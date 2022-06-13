&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
using Progress.Json.ObjectModel.JsonObject from propath.
using Progress.Json.ObjectModel.ObjectModelParser from propath.
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

{thealth/reajuste-planos-saude/api/api-reajuste-plano.i}

/* Parameters Definitions ---                                           */

define input        parameter in-modalidade     as   integer    no-undo.
define input        parameter in-termo          as   integer    no-undo.
define input-output parameter table             for  temp-contrato.

/* Local Variable Definitions ---                                       */

define variable hd-api                              as   handle     no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frameDialog
&Scoped-define BROWSE-NAME browseHistorico

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-historico

/* Definitions for BROWSE browseHistorico                               */
&Scoped-define FIELDS-IN-QUERY-browseHistorico temp-historico.in-modalidade temp-historico.in-termo temp-historico.in-quantidade-parcelas temp-historico.dc-valor-cobrado temp-historico.ch-periodo-reajuste temp-historico.ch-origem-historico temp-historico.ch-usuario temp-historico.dt-ocorrencia   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browseHistorico   
&Scoped-define SELF-NAME browseHistorico
&Scoped-define QUERY-STRING-browseHistorico FOR EACH temp-historico
&Scoped-define OPEN-QUERY-browseHistorico OPEN QUERY {&SELF-NAME} FOR EACH temp-historico.
&Scoped-define TABLES-IN-QUERY-browseHistorico temp-historico
&Scoped-define FIRST-TABLE-IN-QUERY-browseHistorico temp-historico


/* Definitions for FRAME frameCorpo                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frameCorpo ~
    ~{&OPEN-QUERY-browseHistorico}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 textContrato textContratante ~
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

define rectangle RECT-2
     edge-pixels 2 graphic-edge  no-fill   
     size 129 by 2.62.

define button buttonExportar 
     image-up file "thealth/assets/import_18_18.jpg":U
     label "Exportar" 
     size 5.6 by 1.43 tooltip "Exportar".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
define query browseHistorico for 
      temp-historico scrolling.
&ANALYZE-RESUME

/* Browse definitions                                                   */
define browse browseHistorico
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browseHistorico frameDialog _FREEFORM
  query browseHistorico display
      temp-historico.in-modalidade
      temp-historico.in-termo
      temp-historico.in-quantidade-parcelas
      temp-historico.dc-valor-cobrado
      temp-historico.ch-periodo-reajuste      
      temp-historico.ch-origem-historico
      temp-historico.ch-usuario 
      temp-historico.dt-ocorrencia
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 122 BY 14.29
         FONT 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

define frame frameDialog
     textContrato at row 1.48 col 14 colon-aligned widget-id 12
     textContratante at row 1.48 col 59 colon-aligned widget-id 10
     textPercentualReaj at row 2.67 col 59 colon-aligned widget-id 8
     textPeriodoReaj at row 2.67 col 90 colon-aligned widget-id 14
     buttonSair at row 20.48 col 116
     RECT-2 at row 1.24 col 2 widget-id 16
     space(1.19) skip(17.89)
    with view-as dialog-box keep-tab-order 
         side-labels no-underline three-d  scrollable 
         bgcolor 15 font 1
         title "<insert dialog title>"
         cancel-button buttonSair widget-id 100.

define frame frameCorpo
     browseHistorico at row 1.95 col 1 widget-id 200
     buttonExportar at row 1.95 col 123 widget-id 4
    with 1 down keep-tab-order overlay 
         side-labels no-underline three-d 
         at col 2 row 3.91
         size 129 by 16.43
         bgcolor 15 font 1
         title "Registros" widget-id 300.


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
assign frame frameCorpo:FRAME = frame frameDialog:HANDLE.

/* SETTINGS FOR FRAME frameCorpo
                                                                        */
/* BROWSE-TAB browseHistorico 1 frameCorpo */
/* SETTINGS FOR DIALOG-BOX frameDialog
   FRAME-NAME                                                           */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browseHistorico
/* Query rebuild information for BROWSE browseHistorico
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-historico.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browseHistorico */
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


&Scoped-define BROWSE-NAME browseHistorico
&Scoped-define FRAME-NAME frameCorpo
&Scoped-define SELF-NAME browseHistorico
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browseHistorico frameDialog
on value-changed of browseHistorico in frame frameCorpo
do:
    
    assign buttonExportar:sensitive in frame frameCorpo = available temp-historico and temp-historico.ch-origem-historico   = ORIGEM_HISTORICO_GERAR_EVENTO.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME buttonExportar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonExportar frameDialog
on choose of buttonExportar in frame frameCorpo /* Exportar */
do:
    run acaoExportar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frameDialog
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoExportar frameDialog 
procedure acaoExportar private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable lo-detalhes             as   longchar   no-undo.
    define variable lg-confirmar            as   logical    no-undo.
    define variable ch-nome-arquivo         as   character  no-undo.
    define variable ch-caminho-completo     as   character  no-undo.
    
    if not available temp-historico
    then return.
    
    do transaction on error undo, return:
        
        assign ch-nome-arquivo  = substitute ("detalhe_contrato_&1_&2.json", 
                                              temp-historico.in-modalidade,
                                              temp-historico.in-termo).
        
        run thealth/libs/gerar-arquivo.w (input  session:temp-directory,
                                          input  ch-nome-arquivo,
                                          input  yes,
                                          output lg-confirmar,
                                          output ch-caminho-completo).
                                          
        if not lg-confirmar
        then return.
        
        run buscarDetalhamentoHistorico in hd-api (input  temp-historico.in-id-historico,
                                                   output lo-detalhes).
                                                   
        define variable jObj-detalhes   as   JsonObject         no-undo.
        define variable jObj-parser     as   ObjectModelParser  no-undo.
        
        assign jObj-detalhes    = new JsonObject ()  
               jObj-parser      = new ObjectModelParser ()
               .
        
        assign jObj-detalhes = cast (jObj-parser:parse (lo-detalhes), JsonObject).
                  
        jObj-detalhes:write (lo-detalhes, yes).                  
        
        copy-lob lo-detalhes to file ch-caminho-completo.
        
        message substitute ('Arquivo gerado com sucesso em &1', ch-caminho-completo)
        view-as alert-box information buttons ok.                                                           
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
  hide frame frameCorpo.
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
  enable RECT-2 textContrato textContratante textPercentualReaj textPeriodoReaj 
         buttonSair 
      with frame frameDialog.
  view frame frameDialog.
  {&OPEN-BROWSERS-IN-QUERY-frameDialog}
  enable browseHistorico buttonExportar 
      with frame frameCorpo.
  {&OPEN-BROWSERS-IN-QUERY-frameCorpo}
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inicializarInterface frameDialog 
procedure inicializarInterface private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
    do on error undo, return:
        
        find first temp-contrato
             where temp-contrato.in-modalidade  = in-modalidade
               and temp-contrato.in-termo       = in-termo
                   .
                   
        assign textContrato:screen-value in frame frameDialog   = substitute ('&1/&2',
                                                                              in-modalidade,
                                                                              in-termo)
               textContratante:screen-value                     = temp-contrato.ch-contratante
               textPeriodoReaj:screen-value                     = temp-contrato.ch-ultimo-reajuste
               textPercentualReaj:screen-value                  = substitute ("&1 %", temp-contrato.ch-ultimo-reajuste)
               frame frameDialog:title                          = substitute ('Hist¢rico do contrato &1/&2', in-modalidade, in-termo)
               .
        
        run thealth/reajuste-planos-saude/api/api-reajuste-plano.p persistent set hd-api.
        
        empty temp-table temp-historico.
        
        subscribe to EV_API_REAJUSTE_PLANO_CONSULTAR in hd-api run-procedure 'eventoApi'.
        
        run buscarHistoricoContrato in hd-api (input              in-modalidade,
                                               input              in-termo,
                                               input-output table temp-historico by-reference).
                                               
        query browseHistorico:query-prepare ('preselect each temp-historico by temp-historico.dt-ocorrencia').
        query browseHistorico:query-open.                                                
        
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao abrir o hist¢rico.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao abrir o hist¢rico.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
    end.
    
 
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

