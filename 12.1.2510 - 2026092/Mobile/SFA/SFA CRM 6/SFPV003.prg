#INCLUDE "SFPV003.ch"
Function PVItePed(nOpIte, aItePed, nItePed, aColIte, aCabPed,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix)
Local oIte, oFld
Local oBtnOK, oBtnVoltar, oBtnExcluir, oBtnTes, oTxtTes
Local oObj,aObjIte:= { {},{} }
Local nTotPedAnt:=0.00
Local aCmpTes:={},aIndTes:={}
Local cEstOnLine := ""
Local cPictPr := ""

If Empty(aCabPed[7,1]) 
  MsgStop(STR0001,STR0002) //"Escolha uma Cond. de Pagto.!"###"Item do Pedido"
  Return Nil
elseif Empty(aCabPed[8,1])
  MsgStop(STR0003,STR0002) //"Escolha uma Tabela de Preço!"###"Item do Pedido"
  Return Nil
endif       

//Consulta TES
Aadd(aCmpTes,{STR0004,HF4->(FieldPos("F4_CODIGO")),30}) //"Código"
Aadd(aCmpTes,{STR0005,HF4->(FieldPos("F4_TEXTO")),100}) //"Descrição"
Aadd(aIndTes,{STR0004,1}) //"Código"

PVMontaColIte(aColIte)
 
If nOpIte=1
	// Limpa as Variáveis (Array de Itens aColIte)
	nItePed		:=0
	DEFINE DIALOG oIte TITLE STR0006 + Alltrim(Str(Len(aItePed)+1))//"Item do Pedido" //"Novo Item Nº  "
Else
	if len(aItePed) == 0 	
		Return Nil
	Endif
	nItePed:=GridRow(aObj[3,1])
	if nItePed > 0 
       	For nI:=1 to Len(aColIte)
			aColIte[nI,1] := aItePed[nItePed,nI]
		Next 
		
		nTotPedAnt 	:= aCabPed[11,1]
		PVCalcPed(aCabPed,aColIte,aItePed,nItePed,.F.,,.F.)
	Endif

	DEFINE DIALOG oIte TITLE STR0007 + Alltrim(Str(nItePed)) + "/" + Alltrim(Str(Len(aItePed))) //"Item Nº  "
Endif

ADD FOLDER oFld CAPTION STR0008 OF oIte //"Principal"
@ 18,01 TO 125,157 CAPTION STR0008 OF oFld //"Principal"
@ 30,03 BUTTON oObj CAPTION STR0009 ACTION PVProduto(aColIte,aObjIte,aCabPed,cManTes,cManPrc,.F.,aPrdPrefix) SIZE 39,11 of oFld //"Produto"
AADD(aObjIte[1],oObj) // 1 - Botao Produto
@ 30,50 GET oObj VAR aColIte[1,1] SIZE 100,15 VALID PVProduto(aColIte,aObjIte,aCabPed,cManTes,cManPrc,.T.,aPrdPrefix) of oFld
AADD(aObjIte[1],oObj) // 2 - Get Produto
@ 45,03 GET oObj VAR aColIte[2,1] SIZE 140,12 READONLY NO UNDERLINE OF oFld
AADD(aObjIte[1],oObj) // 3 - Get Descricao do Produto
@ 60,03 BUTTON oObj CAPTION STR0010 ACTION PVQTde(aObjIte[1,5],aColIte,aCabPed,aObjIte[1,7]) SIZE 39,11 of oFld //"Qtde."
AADD(aObjIte[1],oObj) // 4 - Botao Quantidade
@ 60,50 GET oObj VAR aColIte[4,1] SIZE 40,15 of oFld
AADD(aObjIte[1],oObj) // 5 - Get Quantidade

cPictPr := SetPicture("HPR", HPR->(FieldPos("PR_UNI")))
If cBloqPrc == "S"	//Bloqueia campo Preco
	@ 75,03 BUTTON oObj CAPTION STR0011 SIZE 39,11 of oFld //"Preço"
	AADD(aObjIte[1],oObj) // 6 - Botao Preco
	@ 75,50 GET oObj VAR aColIte[6,1] PICTURE cPictPr READONLY SIZE 50,15 of oFld
	AADD(aObjIte[1],oObj) // 7 - Get Preco
Else //Desbloqueia
	@ 75,03 BUTTON oObj CAPTION STR0011 ACTION PVPrc(aObjIte[1,7]) SIZE 39,11 of oFld //"Preço"
	AADD(aObjIte[1],oObj) // 6 - Botao Preco
	@ 75,50 GET oObj VAR aColIte[6,1] PICTURE cPictPr;
	VALID PVValidaPrc(aObjIte[1,7],aColIte,aCabPed,cBloqPrc,aObjIte[1,9]) SIZE 50,15 of oFld
	AADD(aObjIte[1],oObj) // 7 - Get Preco                                                            
Endif

@ 90,03 BUTTON oObj CAPTION STR0012 ACTION PVDesc(aObjIte[1,9]) SIZE 39,11 of oFld //"Desc"
AADD(aObjIte[1],oObj) // 8 - Botao Desconto
@ 90,50 GET oObj VAR aColIte[7,1] PICTURE "@E 9,999.99" VALID PVCalcDesc(aColIte) SIZE 45,15 of oFld
AADD(aObjIte[1],oObj) // 9 - Get Desconto

If cManTes == "S"	//Permite a manipulacao da TES
	If nOpIte==1	//Inicia com a 1a. TES quando for novo item
		dbSelectArea("HF4")
		dbSetOrder(1)
		dbGotop()
		aColIte[8,1] := Alltrim(HF4->F4_CODIGO)
	Endif
	@ 105,03 BUTTON oBtnTes CAPTION STR0013 ACTION SFConsPadrao("HF4",aColIte[8,1],aObjIte[1,11],aCmpTes,aIndTes,) SIZE 39,11 of oFld //"Tes"
	@ 105,50 GET oTxtTes VAR aColIte[8,1] SIZE 30,15 of oFld
	AADD(aObjIte[1],oBtnTes) // 10 - Botao TES
	AADD(aObjIte[1],oTxtTes) // 11 - Get TES
Endif

@ 130,55 BUTTON oBtnOK CAPTION STR0014 SIZE 33,11 ACTION PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,@cManTes,cProDupl,nOpIte,1) of oIte //"OK"
@ 130,90 BUTTON oBtnVoltar CAPTION STR0015 SIZE 33,11 ACTION PVCanItePed(aCabPed,nItePed,nTotPedAnt,aObj) of oIte //"Voltar"
If nOpIte=2
	@ 130,125 BUTTON oBtnExcluir CAPTION STR0016 SIZE 33,11 ACTION PVExcIte(aItePed,@nItePed, aCabPed,aObj, .T.,1) of oIte //"Excluir"
Endif 

/*Ponto de Entrada: Tela do Detalhe do pedido
#IFDEF _PEPV0002_
	//Objetivo: 
	//Retorno:    
	uRet := PEPV0002(oIte,oFld,aObjIte,aColIte)
#ENDIF*/

ACTIVATE DIALOG oIte

Return Nil
