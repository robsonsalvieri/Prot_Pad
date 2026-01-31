#INCLUDE "PROTHEUS.ch"

#DEFINE MSG_INFO     0
#DEFINE MSG_WARNING  1
#DEFINE MSG_ERROR    2
#DEFINE MSG_QUESTION 3
#DEFINE MSG_CUSTOM   4
#DEFINE MSG_HELP     5
#DEFINE MAXHELP      40

Static _lExibeMsg := .T.
//-----------------------------------------------------------------------------
/*/{Protheus.doc} GFEMessage
Função padrão de tratamento de mensagens GFE
@type  Function
@author Squad GFE
@since 05/06/2020
@version 1.0
@param nTipo, numeric, Indica o tipo de mensagem que será apresentada
@param cTitle, caracter, Titulo da tela de mensagem
@param cMsg, caracter, Mensagem
@param cSolucao, caracter, Solucao
@param lExibe, logical, Indica se irá apresentar a mensagem
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------------
Function GFEMessage(nTipo,cTitle,cMsg,cSolucao,lExibe)
Default cTitle      := "SIGAGFE"
Default nTipo       := MSG_INFO
Default lExibe      := _lExibeMsg
Default cSolucao    := ""

	_cMessage := cMsg
	_cTitle   := cTitle
	_nTipoMsg := nTipo

	If !lExibe
		Return Nil
	EndIf

	If nTipo != MSG_QUESTION .And. !Empty(cSolucao)
		GFEHelp(cMsg,cSolucao,cTitle)
	ElseIf nTipo == MSG_INFO
		MsgInfo(cMsg,cTitle)
	ElseIf nTipo == MSG_WARNING
		MsgAlert(cMsg,cTitle)
	ElseIf nTipo == MSG_ERROR
		MsgStop(cMsg,cTitle)
	ElseIf nTipo == MSG_QUESTION
		Return MsgYesNo(cMsg,cTitle)
	ElseIf nTipo == MSG_HELP
		GFEHelp(cMsg,cSolucao,cTitle)
	Else
		Return Aviso(cTitle,cMsg)
	EndIf
Return Nil
//-----------------------------------------------------------------------------
/*/{Protheus.doc} GFEHelp
Função de mensagem do tipo 1 - Help()
@type  Function
@author Squad GFE
@since 05/06/2020
@version 1.0
@param cProblema, caracter, Mensagem
@param cSolucao, caracter, Solucao
@param cTitle, caracter, Titulo da tela de mensagem
@param lGravaLog, logical, Indica se irá gravar log
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------------
Function GFEHelp(cProblema,cSolucao,cTitle,lGravaLog)
Local aSolucao  := {}
Local nLines    := 0
Local nCnt      := 0

Default cTitle    := "SIGAGFE"
Default lGravaLog := .F.

	If Empty(cSolucao)
		Help( ,1,cTitle,,cProblema,1,0,,,,,lGravaLog)
	Else
		nLines := MlCount(cSolucao, MAXHELP)
		For nCnt := 1 To nLines
			AAdd(aSolucao, MemoLine(cSolucao, MAXHELP, nCnt))
			//O máximo de linhas possíveis é 5
			If nCnt == 5
				Exit
			EndIf
		Next nCnt
		//Help - Ajuda para o campo ( [ uPar1 ] [ uPar2 ] [ cCampo ] [ cNome ] [ cMensagem ] [ nLinha1 ] [ nColuna ] [ lPop ] [ uPar9 ] [ uPar10 ] [ uPar11 ] [ lGravaLog ][aSoluc] )
		Help( ,1,cTitle,,cProblema,1,0,,,,,lGravaLog,aSolucao)
	EndIf
Return Nil
//-----------------------------------------------------------------------------
/*/{Protheus.doc} GFEMsgFmt
Função formatação de mensagens que apresentam valores em momento de execução
@type  Function
@author Squad GFE
@since 05/06/2020
@version 1.0
@param cMessage, caracter, Mensagem a ser formatada
@param aStrRepl, array, Lista de tags e valores a serem formatados
@Return cRetMsg, caracter, Mensagem formatada
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------------
Function GFEMsgFmt(cMessage,aStrRepl)
Local nI      := 0
Local nF      := 0
Local cRetMsg := cMessage
	nF := Len(aStrRepl)
	For nI := 1 To Len(aStrRepl)
		If ValType(aStrRepl[nI]) == "A" .And. Len(aStrRepl[nI]) == 2
			cRetMsg := StrTran(cRetMsg,aStrRepl[nI][1],AllTrim(aStrRepl[nI][2]))
		EndIf
	Next nI
Return cRetMsg