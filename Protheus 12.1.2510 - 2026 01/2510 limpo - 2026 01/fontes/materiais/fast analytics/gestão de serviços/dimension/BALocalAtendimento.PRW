#INCLUDE "BADEFINITION.CH"

NEW ENTITY LOCALATENDIMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BALocalAtendimento
Visualiza as informacoes de Local de Atendimento.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BALocalAtendimento from BAEntity
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
Method Setup( ) Class BALocalAtendimento
	_Super:Setup("Local de Atendimento", DIMENSION, "ABS")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BALocalAtendimento
	Local cQuery := ""

	cQuery += " SELECT "
    cQuery +=   "<<KEY_ABS_ABS_FILIAL+ABS_LOCAL>> AS BK_LOCAL_ATENDIMENTO, "
    cQuery +=   "ABS_LOCAL AS COD_LOCAL, "
    cQuery +=   "ABS_DESCRI AS DESC_LOCAL, "
	cQuery +=   "ABS_LATITU AS LATITUDE, "
	cQuery +=   "ABS_LONGIT AS LONGITUDE, "
	cQuery +=   "ABS_MUNIC AS MUNICIPIO, "
	cQuery +=   "ABS_ESTADO AS ESTADO, "
	cQuery +=   "<<CODE_INSTANCE>> AS INSTANCIA "	
    cQuery += "FROM <<ABS_COMPANY>> ABS "
    cQuery += "WHERE "
    cQuery +=   "ABS.D_E_L_E_T_ = ' ' "
	cQuery +=   "<<AND_XFILIAL_ABS_FILIAL>> "
Return cQuery
