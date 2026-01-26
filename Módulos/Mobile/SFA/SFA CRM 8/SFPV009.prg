#INCLUDE "SFPV009.ch"

//Evento p/ selecao de um produto no browse
Function PVSeleciona(oBrwProd,aColIte,aItePed,nItePed,aCabPed,aObj,cManPrc,cManTes,nOpIte,aGrupo,nGrupo,nTop,lCodigo)

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
aColIte[18,1] := 0
aColIte[5,1] := ""
aColIte[6,1] := 0
aColIte[16,1] := 0
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
			nPrecoDesc := Round((aColIte[6,1] - (aColIte[6,1] * (aColIte[7,1] / 100))),TamADVC("HC6_PRCVEN",2))
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
	HB1->( dbSeek(RetFilial("HB1") + aProduto[nLin,2]) ) //Codigo
	If HB1->(Found())
		aColIte[1,1] := HB1->HB1_COD
		PVExibe(aColIte,aCabPed,aObj,cManPrc,cManTes,oBrwProd,aGrupo,nGrupo,@nTop,aItePed,lCodigo)
    Endif                 
Endif
If ExistBlock("SFAPV105")
	ExecBlock("SFAPV105", .F., .F., {aObj, aCabPed, aColIte, aItePed})
EndIf

Return nil
                             

//Exibir dados do produto selecionado
Function PVExibe(aColIte,aCabPed,aObj,cManPrc,cManTes,oBrwProd,aGrupo,nGrupo,nTop,aItePed,lCodigo)
Local nLin		:= 0
Local nLInMax	:= 0
Local nOrder	:= If(lCodigo,1,2)

If Len(aProduto) == 0
	return nil
Else
	nLinMax := GridRows(oBrwProd)
	nLin := GridRow(oBrwProd)
	If nLin <= 0
		return nil
	Endif
Endif

If Empty(cUltGrupo)
	HB1->( dbSetOrder(nOrder) )
Else
	HB1->( dbSetOrder(3) )
Endif


If !Empty(aCabPed[8,1])
	dbSelectArea("HPR")
	dbSetOrder(1)
	If dbSeek(RetFilial("HPR") + aColIte[1,1]+aCabPed[8,1])
		aColIte[6,1]:=HPR->HPR_UNI
		aColIte[16,1]:=HPR->HPR_UNI
	else
		If HB1->HB1_PRV1 <> 0
			aColIte[6,1]:=HB1->HB1_PRV1 
			aColIte[16,1]:=HB1->HB1_PRV1 
		Else
			//MsgStop(STR0001 + aCabPed[8,1] + "!",STR0002) //"Preço não cadastrado na tabela "###"Aviso"
			If Empty(cUltGrupo)
				HB1->( dbSetOrder(nOrder) )
			Else
				HB1->( dbSetOrder(3) )
			Endif			

			HB1->(dbGoTo(nTop+nLin+1))

			if HB1->(Eof())
			   PVLimpaItem(aColIte,aObj,cManTes)
			   return nil
			endif
			If nLin == nLinMax
				PVDesce(aGrupo,nGrupo,oBrwProd,nTop,aItePed,lCodigo)
			Else
				GridSetRow(oBrwProd,(nLIn+1))
			EndIf
			PVExibe(aColIte,aCabPed,aObj,cManPrc,cManTes,oBrwProd,aGrupo,nGrupo,nTop,aItePed,lCodigo)
			Return nil
			/*If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
				PVLimpaItem(aColIte,aObj,cManTes)
				Return nil			
			Endif*/			        
			aColIte[6,1]:=0
			aColIte[16,1]:=0
		Endif
	Endif                       
Else
	If HB1->HB1_PRV1 == 0
		//MsgStop(STR0003,STR0002) //"Preço não cadastrado!"###"Aviso"
		If Empty(cUltGrupo)
			HB1->( dbSetOrder(nOrder) )
		Else
			HB1->( dbSetOrder(3) )
		Endif		
		
		HB1->(dbGoTo(nTop+nLIn+1))
		
		If HB1->(Eof())
		   PVLimpaItem(aColIte,aObj,cManTes)
		   return nil
		endif
		If nLin == nLinMax
			PVDesce(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,lCodigo)
		Else
			GridSetRow(oBrwProd,(nLIn+1))
		EndIf
		PVExibe(aColIte,aCabPed,aObj,cManPrc,cManTes,oBrwProd,aGrupo,nGrupo,nTop,aItePed,lCodigo)
		Return nil
		/*If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
			PVLimpaItem(aColIte,aObj,cManTes)
			Return nil
		Endif*/
	Endif
	aColIte[6,1]:=HB1->HB1_PRV1
	aColIte[16,1]:=HB1->HB1_PRV1
Endif	

If cManTes == "N"
	If !Empty(HB1->HB1_TS)
		aColIte[8,1]:=HB1->HB1_TS
	Else
		MsgStop(STR0004 + AllTrim(aColIte[1,1]) + STR0005,STR0002) //"Produto "###" c/ TES em branco. Solicite à retaguarda cadastrar!"###"Aviso"
		PVLimpaItem(aColIte,aObj,cManTes)
		Return nil
	Endif
Else //inicia o campo TES com a 1a.
	HF4->(dbSeek(RetFilial("HF4")))
	//HF4->(dbGotop())
	aColIte[8,1] := Alltrim(HF4->HF4_CODIGO)
	SetText(aObj[3,9],aColIte[8,1])
Endif

aColIte[2,1]:=HB1->HB1_DESC
aColIte[3,1]:=HB1->HB1_GRUPO   
SetText(aObj[3,5], aColIte[6,1])   //exibe preco
SetText(aObj[3,10],aColIte[2,1])  //exibe descricao
If ExistBlock("SFAPV103")
	ExecBlock("SFAPV103", .F., .F., {aObj, aColIte, aCabPed, aItePed})
EndIf


SetFocus(aObj[3,3])               //foco na qtde.
Return nil


//Limpar campos do item
Function PVLimpaItem(aColIte,aObj,cManTes)
aColIte[2,1] := ""
aColIte[4,1] := 0
aColIte[18,1] := 0
aColIte[6,1] := 0
aColIte[16,1] := 0
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
SetFocus(oBrwProd)
Return nil

//Exibe o preco com desconto (quando houver)
Function PVCalcDesc(aColIte,aObjIte,aCabPed,cBloqPrc, nTelaPed)
Local nPrecoDesc := aColIte[6,1]
Local lRet := .T.
Local lVrfItem	:= .T.
Local oPrcGet, oDescGet

If ExistBlock("SFAPV021")
	lVrfItem := ExecBlock("SFAPV021", .F., .F., {aColIte,aObjIte,aCabPed})
	If !lVrfItem
		Return .T.
	EndIf
EndIf

If nTelaPed =nil .or. nTelaPed = 1
	oPrcGet := aObjIte[1,7]
	oDescGet:= aObjIte[1,9]
Else
	oPrcGet := aObjIte[3,5]
	oDescGet:= aObjIte[3,7]
EndIf

If aColIte[7,1] > 0 .And. aColIte[16,1] > 0
	If aColIte[7,1] > 0 .And. aColIte[7,1] <= 100	
		PVDesconto(aColIte, aCabPed)		
		nPrecoDesc:= aColIte[6,1]
		If aColIte[6,1] <> aColIte[16,1]
			MsgAlert(STR0006 + Str(nPrecoDesc,4,TamADVC("HPR_UNI",2)),STR0002) //"Preço com Desconto: "###"Aviso"
			//Aplica desconto no campo de preco
			aColIte[6,1] := nPrecoDesc
			//lRet := PVValidaPrc(aObjIte[1,7],aColIte,aCabPed,cBloqPrc,aObjIte[1,9],.F.)
			lRet := PVValidaPrc(oPrcGet,aColIte,aCabPed,cBloqPrc,oDescGet,.F.)
		EndIf
	Else
		MsgAlert(STR0007,STR0002) //"Desconto Inválido"###"Aviso"
		lRet := .F.
	Endif
Elseif aColIte[7,1] = 0 .And. aColIte[6,1] <> aColIte[16,1] //retornar preço de venda ao zerar desconto na alteracao.
         
       lRet := PVValidaPrc(oPrcGet,aColIte,aCabPed,cBloqPrc,oDescGet,.F.)     
           
Endif
		
//SetText(aObjIte[1,7], aColIte[6,1])
SetText(oPrcGet, aColIte[6,1])
If ExistBlock("SFAPV104")
	ExecBlock("SFAPV104", .F., .F., {aObjIte, aCabPed, aColIte})
EndIf

Return lRet

//Efetua validacao do preco de venda digitado
Function PVValidaPrc(oGetPrc,aColIte,aCabPed,cBloqPrc,oGetDescto,lCalcDesc)
Local nPrcBase  := 0
Local nDscFinal := 0
Local nPrcFinal := aColIte[6,1]
Local cQtd	:= StrTran( StrZero(aColIte[4,1],18,2), ",", ".")
Local cProd	:= aColIte[1,1]
Local cTab	:= aCabPed[8,1]
Local cChave	:= ""
Local lProxRec	:= .F.
Local lRet		:= .T.
Local lVrfItem	:= .T.
Local nValDescto := 0
Local nDescMax := 0
Local nValDesMax := 0
// Ponto no inicio da validacao do preco para que possa ser retornado um preco especifico do cliente, 
// e entao retornar .T. ou .F. para deixar ou nao o fonte padrao seguir com as consistencias de preco
If ExistBlock("SFAPV011")
	lVrfItem := ExecBlock("SFAPV011", .F., .F., {oGetPrc,aColIte,aCabPed})
	If !lVrfItem
		Return .T.
	EndIf
EndIf
If nPrcFinal < 0
	MsgAlert(STR0009,STR0002) //"O valor do preço não pode ser negativo"###"Aviso"
	Return .F.
EndIf

HPR->(dbSetOrder(2))
//HPR->(dbSetOrder(1))
If HPR->(FieldPos("HPR_QTDLOT")) != 0 .And. HPR->(FieldPos("HPR_INDLOT")) != 0
	If !Empty(aColIte[1,1]) .And. !Empty(aCabPed[8,1]) .And. !Empty(aColIte[4,1])
		cChave := RetFilial("HPR")+ALlTrim(aColITe[1,1])+Space(Len(HPR->HPR_PROD)-Len(AllTrim(cProd)))+AllTrim(aCabPed[8,1])+cQtd
		lProxRec := .T.
	Else
		Return .T.// Caso a quantidade, tabela ou produto estejam em branco não faz nada
	EndIf
Else
	cChave := RetFilial("HPR")+ALlTrim(aColITe[1,1])+Space(Len(HPR->HPR_PROD)-Len(AllTrim(cProd)))+AllTrim(aCabPed[8,1])	
	lProxRec := .F.
EndIf

HB1->( dbSetOrder(1) )
HB1->( dbSeek(RetFilial("HB1") + aColIte[1,1]) )

HPR->( dbSeek(cChave, lProxRec))
If HPR->(Found()) .Or. (lProxRec .And. !HPR->(Eof()) .And. AllTrim(HPR->HPR_PROD) == AllTrim(aColIte[1,1]) .And. AllTrim(HPR->HPR_TAB) == Alltrim(aCabPed[8,1]) .And. HPR->HPR_QTDLOT >= aColIte[4,1])
	nPrcBase:=HPR->HPR_UNI
Else
	nPrcBase:=HB1->HB1_PRV1
Endif

If HPR->(FieldPos("HPR_DESMAX")) != 0
	If HPR->(Found()) .And. HPR->HPR_DESMAX > 0
   nDescMax   := HPR->HPR_DESMAX
	EndIf
EndIf 

If HB1->(FieldPos("HB1_DESMAX")) != 0 .And. HB1->HB1_DESMAX > 0
	If nDescMax = 0
   nDescMax  := HB1->HB1_DESMAX
	EndIf
EndIf

If nDescMax = 0
   nDescMax := 100
EndIf    

If nDescMax > 0 .And. nDescMax < 100
	nValDesMax := aColIte[16,1] - (aColIte[16,1] * (nDescMax / 100) )
EndIf

nValDescto := aColIte[16,1] - (aColIte[16,1] * (aColIte[7,1] / 100) )

If nPrcFinal < nPrcBase
	If cBloqPrc == "2" .And. aColIte[6,1] <> nValDescto // (libera so p/ acrescimo)
		MsgAlert(STR0008,STR0002) //"Para vender abaixo da tabela, favor usar o campo Desconto"###"Aviso"
		aColIte[6,1]:=nPrcBase
		lRet := .F.
	Endif
Endif

If nValDesMax > 0 .And. nPrcFinal < nValDesMax
   //MsgAlert("Desconto acima do máximo permitido para este produto",STR0002)
   MsgStop(STR0007 + str(nDescMax,3,2) + " %",STR0002) //"Desconto acima do máximo permitido: "###"Verifica Item"
   aColIte[6,1]:=nPrcBase
   aColIte[7,1]:=0
   lRet := .F.
Endif

If aColIte[6,1] >= aColIte[16,1] .or.;
   (aColIte[6,1] <> nValDescto .and. aCabPed[18,1] = 0 .and. aCabPed[19,1] = 0 .and. aCabPed[20,1] = 0 .and. aCabPed[21,1] = 0 )
	//Se o preco de venda for maior que o preco de tabela, ou se o preco for informado manualmente, limpa o desconto
   aColIte[7,1] := 0
EndIf

SetText(oGetPrc, aColIte[6,1])
SetText(oGetDescto, aColIte[7,1])

Return lRet
