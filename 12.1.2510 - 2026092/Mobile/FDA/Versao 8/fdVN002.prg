#include "eADVPL.ch"
#include "FDVN002.ch"

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
/***************************************************************************/
/* Atendimento ao Cliente												   */
/***************************************************************************/
Function InitSale(aClientes,nCliente,oCliente,aRoteiro)
// ---> Dialogs
Local oDlg, oCol
//Local oOfertas, oMercado
Local oContatos, oPedido, oOcorrencia 
Local oPosicao, oEmiNota, oDetCli
Local oCod //oCodLbl
Local oMnu, oItem
//---> Browse
Local  oBrwPosicao, oBrwPedido, oBrwContato, oBrwDetCli
Local  oTrocas,oBrwUltPed
Local nBrwPedido  :=0, nBrwContato 	:=0
//---> Buttons
Local oBtnIncPed, oBtnAltPed, oBtnExcPed, oBtnGrvOco,oBtnImpPed
//Local oBtnImpBol
Local oBtnIncCto, oBtnAltCto, oBtnDetCto
//---> ListBox
Local oLbxOco
//---> TextBox
Local oTxtOco
//---> Labels
//Variaveis Locais                        
Local cCliente := "", cCodCli := "", cLojaCli := "", cNumPed := "", cOco :=space(2)
Local cCodRot  := "", cIteRot := "", cProd := "", cPrdDesc := "", cNomeCli := ""   
Local cCadCon:="1", nTop := 0, cNumNot:="" , cNumDev:="", cCodPer:=""
Local nOco := 0, nQtdTrc := 0, nAtraso := 0  , nAtend:=0 ,  nsldtot:=0
Local aPosicao :={}, aPedido	:={}, aOco :={} , aNotas:={}, aPrdPrefix:={}
Local aContato :={}, aDetCli:={} , aDuplicatas:={}, aTroca:={}, aForma:={}
Local cVrfLimCred := ""    
Local oBrwDev, oDev 
Local aDev:={},aUltPed:={}

//Notas fiscais
Local oBtnIncNota, oBtnAltNota, oBtnExcNota, oBtnImpNota
Local oBrwNotas

//Trocas
Local oGetPrd,oBtnProd,oGetQtd,oIncItTrc,oExcItTrc,oBrwTrc,oBtnGrv,oGetDes
Local cObsTrc:=""
Local nqtdped:=0

SET DATE BRITISH

if Len(aClientes) == 0
	MsgAlert(STR0013)  //"Nenhum Cliente/Roteiro selecionado"
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
	cCodCli 	:= HA1->A1_COD
	cLojaCli	:= HA1->A1_LOJA
	cCliente 	:= AllTrim(cCodCli) + "/" + AllTrim(cLojaCli) + " - " + Alltrim(HA1->A1_NOME)
endif

cVrfLimCred	:= VrfLimCred(cCodCli,cLojaCli, 0,"")

DEFINE DIALOG oDlg TITLE STR0014 //"Atendimento"

@ 15,05 GET oCod VAR cCliente SIZE 157,15 READONLY MULTILINE OF oDlg

ADD MENUBAR oMnu CAPTION STR0014 OF oDlg //"Atendimento"
ADD MENUITEM oItem CAPTION STR0015 ACTION ACFecha(aClientes,nCliente,oCliente) OF oMnu //"Retornar"

// Emissao de Notas
ADD FOLDER oEmiNota CAPTION STR0016 OF oDlg //"Notas"

@ 37,5 TO 140,155 CAPTION STR0017 OF oEmiNota //"Emissao de Notas"

@ 45,07 BUTTON oBtnIncNota  CAPTION STR0004 ACTION NFPrepNot(1,oBrwNotas,aNotas,cNumNot,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 45,10 OF oEmiNota //"Incluir"
@ 45,57 BUTTON oBtnAltNota  CAPTION STR0005 ACTION NFPrepNot(2,oBrwNotas,aNotas,cNumNot,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 45,10 OF oEmiNota //"Alterar"
@ 45,107 BUTTON oBtnExcNota CAPTION STR0006 ACTION NFExcNot(oBrwNotas,aNotas,cNumNot,aClientes,nCliente,oCliente,cCodCli, cLojaCli, cCodRot,cIteRot) SIZE 45,10 OF oEmiNota //"Excluir"
//@ 127,007 BUTTON oBtnImpBol  CAPTION "Boleto" ACTION Alert("Configurar Boleto") SIZE 45,10 OF oEmiNota
#IFDEF __PALM__
  @ 123,127 BUTTON oBtnImpNota  CAPTION BTN_BITMAP_PRINTER SYMBOL ACTION NFImp(oBrwNotas,aNotas)  OF oEmiNota
#ELSE
  @ 127,107 BUTTON oBtnImpNota  CAPTION STR0011 ACTION NFImp(oBrwNotas,aNotas) SIZE 45,10 OF oEmiNota //"Imprimir"
#ENDIF

ACCrgNot(cCodCli,cLojaCli,aNotas )   

@ 61,10 BROWSE oBrwNotas SIZE 140,62  OF oEmiNota
SET BROWSE oBrwNotas ARRAY aNotas
ADD COLUMN oCol TO oBrwNotas ARRAY ELEMENT 1 HEADER STR0018 WIDTH 50 //"Nota Nº"
ADD COLUMN oCol TO oBrwNotas ARRAY ELEMENT 2 HEADER STR0019 WIDTH 50      //"Emissão"
ADD COLUMN oCol TO oBrwNotas ARRAY ELEMENT 3 HEADER STR0020 WIDTH 60    				 //"Status "

LoadPagos(cCodCli,cLojaCli,aForma)
// Folder Pago (Recebimentos)
ADD FOLDER oForma CAPTION STR0010  OF oDlg //"Pago"
@ 40,5 TO 140,155 CAPTION STR0010 OF oForma  //"Pago"
@ 45,07 BUTTON oBtnIncForma CAPTION STR0004 ACTION ManutPagto(1,cCodCli,cLojaCli,nAtend,nSldTot,oBrwForma,aForma,aPedido) SIZE 47,12 OF oForma //"Incluir"
@ 45,57 BUTTON oBtnAltForma CAPTION STR0005 ACTION ManutPagto(2,cCodCli,cLojaCli,nAtend,nSldTot,oBrwForma,aForma,aPedido) SIZE 47,12 OF oForma //"Modificar"
@ 45,107 BUTTON oBtnExcForma CAPTION STR0006 ACTION ExcPagto(cCodCli,cLojaCli,nAtend,oBrwForma,aForma) SIZE 45,12 OF oForma //"Borrar"
#IfDef __PALM__
   @ 123,127 BUTTON oBtnImpForma CAPTION BTN_BITMAP_PRINTER SYMBOL ACTION RecImp(cCodCli,cLojaCli,aForma) SIZE 45,12 OF oForma //"Imprimir"
#Else     
   @ 125,107 BUTTON oBtnImpForma CAPTION STR0011 ACTION RecImp(cCodCli,cLojaCli,aForma) SIZE 45,12 OF oForma //"Imprimir" //"Imprimir"
#Endif
@ 61,10 BROWSE oBrwForma SIZE 140,62 OF oForma           
SET BROWSE oBrwForma ARRAY aForma
ADD COLUMN oCol TO oBrwForma ARRAY ELEMENT 1 HEADER STR0008 WIDTH 50  //"Emision"
ADD COLUMN oCol TO oBrwForma ARRAY ELEMENT 2 HEADER STR0012 WIDTH 20  //"Tipo"
ADD COLUMN oCol TO oBrwForma ARRAY ELEMENT 3 HEADER STR0009 WIDTH 50  //"Total"

//Devolucao 

ADD FOLDER oDev CAPTION STR0021 OF oDlg  //  //"Devolucao"
@ 40,5 TO 140,155 CAPTION STR0021 OF oDev //"Devolucao"
@ 45,07  BUTTON oBtnIncDev CAPTION STR0004 ACTION PDPrepDev(1,oBrwDev,aDev,@cNumDev,cCodCli, cLojaCli) SIZE 47,12 OF oDev //"Incluir"
@ 45,57  BUTTON oBtnAltDev CAPTION STR0005 ACTION PDPrepDev(2,oBrwDev,aDev,@cNumDev,cCodCli, cLojaCli) SIZE 47,12 OF oDev //"Alterar"
@ 45,107 BUTTON oBtnExcDev CAPTION STR0006 ACTION PDExcDev(oBrwDev, aDev, @cNumDev,cCodCli, cLojaCli)  SIZE 45,12 OF oDev //"Excluir"

ACCrgDev(cCodCli, cLojaCli, aDev)

@ 61,10 BROWSE oBrwDev SIZE 140,75  OF oDev
SET BROWSE oBrwDev ARRAY aDev
ADD COLUMN oCol TO oBrwDev ARRAY ELEMENT 1 HEADER STR0022  WIDTH 35  //"Codigo"
ADD COLUMN oCol TO oBrwDev ARRAY ELEMENT 2 HEADER STR0008 WIDTH 50  //"Emissao"
ADD COLUMN oCol TO oBrwDev ARRAY ELEMENT 3 HEADER STR0009   WIDTH 50  //"Total"

// Folder Trocas
LoadTroca(aTroca, cCodCli, cLojaCli)

ADD FOLDER oTrocas CAPTION STR0023 ON ACTIVATE PrepTroca(aPrdPrefix) OF oDlg //"Trocas"
// Produto
#IFDEF __PALM__
	@ 30,005 SAY oSay PROMPT STR0024 OF oTrocas //"Produto:"
	@ 30,040 GET oGetPrd VAR cProd SIZE 90,20 OF oTrocas
	@ 28,135 BUTTON oBtnProd CAPTION BTN_BITMAP_SEARCH SYMBOL ACTION RefreshProd(oGetPrd, @cProd, aPrdPrefix) of oTrocas
	
	// Quantidade
	@ 45,005 SAY oSay PROMPT STR0025 OF oTrocas //"Quant.: "
	@ 45,040 GET oGetQtd VAR nQtdTrc PICTURE "@E 99999.99" SIZE 45,20 OF oTrocas
    @ 43,085 BUTTON oBtnObs   CAPTION BTN_BITMAP_CLIPS SYMBOL ACTION Alert(STR0026) of oTrocas //"OBS"
	@ 43,110 BUTTON oIncItTrc CAPTION BTN_BITMAP_PLUS  SYMBOL ACTION UpdTrc(1, aTroca, cCodCli, cLojaCli, @cProd, @nQtdTrc, oGetPrd, oGetQtd, oBrwTrc) of oTrocas
	@ 43,135 BUTTON oExcItTrc CAPTION BTN_BITMAP_MINUS SYMBOL ACTION UpdTrc(2, aTroca,,, @cProd, @nQtdTrc, oGetPrd, oGetQtd, oBrwTrc) of oTrocas
#ELSE
	@ 32,005 SAY oSay PROMPT STR0024 OF oTrocas //"Produto:"
	@ 32,040 GET oGetPrd VAR cProd SIZE 75,13 OF oTrocas
	@ 32,110 BUTTON oBtnProd CAPTION STR0027 ACTION RefreshProd(oGetPrd, @cProd, aPrdPrefix) SIZE 45,10 of oTrocas //"Pesquisa"
	
	// Quantidade
	@ 45,005 SAY oSay PROMPT "Quant.: " OF oTrocas
	@ 45,040 GET oGetQtd VAR nQtdTrc SIZE 75,13 PICTURE "@E 99999.99" OF oTrocas
	@ 44,110 BUTTON oIncItTrc CAPTION "+" ACTION UpdTrc(1, aTroca, cCliente, cLojaCli, @cProd, @nQtdTrc, oGetPrd, oGetQtd, oBrwTrc) SIZE 23,10 of oTrocas
	@ 44,135 BUTTON oExcItTrc CAPTION "-" ACTION UpdTrc(2, aTroca,,, @cProd, @nQtdTrc, oGetPrd, oGetQtd, oBrwTrc) SIZE 23,10 of oTrocas
#ENDIF

@ 59,05 BROWSE oBrwTrc SIZE 150,60 ON CLICK PesqProd(oBrwTrc, oGetDes, @cPrdDesc, aTroca, 3) OF oTrocas
SET BROWSE oBrwTrc ARRAY aTroca
ADD COLUMN oCol TO oBrwTrc ARRAY ELEMENT 3 HEADER STR0028 WIDTH 55 //"Produto"
ADD COLUMN oCol TO oBrwTrc ARRAY ELEMENT 4 HEADER "Qtd" WIDTH 45

@ 119,005 GET oGetDes VAR cPrdDesc MULTILINE READONLY NO UNDERLINE SIZE 90,30 OF oTrocas

#IfDef __PALM__ 
  @ 125,135 BUTTON oBtnGrv CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION GravaTrc(aTroca, oBrwTrc) of oTrocas
#Else
  @ 125,110 BUTTON oBtnGrv CAPTION STR0029 ACTION GravaTrc(aTroca, oBrwTrc) of oTrocas //"Gravar"
#Endif

// Ocorrencias
ADD FOLDER oOcorrencia CAPTION STR0030 OF oDlg //"Ocorrência"
@ 40,5 TO 140,155 CAPTION STR0030 OF oOcorrencia //"Ocorrência"

ACCrgOco(aOco)              
nOco:=ACPsqOco(@cOco,aOco, cCodRot)
nqtdped:=len(aPedido)
@44,10 SAY STR0031 of oOcorrencia //"Ocorrência Nº "
@44,70 GET oTxtOco VAR cOco SIZE 40,15 of oOcorrencia
@62,10 LISTBOX oLbxOco VAR nOco ITEMS aOco ACTION ACEscOco(cOco, oTxtOco, aOco, nOco) SIZE 140,55 OF oOcorrencia
#IfDef __PALM__
   @123,10 BUTTON oBtnGrvOco CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION ACGrvOco(cCodPer,cCodRot,cIteRot,cCodCli,cLojaCli,cOco,oTxtOco,aOco,nqtdped,aClientes,nCliente)  SIZE 140,15 OF oOcorrencia
   //ACGrvOco(cCodRot,cIteRot,cCodCli,cLojaCli,cOco,oTxtOco,aOco,nqtdped,aClientes,nCliente) SIZE 140,15 OF oOcorrencia
#Else 
   @123,10 BUTTON oBtnGrvOco CAPTION STR0029 ACTION ACGrvOco(cCodPer,cCodRot,cIteRot,cCodCli,cLojaCli,cOco,oTxtOco,aOco,nqtdped,aClientes,nCliente)  SIZE 140,15 OF oOcorrencia //"Gravar"
   //ACGrvOco(cCodRot,cIteRot,cCodCli,cLojaCli,cOco,oTxtOco,aOco, len(aPedido),aClientes,nCliente) SIZE 140,15 OF oOcorrencia
#Endif   

// Pedido de Venda
ADD FOLDER oPedido     CAPTION STR0032 OF oDlg     //"Pedido"
@ 40,5 TO 140,155 CAPTION STR0032 OF oPedido //"Pedido"
if cVrfLimCred != "2"
	@ 45,07 BUTTON oBtnIncPed CAPTION STR0004 ACTION PVPrepPed(1,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 45,10 OF oPedido //"Incluir"
	@ 45,57 BUTTON oBtnAltPed CAPTION STR0005 ACTION PVPrepPed(2,oBrwPedido,aPedido,oBrwUltPed,aUltPed,@cNumPed,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 45,10 OF oPedido //"Alterar"
	@ 45,107 BUTTON oBtnExcPed CAPTION STR0006 ACTION PVExcPed(oBrwPedido, aPedido, @cNumPed,aClientes,nCliente,oCliente, cCodCli, cLojaCli, cCodRot,cIteRot) SIZE 45,10 OF oPedido //"Excluir"
    #IFDEF __PALM__
       @ 123,135 BUTTON oBtnImpPed CAPTION BTN_BITMAP_PRINTER SYMBOL ACTION PVImp(oBrwPedido,aPedido) SIZE 45,10 OF oPedido
    #ELSE
       @ 127,107 BUTTON oBtnImpPed CAPTION STR0011 ACTION PVImp(oBrwPedido,aPedido) SIZE 45,10 OF oPedido //"Imprimir"
    #ENDIF
Endif

// Nao tem ultimos pedidos . Pode ser que tenha no futuro ultimas notas 
// Aguardar pela Demanda 
//ACCrgPed(cCodCli, cLojaCli, aPedido )

@ 61,10 BROWSE oBrwPedido SIZE 140,62  OF oPedido
SET BROWSE oBrwPedido ARRAY aPedido 
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 1 HEADER STR0033 WIDTH 50 //"Pedido Nº"
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 2 HEADER STR0019 WIDTH 50 //"Emissão"
ADD COLUMN oCol TO oBrwPedido ARRAY ELEMENT 3 HEADER STR0034 WIDTH 50 //"Cond.Pagto."

ADD FOLDER oPosicao    CAPTION STR0035 OF oDlg //"Financeira"
@ 40,5 TO 140,155 CAPTION STR0036 OF oPosicao //"Posição Financeira"

AADD(aPosicao,{STR0037     ,""}) //"SALDO:"
AADD(aPosicao,{STR0038 ,HA1->A1_SALDUP}) //"Duplicatas"
AADD(aPosicao,{STR0039        ,HA1->A1_VACUM}) //"Ano"
AADD(aPosicao,{STR0040 ,HA1->A1_LC})    //Acrescentado em 27/12/02 //"Limite Cr."
AADD(aPosicao,{STR0041    ,""}) //"ATRASO:"
AADD(aPosicao,{STR0042      ,HA1->A1_ATR}) //"Valor"
AADD(aPosicao,{STR0043 ,HA1->A1_PAGATR}) //"Nº. Pagtos"
AADD(aPosicao,{STR0044      ,HA1->A1_METR}) //"Média"
AADD(aPosicao,{STR0045      ,HA1->A1_MATR}) //"Maior"
AADD(aPosicao,{STR0046   ,""}) //"CHEQUES:"
AADD(aPosicao,{STR0047  ,HA1->A1_CHQDEVO}) //"Devolvido"
AADD(aPosicao,{STR0048 ,HA1->A1_DTULCHQ}) //"Ult.Devolv"
AADD(aPosicao,{STR0049   ,""}) //"COMPRAS:"
AADD(aPosicao,{STR0050         ,HA1->A1_NROCOM}) //"Nº"
AADD(aPosicao,{STR0051         ,HA1->A1_PRICOM}) //"1ª"
AADD(aPosicao,{STR0052     ,HA1->A1_ULTCOM}) //"Última"
AADD(aPosicao,{STR0053   ,""}) //"TÍTULOS:"
AADD(aPosicao,{STR0054,HA1->A1_TITPROT}) //"Protestados"

@ 50,10 BROWSE oBrwPosicao SIZE 140,84 OF oPosicao
SET BROWSE oBrwPosicao ARRAY aPosicao
ADD COLUMN oCol TO oBrwPosicao ARRAY ELEMENT 1 HEADER "" WIDTH 50
ADD COLUMN oCol TO oBrwPosicao ARRAY ELEMENT 2 HEADER "" WIDTH 50

// Contatos
ADD FOLDER oContatos   CAPTION STR0055 OF oDlg //"Contatos"
@ 40,5 TO 140,155 CAPTION STR0055 OF oContatos //"Contatos"
ACCrgCto(cCodCli, cLojaCli, aContato)
@ 50,7 BUTTON oBtnIncCto CAPTION STR0004  ACTION AcManCon(1,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 47,18 OF oContatos //"Incluir"
@ 50,57 BUTTON oBtnAltCto CAPTION STR0005 ACTION AcManCon(2,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 47,18 OF oContatos //"Alterar"
@ 50,107 BUTTON oBtnDetCto CAPTION STR0056 ACTION AcMancon(3,oBrwContato,aContato,cCodCli, cLojaCli) SIZE 45,18 OF oContatos //"Detalhe"
@ 75,10 BROWSE oBrwContato SIZE 140,62  OF oContatos
SET BROWSE oBrwContato ARRAY aContato
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 1 HEADER STR0057 WIDTH 30 //"Cód. "
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 2 HEADER STR0058 WIDTH 85 //"Contato "
ADD COLUMN oCol TO oBrwContato ARRAY ELEMENT 3 HEADER STR0059 WIDTH 60 //"Cargo "

// Detalhe do Cliente
ADD FOLDER oDetCli CAPTION STR0060 OF oDlg //"Det.Cliente"
@ 40,5 TO 140,155 CAPTION STR0061 OF oDetCli //"Detalhe do Cliente"

AADD(aDetCli,{STR0062 ,HA1->A1_RISCO}) //"Risco "
AADD(aDetCli,{STR0063 ,HA1->A1_NOME}) //"R.Soc."
AADD(aDetCli,{STR0064  ,HA1->A1_NREDUZ}) //"Fant."
AADD(aDetCli,{STR0065   ,HA1->A1_END}) //"End."
AADD(aDetCli,{STR0066 ,HA1->A1_BAIRRO}) //"Bairro"
AADD(aDetCli,{STR0067    ,HA1->A1_CEP}) //"CEP"
AADD(aDetCli,{STR0068   ,HA1->A1_MUN}) //"Cid."
AADD(aDetCli,{STR0069     ,HA1->A1_EST}) //"UF"
AADD(aDetCli,{STR0070    ,HA1->A1_TEL}) //"Tel"
AADD(aDetCli,{STR0071    ,HA1->A1_CGC}) //"CGC"
AADD(aDetCli,{STR0072     ,HA1->A1_INSCR}) //"IE"
AADD(aDetCli,{STR0073 ,HA1->A1_EMAIL}) //"E-Mail"

@ 50,10 BROWSE oBrwDetCli SIZE 140,84 OF oDetCli
SET BROWSE oBrwDetCli ARRAY aDetCli
ADD COLUMN oCol TO oBrwDetCli ARRAY ELEMENT 1 HEADER "" WIDTH 30
ADD COLUMN oCol TO oBrwDetCli ARRAY ELEMENT 2 HEADER "" WIDTH 85

ACTIVATE DIALOG oDlg

Return nil
