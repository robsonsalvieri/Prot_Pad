#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APTA100APIE.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

/*
{Protheus.doc} laborProcessTaxesConsolidation
API de Pagamentos do Processo trabalhista
@author  martins.marcio
@since   17/09/2024
@version 12.1.2410
*/

WSRESTFUL laborProcessTaxesConsolidation DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para Consolidações do Processo Trabalhista"
	WSDATA companyId	 	As String
	WSDATA branchId	     	As String
	WSDATA fields	     	As String Optional
	WSDATA page			 	As Integer Optional
	WSDATA pageSize		 	As Integer Optional
	WSDATA order	     	As String Optional
	WSDATA id				As String Optional
	WSDATA perApurPagto		As String Optional
	WSDATA cpfTrab			As String Optional

	WSMETHOD POST;
	DESCRIPTION OemToAnsi(STR0002); // "Inclui uma Consolidação, evento S-2555"
	WSSYNTAX "/api/rh/v3/laborProcessTaxesConsolidation" ;
	PATH "/api/rh/v3/laborProcessTaxesConsolidation" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD GET ALL;
	DESCRIPTION oEmToAnsi(STR0003); // "Retorna uma lista de Consolidações, evento S-2555"
	WSSYNTAX "/api/rh/v3/laborProcessTaxesConsolidation" ;
	PATH "/api/rh/v3/laborProcessTaxesConsolidation" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD GET BYID ;
	DESCRIPTION oEmToAnsi(STR0004); // "Retorna uma Consolidação, evento S-2555"
	WSSYNTAX "/api/rh/v3/laborProcessTaxesConsolidation/{id}" ;
	PATH "/api/rh/v3/laborProcessTaxesConsolidation/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD DELETE;
	DESCRIPTION OemToAnsi(STR0005); // "Exclusão da Consolidação evento S-2555"
	WSSYNTAX "/api/rh/v3/laborProcessTaxesConsolidation/{id}" ;
	PATH "/api/rh/v3/laborProcessTaxesConsolidation/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

END WSRESTFUL

// Insere um Processo trabalhista
/*/{Protheus.doc} POST
TODO Método responsável pela inclusão de uma Consolidação do Processo Trabalhista leiaute S-1.3
@author  martins.marcio
@since   17/09/2024
@version 12.1.2410
@return return, return_description
/*/
WSMETHOD POST QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcessTaxesConsolidation
	Local lRet := .T.

	//"A inclusão não é permitida por esta rotina."
	//"Para realizar a geração desse evento utilize a rotina Geração de Eventos Trabalhistas do módulo SIGAGPE (GPEM038)"
	fSendMess(403, oEmToAnsi(STR0013),.T.,403,oEmToAnsi(STR0014),,)
	lRet := .F.

Return (lRet)

// Retorna lista de pagamentos/tributos do processo trabalhista S-2501 S-1.3
/*/{Protheus.doc} GET ALL
Método responsável pelo retorno de todos os pagamentos do processo
@author  martins.marcio
@since   06/09/2024
@version 12.1.2410
@return return, return_description
/*/
WSMETHOD GET ALL QUERYPARAM companyId, branchId, page, pageSize, order, nrProcTrab, perApurPagto, cpfTrab HEADERPARAM authorization WSSERVICE laborProcessTaxesConsolidation

	Local cResponse As Character
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()
	Local cVersEnvio	:= "9.3"

	Private cBranchId  as Character
	Private cCompanyId as Character
	Private cCpfTrab   as Character
	Private cNrProcTra as Character
	Private cOrder     as Character
	Private cPerApurPg as Character
	Private nNumePage := PAGE_DEFAULT
	Private nPageSize := PAGESIZE_DEFAULT
	Private cIdSqPr	  := ""

	BEGIN SEQUENCE

		fResetErrorHandler()
		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If !fCheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		aEval({'RE0', 'RD0', 'E0H', 'E0I'},{|x|CHKFILE(x)})

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := getAll2555(@oJsonData, cVersEnvio)

		// Compress String And Set Responser
		cResponse := fCompress(@oJsonData)
		::SetResponse(cResponse)

	RECOVER
	END SEQUENCE

	FreeObj(oJsonData)

Return lRet

// Retorna pagamentos/tributos do processo trabalhista S-2501
/*/{Protheus.doc} GET BY ID
Método responsável pelo retorno de tributos/pagamentos de um Processo Trabalhista específico leiaute S-1.3
@author  martins.marcio
@since   04/09/2024
@version 12.1.2410
@return return, return_description
/*/
WSMETHOD GET BYID QUERYPARAM companyId, branchId, id HEADERPARAM authorization WSSERVICE laborProcessTaxesConsolidation

	Local cResponse 	:= ""
	Local lRet 			:= .T.
	Local oJsonData 	:= JsonObject():new()
	Local aParms		:= {}
	Local aInfoPar		:= {}
	Local cVersEnvio	:= "9.3"

	DEFAULT Self:aUrlParms := {}

	Private aUrlParam	:= ::aUrlParms
	Private cCompanyId	:= ""
	Private cBranchId	:= ""
	Private cProcessId	:= ""
	Private cPerApurPg	:= ""
	Private cCpfTrab	:= ""

	BEGIN SEQUENCE

		aParms := StrTokArr2(Self:aUrlParms[1],";",.T.)

		fResetErrorHandler()
		fSetErrorHandler(OemToAnsi(STR0016)) // "O Id da requisição está inválido, a chave deve respeitar a estrutura companyId|branchId|nrProcTrab|perApurPagto."
		If !Empty(Self:aUrlParms) .And. !Empty(aParms) .And. Len(aParms) >= 4
			cProcessId	:= aParms[3]
			cPerApurPg	:= aParms[4]
			cPerApurPg	:= fJToD(cPerApurPg,"C")
			aAdd(aInfoPar, {"COMPANYID", aParms[1]})
			aAdd(aInfoPar, {"BRANCHID", aParms[2]})
			aAdd(aInfoPar, {"NRPROCTRAB", aParms[3]})
			aAdd(aInfoPar, {"PERAPURPAGTO", aParms[4]})
		Else
			//"O Id da requisição está inválido, a chave deve respeitar a estrutura companyId|branchId|nrProcTrab|perApurPagto."
			fSendMess(400,OemToAnsi(STR0008),.T.,400,OemToAnsi(STR0016),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf

		fSetQryPar(aInfoPar)

		// Valida os parâmetros recebidos na mensagem
		If !fCheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		aEval({'RE0', 'RD0', 'E0H', 'E0I'},{|x|CHKFILE(x)})

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := f2555ById(@oJsonData, cVersEnvio)

		// Compress String And Set Response
		cResponse := fCompress(@oJsonData)
		::SetResponse(cResponse)

	RECOVER
	END SEQUENCE

	FreeObj(oJsonData)

Return lRet

//-------------------------------------------------------------------
// Exclusão do Processo trabalhista Layout S-1.3
/*/{Protheus.doc} DELETE
Método responsável pela exclusão de um Processo trabalhista
@author  martins.marcio
@since   17/09/2024
@version 12.1.2410
@return return, return_description
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcessTaxesConsolidation

	Local lRet := .T.

	//"A exclusão não é permitida por esta rotina."
	//"Para realizar a geração desse evento utilize a rotina Geração de Eventos Trabalhistas do módulo SIGAGPE (GPEM038)"
	fSendMess(403, oEmToAnsi(STR0015),.T.,403,oEmToAnsi(STR0014),,)
	lRet := .F.

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} function f2501ById3
Retorna informações detalhadas de pagamento/tributos de um processo trabalhista no Layout S-1.3
@author  martins.marcio
@since   04/09/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function f2555ById(oJsonData, cVersEnvio)

	Local oCabecData	:= JsonObject():New()
	Local oItemData
	Local lRet			:= .T.
	Local aItemQry		:= {}
	Local cIdTab		:= ""
	Local chvTaf2555	:= ""
	Local cStat2555		:= ""

	Default cVersEnvio	:= "9.3"

	chvTaf2555 := PadR(AllTrim(cProcessId),20) + ";" + cPerApurPg + ";" + "1" //4-[T8I_FILIAL]+T8I_NRPROC+T8I_PERAPU+T8I_ATIVO
	If gpeHas2555(chvTaf2555, 4, cEmpAnt, cFilAnt, @cStat2555)
		oItemData := JsonObject():new()
		oItemData['companyId'] := cEmpAnt
		oItemData['branchId'] := cFilAnt
		oItemData['excluidoERP'] := "N"
		oItemData['nrProcTrab'] := RTrim(cProcessId)
		oItemData['perApurPgto'] := fDtToJson(cPerApurPg)
		oItemData['hasNext'] := .F.

		cIdTab		:= cEmpAnt			+ ";"
		cIdTab		+= cFilAnt			+ ";"
		cIdTab		+= RTrim(cProcessId) + ";"
		cIdTab		+= fDtToJson(cPerApurPg)
		oItemData["id"] := cIdTab
		AAdd(aItemQry, oItemData )
		FreeObj(oItemData)
	EndIf

	oCabecData["hasNext"]	:= .F.
	oCabecData["items"] := aItemQry
	oJsonData := oCabecData
	FreeObj(oCabecData)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function getAll2555
Retorna json com a lista de Consolidação das Informações de
Tributos Decorrentes de Processo Trabalhista - S-2555.
@author  martins.marcio
@since   18/09/2024
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function getAll2555(oJsonData, cVersEnvio)

	Local lRet 		 	:= .T.
	Local oItemData
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local cIdTab		:= ""
	Local cQrAlias 		:= ""
	Local cStat2555		:= ""
	Local chvTaf2555	:= ""

	DEFAULT cVersEnvio	:= "9.2"

	cQrAlias := fazQry2501(cVersEnvio)

	(cQrAlias)->(DBGoTop())

	// Get items Properties
	While (cQrAlias)->(!Eof())

		chvTaf2555 := PadR(AllTrim((cQrAlias)->NRPROCTRAB),20) + ";" + (cQrAlias)->PERAPURPAGTO+ ";" + "1" //4-[T8I_FILIAL]+T8I_NRPROC+T8I_PERAPU+T8I_ATIVO
		If gpeHas2555(chvTaf2555, 4, cEmpAnt, cFilAnt, @cStat2555)
			oItemData := JsonObject():new()
			oItemData["nrProcTrab"]			:= (cQrAlias)->NRPROCTRAB
			oItemData["perApurPgto"]		:= fDtToJson((cQrAlias)->PERAPURPAGTO)
			cIdTab		:= cEmpAnt					+ ";"
			cIdTab		+= cFilAnt					+ ";"
			cIdTab		+= RTrim((cQrAlias)->NRPROCTRAB)	+ ";"
			cIdTab		+= fDtToJson((cQrAlias)->PERAPURPAGTO)
			oItemData["id"]					:= cIdTab

			AAdd(aItemQry, oItemData )

			oCabecData["hasNext"] 		  := Iif((cQrAlias)->ITEMNUMBER >= (cQrAlias)->TOTALNUMBER, .F., .T.)
		EndIf

		(cQrAlias)->(DBSkip())
	EndDo

	oCabecData["items"] := aItemQry
	oJsonData := oCabecData

	fResetErrorHandler()
	(cQrAlias)->(DbCloseArea())
	FreeObj(oCabecData)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since   10/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0011 // "Erro desconhecido no processo!"
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0011 // "Erro desconhecido no processo!"
	Default cHelpUrl   := ""
	DEFAULT aDetails   := {}

	SetRestFault(nCode,EncodeUTF8(OemToAnsi(cMessage)),lJson,nStatus,EncodeUTF8(OemToAnsi(cDetailMsg)),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informações recebidas na assinatura da mensagem
@author  martins.marcio
@since   10/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor()

	Local cMessage	:= ""
	Local lRet		:= .T.

	If Empty(cCompanyId)
		cMessage := oEmToAnsi(STR0012) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0012) + "branchId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	EndIf

	If !Empty(cCompanyId)
		cCompanyId := Alltrim(cCompanyId)
	Endif

	If Empty(cMessage)
		If ! FWFilExist(cCompanyId,cBranchId)
			cMessage := oEmToAnsi(STR0012) + "companyId + branchId " //"Falha ao validar as informações básicas da assinatura. Informação: "
		EndIf
	EndIf

	If ! Empty(cMessage)
		fSendError(400,cMessage,.T.,400,cMessage,,)
		lRet := .F.
	EndIf

	/* Persiste parâmetros específicos do GET ALL */
	If IsInCallStack("GET_ALL")
		//  Se nPageSize vazio, maior que PAGESIZE_DEFAULT ou negativo assume o DEFAULT
		If ( Empty(nPageSize)) .OR. ( nPageSize > PAGESIZE_DEFAULT ) .OR. ( nPageSize < 1 )
			nPageSize := PAGESIZE_DEFAULT
		EndIf
		// Se nPage vazio ou negativo assume o DEFAULT
		If ( Empty(nNumePage)) .OR. ( nNumePage < 1 )
			nNumePage := PAGE_DEFAULT
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetQryPar
Carrega os valores dos parâmetros de query
@author  martins.marcio
@since  10/11/2022
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
			Case UPPER(AllTrim(aQueryString[nX][1])) == "NRPROCTRAB"
				cNrProcTra := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "CPFTRAB"
				cCpfTrab := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PERAPURPAGTO"
				cPerApurPg := fJToD(aQueryString[nX][2], "C")
			Case UPPER(AllTrim(aQueryString[nX][1])) == "ORDER"
				cOrder := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGE"
				nNumePage := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGESIZE"
				nPageSize := aQueryString[nX][2]
			// Case UPPER(AllTrim(aQueryString[nX][1])) == "FIELDS"
			// 	cFields := aQueryString[nX][2]
		EndCase
	Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  10/11/2022
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0007
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0007
	Default cHelpUrl   := ""
	DEFAULT aDetails   := {}

	SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   25/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fJToD(cDateJson, cDtType)
	Local dRet := sToD("")
	DEFAULT cDateJson := ""
	DEFAULT cDtType	  := "D"

	dRet := IIf(cDtType =="D", sToD( StrTran( cDateJson, "-", "" ) ), StrTran( cDateJson, "-", "" ))

Return dRet
