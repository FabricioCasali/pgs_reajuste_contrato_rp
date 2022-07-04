&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
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
block-level on error undo, throw.

{thealth/libs/color-template.i}
{thealth/reajuste-planos-saude/api/api-reajuste-plano.i}
{thealth/reajuste-planos-saude/interface/reajuste-plano.i}
/* Parameters Definitions ---                                           */
define input        parameter in-modalidade                 as   integer    no-undo.
define input        parameter in-termo                      as   integer    no-undo.
define input-output parameter table                         for  temp-contrato.
define input-output parameter table                         for  temp-valor-beneficiario.


/* Local Variable Definitions ---                                       */

define variable ch-query                                as   character  no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frameDialog
&Scoped-define BROWSE-NAME browseBeneficiario

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-valor-beneficiario

/* Definitions for BROWSE browseBeneficiario                            */
&Scoped-define FIELDS-IN-QUERY-browseBeneficiario temp-valor-beneficiario.in-modalidade temp-valor-beneficiario.in-termo temp-valor-beneficiario.in-usuario temp-valor-beneficiario.ch-nome-usuario temp-valor-beneficiario.in-ano temp-valor-beneficiario.in-mes temp-valor-beneficiario.dc-valor temp-valor-beneficiario.dt-nascimento temp-valor-beneficiario.in-grau-parentesco temp-valor-beneficiario.dc-id-criterio-atual temp-valor-beneficiario.dc-regra-atual temp-valor-beneficiario.in-faixa-atual temp-valor-beneficiario.ch-nome temp-valor-beneficiario.dt-inclusao-plano   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browseBeneficiario   
&Scoped-define SELF-NAME browseBeneficiario
&Scoped-define QUERY-STRING-browseBeneficiario FOR EACH temp-valor-beneficiario
&Scoped-define OPEN-QUERY-browseBeneficiario OPEN QUERY {&SELF-NAME} FOR EACH temp-valor-beneficiario.
&Scoped-define TABLES-IN-QUERY-browseBeneficiario temp-valor-beneficiario
&Scoped-define FIRST-TABLE-IN-QUERY-browseBeneficiario temp-valor-beneficiario


/* Definitions for FRAME frameBrowse                                    */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS textContrato textContratante ~
textPercentualReaj textPeriodoReaj buttonSair 
&Scoped-Define DISPLAYED-OBJECTS textContrato textContratante ~
textPercentualReaj textPeriodoReaj 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
define button buttonSair auto-end-key 
     label "Sai&r" 
     size 15 by 1.14
     bgcolor 8 .

define variable textContratante as character format "X(256)":U 
     label "Contratante" 
     view-as fill-in 
     size 63 by 1 no-undo.

define variable textContrato as character format "X(256)":U 
     label "Contrato" 
     view-as fill-in 
     size 25 by 1 no-undo.

define variable textPercentualReaj as character format "X(256)":U 
     label "% Reajuste" 
     view-as fill-in 
     size 14 by 1 no-undo.

define variable textPeriodoReaj as character format "X(256)":U 
     label "Último reajuste" 
     view-as fill-in 
     size 12 by 1 no-undo.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
define query browseBeneficiario for 
      temp-valor-beneficiario scrolling.
&ANALYZE-RESUME

/* Browse definitions                                                   */
define browse browseBeneficiario
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browseBeneficiario frameDialog _FREEFORM
  query browseBeneficiario display
    temp-valor-beneficiario.in-usuario            
    temp-valor-beneficiario.ch-nome-usuario       
    temp-valor-beneficiario.dt-nascimento         
    temp-valor-beneficiario.ch-grau-parentesto    
    temp-valor-beneficiario.dt-inclusao-plano     
    temp-valor-beneficiario.dc-valor-referencia
    temp-valor-beneficiario.in-quantidade-parcelas       
    temp-valor-beneficiario.dc-valor-cobrar       
    temp-valor-beneficiario.lg-aniversario-periodo
    temp-valor-beneficiario.lg-possui-troca-faixa 
    





/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 121 BY 11.19
         FONT 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

define frame frameDialog
     textContrato at row 1.48 col 14 colon-aligned widget-id 2
     textContratante at row 1.48 col 59 colon-aligned widget-id 4
     textPercentualReaj at row 2.67 col 59 colon-aligned widget-id 8
     textPeriodoReaj at row 2.67 col 90 colon-aligned widget-id 6
     buttonSair at row 16.48 col 110
     space(1.19) skip(0.18)
    with view-as dialog-box keep-tab-order 
         side-labels no-underline three-d  scrollable 
         bgcolor 15 font 1
         title "<insert dialog title>"
         cancel-button buttonSair widget-id 100.

define frame frameBrowse
     browseBeneficiario at row 1 col 2 widget-id 200
    with 1 down keep-tab-order overlay 
         side-labels no-underline three-d 
         at col 2 row 3.86
         size 123 by 12.38
         bgcolor 15 font 1
         title "Beneficiarios" widget-id 300.


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
/* REPARENT FRAME */
assign frame frameBrowse:FRAME = frame frameDialog:HANDLE.

/* SETTINGS FOR FRAME frameBrowse
                                                                        */
/* BROWSE-TAB browseBeneficiario 1 frameBrowse */
/* SETTINGS FOR DIALOG-BOX frameDialog
   FRAME-NAME                                                           */

define variable XXTABVALXX as logical no-undo.

assign XXTABVALXX = frame frameBrowse:MOVE-AFTER-TAB-ITEM (textPeriodoReaj:HANDLE in frame frameDialog)
       XXTABVALXX = frame frameBrowse:MOVE-BEFORE-TAB-ITEM (buttonSair:HANDLE in frame frameDialog)
/* END-ASSIGN-TABS */.

assign 
       frame frameDialog:SCROLLABLE       = false
       frame frameDialog:HIDDEN           = true.

assign 
       textContratante:READ-ONLY in frame frameDialog        = true.

assign 
       textContrato:READ-ONLY in frame frameDialog        = true.

assign 
       textPercentualReaj:READ-ONLY in frame frameDialog        = true.

assign 
       textPeriodoReaj:READ-ONLY in frame frameDialog        = true.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browseBeneficiario
/* Query rebuild information for BROWSE browseBeneficiario
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-valor-beneficiario.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE browseBeneficiario */
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


&Scoped-define SELF-NAME buttonSair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonSair frameDialog
on choose of buttonSair in frame frameDialog /* Sair */
do:
    apply 'close' to this-procedure.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browseBeneficiario
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frameDialog 

 
/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
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
  hide frame frameBrowse.
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
  display textContrato textContratante textPercentualReaj textPeriodoReaj 
      with frame frameDialog.
  enable textContrato textContratante textPercentualReaj textPeriodoReaj 
         buttonSair 
      with frame frameDialog.
  view frame frameDialog.
  {&OPEN-BROWSERS-IN-QUERY-frameDialog}
  enable browseBeneficiario 
      with frame frameBrowse.
  {&OPEN-BROWSERS-IN-QUERY-frameBrowse}
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inicializarInterface frameDialog 
procedure inicializarInterface private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/

    assign ch-query                 = substitute ("
    preselect each temp-valor-beneficiario no-lock ~n 
             where temp-valor-beneficiario.in-modalidade    = &1 ~n 
               and temp-valor-beneficiario.in-termo         = &2",
                                                  in-modalidade,
                                                  in-termo)
           frame frameDialog:title  = substitute ('Detalhamento do contrato &1/&2',
                                                  in-modalidade,
                                                  in-termo)
           .
                                   
    find first temp-contrato no-lock
         where temp-contrato.in-modalidade  = in-modalidade
           and temp-contrato.in-termo       = in-termo.
           
    assign textContratante:screen-value in frame frameDialog    = substitute ("&1 - &2", temp-contrato.dc-contratante, temp-contrato.ch-contratante)
           textContrato:screen-value                            = substitute ('&1/&2', temp-contrato.in-modalidade, temp-contrato.in-termo)
           textPeriodoReaj:screen-value                         = substitute ('&1', temp-contrato.ch-ultimo-reajuste)
           textPercentualReaj:screen-value                      = substitute ('&1 %', temp-contrato.dc-percentual-ultimo-reajuste)
           .
      
    query browseBeneficiario:query-prepare (ch-query).
    query browseBeneficiario:query-open.
    
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

