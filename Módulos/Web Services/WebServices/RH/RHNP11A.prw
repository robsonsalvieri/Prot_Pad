#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP11.CH"

/*/{Protheus.doc} GetTaeToken
Instacia a classe FwRest e realiza o login no totvs assinatura eletrônica
@type  Function
@author Marcelo Silveira
@since 15/02/2023
@param cErr, String, Erros ocorridos durante o processamento do dados - deve ser passado por referência
@return aRet, Array, [1] Token de acesso ao Tae, e [2] usuário do Tae
/*/
Function GetTaeToken(cErr)

    Local oRest         := Nil
    Local oToken        := Nil
    Local oData         := Nil
    Local aHeader       := {}
	Local aRet			:= {"",""}
    Local cRet          := ""
	Local cMsgErr		:= ""
    Local cJson         := ""
	Local lURLOk		:= .T.
	Local cUser     	:= AllTrim(GetMv('MV_RHTAEUS', , ""))
	Local cPassword 	:= AllTrim(GetMv('MV_RHTAEPW', , ""))
	Local cRestURL 		:= AllTrim(SuperGetMv('MV_SIGNURL',,""))
    Local cResource     := "identityintegration/v2/auth/login"
	Local lContinua     := .T.

	DEFAULT cErr		:= ""

	lContinua := !Empty(cRestURL) .And. !Empty(cUser) .And. !Empty(cPassword)

	If lContinua
		
		AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
		AAdd(aHeader, "Accept: application/json")

		cUser 				:= rc4crypt( cUser, "123456789", .F., .T.)
		cPassword			:= rc4crypt( cPassword, "123456789", .F., .T.)
		lURLOk				:= SubStr(cRestURL, Len(cRestURL)) == "/"
		cResource 			:= If( lURLOk, cResource, "/" + cResource )

		oData				:= JsonObject():New()
		oData["UserName"]	:= cUser
		oData["Password"]	:= cPassword
		cJson				:= oData:toJson()

		oRest:= FwRest():New(cRestURL)
		oRest:SetPath(cResource)
		oRest:SetPostParams(cJson)
		oRest:Post(aHeader)

		lContinua := !Empty(cRet := oRest:GetResult())

		//Avalia retorno da API de Token do TAE
		If lContinua
			oToken := JsonObject():New()
			oToken:FromJson(cRet)

            If oToken:hasProperty("succeeded") .And. oToken["succeeded"]
                aRet[1] := oToken["data"]['token']
				aRet[2] := cUser
            Else
				cMsgErr := STR0010 + Space(1) //"Não foi possível efetuar autenticação no TAE!"
                cMsgErr += If( oToken:hasProperty("description"), DecodeUTF8(oToken["description"]), "" ) //Erro retornado pela API do TAE
				cErr 	:= EncodeUTF8(cMsgErr)
            EndIf
			FreeObj(oToken)
		EndIf

		FreeObj(oRest)
		FreeObj(oData)
	EndIf

	//Caso ocorra algum erro com o parâmetro ou bloqueio do endereço do TAE.
	cErr := If(lContinua, cErr, EncodeUTF8(STR0016)) //"Problemas de comunicação com o TAE."

Return(aRet)

/*/{Protheus.doc} GetDashTae (Versão Padrão)
Obtem os dados do dashboard com o resumo de informações do usuario
@type  Static Function
@author Marcelo Silveira
@since 15/02/2023
@param oData, Objeto, Json com os dados do dashboard do usuario - deve ser passado por referência
@param cEmail, String, e-mail do destinatario dos documentos atribuidos no Tae
@param cTaeToken, String, Token de acesso ao Tae
@return Nil
/*/
Function GetDashTae(oData, cEmail, cTaeToken)

    Local oRest         := Nil
	Local oReturn		:= Nil
    Local oRequest     	:= Nil

    Local cJson         := ""
	Local nX 			:= 0
	Local nPending		:= 0
	Local nFinished		:= 0
	Local nRejected		:= 0
    Local aHeader       := {}
	Local lURLOk		:= .T.
	Local cRestURL 		:= AllTrim(SuperGetMv('MV_SIGNURL',,""))
    Local cResource     := "documents/v1/publicacoes/pesquisas/destinatario?PaginaAtual=1&TamanhoPagina=1000"

    DEFAULT oData       := JsonObject():New()
    DEFAULT cEmail      := ""

	lURLOk				:= SubStr(cRestURL, Len(cRestURL)) == "/"
	cResource 			:= If( lURLOk, cResource, "/" + cResource )
	
	AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "Authorization:" + 'Bearer ' + cTaeToken)

	oRequest 						:= JsonObject():New()
	oRequest["destinatarioEmail"]	:= cEmail	
	cJson := oRequest:toJson()

	oRest := FwRest():New(cRestURL)
	oRest:SetPath(cResource)
	oRest:SetPostParams(cJson)
	oRest:Post(aHeader)

	//Avalia retorno da API de Token
	If !Empty( cRet := oRest:GetResult() )
		oReturn := JsonObject():New()
		oReturn:FromJson(cRet)

		If oReturn:hasProperty("success") .And. oReturn["success"]
			If oReturn:hasProperty("data") 

				For nX := 1 To Len( oReturn["data"]["registro"] )
					//Desconsidera os registros integrados via ERP (Chave publica zerada)
					If !(oReturn["data"]["registro"][nx]['destinatario']["publicKey"] == "00000000-0000-0000-0000-000000000000")
						nPending 	+= If( oReturn["data"]["registro"][nx]['status'] == 0, 1, 0 ) //Pendente
						nFinished	+= If( oReturn["data"]["registro"][nx]['status'] == 2, 1, 0 ) //Finalizado	
						nRejected	+= If( oReturn["data"]["registro"][nx]['status'] == 4, 1, 0 ) //Rejeitado
					EndIf
				Next nX

				oData["pending"]				:= nPending
				oData["finished"]				:= nFinished
				oData["rejected"]				:= nRejected
				oData["pendingWithRecipient"]	:= nPending

			EndIf
		EndIf		

		FreeObj(oReturn)
	EndIf

	FreeObj(oRest)
	FreeObj(oRequest)

Return()


/*/{Protheus.doc} GetDocsTae
Obtem os dados do dashboard com o resumo de informações do usuario
@type  Function
@author Marcelo Silveira
@since 15/02/2023
@param oData, Objeto, Json com os dados do dashboard do usuario - deve ser passado por referência
@param cEmail, String, e-mail do destinatario dos documentos atribuidos no Tae
@param cTaeToken, String, Token de acesso ao Tae
@param cBody, String, body da requisição do Tae
@param aQryParam, Array, queryparams da requisição do Tae
@param cErr, String, Erros ocorridos durante o processamento do dados - deve ser passado por referência
@return Nil
/*/
Function GetDocsTae(oData, cEmail, cTaeToken, cBody, aQryParam, cErr)

    Local oRest         := Nil
	Local oReturn		:= Nil
    Local oRequest     	:= Nil
	Local oItem      	:= Nil
	Local oBody			:= JsonObject():New()

	Local uStatus		:= Nil
    Local cRet          := ""
    Local cJson         := ""
	Local cStatus		:= ""
	Local cPage			:= "1"
	Local cPageSize		:= "10"	
	Local nX 			:= 0
	Local nTotal		:= 0
	Local nRegCount		:= 0
	Local nRegIniCount	:= 0 
	Local nRegFimCount	:= 0	
    Local aHeader       := {}
	Local aItems		:= {}
	Local lURLOk		:= .T.
	Local lNextPage		:= .F.
	Local cRestURL 		:= AllTrim(SuperGetMv('MV_SIGNURL',,""))
    Local cResource     := "documents/v1/publicacoes/pesquisas/destinatario"

    DEFAULT oData       := JsonObject():New()
    DEFAULT cEmail      := ""
	DEFAULT cErr		:= ""

	lURLOk				:= SubStr(cRestURL, Len(cRestURL)) == "/"
	cResource 			:= If( lURLOk, cResource, "/" + cResource )
	
	AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "Authorization:" + 'Bearer ' + cTaeToken)

	oBody:FromJson(cBody)
	cStatus := If( oBody:hasProperty("status"), oBody["status"], "" ) //Status do documento

	For nX := 1 To Len(aQryParam)
		DO Case
			CASE UPPER(aQryParam[nX,1]) $ "PAGE"
				cPage := UPPER(AllTrim(aQryParam[nX,2]))
			CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
				cPageSize := UPPER(AllTrim(aQryParam[nX,2]))
		ENDCASE
	Next nX
	
	cResource += '?PaginaAtual=' + cPage + '&TamanhoPagina=' + cPageSize

	If !Empty(cStatus)
		Do Case
 			CASE cStatus == "pending" //Pendente
				uStatus := 0
			CASE cStatus == "signed" //Finalizado
				uStatus := 2
			CASE cStatus == "rejected" //Rejeitado
				uStatus := 4				
		END CASE
	EndIf

	oRequest 						:= JsonObject():New()
	oRequest["status"]				:= {uStatus}
	oRequest["destinatarioEmail"]	:= cEmail	
	cJson := oRequest:toJson()

	oRest := FwRest():New(cRestURL)
	oRest:SetPath(cResource)
	oRest:SetPostParams(cJson)
	oRest:Post(aHeader)

	//Avalia retorno da API de Token
	If !Empty( cRet := oRest:GetResult() )
		oReturn := JsonObject():New()
		oReturn:FromJson(cRet)

		If oReturn:hasProperty("success") .And. oReturn["success"]
			If oReturn:hasProperty("data") 

				//controle de paginacao
				If !Empty(cPage) .And. !Empty(cPageSize)
					If cPage == "1" .Or. cPage == ""
						nRegIniCount := 1 
						nRegFimCount := If( Empty( Val(cPageSize) ), 10, Val(cPageSize) )
					Else
						nRegIniCount := ( Val(cPageSize) * ( Val(cPage) - 1 ) ) + 1
						nRegFimCount := ( nRegIniCount + Val(cPageSize) ) - 1
					EndIf
					lCount := .T.
				EndIf

				For nX := 1 To Len( oReturn["data"]["registro"] )
					//Desconsidera os registros integrados via ERP (Chave publica zerada)
					If !(oReturn["data"]["registro"][nx]['destinatario']["publicKey"] == "00000000-0000-0000-0000-000000000000")
						nRegCount ++
						oItem						:= JsonObject():New()
						oItem["idDocument"] 		:= oReturn["data"]["registro"][nx]['id']
						oItem["name"] 				:= oReturn["data"]["registro"][nx]['nomeArquivo']
						oItem["createDate"] 		:= oReturn["data"]["registro"][nx]['dataCriacao']
						oItem["expirationDate"]		:= oReturn["data"]["registro"][nx]['dataExpiracao']
						oItem["sender"] 			:= oReturn["data"]["registro"][nx]['autor']["email"]
						oItem["publicKey"] 			:= oReturn["data"]["registro"][nx]['destinatario']["publicKey"]
						oItem["lastModification"]	:= oReturn["data"]["registro"][nx]['dataUltimaAlteracao']
						aAdd( aItems, oItem )
					EndIf
				Next nX
				nTotal 		:= oReturn["data"]["total"]
				lNextPage 	:= (nRegIniCount + nRegCount - 1) < nTotal
			EndIf
			FreeObj(oItem)
		EndIf
		
		oData["hasNext"] 	:= lNextPage
		oData["items"] 		:= aItems

		FreeObj(oReturn)
	EndIf

	FreeObj(oRest)
	FreeObj(oRequest)

Return()

/*/{Protheus.doc} SendTaeCode
Envia para o e-mail do destinatario o codigo de acesso ao documento do Tae
@type  Function
@author Marcelo Silveira
@since 27/02/2023
@param oData, Objeto, Json com os dados do dashboard do usuario - deve ser passado por referência
@param cBody, String, body da requisição do Tae
@param aQryParam, Array, queryparams da requisição do Tae
@return Nil
/*/
Function SendTaeCode(oData, cBody, aQryParam)

    Local oRest         := Nil
	Local oReturn		:= Nil
	Local oBody			:= JsonObject():New()
	Local oRequest		:= JsonObject():New()

    Local cRet          := ""
    Local cJson         := ""
	Local cPublicKey	:= ""
	Local nX 			:= 0
    Local aHeader       := {}
	Local lURLOk		:= .T.
	Local cRestURL 		:= AllTrim(SuperGetMv('MV_SIGNURL',,""))
    Local cResource     := "identityintegration/v1/verification-codes/send"

    DEFAULT oData       := JsonObject():New()
    DEFAULT cBody		:= ""
	DEFAULT aQryParam	:= {}

	lURLOk				:= SubStr(cRestURL, Len(cRestURL)) == "/"
	cResource 			:= If( lURLOk, cResource, "/" + cResource )
	
	//Extrai o body enviado pelo Front-End
	oBody:FromJson(cBody)
	cPublicKey := If( oBody:hasProperty("publicKey"), oBody["publicKey"], "" ) //Chave publica do documento

	If !Empty(cRestURL) .And. !Empty(cPublicKey)

		For nX := 1 To Len(aQryParam)
			If UPPER(aQryParam[nX,1]) $ "RESEND" .And. aQryParam[nX,2] == "true"
				cResource += "?resend=true"
			EndIf
		Next nX

		AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
		AAdd(aHeader, "Accept: application/json")
		AAdd(aHeader, "x-application-id: aabaf372-92bd-4ac0-879a-7b26c3247bba") //Chave padrão do TAE para o Meu RH

		oRequest["publicKey"]	:= cPublicKey
		cJson					:= oRequest:toJson()

		//Realiza a requisicao
		oRest := FwRest():New(cRestURL)
		oRest:SetPath(cResource)
		oRest:SetPostParams(cJson)
		oRest:Post(aHeader)

		//Avalia o retorno da requisicao
		If !Empty( cRet := oRest:GetResult() )
			oReturn := JsonObject():New()
			oReturn:FromJson(cRet)

			If oReturn:hasProperty("success") .And. oReturn["success"]
				oData["success"]	:= oReturn["success"]
				oData["email"] 		:= oReturn["data"]["jsonData"]["email"]
				oData["documentId"]	:= oReturn["data"]["jsonData"]["idDocumento"]
			EndIf
			
			FreeObj(oReturn)
		EndIf

		FreeObj(oRest)
	EndIf

	FreeObj(oBody)

Return()

/*/{Protheus.doc} CheckCodeTae
Valida o código recebido por e-mail e emite o token para visualizar e assinar o documento
@type  Function
@author Marcelo Silveira
@since 27/02/2023
@param oData, Objeto, Json com os dados do dashboard do usuario - deve ser passado por referência
@param cBody, String, body da requisição do Tae
@param aQryParam, Array, queryparams da requisição do Tae
@param cErr, String, Erros ocorridos durante o processamento do dados - deve ser passado por referência
@return Nil
/*/
Function CheckCodeTae(oData, cBody, aQryParam, cErr)

    Local oRest         := Nil
	Local oReturn		:= Nil
	Local oBody			:= JsonObject():New()
	Local oRequest		:= JsonObject():New()

    Local cRet          := ""
    Local cJson         := ""
    Local cMsgErr       := ""
    Local cCode         := ""
	Local cPublicKey	:= ""
	Local nX 			:= 0
    Local aHeader       := {}
	Local lURLOk		:= .T.
	Local cRestURL 		:= AllTrim(SuperGetMv('MV_SIGNURL',,""))
    Local cResource     := "identityintegration/v1/verification-codes/validate"

    DEFAULT oData       := JsonObject():New()
    DEFAULT cBody		:= ""
	DEFAULT aQryParam	:= {}
	DEFAULT cErr		:= ""

	lURLOk				:= SubStr(cRestURL, Len(cRestURL)) == "/"
	cResource 			:= If( lURLOk, cResource, "/" + cResource )
	
	//Extrai o body enviado pelo Front-End
	oBody:FromJson(cBody)
	cCode := If( oBody:hasProperty("code"), oBody["code"], "" ) //Codigo para assinatura do documento
	cPublicKey := If( oBody:hasProperty("publicKey"), oBody["publicKey"], "" ) //Chave publica do documento

	If !Empty(cRestURL) .And. !Empty(cCode) .And. !Empty(cPublicKey)

		AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
		AAdd(aHeader, "Accept: application/json")
		AAdd(aHeader, "x-application-id: aabaf372-92bd-4ac0-879a-7b26c3247bba") //Chave padrão do TAE para o Meu RH

		oRequest["code"]		:= cCode
		oRequest["publicKey"]	:= cPublicKey
		cJson					:= oRequest:toJson()

		//Realiza a requisicao
		oRest := FwRest():New(cRestURL)
		oRest:SetPath(cResource)
		oRest:SetPostParams(cJson)
		oRest:Post(aHeader)

		//Avalia o retorno da requisicao
		If !Empty( cRet := oRest:GetResult() )
			oReturn := JsonObject():New()
			oReturn:FromJson(cRet)

			If oReturn:hasProperty("success") .And. oReturn["success"]
				oData["token"] := oReturn["data"]["token"]
			Else
				If( oReturn:hasProperty("errors") )
					For nX := 1 To Len( oReturn["errors"] )
						cMsgErr += DecodeUTF8(oReturn["errors"][nX]) + " "
					Next nX
					cErr := EncodeUTF8(cMsgErr)
				EndIf
			EndIf
			
			FreeObj(oReturn)
		EndIf

		FreeObj(oRest)
		FreeObj(oRequest)
	EndIf

	FreeObj(oBody)

Return()

/*/{Protheus.doc} SetError
Gera o json padrão do tipo Message error do Meu RH
@type  Function
@author Marcelo Silveira
@since 15/02/2023
@param cMsgErr, String, mensagem do erro
@param cType, String, tipo de erro (default 'error')
@param cCode, String, codigo de erro (default '400')
@return cJson, Json, Json contendo o json com os erros
/*/
Function SetError(cMsgErr, cType, cCode)

	Local aMessage	:= {}
	Local cJson		:= ""
	Local oItem		:= JsonObject():New()
	Local oMsg		:= JsonObject():New()

	DEFAULT cType	:= "error"
	DEFAULT cCode	:= "400"
	
	oMsg["type"]	:= cType
	oMsg["code"]	:= cCode
	oMsg["detail"]	:= cMsgErr
	Aadd(aMessage, oMsg)

	oItem["data"]		:= ''
	oItem["messages"]	:= aMessage
	oItem["length"]		:= 1 

	cJson := oItem:ToJson()

	FreeObj(oMsg)
	FreeObj(oItem)

Return( cJson )

/*/{Protheus.doc} GetDocInfoTae
Obtem os detalhes de um documento do TAE.
@type  Static Function
@author Alberto Ortiz
@since 15/03/2023
@return Nil
/*
*/
Function GetDocInfoTae(oData, cEmail, cTaeToken, nDocumentId, cRestFault)

    Local oRest         := Nil
	Local oResponse		:= Nil
	Local oFile         := Nil
	Local oRestGetPDF   := Nil
	Local aPendentes    := {}

    Local cRet          := ""
	Local cURLPDF       := "https://storage.googleapis.com"
	Local cPath         := ""
    Local aHeader       := {}
	Local lURLOk		:= .T.
	Local cRestURL 		:= AllTrim(SuperGetMv('MV_SIGNURL', ,""))
    Local cResource     := ""
	Local cNomeArquivo  := ""
	Local cTypeFile     := ""
	Local cCreateDate   := ""
	Local cDocument     := ""
	Local cName         := ""

	Local cDocumentType := "" // Default - Não informado
	Local nX            := 1
	
    DEFAULT oData       := JsonObject():New()
    DEFAULT cEmail      := ""
	DEFAULT cTaeToken   := ""
	DEFAULT nDocumentId := 0
	DEFAULT cRestFault  := ""

	//Constroi a URL da API com o id do documento.
	cResource     := "documents/v1/publicacoes/sem-cadastro/" + cValToChar(nDocumentId)

	//Verifica se a 'MV_SIGNURL' está com barra no final.
	lURLOk	  := SubStr(cRestURL, Len(cRestURL)) == "/"
	cResource := If( lURLOk, cResource, "/" + cResource )

	//Header da primeira requisição.
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "Authorization:" + 'Bearer ' + cTaeToken)

	//Realiza a requisicao para obter os detalhes da API do TAE
 	oRest:= FwRest():New(cRestURL)
	oRest:SetPath(cResource)
	oRest:Get(aHeader)

	//Avalia retorno da API
	If !Empty(cRet := oRest:GetResult())
		//Transforma o response em objeto.
		oResponse := JsonObject():New()
		oResponse:FromJson(cRet)

		//Busca dados para o download do arquivo do TAE via URL.
		aHeader     := {}
		cPath       := Substr(oResponse["data"]["signedURL"], Len(cURLPDF)+1)
        oRestGetPDF := FwRest():New(cURLPDF)
        oRestGetPDF:SetPath(cPath)

		//Só continua se o download do arquivo ocorreu com sucesso.
		If (oRestGetPDF:Get(aHeader))
			//PDF baixado na URL em base 64.
			cContent := Encode64(oRestGetPDF:GetResult())
			//Busca o nome do arquivo.
			cNomeArquivo := oResponse["data"]["nomeArquivo"]
			//Busca o tipo do arquivo no nome do arquivo.
			cTypeFile    := RIGHT(oResponse["data"]["nomeArquivo"], LEN(oResponse["data"]["nomeArquivo"]) - AT(".",oResponse["data"]["nomeArquivo"]) )
			//Busca a data de criação do arquivo.
			cCreateDate  := oResponse["data"]["dataCriacao"]
			//Busca o nome do arquivo.
			cName        := oResponse["data"]["nomeArquivo"]
			//Busca o document e o documentType nos pendentes.
			aPendentes := oResponse["data"]["pendentes"]
			For nX := 1 to LEN(aPendentes)
				If aPendentes[nX]["email"] == cEmail
					cDocumentType := fCTaeDocTypeDesc(aPendentes[nX]["participanteSemCadastro"]["tipoIdentificacao"])
					cDocument     := aPendentes[nX]["participanteSemCadastro"]["identificacao"]
				EndIf
			Next
			//Dados do arquivo
			oFile := JsonObject():New()
			oFile["content"] := cContent
			oFile["name"]    := cNomeArquivo
			oFile["type"]    := cTypeFile

			//Dados do documento
			oData["createDate"]   := cCreateDate
			oData["document"]     := cDocument
			oData["documentType"] := cDocumentType
			oData["name"]         := cName
			oData["file"]         := oFile

			FreeObj(oFile)
		EndIf
		
		FreeObj(oResponse)
		FreeObj(oRestGetPDF)	
	EndIf

	cRestFault := If(Empty(cRet), EncodeUTF8(STR0014), cRestFault) //Documento não localizado!

	FreeObj(oRest)

Return(Nil)


/*/{Protheus.doc} SignDocTae
Realizar a assinatura de um documento do TAE.
@type  Static Function
@author Alberto Ortiz
@since 15/03/2023
@return Nil
/*
*/
Function SignDocTae(oData, cRestFault, cTaeToken, nDocumentId, cEmail, cDocument, cSignType, cDocumentType)

    Local oRest         := Nil
	Local oReturn		:= Nil
    Local oBody        	:= JsonObject():New()

	Local aHeader       := {}

	Local cRet          := ""
	Local lURLOk		:= .T.
	Local cRestURL 		:= AllTrim(SuperGetMv('MV_SIGNURL', ,""))
    Local cResource     := "signintegration/v2/assinaturas/sem-cadastro"
	
    DEFAULT oData         := JsonObject():New()
    DEFAULT cEmail        := ""
	DEFAULT cTaeToken     := ""
	DEFAULT cDocument     := ""
	DEFAULT cSignType     := ""
	DEFAULT cDocumentType := ""
	DEFAULT cRestFault    := ""
	DEFAULT nDocumentId   := 0

	//Verifica se a 'MV_SIGNURL' está com barra no final.
	lURLOk	  := SubStr(cRestURL, Len(cRestURL)) == "/"
	cResource := If( lURLOk, cResource, "/" + cResource )

	//Header da requisição.
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "Authorization:" + 'Bearer ' + cTaeToken)
	AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	AAdd(aHeader, "x-application-id: aabaf372-92bd-4ac0-879a-7b26c3247bba") //Chave padrão do TAE para o Meu RH

	//Body da requisição.
	oBody["tipoDeAssinatura"]  := fNTaeAssignType(cSignType)
	oBody["idDocumento"]       := nDocumentId
	oBody["tipoIdentificacao"] := fNTaeDocType(cDocumentType)
	oBody["identificacao"]     := cDocument
	cJson                      := oBody:toJson()

	//Realiza a requisicao para realizar a assinatura de um documento do TAE.
 	oRest := FwRest():New(cRestURL)
	oRest:SetPath(cResource)
	oRest:SetPostParams(cJson)
	oRest:Post(aHeader)

	//Avalia retorno da API
	If !Empty(cRet := oRest:GetResult())
		oReturn := JsonObject():New()
		oReturn:FromJson(cRet)

		oData["message"] := oReturn["message"]
		oData["success"] := oReturn["success"]

		//Caso o TAE retorne com algum problema, devolve para o usuário.
		cRestFault := If(!oData["success"], EncodeUTF8(STR0015), cRestFault) //Não foi possível realizar a assinatura, problemas na comunicação com o serviço de assinatura eletrônica.

		FreeObj(oReturn)
	EndIf

	cRestFault := If(Empty(cRet), EncodeUTF8(STR0014), cRestFault) //Documento não localizado!

	FreeObj(oRest)
	FreeObj(oBody)

Return(Nil)

/*/{Protheus.doc} fNTaeAssignType
Faz o de-para do tipoDeAssinatura que vem do Meu RH para o padrão do TAE.
@type  Static Function
@author Alberto Ortiz
@since 15/03/2023
@return nAssigType
/*
*/
Function fNTaeAssignType(cAssignType)

	Local oAssigType := JsonObject():New()
	Local nAssigType := 0

	DEFAULT cAssignType := ""
	
	oAssigType['eletronic'] := 0
	oAssigType['digital']   := 1
	oAssigType['validator'] := 2
	oAssigType['witness']   := 4

	If cAssignType $ 'eletronic|digital|validator|witness'
		nAssigType := oAssigType[cAssignType]
	EndIf

Return nAssigType

/*/{Protheus.doc} fNTaeDocType
Faz o de-para do tipoIdentificacao que vem do Meu RH para o padrão do TAE.
@type  Static Function
@author Alberto Ortiz
@since 15/03/2023
@return nDocType
/*
*/
Function fNTaeDocType(cDocType)

	Local oDocType := JsonObject():New()
	Local nDocType := 0

	DEFAULT cDocType := ""
	
	oDocType['national']      := 1
	oDocType['international'] := 2
	oDocType['uninformed']    := 3

	If cDocType $ 'national|international|uninformed'
		nDocType := oDocType[cDocType]
	EndIf

Return nDocType


/*/{Protheus.doc} fCTaeDocTypeDesc
Faz o de-para do tipoIdentificacao que vem do TAE para o padrão do Meu RH.
@type  Static Function
@author Alberto Ortiz
@since 15/03/2023
@return cDocType
/*
*/
Function fCTaeDocTypeDesc(nDocType)

	Local aDocType := {'national', 'international','uninformed'}
	Local cDocType := 'national' //Padrão para o CPF

	DEFAULT nDocType := 1

	If nDocType == 1 .Or. nDocType == 2 .Or. nDocType == 3
		cDocType := aDocType[nDocType]
	EndIf

Return cDocType
