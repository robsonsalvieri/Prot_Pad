#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "AGDA180.ch"

/*/{Protheus.doc} AGDA180EVT
Eventos do modelo MVC da rotina de Destinação das Sobras.
@type class
@version 1.0
@author gilson.venturi
@since 27/08/2026
/*/
Class AGDA180EVT From FWModelEvent

	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
EndClass

/*/{Protheus.doc} New
Construtor da classe de eventos da rotina de Destinação das Sobras.
@type method
@version 1.0
@author gilson.venturi
@since 27/08/2026
@return object, instância da classe
/*/
Method New() Class AGDA180EVT
Return Self

/*/{Protheus.doc} ModelPosVld
Valida os dados obrigatórios antes da confirmação da atualização
da rotina de Destinação das Sobras.
@type method
@version 1.0
@author gilson.venturi
@since 27/08/2026
@param oModel, object, modelo principal
@param cModelId, character, identificador do modelo
@return logical, resultado da validação
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA180EVT
	Local lRet      := .T.
	Local oModelNFE := oModel:GetModel("NFEMASTER")

	if oModel:getOperation() != MODEL_OPERATION_DELETE
	
		// A soma dos percentuais de pagamento cooperado e integralização capital social
		If oModelNFE:GetValue("NFE_PRCPGT") + oModelNFE:GetValue("NFE_PRCINT") <> 100
			AGDHELP(STR0007, STR0008) //"Ajuda"#"A soma dos percentuais de pagamento e integralização deve ser 100%"
			lRet := .F.
		Endif

		If oModelNFE:GetValue("NFE_DTAINI") > oModelNFE:GetValue("NFE_DTAFIM")
			AGDHELP(STR0007, STR0016) //"Ajuda"#"A data de início deve ser anterior à data de fim"
			lRet := .F.
		Endif

		if oModel:getOperation() == MODEL_OPERATION_INSERT
			if ExistCpo('NFE',oModelNFE:GetValue("NFE_ORIGEM")+oModelNFE:GetValue("NFE_TIPO")+oModelNFE:GetValue("NFE_ANOREF"),2)
				AGDHELP(STR0007,STR0017)//"Ajuda","Já existe registro com esta informação"
				lRet := .F.
			endif
		endif
	Endif

Return lRet
