
/*------------------------------------------------------------------------
    File        : api-reajuste-plano.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : fabri 
    Created     : Tue Jun 07 07:12:46 BRT 2022
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

using Progress.Json.ObjectModel.JsonArray from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using Progress.Json.ObjectModel.ObjectModelParser from propath.
using Progress.Lang.AppError from propath.

/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */


function buscarDataVencimento returns date private
    (ch-empresa         as   character,
     ch-estabelecimento as   character,
     in-tipo-vencimento as   integer,
     in-vencimento      as   integer,
     in-ano             as   integer,
     in-mes             as   integer) forward.

function buscarNumeroFatura returns integer private
    (in-modalidade          as   integer,
     dc-contratante         as   decimal) forward.

function buscarSequenciaNota returns integer 
    (in-modalidade          as   integer,
     in-termo               as   integer,
     dc-contratante         as   decimal,
     dc-contratante-origem  as   decimal,
     in-ano                 as   integer,
     in-mes                 as   integer) forward.

function numeroParcelas returns integer private
    (in-modalidade  as   integer,
     in-termo       as   integer) forward.

function removerSequenciaNota returns logical private
    (dc-contratante         as   decimal,
     in-ano                 as   integer,
     in-mes                 as   integer) forward.

{thealth/reajuste-planos-saude/api/api-reajuste-plano.i}
{thealth/reajuste-planos-saude/api/simular-faturamento.i}
{thealth/reajuste-planos-saude/interface/reajuste-plano.i}
{thealth/reajuste-planos-saude/utils/reajuste-plano-dominios.i}
{thealth/libs/dates.i}
{thealth/libs/pdf-tools.i}
 
define variable hd-api-config               as   handle     no-undo.
define variable lg-cancelar-pesquisa        as   logical    no-undo.

define new global shared variable v_cod_usuar_corren as character
                          format "x(12)":U label "Usu†rio Corrente"
                                        column-label "Usu†rio Corrente" no-undo.
/* ***************************  Main Block  *************************** */



/* **********************  Internal Procedures  *********************** */



procedure buscarContaContabeis private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade   as   integer    no-undo.
    define input  parameter in-plano        as   integer    no-undo.
    define input  parameter in-tipo-plano   as   integer    no-undo.
    define input  parameter in-forma-pagto  as   integer    no-undo.
    define input  parameter in-evento       as   integer    no-undo.
    define input  parameter in-modulo       as   integer    no-undo.
    define input  parameter in-tipo-contra  as   integer    no-undo.
    define input  parameter dt-emissao      as   date       no-undo.
    define input  parameter ch-tipo-movto   as   character  no-undo.
    define input  parameter rw-movimento    as   rowid      no-undo.
    define output parameter ch-conta        as   character  no-undo.
    define output parameter ch-centro-custo as   character  no-undo.
    
    define variable lg-ct-contabil-aux      as   logical    no-undo.
    define variable ct-codigo-aux           as   character  no-undo.
    define variable sc-codigo-aux           as   character  no-undo.
    define variable ct-codigo-dif-aux       as   character  no-undo.
    define variable sc-codigo-dif-aux       as   character  no-undo.
    define variable ct-codigo-dif-neg-aux   as   character  no-undo.
    define variable sc-codigo-dif-neg-aux   as   character  no-undo.
    define variable ct-codigo-glosa-aux     as   character  no-undo.
    define variable sc-codigo-glosa-aux     as   character  no-undo.
    define variable lg-evencontde-aux       as   logical    no-undo.
    
    run rtp/rtct-contabeis.p (input  in-modalidade,
                              input  in-plano,
                              input  in-tipo-plano,
                              input  in-forma-pagto,
                              input  "FT",
                              input  in-evento,
                              input  in-modulo,
                              input  year (dt-emissao),
                              input  month (dt-emissao),
                              input  if rw-movimento <> ? then 1 else 0,
                              input  ch-tipo-movto,
                              input  rw-movimento,
                              input  in-tipo-contra,
                              input  0,
                              output lg-ct-contabil-aux,
                              output ct-codigo-aux,
                              output sc-codigo-aux,
                              output ct-codigo-dif-aux,
                              output sc-codigo-dif-aux,
                              output ct-codigo-dif-neg-aux,
                              output sc-codigo-dif-neg-aux,
                              output ct-codigo-glosa-aux,
                              output sc-codigo-glosa-aux,
                              output lg-evencontde-aux).
    
    if not lg-ct-contabil-aux
    then do:
        
        undo, throw new AppError ("nao encontrada conta contabil para os parametros de entrada na rtct-contabil", 1).
    end.
    
    assign ch-conta         = ct-codigo-aux   
           ch-centro-custo  = sc-codigo-aux
           .
    

end procedure.

procedure buscarContratos:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade-ini           as   integer    no-undo.
    define input  parameter in-modalidade-fim           as   integer    no-undo.
    define input  parameter in-plano-ini                as   integer    no-undo.
    define input  parameter in-plano-fim                as   integer    no-undo.
    define input  parameter in-tipo-plano-ini           as   integer    no-undo.
    define input  parameter in-tipo-plano-fim           as   integer    no-undo.
    define input  parameter in-contratante-ini          as   integer    no-undo.
    define input  parameter in-contratante-fim          as   integer    no-undo.
    define input  parameter in-termo-ini                as   integer    no-undo.
    define input  parameter in-termo-fim                as   integer    no-undo.
    define input  parameter in-forma-pagto-ini          as   integer    no-undo.
    define input  parameter in-forma-pagto-fim          as   integer    no-undo.
    define input  parameter in-convenio-ini             as   integer    no-undo.
    define input  parameter in-convenio-fim             as   integer    no-undo.
    define input  parameter ch-tipo-pessoa              as   character  no-undo.
    define input  parameter ch-periodo-fat              as   character  no-undo.
    define input  parameter ch-periodo-reajuste         as   character  no-undo.
     
    define output parameter table                       for  temp-contrato. 
    define output parameter table                       for  temp-valor-beneficiario.
    define output parameter table                       for  temp-valor-beneficiario-mes.
        
    define buffer buf-contrat                           for  contrat.
    
    define variable in-ano-ult-reaj                     as   integer    no-undo.
    define variable in-mes-ult-reaj                     as   integer    no-undo.
    define variable dc-perc-ult-reaj                    as   decimal    no-undo.
    define variable in-mes-fat                          as   integer    no-undo.
    define variable in-ano-fat                          as   integer    no-undo.
    
    define variable ch-query                            as   character  no-undo.
    define variable hd-query                            as   handle     no-undo.
    define variable in-mes-reaj-filtro                  as   integer    no-undo.
    define variable in-ano-reaj-filtro                  as   integer    no-undo.
    define variable dt-corte                            as   date       no-undo.
    define variable lg-filtro-mes-reaj                  as   logical    no-undo.
        
    empty temp-table temp-contrato.
    empty temp-table temp-valor-beneficiario.
    empty temp-table temp-valor-beneficiario-mes.
    empty temp-table temp-valor-faturado-mes.
    
    assign in-mes-fat           = integer (substring (ch-periodo-fat, 1, 2))
           in-ano-fat           = integer (substring (ch-periodo-fat, 4, 4))
           in-mes-reaj-filtro   = integer (substring (ch-periodo-reajuste, 1, 2))
           in-ano-reaj-filtro   = integer (substring (ch-periodo-reajuste, 4))               
           dt-corte             = add-interval (ultimoDiaMes(in-ano-reaj-filtro, in-mes-reaj-filtro), -1, 'year')       
           .
    
    assign ch-query = substitute ("
    for each propost no-lock ~n
   use-index propo21 ~n
       where propost.cd-modalidade     >= &1 ~n
         and propost.cd-modalidade     <= &2 ~n
         and propost.cd-plano          >= &3 ~n
         and propost.cd-plano          <= &4 ~n
         and propost.cd-tipo-plano     >= &5 ~n
         and propost.cd-tipo-plano     <= &6 ~n
         and propost.cd-forma-pagto    >= &7 ~n
         and propost.cd-forma-pagto    <= &8",
                                   in-modalidade-ini,
                                   in-modalidade-fim,
                                   in-plano-ini,
                                   in-plano-fim,
                                   in-tipo-plano-ini,
                                   in-tipo-plano-fim,
                                   in-forma-pagto-ini,
                                   in-forma-pagto-fim).
                                   
    assign ch-query =  ch-query + substitute (" ~n
         and propost.cd-contratante    >= &1    ~n
         and propost.cd-contratante    <= &2    ~n
         and propost.nr-ter-adesao     >= &3    ~n
         and propost.nr-ter-adesao     <= &4    ~n
         and propost.cd-sit-proposta   >= 5     ~n
         and propost.cd-sit-proposta   <= 7     ~n
         and propost.cd-convenio       >= &5    ~n
         and propost.cd-convenio       <= &6,   ~n
       first ter-ade no-lock                    ~n
          of propost                            ~n
       where (    ter-ade.dt-inicio    <= &7    ~n
              and propost.cd-convenio   = 1)    ~n
          or (   propost.cd-convenio   <> 1),   ~n
       first contrat no-lock                    ~n
       where contrat.cd-contratante     = propost.cd-contratante",
                                              in-contratante-ini,
                                              in-contratante-fim,
                                              in-termo-ini,      
                                              in-termo-fim,
                                              in-convenio-ini,    
                                              in-convenio-fim,
                                              dt-corte)
            .
                                                                                           
    if ch-tipo-pessoa  <> TIPO_PESSOA_AMBOS
    then do:
        
        assign ch-query = ch-query + substitute (" and contrat.in-tipo-pessoa = '&1'", ch-tipo-pessoa).
    end.                                              
                                              .

    log-manager:write-message (substitute ("query a ser executada: &1", ch-query), "DEBUG") no-error.
    create query hd-query.
    hd-query:set-buffers (buffer propost:handle, buffer ter-ade:handle, buffer contrat:handle).
    hd-query:query-prepare (ch-query).                                          
    hd-query:query-open().
    
    repeat:
        
        hd-query:get-next.
        if hd-query:query-off-end then leave.        
        
        publish EV_API_REAJUSTE_PLANO_CONSULTAR (input  propost.cd-modalidade,
                                                 input  propost.nr-ter-adesao).
                                    
        if available buf-contrat 
        then release buf-contrat.
        
        assign lg-filtro-mes-reaj   = no.
        
        if propost.cd-contrat-origem    > 0
        then do:
            
           for first buf-contrat no-lock
               where buf-contrat.cd-contratante = propost.cd-contrat-origem:                                                   
           end.
        end.

                                                 
        create temp-contrato. 
        assign temp-contrato.in-modalidade          = propost.cd-modalidade
               temp-contrato.in-termo               = propost.nr-ter-adesao
               temp-contrato.in-proposta            = propost.nr-proposta
               temp-contrato.dc-contratante         = propost.cd-contratante
               temp-contrato.ch-contratante         = contrat.nm-contratante
               temp-contrato.dc-contratante-origem  = propost.cd-contrat-origem
               temp-contrato.ch-contratante-origem  = buf-contrat.nm-contratante 
                                                      when available buf-contrat
               in-ano-ult-reaj                      = propost.aa-ult-reajuste
               in-mes-ult-reaj                      = propost.mm-ult-reajuste 
               dc-perc-ult-reaj                     = propost.pc-ult-reajuste
               .
        
        find first reajuste-contrato no-lock
             where reajuste-contrato.in-modalidade  = propost.cd-modalidade
               and reajuste-contrato.in-termo       = propost.nr-ter-adesao
               and reajuste-contrato.ch-periodo-reajuste
                                                    = ch-periodo-reajuste
               and reajuste-contrato.ch-origem-historico
                                                    = ORIGEM_HISTORICO_GERAR_EVENTO 
               and reajuste-contrato.lg-cancelado   = no
                   no-error.
                   
        if available reajuste-contrato
        then do:
            
            assign temp-contrato.lg-eventos-gerados = yes
                   temp-contrato.ch-usuario-evento  = reajuste-contrato.ch-usuario
                   temp-contrato.dt-geracao-evento  = reajuste-contrato.dt-criacao
                   .
        end.                    
                   
        for last histabpreco no-lock
       use-index histabpr1
           where histabpreco.cd-modalidade  = propost.cd-modalidade
             and histabpreco.nr-proposta    = propost.nr-proposta
             and histabpreco.aa-reajuste    = in-ano-reaj-filtro:
                 
            log-manager:write-message (substitute ('LOG -> alterado dados do reajuste para &1, &2/&3',
                                                   histabpreco.pc-reajuste,
                                                   histabpreco.aa-reajuste,
                                                   histabpreco.mm-reajuste), 
                                       'DEBUG') no-error.

            assign dc-perc-ult-reaj = histabpreco.pc-reajuste
                   in-ano-ult-reaj  = histabpreco.aa-reajuste
                   in-mes-ult-reaj  = histabpreco.mm-reajuste 
                   .
                   
            if in-mes-ult-reaj <> in-mes-reaj-filtro
            then do:
                
                assign lg-filtro-mes-reaj   = yes.
                next.
            end.                   
        end.       
        
        assign temp-contrato.ch-ultimo-reajuste             = substitute ('&1/&2', string (in-mes-ult-reaj, '99'), string (in-ano-ult-reaj, '9999'))
               temp-contrato.dc-percentual-ultimo-reajuste  = dc-perc-ult-reaj
               temp-contrato.ch-ultimo-faturamento          = substitute ('&1/&2', string (ter-ade.mm-ult-fat, '99'), string (ter-ade.aa-ult-fat, '9999'))
               .

        if  in-mes-ult-reaj = in-mes-reaj-filtro
        and in-ano-ult-reaj = in-ano-reaj-filtro
        and not temp-contrato.lg-eventos-gerados
        then do:
            
            assign temp-contrato.lg-possui-reajuste-ano-ref = yes
                   .

            run buscarFaturamentoContrato (input              propost.cd-modalidade,
                                           input              propost.nr-ter-adesao,
                                           input              in-ano-ult-reaj,
                                           input              in-mes-ult-reaj,
                                           input              in-ano-fat,
                                           input              in-mes-fat,
                                           input-output table temp-contrato by-reference,
                                           input-output table temp-valor-beneficiario by-reference,
                                           input-output table temp-valor-beneficiario-mes by-reference,
                                           input-output table temp-valor-faturado-mes by-reference 
                                           ).
        end.
    end.
    
end procedure.


procedure buscarDetalhamentoHistorico:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-id-historico             as   integer    no-undo.
    define output parameter lo-detalhe                  as   longchar   no-undo.

    define variable jObj-detalhes   as   JsonObject         no-undo.
    define variable jObj-parser     as   ObjectModelParser  no-undo.
    
    find first reajuste-contrato no-lock
         where reajuste-contrato.in-id      = in-id-historico 
               .

    assign jObj-detalhes    = new JsonObject ()  
           jObj-parser      = new ObjectModelParser ()
           .
           
    copy-lob reajuste-contrato.ch-detalhamento to lo-detalhe convert target codepage 'UTF-8'  .           
        
    assign jObj-detalhes = cast (jObj-parser:parse (lo-detalhe), JsonObject).
                  
    jObj-detalhes:write (lo-detalhe, yes).                           
    
 
end procedure.

procedure buscarFaturamentoContrato:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input        parameter in-modalidade               as   integer    no-undo.
    define input        parameter in-termo                    as   integer    no-undo.
    define input        parameter in-ano-ref                  as   integer    no-undo.
    define input        parameter in-mes-ref                  as   integer    no-undo.
    define input        parameter in-ano-fat                  as   integer    no-undo.
    define input        parameter in-mes-fat                  as   integer    no-undo.
    define input-output parameter table                 for  temp-contrato.
    define input-output parameter table                 for  temp-valor-beneficiario.
    define input-output parameter table                 for  temp-valor-beneficiario-mes.
    define input-output parameter table                 for  temp-valor-faturado-mes.
    

    define variable in-meses-dif                        as   integer    no-undo.
    define variable lg-precisa-simular                  as   logical    no-undo.
    
    define buffer buf-temp-valor-beneficiario-mes       for  temp-valor-beneficiario-mes.      
    define buffer buf-temp-valor-faturado-mes           for  temp-valor-faturado-mes.

    define variable in-mes                              as   integer    no-undo.
    define variable in-ano                              as   integer    no-undo.
    define variable in-idade                            as   integer    no-undo.
    define variable in-mes-ant                          as   integer    no-undo.
    define variable in-ano-ant                          as   integer    no-undo.
    define variable lg-antecipado                       as   logical    no-undo.
    
    
        
    define variable in-numero-parcela as   integer  no-undo.
    define variable in-conta          as   integer  no-undo.
    define variable dc-valor-parcela     as decimal no-undo.
    define variable dc-saldo             as decimal no-undo. 
    
    assign in-ano           = in-ano-ref
           in-mes           = in-mes-ref
           lg-antecipado    = faturamentoAntecipado (in-modalidade, in-termo)
           .
           
    run limpaTemporaria (input  in-modalidade,
                         input  in-termo).           

    
    assign temp-contrato.in-quantidade-parcelas = 0.
           
    // se for da estrutura de faturamento antecipado, diminui uma parcela da geraá∆o.           
    if lg-antecipado
    then do:
        
        assign in-mes = in-mes + 1.
        
        if in-mes > 12
        then 
            assign in-ano   = in-ano + 1
                   in-mes   = 1.
    end.           
                
    repeat:
        
        process events.
        
        log-manager:write-message (substitute ("&1/&2 -> lendo faturamento do periodo &3/&4",
                                               in-modalidade,
                                               in-termo,
                                               in-mes,
                                               in-ano), "DEBUG") no-error.
        
        for each notaserv no-lock
           where notaserv.cd-modalidade     = in-modalidade
             and notaserv.nr-ter-adesao     = in-termo
             and notaserv.aa-referencia     = in-ano
             and notaserv.mm-referencia     = in-mes
             and (   notaserv.in-tipo-nota  = 0
                  or notaserv.in-tipo-nota  = 5):
                
            for each vlbenef no-lock
                  of notaserv,                  
               first usuario no-lock
               where usuario.cd-modalidade  = vlbenef.cd-modalidade
                 and usuario.nr-ter-adesao  = vlbenef.nr-ter-adesao
                 and usuario.cd-usuario     = vlbenef.cd-usuario              
            break by vlbenef.cd-usuario:  
                
                if not available evenfatu 
                or evenfatu.cd-evento  <> vlbenef.cd-evento
                then do:
                    
                    for first evenfatu no-lock
                        where evenfatu.in-entidade  = 'FT'
                          and evenfatu.cd-evento    = vlbenef.cd-evento:
                    end.
                end.             
                
                if not available temp-valor-faturado-mes
                or temp-valor-faturado-mes.in-modalidade   <> in-modalidade
                or temp-valor-faturado-mes.in-termo        <> in-termo
                or temp-valor-faturado-mes.in-usuario      <> vlbenef.cd-usuario
                or temp-valor-faturado-mes.in-ano          <> in-ano
                or temp-valor-faturado-mes.in-mes          <> in-mes
                then do:
                    
                    find first temp-valor-faturado-mes 
                         where temp-valor-faturado-mes.in-modalidade    = in-modalidade     
                           and temp-valor-faturado-mes.in-termo         = in-termo
                           and temp-valor-faturado-mes.in-usuario       = vlbenef.cd-usuario
                           and temp-valor-faturado-mes.in-ano           = in-ano
                           and temp-valor-faturado-mes.in-mes           = in-mes
                               no-error
                               .
                               
                    if not available temp-valor-faturado-mes
                    then do:
                        
                        log-manager:write-message (substitute ("&1/&2/&3 -> criando temporaria valor-mes",
                                                                in-modalidade,
                                                                in-termo,
                                                                vlbenef.cd-usuario), 
                                                   "DEBUG") no-error.
                                                   
                                             
                                                
                        create temp-valor-faturado-mes.
                        assign temp-valor-faturado-mes.in-modalidade    = in-modalidade
                               temp-valor-faturado-mes.in-termo         = in-termo
                               temp-valor-faturado-mes.in-usuario       = vlbenef.cd-usuario
                               temp-valor-faturado-mes.in-ano           = in-ano
                               temp-valor-faturado-mes.in-mes           = in-mes 
                               temp-valor-faturado-mes.in-faixa-etaria  = vlbenef.nr-faixa-etaria
                               temp-valor-faturado-mes.in-idade         = interval (ultimoDiaMes (in-ano, in-mes), usuario.dt-nascimento, 'year')
                               .      
                               
                        assign in-mes-ant = in-mes - 1
                        in-ano-ant = in-ano.
                        
                        if in-mes-ant   = 0
                        then 
                            assign in-ano-ant   = in-ano-ant - 1
                                   in-mes-ant   = 12.      
                                   
                        find first buf-temp-valor-faturado-mes 
                             where buf-temp-valor-faturado-mes.in-modalidade    = temp-valor-faturado-mes.in-modalidade
                               and buf-temp-valor-faturado-mes.in-termo         = temp-valor-faturado-mes.in-termo
                               and buf-temp-valor-faturado-mes.in-usuario       = temp-valor-faturado-mes.in-usuario
                               and buf-temp-valor-faturado-mes.in-ano           = temp-valor-faturado-mes.in-ano
                               and buf-temp-valor-faturado-mes.in-mes           = temp-valor-faturado-mes.in-mes
                                   no-error. 
                                   
                        if available buf-temp-valor-faturado-mes
                        and buf-temp-valor-faturado-mes.in-faixa-etaria    <> temp-valor-faturado-mes.in-faixa-etaria
                        then
                            assign temp-valor-faturado-mes.lg-trocou-faixa  = yes. 
                    end.
                end.
                
                if considerarEvento (evenfatu.cd-evento, evenfatu.in-classe-evento)
                then do:
                    
                    log-manager:write-message (substitute ("&1/&2/&3 -> somando evento &4, valor &5",
                                                           vlbenef.cd-modalidade,
                                                           vlbenef.nr-ter-adesao,
                                                           vlbenef.cd-usuario,
                                                           vlbenef.cd-evento, 
                                                           vlbenef.vl-usuario), 
                                               "DEBUG") no-error. 
                                               
                    assign temp-valor-faturado-mes.dc-valor-referencia  = temp-valor-faturado-mes.dc-valor-referencia + 
                                                                          if (evenfatu.lg-cred-deb) 
                                                                          then vlbenef.vl-usuario
                                                                          else vlbenef.vl-usuario * -1.
                end.
   
            end.
        end. 
    
        assign in-mes   = in-mes + 1
               . 
        
        if in-mes > 12
        then 
            assign in-ano   = in-ano + 1
                   in-mes   = 1.
          
        if  in-ano  = in-ano-fat
        and in-mes  = in-mes-fat
        then do:
            log-manager:write-message (substitute ("&1/&2 -> terminada leitura do faturamento",
                                                   temp-contrato.in-modalidade,
                                                   temp-contrato.in-termo), "DEBUG") no-error.
            leave.
        end. 
        
        if in-ano > in-ano-fat
        then leave.
    end.
    
                               
    for each temp-valor-faturado-mes
       where temp-valor-faturado-mes.in-modalidade  = in-modalidade
         and temp-valor-faturado-mes.in-termo       = in-termo
    break by temp-valor-faturado-mes.in-ano
          by temp-valor-faturado-mes.in-mes: 
              
        if first-of (temp-valor-faturado-mes.in-ano)
        or first-of (temp-valor-faturado-mes.in-mes)
        then do:
            
            assign temp-contrato.in-quantidade-parcelas = temp-contrato.in-quantidade-parcelas + 1.
        end.               
    end.
    
    log-manager:write-message (substitute ("&1/&2 -> parcelas calculadas pelo sistema: &3",
                                           in-modalidade,
                                           in-termo,
                                           temp-contrato.in-quantidade-parcelas), 
                               "DEBUG") no-error.
                               
                               
    log-manager:write-message (substitute ("&1/&2 -> criando acumulado por beneficiario",
                                           in-modalidade,
                                           in-termo), 
                               "DEBUG") no-error.
                               
    for each temp-valor-faturado-mes
       where temp-valor-faturado-mes.in-modalidade  = in-modalidade
         and temp-valor-faturado-mes.in-termo       = in-termo
    break by temp-valor-faturado-mes.in-usuario:
        
                                               
        if first-of (temp-valor-faturado-mes.in-usuario)
        then do:

            log-manager:write-message (substitute ("&1/&2/&3 -> criando acumulado",
                                                   in-modalidade,
                                                   in-termo,
                                                   temp-valor-faturado-mes.in-usuario), 
                                       "DEBUG") no-error.

            find first usuario no-lock
                 where usuario.cd-modalidade    = temp-valor-faturado-mes.in-modalidade
                   and usuario.nr-ter-adesao    = temp-valor-faturado-mes.in-termo
                   and usuario.cd-usuario       = temp-valor-faturado-mes.in-usuario
                       .
            
            find first gra-par no-lock
                 where gra-par.cd-grau-parentesco   = usuario.cd-grau-parentesco
                       .
                       
            create temp-valor-beneficiario.
            assign temp-valor-beneficiario.rc-contrato          = recid (temp-contrato)
                   temp-valor-beneficiario.in-modalidade        = temp-valor-faturado-mes.in-modalidade
                   temp-valor-beneficiario.in-termo             = temp-valor-faturado-mes.in-termo
                   temp-valor-beneficiario.in-usuario           = temp-valor-faturado-mes.in-usuario
                   temp-valor-beneficiario.ch-grau-parentesto   = gra-par.ds-grau-parentesco
                   temp-valor-beneficiario.ch-nome-usuario      = usuario.nm-usuario
                   temp-valor-beneficiario.dt-inclusao-plano    = usuario.dt-inclusao-plano
                   temp-valor-beneficiario.dt-nascimento        = usuario.dt-nascimento
                   temp-contrato.in-quantidade-vidas            = temp-contrato.in-quantidade-vidas + 1
                   .          
                   
        end.            
        
        assign temp-valor-faturado-mes.dc-valor-reajuste    = round ((temp-contrato.dc-percentual-ultimo-reajuste * 
                                                                      temp-valor-faturado-mes.dc-valor-referencia) / 
                                                                      100, 2)
                                                                      
               temp-valor-beneficiario.dc-valor-referencia  = temp-valor-beneficiario.dc-valor-referencia + 
                                                              temp-valor-faturado-mes.dc-valor-referencia
                                                                                                                                    
               temp-valor-beneficiario.dc-valor-cobrar      = temp-valor-beneficiario.dc-valor-cobrar +
                                                              temp-valor-faturado-mes.dc-valor-reajuste
               .  
                                                                                                                  
        log-manager:write-message (substitute ("&1/&2/&3 -> per: &4/&5, valor ref: &6, valor reaj: &7",
                                               temp-valor-faturado-mes.in-modalidade,
                                               temp-valor-faturado-mes.in-termo,
                                               temp-valor-faturado-mes.in-usuario,
                                               temp-valor-faturado-mes.in-mes,
                                               temp-valor-faturado-mes.in-ano,
                                               temp-valor-faturado-mes.dc-valor-referencia,
                                               temp-valor-faturado-mes.dc-valor-reajuste), 
                                   "DEBUG") no-error.
                                   
        if last-of (temp-valor-faturado-mes.in-usuario)
        then do:
            
            log-manager:write-message (substitute ("&1/&2/&3 -> total a cobrar: &4",
                                                   in-modalidade,
                                                   in-termo,
                                                   temp-valor-beneficiario.in-usuario,
                                                   temp-valor-beneficiario.dc-valor-cobrar), 
                                       "DEBUG") no-error.
        end.                                   
    end.
    
    assign in-numero-parcela    = numeroParcelas (in-modalidade, in-termo).
            
    log-manager:write-message (substitute ("&1/&2 -> iniciando calculo do valor das parcelas",
                                           in-modalidade,
                                           in-termo), "DEBUG") no-error.         
    
    for each temp-valor-beneficiario
       where temp-valor-beneficiario.in-modalidade  = in-modalidade
         and temp-valor-beneficiario.in-termo       = in-termo:   
        
        log-manager:write-message (substitute ("&1/&2/&3 -> calculando valores do benef",
                                               in-modalidade,
                                               in-termo,
                                               temp-valor-beneficiario.in-usuario), 
                                   "DEBUG") no-error.            
            
        assign in-conta         = 1
               in-mes           = in-mes-fat
               in-ano           = in-ano-fat
               dc-valor-parcela = round (temp-valor-beneficiario.dc-valor-cobrar / in-numero-parcela, 2)
               dc-saldo         = temp-valor-beneficiario.dc-valor-cobrar - (dc-valor-parcela * in-numero-parcela).
               .        
 
        bloco_repeat:
        repeat:
            
            log-manager:write-message (substitute ("&1/&2/&3 -> criando parcela &4",
                                                   in-modalidade,
                                                   in-termo,
                                                   temp-valor-beneficiario.in-usuario,
                                                   in-conta), 
                                       "DEBUG") no-error.
            
            create temp-valor-beneficiario-mes.
            assign temp-valor-beneficiario-mes.in-modalidade        = temp-valor-beneficiario.in-modalidade
                   temp-valor-beneficiario-mes.in-termo             = temp-valor-beneficiario.in-termo
                   temp-valor-beneficiario-mes.in-usuario           = temp-valor-beneficiario.in-usuario
                   temp-valor-beneficiario-mes.in-ano               = in-ano
                   temp-valor-beneficiario-mes.in-mes               = in-mes
                   temp-valor-beneficiario-mes.dc-valor-parcela     = dc-valor-parcela
                   temp-valor-beneficiario-mes.in-numero-parcela    = in-conta
                   .
                   
            if  in-conta    = in-numero-parcela
            and dc-saldo    > 0
            then               
                assign temp-valor-beneficiario-mes.dc-valor-parcela = temp-valor-beneficiario-mes.dc-valor-parcela + dc-saldo.         
                   

            log-manager:write-message (substitute ("&1/&2/&3 -> parcela &4 no valor de &5 criada para &6/&7",
                                                   in-modalidade,
                                                   in-termo,
                                                   temp-valor-beneficiario.in-usuario,
                                                   in-conta,
                                                   temp-valor-beneficiario-mes.dc-valor-parcela,
                                                   temp-valor-beneficiario-mes.in-mes,
                                                   temp-valor-beneficiario-mes.in-ano), 
                                       "DEBUG") no-error.

            

            assign in-conta = in-conta + 1
                   in-mes   = in-mes + 1
                   .
                   
            if in-mes > 12
            then 
                assign in-mes   = 1
                       in-ano   = in-ano + 1
                       .
            
            if in-conta > in-numero-parcela
            then leave bloco_repeat.
        end.                                   
    end.  
end procedure.


procedure buscarHistoricoContrato:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input        parameter in-modalidade         as   integer    no-undo.
    define input        parameter in-termo              as   integer    no-undo.
    define input-output parameter table                 for  temp-historico.
    
    for each reajuste-contrato no-lock
       where reajuste-contrato.in-modalidade    = in-modalidade
         and reajuste-contrato.in-termo         = in-termo:

        publish EV_API_REAJUSTE_PLANO_CONSULTAR (reajuste-contrato.in-modalidade,
                                                 reajuste-contrato.in-termo).
        process events.
             
        find first temp-historico
             where temp-historico.in-id-historico       = reajuste-contrato.in-id
                   no-error.
                   
        if not available temp-historico
        then do:
            
            create temp-historico.
            assign temp-historico.in-id-historico       = reajuste-contrato.in-id
                   temp-historico.ch-origem-historico   = reajuste-contrato.ch-origem-historico
                   temp-historico.ch-periodo-reajuste   = reajuste-contrato.ch-periodo-reajuste
                   temp-historico.dc-valor-cobrado      = reajuste-contrato.dc-valor-cobrado
                   temp-historico.in-modalidade         = reajuste-contrato.in-modalidade
                   temp-historico.in-quantidade-parcelas    
                                                        = reajuste-contrato.in-quantidade-parcelas
                   temp-historico.in-termo              = reajuste-contrato.in-termo
                   temp-historico.ch-usuario            = reajuste-contrato.ch-usuario
                   temp-historico.dt-ocorrencia         = reajuste-contrato.dt-criacao
                   
                   .
        end.                   
    end.           

end procedure.

procedure criarEventoProgramado private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade               as   integer    no-undo.
    define input  parameter in-termo                    as   integer    no-undo.
    define input  parameter in-usuario                  as   integer    no-undo.
    define input  parameter in-ano                      as   integer    no-undo.
    define input  parameter in-mes                      as   integer    no-undo.
    define input  parameter in-evento                   as   integer    no-undo.
    define input  parameter dc-valor                    as   decimal    no-undo.
    define input  parameter ch-mensagem                 as   character  no-undo.
    
    define buffer buf-propost   for  propost.
    
    do transaction on error undo, throw:
        
        find first event-progdo-bnfciar exclusive-lock 
             where event-progdo-bnfciar.cd-modalidade   = in-modalidade
               and event-progdo-bnfciar.nr-ter-adesao   = in-termo
               and event-progdo-bnfciar.cd-usuario      = in-usuario
               and event-progdo-bnfciar.aa-referencia   = in-ano
               and event-progdo-bnfciar.mm-referencia   = in-mes
               and event-progdo-bnfciar.cd-evento       = in-evento
                   no-error.
                   
        
        if not available event-progdo-bnfciar
        then do:
            
            log-manager:write-message (substitute ("&1/&2/&3 -> evento nao existe, criando",
                                                   in-modalidade,
                                                   in-termo,
                                                   in-usuario), "DEBUG") no-error.
            
            create event-progdo-bnfciar.
            assign event-progdo-bnfciar.cd-modalidade           = in-modalidade 
                   event-progdo-bnfciar.nr-ter-adesao           = in-termo
                   event-progdo-bnfciar.cd-usuario              = in-usuario
                   event-progdo-bnfciar.aa-referencia           = in-ano        
                   event-progdo-bnfciar.mm-referencia           = in-mes     
                   event-progdo-bnfciar.cd-evento               = in-evento 
                   event-progdo-bnfciar.cd-moeda                = 0
                   event-progdo-bnfciar.qt-evento               = 1
                   event-progdo-bnfciar.cod-livre-1             = ch-mensagem                   
                   .                    
        end.
        
                
        log-manager:write-message (substitute ("&1/&2/&3 -> registrando valor evento &4, periodo &5/&6, valor &7",    
                                               in-modalidade,
                                               in-termo,
                                               in-usuario,
                                               in-mes,
                                               in-ano,
                                               dc-valor), "DEBUG") no-error.
        
        assign event-progdo-bnfciar.vl-evento               = event-progdo-bnfciar.vl-evento + dc-valor
               event-progdo-bnfciar.dat-ult-atualiz         = today
               event-progdo-bnfciar.cod-usuar-ult-atualiz   = v_cod_usuar_corren
               .
    end.
end procedure.


procedure criarNota private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade           as   integer    no-undo.
    define input  parameter in-termo                as   integer    no-undo.
    define input  parameter in-ano                  as   integer    no-undo.
    define input  parameter in-mes                  as   integer    no-undo.
    
    define variable in-total-eventos                as   integer    no-undo.    
    define variable dc-valor-total                  as   decimal    no-undo.
    
    define variable dt-vencimento                   as   date       no-undo.
    define variable in-numero-fatura                as   integer    no-undo.
    define variable in-sequencia-nota               as   integer    no-undo.
    
    define variable ch-especie                      as   character  no-undo.

    define variable ch-conta                        as   character  no-undo.    
    define variable ch-centro                       as   character  no-undo.
    
    define variable dc-contratante                  as   decimal    no-undo.
    define variable dc-contratante-origem           as   decimal    no-undo.
    define variable in-insc-contratante             as   integer    no-undo.
    define variable in-insc-contratante-origem      as   integer    no-undo.
    
    define variable in-portador                     as   integer    no-undo.
    define variable in-modalidade-cob               as   integer    no-undo. 
        
    if not available parafatu then find first parafatu no-lock.    
    if not available paramecp then find first paramecp no-lock.

    for first propost no-lock
        where propost.cd-modalidade = in-modalidade
          and propost.nr-ter-adesao = in-termo,
        first ter-ade no-lock
           of propost.
    end.
    
    if ter-ade.in-contratante-mensalidade = 0
    then do:
        
        for first contrat no-lock
            where contrat.cd-contratante    = propost.cd-contratante.
        end.
        
        assign dc-contratante       = contrat.cd-contratante
               in-insc-contratante  = contrat.nr-insc-contratante
               in-portador          = contrat.portador
               in-modalidade-cob    = contrat.modalidade
               .
               
        if propost.cd-contrat-origem   <> 0
        then do:
            
            for first contrat no-lock
                where contrat.cd-contratante    = propost.cd-contrat-origem.
            end.
            
            assign dc-contratante-origem        = contrat.cd-contratante
                   in-insc-contratante-origem   = contrat.nr-insc-contratante
                   .            
        end.
    end.
    else do:
        
        for first contrat no-lock
            where contrat.cd-contratante    = propost.cd-contrat-origem.
        end.
        assign dc-contratante       = contrat.cd-contratante
               in-insc-contratante  = contrat.nr-insc-contratante
               in-portador          = contrat.portador
               in-modalidade-cob    = contrat.modalidade
               .
               
        if propost.cd-contrat-origem   <> 0
        then do:
            
            for first contrat no-lock
                where contrat.cd-contratante    = propost.cd-contratante.
            end.
            
            assign dc-contratante-origem        = contrat.cd-contratante
                   in-insc-contratante-origem   = contrat.nr-insc-contratante
                   .            
        end.
    end.
    
    find first estrsitu no-lock 
         where estrsitu.in-entidade     = "FT"
           and estrsitu.cd-estrutura    = parafatu.cd-estrutura.

    log-manager:write-message (substitute ("thealth -> contratante: &1, origem: &2", dc-contratante, dc-contratante-origem), "DEBUG") no-error.
    
    log-manager:write-message (substitute ("thealth -> bucando data de vencimento"), "DEBUG") no-error.
    assign dt-vencimento    = buscarDataVencimento (paramecp.ep-codigo, 
                                                    propost.cod-estabel, 
                                                    propost.cd-tipo-vencimento, 
                                                    propost.dd-vencimento, 
                                                    in-ano, 
                                                    in-mes).
    log-manager:write-message (substitute ("thealth -> data de vencimento: &1", dt-vencimento), "DEBUG") no-error.                                                    
                                                    
    log-manager:write-message (substitute ("thealth -> buscando numero da fatura"), "DEBUG") no-error.                                                    
    assign in-numero-fatura = buscarNumeroFatura (in-modalidade, dc-contratante).
    log-manager:write-message (substitute ("thealth -> numero da fatura: &1", in-numero-fatura), "DEBUG") no-error.
    
    log-manager:write-message (substitute ("thealth -> buscando sequencia nota"), "DEBUG") no-error.    
    assign in-sequencia-nota    = buscarSequenciaNota (in-modalidade, 
                                                       in-termo, 
                                                       dc-contratante, 
                                                       dc-contratante-origem, 
                                                       in-ano, 
                                                       in-mes).
    log-manager:write-message (substitute ("thealth -> sequencia da nota: &1", in-sequencia-nota), "DEBUG") no-error.
    
    if not available parafatu then find first parafatu no-lock.                                                       
                                                       
    assign ch-especie   = parafatu.char-24.            
    
    
    
    
    
    
    
    publish EV_API_REAJUSTE_PLANO_MIGRAR_VALORES (input  substitute ("Criando fatura")).
    
    
    
                                                      
          
    /** cria nota de serviáo */
    log-manager:write-message (substitute ("thealth -> criando notaserv: &1|&2|&3|&4|&5|&6|&7",
                                           in-modalidade,
                                           dc-contratante,
                                           dc-contratante-origem,
                                           in-termo,
                                           in-ano,
                                           in-mes,
                                           in-sequencia-nota), "DEBUG") no-error.
    create notaserv.
    assign notaserv.cd-modalidade         = in-modalidade
           notaserv.cd-contratante        = dc-contratante
           notaserv.cd-contratante-origem = dc-contratante-origem
           notaserv.nr-ter-adesao         = in-termo
           notaserv.cd-especie            = ch-especie
           notaserv.aa-referencia         = in-ano
           notaserv.mm-referencia         = in-mes
           notaserv.nr-sequencia          = in-sequencia-nota
           notaserv.ep-codigo             = parafatu.ep-codigo
           notaserv.cod-estabel           = parafatu.cod-estabel
           notaserv.dt-emissao            = today
           notaserv.dt-vencimento         = dt-vencimento
           notaserv.mo-codigo             = 0
           notaserv.vl-total              = 0
           notaserv.nr-fatura             = in-numero-fatura
           notaserv.lg-contabilizada      = no
           notaserv.cd-userid             = v_cod_usuar_corren
           notaserv.dt-atualizacao        = today
           notaserv.date-1                = today.
          

    log-manager:write-message (substitute ("thealth -> criando fatura: &1|&2", dc-contratante, in-numero-fatura), "DEBUG") no-error.
      /** cria fatura e vincula a nota de servico */
    create fatura.
    assign fatura.cd-contratante            = dc-contratante
           fatura.nr-fatura                 = in-numero-fatura
           fatura.aa-referencia             = in-ano
           fatura.mm-referencia             = in-mes
           fatura.ep-codigo                 = parafatu.ep-codigo
           fatura.cod-estabel               = parafatu.cod-estabel
           fatura.cd-modalidade             = in-modalidade
           fatura.cd-especie                = ch-especie
           fatura.ds-mensagem               = 'Fatura gerada automaticamente pela rotina de migraá∆o de valores de reajuste entre contratos'
           fatura.portador                  = in-portador
           fatura.modalidade                = in-modalidade-cob
           fatura.ct-codigo                 = parafatu.ct-codigo
           fatura.sc-codigo                 = parafatu.sc-codigo
           fatura.nr-titulo-acr             = ""
           fatura.parcela                   = 0
           fatura.dt-emissao                = today
           fatura.dt-vencimento             = dt-vencimento
           fatura.cd-tipo-vencimento        = 0
           fatura.cd-sit-fatu               = estrsitu.cd-sit-inicial
           fatura.mo-codigo                 = 0
           fatura.in-tipo-fatura            = 3
           fatura.cd-userid                 = v_cod_usuar_corren
           fatura.dt-atualizacao            = today
           fatura.date-3                    = today
           fatura.nr-ter-adesao-estatistica = 0
           fatura.dec-1                     = 0
           fatura.dec-2                     = 0
           fatura.log-1                     = no
           fatura.int-4                     = 0
           fatura.int-10                    = 0
           .
           
    for each temp-assoc-usuario
       where temp-assoc-usuario.in-usuario-destino <> 0,
       first evenfatu no-lock
       where evenfatu.in-entidade                   = "FT"
         and evenfatu.cd-evento                     = temp-assoc-usuario.in-evento  
    break by temp-assoc-usuario.in-evento:

        if first-of (temp-assoc-usuario.in-evento)
        then do:
            
            assign dc-valor-total   = 0
                   in-total-eventos = 0
                   .
        end.
                
        log-manager:write-message (substitute ("thealth -> criando vlbenef para benef &1", temp-assoc-usuario.in-usuario-destino), "DEBUG") no-error.    
        find first temp-evento-conta
             where temp-evento-conta.in-evento  = temp-assoc-usuario.in-evento
                   no-error.
                   
        if not available temp-evento-conta
        then do:
            
            run buscarContaContabeis (input  propost.cd-modalidade, 
                                      input  propost.cd-plano, 
                                      input  propost.cd-tipo-plano, 
                                      input  propost.cd-forma-pagto, 
                                      input  temp-assoc-usuario.in-evento, 
                                      input  0, 
                                      input  propost.in-tipo-contratacao, 
                                      input  today, 
                                      input  "", 
                                      input  ?, 
                                      output ch-conta, 
                                      output ch-centro).
                                      
            create temp-evento-conta.
            assign temp-evento-conta.ch-centro  = ch-centro
                   temp-evento-conta.ch-conta   = ch-conta
                   temp-evento-conta.in-evento  = temp-assoc-usuario.in-evento
                   .
        end.        
        
        publish EV_API_REAJUSTE_PLANO_MIGRAR_VALORES (input  substitute ("&1/&2 - Registrando valor para o benefici†rio &3 - &4 - R$ &5",
                                                                         in-modalidade,
                                                                         in-termo,
                                                                         temp-assoc-usuario.in-usuario-destino,
                                                                         temp-assoc-usuario.ch-nome,
                                                                         string (temp-assoc-usuario.dc-valor-evento, ">>>>>9.99"))).        

        create vlbenef.
        assign vlbenef.cd-modalidade            = notaserv.cd-modalidade               
               vlbenef.cd-contratante           = notaserv.cd-contratante       
               vlbenef.cd-contratante-origem    = notaserv.cd-contratante-origem
               vlbenef.nr-ter-adesao            = notaserv.nr-ter-adesao         
               vlbenef.aa-referencia            = notaserv.aa-referencia                  
               vlbenef.mm-referencia            = notaserv.mm-referencia                  
               vlbenef.nr-sequencia             = notaserv.nr-sequencia                   
               vlbenef.cd-usuario               = temp-assoc-usuario.in-usuario-destino           
               vlbenef.cd-evento                = temp-assoc-usuario.in-evento 
               vlbenef.cd-modulo                = 0
               vlbenef.nr-faixa-etaria          = temp-assoc-usuario.in-faixa-etaria
               vlbenef.cd-grau-parentesco       = temp-assoc-usuario.in-grau-parentesco
               vlbenef.char-1                   = ''
               vlbenef.cd-userid                = v_cod_usuar_corren
               vlbenef.dt-atualizacao           = today
               vlbenef.vl-usuario               = temp-assoc-usuario.dc-valor-evento
               vlbenef.vl-total                 = temp-assoc-usuario.dc-valor-evento
               dc-valor-total                   = dc-valor-total + temp-assoc-usuario.dc-valor-evento
               in-total-eventos                 = in-total-eventos + temp-assoc-usuario.in-quantidade-evento
               .
               
        if last-of (temp-assoc-usuario.in-evento)
        then do:
            
            log-manager:write-message (substitute ("thealth -> criando fatueven"), "DEBUG") no-error.
            create fatueven.
            assign fatueven.cd-modalidade           = notaserv.cd-modalidade
                   fatueven.cd-contratante          = notaserv.cd-contratante
                   fatueven.cd-contratante-origem   = notaserv.cd-contratante-origem
                   fatueven.nr-ter-adesao           = notaserv.nr-ter-adesao
                   fatueven.aa-referencia           = notaserv.aa-referencia
                   fatueven.mm-referencia           = notaserv.mm-referencia
                   fatueven.nr-sequencia            = notaserv.nr-sequencia
                   fatueven.cd-evento               = temp-assoc-usuario.in-evento
                   fatueven.cd-tipo-cob             = 0
                   fatueven.lg-cred-deb             = yes
                   fatueven.lg-destacado            = evenfatu.lg-destacado
                   fatueven.lg-modulo               = no
                   fatueven.ct-codigo               = temp-evento-conta.ch-conta
                   fatueven.sc-codigo               = temp-evento-conta.ch-centro
                   fatueven.qt-evento-ref           = 0
                   fatueven.vl-evento-ref           = 0
                   fatueven.cd-userid               = v_cod_usuar_corren
                   fatueven.qt-evento               = in-total-eventos 
                   fatueven.vl-evento               = dc-valor-total
                   fatueven.cd-userid               = v_cod_usuar_corren
                   fatueven.dt-atualizacao          = today
                   .
        end.               
    end.
    
    assign notaserv.vl-total    = dc-valor-total
           fatura.vl-total      = dc-valor-total
           .
    
    for each temp-assoc-usuario
       where temp-assoc-usuario.in-usuario-destino <> 0
    break by temp-assoc-usuario.in-grau-parentesco
          by temp-assoc-usuario.in-faixa-etaria:
              
        if first-of (temp-assoc-usuario.in-grau-parentesco)
        or first-of (temp-assoc-usuario.in-faixa-etaria)
        then do:
            
            find first temp-evento-conta
                 where temp-evento-conta.in-evento  = temp-assoc-usuario.in-evento
                       no-error.
                                   
            create fatgrmod.
            assign fatgrmod.cd-modalidade           = in-modalidade
                   fatgrmod.nr-ter-adesao           = in-termo
                   fatgrmod.aa-referencia           = in-ano
                   fatgrmod.mm-referencia           = in-mes
                   fatgrmod.nr-sequencia            = in-sequencia-nota
                   fatgrmod.cd-evento               = temp-assoc-usuario.in-evento
                   fatgrmod.cd-grau-parentesco      = temp-assoc-usuario.in-grau-parentesco
                   fatgrmod.ct-codigo               = temp-evento-conta.ch-conta
                   fatgrmod.sc-codigo               = temp-evento-conta.ch-centro
                   fatgrmod.nr-faixa-etaria         = temp-assoc-usuario.in-faixa-etaria
                   fatgrmod.cd-modulo               = 0
                   fatgrmod.ch-evento-grau-modulo   = string (temp-assoc-usuario.in-evento, "999") +
                                                      string (temp-assoc-usuario.in-grau-parentesco, "99") +
                                                      string (temp-assoc-usuario.in-faixa-etaria, "99") +
                                                      string (0, "999")
                   fatgrmod.cd-userid               = v_cod_usuar_corren
                   fatgrmod.dt-atualizacao          = today
                   fatgrmod.cd-contratante          = dc-contratante
                   fatgrmod.cd-contratante-origem   = in-insc-contratante-origem                   
                   .
        end.
        
        assign fatgrmod.qt-evento   = fatgrmod.qt-evento + temp-assoc-usuario.in-quantidade-evento
               fatgrmod.vl-evento   = fatgrmod.vl-evento + temp-assoc-usuario.dc-valor-evento
               .        
    end. 
    
    if not available temp-assoc-usuario
    then find first temp-assoc-usuario.
    
    create reajuste-contrato-migracao-lote.
    assign reajuste-contrato-migracao-lote.in-id                    = next-value (seq-reajuste-contrato-migracao-l)
           reajuste-contrato-migracao-lote.in-modalidade-destino    = in-modalidade
           reajuste-contrato-migracao-lote.in-termo-destino         = in-termo
           reajuste-contrato-migracao-lote.dt-ocorrencia            = now
           reajuste-contrato-migracao-lote.ch-tipo-fatura           = TIPO_FATURA_NORMAL
           reajuste-contrato-migracao-lote.dt-emissao               = fatura.dt-emissao
           reajuste-contrato-migracao-lote.dt-vencimento            = fatura.dt-vencimento
           reajuste-contrato-migracao-lote.dc-contratante           = fatura.cd-contratante
           reajuste-contrato-migracao-lote.in-fatura                = fatura.nr-fatura
           reajuste-contrato-migracao-lote.dc-total                 = fatura.vl-total
           .   
           
    create reajuste-contrato.
    assign reajuste-contrato.in-id                      = next-value (seq-reajuste-contrato)
           reajuste-contrato.in-modalidade              = temp-assoc-usuario.in-modalidade-origem
           reajuste-contrato.in-termo                   = temp-assoc-usuario.in-termo-origem
           reajuste-contrato.in-quantidade-parcelas     = 0            
           reajuste-contrato.lg-cancelado               = no
           reajuste-contrato.lg-gerado-eventos          = yes
           reajuste-contrato.dt-criacao                 = now
           reajuste-contrato.dc-valor-cobrado           = fatura.vl-total
           reajuste-contrato.ch-detalhamento            = substitute ("EVENTOS MIGRADOS DO CONTRATO &1/&2 PARA O CONTRATO &3/4",
                                                                      temp-assoc-usuario.in-modalidade-origem,
                                                                      temp-assoc-usuario.in-termo-origem,
                                                                      in-modalidade,
                                                                      in-termo)
           reajuste-contrato.ch-origem-historico        = ORIGEM_HISTORICO_MIGRAR_EVENTO
           .            
           
    create temp-migracao-lote-gerado.
    assign temp-migracao-lote-gerado.in-id-lote = reajuste-contrato-migracao-lote.in-id.           

    log-manager:write-message (substitute ("thealth -> registrando na tabela de historico"), "DEBUG") no-error.
    for each temp-assoc-usuario
       where temp-assoc-usuario.in-usuario-destino <> 0:
           
           
        
        publish EV_API_REAJUSTE_PLANO_MIGRAR_VALORES (input  substitute ("&1/&2 - Registrando hist¢rico para o benefici†rio &3 - &4 - R$ &5",
                                                                         in-modalidade,
                                                                         in-termo,
                                                                         temp-assoc-usuario.in-usuario-destino,
                                                                         temp-assoc-usuario.ch-nome,
                                                                         string (temp-assoc-usuario.dc-valor-evento, ">>>>>9.99")))
                .        
        
        create reajuste-contrato-migracao-item.
        assign reajuste-contrato-migracao-item.in-id                    = next-value (seq-reajuste-contrato-migracao-i)
		       reajuste-contrato-migracao-item.in-id-lote               = reajuste-contrato-migracao-lote.in-id
               reajuste-contrato-migracao-item.ch-usuario               = v_cod_usuar_corren
               reajuste-contrato-migracao-item.dt-ocorrencia            = now
               reajuste-contrato-migracao-item.dc-valor-evento          = temp-assoc-usuario.dc-valor-evento
               reajuste-contrato-migracao-item.in-quantidade-eventos    = temp-assoc-usuario.in-quantidade-evento
               reajuste-contrato-migracao-item.in-ano                   = in-ano
               reajuste-contrato-migracao-item.in-mes                   = in-mes
               reajuste-contrato-migracao-item.in-evento                = temp-assoc-usuario.in-evento
               reajuste-contrato-migracao-item.in-faixa-etaria          = temp-assoc-usuario.in-faixa-etaria
               reajuste-contrato-migracao-item.in-grau-parentesco       = temp-assoc-usuario.in-grau-parentesco
               reajuste-contrato-migracao-item.in-modalidade-destino    = in-modalidade
               reajuste-contrato-migracao-item.in-termo-destino         = in-termo
               reajuste-contrato-migracao-item.in-modalidade-origem     = temp-assoc-usuario.in-modalidade-origem
               reajuste-contrato-migracao-item.in-termo-origem          = temp-assoc-usuario.in-termo-origem
               reajuste-contrato-migracao-item.in-usuario-destino       = temp-assoc-usuario.in-usuario-destino
               reajuste-contrato-migracao-item.in-usuario-origem        = temp-assoc-usuario.in-usuario-origem
               reajuste-contrato-migracao-item.in-sequencia-nota        = in-sequencia-nota
               reajuste-contrato-migracao-item.in-fatura                = in-numero-fatura
               reajuste-contrato-migracao-item.dc-contratante           = dc-contratante
               reajuste-contrato-migracao-lote.in-modalidade-origem     = temp-assoc-usuario.in-modalidade-origem
               reajuste-contrato-migracao-lote.in-termo-origem          = temp-assoc-usuario.in-termo-origem
               .         
    end.
    
    find first temp-assoc-usuario
         where temp-assoc-usuario.in-usuario-destino    = 0
               no-error.
               
    log-manager:write-message (substitute ("thealth -> existe benef nao migrado?: &1", available temp-assoc-usuario), "DEBUG") no-error.               
    if available temp-assoc-usuario
    then do:
        
        log-manager:write-message (substitute ("thealth -> encontrado valor devido para beneficiario que nao foi migrado para contrato destino "), "DEBUG") no-error.
        
        assign dc-valor-total   = 0
               in-total-eventos = 0
               .


        log-manager:write-message (substitute ("thealth -> buscando numero da fatura"), "DEBUG") no-error.
        assign in-numero-fatura = buscarNumeroFatura (in-modalidade, dc-contratante).        
        log-manager:write-message (substitute ("thealth -> numero da fatura: &1", in-numero-fatura), "DEBUG") no-error.
        
        log-manager:write-message (substitute ("thealth -> buscando sequencia nota"), "DEBUG") no-error.            
        assign in-sequencia-nota    = buscarSequenciaNota (in-modalidade, 
                                                           in-termo, 
                                                           dc-contratante, 
                                                           dc-contratante-origem, 
                                                           in-ano, 
                                                           in-mes).
        log-manager:write-message (substitute ("thealth -> sequencia da nota: &1", in-sequencia-nota), "DEBUG") no-error.

        create notaserv.
        assign notaserv.cd-modalidade         = in-modalidade
               notaserv.cd-contratante        = dc-contratante
               notaserv.cd-contratante-origem = dc-contratante-origem
               notaserv.nr-ter-adesao         = in-termo
               notaserv.cd-especie            = ch-especie
               notaserv.aa-referencia         = in-ano
               notaserv.mm-referencia         = in-mes
               notaserv.nr-sequencia          = in-sequencia-nota
               notaserv.ep-codigo             = parafatu.ep-codigo
               notaserv.cod-estabel           = parafatu.cod-estabel
               notaserv.dt-emissao            = today
               notaserv.dt-vencimento         = dt-vencimento
               notaserv.mo-codigo             = 0
               notaserv.vl-total              = 0
               notaserv.nr-fatura             = in-numero-fatura
               notaserv.lg-contabilizada      = no
               notaserv.cd-userid             = v_cod_usuar_corren
               notaserv.dt-atualizacao        = today
               notaserv.date-1                = today
               .            
            
        create fatura.
        assign fatura.cd-contratante            = dc-contratante
               fatura.nr-fatura                 = in-numero-fatura
               fatura.aa-referencia             = in-ano
               fatura.mm-referencia             = in-mes
               fatura.ep-codigo                 = parafatu.ep-codigo
               fatura.cod-estabel               = parafatu.cod-estabel
               fatura.cd-modalidade             = in-modalidade
               fatura.cd-especie                = ch-especie
               fatura.ds-mensagem               = 'Fatura gerada automaticamente pela rotina de migraá∆o de valores de reajuste entre contratos'
               fatura.portador                  = in-portador
               fatura.modalidade                = in-modalidade-cob
               fatura.ct-codigo                 = parafatu.ct-codigo
               fatura.sc-codigo                 = parafatu.sc-codigo
               fatura.nr-titulo-acr             = ""
               fatura.parcela                   = 0
               fatura.dt-emissao                = today
               fatura.dt-vencimento             = dt-vencimento
               fatura.cd-tipo-vencimento        = 0
               fatura.cd-sit-fatu               = estrsitu.cd-sit-inicial
               fatura.mo-codigo                 = 0
               fatura.in-tipo-fatura            = 3
               fatura.cd-userid                 = v_cod_usuar_corren
               fatura.dt-atualizacao            = today
               fatura.date-3                    = today
               fatura.nr-ter-adesao-estatistica = 0
               fatura.dec-1                     = 0
               fatura.dec-2                     = 0
               fatura.log-1                     = no
               fatura.int-4                     = 0
               fatura.int-10                    = 0
               .       

        create fatueven.
        assign fatueven.cd-modalidade           = notaserv.cd-modalidade
               fatueven.cd-contratante          = notaserv.cd-contratante
               fatueven.cd-contratante-origem   = notaserv.cd-contratante-origem
               fatueven.nr-ter-adesao           = notaserv.nr-ter-adesao
               fatueven.aa-referencia           = notaserv.aa-referencia
               fatueven.mm-referencia           = notaserv.mm-referencia
               fatueven.nr-sequencia            = notaserv.nr-sequencia
               fatueven.cd-evento               = temp-assoc-usuario.in-evento
               fatueven.cd-tipo-cob             = 0
               fatueven.lg-cred-deb             = yes
               fatueven.lg-destacado            = evenfatu.lg-destacado
               fatueven.lg-modulo               = no
               fatueven.ct-codigo               = evencont.ct-codigo
               fatueven.sc-codigo               = evencont.sc-codigo
               fatueven.qt-evento-ref           = 0
               fatueven.vl-evento-ref           = 0
               fatueven.cd-userid               = v_cod_usuar_corren
               fatueven.cd-userid               = v_cod_usuar_corren
               fatueven.dt-atualizacao          = today
               .

        for each temp-assoc-usuario
           where temp-assoc-usuario.in-usuario-destino  = 0
        break by temp-assoc-usuario.in-evento:
            
            assign dc-valor-total   = dc-valor-total + temp-assoc-usuario.dc-valor-evento
                   in-total-eventos = in-total-eventos + temp-assoc-usuario.in-quantidade-evento
                   .
        end.

        create ftavulev.
        assign ftavulev.cd-modalidade   = in-modalidade
               ftavulev.cd-contratante  = dc-contratante
               ftavulev.aa-referencia   = in-ano
               ftavulev.mm-referencia   = in-mes
               ftavulev.nr-ter-adesao   = in-termo
               ftavulev.nr-sequencia    = in-sequencia-nota
               ftavulev.cd-evento       = temp-assoc-usuario.in-evento                   
               ftavulev.cd-contratante-origem
                                        = dc-contratante-origem
               ftavulev.ds-evento       = caps (temp-assoc-usuario.ch-nome)
               .

        assign fatueven.qt-evento       = in-total-eventos 
               fatueven.vl-evento       = dc-valor-total
               notaserv.vl-total        = dc-valor-total
               fatura.vl-total          = dc-valor-total
               .
               
        find first temp-assoc-usuario.               

        create reajuste-contrato-migracao-lote.
        assign reajuste-contrato-migracao-lote.in-id                    = next-value (seq-reajuste-contrato-migracao-l)
               reajuste-contrato-migracao-lote.in-modalidade-destino    = in-modalidade
               reajuste-contrato-migracao-lote.in-termo-destino         = in-termo
               reajuste-contrato-migracao-lote.dt-ocorrencia            = now
               reajuste-contrato-migracao-lote.ch-tipo-fatura           = TIPO_FATURA_AVULSA
               reajuste-contrato-migracao-lote.dt-emissao               = fatura.dt-emissao
               reajuste-contrato-migracao-lote.dt-vencimento            = fatura.dt-vencimento
               reajuste-contrato-migracao-lote.dc-contratante           = fatura.cd-contratante
               reajuste-contrato-migracao-lote.in-fatura                = fatura.nr-fatura
               reajuste-contrato-migracao-lote.dc-total                 = fatura.vl-total
               reajuste-contrato-migracao-lote.in-modalidade-origem     = temp-assoc-usuario.in-modalidade-origem
               reajuste-contrato-migracao-lote.in-termo-origem          = temp-assoc-usuario.in-termo-origem
               .                

        create temp-migracao-lote-gerado.
        assign temp-migracao-lote-gerado.in-id-lote = reajuste-contrato-migracao-lote.in-id.               
               
        create reajuste-contrato.
        assign reajuste-contrato.in-id                      = next-value (seq-reajuste-contrato)
               reajuste-contrato.in-modalidade              = temp-assoc-usuario.in-modalidade-origem
               reajuste-contrato.in-termo                   = temp-assoc-usuario.in-termo-origem
               reajuste-contrato.in-quantidade-parcelas     = 0            
               reajuste-contrato.lg-cancelado               = no
               reajuste-contrato.lg-gerado-eventos          = yes
               reajuste-contrato.dt-criacao                 = now
               reajuste-contrato.dc-valor-cobrado           = fatura.vl-total
               reajuste-contrato.ch-detalhamento            = substitute ("EVENTOS MIGRADOS DO CONTRATO &1/&2 PARA O CONTRATO &3/4",
                                                                          temp-assoc-usuario.in-modalidade-origem,
                                                                          temp-assoc-usuario.in-termo-origem,
                                                                          in-modalidade,
                                                                          in-termo)
               reajuste-contrato.ch-origem-historico        = ORIGEM_HISTORICO_MIGRAR_EVENTO
               .
               
        for each temp-assoc-usuario
           where temp-assoc-usuario.in-usuario-destino  = 0:
               
            create reajuste-contrato-migracao-item.
            assign reajuste-contrato-migracao-item.in-id                 = next-value (seq-reajuste-contrato-migracao-i)
		           reajuste-contrato-migracao-item.in-id-lote            = reajuste-contrato-migracao-lote.in-id
                   reajuste-contrato-migracao-item.ch-usuario            = v_cod_usuar_corren
                   reajuste-contrato-migracao-item.dt-ocorrencia         = now
                   reajuste-contrato-migracao-item.dc-valor-evento       = temp-assoc-usuario.dc-valor-evento
                   reajuste-contrato-migracao-item.in-quantidade-eventos = temp-assoc-usuario.in-quantidade-evento
                   reajuste-contrato-migracao-item.in-ano                = in-ano
                   reajuste-contrato-migracao-item.in-mes                = in-mes
                   reajuste-contrato-migracao-item.in-evento             = temp-assoc-usuario.in-evento
                   reajuste-contrato-migracao-item.in-faixa-etaria       = temp-assoc-usuario.in-faixa-etaria
                   reajuste-contrato-migracao-item.in-grau-parentesco    = temp-assoc-usuario.in-grau-parentesco
                   reajuste-contrato-migracao-item.in-modalidade-destino = in-modalidade
                   reajuste-contrato-migracao-item.in-termo-destino      = in-termo
                   reajuste-contrato-migracao-item.in-modalidade-origem  = temp-assoc-usuario.in-modalidade-origem
                   reajuste-contrato-migracao-item.in-termo-origem       = temp-assoc-usuario.in-termo-origem
                   reajuste-contrato-migracao-item.in-usuario-destino    = temp-assoc-usuario.in-usuario-destino
                   reajuste-contrato-migracao-item.in-usuario-origem     = temp-assoc-usuario.in-usuario-origem
                   reajuste-contrato-migracao-item.in-sequencia-nota     = in-sequencia-nota
                   reajuste-contrato-migracao-item.in-fatura             = in-numero-fatura
                   reajuste-contrato-migracao-item.dc-contratante        = dc-contratante
                   .             
        end.
                
               
    
    
                                        
    end.
             
    for each temp-assoc-usuario:
        
        publish EV_API_REAJUSTE_PLANO_MIGRAR_VALORES (input  substitute ("&1/&2 - Marcando eventos para o benefici†rio &3 - &4 - como utilizados",
                                                                         in-modalidade,
                                                                         in-termo,
                                                                         temp-assoc-usuario.in-usuario-destino,
                                                                         temp-assoc-usuario.ch-nome)).        
        for each temp-vinculo-evento-progto
           where temp-vinculo-evento-progto.rc-assoc-usuario    = recid (temp-assoc-usuario):
            
            for first event-progdo-bnfciar exclusive-lock
                where recid (event-progdo-bnfciar)  = temp-vinculo-evento-progto.rc-evento-progto:
                
                assign event-progdo-bnfciar.nr-sequencia = 999.
            end.
        end.
    end.
             
end procedure.

procedure criarTemporariaValorBenef private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-ano-ref              as   integer    no-undo.
    define input  parameter in-mes-ref              as   integer    no-undo.
    define input  parameter in-ano-fat              as   integer    no-undo.
    define input  parameter in-mes-fat              as   integer    no-undo.
        
    define variable in-idade-ref                    as   integer    no-undo.
    define variable in-idade-fat                    as   integer    no-undo.
    
        
    define buffer buf-notaserv for notaserv.
    define buffer buf-vlbenef for vlbenef.
    
    define variable in-ano-calc as integer no-undo.
    define variable in-mes-calc as integer no-undo.
    
                       
    find first usuario no-lock
         where usuario.cd-modalidade    = vlbenef.cd-modalidade
           and usuario.nr-ter-adesao    = vlbenef.nr-ter-adesao
           and usuario.cd-usuario       = vlbenef.cd-usuario
           .
               
    find first gra-par no-lock
         where gra-par.cd-grau-parentesco   = usuario.cd-grau-parentesco
         .                               
                    /*                                            
    create temp-valor-beneficiario.
    assign temp-valor-beneficiario.in-modalidade        = notaserv.cd-modalidade
           temp-valor-beneficiario.in-termo             = notaserv.nr-ter-adesao
           temp-valor-beneficiario.in-usuario           = vlbenef.cd-usuario
           temp-valor-beneficiario.in-ano               = in-ano-ref
           temp-valor-beneficiario.in-mes               = in-mes-ref
           temp-valor-beneficiario.dt-nascimento        = usuario.dt-nascimento
           temp-valor-beneficiario.ch-nome-usuario      = usuario.nm-usuario
           temp-valor-beneficiario.in-faixa-atual       = vlbenef.nr-faixa-etaria                           
           temp-valor-beneficiario.in-grau-parentesco   = usuario.cd-grau-parentesco
           temp-valor-beneficiario.dt-inclusao-plano    = usuario.dt-inclusao-plano 
           temp-valor-beneficiario.ch-grau-parentesto   = gra-par.ds-grau-parentesco
            
           temp-contrato.in-quantidade-vidas            = temp-contrato.in-quantidade-vidas + 1
    .                                 
*/ 
end procedure.

procedure criarEventosContratos:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input        parameter in-ano-fat        as   integer    no-undo.
    define input        parameter in-mes-fat        as   integer    no-undo.
    define input        parameter ch-competencia    as   character  no-undo.
    define input-output parameter table             for  temp-contrato.
    define input-output parameter table             for  temp-valor-beneficiario.
    define input-output parameter table             for  temp-valor-beneficiario-mes.
        
    define variable lo-parametro                    as   longchar   no-undo.
    define variable in-evento-pf                    as   integer    no-undo.    
    define variable in-evento-pj                    as   integer    no-undo.
    define variable in-mes                          as   integer    no-undo.
    define variable in-ano                          as   integer    no-undo.
    define variable in-quantidade-parcelas          as   integer    no-undo.
    define variable dc-valor-cobrado                as   decimal    no-undo.
    define variable lo-data-json                    as   longchar   no-undo.
    define variable ch-per-ini                      as   character  no-undo.
    define variable ch-per-fim                      as   character  no-undo.
    define variable ch-tipo-contrato-pessoa         as   character  no-undo.                
            
    do transaction on error undo, throw:
        
        if not valid-handle (hd-api-config)
        then run thealth/libs/api-mantem-parametros.p persistent set hd-api-config.
                
        run buscarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano", 
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE_PF,   
                                              output lo-parametro) no-error.
                                               
        if lo-parametro = ?
        or lo-parametro = ''
        then undo, throw new AppError('Evento para cobranáa de pessoa f°sica n∆o parametrizado.~nAcesse os parÉmetros do programa para registrar o evento').                                              
                                              
        assign in-evento-pf = integer (lo-parametro).        

        run buscarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano", 
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE_PJ,   
                                              output lo-parametro) no-error.
                                              
        if lo-parametro = ?
        or lo-parametro = ''
        then undo, throw new AppError('Evento para cobranáa de pessoa jur°dica n∆o parametrizado.~nAcesse os parÉmetros do programa para registrar o evento').                                              
                                              
        assign in-evento-pj = integer (lo-parametro).        
        
        for each temp-contrato
           where temp-contrato.lg-marcado                   = yes
             and temp-contrato.lg-possui-reajuste-ano-ref   = yes
             and temp-contrato.lg-eventos-gerados           = no:
                 
            log-manager:write-message (substitute ("&1/&2 -> lendo contrato", 
                                                   temp-contrato.in-modalidade,
                                                   temp-contrato.in-termo), "DEBUG") no-error.                 
            
            assign in-quantidade-parcelas   = 0
                   dc-valor-cobrado         = 0
                   ch-tipo-contrato-pessoa  = tipoContratoPessoa (temp-contrato.in-modalidade, temp-contrato.in-termo)
                   .
                
                   
            for each temp-valor-beneficiario
               where temp-valor-beneficiario.in-modalidade      = temp-contrato.in-modalidade
                 and temp-valor-beneficiario.in-termo           = temp-contrato.in-termo
                 and temp-valor-beneficiario.dc-valor-cobrar    > 0:
                     
                log-manager:write-message (substitute ("&1/&2/&3 -> lendo beneficiario",
                                                       temp-contrato.in-modalidade,
                                                       temp-contrato.in-termo,
                                                       temp-valor-beneficiario.in-usuario), "DEBUG") no-error.                     

                assign in-ano       = in-ano-fat
                       in-mes       = in-mes-fat
                       .
 
                for each temp-valor-beneficiario-mes 
                   where temp-valor-beneficiario-mes.in-modalidade      = temp-valor-beneficiario.in-modalidade  
                     and temp-valor-beneficiario-mes.in-termo           = temp-valor-beneficiario.in-termo
                     and temp-valor-beneficiario-mes.in-usuario         = temp-valor-beneficiario.in-usuario
                     and temp-valor-beneficiario-mes.dc-valor-parcela   > 0:
                         
                    assign in-quantidade-parcelas   = in-quantidade-parcelas + 1
                           dc-valor-cobrado         = dc-valor-cobrado + temp-valor-beneficiario-mes.dc-valor-parcela
                           .                         
                           
                                           
                         
                    run criarEventoProgramado (input  temp-valor-beneficiario-mes.in-modalidade,
                                               input  temp-valor-beneficiario-mes.in-termo,
                                               input  temp-valor-beneficiario-mes.in-usuario,
                                               input  in-ano, 
                                               input  in-mes,
                                               input  if ch-tipo-contrato-pessoa = 'PF'
                                                      then in-evento-pf
                                                      else in-evento-pj,
                                               input  temp-valor-beneficiario-mes.dc-valor-parcela,
                                               input  substitute ('Valor reajuste retroativo referente ao màs &1/&2',
                                                                  string (temp-valor-beneficiario-mes.in-mes, '99'),
                                                                  temp-valor-beneficiario-mes.in-ano))
                        .
        
                    assign in-mes   = in-mes + 1. 
                           
                    if in-mes > 12 
                    then do: 
                        
                        assign in-ano   = in-ano + 1
                               in-mes   = 1.
                    end.
               
                end.                     
            end.                                        
        
            log-manager:write-message (substitute ("&1/&2 -> registrando no historico a geraá∆o dos eventos",
                                                   temp-contrato.in-modalidade,
                                                   temp-contrato.in-termo), "DEBUG") no-error.
                                                   
            run gerarJson (output lo-data-json).
            
            
            for first temp-valor-beneficiario-mes
                where temp-valor-beneficiario-mes.in-modalidade = temp-contrato.in-modalidade               
                  and temp-valor-beneficiario-mes.in-termo      = temp-contrato.in-termo
                   by temp-valor-beneficiario-mes.in-ano
                   by temp-valor-beneficiario-mes.in-mes:
                       
                assign ch-per-ini   = substitute ("&1/&2",
                                                  string (temp-valor-beneficiario-mes.in-mes, '99'),
                                                  string (temp-valor-beneficiario-mes.in-ano, '9999')).
            end.                       

            for last temp-valor-beneficiario-mes
               where temp-valor-beneficiario-mes.in-modalidade  = temp-contrato.in-modalidade               
                 and temp-valor-beneficiario-mes.in-termo       = temp-contrato.in-termo
                  by temp-valor-beneficiario-mes.in-ano
                  by temp-valor-beneficiario-mes.in-mes:
                      
                assign ch-per-fim   = substitute ("&1/&2",
                                                  string (temp-valor-beneficiario-mes.in-mes, '99'),
                                                  string (temp-valor-beneficiario-mes.in-ano, '9999')).
            end.                       
 
            create reajuste-contrato.
            assign reajuste-contrato.in-id                  = next-value (seq-reajuste-contrato)
                   reajuste-contrato.in-modalidade          = temp-contrato.in-modalidade
                   reajuste-contrato.in-termo               = temp-contrato.in-termo
                   reajuste-contrato.ch-usuario             = v_cod_usuar_corren
                   reajuste-contrato.dt-criacao             = now
                   reajuste-contrato.in-quantidade-parcelas = in-quantidade-parcelas
                   reajuste-contrato.dc-valor-cobrado       = dc-valor-cobrado
                   reajuste-contrato.ch-detalhamento        = lo-data-json
                   reajuste-contrato.ch-periodo-reajuste    = temp-contrato.ch-ultimo-reajuste
                   reajuste-contrato.ch-origem-historico    = ORIGEM_HISTORICO_GERAR_EVENTO
                   reajuste-contrato.ch-periodo-inicial-cob = ch-per-ini
                   reajuste-contrato.ch-periodo-final-cob   = ch-per-fim
                   .
         
        end.                
        catch cs-erro as Progress.Lang.Error :
            
            log-manager:write-message (substitute ("&1", cs-erro:GetMessage(1)), "ERROR") no-error. 
            undo, throw cs-erro.                
        end catch.
    end.
    

end procedure.

procedure eliminarEventos:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter table           for  temp-contrato.

    define variable in-ano                  as   integer    no-undo.
    define variable in-mes                  as   integer    no-undo.
    define variable in-ano-fim              as   integer    no-undo.
    define variable in-mes-fim              as   integer    no-undo.
    define variable in-ano-ini              as   integer    no-undo.
    define variable in-mes-ini              as   integer    no-undo.
    define variable lo-parametro            as   longchar   no-undo.
    define variable in-evento-pf            as   integer    no-undo.
    define variable in-evento-pj            as   integer    no-undo.
    
    do transaction on error undo, throw:
        
        if not valid-handle (hd-api-config)
        then run thealth/libs/api-mantem-parametros.p persistent set hd-api-config.
                
        run buscarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano", 
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE_PF,   
                                              output lo-parametro) no-error.
                                              
        if lo-parametro = ?
        or lo-parametro = ''
        then undo, throw new AppError('Evento para cobranáa de pessoa f°sica n∆o parametrizado.~nAcesse os parÉmetros do programa para registrar o evento').                                              
                                              
        assign in-evento-pf = integer (lo-parametro).        

        run buscarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano", 
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE_PJ,   
                                              output lo-parametro) no-error.
                                              
        if lo-parametro = ?
        or lo-parametro = ''
        then undo, throw new AppError('Evento para cobranáa de pessoa jur°dica n∆o parametrizado.~nAcesse os parÉmetros do programa para registrar o evento').                                              
                                              
        assign in-evento-pj = integer (lo-parametro).                                            
            
        for each temp-contrato 
           where temp-contrato.lg-marcado:

            find first reajuste-contrato no-lock
                 where reajuste-contrato.in-modalidade          = temp-contrato.in-modalidade
                   and reajuste-contrato.in-termo               = temp-contrato.in-termo
                   and reajuste-contrato.ch-periodo-reajuste    = temp-contrato.ch-ultimo-reajuste
                   and reajuste-contrato.ch-origem-historico    = ORIGEM_HISTORICO_GERAR_EVENTO
                       no-error.
                   
            if not available reajuste-contrato
            then do:
                
                next.
            end.     
            
            assign in-ano-ini   = integer (substring (reajuste-contrato.ch-periodo-inicial-cob, 4))                         
                   in-mes-ini   = integer (substring (reajuste-contrato.ch-periodo-inicial-cob, 1, 2))
                   in-ano-fim   = integer (substring (reajuste-contrato.ch-periodo-final-cob, 4))                         
                   in-mes-fim   = integer (substring (reajuste-contrato.ch-periodo-final-cob, 1, 2))
                   in-ano       = in-ano-ini
                   in-mes       = in-mes-ini
                   .
                   
            find current reajuste-contrato exclusive-lock.
            
            assign reajuste-contrato.lg-cancelado   = yes.
            
            find first modalid no-lock
                 where modalid.cd-modalidade = reajuste-contrato.in-modalidade
                       .                   

            repeat:
                
                for each event-progdo-bnfciar exclusive-lock
                   where event-progdo-bnfciar.cd-modalidade = temp-contrato.in-modalidade
                     and event-progdo-bnfciar.nr-ter-adesao = temp-contrato.in-termo
                     and event-progdo-bnfciar.cd-usuario    > 0
                     and event-progdo-bnfciar.aa-referencia = in-ano
                     and event-progdo-bnfciar.mm-referencia = in-mes 
                     and event-progdo-bnfciar.cd-evento     = if modalid.in-tipo-pessoa = 'F'
                                                              then in-evento-pf
                                                              else in-evento-pj:
                         
                    publish EV_API_REAJUSTE_PLANO_ELIMINAR_EVENTO (input  event-progdo-bnfciar.cd-modalidade,       
                                                                   input  event-progdo-bnfciar.nr-ter-adesao,
                                                                   input  event-progdo-bnfciar.cd-usuario,
                                                                   input  event-progdo-bnfciar.cd-evento,
                                                                   input  event-progdo-bnfciar.vl-evento,
                                                                   input  substitute ("&1/&2",
                                                                                      string (event-progdo-bnfciar.mm-referencia, '99'),
                                                                                      string (event-progdo-bnfciar.aa-referencia, '9999')))
                            .
                            
                    delete event-progdo-bnfciar.                            
                end.
                                      
                assign in-mes   =  in-mes + 1.
                
                if in-mes > 12
                then 
                    assign in-ano = in-ano + 1
                           in-mes = 1.
                           
                if integer (string (in-ano, '9999') + string (in-mes, '99')) > integer (string (in-ano-fim, '9999') + string (in-mes-fim, '99'))
                then leave.                            
            end.        
            
            create reajuste-contrato.
            assign reajuste-contrato.in-id                  = next-value (seq-reajuste-contrato)
                   reajuste-contrato.in-modalidade          = temp-contrato.in-modalidade
                   reajuste-contrato.in-termo               = temp-contrato.in-termo
                   reajuste-contrato.ch-usuario             = v_cod_usuar_corren
                   reajuste-contrato.dt-criacao             = now
                   reajuste-contrato.ch-periodo-reajuste    = temp-contrato.ch-ultimo-reajuste
                   reajuste-contrato.ch-origem-historico    = ORIGEM_HISTORICO_REMOVER_EVENTO
                   reajuste-contrato.ch-periodo-inicial-cob = substitute ('&1/&2', 
                                                                          string (in-mes-ini, '99'),
                                                                          string (in-ano-ini, '9999'))
                   reajuste-contrato.ch-periodo-final-cob   = substitute ('&1/&2', 
                                                                          string (in-mes-fim, '99'),
                                                                          string (in-ano-fim, '9999'))
                   .
        end.
    end.

end procedure.

procedure gerarJson private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define output parameter lo-saida        as   longchar   no-undo.
    
    define variable jObj-contrato           as   JsonObject no-undo.
    define variable jObj-valor-benef        as   JsonObject no-undo.
    define variable jObj-valor-benef-mes    as   JsonObject no-undo.
    define variable jObj-valor-fat-mes      as   JsonObject no-undo.
    define variable jArr-valor-benef        as   JsonArray  no-undo.
    define variable jArr-valor-benef-mes    as   JsonArray  no-undo.    
    define variable jArr-valor-fat-mes      as   JsonArray  no-undo.

    assign jObj-contrato    = new JsonObject()
           jArr-valor-benef = new JsonArray().
           .
           
    buffer temp-contrato:serialize-row ('json', 'JsonObject', jObj-contrato, no).
    
    for each temp-valor-beneficiario 
       where temp-valor-beneficiario.in-modalidade  = temp-contrato.in-modalidade
         and temp-valor-beneficiario.in-termo       = temp-contrato.in-termo:
        
        assign jObj-valor-benef     = new JsonObject()
               jArr-valor-benef-mes = new JsonArray()
               jArr-valor-fat-mes   = new JsonArray()
               .
        
        buffer temp-valor-beneficiario:serialize-row ('json', 'JsonObject', jObj-valor-benef, no, ?, yes, yes ).
        
        for each temp-valor-faturado-mes
           where temp-valor-faturado-mes.in-modalidade  = temp-valor-beneficiario.in-modalidade
             and temp-valor-faturado-mes.in-termo       = temp-valor-beneficiario.in-termo
             and temp-valor-faturado-mes.in-usuario     = temp-valor-beneficiario.in-usuario:
                 
            assign jObj-valor-fat-mes   = new JsonObject().                 
            
            buffer temp-valor-faturado-mes:serialize-row ('json', 'JsonObject', jObj-valor-fat-mes, no, ?, yes, yes).
            jArr-valor-fat-mes:Add(jObj-valor-fat-mes).                    
                 
        end.                 
        
        
        for each temp-valor-beneficiario-mes
           where temp-valor-beneficiario-mes.in-modalidade  = temp-valor-beneficiario.in-modalidade
             and temp-valor-beneficiario-mes.in-termo       = temp-valor-beneficiario.in-termo
             and temp-valor-beneficiario-mes.in-usuario     = temp-valor-beneficiario.in-usuario:
            
            log-manager:write-message (substitute ("&1/&2/&3 vl-mes", 
                                                   temp-valor-beneficiario-mes.in-modalidade,
                                                   temp-valor-beneficiario-mes.in-termo,
                                                   temp-valor-beneficiario-mes.in-usuario), 
                                       "DEBUG") no-error.
            assign jObj-valor-benef-mes = new JsonObject().                 
            
            buffer temp-valor-beneficiario-mes:serialize-row ('json', 'JsonObject', jObj-valor-benef-mes, no, ?, yes, yes).
            jArr-valor-benef-mes:Add(jObj-valor-benef-mes).                                    
        end.
        
        jObj-valor-benef:Add("parcelas", jArr-valor-benef-mes).        
        jObj-valor-benef:Add("faturado", jArr-valor-fat-mes).
        jArr-valor-benef:Add(jObj-valor-benef).
    end.  
    
    jObj-contrato:Add("valores", jArr-valor-benef).          
    
    jObj-contrato:write (lo-saida, no).
    
             

end procedure.

procedure gerarPdfMigracaoContrato:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter table for temp-migracao-lote-gerado.
    define input  parameter ch-caminho-saida        as   character  no-undo.
    define input  parameter ch-arquivo              as   character  no-undo.
    
	
    create temp-migracao-lote-gerado.
    assign temp-migracao-lote-gerado.in-id-lote = reajuste-contrato-migracao-lote.in-id.       	
	
    do on error undo, return:
        
        CriarPdf (substitute ("&1/&2", ch-caminho-saida, ch-arquivo),
                  PDF_RETRATO,
                  //search("igp/logo_cliente.gif")
				  ?
				  ).
				  
        AdicionarColunaImpressao ('benefs', 'tcontrato', 'Contrato'  , 10, PDF_IMPRESSAO_AT).
        AdicionarColunaImpressao ('benefs', 'tnome'    , 'Nome'      , 40, PDF_IMPRESSAO_AT).
        AdicionarColunaImpressao ('benefs', 'tcarteira', 'Carteira'  , 120, PDF_IMPRESSAO_AT).
        AdicionarColunaImpressao ('benefs', 'tvalor'   , '     Valor', 150, PDF_IMPRESSAO_AT).			

        AdicionarColunaImpressao ('fatAvulsa', 'tContratante', 'Contratante', 10, PDF_IMPRESSAO_AT).
        AdicionarColunaImpressao ('fatAvulsa', 'tFatura'     , 'Fatura'     , 40, PDF_IMPRESSAO_AT).
        AdicionarColunaImpressao ('fatAvulsa', 'tVencimento' , 'Vencimento' , 120, PDF_IMPRESSAO_AT).
        AdicionarColunaImpressao ('fatAvulsa', 'tValor'      , '     Valor' , 150, PDF_IMPRESSAO_AT).					
				  
		for each temp-migracao-lote-gerado:
			for first reajuste-contrato-migracao-lote no-lock
                where reajuste-contrato-migracao-lote.in-id = temp-migracao-lote-gerado.in-id-lote: end.
				
			if not avail reajuste-contrato-migracao-lote
			then next.
			
			if reajuste-contrato-migracao-lote.ch-tipo-fatura = TIPO_FATURA_NORMAL
			then do:
					NovaPagina().
					ImprimeValorEmEnter("Detalhamento de beneficiarios que possuem valor de reajuste a pagar.", 10).
					NovaLinha().
					ImprimeHeaderRetrato('benefs').		

					for each reajuste-contrato-migracao-item no-lock
					   where reajuste-contrato-migracao-item.in-id-lote = reajuste-contrato-migracao-lote.in-id,
					   first usuario no-lock
					   where usuario.cd-modalidade                      = reajuste-contrato-migracao-item.in-modalidade-destino
						 and usuario.nr-ter-adesao                      = reajuste-contrato-migracao-item.in-termo-destino
						 and usuario.cd-usuario                         = reajuste-contrato-migracao-item.in-usuario-destino:
											
						for last car-ide no-lock
					   use-index car-ide1
						   where car-ide.cd-unimed  = usuario.cd-unimed
							 and car-ide.cd-modalidade  = usuario.cd-modalidade
							 and car-ide.nr-ter-adesao  = usuario.nr-ter-adesao
							 and car-ide.cd-usuario     = usuario.cd-usuario:
						end. 
						
						ImprimeValor ('benefs', 'tcontrato', substitute ("&1/&2/&3", usuario.cd-modalidade, usuario.nr-ter-adesao, usuario.cd-usuario)).
						ImprimeValor ('benefs', 'tnome', usuario.nm-usuario).
						ImprimeValor ('benefs', 'tcarteira', if available car-ide then string (car-ide.cd-carteira-inteira) else "").
						ImprimeValor ('benefs', 'tvalor', string (reajuste-contrato-migracao-item.dc-valor-evento, 'R$ >>>,>>9.99')).
						NovaLinha().
					end.
					next.
				 end.
				 
				NovaPagina().
				ImprimeValorEmEnter("Detalhamento da fatura avulsa.", 10).
				NovaLinha().
				ImprimeHeaderRetrato('fatAvulsa').	

				ImprimeValor ('fatAvulsa', 'tContratante', string(reajuste-contrato-migracao-lote.dc-contratante)).
				ImprimeValor ('fatAvulsa', 'tFatura'     , string(reajuste-contrato-migracao-lote.in-fatura)).
				ImprimeValor ('fatAvulsa', 'tVencimento' , string(reajuste-contrato-migracao-lote.dt-vencimento, "99/99/9999")).
				ImprimeValor ('fatAvulsa', 'tValor'      , string(reajuste-contrato-migracao-lote.dc-total, 'R$ >>>,>>9.99')).
				NovaLinha().				
		end.
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao gerar o pdf.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao gerar o pdf.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
		
		finally:
			FecharPdf().
		end.
    end.    
    
end procedure.

procedure limpaTemporaria private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade       as   integer    no-undo.
    define input  parameter in-termo            as   integer    no-undo.

    // limpando temp tables para recalcular, caso reprocessado
    if can-find (first temp-valor-beneficiario
                 where temp-valor-beneficiario.in-modalidade    = in-modalidade
                   and temp-valor-beneficiario.in-termo         = in-termo)
    then do:
        
        for each temp-valor-beneficiario
           where temp-valor-beneficiario.in-modalidade    = in-modalidade
             and temp-valor-beneficiario.in-termo         = in-termo:
                 
            delete temp-valor-beneficiario.                                
        end.          
        
        for each temp-valor-beneficiario-mes
           where temp-valor-beneficiario-mes.in-modalidade  = in-modalidade
             and temp-valor-beneficiario-mes.in-termo       = in-termo:
        
            delete temp-valor-beneficiario-mes.         
        end. 
        
        for each temp-valor-faturado-mes
           where temp-valor-faturado-mes.in-modalidade  = in-modalidade
             and temp-valor-faturado-mes.in-termo       = in-termo:
            
            delete temp-valor-faturado-mes.
        end.       
    end.

end procedure.

procedure migrarValoresEntreContratos:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade-origem    as   integer           no-undo.
    define input  parameter in-termo-origem         as   integer           no-undo.
    define input  parameter in-modalidade-destino   as   integer           no-undo.
    define input  parameter in-termo-destino        as   integer           no-undo.
    define input  parameter in-mes                  as   integer           no-undo.
    define input  parameter in-ano                  as   integer           no-undo.
	define output parameter lg-possui-valor-migra   as   logical init true no-undo.
    define output parameter table                   for  temp-migracao-lote-gerado.              
    
    define buffer buf-propost                       for  propost.
    define buffer buf-usuario                       for  usuario.
        
    define variable dt-corte                        as   date       no-undo.
    define variable lo-parametro                    as   longchar   no-undo.
    define variable in-evento-filtro                as   integer    no-undo.
    define variable ch-tipo-contrato-pessoa         as   character  no-undo.
    
    empty temp-table temp-assoc-usuario.
    empty temp-table temp-vinculo-evento-progto.
    empty temp-table temp-evento-conta.
    empty temp-table temp-migracao-lote-gerado.
    
    do on error undo, throw:
        
        find first propost no-lock
             where propost.cd-modalidade    = in-modalidade-origem
               and propost.nr-ter-adesao    = in-termo-origem
                   no-error.
                   
        if not available propost
        then do:
            
            undo, throw new AppError (substitute ("N∆o foi encontrada a proposta de origem: &1/&2", in-modalidade-origem, in-termo-origem), 1).
        end.               
        
        publish EV_API_REAJUSTE_PLANO_MIGRAR_VALORES (input  substitute ("&1/&2 - Iniciando programa", propost.cd-modalidade, propost.nr-ter-adesao)).
        
        find first buf-propost no-lock
             where buf-propost.cd-modalidade    = in-modalidade-destino
               and buf-propost.nr-ter-adesao    = in-termo-destino
                   no-error.
                   
        if not available buf-propost
        then do:
            
            undo, throw new AppError (substitute ("N∆o foi encontrada a proposta de destino: &1/&2", in-modalidade-destino, in-termo-destino), 1).                   
        end.
        
        assign ch-tipo-contrato-pessoa = tipoContratoPessoa (in-modalidade-origem, in-termo-origem).

        if not valid-handle (hd-api-config)
        then run thealth/libs/api-mantem-parametros.p persistent set hd-api-config.
        
        run buscarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano", 
                                              input  ?,
                                              input  if ch-tipo-contrato-pessoa = "PF" 
                                                     then PARAM_EVENTO_REAJUSTE_PF
                                                     else PARAM_EVENTO_REAJUSTE_PJ,   
                                              output lo-parametro) no-error.
                                               
        if lo-parametro = ?
        or lo-parametro = ''
        then undo, throw new AppError('Evento para cobranáa n∆o parametrizado.~nAcesse os parÉmetros do programa para registrar o evento').                                              
                                              
        assign in-evento-filtro = integer (lo-parametro).        
        
        run apurarValoresMigracaoContrato (input  in-modalidade-destino,
                                           input  in-termo-destino,
                                           input  in-evento-filtro,
                                           input  in-ano, 
                                           input  in-mes).
        
        find first temp-assoc-usuario    
             where temp-assoc-usuario.dc-valor-evento > 0
                   no-error.
                    
        if not available temp-assoc-usuario
        then do:
               log-manager:write-message (substitute ("thealth -> nenhum beneficiario tem valor a transferir para o novo contrato, nada a fazer"), "INFO") no-error.
               lg-possui-valor-migra = false.
               return.            
             end.
        
        // remove valores zerado, para n∆o gerar sugeira e ter que filtrar em cada query
        for each temp-assoc-usuario
           where temp-assoc-usuario.dc-valor-evento = 0:
            
            delete temp-assoc-usuario.
        end.
        
        //temp-table temp-assoc-usuario:write-json ("file", "c:/temp/dump.json", yes).        
        run criarNota (input  in-modalidade-destino,
                       input  in-termo-destino,
                       input  in-ano,
                       input  in-mes).
    end.
    
end procedure.


procedure apurarValoresMigracaoContrato private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade-destino   as   integer    no-undo.
    define input  parameter in-termo-destino        as   integer    no-undo.
    define input  parameter in-evento-filtro        as   integer    no-undo.
    define input  parameter in-ano                  as   integer    no-undo.
    define input  parameter in-mes                  as   integer    no-undo.
    
    define buffer buf-usuario                       for  usuario.
    
    define variable dt-corte                        as   date       no-undo.
    
    dt-corte = add-interval (date (in-mes, 1, in-ano), -1, 'days').
    
    for each usuario no-lock
          of propost,
       first ter-ade no-lock
          of propost:

        log-manager:write-message (substitute ("thealth -> criando registro na temp para o beneficiario: &1", usuario.cd-usuario), "DEBUG") no-error.
        
        for last vlbenef no-lock
       use-index vlbenef1
           where vlbenef.cd-modalidade          = propost.cd-modalidade
             and vlbenef.cd-contratante         = propost.cd-contratante
             and vlbenef.cd-contratante-origem  = propost.cd-contrat-origem
             and vlbenef.nr-ter-adesao          = propost.nr-ter-adesao
             and vlbenef.aa-referencia          = ter-ade.aa-ult-fat
             and vlbenef.mm-referencia          = ter-ade.mm-ult-fat
             and vlbenef.cd-usuario             = usuario.cd-usuario
                 .
        end.
        
        if not available vlbenef
        then do:
            
            for last vlbenef no-lock
           use-index vlbenef1
               where vlbenef.cd-modalidade          = propost.cd-modalidade
                 and vlbenef.cd-contratante         = propost.cd-contratante
                 and vlbenef.cd-contratante-origem  = propost.cd-contrat-origem
                 and vlbenef.nr-ter-adesao          = propost.nr-ter-adesao
                 and vlbenef.cd-usuario             = usuario.cd-usuario
                  by vlbenef.aa-referencia
                  by vlbenef.mm-referencia
                     .
            end.
        end.
        
        if not available vlbenef
        then next.
        
        publish EV_API_REAJUSTE_PLANO_MIGRAR_VALORES (input  substitute ("&1/&2 - Lendo beneficiario &3 - &4",
                                                                         usuario.cd-modalidade,
                                                                         usuario.nr-ter-adesao,
                                                                         usuario.cd-usuario,
                                                                         usuario.nm-usuario)).
        
        // verificar, pois se o usuario n∆o possuir vlbenef (por alguma raz∆o), vai gerar erro neste ponto.
        // talvez tenha que criar uma rotina que calcula a faixa do benef
        create temp-assoc-usuario.
        assign temp-assoc-usuario.in-modalidade-origem  = usuario.cd-modalidade        
               temp-assoc-usuario.in-termo-origem       = usuario.nr-ter-adesao
               temp-assoc-usuario.in-usuario-origem     = usuario.cd-usuario               
               temp-assoc-usuario.ch-cpf                = usuario.cd-cpf
               temp-assoc-usuario.ch-nome               = usuario.nm-usuario
               temp-assoc-usuario.dt-nascimento         = usuario.dt-nascimento
               temp-assoc-usuario.in-evento             = in-evento-filtro
               temp-assoc-usuario.in-grau-parentesco    = usuario.cd-grau-parentesco
               temp-assoc-usuario.in-faixa-etaria       = vlbenef.nr-faixa-etaria
               .
        
        log-manager:write-message (substitute ("thealth -> buscando beneficiario &1 no contrato novo", usuario.cd-usuario), "DEBUG") no-error.
        
        find first buf-usuario
             where buf-usuario.cd-modalidade    = in-modalidade-destino
               and buf-usuario.nr-ter-adesao    = in-termo-destino
               and buf-usuario.cd-cpf           = usuario.cd-cpf
                   no-error.
                   
        if not available buf-usuario 
        then do:
            
            log-manager:write-message (substitute ("thealth -> beneficiario &1 nao encontrado no contrato novo", usuario.cd-usuario), "WARN") no-error.
            next.
        end.                
        
        assign temp-assoc-usuario.in-usuario-destino    = buf-usuario.cd-usuario.                      

        for each event-progdo-bnfciar no-lock
       use-index evntprge-id
           where event-progdo-bnfciar.cd-modalidade     = usuario.cd-modalidade
             and event-progdo-bnfciar.nr-ter-adesao     = usuario.nr-ter-adesao
             and event-progdo-bnfciar.cd-usuario        = usuario.cd-usuario
             and event-progdo-bnfciar.nr-sequencia      = 0:
                 
            if event-progdo-bnfciar.cd-evento  <> in-evento-filtro
            then do:
                
                log-manager:write-message (substitute ("thealth -> encontrado evento &1, desconsiderando pois n∆o Ç o evento parametrizado", in-evento-filtro), "DEBUG") no-error.                    
                next.
            end.
            
            if (    event-progdo-bnfciar.aa-referencia  = in-ano
                and event-progdo-bnfciar.mm-referencia  < in-mes)
            or (    event-progdo-bnfciar.aa-referencia  < in-ano)
            then do:
                
                log-manager:write-message (substitute ("thealth -> desconsiderando evento &1, pois Ç de per°odo anterior (&2/&3)",
                                                       event-progdo-bnfciar.cd-usuario,
                                                       event-progdo-bnfciar.mm-referencia,
                                                       event-progdo-bnfciar.aa-referencia), 
                                           "DEBUG") no-error.
            end.

            log-manager:write-message (substitute ("thealth -> encontrado evento programado para beneficiario &1, competencia &2/&3, valor &4 ainda nao processado",
                                                   event-progdo-bnfciar.cd-usuario,
                                                   string (event-progdo-bnfciar.mm-referencia, "99"),
                                                   string (event-progdo-bnfciar.aa-referencia, "9999"),
                                                   event-progdo-bnfciar.vl-evento), 
                                       "DEBUG") no-error.                
            
            
            log-manager:write-message (substitute ("thealth -> adicionado valor &1 aos eventos do beneficiario &2",
                                                   event-progdo-bnfciar.vl-evento,
                                                   event-progdo-bnfciar.cd-usuario), 
                                       "DEBUG") no-error.
            assign temp-assoc-usuario.in-quantidade-evento  = temp-assoc-usuario.in-quantidade-evento + 1
                   temp-assoc-usuario.dc-valor-evento       = temp-assoc-usuario.dc-valor-evento + event-progdo-bnfciar.vl-evento
                   .
                   
            create temp-vinculo-evento-progto.
            assign temp-vinculo-evento-progto.rc-assoc-usuario  = recid (temp-assoc-usuario)
                   temp-vinculo-evento-progto.rc-evento-progto  = recid (event-progdo-bnfciar)
                   .                                                
        end.
        
        publish EV_API_REAJUSTE_PLANO_MIGRAR_VALORES (input  substitute ("&1/&2 - Lendo beneficiario &3 - &4 - Valor devido: R$ &5",
                                                                         usuario.cd-modalidade,
                                                                         usuario.nr-ter-adesao,
                                                                         usuario.cd-usuario,
                                                                         usuario.nm-usuario,
                                                                         string (temp-assoc-usuario.dc-valor-evento, ">>>>>9.99" ))).

        log-manager:write-message (substitute ("thealth -> valor final do beneficiario &1: &2, &3 eventos",
                                               temp-assoc-usuario.in-usuario-origem,
                                               temp-assoc-usuario.dc-valor-evento,
                                               temp-assoc-usuario.in-quantidade-evento), 
                                   "DEBUG") no-error.
    end.

end procedure.

procedure simularFaturamento private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade       as   integer        no-undo.
    define input  parameter in-termo            as   integer        no-undo.
    define input  parameter in-ano-ref          as   integer        no-undo.
    define input  parameter in-mes-ref          as   integer        no-undo.
    
    define variable hd-api                      as   handle         no-undo. 
        
    run thealth/reajuste-planos-saude/api/simular-faturamento.p persistent set hd-api.
    
    empty temp-table temp-simular-benef.
    empty temp-table temp-faturamento-contrato.    
    empty temp-table temp-faturamento-beneficiario.
        
    run simularFaturamentoTermo in hd-api (input  in-modalidade,
                                           input  in-termo,
                                           input  in-ano-ref,
                                           input  in-mes-ref,
                                           input  table temp-simular-benef,
                                           output table temp-faturamento-contrato,
                                           output table temp-faturamento-beneficiario).

    delete object hd-api.
  
         
    


end procedure.



/* ************************  Function Implementations ***************** */

function buscarDataVencimento returns date private
    (ch-empresa         as   character,
     ch-estabelecimento as   character,
     in-tipo-vencimento as   integer,
     in-vencimento      as   integer,
     in-ano             as   integer,
     in-mes             as   integer):
/*------------------------------------------------------------------------------
 Purpose: busca a data de vencimento de um contrato com base na parametrizaá∆o do produto
 Notes:
------------------------------------------------------------------------------*/

    define variable dt-calculada        as   date       no-undo. 
    define variable ch-mensagem         as   character  no-undo.
    define variable lg-erro             as   logical    no-undo.   
 
    for first tipovenc no-lock
        where tipovenc.cd-tipo-vencimento = in-tipo-vencimento.
    end.

    if not available tipovenc
    then do:
        
        undo, throw new AppError (substitute ("tipo do vencimento &1 n∆o encontrado na tabela tipovenc", in-tipo-vencimento), 1).         
    end.
   
    run rtp/rtdtvenc.p (input        ch-empresa,
                        input        ch-estabelecimento,
                        input        in-vencimento,
                        input        date (in-mes, 1, in-ano),
                        input-output dt-calculada,
                        input        in-mes,
                        input        in-ano,
                        input        in-tipo-vencimento,
                        output       lg-erro,
                        output       ch-mensagem)
        .
    
    if lg-erro
    then do:
        
        undo, throw new AppError (substitute ("erro ao calcular data de vencimento: &1", ch-mensagem)).
    end.
            
    return dt-calculada.        
end function.

function buscarNumeroFatura returns integer private
    (in-modalidade          as   integer,
     dc-contratante         as   decimal):
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable in-numero-fatura        as   integer    no-undo.    

    run rtp/rtnrfat.p (input  in-modalidade,
                       input  dc-contratante,
                       output in-numero-fatura) no-error.
                       
    if error-status:error
    then do:
        
        undo, throw new AppError (substitute ("falha ao buscar numero da fatura: &1", error-status:get-message (1)), 1).
    end.                       

    return in-numero-fatura.
end function.

function buscarSequenciaNota returns integer 
    (in-modalidade          as   integer,
     in-termo               as   integer,
     dc-contratante         as   decimal,
     dc-contratante-origem  as   decimal,
     in-ano                 as   integer,
     in-mes                 as   integer):
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/    
    define variable in-sequencia            as   integer    no-undo.
    
    run rtp/rt-sequencia-nota.p (input        "CRIACAO",
                                 input        "FP0511S",
                                 input        in-modalidade,   
                                 input        dc-contratante,        
                                 input        dc-contratante-origem,    
                                 input        in-termo,   
                                 input        in-ano,              
                                 input        in-mes,
                                 input        yes,              
                                 input-output in-sequencia) no-error.
                                 
    if error-status:error
    then do:
        
        undo, throw new AppError (substitute ("falha ao buscar a sequencia da nota: &1", in-sequencia), 1).
    end.                                 

    return in-sequencia.
                                      
end function.

function numeroParcelas returns integer private
    (in-modalidade  as   integer,
     in-termo       as   integer  ):
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable in-numero-parcela               as   integer    no-undo.    

    if  temp-contrato.in-quantidade-parcelas-usuario    > 0
    and temp-contrato.in-quantidade-parcelas-usuario   <> temp-contrato.in-quantidade-parcelas
    then do:
        
        assign in-numero-parcela    = temp-contrato.in-quantidade-parcelas-usuario.   
    end. 
    else do:
        
        assign in-numero-parcela    = temp-contrato.in-quantidade-parcelas.
    end.
    
    log-manager:write-message (substitute ("&1/&2 -> quantidade parcelas a considerar: &3, calculado pelo sistema: &4, digitado pelo usuario: &5",
                                           in-modalidade,
                                           in-termo,
                                           in-numero-parcela,
                                           temp-contrato.in-quantidade-parcelas,
                                           temp-contrato.in-quantidade-parcelas-usuario), 
                               "DEBUG") no-error.
    return in-numero-parcela.
        
end function.

function removerSequenciaNota returns logical private
    (dc-contratante         as   decimal,
     in-ano                 as   integer,
     in-mes                 as   integer):
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/    

    run RemoveSequenciaNota  (input  dc-contratante,
                              input  in-ano,
                              input  in-mes) no-error.
    return true.
end function.

