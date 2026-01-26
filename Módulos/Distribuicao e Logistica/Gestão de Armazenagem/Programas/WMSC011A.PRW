#INCLUDE "WMSC011A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} WMSC011A
Rastreabilidade
@author  Alexsander Burigo Corrêa
@version P11
@Since   16/05/12
/*/
//----------------------------------------------------------
Function WMSC011A(nNUMSEQ)
Local aCoors := FWGetDialogSize (oMainWnd )
Local oLayerRas
Local oPnlRas

Local aColsSX3   := {}

Local cPict  := PesqPict('SB2','B2_QATU')

Private aFieldRAS:= {}
Private dUltFech := GetUltFech()
Private dDataIni := dUltFech + 1
Private dDataFim := dDataBase

Private oBrwRas

	//Cria tabela temporária
	CriaTemp()

	//Atualiza dados Kardex
	SetRastro(nNUMSEQ)

	//Trata a altura da janela de acordo com a resolução
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel //Rastreabilidade

	// Cria conteiner para os browses

	oLayerRas := FWLayer():New()
	oLayerRas:Init(oDlgPrinc, .F., .T.)

	oLayerRas:AddLine( 'RASTRO', 6, .F.)
	oPnlCapa := oLayerRas:GetLinePanel ('RASTRO')

	TSay():New( 5,5,{|| buscarSX3('B1_COD',,aColsSX3)},oPnlCapa,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) //Produto
	oProduto  := TGet():New( 3,30,{|| SB2->B2_COD}, oPnlCapa, 50, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cProduto',,,,.T.)

	TSay():New( 5,90,{||buscarSX3('B1_DESC',,aColsSX3)},oPnlCapa,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) //Saldo
	oDescProd := TGet():New( 3,125,{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'SB1->B1_DESC')}, oPnlCapa, 200, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cDescProd',,,,.T.)

	// Define painel Detail
	oLayerRas:AddLine( 'RAS', 94, .F.)
	oPnlRas := oLayerRas:GetLinePanel ('RAS')

	// Monta browse
	aColsRas:= {;
	           { buscarSX3('D2_EMISSAO',,aColsSX3)       ,{|| ('WMSRAS')->KR_DATA}   ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_DOC',,aColsSX3)           ,{|| ('WMSRAS')->KR_DOCTO}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_SERIE',,aColsSX3)         ,{|| ('WMSRAS')->KR_SERIE}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_CLIENTE',,aColsSX3)       ,{|| ('WMSRAS')->KR_CLIENTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_LOJA',,aColsSX3)          ,{|| ('WMSRAS')->KR_LOJA}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_TES',,aColsSX3)           ,{|| ('WMSRAS')->KR_TES}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_CF',,aColsSX3)            ,{|| ('WMSRAS')->KR_CF}     ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_LOTECTL',,aColsSX3)       ,{|| ('WMSRAS')->KR_LOTE}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_NUMLOTE',,aColsSX3)       ,{|| ('WMSRAS')->KR_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_LOCALIZ',,aColsSX3)       ,{|| ('WMSRAS')->KR_LOCALIZ},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_NUMSERI',,aColsSX3)       ,{|| ('WMSRAS')->KR_NUMSERI},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_QUANT',,aColsSX3)         ,{|| ('WMSRAS')->KR_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_QTSEGUM',,aColsSX3)       ,{|| ('WMSRAS')->KR_QTSEGUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('D2_NUMSEQ',,aColsSX3)        ,{|| ('WMSRAS')->KR_NUMSEQ} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,};
	           }

	oBrwRas := FWMBrowse():New()
	oBrwRas:SetAlias('WMSRAS')
	oBrwRas:SetOwner(oPnlRas)
	oBrwRas:SetFields(aColsRas)
	oBrwRas:SetMenuDef('')
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0002) //NF. Entrada
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0003) //NF. Saída
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0004) //Entrada
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0005) //Saída
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0006) //Transferência
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'À ENDEREÇAR'"  ,'WHITE' ,STR0007) //À Endereçar
	oBrwRas:SetFixedBrowse(.T.)
	oBrwRas:SetAmbiente(.F.)
	oBrwRas:SetWalkThru(.F.)
	oBrwRas:SetDescription(STR0001)//Rastreabilidade
	oBrwRas:DisableDetails()
	oBrwRas:SetProfileID('1')
	oBrwRas:Activate()


	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center

	delTabTmp('WMSRAS')
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} GetUltFech
Busca Data Ultimo Fechamento

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs		Busca Data Ultimo Fechamento

/*/
//----------------------------------------------------------
Static Function GetUltFech()
Local cAliSB9  := GetNextAlias()
Local cQuery   := ""
Local dUltFech := CtoD("  /  /  ")

	cQuery := "SELECT MAX(B9_DATA) AS B9_DATA"
	cQuery +=  " FROM "+RetSqlName('SB9')+" SB9"
	cQuery += " WHERE SB9.B9_FILIAL  = '"+xFilial("SB9")+"'"
	cQuery +=   " AND SB9.B9_COD     = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SB9.B9_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SB9.B9_DATA    < '"+DtoS(dDatabase)+"'"
	cQuery +=   " AND SB9.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliSB9,.F.,.T.)
	TcSetField(cAliSB9,'B9_DATA','D')
	If !(cAliSB9)->(Eof())
		dUltFech := (cAliSB9)->B9_DATA
	EndIf
	(cAliSB9)->( DbCloseArea())

Return dUltFech

//----------------------------------------------------------
/*/{Protheus.doc} CriaTemp
Cria tabelas temporárias

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs		Cria tabelas temporárias

/*/
//----------------------------------------------------------
Static Function CriaTemp(nNUMSEQ)
	//---------------------------------------
	// Cria tabela temporária Rastreabilidade
	//---------------------------------------
	AAdd(aFieldRAS,{'KR_ORDEM' ,'C',13,0})
	AAdd(aFieldRAS,{'KR_TABELA','C',30,0})
	AAdd(aFieldRAS,{'KR_ORIGEM','C',13,0})

	buscarSX3('D2_EMISSAO',,aColsSX3)
	AAdd(aFieldRAS,{'KR_DATA','D',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_DOC',,aColsSX3)
	AAdd(aFieldRAS,{'KR_DOCTO','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_SERIE',,aColsSX3)
	AAdd(aFieldRAS,{'KR_SERIE','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_CLIENTE',,aColsSX3)
	AAdd(aFieldRAS,{'KR_CLIENTE','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_LOJA',,aColsSX3)
	AAdd(aFieldRAS,{'KR_LOJA','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_TES',,aColsSX3)
	AAdd(aFieldRAS,{'KR_TES','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_CF',,aColsSX3)
	AAdd(aFieldRAS,{'KR_CF','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_LOTECTL',,aColsSX3)
	AAdd(aFieldRAS,{'KR_LOTE','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_NUMLOTE',,aColsSX3)
	AAdd(aFieldRAS,{'KR_NUMLOTE','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_LOCALIZ',,aColsSX3)
	AAdd(aFieldRAS,{'KR_LOCALIZ','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_NUMSERI',,aColsSX3)
	AAdd(aFieldRAS,{'KR_NUMSERI','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_QUANT',,aColsSX3)
	AAdd(aFieldRAS,{'KR_QUANT','N',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_QTSEGUM',,aColsSX3)
	AAdd(aFieldRAS,{'KR_QTSEGUM','N',aColsSX3[3],aColsSX3[4]})

	buscarSX3('D2_NUMSEQ',,aColsSX3)
	AAdd(aFieldRAS,{'KR_NUMSEQ','C',aColsSX3[3],aColsSX3[4]})

	// Cria tabelas temporárias
	criaTabTmp(aFieldRAS,{'KR_NUMSEQ+KR_ORDEM+KR_TES'},'WMSRAS')
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} SetRastro
Rastreabilidade

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs		Rastreabilidade

/*/
//----------------------------------------------------------
Static Function SetRastro(nNUMSEQ)
Local cAliasSD1 := GetNextAlias()
Local cAliasSD2 := GetNextAlias()
Local cAliasSD3 := GetNextAlias()
Local cAliasSD5 := GetNextAlias()
Local cAliasSDB := GetNextAlias()
Local cAliasSDA := GetNextAlias()
Local cQuery    := ""
Local aRastrear := {}

	// Movimento do SD1
	cQuery := "SELECT D1_DOC,"
	cQuery +=       " D1_SERIE,"
	cQuery +=       " D1_FORNECE,"
	cQuery +=       " D1_LOJA,"
	cQuery +=       " D1_TIPO,"
	cQuery +=       " D1_ORIGLAN,"
	cQuery +=       " D1_DTDIGIT,"
	cQuery +=       " D1_TES,"
	cQuery +=       " D1_CF,"
	cQuery +=       " D1_QUANT,"
	cQuery +=       " D1_QTSEGUM,"
	cQuery +=       " D1_NUMSEQ,"
	cQuery +=       " D1_LOTECTL,"
	cQuery +=       " D1_NUMLOTE"
	cQuery +=  " FROM "+RetSqlName("SD1")+" SD1,"
	cQuery +=           RetSqlName("SF4")+" SF4"
	cQuery += " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
	cQuery +=   " AND SD1.D1_COD     = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD1.D1_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD1.D1_NUMSEQ  = '"+nNUMSEQ+"'"
	cQuery +=   " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF4.F4_FILIAL  = '"+xFilial("SF4")+"'"
	cQuery +=   " AND SF4.F4_CODIGO  = D1_TES"
	cQuery +=   " AND SF4.F4_ESTOQUE = 'S'"
	cQuery +=   " AND SF4.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D1_DTDIGIT,D1_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD1,.F.,.T.)
	TcSetField(cAliasSD1,'D1_DTDIGIT','D')

	While !(cAliasSD1)->( Eof() )
		AAdd(aRastrear,{'A',X2NOME(),'NF ENTRADA',(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_TES,(cAliasSD1)->D1_CF,(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_NUMLOTE,"","",(cAliasSD1)->D1_QUANT,(cAliasSD1)->D1_QTSEGUM,(cAliasSD1)->D1_NUMSEQ})
		(cAliasSD1)->( dbSkip() )
	Enddo
	(cAliasSD1)->( DBCloseArea())

	cQuery := "SELECT D2_DOC,"
	cQuery +=       " D2_SERIE,"
	cQuery +=       " D2_CLIENTE,"
	cQuery +=       " D2_LOJA,"
	cQuery +=       " D2_ORIGLAN,"
	cQuery +=       " D2_EMISSAO,"
	cQuery +=       " D2_TES,"
	cQuery +=       " D2_CF,"
	cQuery +=       " D2_QUANT,"
	cQuery +=       " D2_QTSEGUM,"
	cQuery +=       " D2_NUMSEQ,"
	cQuery +=       " D2_LOTECTL,"
	cQuery +=       " D2_NUMLOTE,"
	cQuery +=       " D2_LOCALIZ,"
	cQuery +=       " D2_NUMSERI"
	cQuery +=  " FROM "+RetSqlName("SD2")+" SD2,"
	cQuery +=           RetSqlName("SF4")+" SF4"
	cQuery += " WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"
	cQuery +=   " AND SD2.D2_COD     = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD2.D2_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD2.D2_NUMSEQ  = '"+nNUMSEQ+"'"
	cQuery +=   " AND SD2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF4.F4_FILIAL  = '"+xFilial("SF4")+"'"
	cQuery +=   " AND SF4.F4_CODIGO  = D2_TES"
	cQuery +=   " AND SF4.F4_ESTOQUE = 'S'"
	cQuery +=   " AND SF4.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D2_EMISSAO,D2_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD2,.F.,.T.)
	TcSetField(cAliasSD2,'D2_EMISSAO','D')

	While !(cAliasSD2)->( Eof() )
		AAdd(aRastrear,{'B',X2NOME(),'NF SAIDA',(cAliasSD2)->D2_EMISSAO,(cAliasSD2)->D2_DOC,(cAliasSD2)->D2_SERIE,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_TES,(cAliasSD2)->D2_CF,(cAliasSD2)->D2_LOTECTL,(cAliasSD2)->D2_NUMLOTE,(cAliasSD2)->D2_LOCALIZ,(cAliasSD2)->D2_NUMSERI,(cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_QTSEGUM,(cAliasSD2)->D2_NUMSEQ})
		(cAliasSD2)->( dbSkip() )
	Enddo
	(cAliasSD2)->( DBCloseArea())

	// Movimento do SD3
	cQuery := "SELECT D3_EMISSAO,"
	cQuery +=       " D3_TM,"
	cQuery +=       " D3_CF,"
	cQuery +=       " D3_DOC,"
	cQuery +=       " D3_QUANT,"
	cQuery +=       " D3_QTSEGUM,"
	cQuery +=       " D3_NUMSEQ,"
	cQuery +=       " D3_LOTECTL,"
	cQuery +=       " D3_NUMLOTE,"
	cQuery +=       " D3_LOCALIZ,"
	cQuery +=       " D3_NUMSERI"
	cQuery +=  " FROM "+RetSqlName("SD3")+" SD3"
	cQuery += " WHERE SD3.D3_FILIAL   = '"+xFilial("SD3")+"'"
	cQuery +=   " AND SD3.D3_COD      = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD3.D3_LOCAL    = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD3.D3_NUMSEQ   = '"+nNUMSEQ+"'"
	cQuery +=   " AND SD3.D3_EMISSAO >= '"+DtoS(dDataIni)+"'"
	cQuery +=   " AND SD3.D3_EMISSAO <= '"+DtoS(dDataFim)+"'"
	cQuery +=   " AND SD3.D3_ESTORNO  = ' '"
	cQuery +=   " AND SD3.D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY D3_EMISSAO,D3_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)
	TcSetField(cAliasSD3,'D3_EMISSAO','D')

	While !(cAliasSD3)->( Eof() )
		AAdd(aRastrear,{'C',X2NOME(),IIF((cAliasSD3)->D3_TM$'499/999','TRANSFERENCIA',IIF((cAliasSD3)->D3_TM<='500','ENTRADA','SAIDA')),(cAliasSD3)->D3_EMISSAO,(cAliasSD3)->D3_DOC,"","","",(cAliasSD3)->D3_TM,(cAliasSD3)->D3_CF,(cAliasSD3)->D3_LOTECTL,(cAliasSD3)->D3_NUMLOTE,(cAliasSD3)->D3_LOCALIZ,(cAliasSD3)->D3_NUMSERI,(cAliasSD3)->D3_QUANT,(cAliasSD3)->D3_QTSEGUM,(cAliasSD3)->D3_NUMSEQ})
		(cAliasSD3)->( dbSkip() )
	Enddo
	(cAliasSD3)->( DBCloseArea())

	// Movimento do SD5
	cQuery := "SELECT D5_DATA,"
	cQuery +=       " D5_ORIGLAN,"
	cQuery +=       " D5_DOC,"
	cQuery +=       " D5_SERIE,"
	cQuery +=       " D5_CLIFOR,"
	cQuery +=       " D5_LOJA,"
	cQuery +=       " D5_LOTECTL,"
	cQuery +=       " D5_NUMLOTE,"
	cQuery +=       " D5_DTVALID,"
	cQuery +=       " D5_QUANT,"
	cQuery +=       " D5_QTSEGUM,"
	cQuery +=       " D5_NUMSEQ"
	cQuery +=  " FROM "+RetSqlName("SD5")+" SD5"
	cQuery += " WHERE SD5.D5_FILIAL  = '"+xFilial("SD5")+"'"
	cQuery +=   " AND SD5.D5_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD5.D5_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD5.D5_NUMSEQ  = '"+nNUMSEQ+"'"
	cQuery +=   " AND SD5.D5_ESTORNO = ' '"
	cQuery +=   " AND SD5.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D5_DATA,D5_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD5,.F.,.T.)
	TcSetField(cAliasSD5,'D5_DATA'   ,'D')
	TcSetField(cAliasSD5,'D5_DTVALID','D')

	While !(cAliasSD5)->( Eof() )
		AAdd(aRastrear,{'D',X2NOME(),IIF((cAliasSD5)->D5_ORIGLAN$'499/999','TRANSFERENCIA',IIF((cAliasSD5)->D5_ORIGLAN<='500','ENTRADA','SAIDA')),(cAliasSD5)->D5_DATA,(cAliasSD5)->D5_DOC,(cAliasSD5)->D5_SERIE,(cAliasSD5)->D5_CLIFOR,(cAliasSD5)->D5_LOJA,(cAliasSD5)->D5_ORIGLAN,"",(cAliasSD5)->D5_LOTECTL,(cAliasSD5)->D5_NUMLOTE,"","",(cAliasSD5)->D5_QUANT,(cAliasSD5)->D5_QTSEGUM,(cAliasSD5)->D5_NUMSEQ})
		(cAliasSD5)->( dbSkip() )
	Enddo
	(cAliasSD5)-> ( dbCloseArea() )

	// Movimento do SDB
	cQuery := "SELECT DB_DATA,"
	cQuery +=       " DB_TM,"
	cQuery +=       " DB_DOC,"
	cQuery +=       " DB_SERIE,"
	cQuery +=       " DB_CLIFOR,"
	cQuery +=       " DB_LOJA,"
	cQuery +=       " DB_LOCALIZ,"
	cQuery +=       " DB_NUMSERI,"
	cQuery +=       " DB_LOTECTL,"
	cQuery +=       " DB_NUMLOTE,"
	cQuery +=       " DB_QUANT,"
	cQuery +=       " DB_QTSEGUM,"
	cQuery +=       " DB_NUMSEQ"
	cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
	cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND SDB.DB_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SDB.DB_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SDB.DB_NUMSEQ  = '"+nNUMSEQ+"'"
	cQuery +=   " AND SDB.DB_ATUEST  = 'S'"
	cQuery +=   " AND SDB.DB_ESTORNO = ' '"
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY DB_DATA,DB_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)
	TcSetField(cAliasSDB,'DB_DATA','D')

	While !(cAliasSDB)->( Eof() )
		AAdd(aRastrear,{'E',X2NOME(),IIF((cAliasSDB)->DB_TM $ '499/999','TRANSFERENCIA',IIF((cAliasSDB)->DB_TM <= '500','ENTRADA','SAIDA')),(cAliasSDB)->DB_DATA,(cAliasSDB)->DB_DOC,(cAliasSDB)->DB_SERIE,(cAliasSDB)->DB_CLIFOR,(cAliasSDB)->DB_LOJA,(cAliasSDB)->DB_TM,"",(cAliasSDB)->DB_LOTECTL,(cAliasSDB)->DB_NUMLOTE,(cAliasSDB)->DB_LOCALIZ,(cAliasSDB)->DB_NUMSERI,(cAliasSDB)->DB_QUANT,(cAliasSDB)->DB_QTSEGUM,(cAliasSDB)->DB_NUMSEQ})
		(cAliasSDB)->( dbSkip() )
	Enddo
	(cAliasSDB)->( DBCloseArea() )

	//Grava SDA
	cQuery := "SELECT DA_DATA,"
	cQuery +=       " DA_DOC,"
	cQuery +=       " DA_SERIE,"
	cQuery +=       " DA_CLIFOR,"
	cQuery +=       " DA_LOJA,"
	cQuery +=       " DA_ORIGEM,"
	cQuery +=       " DA_LOTECTL,"
	cQuery +=       " DA_NUMLOTE,"
	cQuery +=       " DA_SALDO,"
	cQuery +=       " DA_QTSEGUM,"
	cQuery +=       " DA_NUMSEQ"
	cQuery +=  " FROM "+RetSqlName("SDA")+" SDA"
	cQuery += " WHERE SDA.DA_FILIAL  = '"+xFilial("SDA")+"'"
	cQuery +=   " AND SDA.DA_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SDA.DA_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SDA.DA_PRODUTO = '"+nNUMSEQ+"'"
	cQuery +=   " AND SDA.DA_SALDO   > 0"
	cQuery +=   " AND SDA.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDA,.F.,.T.)
	TcSetField(cAliasSDA,'DA_DATA','D')
	
	While !(cAliasSDA)->( Eof() )
		AAdd(aRastrear,{'F',X2NOME(),'À ENDEREÇAR',(cAliasSDA)->DA_DATA,(cAliasSDA)->DA_DOC,(cAliasSDA)->DA_SERIE,(cAliasSDA)->DA_CLIFOR,(cAliasSDA)->DA_LOJA,(cAliasSDA)->DA_ORIGEM,"",(cAliasSDA)->DA_LOTECTL,(cAliasSDA)->DA_NUMLOTE,"","",(cAliasSDA)->DA_SALDO,(cAliasSDA)->DA_QTSEGUM,(cAliasSDA)->DA_NUMSEQ})
		(cAliasSDA)->( dbSkip() )
	Enddo
	(cAliasSDA)->(DbCloseArea())

	MntCargDad('WMSRAS',aRastrear, aFieldRAS)

Return .T.