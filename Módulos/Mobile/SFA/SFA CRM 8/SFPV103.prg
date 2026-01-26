#INCLUDE "SFPV103.ch"
Function PVProduto(aColIte,aObjIte,aCabPed,cManTes,cManPrc,lPesq,aPrdPrefix,cProduto)
//Local cProduto   :=""
Local cPrefixo   := ""
Local lEncontrou :=.F.
Local cPrdPesq   := ""
Local lRet       := .T.

If !Empty(aPrdPrefix[1,1])
	If Empty(aPrdPrefix[1,3])
		cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
	Else
		cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(aColIte[1,1]))		
	EndIf
	If At(cPrefixo, aColIte[1,1]) != 0
		cPrdPesq := aColIte[1,1]
	Else
		cPrdPesq := cPrefixo + aColIte[1,1]
	EndIf
	If At(cPrefixo, cProduto) == 0
		cProduto := cPrefixo + cProduto
	EndIf
EndIf

if lPesq
	// Faz a busca se algo for digitado
	If Empty(aColIte[1,1])
	    Return .T.
	EndIf
	dbSelectArea("HB1")
	dbSetOrder(1)      
	dbSeek(RetFilial("HB1") + cPrdPesq)
	if Found()
	   aColIte[1,1]	:= HB1->HB1_COD
	   lEncontrou	:= .T.
	   lRet         := .T.
	Endif
Else
	If GetProduto(@cProduto, aPrdPrefix)
//	if GetProduto(aColIte[1,1])
		aColIte[1,1]:=cProduto
		lEncontrou	:= .T.
		lRet        := .T.
	Else
		lRet        := .F.
	Endif	     
Endif	

If lEncontrou
	If !Empty(aCabPed[8,1])
		dbSelectArea("HPR")
		dbSetOrder(1)
		dbSeek(RetFilial("HPR") + aColIte[1,1]+aCabPed[8,1])
		If HPR->(Found()) //!Eof()
			aColIte[6,1]:=HPR->HPR_UNI
			aColIte[16,1]:=HPR->HPR_UNI
			//nDesMax:=HPR->HPR_DESMAX	
		else
			If HB1->HB1_PRV1 <> 0
				aColIte[6,1]:=HB1->HB1_PRV1 
				aColIte[16,1]:=HB1->HB1_PRV1
			Else
				MsgStop(STR0001 + aCabPed[8,1] + "!",STR0002) //"Preço não cadastrado na tabela "###"Aviso"
				If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
					PVLimpaColIte(aColIte,aObjIte)
					Return nil			
				Endif			        
				aColIte[6,1]:=0
				aColIte[16,1]:=0
			Endif
		Endif                       
	Else
		If HB1->HB1_PRV1 == 0
			MsgStop(STR0003,STR0002) //"Preço não cadastrado!"###"Aviso"
			If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
				PVLimpaColIte(aColIte,aObjIte)
				Return nil
			Endif
		Endif
		aColIte[6,1]:=HB1->HB1_PRV1
		aColIte[16,1]:=HB1->HB1_PRV1
	Endif	
	
	PVDesconto(aColIte, aCabPed)	
	
	If !Empty(HB1->HB1_TS)
		dbSelectArea("HF4")
		dbSetOrder(1)
		If dbSeek(RetFilial("HF4")+HB1->HB1_TS)
			aColIte[8,1]:=HB1->HB1_TS
		EndIf
	EndIf
	
	If cManTes == "N"
		If Empty(aColIte[8,1])
			MsgStop(STR0004 + aColIte[1,1] + STR0005,STR0002) //"Produto "###" c/ TES em branco. Solicite à retaguarda cadastrar!"###"Aviso"
			PVLimpaColIte(aColIte,aObjIte)
			Return nil
		EndIf
	Else
		SetText(aObjIte[1,12],aColIte[8,1])
	Endif
	
	//Limpa qtd, descto, peso. Atualiza cod, descrição e TES
	aColIte[2,1]  := HB1->HB1_DESC
	aColIte[3,1]  := HB1->HB1_GRUPO
	aColIte[4,1]  := 0
	aColIte[18,1] := 0
	aColIte[7,1]  := 0
	aColIte[17,1] := 0
	SetText(aObjIte[1,2],aColIte[1,1])
	SetText(aObjIte[1,3],aColIte[2,1])
	SetText(aObjIte[1,7],aColIte[6,1])
	SetText(aObjIte[1,5],aColIte[4,1])
	SetText(aObjIte[1,9],aColIte[7,1])
	
	If Len(aObjIte[1]) >=14
		SetText(aObjIte[1,14],aColIte[17,1])
	Endif
	
    SetFocus(aObjIte[1,5])
	
	//Ponto de Entrada: Ponto de Entrada de Atualizacao no Retorno da Tela de Produto
	If ExistBlock("SFAPD003")
		lRet := ExecBlock("SFAPD003", .F., .F., {aColIte,aCabPed,aObjIte})
	EndIf

Else
	If lPesq
		MsgStop(STR0004 + aColIte[1,1] + STR0006,STR0007) //"Produto "###" não encontrado"###"Pesquisa Produto"
		lRet := .F.
		PVLimpaColIte(aColIte,aObjIte)	
	Endif
Endif

If !lPesq
	lRet := .T.
EndIf

Return lRet


Function PVLimpaColIte(aColIte,aObjIte)
aColIte[1,1] := ""
aColIte[2,1] := ""
aColIte[3,1] := ""
aColIte[6,1] := 0
aColIte[16,1] := 0
SetText(aObjIte[1,2],aColIte[1,1])   
SetText(aObjIte[1,3],aColIte[2,1])   
SetText(aObjIte[1,7],aColIte[6,1])   
Return nil

Function PVRetTes(cTes,oTxtTes,aTes,nTes,oTes)
cTes:=Substr(aTes[nTes],1,at("-",aTes[nTes])-1)
SetText(oTxtTes,cTes)
CloseDialog()
Return Nil

Function PVFecha(nOperacao,aCabPed)
Local cResp	:=""

If nOperacao == 1 .Or. nOperacao == 4
	cResp:=if(MsgYesOrNo(STR0008,STR0009),STR0010,STR0011) //"Deseja cancelar este Pedido?"###"Cancelar"###"Sim"###"Não"
ElseIf nOperacao == 5
	CloseDialog()
Else
	cResp:=if(MsgYesOrNo(STR0012,STR0009),STR0010,STR0011) //"Deseja cancelar as alterações deste Pedido?"###"Cancelar"###"Sim"###"Não"
Endif
if cResp=STR0010 //"Sim"
	CloseDialog() 
endif

//Ponto de entrada para tratamento no cancelamento de alteracao/inclusao de pedidos
If ExistBlock("SFAPV020")
	ExecBlock("SFAPV020", .F., .F., {nOperacao,aCabPed})
EndIf

Return Nil

//Fora de uso
Function PVCrgTes(aTes)
dbSelectArea("HF4")   
dbSetOrder(1)
dbSeek(RetFilial("HF4"))
//dbGotop()
While !Eof()
	AADD(aTes,Alltrim(HF4->HF4_CODIGO) + "-" + AllTrim(HF4->HF4_TEXTO)) 
	dbSkip()
Enddo     
Return Nil

Function PVProcArray(aArray,cPesq)
Local nContador :=0
Local nAt		:=0

For nContador:=1 To len(aArray) 
	nAt:= at("-",aArray[nContador])
	If nAt ==0	
		If AllTrim(cPesq) == AllTrim(aArray[nContador])
			break
		Endif
	Else
		If AllTrim(cPesq) == Substr(aArray[nContador],1,nAt-1)
			break
		Endif
	Endif	
Next 

if nContador > len(aArray)
	nContador :=1
EndIf
Return nContador


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PVDescontoºAutor  ³ Osmar Cioni E. Jr  º Data ³  07/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para calcular o desconto do cabeçalho   			  º±±
±±º          |(C5_DESC1, C5_DESC2, C5_DESC3, C5_DESC4)					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³aColIte - array com estrutura dos itens do pedido           º±±
±±ºParametros³aCabPed - array com estrutura do cabecalho do pedido        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PVDesconto(aColIte, aCabPed)
Local prcItem := aColIte[16,1]

If aCabPed[18,1] > 0 .Or. aCabPed[19,1] > 0 .Or. aCabPed[20,1] > 0 .Or. aCabPed[21,1] > 0
	If aCabPed[18,1] > 0 
			 aColIte[6,1] := prcItem - ( aColIte[16,1] * ( aCabPed[18,1] / 100 ) ) 
			 prcItem :=      prcItem - ( aColIte[16,1] * ( aCabPed[18,1] / 100 ) ) 
	EndIf
	If aCabPed[19,1] > 0
	   	      aColIte[6,1] := prcItem - ( aColIte[6,1] * ( aCabPed[19,1] / 100 ) ) 
	   	      prcItem :=      prcItem - ( prcItem * ( aCabPed[19,1] / 100 ) ) 
	EndIf
	If aCabPed[20,1] > 0
	   	      aColIte[6,1] := prcItem - ( aColIte[6,1] * ( aCabPed[20,1] / 100 ) ) 
	   	      prcItem :=      prcItem - ( prcItem * ( aCabPed[20,1] / 100 ) ) 
	EndIf
	If aCabPed[21,1] > 0
	   	      aColIte[6,1] := prcItem - ( aColIte[6,1] * ( aCabPed[21,1] / 100 ) )    	      
	EndIf	
	
	aColIte[6,1]:= Round( aColIte[6,1] ,TamADVC("HC6_PRCVEN",2))
	
	If aColIte[7,1] >= 0 .And. aColIte[7,1] <= 100		
			  aColIte[6,1] := Round( aColIte[6,1] - (aColIte[6,1] * (aColIte[7,1] / 100)), 2)
	EndIf
Else
	aColIte[6,1] := Round( prcItem - (prcItem * (aColIte[7,1] / 100)), 2)		
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PVDesItensºAutor  ³ Osmar Cioni E. Jr  º Data ³  07/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para calcular o desconto do cabeçalho em todos os 	  º±±
±±º          |itens do pedido											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          |aItePed - array com os itens do pedido                      º±±
±±ºParametros³aCabPed - array com estrutura do cabecalho do pedido        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PVDesItens(aItePed, aCabPed)
Local nItens	:= 0

	For nItens := 1 to Len(aItePed)
		PVDesconto(aItePed[nItens], aCabPed)
	Next
	
Return Nil
