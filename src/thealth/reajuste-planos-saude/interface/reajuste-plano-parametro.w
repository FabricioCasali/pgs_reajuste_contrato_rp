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
&Scoped-Define ENABLED-OBJECTS buttonProcurarEventoPF RECT-1 ~
buttonProcurarEventoPJ textEventoCobrancaReajustePF ~
textDescricaoEventoReajustePF textEventoCobrancaReajustePJ ~
textDescricaoEventoReajustePJ buttonSalvar buttonCancelar labelParametros 
&Scoped-Define DISPLAYED-OBJECTS textEventoCobrancaReajustePF ~
textDescricaoEventoReajustePF textEventoCobrancaReajustePJ ~
textDescricaoEventoReajustePJ labelParametros 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON buttonCancelar 
     LABEL "Cancela&r" 
     SIZE 15 BY 1.14.

DEFINE BUTTON buttonProcurarEventoPF  NO-FOCUS FLAT-BUTTON
     LABEL "..." 
     SIZE 5 BY 1.14.

DEFINE BUTTON buttonProcurarEventoPJ  NO-FOCUS FLAT-BUTTON
     LABEL "..." 
     SIZE 5 BY 1.14.

DEFINE BUTTON buttonSalvar 
     LABEL "&Salvar" 
     SIZE 15 BY 1.14.

DEFINE VARIABLE labelParametros AS CHARACTER FORMAT "X(256)":U INITIAL "Parametros" 
      VIEW-AS TEXT 
     SIZE 14 BY .62 NO-UNDO.

DEFINE VARIABLE textDescricaoEventoReajustePF AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 62 BY 1 NO-UNDO.

DEFINE VARIABLE textDescricaoEventoReajustePJ AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 62 BY 1 NO-UNDO.

DEFINE VARIABLE textEventoCobrancaReajustePF AS CHARACTER FORMAT "X(256)":U 
     LABEL "Evento reajuste PF" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE textEventoCobrancaReajustePJ AS CHARACTER FORMAT "X(256)":U 
     LABEL "Evento reajuste PJ" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 101 BY 3.57.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frameDialog
     buttonProcurarEventoPF AT ROW 2.05 COL 31 WIDGET-ID 34
     buttonProcurarEventoPJ AT ROW 3.14 COL 31 WIDGET-ID 46
     textEventoCobrancaReajustePF AT ROW 2.1 COL 20 COLON-ALIGNED WIDGET-ID 44
     textDescricaoEventoReajustePF AT ROW 2.1 COL 33.8 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     textEventoCobrancaReajustePJ AT ROW 3.19 COL 20 COLON-ALIGNED WIDGET-ID 50
     textDescricaoEventoReajustePJ AT ROW 3.19 COL 33.8 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     buttonSalvar AT ROW 4.86 COL 72 WIDGET-ID 36
     buttonCancelar AT ROW 4.86 COL 88 WIDGET-ID 32
     labelParametros AT ROW 1 COL 4.2 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     RECT-1 AT ROW 1.24 COL 2 WIDGET-ID 40
     SPACE(0.99) SKIP(1.80)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         BGCOLOR 15 FONT 1
         TITLE "<insert dialog title>" WIDGET-ID 100.


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
ASSIGN 
       FRAME frameDialog:SCROLLABLE       = FALSE
       FRAME frameDialog:HIDDEN           = TRUE.

ASSIGN 
       buttonProcurarEventoPF:HIDDEN IN FRAME frameDialog           = TRUE.

ASSIGN 
       buttonProcurarEventoPJ:HIDDEN IN FRAME frameDialog           = TRUE.

ASSIGN 
       textDescricaoEventoReajustePF:READ-ONLY IN FRAME frameDialog        = TRUE.

ASSIGN 
       textDescricaoEventoReajustePJ:READ-ONLY IN FRAME frameDialog        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME frameDialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL frameDialog frameDialog
ON window-close OF FRAME frameDialog /* <insert dialog title> */
do:
  apply "END-ERROR":U to self.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonCancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonCancelar frameDialog
ON choose OF buttonCancelar IN FRAME frameDialog /* Cancelar */
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
ON choose OF buttonSalvar IN FRAME frameDialog /* Salvar */
do:
    run acaoSalvar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME textEventoCobrancaReajustePF
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL textEventoCobrancaReajustePF frameDialog
ON value-changed OF textEventoCobrancaReajustePF IN FRAME frameDialog /* Evento reajuste PF */
do:
    run acaoBuscarEvento (input  'PF').  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME textEventoCobrancaReajustePJ
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL textEventoCobrancaReajustePJ frameDialog
ON value-changed OF textEventoCobrancaReajustePJ IN FRAME frameDialog /* Evento reajuste PJ */
do:
    run acaoBuscarEvento (input  'PJ').  
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
PROCEDURE acaoBuscarEvento :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter ch-campo            as   character  no-undo.
    

    if ch-campo = 'PF'
    then do:
        
        assign textEventoCobrancaReajustePF:bgcolor in frame frameDialog    = ?
               textEventoCobrancaReajustePF:tooltip                         = ''
               .
    end.
    else do:
        assign textEventoCobrancaReajustePJ:bgcolor = ?
               textEventoCobrancaReajustePJ:tooltip = ''
               .
    end.
    
           
    find first evenfatu no-lock
         where evenfatu.in-entidade = 'FT'
           and evenfatu.cd-evento   = if ch-campo = 'PF'
                                      then integer (textEventoCobrancaReajustePF:screen-value)
                                      else integer (textEventoCobrancaReajustePJ:screen-value)
               no-error.
               
    if available evenfatu
    then do:
        
        if ch-campo = 'PF'
        then 
            assign textDescricaoEventoReajustePF:screen-value = evenfatu.ds-evento.
        else 
            assign textDescricaoEventoReajustePJ:screen-value = evenfatu.ds-evento.
        
    end.
    else do:
        
        if ch-campo = 'PF'
        then do:
            
            assign textDescricaoEventoReajustePF:tooltip        = 'EVENTO NÇO ENCONTRADO'
                   textDescricaoEventoReajustePF:screen-value   = ''
                   textEventoCobrancaReajustePF:bgcolor         = COLOR-ERROR
                   . 
        end.
        else do:

            assign textDescricaoEventoReajustePJ:tooltip        = 'EVENTO NÇO ENCONTRADO'
                   textDescricaoEventoReajustePJ:screen-value   = ''
                   textEventoCobrancaReajustePJ:bgcolor         = COLOR-ERROR
                   . 
        end.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoSalvar frameDialog 
PROCEDURE acaoSalvar :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    if textEventoCobrancaReajustePF:bgcolor in frame frameDialog   <> ?
    or textEventoCobrancaReajustePJ:bgcolor                        <> ?
    then do:
        
        message 'Existem parƒmetros com valores inv lidos.~nVerifique os campos destacados ou cancele a edi‡Æo'
        view-as alert-box information buttons ok.
        return.
    end.     
    do on error undo, return:
                
        run salvarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano",
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE_PF,
                                              input  string (textEventoCobrancaReajustePF:screen-value)).         
        
        run salvarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano",
                                              input  ?,
                                              input  PARAM_EVENTO_REAJUSTE_PJ,
                                              input  string (textEventoCobrancaReajustePJ:screen-value)).         
        
        
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
PROCEDURE carregarParametros PRIVATE :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
    define variable lo-parametro            as   longchar   no-undo.     
    
    run buscarParametro in hd-api-config (input  "th-gps-param",
                                          input  "reajuste-plano", 
                                          input  ?,
                                          input  PARAM_EVENTO_REAJUSTE_PF,
                                          output lo-parametro).       
    if not error-status:error
    and lo-parametro   <> ?
    and lo-parametro   <> ''
    then do:
        
        assign textEventoCobrancaReajustePF:screen-value in frame frameDialog = string (lo-parametro).
        apply 'value-changed' to textEventoCobrancaReajustePF.
    end.
 
    run buscarParametro in hd-api-config (input  "th-gps-param",
                                          input  "reajuste-plano", 
                                          input  ?,
                                          input  PARAM_EVENTO_REAJUSTE_PJ,
                                          output lo-parametro).       
    if not error-status:error
    and lo-parametro   <> ?
    and lo-parametro   <> ''
    then do:
        
        assign textEventoCobrancaReajustePJ:screen-value    = string (lo-parametro).
        apply 'value-changed' to textEventoCobrancaReajustePJ.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI frameDialog  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME frameDialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI frameDialog  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY textEventoCobrancaReajustePF textDescricaoEventoReajustePF 
          textEventoCobrancaReajustePJ textDescricaoEventoReajustePJ 
          labelParametros 
      WITH FRAME frameDialog.
  ENABLE buttonProcurarEventoPF RECT-1 buttonProcurarEventoPJ 
         textEventoCobrancaReajustePF textDescricaoEventoReajustePF 
         textEventoCobrancaReajustePJ textDescricaoEventoReajustePJ 
         buttonSalvar buttonCancelar labelParametros 
      WITH FRAME frameDialog.
  VIEW FRAME frameDialog.
  {&OPEN-BROWSERS-IN-QUERY-frameDialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inicializarInterface frameDialog 
PROCEDURE inicializarInterface :
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

