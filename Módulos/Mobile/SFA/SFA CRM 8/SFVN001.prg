#include "eADVPL.ch"
#include "sfvn001.ch"

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
Local oDlg, oMnu, oItem,nShow := 1
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
#IFNDEF __PALM__
Local oKeyDown, oKeyUp
#ENDIF


MsgStatus(STR0003) //"Aguarde..."
AADD(aOptions, STR0004) //"Clientes"
AADD(aoptions, STR0005) //"Roteiro"

If Existblock ("SFAVN004")
   aPesqOrd := Execblock ("SFAVN004", .F., .F.,{aPesqOrd})
EndIf   

dbSelectArea("HA1")
dbSetOrder(2)
dbSeek(RetFilial("HA1"))
//dbGoTop()
nTop := Recno()

cCodigo := HA1->HA1_COD
cLoja   := HA1->HA1_LOJA
cEnd    := HA1->HA1_END
cCGC    := HA1->HA1_CGC
cTel    := HA1->HA1_TEL

If HCF->(dbSeek(RetFilial("HCF") + "MV_SFAVIEW"))
	If ( HCF->HCF_VALOR = "C" )
	  nShow := 1
	Else
	  nShow := 2
	EndIf
Else
	nShow :=1
Endif	
DEFINE DIALOG oDlg TITLE STR0006 //"Atendimento"

ADD MENUBAR oMnu CAPTION STR0007 OF oDlg //"Visitas"

ADD MENUITEM oItem CAPTION STR0008 ACTION InitSale(aClientes,nCliente,oCliente,aRoteiro) OF oMnu //"Iniciar Vendas"
//ADD MENUITEM oItem CAPTION STR0009 ACTION ZerarVisCli() OF oMnu //"Zerar Visitas"
ADD MENUITEM oItem CAPTION STR0010 ACTION CloseDialog() OF oMnu //"Sair"

#ifdef __PALM__
	@ 0,110 COMBOBOX oCbx VAR nShow ITEM aOptions ACTION switch(nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows ) OF oDlg
	@ 18,01 SAY oCodLbl VAR STR0011 OF oDlg //"Código:"
	@ 18,35 GET oCod VAR cCodigo SIZE 35,15 READONLY OF oDlg
	//@ 18,80 SAY oRota VAR "Rota:" OF oDlg
	@ 18,75 BUTTON oRota CAPTION STR0012 ACTION SwitchRota(cRota, oDia, aRota, aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows) OF oDlg //"Rota"
    //ChangeRota(cRota, oDia, aRota,aRoteiro,nDia,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows)
	@ 18,90 BUTTON oPesquisar CAPTION STR0013 ACTION ActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd) OF oDlg //"Pesquisar"
	//@ 18,105 COMBOBOX oDia VAR nDia ITEMS aRota ACTION  OF oDlg
	
	@ 18,117 GET oDia VAR cRota READONLY SIZE 45,15 OF oDlg
	
	@ 30,01 GET oEnd VAR cEnd MULTILINE READONLY SIZE 156,23 OF oDlg
	@ 54,01 SAY oCGCLbl VAR STR0014 OF oDlg //"CGC/CPF:"
	@ 54,41 GET oCGC VAR cCGC READONLY SIZE 78,15 OF oDlg
	@ 54,123 SAY oLojaLbl VAR STR0015 OF oDlg //"Loja:"
	@ 54,149 GET oLoja VAR cLoja READONLY SIZE 15,15 OF oDlg
	@ 66,01 SAY oTelLbl VAR STR0016 OF oDlg //"Tel.:"
	@ 66,21 GET oTel VAR cTel READONLY SIZE 80,15 OF oDlg
	@ 66,101 SAY oStatusLbl VAR STR0017 OF oDlg //"St.:"
	@ 66,116 GET oStatus VAR cStatus READONLY SIZE 40,15 OF oDlg
	
	@ 82,01 BROWSE oCliente SIZE 144,76 NO SCROLL ACTION ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus) OF oDlg
	
#else

	If lNotTouch
		
		@ 2,01 SAY oCodLbl VAR STR0011 OF oDlg //"Código:"
		@ 2,35 GET oCod VAR cCodigo SIZE 45,15 READONLY OF oDlg
		//@ 18,80 SAY oRota VAR "Rota:" OF oDlg
		@ 18,45 BUTTON oPesquisar CAPTION STR0013 ACTION ActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd) SIZE 45,12 OF oDlg //"Pesquisar"
		@ 18,10 BUTTON oRota CAPTION STR0012 ACTION SwitchRota(cRota, oDia, aRota, aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows) SIZE 35,12 OF oDlg //"Rota"
		//@ 18,105 COMBOBOX oDia VAR nDia ITEMS aRota ACTION SwitchRota(cRota, oDia, aRota, aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows) OF oDlg
		@ 18,50 GET oDia VAR cRota READONLY SIZE 45,15 OF oDlg
		//SwitchRota(aRota,aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows)
		@ 35,01 GET oEnd VAR cEnd MULTILINE READONLY SIZE 156,15 OF oDlg
		
		@ 54,01 SAY oCGCLbl VAR STR0014 OF oDlg //"CGC/CPF:"
		@ 54,41 GET oCGC VAR cCGC READONLY SIZE 78,15 OF oDlg
		@ 54,115 SAY oLojaLbl VAR STR0015 OF oDlg //"Loja:"
		@ 54,135 GET oLoja VAR cLoja READONLY SIZE 25,15 OF oDlg
		
		@ 70,01 SAY oTelLbl VAR STR0016 OF oDlg //"Tel.:"
		@ 70,21 GET oTel VAR cTel READONLY SIZE 70,15 OF oDlg
		@ 70,90 SAY oStatusLbl VAR STR0017 OF oDlg //"St.:"
		@ 70,110 GET oStatus VAR cStatus READONLY SIZE 50,15 OF oDlg
		
		@ 85,01 BROWSE oCliente SIZE 144,70 NO SCROLL ACTION ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus) OF oDlg
		
		@ 5,95 COMBOBOX oCbx VAR nShow ITEM aOptions ACTION switch(nShow, oRota, oDia, oPesquisar, nCliente,oCliente, aClientes, aRota, aRoteiro,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows ) OF oDlg
		
	Else

		@ 0,100 COMBOBOX oCbx VAR nShow ITEM aOptions ACTION switch(nShow, oRota, oDia, oPesquisar, nCliente,oCliente, aClientes, aRota, aRoteiro,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows ) OF oDlg

		@ 18,01 SAY oCodLbl VAR STR0011 OF oDlg //"Código:"
		@ 18,35 GET oCod VAR cCodigo SIZE 45,15 READONLY OF oDlg
		//@ 18,80 SAY oRota VAR "Rota:" OF oDlg
		@ 18,90 BUTTON oPesquisar CAPTION STR0013 ACTION ActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd) SIZE 45,12 OF oDlg //"Pesquisar"
		@ 18,75 BUTTON oRota CAPTION STR0012 ACTION SwitchRota(cRota, oDia, aRota, aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows) OF oDlg //"Rota"
		//@ 18,105 COMBOBOX oDia VAR nDia ITEMS aRota ACTION SwitchRota(cRota, oDia, aRota, aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows) OF oDlg
		@ 18,117 GET oDia VAR cRota READONLY SIZE 45,15 OF oDlg
		//SwitchRota(aRota,aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows)
		@ 30,01 GET oEnd VAR cEnd MULTILINE READONLY SIZE 156,23 OF oDlg
		@ 54,01 SAY oCGCLbl VAR STR0014 OF oDlg //"CGC/CPF:"
		@ 54,41 GET oCGC VAR cCGC READONLY SIZE 78,15 OF oDlg
		@ 54,115 SAY oLojaLbl VAR STR0015 OF oDlg //"Loja:"
		@ 54,135 GET oLoja VAR cLoja READONLY SIZE 25,15 OF oDlg
		@ 66,01 SAY oTelLbl VAR STR0016 OF oDlg //"Tel.:"
		@ 66,21 GET oTel VAR cTel READONLY SIZE 70,15 OF oDlg
		@ 66,90 SAY oStatusLbl VAR STR0017 OF oDlg //"St.:"
		@ 66,110 GET oStatus VAR cStatus READONLY SIZE 50,15 OF oDlg
		
		@ 82,01 BROWSE oCliente SIZE 144,76 NO SCROLL ACTION ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus) OF oDlg
	EndIf
#endif

SET BROWSE oCliente ARRAY aClientes
ADD COLUMN oCol TO oCliente ARRAY ELEMENT 1 HEADER STR0018 WIDTH 27 //"Visit."
ADD COLUMN oCol TO oCliente ARRAY ELEMENT 2 HEADER STR0019 WIDTH 143 //"Cliente"

If !lNotTouch
	@ 82,146 BUTTON oUp CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION ClientUp(nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows) OF oDlg
	@ 104,146 BUTTON oLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oCliente) OF oDlg
	@ 126,146 BUTTON oRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oCliente) OF oDlg
	@ 148,146 BUTTON oDown CAPTION DOWN_ARROW SYMBOL  SIZE 12,10 ACTION ClientDown(nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows) OF oDlg
EndIf

//Tela de pesquisa
@ 20,01 SAY oPesqLbl VAR STR0020 OF oDlg //"Cliente:"
@ 15,95 COMBOBOX oPesqOrd VAR nPesqOrd ITEMS aPesqOrd ACTION SetFocus(oPesqName) OF oDlg
@ 41,01 GET oPesqName VAR cPesqName SIZE 156,15 OF oDlg
@ 65,01 BUTTON oPesqBtn CAPTION STR0013 ACTION FindCustomer(oPesqName,cPesqName,nPesqOrd,oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRoteiro, aRota, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows) OF oDlg //"Pesquisar"
@ 65,60 BUTTON oPesqClose CAPTION STR0021 ACTION DeActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd) OF oDlg //"Cancelar"

HideControl(oPesqLbl)
HideControl(oPesqName)
HideControl(oPesqBtn)
HideControl(oPesqClose)
HideControl(oPesqOrd)

HideControl(oRota)
HideControl(oDia)

If lNotTouch
	nRows := HA1->(RecCount())
Else
	nRows := GridRows(oCliente)
EndIf

switch(nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows )
ClearStatus()

#IFNDEF __PALM__
SET KEY VK_UP 	TO CliKeyMove(1, oCliente, nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows) IN oCliente OBJ oKeyUp
SET KEY VK_DOWN TO CliKeyMove(2, oCliente, nShow, oRota, oDia, oPesquisar, @nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,@nTop,nRows) IN oCliente OBJ oKeyDown
#ENDIF


ACTIVATE DIALOG oDlg

Return nil
