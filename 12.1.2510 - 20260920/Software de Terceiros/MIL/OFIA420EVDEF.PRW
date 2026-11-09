#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA420.CH"

CLASS OFIA420EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD FieldPreVld()
	METHOD GridPreVld()

ENDCLASS


METHOD New() CLASS OFIA420EVDEF

RETURN .T.


METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFIA420EVDEF
Local lRet    := .t.
Local cQuery  := ""
Local nCntFor := 0
Local oMod420
Local oDet420
Local oVie420
If cModelId == "VBKMASTER"
	If cAction == "SETVALUE" // Valid do campo
		If cId == "VBK_ATIVO"
			If xValue == "0" // Selecionou 0-Não Ativo
				oVie420 := FWViewActive()
				oMod420 := FWModelActive()
				oDet420 := oMod420:GetModel("VBLDETAIL")
				For nCntFor := 1 to len(oDet420:aDataModel)
					oDet420:GoLine(nCntFor)
					oDet420:LoadValue("VBL_ATIVO","0")
				Next
				oDet420:GoLine(1)
				oVie420:Refresh()
			Else
				cQuery := "SELECT R_E_C_N_O_ AS RECVBK "
				cQuery += "  FROM " + RetSqlName("VBK")
				cQuery += " WHERE VBK_FILIAL = '" + xFilial("VBK") + "'"
				cQuery += "   AND VBK_ATIVO  = '1'" // ativo
				cQuery += "   AND VBK_CODIGO <> '" + oSubModel:GetValue("VBK_CODIGO") + "'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				If FM_SQL(cQuery) > 0
					lRet := .f.
					Help("",1,"VALIDVBK",,STR0011,1,0) // Já existe Cadastro Ativo.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RETURN lRet


METHOD GridPreVld(oSubModel, cModelId, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA420EVDEF
Local lRet    := .t.
Local cConPag := ""
Local nCntFor := 0
Local oMod420
Local oMst420
If cModelId == "VBLDETAIL"
	If cAction == "CANSETVALUE"
		If cId == "VBL_ATIVO"
			oMod420 := FWModelActive()
			oMst420 := oMod420:GetModel("VBKMASTER")
			If oMst420:GetValue("VBK_ATIVO") == "0" // 0 = Não ATIVO
				lRet := .f.
			EndIf
		EndIf
	ElseIf cAction == "SETVALUE" // Valid do campo
		If cId == "VBL_ATIVO"
			If xValue == "1" // Selecionou 1-Ativo
				cConPag := oSubModel:GetValue("VBL_CONPAG")
			EndIf
		ElseIf cId == "VBL_CONPAG"
			If oSubModel:GetValue("VBL_ATIVO") == "1" // Esta 1-Ativo
				cConPag := xValue
			EndIf
		EndIf
		If !Empty(cConPag)
			For nCntFor := 1 to len(oSubModel:aDataModel)
				If nLine <> nCntFor
					oSubModel:GoLine(nCntFor)
					If cConPag == oSubModel:GetValue("VBL_CONPAG") .and. oSubModel:GetValue("VBL_ATIVO") == "1"
						lRet := .f.
						Help("",1,"VALIDVBL",,STR0012,1,0) // Já existe a mesma Condição de Pagamento com Remuneração Ativa.
						Exit
					EndIf
				EndIf
			Next
			oSubModel:GoLine(nLine)
		EndIf
	EndIf
EndIf
RETURN lRet