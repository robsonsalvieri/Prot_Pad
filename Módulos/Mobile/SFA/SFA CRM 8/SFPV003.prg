#INCLUDE "SFPV003.ch"
#include "eADVPL.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVItePed  บAutor  ณMarcelo Vieira      บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de inclusao/alteracao de um item do pedido.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PVItePed(nOpIte, aItePed, nItePed, aColIte, aCabPed,aObj,cManTes,cManPrc,cBloqPrc,cProDupl, aPrdPrefix)

Local oIte, oFld, oFldDet
Local oBtnOK, oBtnVoltar, oBtnExcluir, oBtnTes, oTxtTes, oSay
Local oObj,aObjIte	:= { {},{} }
Local nTotPedAnt	:= 0.00
Local nEstoque 		:= 0
Local aCmpTes		:= {},aIndTes:={}
Local cEstOnLine	:= ""
Local cProdSim		:= ""
Local cProduto		:= ""
Local cPictVal		:= SetPicture("HPR","HPR_UNI")
Local cPictDes		:= SetPicture("HB1","HC6_DESC")
Local cPictPeso 	:= SetPicture("HB1","HB1_PBRUTO")
Local cPictProd		:= SetPicture("HB1","HB1_COD")
Local cPictQtd		:= SetPicture("HC6","HC6_QTDVEN")
Local nPosPeso 		:= 0
Local cBloqDsc		:= "N"
Local oGetProd
Local oGetQtde

//Variaveis para tratamento de tela com tamanhos variados
Local nSizeobj1 := 12
Local nDistobj1 := 15
Local nPos		:= 0
Local nLinQtd	:= 0
Local nLinSim	:= 0
Local nColSim	:= 0
Local nSizeFld	:= 133

If lNotTouch
	nSizeobj1	:= 15
	nDistobj1	:= 18
EndIf

If Empty(aCabPed[7,1]) 
  MsgStop(STR0001,STR0002) //"Escolha uma Cond. de Pagto.!"###"Item do Pedido"
  Return Nil
elseif Empty(aCabPed[8,1])
  MsgStop(STR0003,STR0002) //"Escolha uma Tabela de Pre็o!"###"Item do Pedido"
  Return Nil
endif       

//Consulta TES
Aadd(aCmpTes,{STR0004,HF4->(FieldPos("HF4_CODIGO")),30}) //"C๓digo"
Aadd(aCmpTes,{STR0005,HF4->(FieldPos("HF4_TEXTO")),100}) //"Descri็ใo"
Aadd(aIndTes,{STR0004,1}) //"C๓digo"

PVMontaColIte(aColIte)
 
If nOpIte=1
	// Limpa as Variแveis (Array de Itens aColIte)
	nItePed		:=0                             
	DEFINE DIALOG oIte TITLE STR0006 + Alltrim(Str(Len(aItePed)+1))//"Item do Pedido" //"Novo Item Nบ  "
Else
	if len(aItePed) == 0 	
		Return Nil
	Endif
	nItePed:=GridRow(aObj[3,1])
	if nItePed > 0 
       	For nI:=1 to Len(aColIte)
			aColIte[nI,1] := aItePed[nItePed,nI]
		Next
		//Carrega quantidade auxiliar
		aColIte[18,1] := aColIte[4,1]
		
		nTotPedAnt 	:= aCabPed[11,1]
		//Subtrai item atual do total do pedido
		PVCalcPed(aCabPed,aColIte,aItePed,nItePed,.F.,,.F.)
	Endif

	DEFINE DIALOG oIte TITLE STR0007 + Alltrim(Str(nItePed)) + "/" + Alltrim(Str(Len(aItePed))) //"Item Nบ  "
Endif

nPos := 30
#IFDEF __PALM__
	nPos := 28
	nSizeobj1	:= 11
	nDistobj1	:= 14
	nSizeFld	:= 130
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFolder Principal    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ADD FOLDER oFld CAPTION STR0008 OF oIte //"Principal"
If lNotTouch
	@ 18,01 TO 138,157 CAPTION STR0008 OF oFld //"Principal"
Else
	@ 21,01 TO nSizeFld,157 CAPTION STR0008 OF oFld //"Principal"
EndIf

//Botao Produto
@ nPos,03 BUTTON oObj CAPTION STR0009 ACTION PVProduto(aColIte,aObjIte,aCabPed,cManTes,cManPrc,.F.,aPrdPrefix,cProduto) SIZE 39,nSizeobj1 of oFld //"Produto"
AADD(aObjIte[1],oObj) // 1 - Botao Produto
//Se for alteracao inibe o botao produtos e bloqueia o get
If nOpIte == 2
	DisableConTrol(aObjIte[1][1])
	@ nPos,50 GET oGetProd VAR aColIte[1,1] PICTURE cPictProd SIZE 100,15 READONLY OF oFld
Else
	@ nPos,50 GET oGetProd VAR aColIte[1,1] PICTURE cPictProd SIZE 100,15 VALID PVProduto(aColIte,aObjIte,aCabPed,cManTes,cManPrc,.T.,aPrdPrefix,cProduto) of oFld
EndIF
AADD(aObjIte[1],oGetProd) // 2 - Get Produto

//Descricao do produto
nPos += nDistobj1
@ nPos,03 GET oObj VAR aColIte[2,1] SIZE 140,nSizeobj1 READONLY NO UNDERLINE OF oFld
AADD(aObjIte[1],oObj) // 3 - Get Descricao do Produto

//Botao Quantidade
nPos += nDistobj1
nLinQtd := nPos
@ nPos,03 BUTTON oObj CAPTION STR0010 ACTION PVQTde(aObjIte[1,5]) SIZE 39,nSizeobj1 of oFld //"Qtde."
AADD(aObjIte[1],oObj) // 4 - Botao Quantidade
@ nPos,50 GET oGetQtde VAR aColIte[4,1] SIZE 40,15 PICTURE cPictQtd VALID PVGetItQtd(aColIte, aCabPed, aObjIte, .T., cBloqPrc) of oFld
//SET ON CHANGE GET oGetQtde TO PVGetItQtd(aColIte, aCabPed, aObjIte, .F., cBloqPrc)
AADD(aObjIte[1],oGetQtde) // 5 - Get Quantidade
If nOpIte=1
	SetText(aObjIte[1,5],"")  
Endif	

//Botao Pre็o
nPos += nDistobj1
If cBloqPrc $ "S/1"	//Bloqueia campo Preco
	@ nPos,03 BUTTON oObj CAPTION STR0011 SIZE 39,nSizeobj1 of oFld //"Pre็o"
	AADD(aObjIte[1],oObj) // 6 - Botao Preco
	@ nPos,50 GET oObj VAR aColIte[6,1] PICTURE cPictVal READONLY SIZE 50,15 of oFld
	AADD(aObjIte[1],oObj) // 7 - Get Preco
Else //Desbloqueia
	@ nPos,03 BUTTON oObj CAPTION STR0011 ACTION PVPrc(aObjIte[1,7]) SIZE 39,nSizeobj1 of oFld //"Pre็o"
	AADD(aObjIte[1],oObj) // 6 - Botao Preco
	@ nPos,50 GET oObj VAR aColIte[6,1] PICTURE cPictVal;
	VALID PVValidaPrc(aObjIte[1,7],aColIte,aCabPed,cBloqPrc,aObjIte[1,9],.T.) SIZE 50,15 of oFld
	AADD(aObjIte[1],oObj) // 7 - Get Preco
Endif

//Botao Desconto
cBloqDsc := SFGetMv("MV_BLOQDSC",.F.,cBloqPrc)
nPos += nDistobj1
If cBloqDsc $ "S/1"	//Bloqueia Desconto.
	@ nPos,03 BUTTON oObj CAPTION STR0012 SIZE 39,nSizeobj1 of oFld //"Desc"
	AADD(aObjIte[1],oObj) // 8 - Botao Desconto
	@ nPos,50 GET oObj VAR aColIte[7,1] PICTURE cPictDes READONLY SIZE 45,15 of oFld
	AADD(aObjIte[1],oObj) // 9 - Get Desconto
Else
	@ nPos,03 BUTTON oObj CAPTION STR0012 ACTION PVDesc(aObjIte[1,9]) SIZE 39,nSizeobj1 of oFld //"Desc"
	AADD(aObjIte[1],oObj) // 8 - Botao Desconto
	@ nPos,50 GET oObj VAR aColIte[7,1] PICTURE cPictDes VALID PVCalcDesc(aColIte,aObjIte,aCabPed,cBloqPrc,1) SIZE 45,15 of oFld
	AADD(aObjIte[1],oObj) // 9 - Get Desconto
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณ Similar  ณ
//ภฤฤฤฤฤฤฤฤฤฤู
If SFGetMv("MV_SFAPRSI",.F.,"N") == "S"                                         
	If Select("HCU")>0 .And. Select("HCV")>0
		If lNotTouch
			nLinSim := nLinQtd
			nColSim := 100
		Else
			nPos += nDistobj1
			nLinSim := nPos
			nColSim := 03
		EndIf
		@ nLinSim,nColSim BUTTON oObj CAPTION STR0017 ACTION PVBtSimil(aColIte[1,1],aColIte,aObjIte,aCabPed,cManTes,cManPrc,aPrdPrefix,cBloqPrc) SIZE 39,nSizeobj1 of oFld //"Similar"
		AADD(aObjIte[1],oObj) // 10 - Botao Produto Similar
		If nOpIte == 2
			//Isto irแ ocultar o botใo Similar
			HideConTrol(aObjIte[1,10])
		EndIf
	Else
		AADD(aObjIte[1],"") // 10
		MsgAlert(STR0018+Chr(13)+Chr(10)+STR0019,STR0020)//"Nใo serแ possํvel a consulta de Prod. Similares. Tabelas "###"HCU - Categorias ou HCV - Categorias x Produtos nใo existem!"###"Aten็ใo!"
	EndIf
Else
	AADD(aObjIte[1],"") // 10
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณManipulacao da TES   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPos += nDistobj1
If cManTes == "S"	//Permite a manipulacao da TES
	@ nPos,03 BUTTON oBtnTes CAPTION STR0013 ACTION SFConsPadrao("HF4",aColIte[8,1],aObjIte[1,12],aCmpTes,aIndTes,) SIZE 39,nSizeobj1 of oFld //"Tes"
	@ nPos,50 GET oTxtTes VAR aColIte[8,1] SIZE 30,15 VALID ExistCpo("HF4",aColIte[8,1]) of oFld
	AADD(aObjIte[1],oBtnTes) // 11 - Botao TES
	AADD(aObjIte[1],oTxtTes) // 12 - Get TES
Else
	AADD(aObjIte[1],"")
	AADD(aObjIte[1],"")
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPeso Bruto           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ nPos,82 SAY oSay PROMPT STR0024 OF oFld //"Peso:"
AADD(aObjIte[1],oSay) // 13 - Label Peso
@ nPos,104 GET oObj VAR aColIte[17,1] PICTURE cPictPeso READONLY NO UNDERLINE SIZE 45,15 of oFld
AADD(aObjIte[1],oObj) // 14 - Get Peso

If cSfaPeso == "T"
	nPosPeso := At(",",SFGetMv("MV_SFAPESO"))
Else
	HideControl(aObjIte[1,13])
	HideControl(aObjIte[1,14])
Endif

/*If nDistobj1 == 14
	nDistobj1 := 15
	nSizeobj1 := 12
EndIf*/
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotoes OK/Voltar/Excluir   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 120+nDistobj1,52 BUTTON oBtnOK CAPTION STR0014 SIZE 33,nSizeobj1 ACTION PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,@cManTes,cProDupl,nOpIte,1,0,aObjIte,oIte,@cProduto) of oIte //"OK"
@ 120+nDistobj1,89 BUTTON oBtnVoltar CAPTION STR0015 SIZE 33,nSizeobj1 ACTION PVCanItePed(aCabPed,nItePed,nTotPedAnt,aObj) of oIte //"Voltar"
If nOpIte=2
	@ 120+nDistobj1,126 BUTTON oBtnExcluir CAPTION STR0016 SIZE 34,nSizeobj1 ACTION PVExcIte(aItePed,@nItePed,aCabPed,aObj, .T.,1) of oIte //"Excluir"
Endif 

If ExistBlock("SFAPV005")
	ExecBlock("SFAPV005", .F., .F., {oIte, oFld, aObjIte, aColIte, aCabPed, aItePed})
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFolder Detalhe      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ADD FOLDER oFldDet CAPTION STR0021 ON ACTIVATE PVSetDet(cProduto,aObjIte,aColIte) OF oIte //"Detalhes"
@ 18,01 TO 120,157 CAPTION STR0021 OF oFldDet //"Detalhes"

@ 30,03 SAY "Produto: " of oFldDet 
@ 30,40 GET oObj VAR aColIte[1,1] SIZE 100,15 READONLY NO UNDERLINE OF oFldDet
AADD(aObjIte[2],oObj) // 1 - Get Produto
@ 45,03 SAY "Desc.: " of oFldDet // Descricao
@ 45,40 GET oObj VAR aColIte[2,1] SIZE 140,nSizeobj1 READONLY NO UNDERLINE OF oFldDet
AADD(aObjIte[2],oObj) // 2 - Get Descricao do Produto
@ 60,03 SAY "Estoque: " of oFldDet
@ 60,40 GET oObj VAR nEstoque SIZE 100,15 READONLY NO UNDERLINE OF oFldDet
AADD(aObjIte[2],oObj) // 3 - Estoque

If lNotTouch
	DisableControl(aObjIte[1][4])
	DisableControl(aObjIte[1][6])
	DisableControl(aObjIte[1][8])

	If nOpIte=1
		SetFocus(oGetProd)
	Else
		SetFocus(oGetQtde)
	EndIf
EndIf

ACTIVATE DIALOG oIte

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVPrecoTabบAutor  ณRodrigo A. Godinho  บ Data ณ  04/17/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca o preco unitario do produto de acordo com as faixas   บฑฑ
ฑฑบ          ณde quantidades das tabelas de precos.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณaColIte - array com estrutura dos itens do pedido           บฑฑ
ฑฑบParametrosณaCabPed - array com estrutura do cabecalho do pedido        บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PVPrecoTab(aColIte, aCabPed)
Local cQtd	:= StrTran( StrZero(aColIte[4,1],18,2), ",", ".")
Local cProd	:= aColIte[1,1]
Local cTab	:= aCabPed[8,1]

If HPR->(FieldPos("HPR_QTDLOT")) != 0 .And. HPR->(FieldPos("HPR_INDLOT")) != 0
	If !Empty(aColIte[1,1]) .And. !Empty(aCabPed[8,1]) .And. !Empty(aColIte[4,1])
		HPR->(dbSetOrder(2))
		HPR->(DbSeek( RetFilial("HPR")+ALlTrim(aColITe[1,1])+Space(Len(HPR->HPR_PROD)-Len(AllTrim(cProd)))+AllTrim(aCabPed[8,1])+cQtd, .T.))
		If !HPR->(Eof()) .And. AllTrim(HPR->HPR_PROD) == AllTrim(aColIte[1,1]) .And. AllTrim(HPR->HPR_TAB) == Alltrim(aCabPed[8,1]) .And. HPR->HPR_QTDLOT >= aColIte[4,1]
			aColIte[6,1] := HPR->HPR_UNI
			aColIte[16,1] := HPR->HPR_UNI
		EndIf
	EndIf
EndIf

HPR->(dbSetOrder(1))
Return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVSetDet  บAutor  ณRodrigo A. Godinho  บ Data ณ  07/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o conteudo do folder de detalhes da tela de itens  บฑฑ
ฑฑบ          ณdo pedido de venda.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณcProduto - codigo do produto                                บฑฑ
ฑฑบParametrosณaObjIte - array de objetos mostrados na tela do pedido      บฑฑ
ฑฑบ          ณaColIte - array de colunas do item de pedido                บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PVSetDet(cProduto,aObjIte,aColIte)

SetText(aObjIte[2,1],aColIte[1,1])
SetText(aObjIte[2,2],aColIte[2,1])
HB2->(dbSetOrder(1))
If HB2->(dbSeek(RetFilial("HB2") + aColIte[1,1])) .And. !Empty(AllTrim(aColIte[1,1]))
	SetText(aObjIte[2,3],Str(HB2->HB2_QTD,5,2) + " em " + DtoC(HB2->HB2_DATA))
Else
	SetText(aObjIte[2,3],Str(0,5,2) + " em " + DtoC(Date()))
EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVConvUM  บAutor  ณRodrigo A. Godinho  บ Data ณ  07/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerificar se a quantidade informada ้ multiplo do fator de  บฑฑ
ฑฑบ          ณconversao da segunda unidade de medida.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณcProduto - codigo do produto.                               บฑฑ
ฑฑบParametrosณnQtde - quantidade a ser veficada.                          บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PVConvUM(cProduto,nQtde)
Local lRet	:=	.T.

dbSelectArea("HB1")
HB1->(dbSetOrder(1))

If HB1->( dbSeek( RetFilial("HB1")+cProduto ) )
	If HB1->HB1_CONV > 0 .And. nQtde > 0 .And. HB1->HB1_TIPCON == "D" 
		If (nQtde%HB1->HB1_CONV) <> 0
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVGetItQtdบAutor  ณRodrigo A. Godinho  บ Data ณ  07/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao do action do botam Quantidade da tela de itens do    บฑฑ
ฑฑบ          ณpedido de venda.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณaColIte - array com estrutura dos itens do pedido           บฑฑ
ฑฑบParametrosณaCabPed - array com estrutura do cabecalho do pedido        บฑฑ
ฑฑบ          ณaObjIte - array de objetos mostrados na tela do pedido      บฑฑ 
ฑฑบ          ณlConvQtd - indica se havera verificacao da qtde ou nao      บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PVGetItQtd(aColIte, aCabPed, aObjIte, lConvQtd, cBloqPrc)
Local cConvQtd	:=	""
Local lRet	:=	.T.
Local lVrfItem	:= .T.

If ExistBlock("SFAPV022")
	lVrfItem := ExecBlock("SFAPV022", .F., .F., {aColIte,aCabPed,aObjIte})
	If !lVrfItem
		Return .T.
	EndIf
EndIf

	If Len(aColIte) < 0
	   Return lRet
	EndIf

    If aColIte[4,1] == aColIte[18,1]
	   Return lRet
    EndIf
	
	// Habilita o controle de quantidade do produto
	cConvQtd := SFGetMv("MV_SFFTCON",.F.,"F")
	If lConvQtd .And. cConvQtd == "T" 
		If !PVConvUM(aColIte[1,1],aColIte[4,1])
			MsgAlert( STR0022 + Alltrim(Str(HB1->HB1_CONV)) , STR0023 )//"A quantidade informada nใo ้ um n๚mero multiplo de "###"Quantidade Incorreta"
			Return nil	
		EndIf
	EndIf
	
	//Verifica pre็o de acordo com a faixa de qtd informada
	PVPrecoTab(aColIte, aCabPed)
	
	If (SFGetMv("MV_SFRGDSC",,"S") == "S")
		//Aplica regra de desconto no item
		RGAplDescIte(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], aCabPed[15,1], aColIte)
	EndIf

	PVDesconto(aColIte, aCabPed)

	SetText(aObjIte[1,7],aColIte[6,1])
	SetText(aObjIte[1,9],aColIte[7,1])
	
	If Len(aObjIte[1]) >=14
	    // Calculo do Peso Bruto
		aColIte[17,1] := (aColIte[4,1] * HB1->HB1_PBRUTO)
		SetText(aObjIte[1,14],aColIte[17,1])
	Endif
	
	aColIte[18,1] := aColIte[4,1]

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVBtSimil บAutor  ณRodrigo A. Godinho  บ Data ณ  07/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao do action do botao Similar da tela de itens do pedidoบฑฑ
ฑฑบ          ณde venda.                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PVBtSimil(cPesq,aColIte,aObjIte,aCabPed,cManTes,cManPrc,aPrdPrefix,cBloqPrc)

Local cProdAnt := aColIte[1,1]

PVSimilar(cPesq,aColIte,aObjIte,aCabPed,cManTes,cManPrc,aPrdPrefix)
If cProdAnt <> aColIte[1,1]
	//limpa desconto
	aColIte[7,1] := 0
	SetText(aObjIte[1,9], aColIte[7,1] )
Endif

Return nil
