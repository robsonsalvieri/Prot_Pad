#INCLUDE "SFPV009.ch"
//Evento p/ selecao de um produto no browse
Function PVSeleciona(oBrwProd,aColIte,aItePed,nItePed,aCabPed,aObj,cManPrc,cManTes,nOpIte)
Local nLin := 0, nPos := 0, cCod := ""
  
If Len(aProduto) == 0
	return nil
Else
	nLin := GridRow(oBrwProd)
	If nLin <= 0
		return nil
	Endif
Endif

//Limpar variaveis do item
aColIte[1,1] := ""
aColIte[2,1] := ""
aColIte[3,1] := ""
aColIte[4,1] := 0
aColIte[5,1] := ""
aColIte[6,1] := 0
aColIte[7,1] := 0
aColIte[8,1] := ""
aColIte[9,1] := 0
aColIte[10,1] := ""
aColIte[11,1] := 0
aColIte[12,1] := 0
aColIte[13,1] := 0
aColIte[14,1] := "N"

If aProduto[nLin,3] > 0 //Alteracao do item (qtde > 0)

	cCod := aProduto[nLin,2]
	nItePed := ScanArray(aItePed, cCod,,,1)

	If nItePed > 0 
       	nOpIte  := 2 //Alteracao
       	For nI:=1 to Len(aColIte)
			aColIte[nI,1] := aItePed[nItePed,nI]
		Next 
		SetText(aObj[3,3], aColIte[4,1])    
		SetText(aObj[3,5], aColIte[6,1])		
		/*If aColIte[7,1] > 0
			nPrecoDesc := Round((aColIte[6,1] - (aColIte[6,1] * (aColIte[7,1] / 100))),2)
			SetText(aObj[3,5],Str(nPrecoDesc))		
		Else
			SetText(aObj[3,5], aColIte[6,1])
		Endif*/
		SetText(aObj[3,7], aColIte[7,1])
		SetText(aObj[3,10],aColIte[2,1])
		If cManTes == "S"
			SetText(aObj[3,9],aColIte[8,1])
		Endif
	Endif

Else   //Novo item (consultar produto)  
	SetText(aObj[3,3],"")
	SetText(aObj[3,5],"")
	SetText(aObj[3,7],"")
	SetText(aObj[3,10],"")
	If cManTes == "S"
		SetText(aObj[3,9],"")
	Endif
	nItePed := 0
	nOpIte  := 1 //Inclusao
	HB1->( dbSetOrder(1) )
	HB1->( dbSeek(aProduto[nLin,2]) ) //Codigo
	If HB1->(Found())
		aColIte[1,1] := HB1->B1_COD
		PVExibe(aColIte,aCabPed,aObj,cManPrc,cManTes)
    Endif                 
Endif
Return nil
                             

//Exibir dados do produto selecionado
Function PVExibe(aColIte,aCabPed,aObj,cManPrc,cManTes)
Local lUseSb1Prc := GetMV("MV_SFPRSB1", "N") = "S"

If !Empty(aCabPed[8,1])
	dbSelectArea("HPR")
	dbSetOrder(1)
	If dbSeek(aColIte[1,1]+aCabPed[8,1])
		aColIte[6,1]:=HPR->PR_UNI
	Else
		If lUseSb1Prc
			If HB1->B1_PRV1 <> 0
				aColIte[6,1]:=HB1->B1_PRV1 
			Else
				MsgStop(STR0001 + aCabPed[8,1] + "!",STR0002) //"Preço não cadastrado na tabela "###"Aviso"
				If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
					PVLimpaItem(aColIte,aObj,cManTes)
					Return nil			
				Endif			        
				aColIte[6,1]:=0
			Endif
		Else
			aColIte[6,1]:=0
			MsgStop(STR0001 + aCabPed[8,1] + "!",STR0002) //"Preço não cadastrado na tabela "###"Aviso"
		EndIf
	Endif                       
Else
	If HB1->B1_PRV1 == 0
		MsgStop(STR0003,STR0002) //"Preço não cadastrado!"###"Aviso"
		If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
			PVLimpaItem(aColIte,aObj,cManTes)
			Return nil
		Endif
	Endif
	aColIte[6,1]:=HB1->B1_PRV1
Endif	

If cManTes == "N"
	If !Empty(HB1->B1_TS)
		aColIte[8,1]:=HB1->B1_TS
	Else
		MsgStop(STR0004 + AllTrim(aColIte[1,1]) + STR0005,STR0002) //"Produto "###" c/ TES em branco. Solicite à retaguarda cadastrar!"###"Aviso"
		PVLimpaItem(aColIte,aObj,cManTes)
		Return nil
	Endif
Else //inicia o campo TES com a 1a.
	If Empty(AllTrim(aColIte[8,1]))
		HF4->(dbGotop())
		aColIte[8,1] := Alltrim(HF4->F4_CODIGO)
		SetText(aObj[3,9],aColIte[8,1])
	EndIf
Endif

aColIte[2,1]:=HB1->B1_DESC
aColIte[3,1]:=HB1->B1_GRUPO   
SetText(aObj[3,5], aColIte[6,1])   //exibe preco
SetText(aObj[3,10],aColIte[2,1])  //exibe descricao
SetFocus(aObj[3,3])               //foco na qtde.
    
Return nil


//Limpar campos do item
Function PVLimpaItem(aColIte,aObj,cManTes)
aColIte[2,1] := ""
aColIte[4,1] := 0
aColIte[6,1] := 0
aColIte[7,1] := 0
SetText(aObj[3,3],Str(aColIte[4,1]))
SetText(aObj[3,5],Str(aColIte[6,1]))
SetText(aObj[3,7],Str(aColIte[7,1]))
SetText(aObj[3,10],aColIte[2,1])
If cManTes == "S"
	aColIte[8,1] := ""
	SetText(aObj[3,9],aColIte[8,1])
Endif
Return nil


Function PVFocarBrowse(oBrwProd)
Local nLin := GridRow(oBrwProd)
//SetFocus(oBrwProd)
//GridSetRow(oBrwProd,nLin)

Return nil

//Exibe o preco com desconto (quando houver)
Function PVCalcDesc(aColIte)
Local nPrecoDesc := 0

If aColIte[6,1] > 0 .And. aColIte[7,1] <> 0
	If aColIte[7,1] >= 0 .And. aColIte[7,1] <= 100
		nPrecoDesc := Round((aColIte[6,1] - (aColIte[6,1] * (aColIte[7,1] / 100))),nQtdDec)
        MsgAlert(STR0006 + Str(nPrecoDesc,4,nQtdDec),STR0002) //"Preço com Desconto: "###"Aviso"
	Else
		MsgAlert(STR0007,STR0002) //"Desconto Inválido"###"Aviso"
		return .F.
	Endif
Endif
Return .T.

//Efetua validacao do preco de venda digitado
Function PVValidaPrc(oGetPrc,aColIte,aCabPed,cBloqPrc,oGetDescto)
Local nPrcBase  := 0
Local nPrcFinal := aColIte[6,1]

HPR->( dbSetOrder(1) )
HPR->( dbSeek(aColIte[1,1]+aCabPed[8,1]) )
If HPR->(Found())
	nPrcBase:=HPR->PR_UNI
Else
	HB1->( dbSetOrder(1) )
	HB1->( dbSeek(aColIte[1,1]) )
	nPrcBase:=HB1->B1_PRV1
Endif

If nPrcFinal < nPrcBase
	aColIte[6,1]:=nPrcBase
	SetText(oGetPrc, aColIte[6,1])
	If cBloqPrc == "N" // (libera so p/ acrescimo)
		MsgAlert(STR0008,STR0002) //"Para vender abaixo da tabela, favor usar o campo Desconto"###"Aviso"
		return .F.        
	ElseIf cBloqPrc == "L" // (libera p/ acresc. e desconto)
		//calcula porcentagem de desconto
		aColIte[7,1] := ( ( (aColIte[6,1] - nPrcFinal) / aColIte[6,1] ) * 100 )
		SetText(oGetDescto, aColIte[7,1])
	Endif
ElseIf nPrcFinal > nPrcBase
	aColIte[7,1] := 0.00
	SetText(oGetDescto, aColIte[7,1])
Endif
	
Return .T.
