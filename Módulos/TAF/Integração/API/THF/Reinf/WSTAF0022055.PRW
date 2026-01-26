#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE ICMS_ST "000004"
#DEFINE IPI	"000005"
#DEFINE R2055 1,1

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0022055()

Monta Json de acordo com a query e visao = 1 ( registros sinteticos por
fornecedor ) da apuracao do TAFAPR2055.

@author Denis Souza / Renan Gomes
@since 01/02/2021
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function WS0022055(aApurac, oEstruct, oValidationError, cPeriodo, cEvent, aFiliais, npage, npageSize )

	local cNrInsc	 As character
	local cBranch	 As character
	local nTSintetic As numeric
	local nTotDoc	 As numeric

	default oValidationError["registryKey"] := {}
	Default npage 		:= 0
	Default npageSize	:= 0

	cNrInsc		:= ""
	cBranch		:= ""
	nTSintetic 	:= 0
	nTotDoc		:= 0
	nTotReg		:= 0 

	While !(aApurac[R2055])->(eof())

		DbSelectArea("SM0")
		aAreaSM0 := SM0->( GetArea() )
		SM0->(DbSetOrder(1))
		If SM0->( DbSeek(cEmpAnt + (aApurac[R2055])->FIL) )
			cBranch  := SM0->M0_FILIAL
			cNrInsc  := SM0->M0_CGC
		EndIf
		RestArea(aAreaSM0)
		
		nTotDoc := 1
		nTotReg++
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])

		//Código da Filial
		oEstruct["eventDetail"][nTSintetic]["branchId"]          :=  (aApurac[R2055])->FIL

		// Nome da Filial
		oEstruct["eventDetail"][nTSintetic]["branch"]            := alltrim(EncodeUTF8(cBranch))

		// CNPJ da Filial
		oEstruct["eventDetail"][nTSintetic]["inscriptionAcq"]    := cNrInsc
		oEstruct["eventDetail"][nTSintetic]["taxNumberFormated"] := cNrInsc
		
		//Total fornecedores pendentes
		oEstruct["eventDetail"][nTSintetic]["totalOutProviders"] := (aApurac[R2055])->QTDPARTIC

		// Status
		oEstruct["eventDetail"][nTSintetic]["status"]            := Alltrim((aApurac[R2055])->STATUS) 

		//Total Bruto
		oEstruct["eventDetail"][nTSintetic]["totalGrossValue"]   := (aApurac[R2055])->VLRECBRT

		//Inscrição de apuração
		oEstruct["eventDetail"][nTSintetic]["key"]               := cNrInsc

		//Propriedade errors que habilita o icone no frontend
		oEstruct["eventDetail"][nTSintetic]["errors"]            := 'errors'

		If Len(oValidationError["registryKey"]) > 0
			// Chave de busca do erro da apuração
			oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"]  := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
		EndIf

		// Valor INSS
		oEstruct["eventDetail"][nTSintetic]["valueINSS"] 	    := (aApurac[R2055])->CONTPR
		// Valor Gilrat
		oEstruct["eventDetail"][nTSintetic]["valueGilRat"] 	    := (aApurac[R2055])->GILRAT
		// Valor Senar
		oEstruct["eventDetail"][nTSintetic]["valueSenar"] 	    := (aApurac[R2055])->SENAR
		//Total fornecedores
		oEstruct["eventDetail"][nTSintetic]["totalProviders"] 	:= (aApurac[R2055])->PARTIC
		
		//Total documentos
		oEstruct["eventDetail"][nTSintetic]["totalDocs"] 	    := (aApurac[R2055])->TOTALDOCS

		(aApurac[R2055])->(dbSkip())
	EndDo

oEstruct['hasNext'] := Iif((npage * npageSize) >= nTotReg, .F., .T.)

Return oEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} WSQry2055()

Montagem da estrutura temporário para ser utilizar no json.

@author Denis Souza / Renan Gomes
@since 01/02/2021
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function WSQry2055(cPerApu, aFil, nView, cPartic,cChvNF, cItemNF,cFilDoc)

	local cAlias2055 as character
	Local cCompC1H   as Character
	Local cFiliais   as Character
	Local cQuery     as Character
	Local cBd        as Character
	Local cAl2055    as Character
	Local aRet       as array
	Local aInfoEUF   as array
	Local aCamp      as array
	Local lICMSFRETE as logical
	Local oTemp2055  as object
	Local aIndTab    as array

	Default nView	:= 1
	Default cPartic	:= ""
	Default cFilDoc := ""

	cAlias2055 := GetNextAlias()
	cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	cFiliais   := RetFil(aFil)
	cBd        := TcGetDb()
	cQuery     := ""
	aRet       := {}
	aInfoEUF   := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	lICMSFRETE := .F.
	aIndTab     := {}

	lApur 	   := .T.
	lIdProc    := .F.
	lGetStatus := .F.
	cQuery 	   := "%" + Qury2055(cPerApu, lApur, lIdProc, aFil, lGetStatus, cPartic, nView) + "%"

	BeginSql Alias cAlias2055
	COLUMN PROCID AS NUMERIC(14,0)

		SELECT
			%EXP:cQuery%	
	EndSql

	If (cAlias2055)->(!EOF())

		DbSelectArea(cAlias2055)
		(cAlias2055)->(DbGoTop())

		cAl2055	:= GetNextAlias()

		aCamp := { {'FIL'		 , 'C', TamSX3("C20_FILIAL")[1], 0} ,;
				   {'TOTALDOCS'	 , 'N', 14 					   , 0} ,;
				   {'PARTIC'	 , 'N', 14 					   , 0} ,;
				   {'VLRECBRT'	 , 'N', 14 					   , 2} ,;
				   {'CONTPR'	 , 'N', 14 					   , 2} ,;
				   {'GILRAT'	 , 'N', 14 					   , 2} ,;
				   {'SENAR' 	 , 'N', 14 					   , 2} ,;
				   {'STATUS'     , 'C', 12 					   ,0 },;
				   {'QTDPARTIC'  , 'N', 14                     ,0 }}
		
		aIndTab := {'STATUS', 'FIL', 'PARTIC' }
		oTemp2055 := Nil
		oTemp2055 := FWTemporaryTable():New(cAl2055, aCamp)
		oTemp2055:AddIndex('1', aIndTab)
		oTemp2055:Create()

		While (cAlias2055)->(!EOF())

			RecLock(cAl2055, .T.)

			(cAl2055)->FIL	 	 := (cAlias2055)->FIL
			(cAl2055)->TOTALDOCS := (cAlias2055)->TOTALDOCS
			(cAl2055)->PARTIC    := (cAlias2055)->PARTIC
			(cAl2055)->VLRECBRT  := (cAlias2055)->VLRRECBRUTA
			(cAl2055)->CONTPR  	 := (cAlias2055)->CONTPR
			(cAl2055)->GILRAT  	 := (cAlias2055)->GILRAT
			(cAl2055)->SENAR  	 := (cAlias2055)->SENAR
			(cAl2055)->QTDPARTIC := (cAlias2055)->PARTIC - (cAlias2055)->PROCID
			(cAl2055)->STATUS    := Iif( (cAl2055)->QTDPARTIC > 0, 'notValidated', 'validated' )
				
			(cAl2055)->(MsUnLock())

			(cAlias2055)->(DbSkip())
		EndDo
		(cAl2055)->(DBSETORDER(1))
		(cAl2055)->(DBGOTOP())
		aAdd(aRet, { cAl2055 })
	EndIf

	If Empty(aRet)
		aAdd(aRet, { cAlias2055 })
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado pela tela da apuraÃ§Ã£o
para que fique no formato de execuÃ§Ã£o do IN no SQL

@author Henrique Pereira
@since 08/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function RetFil(aFil)
	Local cRetFils	as Character
	Local nX		as Numeric

	cRetFils	:= ""
	nX			:= 0

	If !Empty(xFilial("C20")) .And. Len(aFil) > 0

		For nX := 1 to Len(aFil)
			If nX > 1
				cRetFils += " , '" + xFilial("C20", aFil[nX][2]) + "'"
			Else
				cRetFils += "'" + xFilial("C20", aFil[nX][2]) + "'"
			EndIf
		Next nX
	Else
		cRetFils := "'" + xFilial("C20") + "'"
	EndIf

Return cRetFils

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Leticia Campos
@since 30/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)
	local cKeyError as character
	local nX        as numeric

	cKeyError       := ""
	nX              := 1

	For nX := 1 to Len(oValidationError["registryKey"])
		if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
			if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
				cKeyError := oValidationError["registryKey"][nX]["error"]
			endif
		endif
	Next nX

return ( cKeyError )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryRel2055
Função responsável por retornar a query para geração dp arquivo CSV

@author Renan Gomes
@since 08/02/2021/
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Function QryRel2055(cPerApu,  aFil)
	local aInfoEUF		as array
	local aRet 			as array 
	local cCompC1H		as character
	local cQuery 		as character
	local cBd			as character
	local cAliasApr		as character		
	local cFiliais		as character
	local nTamIDSUSP	as numeric

	aInfoEUF	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	aRet 		:= {}
	cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	cQuery		:= ""
	cBd			:= TcGetDb()
	cAliasApr	:= GetNextAlias()
	cFiliais	:= RetFil(aFil)
	nTamIDSUSP	:= 0

	//SELECT
	cQuery	:= " C20.C20_FILIAL AS FIL, C20.C20_CHVNF AS CHVNF, C20.C20_DTDOC AS DTEMISSAONF, C20.C20_SERIE AS SERIE,   "
	cQuery	+= " C20.C20_NUMDOC AS NUMDOC, C35_VALOR AS VALOR, C35_CODTRI AS CODTRI, "
	cQuery	+= " C30.C30_VLOPER AS VLRRECBRUTA, C30.C30_NUMITE AS NUMITE,"
	cQuery	+= " C1G.C1G_NUMPRO AS NUMPRO, T5L.T5L_INDDEC AS INDSUSP, T5L.T5L_CODSUS AS CODSUS, T9Q.T9Q_VALSUS AS VALSUS, " 
	cQuery	+= " C1H.C1H_NOME NOME, "
	cQuery	+= " C1H.C1H_INDCP INDCP, "
	cQuery	+= " C1H.C1H_CPF CPFPR, "
	cQuery	+= " C1H.C1H_CNPJ CNPJPR, "
	cQuery	+=  " 		CASE "
	cQuery	+=  " 		           WHEN  C1H.C1H_CPF <> '' THEN  C1H.C1H_CPF "
	cQuery	+=  " 		           ELSE  C1H.C1H_CNPJ "
	cQuery	+=  " 		       END PARTI, "
	cQuery	+=  " C30_INDISE INDISE, "
	cQuery	+=  " C0Y.C0Y_CODIGO CFOP , "
	cQuery  += " C20.R_E_C_N_O_ AS RECNO"
		
	cQuery	+= " FROM " + RetSqlName("C20") + " C20"

	//INNER JOIN
	cQuery	+= " INNER JOIN " + RetSqlName("C30") "
	cQuery	+= " C30 ON C20.C20_FILIAL = C30_FILIAL AND C30.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND C20.C20_CHVNF = C30.C30_CHVNF "
	
	cQuery	+= " INNER JOIN " + RetSqlName("C35") "
	cQuery	+= " C35 On C30.C30_FILIAL = C35_FILIAL AND C30.C30_CHVNF = C35.C35_CHVNF AND "
	cQuery	+= " C30.C30_NUMITE = C35.C35_NUMITE AND C35.C35_CODTRI IN ('000013','000024','000025') "
	cQuery	+= " AND C35.D_E_L_E_T_ = ' ' "

	cQuery	+= " INNER JOIN " + RetSqlName("C1H") "
	cQuery	+= " C1H ON C1H.C1H_ID = C20.C20_CODPAR " 
	cQuery	+= " AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' "

	If cCompC1H == "EEE"
		cQuery += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "			
	Else
		If cBd $ "ORACLE|POSTGRES|DB2"
			If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
			ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
			Else
				cQuery += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"								
			EndIf
					
		ElseIf cBd $ "INFORMIX"
			If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] = C20.C20_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] " 
			ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] = C20.C20_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] " 
			Else
				cQuery += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"								
			EndIf

		Else
			If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
			ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
			Else
				cQuery += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"								
			EndIf
		EndIf
	
	EndIf
	cQuery	+= " AND C1H.C1H_RAMO = '4' "
	cQuery	+= " INNER JOIN " + RetSqlName("C0Y") "
	cQuery	+= " C0Y ON C0Y.C0Y_ID = C30.C30_CFOP "

	cQuery	+= " LEFT JOIN " + RetSqlName("T9Q") + " T9Q ON "
	cQuery	+= "  T9Q.T9Q_FILIAL = C30.C30_FILIAL "
	cQuery	+= " AND T9Q_CHVNF = C30.C30_CHVNF "
	cQuery	+= " AND T9Q.T9Q_CODTRI = C35.C35_CODTRI "
	cQuery	+= " AND T9Q.D_E_L_E_T_ = ' ' "

	cQuery +=  " LEFT JOIN " +  RetSqlName("C1G") + " C1G ON "
	cQuery +=  " C1G.C1G_FILIAL = '" + xFilial("C1G") + "' AND "
	cQuery +=  " C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "

	If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
		if cBd $ "POSTGRES"
			nTamIDSUSP	:= TamSX3("T9Q_IDSUSP")[1]
			cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = SUBSTR(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") AND  T9Q.T9Q_FILIAL = C20.C20_FILIAL  AND "
		Else
			cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS AND  T9Q.T9Q_FILIAL = C20.C20_FILIAL  AND "
		Endif
	Else
		cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L.T5L_ID+T5L.T5L_VERSAO+T5L.T5L_CODSUS AND  T9Q.T9Q_FILIAL = C20.C20_FILIAL  AND "
	EndIf
	cQuery += " T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

	//WHERE
	cQuery	+= " WHERE C20.C20_FILIAL IN (" + cFiliais + ")  "
	cQuery	+= " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') "
	cQuery	+= " AND C20.C20_TPDOC <> '000002' "
	cQuery	+= " AND C20.D_E_L_E_T_ = ' '  "
	cQuery	+= " AND C20.C20_INDOPE = '0' AND " //APENAS ENTRADA

	If cBd $ "ORACLE|POSTGRES|DB2"
		cQuery	+=  " SUBSTR(C20.C20_DTDOC,1,6) = '"+ cPerApu +"'"
			
	ElseIf cBd $ "INFORMIX"
		cQuery	+=  " C20.C20_DTDOC[1,6] = '"+ cPerApu +"'"

	Else
		cQuery	+=  " SUBSTRING(C20.C20_DTDOC,1,6) = '"+ cPerApu +"'"
	EndIf

	// Tratamento feito para retornar registros da tabela C30 em que os campos C30_IDTSER, C30_SRVMUN, 
	// C30_CODSER e C30_TPREPA sejam diferentes de branco.
	// Caso seja retornado algum registro, esse documento fiscal não deverá estar disponível para apuração no evento R-2055 e sim R-2010.

	cQuery += " AND NOT EXISTS (SELECT C30.C30_CHVNF FROM " + RetSQLName("C30") + " C30 "
	cQuery += " WHERE C30.C30_FILIAL = C20.C20_FILIAL "
	cQuery += " AND C30.C30_CHVNF = C20.C20_CHVNF "
	cQuery += " AND (C30.C30_IDTSER != '" + Padr(" ", TamSx3("C30_IDTSER")[1]) + "' OR C30.C30_SRVMUN != '" + Padr(" ", TamSx3("C30_SRVMUN")[1]) + "' "
	cQuery += " OR C30.C30_CODSER != '" + Padr(" ", TamSx3("C30_CODSER")[1]) + "' OR C30.C30_TPREPA != '" + Padr(" ", TamSx3("C30_TPREPA")[1]) + "') "
	cQuery += " AND C30.D_E_L_E_T_ = ' ') "

	//---------------------------------------------------------------------------------------------------------------------------------------------------

	cQuery	+=  " UNION ALL  "
	
	cQuery	+=  " SELECT LEM.LEM_FILIAL AS FIL, "
	cQuery	+=  " 		LEM.LEM_ID	 AS CHVNF, "
	cQuery	+=  " 		LEM.LEM_DTEMIS AS DTEMISSAONF, "
	cQuery	+=  " 		LEM.LEM_PREFIX AS SERIE, "
	cQuery	+=  " 		LEM.LEM_NUMERO AS NUMDOC, "
	cQuery	+=  " 		CASE WHEN C3S.C3S_CODIGO = '25' THEN LEM.LEM_VLRSEN  "
	cQuery	+=  " 				WHEN C3S.C3S_CODIGO = '24' THEN LEM.LEM_VLRGIL  "
	cQuery	+=  " 				WHEN C3S.C3S_CODIGO = '13' THEN LEM.LEM_VLRCP END VALOR , "
	cQuery	+=  " 		C3S.C3S_ID CODTRI, "
	cQuery	+=  " 		LEM.LEM_VLBRUT AS VLRRECBRUTA, "
	cQuery	+=  " 		'0001' AS NUMITE, "
	cQuery	+=  " 		C1G.C1G_NUMPRO AS NUMPRO, "
	cQuery	+=  " 		T5L.T5L_INDDEC AS INDSUSP, "
	cQuery	+=  " 		T5L.T5L_CODSUS AS CODSUS, "
	cQuery	+=  " 		T9E.T9E_VALSUS AS VALSUS, "
	cQuery	+=  " 		C1H.C1H_NOME NOME, "
	cQuery	+=  " 		C1H.C1H_INDCP INDCP, "
	cQuery	+=  " 		C1H.C1H_CPF CPFPR, "
	cQuery	+=  " 		C1H.C1H_CNPJ CNPJPR, "
	cQuery	+=  " 		CASE "
	cQuery	+=  " 		           WHEN  C1H.C1H_CPF <> '' THEN  C1H.C1H_CPF "
	cQuery	+=  " 		           ELSE  C1H.C1H_CNPJ "
	cQuery	+=  " 		       END PARTI, "
	cQuery	+=  " 		LEM_INDISE INDISE, "
	cQuery	+=  " 		'     ' CFOP, "
	cQuery	+=  " 		LEM.R_E_C_N_O_ AS RECNO "
									
	cQuery	+=  " 	FROM " + RetSqlName("LEM") +  " LEM "

	cQuery	+= " INNER JOIN " + RetSqlName("C1H") "
	cQuery	+= " C1H ON C1H.C1H_ID = LEM.LEM_IDPART " 
	cQuery	+= " AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' "

	If cCompC1H == "EEE"
		cQuery += "AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "			
	Else
		If cBd $ "ORACLE|POSTGRES|DB2"
			If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
			ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
			Else
				cQuery += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"								
			EndIf
					
		ElseIf cBd $ "INFORMIX"
			If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] = LEM.LEM_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] " 
			ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] = LEM.LEM_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] " 
			Else
				cQuery += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"								
			EndIf

		Else
			If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
			ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
				cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
			Else
				cQuery += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"								
			EndIf
		EndIf
	
	EndIf
	cQuery	+=  " AND C1H.C1H_RAMO = '4' "

	cQuery	+=  " 	INNER JOIN " + RetSqlName("C3S") +" C3S ON C3S.C3S_FILIAL = ' ' AND C3S.C3S_CODIGO IN ('25','24','13') "

	cQuery	+=  " 	LEFT JOIN " + RetSqlName("T9E") +" T9E ON T9E.T9E_FILIAL = LEM.LEM_FILIAL "
	cQuery	+=  " 	AND T9E_ID = LEM.LEM_ID "
	cQuery	+=  " 	AND T9E.T9E_CODTRI = C3S.C3S_ID "
	cQuery	+=  " 	AND T9E.D_E_L_E_T_ = ' ' "
	
	cQuery	+=  " 	LEFT JOIN " + RetSqlName("C1G") +" C1G ON C1G.C1G_FILIAL =  LEM.LEM_FILIAL "
	cQuery	+=  " 	AND C1G.C1G_ID = T9E.T9E_NUMPRO "
	cQuery	+=  " 	AND C1G.D_E_L_E_T_ = ' ' "
	
	If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
		if cBd $ "POSTGRES"
			nTamIDSUSP	:= TamSX3("T9E_IDSUSP")[1]
			cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9E.T9E_IDSUSP = SUBSTR(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") "
		Else
			cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9E.T9E_IDSUSP = T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS "
		Endif
	Else
		cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9E.T9E_IDSUSP = T5L.T5L_ID+T5L.T5L_VERSAO+T5L.T5L_CODSUS "
	EndIf

	cQuery	+=  " 	AND T5L.D_E_L_E_T_ = ' ' "
	cQuery	+=  " 	AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

	cQuery	+=  " 	WHERE LEM.LEM_FILIAL IN (" + cFiliais + ")  "
	cQuery	+=  " 	AND LEM.LEM_NATTIT = '0' "
	cQuery	+=  " 	AND  CASE WHEN C3S.C3S_CODIGO = '25' THEN LEM.LEM_VLRSEN  "
	cQuery	+=  " 		WHEN C3S.C3S_CODIGO = '24' THEN LEM.LEM_VLRGIL  "
	cQuery	+=  " 		WHEN C3S.C3S_CODIGO = '13' THEN LEM.LEM_VLRCP END > 0 "
	cQuery	+=  " 	AND LEM.LEM_DOCORI = '' AND"
	If cBd $ "ORACLE|POSTGRES|DB2"
		cQuery	+=  " SUBSTR(LEM.LEM_DTEMIS,1,6) = '"+ cPerApu +"'"
			
	ElseIf cBd $ "INFORMIX"
		cQuery	+=  " LEM.LEM_DTEMIS[1,6] = '"+ cPerApu +"'"

	Else
		cQuery	+=  " SUBSTRING(LEM.LEM_DTEMIS,1,6) = '"+ cPerApu +"'"
	EndIf
	cQuery	+=  " 	AND (LEM.LEM_VLRGIL > 0 "
	cQuery	+=  " 		OR LEM.LEM_VLRSEN > 0 "
	cQuery	+=  " 		OR LEM.LEM_VLRCP > 0) "
	cQuery	+=  " 	AND LEM.D_E_L_E_T_ = ' ' "

	// Tratamento feito para retornar registros da tabela T5M em que os campos T5M_IDTSER e T5M_TPREPA sejam diferentes de branco.
	// Caso seja retornado algum registro, essa fatura não deverá estar disponível para apuração no evento R-2055 e sim R-2010.

	cQuery  +=	" AND NOT EXISTS (SELECT T5M.T5M_NUMFAT FROM " + RetSqlName("T5M") + " T5M WHERE T5M.T5M_FILIAL = LEM.LEM_FILIAL "
	cQuery  +=	" AND T5M.T5M_ID = LEM.LEM_ID "
	cQuery  +=	" AND T5M.T5M_IDPART = LEM.LEM_IDPART "
	cQuery  +=	" AND T5M.T5M_NUMFAT = LEM.LEM_NUMERO "
	cQuery  +=	" AND (T5M.T5M_IDTSER != '" + Padr(" ", TamSx3("T5M_IDTSER")[1]) + "' "
	cQuery  +=	" OR T5M.T5M_TPREPA != '" + Padr(" ", TamSx3("T5M_TPREPA")[1]) + "' ) "
	cQuery  +=	" AND T5M.D_E_L_E_T_ = ' ') "

	//------------------------------------------------------------------------------------------------------------------------------

	cQuery += " ORDER BY 1,2,9"

	cQuery		:= "%" + cQuery + "%"

	BeginSql Alias cAliasApr

		COLUMN DTEMISSAONF AS DATE
		
		SELECT distinct
			%EXP:cQuery%	
	EndSql

	aAdd(aRet, { cAliasApr })

Return aRet
