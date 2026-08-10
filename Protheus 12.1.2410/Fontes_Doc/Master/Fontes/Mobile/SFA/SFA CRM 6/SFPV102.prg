#INCLUDE "SFPV102.ch"
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

//Verifica Limite de Credito
If aCabPed[2,1] = 1 
	If VrfLimCred(aCabPed[3,1],aCabPed[4,1], aCabPed[11,1],"") = "2"
		Return Nil
	EndIf
Else
	If VrfLimCred(aCabPed[3,1],aCabPed[4,1], aCabPed[11,1],aCabPed[1,1]) = "2"
		Return Nil
	EndIf
EndIf

// Verifica Condição de Pagamento
dbSelectArea("HE4")
dbSetorder(1)
If !HE4->(dbSeek(aCabPed[7,1]))
	MsgAlert(STR0012, STR0010) // "Condição de pagamento inválida." ### "Gravação do Pedido"
	Return Nil
EndIf

// Verifica Transportadora
dbSelectArea("HA4")
dbSetorder(1)
If !Empty(aCabPed[13,1]) .And. !HA4->(dbSeek(aCabPed[13,1]))
	MsgAlert(STR0011, STR0010) // "Transportadora Inválida." ### "Gravação do Pedido"
	Return Nil
EndIf

// Verifica Forma de Pagamento
If cSfaFpg = "T" .And. Empty(aCabPed[15,1])
	MsgStop(STR0001, STR0002) //"Favor preencher a forma de pagamento."###"Forma de Pagamento"
	Return Nil
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
EndIf

dbSelectArea("HC5")
dbSetOrder(1)

//AllTrim no Campo Observacao
aCabPed[9,1] := Substr(aCabPed[9,1],1,Len(HC5->C5_MENNOTA))

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
Else
	If HC5->(dbSeek(aCabPed[1,1]))
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
	EndIf

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
For nCont := 1 To len(aItePed)
	dbAppend() 
	HC6->C6_NUM	  := aCabPed[1,1]
	HC6->C6_COTAC := aCabPed[1,1]
	HC6->C6_ITEM  := StrZero(nCont,3)
	For nI := 1 to Len(aColIte)         
 		If aColIte[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
			If nI == 5  // Grava a mesma tabela de Preco que esta no cabecalho
				HC6->(FieldPut(HC6->(aColIte[nI,2]), aCabPed[8,1]))
			Else
				HC6->(FieldPut(HC6->(aColIte[nI,2]), aItePed[nCont,nI]))
			Endif
		Endif
	Next

	HB1->(dbSetOrder(1))
	If HB1->(dbSeek(AllTrim(aItePed[nCont,1])))	
    	HC6->C6_UM    := HB1->B1_UM
    	HC6->C6_LOCAL := HB1->B1_LOCPAD             
 	EndIf

    HC6->C6_ENTREG := aCabPed[10,1]
    HC6->C6_ICMS   := 0
    HC6->C6_IPI    := 0  
	dbCommit() 
Next	

GrvAtend(1, aCabPed[1,1], , HC5->C5_CLI, HC5->C5_LOJA,)
MsgAlert(STR0003,STR0004) //"Pedido gravado com sucesso!"###"Pedido"

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