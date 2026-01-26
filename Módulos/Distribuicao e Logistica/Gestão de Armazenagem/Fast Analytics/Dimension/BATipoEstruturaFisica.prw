#INCLUDE "BADEFINITION.CH"

NEW ENTITY TIPESTFIS
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BATipoEstruturaFisica
Visualiza as informações do Tipo de Estrutura Fisica.
 
@author   jackson.werka
@since    16/08/2018
/*/
//-------------------------------------------------------------------
Class BATipoEstruturaFisica from BAEntity
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
Method Setup( ) Class BATipoEstruturaFisica
	_Super:Setup("TipoEstruturaFisica", DIMENSION, "DC8")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   16/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BATipoEstruturaFisica
Local cQuery := ""
 
	cQuery += "SELECT DISTINCT <<KEY_DC8_DC8_FILIAL+DC8_TPESTR>> AS BK_TIPO_EST_FISICA,"
	cQuery +=       " DC8.DC8_TPESTR AS COD_TIPO_EST_FISICA,"
	cQuery +=       " CASE DC8.DC8_TPESTR"
	cQuery +=       "    WHEN '1' THEN 'Pulmao'"
	cQuery +=       "    WHEN '2' THEN 'Picking'"
	cQuery +=       "    WHEN '3' THEN 'Cross Docking'"
	cQuery +=       "    WHEN '4' THEN 'Blocado'"
	cQuery +=       "    WHEN '5' THEN 'Box/Doca'"
	cQuery +=       "    WHEN '6' THEN 'Blocado Fracionado'"
	cQuery +=       "    WHEN '7' THEN 'Producao'"
	cQuery +=       "    WHEN '8' THEN 'Qualidade'"
	cQuery +=       "    ELSE 'Nao Definido'"
	cQuery +=       " END DESC_TIPO_EST_FISICA"
	cQuery +=  " FROM <<DC8_COMPANY>> DC8"
	cQuery += " WHERE DC8.D_E_L_E_T_ = ' ' "
Return cQuery