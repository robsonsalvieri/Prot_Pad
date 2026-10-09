#INCLUDE "BADEFINITION.CH"
#INCLUDE "BAGRPCLIENTE.CH"

NEW ENTITY GRPCLIENTE

//-------------------------------------------------------------------
/*/{Protheus.doc} BAGrpCliente
Visualiza as informacoes de  Grupo de Cliente.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Class BAGrpCliente from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAGrpCliente
	_Super:Setup("GrupoCliente", DIMENSION, "SA1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAGrpCliente
	Local cQuery := ""

	cQuery += " SELECT DISTINCT"
	cQuery += " <<KEY_SA1_A1_FILIAL+A1_TIPO>> as BK_GRUPO_CLIENTE,"
	cQuery += " SA1.A1_TIPO AS COD_GRUPO_CLI,"

    cQuery += "CASE SA1.A1_TIPO" + ; 
				" WHEN 'L' THEN 'Produtor Rural'" +;
				" WHEN 'F' THEN 'Cons.Final'" +;
				" WHEN 'R' THEN 'Revendedor'" +;
				" WHEN 'S' THEN 'ICMS Solidario sem IPI na base'" +;
				" ELSE 'Exportacao'" +;
			  " END AS DESC_GRUPO_CLI," +;
			  " <<CODE_INSTANCE>> AS INSTANCIA " 

	cQuery += " FROM <<SA1_COMPANY>> SA1" 
	cQuery += " WHERE "
	cQuery += " SA1.D_E_L_E_T_ = ' '"
	cQuery += " <<AND_XFILIAL_A1_FILIAL>>"
Return cQuery 
