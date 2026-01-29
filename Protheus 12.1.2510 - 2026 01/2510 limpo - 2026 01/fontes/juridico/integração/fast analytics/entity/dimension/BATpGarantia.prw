#INCLUDE "BADEFINITION.CH"

NEW ENTITY TPGARANTIA

//-------------------------------------------------------------------
/*/{Protheus.doc} BATpGarantia
Visualiza as informacoes sobre Tipos de Garantia.              

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BATpGarantia from BAEntity
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
Method Setup() class BATpGarantia
	_Super:Setup("TpGarantia", DIMENSION, "NQW" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BATpGarantia
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQW_NQW_FILIAL+NQW_COD>> AS BK_TIPO_GARANTIA,"
	cQuery += " 		NQW.NQW_COD AS COD_TIPO_GARANTIA,"
	cQuery += " 		NQW.NQW_DESC AS DESC_TIPO_GARANTIA,"
	cQuery += " 		NQW.NQW_TIPO AS TIPO_GARANTIA,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQW_COMPANY>> NQW" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQW.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NQW_FILIAL>> "
Return cQuery
