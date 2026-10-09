#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH" 


//-------------------------------------------------------------------
/*/ {Protheus.doc} STWSalesmanSelection
WorkFlow responsavel pela selecao de Vendedores.
@param   cKey			- Chave para busca no Back-Office
@author  Varejo 
@version P11.8
@since   10/09/2013
@return  oModelVendedor - Retorna model do Vendedor  
/*/
//-------------------------------------------------------------------
Function STWSalesmanSelection(cKey)

Local lOffline 			:= .T. 							// Por questoes tecnicas, a busca pelo Vendedor sera feita apenas offline, porem a busca online ja esta implementada
Local aDadosVen 		:= {} 							// Array de dados do Vendedor
Local aParam 			:= {}  							// Array de parametros
Local cVendedor 		:= "" 							// Vendedor 
Local cLojaVen 			:= "" 							// Loja do Vendedor
Local oModelVendedor 	:= Nil 							// Model de Vendedor
Local uResult			:= Nil 							// Resultado generico

Default cKey 		:= ""

ParamType 0 var  cKey 			As Character	Default ""				


If lOffline
	/*  
	  Atribuicao do model do Vendedor à variavel de Retorno.
	*/
	
	oModelVendedor := STDSalesmanData(xFilial("SA3")+cKey,lOffline)
	cVendedor := oModelVendedor:GetValue("SA3MASTER","A3_COD")
	
EndIf

Return oModelVendedor

//-------------------------------------------------------------------
/*{Protheus.doc} STBValidVenPad
Funcao que verifica se o Vendedor digitado pelo usuario eh o Vendedor padrao. Caso seja, seta lSearchOffline para True, 
a fim de forcar todo o processo de selecao de Vendedores para ocorrer em ambiente local.
@param   cKey			- Chave para busca no Back-Office
@author  Varejo 
@version P11.8
@since   10/09/2013
@return  lRet 			- Retorna True caso o Vendedor digitado seja o Vendedor padrao, o que forca a pesquisa em ambiente local.
*/
//-------------------------------------------------------------------

Function STBValidVenPad( cKey )

Local cVenPad	:= SuperGetMv( "MV_VENDPAD" )	   	//Vendedor Padrao
Local lRet		:= .F.								//Retorno

Default cKey      := ""

ParamType 0 var  cKey 			As Character	Default ""				

If (cKey == cVenPad)
	lRet := .T.
EndIf

Return lRet



