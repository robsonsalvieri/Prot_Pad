#INCLUDE "PROTHEUS.CH"   
#INCLUDE "LOJA0049.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Protheus necessita ter ao menos uma funcao para que o    ³
//³fonte seja exibido na inspecao de fontes do RPO.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function StFwCMsgMe() ; Return

//--------------------------------------------------------
/*/{Protheus.doc} STFWCMessageManager
Gerenciador de troca de mensagens, utilizada para a troca de mensagens entre funcoes.

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWCMessageManager
@since   29/03/2012
@return  Self
@todo    
@obs     Herda da classe FWSerialize     
@sample

Static Function TstLJMM()
	Local oLJCMessageManager := GetLJCMessageManager()
	Public __cInternet	
	
	__cInternet := "AUTOMATICO"
	
	If oLJCMessageManager:HasMessage()
		ConOut("Falhou")
	Else
		ConOut("Passou")
	EndIf
	
	oLJCMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroA", 1, "Ocorreu o erro no TCP" ) )	
	If oLJCMessageManager:HasMessage()
		ConOut("Passou")
	Else
		ConOut("Falhou")
	EndIf	
	
	oLJCMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroB", 1, "Não foi possivel efetuar o download." ) )	
	If oLJCMessageManager:HasMessage( "ErroB" )
		ConOut("Passou")
	Else
		ConOut("Falhou")
	EndIf		
	
	oLJCMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroC", 2, "Não foi possivel efetuar carga" ) )	
	If oLJCMessageManager:HasWarning()
		ConOut("Passou")
	Else
		ConOut("Falhou")
	EndIf			
	
	If oLJCMessageManager:HasWarning( "ErroC" )
		ConOut("Passou")
	Else
		ConOut("Falhou")
	EndIf	
	
	If oLJCMessageManager:HasInformation( "ErroC" )
		ConOut("Falhou")
	Else
		ConOut("Passou")		
	EndIf		
	
	oLJCMessageManager:Show( "Há uma mensagem" )
	                              
	ConOut( oLJCMessageManager:Serialize() )	
	
	oLJCMessageManager:Clear()
	If oLJCMessageManager:HasMessage()
		ConOut("Falhou")
	Else
		ConOut("Passou")
	EndIf  
Return    

/*/
//--------------------------------------------------------

Class STFWCMessageManager From FWSerialize
	Data oMessage
	
	Method STFWCMessageManager()
	Method HasMessage()
	Method HasError()
	Method HasWarning()
	Method HasInformation()
	Method ThrowMessage()
	Method Clear()
	Method Show()
EndClass

//--------------------------------------------------------
/*/{Protheus.doc} STFWCMessageManager
Metodo construtor da classe STFWCMessageManager.

@param   
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  Self
@todo    
@obs	  Classe STFWCMessageManager                                     
@sample
/*/
//--------------------------------------------------------

Method STFWCMessageManager() Class STFWCMessageManager

Return Self
                     
//--------------------------------------------------------
/*/{Protheus.doc} HasMessage
Se eh uma mensagem e/ou se tem alguma mensagem interna com o nome passado pelo parametro.


@param   cMessageName		Nome da mensagem a ser identificada. (Opcional).
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  lHasMessage: .T. se há alguma mensagem ou a mensagem questionada.
@todo    
@obs	  Classe STFWCMessageManager                                     
@sample
/*/
//--------------------------------------------------------

Method HasMessage( cMessageName ) Class STFWCMessageManager
	Local lHasMessage	:= .F.

	If Self:oMessage != Nil
		If cMessageName == Nil
			lHasMessage := .T.
		Else
			lHasMessage := Self:oMessage:HasMessage( cMessageName )
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
@obs	  Classe STFWCMessageManager             
@sample
/*/
//--------------------------------------------------------

Method HasError( cMessageName ) Class STFWCMessageManager
	Local lHasMessage	:= .F.

	If Self:oMessage != Nil
		If cMessageName == Nil
			lHasMessage := .T.
		Else
			lHasMessage := Self:oMessage:HasError( cMessageName )
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
@obs	  Classe STFWCMessageManager             
@sample
/*/
//--------------------------------------------------------

Method HasWarning( cMessageName ) Class STFWCMessageManager
	Local lHasMessage	:= .F.

	If Self:oMessage != Nil
		If cMessageName == Nil
			lHasMessage := .T.
		Else
			lHasMessage := Self:oMessage:HasWarning( cMessageName )
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
@obs	  Classe STFWCMessageManager             
@sample
/*/
//--------------------------------------------------------

Method HasInformation( cMessageName ) Class STFWCMessageManager
	Local lHasMessage	:= .F.

	If Self:oMessage != Nil
		If cMessageName == Nil
			lHasMessage := .T.
		Else
			lHasMessage := Self:oMessage:HasInformation( cMessageName )
		EndIf
	EndIf
Return lHasMessage

//--------------------------------------------------------
/*/{Protheus.doc} ThrowMessage
Grava uma mensagem no gerenciador de mensagens.

@param   oMessage			Objeto LJCMessage com a mensagem.
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  Self
@todo    
@obs	  Classe STFWCMessageManager             
@sample
/*/
//--------------------------------------------------------

Method ThrowMessage( oMessage ) Class STFWCMessageManager
	oMessage:oInnerMessage := Self:oMessage
	Self:oMessage := oMessage
Return

//--------------------------------------------------------
/*/{Protheus.doc} Clear
Limpa a cadeia de mensagens existente no gerenciador de mensagem.

@param   
@author  Varejo
@version P11.8
@see                                             
@since   29/03/2012
@return  Self
@todo    
@obs	  Classe STFWCMessageManager             
@sample
/*/
//--------------------------------------------------------

Method Clear() Class STFWCMessageManager
	Self:oMessage := Nil
Return

//--------------------------------------------------------
/*/{Protheus.doc} Show 
Exibe a mensagem e suas mensagens internas.

@param   cMessage: Texto de exibição principal.
@author  Varejo
@version P11.8
@see                                             
@since   02/04/2012
@return  Self
@todo    
@obs	  Classe STFWCMessageManager             
@sample
/*/
//--------------------------------------------------------

Method Show( cMessage ) Class STFWCMessageManager
	Local oDlgII				:= Nil
	Local oFntTit				:= Nil
	Local oFntMsg				:= Nil
	Local oBmp					:= Nil
	Local oMsgDet				:= Nil
	Local lTelaDetalhe			:= .F.
	Local lExibeBotaoDetalhe	:= .F.
	
	If IsBlind()
		ConOut( STR0001 + ": " + cMessage ) // "Mensagem"
		If Self:oMessage != Nil
			ConOut( STR0002 + ": " + Self:oMessage:ToString() ) // "Detalhes"
		EndIf
	Else
		If Self:HasMessage() .And. Self:oMessage != Nil
			lExibeBotaoDetalhe := .T.
		EndIf
		
		DEFINE MSDIALOG oDlgII TITLE STR0001 FROM 0,0 TO 130,600 PIXEL // "Mensagem"
		
		DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
		DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15
		
		@05,2 TO 45,300 PROMPT STR0003 PIXEL // "Informação"
		@11,4 GET cMessage FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 245,30 PIXEL
		
		@50,200 BUTTON "OK" PIXEL ACTION oDlgII:End()
		
		If lExibeBotaoDetalhe .And. Self:oMessage != Nil
			@50,230 BUTTON STR0002 PIXEL ACTION If(	!lTelaDetalhe,;  // "Detalhes"
			(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
			(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight-165,,.T.),lTelaDetalhe:=.F.))		
			@ 67,2 TO 140,300 PROMPT STR0004 PIXEL // "Detalhes da informação:"
			@ 73,4 GET oMsgDet VAR Self:oMessage:ToString() FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 245,65 PIXEL
		EndIf
		
		ACTIVATE MSDIALOG oDlgII CENTERED
	EndIf
Return

//--------------------------------------------------------
/*/{Protheus.doc} GetSTFWCMessageManager 
Pega o gerenciador de mensagens global.

@param   
@author  Varejo
@version P11.8
@see                                             
@since   02/04/2012
@return  Self
@todo    
@obs	  Funcao Get             
@sample
/*/
//--------------------------------------------------------

Function GetSTFWCMessageManager()
	Public _oSTFWCMessageManager
	
	If _oSTFWCMessageManager == Nil
		_oSTFWCMessageManager := STFWCMessageManager():New()
	EndIf                                     
Return _oSTFWCMessageManager 

//--------------------------------------------------------
/*/{Protheus.doc} SetSTFWCMessageManager 
Configura o gerenciador de mensagens global.

@param   
@author  Varejo
@version P11.8
@see                                             
@since   02/04/2012
@return  Self
@todo    
@obs	  Funcao Set             
@sample
/*/
//--------------------------------------------------------

Function SetSTFWCMessageManager( oSTFWCMessageManager )
	Public _oSTFWCMessageManager
	_oSTFWCMessageManager := oSTFWCMessageManager
Return