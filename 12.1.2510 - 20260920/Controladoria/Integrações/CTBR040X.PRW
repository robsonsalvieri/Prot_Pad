#INCLUDE "Protheus.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "TBICONN.ch"
#include "CTBR040X.ch"


Function movimContS(ctempCon,cFilIni,cFilFinal,cDataIni,cDataFim,cContaIni,cContaFim,cCustoIni,cCustoFim,cItemIni,cItemFim,cClasseIn,cClasseFi,cEnt05Ini,cEnt05Fim,cEnt06Ini,cEnt06Fim,cEnt07Ini,cEnt07Fim,cEnt08Ini,cEnt08Fim,cEnt09Ini,cEnt09Fim,cMoeda,cTPSaldo)
	Local cMsg 		 := ""	as character
	Local nStatusCod := 0	as Numeric
	Local cQuery	 := ""	as character
	Local oJBalanc 	 := JsonObject():new() as object	
	Local oPrepared  as Object
	Local nParamOrd  := 1  as Numeric
	Local ntamCt2    as Numeric
	Local ntamCto    as Numeric
	Local cFunSub    := 'SUBSTR' as character
	Local nTamTFil   := TamSX3('CT2_FILIAL')[01] as Numeric
	Local cReplicaT  := 'RPAD' as character
	Local cDbInUse   := TcGetDb() as character
	Local cSoma      := ' || ' as character
	Local cCpEnt05   := "''"  as character
	Local cCpEnt06   := "''"  as character
	Local cCpEnt07   := "''"  as character
	Local cCpEnt08   := "''"  as character
	Local cCpEnt09   := "''"  as character
	Local lFdPos05   := CT2->(FieldPos("CT2_EC05CR")) > 0 as logical 
	Local lFdPos06   := CT2->(FieldPos("CT2_EC06CR")) > 0 as logical 
	Local lFdPos07   := CT2->(FieldPos("CT2_EC07CR")) > 0 as logical 
	Local lFdPos08   := CT2->(FieldPos("CT2_EC08CR")) > 0 as logical 
	Local lFdPos09   := CT2->(FieldPos("CT2_EC09CR")) > 0 as logical 
	
	DEFAULT ctempCon := ""

	oPrepared := NIL

	If cDbInUse $ "ORACLE" 
		cReplicaT := 'RPAD'
	Else
		cFunSub   := "SUBSTRING"
		If cDbInUse $ "POSTGRES"
			cReplicaT := 'REPEAT'
		Else
			cSoma := ' + '
			cReplicaT  := 'REPLICATE'
		EndIf
	EndIf

	ntamCt2 := tamFil040("CT2")
	ntamCto := tamFil040("CTO")

	DbSelectArea("CT2")	
	cQuery:= " SELECT " + CRLF
	cQuery+= " 		FILIAL, " + CRLF
	cQuery+= "		CTO.CTO_DESC AS MOEDA, " + CRLF
	cQuery+= "		CONTA, " + CRLF
	cQuery+= "		CENTRO_CUSTO, " + CRLF
	cQuery+= "		ITEM_CONTABIL, " + CRLF
	cQuery+= "		CLASSE_VALOR, " + CRLF
	cQuery+= "		ENT05, " + CRLF
	cQuery+= "		ENT06, " + CRLF
	cQuery+= "		ENT07, " + CRLF
	cQuery+= "		ENT08, " + CRLF
	cQuery+= "		ENT09, " + CRLF
	cQuery+= "		DELETADO, " + CRLF
	cQuery+= "		SUM(SALDO) SALDO " + CRLF
	cQuery+= "		FROM  " + CRLF
	cQuery+= "		(SELECT  " + CRLF
	cQuery+= "			CT2_FILIAL				AS FILIAL, " + CRLF
	cQuery+= "			CT2.CT2_MOEDLC AS MOEDA, " + CRLF
	cQuery+= "			CT2_CREDIT    AS CONTA, " + CRLF
	cQuery+= "			CT2_CCC       AS CENTRO_CUSTO, " + CRLF
	cQuery+= "			CT2_ITEMC     AS ITEM_CONTABIL, " + CRLF
	cQuery+= "			CT2_CLVLCR    AS CLASSE_VALOR, " + CRLF
	
	If lFdPos05
		cCpEnt05 := "CT2_EC05CR"
	EndIf
	If lFdPos06
		cCpEnt06 := "CT2_EC06CR"
	EndIf
	If lFdPos07
		cCpEnt07 := "CT2_EC07CR"
	EndIf
	If lFdPos08
		cCpEnt08 := "CT2_EC08CR"
	EndIf
	If lFdPos09
		cCpEnt09 := "CT2_EC09CR"
	EndIf
	cQuery+= cCpEnt05 + " AS ENT05, " + CRLF
	cQuery+= cCpEnt06 + " AS ENT06, " + CRLF
	cQuery+= cCpEnt07 + " AS ENT07, " + CRLF
	cQuery+= cCpEnt08 + " AS ENT08, " + CRLF
	cQuery+= cCpEnt09 + " AS ENT09, " + CRLF

	cQuery+= "			CT2_VALOR	  AS SALDO, " + CRLF
	cQuery+= "			CT2_FILORI    AS FILORI, " + CRLF
	cQuery+= " 			D_E_L_E_T_  AS DELETADO " + CRLF
	cQuery+= "			FROM "+RetSqlName("CT2")+" CT2 " + CRLF
	cQuery+= "			WHERE   " + CRLF
	cQuery+= "			CT2.CT2_FILIAL 	   >= ? AND CT2.CT2_FILIAL <= ? " + CRLF 
	cQuery+= "			AND CT2.CT2_DATA   >= ? AND CT2.CT2_DATA   <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CREDIT >= ? AND CT2.CT2_CREDIT <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CCC    >= ? AND CT2.CT2_CCC    <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_ITEMC  >= ? AND CT2.CT2_ITEMC  <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CLVLCR >= ? AND CT2.CT2_CLVLCR <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DC IN ('2','3') " + CRLF
	If lFdPos05
		cQuery+= "			AND CT2.CT2_EC05CR >= ? AND CT2.CT2_EC05CR <= ? " + CRLF
	EndIf
	If lFdPos06
		cQuery+= "			AND CT2.CT2_EC06CR >= ? AND CT2.CT2_EC06CR <= ? " + CRLF
	EndIf
	If lFdPos07
		cQuery+= "			AND CT2.CT2_EC07CR >= ? AND CT2.CT2_EC07CR <= ? " + CRLF
	EndIf
	If lFdPos08
		cQuery+= "			AND CT2.CT2_EC08CR >= ? AND CT2.CT2_EC08CR <= ? " + CRLF
	EndIf
	If lFdPos09
		cQuery+= "			AND CT2.CT2_EC09CR >= ? AND CT2.CT2_EC09CR <= ? " + CRLF
	EndIf
	cQuery+= "		AND CT2.CT2_MOEDLC = ? " + CRLF
	cQuery+= "		AND CT2.CT2_TPSALD = ? " + CRLF
	cQuery+= "		UNION ALL " + CRLF
	cQuery+= "		SELECT  " + CRLF
	cQuery+= "			CT2_FILIAL    AS FILIAL, " + CRLF
	cQuery+= "			CT2.CT2_MOEDLC AS MOEDA, " + CRLF
	cQuery+= "			CT2_DEBITO    AS CONTA, " + CRLF
	cQuery+= "			CT2_CCD       AS CENTRO_CUSTO, " + CRLF
	cQuery+= "			CT2_ITEMD     AS ITEM_CONTABIL, " + CRLF
	cQuery+= "			CT2_CLVLDB    AS CLASSE_VALOR, " + CRLF

	If lFdPos05
		cCpEnt05 := "CT2_EC05DB"
	EndIf
	If lFdPos06
		cCpEnt06 := "CT2_EC06DB"
	EndIf
	If lFdPos07
		cCpEnt07 := "CT2_EC07DB"
	EndIf
	If lFdPos08
		cCpEnt08 := "CT2_EC08DB"
	EndIf
	If lFdPos09
		cCpEnt09 := "CT2_EC09DB"
	EndIf
	cQuery+= cCpEnt05 + " AS ENT05, " + CRLF
	cQuery+= cCpEnt06 + " AS ENT06, " + CRLF
	cQuery+= cCpEnt07 + " AS ENT07, " + CRLF
	cQuery+= cCpEnt08 + " AS ENT08, " + CRLF
	cQuery+= cCpEnt09 + " AS ENT09, " + CRLF

	cQuery+= "			CT2_VALOR*-1  AS SALDO, " + CRLF
	cQuery+= "			CT2_FILORI    AS FILORI, " + CRLF
	cQuery+= "			D_E_L_E_T_   AS DELETADO " + CRLF
	cQuery+= "			FROM "+RetSqlName("CT2")+" CT2 " + CRLF
	cQuery+= "			WHERE   " + CRLF
	cQuery+= "			CT2.CT2_FILIAL     >= ?  AND CT2.CT2_FILIAL <= ? " + CRLF 
	cQuery+= "			AND CT2.CT2_DATA   >= ?  AND CT2.CT2_DATA   <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DEBITO >= ?  AND CT2.CT2_DEBITO <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CCD    >= ?  AND CT2.CT2_CCD    <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_ITEMD  >= ?  AND CT2.CT2_ITEMD  <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CLVLDB >= ?  AND CT2.CT2_CLVLDB <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DC IN ('1','3') " + CRLF
	If lFdPos05
		cQuery+= "			AND CT2.CT2_EC05DB >= ? AND CT2.CT2_EC05DB <= ? " + CRLF
	EndIf
	If lFdPos06
		cQuery+= "			AND CT2.CT2_EC06DB >= ? AND CT2.CT2_EC06DB <= ? " + CRLF
	EndIf
	If lFdPos07
		cQuery+= "			AND CT2.CT2_EC07DB >= ? AND CT2.CT2_EC07DB <= ? " + CRLF
	EndIf
	If lFdPos08
		cQuery+= "			AND CT2.CT2_EC08DB >= ? AND CT2.CT2_EC08DB <= ? " + CRLF
	EndIf
	If lFdPos09
		cQuery+= "			AND CT2.CT2_EC09DB >= ? AND CT2.CT2_EC09DB <= ? " + CRLF
	EndIf
	cQuery+= "		AND CT2.CT2_MOEDLC = ? " + CRLF
	cQuery+= "		AND CT2.CT2_TPSALD = ? " + CRLF
	cQuery+= "			) LANCAMENTOS " + CRLF
	cQuery+= "			INNER JOIN "+RetSqlName("CTO")+" CTO ON ( " + CRLF
	If ntamCt2 == ntamCtO //MESMO COMPARTILHAMENTO - AMARRACAO DIRETA
		cQuery+= "  CTO.CTO_FILIAL = LANCAMENTOS.FILIAL " + CRLF
	Else
		If ntamCt2 > ntamCto // CT2 MAIS EXCLUSIVA DO QUE CTO - SUBSTRING EM FILIAL
			cQuery+= "  CTO.CTO_FILIAL = "+cFunSub+"( LANCAMENTOS.FILIAL , 1 ,"+cValToChar(ntamCto)+" ) "+cSoma+cReplicaT+"(' ',"+cValToChar(nTamTFil-ntamCto)+ ") "+ CRLF
		Else
			// CTO MAIS EXCLUSIVA DO QUE CT2
			// LANCAMENTOS.FILORI SEMPRE GRAVADO COM A INFORMACAO COMPLETA
			// SUBSTRING SOBRE FILORI GARANTE A CHAVE CORRETA DE CTO
			cQuery+= "  CTO.CTO_FILIAL = "+cFunSub+"( LANCAMENTOS.FILORI , 1 ,"+cValToChar(ntamCto)+" ) "+cSoma+cReplicaT+"(' ',"+cValToChar(nTamTFil-ntamCto)+ ") "+ CRLF
		EndIf
	EndIf
	cQuery+= "        AND CTO.CTO_MOEDA = LANCAMENTOS.MOEDA " + CRLF
	cQuery+= "        AND CTO.D_E_L_E_T_ = ?) " + CRLF
	cQuery+= "		WHERE LANCAMENTOS.SALDO <> 0 " + CRLF
	cQuery+= "GROUP BY FILIAL, " + CRLF
	cQuery+= "		 CTO.CTO_DESC, " + CRLF
	cQuery+= "		 CONTA, " + CRLF
	cQuery+= "		 CENTRO_CUSTO, " + CRLF
	cQuery+= "		 ITEM_CONTABIL, " + CRLF
	cQuery+= "		 CLASSE_VALOR, " + CRLF
	cQuery+= "		 ENT05, " + CRLF
	cQuery+= "		 ENT06, " + CRLF
	cQuery+= "		 ENT07, " + CRLF
	cQuery+= "		 ENT08, " + CRLF
	cQuery+= "	 	 ENT09,  " + CRLF
	cQuery+= "		 DELETADO " + CRLF
	cQuery+= "ORDER BY FILIAL, " + CRLF
	cQuery+= "		 MOEDA, " + CRLF
	cQuery+= "		 CONTA, " + CRLF
	cQuery+= "		 CENTRO_CUSTO, " + CRLF
	cQuery+= "		 ITEM_CONTABIL, " + CRLF
	cQuery+= "		 CLASSE_VALOR, " + CRLF
	cQuery+= "		 ENT05, " + CRLF
	cQuery+= "		 ENT06, " + CRLF
	cQuery+= "		 ENT07, " + CRLF
	cQuery+= "		 ENT08, " + CRLF
	cQuery+= "	 	 ENT09 " + CRLF

	cQuery := ChangeQuery(cQuery) 	
	oPrepared := FWExecStatement():New(cQuery) 

	oPrepared:SetString(nParamOrd++, cFilIni)
	oPrepared:SetString(nParamOrd++, cFilFinal)
	oPrepared:SetString(nParamOrd++, cDataIni)
	oPrepared:SetString(nParamOrd++, cDataFim)
	oPrepared:SetString(nParamOrd++, cContaIni)
	oPrepared:SetString(nParamOrd++, cContaFim)
	oPrepared:SetString(nParamOrd++, cCustoIni)
	oPrepared:SetString(nParamOrd++, cCustoFim)
	oPrepared:SetString(nParamOrd++, cItemIni)
	oPrepared:SetString(nParamOrd++, cItemFim)
	oPrepared:SetString(nParamOrd++, cClasseIn)
	oPrepared:SetString(nParamOrd++, cClasseFi)
	If lFdPos05
		oPrepared:SetString(nParamOrd++, cEnt05Ini)
		oPrepared:SetString(nParamOrd++, cEnt05Fim)
	EndIf
	If lFdPos06
		oPrepared:SetString(nParamOrd++, cEnt06Ini)
		oPrepared:SetString(nParamOrd++, cEnt06Fim)
	EndIf
	If lFdPos07
		oPrepared:SetString(nParamOrd++, cEnt07Ini)
		oPrepared:SetString(nParamOrd++, cEnt07Fim)
	EndIf
	If lFdPos08
		oPrepared:SetString(nParamOrd++, cEnt08Ini)
		oPrepared:SetString(nParamOrd++, cEnt08Fim)
	EndIf
	If lFdPos09
		oPrepared:SetString(nParamOrd++, cEnt09Ini)
		oPrepared:SetString(nParamOrd++, cEnt09Fim)
	EndIf
	oPrepared:SetString(nParamOrd++, cMoeda)
	oPrepared:SetString(nParamOrd++, cTPSaldo)
	
	oPrepared:SetString(nParamOrd++, cFilIni)
	oPrepared:SetString(nParamOrd++, cFilFinal)
	oPrepared:SetString(nParamOrd++, cDataIni)
	oPrepared:SetString(nParamOrd++, cDataFim)
	oPrepared:SetString(nParamOrd++, cContaIni)
	oPrepared:SetString(nParamOrd++, cContaFim)
	oPrepared:SetString(nParamOrd++, cCustoIni)
	oPrepared:SetString(nParamOrd++, cCustoFim)
	oPrepared:SetString(nParamOrd++, cItemIni)
	oPrepared:SetString(nParamOrd++, cItemFim)
	oPrepared:SetString(nParamOrd++, cClasseIn)
	oPrepared:SetString(nParamOrd++, cClasseFi)
	If lFdPos05
		oPrepared:SetString(nParamOrd++, cEnt05Ini)
		oPrepared:SetString(nParamOrd++, cEnt05Fim)
	EndIf
	If lFdPos06
		oPrepared:SetString(nParamOrd++, cEnt06Ini)
		oPrepared:SetString(nParamOrd++, cEnt06Fim)
	EndIf
	If lFdPos07
		oPrepared:SetString(nParamOrd++, cEnt07Ini)
		oPrepared:SetString(nParamOrd++, cEnt07Fim)
	EndIf
	If lFdPos08
		oPrepared:SetString(nParamOrd++, cEnt08Ini)
		oPrepared:SetString(nParamOrd++, cEnt08Fim)
	EndIf
	If lFdPos09
		oPrepared:SetString(nParamOrd++, cEnt09Ini)
		oPrepared:SetString(nParamOrd++, cEnt09Fim)
	EndIf
	oPrepared:SetString(nParamOrd++, cMoeda)
	oPrepared:SetString(nParamOrd++, cTPSaldo)
	oPrepared:SetString(nParamOrd++, " ") // CTO.D_E_L_E_T_

	cQuery := oPrepared:GetFixQuery()
	oPrepared:destroy()
	freeObj(oPrepared)

	ctempCon := GetNextAlias()

	MPSysOpenQuery(cQuery, ctempCon)

	oJBalanc["sucesso"]      := .T.
	oJBalanc["mensagem"]   	 := cMsg
	oJBalanc["codigo"]	  	 := nStatusCod
Return oJBalanc



Static function tamFil040(cTable)
	Local nTamEmp   := 0 As Numeric
    Local nTamUnit  := 0 As Numeric
    Local nTamFil   := 0 As Numeric
    Local nTamTotal := 0  As Numeric

	// Calcula os tamanhos das unidades de negócio para a tabela atual
	nTamEmp  := Len(FWCompany(cTable))
	nTamUnit := Len(FWUnitBusiness(cTable))
	nTamFil  := Len(FWFilial(cTable))

	// Verifica os modos de acesso e soma os tamanhos
    If FWModeAccess(cTable, 1) == "E"
        nTamTotal += nTamEmp
    EndIf

    If FWModeAccess(cTable, 2) == "E"
        nTamTotal += nTamUnit
    EndIf

    If FWModeAccess(cTable, 3) == "E"
        nTamTotal += nTamFil
    EndIf

Return nTamTotal

Function movimContA(ctempCon,cFilIni,cFilFinal,cDataIni,cDataFim,cContaIni,cContaFim,cCustoIni,cCustoFim,cItemIni,cItemFim,cClasseIn,cClasseFi,cEnt05Ini,cEnt05Fim,cEnt06Ini,cEnt06Fim,cEnt07Ini,cEnt07Fim,cEnt08Ini,cEnt08Fim,cEnt09Ini,cEnt09Fim,cMoeda,cTPSaldo)
	Local cMsg 		 := "" as character
	Local nStatusCod := 0  as Numeric
	Local cQuery	 := "" as character
	Local oJBalanc 	 := JsonObject():new() as object	
	Local oPrepared as Object
	Local nParamOrd  := 1 as Numeric
	Local ntamCt2    as numeric
	Local ntamCto    as numeric
	Local cFunSub    := "SUBSTR" as character
	Local cSoma      := ' || ' 		as character
	Local cReplicaT  := 'RPAD' as character
	Local nTamTFil   := TamSX3('CT2_FILIAL')[01] as Numeric
	Local cDbInUse   := TcGetDb() as character
	Local cCpEnt05   := "''"  as character
	Local cCpEnt06   := "''"  as character
	Local cCpEnt07   := "''"  as character
	Local cCpEnt08   := "''"  as character
	Local cCpEnt09   := "''"  as character
	Local lFdPos05   := CT2->(FieldPos("CT2_EC05CR")) > 0 as logical 
	Local lFdPos06   := CT2->(FieldPos("CT2_EC06CR")) > 0 as logical 
	Local lFdPos07   := CT2->(FieldPos("CT2_EC07CR")) > 0 as logical 
	Local lFdPos08   := CT2->(FieldPos("CT2_EC08CR")) > 0 as logical 
	Local lFdPos09   := CT2->(FieldPos("CT2_EC09CR")) > 0 as logical 
	
	DEFAULT ctempCon := ""

	If cDbInUse $ "ORACLE" 
		cReplicaT := 'RPAD'
	Else
		cFunSub   := "SUBSTRING"
		If cDbInUse $ "POSTGRES"
			cReplicaT := 'REPEAT'
		Else
			cSoma := ' + '
			cReplicaT  := 'REPLICATE'
		EndIf
	EndIf

	ntamCt2 :=  tamFil040('CT2')  
	ntamCto :=  tamFil040('CTO') 

	DbSelectArea("CT2")	
	cQuery:= "		SELECT  " + CRLF
	cQuery+= "			CT2_FILIAL				AS FILIAL, " + CRLF
	cQuery+= "			CTO.CTO_DESC AS MOEDA, " + CRLF
	cQuery+= "			'2' AS TIPO, " + CRLF
	cQuery+= "			CT2_CREDIT    AS CONTA, " + CRLF
	cQuery+= "			CT2_CCC       AS CENTRO_CUSTO, " + CRLF
	cQuery+= "			CT2_ITEMC     AS ITEM_CONTABIL, " + CRLF
	cQuery+= "			CT2_CLVLCR    AS CLASSE_VALOR, " + CRLF
	cQuery+= "			CT2_DATA 	  DDATA, " + CRLF
	cQuery+= "			CT2_TPSALD    TPSALD, " + CRLF 
	cQuery+= "			CT2_DC		  DC, " + CRLF
	cQuery+= "			CT2_LOTE	  LOTE, " + CRLF
	cQuery+= "			CT2_SBLOTE 	  SUBLOTE, " + CRLF
	cQuery+= "			CT2_DOC		  DOC, " + CRLF
	cQuery+= "			CT2_LINHA	  LINHA, " + CRLF
	cQuery+= "			CT2_DEBITO	  XPARTIDA, " + CRLF
	cQuery+= "			CT2_HIST	  HIST, " + CRLF
	cQuery+= "			CT2_SEQHIS	  SEQHIS, " + CRLF
	cQuery+= "			CT2_SEQLAN	  SEQLAN, " + CRLF
	cQuery+= "			CT2_EMPORI	  EMPORI, " + CRLF
	cQuery+= "			CT2_FILORI	  FILORI, " + CRLF
	If lFdPos05
		cCpEnt05 := "CT2_EC05CR"
	EndIf
	cQuery+= cCpEnt05 + " AS ENT05, " + CRLF

	If lFdPos06
		cCpEnt06 := "CT2_EC06CR"
	EndIf
	cQuery+= cCpEnt06 + " AS ENT06, " + CRLF

	If lFdPos07
		cCpEnt07 := "CT2_EC07CR"
	EndIf
	cQuery+= cCpEnt07 + " AS ENT07, " + CRLF

	If lFdPos08
		cCpEnt08 := "CT2_EC08CR"
	EndIf
	cQuery+= cCpEnt08 + " AS ENT08, " + CRLF

	If lFdPos09
		cCpEnt09 := "CT2_EC09CR"
	EndIf
	cQuery+= cCpEnt09 + " AS ENT09, " + CRLF
	cQuery+= "			CT2_MSUIDT    AS MSUIDT, " + CRLF
	cQuery+= "			CT2_VALOR	  AS SALDO, " + CRLF
	cQuery+= "		    CT2.D_E_L_E_T_ AS DELETADO " + CRLF
	cQuery+= "		FROM "+RetSqlName("CT2")+" CT2 " + CRLF
	cQuery+= "			INNER JOIN "+RetSqlName("CTO")+" CTO ON ( " + CRLF
	//TRATAR COMPARTILHAMENTO ENTRE CTO PARA FILIAL 
	If ntamCt2 == ntamCtO //MESMO COMPARTILHAMENTO AMARRACAO DIRETA
		cQuery+= "  CTO.CTO_FILIAL = CT2.CT2_FILIAL " + CRLF
	Else
		If ntamCt2 > ntamCto // CT2 MAIS EXCLUSIVA DO QUE CTO SUBSTRING EM CT2
			cQuery+= "  CTO.CTO_FILIAL = "+cFunSub+"( CT2.CT2_FILIAL , 1 ,"+cValToChar(ntamCto)+" ) "+cSoma+cReplicaT+"(' ',"+cValToChar(nTamTFil-ntamCto)+ ") "+ CRLF
		Else
			// CTO MAIS EXCLUSIVA DO QUE CT2 
			// NESSE CASO O SUBSTRING PODE FALHAR
			// PODERIA GERAR MAIS DE UM RETORNO PARA O MESMO LANAMENTO  
			// USAR O SUBSTRING AMARRANDO COM FILORI 
			cQuery+= "  CTO.CTO_FILIAL = "+cFunSub+"( CT2.CT2_FILORI , 1 ,"+cValToChar(ntamCto)+" ) "+cSoma+cReplicaT+"(' ',"+cValToChar(nTamTFil-ntamCto)+ ") "+ CRLF
		EndIf
	EndIf
	cQuery+= "        AND CTO.CTO_MOEDA = CT2.CT2_MOEDLC " + CRLF
	cQuery+= "        AND CTO.D_E_L_E_T_ = ?) " + CRLF
	cQuery+= "		WHERE   " + CRLF
	cQuery+= "			CT2.CT2_FILIAL 	   >= ? AND CT2.CT2_FILIAL <= ? " + CRLF 
	cQuery+= "			AND CT2.CT2_DATA   >= ? AND CT2.CT2_DATA   <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CREDIT >= ? AND CT2.CT2_CREDIT <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CCC    >= ? AND CT2.CT2_CCC    <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_ITEMC  >= ? AND CT2.CT2_ITEMC  <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CLVLCR >= ? AND CT2.CT2_CLVLCR <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DC IN ('2','3') " + CRLF
	If lFdPos05
		cQuery+= "			AND CT2.CT2_EC05CR >= ? AND CT2.CT2_EC05CR <= ? " + CRLF
	EndIf
	If lFdPos06
		cQuery+= "			AND CT2.CT2_EC06CR >= ? AND CT2.CT2_EC06CR <= ? " + CRLF
	EndIf
	If lFdPos07
		cQuery+= "			AND CT2.CT2_EC07CR >= ? AND CT2.CT2_EC07CR <= ? " + CRLF
	EndIf
	If lFdPos08
		cQuery+= "			AND CT2.CT2_EC08CR >= ? AND CT2.CT2_EC08CR <= ? " + CRLF
	EndIf
	If lFdPos09
		cQuery+= "			AND CT2.CT2_EC09CR >= ? AND CT2.CT2_EC09CR <= ? " + CRLF
	EndIf
	cQuery+= "		AND CT2.CT2_MOEDLC = ? " + CRLF
	cQuery+= "		AND CT2.CT2_TPSALD = ? " + CRLF
	cQuery+= "		UNION ALL " + CRLF
	cQuery+= "		SELECT  " + CRLF
	cQuery+= "			CT2_FILIAL    AS FILIAL, " + CRLF
	cQuery+= "			CTO.CTO_DESC  AS MOEDA, " + CRLF
	cQuery+= "			'1'           AS TIPO, " + CRLF
	cQuery+= "			CT2_DEBITO    AS CONTA, " + CRLF
	cQuery+= "			CT2_CCD       AS CENTRO_CUSTO, " + CRLF
	cQuery+= "			CT2_ITEMD     AS ITEM_CONTABIL, " + CRLF
	cQuery+= "			CT2_CLVLDB    AS CLASSE_VALOR, " + CRLF
	cQuery+= "			CT2_DATA      DDATA, " + CRLF
	cQuery+= "			CT2_TPSALD    TPSALD, " + CRLF
	cQuery+= "			CT2_DC        DC, " + CRLF
	cQuery+= "			CT2_LOTE      LOTE, " + CRLF
	cQuery+= "			CT2_SBLOTE    SUBLOTE, " + CRLF
	cQuery+= "			CT2_DOC       DOC, " + CRLF
	cQuery+= "			CT2_LINHA     LINHA, " + CRLF
	cQuery+= "			CT2_CREDIT    XPARTIDA, " + CRLF
	cQuery+= "			CT2_HIST      HIST, " + CRLF
	cQuery+= "			CT2_SEQHIS    SEQHIS, " + CRLF
	cQuery+= "			CT2_SEQLAN    SEQLAN, " + CRLF
	cQuery+= "			CT2_EMPORI    EMPORI, " + CRLF
	cQuery+= "			CT2_FILORI    FILORI, " + CRLF

	If lFdPos05
		cCpEnt05 := "CT2_EC05DB"
	EndIf
	If lFdPos06
		cCpEnt06 := "CT2_EC06DB"
	EndIf
	If lFdPos07
		cCpEnt07 := "CT2_EC07DB"
	EndIf
	If lFdPos08
		cCpEnt08 := "CT2_EC08DB"
	EndIf
	If lFdPos09
		cCpEnt09 := "CT2_EC09DB"
	EndIf
	cQuery+= cCpEnt05 + " AS ENT05, " + CRLF
	cQuery+= cCpEnt06 + " AS ENT06, " + CRLF
	cQuery+= cCpEnt07 + " AS ENT07, " + CRLF
	cQuery+= cCpEnt08 + " AS ENT08, " + CRLF
	cQuery+= cCpEnt09 + " AS ENT09, " + CRLF

	cQuery+= "			CT2_MSUIDT    AS MSUIDT, " + CRLF
	cQuery+= "			CT2_VALOR*-1  AS SALDO, " + CRLF
	cQuery+= "			CT2.D_E_L_E_T_  AS DELETADO " + CRLF
	cQuery+= "		FROM "+RetSqlName("CT2")+" CT2 " + CRLF
	cQuery+= "			INNER JOIN "+RetSqlName("CTO")+" CTO ON ( " + CRLF
	//TRATAR COMPARTILHAMENTO ENTRE CTO PARA FILIAL
	If ntamCt2 == ntamCtO //MESMO COMPARTILHAMENTO AMARRACAO DIRETA
		cQuery+= "  CTO.CTO_FILIAL = CT2.CT2_FILIAL " + CRLF
	Else
		If ntamCt2 > ntamCto // CT2 MAIS EXCLUSIVA DO QUE CTO - SUBSTRING EM CT2
			cQuery+= "  CTO.CTO_FILIAL = "+cFunSub+"( CT2.CT2_FILIAL , 1 ,"+cValToChar(ntamCto)+" ) "+cSoma+cReplicaT+"(' ',"+cValToChar(nTamTFil-ntamCto)+ ") "+ CRLF
		Else
			// CTO MAIS EXCLUSIVA DO QUE CT2
			// CT2_FILORI SEMPRE GRAVADO COM A INFORMACAO COMPLETA
			// SUBSTRING SOBRE FILORI GARANTE A CHAVE CORRETA DE CTO
			cQuery+= "  CTO.CTO_FILIAL = "+cFunSub+"( CT2.CT2_FILORI , 1 ,"+cValToChar(ntamCto)+" ) "+cSoma+cReplicaT+"(' ',"+cValToChar(nTamTFil-ntamCto)+ ") "+ CRLF
		EndIf
	EndIf
	cQuery+= "        AND CTO.CTO_MOEDA = CT2.CT2_MOEDLC " + CRLF
	cQuery+= "        AND CTO.D_E_L_E_T_ = ?) " + CRLF
	cQuery+= "		WHERE   " + CRLF
	cQuery+= "			CT2.CT2_FILIAL     >= ?  AND CT2.CT2_FILIAL <= ? " + CRLF 
	cQuery+= "			AND CT2.CT2_DATA   >= ?  AND CT2.CT2_DATA   <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DEBITO >= ?  AND CT2.CT2_DEBITO <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CCD    >= ?  AND CT2.CT2_CCD    <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_ITEMD  >= ?  AND CT2.CT2_ITEMD  <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CLVLDB >= ?  AND CT2.CT2_CLVLDB <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DC IN ('1','3') " + CRLF
	If lFdPos05
		cQuery+= "			AND CT2.CT2_EC05DB >= ? AND CT2.CT2_EC05DB <= ? " + CRLF
	EndIf
	If lFdPos06
		cQuery+= "			AND CT2.CT2_EC06DB >= ? AND CT2.CT2_EC06DB <= ? " + CRLF
	EndIf
	If lFdPos07
		cQuery+= "			AND CT2.CT2_EC07DB >= ? AND CT2.CT2_EC07DB <= ? " + CRLF
	EndIf
	If lFdPos08
		cQuery+= "			AND CT2.CT2_EC08DB >= ? AND CT2.CT2_EC08DB <= ? " + CRLF
	EndIf
	If lFdPos09
		cQuery+= "			AND CT2.CT2_EC09DB >= ? AND CT2.CT2_EC09DB <= ? " + CRLF
	EndIf
	cQuery+= "		AND CT2.CT2_MOEDLC = ? " + CRLF
	cQuery+= "		AND CT2.CT2_TPSALD = ? " + CRLF
	cQuery+= "ORDER BY FILIAL, " + CRLF
	cQuery+= "		 MOEDA, " + CRLF
	cQuery+= "		 CONTA, " + CRLF
	cQuery+= "		 CENTRO_CUSTO, " + CRLF
	cQuery+= "		 ITEM_CONTABIL, " + CRLF
	cQuery+= "		 CLASSE_VALOR, " + CRLF
	cQuery+= "		 ENT05, " + CRLF
	cQuery+= "		 ENT06, " + CRLF
	cQuery+= "		 ENT07, " + CRLF
	cQuery+= "		 ENT08, " + CRLF
	cQuery+= "	 	 ENT09 " + CRLF

	cQuery := ChangeQuery(cQuery) 	
	
	oPrepared := FWExecStatement():New(cQuery) 

	oPrepared:SetString(nParamOrd++, " ") 
	oPrepared:SetString(nParamOrd++, cFilIni)
	oPrepared:SetString(nParamOrd++, cFilFinal)
	oPrepared:SetString(nParamOrd++, cDataIni)//CONVERTE S01/08/2025 PARA D 01/08/25 E APOS FORMATO DE BANCO S20250801
	oPrepared:SetString(nParamOrd++, cDataFim)
	oPrepared:SetString(nParamOrd++, cContaIni)
	oPrepared:SetString(nParamOrd++, cContaFim)
	oPrepared:SetString(nParamOrd++, cCustoIni)
	oPrepared:SetString(nParamOrd++, cCustoFim)
	oPrepared:SetString(nParamOrd++, cItemIni)
	oPrepared:SetString(nParamOrd++, cItemFim)
	oPrepared:SetString(nParamOrd++, cClasseIn)
	oPrepared:SetString(nParamOrd++, cClasseFi)
	If lFdPos05
		oPrepared:SetString(nParamOrd++, cEnt05Ini)
		oPrepared:SetString(nParamOrd++, cEnt05Fim)
	EndIf
	If lFdPos06
		oPrepared:SetString(nParamOrd++, cEnt06Ini)
		oPrepared:SetString(nParamOrd++, cEnt06Fim)
	EndIf
	If lFdPos07
		oPrepared:SetString(nParamOrd++, cEnt07Ini)
		oPrepared:SetString(nParamOrd++, cEnt07Fim)
	EndIf
	If lFdPos08
		oPrepared:SetString(nParamOrd++, cEnt08Ini)
		oPrepared:SetString(nParamOrd++, cEnt08Fim)
	EndIf
	If lFdPos09
		oPrepared:SetString(nParamOrd++, cEnt09Ini)
		oPrepared:SetString(nParamOrd++, cEnt09Fim)
	EndIf
	oPrepared:SetString(nParamOrd++, cMoeda)
	oPrepared:SetString(nParamOrd++, cTPSaldo)
	
	oPrepared:SetString(nParamOrd++, " ") 
	oPrepared:SetString(nParamOrd++, cFilIni)
	oPrepared:SetString(nParamOrd++, cFilFinal)
	oPrepared:SetString(nParamOrd++, cDataIni)
	oPrepared:SetString(nParamOrd++, cDataFim)
	oPrepared:SetString(nParamOrd++, cContaIni)
	oPrepared:SetString(nParamOrd++, cContaFim)
	oPrepared:SetString(nParamOrd++, cCustoIni)
	oPrepared:SetString(nParamOrd++, cCustoFim)
	oPrepared:SetString(nParamOrd++, cItemIni)
	oPrepared:SetString(nParamOrd++, cItemFim)
	oPrepared:SetString(nParamOrd++, cClasseIn)
	oPrepared:SetString(nParamOrd++, cClasseFi)
	If lFdPos05
		oPrepared:SetString(nParamOrd++, cEnt05Ini)
		oPrepared:SetString(nParamOrd++, cEnt05Fim)
	EndIf
	If lFdPos06
		oPrepared:SetString(nParamOrd++, cEnt06Ini)
		oPrepared:SetString(nParamOrd++, cEnt06Fim)
	EndIf
	If lFdPos07
		oPrepared:SetString(nParamOrd++, cEnt07Ini)
		oPrepared:SetString(nParamOrd++, cEnt07Fim)
	EndIf
	If lFdPos08
		oPrepared:SetString(nParamOrd++, cEnt08Ini)
		oPrepared:SetString(nParamOrd++, cEnt08Fim)
	EndIf
	If lFdPos09
		oPrepared:SetString(nParamOrd++, cEnt09Ini)
		oPrepared:SetString(nParamOrd++, cEnt09Fim)
	EndIf
	oPrepared:SetString(nParamOrd++, cMoeda)
	oPrepared:SetString(nParamOrd++, cTPSaldo)
	

	cQuery := oPrepared:GetFixQuery()
	oPrepared:destroy()
	freeObj(oPrepared)

	ctempCon := GetNextAlias()
	MPSysOpenQuery(cQuery, ctempCon)

	oJBalanc["sucesso"]      := .T.
	oJBalanc["mensagem"]   	 := cMsg
	oJBalanc["codigo"]	  	 := nStatusCod
Return oJBalanc

Function BalnVldPrm(ojBody as json, aFils as array)
    Local cParamFil   as character
    Local nI      as numeric
    Local cMsg   as character
    Local lOK    as logical
    Local lFilial as logical
    Local oJRes  as json
    Local aField as array
	Local cCgc   as character	
    Local aAllFils as array
    Local cEmpresa as character	

    oJRes :=  JsonObject():new()
    cMSg  := ""
    lOk   := .T.

    If Vazio(oJBody["CNPJ"]) == .F.
        aField:= {"CNPJ", "DATA_FINAL", "DATA_INICIAL"}
        If oJBody["INDICADORES"]== 1 
            cCgc  := oJBody["CNPJ"]
        Else
            cCgc  := substr(oJBody["CNPJ"], 1, 8)
        EndIf
    Else
        aField:= {"GRUPO_EMPRESA","FILIAL", "DATA_FINAL", "DATA_INICIAL"}
    EndIf

    for nI:=1 to (len(aField))
        If(vazio(ojBody[ aField[nI] ]))
            cMsg+= STR0005 + aField[nI] + STR0002 // "Campo: " " inválido"
            lOK := .F.
        EndIf   
    next
    If lOK .and. oJBody["INDICADORES"]== 1 
        If ! VALTYPE(ojBody["CODIGO_EXTERNO"]) == 'A' .or. Empty(ojBody["CODIGO_EXTERNO"])
            cMsg+= STR0005 + "CODIGO_EXTERNO" + STR0002 // "Campo: " " inválido"
            lOK := .F.
        EndIf
    EndIF

    If lOk
        If vazio(ojBody["CNPJ"]) == .F.
            aAllFils := fwLoadSm0(.F., .F.)
            lFilial := !vazio(ojBody["FILIAL"]) 
            For nI:=1 to len(aAllFils)
                If /*aAllFils[nI][1] == cEmpAnt .And.*/ substr(aAllFils[nI][18], 1, len(cCgc)) == cCgc // por cnpj pode necessitar de trocar enviroment (smartlink)
                    If Empty(cEmpresa)
                        cEmpresa := aAllFils[nI][1]
                    EndIf
                    If lFilial
                        aFils:= separa( ojBody["FILIAL"], ";" )
                        nI := len(aAllFils)
                    Else                
					    aadd(aFils, aAllFils[nI][2])
                    EndIf
                EndIf
            next             

            If len(aFils) == 0 
                cMsg += STR0004 + oJBody["CNPJ"] // "Nenhuma filial cadastrada com o CNPJ: " + oJBody["CNPJ"]
                lOK  := .F.
            EndIf 
        Else
            // Para acessar outro grupo empresa, deve ser enviado via tenantId
			cEmpresa := IIf(empty(ojBody["GRUPO_EMPRESA"]),"", ojBody["GRUPO_EMPRESA"])
            cParamFil := alltrim(separa( ojBody["FILIAL"], ";" )[1])

            If FWFilExist(cEmpresa, cParamFil) == .F.
                cMsg+= STR0001 +" "+ cParamFil +" "+ STR0003 +": "+ cEmpresa  // Filial + cParamFil + não existe na empresa  + cParamEmp
                lOK := .F.
            EndIf 
        EndIf
    EndIf

    oJRes["items"]  := {}
    oJRes["empresa"]:= cEmpresa
    oJRes["isok"]   := lOK
    oJRes["message"]:= cMsg
return oJRes

Function BalnVldEmp(cEmpresa as character)
	Local oJRes  as json
	Local lOK    as logical
	Local cMsg   as character

	lOK  := .T.
	cMsg := ""

	If Empty(cEmpresa) .or. FWFilExist(cEmpresa) == .F.
		lOK  := .F.
		cMsg+= STR0006 + cEmpresa + STR0007  // "Empresa: "  + cEmpresa + " não encontrada."   
	EndIf 

	oJRes :=  JsonObject():new()
    oJRes["isok"]   := lOK
    oJRes["message"]:= cMsg

Return oJRes


Function Ctr040GetDt(oJBody as json, aFils as array, cTableNam as character,cArqTmp as character)

	Local cAlias		as character    
	Local cWhere        as character
	Local aSelFil		as Array 		
	Local cDataini  	as character	
	Local cDataFim  	as character	
	Local nImpCtas   	as numeric
	Local cMoeda		as character
	Local cTpSaldo  	as character
	Local cFSeg 		as character
	Local cFSegIni 		as character
	Local cFSegFim 		as character
	Local cFSegCon 		as character
	Local nImpMov		as numeric
	Local nDivide		as numeric
	Local lVlZerado     as logical
	Local lImpAntLp		as logical
	Local cDtPAntLp		as character
	Local lRecDesp0 	as logical
	Local cGrpRDesp     as character
	Local aSetBook		as array
	Local cCodPla 		as character
	Local cDtZeraRD 	as character
	cCodPla := getCodPla()
	aSetBook := {/*CTN->CTN_CODIGO*/"", /*CTN->CTN_MASC1*/"",/*CTN->CTN_DECIM*/ 2,;
		/*CTN->CTN_PICTV*/"",/*CTN->CTN_PLAGER*/cCodPla,/*CTN->CTN_MASC2*/"",/*CTN->CTN_MASC3*/"",;
		/*CTN->CTN_MASC4*/ "",1,/*CTN_DESC*/"INDIC GESPLAN",/*CTN->CTN_PLREF*/"",/*CTN->CTN_VERSAO*/"" }
	
	cWhere 		 := ""
	cAlias		 := "CT7"
	cTableNam	 := ""
	cArqTmp		 := "" 
	aSelFil		 := {}

	cDataini 	 := ojBody["DATA_INICIAL"]				
	cDataFim  	 := ojBody["DATA_FINAL"]				
	nImpCtas  := iIf( Vazio(ojBody["IMPRIME_CONTAS"]),  3, ojBody["IMPRIME_CONTAS"]  )
	lVlZerado   := iIf( Vazio(ojBody["SALDOS_ZERADOS"]), .T., iIf(ojBody["SALDOS_ZERADOS"] == 1, .T., .F.)   )	
	cMoeda		 := iIf( Vazio(ojBody["MOEDA"]),  "01", ojBody["MOEDA"]  )	
	cTpSaldo     := iIf( Vazio(ojBody["TIPO_DE_SALDO"]), "1", ojBody["TIPO_DE_SALDO"]  )	
	cFSeg	 := iIf( Vazio(ojBody["FILTRA_SEGMENTO_NO"]), padR(" ", tamSx3("CTM_SEGMEN")[1]) , ojBody["FILTRA_SEGMENTO_NO"]  )	  
	cFSegIni:= iIf( Vazio(ojBody["CONTEUDO_INI_SEGMEN"]),  "", ojBody["CONTEUDO_INI_SEGMEN"]  )	  
	cFSegFim:= iIf( Vazio(ojBody["CONTEUDO_FIM_SEGMEN"]),  "", ojBody["CONTEUDO_FIM_SEGMEN"]  )	  
	cFSegCon:= iIf( Vazio(ojBody["CONTEUDO_CONTIDO_EM"]),  "", ojBody["CONTEUDO_CONTIDO_EM"]  )	  
	nImpMov:= iIf( Vazio(ojBody["IMPRIME_COLUNA_MOV"]),  1, ojBody["IMPRIME_COLUNA_MOV"]  )	  
	nDivide		 := iIf( Vazio(ojBody["DIVIDE_POR"]),  1, ojBody["DIVIDE_POR"])	
	lImpAntLp	 := iIf( Vazio(ojBody["POSICAO_ANT_L_P"]), .F., iIf(ojBody["POSICAO_ANT_L_P"] = 2, .F., .T.) )	
	cDtPAntLp	 := iIf( Vazio(ojBody["DATA_LUCRO_PERDAS"]), ojBody["DATA_INICIAL"], ojBody["DATA_LUCRO_PERDAS"]  )		
	lRecDesp0 	 := iIf( Vazio(ojBody["IGNORA_SL_ANT_REC_DES"]), .T., iIf(ojBody["IGNORA_SL_ANT_REC_DES"] == 1, .T., .F.)  )	
	cGrpRDesp  := iIf( Vazio(ojBody["GRUPOS_RECEITAS_DESPESAS"]),  "", ojBody["GRUPOS_RECEITAS_DESPESAS"]  )	
	cDtZeraRD    := iIf( Vazio(ojBody["DATA_SLD_ANT_RECEITAS_DESP"]), ojBody["DATA_INICIAL"], ojBody["DATA_SLD_ANT_RECEITAS_DESP"]  )
	If len(aFils)> 0 
		aSelFil := afils
	Else		
		aSelFil		 := separa( ojBody["FILIAL"], ";" ) 
	EndIf

	If nDivide >= 1 .AND. nDivide <= 4
		nDivide := {1, 100, 1000, 1000000}[nDivide]
	Else 
		nDivide := 1
	EndIf
	
	CTGerPlan(,,, .F., @cArqTmp,;
	ctoD(cDataini), cToD(cDataFim), cAlias, "", ,,,,,,,, cMoeda,;
	cTpSaldo, aSetBook, cFSeg, ;
	cFSegIni, cFSegFim, cFSegCon,;
	.F.,.F.,,, lImpAntLP, ctoD(cDtPAntLp)-1, nDivide, ;
	lVlZerado,,,,,,,,,,,,,,.T.,"", lRecDesp0,;
	cGrpRDesp, ctoD(cDtZeraRD)-1,,,,,,,,,aSelFil,,,,,,,,,,,,,,,@cTableNam,,,,,ojBody["CODIGO_EXTERNO"])

Return cTableNam

Function getCodPla() 
	Local cCodPla     := '' as Character
	Local cAliasCTS   := GetNextAlias() as Character
	Local cQuery 	  := '' as Character

	If CTS->(FieldPos("CTS_ENTGRP")) > 0
		cQuery := "SELECT CTS_CODPLA"
		cQuery += " FROM " + RetSQLName("CTS")
		cQuery += " WHERE CTS_FILIAL = '" + xFilial("CTS") +"' AND CTS_ENTGRP = '1' AND  D_E_L_E_T_ = ' '"

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasCTS, .T., .F.)

		If (cAliasCTS)->(!EOF())
			cCodPla := (cAliasCTS)->CTS_CODPLA //Pega ultimo utilizado
		Else
			cCodPla := MpSysExecScalar("SELECT MAX(CTS_CODPLA) NUMMAX FROM "+RetSqlName("CTS")+" WHERE CTS_FILIAL = '" + xFilial("CTS") + "' ", "NUMMAX")
			cCodPla := PadR(Soma1(cCodPla), TamSx3("CTS_CODPLA")[1])
		EndIf
	EndIf

	(cAliasCTS)->(dbCloseArea())

Return cCodPla

Function getFldGesp()
	Local aField as array
	aField := {}

	aadd(afield, {"CONTA", "CODIGO_EXTERNO", "CONTA" })
	// aadd(afield, {"NORMAL", "CONDICAO_NORMAL", "NORMAL"} )
	// aadd(afield, {"SUPERIOR", "SUPERIOR", "SUPERIOR"} )
	// aadd(afield, {"TIPOCONTA", "CLASSE", "TIPOCONTA"} )
	// aadd(afield, {"NATCTA", "NATUREZA", "NATCTA"} )
	// aadd(afield, {"DESCCTA", "DESCRICAO", "DESCCTA"} )
	aadd(afield, {"SALDOANT", "SALDO_ANTERIOR", "SALDOANT" })
	aadd(afield, {"SALDODEB", "DEBITO", "SALDODEB" })
	aadd(afield, {"SALDOCRD", "CREDITO", "SALDOCRD"  })
	aadd(afield, {"SALDOATU", "SALDO_ATUAL", "SALDOATU" })

return aField

