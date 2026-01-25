#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "WSMIDPROC.CH"                                                                                                                                                                                                                                                  

#DEFINE ERRORCODE_DEF	400
#DEFINE ERRORSRV_DEF	500
#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )

Private oError
Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )


// STR0001: "Serviço do Monitor de Transmissão do eSocial"
WSRESTFUL GPEEsocialMonitorTransmission DESCRIPTION OemToAnsi( STR0001 ) FORMAT APPLICATION_JSON 
	WSDATA authorization As String
	WSDATA branches	     As String
	WSDATA period	     As String
	WSDATA events	     As String
	WSDATA keys	     	 AS STRING OPTIONAL
/*
STR0002: "Método para transmissão dos eventos no eSocial"
STR0003: "api/rh/esocial/v1/GPEEsocialMonitorTransmission"
STR0004: "v1" 
*/
WSMETHOD POST DESCRIPTION oEmToAnsi( STR0002 ); 
WSSYNTAX "api/rh/esocial/v1/GPEEsocialMonitorTransmission"; 
PATH "api/rh/esocial/v1/GPEEsocialMonitorTransmission"; 
TTALK "v1"; 
PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD POST WSREST GPEEsocialMonitorTransmission
	Local oInput
	Local nX		:= 1
	Local cBody		:= ""
	Local aEvent	:= ""
	Local cId		:= ""
	Local cPreValid	:= ""
	Local aParam	:= {}
	Local aAmb		:= {}
	Local lRet		:= .T.
	Local cErro		:= ""

	oInput := JsonObject():New()
	cBody  := ::GetContent()
	oInput:FromJson( cBody )
	
	BEGIN SEQUENCE
		IF Empty(cPreValid := fPreValid(oInput)) // Realiza pré-validações
			fSetErrorHandler( EncodeUTF8( STR0005 ) ) // STR0005: "Erro ao preparar o ambiente com a Empresa e Filial informados!"
			
			aAmb := StrTokArr(oInput["companyId"], "|")
			If fSetEnv(aAmb[1], aAmb[2])
				fSetErrorHandler(STR0007) // STR0007: "Não foi possível gravar os dados na Tabela de Controle de Transações (RJN), verifique se a tabela existe no dicionário de dados."

				If RJN->(ColumnPos("RJN_ID")) > 0
					aEvent := oInput["events"]
					aParam := {"", "200", aAmb[1], aAmb[2], aEvent[nX], ALLTRIM(oInput["period"]), oInput["branches"], oInput["keys"]}

					For nX := 1 To Len(aEvent) // Percorre todos os eventos selecionados nos cards
						If Empty(cId) // Montagem do ID da tabela de Transações
							cId := ALLTRIM(STR(YEAR(DATE()))) + ALLTRIM(STR(MONTH(DATE()))) + ALLTRIM(STR(DAY(DATE())))
							cId += REPLACE(TIME(), ":", "")
							cId += SUBSTR(FWUUId(cId), 1, 48)
							cId += SUBSTR(FWUUId(cId), 1, 10)
						EndIf
				
						// Gravação dos dados na Tabela de Controle de Transações
						If fSetRJN(cId, aEvent[nX], ALLTRIM(oInput["period"]), oInput["branches"])
							fResetErrorHandler()
							cErro := StartJob( "GPEM921A", GetEnvServer(), .T., aParam ) // Chamada do JOB para envio dos dados
							::SetResponse(fReturn(cId, cErro))
						EndIf
						fResetErrorHandler()
					Next nX
				EndIf
				fResetErrorHandler()
			EndIf
		Else
			::SetResponse(fReturn("", cPreValid))
		EndIf

	RECOVER
		::SetResponse(fReturn("",oError:Description))
	END SEQUENCE
Return lRet


/*/{Protheus.doc} function fSetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   07/11/2019
@version 12.1.25
/*/
Static Function fSetErrorHandler(cTitle)
	bError  	:= { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock := ErrorBlock( bError )
Return .T.


/*/{Protheus.doc} function fResetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   07/11/2019
@version 12.1.25
/*/
Static Function fResetErrorHandler(cTitle)
	bError  	:= { |e| oError := e , Break(e) }
	bErrorBlock := ErrorBlock( bError )
Return .T.


/*/{Protheus.doc} function fPreValid
Realiza a Pré validação dos Inputs
@author  Hugo de Oliveira
@since   07/11/2019
@version 12.1.25
/*/
Static Function fPreValid( oInput )
	Local cMessage	:= ""

	If Empty( oInput["branches"] )
		cMessage := STR0009 // "O parâmetro 'branches' é obrigatório e não foi informado."

	ElseIf Empty( oInput["events"] )
		cMessage := STR0011 // "O parâmetro 'events' é obrigatório e não foi informado.
		
	ElseIf Empty( oInput["companyId"] )
		cMessage := STR0012 // "O parâmetro 'companyId' é obrigatório e não foi informado."
	EndIf
Return cMessage


/*/{Protheus.doc} function fCompress
Compress String Object
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
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


/*/{Protheus.doc} function fSetRJN
Realiza a gravação do ID macro na tabela de controle de Transações
@author  hugo.de.oliveira
@since   19/11/2019
@version 1.0
/*/
Static Function fSetRJN( cId, cEvent, cPeriod, aBranches )
	Local cHEnv
	Local dDtEnv
	Local nX		:= 1
	Local cBranches	:= ""
	Local lRet		:= .F.

	// Preenchimento de String de Inputs a serem gravadas na RJN
	For nX := 1 To LEN( aBranches )
		cBranches += aBranches[nX]
	Next nX
	
	dDtEnv 	:= DATE()
	cHEnv 	:= TIME()
	
	// Gravação na tabela
	DbSelectArea("RJN")
    RJN->(DbSetOrder(1)) // RJN_FILIAL, RJN_ID
    RJN->(DbGoTop())
	
	Begin Transaction
		Reclock( "RJN", .T.)
			RJN->RJN_ID 	:= cId
			RJN->RJN_DTREQ	:= dDtEnv
			RJN->RJN_HRREQ	:= cHEnv
			RJN->RJN_METODO	:= "POST"
			RJN->RJN_STATUS	:= "2" // Pendente de Processamento
			RJN->RJN_PARAMS	:= cEvent + "|" + cPeriod + "|" + cBranches
			lRet := .T.
		 RJN->(MsUnLock())
	End Transaction
Return lRet


/*/{Protheus.doc} function fReturn
Seta o retorno da API
@author  hugo.de.oliveira
@since   19/11/2019
@version 1.0
/*/
Static Function fReturn( cId, cMessage )
	Local cRet			:= ""
	Local oRet			:= JsonObject():new()
	Local lSuccess		:= .T.
	
	DEFAULT cId 		:= ""
	DEFAULT cMessage 	:= ""
	
	oRet["id"] := cId
	
	If !Empty(cMessage)
		oRet["message"]	:= EncodeUTF8(cMessage)
		lSuccess		:= .F.	
	EndIf
	
	oRet["id"] 		:= cId
	oRet["success"]	:= lSuccess
	cRet			:= fCompress( oRet )
	FreeObj( oRet )
Return cRet


/*/{Protheus.doc} function fSetEnv
Inicializa o ambiente informado
@author  hugo.de.oliveira
@since   19/02/2020
@version 1.0
/*/
Static Function fSetEnv( cEmpIni, cFilIni )
	Local lRet	:=	.T.
	
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cEmpIni FILIAL cFilIni TABLES "RJE, RJN" MODULO "GPE"
	lRet :=	FWFilExist( cEmpIni, cFilIni )
Return lRet
