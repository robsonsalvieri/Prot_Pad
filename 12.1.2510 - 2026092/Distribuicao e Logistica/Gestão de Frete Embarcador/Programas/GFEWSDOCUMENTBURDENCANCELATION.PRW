#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
 
WSRESTFUL DOCUMENTBURDENCANCELATION DESCRIPTION "Serviço especifico para cancelamento do Documento de Carga - SIGAGFE - GESTÃO DE FRETE EMBARCADOR"

	// TIPO DE OPERAÇÃO
	// "1" = Somente Verificação/Validação 
	// "2" = Verificação/Validação e execução da operação solicitada
	WSDATA CODTPOPERACAO AS STRING
	 
	WSMETHOD GET  DESCRIPTION "Exemplo de arquivo JSON para utilizar com base no cancelamento do Documento de Carga no módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR" WSSYNTAX "supply/gfe/v1/DocumentBurdenCancelations || /GET/{id}"
	WSMETHOD POST DESCRIPTION "Executa as validações e cancelamento do Documento de Carga no módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR"                           WSSYNTAX "supply/gfe/v1/DocumentBurdenCancelations || /POST/{id}"

END WSRESTFUL

WSMETHOD GET WSSERVICE DOCUMENTBURDENCANCELATION
	Local oResponse   := JsonObject():New()

	/* DEFINIÇÃO DOS TAMANHOS DOS CAMPOS*/
	Local nGW1CDTPDC	:= TamSX3("GW1_CDTPDC")[1]
	Local nGW1EMISDC	:= TamSX3("GW1_EMISDC")[1]
	Local nGW1SERDC		:= TamSX3("GW1_SERDC")[1]
	Local nGW1NRDC		:= TamSX3("GW1_NRDC")[1]
	
	/* A FILIAL DEVE SER ENVIADA VIA PROTOCOLO REST NO HEADER tenantId CONFORME DOCUMENTAÇÃO DO PROTOCOLO REST NA TDN*/  

	// define o tipo de retorno do método
	::SetContentType("application/json")
	 
	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())

	oResponse["content"][1]["Items"][1]["DocumentBurden"] := {}

	Aadd(oResponse["content"][1]["Items"][1]["DocumentBurden"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"] := {}
	
	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["id"] := "TypeOfDocument"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["length"] := nGW1CDTPDC
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["Description"] := "Tipo do Documento de Carga/Nota Fiscal"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["value"] := PADR("NFS",nGW1CDTPDC,' ')

	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["id"] := "IssuerCode"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["length"] := nGW1EMISDC
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["Description"] := "Emitente do Documento de Carga/Nota Fiscal"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["value"] := PADR("000000003",nGW1EMISDC,' ')

	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["id"] := "InvoiceSerie"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["length"] := nGW1SERDC
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["Description"] := "Série do Documento de Carga/Nota Fiscal"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["value"] := PADR("1",nGW1SERDC,' ')

	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["id"] := "InvoiceNumber"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["length"] := nGW1NRDC
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["Description"] := "Número do Documento de Carga/Nota Fiscal"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["value"] := PADR("000026",nGW1NRDC,' ')

	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["id"] := "ElectronicAccessKey"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["length"] := 44
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["Description"] := "Chave de Acesso Eletrônica"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])["value"] := PADR(" ",44,' ')

	Aadd(oResponse["content"][1]["Items"][1]["DocumentBurden"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"] := {}
	
	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["id"] := "TypeOfDocument"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["length"] := nGW1CDTPDC
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["Description"] := "Tipo do Documento de Carga/Nota Fiscal"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["value"] := PADR("NFS",nGW1CDTPDC,' ')

	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["id"] := "IssuerCode"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["length"] := nGW1EMISDC
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["Description"] := "Emitente do Documento de Carga/Nota Fiscal"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["value"] := PADR("000000003",nGW1EMISDC,' ')

	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["id"] := "InvoiceSerie"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["length"] := nGW1SERDC
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["Description"] := "Série do Documento de Carga/Nota Fiscal"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["value"] := PADR("18",nGW1SERDC,' ')

	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["id"] := "InvoiceNumber"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["length"] := nGW1NRDC
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["Description"] := "Número do Documento de Carga/Nota Fiscal"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["value"] := PADR("031401",nGW1NRDC,' ')

	Aadd( oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["id"] := "ElectronicAccessKey"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["length"] := 44
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["Description"] := "Chave de Acesso Eletrônica"
	aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][2]["Items"])["value"] := PADR(" ",44,' ')


	::SetResponse(EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.)))
	
Return .T.

WSMETHOD POST WSRECEIVE CODTPOPERACAO  WSSERVICE DOCUMENTBURDENCANCELATION
	Local oContent		:= Nil
	Local aRetCanc
	Local aRetRom		:= {}
	Local cContent		:= ""
	Local aRet			:= {}
	Local cReturn		:= ""
	Local nCont 		:= 0
	Local cGW1FILIAL	:= '' 
	Local cGW1EMISDC	:= '' 
	Local cGW1CDTPDC	:= '' 
	Local cGW1SERDC		:= '' 
	Local cGW1NRDC		:= ''
	Local nTpOper		:= 1
	
	Default Self:CODTPOPERACAO  := "2"
	
	// define o tipo de retorno do método
	::SetContentType("application/json")
	
	cContent :=  ::GetContent()
	
	aRet := ValidContent(cContent)
	If !aRet[1]
		::SetResponse(EncodeUTF8(FWJsonSerialize(aRet[2], .F., .F., .T.)))
		Return .T.
	EndIf
	
	FWJsonDeserialize(cContent,@oContent)
	
	aRet := ReadContent(oContent)
	
	if Self:CODTPOPERACAO  == "2"
		nTpOper := 2
	EndIf
	
	for nCont:= 1 to Len(aRet)
		if aRet[nCont][1]

			cGW1FILIAL	:= xFilial("GW1")
			cGW1CDTPDC	:= aRet[nCont][3][1]
			cGW1EMISDC	:= aRet[nCont][3][2]
			cGW1SERDC	:= aRet[nCont][3][3]
			cGW1NRDC	:= aRet[nCont][3][4]

			aRetCanc := GFE44CancelarDC(cGW1FILIAL, cGW1CDTPDC, cGW1EMISDC, cGW1SERDC, cGW1NRDC,nTpOper,.F.,.F.) 

			if aRetCanc[1]
				aAdd(aRetRom,{"ok"   ,"Processo realizado com sucesso",aRet[nCont][3]})
			else
				aAdd(aRetRom,{'error',aRetCanc[2],aRet[nCont][3]})
			EndIf
		Else
			aAdd(aRetRom,{'error',aRet[nCont][2],aRet[nCont][3]})
		EndIf
	next
	
	cReturn := FWJsonSerialize(WriteCalculation(aRetRom, nTpOper), .F., .F., .T.)
	
	::SetResponse(EncodeUTF8(cReturn))
Return .T.

/*/{Protheus.doc} WriteCalculation
//TODO Monta o Json da cálculo de frete realizado.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return oResponse, ${Objeto Json da cálculo de frete}
@param aRetFrete, array, Array com a cálculo de frete calculado
@type function
/*/
Static Function WriteCalculation(aRetFrete, nTpOper)
	Local oResponse	:= JsonObject():New()
	Local nCont		:= 0
	
	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())
	
	oResponse["content"][1]["Items"][1]["Status"]	:= "ok"
	if nTpOper = 1 
		oResponse["content"][1]["Items"][1]["Message"]	:= "DocumentBurdenCancelations: Processamento de consulta da viabilidade do cancelamento executada com sucesso. Verifique o Status de cada documento solicitado."
	Else
		oResponse["content"][1]["Items"][1]["Message"]	:= "DocumentBurdenCancelations: Processamento de cancelamento de documentos executada com sucesso. Verifique o Status de cada documento solicitado."
	EndIf

	oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"] := {}

	for nCont:= 1 to Len(aRetFrete)

		Aadd(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"], JsonObject():New())
		oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"] := {}
		
		oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Status"] 		:= aRetFrete[nCont][1]
		oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Message"] 		:= aRetFrete[nCont][2]
		
		Aadd( oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["id"] := "TypeOfDocument"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["Description"] := "Tipo do Documento de Carga/Nota Fiscal"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["value"] := aRetFrete[nCont][3][1]
	
		Aadd( oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["id"] := "IssuerCode"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["Description"] := "Emitente do Documento de Carga/Nota Fiscal"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["value"] := aRetFrete[nCont][3][2]
	
		Aadd( oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["id"] := "InvoiceSerie"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["Description"] := "Série do Documento de Carga/Nota Fiscal"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["value"] := aRetFrete[nCont][3][3]
	
		Aadd( oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["id"] := "InvoiceNumber"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["Description"] := "Número do Documento de Carga/Nota Fiscal"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["value"] := aRetFrete[nCont][3][4]

		Aadd( oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["id"] := "ElectronicAccessKey"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["Description"] := "Chave de Acesso Eletrônica"
		aTail(oResponse["content"][1]["Items"][1]["DocumentBurdenCancelation"][nCont]["Items"])["value"] := aRetFrete[nCont][3][5]

	next

Return oResponse

/*/{Protheus.doc} ReadContent
//TODO Realiza a leitura do conteudo enviado no método POST.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oContent, object, descrição
@type function
/*/
Static Function ReadContent(oContent)
	Local aDocBurden
	Local nContent			:= 0
	Local aRetDC			:= {} // Agrupadores de frete
	Local aAux				:= {}
	Local lRet				:= .T.
	Local cMsgErro			:= ""
	Local cAuxRet
	Local aDocCarga
	Local lDCFind			:= .F.
	Local oTypeOfDocument	:= GFEITypeOfDocument():New()
	Local aDadosFil

	/* DEFINIÇÃO DE TAMANHO DE CAMPOS*/
	Local nGW1CDTPDC	:= TamSX3("GW1_CDTPDC")[1]
	Local nGW1EMISDC	:= TamSX3("GW1_EMISDC")[1]
	Local nGW1SERDC		:= TamSX3("GW1_SERDC")[1]
	Local nGW1NRDC		:= TamSX3("GW1_NRDC")[1]
	
	For nContent:= 1 to Len(oContent["content"][1]["Items"][1]["DocumentBurden"])
		aDocBurden 			:= oContent["content"][1]["Items"][1]["DocumentBurden"][nContent]["Items"]
		
		aAux		:= {}
		lRet		:= .T.
		lDCFind		:= .F.
		aDocCarga	:= {GFEGETVALUE(aDocBurden,"TypeOfDocument",nGW1CDTPDC),;
						GFEGETVALUE(aDocBurden,"IssuerCode"    ,nGW1EMISDC),;
						GFEGETVALUE(aDocBurden,"InvoiceSerie"  ,nGW1SERDC),;
						GFEGETVALUE(aDocBurden,"InvoiceNumber" ,nGW1NRDC),;
						GFEGETVALUE(aDocBurden,"ElectronicAccessKey" ,44)}
		
		cAuxRet := aDocCarga[5] // Chave de Acesso eletrônica
		If !Empty(Alltrim(cAuxRet))
			GW1->(dbSetOrder(12))
			If !GW1->(dbSeek(cAuxRet))
				lRet := .F.
				cMsgErro := 'Documento de Carga informado não é válido, Documento de Carga não encontrado na base de dados. ('+xFilial("GW1") + aDocCarga[1] + aDocCarga[2] + aDocCarga[3] + aDocCarga[4]+') Chave: (' + aDocCarga[5] + ')'
				aAux := {lRet, cMsgErro, aDocCarga}
			Else
				aDocCarga	:= {GW1->GW1_CDTPDC,;
								GW1->GW1_EMISDC,;
								GW1->GW1_SERDC,;
								GW1->GW1_NRDC,;
								cAuxRet}
				lDCFind:= .T.
			EndIf
		EndIf
		
		if !lDCFind
			If lRet
				cAuxRet := aDocCarga[1]
				
				oTypeOfDocument:ClearData()
				oTypeOfDocument:setTypeOfDocument(cAuxRet)
				oTypeOfDocument:setNoTags(.F.)
				oTypeOfDocument:Localizar()
				if !oTypeOfDocument:getStatus()
					lRet 		:= .F.
					cMsgErro	:= 'Campo TypeOfDocument ' + oTypeOfDocument:getMensagem()
					aAux		:= {lRet, cMsgErro, aDocCarga}
				Else
					aDocCarga[1] := oTypeOfDocument:getTypeOfDocument()
				EndIf
			EndIf
	
			If lRet
				cAuxRet := aDocCarga[2]
				If Empty(cAuxRet)
					
					aDadosFil	:= FWArrFilAtu()
					
					GU3->(dbSetOrder(11))
					if GU3->(dbSeek(xFilial("GU3") + PADR(aDadosFil[18],TamSX3("GU3_IDFED")[1])))
						IF GU3->GU3_SIT == "2"
							lRet := .F.
							cMsgErro := 'Campo IssuerCode. Busca do Emissor pelo CNPJ (' + aDadosFil[18] + ') da Filial (' + aDadosFil[2] + '/' + aDadosFil[7] + ') localizada no Cadastro de Emitentes porém o mesmo encontra-se Inativo. Favor revisar o cadastro de emitentes.'
							aAux := {lRet, cMsgErro, aDocCarga}
						Else
							cAuxRet			:= GU3->GU3_CDEMIT
							aDocCarga[2]	:= cAuxRet
						EndIf
					Else
						lRet := .F.
						cMsgErro := 'Campo IssuerCode. Busca do Emissor pelo CNPJ (' + aDadosFil[18] + ') da Filial (' + aDadosFil[2] + '/' + aDadosFil[7] + ') não localizada no Cadastro de Emitentes. Incluir um Emitente (GFEA015) com o CNPJ da Filial para encontrar o Documento de Carga.'
						aAux := {lRet, cMsgErro, aDocCarga}
					EndIf
				Else
					GU3->(dbSetOrder(1))
					If !GU3->(dbSeek(xFilial("GU3") + cAuxRet))
						lRet := .F.
						cMsgErro := 'Campo IssuerCode. Código do Emissor ('+cAuxRet+') não encontrado na base de dados, verifique o cadastro de Emitentes se este código existe. '
						aAux := {lRet, cMsgErro, aDocCarga}
					Endif
				EndIf
			EndIf
			
			If lRet
				cAuxRet := aDocCarga[4]
				If Empty(cAuxRet)
					lRet := .F.
					cMsgErro := 'Campo InvoiceNumber. Número do Documento de Carga não informado. Informe o número do documento de carga. '
					aAux := {lRet, cMsgErro, aDocCarga}
				EndIf
			EndIf
	
			If lRet
				GW1->(dbSetOrder(1))
				If !GW1->(dbSeek(xFilial("GW1") + aDocCarga[1] + aDocCarga[2] + aDocCarga[3] + aDocCarga[4]))
					lRet := .F.
					cMsgErro := 'Documento de Carga informado não é válido, Documento de Carga não encontrado na base de dados. ('+xFilial("GW1") + aDocCarga[1] + aDocCarga[2] + aDocCarga[3] + aDocCarga[4]+') Chave: (' + aDocCarga[5] + ')'
					aAux := {lRet, cMsgErro, aDocCarga}
				Else
					aDocCarga[5] := PADR(AllTrim(GW1->GW1_DANFE),44)
				EndIf
			EndIf
		EndIf

		If lRet
			lRet := .T.
			cMsgErro := ''
			aAux := {lRet, cMsgErro, aDocCarga}
		EndIf

		AADD(aRetDC, aAux)
	next
	oTypeOfDocument:Destroy(oTypeOfDocument)
	
Return aRetDC


/*/{Protheus.doc} GFEGETVALUE
//TODO Descrição Retorna o valor do campo de um objeto Json.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return Conteudo do objeto 
@param jValues, TJson , Ojeto Json
@param cCampo, characters, Nome do conteudo a ser encontrado
@type function
/*/
Static Function GFEGETVALUE(jValues,cCampo,nTamSX3,cDefault)
	Local nCampos := 0
	Local cRet := ""
	Default nTamSX3 := 0
	for nCampos:= 1 to Len(jValues)
		if Upper(jValues[nCampos]["id"]) == Upper(cCampo)
			cRet	:= jValues[nCampos]["value"]
			Loop
		EndIf
	next
	if Empty(cRet) .AND. !Empty(cValToChar(cDefault))
		cRet := cDefault
	EndIf
	if nTamSX3 > 0
		cRet := PadR(cRet,nTamSX3)
	EndIf
Return cRet


/*/{Protheus.doc} ValidContent
//TODO Realiza as validaçoes dos arquivo.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cContent, characters, descrição
@type function
/*/
Static Function ValidContent(cContent)
	Local oResponse   := JsonObject():New()
	
	if Empty(cContent)
		oResponse["content"] := {}
		Aadd(oResponse["content"], JsonObject():New())
	
		oResponse["content"][1]["Items"] := {}
		Aadd(oResponse["content"][1]["Items"], JsonObject():New())
		oResponse["content"][1]["Items"][1]["Status"]	:= "error" 
		oResponse["content"][1]["Items"][1]["Message"]	:= "DOCUMENTBURDENCANCELATIONs: Não foi possível executar o cancelamento do Documento de Carga/Nota Fiscal no módulo SIGAGFE - Gestão de Frete Embarcador."
		oResponse["content"][1]["Items"][1]["Error"]	:= "DOCUMENTBURDENCANCELATIONs: Dados do documento de carga não encontrado no corpo da requisição. No método POST deve ser enviado no corpo da mensagem os dados para realizar o cancelamento do documento de Carga. Execute o método GET para pegar JSON de exemplo."
		
		Return {.F., oResponse}
	EndIf
Return {.T.,nil}