#INCLUDE "AGDA130.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE QUOTA_MOVIMENT_SERVICE totvs.protheus.agrobusiness.agd.QuotaMovementService
#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd
/*/{Protheus.doc} AGDA130EVT
Classe de eventos do modelo do AGDA130
@type class
@version 12
@author gilson.venturi
@since 18/06/2026
/*/
Class AGDA130EVT From FWModelEvent

	Method New() Public Constructor
	Method ModelPosVld()
	Method InTTS()
	Method AfterTTS()
End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, self
/*/
Method New() Class AGDA130EVT
Return Nil

/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author gilson.venturi
@since 18/06/2026
@param oModel, object, modelo
@param cModelId, character, modelo id
@return logical, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA130EVT
	Local aArea	     := FWGetArea()
	Local nOperation := oModel:GetOperation()
	Local oNF3       := oModel:GetModel("AGDA130_NF3")

	If nOperation == MODEL_OPERATION_INSERT
		If ExistCpo("NF3", oNF3:GetValue("NF3_CODCOO") + oNF3:GetValue("NF3_LOJCOO") + '1', 1)
			AGDHELP(STR0006, STR0008) //Ajuda - "Inclusão não permitida. Cooperado já possui Conta ativa"
			Return .F.
		Endif

		If oNF3:GetValue("NF3_QTDCOT") <= 0 .Or. oNF3:GetValue("NF3_VALCOT") <= 0
			AGDHELP(STR0006, STR0018, STR0019) //"Ajuda", "Inclusão não permitida.", "A quantidade e o valor das cotas devem ser maiores que zero."
			Return .F.
		EndIf
	EndIf

	FWRestArea(aArea)
Return .T.

/*/{Protheus.doc} AGDA130EVT::afterTTS
Método que é chamado pelo MVC após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@type method
@version 12
@author lindembergson.pacheco
@since 17/06/2026
@param oModel, object, Objeto do modelo principal
@param cModelId, character, Id do modelo
/*/
method afterTTS(oModel, cModelId) class AGDA130EVT
	Local oView := Nil

	If oModel:HasErrorMessage();
			.And. (oView := FwViewActive()) != Nil;
			.And. ValType(oView) == "O";
			.And. oView:oModel:getId() == "AGDA130";
			.And. oView:IsActive();

		oView:showInsertMsg(.F.) //Suprime a mensagem de "Registro incluido com sucesso"

		FWAlertError(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
	Endif
Return

/*/{Protheus.doc} AGDA130EVT::InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@type method
@version 12
@author jc.maldonado
@since 17/08/2026
@param oModel, object, Modelo
@param cModelId, character, Id do modelo
/*/
Method InTTS(oModel, cModelId) Class AGDA130EVT
	Local aArea := {}

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		aArea := FWGetArea()

		geraMovime(oModel)

		FWRestArea(aArea)
	EndIf

	If oModel:HasErrorMessage()
		DisarmTransaction()
		Break
	EndIf
Return

/*/{Protheus.doc} geraMovime
Gera movimento inicial se for do tipo 2=Subscrição ou 3=Integralização
@type function
@version 12
@author jc.maldonado
@since 17/08/2026
@param oModel, object, modelo
/*/
static function geraMovime(oModel)
	Local aAreaNF5 := {}

	dbSelectArea("NF5")
	aAreaNF5 := NF5->(FWGetArea())
	NF5->(dbSetOrder(1)) //NF5_FILIAL+NF5_CODIGO

	If NF5->(dbSeek(xFilial("NF5")+NF3->NF3_TPOPER));
			.And. NF5->NF5_TIPO $ "2|3" //2=Subscrição; 3=Integralização

		If IsBlind()
			runMovInic(oModel)
		Else
			FWMsgRun(nil, {|| runMovInic(oModel)}, STR0010, STR0011) //"Aguarde", "Gerando movimento inicial de cooperado..."
		EndIf
	EndIf

	FWRestArea(aAreaNF5)
return

/*/{Protheus.doc} runMovInic
Inclui o movimento inicial e define erro no modelo caso ocorra.
@type function
@version 12
@author lindembergson.pacheco
@since 22/06/2026
@param oModel, object, Modelo
/*/
Static Function runMovInic(oModel)
	Local oQuotaMovS := NAMESPACEAGD.QuotaMovementService():New()
	Local oNF3       := oModel:GetModel("AGDA130_NF3")

	oQuotaMovS := NAMESPACEAGD.QuotaMovementService():New()
	oQuotaMovS:gravarMovimento(     ;
		FWxFilial("NF4")           ,;
		oNF3:GetValue("NF3_CODCOO"),;
		oNF3:GetValue("NF3_LOJCOO"),;
		oNF3:GetValue("NF3_VALCOT"),;
		oNF3:GetValue("NF3_TPOPER"),;
		oNF3:GetValue("NF3_OBS")    ;
		)

	If ! oQuotaMovS:isSuccess()
		oModel:SetErrorMessage(,,,,, oQuotaMovS:getMessageError() + CRLF + oQuotaMovS:getDetailedMessage(), oQuotaMovS:getSolutionError())
	EndIf

	FwFreeObj(oQuotaMovS)
Return
