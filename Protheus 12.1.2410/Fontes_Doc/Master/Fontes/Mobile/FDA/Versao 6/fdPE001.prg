#INCLUDE "FDPE001.ch"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± < INDICE DAS FUNCOES  > ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
±±
±± @1.  InitNF -> Modulo principal das Notas
±± @2.  PVIteNot -> Modulo de Item das Notas
±± @3.  Acoes dos Botoes 
±± @3A. PVQTdeNF -> Chamada do Keyboard para o Campo Qtde.
±± @3B. PVPrcNF -> Chamada do Keyboard para o Campo Preco.
±± @6A. PVDtEntrNF -> Data de Entrega ( BUTTON ENTREGA )
±± @6B. PVProdutoNF -> Carrega o Modulo de Produtos( BUTTON PRODUTO )
±± @6C. PVObsNF -> Carrega o Memo de Observacao ( BUTTON OBS )
±± @6D. NFFechaNf -> Fecha o Modulo das Notas ( BUTTON CANCELAR )
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 

   
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ Notas   de Venda    ≥Autor-Marcelo Vieira ≥ Data ≥27/06/02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Modulo de Notas          					 			  ≥±±
±±≥			 ≥ InitNotas -> Inicia o Mod. de Notas   		 			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFA CRM 6.0                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥NOperacao 1- Inclusao /2 - Alteracao / 3 -                  ¥±±
±±≥			 ≥4 -                                  	     		 		  ¥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista    ≥ Data   ≥Motivo da Alteracao                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

#include "eADVPL.ch"

Function InitNF(aCabNot,aIteNot,aCond,aTab,aColIteNf)
Local oDlg,oCol,oCabnf,oObj,oBrwItenf,oDetnf,oImpsNf,oBrwImp
Local aObj := { {},{},{},{},{} }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := ""
Local nIteNot:=0
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := ""
Local cSfaFre := "", aTpFrete := {"CIF", "FOB"}, nOpcFre := 2
Local aImpostos:={}
Local cCF:="",cGeraDup:="N"

dbSelectArea("HA1")
dbSetorder(1)
dbSeek(aCabNot[4,1]+aCabNot[5,1])  
cCliente:=HA1->A1_COD + "/" + HA1->A1_LOJA + " - " + HA1->A1_NOME
cCond 	:= Alltrim(HA1->A1_COND) 
If HA1->(FieldPos("A1_TRANSP")) <> 0
	cTransp := Alltrim(HA1->A1_TRANSP)
EndIf

dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_SFAMTES")//Permite ou nao ao vendedor manipular a TES
if !eof()
	cManTes:=AllTrim(HCF->CF_VALOR)
else
	cManTes:="N"
Endif              

dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_SEMPREC")//Permite ou nao ao vendedor digitar o preco (quando nao houver)
if !eof()
	cManPrc:=AllTrim(HCF->CF_VALOR)
else
	cManPrc:="N"
Endif

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek("MV_BLOQPRC")//Bloqueio do campo preco
if !eof()
	cBloqPrc := AllTrim(HCF->CF_VALOR)
else
	cBloqPrc :=	"S"
endif
                   
dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_SFCONDI")//Habilita ou nao a cond. de pagto. inteligente (T ou F)
if !eof()
	cCondInt:=AllTrim(HCF->CF_VALOR)
else
	cCondInt:="F"
Endif              

dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_PRODUPL") //Habilita ou nao a duplicacao de produtos no pedido (T ou F)
if !Eof()
	cProDupl := AllTrim(HCF->CF_VALOR)
else
	cProDupl := "F"
Endif              

If cCondInt == "T" .And. !Empty(cCond)
	cTabPrc := RGCondInt(aCabNot[3,1],aCabNot[4,1],cCond)
Else
	If HA1->(FieldPos("A1_TABELA")) <> 0
		cTabPrc := Alltrim(HA1->A1_TABELA)
	Endif
Endif

// Consulta Condicao de Pagamento 
Aadd(aCmpPag,{STR0001,HE4->(FieldPos("E4_COD")),30}) //"CÛdigo"
Aadd(aCmpPag,{STR0002,HE4->(FieldPos("E4_DESCRI")),70}) //"DescriÁ„o"
Aadd(aIndPag,{STR0001,1}) //"CÛdigo"

//Consulta Tabela de Preco
Aadd(aCmpTab,{STR0001,HTC->(FieldPos("TC_TAB")),30}) //"CÛdigo"
Aadd(aCmpTab,{STR0002,HTC->(FieldPos("TC_DESCRI")),100}) //"DescriÁ„o"
Aadd(aIndTab,{STR0001,1}) //"CÛdigo"

//Consulta Transportadora
Aadd(aCmpTra,{STR0001,HA4->(FieldPos("A4_COD")),40}) //"CÛdigo"
Aadd(aCmpTra,{STR0003,HA4->(FieldPos("A4_NOME")),100}) //"Nome"
Aadd(aIndTra,{STR0001,1}) //"CÛdigo"

//Consulta Forma de Pagamento
Aadd(aCmpFpg,{STR0001,HTP->(FieldPos("X5_CHAVE")),10}) //"CÛdigo"
Aadd(aCmpFpg,{STR0004,HTP->(FieldPos("X5_DESCRI")),60}) //"Descricao"
Aadd(aIndFpg,{STR0001,1}) //"CÛdigo"

If aCabNot[2,1] = 1 .Or. aCabNot[2,1] = 4

	DEFINE DIALOG oDlg TITLE STR0005 //"Inclus„o da Nota"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo pedido)
	If aCabNot[2,1] = 1
		aCabNot[6,1] := cCond
		aCabNot[7,1] := cTabPrc
		aCabNot[26,1]:= cTransp
	Endif
Else 
	DEFINE DIALOG oDlg TITLE STR0006 //"AlteraÁ„o da Nota"
EndIf

@ 15,05 GET oObj VAR cCliente SIZE 157,15 READONLY MULTILINE OF oDlg
AADD(aObj[1],oObj) 
@ 130,71 BUTTON oObj CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION NFGravarNF(aCabNot,aIteNot,aColItenf,cCondInt,cSfaInd,cCF,cGeraDup) SIZE 40,12 OF oDlg
AADD(aObj[1],oObj) 
@ 130,116 BUTTON oObj CAPTION BTN_BITMAP_CANCEL SYMBOL  ACTION NFFechaNF(aCabNot[2,1],aCabNot[1,1]) SIZE 40,12 OF oDlg
AADD(aObj[1],oObj) 
@ 130,2 SAY "T:"  of oDlg
#ifdef __PALM__
	@ 130,20 GET oObj VAR aCabNot[16,1] READONLY SIZE 40,12 of oDlg
	AADD(aObj[1],oObj) 
#else
	@ 130,20 GET oObj VAR aCabNot[16,1] READONLY SIZE 52,12 of oDlg
	AADD(aObj[1],oObj) 
#endif

ADD FOLDER oCabNf CAPTION STR0007 OF oDlg //"Principal Nf"
@ 30,01 TO 127,158 CAPTION STR0007 OF oCabNf //"Principal Nf"
// Condicao de Pagamento
@ 40,42 GET oObj VAR aCabNot[6,1] READONLY SIZE 25,12 of oCabNf
AADD(aObj[2],oObj)
@ 40,03 BUTTON oObj CAPTION STR0008 SIZE 34,10 ACTION NFCondNF(aCabNot,aObj,aCmpPag,aIndPag,aColItenf,aIteNot,cCondInt) of oCabNf  //"Pagto:"
AADD(aObj[2],oObj)
// Tabela de Preco
@ 40,119 GET oObj VAR aCabNot[7,1] READONLY SIZE 25,12 of oCabNf
AADD(aObj[2],oObj)
@ 40,80 BUTTON oObj CAPTION STR0009 SIZE 34,10 ACTION PVTrocaTab(aCabNot,aObj,aCmpTab,aIndTab,aColItenf,aIteNot,cCondInt) of oCabNf //"Tabela:"
AADD(aObj[2],oObj)
// Data de Entrega
//@ 54,42 GET oObj VAR aCabNot[10,1] READONLY SIZE 50,12 of oCabNf
//AADD(aObj[2],oObj)
//@ 54,03 BUTTON oObj CAPTION "Entrg.:" SIZE 34,10 ACTION PVDtEntr(aCabNot[10,1],aObj[2,5]) of oCabNf
AADD(aObj[2],oObj)
// Transportadora
@ 68,42 GET oObj VAR aCabNot[26,1] READONLY SIZE 50,12 of oCabNf
AADD(aObj[2],oObj)
@ 68,03 BUTTON oObj CAPTION STR0010 SIZE 34,10 ACTION SFConsPadrao("HA4",aCabNot[26,1],aObj[2,6],aCmpTra,aIndTra) of oCabNf //"Transp:"
AADD(aObj[2],oObj)

// Forma de Pagamento
HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFAFPG"))
	cSfaFpg := HCF->CF_VALOR
Else 
	cSfaFpg := "F"
EndIf	
If cSfaFpg = "T"
	@ 82,03 BUTTON oObj CAPTION STR0011 SIZE 34,10 ACTION SFConsPadrao("HTP",aCabNot[43,1],aObj[2,10],aCmpFpg,aIndFpg) of oCabNf //"F.Pagto"
	AADD(aObj[2],oObj)
	@ 82,42 GET oObj VAR aCabNot[15,1] SIZE 50,12 of oCabNf
	AADD(aObj[2],oObj)
EndIf

// Indenizacao
HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFAIND"))
	cSfaInd := AllTrim(HCF->CF_VALOR)
Else 
	cSfaInd := "F"
EndIf	

If cSfaInd == "T"
	@ 96,03 SAY STR0012 OF oCabNf //"Inden:"
	AADD(aObj[2],oObj)
	@ 96,42 GET oObj VAR aCabNot[14,1] VALID ChkIndeni(aCabNot) SIZE 50,12 of oCabNf
	//VALID (aCabNot[14,1] < aCabNot[11,1])
	AADD(aObj[2],oObj)
EndIf

// Tipo de Frete
HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFAFRE"))
	cSfaFre := AllTrim(HCF->CF_VALOR)
Else 
	cSfaFre := "F"
EndIf	
 
If cSfaFre == "T"
	@ 110,03 SAY STR0013 OF oCabNf //"Frete:"
	AADD(aObj[2],oObj)
	@ 110,42 COMBOBOX oObj VAR nOpcFre ITEMS aTpFrete ACTION UpdTpFrete(aCabNot, aTpFrete, nOpcFre) SIZE 50,40 of oCabNf
	AADD(aObj[2],oObj)
EndIf

ADD FOLDER oDetnf CAPTION STR0014 OF oDlg //"Detalhe"
@ 30,01 TO 127,158 CAPTION STR0014 OF oDetnf //"Detalhe"
@ 40,03 BROWSE oBrwIteNf SIZE 134,82 of oDetnf
SET BROWSE oBrwIteNf ARRAY aIteNot
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  1 HEADER STR0015 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  2 HEADER STR0016 WIDTH 130   //"Descr."
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  4 HEADER STR0017 WIDTH 35 //"Qtde"
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  6 HEADER STR0018 WIDTH 35 //"Preco"
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT 15 HEADER STR0019 WIDTH 35 //"Vlr Total"
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  7 HEADER STR0020 WIDTH 35 //"Desc."
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  9 HEADER STR0021 WIDTH 45 //"Vlr LÌquido"
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  6 HEADER STR0022 WIDTH 35 //"Icms"
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  7 HEADER STR0023 WIDTH 35 //"Ipi"
ADD COLUMN oCol TO oBrwIteNf ARRAY ELEMENT  7 HEADER STR0024 WIDTH 35 //"Valor IPI"
AADD(aObj[3],oBrwIteNf)

@ 40,140 BUTTON oObj CAPTION "N" SIZE 16,12 ACTION NFIteNot(1,aIteNot, @nIteNot, aColItenf, aCabNot,aObj,cManTes,cManPrc,cBloqPrc,cProDupl) of oDetnf
AADD(aObj[3],oObj)
@ 54,140 BUTTON oObj CAPTION STR0025 SIZE 16,12 of oDetnf //"A"
//@ 54,140 BUTTON oObj CAPTION "A" SIZE 16,12 ACTION PVItePed(2,aIteNot, @nIteNot, aColItenf, aCabNot,aObj,cManTes,cManPrc,cBloqPrc,cProDupl) of oDetnf
AADD(aObj[3],oObj)
@ 68,140 BUTTON oObj CAPTION STR0026 SIZE 16,12 of oDetnf //"E"
//@ 68,140 BUTTON oObj CAPTION "E" SIZE 16,12 ACTION PVExcIte(aIteNot,@nIteNot, aCabNot,aObj, .F.) of oDetnf
AADD(aObj[3],oObj)

// Nao tem onde gravar observacao na nota (por enquanto)
//ADD FOLDER oObsNf CAPTION "Obs" OF oDlg
//@ 30,01 TO 127,158 CAPTION "ObservaÁ„o" OF oObsNf
//@ 40,05 GET oObj VAR aCabNot[9,1] MULTILINE VSCROLL SIZE 140,80 of oObsNf
//AADD(aObj[4],oObj)                                                       

aadd( aImpostos,{ STR0027,0} ) //"Base de Calculo ICMS "
aadd( aImpostos,{ STR0028,0} ) //"Valor do ICMS        "
aadd( aImpostos,{ STR0029,0} ) //"Base Calc.Icms Subs. "
aadd( aImpostos,{ STR0030,0} ) //"Valor do Icms  Subs. "
aadd( aImpostos,{ STR0031,0} ) //"Valor total Produtos "
aadd( aImpostos,{ STR0032,0} ) //"Valor total do IPI   "
aadd( aImpostos,{ STR0033,0} ) //"Valor total da Nota  "


ADD FOLDER oImpsNf CAPTION STR0034 OF oDlg //"Impostos"
@ 31,01 TO 127,158 CAPTION STR0035 OF oImpsNf //"Impostos da nf"
@ 37,02 BROWSE oBrwImp SIZE 155,82 of oImpsNf
SET BROWSE oBrwImp ARRAY aImpostos
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 1 HEADER STR0004 WIDTH 85 //"Descricao"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 2 HEADER STR0036 WIDTH 50 //"Valor    "
AADD(aObj[3],oBrwImp)

ACTIVATE DIALOG oDlg

Return Nil