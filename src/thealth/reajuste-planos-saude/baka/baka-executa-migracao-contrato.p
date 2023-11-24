{thealth/reajuste-planos-saude/api/api-reajuste-plano.i}

define variable CD_MODALIDADE_ORIGEM  as int no-undo.
define variable NR_TERMO_ORIGEM       as int no-undo.
define variable CD_MODALIDADE_DESTINO as int no-undo.
define variable NR_TERMO_DESTINO      as int no-undo.

define variable ANO_FATURA            as int no-undo.
define variable MES_FATURA            as int no-undo.

define variable hd-api                as handle no-undo.

current-language = current-language.

output to "c:/temp/clientlog-iago.log".
output close.

log-manager:logfile-name = "c:/temp/clientlog-iago.log".
log-manager:log-entry-types = "DB.Connects,4GLTrace:3,4GLMessages,Fileid".
log-manager:logging-level = 4.

run thealth/reajuste-planos-saude/api/api-reajuste-plano.p persistent set hd-api.

assign CD_MODALIDADE_ORIGEM  = 15 
       NR_TERMO_ORIGEM       = 4952 
       CD_MODALIDADE_DESTINO = 15
       NR_TERMO_DESTINO      = 7175
                             
       ANO_FATURA            = 2023
       MES_FATURA            = 7.

do transaction:
    run migrarValoresEntreContratos in hd-api (input  CD_MODALIDADE_ORIGEM,
                                               input  NR_TERMO_ORIGEM,
                                               input  CD_MODALIDADE_DESTINO,
                                               input  NR_TERMO_DESTINO,
                                               input  MES_FATURA,
                                               input  ANO_FATURA,
                                               output table temp-migracao-lote-gerado).



    find first temp-migracao-lote-gerado no-error.

    for each  reajuste-contrato-migracao-item no-lock
        where reajuste-contrato-migracao-item.in-id-lote = temp-migracao-lote-gerado.in-id,
        first usuario no-lock
        where usuario.cd-modalidade                      = reajuste-contrato-migracao-item.in-modalidade-destino
          and usuario.nr-ter-adesao                      = reajuste-contrato-migracao-item.in-termo-destino
          and usuario.cd-usuario                         = reajuste-contrato-migracao-item.in-usuario-destino:
    
        disp reajuste-contrato-migracao-item.in-modalidade-destino  
             reajuste-contrato-migracao-item.in-termo-destino       
             reajuste-contrato-migracao-item.in-usuario-destino.
    end.

    for last  notaserv
        where notaserv.cd-modalidade = 15
          and notaserv.nr-ter-adesao = 7175
          and notaserv.mm-referencia = 7 no-lock:

        for each vlbenef of notaserv no-lock,
            first usuario
            where usuario.cd-modalidade = vlbenef.cd-modalidade
              and usuario.nr-ter-adesao = vlbenef.nr-ter-adesao
              and usuario.cd-usuario    = vlbenef.cd-usuario no-lock:

            disp usuario.cd-usuario usuario.nr-ter-adesao usuario.nm-usuario.
        end.
    end.

    run gerarPdfMigracaoContrato in hd-api (input TABLE temp-migracao-lote-gerado,
                                            input "C:/Users/iago.passos/Desktop/reajuste",
                                            input "reajuste.pdf").

    undo.
end.

finally:
    delete object hd-api no-error.
end.
