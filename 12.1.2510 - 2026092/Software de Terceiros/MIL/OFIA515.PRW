#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'OFIA515.CH'

/*/{Protheus.doc} OFIA515
	Importacao de arquivos DPM por conta
	Importa arquivos DPMSCHED, DPMXFER e DPMORD do caminho
	configurado para cada conta RPM.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OFIA515(aParam)
	Local nX := 1
	Private oUtil           := DMS_Util():New()
	Private oSqlHlp         := DMS_SqlHelper():New()
	Private oArHlp          := DMS_ArrayHelper():New()
	Private oLogger         := DMS_Logger():New("OFIA515.LOG")
	Private oDpm            := OFJDRpmConfig():New()
	Private lIsDebug        := "OFIA515" $ GetNewPar("MV_MILDBG", "NAO") .OR. "*DPM*" $ GetNewPar("MV_MILDBG", "NAO")
	Private lForcSch        := "OFIA515SCH" $ GetNewPar("MV_MILDBG", "NAO")
	Private lProcForce      := lIsDebug .AND. "FORCE" $ GetNewPar("MV_MILDBG", "NAO")
	Private cTblLogCod
	Private lNovoCombo      := GetNewPar("MV_MIL0210", .F.)
	Private lDebug := .T.

	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ INICIANDO OFIA515 ~~~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if ! lNovoCombo
		UserException(STR0001) /* "Somente clientes combo podem executar esta rotina." */
	endif

	if ! oDpm:Ready(.F.)
		if ! isBlind()
			MsgInfo(oDpm:cLastError, STR0002) /* "Informacao" */
		endif
		Return .F.
	endif

	cLock := "OFIA515_" + DToS(Date())
	If !LockByName(cLock, .T., .F.)
		cTblLogCod := oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'OFIA515'                                      },;
			{'VQL_TIPO'       , 'LOG_EXECUCAO'                                 },;
			{'VQL_DADOS'      , 'MODO:' + IIF(isBlind(), "Agendado", "Normal") + STR0018 /*" Cancelado: Outro processo em andamento."*/ } ;
		})
		oLogger:CloseOpened(cTblLogCod)
		conout('OFIA515 MODO:' + IIF(isBlind(), "Agendado", "Normal") + STR0018 /*" Cancelado: Outro processo em andamento."*/)
		Return .T.
	EndIf

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFIA515'                                      },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                                 },;
		{'VQL_DADOS'      , 'MODO:' + IIF(isBlind(), "Agendado", "Normal") } ;
	})

	aContas := OA5120074_BuscaContasRPM()
	for nX := 1 to len(aContas)
		OA5150024_ImportaArquivos(aContas[nX], oLogger, cTblLogCod)
	next

	oLogger:CloseOpened(cTblLogCod)
	UnlockByName(cLock, .T. , .T. , .T. )

	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ FINALIZANDO OFIA515 ~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
Return

/*/{Protheus.doc} SchedDef
	Funo padro scheduler

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

/*/{Protheus.doc} OA5150024_ImportaArquivos
	Importa arquivos para uma conta especifica

	Busca arquivos DPMSCHED, DPMXFER e DPMORD no caminho
	de importacao configurado para a conta e processa cada um.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OA5150024_ImportaArquivos(cConta, oLogger, cTblLogCod)
	Local nIdx  := 1
	Local oJdConfig := OFJDConfig():New(, cConta)
	Local cPath := oJdConfig:CaminhoDeImportacao()
	Local aArquivos := ""
	Local oBckBlk  := ErrorBlock()
	Local aFils := oJdConfig:GetFiliais()
	Default oLogger := DMS_Logger():New()
	Default cTblLogCod := "OFIA515"

	if len(aFils) == 0
		return .F.
	endif

	jFil := aFils[1]
	cFilAnt := jFil["FILIAL"] // só pra setar uma filial da conta qualquer pois pode ser que pega grupo diferente dependendo da config

	conout(STR0005 + cConta + "' no caminho: " + cPath + ALLTRIM(" \ "))

	aArquivos := Directory(strtran(cPath + ALLTRIM(" \ ") + "JD2DLR_DPMSCHED_*.DAT", "//", "/"),,nil, .T.)
	if LEN( aArquivos ) > 0
		conout(STR0006 + cValToChar(len(aArquivos)) + STR0007 + cConta) //  "Encontrados: "" arquivos. CONTA - "
		for nIdx := 1 to LEN(aArquivos)
			aArqData := aArquivos[nIdx]
			If "JD2DLR_DPMSCHED_" $ aArqData[1];
				.AND. FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+cConta+"' AND VQL_TIPO = 'DPMSCHED_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
				FT_FUse( cPath + ALLTRIM(" \ ") + aArqData[1] )
				cArqCtnt := FT_FReadLn()
				FT_FUse()
				OA5150074_ImportaDPMSCHED(cConta, cArqCtnt, aArqData, cPath, oLogger, cTblLogCod)
			EndIf
		next
	endif

	aArquivos := Directory(strtran(cPath + ALLTRIM(" \ ") + "JD2DLR_DPMXFER_*.DAT", "//", "/"),,nil, .T.)
	if LEN( aArquivos ) > 0
		conout(STR0006 + cValToChar(len(aArquivos)) + " arquivos. CONTA - " + cConta)
		for nIdx := 1 to LEN(aArquivos)
			aArqData := aArquivos[nIdx]
			If FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+cConta+"' AND VQL_TIPO = 'DPMXFER_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
				OA5150064_ImportaDPMXFE(cConta, cPath, aArqData)
			EndIf
		next
	endif

	aArquivos := Directory(strtran(cPath + ALLTRIM(" \ ") + "JD2DLR_DPMORD_*.DAT", "//", "/"),,nil, .T.)
	if LEN( aArquivos ) > 0
		conout(STR0006 + cValToChar(len(aArquivos)) + " arquivos. CONTA - " + cConta)
		for nIdx := 1 to LEN(aArquivos)
			aArqData := aArquivos[nIdx]
			If FM_SQL(" SELECT count(*) FROM " + RetSqlName('VQL') + " WHERE VQL_AGROUP = '"+cConta+"' AND VQL_TIPO = 'DPMORD_IMP' AND VQL_DADOS = '"+aArqData[1]+"' AND D_E_L_E_T_ = '' ") == 0
				OA5150054_ImportaDPMORD(cConta, cPath, aArqData)
			EndIf
		next
	endif

	ErrorBlock(oBckBlk)
Return

/*/{Protheus.doc} OA5150054_ImportaDPMORD
	Importacao do arquivo de orders (DPMORD)

	Le o arquivo, valida via DMS_DPMOrders e efetiva em transacao.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OA5150054_ImportaDPMORD(cConta, cPath, aArqData)
	local oOrders
	Local oBckBlk  := ErrorBlock()

	ErrorBlock({ |e| ;
		OA5150084_EnviaEmailDeErro( CRLF + "Erro: " + e:Description + CRLF + ;
									 "Stacktrace: " + e:Errorstack ),;
		KillApp(.t.);
	})
	BEGIN TRANSACTION
		oOrders := DMS_DPMOrders():New( cPath , aArqData[1], cConta )
		If oOrders:AllOk()
			if oOrders:Efetivar()
				conout(STR0009)
				FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
			Else
				conout(STR0010)
			EndIf
		EndIf
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.

/*/{Protheus.doc} OA5150064_ImportaDPMXFE
	Importacao do arquivo de transferencias (DPMXFER)

	Le o arquivo, valida via DMS_DPMXFers e efetiva em transacao.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OA5150064_ImportaDPMXFE(cConta, cPath, aArqData)
	local oXFer
	Local oBckBlk  := ErrorBlock()

	ErrorBlock({ |e| ;
		OA5150084_EnviaEmailDeErro(e:Description),;
		KillApp(.t.);
	})
	BEGIN TRANSACTION
		oXFer := DMS_DPMXFers():New( cPath , aArqData[1], cConta )
		If oXFer:AllOk()
			if oXFer:Efetivar()
				conout(STR0011)
				FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
			Else
				conout(STR0012)
			EndIf
		Else
			conout(STR0013 + cPath + ALLTRIM(" \ ") + aArqData[1])
		EndIf
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.

/*/{Protheus.doc} OA5150074_ImportaDPMSCHED
	Importacao do arquivo de scheduler (DPMSCHED)

	Registra o arquivo no VQL, atualiza as geracoes via
	DMS_DPMSched:UpdateGers e renomeia o arquivo como importado.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OA5150074_ImportaDPMSCHED(cConta, cArqCtnt, aArqData, cPath, oLogger, cTblLogCod)
	Local oBckBlk  := ErrorBlock()
	Default oLogger  := DMS_Logger():New()
	Default cTblLogCod := "OFIA515"

	ErrorBlock({ |e| ;
		OA5150084_EnviaEmailDeErro(e:Description),;
		killapp(.t.);
	})
	BEGIN TRANSACTION
		cVQLFN := oLogger:LogToTable({;
			{'VQL_AGROUP' , cConta         },;
			{'VQL_CODVQL' , cTblLogCod     },;
			{'VQL_TIPO'   , 'DPMSCHED_IMP' },;
			{'VQL_DADOS'  , aArqData[1]    } ;
		})
		cVQLFN := oLogger:LogToTable({;
			{'VQL_AGROUP' , cConta          },;
			{'VQL_CODVQL' , cVQLFN          },;
			{'VQL_TIPO'   , 'DPMSCHED_FILE' },;
			{'VQL_DADOS'  , cArqCtnt        } ;
		})

		oSched  := DMS_DPMSched():New(cConta)
		oSched:UpdateGers(.T.)

		nStatus := FRenameEx(cPath + aArqData[1], cPath + "IMPORTADO_" + aArqData[1])
		IF nStatus == -1
			conout(STR0014 + str(ferror(),4))
		Endif
	END TRANSACTION

	ErrorBlock(oBckBlk)
Return .T.

/*/{Protheus.doc} OA5150084_EnviaEmailDeErro
	Envia email de erro do sistema

	Tenta recuperar erros de alias inexistente e envia email
	com template mil_sys_err, com deduplicacao por hora.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OA5150084_EnviaEmailDeErro(cErrMessage)
	Local oEmailHlp := DMS_EmailHelper():New()
	Local nIdxEr    := AT(cErrMessage, "Alias does not exist ")
	Local cTabela   := ""

	conout(STR0015 + cErrMessage)

	if nIdxEr > 0
		cTabela := SUBSTR(cErrMessage, nIdxEr + 21,  3)
		dbSelectArea(cTabela)
		conout(STR0016 + cTabela)
	else
		cErrMessage := FwNoAccent(cErrMessage)
		if ! OA5150094_JaEnviouEmail(cErrMessage)
			conout(cErrMessage)
			/* "Erro de sistema detectado em " */
			/* "Erro de sistema detectado em " */
			/* "Lamentamos o ocorrido, seguem detalhes do mesmo:" */
			oEmailHlp:SendTemplate({;
				{'template'           , 'mil_sys_err'                                                    },;
				{'origem'             , GetNewPar("MV_MIL0088", "")                                      },;
				{'destino'            , GetNewPar("MV_MIL0102", "")                                      },;
				{'assunto'            , STR0003 + dtoc(DATE()) + " " + TIME()                            },;
				{':titulo'            , STR0003 + dtoc(DATE()) + " " + TIME()                            },;
				{':cabecalho1'        , STR0004                                                          },;
				{':dados_cabecalho1'  , cErrMessage                                                      } ;
			})
		end
	end
Return .T.

/*/{Protheus.doc} OA5150094_JaEnviouEmail
	Verifica se o mesmo erro ja foi enviado por email nesta hora

	Evita bombardear a caixa de entrada com emails repetidos
	do mesmo assunto no mesmo intervalo de 1 hora.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OA5150094_JaEnviouEmail(cErrMessage)
	Local nIdx := 1
	Local oUtil := DMS_Util():New()
	Local cFileName := "OFIA515_EMAILS_"+DTOS(date())+left(strtran(TIME(), ':', ''), 2)+".log"
	Local aEmails

	oData   := oUtil:ParamFileOpen(cFileName)
	aEmails := oData:getValue('emails', {})

	if ! Empty(aEmails)
		for nIdx := 1 to LEN( aEmails )
			if alltrim(aEmails[nIdx]) == alltrim(FwNoAccent(cErrMessage))
				conout(STR0017)
				return .T.
			end
		end
	end
	AADD(aEmails, alltrim(cErrMessage))
	oData:SetValue('emails', aEmails)
	oUtil:ParamFileSave(cFileName, oData)
Return .F.
