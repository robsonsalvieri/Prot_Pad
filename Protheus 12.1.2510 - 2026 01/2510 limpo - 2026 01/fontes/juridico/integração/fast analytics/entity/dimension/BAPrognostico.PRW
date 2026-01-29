#INCLUDE "BADEFINITION.CH"

NEW ENTITY PROGNOSTICO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPrognostico
Visualiza as informacoes dos Prognosticos.

@author  henrique.cesar
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Class BAPrognostico from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  henrique.cesar
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPrognostico 
	_Super:Setup("Prognostico", DIMENSION, "NQ7")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPrognostico
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQ7_NQ7_FILIAL+NQ7_COD>> AS BK_PROGNOSTICO,"
	cQuery += " 		NQ7.NQ7_COD AS COD_DO_PROGNOSTICO,"
	cQuery += " 		NQ7.NQ7_DESC AS DESC_DO_PROGNOSTICO,"
	cQuery += "			NQ7.NQ7_TIPO AS TIPO_DO_PROGNOSTICO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQ7_COMPANY>> NQ7" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQ7.D_E_L_E_T_ = ' ' "
	cQuery += "     <<AND_XFILIAL_NQ7_FILIAL>> "
Return cQuery
