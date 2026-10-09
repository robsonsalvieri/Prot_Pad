
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFINJD38.ch'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/

STATIC cSGBD := TcGetDb()

Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "8"

/*/{Protheus.doc} OFINJD38 "Consulta de inventário PMM"

    Pontos de entrada:
		N/A		
	Parametros:
		N/A

    @author Vinicius Gati
    @since  13/05/2016
/*/
Function OFINJD38()
	Private oArrHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp    := DMS_SqlHelper():New()
	Private oUtil      := DMS_Util():New()
	Private oDpm       := DMS_Dpm():New()
	Private aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Private aMeses     := last12M()
	Private cFil       := SPACE(FWSizeFilial())
	Private oCombo     := Nil
	Private oCombo3    := Nil
	Private cErrados   := ""
	Private cOrigem    := STR0004 // Todos
	Private cPrd       := SPACE(TAMSX3("B1_COD")[1])
	Private lSBZ       := SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
	Private lEnderecado:= GetMv("MV_LOCALIZ") == "S" // Trabalha com estoque Enderecado ?
	Private aFilis    := oArrHlp:Map(oDpm:GetFiliais(), {|aEl| aEl[1] })


	FS_UILoad()
Return NIL

/*/{Protheus.doc} FS_UILoad

	@author       Vinicius Gati
	@since        13/05/2016
	@description  Desenha a interface com usuario

/*/
Static Function FS_UILoad()
	Local aObjects := {} , aPosObj := {} , aInfo := {}
	Local aFiltro  := {STR0009 /*"Padrão"*/, STR0010 /*"Não-conforme"*/, STR0004/*Todos*/}
	Local aOrigem  := {STR0004 /*Todos*/, STR0059 /*Original*/, STR0060 /*Não original*/}
	Local oGtPrd, oGtAlm
	Local aNewBot := {}
	cSizeCli       := SPACE(TAMSX3("A1_COD")[1])
	cSizeLoja      := SPACE(TAMSX3("A1_LOJA")[1])
	cProdut        := SPACE(TAMSX3("B1_COD")[1])
	cLoc           := SPACE(TAMSX3("B2_LOCAL")[1])
	cMesSel        := SPACE(10)

	AAdd( aObjects, { 01 , 26 , .T. , .F. } ) // Filtro
	AAdd( aObjects, { 01 , 10 , .T. , .T. } ) // ListBox
	aInfo   := { aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize(aInfo, aObjects,.F.)

	//"Relatório Consulta de inventário PMM"
	DEFINE MSDIALOG oWindow TITLE STR0003 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	AADD( aNewBot , {"IMPRESSAO", {|| OFJ380001H_RelatorioInventarioCSV() } , STR0032 }) //Exportar CSV
	//
	@ aPosObj[1,1] + 002 , aPosObj[1,2] TO aPosObj[1,3] , aPosObj[1,4] LABEL STR0016 /*"Filtro"*/ OF oWindow PIXEL // label bloco
	
	// Filtro Data Base
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 008 SAY STR0012 OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 040 MSCOMBOBOX oCombo   VAR cMesSel ITEMS aMeses SIZE 045,10 OF oWindow PIXEL

	// Filtro Erros Estoque
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 0090 SAY STR0011 /*Análise Est.*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 0123 MSCOMBOBOX oCombo2  VAR cErrados ITEMS aFiltro SIZE 055,10 OF oWindow PIXEL

	// Produto
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 0183 SAY STR0002 /*Produto*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 0205 MSGET oGtPrd VAR cPrd F3 "SB1" SIZE 50,08 OF oWindow PIXEL HASBUTTON

	// Almoxarifado
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 0263 SAY STR0015 /*Almoxarifado*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 0298 MSGET oGtAlm VAR cLoc F3 'NNR' SIZE 50,08 OF oWindow PIXEL HASBUTTON

	// Filiais
	aFils := oArrHlp:Map(oDpm:GetFiliais(), {|aEl| aEl[1] })
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 0355 SAY STR0013 /*Filial*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 0370 MSCOMBOBOX oCombo3 VAR cFil ITEMS aFils SIZE 050,10 OF oWindow PIXEL

	// Origem
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 0425 SAY STR0057 /*Origem*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 0450 MSCOMBOBOX oCombo4 VAR cOrigem ITEMS aOrigem SIZE 055,10 OF oWindow PIXEL
	
	@ aPosObj[1,1] + 011 , aPosObj[1,4] - 060 BUTTON oFiltra PROMPT STR0008 /*Filtrar*/ OF oWindow SIZE 50,10 PIXEL ACTION FS_Buscar()
	//
	aLBHeader := {}
	@ aPosObj[2,1] + 000 , aPosObj[2,2] + 000 LISTBOX oLb ;
		FIELDS ;
		HEADER   "", STR0013 /*Filial*/,  STR0014 /*Produto*/, STR0030 /*Grupo*/, STR0058 /*Descrição Grupo*/, STR0057 /*Origem*/, STR0031 /*Locação*/,STR0015 /*Almoxarifado*/, STR0007 /*Custo Médio*/, STR0006 /*Quantidade*/, STR0005 /*Total*/, "";
		COLSIZES 30,                 50,                   50,                30,                 100,       60,                  30,                      50,                      50,                     50,              100 , 10;
		SIZE aPosObj[2,4] - 2,aPosObj[2,3] - aPosObj[2,1] - 15 OF oWindow PIXEL ;
		ON DBLCLICK FS_DblClick()
	oLb:SetArray({})
	oLb:bLine := FS_Valores()
	//
	// Nível de atendimento geral
	//
	cValTot := "                      "
	@ aPosObj[2,3] - 011 , 10 SAY STR0001 /*"Total geral do filtro:"*/ OF oWindow PIXEL
	@ aPosObj[2,3] - 012 , 85 MSGET oGtTotNa VAR cValTot SIZE 90,08 OF oWindow PIXEL WHEN .F.
	//
	@ aPosObj[2,3] - 012 , 200 BUTTON oFiltra PROMPT STR0022 /*Ger. Relatório*/ OF oWindow SIZE 50,10 PIXEL ACTION Processa( {||FS_GerExcel()} , STR0023 /*"Processando"*/, "", .T.)
	//
	ACTIVATE MSDIALOG oWindow ON INIT (EnchoiceBar(oWindow, {|| lOk:=.t., oWindow:End() }, { || oWindow:End() },,aNewBot))

Return .T.

/*/{Protheus.doc} FS_GerExcel

	@author       Vinicius Gati
	@since        13/05/2016
	@description  Evento double click do grid

/*/
Static Function FS_GerExcel()
	if LEN(oLb:aArray) >= 1
		ProcRegua( 0 )
		IncProc("Gerando")
		aHeader := {;
			STR0013 ,; // Filial
			STR0014 ,; // Produto
			STR0030 ,; // Grupo
			STR0058 ,; // Descrição Grupo
			STR0057 ,; // Origem
			STR0031 ,; // Locação
			STR0015 ,; // Almoxarifado
			STR0007 ,; // Custo Medio
			STR0006 ,; // Quantidade
			STR0005  ; // Total
		}
		aDados := {}
		oArrHlp:Map( oLb:aArray, {|el| AADD(aDados, {;
			el:GetValue('FILIAL')   ,;
			el:GetValue('PRODUT')   ,;
			el:GetValue('B1_GRUPO'),;
			el:GetValue('BM_DESC')  ,;
			el:GetValue('ORIGEM'),;
			el:GetValue("ENDERECAMENTO"),;
			el:GetValue('ALMOXE')   ,;
			(Transform(el:GetValue('CM'), "@E 999,999,999,999.99")),;
			STR(el:GetValue('QUANT')),;
			(Transform(el:GetValue('TOTAL'), "@E 999,999,999,999.99")) ;
		})} )
		targetDir := cGetFile( '*.html' , 'Local do arquivo', 1, ALLTRIM(' C:\ '), .F., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),.T., .T. )
		cfilname  := "RELATORIO_CACHE_INVENTARIO_" + SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) +"_EXTRATO_CONSULTA_INVENTARIO.HTML"
		IncProc(STR0022 + ": " + targetDir + cfilname)
		oUtil:GerExcel(targetDir + cfilname, aHeader, aDados)

		MSGINFO("Gerado com sucesso", "Informação")
	EndIf
Return .T.

/*/{Protheus.doc} FS_DblClick

	@author       Vinicius Gati
	@since        13/05/2016
	@description  Evento double click do grid

/*/
Static Function FS_DblClick()
Return ShowCacheInfo(oLb:aArray[oLb:nAt])


/*/{Protheus.doc} ShowCacheInfo

	@author       Vinicius Gati
	@since        13/05/2016
	@description  Informacoes da peca

/*/
Static Function ShowCacheInfo(oPrd)
	Local PULALINHA := CHR(13) + CHR(10)
	Local nIdx := 1
	Local cMessage := "" 

	cMessage += STR0017 /* Abaixo estão listados os almoxarifados existentes  */ + PULALINHA
	cMessage += STR0018 /*  para a peça selecionada. Serão listados os saldos */ + PULALINHA
	cMessage += STR0019 /*  dos últimos doze meses para estes almoxarifados.  */ + PULALINHA
	cMessage += STR0020 /*  A coluna SALDO ESTOQUE informa o saldo atual de   */ + PULALINHA
	cMessage += STR0021 /*  fechamento de estoque no Protheus. A coluna SALDO */ + PULALINHA
	cMessage += STR0024 /* CACHE informa o saldo atual da tabela de           */ + PULALINHA
	cMessage += STR0025 /*  inventário do PMM. Estas informações podem ser    */ + PULALINHA
	cMessage += STR0026 /*  usadas para comparação, validação e correção de   */ + PULALINHA
	cMessage += STR0027 /*  saldos errôneos.                                  */ + PULALINHA
	cMessage += PULALINHA
	cMessage += "-------------------------------------------------------------------"
	cMessage += PULALINHA

	aRegs := oSqlHlp:GetSelect({;
		{'campos', {"DATAEX", "PRODUT", "ALMOXE", "CM", "QUANT", "TOTAL"}},;
		{'query' , "SELECT DATAEX, PRODUT, ALMOXE, CM, QUANT, CM*QUANT TOTAL FROM MIL_DPM_CACHE_INVENTARIO WHERE FILIAL = '"+oPrd:GetValue('FILIAL')+"' AND PRODUT = '"+oPrd:GetValue('PRODUT')+"' AND D_E_L_E_T_ = ' ' ORDER BY ALMOXE, DATAEX DESC" };
	})
	
	DbSelectArea("SB2")
	for nIdx := 1 to LEN(aRegs)
		oReg := aRegs[nIdx]
		nQtd := CalcEst( oPrd:GetValue("PRODUT"), oReg:GetValue("ALMOXE"), STOD(oReg:GetValue('DATAEX')) )[1]
		cMessage += "Data:" + DTOC(STOD(oReg:GetValue("DATAEX"))) + " " + STR0015 /* ALMOXARIFADO */ + ": '"+oReg:GetValue("ALMOXE")+"' " + STR0028/*" SALDO: "*/ + ALLTRIM(STR(nQtd)) + STR0029/*" CACHE: "*/ + ALLTRIM(STR(oReg:GetValue('QUANT'))) + PULALINHA
	next

	Aviso("Atenção",cMessage, { "Ok" } , 3)
Return

/*/{Protheus.doc} FS_Valores

	@author       Vinicius Gati
	@since        13/05/2016
	@description  Indica os valores mostrados em cada coluna do listbox

/*/
Static Function FS_Valores()
Return { || IIF( LEN(oLb:aArray) < oLb:nAt,Array(12), ;
	{ "" ,;
		oLb:aArray[oLb:nAt]:GetValue('FILIAL'),;
		oLb:aArray[oLb:nAt]:GetValue('PRODUT'),;
		oLb:aArray[oLb:nAt]:GetValue('B1_GRUPO') ,;
		oLb:aArray[oLb:nAt]:GetValue('BM_DESC') ,;
		oLb:aArray[oLb:nAt]:GetValue('ORIGEM'),;
		oLb:aArray[oLb:nAt]:GetValue("ENDERECAMENTO"),;
		oLb:aArray[oLb:nAt]:GetValue('ALMOXE'),;
		Transform(oLb:aArray[oLb:nAt]:GetValue('CM'), "@E 999,999,999.99"),;
		oLb:aArray[oLb:nAt]:GetValue('QUANT'),;
		Transform(oLb:aArray[oLb:nAt]:GetValue('TOTAL'), "@E 999,999,999.99"), ;
		"" ;
	};
)}

/*/{Protheus.doc} FS_Buscar

	@author       Vinicius Gati
	@since        13/05/2016
	@description  Busca os dados de Interesses

/*/
Static Function FS_Buscar()
	Local cQuery    := ""
	Local oSqlHlp   := DMS_SqlHelper():New()
	Local nIdx      := 0
	Local nSum      := 0.0
	Local lLocSoSBZ := ( lSBZ .and. GetNewPar("MV_MIL0096","S") == "N" ) // A locação da peça também deve ser considerada na tabela SB5 quando o parâmetro MV_ARQPROD estiver configurado com SBZ? ( S=Considera / N=Não Considera )
	Local cOriginal := STR0059 // Original
	Local cNaoOrig  := STR0060 // Nao original

	cQuery += " SELECT CACHE.*, COALESCE( B1_GRUPO, ' ') B1_GRUPO, COALESCE( SBM.BM_DESC, ' ') BM_DESC, CASE WHEN SBM.BM_PROORI = '1' THEN '"+cOriginal+"' WHEN SBM.BM_PROORI = '0' THEN '"+cNaoOrig+"' ELSE ' ' END ORIGEM, CM*QUANT TOTAL,  "
	If lLocSoSBZ
		cQuery += " BZ_LOCALI2 ENDERECAMENTO "
	Else
		cQuery += " CASE "
		if lSBZ
			cQuery += "   WHEN SBZ.BZ_LOCALIZ = 'S' OR ( SBZ.BZ_LOCALIZ IS NULL AND SB1.B1_LOCALIZ = 'S' ) "
		Else
			cQuery += "   WHEN SB1.B1_LOCALIZ = 'S' "
		End
		cQuery += "   THEN ' ' "
		if lSBZ
			cQuery += "   ELSE CASE WHEN BZ_LOCALI2 IS NULL OR BZ_LOCALI2 = ' ' THEN B5_LOCALI2 ELSE BZ_LOCALI2 END "
		Else
			cQuery += "   ELSE B5_LOCALI2 "
		EndIf
		cQuery += " END ENDERECAMENTO "
	EndIf

	cQuery += "   FROM MIL_DPM_CACHE_INVENTARIO CACHE "
	cQuery += "   JOIN " + oSqlHlp:NoLock('SB1') + " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' AND B1_COD = CACHE.PRODUT AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "   LEFT JOIN " + oSqlHlp:NoLock('SBM') + " ON SBM.BM_FILIAL = '" + xFilial('SBM') + "' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_VAIDPM = '1' AND SBM.D_E_L_E_T_ = ' ' "
	
	nSize := LEN( ALLTRIM(xFilial('SBZ')) )
	if nSize == len(xFilial('SBZ'))
		cQuery += " JOIN " + oSqlHlp:NoLock('SBZ') + " ON SBZ.BZ_FILIAL = "+iif("ORACLE" $ cSGBD,"SUBSTR(CACHE.FILIAL ,1 ,"+STR(nSize)+"","LEFT(CACHE.FILIAL,'"+STR(nSize)+"'")+") AND BZ_COD = PRODUT AND SBZ.D_E_L_E_T_ = ' ' "
	Else
		cQuery += " JOIN " + oSqlHlp:NoLock('SBZ') + " ON SBZ.BZ_FILIAL = '" + xFilial('SBZ') + "' AND BZ_COD = PRODUT AND SBZ.D_E_L_E_T_ = ' ' "
	Endif
	nSize := LEN( ALLTRIM(xFilial('SB5')) )
	if nSize == len(xFilial('SB5'))
		cQuery += " JOIN " + oSqlHlp:NoLock('SB5') + " ON SB5.B5_FILIAL = "+IIF("ORACLE" $ cSGBD,"SUBSTR(CACHE.FILIAL ,1 ,"+STR(nSize)+"","LEFT(CACHE.FILIAL,'"+STR(nSize)+"'")+") AND B5_COD = PRODUT AND SB5.D_E_L_E_T_ = ' ' "
	Else
		cQuery += " JOIN " + oSqlHlp:NoLock('SB5') + " ON SB5.B5_FILIAL =  '" + xFilial('SB5') + "' AND B5_COD = PRODUT AND SB5.D_E_L_E_T_ = ' ' "
	Endif
	cQuery += "  WHERE 1=1  "
	if ! Empty(cPrd)
		cQuery += "  AND CACHE.PRODUT = '"+cPrd+"' "
	EndIf
	cQuery += "    AND CACHE.DATAEX = '"+DTOS(CTOD(cMesSel))+"' "

	if ! Empty(cLoc)
		cQuery += "    AND CACHE.ALMOXE = '"+cLoc+"' "
	EndIf

	if ! Empty(cFil)
		cQuery += "    AND CACHE.FILIAL = '" + cFil + "'"
	endIf

	if cOrigem == STR0059 // Original
		cQuery += "    AND SBM.BM_PROORI = '1' "
	elseIf cOrigem == STR0060 // Não original
		cQuery += "    AND SBM.BM_PROORI = '0' "
	endIf

	if cErrados == STR0010 /*"Problemas"*/
		cQuery += "  AND ( CACHE.CM < 0 OR CACHE.QUANT < 0 ) "
	elseIf cErrados == STR0009 /*"Corretos"*/
		cQuery += "  AND CACHE.CM > 0 AND CACHE.QUANT > 0 "
	endIf
	cQuery += "    AND FLAGP != ' ' "
	cQuery += "    AND CACHE.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY CM*QUANT DESC "
	aRegs := oSqlHlp:GetSelect({;
		{'campos', {"TOTAL", "FILIAL", "DATAEX", "PRODUT", "ALMOXE", "CM", "QUANT", "B1_GRUPO", "BM_DESC", "ORIGEM", "ENDERECAMENTO"}},;
		{'query' , cQuery};
	})

	For nIdx := 1 to LEN(aRegs)
		nSum += aRegs[nIdx]:GetValue("TOTAL")
	Next

	cValTot := Transform(nSum, "@E 999,999,999,999.99")
	oLb:SetArray( aRegs )
	oLb:bLine := FS_Valores()
	oLb:Refresh()
Return .T.

/*/{Protheus.doc} last12M
    Retornar ultimos 12 meses em data e em array, todas no ultimo dia do mês

    @author Vinicius Gati
    @since  08/10/2015
/*/
Static Function last12M()
	aRegs := oSqlHlp:GetSelect({;
		{'campos', {"DATAEX"}},;
		{'query' , " SELECT DISTINCT DATAEX FROM MIL_DPM_CACHE_INVENTARIO WHERE D_E_L_E_T_ = ' ' AND FLAGP != ' ' ORDER BY DATAEX DESC "};
	})
Return oArrHlp:Map(aRegs, {|r| DTOC(STOD(r:GetValue('DATAEX'))) })

Static Function OFJ380001H_RelatorioInventarioCSV()
	Local oDpm      := DMS_Dpm():New()
	Local oArrHlp   := DMS_ArrayHelper():New()
	Local aFilis    := oArrHlp:Map(oDpm:GetFiliais(), {|aEl| aEl[1] })
	Local oSqlHlp   := DMS_SqlHelper():New()
	//
	Local aParam    := OFJ380002H_ParamBoxCSV(aFilis)
	Local cQuery    := ""	
	Local lSBZ      := SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
	Local lLocSoSBZ := ( lSBZ .and. GetNewPar("MV_MIL0096","S") == "N" ) // A locação da peça também deve ser considerada na tabela SB5 quando o parmetro MV_ARQPROD estiver configurado com SBZ? ( S=Considera / N=No Considera )
	Local cOriginal := STR0059 // Original
	Local cNaoOrig  := STR0060 // Nao original
	//
	Local cMesesDe
	Local cMesAte
	//
	Local cBckFil       := cFilAnt
	Local cAl := GetNextAlias()
	//

	iF ValType(aParam) <> "A"
		Return
	Endif

	MV_PAR001 := aParam[1] //Filiais
	MV_PAR002 := aParam[2] // Data De
	MV_PAR003 := aParam[3] // Data Ate
	MV_PAR004 := aParam[4] //Produto
	MV_PAR005 := aParam[5] //Almoxerifado
	MV_PAR006 := aParam[6] //Anlise Est.
	MV_PAR007 := alltrim(aParam[7]) //Diretório
	MV_PAR008 := aParam[8] //Origem
	//
	cMesesDe := SubStr(MV_PAR002,7,4) + SubStr(MV_PAR002,4,2) + SubStr(MV_PAR002,1,2) //Formatar string da data do ultimo
	cMesAte := SubStr(MV_PAR003,7,4) + SubStr(MV_PAR003,4,2) + SubStr(MV_PAR003,1,2)

	cNomeArq := MV_PAR007 + STR0056+dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) +STR0055 //exp_inventario_pmm_//.csv
	oFWriter := FWFileWriter():New(cNomeArq , .T., 4096)

	If ! oFWriter:Create()
		MsgStop(STR0054 + oFWriter:Error():Message + STR0053) // Houve um erro ao gerar o arquivo : // Atenção
    Else
	
		oFWriter:Write( STR0013 + ";" +; //Filial
						STR0034 + ";" +; //Dealer Code
						STR0035 +";"+ ;  //Grupo do Item
						STR0058 +";"+; //Descrição Grupo
						STR0057 +";"+; //Origem
						STR0036 +";"+ ;  //Codigo do Item
						STR0037 +";"+;   //Descricao do Item
						STR0038 +";"+;   //Data de Execucao do PMM
						STR0015 +";"+;   //Almoxarifado
						STR0039 +";"+;   //Flag
						STR0007 +";"+;   //Custo Médio
						STR0006 + ";"+;  //Quantidade
						STR0040+ CRLF )  //Valor Total

		cQuery += " SELECT CACHE.*, COALESCE( B1_GRUPO, ' ') B1_GRUPO, COALESCE( SBM.BM_DESC, ' ') BM_DESC, CASE WHEN SBM.BM_PROORI = '1' THEN '"+cOriginal+"' WHEN SBM.BM_PROORI = '0' THEN '"+cNaoOrig+"' ELSE ' ' END ORIGEM, CM*QUANT TOTAL, FILIAL, B1_CODITE, B1_DESC, "
		If lLocSoSBZ
			cQuery += " BZ_LOCALI2 ENDERECAMENTO "
		Else
			cQuery += " CASE "
			if lSBZ
				cQuery += "   WHEN SBZ.BZ_LOCALIZ = 'S' OR ( SBZ.BZ_LOCALIZ IS NULL AND SB1.B1_LOCALIZ = 'S' ) "
			Else
				cQuery += "   WHEN SB1.B1_LOCALIZ = 'S' "
			End
			cQuery += "   THEN ' ' "
			if lSBZ
				cQuery += "   ELSE CASE WHEN BZ_LOCALI2 IS NULL OR BZ_LOCALI2 = ' ' THEN B5_LOCALI2 ELSE BZ_LOCALI2 END "
			Else
				cQuery += "   ELSE B5_LOCALI2 "
			EndIf
			cQuery += " END ENDERECAMENTO "
		EndIf

		cQuery += "   FROM MIL_DPM_CACHE_INVENTARIO CACHE "
		cQuery += "   JOIN " + oSqlHlp:NoLock('SB1') + " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' AND B1_COD = CACHE.PRODUT AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "   LEFT JOIN " + oSqlHlp:NoLock('SBM') + " ON SBM.BM_FILIAL = '" + xFilial('SBM') + "' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_VAIDPM = '1' AND SBM.D_E_L_E_T_ = ' ' "
		
		nSize := LEN( ALLTRIM(xFilial('SBZ')) )
		if nSize == len(xFilial('SBZ'))
			cQuery += " JOIN " + oSqlHlp:NoLock('SBZ') + " ON SBZ.BZ_FILIAL = "+iif("ORACLE" $ cSGBD,"SUBSTR(CACHE.FILIAL ,1 ,"+STR(nSize)+"","LEFT(CACHE.FILIAL,'"+STR(nSize)+"'")+") AND BZ_COD = PRODUT AND SBZ.D_E_L_E_T_ = ' ' "
		Else
			cQuery += " JOIN " + oSqlHlp:NoLock('SBZ') + " ON SBZ.BZ_FILIAL = '" + xFilial('SBZ') + "' AND BZ_COD = PRODUT AND SBZ.D_E_L_E_T_ = ' ' "
		Endif
		nSize := LEN( ALLTRIM(xFilial('SB5')) )
		if nSize == len(xFilial('SB5'))
			cQuery += " JOIN " + oSqlHlp:NoLock('SB5') + " ON SB5.B5_FILIAL = "+IIF("ORACLE" $ cSGBD,"SUBSTR(CACHE.FILIAL ,1 ,"+STR(nSize)+"","LEFT(CACHE.FILIAL,'"+STR(nSize)+"'")+") AND B5_COD = PRODUT AND SB5.D_E_L_E_T_ = ' ' "
		Else
			cQuery += " JOIN " + oSqlHlp:NoLock('SB5') + " ON SB5.B5_FILIAL =  '" + xFilial('SB5') + "' AND B5_COD = PRODUT AND SB5.D_E_L_E_T_ = ' ' "
		Endif
		cQuery += "  WHERE 1=1  "
		if ! Empty(MV_PAR004)
			cQuery += "  AND CACHE.PRODUT = '"+MV_PAR004+"' "
		EndIf
		
		cQuery += "    AND CACHE.DATAEX BETWEEN '"+Alltrim(cMesesDe)+"' AND '"+Alltrim(cMesAte)+"'

		if ! Empty(MV_PAR005)
			cQuery += "    AND CACHE.ALMOXE = '"+MV_PAR005+"' "
		EndIf

		if ! Empty(MV_PAR001) .and. ALLTRIM((MV_PAR001)) <> STR0004 // Diferente que a opcao Todos
			cQuery += "    AND CACHE.FILIAL = '" + MV_PAR001 + "'"
		endIf

		if ALLTRIM(MV_PAR008) == "2" // Original
			cQuery += "    AND SBM.BM_PROORI = '1' "
		elseIf ALLTRIM(MV_PAR008) == "3" // Não original
			cQuery += "    AND SBM.BM_PROORI = '0' "
		endIf

		if ALLTRIM(MV_PAR006) == "2" /*"Problemas"*/
			cQuery += "  AND ( CACHE.CM < 0 OR CACHE.QUANT < 0 ) "
		elseIf ALLTRIM(MV_PAR006) == "1" /*"Corretos"*/
			cQuery += "  AND CACHE.CM > 0 AND CACHE.QUANT > 0 "
		endIf
		cQuery += "    AND FLAGP != ' ' "
		cQuery += "    AND CACHE.D_E_L_E_T_ = ' ' "
		//cQuery += " ORDER BY CM*QUANT DESC "
		cQuery += " ORDER BY CACHE.FILIAL, CACHE.DATAEX, B1_GRUPO, B1_CODITE "
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )

		(cAl)->(DbGoTop())

		cDealerCode := GetMV("MV_MIL0005")

		While ! (cAl)->(EoF())

			if cFilAnt <> (cAl)->FILIAL
				cFilAnt := (cAl)->FILIAL
				cDealerCode := GetMV("MV_MIL0005")
			endif

			oFWriter:Write((cAl)->FILIAL + ";" +;
						Alltrim(cDealerCode) + ";" +;
						alltrim((cAl)->B1_GRUPO) +";"+ ;
						alltrim((cAl)->BM_DESC) +";"+ ;
						alltrim((cAl)->ORIGEM) +";"+ ;
						ALLTRIM((cAl)->B1_CODITE) +";"+ ;
						Alltrim((cAl)->B1_DESC) +";"+;
						DtoC(StoD((cAl)->DATAEX)) +";"+;
						(cAl)->ALMOXE +";"+;
						(cAl)->FLAGP +";"+;
						Transform((cAl)->CM,"@E 999999999999999.99") +";"+;
						Transform((cAl)->QUANT,"@E 999999999999999.99") +";"+;
						Transform((cAl)->TOTAL,"@E 999999999999999.99") + CRLF )
			(cAl)->(DbSkip())

		End Do
		
		(cAl)->(DbCloseArea())

		//Encerra o arquivo
		oFWriter:Close()
		MsgInfo(STR0041+dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + STR0042 + MV_PAR007) //Arquivo exp_inventario_pmm//.csv gerado com sucesso no diretório
	endIf

	cFilAnt := cBckFil

Return

Static Function OFJ380002H_ParamBoxCSV(aFilis)	
	Local aRet	   := {}
	local aCombo1  := aClone(aFilis)
	local aCombo2  := {STR0043,STR0044,STR0045} // 1=Padrão//2=Não-Conforme//3=Todos
	local aCombo3  := {STR0004, STR0059, STR0060} // Todos//Original//Não original
	local aPergs   := {}
	Local cPrd     := SPACE(TAMSX3("B1_COD")[1])
	Local cLoc     := SPACE(TAMSX3("B2_LOCAL")[1])
	Local nTamFil  := Len(aCombo1)
	Local aMeses   := last12M()
	Local nTamDt   := Len(aMeses)

	Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY
	Local cVldDiretorio := "iif( ! empty(mv_par07) , mv_par07 , MV_PAR07 := cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcGetFil))+"))"

	aAdd(aCombo1, STR0004) // Todos

	aAdd(aPergs, {2,STR0046, Str(nTamFil) , aCombo1, 100, "", .T.}) // Filias :
	aAdd(aPergs, {2,STR0047, Str(nTamDt)  , aMeses, 100, "", .T.}) // Data de :
	aAdd(aPergs, {2,STR0048, Str(nTamDt) , aMeses, 100, "", .T.}) // Data ate :
	aAdd(aPergs, {1,STR0049     , cPrd, "", ".T.", "SB1", ".T.", 100, .F.}) //Produto :
	aAdd(aPergs, {1,STR0050, cLoc, "", ".T.", "NNR", ".T.", 100, .F.}) //Amoxarifado:
	aAdd(aPergs, {2,STR0051, "1", aCombo2, 100, "", .F.}) //Analise Est :
	aAdd(aPergs, {1,STR0052, Space(80),  '', cVldDiretorio, '', '.T.', 120,  .T.}) //Diretório :
	aAdd(aPergs, {2,STR0057 + " :", "1", aCombo3, 100, "", .F.}) //Origem :
	
	if !ParamBox(aPergs, STR0033 , @aRet,,,,,,,, .t., .t.) //Informe os parametros
		return .f.
	endif

Return aRet
