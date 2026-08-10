#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

/*/{Protheus.doc} MrpDominio_HorizonteFirme
Regras de negocio MRP - Horizonte Firme
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDominio_HorizonteFirme FROM LongClassName

	METHOD new() CONSTRUCTOR
	METHOD criaScriptIN(dDataIni, cTabela, cCpoProd, cCpoData, cWhere, cScriptIN, oDominio)

ENDCLASS

/*/{Protheus.doc} MrpDominio_HorizonteFirme
Construtor da Classe Horizonte Firme
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
METHOD new() CLASS MrpDominio_HorizonteFirme
Return Self

/*/{Protheus.doc} criaScriptIN
Gera Script para Filtro dos Registros para Exclusão em SQL Server
@author    brunno.costa
@since     11/05/2020
@version   1
@param 01 dDataIni  , data, data de processamento do MRP
@param 02 cTabela   , caracter, alias da tabela referencia para identificação dos RECNOS
@param 03 cCpoProd  , caracter, campo produto da tabela cAlias
@param 04 cCpoData  , caracter, campo data para comparação da tabela cAlias
@param 05 cWhere    , caracter, condição compementar do bloco where
@param 06 cScript , caracter, retorna por referência complemento de WHERE XX_CAMPO IN (cScriptIN)
@param 07 oDominio  , Object  , instância da classe de domínio do MRP (MRPDominio).
@return cScript, caracter, complemento de WHERE XX_CAMPO IN (cScript)
/*/
METHOD criaScriptIN(dDataIni, cTabela, cCpoProd, cCpoData, cWhere, cScript, oDominio) CLASS MrpDominio_HorizonteFirme
	Local cAlias     := cTabela + "_1"
	Local cBanco     := TCGetDB()
	Local cDataIni   := DtoS(dDataIni)
	Local cCmpFil    := cTabela + "_FILIAL"
	Local lUsaME     := oDominio:oMultiEmp:utilizaMultiEmpresa()
	Local nIndex     := 0
	
	Default cScript := ""

	If Left(cCmpFil, 1) == "S"
		cCmpFil := SubStr(cCmpFil, 2)
	EndIf

	cScript += " SELECT " + cAlias + ".R_E_C_N_O_ RECNO "
	cScript +=   " FROM " + RetSqlName(cTabela) + " " + cAlias
	If oDominio:oParametros["lUsesProductIndicator"]
		cScript += " LEFT OUTER JOIN " + RetSqlName("HWA") + " HWA "
	Else
		cScript += " INNER JOIN " + RetSqlName("HWA") + " HWA "
	EndIf
	cScript +=     " ON HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"
	cScript +=    " AND HWA.HWA_PROD   = " + cAlias + "." + cCpoProd
	cScript +=    " AND HWA.D_E_L_E_T_ = ' ' "

	If oDominio:oParametros["lUsesProductIndicator"]
		//Adiciona JOIN com a HWE quando configurado.
		cScript += " LEFT OUTER JOIN " + RetSqlName("HWE") + " HWE "
		cScript +=   " ON HWE.HWE_PROD   = " + cAlias + "." + cCpoProd
		cScript +=  " AND HWE.D_E_L_E_T_ = ' ' "

		If lUsaME
			cScript += " AND ("
			
			For nIndex := 1 To oDominio:oMultiEmp:totalDeFiliais()
				If nIndex > 1 
					cScript += " OR "
				EndIf

				cScript += " ( "
				cScript +=        " HWE.HWE_FILIAL = '" + xFilial("HWE", oDominio:oMultiEmp:filialPorIndice(nIndex)) + "' "
				cScript +=    " AND " + cAlias + "." + cCmpFil + " = '" + xFilial(cTabela, oDominio:oMultiEmp:filialPorIndice(nIndex)) + "' "
				cScript += " )"
			Next nIndex 

			cScript += " )"
		Else
			cScript += " AND HWE.HWE_FILIAL = '" + xFilial("HWE") + "' "
		EndIf
		
		cScript +=  " WHERE ( (HWE.HWE_PROD IS NOT NULL "
		cScript +=      " AND COALESCE(HWE.HWE_TPHFIX, ' ') <> ' ' "
		cScript +=      " AND COALESCE(HWE.HWE_HORFIX, 0) > 0) "
		cScript +=       " OR (HWE.HWE_PROD IS NULL "
		cScript +=      " AND HWA.HWA_PROD IS NOT NULL "
		cScript +=      " AND COALESCE(HWA.HWA_TPHFIX, ' ') <> ' ' "
		cScript +=      " AND COALESCE(HWA.HWA_HORFIX, 0) > 0) "
		cScript +=        " ) AND " //Somente produtos que possuem o parâmetro de horizonte firme configurado
	Else 
		cScript +=  " WHERE COALESCE(HWA.HWA_TPHFIX, ' ') <> ' ' "
		cScript +=    " AND COALESCE(HWA.HWA_HORFIX, 0) > 0 AND "
	EndIf

	If !Empty(cWhere)
		cWhere    := StrTran(cWhere, " D_E_L_E_T_", " " + cAlias + ".D_E_L_E_T_") + " AND "
		cScript += StrTran(cWhere, cTabela + ".", cAlias + ".")
	EndIf

	//Adiciona a condição de data conforme parametrização do horizonte firme.
	If cBanco == "ORACLE"
		cScript += "("
		cScript += "TO_DATE(" + cAlias + "." + cCpoData + ", 'YYYYMMDD') <= "

		cScript += "(CASE WHEN [HWA.HWA_TPHFIX] = '1' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [HWA.HWA_HORFIX]) "
		cScript +=      " WHEN [HWA.HWA_TPHFIX] = '2' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + ([HWA.HWA_HORFIX] * 7 ) ) "
		cScript +=      " WHEN [HWA.HWA_TPHFIX] = '3' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + ([HWA.HWA_HORFIX] * 30) ) "
		cScript +=      " ELSE (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + ([HWA.HWA_HORFIX] * 365) ) "
		cScript += " END) "
		cScript += ")"

	ElseIf cBanco == "POSTGRES"
		cScript += "("
		cScript += "TO_DATE(" + cAlias + "." + cCpoData + ", 'YYYYMMDD') <= "

		cScript += "(CASE WHEN [HWA.HWA_TPHFIX] = '1' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [HWA.HWA_HORFIX]*interval'1 days' ) "
		cScript +=      " WHEN [HWA.HWA_TPHFIX] = '2' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [HWA.HWA_HORFIX]*interval'1 weeks' ) "
		cScript +=      " WHEN [HWA.HWA_TPHFIX] = '3' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [HWA.HWA_HORFIX]*interval'1 months' ) "
		cScript +=      " ELSE (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [HWA.HWA_HORFIX]*interval'1 years' ) "
		cScript += " END) "
		cScript += ")"

	Else
		cScript += "("
		cScript += "CONVERT(DATETIME, " + cAlias + "." + cCpoData + ") <= "

		cScript += "(CASE WHEN [HWA.HWA_TPHFIX] = '1' THEN (CONVERT(DATETIME, '" + cDataIni + "') + [HWA.HWA_HORFIX]) "
		cScript +=      " WHEN [HWA.HWA_TPHFIX] = '2' THEN (CONVERT(DATETIME, '" + cDataIni + "') + ([HWA.HWA_HORFIX] * 7 ) ) "
		cScript +=      " WHEN [HWA.HWA_TPHFIX] = '3' THEN (CONVERT(DATETIME, '" + cDataIni + "') + ([HWA.HWA_HORFIX] * 30) ) "
		cScript +=      " ELSE (CONVERT(DATETIME, '" + cDataIni + "') + ([HWA.HWA_HORFIX] * 365) ) "
		cScript += " END) "
		cScript += ")"

	EndIf

	//Ajusta os comandos [HWA.HWA_TPHFIX] e [HWA.HWA_HORFIX] de acordo com o parâmetro da tabela HWE
	If oDominio:oParametros["lUsesProductIndicator"]
		//Substitui [HWA.HWA_HORFIX] por COALESCE(HWE.HWE_HORFIX,HWA.HWA_HORFIX)
		//Substitui [HWA.HWA_TPHFIX] por COALESCE(HWE.HWE_TPHFIX,HWA.HWA_TPHFIX)
		cScript := StrTran(cScript, "[HWA.HWA_HORFIX]", "COALESCE(HWE.HWE_HORFIX,HWA.HWA_HORFIX)"  )
		cScript := StrTran(cScript, "[HWA.HWA_TPHFIX]", "COALESCE(HWE.HWE_TPHFIX,HWA.HWA_TPHFIX)")
	Else
		//Substitui [HWA.HWA_HORFIX] por HWA.HWA_HORFIX
		//Substitui [HWA.HWA_TPHFIX] por HWA.HWA_TPHFIX
		cScript := StrTran(cScript, "[HWA.HWA_HORFIX]", "HWA.HWA_HORFIX" )
		cScript := StrTran(cScript, "[HWA.HWA_TPHFIX]", "HWA.HWA_TPHFIX")
	EndIf

Return cScript

