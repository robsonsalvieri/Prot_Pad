#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSA250B.CH"

/*{Protheus.doc} TMSA250B
Integração do Faturamento com Coleta/Entrega (notas avulsas)
@author Carlos Alberto Gomes Junior
@since 10/01/2023
*/
Function TMSA250B()
Local cCadastro := STR0001
Private aRotina := MenuDef()

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("DNH")
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@author Carlos Alberto Gomes Junior
@since 10/01/2023
*/
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action "AxPesqui"         OPERATION 1 ACCESS 0 //-- "Pesquisar"
	ADD OPTION aRotina Title STR0003 Action "VIEWDEF.TMSA250B" OPERATION 2 ACCESS 0 //-- "Visualizar"
	ADD OPTION aRotina Title STR0003 Action "VIEWDEF.TMSA250B" OPERATION 5 ACCESS 0 //-- "Excluir"

Return aRotina

/*{Protheus.doc} ModelDef
Definição do Modelo
@author Carlos Alberto Gomes Junior
@since 11/01/2023
*/
Static Function ModelDef()
Local oStrucDNH  := FWFormStruct(1,"DNH")
Local oModel

	oModel := MpFormModel():New("TMSA250B",/*bPreValidacao*/,/*bPosVld*/,/*bCommit*/,/*bCancel*/)

	oModel:SetDescription(STR0001)

	//-- Cabeçalho da Viagem
	oModel:AddFields("MdFieldDNH",,oStrucDNH,,,)
	oModel:SetPrimaryKey({"DNH_FILORI","DNH_NUNCTC"})
	oModel:GetModel("MdFieldDNH"):SetDescription(STR0001)

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@author Carlos Alberto Gomes Junior
@since 11/01/2023
*/
Static Function ViewDef()
Local oStrucDNH := FWFormStruct(2,"DNH")
Local oModel    := FwLoadModel("TMSA250B")
Local oView

	oView := FwFormView():New()
	oView:SetModel(oModel)
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "TelaCTC", 100 )

	//-- Define o Field da Tela Principal
	oView:AddField("VwFieldDNH",oStrucDNH,"MdFieldDNH")
	oView:SetOwnerView("VwFieldDNH","TelaCTC")

Return oView

/*{Protheus.doc} ViewDef
Função de gravação de histórico de contratos cancelados
@author Carlos Alberto Gomes Junior
@since 17/03/2023
*/
Function TMSA250BGr

Local aCposDTY 	:= {}
Local aContrFor := {}
Local nDTY := 0
Local nDNH := 0
Local aAreaDTQ := DTQ->(GetArea())

	If AliasInDic("DNH") .And. DUJ->(ColumnPos("DUJ_GRVHIS")) > 0
		DTQ->(DbSetOrder(2)) //--DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
		If DTQ->(MsSeek(xFilial('DTQ') +DTY->DTY_FILORI + DTY->DTY_VIAGEM ))
			aContrFor := aClone( TMSContrFor( DTY->DTY_CODFOR, DTY->DTY_LOJFOR, , DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA, .F., , , DTY->DTY_FILORI, DTY->DTY_VIAGEM ) )
			DUJ->(DbSetOrder(1))
			If Len(aContrFor) >= 1 .And. Len(aContrFor[1]) >= 1 .And. !Empty(aContrFor[1][1])  .And. DUJ->(MsSeek(xFilial("DUJ")+aContrFor[1][1])) .And. DUJ->DUJ_GRVHIS == "1"
				aCposDTY := DTY->(DbStruct())
				RecLock("DNH",.T.)
				DNH->DNH_FILIAL := xFilial("DNH")
				For nDTY := 1 To Len(aCposDTY)
					If Upper( AllTrim( aCposDTY[nDTY][1] ) ) != "DTY_FILIAL"
						If ( nDNH := DNH->( FieldPos( "DNH" + Substr( AllTrim( aCposDTY[nDTY][1] ), 4 ) ) ) ) > 0
							DNH->( FieldPut( nDNH, DTY->(FieldGet(nDTY) ) ) )
						EndIf
					EndIf
				Next
				MsUnLock()
				FWFreeArray(aCposDTY)
			EndIf
			FWFreeArray(aContrFor)
		EndIf
	EndIf
RestArea(aAreaDTQ)

Return
