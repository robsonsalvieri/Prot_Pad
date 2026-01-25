#INCLUDE "BADEFINITION.CH"

NEW ENTITY REGIAORENTAL 

//-------------------------------------------------------------------
/*/{Protheus.doc} BARegiaoRental
Visualiza as informacoes das Regiões.

@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Class BARegiaoRental from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BARegiaoRental
	_Super:Setup("RegiaoRental", DIMENSION, "SX5")
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARegiaoRental
	Local cQuery := ""
 
	cQuery += " SELECT "
	cQuery += " 		<<KEY_SX5_X5_CHAVE>> 	AS BK_REGIAO,"
	cQuery += " 		SX5.X5_CHAVE			AS COD_ESTADO,"
	cQuery += " 		SX5.X5_DESCRI 			AS DESC_ESTADO,"
	cQuery += " 		' '	 					AS COD_MUNICIPIO,"
	cQuery += " 		' ' 					AS DESC_MUNICIPIO,"
	cQuery += "         <<CODE_INSTANCE>> 		AS INSTANCIA"
	cQuery += " 	FROM <<SX5_COMPANY>> SX5" 
	cQuery += " 	WHERE "
	cQuery += " 	SX5.X5_TABELA = '12' AND "
	cQuery += "	   	SX5.D_E_L_E_T_ = ' '" 
	cQuery += " UNION ALL "
	cQuery += " 	SELECT "
	cQuery += " 	<<KEY_CC2_CC2_EST+CC2_CODMUN>> AS BK_REGIAO,"
	cQuery += " 		CC2.CC2_EST        		AS COD_ESTADO,"
	cQuery += " 		(SELECT DISTINCT SX5.X5_DESCRI "
	cQuery += " 		FROM   <<SX5_COMPANY>> SX5 "
	cQuery += " 		WHERE  SX5.X5_TABELA = '12' "
	cQuery += " 		AND SX5.X5_CHAVE = CC2.CC2_EST "
	cQuery += " 		AND SX5.D_E_L_E_T_ = ' ') AS DESC_ESTADO, "
	cQuery += " 		CC2.CC2_CODMUN 			AS COD_MUNICIPIO, "
	cQuery += " 		CC2.CC2_MUN 			AS DESC_MUNICIPIO, "
	cQuery += " 		<<CODE_INSTANCE>>		AS INSTANCIA "
	cQuery += " 		FROM   <<CC2_COMPANY>> CC2 "
	cQuery += " 		WHERE  CC2.D_E_L_E_T_ = ' ' 	"
Return cQuery