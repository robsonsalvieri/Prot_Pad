#Include "PROTHEUS.CH"
#Include 'TBICONN.ch'
#Include "OFIXDEF.ch"
#Include "TOTVS.CH"
#Include "OFIA030.ch"

#DEFINE PulaLinha CHR(13) + CHR(10)
#DEFINE nLimiteArq 40 // 40 = igual ao tratamento de leitura interna da SCANIA

Static cCodVRNDelimit := "OFIA030"

/*/{Protheus.doc} OFIA030
	Gerar SOAP ( XML ) para WEBSERVICE - DSM Global - SCANIA

	@author Andre Luis Almeida
	@since 23/08/2018
/*/
Function OFIA030( )
	Local cFilBkp		:= ""
	Local cPerg			:= "OFIA030"
	Private lSchedule	:= FWGetRunSchedule() .Or. Select("SX2") == 0

	cFilBkp := cFilAnt

	If !lSchedule
		If FunName() == "OFIA030"
			//Define os parâmetros antes de abrir a tela
			SetMVValue(cPerg, "MV_PAR01", 2)
			SetMVValue(cPerg, "MV_PAR02", "")
			SetMVValue(cPerg, "MV_PAR03", "")
			Pergunte(cPerg, .F.)
		Endif

		FwMsgRun(Nil, {|oSay| OA030012K_ExecDSMGlobal(oSay)}, STR0030, STR0031) // "Processando" / "Executando DSM Global..."

	Else
		OA030012K_ExecDSMGlobal()
	Endif

	cFilAnt := cFilBkp

Return Nil

/*/{Protheus.doc} OA030012K_ExecDSMGlobal
	Funcao principal que executa o levantamento e 
	integração do DSM Global
	@type  Function
	@author Lucas Oliveira
	@since 07/04/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OA030012K_ExecDSMGlobal(oSay)

	Local cXML          := ""
	Local nCntID        := 1
	Local nCntFil       := 0
	Local nPosFilExec 	:= 0
	Local aDataHora     := {}
	Local oDSMParametros:= Nil
	Local oSqlHelp   	:= Nil	
	Local cSD1SqIni     := ""
	Local cSD1SqFin     := ""
	Local cSD2SqIni     := ""
	Local cSD2SqFin     := ""
	Local cSD3SqIni     := ""
	Local cSD3SqFin     := ""
	Local cVE9SqIni     := ""
	Local cVE9SqFin     := ""
	Local cVPJSqIni 	:= ""
	Local cVPJSqFin 	:= ""
	Local dDtIniRef     := ctod("")
	Local cHrIniRef     := ""
	Local dDtFinRef     := ctod("")
	Local cHrFinRef     := ""
	Local aFiliais      := {}
	Local cWHouseID     := ""
	Local cDtHr         := ""
	Local aFilExec      := {}	
	Local cQAlSQL       := "SQLVBJ"
	Local cQuery        := ""	
	Local lCargaIni     := .F.
	Local cTmpIni       := ""
	Local cMsgTmp       := ""
	Local aGerar        := {}
	Local aPBox         := {}
	Local cFilVBJ       := ""
	Local cCodVBJ       := ""
	Local lFilOk        := .T.
	Local aParVda       := {}
	Local aParCpa       := {}
	Local aParDev       := {}
	Local aParReq       := {}
	Local lNewRes 		:= .F.
	Local aBind         := {}
	Local lSB1Trigg  	:= .F.
	Local lSB5Trigg  	:= .F.
	Local cBkpFil		:= ""
	Private cGrpPrinc   := ""
	Private aGrpTotal   := {}
	Private cOwnerID    := ""
	Private cOperatID   := ""
	Private cCdMoeda    := ""
	Private cUrlXML     := ""
	Private cUserWS     := ""
	Private cPassWS     := ""
	Private cRodapXML   := ""
	Private nCntQtd     := 1
	Private nSeqXML     := 0
	Private dDataExec   := ctod("") // Data Execucao
	Private cHoraExec   := "" // Hora Execucao
	Private cTipoExec 	:= ""
	Private cNomXML     := ""
	Private cDirXML     := ""
	Private aArmReserv  := {}
	Private lAgrResBlq  := .F.
	Private lAgrTransi  := .F.
	Private lBZ_PRV1    := .F.
	Private lB5_ULTVEN  := .F.
	Private lVBJSQVPJI	:= .F.
	Private lVPJCodigo	:= .F.
	Private aIteBalance := {} // B1_CODITE - Vendas / Compras / Devoluções / Ajustes / Requisicoes
	Private aIteVendas  := {} // B1_CODITE - Vendas
	Private lEnviaWS    := .T.
	Private lPriceUpdates := .F.
	Private lPOA30SQL   := ExistBlock("POA30SQL") // Customização nos SQLs de Levantamento dos ITENS
	Private	cFrmPrcVnd	:= ""
	Private	cFrmPrcRep	:= ""
	Private lEnviaGlass := .F.
	Private lEnviaListaPreco := .F.
	Private lSBZTrigg  	:= .F.
	Private cDbDriver	:= TCGetDb()

	Private	aTiposAssunto := {}
	Private	aCodigoMotivos := {}
	Private cCodLogVQL 	:= ""

	// Tipo de Execucao ( via 0-Carga Inicial / 1-Manual / 2-Schedule / 3-Reprocess.Manual )
	If MV_PAR01 == 1 // Carga Inicial
		lCargaIni := .T. // Carga Inicial
		cTipoExec := "0" // 0 - Carga Inicial

	ElseIf MV_PAR01 == 2 // Lote Diário
		cTipoExec := IIF(lSchedule,"2","1")

	ElseIf MV_PAR01 == 3 // Reprocess.Manual 
		cFilAnt 	:= MV_PAR02 // Filial VBJ
		cFilVBJ		:= MV_PAR02 // Filial VBJ
		cCodVBJ 	:= MV_PAR03 // Código VBJ para Reprocessamento
		cTipoExec	:= "3" // 3-Reprocess.Manual

		If Empty( cFilVBJ + cCodVBJ ) // --> Não ha como reprocessar VBJ sem que seja especificada
			Return Nil
		Endif

	ElseIf MV_PAR01 == 4 // Price Updates
		lCargaIni 		:= .T. // Carga Inicial
		lPriceUpdates 	:= .T.
		cTipoExec 		:= "4" // 4 - Price Updates

	EndIf

	//////////////////////////////////////////////////
	// Carregar variaveis apos o Prepare - Schedule //
	//////////////////////////////////////////////////
	lVPJCodigo := VPJ->(FieldPos("VPJ_CODIGO")) > 0
	lBZ_PRV1   := SBZ->(FieldPos("BZ_PRV1")) > 0
	lB5_ULTVEN := SB5->(FieldPos("B5_ULTVEN")) > 0
	lVBJSQVPJI := VBJ->(FieldPos("VBJ_SQVPJI")) > 0

	oSqlHelp   := DMS_SqlHelper():New()
	lSB1Trigg  := oSqlHelp:ExistTable(RetSqlName("SB1") + "_TTAT_LOG")
	lSB5Trigg  := oSqlHelp:ExistTable(RetSqlName("SB5") + "_TTAT_LOG")
	lSBZTrigg  := oSqlHelp:ExistTable(RetSqlName("SBZ") + "_TTAT_LOG")

	If (!lSB1Trigg .or. !lSB5Trigg) // Não existe as tabelas obrigatórios para execução do DSM Global
		OA030040K_RegistraLOG( {"OA030001", STR0021, STR0022 + CRLF + STR0023 + CRLF + STR0024, /*lShowHelp:=*/ .T.}, cCodLogVQL, /*lClose := .F.*/)
	Endif

	oDSMParametros := OFDSMParametros():New()
	dDtIniRef  := Date()
	cHrIniRef  := Time()
	dDtFinRef  := Date()
	cHrFinRef  := Time()
	aFiliais   := oDSMParametros:Filiais()
	cDtHr      := OA0300031_DataHora( dDtFinRef , cHrFinRef )
	aGrpTotal  := oDSMParametros:Grupos()
	cGrpPrinc  := oDSMParametros:Grupo_principal()
	cOwnerID   := oDSMParametros:Owner_Id()
	cOperatID  := oDSMParametros:Operator_Id()
	cCdMoeda   := oDSMParametros:Codigo_moeda()
	cUrlXML    := oDSMParametros:URL_XML()
	cUserWS    := oDSMParametros:User_WebService()
	cPassWS    := oDSMParametros:Pass_WebService()
	aTiposAssunto := oDSMParametros:tipos_assunto()
	aCodigoMotivos := oDSMParametros:codigos_motivo()
	cFrmPrcVnd := oDSMParametros:PrecoVenda_Forml()
	cFrmPrcRep := oDSMParametros:PrecoReposicao_Forml()
	lEnviaGlass := oDSMParametros:Envia_glass()
	lEnviaListaPreco := oDSMParametros:Envia_atualizacao_preco()
	cDirXML	:= oDSMParametros:diretorio_XML()
	cWHouseID := oDSMParametros:filial_warehouse_id()
	cRodapXML  := OA0300021_SOAP_Rodape()
	cNomXML    := "BR_"+cOperatID+'_'+cWHouseID+'_'+dtos(dDtFinRef)+'T'+Substr(cHrFinRef,1,2)+Substr(cHrFinRef,4,2)

	lNewRes	   := GetNewPar("MV_MIL0181", .F.) // Controla nova reserva no ambiente?
	If lNewRes
		aAdd(aArmReserv, Left(GetMV("MV_MIL0177")+Space(10),Len(SB2->B2_LOCAL)))
		aAdd(aArmReserv, Left(GetMV("MV_MIL0179")+Space(10),Len(SB2->B2_LOCAL)))
		aAdd(aArmReserv, Left(GetMV("MV_MIL0192")+Space(10),Len(SB2->B2_LOCAL)))
	Else
		aAdd(aArmReserv, Left(GetMV("MV_RESITE")+Space(10),Len(SB2->B2_LOCAL)))
	EndIf
	aAdd(aArmReserv, Left(GetMV("MV_BLQITE")+Space(10),tamSX3("B2_LOCAL")[1]))
	lAgrResBlq := (oDSMParametros:Agrega_Resblq()=="1")
	lAgrTransi := (oDSMParametros:Agrega_Transito()=="1")

	aGerar := { (oDSMParametros:Tags_Tiks(01)=="1") ,;
		(oDSMParametros:Tags_Tiks(02)=="1") ,;
		(oDSMParametros:Tags_Tiks(03)=="1") ,;
		(oDSMParametros:Tags_Tiks(04)=="1") ,;
		(oDSMParametros:Tags_Tiks(05)=="1") ,;
		(oDSMParametros:Tags_Tiks(06)=="1") ,;
		(oDSMParametros:Tags_Tiks(07)=="1") ,;
		(oDSMParametros:Tags_Tiks(08)=="1") ,;
		(oDSMParametros:Tags_Tiks(09)=="1") ,;
		(oDSMParametros:Tags_Tiks(10)=="1") ,;
		(oDSMParametros:Tags_Tiks(11)=="1") }

	If cTipoExec <> "2" // DIferente de Schedule
		If !lCargaIni .and. !Empty( cFilVBJ + cCodVBJ )
			aAdd( aPBox ,{4,STR0010      ,aGerar[01], "PartForSaleIntroduction"		, 100,'.T.',.F.}) // 01 # "Gerar XML ?"
			aAdd( aPBox ,{4,"           ",aGerar[02], "PartPriceUpdate"				, 100,'.T.',.F.}) // 02
			aAdd( aPBox ,{4,"           ",aGerar[03], "PartReception"				, 100,'.T.',.F.}) // 03
			aAdd( aPBox ,{4,"           ",aGerar[04], "PartOrder"					, 100,'.T.',.F.}) // 04
			aAdd( aPBox ,{4,"           ",aGerar[05], "PartDelivery"				, 100,'.T.',.F.}) // 05
			aAdd( aPBox ,{4,"           ",aGerar[06], "PartOrderDelivery ("+STR0035+")", 100,'.F.',.F.}) // 06 # "Não implementado"
			aAdd( aPBox ,{4,"           ",aGerar[07], "StockAdjustment"				, 100,'.T.',.F.}) // 07
			aAdd( aPBox ,{4,"           ",aGerar[08], "LostSale"		            , 100,'.F.',.F.}) // 08
			aAdd( aPBox ,{4,"           ",aGerar[09], "RemovePartInStock"			, 100,'.T.',.F.}) // 09
			aAdd( aPBox ,{4,"           ",aGerar[10], "PartCorrection"				, 100,'.T.',.F.}) // 10
			aAdd( aPBox ,{4,"           ",aGerar[11], "SetStockBalance"				, 100,'.T.',.F.}) // 11
			If !ParamBox(aPBox,STR0009,@aGerar,,,,,,,,.F.) // Considerar
				Return Nil
			EndIf
		EndIf
		cTmpIni    := Time()
		cMsgTmp    := STR0006 + cTmpIni + PulaLinha		// "Inicio: "
		cCodLogVQL := OA030040K_RegistraLOG({"OA030002", cMsgTmp, /*cSolucao:= */"", /*lShowHelp :=*/.F.}, /*cCodLogVQL*/,/*lClose := .F.*/)

	EndIf

	If lCargaIni
		lEnviaWS := .F.
		If lPriceUpdates
			If FWAlertYesNo(STR0014, STR0015) //"Enviar via WebService o arquivo de Price Updates?" //"Enviar via WebService"
				lEnviaWS := .T.
			EndIf
		Else
			If FWAlertYesNo(STR0016, STR0017) //"Enviar via WebService o arquivo de Carga Inicial?" //"Enviar via WebService"
				lEnviaWS := .T.
			EndIf
		EndIf

	EndIf

	cBkpFil := cFilAnt

	For nCntFil := 1 to Len(aFiliais)

		cFilAnt := aFiliais[nCntFil]
		cTmpIni := Time()
		If lBZ_PRV1

			If !lSchedule
				oSay:SetText(STR0032) //"Ajusta Data da 1a.Compra"
				ProcessMessages()
			Endif

			OA0300111_AjustaDataCompra() // "Ajusta Data da 1a.Compra"
		EndIf
		cMsgTmp += CRLF + cTmpIni + " a " + Time() + STR0007 + cFilAnt	// " - Ajusta Data 1a.Compra - Filial: "

		cWHouseID := oDSMParametros:filial_warehouse_id()

		lFilOk := .T.

		If !lCargaIni // Se NAO For carga Inicial
			If !Empty( cFilVBJ + cCodVBJ )
				aBind  := {}
				cQuery := "SELECT VBJ_DATINI ,"
				cQuery += "       VBJ_HORINI ,"
				cQuery += "       VBJ_DATFIN ,"
				cQuery += "       VBJ_HORFIN ,"
				cQuery += "       VBJ_SQSD1I ,"
				cQuery += "       VBJ_SQSD1F ,"
				cQuery += "       VBJ_SQSD2I ,"
				cQuery += "       VBJ_SQSD2F ,"
				cQuery += "       VBJ_SQSD3I ,"
				cQuery += "       VBJ_SQSD3F ,"
				cQuery += "       VBJ_SQVE9I ,"
				cQuery += "       VBJ_SQVE9F ,"
				cQuery += "       VBJ_SQVPJI ,"
				cQuery += "       VBJ_SQVPJF  "
				cQuery += "  FROM "+RetSqlName("VBJ")
				cQuery += " WHERE VBJ_FILIAL=  ? " ; 	aAdd( aBind, { "C", xFilial("VBJ") } )
				cQuery += "   AND VBJ_CODIGO=  ? " ; 	aAdd( aBind, { "C", cCodVBJ } )
				cQuery += "   AND VBJ_CODFIL=  ? " ;   	aAdd( aBind, { "C", cFilVBJ} )
				cQuery += "   AND D_E_L_E_T_=' '"

				OA030037C_ExecQuery( cQuery, aBind, cQAlSQL, /*lQueryOnly*/ )

				If !( cQAlSQL )->( Eof() )
					dDtIniRef := StoD( ( cQAlSQL )->( VBJ_DATINI ) )	// Data Inicial
					cHrIniRef := ( cQAlSQL )->( VBJ_HORINI )			// Hora Inicial
					dDtFinRef := StoD( ( cQAlSQL )->( VBJ_DATFIN ) )	// Data Final
					cHrFinRef := ( cQAlSQL )->( VBJ_HORFIN )			// Hora Final
					cSD1SqIni := ( cQAlSQL )->( VBJ_SQSD1I )			// D1_NUMSEQ Inicial
					cSD1SqFin := ( cQAlSQL )->( VBJ_SQSD1F )			// D1_NUMSEQ Final
					cSD2SqIni := ( cQAlSQL )->( VBJ_SQSD2I )			// D2_NUMSEQ Inicial
					cSD2SqFin := ( cQAlSQL )->( VBJ_SQSD2F )			// D2_NUMSEQ Final
					cSD3SqIni := ( cQAlSQL )->( VBJ_SQSD3I )			// D3_NUMSEQ Inicial
					cSD3SqFin := ( cQAlSQL )->( VBJ_SQSD3F )			// D3_NUMSEQ Final
					cVE9SqIni := ( cQAlSQL )->( VBJ_SQVE9I )			// VE9_NROSUB Inicial
					cVE9SqFin := ( cQAlSQL )->( VBJ_SQVE9F )			// VE9_NROSUB Final
					cVPJSqIni := ( cQAlSQL )->( VBJ_SQVPJI )			// VPJ Sequencial Inicial
					cVPJSqFin := ( cQAlSQL )->( VBJ_SQVPJF )			// VPJ Sequencial Final
				Else
					lFilOk := .F.
				EndIf
				( cQAlSQL )->( DbCloseArea() )
				DbSelectArea("VBJ")
			Else
				aDataHora := oDSMParametros:DataHoraInit()
				dDtIniRef := aDataHora[1] // Data Inicial
				cHrIniRef := aDataHora[2] // Hora Inicial
				cSD1SqIni := oDSMParametros:NumSeqInit("SD1","NUMSEQ")
				cSD1SqFin := FM_SQL(" SELECT MAX(D1_NUMSEQ) FROM "+RetSqlName('SD1')+" WHERE D1_FILIAL = '"+xFilial('SD1')+"'")
				cSD2SqIni := oDSMParametros:NumSeqInit("SD2","NUMSEQ")
				cSD2SqFin := FM_SQL(" SELECT MAX(D2_NUMSEQ) FROM "+RetSqlName('SD2')+" WHERE D2_FILIAL = '"+xFilial('SD2')+"'")
				cSD3SqIni := oDSMParametros:NumSeqInit("SD3","NUMSEQ")
				cSD3SqFin := FM_SQL(" SELECT MAX(D3_NUMSEQ) FROM "+RetSqlName('SD3')+" WHERE D3_FILIAL = '"+xFilial('SD3')+"'")
				cVE9SqIni := oDSMParametros:NumSeqInit("VE9","NROSUB")
				cVE9SqFin := FM_SQL(" SELECT MAX(VE9_NROSUB) FROM "+RetSqlName('VE9')+" WHERE VE9_FILIAL = '"+xFilial('VE9')+"'")
				If ( lVPJCodigo )
					cVPJSqIni := oDSMParametros:NumSeqInit("VPJ", "CODIGO")
					cVPJSqFin := FM_SQL("SELECT MAX(VPJ_CODIGO) FROM " +RetSqlName('VPJ')+" WHERE VPJ_FILIAL = '"+xFilial('VPJ')+"'")
				EndIf

			EndIf
		EndIf

		If lFilOk
			aAdd(aFilExec,{ cFilAnt , cSD1SqIni , cSD1SqFin , cSD2SqIni , cSD2SqFin , cSD3SqIni , cSD3SqFin , cVE9SqIni , cVE9SqFin , dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , cWHouseID, cVPJSqIni, cVPJSqFin} )
		EndIf

	Next

	cFilAnt := cBkpFil
	If (nPosFilExec := OA030042K_ObterFilialDoProcessamento(aFilExec)) == 0
		OA030040K_RegistraLOG({"OA030011", STR0036 ,STR0037 ,/*lShowHelp:=*/ .T.}, cCodLogVQL, /*lClose := */.T.) // "A filial em processamento não possui configuração definida na tela de Configuração do DSM Global.""Acesse a tela de configuração, verifique se a filial está cadastrada e informe o WarehouseID correspondente para que a integração possa ser realizada."
		Return
	Endif

	If lCargaIni .or. aGerar[1] // Introduction - Iniciar Itens
		//	-> PartForSaleIntroduction (1)
		If !lSchedule
			oSay:SetText(STR0030 + " PartForSaleIntroduction") // Processando
			ProcessMessages()
		Endif

		cTmpIni := Time()
		If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
			cFilAnt   := aFilExec[nPosFilExec,01]
			dDtIniRef := aFilExec[nPosFilExec,10]
			cHrIniRef := aFilExec[nPosFilExec,11]
			dDtFinRef := aFilExec[nPosFilExec,12]
			cHrFinRef := aFilExec[nPosFilExec,13]
			cWHouseID := aFilExec[nPosFilExec,14]
			aParVda := { aFilExec[nPosFilExec,04] , aFilExec[nPosFilExec,05] } // Vendas
			aParCpa := { aFilExec[nPosFilExec,02] , aFilExec[nPosFilExec,03] } // Compras
			aParDev := { aFilExec[nPosFilExec,02] , aFilExec[nPosFilExec,03] } // Devolucoes
			aParReq := { aFilExec[nPosFilExec,06] , aFilExec[nPosFilExec,07] } // Requisicoes
			cXML := OA0300201_Introduction( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , cDtHr , cWHouseID , "" , @nCntID , cXML , lCargaIni , aParVda , aParCpa , aParDev , aParReq )
		EndIf
		cMsgTmp += CRLF + cTmpIni + " a " + Time() + " - PartForSaleIntroduction"
	EndIf

	// Vetores utilizados no Balance de Estoque e Outros pontos
	aIteBalance := {}
	aIteVendas  := {}

	If !lCargaIni // Se NAO For carga Inicial
		If aGerar[2] // Atualização do Valor de Venda dos Itens
			//	-> PartPriceUpdate (2)
			If !lSchedule
				oSay:SetText(STR0030 + " PartPriceUpdate") //"Processando"
				ProcessMessages()
			Endif

			cTmpIni := Time()
			If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
				cFilAnt := aFilExec[nPosFilExec,01]
				dDtIniRef := aFilExec[nPosFilExec,10]
				cHrIniRef := aFilExec[nPosFilExec,11]
				dDtFinRef := aFilExec[nPosFilExec,12]
				cHrFinRef := aFilExec[nPosFilExec,13]
				cXML := OA0300211_ValorVenda( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , cDtHr , "" , @nCntID , cXML )
			EndIf
			cMsgTmp += CRLF + cTmpIni + " a " + Time() + " - PartPriceUpdate"
		EndIf

		If aGerar[3] // Compras pelo D1_NUMSEQ
			//	-> PartReception (4)
			If !lSchedule
				oSay:SetText(STR0030 + " PartReception") //"Processando"
				ProcessMessages()
			Endif

			cTmpIni := Time()
			If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
				cFilAnt   := aFilExec[nPosFilExec,01]
				cSD1SqIni := aFilExec[nPosFilExec,02]
				cSD1SqFin := aFilExec[nPosFilExec,03]
				dDtIniRef := aFilExec[nPosFilExec,10]
				dDtFinRef := aFilExec[nPosFilExec,12]
				cWHouseID := aFilExec[nPosFilExec,14]
				cXML := OA0300241_Compras( cSD1SqIni , cSD1SqFin , dDtIniRef , dDtFinRef , cWHouseID , @nCntID , cXML )
			Endif
			cMsgTmp += CRLF + cTmpIni + " a " + Time() + " - PartReception"
		EndIf

		If aGerar[4] // ( Requisicoes OS pelo D3_NUMSEQ ) e ( Orcamentos Faturados pelo D2_NUMSEQ )
			//	-> PartOrder (5)
			If !lSchedule
				oSay:SetText(STR0030 + " PartOrder") //"Processando"
				ProcessMessages()
			Endif

			cTmpIni := Time()
			If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
				cFilAnt   := aFilExec[nPosFilExec,01]
				cSD2SqIni := aFilExec[nPosFilExec,04]
				cSD2SqFin := aFilExec[nPosFilExec,05]
				cSD3SqIni := aFilExec[nPosFilExec,06]
				cSD3SqFin := aFilExec[nPosFilExec,07]
				dDtIniRef := aFilExec[nPosFilExec,10]
				dDtFinRef := aFilExec[nPosFilExec,12]
				cWHouseID := aFilExec[nPosFilExec,14]
				cXML := OA0300301_Requisicoes( cSD3SqIni , cSD3SqFin , dDtIniRef , dDtFinRef , cWHouseID , @nCntID , cXML ) // Requisicoes/Devolucoes OS
				cXML := OA0300321_Orcamentos_Faturados( cSD2SqIni , cSD2SqFin , dDtIniRef , dDtFinRef , cWHouseID , @nCntID , cXML ) // Orcamentos Faturados
			Endif
			cMsgTmp += CRLF + cTmpIni + " a " + Time() + " - PartOrder"
		EndIf

		If aGerar[5] // ( Vendas pelo D2_NUMSEQ ) e ( Devolucoes Venda pelo D1_NUMSEQ )
			//	-> PartDelivery (6)
			If !lSchedule
				oSay:SetText(STR0030 + " PartDelivery") //"Processando"
				ProcessMessages()
			Endif

			cTmpIni := Time()
			If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
				cFilAnt   := aFilExec[nPosFilExec,01]
				cSD1SqIni := aFilExec[nPosFilExec,02]
				cSD1SqFin := aFilExec[nPosFilExec,03]
				cSD2SqIni := aFilExec[nPosFilExec,04]
				cSD2SqFin := aFilExec[nPosFilExec,05]
				dDtIniRef := aFilExec[nPosFilExec,10]
				dDtFinRef := aFilExec[nPosFilExec,12]
				cWHouseID := aFilExec[nPosFilExec,14]
				cXML := OA0300231_Vendas( cSD2SqIni , cSD2SqFin , dDtIniRef , dDtFinRef , cWHouseID , @nCntID , cXML ) // Vendas
				cXML := OA0300251_Devolucoes( cSD1SqIni , cSD1SqFin , dDtIniRef , dDtFinRef , cWHouseID , @nCntID , cXML ) // Devolucoes Venda ( Fazer CONTA -> D2_QUANT - D2_QTDEDEV )
				cXML := OA0300331_Cancelamentos( cSD2SqIni , cSD2SqFin , dDtIniRef , dDtFinRef , cWHouseID , @nCntID , cXML ) // Cancelamentos de Vendas
			Endif
			cMsgTmp += CRLF + cTmpIni + " a " + Time() + " - PartDelivery"
		EndIf

		If aGerar[6]
			//	-> PartOrderAndDelivery (7)
		EndIf

		If aGerar[7] // Ajustes de Estoque ( Transferencias entre Filiais, Ajustes de Inventario, Interno , ... )
			//	-> StockAdjustment (8)
			If !lSchedule
				oSay:SetText(STR0030 + " StockAdjustment") //"Processando"
				ProcessMessages()
			Endif

			cTmpIni := Time()
			If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
				cFilAnt   := aFilExec[nPosFilExec,01]
				cSD1SqIni := aFilExec[nPosFilExec,02]
				cSD1SqFin := aFilExec[nPosFilExec,03]
				cSD2SqIni := aFilExec[nPosFilExec,04]
				cSD2SqFin := aFilExec[nPosFilExec,05]
				cWHouseID := aFilExec[nPosFilExec,14]
				cXML := OA0300291_AjusteEstoque( "SD2" , cSD2SqIni , cSD2SqFin , , , cWHouseID , @nCntID , cXML ) // Saida ( - Estoque )
				cXML := OA0300291_AjusteEstoque( "SD1" , cSD1SqIni , cSD1SqFin , , , cWHouseID , @nCntID , cXML ) // Entrada ( + Estoque )
			Endif
			cMsgTmp += CRLF + cTmpIni + " a " + Time() + " - StockAdjustment"
		EndIf

		If aGerar[8] .And. lVPJCodigo  // Venda Pedida
			//	-> LostSale (9)
			If !lSchedule
				oSay:SetText(STR0030 + " LostSale") //"Processando"
				ProcessMessages()
			Endif

			cTmpIni := Time()

			If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
				cFilAnt   := aFilExec[nPosFilExec, 01]  // Filial a processar
				cWHouseID := aFilExec[nPosFilExec, 14]  // Warehouse ID
				cVPJSqIni := aFilExec[nPosFilExec, 15]  // VPJ Seq Inicial
				cVPJSqFin := aFilExec[nPosFilExec, 16]  // VPJ Seq Final
				cXML := OA0300LS_LostSale(cVPJSqIni, cVPJSqFin, cWHouseID, aGrpTotal, @nCntID, cXML, aTiposAssunto, aCodigoMotivos)
			Endif
			cMsgTmp += PulaLinha + cTmpIni + " a " + Time() + " - LostSale"

		EndIf

		If aGerar[10] // Correcao de Itens ( apos Vendas )
			//	-> PartCorrection (11)
			If !lSchedule
				oSay:SetText(STR0030 + " PartCorrection") //"Processando"
				ProcessMessages()
			Endif

			cTmpIni := Time()
			If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
				cFilAnt   := aFilExec[nPosFilExec,01]
				dDtIniRef := aFilExec[nPosFilExec,10]
				cHrIniRef := aFilExec[nPosFilExec,11]
				dDtFinRef := aFilExec[nPosFilExec,12]
				cHrFinRef := aFilExec[nPosFilExec,13]
				cWHouseID := aFilExec[nPosFilExec,14]
				cXML := OA0300281_CorrecaoItens( cWHouseID , @nCntID , cXML , dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef )
			Endif
			cMsgTmp += CRLF + cTmpIni + " a " + Time() + " - PartCorrection"
		EndIf

		If aGerar[11] .and. Len(aIteBalance) > 0 // Balance de Estoque ( necessario apos Vendas ou Compras ou Devoluções ou Ajustes )
			//	-> SetStockBalance (12)
			If !lSchedule
				oSay:SetText(STR0030 + " SetStockBalance") //"Processando"
				ProcessMessages()
			Endif

			cTmpIni := Time()
			If Len(aFilExec) > 0 // UMA UNICA VEZ - APENAS UMA FILIAL
				cFilAnt   := aFilExec[nPosFilExec,01]
				cWHouseID := aFilExec[nPosFilExec,14]
				cXML := OA0300261_BalanceEstoque( cWHouseID , @nCntID , cXML )
			Endif
			cMsgTmp += CRLF + cTmpIni + " a " + Time() + " - SetStockBalance"
		EndIf
	EndIf

	If !lSchedule
		oSay:SetText(STR0033) // "Finalizando gravação do XML"
		ProcessMessages()
	Endif

	OA0300071_GravaXML(cXML)	// Finalizar ultimo XML

	If nSeqXML > 0 // Gerou XML ?

		If !lSchedule
			oSay:SetText(STR0034) // "Atualizando Controle de Execução Diária"
			ProcessMessages()
		Endif 

		// Grava variaveis de Controle ( Data/Hora e Sequencial SD1/SD2/SD3/VE9 )
		OA0300101_GravaControle( aFilExec , Empty( cFilVBJ + cCodVBJ ) , lCargaIni )

		cMsgTmp += PulaLinha + PulaLinha + STR0008 + Time() // "Fim: "

		FWAlertSuccess( cMsgTmp, STR0003)		// "XML's gerados com Sucesso"

		OA030040K_RegistraLOG({"OA030003", STR0003 ,cMsgTmp ,/*lShowHelp:=*/ .F.}, cCodLogVQL, /*lClose := */.T.)

	Else
		OA030040K_RegistraLOG( {"OA030004", STR0019, STR0020, /*lShowHelp:=*/ .T.}, cCodLogVQL, /*lClose := */.T.)
	EndIf

Return .T.

/*/{Protheus.doc} OA0300011_SOAP_Cabecalho
	Cabeçalho do SOAP

	@author Andre Luis Almeida
	@since 23/08/2018
/*/
Function OA0300011_SOAP_Cabecalho()
	Local cRetXML := ''
	Local cAux1   := ''

	dDataExec  := Date() // Data Execucao
	cHoraExec  := time() // Hora Execucao

	cAux1 += dtos(dDataExec)+"T" + JurTime(.F., .F.)

	cRetXML += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.scania.com/dsm/schema/datacollectionmsgs/v1" xmlns:v11="http://xmlns.scania.com/dsm/schema/datacollection/v1">'+PulaLinha
	cRetXML += '<soapenv:Header>'+PulaLinha
	cRetXML += '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+PulaLinha
	cRetXML += '<wsse:UsernameToken wsu:Id="UsernameToken-1">'+PulaLinha
	cRetXML += '<wsse:Username>'+cUserWS+'</wsse:Username>'+PulaLinha
	cRetXML += '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+cPassWS+'</wsse:Password>'+PulaLinha
	cRetXML += '</wsse:UsernameToken>'+PulaLinha
	cRetXML += '</wsse:Security>'+PulaLinha
	cRetXML += '</soapenv:Header>'+PulaLinha
	cRetXML += '<soapenv:Body>'+PulaLinha
	cRetXML += '<v1:UpdateRequest>'+PulaLinha
	cRetXML += '<v11:Message>'+PulaLinha
	cRetXML += '<v11:Header sender="'+cOperatID+'" version="1.0" sendTime="'+cAux1+'"/>'+PulaLinha

Return cRetXML

/*/{Protheus.doc} OA0300021_SOAP_Rodape
	Rodape do SOAP
	
	@author Andre Luis Almeida
	@since 23/08/2018
/*/
Function OA0300021_SOAP_Rodape()
	Local cRetXML := ''
	cRetXML += '</v11:Message>'+PulaLinha
	cRetXML += '</v1:UpdateRequest>'+PulaLinha
	cRetXML += '</soapenv:Body>'+PulaLinha
	cRetXML += '</soapenv:Envelope>'+PulaLinha
Return cRetXML

/*/{Protheus.doc} OA0300031_DataHora
	Monta Formato da data/hora

	@author Andre Luis Almeida
	@since 23/08/2018
/*/
Function OA0300031_DataHora( dData , cHora )
	Local cRetDtHr := ''
	Default dData  := stod("19500101")
	Default cHora  := "00:00"
	If Empty(dData)
		dData := stod("19500101")
	EndIf
	If Empty(cHora)
		cHora := "00:00"
	EndIf
	cRetDtHr := dtos(dData)+"T"+Substr(cHora,1,2)+Substr(cHora,4,2) // Default: 19500101T0000
Return cRetDtHr

/*/{Protheus.doc} OA0300041_DTIME
	Retorna o WHERE do DATE/TIME

	@author Andre Luis Almeida
	@since 03/09/2018
/*/
Function OA0300041_DTIME( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef )
	Local cQuery := ""
	Local aBind	 := {}

	If cDbDriver == "ORACLE" // ORACLE
		cQuery	+= " AND TO_CHAR(TTAT_DTIME,'yyyymmdd') || TO_CHAR(TTAT_DTIME,'hh24:mi:ss') >  ? " ; aAdd(aBind, {"C", DToS(dDtIniRef) + cHrIniRef})
		cQuery	+= " AND TO_CHAR(TTAT_DTIME,'yyyymmdd') || TO_CHAR(TTAT_DTIME,'hh24:mi:ss') <= ? " ; aAdd(aBind, {"C", DToS(dDtFinRef) + cHrFinRef})
	Else // SQL e demais Bancos
		cQuery	+= " AND TRIG.TTAT_DTIME >  ? " ; aAdd(aBind, {"C", DToS(dDtIniRef)+" "+cHrIniRef})
		cQuery	+= " AND TRIG.TTAT_DTIME <= ? " ; aAdd(aBind, {"C", DToS(dDtFinRef)+" "+cHrFinRef})
	EndIf

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )

Return cQuery

/*/{Protheus.doc} OA0300051_Transaction
	ID Transacao - Inicia e Finaliza Transacao

	@author Andre Luis Almeida
	@since 23/08/2018
/*/
Function OA0300051_Transaction( lInicTransac , nID )
	Local cRetXML := ''
	Default nID   := 1

	If lInicTransac
		cRetXML += '<v11:Transaction id="'+Alltrim(str(nID))+'">'+PulaLinha
	Else
		cRetXML += '</v11:Transaction>'+PulaLinha
	EndIf

Return cRetXML

/*/{Protheus.doc} OA0300071_GravaXML
	Gravar o arquivo XML

	@author Andre Luis Almeida
	@since 27/08/2018
/*/
Function OA0300071_GravaXML( cBodyXML )
	Local cXML    := OA0300011_SOAP_Cabecalho() + cBodyXML + cRodapXML
	Local cArqXML := ""
	Local lOkWS   := .T.
	Local cDiretorioArqXML  := ""
	Local oFWriter := Nil

	If !Empty(cBodyXML)

		If lEnviaWS
			lOkWS    := OA0300311_WebService( cXML )
		endIf

		If !Empty(cDirXML)

			cArqXML   := cNomXML+"_"+strzero(++nSeqXML,5)+IIf(lOkWS,+'.XML','.ERRO')
			cDiretorioArqXML := Alltrim(cDirXML) + "/" + Alltrim(cArqXML)

			oFWriter := FWFileWriter():New(cDiretorioArqXML)
			oFWriter:lCaseSensitive  := .T.

			If !oFWriter:Create()
				OA030040K_RegistraLOG( {"OA030005", STR0025, STR0026 + cDiretorioArqXML + "| FError: " + oFWriter:Error():Message, /*lShowHelp:=*/ .T.}, cCodLogVQL, /*lClose := .F.*/)
			Else
				oFWriter:Write(cXML)
				oFWriter:Close()
			Endif
			
		Endif

	EndIf

Return Nil


/*/{Protheus.doc} OA0300081_Estoque
	Monta TAG XML - Estoque

	@author Andre Luis Almeida
	@since 27/08/2018
/*/
Function OA0300081_Estoque( cWHouseID , cCodIte , nQtdAtu , dDtaEnt , dDtaSai , cEnder , cNamSB1 , cFilSB1 , cNamSB2 , cFilSB2 , cNamSC7 , cFilSC7 )
	Local cRetXML     := ''
	Local nAux1       := 0
	Local cAux1       := ''
	Local cAux2       := ''
	Local cAux3       := ''
	Local cAux4       := ''
	Local cQuery      := ''
	Local nQtdTot     := 0
	Local aBind  	  := {}
	Default cWHouseID := ''
	Default cCodIte   := ''
	Default nQtdAtu   := 0
	Default dDtaEnt   := ctod("")
	Default dDtaSai   := ctod("")
	Default cEnder    := ""
	Default cNamSB1   := RetSqlName("SB1")
	Default cFilSB1   := xFilial("SB1")
	Default cNamSB2   := RetSqlName("SB2")
	Default cFilSB2   := xFilial("SB2")
	Default cNamSC7   := RetSqlName("SC7")
	Default cFilSC7   := xFilial("SC7")

	nQtdTot := nQtdAtu

	If lAgrTransi // Agrega Qtde Em Transito ?
		aBind  := {}
		cQuery := "SELECT SUM(SC7.C7_QUANT-SC7.C7_QUJE) AS QTDSC7 "
		cQuery += "  FROM "+cNamSB1+" SB1"
		cQuery += "  JOIN "+cNamSC7+" SC7 ON ( SC7.C7_FILIAL= ? AND SC7.C7_PRODUTO=SB1.B1_COD AND SC7.C7_RESIDUO <> 'S' AND SC7.C7_QUANT <> SC7.C7_QUJE AND SC7.D_E_L_E_T_=' ' ) "	; aAdd(aBind, {"C", cFilSc7})
		cQuery += " WHERE SB1.B1_FILIAL= ? "	; aAdd(aBind, {"C", cFilSb1})
		cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd(aBind, {"A", aGrpTotal})
		cQuery += "   AND SB1.B1_CODITE= ? "	; aAdd(aBind, {"C", cCodIte})
		cQuery += "   AND SB1.D_E_L_E_T_=' '"
		cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
		nQtdTot += FM_SQL(cQuery) // Qtde.Em Transito SC7
	EndIf

	cAux1 := StrTran( Alltrim(TransForm(nQtdAtu          ,"@E 9999999999")) , "," , "." ) // Qtde.Estoque
	If lAgrResBlq // Agrega Qtde Reservada/Bloqueada
		cAux2 := StrTran( Alltrim(TransForm(nQtdTot      ,"@E 9999999999")) , "," , "." ) // Qtde.Estoque
	Else
		aBind  := {}
		cQuery := "SELECT SUM(SB2.B2_QATU) AS B2QATU"
		cQuery += "  FROM "+cNamSB1+" SB1"
		cQuery += "  JOIN "+cNamSB2+" SB2 ON ( SB2.B2_FILIAL = ? AND SB2.B2_COD=SB1.B1_COD " 	; aAdd(aBind, {"C", cFilSB2})
		cQuery += "   AND SB2.B2_LOCAL IN ( ? ) AND SB2.D_E_L_E_T_=' ' ) " 	; aAdd(aBind, {"A", aArmReserv})
		cQuery += " WHERE SB1.B1_FILIAL = ? " 	; aAdd(aBind, {"C", cFilSB1})
		cQuery += "   AND SB1.B1_GRUPO IN ( ? ) " 	; aAdd(aBind, {"A", aGrpTotal})
		cQuery += "   AND SB1.B1_CODITE = ? " 	; aAdd(aBind, {"C", cCodIte})
		cQuery += "   AND SB1.D_E_L_E_T_=' '"
		cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
		nAux1 := FM_SQL(cQuery) // Qtde.Reservada/Bloqueada
		cAux2 := StrTran( Alltrim(Transform(nQtdTot-nAux1,"@E 9999999999")) , "," , "." ) // Qtde.Estoque - Qtde.Reservada/Bloqueada
	EndIf
	cAux3 := OA0300031_DataHora(dDtaSai,"00:00")
	cAux4 := OA0300031_DataHora(dDtaEnt,"00:00")

	cRetXML += '<v11:PartInStockIntroduction>'+PulaLinha
	cRetXML += '<v11:PartInStock lastSoldTime="'+cAux3+'" '
	cRetXML +=                  'binLocation="'+IIf(!Empty(cEnder),cEnder,'NOT BINNED')+'" '
	cRetXML +=                  'stockIntroductionTime="'+cAux4+'" '
	cRetXML +=                  'availableStock="'+cAux1+'" '
	cRetXML +=                  'stockBalance="'+cAux2+'">'+PulaLinha
	cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
	cRetXML += '<v11:StockId stockId="1" '
	cRetXML +=              'warehouseId="'+cWHouseID+'"/>'+PulaLinha
	cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" '
	cRetXML +=             'partNumber="'+Alltrim(cCodIte)+'"/>'+PulaLinha
	cRetXML += '</v11:PartInStock>'+PulaLinha
	cRetXML += '</v11:PartInStockIntroduction>'+PulaLinha

Return cRetXML

/*/{Protheus.doc} OA0300091_PriceUpdate
	Monta TAG XML - Preco de Venda ou Preco de Reposicao

	@author Andre Luis Almeida
	@since 27/08/2018
/*/
Function OA0300091_PriceUpdate( cDtHr , cIte , nVlr , cPriceType )
	Local cRetXML      := ''
	Local cAux         := ''
	Default cDtHr      := ''
	Default cIte       := SB1->B1_CODITE
	Default nVlr       := SB1->B1_PRV1
	Default cPriceType := "PurchaseGross" // "PurchaseGross" (Preco Venda) ou "PurchaseNet" (Preco de Reposicao)

	cAux := StrTran( Alltrim(TransForm(nVlr,"@E 99999999.99")) , "," , "." )

	cRetXML += '<v11:PartPriceUpdate priceType="'+cPriceType+'" '
	cRetXML +=                      'currency="'+cCdMoeda+'" '
	cRetXML +=                      'validFrom="'+cDtHr+'" '
	cRetXML +=                      'price="'+cAux+'">'+PulaLinha
	cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
	cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" '
	cRetXML +=             'partNumber="'+Alltrim(cIte)+'"/>'+PulaLinha
	cRetXML += '</v11:PartPriceUpdate>'+PulaLinha

Return cRetXML


/*/{Protheus.doc} OA0300101_GravaControle
	Grava variaveis de Controle ( Data/Hora e Sequencial SD1/SD2/SD3/VE9 )

	@author Andre Luis Almeida
	@since 29/08/2018
/*/
Function OA0300101_GravaControle( aFilExec , lAtu_Json , lCargaIni , lSchedule )
	Local oConfig     := JsonObject():new()
	Local oAux
	Local nPosFilExec := OA030042K_ObterFilialDoProcessamento(aFilExec)
	Local cBkpFil     := ""
	Local cVBJ_CODIGO := ""
	Default aFilExec  := {}
	Default lAtu_Json := .T.
	Default lCargaIni := .F.
	Default lSchedule := .F.

	If !lSchedule
		cBkpFil := cFilAnt
	EndIf
	
	cVBJ_CODIGO := GetSXENum("VBJ","VBJ_CODIGO") // Codigo Interno (sequencial)
	ConfirmSX8()

	oConfig["FILIAIS"] := {}

	If Len(aFilExec) > 0
		cFilAnt := aFilExec[nPosFilExec,1]
		oAux    := JsonObject():New()
		If lAtu_Json .and. !lCargaIni // Atualiza Json e NAO é carga Inicial
			oAux["FILIAL"] := cFilAnt
			oAux["SD1"] := JsonObject():New()
			oAux["SD1"]["NUMSEQ"] := aFilExec[nPosFilExec,03]
			oAux["SD2"] := JsonObject():New()
			oAux["SD2"]["NUMSEQ"] := aFilExec[nPosFilExec,05]
			oAux["SD3"] := JsonObject():New()
			oAux["SD3"]["NUMSEQ"] := aFilExec[nPosFilExec,07]
			oAux["VE9"] := JsonObject():New()
			oAux["VE9"]["NROSUB"] := aFilExec[nPosFilExec,09]
			oAux["VPJ"] := JsonObject():New()
			oAux["VPJ"]["CODIGO"] := aFilExec[nPosFilExec, 16]
			oAux["ULTIMA_EXECUCAO"] := JsonObject():New()
			oAux["ULTIMA_EXECUCAO"]["DATA"] := DtoS( aFilExec[nPosFilExec,12] )
			oAux["ULTIMA_EXECUCAO"]["HORA"] := aFilExec[nPosFilExec,13]

			aAdd( oConfig["FILIAIS"], oAux )

			If lAtu_Json .and. Len( oConfig["FILIAIS"] ) > 0
				OA030036C_SaveConfig( oConfig )
			EndIf

		EndIf
		DbSelectArea("VBJ")
		RecLock("VBJ",.T.)
		VBJ->VBJ_FILIAL := xFilial("VBJ")			// Filial
		VBJ->VBJ_CODIGO := cVBJ_CODIGO				// Codigo Interno (sequencial)
		VBJ->VBJ_CODFIL := aFilExec[nPosFilExec,01] // Codigo Filial
		VBJ->VBJ_DATEXE := dDataExec				// Data Execucao
		VBJ->VBJ_HOREXE := cHoraExec				// Hora Execucao
		VBJ->VBJ_TIPEXE := cTipoExec				// Tipo de Execucao ( via 0-Carga Inicial / 1-Manual / 2-Schedule / 3-Reprocess.Manual / 4-Price Updates )
		If !lCargaIni // Se NAO For carga Inicial
			VBJ->VBJ_DATINI := aFilExec[nPosFilExec,10]	// Data Inicial
			VBJ->VBJ_HORINI := aFilExec[nPosFilExec,11]	// Hora Inicial
			VBJ->VBJ_DATFIN := aFilExec[nPosFilExec,12]	// Data Final
			VBJ->VBJ_HORFIN := aFilExec[nPosFilExec,13]	// Hora Final
			VBJ->VBJ_SQSD1I := aFilExec[nPosFilExec,02]	// D1_NUMSEQ Inicial
			VBJ->VBJ_SQSD1F := aFilExec[nPosFilExec,03]	// D1_NUMSEQ Final
			VBJ->VBJ_SQSD2I := aFilExec[nPosFilExec,04]	// D2_NUMSEQ Inicial
			VBJ->VBJ_SQSD2F := aFilExec[nPosFilExec,05]	// D2_NUMSEQ Final
			VBJ->VBJ_SQSD3I := aFilExec[nPosFilExec,06]	// D3_NUMSEQ Inicial
			VBJ->VBJ_SQSD3F := aFilExec[nPosFilExec,07]	// D3_NUMSEQ Final
			VBJ->VBJ_SQVE9I := aFilExec[nPosFilExec,08]	// VE9_NROSUB Inicial
			VBJ->VBJ_SQVE9F := aFilExec[nPosFilExec,09]	// VE9_NROSUB Final
			If lVBJSQVPJI
				VBJ->VBJ_SQVPJI := aFilExec[nPosFilExec,15]  // VPJ Inicial
				VBJ->VBJ_SQVPJF := aFilExec[nPosFilExec,16]  // VPJ Final
			EndIf
		EndIf
		VBJ->VBJ_NOMXML := cNomXML					// Nome XML
		VBJ->VBJ_QTDXML := nSeqXML					// Qtde XML
		MsUnLock()

	Endif

	FreeObj( oConfig )
	FreeObj( oAux )
	cFilAnt := cBkpFil

Return Nil

/*/{Protheus.doc} OA0300111_AjustaDataCompra
	Ajusta a Data de Compra (1a.Compra)

	@author Andre Luis Almeida
	@since 05/08/2018
/*/
Function OA0300111_AjustaDataCompra()

	Local cQuery 	:= ""
	Local aBind		:= {}
	Local cFilSD1	:= xFilial("SD1")
	Local cFilSF4	:= xFilial("SF4")
	Local cFilSBZ	:= xFilial("SBZ")
	Local cFilSB1	:= xFilial('SB1')

	// Cabeçalho do UPDATE — sintaxe difere entre Oracle e SQL Server
	If cDbDriver == "ORACLE"
		cQuery := " UPDATE "+RetSqlName('SBZ')+" T1"
		cQuery += "    SET BZ_PRIENT = "
	Else
		cQuery := " UPDATE T1"
		cQuery += "    SET T1.BZ_PRIENT = "
	EndIf

	// Subquery do SET — igual para os dois
	cQuery += "        ("
	cQuery += "         SELECT MIN(SD1.D1_DTDIGIT)"
	cQuery += "           FROM " + RetSQLName("SD1") + " SD1 "
	cQuery += "           JOIN " + RetSQLName("SF4") + " SF4 ON SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV='01' AND SF4.D_E_L_E_T_=' '" 	; aAdd(aBind, { "C", cFilSF4} ) // OPEMOV = 01 ( COMPRAS )
	cQuery += "          WHERE SD1.D1_FILIAL = ? "	; aAdd(aBind, {"C", cFilSD1})
	cQuery += "            AND SD1.D1_COD = T1.BZ_COD "
	cQuery += "            AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += "        )"

	// FROM apenas para SQL Server
	If cDbDriver != "ORACLE"
		cQuery += "   FROM "+RetSqlName('SBZ')+" T1"
	EndIf

	// WHERE — igual para os dois
	cQuery += " WHERE T1.BZ_FILIAL  = ? " ; aAdd(aBind, {"C", cFilSBZ})
	cQuery += "   AND T1.BZ_PRIENT  = ' ' "
	cQuery += "   AND T1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND T1.BZ_COD IN ("
	cQuery += "         SELECT SB1.B1_COD"
	cQuery += "           FROM "+RetSqlName('SB1')+" SB1 "
	cQuery += "          WHERE SB1.B1_FILIAL = ? "	; aAdd(aBind, {"C", cFilSB1})
	cQuery += "            AND SB1.B1_COD    = T1.BZ_COD "
	cQuery += "            AND SB1.B1_GRUPO IN ( ? ) " ; aAdd(aBind, {"A", aGrpTotal})
	cQuery += "            AND SB1.D_E_L_E_T_ = ' ' ) "
	cQuery += "            AND EXISTS ( SELECT 1"
	cQuery += "                           FROM " + RetSQLName("SD1") + " T2 "
	cQuery += "                           JOIN " + RetSQLName("SF4") + " SF4 ON SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=T2.D1_TES AND SF4.F4_OPEMOV='01' AND SF4.D_E_L_E_T_=' '" ; aAdd(aBind, { "C", cFilSF4} ) // OPEMOV = 01 ( COMPRAS )
	cQuery += "                          WHERE T2.D1_FILIAL = ? " 	; aAdd(aBind, {"C", cFilSD1})
	cQuery += "                            AND T2.D1_COD = T1.BZ_COD "
	cQuery += "                            AND T2.D1_DTDIGIT <> ' ' "
	cQuery += "                            AND T2.D_E_L_E_T_ = ' ' ) "

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly :=*/ .T. )

	If TCSQLExec(cQuery) < 0 // Atualiza o BZ_PRIENT
		cSQLError := TCSQLError()
		OA030040K_RegistraLOG( {"OA030006", STR0018, cSQLError, /*lShowHelp:=*/ .T.}, cCodLogVQL, /*lClose := .F.*/)
	EndIf

Return Nil

/*/{Protheus.doc} OA0300201_Introduction
	Gera XML Completo do Introduction

	@author Andre Luis Almeida
	@since 03/09/2018
/*/
Function OA0300201_Introduction( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , cDtHr , cWHouseID , cCodSB1 , nCntID , cXMLInic , lCargaIni , aParVda , aParCpa , aParDev , aParReq )
	Local cRetXML      := ""
	Local cQAlSQL      := "SQLSB1"
	Local cQuery       := ""
	Local cPrefBal     := GetNewPar("MV_PREFBAL","BAL")
	Local cPrefOfi     := GetNewPar("MV_PREFOFI","OFI")
	Local cNamSB1      := RetSqlName("SB1")
	Local cNamSB2      := RetSqlName("SB2")
	Local cNamSB5      := RetSqlName("SB5")
	Local cNamSBZ      := RetSqlName("SBZ")
	Local cNamSC7      := RetSqlName("SC7")
	Local cNamSD1      := RetSqlName("SD1")
	Local cNamSD2      := RetSqlName("SD2")
	Local cNamSD3      := RetSqlName("SD3")
	Local cNamSF4      := RetSqlName("SF4")
	Local cNamSF2      := RetSqlName("SF2")
	Local cNamVO2      := RetSqlName("VO2")
	Local cNamVO3      := RetSqlName("VO3")
	Local cFilSB1      := xFilial("SB1")
	Local cFilSB2      := xFilial("SB2")
	Local cFilSB5      := xFilial("SB5")
	Local cFilSBZ      := xFilial("SBZ")
	Local cFilSC7      := xFilial("SC7")
	Local cFilSD1      := xFilial("SD1")
	Local cFilSD2      := xFilial("SD2")
	Local cFilSD3      := xFilial("SD3")
	Local cFilSF4      := xFilial("SF4")
	Local cFilVO3      := xFilial("VO3")
	Local nVlrSai      := 0
	Local nVlrEnt	   := 0
	Local dDtaEnt      := ctod("")
	Local dDtaSai      := ctod("")
	Local cEnder       := ""
	Local aBind   	   := {}
	Default dDtIniRef  := Date()
	Default cHrIniRef  := "00:00:00"
	Default dDtFinRef  := Date()
	Default cHrFinRef  := Time()
	Default cDtHr      := ""
	Default cWHouseID  := ""
	Default cCodSB1    := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""
	Default lCargaIni  := .F.
	Default aParVda    := {}
	Default aParCpa    := {}
	Default aParDev    := {}
	Default aParReq    := {}

	aBind  := {}
	cRetXML:= cXMLInic

	If !lCargaIni .and. Empty(cCodSB1) // Se NAO For carga Inicial e fez Com TRIGGER do Banco - Trazer tambem os itens de Troca de Preço, Vendas, Compras e Devolucoes e Requisições
		cQuery := OA030041K_QueryTriggerPRV1(dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef)
		cQuery += " UNION "
	EndIf

	cQuery += "SELECT SB1.B1_CODITE ,"
	If lCargaIni
		cQuery += "    SUM( Coalesce (SB2.B2_QATU + ( Case When SB2.B2_QNPT > 0 then SB2.B2_QNPT Else 0 end ) - ( Case When SB2.B2_QTNP > 0 then SB2.B2_QTNP Else 0 end ) , 0 ) ) AS QTDTOTAL,"
	EndIf
	cQuery += "       MIN(SBZ.BZ_PRIENT)  AS MIN_PRIENT ,"
	cQuery += "       MAX(SBZ.BZ_PRIENT)  AS MAX_PRIENT ,"
	If lB5_ULTVEN
		cQuery += "   MAX(SB5.B5_ULTVEN)  AS B5_ULTVEN  ,"
	EndIf
	cQuery += "       MAX(SB5.B5_LOCALI2) AS B5_LOCALI2  "
	If lCargaIni // Carga Inicial
		cQuery += "  FROM "+cNamSB1+" SB1"
		cQuery += "  LEFT JOIN "+cNamSB2+" SB2 ON ( SB2.B2_FILIAL= ? AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL>='01' AND SB2.B2_LOCAL<='99' AND SB2.D_E_L_E_T_=' ' ) "	; aAdd(aBind, {"C", cFilSB2})
		cQuery += "  JOIN "+cNamSB5+" SB5 ON ( SB5.B5_FILIAL= ? AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' ' )" 	; aAdd(aBind, {"C", cFilSB5})
		cQuery += "  LEFT JOIN "+cNamSBZ+" SBZ ON ( SBZ.BZ_FILIAL= ? AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' ' )"	; aAdd(aBind, {"C", cFilSBZ})
		cQuery += " WHERE SB1.B1_FILIAL= ? " 	; aAdd(aBind, {"C", cFilSB1})
		cQuery += "   AND SB1.D_E_L_E_T_=' '"
	Else // Se NAO For carga Inicial
		If !Empty(cCodSB1) // Item EspecIfico
			cQuery += "  FROM "+cNamSB1+" SB1"
			cQuery += "  JOIN "+cNamSB5+" SB5 ON ( SB5.B5_FILIAL= ? AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' ' )"	; aAdd(aBind, {"C", cFilSB5})
			cQuery += "  LEFT JOIN "+cNamSBZ+" SBZ ON ( SBZ.BZ_FILIAL= ? AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' ' )"	; aAdd(aBind, {"C", cFilSBZ})
			cQuery += " WHERE SB1.B1_FILIAL= ?"	; aAdd(aBind, {"C", cFilSB1})
			cQuery += "   AND SB1.B1_COD= ?"	; aAdd(aBind, {"C", cCodSB1})
			cQuery += "   AND SB1.D_E_L_E_T_=' '"
		Else // Com TRIGGER do Banco
			cQuery += "  FROM "+cNamSB1+"_TTAT_LOG TRIG"
			cQuery += "  JOIN "+cNamSB1+" SB1 ON ( SB1.R_E_C_N_O_=TRIG.TTAT_RECNO AND SB1.D_E_L_E_T_=' ' ) "
			cQuery += "  JOIN "+cNamSB5+" SB5 ON ( SB5.B5_FILIAL= ? AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' ' )" 	; aAdd(aBind, {"C", cFilSB5})
			cQuery += "  LEFT JOIN "+cNamSBZ+" SBZ ON ( SBZ.BZ_FILIAL= ? AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' ' )" 	; aAdd(aBind, {"C", cFilSBZ})
			cQuery += " WHERE TRIG.TTAT_FIELD='B1_COD'"
			If !lEnviaGlass
				cQuery += " AND TRIG.TTAT_PROGRAM <> 'OFIA538'" // OFIA538 é a rotina do Glass para cadastro de peças
			Endif
			cQuery += OA0300041_DTIME( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef )
		EndIf
	EndIf
	cQuery += "   AND SB1.B1_GRUPO IN ( ? ) " ; aAdd(aBind, {"A", aGrpTotal})

	If lCargaIni
		cQuery += " AND (SB5.B5_LOCALI2 <> ' ' " // Precisa ter locação cadastrada
		cQuery += " OR SB2.B2_QATU > 0) " // Precisa ter Quantidade
	EndIf
	cQuery += " GROUP BY SB1.B1_CODITE"

	If !lCargaIni .and. Empty(cCodSB1) // Se NAO For carga Inicial e fez Com TRIGGER do Banco - Trazer tambem os itens de Troca de Preço, Vendas, Compras e Devolucoes e Requisições

		cQuery += " UNION " // Vendas

		cQuery += "SELECT SB1.B1_CODITE ,"
		cQuery += "       MIN(SBZ.BZ_PRIENT)  AS MIN_PRIENT ,"
		cQuery += "       MAX(SBZ.BZ_PRIENT)  AS MAX_PRIENT ,"
		If lB5_ULTVEN
			cQuery += "   MAX(SB5.B5_ULTVEN)  AS B5_ULTVEN  ,"
		EndIf
		cQuery += "       MAX(SB5.B5_LOCALI2) AS B5_LOCALI2  "
		cQuery += "  FROM "+cNamSD2+" SD2"
		cQuery += "  JOIN "+cNamSF2+" SF2 ON SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_PREFORI IN ( ? ) AND SF2.D_E_L_E_T_=' '" ; aAdd(aBind, {"A", { cPrefBal, cPrefOfi }})
		cQuery += "  JOIN "+cNamSF4+" SF4 ON SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' '" ; aAdd(aBind, {"C", cFilSF4}) // OPEMOV = 05 ( VENDAS )
		cQuery += "  JOIN "+cNamSB1+" SB1 ON SB1.B1_FILIAL= ? AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' " ; aAdd(aBind, {"C", cFilSB1})
		cQuery += "  JOIN "+cNamSB5+" SB5 ON SB5.B5_FILIAL= ? AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' '" ; aAdd(aBind, {"C", cFilSB5})
		cQuery += "  LEFT JOIN "+cNamSBZ+" SBZ ON SBZ.BZ_FILIAL= ? AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' '" ; aAdd(aBind, {"C", cFilSBZ})
		cQuery += " WHERE SD2.D2_FILIAL= ? " ; aAdd(aBind, {"C", cFilSD2})
		If Len(aParVda) > 0 .and. !Empty(aParVda[1])
			cQuery += "   AND SD2.D2_NUMSEQ >  ? "	; aAdd(aBind, {"C", aParVda[1]})
			cQuery += "   AND SD2.D2_NUMSEQ <= ? "  ; aAdd(aBind, {"C", aParVda[2]})
		Else
			cQuery += "   AND SF2.F2_EMISSAO >= ? "	; aAdd(aBind, {"D", dDtIniRef})
			cQuery += "   AND SF2.F2_EMISSAO <= ? "	; aAdd(aBind, {"D", dDtFinRef})
		EndIf
		cQuery += "   AND SD2.D_E_L_E_T_=' '"
		cQuery += "   AND SB1.B1_GRUPO IN ( ? ) " ; aAdd(aBind, {"A", aGrpTotal})

		cQuery += " GROUP BY SB1.B1_CODITE"

		cQuery += " UNION " // Compras

		cQuery += "SELECT SB1.B1_CODITE ,"
		cQuery += "       MIN(SBZ.BZ_PRIENT)  AS MIN_PRIENT ,"
		cQuery += "       MAX(SBZ.BZ_PRIENT)  AS MAX_PRIENT ,"
		If lB5_ULTVEN
			cQuery += "   MAX(SB5.B5_ULTVEN)  AS B5_ULTVEN  ,"
		EndIf
		cQuery += "       MAX(SB5.B5_LOCALI2) AS B5_LOCALI2  "
		cQuery += "  FROM "+cNamSD1+" SD1"
		cQuery += "  JOIN "+cNamSF4+" SF4 ON SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV='01' AND SF4.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSF4 } ) // OPEMOV = 01 ( COMPRAS )
		cQuery += "  JOIN "+cNamSB1+" SB1 ON SB1.B1_FILIAL= ? AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSB1 } )
		cQuery += "  JOIN "+cNamSB5+" SB5 ON SB5.B5_FILIAL= ? AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSB5 } )
		cQuery += "  LEFT JOIN "+cNamSBZ+" SBZ ON SBZ.BZ_FILIAL= ? AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSBZ } )
		cQuery += " WHERE SD1.D1_FILIAL= ?"	; aAdd( aBind, { "C", cFilSD1 } )
		If Len(aParCpa) > 0 .and. !Empty(aParCpa[1])
			cQuery += "   AND SD1.D1_NUMSEQ >  ? "	; aAdd( aBind, { "C", aParCpa[1] } )
			cQuery += "   AND SD1.D1_NUMSEQ <= ? "	; aAdd( aBind, { "C", aParCpa[2] } )
		Else
			cQuery += "   AND SD1.D1_DTDIGIT >= ? "	; aAdd( aBind, {"D", dDtIniRef})
			cQuery += "   AND SD1.D1_DTDIGIT <= ? "	; aAdd( aBind, {"D", dDtFinRef})
		EndIf
		cQuery += "   AND SD1.D_E_L_E_T_=' '"
		cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
		cQuery += " GROUP BY SB1.B1_CODITE"

		cQuery += " UNION " // Devoluções

		cQuery += "SELECT SB1.B1_CODITE ,"
		cQuery += "       MIN(SBZ.BZ_PRIENT)  AS MIN_PRIENT ,"
		cQuery += "       MAX(SBZ.BZ_PRIENT)  AS MAX_PRIENT ,"
		If lB5_ULTVEN
			cQuery += "   MAX(SB5.B5_ULTVEN)  AS B5_ULTVEN  ,"
		EndIf
		cQuery += "       MAX(SB5.B5_LOCALI2) AS B5_LOCALI2  "
		cQuery += "  FROM "+cNamSD1+" SD1"
		cQuery += "  JOIN "+cNamSF4+" SF4 ON SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV='09' AND SF4.D_E_L_E_T_=' '" 	; aAdd( aBind, { "C", cFilSF4 } ) // OPEMOV = 09 ( DEVOLUCOES )
		cQuery += "  JOIN "+cNamSB1+" SB1 ON SB1.B1_FILIAL= ? AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' "	; aAdd( aBind, { "C", cFilSB1 } )
		cQuery += "  JOIN "+cNamSF2+" SF2 ON SF2.F2_FILIAL = SD1.D1_FILIAL AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI AND SF2.F2_PREFORI IN ( ? ) AND SF2.D_E_L_E_T_=' '"	; aAdd( aBind, { "A", { cPrefBal, cPrefOfi } } )
		cQuery += "  JOIN "+cNamSB5+" SB5 ON SB5.B5_FILIAL= ? AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSB5 } )
		cQuery += "  LEFT JOIN "+cNamSBZ+" SBZ ON SBZ.BZ_FILIAL= ? AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSBZ } )
		cQuery += " WHERE SD1.D1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSD1 } )
		If Len(aParDev) > 0 .and. !Empty(aParDev[1])
			cQuery += "   AND SD1.D1_NUMSEQ >  ? "	; aAdd( aBind, { "C", aParDev[1] } )
			cQuery += "   AND SD1.D1_NUMSEQ <= ? "	; aAdd( aBind, { "C", aParDev[2] } )
		Else
			cQuery += "   AND SD1.D1_DTDIGIT >= ? "	; aAdd( aBind, { "C", dtos(dDtIniRef) } )
			cQuery += "   AND SD1.D1_DTDIGIT <= ? "	; aAdd( aBind, { "C", dtos(dDtFinRef) } )
		EndIf
		cQuery += "   AND SD1.D_E_L_E_T_=' '"
		cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
		cQuery += " GROUP BY SB1.B1_CODITE"

		cQuery += " UNION " // Requisições

		cQuery += "SELECT SB1.B1_CODITE ,"
		cQuery += "       MIN(SBZ.BZ_PRIENT)  AS MIN_PRIENT ,"
		cQuery += "       MAX(SBZ.BZ_PRIENT)  AS MAX_PRIENT ,"
		If lB5_ULTVEN
			cQuery += "   MAX(SB5.B5_ULTVEN)  AS B5_ULTVEN  ,"
		EndIf
		cQuery += "       MAX(SB5.B5_LOCALI2) AS B5_LOCALI2  "
		cQuery += "  FROM "+cNamSD3+" SD3 "
		cQuery += "  JOIN "+cNamSB1+" SB1 ON SB1.B1_FILIAL= ? AND SB1.B1_COD=SD3.D3_COD AND SB1.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSB1 } )
		cQuery += "  JOIN "+cNamSB5+" SB5 ON SB5.B5_FILIAL= ? AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSB5 } )
		cQuery += "  JOIN "+cNamVO3+" VO3 ON VO3.VO3_FILIAL= ? AND VO3.VO3_GRUITE=SB1.B1_GRUPO AND VO3.VO3_CODITE=SB1.B1_CODITE AND VO3.VO3_NUMDOC=SD3.D3_DOC AND VO3.VO3_DATCAN=' ' AND VO3.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilVO3 } )
		cQuery += "  JOIN "+cNamVO2+" VO2 ON VO2.VO2_FILIAL=VO3.VO3_FILIAL AND VO2.VO2_NOSNUM=VO3.VO3_NOSNUM AND VO2.D_E_L_E_T_=' '"
		cQuery += "  LEFT JOIN "+cNamSBZ+" SBZ ON SBZ.BZ_FILIAL= ? AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilSBZ } )
		cQuery += " WHERE SD3.D3_FILIAL= ? "	; aAdd( aBind, { "C", cFilSD3 } )
		If Len(aParReq) > 0 .and. !Empty(aParReq[1])
			cQuery += "   AND SD3.D3_NUMSEQ >  ? "	; aAdd( aBind, { "C", aParReq[1] } )
			cQuery += "   AND SD3.D3_NUMSEQ <= ? "	; aAdd( aBind, { "C", aParReq[2] } )
		Else
			cQuery += "   AND VO2.VO2_DATREQ >= ? "	; aAdd( aBind, { "C", dtos(dDtIniRef) } )
			cQuery += "   AND VO2.VO2_DATREQ <= ? "	; aAdd( aBind, { "C", dtos(dDtFinRef) } )
		EndIf
		cQuery += "   AND SD3.D3_TM <= '500'"
		cQuery += "   AND SD3.D3_ESTORNO <> 'S'"
		cQuery += "   AND SD3.D_E_L_E_T_=' '"
		cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
		cQuery += " GROUP BY SB1.B1_CODITE"

	EndIf

	cQuery  := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.F.,.F.,{ "1" , cQuery , lPriceUpdates }) // 1 - Introduction
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )

	While !( cQAlSQL )->( Eof() )
		nVlrSai := 0
		nVlrEnt := 0
		nVlrSai := OA030038C_ExecFormula( "PurchaseGross", cGrpPrinc, (cQAlSQL)->B1_CODITE ) // Preco de Venda
		nVlrEnt := OA030038C_ExecFormula( "PurchaseNet", cGrpPrinc, (cQAlSQL)->B1_CODITE ) // Preco de Reposicao

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )
		cRetXML += '<v11:PartForSaleIntroduction>'+PulaLinha
		cRetXML += '<v11:PartForSaleUpdate timeIntroduced="'+cDtHr+'">'+PulaLinha
		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim(( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
		cRetXML += '</v11:PartForSaleUpdate>'+PulaLinha
		// Passar PRECO DE VENDA do ITEM
		//	-> PartPriceUpdate (2)
		cRetXML += OA0300091_PriceUpdate( cDtHr , ( cQAlSQL )->( B1_CODITE ) , nVlrSai , "PurchaseGross" )
		cRetXML += '</v11:PartForSaleIntroduction>'+PulaLinha
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )
		cRetXML += '<v11:PartForSaleIntroduction>'+PulaLinha
		cRetXML += '<v11:PartForSaleUpdate timeIntroduced="'+cDtHr+'">'+PulaLinha
		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim(( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
		cRetXML += '</v11:PartForSaleUpdate>'+PulaLinha
		// Passar PRECO DE REPOSICAO do ITEM
		//	-> PartPriceUpdate (2)
		cRetXML += OA0300091_PriceUpdate( cDtHr , ( cQAlSQL )->( B1_CODITE ) , nVlrEnt , "PurchaseNet" )
		cRetXML += '</v11:PartForSaleIntroduction>'+PulaLinha
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++

		If lCargaIni .and. !lPriceUpdates
			If !Empty( ( cQAlSQL )->( MIN_PRIENT ) )
				dDtaEnt := stod( ( cQAlSQL )->( MIN_PRIENT ) )
			Else
				dDtaEnt := stod( ( cQAlSQL )->( MAX_PRIENT ) )
			EndIf
			If lB5_ULTVEN
				dDtaSai := stod( ( cQAlSQL )->( B5_ULTVEN ) )
			EndIf
			cEnder := Alltrim(( cQAlSQL )->( B5_LOCALI2 ))

			If nCntQtd == nLimiteArq
				OA0300071_GravaXML(cRetXML)
				cRetXML := ""
				nCntQtd := 1
			EndIf

			cRetXML += OA0300051_Transaction( .T. , nCntID )
			// Passar ESTOQUE do ITEM
			//	-> PartInStockIntroduction (3)
			cRetXML += OA0300081_Estoque( cWHouseID , ( cQAlSQL )->( B1_CODITE ) , ( cQAlSQL )->( QTDTOTAL ) , dDtaEnt , dDtaSai , cEnder , cNamSB1 , cFilSB1 , cNamSB2 , cFilSB2 , cNamSC7 , cFilSC7 )
			cRetXML += OA0300051_Transaction( .F. , 0 )
			nCntID++
			nCntQtd++
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SB1")

Return cRetXML

/*/{Protheus.doc} OA0300211_ValorVenda
	Gera XML completo de atualizacao do Valor de Venda do Item

	@author Andre Luis Almeida
	@since 03/09/2018
/*/
Function OA0300211_ValorVenda( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , cDtHr , cCodSB1 , nCntID , cXMLInic )
	Local cRetXML      := ""
	Local cQAlSQL      := "SQLSB1"
	Local cQuery       := ""
	Local nVlrSai      := 0
	Local nVlrEnt 	   := 0
	Local cNamSB1      := RetSqlName("SB1")
	Local cFilSB1      := xFilial("SB1")
	Local aBind		   := {}
	Default cDtHr      := ""
	Default cCodSB1    := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""

	cRetXML := cXMLInic
	If !Empty(cCodSB1) // Item EspecIfico
		cQuery	:= "SELECT DISTINCT SB1.B1_CODITE "
		cQuery	+= "  FROM "+cNamSB1+" SB1"
		cQuery	+= " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 })
		cQuery	+= "   AND SB1.B1_COD= ? "	; aAdd( aBind, { "C", cCodSB1 })
		cQuery	+= "   AND SB1.D_E_L_E_T_=' '"
		cQuery	+= "   AND SB1.B1_GRUPO IN ( ? ) "	; aAdd( aBind, { "A", aGrpTotal })
	Else // Com TRIGGER do Banco
		cQuery	+= OA030041K_QueryTriggerPRV1(dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef)
	EndIf

	cQuery  := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.F.,.F.,{ "2" , cQuery , lPriceUpdates }) // 2 - PriceUpdate
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
	
	While !( cQAlSQL )->( Eof() )

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		nVlrSai := 0
		nVlrEnt := 0
		nVlrSai := OA030038C_ExecFormula( "PurchaseGross", cGrpPrinc, (cQAlSQL)->B1_CODITE ) // Preço de Venda
		nVlrEnt := OA030038C_ExecFormula( "PurchaseNet", cGrpPrinc, (cQAlSQL)->B1_CODITE ) // Preco de Reposicao

		cRetXML += OA0300051_Transaction( .T. , nCntID )

		// Passar PRECO DE VENDA do ITEM
		//	-> PartPriceUpdate (2)
		cRetXML += OA0300091_PriceUpdate( cDtHr , ( cQAlSQL )->( B1_CODITE ) , nVlrSai , "PurchaseGross" )
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++
		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )

		// Passar PRECO DE REPOSICAO do ITEM
		//	-> PartPriceUpdate (2)
		cRetXML += OA0300091_PriceUpdate( cDtHr , ( cQAlSQL )->( B1_CODITE ) , nVlrEnt , "PurchaseNet" )
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SB1")

Return cRetXML

/*/{Protheus.doc} OA0300231_Vendas
	Gera XML referente as Vendas (PartDelivery) de um determinado Periodo
	@author Andre Luis Almeida
	@since 03/09/2018
/*/
Function OA0300231_Vendas( cNroSqIni , cNroSqFin , dDtIniRef , dDtFinRef , cWHouseID , nCntID , cXMLInic )
	Local cRetXML      := ""
	Local cAux1        := ""
	Local cAux2        := ""
	Local cQAlSQL      := "SQLSD2"
	Local cQuery       := ""
	Local cOrdNumber   := ""
	Local cSequen      := ""
	Local lPOA30SOF    := ExistBlock("POA30SOF") // Sequencia Oficina - Customizado
	Local cPrefBal     := GetNewPar("MV_PREFBAL","BAL")
	Local cPrefOfi     := GetNewPar("MV_PREFOFI","OFI")
	Local cFilVS1      := xFilial("VS1")
	Local cFilVOO      := xFilial("VOO")
	Local cFilVO3      := xFilial("VO3")
	Local cNamVS1      := RetSqlName("VS1")
	Local cNamVOO      := RetSqlName("VOO")
	Local aBind		   := {}
	Default cNroSqIni  := ""
	Default cNroSqFin  := ""
	Default dDtIniRef  := Date()
	Default dDtFinRef  := Date()
	Default cWHouseID  := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""

	cRetXML := cXMLInic
	aBind  := {}
	cQuery := "SELECT SF2.F2_EMISSAO ,"
	cQuery += "       SB1.B1_CODITE  ,"
	cQuery += "       SB1.B1_COD     ,"
	cQuery += "       SD2.D2_QUANT   ,"
	cQuery += "       SD2.D2_ITEM    ,"
	cQuery += "       SD2.D2_DOC     ,"
	cQuery += "       SD2.D2_SERIE   ,"
	cQuery += "       SF2.F2_HORA    ,"
	cQuery += "       SF2.F2_PREFORI  "
	cQuery += "  FROM "+RetSqlName("SD2")+" SD2"
	cQuery += "  JOIN "+RetSqlName("SF2")+" SF2 ON ( SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_PREFORI IN ( ? ) AND SF2.D_E_L_E_T_=' ' ) " ; aAdd( aBind, { "A", {cPrefBal,cPrefOfi} } )
	cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " ; aAdd( aBind, { "C", xFilial("SF4") } ) // OPEMOV = 05 ( VENDA )
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL= ? AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) " ; aAdd( aBind, { "C", xFilial("SB1") } )
	cQuery += " WHERE SD2.D2_FILIAL= ? " ; aAdd( aBind, { "C", xFilial("SD2") } )

	If !Empty(cNroSqIni)
		cQuery += "   AND SD2.D2_NUMSEQ >  ? " ; aAdd( aBind, { "C", cNroSqIni } )
		cQuery += "   AND SD2.D2_NUMSEQ <= ? " ; aAdd( aBind, { "C", cNroSqFin } )
	Else
		cQuery += "   AND SF2.F2_EMISSAO >= ? " ; aAdd( aBind, { "C", dtos(dDtIniRef) } )
		cQuery += "   AND SF2.F2_EMISSAO <= ? " ; aAdd( aBind, { "C", dtos(dDtFinRef) } )
	EndIf
	cQuery += "   AND SD2.D_E_L_E_T_=' '"
	cQuery += "   AND SB1.B1_GRUPO IN ( ? )" ; aAdd( aBind, { "A", aGrpTotal } )
	cQuery += " ORDER BY SF2.F2_EMISSAO , SD2.D2_DOC , SD2.D2_ITEM"

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.F.,.F.,{ "3" , cQuery , lPriceUpdates }) // 3 - PartDelivery ( Vendas )
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )

	While !( cQAlSQL )->( Eof() )
		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		If !Empty( ( cQAlSQL )->( F2_EMISSAO ) )
			cAux1 := ( cQAlSQL )->( F2_EMISSAO )+"T"
			cAux1 += Left(( cQAlSQL )->( F2_HORA ),2)
			cAux1 += right(Left(( cQAlSQL )->( F2_HORA ),5),2)
		Else
			cAux1 := "19500101T0000"
		EndIf
		cAux2 := Alltrim(TransForm(( cQAlSQL )->( D2_QUANT ),"@E 9999999999"))

		aBind := {}
		cSequen := ""
		If ( cQAlSQL )->( F2_PREFORI ) == cPrefBal // Balcao
			cQuery := "SELECT VS1_NUMORC"
			cQuery += "  FROM "+cNamVS1 
			cQuery += " WHERE VS1_FILIAL= ? " ; aAdd( aBind, { "C", cFilVS1 } )
			cQuery += "   AND VS1_NUMNFI= ? " ; aAdd( aBind, { "C", ( cQAlSQL )->( D2_DOC ) } )
			cQuery += "   AND VS1_SERNFI= ? " ; aAdd( aBind, { "C", ( cQAlSQL )->( D2_SERIE ) } )
			cQuery += "   AND D_E_L_E_T_=' '"
			cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
			cOrdNumber := FM_SQL(cQuery)
		Else // Oficina
			cQuery := "SELECT VOO_NUMOSV"
			cQuery += "  FROM "+cNamVOO "
			cQuery += " WHERE VOO_FILIAL= ? " ; aAdd( aBind, { "C", cFilVOO } )
			cQuery += "   AND VOO_NUMNFI= ? " ; aAdd( aBind, { "C", ( cQAlSQL )->( D2_DOC ) } )
			cQuery += "   AND VOO_SERNFI= ? " ; aAdd( aBind, { "C", ( cQAlSQL )->( D2_SERIE ) } )
			cQuery += "   AND D_E_L_E_T_=' '"
			cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
			cOrdNumber := FM_SQL(cQuery)
			If lPOA30SOF
				cSequen := ExecBlock("POA30SOF",.F.,.F.,{ cFilVO3 , cOrdNumber , ( cQAlSQL )->( B1_COD ) })
			EndIf
		EndIf

		If Empty(cSequen)
			cSequen := strzero(val(( cQAlSQL )->( D2_ITEM )),4)
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )
		cRetXML += '<v11:PartDelivery deliverTime="'+cAux1+'" deliveredQuantity="'+cAux2+'">'+PulaLinha
		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:OrderId orderLineNumber="'+cSequen+'" '
		cRetXML +=              'orderNumber="'+Alltrim(cOrdNumber)+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim( ( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
		cRetXML += '</v11:PartDelivery>'+PulaLinha
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++

		// Vetores utilizados no Balance de Estoque
		If aScan(aIteBalance, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
			aAdd(aIteBalance,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , cAux1 })
		EndIf

		If aScan(aIteVendas, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
			aAdd(aIteVendas,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , cAux1 })
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SD2")

Return cRetXML

/*/{Protheus.doc} OA0300241_Compras
	Gera XML referente as Compras (PartReception) de um determinado Periodo

	@author Andre Luis Almeida
	@since 03/09/2018
/*/
Function OA0300241_Compras( cNroSqIni , cNroSqFin , dDtIniRef , dDtFinRef , cWHouseID , nCntID , cXMLInic )
	Local cRetXML      := ""
	Local cQAlSQL      := "SQLSD1"
	Local cQuery       := ""
	Local cAux1        := ""
	Local cAux2        := ""
	Local cAux3        := ""
	Local aBind
	Default cNroSqIni  := ""
	Default cNroSqFin  := ""
	Default dDtIniRef  := Date()
	Default dDtFinRef  := Date()
	Default cWHouseID  := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""

	cRetXML := cXMLInic

	aBind := {}
	cQuery := "SELECT SD1.D1_EMISSAO                ,"
	cQuery += "       SF1.F1_HORA                   ,"
	cQuery += "       SB1.B1_CODITE                 ,"
	cQuery += "       SUM(SD1.D1_QUANT) AS D1_QUANT ,"
	cQuery += "       MAX(SB1.B1_UCOM)  AS B1_UCOM  ,"
	cQuery += "       MAX(SBZ.BZ_UCOM)  AS BZ_UCOM   "
	cQuery += "  FROM "+RetSqlName("SD1")+" SD1"
	cQuery += "  JOIN "+RetSqlName("SF1")+" SF1 ON ( SF1.F1_FILIAL=SD1.D1_FILIAL AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.F1_FORNECE=SD1.D1_FORNECE AND SF1.F1_LOJA=SD1.D1_LOJA AND SF1.D_E_L_E_T_=' ' ) "
	cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL= ?  AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV='01' AND SF4.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", xFilial("SF4") } ) // OPEMOV = 01 ( COMPRA )
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL= ?  AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", xFilial("SB1") } )
	cQuery += "  LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON ( SBZ.BZ_FILIAL= ?  AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' ' )"	; aAdd( aBind, { "C", xFilial("SBZ") } )
	cQuery += " WHERE SD1.D1_FILIAL= ? "	; aAdd( aBind, { "C", xFilial("SD1") } )

	If !Empty(cNroSqIni)
		cQuery += "   AND SD1.D1_NUMSEQ >  ? "	; aAdd( aBind, { "C", cNroSqIni } )
		cQuery += "   AND SD1.D1_NUMSEQ <= ? "	; aAdd( aBind, { "C", cNroSqFin } )
	Else
		cQuery += "   AND SD1.D1_DTDIGIT >= ? "	; aAdd( aBind, { "C", dtos(dDtIniRef) } )
		cQuery += "   AND SD1.D1_DTDIGIT <= ? "	; aAdd( aBind, { "C", dtos(dDtFinRef) } )
	EndIf
	cQuery += "   AND SD1.D_E_L_E_T_=' '"
	cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery += " GROUP BY SD1.D1_EMISSAO , SF1.F1_HORA , SB1.B1_CODITE "
	cQuery += " ORDER BY SD1.D1_EMISSAO , SB1.B1_CODITE "

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.F.,.F.,{ "4" , cQuery , lPriceUpdates }) // 4 - PartReception ( Compras )
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
	While !( cQAlSQL )->( Eof() )

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		If !Empty( ( cQAlSQL )->( D1_EMISSAO ) )
			cAux1 := ( cQAlSQL )->( D1_EMISSAO )+"T"
			cAux1 += Left(( cQAlSQL )->( F1_HORA ),2)
			cAux1 += right(Left(( cQAlSQL )->( F1_HORA ),5),2)
		Else
			cAux1 := "19500101T0000"
		EndIf
		cAux2 := Alltrim(TransForm(( cQAlSQL )->( D1_QUANT ),"@E 9999999999"))
		If !Empty(( cQAlSQL )->( BZ_UCOM )) .and. ( cQAlSQL )->( BZ_UCOM ) > ( cQAlSQL )->( B1_UCOM )
			cAux3 := ( cQAlSQL )->( BZ_UCOM )+"T0000"
		Else
			If !Empty( ( cQAlSQL )->( B1_UCOM ) )
				cAux3 := ( cQAlSQL )->( B1_UCOM )+"T0000"
			Else
				cAux3 := "19500101T0000"
			EndIf
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )

		cRetXML += '<v11:PartReception supplier="Scania" '
		cRetXML +=                    'receptionTime="'+cAux1+'" '
		cRetXML +=                    'receivedQuantity="'+cAux2+'" '
		cRetXML +=                    'binnedTime="'+cAux3+'" '
		cRetXML +=                    'binnedQuantity="'+cAux2+'">'+PulaLinha

		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:PartId partNumber="'+Alltrim( ( cQAlSQL )->( B1_CODITE ) )+'" assortmentOwnerId="'+cOwnerID+'"/>'+PulaLinha

		cRetXML += '</v11:PartReception>'+PulaLinha

		cRetXML += OA0300051_Transaction( .F. , 0 )

		nCntID++
		nCntQtd++

		// Vetores utilizados no Balance de Estoque
		If aScan(aIteBalance, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
			aAdd(aIteBalance,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , cAux1 })
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SD1")
Return cRetXML

/*/{Protheus.doc} OA0300251_Devolucoes
	Gera XML referente as Devoluções (PartDelivery) de um determinado Periodo

	@author Andre Luis Almeida
	@since 03/09/2018
/*/
Function OA0300251_Devolucoes( cNroSqIni , cNroSqFin , dDtIniRef , dDtFinRef , cWHouseID , nCntID , cXMLInic )
	Local cRetXML      := ""
	Local cQAlSQL      := "SQLSD1"
	Local cQuery       := ""
	Local cAux1        := ""
	Local cAux2        := ""
	Local cSequen      := ""
	Local cPrefBal     := GetNewPar("MV_PREFBAL","BAL")
	Local cPrefOfi     := GetNewPar("MV_PREFOFI","OFI")
	Local cFilVS1      := xFilial("VS1")
	Local cFilVOO      := xFilial("VOO")
	Local cFilVO3      := xFilial("VO3")
	Local cNamVS1      := RetSqlName("VS1")
	Local cNamVOO      := RetSqlName("VOO")
	Local lPOA30SOF    := ExistBlock("POA30SOF") // Sequencia Oficina - Customizado
	Local aBind
	Default cNroSqIni  := ""
	Default cNroSqFin  := ""
	Default dDtIniRef  := Date()
	Default dDtFinRef  := Date()
	Default cWHouseID  := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""

	cRetXML := cXMLInic
	aBind := {}
	cQuery := "SELECT SA1.A1_NOME    ,"
	cQuery += "       SD1.D1_FORNECE ,"
	cQuery += "       SD1.D1_LOJA    ,"
	cQuery += "       SD1.D1_EMISSAO ,"
	cQuery += "       SF1.F1_HORA    ,"
	cQuery += "       SD1.D1_ITEMORI ,"
	cQuery += "       SB1.B1_CODITE  ,"
	cQuery += "       SB1.B1_COD     ,"
	cQuery += "       SD2.D2_QUANT   ,"
	cQuery += "       SD2.D2_QTDEDEV ,"
	cQuery += "       SF2.F2_PREFORI ,"
	cQuery += "       SF2.F2_DOC     ,"
	cQuery += "       SF2.F2_SERIE    "
	cQuery += "  FROM "+RetSqlName("SD1")+" SD1"
	cQuery += "  JOIN "+RetSqlName("SF1")+" SF1 ON ( SF1.F1_FILIAL=SD1.D1_FILIAL AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.F1_FORNECE=SD1.D1_FORNECE AND SF1.F1_LOJA=SD1.D1_LOJA AND SF1.D_E_L_E_T_=' ' ) "
	cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV='09' AND SF4.D_E_L_E_T_=' ' ) " 	; aAdd( aBind, { "C", xFilial("SF4") }) // OPEMOV = 09 ( DEVOLUCOES )
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL= ? AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", xFilial("SB1") })
	cQuery += "  JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL= ? AND SA1.A1_COD=SD1.D1_FORNECE AND SA1.A1_LOJA=SD1.D1_LOJA AND SA1.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", xFilial("SA1") })
	cQuery += "  JOIN "+RetSqlName("SF2")+" SF2 ON ( SF2.F2_FILIAL=SD1.D1_FILIAL AND SF2.F2_DOC=SD1.D1_NFORI AND SF2.F2_SERIE=SD1.D1_SERIORI AND SF2.F2_PREFORI IN ( ? ) AND SF2.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "A", {cPrefBal,cPrefOfi} })
	cQuery += "  JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL=SD1.D1_FILIAL AND SD2.D2_DOC=SD1.D1_NFORI AND SD2.D2_SERIE=SD1.D1_SERIORI AND SD2.D2_ITEM=SD1.D1_ITEMORI AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE SD1.D1_FILIAL= ? "	; aAdd( aBind, { "C", xFilial("SD1") })
	If !Empty(cNroSqIni)
		cQuery += "   AND SD1.D1_NUMSEQ >  ? "	; aAdd( aBind, { "C", cNroSqIni } )
		cQuery += "   AND SD1.D1_NUMSEQ <= ? "	; aAdd( aBind, { "C", cNroSqFin } )
	Else
		cQuery += "   AND SD1.D1_DTDIGIT >= ? "	; aAdd( aBind, { "C", dtos(dDtIniRef) } )
		cQuery += "   AND SD1.D1_DTDIGIT <= ? "	; aAdd( aBind, { "C", dtos(dDtFinRef) } )
	EndIf
	cQuery += "   AND SD1.D_E_L_E_T_=' '"
	cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal })
	cQuery += " ORDER BY SD1.D1_EMISSAO , SB1.B1_CODITE "

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.F.,.F.,{ "5" , cQuery , lPriceUpdates }) // 5 - PartDelivery ( Devolucoes )
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
	While !( cQAlSQL )->( Eof() )

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		If !Empty( ( cQAlSQL )->( D1_EMISSAO ) )
			cAux1 := ( cQAlSQL )->( D1_EMISSAO )+"T"
			cAux1 += Left(( cQAlSQL )->( F1_HORA ),2)
			cAux1 += right(Left(( cQAlSQL )->( F1_HORA ),5),2)
		Else
			cAux1 := "19500101T0000"
		EndIf
		cAux2 := Alltrim(TransForm(( cQAlSQL )->( D2_QUANT )-( cQAlSQL )->( D2_QTDEDEV ),"@E 9999999999"))

		aBind := {}
		cSequen := ""
		If ( cQAlSQL )->( F2_PREFORI ) == cPrefBal // Balcao
			cQuery := "SELECT VS1_NUMORC"
			cQuery += "  FROM "+cNamVS1
			cQuery += " WHERE VS1_FILIAL= ? "	; aAdd( aBind, { "C", cFilVS1 } )
			cQuery += "   AND VS1_NUMNFI= ? "	; aAdd( aBind, { "C", ( cQAlSQL )->( F2_DOC ) } )
			cQuery += "   AND VS1_SERNFI= ? "	; aAdd( aBind, { "C", ( cQAlSQL )->( F2_SERIE ) } )
			cQuery += "   AND D_E_L_E_T_=' '"
			cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
			cOrdNumber := FM_SQL(cQuery)
		Else // Oficina
			cQuery := "SELECT VOO_NUMOSV"
			cQuery += "  FROM "+cNamVOO
			cQuery += " WHERE VOO_FILIAL= ? "	; aAdd( aBind, { "C", cFilVOO } )
			cQuery += "   AND VOO_NUMNFI= ? "	; aAdd( aBind, { "C", ( cQAlSQL )->( F2_DOC ) } )
			cQuery += "   AND VOO_SERNFI= ? "	; aAdd( aBind, { "C", ( cQAlSQL )->( F2_SERIE ) } )
			cQuery += "   AND D_E_L_E_T_=' '"
			cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
			cOrdNumber := FM_SQL(cQuery)
			If lPOA30SOF
				cSequen := ExecBlock("POA30SOF",.F.,.F.,{ cFilVO3 , cOrdNumber , ( cQAlSQL )->( B1_COD ) })
			EndIf
		EndIf
		If Empty(cSequen)
			cSequen := strzero(val(( cQAlSQL )->( D1_ITEMORI )),4)
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )
		cRetXML += '<v11:PartDelivery deliverTime="'+cAux1+'" deliveredQuantity="'+cAux2+'">'+PulaLinha

		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:OrderId orderLineNumber="'+cSequen+'" '
		cRetXML +=              'orderNumber="'+Alltrim(cOrdNumber)+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim( ( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha

		cRetXML += '</v11:PartDelivery>'+PulaLinha

		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++

		// Vetores utilizados no Balance de Estoque
		If aScan(aIteBalance, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
			aAdd(aIteBalance,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , cAux1 })
		EndIf

		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SD1")
Return cRetXML

/*/{Protheus.doc} OA0300261_BalanceEstoque
	Gera XML referente ao StockBalance - TAG necessaria apos existir registros referente as Compras, Vendas ou Devoluções

	@author Andre Luis Almeida
	@since 03/09/2018
/*/
Function OA0300261_BalanceEstoque( cWHouseID , nCntID , cXMLInic )
	Local cRetXML     := ""
	Local cQAlSQL     := "SQLSB2SC7"
	Local cQuery      := ""
	Local cQuery1     := ""
	Local cQuery2     := ""
	Local cQuery3     := ""
	Local cQuery4     := ""
	Local nCntFor     := 0
	Local nQtdAtu     := 0
	Local nQtdResBlq  := 0
	Local nQtdTot     := 0
	Local cAux1       := ""
	Local cAux2       := ""
	Local cNamSB1     := RetSqlName("SB1")
	Local cNamSB2     := RetSqlName("SB2")
	Local cNamSC7     := RetSqlName("SC7")
	Local cFilSB1     := xFilial("SB1")
	Local cFilSB2     := xFilial("SB2")
	Local cFilSC7     := xFilial("SC7")
	Local nInIfor     := 1
	Local cDtHrNow    := dtos(dDataBase)+"T"+Substr(Time(),1,2)+Substr(Time(),4,2)
	Local lPOA30EBA   := ExistBlock("POA30EBA") // Mudar query do Estoque Balance - Customizado
	Local aBind
	Default cWHouseID := ""
	Default nCntID    := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic  := ""

	cRetXML := cXMLInic

	aSort(aIteBalance,1,,{|x,y| x[1] < y[1] }) // Ordem: Filial
	nInIfor := aScan(aIteBalance, {|x| x[1] == cFilAnt })
	If nInIfor == 0 // Se nao encontrar a Filial
		Return cRetXML
	EndIf

	aBind := {}
	cQuery1 := "SELECT SUM( SB2.B2_QATU + SB2.B2_QNPT - SB2.B2_QTNP ) AS QTDTOTAL "
	cQuery1 += "  FROM "+cNamSB1+" SB1"
	cQuery1 += "  JOIN "+cNamSB2+" SB2 ON ( SB2.B2_FILIAL= ? AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL=SB1.B1_LOCPAD AND SB2.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", cFilSB2 } )
	cQuery1 += " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery1 += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery1 += "   AND SB1.D_E_L_E_T_=' '"
	cQuery1 += "   AND SB1.B1_CODITE="

	cQuery1 := OA030037C_ExecQuery( cQuery1, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30EBA
		cQuery1 := ExecBlock("POA30EBA",.f.,.f.,{ "1", cQuery1 , aGrpTotal })
	EndIf

	aBind := {}
	cQuery2 := "SELECT SUM(SB2.B2_QATU) AS B2_QATU "
	cQuery2 += "  FROM "+cNamSB1+" SB1"
	cQuery2 += "  JOIN "+cNamSB2+" SB2 ON ( SB2.B2_FILIAL= ? AND SB2.B2_COD=SB1.B1_COD "	; aAdd( aBind, { "C", cFilSB2 } )
	cQuery2 += "   AND SB2.B2_LOCAL IN ( ? ) AND SB2.D_E_L_E_T_=' ' ) " ; aAdd( aBind, { "A", aArmReserv } )
	cQuery2 += " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery2 += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery2 += "   AND SB1.D_E_L_E_T_=' '"
	cQuery2 += "   AND SB1.B1_CODITE="

	cQuery2 := OA030037C_ExecQuery( cQuery2, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30EBA
		cQuery2 := ExecBlock("POA30EBA",.f.,.f.,{ "2", cQuery2 , aGrpTotal })
	EndIf

	aBind := {}
	cQuery3 := "SELECT SUM( SB2.B2_QATU + SB2.B2_QNPT - SB2.B2_QTNP ) AS QTDTOTAL "
	cQuery3 += "  FROM "+cNamSB1+" SB1"
	cQuery3 += "  JOIN "+cNamSB2+" SB2 ON ( SB2.B2_FILIAL= ? AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL>='01' AND SB2.B2_LOCAL<='99' AND SB2.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", cFilSB2 } )
	cQuery3 += " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery3 += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery3 += "   AND SB1.D_E_L_E_T_=' '"
	cQuery3 += "   AND SB1.B1_CODITE="

	cQuery3 := OA030037C_ExecQuery( cQuery3, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30EBA
		cQuery3 := ExecBlock("POA30EBA",.f.,.f.,{ "3", cQuery3 , aGrpTotal })
	EndIf

	aBind := {}
	cQuery4 := "SELECT SUM(SC7.C7_QUANT-SC7.C7_QUJE) AS QTDSC7 "
	cQuery4 += "  FROM "+cNamSB1+" SB1"
	cQuery4 += "  JOIN "+cNamSC7+" SC7 ON ( SC7.C7_FILIAL= ? AND SC7.C7_PRODUTO=SB1.B1_COD AND SC7.C7_RESIDUO <> 'S' AND SC7.C7_QUANT <> SC7.C7_QUJE AND SC7.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", cFilSC7 } )
	cQuery4 += " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery4 += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery4 += "   AND SB1.D_E_L_E_T_=' '"
	cQuery4 += "   AND SB1.B1_CODITE="

	cQuery4 := OA030037C_ExecQuery( cQuery4, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )
	If lPOA30EBA
		cQuery4 := ExecBlock("POA30EBA",.f.,.f.,{ "4", cQuery4 , aGrpTotal })
	EndIf

	For nCntFor := nInIfor to Len(aIteBalance)

		If cFilAnt <> aIteBalance[nCntFor,1]
			Exit
		EndIf

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )

		nQtdAtu := 0
		cQuery  := cQuery1 + " ? "
		aBind := { { "C", aIteBalance[nCntFor,2] } }
		OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlSQL )->( Eof() )
			nQtdAtu := ( cQAlSQL )->( QTDTOTAL ) // Qtde Disponivel ( Qtde.Atual + Qtde.Nossa em Poder de Terceiros - Qtde.Terceiros em Nosso Poder )
		EndIf
		( cQAlSQL )->( DbCloseArea() )

		nQtdResBlq := 0
		cQuery  := cQuery2 + " ? "
		aBind := { { "C", aIteBalance[nCntFor,2] } }
		OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlSQL )->( Eof() )
			nQtdResBlq := ( cQAlSQL )->( B2_QATU ) // Qtde.Reservada/Bloqueada
		EndIf
		( cQAlSQL )->( DbCloseArea() )

		nQtdTot := 0
		cQuery  := cQuery3 + " ? "
		aBind := { { "C", aIteBalance[nCntFor,2] } }
		OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlSQL )->( Eof() )
			nQtdTot := ( cQAlSQL )->( QTDTOTAL ) // Qtde Total ( Qtde.Atual + Qtde.Nossa em Poder de Terceiros - Qtde.Terceiros em Nosso Poder )
		EndIf
		( cQAlSQL )->( DbCloseArea() )

		If lAgrTransi // Agrega Qtde Em Transito ?
			cQuery  := cQuery4 + " ? "
			aBind := { { "C", aIteBalance[nCntFor,2] } }
			OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
			If !( cQAlSQL )->( Eof() )
				nQtdTot += ( cQAlSQL )->( QTDSC7 ) // Qtde Em Transito (SC7), somar na Qtde Total
			EndIf
			( cQAlSQL )->( DbCloseArea() )
		EndIf

		cAux1 := StrTran( Alltrim(TransForm(nQtdAtu               ,"@E 9999999999")) , "," , "." ) // Qtde.Estoque Disponivel
		If lAgrResBlq // Agrega Qtde Reservada/Bloqueada
			cAux2 := StrTran( Alltrim(TransForm(nQtdTot           ,"@E 9999999999")) , "," , "." ) // Qtde.Estoque Total
		Else
			cAux2 := StrTran( Alltrim(TransForm(nQtdTot-nQtdResBlq,"@E 9999999999")) , "," , "." ) // Qtde.Estoque Total - Qtde.Reservada/Bloqueada
		EndIf

		cRetXML += '<v11:SetStockBalance availableStock="'+cAux1+'" '
		cRetXML +=                      'stockBalance="'+cAux2+'" '
		cRetXML +=                      'setStockBalanceTime="'+cDtHrNow+'">'+PulaLinha

		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" '
		cRetXML +=              'warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" '
		cRetXML +=             'partNumber="'+Alltrim(aIteBalance[nCntFor,2])+'"/>'+PulaLinha

		cRetXML += '</v11:SetStockBalance>'+PulaLinha

		cRetXML += OA0300051_Transaction( .F. , 0 )

		nCntID++
		nCntQtd++

	Next
	DbSelectArea("SB1")

Return cRetXML


/*/{Protheus.doc} OA0300281_CorrecaoItens
	Gera XML referente ao PartCorrection - TAG apos existir registros referente as Vendas

	@author Andre Luis Almeida
	@since 27/09/2018
/*/
Function OA0300281_CorrecaoItens( cWHouseID , nCntID , cXMLInic , dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef )
	Local cRetXML     := ""
	Local cQAlSQL     := "SQLSB2SC7"
	Local cQuery      := ""
	Local cQuery1     := ""
	Local cQuery2     := ""
	Local cQuery3     := ""
	Local cQuery4     := ""
	Local nCntFor     := 0
	Local nQtdAtu     := 0
	Local nQtdResBlq     := 0
	Local nQtdTot     := 0
	Local cDtaEnt     := ""
	Local cEnder      := ""
	Local cAux1       := ""
	Local cAux2       := ""
	Local cNamSB1     := RetSqlName("SB1")
	Local cNamSB2     := RetSqlName("SB2")
	Local cNamSB5     := RetSqlName("SB5")
	Local cNamSBZ     := RetSqlName("SBZ")
	Local cNamSC7     := RetSqlName("SC7")
	Local cFilSB1     := xFilial("SB1")
	Local cFilSB2     := xFilial("SB2")
	Local cFilSB5     := xFilial("SB5")
	Local cFilSBZ     := xFilial("SBZ")
	Local cFilSC7     := xFilial("SC7")
	Local aIteLev     := {} // Itens do Levantamento
	Local nInIfor     := 1
	Local aBind		  := {}
	Default cWHouseID := ""
	Default nCntID    := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic  := ""

	cRetXML := cXMLInic

	// Montar SELECT da TRIGGER da SB5 ( B5_LOCALI2 ) para incluir mais linhas no Vetor de aIteLev
	aBind := {}
	cQuery	:= "SELECT DISTINCT SB1.B1_CODITE "
	cQuery	+= "  FROM "+cNamSB5+"_TTAT_LOG TRIG"
	cQuery	+= "  JOIN "+cNamSB5+" SB5 ON ( SB5.R_E_C_N_O_=TRIG.TTAT_RECNO AND SB5.D_E_L_E_T_=' ' AND SB5.B5_FILIAL= ? ) "	; aAdd( aBind, { "C", cFilSB5 } ) // Necesario ser a Filial que fez a alteracao	; 
	cQuery  += "  JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL= ? AND SB1.B1_COD=SB5.B5_COD AND SB1.D_E_L_E_T_=' ' )"	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery	+= " WHERE TRIG.TTAT_FIELD = 'B5_LOCALI2'"
	cQuery	+= OA0300041_DTIME( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef )
	cQuery	+= "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.f.,.f.,{ "7" , cQuery , lPriceUpdates }) // 7 - PartCorrection ( Correcao de Itens )
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
	While !( cQAlSQL )->( Eof() )
		If aScan(aIteLev, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
			aAdd(aIteLev,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , dtos(dDtFinRef)+"T"+Substr(cHrFinRef,1,2)+Substr(cHrFinRef,4,2) })
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )

	aBind := {}
	cQuery1 := "SELECT SUM( SB2.B2_QATU + SB2.B2_QNPT - SB2.B2_QTNP ) AS QTDDISP ,"
	cQuery1 += "       MIN(SBZ.BZ_PRIENT)  AS MIN_PRIENT ,"
	cQuery1 += "       MAX(SBZ.BZ_PRIENT)  AS MAX_PRIENT ,"
	cQuery1 += "       MAX(SB5.B5_LOCALI2) AS B5_LOCALI2  "
	cQuery1 += "  FROM "+cNamSB1+" SB1"
	cQuery1 += "  JOIN "+cNamSB2+" SB2 ON ( SB2.B2_FILIAL= ? AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL=SB1.B1_LOCPAD AND SB2.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", cFilSB2 } )
	cQuery1 += "  JOIN "+cNamSB5+" SB5 ON ( SB5.B5_FILIAL= ? AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' ' )"	; aAdd( aBind, { "C", cFilSB5 } )
	cQuery1 += "  LEFT JOIN "+cNamSBZ+" SBZ ON ( SBZ.BZ_FILIAL= ? AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' ' )"	; aAdd( aBind, { "C", cFilSBZ } )
	cQuery1 += " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery1 += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery1 += "   AND SB1.D_E_L_E_T_=' '"
	cQuery1 += "   AND SB1.B1_CODITE="
	cQuery1 := OA030037C_ExecQuery( cQuery1, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )

	aBind := {}
	cQuery2 := "SELECT SUM(SB2.B2_QATU) AS B2_QATU "
	cQuery2 += "  FROM "+cNamSB1+" SB1"
	cQuery2 += "  JOIN "+cNamSB2+" SB2 ON ( SB2.B2_FILIAL= ? AND SB2.B2_COD=SB1.B1_COD "	; aAdd( aBind, { "C", cFilSB2 } )
	cQuery2 += "   AND SB2.B2_LOCAL IN ( ? ) AND SB2.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "A", aArmReserv } )
	cQuery2 += " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery2 += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery2 += "   AND SB1.D_E_L_E_T_=' '"
	cQuery2 += "   AND SB1.B1_CODITE="
	cQuery2 := OA030037C_ExecQuery( cQuery2, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )

	aBind := {}
	cQuery3 := "SELECT SUM( SB2.B2_QATU + SB2.B2_QNPT - SB2.B2_QTNP ) AS QTDTOTAL "
	cQuery3 += "  FROM "+cNamSB1+" SB1"
	cQuery3 += "  JOIN "+cNamSB2+" SB2 ON ( SB2.B2_FILIAL= ? AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL>='01' AND SB2.B2_LOCAL<='99' AND SB2.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", cFilSB2 } )
	cQuery3 += " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery3 += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery3 += "   AND SB1.D_E_L_E_T_=' '"
	cQuery3 += "   AND SB1.B1_CODITE="
	cQuery3 := OA030037C_ExecQuery( cQuery3, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )

	aBind := {}
	cQuery4 := "SELECT SUM(SC7.C7_QUANT-SC7.C7_QUJE) AS QTDSC7 "
	cQuery4 += "  FROM "+cNamSB1+" SB1"
	cQuery4 += "  JOIN "+cNamSC7+" SC7 ON ( SC7.C7_FILIAL= ? AND SC7.C7_PRODUTO=SB1.B1_COD AND SC7.C7_RESIDUO <> 'S' AND SC7.C7_QUANT <> SC7.C7_QUJE AND SC7.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", cFilSC7 } )
	cQuery4 += " WHERE SB1.B1_FILIAL= ? "	; aAdd( aBind, { "C", cFilSB1 } )
	cQuery4 += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery4 += "   AND SB1.D_E_L_E_T_=' '"
	cQuery4 += "   AND SB1.B1_CODITE="
	cQuery4 := OA030037C_ExecQuery( cQuery4, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )

	aSort(aIteLev,1,,{|x,y| x[1] < y[1] }) // Ordem: Filial
	nInIfor := aScan(aIteLev, {|x| x[1] == cFilAnt })
	If nInIfor == 0 // Se nao encontrar a Filial
		Return cRetXML
	EndIf

	For nCntFor := nInIfor to Len(aIteLev)

		If cFilAnt <> aIteLev[nCntFor,1]
			Exit
		EndIf

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )

		nQtdAtu := 0
		cDtaEnt := "19500101T0000"
		cEnder  := ""
		cQuery  := cQuery1 + " ? "
		aBind := { { "C", aIteLev[nCntFor,2] } }
		OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlSQL )->( Eof() )
			nQtdAtu := ( cQAlSQL )->( QTDDISP ) // Qtde Disponivel ( Qtde.Atual + Qtde.Nossa em Poder de Terceiros - Qtde.Terceiros em Nosso Poder )
			If !Empty( ( cQAlSQL )->( MIN_PRIENT ) )
				cDtaEnt := ( cQAlSQL )->( MIN_PRIENT )+'T0000'
			Else
				If !Empty( ( cQAlSQL )->( MAX_PRIENT ) )
					cDtaEnt := ( cQAlSQL )->( MAX_PRIENT )+'T0000'
				EndIf
			EndIf
			cEnder := Alltrim(( cQAlSQL )->( B5_LOCALI2 ))
		EndIf
		( cQAlSQL )->( DbCloseArea() )

		nQtdResBlq := 0
		cQuery  := cQuery2 + " ? "
		aBind := { { "C", aIteLev[nCntFor,2] } }
		OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlSQL )->( Eof() )
			nQtdResBlq := ( cQAlSQL )->( B2_QATU ) // Qtde.Reservada/Bloqueada
		EndIf
		( cQAlSQL )->( DbCloseArea() )

		nQtdTot := 0
		cQuery  := cQuery3 + " ? "
		aBind := { { "C", aIteLev[nCntFor,2] } }
		OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlSQL )->( Eof() )
			nQtdTot := ( cQAlSQL )->( QTDTOTAL ) // Qtde Total ( Qtde.Atual + Qtde.Nossa em Poder de Terceiros - Qtde.Terceiros em Nosso Poder )
		EndIf
		( cQAlSQL )->( DbCloseArea() )

		If lAgrTransi // Agrega Qtde Em Transito ?
			cQuery  := cQuery4 + " ? "
			aBind := { { "C", aIteLev[nCntFor,2] } }
			OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
			If !( cQAlSQL )->( Eof() )
				nQtdTot += ( cQAlSQL )->( QTDSC7 ) // Qtde Em Transito (SC7), somar na Qtde Total
			EndIf
			( cQAlSQL )->( DbCloseArea() )
		EndIf

		cAux1 := StrTran( Alltrim(TransForm(nQtdAtu               ,"@E 9999999999")) , "," , "." ) // Qtde.Estoque Disponivel
		If lAgrResBlq // Agrega Qtde Reservada/Bloqueada
			cAux2 := StrTran( Alltrim(TransForm(nQtdTot           ,"@E 9999999999")) , "," , "." ) // Qtde.Estoque Total
		Else
			cAux2 := StrTran( Alltrim(TransForm(nQtdTot-nQtdResBlq,"@E 9999999999")) , "," , "." ) // Qtde.Estoque Total - Qtde.Reservada/Bloqueada
		EndIf

		cRetXML += '<v11:PartCorrection>'+PulaLinha
		cRetXML += '<v11:PartInStock stockIntroductionTime="'+cDtaEnt+'" '
		cRetXML +=                  'binLocation="'+IIf(!Empty(cEnder),cEnder,'NOT BINNED')+'" '
		cRetXML +=                  'lastSoldTime="'+aIteLev[nCntFor,3]+'" '
		cRetXML +=                  'stockBalance="'+cAux2+'" '
		cRetXML +=                  'availableStock="'+cAux1+'">'+PulaLinha
		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'" />'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" '
		cRetXML +=              'warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" '
		cRetXML +=             'partNumber="'+Alltrim(aIteLev[nCntFor,2])+'" />'+PulaLinha
		cRetXML += '</v11:PartInStock>'+PulaLinha
		cRetXML += '</v11:PartCorrection>'+PulaLinha
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++
	Next
	DbSelectArea("SB1")
Return cRetXML

/*/{Protheus.doc} OA0300291_AjusteEstoque
	Gera XML referente aos Ajustes de Estoque (StockAdjustment) de um determinado Periodo

	@author Andre Luis Almeida
	@since 04/10/2018
/*/
Function OA0300291_AjusteEstoque( cArquivo , cNroSqIni , cNroSqFin , dDtIniRef , dDtFinRef , cWHouseID , nCntID , cXMLInic )
	Local cRetXML      := ""
	Local cQAlSQL      := "SQL"+cArquivo
	Local cQuery       := ""
	Local nMult        := IIf( cArquivo == "SD1" , 1 , -1 )
	Local aBind
	Default cNroSqIni  := ""
	Default cNroSqFin  := ""
	Default dDtIniRef  := Date()
	Default dDtFinRef  := Date()
	Default cWHouseID  := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""

	cRetXML := cXMLInic
	aBind   := {}
	If cArquivo == "SD1"
		cQuery := "SELECT SD1.D1_EMISSAO AS EMISSAO ,"
		cQuery += "       SF1.F1_HORA    AS HORA    ,"
		cQuery += "       SD1.D1_QUANT   AS QUANT   ,"
		cQuery += "       SB1.B1_CODITE             ,"
		cQuery += "       SF4.F4_OPEMOV             ,"
		cQuery += "       ' ' AS CODSIT              "
		cQuery += "  FROM "+RetSqlName("SD1")+" SD1"
		cQuery += "  JOIN "+RetSqlName("SF1")+" SF1 ON ( SF1.F1_FILIAL=SD1.D1_FILIAL AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.F1_FORNECE=SD1.D1_FORNECE AND SF1.F1_LOJA=SD1.D1_LOJA AND SF1.D_E_L_E_T_=' ' ) "
		cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.F4_OPEMOV IN ('03','09','11','12','15') AND SF4.D_E_L_E_T_=' ' ) " ;	aAdd( aBind, { "C", xFilial("SF4") } )// OPEMOV ( Transferencias / Interno / Ajuste Inventario )
		cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL= ? AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "	;	aAdd( aBind, { "C", xFilial("SB1") } )
		cQuery += " WHERE SD1.D1_FILIAL= ? "	;	aAdd( aBind, { "C", xFilial("SD1") } )
		If !Empty(cNroSqIni)
			cQuery += "   AND SD1.D1_NUMSEQ >  ? "	;		aAdd( aBind, { "C", cNroSqIni } )
			cQuery += "   AND SD1.D1_NUMSEQ <= ? "	;		aAdd( aBind, { "C", cNroSqFin } )
		Else
			cQuery += "   AND SD1.D1_DTDIGIT >= ? "	;		aAdd( aBind, { "C", dtos(dDtIniRef) } )
			cQuery += "   AND SD1.D1_DTDIGIT <= ? "	;		aAdd( aBind, { "C", dtos(dDtFinRef) } )
		EndIf
		cQuery += "   AND SD1.D_E_L_E_T_=' '"
		cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	;	aAdd( aBind, { "A", aGrpTotal } )
		cQuery += " ORDER BY SD1.D1_EMISSAO , SB1.B1_CODITE "
	ElseIf cArquivo == "SD2"
		cQuery := "SELECT SF2.F2_EMISSAO AS EMISSAO ,"
		cQuery += "       SF2.F2_HORA    AS HORA    ,"
		cQuery += "       SD2.D2_QUANT   AS QUANT   ,"
		cQuery += "       SB1.B1_CODITE             ,"
		cQuery += "       SF4.F4_OPEMOV             ,"
		cQuery += "       VS3.VS3_CODSIT AS CODSIT   "
		cQuery += "  FROM "+RetSqlName("SD2")+" SD2"
		cQuery += "  JOIN "+RetSqlName("SF2")+" SF2 ON ( SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.D_E_L_E_T_=' ' ) "
		cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV IN ('03','09','11','12','15') AND SF4.D_E_L_E_T_=' ' ) " ;	aAdd( aBind, { "C", xFilial("SF4") } )// OPEMOV ( Transferencias / Interno / Ajuste Inventario )
		cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL= ? AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "	;	aAdd( aBind, { "C", xFilial("SB1") } )
		cQuery += "  LEFT JOIN "+RetSqlName("VS1")+" VS1 ON ( VS1.VS1_FILIAL= ? AND VS1.VS1_NUMNFI=SD2.D2_DOC AND VS1.VS1_SERNFI=SD2.D2_SERIE AND VS1.D_E_L_E_T_=' ' ) "	;	aAdd( aBind, { "C", xFilial("VS1") } )
		cQuery += "  LEFT JOIN "+RetSqlName("VS3")+" VS3 ON ( VS3.VS3_FILIAL= ? AND VS3.VS3_NUMORC=VS1.VS1_NUMORC AND VS3.VS3_GRUITE=SB1.B1_GRUPO AND VS3.VS3_CODITE=SB1.B1_CODITE AND VS3.D_E_L_E_T_=' ' ) "	;	aAdd( aBind, { "C", xFilial("VS3") } )
		cQuery += " WHERE SD2.D2_FILIAL= ? "	;	aAdd( aBind, { "C", xFilial("SD2") } )
		If !Empty(cNroSqIni)
			cQuery += "   AND SD2.D2_NUMSEQ >  ? "	;		aAdd( aBind, { "C", cNroSqIni } )
			cQuery += "   AND SD2.D2_NUMSEQ <= ? "	;		aAdd( aBind, { "C", cNroSqFin } )
		Else
			cQuery += "   AND SF2.F2_EMISSAO >= ? "	;		aAdd( aBind, { "C", dtos(dDtIniRef) } )
			cQuery += "   AND SF2.F2_EMISSAO <= ? "	;		aAdd( aBind, { "C", dtos(dDtFinRef) } )
		EndIf
		cQuery += "   AND SD2.D_E_L_E_T_=' '"
		cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	;	aAdd( aBind, { "A", aGrpTotal } )
		cQuery += " ORDER BY SF2.F2_EMISSAO , SB1.B1_CODITE "
	EndIf

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.f.,.f.,{ "8" , cQuery , lPriceUpdates }) // 8 - StockAdjustment ( Ajuste de Estoque )
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
	While !( cQAlSQL )->( Eof() )
		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		If !Empty( ( cQAlSQL )->( EMISSAO ) )
			cAux1 := ( cQAlSQL )->( EMISSAO )+"T"
			cAux1 += Left(( cQAlSQL )->( HORA ),2)
			cAux1 += right(Left(( cQAlSQL )->( HORA ),5),2)
		Else
			cAux1 := "19500101T0000"
		EndIf
		cAux2 := Alltrim(TransForm(( cQAlSQL )->( QUANT )*nMult,"@E 9999999999"))

		cRetXML += OA0300051_Transaction( .T. , nCntID )

		cRetXML += '<v11:StockAdjustment stockAdjustmentTime="'+cAux1+'" reasonForAdjustment='
		Do Case
		Case ( cQAlSQL )->( F4_OPEMOV ) == "03"
			cRetXML += '"Relocation"'
		Case ( cQAlSQL )->( F4_OPEMOV ) $ "11/12"
			cRetXML += '"StockTaking"'
		Case ( cQAlSQL )->( F4_OPEMOV ) == "15"
			If ( cQAlSQL )->( CODSIT ) == "03" // Scrape
				cRetXML += '"Scrapping"'
			ElseIf ( cQAlSQL )->( CODSIT ) == "06" // Recompra
				cRetXML += '"ReturnedToSupplier"'
			Else
				cRetXML += '"StockTaking"'
			EndIf
		Case  ( cQAlSQL )->( F4_OPEMOV ) == "09"
			cRetXML += '"ReturnedToSupplier"'// Devolução de compra
		EndCase
		cRetXML += ' quantity="'+cAux2+'">'+PulaLinha
		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim(( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
		cRetXML += '</v11:StockAdjustment>'+PulaLinha
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++

		// Vetores utilizados no Balance de Estoque
		If aScan(aIteBalance, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
			aAdd(aIteBalance,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , cAux1 })
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea(cArquivo)

Return cRetXML

/*/{Protheus.doc} OA0300301_Requisicoes
	Gera XML referente as Requisicoes (PartOrder) de um determinado Periodo

	@author Andre Luis Almeida
	@since 05/08/2019
/*/
Function OA0300301_Requisicoes( cNroSqIni , cNroSqFin , dDtIniRef , dDtFinRef , cWHouseID , nCntID , cXMLInic )
	Local cRetXML      := ""
	Local cAux1        := ""
	Local cAux2        := ""
	Local cAux3        := ""
	Local cAux4        := ""
	Local cQAlSQL      := "SQLSD3"
	Local cQAlAux      := "SQLAUX"
	Local cForeCast    := ""
	Local cQuery       := ""
	Local nQtdFalta    := 0
	Local cNamVS1      := RetSqlName("VS1")
	Local cNamVS3      := RetSqlName("VS3")
	Local cFilVS1      := xFilial("VS1")
	Local cFilVS3      := xFilial("VS3")
	Local cFilVO3      := xFilial("VO3")
	Local lPOA30SOF    := ExistBlock("POA30SOF") // Sequencia Oficina - Customizado
	Local cSequen      := ""
	Local cFilV09      := xFilial("V09")
	Local cNamV09      := RetSqlName("V09")
	Local aBind		   := {}
	Local cQuebra      := ""
	Default cNroSqIni  := ""
	Default cNroSqFin  := ""
	Default dDtIniRef  := Date()
	Default dDtFinRef  := Date()
	Default cWHouseID  := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""

	cRetXML := cXMLInic
	aBind := {}
	cQuery += "SELECT VO2.VO2_NUMOSV ,"
	cQuery += "       SB1.B1_GRUPO   ,"
	cQuery += "       SB1.B1_CODITE  ,"
	cQuery += "       SB1.B1_COD     ,"
	cQuery += "       VO3.VO3_SEQINC   ,"
	//cQuery += "       VO3.VO3_TIPTEM ,"
	cQuery += "       VO3.VO3_FATPAR ,"
	cQuery += "       VO3.VO3_LOJA   ,"
	cQuery += "       SA1.A1_NOME    ,"
	cQuery += "       MAX(VO2.R_E_C_N_O_) AS RECVO2 "
	cQuery += "  FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL= ? AND SB1.B1_COD=SD3.D3_COD AND SB1.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", xFilial("SB1") } )
	cQuery += "  JOIN "+RetSqlName("VO3")+" VO3 ON VO3.VO3_FILIAL= ? AND VO3.VO3_GRUITE=SB1.B1_GRUPO AND VO3.VO3_CODITE=SB1.B1_CODITE AND VO3.VO3_NUMDOC=SD3.D3_DOC AND VO3.VO3_DATCAN=' ' AND VO3.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", xFilial("VO3") } )
	cQuery += "  JOIN "+RetSqlName("VO2")+" VO2 ON VO2.VO2_FILIAL=VO3.VO3_FILIAL AND VO2.VO2_NOSNUM=VO3.VO3_NOSNUM AND VO2.D_E_L_E_T_=' '"
	cQuery += "  JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL= ? AND SA1.A1_COD=VO3.VO3_FATPAR AND SA1.A1_LOJA=VO3.VO3_LOJA AND SA1.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", xFilial("SA1") } )
	cQuery += " WHERE SD3.D3_FILIAL= ? "	; aAdd( aBind, { "C", xFilial("SD3") } )
	If !Empty(cNroSqIni)
		cQuery += "   AND SD3.D3_NUMSEQ >  ? "	; aAdd( aBind, { "C", cNroSqIni } )
		cQuery += "   AND SD3.D3_NUMSEQ <= ? "	; aAdd( aBind, { "C", cNroSqFin } )
	Else
		cQuery += "   AND VO2.VO2_DATREQ >= ? "	; aAdd( aBind, { "C", dtos(dDtIniRef) } )
		cQuery += "   AND VO2.VO2_DATREQ <= ? "	; aAdd( aBind, { "C", dtos(dDtFinRef) } )
	EndIf
	cQuery += "   AND SD3.D3_TM <= '500'"
	cQuery += "   AND SD3.D3_ESTORNO <> 'S'"
	cQuery += "   AND SD3.D_E_L_E_T_=' '"
	cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery += " GROUP BY VO2.VO2_NUMOSV , "
	cQuery += "          SB1.B1_GRUPO   , "
	cQuery += "          SB1.B1_CODITE  , "
	cQuery += "          SB1.B1_COD     , "
	cQuery += "          VO3.VO3_SEQINC , "
	//cQuery += "          VO3.VO3_TIPTEM , "
	cQuery += "          VO3.VO3_FATPAR , "
	cQuery += "          VO3.VO3_LOJA   , "
	cQuery += "          SA1.A1_NOME      "

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.F.,.F.,{ "9" , cQuery , lPriceUpdates }) // 9 - PartOrder ( Requisicoes )
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
	While !( cQAlSQL )->( Eof() )
		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		cSequen := ""
		If lPOA30SOF
			cSequen := ExecBlock("POA30SOF",.F.,.F.,{ cFilVO3 , ( cQAlSQL )->( VO2_NUMOSV ) , ( cQAlSQL )->( B1_COD ) })
		Else
			If FWAliasInDic("VRW")
				cSequen := OA030039F_ObtemSeqItemRequisicaoAux(cFilVO3,( cQAlSQL )->VO2_NUMOSV, ( cQAlSQL )->B1_GRUPO,( cQAlSQL )->B1_CODITE,( cQAlSQL )->VO3_SEQINC)
			Else
				If cQuebra <> ( cQAlSQL )->( VO2_NUMOSV )
					cQuebra := ( cQAlSQL )->( VO2_NUMOSV )
					nSequen := 0
				EndIf
				nSequen++
				cSequen := strzero(nSequen,4)
			EndIf
		EndIf

		// Chamar FMX_CALPEC da OS + Item
		aAuxPeca := FMX_CALPEC( ( cQAlSQL )->( VO2_NUMOSV ) , , ( cQAlSQL )->( B1_GRUPO ) , ( cQAlSQL )->( B1_CODITE ) , .F. , .F. , .F. , .T. , .T. , .T. , .F. )
		nQtd := 0
		aEval( aAuxPeca , { |x| nQtd += x[PECA_QTDREQ] } ) // Somar Qtde da Peca
		//Pegar a maxima Data / Hora do VO2
		If ( cQAlSQL )->( RECVO2 ) > 0
			VO2->( DbGoTo(( cQAlSQL )->( RECVO2 )) )
			cAux1 := dtos(VO2->VO2_DATREQ)+"T"+strzero(VO2->VO2_HORREQ,4)
		Else
			cAux1 := "19500101T0000"
		EndIf

		cForeCast := "True"
		nQtdFalta := 0
		aBind := {}
		cQuery := "SELECT VS3.VS3_CODSIT, V09.V09_LEVDEM "
		cQuery += "  FROM "+cNamVS3+" VS3"
		cQuery += "  JOIN "+cNamVS1+" VS1 ON VS1.VS1_FILIAL= ? AND VS1.VS1_NUMORC=VS3.VS3_NUMORC " ; aAdd( aBind, { "C", cFilVS1 } )
		cQuery += "   AND VS1.VS1_NUMOSV= ? AND VS1.D_E_L_E_T_=' '" ; aAdd( aBind, { "C", ( cQAlSQL )->VO2_NUMOSV } )
		cQuery += "  JOIN "+cNamV09+" V09 ON V09.V09_FILIAL= ? AND V09.V09_CODSIT = VS3.VS3_CODSIT AND V09.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilV09 } )
		cQuery += " WHERE VS3.VS3_FILIAL= ?"	; aAdd( aBind, { "C", cFilVS3 } )
		cQuery += "   AND VS3.VS3_GRUITE IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
		cQuery += "   AND VS3.VS3_CODITE= ? "	; aAdd( aBind, { "C", (cQAlSQL)->B1_CODITE } )
		cQuery += "   AND VS3.D_E_L_E_T_=' '"
		OA030037C_ExecQuery( cQuery, aBind, cQAlAux /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlAux )->( Eof() )
			If ( cQAlAux )->( V09_LEVDEM ) == "0"
				cForeCast := "False"
			EndIf
		EndIf
		( cQAlAux )->( DbCloseArea() )

		cAux2 := Alltrim(TransForm(nQtdFalta,"@E 9999999999")) // Qtde.Faltante
		cAux3 := Alltrim(TransForm(nQtd,"@E 9999999999")) // Qtde.Vendida (Possivel)
		cAux4 := Alltrim(TransForm(nQtd+nQtdFalta,"@E 9999999999")) // Qtde.Necessaria (Qtde.Vendida+Qtde.Faltante)

		cRetXML += OA0300051_Transaction( .T. , nCntID )

		cRetXML += '<v11:PartOrder '
		cRetXML +=                'pointOfSale="WS" '
		cRetXML +=                'ForecastBase="'+cForeCast+'" '
		cRetXML +=                'customerType="Normal" '
		cRetXML +=                'backOrderQuantity="'+cAux2+'" '                  // backOrderQuantity =  9 – QUANTIDADE FALTANTE
		cRetXML +=                'bookedQuantity="'+cAux3+'" '                     // bookedQuantity    = 11 – QUANTIDADE POSSIVEL
		cRetXML +=                'orderTimestamp="'+cAux1+'" '
		cRetXML +=                'orderedQuantity="'+cAux4+'" '                    // orderedQuantity   = 20 – QUANTIDADE NECESSARIA
		cRetXML +=                'customerName="'+OA0300431_TrocaTexto( Alltrim(Left(( cQAlSQL )->( A1_NOME ),15)) )+'" '
		cRetXML +=                'customerNumber="'+Alltrim(( cQAlSQL )->( VO3_FATPAR )+( cQAlSQL )->( VO3_LOJA ))+'" '
		cRetXML +=                'orderType="Normal">'+PulaLinha
		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:OrderId orderLineNumber="'+cSequen+'" '
		cRetXML +=              'orderNumber="'+Alltrim(( cQAlSQL )->( VO2_NUMOSV ))+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim(( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
		cRetXML += '</v11:PartOrder>'+PulaLinha
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++

		// Vetores utilizados no Balance de Estoque
		If aScan(aIteBalance, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
			aAdd(aIteBalance,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , cAux1 })
		EndIf

		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SD3")
Return cRetXML

/*/{Protheus.doc} OA0300311_WebService
// "https://seipbext.scania.com/SCIS142/dsm/datacollectionservice/v1?wsdl" // Aceite
// "https://seipaext.scania.com/SCIS142/dsm/datacollectionservice/v1?wsdl" // Producao
Conecta com o WEBSERVICE e envia os Dados
@author Andre Luis Almeida
@since 25/07/2019
@param cTXTEnvio, caracter, Texto a ser enviado
@type Function
/*/
Static Function OA0300311_WebService( cTXTEnvio )

	Local oWsdl    := Nil
	Local cRetSend := ""
	Local cHelp	   := ""

	If !Empty(cTXTEnvio) .and. lEnviaWS

		oWsdl := TWsdlManager():New()
		oWsdl:lSSLInsecure := .T.
		oWsdl:lVerbose := .T.
		
		If !oWsdl:ParseURL(cUrlXML)
			cHelp := "OFIA030 - Erro ParseURL: " + oWsdl:cError
			OA030040K_RegistraLOG( {"OA030008", cHelp, STR0027, /*lShowHelp:=*/ .T.}, cCodLogVQL, /*lClose := .F.*/)
			Return .F.
		EndIf
		
		If !oWsdl:SetOperation( "Update" )
			cHelp := "OFIA030 - SetOperation: " + oWsdl:cError
			OA030040K_RegistraLOG( {"OA030009", cHelp, STR0028, /*lShowHelp:=*/ .T.}, cCodLogVQL, /*lClose := .F.*/)
			Return .F.
		EndIf
	
		oWsdl:SendSoapMsg( cTXTEnvio )
		cRetSend := oWsdl:GetSoapResponse()

		If !(">OK</Status>" $ cRetSend) // Verifica se deu erro
			cHelp := "OFIA030 - GetSoapResponse:" + cRetSend + PulaLinha + PulaLinha
			cHelp += "OFIA030 - SendSoapMsg: " + oWsdl:cError + PulaLinha
			cHelp += "OFIA030 - SendSoapMsg FaultCode: " + oWsdl:cFaultCode + PulaLinha

			//Compatilizar com execução do SmartClient na Web
			cHelp := StrTran(cHelp, "<", "")
			cHelp := StrTran(cHelp, ">", "")

			OA030040K_RegistraLOG( {"OA030010", cHelp, STR0029, /*lShowHelp:=*/ .T.}, cCodLogVQL, /*lClose := .F.*/)
			Return .F.
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} OA0300321_Orcamentos_Faturados
	Gera XML referente aos Orcamentos Faturados (somente BALCAO) para enviar o PartOrder de um determinado Periodo

	@author Andre Luis Almeida
	@since 07/10/2019
/*/
Function OA0300321_Orcamentos_Faturados( cNroSqIni , cNroSqFin , dDtIniRef , dDtFinRef , cWHouseID , nCntID , cXMLInic )
	Local cRetXML      := ""
	Local cAux1        := ""
	Local cAux2        := ""
	Local cQAlSQL      := "SQLSD2"
	Local cQAlAux      := "SQLAUX"
	Local cQuery       := ""
	Local nQtdFalta    := 0
	Local cForeCast    := ""
	Local cNamVS3      := RetSqlName("VS3")
	Local cPrefBal     := GetNewPar("MV_PREFBAL","BAL")
	Local cFilV09      := xFilial("V09")
	Local cNamV09      := RetSqlName("V09")
	Local aBind		   := {}
	Default cNroSqIni  := ""
	Default cNroSqFin  := ""
	Default dDtIniRef  := Date()
	Default dDtFinRef  := Date()
	Default cWHouseID  := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""

	aBind := {}
	cRetXML := cXMLInic
	cQuery := "SELECT SF2.F2_EMISSAO ,"
	cQuery += "       SB1.B1_CODITE  ,"
	cQuery += "       SD2.D2_QUANT   ,"
	cQuery += "       SD2.D2_ITEM    ,"
	cQuery += "       SD2.D2_DOC     ,"
	cQuery += "       SD2.D2_SERIE   ,"
	cQuery += "       SF2.F2_HORA    ,"
	cQuery += "       SF2.F2_CLIENTE ,"
	cQuery += "       SF2.F2_LOJA    ,"
	cQuery += "       SA1.A1_NOME    ,"
	cQuery += "       VS1.VS1_FILIAL ,"
	cQuery += "       VS1.VS1_NUMORC  "
	cQuery += "  FROM "+RetSqlName("SD2")+" SD2"
	cQuery += "  JOIN "+RetSqlName("SF2")+" SF2 ON ( SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_PREFORI= ? AND SF2.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", cPrefBal } )
	cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " 	; aAdd( aBind, { "C", xFilial("SF4") } ) // OPEMOV = 05 ( VENDA )
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL= ? AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", xFilial("SB1") } )
	cQuery += "  JOIN "+RetSqlName("VS1")+" VS1 ON ( VS1.VS1_FILIAL= ? AND VS1.VS1_NUMNFI=SD2.D2_DOC AND VS1.VS1_SERNFI=SD2.D2_SERIE AND VS1.D_E_L_E_T_=' ' )"	; aAdd( aBind, { "C", xFilial("VS1") } )
	cQuery += "  JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL= ? AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_=' ' )"	; aAdd( aBind, { "C", xFilial("SA1") } )
	cQuery += " WHERE SD2.D2_FILIAL= ? "	; aAdd( aBind, { "C", xFilial("SD2") } )
	If !Empty(cNroSqIni)
		cQuery += "   AND SD2.D2_NUMSEQ >  ? "	; aAdd( aBind, { "C", cNroSqIni } )
		cQuery += "   AND SD2.D2_NUMSEQ <= ? "	; aAdd( aBind, { "C", cNroSqFin } )
	Else
		cQuery += "   AND SF2.F2_EMISSAO >= ? "	; aAdd( aBind, { "C", dtos(dDtIniRef) } )
		cQuery += "   AND SF2.F2_EMISSAO <= ? "	; aAdd( aBind, { "C", dtos(dDtFinRef) } )
	EndIf
	cQuery += "   AND SD2.D_E_L_E_T_=' '"
	cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
	cQuery += " ORDER BY SF2.F2_EMISSAO , SD2.D2_DOC , SD2.D2_ITEM"
	
	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.f.,.f.,{ "10" , cQuery , lPriceUpdates }) // 10 - PartOrder ( Orcamentos Faturados )
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
	While !( cQAlSQL )->( Eof() )

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		If !Empty( ( cQAlSQL )->( F2_EMISSAO ) )
			cAux1 := ( cQAlSQL )->( F2_EMISSAO )+"T"
			cAux1 += Left(( cQAlSQL )->( F2_HORA ),2)
			cAux1 += right(Left(( cQAlSQL )->( F2_HORA ),5),2)
		Else
			cAux1 := "19500101T0000"
		EndIf

		cForeCast := "True"
		nQtdFalta := 0
		aBind := {}
		cQuery := "SELECT VS3.VS3_CODSIT, V09.V09_LEVDEM "
		cQuery += "  FROM "+cNamVS3+" VS3"
		cQuery += "  JOIN "+cNamV09+" V09 ON V09.V09_FILIAL= ? AND V09.V09_CODSIT = VS3.VS3_CODSIT AND V09.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilV09 } )
		cQuery += " WHERE VS3.VS3_FILIAL= ? "	; aAdd( aBind, { "C", ( cQAlSQL )->VS1_FILIAL } )
		cQuery += "   AND VS3.VS3_NUMORC= ? "	; aAdd( aBind, { "C", ( cQAlSQL )->VS1_NUMORC } )
		cQuery += "   AND VS3.VS3_GRUITE IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
		cQuery += "   AND VS3.VS3_CODITE= ? "	; aAdd( aBind, { "C", ( cQAlSQL )->B1_CODITE } )
		cQuery += "   AND VS3.D_E_L_E_T_=' '"
		OA030037C_ExecQuery( cQuery, aBind, cQAlAux /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlAux )->( Eof() )
			If ( cQAlAux )->( V09_LEVDEM ) == "0"
				cForeCast := "False"
			EndIf
		EndIf
		( cQAlAux )->( DbCloseArea() )

		cAux2 := Alltrim(TransForm(nQtdFalta,"@E 9999999999")) // Qtde.Faltante
		cAux3 := Alltrim(TransForm(( cQAlSQL )->( D2_QUANT ),"@E 9999999999")) // Qtde.Vendida (Possivel)
		cAux4 := Alltrim(TransForm(( cQAlSQL )->( D2_QUANT )+nQtdFalta,"@E 9999999999")) // Qtde.Necessaria (Qtde.Vendida+Qtde.Faltante)

		cRetXML += OA0300051_Transaction( .T. , nCntID )
		cRetXML += '<v11:PartOrder '
		cRetXML +=                'pointOfSale="OTC" '
		cRetXML +=                'ForecastBase="'+cForeCast+'" '
		cRetXML +=                'customerType="Normal" '
		cRetXML +=                'backOrderQuantity="'+cAux2+'" '                  // backOrderQuantity =  9 – QUANTIDADE FALTANTE
		cRetXML +=                'bookedQuantity="'+cAux3+'" '                     // bookedQuantity    = 11 – QUANTIDADE POSSIVEL
		cRetXML +=                'orderTimestamp="'+cAux1+'" '
		cRetXML +=                'orderedQuantity="'+cAux4+'" '                    // orderedQuantity   = 20 – QUANTIDADE NECESSARIA
		cRetXML +=                'customerName="'+OA0300431_TrocaTexto( Alltrim(Left(( cQAlSQL )->( A1_NOME ),15)) )+'" '
		cRetXML +=                'customerNumber="'+Alltrim(( cQAlSQL )->( F2_CLIENTE )+( cQAlSQL )->( F2_LOJA ))+'" '
		cRetXML +=                'orderType="Normal">'+PulaLinha
		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:OrderId orderLineNumber="'+strzero(val(( cQAlSQL )->( D2_ITEM )),4)+'" '
		cRetXML +=              'orderNumber="'+Alltrim(( cQAlSQL )->( VS1_NUMORC ))+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim(( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
		cRetXML += '</v11:PartOrder>'+PulaLinha
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SD2")

Return cRetXML

/*/{Protheus.doc} OA0300331_Cancelamentos
	Gera XML referente aos Cancelamentos de Vendas (PartDelivery) de um determinado Periodo

	@author Andre Luis Almeida
	@since 20/10/2019
/*/
Function OA0300331_Cancelamentos( cNroSqIni , cNroSqFin , dDtIniRef , dDtFinRef , cWHouseID , nCntID , cXMLInic )
	Local cRetXML      := ""
	Local cAux1        := ""
	Local cQAlSQL      := "SQLSD2SFT"
	Local cQAlAux      := "SQLAUX"
	Local cQuery       := ""
	Local cOrdNumber   := ""
	Local cSequen      := ""
	Local lPOA30SOF    := ExistBlock("POA30SOF") // Sequencia Oficina - Customizado
	Local cPrefBal     := GetNewPar("MV_PREFBAL","BAL")
	Local cPrefOfi     := GetNewPar("MV_PREFOFI","OFI")
	Local cFilVO3      := xFilial("VO3")
	Local cFilVS3      := xFilial("VS3")
	Local cFilVS1      := xFilial("VS1")
	Local cNamVS1      := RetSqlName("VS1")
	Local cNamVS3      := RetSqlName("VS3")
	Local cFilV09      := xFilial("V09")
	Local cNamV09      := RetSqlName("V09")
	Local aBind		   := {}
	Default cNroSqIni  := ""
	Default cNroSqFin  := ""
	Default dDtIniRef  := Date()
	Default dDtFinRef  := Date()
	Default cWHouseID  := ""
	Default nCntID     := 1 // Nro.Inicial do ID de Transacao
	Default cXMLInic   := ""

	cRetXML := cXMLInic
	aBind := {}

	If !Empty(cNroSqIni) // Pegar a Data de Emissao ( mesmo os registros de SD2 DELETADOS )
		cQuery := "SELECT MIN(SF2.F2_EMISSAO) AS EMISMIN ,"
		cQuery += "       MAX(SF2.F2_EMISSAO) AS EMISMAX  "
		cQuery += "  FROM "+RetSqlName("SD2")+" SD2"
		cQuery += "  JOIN "+RetSqlName("SF2")+" SF2 ON ( SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_PREFORI IN ( ? ) ) "	; aadd(aBind, {"A", {cPrefBal, cPrefOfi}})
		cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " 	; aAdd( aBind, { "C", xFilial("SF4") } ) // OPEMOV = 05 ( VENDA )
		cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL= ? AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", xFilial("SB1") } )
		cQuery += " WHERE SD2.D2_FILIAL= ? "	; aAdd( aBind, { "C", xFilial("SD2") } )
		cQuery += "   AND SD2.D2_NUMSEQ >  ? "	; aAdd( aBind, { "C", cNroSqIni } )
		cQuery += "   AND SD2.D2_NUMSEQ <= ? "	; aAdd( aBind, { "C", cNroSqFin } )
		cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
		OA030037C_ExecQuery( cQuery, aBind, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
		If !( cQAlSQL )->( Eof() )
			dDtIniRef := stod( ( cQAlSQL )->( EMISMIN ) )
			dDtFinRef := stod( ( cQAlSQL )->( EMISMAX ) )
		EndIf
		( cQAlSQL )->( DbCloseArea() )
	EndIf

	aBind := {}
	cQuery := "SELECT SF3.F3_DTCANC  ,"
	cQuery += "       SF2.F2_EMISSAO ,"
	cQuery += "       SF2.F2_HORA    ,"
	cQuery += "       SD2.D2_DOC     ,"
	cQuery += "       SD2.D2_SERIE   ,"
	cQuery += "       SD2.D2_ITEM    ,"
	cQuery += "       SD2.D2_QUANT   ,"
	cQuery += "       SB1.B1_CODITE  ,"
	cQuery += "       SB1.B1_COD     ,"
	cQuery += "       SF2.F2_PREFORI ,"
	cQuery += "       SF2.F2_CLIENTE ,"
	cQuery += "       SF2.F2_LOJA    ,"
	cQuery += "       SA1.A1_NOME    ,"
	cQuery += "       VEC.VEC_NUMORC ,"
	cQuery += "       VEC.VEC_NUMOSV  "
	cQuery += "  FROM "+RetSqlName("SFT")+" SFT"
	cQuery += "  JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL=SFT.FT_FILIAL AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D_E_L_E_T_<>' ' ) "
	cQuery += "  JOIN "+RetSqlName("SF2")+" SF2 ON ( SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_DOC=SD2.D2_DOC AND SF2.F2_SERIE=SD2.D2_SERIE AND SF2.F2_PREFORI IN ( ? ) AND SF2.D_E_L_E_T_<>' ' ) "	; aAdd( aBind, { "A", {cPrefBal,cPrefOfi} })
	cQuery += "  JOIN "+RetSqlName("SF3")+" SF3 ON ( SF3.F3_FILIAL=SF2.F2_FILIAL AND SF3.F3_NFISCAL=SF2.F2_DOC AND SF3.F3_SERIE=SF2.F2_SERIE AND SF3.F3_CLIEFOR=SF2.F2_CLIENTE AND SF3.F3_LOJA=SF2.F2_LOJA AND SF3.F3_ENTRADA=SF2.F2_EMISSAO AND SF3.F3_CFO>'4999' AND SF3.D_E_L_E_T_=' ' ) "
	cQuery += "  JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL= ? AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", xFilial("SA1") })
	cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON ( SF4.F4_FILIAL= ? AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' ) " ; aAdd( aBind, { "C", xFilial("SF4") })// OPEMOV = 05 ( VENDA )	
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL= ? AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "	; aAdd( aBind, { "C", +xFilial("SB1") })
	cQuery += "  JOIN "+RetSqlName("VEC")+" VEC ON ( VEC.VEC_FILIAL= ? AND VEC.VEC_NUMNFI=SD2.D2_DOC AND VEC.VEC_SERNFI=SD2.D2_SERIE AND VEC.VEC_PECINT=SB1.B1_COD ) "	; aAdd( aBind, { "C", xFilial("VEC") })
	cQuery += " WHERE SFT.FT_FILIAL= ? "	; aAdd( aBind, { "C", xFilial("SFT") })
	cQuery += "   AND SFT.FT_TIPOMOV='S'"
	cQuery += "   AND SF3.F3_DTCANC >= ? "	; aAdd( aBind, { "D", dDtIniRef })
	cQuery += "   AND SF3.F3_DTCANC <= ? "	; aAdd( aBind, { "D", dDtFinRef })
	cQuery += "   AND SFT.FT_DTCANC <> ' '"
	cQuery += "   AND SFT.D_E_L_E_T_=' '"
	cQuery += "   AND SB1.B1_GRUPO IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal })
	cQuery += " GROUP BY SF3.F3_DTCANC  ,"
	cQuery += "          SF2.F2_EMISSAO ,"
	cQuery += "          SF2.F2_HORA    ,"
	cQuery += "          SD2.D2_DOC     ,"
	cQuery += "          SD2.D2_SERIE   ,"
	cQuery += "          SD2.D2_ITEM    ,"
	cQuery += "          SD2.D2_QUANT   ,"
	cQuery += "          SB1.B1_CODITE  ,"
	cQuery += "          SB1.B1_COD     ,"
	cQuery += "          SF2.F2_PREFORI ,"
	cQuery += "          SF2.F2_CLIENTE ,"
	cQuery += "          SF2.F2_LOJA    ,"
	cQuery += "          SA1.A1_NOME    ,"
	cQuery += "          VEC.VEC_NUMORC ,"
	cQuery += "          VEC.VEC_NUMOSV  "
	cQuery += " ORDER BY SF2.F2_EMISSAO , SF2.F2_HORA , SD2.D2_DOC , SD2.D2_ITEM"

	cQuery := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, .T. /*lQueryOnly*/ )
	If lPOA30SQL
		cQuery := ExecBlock("POA30SQL",.f.,.f.,{ "11" , cQuery , lPriceUpdates }) // 11 - PartDelivery ( Cancelamentos )
	EndIf

	OA030037C_ExecQuery( cQuery, {}, cQAlSQL /*cAlias*/, /*lQueryOnly*/ )
	While !( cQAlSQL )->( Eof() )
		If ( cQAlSQL )->( F2_PREFORI ) == cPrefBal // Balcao
			cOrdNumber := ( cQAlSQL )->( VEC_NUMORC )
		Else
			cOrdNumber := ( cQAlSQL )->( VEC_NUMOSV )
		EndIf

		cSequen := ""
		If ( cQAlSQL )->( F2_PREFORI ) == cPrefOfi // Oficina
			If lPOA30SOF
				cSequen := ExecBlock("POA30SOF",.F.,.F.,{ cFilVO3 , cOrdNumber , ( cQAlSQL )->( B1_COD ) })
			EndIf
		EndIf
		If Empty(cSequen)
			cSequen := strzero(val(( cQAlSQL )->( D2_ITEM )),4)
		EndIf
		If ( cQAlSQL )->( F2_EMISSAO ) == ( cQAlSQL )->( F3_DTCANC ) // Cancelamento no mesmo dia da Venda
			If ( cQAlSQL )->( F2_PREFORI ) == cPrefBal // Balcao
				If nCntQtd == nLimiteArq
					OA0300071_GravaXML(cRetXML)
					cRetXML := ""
					nCntQtd := 1
				EndIf

				If !Empty( ( cQAlSQL )->( F2_EMISSAO ) )
					cAux1 := ( cQAlSQL )->( F2_EMISSAO )+"T"
					cAux1 += Left(( cQAlSQL )->( F2_HORA ),2)
					cAux1 += right(Left(( cQAlSQL )->( F2_HORA ),5),2)
				Else
					cAux1 := "19500101T0000"
				EndIf

				cForeCast := "True"
				nQtdFalta := 0
				aBind := {}
				cQuery := "SELECT VS3.VS3_CODSIT, V09.V09_LEVDEM "
				cQuery += "  FROM "+cNamVS3+" VS3"
				cQuery += "  JOIN "+cNamV09+" V09 ON V09.V09_FILIAL= ? AND V09.V09_CODSIT = VS3.VS3_CODSIT AND V09.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilV09 } )
				cQuery += " WHERE VS3.VS3_FILIAL= ? "	; aAdd( aBind, { "C", cFilVS3 } )
				cQuery += "   AND VS3.VS3_NUMORC= ? "	; aAdd( aBind, { "C", cOrdNumber } )
				cQuery += "   AND VS3.VS3_GRUITE IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
				cQuery += "   AND VS3.VS3_CODITE= ? "	; aAdd( aBind, { "C", (cQAlSQL)->B1_CODITE } )
				cQuery += "   AND VS3.D_E_L_E_T_=' '"
				OA030037C_ExecQuery( cQuery, aBind, cQAlAux /*cAlias*/, /*lQueryOnly*/ )
				If !( cQAlAux )->( Eof() )
					If ( cQAlAux )->( V09_LEVDEM ) == "0"
						cForeCast := "False"
					EndIf

				EndIf
				( cQAlAux )->( DbCloseArea() )

				cAux2 := Alltrim(TransForm(nQtdFalta,"@E 9999999999")) // Qtde.Faltante
				cAux3 := Alltrim(TransForm(( cQAlSQL )->( D2_QUANT ),"@E 9999999999")) // Qtde.Vendida (Possivel)
				cAux4 := Alltrim(TransForm(( cQAlSQL )->( D2_QUANT )+nQtdFalta,"@E 9999999999")) // Qtde.Necessaria (Qtde.Vendida+Qtde.Faltante)
				cRetXML += OA0300051_Transaction( .T. , nCntID )
				cRetXML += '<v11:PartOrder '
				cRetXML +=                'pointOfSale="OTC" '
				cRetXML +=                'ForecastBase="'+cForeCast+'" '
				cRetXML +=                'customerType="Normal" '
				cRetXML +=                'backOrderQuantity="'+cAux2+'" '                  // backOrderQuantity =  9 – QUANTIDADE FALTANTE
				cRetXML +=                'bookedQuantity="'+cAux3+'" '                     // bookedQuantity    = 11 – QUANTIDADE POSSIVEL
				cRetXML +=                'orderTimestamp="'+cAux1+'" '
				cRetXML +=                'orderedQuantity="'+cAux4+'" '                    // orderedQuantity   = 20 – QUANTIDADE NECESSARIA
				cRetXML +=                'customerName="'+OA0300431_TrocaTexto( Alltrim(Left(( cQAlSQL )->( A1_NOME ),15)) )+'" '
				cRetXML +=                'customerNumber="'+Alltrim(( cQAlSQL )->( F2_CLIENTE )+( cQAlSQL )->( F2_LOJA ))+'" '
				cRetXML +=                'orderType="Normal">'+PulaLinha
				cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
				cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
				cRetXML += '<v11:OrderId orderLineNumber="'+strzero(val(( cQAlSQL )->( D2_ITEM )),4)+'" '
				cRetXML +=              'orderNumber="'+cOrdNumber+'"/>'+PulaLinha
				cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim(( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
				cRetXML += '</v11:PartOrder>'+PulaLinha
				cRetXML += OA0300051_Transaction( .F. , 0 )
				nCntID++
				nCntQtd++
			EndIf

			If nCntQtd == nLimiteArq
				OA0300071_GravaXML(cRetXML)
				cRetXML := ""
				nCntQtd := 1
			EndIf

			If !Empty( ( cQAlSQL )->( F2_EMISSAO ) )
				cAux1 := ( cQAlSQL )->( F2_EMISSAO )+"T"
				cAux1 += Left(( cQAlSQL )->( F2_HORA ),2)
				cAux1 += right(Left(( cQAlSQL )->( F2_HORA ),5),2)
			Else
				cAux1 := "19500101T0000"
			EndIf
			cAux2 := Alltrim(TransForm(( cQAlSQL )->( D2_QUANT ),"@E 9999999999"))
			cRetXML += OA0300051_Transaction( .T. , nCntID )
			cRetXML += '<v11:PartDelivery deliverTime="'+cAux1+'" deliveredQuantity="'+cAux2+'">'+PulaLinha
			cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
			cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
			cRetXML += '<v11:OrderId orderLineNumber="'+cSequen+'" '
			cRetXML +=              'orderNumber="'+Alltrim(cOrdNumber)+'"/>'+PulaLinha
			cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim( ( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
			cRetXML += '</v11:PartDelivery>'+PulaLinha
			cRetXML += OA0300051_Transaction( .F. , 0 )
			nCntID++
			nCntQtd++
			If aScan(aIteVendas, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
				aAdd(aIteVendas,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , cAux1 })
			EndIf
		EndIf

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		If !Empty( ( cQAlSQL )->( F2_EMISSAO ) )
			cAux1 := ( cQAlSQL )->( F2_EMISSAO )+"T"
			cAux1 += Left(( cQAlSQL )->( F2_HORA ),2)
			cAux1 += right(Left(( cQAlSQL )->( F2_HORA ),5),2)
		Else
			cAux1 := "19500101T0000"
		EndIf

		If ( cQAlSQL )->( F2_PREFORI ) == cPrefBal // Balcao
			cForeCast := "True"
			nQtdFalta := 0
			aBind := {}
			cQuery := "SELECT VS3.VS3_CODSIT "
			cQuery += "  FROM "+cNamVS3+" VS3"
			cQuery += "  JOIN "+cNamVS1+" VS1 ON VS1.VS1_FILIAL= ? " ; aAdd( aBind, { "C", cFilVS1 } )
			cQuery += "   AND VS1.VS1_NUMORC=VS3.VS3_NUMORC 
			cQuery += "   AND VS1.VS1_NUMNFI= ? " ; aAdd( aBind, { "C", (cQAlSQL)->D2_DOC } )
			cQuery += "   AND VS1.VS1_SERNFI= ? " ; aAdd( aBind, { "C", (cQAlSQL)->D2_SERIE } )
			cQuery += "   AND VS1.D_E_L_E_T_=' '"			
			cQuery += "  JOIN "+cNamV09+" V09 ON V09.V09_FILIAL= ? AND V09.V09_CODSIT = VS3.VS3_CODSIT AND V09.D_E_L_E_T_=' '"	; aAdd( aBind, { "C", cFilV09 } )
			cQuery += " WHERE VS3.VS3_FILIAL= ?"	; aAdd( aBind, { "C", cFilVS3 } )
			cQuery += "   AND VS3.VS3_GRUITE IN ( ? )"	; aAdd( aBind, { "A", aGrpTotal } )
			cQuery += "   AND VS3.VS3_CODITE= ? "	; aAdd( aBind, { "C", (cQAlSQL)->B1_CODITE } )
			cQuery += "   AND V09.V09_LEVDEM = '0'"
			cQuery += "   AND VS3.D_E_L_E_T_=' '"
			OA030037C_ExecQuery( cQuery, aBind, cQAlAux /*cAlias*/, /*lQueryOnly*/ )
			If !( cQAlAux )->( Eof() )
				cForeCast := "False"
			EndIf
			( cQAlAux )->( DbCloseArea() )

			cRetXML += OA0300051_Transaction( .T. , nCntID )
			cRetXML += '<v11:PartOrder '
			cRetXML +=                'pointOfSale="OTC" '
			cRetXML +=                'ForecastBase="'+cForeCast+'" '
			cRetXML +=                'customerType="Normal" '
			cRetXML +=                'backOrderQuantity="0" '                  // backOrderQuantity =  9 – QUANTIDADE FALTANTE
			cRetXML +=                'bookedQuantity="0" '                     // bookedQuantity    = 11 – QUANTIDADE POSSIVEL
			cRetXML +=                'orderTimestamp="'+cAux1+'" '
			cRetXML +=                'orderedQuantity="0" '                    // orderedQuantity   = 20 – QUANTIDADE NECESSARIA
			cRetXML +=                'customerName="'+OA0300431_TrocaTexto( Alltrim(Left(( cQAlSQL )->( A1_NOME ),15)) )+'" '
			cRetXML +=                'customerNumber="'+Alltrim(( cQAlSQL )->( F2_CLIENTE )+( cQAlSQL )->( F2_LOJA ))+'" '
			cRetXML +=                'orderType="Normal">'+PulaLinha
			cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
			cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
			cRetXML += '<v11:OrderId orderLineNumber="'+cSequen+'" '
			cRetXML +=              'orderNumber="'+Alltrim(cOrdNumber)+'"/>'+PulaLinha
			cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim(( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
			cRetXML += '</v11:PartOrder>'+PulaLinha
			cRetXML += OA0300051_Transaction( .F. , 0 )
			nCntID++
			nCntQtd++
		EndIf

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cRetXML)
			cRetXML := ""
			nCntQtd := 1
		EndIf

		cRetXML += OA0300051_Transaction( .T. , nCntID )
		cRetXML += '<v11:PartDelivery deliverTime="'+cAux1+'" deliveredQuantity="0">'+PulaLinha
		cRetXML += '<v11:AssortmentOperatorId identIfier="'+cOperatID+'"/>'+PulaLinha
		cRetXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+PulaLinha
		cRetXML += '<v11:OrderId orderLineNumber="'+cSequen+'" '
		cRetXML +=              'orderNumber="'+Alltrim(cOrdNumber)+'"/>'+PulaLinha
		cRetXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim( ( cQAlSQL )->( B1_CODITE ))+'"/>'+PulaLinha
		cRetXML += '</v11:PartDelivery>'+PulaLinha
		cRetXML += OA0300051_Transaction( .F. , 0 )
		nCntID++
		nCntQtd++
		// Vetores utilizados no Balance de Estoque
		If aScan(aIteBalance, {|x| x[1] + x[2] == cFilAnt + ( cQAlSQL )->( B1_CODITE ) }) == 0
			aAdd(aIteBalance,{ cFilAnt , ( cQAlSQL )->( B1_CODITE ) , cAux1 })
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("SD2")

Return cRetXML

/*/{Protheus.doc} OA0300431_TrocaTexto
	Troca no texto '&' para 'e'

	@author Andre Luis Almeida
	@since 02/02/2021
/*/
Static Function OA0300431_TrocaTexto( cTxt )
	Local cTexto := cTxt
	Local nTam   := AT("&",cTexto)
	While nTam > 0
		cTexto := STUFF(cTexto,nTam,1,"e")
		nTam := AT("&",cTexto)
	EndDo
Return cTexto


/*/{Protheus.doc} OA030035C_GetConfig
Pega a configuracao em Formato de data container
@type Function
@author Cristiam Rossi
@since 10/11/2025
/*/
Function OA030035C_GetConfig()
	Local   oConfig   := JsonObject():New()
	Local   oAux      := JsonObject():New()
	Local   lExistCfg := .F.
	Local   cJson

	VRN->(dbSetOrder(2))
	lExistCfg := VRN->(dbSeek( xFilial("VRN") + cFilAnt + cCodVRNDelimit ))
	If lExistCfg
		oConfig:FromJson(VRN->VRN_CONFIG)
	Endif

	If !lExistCfg
		oConfig["FILIAIS"] := {}
		oAux["FILIAL"] := cFilAnt
		oAux["SD1"] := JsonObject():New()
		oAux["SD1"]["NUMSEQ"] := "000000"
		oAux["SD2"] := JsonObject():New()
		oAux["SD2"]["NUMSEQ"] := "000000"
		oAux["SD3"] := JsonObject():New()
		oAux["SD3"]["NUMSEQ"] := "000000"
		oAux["VE9"] := JsonObject():New()
		oAux["VE9"]["NROSUB"] := "0000000000"
		oAux["VPJ"] := JsonObject():New()
		oAux["VPJ"]["CODIGO"] := "000000"
		oAux["ULTIMA_EXECUCAO"] := JsonObject():New()
		oAux["ULTIMA_EXECUCAO"]["DATA"] := "19000101"
		oAux["ULTIMA_EXECUCAO"]["HORA"] := "00:00:00"
		aAdd( oConfig["FILIAIS"], oAux )

		cJson := FGX_JSONForm( oConfig:ToJson(), .T., nil, .F. )
		Reclock("VRN", !lExistCfg)
		VRN->VRN_FILIAL := xFilial("VRN")
		VRN->VRN_CODIGO := cCodVRNDelimit
		VRN->VRN_CONFIG := cJson
		VRN->VRN_FILCON := cFilAnt
		VRN->(MsUnlock())

	EndIf

return oConfig


/*/{Protheus.doc} OA030036C_SaveConfig
Salva a configuracao no lugar da atual
@type Function
@author Cristiam Rossi
@since 10/11/2025
/*/
Function OA030036C_SaveConfig( oDados )
	Local oConfig := OA030035C_GetConfig()
	Local oAux
	Local nI
	Local lAtualiz := .F.
	Local cJson

	For nI := 1 to Len( oConfig["FILIAIS"] )
		oAux := oConfig["FILIAIS"][nI]
		nPos := aScan( oDados["FILIAIS"], {|it| it["FILIAL"] == oAux["FILIAL"] } )
		If nPos > 0
			oAux["SD1"]["NUMSEQ"]           := oDados["FILIAIS"][nPos]["SD1"]["NUMSEQ"]
			oAux["SD2"]["NUMSEQ"]           := oDados["FILIAIS"][nPos]["SD2"]["NUMSEQ"]
			oAux["SD3"]["NUMSEQ"]           := oDados["FILIAIS"][nPos]["SD3"]["NUMSEQ"]
			oAux["VE9"]["NROSUB"]           := oDados["FILIAIS"][nPos]["VE9"]["NROSUB"]
			oAux["VPJ"]["CODIGO"]           := oDados["FILIAIS"][nPos]["VPJ"]["CODIGO"]
			oAux["ULTIMA_EXECUCAO"]["DATA"] := oDados["FILIAIS"][nPos]["ULTIMA_EXECUCAO"]["DATA"]
			oAux["ULTIMA_EXECUCAO"]["HORA"] := oDados["FILIAIS"][nPos]["ULTIMA_EXECUCAO"]["HORA"]
			lAtualiz := .T.
		endIf
	Next

	If !lAtualiz
		oAux := JsonObject():New()
		oAux["FILIAL"] := cFilAnt
		oAux["SD1"] := JsonObject():New()
		oAux["SD1"]["NUMSEQ"] := oDados["SD1"]["NUMSEQ"]
		oAux["SD2"] := JsonObject():New()
		oAux["SD2"]["NUMSEQ"] := oDados["SD2"]["NUMSEQ"]
		oAux["SD3"] := JsonObject():New()
		oAux["SD3"]["NUMSEQ"] := oDados["SD3"]["NUMSEQ"]
		oAux["VE9"] := JsonObject():New()
		oAux["VE9"]["NROSUB"] := oDados["VE9"]["NROSUB"]
		oAux["VPJ"] := JsonObject():New()
		oAux["VPJ"]["CODIGO"] := oDados["VPJ"]["CODIGO"]
		oAux["ULTIMA_EXECUCAO"] := JsonObject():New()
		oAux["ULTIMA_EXECUCAO"]["DATA"] := oDados["ULTIMA_EXECUCAO"]["DATA"]
		oAux["ULTIMA_EXECUCAO"]["HORA"] := oDados["ULTIMA_EXECUCAO"]["HORA"]
		aAdd( oConfig["FILIAIS"], oAux )
	endIf

	cJson := oConfig:ToJson()

	VRN->(dbSetOrder(2))
	If VRN->(dbSeek( xFilial("VRN") + cFilAnt + cCodVRNDelimit ))
		Reclock("VRN", .F.)
		VRN->VRN_CONFIG := FGX_JSONForm( cJson, .T., nil, .F. )
		VRN->(MsUnlock())
	Endif
Return .T.

/*/{Protheus.doc} OA0300LS_LostSale
	Levantamento e geração da TAG LostSale - DSM Global
	Atende História #9 - Venda Perdida
	
	@param cVPJSqIni Sequencial inicial de VPJ a processar
	@param cVPJSqFim Sequencial final de VPJ a processar 
	@param cWHouseID   Warehouse ID da filial
	@param aGrpTotal   Array com grupos permitidos
	@param nCntID      Contador de Transaction (by reference)
	@param cXMLInic    XML acumulado
	
	@return cRetXML    XML com blocos LostSale gerados
	
	@author Lucas Brustolin
	@since 09/01/2026
/*/
Static Function OA0300LS_LostSale(cNroSqIni, cNroSqFin, cWHouseID, aGrpTotal, nCntID, cXMLInic, aTiposAssunto, aCodigoMotivos)
	Local cRetXML   := cXMLInic
	Local cQAlSQL   := "SQLVPJ"
	Local cQuery    := ""
	Local cLostTime := ""
	Local aBind     := {}
	Local lVPJCODMOT := .F.
	Local nI := 0

	Default cNroSqIni  := ""
	Default cNroSqFin  := ""
	Default cWHouseID  := ""
	Default nCntID     := 1
	Default cXMLInic   := ""
	Default aTiposAssunto := {}
	Default aCodigoMotivos := {}

	lVPJCODMOT := (Len(aTiposAssunto) > 0) .and. (Len(aCodigoMotivos) > 0) .and. (Len(aTiposAssunto) == Len(aCodigoMotivos))

	If lVPJCODMOT
		aBind := {}
		cQuery := "	SELECT "
		cQuery += "       VPJ.VPJ_CODIGO, "
		cQuery += "       VPJ.VPJ_DATCAN,"
		cQuery += "       VPJ.VPJ_HORCAN,"
		cQuery += "       VPJ.VPJ_QTDITE,"
		cQuery += "       VPJ.VPJ_CODITE "
		cQuery += "	FROM " + RetSqlName("VPJ") + " VPJ"
		cQuery += "	WHERE VPJ.VPJ_FILIAL = ?"	;	aAdd(aBind, {"C", xFilial("VPJ")})
		cQuery += "		AND VPJ.VPJ_CODIGO >  ?"	;	aAdd(aBind, {"C", cNroSqIni})
		cQuery += "		AND VPJ.VPJ_CODIGO <= ?"	;	aAdd(aBind, {"C", cNroSqFin})
		cQuery += "		AND VPJ.VPJ_GRUITE IN (?)"	;	aAdd(aBind, {"A", aGrpTotal})

		//Criando Filtro por tuplas exatas para evitar produto cartesiano entre arrays
		cQuery += "		AND ("
		For nI := 1 to Len(aTiposAssunto)
			If nI > 1
				cQuery += "    OR "
			EndIf
			cQuery += "("
			cQuery +=		"VPJ.VPJ_TIPASS = ? " ; aAdd(aBind, {"C", aTiposAssunto[nI]})
			cQuery +=		"AND VPJ.VPJ_CODMOT = ?)"	;	aAdd(aBind, {"C", aCodigoMotivos[nI]})
		Next nI

		cQuery += ")"
		cQuery += "		AND VPJ.VPJ_DATCAN <> ' ' "
		cQuery += "		AND VPJ.VPJ_QTDITE > 0 "
		cQuery += "		AND VPJ.D_E_L_E_T_ = ' '"
		cQuery += "	ORDER BY VPJ.VPJ_CODIGO"

		cQuery := OA030037C_ExecQuery(cQuery, aBind, /*cAlias*/, .T.)
		If lPOA30SQL
			cQuery := ExecBlock("POA30SQL",.F.,.F.,{"12", cQuery, lPriceUpdates})
		EndIf

		OA030037C_ExecQuery(cQuery, {}, cQAlSQL, /*lQueryOnly*/)

		While !(cQAlSQL)->(Eof())

			If nCntQtd == nLimiteArq
				OA0300071_GravaXML(cRetXML)
				cRetXML := ""
				nCntQtd := 1
			EndIf

			cRetXML += OA0300051_Transaction(.T., nCntID)
			nCntID++

			// Monta lostTime: AAAAMMDD + T + HHMM
			cLostTime := (cQAlSQL)->VPJ_DATCAN + "T" + cValToChar((cQAlSQL)->VPJ_HORCAN)

			// Geração do bloco <v11:LostSale>
			cRetXML += '<v11:LostSale lostTime="' + cLostTime + '" '
			cRetXML +=               'quantity="' + AllTrim(TransForm((cQAlSQL)->VPJ_QTDITE, "@E 9999999999")) + '">' + PulaLinha
			cRetXML += '<v11:AssortmentOperatorId identIfier="' + cOperatID + '"/>' + PulaLinha
			cRetXML += '<v11:StockId stockId="1" warehouseId="' + cWHouseID + '"/>' + PulaLinha
			cRetXML += '<v11:PartId assortmentOwnerId="' + cOwnerID + '" '
			cRetXML +=             'partNumber="' + AllTrim((cQAlSQL)->VPJ_CODITE) + '"/>' + PulaLinha
			cRetXML += '</v11:LostSale>' + PulaLinha

			// Fecha Transaction
			cRetXML += OA0300051_Transaction(.F., 0)

			nCntQtd++
			(cQAlSQL)->(DbSkip())
		EndDo

		(cQAlSQL)->(DbCloseArea())
		DbSelectArea("VPJ")
	endIf

Return cRetXML

/*/{Protheus.doc} OA030039F_ObtemSeqItemRequisicaoAux
retorna sequencial e atualiza quantidade do item da requisição em tabela auxiliar VRW
@type Function
@author Emanuel Furtado
@since 26/12/2025
@return string 
/*/
Static Function OA030039F_ObtemSeqItemRequisicaoAux(cFilAux,cNumOSV,cGrupIt,cCodIt,cSeqInc)

	Local cSeqRet := ""
	Local cAlias  := "VRW"
	Local nProx := 1

	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(2))

	cSeqRet := StrZero(nProx, 4)

	If (cAlias)->(DbSeek(cFilAux + cNumOSV + cSeqInc + cGrupIt + cCodIt)) //VRW_FILIAL, VRW_NUMOSV, VRW_SEQINC, VRW_GRUITE, VRW_CODITE, R_E_C_N_O_, D_E_L_E_T_
		cSeqRet := (cAlias)->VRW_SEQITE
	EndIf

	(cAlias)->(DbCloseArea())

Return cSeqRet

/*/{Protheus.doc} OA030040K_RegistraLOG
	Função que registra os logs desde o inicio
	do processamento até a conclusão
	@type  Static Function
	@author user
	@since 27/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function OA030040K_RegistraLOG( aLog, cCodLogVQL, lClose)

	Local oLogger 		:= DMS_Logger():New()
	Default aLog		:= {"","","",.T.}
	Default cCodLogVQL 	:= ""
	Default lClose		:= .F.

	cCodHelp	:= aLog[1]
	cMensagem	:= aLog[2]
	cSolucao	:= aLog[3]
	lShowHelp	:= aLog[4]

	If Empty(cCodLogVQL)

		cCodLogVQL := oLogger:LogToTable(	{;
			{'VQL_CODVQL',	''},;
			{'VQL_AGROUP',	FunName()	},;
			{'VQL_TIPO'  , 	cTipoExec	},; // Tipo de Execucao ( via 0-Carga Inicial / 1-Manual / 2-Schedule / 3-Reprocess.Manual / 4-Price Updates )
			{'VQL_DADOS' , 	cCodHelp	},;
			{'VQL_FILORI', 	cFilAnt		},;
			{'VQL_MSGLOG', 	STR0038 + cFilAnt + " | " + PulaLinha + cMensagem +" | "+ PulaLinha + cSolucao}; // #Filial
			})

	Else
		oLogger:LogToTable(	{;
			{'VQL_CODVQL',	cCodLogVQL	},;
			{'VQL_AGROUP',	FunName()	},;
			{'VQL_TIPO'  , 	cTipoExec	},;
			{'VQL_DADOS' , 	cCodHelp	},;
			{'VQL_FILORI', 	cFilAnt		},;
			{'VQL_MSGLOG', 	STR0038 + cFilAnt + " | " + PulaLinha + cMensagem +" | "+ PulaLinha + cSolucao}; // #Filial
			})

	EndIf

	If lShowHelp .or. lSchedule
		FMX_HELP(cCodHelp, cMensagem, cSolucao)
	Endif

	If lClose
		oLogger:CloseOpened(cCodLogVQL)
	EndIf

Return cCodLogVQL

/*/{Protheus.doc} OA030037C_ExecQuery
executa query com método FWPreparedStatement()
@type Function
@author Cristiam Rossi
@since 23/05/2025
@param cQuery, character, string query
@param aBind, character, lista dos parmetros
@param cAlias, character, alias que ser aberto
@param lQueryOnly, logical, se deve retornar apenas a query string ps bind
@return variant, se lQueryOnly: query; se For SELECT: Alias; se UPDATE: .T.
/*/
Function OA030037C_ExecQuery( cQuery, aBind, cAlias, lQueryOnly )

	Local   nI
	Local   oStatement
	Local   xRet
	Default aBind       := {}
	Default cAlias      := getNextAlias()
	Default lQueryOnly  := .F.

	oStatement := FwExecStatement():new( cQuery )

	For nI := 1 to Len( aBind )
		If aBind[nI,1] == "C"
			oStatement:SetString( nI, aBind[nI,2] )
		ElseIf aBind[nI,1] == "N"
			oStatement:SetNumeric( nI, aBind[nI,2] )
		ElseIf aBind[nI,1] == "A"
			oStatement:SetIn( nI, aBind[nI,2] )
		ElseIf aBind[nI,1] == "D"
			oStatement:SetDate( nI, aBind[nI,2] )
		EndIf		
	Next

	cQuery := oStatement:getFixQuery()

	If lQueryOnly
		xRet := cQuery
	else
		If "SELECT" $ Upper(cQuery)
			oStatement:OpenAlias( cAlias )
			DBSelectArea( cAlias )
			xRet := cAlias
		else
			xRet := TCSQLExec( cQuery ) >= 0
		endIf
	endIf

	oStatement:destroy()
	FwFreeObj(oStatement)

return xRet

/*/{Protheus.doc} OA030038C_ExecFormula
executa a Fórmula posicionando as tabela SB1, SB5 e SBZ antes
@type Function
@author Cristiam Rossi
@since 14/11/2025
@return numeric, 
/*/
Static Function OA030038C_ExecFormula( cPriceType, cGruite, cCodite )

	Local   aArea    := GetArea()
	Local   aAreaSB1 := SB1->( GetArea() )
	Local   aAreaSB5 := SB5->( GetArea() )
	Local   aAreaSBZ := SBZ->( GetArea() )
	Local   nRet     := 0
	Local   nAux
	Local 	cFormul	 := ""
	Default cGruite  := cGrpPrinc
	Default cCodite  := ""

	If cPriceType == "PurchaseGross"
		cFormul := cFrmPrcVnd
	ElseIf cPriceType == "PurchaseNet"
		cFormul := cFrmPrcRep
	Endif

	cFormul := PadR( cFormul , TamSX3("VEG_CODIGO")[1] )
	cGruite	:= PadR( cGruite , TamSX3("B1_GRUPO"  )[1] )
	cCodite	:= PadR( cCodite , TamSX3("B1_CODITE" )[1] )

	SB1->( DBSetOrder(7) )	// B1_FILIAL+B1_GRUPO+B1_CODITE
	If SB1->( DBSeek( xFilial("SB1") + cGruite + cCodite ) )

		SB5->( DBSetOrder(1) )
		SB5->( DBSeek( xFilial("SB5") + SB1->B1_COD ) )

		SBZ->( DBSetOrder(1) )
		SB5->( DBSeek( xFilial("SBZ") + SB1->B1_COD ) )

		If !Empty( cFormul )
			nAux := FG_Formula( cFormul )
			If ValType( nAux ) == "N"
				nRet := nAux
			EndIf
		EndIf
	EndIf
	SBZ->( RestArea( aAreaSBZ ) )
	SB5->( RestArea( aAreaSB5 ) )
	SB1->( RestArea( aAreaSB1 ) )
	RestArea( aArea )

Return nRet

/*/{Protheus.doc} OA030041K_QueryTriggerPRV1
	Retorna query que busca alteração do valor 
	nos campos B1_PRV1 e BZ_PRV1, dependendo da existencia
	ou não do campo e trigger na tabela SBZ (opcional)
	@type  Static Function
	@author Lucas Oliveira
	@since 08/04/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA030041K_QueryTriggerPRV1(dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef)

	Local cQuery 	:= ""
	Local aBind		:= {}
	Local cNamSB1	:= RetSqlName("SB1")
	Local cNamSB5	:= RetSqlName("SB5")
	Local cNamSBZ	:= RetSqlName("SBZ")

	cQuery := "	WITH ITENS_PRECO_ALTERADO AS ( "

	cQuery += "		SELECT SB1.B1_COD AS COD_ITEM "
	cQuery += "		FROM " + cNamSB1 + "_TTAT_LOG TRIG "
	cQuery += "		JOIN " + cNamSB1 + " SB1  "
	cQuery += "			ON SB1.R_E_C_N_O_ = TRIG.TTAT_RECNO "
	cQuery += "		AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "		WHERE TRIG.TTAT_FIELD = 'B1_PRV1' "
	cQuery += OA0300041_DTIME( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef )
	cQuery += "		AND SB1.B1_GRUPO IN ( ? ) " ; aAdd( aBind, { "A", aGrpTotal })
	If !lEnviaListaPreco
		cQuery += " AND TRIG.TTAT_PROGRAM <> 'OFIA539'" // OFIA539 é a rotina de atualização de lista de preço de peças
	Endif

	// Só executa se criou trigger para a SBZ e criou o campo BZ_PRV1 manualmente na base
	If lBZ_PRV1 .and. lSBZTrigg
	
		cQuery += "		UNION

		cQuery += "		SELECT SBZ.BZ_COD "
		cQuery += "		FROM " + cNamSBZ + "_TTAT_LOG TRIG "
		cQuery += "		JOIN " + cNamSBZ + " SBZ  "
		cQuery += "			ON SBZ.R_E_C_N_O_ = TRIG.TTAT_RECNO "
		cQuery += "			AND SBZ.D_E_L_E_T_ = ' ' "
		cQuery += "		JOIN " + cNamSB1 + " SB1  "
		cQuery += "			ON SB1.B1_FILIAL = ? "  ; aAdd( aBind, { "C", xFilial("SB1") })
		cQuery += "			AND SB1.B1_COD = SBZ.BZ_COD "
		cQuery += "			AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "			AND SB1.B1_GRUPO IN ( ? ) " ; aAdd( aBind, { "A", aGrpTotal })
		cQuery += "		WHERE TRIG.TTAT_FIELD = 'BZ_PRV1' "
		cQuery += OA0300041_DTIME( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef )
		If !lEnviaListaPreco
			cQuery += " AND TRIG.TTAT_PROGRAM <> 'OFIA539'" // OFIA539 é a rotina de atualização de lista de preço de peças
		Endif
	Endif

	cQuery += "	)"

	cQuery += "	SELECT "
	cQuery += "		SB1.B1_CODITE, "
	cQuery += "		MIN(SBZ.BZ_PRIENT) AS MIN_PRIENT, "
	cQuery += "		MAX(SBZ.BZ_PRIENT) AS MAX_PRIENT, "
	If lB5_ULTVEN
        cQuery += "   MAX(SB5.B5_ULTVEN)  AS B5_ULTVEN  ,"
    EndIf	
	cQuery += "		MAX(SB5.B5_LOCALI2) AS B5_LOCALI2 "

	cQuery += "	FROM ITENS_PRECO_ALTERADO ITENS_ALT "

	cQuery += "	JOIN " + cNamSB1 + " SB1 
	cQuery += "		ON SB1.B1_FILIAL = ? "  ; aAdd( aBind, { "C", xFilial("SB1") })
	cQuery += "		AND SB1.B1_COD = ITENS_ALT.COD_ITEM "
	cQuery += "		AND SB1.D_E_L_E_T_ = ' ' "

	cQuery += "	JOIN " + cNamSB5 + " SB5 "
	cQuery += "		ON SB5.B5_FILIAL = ? "  ; aAdd( aBind, { "C", xFilial("SB5") })
	cQuery += "		AND SB5.B5_COD = SB1.B1_COD "
	cQuery += "		AND SB5.D_E_L_E_T_ = ' ' "

	cQuery += "	LEFT JOIN " + cNamSBZ + " SBZ "
	cQuery += "		ON SBZ.BZ_FILIAL = ? "   ; aAdd( aBind, { "C", xFilial("SBZ") })
	cQuery += "		AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "		AND SBZ.D_E_L_E_T_ = ' ' "

	cQuery += "		GROUP BY SB1.B1_CODITE "

	cQuery  := OA030037C_ExecQuery( cQuery, aBind, /*cAlias*/, /*lQueryOnly := */ .T. )

Return cQuery

/*/{Protheus.doc} SchedDef
	(long_description)
	@type  Static Function
	@author user
	@since 08/04/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SchedDef()

	Local cPerg		:= PadR("OFIA030", Len(SX1->X1_GRUPO))
	Local aParam	:= { "P",;
		cPerg,;
		"",;
		"",;
		""}

Return aParam

/*/{Protheus.doc} OA030042K_ObterFilialDoProcessamento
	Função que retorna a filial preparada para o processamento
	@type  Static Function
	@author Lucas Oliveira
	@since 10/04/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA030042K_ObterFilialDoProcessamento(aFilExec)

	nPosFilExec := aScan(aFilExec, {|x| x[1] == cFilAnt})

Return nPosFilExec
