#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA070.CH"

/*/{Protheus.doc} AGDA070EVT
Classe de eventos do modelo do AGDA070
@type class
@version P12
@author scheronlini.martins
@since 26/11/2025
/*/
Class AGDA070EVT From FWModelEvent
	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
	Method Activate(oModel) Public
	Method AfterTTS(oModel, cModelId)
End Class

/*/{Protheus.doc} AGDA070EVT::New
Constructor
@type method
@version P12
@author scheronlini.martins
@since 26/11/2025
/*/
Method New() Class AGDA070EVT
Return Nil

/*/{Protheus.doc} AGDA070EVT::Activate
Ativação do Modelo
@type method
@version p12 
@author scheronlini.martins
@since 26/11/2025
@param oModel, object, modelo
/*/
Method Activate(oModel) Class AGDA070EVT
	Local aArea		:= GetArea()
	Local oMldNES 	:= oModel:GetModel('AGDA070_SF2')

	If oModel:GetOperation() == MODEL_OPERATION_INSERT 
		oMldNES:LoadValue("NES_FILIAL", FWxFilial("NES"))
		oMldNES:LoadValue("NES_DOC",    SF2->F2_DOC)
		oMldNES:LoadValue("NES_SERIE",  SF2->F2_SERIE)
		oMldNES:LoadValue("NES_CLIENT", SF2->F2_CLIENTE)
		oMldNES:LoadValue("NES_LOJA",   SF2->F2_LOJA)
	EndIf
	RestArea(aArea)

return nil

/*/{Protheus.doc} AGDA070EVT::AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
@type method
@version p12
@author scheronlini.martins
@since 26/11/2025
@param oModel, object, modelo
@param cModelId, character, id
/*/
Method AfterTTS(oModel, cModelId) Class AGDA070EVT
	Local aAreaNES := NES->(GetArea())
	Local oMdlRec  := oModel:GetModel("NES_RECE")
	Local oMdlGuia := oModel:GetModel("NES_GUIA")
	Local oMldNES  := oModel:GetModel('AGDA070_SF2')

	AGDA70CURA(oMldNES,oMdlRec)
	AGDA70CURA(oMldNES,oMdlGuia)

	RestArea(aAreaNES)
return nil

/*/{Protheus.doc} AGDA70CURA
Incluir registro caso não exista após o commit
@type function
@version p12 
@author scheronlini.martins
@since 26/11/2025
@param oMldNES, object, modelo
@param oSubModel, object, submodelo
/*/
Function AGDA70CURA(oMldNES, oSubModel)
	Local nX       := 1
	Local cTpVinc  := IIF(oSubModel:GetId() = "NES_GUIA","2","1")

	For nX := 1 To oSubModel:Length()
		oSubModel:GoLine(nX)
		If !oSubModel:IsDeleted()
			NES->(DbSetOrder(1))
			If !NES->(DbSeek(oMldNES:GetValue("NES_FILIAL") + oMldNES:GetValue("NES_DOC") + oMldNES:GetValue("NES_SERIE") + oMldNES:GetValue("NES_CLIENT") +;
			 				 oMldNES:GetValue("NES_LOJA")   + cTpVinc + oSubModel:GetValue("NES_ITEM")))

				//Para criar registro do item manualmente, a linha deve ter algum campo preenchido.
				If (oSubModel:GetId() = "NES_GUIA" .And. (!Empty(oSubModel:GetValue("NES_TPGUIA"));
													 .Or. !Empty(oSubModel:GetValue("NES_UF"));
													 .Or. !Empty(oSubModel:GetValue("NES_SERGUI"));
													 .Or. !Empty(oSubModel:GetValue("NES_NUMGUI")))) .Or.;
				   (oSubModel:GetId() = "NES_RECE" .And. (!Empty(oSubModel:GetValue("NES_NUMREC"));
				   									  .Or. !Empty(oSubModel:GetValue("NES_CGC"))))

					RecLock("NES",.T.)
						NES->NES_FILIAL := oMldNES:GetValue("NES_FILIAL")
						NES->NES_DOC    := oMldNES:GetValue("NES_DOC")
						NES->NES_SERIE  := oMldNES:GetValue("NES_SERIE")
						NES->NES_CLIENT := oMldNES:GetValue("NES_CLIENT")
						NES->NES_LOJA   := oMldNES:GetValue("NES_LOJA")
						NES->NES_TPVINC := cTpVinc
						NES->NES_ITEM   := oSubModel:GetValue("NES_ITEM")
						NES->NES_NUMREC := oSubModel:GetValue("NES_NUMREC")
						NES->NES_CGC    := oSubModel:GetValue("NES_CGC")
						NES->NES_TPGUIA := oSubModel:GetValue("NES_TPGUIA")
						NES->NES_UF     := oSubModel:GetValue("NES_UF")
						NES->NES_SERGUI := oSubModel:GetValue("NES_SERGUI")
						NES->NES_NUMGUI := oSubModel:GetValue("NES_NUMGUI")
					NES->(MsUnlock())
				EndIf
			EndIf
		EndIf
	Next nX
Return


/*/{Protheus.doc} AGDA070EVT::ModelPosVld
Pós valid
@type method
@version p12
@author scheronlini.martins
@since 26/11/2025
@param oModel, object, modelo
@param cModelId, character, id
@return variant, return_true or false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA070EVT
	Local aAreaNES := NES->(GetArea())
	Local oMdlRec  := oModel:GetModel("NES_RECE")
	Local oMdlGuia := oModel:GetModel("NES_GUIA")
	Local oMldNES  := oModel:GetModel('AGDA070_SF2')
	Local lRet     := .T.

	If oModel:getOperation() == MODEL_OPERATION_INSERT
		lRet := AGDA70VLDG(oMldNES,oMdlRec)
		If !lRet
			lRet := AGDA70VLDG(oMldNES,oMdlGuia)
		EndIf
		If !lRet
			oModel:SetErrorMessage(,,,,,STR0013) //"Receituário ou Guia de Trânsito não informados."
			Return .F.
		EndIf
	Endif

	RestArea(aAreaNES)
Return lRet

/*/{Protheus.doc} AGDA70VLDG
valida se todos os campos estão vazios ao confirmar
@type function
@version  p12
@author scheronlini.martins
@since 26/11/2025
@param oMldNES, object, modelo
@param oSubModel, object, submodelo
@return variant, true or false
/*/
Function AGDA70VLDG(oMldNES, oSubModel)
	Local nX       := 1

	For nX := 1 To oSubModel:Length()
		oSubModel:GoLine(nX)
		If !oSubModel:IsDeleted()
			//Valida se algo foi preenchido nos dois grids
			If (oSubModel:GetId() = "NES_GUIA" .And. (Empty(oSubModel:GetValue("NES_TPGUIA"));
													.And. Empty(oSubModel:GetValue("NES_UF"));
													.And. Empty(oSubModel:GetValue("NES_SERGUI"));
													.And. Empty(oSubModel:GetValue("NES_NUMGUI")))) .Or.;
				(oSubModel:GetId() = "NES_RECE" .And. (Empty(oSubModel:GetValue("NES_NUMREC"));
													.And. Empty(oSubModel:GetValue("NES_CGC"))))
				Return .F.
			EndIf
		EndIf
	Next nX
Return .T.
