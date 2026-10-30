#INCLUDE "FDNF101.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Adiciona Itens      ³Autor-Marcelo vieira |Data  ³01/07/03 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Notas             					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oLbxIteNot,aLbxIteNot, aIteNot, aTab, nTab, aCond ,         ´±±
±±³          ³nCond, cProd, oTxtProd, nQtde, oTxtQtde, nPrc, oTxtPrc, 	  ´±±
±±³			 ³nDesc, oTxtDesc, nTotPed, oTxtTotPed                        ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Adicionar os Itens para a Gravacao na Tab. PedidoI         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function NFGrvIte(aColIteNf,aIteNot,nIteNot,aCabNot,aObj,cManTes,cProDupl,nOpIte,nOp,cCF,cGeraDup,oSaldoEst,nSaldoEst)
Local nSubTotI :=0, nLin
Local cCalcIPI:="N",cCalcICM:="N"

If !NFVrfIte(aColItenf,aItenot,aCabnot,cProDupl,nOpIte,nSaldoEst)
	Return Nil
Endif

aColItenf[8,1] := aColItenf[6,1] * aColItenf[23,1]   

//Subtrair primeiro o item do Valor Total (na alteracao)
If nIteNot <> 0
	NFCalcNf(aCabNot,aColIteNf,aIteNot,nIteNot,.F.,,.F.) 
Endif

NFSetTaxas(aColIteNf,@cCalcIPI,@cCalcICM,@cCF,@cGeraDup)

//aCabNot[15,1] := aCabNot[15,1] + aColItenf[8,1] 

//Calcula o Valor do Item
NFCalcNf(aCabNot,aColIteNf,aIteNot,nIteNot,.T.,,.F.) 

//Calcula IPI
If cCalcIPI="S"
   aColItenf[9,1]:= aColItenf[8,1] * ( HB1->HB1_IPI/100)
   aCabNot[15,1] := aCabNot[15,1] + aColItenf[9,1]          
Endif           
//Calcula ICMS
if cCalcICM="S"
   aColItenf[10,1]:= aColItenf[8,1] * ( HB1->HB1_PICM/100)
   //Se o cliente quiser cobrar o ICMS  
   //aCabNot[15,1] := aCabNot[15,1] + aColItenf[10,1]             
endif        
		
aCabNot[35,1] := Round(aCabNot[15,1],2)
SetText( aObj[1,4],aCabNot[35,1] )

if nIteNot=0
	AADD(aIteNot,Array(Len(aColIteNf)))
	For nI := 1 to Len(aColIteNf)
		aIteNot[Len(aIteNot),nI] := aColIteNf[nI,1]
	Next
	nIteNot:=Len(aIteNot)
Else
	For nI:=1 to Len(aColIteNf)
		aIteNot[nIteNot,nI]:= aColIteNf[nI,1]
	Next
Endif

nLin := GridRow(aObj[3,1])
aProduto[nLin,3] :=	 aColItenf[6,1]
aProduto[nLin,4] := aColItenf[23,1] // preco unitario
aProduto[nLin,5] := aColItenf[13,1] // Desconto
aProduto[nLin,6] := aColItenf[10,1] // valor icm
aProduto[nLin,7] := aColItenf[9,1] // Vl IPI
aProduto[nLin,8] := aColItenf[8,1] // Vl Total

//SetTExt(oSaldoEst,nSaldoEst )

NFLimpaItem(aColItenf,aObj,cManTes)
GridSetRow(aObj[3,1],nLin+1)
SetFocus(aObj[3,1])

Return Nil

Function NFVrfIte(aColIteNf,aIteNot,aCabNot,cProDupl,nOpIte,nSaldoEst)
Local nDescMax := 0
Local cCod     := aColIteNf[3,1]

HB1->(dbSetOrder(1))
HB1->(dbSeek( RetFilial("HB1")+cCod ))
If HB1->(FieldPos("B1_DESCMAX")) <> 0
	nDescMax := HB1->HB1_DESCMAX
Else
	nDescMax := 100
Endif

//Valida se o produto ja foi incluido neste pedido
If cProDupl == "F" .And. nOpIte==1 //novo item
	If ScanArray(aIteNot, cCod ,,,3) > 0
		MsgStop(STR0001,STR0002) //"Este produto ja foi incluido!"###"Verifica Item"
		Return .F.
	EndIf
EndIf

If Empty(cCod)
	MsgStop(STR0003,STR0002) //"Escolha um Produto!"###"Verifica Item"
	Return .f.
Elseif aColIteNf[6,1] == 0
	MsgStop(STR0004,STR0002) //"Escreva a Qtde!"###"Verifica Item"
	Return .f.
Elseif aColItenf[6,1] > nSaldoEst
	MsgStop(STR0005 + str(nSaldoEst,3,2) ,STR0002) //"Qtde acima do estoque disponível: "###"Verifica Item"
	Return .f.
Elseif aColIteNf[23,1] == 0
	MsgStop(STR0006,STR0002) //"Escolha/Escreva o Preço!"###"Verifica Item"
	Return .f.
Elseif aColIteNf[13,1] > nDescMax
	MsgStop(STR0007 + str(nDescMax,3,2) + " %",STR0002) //"Desconto acima do máximo permitido: "###"Verifica Item"
	Return .f.
/*Elseif Empty(aColIteNf[8,1])
	MsgStop("Tes não Selecionado!","Verifica Item")
	Return .f.*/
endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Remove Itens        ³Autor -Marcelo vieira Data  |01/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Notas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oLbxIteNot,aLbxIteNot, aIteNot, nIteNot, aTab, nTab,        ´±±
±±³          ³aCond ,nCond, cProd, oTxtProd,nQtde,oTxtQtde, nPrc,oTxtPrc, ´±±
±±³          ³nDesc, oTxtDesc, nTotNot, oTxtTotNot                        ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         				OBSERVACAO.             					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ lClose = .T. -> Quando estou efetuando a exclusao do Item 			  ³±±
±±³	da tela Item do Pedido         										  ³±±
±±³ lClose = .F. -> Quando estou efetuando a exclusao do Item do Pedido   ³±±
±±³	(Botao "E" )                     									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Remove o Item selecionado							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function NFExcIte(aIteNot,nIteNot,aCabNot,aObj,lClose,nTelaNf,oSaldoEst,nSaldoEst)

Local nLin:=0

if len(aIteNot) == 0
	Return Nil
Endif

If nTelaNf == 1  //Tela 1
	nIteNot:=GridRow(aObj[3,1])
Else  //Tela 2
	if len(aProduto) == 0
		return nil
	endif
	nLin := GridRow(aObj[3,1])
	//nIteNot:=GridRow(aObj[3,1]) //nao pode (da erro)
	If aProduto[nLin,3] <= 0
		return nil
	Endif
Endif

If nIteNot > 0 .And. !Empty(aIteNot[nIteNot])
	
	//Efetua a operacao de Atualizacao do Total
	If !lClose
		NFCalcNf(aCabNot,,aIteNot,nIteNot,.F.,aObj,.T.)
	Else
		SetText(aObj[1,4],aCabNot[35,1])	//Atualiza linha do Total
	Endif
	
	//->Remove o Item Selecionado dos Arrays dos Itens do Pedido

    //Recalcula o saldo 
    //nSaldoEst:=nSaldoEst - aItenot[6,1]
    SetTExt(oSaldoEst,nSaldoEst )

	aDel(aIteNot,nIteNot)
	aSize(aIteNot,len(aIteNot)-1)
	If nTelaNf == 1
		SetArray(aObj[3,1],aIteNot)
	Else
		aProduto[nLin,3] := 0
		aProduto[nLin,4] := 0
		aProduto[nLin,5] := 0
		aProduto[nLin,6] := 0
		aProduto[nLin,7] := 0
		aProduto[nLin,8] := 0
		
		SetText(aObj[3,3], "")
		SetText(aObj[3,5], "")
		SetText(aObj[3,7], "")
		
		SetArray(aObj[3,1],aProduto)
		If nLin < 4
			GridSetRow(aObj[3,1],nLin+1)
		Else
			GridSetRow(aObj[3,1],nLin)
		Endif
	Endif
	
	if lClose // Fecha a Tela do Item do pedido (V.1)
		CloseDialog()
	Endif
Endif

Return Nil


Function NFCanIteNF(aCabNot, nIteNot,nTotPedAnt,aObj)
if nIteNot != 0
	// Cancelamento da Alteracao e Restaura Saldo Total Anterior
	aCabNot[15,1]:=nTotPedAnt
	aCabNot[35,1]:=Round(aCabNot[15,1],2)
	SetText(aObj[1,4],aCabNot[35,1])
Endif
// Fim
CloseDialog()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Gravar A nota       ³Autor-Marcelo Vieira ³ Data ³01/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aIteNot, nIteNot											  ´±±
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
Function NFGravarNF(aCabNot,aIteNot,aColItenf,cCondInt,cSfaInd, cSfaFpg,cCF,cGeraDup)
Local nCont :=0, nDescNot:= 0.00, cSerie:=""
Local lConfirmNot :=.F.             

cSerie := AllTrim(GetParam("MV_SERIEPE","RUA"))  

//Verifica Limite de Credito
If aCabNot[2,1] = 1
	If VrfLimCred(aCabNot[3,1],aCabNot[4,1], aCabNot[16,1],"") == "2"
		Return Nil
	EndIf
Else
	If VrfLimCred(aCabNot[3,1],aCabNot[4,1], aCabNot[11,1],aCabNot[1,1]) == "2"
		Return Nil
	EndIf
EndIf

//Consistencia da Nota
If !NFVrfNot(aCabNot[9,1], aIteNot)
	Return Nil
EndIf

// Faz os Calculos dos impostos da nota
NFFldImp(aCabNot,aIteNot,@lConfirmNot)
//NFConfirmNf(aIteNot, aCabNot[11,1], nDescNot, @lConfirmNot,.F.,cSfaInd,aCabNot[15,1])
If !lConfirmNot
	Return Nil
Endif

dbSelectArea("HF2")
dbSetOrder(1)

//AllTrim no Campo Observacao

// Se for Inclusao ou Ult. Notas
If aCabNot[2,1] == 1 .Or. aCabNot[2,1] == 4
	dbAppend()
	For nI:=1 to Len(aCabNot)
	
		If aCabNot[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
		    
		    if aCabNot[nI,2]=12      
		       // a Definir regra para o campo 12
            else 
               HF2->(FieldPut(HF2->(aCabNot[nI,2]), aCabNot[nI,1]))
		    endif   
		Endif
		
	Next
		
    dbSelectArea("HF2")
	HF2->HF2_FILIAL := RetFilial("HF2")
	HF2->HF2_DOC     := aCabNot[1,1]          
	HF2->HF2_SERIE   := cSerie               
	HF2->HF2_DUPL    := aCabNot[1,1]          
	HF2->HF2_VEND1   := HA3->HA3_COD
	HF2->HF2_VALBRUT := aCabNot[15,1]        //Total
	HF2->HF2_QTDITE  := len(aIteNot)
	HF2->HF2_STATUS  := "N"
	HF2->HF2_EST     := HA1->HA1_EST
    HF2->HF2_TIPOCLI := HA1->HA1_TIPO
    	
	HF2->(dbCommit())
Else
	HF2->(dbSeek(RetFilial("HF2")+aCabNot[1,1]) )
	if HF2->(Found())
		For nI:=1 to Len(aCabNot)
			If aCabNot[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero    
				HF2->(FieldPut(HF2->(aCabNot[nI,2]), aCabNot[nI,1]))
			Endif
		Next
		HF2->HF2_DUPL   := aCabNot[1,1]          
		HF2->HF2_EMISSAO:= Date()
		HF2->HF2_STATUS := "N"      
    	HF2->HF2_QTDITE  := len(aIteNot)
		HF2->HF2_VALBRUT := aCabNot[15,1]        //Total
		HF2->(dbCommit() )
	Endif
	
	dbSelectArea("HD2")
	dbSetOrder(1)
	dbSeek(RetFilial("HD2")+aCabNot[1,1])
	While !Eof() .And. HD2->HD2_FILIAL == RetFilial("HD2") .And. HD2->HD2_DOC = aCabNot[1,1]
		//Antes de excluir, restaurar a qtde ao estoque (HB6)
		//RestauraHB6(HD2->HD2_COD, HD2->HD2_QUANT)
		//dbSelectArea("HD2")
		dbDelete()
		dbSkip()
	EndDo
Endif

dbSelectArea("HD2")
dbSetOrder(1)
For nCont:=1 to len(aIteNot)
                            
	HD2->( dbAppend() )
	For nI:=1 to Len(aColItenf)
		If aColItenf[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
         
    	   HD2->(FieldPut(HD2->(aColItenf[nI,2]), aIteNot[nCont,nI])) 
    	   
		Endif
	Next     
	HD2->HD2_FILIAL := RetFilial("HD2")
	HD2->HD2_DOC     := aCabNot[1,1]
	//HD2->HD2_DUPL    := aCabNot[1,1]
	HD2->HD2_SERIE   := cSerie
	HD2->HD2_CLIENTE := aCabNot[4,1]
	HD2->HD2_LOJA    := aCabNot[5,1]
	HD2->HD2_EST     := HA1->HA1_EST
	HD2->HD2_EMISSAO := HF2->HF2_EMISSAO
	HD2->HD2_ITEM    := StrZero(nConT,3)
	HD2->HD2_ENTREG  := aCabNot[9,1]
	
	HD2->HD2_CF     := HF4->HF4_CF
    
  	HB1->(dbSetOrder(1))
	HB1->(dbSeek( RetFilial("HB1")+HD2->HD2_COD ))
	if HB1->(Found())   
		HD2->HD2_UM      := HB1->HB1_UM
		HD2->HD2_LOCAL   := HB1->HB1_LOCPAD
		//HD2->HD2_PICMS := HB1->HB1_PICM // nao sei porque nao da erro mas tb nao aborta. perguntar para Manoel
		HD2->HD2_PICM    := HB1->HB1_PICM
	    	HD2->HD2_IPI     := HB1->HB1_IPI
	Endif

	HD2->(dbCommit())
    
    // Atualiza Saldo do Caminhao
    AtualHB6(HD2->HD2_COD) 
	
Next

GrvAtend(5, aCabNot[1,1],, HF2->HF2_CLIENTE, HF2->HF2_LOJA,)

// Aqui gravo o titulo se for para gerar Duplicatas    

IF alltrim(cGeraDup)=="S"
   // Realiza a gravacao do Título conforme a condicao de pagamento 
   // quebrando em parcelas se for o caso.
   msgStatus( STR0008 ) //"Gravando titulo, Aguarde..."
   NFGeraDup(aCabNot,aIteNot)
   ClearStatus() 
Endif

MsgAlert(STR0009,"NF") //"Nota gravada com sucesso!"

CloseDialog()

Return Nil

Function NFVrfNot(dDtEntr, aIteNot)

If Len(aIteNot)<=0
	MsgStop(STR0010,STR0011) //"Inclua um Item nessa nota!"###"Verifica Nota"
	Return .F.
Endif

Return .T.

Function NFPosRot(cCodCli, cLojaCli, cCodRot, cIteRot)
//Funcao que positiva Roteiro
If !Empty(cCodRot)
	dbSelectArea("HD7")
	dbSetOrder(1)
	dbSeek(RetFilial("HD7")+cCodRot + cIteRot)
	HD7->HD7_FLGVIS	:="1"
	HD7->HD7_OCO:=""
Else
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(RetFilial("HA1")+cCodCli + cLojaCli)
	HA1->HA1_FLGVIS	:="1"
	HA1->HA1_OCO:=""
Endif
dbCommit()
Return Nil

Return Nil

Function NFDtEntr(dDtEntr,oDtEntr)
Local dData :=date()
if !Empty(dDtEntr) .And. !dDtEntr=Nil
	dDtEntr := SelectDate(STR0012,dDtEntr) //"Sel.Data Entrega"
else
	dDtEntr := SelectDate(STR0012,dData) //"Sel.Data Entrega"
Endif
SetText(oDtEntr,dDtEntr)
Return Nil

Function NFProduto(aColIteNf,aObjIte,aCabNot,cManTes,cManPrc,lPesq)
Local cProduto:=""
Local lEncontrou :=.F.
if lPesq
	dbSelectArea("HB1")
	dbSetOrder(1)
	dbSeek(RetFilial("HB1")+aColIteNf[3,1])
	if Found()
		aColIteNf[1,1]:= HB1->HB1_COD
		lEncontrou	 := .T.
	Endif
Else
	if GetProduto(cProduto)
		aColIteNf[3,1]:=cProduto
		lEncontrou	:=.T.
	Endif
Endif
If lEncontrou
	If !Empty(aCabNot[7,1])
		dbSelectArea("HPR")
		dbSetOrder(1)
		dbSeek(RetFilial("HPR")+aColIteNf[1,1]+aCabNot[7,1])
		If HPR->(Found()) //!Eof()
			aColIteNf[23,1]:=HPR->HPR_UNI
		else
			If HB1->HB1_PRV1 <> 0
				aColIteNf[23,1]:=HB1->HB1_PRV1
			Else
				MsgStop(STR0013 + aCabNot[8,1] + "!",STR0014) //"Preço não cadastrado na tabela "###"Aviso"
				If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
					NFLimpaColIteNf(aColIteNf,aObjIte)
					Return nil
				Endif
				aColIteNf[23,1]:=0
			Endif
		Endif
	Else
		If HB1->HB1_PRV1 == 0
			MsgStop(STR0015,STR0014) //"Preço não cadastrado!"###"Aviso"
			If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
				NFLimpaColIteNf(aColIteNf,aObjIte)
				Return nil
			Endif
		Endif
		aColIteNf[23,1]:=HB1->HB1_PRV1
	Endif
	
	If cManTes == "N"
		If !Empty(HB1->HB1_TS)
			aColIteNf[10,1]:=HB1->HB1_TS
		Else
			MsgStop(STR0016 + aColIteNf[3,1] + STR0017,STR0014) //"Produto "###" c/ TES em branco. Solicite à retaguarda cadastrar!"###"Aviso"
			NFLimpaColIteNf(aColIteNf,aObjIte)
			Return nil
		Endif
	Endif
	
	aColIteNf[43,1]:=HB1->HB1_DESC
	aColIteNf[20,1]:=HB1->HB1_GRUPO
	SetText(aObjIte[1,2],aColIteNf[1,1])
	SetText(aObjIte[1,3],aColIteNf[2,1])
	SetText(aObjIte[1,7],aColIteNf[6,1])
Else
	If lPesq
		MsgStop(STR0016 + aColIteNf[3,1] + STR0018,STR0019) //"Produto "###" não encontrado"###"Pesquisa Produto"
		NFLimpaColIteNf(aColIteNf,aObjIte)
	Endif
Endif

Return nil


Function NFLimpaColIteNf(aColIteNf,aObjIte)
aColIteNf[1,1] := ""
aColIteNf[2,1] := ""
aColIteNf[3,1] := ""
aColIteNf[6,1] := 0
SetText(aObjIte[1,2],aColIteNf[1,1])
SetText(aObjIte[1,3],aColIteNf[2,1])
SetText(aObjIte[1,7],aColIteNf[6,1])
Return nil

Function NFRetTes(cTes,oTxtTes,aTes,nTes,oTes)
cTes:=Substr(aTes[nTes],1,at("-",aTes[nTes])-1)
SetText(oTxtTes,cTes)
CloseDialog()
Return Nil

Function NFFechaNF(nOperacao,cNumNot)
Local cResp	:=""

If nOperacao == 1 .Or. nOperacao == 4
	cResp:=MsgYesOrNo(STR0020,STR0021) //"Deseja cancelar a inclusao desta nota ?"###"Cancelar"
Else
	cResp:=MsgYesOrNo(STR0022,STR0021) //"Deseja cancelar as alterações desta Nota?"###"Cancelar"
	If cResp 
		MsgStatus(STR0023) //"Atualizando estoque..."
		dbSelectArea("HD2")     
		dbSetOrder(1)
		dbSeek(RetFilial("HD2")+cNumNot)	
		While !HD2->(Eof()) .And. HD2->HD2_FILIAL == RetFilial("HD2") .And. HD2->HD2_DOC == cNumNot
			//Reatualiza o saldo, pois a alteracao da NF foi cancelada
			AtualHB6(HD2->HD2_COD) 			        
			dbSelectArea("HD2")
			dbSkip()
		Enddo		
		ClearStatus()
	Endif
Endif
if cResp
	CloseDialog()
endif

Return Nil

//Fora de uso
Function NFCrgTes(aTes)
dbSelectArea("HF4")
dbSetOrder(1)
dbGotop()
While !Eof()
	AADD(aTes,Alltrim(HF4->HF4_CODIGO) + "-" + AllTrim(HF4->HF4_TEXTO))
	dbSkip()
Enddo
Return Nil


Function NFSetTaxas(aColIteNf,cCalcIPI,cCalcICM,cCF,cGeraDup)

// CALCULA IPI(SIM/NAO) NO PRONTA ENTREGA de acordo com o Tes
dbSelectArea("HF4")
dbSetorder(1)     
dbSeek( RetFilial("HF4")+aColiteNF[11,1] )

cCalcIPI:=HF4->HF4_IPI  
cCalcICM:=HF4->HF4_ICM
cCF     :=HF4->HF4_CF
cGeraDup:=HF4->HF4_DUPLIC    

Return 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ NFExcNot            ³Autor-Marcelo Vieira ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclui um Pedido								 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCli: Codigo do Cliente, cLojaCli: Loja do Cliente	  ³±±
±±³			 ³ aNotas : Array de Pedidos		  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function NFExcNot(oBrwNotas,aNotas,cNumNot,aClientes,nCliente,oCliente,cCodCli, cLojaCli, cCodRot,cIteRot)
Local nI:=0
Local cResp	:=""
Local dData := Date()
Local nNf   := 0
Local cProd := ""
Local nQtdEstorna := 0

SET DATE BRITISH 
SET DELETE ON

nNf:=GridRow(oBrwNotas)

If Len(aNotas)==0
	MsgAlert(STR0024) //"Nenhuma Nota Selecionada para ser Excluida"
	Return Nil
Endif
                                     
If Alltrim(aNotas[nNf,3])==STR0025  //"Transmitida"
   msgAlert(STR0026 , STR0027  )    //"Nota ja transmitida, nao pode ser Excluida"###"Atencao"
   Return
Endif

cNumNot := aNotas[nNf,1]
If !MsgYesOrNo(STR0028 + cNumNot + STR0029,STR0021) //"Você deseja Excluir a Nota "###" ?"###"Cancelar"
	Return Nil
EndIf      

//PVNumPed(oBrwNotas,aNotas,@cNumNf)

dbSelectArea("HF2")
dbSetOrder(1) 
dbGoTop()

If dbSeek(RetFilial("HF2")+cNumNot)

    // Primeiro Exclui os títulos desde que nao estejam com recebimentos 
    dbSelectArea("HE1")
    dbSetOrder(1)
    dbGoTop()
    dbSeek(RetFilial("HE1")+cCodCli+cLojaCli+cNumNot)

    While !Eof() .And. HE1->HE1_FILIAL == RetFilial("HE1") .And.(HE1->HE1_NUM=cNumNot .And. HE1->E1_CLIENTE=cCodCli .And. HE1->E1_LOJA=cLojaCLi )
		HE1->(dbDelete())	
		dbSkip()			
    EndDo
    
    dbSelectArea("HF2")
	// Guarda a data para excluir o Atendimento
	dData := HF2->HF2_EMISSAO
	dbDelete()      
	dbSkip()
		
	dbSelectArea("HD2")
	dbSetOrder(1)
	//dbGoTop()
	dbSeek(RetFilial("HD2")+cNumNot)

	While !Eof() .And. HD2->HD2_FILIAL == RetFilial("HD2") .And. HD2->HD2_DOC = cNumNot
		// Estornar a qtde dos produtos da NF ao estoque (HB6)
		cProd := HD2->HD2_COD
		nQtdEstorna := HD2->HD2_QUANT
		
		RestauraHB6(cProd,nQtdEstorna)
	
		dbSelectArea("HD2")
		dbDelete()	
		dbSkip()			
	EndDo
	
	nI := GridRow(oBrwNotas)
	
	aDel(aNotas, nI)
	aSize(aNotas, Len(aNotas)-1)
	SetArray(oBrwNotas, aNotas)
	
	GrvAtend(6, cNumNot, , HF2->HF2_CLIENTE, HF2->HF2_LOJA, dData)
		
	MsgAlert(STR0030) //"Nota Excluída com sucesso"

	If Len(aNotas)<= 0 	
		// Atualiza Flag para nao visitado, se nao houvere mais pedidos para o cliente
		dbSelectArea("HA1")
		dbSetOrder(1)
		If dbSeek(RetFilial("HA1")+cCodCli+cLojaCli)
			HA1->HA1_FLGVIS := "0"
    		dbCommit()
		Endif

		If Empty(cCodRot)
			dbSelectArea("HD7")
			dbSetOrder(3)	
			If dbSeek(RetFilial("HD7")+DtoS(Date()) + cCodCli + cLojaCli)
				HD7->HD7_FLGVIS := "0"
	    		dbCommit()
			Endif
		Else
			dbSelectArea("HD7")
			dbSetOrder(1)		
			If dbSeek(RetFilial("HD7")+cCodRot+cIteRot)
				HD7->HD7_FLGVIS := "0"
	    		dbCommit()
			Endif
		Endif		
		aClientes[nCliente,1]:="NVIS"
	Endif
Endif

Return Nil


Function AtuaLHB6(codigo)
Local nQtdeAbat:=0
Local nAbateu  :=0 

// Atualiza o saldo do caminhao
dbSelectArea("HB6")
HB6->( dbSetOrder(1) )
HB6->( dbSeek(RetFilial("HB6")+codigo,.f.) )

While !Eof() .And. HB6->HB6_FILIAL == RetFilial("HB6") .And. HB6->HB6_COD == codigo
	if HB6->HB6_QTD > 0
		nQtdeAbat:= HD2->HD2_QUANT
		If nQtdeAbat <= HB6->HB6_QTD
			HB6->HB6_QTD := HB6->HB6_QTD - nQtdeAbat
			HB6->(dbCommit())
			Exit
		Endif
	endif   
	HB6->( dbSkip() )  
Enddo  

Return nil


Function RestauraHB6(cProd, nQtd)
Local nQtdAbat := 0

HB6->( dbSetOrder(1) )
HB6->( dbSeek(RetFilial("HB6")+cProd,.f.) )

While !HB6->(Eof()) .And. HB6->HB6_FILIAL == RetFilial("HB6") .And. HB6->HB6_COD == cProd .And. nQtd > 0
	nQtdAbat := HB6->HB6_ORI - HB6->HB6_QTD

	If nQtd <= nQtdAbat //restaura a qtde em uma unica nota
		HB6->HB6_QTD := HB6->HB6_QTD + nQtd
		nQtd := 0
	Else 				//restaura a qtde em mais de uma nota
		HB6->HB6_QTD := HB6->HB6_QTD + nQtdAbat
		nQtd := nQtd - nQtdAbat
	Endif
	HB6->(dbCommit())			   
	HB6->(dbSkip())
Enddo

Return nil