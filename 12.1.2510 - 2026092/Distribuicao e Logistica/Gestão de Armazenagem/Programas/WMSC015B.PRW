#INCLUDE "WMSC015B.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"   

#DEFINE WMSC015B01 "WMSC015B01"

//-----------------------------------------------------------
/*/{Protheus.doc} WMSC015B
Rastreabilidade
@author  Alexsander Burigo Corrêa
@version P11
@Since 16/05/12
/*/
//----------------------------------------------------------- 
Function WMSC015B(cLocal, cProduto)
Local aCoors    := FWGetDialogSize (oMainWnd )
Local oLayerKard, oFWLayerKlt
Local oPnlKlt
Local aColsSX3  := {}
Local cPict     := PesqPict('SB2','B2_QATU')
	
Private aFieldKLT:= {}
Private dUltFech := GetUltFech(cLocal, cProduto)
Private dDataIni := dUltFech + 1
Private dDataFim := dDataBase

Private oBrwKlt
Private nSldKlt, cProd, cDescProd  
Private oSldKlt, oProduto, oDescProd
	// Cria tabela temporária
	CriaTemp()
	// Atualiza dados Kardex
	nSldKlt := SetKarLot(cLocal, cProduto)
	// Trata a altura da janela de acordo com a resolução	
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel // Kardex
	// Cria conteiner para os browse
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
	oSldKar := TGet():New( 3,375,{|| nSldKlt}, oPnlSaldos, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nSldKlt',,,,.T.)
	
	// Define painel Detail
	oLayerKard:AddLine( 'KARD', 94, .F.)
	oPnlKard := oLayerKard:GetLinePanel ('KARD')	
		
	aColsKLt:= {;
				{ buscarSX3('D5_LOTECTL',,aColsSX3)     ,{|| ('WMSKLT')->KL_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D5_NUMLOTE',,aColsSX3)     ,{|| ('WMSKLT')->KL_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D5_DATA',,aColsSX3)        ,{|| ('WMSKLT')->KL_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D5_ORIGLAN',,aColsSX3)     ,{|| ('WMSKLT')->KL_ORIGLAN},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D5_DOC',,aColsSX3)         ,{|| ('WMSKLT')->KL_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D5_DTVALID',,aColsSX3)     ,{|| ('WMSKLT')->KL_DTVALID},'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D5_QUANT',,aColsSX3)       ,{|| ('WMSKLT')->KL_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D5_QUANT',STR0004,aColsSX3),{|| ('WMSKLT')->KL_SALDO}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D5_NUMSEQ',,aColsSX3)      ,{|| ('WMSKLT')->KL_NUMSEQ} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,};
				}
	
	oBrwKlt := FWMBrowse():New()
	oBrwKlt:SetAlias('WMSKLT')
	oBrwKlt:SetOwner(oPnlKard)
	oBrwKlt:SetFields(aColsKlt)	
	oBrwKlt:SetMenuDef('')
	oBrwKlt:SetGroup({ || IIf(('WMSKLT')->KL_ORDEM == '0',.T.,.F.)},.F.)
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'SALDO INICIAL'",'RED'   ,STR0005) // Saldo inicial
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0006) // NF. Entrada
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0007) // NF. Saída
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0008) // Entrada
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0009) // Saída
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0010) // Transferência
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'SALDO FINAL'"  ,'GREEN' ,STR0011) // Saldo final
	oBrwKlt:SetDoubleClick({|| Rastrear(cLocal, cProduto)})
	oBrwKlt:AddButton(STR0012,{|| Rastrear(cLocal, cProduto)} ,, 2, 0) // Rastrear
	oBrwKlt:SetAmbiente(.F.)
	oBrwKlt:SetWalkThru(.F.)
	oBrwKlt:SetFixedBrowse(.T.)
	oBrwKlt:SetDescription(STR0002) // Kardex Lote
	oBrwKlt:DisableDetails()
	oBrwKlt:SetProfileID('2')

	oBrwKlt:Activate()
	
	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center
	
	delTabTmp('WMSKLT')
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
	//------------------------------------
	// Cria tabela temporária KARDEX LOTE
	//------------------------------------
	aFiledKLT := {}
	AAdd(aFieldKLT,{'KL_ORIGEM','C',13,0})  
	
	buscarSX3('D5_DATA',,aColsSX3)
	AAdd(aFieldKLT,{'KL_DATA','D',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D5_ORIGLAN',,aColsSX3) 
  	AAdd(aFieldKLT,{'KL_ORIGLAN','C',aColsSX3[3],aColsSX3[4]})
  	
  	buscarSX3('D5_DOC',,aColsSX3)
 	AAdd(aFieldKLT,{'KL_DOC','C',aColsSX3[3],aColsSX3[4]})
 	
 	buscarSX3('D5_LOTECTL',,aColsSX3)
	AAdd(aFieldKLT,{'KL_LOTECTL','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D5_NUMLOTE',,aColsSX3)
	AAdd(aFieldKLT,{'KL_NUMLOTE','C',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D5_DTVALID',,aColsSX3)
	AAdd(aFieldKLT,{'KL_DTVALID','D',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_QUANT',,aColsSX3)
	AAdd(aFieldKLT,{'KL_QUANT','N',aColsSX3[3],aColsSX3[4]})
	
	buscarSX3('D2_QUANT',,aColsSX3)
 	AAdd(aFieldKLT,{'KL_SALDO','N',aColsSX3[3],aColsSX3[4]})
 	
 	buscarSX3('D2_NUMSEQ',,aColsSX3)
 	AAdd(aFieldKLT,{'KL_NUMSEQ','C',aColsSX3[3],aColsSX3[4]})
 	
 	AAdd(aFieldKLT,{'KL_ORDEM','C',1,0})

  	// Cria tabelas temporárias
	criaTabTmp(aFieldKLT,{'KL_LOTECTL+KL_NUMLOTE+KL_ORDEM+KL_NUMSEQ+KL_ORIGLAN'},'WMSKLT')	 		
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
Local aAreaKLT := ('WMSKLT') -> (GetArea())	
	If !Empty(('WMSKLT')->KL_NUMSEQ)
		Processa({|| ProcRegua(0), IncProc(STR0013 + '...'), WMSC015D(('WMSKLT')->KL_NUMSEQ,cLocal,cProduto,cProduto), IncProc(STR0014 + '...') } , STR0015, STR0016 + '...', .F.) // Aguarde , Encerrando, Rastreabilidade, Buscando informações 
	Else
		WMSMessage(STR0017,WMSC015B01,5/*MSG_HELP*/) // Número da sequência inválida!
	EndIf
	RestArea(aAreaKLT)	
Return .T.
 
//-----------------------------------------------------------
/*/{Protheus.doc} SetKarLot
Montar Array Kardex Lote

@author  Alexsander Burigo Corrêa
@version P11
@Since 16/05/12
@obS Busca Dados para gerar o Kardex por Lote do Produto
/*/ 
//----------------------------------------------------------- 
Static Function SetKarLot(cLocal, cProduto)
Local aKarLote   := {}  
Local cAliasQry  := GetNextAlias()
Local cLote      := ""
Local cNumLote   := ""
Local nSaldo     := 0
Local nSldKlt    := 0
Local nCont      := 0 
Local nPos       := 0
Local dUltFech   := GetUltFech(cLocal, cProduto)
Local dDataIni   := dUltFech + 1
Local dDataFim   := dDataBase
Local cDatLan    := PadR("", TamSx3("D5_DATA")[1])
Local cOriLan    := PadR("", TamSx3("D5_ORIGLAN")[1])
Local cDocto     := PadR("", TamSx3("D5_DOC")[1])
Local cNumSeq    := PadR("", TamSx3("D5_NUMSEQ")[1])

	BeginSql Alias cAliasQry
		SELECT '1' AS TIPO,
				' ' AS OPERACAO, 
				%Exp:cDatLan% AS DATLAN,
				%Exp:cOriLan% AS ORIGEM,
				%Exp:cDocto% AS DOC,
				SBJ.BJ_LOTECTL AS LOTECTL,
				SBJ.BJ_NUMLOTE AS NUMLOTE,
				SBJ.BJ_DTVALID AS DTVALID,
				SUM(SBJ.BJ_QINI) AS QUANT,
				%Exp:cNumSeq% AS NUMSEQ
		FROM %Table:SBJ% SBJ
		WHERE SBJ.BJ_FILIAL = %xFilial:SBJ%
		AND SBJ.BJ_LOCAL = %Exp:cLocal%
		AND SBJ.BJ_COD = %Exp:cProduto%
		AND SBJ.BJ_DATA = %Exp:DTOS(dUltFech)%
		AND SBJ.%NotDel%
		GROUP BY SBJ.BJ_LOTECTL,
					SBJ.BJ_NUMLOTE,
					SBJ.BJ_DTVALID
		UNION ALL
		SELECT '2' AS TIPO,
			CASE WHEN SD5.D5_ORIGLAN IN ('499','999') THEN 'TRANSFERENCIA'
				WHEN SD5.D5_ORIGLAN NOT IN ('499','999') AND SD5.D5_ORIGLAN <= '500' THEN 'ENTRADA'
				WHEN SD5.D5_ORIGLAN NOT IN ('499','999') AND SD5.D5_ORIGLAN > '500' THEN 'SAIDA' END OPERACAO,
			SD5.D5_DATA AS DATLAN,
			SD5.D5_ORIGLAN AS ORIGEM,
			SD5.D5_DOC AS DOC,
			SD5.D5_LOTECTL AS LOTECTL,
			SD5.D5_NUMLOTE AS NUMLOTE,
			SD5.D5_DTVALID AS DTVALID,
			SD5.D5_QUANT AS QUANT,
			SD5.D5_NUMSEQ AS NUMSEQ
		FROM %table:SD5% SD5
		WHERE SD5.D5_FILIAL  = %xFilial:SD5%
		AND SD5.D5_LOCAL = %Exp:cLocal%
		AND SD5.D5_PRODUTO = %Exp:cProduto%
		AND SD5.D5_DATA >= %Exp:DTOS(dDataIni)%
		AND SD5.D5_DATA <= %Exp:DTOS(dDataFim)%
		AND SD5.D5_ESTORNO = ' '
		AND SD5.%NotDel%
		ORDER BY LOTECTL,
					NUMLOTE,
					TIPO,
					DATLAN,
					NUMSEQ
	EndSql
	TcSetField(cAliasQry,'DATLAN','D')
	TcSetField(cAliasQry,'DTVALID','D')
	Do While (cAliasQry)->(!EoF())
		If cLote+cNumLote != (cAliasQry)->(LOTECTL+NUMLOTE)
			//Posiciona no saldo final
			If !Empty(cLote+cNumLote)
				nPos := aScan( aKarLote, { |x| x[1]+x[5]+x[6] ==  'SALDO FINAL'+cLote+cNumLote } )
				If nPos > 0 
					aKarLote[nPos][9] := nSaldo
				EndIf
				nSldKlt += nSaldo
				nSaldo := 0 
			EndIf
			//Redefine quebra 
			cLote    := (cAliasQry)->LOTECTL
			cNumLote := (cAliasQry)->NUMLOTE
			// Saldo Final
			AAdd(aKarLote,{'SALDO FINAL',dDataFim,(cAliasQry)->ORIGEM,(cAliasQry)->DOC,(cAliasQry)->LOTECTL,(cAliasQry)->NUMLOTE,CTOD('  /  /  '),0,0,(cAliasQry)->NUMSEQ,'0'})
			// Saldo Inicial
			nSaldo := Iif((cAliasQry)->TIPO == '1',(cAliasQry)->QUANT,0) 
			AAdd(aKarLote,{'SALDO INICIAL',dUltFech,(cAliasQry)->ORIGEM,(cAliasQry)->DOC,(cAliasQry)->LOTECTL,(cAliasQry)->NUMLOTE,(cAliasQry)->DTVALID,0,nSaldo,(cAliasQry)->NUMSEQ,'1'})
		EndIf
		//Movimentações
		If (cAliasQry)->TIPO == '2'
			nSaldo += IF((cAliasQry)->ORIGEM <= "500" .OR. (cAliasQry)->ORIGEM $ 'DE/PR/MA',(cAliasQry)->QUANT,(cAliasQry)->QUANT*-1)
			AAdd(aKarLote,{(cAliasQry)->OPERACAO,(cAliasQry)->DATLAN,(cAliasQry)->ORIGEM,(cAliasQry)->DOC,(cAliasQry)->LOTECTL,(cAliasQry)->NUMLOTE,(cAliasQry)->DTVALID,(cAliasQry)->QUANT,nSaldo,(cAliasQry)->NUMSEQ,'2'})
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	//Posiciona no saldo final
	If Len(aKarLote) > 0
		nPos := aScan( aKarLote, { |x| x[1]+x[5]+x[6] ==  'SALDO FINAL'+cLote+cNumLote } )
		aKarLote[nPos][9] := nSaldo
		nSldKlt += nSaldo
		nSaldo := 0	
	EndIf
	// Atualiza Dados da Tabela Temporária
	MntCargDad('WMSKLT',aKarLote, aFieldKLT)	 
Return nSldKlt
