Function PVIteRec(nOpIte, aIteRec, nIteRec, aColIteRC, aCabRec,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix)
Local oIte, oFld
Local oBtnOK, oBtnVoltar, oBtnExcluir, oBtnTes, oTxtTes
Local oObj,aObjIte:= { {},{} }
Local nTotRecAnt:=0.00
Local aCmpTes:={},aIndTes:={}
Local cEstOnLine := ""

If Empty(aCabRec[7,1]) 
  MsgStop("Escolha uma Cond. de Pagto.!","Item do Recido")
  Return Nil
elseif Empty(aCabRec[8,1])
  MsgStop("Escolha uma Tabela de Preço!","Item do Recido")
  Return Nil
endif       

//Consulta TES
Aadd(aCmpTes,{"Código",HF4->(FieldPos("F4_CODIGO")),30})
Aadd(aCmpTes,{"Descrição",HF4->(FieldPos("F4_TEXTO")),100})
Aadd(aIndTes,{"Código",1})

PVMontaColIteRC(aColIteRC)
 
If nOpIte=1
	// Limpa as Variáveis (Array de Itens aColIteRC)
	nIteRec		:=0
	DEFINE DIALOG oIte TITLE "Novo Item Nº  " + Alltrim(Str(Len(aIteRec)+1))//"Item do Recido"
Else
	if len(aIteRec) == 0 	
		Return Nil
	Endif
	nIteRec:=GridRow(aObj[3,1])
	if nIteRec > 0 
       	For nI:=1 to Len(aColIteRC)
			aColIteRC[nI,1] := aIteRec[nIteRec,nI]
		Next 
		
		nTotRecAnt 	:=aCabRec[11,1]
		PVCalcRec(aCabRec,aColIteRC,aIteRec,nIteRec,.F.,,.F.)
	Endif

	DEFINE DIALOG oIte TITLE "Item Nº  " + Alltrim(Str(nIteRec)) + "/" + Alltrim(Str(Len(aIteRec)))
Endif

ADD FOLDER oFld CAPTION "Principal" OF oIte
@ 18,01 TO 125,157 CAPTION "Principal" OF oFld
@ 30,03 BUTTON oObj CAPTION "Produto" ACTION PVProduto(aColIteRC,aObjIte,aCabRec,cManTes,cManPrc,.F.,aPrdPrefix) SIZE 39,11 of oFld
AADD(aObjIte[1],oObj) // 1 - Botao Produto
@ 30,50 GET oObj VAR aColIteRC[1,1] SIZE 100,15 VALID PVProduto(aColIteRC,aObjIte,aCabRec,cManTes,cManPrc,.T.,aPrdPrefix) of oFld
AADD(aObjIte[1],oObj) // 2 - Get Produto
@ 45,03 GET oObj VAR aColIteRC[2,1] SIZE 140,12 READONLY NO UNDERLINE OF oFld
AADD(aObjIte[1],oObj) // 3 - Get Descricao do Produto
@ 60,03 BUTTON oObj CAPTION "Qtde." ACTION PVQTde(aObjIte[1,5]) SIZE 39,11 of oFld
AADD(aObjIte[1],oObj) // 4 - Botao Quantidade
@ 60,50 GET oObj VAR aColIteRC[4,1] SIZE 40,15 of oFld
AADD(aObjIte[1],oObj) // 5 - Get Quantidade
/*
cEstOnLine := "T"
If cEstOnLine = "T"
	// Este Objeto nao e adicionado ao Arrya
	@ 60,120 BUTTON oObj CAPTION "Estoque" ACTION ConsEstOnLine(aColIteRC[1,1]) SIZE 39,11 of oFld
EndIf
*/
If cBloqPrc == "S"	//Bloqueia campo Preco
	@ 75,03 BUTTON oObj CAPTION "Preço" SIZE 39,11 of oFld
	AADD(aObjIte[1],oObj) // 6 - Botao Preco
	@ 75,50 GET oObj VAR aColIteRC[6,1] PICTURE "@E 9,999.99" READONLY SIZE 50,15 of oFld
	AADD(aObjIte[1],oObj) // 7 - Get Preco
Else
	@ 75,03 BUTTON oObj CAPTION "Preço" ACTION PVPrc(aObjIte[1,7]) SIZE 39,11 of oFld
	AADD(aObjIte[1],oObj) // 6 - Botao Preco
	@ 75,50 GET oObj VAR aColIteRC[6,1] PICTURE "@E 9,999.99" SIZE 50,15 of oFld
	AADD(aObjIte[1],oObj) // 7 - Get Preco                                                            
Endif
@ 90,03 BUTTON oObj CAPTION "Desc" ACTION PVDesc(aObjIte[1,9]) SIZE 39,11 of oFld
AADD(aObjIte[1],oObj) // 8 - Botao Desconto
@ 90,50 GET oObj VAR aColIteRC[7,1] PICTURE "@E 9,999.99" SIZE 45,15 of oFld
AADD(aObjIte[1],oObj) // 9 - Get Desconto

If cManTes == "S"	//Permite a manipulacao da TES
	If nOpIte==1	//Inicia com a 1a. TES quando for novo item
		dbSelectArea("HF4")
		dbSetOrder(1)
		dbGotop()
		aColIteRC[8,1] := Alltrim(HF4->HF4_CODIGO)
	Endif
	@ 105,03 BUTTON oBtnTes CAPTION "Tes" ACTION SFConsPadrao("HF4",aColIteRC[8,1],aObjIte[1,11],aCmpTes,aIndTes,) SIZE 39,11 of oFld
	@ 105,50 GET oTxtTes VAR aColIteRC[8,1] SIZE 30,15 of oFld
	AADD(aObjIte[1],oBtnTes) // 10 - Botao TES
	AADD(aObjIte[1],oTxtTes) // 11 - Get TES
Endif

@ 130,55 BUTTON oBtnOK CAPTION BTN_BITMAP_OK SYMBOL SIZE 33,11 ACTION RCGrvIte(aColIteRC,aIteRec, nIteRec, aCabRec,aObj,@cManTes,cProDupl,nOpIte,1) of oIte
@ 130,90 BUTTON oBtnVoltar CAPTION "Voltar" SIZE 33,11 ACTION RCCanIteRec(aCabRec,nIteRec,nTotRecAnt,aObj) of oIte
If nOpIte=2
	@ 130,125 BUTTON oBtnExcluir CAPTION "Excluir" SIZE 33,11 ACTION PVExcIte(aIteRec,@nIteRec, aCabRec,aObj, .T.,1) of oIte
Endif 

/*Ponto de Entrada: Tela do Detalhe do Recido
#IFDEF _PEPV0002_
	//Objetivo: 
	//Retorno:    
	uRet := PEPV0002(oIte,oFld,aObjIte,aColIteRC)
#ENDIF*/

ACTIVATE DIALOG oIte

Return Nil