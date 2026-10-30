#INCLUDE "WMSC015C.CH"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"   

#DEFINE WMSC015C01 "WMSC015C01"

//-----------------------------------------------------------
/*/{Protheus.doc} WMSC015C
Rastreabilidade
@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
                                                   
/*/ 
//----------------------------------------------------------- 
Function WMSC015C(cLocal,cProduto,cPrdOri)   	
Local aCoors   := FWGetDialogSize (oMainWnd )
Local oLayerKard
Local oPnlKard
Local aColsSX3 := {}
Local cPict    := PesqPict('SB2','B2_QATU')
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSB2 := SB2->(GetArea())
	
Private aFieldKEN:= {}
Private dUltFech := WMSC015Dat(cLocal,cProduto)
Private dDataIni := dUltFech + 1
Private dDataFim := dDataBase

Private oBrwKen
Private nSldKen, cProd, cDescProd  
Private oSldKen, oProduto, oDescProd
	// Cria tabela temporária
	CriaTemp()
	// Atualiza dados Kardex
	nSldKen := SetKarEnd(cLocal,cProduto,cPrdOri)
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
	oSldKar := TGet():New( 3,375,{|| nSldKen}, oPnlSaldos, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nSldKen',,,,.T.)
		
	// Define painel Detail
	oLayerKard:AddLine( 'KARD', 94, .F.)
	oPnlKard := oLayerKard:GetLinePanel ('KARD')
	
	aColsKen:= {;
				{ buscarSX3('D13_ENDER',,aColsSX3)        , {|| ('WMSKEN')->KE_ENDER}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_NUMSER',,aColsSX3)       , {|| ('WMSKEN')->KE_NUMSERI},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_LOTECT',,aColsSX3)       , {|| ('WMSKEN')->KE_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_NUMLOT',,aColsSX3)       , {|| ('WMSKEN')->KE_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_DTESTO',,aColsSX3)       , {|| ('WMSKEN')->KE_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_TM',,aColsSX3)           , {|| ('WMSKEN')->KE_TM}     ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_DOC',,aColsSX3)          , {|| ('WMSKEN')->KE_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_QTDEST',,aColsSX3)       , {|| ('WMSKEN')->KE_QTDEST} ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_QTDEST',STR0004,aColsSX3), {|| ('WMSKEN')->KE_SALDO}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
				{ buscarSX3('D13_NUMSEQ',,aColsSX3)       , {|| ('WMSKEN')->KE_NUMSEQ} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,};	
				}

	oBrwKen := FWMBrowse():New()
	oBrwKen:SetAlias('WMSKEN')
	oBrwKen:SetOwner(oPnlKard)
	oBrwKen:SetFields(aColsKen)
	oBrwKen:SetMenuDef('')
	oBrwKen:SetGroup({ || IIf(('WMSKEN')->KE_NRSEQ == 0,.T.,.F.)},.F.)
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'SALDO INICIAL'",'RED'   ,STR0005) // Saldo inicial
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0006) // NF. Entrada
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0007) // NF. Saída
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0008) // Entrada
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0009) // Saída
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0010) // Transferência
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'SALDO FINAL'"  ,'GREEN' ,STR0011) // Saldo final
	oBrwKen:SetDoubleClick({|| Rastrear(cLocal,cProduto,cPrdOri)})	
	oBrwKen:AddButton(STR0012,{|| Rastrear(cLocal,cProduto,cPrdOri)},, 2, 0) // Rastrear
	oBrwKen:SetTotalColumns()
	oBrwKen:SetAmbiente(.F.)
	oBrwKen:SetWalkThru(.F.)
	oBrwKen:SetFixedBrowse(.T.)
	oBrwKen:SetDescription(STR0003) // Kardex Endereço
	oBrwKen:SetFixedBrowse(.T.)	
	oBrwKen:DisableDetails()
	oBrwKen:SetProfileID('3')
	
	oBrwKen:Activate()
	
	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center
	
	delTabTmp('WMSKEN')
	RestArea(aAreaSB1)
	RestArea(aAreaSB2)
Return Nil
//-----------------------------------------------------------
/*/{Protheus.doc} GetUltFech/WMSC015Dat
Busca Data Ultimo Fechamento

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs Busca Data Ultimo Fechamento
/*/ 
//-----------------------------------------------------------
Function WMSC015Dat(cLocal,cProduto,cPrdOri,cEndereco,cLoteCtl,cNumLote,cNumserie,cIdUnitiz)
Local cAliasD15  := GetNextAlias()
Local dUltFech
Local cWhere := " "
Default cEndereco := " "
Default cLoteCtl  := " "
Default cNumLote  := " "
Default cNumserie := " "
Default cIdUnitiz := " "
Default cPrdOri   := " "


	// Parâmetro cWhere
	If !Empty(cPrdOri)
		cWhere += " AND D15.D15_PRDORI = '"+cPrdOri+"'"
	EndIf
	If !Empty(cEndereco)
		cWhere += " AND D15.D15_ENDER = '"+cEndereco+"'"
	EndIf
	If !Empty(cLoteCtl)
		cWhere += " AND D15.D15_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D15.D15_NUMLOT = '"+cNumLote+"'"
	EndIf
	If !Empty(cNumserie)
		cWhere += " AND D15.D15_NUMSER = '"+cNumserie+"'"
	EndIf
	If !Empty(cIdUnitiz)
		cWhere += " AND D15.D15_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	cWhere := "%"+cWhere+"%"
	BeginSql Alias cAliasD15
		SELECT MAX(D15.D15_DATA) AS D15_DATA
		FROM %Table:D15% D15
		WHERE D15.D15_FILIAL = %xFilial:D15%
		AND D15.D15_LOCAL = %Exp:cLocal%
		AND D15.D15_PRODUT = %Exp:cProduto%
		AND D15.D15_DATA <=  %Exp:DTOS(dDatabase)%
		AND D15.%NotDel%
		%Exp:cWhere%
	EndSql
	TcSetField(cAliasD15,'D15_DATA','D')
	If (cAliasD15)->(!Eof()) .AND. !Empty((cAliasD15)->D15_DATA)
		dUltFech := (cAliasD15)->D15_DATA
	Else
		dUltFech := Ctod( "01/01/80","ddmmyy" )
	EndIf
	(cAliasD15)->(dbCloseArea())
Return dUltFech
//-----------------------------------------------------------
/*/{Protheus.doc} CriaTemp
Cria tabelas temporárias

@author  Alexsander Burigo Corrêa
@version P12
@Since	16/05/12
@version 1.0
@obs		Cria tabelas temporárias     
            
/*/ 
//-----------------------------------------------------------
Static Function CriaTemp() 	
	//---------------------------------------
	// Cria tabela temporária KARDEX ENDEREÇO
	//--------------------------------------- 	
	aFiledKEN := {}
	AAdd(aFieldKEN,{'KE_ORIGEM','C',13,0})
	
	buscarSX3('D13_DTESTO',,aColsSX3)
   	AAdd(aFieldKEN,{'KE_DATA','D',aColsSX3[3],aColsSX3[4]})
    
   	buscarSX3('D13_TM',,aColsSX3)
  	AAdd(aFieldKEN,{'KE_TM','C',aColsSX3[3],aColsSX3[4]})
  	
  	buscarSX3('D13_DOC',,aColsSX3)
 	AAdd(aFieldKEN,{'KE_DOC','C',aColsSX3[3],aColsSX3[4]})
 	
 	buscarSX3('D13_ENDER',,aColsSX3)
   	AAdd(aFieldKEN,{'KE_ENDER','C',aColsSX3[3],aColsSX3[4]})
    
   	buscarSX3('D13_NUMSER',,aColsSX3)
   	AAdd(aFieldKEN,{'KE_NUMSERI','C',aColsSX3[3],aColsSX3[4]})
    
   	buscarSX3('D13_LOTECT',,aColsSX3)
   	AAdd(aFieldKEN,{'KE_LOTECTL','C',aColsSX3[3],aColsSX3[4]})
    
   	buscarSX3('D13_NUMLOT',,aColsSX3)
   	AAdd(aFieldKEN,{'KE_NUMLOTE','C',aColsSX3[3],aColsSX3[4]})
    
   	buscarSX3('D13_QTDEST',,aColsSX3)
 	AAdd(aFieldKEN,{'KE_QTDEST','N',aColsSX3[3],aColsSX3[4]})
 	
 	buscarSX3('D13_QTDEST',,aColsSX3)
 	AAdd(aFieldKEN,{'KE_SALDO','N',aColsSX3[3],aColsSX3[4]})
 	
 	buscarSX3('D13_NUMSEQ',,aColsSX3)
 	AAdd(aFieldKEN,{'KE_NUMSEQ','C',aColsSX3[3],aColsSX3[4]})
 	AAdd(aFieldKEN,{'KE_NRSEQ','N',9,0})

   	// Cria tabelas temporárias
	criaTabTmp(aFieldKEN,{'KE_ENDER+KE_NUMSERI+KE_LOTECTL+KE_NUMLOTE+Str(KE_NRSEQ)'},'WMSKEN')
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
Static Function Rastrear(cLocal,cProduto,cPrdOri)
Local aAreaKEN := ('WMSKEN') -> (GetArea())	
	If !Empty(('WMSKEN')->KE_NUMSEQ)
		Processa({|| ProcRegua(0), IncProc(STR0013 + '...'), WMSC015D(('WMSKEN')->KE_NUMSEQ,cLocal,cProduto,cPrdOri), IncProc(STR0014 + '...') } , STR0015, STR0016 + '...', .F.) // Aguarde , Encerrando, Rastreabilidade, Buscando informações 
	Else
		WMSMessage(STR0017,WMSC015C01,5/*MSG_HELP*/) // Número da sequência inválida!
	EndIf
	RestArea(aAreaKEN)	
Return .T.
 
//-----------------------------------------------------------
/*/{Protheus.doc} SetKarEnd
Montar Array Kardex Endereço

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Busca Dados para gerar o Kardex por Endereço do Produto
/*/ 
//-----------------------------------------------------------
Static Function SetKarEnd(cLocal,cProduto,cPrdOri)
Local cAliasTRB  := GetNextAlias()
Local cEnder     := "" 
Local cProd      := ""
Local cLoteCT    := ""
Local cNumLot    := ""
Local cNumSer    := ""
Local cDatLan    := ""
Local cTM        := PadR("", TamSx3("D13_TM")[1])
Local cDocto     := PadR("", TamSx3("D13_DOC")[1])
Local cNumSeq    := PadR("", TamSx3("D13_NUMSEQ")[1])
Local nSaldo     := 0
Local nPos       := 0
Local nSldKed    := 0
Local nContReq   := 1
Local dUltFech   := WMSC015Dat(cLocal,cProduto)
Local dDataIni   := dUltFech + 1
Local dDataFim   := dDataBase
Local aKarEnde   := {}

	dbSelectArea('D13')
	// Identifica os Enderecos
	BeginSql Alias cAliasTRB
		SELECT '1' AS TIPO,
				'' AS OPERACAO, 
				D15.D15_PRODUT AS PRODUTO,
				%Exp:cDatLan% AS DATLAN,
				%Exp:cTm% AS TM,
				%Exp:cDocto% AS DOC,
				D15.D15_ENDER  AS ENDER,
				D15.D15_NUMSER AS NUMSER,
				D15.D15_LOTECT AS LOTECT,
				D15.D15_NUMLOT AS NUMLOT,
				D15.D15_QINI AS QTDE,
				%Exp:cNumSeq% AS NUMSEQ,
				0 AS NRECNO
		FROM %Table:D15% D15 
		WHERE D15.D15_FILIAL = %xFilial:D15%
		AND D15.D15_LOCAL = %Exp:cLocal%
		AND D15.D15_PRODUT = %Exp:cProduto%
		AND D15.D15_PRDORI = %Exp:cPrdOri%
		AND D15.D15_DATA = %Exp:DTOS(dUltFech)%
		AND D15.D15_QINI <> 0
		AND D15.%NotDel%
		UNION ALL
		SELECT '2' AS TIPO,  
				CASE WHEN D13.D13_TM IN ('499','999') THEN 'TRANSFERENCIA'
					WHEN D13.D13_TM NOT IN ('499','999') AND D13.D13_TM <= '500' THEN 'ENTRADA'
					WHEN D13.D13_TM NOT IN ('499','999') AND D13.D13_TM > '500' THEN 'SAIDA' END OPERACAO,
				D13.D13_PRODUT AS PRODUTO,
				D13.D13_DTESTO AS DATLAN,
				D13.D13_TM AS TM,
				D13.D13_DOC AS DOC,
				D13.D13_ENDER  AS ENDER,
				D13.D13_NUMSER AS NUMSER,
				D13.D13_LOTECT AS LOTECT,
				D13.D13_NUMLOT AS NUMLOT,
				D13.D13_QTDEST AS QTDE,
				D13.D13_NUMSEQ AS NUMSEQ,
				D13.R_E_C_N_O_ AS NRECNO
		FROM %Table:D13% D13
		WHERE D13.D13_FILIAL = %xFilial:D13%
		AND D13.D13_LOCAL = %Exp:cLocal%
		AND D13.D13_PRODUT = %Exp:cProduto%
		AND D13.D13_PRDORI = %Exp:cPrdOri%
		AND D13.D13_DTESTO >= %Exp:DTOS(dDataIni)%
		AND D13.D13_DTESTO <= %Exp:DTOS(dDataFim)%
		AND D13.%NotDel%
		ORDER BY ENDER,
					TIPO,
					PRODUTO,
					NUMSER,
					LOTECT,
					NUMLOT,
					NRECNO,
					NUMSEQ
	EndSql
	TcSetField(cAliasTRB,'DATA','D')
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->( dbGoTop() )
	Do While !(cAliasTRB)->( Eof() )
		If (cEnder+cProd+cLoteCT+cNumLot+cNumSer) != (cAliasTRB)->(ENDER+PRODUTO+LOTECT+NUMLOT+NUMSER)
			If !Empty(cEnder+cProd+cLoteCT+cNumLot+cNumSer)
				//Posiciona no saldo final e gravar o total
				nPos := aScan( aKarEnde, { |x| x[1]+x[5]+x[6]+x[7]+x[8] ==  'SALDO FINAL'+cEnder+cNumSer+cLoteCT+cNumLot } )
				If nPos > 0
					aKarEnde[nPos][10] := nSaldo
				EndIf
				nSldKed += nSaldo
				nSaldo := 0
			EndIf
			// Redefine a quebra 
			cEnder   := (cAliasTRB)->ENDER
			cProd    := (cAliasTRB)->PRODUTO
			cLoteCT  := (cAliasTRB)->LOTECT
			cNumLot  := (cAliasTRB)->NUMLOT
			cNumSer  := (cAliasTRB)->NUMSER
			nContReq := 1
			//Saldo Final
			AAdd(aKarEnde,{'SALDO FINAL'  ,dDataFim," "," ",(cAliasTRB)->ENDER,(cAliasTRB)->NUMSER,(cAliasTRB)->LOTECT,(cAliasTRB)->NUMLOT,0,0,space(len(D13->D13_NUMSEQ)),0})	
			// Saldo Inicial
			nSaldo := IIf((cAliasTRB)->TIPO == '1',(cAliasTRB)->QTDE,0)
			AAdd(aKarEnde,{'SALDO INICIAL',dUltFech,"",Space(len((cAliasTRB)->DOC)),(cAliasTRB)->ENDER,(cAliasTRB)->NUMSER,(cAliasTRB)->LOTECT,(cAliasTRB)->NUMLOT,0,nSaldo,space(len(D13->D13_NUMSEQ)),1})
		EndIf
		//Movimentações
		If (cAliasTRB)->TIPO == '2'
			nSaldo += IF((cAliasTRB)->TM <= "500" .OR. Substr((cAliasTRB)->TM,1,2) $ 'DE/PR/MA',(cAliasTRB)->QTDE,(cAliasTRB)->QTDE*-1)
			AAdd(aKarEnde,{(cAliasTRB)->OPERACAO,(cAliasTRB)->DATLAN,(cAliasTRB)->TM,(cAliasTRB)->DOC,(cAliasTRB)->ENDER,(cAliasTRB)->NUMSER,(cAliasTRB)->LOTECT,(cAliasTRB)->NUMLOT,(cAliasTRB)->QTDE,nSaldo,(cAliasTRB)->NUMSEQ,++nContReq})
		EndIf
		(cAliasTRB)->( dbSkip() )
	Enddo
	If (cAliasTRB)->( Eof() ) .And. Len(aKarEnde) > 0
		//Posiciona no saldo final e gravar o total
		nPos := aScan( aKarEnde, { |x| x[1]+x[5]+x[6]+x[7]+x[8] ==  'SALDO FINAL'+cEnder+cNumSer+cLoteCT+cNumLot } ) 
		aKarEnde[nPos][10] := nSaldo
		nSldKed += nSaldo
		nSaldo := 0
	EndIf
	(cAliasTRB)->(dbCloseArea())
	// Atualiza dados tabela temporária
	MntCargDad('WMSKEN',aKarEnde,aFieldKEN )
Return nSldKed
