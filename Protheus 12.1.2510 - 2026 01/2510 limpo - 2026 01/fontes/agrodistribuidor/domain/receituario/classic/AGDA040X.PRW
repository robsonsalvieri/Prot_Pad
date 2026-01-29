#INCLUDE "AGDA040X.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGDA040X
Rotina para Cadastro de Solicitação de Receita
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 10/10/2025
/*/
Function AGDA040X()
	Local oMBrowse := Nil

	If .Not. TableInDic('NET')
		MsgNextRel()
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NET" )
	oMBrowse:SetDescription( STR0001 ) //#"Solicitação de Receita"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Definição do menu
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 10/10/2025
@return Array, array com o menu da rotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA040X' OPERATION 2 ACCESS 0 //#"Visualizar"
	// ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGDA040X' OPERATION 3 ACCESS 0 //#"Incluir"
	// ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGDA040X' OPERATION 4 ACCESS 0 //#"Alterar"
	// ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGDA040X' OPERATION 5 ACCESS 0 //#"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 10/10/2025
@return Object, modelo de dados
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStru		:= FwFormStruct( 1, "NET" )
	Local oStruNET  := FwFormStruct( 1, "NET" )
	Local oStruNEU	:= FwFormStruct( 1, "NEU" )
	//Local oEvent        := AGDA040EVT():New()

	//SETANDO INICILIZADOR PADRAO PARA EVITAR MESAGEM DE CAMPO NAO PREECHIDO
	oStruNET:SetProperty("NET_NUMPED"	, MODEL_FIELD_INIT 	, {| | M->NET_NUMPED 	})
	oStruNET:SetProperty("NET_CLIENT"	, MODEL_FIELD_INIT 	, {| | M->NET_CLIENT	})
	oStruNET:SetProperty("NET_LOJA"		, MODEL_FIELD_INIT 	, {| | M->NET_LOJA 		})

	oStruNEU:SetProperty( "NEU_CODIGO" 	, MODEL_FIELD_INIT 	, {| | M->NET_CODIGO } )

	oModel := MpFormModel():New( "AGDA040X")
	oModel:SetDescription( STR0001 ) //##"Solicitação de Receita"

	oStru:RemoveField( "NET_CODIGO" )

	oModel:AddFields("NETMASTER", , oStru)
	oModel:GetModel( "NETMASTER" ):SetDescription( STR0006 ) //#"Dados de Pedido"

	// Adiciona a field no modelo de dados
	oModel:AddGrid("AGDA040X_NET","NETMASTER",oStruNET,,,,,)
	oModel:GetModel( "AGDA040X_NET" ):SetDescription( STR0007 ) //#"Dados Solicitação de Receita"
	oModel:SetPrimaryKey( { "NET_FILIAL", "NET_NUMPED" } )

	oModel:AddGrid( "AGDA040X_NEU", "AGDA040X_NET", oStruNEU)
	oModel:GetModel( "AGDA040X_NEU" ):SetDescription( STR0008 ) //#"Itens Solicitação de Receita"

	oModel:SetRelation( 'AGDA040X_NET', {{'NET_FILIAL', 'xFilial("NET")'},{ 'NET_NUMPED', 'NET_NUMPED' },{ 'NET_CLIENT', 'NET_CLIENT' },{ 'NET_LOJA', 'NET_LOJA' }}, NET->(IndexKey( 1 ) ) )
	oModel:SetRelation( 'AGDA040X_NEU', {{'NEU_FILIAL', 'xFilial("NEU")'},{ 'NEU_CODIGO', 'NET_CODIGO' },{ 'NEU_NUMPED', 'NET_NUMPED' }}, NEU->(IndexKey( 1 ) ) )

	oModel:GetModel( "AGDA040X_NEU" ):SetUniqueLine( { 'NEU_ITEM' } )
	oModel:GetModel( "AGDA040X_NEU" ):SetOptional( .F. )
	oModel:GetModel('AGDA040X_NEU'):SetUseOldGrid(.T.)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da visualização dos dados
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 10/10/2025
@return Object, Objeto de dados da View
/*/
Static Function ViewDef()

	Local oModel	:= FwLoadModel( "AGDA040X" )
	Local oStru   	:= FWFormStruct( 2, "NET")
	Local oStruNET  := FwFormStruct( 2, "NET" )
	Local oStruNEU  := FwFormStruct( 2, "NEU")
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField("VIEW_NET", oStru, "NETMASTER")

	oView:AddGrid( 'GRID_NET', oStruNET, 'AGDA040X_NET' )
	oView:AddGrid( 'GRID_NEU', oStruNEU, 'AGDA040X_NEU' )
	oView:AddIncrementField( 'GRID_NEU', 'NEU_ITEM' )

	oView:CreateHorizontalBox( 'CABEC', 20 )
	oView:CreateHorizontalBox( 'GRIDNET', 40 )
	oView:CreateHorizontalBox( 'GRIDNEU', 40 )

	oView:SetOwnerView( 'VIEW_NET', 'CABEC' )
	oView:SetOwnerView( 'GRID_NET', 'GRIDNET' )
	oView:SetOwnerView( 'GRID_NEU', 'GRIDNEU' )

	oView:EnableTitleView("VIEW_NET")
	oView:EnableTitleView("GRID_NET")
	oView:EnableTitleView("GRID_NEU")


	oStru:RemoveField( "NET_CODIGO" )
	oStru:RemoveField( "NET_NUMREC" )
	oStru:RemoveField( "NET_URL" )
	oStru:RemoveField( "NET_DTEMIS" )
	oStru:RemoveField( "NET_HREMIS" )
	oStru:RemoveField( "NET_OBS" )
	oStru:RemoveField( "NET_EMISSA" )
	oStru:RemoveField( "NET_CULTRA" )
	oStru:RemoveField( "NET_DOC" )
	oStru:RemoveField( "NET_SERIE" )
	oStru:RemoveField( "NET_STSSOL" )
	oStru:RemoveField( "NET_STSREC" )


	oStruNET:RemoveField( "NET_CLIENT" )
	oStruNET:RemoveField( "NET_LOJA" )
	oStruNET:RemoveField( "NET_NUMPED" )
	oStruNET:RemoveField( "NET_CODENG" )
	oStruNET:RemoveField( "NET_LOCDES" )

	oStruNEU:RemoveField( "NEU_CODREC" )
	oStruNEU:RemoveField( "NEU_SEQREC" )

	oView:SetCloseOnOk({||.T.})
Return oView

