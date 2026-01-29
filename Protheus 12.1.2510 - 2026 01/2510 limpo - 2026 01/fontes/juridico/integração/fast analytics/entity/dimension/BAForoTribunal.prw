#INCLUDE "BADEFINITION.CH"

NEW ENTITY FOROTRIBUNAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BAForoTribunal
Visualiza as informacoes dos Foros e Tribunais.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAForoTribunal from BAEntity
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
Method Setup() class BAForoTribunal
	_Super:Setup("ForoTribunal", DIMENSION, "NQC" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAForoTribunal
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQC_NQC_FILIAL+NQC_COD>> AS BK_FORO_TRIBUNAL,"
	cQuery += " 		NQC.NQC_COD AS COD_FORO_TRIBUNAL,"
	cQuery += " 		NQC.NQC_DESC AS DESC_FORO_TRIBUNAL,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQC_COMPANY>> NQC" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQC.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NQC_FILIAL>>"
Return cQuery
