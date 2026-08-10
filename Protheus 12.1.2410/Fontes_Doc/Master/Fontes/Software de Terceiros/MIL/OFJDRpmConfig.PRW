#include 'totvs.ch'
#include 'OFJDRpmConfig.ch'

/*/{Protheus.doc} OFJDRpmConfig
	Classe que vai adequar o novo ao antigo com relação a configuração de DPM
	ou seja, se tem a configuração nova vai jogar para a classe nova OFJDConfig
	caso contrário vai usar a DMS_DPM que vem do VEICLSAD.PRW
	
	@type class
	@author Vinicius Gati
	@since 19/06/2024
/*/
Class OFJDRpmConfig from DMS_DPM
	Data lNovaConfiguracao
	Data oNovaConfiguracao
	Data oArrHlp
	Public Method New() CONSTRUCTOR
	Public Method GetAccount()
	Public Method GetPecGroups()
	Public Method GetFiliais()
	Public Method GetFilial()
	Public Method GetJdCode()
	Public Method GetOfiInMotivosVPRpm()
	Public Method GetBalInMotivosVPRpm()
	Public Method getTabelaDadosAdc()
	Public Method DebugMode()
	Public Method PodeGerarDelta()
	Public Method MostraEstoqueAoDigitar()
	Public Method CaminhoDosArquivos()
	Public Method CaminhoDeImportacao()
	Public Method EmailOrigem()
	Public Method EmailsDestino()
	Public Method Ready()
	Public Method SaldoDaPeca()
	Public Method SaldoTotalDaPeca()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type method
	@author Vinicius Gati
	@since 19/06/2024
/*/
Method New(lNovaConfig, oJdConfig) Class OFJDRpmConfig
	_Super:New()
	::lNovaConfiguracao := lNovaConfig
	if valtype(oJdConfig) == "O" // só pra ajudar nos mocks para testes
		::oNovaConfiguracao := oJdConfig
	else
		::oNovaConfiguracao := OFJDConfig():New()
	endif
	if valtype(lNovaConfig) == "L" // só pra ajudar nos mocks para testes
		::lNovaConfiguracao := lNovaConfig
	else
		::lNovaConfiguracao := ::oNovaConfiguracao:sendoUsada()
	endif
	If cPaisLoc == "BRA"
		::lNovaConfiguracao := .f. // TEMPORARIO até quando o OFIA503 for liberado no BRASIL
	EndIf
	::oArrHlp := DMS_ArrayHelper():New()
Return SELF

/*/{Protheus.doc} GetAccount
	Retorna o account da instalação do RPM

	@type method
	@author Vinicius Gati
	@since 09/09/2024
/*/
Method GetAccount() Class OFJDRpmConfig
	if ::lNovaConfiguracao
		return "'" + ::oNovaConfiguracao:GetAccount() + "'"
	endif
	Pergunte("ONJD06", .f.)
Return iif(empty(MV_PAR08), "000000", MV_PAR08)

/*/{Protheus.doc} GetOfiInMotivosVPRpm
	Retorna um in com os dados dos parametros MV_MIL0108 para venda perdida balcao e oficina

	@type method
	@author Vinicius Gati
	@since 01/07/2024
/*/
Method GetOfiInMotivosVPRpm() Class OFJDRpmConfig
	local oConfig := self:oNovaConfiguracao:GetConfig()
	local nX := 1
	local oMotivo
	local aMots := {}

	if ::lNovaConfiguracao
		if valtype(oConfig["MOTIVOS_OFICINA"]) == "A" .and. len(oConfig["MOTIVOS_OFICINA"]) > 0
			for nX := 1 to len(oConfig["MOTIVOS_OFICINA"])
				oMotivo := oConfig["MOTIVOS_OFICINA"][nX]
				aadd(aMots,  oMotivo["MOTIVO"])
			next
			return "'" + self:oArrHlp:Join(aMots, "','") + "'"
		endif
		return "'-'"
	endif
Return _Super:GetOfiInMotivosVPRpm()

/*/{Protheus.doc} GetBalInMotivosVPRpm
	Retorna um in com os dados de parametro MV_MIL0032 para venda perdida balcao

	@type method
	@author Vinicius Gati
	@since 01/07/2024
/*/
Method GetBalInMotivosVPRpm() Class OFJDRpmConfig
	local oConfig := self:oNovaConfiguracao:GetConfig()
	local nX := 1
	local oMotivo
	local aMots := {}

	if ::lNovaConfiguracao
		if valtype(oConfig["MOTIVOS_BALCAO"]) == "A" .and. len(oConfig["MOTIVOS_BALCAO"]) > 0
			for nX := 1 to len(oConfig["MOTIVOS_BALCAO"])
				oMotivo := oConfig["MOTIVOS_BALCAO"][nX]
				aadd(aMots,  oMotivo["MOTIVO"])
			next
			Return "'" + self:oArrHlp:Join(aMots, "','") + "'"
		endif
		return "'-'"
	endif
Return _Super:GetBalInMotivosVPRpm()

/*/{Protheus.doc} GetPecGroups
	A ideia é um dia remover o BM_VAIDPM por completo do DMS visto que é um campo não existente na totvs
	porém por compatibilidade inicialmente vamos manter e gravar o mesmo durante a adequação da america latina
/*/
Method GetPecGroups() Class OFJDRpmConfig
	local aGrupos
	if ::lNovaConfiguracao
	aGrupos := ::oNovaConfiguracao:GetValue("GRUPOS_DE_PECAS")
		return ::oArrHlp:Map(aGrupos, {|g| g["GRUPO_PECA"] })
	endif
Return _Super:GetPecGroups()

/*/{Protheus.doc} GetFiliais

/*/
Method GetFiliais() Class OFJDRpmConfig
	local aFils
	if ::lNovaConfiguracao
		aFils := ::oNovaConfiguracao:GetValue("FILIAIS")
		return ::oArrHlp:Map(aFils, { |f| { f["FILIAL"], f["DEALER_CODE"], f["SEGMENTO"], f["PRINCIPAL"]  } })
	endif
Return _Super:GetFiliais()

/*/{Protheus.doc} GetFilial

/*/
Method GetFilial(cDealerCode) Class OFJDRpmConfig
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:GetFilialByDealerCode(cDealerCode)
	endif
Return _Super:GetFilial(cDealerCode)

/*/{Protheus.doc} GetJdCode

/*/
Method GetJdCode(cFlal, cSegmento) Class OFJDRpmConfig
	default cSegmento := "2" // ambos
	if ::lNovaConfiguracao
		if empty(cSegmento)
			FMX_HELP("RPM001", STR0003) //"Segmento obrigatório quando utilizando nova configuração do RPM"
		endif
		return ::oNovaConfiguracao:GetJdCode(cFlal, cSegmento)
	endif
Return _Super:GetJdCode(cFlal)

/*/{Protheus.doc} getTabelaDadosAdc

	@type method
	@author Vinicius Gati
	@since 28/06/2024
/*/
Method getTabelaDadosAdc() Class OFJDRpmConfig
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:getTabelaDadosAdc()
	endif
Return _Super:getTabelaDadosAdc()

/*/{Protheus.doc} DebugMode
	@type method
	@author Vinicius Gati
	@since 03/07/2024
/*/
Method DebugMode() Class OFJDRpmConfig
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:DebugMode()
	endif
Return _Super:DebugMode()

/*/{Protheus.doc} PodeGerarDelta
	Retorna se pode gerar delta na instalação do RPM

	@type method
	@author Vinicius Gati
	@since 10/07/2024
/*/
Method PodeGerarDelta() Class OFJDRpmConfig
	local oDpe
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:PodeGerarDelta()
	endif
	oDpe := DMS_DPMDPE_1_3():New()
Return oDpe:canGenDelta()

/*/{Protheus.doc} MostraEstoqueAoDigitar
	Antigo parametro MVMIL0011 para controle de NA

	@type method
	@author Vinicius Gati
	@since 10/07/2024
/*/
Method MostraEstoqueAoDigitar() Class OFJDRpmConfig
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:MostraEstoqueAoDigitar()
	endif
Return GetNewPar("MV_MIL0011","0") == "0"

/*/{Protheus.doc} CaminhoDosArquivos

	@type method
	@author Vinicius Gati
	@since 10/07/2024
/*/
Method CaminhoDosArquivos(cGroup) Class OFJDRpmConfig
	default cGroup := "SCHEDULER"
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:CaminhoDosArquivos()
	endif

	oDpm := DMS_DPMConfig():New(cGroup)
Return oDpm:GetPath()

/*/{Protheus.doc} CaminhoDeImportacao
	caminho de importacao de arquivos para RPM

	@type method
	@author Vinicius Gati
	@since 10/07/2024
/*/
Method CaminhoDeImportacao() Class OFJDRpmConfig
	default cGroup := "SCHEDULER"
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:CaminhoDeImportacao()
	endif

	oDpm := DMS_DPMConfig():New(cGroup)
Return oDpm:GetPathImp()

/*/{Protheus.doc} EmailOrigem
	Email de origem das comunicações do RPM

	@type method
	@author Vinicius Gati
	@since 10/07/2024
/*/
Method EmailOrigem(cWHJdCode) Class OFJDRpmConfig
	default cWHJdCode := ""
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:EmailOrigem(cWHJdCode)
	endif
Return GetNewPar("MV_MIL0088", "")


/*/{Protheus.doc} EmailsDestino
	Destinatários das comunicações do RPM

	@type method
	@author Vinicius Gati
	@since 10/07/2024
/*/
Method EmailsDestino(cWHJdCode) Class OFJDRpmConfig
	default cWHJdCode := ""
	if ::lNovaConfiguracao
		return ::oNovaConfiguracao:EmailsDestino(cWHJdCode)
	endif
Return cValToChar(GetNewPar("MV_MIL0089", ""))

/*/{Protheus.doc} Ready
	Criado por compatibilidade, porém será removida em breve para argentina
	a VQ3 não pode mais sem usada nem mencionada nos fontes após argentina

	@type function
	@author Vinicius Gati
	@since 10/07/2024
/*/
Method Ready(lSendMail) Class OFJDRpmConfig
	local cMsg := "Base VQ3 não transferida para VB8 completamente, por favor rode o OFINJD45 para completar o processo."
	local nQtdToImp := FM_SQL("SELECT COUNT(*) FROM " + RetSqlName('VQ3') + " WHERE VQ3_TIPREG in ('C','N',' ') AND D_E_L_E_T_ = ' ' ")
	Default lSendMail := .T.
	if nQtdToImp > 0
		self:cLastError := cMsg
		if lSendMail
			oEmail := DMS_EmailHelper():New()
			oEmail:SendTemplate({;
				{'template'           , 'mil_sys_err'                                               },;
				{'origem'             , self:EmailOrigem()                                          },;
				{'destino'            , self:EmailsDestino()                                        },;
				{'assunto'            , "[DPM] problema detectado " + dtoc(DATE()) + " " + TIME()   },;
				{':titulo'            , "[DPM] problema detectado " + dtoc(DATE()) + " " + TIME()   },;
				{':cabecalho1'        , "O DPM detectou um problema:"                               },;
				{':dados_cabecalho1'  , cMsg                                                        } ;
			})
		endif
		conout('################################')
		conout('######|  _ \|  _ \|  \/  |######')
		conout('######| | | | |_) | |\/| |######')
		conout('######| |_| |  __/| |  | |######')
		conout('######|____/|_|   |_|  |_|######')
		conout('################################')
		conout(cMsg)
		return .F.
	endif
Return .T.

/*/{Protheus.doc} SaldoDaPeca
	Retornará o saldo da peça de acordo com o armazem
	Não usa mais o segmento devido a mudança de entendimento, pensavamos em fazer uma soma dos locais do segmento mas não é assim,
	é realmente tudo separado.

	A principio deixarei os parametros pois se mudar algo novamente temos todos os parametros necessários

	@type method
	@author Vinicius Gati
	@since 31/07/2024
/*/
Method SaldoDaPeca(cB1COD, cSegmto, lSomenteVenda, cFlal, cLocal) Class OFJDRpmConfig
	local cQuery := ""
	local nSaldo := 0
	local cAl
	local cBckFlal := cFilAnt
	Local aArea     := sGetArea()
	default cFlal := cFilAnt
	default lSomenteVenda := .F.
	default cLocal := ""

	cFilAnt := cFlal

	cAl := GetNextAlias()
	cQuery := " SELECT SB2.R_E_C_N_O_ AS B2RECNO"
	cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
	cQuery += " JOIN " + RetSqlName('NNR') + " NNR ON NNR.NNR_FILIAL = '" + xFilial('NNR') + "' "
	cQuery += "  AND NNR.NNR_CODIGO = SB2.B2_LOCAL "
	cQuery += "  AND NNR.D_E_L_E_T_ = ' ' "
	if lSomenteVenda
		cQuery += " AND NNR.NNR_VDADMS = '1' "
	endif
	cQuery += " WHERE SB2.B2_FILIAL = '" + xFilial('SB2') + "' "
	cQuery += "   AND SB2.B2_COD   = '" + cB1COD + "' "
	cQuery += "   AND SB2.B2_LOCAL = '" + cLocal + "' "
	cQuery += "   AND SB2.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
	While !(cAl)->(Eof())
		SB2->(DbGoto((cAl)->B2RECNO))
		nSaldo += SaldoSB2()
		(cAl)->(DbSkip())
	EndDo

	(cAl)->(DbCloseArea())

	DbSelectArea(aArea[1,1]) //Posiciona no primeiro Alias
	sRestArea( aArea )
	cFilAnt := cBckFlal
Return nSaldo

/*/{Protheus.doc} SaldoTotalDaPeca
	pega o saldo do local de venda sem considerar segmento, isso é usado para mostrar o saldo corretamente na tela
	quando nao envolve saldo para nivel de atendimento.

	Entenda uma coisa é o saldo para NA que deve considerar segmento, a outra é o saldo da peça geral para
	informação somente, pois independente do NA o saldo existe.

	@type method
	@author Vinicius Gati
	@since 23/10/2024
/*/
Method SaldoTotalDaPeca(cB1COD, cFlal, cLocal) Class OFJDRpmConfig
	local cQuery := ""
	local nSaldo := 0
	local cBckFlal := cFilAnt
	default cFlal := cFilAnt
	default cLocal := ""

	cFilAnt := cFlal

	if ::lNovaConfiguracao
		if empty(cLocal)
			FMX_HELP("RPMCFGERR01", STR0001, STR0002) //"Favor atualizar os modulos DMS para que funcionem corretamente com a configuração utilizada"
			return 0
		endif

		cQuery := " SELECT SB2.R_E_C_N_O_ AS B2RECNO"
		cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
		cQuery += " WHERE SB2.B2_FILIAL = '" + xFilial('SB2') + "' 
		cQuery += "   AND SB2.B2_COD = '" + cB1COD + "' "
		cQuery += "   AND SB2.B2_LOCAL in ('" + cLocal + "') "
		cQuery += "   AND SB2.D_E_L_E_T_ = ' ' "
		nRecno := FM_SQL(cQuery)
		SB2->(DbGoto(nRecno))
		nSaldo := SaldoSB2()
	else
		FMX_HELP("RPMCFGERR01", STR0001, STR0002) //"Favor atualizar os modulos DMS para que funcionem corretamente com a configuração utilizada"
	endif

	dbselectArea("SB1")
	cFilAnt := cBckFlal
Return nSaldo