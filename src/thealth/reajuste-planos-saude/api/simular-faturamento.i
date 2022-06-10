
/*------------------------------------------------------------------------
    File        : simular-faturamento.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Thu Oct 05 15:55:56 BRT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
define temp-table temp-faturamento-contrato no-undo
    field in-modalidade                     as   integer
    field in-termo                          as   integer
    field in-ano                            as   integer
    field in-mes                            as   integer
    field dc-valor-total                    as   decimal.
    
    
define temp-table temp-faturamento-beneficiario   
                                            no-undo    
    field in-modalidade                     as   integer
    field in-termo                          as   integer
    field in-usuario                        as   integer
    field in-ano                            as   integer
    field in-mes                            as   integer
    field in-evento                         as   integer
    field ch-classe-evento                  as   character
    field dc-valor                          as   decimal
    field ch-tipo-movimento                 as   character
    field in-grau-par                       as   integer
    field in-faixa                          as   integer
    index idx1
          in-modalidade
          in-termo
          in-usuario
    index idx2
          in-grau-par
          in-faixa
    index idx3
          in-usuario.
          
define temp-table temp-simular-benef        no-undo
    field in-usuario                        as   integer
    field in-grau-parentesco                as   integer
    field in-idade                          as   integer
    field dt-inclusao                       as   date.
    
/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */


function EhEventoMensalidade returns logical 
    (ch-classe-evento               as   character) forward.

function IdadeBeneficiario returns integer 
    (dt-nascimento      as   date,
     dt-calculo         as   date) forward.

function ValorTotalMensalidade returns decimal 
    (in-modalidade          as   integer,
     in-termo               as   integer,
     in-usuario             as   integer) forward.

/* ***************************  Main Block  *************************** */


/* ************************  Function Implementations ***************** */

function EhEventoMensalidade returns logical 
    (ch-classe-evento               as   character ):

    if ch-classe-evento    = "A"
    or ch-classe-evento    = "K"
    or ch-classe-evento    = "L"
    or ch-classe-evento    = "N"
    or ch-classe-evento    = "O"
    or ch-classe-evento    = "P"
    or ch-classe-evento    = "Q"
    or ch-classe-evento    = "W"
    or ch-classe-evento    = "4"
    then do:
        return yes.
    end.                                     
    return no.       
end function.

function IdadeBeneficiario returns integer 
    (dt-nascimento      as   date,
     dt-calculo         as   date  ):

    define variable lg-erro                                     as   logical    no-undo.
    define variable in-idade-beneficiario                       as   integer    no-undo.
    
    run rtp/rtidade.p (input  dt-nascimento,
                       input  dt-calculo,
                       output in-idade-beneficiario,
                       output lg-erro).
                     
    if lg-erro then return ?.
    
    return in-idade-beneficiario.                         
        
end function.

function ValorTotalMensalidade returns decimal 
    (in-modalidade          as   integer,
     in-termo               as   integer,
     in-usuario             as   integer):
         
    define buffer buf-benef for temp-faturamento-beneficiario.
    define variable dc-valor as decimal no-undo.
    
             
        
    for each buf-benef
       where buf-benef.in-modalidade        = in-modalidade
         and buf-benef.in-termo             = in-termo
         and buf-benef.in-usuario           = in-usuario:
              
             
    find first evenfatu no-lock
         where evenfatu.in-entidade     = 'FT'
           and evenfatu.cd-evento       = buf-benef.in-evento.
             
        if EhEventoMensalidade (buf-benef.ch-classe-evento)
        then do:
            if buf-benef.ch-tipo-movimento  = 'CREDITO'
            then do:
                assign dc-valor = dc-valor + buf-benef.dc-valor.
            end.
            else do:
                assign dc-valor = dc-valor - buf-benef.dc-valor.
            end.   
        end.        
    end.
    return dc-valor.


        
end function.
    