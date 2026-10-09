#INCLUDE "BADEFINITION.CH"

NEW ENTITY SEGMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BASegmento
Visualiza as informacoes de Segmento.

@author  Angelo Lee
@since   26/10/2018
/*/
//-------------------------------------------------------------------
Class BASegmento from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Angelo Lee
@since   26/10/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BASegmento
	_Super:Setup("Segmento", DIMENSION, "AOV")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Angelo Lee
@since   26/10/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BASegmento
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_AOV_AOV_FILIAL+AOV_CODSEG>> AS BK_SEGMENTO, "
    cQuery +=   "AOV_CODSEG AS CODIGO_SEGMENTO, "
    cQuery +=   "AOV_DESSEG AS DESCRICAO_SEGMENTO, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
    cQuery += "FROM <<AOV_COMPANY>> AOV "
    cQuery += "WHERE "
    cQuery +=   "AOV.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_AOV_FILIAL>> "

Return cQuery
