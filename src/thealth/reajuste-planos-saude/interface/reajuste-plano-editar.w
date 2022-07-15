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

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input-output parameter in-quantidade-parcela         as   integer    no-undo.           

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
&Scoped-Define ENABLED-OBJECTS RECT-2 textQuantidadeParcelas ~
buttonConfirmar buttonCancelar 
&Scoped-Define DISPLAYED-OBJECTS textQuantidadeParcelas 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
define button buttonCancelar auto-end-key 
     label "Cancela&r" 
     size 15 by 1.14
     bgcolor 8 .

define button buttonConfirmar auto-go 
     label "&Alterar" 
     size 15 by 1.14
     bgcolor 8 .

define variable textQuantidadeParcelas as integer format "99":U initial 0 
     label "Quantidade parcelas" 
     view-as fill-in 
     size 14 by 1 no-undo.

define rectangle RECT-2
     edge-pixels 2 graphic-edge  no-fill   
     size 59 by 2.38.


/* ************************  Frame Definitions  *********************** */

define frame frameDialog
     textQuantidadeParcelas at row 1.95 col 29 colon-aligned widget-id 2
     buttonConfirmar at row 3.62 col 31
     buttonCancelar at row 3.62 col 46
     "Parcelar" view-as text
          size 10 by .62 at row 1 col 5 widget-id 6
     RECT-2 at row 1.24 col 2 widget-id 4
     space(0.79) skip(1.37)
    with view-as dialog-box keep-tab-order 
         side-labels no-underline three-d  scrollable 
         bgcolor 15 font 1
         title "<insert dialog title>"
         default-button buttonConfirmar cancel-button buttonCancelar widget-id 100.


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
    apply 'window-close' to frame frameDialog.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonConfirmar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonConfirmar frameDialog
on choose of buttonConfirmar in frame frameDialog /* Alterar */
do:
    assign in-quantidade-parcela    = integer (textQuantidadeParcelas:screen-value in frame frameDialog).
    apply 'window-close' to frame frameDialog.  
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
  display textQuantidadeParcelas 
      with frame frameDialog.
  enable RECT-2 textQuantidadeParcelas buttonConfirmar buttonCancelar 
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

    assign textQuantidadeParcelas:screen-value in frame frameDialog = string (in-quantidade-parcela)
           frame frameDialog:title                                  = 'Quantidade de parcelas'.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

