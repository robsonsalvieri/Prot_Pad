#include "rwmake.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³CBMT680GREST º Autor ³ Aecio Ferreira Gomes     º Data ³Tue  12/12/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Valida o estorno do apontamento da produção - Mata680               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CBMT680GREST()
Local nQtdOk := 0
Local nQtdErr:= 0
Local aOKs   := {}
Local lErro  := .f.
Local nX
Local aAreaSD3 := SD3->(GetArea())

If !SuperGetMV("MV_CBPE011",.F.,.F.)
	Return .t.
EndIf

If Type("l250AUTO") == "L" .and. l250AUTO // ---> Executa somente se for Protheus 
	Return .t.
EndIf

If !GetMV("MV_IMPIPOP") $ "1|2" 
   Return .t.
Endif

//-- No estorno posiciona no SD3 correto, caso esteja desposicionado em relacao a SH6, isso serve para excluir a etiqueta correta
If ( ( Type( "l680" ) == "L" .And. l680 ) .Or. ( Type( "l680Auto" ) == "L" .And. l680Auto ) ) .Or.;
   ( ( Type( "l681" ) == "L" .And. l681 ) .Or. ( Type( "l681Auto" ) == "L" .And. l681Auto ) )
   SD3->(dbSetOrder(14)) //-- D3_FILIAL+D3_COD+D3_IDENT
   If SD3->D3_IDENT != SH6->H6_IDENT .And. !SD3->(DbSeek(xFilial("SD3")+SD3->D3_COD+SH6->H6_IDENT))
      RestArea(aAreaSD3)
      Return .T.
   EndIf
EndIf

CB0->(DbSetOrder(7))
If ! CB0->(DbSeek(xFilial("CB0")+Alltrim(SD3->D3_OP)))
   RestArea(aAreaSD3)
   Return .t.
Endif
				
While ! CB0->(EOF()) .and. CB0->CB0_FILIAL+CB0->CB0_OP == xFilial("CB0")+SD3->D3_OP
   If nQtdErr >= SD3->D3_QUANT .OR. nQtdOk >= SD3->D3_QUANT
      Exit
   Endif   
   If CB0->CB0_CODPRO # SD3->D3_COD
      CB0->(DbSkip())
      Loop
   Endif
   If CB0->CB0_NUMSEQ # SD3->D3_NUMSEQ
      CB0->(DbSkip())
      Loop
   Endif
   If ! Empty(CB0->CB0_LOCALI)
      lErro:=.t.      
      AutoGrLog("Etiqueta "+CB0->CB0_CODETI+" ja enderecada  - "+CB0->CB0_LOCALI)
   Endif
   If ! Empty(CB0->CB0_NFSAI+CB0->CB0_SERIES)
      lErro:=.t.
	   AutoGrLog("Etiqueta "+CB0->CB0_CODETI+" possui nota de saida - "+CB0->CB0_NFSAI+'-'+SerieNfId("CB0",2,"CB0_SERIES"))
	Endif
	If !lErro
	   aadd(aOKs,CB0->(RECNO()))	   
	Endif
	CB0->(DbSkip())
Enddo

If lErro
   iF !IsBlind()
      MostraErro()			
   EndIf
   RestArea(aAreaSD3)
   Return .f.
EndIf
		
If !Empty(aOKs)
   For nX:= 1 to Len(aOKs)
      CB0->(DbGoto(aOKs[nX]))
      Reclock("CB0",.F.)
 	   CB0->(DbDelete())
	   CB0->(MsUnlock())
	Next
Endif
RestArea(aAreaSD3)
Return .t.
