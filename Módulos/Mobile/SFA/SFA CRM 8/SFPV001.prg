#INCLUDE "SFPV001.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± < INDICE DAS FUNCOES  > ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±
±± @1.  InitPV -> Modulo principal do Pedido
±± @2.  PVItePed -> Modulo de Item do Pedido
±± @3.  Acoes dos Botoes 
±± @3A. PVQTde -> Chamada do Keyboard para o Campo Qtde.
±± @3B. PVPrc -> Chamada do Keyboard para o Campo Preco.
±± @6A. PVDtEntr -> Data de Entrega ( BUTTON ENTREGA )
±± @6B. PVProduto -> Carrega o Modulo de Produtos( BUTTON PRODUTO )
±± @6C. PVObs -> Carrega o Memo de Observacao ( BUTTON OBS )
±± @6D. PVFecha -> Fecha o Modulo de Pedidos ( BUTTON CANCELAR )
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Pedidos de Venda    ³Autor - Paulo Lima   ³ Data ³27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±³			 ³ InitPedido -> Inicia o Mod. de Pedidos		 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³NOperacao 1- Inclusao /2 - Alteracao / 3 - Ult.Pedido(Cons.)³±±
±±³			 ³4 - Ult.Pedido (Gerar Novo Pedido)   	     		 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "eADVPL.ch"

Function InitPV(aCabPed,aItePed,aCond,aTab,aColIte,lRestaura)

Local oDlg,oCab,oObs,oObj,oBrwItePed,oDet,oPVDesc,oChk1
Local aObj := { Array(4),Array(25),Array(5),Array(1) }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := "", cManDte :=""
Local nItePed:=0
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := "", cSfaFpgIni := ""
Local cFrete := "", cSfaFre := "", aTpFrete := {STR0001, STR0002}, nOpcFre := If(aCabPed[16,1]="C",1,2) //"CIF"###"FOB"
Local aPrdPrefix := {}, cPrdPrefix := "", cPrefix := "", nPreTimes := 0, nPreLen := 0, cPsqGrp := ""
Local nPos := 0
Local oCol   
Local cIndHe4	:= ""
Local cIndHa4 	:= ""
Local cCpBtn  	:= STR0010 // Cancelar
Local lVisual 	:= .F.
Local lChk1	  	:= .F.
Local cSfBlPed	:= ""
Local cFoldDes  := SFGetMv("MV_SFLDDES",.F.,"T")
Local cPictPeso := SetPicture("HB1","HB1_PBRUTO")
Local cPictDes	:= SetPicture("HB1","HC6_DESC")
Local cPictVal	:= SetPicture("HPR","HPR_UNI")
Local cPictTot	:= SetPicture("HC5","HC5_VALOR")
Local lRet	:= .T.

//Variaveis para tratamento de tela com tamanhos variados
Local nSizeobj1 := 10
Local nSizeobj2 := 12
Local nDistobj1 := 14
Local nColPeso	:= 80
Local nLinPeso	:= 118
Local nLinFrt1	:= 0
Local nLinTrp	:= 0
Local nLinFrt2	:= 0
Local nColFrt1	:= 0
Local nColFrt2	:= 0
Local nPosGet 	:= 0
Local nPosBtn 	:= 0
Local nPosSay 	:= 0
Local nSizeGt	:= 0
Local nSizeBrw	:= 82

If lNotTouch
	nSizeobj1	:= 15
	nSizeobj2	:= 15
	nDistobj1	:= 20
	nColPeso	:= 90
	nSizeBrw	:= 76
EndIf

cIndHe4 := SFGetMv("MV_IND2HE4",.F.,"F")
cIndHa4 := SFGetMv("MV_IND2HA4",.F.,"1")

// Configura parametros
SetParam(aCabPed[3,1],aCabPed[4,1], cCliente, cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix, cPsqGrp,,cManDte)

// Consulta Condicao de Pagamento 
Aadd(aCmpPag,{STR0003,HE4->(FieldPos("HE4_CODIGO")),30}) //"Código"
Aadd(aCmpPag,{STR0004,HE4->(FieldPos("HE4_DESCRI")),70}) //"Descrição"
Aadd(aIndPag,{STR0003,1}) //"Código" 
If cIndHe4 == "T"
	Aadd(aIndPag,{STR0004,2}) //"Descrição"
EndIf

//Consulta Tabela de Preco
Aadd(aCmpTab,{STR0003,HTC->(FieldPos("HTC_TAB")),30}) //"Código"
Aadd(aCmpTab,{STR0004,HTC->(FieldPos("HTC_DESCRI")),100}) //"Descrição"
Aadd(aIndTab,{STR0003,1}) //"Código"

//Consulta Transportadora
Aadd(aCmpTra,{STR0003,HA4->(FieldPos("HA4_COD")),40}) //"Código"
If HA4->(FieldPos("HA4_NOME")) <> 0
   Aadd(aCmpTra,{STR0005,HA4->(FieldPos("HA4_NOME")),100}) //"Nome"
EndIf
If HA4->(FieldPos("HA4_CGC")) <> 0
   Aadd(aCmpTra,{STR0039,HA4->(FieldPos("HA4_CGC")),100}) //"CGC/CPF"
EndIf
Aadd(aIndTra,{STR0003,1}) //"Código" 

If cIndHa4 == "2"
	Aadd(aIndTra,{STR0005,2}) //"Nome" 
EndIf
If cIndHa4 == "3"
	Aadd(aIndTra,{STR0005,2}) //"Nome" 
	Aadd(aIndTra,{STR0039,3}) //"CNPJ/CPF" 
EndIf

//Consulta Forma de Pagamento
Aadd(aCmpFpg,{STR0003,HTP->(FieldPos("HTP_CHAVE")),20}) //"Código"
Aadd(aCmpFpg,{STR0006,HTP->(FieldPos("HTP_DESCRI")),60}) //"Descricao"
Aadd(aIndFpg,{STR0003,1}) //"Código"

If aCabPed[2,1] = 1 .Or. aCabPed[2,1] = 4
	DEFINE DIALOG oDlg TITLE STR0007 //"Inclusão do Pedido"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo pedido)
	If aCabPed[2,1] = 1 .And. !lRestaura
		aCabPed[7,1] := cCond
		aCabPed[8,1] := cTabPrc
		aCabPed[13,1]:= cTransp
		aCabPed[15,1]:= cSfaFpgIni
		aCabPed[16,1]:= cFrete
		aCabPed[18,1]:= 0
		aCabPed[19,1]:= 0
		aCabPed[20,1]:= 0
		aCabPed[21,1]:= 0
		nOpcFre      := If(aCabPed[16,1]="C",1,2)
	Endif 
Else
	dbSelectArea("HC5")
	dbSetOrder(1)
	dbSeek(RetFilial("HC5") + aCabPed[1,1])
	
	//Verifica se esta marcado bloqueio de pedido
	lChk1 := !(IsDirty())
		
	If aCabPed[2,1] = 5
		DEFINE DIALOG oDlg TITLE STR0037 //"Visualizacao do Pedido"  
		lVisual := .T.   
	Else
		DEFINE DIALOG oDlg TITLE STR0008 //"Alteração do Pedido"
		aCabPed[10,1] := Date()
	EndIf
EndIf

If lVisual
	cCpBtn := STR0038 // "Retornar"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder Principal    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADD FOLDER oCab CAPTION STR0012 OF oDlg //"Principal"
@ 30,01 TO 130,158 CAPTION STR0012 OF oCab //"Principal"

// Condicao de Pagamento
nPos := 40
@ nPos,42 GET oObj VAR aCabPed[7,1] READONLY SIZE 30,nSizeobj2 of oCab
aObj[2][1] := oObj   // 1 - Get Cond Pag
@ nPos,03 BUTTON oObj CAPTION STR0013 SIZE 34,nSizeobj1 ACTION PVCond(aCabPed,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt) of oCab  //"Pagto:"
aObj[2][2] := oObj   // 2 - Botao Cond Pag

// Tabela de Preco
@ nPos,119 GET oObj VAR aCabPed[8,1] READONLY SIZE 30,nSizeobj2 of oCab
aObj[2][3] := oObj   // 3 - Get Tab Preco
@ nPos,80 BUTTON oObj CAPTION STR0014 SIZE 34,nSizeobj1 ACTION PVTrocaTab(aCabPed,aObj,aCmpTab,aIndTab,aColIte,aItePed,cCondInt,1) of oCab //"Tabela:"
aObj[2][4] := oObj   // 4 - Botao Tab Preco

//Bloqueia tabela de preco
If SFGetMV("MV_SFBLTBP",,"N") == "S"
	DisableControl(aObj[2][4])
EndIf

// Data de Entrega
nPos += nDistobj1
@ nPos,42 GET oObj VAR aCabPed[10,1] READONLY SIZE 50,nSizeobj2 of oCab
aObj[2][5] := oObj   // 5 - Get Data
@ nPos,03 BUTTON oObj CAPTION STR0015 SIZE 34,nSizeobj1 ACTION PVDtEntr(aCabPed[10,1],aObj[2,5]) of oCab //"Entrg.:"
aObj[2][6] := oObj   // 6 Botao Data

If cManDte <> "S"
	DisableControl(aObj[2,6])
EndIf

//Bloqueio de pedido
cSfBlPed := SFGetMv("MV_SFBLPED",.F.,"F")
If cSfBlPed == "T"
	@ nPos,100 CHECKBOX oChk1 VAR lChk1 CAPTION "Bloquear" ACTION BloqPed(@lChk1) SIZE 60,12 OF oCab
	aObj[2][25] := oChk1   // 25 - Check Bloqueio
EndIf

// Transportadora
nPos += nDistobj1
nLinTrp := nPos
@ nPos,42 GET oObj VAR aCabPed[13,1] READONLY SIZE 50,nSizeobj2 of oCab
aObj[2][7] := oObj   // 7 - Get Transp
@ nPos,03 BUTTON oObj CAPTION STR0016 SIZE 34,nSizeobj1 ACTION PVTrocaTra("HA4",aCmpTra,aIndTra,aCabPed,aObj) of oCab //"Transp:"
aObj[2][8] := oObj   // 8 - Botao Transp

// Forma de Pagamento
nPos += nDistobj1
If cSfaFpg = "T"
	@ nPos,42 GET oObj VAR aCabPed[15,1] READONLY SIZE 50,nSizeobj2 of oCab
	aObj[2][9] := oObj   // 9 - Get FPagto
	@ nPos,03 BUTTON oObj CAPTION STR0017 SIZE 34,nSizeobj1 ACTION SFConsPadrao("HTP",aCabPed[15,1],aObj[2,9],aCmpFpg,aIndFpg,) of oCab //"F.Pagto"
	aObj[2][10] := oObj   // 10 - Botao FPagto
EndIf

// Indenizacao
cSfaInd := SFGetMv("MV_SFAIND",.F.,"F")
nPos += nDistobj1
If cSfaInd == "T"
	@ nPos,03 SAY STR0018 OF oCab //"Inden:"
	aObj[2][11] := oObj   // 11 - Say Inden
	@ nPos,42 GET oObj VAR aCabPed[14,1] SIZE 50,nSizeobj2 of oCab // VALID ChkIndeni(aCabPed) 
	aObj[2][12] := oObj   // 12 - Get Inden
EndIf

// Tipo de Frete
If lNotTouch
	nLinFrt1 := nLinTrp
	nLinFrt2 := nLinTrp + 15
	nColFrt1 := 100
	nColFrt2 := 100
Else
	nLinFrt1 := nPos + nDistobj1 + 3
	nLinFrt2 := nPos + nDistobj1 + 3
	nColFrt1 := 03
	nColFrt2 := 30
EndIf
cSfaFre := SFGetMv("MV_SFAFRE",.F.,"F")
If cSfaFre == "T"
	@ nLinFrt1,nColFrt1 SAY STR0019 OF oCab //"Frete:"
	aObj[2][13] := oObj   // 13 - Say Frete
	@ nLinFrt2,nColFrt2 COMBOBOX oObj VAR nOpcFre ITEMS aTpFrete ACTION UpdTpFrete(aCabPed, aTpFrete, nOpcFre) of oCab
	aObj[2][14] := oObj   // 14 - Combo Frete
EndIf


If !lNotTouch
	nLinPeso := nLinFrt1
EndIf
//Peso do Pedido
If 	cSfaPeso == "T"
	@ nLinPeso,nColPeso SAY STR0020 OF oCab //"Peso:"
	aObj[2][15] := oObj // 15 - Label Peso
	@ nLinPeso,110 GET oObj VAR aCabPed[17,1] PICTURE cPictPeso READONLY SIZE 49,nSizeobj2 of oCab
	aObj[2][16] := oObj // 16 - Get Peso
EndIf

If ExistBlock("SFAPV002")
	ExecBlock("SFAPV002", .F., .F., {oCab, aCabPed, oObj, oDlg})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder Descontos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFoldDes == "T"
	ADD FOLDER oPVDesc CAPTION STR0036 OF oDlg // Folder de Informacoes de descontos do pedido de venda #### "Descontos"
	@ 30,01 TO 127,158 CAPTION STR0036 OF oPVDesc //"Descontos"
	
	@ 50,44 GET oObj VAR aCabPed[18,1] PICTURE cPictDes VALID VldDesc(aCabPed[18,1]) SIZE 30,nSizeobj2 of oPVDesc //42
	aObj[2][17] := oObj // 17 - Desconto 1
	@ 50,03 BUTTON oObj CAPTION STR0032 SIZE 34,nSizeobj1 ACTION PVQTde(aObj[2,17]) of oPVDesc
	aObj[2][18] := oObj // 18 - Botao Desconto 1
	
	@ 50,121 GET oObj VAR aCabPed[19,1] PICTURE cPictDes  VALID VldDesc(aCabPed[19,1]) SIZE 30,nSizeobj2 of oPVDesc
	aObj[2][19] := oObj // 19 - Desconto 2
	@ 50,80 BUTTON oObj CAPTION STR0033 SIZE 34,nSizeobj1 ACTION PVQTde(aObj[2,19]) of oPVDesc
	aObj[2][20] := oObj // 20 - Botao Desconto 2
	
	@ 75,44 GET oObj VAR aCabPed[20,1] PICTURE cPictDes  VALID VldDesc(aCabPed[20,1]) SIZE 30,nSizeobj2 of oPVDesc
	aObj[2][21] := oObj // 21 - Desconto 3
	@ 75,03 BUTTON oObj CAPTION STR0034 SIZE 34,nSizeobj1 ACTION PVQTde(aObj[2,21]) of oPVDesc  
	aObj[2][22] := oObj // 22 - Boato Desconto 3
	
	@ 75,121 GET oObj VAR aCabPed[21,1] PICTURE cPictDes  VALID VldDesc(aCabPed[21,1]) SIZE 30,nSizeobj2 of oPVDesc
	aObj[2][23] := oObj // 23 - Desconto 4
	@ 75,80 BUTTON oObj CAPTION STR0035 SIZE 34,nSizeobj1 ACTION PVQTde(aObj[2,23]) of oPVDesc 
	aObj[2][24] := oObj // 24 Botao Desconto 4
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder Detalhe      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADD FOLDER oDet CAPTION STR0021 OF oDlg //"Detalhe"
@ 30,01 TO 127,158 CAPTION STR0021 OF oDet //"Detalhe"

@ 40,03 BROWSE oBrwItePed SIZE 134,nSizeBrw of oDet
SET BROWSE oBrwItePed ARRAY aItePed
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 1 HEADER STR0022 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 2 HEADER STR0023 WIDTH 130  //Acresc. 11/06/03 //"Descr."
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 4 HEADER STR0024 WIDTH 35 //"Qtde"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 6 HEADER STR0025 WIDTH 40 PICTURE cPictVal //"Preco"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 7 HEADER STR0026 WIDTH 40 PICTURE cPictDes //"Desc."
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 9 HEADER STR0027 WIDTH 50 PICTURE cPictVal //"Sub Tot."
aObj[3][1] := oBrwItePed // 1 - Browse de Itens


// Este Ponto de Entrada servirah para que passamos criar novos botoes na area de inclusao, alteracao,exclusao e visualizacao de itens dos pedidos de venda
// No mesmo devemos criar os novos botoes ou nao (podendo o desenvolvedor efetuar condicoes antes de montar os novos) e
// entao retornar .F. caso tenha criado os novos botoes e assim abaixo o padrao NAO criarah os seus.

If ExistBlock("SFAPV016")

	lRet := ExecBlock("SFAPV016", .F., .F., {aItePed, @nItePed, aColIte, aCabPed, aObj, cManTes, cManPrc, cBloqPrc, cProDupl, aPrdPrefix, lVisual, oDet, oObj})

EndIf

If lRet

	If lVisual == .T.
		@ 42,140 BUTTON oObj CAPTION "D" SIZE 16,nSizeobj2 ACTION PVDetIte(aItePed,aObj,cManTes) of oDet
		aObj[3][5] := oObj // 5 - Botao D
	Else
		@ 42,140 BUTTON oObj CAPTION "N" SIZE 16,nSizeobj2 ACTION PVItePed(1,aItePed, @nItePed, aColIte, aCabPed,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix) of oDet
		aObj[3][2] := oObj // 2 - Botao N
		@ 62,140 BUTTON oObj CAPTION STR0028 SIZE 16,nSizeobj2 ACTION PVItePed(2,aItePed, @nItePed, aColIte, aCabPed,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix) of oDet //"A"
		aObj[3][3] := oObj // 3 - Botao A
		@ 82,140 BUTTON oObj CAPTION STR0029 SIZE 16,nSizeobj2 ACTION PVExcIte(aItePed,@nItePed, aCabPed,aObj, .F.,1) of oDet //"E"
		aObj[3][4] := oObj // 4 - Botao E
		@ 102,140 BUTTON oObj CAPTION "D" SIZE 16,nSizeobj2 ACTION PVDetIte(aItePed,aObj,cManTes) of oDet
		aObj[3][5] := oObj // 5 - Botao D
	EndIf

EndIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder Obs.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADD FOLDER oObs CAPTION STR0030 OF oDlg //"Obs"
@ 30,01 TO 127,158 CAPTION STR0031 OF oObs //"Observação"
@ 40,05 GET oObj VAR aCabPed[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
aObj[4][1] := oObj // 1 - Get Observacao

If lNotTouch
	nPosGet := 04
	nPosBtn := 140
	nPosSay := 140
	nSizeGt := 20
Else
	nPosGet := 15
	nPosBtn := 134
	nPosSay := 136
	nSizeGt := 15
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos comuns a todos os folders.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nPosGet,05 GET oObj VAR cCliente SIZE 157,nSizeGt READONLY MULTILINE OF oDlg
aObj[1][1] := oObj // 1 - Get Cliente
@ nPosBtn,71 BUTTON oObj CAPTION STR0009  ACTION PVGravarPed(aCabPed,aItePed,aColIte,cCondInt,cSfaInd,cSfaFpg,lChk1,aObj[1][4])SIZE 40,nSizeobj2 OF oDlg //"Gravar"

aObj[1][2] := oObj // 2 - Botao de gravar
@ nPosBtn,116 BUTTON oObj CAPTION cCpBtn ACTION PVFecha(aCabPed[2,1],aCabPed) SIZE 40,nSizeobj2 OF oDlg //"Cancelar"
aObj[1][3] := oObj // 3 - Botao de Cancelar
@ nPosSay,2 SAY STR0011  of oDlg //"T:"
@ nPosSay,12 GET oObj VAR aCabPed[12,1] PICTURE cPictTot READONLY SIZE 52,nSizeobj2 of oDlg
aObj[1][4] := oObj // 4 - Get Total

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desabilita objetos na visualizacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisual == .T. 
	HideControl(aObj[1][2])
	DisableControl(aObj[2][2])
	DisableControl(aObj[2][4])
	DisableControl(aObj[2][6])
	DisableControl(aObj[2][8])
		
 	IIf (cSfaFpg == "T" ,DisableControl(aObj[2][10]),0)
 	IIf (cSfaInd == "T" ,DisableControl(aObj[2][12]),0)
 	IIf (cSfaFre == "T" ,DisableControl(aObj[2][14]),0)
 	IIf (cSfBlPed == "T" ,DisableControl(oChk1),0)
 	
	If cFoldDes == "T"
	 	DisableControl(aObj[2][17])
	 	DisableControl(aObj[2][18])
	 	DisableControl(aObj[2][19])
	 	DisableControl(aObj[2][20])
	 	DisableControl(aObj[2][21])
	 	DisableControl(aObj[2][22])
	 	DisableControl(aObj[2][23])
	 	DisableControl(aObj[2][24])
	EndIf
 	DisableControl(aObj[4][1])
	
Endif

// Ponto de Entrada no Final da monstagem da DIALOG do Pedido de Vendas
If ExistBlock("SFAPV007")
	ExecBlock("SFAPV007", .F., .F., {oCab, aCabPed, aObj, aItePed})
EndIf

ACTIVATE DIALOG oDlg

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BloqPed   ³Autor  ³Liber De Esteban    ³ Data ³  26/09/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Aplica bloqueio no pedido                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lChk1 -> Flag que indica se o pedido sera bloqueado         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SFA                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function BloqPed(lChk1)

If lChk1
	MsgAlert("O Pedido nao sera sincronizado","Atenção")
Else
	MsgAlert("Pedido Liberado!","Atenção")
EndIf

Return Nil

Function VldDesc(nDesconto)
lRet:=.F.
If nDesconto < 100 .AND. nDesconto >=0
	lRet:=.T.
EndIf

Return lRet
