#INCLUDE "TKGRPED.ch"
#include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TKGRPED ³ Autor ³ Ewerton C Tomaz        ³ Data ³ 29/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de Entrada para o tratamento do calculo dos itens    ³±±
±±³            no Televendas                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Projeto Ewerton                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function TKGRPED()
Local _nI, _nX
Local _cProdDp 	:= ""
Local _lGeraPen := .F.
Local _nRecSC9  := 0

_aAreaTKGR:= GetArea()

DbSelectArea("SU7")
DbSetOrder(1)

DbSelectArea("SC9")
DbSetOrder(1)

DbSelectArea("SUA")
DbSetOrder(1)
DbSeek(xFilial("SUA") + M->UA_NUM)

/*
If Altera .and. SUA->UA_OPER == "1"
MsgAlert("Alteração não permitida!!", "Atenção" )
RestArea(_aAreaTKGR)
Return(.f.)
EndIf
*/

_nPosPro:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_PRODUTO"})
_nPosPrD:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_DESCRI"})
_nPosLoc:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_LOCAL"  })
_nPosQtd:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_QUANT"  })
_nPosQtA:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_QTDANT" })
_nPosVU := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_VRUNIT" })
_nPosTab:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_PRCTAB" })
_nPosTES:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_TES"    })
_nPosIte:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_ITEM"   })

_aCopia  := aClone(aCols)

aSort(_aCopia,,, { |x, y| x[_nPosPro] < y[_nPosPro] })

For _nI := 1 to Len(_aCopia)
	If _aCopia[_nI,Len(aHeader)+1] == .F.
		If _aCopia[_nI,_nPosQtd] <= 0
			If Empty(_aCopia[_nI,_nPosPro])
				MsgStop(STR0001) //"Verifique se não existe algum item em branco"
			Else
				MsgStop(STR0002+_aCopia[_nI,_nPosPro]+STR0003+Str(_aCopia[_nI,_nPosQtd])) //"Produto "###" com Quantidade Invalida -> "
			Endif
			RestArea(_aAreaTKGR)
			Return .F.
		EndIf
	EndIf
	If _cProdDp == _aCopia[_nI,_nPosPro] .And. !Empty(_aCopia[_nI,_nPosPro])
		MsgStop(STR0002+_aCopia[_nI,_nPosPro]+ STR0004) //"Produto "###" duplicado!"
		RestArea(_aAreaTKGR)
		Return .F.
	EndIf
	_cProdDp := _aCopia[_nI,_nPosPro]
Next _nI

If M->UA_OPER == "1"
	
	If SU7->(DbSeek(xFilial("SU7")+M->UA_OPERADO)) .And. M->UA_FATINT = 'S' //IIF(SU7->U7_POSTO $ "03/04/08",M->UA_FATINT = 'S',.T.)
		_cItenSem := ''
		_nRecSC9 := SC9->(Recno())
		SB2->(DbSetOrder(1))
		For _nX:=1 to Len(aCols)
			If  aCols[_nX,Len(aHeader)+1] == .F.
				If SB2->(DbSeek(xFilial('SB2')+aCols[_nX,_nPosPro]+aCols[_nX,_nPosLoc]))
					_nMix := 0
					If T_BuscaSalCon(M->UA_CLIENTE,aCols[_nX,_nPosPro]) = 0
						_nMix := T_BuscaSalCon('',aCols[_nX,_nPosPro])
					Endif
					If aCols[_nX,_nPosQtA] > 0 .And.;
					   SC9->(dbSeek(xFilial("SC9")+M->UA_NUMSC5+aCols[_nX,_nPosIte])) .And.;
					   Empty(SC9->C9_BLEST)
						_nDispo   := (SB2->(SaldoMov()) - _nMix) + SC9->C9_QTDLIB
					Else
						_nDispo   := (SB2->(SaldoMov()) - _nMix) 
					Endif
					If _nDispo < aCols[_nX,_nPosQtd]
						_cItenSem += aCols[_nX,_nPosPro]+' '+aCols[_nX,_nPosPrD]+STR0005+Str(aCols[_nX,_nPosQtd],10,0)+STR0006+Str(_nDispo,10,0)+Chr(13) //' Qtd.Pedido: '###' Qtd.Disp.: '
					Endif
				Endif
			EndIf
		Next
		SC9->(DbGoTo(_nRecSC9))
		If !Empty(_cItenSem)
/*		    If  SU7->U7_POSTO $ "03/04/08"
				If !MsgBox('Falta Estoque para os Itens Abaixo, Confirma?'+Chr(13)+_cItenSem,'Informacao','YESNO')
					RestArea(_aAreaTKGR)
					Return(.F.)
				Else
					_lGeraPen := .T.
				Endif
			Else  */
				MsgBox(STR0007+Chr(13)+_cItenSem,STR0008,'STOP') //'Falta Estoque para os Itens Abaixo, '###'Informacao'
				RestArea(_aAreaTKGR)
				Return(.F.)
//			Endif
		Endif
	Else	
		_lGeraPen := .T.
	Endif
	
	_cMsg  := ""
	For _nX := 1 to Len(aCols)
		If aCols[_nX,Len(aHeader)+1] == .F.
			
			_cProduto:= aCols[_nX,_nPosPro]
			_nQtde   := aCols[_nX,_nPosQtd]
			_nQtdeA  := aCols[_nX,_nPosQtA]
			cLocal   := aCols[_nX,_nPosLoc]
			
			DbSelectArea("SB2")
			DbSetorder(1)
			If dbseek(xFilial("SB2")+_cProduto+cLocal) .And. SB2->B2_RESERVA < 0
				MsgStop(STR0009+_cProduto+STR0010) //"Inconsistência na reserva do produto:  "###" Comunique Administrador do Sistema"
				RestArea(_aAreaTKGR)
				Return .F.
			Endif
			
			If !empty(M->UA_NUMSC5)
				DbSelectArea('SC9')
				DbSetOrder(1)
				If dbSeek(xFilial("SC9")+M->UA_NUMSC5+StrZero(_nX,2)) .And. !Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST <> '10'
					_nQtdeA := 0
				Endif
			Endif
			
			If ((SaldoSB2() + _nQtdeA) - _nQtde) < 0 .And. !_lGeraPen
				MsgStop(STR0011+_cProduto+STR0012+cLocal+Chr(13)+STR0013+Str(SaldoSB2())) //"Saldo Insuficiente para o Produto "###" no Almoxarifado "###"O saldo para esse produto e de "
				RestArea(_aAreaTKGR)
				Return .F.
			EndIf
			
		EndIf
		_aAreaSUB := SUB->(GetArea())
		DbSelectArea('SUB')
		DbSetOrder(3)
		If (altera .or. (!altera .and. !inclui)) .and. DbSeek(xFilial('SUB')+M->UA_NUM)
			While SUB->(! Eof()) .AND. SUB->UB_FILIAL == xFilial('SUB') .AND. SUB->UB_NUM == M->UA_NUM 
				_nPosWhiPro := aScan(aCols,{|x| Alltrim(x[_nPosProd]) == Alltrim(SUB->UB_PRODUTO)})
				If _nPosWhiPro > 0 .And. _nPosWhiPro < 100 .And. SUB->UB_ITEM <> StrZero(_nPosWhiPro,2)
					MsgStop(STR0014+StrZero(_nPosWhiPro,2)+STR0015+Chr(13)+; //'O Item '###' já existia no Orçamento'
					STR0016+Chr(13)+; //'e a mudança de posição pode causar problemas com estoque'
					STR0017) //'Confirme o Item na mesma posição que estava anteriormente!'
					RestArea(_aAreaTKGR)
					Return(.F.)
				ElseIf _nPosWhiPro = 0
					MsgStop(STR0018+Alltrim(SUB->UB_PRODUTO)+STR0019+Chr(13)+; //'O Produto '###' foi sobreposto por outro item,'
					STR0020+Chr(13)+; //'Favor manter o item e deletar a linha, e inserir o item novo'
					STR0021) //'na ultima linha, isso pode causar problemas com estoque.'
					RestArea(_aAreaTKGR)
					Return(.F.)
				Endif
				DbSkip()
			EndDo
		Endif
		RestArea(_aAreaSUB)
	Next _nX
	If !Empty(M->UA_NUMSC5)
//		Begin Transaction
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek(xFilial("SC5")+M->UA_NUMSC5)
		
		DbSelectArea("SC9")
		DbSetOrder(1)
		If dbSeek(xFilial("SC9")+M->UA_NUMSC5)
			While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == M->UA_NUMSC5 
				_nPosWhiPro := aScan(aCols,{|x| Alltrim(x[_nPosPro]) == Alltrim(SC9->C9_PRODUTO)})
				// Verifica se os produtos gravados anteriormente estao todos no acols ou se foram deletados
				If _nPosWhiPro == 0
					MsgStop(STR0018+Alltrim(SC9->C9_PRODUTO)+STR0019+Chr(13)+; //'O Produto '###' foi sobreposto por outro item,'
					STR0020+Chr(13)+; //'Favor manter o item e deletar a linha, e inserir o item novo'
					STR0021) //'na ultima linha, isso pode causar problemas com estoque.'
					RestArea(_aAreaTKGR)
					Return(.F.)				
				Endif
				If aCols[_nPosWhiPro,Len(aHeader)+1] == .T.
					If aCols[_nPosWhiPro,Len(aHeader)+1] == .T. .And. aCols[_nPosWhiPro,_nPosLoc] = SC9->C9_LOCAL
						DbSelectArea("SB2")
						DbSetOrder(1)
						If dbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL)
							If Empty(SC9->C9_BLEST) //.And. Empty(SC9->C9_BLPRE) - Ewerton 15/03
								RecLock("SB2",.F.)
								SB2->B2_RESERVA -= SC9->C9_QTDLIB
								SB2->B2_QPEDVEN += SC9->C9_QTDLIB
								MsUnLock()
							Endif
						EndIf
					ElseIf aCols[_nPosWhiPro,Len(aHeader)+1] == .T. .And. aCols[_nPosWhiPro,_nPosLoc] <> SC9->C9_LOCAL
						DbSelectArea("SB2")
						DbSetOrder(1)
						If DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL)
							If Empty(SC9->C9_BLEST) //.And. Empty(SC9->C9_BLPRE) - Ewerton 15/03
								RecLock("SB2",.F.)
								SB2->B2_RESERVA -= SC9->C9_QTDLIB
								MsUnLock()
							Endif
						EndIf
						DbSelectArea("SB2")
						DbSetOrder(1)
						If dbSeek(xFilial("SB2")+SC9->C9_PRODUTO+aCols[_nPosWhiPro,_nPosLoc])
							If Empty(SC9->C9_BLEST) //.And. Empty(SC9->C9_BLPRE) - Ewerton 15/03
								RecLock("SB2",.F.)
								SB2->B2_QPEDVEN += SC9->C9_QTDLIB
								MsUnLock()
							Endif
						EndIf
					Else
						DbSelectArea("SB2")
						DbSetOrder(1)
						If dbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL)
							If Empty(SC9->C9_BLEST) //.And. Empty(SC9->C9_BLPRE) - Ewerton 15/03
								RecLock("SB2",.F.)
								SB2->B2_RESERVA -= SC9->C9_QTDLIB
								SB2->B2_QPEDVEN += SC9->C9_QTDLIB
								MsUnLock()
							Endif
						EndIf
					Endif
				ElseIf aCols[_nPosWhiPro,_nPosLoc] <> SC9->C9_LOCAL
					// Verifica se o produto foi modificado o armazem
					DbSelectArea("SB2")
					DbSetOrder(1)
					If DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL)
						RecLock("SB2",.F.)
						If Empty(SC9->C9_BLEST)
							SB2->B2_RESERVA -= SC9->C9_QTDLIB
						Else
							SB2->B2_QPEDVEN -= SC9->C9_QTDLIB
						Endif
						MsUnLock()
					EndIf
					DbSelectArea("SB2")
					DbSetOrder(1)
					If DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+aCols[_nPosWhiPro,_nPosLoc])
						RecLock("SB2",.F.)
						If Empty(SC9->C9_BLEST) .and. (SaldoSb2() >= aCols[_nPosWhiPro,_nPosQtd]) 
							SB2->B2_RESERVA += SC9->C9_QTDLIB
						Else
							SB2->B2_QPEDVEN += SC9->C9_QTDLIB
						Endif
						MsUnLock()
					EndIf
				EndIf
				If (_nPosWhiPro > 0 .And. aCols[_nPosWhiPro,Len(aHeader)+1] == .F.) .And. !Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST <> '10'
					//Todos produtos com bloqueio de estoque passam por aqui.
					If (SaldoSb2() >= aCols[_nPosWhiPro,_nPosQtd])
						DbSelectArea("SB2")
						DbSetOrder(1)
						If dbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL)
							RecLock("SB2",.F.)
							SB2->B2_QPEDVEN += SC9->C9_QTDLIB
							MsUnLock()
						EndIf
					Else
						DbSelectArea("SB2")
						DbSetOrder(1)
						If dbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL)
							RecLock("SB2",.F.)
							SB2->B2_QPEDVEN -= SC9->C9_QTDLIB
							MsUnLock()
						EndIf
					Endif
				ElseIf (_nPosWhiPro > 0 .And. aCols[_nPosWhiPro,Len(aHeader)+1] == .F.) .And. Empty(SC9->C9_BLEST) 
				    // Todos Liberados
				Endif
				DbSelectArea("SC9")
				DbSkip()
			End
		EndIf
		DbSelectArea("SC6")
		DbSetOrder(1)
		_aProdAnt := {}
		If DbSeek(xFilial("SC6")+M->UA_NUMSC5)
			While SC6->(! Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == M->UA_NUMSC5 
				DbSelectArea("SC9")
				DbSetOrder(1)
				DbSeek(xFilial("SC9")+M->UA_NUMSC5+SC6->C6_ITEM)
				If (aScan(aCols,{|x| Alltrim(x[_nPosPro]) == Alltrim(SC6->C6_PRODUTO)}) == 0 .or.;
					aCols[aScan(aCols,{|x| Alltrim(x[_nPosPro]) == Alltrim(SC6->C6_PRODUTO)}),Len(aHeader)+1] == .T. .Or.;
					SC6->C6_LOCAL <> BUSCACOLS("UB_LOCAL") .Or.;
					!Empty(SC9->C9_BLEST))
					DbSelectArea("SC6")
					RecLock("SC6",.F.)
					SC6->C6_QTDANT := 0
					MsUnLock()
				EndIf
				AaDd(_aProdAnt,SC6->C6_PRODUTO)
				DbSelectArea("SC6")
				DbSkip()
			End
			For _nX := 1 To Len(aCols)
				If aScan(_aProdAnt,aCols[_nX,_nPosPro]) == 0
					aCols[_nX,_nPosQtA] := 0
				Endif
			Next
		EndIf
//		END TRANSACTION
	EndIf
Endif

RestArea(_aAreaTKGR)
Return(.T.)
