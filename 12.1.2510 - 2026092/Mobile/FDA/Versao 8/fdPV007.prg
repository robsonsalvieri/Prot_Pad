#INCLUDE "FDPV007.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Pedido  de Venda 2  ³Autor - Cleber M.    ³ Data ³21/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±³			 ³ InitPV2 -> Inicia o Mod. de Pedidos Versao 2	 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0.1                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³NOperacao 1- Inclusao /2 - Alteracao / 3 - Ult.Pedido(Cons.)´±±
±±³			 ³4 - Ult.Pedido (Gerar Novo Pedido)   	     		 		  ´±±
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

Function InitPV2(aCabPed,aItePed,aCond,aTab,aColIte)
Local oDlg,oCab,oFldProd,oObs,oObj,oBrwProd,oPrecos
Local aObj := { {},{},{},{},{} }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := ""
Local nItePed:=0, nOpIte := 1 //depois tirar
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := "", cSfaFpgIni := ""
Local cFrete := "", cSfaFre := "", aTpFrete := {"CIF", "FOB"}, nOpcFre := If(aCabPed[16,1]="C",1,2)
Local aPrdPrefix := {}
Local nPos := 0, oUp,oDown,oLeft,oRight
Local oCol,oBtnTes,oTxtTes,oBtnOK,oBtnExcluir
Local cDesc := "", cCod := "", oGrupo
Local cDescD := ""
Local cUN := "", nQTD := 0, nEnt := 0, nDescMax := 0
Local nICM := 0, nIPI := 0, cEst := space(40), nPrc:=0.00 , oBrw
Local oCtrl, aControls := { {},{},{} }
Local oDet, oCod, oDesc, cPesq := Space(40), lCodigo:=.t., lDesc:=.f.
Local aPrecos := {}, nTop := 0
Local aCmpTes:={},aIndTes:={}
Local nIva,cTes,lvenda:=.T.
// Configura parametros
//SetParam(aCabPed[3,1],aCabPed[4,1], cCliente, cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix)
SetParam(aCabPed[3,1],aCabPed[4,1],@cCliente,@cCond,@cTes,nIVA,cProDupl,aPrdPrefix,lVenda)
cManTes:=GetParam("MV_SFAMTES","N")
cBloqPrc:=GetParam("MV_BLOQPRC","S")
//Prepara/inicia arrays
PVMontaColIte(aColIte)
PVMontaArrays(aCmpPag,aIndPag,aCmpTab,aIndTab,aCmpTra,aIndTra,aCmpFpg,aIndFpg,aCmpTes,aIndTes)
  
aSize(aProduto,0)

If aCabPed[2,1] = 1 .Or. aCabPed[2,1] = 4
	DEFINE DIALOG oDlg TITLE STR0001 //"Inclusão"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo pedido)
	If aCabPed[2,1] = 1
		aCabPed[7,1] := cCond
		aCabPed[8,1] := HA1->HA1_TABELA //cTabPrc
		aCabPed[13,1]:= HA1->HA1_TRANSP //cTransp
		aCabPed[15,1]:= HA1->HA1_FORPAG //cSfaFpgIni
		aCabPed[16,1]:= HA1->HA1_TPFRET //cFrete
		nOpcFre      := If(aCabPed[16,1]="C",1,2)
	Endif
Else 
	DEFINE DIALOG oDlg TITLE STR0002 //"Alteração"
EndIf

//Folder Principal (Cabec. do Pedido)
ADD FOLDER oCab CAPTION STR0003 OF oDlg //"Principal"
@ 35,01 TO 139,158 CAPTION STR0003 OF oCab //"Principal"
@ 18,03 GET oObj VAR cCliente SIZE 150,12 READONLY MULTILINE OF oCab
AADD(aObj[1],oObj) // 1 - Label Cliente
@ 122,71 BUTTON oObj CAPTION  BTN_BITMAP_GRAVAR SYMBOL ACTION PVGravarPed(aCabPed,aItePed,aColIte,cCondInt,cSfaInd,cSfaFpg) SIZE 40,12 OF oCab
AADD(aObj[1],oObj) // 2 - Botao Gravar
@ 122,116 BUTTON oObj CAPTION BTN_BITMAP_CANCEL SYMBOL ACTION PVFecha(aCabPed[2,1]) SIZE 40,12 OF oCab
AADD(aObj[1],oObj) // 3 - Botao Cancelar
@ 125,2 SAY "T:"  of oCab
#ifdef __PALM__
	@ 125,20 GET oObj VAR aCabPed[12,1] READONLY SIZE 40,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#else
	@ 125,20 GET oObj VAR aCabPed[12,1] READONLY SIZE 52,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#endif

// Condicao de Pagamento
@ 40,42 GET oObj VAR aCabPed[7,1] READONLY SIZE 25,12 of oCab
AADD(aObj[2],oObj)
@ 40,03 BUTTON oObj CAPTION STR0004 SIZE 34,10 ACTION PVCond(aCabPed,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt) of oCab  //"Pagto:"
AADD(aObj[2],oObj)
// Tabela de Preco
@ 40,119 GET oObj VAR aCabPed[8,1] READONLY SIZE 25,12 of oCab
AADD(aObj[2],oObj)
@ 40,80 BUTTON oObj CAPTION STR0005 SIZE 34,10 ACTION PVTrocaTab(aCabPed,aObj,aCmpTab,aIndTab,aColIte,aItePed,cCondInt,2) of oCab //"Tabela:"
AADD(aObj[2],oObj)

// Data de Entrega
@ 54,42 GET oObj VAR aCabPed[10,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 54,03 BUTTON oObj CAPTION STR0006 SIZE 34,10 ACTION PVDtEntr(aCabPed[10,1],aObj[2,5]) of oCab //"Entrg.:"
AADD(aObj[2],oObj)
// Transportadora
@ 68,42 GET oObj VAR aCabPed[13,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 68,03 BUTTON oObj CAPTION STR0007 SIZE 34,10 ACTION SFConsPadrao("HA4",aCabPed[13,1],aObj[2,7],aCmpTra,aIndTra,) of oCab //"Transp:"
AADD(aObj[2],oObj)

cSfaFpg := GetParam("MV_SFAFPG","F")
If cSfaFpg == "T"
	//Forma de Pagto.
	@ 82,03 BUTTON oObj CAPTION STR0008 SIZE 34,10 ACTION SFConsPadrao("HTP",aCabPed[15,1],aObj[2,10],aCmpFpg,aIndFpg,) of oCab //"F.Pagto"
	AADD(aObj[2],oObj)
	@ 82,42 GET oObj VAR aCabPed[15,1] SIZE 50,12 of oCab
	AADD(aObj[2],oObj)
EndIf

// Indenizacao
cSfaInd := GetParam("MV_SFAIND","F")
If cSfaInd == "T"
	@ 96,03 SAY STR0009 OF oCab //"Inden:"
	AADD(aObj[2],oObj)
	@ 96,42 GET oObj VAR aCabPed[14,1] VALID ChkIndeni(aCabPed) SIZE 50,12 of oCab
	//VALID (aCabPed[14,1] < aCabPed[11,1])
	AADD(aObj[2],oObj)
EndIf

// Tipo de Frete
cSfaFre := GetParam("MV_SFAFRE","F")
If cSfaFre == "T"
	@ 110,03 SAY STR0010 OF oCab //"Frete:"
	AADD(aObj[2],oObj)
	@ 110,42 COMBOBOX oObj VAR nOpcFre ITEMS aTpFrete ACTION UpdTpFrete(aCabPed, aTpFrete, nOpcFre) SIZE 50,40 of oCab
	AADD(aObj[2],oObj)
EndIf

//Folder (Browse de Itens/Produtos)
ADD FOLDER oFldProd CAPTION STR0011 OF oDlg //"Itens"
@ 18,2 SAY STR0012 OF oFldProd //"Grupo:"
@ 18,32 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION PVGrupo(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,.f.,lCodigo) SIZE 125,50 OF oFldProd

@ 30,03 BROWSE oBrwProd SIZE 140,60 NO SCROLL ACTION PVSeleciona(oBrwProd,aColIte,aItePed,@nItePed,aCabPed,aObj,cManPrc,cManTes,@nOpIte,"P") of oFldProd
SET BROWSE oBrwProd ARRAY aProduto            
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0013 WIDTH 135 //"Descr."
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0014 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0015 WIDTH 35 //"Qtde"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 4 HEADER STR0016 WIDTH 35 ALIGN RIGHT //"Preco"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 5 HEADER STR0017 WIDTH 35 ALIGN RIGHT //"Desc."
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 6 HEADER STR0018 WIDTH 40 ALIGN RIGHT //"Sub Tot."
AADD(aObj[3],oBrwProd) // 1 - Browse de Produtos

@ 32,146 BUTTON oUp CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION PVSobe(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,lCodigo) OF oFldProd
@ 47,146 BUTTON oLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oBrwProd) OF oFldProd
@ 62,146 BUTTON oRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oBrwProd) OF oFldProd
@ 77,146 BUTTON oDown CAPTION DOWN_ARROW SYMBOL  SIZE 12,10 ACTION PVDesce(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,lCodigo) OF oFldProd

@ 92,03 BUTTON oObj CAPTION STR0019 ACTION PVQTde(aObj[3,3]) SIZE 30,11 of oFldProd //"Qtde."
AADD(aObj[3],oObj) // 2 - Botao Quantidade
@ 92,40 GET oObj VAR aColIte[4,1] SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 3 - Get Quantidade

If cBloqPrc == "S"	//Bloqueia campo Preco
	@ 92,080 BUTTON oObj CAPTION STR0020 SIZE 33,11 of oFldProd //"Preço"
	AADD(aObj[3],oObj) // 4 - Botao Preco
	@ 92,115 GET oObj VAR aColIte[6,1] PICTURE "@E 9,999.99" READONLY SIZE 40,15 of oFldProd
	AADD(aObj[3],oObj) // 5 - Get Preco
Else
	@ 92,080 BUTTON oObj CAPTION STR0020 ACTION PVPrc(aObj[3,5]) SIZE 33,11 of oFldProd //"Preço"
	AADD(aObj[3],oObj) // 4 - Botao Preco
	@ 92,115 GET oObj VAR aColIte[6,1] PICTURE "@E 9,999.99" SIZE 40,15 of oFldProd
	AADD(aObj[3],oObj) // 5 - Get Preco                                                            
Endif
@ 107,03 BUTTON oObj CAPTION STR0021 ACTION PVDesc(aObj[3,7]) SIZE 30,11 of oFldProd //"Desc"
AADD(aObj[3],oObj) // 6 - Botao Desconto
@ 107,40 GET oObj VAR aColIte[7,1] PICTURE "@E 9,999.99" SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 7 - Get Desconto

If cManTes == "S"	//Permite a manipulacao da TES
	@ 107,080 BUTTON oBtnTes CAPTION STR0022 ACTION SFConsPadrao("HF4",aColIte[8,1],aObj[3,9],aCmpTes,aIndTes,) SIZE 33,11 of oFldProd //"Tes"
	@ 107,115 GET oTxtTes VAR aColIte[8,1] READONLY SIZE 35,15 of oFldProd
	AADD(aObj[3],oBtnTes) // 8 - Botao TES
	AADD(aObj[3],oTxtTes) // 9 - Get TES
	@ 01,075 BUTTON oBtnOK CAPTION "+" SIZE 22,10 ACTION PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,@cManTes,cProDupl,nOpIte,2,"P") of oFldProd
	@ 01,125 BUTTON oBtnExcluir CAPTION "-" SIZE 22,10 ACTION PVExcIte(aItePed,@nItePed,aCabPed,aObj,.F.,2) of oFldProd
Else
	AADD(aObj[3],"") // 8 - Botao TES
	AADD(aObj[3],"") // 9 - Get TES
	@ 107,085 BUTTON oBtnOK CAPTION "+" SIZE 22,10 ACTION PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,@cManTes,cProDupl,nOpIte,2,"P") of oFldProd
	@ 107,130 BUTTON oBtnExcluir CAPTION "-" SIZE 22,10 ACTION PVExcIte(aItePed,@nItePed,aCabPed,aObj,.F.,2) of oFldProd	
Endif
	
@ 122,3 GET oObj VAR aColIte[2,1] MULTILINE READONLY NO UNDERLINE SIZE 150,22 OF oFldProd
AADD(aObj[3],oObj) // 10 - Get Descricao

//@ 130,85 BUTTON oBtnOK CAPTION "OK" SIZE 33,11 ACTION PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,@cManTes,cProDupl,nOpIte,2,"P") of oFldProd
//@ 130,125 BUTTON oBtnExcluir CAPTION "Excluir" SIZE 33,11 ACTION PVExcIte(aItePed,@nItePed,aCabPed,aObj,.F.,2) of oFldProd

PVGrupo(aGrupo,1,oBrwProd,@nTop,aItePed,.f.,lCodigo) //Carrega o 1o. grupo automat.

//Folder (Detalhes do produto)
ADD FOLDER oDet CAPTION STR0023 ON ACTIVATE PVSetDetalhes(oBrwProd,aControls,@cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax) Of oDlg //"Detalhe"
PVFldDetalhe(oBrwProd,aItePed,@nTop,oDet,aControls,oCtrl,cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax,aPrdPrefix)

//Pesquisa produto
@ 18,3 GET oCtrl VAR cPesq SIZE 150,13 OF oDet
AADD(aControls[3],oCtrl) // 1 - Get Pesquisa
@ 32,3 CHECKBOX oCod VAR lCodigo CAPTION STR0024 ACTION PVOrderFind(aControls,@lCodigo, @lDesc,.t.) OF oDet //"Código"
AADD(aControls[3],oCod) // 2 - CheckBox Codigo
@ 32,55 CHECKBOX oDesc VAR lDesc CAPTION STR0025 ACTION PVOrderFind(aControls,@lCodigo, @lDesc ,.f.) OF oDet //"Descrição"
AADD(aControls[3],oDesc) // 3 - CheckBox Descricao
@ 32,115 BUTTON oCtrl CAPTION BTN_BITMAP_SEARCH SYMBOL ACTION PVFind(cPesq,lCodigo,aGrupo,@nGrupo,aPrdPrefix,oBrwProd,aItePed,@nTop) OF oDet
AADD(aControls[3],oCtrl) // 4- Botao Buscar


//Folder (Precos de Tabela)
ADD FOLDER oPrecos CAPTION STR0026 ON ACTIVATE PVSetPrecos(aObj,aControls,aPrecos) Of oDlg //"Preços"
PVFldPrecos(oPrecos,oCtrl,aControls,oBrw,aPrecos,oCol,nPrc)

//Folder Observacoes
ADD FOLDER oObs CAPTION STR0027 OF oDlg //"Obs"
@ 30,01 TO 127,158 CAPTION STR0028 OF oObs //"Observação"
@ 40,05 GET oObj VAR aCabPed[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
AADD(aObj[4],oObj)

ACTIVATE DIALOG oDlg

Return Nil
