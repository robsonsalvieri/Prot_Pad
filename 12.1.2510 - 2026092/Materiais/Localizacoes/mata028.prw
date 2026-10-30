#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA028.CH"
#INCLUDE "FWBROWSE.CH"

Static cMT28SX3 := ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATA028   ³ Autor  ³Miguel Angel Rojas G.     ³ Data ³ 14.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CONFIGURACIONES DE ADENDA                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATA028()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERAL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Miguel Rojas³24/02/14³          ³Ordenar constantes STR00XX                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Miguel Rojas³25/02/14³          ³Valida linea duplicada en CPO             ³±±
±±³            ³        ³          ³y registro unico en CPR_CONFIG            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo	 ³08/04/14³          ³Se agrega funcionalidad para cargar campos³±±
±±³            ³        ³          ³obligatorios de cpp/cpq al incluir.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³06/06/16³  TVGZL6  ³se agrega SetPrimaryKey en ModelDef       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jose Glez   ³28/11/17³DMINA-1217³Se agrega validacion para detectar si     ³±±
±±³            ³        ³	       ³la rutina se ejecuta de manera automatica ³±±
±±³            ³        ³          ³y no mostrar cuadros de usuario.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATA028()
DbSelectArea("CPP")
DbSelectArea("CPQ")
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CPR")
oBrowse:SetDescription(STR0001)  // Configuraciones de adendas
oBrowse:SetMenuDef("MATA028")
oBrowse:DisableDetails()
oBrowse:Activate()
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef   ³ Autor ³ Miguel Angel Rojas G. ³ Data ³14.02.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Crea un Menu                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Menu Estandar                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA028                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()
Return FWMVCMenu( "MATA028" ) // Genera un Menu Estandar en MVC sin Necesidad de aRotina.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ModelDef  ³ Autor ³Miguel Angel. Rojas G. ³ Data ³14/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Crea la estructura del modelo de datos llama                ³±±
±±³          ³funciones para validar antes de guardar y al modificar      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                 ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Modelo de datos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA028                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ModelDef()
Local oStruCPR := FWFormStruct( 1, "CPR" )
Local oStruCPO := FWFormStruct( 1, "CPO" )
Local oModel
Local bBloco


//--- Objeto Constructor del Modelo de Datos
oModel := MPFormModel():New("MATA028",/* { | oMdl | MT28PRE( oMdl ) } */,{ | oMdl | MT28POS( oMdl ) }, /*{ | oMdl | MATA028COMM( oMdl ) }*/,/*bCancel*/ )
bBloco := {|oModel| M458FILLGRID(oModel)}
//--- Agrega un Modelo para la captura de datos
oModel:AddFields( "CPRMASTER", /*es el encabezado*/, oStruCPR )

//--- Agrega Modelo de datos para el detalle
oModel:AddGrid( "CPODETAIL", "CPRMASTER", oStruCPO ,,,,, )

//--- Establece la relaci?n entre las tablas
oModel:SetRelation( "CPODETAIL", { { "CPO_FILIAL", "xFilial( 'CPO' )" }, { "CPO_CONFIG" , "CPR_CONFIG"  } } , CPO->( IndexKey( 1 ) )  )

//--- No permite la duplicidad de registros con SetUniqueLine  
oModel:GetModel( "CPODETAIL" ):SetUniqueLine( { "CPO_CAMPO" } )

//--- Descripci?n del Modelo de Datos
oModel:SetDescription( STR0001 )       // Configuraciones de adendas

//----llave primaria
oModel:SetPrimaryKey( {'CPO_FILIAL','CPR_CONFIG'} ) 
//--- Valida que un Grid pueda quedar Vacio
oModel:GetModel( "CPODETAIL" ):SetOptional( .T. )

//--- Descripci?n de los componente del Modelo de Datos
oModel:GetModel( "CPRMASTER" ):SetDescription( STR0001 )  		// Configuraciones de adendas
oModel:GetModel( "CPODETAIL" ):SetDescription( STR0001 )		// Configuraciones de adendas

oModel:SetActivate(bBloco)

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ViewDef   ³ Autor ³Miguel Angel. Rojas G. ³ Data ³14/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Genera la vista de los datos de acuerdo al  modelo         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EprO1: Objeto Vista                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA094                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ViewDef()
Local oStruCPR := FWFormStruct( 2, "CPR" )
Local oStruCPO := FWFormStruct( 2, "CPO" )
Local oModel   := FWLoadModel( "MATA028" )
Local oView

//--- Quita los campos de la estrutura para evitar duplicidad en pantalla
oStruCPO:RemoveField( "CPO_CONFIG" )


oView := FWFormView():New()
oView:SetModel( oModel )    // el oView toma como base el objeto oModel para su construcci?n
oView:AddField( "VIEW_CPR", oStruCPR, "CPRMASTER" )
//--- Agrega los Grids para consulta 
oView:AddGrid(  "VIEW_CPO", oStruCPO, "CPODETAIL" )
//--- Hace un "box" horizontal para recibir elementos de la Vista
oView:CreateHorizontalBox( "SUPERIOR", 15 )
oView:CreateHorizontalBox( "INFERIOR", 85 )


//--- Relaciona EL ID del View con el "box" para mostrar
oView:SetOwnerView( "VIEW_CPR", "SUPERIOR" )
oView:SetOwnerView( "VIEW_CPO", "INFERIOR" )

//oView:SetFieldAction( 'CPR_CONFIG'	, { |oView| M458FILLGRID(oView) 		} )
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³MT28SX3   ³ Autor ³Miguel Angel. Rojas G. ³ Data ³14/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Genera la consulta SX3FIL                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MT28SX3()                                                  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SXB - SX3FIL                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT28SX3()
Local lRet      := .F. 
Local oDlg
Local oBrowse
Local oMainPanel
Local oPanelBtn
Local oBtnOK
Local oBtnCan
Local nx := 0
Local aItems := {}
Local aColumns := {}

cMT28SX3 := ""

Define MsDialog oDlg From 0, 0 To 390, 515 Title STR0002 Pixel Of oMainWnd		//Campos de las Tablas CPP/CPQ

@00, 00 MsPanel oMainPanel Size 250, 80
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

@00, 00 MsPanel oPanelBtn Size 250, 15
oPanelBtn:Align := CONTROL_ALIGN_BOTTOM

Define FwBrowse oBrowse NO CONFIG  NO REPORT DOUBLECLICK { || lRet := .T.,  oDlg:End() } NO LOCATE Of oMainPanel

oBrowse:SetDataArrayoBrowse()  //Define utilização de array

aItems := LoadItems()      //Carregar os itens que irão compor o conteudo do grid
oBrowse:SetArray(aItems) //Indica o array utilizado para apresentação dos dados no Browse.

aColumns := RetColumns( aItems )

//Cria as colunas do array
For nX := 1 To Len(aColumns )
    oBrowse:AddColumn( aColumns[nX] )
Next

oBrowse:SetOwner(oDlg)
oBrowse:SetDescription("")
oBrowse:SetDoubleClick({ || lRet := .T.,  oDlg:End() })
oBrowse:SetLocate()
oBrowse:Activate()

Define SButton oBtnOK  From 02, 02 Type 1 Enable Of oPanelBtn ONSTOP STR0006 ;				//Aceptar
Action ( lRet := .T., oDlg:End() )

Define SButton oBtnCan From 02, 32 Type 2 Enable Of oPanelBtn ONSTOP STR0007 ;				//Cancelar
Action ( lRet := .F., oDlg:End() )

Activate MsDialog oDlg Centered

if oBrowse:nAT > 0 .and. lret
    cMT28SX3 := aItems[oBrowse:nAT][1]
else
	cMT28SX3 := ""
endif

Return lRet


/*/{Protheus.doc} RetColumns
	Retorna as colunas a serem criadas no grid da MT28SX3
	@type  Function
	@author elias.kuchak
    @since 23/02/2024
	@version 1.0
	@param aItems - Array - Conteudo das colunas a serem apresentadas no GRID.
	@return aColumns - Array - Colunas a serem adicionadas ao GRID.
	/*/
Static Function RetColumns(aItems)
    Local aColumns := {}
    Local aTamanho := {10, 10, 10}

    Default aItems := {}

    if len(aItems) > 0
	   aTamanho:= {}
       aAdd(aTamanho, len(aItems[1][1]))
       aAdd(aTamanho, len(aItems[1][2]))
       aAdd(aTamanho, len(aItems[1][3]))
    endif
    
    aAdd(aColumns, {;
                        STR0003,;                        // [n][01] Título da coluna
                        {|oBrw| aItems[oBrw:At(), 1] },; // [n][02] Code-Block de carga dos dados
                        "C",;                            // [n][03] Tipo de dados
                        "@!",;                           // [n][04] Máscara
                        1,;                              // [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
                        aTamanho[1],;                    // [n][06] Tamanho
                        0,;                              // [n][07] Decimal
                        .T.,;                            // [n][08] Indica se permite a edição
                        {|| },;                          // [n][09] Code-Block de validação da coluna após a edição
                        .F.,;                            // [n][10] Indica se exibe imagem
                        Nil,;                            // [n][11] Code-Block de execução do duplo clique
                        "__ReadVar",;                    // [n][12] Variável a ser utilizada na edição (ReadVar)
                        {|| AlwaysTrue()},;              // [n][13] Code-Block de execução do clique no header
                        .F.,;                            // [n][14] Indica se a coluna está deletada
                        .T.,;                            // [n][15] Indica se a coluna será exibida nos detalhes do Browse
                        {},;                             // [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
                        "ID1"})                          // [n][17] Id da coluna
 
    aAdd(aColumns, {;
                        STR0004,;                        // [n][01] Título da coluna
                        {|oBrw| aItems[oBrw:At(), 2] },; // [n][02] Code-Block de carga dos dados
                        "C",;                            // [n][03] Tipo de dados
                        "@!",;                           // [n][04] Máscara
                        1,;                              // [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
                        aTamanho[2],;                    // [n][06] Tamanho
                        0,;                              // [n][07] Decimal
                        .F.,;                            // [n][08] Indica se permite a edição
                        {|| },;                          // [n][09] Code-Block de validação da coluna após a edição
                        .F.,;                            // [n][10] Indica se exibe imagem
                        Nil,;                            // [n][11] Code-Block de execução do duplo clique
                        __ReadVar,;                      // [n][12] Variável a ser utilizada na edição (ReadVar)
                        {|| AlwaysTrue()},;              // [n][13] Code-Block de execução do clique no header
                        .F.,;                            // [n][14] Indica se a coluna está deletada
                        .T.,;                            // [n][15] Indica se a coluna será exibida nos detalhes do Browse
                        {},;                             // [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
                        "ID2"})                          // [n][17] Id da coluna
 
    aAdd(aColumns, {;
                        STR0005,;                         // [n][01] Título da coluna
                        {|oBrw| aItems[oBrw:At(), 3 ] },; // [n][02] Code-Block de carga dos dados
                        "C",;                             // [n][03] Tipo de dados
                        "@!",;                            // [n][04] Máscara
                        1,;                               // [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
                        aTamanho[3],;                     // [n][06] Tamanho
                        0,;                               // [n][07] Decimal
                        .F.,;                             // [n][08] Indica se permite a edição
                        {|| },;                           // [n][09] Code-Block de validação da coluna após a edição
                        .F.,;                             // [n][10] Indica se exibe imagem
                        Nil,;                             // [n][11] Code-Block de execução do duplo clique
                        "__ReadVar",;                     // [n][12] Variável a ser utilizada na edição (ReadVar)
                        {|| AlwaysTrue()},;               // [n][13] Code-Block de execução do clique no header
                        .F.,;                             // [n][14] Indica se a coluna está deletada
                        .T.,;                             // [n][15] Indica se a coluna será exibida nos detalhes do Browse
                        {},;                              // [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
                        "ID3"})                           // [n][17] Id da coluna
 
Return aColumns
 

/*/{Protheus.doc} LoadItems
	Obtem os valores a serem apresentados no GRID da MT28SX3.
	@type  Function
	@author elias.kuchak
    @since 23/02/2024
	@version 1.0
	@return aLinha - Array - Valores a serem apresentados no GRID.
	/*/
Static Function LoadItems()
    Local aLinha     := {}
    Local aSX3      := {}
	Local _i        := 0
 
    aSX3 := FWSX3Util():GetAllFields("CPP", .T.)
	for _i := 1 to len(aSX3)
		If GetSx3Cache(aSX3[_i], "X3_CONTEXT") <> 'V'
			aAdd(aLinha,{aSX3[_i], FWX3Titulo(aSX3[_i]), fGetX3Descri(aSX3[_i])})
		EndIf
	next _i

    aSX3 := FWSX3Util():GetAllFields("CPQ", .T.)
	for _i := 1 to len(aSX3)
		If GetSx3Cache(aSX3[_i], "X3_CONTEXT") <> 'V'
			aAdd(aLinha,{aSX3[_i], FWX3Titulo(aSX3[_i]), fGetX3Descri(aSX3[_i])})
		EndIf
	next _i

Return aLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³MT28CAMPO ³Autor  ³Miguel Angel. Rojas G. ³ Data ³13/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Validacion para el campo CPO_CAMPO                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MT28CAMPO                                                  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EprL1: .T./.F.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SX3VALID -CPO_CAMPO                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MT28CAMPO()
Local cVar := &(ReadVar())
Local lRet := .f.

IF GetSx3Cache(cVar, "X3_ARQUIVO")=="CPP" .OR. GetSx3Cache(cVar, "X3_ARQUIVO")=="CPQ"
	lRet := .t.
Else
	Help( ,, STR0008,,STR0009 ,1, 0 )  // Aviso, El campo no pertenece a las tablas CPP/CPQ	
EndIf
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³MT28POS    ³ Autor ³Miguel Angel. Rojas G.³ Data ³14/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Valida que se eliminen las funciones de tipo sistema al     ³±±
±±³          ³presionar Confirmar cuanto estamos en Borrar                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT28POS(EprO1)                                              ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExprO1: Objeto que contiene el modelo de datos              ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExprL1 : .t./.f.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA028                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MT28POS( oMdl )
Local nOperation	:= oMdl:GetOperation()
Local lRet 		:= .T.
Local lBorrar		:= .F.
Local lAutomato   := IsBlind()

If nOperation ==	MODEL_OPERATION_DELETE   	
	If !lAutomato
		lBorrar := MsgNoYes(STR0011)	           //Estás seguro de eliminar
		if lBorrar
		  lRet := .T.
		Else
		  lRet := .F.
		  Help( ,, STR0003,,STR0012,1, 0 )        //Aviso, No se hicieron cambios.
		Endif
	 Else
	   	lRet := .T.   // Se omite la confirmación del usuario para la rutina automática
	 EndIf			
EndIF
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³MT28POS    ³ Autor ³Mayra.Camargo         ³ Data ³08/08/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³LLenado del grid al ser una nueva configuración.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fgetSX3Cpos(cTabla,aCampos)                                 ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oMdl:=Modelo de datos										    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA028                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//
Static Function M458FILLGRID(oMdl)
	Local lRet 	:= .T.
	Local oMdlGr	:= oMdl:GetModel('CPODETAIL')
	Local aCampos:= {}
	Local aCols	:= {}
	Local nI		:= 0
	Local nOp		:= oMdl:GetOperation()
	Local cNodo	:= ""
	Local cCampo	:= ""
	
	If nOp == MODEL_OPERATION_INSERT
		fgetSX3Cpos("CPP",@aCampos)
		fgetSX3Cpos("CPQ",@aCampos)
		
	
		For nI := 1 to len(aCampos)
			cCampo := alltrim(aCampos[nI])
			Do Case
				Case cCampo $ "CPP_UUID|CPQ_UUID"		
					cNodo := "_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT"
				Case cCampo $ "CPP_EMISSA|CPQ_EMISSA"
					cNodo := "_CFDI_COMPROBANTE:_FECHA:TEXT"
				Case  cCampo $ "CPP_FECTIM"
					cNodo := "_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT"
				Otherwise
					cNodo:= "_CFDI_COMPROBANTE"
			EndCase
			oMdlGr:SetValue("CPO_FILIAL",XFILIAL("CPO"))
			oMdlGr:SetValue("CPO_CONFIG","0")
			oMdlGr:SetValue("CPO_CAMPO",cCampo)
			oMdlGr:SetValue("CPO_ELEMEN",cNodo)
			oMdlGr:SetValue("CPO_OBLIGA",'1')
			oMdlGr:AddLine()
						
		Next nI			
	EndIF

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³MT28POS    ³ Autor ³Mayra.Camargo         ³ Data ³08/08/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Obtiene los camposo bligatorios de cpp/cpq de la SX3        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fgetSX3Cpos(cTabla,aCampos)                                 ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTabla	:=Tabla del diccionario para la b´suqueda            ³±±
±±³          ³aCampos:=Array a llenar con los campos obtenidos            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA028                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//
Static function fgetSX3Cpos(cTabla,aCampos)
	Local aArea 	:= getArea()
	Local aSX3    := {}
  Local _i        := 0
  DEFAULT aCampos	:= {}
	
  aSX3 := FWSX3Util():GetAllFields(cTabla, .T.)
	for _i := 1 to len(aSX3)
	    If X3OBRIGAT(aSX3[_i])
		      aAdd(aCampos, aSX3[_i])
			EndIf
	next _i

	RestArea(aArea)
Return


/*/{Protheus.doc} fGetX3Descri
	Obtiene valor para campo de descrição de acordo com a linguagem.
	@type  Function
	@author elias.kuchak
    @since 23/02/2024
	@version 1.0
	@param cField - Character - Nombre de campo en SX3.
	@return cX3Descri - Character - Descrição do campo.
	/*/
Function fGetX3Descri(cField As Character) As Character
	Local cX3Descri As Character
	Local cFunction As Character
	Local cIdiom    As Character
	Local cBoxIdiom As Character

	Default cField := ""

	cIdiom := FwRetIdiom()

	If cIdiom == 'en' .Or. cIdiom == 'ru'
		cBoxIdiom := 'X3_DESCENG'
	ElseIf cIdiom == 'es'
		cBoxIdiom := 'X3_DESCSPA'
	Else
		cBoxIdiom := 'X3_DESCRIC'
	EndIf

	cX3Descri  := AllTrim(GetSX3Cache(cField, cBoxIdiom))

Return cX3Descri



/*/{Protheus.doc} MT28SX3Ret
	Retorna o valor da variavel static cMT28SX3 que é selecionada na função MT28SX3
	@type  Function
	@author elias.kuchak
    @since 28/02/2024
	@version 1.0
	@return cMT28SX3 - Character - Campo selecionado e armazenado na variavel static 
	/*/

Function MT28SX3Ret()
    return cMT28SX3
