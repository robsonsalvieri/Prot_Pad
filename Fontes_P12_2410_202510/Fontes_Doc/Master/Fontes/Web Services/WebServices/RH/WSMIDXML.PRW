#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "WSMIDXML.CH"

#DEFINE ERRORCODE_DEF	400
#DEFINE ERRORSRV_DEF	500
#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )

Private oError
Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )


/*/{Protheus.doc} WSMETHOD GET
Classe de edição de XML de eventos do eSocial, utilizado no Monitor THF
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
WSRESTFUL GPEEsocialXMLMessage DESCRIPTION oEmToAnsi(STR0001) FORMAT APPLICATION_JSON // STR0001: "Serviço do Monitor de Transmissão do eSocial"
	WSDATA companyId 	AS STRING
	WSDATA id 			AS STRING
	WSDATA xmlMessage	AS STRING
	WSDATA user 		AS STRING OPTIONAL

	/*	STR0002: "Método para consultar o XML dos eventos do Esocial no Monitor THF"
		STR0003: "api/rh/esocial/v1/GPEEsocialXMLMessage/"
		STR0004: "v1"*/
	WSMETHOD GET DESCRIPTION oEmToAnsi(STR0002);	
	WSSYNTAX "api/rh/esocial/v1/GPEEsocialXMLMessage/"; 
	PATH "api/rh/esocial/v1/GPEEsocialXMLMessage/"; 
	TTALK "v1";	
	PRODUCES APPLICATION_JSON

	//	STR0005: "Método para editar o XML dos eventos do Esocial no Monitor THF"
	WSMETHOD POST DESCRIPTION oEmToAnsi(STR0005); 
	WSSYNTAX "api/rh/esocial/v1/GPEEsocialXMLMessage/"; 
	PATH "api/rh/esocial/v1/GPEEsocialXMLMessage/"; 
	TTALK "v1"; 
	PRODUCES APPLICATION_JSON
END WSRESTFUL


/*/{Protheus.doc} WSMETHOD GET
Método para consultar o XML dos eventos do Esocial no Monitor THF
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
WSMETHOD GET QUERYPARAM companyId, id WSSERVICE GPEEsocialXMLMessage
	Local oInput
	Local aDados 		:= {}
	Local cRet			:= ""
	Local cMessage		:= ""
	Local cMethod		:= "GET"
	Local lRet			:= .T.

	DEFAULT Self:companyId 	:= ""
	DEFAULT Self:id 		:= ""
	
	oInput 				:= JsonObject():New()
	oInput["companyId"] := Self:companyId
	oInput["id"] 		:= Self:id

	BEGIN SEQUENCE
		If Empty(cMessage := fPreValid(oInput, cMethod)) // Realiza pré-validações 
			fStartEnv(oInput) // Inicializa o Ambiente
			aDados 	:= fXMLCRUD(oInput, cMethod) // Pesquisa e grava o XML editado
		EndIf

		cRet := fReturn(cMethod, aDados, cMessage) // Montagem da estrutura de retorno da API
		::SetResponse(cRet)

	RECOVER
		lRet := .F.
		ErrorBlock( bErrorBlock ) // STR0006: "Ocorreu uma falha no retorno da informação."
		SetRestFault(ERRORSRV_DEF, EncodeUTF8( STR0006 ) + TAB + oError:Description, , , , , )
	END SEQUENCE
Return lRet


/*/{Protheus.doc} WSMETHOD POST
"Método para editar o XML dos eventos do Esocial no Monitor THF"
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
WSMETHOD POST WSREST GPEEsocialXmlMessage
	Local oInput
	Local aDados 		:= {}
	Local cRet			:= ""
	Local cBody			:= ""
	Local cMessage 		:= ""
	Local cMethod		:= "POST"
	Local lRet			:= .T.

	oInput 		:= JsonObject():New()
	cBody     	:= ::GetContent()
	oInput:FromJson(cBody)

	BEGIN SEQUENCE		
		If Empty(cMessage := fPreValid(oInput, cMethod)) // Realiza pré-validações 
			fStartEnv(oInput) // Inicializa o Ambiente
			aDados := fXMLCRUD(oInput, cMethod) // Pesquisa e grava o XML editado
		EndIf

		cRet := fReturn(cMethod, aDados, cMessage) // Montagem da estrutura de retorno da API
		::SetResponse(cRet)

	RECOVER
		lRet := .F.
		ErrorBlock( bErrorBlock ) // STR0006: "Ocorreu uma falha no retorno da informação."
		SetRestFault(ERRORSRV_DEF, EncodeUTF8(STR0006) + TAB + oError:Description, , , , , )
	END SEQUENCE
Return lRet


/*/{Protheus.doc} function fStartEnv
Função que realiza a Inicialização do Ambiente
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
Static Function fStartEnv(oInput)
	Local aAmb := {}

	fSetErrorHandler(EncodeUTF8(STR0007)) // STR0007: "Erro ao preparar o ambiente com a Empresa e Filial informados!"
	aAmb := StrTokArr(oInput["companyId"], "|")
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA aAmb[1] FILIAL aAmb[2] TABLES "RJE" MODULO "GPE"
	fResetErrorHandler()
Return


/*/{Protheus.doc} function fPreValid
Função que realiza as pré-validações
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
Static Function fPreValid(oInput, cMethod)
	Local cMessage	:= ""

	If Empty( oInput["companyId"] )
		cMessage := STR0008 // STR0008: "O parâmetro 'companyId' é obrigatório e não foi informado." 

	ElseIf Empty( oInput["id"] )
		cMessage := STR0009 // STR0009: "O parâmetro 'id' é obrigatório e não foi informado."
	
	ElseIf Empty( oInput["xmlMessage"] ) .AND. cMethod == "POST"
		cMessage := STR0010 // STR0010: "O parâmetro 'xmlMessage' é obrigatório e não foi informado."
	EndIf
Return cMessage


/*/{Protheus.doc} function fReturn
Função que monta a estrutura de retorno da API
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
Static Function fReturn(cMethod, aDados, cMessage)
	Local cRet := ""
	Local oRet := JsonObject():new()
	
	fSetErrorHandler(EncodeUTF8(STR0011)) // STR0011: "Falha na montagem da estrutura de retorno da API"
		If cMethod == "GET"
			If !Empty(cMessage)
				oRet["success"]	:= .F.
				oRet["message"]	:= EncodeUTF8(cMessage)
			Else
				oRet["companyId "] 	:= aDados[3]
				oRet["id"] 			:= aDados[4]
				oRet["xmlType"] 	:= aDados[5]
				oRet["xmlMessage"] 	:= Encode64(aDados[6])
			EndIf

		ElseIf cMethod == "POST"
			If !Empty(cMessage)
				oRet["success"]	:= .F.
				oRet["message"]	:= EncodeUTF8(cMessage)
			Else
				oRet["success"]	:= aDados[2]
				oRet["message"]	:= EncodeUTF8(aDados[3])
			EndIf
		EndIf

		cRet := fCompress(oRet) // Compactação e conversão da String de  retorno
		FreeObj(oRet)

	fResetErrorHandler()
Return cRet


/*/{Protheus.doc} function fXMLCRUD
Função que consulta e retorna os valores dos campos no banco de dados
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
Static Function fXMLCRUD(oInput, cMethod)	
	Local aDados	:= {}
	Local lRet		:= .F.
	Local cQuery	:= ""
	Local cEvent	:= ""
	Local cXML 		:= ""
	Local cRJE		:= "RJE"
	
	Local cAliasQRY	:= GetNextAlias()

	fSetErrorHandler(EncodeUTF8(STR0012)) //"Falha ao buscar/atualizar o XML selecionado!"
		// Verifica conexões abertas
		If Select (cRJE) > 0
			RJE->( dbCloseArea() )
		EndIf
		
		// Consulta e e grava XML editado
		cQuery := "SELECT RJE_XML, RJE_EVENTO, RJE_RETKEY FROM " + RetSqlName(cRJE) + " WHERE "
		cQuery += "RJE_RETKEY = '" + ALLTRIM(oInput["id"]) + "' "
		cQuery := ChangeQuery(cQuery)
		DBUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasQRY, .T., .T.)
		
		If (cAliasQRY)->(!EOF())
			dbSelectArea(cRJE)
			(cRJE)->(DbSetOrder(3)) // RJE_EVENTO, RJE_RETKEY
			(cRJE)->(DbGoTop())

			If (cRJE)->(DbSeek((cAliasQRY)->RJE_EVENTO + (cAliasQRY)->RJE_RETKEY))
				If cMethod == "GET"
					cEvent 	:= ALLTRIM((cAliasQRY)->RJE_EVENTO)
					cXML	:= ALLTRIM((cRJE)->RJE_XML)
					lRet 	:= .T.
				Else
					If !Empty(ALLTRIM(oInput["xmlMessage"]))
						Begin Transaction
							Reclock( cRJE, .F.)
								(cRJE)->RJE_XML 	:= Decode64(ALLTRIM(oInput["xmlMessage"]))
								(cRJE)->RJE_USRXML 	:= oInput["user"]
								lRet 				:= .T.
							MsUnlock()
						End Transaction
					EndIf
				EndIf
			EndIf

			(cAliasQRY)->(DbCloseArea())
		EndIf

		If cMethod == "GET"
			aadd(aDados, cMethod)
			aadd(aDados, lRet)
			aadd(aDados, ALLTRIM(oInput["companyId"]))
			aadd(aDados, ALLTRIM(oInput["id"]))
			aadd(aDados, cEvent)
			aadd(aDados, cXML)
		Else
			aadd(aDados, cMethod)
			aadd(aDados, lRet)
			aadd(aDados, "")
		EndIf

	fResetErrorHandler()
Return aDados


/*/{Protheus.doc} function fCompress
Função que compacta e converte objeto JSON para String
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := oObj:toJSON()

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif
Return cComp


/*/{Protheus.doc} function fSetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
Static Function fSetErrorHandler(cTitle)
	bError  	:= { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock := ErrorBlock( bError )
Return .T.


/*/{Protheus.doc} function fResetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   11/03/2020
@version 12.1.25
/*/
Static Function fResetErrorHandler(cTitle)
	bError  	:= { |e| oError := e , Break(e) }
	bErrorBlock := ErrorBlock( bError )
Return .T.
