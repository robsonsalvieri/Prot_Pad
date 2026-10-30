#include "PROTHEUS.ch" 
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE "WMSXMSG.CH"
#define MSG_INFO     0
#define MSG_WARNING  1
#define MSG_ERROR    2
#define MSG_QUESTION 3
#define MSG_CUSTOM   4
#define MSG_HELP     5
#define MAXHELP      40

Static _cMessage  := ""
Static _cTitle    := "SIGAWMS"
Static _nTipoMsg  := 0
Static _lExibeMsg := .T.

Function WmsMsgExibe(lExibe)
Local lOldExibe := _lExibeMsg
   If ValType(lExibe) == 'L'
      _lExibeMsg := lExibe
   EndIf 
Return lOldExibe

Function WmsLastMsg()
Return _cMessage

Function WmsLastTit()
Return _cTitle

Function WmsMsgType()
Return _nTipoMsg

Function WmsQuestion(cMsg,cTitle)
Default cTitle := "SIGAWMS"
Return Iif(!ISTelNet(),MsgYesNo(cMsg,cTitle),(WMSVTAviso(cTitle,cMsg,{STR0001,STR0002})==1)) // Sim // Nao

Function WmsMessage(cMsg,cTitle,nTipo,lExibe,aBtns,cSolucao,nTamAvis)
   Default cTitle := "SIGAWMS"
   Default nTipo  := MSG_INFO
   Default lExibe := _lExibeMsg
   Default aBtns  := Iif(ISTelNet(),Nil,{STR0003}) // OK
   Default cSolucao := ""
   Default nTamAvis := 3
   
   _cMessage := cMsg
   _cTitle   := cTitle
   _nTipoMsg := nTipo
   
   If !lExibe
      Return Nil
   EndIf 
   
   If ISTelNet()
      If nTipo == MSG_QUESTION
         aBtns := {STR0001,STR0002} // Sim // Nao
      EndIf 
      Return WMSVTAviso(cTitle,cMsg,aBtns)
   Else
      If nTipo != MSG_QUESTION .And. !Empty(cSolucao)
         WmsHelp(cMsg,cSolucao,cTitle)
      ElseIf nTipo == MSG_INFO
         MsgInfo(cMsg,cTitle)
      ElseIf nTipo == MSG_WARNING
         MsgAlert(cMsg,cTitle)
      ElseIf nTipo == MSG_ERROR
         MsgStop(cMsg,cTitle)
      ElseIf nTipo == MSG_QUESTION
         Return MsgYesNo(cMsg,cTitle)
      ElseIf nTipo == MSG_HELP
         WmsHelp(cMsg,cSolucao,cTitle)
      Else
         Return Aviso(cTitle,cMsg,aBtns,nTamAvis)
      EndIf
   EndIf
   
Return Nil 

Function WmsFmtMsg(cMessage,aStrRepl)
Local nI      := 0
Local cRetMsg := cMessage

   For nI := 1 To Len(aStrRepl)
      If ValType(aStrRepl[nI]) == "A" .And. Len(aStrRepl[nI]) == 2
         cRetMsg := StrTran(cRetMsg,aStrRepl[nI][1],AllTrim(aStrRepl[nI][2]))
      EndIf
   Next
Return cRetMsg

Function WmsHelp(cProblema,cSolucao,cTitle)
Local aSolucao  := {}
Local nLines    := 0
Local nCnt      := 0
Default cTitle := "SIGAWMS"

   If Empty(cSolucao)
      Help( ,1,cTitle,,cProblema,1,0)
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
      Help(,1,cTitle,,cProblema,1,0,,,,,,aSolucao)
      //ShowHelpDlg(cTitle,aProblema,Len(aProblema),aSolucao,Len(aSolucao))
   EndIf
Return Nil

Function WMSVTAviso(cCabec, cMsg, aOpcoes, lWait, nItemIni)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(),  VTMaxCol())
Local nOpcao    := 1
Local nX        := 0
Local nLines    := 0 
Local aMsg      := {}
Local lTerminal := (VTMaxRow()==1)
Default cCabec  := STR0004 // Atencao
Default cMsg    := ''
Default aOpcoes := {}
Default lWait   := .T.
Default nItemIni := 1

//-- Permite SOMENTE TRES opcoes
If Len(aOpcoes) > 1
   If Len(aOpcoes)>3
      aSize(aOpcoes, 3)
   EndIf
EndIf

cMsg := FwNoAccent(cMsg)

VTBeep(2)
VTClearBuffer()
If ! lTerminal
   DLVTCabec(cCabec, .F., .F., .T.)
   //Determina o múmero de linhas da mensagem
   nLines := MlCount(cMsg, VTMaxCol())
   //Se não é multipla escolha e a mensagem ultrapassa a tela
   //Força a quebra da mensagem para gerar rolagem da tela
   If (Len(aOpcoes) <= 0 .And. nLines >= VTMaxRow())
      For nX := 1 To nLines
         AAdd(aMsg, MemoLine(cMsg, VTMaxCol(), nX))
      Next nX
      VTAchoice(01,00,VTMaxRow(),VtMaxCol(),aMsg,,,VTMaxRow(),.T.)
      VTInkey()
   //Se as opções mais a mensagem ultrapassam a tela
   ElseIf ((Len(aOpcoes)+nLines) > VTMaxRow())
      //Exibe a mensagem de forma cortada, forçando rolagem de tela
      For nX := 1 To nLines
         AAdd(aMsg, MemoLine(cMsg, VTMaxCol(), nX))
      Next nX
      //Força uma impressão das respostas na tela
      For nX := 1 To Len(aOpcoes)
         @ nX+(VTMaxRow()-Len(aOpcoes)), 00 VTSay aOpcoes[nX]
      Next nX
      //Mostra a mensagem para o usuário com rolagem de tela
      VTAchoice(01,00,(VTMaxRow()-Len(aOpcoes)),VtMaxCol(),aMsg,,,(VTMaxRow()-Len(aOpcoes)),.T.)
      VTInkey()
      //Mostra as opções, agora com a opção de escolha do usuário
      nOpcao := VTachoice(((VTMaxRow()+1)-Len(aOpcoes)),0,VTMaxRow(),VtMaxCol(),aOpcoes,,,nItemIni,.T.)
      VTInkey()
   Else 
      For nX := 1 To nLines
         @ nX, 00 VTSay MemoLine(cMsg, VTMaxCol(), nX)
      Next nX
      If Len(aOpcoes) > 0
         nOpcao := VTachoice(((VTMaxRow()+1)-Len(aOpcoes)),0,VTMaxRow(),VtMaxCol(),aOpcoes,,,nItemIni,.T.)
         VTInkey()
      Else
         DLVTRodaPe(, lWait)
      EndIf
   EndIf
   If lWait
      VTRestore(00, 00, VTMaxRow(),  VTMaxCol(), aTelaAnt)
   EndIf
Else
   VtClear()
   @ 00,00 VTSay cMsg
   If Len(aOpcoes) > 0
      nOpcao := VTAchoice(01, 00, VTMaxRow(),  VTMaxCol(), aOpcoes,,,nItemIni)
      VTInkey()
   Else
      nOpcao := 1
      VTInkey(0)
   EndIf
   If lWait
      VTRestore(00, 00, VTMaxRow(),  VTMaxCol(), aTelaAnt)
   EndIf
EndIf
Return nOpcao
