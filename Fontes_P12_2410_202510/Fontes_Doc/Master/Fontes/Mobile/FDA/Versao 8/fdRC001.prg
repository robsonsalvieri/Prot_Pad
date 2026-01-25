/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± < INDICE DAS FUNCOES  > ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±
±± @1.  InitRc -> Modulo principal do Recido
±± @2.  PVIteRec -> Modulo de Item do Recido
±± @3.  Acoes dos Botoes 
±± @3A. PVQTde -> Chamada do Keyboard para o Campo Qtde.
±± @3B. PVPrc -> Chamada do Keyboard para o Campo Preco.
±± @6A. PVDtEntr -> Data de Entrega ( BUTTON ENTREGA )
±± @6B. PVProduto -> Carrega o Modulo de Produtos( BUTTON PRODUTO )
±± @6C. PVObs -> Carrega o Memo de Observacao ( BUTTON OBS )
±± @6D. PVFecha -> Fecha o Modulo de Recidos ( BUTTON CANCELAR )
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 

   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Recidos de Venda    ³Autor - Paulo Lima   ³ Data ³27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Recidos        					 			  ³±±
±±³			 ³ InitRecido -> Inicia o Mod. de Recidos		 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³NOperacao 1- Inclusao /2 - Alteracao / 3 - Ult.Recido(Cons.)´±±
±±³			 ³4 - Ult.Recido (Gerar Novo Recido)   	     		 		  ´±±
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

Function InitRC(aCabRec,aIteRec,aCond,aTab,aColIteRC)
Local oDlg,oCab,oObs,oObj,oBrwIteRec,oDet
Local aObj := { {},{},{},{},{} }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := ""
Local nIteRec:=0
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := "", cSfaFpgIni := ""
Local cFrete := "", cSfaFre := "", aTpFrete := {"CIF", "FOB"}, nOpcFre := If(aCabRec[16,1]="C",1,2)
Local aPrdPrefix := {}, cPrdPrefix := "", cPrefix := "", nPreTimes := 0, nPreLen := 0
Local nPos := 0
Local oCol

If aCabRec[2,1] = 1 .Or. aCabRec[2,1] = 4
	DEFINE DIALOG oDlg TITLE "Inclusão Recebimento"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo Recido)

Else 
	DEFINE DIALOG oDlg TITLE "Alteração do Recido"
EndIf

@ 15,05 GET oObj VAR cCliente SIZE 157,15 READONLY MULTILINE OF oDlg
AADD(aObj[1],oObj) 
@ 130,71 BUTTON oObj CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION ALERT("1") OF oDlg
//PVGravarRec(aCabRec,aIteRec,aColIte,cCondInt,cSfaInd,cSfaFpg) SIZE 40,12 OF oDlg
AADD(aObj[1],oObj) 
@ 130,116 BUTTON oObj CAPTION BTN_BITMAP_CANCEL SYMBOL ACTION ALERT("2") OF oDlg
//PVFecha(aCabRec[2,1]) SIZE 40,12 OF oDlg
AADD(aObj[1],oObj) 
@ 130,2 SAY "T:"  of oDlg

#ifdef __PALM__
	//@ 130,20 GET oObj VAR aCabRec[12,1] READONLY SIZE 40,12 of oDlg
	AADD(aObj[1],oObj) 
#else
	//@ 130,20 GET oObj VAR aCabRec[12,1] READONLY SIZE 52,12 of oDlg
	AADD(aObj[1],oObj) 
#endif

ADD FOLDER oCab CAPTION "Recebimento" OF oDlg
@ 30,01 TO 127,158 CAPTION "Principal" OF oCab

ADD FOLDER oDet CAPTION "Detalhe" OF oDlg
@ 30,01 TO 127,158 CAPTION "Detalhe" OF oDet
@ 40,03 BROWSE oBrwIteRec SIZE 134,82 of oDet
SET BROWSE oBrwIteRec ARRAY aIteRec
ADD COLUMN oCol TO oBrwIteRec ARRAY ELEMENT 1 HEADER "Tipo"     WIDTH 50
ADD COLUMN oCol TO oBrwIteRec ARRAY ELEMENT 2 HEADER "Descr."   WIDTH 130 
ADD COLUMN oCol TO oBrwIteRec ARRAY ELEMENT 3 HEADER "Bco   "   WIDTH 35
ADD COLUMN oCol TO oBrwIteRec ARRAY ELEMENT 4 HEADER "cheque"   WIDTH 35
ADD COLUMN oCol TO oBrwIteRec ARRAY ELEMENT 5 HEADER "Valor "   WIDTH 35
ADD COLUMN oCol TO oBrwIteRec ARRAY ELEMENT 6 HEADER "3o?"      WIDTH 35
ADD COLUMN oCol TO oBrwIteRec ARRAY ELEMENT 7 HEADER "Desc."    WIDTH 35
AADD(aObj[3],oBrwIteRec)

@ 40,140 BUTTON oObj CAPTION "N" SIZE 16,12 ACTION Alert("1") of oDet
//RCIteRec(1,aIteRec, @nIteRec, aColIte, aCabRec,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix) of oDet
AADD(aObj[3],oObj)
@ 54,140 BUTTON oObj CAPTION "A" SIZE 16,12 ACTION Alert("2") of oDet
//RCIteRec(2,aIteRec, @nIteRec, aColIte, aCabRec,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix) of oDet
AADD(aObj[3],oObj)
@ 68,140 BUTTON oObj CAPTION "E" SIZE 16,12 ACTION Alert("2") of oDet 
//RCExcIte(aIteRec,@nIteRec, aCabRec,aObj, .F.,1) of oDet
AADD(aObj[3],oObj)

ADD FOLDER oObs CAPTION "Obs" OF oDlg
@ 30,01 TO 127,158 CAPTION "Observação" OF oObs
@ 40,05 GET oObj VAR aCabRec[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
AADD(aObj[4],oObj)

ACTIVATE DIALOG oDlg

Return Nil