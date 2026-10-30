#Include "agda145.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGDA145
Lista de Titulos Financeiros do Movimento
@type function
@version 12
@author jean.schulze
@since 7/13/2026
@return variant, nil
/*/
Function AGDA145(cCooperado, cLoja, cIdMov)
	Local oMBrowse := Nil

	If .Not. TableInDic('NF6')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NF6" )
	oMBrowse:SetDescription( FwSX2Util():GetX2Name("NF6") )  //Movimentações Cotas Cooperados
	
	/*if hasSmartX()
		oMBrowse:setSmartX()
		if !Empty(cCooperado) .and. !Empty(cLoja) .and. !Empty(cIdMov)
			oMBrowse:AddFilterSmartX("@ NF6_CODCOO = '"+ cCooperado +"' AND NF6_LOJCOO = '"+ cLoja +"' AND NF6_IDMOV = '"+ cIdMov +"'")
		Endif
	endIf*/

	if !Empty(cCooperado) .and. !Empty(cLoja) .and. !Empty(cIdMov)
		oMBrowse:SetFilterDefault("NF6->NF6_CODCOO == '"+ cCooperado +"' .and. NF6->NF6_LOJCOO == '"+ cLoja +"' .and. NF6->NF6_IDMOV == '"+ cIdMov +"'")
	Endif
	

	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0001 Action 'VIEWDEF.AGDA145' OPERATION 2 ACCESS 0  //STR0001 //"Visualizar"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Modelo de Dados
@type function
@version 12
@author jean.schulze
@since 7/13/2026
@return variant, oModel
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNF6  := FwFormStruct( 1, "NF6" )

	oModel := MpFormModel():New( "AGDA145" )
	oModel:SetDescription( FwSX2Util():GetX2Name("NF6") )  //"Conta de Cotas e Valores Cooperado"

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA145_NF6", , oStruNF6)
	oModel:GetModel( "AGDA145_NF6" ):SetDescription(  FwSX2Util():GetX2Name("NF6") )  //"Conta de Cotas e Valores Cooperado"
	oModel:SetPrimaryKey( { "NF6_FILIAL", "NF6_CODCOO", "NF6_LOJCOO",  "NF6_IDMOV", "NF6_PARTIT" } )

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA145" )
	Local oStruNF6  := FwFormStruct( 2, "NF6" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NF6', oStruNF6, 'AGDA145_NF6' )
	
	oView:CreateHorizontalBox( 'CABEC', 100 )
	oView:SetOwnerView( 'VIEW_NF6', 'CABEC' )
	oView:EnableTitleView("VIEW_NF6")
	oView:SetCloseOnOk({||.T.})

Return oView
