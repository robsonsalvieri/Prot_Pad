#INCLUDE "SFPV103.ch"
Function PVProduto(aColIte,aObjIte,aCabPed,cManTes,cManPrc,lPesq,aPrdPrefix)
Local cProduto   :=""
Local cPrefixo   := ""
Local lEncontrou :=.F.
Local cPrdPesq   := ""
Local lRet       := .T.
Local lUseSb1Prc := GetMV("MV_SFPRSB1", "N") = "S"

if lPesq
	// Faz a busca se algo for digitado
	If Empty(aColIte[1,1])
	    Return .T.
	EndIf
	If !Empty(aPrdPrefix[1,1])
		If Empty(aPrdPrefix[1,3])
			cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
		Else
			cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(aColIte[1,1]))		
		EndIf
		If At(cPrefixo, aColIte[1,1]) != 0
			cPrdPesq := aColIte[1,1]
		Else
			cPrdPesq := AllTrim(cPrefixo + aColIte[1,1])
		EndIf
	Else
		cPrdPesq := aColIte[1,1]
	EndIf
	dbSelectArea("HB1")
	dbSetOrder(1)      
	If dbSeek(cPrdPesq)
	   aColIte[1,1]	:= HB1->B1_COD
	   lEncontrou	:= .T.
	   lRet         := .T.
	Endif
Else
	If GetProduto(cProduto, aPrdPrefix)
	   aColIte[1,1] :=cProduto
	   lEncontrou	:= .T.
	   lRet         := .T.
	Else
	   lRet         := .F.
	Endif	     
Endif	
If lEncontrou
	If !Empty(aCabPed[8,1])
		dbSelectArea("HPR")
		dbSetOrder(1)
		If dbSeek(aColIte[1,1]+aCabPed[8,1])
			aColIte[6,1]:=HPR->PR_UNI
			//nDesMax:=HPR->PR_DESMAX	
		else
			If lUseSb1Prc
				If HB1->B1_PRV1 <> 0
					aColIte[6,1]:=HB1->B1_PRV1 
				Else
					MsgStop(STR0001 + aCabPed[8,1] + "!",STR0002) //"Preço não cadastrado na tabela "###"Aviso"
					If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
						PVLimpaColIte(aColIte,aObjIte)
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
				PVLimpaColIte(aColIte,aObjIte)
				Return nil
			Endif
		Endif
		aColIte[6,1]:=HB1->B1_PRV1
	Endif	

	If cManTes == "N"
		If !Empty(HB1->B1_TS)
			aColIte[8,1]:=HB1->B1_TS
		Else
			MsgStop(STR0004 + aColIte[1,1] + STR0005,STR0002) //"Produto "###" c/ TES em branco. Solicite à retaguarda cadastrar!"###"Aviso"
			PVLimpaColIte(aColIte,aObjIte)
			Return nil
		Endif
	Endif

	aColIte[2,1]:=HB1->B1_DESC
	aColIte[3,1]:=HB1->B1_GRUPO   
	SetText(aObjIte[1,2],aColIte[1,1])   
	SetText(aObjIte[1,3],aColIte[2,1])   
	SetText(aObjIte[1,7],aColIte[6,1])   
    SetFocus(aObjIte[1,5])
	//Ponto de Entrada: Ponto de Entrada de Atualizacao no Retorno da Tela de Produto
	//#IFDEF _PEPV0033_
		//Objetivo: 
		//Retorno: 
	//	uRet := PEPV0033(aColIte,aCabPed,aObjIte)
	//#ENDIF
Else
	If lPesq                              
		MsgStop(STR0004 + aColIte[1,1] + STR0006,STR0007) //"Produto "###" não encontrado"###"Pesquisa Produto"
		lRet := .F.
		PVLimpaColIte(aColIte,aObjIte)	
	Endif
Endif            

Return lRet


Function PVLimpaColIte(aColIte,aObjIte)
aColIte[1,1] := ""
aColIte[2,1] := ""
aColIte[3,1] := ""
aColIte[6,1] := 0
SetText(aObjIte[1,2],aColIte[1,1])   
SetText(aObjIte[1,3],aColIte[2,1])   
SetText(aObjIte[1,7],aColIte[6,1])   
Return nil

Function PVRetTes(cTes,oTxtTes,aTes,nTes,oTes)
cTes:=Substr(aTes[nTes],1,at("-",aTes[nTes])-1)
SetText(oTxtTes,cTes)
CloseDialog()
Return Nil

Function PVFecha(nOperacao)
Local cResp	:=""

If nOperacao == 1 .Or. nOperacao == 4
	cResp:=if(MsgYesOrNo(STR0008,STR0009),STR0010,STR0011) //"Deseja cancelar este Pedido?"###"Cancelar"###"Sim"###"Não"
Else 
	cResp:=if(MsgYesOrNo(STR0012,STR0009),STR0010,STR0011) //"Deseja cancelar as alterações deste Pedido?"###"Cancelar"###"Sim"###"Não"
Endif
if cResp=STR0010 //"Sim"
	CloseDialog() 
endif      

Return Nil  

//Fora de uso
Function PVCrgTes(aTes)
dbSelectArea("HF4")   
dbSetOrder(1)
dbGotop()
While !Eof()
	AADD(aTes,Alltrim(HF4->F4_CODIGO) + "-" + AllTrim(HF4->F4_TEXTO)) 
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