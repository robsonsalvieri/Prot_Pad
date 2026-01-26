#include 'TOTVS.ch'
#include "PROTHEUS.CH"
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "OFINJD49.CH" // mesmo CH do OFINJD49

CLASS OFINJD49EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
	METHOD VldActivate()
	METHOD DeActivate()

ENDCLASS


METHOD New() CLASS OFINJD49EVDEF

RETURN .T.

METHOD VldActivate(oModel, cModelId) CLASS OFINJD49EVDEF

	SetKey(VK_F10,{|| Pergunte('OFINJD49',.t.) })

RETURN .T.

METHOD DeActivate(oModel) CLASS OFINJD49EVDEF

	SetKey(VK_F10, Nil )

RETURN .T.

METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFINJD49EVDEF

	Local lB1CODFAB := (SB1->(FieldPos("B1_CODFAB")) <> 0)
	Local lRetorno  := .t.
	Local aConvUM   := {}

	If cModelId == "VMCPECA"
	
		If cAction == "SETVALUE"

			If cId == "VMC_GRUITE"
				
				lRetorno := ExistCPO("SBM",xValue)
				If lRetorno

					If !Empty(oSubModel:GetValue("VMC_CODITE"))
						oSubModel:LoadValue("VMC_CODITE", Space(GetSX3Cache("VMC_CODITE","X3_TAMANHO")) )
					EndIf

					If !Empty(oSubModel:GetValue("VMC_DESCRI"))
						oSubModel:LoadValue("VMC_DESCRI", Space(GetSX3Cache("VMC_DESCRI","X3_TAMANHO")) )
					EndIf

					If !Empty(oSubModel:GetValue("VMC_PARTNO"))
						oSubModel:LoadValue("VMC_PARTNO", Space(GetSX3Cache("VMC_PARTNO","X3_TAMANHO")) )
					EndIf

				EndIf

			ElseIf cId == "VMC_CODITE"

				SB1->(dbSetOrder(7))
				lRetorno := SB1->(dbSeek(xFilial("SB1") + oSubModel:GetValue("VMC_GRUITE") + xValue ))
				If lRetorno

					// Conversao de Unidade de Medida
					If !Empty(MV_PAR38)
						aConvUM := StrTokArr(AllTrim(MV_PAR38),";")
					Else
						AADD( aConvUM , "BD/L " )
					EndIf

					cUM := SB1->B1_UM
					If (nPosConvUM := aScan(aConvUM,{ |x| SB1->B1_UM $ AllTrim(x) })) <> 0
						aAuxConv := StrTokArr(aConvUM[nPosConvUM],"/")

						If Len(aAuxConv) == 2 .and. AllTrim(aAuxConv[1]) == AllTrim(SB1->B1_UM) .and. AllTrim(aAuxConv[2]) == AllTrim(SB1->B1_SEGUM)
							cUM   := SB1->B1_SEGUM
						EndIf
					EndIf

					oSubModel:LoadValue("VMC_UM"    , cUM )
					oSubModel:LoadValue("VMC_PARTNO", Subs(IIf(lB1CODFAB .and. !Empty(SB1->B1_CODFAB), SB1->B1_CODFAB , SB1->B1_CODITE ),1,GetSX3Cache("VMC_PARTNO","X3_TAMANHO")) )
					oSubModel:SetValue("VMC_DESCRI", SB1->B1_DESC )
				Else

					If !Empty(oSubModel:GetValue("VMC_DESCRI"))
						oSubModel:SetValue("VMC_DESCRI", Space(GetSX3Cache("VMC_DESCRI","X3_TAMANHO")) )
					EndIf

					If !Empty(oSubModel:GetValue("VMC_PARTNO"))
						oSubModel:SetValue("VMC_PARTNO", Space(GetSX3Cache("VMC_PARTNO","X3_TAMANHO")) )
					EndIf

					FMX_HELP("OFNJD49E001", STR0011, STR0012) //"Produto não encontrado." //"Verifique se o código digitado existe para o grupo de item informado."

				endif
			
			EndIf

		EndIf

	EndIf

RETURN lRetorno
