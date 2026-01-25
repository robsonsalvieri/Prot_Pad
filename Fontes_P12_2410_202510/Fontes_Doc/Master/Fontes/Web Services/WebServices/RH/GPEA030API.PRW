#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEA030API.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1
#DEFINE TAB 			 CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} Positions
	API de Cadastro de Funções

	@author	Marcio Felipe Martins
	@version	P12
	@since	14/01/2020
*/
WSRESTFUL positions DESCRIPTION STR0001 FORMAT "application/json" // STR0001: "Serviço genérico para retorno das informações de Cadastro de Funções."
	WSDATA companyId	 As String
	WSDATA branchId	     As String
	WSDATA page			 As Integer Optional
	WSDATA pageSize		 As Integer Optional
	WSDATA dateModified	 As String  Optional

	WSMETHOD GET DESCRIPTION oEmToAnsi(STR0006) PRODUCES 'application/json;charset=utf-8' WSSYNTAX "/api/rh/v1/positions/" PATH "/api/rh/v1/positions/" TTALK "v2"

END WSRESTFUL

WSMETHOD GET WSRECEIVE companyId, branchId, page, pageSize, dateModified WSSERVICE positions

	Local cResponse  := ""
	Local lRet       := .T.
	Local cCompanId  := ""
	Local cBranchId  := ""
	Local nNumePage  := 1
	Local nPageSize  := 1
	Local cDtUpDate  := ""
	Local cEmpAntBck := cEmpAnt
	Local cFilAntBck := cFilAnt

	Local oGroupData := JsonObject():new()

	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )
	Private oError

	DEFAULT Self:companyId 		:= ""
	DEFAULT Self:branchId 		:= ""
	DEFAULT Self:page 			:= PAGE_DEFAULT
	DEFAULT Self:pageSize 		:= PAGESIZE_DEFAULT
	DEFAULT Self:dateModified 	:= ""

	BEGIN SEQUENCE

		cCompanId := Self:companyId
		cBranchId := Self:branchId
		nNumePage := Self:page
		nPageSize := Self:pageSize
		cDtUpDate := Self:dateModified

		fResetErrorHandler()
		fSetErrorHandler(oEmToAnsi(STR0010)) // STR0010: "Erro ao preparar o ambiente com a Empresa e Filial informados!"

		// Set Default nPageSize
		If ( Empty(nPageSize)) .OR. ( nPageSize > PAGESIZE_DEFAULT ) .OR. ( nPageSize < 1 )
			nPageSize := PAGESIZE_DEFAULT
		EndIf

		// Set Default nPage
		If ( Empty(nNumePage)) .OR. ( nNumePage < 1 )
			nNumePage := PAGE_DEFAULT
		EndIf

		If ! fcheckInfor(cCompanId, cBranchId, nNumePage, nPageSize, cDtUpDate)
			lRet := .F.
			Return lRet
		EndIf

		If cEmpAntBck <> cCompanId .Or. cFilAntBck <> cBranchId
			fTrGrpGPE(cCompanId, cBranchId, "SRJ", "GPE")
		EndIf

		fResetErrorHandler()

		If !SRJ->(ColumnPos("RJ_USERLGA")) > 0
			fSendError(400, oEmToAnsi(STR0003) + oEmToAnsi(STR0007), .T., 400, oEmToAnsi(STR0003) + oEmToAnsi(STR0007),,)// STR0003 + STR0007 : "Campo USERLGA não foi encontrado. Entidade (SRJ)."
			lRet := .F.
			Return lRet

		ElseIf !SRJ->(ColumnPos("RJ_USERLGI")) > 0
			fSendError(400, oEmToAnsi(STR0005) + oEmToAnsi(STR0007), .T., 400, oEmToAnsi(STR0005) + oEmToAnsi(STR0007),,)// STR0005 + STR0007 : "Campo USERLGI não foi encontrado. Entidade (SRJ)."
			lRet := .F.
			Return lRet
		Endif

		// Create employeeList Object And items
		lRet := fGetData(@oGroupData, nNumePage, nPageSize, cDtUpDate)

		// Compress String And Set Response
		cResponse := fCompress(@oGroupData)
		::SetResponse(cResponse)

	RECOVER
		lRet := .F.
		ErrorBlock(bErrorBlock)
		fSendError(500,oError:Description,.T.,500,STR0002,,) // STR0002: "Ocorreu uma falha no retorno da informação."
	END SEQUENCE

	If cEmpAntBck <> cCompanId .Or. cFilAntBck <> cBranchId
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetErrorHandler
Seta código e mensagem de erro
@author  Marcio Felipe Martins
@since   14/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSetErrorHandler(cTitle)

bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
bErrorBlock    := ErrorBlock( bError )

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fResetErrorHandler
Reseta código e mensagem de erro
@author  Marcio Felipe Martins
@since   14/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fResetErrorHandler(cTitle)

bError  := { |e| oError := e , Break(e) }
bErrorBlock    := ErrorBlock( bError )

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informações recebidas na assinatura da mensagem
@author  Marcio Felipe Martins
@since   14/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor(cCompanId, cBranchId, nNumePage, nPageSize, cDtUpDate)

	Local dDataAss
	Local cMessage	:= ""
	Local cFormData := " (yyyy-mm-ddThh:mm:ss)"

	If Empty(cCompanId)
		cMessage := oEmToAnsi(STR0004) + "companyId"

	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0004) + "branchId"
	EndIf

	If ! Empty(cDtUpDate)
		If ! fValidDate(cDtUpDate)
			cMessage := oEmToAnsi(STR0004) + "dateModified" + cFormData
		EndIf
	EndIf

	If ! Empty(cDtUpDate)
		dDataAss := fClearDate(cDtUpDate)
		lDataUp := .T.

		If Empty(cMessage)
			If Empty(dDataAss)
				cMessage := oEmToAnsi(STR0004) + "dateModified" + cFormData
			EndIf
		EndIf
	EndIf

	If Empty(cMessage)
		If ! FWFilExist(cCompanId,cBranchId)
			cMessage := oEmToAnsi(STR0004) + "companyId + branchId "
		EndIf
	EndIf

	If ! Empty(cMessage)
		fSendError(400, cMessage, .T., 400, cMessage,,)
		Return (.F.)
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetData
Busca os dados referente ao Cadastro de Funções
@author  Marcio Felipe Martins
@since   14/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fGetData(oGroupData, nNumePage, nPageSize, cDtUpDate)

	Local cQuery  	 	:= ""
	Local lRet 		 	:= .T.
	Local dDataAss
	Local lDataUp    	:= .F.
	Local oItemData
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local cDataBase		:= TcGetDB()
	Local cIdTab		:= ""
	Local cQrAlias 		:= GetNextAlias()
	Local cDescFunc		:= ""
	Local cCargo		:= ""
	Local cDescCargo	:= ""
	Local cTpDesc		:= SuperGetMv( "MV_NG2TDES", .F., "1" ) //Indica se a descricao por Funcao ou Cargo

	dbSelectArea("SRJ")
	dbSetOrder(1) // RJ_FILIAL+RJ_FUNCAO

	If ! Empty( cDtUpDate )
		dDataAss := fClearDate(cDtUpDate)
		lDataUp := .T.
	EndIf

	// Create Paging Control
	cQuery := "		SELECT JSO.* FROM ( "

	If cDataBase == "ORACLE"
		cQuery +=  "	SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, DADOS.*  "
	ElseIF cDataBase == "POSTGRES"
		cQuery += "		SELECT ROW_NUMBER() OVER( ORDER BY RECNO ) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER, DADOS.* "
	Else
		cQuery += "		SELECT ROW_NUMBER() OVER( ORDER BY RECNO ) ITEMNUMBER, COUNT(1) OVER() TOTALNUMBER, DADOS.* "
	EndIf

	cQuery += "			FROM (	"
	cQuery += "			SELECT SRJ.R_E_C_N_O_ RECNO,"
	cQuery += "					SRJ.RJ_FILIAL,"
	cQuery += "					SRJ.RJ_FUNCAO,"
	cQuery += "					SRJ.RJ_DESC,"
	cQuery += "					SRJ.RJ_CODCBO,"
	cQuery += "					SRJ.RJ_DESCREQ,"
	cQuery += "					SRJ.RJ_CARGO"

	cQuery += "			FROM "+ RetSqlName("SRJ") + " SRJ"
	cQuery += "			WHERE SRJ.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   SRJ.RJ_FILIAL = '" + xFilial("SRJ") + "'"

	// Tratamento para não considerar os registros bloqueados
	If SRJ->(ColumnPos("RJ_MSBLQL")) > 0
		cQuery += " AND RJ_MSBLQL != '1' "
	EndIf
	If SRJ->(ColumnPos("RJ_MSBLQD")) > 0
		cQuery += " AND ( RJ_MSBLQD = '        ' OR RJ_MSBLQD > '" + dToS(Date()) + "')"
	EndIf

	If lDataUp
		cQuery += "     AND ( "

			cQuery += "RJ_USERLGA <> ' ' "
			If cDataBase == "ORACLE"
				cQuery += " 	AND REPLACE(TO_DATE('19960101','YYYYMMDD') + TO_NUMBER(CONCAT(TO_CHAR(ASCII(SUBSTR(RTRIM(RJ_USERLGA),12,1))-50), TO_CHAR(ASCII(SUBSTR(RJ_USERLGA,16,1))-50))) ,'/','') >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "POSTGRES"
				cQuery += "AND (REPLACE(CAST(to_date('19960101','YYYYMMDD') + "
				cQuery += "CAST(CONCAT(REPLACE(CAST((ASCII(SUBSTR(RJ_USERLGA,12,1))-50) AS VARCHAR),' ',''),"
				cQuery += "REPLACE(CAST((ASCII(SUBSTR(RJ_USERLGA,16,1))-50) AS VARCHAR),' ','')) AS INT ) AS VARCHAR ),'-','')) >= '" + DTOS(dDataAss) + "' "
			ElseIF cDataBase == "DB2"
				cQuery += " AND REPLACE(CONVERT(CHARACTER,DATEADD(DAY,CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGA,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGA,16,1))-50 AS CHAR),' ','')) AS INT) '19960101'),102),'.','')   >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "INFORMIX"
				cQuery += " AND REPLACE(CAST(CAST( ADD_DAYS ('1996-01-01',CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGA,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGA,16,1))-50 AS CHAR),' ',''))AS INT)) AS INT) AS CHAR),'.','') >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "MYSQL"
				cQuery += " AND REPLACE(CONVERT(CHARACTER,DATEADD(DAY,CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGA,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGA,16,1))-50 AS CHAR),' ','')) AS INT),'19960101'),102),'.','')   >= '" + DTOS(dDataAss) + "'"
			Else
				cQuery += " AND REPLACE(CONVERT(VARCHAR, DATEADD(DAY,CONVERT(NUMERIC,CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RJ_USERLGA),12,1))-50)+CONVERT(VARCHAR,ASCII(SUBSTRING(RJ_USERLGA,16,1))-50)),'19960101'), 102),'.','')   >= '" + DTOS(dDataAss) + "'"
			EndIf

			cQuery += "     OR "

			cQuery += "RJ_USERLGI <> ' ' "
			If cDataBase == "ORACLE"
				cQuery += " 	AND REPLACE(TO_DATE('19960101','YYYYMMDD') + TO_NUMBER(CONCAT(TO_CHAR(ASCII(SUBSTR(RTRIM(RJ_USERLGI),12,1))-50), TO_CHAR(ASCII(SUBSTR(RJ_USERLGI,16,1))-50))) ,'/','') >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "POSTGRES"
				cQuery += "AND (REPLACE(CAST(to_date('19960101','YYYYMMDD') + "
				cQuery += "CAST(CONCAT(REPLACE(CAST((ASCII(SUBSTR(RJ_USERLGI,12,1))-50) AS VARCHAR),' ',''),"
				cQuery += "REPLACE(CAST((ASCII(SUBSTR(RJ_USERLGI,16,1))-50) AS VARCHAR),' ','')) AS INT ) AS VARCHAR ),'-','')) >= '" + DTOS(dDataAss) + "' "
			ElseIF cDataBase == "DB2"
				cQuery += " AND REPLACE(CONVERT(CHARACTER,DATEADD(DAY,CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGI,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGI,16,1))-50 AS CHAR),' ','')) AS INT) '19960101'),102),'.','')   >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "INFORMIX"
				cQuery += " AND REPLACE(CAST(CAST( ADD_DAYS ('1996-01-01',CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGI,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGI,16,1))-50 AS CHAR),' ',''))AS INT)) AS INT) AS CHAR),'.','') >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "MYSQL"
				cQuery += " AND REPLACE(CONVERT(CHARACTER,DATEADD(DAY,CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGI,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(RJ_USERLGI,16,1))-50 AS CHAR),' ','')) AS INT),'19960101'),102),'.','')   >= '" + DTOS(dDataAss) + "'"
			Else
				cQuery += " AND REPLACE(CONVERT(VARCHAR, DATEADD(DAY,CONVERT(NUMERIC,CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RJ_USERLGI),12,1))-50)+CONVERT(VARCHAR,ASCII(SUBSTRING(RJ_USERLGI,16,1))-50)),'19960101'), 102),'.','')   >= '" + DTOS(dDataAss) + "'"
			EndIf

		cQuery += "  ) "

	EndIf

	cQuery += "			) DADOS "

	cQuery += "			) JSO"
	cQuery += "	        WHERE JSO.ITEMNUMBER BETWEEN " + Alltrim(Str((nNumePage - 1) * nPageSize + 1)) + " AND " + Alltrim(Str((nNumePage * nPageSize))) + " "
	cQuery += "			ORDER BY 1,2,3,4,5	"
	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cQrAlias, .T., .T. )

	// Check return Query
	IF !fValid(nNumePage, (cQrAlias)->ITEMNUMBER)
		lRet := .F.
	Endif

	(cQrAlias)->(DBGoTop())

	If lRet

		// Get items Properties
		While (cQrAlias)->(!Eof())

			oItemData := JsonObject():new()
			cCargo		:= If( !Empty((cQrAlias)->RJ_CARGO), Posicione( "SQ3", 1, xFilial( "SQ3" ) + (cQrAlias)->RJ_CARGO, "Q3_DESCDET" ), "" )
			cDescCargo	:= If( !Empty(cCargo), RHMSMM(cCargo,,,,,,, "SQ3",, "RDY"), "" )
			// Posiciono na Função para garantir Filial+Código corretos na captura de campos MEMO
			SRJ->(dbSeek((cQrAlias)->RJ_FILIAL+(cQrAlias)->RJ_FUNCAO))
			cDescFunc	:= RHMSMM((cQrAlias)->RJ_DESCREQ,,,,,,, "SRJ",, "RDY")
			cIdTab		:= cEmpAnt                                         	+ "|"
			cIdTab		+= (cQrAlias)->RJ_FILIAL							+ "|"
			cIdTab		+= (cQrAlias)->RJ_FUNCAO

			oItemData["companyId"]			:= cEmpAnt
			oItemData["branchId"]			:= (cQrAlias)->RJ_FILIAL
			oItemData["positionCode"]		:= (cQrAlias)->RJ_FUNCAO
			oItemData["name"]				:= AllTrim(Substr((cQrAlias)->RJ_DESC, 1, 100))
			oItemData["cbo"]				:= AllTrim((cQrAlias)->RJ_CODCBO)
			oItemData["id"]					:= cIdTab
			oItemData["activityDetails"]	:= If( cTpDesc == "3" .Or. Empty(cDescCargo), cDescFunc, cDescCargo )

			AAdd(aItemQry, oItemData )

			oCabecData["hasNext"] 		  := Iif((cQrAlias)->ITEMNUMBER >= (cQrAlias)->TOTALNUMBER, .F., .T.)

			cDescFunc := ""
			(cQrAlias)->(DBSkip())

		EndDo

		oCabecData["items"] := aItemQry

		oGroupData := oCabecData

	EndIf

	fResetErrorHandler()
	(cQrAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fValid
Valida os dados da assinatura do metodo
@author  Marcio Felipe Martins
@since   14/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fValid(nNumePage, nItemNumb)
	Local cMessage := ""

	// Check Page
	If nItemNumb == 0
		cMessage := oEmToAnsi(STR0011) // STR0011: "Nenhum registro localizado."
	ElseIf nNumePage > nItemNumb
		cMessage := oEmToAnsi(STR0008) // STR0008: "A página solicitada é maior do que a quantidade disponível na consulta"
	EndIf

	If ! Empty(cMessage)
		fSendError(404,cMessage,.T.,404,cMessage,,)
		Return (.F.)
	Endif

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compacta os dados do retorno solicitado
@author  Marcio Felipe Martins
@since   14/01/2020
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
@since   14/01/2020
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
@since   14/01/2020
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
@since   14/01/2020
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
