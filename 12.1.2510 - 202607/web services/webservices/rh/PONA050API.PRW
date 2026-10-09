#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PONA050API.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

#DEFINE TAB 			 CHR ( 13 ) + CHR ( 10 )


/*
{Protheus.doc} AllowanceTypes
	API de Cadastro de Tipos de Abono                              
		
	@author	Marcio Felipe Martins
	@version	P12
	@since	24/02/2020
*/

WSRESTFUL allowancetypes DESCRIPTION STR0001 FORMAT "application/json" // STR0001: "Serviço genérico para retorno das informações de Cadastro de Tipos de Abono."
	WSDATA companyId	 As String
	WSDATA branchId	     As String
	WSDATA page			 As Integer Optional
	WSDATA pageSize		 As Integer Optional
	WSDATA dateModified	 As String  Optional

	WSMETHOD GET DESCRIPTION oEmToAnsi(STR0006) PRODUCES 'application/json;charset=utf-8' WSSYNTAX "/api/rh/v2/allowancetypes/" PATH "/api/rh/v2/allowancetypes/" TTALK "v2"

END WSRESTFUL

WSMETHOD GET WSRECEIVE companyId, branchId, page, pageSize, dateModified WSSERVICE allowancetypes
	Local cResponse		:= ""
	Local cCompanId		:= ""
	Local cBranchId		:= ""
	Local cDtUpDate		:= ""
	Local nNumePage		:= 1
	Local nPageSize		:= 1
	Local lRet			:= .T.
	Local aRet			:= {}
	Local oGroupData	:= JsonObject():new()
	
	Static oFwPS

	DEFAULT Self:companyId 		:= ""
	DEFAULT Self:branchId 		:= ""
	DEFAULT Self:page 			:= PAGE_DEFAULT
	DEFAULT Self:pageSize 		:= PAGESIZE_DEFAULT
	DEFAULT Self:dateModified 	:= ""

	// Limpa o conteúdo da variável de para evitar que o conteúdo de conexões anteriores sejam considerados
	oFwPS := Nil
	
	BEGIN SEQUENCE
		cCompanId := Self:companyId
		cBranchId := Self:branchId
		nNumePage := Self:page
		nPageSize := Self:pageSize
		cDtUpDate := Self:dateModified

		// Set Default nPageSize
		If (Empty(nPageSize)) .Or. (nPageSize > PAGESIZE_DEFAULT) .Or. (nPageSize < 1)
			nPageSize := PAGESIZE_DEFAULT
		EndIf
		
		// Set Default nPage
		If (Empty(nNumePage)) .Or. (nNumePage < 1)
			nNumePage := PAGE_DEFAULT
		EndIf
		
		aRet := fVldJob(cCompanId, cBranchId, nNumePage, nPageSize, cDtUpDate)

		If !aRet[1]
			fSendError(aRet[2], aRet[3],.T., aRet[2], aRet[3],,)
			lRet := .F.
		Else
			// Compress String And Set Response
			oGroupData := aRet[4]
			cResponse := fCompress(@oGroupData)
			::SetResponse(cResponse)
		EndIf
	END SEQUENCE
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informações recebidas na assinatura da mensagem
@author  Marcio Felipe Martins
@since   24/02/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor(cCompanId,cBranchId,nNumePage,nPageSize,cDtUpDate)
Local aRet		:= {.T., 200, ""}
Local dDataAss	:= cToD("")
Local cMessage	:= ""
Local cFormData	:= " (yyyy-mm-ddThh:mm:ss)"

If ! Empty( cDtUpDate ) 
	If ! fValidDate(cDtUpDate)
		cMessage := oEmToAnsi(STR0004) + "dateModified" + cFormData
	EndIf
EndIf

If ! Empty( cDtUpDate )
	dDataAss := fClearDate(cDtUpDate) 
	lDataUp := .T.
	
	If Empty(cMessage)
		If Empty( dDataAss ) 
			cMessage := oEmToAnsi(STR0004) + "dateModified" + cFormData
		EndIf
	EndIf
EndIf

If !Empty(cMessage)
	aRet := {.F., 400, cMessage}
EndIf
Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckDic
Valida a criação dos campos P6_USERLGA e P6_USERLGI
@author  raquel.andrade
@since   20/09/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckDic()
Local aRet		:= {.T., 200, ""}
Local lRHULGA	:= If(SP6->(ColumnPos("P6_USERLGA")) > 0, .T., .F.)
Local lRHULGI	:= If(SP6->(ColumnPos("P6_USERLGI")) > 0, .T., .F.)
Local cMessage	:= ""

	If !lRHULGA
		cMessage := oEmToAnsi(STR0003) + oEmToAnsi(STR0007)// STR0003 + STR0007 : "Campo USERLGA não foi encontrado. Entidade (SP6)."
	ElseIf !lRHULGI
		cMessage := oEmToAnsi(STR0005) + oEmToAnsi(STR0007)// STR0005 + STR0007 : "Campo USERLGI não foi encontrado. Entidade (SP6)."
	EndIf

	If !Empty(cMessage)		
		aRet := {.F., 400, cMessage}
	EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetData
Busca os dados referente ao Cadastro de Tipos de Abono
@author  Marcio Felipe Martins
@since   24/02/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fGetData(oGroupData, nNumePage, nPageSize, cDtUpDate)
	Local cQuery		:= ""
	Local cIdTab		:= ""
	Local lDataUp		:= .F.
	Local lHasNext		:= .F.
	Local aItemQry		:= {}    
	Local aRet			:= {.T., 200, ""}
	Local oCabecData	:= JsonObject():new()
	Local oItemData		:= JsonObject():new()
	Local dDataAss		:= cToD("")
	Local dUserLGA		:= cToD("")
	Local dUserLGI		:= cToD("")
	Local nIniPagina	:= (nNumePage - 1) * nPageSize
	Local nFimPagina 	:= (nNumePage * nPageSize)
	Local nParamOrdr	:= 1
	Local nRegValido  	:= 0
	Local nTotPagina	:= 0
	
	Local cQrAlias := GetNextAlias()
	
	If !Empty(cDtUpDate)
		dDataAss := fClearDate(cDtUpDate) 
		lDataUp := .T.
	EndIf
	
	dbSelectArea("SP6")

	If oFwPS == Nil
		oFwPS := FWPreparedStatement():New()
		cQuery += "SELECT "
		cQuery +=	"SP6.R_E_C_N_O_ RECNO, "
		cQuery +=	"SP6.P6_FILIAL, "
		cQuery +=	"SP6.P6_CODIGO, "
		cQuery +=	"SP6.P6_DESC, "
		cQuery +=	"SP6.P6_USERLGA, "
		cQuery +=	"SP6.P6_USERLGI "
		cQuery += "FROM ? SP6 "
		cQuery += "WHERE SP6.D_E_L_E_T_ = ? "
		cQuery +=	"AND SP6.P6_FILIAL = ? " 
		
		// Tratamento para não considerar os registros bloqueados
		If SP6->(ColumnPos("P6_MSBLQL")) > 0
			cQuery += "AND P6_MSBLQL != ? "
		EndIf

		If SP6->(ColumnPos("P6_MSBLQD")) > 0
			cQuery += "AND (P6_MSBLQD = ? OR P6_MSBLQD > ?) "
		EndIf
		
		If lDataUp
			cQuery += "AND ((P6_USERLGA <> ?) OR (P6_USERLGI <> ?)) "
		EndIf	
		
		cQuery += "ORDER BY P6_FILIAL, P6_CODIGO"

		oFwPS:SetQuery(cQuery)
	EndIf

	oFwPS:SetUnsafe(nParamOrdr++, RetSqlName("SP6"))
	oFwPS:SetString(nParamOrdr++, " ")
	oFwPS:SetString(nParamOrdr++, xFilial("SP6"))

	If SP6->(ColumnPos("P6_MSBLQL")) > 0
		oFwPS:SetString(nParamOrdr++, "1")
	EndIf

	If SP6->(ColumnPos("P6_MSBLQD")) > 0
		oFwPS:SetString(nParamOrdr++, " ")
		oFwPS:SetString(nParamOrdr++, dToS(Date()))
	EndIf

	If lDataUp
		oFwPS:SetString(nParamOrdr++, " ")
		oFwPS:SetString(nParamOrdr++, " ")
	EndIf
	
	cQuery := oFwPS:getFixQuery()

	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cQrAlias, .T., .T.)
	
	(cQrAlias)->(DBGoTop())
	
	// Get items Properties
	While (cQrAlias)->(!Eof())
		oItemData := JsonObject():new()

		If lDataUp
			SP6->(DbGoTo((cQrAlias)->RECNO))
			dUserLGA := cToD(FWLeUserlg("P6_USERLGA", 2))
			dUserLGI := cToD(FWLeUserlg("P6_USERLGI", 2))

			If (!Empty(dUserLGA) .And. dUserLGA < dDataAss) .Or. (!Empty(dUserLGI) .And. dUserLGI < dDataAss)
				(cQrAlias)->(DbSkip())
				Loop
			EndIf
		EndIf

		nRegValido++

		If nRegValido <= nIniPagina
			(cQrAlias)->(DbSkip())
			Loop
		EndIf

		If nRegValido > nFimPagina
			lHasNext := .T.
			(cQrAlias)->(DbSkip())
			Loop
		EndIf

		cIdTab := cEmpAnt                                         	+ "|"
		cIdTab += (cQrAlias)->P6_FILIAL								+ "|"
		cIdTab += (cQrAlias)->P6_CODIGO								 	 
		
		oItemData["companyId"] := cEmpAnt						     
		oItemData["branchId"]  := (cQrAlias)->P6_FILIAL			  						     
		oItemData["code"]	   := (cQrAlias)->P6_CODIGO			 						     
		oItemData["name"]	   := AllTrim(Substr((cQrAlias)->P6_DESC,1,30))
		oItemData["id"]		   := cIdTab
		
		AAdd(aItemQry, oItemData )

		(cQrAlias)->(DbSkip())
	EndDo

	If nRegValido == 0
		aRet := fValid(nNumePage, 0)
		(cQrAlias)->(DbCloseArea())
		Return aRet
	Else
		nTotPagina := Int(nRegValido/nPageSize)
		
		If (nRegValido % nPageSize) > 0
			nTotPagina++
		EndIf
		
		If nNumePage > nTotPagina
			aRet := fValid(2, 1)
			(cQrAlias)->(DbCloseArea())
			Return aRet
		EndIf
	EndIf

	oCabecData["hasNext"] := lHasNext
	oCabecData["items"] := aItemQry
	oGroupData := oCabecData

	aAdd(aRet, oGroupData)
		
	(cQrAlias)->(DbCloseArea())
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fValid
Valida os dados da assinatura do metodo
@author  Marcio Felipe Martins
@since   24/02/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fValid(nNumePage, nItemNumb)
	Local aRet		:= {.T., 200, ""}
	Local cMessage	:= ""
	
	// Check Page
	If nItemNumb == 0
		cMessage := oEmToAnsi(STR0011) // STR0011: "Nenhum registro localizado."
	ElseIf nNumePage > nItemNumb
		cMessage := oEmToAnsi(STR0008) // STR0008: "A página solicitada é maior do que a quantidade disponível na consulta"
	EndIf

	If !Empty(cMessage)
		aRet := {.F., 404, cMessage}
	EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compacta os dados do retorno solicitado
@author  Marcio Felipe Martins
@since   24/02/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := FWJsonSerialize(oObj,.T.,.T.)

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

/*/{Protheus.doc} function fDateValid
Verify Date Input
@author  Marcio Felipe Martins
@since   24/02/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fValidDate(cDate)
	Local lRet := .T.

	// Formato Considerado como válido: "2001-01-01T18:25:43"
	If !Empty(cDate)
		If  SubStr(cDate, 5,  1) != "-" .OR. SubStr(cDate, 8,  1) != "-" .OR. ;
			SubStr(cDate, 11, 1) != "T" .OR. SubStr(cDate, 14, 1) != ":" .OR. ; 
			SubStr(cDate, 17, 1) != ":" .OR. ;
			Len(Alltrim(cDate)) < Len("2001-01-01T18:25:43") 
				lRet := .F.
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function ClearDate
Clean especial character from Date Input. Input Format: 2012-04-23T18:25:43
@author  Marcio Felipe Martins
@since   24/02/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fClearDate(cDate)
Local dData := STOD("")
	
	cDate := StrTran(cDate, "T", "")
	cDate := StrTran(cDate, ":", "")
	cDate := StrTran(cDate, "-", "")
	cDate := SubStr(cDate,1,8)
	dData := StoD(cDate)
	
Return ( dData )

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  Marcio Felipe Martins
@since   24/02/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

DEFAULT nCode := 500
DEFAULT cMessage := STR0002
DEFAULT lJson := .T.
DEFAULT nStatus := 500
Default cDetailMsg := STR0002
Default cHelpUrl := "https://tdn.totvs.com/x/BJuMHw"
DEFAULT aDetails := {}

SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)

/*/{Protheus.doc} fVldJob
Verifica se deve iniciar um job com o grupo de empresa ou filial informado nos parâmetros para validar e buscar os dados
@type static function
@author Marco Nakazawa
@since 14/04/2026
@param cCompanId, character, grupo de empresas
@param cBranchId, character, filial
@param nNumePage, numeric, número da página para paginação
@param nPageSize, numeric, tamanho da página para paginação
@param cDtUpDate, character, data de atualização
@return aRet, array, Retorna um array com os dados validados e buscados ou mensagens de erro
/*/
Static Function fVldJob(cCompanId, cBranchId, nNumePage, nPageSize, cDtUpDate)
Local aRet		:= {.T., 200, ""}
Local lExecJob	:= .F.
Local cUID		:= ""
Local nCount	:= 0
Local nTime		:= 1000

If lExecJob := (cEmpAnt <> cCompanId .Or. cFilAnt <> cBranchId)
	aRet := fVldFil(cCompanId, cBranchId)

	If !aRet[1]
		Return aRet
	Else
		//Define o nome da variavel de controle
		cUID := "PON080_EMP_" + AllTrim(Str(ThreadID()))

		//Atribui a variavel de controle				
		PutGlbValue(cUID, "0")

		//Define a criação e o retorno do Job				
		aRet := StartJob("fVldDds050", GetEnvServer(), .T., cCompanId, cBranchId, nNumePage, nPageSize, cDtUpDate, lExecJob, cUID)
		
		While lExecJob
			//Obtem o valor da variavel global
			If (GetGlbValue(cUID) == "1", nCount := 10, (nCount++, Sleep(nTime)))
			
			lExecJob := (nCount < 10)
		EndDo
		
		//Limpa a variavel global da memoria
		If !Empty(cUID)
			ClearGlbValue(cUID)
		EndIf
	EndIf
Else
	aRet := fVldDds050(cCompanId, cBranchId, nNumePage, nPageSize, cDtUpDate, lExecJob, cUID)
EndIf
Return aRet

/*/{Protheus.doc} fVldDds050
Valida os dados e busca as informações do cadastro de Tipos de Abono
@type static function
@author Marco Nakazawa
@since 14/04/2026
@param cCompanId, character, grupo de empresas
@param cBranchId, character, filial
@param nNumePage, numeric, número da página para paginação
@param nPageSize, numeric, tamanho da página para paginação
@param cDtUpDate, character, data de atualização
@return aRet, array, Retorna um array com os dados validados e buscados ou mensagens de erro
/*/
Function fVldDds050(cCompanId, cBranchId, nNumePage, nPageSize, cDtUpDate, lExecJob, cUID)
Local aRet			:= {}
Local oGroupData	:= JsonObject():new()

Default cCompanId	:= .T.
Default cBranchId	:= .T.
Default nNumePage	:= .T.
Default nPageSize	:= .T.
Default cDtUpDate	:= .T.
Default lExecJob	:= .F.
Default cUID		:= ""

If lExecJob
	RPCSetType(3)
	RPCSetEnv(cCompanId, cBranchId)
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

aRet := fcheckInfor(cCompanId, cBranchId, nNumePage, nPageSize, cDtUpDate)
If !aRet[1]
	Return aRet
EndIf		

aRet := fcheckDic()
If !aRet[1]
	Return aRet
EndIf		

aRet := fGetData(@oGroupData, nNumePage, nPageSize, cDtUpDate)
Return aRet

/*/{Protheus.doc} fVldFil
Verificar se o Grupo de empresa e Filial são válidos.
@type static function
@author Marco Nakazawa
@since 14/04/2026
@param cCompanId, character, grupo de empresas
@param cBranchId, character, filial
@return lRet, logical, Retorna verdadeiro se o grupo e filial são válidos, falso para inválidos
/*/
Static Function fVldFil(cCompanId, cBranchId)
Local aRet := {.T., 200, ""}

If !FWFilExist(cCompanId, cBranchId)
	aRet := {.F., 400, oEmToAnsi(STR0004) + "companyId + branchId"}
EndIf
Return aRet
