#include "rwmake.ch"
#include "acdmt460est.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ CBMT460EST º Autor ³ Anderson Rodrigues º Data ³Thu 10/07/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Faz validacao do estorno da liberacao dos PV's      			 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CBMT460EST()
Local aArea 	:= GetArea()
Local aAreaSC6 	:= SC6->( GetArea() )
Local nI 		:= 0
Local nItens 	:= 0
Local lRet 		:= .T.

Static aPedi := {"",0}

If !SuperGetMV("MV_CBPE013",.F.,.F.)
	Return lRet
EndIf

If (Type ("__cInternet") <> "U" .and. __cInternet == "AUTOMATICO") .or. Istelnet()
	Return lRet
Endif

If "MATA410" $ FunName()
	If Type("aCols") == "A"
		For nI := 1 To Len(aCols)
			If !aCols[nI,Len(aHeader)+1]
				nItens += 1
			Endif
		Next
	Else
		SC6->( DbSetOrder(1) ) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SC6->( DbSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
		While SC6->( !EOF() ) .And. SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM
		    nItens++
			SC6->( DbSkip() )
		END
	Endif
Endif
If "MATA460A" $ FunName()
	If MV_PAR02 == 2  // parameto 02: Estorno da Liberacao = 2 = Marcados
		DbSelectArea("MA461ESTOR")
		nRecSC9 := MA461ESTOR->SC9RECNO
		MA461ESTOR->(DbGoTop())
		While !MA461ESTOR->(EOF())
			If MA461ESTOR->C9_PEDIDO == SC9->C9_PEDIDO
				nItens += 1
			Endif
			MA461ESTOR->(DbSkip())
		END
		MA461ESTOR->(DbGoTop())
		While !MA461ESTOR->(EOF())
			If MA461ESTOR->SC9RECNO == nRecSC9
				EXIT
			Endif
			MA461ESTOR->(DbSkip())
		END
	else // parameto 02: Estorno da Liberacao = 1 = Posicionado ( não terá controle de itens, pois retorna no 1o return .F. )
		nItens := 0
		aPedi[1] := ""
		aPedi[2] := 0
	Endif
Endif

If ! Empty(SC9->C9_ORDSEP)
	CB7->(DbSetOrder(1))
	If CB7->(DbSeek(xFilial("CB7")+SC9->C9_ORDSEP))
		If aPedi[1] <> ALLTRIM(SC9->C9_PEDIDO)
			Help( ,,'CBMT460EST',,I18N(STR0001,{SC9->C9_PEDIDO, SC9->C9_ORDSEP}), 1, 0) //A liberacao do Pedido [numeroPedido] nao pode ser estornada pois o mesmo encontra-se amarrado a Ordem de Separacao [ordemSeparacao]
			aPedi[1] := ALLTRIM(SC9->C9_PEDIDO)
			aPedi[2] := 1
			lRet := .F.
		Else
			// valida se for o ultimo item, zera o controle para exibir a mensagem novamente, caso alterar o mesmo pedido
			aPedi[2] += 1
			If "MATA410" $ FunName() .Or. "MATA460A" $ FunName()
				If aPedi[2] >= nItens
					aPedi[1] := ""
					aPedi[2] := 0
				Endif
			Endif
			lRet := .F.
		Endif
	Else
		RecLock("SC9",.F.)
		SC9->C9_ORDSEP:= ""
		SC9->(MsUnLock())
	Endif
Endif

RestArea( aArea )
RestArea( aAreaSC6 )
FWFreeArray( aArea )
FWFreeArray( aAreaSC6 )
Return lRet
