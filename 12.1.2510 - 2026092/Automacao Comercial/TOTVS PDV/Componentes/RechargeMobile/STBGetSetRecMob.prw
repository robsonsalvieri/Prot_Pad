#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static aRecharge := {} //Guarga o retorno da recarga de celular


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetRec
Seta o retorno da recarga de celular

@param		aRec - Dados da recarga
@author  Varejo
@version P11.8
@since   	15/05/2012
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetRec( aRec )

Default aRec := {}

ParamType 0 Var   	aRec 	As Array	Default 	{}

aRecharge := aRec

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetRec
Retorna os dados da recarga de celular

@param		
@author  	Vendas & CRM
@author  Varejo
@version P11.8
@return	aRecharge  - Array com dados da recarga	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetRec()
Return aRecharge