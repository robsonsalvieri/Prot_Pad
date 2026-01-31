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
Local oBox, oPosit, oOcorr, oResumo, aShow := {}, oLbl, oDown, oBtnData
Local oCol
Local nPosIni := Iif(lNotTouch,10,18)
Local cPictVal	:= SetPicture("HPR","HPR_UNI")

aOptions := { STR0001, STR0002,STR0003 } //"Clientes positivados"###"Ocorrências de não venda"###"Resumo do dia"

DEFINE DIALOG oDlg TITLE STR0004  //"Fechamento do Dia"

@ nPosIni,2 COMBOBOX oLbx VAR nOpt ITEMS aOptions ACTION FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl) SIZE 155,35 OF oDlg
@ 40,2 TO 130,157 oBox CAPTION STR0001 OF oDlg //"Clientes positivados"

@ 52,7 BROWSE oPosit SIZE 145,56 OF oDlg
SET BROWSE oPosit ARRAY aShow
ADD COLUMN oCol TO oPosit ARRAY ELEMENT 1 HEADER STR0005 WIDTH 100  //"Cliente"
ADD COLUMN oCol TO oPosit ARRAY ELEMENT 2 HEADER STR0006 WIDTH 20 //"Loja"

@ 52,7 BROWSE oOcorr SIZE 145,56 OF oDlg
SET BROWSE oOcorr ARRAY aShow
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 1 HEADER STR0005 WIDTH 100  //"Cliente"
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 2 HEADER STR0006 WIDTH 20 //"Loja"
ADD COLUMN oCol TO oOcorr ARRAY ELEMENT 3 HEADER STR0007 WIDTH 80 //"Ocorrência"

@ 52,7 BROWSE oResumo SIZE 145,56 OF oDlg
SET BROWSE oResumo ARRAY aShow
ADD COLUMN oCol TO oResumo ARRAY ELEMENT 1 HEADER STR0008 WIDTH 75  //"Item"
ADD COLUMN oCol TO oResumo ARRAY ELEMENT 2 HEADER STR0009 WIDTH 45 PICTURE cPictVal //"Valor"

@ 115,7 SAY oLbl PROMPT STR0010 OF oDlg //"Clientes positivados: "

@ 115,139 BUTTON oDown CAPTION "D"  SIZE 12,10 ACTION DetPed(GridRow(oPosit), aShow, dData, nOpt) OF oDlg

@ 135,2 BUTTON oBtnData CAPTION STR0011 ACTION FDData(oData, @dData,nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,aShow,oLbl) SIZE 35,12 OF oDlg //"Data:"
@ 135,40 GET oData VAR dData READONLY OF oDlg

If SFGetMv("MV_SFBLOQH",.F.,"N") = "S" // Desabilita a consulta ao historico de fechamento do dia
	DisableControl(oBtnData)
EndIf

//@ 145,90 BUTTON oBtn CAPTION STR0012 ACTION FDClear(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl) SIZE 40,12 OF oDlg //"Limpar"
@ 135,132 BUTTON oBtn CAPTION STR0013 ACTION CloseDialog() SIZE 25,12 OF oDlg //"Sair"

FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)
GridSetRow(oPosit, 1)

ACTIVATE DIALOG oDlg

Return nil


Function DetPed(nPos, aShow, dData, nOpt)

Local oDlg, oBrw
//Local oBox, oPosit, oOcorr, oResumo, aShow := {}, oLbl
Local oCol, oLbl, oBtn
Local aPedCli	:= {}
Local cCliente	:= ""
Local cStatus	:= ""
Local cPictVal	:= SetPicture("HPR","HPR_UNI")
//Variaveis para controle de tela
Local nLinIni	:= 0
Local nColBrw	:= 0
Local nLinBrw	:= 0
Local nPosBtn	:= 0

If nOpt != 1 //Se nao estiver na tela de Clientes Positivados, nao exibir os detalhes
	Return nil
EndIf          

If Len(aShow) = 0
	Return .T.
Endif

cCliente := aShow[nPos, 3]
dbSelectArea("HC5")
dbSetOrder(2)
If dbSeek(RetFilial("HC5") + cCliente)
	HA1->(dbSetOrder(1))
	HA1->(dbSeek(RetFilial("HA1") + cCliente))
	While !HC5->(Eof()) .And. cCliente = (HC5->HC5_CLI + HC5->HC5_LOJA)
		If Alltrim(HC5->HC5_STATUS) $ "N/BS"
			If HC5->(IsDirty())
				cStatus := STR0021 //"Não transmitido"
			Else
				cStatus	:= LoadStatus(HC5->HC5_STATUS)
			Endif
			aAdd(aPedCli, {HC5->HC5_NUM, HC5->HC5_QTDITE, HC5->HC5_COND, HC5->HC5_VALOR, cStatus})
		EndIf
		HC5->(dbSkip())
	End
EndIf

If lNotTouch
	nLinIni := 10
	nColBrw := 90
	nLinBrw := 150
	nPosBtn := 130
Else
	nLinIni := 20
	nColBrw := 110
	nLinBrw := 150
	nPosBtn := 145
EndIf

DEFINE DIALOG oDlg TITLE STR0014  //"Detalhes do Pedido"

@ nLinIni,2 SAY oLbl PROMPT STR0015 + HA1->HA1_NOME OF oDlg //"Cliente: "

@ 32,2 BROWSE oBrw SIZE nLinBrw,nColBrw OF oDlg
SET BROWSE oBrw ARRAY aPedCli
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0016 WIDTH 40 //"Pedido"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0017 WIDTH 25 PICTURE "@E 999" //"Itens"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0018 WIDTH 40 //"Condição"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER STR0009 WIDTH 50 PICTURE cPictVal //"Valor"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 5 HEADER STR0020 WIDTH 50 //"Status"

@ nPosBtn,125 BUTTON oBtn CAPTION STR0019 ACTION CloseDialog() SIZE 30,12 OF oDlg //"Voltar"

ACTIVATE DIALOG oDlg

Return nil
