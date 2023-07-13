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
DEFINE BUTTON buttonCancelar AUTO-END-KEY 
     LABEL "Cancela&r" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON buttonConfirmar AUTO-GO 
     LABEL "&Alterar" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE textQuantidadeParcelas AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Quantidade parcelas" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 59 BY 2.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frameDialog
     textQuantidadeParcelas AT ROW 1.95 COL 29 COLON-ALIGNED WIDGET-ID 2
     buttonConfirmar AT ROW 3.62 COL 31
     buttonCancelar AT ROW 3.62 COL 46
     "Parcelar" VIEW-AS TEXT
          SIZE 10 BY .62 AT ROW 1 COL 5 WIDGET-ID 6
     RECT-2 AT ROW 1.24 COL 2 WIDGET-ID 4
     SPACE(0.79) SKIP(1.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         BGCOLOR 15 FONT 1
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON buttonConfirmar CANCEL-BUTTON buttonCancelar WIDGET-ID 100.


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
    assign in-quantidade-parcela    = ?.
    apply 'window-close' to frame frameDialog.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonConfirmar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonConfirmar frameDialog
ON choose OF buttonConfirmar IN FRAME frameDialog /* Alterar */
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
  DISPLAY textQuantidadeParcelas 
      WITH FRAME frameDialog.
  ENABLE RECT-2 textQuantidadeParcelas buttonConfirmar buttonCancelar 
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

    assign textQuantidadeParcelas:screen-value in frame frameDialog = string (in-quantidade-parcela)
           frame frameDialog:title                                  = 'Quantidade de parcelas'.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

