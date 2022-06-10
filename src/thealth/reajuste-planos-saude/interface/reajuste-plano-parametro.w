&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME frameDialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS frameDialog 
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
block-level on error undo, throw.

{thealth/libs/color-template.i}
{thealth/reajuste-planos-saude/interface/reajuste-plano.i} 

/* ***************************  Definitions  ************************** */
define variable lo-configuracao-browse      as   longchar   no-undo.
define variable hd-api-config               as   handle     no-undo.
define new global shared variable v_cod_usuar_corren as character
                          format "x(12)":U label "Usu rio Corrente"
                                        column-label "Usu rio Corrente" no-undo.

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frameDialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS buttonProcurarEvento RECT-1 ~
textEventoCobrancaReajuste textDescricaoEventoReajuste buttonSalvar ~
buttonCancelar labelParametros 
&Scoped-Define DISPLAYED-OBJECTS textEventoCobrancaReajuste ~
textDescricaoEventoReajuste labelParametros 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
define button buttonCancelar 
     label "Cancela&r" 
     size 15 by 1.14.

define button buttonProcurarEvento  no-focus flat-button
     label "..." 
     size 5 by 1.14.

define button buttonSalvar 
     label "&Salvar" 
     size 15 by 1.14.

define variable labelParametros as character format "X(256)":U initial "Parametros" 
      view-as text 
     size 14 by .62 no-undo.

define variable textDescricaoEventoReajuste as character format "X(256)":U 
     view-as fill-in 
     size 62 by 1 no-undo.

define variable textEventoCobrancaReajuste as character format "X(256)":U 
     label "Evento reajuste" 
     view-as fill-in 
     size 9 by 1 no-undo.

define rectangle RECT-1
     edge-pixels 2 graphic-edge  no-fill   
     size 101 by 2.38.


/* ************************  Frame Definitions  *********************** */

define frame frameDialog
     buttonProcurarEvento at row 2.05 col 31 widget-id 34
     textEventoCobrancaReajuste at row 2.1 col 20 colon-aligned widget-id 44
     textDescricaoEventoReajuste at row 2.1 col 33.8 colon-aligned no-label widget-id 42
     buttonSalvar at row 3.86 col 72 widget-id 36
     buttonCancelar at row 3.86 col 88 widget-id 32
     labelParametros at row 1 col 4.2 colon-aligned no-label widget-id 38
     RECT-1 at row 1.24 col 2 widget-id 40
     space(0.99) skip(1.61)
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
/* SETTINGS FOR DIALOG-BOX frameDialog
   FRAME-NAME                                                           */
assign 
       frame frameDialog:SCROLLABLE       = false
       frame frameDialog:HIDDEN           = true.

assign 
       textDescricaoEventoReajuste:READ-ONLY in frame frameDialog        = true.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME frameDialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frameDialog frameDialog
on window-close of frame frameDialog /* <insert dialog title> */
do:
  apply "END-ERROR":U to self.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonCancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonCancelar frameDialog
on choose of buttonCancelar in frame frameDialog /* Cancelar */
do:
    define variable lg-confirmar as logical no-undo.
    
    message 'Confirma sair sem salvar?'
    view-as alert-box question buttons yes-no update lg-confirmar.
    
    if not lg-confirmar
    then return.
    
    apply 'window-close' to frame frameDialog.
       
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonSalvar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonSalvar frameDialog
on choose of buttonSalvar in frame frameDialog /* Salvar */
do:
    run acaoSalvar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME textEventoCobrancaReajuste
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL textEventoCobrancaReajuste frameDialog
on value-changed of textEventoCobrancaReajuste in frame frameDialog /* Evento reajuste */
do:
    run acaoBuscarEvento.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frameDialog 


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoBuscarEvento frameDialog 
procedure acaoBuscarEvento :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    assign textEventoCobrancaReajuste:bgcolor in frame frameDialog  = ?
           textEventoCobrancaReajuste:tooltip                       = ''
           .
           
    find first evenfatu no-lock
         where evenfatu.in-entidade = 'FT'
           and evenfatu.cd-evento   = integer (textEventoCobrancaReajuste:screen-value)
               no-error.
               
    if available evenfatu
    then do:
        
        assign textDescricaoEventoReajuste:screen-value = evenfatu.ds-evento.
    end.
    else do:
        
        assign textDescricaoEventoReajuste:tooltip      = 'EVENTO NÇO ENCONTRADO'
               textDescricaoEventoReajuste:screen-value = ''
               textEventoCobrancaReajuste:bgcolor       = COLOR-ERROR
               . 
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoSalvar frameDialog
procedure acaoSalvar:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    if textEventoCobrancaReajuste:bgcolor in frame frameDialog <> ?
    then do:
        
        message 'Existem parƒmetros com valores inv lidos.~nVerifique os campos destacados ou cancele a edi‡Æo'
        view-as alert-box information buttons ok.
        return.
    end.    
    do on error undo, return:
                
        run salvarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano",
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE,
                                              input  string (textEventoCobrancaReajuste:screen-value)).         
        
        
        message 'Parƒmetros atualizados com sucesso'
        view-as alert-box information buttons ok.
        
        apply 'window-close' to frame frameDialog.
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao salvar os parƒmetros.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao salvar os parƒmetros.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
    end.

end procedure.
    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregarParametros frameDialog 
procedure carregarParametros private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
    define variable lo-parametro            as   longchar   no-undo.     
    
    run buscarParametro in hd-api-config (input  "th-gps-param",
                                          input  "reajuste-plano", 
                                          input  ?,
                                          input  PARAM_EVENTO_REAJUSTE,
                                          output lo-parametro).       
    if not error-status:error
    and lo-parametro   <> ?
    and lo-parametro   <> ''
    then do:
        
        assign textEventoCobrancaReajuste:screen-value in frame frameDialog = string (lo-parametro).
        apply 'value-changed' to textEventoCobrancaReajuste.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI frameDialog  _DEFAULT-DISABLE
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
  hide frame frameDialog.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI frameDialog  _DEFAULT-ENABLE
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
  display textEventoCobrancaReajuste textDescricaoEventoReajuste labelParametros 
      with frame frameDialog.
  enable buttonProcurarEvento RECT-1 textEventoCobrancaReajuste 
         textDescricaoEventoReajuste buttonSalvar buttonCancelar 
         labelParametros 
      with frame frameDialog.
  view frame frameDialog.
  {&OPEN-BROWSERS-IN-QUERY-frameDialog}
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inicializarInterface frameDialog 
procedure inicializarInterface :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    do on error undo, throw:
        
        assign frame frameDialog:title  = 'Configurar parƒmetros'.
        
        run thealth/libs/api-mantem-parametros.p persistent set hd-api-config.
        
        run carregarParametros.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

