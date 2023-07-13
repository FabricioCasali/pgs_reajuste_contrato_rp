
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

define variable TIPO_FATURA_NORMAL          as   character  init 'NORMAL'
                                                                        no-undo.
define variable TIPO_FATURA_AVULSA          as   character  init 'AVULSA'
                                                                        no-undo.
                                                                        

define variable ORIGEM_HISTORICO_GERAR_EVENTO
                                            as   character  init 'Gerar'
                                                                        no-undo.
                                                                        
define variable ORIGEM_HISTORICO_MIGRAR_EVENTO
                                            as   character  init 'Migrar'
                                                                        no-undo.
                                                                        
define variable ORIGEM_HISTORICO_REMOVER_EVENTO
                                            as   character  init 'Remover'
                                                                        no-undo.

define variable EV_API_REAJUSTE_PLANO_CONSULTAR 
                                            as   character  init 'EV_API_REAJUSTE_PLANO_CONSULTAR'
                                                                        no-undo.

define variable EV_API_REAJUSTE_PLANO_CRIAR_EVENTO 
                                            as   character  init 'EV_API_REAJUSTE_PLANO_CRIAR_EVENTO'
                                                                        no-undo.

define variable EV_API_REAJUSTE_PLANO_ELIMINAR_EVENTO
                                            as   character  init 'EV_API_REAJUSTE_PLANO_ELIMINAR_EVENTO'
                                                                        no-undo.

define variable EV_API_REAJUSTE_PLANO_MIGRAR_VALORES
                                            as   character  init 'EV_API_REAJUSTE_PLANO_MIGRAR_VALORES'
                                                                        no-undo.

define temp-table temp-contrato             no-undo
                                            serialize-name  'contrato'
    field lg-marcado                        as   logical    label '   '                 
                                                            view-as toggle-box
                                                            serialize-hidden
    field in-modalidade                     as   integer    label 'Modalidade'          
                                                            format '>9'
                                                            serialize-name 'modalidade'
    field in-termo                          as   integer    label 'Termo'               
                                                            format '>>>>>9'
                                                            serialize-name 'termo'                                           
    field in-proposta                       as   integer    label 'Proposta'            
                                                            format '>>>>>9'
                                                            serialize-name 'proposta'
    field ch-ultimo-reajuste                as   character  label 'élt. reaj.'          
                                                            format 'x(15)'
                                                            serialize-name 'ultReajuste'
    field dc-percentual-ultimo-reajuste     as   decimal    label '% £lt. reaj.'        
                                                            format '->>9.99'
                                                            serialize-name 'percUltReaj'
    field ch-ultimo-faturamento             as   character  label 'Per¡odo £lt. fat.'   
                                                            format 'x(8)'
                                                            serialize-name 'periodoUltFat'
    field dc-contratante                    as   decimal    label 'C¢d. contratante'    
                                                            format '>>>>>>>>9'
                                                            serialize-name 'contratante'
    field dc-contratante-origem             as   decimal    label 'C¢d. contrat. origem'
                                                            format '>>>>>>>>9'
                                                            serialize-name 'contratanteOrigem'
    field in-quantidade-vidas               as   integer    label 'Qt. vidas'
                                                            serialize-name 'qtVidas'           
                                                            format '>>>9'
    field ch-contratante                    as   character  label 'Contratante'
                                                            serialize-name 'nomeContratante'         
                                                            format 'x(40)'
    field ch-contratante-origem             as   character  label 'Contratante orig.'
                                                            serialize-name 'nomeContratanteOrigem'   
                                                            format 'x(40)'
    field lg-possui-reajuste-ano-ref        as   logical    label 'Possui reaj?'
                                                            serialize-name 'possuiReajuste'        
                                                            view-as toggle-box
    field lg-eventos-gerados                as   logical    label 'Eventos gerados'
                                                            serialize-name 'eventosGerados'     
                                                            format 'Sim/NÆo'
    field ch-usuario-evento                 as   character  label 'Gerado por'
                                                            serialize-name 'geradoPor'          
                                                            format 'x(20)'
    field dt-geracao-evento                 as   datetime   label 'Em'
                                                            serialize-name 'geradoEm'                  
                                                            format '99/99/9999 HH:MM:SS'
    field in-quantidade-parcelas            as   integer    label 'Qt. parc.'           
                                                            serialize-name 'quantidadeParcelas'
                                                            format '99'
    field in-quantidade-parcelas-usuario    as   integer    label 'Qt. parc. usuario'   
                                                            serialize-name 'quantidadeParcelasInformado' 
                                                            format '99'
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
                                                            format '>9'      
                                                            serialize-name 'modalidade'
    field in-termo                          as   integer    label 'Termo'
                                                            format '>>>>>9'           
                                                            serialize-name 'termo'
    field in-usuario                        as   integer    label 'Usu rio'
                                                            format '>>>>>>>9'         
                                                            serialize-name 'codUsuario'
    field ch-nome-usuario                   as   character  label 'Nome'            
                                                            format 'x(40)'
                                                            serialize-name 'nome'
    field dt-nascimento                     as   date       label 'Dt. Nascimento'  
                                                            format '99/99/9999'
                                                            serialize-name 'nascimento'
    field in-grau-parentesco                as   integer    label 'Grau par.'       
                                                            serialize-name 'codGrauParentesco'
    field ch-grau-parentesto                as   character  label 'Grau par.'       
                                                            format 'x(15)'
                                                            serialize-name 'descGrauParentesco'
    field dt-inclusao-plano                 as   date       label 'Dt. InclusÆo'    
                                                            format '99/99/9999'
                                                            serialize-name 'dtInclusaoPlano'
    field lg-aniversario-periodo            as   logical    label 'Fez aniver.?'    
                                                            format 'Sim/NÆo'
                                                            serialize-name 'fezAniversario'
    field lg-possui-troca-faixa             as   logical    label 'Trocou faixa?'   
                                                            format 'Sim/NÆo'
                                                            serialize-name 'trocouFaixa' 
    field dc-valor-referencia               as   decimal    label 'Valor faturado'
                                                            format 'R$ >>>,>>9.99'  
                                                            serialize-name 'valorNotaReferencia'
    field in-quantidade-parcelas            as   integer    label 'Quantidade parcela'
                                                            format '99'
                                                            serialize-name 'qtParcelas'
    field dc-valor-cobrar                   as   decimal    label 'Valor cobrar' 
                                                            format 'R$ >>>,>>9.99'        
                                                            serialize-name 'valorCobrarReajuste'
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
                                                            format '>9'      
                                                            serialize-name 'modalidade'
    field in-termo                          as   integer    label 'Termo'
                                                            format '>>>>>9'           
                                                            serialize-name 'termo'
    field in-usuario                        as   integer    label 'Usu rio'
                                                            format '>>>>>>>9'         
                                                            serialize-name 'codUsuario'
    field in-ano                            as   integer    label 'Ano'
                                                            format '9999'
                                                            serialize-name 'ano'
    field in-mes                            as   integer    label 'Mˆs'
                                                            format '99'
                                                            serialize-name 'mes'
    field dc-valor-parcela                  as   decimal    label 'Valor parcela'
                                                            format 'R$ >>>,>>9.99'
                                                            serialize-name 'valorParcela'
    field in-numero-parcela                 as   integer    label 'N£mero parc.'
                                                            format '99'
                                                            serialize-name 'numeroParcela'                                                               
    index idx1
          as primary
          as unique
          in-modalidade
          in-termo
          in-usuario
          in-ano
          in-mes
    .
    
    
define temp-table temp-valor-faturado-mes   no-undo 
                                            serialize-name 'valorBenefCobranca'
                                            like temp-valor-beneficiario-mes
    field dc-valor-referencia               as   decimal    label 'Valor ref.'
                                                            format 'R$ >>>,>>9.99'
                                                            serialize-name 'valorBenefCobranca'
    field dc-valor-reajuste                 as   decimal    label 'Valor reaj.'
                                                            format 'R$ >>>,>>9.99'
                                                            serialize-name 'valorReajuste'
    field in-faixa-etaria                   as   integer    label 'Faixa etaria'
                                                            format 'R$ >>>,>>9.99'
                                                            serialize-name 'faixaEtaria'        
    field in-idade                          as   integer    label 'Idade'
                                                            format '999'
                                                            serialize-name 'idade'                
    field lg-trocou-faixa                   as   logical    label 'Trocou fx.'
                                                            format 'Sim/NÆo'
                                                            serialize-name 'trocouFaixa'                                                        
     
    
    .    
    
    
    
define temp-table temp-exportar             no-undo
    field in-modalidade                     as   integer    label 'Modalidade'
    field in-termo                          as   integer    label 'Termo'                                           
    field in-proposta                       as   integer    label 'Proposta'
    field in-usuario                        as   integer    label 'Usu rio'    
    field ch-ultimo-reajuste                as   character  label 'élt. reaj.'
    field dc-percentual-ultimo-reajuste     as   decimal    label '% £lt. reaj.'        format '->>9.99'
    field ch-ultimo-faturamento             as   character  label 'Per¡odo £lt. fat.'
    field dc-valor-referencia               as   decimal    label 'Valor faturado'
    field in-quantidade-parcelas            as   integer    label 'Quantidade parcela'
    field ch-nome-usuario                   as   character  label 'Nome'            format 'x(40)'
    field dt-nascimento                     as   date       label 'Dt. Nascimento'  format '99/99/9999'
    field in-grau-parentesco                as   integer    label 'Grau par.'
    field ch-grau-parentesto                as   character  label 'Grau par.'       format 'x(15)'
    field dt-inclusao-plano                 as   date       label 'Dt. InclusÆo'    format '99/99/9999'
    field dc-valor-total-cobrar             as   decimal    label 'Total cobrar'    format '>>>,>>9.99'
    index idx1
          as primary
          as unique
          in-modalidade
          in-termo
          in-usuario
    . 



define temp-table temp-historico            no-undo
    field in-id-historico                   as   integer    label 'Id'              serialize-hidden
    field in-modalidade                     as   integer    label 'Modalidade'
    field in-termo                          as   integer    label 'Termo'                                           
    field in-quantidade-parcelas            as   integer    label 'Qt. parcelas'
    field dc-valor-cobrado                  as   decimal    label 'Valor'
    field ch-periodo-reajuste               as   character  label 'Per¡odo'    
    field ch-origem-historico               as   character  label 'Origem'
    field dt-ocorrencia                     as   datetime   label 'Ocorrˆncia'      format '99/99/9999 HH:MM:SS'
    field ch-usuario                        as   character  label 'Usu rio'         format 'x(20)'
    index idx1
          as unique
          in-id-historico
    index idx2
          as primary
          in-modalidade
          in-termo
          ch-periodo-reajuste
          ch-origem-historico          
    .
    
    
// temp-table utilizada na migra‡Æo de valores entre contratos, vinculando o usuario do contrato novo com o velho
define temp-table temp-assoc-usuario        no-undo
    field in-modalidade-origem              as   integer
    field in-termo-origem                   as   integer
    field in-usuario-origem                 as   integer
    field in-usuario-destino                as   integer
    field ch-nome                           as   character 
    field ch-cpf                            as   character 
    field dt-nascimento                     as   date
    field in-quantidade-evento              as   integer
    field dc-valor-evento                   as   decimal
    field in-evento                         as   integer
    field in-faixa-etaria                   as   integer
    field in-grau-parentesco                as   integer
    field rc-event-progdo                   as   recid
    index idx1
          as primary
          as unique
          in-usuario-origem
    index idx2
          as unique
          in-usuario-destino
    index idx3
          dc-valor-evento
    .    
    
define temp-table temp-migracao-lote-gerado no-undo
    field in-id-lote                        as   integer
    .    
    
// temp-table utilizada para armazenar os eventos programados relacionados ao usuario    
define temp-table temp-vinculo-evento-progto        
                                            no-undo
    field rc-assoc-usuario                  as   recid
    field rc-evento-progto                  as   recid
    index idx1
          as primary
          rc-assoc-usuario
    .    

define temp-table temp-evento-conta         no-undo
    field ch-conta                          as   character 
    field ch-centro                         as   character 
    field in-evento                         as   integer
    index idx1
          as primary
          as unique
          in-evento
    .
     
define dataset ds-dados
    for temp-contrato,
        temp-valor-beneficiario, 
        temp-valor-beneficiario-mes,
        temp-valor-faturado-mes
    parent-id-relation r1
        for temp-contrato,
            temp-valor-beneficiario
            parent-id-field rc-contrato
    parent-id-relation r2 
        for temp-valor-beneficiario, 
            temp-valor-beneficiario-mes
        parent-id-field rc-valor-benef
    parent-id-relation r3 
        for temp-valor-beneficiario, 
            temp-valor-faturado-mes
        parent-id-field rc-valor-benef
    
    .                        

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
