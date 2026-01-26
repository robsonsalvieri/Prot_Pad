#INCLUDE "BADEFINITION.CH"

NEW ENTITY PROPOSTA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProposta
Visualiza as informacoes de Proposta.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BAProposta from BAEntity
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
Method Setup( ) Class BAProposta
	_Super:Setup("Proposta", DIMENSION, "ADY")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAProposta
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_ADY_ADY_FILIAL+ADY_PROPOS+ADY_PREVIS>> AS BK_PROPOSTA, "
    cQuery +=   "ADY_PROPOS AS NUM_PROPOSTA, "
    cQuery +=   "ADY_PREVIS AS REVISAO_PROPOSTA, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
    cQuery += "FROM <<ADY_COMPANY>> ADY "
    cQuery += "WHERE "
    cQuery +=   "ADY.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_ADY_FILIAL>> "

Return cQuery
