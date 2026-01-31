#INCLUDE "BADEFINITION.CH"

NEW ENTITY XCONTRENTAL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Visualiza as informações BAXCONTRENTAL dos Contratos

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Class BAXCONTRENTAL from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAXCONTRENTAL
	_Super:Setup("Contratos", FACT, "FP0")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAXCONTRENTAL
	Local cQuery := ""

	cQuery += " SELECT <<KEY_COMPANY>> AS BK_EMPRESA, "
	cQuery += " <<KEY_FILIAL_FP0_FILIAL>> AS BK_FILIAL, "
	cQuery += " <<KEY_SA1_A1_FILIAL+A1_COD+A1_LOJA>> 		AS BK_CLIENTE, "
	cQuery += " <<KEY_CC2_CC2_EST+CC2_CODMUN>> 				AS BK_REGIAO,"
	cQuery += " <<KEY_SUS_US_FILIAL+US_COD>> 				AS BK_PROSP, "
	cQuery += " <<KEY_SA3_A3_FILIAL+A3_COD>> 				AS BK_GESTOR, "
	cQuery += " <<KEY_SE4_E4_FILIAL+E4_CODIGO>> 			AS BK_CONDICAO_DE_PAGAMENTO, "
	cQuery += " <<KEY_FPA_FPA_FILIAL+FPA_PROJET>> 			AS BK_LOCPROJ, "
	cQuery += " <<KEY_FP1_FP1_FILIAL+FP1_PROJET+FP1_OBRA>> 	AS BK_OBRAS, "
	cQuery += " CASE "
	cQuery += " 	WHEN FPA_GRUA = ' ' "
	cQuery += " 	THEN 'P |"+baInstance()+"|<<SQ4_COMPANY>>||' "
	cQuery += " 	ELSE 'P |"+baInstance()+"|<<SQ4_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(FPA_FILIAL, ' '))+'|'+RTRIM(COALESCE(FPA_GRUA, ' ')), ' '), '|') "
	cQuery += " END 										AS BK_CADBEM, "
	cQuery += " CASE FP0_STATUS "
	cQuery += "		WHEN '1' THEN 'EM ELABORACAO' "
	cQuery += " 	WHEN '2' THEN 'EM APROV/APROV' "
	cQuery += " 	WHEN '3' THEN 'EM APROV/APROV' "
	cQuery += " 	WHEN '4' THEN 'NAO APROVADO' "
	cQuery += " 	WHEN '5' THEN 'ATIVO' "
	cQuery += " 	WHEN '6' THEN 'DECLINADO' "
	cQuery += " 	WHEN '7' THEN 'DECLINADO' "
	cQuery += " 	WHEN '8' THEN 'FINALIZADO' "
	cQuery += " 	WHEN 'C' THEN 'DECLINADO' "
	cQuery += " END 										AS STATUS, "
	cQuery += " CASE "
	cQuery += " 	WHEN FPA_DTFIM <= GETDATE() AND FPA_TIPOSE<>'Z'	THEN 'ATRASADO' "
	cQuery += " 	WHEN FPA_DTSCRT<>' ' AND FPA_NFRET=' '			THEN 'FAT. PARADO' "
	cQuery += " 	ELSE 'FAT. EM DIA' "
	cQuery += " END 										AS SITUACAO, "
	cQuery += " FP0_PROJET AS PROJETO, "
	cQuery += " FP0_REVISA AS REVISAO, "
	cQuery += " CASE FP0_TIPOSE "
	cQuery += " 	WHEN 'T' THEN 'TRANSPORTE' "
	cQuery += " 	WHEN 'E' THEN 'EQUIPAMENTOS' "
	cQuery += " 	WHEN 'L' THEN 'LOCACAO' "
	cQuery += " END 										AS TIPO_SERV, "
	cQuery += " FP0_DATAS  									AS ENTREGA, "
	cQuery += " FP0_DTRETO 									AS RETORNO, "
	cQuery += " FP0_DTVALI 									AS VALIDADE, "
	cQuery += " FP0_DATINC 									AS DT_INCLUSAO, "
	cQuery += " FP0_CONVIT 									AS CONVITE, "
	cQuery += " FP0_VALCON 									AS VLR_CON, "
	cQuery += " FP0_POSSIB 									AS POSSIBILID, "
	cQuery += " FP0_UNINEG 									AS UNIDADE, "
	cQuery += " CASE FP0_MINPFT "
	cQuery += " 	WHEN '0' THEN 'SINTETICO' "
	cQuery += " 	WHEN '1' THEN 'ANALITICO' "
	cQuery += " END 										AS TIPO_FAT, "
	cQuery += " FPA.FPA_PREDIA 								AS QTDE_BASE, "
	cQuery += " FPA.FPA_MINDIA 								AS MIN_H_SEM, "
	cQuery += " FPA.FPA_MINMES 								AS MIN_H_MES, "
	cQuery += " FPA.FPA_QUANT  								AS QTDE, "
	cQuery += " FPA.FPA_ACRESC 								AS ACRESCIMO, "
	cQuery += " FPA.FPA_PRCUNI 								AS VAL_UNIT, "
	cQuery += " FPA.FPA_VLBRUT 								AS VAL_BRUTO, "
	cQuery += " FPA.FPA_PDESC  								AS PERC_DESC, "
	cQuery += " FPA.FPA_VRHOR  								AS VLR_BASE, "
	cQuery += " FPA.FPA_GUIMON 								AS VLR_FRETE_IDA, "
	cQuery += " FPA.FPA_GUIDES 								AS VLR_FR_VOLTA, "
	cQuery += " FPA.FPA_VRISS  								AS VLR_ISS, "
	cQuery += " FPA.FPA_VRSEGU 								AS VLR_SEGURO, "
	cQuery += " FPA.FPA_VRHOR * FPA.FPA_QUANT 				AS VL_TOT_LOC, "
	cQuery += " (FPA.FPA_VRHOR *FPA.FPA_QUANT)+(FPA.FPA_VRSEGU+FPA.FPA_GUIMON+FPA.FPA_GUIDES) AS VL_TOT_PROJ, "
	cQuery += " <<CODE_INSTANCE>> 							AS INSTANCIA "
	cQuery += " FROM <<FP0_COMPANY>> FP0 "
	cQuery += " LEFT JOIN <<FP1_COMPANY>> FP1 ON FP1_FILIAL = <<SUBSTR_FP1_FP0_FILIAL>> AND AND FP1.FP1_PROJET=FP0.FP0_PROJET AND FP0.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN <<FPA_COMPANY>> FPA ON FPA_FILIAL = <<SUBSTR_FPA_FP0_FILIAL>> AND FPA.FPA_PROJET=FP1.FP1_PROJET AND FPA.FPA_OBRA=FP1.FP1_OBRA AND FPA_TIPOSE<>'S' AND FPA.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN <<SA1_COMPANY>> SA1 ON SA1_FILIAL = <<SUBSTR_SA1_FP0_FILIAL>> AND SA1.A1_COD = FP0.FP0_CLI AND SA1.A1_LOJA=FP0.FP0_LOJA AND SA1.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN <<SUS_COMPANY>> SUS ON SUS_FILIAL = <<SUBSTR_SUS_FP0_FILIAL>> AND US_COD=FP0_PROSPE AND US_LOJA=FP0_LOJAP AND SUS.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN <<SA3_COMPANY>> SA3 ON SA3_FILIAL = <<SUBSTR_SA3_FP0_FILIAL>> AND FP0.FP0_VENDED=SA3.A3_COD AND SA3.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN <<SE4_COMPANY>> SE4 ON SE4_FILIAL = <<SUBSTR_SE4_FP0_FILIAL>> AND FP0.FP0_CONDPG=SE4.E4_CODIGO AND SE4.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN <<CC2_COMPANY>> CC2 ON CC2_FILIAL = <<SUBSTR_CC2_FP0_FILIAL>> AND CC2_EST=A1_EST AND CC2_CODMUN AND A1_COD_MUN AND CC2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE FP0.FP0_STATUS<>'A' AND FP0.FP0_STATUS<>'B' AND FP0.D_E_L_E_T_=' ' "

Return cQuery
