#INCLUDE "BADEFINITION.CH"

NEW ENTITY OPORTUNIDADE

//-------------------------------------------------------------------
/*/{Protheus.doc} BAOportunidade
Visualiza as informacoes de Oportunidade.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BAOportunidade from BAEntity
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
Method Setup( ) Class BAOportunidade
	_Super:Setup("Oportunidade", DIMENSION, "AD1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAOportunidade
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_AD1_AD1_FILIAL+AD1_NROPOR>> AS BK_OPORTUNIDADE, "
    cQuery +=   "AD1_NROPOR AS CODIGO_OPORTUNIDADE, "
    cQuery +=   "AD1_DESCRI AS DESCRICAO_OPORTUNIDADE, "
    cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "
    cQuery += "FROM <<AD1_COMPANY>> AD1 "
    cQuery += "WHERE "
    cQuery +=   "AD1.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_AD1_FILIAL>> "

Return cQuery
