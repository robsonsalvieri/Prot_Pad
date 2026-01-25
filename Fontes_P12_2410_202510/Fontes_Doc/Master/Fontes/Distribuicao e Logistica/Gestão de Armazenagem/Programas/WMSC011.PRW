#INCLUDE "WMSC011.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} WMSC011
Rastreabilidade
@author  Alexsander Burigo Corrêa
@version P11
@Since   16/05/12
/*/
//----------------------------------------------------------
Function WMSC011()
Local aCoors := FWGetDialogSize (oMainWnd )
Local oLayerKard, oLayerKar, oFWLayerKlt, oLayerKen
Local oPnlKard, oPnlKlt, oPnlKen

Local aColsSX3   := {}
Local cPict  := PesqPict('SB2','B2_QATU')

Private aFieldKAD:= {}
Private aFieldKLT:= {}
Private aFieldKEN:= {}
Private dUltFech := GetUltFech()
Private dDataIni := dUltFech + 1
Private dDataFim := dDataBase

Private oBrwKar, oBrwKlt, oBrwKen
Private nSldKar, nSldKlt, nSldKen, cProduto, cDescProd
Private oSldKar, oSldKlt, oSldKen, oProduto, oDescProd

	//Cria tabela temporária
	CriaTemp()

	//Atualiza dados Kardex
	nSldKar := SetKardex()
	nSldKlt := SetKarLot()
	nSldKen := SetKarEnd()

	//Trata a altura da janela de acordo com a resolução
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel //Kardex

	// Cria conteiner para os browses

	oLayerKard := FWLayer():New()
	oLayerKard:Init(oDlgPrinc, .F., .T.)

	oLayerKard:AddLine( 'SALDOS', 6, .F.)
	oPnlSaldos := oLayerKard:GetLinePanel ('SALDOS')

	TSay():New( 5,5,{|| buscarSX3('B1_COD',,aColsSX3)},oPnlSaldos,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) //Produto
	oProduto  := TGet():New( 3,30,{|| SB2->B2_COD}, oPnlSaldos, 50, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cProduto',,,,.T.)

	TSay():New( 5,90,{||buscarSX3('B1_DESC',,aColsSX3)},oPnlSaldos,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) //Saldo
	oDescProd := TGet():New( 3,125,{|| Posicione('SB1',1,xFilial('SB1')+SB2->B2_COD,'SB1->B1_DESC')}, oPnlSaldos, 200, 9,"@!",,,,,,,.T.,,,{|| .F.},,,,,,,'cDescProd',,,,.T.)

	// Define painel Detail
	oLayerKard:AddLine( 'KARD', 94, .F.)
	oPnlKard := oLayerKard:GetLinePanel ('KARD')

	aFolders := {STR0001, STR0002, STR0003} //Kardex, Kardex Lote, Kardex Endereço

	oFolder := TFolder():New( 0, 0, aFolders, aFolders, oPnlKard,,,, .T.,,oPnlKard:NCLIENTWIDTH/2,oPnlKard:NCLIENTHEIGHT/2)

	oLayerKar := FWLayer():New()
	oLayerKar:Init(oFolder:aDialogs[1], .F., .T.)
	oLayerKar:AddLine( 'UPKARDEXS', 6, .F.)
	oPanelKarS := oLayerKar:GetLinePanel ('UPKARDEXS')

	// Campo Saldo Kardex
	TSay():New( 5,5,{|| STR0004},oPanelKarS,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) //Saldo
	oSldKar := TGet():New( 3,34,{|| nSldKar}, oPanelKarS, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nSldKar',,,,.T.)

	oLayerKar:AddLine( 'DOWNKARDEX', 94, .F.)
	oPanelKardex := oLayerKar:GetLinePanel ('DOWNKARDEX')

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
	oBrwKar:SetOwner(oPanelKardex)
	oBrwKar:SetFields(aColsKar)
	oBrwKar:SetMenuDef('')
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'SALDO INICIAL'",'RED'   ,STR0005) //Saldo inicial
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0006) //NF. Entrada
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0007) //NF. Saída
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0008) //Entrada
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0009) //Saída
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0010) //Transferência
	oBrwKar:AddLegend("AllTrim(('WMSKAD')->KA_ORIGEM) == 'SALDO FINAL'"  ,'GREEN' ,STR0011) //Saldo final
	oBrwKar:SetDoubleClick({|| WMSC011RAS(('WMSKAD')->KA_NUMSEQ)})
	oBrwKar:AddButton(STR0012,"WMSC011RAS(('WMSKAD')->KA_NUMSEQ)" ,, 2, 0) //Rastrear
	oBrwKar:SetAmbiente(.F.)
	oBrwKar:SetWalkThru(.F.)
	oBrwKar:DisableDetails()
	oBrwKar:SetFixedBrowse(.T.)
	oBrwKar:SetDescription(STR0001) //Kardex
	oBrwKar:SetProfileID('1')

	oFWLayer7 := FWLayer():New()
	oFWLayer7:Init(oFolder:aDialogs[2], .F., .T.)

	oFWLayer7:AddLine( 'UPKARDEXL', 6, .F.)
	oPanelKarL := oFWLayer7:GetLinePanel ('UPKARDEXL')

 	// Campo Saldo Kardex
	TSay():New( 5,5,{|| STR0004},oPanelKarL,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) //Saldo
	oSldKlt := TGet():New( 3,34,{|| nSldKlt}, oPanelKarL, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nSldKlt',,,,.T.)

	oFWLayer7:AddLine( 'DOWNKARDEX', 94, .F.)
	oPanelKardeL := oFWLayer7:GetLinePanel ('DOWNKARDEX')

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
	oBrwKlt:SetOwner(oPanelKardeL)
	oBrwKlt:SetFields(aColsKlt)
	oBrwKlt:SetMenuDef('')
	oBrwKlt:SetGroup({ || IIf(('WMSKLT')->KL_ORDEM == '0',.T.,.F.)},.F.)
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'SALDO INICIAL'",'RED'   ,STR0005) //Saldo inicial
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0006) //NF. Entrada
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0007) //NF. Saída
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0008) //Entrada
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0009) //Saída
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0010) //Transferência
	oBrwKlt:AddLegend("AllTrim(('WMSKLT')->KL_ORIGEM) == 'SALDO FINAL'"  ,'GREEN' ,STR0011) //Saldo final
	oBrwKlt:SetDoubleClick({|| WMSC011RAS(('WMSKLT')->KL_NUMSEQ)})
	oBrwKlt:AddButton(STR0012,"WMSC011RAS(('WMSKLT')->KL_NUMSEQ)" ,, 2, 0) //Rastrear
	oBrwKlt:SetAmbiente(.F.)
	oBrwKlt:SetWalkThru(.F.)
	oBrwKlt:SetFixedBrowse(.T.)
	oBrwKlt:SetDescription(STR0002) //Kardex Lote
	oBrwKlt:DisableDetails()
	oBrwKlt:SetProfileID('2')

	oLayerKen := FWLayer():New()
	oLayerKen:Init(oFolder:aDialogs[3], .F., .T.)

	oLayerKen:AddLine( 'UPKARDEXL', 6, .F.)
	oPanelKarE := oLayerKen:GetLinePanel ('UPKARDEXL')

	// Campo Saldo Kardex
	TSay():New( 5,5,{|| STR0004},oPanelKarE,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20) //Saldo
	oSldKen := TGet():New( 3,34,{|| nSldKen}, oPanelKarE, 90, 9,cPict,,,,,,,.T.,,,{|| .F.},,,,,,,'nSldKen',,,,.T.)

	oLayerKen:AddLine( 'DOWNKARDEX', 94, .F.)
	oPanelKardeE := oLayerKen:GetLinePanel ('DOWNKARDEX')

	aColsKen:= {;
	           { buscarSX3('DB_LOCALIZ',,aColsSX3)     , {|| ('WMSKEN')->KE_LOCALIZ},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_NUMSERI',,aColsSX3)     , {|| ('WMSKEN')->KE_NUMSERI},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_LOTECTL',,aColsSX3)     , {|| ('WMSKEN')->KE_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_NUMLOTE',,aColsSX3)     , {|| ('WMSKEN')->KE_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_DATA',,aColsSX3)        , {|| ('WMSKEN')->KE_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_TM',,aColsSX3)          , {|| ('WMSKEN')->KE_TM}     ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_DOC',,aColsSX3)         , {|| ('WMSKEN')->KE_DOC}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_QUANT',,aColsSX3)       , {|| ('WMSKEN')->KE_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_QUANT',STR0004,aColsSX3), {|| ('WMSKEN')->KE_SALDO}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,.F.,},;
	           { buscarSX3('DB_NUMSEQ',,aColsSX3)      , {|| ('WMSKEN')->KE_NUMSEQ} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,.F.,};
	           }

	oBrwKen := FWMBrowse():New()
	oBrwKen:SetAlias('WMSKEN')
	oBrwKen:SetOwner(oPanelKardeE)
	oBrwKen:SetFields(aColsKen)
	oBrwKen:SetMenuDef('')
	oBrwKen:SetGroup({ || IIf(('WMSKEN')->KE_ORDEM == '0',.T.,.F.)},.F.)
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'SALDO INICIAL'",'RED'   ,STR0005) //Saldo inicial
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'NF ENTRADA'"   ,'YELLOW',STR0006) //NF. Entrada
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'NF SAIDA'"     ,'BLUE'  ,STR0007) //NF. Saída
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'ENTRADA'"      ,'ORANGE',STR0008) //Entrada
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'SAIDA'"        ,'BLACK' ,STR0009) //Saída
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'TRANSFERENCIA'",'BROWN' ,STR0010) //Transferência
	oBrwKen:AddLegend("AllTrim(('WMSKEN')->KE_ORIGEM) == 'SALDO FINAL'"  ,'GREEN' ,STR0011) //Saldo final
	oBrwKen:SetDoubleClick({|| WMSC011RAS(('WMSKEN')->KE_NUMSEQ)})
	oBrwKen:AddButton(STR0012,"WMSC011RAS(('WMSKEN')->KE_NUMSEQ)" ,, 2, 0) //Rastrear
	oBrwKen:SetTotalColumns()
	oBrwKen:SetAmbiente(.F.)
	oBrwKen:SetWalkThru(.F.)
	oBrwKen:SetFixedBrowse(.T.)
	oBrwKen:SetDescription(STR0003) //Kardex Endereço
	oBrwKen:SetFixedBrowse(.T.)
	oBrwKen:DisableDetails()
	oBrwKen:SetProfileID('3')

	oBrwKar:Activate()
	oBrwKlt:Activate()
	oBrwKen:Activate()

	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	Activate MsDialog oDlgPrinc Center

	delTabTmp('WMSKAD')
	delTabTmp('WMSKLT')
	delTabTmp('WMSKEN')
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
Static Function CriaTemp()

	//------------------------------
	// Cria tabela temporária KARDEX
	//------------------------------
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
	criaTabTmp(aFieldKAD,{'DTOS(KA_DATA)+KA_ORDEM+KA_NUMSEQ'},'WMSKAD')

	//-----------------------------------
	// Cria tabela temporária KARDEX LOTE
	//-----------------------------------
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

	//--------------------------------------
	//Cria tabela temporária KARDEX ENDEREÇO
	//--------------------------------------
	aFiledKEN := {}
	AAdd(aFieldKEN,{'KE_ORIGEM','C',13,0})

	buscarSX3('DB_DATA',,aColsSX3)
	AAdd(aFieldKEN,{'KE_DATA','D',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_TM',,aColsSX3)
	AAdd(aFieldKEN,{'KE_TM','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_DOC',,aColsSX3)
	AAdd(aFieldKEN,{'KE_DOC','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_LOCALIZ',,aColsSX3)
	AAdd(aFieldKEN,{'KE_LOCALIZ','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_NUMSERI',,aColsSX3)
	AAdd(aFieldKEN,{'KE_NUMSERI','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_LOTECTL',,aColsSX3)
	AAdd(aFieldKEN,{'KE_LOTECTL','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_NUMLOTE',,aColsSX3)
	AAdd(aFieldKEN,{'KE_NUMLOTE','C',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_QUANT',,aColsSX3)
	AAdd(aFieldKEN,{'KE_QUANT','N',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_QUANT',,aColsSX3)
	AAdd(aFieldKEN,{'KE_SALDO','N',aColsSX3[3],aColsSX3[4]})

	buscarSX3('DB_NUMSEQ',,aColsSX3)
	AAdd(aFieldKEN,{'KE_NUMSEQ','C',aColsSX3[3],aColsSX3[4]})
	AAdd(aFieldKEN,{'KE_ORDEM','C',1,0})

	// Cria tabelas temporárias
	criaTabTmp(aFieldKEN,{'KE_LOCALIZ+KE_NUMSERI+KE_LOTECTL+KE_NUMLOTE+KE_ORDEM+KE_NUMSEQ+KE_TM'},'WMSKEN')

Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} WMSC011RAS
Rastreabilidade

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Rastreabilidade

/*/
//----------------------------------------------------------
Function WMSC011RAS(nNUMSEQ)
Local aAreaKAD := ('WMSKAD') -> (GetArea())
Local aAreaKLT := ('WMSKLT') -> (GetArea())
Local aAreaKEN := ('WMSKEN') -> (GetArea())

	If !Empty(nNUMSEQ)
		Processa({|| ProcRegua(0), IncProc(STR0013 + '...'), WMSC011A(nNUMSEQ), IncProc(STR0014 + '...') } , STR0015, STR0016 + '...', .F.) //Aguarde , Encerrando, Rastreabilidade, Buscando informações
	Else
		Help( ,1, 'HELP',,STR0017, 1, 0 ) //Número da sequência inválida!
	EndIf

RestArea(aAreaKAD)
RestArea(aAreaKLT)
RestArea(aAreaKEN)
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} SetKardex
Montar Array Kardex

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Busca Dados para gerar o Kardex do Produto

/*/
//----------------------------------------------------------
Static Function SetKardex()
Local cAliasSD1  := GetNextAlias()
Local cAliasSD2  := GetNextAlias()
Local cAliasSD3  := GetNextAlias()

Local dUltFech   := GetUltFech()
Local dDataIni   := dUltFech + 1
Local dDataFim   := dDataBase
Local aKarLocal  := {}
Local nSldKar    := 0
Local nCont      := 0

	dbSelectArea('SF1')
	SF1->( dbSetOrder(1) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

	dbSelectArea('SB9')
	SB9->( dbSetOrder(1) )
	SB9->( dbSeek(xFilial('SB9')+SB2->B2_COD+SB2->B2_LOCAL+DTOS(dUltFech)) )

	// Saldo Inicial
	AAdd(aKarLocal,{'SALDO INICIAL',SB9->B9_DATA,"","","",SB9->B9_QINI,SB9->B9_QINI,Space(6),'1'})

	// Movimento do SD1
	cQuery := " SELECT D1_DOC,"
	cQuery +=        " D1_SERIE,"
	cQuery +=        " D1_FORNECE,"
	cQuery +=        " D1_LOJA,"
	cQuery +=        " D1_TIPO,"
	cQuery +=        " D1_ORIGLAN,"
	cQuery +=        " D1_DTDIGIT,"
	cQuery +=        " D1_TES,"
	cQuery +=        " D1_CF,"
	cQuery +=        " D1_QUANT,"
	cQuery +=        " D1_NUMSEQ"
	cQuery +=  " FROM "+RetSqlName("SD1")+" SD1,"
	cQuery +=           RetSqlName("SF4")+" SF4"
	cQuery += " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
	cQuery +=   " AND SD1.D1_COD     = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD1.D1_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF4.F4_FILIAL  = '"+xFilial("SF4")+"'"
	cQuery +=   " AND SF4.F4_CODIGO  = SD1.D1_TES"
	cQuery +=   " AND SF4.F4_ESTOQUE = 'S'"
	cQuery +=   " AND SF4.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D1_DTDIGIT,D1_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD1,.F.,.T.)
	TcSetField(cAliasSD1,'D1_DTDIGIT','D')

	While !(cAliasSD1)->( Eof() )

		If SF1->( dbSeek(xFilial('SF1')+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_TIPO) )

			If (cAliasSD1)->D1_ORIGLAN <> 'LF' .AND. (cAliasSD1)->D1_DTDIGIT >= dDataIni .AND. (cAliasSD1)->D1_DTDIGIT <= dDataFim
				AAdd(aKarLocal,{'NF ENTRADA',(cAliasSD1)->D1_DTDIGIT,(cAliasSD1)->D1_TES,(cAliasSD1)->D1_CF,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_QUANT,0,(cAliasSD1)->D1_NUMSEQ,'2'})
			EndIf

		EndIf

		(cAliasSD1)->( dbSkip() )

	Enddo

	(cAliasSD1)->( DbCloseArea())

	// Movimento do SD2
	dbSelectArea('SF2')
	dbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

	cQuery := " SELECT D2_DOC,"
	cQuery +=        " D2_SERIE,"
	cQuery +=        " D2_CLIENTE,"
	cQuery +=        " D2_LOJA,"
	cQuery +=        " D2_ORIGLAN,"
	cQuery +=        " D2_EMISSAO,"
	cQuery +=        " D2_TES,"
	cQuery +=        " D2_CF,"
	cQuery +=        " D2_QUANT,"
	cQuery +=        " D2_NUMSEQ"
	cQuery +=  " FROM "+RetSqlName("SD2")+" SD2,"
	cQuery +=           RetSqlName("SF4")+" SF4"
	cQuery += " WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"
	cQuery +=   " AND SD2.D2_COD     = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD2.D2_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF4.F4_FILIAL  = '"+xFilial("SF4")+"'"
	cQuery +=   " AND SF4.F4_CODIGO  = SD2.D2_TES"
	cQuery +=   " AND SF4.F4_ESTOQUE = 'S'"
	cQuery +=   " AND SF4.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D2_EMISSAO,D2_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD2,.F.,.T.)
	TcSetField(cAliasSD2,'D2_EMISSAO','D')

	While !(cAliasSD2)->( Eof() )

		If SF2->( dbSeek(xFilial('SF2')+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA) )

			If (cAliasSD2)->D2_ORIGLAN <> 'LF' .AND. (cAliasSD2)->D2_EMISSAO >= dDataIni .AND. (cAliasSD2)->D2_EMISSAO <= dDataFim
				AAdd(aKarLocal,{'NF SAIDA',(cAliasSD2)->D2_EMISSAO,(cAliasSD2)->D2_TES,(cAliasSD2)->D2_CF,(cAliasSD2)->D2_DOC,(cAliasSD2)->D2_QUANT,0,(cAliasSD2)->D2_NUMSEQ,'2'})
			EndIf

		EndIf

		(cAliasSD2)->( dbSkip() )

	Enddo

	(cAliasSD2)->( dbCloseArea())

	// Movimento do SD3
	cQuery := " SELECT D3_EMISSAO,"
	cQuery +=        " D3_TM,"
	cQuery +=        " D3_CF,"
	cQuery +=        " D3_DOC,"
	cQuery +=        " D3_QUANT,"
	cQuery +=        " D3_NUMSEQ"
	cQuery +=   " FROM "+RetSqlName("SD3")+" SD3"
	cQuery += " WHERE SD3.D3_FILIAL   = '"+xFilial("SD3")+"'"
	cQuery +=   " AND SD3.D3_COD      = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD3.D3_LOCAL    = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD3.D3_EMISSAO >= '"+DtoS(dDataIni)+"'"
	cQuery +=   " AND SD3.D3_EMISSAO <= '"+DtoS(dDataFim)+"'"
	cQuery +=   " AND SD3.D3_ESTORNO  = ' '"
	cQuery +=   " AND SD3.D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY D3_EMISSAO,D3_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)
	TcSetField(cAliasSD3,'D3_EMISSAO','D')

	While !(cAliasSD3)->( Eof() )

		AAdd(aKarLocal,{IIF((cAliasSD3)->D3_TM$'499/999','TRANSFERENCIA',IIF((cAliasSD3)->D3_TM<='500','ENTRADA','SAIDA')),(cAliasSD3)->D3_EMISSAO,(cAliasSD3)->D3_TM,(cAliasSD3)->D3_CF,(cAliasSD3)->D3_DOC,(cAliasSD3)->D3_QUANT,0,(cAliasSD3)->D3_NUMSEQ,'2'})

		(cAliasSD3)->( dbSkip() )

	Enddo

	(cAliasSD3)->( DBCloseArea())

	AAdd(aKarLocal,{'SALDO FINAL',dDataFim,"","","",0,0,Space(6),'9'})

	//Ordena as informações de acordo com o indice
	aSort(aKarLocal,,, { |x,y| DTOS(y[2])+y[8]+y[9] > DTOS(x[2])+x[8]+x[9] } )

	nSldKar := 0
	For nCont:= 1 To Len(aKarLocal)
		If aKarLocal[nCont,1] == 'SALDO INICIAL'
			nSldKar := aKarLocal[nCont,6]
		Else
			If aKarLocal[nCont,1] == 'SALDO FINAL'
				aKarLocal[nCont,7] := nSldKar
			Else
				nSldKar += If(aKarLocal[nCont,3] <= "500",aKarLocal[nCont,6],aKarLocal[nCont,6]*-1)
				aKarLocal[nCont,7] := nSldKar
			EndIf
		EndIf
	Next

	//Atualiza Dados da Tabela Temporária
	MntCargDad('WMSKAD',aKarLocal, aFieldKAD)

Return nSldKar

//----------------------------------------------------------
/*/{Protheus.doc} SetKarLot
Montar Array Kardex Lote

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Busca Dados para gerar o Kardex por Lote do Produto

/*/
//----------------------------------------------------------
Static Function SetKarLot()
Local nSaldo := 0
Local nCont  := 0
Local cAliasTRB  := GetNextAlias()
Local cAliasSBJ  := GetNextAlias()
Local cAliasSD5  := GetNextAlias()
Local dUltFech   := GetUltFech()
Local dDataIni   := dUltFech + 1
Local dDataFim   := dDataBase
Local aKarLote   := {}

	dbSelectArea('SD5')

	// Identifica os Lotes
	cQuery := "SELECT DISTINCT BJ_LOTECTL AS LOTECTL,"
	cQuery +=                " BJ_NUMLOTE AS NUMLOTE"
	cQuery +=  " FROM "+RetSqlName("SBJ")+" SBJ"
	cQuery += " WHERE SBJ.BJ_FILIAL  = '"+xFilial("SBJ")+"'"
	cQuery +=   " AND SBJ.BJ_COD     = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SBJ.BJ_LOCAL   = '"+SB2->B2_LOCAL+"' "
	cQuery +=   " AND SBJ.BJ_DATA    = '"+DtoS(dUltFech)+"'"
	cQuery +=   " AND SBJ.BJ_QINI   <> 0"
	cQuery +=   " AND SBJ.D_E_L_E_T_ = ' '"
	cQuery += " UNION "
	cQuery += "SELECT DISTINCT D5_LOTECTL AS LOTECTL,"
	cQuery +=                " D5_NUMLOTE AS NUMLOTE"
	cQuery +=  " FROM "+RetSqlName("SD5")+" SD5"
	cQuery += " WHERE SD5.D5_FILIAL  = '"+xFilial("SD5")+"'"
	cQuery +=   " AND SD5.D5_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD5.D5_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD5.D5_DATA   >= '"+DtoS(dDataIni)+"'"
	cQuery +=   " AND SD5.D5_DATA   <= '"+DtoS(dDataFim)+"'"
	cQuery +=   " AND SD5.D5_ESTORNO = ' '"
	cQuery +=   " AND SD5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasTRB,.F.,.T.)

	While !(cAliasTRB)->( Eof() )

		// Saldo Final
		AAdd(aKarLote,{'SALDO FINAL',dDataFim,Space(len(SD5->D5_ORIGLAN)),Space(Len(SD5->D5_DOC)),(cAliasTRB)->LOTECTL,(cAliasTRB)->NUMLOTE,CTOD('  /  /  '),0,0,Space(Len(SD5->D5_NUMSEQ)),'9'})

		// Movimento do SBJ
		cQuery := "SELECT BJ_LOTECTL,"
		cQuery +=       " BJ_NUMLOTE,"
		cQuery +=       " BJ_DTVALID,"
		cQuery +=       " SUM(BJ_QINI) AS BJ_QINI"
		cQuery +=  " FROM "+RetSqlName("SBJ")+" SBJ"
		cQuery += " WHERE SBJ.BJ_FILIAL  = '"+xFilial("SBJ")+"'"
		cQuery +=   " AND SBJ.BJ_COD     = '"+SB2->B2_COD+"'"
		cQuery +=   " AND SBJ.BJ_LOCAL   = '"+SB2->B2_LOCAL+"'"
		cQuery +=   " AND SBJ.BJ_LOTECTL = '"+(cAliasTRB)->LOTECTL+"'"
		cQuery +=   " AND SBJ.BJ_NUMLOTE = '"+(cAliasTRB)->NUMLOTE+"'"
		cQuery +=   " AND SBJ.BJ_DATA    = '"+DtoS(dUltFech)+"'"
		cQuery +=   " AND SBJ.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY BJ_LOTECTL,BJ_NUMLOTE,BJ_DTVALID"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBJ,.F.,.T.)
		TcSetField(cAliasSBJ,'BJ_DTVALID','D')
		If !(cAliasSBJ)->(Eof())
			//Saldo Inicial
			AAdd(aKarLote,{'SALDO INICIAL',dUltFech,Space(len(SD5->D5_ORIGLAN)),Space(Len(SD5->D5_DOC)),(cAliasTRB)->LOTECTL,(cAliasTRB)->NUMLOTE,(cAliasSBJ)->BJ_DTVALID,(cAliasSBJ)->BJ_QINI,0,Space(Len(SD5->D5_NUMSEQ)),'1'})
		EndIf
		(cAliasSBJ)->( DbCloseArea() )
		
		(cAliasTRB)->( dbSkip() )
	Enddo
	(cAliasTRB)->( DbCloseArea() )

	// Movimento do SD5
	cQuery := "SELECT D5_DATA,"
	cQuery +=       " D5_ORIGLAN,"
	cQuery +=       " D5_DOC,"
	cQuery +=       " D5_LOTECTL,"
	cQuery +=       " D5_NUMLOTE,"
	cQuery +=       " D5_DTVALID,"
	cQuery +=       " D5_QUANT,"
	cQuery +=       " D5_NUMSEQ"
	cQuery +=  " FROM "+RetSqlName("SD5")+" SD5"
	cQuery += " WHERE SD5.D5_FILIAL  = '"+xFilial("SD5")+"'"
	cQuery +=   " AND SD5.D5_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SD5.D5_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SD5.D5_DATA   >= '"+DtoS(dDataIni)+"'"
	cQuery +=   " AND SD5.D5_DATA   <= '"+DtoS(dDataFim)+"'"
	cQuery +=   " AND SD5.D5_ESTORNO = ' '"
	cQuery +=   " AND SD5.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D5_DATA,D5_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD5,.F.,.T.)
	TcSetField(cAliasSD5,'D5_DATA'   ,'D')
	TcSetField(cAliasSD5,'D5_DTVALID','D')

	While !(cAliasSD5)->( Eof() )
		AAdd(aKarLote,{IIF((cAliasSD5)->D5_ORIGLAN$'499/999','TRANSFERENCIA',IIF((cAliasSD5)->D5_ORIGLAN<='500','ENTRADA','SAIDA')),(cAliasSD5)->D5_DATA,(cAliasSD5)->D5_ORIGLAN,(cAliasSD5)->D5_DOC,(cAliasSD5)->D5_LOTECTL,(cAliasSD5)->D5_NUMLOTE,(cAliasSD5)->D5_DTVALID,(cAliasSD5)->D5_QUANT,0,(cAliasSD5)->D5_NUMSEQ,'2'})
		(cAliasSD5)->( dbSkip() )
	Enddo
	(cAliasSD5)-> ( DbCloseArea() )

	//Ordena as informações pelo indice
	// Para facilitar os calculos sera ordenado da seguinte forma
	// Ordem Saldo Inicial
	//       Movimentações
	//       Saldo Final

	aSort(aKarLote,,, { |x,y| y[5]+y[6]+y[11]+y[10]+y[3] > x[5]+x[6]+x[11]+x[10]+x[3] } )

	nSldKlt := 0
	nSaldo  := 0

	For nCont:= 1 To Len(aKarLote)
		Do Case
			Case aKarLote[nCont,1] == "SALDO INICIAL"
				nSaldo            := aKarLote[nCont,8]
				aKarLote[nCont,9] := nSaldo
			Case aKarLote[nCont,1] $ "ENTRADA/SAIDA/TRANSFERENCIA"
				nSaldo            += IF(aKarLote[nCont,3] <= "500" .OR. Substr(aKarLote[nCont,3],1,2) $ 'DE/PR/MA',aKarLote[nCont,8],aKarLote[nCont,8]*-1)
				aKarLote[nCont,9] := nSaldo
			Case aKarLote[nCont,1] == "SALDO FINAL"
				aKarLote[nCont,9] := nSaldo
				aKarLote[nCont,11]:= '0'
				nSldKlt           += nSaldo
		EndCase
	Next

	//Reordena as informações pelo indice
	// Para permitir o agrupamento será reordenado da seguinte forma
	// Ordem Saldo Final
	//       Saldo Inicial
	//       Movimentações
	aSort(aKarLote,,, { |x,y| y[5]+y[6]+y[11]+y[10]+y[3] > x[5]+x[6]+x[11]+x[10]+x[3] } )

	//Atualiza Dados da Tabela Temporária
	MntCargDad('WMSKLT',aKarLote, aFieldKLT)


Return nSldKlt

//----------------------------------------------------------
/*/{Protheus.doc} SetKarEnd
Montar Array Kardex Endereço

@author  Alexsander Burigo Corrêa
@version P11
@Since	  16/05/12
@obs	  Busca Dados para gerar o Kardex por Endereço do Produto

/*/
//----------------------------------------------------------
Static Function SetKarEnd()
Local nSaldo     := 0
Local nCont      := 0
Local cAliasTRB  := GetNextAlias()
Local cAliasSBK  := GetNextAlias()
Local cAliasSDB  := GetNextAlias()
Local dUltFech   := GetUltFech()
Local dDataIni   := dUltFech + 1
Local dDataFim   := dDataBase
Local aKarEnde   := {}

	dbSelectArea('SDB')

	// Identifica os Enderecos
	cQuery := "SELECT DISTINCT BK_LOCALIZ AS LOCALIZ,"
	cQuery +=                " BK_NUMSERI AS NUMSERI,"
	cQuery +=                " BK_LOTECTL AS LOTECTL,"
	cQuery +=                " BK_NUMLOTE AS NUMLOTE"
	cQuery +=  " FROM "+RetSqlName("SBK")+" SBK"
	cQuery += " WHERE SBK.BK_FILIAL  = '"+xFilial("SBK")+"'"
	cQuery +=   " AND SBK.BK_COD     = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SBK.BK_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SBK.BK_DATA    = '"+DtoS(dUltFech)+"'"
	cQuery +=   " AND SBK.BK_QINI   <> 0"
	cQuery +=   " AND SBK.D_E_L_E_T_ = ' '"
	cQuery += " UNION "
	cQuery += "SELECT DISTINCT DB_LOCALIZ AS LOCALIZ,"
	cQuery +=                " DB_NUMSERI AS NUMSERI,"
	cQuery +=                " DB_LOTECTL AS LOTECTL,"
	cQuery +=                " DB_NUMLOTE AS NUMLOTE "
	cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
	cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND SDB.DB_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SDB.DB_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SDB.DB_DATA   >= '"+DtoS(dDataIni)+"'"
	cQuery +=   " AND SDB.DB_DATA   <= '"+DtoS(dDataFim)+"'"
	cQuery +=   " AND SDB.DB_ATUEST  = 'S'"
	cQuery +=   " AND SDB.DB_ESTORNO = ' '"
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
	cQuery += " UNION "
	cQuery += "SELECT DISTINCT BF_LOCALIZ AS LOCALIZ,"
	cQuery +=                " BF_NUMSERI AS NUMSERI,"
	cQuery +=                " BF_LOTECTL AS LOTECTL,"
	cQuery +=                " BF_NUMLOTE AS NUMLOTE"
	cQuery +=  " FROM "+RetSqlName("SBF")+" SBF"
	cQuery += " WHERE SBF.BF_FILIAL  = '"+xFilial("SBF")+"'"
	cQuery +=   " AND SBF.BF_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SBF.BF_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SBF.BF_QUANT  <> 0"
	cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery), cAliasTRB,.F.,.T.)

	While !(cAliasTRB)->( Eof() )
		// Saldo Final
		AAdd(aKarEnde,{'SALDO FINAL'  ,dDataFim,Space(len(SDB->DB_TM)),Space(len(SDB->DB_DOC)),(cAliasTRB)->LOCALIZ,(cAliasTRB)->NUMSERI,(cAliasTRB)->LOTECTL,(cAliasTRB)->NUMLOTE,0,0,space(len(SDB->DB_NUMSEQ)),'9'})

		// Movimento do SBK
		cQuery := "SELECT BK_LOCALIZ,"
		cQuery +=       " BK_NUMSERI,"
		cQuery +=       " BK_LOTECTL,"
		cQuery +=       " BK_NUMLOTE,"
		cQuery +=       " SUM(BK_QINI) AS BK_QINI"
		cQuery +=  " FROM "+RetSqlName("SBK")+" SBK"
		cQuery += " WHERE SBK.BK_FILIAL  = '"+xFilial("SBK")+"'"
		cQuery +=   " AND SBK.BK_COD     = '"+SB2->B2_COD+"'"
		cQuery +=   " AND SBK.BK_LOCAL   = '"+SB2->B2_LOCAL+"'"
		cQuery +=   " AND SBK.BK_LOTECTL = '"+(cAliasTRB)->LOTECTL+"'"
		cQuery +=   " AND SBK.BK_NUMLOTE = '"+(cAliasTRB)->NUMLOTE+"'"
		cQuery +=   " AND SBK.BK_LOCALIZ = '"+(cAliasTRB)->LOCALIZ+"'"
		cQuery +=   " AND SBK.BK_NUMSERI = '"+(cAliasTRB)->NUMSERI+"'"
		cQuery +=   " AND SBK.BK_DATA    = '"+DtoS(dUltFech)+"'"
		cQuery +=   " AND SBK.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY BK_LOCALIZ,BK_NUMSERI,BK_LOTECTL,BK_NUMLOTE"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBK,.F.,.T.)
		If !(cAliasSBK)->(Eof())
			// Saldo Inicial
			AAdd(aKarEnde,{'SALDO INICIAL',dUltFech,Space(len(SDB->DB_TM)),Space(len(SDB->DB_DOC)),(cAliasTRB)->LOCALIZ,(cAliasTRB)->NUMSERI,(cAliasTRB)->LOTECTL,(cAliasTRB)->NUMLOTE,(cAliasSBK)->BK_QINI,0,space(len(SDB->DB_NUMSEQ)),'1'})
		EndIf
		(cAliasSBK)->( dbCloseArea() )

		(cAliasTRB)->( dbSkip() )
	Enddo
	(cAliasTRB)->( dbCloseArea() )

	// Movimento do SDB
	cQuery := "SELECT DB_DATA,"
	cQuery +=       " DB_TM,"
	cQuery +=       " DB_DOC,"
	cQuery +=       " DB_LOCALIZ,"
	cQuery +=       " DB_NUMSERI,"
	cQuery +=       " DB_LOTECTL,"
	cQuery +=       " DB_NUMLOTE,"
	cQuery +=       " DB_QUANT,"
	cQuery +=       " DB_NUMSEQ "
	cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
	cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND SDB.DB_PRODUTO = '"+SB2->B2_COD+"'"
	cQuery +=   " AND SDB.DB_LOCAL   = '"+SB2->B2_LOCAL+"'"
	cQuery +=   " AND SDB.DB_DATA   >= '"+DtoS(dDataIni)+"'"
	cQuery +=   " AND SDB.DB_DATA   <= '"+DtoS(dDataFim)+"'"
	cQuery +=   " AND SDB.DB_ESTORNO = ' '"
	cQuery +=   " AND SDB.DB_ATUEST  = 'S'"
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY DB_DATA,DB_NUMSEQ"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)
	TcSetField(cAliasSDB,'DB_DATA','D')

	While !(cAliasSDB)->( Eof() )
		AAdd(aKarEnde,{IIF((cAliasSDB)->DB_TM $ '499/999','TRANSFERENCIA',IIF((cAliasSDB)->DB_TM <= '500','ENTRADA','SAIDA')),(cAliasSDB)->DB_DATA,(cAliasSDB)->DB_TM,(cAliasSDB)->DB_DOC,(cAliasSDB)->DB_LOCALIZ,(cAliasSDB)->DB_NUMSERI,(cAliasSDB)->DB_LOTECTL,(cAliasSDB)->DB_NUMLOTE,(cAliasSDB)->DB_QUANT,0,(cAliasSDB)->DB_NUMSEQ,'2'})
		(cAliasSDB)->( dbSkip() )
	Enddo
	(cAliasSDB)->( DBCloseArea() )

	//Ordena as informações pelo indice
	// Para facilitar os calculos sera ordenado da seguinte forma
	// Ordem Saldo Inicial
	//       Movimentações
	//       Saldo Final
	aSort(aKarEnde,,, { |x,y| y[5]+y[6]+y[7]+y[8]+y[12]+y[11]+y[3] > x[5]+x[6]+x[7]+x[8]+x[12]+x[11]+x[3] } )

	//Atualiza Saldos Movimentos
	nSaldo  := 0
	nSldKed := 0

	For nCont:= 1 To Len(aKarEnde)
		Do Case
			Case aKarEnde[nCont,1] == "SALDO INICIAL"
				nSaldo             := aKarEnde[nCont,9]
				aKarEnde[nCont,10] := nSaldo
			Case aKarEnde[nCont,1] $ "ENTRADA/SAIDA/TRANSFERENCIA"
				nSaldo             += IF(aKarEnde[nCont,3] <= "500" .OR. Substr(aKarEnde[nCont,3],1,2) $ 'DE/PR/MA',aKarEnde[nCont,9],aKarEnde[nCont,9]*-1)
				aKarEnde[nCont,10] := nSaldo
			Case aKarEnde[nCont,1] == "SALDO FINAL"
				aKarEnde[nCont,10] := nSaldo
				aKarEnde[nCont,12] := '0'
				nSldKed            += nSaldo
		EndCase
	Next

	//Reordena as informações pelo indice
	// Para permitir o agrupamento será reordenado da seguinte forma
	// Ordem Saldo Final
	//       Saldo Inicial
	//       Movimentações
	aSort(aKarEnde,,, { |x,y| y[5]+y[6]+y[7]+y[8]+y[12]+y[11]+y[3]+Str(y[10]) > x[5]+x[6]+x[7]+x[8]+x[12]+x[11]+x[3]+Str(x[10]) } )

	//Atualiza dados tabela temporária
	MntCargDad('WMSKEN',aKarEnde,aFieldKEN )

Return nSldKed