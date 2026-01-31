#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFsmOrd
Métodos Rest do FSM para Ordem de Serviço
@author flavio.martins
@since 01/08/2025
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMORD DESCRIPTION "WS de Integração Field Services Manager - Ordem de Serviço" 

	WSDATA codigo AS STRING

	WSMETHOD GET ordemServico			DESCRIPTION 'Ordem de Servico Field Service Manager' 		  	PATH "ordemServico/{codigo}"	PRODUCES APPLICATION_JSON 
	WSMETHOD POST ordemServico     		DESCRIPTION 'Inclusão Ordem de Servico Field Service Manager'   PATH "ordemServico"       		PRODUCES APPLICATION_JSON
	WSMETHOD PUT ordemServico      		DESCRIPTION 'Alteração Ordem de Servico Field Service Manager'	PATH "ordemServico/{codigo}" 	PRODUCES APPLICATION_JSON
	WSMETHOD POST generateSalesOrder 	DESCRIPTION 'Inclusão do pedido de venda' 						PATH "generateSalesOrder" 		PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST generateSalesOrder WSREST FSMORD
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgRet	   := ''
Local cCodigo      := ''
Local cCodRet      := ''

oRequest:fromJson(cBody)

cCodigo := oRequest['ordemServico']

lRet := FsmGerPed(cCodigo, @cMsgRet, @cCodRet)

If lRet
	oResponse['message'] := EncodeUtf8(cMsgRet)
	oResponse['data'] := {}
			
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['codigo'] := cCodRet

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	SetRestFault(400, EncodeUtf8(cMsgRet))
Endif

oResponse := Nil
oRequest :=  Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD GET ordemServico WSREST FSMORD
Local lRet      	:= .T.
Local oResponse		:= JsonObject():New()
Local oModel        := Nil
Local nServico      := 0
Local nProduto      := 0
Local nAtendente    := 0

JN3->(dbSetOrder(1))

If !(JN3->(dbSeek(xFilial('JN3')+Self:codigo)))

	SetRestFault(404, EncodeUtf8("Código da ordem de serviço não encontrado"))
	Return .F.

Endif

oModel := FwLoadModel('FSMA008')
oModel:SetOperation(MODEL_OPERATION_VIEW)
oModel:Activate()

oResponse['codigoOrdem'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_CODIGO'))
oResponse['ordemOrigem'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_CODORI'))
oResponse['descricaoOrdem'] 		:= RTrim(oModel:GetValue('JN3MASTER','JN3_DESCRI'))
oResponse['codigoCliente'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_CLIENT'))
oResponse['lojaCliente'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_LOJA'))
oResponse['razaoSocial'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_NOME'))
oResponse['nomeFantasia'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_FANTAS'))
oResponse['prioridade'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_PRIORI'))
oResponse['nomeSolicitante'] 		:= RTrim(oModel:GetValue('JN3MASTER','JN3_NOMSOL'))
oResponse['nomeContato'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_NOMCNT'))
oResponse['telefoneContato'] 		:= RTrim(oModel:GetValue('JN3MASTER','JN3_TELCNT'))
oResponse['atendimentoInterno'] 	:= RTrim(oModel:GetValue('JN3MASTER','JN3_ATEINT'))
oResponse['codigoBase'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_CODPRO'))
oResponse['numeroSerie'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_NUMSER'))
oResponse['status'] 				:= RTrim(oModel:GetValue('JN3MASTER','JN3_SITUAC'))
oResponse['dataInclusao'] 			:= DtoS(oModel:GetValue('JN3MASTER','JN3_DTINCL'))
oResponse['cepAtendimento'] 		:= RTrim(oModel:GetValue('JN3MASTER','JN3_CEP'))
oResponse['enderecoAtendimento'] 	:= RTrim(oModel:GetValue('JN3MASTER','JN3_END'))
oResponse['complementoAtendimento'] := RTrim(oModel:GetValue('JN3MASTER','JN3_COMPL'))
oResponse['bairroAtendimento'] 		:= RTrim(oModel:GetValue('JN3MASTER','JN3_BAIRRO'))
oResponse['estadoAtendimento'] 		:= RTrim(oModel:GetValue('JN3MASTER','JN3_ESTADO'))
oResponse['cidadeAtendimento'] 		:= RTrim(oModel:GetValue('JN3MASTER','JN3_CIDADE'))
oResponse['nomeCidadeAtendimento'] 	:= RTrim(oModel:GetValue('JN3MASTER','JN3_DESCID'))
oResponse['condicaoPagamento'] 		:= RTrim(oModel:GetValue('JN3MASTER','JN3_CONPAG'))
oResponse['pedidoVenda'] 			:= RTrim(oModel:GetValue('JN3MASTER','JN3_PEDIDO'))

oResponse['servicos'] := {}

For nServico := 1 To oModel:GetModel('JN4DETAIL'):Length()

	Aadd(oResponse['servicos'], JsonObject():New())
	
	oModel:GetModel('JN4DETAIL'):GoLine(nServico)

	oResponse['servicos'][nServico]['codigoServico'] 		:= RTrim(oModel:GetValue('JN4DETAIL','JN4_CODJN1', nServico))
	oResponse['servicos'][nServico]['descricaoServico'] 	:= RTrim(EncodeUtf8(oModel:GetValue('JN4DETAIL','JN4_DSCJN1', nServico)))
	oResponse['servicos'][nServico]['checklistObrigatorio'] := RTrim(oModel:GetValue('JN4DETAIL','JN4_CHKOBR', nServico))
	oResponse['servicos'][nServico]['observacoes'] 			:= RTrim(EncodeUtf8(oModel:GetValue('JN4DETAIL','JN4_OBSERV', nServico)))
	oResponse['servicos'][nServico]['tabelaPreco'] 			:= RTrim(oModel:GetValue('JN4DETAIL','JN4_CODDA0', nServico))
	oResponse['servicos'][nServico]['opcaoTabela'] 			:= RTrim(oModel:GetValue('JN4DETAIL','JN4_OPCTAB', nServico))

	oResponse['servicos'][nServico]['produtos'] := {}

	For nProduto := 1 To oModel:GetModel('JN5DETAIL'):Length() 

		Aadd(oResponse['servicos'][nServico]['produtos'], JsonObject():New())

		oModel:GetModel('JN5DETAIL'):GoLine(nProduto)

		oResponse['servicos'][nServico]['produtos'][nProduto]['codigoProduto'] 		:= Rtrim(oModel:GetValue('JN5DETAIL','JN5_CODPRO', nProduto))
		oResponse['servicos'][nServico]['produtos'][nProduto]['descricaoProduto'] 	:= Rtrim(EncodeUtf8(oModel:GetValue('JN5DETAIL','JN5_DSCSB1', nProduto)))
		oResponse['servicos'][nServico]['produtos'][nProduto]['quantidade'] 		:= oModel:GetValue('JN5DETAIL','JN5_QTDPRO', nProduto)

	Next 

	oResponse['servicos'][nServico]['atendentes'] := {}

	For nAtendente := 1 To oModel:GetModel('JN6DETAIL'):Length()

		Aadd(oResponse['servicos'][nServico]['atendentes'], JsonObject():New())
		
		oModel:GetModel('JN6DETAIL'):GoLine(nAtendente)

		oResponse['servicos'][nServico]['atendentes'][nAtendente]['codigoAtendente'] 	:= Rtrim(oModel:GetValue('JN6DETAIL','JN6_CODAA1', nAtendente))
		oResponse['servicos'][nServico]['atendentes'][nAtendente]['codigoFuncao']		:= Rtrim(oModel:GetValue('JN6DETAIL','JN6_CODFUN', nAtendente))
		oResponse['servicos'][nServico]['atendentes'][nAtendente]['dataInicial'] 		:= DtoS(oModel:GetValue('JN6DETAIL','JN6_DTINI', nAtendente))
		oResponse['servicos'][nServico]['atendentes'][nAtendente]['horaInicial'] 		:= Rtrim(StrTran(oModel:GetValue('JN6DETAIL','JN6_HRINI', nAtendente),':'))
		oResponse['servicos'][nServico]['atendentes'][nAtendente]['dataFinal'] 			:= DtoS(oModel:GetValue('JN6DETAIL','JN6_DTFIM', nAtendente))
		oResponse['servicos'][nServico]['atendentes'][nAtendente]['horaFinal'] 			:= Rtrim(StrTran(oModel:GetValue('JN6DETAIL','JN6_HRFIM', nAtendente),':'))
		
	Next 
	
Next 

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD POST ordemServico WSREST FSMORD
Local lRet         := .T.
Local oModel	   := Nil
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgError	   := ''

oRequest:fromJson(DecodeUTF8(cBody))

oModel := FwLoadModel('FSMA008')

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

lRet := GrvOrdServ(oModel, oRequest, @cMsgError)

If lRet
	oResponse['status'] := 'success'
	oResponse['message'] := EncodeUtf8('Ordem de serviço incluída com sucesso')
	oResponse['data'] := {}
		
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['filial'] := oModel:GetValue('JN3MASTER','JN3_FILIAL')
	oResponse['data'][1]['codigoOrdem'] := oModel:GetValue('JN3MASTER','JN3_CODIGO')

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	SetRestFault(400, EncodeUtf8(cMsgError))
Endif

oModel:DeActivate()
oResponse := Nil
oRequest :=  Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author flavio.martins
@since 13/10/2023
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD PUT ordemServico WSREST FSMORD
Local oModel       := Nil
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgError	   := ''

oRequest:fromJson(cBody)

JN3->(dbSetOrder(1))

If !(JN3->(dbSeek(xFilial('JN3')+Self:codigo)))

	SetRestFault(404, EncodeUtf8("Código da ordem de serviço não encontrado"))
	Return .F.

Endif

If !(JN3->JN3_SITUAC $ '00|02')

	SetRestFault(400, EncodeUtf8("Status da ordem de serviço não permite a alteração"))
	Return .F.

Endif	

oModel := FwLoadModel('FSMA008')

JN3->(dbSetOrder(1))

If (JN3->(dbSeek(xFilial('JN3')+Self:codigo)))

	oModel:GetModel('JN4DETAIL'):SetDelAllLine(.T.)
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()

	lRet := GrvOrdServ(oModel, oRequest, @cMsgError)

Endif

If lRet
	oResponse['status'] := 'success'
	oResponse['message'] := EncodeUtf8('Ordem de serviço atualizada com sucesso')
	oResponse['data'] := {}
		
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['filial'] := oModel:GetValue('JN3MASTER','JN3_FILIAL')
	oResponse['data'][1]['codigoOrdem'] := oModel:GetValue('JN3MASTER','JN3_CODIGO')

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	SetRestFault(400, EncodeUtf8(cMsgError))
Endif

oModel:DeActivate()
oResponse := Nil
oRequest :=  Nil

Return lRet

Static Function VlOrdOrig(oModel, cMsgError)
Local lRet := .T.

If !Empty(oModel:GetValue('JN3MASTER', 'JN3_CODORI'))

	JN3->(dbSetOrder(1))

	If JN3->(dbSeek(xFilial('JN3')+oModel:GetValue('JN3MASTER', 'JN3_CODORI')))

		If !Empty(JN3->JN3_PEDIDO)
			cMsgError := 'O.S. de origem já possui pedido de venda gerado e não poderá ser selecionada.'
			Return .F.
		Endif

		If !Empty(JN3->JN3_CODORI)
			cMsgError := 'O.S. de origem selecionada já está vinculada em outra O.S.'
			Return .F.
		Endif

		oModel:SetValue('JN3MASTER', 'JN3_CODPRO', JN3->JN3_CODPRO)
		oModel:SetValue('JN3MASTER', 'JN3_NUMSER', JN3->JN3_NUMSER)
		oModel:SetValue('JN3MASTER', 'JN3_CLIENT', JN3->JN3_CLIENT)
		oModel:SetValue('JN3MASTER', 'JN3_LOJA', JN3->JN3_LOJA)
		oModel:SetValue('JN3MASTER', 'JN3_CONPAG', JN3->JN3_CONPAG)

	Else
		lRet := .F.
		cMsgError := 'Ordem de serviço de origem informada não encontrada.'
	Endif

Endif

Return lRet

Static Function VldBaseAtd(oModel, cMsgError)
Local lRet := .T.

If !Empty(oModel:GetValue('JN3MASTER', 'JN3_CODORI'))
	Return .T.
Endif
		
If !Empty(oModel:GetValue('JN3MASTER', 'JN3_CODPRO'))

	AA3->(dbSetOrder(1))

	If AA3->(dbSeek(xFilial('AA3')+oModel:GetValue('JN3MASTER', 'JN3_CLIENT')+;
								  oModel:GetValue('JN3MASTER','JN3_LOJA')+;
								  oModel:GetValue('JN3MASTER','JN3_CODPRO')+;
								  oModel:GetValue('JN3MASTER','JN3_NUMSER')))

		oModel:SetValue('JN3MASTER', 'JN3_CLIENT', AA3->AA3_CODCLI)
		oModel:SetValue('JN3MASTER', 'JN3_LOJA',   AA3->AA3_LOJA)
	Else
		lRet := .F.
		cMsgError := 'Base de atendimento não encontrada.'
	Endif

Endif

Return lRet

Static Function GrvOrdServ(oModel, oRequest, cMsgError)
Local lRet         := .T.
Local nServico     := 0
Local nProduto     := 0
Local nAtendente   := 0
Local nVlrTabela   := 0

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	oModel:SetValue('JN3MASTER', 'JN3_CODIGO', GetSxEnum('JN3', 'JN3_CODIGO'))
	ConfirmSx8()
Endif 

If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	oModel:GetModel('JN4DETAIL'):DelAllLine()
Endif

oModel:SetValue('JN3MASTER', 'JN3_CODORI', oRequest['ordemOrigem'])
oModel:SetValue('JN3MASTER', 'JN3_DESCRI', oRequest['descricaoOrdem'])
oModel:SetValue('JN3MASTER', 'JN3_CODPRO', oRequest['codigoBase'])
oModel:SetValue('JN3MASTER', 'JN3_NUMSER', oRequest['numeroSerie'])
oModel:SetValue('JN3MASTER', 'JN3_CLIENT', oRequest['codigoCliente'])
oModel:SetValue('JN3MASTER', 'JN3_LOJA'	 , oRequest['lojaCliente'])
oModel:SetValue('JN3MASTER', 'JN3_PRIORI', oRequest['prioridade'])
oModel:SetValue('JN3MASTER', 'JN3_NOMSOL', oRequest['nomeSolicitante'])
oModel:SetValue('JN3MASTER', 'JN3_NOMCNT', oRequest['nomeContato'])
oModel:SetValue('JN3MASTER', 'JN3_TELCNT', oRequest['telefoneContato'])
oModel:SetValue('JN3MASTER', 'JN3_ATEINT', oRequest['atendimentoInterno'])
oModel:SetValue('JN3MASTER', 'JN3_CEP'	 , oRequest['cepAtendimento'])
oModel:SetValue('JN3MASTER', 'JN3_END'	 , oRequest['enderecoAtendimento'])
oModel:SetValue('JN3MASTER', 'JN3_COMPL' , oRequest['complementoAtendimento'])
oModel:SetValue('JN3MASTER', 'JN3_BAIRRO', oRequest['bairroAtendimento'])
oModel:SetValue('JN3MASTER', 'JN3_CIDADE', oRequest['cidadeAtendimento'])
oModel:SetValue('JN3MASTER', 'JN3_ESTADO', oRequest['estadoAtendimento'])
oModel:SetValue('JN3MASTER', 'JN3_CONPAG', oRequest['condicaoPagamento'])

lRet := VlOrdOrig(oModel, @cMsgError)

If lRet 
	lRet := VldBaseAtd(oModel, @cMsgError)
Endif

If lRet 
	For nServico := 1 To Len(oRequest['servicos'])

		If (nServico > 1) 
			oModel:GetModel('JN4DETAIL'):AddLine()
		Endif

		oModel:SetValue('JN4DETAIL', 'JN4_CODJN3', oModel:GetValue('JN3MASTER', 'JN3_CODIGO'))
		oModel:SetValue('JN4DETAIL', 'JN4_CODJN1', oRequest['servicos'][nServico]['codigoServico'])
		oModel:SetValue('JN4DETAIL', 'JN4_CHKOBR', oRequest['servicos'][nServico]['checklistObrigatorio'])
		oModel:SetValue('JN4DETAIL', 'JN4_OBSERV', oRequest['servicos'][nServico]['observacao'])
		oModel:SetValue('JN4DETAIL', 'JN4_CODDA0', oRequest['servicos'][nServico]['tabelaPreco'])
		oModel:SetValue('JN4DETAIL', 'JN4_OPCTAB', oRequest['servicos'][nServico]['opcaoTabela'])

		JN1->(dbSetOrder(1))
		
		If JN1->(dbSeek(xFilial('JN1')+oModel:GetValue('JN4DETAIL', 'JN4_CODJN1')))
			oModel:SetValue('JN4DETAIL', 'JN4_CODPRO', JN1->JN1_CODPRO)
			oModel:SetValue('JN4DETAIL', 'JN4_VALOR', JN1->JN1_VALOR)
		Endif

		If !Empty(oModel:GetValue('JN4DETAIL', 'JN4_CODDA0')) .And. oModel:GetValue('JN4DETAIL', 'JN4_OPCTAB') $ '1|3'

			nVlrTabela := MaTabPrVen(Padr(oModel:GetValue('JN4DETAIL', 'JN4_CODDA0'),TamSx3("DA0_CODTAB")[1]),;
									Padr(oModel:GetValue('JN4DETAIL', 'JN4_CODPRO'),TamSx3("B1_COD")[1]),;
									1,; //quantidade
									Padr(oModel:GetValue('JN3MASTER', 'JN3_CLIENT'),TamSx3("JN3_CLIENT")[1]),;
									Padr(oModel:GetValue('JN3MASTER', 'JN3_LOJA'),TamSx3("JN3_LOJA")[1]),,;
									dDataBase)

			oModel:SetValue('JN4DETAIL', 'JN4_VALOR', nVlrTabela)							 

		Endif 

		If !oModel:GetModel('JN4DETAIL'):VldLineData()
			lRet := .F.
			Exit
		Endif

		If oRequest['servicos'][nServico]['produtos'] != Nil

			For nProduto := 1 To Len(oRequest['servicos'][nServico]['produtos'])

				If (nProduto > 1) 
					oModel:GetModel('JN5DETAIL'):AddLine()
				Endif

				oModel:SetValue('JN5DETAIL', 'JN5_CODJN4', oModel:GetValue('JN4DETAIL', 'JN4_CODIGO'))
				oModel:SetValue('JN5DETAIL', 'JN5_CODPRO', oRequest['servicos'][nServico]['produtos'][nProduto]['codigoProduto'])
				oModel:SetValue('JN5DETAIL', 'JN5_QTDPRO', oRequest['servicos'][nServico]['produtos'][nProduto]['quantidade'])

				SB1->(dbSetOrder(1))
				
				If SB1->(dbSeek(xFilial('SB1')+oModel:GetValue('JN5DETAIL', 'JN5_CODPRO')))
					oModel:SetValue('JN5DETAIL', 'JN5_VALOR', SB1->B1_PRV1)
				Endif

				If !oModel:GetModel('JN5DETAIL'):VldLineData()
					lRet := .F.
					Exit
				Endif

			Next

		Endif

		If lRet .And. oRequest['servicos'][nServico]['atendentes'] != Nil

			For nAtendente := 1 To Len(oRequest['servicos'][nServico]['atendentes'])

				If (nAtendente > 1) 
					oModel:GetModel('JN6DETAIL'):AddLine()
				Endif

				oModel:SetValue('JN6DETAIL', 'JN6_CODJN3', oModel:GetValue('JN3MASTER', 'JN3_CODIGO'))
				oModel:SetValue('JN6DETAIL', 'JN6_CODAA1', oRequest['servicos'][nServico]['atendentes'][nAtendente]['codigoAtendente'])
				oModel:SetValue('JN6DETAIL', 'JN6_DTINI', StoD(oRequest['servicos'][nServico]['atendentes'][nAtendente]['dataInicial']))
				oModel:SetValue('JN6DETAIL', 'JN6_HRINI', Transform(oRequest['servicos'][nServico]['atendentes'][nAtendente]['horaInicial'],'@R 99:99'))
				oModel:SetValue('JN6DETAIL', 'JN6_DTFIM', StoD(oRequest['servicos'][nServico]['atendentes'][nAtendente]['dataFinal']))
				oModel:SetValue('JN6DETAIL', 'JN6_HRFIM', Transform(oRequest['servicos'][nServico]['atendentes'][nAtendente]['horaFinal'],'@R 99:99'))

				AA1->(dbSetOrder(1))
				If AA1->(dbSeek(xFilial('AA1')+oModel:GetValue('JN6DETAIL', 'JN6_CODAA1')))
					oModel:SetValue('JN6DETAIL', 'JN6_CODFUN', AA1->AA1_FUNCAO)
				Endif
				
				If !oModel:GetModel('JN6DETAIL'):VldLineData()
					lRet := .F.
					Exit
				Endif

			Next
		Endif

	Next

	If oModel:VldData()
		oModel:CommitData()
	Else
		lRet 	  := .F.	
		cMsgError := oModel:GetErrorMessage()[6]
	Endif

Endif

Return lRet
