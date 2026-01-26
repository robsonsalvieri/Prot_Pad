#INCLUDE "SFPV005.ch"
#include "eADVPL.ch"

Function PVConfirmPed(aItePed, aCabPed, nDescInd, nDescReg, cSfaInd, lConfirmPed, lCons, aObj)

Local oDlg, oBrw
Local oBtnVltPed, oBtnConfPed
Local oTxtSIte, oTxtSTPed, oTxtTPed, oTxtDPed, oTxtInden
Local oCol

Local nQtdIte		:= Len(aItePed)                                 //Nr. de itens do pedido
Local nTotPed		:= Round(aCabPed[12,1],TamADVC("HC5_VALOR",2)) //Total do Pedido 
Local nValDescIte	:= 0
Local nValAcreIte	:= 0
Local nDescPed		:= 0
Local nAcrePed		:= 0
Local nSubTotal		:= 0
Local nSaldo		:= 0
Local nTotal		:= 0

Local nI			:= 0
Local nJ			:= 0

Local nPos			:= 0
Local nDistObj		:= 0

Local cPictVal		:= SetPicture("HC6","HC6_PRCVEN")
Local cPictTot		:= SetPicture("HC5","HC5_VALOR")
Local cPictDes		:= SetPicture("HC6","HC6_DESC")

If lCons
	DEFINE DIALOG oDlg TITLE STR0001 //"Consulta dos Itens do Pedido"
Else
	DEFINE DIALOG oDlg TITLE STR0002 //"Confirmação do Pedido"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula descescimo/Acrescimo dos itens do pedido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 To Len(aItePed)
	nSubTotal += aItePed[ni,16] * aItePed[ni,4]
	//Calcula somente o que nao for item de bonificacao
	If aItePed[ni,11] <> 1
		If aItePed[ni,16] > 0 .And. aItePed[ni,6] > 0
			nValDescIte := 0
			nValAcreIte := 0
			If aItePed[ni,16] > aItePed[ni,6] //Se o preco de tabela for maior que o preco de venda
				nValDescIte := Round( aItePed[ni,4] * (aItePed[ni,16] - aItePed[ni,6]) ,TamADVC("HC6_PRCVEN",2))			
			ElseIf aItePed[ni,6] > aItePed[ni,16] //Se o preco de venda for maior que o preco de tabela
				nValAcreIte := Round( aItePed[ni,4] * (aItePed[ni,6] - aItePed[ni,16]) ,TamADVC("HC6_PRCVEN",2))					
			EndIf
			nDescPed += nValDescIte
			nAcrePed += nValAcreIte
        Endif
	Endif
Next

//Saldo de descontos/acrescimos ja aplicados nos itens do pedido
nSaldo := nDescPed - nAcrePed

//Total sem os descontos/Acrescimos
//nSubTotal := nTotPed + nSaldo

//Total de desconto por regra no cabecalho
nDescReg := Round(nDescReg,TamADVC("HC5_DESCON",2))

//Total de desconto por indenizacao
nDescInd := Round(nDescInd,TamADVC("HC5_DESCON",2))

//Total do pedido com desconto de regra e indenizacao
//nTotal := nTotPed - nDescReg - nDescInd
nTotal := nSubTotal - nSaldo - nDescInd
aCabPed[12,1]:= nTotal
If aObj <> Nil
	SetText(aObj, nTotal)
EndIf
//Na consulta nao tera alguns valores para calculo
If lCons
	nTotal := 0
	For ni := 1 To Len(aItePed)
		nTotal += aItePed[ni,9]
	Next
	nSubTotal := nTotal
	nDescReg  := 0
	nDescInd  := 0
	nSaldo    := 0
EndIf

If lNotTouch
	@ 05,02 BROWSE oBrw SIZE 155,63 OF oDlg
	nDistObj := 15
	nPos	 := 78
Else
	@ 20,02 BROWSE oBrw SIZE 155,70 OF oDlg
	nDistObj := 12
	nPos	 := 92
EndIf

SET BROWSE oBrw ARRAY aItePed
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1  HEADER STR0003 WIDTH 50   //"Produto"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2  HEADER STR0004 WIDTH 150  //"Descr."
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4  HEADER STR0005 WIDTH 40   //"Qtde"
If lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 13 HEADER STR0006 WIDTH 40 //"Qtde Ent"
EndIf
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 6  HEADER STR0007 WIDTH 40 PICTURE cPictVal //"Preco"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 7  HEADER STR0008 WIDTH 40 PICTURE cPictDes //"Desconto"
If !lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 8 HEADER STR0009 WIDTH 30 //"Tes"
EndIf
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 9 HEADER STR0010 WIDTH 45 PICTURE cPictVal //"Sub Tot."
If lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 15 HEADER STR0011 WIDTH 80 //"Status"
EndIf

@ nPos,4 SAY STR0012 of oDlg // "Itens: "
@ nPos,32 GET oTxtSIte VAR nQtdIte READONLY SIZE 32,12 of oDlg

@ nPos,70 SAY STR0014 of oDlg //"SubTotal: "
@ nPos,110 GET oTxtSTPed VAR nSubTotal READONLY PICTURE cPictTot SIZE 50,12 of oDlg

nPos += nDistObj
@ nPos,4 SAY STR0016 of oDlg // "R.Desc.: "
@ nPos,38 GET oTxtDPed VAR nDescReg READONLY PICTURE cPictDes SIZE 40,12 of oDlg

If cSfaInd == "T"
	@ nPos,88 SAY STR0013 of oDlg // "Inden.: "
	@ nPos,117 GET oTxtInden VAR nDescInd READONLY PICTURE cPictDes SIZE 40,12 of oDlg
Endif

nPos += nDistObj
@ nPos,4 SAY STR0015 of oDlg // "Desc./Acres.:"
@ nPos,60 GET oTxtDPed VAR nSaldo READONLY PICTURE cPictDes SIZE 50,12 of oDlg

nPos += nDistObj
@ nPos,4 SAY STR0017 of oDlg //"Total: "
@ nPos,35 GET oTxtTPed VAR nTotal READONLY PICTURE cPictTot SIZE 80,12 of oDlg

nPos += nDistObj + 2
if !lCons
	@ nPos,04 BUTTON oBtnConfPed CAPTION STR0018 ACTION PVFecConfT(lConfirmPed) SIZE 65,14 OF oDlg //"Confirmar"
Else
	// Quantidade Entregue != Quantidade Vendida
	For ni := 1 To Len(aItePed) 
		If aItePed[ni ,4] != aItePed[ni,13]
			For nJ := 1 To 8  // Na consulta de Itens são utilizadas 8 Colunas
				GridSetCellColor(oBrw, ni, nJ, CLR_HRED, CLR_WHITE)
			Next
		EndIf
	Next
Endif
@ nPos,85 BUTTON oBtnVltPed CAPTION STR0019 ACTION PVFecConfF(lConfirmPed,aItePed)SIZE 65,14 OF oDlg //"Cancelar"

// Ponto de Entrada ao final da montagem da Tela de Consulta dos Itens dos Ultimos Pedidos
If ExistBlock("SFAPV015")
	ExecBlock("SFAPV015", .F., .F., {aItePed, oBrw, oDlg, oCol, lCons })
EndIf

ACTIVATE DIALOG oDlg

If lNotTouch
	SetFocus(oBtnConfPed)
EndIf

Return Nil

//Confirma a gravacao do pedido
Function PVFecConfT(lConfirmPed)
	lConfirmPed := .T.
	CloseDialog() 
Return Nil

//Cancela a confirmacao do pedido (restaurar itens)
Function PVFecConfF(lConfirmPed, aItePed)
Local nCont:=len(aItePed)

While nCont > 0    
	if aItePed[nCont,11] == 1	//exclui o item de bonificacao
		aDel(aItePed,nCont)      
		aSize(aItePed,len(aItePed)-1)
	Else  
		If !Empty(aItePed[nCont,10])
        	aItePed[nCont,10] := ""
		Endif
		//break
	Endif
	nCont--
Enddo	

//if nCont<len(aItePed)
//	aSize(aItePed,len(aItePed)-1)
//Endif    

lConfirmPed := .F. 
CloseDialog() 
Return Nil
