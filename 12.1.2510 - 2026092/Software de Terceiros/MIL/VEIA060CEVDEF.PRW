#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "VEIA060CEVDEF.CH"

Class VEIA060CEVDEF From FWModelEvent

	Method New() Constructor
	Method GridLinePreVld()
	Method VldActivate()
		
EndClass

Method New() Class VEIA060CEVDEF


Return()


Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cID, xValue, xCurrentValue) Class VEIA060CEVDEF

	Local lRet := .T.

	If cModelID == "MODEL_VRK"

		If cAction == "CANSETVALUE"
			If oSubModel:GetValue("VRK_CANCEL") == "1"
				lRet := .F.
			ElseIf !Empty(oSubModel:GetValue("VRK_NUMTRA"))
				lRet := .F.
			EndIf
		
		EndIf

	EndIf

Return(lRet)


METHOD VldActivate(oModel, cModelId) CLASS VEIA060CEVDEF

	Local lRet       := .T.
	Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_UPDATE
		If VRJ->VRJ_STATUS $ "C/R/A"
			FMX_HELP("VA060CERR001", STR0001) // "Alteração não permitida para pedidos Em Aberto, Cancelados ou Reprovados."
			lRet := .f.
		EndIf
		If (VRJ->VRJ_STATUS <> "A" .or. Empty(VRJ->VRJ_STATUS))
			
			// Configura limitações de edição do pedido ...
			oModel:GetModel("MODEL_VRK"):SetNoInsertLine(.t.)
			oModel:GetModel("MODEL_VRK"):SetNoDeleteLine(.t.)

		EndIf
	EndIf

Return(lRet)
