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
Local cCodRot  := "", cIteRot := "", cProd := "", cPrdDesc := "", cNomeCli := ""   
Local cCadCon:="1", nTop := 0
Local nOco := 0, nQtdInv := 0, nAtraso := 0
Local aUltPed  :={}, aDuplicatas :={}, aPosicao :={}, aPedido	:={}, aOco :={}
Local aContato :={}, aDetCli	:={}, aConsumo	:={}, aInv := {}
Local lVrfLimCred := .T.
Local oCol
// aInv[n,1] -> Cliente
// aInv[n,2] -> Loja
// aInv[n,3] -> Produto
// aInv[n,4] -> Quantidade
// aInv[n,4] -> Grava ou Nao 0/1

SET DATE BRITISH

if Len(aClientes) == 0
	MsgAlert("Nenhum Cliente/Roteiro selecionado") 
	Return Nil
Endif

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek(RetFilial("HCF")+"CALCPROTHEUS")
If HCF->(Found())
	cCalcProtheus := AllTrim(HCF->CF_VALOR)
Else
	cCalcProtheus := "T"
Endif

If Len(aRoteiro)=0
	cCodRot  :=""
	cIteRot  :=""
Else
	cCodRot	 :=aRoteiro[nCliente,1]
	cIteRot	 :=aRoteiro[nCliente,2]
Endif	

dbSelectArea("HCF")
if dbSeek(RetFilial("HCF")+"MV_SFCADCON")
    cCadCon:=AllTrim(HCF->CF_VALOR)
Endif	

dbSelectArea("HA1")
dbSetOrder(1)      
dbGoTop()

dbSeek(RetFilial("HA1")+aClientes[nCliente,3]+aClientes[nCliente,4],.f. )
if !Eof()
	If HA1->A1_STATUS == "N" .And. !HA1->(IsDirty())	//Transmitido
		MsgAlert("Cliente novo já transmitido, não é possível incluir pedidos a ele.","Aviso")
		return nil
	Endif
	cCodCli 	:= HA1->A1_COD
	cLojaCli	:= HA1->A1_LOJA
	cCliente 	:= AllTrim(cCodCli) + "/" + AllTrim(cLojaCli) + " - " + Alltrim(HA1->A1_NOME)
endif

lVrfLimCred	:= VrfLimCred(cCodCli,cLojaCli, 0,"")

DEFINE DIALOG oDlg TITLE "Atendimento"

//@ 18,05 SAY oCodLbl VAR "Cliente:" OF oDlg
@ 15,05 GET oCod VAR cCliente SIZE 157,15 READONLY MULTILINE OF oDlg

ADD MENUBAR oMnu CAPTION "Atendimento" OF oDlg
ADD MENUITEM oItem CAPTION "Retornar" ACTION ACFecha(aClientes,nCliente,oCliente) OF oMnu

// Pedido de Venda
ADD FOLDER oPedido     CAPTION "Pedido" OF oDlg    
@ 40,5 TO 140,155 CAPTION "Pedido" OF oPedido
if lVrfLimCred
	@ 45,07 BUTTON oBtnIncPed CAPTION "Incluir" ACTION PVPrepPed(1,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,12 OF oPedido
	@ 45,57 BUTTON oBtnAltPed CAPTION "Alterar" ACTION PVPrepPed(2,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,12 OF oPedido
	@ 45,107 BUTTON oBtnExcPed CAPTION "Excluir" ACTION PVExcPed(oBrwPedido, aPedido, @cNumPed,aClientes,nCliente,oCliente, cCodCli, cLojaCli, cCodRot,cIteRot) SIZE 45,12 OF oPedido
	@ 61,07 BUTTON oBtnImpPed CAPTION "Imprimir" ACTION PVImp(oBrwPedido,aPedido) SIZE 47,12 OF oPedido
Endif

ACCrgPed(cCodCli, cLojaCli, aPedido,aUltPed)

@ 75,10 BROWSE oBrwPedido SIZE 140,62  OF oPedido
//ON CLICK PVNumPed(oBrwPedido,aPedido,@cNumPed)
SET BROWSE oBrwPedido ARRAY aPedido 
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 1 HEADER "Pedido Nº" WIDTH 50
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 2 HEADER "Emissão" WIDTH 50
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 3 HEADER "Cond.Pagto." WIDTH 50

// Ultimos Pedidos
ADD FOLDER oUltPed CAPTION "Ult.Pedido" OF oDlg
@ 40,05 TO 140,155 CAPTION "Últimos Pedidos" OF oUltPed

@ 50,011 BUTTON oBtnConsPed CAPTION "Itens"     ACTION PVPrepPed(3,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,18 OF oUltPed
If lVrfLimCred
	@ 50,100 BUTTON oBtnGeraPed CAPTION "Copiar Ped." ACTION PVPrepPed(4,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,18 OF oUltPed
Endif


@ 72,10 BROWSE oBrwUltPed SIZE 140,62 OF oUltPed
SET BROWSE oBrwUltPed ARRAY aUltPed
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 1 HEADER "Pedido Nº" WIDTH 40
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 2 HEADER "Emissão" WIDTH 45
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 3 HEADER "Status" WIDTH 100

// Duplicatas
ADD FOLDER oDuplicatas CAPTION "Duplicatas" OF oDlg
@ 40,5 TO 140,155 CAPTION "Duplicatas" OF oDuplicatas

dbSelectArea("HE1")
dbSetOrder(1)
dbGoTop()
dbSeek( RetFilial("HE1")+HA1->A1_COD+HA1->A1_LOJA,.f. )
While !Eof() .And. HE1->HE1_FILIAL == RetFilial("HE1") .and. HE1->E1_CLIENTE == HA1->A1_COD .and. HE1->E1_LOJA == HA1->A1_LOJA
	nAtraso := Date() - HE1->E1_VENCTO
	AADD(aDuplicatas,{HE1->E1_TIPO,HE1->E1_EMISSAO,HE1->E1_VENCTO, HE1->E1_SALDO,HE1->E1_NUM,nAtraso })
	dbSkip()
Enddo

@ 50,10 BROWSE oBrwDuplicatas SIZE 140,83 OF oDuplicatas
SET BROWSE oBrwDuplicatas ARRAY aDuplicatas
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 1 HEADER "Tipo" WIDTH 30
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 2 HEADER "Emissao" WIDTH 45
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 3 HEADER "Vencto." WIDTH 45
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 4 HEADER "Valor" WIDTH 50
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 5 HEADER "Título Nº" WIDTH 40
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 6 HEADER "Dias Atrasado" WIDTH 40

ADD FOLDER oPosicao    CAPTION "Financeira" OF oDlg
@ 40,5 TO 140,155 CAPTION "Posição Financeira" OF oPosicao

AADD(aPosicao,{"SALDO:",""})
AADD(aPosicao,{"Duplicatas",HA1->A1_SALDUP})
AADD(aPosicao,{"Ano",HA1->A1_VACUM})
AADD(aPosicao,{"Limite Cr.",HA1->A1_LC})    //Acrescentado em 27/12/02
AADD(aPosicao,{"ATRASO:",""})
AADD(aPosicao,{"Valor",HA1->A1_ATR})
AADD(aPosicao,{"Nº. Pagtos",HA1->A1_PAGATR})
AADD(aPosicao,{"Média",HA1->A1_METR})
AADD(aPosicao,{"Maior",HA1->A1_MATR})
AADD(aPosicao,{"CHEQUES:",""})
AADD(aPosicao,{"Devolvido",HA1->A1_CHQDEVO})
AADD(aPosicao,{"Ult.Devolv",HA1->A1_DTULCHQ})
AADD(aPosicao,{"COMPRAS:",""})
AADD(aPosicao,{"Nº",HA1->A1_NROCOM})
AADD(aPosicao,{"1ª",HA1->A1_PRICOM})
AADD(aPosicao,{"Última",HA1->A1_ULTCOM})
AADD(aPosicao,{"TÍTULOS:",""})
AADD(aPosicao,{"Protestados",HA1->A1_TITPROT})

@ 50,10 BROWSE oBrwPosicao SIZE 140,84 OF oPosicao
SET BROWSE oBrwPosicao ARRAY aPosicao
ADD COLUMN oCol TO oBrwPosicao ARRAY ELEMENT 1 HEADER "" WIDTH 50
ADD COLUMN oCol TO oBrwPosicao ARRAY ELEMENT 2 HEADER "" WIDTH 50

// Ocorrencias
ADD FOLDER oOcorrencia CAPTION "Ocorrência" OF oDlg
@ 40,5 TO 140,155 CAPTION "Ocorrência" OF oOcorrencia

ACCrgOco(aOco)              
nOco:=ACPsqOco(@cOco,aOco, cCodRot)

@44,10 SAY "Ocorrência Nº " of oOcorrencia
@44,70 GET oTxtOco VAR cOco SIZE 40,15 of oOcorrencia
@62,10 LISTBOX oLbxOco VAR nOco ITEMS aOco ACTION ACEscOco(cOco, oTxtOco, aOco, nOco) SIZE 140,55 OF oOcorrencia
//@123,10 BUTTON oBtnExcOco CAPTION "Excluir" SIZE 67,15 OF oOcorrencia
@123,10 BUTTON oBtnGrvOco CAPTION "Gravar" ACTION ACGrvOco(cCodRot,cIteRot,cCodCli,cLojaCli,cOco,oTxtOco,aOco, len(aPedido),aClientes,nCliente) SIZE 140,15 OF oOcorrencia

// Contatos
ADD FOLDER oContatos   CAPTION "Contatos" OF oDlg
@ 40,5 TO 140,155 CAPTION "Contatos" OF oContatos
ACCrgCto(cCodCli, cLojaCli, aContato)
@ 50,7 BUTTON oBtnIncCto CAPTION "Incluir"  ACTION AcManCon(1,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 47,18 OF oContatos
@ 50,57 BUTTON oBtnAltCto CAPTION "Alterar" ACTION AcManCon(2,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 47,18 OF oContatos
@ 50,107 BUTTON oBtnDetCto CAPTION "Detalhe" ACTION AcMancon(3,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 45,18 OF oContatos
@ 75,10 BROWSE oBrwContato SIZE 140,62  OF oContatos
SET BROWSE oBrwContato ARRAY aContato
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 1 HEADER "Cód. " WIDTH 30
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 2 HEADER "Contato " WIDTH 85
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 3 HEADER "Cargo " WIDTH 60

// Detalhe do Cliente
ADD FOLDER oDetCli CAPTION "Cliente" OF oDlg
@ 40,5 TO 140,155 CAPTION "Detalhe do Cliente" OF oDetCli

AADD(aDetCli,{"R.Soc.",HA1->A1_NOME})
AADD(aDetCli,{"Fant.",HA1->A1_NREDUZ})
AADD(aDetCli,{"End.",HA1->A1_END})
AADD(aDetCli,{"Bairro",HA1->A1_BAIRRO})
AADD(aDetCli,{"CEP",HA1->A1_CEP})
AADD(aDetCli,{"Cid.",HA1->A1_MUN})
AADD(aDetCli,{"UF",HA1->A1_EST})
AADD(aDetCli,{"Tel",HA1->A1_TEL})
AADD(aDetCli,{"CGC",HA1->A1_CGC})
AADD(aDetCli,{"IE",HA1->A1_INSCR})
AADD(aDetCli,{"E-Mail",HA1->A1_EMAIL})

@ 50,10 BROWSE oBrwDetCli SIZE 140,84 OF oDetCli
SET BROWSE oBrwDetCli ARRAY aDetCli
ADD COLUMN oCol TO oBrwDetCli ARRAY ELEMENT 1 HEADER "" WIDTH 30
ADD COLUMN oCol TO oBrwDetCli ARRAY ELEMENT 2 HEADER "" WIDTH 85

//ADD FOLDER oLembretes  CAPTION "Lembretes" OF oDlg
//@ 40,5 TO 140,155 CAPTION "Lembretes" OF oLembretes

// Folder Inventario
LoadInv(aInv, cCodCli, cLojaCli)

ADD FOLDER oInventario CAPTION "Inventário" OF oDlg
// Produto
#IFDEF __PALM__
	@ 30,005 SAY oSay PROMPT "Produto:" OF oInventario
	@ 30,040 GET oGetPrd VAR cProd SIZE 90,20 OF oInventario
	@ 30,135 BUTTON oBtnProd CAPTION "..."  SIZE 20,12 ACTION RefreshProd(oGetPrd, @cProd) of oInventario
	
	// Quantidade
	@ 45,005 SAY oSay PROMPT "Quant.: " OF oInventario
	@ 45,040 GET oGetQtd VAR nQtdInv PICTURE "@E 99999.99" SIZE 45,20 OF oInventario
	@ 45,110 BUTTON oIncItInv CAPTION " + "  SIZE 20,12 ACTION UpdInv(1, aInv, cCodCli, cLojaCli, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
	@ 45,135 BUTTON oExcItInv CAPTION " - "  SIZE 20,12 ACTION UpdInv(2, aInv,,, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
#ELSE
	@ 32,005 SAY oSay PROMPT "Produto:" OF oInventario
	@ 32,040 GET oGetPrd VAR cProd SIZE 75,13 OF oInventario
	@ 32,135 BUTTON oBtnProd CAPTION "..."  SIZE 20,10 ACTION RefreshProd(oGetPrd, @cProd) of oInventario
	
	// Quantidade
	@ 45,005 SAY oSay PROMPT "Quant.: " OF oInventario
	@ 45,040 GET oGetQtd VAR nQtdInv SIZE 75,13 PICTURE "@E 99999.99" OF oInventario
	@ 45,110 BUTTON oIncItInv CAPTION " + "  SIZE 20,10 ACTION UpdInv(1, aInv, cCliente, cLojaCli, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
	@ 45,135 BUTTON oExcItInv CAPTION " - "  SIZE 20,10 ACTION UpdInv(2, aInv,,, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
#ENDIF

@ 59,05 BROWSE oBrwInv SIZE 150,60 ON CLICK PesqProd(oBrwInv, oGetDes, @cPrdDesc, aInv, 3) OF oInventario
SET BROWSE oBrwInv ARRAY aInv
ADD COLUMN oCol TO oBrwInv ARRAY ELEMENT 3 HEADER "Produto" WIDTH 55
ADD COLUMN oCol TO oBrwInv ARRAY ELEMENT 4 HEADER "Qtd" WIDTH 45

@ 119,005 GET oGetDes VAR cPrdDesc MULTILINE READONLY NO UNDERLINE SIZE 90,30 OF oInventario
@ 130,114 BUTTON oBtnGrv CAPTION "Gravar" SIZE 43,12 ACTION GravaInv(aInv, oBrwInv) of oInventario


// Consumo
ADD FOLDER oConsumo CAPTION "Consumo" OF oDlg
@ 40,5 TO 140,155 CAPTION "Consumo" OF oConsumo
#IFDEF __PALM__
	@ 50,10 BROWSE oBrwConsumo SIZE 130,83 NO SCROLL OF oConsumo
#ELSE
	@ 50,10 BROWSE oBrwConsumo SIZE 130,88 NO SCROLL OF oConsumo
#ENDIF
ACCrgConsumo(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop)

SET BROWSE oBrwConsumo ARRAY aConsumo
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 1 HEADER "Produto" WIDTH 50
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 2 HEADER "Mês/Ano Passado" WIDTH 50
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 3 HEADER "Mês Passado" WIDTH 50
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 4 HEADER "Mês Atual" WIDTH 50

@ 52,141 BUTTON oUpCons CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION ConsumoUp(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop) OF oConsumo
@ 64,141 BUTTON oLeftCons CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oBrwConsumo) OF oConsumo
@ 76,141 BUTTON oRightCons CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oBrwConsumo) OF oConsumo
@ 88,141 BUTTON oDownCons CAPTION DOWN_ARROW SYMBOL SIZE 12,10 ACTION ConsumoDown(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop) OF oConsumo

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