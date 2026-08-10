#INCLUDE "AGDA020.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE IE_PEDIDO_SERVICE agd.instrucaoEmbarquePedidoService.agdInstrucaoEmbarquePedidoService
#DEFINE INSTRUCAO_EMBARQUE_ITEM_REPOSITORY agd.instrucaoEmbarqueItemRepository.agdInstrucaoEmbarqueItemRepository
#DEFINE NEGOCIO_STATUS_SERVICE agd.negocioStatusService.agdNegocioStatusService
#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService

/*/{Protheus.doc} AGDA020EVT
Classe de eventos do modelo do AGDA010
@type class
@version 12
@author jean.schulze
@since 02/09/2025
/*/
Class AGDA020EVT From FWModelEvent

	Method New() Public Constructor
	Method VldActivate(oModel, cModelId) 
	Method ModelPosVld(oModel, cModelId)
	Method InTTS(oModel, cModelId)	
	Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
	Method GridLinePosVld() 
	
	Method validaCampoInsumos()
	Method validaLinhaInsumos()
	Method validaQuantidade()
End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@return variant, self
/*/
Method New() Class AGDA020EVT
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
Method ModelPosVld(oModel, cModelId) Class AGDA020EVT
	Local lRet    		   	:= .T.
	Local nOperation       	:= oModel:GetOperation()
	Local oNEC			   	:= oModel:GetModel("AGDA020_NEC")
	Local oNED			   	:= oModel:GetModel("AGDA020_NED")
	Local oIEPedidoService 	:= nil
	Local cIdChaveNegocio  	:= ""
	Local oNegocioService 	:= nil

	If nOperation == MODEL_OPERATION_UPDATE
		If lRet .and. oNED:IsModified()
			oNegocioService := NEGOCIO_SERVICE():New()
			cIdChaveNegocio := oNegocioService:buscarIdUnicoNegocio(oNEC:GetValue("NEC_CODBRT")) //retorna indice unico filial+codigo+versao

			If POSICIONE("NEA", 1, cIdChaveNegocio, "NEA_STSAUT" ) == "1" //1=Nao Liberada
				lRet := Self:validaQuantidade(oModel)
			Endif
		EndIf

	elseIf nOperation == MODEL_OPERATION_DELETE

		oIEPedidoService := IE_PEDIDO_SERVICE():new(oNEC:GetValue("NEC_CODIGO"))

		if oIEPedidoService:hasPedido()
			If Upper(FunName()) == "AGDA020" .And. !(lRet := FWAlertYesNo(STR0040, ""))//"Esta Instrução de Embarque possui um Pedido de Venda vinculado. Ao confirmar a exclusão, o Pedido de Venda vinculado também será excluído. Deseja continuar?"
				Help( , , STR0009, , STR0041, 1, 0, .F., , ,,,{}) //"Processo de exclusão da Instrução de Embarque cancelado."
				lRet := .F.
			Else
				oIEPedidoService:removerPedido()
				if !oIEPedidoService:isSuccess()
					Help( , , STR0009, ,STR0043, 1, 0, .F., , ,,,{oIEPedidoService:getMessageError()})//"Não foi possível realizar a exclusão da Instrução de Embarque. O status do pedido não permite exclusão automática."
					lRet := .F.
				endif
			EndIF
		endif

	Endif

	If lRet .and. nOperation != MODEL_OPERATION_DELETE
		//Momentaneamente incluso essa validação. Futuramente com liberação da reforma tributária
		//esta tabela será subtituida pela SD9.Sendo revisada essa validação assim como campo o dicionario
		DbSelectArea('SX5')
		DbSetOrder(1)
		If !SX5->(MsSeek(xFilial("SX5")+"01"+oNEC:GetValue("NEC_SERNF")))
			Help( , , STR0009, , STR0042, 1, 0, .F., , ,,,{})
			lRet := .F.
		EndIf
	Endif

	FreeObj(oIEPedidoService)
Return lRet

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
Method InTTS(oModel, cModelId)  Class AGDA020EVT
	Local aArea 	 	   := GetArea()
	Local nOperation       := oModel:GetOperation()
	Local oNEC			   := oModel:GetModel("AGDA020_NEC")
	Local oIEPedidoService := nil
	Local oNegStatus	   := nil
	Local cFilNEA          := FWxFilial("NEA")
	Local oNegocioService  := nil
	Local cVersaoNegocio   := ""


	If nOperation == MODEL_OPERATION_INSERT
		AGDGRAVAHIS("","NEC",xFilial("NEC")+oNEC:Getvalue('NEC_CODIGO'),"INCLUIR",.F.) //INCLUIR
	elseIf nOperation == MODEL_OPERATION_UPDATE
		AGDGRAVAHIS("","NEC",xFilial("NEC")+oNEC:Getvalue('NEC_CODIGO'),"ALTERAR",.F.) //ALTERAR
	elseIf nOperation == MODEL_OPERATION_DELETE
		AGDGRAVAHIS("","NEC",xFilial("NEC")+oNEC:Getvalue('NEC_CODBRT'),"EXCLUIDO INSTRUCAO EMBARQUE ",.F., oNEC:Getvalue('NEC_CODIGO')) //EXCLUIR
	Endif

	oNegocioService := NEGOCIO_SERVICE():New()
	cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(oNEC:Getvalue('NEC_CODBRT'))

	Sleep(1000)// Garantir que gere uma diferenca de 1 segundo na geracao do LOG
	oNegStatus := NEGOCIO_STATUS_SERVICE():New(cFilNEA + oNEC:GetValue("NEC_CODBRT")+cVersaoNegocio)
	oNegStatus:informarInstrucaoEmbarque()
	FreeObj(oNegStatus)

	RestArea(aArea)
	FreeObj(oIEPedidoService)

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
Method VldActivate(oModel, cModelId) Class AGDA020EVT
	Local aArea            := {}
	Local oIEPedidoService := Nil
	Local lValid           := .F.

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		aArea := NEC->(FWgetArea())

		oIEPedidoService := IE_PEDIDO_SERVICE():new(NEC->NEC_CODIGO)
		lValid := ! oIEPedidoService:hasPedido()
		FWFreeObj(oIEPedidoService)

		NEC->(FWrestArea(aArea))

		If ! lValid
			AGDHELP(STR0009, STR0026, STR0049) //#"AJUDA", "Instrucao de Embarque com Pedido de Venda Gerado.", "Excluir o Pedido de venda."
			Return .F.
		Endif
	Endif
Return .T.

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
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class AGDA020EVT
	if cModelID == 'AGDA020_NED'
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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class AGDA020EVT
	if cModelID == 'AGDA020_NED'
		return Self:validaLinhaInsumos(oSubModel)
	endif
return .t.

/*/{Protheus.doc} validaCampoInsumos
Valida campos especificos da linha de insumos
@type method
@version 12
@author jean.schulze
@since 03/09/2025
@param oNED, object, modelo
@param nLine, numeric, linha
@param cAction, character, acao
@param cIDField, character, id campo
@param xValue, variant, valor
@param xCurrentValue, variant, valor anterior
@return variant, retorno
/*/
Method validaCampoInsumos(oNED, nLine, cAction, cIDField, xValue, xCurrentValue) Class AGDA020EVT
	Local lRet 		:= .T.
	Local nSaldo 		:= 0
	Local oView		:= FwViewActive()

	If cAction == "DELETE" //no delete da linha
		oNED:SetValue("NED_QTDIEB", 0) //Zera a quantidade de insumo
		oNED:LoadValue("NED_QTDSLD", 0) //Zera o saldo de insumo
		If valType(oView) == 'O' .AND. oView:GetModel():GetId() == "AGDA020" // Atualiza a View
			oView:Refresh("AGDA020_NED")
		EndIf
	ElseIf cAction == "UNDELETE" //no delete da linha
		nSaldo := AGDA020SNED(oNED:GetModel())
		oNED:GoLine( nLine )
		oNED:SetValue("NED_QTDIEB", 0)
		oNED:LoadValue("NED_QTDSLD", nSaldo) //atualiza o saldo de insumo
		If valType(oView) == 'O' .AND. oView:GetModel():GetId() == "AGDA020" // Atualiza a View
			oView:Refresh("AGDA020_NED")
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} validaLinhaInsumos
Valida a linha de insumos
@type method
@version 12
@author jean.schulze
@since 03/09/2025
@param oNED, object, modelo
@return variant, retorno
/*/
method validaLinhaInsumos(oNED) Class AGDA020EVT
	Local lRet		 := .T.
	Local nX    	 := 0
	Local nLinha	 := 0
	Local nSaldoInst := 0

	nLinha := oNED:GetLine()
	For nX := 1 to oNED:Length()
		oNED:GoLine( nX )

		IF  !oNED:IsDeleted()
			nSaldoInst += oNED:GetValue("NED_QTDIEB")
			If oNED:GetValue("NED_QTDIEB") <= 0 .OR. oNED:GetValue("NED_VALOR") <= 0
				lRet := .F.
			endif
		endif
	Next nX
	oNED:GoLine( nLinha )

	if !oNED:IsDeleted() .AND. nSaldoInst == 0
		AGDHELP(STR0009,STR0027, STR0028) //"Ajuda" //"Quantidade a Instruir está Zerada!" //"Informe uma Quantidade a Instruir maior que Zero."
		Return .F.
	endif

	if !lRet
		If MsgYesNo(STR0024, "") //Existem itens que a quantidade a instruir está zerada e serão deletados para a geração da Instrução de Embarque, Deseja seguir?
			lRet := .T.
			nLinha := oNED:GetLine()
			For nX := 1 to oNED:Length()
				oNED:GoLine( nX )
				//removendo itens com valor zero na quantidade da grid
				If oNED:GetValue("NED_QTDIEB") <= 0 .OR. oNED:GetValue("NED_VALOR") <= 0
					IF  !oNED:IsDeleted()
						oNED:DeleteLine()
					endif
				endif
			Next nX
			oNED:GoLine( nLinha )
		Else
			lRet := .F.
			AGDHELP(STR0009, STR0010, STR0011 ) //##"AJUDA","Há itens com o campo quantidade ou valor não informado.", "Obrigatório informar quantidade e valor para cada item da instrução de embarque.")
		EndIf
	endif

Return lRet 

/*/{Protheus.doc} validaQuantidade
Valida se a quantidade a instruir (NED_QTDIEB) não é superior a quantidade original.
Utilizado quando há uma alteração na Instrução de Embarque e a autorização do negócio
for 'Não Liberado' (Campo NEA_STSAUT = "1")
@type function
@version 12
@author jc.maldonado
@since 17/02/2025
@param oModel, object, MpFormModel "AGDA020"
@return logical, .T. or .F.
/*/
Method validaQuantidade(oModel) Class AGDA020EVT
	Local oGridNED   := oModel:GetModel("AGDA020_NED")
	Local aLinesChgd := oGridNED:GetLinesChanged(MODEL_GRID_LINECHANGED_UPDATED)
	Local nX
	Local nPos
	Local aCodQntd   := {} // { {cNED_ITEBRT, nQtdTotalInstruir}, ... }
	Local cCodNeg    := oModel:GetValue("AGDA020_NEC", "NEC_CODBRT")
	Local nTotalInst
	Local lRet       := .T.
	Local nLineBkp   := oGridNED:GetLine()
	Local oIEitemRep as object

	For nX := 1 To Len(aLinesChgd)
		oGridNED:GoLine(aLinesChgd[nX])

		If ! oGridNED:IsDeleted()
			If (nPos := aScan(aCodQntd, {|xIt| xIt[1] == oGridNED:GetValue("NED_ITEBRT")})) == 0
				aAdd(aCodQntd, {oGridNED:GetValue("NED_ITEBRT"), oGridNED:GetValue("NED_QTDIEB")})
			Else
				aCodQntd[nPos, 2] += oGridNED:GetValue("NED_QTDIEB")
			EndIf
		EndIf
	Next nX

	oGridNED:GoLine(nLineBkp)

	oIEitemRep := INSTRUCAO_EMBARQUE_ITEM_REPOSITORY():New()

	For nX := 1 to Len(aCodQntd)
		nTotalInst := oIEitemRep:sumByNegocioInsumo(cCodNeg, aCodQntd[nX, 1])

		If aCodQntd[nX, 2] > nTotalInst
			lRet := .F.
			AGDHELP(STR0009, STR0022, STR0023) //"AJUDA","Negociação em processo de liberação, a quantidade não pode ser superior a atual.", "Informe uma quantidade inferior a atual."
			Exit
		EndIf
	Next nX

	FwFreeArray(aCodQntd)
	FreeObj(oIEitemRep)
return lRet 
