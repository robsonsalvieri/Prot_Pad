#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP120.CH"

PUBLISH MODEL REST NAME AGDP120

/*/{Protheus.doc} AGDP120
Browse do Programa de Tipo de Movimentação de Cotas - NF5
@type function
@version 12
@author ronery.filho
@since 26/06/2026
/*/
Function AGDP120()
	Local oMBrowse := Nil

	If !FWAliasInDic("NF5")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("NF5")
	oMBrowse:SetDescription(FwSX2Util():GetX2Name("NF5"))
	oMBrowse:DisableDetails()
	oMBrowse:AddLegend("NF5_TIPO=='1'","BLUE"   ,X3Combo( "NF5_TIPO", "1" ))	
	oMBrowse:AddLegend("NF5_TIPO=='2'","GREEN"  ,X3Combo( "NF5_TIPO", "2" ))	
	oMBrowse:AddLegend("NF5_TIPO=='3'","YELLOW" ,X3Combo( "NF5_TIPO", "3" ))
	oMBrowse:AddLegend("NF5_TIPO=='4'","RED"    ,X3Combo( "NF5_TIPO", "4" ))
	oMBrowse:AddLegend("NF5_TIPO=='5'","ORANGE" ,X3Combo( "NF5_TIPO", "5" ))
	oMBrowse:AddLegend("NF5_TIPO=='6'","GRAY"   ,X3Combo( "NF5_TIPO", "6" ))
	oMBrowse:AddLegend("NF5_TIPO=='7'","PINK"   ,X3Combo( "NF5_TIPO", "7" ))

	if hasSmartX()
		oMBrowse:setSmartX()
	endIf

	oMBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
Menu da Rotina
@type function
@version 12
@author ronery.filho
@since 26/06/2026
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDP120"
	Local nAccess := 0

	ADD OPTION aRotina Title STR0001 Action cAction     OPERATION OP_VISUALIZAR ACCESS nAccess
	ADD OPTION aRotina Title STR0002 Action cAction     OPERATION OP_INCLUIR	ACCESS nAccess
	ADD OPTION aRotina Title STR0003 Action cAction     OPERATION OP_ALTERAR	ACCESS nAccess
	ADD OPTION aRotina Title STR0004 Action cAction     OPERATION OP_EXCLUIR	ACCESS nAccess
	
Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de Dados
@type function
@version 12
@author ronery.filho
@since 26/06/2026
/*/
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNF5 := FwFormStruct(1, "NF5")

	oModel:= MpFormModel():New("AGDP120")
	oModel:SetDescription(FwSX2Util():GetX2Name("NF5"))
	oModel:AddFields("AGDP120_NF5", , oStructNF5)
	oModel:SetPrimaryKey({"NF5_FILIAL", "NF5_CODIGO"})
	
	oModel:InstallEvent("AGDP120EVT", /*cOwner*/, AGDP120EVT():New())

Return oModel

/*/{Protheus.doc} ViewDef
View da Rotina
@type function
@version 12
@author ronery.filho
@since 26/06/2026
/*/
Static Function ViewDef()
	Local oView		 := FwFormView():New()
	Local oModel	 := FwLoadModel("AGDP120")
	Local oStructNF5 := FwFormStruct(2, "NF5")

	oView:SetModel(oModel)
	oView:AddField("VIEW_NF5", oStructNF5, "AGDP120_NF5")
	oView:SetCloseOnOk({ || .T.})

Return oView

/*/{Protheus.doc} AGDP120MBCX
Opções do combo de motivos de baixa
@type function
@version 12
@author jean.schulze
@since 13/08/2026
@return variant, lista de opcoes
/*/
Function AGDP120MBCX()
	Local aMotBx     := ReadMotBx()
	Local aCbxBaixa  := ""
	/*Cria combo de motivos de baixa*/
	aEval(aMotBx, {|e| aCbxBaixa := aCbxBaixa + ALLTRIM(Left(e,3)) + "=" + ALLTRIM(SubStr(e,7,10)) + ";" } )
Return aCbxBaixa

/*/{Protheus.doc} AGDP120MBVL
Validacao de Combo de Baixa
@type function
@version 12
@author jean.schulze
@since 13/08/2026
@return variant, true se motivo de baixa existe, false caso contrario
/*/
Function AGDP120MBVL()
	Local aMotBx     := ReadMotBx()
	Local aCbxBaixa  := {}
	Local lRet		:= .F.

	/*Cria lista de motivos de baixa*/
	aEval(aMotBx, {|e| aadd(aCbxBaixa, ALLTRIM(Left(e,3))) } )
	if AScanX(aCbxBaixa, M->NF5_MOTBXA ) > 0
		lRet := .T.
	endif
	
Return lRet

/*/{Protheus.doc} AGDP120BRW
Validação para o campo NF5_TMOVAD via dicionario(SX3)
@type function
@version 12
@author beatriz.dantas
@since 01/09/2026
@return Character, valor do campo para o X3_INIBRW
/*/
Function AGDP120BRW()
	Local cIniBrw  := ""
	Local aAreaNF5 := NF5->(FwGetArea())

	cIniBrw := X3CBOXDESC("NF5_TIPO", Posicione("NF5",1, xFilial("NF5")+NF5->NF5_CMOVAD, "NF5_TIPO"))

	FWRestArea(aAreaNF5)
Return cIniBrw

/*/{Protheus.doc} AGDP120REL
Validação para o campo NF5_TMOVAD via dicionario(SX3)
@type function
@version 12
@author beatriz.dantas
@since 01/09/2026
@return Character, valor do campo para o X3_RELACAO
/*/
Function AGDP120REL()
	Local aAreaNF5 := NF5->(FwGetArea())
	Local cIniBrw  := Space(TamSX3("NF5_TMOVAD")[1])

	If !Inclui
		cIniBrw := X3CBOXDESC("NF5_TIPO", Posicione("NF5",1, xFilial("NF5")+NF5->NF5_CMOVAD, "NF5_TIPO"))
	EndIf

	FWRestArea(aAreaNF5)
Return cIniBrw
