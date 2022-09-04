
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

using Progress.Lang.AppError from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using Progress.Json.ObjectModel.JsonArray from propath.
using Progress.Json.ObjectModel.ObjectModelParser from propath.

/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */


function numeroParcelas returns integer private
    (in-modalidade  as   integer,
     in-termo       as   integer) forward.

{thealth/reajuste-planos-saude/api/api-reajuste-plano.i}
{thealth/reajuste-planos-saude/api/simular-faturamento.i}
{thealth/reajuste-planos-saude/interface/reajuste-plano.i}
{thealth/reajuste-planos-saude/utils/reajuste-plano-dominios.i}
{thealth/libs/dates.i}
 
define variable hd-api-config               as   handle     no-undo.
define variable lg-cancelar-pesquisa        as   logical    no-undo.

define new global shared variable v_cod_usuar_corren as character
                          format "x(12)":U label "Usu rio Corrente"
                                        column-label "Usu rio Corrente" no-undo.
/* ***************************  Main Block  *************************** */



/* **********************  Internal Procedures  *********************** */

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
          of propost                            ~n,
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
           
    // se for da estrutura de faturamento antecipado, diminui uma parcela da gera‡Æo.           
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
        then undo, throw new AppError('Evento para cobran‡a de pessoa f¡sica nÆo parametrizado.~nAcesse os parƒmetros do programa para registrar o evento').                                              
                                              
        assign in-evento-pf = integer (lo-parametro).        

        run buscarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano", 
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE_PJ,   
                                              output lo-parametro) no-error.
                                              
        if lo-parametro = ?
        or lo-parametro = ''
        then undo, throw new AppError('Evento para cobran‡a de pessoa jur¡dica nÆo parametrizado.~nAcesse os parƒmetros do programa para registrar o evento').                                              
                                              
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
                                               input  substitute ('Valor reajuste retroativo referente ao mˆs &1/&2',
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
        
            log-manager:write-message (substitute ("&1/&2 -> registrando no historico a gera‡Æo dos eventos",
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
        then undo, throw new AppError('Evento para cobran‡a de pessoa f¡sica nÆo parametrizado.~nAcesse os parƒmetros do programa para registrar o evento').                                              
                                              
        assign in-evento-pf = integer (lo-parametro).        

        run buscarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano", 
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE_PJ,   
                                              output lo-parametro) no-error.
                                              
        if lo-parametro = ?
        or lo-parametro = ''
        then undo, throw new AppError('Evento para cobran‡a de pessoa jur¡dica nÆo parametrizado.~nAcesse os parƒmetros do programa para registrar o evento').                                              
                                              
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

