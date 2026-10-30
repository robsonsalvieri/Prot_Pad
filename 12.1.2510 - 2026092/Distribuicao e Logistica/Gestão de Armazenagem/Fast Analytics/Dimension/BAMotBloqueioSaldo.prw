#INCLUDE "BADEFINITION.CH"

NEW ENTITY MOTBLOQUEIOSALDO
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAMotBloqueioSaldo
Visualiza as informações de Motivo de Bloqueio de Saldo
 
@author   jackson.werka
@since    16/08/2018
/*/
//-------------------------------------------------------------------
Class BAMotBloqueioSaldo from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass
 
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.
 
@author  jackson.werka
@since   16/08/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAMotBloqueioSaldo
	_Super:Setup("MotBloqueioSaldo", DIMENSION, "SX5")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   16/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAMotBloqueioSaldo
Local cQuery := ""
 
	cQuery += "SELECT <<KEY_SX5_X5_FILIAL+X5_CHAVE>> AS BK_MOTIVO_BLOQUEIO,"
	cQuery +=       " SX5.X5_CHAVE AS COD_MOTIVO_BLOQUEIO,"
	cQuery +=       " SX5.X5_DESCRI AS DESC_MOTIVO_BLOQUEIO"
	cQuery +=  " FROM <<SX5_COMPANY>> SX5"
	cQuery += " WHERE SX5.X5_TABELA = 'E1'"
   cQuery +=   " AND SX5.D_E_L_E_T_ = ' ' "
Return cQuery