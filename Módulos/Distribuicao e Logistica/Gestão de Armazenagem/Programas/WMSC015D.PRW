#INCLUDE "WMSC015D.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
//-----------------------------------------------------------
/*/{Protheus.doc} WMSC015D
Rastreabilidade
@author  Alexsander Burigo Corrêa
@version P11
@Since 16/05/12
/*/ 
//----------------------------------------------------------- 
Function WMSC015D(nNumSeq,cLocal,cProduto,cPrdOri)
Local aCoors   := FWGetDialogSize (oMainWnd )
Local oLayerRas
Local oPnlRas
Local aColsSX3 := {}
	
Private aFieldRAS:= {}
Private dUltFech := GetUltFech(cLocal,cProduto)
Private dDataIni := dUltFech + 1
Private dDataFim := dDataBase

Private oBrwRas

	// Cria tabela temporária
	CriaTemp()

	// Atualiza dados Kardex
	SetRastro(nNumSeq,cLocal,cProduto,cPrdOri)

	// Trata a altura da janela de acordo com a resolução	
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel // Rastreabilidade

	// Cria conteiner para os browses
	oLayerRas := FWLayer():New()
	oLayerRas:Init(oDlgPrinc, .F., .T.)

	oLayerRas:AddLine( 'RASTRO', 6, .F.)
	oPnlCapa := oLayerRas:GetLinePanel ('RASTRO')

	TSay():New( 5,5,{|| buscarSX3('B1_COD',,aColsSX3)},oPnlCapa,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Produto
	oProduto  := TGet():New( 3,30,{|| cProduto}, oPnlCapa, 50, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cProduto',,,,.T.)

	TSay():New( 5,90,{||buscarSX3('B1_DESC',,aColsSX3)},oPnlCapa,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Saldo
	oDescProd := TGet():New( 3,125,{|| Posicione('SB1',1,xFilial('SB1')+cProduto,'SB1->B1_DESC')}, oPnlCapa, 200, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cDescProd',,,,.T.)
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
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0002) // NF. Entrada
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0003) // NF. Saída
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0004) // Entrada
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0005) // Saída
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0006) // Transferência
	oBrwRas:AddLegend("AllTrim(('WMSRAS')->KR_ORIGEM) == 'À ENDEREÇAR'"  ,'WHITE' ,STR0007) // À Endereçar
	oBrwRas:SetFixedBrowse(.T.)
	oBrwRas:SetAmbiente(.F.)
	oBrwRas:SetWalkThru(.F.)
	oBrwRas:SetDescription(STR0001)// Rastreabilidade
	oBrwRas:DisableDetails()
	oBrwRas:SetProfileID('1')
	oBrwRas:Activate()

	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center
	
	delTabTmp('WMSRAS')
Return Nil
//-----------------------------------------------------------
/*/{Protheus.doc} GetUltFech
Busca Data Ultimo Fechamento

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs Busca Data Ultimo Fechamento
/*/ 
//-----------------------------------------------------------
Static Function GetUltFech(cLocal,cProduto)
Local aAreaSB2    := SB2 -> (GetArea())
Local cAliasSB9  := GetNextAlias()
Local dUltFech
	BeginSql Alias cAliasSB9
		SELECT MAX(SB9.B9_DATA)B9_DATA
		FROM %Table:SB9% SB9
		WHERE SB9.B9_FILIAL = %xFilial:SB9%
		AND SB9.B9_LOCAL = %Exp:cLocal%
		AND SB9.B9_COD = %Exp:cProduto%
		AND SB9.B9_DATA < %Exp:DTOS(dDatabase)%
		AND SB9.%NotDel%
	EndSql
	TcSetField(cAliasSB9,'B9_DATA','D')
	dUltFech := (cAliasSB9)->B9_DATA
	(cAliasSB9)->( DBCloseArea())
	RestArea(aAreaSB2)
Return dUltFech
//-----------------------------------------------------------
/*/{Protheus.doc} CriaTemp
Cria tabelas temporárias

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs Cria tabelas temporárias
/*/ 
//-----------------------------------------------------------
Static Function CriaTemp()
	//----------------------------------------
	// Cria tabela temporária Rastreabilidade
	//---------------------------------------- 	
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
//-----------------------------------------------------------
/*/{Protheus.doc} SetRastro
Rastreabilidade

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs astreabilidade
/*/ 
//-----------------------------------------------------------
Static Function SetRastro(nNumSeq,cLocal,cProduto,cPrdOri)
Local aRastrear := {}
Local cAliasQry := GetNextAlias()
Local cColumnsA := ""
Local cColumnsB := ""
Local cColumnsC := ""
Local cColumnsD := ""
Local cColumnsE := ""


	cColumnsA := " 'A' AS TIPO, " 
	cColumnsA += "	'NF ENTRADA' AS OPERACAO, "
	cColumnsA += "	SD1.D1_DOC AS DOC, "
	cColumnsA += "	SD1.D1_SERIE AS SERIE, "
	cColumnsA += "	SD1.D1_FORNECE AS CLIFOR, "
	cColumnsA += "	SD1.D1_LOJA AS LOJA, "
	cColumnsA += "	SD1.D1_TIPO AS TPDOC, "
	cColumnsA += "	SD1.D1_ORIGLAN AS ORIGEM, "
	cColumnsA += "	SD1.D1_DTDIGIT AS DATLAN, "
	cColumnsA += "	SD1.D1_TES AS TES, "
	cColumnsA += "	SD1.D1_CF AS CF, "
	cColumnsA += "	SD1.D1_QUANT AS QUANT, "
	cColumnsA += "	SD1.D1_QTSEGUM AS QTSEGUM, "
	cColumnsA += "	SD1.D1_NUMSEQ AS NUMSEQ, "
	cColumnsA += "	SD1.D1_LOTECTL AS LOTECTL, "
	cColumnsA += "	SD1.D1_NUMLOTE AS NUMLOTE, "
	cColumnsA += "	' ' AS LOCALIZ, "
	cColumnsA += "	' ' AS NUMSERI, "
	cColumnsA += "	' ' AS DTVALID "
	cColumnsA := "%"+cColumnsA+"%"

	cColumnsB := " 'B' AS TIPO, "
	cColumnsB += " 'NF SAIDA' AS OPERACAO,  "
	cColumnsB += "	SD2.D2_DOC AS DOC, "
	cColumnsB += "	SD2.D2_SERIE AS SERIE, "
	cColumnsB += "	SD2.D2_CLIENTE AS CLIFOR, "
	cColumnsB += "	SD2.D2_LOJA AS LOJA, "
	cColumnsB += "	' ' AS TPDOC, "
	cColumnsB += "	SD2.D2_ORIGLAN AS ORIGEM, "
	cColumnsB += "	SD2.D2_EMISSAO AS DATLAN, "
	cColumnsB += "	SD2.D2_TES AS TES, "
	cColumnsB += "	SD2.D2_CF AS CF, "
	cColumnsB += "	SD2.D2_QUANT AS QUANT, "
	cColumnsB += "	SD2.D2_QTSEGUM AS QTSEGUM, "
	cColumnsB += "	SD2.D2_NUMSEQ AS NUMSEQ, "
	cColumnsB += "	SD2.D2_LOTECTL AS LOTECTL, "
	cColumnsB += "	SD2.D2_NUMLOTE AS NUMLOTE, "
	cColumnsB += "	SD2.D2_LOCALIZ AS LOCALIZ, "
	cColumnsB += "	SD2.D2_NUMSERI AS NUMSERI, "
	cColumnsB += "	' ' AS DTVALID "
	cColumnsB := "%"+cColumnsB+"%"

	cColumnsC := " 'C' AS TIPO, "
	cColumnsC += "	CASE WHEN SD3.D3_TM IN ('499','999') THEN 'TRANSFERENCIA' "
	cColumnsC += "		WHEN SD3.D3_TM NOT IN ('499','999') AND SD3.D3_TM <= '500' THEN 'ENTRADA' "
	cColumnsC += "		WHEN SD3.D3_TM NOT IN ('499','999') AND SD3.D3_TM > '500' THEN 'SAIDA' END OPERACAO, "
	cColumnsC += "	SD3.D3_DOC AS DOC, "
	cColumnsC += "	' ' AS SERIE, "
	cColumnsC += "	' ' AS CLIFOR, "
	cColumnsC += "	' ' AS LOJA, "
	cColumnsC += "	' ' AS TPDOC, "
	cColumnsC += "	' ' AS ORIGEM, "
	cColumnsC += "	SD3.D3_EMISSAO AS DATLAN, "
	cColumnsC += "	SD3.D3_TM AS TES, "
	cColumnsC += "	SD3.D3_CF AS CF, "
	cColumnsC += "	SD3.D3_QUANT AS QUANT, "
	cColumnsC += "	SD3.D3_QTSEGUM AS QTSEGUM, "
	cColumnsC += "	SD3.D3_NUMSEQ AS NUMSEQ, "
	cColumnsC += "	SD3.D3_LOTECTL AS LOTECTL, "
	cColumnsC += "	SD3.D3_NUMLOTE AS NUMLOTE, "
	cColumnsC += "	SD3.D3_LOCALIZ AS LOCALIZ, "
	cColumnsC += "	SD3.D3_NUMSERI AS NUMSERI, "
	cColumnsC += "	' ' AS DTVALID "
	cColumnsC := "%"+cColumnsC+"%"

	cColumnsD := " 'D' AS TIPO, " 
	cColumnsD += "	CASE WHEN SD5.D5_ORIGLAN IN ('499','999') THEN 'TRANSFERENCIA' "
	cColumnsD += "		WHEN SD5.D5_ORIGLAN NOT IN ('499','999') AND SD5.D5_ORIGLAN <= '500' THEN 'ENTRADA' "
	cColumnsD += "		WHEN SD5.D5_ORIGLAN NOT IN ('499','999') AND SD5.D5_ORIGLAN > '500' THEN 'SAIDA' END OPERACAO, "
	cColumnsD += "	SD5.D5_DOC AS DOC, "
	cColumnsD += "	SD5.D5_SERIE AS SERIE, "
	cColumnsD += "	SD5.D5_CLIFOR AS CLIFOR, "
	cColumnsD += "	SD5.D5_LOJA AS LOJA, "
	cColumnsD += "	' ' AS TPDOC, "
	cColumnsD += "	SD5.D5_ORIGLAN AS ORIGEM, "
	cColumnsD += "	SD5.D5_DATA AS DATLAN, "
	cColumnsD += "	' ' AS TES, "
	cColumnsD += "	' ' AS CF, "
	cColumnsD += "	SD5.D5_QUANT AS QUANT, "
	cColumnsD += "	SD5.D5_QTSEGUM AS QTSEGUM, "
	cColumnsD += "	SD5.D5_NUMSEQ AS NUMSEQ, "
	cColumnsD += "	SD5.D5_LOTECTL AS LOTECTL, "
	cColumnsD += "	SD5.D5_NUMLOTE AS NUMLOTE, "
	cColumnsD += "	' ' AS LOCALIZ, "
	cColumnsD += "	' ' AS NUMSERI, "
	cColumnsD += "	SD5.D5_DTVALID AS DTVALID "
	cColumnsD := "%"+cColumnsD+"%"

	cColumnsE := " 'E' AS TIPO, "
	cColumnsE += " CASE WHEN D13.D13_TM IN ('499','999') THEN 'TRANSFERENCIA' "
	cColumnsE += "		WHEN D13.D13_TM NOT IN ('499','999') AND D13.D13_TM <= '500' THEN 'ENTRADA' "
	cColumnsE += "		WHEN D13.D13_TM NOT IN ('499','999') AND D13.D13_TM > '500' THEN 'SAIDA' END OPERACAO, "
	cColumnsE += "	D13.D13_DOC AS DOC, "
	cColumnsE += "	D13.D13_SERIE AS SERIE, "
	cColumnsE += "	D13.D13_CLIFOR AS CLIFOR, "
	cColumnsE += "	D13.D13_LOJA AS LOJA, "
	cColumnsE += "	' ' AS TPDOC, "
	cColumnsE += "	' ' AS ORIGEM, "
	cColumnsE += "	D13.D13_DTESTO AS DATLAN, "
	cColumnsE += "	D13.D13_TM AS TES, "
	cColumnsE += "	' ' AS CF, "
	cColumnsE += "	D13.D13_QTDEST AS QUANT, "
	cColumnsE += "	D13.D13_QTDES2 AS QTSEGUM, "
	cColumnsE += "	D13.D13_NUMSEQ AS NUMSEQ, "
	cColumnsE += "	D13.D13_LOTECT AS LOTECT, "
	cColumnsE += "	D13.D13_NUMLOT AS NUMLOTE, "
	cColumnsE += "	D13.D13_ENDER AS LOCALIZ, "
	cColumnsE += "	D13.D13_NUMSER AS NUMSERI, "
	cColumnsE += "	' ' AS DTVALID "
	cColumnsE := "%"+cColumnsE+"%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cColumnsA% 
		FROM %Table:SD1% SD1
		INNER JOIN %Table:SF4% SF4
		ON SF4.F4_FILIAL = %xFilial:SF4%
		AND SF4.F4_CODIGO = SD1.D1_TES
		AND SF4.F4_ESTOQUE = 'S'
		AND SF4.%NotDel%
		WHERE SD1.D1_FILIAL  = %xFilial:SD1%
		AND SD1.D1_LOCAL = %Exp:cLocal%
		AND SD1.D1_COD = %Exp:cProduto%
		AND SD1.D1_NUMSEQ = %Exp:nNumSeq%
		AND SD1.%NotDel%
		UNION ALL
		SELECT %Exp:cColumnsB% 
		FROM %Table:SD2% SD2
		INNER JOIN %Table:SF4% SF4
		ON SF4.F4_FILIAL = %xFilial:SF4%
		AND SF4.F4_CODIGO = SD2.D2_TES
		AND SF4.F4_ESTOQUE = 'S'
		AND SF4.%NotDel%
		WHERE SD2.D2_FILIAL  = %xFilial:SD2%
		AND SD2.D2_LOCAL = %Exp:cLocal%
		AND SD2.D2_COD = %Exp:cProduto%
		AND SD2.D2_NUMSEQ = %Exp:nNumSeq%
		AND SD2.%NotDel%
		UNION ALL
		SELECT %Exp:cColumnsC% 
		FROM %Table:SD3% SD3
		WHERE SD3.D3_FILIAL  = %xFilial:SD3%
		AND SD3.D3_LOCAL = %Exp:cLocal%
		AND SD3.D3_COD = %Exp:cProduto%
		AND SD3.D3_NUMSEQ  = %Exp:nNumSeq%
		AND SD3.D3_EMISSAO >= %Exp:DTOS(dDataIni)%
		AND SD3.D3_EMISSAO <= %Exp:DTOS(dDataFim)%
		AND SD3.D3_ESTORNO = ' '
		AND SD3.%NotDel%
		UNION ALL	
		SELECT %Exp:cColumnsD% 
		FROM %Table:SD5% SD5
		WHERE SD5.D5_FILIAL = %xFilial:SD5%
		AND SD5.D5_LOCAL = %Exp:cLocal%
		AND SD5.D5_PRODUTO = %Exp:cProduto%
		AND SD5.D5_NUMSEQ = %Exp:nNumSeq%
		AND SD5.D5_ESTORNO = ' '
		AND SD5.%NotDel%
		UNION ALL
		SELECT %Exp:cColumnsE% 
		FROM %Table:D13% D13
		WHERE D13.D13_FILIAL = %xFilial:D13%
		AND D13.D13_LOCAL = %Exp:cLocal%
		AND D13.D13_PRODUT = %Exp:cProduto%
		AND D13.D13_PRDORI = %Exp:cPrdOri%
		AND D13.D13_NUMSEQ = %Exp:nNumSeq%
		AND D13.%NotDel%
		ORDER BY TIPO,
				NUMSEQ
	EndSql
	TcSetField(cAliasQry,'DATA','D')
	TcSetField(cAliasQry,'DTVALID','D')
	Do While (cAliasQry)->(!Eof())
		// Movimentos SD1/SD2/SD3/SD5/D13	
		AAdd(aRastrear,{(cAliasQry)->TIPO,X2NOME(),(cAliasQry)->OPERACAO,(cAliasQry)->DATLAN,(cAliasQry)->DOC,(cAliasQry)->SERIE,(cAliasQry)->CLIFOR,(cAliasQry)->LOJA,(cAliasQry)->TES,(cAliasQry)->CF,(cAliasQry)->LOTECTL,(cAliasQry)->NUMLOTE,(cAliasQry)->LOCALIZ,(cAliasQry)->NUMSERI,(cAliasQry)->QUANT,(cAliasQry)->QTSEGUM,(cAliasQry)->NUMSEQ})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	MntCargDad('WMSRAS',aRastrear, aFieldRAS)
Return .T.
