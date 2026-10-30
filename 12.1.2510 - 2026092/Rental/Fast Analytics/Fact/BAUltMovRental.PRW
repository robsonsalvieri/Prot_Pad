#INCLUDE "BADEFINITION.CH"

NEW ENTITY ULTMOVRENTAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BAUltMovRental
Visualiza as informações das Últimas Movimentações.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Class BAUltMovRental from BAEntity
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
Method Setup( ) Class BAUltMovRental
	_Super:Setup("UltimaMovimentacao", FACT, "FQ4")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAUltMovRental
	Local cQuery := ""

	cQuery += "SELECT 'P |"+baInstance()+"|<<ST9_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(T9_FILIAL, ' '))+'|'+RTRIM(COALESCE(T9_CODBEM, ' ')), ' '), '|') AS BK_CADBEM,"
	cQuery += "                 'P |"+baInstance()+"|<<ST9_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(FQ4_FILIAL, ' '))+'|'+RTRIM(COALESCE(FQ4_STATUS, ' ')), ' '), '|') AS BK_STATUS,"
	cQuery += "                 'P |"+baInstance()+"|<<SA1_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(A1_FILIAL, ' '))+'|'+RTRIM(COALESCE(A1_COD, ' '))+RTRIM(COALESCE(A1_LOJA, ' ')), ' '), '|') AS BK_CLIENTE,"
	cQuery += "                 CASE"
	cQuery += "                     WHEN A1_COD_MUN = ' ' THEN 'P |"+baInstance()+"|<<CC2_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(A1_EST, ' ')), ' '), '|')"
	cQuery += "                     ELSE 'P |"+baInstance()+"|<<CC2_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(A1_EST, ' '))+RTRIM(COALESCE(A1_COD_MUN, ' ')), ' '), '|')"
	cQuery += "                 END AS BK_REGIAO,"
	cQuery += "                 CASE"
	cQuery += "                     WHEN FQ4_PROJET = ' ' THEN 'P |"+baInstance()+"|<<FPA_COMPANY>>||'"
	cQuery += "                     ELSE 'P |"+baInstance()+"|<<FPA_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(FP1_FILIAL, ' '))+'|'+RTRIM(COALESCE(FQ4_PROJET, ' ')), ' '), '|')"
	cQuery += "                 END AS BK_LOCPROJ,"
	cQuery += "                 CASE"
	cQuery += "                     WHEN FQ4_OBRA = ' ' THEN 'P |"+baInstance()+"|<<FP1_COMPANY>>||'"
	cQuery += "                     ELSE 'P |"+baInstance()+"|<<FP1_COMPANY>>|' + COALESCE(NULLIF(RTRIM(COALESCE(FP1_FILIAL, ' '))+'|'+RTRIM(COALESCE(FQ4_PROJET, ' '))+RTRIM(COALESCE(FQ4_OBRA, ' ')), ' '), '|')"
	cQuery += "                 END AS BK_OBRAS,"
	cQuery += "                CASE"
	cQuery += " 					WHEN LEN(SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-18, 10)) - LEN(replace(SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-18, 10), '/', '')) = 2"
	cQuery += " 					THEN SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-12, 4) + SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-15, 2) + SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-18, 2)"
	cQuery += " 				ELSE"
	cQuery += " 				''"
	cQuery += " 				END AS DATA_EVENTO,"
	cQuery += "                <<CODE_INSTANCE>> 	AS INSTANCIA "
	cQuery += " FROM <<FQ4_COMPANY>> FQ4"
	cQuery += " INNER JOIN <<ST9_COMPANY>> ST9 ON T9_FILIAL = <<SUBSTR_ST9_FQ4_FILIAL>> and FQ4.FQ4_CODBEM = ST9.T9_CODBEM"
	cQuery += " AND ST9.D_E_L_E_T_ = ' '"
	cQuery += " AND ST9.T9_SITBEM = 'A'"
	cQuery += " LEFT JOIN <<SA1_COMPANY>> SA1 ON A1_FILIAL = <<SUBSTR_SA1_T9_FILIAL>> and SA1.A1_COD=FQ4.FQ4_CODCLI"
	cQuery += " AND SA1.A1_LOJA=FQ4.FQ4_LOJCLI"
	cQuery += " AND SA1.D_E_L_E_T_ = ' '
	cQuery += " LEFT JOIN <<ST6_COMPANY>> ST6 ON ST6.T6_CODFAMI = FQ4.FQ4_CODFAM"
	cQuery += " AND ST6.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN <<FPA_COMPANY>> FPA ON FPA.FPA_PROJET = FQ4.FQ4_PROJET AND FPA.FPA_OBRA = FQ4.FQ4_OBRA AND FPA.FPA_AS = FQ4.FQ4_AS AND FPA.FPA_GRUA = FQ4.FQ4_CODBEM AND FPA.D_E_L_E_T_ = ''"
	cQuery += " LEFT JOIN <<FP1_COMPANY>> FP1 ON FP1.FP1_PROJET = FPA.FPA_PROJET AND FP1.FP1_OBRA = FPA.FPA_OBRA AND FP1.D_E_L_E_T_ = '' AND FP1.FP1_FILIAL = FPA.FPA_FILIAL"
	cQuery += " WHERE FQ4.D_E_L_E_T_ = ' '"
	cQuery += " AND FQ4.FQ4_SEQ = (SELECT MAX(B.FQ4_SEQ) FROM "
	cQuery += " <<FQ4_COMPANY>> B WHERE B.FQ4_CODBEM = FQ4.FQ4_CODBEM AND B.D_E_L_E_T_ = ' ')"
	cQuery += " UNION"
	cQuery += " SELECT "
	cQuery += " 'P |"+baInstance()+"|<<ST9_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(T9_FILIAL, ' '))+'|'+RTRIM(COALESCE(T9_CODBEM, ' ')), ' '), '|') AS BK_CADBEM,"
	cQuery += " 'P |"+baInstance()+"|<<ST9_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(FQ4_FILIAL, ' '))+'|'+RTRIM(COALESCE(T9_STATUS, ' ')), ' '), '|') AS BK_STATUS,"
	cQuery += " 'P |"+baInstance()+"|<<SA1_COMPANY>>||' AS BK_CLIENTE,"
	cQuery += " 'P |"+baInstance()+"|<<CC2_COMPANY>>||' AS BK_REGIAO,"
	cQuery += " 'P |"+baInstance()+"|<<FPA_COMPANY>>||' AS BK_LOCPROJ,"
	cQuery += " 'P |"+baInstance()+"|<<FP1_COMPANY>>||' AS BK_OBRAS,"
	cQuery += " '' AS DATA_EVENTO,"
	cQuery += "  <<CODE_INSTANCE>>  AS INSTANCIA"
	cQuery += " FROM <<ST9_COMPANY>> AS ST9"
	cQuery += " WHERE ST9.D_E_L_E_T_ = ''"
	cQuery += " AND NOT EXISTS (SELECT FQ4A.FQ4_CODBEM FROM <<FQ4_COMPANY>> FQ4A WHERE FQ4_COBEM = ST9.T9_CODBEM) AND D_E_L_E_T_ = '')"
	cQuery += " AND ST9.T9_SITBEM = 'A'"

Return cQuery

