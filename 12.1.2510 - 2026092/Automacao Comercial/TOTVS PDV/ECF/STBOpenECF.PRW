#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBOpenECF
Function abertura ECF  
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Abertura com sucesso
/*/
//-------------------------------------------------------------------
Function STBOpenECF()
Local nRet := 0  
Local lRet := .F.

nRet := STWOpenECF()
lRet := (nRet == 0)

Return lRet