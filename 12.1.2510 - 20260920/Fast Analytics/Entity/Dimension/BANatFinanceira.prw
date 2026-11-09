#INCLUDE "BADEFINITION.CH"

NEW ENTITY NATFINANCEIRA
//-------------------------------------------------------------------
/*/{Protheus.doc} BANatFinanceira
visualiza as informacoes Natureza Financeira

@author  BI TEAM
@since   29/12/2017
/*/
//-------------------------------------------------------------------
Class BANatFinanceira from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrao.  

@author  BI TEAM
@since   29/12/2017
/*/
//-------------------------------------------------------------------  
Method Setup() class BANatFinanceira
	_Super:Setup("NatFinanceira", DIMENSION, "SED" ) //"Natureza Financeira"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  BI TEAM
@since   29/12/2017
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BANatFinanceira
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_SED_ED_FILIAL+ED_CODIGO>> AS BK_NAT_FINANCEIRA,"
	cQuery += " 		SED.ED_CODIGO AS COD_NAT_FINANCEIRA,"
	cQuery += " 		SED.ED_DESCRIC AS DESC_NAT_FINANCEIRA,"
	cQuery += " 		SED.ED_PAI AS PAI_NAT_FINANCEIRA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<SED_COMPANY>> SED" 
	cQuery += " 	WHERE "
	cQuery += "	   	SED.D_E_L_E_T_ = ' '"
	cQuery += "	   	<<AND_XFILIAL_ED_FILIAL>> "
Return cQuery
