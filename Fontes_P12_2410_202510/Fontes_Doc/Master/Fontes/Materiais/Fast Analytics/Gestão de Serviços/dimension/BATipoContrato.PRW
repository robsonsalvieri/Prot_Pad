#INCLUDE "BADEFINITION.CH"

NEW ENTITY TIPOCONTRATO

//-------------------------------------------------------------------
/*/{Protheus.doc} BATipoContrato
Visualiza as informacoes de Tipo de Contrato.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BATipoContrato from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BATipoContrato
	_Super:Setup("Tipo de Contrato", DIMENSION, "CN1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BATipoContrato
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_CN1_CN1_FILIAL+CN1_CODIGO>> AS BK_TIPO_CONTRATO, "
    cQuery +=   "CN1_CODIGO AS COD_TIPO_CONTRATO, "
    cQuery +=   "CN1_DESCRI AS DESC_TIPO_CONTRATO, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA"
    cQuery += "FROM <<CN1_COMPANY>> CN1 "
    cQuery += "WHERE "
    cQuery +=   "CN1.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_CN1_FILIAL>> "

Return cQuery
