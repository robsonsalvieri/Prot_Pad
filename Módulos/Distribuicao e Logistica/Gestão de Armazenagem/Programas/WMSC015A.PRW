#INCLUDE "WMSC015A.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"   

#DEFINE WMSC015A01 "WMSC015A01"
//-----------------------------------------------------------
/*/{Protheus.doc} WMSC015A
Rastreabilidade
@author  Alexsander Burigo Corrêa
@version P11
@Since 16/05/12
/*/
//----------------------------------------------------------- 
Function WMSC015A(cLocal, cProduto)
Local aCoors := FWGetDialogSize (oMainWnd )
Local oLayerKard, oLayerKar
Local oPnlKard
Local aColsSX3   := {}
Local cPict  := PesqPict('SB2','B2_QATU')
	
Private aFieldKAD:= {}
Private dUltFech := GetUltFech(cLocal, cProduto)
Private dDataIni := dUltFech + 1
Private dDataFim := dDataBase

Private oBrwKar
Private nSldKar, cProd, cDescProd
Private oSldKar, oProduto, oDescProd
	// Cria tabela temporária
	CriaTemp()
	// Atualiza dados Kardex
	nSldKar := SetKardex(cLocal, cProduto)
	// Trata a altura da janela de acordo com a resolução
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel // Kardex
	
	// Cria conteiner para os browses

	oLayerKard := FWLayer():New()
	oLayerKard:Init(oDlgPrinc, .F., .T.)
	
	oLayerKard:AddLine( 'SALDOS', 6, .F.)
	oPnlSaldos := oLayerKard:GetLinePanel ('SALDOS')
		
	TSay():New( 5,5,{|| buscarSX3('B1_COD',,aColsSX3)},oPnlSaldos,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Produto
	oProduto  := TGet():New( 3,30,{|| cProduto}, oPnlSaldos, 50, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cProd',,,,.T.)
	
	TSay():New( 5,90,{||buscarSX3('B1_DESC',,aColsSX3)},oPnlSaldos,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Saldo
	oDescProd := TGet():New( 3,125,{|| Posicione('SB1',1,xFilial('SB1')+cProduto,'SB1->B1_DESC')}, oPnlSaldos, 200, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cDescProd',,,,.T.)

	// Campo Saldo Kardex		
	TSay():New( 5,350,{|| STR0004},oPnlSaldos,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) // Saldo
	oSldKar := TGet():New( 3,375,{|| nSldKar}, oPnlSaldos, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nSldKar',,,,.T.)
	
	// Define painel Detail
	oLayerKard:AddLine( 'KARD', 94, .F.)
	oPnlKard := oLayerKard:GetLinePanel ('KARD')
	
	// Campos adicionais
	aColsKar:= {;
				{ buscarSX3('D2_EMISSAO',,aColsSX3)     ,{|| ('WMSKAD')->KA_DATA}  ,'D',aColsSX3[2],0,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
				{ buscarSX3('D2_TES',,aColsSX3)         ,{|| ('WMSKAD')->KA_TESTM} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
				{ buscarSX3('D2_CF',,aColsSX3)          ,{|| ('WMSKAD')->KA_CFO}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
				{ buscarSX3('D2_DOC',,aColsSX3)		     ,{|| ('WMSKAD')->KA_DOCTO} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
				{ buscarSX3('D2_QUANT',,aColsSX3)       ,{|| ('WMSKAD')->KA_QTDE}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
				{ buscarSX3('D2_QUANT',STR0004,aColsSX3),{|| ('WMSKAD')->KA_SALDO} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},;
				{ buscarSX3('D2_NUMSEQ',,aColsSX3)      ,{|| ('WMSKAD')->KA_NUMSEQ},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};
				}
				
	oBrwKar := FWMBrowse():New()
	oBrwKar:SetAlias('WMSKAD')
	oBrwKar:SetOwner(oPnlKard)
	oBrwKar:SetFields(aColsKar)
	oBrwKar:SetMenuDef('')
	oBrwKar:SetGroup({ || IIf(('WMSKAD')->KA_ORDEM == '0',.T.,.F.)},.F.)
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'SALDO INICIAL'",'RED'   ,STR0005) // Saldo inicial
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0006) // NF. Entrada
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0007) // NF. Saída
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0008) // Entrada
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0009) // Saída
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0010) // Transferência
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'SALDO FINAL'"  ,'GREEN' ,STR0011) // Saldo final
	oBrwKar:SetDoubleClick({|| Rastrear(cLocal, cProduto)})
	oBrwKar:AddButton(STR0012,{|| Rastrear(cLocal, cProduto)},, 2, 0) // Rastrear
	oBrwKar:SetAmbiente(.F.)
	oBrwKar:SetWalkThru(.F.)
	oBrwKar:DisableDetails()
	oBrwKar:SetFixedBrowse(.T.)
	oBrwKar:SetDescription(STR0001) // Kardex
	oBrwKar:SetProfileID('1')

	oBrwKar:Activate()
	
	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center
	
	delTabTmp('WMSKAD')
Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} GetUltFech
Busca Data Ultimo Fechamento

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs		Busca Data Ultimo Fechamento
/*/ 
//-----------------------------------------------------------
Static Function GetUltFech(cLocal, cProduto)
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
	//-------------------------------
	// Cria tabela temporária KARDEX
	//-------------------------------
	aFiledKAD := {}
	AAdd(aFieldKAD,{'KA_ORIGEM' ,'C',13,0})

	buscarSX3('D2_EMISSAO',,aColsSX3) 
	AAdd(aFieldKAD,{'KA_DATA'   ,'D',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_TES',,aColsSX3)
	AAdd(aFieldKAD,{'KA_TESTM'  ,'C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_CF',,aColsSX3)
	AAdd(aFieldKAD,{'KA_CFO'    ,'C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_DOC',,aColsSX3)
	AAdd(aFieldKAD,{'KA_DOCTO'  ,'C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_QUANT',,aColsSX3)
	AAdd(aFieldKAD,{'KA_QTDE'   ,'N',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_QUANT',,aColsSX3)
	AAdd(aFieldKAD,{'KA_SALDO'  ,'N',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_NUMSEQ',,aColsSX3)
	AAdd(aFieldKAD,{'KA_NUMSEQ' ,'C',aColsSX3[3],aColsSX3[4]})

	AAdd(aFieldKAD,{'KA_ORDEM'  ,'C',1,0})

	// Cria tabelas temporárias
	criaTabTmp(aFieldKAD,{'KA_ORDEM+KA_NUMSEQ'},'WMSKAD')
Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} Rastrear
Rastreabilidade

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Rastreabilidade
/*/ 
//-----------------------------------------------------------
Static Function Rastrear(cLocal, cProduto)
Local aAreaKAD := ('WMSKAD') -> (GetArea())	
	If !Empty(('WMSKAD')->KA_NUMSEQ)
		Processa({|| ProcRegua(0), IncProc(STR0013 + '...'), WMSC015D(('WMSKAD')->KA_NUMSEQ,cLocal,cProduto,cProduto), IncProc(STR0014 + '...') } , STR0015, STR0016 + '...', .F.) // Aguarde , Encerrando, Rastreabilidade, Buscando informações 
	Else
		WMSMessage(STR0017,WMSC015A01,5/*MSG_HELP*/) // Número da sequência inválida!
	EndIf
	RestArea(aAreaKAD)
Return .T.
 
//-----------------------------------------------------------
/*/{Protheus.doc} SetKardex
Montar Array Kardex

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Busca Dados para gerar o Kardex do Produto
/*/
//-----------------------------------------------------------
Static Function SetKardex(cLocal, cProduto)
Local lInicio    := .T.
Local aKarLocal  := {}
Local cAliasQry  := Nil
Local cDocto     := PadR("", TamSx3("D1_DOC")[1]) 
Local cSerie     := PadR("", TamSx3("D1_SERIE")[1])
Local cClifor    := PadR("", TamSx3("D1_FORNECE")[1])
Local cLoja      := PadR("", TamSx3("D1_LOJA")[1])
Local cTipo      := PadR("", TamSx3("D1_TIPO")[1])
Local cOriLan    := PadR("", TamSx3("D1_ORIGLAN")[1])
Local cTes       := PadR("", TamSx3("D1_TES")[1])
Local cCf        := PadR("", TamSx3("D1_CF")[1])
Local cNumSeq    := PadR("", TamSx3("D1_NUMSEQ")[1])
Local nSldKar    := 0
Local nPos       := 0
Local dUltFech   := GetUltFech(cLocal, cProduto)
Local dDataIni   := dUltFech + 1
Local dDataFim   := dDataBase

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT '1' AS TIPO,
			' ' AS OPERACAO,
			%Exp:cDocto% AS DOC,
			%Exp:cSerie% AS SERIE,
			%Exp:cClifor% AS CLIFOR,
			%Exp:cLoja% AS LOJA,
			%Exp:cTipo% AS TPDOC,
			%Exp:cOriLan% AS ORIGEM,
			SB9.B9_DATA AS DATLAN,
			%Exp:cTes% AS TES,
			%Exp:cCf% AS CF,
			SB9.B9_QINI AS QUANT,
			%Exp:cNumSeq% AS NUMSEQ
		FROM %Table:SB9% SB9
		WHERE SB9.B9_FILIAL  = %xFilial:SB9%
		AND SB9.B9_COD = %Exp:cProduto%
		AND SB9.B9_LOCAL = %Exp:cLocal%
		AND SB9.B9_DATA = %Exp:DTOS(dUltFech)%
		AND SB9.%NotDel%
		UNION ALL
		SELECT '2' AS TIPO,
				'NF ENTRADA' AS OPERACAO,
				SD1.D1_DOC AS DOC,
				SD1.D1_SERIE AS SERIE,
				SD1.D1_FORNECE AS CLIFOR,
				SD1.D1_LOJA AS LOJA,
				SD1.D1_TIPO AS TPDOC,
				SD1.D1_ORIGLAN AS ORIGEM,
				SD1.D1_DTDIGIT AS DATLAN,
				SD1.D1_TES AS TES,
				SD1.D1_CF AS CF,
				SD1.D1_QUANT AS QUANT,
				SD1.D1_NUMSEQ AS NUMSEQ 
		FROM %Table:SD1% SD1
		INNER JOIN %Table:SF4% SF4 
		ON SF4.F4_FILIAL  = %xFilial:SF4%
		AND SF4.F4_CODIGO  = SD1.D1_TES
		AND SF4.F4_ESTOQUE = 'S'
		AND SF4.%NotDel%
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
		AND SD1.D1_LOCAL = %Exp:cLocal%
		AND SD1.D1_COD = %Exp:cProduto%
		AND SD1.D1_ORIGLAN <> 'LF'
		AND SD1.D1_DTDIGIT >= %Exp:DTOS(dDataIni)%
		AND SD1.D1_DTDIGIT <= %Exp:DTOS(dDataFim)%
		AND SD1.%NotDel%
		UNION ALL
		SELECT '2' AS TIPO,
				'NF SAIDA' AS OPERACAO,
				SD2.D2_DOC AS DOC,
				SD2.D2_SERIE AS SERIE,
				SD2.D2_CLIENTE AS CLIFOR,
				SD2.D2_LOJA AS LOJA,
				%Exp:cTipo% AS TPDOC,
				SD2.D2_ORIGLAN AS ORIGEM, 
				SD2.D2_EMISSAO AS DATLAN,
				SD2.D2_TES AS TES,
				SD2.D2_CF AS CF,
				SD2.D2_QUANT AS QUANT,
				SD2.D2_NUMSEQ AS NUMSEQ
		FROM %Table:SD2% SD2
		INNER JOIN %Table:SF4% SF4
		ON SF4.F4_FILIAL = %xFilial:SF4%
		AND SF4.F4_CODIGO = SD2.D2_TES
		AND SF4.F4_ESTOQUE = 'S' 
		AND SF4.%NotDel%
		WHERE SD2.D2_FILIAL = %xFilial:SD2% 
		AND SD2.D2_LOCAL = %Exp:cLocal%  
		AND SD2.D2_COD = %Exp:cProduto%
		AND SD2.D2_ORIGLAN <> 'LF'
		AND SD2.D2_EMISSAO >= %Exp:DTOS(dDataIni)% 
		AND SD2.D2_EMISSAO <= %Exp:DTOS(dDataFim)% 
		AND SD2.%NotDel%
		UNION ALL
		SELECT '2' AS TIPO,
				CASE WHEN SD3.D3_TM IN ('499','999') THEN 'TRANSFERENCIA'
					WHEN SD3.D3_TM NOT IN ('499','999') AND SD3.D3_TM <= '500' THEN 'ENTRADA'
					WHEN SD3.D3_TM NOT IN ('499','999') AND SD3.D3_TM > '500' THEN 'SAIDA' END OPERACAO,
				SD3.D3_DOC,
				%Exp:cSerie% AS SERIE,
				%Exp:cClifor% AS CLIFOR,
				%Exp:cLoja% AS LOJA,
				%Exp:cTipo% AS TPDOC,
				%Exp:cOriLan% AS ORIGEM,
				SD3.D3_EMISSAO AS DATLAN,
				SD3.D3_TM AS TES,
				SD3.D3_CF AS CF,
				SD3.D3_QUANT AS QUANT,
				SD3.D3_NUMSEQ AS NUMSEQ 
		FROM %Table:SD3% SD3
		
		WHERE SD3.D3_FILIAL = %xFilial:SD3%
		AND SD3.D3_LOCAL = %Exp:cLocal%  
		AND SD3.D3_COD = %Exp:cProduto%
		AND SD3.D3_ESTORNO = ' ' 
		AND SD3.D3_EMISSAO >= %Exp:DTOS(dDataIni)% 
		AND SD3.D3_EMISSAO <= %Exp:DTOS(dDataFim)%
		AND SD3.%NotDel%
		ORDER BY TIPO,
					DATLAN,
					NUMSEQ ASC
	EndSql
	TcSetField(cAliasQry,'DATLAN','D')
	Do While (cAliasQry)->(!EoF())
		// Saldo Inicial
		If lInicio 
			lInicio := .F.
			nSldKar := IIf((cAliasQry)->TIPO == '1',(cAliasQry)->QUANT,0)
			AAdd(aKarLocal,{'SALDO FINAL',dDataFim,"","","",0,0,Space(6),'0'})
			AAdd(aKarLocal,{'SALDO INICIAL',(cAliasQry)->DATLAN,"","","",0,nSldKar,"",'1'})
		EndIf
		nSldKar += If((cAliasQry)->TES <= "500",(cAliasQry)->QUANT,(cAliasQry)->QUANT*-1)
		// Movimento do SD1
		If (cAliasQry)->TIPO == '2'
			AAdd(aKarLocal,{(cAliasQry)->OPERACAO,(cAliasQry)->DATLAN,(cAliasQry)->TES,(cAliasQry)->CF,(cAliasQry)->DOC,(cAliasQry)->QUANT,nSldKar,(cAliasQry)->NUMSEQ,'2'})
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo	
	(cAliasQry)->(dbCloseArea())
	//Grava saldo Final
	If Len(aKarLocal) > 0
		nPos := aScan( aKarLocal, { |x| x[1] == 'SALDO FINAL'} )
		If nPos > 0
			aKarLocal[nPos][6] := nSldKar
		EndIf
	EndIf
	// Atualiza Dados da Tabela Temporária
	MntCargDad('WMSKAD',aKarLocal, aFieldKAD)	 
Return nSldKar
