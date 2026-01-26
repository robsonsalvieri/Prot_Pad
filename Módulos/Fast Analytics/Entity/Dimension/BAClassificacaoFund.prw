#INCLUDE "BADEFINITION.CH"

NEW ENTITY CLASSIFICACAOFUND

//-------------------------------------------------------------------
/*/{Protheus.doc} BAClassificacaoFund
Visualiza as informacoes da Classificacoo dos Fundamentos Juridicos.

@author  henrique.cesar
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAClassificacaoFund from BAEntity
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
Method Setup() class BAClassificacaoFund
	_Super:Setup("ClassificacaoFundamento", DIMENSION, "O06" )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  henrique.cesar
@since   23/02/2018
/*/
//------------------------------------------------------------------- 
Method BuildQuery() class BAClassificacaoFund
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_O06_O06_FILIAL+O06_COD>> AS BK_CLASSIFICACAO_FUNDAMENTO,"
	cQuery += " 		O06.O06_COD AS COD_CLASSIFICACAO_FUNDAMENTO,"
	cQuery += " 		O06.O06_DESC AS DESC_CLASSIFICACAO_FUNDAMENTO,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<O06_COMPANY>> O06" 
	cQuery += " 	WHERE "
	cQuery += "	   	O06.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_O06_FILIAL>> "
Return cQuery
