#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"
#INCLUDE "ACDXFAT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldOsStatus Autor ³ Pedro Antonio Missaglia³ Data ³ 15/04/19³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe Ordem de Separacao em aberto            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAliasSC9   - Alias da SC9                                 ³±±
±±³            C5RECNO     - Recno da SC5                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Tipo do ID                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AcdFatOsep(cAliasSC9,C5RECNO,cPedido,cItem, cSequen )
Local lRet := .T.
Local lIntACD :=  SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local aArea := GetArea()

Default cPedido := ""
Default cItem 	:= ""
Default cSequen	:= ""

If lIntACD
	Do Case
	Case IsInCallStack('Ma410PvNfs') 
		lRet := AcdPVxOsep(cAliasSC9)
	Case IsInCallStack('MA460PROC') .or.( cPaisLoc <> "BRA" .and. IsInCallStack("A462ANGera"))
		lRet := AcdNFxOsep(cAliasSC9,C5RECNO,cPedido,cItem, cSequen )
	EndCase
Endif	

RestArea(aArea)
Return lRet

Static Function AcdNFxOsep(cAliasSC9,C5RECNO,cPedido,cItem, cSequen )
Local lRet := .T.
Local cChave := ""
Local aArea		:= GetArea()
Local aAreaCB7	:= CB7->( GetArea() )
Local aAreaAlias:= (cAliasSC9)->( GetArea() )
Local lIsMark   := .F.

dbSelectArea( 'CB7' )
CB7->( dbSetorder( 1 ) )

(cAliasSC9)->(Dbsetorder(1)) //C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED

If !Empty(cPedido) .And. !Empty(cItem)
	cChave := cPedido + cItem + cSequen
Else
	SC5->(MsGoto(C5RECNO))
	cChave := SC5->C5_NUM
EndIf

If (cAliasSC9)->(dbSeek(xFilial(cAliasSC9)+cChave))
	lIsMark := IIf(ThisInv(), Empty(SC9->C9_OK), SC9->C9_OK == ThisMark())
	If lIsMark
		If !Empty((cAliasSC9)->C9_ORDSEP) 
			If CB7->( dbSeek( FWxFilial("CB7") + (cAliasSC9)->C9_ORDSEP ) )
				If (CB7->CB7_STATUS <> "2" .AND. CB7->CB7_STATUS <> "4" .AND. CB7->CB7_STATUS <> "9")
					ApMsgAlert(STR0001 + cPedido + STR0002 + (cAliasSC9)->C9_ORDSEP + STR0003)
					lRet := .F.	      
				EndIf 
			EndiF
		EndIf
	Else
		lRet := .F. //Entrou na função sem estar marcado
	EndIf
Endif	

RestArea( aAreaAlias )
RestArea( aAreaCB7 )
RestArea( aArea )
Return lRet


Static Function AcdPVxOsep(cAliasSC9)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaCB7	:= CB7->( GetArea() )
Local aAreaAlias:= (cAliasSC9)->( GetArea() )

dbSelectArea( 'CB7' )
CB7->( dbsetorder( 1 ) )

(cAliasSC9)->(Dbsetorder(1))//C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED

If (cAliasSC9)->(dbSeek(xFilial(cAliasSC9)+SC5->C5_NUM))
	While !(cAliasSC9)->( Eof() ) .And. (cAliasSC9)->C9_FILIAL == FWxFilial(cAliasSC9) .And. (cAliasSC9)->C9_PEDIDO == SC5->C5_NUM
		If !Empty((cAliasSC9)->C9_ORDSEP) 
			If CB7->( dbSeek( FWxFilial("CB7") + (cAliasSC9)->C9_ORDSEP ) )
				If !(!'*03' $ CB7->CB7_TIPEXP .AND. CB7->CB7_STATUS >= "4" .AND. !"*09" $ CB7->CB7_TIPEXP)
					ApMsgAlert(STR0001 + SC5->C5_NUM + STR0004)
					lRet := .F.	
					Exit      
				EndIf 
			EndiF
		EndIf
		(cAliasSC9)->(dbSkip())
	End
Endif

RestArea( aAreaAlias )
RestArea( aAreaCB7 )
RestArea( aArea )
Return lRet
