#INCLUDE "FDPV102.ch"
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
Function PDGravarPed(aCabPed,aItePed,aColIte,cSfaInd)
Local nCont :=0, nDescPed:= 0.00                                 
Local lConfirmPed :=.F.           

//Consistencia do Pedido
If !PVVrfPed(aCabPed[10,1], aItePed)
	Return Nil	
EndIf

PVConfirmPed(aItePed, aCabPed[12,1], nDescPed, @lConfirmPed,.F.,cSfaInd,aCabPed[14,1])

If !lConfirmPed
	Return Nil
Endif

dbSelectArea("HF1")
dbSetOrder(1)
//AllTrim no Campo Observacao
//aCabPed[9,1]:=Substr(aCabPed[9,1],1,Len(HC5->C5_MENNOTA))
//aCabPed[9,1]:=Alltrim(aCabPed[9,1]) 

// Se for Inclusao ou Ult. Pedidos
If aCabPed[2,1] == 1 .Or. aCabPed[2,1] == 4

	dbAppend()    
	For nI:=1 to Len(aCabPed) 
		If aCabPed[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
           	HF1->(FieldPut(HF1->(aCabPed[nI,2]), aCabPed[nI,1]))
    	Endif	
	Next 
  	
	HF1->F1_QTDITE	:= Len(aItePed)
//	HC5->C5_VEND1 	:= HA3->A3_COD
	HF1->F1_EMISSAO	:= dDataBase
	HF1->F1_STATUS 	:= "N"
	HF1->F1_VALOR 	:= aCabPed[12,1]	//Total
	dbCommit()
Else
	dbSeek(aCabPed[1,1])
	if HF1->(Found())
		For nI:=1 to Len(aCabPed)
	 		If aCabPed[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
           		HF1->(FieldPut(HF1->(aCabPed[nI,2]), aCabPed[nI,1]))
	    	Endif	
		Next 
		HF1->F1_QTDITE	:= Len(aItePed)
		HF1->F1_EMISSAO	:= dDataBase
		HF1->F1_STATUS 	:= "N"
		HF1->F1_VALOR 	:= aCabPed[12,1]	//Total
	
		dbCommit()
	Endif
	dbSelectArea("HD1")
	dbSetOrder(1)
	dbSeek(aCabPed[1,1]) 
	While !Eof() .And. HD1->D1_DOC = aCabPed[1,1]
	    dbDelete() 
	    dbSkip()
	EndDo 
Endif

dbSelectArea("HD1")
dbSetOrder(1)

For nCont:=1 to len(aItePed)
	dbAppend() 
	HD1->D1_DOC	   := aCabPed[1,1]
	HD1->D1_ITEM   := StrZero(nCont,3)
	For nI:=1 to Len(aColIte)         
 		If aColIte[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
			If nI== 5 
				HD1->(FieldPut(HD1->(aColIte[nI,2]), aCabPed[8,1]))
			Else
				HD1->(FieldPut(HD1->(aColIte[nI,2]), aItePed[nCont,nI]))
			Endif
		Endif
	Next

	dbCommit() 
	
Next	

GrvAtend(1, aCabPed[1,1], , HF1->F1_FORNECE, HF1->F1_LOJA,)
MsgAlert(STR0003,STR0004) //"Pedido gravado com sucesso!"###"Pedido"

CloseDialog() 
Return Nil
   
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACCrgdev            ³Autor - Paulo Lima   ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega array dos ultimos pedidos e Pedidos	 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCli: Codigo do Cliente, cLojaCli: Loja do Cliente	  ³±±
±±³			 ³ aPedido, aUltPed: Arrays de Ult. Pedidos e Pedidos		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ACCrgDev(cCodCli, cLojaCli, aDev)
Local cNumDev := ""
dbSelectArea("HF1")
dbSetOrder(2)
dbSeek( cCodCli+cLojaCli,.f. )
While !Eof() .and. HF1->F1_FORNECE == cCodCli .and. HF1->F1_LOJA == cLojaCli
	cStPedido:= ""
	cNumDev:=""
	cNumDev:=HF1->F1_DOC
	if HF1->F1_STATUS = "N"
		If HF1->(IsDirty())		//Nao transmitido
			AADD(aDev,{cNumDev,HF1->F1_EMISSAO,HF1->F1_VALOR}) 
		Endif
	Endif

	dbSkip()  
	
Enddo

Return Nil                                                        
