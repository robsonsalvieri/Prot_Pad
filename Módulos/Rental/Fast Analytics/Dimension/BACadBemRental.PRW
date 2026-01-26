#INCLUDE "BADEFINITION.CH"

NEW ENTITY CADBEMRENTAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BACadBemRental
Visualiza as informacoes do Cadastro de Bens
Subida 08/04/24
@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Class BACadBemRental from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACadBemRental
	_Super:Setup("CadastroBens", DIMENSION, "ST9")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   22/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACadBemRental
	Local cQuery := ""

	cQuery += " SELECT "
	cQuery += " <<KEY_COMPANY>> AS BK_EMPRESA,	"
	cQuery += " <<KEY_FILIAL_T9_FILIAL>> AS BK_FILIAL, "
	cQuery += " <<KEY_ST9_T9_FILIAL+T9_CODBEM>> 	AS BK_CADBEM, "
	cQuery += " <<KEY_ST6_T9_FILIAL+T9_CODFAMI>> 	AS BK_FAMILIA, "
	cQuery += " ST9.T9_CODBEM							AS COD_BEM, "
	cQuery += " ST9.T9_TIPMOD							AS TIPO_MODELO, "
	cQuery += " ST9.T9_CODFAMI							AS COD_FAMILIA, "
	cQuery += " ST9.T9_NOME								AS NOME_BEM, "
	cQuery += " ST9.T9_CCUSTO							AS CENTRO_CUSTO, "
	cQuery += " ST9.T9_CENTRAB							AS CENTRO_TRABALHO, "
	cQuery += " ST9.T9_DTINSTA							AS DATA_INSTALACAO, "
	cQuery += " ST9.T9_DTCOMPR							AS DATA_COMPRA, "
	cQuery += " CAST(ST9.T9_VALPROR AS VARCHAR(100))	AS VALOR_COMPRA, "
	cQuery += " CASE ST9.T9_LUBRIFI "
	cQuery += " 	WHEN '1' THEN 'SIM' "
	cQuery += " 	WHEN '2' THEN 'NAO' "
	cQuery += " END										AS APLIC_PROD_ABASTEC, "
	cQuery += " ST9.T9_ALUGUEL							AS PERMITE_ALUGUEL, "
	cQuery += " CAST(ST9.T9_PERMANU AS VARCHAR(100))	AS PERCENTUAL_MANUTENCAO, "
	cQuery += " CAST(ST9.T9_SEGLICE AS VARCHAR(100))	AS PERCENTUAL_SEGURO_LICENC, "
	cQuery += " CAST(ST9.T9_VALPRES AS VARCHAR(100))	AS VALOR_PRESENTE, "
	cQuery += " CAST(ST9.T9_VALFAT  AS VARCHAR(100))	AS VALOR_FATURADO, "
	cQuery += " CASE ST9.T9_TERCEIR "
	cQuery += " 	WHEN '1' THEN 'PROPRIO' "
	cQuery += " 	WHEN '2' THEN 'TERCEIRO' "
	cQuery += " END						AS TERCEIRO, "
	cQuery += " <<CODE_INSTANCE>> AS INSTANCIA "
	cQuery += " FROM <<ST9_COMPANY>> ST9 "
	cQuery += " WHERE ST9.T9_STATUS<>'  ' AND ST9.T9_CATBEM<>'3' AND ST9.D_E_L_E_T_=' ' "
	cQuery += " <<AND_XFILIAL_T9_FILIAL>> "

Return cQuery
