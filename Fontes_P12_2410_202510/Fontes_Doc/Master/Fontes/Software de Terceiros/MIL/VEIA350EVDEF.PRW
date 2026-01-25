#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "VEIA350.CH"

CLASS VEIA350EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD GridLinePreVld()
	METHOD ModelPosVld()

ENDCLASS

// New //
METHOD New() CLASS VEIA350EVDEF
RETURN SELF

// Abertura TELA //
METHOD Activate(oModel, lCopy) CLASS VEIA350EVDEF
	Local oModVW1
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE // Incluir ou Alterar
		oModVW1 := oModel:GetModel("VW1DETAIL")
		If oModVW1:Length() == 1
			oModVW1:GoLine(1)
			oModVW1:LoadValue("VW1_CODCLI" , M->VV9_CODCLI )
			oModVW1:LoadValue("VW1_LOJCLI" , M->VV9_LOJA )
			oModVW1:LoadValue("VW1_NOMCLI" , Left(M->VV9_NOMVIS,GetSX3Cache("VW1_NOMCLI","X3_TAMANHO")))
		EndIf
	EndIf
RETURN .T.

// Campos Filhos //
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA350EVDEF
Local lRet    := .t.
Local nCntFor := 0
Local oView
Local oModel
Local oModVW1
If cModelID == "VW1DETAIL"
	If cAction == "CANSETVALUE" 
		If nLine == 1 .and. cId $ "VW1_CODCLI/VW1_LOJCLI/" // Nao deixa alterar o Cliente e a Loja da primeira linha
			lRet := .f.
		ElseIf nLine <> 1 // Quando vai digitar qualquer linha, verifica se a 1a.linha esta valida (não deletada)
			oView   := FWViewActive()
			oModel  := FWModelActive()
			oModVW1 := oModel:GetModel("VW1DETAIL")
			oModVW1:GoLine(1)
			If oModVW1:IsDeleted() // Caso a 1a.linha esta Deletada, não deixa preencher nova linha
				lRet := .f.
			EndIf
		EndIf
	ElseIf cAction == "DELETE" // Deixa deletar
		If nLine == 1
			oView   := FWViewActive()
			oModel  := FWModelActive()
			oModVW1 := oModel:GetModel("VW1DETAIL")
			For nCntFor := 2 to oModVW1:Length()
				oModVW1:GoLine(nCntFor)
				oModVW1:DeleteLine()
			Next
			oModVW1:GoLine(1)
			oView:Refresh()
		EndIf
	ElseIf cAction == "UNDELETE"
		If nLine <> 1
			oView   := FWViewActive()
			oModel  := FWModelActive()
			oModVW1 := oModel:GetModel("VW1DETAIL")
			oModVW1:GoLine(1)
			oModVW1:UnDeleteLine()
			oModVW1:GoLine(nLine)
			oView:Refresh()
		EndIf
	EndIf
EndIf
RETURN lRet

// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS VEIA350EVDEF
	Local lRet    := .t.
	Local nCntFor := 0
	Local nPerc   := 0
	Local oModVW1
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE // Incluir ou Alterar
		oModVW1 := oModel:GetModel("VW1DETAIL")
		For nCntFor := 1 to oModVW1:Length()
			oModVW1:GoLine(nCntFor)
			If !oModVW1:IsDeleted()
				nPerc += oModVW1:GetValue("VW1_PERVEI")
			EndIf
		Next
		If nPerc > 0 .and. nPerc <> 100
			FMX_HELP("VEIA350_PERC",STR0011+": "+Transform(nPerc,"@E 999.99")+" %",STR0012) // Total de % das Máquinas/Veiculos dos clientes / É necessário que a soma dos % das Máquinas/Veiculos dos clientes atinjam 100 %
			lRet := .f.
		EndIf
	EndIf
RETURN lRet