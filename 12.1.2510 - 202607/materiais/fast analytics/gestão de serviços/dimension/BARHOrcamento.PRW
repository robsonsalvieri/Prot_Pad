#INCLUDE "BADEFINITION.CH"

NEW ENTITY RHORCAMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BARHOrcamento
Visualiza as informacoes de Orcamento do RH.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BARHOrcamento from BAEntity
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
Method Setup( ) Class BARHOrcamento
	_Super:Setup("RHOrcamento", DIMENSION, "TFF")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARHOrcamento
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_TFF_TFF_FILIAL+TFF_COD>> AS BK_RH_ORCAMENTO, "
    cQuery +=   "TFF_COD AS COD_RH_ORCAMENTO, "
    cQuery +=   "TFF_LOCAL AS LOCAL_RH_ORCAMENTO, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
    cQuery += "FROM <<TFF_COMPANY>> TFF "
    cQuery += "WHERE "
    cQuery +=   "TFF.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_TFF_FILIAL>> "

Return cQuery
