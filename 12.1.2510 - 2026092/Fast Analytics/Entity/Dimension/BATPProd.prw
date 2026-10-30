#INCLUDE "BADEFINITION.CH"

NEW ENTITY BATPPROD

//-------------------------------------------------------------------
/*/{Protheus.doc} BATPProd
Visualiza as informacoes de Tipo de Produto.

@author  Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Class BATPProd from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BATPProd
	_Super:Setup("TPProd", DIMENSION, "SB1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retona as consultas da entidade por empresa.

@author Helio Leal
@since  23/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BATPProd
	Local cQuery := ""

	cQuery := " SELECT" 
	cQuery += " <<KEY_SB1_B1_FILIAL+B1_COD>> as BK_TIPO_PRODUTO,"
	cQuery += " CASE"
	cQuery += "    WHEN (SELECT COUNT(*) FROM <<SG1_COMPANY>> SG1 WHERE G1_FILIAL = B1_FILIAL AND G1_COD = B1_COD) = 0 THEN 'Comprado'"
	cQuery += "    WHEN ((SELECT COUNT(*) FROM <<SG1_COMPANY>> SG1 WHERE G1_FILIAL = B1_FILIAL AND G1_COD = B1_COD) > 0) AND (B1_TIPO LIKE '%MP%') THEN 'Mat�ria-Prima'"
	cQuery += "    WHEN ((SELECT COUNT(*) FROM <<SG1_COMPANY>> SG1 WHERE G1_FILIAL = B1_FILIAL AND G1_COD = B1_COD) > 0) AND (B1_TIPO NOT LIKE '%MP%') THEN 'Fabricado'"
	cQuery += " END AS TIPO_PRODUTO,"
	cQuery += " <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " FROM <<SB1_COMPANY>> SB1"
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' '"
	cQuery += "	<<AND_XFILIAL_B1_FILIAL>> "
Return cQuery