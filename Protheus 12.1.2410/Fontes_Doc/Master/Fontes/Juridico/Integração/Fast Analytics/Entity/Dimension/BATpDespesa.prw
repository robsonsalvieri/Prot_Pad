#INCLUDE "BADEFINITION.CH"

NEW ENTITY TPDESPESA

//-------------------------------------------------------------------
/*/{Protheus.doc} BATpDespesa
Visualiza as informacoes sobre as Despesas Juridicas. 

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BATpDespesa from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrao.  

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------  
Method Setup() class BATpDespesa
	_Super:Setup("TpDespesa", DIMENSION, "NSR" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BATpDespesa
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NSR_NSR_FILIAL+NSR_COD>> AS BK_TIPO_DESPESA,"
	cQuery += " 		NSR.NSR_COD AS COD_TIPO_DESPESA,"
	cQuery += " 		NSR.NSR_DESC AS DESC_TIPO_DESPESA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NSR_COMPANY>> NSR" 
	cQuery += " 	WHERE "
	cQuery += "	   	NSR.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NSR_FILIAL>> " 

Return cQuery
