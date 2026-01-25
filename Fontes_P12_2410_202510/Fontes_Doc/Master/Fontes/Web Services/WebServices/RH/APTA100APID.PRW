#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APTA100APID.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

/*
{Protheus.doc} eSocialLayoutVersion
API para retorno da versão do eSocial
@author  martins.marcio
@since   10/08/2023
@version 12.1.33
*/

WSRESTFUL eSocialLayoutVersion DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para Retorno da versão do eSocial utilizada no módulo SIGAGPE"
	WSDATA companyId	 	As String
	WSDATA branchId	     	As String
	WSDATA id				As String

	WSMETHOD GET;
	DESCRIPTION oEmToAnsi(STR0002); // "Retorna a versão do eSocial utilizada no módulo SIGAGPE"
	WSSYNTAX "/api/rh/v1/eSocialLayoutVersion" ;
	PATH "/api/rh/v1/eSocialLayoutVersion" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

END WSRESTFUL

// Retorno da versão do eSocial utilizada no módulo SIGAGPE
/*/{Protheus.doc} GET
Método responsável pelo retorno da versão do eSocial utilizada no módulo SIGAGPE
@author  martins.marcio
@since   10/08/2023
@version 12.1.33
@return return, return_description
/*/
WSMETHOD GET QUERYPARAM companyId, branchId HEADERPARAM authorization WSSERVICE eSocialLayoutVersion

	Local cResponse := ""
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()

	DEFAULT Self:aUrlParms 		:= {}
	DEFAULT Self:aQueryString 	:= {}

	Private aUrlParam	:= ::aUrlParms
	Private cCompanyId	:= ""
	Private cBranchId	:= ""
	Private cProcessId	:= ""

	BEGIN SEQUENCE

		fResetErrorHandler()

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := fGetVersion(@oJsonData)

		// Compress String And Set Response
		cResponse := fCompress(@oJsonData)
		::SetResponse(cResponse)

	END SEQUENCE


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetVersion
Retorna json com a lista de Pagamentos do Processo trabalhista
@author  martins.marcio
@since   10/08/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetVersion(oJsonData)

	Local neSocVer		:= 0
	Local lRet 		 	:= .T.
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local oItemData		:= JsonObject():new()
	Local cErroMsg		:= ""

	neSocVer := eSocVerAPT(@cErroMsg)
	If !Empty(cErroMsg) .Or. neSocVer < 1
		fSendError(500,oEmToAnsi(STR0008),.T.,500, cErroMsg,,) //"Versão do leiaute do eSocial incompatível." ...
	Else
		oItemData["eSocialLayoutVersion"]	:= neSocVer
		AAdd(aItemQry, oItemData )

		oCabecData["hasNext"]	:= .F.
		oCabecData["items"]		:= aItemQry
		oJsonData := oCabecData
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function eSocVerAPT
Retorna a versão do eSocial no padrão definido pelas linhas PRT/DTS/RM
@author  martins.marcio
@since   10/08/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function eSocVerAPT(cErroMsg, aVers)

	Local cVersGPE		:= AllTrim(SuperGetMv("MV_VLESOC",, ""))
	Local cVerTaf		:= AllTrim(SuperGetMv("MV_TAFVLES",, ""))
	Local lIdSqPr		:= RE0->(ColumnPos("RE0_IDSQPR")) > 0
	Local lMiddleware	:= IIf( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local nVers			:= -1

	DEFAULT cErroMsg := ""
	DEFAULT aVers	:= {"S_01_01_00",;	// 1 - Versão S-1.1
						"S_01_02_00",;  // 2 - Versão S-1.2
						"S_01_03_00",;	// 3 - Versão S-1.3
						"S_01_03_01"}	// 4 - Versão S-1.3 NT 03/2025

	If !lMiddleware .And. cVersGPE <> cVerTaf
		cErroMsg := oEmToAnsi(STR0009) +cVersGPE+ oEmToAnsi(STR0010) +cVerTaf+ oEmToAnsi(STR0011) //"A versão do leiaute GPE é (XXX) e a do TAF é (XXX), sendo assim, estão divergentes. Verifique os parâmetros MV_VLESOC / MV_TAFVLES."
	Else
		If !Empty(cVersGPE)
			nVers := aScan(aVers,{|x| UPPER(x) == UPPER(cVersGPE)})
			If nVers <= 1
				cErroMsg := oEmToAnsi(STR0012) + cVersGPE + oEmToAnsi(STR0013) //"A versão do leiaute do eSocial (###) não é compatível com a rotina de Processos Trabalhistas, verifique os parâmetros MV_VLESOC / MV_TAFVLES."
			ElseIf nVers == 3 .And. lIdSqPr
				nVers := 4
			EndIf
		Else
			cErroMsg := oEmToAnsi(STR0014) //"A versão do leiaute do eSocial não foi preenchida, verifique os parâmetros MV_VLESOC / MV_TAFVLES."
		EndIf
	EndIf

Return nVers

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informações recebidas na assinatura da mensagem
@author  martins.marcio
@since   10/08/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor()

	Local cMessage	:= ""
	Local lRet		:= .T.

	If Empty(cCompanyId)
		cMessage := oEmToAnsi(STR0006) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0006) + "branchId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	EndIf

	If Empty(cMessage)
		If ! FWFilExist(cCompanyId,cBranchId)
			cMessage := oEmToAnsi(STR0006) + "companyId + branchId " //"Falha ao validar as informações básicas da assinatura. Informação: "
		EndIf
	EndIf

	If ! Empty(cMessage)
		fSendError(400,cMessage,.T.,400,cMessage,,)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetQryPar
Carrega os valores dos parâmetros de query
@author  martins.marcio
@since  10/08/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSetQryPar(aQueryString)

	Local nX as Numeric
	DEFAULT aQueryString := {}

	For nX := 1 To Len(aQueryString)
		Do Case
			Case UPPER(AllTrim(aQueryString[nX][1])) == "COMPANYID"
				cCompanyId := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "BRANCHID"
				cBranchId := aQueryString[nX][2]
		EndCase
	Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  10/08/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0007
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0007
	Default cHelpUrl   := "https://tdn.totvs.com/x/5G6VKw"
	DEFAULT aDetails   := {}

	SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)
