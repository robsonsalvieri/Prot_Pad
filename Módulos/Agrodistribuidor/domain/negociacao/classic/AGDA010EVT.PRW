#INCLUDE "AGDA010.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService
#DEFINE NEGOCIO_INSUMO_SERVICE agd.negocioInsumoService.agdNegocioInsumoService
#DEFINE HISTORICO_SERVICE agd.historicoService.agdHistoricoService
#DEFINE RATEIO_REPOSITORY agd.rateioNegociacaoRepository.agdRateioNegociacaoRepository

/*/{Protheus.doc} AGDA010EVT
Classe de eventos do modelo do AGDA010
@type class
@version 12
@author jean.schulze
@since 02/09/2025
/*/
Class AGDA010EVT From FWModelEvent
	public Data cHistorico As string 

	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
	Method GridLinePosVld() 
	Method GridLinePreVld()
	Method InTTS(oModel, cModelId)
	Method VldActivate(oModel, cModelId) 
	Method DeActivate(oModel)
	Method Activate(oModel, lCopy) Public

	Method openSaldoProduto()
	Method validaCampoInsumos()
	Method validaLinhaContrato()

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@return variant, self
/*/
Method New() Class AGDA010EVT
Return Nil

/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA010EVT
	Local aArea      := FWGetArea()

	Self:cHistorico := ""

	if oModel:getOperation() == MODEL_OPERATION_DELETE;
			.And. ! IsBlind();
			.And. ! FWisInCallStack('TLPP.REST.HANDLEREST');
			.And. Empty(Self:cHistorico := AGDXHISTGM())
	
		oModel:SetErrorMessage(,,,,, STR0072) //"Processo cancelado pelo usuário."
		return .F.
	endif

	FWRestArea(aArea)
Return .t.

/*/{Protheus.doc} InTTS
Pós Commit
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, nil
/*/
Method InTTS(oModel, cModelId)  Class AGDA010EVT
	Local aArea      := FWGetArea()
	Local nLinha     := 0
	Local oGridNEB   := nil
	Local oHeaderNEA := nil
	Local oRateio    := nil
	Local oHistorico := nil

	oGridNEB   := oModel:GetModel("AGDA010_NEB")
	oHeaderNEA := oModel:GetModel("AGDA010_NEA")
	oRateio    := RATEIO_REPOSITORY():New()
	oHistorico := HISTORICO_SERVICE():New()

	For nLinha := 1 To oGridNEB:Length()
		If oGridNEB:IsDeleted(nLinha)
			oGridNEB:GoLine(nLinha)
			oRateio:deleteRateiosByInsumo(;
				oHeaderNEA:GetValue("NEA_CODIGO"), ;
				oGridNEB:GetValue("NEB_ITEM", nLinha) ;
				)
		EndIf
	Next

	oHistorico:registrar("NEA", FWxFilial("NEA") + oHeaderNEA:GetValue("NEA_CODIGO") + oHeaderNEA:GetValue("NEA_VERSAO"), oModel:getOperation(), RetCodUsr(), Self:cHistorico)
	
	FreeObj(oRateio)
	FWFreeObj(oHistorico)
	FWRestArea(aArea)
return nil

/*/{Protheus.doc} VldActivate
Validação de Ativação do Módulo
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method VldActivate(oModel, cModelId) Class AGDA010EVT
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local oNegocioService := NEGOCIO_SERVICE():New()

	IF oModel:GetOperation() == MODEL_OPERATION_UPDATE
		DO CASE
		CASE NEA->NEA_STATUS == "6" // VERSIONADO
			AGDHELP(STR0008, STR0039) // #""AJUDA". Negociação versionada não pode ser alterada."
			Return .F.

		CASE NEA->NEA_STATUS == "3" // CANCELADO
			AGDHELP(STR0008, STR0071) // #""AJUDA". Negociação cancelada não pode ser alterada."
			Return .F.

		CASE NEA->NEA_STSAUT == "2" // AUTORIZACAO - LIBERADO
			AGDHELP(STR0008, STR0034, STR0035) // #"AJUDA", "Negócio liberado não pode se alterado", "Para alteração do mesmo, deve-se realizar o versionamento do negócio."
			Return .F.
		ENDCASE
	EndIF

	//#####################################################
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		oNegocioService := NEGOCIO_SERVICE():New()
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			oNegocioService := NEGOCIO_SERVICE():New()
			If NEA->NEA_STATUS $ "6"
				AGDHELP(STR0008, STR0040 +UPPER(AllTrim(X3CboxDesc( "NEA_STATUS", NEA->NEA_STATUS )))+ STR0041) //##"Operação não permitida. Negociação com status " ##" não pode ser excluída."
				Return .F.
			ElseIf oNegocioService:validarSeTemVersionamento(NEA->NEA_CODIGO) //negociação atual tem versionamentos
				AGDHELP(STR0008, STR0042) //##"Operação não permitida. Negociação possui versionamento, portanto não pode ser excluída."
				Return .F.
			Endif
		Endif
	Endif

	RestArea(aArea)
return lRet


/*/{Protheus.doc} GridLinePreVld
Validação de Campos da Grids
@type method
@version 12
@author jean.schulze
@since 03/09/2025
@param oSubModel, object, modelo
@param cModelID, character, modelo id
@param nLine, numeric, linha
@param cAction, character, acao
@param cId, character, identificacao campo
@param xValue, variant, valor
@param xCurrentValue, variant, valor anterior
@return variant, retorno
/*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class AGDA010EVT
	if cModelID == 'AGDA010_NEB'
		return Self:validaCampoInsumos(oSubModel, nLine, cAction, cId, xValue, xCurrentValue)
	endif
return .t.

/*/{Protheus.doc} GridLinePosVld
Validação de linhas da Grid
@type method
@version 12
@author jean.schulze
@since 03/09/2025
@param oSubModel, object, modelo
@param cModelID, character, modelo id
@param nLine, numeric, linha
@return variant, retorno
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class AGDA010EVT
	if cModelID == 'AGDA010_NEE'
		return Self:validaLinhaContrato(oSubModel)
	endif
return .t.

/*/{Protheus.doc} DeActivate
Desativação do Modelo de Dados
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, Modelo de Dados
@return variant, nil
/*/
Method DeActivate(oModel) Class AGDA010EVT
	SetKey(VK_F4, nil)
return nil

/*/{Protheus.doc} Activate
Ativação do Modelo de Dados
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo de dados
@param lCopy, logical, copia de dados
@return variant, nil
/*/
Method Activate(oModel, lCopy) Class AGDA010EVT
	Local aArea		:= GetArea()

	SetKey(VK_F4,  {|| Self:openSaldoProduto()})  //Setanto F4 para mostrar consulta saldo dos produtos

	RestArea(aArea)
return nil

/*/{Protheus.doc} openSaldoProduto
Abertura de tela de saldos
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@return variant, nil
/*/
Method openSaldoProduto()  Class AGDA010EVT
	Local aArea  := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldNEB 	:= oModel:GetModel('AGDA010_NEB')
	Local cCodPro   := oMldNEB:GetValue("NEB_CODPRO")

	If !Empty(cCodPro)
		MaViewSB2(cCodPro)
	EndIf

	RestArea(aArea)
return nil

/*/{Protheus.doc} validaCampoInsumos
Pré Validação da linha da grid NEB
@type method
@version P12.1.2410
@author claudineia.reinert
@since 26/11/2024
@param oNEB, object, objeto do modelo da tabela NEB
@param nLine, numeric, numero da linha 
@param cAction, character, ação executada UNDELETE/DELETE/SETVALUE/CANSETVALUE
@param cIDField, character, id do campo
@param xValue, variant, Valor do campo antes de ajustar
@param xCurrentValue, variant, Valor atual a ser ajustado no campo
@return Logical, Valor .T. ou .F.
/*/
Method validaCampoInsumos(oNEB, nLine, cAction, cIDField, xValue, xCurrentValue) Class AGDA010EVT
	Local lRet 		:= .T.
	Local oView		:= FwViewActive()
	Local oModel	:= oNEB:GetModel()
	Local oNEA		:= oModel:GetModel("AGDA010_NEA")
	Local cAliPrcTab := GetNextAlias()
	Local oNegocioInsumoServive := nil
	Local nQtdAlocada := 0

	If cAction == "UNDELETE" // Se a Ação for Undelete
		lRet := AGDA010VPTB() //valida se produto esta na tabela
		If lRet
			AGDA010QYTP(@cAliPrcTab)
			oNEB:LoadValue("NEB_PRCTAB", (cAliPrcTab)->(DA1_PRCVEN)) //força atualização campo para usuario informar novamente
			oNEB:LoadValue("NEB_PRCUNI", (cAliPrcTab)->(DA1_PRCVEN)) //força atualização campo para usuario informar novamente
			oNEB:LoadValue("NEB_QTDVEN", 0) //força atualização campo para usuario informar novamente
			oNEB:LoadValue("NEB_VALOR" , 0) //força atualização campo
			oNEB:LoadValue("NEB_PARID" , 0) //força atualização campo
			(cAliPrcTab)->(dbCloseArea())
			AGDA010UNEB()
			If ValType(oView) != "U" // Atualiza a View
				oView:Refresh("AGDA010_NEB")
			EndIf
		EndIf
	ElseIf cAction == "DELETE"
		oNegocioInsumoServive := NEGOCIO_INSUMO_SERVICE():New(oNEA:GetValue("NEA_CODIGO"), oNEB:GetValue("NEB_VERSAO"), oNEB:GetValue("NEB_ITEM"))
		nQtdAlocada := oNegocioInsumoServive:getQtdAlocada()
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .and. nQtdAlocada > 0
			lRet := .F.
			AGDHELP(STR0008,STR0043) //##"Este item não pode ser removido pois tem vínculo com movimentações."
		Else
			oNEB:LoadValue("NEB_PARID" , 0) //força atualização campo para uso do calculo total da paridade no campo qtd negocio do cabeçalho
			lRet := AGDA010UPQT(nLine)
		EndIf
	ElseIf cAction == "CANSETVALUE" // valida se pode alterar o campo
		If cIDField $ "NEB_ITEM|NEB_CLIENT|NEB_LOJENT|NEB_CODPRO|NEB_PRCUNI|NEB_PDESAC|NEB_VDESAC" .AND. oModel:GetOperation() == MODEL_OPERATION_UPDATE
			oNegocioInsumoServive := NEGOCIO_INSUMO_SERVICE():New(oNEA:GetValue("NEA_CODIGO"), oNEB:GetValue("NEB_VERSAO"), oNEB:GetValue("NEB_ITEM"))
			nQtdAlocada := oNegocioInsumoServive:getQtdAlocada()
			If nQtdAlocada > 0
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} validaLinhaContrato
Função de pós-validação do modelo de dados, antes da gravação
@type method
@version P12.1.2410 
@author Gilson.Venturi
@since 07/01/2025
@param oModel, object, Objeto de modelo de dados
@return Logical, valor logical .T. ou .F. para validar se permite a gravação dos dados
/*/
Method validaLinhaContrato( oNEE ) Class AGDA010EVT
	Local lRet		:= .T.
	Local nX    	:= 0
	Local nLinha	:= 0

	nLinha := oNEE:GetLine()
	For nX := 1 to oNEE:Length()
		oNEE:GoLine( nX )

		If !oNEE:IsEmpty() .and. !oNEE:IsDeleted() //se não estiver deletado
			NJ0->(DbSetOrder(1))
			If !NJ0->(DbSeek(xFilial("NJ0") + oNEE:GetValue("NEE_CDPROP") + oNEE:GetValue("NEE_LJPROP")))
				AGDHELP(STR0008, STR0023 + " " + oNEE:GetValue("NEE_CDPROP"), STR0024 )
				lRet := .F.
				Exit
			Endif

			If !Empty(oNEE:GetValue("NEE_TABELA"))
				NNI->(DbSetOrder(1))
				If !NNI->(DbSeek(xFilial("NNI") + oNEE:GetValue("NEE_TABELA")))
					AGDHELP(STR0008, STR0025 + " " + oNEE:GetValue("NEE_TABELA"), STR0026 )
					lRet := .F.
					Exit
				Endif
			EndIf

			If !Empty(oNEE:GetValue("NEE_FIMENT")) .And.;
					(oNEE:GetValue("NEE_FIMENT") < oNEE:GetValue("NEE_INIENT") .Or.;
					oNEE:GetValue("NEE_FIMENT") < dDataBase)
				AGDHELP(STR0008, STR0050, STR0051)  //"#Data da entrega final do contrato inferior a data inicial ou data corrente", "#Informe data final válida"
				lRet := .F.
				Exit
			Endif
		Endif

	Next nX
	oNEE:GoLine( nLinha )

Return lRet
