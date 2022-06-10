
/*------------------------------------------------------------------------
    File        : api-reajuste-plano.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : fabri
    Created     : Tue Jun 07 07:13:27 BRT 2022
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define variable TIPO_PESSOA_FISICA          as   character  init 'F'    no-undo.
define variable TIPO_PESSOA_JURIDICA        as   character  init 'J'    no-undo.
define variable TIPO_PESSOA_AMBOS           as   character  init 'A'    no-undo.


define variable EV_API_REAJUSTE_PLANO_CONSULTAR 
                                            as   character  init 'EV_API_REAJUSTE_PLANO_CONSULTAR'
                                                                        no-undo.
define variable EV_API_REAJUSTE_PLANO_CRIAR_EVENTO 
                                            as   character  init 'EV_API_REAJUSTE_PLANO_CRIAR_EVENTO'
                                                                        no-undo.

define temp-table temp-contrato             no-undo
                                            serialize-name  'contrato'
    field lg-marcado                        as   logical    label '   '                 view-as toggle-box
    field in-modalidade                     as   integer    label 'Modalidade'          format '>9'
    field in-termo                          as   integer    label 'Termo'               format '>>>>>9'                                           
    field in-proposta                       as   integer    label 'Proposta'            format '>>>>>9'
    field ch-ultimo-reajuste                as   character  label 'Èlt. reaj.'          format 'x(8)'
    field dc-percentual-ultimo-reajuste     as   decimal    label '% £lt. reaj.'        format '->>9.99'
    field ch-ultimo-faturamento             as   character  label 'Per°odo £lt. fat.'   format 'x(8)'
    field dc-contratante                    as   decimal    label 'C¢d. contratante'    format '>>>>>>>>9'
    field dc-contratante-origem             as   decimal    label 'C¢d. contrat. origem'
                                                                                        format '>>>>>>>>9'
    field in-quantidade-vidas               as   integer    label 'Qt. vidas'           format '>>>9'
    field ch-contratante                    as   character  label 'Contratante'         format 'x(40)'
    field ch-contratante-origem             as   character  label 'Contratante orig.'   format 'x(40)'
    field lg-possui-reajuste-ano-ref        as   logical    label 'Possui reaj?'        view-as toggle-box
    field lg-eventos-gerados                as   logical    label 'Eventos gerados'     format 'Sim/N∆o'
    field ch-usuario-evento                 as   character  label 'Gerado por'          format 'x(20)'
    field dt-geracao-evento                 as   datetime   label 'Em'                  format '99/99/9999 HH:MM:SS'
    index idx1
          as primary
          in-modalidade
          in-termo
    index idx2
          lg-possui-reajuste-ano-ref
    index idx3
          lg-marcado
          lg-possui-reajuste-ano-ref
          lg-eventos-gerados
    .
    
define temp-table temp-valor-beneficiario   no-undo
                                            serialize-name  'valorBenef'
    field rc-contrato                       as   recid      serialize-hidden
    field in-modalidade                     as   integer    label 'Modalidade'
    field in-termo                          as   integer    label 'Termo'
    field in-usuario                        as   integer    label 'Usu†rio'
    field ch-nome-usuario                   as   character  label 'Nome'            format 'x(40)'
    field dt-nascimento                     as   date       label 'Dt. Nascimento'  format '99/99/9999'
    field in-grau-parentesco                as   integer    label 'Grau par.'
    field ch-grau-parentesto                as   character  label 'Grau par.'       format 'x(15)'
    field dt-inclusao-plano                 as   date       label 'Dt. Inclus∆o'    format '99/99/9999'
    field lg-aniversario-periodo            as   logical    label 'Fez aniver.?'    format 'Sim/N∆o'
    field lg-possui-troca-faixa             as   logical    label 'Trocou faixa?'   format 'Sim/N∆o' 
    field dc-valor-referencia               as   decimal    label 'Valor faturado'
    field in-quantidade-parcelas            as   integer    label 'Quantidade parcela'
    field dc-valor-cobrar                   as   decimal    label 'Valor cobrar'    
    index idx1
          as primary
          as unique
          in-modalidade
          in-termo
          in-usuario
    .
    
    
define temp-table temp-valor-beneficiario-mes   no-undo
                                            serialize-name  'valorBenefMes'
    field rc-valor-benef                    as   recid      serialize-hidden
    field in-modalidade                     as   integer    label 'Modalidade'
    field in-termo                          as   integer    label 'Termo'
    field in-usuario                        as   integer    label 'Usu†rio'
    field in-ano                            as   integer    label 'Ano'
    field in-mes                            as   integer    label 'Màs'
    field lg-trocou-faixa                   as   logical
    field lg-simular                        as   logical    
    field dc-valor-referencia               as   decimal
    field dc-valor-parcela                  as   decimal
    field in-faixa-etaria                   as   integer
    field in-idade                          as   integer
    index idx1
          as primary
          as unique
          in-modalidade
          in-termo
          in-usuario
          in-ano
          in-mes
    .
    
    
define temp-table temp-exportar             no-undo
    field in-modalidade                     as   integer    label 'Modalidade'
    field in-termo                          as   integer    label 'Termo'                                           
    field in-proposta                       as   integer    label 'Proposta'
    field in-usuario                        as   integer    label 'Usu†rio'    
    field ch-ultimo-reajuste                as   character  label 'Èlt. reaj.'
    field dc-percentual-ultimo-reajuste     as   decimal    label '% £lt. reaj.'        format '->>9.99'
    field ch-ultimo-faturamento             as   character  label 'Per°odo £lt. fat.'
    field dc-valor-referencia               as   decimal    label 'Valor faturado'
    field in-quantidade-parcelas            as   integer    label 'Quantidade parcela'
    field ch-nome-usuario                   as   character  label 'Nome'            format 'x(40)'
    field dt-nascimento                     as   date       label 'Dt. Nascimento'  format '99/99/9999'
    field in-grau-parentesco                as   integer    label 'Grau par.'
    field ch-grau-parentesto                as   character  label 'Grau par.'       format 'x(15)'
    field dt-inclusao-plano                 as   date       label 'Dt. Inclus∆o'    format '99/99/9999'
    index idx1
          as primary
          as unique
          in-modalidade
          in-termo
          in-usuario
    . 



     
define dataset ds-valor-beneficiario
    for temp-valor-beneficiario, 
        temp-valor-beneficiario-mes
    parent-id-relation r2 
        for temp-valor-beneficiario, 
            temp-valor-beneficiario-mes
        parent-id-field rc-valor-benef
    .                        

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
