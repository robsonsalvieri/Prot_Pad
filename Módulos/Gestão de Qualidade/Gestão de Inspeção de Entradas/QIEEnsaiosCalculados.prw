#INCLUDE "TOTVS.CH"

CLASS QIEEnsaiosCalculados FROM QLTEnsaiosCalculados
	
	Method New(nRecnoInspecao, aAmostrasMemoria, lConsideraDB)

	//Métodos Internos
	Method RetornaAmostrasBanco(nRecnoInspecao)
	Method RetornaEnsaiosCalculados(nRecnoInspecao)

EndClass

Method New(nRecnoInspecao, aAmostrasMemoria, lConsideraDB) CLASS QIEEnsaiosCalculados
	
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

	Self:aAmostrasBanco     := Iif(lConsideraDB, Self:RetornaAmostrasBanco(nRecnoInspecao), {})
	Self:nTamMedicao        := GetSx3Cache("QES_MEDICA", "X3_TAMANHO")

	_Super:new(nRecnoInspecao, aAmostrasMemoria, lConsideraDB)

Return

/*/{Protheus.doc} RetornaAmostrasBanco
Retorna Amostras de Resultados do Banco referente nRenoInspecao
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoInspecao, numérico, número do recno da inspeção na QEK
@return aAmostrasBanco, array, conforme padrão QualityAPIManager():MontaItensRetorno() com Mapa de Campos da API ResultadosEnsaiosInspecaoDeEntradasAPI
/*/
Method RetornaAmostrasBanco(nRecnoInspecao) CLASS QIEEnsaiosCalculados 

	Local aAmostrasBanco := {}
	Local cAlias         := Nil
	Local cOrdem         := "testID,sampleNumber,measurementDate,measurementTime,recno"
	Local nPagina        := 1
	Local nTamPag        := 99999999999
	
	Self:oAPIResultados                         := ResultadosEnsaiosInspecaoDeEntradasAPI():New()
	Self:oAPIResultados:oAPIManager:aMapaCampos := Self:oAPIResultados:MapeiaCamposAPI("*")
	If (Self:oAPIResultados:CriaAliasResultadosInspecaoPorEnsaio(nRecnoInspecao, cOrdem, Nil, nPagina, nTamPag, Nil, @cAlias, Self:oAPIResultados:oAPIManager))
		aAmostrasBanco := Self:oAPIResultados:oAPIManager:MontaItensRetorno(cAlias, nPagina, nTamPag)
	EndIf

    (cAlias)->(dbCloseArea())
	
Return aAmostrasBanco

/*/{Protheus.doc} RetornaEnsaiosCalculados
Retorna Ensaios Calculados
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoInspecao, numérico, número do recno da inspeção na QEK
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
Method RetornaEnsaiosCalculados(nRecnoInspecao) CLASS QIEEnsaiosCalculados 

	Local aEnsCalc      := {}
	Local cAlias        := Nil
	Local cQuery        := ""
	Local oExec         := Nil
	Local oItem         := Nil
	Local oQueryManager := QLTQueryManager():New()

	cQuery += " SELECT QE7.QE7_ENSAIO, QE1.QE1_CARTA, QE7.QE7_FORMUL, QE7.QE7_NOMINA, QE1.QE1_QTDE, RECNOQE7, QE7_MINMAX, QE7_LIE, QE7_LSE "
	cQuery += " FROM "
	cQuery +=      " (SELECT QEK_PRODUT, QEK_REVI "
	cQuery +=       " FROM " + RetSQLName("QEK")
	cQuery +=       " WHERE "
	cQuery +=  	            " (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
	cQuery +=           " AND (D_E_L_E_T_ = ' ') "
	cQuery +=  	   " ) QEK "
	cQuery += " INNER JOIN "
	cQuery +=      " (SELECT QE7_PRODUT, QE7_REVI, QE7_ENSAIO, QE7_NOMINA, QE7_FORMUL, R_E_C_N_O_ RECNOQE7, QE7_MINMAX, QE7_LIE, QE7_LSE "
	cQuery +=       " FROM " + RetSQLName("QE7")
	cQuery +=       " WHERE "
	cQuery +=  	            " (QE7_FILIAL = '" + xFilial("QE7") + "') "
	cQuery +=  	        " AND (QE7_FORMUL <> ' ')  "
	cQuery +=           " AND (D_E_L_E_T_ = ' ') "
	cQuery +=  	   " ) QE7 "
	cQuery += " ON      QE7.QE7_PRODUT = QEK.QEK_PRODUT "
	cQuery +=     " AND QE7.QE7_REVI   = QEK.QEK_REVI "

	cQuery += " LEFT OUTER JOIN "
	cQuery +=       " (SELECT QE1_ENSAIO, QE1_CARTA, "
	cQuery +=                " (CASE QE1_CARTA  "
	cQuery +=                " WHEN 'XBR' THEN QE1_QTDE  "
	cQuery +=                " WHEN 'XBS' THEN QE1_QTDE  "
	cQuery +=                " WHEN 'XMR' THEN QE1_QTDE  "
	cQuery +=                " WHEN 'HIS' THEN QE1_QTDE  "
	cQuery +=                " WHEN 'NP ' THEN 1  "
	cQuery +=                " WHEN 'P  ' THEN 3  "
	cQuery +=                " WHEN 'U  ' THEN 2  "
	cQuery +=                " ELSE 1  "
	cQuery +=                " END) QE1_QTDE "
	cQuery +=        " FROM " + RetSQLName("QE1")
	cQuery +=        " WHERE "
	cQuery +=         	     " (QE1_FILIAL = '" + xFilial("QE1") + "') "
	cQuery +=        	 " AND (QE1_TIPO   = '1') "
	cQuery +=            " AND (D_E_L_E_T_ = ' ') "
	cQuery +=  	   " AND RTRIM(QE1_CARTA) IN ('XBR','XBS','IND','XMR','HIS','TMP') "
	cQuery +=  	    " ) QE1 "
	cQuery += " ON QE7.QE7_ENSAIO = QE1.QE1_ENSAIO "

	cQUery := oQueryManager:changeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()

	While (cAlias)->(!Eof())
		oItem := JsonObject():New()
		oItem["letter"]                   := (cAlias)->QE1_CARTA
		oItem["testID"]                   := (cAlias)->QE7_ENSAIO
		oItem["formula"]                  := (cAlias)->QE7_FORMUL
		oItem["nominalValue"]             := (cAlias)->QE7_NOMINA
		oItem["quantity"]                 := (cAlias)->QE1_QTDE
		oItem["recnoTest"]                := (cAlias)->RECNOQE7
		oItem["controlType"]              := (cAlias)->QE7_MINMAX
		oItem["lowerDeviation"]           := (cAlias)->QE7_LIE
		oItem["upperDeviation"]           := (cAlias)->QE7_LSE
		oItem["results"]                  := {}
		oItem["arithmeticFormula"]        := {}
		oItem["partialArithmeticFormula"] := {}
		aAdd(aEnsCalc, oItem )
		(cAlias)->(DbSkip())
	EndDo


Return aEnsCalc
