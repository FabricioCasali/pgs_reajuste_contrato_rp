&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME winMain
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS winMain 
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
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/
block-level on error undo, throw.

using Progress.Lang.AppError from propath.

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
  
create widget-pool.

/* ***************************  Definitions  ************************** */

{thealth/libs/color-template.i}
{thealth/libs/exportar-excel.i}
{thealth/libs/status-processamento.i}
{thealth/reajuste-planos-saude/api/api-reajuste-plano.i}
{thealth/reajuste-planos-saude/interface/reajuste-plano.i}
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable lo-configuracao-browse      as   longchar   no-undo.
define variable hd-status                   as   handle     no-undo.
define variable hd-api                      as   handle     no-undo.
define variable hd-api-config               as   handle     no-undo.


define new global shared variable v_cod_usuar_corren as character
                          format "x(12)":U label "Usu rio Corrente"
                                        column-label "Usu rio Corrente" no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frameDefault
&Scoped-define BROWSE-NAME browseDados

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-contrato

/* Definitions for BROWSE browseDados                                   */
&Scoped-define FIELDS-IN-QUERY-browseDados temp-contrato.lg-marcado temp-contrato.in-modalidade temp-contrato.in-termo temp-contrato.in-proposta temp-contrato.ch-ultimo-reajuste temp-contrato.dc-percentual-ultimo-reajuste temp-contrato.ch-ultimo-faturamento temp-contrato.dc-contratante temp-contrato.dc-contratante-origem temp-contrato.ch-contratante temp-contrato.ch-contratante-origem temp-contrato.in-quantidade-parcelas temp-contrato.in-quantidade-parcelas-usuario temp-contrato.lg-possui-reajuste-ano-ref temp-contrato.lg-eventos-gerados temp-contrato.ch-usuario-evento temp-contrato.dt-geracao-evento   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browseDados temp-contrato.lg-marcado   
&Scoped-define ENABLED-TABLES-IN-QUERY-browseDados temp-contrato
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-browseDados temp-contrato
&Scoped-define SELF-NAME browseDados
&Scoped-define QUERY-STRING-browseDados FOR EACH temp-contrato
&Scoped-define OPEN-QUERY-browseDados OPEN QUERY {&SELF-NAME} FOR EACH temp-contrato.
&Scoped-define TABLES-IN-QUERY-browseDados temp-contrato
&Scoped-define FIRST-TABLE-IN-QUERY-browseDados temp-contrato


/* Definitions for FRAME frameCorpo                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frameCorpo ~
    ~{&OPEN-QUERY-browseDados}

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
define var winMain as widget-handle no-undo.

/* Definitions of the field level widgets                               */
define button buttonAgendarEventos 
     image-up file "thealth/assets/calendar_24_24.jpg":U no-focus flat-button
     label "" 
     size 7.2 by 1.71 tooltip "Agendar eventos".

define button buttonBrowseLimpar 
     image-up file "thealth/assets/cancel_18_18.jpg":U no-focus flat-button
     label "Button 3" 
     size 3.6 by .95.

define button buttonConfigBrowse 
     image-up file "thealth/assets/settings_18_18.jpg":U no-focus flat-button
     label "" 
     size 3.6 by .95.

define button buttonDetalhar 
     image-up file "thealth/assets/detail_24_24.jpg":U no-focus flat-button
     label "Detalhar" 
     size 7.2 by 1.71 tooltip "Detalhar".

define button buttonEditarParcelas 
     image-up file "thealth/assets/edit_24_24.jpg":U no-focus flat-button
     label "" 
     size 7.2 by 1.71 tooltip "Editar parcelas".

define button buttonElimininarEventos 
     image-up file "thealth/assets/cancel_24_24.jpg":U no-focus flat-button
     label "" 
     size 7.2 by 1.71 tooltip "Eliminar eventos".

define button buttonExpotar 
     image-up file "thealth/assets/excel_24_24.jpg":U no-focus flat-button
     label "" 
     size 7.2 by 1.71 tooltip "Exportar".

define button buttonHistorico 
     image-up file "thealth/assets/history_24_24.jpg":U no-focus flat-button
     label "" 
     size 7.2 by 1.71 tooltip "Historico".

define button buttonParametros 
     image-up file "thealth/assets/process2_24_24.jpg":U no-focus flat-button
     label "" 
     size 7.2 by 1.71 tooltip "Parâmetros".

define button buttonTrocarContrato 
     image-up file "thealth/assets/transfer_24_24.jpg":U no-focus flat-button
     label "" 
     size 7.2 by 1.71 tooltip "Trocar contrato".

define variable radioEdicaoBrowse as integer 
     view-as radio-set horizontal
     radio-buttons 
          "Ordenar", 1,
"Editar", 2
     size 30 by .71
     bgcolor 15  no-undo.

define variable checkMarcarTodos as logical initial no 
     label "" 
     view-as toggle-box
     size 2.6 by .81 no-undo.

define variable checkOcultarSemReajuste as logical initial yes 
     label "Ocultar contratos sem reajuste" 
     view-as toggle-box
     size 40 by .81 no-undo.

define button buttonSair 
     label "Sai&r" 
     size 15 by 1.14.

define button buttonPesquisar 
     image-up file "thealth/assets/search_36_36.jpg":U no-focus flat-button
     label "Pesquisar" 
     size 11 by 2.38.

define variable comboTipoPessoa as character format "X(256)":U 
     label "Tipo pessoa" 
     view-as combo-box inner-lines 5
     list-item-pairs "Ambas","1",
                     "Física","2",
                     "Jurídica","3"
     drop-down-list
     size 33 by 1 no-undo.

define variable textContratanteFim as decimal format "999999999":U initial 999999999 
     label "até" 
     view-as fill-in 
     size 14 by 1 no-undo.

define variable textContratanteIni as decimal format "999999999":U initial 0 
     label "Contratante" 
     view-as fill-in 
     size 14 by 1 no-undo.

define variable textConvenioFim as integer format "999":U initial 999 
     label "até" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textConvenioIni as integer format "999":U initial 0 
     label "Convenio" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textFormaPagtoFim as integer format "99":U initial 99 
     label "até" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textFormaPagtoIni as integer format "99":U initial 0 
     label "Forma pagto" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textModalidadeFim as integer format "99":U initial 99 
     label "até" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textModalidadeIni as integer format "99":U initial 0 
     label "Modalidade" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textPeriodoFat as character format "99/9999":U initial "111111" 
     label "Periodo fat" 
     view-as fill-in 
     size 14 by 1 no-undo.

define variable textPeriodoReajuste as character format "99/9999":U initial "111111" 
     label "Periodo reajuste" 
     view-as fill-in 
     size 14 by 1 no-undo.

define variable textPlanoFim as integer format "99":U initial 99 
     label "até" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textPlanoIni as integer format "99":U initial 0 
     label "Plano" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textTermoFim as decimal format "9999999":U initial 9999999 
     label "até" 
     view-as fill-in 
     size 14 by 1 no-undo.

define variable textTermoIni as decimal format "9999999":U initial 0 
     label "Termo" 
     view-as fill-in 
     size 14 by 1 no-undo.

define variable textTipoPlanoFim as integer format "99":U initial 99 
     label "até" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define variable textTipoPlanoIni as integer format "99":U initial 0 
     label "Tipo Plano" 
     view-as fill-in 
     size 5.8 by 1 no-undo.

define rectangle RECT-1
     edge-pixels 2 graphic-edge  no-fill   
     size 139 by 5.71.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
define query browseDados for 
      temp-contrato scrolling.
&ANALYZE-RESUME

/* Browse definitions                                                   */
define browse browseDados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browseDados winMain _FREEFORM
  query browseDados display
      temp-contrato.lg-marcado                  column-label '  ' view-as toggle-box 
      temp-contrato.in-modalidade                     
    temp-contrato.in-termo                          
    temp-contrato.in-proposta                        
    temp-contrato.ch-ultimo-reajuste           
          
    temp-contrato.dc-percentual-ultimo-reajuste     
    temp-contrato.ch-ultimo-faturamento             
    temp-contrato.dc-contratante                    
    temp-contrato.dc-contratante-origem             
    temp-contrato.ch-contratante                     
    temp-contrato.ch-contratante-origem
    temp-contrato.in-quantidade-parcelas
    temp-contrato.in-quantidade-parcelas-usuario                     
    temp-contrato.lg-possui-reajuste-ano-ref    view-as toggle-box
    temp-contrato.lg-eventos-gerados            view-as toggle-box
    temp-contrato.ch-usuario-evento             
    temp-contrato.dt-geracao-evento 
    enable 
        temp-contrato.lg-marcado
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 13.57
         FONT 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

define frame frameDefault
    with 1 down no-box keep-tab-order overlay 
         side-labels no-underline three-d 
         at col 1 row 1
         size 140.6 by 23.91
         bgcolor 15 font 1 widget-id 100.

define frame frameRodape
     buttonSair at row 1.24 col 124.8 widget-id 2
    with 1 down no-box keep-tab-order overlay 
         side-labels no-underline three-d 
         at col 2 row 23.14
         size 139 by 1.67
         bgcolor 15 font 1 widget-id 400.

define frame frameSuperior
     buttonPesquisar at row 1.48 col 128 widget-id 32
     textModalidadeIni at row 1.71 col 15 colon-aligned widget-id 2
     textModalidadeFim at row 1.71 col 26 colon-aligned widget-id 4
     textPlanoIni at row 2.91 col 15 colon-aligned widget-id 8
     textPlanoFim at row 2.91 col 26 colon-aligned widget-id 6
     textTipoPlanoIni at row 4.1 col 15 colon-aligned widget-id 12
     textTipoPlanoFim at row 4.1 col 26 colon-aligned widget-id 10
     textFormaPagtoIni at row 5.29 col 15 colon-aligned widget-id 36
     textFormaPagtoFim at row 5.29 col 26 colon-aligned widget-id 38
     textTermoIni at row 1.71 col 45 colon-aligned widget-id 18
     textTermoFim at row 1.71 col 64 colon-aligned widget-id 20
     textContratanteIni at row 2.91 col 45 colon-aligned widget-id 14
     textContratanteFim at row 2.91 col 64 colon-aligned widget-id 16
     textConvenioIni at row 4.1 col 45 colon-aligned widget-id 40
     textConvenioFim at row 4.1 col 64 colon-aligned widget-id 42
     comboTipoPessoa at row 5.29 col 45 colon-aligned widget-id 30
     textPeriodoFat at row 1.48 col 97 colon-aligned widget-id 46
     textPeriodoReajuste at row 2.67 col 97 colon-aligned widget-id 48
     RECT-1 at row 1.24 col 2 widget-id 34
    with 1 down no-box keep-tab-order overlay 
         side-labels no-underline three-d 
         at col 1.2 row 1
         size 140 by 6.19
         bgcolor 15 font 1 widget-id 200.

define frame frameCorpo
     checkOcultarSemReajuste at row 1.05 col 55 widget-id 50
     buttonTrocarContrato at row 8.81 col 132.2 widget-id 60
     radioEdicaoBrowse at row 1.14 col 101.6 no-label widget-id 12
     browseDados at row 2.19 col 1 widget-id 500
     checkMarcarTodos at row 2.24 col 1.6 widget-id 34
     buttonEditarParcelas at row 5.48 col 132.2 widget-id 58
     buttonAgendarEventos at row 7.14 col 132.2 widget-id 32
     buttonDetalhar at row 3.81 col 132.2 widget-id 30
     buttonElimininarEventos at row 12.14 col 132.2 widget-id 52
     buttonExpotar at row 10.48 col 132.2 widget-id 36
     buttonHistorico at row 13.81 col 132.2 widget-id 54
     buttonParametros at row 2.14 col 132.2 widget-id 28
     buttonBrowseLimpar at row 1 col 133.2 widget-id 24
     buttonConfigBrowse at row 1 col 136 widget-id 26
    with 1 down keep-tab-order overlay 
         side-labels no-underline three-d 
         at col 2 row 7.19
         size 139 by 15.76
         bgcolor 15 font 1
         title "" widget-id 300.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
if session:display-type = "GUI":U then
  create window winMain assign
         hidden             = yes
         title              = "<insert window title>"
         height             = 23.91
         width              = 140.6
         max-height         = 27.57
         max-width          = 169.6
         virtual-height     = 27.57
         virtual-width      = 169.6
         resize             = yes
         scroll-bars        = no
         status-area        = no
         bgcolor            = ?
         fgcolor            = ?
         keep-frame-z-order = yes
         three-d            = yes
         message-area       = no
         sensitive          = yes.
else {&WINDOW-NAME} = current-window.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW winMain
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
assign frame frameCorpo:FRAME = frame frameDefault:HANDLE
       frame frameRodape:FRAME = frame frameDefault:HANDLE
       frame frameSuperior:FRAME = frame frameDefault:HANDLE.

/* SETTINGS FOR FRAME frameCorpo
                                                                        */
/* BROWSE-TAB browseDados radioEdicaoBrowse frameCorpo */
assign 
       browseDados:ALLOW-COLUMN-SEARCHING in frame frameCorpo = true.

assign 
       buttonEditarParcelas:HIDDEN in frame frameCorpo           = true.

assign 
       buttonTrocarContrato:HIDDEN in frame frameCorpo           = true.

/* SETTINGS FOR FRAME frameDefault
   FRAME-NAME                                                           */

define variable XXTABVALXX as logical no-undo.

assign XXTABVALXX = frame frameCorpo:MOVE-BEFORE-TAB-ITEM (frame frameRodape:HANDLE)
       XXTABVALXX = frame frameSuperior:MOVE-BEFORE-TAB-ITEM (frame frameCorpo:HANDLE)
/* END-ASSIGN-TABS */.

/* SETTINGS FOR FRAME frameRodape
                                                                        */
/* SETTINGS FOR FRAME frameSuperior
   Custom                                                               */
if session:display-type = "GUI":U and VALID-HANDLE(winMain)
then winMain:hidden = no.

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

&Scoped-define SELF-NAME winMain
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winMain winMain
on end-error of winMain /* <insert window title> */
or endkey of {&WINDOW-NAME} anywhere do:
        /* This case occurs when the user presses the "Esc" key.
           In a persistently run window, just ignore this.  If we did not, the
           application would exit. */
        if this-procedure:persistent then return no-apply.
    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL winMain winMain
on window-close of winMain /* <insert window title> */
do:
    define variable lg-confirmar-sair           as   logical    no-undo.
     
    message 'Confirma fechar o programa?'
    view-as alert-box question buttons yes-no update lg-confirmar-sair.
    
    if not lg-confirmar-sair     
    then return no-apply. 
    
    if  valid-handle (hd-api-config)
    and lo-configuracao-browse <> ?  
    then do:
        
        run salvarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano-consultar",
                                              input  v_cod_usuar_corren,
                                              input  PARAM_LAYOUT_BROWSE,
                                              input  string (lo-configuracao-browse)) no-error. 
    end.
    
    /* This event will close the window and terminate the procedure.  */
    apply "CLOSE":U to this-procedure.
    return no-apply. 
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browseDados
&Scoped-define FRAME-NAME frameCorpo
&Scoped-define SELF-NAME browseDados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browseDados winMain
on any-key of browseDados in frame frameCorpo
do:
    if not available temp-contrato
    then return.
    
    if lastkey = 32
    or lastkey = 13
    then do:
        
        assign temp-contrato.lg-marcado = not temp-contrato.lg-marcado.        
        browse browseDados:refresh () no-error. 
    end.   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browseDados winMain
on left-mouse-dblclick of browseDados in frame frameCorpo
do: 
    run acaoDetalhar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browseDados winMain
on row-display of browseDados in frame frameCorpo
do:
    
    if temp-contrato.lg-eventos-gerados
    then do:
        run alterarCorLinhaBrowseDados (COLOR-SUCCESS).
        return .
    end.
    
    if not temp-contrato.lg-possui-reajuste-ano-ref 
    then do:
        
        run alterarCorLinhaBrowseDados (COLOR-DISABLED).
    end.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browseDados winMain
on value-changed of browseDados in frame frameCorpo
do:
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonAgendarEventos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonAgendarEventos winMain
on choose of buttonAgendarEventos in frame frameCorpo
do:
    run acaoGerarEventos.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonDetalhar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonDetalhar winMain
on choose of buttonDetalhar in frame frameCorpo /* Detalhar */
do:
    run acaoDetalhar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonEditarParcelas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonEditarParcelas winMain
on choose of buttonEditarParcelas in frame frameCorpo
do:
    run acaoAlterarParcelas.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonElimininarEventos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonElimininarEventos winMain
on choose of buttonElimininarEventos in frame frameCorpo
do:
    run acaoEliminar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonExpotar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonExpotar winMain
on choose of buttonExpotar in frame frameCorpo
do:
    run acaoExportar.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonHistorico
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonHistorico winMain
on choose of buttonHistorico in frame frameCorpo
do:
    run acaoHistorico.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buttonParametros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonParametros winMain
on choose of buttonParametros in frame frameCorpo
do:
    run acaoMostrarParametros.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frameRodape
&Scoped-define SELF-NAME buttonSair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonSair winMain
on choose of buttonSair in frame frameRodape /* Sair */
do:
    apply 'window-close' to winMain.         
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frameCorpo
&Scoped-define SELF-NAME buttonTrocarContrato
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buttonTrocarContrato winMain
on choose of buttonTrocarContrato in frame frameCorpo
do:
    run acaoTrocarContrato.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME checkMarcarTodos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL checkMarcarTodos winMain
on value-changed of checkMarcarTodos in frame frameCorpo
do:
    run acaoMarcarTodos.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME checkOcultarSemReajuste
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL checkOcultarSemReajuste winMain
on value-changed of checkOcultarSemReajuste in frame frameCorpo /* Ocultar contratos sem reajuste */
do:
    
    run acaoAtualizarFiltro.  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frameDefault
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK winMain 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
assign CURRENT-WINDOW                = {&WINDOW-NAME}  
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.
       
{thealth/libs/configurar-browse-eventos.i &browse="browseDados"    
                                          &temp="temp-contrato"
                                          &jsonConfig="lo-configuracao-browse"  
                                          &config="buttonConfigBrowse"      
                                          &limpar="buttonBrowseLimpar"
                                          &modo="radioEdicaoBrowse"
                                          &titulo="Contratos" 
                                          &pesquisar="buttonPesquisar"
                                          &procedPesquisa="acaoPesquisar"}

{thealth/libs/resize.i &FRAME_PADRAO="frameDefault"}       
       

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
on close of this-procedure 
    run disable_UI.

/* Best default for GUI applications is...                              */
pause 0 before-hide.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK:
    run enable_UI.
    run initializarInterface.
    if not this-procedure:persistent then  
        wait-for close of this-procedure.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoAlterarParcelas winMain 
procedure acaoAlterarParcelas private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable in-parcelas             as   integer    no-undo.
    define variable in-contratos            as   integer    no-undo.
    define variable lg-confirmar            as   logical    no-undo.
    

    for each temp-contrato
       where temp-contrato.lg-marcado:
           
        assign in-contratos = in-contratos + 1.           
    end. 
    
    if in-contratos = 0
    then do:
        
        message 'Marque ao menos um contrato para alterar a quantidade de parcelas'
        view-as alert-box.
        return.
    end.
    
    if in-contratos > 0
    then do:
        
        message substitute ("Confirmar alterar &1 contrato&2?", in-contratos, if in-contratos = 1 then '' else 's') view-as alert-box button yes-no update lg-confirmar.
        
        if not lg-confirmar
        then do:
            return.            
        end. 
    end.

    do on error undo, return:
        
        find first temp-contrato
             where temp-contrato.lg-marcado = yes
                   .
        
        assign in-parcelas  = temp-contrato.in-quantidade-parcelas.
        
        if temp-contrato.in-quantidade-parcelas-usuario > 0
        then do:
            
            assign in-parcelas  = temp-contrato.in-quantidade-parcelas-usuario.
        end.
        
        run thealth/reajuste-planos-saude/interface/reajuste-plano-editar.w (input-output in-parcelas).
        
        for each temp-contrato
           where temp-contrato.lg-marcado:
               
            assign temp-contrato.in-quantidade-parcelas-usuario = in-parcelas.
                  
            run buscarFaturamentoContrato in hd-api (input              temp-contrato.in-modalidade,
                                                     input              temp-contrato.in-termo,
                                                     input              integer (substring (textPeriodoReajuste:screen-value in frame frameSuperior, 4, 4)),
                                                     input              integer (substring (textPeriodoReajuste:screen-value, 1, 2)),
                                                     input              integer (substring (textPeriodoFat:screen-value, 4, 4)),
                                                     input              integer (substring (textPeriodoFat:screen-value, 1, 2)),
                                                     input-output table temp-contrato by-reference,
                                                     input-output table temp-valor-beneficiario by-reference,
                                                     input-output table temp-valor-beneficiario-mes by-reference,
                                                     input-output table temp-valor-faturado-mes by-reference).
        end.
        
        message substitute ('Atualizado a quantidade de parcelas de &1 contrato&2',
                            in-contratos,
                            if in-contratos = 1 then '' else 's')
        view-as alert-box. 
                                                 
        browse browseDados:refresh().                                                 

    end.
 
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoAtualizarFiltro winMain 
procedure acaoAtualizarFiltro private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable ch-query            as   character  no-undo.
    
    assign ch-query = 'preselect each temp-contrato'.
    
    if checkOcultarSemReajuste:checked in frame frameCorpo 
    then do:
        
        assign ch-query = ch-query + ' where temp-contrato.lg-possui-reajuste-ano-ref'.
    end.
    
    run registrarQueryDefaultBrowseDados (ch-query).

    query browseDados:query-prepare (ch-query).
    query browseDados:query-open (). 
    
    run reiniciarDados in hd-browse-browseDados.
    run gerarJsonConfiguracaoBrowse in hd-browse-browseDados (output lo-configuracao-browse).
    

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoDetalhar winMain 
procedure acaoDetalhar private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    if not available temp-contrato
    then return.
    
    do on error undo, return:
        
        run thealth/reajuste-planos-saude/interface/reajuste-plano-detalhar.w (input              temp-contrato.in-modalidade,
                                                                               input              temp-contrato.in-termo,
                                                                               input-output table temp-contrato,
                                                                               input-output table temp-valor-beneficiario).
                                       
        catch cs-erro as Progress.Lang.Error :
            
            message substitute ("Ops...~nOcorreu um erro ao detalhar um contrato.~nInforme a TI com um print desta mensagem.~n&1",
                                cs-erro:GetMessage(1))
            view-as alert-box error buttons ok.
            undo, return.
        end catch.
        finally:
            
        end finally.
    end. 

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoEliminar winMain 
procedure acaoEliminar private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable in-conta            as   integer    no-undo.
    define variable lg-confirmar        as   logical    no-undo.
    
    do transaction on error undo, return:
        
        
        for each temp-contrato
           where temp-contrato.lg-marcado
             and temp-contrato.lg-eventos-gerados:
            
            assign in-conta = in-conta + 1.                             
        end.                 
        
        if in-conta = 0
        then do:
            
            message 'Selecione ao menos um contrato com eventos gerados para cancelar'
            view-as alert-box information buttons ok.
            return. 
        end.
        
        message substitute ('Confirma remover os eventos gerados para &1 contrato&2?',
                            in-conta,
                            if in-conta = 1 then '' else 's')
        view-as alert-box question buttons yes-no update lg-confirmar.
        
        if not lg-confirmar
        then return.
        
        subscribe to EV_API_REAJUSTE_PLANO_ELIMINAR_EVENTO in hd-api run-procedure 'eventoApiEliminar'.
        
        if not valid-handle (hd-status)
        then do:
            
            run thealth/libs/status-processamento.w persistent set hd-status (input  'Eliminando eventos',
                                                                              input  no).
        end.
                                                                          
        run eliminarEventos in hd-api (input  table temp-contrato by-reference).
        
        message 'Eventos removidos com sucesso'
        view-as alert-box information button ok.
        
        apply 'choose' to buttonPesquisar in frame frameSuperior.
                                                                          
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao eliminar os eventos.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao eliminar os eventos.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.                                                                          
        finally:
            
            delete object hd-status no-error.
            unsubscribe to EV_API_REAJUSTE_PLANO_ELIMINAR_EVENTO in hd-api.
        end.
        
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoExportar winMain 
procedure acaoExportar private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable hd-exportar             as   handle     no-undo.
    define variable ch-nome-arquivo         as   character  no-undo.
    define variable ch-caminho-completo     as   character  no-undo.
    define variable lg-confirmou            as   logical    no-undo.
    
    do on error undo, return:
        
        find first temp-contrato no-error.
        
        
        if not available temp-contrato
        then do:
            
            message 'Sem dados para exportar'
            view-as alert-box information buttons ok.
            return.
        end.
        
        assign ch-nome-arquivo  = substitute ("dados_reajuste_contratos_&1.xlsx",
                                              replace (replace (replace (string (now, '99/99/9999 HH:MM:SS'), ' ', ''), '/', ''), ':', ''))
               .           

        run thealth/libs/gerar-arquivo.w (input  session:temp-directory,
                                          input  ch-nome-arquivo,     
                                          input  yes,  
                                          output lg-confirmou,
                                          output ch-caminho-completo).        
                   
        if not lg-confirmou
        then return.         
                
        run thealth/libs/status-processamento.w persistent set hd-status (input  "Exportando", no).
        
        empty temp-table temp-exportar.  
        
        for each temp-contrato:
            
            log-manager:write-message (substitute ("lendo contrato &1/&2", temp-contrato.in-modalidade, temp-contrato.in-termo), "DEBUG") no-error.                 
            
            if not can-find (first temp-valor-beneficiario
                             where temp-valor-beneficiario.in-modalidade  = temp-contrato.in-modalidade
                               and temp-valor-beneficiario.in-termo       = temp-contrato.in-termo)
            then do:
                
                run mostrarMensagem in hd-status (input  substitute ('Buscando detalhes do contrato &1/&2',
                                                                     temp-contrato.in-modalidade,
                                                                     temp-contrato.in-termo))
                    . 
                
                run buscarFaturamentoContrato in hd-api (input        temp-contrato.in-modalidade,
                                                         input        temp-contrato.in-termo,
                                                         input        integer (substring (temp-contrato.ch-ultimo-reajuste, 4, 4)),
                                                         input        integer (substring (temp-contrato.ch-ultimo-reajuste, 1, 2)),
                                                         input        integer (substring (textPeriodoFat:screen-value in frame frameSuperior, 4, 4)),
                                                         input        integer (substring (textPeriodoFat:screen-value, 1, 2)),
                                                         input-output table temp-contrato by-reference,
                                                         input-output table temp-valor-beneficiario by-reference,
                                                         input-output table temp-valor-beneficiario-mes by-reference,
                                                         input-output table temp-valor-faturado-mes by-reference)
                                                         .
            end.                                                         
                                                         
            for each temp-valor-beneficiario
               where temp-valor-beneficiario.in-modalidade  = temp-contrato.in-modalidade
                 and temp-valor-beneficiario.in-termo       = temp-contrato.in-termo
            break by temp-valor-beneficiario.in-usuario:
    
                run mostrarMensagem in hd-status (input  substitute ('Formatando dados do benefici rio &1/&2/&3',
                                                                     temp-valor-beneficiario.in-modalidade,
                                                                     temp-valor-beneficiario.in-termo,
                                                                     temp-valor-beneficiario.in-usuario)).                             
                process events.
                
                if first-of (temp-valor-beneficiario.in-usuario)
                then do:
                    
                    log-manager:write-message (substitute ("criando temp-exportar do contrato &1/&2", temp-contrato.in-modalidade, temp-contrato.in-termo), "DEBUG") no-error.
                    create temp-exportar.
                    buffer-copy temp-contrato to temp-exportar.
                    buffer-copy temp-valor-beneficiario 
                         except temp-valor-beneficiario.in-quantidade-parcelas
                                temp-valor-beneficiario.dc-valor-cobrar
                             to temp-exportar.
                end.
     
                assign temp-exportar.dc-valor-total-cobrar  = temp-exportar.dc-valor-total-cobrar + 
                                                              temp-valor-beneficiario.dc-valor-cobrar
                       temp-exportar.in-quantidade-parcelas = temp-exportar.in-quantidade-parcelas + 
                                                              temp-valor-beneficiario.in-quantidade-parcelas            
                       .
            end.            
        end.
        
        run thealth/libs/exportar-excel.p persistent set hd-exportar.
         
        subscribe to EV_EXPORTAR_EXCEL_LINHA in hd-exportar run-procedure 'eventoExportar'.
               
        run exportarExcel in hd-exportar (input  ch-caminho-completo,
                                          input  buffer temp-exportar:handle).
         
        message substitute ('Planilha gerada em &1',
                            ch-caminho-completo)
        view-as alert-box information buttons ok.    
        
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao exportar.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do: 
            
                message substitute ("Ops...~nOcorreu um erro ao exportar.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
        finally:
            
            if valid-handle (hd-exportar)
            then do:
                
                unsubscribe to EV_EXPORTAR_EXCEL_LINHA in hd-exportar.
                delete object hd-exportar no-error.
            end.
            
            delete object hd-status no-error.
        end.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoGerarEventos winMain 
procedure acaoGerarEventos private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define variable lg-confirmar            as   logical    no-undo.
    define variable in-ano-fat              as   integer    no-undo.
    define variable in-mes-fat              as   integer    no-undo.
    define variable in-conta                as   integer    no-undo.

    define buffer buf-temp-contrato         for  temp-contrato.

    find first temp-contrato
         where temp-contrato.lg-marcado
           and temp-contrato.lg-possui-reajuste-ano-ref
           and temp-contrato.lg-eventos-gerados         = no
               no-error.
               
    if not available temp-contrato
    then do:
        
        message substitute ('Selecione ao menos um contrato que possua reajuste na competˆncia &1 para gerar os eventos',
                            textPeriodoReajuste:screen-value in frame frameSuperior)
        view-as alert-box information buttons ok.
        return.
    end.               
        
    for each buf-temp-contrato
       where buf-temp-contrato.lg-marcado                   = yes
         and buf-temp-contrato.lg-possui-reajuste-ano-ref   = yes
         and buf-temp-contrato.lg-eventos-gerados           = no:   
             
        assign in-conta = in-conta + 1.
    end.             
    
    message substitute ('Confirma iniciar a gera‡Æo dos eventos para &1 contrato&2 selecionado&3?',
                        in-conta,
                        if in-conta =  1 then '' else 's')
    view-as alert-box question buttons yes-no update lg-confirmar.
    
    if not lg-confirmar 
    then return.
    
    do on error undo, return:
        

        subscribe to EV_API_REAJUSTE_PLANO_CRIAR_EVENTO in hd-api run-procedure 'eventoApiCriar'.

        run thealth/libs/status-processamento.w persistent set hd-status (input  'Criando eventos', 
                                                                          input  no).

        
        assign in-ano-fat   = integer (substring (textPeriodoFat:screen-value, 4, 4))
               in-mes-fat   = integer (substring (textPeriodoFat:screen-value, 1, 2)) 
               .
                                                                               
        run criarEventosContratos in hd-api (input              in-ano-fat,
                                             input              in-mes-fat,
                                             input              textPeriodoReajuste:screen-value,
                                             input-output table temp-contrato by-reference,
                                             input-output table temp-valor-beneficiario by-reference,
                                             input-output table temp-valor-beneficiario-mes by-reference)
            . 
            
        message 'Eventos gerados com sucesso'
        view-as alert-box information buttons ok.            
                 
        apply 'choose' to buttonPesquisar in frame frameSuperior.

        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao criar os eventos.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao criar os eventos.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
        finally:
            unsubscribe to EV_API_REAJUSTE_PLANO_CRIAR_EVENTO in hd-api.
            delete object hd-status no-error.    
        end finally.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoHistorico winMain 
procedure acaoHistorico private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    do on error undo, return:
        
        run thealth/reajuste-planos-saude/interface/reajuste-plano-historico.w (input              temp-contrato.in-modalidade,
                                                                                input              temp-contrato.in-termo,
                                                                                input-output table temp-contrato).
        
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoMarcarTodos winMain 
procedure acaoMarcarTodos private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/

    query browseDados:get-first ().
    repeat:
        
        if not available temp-contrato
        then leave.
        
        assign temp-contrato.lg-marcado = checkMarcarTodos:checked in frame frameCorpo.
        
        if not query browseDados:get-next() 
        then leave.
    end.
    
    browse browseDados:refresh () no-error.    

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoMostrarParametros winMain 
procedure acaoMostrarParametros private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    do on error undo, return:
        
        run thealth/reajuste-planos-saude/interface/reajuste-plano-parametro.w.
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao abrir parƒmetros.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao abrir parƒmetros.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoPesquisar winMain 
procedure acaoPesquisar private :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
    define variable ch-query            as   character  no-undo.
    
    do on error undo, return:
        
        
        if not valid-handle (hd-status)
        then do:        
        
            run thealth/libs/status-processamento.w persistent set hd-status (input  "Processando", no).
        end.
        
        assign checkMarcarTodos:checked in frame frameCorpo = no.
        process events.
        
        subscribe to EV_API_REAJUSTE_PLANO_CONSULTAR in hd-api run-procedure "eventoApiConsultar".
     
        empty temp-table temp-contrato.
        empty temp-table temp-valor-beneficiario.
        empty temp-table temp-valor-beneficiario-mes.
     
        run buscarContratos in hd-api (input        integer (textModalidadeIni:screen-value in frame frameSuperior),
                                       input        integer (textModalidadeFim:screen-value),
                                       input        integer (textPlanoIni:screen-value),
                                       input        integer (textPlanoFim:screen-value),
                                       input        integer (textTipoPlanoIni:screen-value), 
                                       input        integer (textTipoPlanoFim:screen-value),
                                       input        integer (textContratanteIni:screen-value),
                                       input        integer (textContratanteFim:screen-value),
                                       input        integer (textTermoIni:screen-value),
                                       input        integer (textTermoFim:screen-value),
                                       input        integer (textFormaPagtoIni:screen-value),
                                       input        integer (textFormaPagtoFim:screen-value),
                                       input        integer (textConvenioIni:screen-value),
                                       input        integer (textConvenioFim:screen-value),
                                       input        comboTipoPessoa:input-value,
                                       input        textPeriodoFat:screen-value,
                                       input        textPeriodoReajuste:screen-value,
                                       output table temp-contrato by-reference, 
                                       output table temp-valor-beneficiario by-reference,
                                       output table temp-valor-beneficiario-mes by-reference).
        
        run acaoAtualizarFiltro.

        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao consultar os contratos.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao consultar os contratos.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
        finally:
            
            unsubscribe to EV_API_REAJUSTE_PLANO_CONSULTAR in hd-api.
            delete object hd-status no-error.
        end.
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE acaoTrocarContrato winMain
procedure acaoTrocarContrato:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
    do on error undo, return:
            
        run thealth/reajuste-planos-saude/interface/reajuste-plano-selecionar-contrato.w.
        
        
        catch cs-erro as Progress.Lang.Error : 
            
            if cs-erro:GetMessageNum(1) = 1
            then do:
                
                message substitute ("Ops...~nOcorreu um erro ao consultar os contratos.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.
            else do:
            
                message substitute ("Ops...~nOcorreu um erro ao consultar os contratos.~nInforme a TI com um print desta mensagem.~n&1",
                                    cs-erro:GetMessage(1))
                view-as alert-box error buttons ok.
            end.    
        end catch.
    end.
end procedure.
    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI winMain  _DEFAULT-DISABLE
procedure disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  if session:display-type = "GUI":U and VALID-HANDLE(winMain)
  then delete widget winMain.
  if this-procedure:persistent then delete procedure this-procedure.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI winMain  _DEFAULT-ENABLE
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
  view frame frameDefault in window winMain.
  {&OPEN-BROWSERS-IN-QUERY-frameDefault}
  display textModalidadeIni textModalidadeFim textPlanoIni textPlanoFim 
          textTipoPlanoIni textTipoPlanoFim textFormaPagtoIni textFormaPagtoFim 
          textTermoIni textTermoFim textContratanteIni textContratanteFim 
          textConvenioIni textConvenioFim comboTipoPessoa textPeriodoFat 
          textPeriodoReajuste 
      with frame frameSuperior in window winMain.
  enable buttonPesquisar textModalidadeIni textModalidadeFim textPlanoIni 
         textPlanoFim textTipoPlanoIni textTipoPlanoFim textFormaPagtoIni 
         textFormaPagtoFim textTermoIni textTermoFim textContratanteIni 
         textContratanteFim textConvenioIni textConvenioFim comboTipoPessoa 
         textPeriodoFat textPeriodoReajuste RECT-1 
      with frame frameSuperior in window winMain.
  {&OPEN-BROWSERS-IN-QUERY-frameSuperior}
  display checkOcultarSemReajuste radioEdicaoBrowse checkMarcarTodos 
      with frame frameCorpo in window winMain.
  enable checkOcultarSemReajuste buttonTrocarContrato radioEdicaoBrowse 
         browseDados checkMarcarTodos buttonEditarParcelas buttonAgendarEventos 
         buttonDetalhar buttonElimininarEventos buttonExpotar buttonHistorico 
         buttonParametros buttonBrowseLimpar buttonConfigBrowse 
      with frame frameCorpo in window winMain.
  {&OPEN-BROWSERS-IN-QUERY-frameCorpo}
  enable buttonSair 
      with frame frameRodape in window winMain.
  {&OPEN-BROWSERS-IN-QUERY-frameRodape}
  view winMain.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE eventoApiConsultar winMain 
procedure eventoApiConsultar :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade           as   integer    no-undo.
    define input  parameter in-termo                as   integer    no-undo.
    
    run mostrarMensagem in hd-status (input  substitute ("Lendo contrato &1/&2",
                                                         in-modalidade,
                                                         in-termo)) no-error.
    process events.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE eventoApiEliminar winMain 
procedure eventoApiEliminar :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-modalidade           as   integer    no-undo.
    define input  parameter in-termo                as   integer    no-undo.
    define input  parameter in-evento               as   integer    no-undo.
    define input  parameter in-usuario              as   integer    no-undo.
    define input  parameter dc-valor                as   decimal    no-undo.
    define input  parameter ch-periodo              as   character  no-undo.
    
    run mostrarMensagem in hd-status (input  substitute ('Removendo evento &4 do benefici rio &1/&2/&3, no valor de R$ &5, per¡odo &6',
                                                         in-modalidade,
                                                         in-termo,
                                                         in-usuario,
                                                         in-evento,
                                                         dc-valor,
                                                         ch-periodo)) no-error.
    process events.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE eventoExportar winMain 
procedure eventoExportar :
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    define input  parameter in-linha            as   integer    no-undo.
    
    run mostrarMensagem in hd-status (input  substitute ('Exportando linha &1', in-linha)) no-error.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializarInterface winMain 
procedure initializarInterface private :
/*------------------------------------------------------------------------------
 Purpose:             
 Notes: 
------------------------------------------------------------------------------*/
    do on error undo, return:
        
        run thealth/reajuste-planos-saude/api/api-reajuste-plano.p persistent set hd-api.    
        run thealth/libs/api-mantem-parametros.p persistent set hd-api-config.
        
        run widgetInicializar. 
        run widgetRedimencionar (frame frameDefault:handle). 
          
        run widgetRedimencionarX (frame frameSuperior:handle).
        run widgetRedimencionarX (RECT-1:handle).
        run widgetAlinharHorizontal (buttonPesquisar:handle, ALINHAR_HORIZONTAL_DIREITA).             
        
        run widgetRedimencionar (frame frameCorpo:handle).
        run widgetRedimencionar (browse browseDados:handle).
        run widgetAlinharHorizontal (radioEdicaoBrowse:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonBrowseLimpar:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonConfigBrowse:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonParametros:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonDetalhar:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonElimininarEventos:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonAgendarEventos:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonHistorico:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonExpotar:handle, ALINHAR_HORIZONTAL_DIREITA).
        run widgetAlinharHorizontal (buttonEditarParcelas:handle, ALINHAR_HORIZONTAL_DIREITA).
        
        run widgetRedimencionarX (frame frameRodape:handle).
        run widgetAlinharVertical (frame frameRodape:handle, ALINHAR_VERTICAL_INFERIOR).
        run widgetAlinharHorizontal (buttonSair:handle, ALINHAR_HORIZONTAL_DIREITA).
        
        assign comboTipoPessoa:list-item-pairs  = substitute ("Ambos,&1,Fisica,&2,Jur¡dica,&3",
                                                              TIPO_PESSOA_AMBOS, 
                                                              TIPO_PESSOA_FISICA,
                                                              TIPO_PESSOA_JURIDICA)
               comboTipoPessoa:screen-value     = comboTipoPessoa:entry(1)
               winMain:title                    = 'Gerar eventos programado de reajuste'
               .
                                                              
        run buscarParametro in hd-api-config (input  "th-gps-param",
                                              input  "reajuste-plano-consultar", 
                                              input  v_cod_usuar_corren,
                                              input  PARAM_LAYOUT_BROWSE,   
                                              output lo-configuracao-browse) no-error.   

        define variable dt-process  as date no-undo.
        assign dt-process   = today.
                                              
        assign textPeriodoReajuste:screen-value = substitute ('&1&2',
                                                              string (month (dt-process), '99'),
                                                              string (year (dt-process), '9999'))
               dt-process                       = add-interval (date (month (dt-process), 1, year (dt-process)) , 1, 'month')                                                              
               textPeriodoFat:screen-value      = substitute ('&1&2',
                                                              string ( month (dt-process), '99'),
                                                              string (year (dt-process), '9999'))                                                           
               .                                                      

        assign textContratanteFim:label = 'at‚'
               textModalidadeFim:label  = 'at‚'
               textPlanoFim:label       = 'at‚'
               textTipoPlanoFim:label   = 'at‚'
               textFormaPagtoFim:label  = 'at‚'
               textTermoFim:label       = 'at‚'
               textConvenioFim:label    = 'at‚'
               .                               
               
        apply 'value-changed' to radioEdicaoBrowse.                         
        
        run prepararbrowseDados.
        
    end.
    catch cs-erro as Progress.Lang.Error : 
        
        if cs-erro:GetMessageNum(1) = 1
        then do:
            
            message substitute ("Ops...~nOcorreu um erro ao abrir o programa.~n&1",
                                cs-erro:GetMessage(1))
            view-as alert-box error buttons ok.
        end.
        else do:
        
            message substitute ("Ops...~nOcorreu um erro ao abrir o programa.~nInforme a TI com um print desta mensagem.~n&1",
                                cs-erro:GetMessage(1))
            view-as alert-box error buttons ok.
        end.    
        
        
        apply 'close' to winMain.
    end catch.      
     
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

