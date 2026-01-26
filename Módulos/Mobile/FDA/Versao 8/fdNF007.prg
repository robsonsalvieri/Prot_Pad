#INCLUDE "FDNF007.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Nota fiscal venda2  ³Autor -M.Vieira      ³ Data ³21/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Notas    					 			          ³±±
±±³			 ³ InitNF2 -> Inicia o Mod. de Notas Versao 2	 		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0.1                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³NOperacao 1- Inclusao /2 - Alteracao /                      ´±±
±±³			     ³                                  	     		 	  ´±±
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

Function InitNF2(aCabNot,aIteNot,aCond,aTab,aColIteNf,cGeraDup)

Local oDlg,oCab,oFldProd,oObj,oBrwProd,oPrecos
Local aObj := { {},{},{},{},{} }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := ""
Local cCodCLi:="" ,cCliLoja :="", Ctes:="",nIVa:=0,lvenda:=.f.
Local nIteNot:=0, nOpIte := 1 //depois tirar
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := "", cSfaFpgIni := ""
Local cFrete := "", cSfaFre := "", aTpFrete := {"CIF", "FOB"} 
Local nOpcFre :=1 // If(aCabNot[43,1]="C",1,2)
Local aPrdPrefix := {}
Local nPos := 0, oUp,oDown,oLeft,oRight
Local oCol,oBtnTes,oTxtTes,oBtnOK,oBtnExcluir
Local cDesc := "", cCod := "", oGrupo
Local cDescD := "",cCF:=""
Local cUN := "", nQTD := 0, nEnt := 0, nDescMax := 0
Local nICM := 0, nIPI := 0, cEst := space(40), nPrc:=0.00 , oBrw
Local oCtrl, aControls := { {},{},{} }
Local oDet, oCod, oDesc, cPesq := Space(40), lCodigo:=.t., lDesc:=.f.
Local aPrecos := {}, nTop := 0
Local aCmpTes:={},aIndTes:={}
Local oSaldoEst,nSaldoEst:=0
//Local oFldImp,oBrwImp,oBrwCab 
cCodCLi  :=HA1->HA1_COD 
cCliLoja :=HA1->HA1_LOJA 
// Configura parametros
//SetParam(aCabNot[4,1],aCabNot[5,1], cCliente, cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, @cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix)
SetParam(cCodCli,cCliLoja, @cCliente, cCond,cTes,nIVA,cProDupl,aPrdPrefix,lVenda)
cManTes:=GetParam("MV_SFAMTES","N")
cBloqPrc:=GetParam("MV_BLOQPRC","S")

//Prepara/inicia arrays
MontaColItenf(aColIteNF)
NFMontaArrays(aCmpPag,aIndPag,aCmpTab,aIndTab,aCmpTra,aIndTra,aCmpFpg,aIndFpg,aCmpTes,aIndTes)

aSize(aProduto,0)
If aCabNot[2,1] = 1 .Or. aCabNot[2,1] = 4
	DEFINE DIALOG oDlg TITLE STR0001 //"Inclusão de NF"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. nova nf)
	If  aCabNot[2,1] = 1
		aCabNot[6,1] := cCond
		aCabNot[7,1] := HA1->HA1_TABELA //cTabPrc
   	aCabNot[9,1] := Date()
		aCabNot[26,1]:= HA1->HA1_TRANSP //cTransp 
		aCabNot[43,1]:= cFrete
		aCabNot[44,1]:= cSfaFpgIni
		nOpcFre      := If(aCabNot[43,1]="C",1,2)
	Endif
Else 
	DEFINE DIALOG oDlg TITLE STR0002 //"Alteração da NF"
EndIf

//Folder Principal (Cabec. do Pedido)
ADD FOLDER oCab CAPTION STR0003 OF oDlg //"Principal"
@ 35,01 TO 139,158 CAPTION STR0003 OF oCab //"Principal"
@ 18,03 GET oObj VAR cCliente SIZE 150,12 READONLY MULTILINE OF oCab
AADD(aObj[1],oObj) // 1 - Label Cliente    
#ifdef __PALM__
	@ 123,71 BUTTON oObj CAPTION  BTN_BITMAP_GRAVAR SYMBOL ;
    ACTION NFGravarNf(aCabNot,aIteNot,aColItenf,cCondInt,cSfaInd,cSfaFpg,cCF,cGeraDup) SIZE 40,12 OF oCab
#else 
	@ 123,71 BUTTON oObj CAPTION  STR0004 ; //"Gravar"
    ACTION NFGravarNf(aCabNot,aIteNot,aColItenf,cCondInt,cSfaInd,cSfaFpg,cCF,cGeraDup) SIZE 40,12 OF oCab
#endif
AADD(aObj[1],oObj) // 2 - Botao Gravar
#ifdef __PALM__
	@ 123,116 BUTTON oObj CAPTION BTN_BITMAP_CANCEL SYMBOL ACTION NFFechaNf(aCabNot[2,1],aCabNot[1,1]) SIZE 40,12 OF oCab
	AADD(aObj[1],oObj) // 3 - Botao Cancelar
	@ 125,2 SAY "T:"  of oCab
	@ 125,20 GET oObj VAR aCabNot[35,1] Picture "@E 9,999,999.99" READONLY SIZE 40,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#else
	@ 123,116 BUTTON oObj CAPTION STR0005 ACTION NFFechaNf(aCabNot[2,1],aCabNot[1,1]) SIZE 40,12 OF oCab //"Cancela"
	AADD(aObj[1],oObj) // 3 - Botao Cancelar
	@ 125,2 SAY "T:"  of oCab
	@ 125,20 GET oObj VAR aCabNot[35,1] Picture "@E 9,999,999.99" READONLY SIZE 52,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#endif

// Condicao de Pagamento
@ 40,42 GET oObj VAR aCabNot[6,1] READONLY SIZE 28,12 of oCab
AADD(aObj[2],oObj)
@ 40,03 BUTTON oObj CAPTION STR0006 SIZE 34,10 ACTION NFCond(aCabNot,aObj,aCmpPag,aIndPag,aColItenf,aIteNot,cCondInt) of oCab  //"Pagto:"
AADD(aObj[2],oObj)
// Tabela de Preco
@ 40,119 GET oObj VAR aCabNot[7,1] READONLY SIZE 28,12 of oCab
AADD(aObj[2],oObj)
@ 40,80 BUTTON oObj CAPTION STR0007 SIZE 34,10 ACTION NFTrocaTab(aCabNot,aObj,aCmpTab,aIndTab,aColItenf,aIteNot,cCondInt) of oCab //"Tabela:"
AADD(aObj[2],oObj)

// Data de Entrega
@ 54,42 GET oObj VAR aCabNot[9,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 54,03 BUTTON oObj CAPTION STR0008 SIZE 34,10 ACTION PVDtEntr(aCabNot[9,1],aObj[2,5]) of oCab //"Entrg.:"
AADD(aObj[2],oObj)
// Transportadora
@ 68,42 GET oObj VAR aCabNot[26,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 68,03 BUTTON oObj CAPTION STR0009 SIZE 34,10 ACTION SFConsPadrao("HA4",aCabNot[26,1],aObj[2,7],aCmpTra,aIndTra,) of oCab //"Transp:"
AADD(aObj[2],oObj)

cSfaFpg := GetParam("MV_SFAFPG","F")
If cSfaFpg == "T"
	//Forma de Pagto.
	@ 82,03 BUTTON oObj CAPTION STR0010 SIZE 34,10 ACTION SFConsPadrao("HTP",aCabNot[44,1],aObj[2,10],aCmpFpg,aIndFpg,) of oCab //"F.Pagto"
	AADD(aObj[2],oObj)
	@ 82,42 GET oObj VAR aCabNot[44,1] SIZE 50,12 of oCab
	AADD(aObj[2],oObj)
EndIf

// Indenizacao
cSfaInd := GetParam("MV_SFAIND","F")
If cSfaInd == "T"
	@ 96,03 SAY STR0011 OF oCab //"Inden:"
	AADD(aObj[2],oObj)
	@ 96,42 GET oObj VAR aCabNot[14,1] VALID ChkIndeni(aCabNot) SIZE 50,12 of oCab
	AADD(aObj[2],oObj)
EndIf

// Tipo de Frete
cSfaFre := GetParam("MV_SFAFRE","F")
If cSfaFre == "T"
	@ 110,03 SAY STR0012 OF oCab //"Frete:"
	AADD(aObj[2],oObj)
    @ 110,42 COMBOBOX oObj VAR nOpcFre ITEMS aTpFrete ACTION NFTpFrete(aCabNot, aTpFrete, nOpcFre) SIZE 50,40 of oCab
	AADD(aObj[2],oObj)
EndIf

//Folder (Browse de Itens/Produtos)
ADD FOLDER oFldProd CAPTION STR0013 OF oDlg //"Itens"
@ 18,2 SAY STR0014 OF oFldProd //"Grupo:"
@ 18,32 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION NFGRUPO(aGrupo,nGrupo,oBrwProd,@nTop,.t.,aIteNot,lcodigo) SIZE 125,50 OF oFldProd

@ 30,03 BROWSE oBrwProd SIZE 138,50 NO SCROLL ACTION NFSeleciona(oBrwProd,aColItenf,aIteNot,@nIteNot,aCabNot,aObj,cManPrc,cManTes,@nOpIte,oSaldoEst,@nsaldoEst) of oFldProd
SET BROWSE oBrwProd ARRAY aProduto            

ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0015 WIDTH 135 //"Descr."
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0016 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0017 WIDTH 35 //"Qtde"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 4 HEADER STR0018 WIDTH 35 ALIGN RIGHT //"Preco"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 5 HEADER STR0019 WIDTH 35 ALIGN RIGHT //"Desc."
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 6 HEADER STR0020 WIDTH 35 ALIGN RIGHT //"Vlr ICM"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 7 HEADER STR0021 WIDTH 35 ALIGN RIGHT //"Vlr IPI"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 8 HEADER STR0022 WIDTH 40 ALIGN RIGHT //"Total  "
AADD(aObj[3],oBrwProd) // 1 - Browse de Produtos

@ 30,142 BUTTON oUp CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION NFSobe(aGrupo,nGrupo,oBrwProd,@nTop,aIteNot,lcodigo) OF oFldProd
@ 47,142 BUTTON oLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oBrwProd) OF oFldProd
@ 62,142 BUTTON oRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oBrwProd) OF oFldProd
@ 77,142 BUTTON oDown CAPTION DOWN_ARROW SYMBOL  SIZE 12,10 ACTION NFDesce(aGrupo,nGrupo,oBrwProd,@nTop,aIteNot) OF oFldProd

@ 80,03 SAY STR0023 OF oFldProd //"Saldo:"
@ 80,35 SAY oSaldoEst VAR nSaldoEst OF oFldProd

@ 92,03 BUTTON oObj CAPTION STR0024 ACTION NFQTde(aObj[3,3]) SIZE 30,11 of oFldProd //"Qtde."
AADD(aObj[3],oObj) // 2 - Botao Quantidade
@ 92,40 GET oObj VAR aColItenf[6,1] SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 3 - Get Quantidade

If cBloqPrc == "S"	//Bloqueia campo Preco
	@ 93,080 BUTTON oObj CAPTION STR0025 SIZE 33,11 of oFldProd //"Preço"
	AADD(aObj[3],oObj) // 4 - Botao Preco
	@ 93,115 GET oObj VAR aColItenf[23,1] PICTURE "@E 9,999.99" READONLY SIZE 40,15 of oFldProd
	AADD(aObj[3],oObj) // 5 - Get Preco
Else
	@ 93,080 BUTTON oObj CAPTION STR0025 ACTION NFPrc(aObj[3,5]) SIZE 33,11 of oFldProd //"Preço"
	AADD(aObj[3],oObj) // 4 - Botao Preco
	@ 92,115 GET oObj VAR aColItenf[23,1] PICTURE "@E 9,999.99" SIZE 40,15 of oFldProd
	AADD(aObj[3],oObj) // 5 - Get Preco                                                            
Endif
@ 107,03 BUTTON oObj CAPTION STR0026 ACTION NFDesc(aObj[3,7]) SIZE 30,11 of oFldProd //"Desc"
AADD(aObj[3],oObj) // 6 - Botao Desconto
@ 107,40 GET oObj VAR aColItenf[13,1] PICTURE "@E 9,999.99" SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 7 - Get Desconto

If cManTes == "S"	//Permite a manipulacao da TES
	@ 107,080 BUTTON oBtnTes CAPTION STR0027 ACTION SFConsPadrao("HF4",aColItenf[11,1],aObj[3,9],aCmpTes,aIndTes,) SIZE 33,11 of oFldProd //"Tes"
	@ 107,115 GET oTxtTes VAR aColItenf[11,1] READONLY SIZE 35,15 of oFldProd
	AADD(aObj[3],oBtnTes) // 8 - Botao TES
	AADD(aObj[3],oTxtTes) // 9 - Get TES
	#ifdef __Palm__ 
    	@ 01,075 BUTTON oBtnOK CAPTION BTN_BITMAP_PLUS SYMBOL ACTION NFGrvIte(aColItenf,aIteNot, nIteNot, aCabNot,aObj,@cManTes,cProDupl,nOpIte,2,@cCF,@cGeraDup,oSaldoEst,nSaldoEst) of oFldProd
    	@ 01,125 BUTTON oBtnExcluir CAPTION BTN_BITMAP_MINUS SYMBOL ACTION NFExcIte(aIteNot,@nIteNot,aCabNot,aObj,.F.,2,oSaldoEst,nSaldoEst) of oFldProd
	#else 
		@ 01,075 BUTTON oBtnOK CAPTION "+" ACTION NFGrvIte(aColItenf,aIteNot, nIteNot, aCabNot,aObj,@cManTes,cProDupl,nOpIte,2,@cCF,@cGeraDup,oSaldoEst,nSaldoEst) of oFldProd
    	@ 02,125 BUTTON oBtnExcluir CAPTION "-" ACTION NFExcIte(aIteNot,@nIteNot,aCabNot,aObj,.F.,2,oSaldoEst,nSaldoEst) of oFldProd
	#endif    	
Else
	AADD(aObj[3],"") // 8 - Botao TES
	AADD(aObj[3],"") // 9 - Get TES
	#ifdef __Palm__ 
		@ 108,085 BUTTON oBtnOK CAPTION BTN_BITMAP_PLUS SYMBOL ACTION NFGrvIte(aColItenf,aIteNot, nIteNot, aCabNot,aObj,@cManTes,cProDupl,nOpIte,2,@cCF,@cGeraDup,oSaldoEst,nSaldoEst) of oFldProd
    	@ 108,130 BUTTON oBtnExcluir CAPTION BTN_BITMAP_MINUS SYMBOL ACTION NFExcIte(aIteNot,@nIteNot,aCabNot,aObj,.F.,2,oSaldoEst,nSaldoEst) of oFldProd	
	#else 
		@ 107,085 BUTTON oBtnOK CAPTION "+" ACTION NFGrvIte(aColItenf,aIteNot, nIteNot, aCabNot,aObj,@cManTes,cProDupl,nOpIte,2,@cCF,@cGeraDup,oSaldoEst,nSaldoEst) of oFldProd
    	@ 107,120 BUTTON oBtnExcluir CAPTION "-" ACTION NFExcIte(aIteNot,@nIteNot,aCabNot,aObj,.F.,2,oSaldoEst,nSaldoEst) of oFldProd	
	#endif      
Endif
	
@ 122,3 GET oObj VAR aColItenf[2,1] MULTILINE READONLY NO UNDERLINE SIZE 150,22 OF oFldProd
AADD(aObj[3],oObj) // 10 - Get Descricao

//@ 130,85 BUTTON oBtnOK CAPTION "OK" SIZE 33,11 ACTION NFGrvIte(aColItenf,aIteNot, nItePed, aCabNot,aObj,@cManTes,cProDupl,nOpIte,2) of oFldProd
//@ 130,125 BUTTON oBtnExcluir CAPTION "Excluir" SIZE 33,11 ACTION NFExcIte(aIteNot,@nItePed,aCabNot,aObj,.F.,2) of oFldProd

NFGRUPO(aGrupo,1,oBrwProd,@nTop,.f.,aIteNot,lcodigo)

//Folder Impostos
//ADD FOLDER oFldImp CAPTION "Impostos" ON ACTIVATE IniCalc(oBrwImp,oBrwCab,aCabImp,aFdaNfCab,aFdaNfItem,aCabNot,aIteNot) OF oDlg
//NFFldImp(oBrwImp,oBrwCab,oFldImp,aCabImp,aFdaNfCab,aFdaNfItem,aCabNot,aIteNot) 

//Folder (Detalhes do produto)
ADD FOLDER oDet CAPTION STR0028 ON ACTIVATE NFSetDetalhes(oBrwProd,aControls,@cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax) Of oDlg //"Detalhe"
NFFldDetalhe(oBrwProd,aIteNot,@nTop,oDet,aControls,oCtrl,cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax,aPrdPrefix)

//Pesquisa produto
@ 18,3 GET oCtrl VAR cPesq SIZE 150,13 OF oDet
AADD(aControls[3],oCtrl) // 1 - Get Pesquisa
@ 32,3 CHECKBOX oCod VAR lCodigo CAPTION STR0029 ACTION NFOrderFind(aControls,@lCodigo, @lDesc,.t.) OF oDet //"Código"
AADD(aControls[3],oCod) // 2 - CheckBox Codigo
@ 32,55 CHECKBOX oDesc VAR lDesc CAPTION STR0030 ACTION NFOrderFind(aControls,@lCodigo, @lDesc ,.f.) OF oDet //"Descrição"
AADD(aControls[3],oDesc) // 3 - CheckBox Descricao
@ 32,115 BUTTON oCtrl CAPTION BTN_BITMAP_SEARCH SYMBOL ACTION NFFind(cPesq,lCodigo,aGrupo,@nGrupo,aPrdPrefix,oBrwProd,aIteNot,@nTop) OF oDet
AADD(aControls[3],oCtrl) // 4- Botao Buscar

//Folder (Precos de Tabela)
ADD FOLDER oPrecos CAPTION STR0031 ON ACTIVATE NFSetPrecos(aObj,aControls,aPrecos) Of oDlg //"Preços"
NFFldPrecos(oPrecos,oCtrl,aControls,oBrw,aPrecos,oCol,nPrc)

//Folder Observacoes
//ADD FOLDER oObs CAPTION "Obs" OF oDlg
//@ 30,01 TO 127,158 CAPTION "Observação" OF oObs
//@ 40,05 GET oObj VAR aCabNot[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
//AADD(aObj[4],oObj)

//if nSaldoEst>0
//   ShowControl(oBtnOk)
//   ShowControl(oBtnExcluir)   
//else
//   HideControl(oBtnOk)         
//   HideControl(oBtnExcluir)               
//endif

ACTIVATE DIALOG oDlg 

Return Nil