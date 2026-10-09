#INCLUDE "BADEFINITION.CH"

NEW ENTITY FUNDSOBJETO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFundsObjeto
Visualiza as informacoes dos Fundamentos do Objeto.

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAFundsObjeto from BAEntity
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
Method Setup() class BAFundsObjeto
	_Super:Setup("FundamentosObjeto", DIMENSION, "O07" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAFundsObjeto
	Local cQuery := ""
	
	cQuery += " SELECT"
	cQuery += "     <<KEY_O07_O07_FILIAL+O07_COBJET+O07_CFUPRO+O07_CCLFUN>> AS BK_FUNDAMENTOS_OBJETO,"	
	cQuery += "     O07_COBJET AS COD_FUNDAMENTOS_OBJETO,"
	cQuery += "     <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " FROM <<O07_COMPANY>> O07"
	cQuery += " WHERE O07.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_O07_FILIAL>>"
Return cQuery
