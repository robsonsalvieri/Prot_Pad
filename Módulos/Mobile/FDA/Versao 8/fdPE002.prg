#INCLUDE "FDPE002.ch"
Function NFIteNot(nOpIte, aIteNot, nIteNot, aColIteNf, aCabNot,aObj,cManTes,cManPrc,cBloqPrc,cProDupl)
Local oIte, oFld
Local oBtnOK, oBtnVoltar, oBtnExcluir, oBtnTes, oTxtTes
Local oObj,aObjIte:= { {},{} }
Local nTotPedAnt:=0.00 , nTotNfAnt:=0.00
Local aCmpTes:={},aIndTes:={}                    

if Empty(aCabNot[6,1]) 
  MsgStop(STR0001,STR0002) //"Escolha uma Cond. de Pagto.!"###"Item do Pedido"
  Return Nil
elseif Empty(aCabNot[7,1])
  MsgStop(STR0003,STR0002) //"Escolha uma Tabela de Preço!"###"Item do Pedido"
  Return Nil
endif       

//Consulta TES
Aadd(aCmpTes,{STR0004,HF4->(FieldPos(STR0005)),30}) //"Código"###"F4_CODIGO"
Aadd(aCmpTes,{STR0006,HF4->(FieldPos("F4_TEXTO")),100}) //"Descrição"
Aadd(aIndTes,{STR0004,1}) //"Código"

MontaColIteNf(aColIteNf)

If nOpIte=1
	// Limpa as Variáveis (Array de Itens aColIte)
	nIteNot		:=0
	DEFINE DIALOG oIte TITLE STR0007 + Alltrim(Str(Len(aIteNot)+1))  //"Novo Item Nº  "
Else
	if len(aIteNot) == 0 	
		Return Nil
	Endif
	nIteNot:=GridRow(aObj[3,1])
	if nIteNot > 0 
       	For nI:=1 to Len(aColIteNf)
			aColIteNf[nI,1] := aIteNot[nIteNot,nI]
		Next 
		
		nTotNfAnt 	:=aCabNot[15,1]
		//NFCalcNot(aCabNot,aColIte,aIteNot,nIteNot,.F.,,.F.)
	Endif

	DEFINE DIALOG oIte TITLE STR0008 + Alltrim(Str(nIteNot)) + "/" + Alltrim(Str(Len(aIteNot))) //"Item Nº  "
Endif

ADD FOLDER oFld CAPTION STR0009 OF oIte //"Principal"
@ 18,01 TO 125,157 CAPTION STR0009 OF oFld //"Principal"
@ 30,03 BUTTON oObj CAPTION STR0010 ACTION NFProduto(aColIteNf,aObjIte,aCabNot,cManTes,cManPrc,.F.) SIZE 39,11 of oFld //"Produto"
AADD(aObjIte[1],oObj)
@ 30,50 GET oObj VAR aColIteNf[1,1] SIZE 100,15 VALID NFProduto(aColIteNf,aObjIte,aCabNot,cManTes,cManPrc,.T.) of oFld
AADD(aObjIte[1],oObj)
@ 45,03 GET oObj VAR aColIteNf[2,1] SIZE 140,12 READONLY NO UNDERLINE OF oFld
AADD(aObjIte[1],oObj)
@ 60,03 BUTTON oObj CAPTION STR0011 ACTION PVQTde(aObjIte[1,5]) SIZE 39,17 of oFld //"Qtde."
AADD(aObjIte[1],oObj)
@ 60,50 GET oObj VAR aColIteNf[6,1] SIZE 40,15 of oFld
AADD(aObjIte[1],oObj)
If cBloqPrc == "S"	//Bloqueia campo Preco
	@ 75,03 BUTTON oObj CAPTION STR0012 SIZE 39,17 of oFld //"Preço"
	AADD(aObjIte[1],oObj)
	@ 75,50 GET oObj VAR aColIteNf[23,1] PICTURE "@E 9,999.99" READONLY SIZE 50,15 of oFld
	AADD(aObjIte[1],oObj)                                                            
Else
	@ 75,03 BUTTON oObj CAPTION STR0012 ACTION PVPrc(aObjIte[1,7]) SIZE 39,17 of oFld //"Preço"
	AADD(aObjIte[1],oObj)
	@ 75,50 GET oObj VAR aColIteNf[23,1] PICTURE "@E 9,999.99" SIZE 50,15 of oFld
	AADD(aObjIte[1],oObj)                                                            
Endif
@ 90,03 BUTTON oObj CAPTION STR0013 ACTION PVDesc(aObjIte[1,9]) SIZE 39,11 of oFld //"Desc"
AADD(aObjIte[1],oObj)
@ 90,50 GET oObj VAR aColIteNf[7,1] PICTURE "@E 9,999.99" SIZE 45,15 of oFld
AADD(aObjIte[1],oObj)

If cManTes == "S"	//Permite a manipulacao da TES
	If nOpIte==1	//Inicia com a 1a. TES quando for novo item
		dbSelectArea("HF4")
		dbSetOrder(1)
		dbGotop()
		aColIte[8,1] := Alltrim(HF4->HF4_CODIGO)
	Endif
	@ 105,03 BUTTON oBtnTes CAPTION "Tes" ACTION SFConsPadrao("HF4",aColIte[8,1],aObjIte[1,11],aCmpTes,aIndTes) SIZE 39,11 of oFld
	@ 105,50 GET oTxtTes VAR aColIteNf[8,1] SIZE 30,15 of oFld
Endif                            
AADD(aObjIte[1],oBtnTes)
AADD(aObjIte[1],oTxtTes)

@ 130,55 BUTTON oBtnOK CAPTION BTN_BITMAP_OK SYMBOL SIZE 33,11 ACTION NFGrvIte(aColIteNf,aIteNot, nIteNot, aCabNot,aObj,@cManTes,cProDupl,nOpIte) of oIte
@ 130,90 BUTTON oBtnVoltar CAPTION STR0014 SIZE 33,11 ACTION NFCanIteNF(aCabNot,nIteNot,nTotPedAnt,aObj) of oIte //"Voltar"
If nOpIte=2
	@ 130,125 BUTTON oBtnExcluir CAPTION STR0015 SIZE 33,11 ACTION NFExcIte(aIteNot,@nIteNot, aCabNot,aObj, .T.) of oIte //"Excluir"
Endif 

ACTIVATE DIALOG oIte

Return Nil