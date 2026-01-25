#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA411.CH" 

#DEFINE WMSA41101 "WMSA41101"
#DEFINE WMSA41102 "WMSA41102"
#DEFINE WMSA41103 "WMSA41103"
#DEFINE WMSA41104 "WMSA41104"
#DEFINE WMSA41105 "WMSA41105"
#DEFINE WMSA41106 "WMSA41106"
#DEFINE WMSA41107 "WMSA41107"
#DEFINE WMSA41108 "WMSA41108"
#DEFINE WMSA41109 "WMSA41109"
#DEFINE WMSA41110 "WMSA41110"
#DEFINE WMSA41111 "WMSA41111"
#DEFINE WMSA41112 "WMSA41112"
#DEFINE WMSA41113 "WMSA41113"
#DEFINE WMSA41114 "WMSA41114"
#DEFINE WMSA41115 "WMSA41115"
#DEFINE WMSA41116 "WMSA41116"
#DEFINE WMSA41117 "WMSA41117"
#DEFINE WMSA41118 "WMSA41118"
#DEFINE WMSA41119 "WMSA41119"
#DEFINE WMSA41120 "WMSA41120"
#DEFINE WMSA41121 "WMSA41121"
#DEFINE WMSA41122 ""
#DEFINE WMSA41123 ""
#DEFINE WMSA41124 ""
#DEFINE WMSA41125 ""
#DEFINE WMSA41126 ""
#DEFINE WMSA41127 ""
#DEFINE WMSA41128 ""
#DEFINE WMSA41129 ""
#DEFINE WMSA41130 ""
#DEFINE WMSA41131 ""
#DEFINE WMSA41132 "WMSA41132"
#DEFINE WMSA41133 "WMSA41133"
#DEFINE WMSA41134 "WMSA41134"

#DEFINE STS_PENDENTE '1' // Pendente
#DEFINE STS_SEP_ANDM '2' // Separação em Andamento
#DEFINE STS_AGU_COFC '3' // Aguardando Conferência
#DEFINE STS_COF_ANDM '4' // Conferência em Andamento
#DEFINE STS_AGU_DIST '5' // Aguardando Dist. Separação
#DEFINE STS_DIS_ANDM '6' // Dist. Separação em Andamento
#DEFINE STS_AGU_MNTV '7' // Aguardando Mont. Volume
#DEFINE STS_MNT_ANDM '8' // Mont. Volume em Andamento
#DEFINE STS_AGU_LIBF '9' // Pendente Liberação
#DEFINE STS_AGU_FATU 'A' // Liberado p/ Faturamento
#DEFINE STS_FAT_REAL 'B' // Faturamento Realizado

Static lWmsNew   := .F.
Static oBrowse   := Nil
Static oTempTab  := Nil
Static oTempSC9  := Nil
Static cAliasTMP := Nil
Static cSituacao := "1"
Static oBrwD00, oBrwSC9
Static lHasCofCnv := .T.
Static lHasDisSep := .F.
Static lHasMntVol := .T.
Static lHasCofExp := .T.

//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Monitor do processo de expedicao
@author  Evaldo Cevinscki Jr.
@version P12
@Since   06/08/12
@version 1.0
@obs  Monitor Expedicao - WMS
/*/
//----------------------------------------------------------
Function WMSA411()
Local aColsSX3 := {}
Local aBrwCols := {}
Local aFields  := {}
Local aIndex   := {}
Local aSeek    := {}
Local aArqTab  := {}
Local aArqSC9  := {}
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela (Default = 10 segundos)
Local aColQtd  := {}
Local aTamSx3  := {}

	lWmsNew  := SuperGetMV("MV_WMSNEW", .F., .F.)
	lHasDisSep := lWmsNew

	If !Pergunte('WMSA410',.T.)
		Return Nil
	EndIf

	//Pergunte('WMSP410',.F.)
	//lHasCofCnv := MV_PAR01
	//lHasDisSep := MV_PAR02
	//lHasMntVol := MV_PAR03
	//lHasCofExp := MV_PAR04

	//----------------------------------------------------------
	// Monta tabela temporaria Browse Inicial
	//----------------------------------------------------------
	//+--------------------------------------------------------------+
	//| IMPORTANTE - Não trocar a ordem dos campos no Array aArqTab  | 
	//|              e aArqSC9 pois eles são na mesma ordem da query |
	//+--------------------------------------------------------------+
	BuscarSX3("DCF_CARGA",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_CARGA }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, "TMP_CARGA", {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_CARGA",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_CARGA","C",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	BuscarSX3("C9_PEDIDO",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_PEDIDO }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, "TMP_PEDIDO", {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_PEDIDO",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_PEDIDO","C",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	BuscarSX3("C9_CLIENTE",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_CLIENT }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, "TMP_CLIENT", {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_CLIENT",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_CLIENT","C",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	BuscarSX3("C9_LOJA",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_LOJCLI }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, "TMP_LOJCLI", {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_LOJCLI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_LOJCLI","C",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	aTamSx3 := TamSx3("C9_IDDCF")
	AAdd(aArqSC9, {"TMP_IDDCF","C",aTamSx3[1],aTamSx3[2]})

	BuscarSX3("C9_DATENT",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_DATENT }, "D", aColsSX3[2], 0, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_DATENT",aColsSX3[1],"D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_DATENT","D",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	BuscarSX3("C9_DATALIB",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_DATLIB }, "D", aColsSX3[2], 0, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_DATLIB",aColsSX3[1],"D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_DATLIB","D",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	BuscarSX3("C9_ENDPAD",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_ENDPAD }, "C", aColsSX3[2], 0, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_ENDPAD",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_ENDPAD","C",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	// Quantidade liberada do pedido de venda
	BuscarSX3("C9_QTDLIB",,aColsSX3); aColQtd := AClone(aColsSX3)
	AAdd(aArqTab ,{"TMP_QTDLIB","N",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	// Números do pedido de venda
	AAdd(aArqTab ,{"TMP_NROPED","N",10,0})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))
	AAdd(aArqTab ,{"TMP_NROFAT","N",10,0})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))
	AAdd(aArqTab ,{"TMP_NROLIB","N",10,0})
	AAdd(aArqSC9, AClone(aArqTab[Len(aArqTab)]))

	// Colunas de perccentuais das quantidades
	Aadd(aBrwCols,{STR0024,{|| CalPerPrc((cAliasTMP)->TMP_CODSEP, (cAliasTMP)->TMP_ORISEP, (cAliasTMP)->TMP_QTDSEP) }, "C", Nil, 2, 6, 0, Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil }) // % Separação
	If lHasCofCnv
		Aadd(aBrwCols,{STR0025,{|| CalPerPrc((cAliasTMP)->TMP_CODCOC, (cAliasTMP)->TMP_ORICOC, (cAliasTMP)->TMP_QTDCOC) }, "C", Nil, 2, 6, 0, Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil }) // % Conf. Cnv.
	EndIf
	If lWmsNew .And. lHasDisSep // Distribuição da separação só tem no novo WMS
		Aadd(aBrwCols,{STR0026,{|| CalPerPrc((cAliasTMP)->TMP_CODDIS, (cAliasTMP)->TMP_ORIDIS, (cAliasTMP)->TMP_QTDDIS) }, "C", Nil, 2, 6, 0, Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil }) // % Dist. Sep.
	EndIf
	If lHasMntVol
		Aadd(aBrwCols,{STR0027,{|| CalPerPrc((cAliasTMP)->TMP_CODMNT, (cAliasTMP)->TMP_ORIVOL, (cAliasTMP)->TMP_QTDVOL) }, "C", Nil, 2, 6, 0, Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil }) // % Mont. Vol.
	EndIf
	If lHasCofExp
		Aadd(aBrwCols,{STR0028,{|| CalPerPrc((cAliasTMP)->TMP_CODEXP, (cAliasTMP)->TMP_ORICOF, (cAliasTMP)->TMP_QTDCOF) }, "C", Nil, 2, 6, 0, Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil }) // % Conf. Exp.
	EndIf
	// Separação via Convocação
	AAdd(aArqTab ,{"TMP_CODSEP","C",6,0})
	AAdd(aArqTab ,{"TMP_ORISEP","N",aColQtd[3],aColQtd[4]})
	AAdd(aArqTab ,{"TMP_QTDSEP","N",aColQtd[3],aColQtd[4]})
	// Conferência via Convocação
	If lHasCofCnv
		AAdd(aArqTab ,{"TMP_CODCOC","C",6,0})
		AAdd(aArqTab ,{"TMP_ORICOC","N",aColQtd[3],aColQtd[4]})
		AAdd(aArqTab ,{"TMP_QTDCOC","N",aColQtd[3],aColQtd[4]})
	EndIf
	If lWmsNew .And. lHasDisSep // Distribuição da separação só tem no novo WMS
		BuscarSX3("D0D_CODDIS",,aColsSX3)
		Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_CODDIS }, "C", aColsSX3[2], 0, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
		AAdd(aFields ,{"TMP_CODDIS",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
		AAdd(aArqTab ,{"TMP_CODDIS","C",aColsSX3[3],aColsSX3[4]})
		AAdd(aArqTab ,{"TMP_ORIDIS","N",aColQtd[3],aColQtd[4]})
		AAdd(aArqTab ,{"TMP_QTDDIS","N",aColQtd[3],aColQtd[4]})
	EndIf
	// Montagem de Volumes
	If lHasMntVol
		BuscarSX3("DCS_CODMNT",,aColsSX3)
		Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_CODMNT }, "C", aColsSX3[2], 0, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
		AAdd(aFields ,{"TMP_CODMNT",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
		AAdd(aArqTab ,{"TMP_CODMNT","C",aColsSX3[3],aColsSX3[4]})
		AAdd(aArqTab ,{"TMP_ORIVOL","N",aColQtd[3],aColQtd[4]})
		AAdd(aArqTab ,{"TMP_QTDVOL","N",aColQtd[3],aColQtd[4]})
	EndIf
	// Conferência de expedição
	If lHasCofExp
		BuscarSX3("D01_CODEXP",,aColsSX3)
		Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_CODEXP }, "C", aColsSX3[2], 0, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
		AAdd(aFields ,{"TMP_CODEXP",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
		AAdd(aArqTab ,{"TMP_CODEXP","C",aColsSX3[3],aColsSX3[4]})
		AAdd(aArqTab ,{"TMP_ORICOF","N",aColQtd[3],aColQtd[4]})
		AAdd(aArqTab ,{"TMP_QTDCOF","N",aColQtd[3],aColQtd[4]})
	EndIf

	AAdd(aSeek ,{ RTrim(aBrwCols[2,1]), {;
		{"",aBrwCols[2,3], aBrwCols[2,6], aBrwCols[2,7], aBrwCols[2,1], aBrwCols[2,4]}};
	})

	AAdd(aSeek ,{ RTrim(aBrwCols[1,1]) + ' + ' + RTrim(aBrwCols[2,1]), {;
		{"",aBrwCols[1,3], aBrwCols[1,6], aBrwCols[1,7], aBrwCols[1,1], aBrwCols[1,4]},;
		{"",aBrwCols[2,3], aBrwCols[2,6], aBrwCols[2,7], aBrwCols[2,1], aBrwCols[2,4]};
	}})

	AAdd(aSeek ,{ RTrim(aBrwCols[3,1]) + ' + ' + RTrim(aBrwCols[4,1]) + ' + ' + RTrim(aBrwCols[2,1]), {;
		{"",aBrwCols[3,3], aBrwCols[3,6], aBrwCols[3,7], aBrwCols[3,1], aBrwCols[3,4]},;
		{"",aBrwCols[4,3], aBrwCols[4,6], aBrwCols[4,7], aBrwCols[4,1], aBrwCols[4,4]},;
		{"",aBrwCols[2,3], aBrwCols[2,6], aBrwCols[2,7], aBrwCols[2,1], aBrwCols[2,4]};
	}})

	aIndex := {"TMP_PEDIDO", "TMP_CARGA+TMP_PEDIDO", "TMP_CLIENT+TMP_LOJCLI+TMP_PEDIDO"}

	// Cria uma tabela temporária auxiliar para carregar as SC9
	CriaTabTmp(aArqSC9,{"TMP_IDDCF"},,@oTempSC9)
	// Cria a tabela temporária para ser utilizada no Browse
	CriaTabTmp(aArqTab,aIndex,@cAliasTMP,@oTempTab)
	LoadData()

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0011) // Monitor Expedição
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cAliasTMP)
	oBrowse:SetMenuDef("WMSA411")

	oBrowse:AddLegend({|| WMSA411STS() == STS_PENDENTE }, "BR_VERMELHO"    , STR0001) // Pendente
	oBrowse:AddLegend({|| cSituacao    == STS_SEP_ANDM }, "BR_AMARELO"     , STR0013) // Separação em Andamento
	If lHasCofCnv .Or. lHasCofExp
		oBrowse:AddLegend({|| cSituacao == STS_AGU_COFC }, "BR_AZUL_CLARO"  , STR0002) // Aguardando Conferência
		oBrowse:AddLegend({|| cSituacao == STS_COF_ANDM }, "BR_AZUL"        , STR0003) // Conferência em Andamento
	EndIf
	If lHasDisSep
		oBrowse:AddLegend({|| cSituacao == STS_AGU_DIST }, "BR_MARROM"      , STR0039) // Aguardando Distribuição Separação
		oBrowse:AddLegend({|| cSituacao == STS_DIS_ANDM }, "BR_VERDE_ESCURO", STR0040) // Distribuição Separação em Andamento
	EndIf
	If lHasMntVol
		oBrowse:AddLegend({|| cSituacao == STS_AGU_MNTV }, "BR_PINK"        , STR0015) // Aguardando Montagem de Volumes
		oBrowse:AddLegend({|| cSituacao == STS_MNT_ANDM }, "BR_VIOLETA"     , STR0016) // Montagem de Volumes em Andamento
	EndIf
	oBrowse:AddLegend({|| cSituacao    == STS_AGU_LIBF }, "BR_LARANJA"     , STR0017) // Aguardando Liberação p/ Faturamento
	oBrowse:AddLegend({|| cSituacao    == STS_AGU_FATU }, "BR_BRANCO"      , STR0010) // Liberado p/ Faturamento
	oBrowse:AddLegend({|| cSituacao    == STS_FAT_REAL }, "BR_VERDE"       , STR0009) // Faturamento Realizado

	oBrowse:SetColumns(aBrwCols)
	oBrowse:SetOnlyFields({})
	oBrowse:SetFieldFilter( aFields )
	oBrowse:SetUseFilter()
	oBrowse:SetSeek(/*bSeek*/,aSeek)

	oBrowse:SetTimer({|| RefreshBrw(1)}, Iif(nTime <= 0, 3600, nTime) * 1000)
	oBrowse:SetParam({|| Selecionar() })
	oBrowse:SetProfileID('1')
	oBrowse:DisableDetails()
	oBrowse:SetFixedBrowse(.T.)
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR08 < 4)})
	oBrowse:Activate()

	// Liberando a memória utilizada
	oTempSC9:Delete()
	oTempTab:Delete()
	oTempSC9 := Nil
	oTempTab := Nil
	oBrowse  := Nil
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
MenuDef - Monitor do processo de expedicao
@author  Evaldo Cevinscki Jr.
@version P12
@Since   06/08/12
@version 1.0
@obs  Monitor Expedicao - WMS
/*/
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0012 ACTION "WMS411Moni()"    OPERATION 2 ACCESS 0 // Monitor
	If lHasDisSep
		ADD OPTION aRotina TITLE STR0041 ACTION "WMS411DisS()" OPERATION 2 ACCESS 0 // Mon. Dist. Sep.
	EndIf
	If lHasMntVol
		ADD OPTION aRotina TITLE STR0042 ACTION "WMS411MntV()" OPERATION 2 ACCESS 0 // Mon. Mont. Vol.
	EndIf
	If lHasCofExp
		ADD OPTION aRotina TITLE STR0043 ACTION "WMS411CofE()" OPERATION 2 ACCESS 0 // Mon. Conf. Exp.
	EndIf
Return aRotina

/*/{Protheus.doc} LoadData
	Efetua a carga dos dados na tabela temporária criada com base nos parâmetros do pergunte
@author Jackson patrick Werka
@since  22/08/2018
@version 1.0
/*/
Static Function LoadData()
Local cQuery     := ""

	// Carrega a temporária auxiliar sumarizando por IDDCF a SC9
	cQuery += "SELECT SC9.C9_CARGA,"
	cQuery +=       " SC9.C9_PEDIDO,"
	cQuery +=       " SC9.C9_CLIENTE,"
	cQuery +=       " SC9.C9_LOJA,"
	cQuery +=       " SC9.C9_IDDCF,"
	cQuery +=       " MIN(SC9.C9_DATENT) AS C9_DATENT,"
	cQuery +=       " MIN(SC9.C9_DATALIB) AS C9_DATALIB,"
	cQuery +=       " MIN(SC9.C9_ENDPAD) AS C9_ENDPAD,"
	cQuery +=       " SUM(SC9.C9_QTDLIB) AS C9_QTDLIB,"
	cQuery +=       " COUNT(SC9.C9_FILIAL) C9_NROPED,"
	cQuery +=       " SUM(CASE WHEN SC9.C9_NFISCAL <> '"+Space(TamSX3("C9_NFISCAL")[1])+"' THEN 1 ELSE 0 END) C9_NROFAT,"
	cQuery +=       " SUM(CASE WHEN SC9.C9_BLWMS = '05' THEN 1 ELSE 0 END) C9_NROLIB"
	cQuery +=  " FROM "+RetSqlName("SC9")+" SC9"

	cQuery += " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=   " AND SC9.C9_SERVIC <> ' '"
	If !Empty(MV_PAR07) 
		If MV_PAR07 == 1 // Não faturados
			cQuery += " AND SC9.C9_NFISCAL = ' '"
		ElseIf MV_PAR07 == 2
			cQuery += " AND SC9.C9_NFISCAL <> ' '"
		EndIf
	EndIf
	If !(Empty(MV_PAR01) .And. Upper(MV_PAR02) == Replicate('Z', Len(MV_PAR02)))
		cQuery += " AND SC9.C9_CARGA >= '"+MV_PAR01+"'"
		cQuery += " AND SC9.C9_CARGA <= '"+MV_PAR02+"'"
	EndIf
	If !(Empty(MV_PAR03) .And. Upper(MV_PAR04) == Replicate('Z', Len(MV_PAR04)))
		cQuery += " AND SC9.C9_PEDIDO >= '"+MV_PAR03+"'"
		cQuery += " AND SC9.C9_PEDIDO <= '"+MV_PAR04+"'"
	EndIf
	cQuery +=   " AND SC9.C9_DATALIB >= '"+ DToS(MV_PAR05) +"'"
	cQuery +=   " AND SC9.C9_DATALIB <= '"+ DToS(MV_PAR06) +"'"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY SC9.C9_CARGA,"
	cQuery +=       " SC9.C9_PEDIDO,"
	cQuery +=       " SC9.C9_CLIENTE,"
	cQuery +=       " SC9.C9_LOJA,"
	cQuery +=       " SC9.C9_IDDCF"
	WmsQry2Tmp(Nil,oTempSC9:oStruct:aFields,cQuery,oTempSC9,.F.,.T.)

	// Carregando a temporária definitiva com base na SC9 já sumarizada
	cQuery := "SELECT SC9.TMP_CARGA AS TMP_CARGA,"
	cQuery +=       " SC9.TMP_PEDIDO AS TMP_PEDIDO,"
	cQuery +=       " SC9.TMP_CLIENT AS TMP_CLIENT,"
	cQuery +=       " SC9.TMP_LOJCLI AS TMP_LOJCLI,"
	cQuery +=       " MIN(SC9.TMP_DATENT) AS TMP_DATENT,"
	cQuery +=       " MIN(SC9.TMP_DATLIB) AS TMP_DATLIB,"
	cQuery +=       " MIN(SC9.TMP_ENDPAD) AS TMP_ENDPAD,"
	cQuery +=       " SUM(SC9.TMP_QTDLIB) AS TMP_QTDLIB,"
	cQuery +=       " SUM(SC9.TMP_NROPED) TMP_NROPED,"
	cQuery +=       " SUM(SC9.TMP_NROFAT) TMP_NROFAT,"
	cQuery +=       " SUM(SC9.TMP_NROLIB) TMP_NROLIB,"
	cQuery +=       " COALESCE(MIN(SEP.SEP_CODSEP),' ') AS TMP_CODSEP,"
	cQuery +=       " COALESCE(SUM(SEP.SEP_QTDORI),0) AS TMP_ORISEP,"
	cQuery +=       " COALESCE(SUM(SEP.SEP_QTDSEP),0) AS TMP_QTDSEP"
	If lHasCofCnv
		cQuery +=    " ,COALESCE(MIN(COF.COF_CODCOC),' ') AS TMP_CODCOC"
		cQuery +=    " ,COALESCE(SUM(COF.COF_ORICOC),0) AS TMP_ORICOC"
		cQuery +=    " ,COALESCE(SUM(COF.COF_QTDCOC),0) AS TMP_QTDCOC"
	EndIf
	If lWmsNew .And. lHasDisSep // Distribuição da separação só tem no novo WMS
		cQuery +=    " ,COALESCE(D0D.D0D_CODDIS,' ') AS TMP_CODDIS"
		cQuery +=    " ,COALESCE(D0D.D0D_QTDORI,0) AS TMP_ORIDIS"
		cQuery +=    " ,COALESCE(D0D.D0D_QTDDIS,0) AS TMP_QTDDIS"
	EndIf
	If lHasMntVol
		cQuery +=    " ,COALESCE(DCS.DCS_CODMNT,' ') AS TMP_CODMNT"
		cQuery +=    " ,COALESCE(DCS.DCS_QTORIG,0) AS TMP_ORIVOL"
		cQuery +=    " ,COALESCE(DCS.DCS_QTEMBA,0) AS TMP_QTDVOL"
	EndIf
	If lHasCofExp
		cQuery +=    " ,COALESCE(D01.D01_CODEXP,' ') AS TMP_CODEXP"
		cQuery +=    " ,COALESCE(D01.D01_QTORIG,0) AS TMP_ORICOF"
		cQuery +=    " ,COALESCE(D01.D01_QTCONF,0) AS TMP_QTDCOF"
	EndIf
	cQuery +=  " FROM "+ oTempSC9:GetRealName() +" SC9"
	cQuery +=  " LEFT JOIN ( "
	cQuery += "SELECT SC9S.TMP_IDDCF SEP_IDDCF,"
	cQuery +=       " CAST('CODSEP' AS VARCHAR(6)) AS SEP_CODSEP,"
		cQuery +=    " SUM(DCR.DCR_QUANT) SEP_QTDORI," 
	If lWmsNew
		cQuery +=    " SUM(CASE WHEN D12.D12_STATUS = '1' THEN DCR.DCR_QUANT ELSE 0 END) SEP_QTDSEP"
	Else
		cQuery +=    " SUM(CASE WHEN SDB.DB_STATUS IN ('1','M') THEN DCR.DCR_QUANT ELSE 0 END) SEP_QTDSEP"
	EndIf
	cQuery +=  " FROM "+ oTempSC9:GetRealName() +" SC9S"
	cQuery += " INNER JOIN "+RetSqlName("DCR")+" DCR"
	cQuery +=    " ON DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
	cQuery +=   " AND DCR.DCR_IDDCF = SC9S.TMP_IDDCF"
	cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
	If lWmsNew 
		cQuery += " INNER JOIN "+RetSqlName("D12")+" D12"
		cQuery +=   "  ON D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=   " AND D12.D12_IDDCF = DCR.DCR_IDORI"
		cQuery +=   " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
		cQuery +=   " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		cQuery +=   " AND D12.D12_STATUS <> '0'"
		cQuery +=   " AND D12.D12_ATUEST = '1'"
		cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
	Else
		cQuery += " INNER JOIN "+RetSqlName("SDB")+" SDB"
		cQuery +=    " ON SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_IDDCF = DCR.DCR_IDORI"
		cQuery +=   " AND SDB.DB_IDMOVTO = DCR.DCR_IDMOV"
		cQuery +=   " AND SDB.DB_IDOPERA = DCR.DCR_IDOPER"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
														" FROM "+RetSqlName("SDB")+" SDBM"+;
													  " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"+;
														 " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"+;
														 " AND SDBM.DB_DOC     = SDB.DB_DOC"+;
														 " AND SDBM.DB_SERIE   = SDB.DB_SERIE"+;
														 " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"+;
														 " AND SDBM.DB_LOJA    = SDB.DB_LOJA"+;
														 " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"+;
														 " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"+;
														 " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"+;
														 " AND SDBM.DB_ESTORNO = ' '"+;
														 " AND SDBM.DB_ATUEST  = 'N'"+;
														 " AND SDBM.D_E_L_E_T_ = ' ' )"
	EndIf
	cQuery += " GROUP BY SC9S.TMP_IDDCF) SEP"
	cQuery +=    " ON SEP.SEP_IDDCF = SC9.TMP_IDDCF"
	If lHasCofCnv
		cQuery +=  " LEFT JOIN ("
		cQuery +=   "SELECT SC9C.TMP_IDDCF COF_IDDCF,"
		cQuery +=         " CAST('COFCNV' AS VARCHAR(6)) COF_CODCOC,"
		If lWmsNew
			cQuery +=     " SUM(D12.D12_QTDMOV) COF_ORICOC,"
			cQuery +=     " SUM(D12.D12_QTDLID) COF_QTDCOC"
		Else
			cQuery +=     " SUM(SDB.DB_QUANT) COF_ORICOC,"
			cQuery +=     " SUM(SDB.DB_QTDLID) COF_QTDCOC"
		EndIf
		cQuery +=    " FROM "+ oTempSC9:GetRealName() +" SC9C"
		If lWmsNew
			cQuery += " INNER JOIN "+RetSqlName("D12")+" D12"
			cQuery +=    " ON D12.D12_FILIAL = '"+xFilial("SDC")+"'"
			cQuery +=   " AND D12.D12_IDDCF = SC9C.TMP_IDDCF"
			cQuery +=   " AND D12.D12_STATUS <> '0'"
			cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
			cQuery += " INNER JOIN "+RetSqlName("DC5")+" DC5"
			cQuery +=    " ON DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
			cQuery +=   " AND DC5.DC5_SERVIC = D12.D12_SERVIC"
			cQuery +=   " AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
			cQuery +=   " AND DC5.DC5_OPERAC = '7'"
			cQuery +=   " AND DC5.D_E_L_E_T_ = ' '"
		Else
			cQuery += " INNER JOIN "+RetSqlName("SDB")+" SDB"
			cQuery +=    " ON SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
			cQuery +=   " AND SDB.DB_IDDCF = SC9C.TMP_IDDCF"
			cQuery +=   " AND SDB.DB_ESTORNO = ' '"
			cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
			cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
			cQuery += " INNER JOIN "+RetSqlName("DC5")+" DC5"
			cQuery +=    " ON DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
			cQuery +=   " AND DC5.DC5_SERVIC = SDB.DB_SERVIC"
			cQuery +=   " AND DC5.DC5_ORDEM = SDB.DB_ORDTARE"
			cQuery +=   " AND DC5.DC5_FUNEXE = '000012'"
			cQuery +=   " AND DC5.D_E_L_E_T_ = ' '"
		EndIf
		cQuery +=  " GROUP BY SC9C.TMP_IDDCF) COF"
		cQuery +=    " ON COF.COF_IDDCF = SC9.TMP_IDDCF"
	EndIf
	If lWmsNew .And. lHasDisSep // Distribuição da separação só tem no novo WMS
		cQuery +=  " LEFT JOIN "+RetSqlName("D0J")+" D0J"
		cQuery +=  "   ON D0J.D0J_FILIAL = '"+xFilial("D0J")+"'"
		cQuery +=  "  AND D0J.D0J_IDDCF = SC9.TMP_IDDCF"
		cQuery +=  "  AND D0J.D_E_L_E_T_ = ' '"
		cQuery +=  " LEFT JOIN "+RetSqlName("D0D")+" D0D"
		cQuery +=  "   ON D0D.D0D_FILIAL = '"+xFilial("D0D")+"'"
		cQuery +=  "  AND D0D.D0D_CODDIS = D0J.D0J_CODDIS"
		cQuery +=  "  AND D0D.D0D_CARGA = SC9.TMP_CARGA"
		cQuery +=  "  AND D0D.D0D_PEDIDO = SC9.TMP_PEDIDO"
		cQuery +=  "  AND D0D.D_E_L_E_T_ = ' '"
	EndIf
	If lHasMntVol
		cQuery +=  " LEFT JOIN "+RetSqlName("D0I")+" D0I"
		cQuery +=  "   ON D0I.D0I_FILIAL = '"+xFilial("D0I")+"'"
		cQuery +=  "  AND D0I.D0I_IDDCF = SC9.TMP_IDDCF"
		cQuery +=  "  AND D0I.D_E_L_E_T_ = ' '"
		cQuery +=  " LEFT JOIN "+RetSqlName("DCS")+" DCS"
		cQuery +=  "   ON DCS.DCS_FILIAL = '"+xFilial("DCS")+"'"
		cQuery +=  "  AND DCS.DCS_CODMNT = D0I.D0I_CODMNT"
		cQuery +=  "  AND DCS.DCS_CARGA = SC9.TMP_CARGA"
		cQuery +=  "  AND DCS.DCS_PEDIDO = SC9.TMP_PEDIDO"
		cQuery +=  "  AND DCS.D_E_L_E_T_ = ' '"
	EndIf
	If lHasCofExp
		cQuery +=  " LEFT JOIN "+RetSqlName("D0H")+" D0H"
		cQuery +=  "   ON D0H.D0H_FILIAL = '"+xFilial("D0H")+"'"
		cQuery +=  "  AND D0H.D0H_IDDCF = SC9.TMP_IDDCF"
		cQuery +=  "  AND D0H.D_E_L_E_T_ = ' '"
		cQuery +=  " LEFT JOIN "+RetSqlName("D01")+" D01"
		cQuery +=  "   ON D01.D01_FILIAL = '"+xFilial("D01")+"'"
		cQuery +=  "  AND D01.D01_CODEXP = D0H.D0H_CODEXP"
		cQuery +=  "  AND D01.D01_CARGA = SC9.TMP_CARGA"
		cQuery +=  "  AND D01.D01_PEDIDO = SC9.TMP_PEDIDO"
		cQuery +=  "  AND D01.D_E_L_E_T_ = ' '"
	EndIf
	cQuery += " GROUP BY SC9.TMP_CARGA,"
	cQuery +=       " SC9.TMP_PEDIDO,"
	cQuery +=       " SC9.TMP_CLIENT,"
	cQuery +=       " SC9.TMP_LOJCLI"
	If lWmsNew .And. lHasDisSep // Distribuição da separação só tem no novo WMS
		cQuery +=    " ,D0D.D0D_CODDIS"
		cQuery +=    " ,D0D.D0D_QTDORI"
		cQuery +=    " ,D0D.D0D_QTDDIS"
	EndIf
	If lHasMntVol
		cQuery +=    " ,DCS.DCS_CODMNT"
		cQuery +=    " ,DCS.DCS_QTORIG"
		cQuery +=    " ,DCS.DCS_QTEMBA"
	EndIf
	If lHasCofExp
		cQuery +=    " ,D01.D01_CODEXP"
		cQuery +=    " ,D01.D01_QTORIG"
		cQuery +=    " ,D01.D01_QTCONF"
	EndIf
	cQuery += " ORDER BY TMP_PEDIDO, TMP_CARGA"

	WmsQry2Tmp(cAliasTMP,oTempTab:oStruct:aFields,cQuery,oTempTab,,.T.)
Return Nil

/*/{Protheus.doc} CalPerPrc
	Efetua o cálculo do percentual executado do processo
@author Jackson patrick Werka
@since  27/08/2018
@version 1.0
/*/
Static Function CalPerPrc(cKey,nTotal,nExec)
Local cRet := "N/A"
	If !Empty(cKey)
		cRet := Transform(((nExec / nTotal) * 100.00),"@E 999.99")
	EndIf
Return cRet

//-------------------------------------------------------------------//
//-----------------------------Monitor-------------------------------//
//-------------------------------------------------------------------//
Function WMS411DisS()

	If Empty((cAliasTMP)->TMP_CODDIS)
		WmsHelp(STR0029,STR0044,WMSA41109) // Não existe registro de distribuição de separação para esta Carga/Pedido. ## Selecione uma Carga/Pedido que possua este processo.
		Return 
	EndIf
	D0D->(DbSetOrder(1)) //D0D_FILIAL, D0D_CODDIS, D0D_CARGA, D0D_PEDIDO
	If D0D->(!DbSeek(xFilial("D01")+(cAliasTMP)->TMP_CODDIS+(cAliasTMP)->TMP_CARGA+(cAliasTMP)->TMP_PEDIDO))
		WmsHelp(STR0030,STR0045,WMSA41110) // Registro de distribuição de separação não encontrado. ## Verifique se o processo ainda é valido.
		Return
	EndIf
Return WMSA540MNT()

//-------------------------------------------------------------------//
//-----------------------------Monitor-------------------------------//
//-------------------------------------------------------------------//
Function WMS411MntV()

	If Empty((cAliasTMP)->TMP_CODMNT)
		WmsHelp(STR0048,STR0044,WMSA41118) // Não existe registro de montagem de volume para esta Carga/Pedido. ## Selecione uma Carga/Pedido que possua este processo.
		Return 
	EndIf
	DCS->(DbSetOrder(1)) //DCS_FILIAL, DCS_CODMNT, DCS_CARGA, DCS_PEDIDO
	If DCS->(!DbSeek(xFilial("D01")+(cAliasTMP)->TMP_CODMNT+(cAliasTMP)->TMP_CARGA+(cAliasTMP)->TMP_PEDIDO))
		WmsHelp(STR0049,STR0045,WMSA41119) // Registro de montagem de volume não encontrado. ## Verifique se o processo ainda é valido.
		Return
	EndIf
Return WMSA391MNT()

//-------------------------------------------------------------------//
//-----------------------------Monitor-------------------------------//
//-------------------------------------------------------------------//
Function WMS411CofE()

	If Empty((cAliasTMP)->TMP_CODEXP)
		WmsHelp(STR0056,STR0044,WMSA41120) // Não existe registro de conferência de expedição para esta Carga/Pedido. ## Selecione uma Carga/Pedido que possua este processo.
		Return 
	EndIf
	D01->(DbSetOrder(1)) //D01_FILIAL, D01_CODEXP, D01_CARGA, D01_PEDIDO
	If D01->(!DbSeek(xFilial("D01")+(cAliasTMP)->TMP_CODEXP+(cAliasTMP)->TMP_CARGA+(cAliasTMP)->TMP_PEDIDO))
		WmsHelp(STR0057,STR0045,WMSA41121) // Registro de conferência de expedição não encontrado. ## Verifique se o processo ainda é valido.
		Return
	EndIf
Return WMSA412MNT()

//-------------------------------------------------------------------//
//-----------------------------Monitor-------------------------------//
//-------------------------------------------------------------------//
Function WMS411Moni()
Local oSize,oDlg, oMaster, oFolder
Local aFolders := {}
Local aButtons := {}
Local aPosSize := {}
Local aCampos  := {}
Local aEstDocs := {}
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local nOpcA    := 0

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar
	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 45, .T., .F. ) //Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 70, .T., .T. ) //Adiciona enchoice
	// Dispara o calculo
	oSize:Process()
	// Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0011 FROM ; // Monitor Expedição"
	oSize:aWindSize[1],oSize:aWindSize[2] TO ;
	oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	// Cria as variáveis de memória usadas pela Enchoice
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
	             oSize:GetDimension("MASTER","COLINI"),;
	             oSize:GetDimension("MASTER","LINEND"),;
	             oSize:GetDimension("MASTER","COLEND")}

	aCampos := {"C9_CARGA","C9_PEDIDO","C9_DATENT","C9_ENDPAD"}
	// Cria as variáveis de memória para serem exibidas na tela
	_SetOwnerPrvt("C9_CARGA",(cAliasTMP)->TMP_CARGA)
	_SetOwnerPrvt("C9_PEDIDO",(cAliasTMP)->TMP_PEDIDO)
	_SetOwnerPrvt("C9_DATENT",(cAliasTMP)->TMP_DATENT)
	_SetOwnerPrvt("C9_ENDPAD",(cAliasTMP)->TMP_ENDPAD)
	oMaster := MsMGet():New("SC9",0,4,,,,aCampos,aPosSize,,4,,,,oDlg,,.T.,,,,,,,,,,.T.)
	oMaster:Disable()

	aFolders := {STR0022,STR0014} // Itens Pedido ## Endereçamento 
	
	// Monta o Objeto Folder
	aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
	             oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
	             oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
	             oSize:GetDimension("DETAIL","YSIZE")}   // Size.y
	oFolder := TFolder():New(aPosSize[1],aPosSize[2],aFolders,aFolders,oDlg,,,,.T.,.T.,aPosSize[3],aPosSize[4])

	// Monta browse do folder Produtos/Operadores
	oBrwSC9 := FWMBrowse():New()
	oBrwSC9:SetOwner(oFolder:aDialogs[1])
	oBrwSC9:SetAlias('SC9')
	oBrwSC9:SetFilterDefault( "@"+MontFiltro('SC9'))
	oBrwSC9:SetMenuDef('')
	oBrwSC9:SetProfileID('7')
	oBrwSC9:SetDescription(STR0022) // Itens Pedido
	oBrwSC9:AddLegend("SC9->C9_NFISCAL <> ' '","GREEN", STR0060) // Faturada
	oBrwSC9:AddLegend("SC9->C9_NFISCAL = ' '" ,"BLUE" , STR0061) // Não Faturada"
	oBrwSC9:DisableDetails()
	oBrwSC9:SetAmbiente(.F.)
	oBrwSC9:SetWalkThru(.F.)
	oBrwSC9:DisableReport()
	oBrwSC9:SetFixedBrowse(.T.)
	oBrwSC9:Activate()

	// Monta browse do folder enderecamento
	aEstDocs := {{ STR0018, "WMS411EEnA()" ,2,0},; // Estornar Endereçamento
					{ STR0019, "WMS411ETrA()",2,0},; // Estornar Transferência
					{ STR0020, "WMS411EEmA()" ,2,0}}  // Estornar Embarque
	oBrwD00 := FWMBrowse():New()
	oBrwD00:SetOwner(oFolder:aDialogs[2])
	oBrwD00:SetAlias('D00')
	oBrwD00:SetFilterDefault( "@"+MontFiltro('D00'))
	oBrwD00:SetMenuDef('')
	oBrwD00:SetProfileID('2')
	oBrwD00:SetDescription(STR0021) // Endereçamento
	oBrwD00:AddButton(STR0023,aEstDocs,, 2, 0) // Documento
	oBrwD00:AddButton(STR0018,"WMS411EEnP()" ,,2,0) // Estorna Endereçamento
	oBrwD00:AddButton(STR0019,"WMS411ETrP()",,2,0) // Estorna Transferência
	oBrwD00:AddButton(STR0020,"WMS411EEmP()" ,,2,0) // Estorna Embarque
	oBrwD00:AddLegend("D00_TIPEMB <> '1'", "BLUE",  STR0032) // Embarque posterior
	oBrwD00:AddLegend("D00_TIPEMB == '1'", "GREEN", STR0033) // Embarque direto
	oBrwD00:DisableDetails()
	oBrwD00:SetAmbiente(.F.)
	oBrwD00:SetWalkThru(.F.)
	oBrwD00:SetFixedBrowse(.T.)
	oBrwD00:Activate()

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| RefreshBrw(2) },oDlg)
	oTimer:Activate()
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()},,aButtons)

	// Liberando a memória utilizada
	oBrwSC9 := Nil
	oBrwD00 := Nil
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
ModelDef
@author  Evaldo Cevinscki Jr.
@version P12
@Since   06/08/12
@version 1.0
/*/
//----------------------------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oStructSC9 := FWFormStruct(1,'SC9')
Local oStructD00 := FWFormStruct(1,'D00')
Local oStructD02 := FWFormStruct(1,'D02')
Local oStructD04 := FWFormStruct(1,'D04')
Local cCodEnd    := D00->D00_CODEND
Local cCodVol    := D00->D00_CODVOL
Local aColsSx3   := {}

	// Monta Struct SC9
	oStructSC9:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStructSC9:AddField('STATUS'  ,'Legenda','STATUS' , 'C',1,0,,,,.T.,{|| .T.},,,.T.) // STATUS
	oStructSC9:AddField(BuscarSX3('C9_CARGA'  ,,aColsSX3),aColsSX3[1],'C9_CARGA'   ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStructSC9:AddField(BuscarSX3('C9_PEDIDO' ,,aColsSX3),aColsSX3[1],'C9_PEDIDO'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStructSC9:AddField(BuscarSX3('C9_DATALIB',,aColsSX3),aColsSX3[1],'C9_DATALIB' ,'D',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.)
	oStructSC9:AddField(BuscarSX3('C9_ENDPAD' ,,aColsSX3),aColsSX3[1],'C9_DATALIB' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.)
	
	oModel := MPFormModel():New('WMSA411', /*bPre*/, /*bPost*/,/*bCommit*/, /*bCancel*/)
	
	oModel:AddFields('WMSA411S0' , Nil  ,oStructSC9 , /*bPre*/, /*bPost*/, /*bLoad*/)
	
	If IsInCallStack('WMS411EEnA') .Or. IsInCallStack('WMS411ETrA') .Or. IsInCallStack('WMS411EEmA') .Or.;
		IsInCallStack('WMS411EEnP') .Or. IsInCallStack('WMS411ETrP') .Or. IsInCallStack('WMS411EEmP')
	
		// Campos Virtuais
		// Enderecamento - D00
		oStructD00:SetProperty('D00_NOPEND',MODEL_FIELD_INIT,{|| POSICIONE('DCD',1,xFilial('DCD')+D00->D00_OPEEND,'DCD_NOMFUN')})
		oStructD00:SetProperty('D00_NOPETR',MODEL_FIELD_INIT,{|| POSICIONE('DCD',1,xFilial('DCD')+D00->D00_OPEDOC,'DCD_NOMFUN')})
		oStructD00:SetProperty('D00_NOPEMB',MODEL_FIELD_INIT,{|| POSICIONE('DCD',1,xFilial('DCD')+D00->D00_OPEEMB,'DCD_NOMFUN')})
	
		oStructD00:AddField(BuscarSX3('D00_TIPEMB',,aColsSX3) ,aColsSX3[1], 'TIPOEMB', 'C',20,0,,,,.T.,{|| StaTipEmb()},,,.T.) // TIPOEMB
		oStructD00:SetProperty('D00_TIPEMB',MVC_VIEW_PICT,'@BMP')
		
		oModel:AddGrid( '411D00', 'WMSA411S0'  , oStructD00, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
		oModel:SetRelation( '411D00', {{'D00_FILIAL',"xFilial('D00')"},{'D00_CARGA','C9_CARGA'},{'D00_PEDIDO','C9_PEDIDO'}} , D00->( IndexKey(1) ) )
		oModel:GetModel( '411D00' ):SetDescription(STR0021) // Endereçamento"
	
		If IsInCallStack('WMS411EEnP') .Or. IsInCallStack('WMS411ETrP') .Or. IsInCallStack('WMS411EEmP')
			oModel:GetModel( '411D00' ):SetLoadFilter({{'D00_CODEND' ,"'"+cCodEnd+"'",1}})
			oModel:GetModel( '411D00' ):SetLoadFilter({{'D00_CODVOL' ,"'"+cCodVol+"'",1}})
		EndIf
		
		oModel:GetModel('411D00'):SetNoInsertLine( .T. )
		oModel:GetModel('411D00'):SetNoDeleteLine( .T. )
		oModel:GetModel('411D00'):SetNoUpdateLine( .T. )
		oModel:GetModel('411D00'):SetOptional( .T. )
	EndIf
	
	oModel:SetDescription(STR0012) // Monitor
	oModel:GetModel("WMSA411S0"):SetDescription(STR0055) // Expedição
	oModel:SetPrimaryKey({"C9_CARGA","C9_PEDIDO"})
	oModel:SetActivate({|oModel| ActiveMdl(oModel) })
Return oModel
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
ViewDef
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Static Function ViewDef()
Local aColsSX3 := {}
Local oView    := Nil
Local oModel   := FWLoadModel('WMSA411')

Local oStructSC9 := FWFormStruct(2,'SC9',,.F.)
Local oStructD00 := FWFormStruct(2,'D00',,.F.)
Local oStructD02 := FWFormStruct(2,'D02',,.F.)
Local oStructD04 := FWFormStruct(2,'D04',,.F.)

	// Monta Struct SC9
	oStructSC9:AddField('STATUS'  ,'01','' ,'',Nil,'GET','@BMP',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructSC9:AddField('C9_CARGA'   ,'01',BuscarSX3('C9_CARGA'  ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructSC9:AddField('C9_PEDIDO'  ,'02',BuscarSX3('C9_PEDIDO' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructSC9:AddField('C9_DATALIB' ,'03',BuscarSX3('C9_DATALIB',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructSC9:AddField('C9_ENDPAD'  ,'06',BuscarSX3('C9_ENDPAD' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	
	// Remove Campos D00
	oStructD00:RemoveField('D00_FILIAL')
	oStructD00:RemoveField('D00_OPEEND')
	oStructD00:RemoveField('D00_OPEDOC')
	oStructD00:RemoveField('D00_OPEEMB')
	
	// Remove Campos D02
	oStructD02:RemoveField('D02_FILIAL')
	
	// Remove Campos D04
	oStructD04:RemoveField('D04_FILIAL')
	oStructD04:RemoveField('D04_CODOPE')
	
	// Remove Campos SC9
	oStructSC9:RemoveField('C9_BLWMS')
	oStructSC9:RemoveField('C9_SEQCAR')
	oStructSC9:RemoveField('C9_SEQENT')
	oStructSC9:RemoveField('C9_SERIREM')
	oStructSC9:RemoveField('C9_LOTNFC')
	oStructSC9:RemoveField('C9_BLTMS')
	oStructSC9:RemoveField('C9_REGWMS')
	oStructSC9:RemoveField('C9_NUMSEQ')
	oStructSC9:RemoveField('C9_NUMCP')
	oStructSC9:RemoveField('C9_CODISS')
	oStructSC9:RemoveField('C9_RETOPER')
	oStructSC9:RemoveField('C9_DAV')
	oStructSC9:RemoveField('C9_ORDSEP')
	oStructSC9:RemoveField('C9_SOLFLG')
	oStructSC9:RemoveField('C9_IDDCF')
	oStructSC9:RemoveField('C9_ROMEMB')
	
	oStructD02:AddField('STATUS','01','' ,'',Nil,'GET','@BMP',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:CreateHorizontalBox('MASTER',0,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/)
	oView:CreateHorizontalBox('DETAIL',100)
	
	oView:AddField('WMSA411S0' ,oStructSC9)
	
	oView:CreateFolder('IDFOLDER','DETAIL')
	If IsInCallStack('WMS411EEnA') .Or. IsInCallStack('WMS411ETrA') .Or. IsInCallStack('WMS411EEmA') .Or.;
		IsInCallStack('WMS411EEnP') .Or. IsInCallStack('WMS411ETrP') .Or. IsInCallStack('WMS411EEmP')

		oView:AddSheet('IDFOLDER','IDSHEET01',STR0021) // Endereçamento
		oView:CreateHorizontalBox('DETAIL_1', 100,,,'IDFOLDER', 'IDSHEET01')
		oView:AddGrid('411D00', oStructD00)
		oView:SetOnlyView('411D00')
		oView:SetOwnerView('411D00', 'DETAIL_1')
	EndIf
	
	oView:SetOwnerView('WMSA411S0','MASTER')
	oView:SetUseCursor(.F.)
Return oView

//----------------------------------------------------------
/*/{Protheus.doc} ActiveMdl
Realiza alguma alteração no modelo
@author Amanda Rosa Vieira
@version P11
@Since  09/12/2017
@version 2.0
/*/
//----------------------------------------------------------
Static Function ActiveMdl(oModel)
	oModel:GetModel('WMSA411S0'):SetValue("STATUS", oModel:GetModel("WMSA411S0"):GetValue("STATUS"))
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Atualiza legenda do monitor
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Function WMSA411STS()
Local lHasProcExp := .F.

	cSituacao := ""
	If (cAliasTMP)->TMP_NROFAT == (cAliasTMP)->TMP_NROPED
		cSituacao := STS_FAT_REAL // Faturamento Realizado
	EndIf
	If Empty(cSituacao) .And. !Empty((cAliasTMP)->TMP_CODSEP)
		lHasProcExp := .T.
		If QtdComp((cAliasTMP)->TMP_QTDSEP) <= 0
			cSituacao := STS_PENDENTE // Penddente
	 	ElseIf QtdComp((cAliasTMP)->TMP_ORISEP) > QtdComp((cAliasTMP)->TMP_QTDSEP)
			cSituacao := STS_SEP_ANDM // Separação em Andamento
		EndIf
	EndIf
	If Empty(cSituacao) .And. lHasCofCnv .And. !Empty((cAliasTMP)->TMP_CODCOC)
		lHasProcExp := .T.
		If QtdComp((cAliasTMP)->TMP_QTDCOC) <= 0
			cSituacao := STS_AGU_COFC // Aguardando Conferência
		ElseIf QtdComp((cAliasTMP)->TMP_ORICOC) > QtdComp((cAliasTMP)->TMP_QTDCOC)
			cSituacao := STS_COF_ANDM // Conferência em Andamento
		EndIf
	EndIf
	If Empty(cSituacao) .And. lHasDisSep .And. !Empty((cAliasTMP)->TMP_CODDIS)
		lHasProcExp := .T.
		If QtdComp((cAliasTMP)->TMP_QTDDIS) <= 0
			cSituacao := STS_AGU_DIST // Aguardando Dist. Separação
		ElseIf QtdComp((cAliasTMP)->TMP_ORIDIS) > QtdComp((cAliasTMP)->TMP_QTDDIS)
			cSituacao := STS_DIS_ANDM // Dist. Separação em Andamento
		EndIf
	EndIf
	If Empty(cSituacao) .And. lHasMntVol .And. !Empty((cAliasTMP)->TMP_CODMNT)
		lHasProcExp := .T.
		If QtdComp((cAliasTMP)->TMP_QTDVOL) <= 0
			cSituacao := STS_AGU_MNTV // Aguardando Mont. Volume
		ElseIf QtdComp((cAliasTMP)->TMP_ORIVOL) > QtdComp((cAliasTMP)->TMP_QTDVOL)
			cSituacao := STS_MNT_ANDM // Mont. Volume em Andamento
		EndIf
	EndIf
	If Empty(cSituacao) .And. lHasCofExp .And. !Empty((cAliasTMP)->TMP_CODEXP)
		lHasProcExp := .T.
		If QtdComp((cAliasTMP)->TMP_QTDCOF) <= 0
			cSituacao := STS_AGU_COFC // Aguardando Conferência
		ElseIf QtdComp((cAliasTMP)->TMP_ORICOF) > QtdComp((cAliasTMP)->TMP_QTDCOF)
			cSituacao := STS_COF_ANDM // Conferência em Andamento
		EndIf
	EndIf
	If Empty(cSituacao)
		If (cAliasTMP)->TMP_NROPED == (cAliasTMP)->TMP_NROLIB
			cSituacao := STS_AGU_FATU // Liberado p/ Faturamento
		ElseIf lHasProcExp
			cSituacao := STS_AGU_LIBF // Aguardando Liberação p/ Faturamento
		Else
			cSituacao := STS_PENDENTE // Pendente
		EndIf
	EndIf

Return cSituacao

//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Funcao chamada pelo dicionario(x3_inibrw) para carregar data
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Function WMS411INIB(cAlias)
Local dRet := CtoD("  /  /  ")
	If cAlias == "D02"
		dRet := Posicione("SB8",5,xFilial("SB8")+D02->(D02_CODPRO+D02_LOTE+D02_SUBLOT),"B8_DTVALID")
	ElseIf cAlias == "D04"
		dRet := Posicione("SB8",5,xFilial("SB8")+D04->(D04_CODPRO+D04_LOTE+D04_SUBLOT),"B8_DTVALID")
	EndIf
Return dRet
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Estorna todos D00 Enderecamento a partir do browse inicial
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Function WMS411EEnA()
Local i        := 0
Local aRegs    := {}
Local lOk      := .F.
Local aAreaD00 := D00->(GetArea())
Local cSeekD00 := ""

	If ValidFatur()
		D00->(dbSetOrder(1))
		If D00->(dbSeek(cSeekD00 := xFilial("D00")+D00_CARGA+D00_PEDIDO))
			lExclui := .T.
			While D00->(!Eof()) .And. D00->(D00_FILIAL+D00_CARGA+D00_PEDIDO) == cSeekD00
				If Empty(D00->D00_CODDOC) .And. Empty(D00->D00_OPEEMB)
					D00->( aAdd(aRegs,{D00_CARGA,D00_PEDIDO,D00_CODEND,D00_CODVOL}) )
				Else
					lExclui := .F.
					WmsMessage(STR0031,WMSA41102) // Estorno não permitido, transferencia ou embarque já iniciado!
					Exit
				EndIf
				D00->(dbSkip())
			EndDo
			If lExclui
				RestArea(aAreaD00)
				FWExecView(STR0018, 'WMSA411', MODEL_OPERATION_UPDATE, , { ||  .T. },{|| RefreshBrw(2),lOk := .T. },,,{ || .T. } ) // Estornar Endereçamento
				If lOk
					Begin Transaction
						For i:= 1 to Len(aRegs)
							Estorno(2,aRegs[i][1],aRegs[i][2],aRegs[i][3],aRegs[i][4])
						Next i
					End Transaction
				EndIf
			EndIf
		Else
			WmsMessage(STR0034,WMSA41103) // Não há endereçamento a ser estornado!
		EndIf
	EndIf
	RestArea(aAreaD00)
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Estorna todos D00 Transferencia a partir do browse inicial
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Function WMS411ETrA()
Local i        := 0
Local lOk      := .F.
Local aRegs    := {}
Local aAreaD00 := D00->(GetArea())
local cSeekD00 := ""
Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
Local cLocD00 := ""

	If ValidFatur()
		D00->(dbSetOrder(1))
		If D00->(dbSeek(cSeekD00 := xFilial("D00")+D00_CARGA+D00_PEDIDO))
			lEstorna := .T.
			While D00->(!Eof()) .And. D00->(D00_FILIAL+D00_CARGA+D00_PEDIDO) == cSeekD00
				If Empty(D00->D00_OPEEMB)
					If lD00Local
						cLocD00 := D00->D00_LOCDOC
					EndIf
					lEstorna := WmsEmbD00(2,D00->D00_CARGA,D00->D00_PEDIDO,D00->D00_CODVOL,"",cLocD00,D00->D00_CODDOC) //Valida se possui embarque
					If !lEstorna
						Exit
					EndIf
					If !Empty(D00->D00_CODDOC)
						D00->( aAdd(aRegs,{D00_CARGA,D00_PEDIDO,D00_CODEND,D00_CODVOL}) )
					EndIf
				Else
					lEstorna := .F.
					WmsMessage(STR0035,WMSA41104) // Estorno não permitido, embarque já iniciado!
					Exit
				EndIf
				D00->(dbSkip())
			EndDo
			If lEstorna
				If Len(aRegs) > 0
					RestArea(aAreaD00)
					FWExecView(STR0019, 'WMSA411', MODEL_OPERATION_UPDATE, , { || .T. },{ || lOk := .T. }/*{|| RefreshBrw(2)}*/,,,{ || .T. } ) // Estornar Transferência
					If lOk
						Begin Transaction
							For i:= 1 to Len(aRegs)
								Estorno(3,aRegs[i][1],aRegs[i][2],aRegs[i][3],aRegs[i][4])
							Next i
						End Transaction
					EndIf
				Else
					WmsMessage(STR0036,WMSA41105) // Não há transferência a ser estornada!
				EndIf
			EndIf
		Else
			WmsMessage(STR0036,WMSA41106) // Não há transferência a ser estornada!
		EndIf		
	EndIf
	RestArea(aAreaD00)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Estorna todos D00 Embarque a partir do browse inicial
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Function WMS411EEmA()
Local i        := 0
Local aRegs    := {}
Local lOk      := .F.
Local lRet     := .T.
Local aAreaD00 := D00->(GetArea())
Local cSeekD00 := ""
Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
Local cLocD00 := ""

	If ValidFatur()
		D00->(dbSetOrder(1))
		If D00->( dbSeek(cSeekD00 := xFilial("D00")+D00_CARGA+D00_PEDIDO)) //
			While D00->(!Eof()) .And. D00->(D00_FILIAL+D00_CARGA+D00_PEDIDO) == cSeekD00 // SC9->(CARGA+PEDIDO)
				If !Empty(D00->D00_OPEEMB)
					D00->( aAdd(aRegs,{D00_CARGA,D00_PEDIDO,D00_CODEND,D00_CODVOL}) )

					If lD00Local
						cLocD00 := D00->D00_LOCDOC
					EndIf
					//Valida se possui embarque e nao deixar estornar se possuir D0Z. Estornar pelo WMSA413!
					lOk := WmsEmbD00(2,D00->D00_CARGA,D00->D00_PEDIDO,D00->D00_CODVOL,"",cLocD00,D00->D00_CODDOC) 
					If !lOk
						RestArea(aAreaD00)
						Return .F.
					EndIf
				EndIf
				D00->(dbSkip())
			EndDo
		
			If Len(aRegs) > 0
				RestArea(aAreaD00)
				FWExecView(STR0020, 'WMSA411', MODEL_OPERATION_UPDATE, , { ||.T. },{|| RefreshBrw(2),lOk := .T.},,,{ || .T. } ) // Estornar Embarque
				If lOk
					Begin Transaction
						For i:= 1 to Len(aRegs)
							Estorno(4,aRegs[i][1],aRegs[i][2],aRegs[i][3],aRegs[i][4])
						Next i
					End Transaction
				EndIf
			Else
				WmsMessage(STR0037,WMSA41107) // Não há embarque a ser estornado!
				lRet := .F.
			EndIf
		Else
			WmsMessage(STR0037,WMSA41108) // Não há embarque a ser estornado!
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaD00)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Estorna Enderecamento do D00 posicionado
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Function WMS411EEnP()
Local lOk     := .F.
Local aAreaD00:= D00->(GetArea())
	If ValidFatur()
		D00->(dbSetOrder(1))
		If D00->( dbSeek(xFilial("D00")+D00->(D00_CARGA+D00_PEDIDO+D00_CODEND+D00_CODVOL)) )
			If Empty(D00->D00_CODDOC) .And. Empty(D00->D00_OPEEMB)
				FWExecView(STR0024, 'WMSA411', MODEL_OPERATION_UPDATE, , { || .T. },{|| RefreshBrw(2),lOk := .T. },,,{ || .T. } ) // Estornar Conferência
				// query para filtrar pelo codigo do volume quando for informando, fazendo um While para deletar todos os pedidos do volume
				If lOk
					D00->( Estorno(1,D00_CARGA,D00_PEDIDO,D00_CODEND,D00_CODVOL) )
				EndIf
			Else
				WmsMessage(STR0031,WMSA41111) // Estorno não permitido, transferencia ou embarque já iniciado!
			EndIf
		Else
			WmsMessage(STR0038,WMSA41112) // Endereçamento não encontrado!
		EndIf
	EndIf
	RestArea(aAreaD00)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Estorna Transferencia do D00 posicionado
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Function WMS411ETrP()
Local lOk       := .F.
Local aAreaD00  := D00->(GetArea())
Local nRecnoD00 := 0
Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
Local cLocD00 := ""
	
	If ValidFatur()
		D00->(dbSetOrder(1))
		If D00->( dbSeek(xFilial("D00")+D00->(D00_CARGA+D00_PEDIDO+D00_CODEND+D00_CODVOL)) )
			If D00->D00_TIPEMB <> "1"
				If Empty(D00->D00_OPEEMB)
					If !Empty(D00->D00_CODDOC)
						If lD00Local
							cLocD00 := D00->D00_LOCDOC
						EndIf
						If WmsEmbD00(1,D00->D00_CARGA,D00->D00_PEDIDO,D00->D00_CODVOL,,cLocD00,D00->D00_CODDOC)
							nRecnoD00   := D00->(Recno())
							FWExecView(STR0046, 'WMSA411', MODEL_OPERATION_UPDATE, , { || .T. },{|| RefreshBrw(2),lOk := .T.},,,{ || .T. } ) // Estornar Transferência
							If lOk
								D00->( Estorno(3,D00_CARGA,D00_PEDIDO,D00_CODEND,D00_CODVOL) )
							EndIf
						EndIf 
					Else
						WmsMessage(STR0036,WMSA41113) // Não há transferência a ser estornada!
					EndIf
				Else
					WmsMessage(STR0035,WMSA41114) // Estorno não permitido, embarque já iniciado!
				EndIf
			Else
				D00->( Estorno(1,D00_CARGA,D00_PEDIDO,D00_CODEND,D00_CODVOL) )
			EndIf
		Else
			WmsMessage(STR0036,WMSA41115) // Não há transferência a ser estornada!
		EndIf
	EndIf
	RestArea(aAreaD00)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Estorna Embarque do D00 posicionado
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Function WMS411EEmP()
Local lOk      := .T.
Local aAreaD00 := D00->(GetArea())
Local nRecnoD00:= 0
Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
Local cLocD00 := ""

	If ValidFatur()
		D00->(dbSetOrder(1))
		If D00->( dbSeek(xFilial("D00")+D00->(D00_CARGA+D00_PEDIDO+D00_CODEND+D00_CODVOL)) )
			If !Empty(D00->D00_OPEEMB)
				If lD00Local
					cLocD00 := D00->D00_LOCDOC
				EndIf
				//Valida se possui embarque e nao deixar estornar se possuir D0Z. Estornar pelo WMSA413!
				lOk := WmsEmbD00(2,D00->D00_CARGA,D00->D00_PEDIDO,D00->D00_CODVOL,"",cLocD00,D00->D00_CODDOC) 
				If lOk
					nRecnoD00   := D00->(Recno())
					FWExecView(STR0020, 'WMSA411', MODEL_OPERATION_UPDATE, , { || .T. },{|| RefreshBrw(2), lOk := .T.},,,{ || .T. } ) // Estornar Embarque
				EndIf
				If lOk
					D00->( Estorno(4,D00_CARGA,D00_PEDIDO,D00_CODEND,D00_CODVOL) )
				EndIf
			Else
				WmsMessage(STR0037,WMSA41116) // Não há embarque a ser estornado!
			EndIf
		Else
			WmsMessage(STR0037,WMSA41117) // Não há embarque a ser estornado!
		EndIf
		RestArea(aAreaD00)
	EndIf
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Valida se o endereco informado pode receber o pedido
@author  Evaldo Cevinscki Jr.
@version P12
@Since   05/09/12
@version 1.0
/*/
//----------------------------------------------------------
Static Function VldEndDoca(cEndereco)
Local lRet := .F.

Default cEndereco := ""

	SBE->(dbSetOrder(9))
	If SBE->(dbSeek(xFilial("SBE")+cEndereco))
	
		DC8->(dbSetOrder(1))
		If DC8->(dbSeek(xFilial("DC8")+SBE->BE_ESTFIS))
			If DC8->DC8_TPESTR == "5"
				lRet := .T.
			Else
				WmsMessage(STR0050,WMSA41132) // Tipo de estrutura do endereço não permitido!
				lRet := .F.
			EndIf
		Else
			WmsMessage(STR0051,WMSA41133) // Tipo de estrutura do endereço não encontrada!
			lRet := .F.
		EndIf
	Else
		WmsMessage(STR0052,WMSA41134) // Endereço inválido!
		lRet := .F.
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Tipo Embarque
@author  Tiago F. da Silva
@version P12
@Since   14/01/14
@version 1.0
/*/
//----------------------------------------------------------
Static Function StaTipEmb()
Local cRet
	If D00->D00_TIPEMB <> "1"
		cRet := "BR_AZUL"
	ElseIf D00->D00_TIPEMB == "1"
		cRet := "BR_VERDE"
	EndIf
Return cRet

//----------------------------------------------------------
// Atualiza browses
/*/{Protheus.doc} WMSA411
Atualiza Browses
@author  Evaldo Cevinscki Jr.
@version P11 R7
@Since   03/12/12
@obs  Atualiza Browses
/*/
//----------------------------------------------------------
Static Function RefreshBrw(nRefr)
Local nPos := 0
	If nRefr == 1
		LoadData()
		If MV_PAR08 == 1
			oBrowse:Refresh(.T.)
		ElseIf MV_PAR08 == 2
			oBrowse:Refresh(.F.)
			oBrowse:GoBottom()
		ElseIf MV_PAR08 == 3
			nPos := oBrowse:At()
			oBrowse:Refresh(.F.)
			oBrowse:GoTo(nPos)
		EndIf
	ElseIf nRefr == 2
		oBrwSC9:Refresh()
		oBrwD00:Refresh()
	EndIf
Return .T.
//----------------------------------------------------------
// Atualiza browses
/*/{Protheus.doc} WMSA411
Seleciona Novo Filtro ao Browse
@author  Evaldo Cevinscki Jr.
@version P11 R7
@Since   03/12/12
@obs  Perguntas para filtro
/*/
//----------------------------------------------------------
Static Function Selecionar()
	If Pergunte('WMSA410',.T.)
		oBrowse:oTimer:lActive := (MV_PAR08 < 4)
		LoadData()
		oBrowse:Refresh(.T.)
	EndIf
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} WMSA411
Estorno de endereçamento/transferencia/embarque
@author evaldo.cevinscki
@since 21/11/2014
@version 1.0
/*/
//----------------------------------------------------------
Static Function Estorno(nAcao,cCarga,cPed,cEnd,cVol)
Local aAreaAnt := GetArea()
Local cAliasQry   := GetNextAlias()
Local cPedidos := ''
Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0

	cQuery := "SELECT D00.D00_PEDIDO, D00.D00_CODEND, D00.D00_OPEEND, D00.D00_DATEND, D00.D00_HOREND, D00.R_E_C_N_O_ nRec, D00.D00_CODVOL"
	cQuery +=  " FROM "+RetSqlName('D00')+" D00"
	cQuery += " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
	If Empty(cVol)
		cQuery +=" AND D00.D00_CARGA = '"+cCarga+"'"
		cQuery +=" AND D00.D00_PEDIDO = '"+cPed+"'"
	Else
		cQuery +=" AND D00.D00_CODVOL = '"+cVol+"'"
	EndIf
	cQuery +=   " AND D00.D00_CODEND = '"+cEnd+"'"
	cQuery +=   " AND D00.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Begin Transaction
		While (cAliasQry)->(!Eof())
			D00->(dbGoTo((cAliasQry)->nRec))
			cPedidos += If(Empty(cPedidos),'',', ') + D00->D00_PEDIDO
			RecLock("D00",.F.)
			If nAcao == 1 .Or. nAcao == 2
				D00->(DbDelete())
			ElseIf nAcao == 3
				IF lD00Local 
					D00->D00_LOCDOC := ""
				EndIf 
				D00->D00_CODDOC := ""
				D00->D00_OPEDOC := ""
				D00->D00_DATDOC := CtoD("  /  /  ")
				D00->D00_HORDOC := ""
				D00->D00_DTDOCF := CtoD("  /  /  ")
				D00->D00_HRDOCF := ""
			ElseIf nAcao == 4
				If D00->D00_TIPEMB <> "1"
					D00->D00_OPEEMB := ""
					D00->D00_DATEMB := CtoD("  /  /  ")
					D00->D00_HOREMB := ""
					D00->D00_DTEMBF := CtoD("  /  /  ")
					D00->D00_HREMBF := ""
				Else
					D00->(DbDelete())
				EndIf
			EndIf
			D00->(MsUnlock())
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	End Transaction
	RestArea(aAreaAnt)
Return .T.
/*-------------------------------------------------------------------
---ValidFatur
---Valida se existe algum item faturado, impedindo operação
---felipe.m 01/06/2015
-------------------------------------------------------------------*/
Static Function ValidFatur()
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local cQuery   := ""
Local cAliasSC9:= ""
	cQuery := " SELECT 1"
	cQuery +=   " FROM "+RetSqlName("SC9")+" SC9"
	cQuery +=  " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	If !Empty(D00->D00_CARGA)
		cQuery +=    " AND SC9.C9_CARGA = '"+D00->D00_CARGA+"'"
	EndIf
	cQuery +=    " AND SC9.C9_PEDIDO = '"+D00->D00_PEDIDO+"'"
	cQuery +=    " AND SC9.C9_NFISCAL <> ' '"
	cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
	If !Empty(D00->D00_CODVOL)
		cQuery +=    " AND EXISTS ("
		cQuery +=        " SELECT 1"
		cQuery +=          " FROM "+RetSqlName("DCU")+" DCU"
		cQuery +=         " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
		cQuery +=           " AND DCU.DCU_CODMNT = (SELECT MAX(DCS.DCS_CODMNT)"
		cQuery +=                                   " FROM "+RetSqlName("DCS")+" DCS"
		cQuery +=                                  " WHERE DCS.DCS_FILIAL = '"+xFilial("DCS")+"'"
		cQuery +=                                    " AND DCS.DCS_CARGA  = DCU.DCU_CARGA"
		cQuery +=                                    " AND DCS.DCS_PEDIDO = DCU.DCU_PEDIDO"
		cQuery +=                                    " AND DCS.D_E_L_E_T_ = ' ')"
		If !Empty(D00->D00_CARGA)
			cQuery +=           " AND DCU.DCU_CARGA = '"+D00->D00_CARGA+"'"
		EndIf
		cQuery +=           " AND DCU.DCU_PEDIDO = SC9.C9_PEDIDO"
		cQuery +=           " AND DCU.DCU_CODVOL = '"+D00->D00_CODVOL+"'"
		cQuery +=           " AND DCU.DCU_ROMEMB = SC9.C9_ROMEMB"
		cQuery +=           " AND DCU.D_E_L_E_T_ = ' '"
	EndIf
	cQuery := ChangeQuery(cQuery)
	cAliasSC9 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSC9,.F.,.T.)
	If (cAliasSC9)->(!Eof())
		WmsMessage(STR0054,WMSA41101) // Existe itens que já foram faturados!
		lRet := .F.
	EndIf
	(cAliasSC9)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

/*----------------------------------------------------------------------
---MontFiltro
---Monta filtro do browse SC9
---Amanda Vieira 05/01/2016
----------------------------------------------------------------------*/
Static Function MontFiltro(cAliasFil)
Local cQuery := ""
	If cAliasFil == 'SC9'
		cQuery := " C9_FILIAL = '"+xFilial('SC9')+"'"
		cQuery += " AND C9_CARGA = '"+(cAliasTMP)->TMP_CARGA+"'"
		cQuery += " AND C9_PEDIDO = '"+(cAliasTMP)->TMP_PEDIDO+"'"
	ElseIf cAliasFil == 'D00'
		cQuery := " D00_FILIAL = '"+xFilial('D00')+"'"
		cQuery += " AND D00_CARGA = '"+(cAliasTMP)->TMP_CARGA+"'"
		cQuery += " AND D00_PEDIDO = '"+(cAliasTMP)->TMP_PEDIDO+"'"
	EndIf
Return cQuery
