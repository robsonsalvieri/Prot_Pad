#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS OFIA004EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
    METHOD Activate()
    METHOD ModelPosVld()

ENDCLASS

// New //
METHOD New() CLASS OFIA004EVDEF
RETURN SELF

// Abertura TELA //
METHOD Activate(oModel, lCopy) CLASS OFIA004EVDEF
	Local oModSB1 := oModel:GetModel("SB1MASTER")
    SB5->(DbSetOrder(1))
    SB5->(MsSeek(xFilial("SB5")+oModSB1:GetValue("B1_COD")))
    oModSB1:LoadValue("B5_LOCALI2",FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"))
RETURN .T.

// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS OFIA004EVDEF
	Local nCntFor := 0
	Local nTamSeq := 0
	Local cSequen := ""
	Local oStrVBU
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE // Incluir ou Alterar
		nTamSeq := GetSx3Cache("VBU_SEQUEN","X3_TAMANHO")
		oStrVBU := oModel:GetModel("VBUDETAIL")
		For nCntFor := 1 to oStrVBU:Length()
			oStrVBU:GoLine(nCntFor)
			If Empty(oStrVBU:GetValue('VBU_ALMOXA')) .and. Empty(oStrVBU:GetValue('VBU_LOCAUX'))
				oStrVBU:DeleteLine()
			EndIf
			If !oStrVBU:IsDeleted()
				cSequen := strzero(val(oStrVBU:GetValue('VBU_SEQUEN')),nTamSeq)
				oStrVBU:SetValue( "VBU_SEQUEN" , cSequen )
			EndIf
		Next
	EndIf
RETURN .t.