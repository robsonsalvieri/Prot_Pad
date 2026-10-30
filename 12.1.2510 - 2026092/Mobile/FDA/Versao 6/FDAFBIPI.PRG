#include "FDAXFIS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FdaBsIPi   ³ Autor ³ Henry Fila           ³ Data ³ 18.10.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca a posicao de acordo com a referencia fiscal            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/        

Function FdaBsIpi(nItem,aFdaNfCab,aFdaNfItem)                          
Local cChaveB1:=aFdaNfItem[nItem,IT_PRODUTO]
Local cChaveF4:=aFdaNfItem[nItem,IT_TES]

dbSelectArea("HB1")
dbSetOrder(1)
dbSeek(cChaveB1)

dbSelectArea("HF4")
dbSetOrder(1)
dbSeek(cChaveF4)

If  HF4->F4_IPI <> "N"                                                             
	aFdaNfItem[nItem,IT_BASEIPI] := aFdaNfItem[nItem,IT_VALMERC] - aFdaNfItem[nItem,IT_DESCONTO]
	If HF4->F4_DESPIPI <> "N"
		aFdaNfItem[nItem,IT_BASEIPI]:= aFdaNfItem[nItem,IT_BASEIPI] + aFdaNfItem[nItem,IT_DESPESA] 
		aFdaNfItem[nItem,IT_BASEIPI]:= aFdaNfItem[nItem,IT_BASEIPI] + aFdaNfItem[nItem,IT_SEGURO] 		
	Endif

	If HF4->F4_IPIFRET <> "N"         
		aFdaNfItem[nItem,IT_BASEIPI] := aFdaNfItem[nItem,IT_BASEIPI] + aFdaNfItem[nItem,IT_FRETE]
	EndIf
	If ( HF4->F4_TPIPI=="B" .Or. (MV_IPIBRUTO=="S" .And. HF4->F4_TPIPI ==" ") )
		aFdaNfItem[nItem,IT_BASEIPI] := aFdaNfItem[nItem,IT_BASEIPI] + aFdaNfItem[nItem,IT_DESCONTO]
	EndIf

	aFdaNfItem[nItem,IT_BIPIORI] := FdaNoRound(aFdaNfItem[nItem,IT_BASEIPI],2)

	If ( HF4->F4_BASEIPI <> 0 )
		aFdaNfItem[nItem,IT_BASEIPI] := FdaNoRound(aFdaNfItem[nItem,IT_BASEIPI] * HF4->F4_BASEIPI /100,2)
	Else       
		aFdaNfItem[nItem,IT_BASEIPI] := FdaNoRound(aFdaNfItem[nItem,IT_BASEIPI],2)  
	EndIf

Else
    aFdaNfItem[nItem,IT_BASEIPI] := 0 
EndIf

Return                           
