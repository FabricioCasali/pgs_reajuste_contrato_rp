
/*------------------------------------------------------------------------
    File        : reajuste-plano-dominios.I
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : fabri
    Created     : Tue Jun 07 07:49:36 BRT 2022
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */


function considerarEvento returns logical 
    (in-evento as integer,
     ch-classe as character) forward.

function faturamentoAntecipado returns logical 
    (in-modalidade          as   integer,
     in-termo               as   integer) forward.

function tipoContratoPessoa returns character 
    (input  in-modalidade               as   integer,
     input  in-termo                    as   integer) forward.

function usarRegraValorMesReferencia returns logical 
    (in-modalidade as   integer,
     in-termo      as   integer) forward.


/* ***************************  Main Block  *************************** */

/* ************************  Function Implementations ***************** */


function considerarEvento returns logical 
    (in-evento  as   integer,
     ch-classe  as  character):
/*------------------------------------------------------------------------------
 Purpose: indica se o evento encontrado no faturamento deve ser considerado 
          na composicao da base da mensalidade. por padrao, consideramos
          apenas os eventos onde a classe do evento eh referente a mensalidade
 Notes:
------------------------------------------------------------------------------*/    
    define variable lg-saida            as   logical    no-undo.
        
    if in-evento = 111
    or in-evento = 113 
    or in-evento = 311
    then assign lg-saida = yes.
    
    return lg-saida.
end function.

function faturamentoAntecipado returns logical 
    (in-modalidade          as   integer,
     in-termo               as   integer):
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/    
    define buffer buf-propost       for  propost.
    define variable in-plano        as   integer    no-undo.
    define variable in-tipo-plano   as   integer    no-undo.
    
    if in-modalidade   <> 5
    then return no.
    
    if not available propost
    or propost.cd-modalidade   <> in-modalidade
    or propost.nr-ter-adesao   <> in-termo 
    then do:
        
        find first buf-propost no-lock
             where buf-propost.cd-modalidade    = in-modalidade
               and buf-propost.nr-ter-adesao    = in-termo.
               
        assign in-plano         = buf-propost.cd-plano
               in-tipo-plano    = buf-propost.cd-tipo-plano
               .                       
    end.
    else do:
        
        assign in-plano         = propost.cd-plano
               in-tipo-plano    = propost.cd-tipo-plano
               .                               
    end.
    
    if in-plano = 6
    or in-plano = 7
    then return yes.
    
    return no.

end function.

function tipoContratoPessoa returns character 
    (input  in-modalidade               as   integer,
     input  in-termo                    as   integer  ):
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/    
 
    define buffer  buf-propost  for  propost.
    define buffer  buf-modalid  for  modalid.
    
    for first buf-propost no-lock
        where buf-propost.cd-modalidade    = in-modalidade
          and buf-propost.nr-ter-adesao    = in-termo,
        first buf-modalid no-lock
        where buf-modalid.cd-modalidade    = buf-propost.cd-modalidade:

       if buf-propost.cd-modalidade = 7 and (buf-propost.cd-plano = 9 or buf-propost.cd-plano = 15
       or buf-propost.cd-plano = 17 or buf-propost.cd-plano = 21 or buf-propost.cd-plano = 22 or buf-propost.cd-plano = 24
       or buf-propost.cd-plano = 26 or buf-propost.cd-plano = 27 or buf-propost.cd-plano = 28 or buf-propost.cd-plano = 29
       or buf-propost.cd-plano = 30 or buf-propost.cd-plano = 35 or buf-propost.cd-plano = 36 or buf-propost.cd-plano = 37
       or buf-propost.cd-plano = 39 or buf-propost.cd-plano = 40 or buf-propost.cd-plano = 41 or buf-propost.cd-plano = 42
       or buf-propost.cd-plano = 43 or buf-propost.cd-plano = 44 or buf-propost.cd-plano = 49 or buf-propost.cd-plano = 51
       or buf-propost.cd-plano = 52 or buf-propost.cd-plano = 57 or buf-propost.cd-plano = 58 or buf-propost.cd-plano = 61
       or buf-propost.cd-plano = 62 or buf-propost.cd-plano = 68) then return "PJ". 
 
        if  buf-modalid.in-tipo-pessoa = 'F'
        then return 'PF'.
        else return 'PJ'.
    end.  
        
end function.

function usarRegraValorMesReferencia returns logical 
    (in-modalidade as   integer,
     in-termo      as   integer  ):
/*------------------------------------------------------------------------------
 Purpose: verifica se deve usar a regra de usar como base o valor do beneficiario
          no mes de referencia, mesmo ele tendo sido incluido no plano no decorrer de 2020.
          nestes casos, o sistema irÿ usar o valor de outro beneficiario no mesmo grau/faixa 
          nos periodos em que o beneficiario n’o esta presente.
 Notes:
------------------------------------------------------------------------------*/
    define buffer buf-propost           for propost.
    
 
    find first buf-propost no-lock   
         where buf-propost.cd-modalidade    = in-modalidade
           and buf-propost.nr-ter-adesao    = in-termo
           and buf-propost.cd-sit-proposta >= 5
           and buf-propost.cd-sit-proposta <= 7
               no-error.

    if not available buf-propost 
    then return no.
               
    /*----------------------------------- Engenharia ----------------------------------------*/
    if buf-propost.cd-contratante   = 11363 
    then return  yes.
    
    /*----------------------------------- Arfusp ---------------------------------------------*/
    if  buf-propost.cd-modalidade   = 12
    and buf-propost.cd-plano        = 1 
    then return yes.
        
    /*----------------------------------- Fpsmed ---------------------------------------------*/
    if  buf-propost.cd-modalidade   = 12
    and buf-propost.cd-plano        = 12 
    then return yes.
 
    /*----------------------------------- Assoc Adv ---------------------------------------------*/
    if  buf-propost.cd-modalidade   = 12
    and buf-propost.cd-plano        = 2 
    then return yes.
 
    /*----------------------------------- Aorp (odont) ---------------------------------------------*/
    if  buf-propost.cd-modalidade   = 12
    and buf-propost.cd-plano        = 13 
    then return yes.

    if  buf-propost.cd-modalidade   = 12
    and buf-propost.cd-plano        = 6 
    then return yes.
 
    if  buf-propost.cd-modalidade   = 7
    and buf-propost.cd-plano        = 21 
    then return yes.
 
    /*----------------------------------- Asso Juris ---------------------------------------------*/
    if  buf-propost.cd-contratante  = 276918 
    then return yes.
    
    /*----------------------------------- Centro Medico ---------------------------------------------*/
    if  buf-propost.cd-modalidade   = 7
    and buf-propost.cd-plano        = 44 
    then return yes.

    if  buf-propost.cd-modalidade   = 12
    and buf-propost.cd-plano        = 11 
    then return yes.
     
    if  buf-propost.cd-modalidade   = 6
    and buf-propost.cd-plano        = 8
    then return yes.
   /*----------------------------------- MEDCRED ---------------------------------------------*/
    if  buf-propost.cd-modalidade   = 12
    and buf-propost.cd-plano        = 17
    then return yes.

    if  buf-propost.cd-modalidade   = 13
    and buf-propost.cd-plano        = 4
    then return yes.

/*----------------------------------------------------------------------------------------------*/
 
    return no.
 
end function.

