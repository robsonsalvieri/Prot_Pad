#INCLUDE "SFPD001.ch"
#include "eADVPL.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GetPD1()            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tela de Consulta de Produtos                 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Codigo do Produto								  ³±±
±±³ 		 ³ lRet     - Retorno da Funcao   		 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GetPD1(cProduto,lRet, aPrdPrefix)

Local oDlg
Local oProd, cDesc := "", cCod := ""
Local cDescD := ""
Local cUN := "", nQTD := 0, nEnt := 0, nDescMax := 0
Local nICM := 0, nIPI := 0, cEst := space(40), nPrc:=0.00 , oBrw, oBox
Local cPesq := Space(40)
Local oCtrl, aControls := Array(3,21)
Local oCod, oDesc, lCodigo := .t., lDesc := .f.
Local aPrecos := {}
Local oCol
Local oCod_Forn
Local oDesc_Forn
Local lCod_Forn	:=	.F.
Local lDesc_Forn	:=	.F.
Local nOrder := 1
Local cPesqFabr	:=	""
Local cPictVal	:= SetPicture("HPR","HPR_UNI")
Local cPictDes	:= SetPicture("HB1","HC6_DESC")
//Variaveis de controle de posicionamento na tela
Local nLinha
Local nLPesq
Local nLinMa
Local nLinBtn
Local nSizBrw

Private oGrupo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_SFACPRF   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

MsgStatus(STR0001) //"Aguarde..."
If Len(aGrupo) == 0
	LoadGrupos(aGrupo)
	/*
	HBM->(dbGoTop())
	While !HBM->(Eof())
	   AADD(aGrupo,HBM->HBM_GRUPO + "-" + AllTrim(HBM->HBM_DESC))
	   HBM->(dbSkip())
	Enddo*/
Endif    

HB1->(dbSetOrder(3))

ClearStatus()

DEFINE DIALOG oDlg TITLE STR0002  //"Produto"

If lNotTouch
	@ 05,2 SAY STR0003 OF oDlg //"Grupo:"
	@ 02,38 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,0,4) OF oDlg
	//oGrupo???
	@ 25,2 SAY STR0004 OF oDlg //"Produto:"
	@ 25,30 BUTTON oCtrl CAPTION Chr(6) ACTION PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,0,4) SYMBOL OF oDlg
	@ 25,56 GET oProd VAR cDesc READONLY NO UNDERLINE SIZE 105,15 OF oDlg
	@ 45,2 TO 135,155 oBox CAPTION STR0005 OF oDlg //"Detalhes"
	@ 55,5 SAY oCtrl PROMPT STR0006 OF oDlg //"Código:"
	aControls[1][1] := oCtrl // 1 - Say Codigo
	@ 55,35 GET oCtrl VAR cCod READONLY NO UNDERLINE SIZE 85,15 OF oDlg
	aControls[1][2] := oCtrl //  2 - Get Cod
	nLinha  := 70
	nLPesq  := 60
	nLinMa  := 15
	nLinBtn := 138
	nSizBrw := 60
Else
	@ 20,2 SAY STR0003 OF oDlg //"Grupo:"
	@ 18,32 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,0,4) SIZE 125,50 OF oDlg
	@ 33,2 SAY STR0004 OF oDlg //"Produto:"
	@ 33,40 BUTTON oCtrl CAPTION Chr(6) ACTION PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,0,4) SYMBOL OF oDlg
	@ 33,56 GET oProd VAR cDesc READONLY NO UNDERLINE SIZE 105,15 OF oDlg
	@ 50,2 TO 140,158 oBox CAPTION STR0005 OF oDlg //"Detalhes"
	@ 55,5 SAY oCtrl PROMPT STR0006 OF oDlg //"Código:"
	aControls[1][1] := oCtrl // 1 - Say Codigo
	@ 55,35 GET oCtrl VAR cCod READONLY NO UNDERLINE SIZE 85,15 OF oDlg
	aControls[1][2] := oCtrl //  2 - Get Cod
	nLinha  := 95
	nLPesq  := 70
	nLinMa  := 10
	nLinBtn := 144
	nSizBrw := 65
EndIf

@ 53,122 BUTTON oCtrl CAPTION STR0007 ACTION PD1Change(aControls,2,oBox) SIZE 30,12 OF oDlg //"Preços"
aControls[1][3] := oCtrl //  3 - Botão Preço

If !lNotTouch
	@ 70,5 GET oCtrl VAR cDescD MULTILINE READONLY NO UNDERLINE SIZE 145,25 OF oDlg
	aControls[1][4] := oCtrl  // 4 - Get Desc
EndIf

@ nLinha,5 SAY oCtrl PROMPT STR0008 OF oDlg  //"Unidade:"
aControls[1][5] := oCtrl
@ nLinha,45 GET oCtrl VAR cUN READONLY NO UNDERLINE SIZE 20,10 OF oDlg
aControls[1][6] := oCtrl
@ nLinha,75 SAY oCtrl PROMPT STR0009 OF oDlg //"Qt.Embal:"
aControls[1][7] := oCtrl
@ nLinha,120 GET oCtrl VAR nQTD READONLY NO UNDERLINE SIZE 35,10 OF oDlg
aControls[1][8] := oCtrl

nLinha += nLinMa
@ nLinha,5 SAY oCtrl PROMPT STR0010 OF oDlg //"Entrega:"
aControls[1][9] := oCtrl
@ nLinha,45 GET oCtrl VAR nEnt READONLY NO UNDERLINE SIZE 25,10 OF oDlg
aControls[1][10] := oCtrl

//Desc. Max.
@ nLinha,75 SAY oCtrl PROMPT STR0014 OF oDlg //"Desc.Max:"
aControls[1][11] := oCtrl
@ nLinha,117 GET oCtrl VAR nDescMax READONLY NO UNDERLINE SIZE 40,10 OF oDlg
aControls[1][12] := oCtrl

nLinha += nLinMa
@ nLinha,5 SAY oCtrl PROMPT STR0011 OF oDlg  //"ICMS:"
aControls[1][13] := oCtrl
@ nLinha,45 GET oCtrl VAR nICM READONLY NO UNDERLINE SIZE 25,10 OF oDlg
aControls[1][14] := oCtrl

@ nLinha,75 SAY oCtrl PROMPT STR0012 OF oDlg //"IPI:"
aControls[1][15] := oCtrl
@ nLinha,120 GET oCtrl VAR nIPI READONLY NO UNDERLINE SIZE 35,10 OF oDlg
aControls[1][16] := oCtrl

nLinha += nLinMa
@ nLinha,5 SAY oCtrl PROMPT STR0013 OF oDlg //"Estoque:"
aControls[1][17] := oCtrl
@ nLinha,45 GET oCtrl VAR cEst READONLY NO UNDERLINE SIZE 110,10 OF oDlg
aControls[1][18] := oCtrl

@ 53,105 BUTTON oCtrl CAPTION STR0005 ACTION PD1Change(aControls,1,oBox) SIZE 45,12 OF oDlg //"Detalhes"
aControls[2][1] := oCtrl

@ 70,5 BROWSE oBrw SIZE 145,nSizBrw OF oDlg
SET BROWSE oBrw ARRAY aPrecos
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0015 WIDTH 35 //"Tabela"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0016 WIDTH 32 PICTURE cPictVal ALIGN RIGHT //"Valor"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0014 WIDTH 33 PICTURE cPictDes ALIGN RIGHT //"Desc. Max."
aControls[2][2] := oBrw

@ 55,05 SAY oCtrl PROMPT STR0017 OF oDlg //"Preço1: "
aControls[2][3] := oCtrl
@ 55,45 SAY oCtrl PROMPT nPrc OF oDlg
aControls[2][4] := oCtrl

PD1ShowHide(aControls,2,.f.)

@ nLPesq,5 GET oCtrl VAR cPesq SIZE 150,15 OF oDlg
aControls[3][1] := oCtrl

nLPesq += 15
@ nLPesq,5 CHECKBOX oCod VAR lCodigo CAPTION STR0018 ACTION PD1Order(oCod, oDesc, oCod_Forn, oDesc_Forn, @lCodigo, @lDesc, @lCod_Forn, @lDesc_Forn,1,@nOrder) OF oDlg //"Por Código"
aControls[3][2] := oCod

nLPesq += Iif(lNotTouch,20,15)
@ nLPesq,5 CHECKBOX oDesc VAR lDesc CAPTION STR0019 ACTION PD1Order(oCod, oDesc, oCod_Forn, oDesc_Forn, @lCodigo, @lDesc, @lCod_Forn, @lDesc_Forn,2,@nOrder) OF oDlg //"Por Descrição"
aControls[3][3] := oDesc

If cPesqFabr == "S"
	If Select("HA5")>0
		@ nLPesq,80 CHECKBOX oCod_Forn VAR lCod_Forn CAPTION STR0027 ACTION PD1Order(oCod, oDesc, oCod_Forn, oDesc_Forn, @lCodigo, @lDesc, @lCod_Forn, @lDesc_Forn,3,@nOrder) OF oDlg //"Por Cód. Fabr."
		aControls[3][4] := oCod_Forn
	Else
		MsgAlert(STR0028+Chr(13)+Chr(10)+STR0029,STR0030)//"Não será possível a consulta por Cód. do Fabr."####"Tabela HA5 - Forn x Prod não existe!"/###"Atenção!"
	EndIf
EndIf

nLPesq += Iif(lNotTouch,20,15)
@ nLPesq,25 BUTTON oCtrl CAPTION STR0020 ACTION PD1Find(cPesq,nOrder,aGrupo,@nGrupo,@cProduto,aControls,oProd,aPrecos,oBox, aPrdPrefix) OF oDlg //"Buscar"
aControls[3][5] := oCtrl
@ nLPesq,80 BUTTON oCtrl CAPTION STR0021 ACTION PD1Change(aControls,1,oBox) OF oDlg //"Retornar"
aControls[3][6] := oCtrl

PD1ShowHide(aControls,3,.f.)

@ nLinBtn,2   BUTTON oCtrl CAPTION STR0022 ACTION PD1End(@lRet,cProduto) SIZE 50,15 OF oDlg //"Ok"
aControls[1][19] := oCtrl
aControls[2][5]  := oCtrl
@ nLinBtn,55  BUTTON oCtrl CAPTION STR0023 ACTION CloseDialog() SIZE 50,15 OF oDlg //"Cancelar"
@ nLinBtn,108 BUTTON oCtrl CAPTION STR0024 ACTION PD1Change(aControls,3,oBox) SIZE 50,15 OF oDlg //"Pesquisar"
aControls[1][20] := oCtrl
aControls[2][6]  := oCtrl

ACTIVATE DIALOG oDlg

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD1ShowHide()       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controla a exibição dos Controles na Tela    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aControls - Array do Controles							  ³±±
±±³ 		 ³ lShow     - Status de Exibicao  		 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD1ShowHide(aControls, nOpt,lShow )
Local i

For i := 1 to Len(aControls[nOpt])
	If !Empty(aControls[nOpt,i])
		If lShow
			ShowControl(aControls[nOpt,i])
		Else
			HideControl(aControls[nOpt,i])
		EndIf
	EndIf
Next
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD1Change()         ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualizacao dos Controles, conforme navegacao   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aControls - Array do Controles							  ³±±
±±³ 		 ³ lShow     - Status de Exibicao  		 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD1Change(aControls,nOpt,oBox)

if nOpt == 1
  SetText(oBox,STR0005) //"Detalhes"
  PD1ShowHide(aControls,2,.f. )
  PD1ShowHide(aControls,3,.f. )
  PD1ShowHide(aControls,1,.t. )
  SetFocus(oGrupo)
elseif nOpt == 2
  SetText(oBox,STR0007) //"Preços"
  PD1ShowHide(aControls,1,.f. )
  PD1ShowHide(aControls,3,.f. )
  PD1ShowHide(aControls,2,.t. )
  SetFocus(oGrupo)
else
  SetText(oBox,STR0024) //"Pesquisar"
  PD1ShowHide(aControls,1,.f. )
  PD1ShowHide(aControls,2,.f. )
  PD1ShowHide(aControls,3,.t. )
  SetFocus(oGrupo)
endif

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD1Order()          ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define texto, conforme ordem de busca			   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD1Order(oCod, oDesc, oCod_Forn, oDesc_Forn, lCodigo, lDesc, lCod_Forn, lDesc_Forn, nVal_Ord, nOrder)
Local cPesqFabr	:=	""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_SFACPRF   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

nOrder := nVal_Ord
If nOrder == 1                                     
  SetText(oDesc,.F.)
  If cPesqFabr == "S" .And. (Select("HA5")>0)
  	SetText(oCod_Forn,.F.)
  EndIf
  lDesc		:=	.F.
  lDesc_Forn:=	.F.
  lCod_Forn	:=	.F.
  If !lCodigo
  	SetText(oCod,.T.)
  	lCodigo := .T.
  Endif
ElseIf nOrder == 2
  SetText(oCod,.F.)
  If cPesqFabr == "S" .And. (Select("HA5")>0)
	  SetText(oCod_Forn,.F.)
  EndIf
  lCodigo	:=	.F.
  lDesc_Forn:=	.F.
  lCod_Forn	:=	.F.
  If !lDesc
  	SetText(oDesc,.T.)
  	lDesc := .T.
  Endif
Else 
	If cPesqFabr == "S" .And. (Select("HA5")>0)
		SetText(oCod,.F.)
		SetText(oDesc,.F.)
		lCodigo	:=	.F.
		lDesc		:=	.F.
		lDesc_Forn:=	.F.
		If !lCod_Forn
			SetText(oCod_Forn,.T.)
			lCod_Forn := .T.
		Endif
	EndIf
Endif

Return nil

