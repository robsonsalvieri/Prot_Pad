#INCLUDE "BADEFINITION.CH"

NEW ENTITY ESTFISICA
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAEstruturaFisica
Visualiza as informações de Estrutura Fisica.
 
@author   jackson.werka
@since    16/08/2018
/*/
//-------------------------------------------------------------------
Class BAEstruturaFisica from BAEntity
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
Method Setup( ) Class BAEstruturaFisica
	_Super:Setup("EstruturaFisica", DIMENSION, "DC8")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   16/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAEstruturaFisica
Local cQuery := ""
 
	cQuery += "SELECT <<KEY_DC8_DC8_FILIAL+DC8_CODEST>> AS BK_ESTRUTURA_FISICA,"
	cQuery +=       " DC8.DC8_CODEST AS COD_ESTRUTURA_FISICA,"
	cQuery +=       " DC8.DC8_DESEST AS DESC_ESTRUTURA_FISICA"
	cQuery +=  " FROM <<DC8_COMPANY>> DC8"
	cQuery += " WHERE DC8.D_E_L_E_T_ = ' ' "
Return cQuery