#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEA010API.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#Include "topconn.ch"


#DEFINE URL_DEF			"http://tdn.totvs.com/x/Uzh_HQ"
#DEFINE ERRORCODE_DEF	400
#DEFINE ERRORSRV_DEF	500
#DEFINE PAGESIZE_DEF	2000
#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )


// STR0001: "Serviço genérico para retorno das informações de Funcionário do Microsiga Protheus."
WSRESTFUL employeedatacontent DESCRIPTION oEmToAnsi(STR0001) SECURITY 'GPEA010'  FORMAT "application/json" 
	WSDATA authorization As String
	WSDATA companyId	 As String
	WSDATA branchId	     As String
	WSDATA product	     As String
	WSDATA page			 As Integer Optional
	WSDATA pageSize		 As Integer Optional
	WSDATA datemodified	 As String  Optional
	WSDATA filter	 	 As String  Optional

	WSMETHOD GET DESCRIPTION oEmToAnsi(STR0006) PRODUCES APPLICATION_JSON WSSYNTAX "rh/v1/employeedatacontent/" PATH "rh/v1/employeedatacontent/" TTALK "v1"
END WSRESTFUL


WSMETHOD GET QUERYPARAM companyId, branchId, page, pageSize, datemodified, product, filter HEADERPARAM authorization WSSERVICE employeedatacontent 
	Local cResponse 	:= ""
	Local lRet 			:= .T.
	Local aEmpre        := {}
	Local oEmpData	    := JsonObject():New()
	Local nPage 	 	:= 0
	Local nPageSize  	:= 0
	Local cDateMod		:= ""
	Local cCompId 	 	:= ""
	Local cBranchId  	:= ""
	Local cProd 		:= ""
	Local cEmpAntBck := cEmpAnt
	Local cFilAntBck := cFilAnt

	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )
	Private oError
	Private aDePara		:= fGetDePara()

	DEFAULT Self:authorization  := ""
	DEFAULT Self:page 			:= 1
	DEFAULT Self:pageSize 		:= PAGESIZE_DEF
	DEFAULT Self:datemodified 	:= ""
	DEFAULT Self:companyId 		:= ""
	DEFAULT Self:branchId 		:= ""
	DEFAULT Self:product 		:= ""
	DEFAULT Self:filter 		:= fGetFilter(Self:aQueryString)

	BEGIN SEQUENCE
		nPage 	   := Self:page
		nPageSize  := Self:pageSize
		cDateMod   := Self:datemodified
		cCompId    := Self:companyId
		cBranchId  := Self:branchId
		cProd 	   := Self:product

		// Verify PreValidations
		IF !fPreValid(@oEmpData, cBranchId, cDateMod, cCompId, cProd)
			lRet := .F.
		Endif

		If lRet
			fSetErrorHandler(EncodeUTF8(STR0010)) // STR0010: "Erro ao preparar o ambiente com a Empresa e Filial informados!"

			// Set nPageSize
			IF (nPageSize < 1) .OR. (nPageSize > PAGESIZE_DEF)
				nPageSize := PAGESIZE_DEF
			EndIf

			// Set nPage
			If nPage < 1
				nPage := 1
			EndIf

			// Prepare Environment
			aEmpre := FWSM0Util():GetSM0Data( cCompId , cBranchId, { "M0_CODIGO", "M0_CODFIL" } )

			// companyId Validation
			If Empty(aEmpre)
				// STR0007: De-Para de Empresa e Filial não encontrado na base para companyId. STR0008: e BranchId 
				SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0007) + " '" + cCompId + "' "+ EncodeUTF8(STR0008) + " '" + cBranchId + "' !", , , , URL_DEF, )
				lRet := .F.
			EndIf
		
			If lRet
				If cEmpAntBck <> aEmpre[1][2] .Or. cFilAntBck <> aEmpre[2][2]
					fTrGrpGPE(aEmpre[1][2], aEmpre[2][2], "SRA,SQB,CTT,SQ3,SR6,SRJ", "GPE")
				EndIf

				// Get SRA Data
				lRet := fGetData(@oEmpData, nPage, nPageSize, cDateMod, cBranchId, Self:filter )
			EndIf

		EndIf

		// Compress String And Set Response
		cResponse := fCompress(@oEmpData)
		::SetResponse(cResponse)

	RECOVER
		lRet := .F.
		ErrorBlock(bErrorBlock)
		SetRestFault(ERRORSRV_DEF, EncodeUTF8(STR0009) + TAB + oError:Description, , , , URL_DEF, ) // STR0009: "Ocorreu uma falha no retorno da informação."
	END SEQUENCE

	If !Empty(aEmpre) .And. Len(aEmpre) >= 2 .And. (cEmpAntBck <> aEmpre[1][2] .Or. cFilAntBck <> aEmpre[2][2])
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} function ClearDate
Clean especial character from Date Input. Input Format: 2012-04-23T18:25:43.511Z
@author  oliveira.hugo
@since   26/04/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fClearDate(cDate)
	cDate := StrTran(cDate, "T", "")
	cDate := StrTran(cDate, ":", "")
	cDate := StrTran(cDate, "-", "")
	cDate := SubStr(cDate,1,8)
Return cDate


//-------------------------------------------------------------------
/*/{Protheus.doc} function fDateValid
Verify Date Input
@author  oliveira.hugo
@since   10/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fValidDate(cDate)
	Local lRet := .T.

	// Formato Considerado como válido: "2001-01-01T18:25:43"
	If !Empty(cDate)
		If  SubStr(cDate, 5,  1) != "-" .OR. SubStr(cDate, 8,  1) != "-" .OR. SubStr(cDate, 11, 1) != "T" .OR. SubStr(cDate, 14, 1) != ":" .OR. SubStr(cDate, 17, 1) != ":"
				lRet := .F.
		EndIf
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function formatDate
Return JSON Date Format
@author  oliveira.hugo
@since   26/04/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function formatDate(cDate)
	Local cNewDate := ""
	
	DEFAULT cDate := ""

	IF !Empty(cDate)
		cNewDate := SubStr(cDate,1,4)+"-"+SubStr(cDate,5,2)+"-"+SubStr(cDate,7,2)+"T"+"00:00:00"
	EndIf

Return cNewDate


//-------------------------------------------------------------------
/*/{Protheus.doc} function fPreValid
Check Pre-Validations
@author  oliveira.hugo
@since   26/04/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fPreValid(oObj, cBranchId, cDateMod, cCompId, cProd)
	Local lRet 	   := .T.
	Local cMessage := ""
	Local lUsrLGA  := If(SRA->(ColumnPos("RA_USERLGA")) > 0, .T., .F.)
	
	Local nSM0			As Integer
	Local aSM0			As Array

	aSM0		:= FWLoadSM0()
	
	// Check Fields
	If lUsrLGA == .F.
		cMessage := STR0003 // STR0003: "Campo RA_USERLGA não foi encontrado."
		lRet := .F.

	// Check cProd
	ElseIf Empty(cProd)
		cMessage := STR0015 // STR0015: "O parâmetro product é obrigatório."
		lRet 	 := .F.

	// Check cCompId
	ElseIf Empty(cCompId)
		cMessage := STR0018 // STR0018: "O parâmetro companyId é obrigatório."
		lRet 	 := .F.

	// Check cBranchId
	ElseIf Empty(cBranchId)
		cMessage := STR0013 // STR0013: "O parâmetro branchId é obrigatório."
		lRet 	 := .F.

	ElseIf !fValidDate(cDateMod)
		cMessage := STR0017 // STR0017: "Se preenchido, o parâmetro datemodified deve estar no formato: '2019-05-01T18:25:43'."
		lRet 	 := .F.

	// cBranchId Validation
	ElseIf (nSM0:=ascan(aSM0,{|X| Alltrim(X[1]) == cCompId .AND. Alltrim(X[2])==cBranchId })) == 0
		cMessage := STR0019 + cCompId + " " + cBranchId // STR0019: "Filial não encontrada para os valores informados de empresa e Filial: "
		lRet 	 := .F.
	EndIf

	If !lRet
		SetRestFault(ERRORCODE_DEF, EncodeUTF8(cMessage), , , , URL_DEF, )
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fPosValid
Check data validation after SRA Query
@author  oliveira.hugo
@since   26/04/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fPosValid(oObj, nPage, nReg, nTotalReg)
	Local lRet		:= .T.
	Local cMessage	:= ""

	DEFAULT  nPage		:= 0
	DEFAULT  nReg		:= 0
	DEFAULT  nTotalReg	:= 0

	If nReg == 0 .OR. nTotalReg == 0
		cMessage	:= STR0002 // STR0002: "Nenhum registro localizado."
		lRet		:= .F.
	EndIf

	If !lRet
		SetRestFault(ERRORCODE_DEF, EncodeUTF8(cMessage), , , , URL_DEF, )
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compress String Object
@author  oliveira.hugo
@since   26/04/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := oObj:toJSON()
	
	cJson := EncodeUTF8(cJson)

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


// Get Requested Data
Static Function fGetData(oEmpData, page, nPageSize, cDateMod, cBranchId, cFiltUsr)
	Local oItemData
	Local cQuery  	 := ""
	Local cQBFilial	 := ""
	Local cQBDPTO  	 := ""
	Local cQBDesc  	 := ""
	Local cR6Filial  := ""
	Local cR6Desc	 := ""
	Local cQ3Filial  := ""
	Local cQ3Desc	 := ""
	Local cRJFilial  := ""
	Local cRJDesc	 := ""
	Local cAliasSRA  := GetNextAlias()
	Local lRet 		 := .T.
	Local aItemQry   := {}
	Local oHeadData	 := JsonObject():new()
	Local cDataBase  := AllTrim( Upper( TcGetDb() ) )

	DEFAULT oEmpData := JsonObject():New()
	DEFAULT cFiltUsr	 := ""

	fSetErrorHandler(EncodeUTF8(STR0009)) // STR0009: "Erro ao buscar dados do Funcionário. Erro:"
	oHeadData["hasNext"] := .T.

	// Create Paging Control
	cQuery := "SELECT * FROM ( "

	If cDataBase == "ORACLE"
		cQuery +=  "SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, "
	Else
		cQuery += "SELECT ROW_NUMBER() OVER(ORDER BY RA_MAT) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER, "
	EndIf

	cQuery += "RA_FILIAL,RA_MAT,RA_NOME,RA_NOMECMP,RA_CRACHA,RA_DEPTO,"
	cQuery += "RA_ADMISSA,RA_DEMISSA,RA_NASC,RA_SEXO,RA_ENDEREC,RA_NUMENDE,RA_COMPLEM,RA_BAIRRO,"
	cQuery += "RA_ESTADO,RA_NATURAL,RA_SITFOLH,RA_MUNICIP,RA_CEP,RA_DDDFONE,RA_TELEFON,RA_DDDCELU,"
	cQuery += "RA_NUMCELU,RA_PIS,RA_NUMCP,RA_SERCP,RA_CC,RA_CARGO,RA_CATFUNC,RA_TNOTRAB,"
	cQuery += "RA_SEQTURN,RA_CODFUNC,RA_DTFIMCT,RA_EMAIL,RA_UFCP,RA_CIC,RA_CATEFD"

	// Verifiy opened conections
	If Select ("SRA") > 0
		SRA->( dbCloseArea() )
	Endif

	fSetErrorHandler(EncodeUTF8(STR0011)) // STR0011: "Falha ao buscar dados do cliente!"

	// Begin Get SRA Data
	cQuery += " FROM " + RetSqlName("SRA")
	cQuery += " WHERE "
	cQuery += RetSqlName("SRA") + ".D_E_L_E_T_ = ' ' "

	If !Empty(cFiltUsr)
		cQuery += "AND (" + cFiltUsr + " ) "
	EndIf

	If !Empty(cDateMod)
		cQuery += "AND RA_FILIAL = '" + cBranchId + "' "
		cQuery += "AND RA_USERLGA != ' ' "

		// Check Database
		If cDataBase == "ORACLE"
			cQuery += "AND REPLACE(TO_DATE('19960101','YYYYMMDD') + TO_NUMBER(CONCAT(TO_CHAR(ASCII(SUBSTR(RTRIM(RA_USERLGA),12,1))-50), "
			cQuery += "TO_CHAR(ASCII(SUBSTR(RTRIM(RA_USERLGA),16,1))-50))) ,'/','') "

		ElseIF cDataBase == "POSTGRES"
			cQuery += "AND (REPLACE(CAST(to_date('19960101','YYYYMMDD') + "
		    cQuery += "CAST(CONCAT(REPLACE(CAST((ASCII(SUBSTR(RTRIM(RA_USERLGA),12,1))-50) AS VARCHAR),' ',''), "
			cQuery += "REPLACE(CAST((ASCII(SUBSTR(RTRIM(RA_USERLGA),16,1))-50) AS VARCHAR),' ','')) AS INT "
			cQuery += ") AS VARCHAR ),'-','')) "

		ElseIF cDataBase == "DB2"
			cQuery += "AND (REPLACE(CONVERT(VARCHAR, DATEADD(DAY,CONVERT(NUMERIC,CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RA_USERLGA),12,1))-50)"
			cQuery += "+CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RA_USERLGA),16,1))-50)),'19960101'), 102),'.',''))"

		ElseIF cDataBase == "INFORMIX"
			cQuery += "AND (REPLACE(CONVERT(VARCHAR, DATEADD(DAY,CONVERT(NUMERIC,CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RA_USERLGA),12,1))-50)"
			cQuery += "+CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RA_USERLGA),16,1))-50)),'19960101'), 102),'.',''))"

		ElseIF cDataBase == "MYSQL"
			cQuery += "AND (REPLACE(CONVERT(VARCHAR, DATEADD(DAY,CONVERT(NUMERIC,CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RA_USERLGA),12,1))-50)"
			cQuery += "+CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RA_USERLGA),16,1))-50)),'19960101'), 102),'.',''))"
		
		Else // SQL Server ("MSSQL|MSSQL7")
			cQuery += "AND (REPLACE(CONVERT(VARCHAR, DATEADD(DAY,CONVERT(NUMERIC,CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RA_USERLGA),12,1))-50)"
			cQuery += "+CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(RA_USERLGA),16,1))-50)),'19960101'), 102),'.',''))"
		Endif

		// Set cDateMod
		cDateMod := fClearDate(cDateMod)
		
		cQuery += " >= '" + cDateMod + "') FINAL "
		cQuery += "WHERE (FINAL.ITEMNUMBER BETWEEN " + Alltrim(Str((page - 1) * nPageSize + 1)) + " AND " + Alltrim(Str((page * nPageSize))) + ") "

	Else
		cQuery += " AND RA_FILIAL = '" + cBranchId + "') FINAL "
		cQuery += "WHERE (FINAL.ITEMNUMBER BETWEEN " + Alltrim(Str((page - 1) * nPageSize + 1)) + " AND " + Alltrim(Str((page * nPageSize))) + ") "
	EndIf

	// Execute Query
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cAliasSRA, .T., .T. )

	fResetErrorHandler()

	// Check SRA Query
	IF !fPosValid(@oEmpData, page, (cAliasSRA)->ITEMNUMBER, (cAliasSRA)->TOTALNUMBER)
		lRet := .F.
	Endif

	If lRet
		// Create items Array
		oHeadData["total"] 		:= (cAliasSRA)->TOTALNUMBER

		// Get items Properties
		While (cAliasSRA)->(!Eof())
			
			// Set hasNext propertie
			IF ((cAliasSRA)->TOTALNUMBER == (cAliasSRA)->ITEMNUMBER) .OR. ( nPageSize >= (cAliasSRA)->TOTALNUMBER )
				oHeadData["hasNext"] := .F.
			EndIf

			oItemData := JsonObject():new()
			
			//  Get SRA item
			oItemData["companyKey"]      				:= SM0->M0_CODIGO + "|" + (cAliasSRA)->RA_FILIAL // "Agrupamento de Empresa, Unidade de negócio e Filial" - SM0->M0_CODIGO
			oItemData["branch"]          				:= (cAliasSRA)->RA_FILIAL						 // "Filial do Funcionario"
			oItemData["code"]            				:= (cAliasSRA)->RA_MAT							 // "Matricula do Funcionario"
			oItemData["id"]  							:= SM0->M0_CODIGO + "|" + (cAliasSRA)->RA_FILIAL + "|" + (cAliasSRA)->RA_MAT 	 // "Chave única do funcionário"
			oItemData["name"]            				:= RTRIM((cAliasSRA)->RA_NOME)					 // "Nome do Funcionario"
			oItemData["fullName"]        				:= RTRIM((cAliasSRA)->RA_NOMECMP)				 // "Nome Completo do Funcionário"
			oItemData["badgeNumber"]     				:= (cAliasSRA)->RA_CRACHA						 // "Número do Crachá"
			oItemData["departamentCode"] 				:= (cAliasSRA)->RA_DEPTO						 // "Codigo do departamento"
			
			//  Get SQB item
			cQBFilial 	:= POSICIONE( "SQB", 1, xFilial("SQB",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_DEPTO, "QB_FILIAL" )
			cQBDPTO		:= POSICIONE( "SQB", 1, xFilial("SQB",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_DEPTO, "QB_DEPTO" )
			cQBDesc		:= RTRIM(POSICIONE( "SQB", 1, xFilial("SQB",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_DEPTO, "QB_DESCRIC" ))

			If Empty(cQBFilial) .AND. Empty(cQBDPTO)
				oItemData["departamentInternalId"] 		:= ""
				oItemData["departmentDescription"] 		:= ""
			Else
				oItemData["departamentInternalId"] 		:= cQBFilial + "|" + cQBDPTO 		// "InternalId do Departamento"
				oItemData["departmentDescription"] 		:= cQBDesc 							// "Descrição do Departamento"
			EndIf
			
			oItemData["hiringDate"]                     := formatDate((cAliasSRA)->RA_ADMISSA)		// "Data de Admissão"
			oItemData["demissionDate"]                  := formatDate((cAliasSRA)->RA_DEMISSA) 	    // "Data de Demissão"
			oItemData["birthDate"]                      := formatDate((cAliasSRA)->RA_NASC)		    // "Data de aniversário"
			oItemData["gender"]                         := (cAliasSRA)->RA_SEXO		    			// "Sexo"
			oItemData["street"]                         := RTRIM((cAliasSRA)->RA_ENDEREC)			// "Rua do funcionário"
			oItemData["streetNumber"]                   := ALLTRIM((cAliasSRA)->RA_NUMENDE)			// "Número do endereço"
			oItemData["complement"]                     := RTRIM((cAliasSRA)->RA_COMPLEM)			// "Complemento do endereço"
			oItemData["neighborhood"]                   := RTRIM((cAliasSRA)->RA_BAIRRO)			// "Bairro do Funcionário"
			oItemData["homeState"]                      := RTRIM((cAliasSRA)->RA_ESTADO)			// "Estado do Funcinário"
			oItemData["naturalCity"]                    := (cAliasSRA)->RA_NATURAL					// "Naturalidade"
			oItemData["employeeSituation"]              := (cAliasSRA)->RA_SITFOLH    				// "Situação do Funcionário na Folha"		
			oItemData["city"]                           := RTRIM((cAliasSRA)->RA_MUNICIP)			// "Cidade do Funcionário"
			oItemData["zipCode"]                        := (cAliasSRA)->RA_CEP						// "Número do Cep"
			oItemData["areaCode"]                       := ALLTRIM((cAliasSRA)->RA_DDDFONE)			// "Código de Área(DDD)"
			oItemData["telephone"]                      := ALLTRIM((cAliasSRA)->RA_TELEFON)			// "Telefone"
			oItemData["areaCodeMobile"]                 := ALLTRIM((cAliasSRA)->RA_DDDCELU)			// "Código de Área(DDD)"
			oItemData["mobileNumber"]                   := ALLTRIM((cAliasSRA)->RA_NUMCELU)   		// "Número do Telefone Celular"
			oItemData["socialIntegProgCode"]            := (cAliasSRA)->RA_PIS			 		  	// "Numero do PIS do Funcionário"
			oItemData["workCardNumber"]                 := (cAliasSRA)->RA_NUMCP					// "Carteira de Trabalho do Funcionário"
			oItemData["workCardSerie"]                  := (cAliasSRA)->RA_SERCP					// "Serie da Carteira de Trabalho Profissional"
			oItemData["workCardStateIssuing"]           := ALLTRIM((cAliasSRA)->RA_UFCP)			// "Unidade da federação emitente da carteira de trabalho"
			oItemData["costCenterCode"]                 := (cAliasSRA)->RA_CC						// "Código do Centro de Custo"

			//  Get CTT item
			oItemData["costCenterInternalId"]  			:= (cAliasSRA)->RA_CC				 		// "InternalId do Centro de Custo"
			oItemData["costCenterDescription"] 			:= RTRIM(POSICIONE( "CTT", 1, xFilial("CTT",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_CC, "CTT_DESC01" )) // "Descrição do Centro de Custo"

			oItemData["employeePositionCode"] 			:= (cAliasSRA)->RA_CARGO	// "Código do Cargo do Funcionário"

			//  Get SQ3 item
			cQ3Filial	:= POSICIONE( "SQ3", 1, xFilial("SQ3",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_CARGO, "SQ3->Q3_FILIAL" )
			cQ3Desc		:= RTRIM(POSICIONE( "SQ3", 1, xFilial("SQ3",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_CARGO, "SQ3->Q3_DESCSUM" ))

			If Empty(cQ3Filial) .AND. Empty(cQ3Desc)
				oItemData["employeePositionCodeInternalId"] := ""
				oItemData["employeePositionDescription"]    := ""
			Else
				oItemData["employeePositionCodeInternalId"] := cQ3Filial + "|" + (cAliasSRA)->RA_CARGO	// "InternalId do Cargo do Funcionário"
				oItemData["employeePositionDescription"]    := cQ3Desc 									// "Descrição do Cargo do Funcionário"
			EndIf

			oItemData["salaryCategory"] 				:= (cAliasSRA)->RA_CATFUNC	// "Categoria Salarial. Rever estas categorias quando  for utilizar com o RM. Produto Datasul também possui outras categorias (Semana, Quinzenal e Diarista)"
			oItemData["workShiftCode"]  				:= (cAliasSRA)->RA_TNOTRAB	// "Turno de Trabalho"

			//  Get SR6 item
			cR6Filial	:= POSICIONE( "SR6", 1, xFilial("SR6",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_TNOTRAB, "SR6->R6_FILIAL" ) 
			cR6Desc		:= RTRIM(POSICIONE( "SR6", 1, xFilial("SR6",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_TNOTRAB, "SR6->R6_DESC" ))

			If Empty(cR6Filial) .AND. Empty(cR6Desc)
				oItemData["workShiftInternalId"] 		:= ""
				oItemData["workshiftDescription"] 		:= ""
			Else
				oItemData["workShiftInternalId"] 		:= cR6Filial + "|" + (cAliasSRA)->RA_TNOTRAB 	// "O InternalID do Turno de Trabalho"
				oItemData["workshiftDescription"] 		:= cR6Desc 								// "Descrição do Turno de Trabalho"
			EndIf

			oItemData["workShiftSequence"] 				:= (cAliasSRA)->RA_SEQTURN	// "Sequência de Turno do funcionário"
			oItemData["roleCode"]          				:= (cAliasSRA)->RA_CODFUNC	// "Código da Função do Funcionário"

			// Get SRJ item
			cRJFilial 	:= POSICIONE( "SRJ", 1, xFilial("SRJ",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_CODFUNC, "SRJ->RJ_FILIAL" )
			cRJDesc		:= RTRIM(POSICIONE( "SRJ", 1, xFilial("SRJ",(cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_CODFUNC, "SRJ->RJ_DESC"))

			If Empty(cRJFilial) .AND. Empty(cRJDesc)
				oItemData["roleInternalId"]  			:= ""
				oItemData["roleDescription"] 			:= ""
			Else
				oItemData["roleInternalId"]  			:= cRJFilial + "|" + (cAliasSRA)->RA_CODFUNC 	// "InternalID do Código da Função do Funcionário"
				oItemData["roleDescription"] 			:= cRJDesc								// "Descrição da Função do Funcionário"
			EndIf

			oItemData["contractEnd"] 					:= formatDate((cAliasSRA)->RA_DTFIMCT) 	// "Data de término do contrato trabalho/experiência"
			oItemData["email"]       					:= ALLTRIM((cAliasSRA)->RA_EMAIL)		// "Email do funcionário"
			oItemData["employeeCpf"]       				:= ALLTRIM((cAliasSRA)->RA_CIC)		    // "CPF do funcionário"
			oItemData["esocialCategoryCode"]        	:= (cAliasSRA)->RA_CATEFD			    // "Cat. eSocial"

			AAdd(aItemQry, oItemData)
			(cAliasSRA)->(DBSkip())
		EndDo

		oHeadData["items"]  := aItemQry
		oEmpData 			:= oHeadData
	EndIf

	fResetErrorHandler()
	(cAliasSRA)->(DbCloseArea())

Return lRet


/*
{Protheus.doc} fSetErrorHandler
Function fSetErro
@Uso    Seta código e mensagem de erro 
@param  Objeto de erro
@return	Nenhum
@Autor  Lucas Peixoto Sepe - TOTVS
*/
Static Function fSetErrorHandler(cTitle)
	bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)


/*
{Protheus.doc} fResetErrorHandler
Function fSetErro
@Uso    Seta código e mensagem de erro 
@param  Objeto de erro
@return	Nenhum
@Autor  Lucas Peixoto Sepe - TOTVS
*/
Static Function fResetErrorHandler(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetDePara
Retorna o De-para entre campos da API x Campos da tabela SRA
@author  martins.marcio
@since   04/07/2023
/*/
//-------------------------------------------------------------------
Static Function fGetDePara()
	
	Local aCpos := { {" SALARYCATEGORY "	, " RA_CATFUNC "},; 	// Categoria Salarial
					 {" EMPLOYEECPF "		, " RA_CIC "};			// CPF do funcionário
					}	
Return aCpos

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetFilter
Trata e retorna o filtro que será utilizado query de funcionários
@author  martins.marcio
@since   04/07/2023
/*/
//-------------------------------------------------------------------
Static Function fGetFilter(aQryPar)

	Local cFiltRet		:= ""
	Local cCond			:= ""
	Local cCampo		:= ""
	Local nPosFilt		:= 0
	Local aCondicoes	:= {}
	Local nX			:= 0
	Local lRmvOpe		:= .T. // Utilizado para remover operador no inicio do filtro	
	
	DEFAULT aQryPar := {}
	
	If !Empty(aQryPar) .And. !Empty(aDePara)
		nPosFilt := aScan(aQryPar,{|X| UPPER(Alltrim(X[1])) == "$FILTER" }) 
		If nPosFilt > 0 
			cCond := Space(1) + UPPER(aQryPar[nPosFilt][2])

			// Marca onde serão as quebras de cada condição
			cCond := StrTran( cCond, " AND ", " ###AND ")
			cCond := StrTran( cCond, " OR ", " ###OR ") 
			
			// Quebra as condições para serem avaliadas separadamente
			aCondicoes := StrTokArr(cCond,"###")
			If !Empty(aCondicoes)
				For nX := 1 To Len(aCondicoes)
					cCampo := fGetCpo(aCondicoes[nX])
					// Verifica se o campo é válido
					If aScan(aDePara,{|X| UPPER(Alltrim(X[1])) == cCampo }) > 0
						//Converte os campos API x campo da tabela SRA
						AEval(aDePara, {|x| aCondicoes[nX] := StrTran(aCondicoes[nX],x[1],x[2]) })

						//Verifica se é um campo valido para o filtro
						If "RA_" $ aCondicoes[nX]
							cFiltRet += fMudaOper(aCondicoes[nX], lRmvOpe)
							lRmvOpe := .F. //vai remover apenas na primeira condição
						EndIf
					EndIf
				Next nX
			EndIf
			
		EndIf
	EndIf

	cFiltRet := AllTrim(cFiltRet)

Return cFiltRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetCpo
Retorna o campo que está sendo avaliado em determinada condiçao 
@author  martins.marcio
@since   04/07/2023
/*/
//-------------------------------------------------------------------
Static Function fGetCpo(cCondicao)
	Local cCampo := ""
	Local aOper	:= {"AND ", "OR ", "("}
	
	Default cCondicao	:= ""
	cCampo := cCondicao

	//Retira os operadores no inicio da string
	AEval(aOper, {|x| cCampo := StrTran( Alltrim(cCampo), x, "") })

	cCampo := Substr(Alltrim(cCampo), 1, At(" ",Alltrim(cCampo)) -1)

Return cCampo

//-------------------------------------------------------------------
/*/{Protheus.doc} function fMudaOper
Substitui os operadores recebidos na API pelos operadores SQL
@author  martins.marcio
@since   04/07/2023
/*/
//-------------------------------------------------------------------
Static Function fMudaOper(cTexto, lRmvAndOr)
	
	Local aOper := {}
	DEFAULT cTexto		:= ""
	DEFAULT lRmvAndOr 	:= .F.

	If !Empty(cTexto)
		//Operadores lógicos
		aOper := {{" EQ ", " = "},; 	//EQUAL
					{" NE ", " <> "},;	//NOT EQUAL
					{" GT ", " > "},;	//GREATER THAN
					{" GE ", " >= "},;	//GREATER THAN OR EQUAL
					{" LT ", " < "},;	//LESS THAN
					{" LE ", " <= "}};	//LESS THAN OR EQUAL
		
		If lRmvAndOr // Deve remover os operadores AND e OR ?
			aAdd( aOper, {"AND ", ""} )
			aAdd( aOper, {"OR ", ""} )
		EndIf
		
		//Substitui os operadores recebidos na API pelos operadores SQL
		AEval(aOper, {|x| cTexto := StrTran(cTexto,x[1],x[2]) })
	
	EndIf

Return cTexto
