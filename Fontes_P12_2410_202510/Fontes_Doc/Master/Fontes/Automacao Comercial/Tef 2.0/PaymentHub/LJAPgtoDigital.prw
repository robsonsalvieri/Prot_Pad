#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LJAPgDigit ; Return             

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJAPgtoDigital
Interface para transacao com pgto digitais utilizando Payment Hub.

@type       Class
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------
Class LJAPgtoDigital From LJATransacao
	
	Data oFormas					  //Coleção de formas de pagamento
	
	Method New()                      		//Metodo construtor  
	Method GetFormaPgto(oRetTran, aFormas) 	//Retorna a forma de pagamento       
		
EndClass                    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LJAPgtoDigital.

@type       Class
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------
Method New() Class LJAPgtoDigital 
	
	_Super:New() 
	
	oFormas := NIl

Return Self    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFormaPgto
Metodo construtor da classe LJAPgtoDigital.

@type       Class
@author     Lucas Novais (lnovias@)
@since      04/11/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------

Method GetFormaPgto(oRetorno, aFormas) Class LJAPgtoDigital 
    Local cFormPgto  := ""                          //forma de pagamento
    Local nMvLjPagto := SuperGetMv("MV_LJPAGTO",,1) //Parametro da forma de pagamento
    Local nPos 		 := 0                           //posição de localização
        
    
    If oRetorno <> NIl
              
	    If nMvLjPagto == 1 //Busca pelo SX5 
	    		If Len(aFormas) > 0 .AND. (	nPos := aScan(aFormas, {|f| f[1] == oRetorno:cFormaPgto}) ) > 0  
	    			cFormPgto := AllTrim(aFormas[nPos, 02])
	    		
	    		EndIf
	    Else 
	    	//Retorna a administradora Financeira
	    	cFormPgto := oRetorno:oRetorno:cAdmFin
	    EndIf
    
    EndIf

Return cFormPgto 
