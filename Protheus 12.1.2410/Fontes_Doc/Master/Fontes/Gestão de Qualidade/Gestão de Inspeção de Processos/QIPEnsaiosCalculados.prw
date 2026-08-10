#INCLUDE "TOTVS.CH"

CLASS QIPEnsaiosCalculados FROM QLTEnsaiosCalculados
	
	DATA cOperacao          as String

	Method New(nRecnoInspecao, cOperacao, aAmostrasMemoria, lConsideraDB)

	//Métodos Internos
	Method RetornaAmostrasBanco(nRecnoInspecao)
	Method RetornaEnsaiosCalculados(nRecnoInspecao)

EndClass

Method New(nRecnoInspecao, cOperacao, aAmostrasMemoria, lConsideraDB) CLASS QIPEnsaiosCalculados
	
	Local nIndEnsaio     := 0

	Default lConsideraDB := .F.

	Self:aEnsaiosCalculados := Self:RetornaEnsaiosCalculados(nRecnoInspecao)

	If !lConsideraDB
		For nIndEnsaio := 1 To Len(Self:aEnsaiosCalculados)
			If "AVG(" $ Upper(Self:aEnsaiosCalculados[nIndEnsaio, 'formula']) .OR. "DESVPAD(" $ Upper(Self:aEnsaiosCalculados[nIndEnsaio, 'formula'])
				lConsideraDB := .T.
				Exit
			EndIf
		Next nIndEnsaio
	EndIf

	Self:cOperacao          := cOperacao
	Self:aAmostrasBanco     := Iif(lConsideraDB, Self:RetornaAmostrasBanco(nRecnoInspecao), {})
	Self:nTamMedicao        := GetSx3Cache("QPS_MEDICA", "X3_TAMANHO")

	_Super:new(nRecnoInspecao, aAmostrasMemoria, lConsideraDB)

Return

/*/{Protheus.doc} RetornaAmostrasBanco
Retorna Amostras de Resultados do Banco referente nRenoInspecao
@author brunno.costa
@since  30/10/2024
@param 01 - nRecnoInspecao, numérico, número do recno da inspeção na QPK
@return aAmostrasBanco, array, conforme padrão QualityAPIManager():MontaItensRetorno() com Mapa de Campos da API ResultadosEnsaiosInspecaoDeProcessosAPI
/*/
Method RetornaAmostrasBanco(nRecnoInspecao) CLASS QIPEnsaiosCalculados 

	Local aAmostrasBanco := {}
	Local cAlias         := Nil
	Local cOrdem         := "testID,sampleNumber,measurementDate,measurementTime,recno"
	Local nPagina        := 1
	Local nTamPag        := 99999999999
	
	Self:oAPIResultados                         := ResultadosEnsaiosInspecaoDeProcessosAPI():New()
	Self:oAPIResultados:oAPIManager:aMapaCampos := Self:oAPIResultados:MapeiaCamposAPI("*")
	If (Self:oAPIResultados:CriaAliasResultadosInspecaoPorEnsaio(nRecnoInspecao, cOrdem, Nil, Self:cOperacao, nPagina, nTamPag, Nil, @cAlias, Self:oAPIResultados:oAPIManager))
		aAmostrasBanco := Self:oAPIResultados:oAPIManager:MontaItensRetorno(cAlias, nPagina, nTamPag)
	EndIf

    (cAlias)->(dbCloseArea())
	
Return aAmostrasBanco

/*/{Protheus.doc} RetornaEnsaiosCalculados
Retorna Ensaios Calculados
@author brunno.costa
@since  30/10/2024
@param 01 - nRecnoInspecao, numérico, número do recno da inspeção na QPK
@return aEnsCalc, array, array com objetos Json contendo os itens calculados: 
{ [ testID, 
	letter, 
	formula, 
	arithmeticFormula,
	nominalValue, 
	quantity, 
	results], ...}

Sendo results Array com as Medições conforme quantidade de medições do ensaio
/*/
Method RetornaEnsaiosCalculados(nRecnoInspecao) CLASS QIPEnsaiosCalculados 

	Local aEnsCalc      := {}
	Local cAlias        := Nil
	Local cQuery        := ""
	Local oExec         := Nil
	Local oItem         := Nil
	Local oQueryManager := QLTQueryManager():New()

	cQuery += " SELECT QP7.QP7_ENSAIO, QP1.QP1_CARTA, QP7.QP7_FORMUL, QP7.QP7_NOMINA, QP1.QP1_QTDE, RECNOQP7, QP7_MINMAX, QP7_LIE, QP7_LSE "
	cQuery += " FROM "
	cQuery +=      " (SELECT QPK_PRODUT, QPK_REVI, QPK_OP "
	cQuery +=       " FROM " + RetSQLName("QPK")
	cQuery +=       " WHERE "
	cQuery +=  	            " (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
	cQuery +=           " AND (D_E_L_E_T_ = ' ') "
	cQuery +=  	   " ) QPK "
	cQuery += " INNER JOIN "
	cQuery +=      " (SELECT QP7_PRODUT, QP7_REVI, QP7_ENSAIO, QP7_NOMINA, QP7_CODREC, QP7_FORMUL, R_E_C_N_O_ RECNOQP7, QP7_MINMAX, QP7_LIE, QP7_LSE "
	cQuery +=       " FROM " + RetSQLName("QP7")
	cQuery +=       " WHERE "
	cQuery +=  	            " (QP7_FILIAL = '" + xFilial("QP7") + "') "
	cQuery +=  	        " AND (QP7_FORMUL <> ' ')  "
	cQuery +=           " AND (D_E_L_E_T_ = ' ') "
	cQuery +=  	   " ) QP7 "
	cQuery += " ON      QP7.QP7_PRODUT = QPK.QPK_PRODUT "
	cQuery +=     " AND QP7.QP7_REVI   = QPK.QPK_REVI "
	cQuery += " INNER JOIN "
	cQuery +=  	    " (SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
	cQuery +=        " FROM " + RetSQLName("SC2")
	cQuery +=        " WHERE "
	cQuery +=  	             " (C2_FILIAL = '" + xFilial("SC2") + "') "
	cQuery +=            " AND (D_E_L_E_T_ = ' ') "
	cQuery +=  	     " ) SC2 "
	cQuery +=      " ON " + oQueryManager:MontaRelationC2OP("QPK.QPK_OP")
	cQuery +=      Iif(SuperGetMV("MV_QIPOPEP") == "3", " AND (QP7.QP7_CODREC = C2_ROTEIRO OR QP7.QP7_CODREC = '" + QIPRotGene("QP7_CODREC") + "') ", " AND QP7.QP7_CODREC = C2_ROTEIRO ")

	cQuery += " LEFT OUTER JOIN "
	cQuery +=       " (SELECT QP1_ENSAIO, QP1_CARTA, "
	cQuery +=                " (CASE QP1_CARTA  "
	cQuery +=                " WHEN 'XBR' THEN QP1_QTDE  "
	cQuery +=                " WHEN 'XBS' THEN QP1_QTDE  "
	cQuery +=                " WHEN 'XMR' THEN QP1_QTDE  "
	cQuery +=                " WHEN 'HIS' THEN QP1_QTDE  "
	cQuery +=                " WHEN 'NP ' THEN 1  "
	cQuery +=                " WHEN 'P  ' THEN 3  "
	cQuery +=                " WHEN 'U  ' THEN 2  "
	cQuery +=                " ELSE 1  "
	cQuery +=                " END) QP1_QTDE "
	cQuery +=        " FROM " + RetSQLName("QP1")
	cQuery +=        " WHERE "
	cQuery +=         	     " (QP1_FILIAL = '" + xFilial("QP1") + "') "
	cQuery +=        	 " AND (QP1_TIPO   = 'C') "
	cQuery +=            " AND (D_E_L_E_T_ = ' ') "
	cQuery +=  	   " AND RTRIM(QP1_CARTA) IN ('XBR','XBS','IND','XMR','HIS','TMP') "
	cQuery +=  	    " ) QP1 "
	cQuery += " ON QP7.QP7_ENSAIO = QP1.QP1_ENSAIO "

	cQUery := oQueryManager:changeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()

	While (cAlias)->(!Eof())
		oItem := JsonObject():New()
		oItem["letter"]                   := (cAlias)->QP1_CARTA
		oItem["testID"]                   := (cAlias)->QP7_ENSAIO
		oItem["formula"]                  := (cAlias)->QP7_FORMUL
		oItem["nominalValue"]             := (cAlias)->QP7_NOMINA
		oItem["quantity"]                 := (cAlias)->QP1_QTDE
		oItem["recnoTest"]                := (cAlias)->RECNOQP7
		oItem["controlType"]              := (cAlias)->QP7_MINMAX
		oItem["lowerDeviation"]           := (cAlias)->QP7_LIE
		oItem["upperDeviation"]           := (cAlias)->QP7_LSE
		oItem["results"]                  := {}
		oItem["arithmeticFormula"]        := {}
		oItem["partialArithmeticFormula"] := {}
		aAdd(aEnsCalc, oItem )
		(cAlias)->(DbSkip())
	EndDo


Return aEnsCalc





