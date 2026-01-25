#INCLUDE "FDNF008.ch"
//Carrega produtos conforme grupo selecionado
Function NFGrupo(aGrupo,nGrupo,oBrwProd,nTop,lFoco,aIteNot,lcodigo)

//Local cGrupo := Substr(aGrupo[nGrupo],1,4)
Local nLinhasMax := GridRows(oBrwProd)
Local i := 0
Local nOrder := if(lCodigo,1,2)

cUltGrupo := Substr(aGrupo[nGrupo],1,4)

If cUltGrupo == "Todo"
	cUltGrupo := ""
	HB1->(dbSetOrder(nOrder))
	HB1->(dbGoTop())
Else
	HB1->(dbSetOrder(3))
	HB1->(dbSeek(RetFilial("HB1")+cUltGrupo))
Endif

if !HB1->(Eof())
	nTop := HB1->(Recno())
	NFListarProd(cUltGrupo,nLinhasMax,oBrwProd,nTop,aIteNot,lFoco)
endif                      

ClearStatus()

Return nil

//Paginar arquivo p/ cima
Function NFSobe(aGrupo,nGrupo,oBrwProd,nTop,aIteNot,lCodigo)
Local nLinhasMax := GridRows(oBrwProd)
Local nOrder := if(lCodigo,1,2)

If Empty(cUltGrupo)
	HB1->( dbSetOrder(nOrder) )
Else
	HB1->( dbSetOrder(3) )
Endif

HB1->(dbGoTo(nTop))        
HB1->(dbSkip(-nPagProd))

if ( !HB1->(Bof()) .And. ( Empty(cUltGrupo) .Or. HB1->HB1_GRUPO == cUltGrupo) )
	nTop := HB1->(Recno())
else
	If Empty(cUltGrupo)
		HB1->( dbSetOrder(nOrder) )
		HB1->( dbGotop() ) //posiciona no 1o. produto
	Else 
		HB1->( dbSetOrder(3) )
		HB1->( dbSeek(RetFilial("HB1")+cUltGrupo) ) //posiciona no 1o. produto do grupo
	Endif
	nTop := HB1->(Recno())
endif
//Listar produtos
NFListarProd(cUltGrupo,nLinhasMax,oBrwProd,nTop,aIteNot,.t.)

Return nil
          

//Paginar arquivo p/ baixo
Function NFDesce(aGrupo,nGrupo,oBrwProd,nTop,aIteNot)
//Local cGrupo := Substr(aGrupo[nGrupo],1,4)
Local nLinhasMax := GridRows(oBrwProd)

If Empty(cUltGrupo)
	HB1->( dbSetOrder(2) )
Else
	HB1->( dbSetOrder(3) )
Endif

HB1->(dbGoTo(nTop))
HB1->(dbSkip(nLinhasMax))
if ( !HB1->(Eof()) .And. ( Empty(cUltGrupo) .Or. HB1->HB1_GRUPO == cUltGrupo) )
   nTop := HB1->(Recno())
else
   return nil
endif
//Listar produtos
NFListarProd(cUltGrupo,nLinhasMax,oBrwProd,nTop,aIteNot,.t.)

Return nil

// Atualiza lista de produtos
Function NFListarProd(cUltGrupo,nLinhasMax,oBrwProd,nTop,aIteNot,lfoco)
Local i, nPos := 0                                             

HB1->(dbGoTo(nTop))

aSize(aProduto,0)
//For i := 1 to nLinhasMax
For i := 1 to nPagProd
   if !HB1->(Eof()) .And. ((HB1->HB1_GRUPO == cUltGrupo) .Or. Empty(cUltGrupo))
      nPos := ScanArray(aIteNot,HB1->HB1_COD,,,3)
	  If nPos > 0 //Carrega dados do item localizado no aIteNot
		  AADD(aProduto,{HB1->HB1_DESC,HB1->HB1_COD,aIteNot[nPos,6],aIteNot[nPos,23],aIteNot[nPos,13],aIteNot[nPos,10],aIteNot[nPos,9],aIteNot[nPos,8]})	
	  Else
		  AADD(aProduto,{HB1->HB1_DESC,HB1->HB1_COD,0,0,0,0,0,0})
	  Endif
   else
	  break
   endif
   HB1->(dbSkip())
Next             
SetArray(oBrwProd,aProduto)
GridSetRow(oBrwProd,1) //Selecionar 1o. item
If lFoco
	SetFocus(oBrwProd)
Endif
Return nil


//Prepara os arrays que serao usados nas telas do Pedido
Function NFMontaArrays(aCmpPag,aIndPag,aCmpTab,aIndTab,aCmpTra,aIndTra,aCmpFpg,aIndFpg,aCmpTes,aIndTes)

//Carregar lista de grupos
aSize(aGrupo,0)
AADD(aGrupo,STR0001) //1o. item (padrao) //"Todos"
HBM->(dbGoTop())
While !HBM->(Eof())
   AADD(aGrupo,HBM->HBM_GRUPO + " - " + AllTrim(HBM->HBM_DESC))
   HBM->(dbSkip())
Enddo                 

// Consulta Condicao de Pagamento 
Aadd(aCmpPag,{STR0002,HE4->(FieldPos("E4_COD")),30}) //"Código"
Aadd(aCmpPag,{STR0003,HE4->(FieldPos("E4_DESCRI")),70}) //"Descrição"
Aadd(aIndPag,{STR0002,1}) //"Código"

//Consulta Tabela de Preco
Aadd(aCmpTab,{STR0002,HTC->(FieldPos("TC_TAB")),30}) //"Código"
Aadd(aCmpTab,{STR0003,HTC->(FieldPos("TC_DESCRI")),100}) //"Descrição"
Aadd(aIndTab,{STR0002,1}) //"Código"

//Consulta Transportadora
Aadd(aCmpTra,{STR0002,HA4->(FieldPos("A4_COD")),40}) //"Código"
Aadd(aCmpTra,{STR0004,HA4->(FieldPos("A4_NOME")),100}) //"Nome"
Aadd(aIndTra,{STR0002,1}) //"Código"

//Consulta Forma de Pagamento
Aadd(aCmpFpg,{STR0002,HTP->(FieldPos("X5_CHAVE")),20}) //"Código"
Aadd(aCmpFpg,{STR0005,HTP->(FieldPos("X5_DESCRI")),60}) //"Descricao"
Aadd(aIndFpg,{STR0002,1}) //"Código"

//Consulta TES
Aadd(aCmpTes,{STR0002,HF4->(FieldPos("F4_CODIGO")),30}) //"Código"
Aadd(aCmpTes,{STR0003,HF4->(FieldPos("F4_TEXTO")),100}) //"Descrição"
Aadd(aIndTes,{STR0002,1}) //"Código"

Return nil
          

//Montagem do Folder: Detalhes do Produto
Function NFFldDetalhe(oBrwProd,aItePed,nTop,oDet,aControls,oCtrl,cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax,aPrdPrefix)

//campos de detalhe
@ 50,2 TO 140,158 CAPTION STR0006 OF oDet //"Detalhes"
@ 55,5 SAY oCtrl PROMPT STR0007 OF oDet //"Código:"
AADD(aControls[1],oCtrl) // 1 - Label Codigo
@ 55,35 GET oCtrl VAR cCod READONLY NO UNDERLINE SIZE 85,15 OF oDet
AADD(aControls[1],oCtrl) // 2 - Get Codigo
@ 70,5 GET oCtrl VAR cDescD MULTILINE READONLY NO UNDERLINE SIZE 145,25 OF oDet
AADD(aControls[1],oCtrl) // 3 - Get Descricao (2 linhas)
@ 95,5 SAY oCtrl PROMPT STR0008 OF oDet //"Unidade:"
AADD(aControls[1],oCtrl) // 4 - Label Unidade Med.
@ 95,45 GET oCtrl VAR cUN READONLY NO UNDERLINE SIZE 20,10 OF oDet
AADD(aControls[1],oCtrl) // 5 - Get Unidade Med.
@ 95,75 SAY oCtrl PROMPT STR0009 OF oDet //"Qt.Embal:"
AADD(aControls[1],oCtrl) // 6 - Label Qtd. Embalagem
@ 95,120 GET oCtrl VAR nQTD READONLY NO UNDERLINE SIZE 35,10 OF oDet
AADD(aControls[1],oCtrl) // 7 - Get Qtd. Embalagem
@ 105,5 SAY oCtrl PROMPT STR0010 OF oDet //"Entrega:"
AADD(aControls[1],oCtrl) // 8 - Label Entrega
@ 105,45 GET oCtrl VAR nEnt READONLY NO UNDERLINE SIZE 25,10 OF oDet
AADD(aControls[1],oCtrl) // 9 - Get Entrega
@ 115,5 SAY oCtrl PROMPT STR0011 OF oDet //"ICMS:"
AADD(aControls[1],oCtrl) // 10 - Label ICMS
@ 115,45 GET oCtrl VAR nICM READONLY NO UNDERLINE SIZE 25,10 OF oDet
AADD(aControls[1],oCtrl) // 11 - Get ICMS
@ 115,75 SAY oCtrl PROMPT STR0012 OF oDet //"IPI:"
AADD(aControls[1],oCtrl) // 12- Label IPI
@ 115,120 GET oCtrl VAR nIPI READONLY NO UNDERLINE SIZE 35,10 OF oDet
AADD(aControls[1],oCtrl) // 13 - Get IPI
@ 125,5 SAY oCtrl PROMPT STR0013 OF oDet //"Estoque:"
AADD(aControls[1],oCtrl) // 14 - Label Estoque
@ 125,45 GET oCtrl VAR cEst READONLY NO UNDERLINE SIZE 110,10 OF oDet
AADD(aControls[1],oCtrl) // 15 - Get Estoque
//Desc. Max.
@ 105,75 SAY oCtrl PROMPT STR0014 OF oDet //"Desc.Max:"
AADD(aControls[1],oCtrl) // 16 - Label Descto. Maximo
@ 105,120 GET oCtrl VAR nDescMax READONLY NO UNDERLINE SIZE 35,10 OF oDet
AADD(aControls[1],oCtrl) // 17 - Get Descto. Maximo

Return nil

          
//Montagem do Folder: Precos de tabela do Produto
Function NFFldPrecos(oPrecos,oCtrl,aControls,oBrw,aPrecos,oCol,nPrc)

@ 20,05 SAY oCtrl PROMPT STR0015 OF oPrecos //"Preço1: "
AADD(aControls[2],oCtrl) // 1 - Label Preco1
@ 20,45 GET oCtrl VAR nPrc READONLY NO UNDERLINE SIZE 40,12 OF oPrecos
AADD(aControls[2],oCtrl) // 2 - Get Preco1
@ 35,5 BROWSE oBrw SIZE 145,90 OF oPrecos
SET BROWSE oBrw ARRAY aPrecos
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0016 WIDTH 50 //"Tabela"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0017 WIDTH 50 PICTURE "@E 999,999.99" ALIGN RIGHT //"Valor"
AADD(aControls[2],oBrw) // 3 - Browse Precos Tabela

Return nil

//Atualizar dados no folder de Precos
Function NFSetPrecos(aObj,aControls,aPrecos)
Local nLin := GridRow(aObj[3,1])
Local cCod := ""

If len(aProduto) == 0 .Or. nLin == 0
	return nil
Endif

cCod := aProduto[nLin,2]

HB1->(dbSetOrder(1))
HB1->(dbSeek(RetFilial("HB1")+cCod))
SetText(aControls[2,2],HB1->B1_PRV1)       

aSize(aPrecos,0)
HPR->(dbSeek(RetFilial("HPR")+cCod))
While (!HPR->(Eof()) .And. HPR->HPR_FILIAL == RetFilial("HPR") .and. HPR->PR_PROD == cCod)
  AADD(aPrecos,{ HPR->HPR_TAB, HPR->HPR_UNI } )
  HPR->(dbSkip())
end
SetArray(aControls[2,3],aPrecos)

Return nil
          

//Atualizar dados do folder Detalhes
Function NFSetDetalhes(oBrwProd,aControls,cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax)
Local nLin := GridRow(oBrwProd)
Local cNewCod := ""

If len(aProduto) == 0 .Or. nLin == 0
	return nil
Endif

cNewCod := aProduto[nLin,2]
If cNewCod <> cCod
	cCod := cNewCod
	HB1->(dbSetOrder(1))
	HB1->(dbSeek(RetFilial("HB1")+cCod))
	
	SetText(aControls[1,3],AllTrim(HB1->HB1_DESC))  //Descricao
	SetText(aControls[1,2],cCod)					//Codigo
	SetText(aControls[1,5],HB1->HB1_UM)				//Unidade Medida
	SetText(aControls[1,7],HB1->HB1_QE)             //Qtde Estoque
	SetText(aControls[1,9],HB1->HB1_PE)				//Prazo Entrega
	SetText(aControls[1,11],HB1->HB1_PICM)			//Porcent. ICMS
	SetText(aControls[1,13],HB1->HB1_IPI)           //Porcent. IPI
	SetText(aControls[1,15],HB1->HB1_EST)			//Estoque
	If HB1->(FieldPos("B1_DESCMAX")) <> 0
		nDescMax := HB1->B1_DESCMAX
	Else
		nDescMax := 100
	Endif
	SetText(aControls[1,17],str(nDescMax,3,2)+"%") //Desconto Maximo
Endif
SetFocus(aControls[3,1])
Return nil


//Funcao para pesquisa de produto (codigo ou descricao)
Function NFFind(cPesq,lCodigo,aGrupo,nGrupo,aPrdPrefix,oBrwProd,aIteNot,nTop)
Local nOrder := if(lCodigo,1,2)
Local cPrefixo := ""

cPesq := Upper(cPesq)    
If !Empty(aPrdPrefix[1,1]) .And. nOrder = 1
	If Empty(aPrdPrefix[1,3])
		cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
	Else
		cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(cPesq))		
	EndIf
	If At(cPrefixo, cPesq) = 0
		cPesq := cPrefixo + cPesq
	EndIf
EndIf

dbSelectArea("HB1")
HB1->(dbSetOrder(nOrder)) 
HB1->(dbSeek(RetFilial("HB1")+cPesq))
If HB1->(Found()) 
	If nOrder == 1
		HB1->H(dbSetOrder(2)) 
		HB1->H(dbSeek(RetFilial("HB1")+HB1->HB1_DESC))
	Endif
	nTop := HB1->(Recno())
	//Listar produtos a partir do prod. pesquisado
	cUltGrupo:=""
	NFListarProd(cUltGrupo,GridRows(oBrwProd),oBrwProd,@nTop,aIteNot,.T.)
Else
    MsgStop(STR0018,STR0019) //"Produto não localizado!"###"Pesquisa Produto"
Endif
Return nil
          

Function NFOrderFind(aControls,lCodigo,lDesc,isCod)
if isCod                                     
  SetText(aControls[3,3],.F.)
  lDesc:= .F.
  if !lCodigo
  	SetText(aControls[3,2],.T.)
  	lCodigo := .T.
  Endif
else
  SetText(aControls[3,2],.F.)
  lCodigo:= .F.
  if !lDesc
  	SetText(aControls[3,3],.T.)
  	lDesc := .T.
  Endif
endif
SetFocus(aControls[3,1]) //Get de pesquisa
Return nil