#INCLUDE "FDPV010.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Pedido  de Venda Esp³Autor - Paulo Lima   ³ Data ³10/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos (Venda e Devolucoes)      	 			  ³±±
±±³			 ³ InitPVEsp -> Especifica da Effem				 			  ³±±
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

Function InitPVEsp(aCabPed,aItePed,aColIte)
Local oDlg,oCab,oFldProd,oObj,oBrwProd,oBrwItePed  //oObs,oPrecos,oBrw
Local aObj := { {},{},{},{},{} }
Local cCliente:=""
Local nItePed:=0, nOpIte := 1
Local cSfaInd := ""
Local aPrdPrefix := {}
Local nPos := 0, oUp,oDown,oLeft,oRight
Local oCol,oBtnOK,oBtnExcluir
Local cDesc := "", cCod := "", oGrupo
Local cDescD := ""
Local cUN := "", nQTD := 0, nEnt := 0
Local cCond := "", cTes := ""
Local nIVA := 0, cEst := space(40), nPrc:=0.00 
Local oCtrl, aControls := { {},{},{} }
Local oDet, oCod, oDesc, cPesq := Space(40), lCodigo:=.t., lDesc:=.f.
Local aPrecos := {}, nTop := 0
Local aCmpTes:={},aIndTes:={}
Local cProDupl := ""
Local cManTes := AllTrim(GetParam("MV_SFAMTES","N")) 
Local cManPrc := AllTrim(GetParam("MV_BLOQPRC","S")) 

// Configura parametros
SetParam(aCabPed[3,1],aCabPed[4,1], @cCliente, @cCond,@cTes,@nIVA,cProDupl,aPrdPrefix,.T.)
//Prepara/inicia arrays
PVMontaColIte(aColIte)
//PVMontaArrays(aCmpPag,aIndPag,aCmpTab,aIndTab,aCmpTra,aIndTra,aCmpFpg,aIndFpg,aCmpTes,aIndTes)
//Carregar lista de grupos

aSize(aGrupo,0)
AADD(aGrupo,"Todos") //1o. item (padrao)
HBM->(dbGoTop())
While !HBM->(Eof())
   AADD(aGrupo,HBM->BM_GRUPO + " - " + AllTrim(HBM->BM_DESC))
   HBM->(dbSkip())
Enddo                 

aSize(aProduto,0)

If aCabPed[2,1] = 1 .Or. aCabPed[2,1] = 4
	DEFINE DIALOG oDlg TITLE STR0001 //"Inclusão"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo pedido)
	If aCabPed[2,1] = 1
		aCabPed[7,1] := cCond
	Endif
Else 
	DEFINE DIALOG oDlg TITLE STR0002 //"Alteração"
EndIf

//Folder (Browse de Itens/Produtos)
ADD FOLDER oFldProd CAPTION STR0014 ON ACTIVATE PVFocarBrowse(oBrwProd) OF oDlg //"Itens"
@ 18,2 SAY STR0015 OF oFldProd //"Grupo:"
@ 18,32 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION PVGrupo(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,.t.,lCodigo) SIZE 125,50 OF oFldProd

@ 30,03 BROWSE oBrwProd SIZE 140,60 NO SCROLL ACTION ;
PVSeleciona(oBrwProd,aColIte,aItePed,@nItePed,aCabPed,aObj,cManPrc,cManTes,@nOpIte,"P") of oFldProd
SET BROWSE oBrwProd ARRAY aProduto            
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0016 WIDTH 135 //"Descr."
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0017 WIDTH 60 //"Produto"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0018 WIDTH 35 ALIGN RIGHT //"Qtde"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 4 HEADER STR0019 WIDTH 35 ALIGN RIGHT //"Preco"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 6 HEADER STR0021 WIDTH 40 ALIGN RIGHT //"Sub Tot."
AADD(aObj[3],oBrwProd) // 1 - Browse de Produtos

@ 32,146 BUTTON oUp CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION PVSobe(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,lCodigo) OF oFldProd
@ 47,146 BUTTON oLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oBrwProd) OF oFldProd
@ 62,146 BUTTON oRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oBrwProd) OF oFldProd
@ 77,146 BUTTON oDown CAPTION DOWN_ARROW SYMBOL  SIZE 12,10 ACTION PVDesce(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,lCodigo) OF oFldProd

@ 92,03 BUTTON oObj CAPTION STR0022 ACTION PVQTde(aObj[3,3]) SIZE 30,11 of oFldProd //"Qtde."
AADD(aObj[3],oObj) // 2 - Botao Quantidade
@ 92,40 GET oObj VAR aColIte[4,1] SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 3 - Get Quantidade

@ 92,080 BUTTON oObj CAPTION STR0023 SIZE 33,11 of oFldProd //"Preço"
AADD(aObj[3],oObj) // 4 - Botao Preco
@ 92,115 GET oObj VAR aColIte[6,1] PICTURE "@E 9,999.99" READONLY SIZE 40,15 of oFldProd
AADD(aObj[3],oObj) // 5 - Get Preco
//@ 107,03 BUTTON oObj CAPTION STR0024 ACTION PVDesc(aObj[3,7]) SIZE 30,11 of oFldProd //"Desc"
AADD(aObj[3],oObj) // 6 - Botao Desconto
//@ 107,40 GET oObj VAR aColIte[7,1] PICTURE "@E 9,999.99" VALID PVCalcDesc(aColIte) SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 7 - Get Desconto

AADD(aObj[3],"") // 8 - Botao TES
AADD(aObj[3],"") // 9 - Get TES
@ 107,085 BUTTON oBtnOK CAPTION "+" SIZE 22,10 ACTION PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,cProDupl,nOpIte,2,"P") of oFldProd
@ 107,130 BUTTON oBtnExcluir CAPTION "-" SIZE 22,10 ACTION PVExcIte(aItePed,@nItePed,aCabPed,aObj,.F.,2) of oFldProd	
	
@ 122,3 GET oObj VAR aColIte[2,1] MULTILINE READONLY NO UNDERLINE SIZE 150,22 OF oFldProd
AADD(aObj[3],oObj) // 10 - Get Descricao

PVGrupo(aGrupo,1,oBrwProd,@nTop,aItePed,.f.,lCodigo) //Carrega o 1o. grupo automat.

//Folder (Detalhes do produto)
ADD FOLDER oDet CAPTION STR0026 ON ACTIVATE PVSetDetalhes(oBrwProd,aControls,@cCod,cDescD,cUN,nQTD,nEnt,nIVA,cEst) Of oDlg //"Detalhe"
PVFldDetalhe(oBrwProd,aItePed,@nTop,oDet,aControls,oCtrl,cCod,cDescD,cUN,nQTD,nEnt,nIVA,cEst,aPrdPrefix)

//Pesquisa produto
@ 18,3 GET oCtrl VAR cPesq SIZE 150,13 OF oDet
AADD(aControls[3],oCtrl) // 1 - Get Pesquisa
@ 32,3 CHECKBOX oCod VAR lCodigo CAPTION STR0027 ACTION PVOrderFind(aControls,@lCodigo, @lDesc,.t.) OF oDet //"Código"
AADD(aControls[3],oCod) // 2 - CheckBox Codigo
@ 32,55 CHECKBOX oDesc VAR lDesc CAPTION STR0028 ACTION PVOrderFind(aControls,@lCodigo, @lDesc ,.f.) OF oDet //"Descrição"
AADD(aControls[3],oDesc) // 3 - CheckBox Descricao
@ 32,115 BUTTON oCtrl CAPTION STR0029 ACTION PVFind(cPesq,lCodigo,aGrupo,@nGrupo,aPrdPrefix,oBrwProd,aItePed,@nTop) OF oDet //"Buscar"
AADD(aControls[3],oCtrl) // 4- Botao Buscar

//Folder Observacoes
/*
ADD FOLDER oObs CAPTION STR0030 OF oDlg //"Obs"
@ 30,01 TO 127,158 CAPTION STR0031 OF oObs //"Observação"
@ 40,05 GET oObj VAR aCabPed[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
AADD(aObj[4],oObj)

//Folder (Precos de Tabela)

ADD FOLDER oPrecos CAPTION STR0032 ON ACTIVATE PVSetPrecos(aObj,aControls,aPrecos) Of oDlg //"Preços"
PVFldPrecos(oPrecos,oCtrl,aControls,oBrw,aPrecos,oCol,nPrc)
*/

//Folder Principal (Cabec. do Pedido)
//ADD FOLDER oCab CAPTION STR0003 ON ACTIVATE PVFLDPrinc(aCabPed,aItePed) OF oDlg //"Principal"
ADD FOLDER oCab CAPTION STR0003 ON ACTIVATE PVBrwItePed(oBrwItePed,aItePed) OF oDlg //"Principal"
@ 35,01 TO 139,158 CAPTION STR0003 OF oCab //"Principal"
@ 18,03 GET oObj VAR cCliente SIZE 150,12 READONLY MULTILINE OF oCab
AADD(aObj[1],oObj) // 1 - Label Cliente
@ 125,71 BUTTON oObj CAPTION STR0004  ACTION PVGravarPed(aCabPed,aItePed,aColIte,cSfaInd) SIZE 40,12 OF oCab //"Gravar"
AADD(aObj[1],oObj) // 2 - Botao Gravar
@ 125,116 BUTTON oObj CAPTION STR0005 ACTION PVFecha(aCabPed[2,1]) SIZE 40,12 OF oCab //"Cancelar"
AADD(aObj[1],oObj) // 3 - Botao Cancelar
@ 125,2 SAY "T:"  of oCab
#ifdef __PALM__
	@ 125,12 GET oObj VAR aCabPed[12,1] PICTURE "@E 9,999,999.99" READONLY SIZE 52,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#else
	@ 125,12 GET oObj VAR aCabPed[12,1] PICTURE "@E 9,999,999.99" READONLY SIZE 59,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#endif

@ 40,03 BROWSE oBrwItePed SIZE 150,82 of oCab
SET BROWSE oBrwItePed ARRAY aItePed
//ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 11 HEADER "B" WIDTH 10 //"Bonificacao"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 1 HEADER STR0017 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 2 HEADER STR0016 WIDTH 130  //Acresc. 11/06/03 //"Descr."
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 4 HEADER STR0018 WIDTH 35 //"Qtde"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 6 HEADER STR0019 WIDTH 35 //"Preco"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 9 HEADER STR0021 WIDTH 45 //"Sub Tot."
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 15 HEADER "IVA" WIDTH 45 //"IVA"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 16 HEADER "Total" WIDTH 45 //"Total do Item"

AADD(aObj[1],oBrwItePed)


ACTIVATE DIALOG oDlg

Return Nil

Function PVBRWItePed(oBrwItePed,aItePed)  
SetArray(oBrwItePed,aItePed)
Return Nil
                                            

Function PVFLDPrinc(aCabPed,aItePed)
Local nCont:=len(aItePed)
Local nDescPed := 0
While nCont > 0    
	if aItePed[nCont,11] == 1	//exclui o item de bonificacao
		aDel(aItePed,nCont)      
		aSize(aItePed,len(aItePed)-1)
	Else  
		If !Empty(aItePed[nCont,10])
        	aItePed[nCont,10] := ""
		Endif
		//break
	Endif
	nCont--
Enddo	

//Regra de Bonificacao
RGAdcBon(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aItePed)
RGDescTotPed(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aCabPed[11,1], @nDescPed)
Return Nil