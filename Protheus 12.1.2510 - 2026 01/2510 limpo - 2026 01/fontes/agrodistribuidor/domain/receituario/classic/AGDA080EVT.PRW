#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "agda080.ch"

/*/{Protheus.doc} AGDA080EVT
Classe de eventos do modelo do AGDA080
@author carlos.augusto
@since 25/11/2025
/*/
Class AGDA080EVT From FWModelEvent
	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
	Method Activate(oModel, lCopy) Public
	Method AfterTTS(oModel, cModelId)
End Class

/*/{Protheus.doc} New
Constructor
@author carlos.augusto
@since 25/11/2025
@return variant, self
/*/
Method New() Class AGDA080EVT
Return Nil

/*/{Protheus.doc} Activate
@author carlos.augusto
@since 25/11/2025
@param oModel, object, modelo
@param lCopy, character, modelo id
/*/
Method Activate(oModel, lCopy) Class AGDA080EVT
	Local aArea		:= GetArea()
	Local oMldNER 	:= oModel:GetModel('NER_CAB')

	If oModel:GetOperation() == MODEL_OPERATION_INSERT 
		oMldNER:LoadValue("NER_FILIAL", FWxFilial("NER"))
		oMldNER:LoadValue("NER_DOC",    SF1->F1_DOC)
		oMldNER:LoadValue("NER_SERIE",  SF1->F1_SERIE)
		oMldNER:LoadValue("NER_FORNEC", SF1->F1_FORNECE)
		oMldNER:LoadValue("NER_LOJA",   SF1->F1_LOJA)
	EndIf
	RestArea(aArea)

return nil

/*/{Protheus.doc} AfterTTS - Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
@author carlos.augusto
@since 25/11/2025
@param oModel, object, modelo
@param lCopy, character, modelo id
/*/
Method AfterTTS(oModel, cModelId) Class AGDA080EVT
	Local aAreaNER := NER->(GetArea())
	Local oMdlRec  := oModel:GetModel("NER_RECEIT")
	Local oMdlGuia := oModel:GetModel("NER_GUIA")
	Local oMldNER  := oModel:GetModel('NER_CAB')

	AGDA80CURA(oMldNER,oMdlRec)
	AGDA80CURA(oMldNER,oMdlGuia)

	RestArea(aAreaNER)
return nil


/*/{Protheus.doc} AGDA80CURA - Incluir registro caso não exista após o commit
@author carlos.augusto
@since 25/11/2025
@param oModel, object, modelo
@param lCopy, character, modelo id
/*/
Function AGDA80CURA(oMldNER, oSubModel)
	Local nX       := 1
	Local cTpVinc  := IIF(oSubModel:GetId() = "NER_GUIA","2","1")

	For nX := 1 To oSubModel:Length()
		oSubModel:GoLine(nX)
		If !oSubModel:IsDeleted()
			NER->(DbSetOrder(1))
			If !NER->(DbSeek(oMldNER:GetValue("NER_FILIAL") + oMldNER:GetValue("NER_DOC") + oMldNER:GetValue("NER_SERIE") + oMldNER:GetValue("NER_FORNEC") +;
			 				 oMldNER:GetValue("NER_LOJA")   + cTpVinc + oSubModel:GetValue("NER_ITEM")))

				//Para criar registro do item manualmente, a linha deve ter algum campo preenchido.
				If (oSubModel:GetId() = "NER_GUIA" .And. (!Empty(oSubModel:GetValue("NER_TPGUIA"));
													 .Or. !Empty(oSubModel:GetValue("NER_UF"));
													 .Or. !Empty(oSubModel:GetValue("NER_SERGUI"));
													 .Or. !Empty(oSubModel:GetValue("NER_NUMGUI")))) .Or.;
				   (oSubModel:GetId() = "NER_RECEIT" .And. (!Empty(oSubModel:GetValue("NER_NUMREC"));
				   									  .Or. !Empty(oSubModel:GetValue("NER_CGC"))))

					RecLock("NER",.T.)
						NER->NER_FILIAL := oMldNER:GetValue("NER_FILIAL")
						NER->NER_DOC    := oMldNER:GetValue("NER_DOC")
						NER->NER_SERIE  := oMldNER:GetValue("NER_SERIE")
						NER->NER_FORNEC := oMldNER:GetValue("NER_FORNEC")
						NER->NER_LOJA   := oMldNER:GetValue("NER_LOJA")
						NER->NER_TPVINC := cTpVinc
						NER->NER_ITEM   := oSubModel:GetValue("NER_ITEM")
						NER->NER_NUMREC := oSubModel:GetValue("NER_NUMREC")
						NER->NER_CGC    := oSubModel:GetValue("NER_CGC")
						NER->NER_TPGUIA := oSubModel:GetValue("NER_TPGUIA")
						NER->NER_UF     := oSubModel:GetValue("NER_UF")
						NER->NER_SERGUI := oSubModel:GetValue("NER_SERGUI")
						NER->NER_NUMGUI := oSubModel:GetValue("NER_NUMGUI")
					NER->(MsUnlock())
				EndIf
			EndIf
		EndIf
	Next nX
Return

/*/{Protheus.doc} AGDA80CURA - Incluir registro caso não exista após o commit
@author carlos.augusto
@since 25/11/2025
@param oModel, object, modelo
@param lCopy, character, modelo id
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA080EVT
	Local aAreaNER := NER->(GetArea())
	Local oMdlRec  := oModel:GetModel("NER_RECEIT")
	Local oMdlGuia := oModel:GetModel("NER_GUIA")
	Local oMldNER  := oModel:GetModel('NER_CAB')
	Local lRet     := .T.

	If oModel:getOperation() == MODEL_OPERATION_INSERT
		lRet := AGDA80VLDG(oMldNER,oMdlRec)
		If !lRet
			lRet := AGDA80VLDG(oMldNER,oMdlGuia)
		EndIf
		If !lRet
			oModel:SetErrorMessage(,,,,,STR0010) // "Receituário ou Guia de Trânsito não informados."
			Return .F.
		EndIf
	Endif

	RestArea(aAreaNER)
Return lRet


/*/{Protheus.doc} AGDA80VLDG - valida se todos os campos estão vazios ao confirmar
@author carlos.augusto
@since 25/11/2025
@param oModel, object, modelo
@param lCopy, character, modelo id
/*/
Function AGDA80VLDG(oMldNER, oSubModel)
	Local nX       := 1

	For nX := 1 To oSubModel:Length()
		oSubModel:GoLine(nX)
		If !oSubModel:IsDeleted()
			//Valida se algo foi preenchido nos dois grids
			If (oSubModel:GetId() = "NER_GUIA" .And. (Empty(oSubModel:GetValue("NER_TPGUIA"));
													.And. Empty(oSubModel:GetValue("NER_UF"));
													.And. Empty(oSubModel:GetValue("NER_SERGUI"));
													.And. Empty(oSubModel:GetValue("NER_NUMGUI")))) .Or.;
				(oSubModel:GetId() = "NER_RECEIT" .And. (Empty(oSubModel:GetValue("NER_NUMREC"));
													.And. Empty(oSubModel:GetValue("NER_CGC"))))
				Return .F.
			EndIf
		EndIf
	Next nX
Return .T.
