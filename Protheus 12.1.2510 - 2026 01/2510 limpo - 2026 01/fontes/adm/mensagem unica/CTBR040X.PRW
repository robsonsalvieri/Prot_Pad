#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "TBICONN.ch"
#include "CTBR040X.ch"


Function movimContS(ctempCon,cEmpresa,cFilialInicial,cFilialFinal,cDataInicial,cDataFinal,cContaInicial,cContaFinal,cCCustoInicial,cCCustoFinal,cItemInicial,cItemFinal,cClasseInicial,cClasseFinal,cEnt05Inicial,cEnt05Final,cEnt06Inicial,cEnt06Final,cEnt07Inicial,cEnt07Final,cEnt08Inicial,cEnt08Final,cEnt09Inicial,cEnt09Final)
Local cMsg 		 := ""	
Local nStatusCode:= 0
Local cQuery	 := ""											as character
Local oJBalanc 	 :=  JsonObject():new()						as object	
Local oPrepared 											as Object
Local nParamOrder:= 1										as Numeric
DEFAULT ctempCon := ""
	oPrepared    :=  NIL

	DbSelectArea("CT2")	
	cQuery:= " SELECT " + CRLF
	cQuery+= " 		FILIAL, " + CRLF
	cQuery+= "		ANO, " + CRLF
	cQuery+= "		MES, " + CRLF
	cQuery+= "		NJ7.NJ7_DESCRI AS MOEDA, " + CRLF
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
	cQuery+= "			SUBSTRING(CT2_DATA,1,4) AS ANO, " + CRLF
	cQuery+= "			SUBSTRING(CT2_DATA,5,2) AS MES, " + CRLF
	cQuery+= "			CT2.CT2_MOEDLC AS MOEDA, " + CRLF
	cQuery+= "			CT2_CREDIT    AS CONTA, " + CRLF
	cQuery+= "			CT2_CCC       AS CENTRO_CUSTO, " + CRLF
	cQuery+= "			CT2_ITEMC     AS ITEM_CONTABIL, " + CRLF
	cQuery+= "			CT2_CLVLCR    AS CLASSE_VALOR, " + CRLF
	If FieldPos("CT2_EC05CR") > 0
		cQuery+= "CT2_EC05CR    AS ENT05, " + CRLF
	Else
		cQuery+= " ''     AS ENT05, " + CRLF
	EndIf
	If FieldPos("CT2_EC06CR") > 0
		cQuery+= "CT2_EC06CR    AS ENT06, " + CRLF
	Else
		cQuery+= " ''     AS ENT06, " + CRLF
	EndIf
	If FieldPos("CT2_EC07CR") > 0
		cQuery+= "CT2_EC07CR    AS ENT07, " + CRLF
	Else
		cQuery+= " ''     AS ENT07, " + CRLF
	EndIf
	If FieldPos("CT2_EC08CR") > 0
		cQuery+= "CT2_EC08CR    AS ENT08, " + CRLF
	Else
		cQuery+= " ''     AS ENT08, " + CRLF
	EndIf
	If FieldPos("CT2_EC09CR") > 0
		cQuery+= "CT2_EC09CR    AS ENT09, " + CRLF
	Else
		cQuery+= " ''     AS ENT09, " + CRLF
	EndIf
	cQuery+= "			CT2_VALOR	  AS SALDO, " + CRLF
	cQuery+= "			CASE  " + CRLF
	cQuery+= "				WHEN D_E_L_E_T_ = ' ' THEN 'NAO' ELSE 'SIM' " + CRLF  
	cQuery+= "			END AS DELETADO " + CRLF
	cQuery+= "		FROM "+RetSqlName("CT2")+" CT2 " + CRLF
	cQuery+= "		WHERE   " + CRLF
	cQuery+= "			CT2.CT2_FILIAL 	   >= ? AND CT2.CT2_FILIAL <= ? " + CRLF 
	cQuery+= "			AND CT2.CT2_DATA   >= ? AND CT2.CT2_DATA   <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CREDIT >= ? AND CT2.CT2_CREDIT <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CCC    >= ? AND CT2.CT2_CCC    <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_ITEMC  >= ? AND CT2.CT2_ITEMC  <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CLVLCR >= ? AND CT2.CT2_CLVLCR <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DC IN ('2','3') " + CRLF
	If FieldPos("CT2_EC05CR") > 0
		cQuery+= "			AND CT2.CT2_EC05CR >= ? AND CT2.CT2_EC05CR <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC06CR") > 0
		cQuery+= "			AND CT2.CT2_EC06CR >= ? AND CT2.CT2_EC06CR <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC07CR") > 0
		cQuery+= "			AND CT2.CT2_EC07CR >= ? AND CT2.CT2_EC07CR <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC08CR") > 0
		cQuery+= "			AND CT2.CT2_EC08CR >= ? AND CT2.CT2_EC08CR <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC09CR") > 0
		cQuery+= "			AND CT2.CT2_EC09CR >= ? AND CT2.CT2_EC09CR <= ? " + CRLF
	EndIf
	cQuery+= "		UNION ALL " + CRLF
	cQuery+= "		SELECT  " + CRLF
	cQuery+= "			CT2_FILIAL    AS FILIAL, " + CRLF
	cQuery+= "			SUBSTRING(CT2_DATA,1,4) AS ANO, " + CRLF
	cQuery+= "			SUBSTRING(CT2_DATA,5,2) AS MES, " + CRLF
	cQuery+= "			CT2.CT2_MOEDLC AS MOEDA, " + CRLF
	cQuery+= "			CT2_DEBITO    AS CONTA, " + CRLF
	cQuery+= "			CT2_CCD       AS CENTRO_CUSTO, " + CRLF
	cQuery+= "			CT2_ITEMD     AS ITEM_CONTABIL, " + CRLF
	cQuery+= "			CT2_CLVLDB    AS CLASSE_VALOR, " + CRLF
	If FieldPos("CT2_EC05DB") > 0
		cQuery+= "CT2_EC05DB    AS ENT05, " + CRLF
	Else
		cQuery+= " ''     AS ENT05, " + CRLF
	EndIf
	If FieldPos("CT2_EC06DB") > 0
		cQuery+= "CT2_EC06DB    AS ENT06, " + CRLF
	Else
		cQuery+= " ''     AS ENT06, " + CRLF
	EndIf
	If FieldPos("CT2_EC07DB") > 0
		cQuery+= "CT2_EC07DB    AS ENT07, " + CRLF
	Else
		cQuery+= " ''     AS ENT07, " + CRLF
	EndIf
	If FieldPos("CT2_EC08DB") > 0
		cQuery+= "CT2_EC08DB    AS ENT08, " + CRLF
	Else
		cQuery+= " ''     AS ENT08, " + CRLF
	EndIf
	If FieldPos("CT2_EC09DB") > 0
		cQuery+= "CT2_EC09DB    AS ENT09, " + CRLF
	Else
		cQuery+= " ''     AS ENT09, " + CRLF
	EndIf
	cQuery+= "			CT2_VALOR*-1  AS SALDO, " + CRLF
	cQuery+= "			CASE  " + CRLF
	cQuery+= "				WHEN D_E_L_E_T_ = ' ' THEN 'NAO' ELSE 'SIM' " + CRLF  
	cQuery+= "			END AS DELETADO " + CRLF
	cQuery+= "		FROM "+RetSqlName("CT2")+" CT2 " + CRLF
	cQuery+= "		WHERE   " + CRLF
	cQuery+= "			CT2.CT2_FILIAL     >= ?  AND CT2.CT2_FILIAL <= ? " + CRLF 
	cQuery+= "			AND CT2.CT2_DATA   >= ?  AND CT2.CT2_DATA   <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DEBITO >= ?  AND CT2.CT2_DEBITO <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CCD    >= ?  AND CT2.CT2_CCD    <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_ITEMD  >= ?  AND CT2.CT2_ITEMD  <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CLVLDB >= ?  AND CT2.CT2_CLVLDB <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DC IN ('1','3') " + CRLF
	If FieldPos("CT2_EC05DB") > 0
		cQuery+= "			AND CT2.CT2_EC05DB >= ? AND CT2.CT2_EC05DB <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC06DB") > 0
		cQuery+= "			AND CT2.CT2_EC06DB >= ? AND CT2.CT2_EC06DB <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC07DB") > 0
		cQuery+= "			AND CT2.CT2_EC07DB >= ? AND CT2.CT2_EC07DB <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC08DB") > 0
		cQuery+= "			AND CT2.CT2_EC08DB >= ? AND CT2.CT2_EC08DB <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC09DB") > 0
		cQuery+= "			AND CT2.CT2_EC09DB >= ? AND CT2.CT2_EC09DB <= ? " + CRLF
	EndIf
	cQuery+= "			) LANCAMENTOS " + CRLF
	cQuery+= "			INNER JOIN "+RetSqlName("NJ7")+" NJ7 ON ('0'+NJ7.NJ7_CODPRO = LANCAMENTOS.MOEDA) " + CRLF
	cQuery+= "		WHERE LANCAMENTOS.SALDO <> 0 " + CRLF
	cQuery+= "GROUP BY FILIAL, " + CRLF
	cQuery+= " 		 ANO, " + CRLF
	cQuery+= "		 MES, " + CRLF
	cQuery+= "		 NJ7.NJ7_DESCRI, " + CRLF
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
	cQuery+= " 		 ANO, " + CRLF
	cQuery+= "		 MES, " + CRLF
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

	oPrepared:SetString(nParamOrder++, cFilialInicial)
	oPrepared:SetString(nParamOrder++, cFilialFinal)
	oPrepared:SetString(nParamOrder++, DTOS(CTOD(cDataInicial)))//CONVERTE S01/08/2025 PARA D 01/08/25 E APOS FORMATO DE BANCO S20250801
	oPrepared:SetString(nParamOrder++, DTOS(CTOD(cDataFinal)))
	oPrepared:SetString(nParamOrder++, cContaInicial)
	oPrepared:SetString(nParamOrder++, cContaFinal)
	oPrepared:SetString(nParamOrder++, cCCustoInicial)
	oPrepared:SetString(nParamOrder++, cCCustoFinal)
	oPrepared:SetString(nParamOrder++, cItemInicial)
	oPrepared:SetString(nParamOrder++, cItemFinal)
	oPrepared:SetString(nParamOrder++, cClasseInicial)
	oPrepared:SetString(nParamOrder++, cClasseFinal)
	If FieldPos("CT2_EC05DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt05Inicial)
		oPrepared:SetString(nParamOrder++, cEnt05Final)
	Endif
	If FieldPos("CT2_EC06DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt06Inicial)
		oPrepared:SetString(nParamOrder++, cEnt06Final)
	EndIf
	If FieldPos("CT2_EC07DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt07Inicial)
		oPrepared:SetString(nParamOrder++, cEnt07Final)
	EndIf
	If FieldPos("CT2_EC08DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt08Inicial)
		oPrepared:SetString(nParamOrder++, cEnt08Final)
	EndIf
	If FieldPos("CT2_EC05DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt09Inicial)
		oPrepared:SetString(nParamOrder++, cEnt09Final)
	EndIf
	
	oPrepared:SetString(nParamOrder++, cFilialInicial)
	oPrepared:SetString(nParamOrder++, cFilialFinal)
	oPrepared:SetString(nParamOrder++, DTOS(CTOD(cDataInicial)))//CONVERTE S01/08/2025 PARA D 01/08/25 E APOS FORMATO DE BANCO S20250801
	oPrepared:SetString(nParamOrder++, DTOS(CTOD(cDataFinal)))
	oPrepared:SetString(nParamOrder++, cContaInicial)
	oPrepared:SetString(nParamOrder++, cContaFinal)
	oPrepared:SetString(nParamOrder++, cCCustoInicial)
	oPrepared:SetString(nParamOrder++, cCCustoFinal)
	oPrepared:SetString(nParamOrder++, cItemInicial)
	oPrepared:SetString(nParamOrder++, cItemFinal)
	oPrepared:SetString(nParamOrder++, cClasseInicial)
	oPrepared:SetString(nParamOrder++, cClasseFinal)
	If FieldPos("CT2_EC05DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt05Inicial)
		oPrepared:SetString(nParamOrder++, cEnt05Final)
	EndIf
	If FieldPos("CT2_EC06DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt06Inicial)
		oPrepared:SetString(nParamOrder++, cEnt06Final)
	EndIf
	If FieldPos("CT2_EC07DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt07Inicial)
		oPrepared:SetString(nParamOrder++, cEnt07Final)
	EndIf
	If FieldPos("CT2_EC08DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt08Inicial)
		oPrepared:SetString(nParamOrder++, cEnt08Final)
	EndIf
	If FieldPos("CT2_EC09DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt09Inicial)
		oPrepared:SetString(nParamOrder++, cEnt09Final)
	EndIf

	cQuery := oPrepared:GetFixQuery()
	oPrepared:destroy()
	freeObj(oPrepared)

	If Select(ctempCon) > 0
		dbSelectArea(ctempCon)
		ctempCon->(dbCloseArea())
		ctempCon := GetNextAlias()
	Endif

	MPSysOpenQuery(cQuery, ctempCon)

	oJBalanc["sucesso"]      := .T.
	oJBalanc["mensagem"]   	 := cMsg
	oJBalanc["codigo"]	  	 := nStatusCode
Return oJBalanc






Function movimContA(ctempCon,cEmpresa,cFilialInicial,cFilialFinal,cDataInicial,cDataFinal,cContaInicial,cContaFinal,cCCustoInicial,cCCustoFinal,cItemInicial,cItemFinal,cClasseInicial,cClasseFinal,cEnt05Inicial,cEnt05Final,cEnt06Inicial,cEnt06Final,cEnt07Inicial,cEnt07Final,cEnt08Inicial,cEnt08Final,cEnt09Inicial,cEnt09Final)
Local cMsg 		 := ""	
Local nStatusCode:= 0
Local cQuery	 := ""											as character
Local oJBalanc 	 :=  JsonObject():new()						as object	
Local oPrepared 											as Object
Local nParamOrder:= 1										as Numeric
DEFAULT ctempCon := ""
	oPrepared    :=  NIL
	

	DbSelectArea("CT2")	
	cQuery:= "		SELECT  " + CRLF
	cQuery+= "			CT2_FILIAL				AS FILIAL, " + CRLF
	cQuery+= "			SUBSTRING(CT2_DATA,1,4) AS ANO, " + CRLF
	cQuery+= "			SUBSTRING(CT2_DATA,5,2) AS MES, " + CRLF
	cQuery+= "			NJ7.NJ7_DESCRI AS MOEDA, " + CRLF
	cQuery+= "			'CREDITO' AS TIPO, " + CRLF
	cQuery+= "			ISNULL(CT2_CREDIT,'')    AS CONTA, " + CRLF
	cQuery+= "			ISNULL(CT2_CCC,'')       AS CENTRO_CUSTO, " + CRLF
	cQuery+= "			ISNULL(CT2_ITEMC,'')     AS ITEM_CONTABIL, " + CRLF
	cQuery+= "			ISNULL(CT2_CLVLCR,'')    AS CLASSE_VALOR, " + CRLF
	cQuery+= "			ISNULL(CT2_DATA,'') DDATA, " + CRLF
	cQuery+= "			ISNULL(CT2_TPSALD,'') TPSALD, " + CRLF 
	cQuery+= "			ISNULL(CT2_DC,'') DC, " + CRLF
	cQuery+= "			ISNULL(CT2_LOTE,'') LOTE, " + CRLF
	cQuery+= "			ISNULL(CT2_SBLOTE,'') SUBLOTE, " + CRLF
	cQuery+= "			ISNULL(CT2_DOC,'') DOC, " + CRLF
	cQuery+= "			ISNULL(CT2_LINHA,'') LINHA, " + CRLF
	cQuery+= "			ISNULL(CT2_CREDIT,'') XPARTIDA, " + CRLF
	cQuery+= "			ISNULL(CT2_HIST,'') HIST, " + CRLF
	cQuery+= "			ISNULL(CT2_SEQHIS,'') SEQHIS, " + CRLF
	cQuery+= "			ISNULL(CT2_SEQLAN,'') SEQLAN, " + CRLF
	cQuery+= "			ISNULL(CT2_EMPORI,'') EMPORI, " + CRLF
	cQuery+= "			ISNULL(CT2_FILORI,'') FILORI, " + CRLF
	If FieldPos("CT2_EC05CR") > 0
		cQuery+= "CT2_EC05CR    AS ENT05, " + CRLF
	Else
		cQuery+= " ''     AS ENT05, " + CRLF
	EndIf
	If FieldPos("CT2_EC06CR") > 0
		cQuery+= "CT2_EC06CR    AS ENT06, " + CRLF
	Else
		cQuery+= " ''     AS ENT06, " + CRLF
	EndIf
	If FieldPos("CT2_EC07CR") > 0
		cQuery+= "CT2_EC07CR    AS ENT07, " + CRLF
	Else
		cQuery+= " ''     AS ENT07, " + CRLF
	EndIf
	If FieldPos("CT2_EC08CR") > 0
		cQuery+= "CT2_EC08CR    AS ENT08, " + CRLF
	Else
		cQuery+= " ''     AS ENT08, " + CRLF
	EndIf
	If FieldPos("CT2_EC09CR") > 0
		cQuery+= "CT2_EC09CR    AS ENT09, " + CRLF
	Else
		cQuery+= " ''     AS ENT09, " + CRLF
	EndIf
	cQuery+= "			CT2_MSUIDT    AS MSUIDT, " + CRLF
	cQuery+= "			CT2_VALOR	  AS SALDO, " + CRLF
	cQuery+= "			CASE  " + CRLF
	cQuery+= "				WHEN CT2.D_E_L_E_T_ = ' ' THEN 'NAO' ELSE 'SIM' " + CRLF  
	cQuery+= "			END AS DELETADO " + CRLF
	cQuery+= "		FROM "+RetSqlName("CT2")+" CT2 " + CRLF
	cQuery+= "			INNER JOIN "+RetSqlName("NJ7")+" NJ7 ON ('0'+NJ7.NJ7_CODPRO = CT2.CT2_MOEDLC) " + CRLF
	cQuery+= "		WHERE   " + CRLF
	cQuery+= "			CT2.CT2_FILIAL 	   >= ? AND CT2.CT2_FILIAL <= ? " + CRLF 
	cQuery+= "			AND CT2.CT2_DATA   >= ? AND CT2.CT2_DATA   <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CREDIT >= ? AND CT2.CT2_CREDIT <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CCC    >= ? AND CT2.CT2_CCC    <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_ITEMC  >= ? AND CT2.CT2_ITEMC  <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CLVLCR >= ? AND CT2.CT2_CLVLCR <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DC IN ('2','3') " + CRLF
	If FieldPos("CT2_EC05CR") > 0
		cQuery+= "			AND CT2.CT2_EC05CR >= ? AND CT2.CT2_EC05CR <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC06CR") > 0
		cQuery+= "			AND CT2.CT2_EC06CR >= ? AND CT2.CT2_EC06CR <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC07CR") > 0
		cQuery+= "			AND CT2.CT2_EC07CR >= ? AND CT2.CT2_EC07CR <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC08CR") > 0
		cQuery+= "			AND CT2.CT2_EC08CR >= ? AND CT2.CT2_EC08CR <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC09CR") > 0
		cQuery+= "			AND CT2.CT2_EC09CR >= ? AND CT2.CT2_EC09CR <= ? " + CRLF
	EndIf
	cQuery+= "		UNION ALL " + CRLF
	cQuery+= "		SELECT  " + CRLF
	cQuery+= "			CT2_FILIAL    AS FILIAL, " + CRLF
	cQuery+= "			SUBSTRING(CT2_DATA,1,4) AS ANO, " + CRLF
	cQuery+= "			SUBSTRING(CT2_DATA,5,2) AS MES, " + CRLF
	cQuery+= "			NJ7.NJ7_DESCRI AS MOEDA, " + CRLF
	cQuery+= "			'DEBITO' AS TIPO, " + CRLF
	cQuery+= "			CT2_DEBITO    AS CONTA, " + CRLF
	cQuery+= "			CT2_CCD       AS CENTRO_CUSTO, " + CRLF
	cQuery+= "			CT2_ITEMD     AS ITEM_CONTABIL, " + CRLF
	cQuery+= "			CT2_CLVLDB    AS CLASSE_VALOR, " + CRLF
	cQuery+= "			ISNULL(CT2_DATA,'') DDATA, " + CRLF
	cQuery+= "			ISNULL(CT2_TPSALD,'') TPSALD, " + CRLF 
	cQuery+= "			ISNULL(CT2_DC,'') DC, " + CRLF
	cQuery+= "			ISNULL(CT2_LOTE,'') LOTE, " + CRLF
	cQuery+= "			ISNULL(CT2_SBLOTE,'') SUBLOTE, " + CRLF
	cQuery+= "			ISNULL(CT2_DOC,'') DOC, " + CRLF
	cQuery+= "			ISNULL(CT2_LINHA,'') LINHA, " + CRLF
	cQuery+= "			ISNULL(CT2_CREDIT,'') XPARTIDA, " + CRLF
	cQuery+= "			ISNULL(CT2_HIST,'') HIST, " + CRLF
	cQuery+= "			ISNULL(CT2_SEQHIS,'') SEQHIS, " + CRLF
	cQuery+= "			ISNULL(CT2_SEQLAN,'') SEQLAN, " + CRLF
	cQuery+= "			ISNULL(CT2_EMPORI,'') EMPORI, " + CRLF
	cQuery+= "			ISNULL(CT2_FILORI,'') FILORI, " + CRLF
	If FieldPos("CT2_EC05DB") > 0
		cQuery+= "CT2_EC05DB    AS ENT05, " + CRLF
	Else
		cQuery+= " ''     AS ENT05, " + CRLF
	EndIf
	If FieldPos("CT2_EC06DB") > 0
		cQuery+= "CT2_EC06DB    AS ENT06, " + CRLF
	Else
		cQuery+= " ''     AS ENT06, " + CRLF
	EndIf
	If FieldPos("CT2_EC07DB") > 0
		cQuery+= "CT2_EC07DB    AS ENT07, " + CRLF
	Else
		cQuery+= " ''     AS ENT07, " + CRLF
	EndIf
	If FieldPos("CT2_EC08DB") > 0
		cQuery+= "CT2_EC08DB    AS ENT08, " + CRLF
	Else
		cQuery+= " ''     AS ENT08, " + CRLF
	EndIf
	If FieldPos("CT2_EC09DB") > 0
		cQuery+= "CT2_EC09DB    AS ENT09, " + CRLF
	Else
		cQuery+= " ''     AS ENT09, " + CRLF
	EndIf
	cQuery+= "			CT2_MSUIDT    AS MSUIDT, " + CRLF
	cQuery+= "			CT2_VALOR*-1  AS SALDO, " + CRLF
	cQuery+= "			CASE  " + CRLF
	cQuery+= "				WHEN CT2.D_E_L_E_T_ = ' ' THEN 'NAO' ELSE 'SIM' " + CRLF  
	cQuery+= "			END AS DELETADO " + CRLF
	cQuery+= "		FROM "+RetSqlName("CT2")+" CT2 " + CRLF
	cQuery+= "			INNER JOIN "+RetSqlName("NJ7")+" NJ7 ON ('0'+NJ7.NJ7_CODPRO = CT2.CT2_MOEDLC) " + CRLF
	cQuery+= "		WHERE   " + CRLF
	cQuery+= "			CT2.CT2_FILIAL     >= ?  AND CT2.CT2_FILIAL <= ? " + CRLF 
	cQuery+= "			AND CT2.CT2_DATA   >= ?  AND CT2.CT2_DATA   <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DEBITO >= ?  AND CT2.CT2_DEBITO <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CCD    >= ?  AND CT2.CT2_CCD    <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_ITEMD  >= ?  AND CT2.CT2_ITEMD  <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_CLVLDB >= ?  AND CT2.CT2_CLVLDB <= ? " + CRLF
	cQuery+= "			AND CT2.CT2_DC IN ('1','3') " + CRLF
	If FieldPos("CT2_EC05DB") > 0
		cQuery+= "			AND CT2.CT2_EC05DB >= ? AND CT2.CT2_EC05DB <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC06DB") > 0
		cQuery+= "			AND CT2.CT2_EC06DB >= ? AND CT2.CT2_EC06DB <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC07DB") > 0
		cQuery+= "			AND CT2.CT2_EC07DB >= ? AND CT2.CT2_EC07DB <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC08DB") > 0
		cQuery+= "			AND CT2.CT2_EC08DB >= ? AND CT2.CT2_EC08DB <= ? " + CRLF
	EndIf
	If FieldPos("CT2_EC09DB") > 0
		cQuery+= "			AND CT2.CT2_EC09DB >= ? AND CT2.CT2_EC09DB <= ? " + CRLF
	EndIf
	cQuery+= "ORDER BY FILIAL, " + CRLF
	cQuery+= " 		 ANO, " + CRLF
	cQuery+= "		 MES, " + CRLF
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

	oPrepared:SetString(nParamOrder++, cFilialInicial)
	oPrepared:SetString(nParamOrder++, cFilialFinal)
	oPrepared:SetString(nParamOrder++, DTOS(CTOD(cDataInicial)))//CONVERTE S01/08/2025 PARA D 01/08/25 E APOS FORMATO DE BANCO S20250801
	oPrepared:SetString(nParamOrder++, DTOS(CTOD(cDataFinal)))
	oPrepared:SetString(nParamOrder++, cContaInicial)
	oPrepared:SetString(nParamOrder++, cContaFinal)
	oPrepared:SetString(nParamOrder++, cCCustoInicial)
	oPrepared:SetString(nParamOrder++, cCCustoFinal)
	oPrepared:SetString(nParamOrder++, cItemInicial)
	oPrepared:SetString(nParamOrder++, cItemFinal)
	oPrepared:SetString(nParamOrder++, cClasseInicial)
	oPrepared:SetString(nParamOrder++, cClasseFinal)
	If FieldPos("CT2_EC05DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt05Inicial)
		oPrepared:SetString(nParamOrder++, cEnt05Final)
	Endif
	If FieldPos("CT2_EC06DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt06Inicial)
		oPrepared:SetString(nParamOrder++, cEnt06Final)
	EndIf
	If FieldPos("CT2_EC07DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt07Inicial)
		oPrepared:SetString(nParamOrder++, cEnt07Final)
	EndIf
	If FieldPos("CT2_EC08DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt08Inicial)
		oPrepared:SetString(nParamOrder++, cEnt08Final)
	EndIf
	If FieldPos("CT2_EC05DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt09Inicial)
		oPrepared:SetString(nParamOrder++, cEnt09Final)
	EndIf
	
	oPrepared:SetString(nParamOrder++, cFilialInicial)
	oPrepared:SetString(nParamOrder++, cFilialFinal)
	oPrepared:SetString(nParamOrder++, DTOS(CTOD(cDataInicial)))//CONVERTE S01/08/2025 PARA D 01/08/25 E APOS FORMATO DE BANCO S20250801	
	oPrepared:SetString(nParamOrder++, DTOS(CTOD(cDataFinal)))
	oPrepared:SetString(nParamOrder++, cContaInicial)
	oPrepared:SetString(nParamOrder++, cContaFinal)
	oPrepared:SetString(nParamOrder++, cCCustoInicial)
	oPrepared:SetString(nParamOrder++, cCCustoFinal)
	oPrepared:SetString(nParamOrder++, cItemInicial)
	oPrepared:SetString(nParamOrder++, cItemFinal)
	oPrepared:SetString(nParamOrder++, cClasseInicial)
	oPrepared:SetString(nParamOrder++, cClasseFinal)
	If FieldPos("CT2_EC05DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt05Inicial)
		oPrepared:SetString(nParamOrder++, cEnt05Final)
	EndIf
	If FieldPos("CT2_EC06DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt06Inicial)
		oPrepared:SetString(nParamOrder++, cEnt06Final)
	EndIf
	If FieldPos("CT2_EC07DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt07Inicial)
		oPrepared:SetString(nParamOrder++, cEnt07Final)
	EndIf
	If FieldPos("CT2_EC08DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt08Inicial)
		oPrepared:SetString(nParamOrder++, cEnt08Final)
	EndIf
	If FieldPos("CT2_EC09DB") > 0
		oPrepared:SetString(nParamOrder++, cEnt09Inicial)
		oPrepared:SetString(nParamOrder++, cEnt09Final)
	EndIf

	cQuery := oPrepared:GetFixQuery()
	oPrepared:destroy()
	freeObj(oPrepared)

	If Select(ctempCon) > 0
		dbSelectArea(ctempCon)
		ctempCon->(dbCloseArea())
		ctempCon := GetNextAlias()
	Endif

	MPSysOpenQuery(cQuery, ctempCon)

	oJBalanc["sucesso"]      := .T.
	oJBalanc["mensagem"]   	 := cMsg
	oJBalanc["codigo"]	  	 := nStatusCode
Return oJBalanc

Function BalanVldPrms(ojBody as json, aFils as array)
    local cParamFil   as character
    local nI      as numeric
    local cMsg   as character
    local lOK    as logical
    local lFilial as logical
    local oJRes  as json
    local aField as array
	local cCgc   as character	
    local aAllFils as array
    Local cEmpresa as character	

    oJRes :=  JsonObject():new()
    cMSg  := ""
    lOk   := .T.

    if Vazio(oJBody["CNPJ"]) == .F.
        aField:= {"CNPJ", "DATA_FINAL", "DATA_INICIAL"}
        If oJBody["INDICADORES"]== 1 
            cCgc  := oJBody["CNPJ"]
        Else
            cCgc  := substr(oJBody["CNPJ"], 1, 8)
        EndIf
    else
        aField:= {"FILIAL", "DATA_FINAL", "DATA_INICIAL"}
    endif

    for nI:=1 to (len(aField))
        if(vazio(ojBody[ aField[nI] ]))
            cMsg+= STR0005 + aField[nI] + STR0002 // "Campo: " " inválido"
            lOK := .F.
        endif   
    next
    If lOK .and. oJBody["INDICADORES"]== 1 
        If ! VALTYPE(ojBody["CODIGO_EXTERNO"]) == 'A' .or. Empty(ojBody["CODIGO_EXTERNO"])
            cMsg+= STR0005 + "CODIGO_EXTERNO" + STR0002 // "Campo: " " inválido"
            lOK := .F.
        EndIf
    EndIF

    if lOk
        if vazio(ojBody["CNPJ"]) == .F.
            aAllFils := fwLoadSm0(.F., .F.)
            lFilial := !vazio(ojBody["FILIAL"]) 
            For nI:=1 to len(aAllFils)
                If aAllFils[nI][1] == cEmpAnt .And. substr(aAllFils[nI][18], 1, len(cCgc)) == cCgc // Verificar apenas na empresa logada no tenantId
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
        else
            // Para acessar outro grupo empresa, deve ser enviado via tenantId
			cEmpresa := IIf(empty(ojBody["GRUPO_EMPRESA"]),"", ojBody["GRUPO_EMPRESA"])
            cParamFil := alltrim(separa( ojBody["FILIAL"], ";" )[1])

            If FWFilExist(cEmpresa, cParamFil) == .F.
                cMsg+= STR0001 +" "+ cParamFil +" "+ STR0003 +": "+ cEmpresa  // Filial + cParamFil + não existe na empresa  + cParamEmp
                lOK := .F.
            endif 
        endIf
    endIf

    oJRes["items"]  := {}
    oJRes["empresa"]:= cEmpresa
    oJRes["isok"]   := lOK
    oJRes["message"]:= cMsg
return oJRes

Function BalanVldEmp(cEmpresa as character)
	local oJRes  as json
	local lOK    as logical
	local cMsg   as character

	lOK  := .T.
	cMsg := ""

	If Empty(cEmpresa) .or. FWFilExist(cEmpresa) == .F.
		lOK  := .F.
		cMsg+= STR0006 + cEmpresa + STR0007  // "Empresa: "  + cEmpresa + " não encontrada."   
	Endif 

	oJRes :=  JsonObject():new()
    oJRes["isok"]   := lOK
    oJRes["message"]:= cMsg

Return oJRes


Function Ctr040getData(oJBody as json, aFils as array, cTableNam1 as character,cArqTmp as character)

	local cAlias		as character    
	local cWhere        as character
	local cQryFields	as character
	local cSubQryField	as character
	local aSelFil		as Array 		
	local cDataini  	as character	
	local cDataFim  	as character	
	local nImprContas   as numeric
	local cMoeda		as character
	local cTpSaldo  	as character
	local cFiltroSeg 	as character
	local cFiltroSegIni as character
	local cFiltroSegFim as character
	local cFiltroSegCon as character
	local nImpMovimento	as numeric
	local nDivide		as numeric
	local lVlrZerado    as logical
	local lImpAntLp		as logical
	local cDtPosAntLp	as character
	local lRecDesp0 	as logical
	local cGrpRecDesp   as character
	local aSetOfBook	as array
	Local cGetCodPla as character
	cGetCodPla := getCodPla()
	aSetOfBook := {/*CTN->CTN_CODIGO*/"", /*CTN->CTN_MASC1*/"",/*CTN->CTN_DECIM*/ 2,;
		/*CTN->CTN_PICTV*/"",/*CTN->CTN_PLAGER*/cGetCodPla,/*CTN->CTN_MASC2*/"",/*CTN->CTN_MASC3*/"",;
		/*CTN->CTN_MASC4*/ "",1,/*CTN_DESC*/"INDIC GESPLAN",/*CTN->CTN_PLREF*/"",/*CTN->CTN_VERSAO*/"" }
	
	cWhere 		 := ""
	cAlias		 := "CT7"
	cQryFields	 := ""
	cSubQryField := ""
	cTableNam1	 := ""
	cArqTmp		 := "" 
	aSelFil		 := {}

	cDataini 	 := ojBody["DATA_INICIAL"]				
	cDataFim  	 := ojBody["DATA_FINAL"]				
	nImprContas  := iif( Vazio(ojBody["IMPRIME_CONTAS"]),  3, ojBody["IMPRIME_CONTAS"]  )
	lVlrZerado   := iif( Vazio(ojBody["SALDOS_ZERADOS"]), .T., iif(ojBody["SALDOS_ZERADOS"] == 1, .T., .F.)   )	
	cMoeda		 := iif( Vazio(ojBody["MOEDA"]),  "01", ojBody["MOEDA"]  )	
	cTpSaldo     := iif( Vazio(ojBody["TIPO_DE_SALDO"]), "1", ojBody["TIPO_DE_SALDO"]  )	
	cFiltroSeg	 := iif( Vazio(ojBody["FILTRA_SEGMENTO_NO"]), padR(" ", tamSx3("CTM_SEGMEN")[1]) , ojBody["FILTRA_SEGMENTO_NO"]  )	  
	cFiltroSegIni:= iif( Vazio(ojBody["CONTEUDO_INI_SEGMEN"]),  "", ojBody["CONTEUDO_INI_SEGMEN"]  )	  
	cFiltroSegFim:= iif( Vazio(ojBody["CONTEUDO_FIM_SEGMEN"]),  "", ojBody["CONTEUDO_FIM_SEGMEN"]  )	  
	cFiltroSegCon:= iif( Vazio(ojBody["CONTEUDO_CONTIDO_EM"]),  "", ojBody["CONTEUDO_CONTIDO_EM"]  )	  
	nImpMovimento:= iif( Vazio(ojBody["IMPRIME_COLUNA_MOV"]),  1, ojBody["IMPRIME_COLUNA_MOV"]  )	  
	nDivide		 := iif( Vazio(ojBody["DIVIDE_POR"]),  1, ojBody["DIVIDE_POR"])	
	lImpAntLp	 := iif( Vazio(ojBody["POSICAO_ANT_L_P"]), .F., iif(ojBody["POSICAO_ANT_L_P"] = 2, .F., .T.) )	
	cDtPosAntLp	 := iif( Vazio(ojBody["DATA_LUCRO_PERDAS"]), ojBody["DATA_INICIAL"], ojBody["DATA_LUCRO_PERDAS"]  )		
	lRecDesp0 	 := iif( Vazio(ojBody["IGNORA_SL_ANT_REC_DES"]), .T., iif(ojBody["IGNORA_SL_ANT_REC_DES"] == 1, .T., .F.)  )	
	cGrpRecDesp  := iif( Vazio(ojBody["GRUPOS_RECEITAS_DESPESAS"]),  "", ojBody["GRUPOS_RECEITAS_DESPESAS"]  )	
	dDtZeraRD    := iif( Vazio(ojBody["DATA_SLD_ANT_RECEITAS_DESP"]), ojBody["DATA_INICIAL"], ojBody["DATA_SLD_ANT_RECEITAS_DESP"]  )
	if len(aFils)> 0 
		aSelFil := afils
	else		
		aSelFil		 := separa( ojBody["FILIAL"], ";" ) 
	endIf

	if nDivide >= 1 .AND. nDivide <= 4
		nDivide := {1, 100, 1000, 1000000}[nDivide]
	else 
		nDivide := 1
	EndIf
	
	CTGerPlan(,,, .F., @cArqTmp,;
	ctoD(cDataini), cToD(cDataFim), cAlias, "", ,,,,,,,, cMoeda,;
	cTpSaldo, aSetOfBook, cFiltroSeg, ;
	cFiltroSegIni, cFiltroSegFim, cFiltroSegCon,;
	.F.,.F.,,, lImpAntLP, ctoD(cDtPosAntLp)-1, nDivide, ;
	lVlrZerado,,,,,,,,,,,,,,.T.,"", lRecDesp0,;
	cGrpRecDesp, ctoD(dDtZeraRD)-1,,,,,,,,,aSelFil,,,,,,,,,,,,,,,@cTableNam1,,,,,ojBody["CODIGO_EXTERNO"])

Return cTableNam1

Function getCodPla() 
	Local cCodPla     := '' as Character
	Local cAliasCTS   := GetNextAlias() as Character

	If CTS->(FieldPos("CTS_ENTGRP")) > 0
		cQuery := "SELECT CTS_CODPLA"
		cQuery += " FROM " + RetSQLName("CTS")
		cQuery += " WHERE CTS_FILIAL = '" + xFilial("CTS") +"' AND CTS_ENTGRP = '1' AND  D_E_L_E_T_ = ' '"

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasCTS, .T., .F.)

		If (cAliasCTS)->(!EOF())
			cCodPla := (cAliasCTS)->CTS_CODPLA //Pega ultimo utilizado
		else
			cCodPla := MpSysExecScalar("SELECT MAX(CTS_CODPLA) NUMMAX FROM "+RetSqlName("CTS")+" WHERE CTS_FILIAL = '" + xFilial("CTS") + "' ", "NUMMAX")
			cCodPla := PadR(Soma1(cCodPla), TamSx3("CTS_CODPLA")[1])
		EndIf
	EndIf

	(cAliasCTS)->(dbCloseArea())

Return cCodPla

Function getfieldReturnGesp()
	local aField as array
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

