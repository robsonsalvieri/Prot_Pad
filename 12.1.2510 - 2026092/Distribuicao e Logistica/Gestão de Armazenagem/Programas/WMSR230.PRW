#Include 'FIVEWIN.CH'  
#Include 'WMSR230.CH'

//----------------------------------------------------------
/*/{Protheus.doc} WMSR230
Reabastecimento

@author  Flavio Luiz Vicco
@version	P11
@since   18/10/2006
/*/
//----------------------------------------------------------
Function WMSR230()
Local cMensagem := ""
	cMensagem := "Rotina descontinuada."+CRLF
	cMensagem += "Para emitir a listagem de movimentos de reabastecmento pendentes"+CRLF
	cMensagem += "utilize a rotina de impressão de lista de atividades (WMSR311)."+CRLF
	cMensagem += "Esta rotina irá gerar um mapa de movimentos para o usuário que"+CRLF
	cMensagem += "deverá ser utilizado para apontar a finalização destas atividades." 
	WmsMessage(cMensagem)
Return NIL
