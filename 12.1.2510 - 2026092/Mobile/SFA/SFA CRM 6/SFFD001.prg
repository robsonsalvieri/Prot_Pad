#INCLUDE "SFFD001.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FechamentoDia       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inicia o Modulo de Fechamento do Dia     	 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FechamentoDia()
Local oDlg, aOptions, nOpt := 1, oLbx, oData, oBtn, dData := Date()
Local oBox, oPosit, oOcorr, oResumo, aShow := {}, oLbl, oDown
Local oCol
aOptions := { STR0001, STR0002,STR0003 } //"Clientes positivados"###"Ocorrências de não venda"###"Resumo do dia"

DEFINE DIALOG oDlg TITLE STR0004  //"Fechamento do Dia"

@ 20,2 LISTBOX oLbx VAR nOpt ITEM aOptions ACTION FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl) SIZE 155,35 OF oDlg
@ 60,2 TO 140,157 oBox CAPTION STR0001 OF oDlg //"Clientes positivados"

@ 67,7 BROWSE oPosit SIZE 145,60 OF oDlg
SET BROWSE oPosit ARRAY aShow
ADD COLUMN oCol TO oPosit ARRAY ELEMENT 1 HEADER STR0005 WIDTH 100  //"Cliente"
ADD COLUMN oCol TO oPosit ARRAY ELEMENT 2 HEADER STR0006 WIDTH 20 //"Loja"

@ 67,7 BROWSE oOcorr SIZE 145,60 OF oDlg
SET BROWSE oOcorr ARRAY aShow
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 1 HEADER STR0005 WIDTH 100  //"Cliente"
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 2 HEADER STR0006 WIDTH 20 //"Loja"
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 3 HEADER STR0007 WIDTH 80 //"Ocorrência"

@ 67,7 BROWSE oResumo SIZE 145,60 OF oDlg
SET BROWSE oResumo ARRAY aShow
ADD COLUMN oCol TO oResumo ARRAY ELEMENT 1 HEADER STR0008 WIDTH 75  //"Item"
ADD COLUMN oCol TO oResumo ARRAY ELEMENT 2 HEADER STR0009 WIDTH 45 //"Valor"

@ 128,7 SAY oLbl PROMPT STR0010 OF oDlg //"Clientes positivados: "

@ 145,2 BUTTON oBtn CAPTION STR0011 ACTION FDData(oData, @dData,nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,aShow,oLbl) SIZE 35,12 OF oDlg //"Data:"
@ 145,40 GET oData VAR dData READONLY OF oDlg

//@ 145,90 BUTTON oBtn CAPTION STR0012 ACTION FDClear(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl) SIZE 40,12 OF oDlg //"Limpar"
@ 145,132 BUTTON oBtn CAPTION STR0013 ACTION CloseDialog() SIZE 25,12 OF oDlg //"Sair"

@ 129,139 BUTTON oDown CAPTION "D"  SIZE 12,10 ACTION DetPed(GridRow(oPosit), aShow, dData, nOpt) OF oDlg

FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)
GridSetRow(oPosit, 1)

ACTIVATE DIALOG oDlg

Return nil


Function DetPed(nPos, aShow, dData, nOpt)
Local oDlg, oBrw
//Local oBox, oPosit, oOcorr, oResumo, aShow := {}, oLbl
Local oCol, oLbl, oBtn
Local aPedCli := {}
Local cCliente := ""
Local cStatus  := ""

If nOpt != 1 //Se nao estiver na tela de Clientes Positivados, nao exibir os detalhes
	Return nil
EndIf          

If Len(aShow) = 0
	Return .T.
Endif

cCliente := aShow[nPos, 3]
dbSelectArea("HC5")
dbSetOrder(2)
If dbSeek(cCliente)
	HA1->(dbSetOrder(1))
	HA1->(dbSeek(cCliente))
	While !HC5->(Eof()) .And. cCliente = (HC5->C5_CLI + HC5->C5_LOJA)
		If HC5->C5_STATUS = "N"
			If HC5->(IsDirty())
				cStatus := STR0021 //"Não transmitido"
			Else
				cStatus := STR0022 //"Transmitido"
			Endif
			aAdd(aPedCli, {HC5->C5_NUM, HC5->C5_QTDITE, HC5->C5_COND, HC5->C5_VALOR, cStatus})
		EndIf
		HC5->(dbSkip())
	End
EndIf

DEFINE DIALOG oDlg TITLE STR0014  //"Detalhes do Pedido"

@ 20,2 SAY oLbl PROMPT STR0015 + HA1->A1_NOME OF oDlg //"Cliente: "

@ 32,2 BROWSE oBrw SIZE 150,110 OF oDlg
SET BROWSE oBrw ARRAY aPedCli
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0016 WIDTH 40 //"Pedido"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0017 WIDTH 25 PICTURE "@E 999" //"Itens"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0018 WIDTH 40 //"Condição"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER STR0009 WIDTH 50 //"Valor"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 5 HEADER STR0020 WIDTH 50 //"Status"

@ 145,125 BUTTON oBtn CAPTION STR0019 ACTION CloseDialog() SIZE 30,12 OF oDlg //"Voltar"

ACTIVATE DIALOG oDlg

Return nil