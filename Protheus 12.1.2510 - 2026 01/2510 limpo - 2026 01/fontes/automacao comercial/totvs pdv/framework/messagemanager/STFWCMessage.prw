#INCLUDE "PROTHEUS.CH"  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Protheus necessita ter ao menos uma funcao para que o    ³
//³fonte seja exibido na inspecao de fontes do RPO.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function STFWCMessage() ; Return

//--------------------------------------------------------
/*/{Protheus.doc} STFWCMessage
Classe que representa uma mensagem utilizada pela classe STFWCMessageManager.

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWCMessageManager
@since   29/03/2012
@return  Self
@todo    
@obs     Herda da classe FWSerialize     
@sample
/*/
//--------------------------------------------------------
                             
Class STFWCMessage From FWSerialize
	Data cName
	Data cMessage
	Data cCallStack
	Data nType
	Data oInnerMessage
	
	Method STFWCMessage() 
	Method HasMessage()
	Method HasError()
	Method HasWarning()
	Method HasInformation()
	Method ToString()
EndClass

//--------------------------------------------------------
/*/{Protheus.doc} STFWCMessage
Metodo construtor da classe STFWCMessage.

@param   cName				Nome identificador da mensagem
@param   nType				Tipo da mensagem, sendo: 1 - Erro | 2 - Aviso | 3 - Informacao
@param   cMessage			A mensagem
@param   oInnerMessage	Objeto STFWCMessage interno,ou a mensagem que gerou essa.

@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  Self
@todo    
@obs	  Classe STFWCMessage                                     
@sample
/*/
//--------------------------------------------------------

Method STFWCMessage( cName, nType, cMessage, oInnerMessage) Class STFWCMessage
	Local nCount		:= 1				// Contador de for
	Local aCallStack	:= {}				// Array que armazenara a pilha de chamada
	Local aType			:= {}				// Tipos de retorno
	Local aFile 		:= {}				// Array que armazenara os arquivos
	Local aLine 		:= {}				// Array que armazenara as linhas da menssagem
	Local aDate 		:= {}				// Array que armazenara as datas
	Local aTime 		:= {}				// Array que armazenara as horas	

	Self:cName			:= cName
	Self:cMessage		:= cMessage
	Self:oInnerMessage	:= oInnerMessage
	Self:nType			:= nType
	Self:cCallStack		:= ""
	
	If ValType(cName) != "U"		
		// Pega o callstack
		While !Empty(ProcName(nCount))
			aAdd( aCallStack, ProcName(nCount) )
			nCount++
		End
	
		For nCount := 1 To Len(aCallStack)
			GetFuncArray( aCallStack[nCount], @aType, @aFile, @aLine, @aDate, @aTime )
			
			Self:cCallStack += "    on " + aCallStack[nCount] + "(" + If(Len(aFile)>0, aFile[1], "Unknown") + ") " + If(Len(aFile)>0,DToc(aDate[1]),"Unknown") + " line : " + AllTrim(Str(ProcLine(nCount+1))) + If(Len(aCallStack)==nCount,"",Chr(13) + Chr(10))
			nCount++
		End	
	EndIf
Return Self

//--------------------------------------------------------
/*/{Protheus.doc} HasMessage
Se eh uma mensagem e/ou se tem alguma mensagem interna com o nome passado pelo parametro.

@param   cMessageName		Nome identificador da mensagem
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  lHasMessage: .T. se há alguma mensagem ou a mensagem questionada.
@todo    
@obs	  Classe STFWCMessage                                     
@sample
/*/
//--------------------------------------------------------

Method HasMessage( cMessageName ) Class STFWCMessage
	Local lHasMessage := .T.			// Messagem de retorno

	If cMessageName != Nil
		lHasMessage := .F.
		If Lower(Self:cName) == Lower(cMessageName)
			lHasMessage := .T.
		Else
			If Self:oInnerMessage != Nil
				lHasMessage := Self:oInnerMessage:HasMessage( cMessageName )
			EndIf
		EndIf
	EndIf	
Return lHasMessage  

//--------------------------------------------------------
/*/{Protheus.doc} HasError
Se eh uma mensagem do tipo erro e/ou se tem alguma mensagem interna do tipo erro com o nome passado 
pelo parametro.

@param   cMessageName		Nome da mensagem a ser identificada. (Opcional)
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  lHasMessage: .T. se ha alguma mensagem ou a mensagem questionada.
@todo    
@obs	  Classe STFWCMessage             
@sample
/*/
//--------------------------------------------------------

Method HasError( cMessageName ) Class STFWCMessage
	Local lHasMessage := .T.			// Messagem de retorno

	If cMessageName != Nil
		lHasMessage := .F.
		If Lower(Self:cName) == Lower(cMessageName) .And. Self:nType == 1
			lHasMessage := .T.
		Else
			If Self:oInnerMessage != Nil
				lHasMessage := Self:oInnerMessage:HasError( cMessageName )
			EndIf
		EndIf
	EndIf	
Return lHasMessage      

//--------------------------------------------------------
/*/{Protheus.doc} HasWarning
Se eh uma mensagem do tipo erro e/ou se tem alguma mensagem interna do tipo aviso com o nome passado 
pelo parametro.

@param   cMessageName		Nome da mensagem a ser identificada. (Opcional)
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  lHasMessage: .T. se ha alguma mensagem ou a mensagem questionada.
@todo    
@obs	  Classe STFWCMessage             
@sample
/*/
//--------------------------------------------------------

Method HasWarning( cMessageName ) Class STFWCMessage
	Local lHasMessage := .T.			// Messagem de retorno

	If cMessageName != Nil
		lHasMessage := .F.
		If Lower(Self:cName) == Lower(cMessageName) .And. Self:nType == 2
			lHasMessage := .T.
		Else
			If Self:oInnerMessage != Nil		
				lHasMessage := Self:oInnerMessage:HasWarning( cMessageName )
			EndIf
		EndIf
	EndIf	
Return lHasMessage

//--------------------------------------------------------
/*/{Protheus.doc} HasInformation
Se eh uma mensagem do tipo erro e/ou se tem alguma mensagem interna do tipo informacao com o nome 
passado pelo parametro.

@param   cMessageName		Nome da mensagem a ser identificada. (Opcional)
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  lHasMessage: .T. se ha alguma mensagem ou a mensagem questionada.
@todo    
@obs	  Classe STFWCMessage             
@sample
/*/
//--------------------------------------------------------

Method HasInformation( cMessageName ) Class STFWCMessage
	Local lHasMessage := .T.			// Messagem de retorno

	If cMessageName != Nil
		lHasMessage := .F.
		If Lower(Self:cName) == Lower(cMessageName) .And. Self:nType == 3
			lHasMessage := .T.
		Else
			If Self:oInnerMessage != Nil		
				lHasMessage := Self:oInnerMessage:HasWarning( cMessageName )
			EndIf
		EndIf
	EndIf	
Return lHasMessage

//--------------------------------------------------------
/*/{Protheus.doc} ToString
Converte a mensagem para um texto de exibicao.

@param   
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  cText: Texto de exibicao.
@todo    
@obs	  Classe STFWCMessage
@sample
/*/
//--------------------------------------------------------

Method ToString() Class STFWCMessage
	
	Local cText := ""			// Variavel de texto de exibicao.
	
	cText += "Message: " + Self:cName
	If Self:cMessage != Nil .Or. !Empty(Self:cMessage)
		cText += Chr(13) + Chr(10) + Self:cMessage
	EndIf
	If Self:cCallStack != Nil .Or. !Empty(Self:cCallStack)
		cText += Chr(13) + Chr(10) + Self:cCallStack
	EndIf
	
	// Se existir mensagem interna, pega o texto dela
	If Self:oInnerMessage != Nil
		cText += Chr(13) + Chr(10) + Self:oInnerMessage:ToString()
	EndIf	
Return cText