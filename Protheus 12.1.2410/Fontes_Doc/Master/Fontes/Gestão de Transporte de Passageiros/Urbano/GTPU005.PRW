#INCLUDE 'TOTVS.ch'
#INCLUDE 'GTPU005.ch'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU005
	Cadastro de Validadores - Urbano

	@author Djalma Mathias
	@since 07/02/2024
	@version 1.0
/*/
//-------------------------------------------------------------------

Function GTPU005()
	Local oBrowse  

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) // "Cadastro de Validadores"
	oBrowse:SetAlias("H6Y")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Menu Funcional

	@return aRotina - Cadastro de Validadores
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
	@since 07/02/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.GTPU005", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.GTPU005", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.GTPU005", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.GTPU005", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.GTPU005", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Função responsavel pela definição do modelo
	@since 07/02/2024
	@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel    := Nil
	Local oStrH6Y   := FWFormStruct(1, 'H6Y')
	Local oStrH7Y   := FWFormStruct(1, 'H7Y')
	Local oCommit	:= GU05COMMIT():New()

	oModel := MPFormModel():New('GTPU005')
	oModel:InstallEvent("GU05COMMIT",, oCommit)

	oModel:AddFields( 'H6YMASTER',, oStrH6Y )
	oModel:AddGrid( 'H7YDETAIL', 'H6YMASTER', oStrH7Y )

	oModel:SetRelation("H7YDETAIL", {{"H7Y_FILIAL", "xFilial('H7Y')"}, {"H7Y_CODH6Y", "H6Y_CODIGO"}}, H7Y->( IndexKey( 1 ))) //Histórico validadores

	oModel:SetDescription(STR0001)// "Cadastro de Validadores"
	oModel:GetModel('H6YMASTER'):SetDescription(STR0001) //"Cadastro de Validadores"
	oModel:GetModel('H7YDETAIL'):SetDescription(STR0008) //"Histórico de validadores"
	oModel:SetOptional( "H7YDETAIL" , .T. )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Função responsavel pela definição da view
	@type Static Function
	@author 
	@since 07/02/2024
	@version 1.0
	@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView   := FWFormView():New()
	Local oModel  := FwLoadModel('GTPU005')
	Local oStrH6Y := FWFormStruct(2, 'H6Y')
	Local oStrH7Y := FWFormStruct(2, 'H7Y')

	oView:SetModel(oModel)
	oView:AddField('VIEW_H6Y', oStrH6Y, 'H6YMASTER')
	oView:AddGrid('VIEW_H7Y', oStrH7Y, 'H7YDETAIL')  

	oView:CreateHorizontalBox( "CABEC", 60 )
    oView:CreateHorizontalBox( "GRID" , 40 )

	oView:SetOwnerView( "VIEW_H6Y" , "CABEC" )   
    oView:SetOwnerView( "VIEW_H7Y" , "GRID" )

	oView:EnableTitleView( "VIEW_H6Y" , STR0001 ) //"Cadastro de Validadores"
    oView:EnableTitleView( "VIEW_H7Y", STR0008 )  //"Histórico de validadores"

Return oView

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GU05COMMIT
@description Classe interna implementando o FWModelEvent, para execução de função durante o commit.
@author Silas Gomes
@since 05/03/2025
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------------------
Class GU05COMMIT FROM FWModelEvent
	Method New()
	Method BeforeTTS() //quando ocorrer as ações do commit antes  da transação.
End Class

//---------------------------------------------------------
Method New() Class GU05COMMIT
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
@author Silas Gomes
@since 05/03/2025
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------------------
Method BeforeTTS(oModel) Class GU05COMMIT

	Local nOperation := oModel:GetOperation()
	Local oModelH7Y  := oModel:GetModel( 'H7YDETAIL' )
	
	If nOperation != MODEL_OPERATION_DELETE
		oModelH7Y:LoadValue('H7Y_USER', FwGetUserName(RetCodUsr()))
	EndIf

Return
