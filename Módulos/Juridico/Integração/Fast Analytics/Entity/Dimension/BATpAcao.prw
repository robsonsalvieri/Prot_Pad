#INCLUDE "BADEFINITION.CH"

NEW ENTITY TPACAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BATpAcao
Visualiza as informacoes de Tipo de Acao do Processo.

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BATpAcao from BAEntity
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
Method Setup() class BATpAcao
	_Super:Setup("TpAcao", DIMENSION, "NQU" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BATpAcao
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQU_NQU_FILIAL+NQU_COD>> AS BK_TIPO_ACAO,"
	cQuery += " 		NQU.NQU_COD AS COD_TIPO_ACAO,"
	cQuery += " 		NQU.NQU_DESC AS DESC_TIPO_ACAO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQU_COMPANY>> NQU" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQU.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NQU_FILIAL>>"
	
Return cQuery
