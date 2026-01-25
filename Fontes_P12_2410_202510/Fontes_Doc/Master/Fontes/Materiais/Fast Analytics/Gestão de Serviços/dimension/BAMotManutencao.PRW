#INCLUDE "BADEFINITION.CH"

NEW ENTITY MOTMANUTENCAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAMotManutencao
Visualiza as informacoes do Motivo Manutencao

@author  Marcia Junko
@since   09/05/2018
/*/
//-------------------------------------------------------------------
Class BAMotManutencao from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Marcia Junko
@since   09/05/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAMotManutencao
	_Super:Setup("Motivo Manutencao", DIMENSION, "ABN")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Marcia Junko
@since   09/05/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAMotManutencao
	Local cQuery := ""

	cQuery := "SELECT <<KEY_ABN_ABN_FILIAL+ABN_CODIGO>> AS BK_MOTIVO_MANUTENCAO, " + ;
			"ABN_CODIGO AS COD_MANUTENCAO, " + ;
			"ABN_DESC AS DESC_MANUTENCAO, " + ;
			"<<CODE_INSTANCE>> AS INSTANCIA " +;
			"FROM <<ABN_COMPANY>> ABN " + ;
			"WHERE ABN.D_E_L_E_T_ = ' ' " + ;
			"<<AND_XFILIAL_ABN_FILIAL>> "	
Return cQuery
