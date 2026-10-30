#INCLUDE "SFVN003.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ At. ao Cliente      ³Autor - Paulo Lima   ³ Data ³25/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atendimento ao Cliente						 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
#include "eADVPL.ch"

/***************************************************************************/
/* Atendimento ao Cliente												   */
/***************************************************************************/
Function InitSale(aClientes,nCliente,oCliente,aRoteiro)
// ---> Dialogs
Local oDlg
//Local oOfertas, oMercado
Local oUltPed, oDuplicatas, oContatos, oPedido, oOcorrencia, oInventario //oLembretes,
Local oPosicao, oConsumo, oDetCli
Local oCod //oCodLbl
Local oMnu, oItem
//---> Browse
Local oBrwUltPed, oBrwDuplicatas, oBrwPosicao, oBrwPedido, oBrwContato, oBrwDetCli, oBrwConsumo, oBrwInv
Local nBrwPedido  :=0, nBrwContato 	:=0
//---> Buttons
Local oBtnIncPed, oBtnAltPed, oBtnExcPed, oBtnGrvOco,oBtnImpPed
Local oBtnIncCto, oBtnAltCto, oBtnDetCto, oBtnConsPed, oBtnGeraPed
Local oBtnProd, oIncItInv, oExcItInv, oBtnGrv
Local oUpCons,oDownCons,oLeftCons,oRightCons
//---> ListBox
Local oLbxOco
//---> TextBox
Local oTxtOco
Local oGetPrd, oGetQtd, oGetDes
//---> Labels
Local oSay
//Variaveis Locais                        
Local cCliente := "", cCodCli := "", cLojaCli := "", cNumPed := "", cOco :=space(2)
Local cCodPer	 := "", cCodRot  := "", cIteRot := "", cProd := "", cPrdDesc := "", cNomeCli := ""   
Local cCadCon:="1", nTop := 0
Local nOco := 0, nQtdInv := 0
Local aUltPed  :={}, aDuplicatas :={}, aPosicao :={}, aPedido	:={}, aOco :={}
Local aContato :={}, aDetCli	:={}, aConsumo	:={}, aInv := {}, aPrdPrefix := {}
//Local lVrfLimCred := .T.
Local cVrfLimCred := "0"
Local cVrfDebito := "0"
Local cPrinter := ""  // Parametro de impressao
Local oCol
// aInv[n,1] -> Cliente
// aInv[n,2] -> Loja
// aInv[n,3] -> Produto
// aInv[n,4] -> Quantidade
// aInv[n,4] -> Grava ou Nao 0/1

SET DATE BRITISH

if Len(aClientes) == 0
	MsgAlert(STR0001)  //"Nenhum Cliente/Roteiro selecionado"
	Return Nil
Endif

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek("CALCPROTHEUS")
If HCF->(Found())
	cCalcProtheus := AllTrim(HCF->CF_VALOR)
Else
	cCalcProtheus := "T"
Endif

If Len(aRoteiro)=0
	cCodRot  :=""
	cIteRot  :=""
Else
	cCodPer	 :=aRoteiro[nCliente,1]
	cCodRot	 :=aRoteiro[nCliente,2]
	cIteRot	 :=aRoteiro[nCliente,3]
Endif	

dbSelectArea("HCF")
if dbSeek("MV_SFCADCON")
    cCadCon:=AllTrim(HCF->CF_VALOR)
Endif	

dbSelectArea("HCF")
If dbSeek("MV_PRINTER")
    cPrinter :=AllTrim(HCF->CF_VALOR)
Endif	


dbSelectArea("HA1")
dbSetOrder(1)      
dbGoTop()

dbSeek(aClientes[nCliente,3]+aClientes[nCliente,4],.f. )
if !Eof()
	If HA1->A1_STATUS == "N" .And. !HA1->(IsDirty())	//Transmitido
		MsgAlert(STR0002,STR0003) //"Cliente novo já transmitido, não é possível incluir pedidos a ele."###"Aviso"
		return nil
	Endif
	cCodCli 	:= HA1->A1_COD
	cLojaCli	:= HA1->A1_LOJA
	cCliente 	:= AllTrim(cCodCli) + "/" + AllTrim(cLojaCli) + " - " + Alltrim(HA1->A1_NOME)
endif

cVrfLimCred	:= VrfLimCred(cCodCli,cLojaCli, 0,"")

DEFINE DIALOG oDlg TITLE STR0004 //"Atendimento"

//@ 18,05 SAY oCodLbl VAR "Cliente:" OF oDlg
@ 15,05 GET oCod VAR cCliente SIZE 157,15 READONLY MULTILINE OF oDlg

ADD MENUBAR oMnu CAPTION STR0004 OF oDlg //"Atendimento"
ADD MENUITEM oItem CAPTION STR0005 ACTION ACFecha(aClientes,nCliente,oCliente) OF oMnu //"Retornar"

// Pedido de Venda
ADD FOLDER oPedido     CAPTION STR0006 OF oDlg     //"Pedido"
@ 40,5 TO 140,155 CAPTION STR0006 OF oPedido //"Pedido"

if cVrfLimCred <> "2"
	@ 45,07 BUTTON oBtnIncPed CAPTION STR0007 ACTION PVPrepPed(1,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,12 OF oPedido //"Incluir"
	@ 45,57 BUTTON oBtnAltPed CAPTION STR0008 ACTION PVPrepPed(2,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,12 OF oPedido //"Alterar"
	@ 45,107 BUTTON oBtnExcPed CAPTION STR0009 ACTION PVExcPed(oBrwPedido, aPedido, @cNumPed,aClientes,nCliente,oCliente, cCodCli, cLojaCli, cCodRot,cIteRot) SIZE 45,12 OF oPedido //"Excluir"
	If cPrinter != "0"
		@ 61,07 BUTTON oBtnImpPed CAPTION STR0010 ACTION PVImp(oBrwPedido,aPedido) SIZE 47,12 OF oPedido //"Imprimir"
	EndIf
Endif

ACCrgPed(cCodCli, cLojaCli, aPedido,aUltPed)

@ 75,10 BROWSE oBrwPedido SIZE 140,62  OF oPedido
//ON CLICK PVNumPed(oBrwPedido,aPedido,@cNumPed)
SET BROWSE oBrwPedido ARRAY aPedido 
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 1 HEADER STR0011 WIDTH 50 //"Pedido Nº"
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 2 HEADER STR0012 WIDTH 50 //"Emissão"
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 3 HEADER STR0013 WIDTH 50 //"Cond.Pagto."
         	
// Ultimos Pedidos
ADD FOLDER oUltPed CAPTION STR0014 OF oDlg //"Ult.Pedido"
@ 40,05 TO 140,155 CAPTION STR0015 OF oUltPed //"Últimos Pedidos"

@ 50,011 BUTTON oBtnConsPed CAPTION STR0016     ACTION PVPrepPed(3,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,18 OF oUltPed //"Itens"
If cVrfLimCred != "2"
	@ 50,100 BUTTON oBtnGeraPed CAPTION STR0017 ACTION PVPrepPed(4,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,18 OF oUltPed //"Copiar Ped."
Endif


@ 72,10 BROWSE oBrwUltPed SIZE 140,62 OF oUltPed
SET BROWSE oBrwUltPed ARRAY aUltPed
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 1 HEADER STR0011 WIDTH 40 //"Pedido Nº"
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 2 HEADER STR0012 WIDTH 45 //"Emissão"
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 3 HEADER STR0018 WIDTH 100 //"Status"

// Folder Duplicatas
FolderDuplicatas(oDuplicatas, aDuplicatas, oBrwDuplicatas, oCol, oDlg)

cVrfDebito := VrfDebito(aDuplicatas)

If cVrfLimCred <> "2" .And. cVrfDebito = "2"
	HideControl(oBtnIncPed)
	HideControl(oBtnAltPed)
	HideControl(oBtnExcPed)
	If cPrinter != "0"
		HideControl(oBtnImpPed)
	Endif
	HideControl(oBtnGeraPed)
Endif

// Folder Posicao Financeira
FolderPosicao(oPosicao, aPosicao, oBrwPosicao, oCol, oDlg)

// Ocorrencias
ADD FOLDER oOcorrencia CAPTION STR0019 OF oDlg //"Ocorrência"
@ 40,5 TO 140,155 CAPTION STR0019 OF oOcorrencia //"Ocorrência"

ACCrgOco(aOco)              
nOco:=ACPsqOco(@cOco,aOco, cCodRot)

@44,10 SAY STR0020 of oOcorrencia //"Ocorrência Nº "
@44,70 GET oTxtOco VAR cOco SIZE 40,15 of oOcorrencia
@62,10 LISTBOX oLbxOco VAR nOco ITEMS aOco ACTION ACEscOco(cOco, oTxtOco, aOco, nOco) SIZE 140,55 OF oOcorrencia
//@123,10 BUTTON oBtnExcOco CAPTION "Excluir" SIZE 67,15 OF oOcorrencia
@123,10 BUTTON oBtnGrvOco CAPTION STR0021 ACTION ACGrvOco(cCodPer, cCodRot,cIteRot,cCodCli,cLojaCli,cOco,oTxtOco,aOco, len(aPedido),aClientes,nCliente) SIZE 140,15 OF oOcorrencia //"Gravar"

// Contatos
ADD FOLDER oContatos   CAPTION STR0022 OF oDlg //"Contatos"
@ 40,5 TO 140,155 CAPTION STR0022 OF oContatos //"Contatos"
ACCrgCto(cCodCli, cLojaCli, aContato)
@ 50,7 BUTTON oBtnIncCto CAPTION STR0007  ACTION AcManCon(1,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 47,18 OF oContatos //"Incluir"
@ 50,57 BUTTON oBtnAltCto CAPTION STR0008 ACTION AcManCon(2,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 47,18 OF oContatos //"Alterar"
@ 50,107 BUTTON oBtnDetCto CAPTION STR0023 ACTION AcMancon(3,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 45,18 OF oContatos //"Detalhe"
@ 75,10 BROWSE oBrwContato SIZE 140,62  OF oContatos
SET BROWSE oBrwContato ARRAY aContato
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 1 HEADER STR0024 WIDTH 30 //"Cód. "
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 2 HEADER STR0025 WIDTH 85 //"Contato "
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 3 HEADER STR0026 WIDTH 60 //"Cargo "

// Detalhe do Cliente
FolderDetCli(oDetCli, aDetCli, oBrwDetCli, oCol, oDlg)

//ADD FOLDER oLembretes  CAPTION "Lembretes" OF oDlg
//@ 40,5 TO 140,155 CAPTION "Lembretes" OF oLembretes

// Folder Inventario
LoadInv(aInv, cCodCli, cLojaCli)

ADD FOLDER oInventario CAPTION STR0027 ON ACTIVATE PreparaInv(aPrdPrefix) OF oDlg //"Inventário"
// Produto
#IFDEF __PALM__
	@ 30,005 SAY oSay PROMPT STR0028 OF oInventario //"Produto:"
	@ 30,040 GET oGetPrd VAR cProd SIZE 90,20 OF oInventario
	@ 30,135 BUTTON oBtnProd CAPTION "..."  SIZE 20,12 ACTION RefreshProd(oGetPrd, @cProd, aPrdPrefix) of oInventario
	
	// Quantidade
	@ 45,005 SAY oSay PROMPT STR0029 OF oInventario //"Quant.: "
	@ 45,040 GET oGetQtd VAR nQtdInv PICTURE "@E 99999.99" SIZE 45,20 OF oInventario
	@ 45,110 BUTTON oIncItInv CAPTION " + "  SIZE 20,12 ACTION UpdInv(1, aInv, cCodCli, cLojaCli, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
	@ 45,135 BUTTON oExcItInv CAPTION " - "  SIZE 20,12 ACTION UpdInv(2, aInv,,, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
#ELSE
	@ 32,005 SAY oSay PROMPT STR0028 OF oInventario //"Produto:"
	@ 32,040 GET oGetPrd VAR cProd SIZE 75,13 OF oInventario
	@ 32,135 BUTTON oBtnProd CAPTION "..."  SIZE 20,10 ACTION RefreshProd(oGetPrd, @cProd, aPrdPrefix) of oInventario
	
	// Quantidade
	@ 45,005 SAY oSay PROMPT STR0029 OF oInventario //"Quant.: "
	@ 45,040 GET oGetQtd VAR nQtdInv SIZE 75,13 PICTURE "@E 99999.99" OF oInventario
	@ 45,110 BUTTON oIncItInv CAPTION " + "  SIZE 20,10 ACTION UpdInv(1, aInv, cCliente, cLojaCli, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
	@ 45,135 BUTTON oExcItInv CAPTION " - "  SIZE 20,10 ACTION UpdInv(2, aInv,,, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
#ENDIF

@ 59,05 BROWSE oBrwInv SIZE 150,60 ON CLICK PesqItem(oBrwInv, oGetDes, aInv, @cPrdDesc,  3, 3) OF oInventario
SET BROWSE oBrwInv ARRAY aInv
ADD COLUMN oCol TO oBrwInv ARRAY ELEMENT 3 HEADER STR0030 WIDTH 55 //"Produto"
ADD COLUMN oCol TO oBrwInv ARRAY ELEMENT 4 HEADER STR0031 WIDTH 45 //"Qtd"

@ 119,005 GET oGetDes VAR cPrdDesc MULTILINE READONLY NO UNDERLINE SIZE 100,25 OF oInventario
@ 130,114 BUTTON oBtnGrv CAPTION STR0021 SIZE 43,12 ACTION GravaInv(aInv, oBrwInv) of oInventario //"Gravar"


// Consumo
ADD FOLDER oConsumo CAPTION STR0032 OF oDlg //"Consumo"
@ 40,5 TO 140,155 CAPTION STR0032 OF oConsumo //"Consumo"
#IFDEF __PALM__
	@ 50,10 BROWSE oBrwConsumo SIZE 125,83 NO SCROLL OF oConsumo
#ELSE
	@ 50,10 BROWSE oBrwConsumo SIZE 125,88 NO SCROLL OF oConsumo
#ENDIF
ACCrgConsumo(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop)

SET BROWSE oBrwConsumo ARRAY aConsumo
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 1 HEADER STR0030 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 2 HEADER STR0033 WIDTH 50 //"Mês/Ano Passado"
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 3 HEADER STR0034 WIDTH 50 //"Mês Passado"
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 4 HEADER STR0035 WIDTH 50 //"Mês Atual"

@  52,138 BUTTON oUpCons CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION ConsumoUp(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop) OF oConsumo
@  72,138 BUTTON oLeftCons CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oBrwConsumo) OF oConsumo
@  92,138 BUTTON oRightCons CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oBrwConsumo) OF oConsumo
@ 112,138 BUTTON oDownCons CAPTION DOWN_ARROW SYMBOL SIZE 12,10 ACTION ConsumoDown(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop) OF oConsumo

If cCadCon=="2"
	HideControl(oBtnIncCto)
Elseif cCadCon=="3"
	HideControl(oBtnIncCto)
	HideControl(oBtnAltCto)
Endif

/*
if lVrfLimCred == .f.
	DisableControl(oBtnIncPed)
	DisableControl(oBtnAltPed)
	DisableControl(oBtnExcPed)
	DisableControl(oBtnGeraPed)
Endif
*/	                           

//PONTO DE ENTRADA: Complemento ou remontagem da tela de Visita de Negocio (Atendimento)
//#IFDEF PEVN0001
	//Objetivo:
	//Retorno: 
	//uRet := PEVN0001()
//#ENDIF
ACTIVATE DIALOG oDlg

Return nil
