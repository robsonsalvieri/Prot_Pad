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
Local oDlg, oGrupo
Local oProd, cDesc := "", cCod := ""
Local cDescD := ""
Local cUN := "", nQTD := 0, nEnt := 0, nDescMax := 0
Local nICM := 0, nIPI := 0, cEst := space(40), nPrc:=0.00 , oBrw, oBox
Local cPesq := Space(40), cPictPr := "", cPictDesc := ""
Local oCtrl, aControls := { {},{},{} }
Local oCod, oDesc, lCodigo := .t., lDesc := .f.
Local aPrecos := {}
Local oCol

MsgStatus(STR0001) //"Aguarde..."
If Len(aGrupo) == 0
	HBM->(dbGoTop())
	While !HBM->(Eof())
	   AADD(aGrupo,HBM->BM_GRUPO + " - " + AllTrim(HBM->BM_DESC))
	   HBM->(dbSkip())
	Enddo                 
Endif    

HB1->(dbSetOrder(3))

ClearStatus()
DEFINE DIALOG oDlg TITLE STR0002  //"Produto"

@ 20,2 SAY STR0003 OF oDlg //"Grupo:"
@ 18,32 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,0,3) SIZE 125,50 OF oDlg
@ 33,2 SAY STR0004 OF oDlg //"Produto:"
@ 33,40 BUTTON oCtrl CAPTION Chr(6) ACTION PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,0,3) SYMBOL OF oDlg
@ 33,56 GET oProd VAR cDesc READONLY NO UNDERLINE SIZE 105,15 OF oDlg
@ 50,2 TO 140,158 oBox CAPTION STR0005 OF oDlg //"Detalhes"
@ 55,5 SAY oCtrl PROMPT STR0006 OF oDlg //"Código:"
AADD(aControls[1],oCtrl)
@ 55,35 GET oCtrl VAR cCod READONLY NO UNDERLINE SIZE 85,15 OF oDlg
AADD(aControls[1],oCtrl)
@ 53,122 BUTTON oCtrl CAPTION STR0007 ACTION PD1Change(aControls,2,oBox) SIZE 30,12 OF oDlg //"Preços"
AADD(aControls[1],oCtrl)
@ 70,5 GET oCtrl VAR cDescD MULTILINE READONLY NO UNDERLINE SIZE 145,25 OF oDlg
AADD(aControls[1],oCtrl)
@ 95,5 SAY oCtrl PROMPT STR0008 OF oDlg  //"Unidade:"
AADD(aControls[1],oCtrl)
@ 95,45 GET oCtrl VAR cUN READONLY NO UNDERLINE SIZE 20,10 OF oDlg
AADD(aControls[1],oCtrl)
@ 95,75 SAY oCtrl PROMPT STR0009 OF oDlg //"Qt.Embal:"
AADD(aControls[1],oCtrl)
@ 95,120 GET oCtrl VAR nQTD READONLY NO UNDERLINE SIZE 35,10 OF oDlg
AADD(aControls[1],oCtrl)
@ 105,5 SAY oCtrl PROMPT STR0010 OF oDlg //"Entrega:"
AADD(aControls[1],oCtrl)
@ 105,45 GET oCtrl VAR nEnt READONLY NO UNDERLINE SIZE 25,10 OF oDlg
AADD(aControls[1],oCtrl)
@ 115,5 SAY oCtrl PROMPT STR0011 OF oDlg  //"ICMS:"
AADD(aControls[1],oCtrl)
@ 115,45 GET oCtrl VAR nICM READONLY NO UNDERLINE SIZE 25,10 OF oDlg
AADD(aControls[1],oCtrl)
@ 115,75 SAY oCtrl PROMPT STR0012 OF oDlg //"IPI:"
AADD(aControls[1],oCtrl)
@ 115,120 GET oCtrl VAR nIPI READONLY NO UNDERLINE SIZE 35,10 OF oDlg
AADD(aControls[1],oCtrl)
@ 125,5 SAY oCtrl PROMPT STR0013 OF oDlg //"Estoque:"
AADD(aControls[1],oCtrl)
@ 125,45 GET oCtrl VAR cEst READONLY NO UNDERLINE SIZE 110,10 OF oDlg
AADD(aControls[1],oCtrl)
//Desc. Max.
@ 105,75 SAY oCtrl PROMPT STR0014 OF oDlg //"Desc.Max:"
AADD(aControls[1],oCtrl)
@ 105,120 GET oCtrl VAR nDescMax READONLY NO UNDERLINE SIZE 35,10 OF oDlg
AADD(aControls[1],oCtrl)

@ 70,5 BROWSE oBrw SIZE 145,65 OF oDlg
SET BROWSE oBrw ARRAY aPrecos
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0015 WIDTH 35 //"Tabela"

cPictPr := SetPicture("HPR", HPR->(FieldPos("PR_UNI")))
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0016 WIDTH 32 PICTURE cPictPr ALIGN RIGHT //"Valor"

cPictDesc := SetPicture("HB1", HPR->(FieldPos("B1_DESCMAX")))
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0014 WIDTH 33 PICTURE cPictDesc ALIGN RIGHT //"Desc. Max."
AADD(aControls[2],oBrw)
@ 53,105 BUTTON oCtrl CAPTION STR0005 ACTION PD1Change(aControls,1,oBox) SIZE 50,12 OF oDlg //"Detalhes"
AADD(aControls[2],oCtrl)
@ 55,05 SAY oCtrl PROMPT STR0017  OF oDlg //"Preço1: "
AADD(aControls[2],oCtrl)
@ 55,45 GET oCtrl VAR nPrc READONLY NO UNDERLINE PICTURE cPictPr OF oDlg
AADD(aControls[2],oCtrl)

PD1ShowHide(aControls,2,.f.)

@ 70,5 GET oCtrl VAR cPesq SIZE 150,15 OF oDlg
AADD(aControls[3],oCtrl)
@ 85,5 CHECKBOX oCod VAR lCodigo CAPTION STR0018 ACTION PD1Order(oCod, oDesc, @lCodigo, @lDesc,.t.) OF oDlg //"Por Código"
AADD(aControls[3],oCod)
@ 97,5 CHECKBOX oDesc VAR lDesc CAPTION STR0019 ACTION PD1Order(oCod, oDesc, @lCodigo, @lDesc ,.f.) OF oDlg //"Por Descrição"
AADD(aControls[3],oDesc)
@ 115,5 BUTTON oCtrl CAPTION STR0020 ACTION PD1Find(cPesq,lCodigo,aGrupo,@nGrupo,@cProduto,aControls,oProd,aPrecos,oBox, aPrdPrefix) OF oDlg //"Buscar"
AADD(aControls[3],oCtrl)
@ 115,50 BUTTON oCtrl CAPTION STR0021 ACTION PD1Change(aControls,1,oBox) OF oDlg //"Retornar"
AADD(aControls[3],oCtrl)

PD1ShowHide(aControls,3,.f.)

@ 144,2 BUTTON oCtrl CAPTION STR0022 ACTION PD1End(@lRet,cProduto) SIZE 50,15 OF oDlg //"Ok"
AADD(aControls[1],oCtrl)
AADD(aControls[2],oCtrl)
@ 144,55  BUTTON oCtrl CAPTION STR0023 ACTION CloseDialog() SIZE 50,15 OF oDlg //"Cancelar"
@ 144,108 BUTTON oCtrl CAPTION STR0024 ACTION PD1Change(aControls,3,oBox) SIZE 50,15 OF oDlg //"Pesquisar"
AADD(aControls[1],oCtrl)
AADD(aControls[2],oCtrl)

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
   If lShow
      ShowControl(aControls[nOpt,i])
   Else
      HideControl(aControls[nOpt,i])
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
elseif nOpt == 2
  SetText(oBox,STR0007) //"Preços"
  PD1ShowHide(aControls,1,.f. )
  PD1ShowHide(aControls,3,.f. )
  PD1ShowHide(aControls,2,.t. )
else
  SetText(oBox,STR0024) //"Pesquisar"
  PD1ShowHide(aControls,1,.f. )
  PD1ShowHide(aControls,2,.f. )
  PD1ShowHide(aControls,3,.t. )
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
Function PD1Order(oCod, oDesc, lCodigo, lDesc,isCod)

if isCod                                     
  SetText(oDesc,.F.)
  lDesc:= .F.
  if !lCodigo
  	SetText(oCod,.T.)
  	lCodigo := .T.
  Endif
else
  SetText(oCod,.F.)
  lCodigo:= .F.
  if !lDesc
  	SetText(oDesc,.T.)
  	lDesc := .T.
  Endif
endif

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD1Browse()         ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta List com Produtos              			   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aGrupo, nGrupo - Array e posicao do grupo, 				  ³±±
±±³			 ³ cProduto - Codigo do Produto, aPrecos - Array dos Precos,  ³±±
±±³			 ³ nOrder - Ordem											  ³±±
±±³			 ³ aControls - Array do Controles							  ³±±
±±³ 		 ³ lShow     - Status de Exibicao  		 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function PD1Browse(aGrupo,nGrupo,cProduto,aControls,oProd,aPrecos,oBox,nSetTop,nOrder)
//Local oDlg, oLbx, aProduto := {} , nProduto := 1, oBtn, oUp, oDown                    
Local oDlg, oLbx, nProduto := 1, oBtn, oUp, oDown,oDesc                    
Local nTop := nSetTop, cGrupo := "", cDesc := ""

If nOrder==3
	cGrupo := Substr(aGrupo[nGrupo],1,4)
Endif

MsgStatus(STR0001) //"Aguarde..."

DEFINE DIALOG oDlg TITLE STR0002  //"Produto"
//@ 20,1 LISTBOX oLbx VAR nProduto ITEM aProduto SIZE 144,25 OF oDlg
@ 20,1 LISTBOX oLbx VAR nProduto ITEM aProduto ACTION PD1Descr(oDesc,cDesc,nProduto) SIZE 144,88 OF oDlg //125
@ 112,1 GET oDesc VAR cDesc MULTILINE READONLY NO UNDERLINE SIZE 155,30 OF oDlg
//@ 144,15 BUTTON oBtn CAPTION "Ok" SIZE 60,15 ACTION PD1Set(aControls,@cProduto,aProduto,nProduto,oProd,aPrecos,oBox,.t.) OF oDlg
@ 144,15 BUTTON oBtn CAPTION STR0022 SIZE 60,15 ACTION PD1Set(aControls,@cProduto,nProduto,cGrupo,oProd,aPrecos,oBox,.t.) OF oDlg //"Ok"
@ 144,80 BUTTON oBtn CAPTION STR0023 SIZE 60,15 ACTION CloseDialog() OF oDlg //"Cancelar"
//@ 19,146 BUTTON oUp CAPTION Chr(5) SYMBOL ACTION PD1Up(@nTop,cGrupo,aProduto,oLbx,nOrder) SIZE 13,10  OF oDlg
@ 19,146 BUTTON oUp CAPTION Chr(5) SYMBOL ACTION PD1Up(@nTop,cGrupo,oLbx,nOrder) SIZE 13,10  OF oDlg
//@ 130,146 BUTTON oDown CAPTION Chr(6) SYMBOL ACTION PD1Down(@nTop,cGrupo,aProduto,oLbx,nOrder) SIZE 13,10 OF oDlg
@ 98,146 BUTTON oDown CAPTION Chr(6) SYMBOL ACTION PD1Down(@nTop,cGrupo,oLbx,nOrder) SIZE 13,10 OF oDlg

//PD1Load(@nTop,cGrupo,aProduto,oLbx)
PD1Load(@nTop,cGrupo,oLbx,.F.)
ClearStatus()

ACTIVATE DIALOG oDlg

Return nil


#define LBL_CODIGO aControls[1,2]
#define LBL_DESC   aControls[1,4]
#define LBL_UM     aControls[1,6]
#define LBL_QTD    aControls[1,8]
#define LBL_ENTR   aControls[1,10]
#define LBL_ICM    aControls[1,12]
#define LBL_IPI    aControls[1,14]
#define LBL_EST    aControls[1,16]
#define LBL_DMAX   aControls[1,18]
#define BROWSE_PRC aControls[2,1]
#define LBL_PRC    aControls[2,4]

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD1Set()            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os Texts com os valores dos campos		   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aControls - Array dos Controles,			 				  ³±±
±±³			 ³ cProduto - Codigo do Produto, aPrecos - Array dos Precos,  ³±±
±±³			 ³ nOrder - Ordem											  ³±±
±±³ 		 ³ aPrecos - Array dos Precos 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
//Function PD1Set(aControls,cProduto,aProduto,nProduto,oProd,aPrecos,oBox,lClose)
Function PD1Set(aControls,cProduto,nProduto,cGrupo,oProd,aPrecos,oBox,lClose)
Local cDesc:="", nDescMax:=0, lexistecpo := .f.
Local cEst := ""

if Len(aProduto)=0
	Return Nil
Endif
cDesc:=aProduto[nProduto]
If Empty(cGrupo)
	HB1->(dbSetOrder(2))
	HB1->(dbSeek(cDesc))
Else
	HB1->(dbSetOrder(3))
	HB1->(dbSeek(cGrupo+cDesc))
Endif
cProduto := HB1->B1_COD

If Select("HB2") != 0
    HB2->(dbSetOrder(1))
    HB2->(dbSeek(cProduto))
    cEst := Str(HB2->HB2_QTD,6,2) + " em " + DtoC(HB2->HB2_DATA)
Else
    cEst := HB1->B1_EST
EndIf

SetText(oProd,AllTrim(HB1->B1_DESC))
SetText(LBL_CODIGO,cProduto)
SetText(LBL_DESC,HB1->B1_DESC)
SetText(LBL_UM,HB1->B1_UM)
SetText(LBL_QTD,HB1->B1_QE)
SetText(LBL_ENTR,HB1->B1_PE)
SetText(LBL_ICM,HB1->B1_PICM)
SetText(LBL_IPI,HB1->B1_IPI)
SetText(LBL_EST,cEst)
SetText(LBL_PRC,HB1->B1_PRV1)

If HB1->(FieldPos("B1_DESCMAX")) != 0 
	nDescMax := HB1->B1_DESCMAX
Else
	nDescMax := 100
Endif
SetText(LBL_DMAX,str(nDescMax,3,2)+"%")

aSize(aPrecos,0)
HPR->(dbSeek(cProduto))
If HPR->(FieldPos("PR_DESMAX")) != 0
	lexistecpo := .t.
Endif
While (!HPR->(Eof()) .and. HPR->PR_PROD == cProduto)
	AADD(aPrecos,{ HPR->PR_TAB, HPR->PR_UNI, If(lexistecpo, HPR->PR_DESMAX, 0) } )
	HPR->(dbSkip())
end

SetArray(BROWSE_PRC,aPrecos)
PD1Change(aControls,1,oBox)
if lClose
   CloseDialog()
endif

Return nil

//Exibe a descricao do produto selecionado no listbox
Function PD1Descr(oDesc,cDesc,nProduto)
cDesc := aProduto[nProduto]
SetText(oDesc,cDesc)
Return nil