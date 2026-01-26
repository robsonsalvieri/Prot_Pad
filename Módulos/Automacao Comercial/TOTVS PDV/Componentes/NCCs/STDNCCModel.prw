#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"

#DEFINE SE1RECNO 5  // TODO: nao esta sendo usado apagar????

Static aNCCs 		:= {}
Static nTotalNCCs	:= 0

//-------------------------------------------------------------------
/*/{Protheus.doc} STDFindNCCModel
Busca as NCCs em aberto do cliente selecionado e preenche o Model da SE1 com essas NCCs.

@param   cCliente		- Codigo do cliente
@param   cLoja			- Codigo da loja no cliente
@param  aSe1Recnos, array , valor do campo MDK_NUMREC
@author  Varejo
@version 	P11.8
@since   24/09/2012
@return  oModelNCC 	- Retorna estrutura de dados do Model
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDFindNCCModel(cCliente,cLoja,lImport,cOrc, aSe1Recnos)

Local cCliPad 		:= SuperGetMv( "MV_CLIPAD" )	// Cliente Padrao
Local cLojaPad		:= SuperGetMV( "MV_LOJAPAD")	// Loja Padrao
Local lSTFNDNCC		:= ExistBlock( "STFNDNCC" )		// PE para customização da consulta NCC.

DEFAULT cCliente	:= ""
DEFAULT cLoja 		:= ""
DEFAULT lImport 	:= .F.
DEFAULT cOrc 		:= ""
DEFAULT aSe1Recnos  := {} 

ParamType 0 var  cCliente	As Character	Default ""				
ParamType 1 var  cLoja		As Character	Default ""


//Entra no conceito de NCC se:                 
//1 - Parametro MV_USACRED habilitado            
//2 - Cliente e loja da venda diferente de padrao
If Substr(SuperGetMV("MV_USACRED"),2,1) == "S" .AND. (cCliente + cLoja <> cCliPad + cLojaPad)
	
	if lSTFNDNCC
		LjGrvLog(cCliente, "chamada do PE STFNDNCC")
		aNCCs  :=ExecBlock("STFNDNCC", .F., .F., {cCliente, cLoja, dDataBase, lImport, cOrc})	
	Else 
		aNCCs  := FrtNCCLoad(cCliente,cLoja,/*cEnvelope*/, dDataBase,lImport,cOrc, aSe1Recnos)
	Endif 

	
	If Len(aNCCs) > 0 //Ordena por E1_EMISSAO+E1_PREFIXO+E1_NUM+E1_PARCELA
		aSort(aNCCs, ,, { |x,y| x[4]< y[4] .And. x[9]< y[9] .And. x[3]< y[3] .And. x[10]< y[10]})
	EndIf
EndIf

Return aNCCs


//-------------------------------------------------------------------
/*/ {Protheus.doc} STDSetNCCs
Seta o Array das NCCs que foi buscado na retaguarda do cliente selecionado

@param   cType: 1 - Retorna o array com as NCCs. 2 - Retorna o valor total das NCCs selecionadas
@param   xValue Recebe valor
@author  Varejo
@version 	P11.8
@since   15/01/2013
@return  aNCCs - retorna NCCs em aberto do cliente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSetNCCs(cType,xValue) 

DEFAULT cType	:= ""
DEFAULT xValue 	:= Nil

If cType == "1"
	If xValue 	<> Nil
		aNCCs := xValue
	Else
		aNCCs := {}
	EndIf
ElseIf cType == "2"
	If xValue 	<> Nil
		nTotalNCCs += xValue
	Else
		nTotalNCCs := 0

		//Retira a selecao das NCCs
		aEval( aNCCs, { |x| x[1] := .F. } )
	EndIf
EndIf

/* 
Posicoes de aNCCs

aNCCs[x,1]  = .F.	// Caso a NCC seja selecionada, este campo recebe TRUE		 
aNCCs[x,2]  = SE1->E1_SALDO  
aNCCs[x,3]  = SE1->E1_NUM		
aNCCs[x,4]  = SE1->E1_EMISSAO
aNCCs[x,5]  = SE1->(Recno()) 
aNCCs[x,6]  = SE1->E1_SALDO
aNCCs[x,7]  = SuperGetMV("MV_MOEDA1")
aNCCs[x,8]  = SE1->E1_MOEDA
aNCCs[x,9]  = SE1->E1_PREFIXO	
aNCCs[x,10] = SE1->E1_PARCELA	 
aNCCs[x,11] = SE1->E1_TIPO

*/

Return aNCCs


//-------------------------------------------------------------------
/*{Protheus.doc} STDGetNCCs
Retorna o Array das NCCs do cliente preenchido.

@param   cType: 1 - Retorna o array com as NCCs. 2 - Retorna o valor total das NCCs selecionadas
@author  Varejo
@version 	P11.8
@since   15/01/2013
@return  xRet - retorna arrays de nccs ou valor da ncc
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDGetNCCs(cType) 

Local xRet := Nil   // Retorno

DEFAULT cType		:= ""

If nTotalNCCs < 0
	nTotalNCCs := 0
EndIf

If cType == "1"
	/*   
	Posicoes de aNCCs
	
	aNCCs[x,1]  = .F.	// Caso a NCC seja selecionada, este campo recebe TRUE			 
	aNCCs[x,2]  = SE1->E1_SALDO  
	aNCCs[x,3]  = SE1->E1_NUM		
	aNCCs[x,4]  = SE1->E1_EMISSAO
	aNCCs[x,5]  = SE1->(Recno()) 
	aNCCs[x,6]  = SE1->E1_SALDO
	aNCCs[x,7]  = SuperGetMV("MV_MOEDA1")
	aNCCs[x,8]  = SE1->E1_MOEDA
	aNCCs[x,9]  = SE1->E1_PREFIXO	
	aNCCs[x,10] = SE1->E1_PARCELA	 
	aNCCs[x,11] = SE1->E1_TIPO
	*/

	//Verifica aNCCs esta definido como Array
	If ValType(aNCCs) == "A"
		xRet := aNCCs
	Else
		LjGrvLog("Retorno NCC", "Variavel aNCCs nao esta definida como Array.aNCCs:",aNCCs)
		xRet := {}
	EndIf
	
ElseIf cType == "2"
	xRet := nTotalNCCs
EndIf

Return xRet
