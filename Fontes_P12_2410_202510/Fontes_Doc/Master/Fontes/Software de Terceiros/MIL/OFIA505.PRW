#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "tbiconn.ch"
#include "OFINJD06.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIA505    | Autor | Vinicius Gati         | Data | 07/11/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exportação do layout John Deere - DPMEXT                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIA505(aParam, lSoGer, aDpmCfgs /*compatibilidade nao usado pos argentina*/, cTipGer)
	Local cDesc1        := STR0001
	Local cDesc2        := STR0002
	Local cDesc3        := STR0003
	Local aSay          := {}
	Local aButton       := {}
	Local lNewRes 		:= GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
	Private lAuto       := valtype(aParam) != "U" //Chamada Automatica
	Private oLogger     := Nil
	Private oLoggerPec	:= Nil
	Private oLogTrf     := Nil
	Private oDpePecas   := Nil
	Private oSqlHlp     := Nil
	Private oDS         := Nil
	Private cTblLogCod  := ""
	Private cSavePath   := ""
	Private cTipoExt    := "D"
	Private nArqGer     := 0
	Private aVetCods    := {}
	Private lEmuPrism   := .F.
	Private aMod36Dem   := {}
	Private cTitulo     := STR0004
	Private aFilis      := {}
	Private dData36At   := Nil
	Private oArHelp     := Nil
	Private lDebug      := .F.
	Private oDevObj     := JsonObject():New()
	Private oDevPecs    := JsonObject():New() // dados para identificar se teve devolucao pra determinada filial e peça de forma rapida
	Private oDpm        := DMS_DPM():New()
	default lSoGer      := .F.
	default cTipGer     := "D"
	Private cArquivo
	Private oRPM
	Private cTblDadosAdc
	
	If !lNewRes
		FMX_HELP("INCRESRPM", STR0031) //Incompatibilidade entre versões, para utilizar as novas implementações do RPM deve-se utilizar a Reserva Rastreavel.
		Return
	EndIf

	oRPM      := OFJDConfig():New()
	oUtil     := DMS_Util():New()
	oDpe      := DMS_DPMDPE_1_3():New()

	oLogger   := DMS_Logger():New("OFINJD06_"    +dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
	oLogDebug := DMS_Logger():New("OFINJD06_DBG_"+dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
	oLogTrf   := DMS_Logger():New("OFINJD06_TRF_"+dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
	
	oSqlHlp   := DMS_SqlHelper():New()
	oDpePecas := DMSB_DpePecas():New()
	oDS       := DMSB_DirectShipment():New()
	oArHelp   := DMS_ArrayHelper():New()
	oDS:AtualizarPecas()

	cTblDadosAdc := oRPM:getTabelaDadosAdc()

	dData36At := oUtil:RemoveMeses(dDataBase, 12)
	dData36At := oUtil:RemoveMeses(dData36At, 12) // 24
	dData36At := oUtil:RemoveMeses(dData36At, 12) // 36

	// Isto serve para gerar arquivo sem perguntar nada via ""menu"" usado por threads para nao consumir licenca
	If lSoGer
		lAuto := .t.
	EndIf

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	nOpc := 0

	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )

	if !lAuto
		FormBatch( cTitulo, aSay, aButton )

		If nOpc <> 1
			Return
		Endif
	endif

	lDebug := oRPM:DebugMode() //TODO: fazer algo bom para debug

	conout("OFINJD06 -> Iniciando rotina <-")
	if lDebug
		conout("OFINJD06 -> Modo debug ativado <-")
	endif

	if ! Empty(cTipGer)
		cTipoExt := cTipGer
	Endif

	if ! oRpm:PodeGerarDelta()
		if cTipoExt == "D"
			conout("OFINJD06 -> Bloqueando geração de delta por não estar habilitado no OFIA503 <-")
		endif
		cTipoExt := "I"
	EndIf

	// Logs iniciais
	if lAuto
		cModo := IIF(lAuto, "Agendado", "Menu")
		oLogger:Log({'TIMESTAMP', "OFINJD06 rodado em modo "+cModo+" data: " + DTOS(dDatabase) + "("+time()+")"})
		cTblLogCod := oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'OFINJD06'         },;
			{'VQL_TIPO'       , 'LOG_EXECUCAO'     },;
			{'VQL_DADOS'      , "MODO: "+cModo     } ;
		})
	EndIf

	If ! oRPM:IsProcessed(dDatabase)
		If lAuto
			oLogger:Log({'TIMESTAMP', STRTRAN(STR0030, "OFINJD31", "OFIA504") /* "OFINJD06 Não pode ser gerado devido a falha no processamento de dados diário(OFINJD31 no prism)."*/})
			cTblLogCod := oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFINJD06' },;
				{'VQL_TIPO'       , 'ERRO'     },;
				{'VQL_DADOS'      , STRTRAN(STR0030, "OFINJD31", "OFIA504") /* "OFINJD06 Não pode ser gerado devido a falha no processamento de dados diário(OFINJD31 no prism)."*/ } ;
			})
		Else
			Alert(STRTRAN(STR0030, "OFINJD31", "OFIA504") /* "OFINJD06 Não pode ser gerado devido a falha no processamento de dados diário(OFINJD31 no prism)."*/)
		EndIf
		Return // não gerará arquivo
	EndIf

	if lAuto
		ExportArq(lAuto, oRPM:GetFiliais(),,, "SCHEDULER")
	else
		Processa({ |lEnd| ExportArq(lAuto, oRPM:GetFiliais(),,, "SCHEDULER") }, STR0005,STR0006)
	endif
	oLogger:Log({'TIMESTAMP', "Quantidade de arquivos gerados: " + STR(nArqGer) })
	oLogger:CloseOpened(cTblLogCod)
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ExportArq  | Autor | Luis Delorme          | Data | 29/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exporta arquivo                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq(lAuto, aFilis, cPath /*compatibilidade*/, cAccount /*compatibilidade*/, cGrupo)
	Local nCntFor, nCntFor2
	Local nIdxFil  := 1
	Local cAl := GetNextAlias()
	Local aDados
	Local cFileDest := ""
	Local cDirSave := ""
	Local nIdx1 := 1
	local nIdx  := 1
	local nX := 1
	local nZ := 1
	local aLocMap := nil
	local cExtensao := ONJD060014_PegaExtensaoDoArquivo(cGrupo)
	default cAccount := oRPM:GetAccount()

	oLoggerPec := DMS_Logger():New("VEICLSBD_" +DToS(dDataBase)+"_"+Subs(Time(),1,2) + Subs(Time(),4,2) + Subs(Time(),7,2) + ".LOG")
	
	oDpePecas:ColetaItensDia(oLoggerPec)
	
	If oRPM:getTabelaDadosAdc() == "SBZ"
		oDpePecas:AtuSBZPrimeiraEntrada(oLoggerPec)
		oDpePecas:AtuSBZUltimaVenda(oLoggerPec)
	Else
		oDpePecas:AtuSB5PrimeiraEntrada(oLoggerPec)
		oDpePecas:AtuSB5UltimaVenda(oLoggerPec)
	Endif

	conout("OFINJD06 - Executando com lAuto ="+IIF(lAuto,"TRUE","FALSE")+ " e cTipoEXT = '"+cTipoExt+"'")

	cArquivo := "DLR2JD_DPMEXT_" + ;
		cTipoExt + "_" + ;
		cAccount + "_" +;
		dtos(ddatabase) + "_" + ;
		SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + cExtensao

	cFileTemp := "\" + cArquivo // arquivo em local temporario
	nHnd := FCREATE( cFileTemp )

	// limpando todas geracoes pendentes se existirem
	TCSQLEXEC(" UPDATE "+RetSqlName('VQL')+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP = '"+IIF(EMPTY(cGrupo), "", cGrupo)+"' AND VQL_TIPO in ('SCHED_I', 'SCHED_R', 'SCHED_D') AND VQL_DATAF = ' ' AND D_E_L_E_T_ = ' ' ")

	SB2->(DBSetOrder(1))
	SBZ->(DBSetOrder(1))
	SB5->(DBSetOrder(1))

	// cabeçalho principal

	aValoresH := {}
	aAdd(aValoresH, "~"+cAccount+"~")
	aAdd(aValoresH, STRZERO(YEAR(dDatabase),4)+"-"+STRZERO(MONTH(dDatabase),2)+"-"+STRZERO(DAY(dDatabase),2))
	aAdd(aValoresH, TIME())
	aAdd(aValoresH, cTipoExt )
	aAdd(aValoresH, "1.3")
	aAdd(aValoresH, "TOTVS PROTHEUS ãÃçÇ")
	aAdd(aValoresH, "2.1.5")
	//
	// Ultimo dpmxfer importado
	// Ultimo dpmord importado
	// todos os xfer e ords importados
	//
	cUltOrd  := ALLTRIM(FM_SQL(oSqlHlp:TopFunc(" SELECT VQL_DADOS FROM " +oSqlHlp:NoLock('VQL')+ " WHERE VQL_AGROUP = 'DPMORD_DPE' AND VQL_TIPO = 'CODIGO_DPE' ORDER BY R_E_C_N_O_ DESC ", 1)))
	aAdd(aValoresH, Alltrim(cUltOrd))
	oLogger:Log({"TIMESTAMP", "ultimo order:" + cUltOrd})


	cUltXfer := ALLTRIM(FM_SQL(oSqlHlp:TopFunc(" SELECT VQL_DADOS FROM " +oSqlHlp:NoLock('VQL')+ " WHERE VQL_AGROUP = 'DPMXFER_DPE' AND VQL_TIPO = 'CODIGO_DPE' ORDER BY R_E_C_N_O_ DESC ", 1)))
	aAdd(aValoresH, Alltrim(cUltXfer))
	oLogger:Log({"TIMESTAMP", "ultimo transfer:" + cUltOrd})

	aCodigos := oSqlHlp:GetSelect({ ;
		{'campos', {'VQL_DADOS', 'VQL_CODIGO'}}, ;
		{'query', "SELECT VQL_DADOS, VQL_CODIGO FROM " +RetSqlName('VQL')+ " WHERE VQL_AGROUP IN ('DPMORD_DPE', 'DPMXFER_DPE') AND VQL_TIPO = 'CODIGO_DPE' AND VQL_DATAF = ' ' AND D_E_L_E_T_ = ' ' AND VQL_DADOS NOT IN ('"+cUltXfer+"', '"+cUltOrd+"') ORDER BY R_E_C_N_O_ ASC"};
	})
	aCodes := oArHelp:Map(aCodigos, { |el| ALLTRIM(el:GetValue('VQL_DADOS'))})
	if ! Empty(cUltXfer)
		AADD(aCodes, cUltXfer)
	endIf
	if ! Empty(cUltOrd)
		AADD(aCodes, cUltOrd)
	endif
	cCodes := oArHelp:Join( aCodes, ',' )
	aAdd(aValoresH, Alltrim(cCodes))
	cLinha := MontaEDI(aValoresH)
	fwrite(nHnd, EncodeUtf8(cLinha))

	cDirSave := Alltrim(oRPM:CaminhoDosArquivos()) + "\"
	cDirSave := StrTran(cDirSave, "/", "\")
	cDirSave := StrTran(cDirSave, "\\", "\")

	cSavePath := cDirSave + "\"
	cFileDest += cDirSave + "\" + cArquivo

	cFileDest := StrTran(cFileDest, "\\", "\")
	cSavePath := StrTran(cSavePath, "\\", "\")

	If lAuto .and. !(Left(cFileDest,1) $ "/\")
		oLogger:Log({'TIMESTAMP', "ATENCAO: nao é possivel gerar o arquivo do PARTS DATA (DPM) em um diretorio local quando executado atraves do SCHEDULE "})
		conout(" ")
		conout("OFINJD06 ==========================================================================================")
		conout("OFINJD06  ATENCAO: nao é possivel gerar o arquivo do PARTS DATA (DPM) em um diretorio local quando ")
		conout("OFINJD06           executado atraves do SCHEDULE                                                   ")
		conout("OFINJD06 ==========================================================================================")
		conout(" ")
	EndIf

	aFilDev := oArHelp:Uniq(aFilis, { |x| x["FILIAL"] })

	// Devoluções
	For nIdx1 := 1 to Len(aFilDev)
		oFil := aFilDev[nIdx1]
		cFil   := oFil["FILIAL"]
		cInGroups := oArHelp:Join(oArHelp:Map(oRPM:GruposDePecas(), { |cCod| "'" + cCod + "'" }), ",")
		aDevs  := oDpm:GetDevData(cFil, dDatabase,,,, "(" + cInGroups + ")")

		for nIdx := 1 to Len(aDevs)
			oObj := aDevs[nIdx]
			//cIdx := alltrim(cFil) + alltrim(oObj:GetValue('D2_EMISSAO'))         + alltrim(oObj:GetValue('D2_COD')) + alltrim(oObj:GetValue('D2_LOCAL') + oObj:GetValue('SEGMTO'))
			cIdx := ALLTRIM(cFil) + alltrim(LEFT(oObj:GetValue('D2_EMISSAO'),6)) + alltrim(oObj:GetValue('D2_COD')) + alltrim(oObj:GetValue('D2_LOCAL') + oObj:GetValue('SEGMTO'))

			if oObj:GetValue('QTD_ITENS') > 0
				oDevPecs[alltrim(cFil) + alltrim(oObj:GetValue('D2_COD'))] := .T.
			endif

			If ! Empty(oDevObj[cIdx])
				oDevObj[cIdx][1] += oObj:GetValue('QTD_ITENS')
				oDevObj[cIdx][2] += oObj:GetValue('QTD_HITS')
			else
				oDevObj[cIdx] := {oObj:GetValue('QTD_ITENS'), oObj:GetValue('QTD_HITS')}
			EndIf
		next	
	Next

	nMes := Month(ddatabase)
	nAno := Year(ddatabase)
	for nCntFor2 := 1 to 36
		nMes--
		if nMes == 0
			nAno--
			nMes := 12
		endif
		aAdd(aMod36Dem,{0,0,0,0, nMes, nAno})
	next

	aTransf := {}

	for nIdxFil := 1 to LEN(aFilis)
		oFil := aFilis[nIdxFil]

		cFilAnt := oFil["FILIAL"]

		//
		// Transferências
		//
		conout("OFINJD06 - Verificando Transferências"+ " ("+time()+")")

		cAl := GetNextAlias()

		oFilialHelper := DMS_FilialHelper():New()
		dbSelectArea("SA2")
		dbGoTo( oFilialHelper:GetFornecedor( xFilial('VS1') ) )

		cQuery := ""
		cQuery += "    SELECT 'ORIGEM' VS1_FILORI, VS1_FILDES, B1_COD, VS3_QTDITE QTDTOT, VS3_LOCAL "
		cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
		cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS1_FILIAL = VS3_FILIAL           AND VS1_NUMORC = VS3_NUMORC AND VS1_STATUS <> 'C'        AND VS1_TIPORC     = '3' AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "      JOIN " + oSqlHlp:NoLock('SF1') + " ON F1_FILIAL  = VS1_FILDES           AND F1_DOC     = VS1_NUMNFI AND F1_SERIE    = VS1_SERNFI AND SF1.D_E_L_E_T_ = ' ' "
		cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO    = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "      JOIN " + oDpePecas:TableName() + " ON FILIAL    = '"+xFilial('VS3')+"'  AND PRODUTO    = B1_COD     AND DATAGER     = '"+DTOS(dDatabase)+"' "
		cQuery += "     WHERE VS3_FILIAL     = '"+xFilial('VS3')+"' "
		cQuery += "       AND VS1_NUMNFI    <> ' ' "
		cQuery += "       AND VS3.D_E_L_E_T_ = ' ' "
		cQuery += "       AND F1_STATUS      = ' ' "
		cQuery += "       AND VS3_LOCAL = ARMAZEM  "
		cQuery += "       AND F1_FORNECE = '"+SA2->A2_COD+"' AND F1_LOJA = '"+SA2->A2_LOJA+"' "

		If ( ExistBlock("OJD06ETRF") )  // Insere condição customizada no levantamento de transfers
			cQryTRF := ExecBlock("OJD06ETRF",.f.,.f.,{cQuery})
			oLogger:Log({'TIMESTAMP', "|> OJD06ETRF: " + cQryTRF})
			If !Empty(cQryTRF)
				cQuery += " AND " + cQryTRF
			EndIf
		EndIf

		cQuery += " UNION ALL "
		cQuery += "    SELECT VS1_FILIAL VS1_FILORI, VS1_FILDES, B1_COD, VS3_QTDITE QTDTOT, VS3_LOCAL "
		cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
		cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS1_FILIAL = VS3_FILIAL           AND VS1_NUMORC = VS3_NUMORC AND VS1_TIPORC  = '3'        AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO    = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "      JOIN " + oDpePecas:TableName() + " ON  FILIAL    = '"+xFilial('VS3')+"' AND PRODUTO    = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' "
		cQuery += "     WHERE VS3_FILIAL     = '"+xFilial('VS3')+"' "
		cQuery += "       AND VS3_DOCSDB    <> ' ' "
		cQuery += "       AND VS1_STATUS    <> 'C' "
		cQuery += "       AND VS1_STATUS    <> 'X' "
		cQuery += "       AND VS1_NUMNFI     = ' ' "
		cQuery += "       AND VS3_LOCAL = ARMAZEM  "
		cQuery += "       AND VS3.VS3_TRSFER = '1' " //Somente orçamentos de transferencia originados de XFER DPM JD
		cQuery += "       AND VS3.D_E_L_E_T_ = ' ' "

		cQuery := " SELECT VS1_FILORI, VS1_FILDES, VS3_LOCAL, B1_COD, SUM(QTDTOT) QTDTOT FROM ("+cQuery+") X GROUP BY VS1_FILORI, VS1_FILDES, VS3_LOCAL, B1_COD "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
		oLogger:Log({'TIMESTAMP', cQuery})

		while !( (cAl)->(eof()) )
			nIdxTransf := aScan(aTransf,{|x| ;
				x[1] == (cAl)->(VS1_FILDES) .AND.;
				x[2] == (cAl)->(B1_COD)     .AND.;
				x[3] == (cAl)->(VS3_LOCAL) ;
			})
			
			if nIdxTransf > 0
				aTransf[nIdxTransf, 4] += (cAl)->(QTDTOT)
			Else
				AAdd(aTransf,{ ;
					(cAl)->(VS1_FILDES), ;
					(cAl)->(B1_COD), ;
					(cAl)->(VS3_LOCAL), ;
					(cAl)->(QTDTOT), ;
					0 ;
				})
			EndIf

			(cAl)->(DBSkip())
		enddo
		(cAl)->(dbCloseArea())
	Next

	oLogger:Log({'TIMESTAMP', "|> Tamanho array transfs: " + ALLTRIM(STR(LEN(aTransf))) })

	cQryAl002 := GetNextAlias()

	for nIdxFil := 1 to LEN(aFilis)
		jFil := aFilis[nIdxFil]
		cFilAnt := jFil["FILIAL"]
		cSegmento := jFil["SEGMENTO"]
		aArms := oRPM:ArmazensCadastrados(jFil["FILIAL"])

		cQuery36 := "  SELECT VB8_MES, VB8_ANO, VB8_NNRCOD, COALESCE(SUM(VB8_VDAB),0) VB8_VDAB, COALESCE(SUM(VB8_VDAO),0) VB8_VDAO, COALESCE(SUM(VB8_HITSB),0) VB8_HITSB, COALESCE(SUM(VB8_HITSO),0) VB8_HITSO, COALESCE(SUM(VB8_VDPERB),0) VB8_VDPERB, COALESCE(SUM(VB8_VDPERO),0) VB8_VDPERO, COALESCE(SUM(VB8_HIPERB),0) VB8_HIPERB, COALESCE(SUM(VB8_HIPERO),0) VB8_HIPERO "
		cQuery36 += "    FROM " +oSqlHlp:NoLock("VB8")
		cQuery36 += "   WHERE "+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'})+" BETWEEN '" + DTOS(dData36At) + "' AND '" + DTOS(dDatabase) + "' "
		cQuery36 += "     AND VB8.D_E_L_E_T_ = ' ' "

		cMesFiscal := STRZERO(MONTH(dDataBase),2)


		aArms := oArHelp:GroupByBlock(aArms, { |x| x["CODIGO_JD_ARMAZEM"] })


		/*
			Gravando cabeçalho de armazem
		*/
		for nX := 1 to len(aArms)
			aArmzMerge := aArms[nX, 2]
			
			// filtrando somente os do mesmo segmento, na realidade isso 
			// nao deveria ocorrer, é só por segurança caso configuração esteja errada
			aArmzMerge := oArHelp:Select(aArmzMerge, { |jArm| alltrim(jArm["SEGMENTO"]) == alltrim(jFil["SEGMENTO"]) })

			if len(aArmzMerge) == 0 // nao tem armazem para o segmento atual pula
				loop
			endif

			jArm := aArmzMerge[1]
			
			aLocMap := oArHelp:Map(aArmzMerge, { |jLoc| jLoc["CODIGO_ARMAZEM"] }) // pegando só o local

			aValores0 := {}
			aAdd(aValores0, "~H~")
			aAdd(aValores0, jFil["DEALER_CODE"])
			aAdd(aValores0, jArm["CODIGO_JD_ARMAZEM"])
			aAdd(aValores0, cMesFiscal)
			aAdd(aValores0, SPACE(10))
			aAdd(aValores0, "1")
			aAdd(aValores0, "3")
			cLinha := MontaEDI(aValores0)
			fwrite(nHnd,EncodeUtf8(NoAcento(cLinha)))

			//
			// Demanda -- buscando demanda do dia seletivamente para evitar muita memoria
			//
			FX_DEMDATA(jFil["FILIAL"], jFil["DEALER_CODE"], jFil["SEGMENTO"], jFil["PRINCIPAL"], cTblDadosAdc, aLocMap)
			OA5050024_OJD06HTRes(jFil["SEGMENTO"], aLocMap)

			for nCntFor := 1 to Len(aVetCods)

				aDados := aVetCods[nCntFor]
				nQtdResBal  := 0
				nQtdOficina := 0
				nCusMed     := 0
				nEstMin     := 0
				nEstMax     := 0

				SB2->(DBSeek(aDados[18] + aDados[2] + jArm["CODIGO_ARMAZEM"]))
				dDateAdded := stod(aDados[17])
				if Alltrim(cTblDadosAdc) = "SBZ"
					SBZ->(DBSeek(aDados[18] + aDados[2]))
					if SBZ->(found())
						nEstMin := SBZ->BZ_EMIN
						nEstMax := SBZ->BZ_EMAX
					endif
				endif
				if SB2->(found())
					nCusMed := SB2->B2_CM1
				endif
				cLocacao := aDados[21]

				aValores1 := {}
				aAdd(aValores1, "~P~")
				aAdd(aValores1, aDados[ 2])
				aAdd(aValores1, aDados[27])
				aAdd(aValores1, aDados[28] + aDados[19]) // 04 - pedidos a chegar+transferencias
				aAdd(aValores1, aDados[26])              // 05 - nQtdOficina reservad
				aAdd(aValores1, aDados[25] + aDados[20]) // 06 - nQtdBal reservad
				aAdd(aValores1, aDados[07])              // 07 - Vendas balcao + vendas oficina
				aAdd(aValores1, aDados[13])              // 08 - hits balcao + hits oficina
				aAdd(aValores1, aDados[14])              // 09 - vendas perdidas
				aAdd(aValores1, aDados[15])              // 10 - hits perdidos
				aAdd(aValores1, aDados[08])              // 11 - ...
				aAdd(aValores1, cLocacao)                // 12
				aAdd(aValores1, "")                      // 13
				aAdd(aValores1, IIF(aDados[16]=="1",0, IIF(SB2->B2_QATU <= 0, 0,SB2->B2_CM1/SB2->B2_QATU) )) //  14
				aAdd(aValores1, IIF(aDados[16]=="1",0, aDados[8] )) //  15
				aAdd(aValores1, IIF(aDados[16]=="1","", aDados[6] )) //  16
				aAdd(aValores1, "" ) //  17
				aAdd(aValores1, "C" ) //  18
				aAdd(aValores1, 0 ) //  19
				aAdd(aValores1, IIF(aDados[11]>0,aDados[11],nCusMed) ) // 20
				aAdd(aValores1, "") // 21
				aAdd(aValores1, "") // 22
				aAdd(aValores1, aDados[24]) // 23 - Reserved Hits Work Orders  - hits reservados oficina
				aAdd(aValores1, aDados[23]) // 24 - Reserved Hits Part Tickets - Hits reservados balcão
				// 1.3
				aAdd(aValores1, nCusMed)
				//
				if cTipoExt <> "D" .or. FX_TemDevolu(cFilAnt, aDados[ 2] /*codigo do item*/)
					aDemanda := aClone(aMod36Dem) // clona

					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery36 + "     AND  VB8_FILIAL = '" + aDados[18] + "' AND VB8_SEGMTO = '"+jFil["SEGMENTO"]+"' AND VB8_PRODUT = '" + aDados[2] + "' AND VB8_NNRCOD = '"+jArm["CODIGO_ARMAZEM"]+"' GROUP BY VB8_MES, VB8_ANO, VB8_NNRCOD ORDER BY VB8_ANO DESC, VB8_MES DESC" ), cQryAl002, .F., .T. )
					while !(cQryAl002)->(eof())
						nPos := aScan(aDemanda,{|x| x[5] == VAL((cQryAl002)->(VB8_MES)) .and. x[6] == VAL((cQryAl002)->(VB8_ANO)) })
						if nPos > 0
							aDemanda[nPos,1] += (cQryAl002)->(VB8_VDAB)   + (cQryAl002)->(VB8_VDAO)
							aDemanda[nPos,2] += (cQryAl002)->(VB8_HITSB)  + (cQryAl002)->(VB8_HITSO)
							aDemanda[nPos,3] += (cQryAl002)->(VB8_VDPERB) + (cQryAl002)->(VB8_VDPERO)
							aDemanda[nPos,4] += (cQryAl002)->(VB8_HIPERB) + (cQryAl002)->(VB8_HIPERO)
						endif
						(cQryAl002)->(DBSkip())
					enddo
					//
					(cQryAl002)->(DBCloseArea())
					//
					// Conta quantidade de meses que teve entrada na peça, se nunca entrou é zero, se entrou a 1 mes é 1 e etc.... não é por demanda como era feito antes.
					// Leonardo da Jd me orientou.
					nQtdMeses := 0
					dDataCnt  := dDataBase
					if dDateAdded > dDataCnt
						nQtdMeses:= 0
					else
						for nCntFor2 := 1 to 37
							if YEAR(dDataCnt) == YEAR(dDateAdded) .AND. MONTH(dDataCnt) == MONTH(dDateAdded)
								nQtdMeses := nCntFor2
								exit
							Else
								dDataCnt := oUtil:RemoveMeses(dDataCnt, 1)
							EndIf
						next
						if nQtdMeses >= 1 .AND. nQtdMeses <= 37
							nQtdMeses := nQtdMeses - 1
						else
							nQtdMeses := 36
						EndIf
					endif
					//
					aAdd(aValores1, "%%%")
					aAdd(aValores1, "")
					aAdd(aValores1, "")
					aAdd(aValores1, "")
					aAdd(aValores1, Left(dtos(dDateAdded),4)+"-"+SUBS(dtos(dDateAdded),5,2)+"-"+Right(dtos(dDateAdded),2) )
					aAdd(aValores1, aDados[4] ) // B1_GRUPO
					aAdd(aValores1, nEstMin)
					aAdd(aValores1, nEstMax)
					aAdd(aValores1, nQtdMeses)
					aAdd(aValores1, 0)
					for nCntFor2 := 1 to 36
						If nCntFor2 > nQtdMeses
						Else
							aDadosMes := aDemanda[nCntFor2]
							If aDadosMes[1] > 0 // performance, não busca devolução se não teve venda, pois como abate no mes da venda, se vendeu 0 não tem como existir devolução valida
								cAno := ALLTRIM( STR(aDadosMes[6]) )
								cMes := ALLTRIM( STR(aDadosMes[5]) )

								aDevData := {0,0} // somatoria das devolucoes devido a N armazens
								for nZ := 1 to len(aLocMap)// fazendo a soma das devolucoes de todos os armazens para unificar depois

									aFXDevData := FX_DevData(aDados[18], aDados[2], aLocMap[nZ]/*NNRCOD*/, STOD(cAno + STRZERO(VAL(cMes),2) + "01"), .F., jFil["SEGMENTO"])
									aDevData[1] += aFXDevData[1]
									aDevData[2] += aFXDevData[2]
								next

								aDadosMes[1] -= aDevData[1]
								aDadosMes[2] -= aDevData[2]
							EndIf

							aAdd(aValores1, NegToZero(aDadosMes[1])) // vendas
							aAdd(aValores1, NegToZero(aDadosMes[2])) // hits
							aAdd(aValores1, NegToZero(aDadosMes[3])) // vendas perdidas
							aAdd(aValores1, NegToZero(aDadosMes[4])) // hits perdidos
						Endif
					next
					aAdd(aValores1, "CLOSE" )
				endif
				//
				IIF( MOD(nCntFor, 1000) == 0, oLogger:Log({'TIMESTAMP', " |> Fim escrita 36 meses, escrevendo no arquivo"}),  )
				cLinha := MontaEDI(aValores1)
				fwrite(nHnd,EncodeUtf8(NoAcento(cLinha)))
			next
		next // armazem
	next

	oLogger:Log({'TIMESTAMP', "Montando Arquivo"})
	oLogger:Log({'TIMESTAMP', "Tamanho do vetor" + STR(LEN(aVetCods)) })

	FClose(nHnd)

	// A pedido do leonardo da jd, o nome do arquivo deve ficar com a data da finalizacao da geracao
	dDataBase := DATE() // atualiza database para geração do nome correto
	cNomeAtualizado := "DLR2JD_DPMEXT_" + ;
		cTipoExt + "_" + ;
		cAccount + "_" + ;
		dtos(ddatabase) + "_" + ;
		SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + cExtensao

	if OA5050064_CopiaArquivo(cFileTemp, lower(cSavePath)+UPPER(cNomeAtualizado))
		FERASE(cFileTemp)
	endif

	iif (IsSrvUnix(),CHMOD( cFileDest , 666,,.f. ),CHMOD( cFileDest , 2,,.f. ))
	iif (IsSrvUnix(),CHMOD( cFileTemp , 666,,.f. ),CHMOD( cFileTemp , 2,,.f. ))
	FRenameEx(cFileDest , lower(cSavePath)+UPPER(cNomeAtualizado))



	OA5000052_GravaDiretorioOrigem(cSavePath,"OFINJD06")

	conout("Arquivo gerado em: " + cFileDest)
	conout("Arquivo renomeado em: " + UPPER(cSavePath+cNomeAtualizado))

	TCSQLEXEC(" UPDATE " + RetSqlName('VQL') + " SET VQL_DATAF = '"+DTOS(dDataBase)+"' WHERE VQL_AGROUP IN ('DPMXFER_DPE', 'DPMORD_DPE') AND VQL_TIPO = 'CODIGO_DPE' AND VQL_DATAF = ' '  ")
	TCSQLEXEC(" UPDATE " + RetSqlName('VB8') + " set VB8_FLGENV = '*' where VB8_FLGENV = ' ' ") // joga todos os registros como enviados a JD para geração de delta

	if ! lAuto
		MsgInfo(STR0007 /*"A operação foi realizada com sucesso"*/ + " " + FWTimeStamp(3),STR0008 /*"Atenção"*/)
	endif

	conout("OFINJD06 -> Sucesso" + " ("+time()+")")
	oLogger:Log({'TIMESTAMP', "OFINJD06 -> Sucesso" + " ("+time()+")"})

return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | MontaEDI   | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |                                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MontaEDI(aDadlinha)
	Local nCntFor := 1
	Local nTam    := LEN(aDadlinha)
	Local cLinha  := ""
	Local uVal    := Nil

	For nCntFor := 1 to LEN(aDadlinha)
		uVal   := aDadlinha[nCntFor]
		cValor := IIF(VALTYPE(uVal) == "C", ALLTRIM(uVal), ALLTRIM(STR(uVal)))
		cValor := STRTRAN(cValor , CHR(09), "")

		if cValor == "CLOSE"
			exit
		else
			cLinha += cValor + IIF(nCntFor == nTam, "", CHR(09))
		endif
	Next
return cLinha + CHR(13) + CHR(10)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FX_DevData | Autor |  Vinicius Gati        | Data | 30/10/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##| Retorna quantidade de hits e qtd devolvida (tudo a subtrair)            |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FX_DevData(cFil, cCODB1, cNNRCOD, dData, xVar /*descontinuado*/, cSegmento)
	local cSearch    := ""

	if empty(cSegmento)
		cSegmento := "2" // padrao ambos para comportamento antigo (brasil)
	endif

	cSearch := alltrim(cFil) + alltrim(LEFT(DTOS(dData), 6)) + alltrim(cCODB1) + alltrim(cNNRCOD) + cSegmento

	if ! Empty(oDevObj[cSearch])
		aValues := oDevObj[cSearch]
		if ! Empty(aValues)
			return aValues
		endif
	endif
Return {0,0}

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FX_DEMDATA | Autor |  Vinicius Gati        | Data | 30/10/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##| Busca a demanda das filiais tambem com produtos sem demanda com estoque |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FX_DEMDATA(cFILIAL, cDEALERCODE, cSEGMENTO, cPRINCIPAL, cTabelaAdc, aLocais)
	Local aDadPeca      := Nil
	Local cQuery        := ""
	Local cFields       := ""
	Local cFilD         := ""
	Local cDtAdded      := ''
	Local cCposGrp      := ""
	Local cGroupC       := ""
	Local cCodFab       := ""
	Local aFilSB2       := {}
	Local aFilSB5       := {}
	Local aFilSBZ       := {}
	Local cFilSB2       := ""
	Local cFilSB5       := ""
	Local cFilSBZ       := ""
	Local cFilSB1       := ""
	Local cFilVB8       := ""
	Local cFilAux       := ""
	Local nFilSB2       := 0
	Local nFilSB5       := 0
	Local nFilSBZ       := 0
	Local nFilSB1       := 0
	Local nFilVB8       := 0
	Local nCntFor       := 0
	Local lOJD06VPC     := FindFunction( "P_OJD06VPC" )
	Local nVlrPec       := 0
	Local cAl           := GetNextAlias()
	Local nPPPJD        := 0
	Local lVL0PPPJD     := .F.
	Local nX            := 1
	Local aLocMap       := Nil
	Default cFILIAL     := ""
	Default cDEALERCODE := ""
	Default cSEGMENTO   := "2" // padrao ambos para comportamento antigo (brasil)
	Default cPRINCIPAL  := ""
	Default aLocais     := {} 

	If FWAliasInDic("VL0", .F.) //Complementos DMS - Cadastro de Produtos
		DbSelectArea("VL0")
		DbSetorder(1)
		lVL0PPPJD := VL0->(FieldPos('VL0_PPPJD')) > 0
	EndIf

	if empty(cFILIAL)
		oLogger:Log({'TIMESTAMP', "FILIAL NAO INFORMADA"})
		return
	endif

	if empty(cDEALERCODE)
		oLogger:Log({'TIMESTAMP', "DEALER CODE NAO INFORMADO PARA FILIAL : " + cFILIAL})
		return
	endif

	if empty(cTabelaAdc)
		oLogger:Log({'TIMESTAMP', "TABELA DE DADOS ADC. NAO INFORMADA PARA FILIAL : " + cFILIAL})
		return
	endif

	if cTblDadosAdc == "SBZ"
		cCposGrp += "BZ_PRIENT, BZ_LOCALI2 "
	else
		cCposGrp += "B5_DTADDED, B5_LOCALI2 "
	endif

	aVetCods := {}

	oLogger:Log({"=================="})
	oLogger:Log({"==Query do delta=="})
	oLogger:Log({"=================="})
	oLogger:Log({"Tipo extração: '" + cTipoExt + "' "})
	oLogger:Log({"Emulado: '" + IIF(lEmuPrism, "SIM", "NÃO") + "' "})
	oLogger:Log({"=================="})

	// tratamento para adequar NNR com B2 pois vou ter que fazer 
	// uma query para somar todos os saldos de N filiais
	cFilNNR  := oSqlHlp:CompatFunc('SUBSTR') + "(B2_FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('NNR')))))+")"
	// sao ajustes para comparacao de filiais de forma dinamica pois nessa query abaixo eu trago mais de 1 filial
	// por conta da configuracao de filial armazem do DPM
	// o campo FILIAL é da tabela de cache de pecas e é exclusiva, por isso é usada de base de comparacao
	// cFilSBM  := oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('SBM')))))+")"
	//cFilSBZ  := oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('SBZ')))))+")"
	//cFilSB5  := oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(len(alltrim(xFilial('SB5')))))+")"

	nFilSBZ  := len(alltrim(xFilial('SBZ')))
	cFilSBZ  := oSqlHlp:CompatFunc('SUBSTR') + "(BZ.BZ_FILIAL, 1, "+alltrim(cvaltochar(nFilSBZ))+")"

	nFilSB5  := len(alltrim(xFilial('SB5')))
	cFilSB5  := oSqlHlp:CompatFunc('SUBSTR') + "(B5.B5_FILIAL, 1, "+alltrim(cvaltochar(nFilSB5))+")"

	nFilSB2  := len(alltrim(xFilial('SB2')))
	cFilSB2  := oSqlHlp:CompatFunc('SUBSTR') + "(B2_FILIAL, 1, "+alltrim(cvaltochar(nFilSB2))+")"
	
	nFilVB8  := len(alltrim(xFilial('VB8')))
	cFilVB8  := oSqlHlp:CompatFunc('SUBSTR') + "(VB8DELTA.VB8_FILIAL, 1, "+alltrim(cvaltochar(nFilVB8))+") = "
	cFilVB8  += oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(nFilVB8))+")"

	nFilSB1  := len(alltrim(xFilial('SB1')))
	cFilSB1  := oSqlHlp:CompatFunc('SUBSTR') + "(SB1.B1_FILIAL, 1, "+alltrim(cvaltochar(nFilSB1))+") = "
	cFilSB1  += oSqlHlp:CompatFunc('SUBSTR') + "(FILIAL, 1, "+alltrim(cvaltochar(nFilSB1))+")"

	// Isto é para usar na query da peça para trazer o
	// saldo da filial atual mais as filiais armazens
	aFilArms := oDpm:GetFilArms(cFilAnt)
	aFilArms := oArHelp:Map(aFilArms, {|aArm| aArm[1]})
	aadd(aFilArms, cFilAnt)
	For nCntFor := 1 to len(aFilArms)
		cFilAux := padr(aFilArms[nCntFor],nFilSBZ)
		If aScan(aFilSBZ,cFilAux) == 0
			aAdd(aFilSBZ,cFilAux)
		EndIf
		cFilAux := padr(aFilArms[nCntFor],nFilSB5)
		If aScan(aFilSB5,cFilAux) == 0
			aAdd(aFilSB5,cFilAux)
		EndIf
		cFilAux := padr(aFilArms[nCntFor],nFilSB2)
		If aScan(aFilSB2,cFilAux) == 0
			aAdd(aFilSB2,cFilAux)
		EndIf
	Next

	cInLocais := "('" + oArHelp:Join(aLocais, "','") + "')"

	if cTblDadosAdc == "SBZ"
		cFields += " coalesce((select MIN(BZ_PRIENT) from "+RetSqlName('SBZ')+" BZ where "+cFilSBZ+" IN ('"+ oArHelp:Join( aFilSBZ, "','" ) +"') AND BZ.BZ_COD = B1_COD AND BZ.BZ_PRIENT != ' ' AND BZ.D_E_L_E_T_ = ' '), '19000101') AS DTADDED, "
	else
		cFields += " coalesce((select MIN(B5_DTADDED) from "+RetSqlName('SB5')+" B5 where "+cFilSB5+" IN ('"+ oArHelp:Join( aFilSB5, "','" ) +"') AND B5.B5_COD = B1_COD AND B5.B5_DTADDED != ' ' AND B5.D_E_L_E_T_ = ' '), '19000101') AS DTADDED, "
	endif

	// Subquery para cálculo do saldo em estoque
	cSubSelSaldo := " ("
	cSubSelSaldo += "    SELECT COALESCE(SUM(B2_QATU), 0) "
	cSubSelSaldo += "    FROM " + oSqlHlp:NoLock('SB2')
	cSubSelSaldo += "    JOIN " + oSqlHlp:NoLock('NNR') 
	cSubSelSaldo += "        ON NNR_FILIAL = '" + xFilial('NNR') + "' "
	cSubSelSaldo += "        AND NNR_CODIGO = B2_LOCAL "
	cSubSelSaldo += "        AND NNR.NNR_VDADMS = '1' "
	cSubSelSaldo += "        AND NNR.D_E_L_E_T_ = ' ' "
	cSubSelSaldo += "    WHERE " + cFilSB2 + " IN ('" + oArHelp:Join(aFilSB2, "','") + "') "
	cSubSelSaldo += "        AND B2_COD = B1_COD "
	cSubSelSaldo += "        AND B2_LOCAL IN " + cInLocais
	cSubSelSaldo += "        AND SB2.D_E_L_E_T_ = ' ' "
	cSubSelSaldo += ") QTD_EST "

	// Subquery para cálculo do estoque encomendado
	cSubEstEnc := " ("
	cSubEstEnc += "    SELECT COALESCE(SUM(C7_QUANT - C7_QUJE), 0) "
	cSubEstEnc += "    FROM " + oSqlHlp:NoLock('SC7')
	cSubEstEnc += "    WHERE C7_FILIAL = '" + xFilial('SC7') + "' "
	cSubEstEnc += "        AND C7_PRODUTO = B1_COD "
	cSubEstEnc += "        AND D_E_L_E_T_ = ' ' "
	cSubEstEnc += "        AND C7_ENCER = ' ' "
	cSubEstEnc += "        AND C7_RESIDUO = ' ' "
	cSubEstEnc += "        AND C7_QUANT > C7_QUJE "
	cSubEstEnc += "        AND C7_LOCAL IN " + cInLocais
	// Condição para incluir pedidos de direct shipment
	cSubEstEnc += "        AND (CASE WHEN B5_ISDSHIP = '1' THEN 'DSHIP' ELSE C7_PEDFAB END) <> ' '"

	If ( ExistBlock("OJD06EORD") )  // Insere condição customizada no levantamento de Orders
		cQryORD := ExecBlock("OJD06EORD",.f.,.f.,{cSubEstEnc})
		oLogger:Log({'TIMESTAMP', "|> OJD06EORD: " + cQryORD})
		If !Empty(cQryORD)
			cSubEstEnc += " AND " + cQryORD
		EndIf
	EndIf
	cSubEstEnc   += " ) QTD_ESTENC "

	cQuery := " SELECT "
	cQuery += " COALESCE(VB8_FILIAL,  '"+xFilial("VS1")+"') as VB8_FILIAL, "+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES'})+" as DATA, "
	cQuery += cFields
	cQuery += " B1_COD, "
	cQuery += " B1_QE, "
	cQuery += " B1_CODFAB, "
	cQuery += " B1_CODITE, "
	cQuery += " B1_GRUPO, "
	cQuery += " B1_GROUPC, "
	cQuery += " B1_PRV1, "
	cQuery += " B1_LOCPAD, "
	cQuery += " B1_CONV, "
	cQuery += " B1_TIPCONV, "
	cQuery += IIf(lVL0PPPJD, "COALESCE(VL0_PPPJD, '0') VL0_PPPJD, ", " ")
	cQuery += " MAX(LOCACAO) LOCACAO, "
	cQuery += " MAX(BM_PROORI) BM_PROORI, "
	cQuery += " MAX(VB8_SEGMTO) VB8_SEGMTO, "
	cQuery += " MAX(VB8_NNRCOD) VB8_NNRCOD, "
	cQuery += " MAX(B5_ISDSHIP) B5_ISDSHIP, "
	cQuery += " COALESCE( SUM(VB8_VDAB  ), 0) VB8_VDAB, "
	cQuery += " COALESCE( SUM(VB8_VDAO  ), 0) VB8_VDAO, "
	cQuery += " COALESCE( SUM(VB8_HITSB ), 0) VB8_HITSB, "
	cQuery += " COALESCE( SUM(VB8_HITSO ), 0) VB8_HITSO, "
	cQuery += " COALESCE( SUM(VB8_VDPERB), 0) VB8_VDPERB, "
	cQuery += " COALESCE( SUM(VB8_VDPERO), 0) VB8_VDPERO, "
	cQuery += " COALESCE( SUM(VB8_HIPERB), 0) VB8_HIPERB, "
	cQuery += " COALESCE( SUM(VB8_HIPERO), 0) VB8_HIPERO, "
	cQuery += cSubSelSaldo + ", "
	cQuery += cSubEstEnc
	cQuery += "       FROM "+oSqlHlp:NoLock('SB1')
	cQuery += "       JOIN "+oDpePecas:TableName()+" ON    FILIAL in ('"+ oArHelp:Join( aFilArms, "','" ) +"') AND PRODUTO    = B1_COD AND ARMAZEM in "+cInLocais+" AND DATAGER = '"+DTOS(dDatabase)+"' "
	cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON BM_FILIAL  = '"+xFilial('SBM')+"' AND B1_GRUPO   = BM_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += "       JOIN "+oSqlHlp:NoLock('SB5')+" ON B5_FILIAL  = '"+xFilial('SB5')+"' AND B5_COD     = B1_COD   AND SB5.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN (
	cQuery += "     SELECT VB8_MES,VB8_ANO,VB8_VDAB,VB8_VDAO,VB8_HITSB,VB8_HITSO,VB8_VDPERB,VB8_VDPERO,VB8_HIPERB,VB8_HIPERO,VB8_DIA,VB8_FILIAL,VB8_PRODUT,VB8_FLGENV,VB8_NNRCOD "
	if cPRINCIPAL == "1" .and. ! empty(cSEGMENTO)
		cQuery += " ,case when VB8_SEGMTO = ' ' OR VB8_SEGMTO IS NULL then '"+oRpm:GetSegmentoPrincipal(cFILIAL)+"' else VB8_SEGMTO end as VB8_SEGMTO "
	else
		cQuery += " ,VB8_SEGMTO "
	endif
	cQuery += "       FROM "+ oSqlHlp:NoLock('VB8', 'VB8J')
	cQuery += "      WHERE VB8J.VB8_SEGMTO = '"+cSEGMENTO+"' "
	cQuery += "        AND VB8J.VB8_NNRCOD IN "+cInLocais
	cQuery += "        AND VB8J.D_E_L_E_T_ = ' ' "
	
	cQuery += " ) VB8 ON VB8_FILIAL = '"+xFilial('VB8')+"' AND VB8_PRODUT = B1_COD   AND VB8_ANO = '"+ALLTRIM(STR(YEAR(dDatabase)))+"' AND VB8_MES = '"+ALLTRIM(STRZERO(MONTH(dDatabase), 2))+"' "
	If lVL0PPPJD
      cQuery += "  LEFT JOIN "+oSqlHlp:NoLock('VL0')+" ON VL0_FILIAL = '"+xFilial('VL0')+"' AND VL0_CODPEC = B1_COD   AND VL0.D_E_L_E_T_= ' ' "
    EndIf
	cQuery += "      WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery += "        AND "+cFilSB1

	if (oDpe:isPrism() .OR. lEmuPrism) .AND. cTipoExt == "D"
		cQuery += " AND VB8_PRODUT IN (SELECT DISTINCT VB8_PRODUT from "+oSqlHlp:NoLock('VB8', 'VB8DELTA')+" where "+cFilVB8+" AND VB8DELTA.VB8_FLGENV = ' ' AND VB8DELTA.D_E_L_E_T_ = ' ' ) "
	EndIf

	cQuery += " GROUP BY COALESCE(VB8_FILIAL,  '"+xFilial("VS1")+"'), "+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES'})+", B1_COD, B1_QE, B1_CODFAB, B1_CODITE, B1_GRUPO, B1_GROUPC, B1_PRV1, B1_LOCPAD, B1_CONV, BM_PROORI, VB8_SEGMTO, VB8_NNRCOD, B5_ISDSHIP, B1_TIPCONV "+IIf(lVL0PPPJD, ",VL0_PPPJD ", "")
	oLogger:Log({'TIMESTAMP', cQuery})
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
	(cAl)->(DbGoTop())
	while !( (cAl)->(eof()) )

		// alguns registros virão sem VB8_FILIAL isso é normal se a peças não tiveram mov. no mes
		cFilD    := IIF(EMPTY((cAl)->(VB8_FILIAL)), xFilial('VB8')     , (cAl)->(VB8_FILIAL))
		cDtAdded := IIF(EMPTY((cAl)->(DTADDED))   , '19000101'         , (cAl)->(DTADDED))
		cGroupC  := IIF(EMPTY((cAl)->(B1_GROUPC)) , (cAl)->(B1_GRUPO)  , (cAl)->(B1_GROUPC))
		cCodFab  := IIF(Empty((cAl)->(B1_CODFAB)) , (cAl)->(B1_CODITE) , (cAl)->(B1_CODFAB))
		cLocReg  := IIF(Empty((cAl)->VB8_NNRCOD)  , "01", (cAl)->VB8_NNRCOD)

		nPPPJD := 1
		If lVL0PPPJD
			If (cAl)->(VL0_PPPJD) == "1"
				If (cAl)->(B1_TIPCONV) == "D" .And. (cAl)->(B1_CONV) > 0
					nPPPJD  := (cAl)->(B1_CONV)
				EndIf
			EndIf
		EndIf

		nVlrPec := (cAl)->(B1_PRV1)
		If lOJD06VPC
			nVlrPec := P_OJD06VPC((cAl)->(B1_COD),nVlrPec)
		EndIf

		aDadPeca := {;
			.f.,;                                    // 1
			(cAl)->(B1_COD),;                        // 2
			(cAl)->(B1_CODITE),;                     // 3
			cGroupC,;                                // 4
			"",;                                     // 5
			cCodFab,;                                // 6
			0,;                                      // 7 vendas
			nPPPJD,;                                 // 8 /*Aqui era enviado B1_QE, se preenchido*/
			0,;                                      // 9
			0,;                                      // 10
			nVlrPec,;                                // 11
			(cAl)->(B1_LOCPAD),;                     // 12
			0,;                                      // 13
			0,;                                      // 14
			0,;                                      // 15
			(cAl)->(BM_PROORI),;                     // 16
			cDtAdded,;                               // 17
			cFilD,;                                  // 18
			0,0,;                                    // 19,20
			(cAl)->(LOCACAO),;                       // 21
			(cAl)->(B1_GRUPO),;                      // 22
			0,0,;                                    // hits reservados oficina e balcao //23 e 24
			0,0,;                                    // quantidade reservados oficina e balcao //25 e 26
			(cAl)->(QTD_EST), (cAl)->(QTD_ESTENC),;  // 27 e 28 saldo e estoque encomendado pedidos
			cLocReg ; // 29
		}

		If (cAl)->(DATA) $ LEFT(DTOS(dDatabase), 6)
			aDadPeca[ 7] += (cAl)->(VB8_VDAB)   + (cAl)->(VB8_VDAO)
			aDadPeca[13] += (cAl)->(VB8_HITSB)  + (cAl)->(VB8_HITSO)
			aDadPeca[14] += (cAl)->(VB8_VDPERB) + (cAl)->(VB8_VDPERO)
			aDadPeca[15] += (cAl)->(VB8_HIPERB) + (cAl)->(VB8_HIPERO)
			if ((cAl)->(VB8_VDAB) + (cAl)->(VB8_VDAO)) > 0 .AND. cTipoExt <> "D" // devolucao
				aDevData := {0,0} // somatoria das devolucoes devido a N armazens

				for nX := 1 to len(aLocMap)// fazendo a soma das devolucoes de todos os armazens para unificar depois
					aFXDevData := FX_DevData((cAl)->(VB8_FILIAL), (cAl)->(B1_COD), aLocMap[nX], dDatabase, .F., cSEGMENTO)
					aDevData[1] += aFXDevData[1]
					aDevData[2] += aFXDevData[2]
				next

				aDadPeca[ 7] -= aDevData[1]
				aDadPeca[13] -= aDevData[2]
			EndIf
		EndIf

		If LEN(aTransf) > 0
			nIdxTransf := aScan(aTransf,{ |x| x[1] == cFilD .AND. (cAl)->(B1_COD) == x[2] .and. (cAl)->VB8_NNRCOD == x[3] })
			If nIdxTransf > 0
				aDadPeca[19] += aTransf[nIdxTransf,4]
				aDadPeca[20] += aTransf[nIdxTransf,5]
			EndIf
		EndIf

		aAdd(aVetCods, aDadPeca)
		(cAl)->(DBSkip())
	EndDo

	(cAl)->(dbCloseArea())
	oLogger:Log({'TIMESTAMP', "NÚMERO DE LINHAS DE INFORMAÇÃO ENCONTRADAS:" + ALLTRIM(STR(LEN(aVetCods))) })
Return

/*/{Protheus.doc} FX_TemDevolu
  Verifica se tem devolução em qualquer data para enviar 36m no delta
  
  @type function
  @author Vinicius Gati
  @since 13/01/2025
/*/
Static Function FX_TemDevolu(cFil, cCODB1)
  uVal := oDevPecs[alltrim(cFil) + alltrim(cCODB1)]
  if valtype(uVal) != "U"
    return .T.
  endif
Return .F.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OA5050024_OJD06HTRes | Autor |  Vinicius Gati        | Data | 30/10/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##| Quantidade e hits reservados pecas provenientes de orçamentos           |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function OA5050024_OJD06HTRes(cSegmento, aLocais)
	Local cSQL  := ""
	Local cAl   := GetNextAlias()
	Local nIdx  := 1
	Local nX    := 1

	conout("  |> OFINJD06 - Inicio coleta reservas filial: "+cFilAnt+" hora:  ("+time()+")")
	for nX := 1 to len(aLocais)

		// todos os status menos em branco e C para filtrar
		cVldsts := JD06ResFases("' ', 'C'") // not in parametro
		// todos os status menos X para o filtro do loja
		cVldLj  := JD06ResFases("'X'") // not in parametro
		cSQL := OJD06QryRes(cVldsts,cVldLj, cSegmento, aLocais[nX])

		oLogger:Log({'----> Query reservas ', cSQL})
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL),cAl, .F., .T. )
		
		While !(cAl)->(EOF())
			nIdx := aScan(aVetCods, {|x| x[2] == (cAl)->(B1_COD) })
			if nIdx > 0
				aDadHit := aVetCods[ nIdx ]
				aDadHit[23] := (cAl)->(HITS_BAL)
				aDadHit[24] := (cAl)->(HITS_OFI)
				aDadHit[25] := (cAl)->(SOMA_BAL)
				aDadHit[26] := (cAl)->(SOMA_OFI)
			end

			(cAl)->(DbSkip())
		End

		OA5050014_ReqDt(aLocais[nX])

		(cAl)->(dbCloseArea())
		dbSelectArea('SB1')

	next
	conout("  |> OFINJD06 - FIM coleta reservas hora:  ("+time()+")")
Return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OA5050014_ReqDt  | Autor |  Vinicius Gati  | Data | 30/10/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##| Quantidade e hits reservados pecas provenientes de requisições          |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function OA5050014_ReqDt(cLocal)
	Local oSqlHlp := DMS_SqlHelper():New()
	Local cAl     := GetNextAlias()
	Local nIdx    := 1
	Local cQuery
	Local aDadHit

	conout("  |> OFINJD06 - Inicio coleta requisicoes filial: "+cFilAnt+" hora:  ("+time()+")")

	cQuery := " SELECT B1_COD, COUNT(*) HITS, SUM(SALDO) SOMA "
	cQuery += " FROM ( "
	cQuery += "      SELECT B1_COD, VO2_NUMOSV, SUM(CASE WHEN VO2_DEVOLU = '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) SALDO  "
	cQuery += "        FROM "+oSqlHlp:NoLock('VO3')
	cQuery += "        JOIN "+oSqlHlp:NoLock('SF4')+" ON F4_FILIAL  = '"+xFilial('SF4')+"' AND F4_CODIGO  = VO3_CODTES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "        JOIN "+oSqlHlp:NoLock('VO2')+" ON VO2_FILIAL = '"+xFilial('VO2')+"' AND VO2_NOSNUM = VO3_NOSNUM AND VO2.D_E_L_E_T_ = ' ' "
	cQuery += "        JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VO3_CODITE AND B1_GRUPO = VO3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "        JOIN "+oSqlHlp:NoLock('VSJ')+" ON VSJ_FILIAL = '"+xFilial('VSJ')+"' AND B1_GRUPO   = VSJ_GRUITE AND VSJ_CODITE = VO3_CODITE AND VO3_CODVSJ = VSJ_CODIGO AND VSJ.D_E_L_E_T_ =  ' ' " // caso não tenha VSJ vamos desconsiderar mesmo
	cQuery += "       WHERE VO3.VO3_FILIAL = '"+xFilial('VO3')+"' "
	cQuery += "         AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "         AND VO3_DATFEC = ' ' "
	cQuery += "         AND VO3_DATCAN = ' ' "
	cQuery += "       GROUP BY B1_COD, VO2_NUMOSV "
	cQuery += "      HAVING SUM(CASE WHEN VO2_DEVOLU = '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ*-1 END) > 0 "
	cQuery += " ) TB "
	cQuery += " GROUP BY B1_COD "
	cQuery += " HAVING SUM(SALDO) > 0 "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
	While !(cAl)->(EOF())
		nIdx := aScan(aVetCods, {|x| x[2] == (cAl)->(B1_COD) })
		if nIdx > 0
			aDadHit     := aVetCods[ nIdx ]
			aDadHit[24] += (cAl)->(HITS)
			aDadHit[26] += (cAl)->(SOMA)
		end

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())

	conout("  |> OFINJD06 - FIM coleta requisicoes hora:  ("+time()+")")
Return .T.

/*/{Protheus.doc} NegToZero
	Essa função foi criada pois a JD pediu para que não vá valores negativos no parts data
	Não tem como garantirmos isto pois pode acontecer de uma venda ser alterada após processamento
	e o valor faturado ficar diferente do valor devolvido futuramente causando valores negativo.
	
	@type function
	@author Vinicius Gati
	@since 13/09/2017
/*/
Static Function NegToZero(nVal)
	Default nVal := 0
	if nVal < 0
		nVal := 0
	end
Return nVal


/*/{Protheus.doc} OJD06QryRes

	@type function
	@author Vinicius Gati
	@since 05/06/2023
/*/

Static Function OJD06QryRes(cVldsts,cVldLj, cSEGMENTO, cLOCAL)
	Local cSQL := ""

	cSQL := "SELECT B1_COD, COUNT(CASE OPERACAO WHEN 'BAL' THEN HITS ELSE null END) HITS_BAL,   SUM(CASE OPERACAO WHEN 'BAL' THEN SOMA ELSE 0 END) SOMA_BAL,"
	cSQL += "               COUNT(CASE OPERACAO WHEN 'OFI' THEN HITS ELSE null END) HITS_OFI,   SUM(CASE OPERACAO WHEN 'OFI' THEN SOMA ELSE 0 END) SOMA_OFI"
	cSQL += "  FROM  "
	cSQL += "  ( "
	cSQL += "    SELECT OPERACAO, VS1_STATUS, B1_COD, COUNT(*) HITS, SUM(CONTA) SOMA  "
	cSQL += "    FROM ( "
	// Orçamento balcão 
	cSQL += "           SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ' ' THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA "
	cSQL += "             FROM "+oSqlHlp:NoLock('VB2')
	cSQL += "             JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND B1_GRUPO = VB2_GRUITE AND B1_CODITE = VB2_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "             JOIN "+oDpePecas:TableName()+" ON FILIAL        = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
	cSQL += "             JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VB2_NUMORC AND VS1_SEGMTO = '"+cSEGMENTO+"' AND VS1.D_E_L_E_T_ = ' ' "
	cSQL += "             JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3.VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = VS1_NUMORC AND VS3_CODITE = VB2_CODITE AND VS3_GRUITE = VB2_GRUITE AND VS3.D_E_L_E_T_ = ' ' "
	cSQL += "            WHERE VB2.VB2_FILIAL='"+xFilial('VB2')+"' AND VS3_LOCAL = '"+cLOCAL+"' AND VB2.D_E_L_E_T_ = ' ' "
	cSQL += "              AND VS1_TIPORC = '1' AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
	cSQL += "            GROUP BY VS1_STATUS, B1_COD "
	// Orçamento oficina
	cSQL += "       UNION ALL  "
	cSQL += "           SELECT VS1_STATUS, B1_COD, 'OFI' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ' ' THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA " // quando oficina é necessário usar a conta
	cSQL += "             FROM "+oSqlHlp:NoLock('VB2')
	cSQL += "             JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND B1_GRUPO = VB2_GRUITE AND B1_CODITE = VB2_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "             JOIN "+oDpePecas:TableName()+" ON FILIAL        = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
	cSQL += "             JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VB2_NUMORC AND VS1_SEGMTO = '"+cSEGMENTO+"' AND VS1.D_E_L_E_T_ = ' ' "
	cSQL += "             JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3.VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = VS1_NUMORC AND VS3_CODITE = VB2_CODITE AND VS3_GRUITE = VB2_GRUITE AND VS3.D_E_L_E_T_ = ' ' "
	cSQL += "            WHERE VB2.VB2_FILIAL='"+xFilial('VB2')+"' AND VS3_LOCAL = '"+cLOCAL+"' AND VB2.D_E_L_E_T_ = ' ' "
	cSQL += "              AND VS1_TIPORC = '2' AND VS1_NUMOSV = ' ' " // requisicao nao entra aqui vai ser query separada, esta abaixo "
	cSQL += "              AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
	cSQL += "            GROUP BY VS1_STATUS, B1_COD "
	// Pedido
	cSQL += "       UNION ALL  "
	cSQL += "         SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ' ' THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA "
	cSQL += "           FROM "+oSqlHlp:NoLock('VB2')
	cSQL += "           JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO = VB2_GRUITE AND B1_CODITE = VB2_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "           JOIN "+oDpePecas:TableName()+" ON FILIAL        = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
	cSQL += "           JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VB2_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cSQL += "           JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3.VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = VS1_NUMORC AND VS3_CODITE = VB2_CODITE AND VS3_GRUITE = VB2_GRUITE AND VS3.D_E_L_E_T_ = ' ' "
	cSQL += "          WHERE VB2.VB2_FILIAL='"+xFilial('VB2')+"' AND VS3_LOCAL = '"+cLOCAL+"' AND VB2.D_E_L_E_T_ = ' ' AND VS1_SEGMTO = '"+cSEGMENTO+"' AND VS1.VS1_PEDSTA IN ('0', '1') "
	cSQL += "            AND VS1_TIPORC = 'P' AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
	cSQL += "            GROUP BY VS1_STATUS, B1_COD "
	// Reserva de OS sem orçamento (não requisição) 
	cSQL += "       UNION ALL  "
	cSQL += "         SELECT '0' VS1_STATUS, B1_COD, 'OFI' OPERACAO, SUM ( CASE WHEN VB3.VB3_TIPREQ <> ' ' THEN VB3.VB3_QUANT ELSE VB3.VB3_QUANT * -1 END ) AS CONTA " // quando oficina é necessário usar a conta
	cSQL += "           FROM "+oSqlHlp:NoLock('VB3')
	cSQL += "      LEFT JOIN "+oSqlHlp:NoLock('VSJ')+" ON VSJ_FILIAL = '"+xFilial('VSJ')+"' AND VSJ_CODIGO = VB3_CODVSJ AND VSJ_NNRCOD = '"+cLOCAL+"' AND VSJ.D_E_L_E_T_ = ' ' "
	cSQL += "      LEFT JOIN "+oSqlHlp:NoLock('VO1')+" ON VO1_FILIAL = '"+xFilial('VO1')+"' AND VO1_NUMOSV = VSJ_NUMOSV AND VO1_SEGMTO = '"+cSEGMENTO+"' AND VO1.D_E_L_E_T_ = ' ' "
	cSQL += "      LEFT JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO   = VB3_GRUITE AND B1_CODITE  = VB3_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "      LEFT JOIN "+oDpePecas:TableName()+" ON FILIAL     = '"+xFilial('VS3')+"' AND PRODUTO    = B1_COD     AND DATAGER    = '"+DTOS(dDatabase)+"'  AND VSJ_NNRCOD = ARMAZEM " // nunca deletado, tabela temporaria
	cSQL += "          WHERE VB3.VB3_FILIAL='"+xFilial('VB3')+"' AND SB1.B1_FILIAL  = '"+xFilial('SB1')+"' "
	cSQL += "            AND VB3.VB3_GRUITE = B1_GRUPO AND VB3.VB3_CODITE = B1_CODITE  AND VB3.D_E_L_E_T_ = ' ' "
	cSQL += "            AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "            GROUP BY B1_COD "
	// Reservas de transferências 
	cSQL += "       UNION ALL  "
	cSQL += "         SELECT VS1_STATUS, B1_COD, 'BAL' OPERACAO, SUM ( CASE WHEN VB2.VB2_TIPREQ <> ' ' THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS CONTA "
	cSQL += "           FROM "+oSqlHlp:NoLock('VB2')
	cSQL += "           JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO = VB2_GRUITE AND B1_CODITE = VB2_CODITE  AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "           JOIN "+oDpePecas:TableName()+" ON FILIAL         = '"+xFilial('VS3')+"' AND PRODUTO  = B1_COD     AND DATAGER        = '"+DTOS(dDatabase)+"' " // nunca deletado, tabela temporaria
	cSQL += "           JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1.VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = VB2_NUMORC AND VS1_SEGMTO = '"+cSEGMENTO+"' AND VS1.D_E_L_E_T_ = ' ' "
	cSQL += "           JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3.VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = VS1_NUMORC AND VS3_CODITE = VB2_CODITE AND VS3_GRUITE = VB2_GRUITE AND VS3.D_E_L_E_T_ = ' ' "
	cSQL += "          WHERE VB2.VB2_FILIAL='"+xFilial('VB2')+"' AND VS3_LOCAL = '"+cLOCAL+"' AND VB2.D_E_L_E_T_ = ' ' "
	cSQL += "            AND VS1_TIPORC = '3' AND (CASE WHEN VS1_NUMNFI = ' ' THEN '0' ELSE VS1_STATUS END ) IN (" + cVldLj + ") "  // só X não entra // tratamento do loja
	cSQL += "            GROUP BY VS1_STATUS, B1_COD "

	cSQL += "    ) UNIONS_RESORC "
	cSQL += "    WHERE VS1_STATUS IN (" + cVldsts + ") "
	cSQL += "    GROUP BY OPERACAO, VS1_STATUS, B1_COD "
	// removendo lixos/erros 
	cSQL += "      HAVING COUNT(*) <= SUM(CONTA) AND SUM(CONTA) > 0 "
	cSQL += "  ) VE6   "
	cSQL += "  GROUP BY B1_COD  "
Return cSQL

function OA5050064_CopiaArquivo(cArq, cTo)
	local nHandle := FCreate(cTo, , , .F.)
	
	If nHandle == -1
		conout("Sem permissão para criar arquivo no destino: " + cTo)
		return .f.
	endif
	oFile := FwFileReader():New(Alltrim(cArq))
	if oFile:Open()
		while oFile:hasLine()
			cStr := oFile:GetLine()
			FWrite(nHandle, cStr + chr(13) + chr(10))
		end
		conout("Arquivo copiado com sucesso para: "+ cTo)
	else
		conout("Arquivo movido: " + cArq)
		return .f.
	endif
	FClose(nHandle)
	oFile:Close()
return .t.
