#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA200()
Rotina que recalcula o valor do Time Sheet, retornando a moeda e o valor 
dos honorários.

@Param  cCodTS    Código do Time Sheet
        cPartAlt  Código do Participante
        cClienAlt Código do Cliente
        cLojaAlt  Código do Loja
        cCasoAlt  Código do Caso
        cAMAlt    Ano mês do TS
        cTabH     Código da Tabela de Honorários
        cAtivi    Código do Tipo de Atividade

@Return aRet      Retorna array com: 
				  aRet[1] - moeda do TimeSheet;  
				  aRet[2] - Valor Hora do TimeSheet; 
				  aRet[3] - Categoria do participante;

@author Luciano Pereira dos Santos

@since 20/06/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA200(cCodTS, cPartAlt, cClienAlt, cLojaAlt, cCasoAlt, cAMAlt, cTabH, cAtivi)
Local aArea         := GetArea()
Local nValorH       := 0
Local cMoeda        := ""
Local cCliente      := ""
Local cloja         := ""
Local cCasos        := ""
Local cCat          := ""
Local cAnoMes       := ""
Local cPart2        := ""
Local nVlTemp       := 0
Local cRegra        := ""
Local cExcCat       := ""
Local nVlHnCaso     := 0
Local aRet          := {}
Local cQry1         := ""
Local cQryNUE       := GetNextAlias()
Local cQry2         := ""
Local cQryNUU       := ""
Local lOHOInDic     := .F.
Local lOHRInDic     := .F.
Local lExistOHR     := .F.
Local cTabCas       := ""

Default cPartAlt    := ""
Default cClienAlt   := ""
Default cLojaAlt    := ""
Default cCasoAlt    := ""
Default cAMAlt      := ""
Default cTabH       := ""
Default cAtivi      := ""

lOHOInDic := FWAliasInDic("OHO") .And. !Empty(cAtivi)
lOHRInDic := FWAliasInDic("OHR") .And. !Empty(cAtivi)

If !Empty(cPartAlt) .And. !Empty(cClienAlt) .And. !Empty(cLojaAlt) .And. !Empty(cCasoAlt) .And. !Empty(cAMAlt)

	// Seleciona o Time Sheet com as informações necessárias
	cQry1 := "SELECT '" + cPartAlt + "' NUE_CPART2, '" + cClienAlt + "' NUE_CCLIEN, '" + cLojaAlt + "' NUE_CLOJA, '" + cCasoAlt + "' NUE_CCASO, '" + cAMAlt + "' NUE_ANOMES, "
	If Empty(cTabH)
		cQry1 += "NUU.NUU_CTABH, NUU.NUU_TPHORA, NTU.NTU_VALORH, NTV.NTV_COD, NTV.NTV_CMOEDA, NUS.NUS_CCAT, "
	Else
		cQry1 += " '" + cTabH + "' NUU_CTABH, NUU.NUU_TPHORA, NTU.NTU_VALORH, NTV.NTV_COD, NTV.NTV_CMOEDA, NUS.NUS_CCAT, "
	EndIf
	cQry1 += "NUW.NUW_REGRA, NUW.NUW_VALOR2, NV0.NV0_REGRA, NV0.NV0_EXCCAT, NV0.NV0_VALOR2, NV0.NV0_CCAT "
	If lOHOInDic
		cQry1 += ", OHO.OHO_REGRA, OHO.OHO_VALOR "
	EndIf
	If lOHRInDic
		cQry1 += ", OHR.OHR_REGRA, OHR.OHR_VALOR "
	EndIf
	
	cQry1 += "FROM " + RetSqlName("NUS") + " NUS "   // histórico do participante
	
	cQry1 += "INNER JOIN " + RetSqlName("NTU") + " NTU "  // histórico de honorários por categoria
	cQry1 +=    "ON NTU.NTU_FILIAL = '" + xFilial("NTU") + "' "
	cQry1 +=   "AND NTU.NTU_CCAT = NUS.NUS_CCAT "
	If !Empty(cTabH)
		cQry1 +=   "AND NTU.NTU_CTAB = '" + cTabH + "' "
	EndIf
	cQry1 +=   "AND NTU.D_E_L_E_T_ = ' ' "
	
	cQry1 += "INNER JOIN " + RetSqlName("NTV") + " NTV "  // histórico da tabela de honorários
	cQry1 +=    "ON NTV.NTV_FILIAL = '" + xFilial("NTV") + "' "
	cQry1 +=   "AND NTV.NTV_COD = NTU.NTU_CHIST "
	If !Empty(cTabH)
		cQry1 +=   "AND NTV.NTV_CTAB = '" + cTabH + "' "
	EndIf
	cQry1 +=   "AND NTV.D_E_L_E_T_ = ' ' "
	
	cQry1 += "INNER JOIN " + RetSqlName("NUU") + " NUU " // histórico do caso 
	cQry1 +=    "ON NUU.NUU_FILIAL = '" + xFilial("NUU") + "' "
	cQry1 +=   "AND NUU.NUU_CCLIEN = '" + cClienAlt + "' "
	cQry1 +=   "AND NUU.NUU_CLOJA  = '" + cLojaAlt + "' "
	cQry1 +=   "AND NUU.NUU_CCASO  = '" + cCasoAlt + "' "
	If Empty(cTabH) 
		cQry1 +=   "AND NUU.NUU_CTABH = NTV.NTV_CTAB "
		cQry1 +=   "AND NUU.NUU_CTABH = NTU.NTU_CTAB "
	EndIf
	cQry1 +=   "AND NUU.D_E_L_E_T_ = ' ' "
	
	cQry1 += "LEFT JOIN " +  RetSqlName("NUW") + " NUW "  // histórico de exceção da tabela de honorários Categoria (não obrigatório)  
	cQry1 +=    "ON NUW.NUW_FILIAL = '" + xFilial("NUW") + "' "
	cQry1 +=   "AND NUW.NUW_CCLIEN = '" + cClienAlt + "' "
	cQry1 +=   "AND NUW.NUW_CLOJA  = '" + cLojaAlt + "' "
	cQry1 +=   "AND NUW.NUW_CCASO  = '" + cCasoAlt + "' "
	cQry1 +=   "AND NUW_CCAT = NUS_CCAT "
	cQry1 +=   "AND (( NUW.NUW_AMINI <= '" + cAMAlt + "' "
	cQry1 +=   "AND NUW.NUW_AMFIM = '" + Space(TamSx3('NUW_AMFIM')[1]) + "') OR "
	cQry1 +=     "( NUW.NUW_AMINI <= '" + cAMAlt + "' "
	cQry1 +=   "AND NUW.NUW_AMFIM >= '" + cAMAlt + "')) "
	cQry1 +=   "AND NUW.D_E_L_E_T_ = ' ' "
	
	cQry1  += "LEFT JOIN " +  RetSqlName("NV0") + " NV0 " // histórico de exceção da tabela de honorários Participante (não obrigatório)  
	cQry1  +=   "ON NV0.NV0_FILIAL = '" + xFilial("NV0") + "' "
	cQry1  +=  "AND NV0.NV0_CCLIEN = '" + cClienAlt + "' "
	cQry1  +=  "AND NV0.NV0_CLOJA  = '" + cLojaAlt + "' "
	cQry1  +=  "AND NV0.NV0_CCASO  = '" + cCasoAlt + "' "
	cQry1  +=  "AND NV0.NV0_CPART = '" + cPartAlt + "' "
	cQry1  +=  "AND (( NV0.NV0_AMINI <= '" + cAMAlt + "' "
	cQry1  +=  "AND NV0.NV0_AMFIM = '" + Space(TamSx3('NV0_AMFIM')[1]) + "') OR "
	cQry1  +=    "( NV0.NV0_AMINI <= '" + cAMAlt + "' "
	cQry1  +=  "AND NV0.NV0_AMFIM >= '" + cAMAlt + "' )) "
	cQry1  +=  "AND NV0.D_E_L_E_T_ = ' ' "

	If lOHOInDic
		cQry1 += "LEFT JOIN " +  RetSqlName("OHO") + " OHO " // Exceção de Valor por Tipo de Atividade no Cliente  
		cQry1  +=   "ON OHO.OHO_FILIAL = '" + xFilial("OHO") + "' "
		cQry1  +=  "AND OHO.OHO_CCLIEN = '" + cClienAlt + "' "
		cQry1  +=  "AND OHO.OHO_CLOJA  = '" + cLojaAlt + "' "
		cQry1  +=  "AND OHO.OHO_CATIVI  = '" + cAtivi + "' "
		cQry1  +=  "AND (( OHO.OHO_AMINI <= '" + cAMAlt + "' "
		cQry1  +=  "AND OHO.OHO_AMFIM = '" + Space(TamSx3('OHO_AMFIM')[1]) + "') OR "
		cQry1  +=    "( OHO.OHO_AMINI <= '" + cAMAlt + "' "
		cQry1  +=  "AND OHO.OHO_AMFIM >= '" + cAMAlt + "' )) "
		cQry1  +=  "AND OHO.D_E_L_E_T_ = ' ' "
	EndIf

	If lOHRInDic
		cQry1 += "LEFT JOIN " +  RetSqlName("OHR") + " OHR " // Exceção de Valor por Tipo de Atividade no Caso
		cQry1  +=   "ON OHR.OHR_FILIAL = '" + xFilial("OHR") + "' "
		cQry1  +=  "AND OHR.OHR_CCLIEN = '" + cClienAlt + "' "
		cQry1  +=  "AND OHR.OHR_CLOJA  = '" + cLojaAlt + "' "
		cQry1  +=  "AND OHR.OHR_CCASO  = '" + cCasoAlt + "' "
		cQry1  +=  "AND OHR.OHR_CATIVI = '" + cAtivi + "' "
		cQry1  +=  "AND (( OHR.OHR_AMINI <= '" + cAMAlt + "' "
		cQry1  +=  "AND OHR.OHR_AMFIM = '" + Space(TamSx3('OHR_AMFIM')[1]) + "') OR "
		cQry1  +=    "( OHR.OHR_AMINI <= '" + cAMAlt + "' "
		cQry1  +=  "AND OHR.OHR_AMFIM >= '" + cAMAlt + "' )) "
		cQry1  +=  "AND OHR.D_E_L_E_T_ = ' ' "
	EndIf
	
	cQry1 += "WHERE NUS.NUS_FILIAL = '" + xFilial("NUS") + "' "
	cQry1 +=   "AND (('" + cAMAlt + "' >= NUU.NUU_AMINI AND NUU.NUU_AMFIM = '" + Space(TamSx3('NUU_AMFIM')[1]) + "') OR "
	cQry1 +=        "('" + cAMAlt + "' BETWEEN NUU.NUU_AMINI AND NUU.NUU_AMFIM)) "
	cQry1 +=   "AND (('" + cAMAlt + "' >= NTV.NTV_AMINI AND NTV.NTV_AMFIM = '" + Space(TamSx3('NTV_AMFIM')[1]) + "') OR "
	cQry1 +=        "('" + cAMAlt + "' BETWEEN NTV.NTV_AMINI AND NTV.NTV_AMFIM)) "
	cQry1 +=   "AND (('" + cAMAlt + "' >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '" + Space(TamSx3('NUS_AMFIM')[1]) + "') OR "
	cQry1 +=        "('" + cAMAlt + "' BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "
	cQry1 +=   "AND NUS.NUS_CPART = '" + cPartAlt + "' "
	cQry1 +=   "AND NUS.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQry1 ), cQryNUE, .T., .F. )
	
	nValorH  := (cQryNUE)->NTU_VALORH
	cCliente := (cQryNUE)->NUE_CCLIEN
	cLoja    := (cQryNUE)->NUE_CLOJA
	cCasos   := (cQryNUE)->NUE_CCASO
	cCat     := (cQryNUE)->NUS_CCAT
	cAnoMes  := (cQryNUE)->NUE_ANOMES
	cPart2   := (cQryNUE)->NUE_CPART2
	If !Empty((cQryNUE)->NTV_CMOEDA)
		cMoeda  := (cQryNUE)->NTV_CMOEDA
	Else
		cTabCas := JurGetDados('NVE', 1, xFilial('NVE') + cClienAlt + cLojaAlt + cCasoAlt, 'NVE_CTABH')
		cMoeda  := JurGetDados('NRF', 1, xFilial('NRF') + cTabCas, 'NRF_MOEDA')
		aAdd(aRet, cMoeda)
		aAdd(aRet, nValorH)
		aAdd(aRet, cCat)
	EndIf

	While !(cQryNUE)->(EOF())
	
		nVlTemp := JurGetDados('NTT', 2, xFilial('NTT') + (cQryNUE)->NUU_CTABH + (cQryNUE)->NTV_COD + cPart2, 'NTT_VALORH')   // mudar indice 2 NTT_FILIAL+NTT_CTAB+NTT_CHIST+NTT_CPART
		
		If !Empty(nVlTemp) .And. nVlTemp != 0
			nValorH := nVlTemp
		EndIf
		
		If Empty(cTabH) 
		
			// Indica se existe exceção de valor por Tipo de Atividade no Caso
			lExistOHR := lOHRInDic .And. !Empty((cQryNUE)->OHR_REGRA)

			If !lExistOHR // Se não existir exceção de valor por Tipo de Atividade no Caso
				// Verifica a exceção de valor por Tipo de Atividade no Cliente
				If lOHOInDic .And. !Empty( (cQryNUE)->OHO_REGRA )
					cRegra  := (cQryNUE)->OHO_REGRA
					nVlTemp := (cQryNUE)->OHO_VALOR
					Do Case
						Case cRegra == "1" .And. nVlTemp != 0
							nValorH := nValorH + (nValorH * nVlTemp/100)
						Case cRegra == "2" .And. nVlTemp != 0
							nValorH := nValorH + nVlTemp
						Case cRegra == "3" .And. nVlTemp != 0
							nValorH := nVlTemp
					EndCase
				EndIf
			EndIf
		
			// verifica se existe exceção de honorários na tabela de Histórico do Caso
			If (cQryNUE)->NUU_TPHORA != " "
				
				cQry2  := "SELECT NUU.NUU_VLHORA "
				cQry2  +=       "FROM " + RetSqlName("NUU") + " NUU "
				cQry2  +=       "WHERE NUU.NUU_FILIAL = '" + xFilial("NUU") + "' "
				cQry2  +=         "AND NUU.NUU_CCASO  = '" + cCasos + "' "
				cQry2  +=         "AND NUU.NUU_CCLIEN = '" + cCliente + "' "
				cQry2  +=         "AND NUU.NUU_CLOJA  = '" + cloja + "' "
				cQry2  +=         "AND (( NUU.NUU_AMINI <= '"+ cAnoMes + "' "
				cQry2  +=                "AND NUU.NUU_AMFIM = '" + Space(TamSx3('NUU_AMFIM')[1])+"') OR "
				cQry2  +=                "('" + cAnoMes + "' BETWEEN NUU.NUU_AMINI AND NUU.NUU_AMFIM)) "
				cQry2  +=         "AND NUU.D_E_L_E_T_ = ' ' "
				
				cQryNUU := GetNextAlias()
				dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQry2 ), cQryNUU, .T., .F. )
				
				If !(cQryNUU)->(EOF())
					nVlTemp := (cQryNUU)->NUU_VLHORA
				Else
					nVlTemp := 0
				EndIf
				
				If (cQryNUE)->NUU_TPHORA == "1"
					nValorH := nVlTemp
				ElseIf ((cQryNUE)->NUU_TPHORA == "2") .And. (nVlTemp > 0) .And. ((cQryNUE)->NTU_VALORH > nVlTemp)
					nValorH := nVlTemp
				EndIf
			
				(cQryNUU)->( dbcloseArea() )
				
			EndIf

			// verifica se existe exceção de honorários na tabela de Categoria
			If !Empty( (cQryNUE)->NUW_REGRA )
				cRegra  := (cQryNUE)->NUW_REGRA
				nVlTemp := (cQryNUE)->NUW_VALOR2
			Else
				cRegra  := " "
				nVlTemp := 0
			EndIf
			
			nVlHnCaso := nValorH // guarda o valor de honorários da tabela de Histórico do Caso
			
			Do Case
				Case cRegra == "1" .And. nVlTemp != 0
					nValorH := nValorH + (nValorH * nVlTemp/100)
				Case cRegra == "2" .And. nVlTemp != 0
					nValorH := nValorH + nVlTemp
				Case cRegra == "3" .And. nVlTemp != 0
					nValorH := nVlTemp
			EndCase
			
			// verifica se existe exceção de honorários na tabela de Participante
			If !Empty( (cQryNUE)->NV0_REGRA )
				cRegra   := (cQryNUE)->NV0_REGRA
				nVlTemp  := (cQryNUE)->NV0_VALOR2
				cExcCat  := (cQryNUE)->NV0_EXCCAT
				If !Empty((cQryNUE)->NV0_CCAT)
					cCat := (cQryNUE)->NV0_CCAT
				EndIf 
					
			Else
				cRegra  := " "
				nVlTemp := 0
				cExcCat := " "
			EndIf
			
			Do Case
				Case cRegra == "1" .And. nVlTemp != 0 .And. cExcCat == "1"
					nValorH := nValorH + (nValorH * nVlTemp/100)
				Case cRegra == "1" .And. nVlTemp != 0 .And. cExcCat == "2"
					nValorH := nVlHnCaso + (nVlHnCaso * nVlTemp/100)
				Case cRegra == "2" .And. nVlTemp != 0 .And. cExcCat == "1"
					nValorH := nValorH + nVlTemp
				Case cRegra == "2" .And. nVlTemp != 0 .And. cExcCat == "2"
					nValorH := nVlHnCaso + nVlTemp
				Case cRegra == "3" .And. nVlTemp != 0
					nValorH := nVlTemp
				Case cRegra == "4"
					nValorH := J200TABVAL((cQryNUE)->NUU_CTABH, cCat, cExcCat, cAMAlt, cClienAlt, cLojaAlt , cCasoAlt, cPartAlt)
			EndCase

			// Verifica a exceção de valor por Tipo de Atividade no Cliente
			If lExistOHR
				cRegra  := (cQryNUE)->OHR_REGRA
				nVlTemp := (cQryNUE)->OHR_VALOR
				Do Case
					Case cRegra == "1" .And. nVlTemp != 0
						nValorH := nValorH + (nValorH * nVlTemp/100)
					Case cRegra == "2" .And. nVlTemp != 0
						nValorH := nValorH + nVlTemp
					Case cRegra == "3" .And. nVlTemp != 0
						nValorH := nVlTemp
				EndCase
			EndIf

		EndIf
		
		aAdd(aRet, cMoeda)
		aAdd(aRet, nValorH)
		aAdd(aRet, cCat)
	
		(cQryNUE)->(dbSkip())
		
	EndDo

	(cQryNUE)->( dbcloseArea() )

EndIf
	
If Empty(aRet)
	aRet := {CriaVar("NUE_CMOEDA", .F.), 0, CriaVar("NUE_CCATEG", .F.)}
EndIf

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J200TABVAL
Função utilizada para retornar o valor conforme tabela de honorários.

@author Mateus Ribeiro - Manutenção Prime
@since 19/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function J200TABVAL(cTabela, cCategoria, cExcCat, cAMAlt, cClienAlt, cLojaAlt , cCasoAlt, cPartAlt)
Local oQry         := Nil
Local cQuery       := ""
Local cQueryNUW    := ""
Local cRegra       := ""
Local nParam       := 0
Local nValor1      := 0 
Local nValor2      := 0
Local nValor       := 0
Local lAcumulativo := ( cExcCat == "1" )

	nValor := JA200VLCAT(cTabela, cCategoria, cAMAlt, cAMAlt, cPartAlt)

	If lAcumulativo
		cQuery := " SELECT NUW.NUW_REGRA,"
		cQuery +=        " NUU.NUU_VLHORA,"
		cQuery +=        " NUW.NUW_VALOR2 "
		cQuery +=   " FROM " + RetSqlName("NUW") + " NUW"
		cQuery +=   " LEFT JOIN " +  RetSqlName("NV0") + " NV0"
		cQuery +=     " ON NV0.NV0_FILIAL = ?" // #1
		cQuery +=    " AND NV0.NV0_CCLIEN = ?" // #2
		cQuery +=    " AND NV0.NV0_CLOJA  = ?" // #3
		cQuery +=    " AND NV0.NV0_CCASO  = ?" // #4
		cQuery +=    " AND NV0.NV0_CPART  = ?" // #5
		cQuery +=    " AND (( NV0.NV0_AMINI <= ?" // #6
		cQuery +=       " AND NV0.NV0_AMFIM = ?) OR" // #7
		cQuery +=         " ( NV0.NV0_AMINI <= ? AND NV0.NV0_AMFIM >= ?))" // #8 - #9
		cQuery +=    " AND NV0.D_E_L_E_T_ = ' '"
		cQuery +=  " INNER JOIN " + RetSqlName("NUU") + " NUU"
		cQuery +=     " ON NUU.NUU_FILIAL = NUW.NUW_FILIAL"
		cQuery +=    " AND NUU.NUU_CCLIEN = NUW.NUW_CCLIEN"
		cQuery +=    " AND NUU.NUU_CLOJA = NUW.NUW_CLOJA"
		cQuery +=    " AND NUU.NUU_CCASO = NUW.NUW_CCASO"
		cQuery +=    " AND NUU.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE NUW.NUW_CCAT = ?" //#10
		cQuery +=    " AND ((NUW.NUW_AMINI <= NV0.NV0_AMINI AND NUW.NUW_AMFIM >= NV0.NV0_AMINI) OR"
		cQuery +=         " (NUW.NUW_AMINI <= NV0.NV0_AMINI AND NUW.NUW_AMFIM = NV0.NV0_AMFIM))"
		cQuery +=    " AND NUW.D_E_L_E_T_ = ' '"

		cQueryNUW := GetNextAlias()
		oQry := FWPreparedStatement():New(cQuery)

		oQry:SetString(++nParam, xFilial("NV0"))                // #1
		oQry:SetString(++nParam, cClienAlt)                     // #2
		oQry:SetString(++nParam, cLojaAlt)                      // #3
		oQry:SetString(++nParam, cCasoAlt)                      // #4
		oQry:SetString(++nParam, cPartAlt)                      // #5
		oQry:SetString(++nParam, cAMAlt)                        // #6
		oQry:SetString(++nParam, Space(TamSx3('NV0_AMFIM')[1])) // #7
		oQry:SetString(++nParam, cAMAlt)                        // #8
		oQry:SetString(++nParam, cAMAlt)                        // #9
		oQry:SetString(++nParam, cCategoria)                    // #10

		cQuery := oQry:GetFixQuery()
		MpSysOpenQuery(cQuery, cQueryNUW)

		If !(cQueryNUW)->(EOF())
			cRegra 	:= (cQueryNUW)->NUW_REGRA
			nValor1	:= (cQueryNUW)->NUU_VLHORA
			nValor2	:= (cQueryNUW)->NUW_VALOR2

			Do Case
			Case cRegra == "1" // Percentual
				nValor := nValor1 + (nValor1 * (nValor2/100))
			Case cRegra == "2" // Soma
				nValor := nValor1 + nValor2
			Case cRegra == "3" // Fixo
				nValor := nValor2
			EndCase
		EndIf
	EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA200VLCAT
Retorna o valor hora da categoria na tabela de honorários e dentro do período
informado.

@author Mateus Ribeiro - Manutenção Prime
@since 19/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA200VLCAT(cTabh, cCateg, cAmIni, cAmFim, cPart)
Local oQry      := Nil
Local cAliasQry := GetNextAlias()
Local nValor    := 0
Local nParam    := 0
Local cSQL      := ""

Default cTabh   := ""
Default cCateg  := ""
Default cAmIni  := ""
Default cAmFim  := ""
Default cPart   := ""

If !Empty(cTabh) .And. !Empty(cCateg) .And. !Empty(cAmIni)

	cSQL := " SELECT NTU_VALORH, COALESCE(NTT_VALORH, 0) NTT_VALORH"
	cSQL +=   " FROM " + RetSqlname('NTV') + " NTV"
	cSQL +=  " INNER JOIN " + RetSqlname('NTU') + " NTU"
	cSQL +=     " ON NTU_FILIAL = ?" // #1
	cSQL +=    " AND NTU_CCAT = ?" // #2
	cSQL +=    " AND NTV_CTAB = NTU_CTAB"
	cSQL +=    " AND NTV_COD = NTU_CHIST"
	cSQL +=    " AND NTU.D_E_L_E_T_ = ' '"
	cSQL +=   " LEFT JOIN " + RetSqlname('NTT') + " NTT"
	cSQL +=     " ON NTT_FILIAL = ?" // #3
	cSQL +=    " AND NTT_CHIST = NTV_COD"
	cSQL +=    " AND NTT_CPART = ?" // #4
	cSQL +=    " AND NTT.D_E_L_E_T_ = ' '"
	cSQL +=  " WHERE NTV_FILIAL = ?" // #5
	cSQL +=    " AND NTV_CTAB = ?" // #6
	cSQL +=    " AND ((NTV_AMINI <= ? AND NTV_AMFIM >= ?) OR" // #7 - #8
	cSQL +=        " (NTV_AMINI <= ? AND(NTV_AMFIM = ? OR NTV_AMFIM = ?)))"// #9 - #10 - #11
	cSQL +=    " AND NTV.D_E_L_E_T_ = ' '"
   

	oQry := FWPreparedStatement():New(cSQL)

	oQry:SetString(++nParam, xFilial("NTU"))            // #1
	oQry:SetString(++nParam, cCateg)                    // #2
	oQry:SetString(++nParam, xFilial("NTT"))            // #3
	oQry:SetString(++nParam, cPart)                     // #4
	oQry:SetString(++nParam, xFilial("NTV"))            // #5
	oQry:SetString(++nParam, cTabh)                     // #6
	oQry:SetString(++nParam, cAmIni)                    // #7
	oQry:SetString(++nParam, cAmIni)                    // #8
	oQry:SetString(++nParam, cAmIni)                    // #9
	oQry:SetString(++nParam, cAmFim)                    // #10
	oQry:SetString(++nParam, CriaVar("NTV_AMFIM", .F.)) // #11

	cSQL := oQry:GetFixQuery()
	MpSysOpenQuery(cSQL, cAliasQry)

	If !(cAliasQry)->(Eof())
		If (cAliasQry)->NTT_VALORH > 0
			nValor := (cAliasQry)->NTT_VALORH
		Else
			nValor := (cAliasQry)->NTU_VALORH
		EndIf
	EndIf
EndIf

Return nValor
