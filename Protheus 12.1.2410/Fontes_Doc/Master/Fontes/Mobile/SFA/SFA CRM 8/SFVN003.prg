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
Local oBtnIncPed, oBtnAltPed, oBtnExcPed, oBtnGrvOco,oBtnImpPed, oBtnVisPed
Local oBtnIncCto, oBtnAltCto, oBtnDetCto, oBtnConsPed, oBtnGeraPed
Local oBtnProd, oIncItInv, oExcItInv, oBtnGrv
Local oUpCons,oDownCons,oLeftCons,oRightCons
//---> ListBox
Local oLbxOco
//---> TextBox
Local oTxtOco
Local oGetPrd, oGetQtd
//Local oGetDes
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
Local lVrfItem := .T.
Local cNreduzi := ""
// Criada esta variavel para informar a quantidade de colunas que tera o browse de Ultimos Pedidos
// A qual sera passada no ponto de entrada abaixo para que o mesmo possa criar as demais dinamicamente
Local nColUlPed := 3
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
dbSeek(RetFilial("HCF") + "CALCPROTHEUS")
If HCF->(Found())
	cCalcProtheus := AllTrim(HCF->HCF_VALOR)
Else
	cCalcProtheus := "T"
Endif 

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek(RetFilial("HCF") + "MV_SFNREDU")
if !eof()
	cNreduzi := AllTrim(HCF->HCF_VALOR)
else
	cNreduzi :=	"F"  
endif

If Len(aRoteiro)=0
	cCodRot  :=""
	cIteRot  :=""
Else
	cCodPer	 :=aRoteiro[nCliente,1]
	cCodRot	 :=aRoteiro[nCliente,2]
	cIteRot	 :=aRoteiro[nCliente,3]
Endif	
dbSelectArea("HCF")
if dbSeek(RetFilial("HCF") + "MV_SFCADCN")
    cCadCon:=AllTrim(HCF->HCF_VALOR)
Endif	

dbSelectArea("HCF")
If dbSeek(RetFilial("HCF") + "MV_PRINTER")
    cPrinter :=AllTrim(HCF->HCF_VALOR)
Endif	

dbSelectArea("HA1")
dbSetOrder(1)      
//dbSeek(RetFilial("HA1"))
//dbGoTop()

dbSeek(RetFilial("HA1") + aClientes[nCliente,3]+aClientes[nCliente,4],.f. )
if !Eof()
	If HA1->HA1_STATUS == "N" .And. !HA1->(IsDirty())	//Transmitido
		MsgAlert(STR0002,STR0003) //"Cliente novo já transmitido, não é possível incluir pedidos a ele."###"Aviso"
		return nil
	Endif
	cCodCli 	:= HA1->HA1_COD
	cLojaCli	:= HA1->HA1_LOJA  
	
	If cNreduzi == "T"
		cCliente 	:= AllTrim(cCodCli) + "/" + AllTrim(cLojaCli) + " - " + Alltrim(HA1->HA1_NREDUZ)
	Else  
		cCliente 	:= AllTrim(cCodCli) + "/" + AllTrim(cLojaCli) + " - " + Alltrim(HA1->HA1_NOME)
	EndIf 
EndIf

cVrfLimCred	:= VrfLimCred(cCodCli,cLojaCli, 0,"")
// Ponto de Entrada Antes da Montagem da Tela de Atendimento (Onde podemos dar manutenção nos Pedidos)
// Permitindo que seja possivel decidir se o Atendimento Segue ou Nao para o cliente (O qual esta posicionado no Browse e na Tabela neste momento)
// Deve ser retornado .T. ou .F. para o funcionamento correto do Ponto
If ExistBlock("SFAVN001")
	lVrfItem := ExecBlock("SFAVN001", .F., .F., {aClientes,nCliente}) // 1-Array com os Clientes, 2-Posicao do Cliente no Array
	If !lVrfItem
		Return nil
	EndIf
EndIf

DEFINE DIALOG oDlg TITLE STR0004 //"Atendimento"

//@ 18,05 SAY oCodLbl VAR "Cliente:" OF oDlg
If lNotTouch
	@ 08,05 GET oCod VAR cCliente SIZE 155,20 READONLY MULTILINE OF oDlg
Else
	@ 15,05 GET oCod VAR cCliente SIZE 155,15 READONLY MULTILINE OF oDlg
EndIf

ADD MENUBAR oMnu CAPTION STR0004 OF oDlg //"Atendimento"
ADD MENUITEM oItem CAPTION STR0005 ACTION ACFecha(aClientes,nCliente,oCliente) OF oMnu //"Retornar"

//Carrega pedidos do cliente
ACCrgPed(cCodCli, cLojaCli, aPedido, aUltPed)

// Pedido de Venda
ADD FOLDER oPedido     CAPTION STR0006 ON ACTIVATE ACCrgPed(cCodCli, cLojaCli, aPedido, aUltPed) OF oDlg     //"Pedido"
@ 35,5 TO 140,155 CAPTION STR0006 OF oPedido //"Pedido"

if cVrfLimCred <> "2"
	@ 43,07 BUTTON oBtnIncPed CAPTION STR0007 ACTION PVPrepPed(1,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,12 OF oPedido //"Incluir"
	@ 43,57 BUTTON oBtnAltPed CAPTION STR0008 ACTION PVPrepPed(2,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,12 OF oPedido //"Alterar"
	@ 43,107 BUTTON oBtnExcPed CAPTION STR0009 ACTION PVExcPed(oBrwPedido, aPedido, @cNumPed,aClientes,nCliente,oCliente, cCodCli, cLojaCli, cCodPer, cCodRot,cIteRot) SIZE 45,12 OF oPedido //"Excluir"      
	If cPrinter != "0"
		@ 58,07 BUTTON oBtnImpPed CAPTION STR0010 ACTION PVImp(oBrwPedido,aPedido) SIZE 47,12 OF oPedido //"Imprimir"
	EndIf
	@ 58,57 BUTTON oBtnVisPed CAPTION STR0036 ACTION PVPrepPed(5,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,12 OF oPedido //Visualizar
Endif

@ 75,10 BROWSE oBrwPedido SIZE 140,62  OF oPedido
//ON CLICK PVNumPed(oBrwPedido,aPedido,@cNumPed)
SET BROWSE oBrwPedido ARRAY aPedido 
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 1 HEADER STR0011 WIDTH 50 //"Pedido Nº"
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 2 HEADER STR0012 WIDTH 50 //"Emissão"
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 3 HEADER STR0013 WIDTH 50 //"Cond.Pagto."
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 4 HEADER "Status" WIDTH 50
         	
// Ultimos Pedidos
ADD FOLDER oUltPed CAPTION STR0014 ON ACTIVATE ACCrgPed(cCodCli, cLojaCli, aPedido, aUltPed) OF oDlg //"Ult.Pedido"

@ 40,05 TO 140,155 CAPTION STR0015 OF oUltPed //"Últimos Pedidos"

@ 50,011 BUTTON oBtnConsPed CAPTION STR0016 ACTION PVPrepPed(3,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,18 OF oUltPed //"Itens"
If cVrfLimCred != "2"
	@ 50,100 BUTTON oBtnGeraPed CAPTION STR0017 ACTION PVPrepPed(4,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 47,18 OF oUltPed //"Copiar Ped."
Endif


@ 72,10 BROWSE oBrwUltPed SIZE 140,62 OF oUltPed
SET BROWSE oBrwUltPed ARRAY aUltPed
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 1 HEADER STR0011 WIDTH 40 //"Pedido Nº"
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 2 HEADER STR0012 WIDTH 45 //"Emissão"
ADD COLUMN oCol TO oBrwUltPed ARRAY ELEMENT 3 HEADER STR0018 WIDTH 100 //"Status"

// Ponto de Entrada ao final da montagem do Folder Ultimos Pedidos
// Possibilitando a inclusao de novas colunas neste folder, bem como abastecer o arrua aUltPed com os demais dados
If ExistBlock("SFAVN002")
	ExecBlock("SFAVN002", .F., .F., {aUltPed, oBrwUltPed, oUltPed, oCol, nColUlPed,oBtnGeraPed })
EndIf

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

If lNotTouch
	@ 35,5 TO 140,155 CAPTION STR0019 OF oOcorrencia //"Ocorrência"
Else
	@ 40,5 TO 140,155 CAPTION STR0019 OF oOcorrencia //"Ocorrência"
EndIf

ACCrgOco(aOco)              
nOco:=ACPsqOco(@cOco,aOco, cCodRot)

@44,10 SAY STR0020 of oOcorrencia //"Ocorrência Nº "
@44,70 GET oTxtOco VAR cOco SIZE 40,15 of oOcorrencia
@62,10 LISTBOX oLbxOco VAR nOco ITEMS aOco ACTION ACEscOco(cOco, oTxtOco, aOco, nOco) SIZE 140,50 OF oOcorrencia
//@123,10 BUTTON oBtnExcOco CAPTION "Excluir" SIZE 67,15 OF oOcorrencia
@115,10 BUTTON oBtnGrvOco CAPTION STR0021 ACTION ACGrvOco(cCodPer, cCodRot,cIteRot,cCodCli,cLojaCli,cOco,oTxtOco,aOco, len(aPedido),aClientes,nCliente) SIZE 140,15 OF oOcorrencia //"Gravar"

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
	@ 30,040 GET oGetPrd VAR cProd SIZE 65,20 OF oInventario
	@ 30,135 BUTTON oBtnProd CAPTION "..."  SIZE 20,12 ACTION RefreshProd(oGetPrd, @cProd, aPrdPrefix) of oInventario
	
	// Quantidade
	@ 45,005 SAY oSay PROMPT STR0029 OF oInventario //"Quant.: "
	@ 45,040 GET oGetQtd VAR nQtdInv PICTURE "@E 99999.99" SIZE 45,20 OF oInventario
	@ 45,110 BUTTON oIncItInv CAPTION " + "  SIZE 20,12 ACTION UpdInv(1, aInv, cCodCli, cLojaCli, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
	@ 45,135 BUTTON oExcItInv CAPTION " - "  SIZE 20,12 ACTION UpdInv(2, aInv,,, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
#ELSE
	@ 30,005 SAY oSay PROMPT STR0028 OF oInventario //"Produto:"
	@ 30,040 GET oGetPrd VAR cProd SIZE 75,13 OF oInventario
	@ 30,135 BUTTON oBtnProd CAPTION "..."  SIZE 20,10 ACTION RefreshProd(oGetPrd, @cProd, aPrdPrefix) of oInventario
	
	// Quantidade
	@ 45,005 SAY oSay PROMPT STR0029 OF oInventario //"Quant.: "
	@ 45,040 GET oGetQtd VAR nQtdInv SIZE 75,13 PICTURE "@E 99999.99" OF oInventario
	@ 45,110 BUTTON oIncItInv CAPTION " + "  SIZE 20,10 ACTION UpdInv(1, aInv, cCliente, cLojaCli, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
	@ 45,135 BUTTON oExcItInv CAPTION " - "  SIZE 20,10 ACTION UpdInv(2, aInv,,, @cProd, @nQtdInv, oGetPrd, oGetQtd, oBrwInv) of oInventario
#ENDIF
                                                                         
@ 65,05 BROWSE oBrwInv SIZE 150,60 /*ON CLICK PesqProd(oBrwInv, oGetDes, @cPrdDesc, aInv, 3)*/ OF oInventario
SET BROWSE oBrwInv ARRAY aInv
ADD COLUMN oCol TO oBrwInv ARRAY ELEMENT 3 HEADER STR0030 WIDTH 55 //"Produto"
ADD COLUMN oCol TO oBrwInv ARRAY ELEMENT 4 HEADER STR0031 WIDTH 45 //"Qtd"

//@ 125,005 GET oGetDes VAR cPrdDesc MULTILINE READONLY NO UNDERLINE SIZE 85,30 OF oInventario
@ 131,114 BUTTON oBtnGrv CAPTION STR0021 SIZE 43,12 ACTION GravaInv(aInv, oBrwInv) of oInventario //"Gravar"

// Consumo
ADD FOLDER oConsumo CAPTION STR0032 OF oDlg //"Consumo"
@ 40,5 TO 140,155 CAPTION STR0032 OF oConsumo //"Consumo"
#IFDEF __PALM__
	@ 50,10 BROWSE oBrwConsumo SIZE 130,83 NO SCROLL OF oConsumo
#ELSE
	If lNotTouch
		@ 50,10 BROWSE oBrwConsumo SIZE 140,80 NO SCROLL OF oConsumo
	Else
		@ 50,10 BROWSE oBrwConsumo SIZE 130,88 NO SCROLL OF oConsumo
	EndIf
#ENDIF
ACCrgConsumo(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop)

SET BROWSE oBrwConsumo ARRAY aConsumo
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 1 HEADER STR0030 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 2 HEADER STR0033 WIDTH 50 //"Mês/Ano Passado"
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 3 HEADER STR0034 WIDTH 50 //"Mês Passado"
ADD COLUMN oCol TO oBrwConsumo ARRAY ELEMENT 4 HEADER STR0035 WIDTH 50 //"Mês Atual"

If !lNotTouch
	@ 52,141 BUTTON oUpCons CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION ConsumoUp(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop) OF oConsumo
	@ 64,141 BUTTON oLeftCons CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oBrwConsumo) OF oConsumo
	@ 76,141 BUTTON oRightCons CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oBrwConsumo) OF oConsumo
	@ 88,141 BUTTON oDownCons CAPTION DOWN_ARROW SYMBOL SIZE 12,10 ACTION ConsumoDown(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop) OF oConsumo
EndIf

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

SetArray(oBrwPedido, aPedido)
SetArray(oBrwUltPed, aUltPed)

Return Nil
