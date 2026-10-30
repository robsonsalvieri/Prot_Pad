#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#INCLUDE "AGDA160.CH"

#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDA160
Cadastro do histórico da posição atual do cooperado para geração
do Informe de Rendimentos sobre Capital Social.
@type function
@version 12
@author rodrigo.nsoledade
@since 06/08/2026
/*/
Function AGDA160()
	Local oMBrowse := Nil

	If !FWAliasInDic("NF0")
		MsgNextRel() // É necessário atualizar o sistema para a expedição mais recente.
		Return Nil
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("NF0")
	oMBrowse:SetDescription(FwSX2Util():GetX2Name("NF0"))
	oMBrowse:AddLegend("NF0_STATUS == '1'","GREEN",X3Combo("NF0_STATUS","1"))
	oMBrowse:AddLegend("NF0_STATUS == '2'","RED"  ,X3Combo("NF0_STATUS","2"))

	If hasSmartX()
		oMBrowse:SetSmartX()
	EndIf

	oMBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
Define as opções disponíveis na rotina de Informe de Rendimentos
sobre Capital Social.
@type function
@version 12
@author rodrigo.nsoledade
@since 06/08/2026
@return array, opções da rotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001      ACTION "VIEWDEF.AGDA160" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE STR0002      ACTION "AGDA160GER()"    OPERATION 3 ACCESS 0 //"Gerar Informe"
	ADD OPTION aRotina TITLE STR0009	  ACTION "AGDA160RPT(1)"   OPERATION 8 ACCESS 0 //"Imprimir Informe"
	ADD OPTION aRotina TITLE STR0010	  ACTION "AGDA160RPT(2)"   OPERATION 4 ACCESS 0 //"Imprimir Informe Cooperado"

Return aRotina

/*/{Protheus.doc} ModelDef
Define o modelo de dados do cadastro de Informe de Rendimentos
sobre Capital Social.
@type function
@version 12
@author rodrigo.nsoledade
@since 06/08/2026
@return object, modelo MVC
/*/
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNF0 := FWFormStruct(1,"NF0")

	oModel := MPFormModel():New("AGDA160")
	oModel:AddFields("NF0MASTER",Nil,oStructNF0)

	oModel:SetPrimaryKey({;
		"NF0_FILIAL",;
		"NF0_CODCOO",;
		"NF0_LOJCOO",;
		"NF0_ANOEXE",;
		"NF0_DTGERA",;
		"NF0_HRGERA"})

	oModel:GetModel("NF0MASTER"):SetDescription(FwSX2Util():GetX2Name("NF0"))

Return oModel

/*/{Protheus.doc} ViewDef
Define a interface MVC do cadastro de Informe de Rendimentos
sobre Capital Social.
@type function
@version 12
@author rodrigo.nsoledade
@since 06/08/2026
@return object, view MVC
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("AGDA160")
	Local oStructNF0 := FWFormStruct(2,"NF0")
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_NF0",oStructNF0,"NF0MASTER")

	oView:CreateHorizontalBox("BOX_NF0",100)
	oView:SetOwnerView("VIEW_NF0","BOX_NF0")
	oView:EnableTitleView("VIEW_NF0",FwSX2Util():GetX2Name("NF0"))
Return oView

/*/{Protheus.doc} AGDA160GER
Gera os registros de Informe de Rendimentos sobre Capital Social
conforme os filtros informados no grupo de perguntas AGDA160.
@type function
@version 12
@author rodrigo.nsoledade
@since 10/08/2026
/*/
Function AGDA160GER()
	Local aAreaAtual      := GetArea()
	Local cFilialDe       := ""
	Local cFilialAte      := ""
	Local cCoopDe         := ""
	Local cCoopAte        := ""
	Local cAnoRef         := ""
	Local cRespCTB        := ""
	Local cMatricDe       := ""
	Local cMatricAte      := ""
	Local cFilPgdora	  := ""
	Local lReprocess      := .F.
	Local oIncomeService  := Nil

	If !FWAliasInDic("NF0")
		MsgNextRel()
		Return Nil
	EndIf

	If !Pergunte("AGDA160",.T.)
		Return Nil
	EndIf

	cFilialDe  := MV_PAR01
	cFilialAte := MV_PAR02
	cCoopDe    := MV_PAR03
	cCoopAte   := MV_PAR04
	cAnoRef    := MV_PAR05
	cRespCTB   := MV_PAR06
	cMatricDe  := MV_PAR07
	cMatricAte := MV_PAR08
	cFilPgdora := MV_PAR09

	oIncomeService := NAMESPACEAGD.QuotaIncomeStatementService():New()

	// Verifica se o período informado já possui histórico gerado.
	lReprocess := oIncomeService:hasHistory(cFilialDe,cFilialAte,cCoopDe,cCoopAte,cAnoRef,cMatricDe,cMatricAte)

	If lReprocess .And. ;
		!FWAlertYesNo(STR0005 + CRLF + STR0006,STR0003)

		FWFreeObj(oIncomeService)
		RestArea(aAreaAtual)
		Return Nil
	EndIf

	// A consulta, reprocessamento, transação e gravação ficam centralizados no service.
	oIncomeService:generate(cFilialDe,cFilialAte,cCoopDe,cCoopAte,cAnoRef,cRespCTB,cMatricDe,cMatricAte,cFilPgdora,lReprocess)

	If !oIncomeService:isSuccess()
		AGDHELP(STR0003, oIncomeService:getMessageError())
	EndIf

	FWFreeObj(oIncomeService)
	RestArea(aAreaAtual)
Return Nil


/*/{Protheus.doc} AGDA160RPT
    Chamada para relatório Smart View
    @type  Function
    @author carlos.augusto
    @since 25/08/2026
    @version 1.0
    @see (DAGRODIST-4908)
    /*/
Function AGDA160RPT(nOpc)

	IF nOpc == 1
		AGDSV001()
	Else
		If NF0->NF0_STATUS != "1"
			AGDHELP(STR0003, STR0011)//Atenção!"Não é possível realizar a impressão de registro inativo." 
		Else
			AGDSV001(NF0->NF0_FILIAL,NF0->NF0_CODCOO,NF0->NF0_LOJCOO,NF0->NF0_ANOCAL,NF0->NF0_CODCTB)
		EndIf
	EndIf

Return Nil
