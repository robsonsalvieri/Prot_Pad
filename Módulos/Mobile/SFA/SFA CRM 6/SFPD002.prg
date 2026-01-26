#INCLUDE "SFPD002.ch"
#include "eADVPL.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GetPD2()            ³Autor: Paulo Amaral  ³ Data ³         ³±±
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
Function GetPD2(cProduto,lRet, aPrdPrefix)
Local oDlg, oProd, oDet, oPrc
Local oPesq
Local oBrwProd, oCbxOrder, oBrwPrc, oBrwDet
Local oBtnCanc, oBtnRet, oBtnBusc, oBtnSobe, oBtnDesce, oBtnDir, oBtnEsq
Local cDesc := "", cCod := "", cGrupo:="", cPesq:=Space(40)
Local lCod:=.F. , lDesc := .T.
Local nOrder:=2,  nTop:=0                        
Local aOrder := {}, aProduto := {}, aPrecos  := {}, aDetalhe := {}
Local oCol
AADD(aOrder,STR0001) //"Por Código"
AADD(aOrder,STR0002) //"Por Descrição"

nTop := nLastProd

DEFINE DIALOG oDlg TITLE STR0003  //"Produto"

@ 125,2 BUTTON oBtnCanc CAPTION STR0004 ACTION CloseDialog() SIZE 70,15 of oDlg //"Cancelar"
@ 125,77 BUTTON oBtnRet CAPTION STR0005 ACTION PD2End(lRet,cProduto)  SIZE 70,15 of oDlg //"Retornar"
@ 0,80 COMBOBOX oCbxOrder VAR nOrder ITEMS aOrder ACTION PD2Order(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet) of oDlg
ADD FOLDER oProd CAPTION STR0006 OF oDlg //"Produtos"

@ 18,1 TO 120,157 CAPTION STR0006 OF oProd //"Produtos"

@ 25,3 GET oPesq VAR cPesq SIZE 152,15 OF oProd
@ 40,3 BUTTON oBtnBusc CAPTION STR0007 ACTION PD2Find(@cProduto,@nTop,cPesq,aProduto, oBrwProd, @nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet, aPrdPrefix) SIZE 35,12 OF oProd //"Buscar"

@ 54,142 BUTTON oBtnSobe CAPTION UP_ARROW SYMBOL ACTION PD2Up(@cProduto,@nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet) SIZE 13,10 OF oProd
@ 66,142 BUTTON oBtnDir CAPTION RIGHT_ARROW SYMBOL ACTION GridRight(oBrwProd) SIZE 13,10 OF oProd
@ 78,142 BUTTON oBtnEsq CAPTION LEFT_ARROW SYMBOL ACTION GridLeft(oBrwProd) SIZE 13,10 OF oProd
@ 90,142 BUTTON oBtnDesce CAPTION DOWN_ARROW SYMBOL ACTION PD2Down(@cProduto,@nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet) SIZE 13,10 OF oProd
//@ 54,3 LISTBOX oLbxProd VAR nProduto ITEMS aProduto ACTION PD2Set(@cProduto,aProduto[nProduto],aPrecos, oBrwPrc,aDetalhe, oBrwDet) SIZE 137,72 OF oProd
@ 54,3 BROWSE oBrwProd SIZE 137,60 NO SCROLL ACTION PD2Set(@cProduto,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet) OF oProd
SET BROWSE oBrwProd ARRAY aProduto
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0008 WIDTH 125 //"Descrição"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0009 WIDTH 50 //"Código"


ADD FOLDER oDet CAPTION STR0010 OF oDlg //"Detalhe"
@ 18,1 TO 120,157 CAPTION STR0010 OF oDet //"Detalhe"

@ 30,3 BROWSE oBrwDet SIZE 152,85 OF oDet
SET BROWSE oBrwDet ARRAY aDetalhe
ADD COLUMN oCol TO oBrwDet ARRAY ELEMENT 1 HEADER "" WIDTH 50
ADD COLUMN oCol TO oBrwDet ARRAY ELEMENT 2 HEADER "" WIDTH 130

ADD FOLDER oPrc CAPTION STR0011 OF oDlg //"Preço"
@ 18,1 TO 120,157 CAPTION STR0011 OF oPrc //"Preço"

@ 30,3 BROWSE oBrwPrc SIZE 152,85 OF oPrc
SET BROWSE oBrwPrc ARRAY aPrecos
ADD COLUMN oCol TO oBrwPrc ARRAY ELEMENT 1 HEADER STR0012 WIDTH 40 //"Tabela"
ADD COLUMN oCol TO oBrwPrc ARRAY ELEMENT 2 HEADER STR0013 WIDTH 45 //"Valor"

PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)                               

ACTIVATE DIALOG oDlg

Return Nil