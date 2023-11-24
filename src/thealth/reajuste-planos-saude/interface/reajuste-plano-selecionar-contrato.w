&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME frameDefault
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS frameDefault 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

{thealth/reajuste-planos-saude/api/api-reajuste-plano.i}

define temp-table temp-beneficiario     no-undo
    field in-modalidade                 as   integer
    .
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable hd-api                  as   handle     no-undo.
define variable hd-status               as   handle     no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frameDefault

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS buttonConsultarDestino RECT-5 ~
buttonProcessar textContratoOriginal buttonConsultarOrigem ~
textContratoDestino textPeriodoFaturamento buttonFechar 
&Scoped-Define DISPLAYED-OBJECTS textContratoOriginal textDescricaoOrigem ~
textContratoDestino textDescricaoDestino textPeriodoFaturamento 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
define button buttonConsultarDestino 
     image-up file "thealth/assets/find_18_18.jpg":U no-focus flat-button
     label "" 
     size 6 by 1.14 tooltip "Consultar".

define button buttonConsultarOrigem 
     image-up file "thealth/assets/find_18_18.jpg":U no-focus flat-button
     label "" 
     size 6 by 1.14 tooltip "Consultar".

define button buttonFechar  no-focus flat-button
     label "Fecha&r" 
     size 15 by 1.14
     bgcolor 8 .

define button buttonProcessar 
     image-up file "thealth/assets/process2_36_36.jpg":U
     label "" 
     size 11 by 2.38.

define variable textContratoDestino as character format "99/99999999":U 
     label "Contrato destino" 
     view-as fill-in 
     size 11 by 1 no-undo.

define variable textContratoOriginal as character format "99/99999999":U 
     label "Contrato Origem" 
     view-as fill-in 
     size 11 by 1 no-undo.

define variable textDescricaoDestino as character format "X(256)":U 
     view-as fill-in 
     size 53 by 1 no-undo.

define variable textDescricaoOrigem as character format "X(256)":U 
     view-as fill-in 
     size 53 by 1 no-undo.

define variable textPeriodoFaturamento as character format "99/9999":U 
     label "Faturar para" 
     view-as fill-in 
     size 11 by 1 no-undo.

define rectangle RECT-5
     edge-pixels 2 graphic-edge  no-fill   
     size 103 by 4.29.


/* ************************  Frame Definitions  *********************** */

define frame frameDefault
     buttonConsultarDestino at row 2.76 col 31.6 widget-id 16
     buttonProcessar at row 1.43 col 92 widget-id 12
     textContratoOriginal at row 1.67 col 18 colon-aligned widget-id 2
     buttonConsultarOrigem at row 1.62 col 31.6 widget-id 10
     textDescricaoOrigem at row 1.67 col 36.4 colon-aligned no-label widget-id 4
     textContratoDestino at row 2.81 col 18 colon-aligned widget-id 18
     textDescricaoDestino at row 2.81 col 36.4 colon-aligned no-label widget-id 20
     textPeriodoFaturamento at row 3.95 col 18 colon-aligned widget-id 22
     buttonFechar at row 5.62 col 90
     RECT-5 at row 1.24 col 2 widget-id 14
     space(0.79) skip(1.41)
    with view-as dialog-box keep-tab-order 
         side-labels no-underline three-d  scrollable 
         bgcolor 15 font 1
         title "<insert dialog title>" widget-id 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX frameDefault
   FRAME-NAME                                                           */
assign 
       frame frameDefault:SCROLLABLE       = false
       frame frameDefault:HIDDEN           = true.

/* SETTINGS FOR FILL-IN textDescricaoDestino IN FRAME frameDefault
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN textDescricaoOrigem IN FRAME frameDefault
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME frameDefault
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frameDefault frameDefault
on window-close of frame frameDefault /* <insert dialog title> */
do:
  apply "END-ERROR":U to self.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonConsultarDestino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonConsultarDestino frameDefault
on choose of buttonConsultarDestino in frame frameDefault
do:
    
    run acaoAbrirPesquisaContrato (input  textContratoDestino:handle).  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonConsultarOrigem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonConsultarOrigem frameDefault
on choose of buttonConsultarOrigem in frame frameDefault
do:
    
    run acaoAbrirPesquisaContrato (input  textContratoOriginal:handle).  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonProcessar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonProcessar frameDefault
on choose of buttonProcessar in frame frameDefault
do:
  
    run acaoProcessar.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME textContratoDestino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL textContratoDestino frameDefault
on value-changed of textContratoDestino in frame frameDefault /* Contrato destino */
do:
    run acaoProcurarContrato (input  textContratoDestino:handle, 
                              input  textDescricaoDestino:handle).  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME textContratoOriginal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL textContratoOriginal frameDefault
on value-changed of textContratoOriginal in frame frameDefault /* Contrato Origem */
do:

    run acaoProcurarContrato (input  textContratoOriginal:handle, 
                              input  textDescricaoOrigem:handle).  
end.

on leave of textContratoOriginal in frame frameDefault /* Contrato origem */
do:
    def var modalidade as int no-undo.
    def var termo as int no-undo.

    assign modalidade = int(entry(1, textContratoOriginal:SCREEN-VALUE, "/"))
           termo      = int(entry(2, textContratoOriginal:SCREEN-VALUE, "/")) no-error.

    textContratoOriginal:screen-value = string(modalidade, "99") + string(termo, "99999999").
end.

on leave of textContratoDestino in frame frameDefault /* Contrato origem */
do:
    def var modalidade as int no-undo.
    def var termo as int no-undo.

    assign modalidade = int(entry(1, textContratoDestino:SCREEN-VALUE, "/"))
           termo      = int(entry(2, textContratoDestino:SCREEN-VALUE, "/")) no-error.

    textContratoDestino:screen-value = string(modalidade, "99") + string(termo, "99999999").
end.

on leave of textPeriodoFaturamento in frame frameDefault 
do:
    def var mes as int no-undo.
    def var ano as int no-undo.

    assign mes = int(entry(1, textPeriodoFaturamento:SCREEN-VALUE, "/"))
           ano = int(entry(2, textPeriodoFaturamento:SCREEN-VALUE, "/")) no-error.

    textPeriodoFaturamento:screen-value = string(mes, "99") + string(ano, "9999").
end.

//iagoo
&Scoped-define SELF-NAME buttonFechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonFechar frameDefault
on choose of buttonFechar in frame frameDefault /* Contrato Origem */
do:
    apply 'window-close' to frame frameDefault.
end.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frameDefault 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK:
  run enable_UI.
  run inicializarInterface.
  wait-for go of frame {&FRAME-NAME}.
end.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoAbrirPesquisaContrato frameDefault 
procedure acaoAbrirPesquisaContrato :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter hd-campo        as   handle     no-undo.

    define variable rc-propost              as   recid      no-undo.
    define variable lg-selecionado          as   logical    no-undo.

    
    do on error undo, return:
        
        run thealth/reajuste-planos-saude/interface/reajuste-plano-consultar-contrato.w (output lg-selecionado, 
                                                                                         output rc-propost).
        
        if lg-selecionado
        then do:
            
            find first propost no-lock
                 where recid (propost)  =  rc-propost.
                 
            assign hd-campo:screen-value    = substitute ("&1&2", string (propost.cd-modalidade, "99"), string (propost.nr-ter-adesao, "999999")).            
            apply "value-changed" to hd-campo.
        end.
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do: 
                
                message substitute ("Ops...~nOcorreu um erro ao abrir a consulta de contratos.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao abrir a consulta de contratos.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoProcessar frameDefault 
procedure acaoProcessar private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable in-modalidade-origem        as   integer    no-undo.
    define variable in-modalidade-destino       as   integer    no-undo.
    define variable in-termo-origem             as   integer    no-undo.
    define variable in-termo-destino            as   integer    no-undo.
    define variable in-ano                      as   integer    no-undo.
    define variable in-mes                      as   integer    no-undo.
    define variable lg-pdf                      as   logical    no-undo.
    define variable nm-arquivo-pdf              as   char       no-undo.
    
    
    do on error undo, return:
        
        if textDescricaoOrigem:screen-value in frame frameDefault   = ''
        then do:
            
            message 'Informe o contrato de origem'
            view-as alert-box information buttons ok.
            
            apply "entry" to textContratoOriginal.
            
            return.
        end.       
        
        if textDescricaoDestino:screen-value    = ''
        then do:
            
            message 'Informe o contrato de destino'
            view-as alert-box information buttons ok.
            
            apply "entry" to textContratoDestino.
            
            return.
        end.
        
        assign in-mes   = integer (substring (textPeriodoFaturamento:screen-value, 1, 2))
               in-ano   = integer (substring (textPeriodoFaturamento:screen-value, 4, 4))
               no-error.
               
        if error-status:error
        then do:
            
            message "Informe o per¡odo para o faturamento"
            view-as alert-box information buttons ok.
            
            apply "entry" to textPeriodoFaturamento.
            
            return.
        end.
        
        if in-mes < 1 
        or in-mes > 12
        or in-ano < 2023
        or in-ano > 2050
        then do:
            
            message "Informe um per¡odo de faturamento v lido"
            view-as alert-box information buttons ok.
            
            apply "entry" to textPeriodoFaturamento.
            
            return.
        end.
        
        assign in-modalidade-origem     = integer (substring (textContratoOriginal:screen-value, 1, 2))
               in-modalidade-destino    = integer (substring (textContratoDestino:screen-value, 1, 2))
               in-termo-origem          = integer (substring (textContratoOriginal:screen-value, 4))
               in-termo-destino         = integer (substring (textContratoDestino:screen-value, 4))
               .
               
        subscribe to EV_API_REAJUSTE_PLANO_MIGRAR_VALORES in hd-api run-procedure 'eventoMigrarValores'.
        
        if not valid-handle (hd-status)
        then do:
            
            run thealth/libs/status-processamento.w persistent set hd-status (input  'Migrando valores',
                                                                              input  no).
        end.
        
		do transaction:
			run migrarValoresEntreContratos in hd-api (input  in-modalidade-origem,
													   input  in-termo-origem,
													   input  in-modalidade-destino,
													   input  in-termo-destino,
													   input  in-mes,
													   input  in-ano,
													   output table temp-migracao-lote-gerado).
													   
													   
			message "Valores migrados com sucesso. Deseja gerar o PDF com os detalhes?"            
			view-as alert-box question buttons yes-no update lg-pdf.
			
			if lg-pdf
			then do:
                    nm-arquivo-pdf = string(today) + "_" + string(time, "hh:mm:ss").
                    nm-arquivo-pdf = replace(replace(nm-arquivo-pdf, "/", "_"), ":", "_").
                    nm-arquivo-pdf = "migra_reajuste_" + nm-arquivo-pdf + ".pdf".

					run gerarPdfMigracaoContrato in hd-api (input table temp-migracao-lote-gerado by-reference,
															input session:temp-directory,
															input nm-arquivo-pdf).		
			end.
			
			message "Relatorio gerado em: " session:temp-directory
				view-as alert-box.
		end.
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao migrar os valores.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao migrar os valores.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.                 
        finally:
            
            unsubscribe to EV_API_REAJUSTE_PLANO_MIGRAR_VALORES in hd-api.            
            delete object hd-status no-error.
        end.        
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoProcurarContrato frameDefault 
procedure acaoProcurarContrato :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter hd-campo        as   handle     no-undo.
    define input  parameter hd-desc         as   handle     no-undo.
        
    define variable in-modalidade           as   integer    no-undo.
    define variable in-termo                as   integer    no-undo.
    
    assign hd-desc:screen-value                             = ""
           hd-desc:private-data                             = ?
          // buttonProcessar:sensitive in frame frameDefault  = no
           .    
    
    do on error undo, return:

        assign in-modalidade    = integer (substring (hd-campo:screen-value, 1, 2))
               in-termo         = integer (substring (hd-campo:screen-value, 4)) no-error
               .
        
        find first propost no-lock
             where propost.cd-modalidade    = in-modalidade
               and propost.nr-ter-adesao    = in-termo
                   no-error.
                   
        if available propost
        then do:
            
            find first contrat no-lock
                 where contrat.cd-contratante   = propost.cd-contratante
                       .

            if avail contrat
            then assign hd-desc:screen-value         = substitute ("&1 - &2", contrat.cd-contratante, contrat.nm-contratante)
                        hd-desc:private-data         = string (recid (propost))
                   .
        end.   
        
        catch cs-erro as Progress.Lang.Error :

            if cs-erro:GetMessageNum(1) = 1
            then do:
    
                message substitute ("Ops...~nOcorreu um erro ao buscar os dados do contrato.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
    
                message substitute ("Ops...~nOcorreu um erro ao buscar os dados do contrato.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.

        end catch.
    end.    
    
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI frameDefault  _DEFAULT-DISABLE
procedure disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  hide frame frameDefault.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI frameDefault  _DEFAULT-ENABLE
procedure enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  display textContratoOriginal textDescricaoOrigem textContratoDestino 
          textDescricaoDestino textPeriodoFaturamento 
      with frame frameDefault.
  enable buttonConsultarDestino RECT-5 buttonProcessar textContratoOriginal 
         buttonConsultarOrigem textContratoDestino textPeriodoFaturamento 
         buttonFechar 
      with frame frameDefault.
  view frame frameDefault.
  {&OPEN-BROWSERS-IN-QUERY-frameDefault}
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE eventoMigrarValores frameDefault
procedure eventoMigrarValores private:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter ch-mensagem     as   character  no-undo.
    
    run mostrarMensagem in hd-status (input  substitute ("&1",
                                                         ch-mensagem)) no-error.
    process events.                                                         

end procedure.
    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inicializarInterface frameDefault 
procedure inicializarInterface private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
    assign frame frameDefault:title   = 'Selecionar contrato'.
    
    run thealth/reajuste-planos-saude/api/api-reajuste-plano.p persistent set hd-api.
    
    

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

