#Include "JURA203J.CH"
#Include "FWBROWSE.ch"
#Include "FWMVCDEF.ch"
#Include "PROTHEUS.CH"

Function JURA203J()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J203JCompr
Gera o relatório de comprovantes de despesas

@param cFatura     Código da fatura
@param cEscritorio Código do escritório
@param cExpPath    Diretório que o usuário selecionou para salvar os
                   relatórios na máquina local.
@Param cResult     Resultado da emissão dos boletos

@author Willian Kazahaya
@since  12/04/2023
/*/
//-------------------------------------------------------------------
Function J203JCompr(cFatura, cEscritorio, cExpPath, cResult)
Local aArea       := GetArea()
Local aFiles      := {}
Local aTpImg      := {".jpg", ".jpeg", ".png", ".bmp", ".heic",".pdf"}
Local cRootPath   := JRepDirSO(GetSrvProfString( 'RootPath' , '' ))
Local cAliasFat   := J203DespFat(cFatura, cEscritorio)
Local cPdfTkPath  := JurFixPath(GetSrvProfString("StartPath", "system\"), 0, 1) + "pdftk.exe" // \system\pdftk.exe
Local cTmpDir     := JRepDirSO("\spool\" + __cUserID + '_' + cFatura + "\")
Local nRetMkDir   := MakeDir(cTmpDir)
Local cJoinPDFs   := " cat output "
Local cImgName    := ""
Local nOrdemNXM   := 0
Local nI          := 0
Local lRetDocs    := .F.

Default cExpPath := ""
Default cResult  := ""

	// Envia dados de uso do Comprovante de Despesa
	FWLsPutAsyncInfo("LS006",RetCodUsr(),"77","JURA203J")

	// Valida se o cliente permite juntar comprovantes de despesas
	If FindFunction("JFileAppSrv") .And. JFileAppSrv("mogrify.exe")
		If (nRetMkDir == 0 .or. nRetMkDir == 5)
			cPdfTkPath := JRepDirSO(cPdfTkPath)

			// Busca comprovantes da pré-faturas
			If (cAliasFat)->(!Eof())
				(cAliasFat)->(DbGoTop())
				While (cAliasFat)->(!Eof()) 
					J203GetAnx((cAliasFat)->NVY_FILIAL, (cAliasFat)->NVY_COD, cFatura, cEscritorio, aTpImg)
					(cAliasFat)->(Dbskip())
				End

				// Unifica os arquivos PDF
				cImgName  := STR0001 + "(" + cEscritorio + "-" + cFatura + ").pdf" // 'Comprovantes de despesas da fatura '
				
				cJoinPDFs := '"' + cRootPath + cPdfTkPath + '"'                               // Path PdfTK
				cJoinPDFs += ' "' +cRootPath + cTmpDir+ '*.pdf"'                              // Pdfs a unificar 
				cJoinPDFs += ' cat output '                                                   // Comando para unificar
				cJoinPDFs += '"' + JurImgFat(cEscritorio, cFatura, .T., .T.) + cImgName + '"' // Destino do arquivo unificado
				
				WaitRunSrv(cJoinPDFs, .T., JurImgFat(cEscritorio, cFatura, .T., .T.))

				If cResult == "5".And. !Empty(cExpPath) // Exportar o arquivo para clientes que não geram o arquivo unificado.
					CpyS2T(JurImgFat(cEscritorio, cFatura, .T., .F., /*@cMsgRet*/) + cImgName, cExpPath)
				EndIf
				
				nOrdemNXM := JurSeqNXM(cEscritorio, cFatura)
				// Registra o comprovante na NXM (Documentos relacionados)
				J203GrvFil("9", cEscritorio, cFatura, cImgName, nOrdemNXM )

				//Apaga os arquivos temporários
				aTpImg := Directory( cTmpDir  + "\*.*")

				For nI := 1 To Len( aTpImg )
					lRetDocs := ( FErase( cTmpDir  + aTpImg[nI][1] ) == 0 )
				Next nI

					If lRetDocs
					DirRemove( cTmpDir )
				EndIf
			EndIf
		EndIf
	Else
		// "Para geração do Comprovante de Despesa é necessário que o #1 esteja na pasta do #2. Verifique!"
		JurConout(I18N( STR0002, {"Mogrify.exe", "Appserver"}))
	EndIf
	
	(cAliasFat)->(DbCloseArea())
	RestArea(aArea)
Return aFiles


//-------------------------------------------------------------------
/*/{Protheus.doc} J203DespFat
Busca as despesas incluídas na fatura

@param cFatura, Cliente da pré-fatura
@param cEscritorio, Escritório

@return cAliasFat, Alias com as despesas da fatura
			(cAliasFat)->NVY_FILIAL
			(cAliasFat)->NVY_COD

@author Willian Kazahaya
@since  19/04/2023
/*/
//-------------------------------------------------------------------
Static Function J203DespFat(cFatura, cEscritorio)
Local aArea     := GetArea()
Local aFiltros  := {}
Local cAliasFat := GetNextAlias()
Local cSQL      := ""

	cSQL += " SELECT NVY.NVY_FILIAL,"
	cSQL +=        " NVY.NVY_COD"
	cSQL +=   " FROM " +RetSqlName("NXC") + " NXC"
	cSQL +=  " INNER JOIN " +RetSqlName("NVZ") + " NVZ"
	cSQL +=          " ON ( NVZ.NVZ_FILIAL = NXC.NXC_FILIAL"
	cSQL +=           " AND NVZ.NVZ_CESCR  = NXC.NXC_CESCR"
	cSQL +=           " AND NVZ.NVZ_CFATUR = NXC.NXC_CFATUR"
	cSQL +=           " AND NVZ.NVZ_CCLIEN = NXC.NXC_CCLIEN"
	cSQL +=           " AND NVZ.NVZ_CLOJA  = NXC.NXC_CLOJA"
	cSQL +=           " AND NVZ.NVZ_CCASO  = NXC.NXC_CCASO"
	cSQL +=           " AND NVZ.NVZ_SITUAC = '2'"
	cSQL +=           " AND NVZ.D_E_L_E_T_ = ' ' )"
	cSQL +=  " INNER JOIN " +RetSqlName("NVY") + " NVY"
	cSQL +=          " ON ( NVY.NVY_FILIAL = NVZ.NVZ_FILIAL"
	cSQL +=           " AND NVY.NVY_COD = NVZ.NVZ_CDESP"
	cSQL +=           " AND NVY.D_E_L_E_T_ = ' ')"
	cSQL +=  " WHERE NXC.D_E_L_E_T_ = ' '"
	cSQL +=    " AND NXC.NXC_FILIAL = ?"
	aAdd(aFiltros, xFilial("NXC"))
	cSQL +=    " AND NXC.NXC_CFATUR = ?"
	aAdd(aFiltros, cFatura)
	cSQL +=    " AND NXC.NXC_CESCR = ?"
	aAdd(aFiltros, cEscritorio)
	
	dbUseArea( .T., "TOPCONN", TcGenQry2(,, cSQL, aFiltros), cAliasFat, .T., .T.)

	RestArea(aArea)
	aSize(aFiltros, 0)
	aFiltros := Nil
Return cAliasFat

//-------------------------------------------------------------------
/*/{Protheus.doc} J203GetAnx
Busca os anexos das despesas incluídas na fatura

@param cFilDesp, Filial da despesa
@param cCodDesp, Código da despesa
@param cCodFat, Código da fatura
@param cEscritorio, código do escritório
@param aTpImg, Extensões a serem consideradas

@return cAliasFat, Alias com as despesas da fatura
			(cAliasFat)->NVY_FILIAL
			(cAliasFat)->NVY_COD

@author Willian Kazahaya
@since  19/04/2023
/*/
//-------------------------------------------------------------------
Function J203GetAnx(cFilDesp, cCodDesp, cCodFat, cEscritorio, aTpImg)
Local aArea       := GetArea()
Local aFiltros    := {}
Local cAlias      := GetNextAlias()
Local aFields     := {"NUM_FILIAL","NUM_COD","NUM_NUMERO","NUM_DOC","NUM_EXTEN", "NUM_DESC", "NUM_ENTIDA"}
Local cBase       := JRepDirSO(MsDocPath() + "\")
Local cConvertPDF := "mogrify -format pdf "
Local cImgName    := ""
Local cImgPath    := ""
Local cSql        := ""
Local cSqlSel     := ""
Local cSqlFrm     := ""
Local cSqlWhr     := ""

Local cQryNVY     := ""
Local cQrySubNVY  := ""
Local cQryFrmWhr  := ""
Local cTpExten    := ""
Local cTmpDir     := JRepDirSO("\spool\" + __cUserID + '_' + cCodFat + "\")
Local cRootPath   := JRepDirSO(GetSrvProfString( 'RootPath' , '' ))
Local lRet        := .T.
Local nI          := 0
Local nTamNumExt  := TamSx3("NUM_EXTEN")[1]
Local lImanage    := SuperGetMV("MV_JDOCUME",,"1") == "4"
Local aAliSel     := {}
Local aQryParams  := {}
Local cMVJPrfDsp  := Lower(SuperGetMV("MV_JPRFDSP",,""))
Local oAnexo      := Nil
Local oQuery      := Nil

	For nI := 1 To Len(aTpImg)
		If lImanage
			cTpExten += "'" + Left(StrTran(aTpImg[nI], ".", "") + Space(nTamNumExt), nTamNumExt) +  "',"
		Else
			cTpExten += "'" + Left(aTpImg[nI] + Space(nTamNumExt), nTamNumExt) +  "',"
		EndIf
	Next nI
	cTpExten := SubStr(cTpExten,0,Len(cTpExten)-1) 

	If Select("ACB") <= 0
		DBSelectArea("ACB")
	EndIf

	ACB->(dbSetOrder( 1 ))

	// Anexos da NVY
	cSqlSel := " SELECT "

	For nI := 1 to Len(aFields)
		cSqlSel += "?,"
		aAdd(aQryParams, { "U", aFields[nI] })
	Next

	cSqlSel := Substring(cSqlSel,1, Len(cSqlSel)-1)
	cSqlFrm :=   " FROM " + RetSqlName("NUM") + " NUM "
	cSqlFrm +=  " INNER JOIN " + RetSqlName("NVY") + " NVY ON (NVY.NVY_FILIAL = NUM.NUM_FILENT"
	cSqlFrm +=                                           " AND NVY.NVY_COD    = NUM.NUM_CENTID"
	cSqlFrm +=                                           " AND NVY.D_E_L_E_T_ = ' ')"
	cSqlWhr := " WHERE NUM.D_E_L_E_T_ = ' '" 
	cSqlWhr +=   " AND NUM.NUM_ENTIDA = 'NVY'"
	cSqlWhr +=   " AND LOWER(NUM.NUM_EXTEN) IN ( ? )"
	aAdd(aQryParams, { "U", cTpExten })

	cSqlWhr +=   " AND NVY.NVY_FILIAL = ?"
	Aadd(aQryParams, { "C", cFilDesp})

	cSqlWhr +=   " AND NVY.NVY_COD = ?"
	Aadd(aQryParams, { "C", cCodDesp})

	If (!Empty(cMVJPrfDsp))
		cSqlWhr += " AND LOWER( "
		If lImanage
			cSqlWhr += " NUM.NUM_DESC"
		Else
			cSqlWhr += " NUM.NUM_DOC"
		EndIf
		cSqlWhr += " ) LIKE '%?%' "
		aAdd(aQryParams, { "U", cMVJPrfDsp })
	EndIf

	cQryNVY := cSqlSel + cSqlFrm + cSqlWhr
	
	// Prepara a query da NUM com NVY
	oQuery := FWPreparedStatement():New(cQryNVY)
	oQuery := JQueryPSPr(oQuery, aQryParams)
	cQryNVY := oQuery:GetFixQuery()

	aSize(aQryParams, 0)

	// Query de Subentidades da NVY
	
	cQryFrmWhr := " SELECT "
	For nI := 1 to Len(aFields)
		cQryFrmWhr += "COALESCE(NUMOHB.?, NUMOHF.?, NUMOHG.?, '') ?,"
		aAdd(aQryParams, { "U", aFields[nI] })
		aAdd(aQryParams, { "U", aFields[nI] })
		aAdd(aQryParams, { "U", aFields[nI] })
		aAdd(aQryParams, { "U", aFields[nI] })
	Next

	cQryFrmWhr := Substring(cQryFrmWhr,1, Len(cQryFrmWhr)-1)

	cQryFrmWhr +=   " FROM " + RetSqlName("NVY") + " NVY"
	cQryFrmWhr +=   " LEFT JOIN " + RetSqlName("OHB") + " OHB"
	cQryFrmWhr +=          " ON (OHB.OHB_FILIAL = NVY.NVY_FILLAN"
	cQryFrmWhr +=         " AND OHB.OHB_CODIGO = NVY.NVY_CLANC"
	cQryFrmWhr +=         " AND OHB.D_E_L_E_T_ = ' ')"
	cQryFrmWhr +=   " LEFT JOIN " + RetSqlName("NUM") + " NUMOHB"
	cQryFrmWhr +=          " ON (NUMOHB.NUM_FILENT = OHB.OHB_FILIAL"
	cQryFrmWhr +=         " AND NUMOHB.NUM_CENTID = OHB.OHB_CODIGO"
	cQryFrmWhr +=         " AND NUMOHB.NUM_ENTIDA = 'OHB'"
	cQryFrmWhr +=         " AND NUMOHB.D_E_L_E_T_ = ' ')"
	cQryFrmWhr +=   " LEFT JOIN " + RetSqlName("FK7") + " FK7"
	cQryFrmWhr +=          " ON (FK7.FK7_CHAVE  = NVY.NVY_CPAGTO"
	cQryFrmWhr +=         " AND FK7.FK7_ALIAS  = 'SE2'"
	cQryFrmWhr +=         " AND FK7.D_E_L_E_T_ = ' ')"
	cQryFrmWhr +=   " LEFT JOIN " + RetSqlName("OHF") + " OHF"
	cQryFrmWhr +=          " ON (OHF.OHF_IDDOC  = FK7.FK7_IDDOC"
	cQryFrmWhr +=         " AND OHF.OHF_CITEM = NVY.NVY_ITDES"
	cQryFrmWhr +=         " AND OHF.D_E_L_E_T_ = ' ')"
	cQryFrmWhr +=   " LEFT JOIN " + RetSqlName("NUM") + " NUMOHF"
	cQryFrmWhr +=          " ON (NUMOHF.NUM_FILENT = OHF.OHF_FILIAL"
	cQryFrmWhr +=         " AND NUMOHF.NUM_CENTID = OHF.OHF_IDDOC || OHF.OHF_CITEM"
	cQryFrmWhr +=         " AND NUMOHF.NUM_ENTIDA = 'OHF'"
	cQryFrmWhr +=         " AND NUMOHF.D_E_L_E_T_ = ' ')"
	cQryFrmWhr +=   " LEFT JOIN " + RetSqlName("OHG") + " OHG"
	cQryFrmWhr +=          " ON (OHG.OHG_IDDOC  = FK7.FK7_IDDOC"
	cQryFrmWhr +=         " AND OHG.OHG_CITEM = NVY.NVY_ITDPGT"
	cQryFrmWhr +=         " AND OHG.D_E_L_E_T_ = ' ')"
	cQryFrmWhr +=   " LEFT JOIN " + RetSqlName("NUM") + " NUMOHG"
	cQryFrmWhr +=          " ON (NUMOHG.NUM_FILENT = OHG.OHG_FILIAL"
	cQryFrmWhr +=         " AND NUMOHG.NUM_CENTID = OHG.OHG_IDDOC || OHG.OHG_CITEM"
	cQryFrmWhr +=         " AND NUMOHG.NUM_ENTIDA = 'OHG'"
	cQryFrmWhr +=         " AND NUMOHG.D_E_L_E_T_ = ' ')"

	cQryFrmWhr += " WHERE NVY.D_E_L_E_T_ = ' '"
	cQryFrmWhr +=   " AND LOWER(COALESCE(NUMOHB.NUM_EXTEN,"
	cQryFrmWhr +=                      " NUMOHF.NUM_EXTEN,"
	cQryFrmWhr +=                      " NUMOHG.NUM_EXTEN,"
	cQryFrmWhr +=                      " '')) IN (?)"
	aAdd(aQryParams, { "U", cTpExten })

	cQryFrmWhr +=   " AND NVY.NVY_FILIAL = ?"
	Aadd(aQryParams, { "C", cFilDesp})

	cQryFrmWhr +=   " AND NVY.NVY_COD = ?"
	Aadd(aQryParams, { "C", cCodDesp})

	If (!Empty(cMVJPrfDsp))
		cQryFrmWhr += " AND LOWER(COALESCE("
		If lImanage
			cQryFrmWhr += " NUMOHB.NUM_DESC,"
			cQryFrmWhr += " NUMOHF.NUM_DESC,"
			cQryFrmWhr += " NUMOHG.NUM_DESC,"
		Else
			cQryFrmWhr += " NUMOHB.NUM_DOC,"
			cQryFrmWhr += " NUMOHF.NUM_DOC,"
			cQryFrmWhr += " NUMOHG.NUM_DOC,"
		EndIf
		cQryFrmWhr += " '')) LIKE '%?%' "
		aAdd(aQryParams, { "U", cMVJPrfDsp })
	EndIf
	
	// Prepara a query do Subselect das subentidades
	oQuery := FWPreparedStatement():New(cQryFrmWhr)
	oQuery := JQueryPSPr(oQuery, aQryParams)
	cQrySubNVY := ChangeQuery(oQuery:GetFixQuery())

	aSize(aQryParams, 0)

	cSql := "? UNION ALL ?"
	aAdd(aQryParams, { "U", cQryNVY })
	aAdd(aQryParams, { "U", cQrySubNVY })
	
	oQuery := FWPreparedStatement():New(cSql)
	oQuery := JQueryPSPr(oQuery, aQryParams)
	cSql := oQuery:GetFixQuery()

	cAlias := GetNextAlias() // Alias para a Query
	MpSysOpenQuery(cSql, cAlias)

	While lRet .And. (cAlias)->(!Eof())
		If (lIManage)
			aAdd(aAliSel, { (cAlias)->NUM_FILIAL, ;
			                (cAlias)->NUM_COD, ;
			                (cAlias)->NUM_NUMERO, ;
			                (cAlias)->NUM_DOC, ;
			                (cAlias)->NUM_EXTEN, ;
			                (cAlias)->NUM_DESC, ; 
							(cAlias)->NUM_ENTIDA })
		Else 
			cImgPath := POSICIONE('ACB', 1, XFILIAL('ACB') + AllTrim( (cAlias)->NUM_NUMERO ), "ACB_OBJETO")
			cImgPath := AllTrim(cBase) + cImgPath
			cImgName := AllTrim( (cAlias)->NUM_DOC ) + AllTrim( (cAlias)->NUM_EXTEN )	
			lRet := __CopyFile(cImgPath, cTmpDir + Lower(AllTrim(cFilDesp) + "_" + AllTrim(cCodDesp) + "_" + FwNoAccent(cImgName)) )
		EndIf
		(cAlias)->(Dbskip())
	End

	If lImanage
		If (FindFunction("JGetAnxCls"))
			oAnexo := JGetAnxCls("NVY", cCodDesp, , , , , , , .F., .T.)
			lRet := oAnexo:Download(aAliSel, .F., cTmpDir)
		Else
			JurConout(STR0003) //Função JGetAnxCls não encontrada!
		EndIf
	EndIf

	(cAlias)->(DbCloseArea())

	If lRet
		// Converte imagens em PDF usando o ImageMagick
		For nI := 1 To Len(aTpImg)
			If (aTpImg[nI] != ".pdf")
				WaitRunSrv( cConvertPDF + cRootPath + cTmpDir + "*" + aTpImg[nI], .T., cRootPath + cTmpDir)
			EndIf
		Next nI
	EndIf

	RestArea(aArea)

	aSize(aFiltros, 0)
	aFiltros := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CallAnx(cCodNVY)
Chamada da tela de anexos

@param  cCodNVY   - Código da Despesas

@author Willian Yoshiaki Kazahaya
@since  17/07/2023
/*/
//-------------------------------------------------------------------
Function J203CallAnx(cCodNVY)
Local cTipoAnex := JTipAnxNVY(cCodNVY)
Local aExtraEnt := {}

	If cTipoAnex != "NVY"
		aAdd(aExtraEnt, cTipoAnex)
	EndIf
	
	JurAnexos('NVY', cCodNVY, 1, /*cFilOrig*/,/*lEntPFS*/,/*lContrOrc*/, QryAnxNVY(cCodNVY, cTipoAnex), aExtraEnt)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} QryAnxNVY(cCodNVY, cTipoAnex)
Query de anexos

@param  cCodNVY   - Código da Despesas
@param  cTipoAnex - Tipo de anexo vinculado

@author Willian Yoshiaki Kazahaya
@since  17/07/2023
/*/
//-------------------------------------------------------------------
Static Function QryAnxNVY(cCodNVY, cTipoAnex)
Local lHasDtIncl := .F.
Local cQuery     := ""

	DBSelectArea("NUM")
	lHasDtIncl :=  (NUM->(FieldPos('NUM_DTINCL')) > 0)

	cQuery +=      " SELECT NUM_FILIAL,"
	cQuery +=             " NUM_COD,"
	cQuery +=             " NUM_DOC,"
	cQuery +=             " NUM_DESC,"
	cQuery +=             " NUM_EXTEN,"
	cQuery +=             " NUM_NUMERO,"
	cQuery +=             " NUM_ENTIDA,"

	If(lHasDtIncl)
		cQuery +=         " NUM.NUM_DTINCL,"
	EndIf

	cQuery +=             " NUM.D_E_L_E_T_"
	cQuery +=        " FROM " + RetSqlName("NUM") + " NUM"
	cQuery +=       " INNER JOIN " + RetSqlName("NVY") + " NVY"
	cQuery +=          " ON ( NVY.NVY_FILIAL = NUM.NUM_FILENT"
	cQuery +=         " AND NVY.NVY_COD = NUM.NUM_CENTID"
	cQuery +=         " AND NVY.D_E_L_E_T_ = ' ' )"
	cQuery +=       " WHERE NUM.D_E_L_E_T_ = ' '"
	cQuery +=         " AND NUM.NUM_ENTIDA = 'NVY'"
	cQuery +=         " AND NVY.NVY_COD = '" + cCodNVY + "'"

	If cTipoAnex != "NVY"
		cQuery += " UNION ALL"
		cQuery += " SELECT NUM.NUM_FILIAL,"
		cQuery +=        " NUM.NUM_COD,"
		cQuery +=        " NUM.NUM_DOC,"
		cQuery +=        " NUM_DESC,"
		cQuery +=        " NUM.NUM_EXTEN,"
		cQuery +=        " NUM.NUM_NUMERO,"
		cQuery +=        " NUM.NUM_ENTIDA,"
		cQuery +=        " NUM.NUM_DTINCL,"
		cQuery +=        " NUM.D_E_L_E_T_"
		cQuery +=   " FROM " + RetSqlName("NVY") + " NVY"

		If (cTipoAnex == "OHB")
			cQuery +=   " LEFT JOIN " + RetSqlName("OHB") + " OHB"
			cQuery +=     " ON ( OHB.OHB_FILIAL = NVY.NVY_FILLAN"
			cQuery +=    " AND OHB.OHB_CODIGO = NVY.NVY_CLANC"
			cQuery +=    " AND OHB.D_E_L_E_T_ = ' ' )"
			cQuery +=   " LEFT JOIN " + RetSqlName("NUM") + " NUM"
			cQuery +=     " ON ( NUM.NUM_FILENT = OHB.OHB_FILIAL"
			cQuery +=    " AND NUM.NUM_CENTID = OHB.OHB_CODIGO"
			cQuery +=    " AND NUM.NUM_ENTIDA = 'OHB'"
			cQuery +=    " AND NUM.D_E_L_E_T_ = ' ' )"
		ElseIf (cTipoAnex == "OHF")
			cQuery +=   " LEFT JOIN " + RetSqlName("FK7") + " FK7"
			cQuery +=     " ON ( FK7.FK7_CHAVE = NVY.NVY_CPAGTO"
			cQuery +=    " AND FK7.FK7_ALIAS = 'SE2'"
			cQuery +=    " AND FK7.D_E_L_E_T_ = ' ' )"
			cQuery +=   " LEFT JOIN " + RetSqlName("OHF") + " OHF"
			cQuery +=     " ON ( OHF.OHF_IDDOC = FK7.FK7_IDDOC"
			cQuery +=    " AND OHF.OHF_CITEM = NVY.NVY_ITDES"
			cQuery +=    " AND OHF.D_E_L_E_T_ = ' ' )"
			cQuery +=   " LEFT JOIN " + RetSqlName("NUM") + " NUM"
			cQuery +=     " ON ( NUM.NUM_FILENT = OHF.OHF_FILIAL"
			cQuery +=    " AND NUM.NUM_CENTID = (OHF.OHF_IDDOC || OHF.OHF_CITEM)"
			cQuery +=    " AND NUM.NUM_ENTIDA = 'OHF'"
			cQuery +=    " AND NUM.D_E_L_E_T_ = ' ' )"
		ElseIf (cTipoAnex == "OHG")
			cQuery +=   " LEFT JOIN " + RetSqlName("FK7") + " FK7"
			cQuery +=     " ON ( FK7.FK7_CHAVE = NVY.NVY_CPAGTO"
			cQuery +=    " AND FK7.FK7_ALIAS = 'SE2'"
			cQuery +=    " AND FK7.D_E_L_E_T_ = ' ' )"
			cQuery +=   " LEFT JOIN " + RetSqlName("OHG") + " OHG"
			cQuery +=     " ON ( OHG.OHG_IDDOC = FK7.FK7_IDDOC"
			cQuery +=    " AND OHG.OHG_CITEM = NVY.NVY_ITDPGT"
			cQuery +=    " AND OHG.D_E_L_E_T_ = ' ' )"
			cQuery +=   " LEFT JOIN " + RetSqlName("NUM") + " NUM"
			cQuery +=     " ON ( NUM.NUM_FILENT = OHG.OHG_FILIAL"
			cQuery +=    " AND NUM.NUM_CENTID = (OHG.OHG_IDDOC || OHG.OHG_CITEM)"
			cQuery +=    " AND NUM.NUM_ENTIDA = 'OHG'"
			cQuery +=    " AND NUM.D_E_L_E_T_ = ' ' )"
		EndIf

		cQuery +=      " WHERE NUM.D_E_L_E_T_ = ' '"
		cQuery +=        " AND NVY.NVY_COD = '" + cCodNVY + "'"
	EndIf
	cQuery := " FROM (" + cQuery + ") NUM "
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JTipAnxNVY(cCodNVY)
Retorna a entidade que originou a despesa

@param  cCodNVY   - Código da Despesas

@author Willian Yoshiaki Kazahaya
@since  17/07/2023
/*/
//-------------------------------------------------------------------
Static Function JTipAnxNVY(cCodNVY)
Local cTipEntida := "NVY"
Local aDadosEnt  := JGetDadoNVY(cCodNVY)

	Do Case
		Case !Empty(aDadosEnt[1])
			cTipEntida := "OHB"
		Case !Empty(aDadosEnt[5])
			cTipEntida := "OHF"
		Case !Empty(aDadosEnt[6])
			cTipEntida := "OHG"
	End Case
Return cTipEntida

//-------------------------------------------------------------------
/*/{Protheus.doc} JTipAnxNVY(cCodNVY)
Retorna a entidade que originou a despesa

@param  cCodNVY   - Código da Despesas

@author Willian Yoshiaki Kazahaya
@since  17/07/2023
/*/
//-------------------------------------------------------------------
Function J203JHasAnx(cCodNVY)
Local lRet       := .F.
Local cTipAnxEnt := JTipAnxNVY(cCodNVY)
Local aDadosEnt  := {}

	lRet := JNUMHasAnx("NVY", cCodNVY)

	If !lRet .And. cTipAnxEnt != "NVY"
		aDadosEnt := JGetDadoNVY(cCodNVY)
		Do Case 
			Case cTipAnxEnt == "OHB"
				lRet := JNUMHasAnx(cTipAnxEnt, aDadosEnt[1])
			Case cTipAnxEnt == "OHF"
				lRet := JNUMHasAnx(cTipAnxEnt, aDadosEnt[5] + aDadosEnt[3])
			Case cTipAnxEnt == "OHG"
				lRet := JNUMHasAnx(cTipAnxEnt, aDadosEnt[6] + aDadosEnt[4])
		End Case 
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetDadoNVY(cCodNVY)
Busca os dados da Despesa

@param  cCodNVY   - Código da Despesas

@author Willian Yoshiaki Kazahaya
@since  17/07/2023
/*/
//-------------------------------------------------------------------
Function JGetDadoNVY(cCodNVY)
Local aRet   := {'','','','','',''}
Local cQuery := ""
Local cAlias := ""

	cQuery := " SELECT NVY.NVY_CLANC,"
	cQuery +=        " NVY_CPAGTO,"
	cQuery +=        " NVY_ITDES,"
	cQuery +=        " NVY_ITDPGT,"
	cQuery +=        " OHF.OHF_IDDOC,"
	cQuery +=        " OHG.OHG_IDDOC"
	cQuery +=   " FROM " + RetSqlName("NVY") + " NVY"
	cQuery +=   " LEFT JOIN " + RetSqlName("FK7") + " FK7"
	cQuery +=     " ON ( FK7.FK7_CHAVE = NVY.NVY_CPAGTO"
	cQuery +=    " AND FK7.FK7_ALIAS = 'SE2'"
	cQuery +=    " AND FK7.D_E_L_E_T_ = ' ' )"
	cQuery +=   " LEFT JOIN " + RetSqlName("OHF") + " OHF"
	cQuery +=     " ON ( OHF.OHF_IDDOC = FK7.FK7_IDDOC"
	cQuery +=    " AND OHF.OHF_CITEM = NVY.NVY_ITDES"
	cQuery +=    " AND OHF.D_E_L_E_T_ = ' ' )"
	cQuery +=   " LEFT JOIN " + RetSqlName("OHG") + " OHG"
	cQuery +=     " ON ( OHG.OHG_IDDOC = FK7.FK7_IDDOC"
	cQuery +=    " AND OHG.OHG_CITEM = NVY.NVY_ITDPGT"
	cQuery +=    " AND OHG.D_E_L_E_T_ = ' ' )"
	cQuery +=  " WHERE NVY_FILIAL = ?"
	cQuery +=    " AND NVY_COD = ?"
	cQuery +=    " AND NVY.D_E_L_E_T_ = ' '"

	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, {xFilial("NVY"), cCodNVY}), cAlias, .T., .T.)

	If !(cAlias)->(EOF())
		aRet[1] := (cAlias)->NVY_CLANC
		aRet[2] := (cAlias)->NVY_CPAGTO
		aRet[3] := (cAlias)->NVY_ITDES
		aRet[4] := (cAlias)->NVY_ITDPGT
		aRet[5] := (cAlias)->OHF_IDDOC
		aRet[6] := (cAlias)->OHG_IDDOC
	EndIf
	(cAlias)->(DbCloseArea())
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JNUMHasAnx(cFilEnt, cEntida, cCodEnt)
Verifica se tem anexo

@param cFilEnt - Filial da entidade
@param cEntida - Entidade
@param cCodEnt - Código da Entidade ( X2_UNICO sem Filial)

@author Willian Yoshiaki Kazahaya
@since  17/07/2023
/*/
//-------------------------------------------------------------------
Static Function JNUMHasAnx(cEntida, cCodEnt)
Local lHasNUM   := .F.
Local cQuery    := ""
Local cAliasNUM := ""

	cQuery := " SELECT COUNT(1) QTD"
	cQuery += " FROM " + RetSqlName("NUM")
	cQuery += " WHERE NUM_ENTIDA = ?"
	cQuery +=   " AND NUM_CENTID = ?"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	
	cAliasNUM := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, { cEntida, PadR(cCodEnt, TamSX3("NUM_CENTID")[1])}), cAliasNUM, .T., .T.)

	lHasNUM := (cAliasNUM)->QTD > 0
	(cAliasNUM)->(DbCloseArea())
Return lHasNUM

