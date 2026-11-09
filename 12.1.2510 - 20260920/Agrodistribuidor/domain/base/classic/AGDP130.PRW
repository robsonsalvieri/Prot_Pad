#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "AGDP130.ch"

/*/{Protheus.doc} AGDP130
Rotina para registrar configurador de integração
@type function
@version 12
@author gilson.venturi
@since 29/07/2026
@return variant, nil
/*/
Function AGDP130()
	Local oMBrowse := Nil

	If .Not. TableInDic('NF9')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NF9" )
	oMBrowse:SetDescription( FwSX2Util():GetX2Name("NF9") )  //Configurador de Integração

	if hasSmartX()
		oMBrowse:setSmartX()
	endIf

	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu
@type function
@version 12
@author gilson.venturi
@since 29/07/2026
@return variant, nil
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDP130"

    ADD OPTION aRotina TITLE STR0002 ACTION cAction OPERATION 2 ACCESS 0  //"Visualizar"
    ADD OPTION aRotina TITLE STR0003 ACTION cAction OPERATION 3 ACCESS 0  //"Incluir"
    ADD OPTION aRotina TITLE STR0004 ACTION cAction OPERATION 4 ACCESS 0  //"Alterar"
    ADD OPTION aRotina TITLE STR0005 ACTION cAction OPERATION 5 ACCESS 0  //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Model do AGDP130
@type function
@version 12
@author gilson.venturi
@since 29/07/2026
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNF9  := FwFormStruct( 1, "NF9" )
	Local oEvent    := AGDP130EVT():New()

	oModel := MpFormModel():New( "AGDP130" )
	oModel:SetDescription(  FwSX2Util():GetX2Name("NF9") )  //Configurador de Integração

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDP130_NF9", , oStruNF9)
	oModel:GetModel( "AGDP130_NF9" ):SetDescription(  FwSX2Util():GetX2Name("NF9") )  //Movimentações Cotas Cooperados
	oModel:SetPrimaryKey( { "NF9_FILIAL", "NF9_TPVEND", "NF9_OPINTE", "NF9_CMDTY" } )

	oModel:InstallEvent("AGDP130EVT", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author gilson.venturi
@since 29/07/2026
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDP130" )
	Local oStruNF9  := FwFormStruct( 2, "NF9" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NF9', oStruNF9, 'AGDP130_NF9' )

	oView:CreateHorizontalBox( 'CABEC', 100 )
	oView:SetOwnerView( 'VIEW_NF9', 'CABEC' )
	oView:EnableTitleView("VIEW_NF9")
	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} P100NNIPRO
Filtro da consulta padrão(SXB) NNINF9 - filtra os dados para o campo produto NF9_CMDTY
@type function
@version P12
@author gilson.venturi
@since 29/07/2026
@return character, filtro SQL com as condições para retorno
/*/
Function P100NNIPRO(cCodProd)
	Local cQry	:=	""
	Local oModel	:=	FwModelActive()
	Default cCodProd := ""

	If ValType(oModel) == "O" .and. oModel:GetId() == "AGDP130"
		cCodProd := oModel:GetModel("AGDP130_NF9"):GetValue("NF9_CMDTY")
	EndIf

	// Construção do filtro, garantindo a conexão com NNI_CODIGO
	cQry += "@ D_E_L_E_T_ = ' ' "
	cQry += " AND NNI_FILIAL = '" + FWxFilial("NNI") + "' "
	cQry += " AND (NNI_CODPRO = '" + cCodProd + "' OR NNI_CODPRO = ' ') "

Return cQry
