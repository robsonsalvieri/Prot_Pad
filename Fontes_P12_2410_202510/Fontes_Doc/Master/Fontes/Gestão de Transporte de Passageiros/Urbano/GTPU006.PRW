#INCLUDE 'totvs.ch'
#INCLUDE 'GTPU006.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU006
	Cadastro de Roleta - Urbano

	@author Djalma Mathias
	@since 13/02/2024
	@version 1.0
/*/
//-------------------------------------------------------------------

Function GTPU006()

	Local oBrowse  

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) // "Cadastro de Roleta"
	oBrowse:SetAlias("H6Z")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Menu Funcional

	@return aRotina - Cadastro de Roleta
	[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transação a ser efetuada:
	1 - Pesquisa e Posiciona em um Banco de Dados
	2 - Simplesmente Mostra os Campos
	3 - Inclui registros no Bancos de Dados
	4 - Altera o registro corrente
	5 - Remove o registro corrente do Banco de Dados
	6 - Alteração sem inclusão de registros
	7 - Cópia
	8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional

	@author Djalma Mathias
	@since 13/02/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.GTPU006", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.GTPU006", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.GTPU006", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.GTPU006", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.GTPU006", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Função responsavel pela definição do modelo

	@since 13/02/2024
	@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel    := Nil
	Local oStrH6Z   := FWFormStruct( 1, 'H6Z' )
	Local oStrH80   := FWFormStruct( 1, 'H80' )

	oModel := MPFormModel():New( 'GTPU006' )

	oModel:AddFields( 'H6ZMASTER',, oStrH6Z )
	oModel:AddGrid( 'H80DETAIL', 'H6ZMASTER', oStrH80 )

	oModel:SetRelation("H80DETAIL", {{"H80_FILIAL", "xFilial('H80')"}, {"H80_CODH6Z", "H6Z_CODIGO"}}, H80->( IndexKey( 1 )))
	
	oModel:SetDescription(STR0001)// "Cadastro de Roleta"
	oModel:GetModel( 'H6ZMASTER' ):SetDescription(STR0001) //"Cadastro de Roleta"
	oModel:GetModel( 'H80DETAIL' ):SetDescription(STR0008) //"Histórico de Roleta"

	oModel:SetOptional( "H80DETAIL" , .T. )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Função responsavel pela definição da view

	@type Static Function
	@since 13/02/2024
	@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView   := FWFormView():New()
	Local oModel  := FwLoadModel('GTPU006')
	Local oStrH6Z := FWFormStruct(2, 'H6Z')
	Local oStrH80 := FWFormStruct(2, 'H80')

	oView:SetModel(oModel)
	oView:AddField('VIEW_H6Z', oStrH6Z, 'H6ZMASTER')
	oView:AddGrid('VIEW_H80', oStrH80, 'H80DETAIL')  

	oView:CreateHorizontalBox( "CABEC", 60 )
    oView:CreateHorizontalBox( "GRID" , 40 )

	oView:SetOwnerView( "VIEW_H6Z", "CABEC" )   
    oView:SetOwnerView( "VIEW_H80", "GRID" )

	oView:EnableTitleView( "VIEW_H6Z", STR0001 ) //"Cadastro de roletas"
    oView:EnableTitleView( "VIEW_H80", STR0008 )  //"Histórico de roletas"

Return oView

