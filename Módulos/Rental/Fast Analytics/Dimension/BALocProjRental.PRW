#INCLUDE "BADEFINITION.CH"

NEW ENTITY CADBENSRENTAL 

//-------------------------------------------------------------------
/*/{Protheus.doc} BALocProjRental
Visualiza as informacoes da Locação x Projeto.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Class BALocProjRental from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BALocProjRental
	_Super:Setup("LocacaoProjeto", DIMENSION, "FPA")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BALocProjRental
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " <<KEY_FPA_FPA_FILIAL+FPA_PROJET>> 	AS BK_LOCPROJ, "
	cQuery += " FPA.FPA_PROJET                     	AS NRO_PROJET, "
	cQuery += " FPA.FPA_SEQGRU                     	AS SEQ_PROJET, "
	cQuery += " FPA.FPA_CNJ                        	AS CONJ_TRASP, "
	cQuery += " CASE FPA.FPA_TIPOSE "
	cQuery += " 	WHEN 'L' THEN 'LOCACAO' "
	cQuery += " 	WHEN 'O' THEN 'OUTROS' "
	cQuery += " 	WHEN 'Z' THEN 'COBRANCA UNICA' "
	cQuery += " 	WHEN 'M' THEN 'MAO DE OBRA' "
	cQuery += " 	WHEN 'S' THEN 'SUBSTITUIDO'	"
	cQuery += " END 								AS TIPO_SERVICO, "
	cQuery += " <<CODE_INSTANCE>> AS INSTANCIA "
	cQuery += " FROM <<FPA_COMPANY>> FPA " 
	cQuery += " WHERE FPA.D_E_L_E_T_=' ' "
	cQuery += " <<AND_XFILIAL_FPA_FILIAL>> "
 
Return cQuery
