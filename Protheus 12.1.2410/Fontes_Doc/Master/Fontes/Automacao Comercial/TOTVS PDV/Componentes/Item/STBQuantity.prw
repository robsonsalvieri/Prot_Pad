#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBQUANTITY.CH"

Static nItemQuant := 1			// Quantidade do item default = 1
Static nQtdOther  := 0			// Quantidade do item default = 0

//-------------------------------------------------------------------
/*/{Protheus.doc} STBQuantity
Seta quantidade do item

@param   nItemQuant		Quantidade do Item
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetQuant( nQuant, nTpQtd )

Default  nQuant := 1		//Quantidade do item
Default  nTpQtd := 1		//Tipo da quantidade a ser armazenada

If  nTpQtd == 1 
	nItemQuant 	:= nQuant
Else
	nQtdOther 	:= nQuant
EndIf 
		
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetDefQuant
Seta quantidade default do item

@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetDefQuant()
 
// seta quantidade default
nItemQuant 	:= 1
nQtdOther 	:= 0
		
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetQuant
Pega quantidade do item

@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  nItemQuant		Quantidade do Item
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetQuant(nTpQtd)
Local nQtdRet :=  0		//Retorno da função

Default nTpQtd := 1		//Tipo da quantidade a ser resgatada

If nTpQtd == 1
	nQtdRet := nItemQuant
Else
	nQtdRet := nQtdOther
EndIf 

Return nQtdRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBBalQuant
Pega quantidade do item na balanca

@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBBalQuant()
 
Local nTmpQtd 	:= 0			// Guarda quantidade da balanca          
Local aRet 		:= {}   		// Array de Retorno
Local aData		:= {0}			// Array data
 
/*/	
	Verifica se usa balanca para pegar peso - ( Quantidade = Peso )
/*/  
      
aRet := 	STFFireEvent(	ProcName(0)		,;		// Nome do processo
							"STBalanceUse"	,;		// Nome do evento
							{.T.}				)	//  06 - Define se usa a balaça

 
If ValTYpe(aRet) == "U" .OR. Len(aRet) == 0  .OR. Valtype(aRet[1]) <> "L" .OR. ! aRet[1]
	STFMessage("STBBalQuant","POPUP",STR0001) //"Por favor colocar o produto na balança ou informar a quantidade!"
	STFShowMessage("STBBalQuant")
	
	STBSetQuant(0)
Else
   	aRet := 	STFFireEvent(	ProcName(0)		,;		// Nome do processo
								"STBalanceGet"	,;		// Nome do evento
								aData				)		//  
	 
	If VaLType(aRet) == "U" .OR. VaLType(aData) == "U"  .OR.  Len(aData) == 0  .OR. Valtype(aData[1]) <> "N"
		STFMessage("STBBalQuant","POPUP",STR0001) //"Por favor colocar o produto na balança ou informar a quantidade!"
		STFShowMessage("STBBalQuant")
		
		STBSetQuant(0)
	Else
	   nTmpQtd := aData[1]
		If nTmpQtd > 0
			STBSetQuant( nTmpQtd )			
		Else	
			STFMessage("STBBalQuant","POPUP",STR0001) //"Por favor colocar o produto na balança ou informar a quantidade!"
			STFShowMessage("STBBalQuant")
			
			STBSetQuant(0)				
		EndIF			    	
	EndIf 

EndIf 
	    
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBQtdEtq
Seta quantidade de acordo com a etiqueta de codigos de barras 
e o preco

@param   cCodeReceived			Codigo recebido/digitado
@param   nPrice						Preco do item
@param   cBalanca						Tipo produto de balanca

@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STBQtdEtq( cCodeReceived , nPrice , cBalanca )

Local cCodProBal 		:= ""			// Codigo do Item da balanca
Local cInfProBal 		:= ""			// Peso/quantidade do Item da balanca
Local nValBal			:= 0
Local nQtdBal			:= 0
Local nDifBal			:= 0

Default cCodeReceived	:= ""			// Codigo do Item
Default nPrice			:= 0			// Preco do item
Default cBalanca 		:= ""			// Codigo do Cliente	

ParamType 0  Var cCodeReceived		AS Character	Default ""
ParamType 1  Var nPrice				AS Numeric		Default 0
ParamType 2  Var cBalanca 			AS Character	Default ""

//Separa o codigo recebido para fazer validacao da balanca
cCodProBal := Substr(cCodeReceived,2,6)	//Codigo do Item da balanca
cInfProBal := SubStr(cCodeReceived,8,5)	//Peso/quantidade do Item da balanca

// Verifica se o produto esta no padrao EAN-13 			  
//	e se o primeiro digito eh 2 (padrao balanca)
If cBalanca == "1" .AND. Len(Alltrim(cCodeReceived)) == 13 .AND. Substr(cCodeReceived,1,1) == "2"
	//comparar o valor da etiqueta com o valor calculado 
	nValBal := Val(cInfProBal)/100
	nQtdBal := Round(nValBal / nPrice ,3 )	
	nDifBal := nValBal - (A410Arred((nPrice * nQtdBal),"D2_TOTAL")) 

	//A Balanca Utiliza 3 Decimais!!!
	//Esse tratamento é realizado quando há diferebça do valor enviado na etiqueta e o valor calculado pelo sistema
	//Para o valor total ficar igual ao valor enviado pela etiqueta, o parâmetro MV_ARREFAT deve ser igual a 'N' (trunca o valor)
	If nDifBal > 0
		nQtdBal += 0.001
	ElseIf nQtdBal < 0
		nQtdBal -= 0.001
	EndIf

	STBSetQuant (nQtdBal)

EndIf  

Return Nil