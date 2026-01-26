#INCLUDE "SFPV001.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± < INDICE DAS FUNCOES  > ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 

   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Pedidos de Venda    ³Autor - Paulo Lima   ³ Data ³27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±³			 ³ InitPedido -> Inicia o Mod. de Pedidos		 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
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

Function InitPV(aCabPed,aItePed,aCond,aTab,aColIte)
Local oDlg,oCab,oObs,oObj,oBrwItePed,oDet,oFldCN
Local aObj := { {},{},{},{},{},{} }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := ""
Local nItePed:=0 , cPermCDNeg:="N"
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := "", cSfaFpgIni := ""
Local cFrete := "", cSfaFre := "", aTpFrete := {STR0001, STR0002}, nOpcFre := If(aCabPed[16,1]="C",1,2) //"CIF"###"FOB"
Local aPrdPrefix := {}, cPrdPrefix := "", cPrefix := "", nPreTimes := 0, nPreLen := 0
Local nPos := 0, cTipoCnd := ""
Local oCol
Local cA1GrpVen:=""      
Local cCondNeg:=GetMV("MV_NUMPARC","0")

// Configura parametros
SetParam(aCabPed[3,1],aCabPed[4,1], cCliente, @cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix,@cA1GrpVen )

// Consulta Condicao de Pagamento 
Aadd(aCmpPag,{STR0003,HE4->(FieldPos("E4_COD")),30}) //"Código"
Aadd(aCmpPag,{STR0004,HE4->(FieldPos("E4_DESCRI")),70}) //"Descrição"
Aadd(aIndPag,{STR0003,1}) //"Código"

//Consulta Tabela de Preco
Aadd(aCmpTab,{STR0003,HTC->(FieldPos("TC_TAB")),30}) //"Código"
Aadd(aCmpTab,{STR0004,HTC->(FieldPos("TC_DESCRI")),100}) //"Descrição"
Aadd(aIndTab,{STR0003,1}) //"Código"

//Consulta Transportadora
Aadd(aCmpTra,{STR0003,HA4->(FieldPos("A4_COD")),40}) //"Código"
Aadd(aCmpTra,{STR0005,HA4->(FieldPos("A4_NOME")),100}) //"Nome"
Aadd(aIndTra,{STR0003,1}) //"Código"

//Consulta Forma de Pagamento
Aadd(aCmpFpg,{STR0003,HTP->(FieldPos("X5_CHAVE")),20}) //"Código"
Aadd(aCmpFpg,{STR0006,HTP->(FieldPos("X5_DESCRI")),60}) //"Descricao"
Aadd(aIndFpg,{STR0003,1}) //"Código"

If aCabPed[2,1] = 1 .Or. aCabPed[2,1] = 4
	DEFINE DIALOG oDlg TITLE STR0007 //"Inclusão do Pedido"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo pedido)
	If aCabPed[2,1] = 1
		aCabPed[7,1] := cCond
		aCabPed[8,1] := cTabPrc
		aCabPed[13,1]:= cTransp
		aCabPed[15,1]:= cSfaFpgIni
		aCabPed[16,1]:= cFrete
		nOpcFre      := If(aCabPed[16,1]="C",1,2)
	Endif
Else 
	DEFINE DIALOG oDlg TITLE STR0008 //"Alteração do Pedido"
EndIf

@ 15,05 GET oObj VAR cCliente SIZE 157,15 READONLY MULTILINE OF oDlg
AADD(aObj[1],oObj) 
@ 130,71 BUTTON oObj CAPTION STR0009  ACTION PVGravarPed(aCabPed,aItePed,aColIte,cCondInt,cSfaInd,cSfaFpg) SIZE 40,12 OF oDlg //"Gravar"
AADD(aObj[1],oObj) 
@ 130,116 BUTTON oObj CAPTION STR0010 ACTION PVFecha(aCabPed[2,1]) SIZE 40,12 OF oDlg //"Cancelar"
AADD(aObj[1],oObj) 
@ 130,2 SAY STR0011  of oDlg //"T:"
#ifdef __PALM__
	@ 130,12 GET oObj VAR aCabPed[12,1] PICTURE "@E 9,999,999.99" READONLY SIZE 52,12 of oDlg
	AADD(aObj[1],oObj) 
#else
	@ 130,12 GET oObj VAR aCabPed[12,1] PICTURE "@E 9,999,999.99" READONLY SIZE 59,12 of oDlg
	AADD(aObj[1],oObj) 
#endif

ADD FOLDER oCab CAPTION STR0012 OF oDlg //"Principal"
@ 30,01 TO 127,158 CAPTION STR0012 OF oCab //"Principal"
// Condicao de Pagamento
@ 40,42 GET oObj VAR aCabPed[7,1] READONLY SIZE 30,12 of oCab
AADD(aObj[2],oObj)
@ 40,03 BUTTON oObj CAPTION STR0013 SIZE 34,10 ACTION PVCond(aCabPed,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt,oFldCN) of oCab  //"Pagto:"
AADD(aObj[2],oObj)
// Tabela de Preco
@ 40,119 GET oObj VAR aCabPed[8,1] READONLY SIZE 30,12 of oCab
AADD(aObj[2],oObj)
@ 40,80 BUTTON oObj CAPTION STR0014 SIZE 34,10 ACTION PVTrocaTab(aCabPed,aObj,aCmpTab,aIndTab,aColIte,aItePed,cCondInt,1,cA1GrpVen) of oCab //"Tabela:"
AADD(aObj[2],oObj)

// Data de Entrega
@ 54,42 GET oObj VAR aCabPed[10,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 54,03 BUTTON oObj CAPTION STR0015 SIZE 34,10 ACTION PVDtEntr(aCabPed[10,1],aObj[2,5]) of oCab //"Entrg.:"
AADD(aObj[2],oObj)
// Transportadora
@ 68,42 GET oObj VAR aCabPed[13,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj)
@ 68,03 BUTTON oObj CAPTION STR0016 SIZE 34,10 ACTION SFConsPadrao("HA4",aCabPed[13,1],aObj[2,7],aCmpTra,aIndTra,) of oCab //"Transp:"
AADD(aObj[2],oObj)

If cSfaFpg = "T"
	@ 82,03 BUTTON oObj CAPTION STR0017 SIZE 34,10 ACTION SFConsPadrao("HTP",aCabPed[15,1],aObj[2,10],aCmpFpg,aIndFpg,) of oCab //"F.Pagto"
	AADD(aObj[2],oObj)// 9 - Get F.Pagto
	@ 82,42 GET oObj VAR aCabPed[15,1] SIZE 50,12 of oCab
	AADD(aObj[2],oObj)// 10 - Label F.Pagto
Else
	AADD(aObj[2],"") // 9 - Get F.Pagto
	AADD(aObj[2],"") // 10 - Label F.Pagto
EndIf

// Indenizacao
HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFAIND"))
	cSfaInd := AllTrim(HCF->CF_VALOR)
Else 
	cSfaInd := "F"
EndIf	

If cSfaInd == "T"
	@ 96,03 SAY STR0018 OF oCab //"Inden:"
	AADD(aObj[2],oObj) // 11 - Label Indenizacao
	@ 96,42 GET oObj VAR aCabPed[14,1] VALID ChkIndeni(aCabPed) SIZE 50,12 of oCab
	AADD(aObj[2],oObj) // 12 - Getl Indenizacao
Else
	AADD(aObj[2],"") // 11 - Label Indenizacao
	AADD(aObj[2],"") // 12 - Getl Indenizacao
EndIf


// Tipo de Frete
HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFAFRE"))
	cSfaFre := AllTrim(HCF->CF_VALOR)
Else 
	cSfaFre := "F"
EndIf	
If cSfaFre == "T"
	@ 110,03 SAY STR0019 OF oCab //"Frete:"
	AADD(aObj[2],oObj)// 13 - Label Frete
	@ 110,30 COMBOBOX oObj VAR nOpcFre ITEMS aTpFrete ACTION UpdTpFrete(aCabPed, aTpFrete, nOpcFre) SIZE 30,40 of oCab
	AADD(aObj[2],oObj)// 14 - Get Frete
Else
	AADD(aObj[2],"")// 13 - Label Frete
	AADD(aObj[2],"") // 14 - Get Frete
EndIf

//Peso do Pedido
If 	cSfaPeso == "T"
	@ 110,80 SAY STR0020 OF oCab //"Peso:"
	AADD(aObj[2],oObj) // 15 - Label Peso
	@ 110,110 GET oObj VAR aCabPed[17,1] PICTURE "@E 999,999.99" READONLY SIZE 49,12 of oCab
	AADD(aObj[2],oObj)// 16 - Get Peso
Else
	AADD(aObj[2],"") // 15 - Label Peso
	AADD(aObj[2],"")// 16 - Get Peso
EndIf


ADD FOLDER oDet CAPTION STR0021 OF oDlg //"Detalhe"
@ 30,01 TO 127,158 CAPTION STR0021 OF oDet //"Detalhe"
@ 40,03 BROWSE oBrwItePed SIZE 134,82 of oDet
SET BROWSE oBrwItePed ARRAY aItePed
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 1 HEADER STR0022 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 2 HEADER STR0023 WIDTH 130  //Acresc. 11/06/03 //"Descr."
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 4 HEADER STR0024 WIDTH 35 //"Qtde"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 6 HEADER STR0025 WIDTH 35 //"Preco"
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 7 HEADER STR0026 WIDTH 35 //"Desc."
ADD COLUMN oCol TO oBrwItePed ARRAY ELEMENT 9 HEADER STR0027 WIDTH 45 //"Sub Tot."
AADD(aObj[3],oBrwItePed)

@ 40,140 BUTTON oObj CAPTION "N" SIZE 16,12 ACTION PVItePed(1,aItePed, @nItePed, aColIte, aCabPed,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix) of oDet
AADD(aObj[3],oObj)
@ 54,140 BUTTON oObj CAPTION STR0028 SIZE 16,12 ACTION PVItePed(2,aItePed, @nItePed, aColIte, aCabPed,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix) of oDet //"A"
AADD(aObj[3],oObj)
@ 68,140 BUTTON oObj CAPTION STR0029 SIZE 16,12 ACTION PVExcIte(aItePed,@nItePed, aCabPed,aObj, .F.,1) of oDet //"E"
AADD(aObj[3],oObj)
@ 82,140 BUTTON oObj CAPTION "D" SIZE 16,12 ACTION PVDetIte(aItePed,aObj) of oDet
AADD(aObj[3],oObj)

ADD FOLDER oObs CAPTION STR0030 OF oDlg //"Obs"
@ 30,01 TO 127,158 CAPTION STR0031 OF oObs //"Observação"
@ 40,05 GET oObj VAR aCabPed[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
AADD(aObj[4],oObj)

//Se a condicaçao negociada está habilitada
IF cCondNeg="4" .And. cTipoCnd="9"

   FldCndNeg(aObj,oObj,aCabPed,oDlg,oFldCN )	
	
ENDIF
	
ACTIVATE DIALOG oDlg

Return Nil

// Mostra/Oculta os controles 
//
Function ExibeCdN(aObj,aCabPed)    
Local cRet := .F.
Local cChave := ""
Local ni
cRet:=.F.                   
cChave:=aCabPed[7,1]       

if HE4->( dbseek(cChave) )
   If HE4->E4_TIPO="9"
	  cRet :=.T.
   endif
endif                     

If cRet 
    // Se a condicao nao for negociada nao exibe
    For ni:=1 to Len(aObj[5]) 
        ShowControl(aObj[5,ni]) 
    next     
else
    MsgStop( "Cond:"+ HE4->E4_COD + " Tipo:" + HE4->E4_TIPO + " Nao permite informar outros vencimentos", "Aviso" ) 
    For ni:=1 to Len(aObj[5]) 
        HideControl(aObj[5,ni]) 
    next     
    Return .F. 
endif    

Return 
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DtNasc              ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ permite selecao de uma data								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dDtaNasc: Data selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function SelData(oDt,dDtVenc)
Local dData :=date()
if !Empty(dDtVenc) .And. !dDtVenc=Nil 
	dDtVenc:= SelectDate("Sel.Data Vencimento",dDtVenc) //"Sel.Data Vencimento"
else
	dDtVenc := SelectDate("Sel.Data Vencimento",dData) //"Sel.Data Vencimento"
Endif

If dDtVenc<Date() 
   MsgAlert( "Data invalida! " ) 
   Return .F. 
Else          
   SetText(oDt,dDtVenc)
   Return .T. 
Endif 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldDtv              ³Autor: Marcelo Vieira³ Data ³02.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±ÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VldDtv(dVenc)

If dVenc<Date() 
   MsgAlert( "Data invalida! " ) 
   Return .F. 
Else
   Return .T. 
Endif 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ValdTot()           ³Autor: Marcelo Vieira³ Data ³02/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ permite selecao de uma data								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function VldTot(nTotalPed,nParc1,nParc2,nParc3,nParc4) 
Local nTotParc := 0
nTotParc := nParc1+nParc2+nParc3+nParc4 
if nTotParc <  nTotalPed 
   Return .F. 
else    
   Return .T. 
Endif
