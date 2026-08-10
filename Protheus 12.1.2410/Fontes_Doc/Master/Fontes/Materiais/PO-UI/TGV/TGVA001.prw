#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TGVA001.CH"

#DEFINE NAOVISUALIZADA "1"
#DEFINE VISUALIZADA	"2"

//-------------------------------------------------------------------
/*/{Protheus.doc} TGVA001
	Notificações do Vendedor referete aos registros integrados pelo
	TOTVS Gestão de Vendas (TGV).

	@author Danilo Salve
	@since 05/02/2021
	@version 12.1.27 ou Superior
/*/
//-------------------------------------------------------------------
Function TGVA001()
	Local oMBrowse 	:= Nil
	Local oTableAtt := TableAttDef()

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("A1S")
	oMBrowse:SetDescription(STR0001) //"Notificações do Vendedor"
	oMBrowse:SetCanSaveArea(.T.)
	oMBrowse:SetMenudef("TGVA001")
	//Adiciona as Legendas do Browse
	oMBrowse:AddLegend("A1S_STATUS == '" + NAOVISUALIZADA + "'"	, "GREEN"	, STR0006)	//"Notificações não visualizadas"
	oMBrowse:AddLegend("A1S_STATUS == '" + VISUALIZADA 	+ "'"	  , "RED"		, STR0007)	//"Notificações visualizadas"

	//Inclui um totalizador no Browse
	oMBrowse:SetAttach( .T. )
	oMBrowse:SetViewsDefault( oTableAtt:aViews )
	oMBrowse:SetTotalDefault("A1S_FILIAL","COUNT", STR0005) //"Total de Registros"
	oMBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef
	Disponibiliza as Visões do Browse.

	@return	    oTableAtt, Objeto,  Objetos com as Visoes e Graicos.
	@author 	Danilo Salve
	@version	12.1.27
	@since      08/02/2021
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()
    Local oView		as Object
    Local oTableAtt := FWTableAtt():New()

    oTableAtt:SetAlias("A1S")

    oView := FWDSView():New()
    oView:SetName(STR0006) 	// Notificações não visualizadas
    oView:SetID(STR0006) 	  // Notificações não visualizadas
    oView:SetOrder(1) 		  // A1S_FILIAL + A1S_CODIGO + A1S_CODUSR
    oView:SetCollumns({"A1S_CODIGO", "A1S_TITULO", "A1S_NOMUSR", "A1S_DATA", "A1S_HORA"})
    oView:SetPublic( .T. )
    oView:AddFilter(STR0002, "A1S_STATUS == '" + NAOVISUALIZADA + "'") //1 - Não Visualizadas
    oTableAtt:AddView(oView)

    oView := FWDSView():New()
    oView:SetName(STR0007) 	// Notificações visualizadas
    oView:SetID(STR0007) 	  // Notificações visualizadas
    oView:SetOrder(1) 		  // A1S_FILIAL + A1S_CODIGO + A1S_CODUSR
    oView:SetCollumns({"A1S_CODIGO", "A1S_TITULO", "A1S_NOMUSR", "A1S_DATA", "A1S_HORA"})
    oView:SetPublic( .T. )
    oView:AddFilter(STR0003, "A1S_STATUS == '"+ VISUALIZADA + "'") //2 - Visualizadas
    oTableAtt:AddView(oView)

Return oTableAtt

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Menu do cadastro de clientes para localização padrão.

	@author 	Danilo Salve
	@version	12.1.27
	@since		05/02/2021
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw" 			    OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003	ACTION "VIEWDEF.TGVA001" 	OPERATION 2	ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.TGVA001" 	OPERATION 8 ACCESS 0 // "Imprimir"
Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Modelo de dados das Notificações

    @sample		ModelDef()
    @return		ExpO - Objeto MPFormModel
    @author		Danilo Salve
    @since		05/02/2021
    @version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ModelDef() as Object
    Local oModel        as Object
    Local oStructA1S    := FWFormStruct(1,'A1S',/*bAvalCampo*/,/*lViewUsado*/)

    oModel:= MPFormModel():New("TGVA001",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
    oModel:AddFields("A1SMASTER",/*cOwner*/,oStructA1S,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
    oModel:GetModel("A1SMASTER"):SetDescription("A1S")
    oModel:SetDescription(STR0001) //"Notificações do Vendedor"
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Interface do modelo de dados de Notificações do Vendedor para localização padrão.

	@author 	Danilo Salve
	@version	12.1.27 ou Superior
	@since		05/02/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel 		:= ModelDef()
	Local oStructA1T	:= FWFormStruct(2,"A1S",/*bAvalCampo*/,/*lViewUsado*/)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_A1S",oStructA1T,"A1SMASTER")

Return oView
