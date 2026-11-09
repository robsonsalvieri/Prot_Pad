#INCLUDE 'WMSA200.CH' 
#INCLUDE 'FiveWin.ch'
//----------------------------------------------------------
/*/{Protheus.doc} WMSA200
Possibilita a visualizacao de todos os Enderecos onde o Produto se encontra
@author Fernando J. Siquini
@version 2.0
@since 11/01/2002
/*/
//----------------------------------------------------------
Function WMSA200()
Local aPosObj    := {}
Local aObjects   := {}
Local aSize      := {}
Local aInfo      := {}
Local aButtons   := {{STR0005, {|| GdSeek(oGetD, OemtoAnsi(STR0001))}, OemtoAnsi(STR0004)}} //pesquisa // Pesquisa Enderecos // Pesquisar
Local oDlgEsp

Private aRotina    := {{'', 'AxPesqui', 0, 1}, ;
	{'', 'AxVisual', 0, 2}, ;
	{'', 'AxInclui', 0, 3}, ;
	{'', 'AxAltera', 0, 4}, ;
	{'', 'AxDeleta', 0, 5}}
Private aHeader     := {}
Private aCols       := {}
Private cProduto    := CriaVar('B1_COD', .F.)
Private cDescProd   := CriaVar('B1_DESC', .F.)
Private oDlg
Private oGetD

	If !SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return DLGA200()
	EndIf
	
	// Montagem do AHEADER e ACOLS para GetDados
	FillGetDados(2,'D14',,,,,,,,,,.T.,,,)
	
	// Dimensoes Padrao
	aSize   := MsAdvSize()
	aAdd(aObjects, {100, 020, .T., .F.})
	aAdd(aObjects, {100, 100, .T., .T.})
	aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
	aPosObj := MsObjSize(aInfo, aObjects)
	
	DEFINE MSDIALOG oDlgEsp TITLE OemToAnsi(STR0002) FROM  aSize[7],0 To aSize[6],aSize[5] PIXEL // Localizacao dos Produtos
	@ aPosObj[1,1]+7, 009 SAY AllTrim(RetTitle('B1_COD')) SIZE 041, 09 OF oDlgEsp PIXEL
	@ aPosObj[1,1]+5, 033 MSGET cProduto Picture PesqPict('SB1', 'B1_COD') VALID WMA200Prod(cProduto) SIZE 050, 09 F3 'SB1' OF oDlgEsp PIXEL
	
	@ aPosObj[1,1]+7, 089 SAY AllTrim(RetTitle('B1_DESC')) SIZE 041, 09 OF oDlgEsp PIXEL
	@ aPosObj[1,1]+5, 118 MSGET cDescProd WHEN .F. SIZE 100, 09 OF oDlgEsp PIXEL
	
	oGetD := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],2,'AllWaysTrue','AllWaysTrue')
	
	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||WMA200Pesq(cProduto)},{||oDlgEsp:End()},,aButtons )
Return Nil
/*---------------------------------------------------------------------------
---WMA200Prod
---Valida o Produto, preenche a Descricao e atualiza o aCols
---Fernando J. Siquini 11/01/2002
---cProduto, Character, (Código do produto)
---------------------------------------------------------------------------*/
Static Function WMA200Prod(cProduto)
Local lRet := .T.
	cDescProd := ''
	SB1->(dbSetOrder(1))
	If	SB1->(lRet:=MsSeek(xFilial("SB1")+cProduto))
		cDescProd := SB1->B1_DESC
		WMA200Pesq(cProduto)
	EndIf
Return lRet
/*---------------------------------------------------------------------------
---WMA200Pesq
---Mostra uma tela enquanto monta a pesquisa nos Enderecos.
---Chama a funcao que realiza a pesquisa
---Fernando J. Siquini 11/01/2002
---cProduto, Character, (Código do produto)
---------------------------------------------------------------------------*/
Static Function WMA200Pesq(cProduto)

MsgRun(STR0003, '', {|| CursorWait(), _WMA200Pesq(cProduto), CursorArrow()}) //'Pesquisando...'

Return Nil
/*---------------------------------------------------------------------------
---_WMA200Pesq
---Realiza a pesquisa do produto no arquivo de Saldos por Endereço                                              
---Fernando J. Siquini 11/01/2002
---cProduto, Character, (Código do produto)
---------------------------------------------------------------------------*/
Static Function _WMA200Pesq(cProduto)
Local cSeekD14   := xFilial('D14')+cProduto
Local cWhile     := 'D14->D14_FILIAL+D14->D14_PRODUT'
Local cQuery     := ''
Local cAliasQry  := ''

	aHeader  := {}
	aCols    := {}
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT *" 
	cQuery +=   " FROM "+RetSqlName("D14")+" D14"
	cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14.D14_PRODUT = '"+cProduto+"'"
	cQuery +=    " AND D14.D_E_L_E_T_ = ' '"   
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	// Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/)
	FillGetDados(2,'D14',5,cSeekD14,{|| &cWhile },,,,,cQuery)
	oGetD:oBrowse:Refresh()
Return Nil