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
Function PVGravarPed(aCabPed,aItePed,aColIte,cCondInt,cSfaInd, cSfaFpg, lChk1, aObj)
Local nCont :=0
Local nPrDscRg := 0	
Local nDescReg := 0
Local nDescInd := 0
Local lConfirmPed :=.F.
Local lVrfItem	:= .T.
Local cBloqPed	:= SFGetMv("MV_SFBLPED",.F.,"F")
Local nRecno	:= 0

Default lChk1 := .F.

HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF") + "MV_VALMIN"))
	If aCabPed[12,1] < Val(HCF->HCF_VALOR)
		MsgAlert(STR0013+AllTrim(HCF->HCF_VALOR))//"Pedido inferior ao valor mínimo de R$"
		Return nil	
	EndIf
EndIf	


//Verifica Limite de Credito
If aCabPed[2,1] = 1 
//	If !VrfLimCred(cCodCli,cLojaCli, nTotPed,"")
	If VrfLimCred(aCabPed[3,1],aCabPed[4,1], aCabPed[11,1],"") = "2"
		Return Nil
	EndIf
Else
//	If !VrfLimCred(cCodCli,cLojaCli, nTotPed,cNumPed)
	If VrfLimCred(aCabPed[3,1],aCabPed[4,1], aCabPed[11,1],aCabPed[1,1]) = "2"
		Return Nil
	EndIf
EndIf

// Verifica Condição de Pagamento
dbSelectArea("HE4")
dbSetOrder(1)
If !Empty(aCabPed[7,1])
	If !HE4->(dbSeek(RetFilial("HE4") + aCabPed[7,1]))
		MsgAlert(STR0012, STR0010) // "Condição de pagamento inválida." ### "Gravação do Pedido"
		Return Nil
	EndIf
Else
	MsgAlert(STR0012, STR0010) // "Condição de pagamento inválida." ### "Gravação do Pedido"
	Return Nil
EndIf

// Verifica Tabela de Preço
dbSelectArea("HTC")
dbSetOrder(1)
If !Empty(aCabPed[8,1])
	If !HTC->(dbSeek(RetFilial("HTC") + aCabPed[8,1]))
		MsgAlert(STR0014, STR0010) // "Tabela de Preço inválida." ### "Gravação do Pedido"
		Return Nil
	EndIf
Else
	MsgAlert(STR0014, STR0010) // "Tabela de Preço inválida." ### "Gravação do Pedido"
	Return Nil
EndIf

// Verifica Transportadora
HA4->(dbSetOrder(1))
If !Empty(aCabPed[13,1]) .And. !HA4->(dbSeek(RetFilial("HA4") + aCabPed[13,1]))
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

MsgStatus("Calculando pedido")

//Regra de Bonificacao
RGAdcBon(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aItePed)

If ExistBlock("SFAPV003")
	//Ponto de entrada para calculo de Regra de Descto. no Total do Pedido
	nDescReg := ExecBlock("SFAPV003",.F.,.F.,{aCabPed,aItePed})
ElseIf SFGetMv("MV_SFRGDSC",,"S") == "S"
	//Regra de Descto. no Total do Pedido
	RGDescTotPed(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], aCabPed[15,1], aCabPed[11,1], @nDescReg, @nPrDscRg)
EndIF

//Valor da Indenização
nDescInd := aCabPed[14,1]

//Percentual do Desconto de regra
If nPrDscRg > 0
	aCabPed[21,1] := nPrDscRg	
EndIf

PVConfirmPed(aItePed, aCabPed, nDescInd, nDescReg, cSfaInd, @lConfirmPed,.F., aObj)
ClearStatus()
If !lConfirmPed
	Return Nil
Endif
// Ponto de Entrada Permitindo efetuar novas consistencias no momento de clicar em gravar o Pedido de Venda
// E logo apos todas as verificacoes do padrao acima
If ExistBlock("SFAPV013")
	lVrfItem := ExecBlock("SFAPV013", .F., .F., {aCabPed,aItePed,aColIte,cCondInt,cSfaInd, cSfaFpg}) // Mesmos Itens recebidos na funcao onde este ponto esta criado
	If !lVrfItem
		Return Nil
	EndIf
EndIf
MsgStatus("Gravando Pedido de Venda.")
#IFNDEF __PALM__
	GETSPACE("HC5",1)
#ENDIF
dbSelectArea("HC5")
dbSetOrder(1)

//AllTrim no Campo Observacao
aCabPed[9,1]:=Substr(aCabPed[9,1],1,Len(HC5->HC5_MENOTA))

//Aplica descontos do cabecalho nos itens
//PvDescCab(aItePed, aCabPed)

// Se for Inclusao ou Ult. Pedidos
If aCabPed[2,1] == 1 .Or. aCabPed[2,1] == 4
	dbAppend()
	For nI:=1 to Len(aCabPed)
		If aCabPed[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
        	HC5->(FieldPut(HC5->(aCabPed[nI,2]), aCabPed[nI,1]))
	 	Endif	
	Next 
	HC5->HC5_FILIAL   	:= RetFilial("HC5")
	HC5->HC5_COTAC 	:= aCabPed[1,1]
	HC5->HC5_QTDITE	:= Len(aItePed)
	HC5->HC5_TIPO 	:= "N"
	HC5->HC5_VEND1 	:= HA3->HA3_COD
	HC5->HC5_EMISS 	:= Date()
	HC5->HC5_STATUS	:= "N"
	HC5->HC5_VALOR 	:= aCabPed[12,1]	//Total
	dbCommit()

Else
	dbSeek(RetFilial("HC5") + aCabPed[1,1])
	if HC5->(Found())
		For nI:=1 to Len(aCabPed)
	 		If aCabPed[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
           		HC5->(FieldPut(HC5->(aCabPed[nI,2]), aCabPed[nI,1]))
	    	Endif	
		Next 
		HC5->HC5_STATUS := "N"
		HC5->HC5_QTDITE := Len(aItePed)
		HC5->HC5_VALOR 	:= aCabPed[12,1]	//Total
		dbCommit()
	Endif

	dbSelectArea("HC6")
	dbSetOrder(1)
	dbSeek(RetFilial("HC6") + aCabPed[1,1]) 
	While !Eof() .And. HC6->HC6_NUM = aCabPed[1,1]
	    dbDelete() 
	    dbSkip()
	EndDo
Endif

//Bloqueio de pedido
If cBloqPed == "T"
	dbSelectArea("HC5")
	HC5->(dbSeek(RetFilial("HC5") + aCabPed[1,1]))
	nRecno := HC5->(RECNO())
	If lChk1 // Bloquear
		HC5->HC5_STATUS := "BS"
		dbCommit()
		SetDirty("HC5",nRecno,.F.)
	Else // Liberar
		HC5->HC5_STATUS := "N"
		dbCommit()
		SetDirty("HC5",nRecno,.T.)
	EndIf
EndIf

dbSelectArea("HC6")
dbSetOrder(1)
#IFNDEF __PALM__
	GETSPACE("HC6",len(aItePed))
#ENDIF
For nCont:=1 to len(aItePed)
	dbAppend() 
	HC6->HC6_FILIAL := RetFilial("HC6")
	HC6->HC6_NUM	:= aCabPed[1,1]
	HC6->HC6_COTAC  := aCabPed[1,1]
	HC6->HC6_ITEM   := StrZero(nCont,3)
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
	HB1->(dbSeek(RetFilial("HB1") + AllTrim(aItePed[nCont,1])))	
	if HB1->(Found())
    	HC6->HC6_UM:=HB1->HB1_UM
    	HC6->HC6_LOCAL:=HB1->HB1_LOCPAD             
 	Endif
    HC6->HC6_ENTREG := aCabPed[10,1]
    HC6->HC6_ICMS   := 0
    HC6->HC6_IPI    := 0
    
	dbCommit() 
	
	//Bloqueio de pedido
	If cBloqPed == "T"
		nRecno := HC6->(RECNO())
		If lChk1 // Bloquear
			HC6->HC6_STATUS := "BS"
			dbCommit()
			SetDirty("HC6",nRecno,.F.)
		Else // Liberar
			HC6->HC6_STATUS := "N"
			dbCommit()
			SetDirty("HC6",nRecno,.T.)
		EndIf
	EndIf
	
Next

GrvAtend(1, aCabPed[1,1], , HC5->HC5_CLI, HC5->HC5_LOJA,)
ClearStatus()
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
	dbSeek(RetFilial("HD7") + cCodRot + cIteRot)
    HD7->HD7_FLGVIS	:="1"
    HD7->HD7_OCO:=""
    dbCommit()
Else
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(RetFilial("HA1") + cCodCli + cLojaCli)
	HA1->HA1_FLGVIS	:="1"
    HA1->HA1_OCO:=""
    dbCommit()
    SetDirty("HA1",HA1->(Recno()),.F.)
Endif

Return Nil

Function PVDtEntr(dDtEntr,oDtEntr)
Local dData		:=	date()
Local dDataAnt	:=	date()
If !Empty(dDtEntr) .And. !dDtEntr=Nil
	dDataAnt :=	dDtEntr
	dDtEntr  := SelectDate(STR0009,dDtEntr) //"Sel.Data Entrega"
Else
	dDtEntr := SelectDate(STR0009,dData) //"Sel.Data Entrega"
Endif
If dDtEntr=Nil .Or. Empty(dDtEntr)
	dDtEntr := dDataAnt
EndIf
SetText(oDtEntr,dDtEntr)
Return Nil

//Aplica descontos do cabecalho nos itens do pedido
/*
Function PvDescCab(aItePed, aCabPed)
Local nX := 0

If aCabPed[18,1] > 0 .Or. aCabPed[18,2] > 0 .Or. aCabPed[18,3] > 0 .Or. aCabPed[18,4] > 0
	For nX := 1 to len(aItePed)
	
	Next
EndIf

Return NIL
*/