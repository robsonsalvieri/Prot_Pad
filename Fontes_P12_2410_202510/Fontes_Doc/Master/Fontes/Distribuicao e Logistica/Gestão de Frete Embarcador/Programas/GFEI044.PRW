#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"

// SonarQube - CA1003: Uso não permitido de chamada de API em LOOP			
Static s_GFEPC	:= SuperGetMV("MV_GFEPC",.F.,"1",)
Static s_CDCLFR := SuperGetMV("MV_CDCLFR",.F.,"")

//====================================================================================================================\\
/*/{Protheus.doc}GFEI044
//====================================================================================================================
	@description
	Função executada pelo IntegDef do GFEA044, responsável por realizar o processamento da integração do Documento de Carga

	@author		João Leonardo Schmidt
	@version	1.0
	@since		16 de Outubro de 2017
/*/
//===================================================================================================================\\
Function GFEI044(cXml,nType,cTypeMsg,GFELog044)
	Local aResult       := {}
	Local cXmlRet    	:= ""
	Local lResult    	:= .T.
	Local lGFEA065		:= .F.
	Local aDocKey		:= {}
	Local cDocKey		:= ""
	Local cFili			:= ""
	Local cCDESP			:= ""
	Local cEMISDF			:= ""
	Local cSERDF			:= ""
	Local cNRDF	  		:= ""
	Local cDTEMIS
	Local aErrsList := {}

	Private cEntityName := ""
	Private aAreaXX4    := {}
	Private oXml
	
	// Obtem a versao caso seja necessario realizar algum tratamento por versao
	
	if cTypeMsg == EAI_MESSAGE_WHOIS
		dbSelectArea('XX4')
		aAreaXX4 := XX4->(GetArea())

		GFELog044:Add('EXECUTANDO A CHAMADA DA FUNcao RESPONSaVEL POR PROCESSAR A MENSAGEM DE NEGÓCIO...')
		aResult := GFEI044REC(cXml,cTypeMsg,GFELog044)
		
		RestArea(aAreaXX4)
		
		AAdd(aResult,cEntityName)
		AAdd(aResult,.F.)
        AAdd(aResult,.F.)
		Return aResult
	EndIf

	
	oXml := TXmlManager():new()
	If !oXml:Parse(cXml)
		GFELog044:Add('OCORREU ALGUM ERRO...')
		
		lResult:= .F.
		Aadd(aErrsList, {"", 1, ""}) // Description | nType: 1-ERROR;2-WARNING | cCode : Generic Code

		cXmlRet := FWEAILOfMessages(aErrsList)

		aResult := {lResult,cXmlRet}
	Else
		//+---------------------------------------------------------------------
		//| Mensagem - Recebimento
		//+---------------------------------------------------------------------
		cDocKey    := oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId/InternalId/Origin")
		
		IF Len(cDocKey) > 0
			aDocKey := StrToKArr(cDocKey, "|")
			cFili	:= PadR(Alltrim(aDocKey[1]), TamSX3("GW3_FILIAL")[1])
		    cCDESP	:= PadR(Alltrim(aDocKey[2]), TamSX3("GW3_CDESP")[1])
		    cEMISDF	:= PadR(Alltrim(aDocKey[3]), TamSX3("GW3_EMISDF")[1])
		    cSERDF	:= PadR(Alltrim(aDocKey[4]), TamSX3("GW3_SERDF")[1])
		    cNRDF	:= PadR(Alltrim(aDocKey[5]), TamSX3("GW3_NRDF")[1])
		    cDTEMIS := Alltrim(aDocKey[6])

		    GW3->(dbSetOrder(1))
		    lGFEA065 := GW3->(dbSeek(cFili + cCDESP + cEMISDF + cSERDF + cNRDF + cDTEMIS))
		    
		Else
			IF AT("GFEI065",cXml) > 0
				lGFEA065 := .T.
			EndIf
		EndIf
		
		if nType == TRANS_RECEIVE .AND. cTypeMsg == EAI_MESSAGE_RESPONSE .AND. lGFEA065
			
			GFELog044:Add('DESVIO PARA EXECUTAR O GFEA065 GFEI065REC')

			Return GFEI065(cXml,nType,cTypeMsg)
			
		ElseIf nType == TRANS_RECEIVE
			
			dbSelectArea('XX4')
			aAreaXX4 := XX4->(GetArea())

			GFELog044:Add('EXECUTANDO A CHAMADA DA FUNCAO RESPONSAVEL POR PROCESSAR A MENSAGEM DE NEGOCIO...')
			aResult := GFEI044REC(cXml,cTypeMsg,GFELog044)
			
			RestArea(aAreaXX4)
			
		EndIf
	EndIf

	
	//- Adiciona o nome da Transação da mensagem no cadastro do Adapter EAI
	//- Gatilha o campo XX4_MODEL
	AAdd(aResult,cEntityName)
	AAdd(aResult,.F.)
    AAdd(aResult,.F.)

Return aResult

//====================================================================================================================\\
/*/{Protheus.doc}GFEI044REC
//====================================================================================================================
	@description
	Função que processa mensagem de negócio para realizar a integração do Documento de Carga

	@author		João Leonardo Schmidt
	@version	1.0
	@since		16 de Outubro de 2017
/*/
//===================================================================================================================\\
Static Function GFEI044REC(cXml,cTypeMsg,GFELog044)

	// Variáveis para realizar o tratamento da função
	Local cXmlRet    	:= ""
	Local lResult    	:= .T.
	Local oModel 
	Local cAction    	:= ""
	Local cMarca		:= ""
	Local aErrsList		:= {}
	Local lRet 			:= .T.
	Local aErro 		:= {}
	Local cCodeInt 		:= ""
	Local cCodeExt 		:= ""
	Local cAlias 		:= "GW1"
	Local cCampo 		:= "GW1_NRDC"
	Local nOpcx 		:= 0
	Local cCGC			:= ""
	Local cIssueDate	:= ""
	Local aItens		:= {}
	Local aItens2		:= {}
	Local nContItens	:= 0
	Local nX			:= 0
	Local nX2			:= 0
	Local cTribPC		:= ""
	Local cCodDest		:= ""
	Local aRetGU3		:= {}
	Local aEndereco		:= {}
	Local aRedesp		:= {}
	Local aRedesp2		:= {}
	Local cCidEntTre	:= ""
	Local aAux			:= {}
	Local nAux			:= 0
	Local aRetCidRedesp := {}
	Local oTypeOfDocument	:= GFEITypeOfDocument():New()
	
	// Variáveis para gravação das informações da GW1
	Local cGW1_FILIAL   := ""
	Local cGW1_CDTPDC   := ""
	Local cGW1_EMISDC	:= ""
	Local cGW1_DTEMIS	:= ""
	Local cGW1_SERDC	:= ""
	Local cGW1_NRDC		:= ""
	Local cGW1_SIT		:= ""
	Local cGW1_USO		:= ""
	Local cGW1_PEDCLI	:= ""
	Local cGW1_CDREM	:= ""
	Local cGW1_CDDEST 	:= ""
	Local cGW1_TPFRET	:= ""
	Local cGW1_DTIMPL   := ""
	Local cGW1_ORIGEM	:= ""
	Local cGW1_DANFE	:= ""
	Local cGW1_AUTSEF	:= ""
	Local cGW1_ENTEND	:= ""
	Local cGW1_ENTBAI	:= ""
	Local cGW1_ENTCEP	:= ""
	Local cGW1_ENTNRC	:= ""
	Local cTypeOfDocument := ""
	
	// Variáveis para gravação das informações da GW8
	Local cGW8_SEQ		:= ""
	Local cGW8_ITEM		:= ""
	Local cGW8_CDCLFR	:= ""
	Local cGW8_RATEIO   := ""
	Local cGW8_TRIBP	:= ""
	Local cGW8_QTDE		:= ""
	Local cGW8_VALOR	:= 0
	Local nGW8_PESOR	:= 0
	Local nPesoRTot		:= 0
	Local cGW8_UNINEG	:= ""
	Local cGW8_DSITEM	:= ""
	Local nGW8_VOLUME	:= 0
	Local cGW8_VALLIQ	:= 0
	Local cGW8_CFOP     := ""
	
	// Variáveis para gravação das informações da GWU
	Local cGWU_SEQ		:= ""
	Local cGWU_PAGAR	:= ""
	Local cGWU_NRCIDD   := ""
	Local cGWU_CDTRP	:= ""
	
	// Variável responsável por obter o Model da GW8, necessário para efetuar a criação dos vários itens
	Local oModelGW8		:= ""
	Local oModelGWU		:= ""
	
	// Variável para gravar o estado da SM0 antes de efetuar o reposicionamento para gravar corretamente a filial
	Local aAreaSM0		:= SM0->(GetArea())
	
	//+--------------------------------------------------------------+
	//| Trata a mensagem de Negocio/BusinessMessage					 |
	//+--------------------------------------------------------------+
	If cTypeMsg == EAI_MESSAGE_BUSINESS
		
		GFELog044:Add('PROCESSANDO O XML...')
		GFELog044:Add('ACESSANDO AS INFORMAÇÕES...')
		
		// Acessando a tag MessageInformation
		oXML:DOMChildNode()
		
		cMarca     := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )
				
		// Acessando a tag BussinessMessage
		oXML:DOMNextNode()
		
		// Acessando a tag BussinesEvent
		oXML:DOMChildNode()
		
		//Inicio do processamento do XML de Endereço de Entrega.
		cCodeExt   := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Entity")
		cAction    := Upper(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Event"))
		
		//Obtém o código interno da tabela de/para através de um código externo
		cCodeInt := PadR(CFGA070INT( cMarca, cAlias, cCampo, cCodeExt ), TamSX3('GW1_NRDC')[1])
		
		If Empty(cCodeInt)
			cCodeInt := cCodeExt
		EndIf
		
		// Acessando a tag BussinesContent
		oXML:DOMNextNode()
		
		cIssueDate		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/IssueDate")
		cIssueDate		:= SToD(SubStr(cIssueDate,1,4) + SubStr(cIssueDate,6,2) + SubStr(cIssueDate,9,2))
		
		GFELog044:Add('PROCESSANDO AS INFORMAÇÕES REFERENTE AO CABEÇALHO DO DOCUMENTO...')
		
		// Informações Obrigatórias do cabeçalho da nota fiscal (GW1)
		cGW1_FILIAL		:= xFilial("GW1")

		// Posiciona a SM0 na filial vinda na mensagem de negócio
		SM0->(dbSetOrder(1))
		if !SM0->(DbSeek(cEmpAnt+cGW1_FILIAL))
			Return {.F.,_NoTags('Empresa:' + cEmpAnt + ' Filial: ' + cGW1_FILIAL + ' não encontrados no cadastro de empresas (SM0)')}
		EndIf

		cCGC			:= PADR(SM0->M0_CGC,TamSX3("GU3_IDFED")[1])
		cCodDest		:= PADR(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/CustomerCode"),TamSX3("GU3_CDEMIT")[1])
		
		cTypeOfDocument := AllTrim(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/TypeOfDocument"))
		
		oTypeOfDocument:ClearData()
		oTypeOfDocument:setTypeOfDocument(cTypeOfDocument)
		oTypeOfDocument:setNoTags(.T.)
		oTypeOfDocument:Localizar()
		cGW1_CDTPDC := oTypeOfDocument:getTypeOfDocument()
		lResult		:= oTypeOfDocument:getStatus()
		cXmlRet		:= oTypeOfDocument:getMensagem()
		oTypeOfDocument:Destroy(oTypeOfDocument)
		
		if !lResult
			Return {lResult,cXmlRet}
		EndIf
		
		aRetGU3			:= GU3Find(11,xFilial("GU3")+cCGC,"GU3_CDEMIT")
		if aRetGU3[1] == "2"
			Return {.F.,_NoTags('Emissor do Documento de Carga não localizado (GU3). CNPJ do Cadastro de Empresas:' + cCGC)}
		Elseif aRetGU3[1] == "3"
			Return {.F.,_NoTags("O Emitente " + aRetGU3[2] + " foi encontrado porém está Inativo. Favor verificar o cadastro do emitente. CNPJ do Cadastro de Empresas:" + cCGC)}
		EndIf
		cGW1_EMISDC		:= aRetGU3[2]
		cGW1_CDREM		:= aRetGU3[2]

		cGW1_DTEMIS		:= cIssueDate
		cGW1_SERDC		:= PADR(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/InvoiceSerie"),TamSX3("GW1_SERDC")[1])
		cGW1_NRDC		:= PADR(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/InvoiceNumber"),TamSX3("GW1_NRDC")[1])
		cGW1_SIT		:= "3"
		cGW1_USO		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/FinalConsumerIndicator") //GW1_USO - 1=Industrializacao/Venda;2=Uso/Consumo;3=Ativo Imobilizado
		If cGW1_USO == "1" // Invoice_3_010 - <Description>Indicador de consumidor final 0-Não, 1-Consumidor Final </Description>
			cGW1_USO := "2"
		Else
			cGW1_USO := InitPad(GetSx3Cache("GW1_USO","X3_RELACAO")) // Pega o conteúdo padrão
		EndIf
		
		cGWU_CDTRP	:= Padr(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/CarrierCode"),TamSX3("GU3_CDEMIT")[1])
		If !Empty(cGWU_CDTRP)
			aRetGU3			:= GU3Find(01,xFilial("GU3")+cGWU_CDTRP,"GU3_CDEMIT",.T.)
			if aRetGU3[1] == "2"
				Return {.F.,_NoTags('Transportador do Documento de Carga não localizado (GU3). Código utilizado para consulta (CarrierCode):' + cGWU_CDTRP)}
			Elseif aRetGU3[1] == "3"
				Return {.F.,_NoTags("O Transportador " + aRetGU3[2] + " foi encontrado porém está Inativo. Favor verificar o cadastro do emitente. Código utilizado para consulta (CarrierCode):" + cGWU_CDTRP)}
			Elseif aRetGU3[1] == "4"
				Return {.F.,_NoTags("O CNPJ " + aRetGU3[2] + " não é um transportador ou autônomo. Favor verificar o cadastro do emitente. Código utilizado para consulta (CarrierCode):" + cGWU_CDTRP)}
			EndIf
			cGWU_CDTRP 	:= aRetGU3[2]
		EndIf

		nPesoRTot	:= Val(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/GrossWeight"))
		cGW1_DANFE	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ElectronicAccessKey")
		cGW1_AUTSEF	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ElectronicProtocol")
		if !Empty(cGW1_AUTSEF) // Quando existe o número do protocolo, gravar como Autorizado
			cGW1_AUTSEF := "1" //0=Nao informado;1=Autorizado;2=Nao-autorizado;3=Nao se aplica
		Else
			cGW1_AUTSEF := "0"
		EndIf
		
		aRetGU3			:= GU3Find(01,xFilial("GU3")+cCodDest,"GU3_CDEMIT")
		
		if aRetGU3[1] == "2"
			Return {.F.,_NoTags('Destinatário do Documento de Carga não localizado (GU3). Código utilizado para consulta (CustomerCode):' + cCodDest)}
		Elseif aRetGU3[1] == "3"
			Return {.F.,_NoTags("O Emitente " + aRetGU3[2] + " foi encontrado porém está Inativo. Favor verificar o cadastro do emitente. Código utilizado para consulta (CustomerCode):" + cCodDest)}
		EndIf
		
		cGW1_CDDEST 	:= aRetGU3[2]
		
		cGW1_TPFRET		:= "1"
		cGW1_DTIMPL		:= cIssueDate
		cGW1_ORIGEM		:= "2"
		
		// Posiciona no nós das informações de negócio
		oXML:DOMChildNode()
		
		// Informações Obrigatórias dos trechos da nota fiscal (GWU)
		cGWU_SEQ		:= "01"
		cGWU_PAGAR		:= "1"
		
		aRetGU3			:= GU3Find(01,xFilial("GU3")+cCodDest,"GU3_NRCID")
		
		If aRetGU3[1] == "2"
			Return {.F.,_NoTags('Destinatário/Cidade do Documento de Carga não localizado (GU3). Código utilizado para consulta (CustomerCode):' + cCodDest)}
		Elseif aRetGU3[1] == "3"
			Return {.F.,_NoTags("O Emitente " + aRetGU3[2] + " foi encontrado porém está Inativo. Favor verificar o cadastro do emitente. Código utilizado para consulta (CustomerCode):" + cCodDest)}
		EndIf
		
		aAdd(aRedesp2,{cGWU_SEQ,  ;
					   cGWU_CDTRP,;
					   cGWU_PAGAR,;
					   ""})
		
		cGWU_SEQ 	:= ""
		cGWU_CDTRP 	:= ""
		cGWU_PAGAR 	:= ""
		cGWU_NRCIDD := ""	  
		
		While(oXML:DOMHasNextNode())
			// Passando para o próximo nó quando houver
			oXML:DOMNextNode()
		
			If (oXML:CNAME == "ListOfItens" .Or. oXML:CNAME == "ListOfItems")
				nContItens := oXML:DOMChildCount()
		
				// Acessando o Item do ListOfItens
				oXML:DOMChildNode()
				
				// Busca a configuração do Módulo para gravar a tributação de PIS/COFINS e Classificação de Frete
				cTribPC    := s_GFEPC
				cModCdClFr := s_CDCLFR
				
				GFELog044:Add('PROCESSANDO AS INFORMAÇÕES REFERENTE AOS ITENS DO DOCUMENTO DE CARGA...')
				
				For nX := 1 TO nContItens
					// Converte os atributos dos itens em um array para utilizar as informações
					aItens := oXML:DOMGetChildArray()
					
					For nX2 := 1 TO Len(aItens)
						// Informações Obrigatórias dos itens da nota fiscal (GW8)
						If aItens[nX2][1] == "InvoiceSequence"
							cGW8_SEQ := PADL(aItens[nX2][2],TamSX3("GW8_SEQ")[1],"0")
						ElseIf aItens[nX2][1] == "ItemCode"
							cGW8_ITEM := aItens[nX2][2]
						ElseIf aItens[nX2][1] == "Quantity"
							cGW8_QTDE := Val(aItens[nX2][2])
						ElseIf aItens[nX2][1] == "GrossValue"
							cGW8_VALLIQ := Val(aItens[nX2][2])
						ElseIf aItens[nX2][1] == "DiscountValue"
							cGW8_VALLIQ := cGW8_VALLIQ - Val(aItens[nX2][2])					
						ElseIf aItens[nX2][1] == "NetValue"
							cGW8_VALOR := Val(aItens[nX2][2])
						ElseIf aItens[nX2][1] == "OrderNumber"
							// O primeiro pedido que encontrar será considerado
							If Empty(cGW1_PEDCLI)
								cGW1_PEDCLI := aItens[nX2][2]
							EndIf
						ElseIf aItens[nX2][1] == "AreAndLineOfBusinessCode"
							If Len(aItens[nX2][2]) > (TamSX3("GW8_UNINEG")[1])
								Return {.F.,_NoTags("O conteúdo da TAG AreAndLineOfBusinessCode excede o tamanho do campo GW8_UNINEG. Efetue o ajuste do tamanho do grupo de campos por meio do módulo Configurador (SIGACFG) do Protheus/GFE.")}
							Else
								cGW8_UNINEG := aItens[nX2][2]
							EndIf
						ElseIf aItens[nX2][1] == "ItemDescription"
							cGW8_DSITEM := SubStr(aItens[nX2][2],1,TamSX3("GW8_DSITEM")[1])
						ElseIf aItens[nX2][1] == "ItemVolume"
							nGW8_VOLUME	:= Val(aItens[nX2][2])
						ElseIf aItens[nX2][1] == "ItemGrossWeight"
							nGW8_PESOR	:= Val(aItens[nX2][2])
						ElseIf aItens[nX2][1] == "TaxOpCodeItem"
							cGW8_CFOP	:= aItens[nX2][2]
						EndIf
						
						// Executa a busca especifica da Classificação de Frete e grava as informações 
						// somente quando o item estiver preenchido
						If cGW8_ITEM != ""
							GUK->(dbSetOrder(1))
							If GUK->(dbSeek(xFilial("GUK") + cGW8_ITEM))
								cGW8_CDCLFR := GUK->GUK_CDCLFR
							Else
								cGW8_CDCLFR := cModCdClFr
							EndIf
							
							cGW8_RATEIO   	:= "1"
							cGW8_TRIBP		:= cTribPC
						EndIf
					Next nX2
					
					aAdd(aItens2,{cGW8_SEQ,    ; 
								  cGW8_ITEM,   ;
								  cGW8_CDCLFR, ;
								  cGW8_RATEIO, ;
								  cGW8_TRIBP,  ;
								  cGW8_QTDE,   ;
								  cGW8_VALOR,  ;
								  nGW8_PESOR,  ;
								  cGW8_UNINEG, ;
								  cGW8_DSITEM, ;
								  nGW8_VOLUME, ;
								  cGW8_VALLIQ, ;
								  cGW8_CFOP})
					
					cGW8_SEQ	:= ""
					cGW8_ITEM	:= ""
					cGW8_CDCLFR	:= ""
					cGW8_RATEIO	:= ""
					cGW8_TRIBP	:= ""
					cGW8_QTDE	:= ""
					cGW8_VALOR	:= 0
					nGW8_PESOR  := 0
					cGW8_UNINEG := ""
					cGW8_DSITEM := ""
					nGW8_VOLUME := 0
					cGW8_VALLIQ := 0
					cGW8_CFOP   := ""
					
					aItens := {}
					
					// Passa para o próximo item quando houver
					If oXML:DOMHasNextNode()
						oXML:DOMNextNode()
					EndIf
				Next nX
				
				// Voltando ao nó do ListOfItens a partir do nó do último Item
				While(oXML:CNAME != "ListOfItens" .And. oXML:CNAME != "ListOfItems")
					If oXML:DOMHasParentNode()
						oXML:DOMParentNode()
					EndIf
				EndDo								
			ElseIf (oXML:CNAME == "ShippingAddress")
				// Transformando os atributos do Endereço em um array
				aEndereco := oXML:DOMGetChildArray()
				
				// Gravando as informações dos itens
				For nX := 1 TO Len(aEndereco)
					If aEndereco[nX][1] == "Address"
						cGW1_ENTEND := aEndereco[nX][2]
					EndIf
					If aEndereco[nX][1] == "District"
						cGW1_ENTBAI := aEndereco[nX][2]
					EndIf
					If aEndereco[nX][1] == "ZIPCode"
						cGW1_ENTCEP := aEndereco[nX][2]
					EndIf
					If aEndereco[nX][1] == "City"
						If !Empty(aEndereco[nX][2])
							GU7->(dbSetOrder(1))
							
							If !GU7->(DbSeek(xFilial("GU7") + AllTrim(aEndereco[nX][2])))
								Return {.F.,_NoTags('A cidade de entrega com o código ' + aEndereco[nX][2] + ' não foi encontrada. Verifique o cadastro de cidades (GFEA020).')}
							Else
								If GU7->GU7_SIT == '2'
									Return {.F.,_NoTags('A cidade de entrega com o código ' + aEndereco[nX][2] + ' foi encontrada, porém a sua situação (GU7_SIT) está como inativa. Verifique a situação da cidade no cadastro de cidades (GFEA020).')}
								Else
									cGW1_ENTNRC := GU7->GU7_NRCID
								EndIf
							EndIf					
						EndIf
					EndIf
				Next nX
				
				GFELog044:Add('PROCESSANDO AS INFORMAÇÕES REFERENTE AOS TRECHOS DO DOCUMENTO DE CARGA...')
				
				// Voltando ao nó do ShippingAdress a partir do nó do último Endereço
				While(oXML:CNAME != "ShippingAddress")
					If oXML:DOMHasParentNode()
						oXML:DOMParentNode()
					EndIf
				EndDo			
			ElseIf (oXML:CNAME == "ListOfConsignee")
				// Altera o tipo para CIF com Redespacho			
				cGW1_TPFRET := "2"
				
				nContRedesp := oXML:DOMChildCount()
	
				oXML:DOMChildNode()
		
				For nX := 1 TO nContRedesp
					// Transformando os atributos dos Reespachantes em um array
					If nX == 1
						aRedesp := oXML:DOMGetChildArray()
					EndIf
					
					aAux 	:= AClone(aRedesp)
					
					For nX2 := 1 To Len(aRedesp)
						If aRedesp[nX2][1] == "ConsigneeSequence"
							cGWU_SEQ	:= PADL(cValToChar(nX + 1),TamSX3("GWU_SEQ")[1],"0")
						EndIf
						If aRedesp[nX2][1] == "ConsigneeCode"
							If nX == 1
								aRetCidRedesp := GU3Find(01,xFilial("GU3")+aRedesp[nX2][2],"GU3_NRCID")
								
								If aRetCidRedesp[1] == "1"
									aRedesp2[1][4] := aRetCidRedesp[2]
								EndIf
							EndIf
							
							If !Empty(aRedesp[nX2][2])
								aGU3Ret := GU3Find(01,xFilial("GU3")+aRedesp[nX2][2],"GU3_CDEMIT",.T.)
								
								If aGU3Ret[1] == "2"
									Return {.F.,_NoTags('Redespachante do Documento de Carga não localizado (GU3). Código utilizado para consulta (ConsigneeCode):' + aRedesp[nX2][2])}
								ElseIf aGU3Ret[1] == "3"
								  	Return {.F.,_NoTags("O Emitente " + aRedesp[nX2][2] + " foi encontrado porém está Inativo. Favor verificar o cadastro do emitente. Código utilizado para consulta (ConsigneeCode):" + aRedesp[nX2][2])}
								ElseIf aGU3Ret[1] == "4"
								  	Return {.F.,_NoTags("O Emitente " + aRedesp[nX2][2] + " foi encontrado porém não é Transportador ou Autônomo. Favor verificar o cadastro do emitente. Código utilizado para consulta (ConsigneeCode):" + aRedesp[nX2][2])}
								EndIf
								
								cGWU_CDTRP  := aRedesp[nX2][2]
							EndIf
						EndIf
						If aRedesp[nX2][1] == "FreightType"
							If aRedesp[nX2][2] != "1" .And. aRedesp[nX2][2] != "2"
								Return {.F.,_NoTags("A informação de pagar do trecho " + cGWU_SEQ + " não foi prenchida corretamente. O código utilizado para preenchimento (FreightType):" + aRedesp[nX2][2]) + ". Preencha o campo com os valores 1-Pago ou 2-Não Pago."}
							EndIf
							
							cGWU_PAGAR  := aRedesp[nX2][2]
						EndIf
					Next nX2
					
					aRedesp := {}
						
					// Passa para o próximo de redespachante quando houver
					If oXML:DOMHasNextNode()
						oXML:DOMNextNode()
					EndIf
					
					aRedesp := oXML:DOMGetChildArray()
					
					If Empty(cGWU_NRCIDD)
						If (nX + 1) <= nContRedesp
							For nAux := 1 To Len(aRedesp)
								If aAux[nAux][1] == "ConsigneeCode"
									aRetCidRedesp := GU3Find(01,xFilial("GU3")+aRedesp[nAux][2],"GU3_NRCID")
									
									cCidEntTre 	  := aRetCidRedesp[2]
									
									aRetCidRedesp := {}
								EndIf
							Next nAux					
						Else
							If !Empty(cGW1_ENTNRC)
								cCidEntTre := cGW1_ENTNRC
							Else
								cCidEntTre := POSICIONE("GU3",01,xFilial("GU3")+cGW1_CDDEST,"GU3_NRCID")
							EndIf
						EndIf
						
						cGWU_NRCIDD := cCidEntTre
					EndIf
											
					aAdd(aRedesp2,{ cGWU_SEQ,  ;
					 				cGWU_CDTRP,;
					 				cGWU_PAGAR,;
					 				cGWU_NRCIDD})

					cGWU_SEQ	:= ""
					cGWU_CDTRP	:= ""
					cGWU_PAGAR	:= ""
					cGWU_NRCIDD := ""
						
				Next nX
				
				// Voltando ao nó do ListofConsignee a partir do nó do último Redespachante
				While(oXML:CNAME != "ListOfConsignee")
					If oXML:DOMHasParentNode()
						oXML:DOMParentNode()
					EndIf
				EndDo
			EndIf
		EndDo
		
		If cGW1_TPFRET == "1"
			If !Empty(cGW1_ENTNRC)
				cCidEntTre := cGW1_ENTNRC
			Else
				cCidEntTre := aRetGU3[2]
			EndIf
			
			aRedesp2[1][4] := cCidEntTre
		EndIf
		
		//Valida a ação sendo: upsert=inclusão/alteração ou delete=exclusão
		If cAction == "UPSERT" 
			GW1->(dbSetOrder(1))
			If !GW1->(dbSeek(cGW1_FILIAL + cGW1_CDTPDC + cGW1_EMISDC + cGW1_SERDC + cGW1_NRDC))
				nOpcx := 3
			Else
				nOpcx := 4
			EndIf
		ElseIf cAction == "DELETE"
			GW1->(dbSetOrder(1))
			GW1->(dbSeek(cGW1_FILIAL + cGW1_CDTPDC + cGW1_EMISDC + cGW1_SERDC + cGW1_NRDC))
			nOpcx := 5
		EndIf
		
		// Carrega o model do GFEA044 para iniciar a gravação dos dados
		oModel := FWLoadModel( "GFEA044" )
		oModel:SetOperation( nOpcx )
		oModel:Activate()
		
		// Capturando o Model da GW8 para a criação de vários itens
		oModelGW8 := oModel:GetModel("GFEA044_GW8")
		oModelGWU := oModel:GetModel("GFEA044_GWU")
	
		If nOpcx != 5
			GFELog044:Add('EFETUANDO A GRAVAÇÃO DAS INFORMAÇÕES...')
		
			// Gravando os dados do cabeçalho do documento de carga
			If !oModel:SetValue("GFEA044_GW1",'GW1_FILIAL'	, cGW1_FILIAL)
				aErro := oModel:GetErrorMessage()
				Return {.F.,_NoTags(aErro[6] + ' Campo: ' + aErro[4])}
			EndIf
			oModel:SetValue("GFEA044_GW1",'GW1_CDTPDC'	, cGW1_CDTPDC)
			oModel:SetValue("GFEA044_GW1",'GW1_EMISDC' 	, cGW1_EMISDC)
			oModel:SetValue("GFEA044_GW1",'GW1_DTEMIS' 	, cGW1_DTEMIS)
			oModel:SetValue("GFEA044_GW1",'GW1_SERDC' 	, cGW1_SERDC)
			oModel:SetValue("GFEA044_GW1",'GW1_NRDC' 	, cGW1_NRDC)
			oModel:SetValue("GFEA044_GW1",'GW1_SIT' 	, cGW1_SIT)
			oModel:SetValue("GFEA044_GW1",'GW1_USO' 	, cGW1_USO)
			oModel:SetValue("GFEA044_GW1",'GW1_DANFE' 	, cGW1_DANFE)
			oModel:SetValue("GFEA044_GW1",'GW1_AUTSEF' 	, cGW1_AUTSEF)
			oModel:SetValue("GFEA044_GW1",'GW1_PEDCLI' 	, cGW1_PEDCLI)
			If !oModel:SetValue("GFEA044_GW1",'GW1_CDREM' 	, cGW1_CDREM)
				aErro := oModel:GetErrorMessage()
				Return {.F.,_NoTags(aErro[6] + ' Campo: ' + aErro[4])}
			EndIf
			If !oModel:SetValue("GFEA044_GW1",'GW1_CDDEST' 	, cGW1_CDDEST)
				aErro := oModel:GetErrorMessage()
				Return {.F.,_NoTags(aErro[6] + ' Campo: ' + aErro[4])}
			EndIf
			oModel:SetValue("GFEA044_GW1",'GW1_TPFRET' 	, cGW1_TPFRET)
			oModel:SetValue("GFEA044_GW1",'GW1_DTIMPL' 	, cGW1_DTIMPL)
			oModel:SetValue("GFEA044_GW1",'GW1_ORIGEM' 	, cGW1_ORIGEM)
			oModel:SetValue("GFEA044_GW1",'GW1_ENTEND'	, cGW1_ENTEND)
			oModel:SetValue("GFEA044_GW1",'GW1_ENTBAI'	, cGW1_ENTBAI)
			oModel:SetValue("GFEA044_GW1",'GW1_ENTCEP'	, cGW1_ENTCEP)
			oModel:SetValue("GFEA044_GW1",'GW1_ENTNRC'	, cGW1_ENTNRC)
			
			// Executa a gravação dos itens do documento de carga
			For nX := 1 To Len(aItens2)
				If nX != 1
					oModelGW8:AddLine()
				EndIf
			 
				oModel:SetValue("GFEA044_GW8",'GW8_SEQ'    , aItens2[nX][1])
				oModel:SetValue("GFEA044_GW8",'GW8_ITEM'   , aItens2[nX][2])
				oModel:SetValue("GFEA044_GW8",'GW8_CDCLFR' , aItens2[nX][3])
				oModel:SetValue("GFEA044_GW8",'GW8_RATEIO' , aItens2[nX][4])
				oModel:SetValue("GFEA044_GW8",'GW8_TRIBP'  , aItens2[nX][5])	
				oModel:SetValue("GFEA044_GW8",'GW8_QTDE'   , aItens2[nX][6])
				oModel:SetValue("GFEA044_GW8",'GW8_VALOR'  , aItens2[nX][7])
				oModel:SetValue("GFEA044_GW8",'GW8_PESOR'  , aItens2[nX][8])
				oModel:SetValue("GFEA044_GW8",'GW8_UNINEG' , aItens2[nX][9])
				oModel:SetValue("GFEA044_GW8",'GW8_DSITEM' , aItens2[nX][10])
				oModel:SetValue("GFEA044_GW8",'GW8_VOLUME' , aItens2[nX][11])
				oModel:SetValue("GFEA044_GW8",'GW8_VALLIQ' , aItens2[nX][12])
				oModel:SetValue("GFEA044_GW8",'GW8_CFOP'   , aItens2[nX][13])
			Next Nx		
			
			// Realiza a gravação dos trechos do documento de carga
			For nX := 1 To Len(aRedesp2)
				If nX != 1
					oModelGWU:AddLine()
				EndIf
			
				oModel:SetValue("GFEA044_GWU",'GWU_SEQ'   , aRedesp2[nX][1])
				oModel:SetValue("GFEA044_GWU",'GWU_CDTRP' , aRedesp2[nX][2]) // o campo transportador tem gatilho, desta forma deve ser o segundo campo a receber informação
				oModel:SetValue("GFEA044_GWU",'GWU_PAGAR' , aRedesp2[nX][3])
				oModel:SetValue("GFEA044_GWU",'GWU_NRCIDD', aRedesp2[nX][4])
			Next nX
		EndIf
		
		// Valida o Model
		lRet := oModel:VldData()
		
		If lRet
			oModel:CommitData()		
			GFELog044:Add('GRAVAÇÃO EFETUADA COM SUCESSO...')						
			// Monta xml com status do processamento da rotina automatica OK.
			cXMLRet +=      "<ListOfInternalId>"
			cXMLRet +=            "<InternalId>"
			cXMLRet +=                  "<Name>CodeInternalId</Name>"
			cXMLRet +=                  "<Origin>"      + cCodeExt + "</Origin>"
			cXMLRet +=                  "<Destination>" + cCodeInt + "</Destination>"
			cXMLRet +=            "</InternalId>"
			cXMLRet +=      "</ListOfInternalId>"
		Else
			GFELog044:Add('OCORREU ALGUM ERRO AO GRAVAR AS INFORMAÇÕES...')	
			//Recupera as mensagens de erro
			aErro := oModel:GetErrorMessage()
			oModel:DeActivate()			
			cXmlRet := ""
			cXmlRet += _NoTags(aErro[6] + ' Campo: ' + aErro[4])
			lResult := .F.
		EndIf
		
		//+--------------------------------------------------------------
		//| Trata a mensagem de Resposta/Devolve Mensagem.
		//+--------------------------------------------------------------
	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
	
		//+--------------------------------------------------------------
		//| Mensagem: responde com a Versão
		//+--------------------------------------------------------------
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
		cXmlRet := "1.000|3.011"
	
		//+--------------------------------------------------------------
		//| Trata a mensagem de Negocio/BusinessMessage
		//+--------------------------------------------------------------
	ElseIf cTypeMsg == EAI_MESSAGE_RECEIPT
	
	EndIf
	
	//Monta a mensagem de erro
	If !Empty(aErrsList)
		lResult := .F.
		cXmlRet := FWEAILOfMessages( aErrsList )
	EndIf
	
	// Recupera a Área da SM0 conforme estava antes de reposicionar
	RestArea(aAreaSM0)

Return {lResult,cXmlRet}

/*/{Protheus.doc} GU3Find
//TODO Localiza o emitente.
@author andre.wisnheski
@since 27/10/2017
@version 1.0
@return ${nRet, cRet}, ${Codigo do erro}
@param nIndice, numeric, descricao
@param cChave, characters, descricao
@param cCampoRet, characters, descricao
@param lTransp, logical, descricao
@type function
/*/
Static Function GU3Find(nIndice, cChave, cCampoRet, lTransp)
	Local nRet := "2" // Não localizado
	Local cRet := ""
	Default lTransp := .F.
	
	GU3->(dbSetOrder(nIndice))
	if GU3->(dbSeek(cChave))
		nRet := "1" //Registro localizado
		IF GU3->GU3_SIT == "2"
			nRet := "3" // Emitente Inativo
		elseif lTransp .AND. !(GU3->GU3_TRANSP == "1" .OR. GU3->GU3_AUTON == "1") // Deve ser um transportador ou autonomo
			nRet := "4" // Emitente não é transportador ou Autonomo
		EndIf
		cRet := &("GU3->" + cCampoRet)
		cRet := PADR(cRet,TamSX3(cCampoRet)[1])
	EndIf
Return {nRet, cRet}

