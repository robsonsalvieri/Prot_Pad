#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'OFIA628.CH'

/*/{Protheus.doc} OFIA628
	Importacao de arquivos DPM
	Importa arquivos DPMSCHED, DPMXFER e DPMORD do caminho
	configurado para cada grupo DPM.

	@author Vinicius Gati
	@since  11/06/2026
/*/
Function OFIA628(aParam)
	Local nIdx := 1
	Local aConfs
	Local lUsaGrps
	Private oUtil           := DMS_Util():New()
	Private oSqlHlp         := DMS_SqlHelper():New()
	Private oArHlp          := DMS_ArrayHelper():New()
	Private oLogger         := DMS_Logger():New("OFIA628.LOG")
	Private oDpm            := OFJDRpmConfig():New()
	Private lIsDebug        := "OFIA628" $ GetNewPar("MV_MILDBG", "NAO") .OR. "*DPM*" $ GetNewPar("MV_MILDBG", "NAO")
	Private lForcSch        := "OFIA628SCH" $ GetNewPar("MV_MILDBG", "NAO")
	Private lProcForce      := lIsDebug .AND. "FORCE" $ GetNewPar("MV_MILDBG", "NAO")
	Private cTblLogCod
	Private lNovoCombo      := GetNewPar("MV_MIL0210", .F.)
	Private lDebug := .T.

	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ INICIANDO OFIA628 ~~~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if lNovoCombo
		UserException(STR0001) //"Usuários combo brasil deve executar a rotina OFIA515"
	endif

	if ! oDpm:Ready(.F.)
		if ! isBlind()
			MsgInfo(oDpm:cLastError, STR0002) /* "Informação" */
		endif
		Return .F.
	endif

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFIA628'                                      },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                                 },;
		{'VQL_DADOS'      , 'MODO:' + IIF(isBlind(), STR0003, STR0004)     } ;
	}) // agendado ou normal

	lUsaGrps := LEN( oDpm:GetConfigs() ) > 0
	aConfs   := oDpm:GetConfigs()

	If ! lUsaGrps
		aConfs := { DMS_DPMConfig():New("SCHEDULER") }
	EndIf

	for nIdx := 1 to LEN(aConfs)
		OA6280024_ImportaArquivos(aConfs[nIdx], oLogger, cTblLogCod)
	next

	oLogger:CloseOpened(cTblLogCod)
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ FINALIZANDO OFIA628 ~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
Return

/*/{Protheus.doc} SchedDef
	Função padrão scheduler

	@author Vinicius Gati
	@since 05/05/2025
	@type function
/*/
Static Function SchedDef()
	Local aParam := {;
		"P",;
		"",;
		"",;
		"",;
		"" ;
	}
Return aParam

/*/{Protheus.doc} OA6280024_ImportaArquivos
	Importa arquivos DPM para um grupo especifico

	Busca arquivos DPMSCHED, DPMXFER e DPMORD no caminho
	de importacao configurado para o grupo e processa cada um.

	@author Vinicius Gati
	@since  11/06/2026
/*/
Function OA6280024_ImportaArquivos(oDpmCfg, oLogger, cTblLogCod)
	Local nIdx  := 1
	Local aArquivos := {}
	Local cPath := oDpmCfg:GetPath()
	Local oBckBlk  := ErrorBlock()
	Default oLogger := DMS_Logger():New()
	Default cTblLogCod := "OFIA628"

	If MethIsMemberOf(oDpmCfg ,"GetPathImp")
		cPath := oDpmCfg:GetPathImp()
	EndIf

	oJdConfig := OFJDConfig():New()
	If oJdConfig:sendoUsada()
		cPath := oJdConfig:CaminhoDeImportacao()
	EndIf

	conout(STR0005 + oDpmCfg:cGrupo + "' no caminho: " + cPath + ALLTRIM(" \ ")) //"Importando arquivos para grupo '"

	aArquivos := Directory(strtran(cPath + ALLTRIM(" \ ") + "JD2DLR_DPMSCHED_*.DAT", "//", "/"),,nil, .T.)
	if LEN( aArquivos ) > 0
		conout(STR0006 + cValToChar(len(aArquivos)) + " arquivos. GRUPO - " + oDpmCfg:cGrupo)
		for nIdx := 1 to LEN(aArquivos)
			aArqData := aArquivos[nIdx]
			If "JD2DLR_DPMSCHED_" $ aArqData[1];
				.AND. FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+oDpmCfg:cGrupo+"' AND VQL_TIPO = 'DPMSCHED_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
				FT_FUse( cPath + ALLTRIM(" \ ") + aArqData[1] )
				cArqCtnt := FT_FReadLn()
				FT_FUse()
				OA6280074_ImportaDPMSCHED(oDpmCfg:cGrupo, cArqCtnt, aArqData, cPath, oLogger, cTblLogCod)
			EndIf
		next
	endif

	aArquivos := Directory(strtran(cPath + ALLTRIM(" \ ") + "JD2DLR_DPMXFER_*.DAT", "//", "/"),,nil, .T.)
	if LEN( aArquivos ) > 0
		conout(STR0006 + cValToChar(len(aArquivos)) + " arquivos. GRUPO - " + oDpmCfg:cGrupo)
		for nIdx := 1 to LEN(aArquivos)
			aArqData := aArquivos[nIdx]
			If FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+oDpmCfg:cGrupo+"' AND VQL_TIPO = 'DPMXFER_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
				OA6280064_ImportaDPMXFE(oDpmCfg:cGrupo, cPath, aArqData)
			EndIf
		next
	endif

	aArquivos := Directory(strtran(cPath + ALLTRIM(" \ ") + "JD2DLR_DPMORD_*.DAT", "//", "/"),,nil, .T.)
	if LEN( aArquivos ) > 0
		conout(STR0006 + cValToChar(len(aArquivos)) + " arquivos. GRUPO - " + oDpmCfg:cGrupo)
		for nIdx := 1 to LEN(aArquivos)
			aArqData := aArquivos[nIdx]
			If FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+oDpmCfg:cGrupo+"' AND VQL_TIPO = 'DPMORD_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
				OA6280054_ImportaDPMORD(oDpmCfg:cGrupo, cPath, aArqData)
			EndIf
		next
	endif

	ErrorBlock(oBckBlk)
Return

/*/{Protheus.doc} OA6280054_ImportaDPMORD
	Importacao do arquivo de orders (DPMORD)

	Le o arquivo, valida via DMS_DPMOrders e efetiva em transacao.

	@author Vinicius Gati
	@since  11/06/2026
/*/
Function OA6280054_ImportaDPMORD(cGrupo, cPath, aArqData)
	Local oOrders
	Local oBckBlk  := ErrorBlock()

	ErrorBlock({ |e| ;
		OA6280084_EnviaEmailDeErro( CRLF + "Erro: " + e:Description + CRLF + ;
									 "Stacktrace: " + e:Errorstack ),;
		KillApp(.t.);
	})
	BEGIN TRANSACTION
		oOrders := DMS_DPMOrders():New( cPath , aArqData[1], cGrupo )
		If oOrders:AllOk()
			if oOrders:Efetivar()
				conout(STR0012)
				FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
			Else
				conout(STR0011 + cPath) // erro ao importar arquivo:
			EndIf
		EndIf
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.

/*/{Protheus.doc} OA6280064_ImportaDPMXFE
	Importacao do arquivo de transferencias (DPMXFER)

	Le o arquivo, valida via DMS_DPMXFers e efetiva em transacao.

	@author Vinicius Gati
	@since  11/06/2026
/*/
Function OA6280064_ImportaDPMXFE(cGrupo, cPath, aArqData)
	Local oXFer
	Local oBckBlk  := ErrorBlock()

	ErrorBlock({ |e| ;
		OA6280084_EnviaEmailDeErro(e:Description),;
		KillApp(.t.);
	})
	BEGIN TRANSACTION
		oXFer := DMS_DPMXFers():New( cPath , aArqData[1], cGrupo )
		If oXFer:AllOk()
			if oXFer:Efetivar()
				conout(STR0012)//Arquivo importado com sucesso
				FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
			Else
				conout(STR0011) // erro ao importar
			EndIf
		Else
			conout(STR0013 + cPath + ALLTRIM(" \ ") + aArqData[1]) // arquivo com formato erroneo
		EndIf
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.

/*/{Protheus.doc} OA6280074_ImportaDPMSCHED
	Importacao do arquivo de scheduler (DPMSCHED)

	Registra o arquivo no VQL, atualiza as geracoes via
	DMS_DPMSched:UpdateGers e renomeia o arquivo como importado.

	@author Vinicius Gati
	@since  11/06/2026
/*/
Function OA6280074_ImportaDPMSCHED(cGrupo, cArqCtnt, aArqData, cPath, oLogger, cTblLogCod)
	Local oBckBlk  := ErrorBlock()
	Default oLogger  := DMS_Logger():New()
	Default cTblLogCod := "OFIA628"

	ErrorBlock({ |e| ;
		OA6280084_EnviaEmailDeErro(e:Description),;
		killapp(.t.);
	})
	BEGIN TRANSACTION
		cVQLFN := oLogger:LogToTable({;
			{'VQL_AGROUP' , cGrupo         },;
			{'VQL_CODVQL' , cTblLogCod     },;
			{'VQL_TIPO'   , 'DPMSCHED_IMP' },;
			{'VQL_DADOS'  , aArqData[1]    } ;
		})
		cVQLFN := oLogger:LogToTable({;
			{'VQL_AGROUP' , cGrupo          },;
			{'VQL_CODVQL' , cVQLFN          },;
			{'VQL_TIPO'   , 'DPMSCHED_FILE' },;
			{'VQL_DADOS'  , cArqCtnt        } ;
		})

		oSched  := DMS_DPMSched():New(cGrupo)
		oSched:UpdateGers(.T.)

		nStatus := FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
		IF nStatus == -1
			conout(STR0006 + str(ferror(),4))
		Endif
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.

/*/{Protheus.doc} OA6280084_EnviaEmailDeErro
	Envia email de erro do sistema

	Tenta recuperar erros de alias inexistente e envia email
	com template mil_sys_err, com deduplicacao por hora.

	@author Vinicius Gati
	@since  11/06/2026
/*/
Function OA6280084_EnviaEmailDeErro(cErrMessage)
	Local oEmailHlp := DMS_EmailHelper():New()
	Local nIdxEr    := AT(cErrMessage, "Alias does not exist ")
	Local cTabela   := ""

	conout(STR0009 + cErrMessage)

	if nIdxEr > 0
		cTabela := SUBSTR(cErrMessage, nIdxEr + 21,  3)
		dbSelectArea(cTabela)
		conout(STR0010 + cTabela) // selecionando tabela
	else
		cErrMessage := FwNoAccent(cErrMessage)
		if ! OA6280094_JaEnviouEmail(cErrMessage)
			conout(cErrMessage)
			/* "Erro de sistema detectado em " */
			/* "Lamentamos o ocorrido, seguem detalhes do mesmo:" */
			oEmailHlp:SendTemplate({;
				{'template'           , 'mil_sys_err'                                                    },;
				{'origem'             , GetNewPar("MV_MIL0088", "")                                      },;
				{'destino'            , GetNewPar("MV_MIL0102", "")                                      },;
				{'assunto'            , STR0007 + dtoc(DATE()) + " " + TIME()                            },;
				{':titulo'            , STR0007 + dtoc(DATE()) + " " + TIME()                            },;
				{':cabecalho1'        , STR0008                                                          },;
				{':dados_cabecalho1'  , cErrMessage                                                      } ;
			})
		end
	end
Return .T.

/*/{Protheus.doc} OA6280094_JaEnviouEmail
	Verifica se o mesmo erro ja foi enviado por email nesta hora

	Evita bombardear a caixa de entrada com emails repetidos
	do mesmo assunto no mesmo intervalo de 1 hora.

	@author Vinicius Gati
	@since  11/06/2026
/*/
Function OA6280094_JaEnviouEmail(cErrMessage)
	Local nIdx := 1
	Local oUtil := DMS_Util():New()
	Local cFileName := "OFIA628_EMAILS_"+DTOS(date())+left(strtran(TIME(), ':', ''), 2)+".log"
	Local aEmails

	oData   := oUtil:ParamFileOpen(cFileName)
	aEmails := oData:getValue('emails', {})

	if ! Empty(aEmails)
		for nIdx := 1 to LEN( aEmails )
			if alltrim(aEmails[nIdx]) == alltrim(FwNoAccent(cErrMessage))
				conout(STR0014) //Email já enviado
				return .T.
			end
		end
	end
	AADD(aEmails, alltrim(cErrMessage))
	oData:SetValue('emails', aEmails)
	oUtil:ParamFileSave(cFileName, oData)
Return .F.
