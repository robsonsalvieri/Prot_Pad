#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43TABOCO

//-------------------------------------------------------------------
/*/{Protheus.doc} BATabelaOcorrencia
Visualiza as informações por Tabela de Ocorrencia

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Class TMSTabelaOcorrencia from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class TMSTabelaOcorrencia
	_Super:Setup("TMS Tabela Ocorrencia", DIMENSION, "DT2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class TMSTabelaOcorrencia
	Local cQuery    := ""

	cQuery += " SELECT "
	cQuery += " 		<<KEY_DT2_DT2_FILIAL+DT2_CODOCO>>   AS BK_CODOCO        ,"
	cQuery += " 		DT2.DT2_CODOCO                      AS COD_OCORRENCIA   ,"
	cQuery += " 		DT2.DT2_DESCRI                      AS DESC_OCORRENCIA, "
	cQuery += "			<<CODE_INSTANCE>>					AS INSTANCIA"
	cQuery += " 	FROM <<DT2_COMPANY>> DT2                                     " 
	cQuery += " 	WHERE                                                        "
	cQuery += "	   	DT2.D_E_L_E_T_ = ' '                                         "
	cQuery += "     <<AND_XFILIAL_DT2_FILIAL>>                                   "

	
Return cQuery