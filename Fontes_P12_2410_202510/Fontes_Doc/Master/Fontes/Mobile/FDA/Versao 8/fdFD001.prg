#INCLUDE "FDFD001.ch"
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
Local oBox, oPosit, oOcorr, oResumo, aShow := {}, oLbl
Local oCol
aOptions := { STR0001, STR0002,STR0003,STR0004 } //"Clientes positivados"###"Ocorrências de não venda"###"Resumo do dia (Pedidos)"###"Resumo do dia (Notas)"

DEFINE DIALOG oDlg TITLE STR0005  //"Fechamento do Dia"

@ 20,2   LISTBOX oLbx VAR nOpt ITEM aOptions ACTION FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl) SIZE 155,35 OF oDlg
@ 60,2   TO 140,157 oBox CAPTION STR0001 OF oDlg //"Clientes positivados"
@ 65,7   BROWSE oPosit SIZE 145,60 OF oDlg
SET BROWSE oPosit ARRAY aShow           
ADD COLUMN oCol TO oPosit ARRAY ELEMENT 1 HEADER STR0006 WIDTH 100  //"Cliente"
ADD COLUMN oCol TO oPosit ARRAY ELEMENT 2 HEADER STR0007 WIDTH 20 //"Loja"

@ 67,7 BROWSE oOcorr SIZE 145,60 OF oDlg
SET BROWSE oOcorr ARRAY aShow
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 1 HEADER STR0006 WIDTH 100  //"Cliente"
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 2 HEADER STR0007 WIDTH 20 //"Loja"
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 3 HEADER STR0008 WIDTH 80 //"Ocorrência"

@ 67,7 BROWSE oResumo SIZE 145,60 OF oDlg
SET BROWSE oResumo ARRAY aShow
ADD COLUMN oCol TO oResumo ARRAY ELEMENT 1 HEADER STR0009 WIDTH 75  //"Item"
ADD COLUMN oCol TO oResumo ARRAY ELEMENT 2 HEADER STR0010 WIDTH 45 //"Valor"

@ 128,7 SAY oLbl PROMPT STR0011 OF oDlg //"Clientes positivados: "

@ 145,2 BUTTON oBtn CAPTION STR0012 ACTION FDData(oData, @dData,nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,aShow,oLbl) SIZE 29,12 OF oDlg //"Data:"
@ 145,33 GET oData VAR dData READONLY OF oDlg
@ 145,86 BUTTON oBtn CAPTION STR0013 ACTION FDClear(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl) SIZE 31,12 OF oDlg //"Limpar"
@ 145,122 BUTTON oBtnImp CAPTION "i" ACTION ATDIMP(dData) SIZE 15,12 OF oDlg
@ 145,140 BUTTON oBtn CAPTION STR0014 ACTION CloseDialog() SIZE 20,12 OF oDlg //"Sair"

FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)

ACTIVATE DIALOG oDlg

Return nil