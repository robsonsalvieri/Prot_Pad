#INCLUDE "BADEFINITION.CH"

NEW ENTITY FASEPROC

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFaseProc
Visualiza as informacoes das Fases Processuais Juridica.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAFaseProc from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrao.  

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------  
Method Setup() class BAFaseProc
	_Super:Setup("FaseProc", DIMENSION, "NQG" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAFaseProc
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQG_NQG_FILIAL+NQG_COD>> AS BK_FASE_PROC,"
	cQuery += " 		NQG.NQG_COD AS COD_FASE_PROC,"
	cQuery += " 		NQG.NQG_DESC AS DESC_FASE_PROC,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQG_COMPANY>> NQG" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQG.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NQG_FILIAL>> "
Return cQuery
