#INCLUDE "BADEFINITION.CH"

NEW ENTITY ASSJURIDICO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAssuntoJuridico
Visualiza as informacoes dos assuntos juridicos de acordo com o tema 
do processo. Ex: contecioso, civel, societario, etc..

@author  Helio Leal
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Class BAAssuntoJuridico from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrao.  

@author  Helio Leal
@since   21/02/2018
/*/
//-------------------------------------------------------------------  
Method Setup() class BAAssuntoJuridico
	_Super:Setup("AssuntoJuridico", DIMENSION, "NYB" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   21/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAAssuntoJuridico
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NYB_NYB_FILIAL+NYB_COD>> AS BK_ASSUNTO_JURIDICO,"
	cQuery += " 		NYB.NYB_COD AS COD_ASSUNTOJURIDICO,"
	cQuery += " 		NYB.NYB_DESC AS DESC_ASSUNTOJURIDICO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NYB_COMPANY>> NYB" 
	cQuery += " 	WHERE "
	cQuery += "	   	NYB.D_E_L_E_T_ = ' '"
	cQuery += "	   	<<AND_XFILIAL_NYB_FILIAL>> "
Return cQuery
