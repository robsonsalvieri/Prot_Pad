#INCLUDE "FDPV005.ch"
#include "eADVPL.ch"

Function PVConfirmPed(aItePed, nTotPed, nDescPedRG, lConfirmPed, lCons, cSfaInd, nTotInd)
Local oDlg, oBrw
Local oBtnVltPed, oBtnConfPed
Local oTxtSIte, oTxtSTPed, oTxtTPed, oTxtDPed, oTxtInden
Local nSIte:= 0, nSTPed:= 0, nTPed :=0, nDPed:=0
Local nTotPedSDesc := 0 // Variavel que soma o total do Pedido sem desconto
Local nDescPed := 0 // Variavel que soma o total dos Descontos do Pedido dados pelo vendedor
Local nInd := Round(nTotInd,2) //Valor da indenizacao
Local oCol
nSIte	:=Len(aItePed)
nSTPed	:= Round(nTotPed,2)
nDPed	:=Round(nDescPedRG,2)

If lCons
	DEFINE DIALOG oDlg TITLE STR0001 //"Consulta dos Itens do Pedido"
else
	DEFINE DIALOG oDlg TITLE STR0002 //"Confirmação do Pedido"
Endif

For ni := 1 To Len(aItePed)
	//nDescPed := nDescPed + ((aItePed[ni,4] * aItePed[ni,6]) * (aItePed[ni,7]/100))
	If cCalcProtheus == "T"
		nDescPed := nDescPed + (aItePed[ni,4] * Round((aItePed[ni,6] * (aItePed[ni,7] / 100)),2))
	Else
		nDescPed := nDescPed + ((aItePed[ni,4] * aItePed[ni,6]) * (aItePed[ni,7]/100))
	Endif
	nTotPedSDesc := nTotPedSDesc + (aItePed[ni,4] * aItePed[ni,6])
Next

// Total do Pedido com todos os descontos (Regra de Desconto e Vendedor)
nTPed := nTotPedSDesc - nDPed - nDescPed

// Desconta a Indenizacao do Total de Pedido
If cSfaInd = "T"
	nTPed := nTPed - nInd
EndIf
nTPed := Round(nTPed,2)

@ 20,02 BROWSE oBrw SIZE 155,70 OF oDlg
SET BROWSE oBrw ARRAY aItePed
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1  HEADER STR0003 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2  HEADER STR0004 WIDTH 150	//Acresc. 11/06/03 //"Descr."
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4  HEADER STR0005 WIDTH 40 //"Qtde"
If lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 13 HEADER STR0006 WIDTH 40 //"Qtde Ent"
EndIf
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 6  HEADER STR0007 WIDTH 40 //"Preco"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 7  HEADER STR0008 WIDTH 40 //"Desconto"
If !lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 8 HEADER STR0009 WIDTH 30 //"Tes"
EndIf
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 9 HEADER STR0010 WIDTH 45 //"Sub Tot."
If lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 14 HEADER STR0011 WIDTH 80 //"Status"
EndIf
@ 94,7 SAY STR0012 of oDlg //"Item(ns): "
@ 94,50 GET oTxtSIte VAR nSIte READONLY SIZE 40,12 of oDlg

If cSfaInd == "T"
	@ 94,93 SAY STR0013 of oDlg //"Inden.: "
	@ 94,123 GET oTxtInden VAR nInd READONLY SIZE 40,12 of oDlg
Endif

@ 106,7 SAY STR0014 of oDlg //"SubTotal: "
@ 106,50 GET oTxtSTPed VAR nTotPedSDesc READONLY SIZE 80,12 of oDlg

@ 118,7 SAY STR0015 of oDlg //"Desconto: "
@ 118,50 GET oTxtDPed VAR nDescPed READONLY SIZE 40,12 of oDlg

@ 118,93 SAY STR0016 of oDlg //"R.Desc: "
@ 118,123 GET oTxtDPed VAR nDPed READONLY SIZE 40,12 of oDlg

@ 130,7 SAY STR0017 of oDlg //"Total: "
@ 130,50 GET oTxtTPed VAR nTPed READONLY SIZE 80,12 of oDlg

if !lCons 
	@ 142,01 BUTTON oBtnConfPed CAPTION STR0018 ACTION PVFecConfT(lConfirmPed) SIZE 70,15 OF oDlg //"Confirmar"
Endif
@ 142,85 BUTTON oBtnVltPed CAPTION STR0019 ACTION PVFecConfF(lConfirmPed,aItePed)SIZE 70,15 OF oDlg //"Cancelar"

ACTIVATE DIALOG oDlg

Return Nil                                                          

Function PVFecConfT(lConfirmPed)
	lConfirmPed := .T.
	CloseDialog() 
Return Nil

Function PVFecConfF(lConfirmPed, aItePed)
Local nCont:=len(aItePed)
While nCont > 0    
	if aItePed[nCont,11] == 1
		aDel(aItePed,nCont)
	Else
		break
	Endif
	nCont--
Enddo	

if nCont<len(aItePed)
	aSize(aItePed,len(aItePed)-1)
Endif    

lConfirmPed := .F. 
CloseDialog() 
Return Nil