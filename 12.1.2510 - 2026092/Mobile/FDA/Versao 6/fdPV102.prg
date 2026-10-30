#INCLUDE "FDPV102.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Gravar o Pedido     ³Autor - Paulo Lima   ³ Data ³03/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aItePed, nItePed											  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Exibir em outro Dialog o Detalhe do Pedido			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function PVGravarPed(aCabPed,aItePed,aColIte,cCondInt,cSfaInd, cSfaFpg)
Local nCont :=0, nDescPed:= 0.00                                 
Local lConfirmPed :=.F.           

If cSfaFpg = "T" .And. Empty(aCabPed[15,1])
	MsgStop(STR0001, STR0002) //"Favor preencher a forma de pagamento."###"Forma de Pagamento"
	Return Nil
EndIf
//Verifica Limite de Credito
If aCabPed[2,1] = 1 
//	If !VrfLimCred(cCodCli,cLojaCli, nTotPed,"")
	If VrfLimCred(aCabPed[3,1],aCabPed[4,1], aCabPed[11,1],"") == "2"
		Return Nil
	EndIf
Else
//	If !VrfLimCred(cCodCli,cLojaCli, nTotPed,cNumPed)
	If VrfLimCred(aCabPed[3,1],aCabPed[4,1], aCabPed[11,1],aCabPed[1,1]) == "2"
		Return Nil
	EndIf
EndIf

//Consistencia do Pedido
If !PVVrfPed(aCabPed[10,1], aItePed)
	Return Nil	
EndIf

If cCondInt == "F"
	//Regra de Negocio (cliente, loja, condicao, tabela, forma pgto)
	If !RGVrfNeg(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1],"")
		Return nil
	Endif             
Endif

//Regra de Bonificacao
RGAdcBon(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aItePed)

//Regra de Descto. no Total do Pedido
RGDescTotPed(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aCabPed[11,1], @nDescPed)

PVConfirmPed(aItePed, aCabPed[11,1], nDescPed, @lConfirmPed,.F.,cSfaInd,aCabPed[14,1])
If !lConfirmPed
	Return Nil
Endif

dbSelectArea("HC5")
dbSetOrder(1)

//AllTrim no Campo Observacao
aCabPed[9,1]:=Substr(aCabPed[9,1],1,Len(HC5->C5_MENNOTA))
aCabPed[9,1]:=Alltrim(aCabPed[9,1]) 

// Se for Inclusao ou Ult. Pedidos
If aCabPed[2,1] == 1 .Or. aCabPed[2,1] == 4
	dbAppend()    
	For nI:=1 to Len(aCabPed) 
		If aCabPed[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
           	HC5->(FieldPut(HC5->(aCabPed[nI,2]), aCabPed[nI,1]))
    	Endif	

	Next 
  	
	HC5->C5_COTAC 	:= aCabPed[1,1]
	HC5->C5_QTDITE	:= Len(aItePed)
	HC5->C5_TIPO 	:= "N"
	HC5->C5_VEND1 	:= HA3->A3_COD
	HC5->C5_EMISS 	:= Date()
	HC5->C5_STATUS	:= "N"
	HC5->C5_VALOR 	:= aCabPed[12,1]	//Total
	dbCommit()

/*
	HC5->C5_NUM		:= cNumPed
	HC5->C5_COTAC 	:= cNumPed
	HC5->C5_CLI		:= HA1->A1_COD
	HC5->C5_LOJA 	:= HA1->A1_LOJA
	HC5->C5_TIPO 	:= "N"
	HC5->C5_COND 	:= Substr(aCond[nCond],1,at("-",aCond[nCond])-1)
	HC5->C5_VEND1 	:= HA3->A3_COD
	HC5->C5_MENNOTA	:= cObs
	HC5->C5_EMISS 	:= Date()  
	If Empty(aTab[nTab])
		HC5->C5_TAB := "1"
	Else
		HC5->C5_TAB := aTab[nTab]
	EndIf	
	HC5->C5_STATUS	:= "N"
	HC5->C5_VALOR 	:= nTotPed 
	HC5->C5_QTDITE	:= Len(aItePed)
*/
	
Else
	dbSeek(aCabPed[1,1])
	if HC5->(Found())
		For nI:=1 to Len(aCabPed)
	 		If aCabPed[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
           		HC5->(FieldPut(HC5->(aCabPed[nI,2]), aCabPed[nI,1]))
	    	Endif	
		Next 
		HC5->C5_EMISS  := Date()
		HC5->C5_STATUS := "N"
		HC5->C5_QTDITE := Len(aItePed)
		HC5->C5_VALOR 	:= aCabPed[12,1]	//Total
		dbCommit()
	Endif

	dbSelectArea("HC6")
	dbSetOrder(1)
	dbSeek(aCabPed[1,1]) 
	While !Eof() .And. HC6->C6_NUM = aCabPed[1,1]
	    dbDelete() 
	    dbSkip()
	EndDo 
Endif

dbSelectArea("HC6")
dbSetOrder(1)

For nCont:=1 to len(aItePed)
	dbAppend() 
	HC6->C6_NUM	   := aCabPed[1,1]
	HC6->C6_COTAC  := aCabPed[1,1]
	HC6->C6_ITEM   := StrZero(nCont,3)
	For nI:=1 to Len(aColIte)         
 		If aColIte[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
			If nI== 5 
				HC6->(FieldPut(HC6->(aColIte[nI,2]), aCabPed[8,1]))
			Else
				HC6->(FieldPut(HC6->(aColIte[nI,2]), aItePed[nCont,nI]))
			Endif
		Endif
	Next

	HB1->(dbSetOrder(1))
	HB1->(dbSeek(AllTrim(aItePed[nCont,1])))	
	if HB1->(Found())
    	HC6->C6_UM:=HB1->B1_UM
    	HC6->C6_LOCAL:=HB1->B1_LOCPAD             
 	Endif
    HC6->C6_ENTREG := aCabPed[10,1]
    HC6->C6_ICMS   := 0
    HC6->C6_IPI    := 0  
  
/*
    HC6->C6_PROD   := aItePed[nCont,1]
    HC6->C6_GRUPO  := aItePed[nCont,3]
    HC6->C6_QTDVEN := aItePed[nCont,4]
    HC6->C6_PRCVEN := aItePed[nCont,6]
    HC6->C6_VALOR  := aItePed[nCont,9]
    HC6->C6_TES    := aItePed[nCont,8]
    HC6->C6_DESC   := aItePed[nCont,7]
//    HC6->C6_ACRES  := 0
    HC6->C6_ICMS   := 0
    HC6->C6_IPI    := 0  
    HC6->C6_BONIF  := aItePed[nCont,11]
    //HC6->C6_TABELA:=aItePed[nCont,5]
	If Empty(aTab[nTab])
		HC6->C6_TABELA 	:= "1"
	Else
		HC6->C6_TABELA 	:= aTab[nTab]
	EndIf	
*/                                                      
	dbCommit() 
	
Next	

GrvAtend(1, aCabPed[1,1], , HC5->C5_CLI, HC5->C5_LOJA,)
MsgAlert(STR0003,STR0004) //"Pedido gravado com sucesso!"###"Pedido"

/*
if !nOperacao=2
	PVPosRot(cCodCli, cLojaCli, cCodRot, cIteRot)
Endif
*/
CloseDialog() 

Return Nil

Function PVVrfPed(dDtEntr, aItePed)
Local dData :=date()
If Empty(dDtEntr)
  MsgStop(STR0005,STR0006) //"Escolha uma Data de Entrega!"###"Verifica Pedido"
  Return .F.
elseif dData > dDtEntr
  MsgStop(STR0007,STR0006) //"Data inválida! A Data de Entrega deverá ser superior ou igual a data atual."###"Verifica Pedido"
  Return .F.
elseif Len(aItePed)<=0
  MsgStop(STR0008,STR0006) //"Inclua um Item nesse Pedido!"###"Verifica Pedido"
  Return .F.
Endif

Return .T.

Function PVPosRot(cCodCli, cLojaCli, cCodRot, cIteRot)
//Funcao que positiva Roteiro
If !Empty(cCodRot)
	dbSelectArea("HD7")
	dbSetOrder(1)
	dbSeek(cCodRot + cIteRot)
    HD7->AD7_FLGVIS	:="1"
    HD7->AD7_OCO:=""
Else
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(cCodCli + cLojaCli)
	HA1->A1_FLGVIS	:="1"
    HA1->A1_OCO:=""
Endif					
dbCommit()	          
Return Nil


Return Nil

Function PVDtEntr(dDtEntr,oDtEntr)
Local dData :=date()
if !Empty(dDtEntr) .And. !dDtEntr=Nil 
	dDtEntr := SelectDate(STR0009,dDtEntr) //"Sel.Data Entrega"
else
	dDtEntr := SelectDate(STR0009,dData) //"Sel.Data Entrega"
Endif
SetText(oDtEntr,dDtEntr)
Return Nil