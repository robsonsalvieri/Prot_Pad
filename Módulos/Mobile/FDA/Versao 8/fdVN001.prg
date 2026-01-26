#INCLUDE "FDVN001.ch"
#include "eADVPL.ch"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VisitaNegocio       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inicia Tela de Visita de Negocio      		 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VisitaNegocio()
Local oDlg, oMnu, oItem,oAniver,nShow := 1
Local oCbx, aOptions := {}
Local oCodLbl,oCod, cCodigo := "", oDia, aRota := {}
Local oRota, oEnd, cEnd := ""
Local oCGCLbl,oCGC, cCGC := ""
Local oLojaLbl,oLoja, cLoja := ""
Local oTelLbl,oTel, cTel := ""                                  
Local oStatusLbl,oStatus, cStatus := ""
Local oCliente, nCliente := 1, aClientes := {}
Local cRota := "", aRoteiro	:= {}
Local oPesquisar
Local oUp, oDown, oLeft,oRight,nTop
Local oPesqName, cPesqName := Space(40)
Local oPesqBtn, oPesqLbl, oPesqClose
Local oPesqOrd, nPesqOrd := 1, aPesqOrd := {STR0001,STR0002} //"Por Código"###"Por Nome"
Local nRows
Local oCol

MsgStatus(STR0003) //"Aguarde..."
AADD(aOptions, STR0004) //"Clientes"
AADD(aoptions, STR0005) //"Roteiro"

/*
dbSelectArea("HRT")
dbSetOrder(1)
dbGoTop()
While !Eof()
  AADD(aRota,AllTrim(HRT->RT_DESCR))
  dbSkip()
end
*/
dbSelectArea("HA1")
dbSetOrder(2)
dbGoTop()
nTop := Recno()

cCodigo := HA1->A1_COD
cLoja   := HA1->A1_LOJA
cEnd    := HA1->A1_END
cCGC    := HA1->A1_CGC
cTel    := HA1->A1_TEL

HCF->(dbSeek(RetFilial("HCF")+"MV_SFAVIEW"))
if HCF->(Found())
	if ( HCF->CF_VALOR = "C" )
	  nShow := 1
	else
	  nShow := 2
	endif
Else
	nShow :=1
Endif	
DEFINE DIALOG oDlg TITLE STR0006 //"Atendimento"
ADD MENUBAR oMnu CAPTION STR0007 OF oDlg //"Visitas"
ADD MENUITEM oItem CAPTION STR0008 ACTION InitSale(aClientes,nCliente,oCliente,aRoteiro) OF oMnu //"Iniciar Vendas"
ADD MENUITEM oItem CAPTION STR0009 ACTION ZerarVisCli() OF oMnu //"Zerar Visitas"
ADD MENUITEM oItem CAPTION STR0010 ACTION CloseDialog() OF oMnu //"Sair"

#ifdef __PALM__
	@ 0,110 COMBOBOX oCbx VAR nShow ITEM aOptions ACTION switch(nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows,oAniver ) OF oDlg
	@ 15,90 BUTTON oPesquisar CAPTION BTN_BITMAP_SEARCH SYMBOL ACTION ActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd) OF oDlg
	@ 18,01 SAY oCodLbl VAR STR0011 OF oDlg //"Código:"
	@ 18,35 GET oCod VAR cCodigo SIZE 35,15 READONLY OF oDlg
	//@ 18,80 SAY oRota VAR "Rota:" OF oDlg
	@ 18,75 BUTTON oRota CAPTION STR0012 ACTION SwitchRota(cRota, oDia, aRota, aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows) OF oDlg //"Rota"
    //ChangeRota(cRota, oDia, aRota,aRoteiro,nDia,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows)
	//@ 18,105 COMBOBOX oDia VAR nDia ITEMS aRota ACTION  OF oDlg
	@ 18,105 GET oDia VAR cRota READONLY SIZE 50,23 OF oDlg
	@ 30,01 GET oEnd VAR cEnd MULTILINE READONLY SIZE 156,23 OF oDlg
	@ 54,01 SAY oCGCLbl VAR STR0013 OF oDlg //"CGC/CPF:"
	@ 54,41 GET oCGC VAR cCGC READONLY SIZE 78,15 OF oDlg
	@ 54,123 SAY oLojaLbl VAR STR0014 OF oDlg //"Loja:"
	@ 54,149 GET oLoja VAR cLoja READONLY SIZE 15,15 OF oDlg
	@ 67,01 SAY oTelLbl VAR STR0015 OF oDlg //"Tel.:"
	@ 67,21 GET oTel VAR cTel READONLY SIZE 80,15 OF oDlg
	@ 67,101 SAY oStatusLbl VAR STR0016  OF oDlg //"St.:"
	@ 67,116 GET oStatus VAR cStatus READONLY SIZE 15,15 OF oDlg
	@ 18,143 BUTTON oAniver CAPTION BTN_BITMAP_CAKE SYMBOL OF oDlg
#else
	@ 0,100 COMBOBOX oCbx VAR nShow ITEM aOptions ACTION switch(nShow, oRota, oDia, oPesquisar, nCliente,oCliente, aClientes, aRota, aRoteiro,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows,oAniver ) OF oDlg
	@ 18,01 SAY oCodLbl VAR STR0011 OF oDlg //"Código:"
	@ 18,35 GET oCod VAR cCodigo SIZE 45,15 READONLY OF oDlg
	@ 18,90 BUTTON oPesquisar CAPTION STR0017 ACTION ActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd) SIZE 45,12 OF oDlg //"Pesquisar"
	@ 18,75 BUTTON oRota CAPTION STR0012 ACTION SwitchRota(cRota, oDia, aRota, aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows,oAniver) OF oDlg //"Rota"
	@ 18,105 GET oDia VAR cRota READONLY SIZE 50,23 OF oDlg
	@ 30,01 GET oEnd VAR cEnd MULTILINE READONLY SIZE 156,23 OF oDlg
	@ 54,01 SAY oCGCLbl VAR STR0013 OF oDlg //"CGC/CPF:"
	@ 54,41 GET oCGC VAR cCGC READONLY SIZE 78,15 OF oDlg
	@ 54,115 SAY oLojaLbl VAR STR0014 OF oDlg //"Loja:"
	@ 54,135 GET oLoja VAR cLoja READONLY SIZE 25,15 OF oDlg
	@ 66,01 SAY oTelLbl VAR STR0015 OF oDlg //"Tel.:"
	@ 66,21 GET oTel VAR cTel READONLY SIZE 70,15 OF oDlg
	@ 66,90 SAY oStatusLbl VAR STR0016 OF oDlg //"St.:"
	@ 66,110 GET oStatus VAR cStatus READONLY SIZE 20,15 OF oDlg
    @ 18,135 BUTTON oAniver CAPTION BTN_BITMAP_CAKE SYMBOL OF oDlg
#endif

@ 82,01 BROWSE oCliente SIZE 143,76 NO SCROLL ACTION ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,oAniver) OF oDlg
SET BROWSE oCliente ARRAY aClientes
ADD COLUMN oCol TO oCliente ARRAY ELEMENT 1 HEADER STR0018 WIDTH 27 //"Visit."
ADD COLUMN oCol TO oCliente ARRAY ELEMENT 2 HEADER STR0019 WIDTH 143 //"Cliente"
// acrecentado para Pronta Entrega
ADD COLUMN oCol TO oCliente ARRAY ELEMENT 5 HEADER STR0020 WIDTH 143 //"L.Credito"
ADD COLUMN oCol TO oCliente ARRAY ELEMENT 6 HEADER STR0021 WIDTH 143 //"Vencto L.C"
ADD COLUMN oCol TO oCliente ARRAY ELEMENT 7 HEADER STR0022 WIDTH 143 //"Aniversario"

@ 84 ,144 BUTTON oUp CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION ClientUp(nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows,oAniver) OF oDlg
@ 103,144 BUTTON oLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oCliente) OF oDlg
@ 122,144 BUTTON oRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oCliente) OF oDlg
@ 141,144 BUTTON oDown CAPTION DOWN_ARROW SYMBOL  SIZE 12,10 ACTION ClientDown(nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows,oAniver) OF oDlg

@ 19,01 SAY oPesqLbl VAR STR0023 OF oDlg //"Cliente:"
@ 19,35 COMBOBOX oPesqOrd VAR nPesqOrd ITEMS aPesqOrd OF oDlg
@ 31,01 GET oPesqName VAR cPesqName SIZE 156,15 OF oDlg

#IFDEF __Palm__
  @ 55,01 BUTTON oPesqBtn CAPTION BTN_BITMAP_SEARCH SYMBOL ACTION FindCustomer(oPesqName,cPesqName,nPesqOrd,oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRoteiro, aRota, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows,oAniver) OF oDlg
  @ 55,60 BUTTON oPesqClose CAPTION BTN_BITMAP_CANCEL SYMBOL ACTION DeActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd) OF oDlg
#ELSE
  @ 55,01 BUTTON oPesqBtn   CAPTION STR0017 ACTION FindCustomer(oPesqName,cPesqName,nPesqOrd,oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRoteiro, aRota, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows,oAniver) SIZE 45,10 OF oDlg //"Pesquisar"
  @ 55,60 BUTTON oPesqClose CAPTION STR0024  ACTION DeActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd)   SIZE 45,10  OF oDlg //"Cancelar"
#ENDIF
HideControl(oPesqLbl)
HideControl(oPesqName)
HideControl(oPesqBtn)
HideControl(oPesqClose)
HideControl(oPesqOrd)

HideControl(oRota)
HideControl(oDia)

nRows  :=GridRows(oCliente)

switch(nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows,oAniver)
ClearStatus()
ACTIVATE DIALOG oDlg

Return nil
