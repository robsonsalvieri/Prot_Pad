#INCLUDE "BADEFINITION.CH"

NEW ENTITY CTBEMRENTAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BACtBemRental
Visualiza as informações da Central de Bens

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Class BACtBemRental from BAEntity
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
Method Setup( ) Class BACtBemRental
	_Super:Setup("CentralBens", FACT, "FQ4")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACtBemRental
	Local cQuery := ""

	cQuery += " SELECT "
	cQuery += " <<KEY_SQ4_T9_FILIAL+T9_CODBEM>> 		AS BK_CADBEM, "
	cQuery += " <<KEY_FQ4_FQ4_FILIAL+FQ4_STATUS>> 		AS BK_STATUS, "
	cQuery += " <<KEY_SA1_A1_FILIAL+A1_COD+A1_LOJA>> 	AS BK_CLIENTE, "
	cQuery += " CASE "
	cQuery += " 	WHEN A1_COD_MUN = ' ' THEN 'P |"+baInstance()+"|<<CC2_COMPANY>>|'+ COALESCE(NULLIF(RTRIM( COALESCE(A1_EST,' ') ),' '), '|') "
	cQuery += " 	ELSE 'P |"+baInstance()+"|<<CC2_COMPANY>>|'+ COALESCE(NULLIF(RTRIM( COALESCE(A1_EST, ' ') )+RTRIM( COALESCE(A1_COD_MUN, ' ') ), ' '), '|') "
	cQuery += " END  AS BK_REGIAO, "
	cQuery += "     SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-12, 4) + SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-15, 2) + SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-18, 2) AS DATA_EVENTO, "
	cQuery += " FQ4.FQ4_POSCON							AS HORIMETRO, "
	cQuery += " FQ4.FQ4_NFREM							AS DOCUMENTO, "
	cQuery += " FQ4.FQ4_SERREM							AS SERIE, "
	cQuery += " CASE "
	cQuery += " 	WHEN FQ4_PROJET = ' ' "
	cQuery += "		THEN 'P |"+baInstance()+"|<<FPA_COMPANY>>||' "
	cQuery += " 	ELSE 'P |"+baInstance()+"|<<FPA_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(T9_FILIAL, ' '))+'|'+RTRIM(COALESCE(FQ4_PROJET, ' ')), ' '), '|')  "
	cQuery += " END AS BK_LOCPROJ, "
	cQuery += " CASE "
	cQuery += " 	WHEN FQ4_OBRA = ' ' THEN 'P |"+baInstance()+"|<<FP1_COMPANY>>||' "
	cQuery += " 	ELSE 'P |"+baInstance()+"|<<FP1_COMPANY>>|' + COALESCE(NULLIF(Rtrim( COALESCE(T9_FILIAL, ' ') )+'|'+Rtrim( COALESCE( FQ4_PROJET, ' ') )+Rtrim( COALESCE(FQ4_OBRA, ' ') ), ' '), '|') "
	cQuery += " END AS BK_OBRAS, "
	cQuery += " FQ4.FQ4_AS								AS NUM_AS, "
	cQuery += " FQ4.FQ4_DTINI							AS DATA_INICIO, "
	cQuery += " FQ4.FQ4_DTFIM							AS DATA_FIM, "
	cQuery += " FQ4.FQ4_PREDES							AS PREV_RET, "
	cQuery += " <<CODE_INSTANCE>> 						AS INSTANCIA "
	cQuery += " FROM <<FQ4_COMPANY>> FQ4 "
	cQuery += " LEFT JOIN <<ST9_COMPANY>> ST9 ON FQ4.FQ4_CODBEM = ST9.T9_CODBEM  AND T9_FILIAL = <<SUBSTR_ST9_FQ4_FILIAL>> "
	cQuery += " LEFT JOIN <<SA1_COMPANY>> SA1 ON SA1.A1_COD=FQ4.FQ4_CODCLI AND SA1.A1_LOJA=FQ4.FQ4_LOJCLI AND A1_FILIAL = <<SUBSTR_SA1_FQ4_FILIAL>> "
	cQuery += " LEFT JOIN <<ST6_COMPANY>> ST6 ON ST6.T6_CODFAMI = FQ4.FQ4_CODFAM AND T6_FILIAL = <<SUBSTR_ST6_FQ4_FILIAL>> "
	cQuery += " WHERE  FQ4.D_E_L_E_T_ = ' ' "

Return cQuery
