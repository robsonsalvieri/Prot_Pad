#INCLUDE "PROTHEUS.CH"

Static _aHandlers := {}


//-------------------------------------------------------------------
/*/{Protheus.doc} STFAddEventHandler
Add evento 
@param   	cFunName		Nome da funcao
@param   	cEventName		Nome do evento
@param   	bHandler		Bloco de manipulacao
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFAddEventHandler(cFunName, cEventName, bHandler)

Local nPosClass	:= 0  //Posicao da class
Local nPosEvent	:= 0  //Posicao do evento

Default cFunName 	:= ""
Default cEventName 	:= ""
Default bHandler 	:= "{|| }"

cFunName	:= Lower(cFunName)
cEventName	:= Lower(cEventName)

nPosClass := AScan( _aHandlers, { |x| x[1] == cFunName }  )
If nPosClass > 0
	nPosEvent := AScan( _aHandlers[nPosClass][2], { |x| x[1] == cEventName } )
	If nPosEvent > 0
		AAdd( _aHandlers[nPosClass][2][nPosEvent][2], bHandler )
	Else
		AAdd( _aHandlers[nPosClass][2], { cEventName, { bHandler } } )
	EndIf 
Else
	AAdd( _aHandlers, { cFunName, { { cEventName, { bHandler } } } } )
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFRemoveEventHandler
Remove evento 
@param   	cFunName		Nome da funcao
@param   	cEventName		Nome do evento
@param   	bHandler		Bloco de manipulacao
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFRemoveEventHandler(cFunName, cEventName, bHandler)

Local nPosClass	:= 0  //Posicao da class
Local nPosEvent	:= 0  //Posicao do evento

Default cFunName 	:= ""
Default cEventName 	:= ""
Default bHandler 	:= "{|| }"

cFunName	:= Lower(cFunName)
cEventName	:= Lower(cEventName)

nPosClass := AScan( _aHandlers, { |x| x[1] == cFunName }  )

If nPosClass > 0
	nPosEvent := AScan( _aHandlers[nPosClass][2], { |x| x[1] == cEventName } )
	If nPosEvent > 0
		nPosHandler := AScan( _aHandlers[nPosClass][2][nPosEvent][2], { |x| GetCbSource(x) == GetCbSource(bHandler) } )
		If nPosHandler > 0
			ADel( _aHandlers[nPosClass][2][nPosEvent][2], nPosHandler )
			ASize( _aHandlers[nPosClass][2][nPosEvent][2], Len( _aHandlers[nPosClass][2][nPosEvent][2] ) - 1 )
		EndIf 
	EndIf 
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STFFireEvent
Start evento 
@param   	cFunName		Nome da funcao
@param   	cEventName		Nome do evento
@param   	bHandler		Bloco de manipulacao
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFFireEvent(cFunName, cEventName, uEventData)

Local nPosClass	:= 0 	//Posicao da class
Local nPosEvent	:= 0  	//Posicao do evento
Local aRets		:= {}	//Array retornos

Default cFunName 	:= ""
Default cEventName 	:= ""
Default uEventData 	:= "{|| }"

cFunName	:= Lower(cFunName)
cEventName	:= Lower(cEventName)

nPosClass := AScan( _aHandlers, { |x| x[1] == cFunName .Or. x[1]=="*" }  )

If nPosClass > 0
	nPosEvent := AScan( _aHandlers[nPosClass][2], { |x| x[1] == cEventName .Or. x[1]=="*" } )
	If nPosEvent > 0
		AEval( _aHandlers[nPosClass][2][nPosEvent][2], { |x| AAdd(aRets, Eval(x, cFunName, cEventName, uEventData)) } )  
	EndIf
EndIf

Return aRets


//-------------------------------------------------------------------
/*/{Protheus.doc} STFClearEvents
Limpa evento 
@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFClearEvents()
_aHandlers := {}
Return       



//-------------------------------------------------------------------
Function STFExistEvent(cFunName, cEventName)

Local nPosClass	:= 0 	//Posicao da class
Local nPosEvent	:= 0  	//Posicao do evento

Default cFunName 	:= ""
Default cEventName 	:= ""

cFunName	:= Lower(cFunName)
cEventName	:= Lower(cEventName)

nPosClass := AScan( _aHandlers, { |x| x[1] == cFunName .Or. x[1]=="*" }  )

If nPosClass > 0
	nPosEvent := AScan( _aHandlers[nPosClass][2], { |x| x[1] == cEventName .Or. x[1]=="*" } ) 
	
EndIf 

Return nPosEvent > 0