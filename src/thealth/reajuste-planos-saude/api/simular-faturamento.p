/*------------------------------------------------------------------------
    File        : simular-faturamento.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : fabricio.casali@thealth.com.br
    Created     : Thu Oct 05 12:54:33 BRT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
block-level on error undo, throw.

{thealth/reajuste-planos-saude/api/simular-faturamento.i}
{fpp/fp0512l.i "new"}
{hdp/hdvrcab0.i}
{cpc/cpc-fp0711a.i}

define new        shared variable lg-avisa-erro-aux                   as log                                no-undo.


define new shared variable  aa-referencia-aux        like notaserv.aa-referencia.
define new shared variable  mm-referencia-aux        like notaserv.mm-referencia.

/* PORQUICES DO PRODUTO */
define new shared variable   dt-emissao-aux          as   date format "99/99/9999".
define new shared variable   dt-vencimento-aux       as   date format "99/99/9999".
define new shared variable   dt-perref-aux           as   integer format "9".
define new shared variable   cd-modalidade-aux       like notaserv.cd-modalidade.
define new shared variable   nr-ter-ade-aux          like notaserv.nr-ter-adesao.
define new shared variable   lg-tem-param            as log.
define new shared variable   lg-calcula-ir-aux       as log format "Sim/Nao" no-undo.
define new shared temp-table w-fatmen       no-undo  like notaserv.
define new shared temp-table w-fateve       no-undo  like fatueven.
define new shared temp-table w-fatgrau      no-undo  like fatgrmod.
define new shared temp-table w-fatgrunp     no-undo  like fatgrunp. 
define new shared temp-table w-fatgrun      no-undo  like fatgrunp.
define new shared variable aa-ref-aux                  as integer format "9999"               .         /* aPAGAR */
define new shared variable mm-ref-aux                  as integer format "99"                 .         /* aPAGAR */


define new shared temp-table       wk1
{fpp/fp0711a.i2}

{fpp/fp0711a.i11 "new shared"}

{fpp/fp0711a.i7}
lg-batch-aux    = yes. 

define temp-table tmp-modulos-opc
    field selec         as character format "x(1)"
    field cd-modulo     like mod-cob.cd-modulo
    field ds-modulo     like mod-cob.ds-modulo.

define new shared temp-table tmp-modulos-selec    
    field cd-modulo     like mod-cob.cd-modulo
    field ds-modulo     like mod-cob.ds-modulo
    field cd-grau-par   like usuario.cd-grau-parentesco
    field nr-idade      as integer format "999"
    field pad-cob       like usuario.cd-padrao-cobertura
    field cd-modalidade like propost.cd-modalidade
    field nr-proposta   like propost.nr-proposta.
/* ********************  Preprocessor Definitions  ******************** */
 

/* ***************************  Main Block  *************************** */



/* **********************  Internal Procedures  *********************** */
procedure simularFaturamentoTermo:
    define input  parameter in-modalidade           as   integer        no-undo.
    define input  parameter in-termo                as   integer        no-undo.
    define input  parameter in-ano                  as   integer        no-undo.
    define input  parameter in-mes                  as   integer        no-undo.
    define input  parameter table                   for  temp-simular-benef.
    define output parameter table                   for  temp-faturamento-contrato.
    define output parameter table                   for  temp-faturamento-beneficiario.
    
    log-manager:write-message (substitute ('iniciando simulacao do faturamento. buscando dados do termo &1/&2',
                          in-modalidade,
                          in-termo), "DEBUG") no-error.

    find first ter-ade no-lock
         where ter-ade.cd-modalidade        = in-modalidade
           and ter-ade.nr-ter-adesao        = in-termo.

    find first propost no-lock
         where propost.cd-modalidade        = ter-ade.cd-modalidade
           and propost.nr-ter-adesao        = ter-ade.nr-ter-adesao.

    empty temp-table w-fatmen.
    empty temp-table w-fateve.
    empty temp-table w-fatgrau.
    empty temp-table w-fatgrunp.
    empty temp-table w-fatgrun.
    empty temp-table w-fatsemreaj. 
    empty temp-table w-vlbenef.
    empty temp-table wk-alerta.
    empty temp-table wk-evento-imposto.
    empty temp-table wk1.
    empty temp-table tmp-reaj-retroat-parc.
    
    for each wk-usuario-sim:
        delete wk-usuario-sim.
    end.

    log-manager:write-message (substitute ('chamando simulacao do faturamento para o termo &1/&2, mes/ano &3/&4',
                          in-modalidade,
                          in-termo,
                          string (in-mes, '99'),
                          string (in-ano, '9999')), "DEBUG") no-error.

    assign aa-referencia-aux    = in-ano
           mm-referencia-aux    = in-mes
           dt-emissao-aux       = today
           dt-vencimento-aux    = date (in-mes, 1, in-ano)
           cd-modalidade-aux    = in-modalidade
           nr-ter-ade-aux       = in-termo
           lg-calcula-ir-aux    = no
           lg-batch-aux         = yes.
           
    for each temp-simular-benef:

       create wk-usuario-sim.
       assign wk-usuario-sim.cd-usuario          = temp-simular-benef.in-usuario
              wk-usuario-sim.cd-grau-parentesco  = temp-simular-benef.in-grau-parentesco
              wk-usuario-sim.nr-idade            = temp-simular-benef.in-idade
              wk-usuario-sim.dt-inclusao-plano   = temp-simular-benef.dt-inclusao
              wk-usuario-sim.dt-nascimento       = date (month (temp-simular-benef.dt-inclusao), 1, year (temp-simular-benef.dt-inclusao) - temp-simular-benef.in-idade) - 1
              wk-usuario-sim.dt-exclusao-plano   = ?
              wk-usuario-sim.cd-sit-usuario      = 05
              wk-usuario-sim.lg-insc-fatura      = no.        
        
    end.           
           
    run fpp/fp0512l.p no-error.
    if error-status:error
    then do:
        
        log-manager:write-message (substitute ('erro na chamada do programa de simula‡Æo do faturamento: &1 - &2',
                                               error-status:get-number (1),
                                               error-status:get-message (1)), "DEBUG") no-error.
        return.
    end. 
    
    find first w-fatmen.
    if not available w-fatmen
    then do:
        
        log-manager:write-message (substitute ('nao houve erro na chamada da simulacao do faturamento, porem nao foram gerados dados sobre a nota de servico'), "DEBUG") no-error.
        return.
    end.

    create temp-faturamento-contrato.
    assign temp-faturamento-contrato.in-ano         = in-ano
           temp-faturamento-contrato.in-mes         = in-mes
           temp-faturamento-contrato.in-modalidade  = in-modalidade
           temp-faturamento-contrato.in-termo       = in-termo 
           temp-faturamento-contrato.dc-valor-total = w-fatmen.vl-total.

    for each w-vlbenef,
       first evenfatu no-lock
       where evenfatu.in-entidade       = 'FT'
         and evenfatu.cd-evento         = w-vlbenef.cd-evento:

        create temp-faturamento-beneficiario.
        assign temp-faturamento-beneficiario.in-modalidade      = in-modalidade
               temp-faturamento-beneficiario.in-termo           = in-termo
               temp-faturamento-beneficiario.in-mes             = in-mes
               temp-faturamento-beneficiario.in-ano             = in-ano
               temp-faturamento-beneficiario.dc-valor           = w-vlbenef.vl-usuario
               temp-faturamento-beneficiario.in-evento          = w-vlbenef.cd-evento
               temp-faturamento-beneficiario.ch-classe-evento   = evenfatu.in-classe-evento
               temp-faturamento-beneficiario.ch-tipo-movimento  = if evenfatu.lg-cred-deb   
                                                                  then 'CREDITO'
                                                                  else 'DEBITO'
               temp-faturamento-beneficiario.in-usuario         = w-vlbenef.cd-usuario
               temp-faturamento-beneficiario.in-grau-par        = w-vlbenef.cd-grau-parentesco
               temp-faturamento-beneficiario.in-faixa           = w-vlbenef.nr-faixa-etaria.
    end.

end procedure.
