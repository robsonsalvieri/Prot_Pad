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

Function InitNF2(aCabNot,aIteNot,aCond,aTab,aColIteNf)
Local oDlg,oCab,oFldProd,oObs,oObj,oBrwProd,oPrecos
Local aObj := { {},{},{},{},{} }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := ""
Local nItePed:=0, nOpIte := 1 //depois tirar
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := "", cSfaFpgIni := ""
Local cFrete := "", cSfaFre := "", aTpFrete := {"CIF", "FOB"}, nOpcFre := If(aCabNot[16,1]="C",1,2)
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
Alert( "na InitNF2")
// Configura parametros
SetParam(aCabNot[3,1],aCabNot[4,1], cCliente, cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix)
//Prepara/inicia arrays
MontaColItenf(aColIteNF)
NFMontaArrays(aCmpPag,aIndPag,aCmpTab,aIndTab,aCmpTra,aIndTra,aCmpFpg,aIndFpg,aCmpTes,aIndTes)
aSize(aProduto,0)

If aCabNot[2,1] = 1 .Or. aCabNot[2,1] = 4
	DEFINE DIALOG oDlg TITLE "Inclusão"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo pedido)
	If aCabNot[2,1] = 1
		aCabNot[7,1] := cCond
		aCabNot[8,1] := cTabPrc
		aCabNot[13,1]:= cTransp
		aCabNot[15,1]:= cSfaFpgIni
		aCabNot[16,1]:= cFrete
		nOpcFre      := If(aCabNot[16,1]="C",1,2)
	Endif
Else 
	DEFINE DIALOG oDlg TITLE "Alteração"
EndIf

//Folder Principal (Cabec. do Pedido)
ADD FOLDER oCab CAPTION "Principal" OF oDlg
@ 35,01 TO 139,158 CAPTION "Principal" OF oCab
@ 18,03 GET oObj VAR cCliente SIZE 150,12 READONLY MULTILINE OF oCab
AADD(aObj[1],oObj) // 1 - Label Cliente
@ 125,71 BUTTON oObj CAPTION "Gravar"  ACTION NFGravarNf(aCabNot,aIteNot,aColItenf,cCondInt,cSfaInd) SIZE 40,12 OF oCab
AADD(aObj[1],oObj) // 2 - Botao Gravar
@ 125,116 BUTTON oObj CAPTION "Cancelar" ACTION NFFechaNf(aCabNot[2,1]) SIZE 40,12 OF oCab
AADD(aObj[1],oObj) // 3 - Botao Cancelar
@ 125,2 SAY "T:"  of oCab
#ifdef __PALM__
	@ 125,20 GET oObj VAR aCabNot[12,1] READONLY SIZE 40,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#else
	@ 125,20 GET oObj VAR aCabNot[12,1] READONLY SIZE 52,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#endif

// Condicao de Pagamento
@ 40,42 GET oObj VAR aCabNot[7,1] READONLY SIZE 25,12 of oCab
AADD(aObj[2],oObj)
@ 40,03 BUTTON oObj CAPTION "Pagto:" SIZE 34,10 ACTION PVCond(aCabNot,aObj,aCmpPag,aIndPag,aColItenf,aIteNot,cCondInt) of oCab 
AADD(aObj[2],oObj)
// Tabela de Preco
@ 40,119 GET oObj VAR aCabNot[8,1] READONLY SIZE 25,12 of oCab
AADD(aObj[2],oObj)
@ 40,80 BUTTON oObj CAPTION "Tabela:" SIZE 34,10 ACTION PVTrocaTab(aCabNot,aObj,aCmpTab,aIndTab,aColItenf,aIteNot,cCondInt,2) of oCab
AADD(aObj[2],oObj)

// Data de Entrega
@ 54,42 GET oObj VAR aCabNot[10,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 54,03 BUTTON oObj CAPTION "Entrg.:" SIZE 34,10 ACTION PVDtEntr(aCabNot[10,1],aObj[2,5]) of oCab
AADD(aObj[2],oObj)
// Transportadora
@ 68,42 GET oObj VAR aCabNot[13,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 68,03 BUTTON oObj CAPTION "Transp:" SIZE 34,10 ACTION SFConsPadrao("HA4",aCabNot[13,1],aObj[2,7],aCmpTra,aIndTra,) of oCab
AADD(aObj[2],oObj)

If cSfaFpg = "T"
	//Forma de Pagto.
	@ 82,03 BUTTON oObj CAPTION "F.Pagto" SIZE 34,10 ACTION SFConsPadrao("HTP",aCabNot[15,1],aObj[2,10],aCmpFpg,aIndFpg,) of oCab
	AADD(aObj[2],oObj)
	@ 82,42 GET oObj VAR aCabNot[15,1] SIZE 50,12 of oCab
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
	@ 96,03 SAY "Inden:" OF oCab
	AADD(aObj[2],oObj)
	@ 96,42 GET oObj VAR aCabNot[14,1] VALID ChkIndeni(aCabNot) SIZE 50,12 of oCab
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
	@ 110,03 SAY "Frete:" OF oCab
	AADD(aObj[2],oObj)
	@ 110,42 COMBOBOX oObj VAR nOpcFre ITEMS aTpFrete ACTION UpdTpFrete(aCabNot, aTpFrete, nOpcFre) SIZE 50,40 of oCab
	AADD(aObj[2],oObj)
EndIf

//Folder (Browse de Itens/Produtos)
ADD FOLDER oFldProd CAPTION "Itens" OF oDlg
@ 18,2 SAY "Grupo:" OF oFldProd
@ 18,32 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION NFGRUPO(aGrupo,nGrupo,oBrwProd,@nTop,aIteNot) SIZE 125,50 OF oFldProd

@ 30,03 BROWSE oBrwProd SIZE 140,60 NO SCROLL ACTION NFSeleciona(oBrwProd,aColItenf,aIteNot,@nItePed,aCabNot,aObj,cManPrc,cManTes,@nOpIte) of oFldProd
SET BROWSE oBrwProd ARRAY aProduto            
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER "Descr." WIDTH 135
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER "Produto" WIDTH 50
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER "Qtde" WIDTH 35
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 4 HEADER "Preco" WIDTH 35 ALIGN RIGHT
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 5 HEADER "Desc." WIDTH 35 ALIGN RIGHT
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 6 HEADER "Sub Tot." WIDTH 40 ALIGN RIGHT
AADD(aObj[3],oBrwProd) // 1 - Browse de Produtos

@ 32,146 BUTTON oUp CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION NFSobe(aGrupo,nGrupo,oBrwProd,@nTop,aIteNot) OF oFldProd
@ 47,146 BUTTON oLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oBrwProd) OF oFldProd
@ 62,146 BUTTON oRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oBrwProd) OF oFldProd
@ 77,146 BUTTON oDown CAPTION DOWN_ARROW SYMBOL  SIZE 12,10 ACTION NFDesce(aGrupo,nGrupo,oBrwProd,@nTop,aIteNot) OF oFldProd

@ 92,03 BUTTON oObj CAPTION "Qtde." ACTION NFQTde(aObj[3,3]) SIZE 30,11 of oFldProd
AADD(aObj[3],oObj) // 2 - Botao Quantidade
@ 92,40 GET oObj VAR aColItenf[4,1] SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 3 - Get Quantidade
alert( "antes do if" )
If cBloqPrc == "S"	//Bloqueia campo Preco
    alert( "dentro do if" )
	@ 92,080 BUTTON oObj CAPTION "Preço" SIZE 33,11 of oFldProd
	AADD(aObj[3],oObj) // 4 - Botao Preco
	@ 92,115 GET oObj VAR aColItenf[6,1] PICTURE "@E 9,999.99" READONLY SIZE 40,15 of oFldProd
	AADD(aObj[3],oObj) // 5 - Get Preco
Else
	@ 92,080 BUTTON oObj CAPTION "Preço" ACTION NFPrc(aObj[3,5]) SIZE 33,11 of oFldProd
	AADD(aObj[3],oObj) // 4 - Botao Preco
	@ 92,115 GET oObj VAR aColItenf[6,1] PICTURE "@E 9,999.99" SIZE 40,15 of oFldProd
	AADD(aObj[3],oObj) // 5 - Get Preco                                                            
Endif
@ 107,03 BUTTON oObj CAPTION "Desc" ACTION NFDesc(aObj[3,7]) SIZE 30,11 of oFldProd
AADD(aObj[3],oObj) // 6 - Botao Desconto
@ 107,40 GET oObj VAR aColItenf[7,1] PICTURE "@E 9,999.99" SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 7 - Get Desconto

If cManTes == "S"	//Permite a manipulacao da TES
	@ 107,080 BUTTON oBtnTes CAPTION "Tes" ACTION SFConsPadrao("HF4",aColItenf[8,1],aObj[3,9],aCmpTes,aIndTes,) SIZE 33,11 of oFldProd
	@ 107,115 GET oTxtTes VAR aColItenf[8,1] READONLY SIZE 35,15 of oFldProd
	AADD(aObj[3],oBtnTes) // 8 - Botao TES
	AADD(aObj[3],oTxtTes) // 9 - Get TES
	@ 01,075 BUTTON oBtnOK CAPTION "+" SIZE 22,10 ACTION NFGrvIte(aColItenf,aIteNot, nItePed, aCabNot,aObj,@cManTes,cProDupl,nOpIte,2) of oFldProd
	@ 01,125 BUTTON oBtnExcluir CAPTION "-" SIZE 22,10 ACTION NFExcIte(aIteNot,@nItePed,aCabNot,aObj,.F.,2) of oFldProd
Else
	AADD(aObj[3],"") // 8 - Botao TES
	AADD(aObj[3],"") // 9 - Get TES
	@ 107,085 BUTTON oBtnOK CAPTION "+" SIZE 22,10 ACTION NFGrvIte(aColItenf,aIteNot, nItePed, aCabNot,aObj,@cManTes,cProDupl,nOpIte,2) of oFldProd
	@ 107,130 BUTTON oBtnExcluir CAPTION "-" SIZE 22,10 ACTION NFExcIte(aIteNot,@nItePed,aCabNot,aObj,.F.,2) of oFldProd	
Endif
	
@ 122,3 GET oObj VAR aColItenf[2,1] MULTILINE READONLY NO UNDERLINE SIZE 150,22 OF oFldProd
AADD(aObj[3],oObj) // 10 - Get Descricao

//@ 130,85 BUTTON oBtnOK CAPTION "OK" SIZE 33,11 ACTION NFGrvIte(aColItenf,aIteNot, nItePed, aCabNot,aObj,@cManTes,cProDupl,nOpIte,2) of oFldProd
//@ 130,125 BUTTON oBtnExcluir CAPTION "Excluir" SIZE 33,11 ACTION NFExcIte(aIteNot,@nItePed,aCabNot,aObj,.F.,2) of oFldProd

//Folder (Detalhes do produto)
ADD FOLDER oDet CAPTION "Detalhe" ON ACTIVATE NFSetDetalhes(oBrwProd,aControls,@cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax) Of oDlg
NFFldDetalhe(oBrwProd,aIteNot,@nTop,oDet,aControls,oCtrl,cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax,aPrdPrefix)

//Pesquisa produto
@ 18,3 GET oCtrl VAR cPesq SIZE 150,13 OF oDet
AADD(aControls[3],oCtrl) // 1 - Get Pesquisa
@ 32,3 CHECKBOX oCod VAR lCodigo CAPTION "Código" ACTION NFOrderFind(aControls,@lCodigo, @lDesc,.t.) OF oDet
AADD(aControls[3],oCod) // 2 - CheckBox Codigo
@ 32,55 CHECKBOX oDesc VAR lDesc CAPTION "Descrição" ACTION NFOrderFind(aControls,@lCodigo, @lDesc ,.f.) OF oDet
AADD(aControls[3],oDesc) // 3 - CheckBox Descricao
@ 32,115 BUTTON oCtrl CAPTION "Buscar" ACTION NFFind(cPesq,lCodigo,aGrupo,@nGrupo,aPrdPrefix,oBrwProd,aIteNot,@nTop) OF oDet
AADD(aControls[3],oCtrl) // 4- Botao Buscar


//Folder (Precos de Tabela)
ADD FOLDER oPrecos CAPTION "Preços" ON ACTIVATE NFSetPrecos(aObj,aControls,aPrecos) Of oDlg
NFFldPrecos(oPrecos,oCtrl,aControls,oBrw,aPrecos,oCol,nPrc)

//Folder Observacoes
ADD FOLDER oObs CAPTION "Obs" OF oDlg
@ 30,01 TO 127,158 CAPTION "Observação" OF oObs
@ 40,05 GET oObj VAR aCabNot[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
AADD(aObj[4],oObj)

ACTIVATE DIALOG oDlg

Return Nil