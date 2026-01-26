#INCLUDE "FDNF009.ch"
//Evento p/ selecao de um produto no browse
Function NFSeleciona(oBrwProd,aColItenf,aIteNot,nIteNot,aCabNot,aObj,cManPrc,cManTes,nOpIte,oSaldoEst,nSaldoEst)
Local nLin := 0, nPos := 0, cCod := ""       

If Len(aProduto) == 0
	return nil
Else
	nLin := GridRow(oBrwProd)
	If nLin == 0
		return nil
	Endif
Endif

//Limpar variaveis do item

aColitenf[1,1] := ""
aColitenf[2,1] := ""
aColitenf[3,1] := ""
aColitenf[4,1] := ""
aColitenf[5,1] := ""
aColitenf[6,1] := 0
aColitenf[7,1] := 0
aColitenf[8,1] := 0
aColitenf[9,1] := 0
aColitenf[10,1] :=0
aColitenf[11,1] := "" // Tes
aColitenf[12,1] := "" // CF
aColitenf[13,1] := 0  //
aColitenf[14,1] := 0
aColitenf[23,1] := 0
                    
nSaldoEst:=0

HB6->( dbSetOrder(1))
if HB6->(dbSeek(RetFilial("HB6")+aProduto[nLin,2]))
   //nSaldoEst:=HB6->HB6_QTD
   //Procura o Proximo Produto que tem quantidade
   While HB6->(!eof()) .And. HB6->HB6_FILIAL == RetFilial("HB6") .And. HB6->HB6_COD == aProduto[nLin,2].And. HB6->(!IsDirty())
         if HB6->HB6_QTD > 0   
            nRecEst := HB6->(Recno())
            nSaldoEst := nSaldoEst + HB6->HB6_QTD
            //Exit                  
         endif           
         HB6->(dbSkip())
   enddo
   If nSaldoEst>0
     SetTExt(oSaldoEst, Str(nSaldoEst) )
   else 
     SetTExt(oSaldoEst, STR0001 ) //"SEM ESTOQUE"
   endif  

else // se nao achar o produto na base de estoques
   nSaldoEst:=0 

Endif

if nSaldoEst==0
   SetTExt(oSaldoEst, STR0001 ) //"SEM ESTOQUE"
else

endif

If aProduto[nLin,3] > 0 //Alteracao do item (qtde > 0)
	cCod := aProduto[nLin,2]             
	nIteNot := ScanArray(aIteNot,cCod,,,3)   
	If nIteNot > 0 
       	nOpIte  := 2 //Alteracao
       	For nI:=1 to Len(aColitenf)
			aColitenf[nI,1] := aIteNot[nIteNot,nI]
		Next   
        
        If nSaldoEst>0
           SetTExt(oSaldoEst, Str(nSaldoEst) )
        else 
           SetTExt(oSaldoEst, STR0001 ) //"SEM ESTOQUE"
        endif  
        
		SetText(aObj[3,3], aColitenf[6,1])
		SetText(aObj[3,5], aColitenf[23,1])
		SetText(aObj[3,7], aColitenf[13,1])
		SetText(aObj[3,10],aColitenf[43,1])
		If cManTes == "S"
			SetText(aObj[3,9],aColitenf[11,1])
		Endif
	Endif
Else   //Novo item (consultar produto)       
    //SetTExt(oSaldoEst, nSaldoEst )
	SetText(aObj[3,3],"" )
	SetText(aObj[3,5],"")
	SetText(aObj[3,7],"")
    SetText(aObj[3,10],"")
	If cManTes == "S"
		SetText(aObj[3,9],"")
	Endif
	nIteNot := 0
	nOpIte  := 1 //Inclusao
	HB1->( dbSetOrder(1) )
	HB1->( dbSeek(RetFilial("HB1")+aProduto[nLin,2]) ) //Codigo
	If HB1->(Found())
       aColitenf[3,1] := HB1->HB1_COD      
       NFExibe(aColitenf,aCabNot,aObj,cManPrc,cManTes)
    Endif                 
Endif
Return nil
                             

//Exibir dados do produto selecionado
Function NFExibe(aColitenf,aCabNot,aObj,cManPrc,cManTes)

If !Empty(aCabNot[7,1])
	dbSelectArea("HPR")
	dbSetOrder(1)
	dbSeek(RetFilial("HPR")+aColitenf[3,1]+aCabNot[7,1])
	If HPR->(Found())
		aColitenf[23,1]:=HPR->HPR_UNI
	else
		If HB1->HB1_PRV1 <> 0
			aColitenf[23,1]:=HB1->HB1_PRV1 
		Else
			MsgStop(STR0002 + aCabNot[7,1] + "!",STR0003) //"Preço não cadastrado na tabela "###"Aviso"
			If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
                NFLimpaItem(aColitenf,aObj,cManTes)
				Return nil			
			Endif			        
			aColitenf[23,1]:=0
		Endif
	Endif                       
Else
	If HB1->HB1_PRV1 == 0
		MsgStop(STR0004,STR0003) //"Preço não cadastrado!"###"Aviso"
		If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
           NFLimpaItem(aColitenf,aObj,cManTes)
		   Return nil
		Endif
	Endif
	aColitenf[23,1]:=HB1->HB1_PRV1
Endif	

If cManTes == "N"
	If !Empty(HB1->HB1_TS)
		aColitenf[11,1]:=HB1->HB1_TS
	Else
		MsgStop(STR0005 + AllTrim(aColitenf[3,1]) + STR0006,STR0003) //"Produto "###" c/ TES em branco. Solicite à retaguarda cadastrar!"###"Aviso"
  		NFLimpaItem(aColitenf,aObj,cManTes)
		Return nil
	Endif
Else //inicia o campo TES com a 1a.
	HF4->(dbGotop())
	aColitenf[11,1] := Alltrim(HF4->HF4_CODIGO)
	//SetText(aObj[3,9],aColitenf[11,1])
Endif
aColitenf[20,1]:=HB1->HB1_GRUPO   
aColitenf[43,1]:=HB1->HB1_DESC

SetText(aObj[3,3], aColitenf[6,1] )  
SetText(aObj[3,5], aColitenf[23,1])   //Exibe preco
SetText(aObj[3,7], aColitenf[13,1])   //
SetText(aObj[3,10],aColitenf[43,1])   //exibe descricao
SetFocus(aObj[3,3])                  //foco na qtde.
    
Return nil


//Limpar campos do item
Function NFLimpaItem(aColitenf,aObj,cManTes) 

aColitenf[2,1] := ""
aColitenf[4,1] := ""
aColitenf[6,1] := 0
aColitenf[7,1] := 0
aColitenf[23,1]:= 0
aColitenf[13,1]:= 0

SetText(aObj[3,3],aColitenf[6,1])
SetText(aObj[3,5],aColitenf[23,1])
SetText(aObj[3,7],aColitenf[13,1])
SetText(aObj[3,10],aColitenf[43,1])
If cManTes == "S"
	aColitenf[11,1] := ""
	SetText(aObj[3,9],aColitenf[11,1])
Endif
Return nil

// Funcao que gravar as parcelas da nota
Function NFGeraDup(aCabNot,aIteNot)
Local nDias:=0, cCondicao, ni,x1, nValParc:=0, cTipo:="NF",nParcelas:=0
Local dVenc:=date(),cCampo1:="",cCampo2:=""  
Local cParcela:="", np:=65 //comeca com parcela "A"
Local nTamanho:=0 , cNum:="" , cCodCli, cLojaCli
Local aTitulos:={}

cNum    :=aCabNot[1,1]       
cCodCli :=aCabNot[4,1]       
cLojaCli:=aCabNot[5,1]
cCondicao:=aCabNot[6,1] 

dbSelectarea("HE4")
dbSetOrder(1)
dbSeek( RetFilial("HE4")+cCondicao )     
cDias:=HE4->HE4_COND

cNrDias:= AllTrim(cDias) 
nTamanho := Len(cNrDias) 

//Descobre em quantas parcelas serah
For x1:=1 to nTamanho
    cCampo1:=Substr(cNrDIas,x1,1)
    if cCampo1<>"," 
       cCampo2:=cCampo2 + cCampo1
    elseif cCampo1="," 
       aadd( aTitulos,val(cCampo2) )   
       cCampo2:=""
    endif     
Next
aadd( aTitulos,val(cCampo2) )   

// Acha quantas parcelas 
nParcelas:=Len(aTitulos)              

// Acha o Valor de cada Parcela
nValParc := aCabNot[15,1] / nParcelas 

//Grava as Parcelas 
For ni:= 1 to nParcelas
    if nParcelas>1
       cParcela:=CHR(np) 
       np++
    endif
    dbSelectarea("HE1")
    dbSetOrder(1)         

    if !dbSeek( RetFilial("HE1")+cCodCLi+cLojaCli+cNum+cParcela )   
      
       HE1->( dbAppend() )
       HE1->HE1_FILIAL := RetFilial("HE1")	
       HE1->HE1_CLIENTE := cCodCli
       HE1->HE1_LOJA    := cLojaCli
       HE1->HE1_TIPO    := cTipo
       HE1->HE1_SALDO   := nValParc
       HE1->HE1_EMISSAO := Date()
       HE1->HE1_VENCTO  := Date() + aTitulos[ni,1]
       HE1->HE1_NUM     := cNum             
       HE1->HE1_PARCELA := cParcela
       HE1->HE1_STATUS  := "N"  // Para importar no Protheus
       HE1->(dbCommit()) 
    Endif                                   
Next    

Return 