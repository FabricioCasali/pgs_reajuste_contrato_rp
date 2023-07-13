&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
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
define temp-table temp-contrato     no-undo
    field in-modalidade             as   integer
    field in-termo                  as   integer
    field dt-inicio                 as   date
    field ch-contratante            as   character 
    field ch-codigo-contratante     as   character 
    field in-proposta               as   integer
    field rc-propost                as   recid
    .
/* Parameters Definitions ---                                           */

define output parameter lg-selecionado          as   logical    no-undo.
define output parameter rc-propost              as   recid      no-undo.

/* Local Variable Definitions ---                                       */

define variable hd-status       as   handle     no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME frameDefault
&Scoped-define BROWSE-NAME browseDados

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-contrato

/* Definitions for BROWSE browseDados                                   */
&Scoped-define FIELDS-IN-QUERY-browseDados   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browseDados   
&Scoped-define SELF-NAME browseDados
&Scoped-define QUERY-STRING-browseDados FOR EACH temp-contrato
&Scoped-define OPEN-QUERY-browseDados OPEN QUERY {&SELF-NAME} FOR EACH temp-contrato.
&Scoped-define TABLES-IN-QUERY-browseDados temp-contrato
&Scoped-define FIRST-TABLE-IN-QUERY-browseDados temp-contrato


/* Definitions for DIALOG-BOX frameDefault                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frameDefault ~
    ~{&OPEN-QUERY-browseDados}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS buttonPesquisar RECT-3 textModalidade ~
buttonCancelar textTermo textContratante browseDados buttonSelecionar 
&Scoped-Define DISPLAYED-OBJECTS textModalidade textTermo textContratante 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
define button buttonCancelar auto-end-key  no-focus flat-button
     label "Cancelar" 
     size 15 by 1.14
     bgcolor 8 .

define button buttonPesquisar 
     image-up file "thealth/assets/search_36_36.jpg":U no-focus flat-button
     label "Pesquisar" 
     size 9 by 2.14.

define button buttonSelecionar auto-go  no-focus flat-button
     label "&Selecionar" 
     size 15 by 1.14
     bgcolor 8 .

define variable textContratante as character format "X(256)":U 
     label "Contratante" 
     view-as fill-in 
     size 73 by 1 no-undo.

define variable textModalidade as integer format ">9":U initial 0 
     label "Modalidade" 
     view-as fill-in 
     size 6 by 1 no-undo.

define variable textTermo as integer format ">>>>>9":U initial 0 
     label "Termo" 
     view-as fill-in 
     size 10.8 by 1 no-undo.

define rectangle RECT-3
     edge-pixels 2 graphic-edge  no-fill   
     size 111 by 2.86.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
define query browseDados for 
      temp-contrato scrolling.
&ANALYZE-RESUME

/* Browse definitions                                                   */
define browse browseDados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browseDados frameDefault _FREEFORM
  query browseDados display
      
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 111 BY 12.86
         FONT 1
         TITLE "Contratos (0)" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

define frame frameDefault
     buttonPesquisar at row 1.48 col 103 widget-id 10
     textModalidade at row 1.57 col 16 colon-aligned widget-id 4
     buttonCancelar at row 17.43 col 98
     textTermo at row 1.57 col 32.2 colon-aligned widget-id 6
     textContratante at row 2.76 col 16 colon-aligned widget-id 8
     browseDados at row 4.33 col 2 widget-id 200
     buttonSelecionar at row 17.43 col 83
     RECT-3 at row 1.24 col 2 widget-id 2
     space(0.59) skip(14.56)
    with view-as dialog-box keep-tab-order 
         side-labels no-underline three-d  scrollable 
         bgcolor 15 font 1
         title "<insert dialog title>"
         default-button buttonSelecionar cancel-button buttonCancelar widget-id 100.


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
                                                                        */
/* BROWSE-TAB browseDados textContratante frameDefault */
assign 
       frame frameDefault:SCROLLABLE       = false
       frame frameDefault:HIDDEN           = true.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browseDados
/* Query rebuild information for BROWSE browseDados
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-contrato.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browseDados */
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


&Scoped-define SELF-NAME buttonCancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonCancelar frameDefault
on choose of buttonCancelar in frame frameDefault /* Cancelar */
do:
    apply "close" to this-procedure.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonPesquisar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonPesquisar frameDefault
on choose of buttonPesquisar in frame frameDefault /* Pesquisar */
do:
    run acaoPesquisar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonSelecionar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonSelecionar frameDefault
on choose of buttonSelecionar in frame frameDefault /* Selecionar */
do:
    run acaoSelecionar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browseDados
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK frameDefault 


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
    wait-for go of frame {&FRAME-NAME}.
end.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoPesquisar frameDefault 
procedure acaoPesquisar :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable ch-query        as   character  no-undo.
    define variable hd-query        as   handle     no-undo.
    define variable lg-where        as   logical    no-undo.
    
    
    
    do on error undo, return:
        assign ch-query = "for each propost no-lock".
        
        run thealth/libs/status-processamento.w persistent set hd-status (input  "Consultando contratos", no).
        
        if textModalidade:screen-value in frame frameDefault   <> "0"
        then do:
            
            assign ch-query = substitute ("&1 where propost.cd-modalidade = &1", textModalidade:screen-value)
                   lg-where = yes
                   .
        end.
        
        if textTermo:screen-value  <> "0"
        then do:
            
            assign ch-query = substitute ("&1 &2 propost.nr-ter-adesao = &3",
                                          ch-query,
                                          if lg-where then "and" else "where",
                                          textTermo:screen-value)
                   .
        end.
        
        assign ch-query = substitute ("&1, first ter-ade no-lock where ter-ade.cd-modalidade = propost.cd-modalidade and ter-ade.nr-ter-adesao = propost.nr-ter-adesao", ch-query).
        assign ch-query = substitute ("&1, first contrat no-lock where contrat.cd-contratante = propost.cd-contratante", ch-query).
        
        if textContratante:screen-value <> ""
        then do:
            
            assign ch-query = substitute ("&1 where contrat.nm-contratante matches ('*&2*')", ch-query, textContratante:screen-value).
        end.
        
        empty temp-table temp-contrato.
        
        create query hd-query.
        hd-query:set-buffers (buffer propost:handle, buffer ter-ade:handle, buffer contrat:handle).
        hd-query:query-prepare (ch-query).
        hd-query:query-open().
        
        
        repeat:
            
            hd-query:get-next.
            
            if hd-query:query-off-end
            then leave.
            
            run mostrarMensagem in hd-status (input  substitute ("Lendo contrato &1/&2", propost.cd-modalidade, propost.nr-ter-adesao)).
            
            create temp-contrato.
            assign temp-contrato.in-modalidade          = propost.cd-modalidade
                   temp-contrato.in-termo               = propost.nr-ter-adesao
                   temp-contrato.in-proposta            = propost.nr-proposta
                   temp-contrato.dt-inicio              = ter-ade.dt-inicio
                   temp-contrato.ch-codigo-contratante  = string (propost.cd-contratante)
                   temp-contrato.ch-contratante         = contrat.nm-contratante
                   temp-contrato.rc-propost             = recid (propost)
                   .
        end.
        
        if browseDados:is-open 
        then browseDados:query-close ().
        
        browseDados:query-prepare ("preselect each temp-contrato").
        browseDados:query-open ().
        browseDados:title = substitute ("Contratos (&1)", query browseDados:num-results).
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao consultar os contratos.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao consultar os constratos.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
        finally:
            
            if valid-handle (hd-status)
            then delete object hd-status.
            
        end finally.
    end.
        

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoSelecionar frameDefault 
procedure acaoSelecionar :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
    if not available temp-contrato
    then do:
        
        message "Selecione um contrato para continuar"
        view-as alert-box information buttons ok.
        
        return.
    end.
    
    assign lg-selecionado   = yes
           rc-propost       = temp-contrato.rc-propost.
           
    apply "close" to this-procedure.

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
  display textModalidade textTermo textContratante 
      with frame frameDefault.
  enable buttonPesquisar RECT-3 textModalidade buttonCancelar textTermo 
         textContratante browseDados buttonSelecionar 
      with frame frameDefault.
  view frame frameDefault.
  {&OPEN-BROWSERS-IN-QUERY-frameDefault}
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

