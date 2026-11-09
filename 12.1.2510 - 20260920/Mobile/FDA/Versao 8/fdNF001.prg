/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± < INDICE DAS FUNCOES  > ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
±±
±± @1.  InitPV -> Modulo principal do Pedido
±± @2.  PVItePed -> Modulo de Item do Pedido
±± @3.  Acoes dos Botoes 
±± @3A. PVQTde -> Chamada do Keyboard para o Campo Qtde.
±± @3B. PVPrc -> Chamada do Keyboard para o Campo Preco.
±± @6A. PVDtEntr -> Data de Entrega ( BUTTON ENTREGA )
±± @6B. PVProduto -> Carrega o Modulo de Produtos( BUTTON PRODUTO )
±± @6C. PVObs -> Carrega o Memo de Observacao ( BUTTON OBS )
±± @6D. PVFecha -> Fecha o Modulo de Pedidos ( BUTTON CANCELAR )
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 

   
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ Pedidos de Venda    ≥Autor - Paulo Lima   ≥ Data ≥27/06/02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Modulo de Pedidos        					 			  ≥±±
±±≥			 ≥ InitPedido -> Inicia o Mod. de Pedidos		 			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFA CRM 6.0                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥NOperacao 1- Inclusao /2 - Alteracao / 3 - Ult.Pedido(Cons.)¥±±
±±≥			 ≥4 - Ult.Pedido (Gerar Novo Pedido)   	     		 		  ¥±±
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

Function InitNF(aCabNot,aIteNot,aCond,aTab,aColIteNF)
Local oDlg,oCab,oObs,oObj,oBrwIteNot,oDet
Local aObj := { {},{},{},{},{} }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := ""
Local nItePed:=0
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := ""
Local cSfaFre := "", aTpFrete := {"CIF", "FOB"}, nOpcFre := 2

dbSelectArea("HA1")
dbSetorder(1)
dbSeek(RetFilial("HA1")+aCabNot[3,1]+aCabNot[4,1])
cCliente:=HA1->HA1_COD + "/" + HA1->HA1_LOJA + " - " + HA1->HA1_NOME
cCond 	:= Alltrim(HA1->HA1_COND) 
If HA1->(FieldPos("A1_TRANSP")) <> 0
	cTransp := Alltrim(HA1->HA1_TRANSP)
EndIf

dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF")+"MV_SFAMTES")//Permite ou nao ao vendedor manipular a TES
if !eof()
	cManTes:=AllTrim(HCF->HCF_VALOR)
else
	cManTes:="N"
Endif              

dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF")+"MV_SEMPREC")//Permite ou nao ao vendedor digitar o preco (quando nao houver)
if !eof()
	cManPrc:=AllTrim(HCF->HCF_VALOR)
else
	cManPrc:="N"
Endif

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek(RetFilial("HCF")+"MV_BLOQPRC")//Bloqueio do campo preco
if !eof()
	cBloqPrc := AllTrim(HCF->HCF_VALOR)
else
	cBloqPrc :=	"S"
endif
                   
dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF")+"MV_SFCONDI")//Habilita ou nao a cond. de pagto. inteligente (T ou F)
if !eof()
	cCondInt:=AllTrim(HCF->HCF_VALOR)
else
	cCondInt:="F"
Endif              

dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF")+"MV_PRODUPL") //Habilita ou nao a duplicacao de produtos no pedido (T ou F)
if !Eof()
	cProDupl := AllTrim(HCF->HCF_VALOR)
else
	cProDupl := "F"
Endif              


If cCondInt == "T" .And. !Empty(cCond)
	cTabPrc := RGCondInt(aCabNot[3,1],aCabNot[4,1],cCond)
Else
	If HA1->(FieldPos("A1_TABELA")) <> 0
		cTabPrc := Alltrim(HA1->HA1_TABELA)
	Endif
Endif

// Consulta Condicao de Pagamento 
Aadd(aCmpPag,{"CÛdigo",HE4->(FieldPos("E4_COD")),30})
Aadd(aCmpPag,{"DescriÁ„o",HE4->(FieldPos("E4_DESCRI")),70})
Aadd(aIndPag,{"CÛdigo",1})

//Consulta Tabela de Preco
Aadd(aCmpTab,{"CÛdigo",HTC->(FieldPos("TC_TAB")),30})
Aadd(aCmpTab,{"DescriÁ„o",HTC->(FieldPos("TC_DESCRI")),100})
Aadd(aIndTab,{"CÛdigo",1})

//Consulta Transportadora
Aadd(aCmpTra,{"CÛdigo",HA4->(FieldPos("A4_COD")),40})
Aadd(aCmpTra,{"Nome",HA4->(FieldPos("A4_NOME")),100})
Aadd(aIndTra,{"CÛdigo",1})

//Consulta Forma de Pagamento
Aadd(aCmpFpg,{"CÛdigo",HTP->(FieldPos("X5_CHAVE")),10})
Aadd(aCmpFpg,{"Descricao",HTP->(FieldPos("X5_DESCRI")),60})
Aadd(aIndFpg,{"CÛdigo",1})

If aCabNot[2,1] = 1 .Or. aCabNot[2,1] = 4
	DEFINE DIALOG oDlg TITLE "Inclus„o do Pedido"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo pedido)
	If aCabNot[2,1] = 1
		aCabNot[7,1] := cCond
		aCabNot[8,1] := cTabPrc
		aCabNot[13,1]:= cTransp
	Endif
Else 
	DEFINE DIALOG oDlg TITLE "AlteraÁ„o do Pedido"
EndIf

@ 15,05 GET oObj VAR cCliente SIZE 157,15 READONLY MULTILINE OF oDlg
AADD(aObj[1],oObj) 
@ 130,71 BUTTON oObj CAPTION "Gravar"  ACTION PVGravarPed(aCabNot,aItePed,aColIte,cCondInt,cSfaInd) SIZE 40,12 OF oDlg
AADD(aObj[1],oObj) 
@ 130,116 BUTTON oObj CAPTION "Cancelar" ACTION PVFecha(aCabNot[2,1]) SIZE 40,12 OF oDlg
AADD(aObj[1],oObj) 
@ 130,2 SAY "T:"  of oDlg
#ifdef __PALM__
	@ 130,20 GET oObj VAR aCabNot[12,1] READONLY SIZE 40,12 of oDlg
	AADD(aObj[1],oObj) 
#else
	@ 130,20 GET oObj VAR aCabNot[12,1] READONLY SIZE 52,12 of oDlg
	AADD(aObj[1],oObj) 
#endif

ADD FOLDER oCab CAPTION "Principal" OF oDlg
@ 30,01 TO 127,158 CAPTION "Principal" OF oCab
// Condicao de Pagamento
@ 40,42 GET oObj VAR aCabNot[7,1] READONLY SIZE 25,12 of oCab
AADD(aObj[2],oObj)
@ 40,03 BUTTON oObj CAPTION "Pagto:" SIZE 34,10 ACTION PVCond(aCabNot,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt) of oCab 
AADD(aObj[2],oObj)
// Tabela de Preco
@ 40,119 GET oObj VAR aCabNot[8,1] READONLY SIZE 25,12 of oCab
AADD(aObj[2],oObj)
@ 40,80 BUTTON oObj CAPTION "Tabela:" SIZE 34,10 ACTION PVTrocaTab(aCabNot,aObj,aCmpTab,aIndTab,aColIte,aItePed,cCondInt) of oCab
AADD(aObj[2],oObj)

// Data de Entrega
@ 54,42 GET oObj VAR aCabNot[10,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 54,03 BUTTON oObj CAPTION "Entrg.:" SIZE 34,10 ACTION PVDtEntr(aCabNot[10,1],aObj[2,5]) of oCab
AADD(aObj[2],oObj)
// Transportadora
@ 68,42 GET oObj VAR aCabNot[13,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 68,03 BUTTON oObj CAPTION "Transp:" SIZE 34,10 ACTION SFConsPadrao("HA4",aCabNot[13,1],aObj[2,7],aCmpTra,aIndTra) of oCab
AADD(aObj[2],oObj)

// Forma de Pagamento
HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF")+"MV_SFAFPG"))
	cSfaFpg := HCF->HCF_VALOR
Else 
	cSfaFpg := "F"
EndIf	
If cSfaFpg = "T"
	@ 82,03 BUTTON oObj CAPTION "F.Pagto" SIZE 34,10 ACTION SFConsPadrao("HTP",aCabNot[15,1],aObj[2,10],aCmpFpg,aIndFpg) of oCab
	AADD(aObj[2],oObj)
	@ 82,42 GET oObj VAR aCabNot[15,1] SIZE 50,12 of oCab
	AADD(aObj[2],oObj)
EndIf

// Indenizacao
HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF")+"MV_SFAIND"))
	cSfaInd := AllTrim(HCF->HCF_VALOR)
Else 
	cSfaInd := "F"
EndIf	

If cSfaInd == "T"
	@ 96,03 SAY "Inden:" OF oCab
	AADD(aObj[2],oObj)
	@ 96,42 GET oObj VAR aCabNot[14,1] VALID ChkIndeni(aCabNot) SIZE 50,12 of oCab
	//VALID (aCabNot[14,1] < aCabNot[11,1])
	AADD(aObj[2],oObj)
EndIf


// Tipo de Frete
HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF")+"MV_SFAFRE"))
	cSfaFre := AllTrim(HCF->HCF_VALOR)
Else 
	cSfaFre := "F"
EndIf	
 
If cSfaFre == "T"
	@ 110,03 SAY "Frete:" OF oCab
	AADD(aObj[2],oObj)
	@ 110,42 COMBOBOX oObj VAR nOpcFre ITEMS aTpFrete ACTION UpdTpFrete(aCabNot, aTpFrete, nOpcFre) SIZE 50,40 of oCab
	AADD(aObj[2],oObj)
EndIf

ADD FOLDER oDet CAPTION "Detalhe" OF oDlg
@ 30,01 TO 127,158 CAPTION "Detalhe" OF oDet
@ 40,03 BROWSE oBrwIteNot SIZE 134,82 of oDet
SET BROWSE oBrwIteNot ARRAY aItePed
ADD COLUMN TO oBrwIteNot ARRAY ELEMENT 1 HEADER "Produto" WIDTH 50
ADD COLUMN TO oBrwIteNot ARRAY ELEMENT 2 HEADER "Descr." WIDTH 130  //Acresc. 11/06/03
ADD COLUMN TO oBrwIteNot ARRAY ELEMENT 4 HEADER "Qtde" WIDTH 35
ADD COLUMN TO oBrwIteNot ARRAY ELEMENT 6 HEADER "Preco" WIDTH 35
ADD COLUMN TO oBrwIteNot ARRAY ELEMENT 7 HEADER "Desc." WIDTH 35
ADD COLUMN TO oBrwIteNot ARRAY ELEMENT 9 HEADER "Sub Tot." WIDTH 45
AADD(aObj[3],oBrwIteNot)

ADD FOLDER oDet CAPTION "Impostos" OF oDlg

@ 40,140 BUTTON oObj CAPTION "N" SIZE 16,12 ACTION PVItePed(1,aItePed, @nItePed, aColIte, aCabNot,aObj,cManTes,cManPrc,cBloqPrc,cProDupl) of oDet
AADD(aObj[3],oObj)
@ 54,140 BUTTON oObj CAPTION "A" SIZE 16,12 ACTION PVItePed(2,aItePed, @nItePed, aColIte, aCabNot,aObj,cManTes,cManPrc,cBloqPrc,cProDupl) of oDet
AADD(aObj[3],oObj)
@ 68,140 BUTTON oObj CAPTION "E" SIZE 16,12 ACTION PVExcIte(aItePed,@nItePed, aCabNot,aObj, .F.) of oDet
AADD(aObj[3],oObj)

ADD FOLDER oObs CAPTION "Obs" OF oDlg
@ 30,01 TO 127,158 CAPTION "ObservaÁ„o" OF oObs
@ 40,05 GET oObj VAR aCabNot[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
AADD(aObj[4],oObj)

ADD FOLDER oObs CAPTION "Impostos" OF oDlg
@ 30,01 TO 127,158 CAPTION "Impostos" OF oObs
@ 40,05 GET oObj VAR aCabNot[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
AADD(aObj[4],oObj)

ACTIVATE DIALOG oDlg

Return Nil