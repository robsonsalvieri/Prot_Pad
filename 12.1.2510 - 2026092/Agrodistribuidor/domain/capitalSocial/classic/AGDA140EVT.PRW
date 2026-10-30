#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "AGDA140.ch"

#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd
/*/{Protheus.doc} AGDA140EVT
Classe de eventos do modelo do AGDA140
@type class
@version 12
@author gilson.venturi
@since 18/06/2026
/*/
Class AGDA140EVT From FWModelEvent

	Method New() Public Constructor
	Method ModelPosVld()
	Method FieldPreVld()
	Method InTTS(oModel, cModelId)
	Method AfterTTS()
	Method validateQuotaBalanceForMovement(oNF4)
	Method VldActivate(oModel, cModelId)

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, self
/*/
Method New() Class AGDA140EVT
Return Nil

/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author lindembergson.pacheco
@since 03/07/2026
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA140EVT
	Local aArea				:= FWGetArea()
	Local lRet				:= .T.
	Local nOperation		:= oModel:GetOperation()
	Local oNF4				:= oModel:GetModel("AGDA140_NF4")
	Local oRepository		as object
	Local cCodigo			as character
	Local cLoja				as character
	Local cIdMov			as character

	If nOperation == MODEL_OPERATION_INSERT

		If oNF4:GetValue("NF4_OPTMOV") = '6' // 6=Encerramento
			If !(IsBlind() .Or. FWAlertYesNo(STR0009, "")) //"Confirma o encerramento desta Conta?"
				AGDHELP(STR0005, STR0010) //Ajuda - "Processo de encerramento da conta abortado"
				lRet := .F.
			Endif
		Endif

		if lRet
			If oNF4:GetValue("NF4_VALBRT") == 0
				oNF4:SetValue("NF4_VALBRT", oNF4:GetValue("NF4_VLRCAP"))
			EndIf

			cCodigo := oNF4:GetValue("NF4_CODCOO")
			cLoja   := oNF4:GetValue("NF4_LOJCOO")

			oRepository := NAMESPACEAGD.QuotaMovementRepository():New()
			cIdMov := oRepository:getNewCode( cCodigo, cLoja )

			oNF4:SetValue("NF4_IDMOV", cIdMov)

			lRet := ::validateQuotaBalanceForMovement(oNF4)

		EndIf
	EndIf

	FWRestArea(aArea)
Return lRet

/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field
@type method
@version  P12
@author claudineia.reinert
@since 03/07/2026
@param oSubModel, object, Modelo principal
@param cModelID, character, Id do submodelo
@param cAction, character, Ação executada, podendo ser: SETVALUE, CANSETVALUE
@param cIdCampo, character, nome do campo
@param valorCampo, variant, Novo valor do campo
@return Logical, true/false
/*/
Method FieldPreVld( oSubModel, cModelID, cAction, cIdCampo, xValue ) Class AGDA140EVT
	Local lRet := .T.

	If cModelID == "AGDA140_NF4" .and. cIdCampo $ "NF4_CODCOO|NF4_LOJCOO" .and. oSubModel:GetOperation() == 3
		oRepository := NAMESPACEAGD.QuotaMovementRepository():New()
		cIdMov := oRepository:getNewCode( oSubModel:GetValue("NF4_CODCOO"), oSubModel:GetValue("NF4_LOJCOO") )
		oSubModel:LoadValue("NF4_IDMOV", cIdMov)
	EndIf

	If cModelID == "AGDA140_NF4" .and. oSubModel:GetValue("NF4_OPTMOV") == '6' //6-Encerramento
		If  cIdCampo $ "NF4_CONDPG"
			if !ExistCpo('SE4',xValue) .and. !Empty(xValue)
				AGDHELP(STR0005, STR0012) //"Ajuda", "Informada condição de pagamento inexistente"
				return .F.
			EndIf
		EndIf


	EndIf


Return lRet

/*/{Protheus.doc} InTTS
Atualiza o saldo de cotas do cooperado (NF3) com base na movimentação (NF4)
@type method
@version 12
@author claudineia.reinert
@since 06/07/2026
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, nil
/*/
Method InTTS(oModel, cModelId) Class AGDA140EVT
	Local aArea := {}

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. oModel:GetValue("AGDA140_NF4", "NF4_STATUS") = '1' // 1=Aprovado
		aArea := FWGetArea()

		confirmMov(oModel)

		FWRestArea(aArea)
	Endif

	If oModel:HasErrorMessage()
		DisarmTransaction()
		Break
	EndIf
Return Nil

/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@type method
@version 12
@author jc.maldonado
@since 02/07/2026
@param oModel, object, modelo
@param cModelId, character, id do modelo
/*/
Method AfterTTS(oModel, cModelId) Class AGDA140EVT
	Local oView := Nil

	If oModel:HasErrorMessage();
			.And. (oView := FwViewActive()) != Nil;
			.And. ValType(oView) == "O";
			.And. oView:oModel:getId() == "AGDA140";
			.And. oView:IsActive();

		oView:showInsertMsg(.F.) //Suprime a mensagem de "Registro incluido com sucesso"

		FWAlertError(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
	Endif
Return


/*/{Protheus.doc} validateQuotaBalanceForMovement
Valida a quantidade da movimentção com relação ao saldo do cooperado conforme o tipo da movimentação.
@type method
@version  P12
@author claudineia.reinert
@since 7/6/2026
@param oNF4, object, objeto de dados da NF4
@return Logical, true/false
/*/
Method validateQuotaBalanceForMovement(oNF4) Class AGDA140EVT
	Local lRet := .T.

	If oNF4:GetValue("NF4_OPTMOV") == "1" //1=Saldo_ERP
		DBSelectArea("NF5")
		NF5->(DBSetOrder(1))
		If NF5->(DBSeek(xFilial("NF5")+oNF4:GetValue("NF4_TIPMOV"))) .AND. NF5->NF5_OPEXEC == "3" //3=subtração
			DBSelectArea("NF3")
			NF3->(DBSetOrder(1))
			If NF3->(dbSeek(xFilial("NF3")+oNF4:GetValue("NF4_CODCOO")+oNF4:GetValue("NF4_LOJCOO"))) ;
					.AND. (NF3->NF3_QTDCOT <= oNF4:GetValue("NF4_QTDCOT") .or. NF3->NF3_VALCOT <= oNF4:GetValue("NF4_VLRCAP"))
				AGDHELP(STR0005, STR0006, STR0007) //"Cooperado não possui cotas/saldo suficientes para esta movimentação."Este tipo de movimentação não permite zerar cotas/saldo do cooperado, ajuste a quantidade de cotas.")
				lRet := .F.
			EndIf
		EndIf
	elseIf oNF4:GetValue("NF4_OPTMOV") == "6" //6=Encerramento Conta Cooperado
		DBSelectArea("NF5")
		NF5->(DBSetOrder(1))
		If NF5->(DBSeek(xFilial("NF5")+oNF4:GetValue("NF4_TIPMOV"))) .AND. NF5->NF5_OPEXEC == "3" //3=subtração
			DBSelectArea("NF3")
			NF3->(DBSetOrder(1))
			If  NF3->(dbSeek(xFilial("NF3")+oNF4:GetValue("NF4_CODCOO")+oNF4:GetValue("NF4_LOJCOO"))) .AND.;
				NF3->NF3_VALCOT < oNF4:GetValue("NF4_VLRCAP")
				AGDHELP(STR0005, STR0019) //"Informado valor do capital superior ao disponível para o cooperado
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VldActivate
Validação antes de ativar o formulário
@type method
@version 12
@author gilson.venturi
@since 07/07/2026
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method VldActivate(oModel, cModelId) Class AGDA140EVT
	Local aArea			:= FWGetArea()
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oNF4			:= oModel:GetModel("AGDA140_NF4")
	Local aSaldos		:= {}
	Local aSaldosJuros  := {}

	Local oQuotaRepository As Object

	If lRet .And. oModel:lactivate .And. nOperation == MODEL_OPERATION_INSERT
		if oNF4:GetValue("NF4_OPTMOV") = '6' .and. NF3->NF3_STATUS == '2'  //6=Encerramento, 2=Inativa

			//Permitir Acesso ao Encerramento de Conta para Cooperados Contemplados pelo Gera Demitidos
			//Se possuir saldo de Capital Social e saldo estiver identificado como originado pela regra Gera Demitidos
			oQuotaRepository := NAMESPACEAGD.QuotaRepository():New()
			aSaldos      := oQuotaRepository:cooperatorBalance(FWXFilial("NF3"), NF3->NF3_CODCOO, NF3->NF3_LOJCOO)
			aSaldosJuros := oQuotaRepository:balanceForTerminatedCooperators(NF3->NF3_CODCOO, NF3->NF3_LOJCOO)

			IF  aSaldos[2] = 0 .or. aSaldosJuros = 0
				lRet := .F.
				AGDHELP(STR0005, STR0008 ) //Ajuda - "Encerramento não permitido. Cooperado já possui Conta inativa"
			EndIf
		EndIf
	EndIf

	If lRet .And. oModel:lactivate .And. nOperation == MODEL_OPERATION_INSERT
		if oNF4:GetValue("NF4_OPTMOV") = '3' .and. NF3->NF3_STATUS != '2'  //3=Integralização, Ativo ou pendente pagamento (Reativar Conta)
			lRet := .F.
			AGDHELP(STR0005, STR0015, STR0016) //Ajuda - "Opção Reativar Conta não disponível para o Cooperado.""Verifique se o Cooperado, está inativo, possui saldo zerado e já ficou ativo anteriormente."
		EndIf
	EndIf

	If lRet .And. oModel:lactivate .And. nOperation == MODEL_OPERATION_INSERT
		if oNF4:GetValue("NF4_OPTMOV") = '1' .and. NF3->NF3_STATUS != '1'  //1=Saldo ERP, diferente de ativo (Movimento Avulso)
			lRet := .F.
			AGDHELP(STR0005, STR0017, STR0018 ) //Ajuda - "Opção Movimento Avulso não disponível para o Cooperado.""Verifique se o Cooperado, está ativo e com saldo." 
		EndIf
	EndIf

	FreeObj(oQuotaRepository)
	FWRestArea(aArea)
Return lRet

/*/{Protheus.doc} confirmMov
Confirma o Movimento
@type function
@version 12
@author jc.maldonado
@since 18/08/2026
@param oModel, object, Modelo
/*/
Static Function confirmMov(oModel)
	Local oQuotaMovS := NAMESPACEAGD.QuotaMovementService():New()
	Local oNF4       := oModel:GetModel("AGDA140_NF4")

	oQuotaMovS:confirmarMovimento(  ;
		oNF4:GetValue("NF4_CODCOO"),;
		oNF4:GetValue("NF4_LOJCOO"),;
		oNF4:GetValue("NF4_IDMOV" ),;
		oNF4:GetValue("NF4_VLRCAP"),;
		oNF4:GetValue("NF4_VALIMP"),;
		oNF4:GetValue("NF4_TIPMOV") ;
		)

	If ! oQuotaMovS:isSuccess()
		oModel:SetErrorMessage(,,,,, oQuotaMovS:getMessageError() + CRLF + oQuotaMovS:getDetailedMessage(), oQuotaMovS:getSolutionError())
	EndIF

	FWFreeObj(oQuotaMovS)
Return
