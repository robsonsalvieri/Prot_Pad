#INCLUDE "BADEFINITION.CH"

NEW ENTITY ATENDENTE

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAtendente
Visualiza as informacoes de Atendente.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BAAtendente from BAEntity
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
Method Setup( ) Class BAAtendente
	_Super:Setup("Atendente", DIMENSION, "AA1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAtendente
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_AA1_AA1_FILIAL+AA1_CODTEC>> AS BK_ATENDENTE, "
    cQuery +=   "AA1_CODTEC AS CODIGO_DO_ATENDENTE, "
    cQuery +=   "AA1_NOMTEC AS NOME_DO_ATENDENTE, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
    cQuery += "FROM <<AA1_COMPANY>> AA1 "
    cQuery += "WHERE "
    cQuery +=   "AA1.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_AA1_FILIAL>> "

Return cQuery
