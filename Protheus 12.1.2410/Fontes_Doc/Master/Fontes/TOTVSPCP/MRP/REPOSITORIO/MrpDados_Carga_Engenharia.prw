#INCLUDE "TOTVS.CH"
#INCLUDE 'MrpDados.ch'

//Alternativo
#DEFINE ALT_FILIAL    1
#DEFINE ALT_PRODUT    2
#DEFINE ALT_ALTERT    3
#DEFINE ALT_FATOR     4
#DEFINE ALT_TPFAT     5
#DEFINE ALT_ORDEM     6
#DEFINE ALT_DATA      7
#DEFINE TAM_ALT       7

//Calendário
#DEFINE CAL_FILIAL    1
#DEFINE CAL_DATA      2
#DEFINE CAL_HRINI     3
#DEFINE CAL_HRFIM     4
#DEFINE CAL_INTER     5
#DEFINE CAL_UTEIS     6
#DEFINE TAM_CAL       6

//Estrutura
#DEFINE EST_FILIAL    1
#DEFINE EST_CODPAI    2
#DEFINE EST_CODFIL    3
#DEFINE EST_QTD       4
#DEFINE EST_FANT      5
#DEFINE EST_TRT       6
#DEFINE EST_GRPOPC    7
#DEFINE EST_ITEOPC    8
#DEFINE EST_VLDINI    9
#DEFINE EST_VLDFIM   10
#DEFINE EST_REVINI   11
#DEFINE EST_REVFIM   12
#DEFINE EST_ALTERN   13
#DEFINE EST_FIXA     14
#DEFINE EST_POTEN    15
#DEFINE EST_PERDA    16
#DEFINE EST_QTDB     17
#DEFINE EST_OPERA    18
#DEFINE EST_ARMCON   19
#DEFINE TAM_EST      19

//Operações
#DEFINE OPE_ROTE      1
#DEFINE OPE_OPERA     2
#DEFINE TAM_OPE       2

//Produtos
#DEFINE PRD_FILIAL    1
#DEFINE PRD_COD       2
#DEFINE PRD_ESTSEG    3
#DEFINE PRD_LE        4 //Lote econômico
#DEFINE PRD_PE        5
#DEFINE PRD_SLDDIS    6
#DEFINE PRD_NIVEST    7
#DEFINE PRD_CHAVE2    8
#DEFINE PRD_NPERAT    9
#DEFINE PRD_NPERMA   10 //Ultimo periodo permitido calcular - limitacao de bloqueio
#DEFINE PRD_THREAD   11
#DEFINE PRD_NPERCA   12 //Ultimo periodo calculado
#DEFINE PRD_REINIC   13
#DEFINE PRD_IDOPC    14
#DEFINE PRD_HORFIR   15
#DEFINE PRD_TPHOFI   16
#DEFINE PRD_DTHOFI   17
#DEFINE PRD_TIPE     18
#DEFINE PRD_PPED     19
#DEFINE PRD_REVATU   20
#DEFINE PRD_TIPDEC   21
#DEFINE PRD_NUMDEC   22
#DEFINE PRD_ROTEIR   23
#DEFINE PRD_QTEMB    24 //Qtd. Embalagem
#DEFINE PRD_LM       25 //Lote Mínimo
#DEFINE PRD_TOLER    26 //Tolerância
#DEFINE PRD_TIPO     27
#DEFINE PRD_GRUPO    28
#DEFINE PRD_RASTRO   29
#DEFINE PRD_MRP      30
#DEFINE PRD_EMAX     31
#DEFINE PRD_PROSBP   32
#DEFINE PRD_LOTSBP   33
#DEFINE PRD_ESTORI   34
#DEFINE PRD_APROPR   35
#DEFINE PRD_LOTVNC   36
#DEFINE PRD_CPOTEN   37
#DEFINE PRD_BLOQUE   38
#DEFINE PRD_LSUBPR   39
#DEFINE PRD_MOD      40
#DEFINE PRD_LOCPAD   41
#DEFINE PRD_LTTRAN   42
#DEFINE PRD_CALCES   43
#DEFINE PRD_AGLUT    44
#DEFINE PRD_QB       45
#DEFINE PRD_TRANSF   46
#DEFINE PRD_FILCOM   47
#DEFINE PRD_CALENS   48
#DEFINE PRD_LMTRAN   49
#DEFINE TAM_PRD      49

//Versão da Produção
#DEFINE VDP_FILIAL    1
#DEFINE VDP_PROD      2
#DEFINE VDP_DTINI     3
#DEFINE VDP_DTFIN     4
#DEFINE VDP_QNTDE     5
#DEFINE VDP_QNTATE    6
#DEFINE VDP_REV       7
#DEFINE VDP_ROTEIRO   8
#DEFINE VDP_LOCAL     9
#DEFINE VDP_CODIGO   10
#DEFINE TAM_VDP      10

Static _lFldLoTMI := Nil
Static _lFldTraMI := Nil
Static _lFieldsQB := Nil
Static _oTpAglPrd := Nil

/*/{Protheus.doc} MrpDados_Carga_Engenharia
Classe para carregar os dados em memoria (Engenharia)

@author marcelo.neumann
@since 15/04/2021
@version 1
/*/
CLASS MrpDados_Carga_Engenharia FROM LongNameClass

	DATA lCal_Ok      AS LOGICAL
	DATA lEst_Ok      AS LOGICAL
	DATA lPrd_Ok      AS LOGICAL
	DATA lSub_Ok      AS LOGICAL
	DATA lVDP_Ok      AS LOGICAL
	DATA lIdentPrd_Ok AS LOGICAL
	DATA oCarga       AS OBJECT

	METHOD new() CONSTRUCTOR

	METHOD cargaFinalizada()
	METHOD getPerCarInicial(oDados)
	METHOD getPerCarga(oDados)

	METHOD calendario()
	METHOD estruturas()
	METHOD identificaProdutos()
	METHOD produtos()
	METHOD subprodutos()
	METHOD versaoDaProducao()

	Static METHOD tipoPeriodoAglutinaProduto(cTipoAglut)

ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe MrpDados_Carga_Engenharia

@author marcelo.neumann
@since 15/04/2021
@version 1
@param oCarga, objeto, instância da classe principal MrpDados_CargaMemoria
@return Self , objeto, instância do objeto MrpDados_Carga_Engenharia criado
/*/
METHOD new(oCarga) CLASS MrpDados_Carga_Engenharia

	Self:oCarga       := oCarga
	Self:lCal_Ok      := .F.
	Self:lEst_Ok      := .F.
	Self:lPrd_Ok      := .F.
	Self:lSub_Ok      := .F.
	Self:lVDP_Ok      := .F.
	Self:lIdentPrd_Ok := .F.

Return Self

/*/{Protheus.doc} getPerCarInicial
Retorna a quantidade de registros que serão carregados na carga inicial

@author marcelo.neumann
@since 19/04/2021
@version 1
@param oDados   , objeto  , intância do objeto de Dados
@return nPercent, numérico, percentual da carga
/*/
METHOD getPerCarInicial(oDados) CLASS MrpDados_Carga_Engenharia
	Local nLidos   := 0
	Local nPercent := 0
	Local nQuant   := 0
	Local nTotal   := 0

	nQuant := oDados:oEstruturas:getflag("qtd_registros_total")
	If nQuant <> Nil
		nTotal += nQuant
		nQuant := oDados:oEstruturas:getflag("qtd_registros_total_operacoes")

		If nQuant <> Nil
			nTotal += nQuant

			nQuant := oDados:oEstruturas:getflag("qtd_registros_lidos")
			If nQuant <> Nil
				nLidos += nQuant
			EndIf

			nQuant := oDados:oEstruturas:getflag("qtd_registros_lidos_operacoes")
			If nQuant <> Nil
				nLidos += nQuant
			EndIf

			If nTotal == 0
				nPercent += 80
			Else
				nPercent += ((nLidos * 100) / nTotal) * 0.8
			EndIf
		EndIf
	EndIf

	nTotal := 0
	nLidos := 0
	nQuant := oDados:oSubprodutos:getflag("qtd_registros_total")
	If nQuant <> Nil
		nTotal += nQuant
		nQuant := oDados:oCalendario:getflag("qtd_registros_total")

		If nQuant <> Nil
			nTotal += nQuant
			nQuant := oDados:oVersaoDaProducao:getflag("qtd_registros_total")

			If nQuant <> Nil
				nTotal += nQuant
				nQuant := oDados:oSubprodutos:getflag("qtd_registros_lidos")
				If nQuant <> Nil
					nLidos += nQuant
				EndIf

				nQuant := oDados:oCalendario:getflag("qtd_registros_lidos")
				If nQuant <> Nil
					nLidos += nQuant
				EndIf

				nQuant := oDados:oVersaoDaProducao:getflag("qtd_registros_lidos")
				If nQuant <> Nil
					nLidos += nQuant
				EndIf

				If nTotal == 0
					nPercent += 20
				Else
					nPercent += ((nLidos * 100) / nTotal) * 0.2
				EndIf
			EndIf
		EndIf
	EndIf

Return nPercent

/*/{Protheus.doc} getPerCarga
Retorna a quantidade de registros que serão carregados na carga

@author marcelo.neumann
@since 19/04/2021
@version 1
@param oDados   , objeto  , intância do objeto de Dados
@return nPercent, numérico, percentual da carga
/*/
METHOD getPerCarga(oDados) CLASS MrpDados_Carga_Engenharia
	Local nLidos   := 0
	Local nPercent := 0
	Local nQuant   := 0
	Local nTotal   := 0

	nQuant := oDados:oProdutos:getflag("qtd_registros_total")
	If nQuant <> Nil
		nTotal += nQuant

		nQuant := oDados:oProdutos:getflag("qtd_registros_lidos")
		If nQuant <> Nil
			nLidos += nQuant
		EndIf

		If nTotal == 0
			nPercent += 100
		Else
			nPercent += (nLidos * 100) / nTotal
		EndIf
	EndIf

Return nPercent

/*/{Protheus.doc} cargaFinalizada
Indica se toda a carga dos dados de Engenharia foi finalizada

@author marcelo.neumann
@since 15/04/2021
@version 1
@return lRet, lógico, indica se a carga foi finalizada
/*/
METHOD cargaFinalizada() CLASS MrpDados_Carga_Engenharia
	Local lError := .F.

	If !Self:lPrd_Ok
		If Self:oCarga:oDados:oProdutos:getFlag("termino_carga", @lError) == "S"
			Self:lPrd_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lEst_Ok
		If Self:oCarga:oDados:oEstruturas:getFlag("termino_carga", @lError) == "S"
			Self:lEst_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lSub_Ok
		If Self:oCarga:oDados:oSubProdutos:getFlag("termino_carga", @lError) == "S"
			Self:lSub_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lCal_Ok
		If Self:oCarga:oDados:oCalendario:getFlag("termino_carga", @lError) == "S"
			Self:lCal_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lVDP_Ok
		If Self:oCarga:oDados:oVersaoDaProducao:getFlag("termino_carga_VDP", @lError) == "S"
			Self:lVDP_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lIdentPrd_Ok
		If Self:oCarga:utilizaCargaSeletiva()
			If Self:oCarga:oDados:oProdutos:getFlag("identificados_termino_carga", @lError) == "S"
				Self:lIdentPrd_Ok := .T.
			Else
				Return .F.
			EndIf
		Else
			Self:lIdentPrd_Ok := .T.
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} calendario
Carrega os dados do Calendário do MRP

@author marcelo.neumann
@since 31/03/2021
@version 1.0
/*/
METHOD calendario() CLASS MrpDados_Carga_Engenharia

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaCa", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaCa(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaCa
Processa a carga do Calendário do MRP

@author marcelo.neumann
@since 31/03/2021
@version 1.0
@param cTicket, caracter, número do ticket para processamento do MRP
/*/
Function MrpCargaCa(cTicket)
	Local aAux       := {}
	Local cAliasQry  := ""
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cOrder     := "%HW0.HW0_FILIAL, HW0.HW0_IDREG%"
	Local cQueryCon  := ""
	Local lLogAtivo  := .F.
	Local lUsaME     := .F.
	Local nIndex     := 0
	Local nIndRegs   := 0
	Local nTempoCarg := MicroSeconds()
	Local nTempoQry  := 0
	Local nTotal     := 0
	Local oDominio   := Nil
	Local oCarga     := Nil
	Local oCalendar  := Nil
	Local oLogs      := Nil
	Local oStatus    := Nil
	Local oMultiEmp  := Nil

	oDominio  := MRPPrepDom(cTicket)
	oCarga    := oDominio:oDados:oCargaMemoria
	oCalendar := oDominio:oDados:oCalendario
	oLogs     := oDominio:oDados:oLogs
	oStatus   := MrpDados_Status():New(cTicket)
	oMultiEmp := oDominio:oMultiEmp
	lLogAtivo := oLogs:logAtivado()

	//Busca os registros a serem processados
	If oStatus:preparaAmbiente(oDominio:oDados)
		lUsaME := oMultiEmp:utilizaMultiEmpresa()

		If lUsaME
			cQueryCon := "% ("
			For nIndex := 1 To oMultiEmp:totalDeFiliais()
				If nIndex > 1
					cQueryCon += " UNION "
				EndIf

				cQueryCon += " SELECT '" + oMultiEmp:filialPorIndice(nIndex) + "' HW0_FILIAL, "
				cQueryCon +=        " HW0.HW0_DATA, "
				cQueryCon +=        " HW0.HW0_HRINI, "
				cQueryCon +=        " HW0.HW0_HRFIM, "
				cQueryCon +=        " HW0.HW0_INTERV, "
				cQueryCon +=        " HW0.HW0_TOTH, "
				cQueryCon +=        " HW0.HW0_IDREG "
				cQueryCon +=   " FROM " + RetSqlName("HW0") + " HW0 "
				cQueryCon +=   " WHERE HW0.HW0_FILIAL = '" + xFilial("HW0", oMultiEmp:filialPorIndice(nIndex)) + "' "
				cQueryCon +=     " AND HW0.HW0_DATA  >= '" + DToS(oDominio:oParametros["dDataIni"]) + "'"
				cQueryCon +=     " AND HW0.D_E_L_E_T_ = ' ' "

				//Para as filiais centralizadas, adiciona um UNION na query para que caso o calendário
				//não esteja cadastrado na filial centralizada, recupere o cadastro de calendário
				//da filial centralizadora, e considera como calendário da filial centralizada.
				If nIndex > 1
					cQueryCon += " UNION "
					cQueryCon += " SELECT '" + oMultiEmp:filialPorIndice(nIndex) + "' HW0_FILIAL, "
					cQueryCon +=        " HW0AUX.HW0_DATA, "
					cQueryCon +=        " HW0AUX.HW0_HRINI, "
					cQueryCon +=        " HW0AUX.HW0_HRFIM, "
					cQueryCon +=        " HW0AUX.HW0_INTERV, "
					cQueryCon +=        " HW0AUX.HW0_TOTH, "
					cQueryCon +=        " HW0AUX.HW0_IDREG "
					cQueryCon +=   " FROM " + RetSqlName("HW0") + " HW0AUX "
					cQueryCon +=   " LEFT JOIN " + RetSqlName("HW0") + " HW0 "
					cQueryCon +=          " ON HW0.D_E_L_E_T_ = ' ' "
					cQueryCon +=         " AND HW0.HW0_DATA  >= '" + DToS(oDominio:oParametros["dDataIni"]) + "'"
					cQueryCon +=         " AND HW0.HW0_DATA   = HW0AUX.HW0_DATA "
					cQueryCon +=         " AND HW0.HW0_FILIAL = '" + xFilial("HW0", oMultiEmp:filialPorIndice(nIndex)) + "' "
					cQueryCon +=  " WHERE HW0AUX.D_E_L_E_T_ = ' ' "
					cQueryCon +=    " AND HW0AUX.HW0_DATA  >= '" + DToS(oDominio:oParametros["dDataIni"]) + "'"
					cQueryCon +=    " AND HW0AUX.HW0_FILIAL = '" + xFilial("HW0", oMultiEmp:filialPorIndice(1)) + "' "
					cQueryCon +=    " AND HW0.HW0_DATA IS NULL "
				EndIf

			Next nIndex

			cQueryCon += ") HW0 %"
		Else
			cQueryCon := "%" + RetSqlName("HW0") + " HW0"
			cQueryCon += " WHERE HW0.HW0_DATA  >= '" + DToS(oDominio:oParametros["dDataIni"]) + "'"
			cQueryCon +=   " AND HW0.HW0_FILIAL = '" + xFilial("HW0") + "' "
			cQueryCon +=   " AND HW0.D_E_L_E_T_ = ' '%"
		EndIf

		cFieldCnt := "%" + oCarga:trataOptimizerOracle() + " " + "COUNT(*) TOTAL%"

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Calendario (HW0)", {"Query totalizadora: SELECT " + SubStr(cFieldCnt, 2, Len(cFieldCnt)-2) + ;
			                                                                          " FROM " + SubStr(cQueryCon, 2, Len(cQueryCon)-2)})
		EndIf

		cAliasQry := GetNextAlias()
		nTempoQry := MicroSeconds()

		BeginSql Alias cAliasQry
		  SELECT %Exp:cFieldCnt%
		    FROM %Exp:cQueryCon%
		EndSql

		nTempoQry := MicroSeconds() - nTempoQry

		If (cAliasQry)->(!Eof())
			nTotal := (cAliasQry)->TOTAL
		EndIf
		(cAliasQry)->(dbCloseArea())

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Calendario (HW0)", {"Quantidade de registros: " + cValToChar(nTotal), ;
			                                                     "Tempo da query totalizadora: " + cValToChar(nTempoQry)})
		EndIf
	EndIf

	oCalendar:setFlag("qtd_registros_total", nTotal)
	oCalendar:setFlag("qtd_registros_lidos", 0     )

	If nTotal > 0
		aAux := Array(TAM_CAL)

		cFieldCnt := oCarga:trataOptimizerOracle()
		cFieldCnt += " HW0.HW0_FILIAL, "
		cFieldCnt += " HW0.HW0_DATA, "
		cFieldCnt += " HW0.HW0_HRINI, "
		cFieldCnt += " HW0.HW0_HRFIM, "
		cFieldCnt += " HW0.HW0_INTERV, "
		cFieldCnt += " HW0.HW0_TOTH "
		cFieldCnt := "%" + cFieldCnt + "%"

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Calendario (HW0)", {"Query principal: SELECT " + SubStr(cFieldCnt, 2, Len(cFieldCnt)-2) + ;
			                                                                       " FROM " + SubStr(cQueryCon, 2, Len(cQueryCon)-2) + ;
			                                                                      " ORDER BY " + SubStr(cOrder, 2, Len(cOrder)-2)})
			nTempoQry := MicroSeconds()
		EndIf

		BeginSql Alias cAliasQry
		  COLUMN HW0_DATA AS DATE
		  SELECT %Exp:cFieldCnt%
		    FROM %Exp:cQueryCon%
		   ORDER BY %Exp:cOrder%
		EndSql

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Calendario (HW0)", {"Tempo da query principal: " + cValToChar(MicroSeconds() - nTempoQry)})
		EndIf

		//Processa todos os registros encontrados
		While (cAliasQry)->(!Eof())
			nIndRegs++

			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
				oCalendar:setFlag("termino_carga", "S")
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAliasQry)->HW0_FILIAL, oMultiEmp:tamanhoFilial())
			EndIf

			cChave := cFilAux + DtoS((cAliasQry)->HW0_DATA)

			//Guarda o registro na Matriz
			If !oCalendar:getRow(1, cChave)
				aAux[CAL_FILIAL] := cFilAux
				aAux[CAL_DATA  ] := (cAliasQry)->HW0_DATA
				aAux[CAL_HRINI ] := (cAliasQry)->HW0_HRINI
				aAux[CAL_HRFIM ] := (cAliasQry)->HW0_HRFIM
				aAux[CAL_INTER ] := (cAliasQry)->HW0_INTERV
				aAux[CAL_UTEIS ] := (cAliasQry)->HW0_TOTH

				If !oCalendar:addRow(cChave, aAux)
					If oStatus:getStatus("status") == "4"
						Exit
					EndIf
				EndIf
			EndIf

			oCalendar:setFlag("qtd_registros_lidos", 1, , , .T.)
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	//Grava flag de conclusão global
	oCalendar:setFlag("termino_carga", "S")

	If lLogAtivo
		oLogs:gravaLog("carga_memoria", "Calendario (HW0)", {"Fim da carga. Tempo: " + cValToChar(MicroSeconds() - nTempoCarg)})
	EndIf

	//Limpa os arrays da memória
	aSize(aAux, 0)
	aAux := Nil

Return

/*/{Protheus.doc} estruturas
Carrega os dados das Estruturas

@author marcelo.neumann
@since 08/07/2019
@version 1.0
/*/
METHOD estruturas() CLASS MrpDados_Carga_Engenharia

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaEs", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaEs(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaEs
Processa a carga dos dados das Estruturas

@author marcelo.neumann
@since 08/07/2019
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpCargaEs(cTicket)
	Local aAuxAlt    := {}
	Local aAuxEst    := {}
	Local aNames     := {}
	Local aRetPE     := {}
	Local cAliasQry  := ""
	Local cChave     := ""
	Local cChavePais := ""
	Local cChvMinMax := ""
	Local cChvOpers  := ""
	Local cComp      := ""
	Local cProdPai   := ""
	Local cFields    := ""
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cFilBkp    := ""
	Local cProduto   := ""
	Local cQueryCon  := ""
	Local cOrder     := "%T4N.T4N_FILIAL%"
	Local lCompVld   := .F.
	Local lLogAtivo  := .F.
	Local lUsaME     := .F.
	Local lP712SQL   := ExistBlock("P712SQL")
	Local nIndRegs   := 1
	Local nTempoCarg := MicroSeconds()
	Local nTempoQry  := 0
	Local nTotalAlt  := 0
	Local nTotalEst  := 0
	Local nTotal     := 0
	Local nQtdLidos  := 0
	Local oAlternati := Nil
	Local oCarga     := Nil
	Local oChavesEst := Nil
	Local oDominio   := Nil
	Local oEstJson   := Nil
	Local oEstrutura := Nil
	Local oJsnMinMax := Nil
	Local oJsonOper  := JsonObject():New()
	Local oLogs      := Nil
	Local oProdsOPC  := JsonObject():New() //Armazena código de produto pai que possui algum componente vinculado com opcional
	Local oPaiComp   := JsonObject():New() //Armazena o código dos produtos pai de um componente.
	Local oMultiEmp  := Nil
	Local oStatus    := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket)
	oAlternati := oDominio:oDados:oAlternativos
	oCarga     := oDominio:oDados:oCargaMemoria
	oEstrutura := oDominio:oDados:oEstruturas
	oLogs      := oDominio:oDados:oLogs
	oStatus    := MrpDados_Status():New(cTicket)
	oMultiEmp  := oDominio:oMultiEmp
	lLogAtivo  := oLogs:logAtivado()

	//Busca os registros a serem processados
	If oStatus:preparaAmbiente(oDominio:oDados)

		lUsaME := oMultiEmp:utilizaMultiEmpresa()

		cFields := oCarga:trataOptimizerOracle()

		cFields += "T4N.T4N_FILIAL,T4N.T4N_PROD,T4N.T4N_COMP,T4N.T4N_QTD,T4N.T4N_QTDB,T4N.T4N_FANTAS,T4N.T4N_SEQ,T4N.T4N_GROPC,"
		cFields += "T4N.T4N_ITOPC,T4N.T4N_DTINI,T4N.T4N_DTFIM,T4N.T4N_REVINI,T4N.T4N_REVFIM,T4O.T4O_ESTOQ,T4N.T4N_FIXA,T4N.T4N_POTEN,"
		cFields += "T4N.T4N_PERDA,T4N.T4N_IDREG,T4O.T4O_ALTERN,T4O.T4O_FATCON,T4O.T4O_TPCONV,T4O.T4O_SEQ,T4O.T4O_DATA,T4N.T4N_ARMCON"

		cQueryCon := RetSqlName("T4N") + " T4N"
		cQueryCon += " LEFT OUTER JOIN " + RetSqlName("T4O") + " T4O"
		cQueryCon +=   " ON T4N.T4N_IDREG = T4O.T4O_IDEST"
		cQueryCon +=  " AND T4O.D_E_L_E_T_ = ' '"

		If oCarga:utilizaCargaSeletiva()
			cQueryCon += " AND " + oCarga:montaExistsSMM("T4O.T4O_ALTERN", cTicket)
			cQueryCon += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4O.T4O_ALTERN", .F., .T., .T., .F.)
		Else
			cQueryCon += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4O.T4O_ALTERN")
		EndIf

		If lUsaME
			cQueryCon += " AND T4O.T4O_FILIAL = T4N.T4N_FILIAL "
		Else
			cQueryCon += " AND T4O.T4O_FILIAL = '" + xFilial("T4O") + "' "
		EndIf

		cQueryCon += oCarga:montaJoinSMM("T4N.T4N_PROD", cTicket, "SMM_PAI")
		cQueryCon += oCarga:montaJoinSMM("T4N.T4N_COMP", cTicket, "SMM_COMP")

		cQueryCon += " WHERE T4N.D_E_L_E_T_ = ' ' "
		If !oCarga:utilizaCargaSeletiva()
			cQueryCon += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4N.T4N_COMP", .T.)
		EndIf
		If lUsaME
			cQueryCon += " AND " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		Else
			cQueryCon += " AND T4N.T4N_FILIAL = '" + xFilial("T4N") + "' "
		EndIf
		cQueryCon := "%" + cQueryCon + "%"

		cFields := "%" + cFields + "%"

		If lP712SQL
			aRetPE := ExecBlock("P712SQL", .F., .F., {"T4N",cFields,cQueryCon,cOrder})

			If aRetPE != Nil .And. Len(aRetPE) == 3
				cFields   := aRetPE[1]
				cQueryCon := aRetPE[2]
				cOrder    := aRetPE[3]
			EndIf
		EndIf

		cFieldCnt := "%" + oCarga:trataOptimizerOracle() + "COUNT(*) TOTAL%"

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Estruturas (T4N)", {"Query totalizadora: SELECT " + SubStr(cFieldCnt, 2, Len(cFieldCnt)-2) + ;
			                                                                          " FROM " + SubStr(cQueryCon, 2, Len(cQueryCon)-2)})
		EndIf

		cAliasQry := GetNextAlias()
		nTempoQry := MicroSeconds()

		BeginSql Alias cAliasQry
		  SELECT %Exp:cFieldCnt%
		    FROM %Exp:cQueryCon%
		EndSql

		nTempoQry := MicroSeconds() - nTempoQry

		If (cAliasQry)->(!Eof())
			nTotalEst := (cAliasQry)->TOTAL
			nTotalAlt := nTotalEst
		EndIf
		(cAliasQry)->(dbCloseArea())

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Estruturas (T4N)", {"Quantidade de registros: " + cValToChar(nTotalEst), ;
			                                                     "Tempo da query totalizadora: " + cValToChar(nTempoQry)})
		EndIf
	EndIf

	oEstrutura:setFlag("qtd_registros_total", nTotalEst)
	oEstrutura:setFlag("qtd_registros_lidos", 0)

	If nTotalEst > 0
		oEstJson   := JsonObject():New()
		oChavesEst := JsonObject():New()
		oJsnMinMax := JsonObject():New()
		aAuxEst    := Array(TAM_EST)
		aAuxAlt    := Array(TAM_ALT)

		If FwAliasInDic("HW9", .F.)
			oJsonOper := RetOperCmp(oDominio, cTicket) //Retorna Objeto Json de Operações por Componente
		Else
			oEstrutura:setFlag("qtd_registros_total_operacoes", 0)
			oEstrutura:setFlag("qtd_registros_lidos_operacoes", 0)
		EndIf

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Estruturas (T4N)", {"Query principal: SELECT " + SubStr(cFields, 2, Len(cFields)-2) + ;
			                                                                       " FROM " + SubStr(cQueryCon, 2, Len(cQueryCon)-2) + ;
			                                                                      " ORDER BY " + SubStr(cOrder, 2, Len(cOrder)-2)})
		EndIf

		cAliasQry := GetNextAlias()
		nTempoQry := MicroSeconds()

		BeginSql Alias cAliasQry
		  COLUMN T4N_DTINI AS DATE
		  COLUMN T4N_DTFIM AS DATE
		  COLUMN T4O_DATA  AS DATE
		  SELECT %Exp:cFields%
		    FROM %Exp:cQueryCon%
		   ORDER BY %Exp:cOrder%
		EndSql

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Estruturas (T4N)", {"Tempo da query principal: " + cValToChar(MicroSeconds() - nTempoQry)})
		EndIf

		While (cAliasQry)->(!Eof())

			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .Or. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .And. oStatus:getStatus("status") == "4"
				oEstrutura:setFlag("termino_carga", "S") //Grava flag de conclusao global
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAliasQry)->(T4N_FILIAL), oMultiEmp:tamanhoFilial())
			EndIf

			cComp     := PadR((cAliasQry)->(T4N_COMP), oCarga:nTamCod)
			cProdPai  := PadR((cAliasQry)->(T4N_PROD), oCarga:nTamCod)
			cChave    := cFilAux + RTrim((cAliasQry)->(T4N_IDREG))
			cChvOpers := cFilAux + cProdPai + cComp + RTrim((cAliasQry)->(T4N_SEQ)) //Produto + Componente + TRT
			lCompVld  := compValid((cAliasQry)->(T4N_DTFIM), oDominio:oParametros)

			//somente subirá para a memória componentes cuja data fim seja maior ou igual à data início do MRP
			If lCompVld
				cChavePais := cFilAux + cComp
				If !oPaiComp:HasProperty(cChavePais)
					oPaiComp[cChavePais] := JsonObject():New()
				EndIf
				oPaiComp[cChavePais][cFilAux + cProdPai] := 1

				If oChavesEst[cChave] == Nil .Or. oChavesEst[cChave]
					oChavesEst[cChave] := .F.

					aAuxEst[EST_FILIAL] := cFilAux
					aAuxEst[EST_CODPAI] := cProdPai
					aAuxEst[EST_CODFIL] := cComp
					aAuxEst[EST_QTD   ] := (cAliasQry)->(T4N_QTD)
					aAuxEst[EST_QTDB  ] := (cAliasQry)->(T4N_QTDB)
					aAuxEst[EST_FANT  ] := (cAliasQry)->(T4N_FANTAS) == "T"
					aAuxEst[EST_TRT   ] := RTrim((cAliasQry)->(T4N_SEQ))
					aAuxEst[EST_GRPOPC] := RTrim((cAliasQry)->(T4N_GROPC))
					aAuxEst[EST_ITEOPC] := RTrim((cAliasQry)->(T4N_ITOPC))
					aAuxEst[EST_VLDINI] := (cAliasQry)->(T4N_DTINI)
					aAuxEst[EST_VLDFIM] := (cAliasQry)->(T4N_DTFIM)
					aAuxEst[EST_REVINI] := RTrim((cAliasQry)->(T4N_REVINI))
					aAuxEst[EST_REVFIM] := RTrim((cAliasQry)->(T4N_REVFIM))
					aAuxEst[EST_ALTERN] := (cAliasQry)->(T4O_ESTOQ)
					aAuxEst[EST_FIXA  ] := (cAliasQry)->(T4N_FIXA)
					aAuxEst[EST_POTEN ] := (cAliasQry)->(T4N_POTEN)
					aAuxEst[EST_PERDA ] := (cAliasQry)->(T4N_PERDA)
					aAuxEst[EST_ARMCON] := RTrim((cAliasQry)->(T4N_ARMCON))

					If oJsonOper[cChvOpers] == Nil
						aAuxEst[EST_OPERA]   := {}
					Else
						aAuxEst[EST_OPERA]   := oJsonOper[cChvOpers]
					EndIf

					cChave := cFilAux + aAuxEst[EST_CODPAI]
					If oEstJson[cChave] == Nil
						oEstJson[cChave] := {}
					EndIf

					/*
						Até que seja desenvolvido as demais regras de alternativo para o multi-empresa,
						irá subir sempre fixo como o tipo 1 (padrão). Esta condição deve ser removida
						quando o desenvolvimento das regras de alternativos para multi-empresa for concluída.
					*/
					If lUsaME
						aAuxEst[EST_ALTERN] := "1"
					EndIf

					aAdd(oEstJson[cChave], aClone(aAuxEst))
				EndIf

				If !Empty((cAliasQry)->(T4O_ALTERN))
					aAuxAlt[ALT_FILIAL] := cFilAux
					aAuxAlt[ALT_PRODUT] := cComp
					aAuxAlt[ALT_ALTERT] := PadR((cAliasQry)->(T4O_ALTERN), oCarga:nTamCod)
					aAuxAlt[ALT_TPFAT]  := (cAliasQry)->(T4O_TPCONV)
					aAuxAlt[ALT_FATOR]  := (cAliasQry)->(T4O_FATCON)
					aAuxAlt[ALT_ORDEM]  := Upper(RTrim((cAliasQry)->(T4O_SEQ)))
					aAuxAlt[ALT_DATA]   := (cAliasQry)->(T4O_DATA)

					If oJsnMinMax[cFilAux+cComp] == Nil
						oJsnMinMax[cFilAux+cComp] := {"", ""} //MIN, MAX
					EndIf

					//Registra Menor e Maior Sequência
					If cFilBkp+cProduto != cFilAux+cComp .AND. !Empty(oJsnMinMax[cFilBkp+cProduto])
						oDominio:oDados:oAlternativos:setItemAList("min_max", cFilBkp+cProduto, oJsnMinMax[cFilBkp+cProduto], .F., .T., .F.)
					EndIf

					//Identifica Menor e Maior Sequência
					cFilBkp                   := cFilAux
					cProduto                  := cComp
					cChvMinMax                := cFilBkp+cProduto
					oJsnMinMax[cChvMinMax][1] := Iif(oJsnMinMax[cChvMinMax][1] == "" .OR. oJsnMinMax[cChvMinMax][1] > aAuxAlt[ALT_ORDEM], aAuxAlt[ALT_ORDEM], oJsnMinMax[cChvMinMax][1])
					oJsnMinMax[cChvMinMax][2] := Iif(oJsnMinMax[cChvMinMax][2] == "" .OR. oJsnMinMax[cChvMinMax][2] < aAuxAlt[ALT_ORDEM], aAuxAlt[ALT_ORDEM], oJsnMinMax[cChvMinMax][2])

					cChave := cFilAux + cComp + aAuxAlt[ALT_ORDEM]
					If !oAlternati:getRow(1, cChave, Nil)
						If !oAlternati:addRow(cChave, aAuxAlt)
							If oStatus:getStatus("status") == "4"
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If !Empty((cAliasQry)->T4N_GROPC) .And. lCompVld
				oProdsOPC[cFilAux + cProdPai] := .T.
			EndIf

			oEstrutura:setFlag("qtd_registros_lidos", @nQtdLidos, , , ,.T.)

			nIndRegs++
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())

		aNames    := oEstJson:GetNames()
		nTotalEst := Len(aNames)

		For nIndRegs := 1 to nTotalEst
			If !oEstrutura:addRow(aNames[nIndRegs], oEstJson[aNames[nIndRegs]])
				If oStatus:getStatus("status") == "4"
					Exit
				EndIf
			EndIf
			aSize(oEstJson[aNames[nIndRegs]], 0)
		Next
		aSize(aNames, 0)

		//Registra Menor e Maior Sequência
		If !Empty(cChvMinMax) .AND. !Empty(oJsnMinMax[cChvMinMax])
			oDominio:oDados:oAlternativos:setItemAList("min_max", cChvMinMax, oJsnMinMax[cChvMinMax], .F., .T., .F.)
		EndIf

		aNames := oJsnMinMax:GetNames()
		nTotal := Len(aNames)
		For nIndRegs := 1 to nTotal
			IF oJsnMinMax[aNames[nIndRegs]] != Nil
				aSize(oJsnMinMax[aNames[nIndRegs]], 0)
				oJsnMinMax[aNames[nIndRegs]] := Nil
			EndIf
		Next nIndRegs
		aSize(aNames, 0)
		FreeObj(oJsnMinMax)

		aNames := oJsonOper:GetNames()
		nTotal := Len(aNames)
		For nIndRegs := 1 to nTotal
			IF oJsonOper[aNames[nIndRegs]] != Nil
				aSize(oJsonOper[aNames[nIndRegs]], 0)
				oJsonOper[aNames[nIndRegs]] := Nil
			EndIf
		Next nIndRegs
		FreeObj(oJsonOper)
		aSize(aNames, 0)

		//Registra produtos que possuem opcionais em sua estrutura
		aNames := oProdsOPC:GetNames()
		nTotal := Len(aNames)
		For nIndRegs := 1 To nTotal
			oDominio:oDados:oOpcionais:setFlag("PRD_COM_OPC" + CHR(10) + aNames[nIndRegs], .T.)

			marcaPais(oPaiComp, aNames[nIndRegs], oDominio:oDados:oOpcionais)
		Next nIndRegs
		aSize(aNames, 0)

		//Limpa as variáveis da memória
		FreeObj(oEstJson)
		oEstJson := Nil

		FreeObj(oChavesEst)
		oChavesEst := Nil

		FreeObj(oProdsOPC)
		oProdsOPC := Nil

		FwFreeObj(oPaiComp)
		oPaiComp := Nil

		aSize(aAuxAlt, 0)
		aAuxAlt := Nil
		aSize(aAuxEst, 0)
		aAuxEst := Nil
	EndIf

	//Grava flag de conclusao global
	oEstrutura:setFlag("termino_carga", "S")

	If lLogAtivo
		oLogs:gravaLog("carga_memoria", "Estruturas (T4N)", {"Fim da carga. Tempo: " + cValToChar(MicroSeconds() - nTempoCarg)})
	EndIf

	aSize(aRetPE, 0)
	aRetPE := Nil

Return

/*/{Protheus.doc} RetOperCmp
Carrega dados no objeto Json de Operações por Componente

@author brunno.costa
@since 15/04/2020
@version 1.0
@param 01 oDominio , objeto  , instância da classe de Dominio
@param 02 cTicket  , caracter, número do ticket de processamento do MRP
@return   oJsonOper, objeto  , objeto json com os registros de operações por componentes
/*/
Static Function RetOperCmp(oDominio, cTicket)
	Local aAuxOper   := {}
	Local aFields    := {{"HW9_FILIAL", "C", "HW9"}, ;
	                     {"HW9_PROD"  , "C", "HW9"}, ;
	                     {"HW9_ROTEIR", "C", "HW9"}, ;
	                     {"HW9_OPERAC", "C", "HW9"}, ;
	                     {"HW9_COMP"  , "C", "HW9"}, ;
	                     {"HW9_TRT"   , "C", "HW9"}}
	Local aRegJson   := {}
	Local cChave     := ""
	Local cError     := ""
	Local cFilAux    := ""
	Local cWhere     := ""
	Local lUsaME     := oDominio:oMultiEmp:utilizaMultiEmpresa()
	Local nIndRegs   := 1
	Local nTotal     := 0
	Local oCarga     := oDominio:oDados:oCargaMemoria
	Local oEstrutura := oDominio:oDados:oEstruturas
	Local oJsonOper  := JsonObject():New()
	Local oRegistros := Nil
	Local oStatus    := MrpDados_Status():New(cTicket)

	If lUsaME
		cWhere := oDominio:oMultiEmp:queryFilial("HW9", "HW9_FILIAL", .T.)
	Else
		cWhere := " HW9.HW9_FILIAL = '" + xFilial("HW9") + "' "
	EndIf

	cWhere += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("HW9.HW9_PROD", .T.)
	cWhere += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("HW9.HW9_COMP", .T.)

	aRegJson := oCarga:buscaRegistrosNoBanco("HW9", {}, cWhere, aFields)
	nTotal   := Len(aRegJson)
	If nTotal > 0
		aAuxOper := Array(TAM_OPE)
	EndIf

	oEstrutura:setFlag("qtd_registros_total_operacoes", nTotal)
	oEstrutura:setFlag("qtd_registros_lidos_operacoes", 0)

	//Processa todos os registros encontrados
	For nIndRegs := 1 to nTotal
		//Checa cancelamento a cada X delegacoes
		If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
			Exit
		EndIf

		oRegistros := JsonObject():new()
		cError     := oRegistros:fromJSON(aRegJson[nIndRegs])
		If !Empty(cError)
			cError := oRegistros:fromJSON(oCarga:trataJsonString(aRegJson[nIndRegs]))
			If !Empty(cError)
				Loop
			EndIf
		EndIf

		If Empty(cError)
			//Filial + Produto + Componente + TRT
			If lUsaME
				cFilAux := PadR(oRegistros["aRegs"][1]["HW9_FILIAL"], oDominio:oMultiEmp:tamanhoFilial())
			EndIf

			cChave := cFilAux
			cChave += PadR(oRegistros["aRegs"][1]["HW9_PROD"], oCarga:nTamCod)
			cChave += PadR(oRegistros["aRegs"][1]["HW9_COMP"], oCarga:nTamCod)
			cChave += oRegistros["aRegs"][1]["HW9_TRT"]

			If oJsonOper[cChave] == Nil
				oJsonOper[cChave] := {}
			EndIf

			aAuxOper[OPE_ROTE]  := oRegistros["aRegs"][1]["HW9_ROTEIR"]
			aAuxOper[OPE_OPERA] := oRegistros["aRegs"][1]["HW9_OPERAC"]
			aAdd(oJsonOper[cChave], aClone(aAuxOper))
		EndIf

		FreeObj(oRegistros)
		oRegistros := Nil

		oEstrutura:setFlag("qtd_registros_lidos_operacoes", 1, , , .T.)
	Next nIndRegs

	//Limpa as variáveis da memória
	aSize(aAuxOper, 0)
	aAuxOper := Nil
	aSize(aFields, 0)
	aFields := Nil

Return oJsonOper

/*/{Protheus.doc} subprodutos
Carrega os dados dos Subprodutos

@author brunno.costa
@since 19/09/2019
@version 1.0
/*/
METHOD subprodutos() CLASS MrpDados_Carga_Engenharia

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaSu", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaSu(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaSu
Processa a carga dos dados dos Subprodutos

@author brunno.costa
@since 16/10/2019
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpCargaSu(cTicket)
	Local aAux       := {}
	Local aNames     := {}
	Local cAlias     := GetNextAlias()
	Local cChave     := ""
	Local cComp      := ""
	Local cFilAux    := ""
	Local cOldChave  := ""
	Local cOrder     := ""
	Local cQuery     := ""
	Local cSql       := ""
	Local cSubQryRev := ""
	Local cStmtRec   := ""
	Local lLogAtivo  := .F.
	Local lRevHWE    := .F.
	Local lUsaME     := .F.
	Local nIndRegs   := 0
	Local nTempoCarg := MicroSeconds()
	Local nTempoQry  := 0
	Local nTotal     := 0
	Local oCarga     := Nil
	Local oDominio   := Nil
	Local oLogs      := Nil
	Local oMultiEmp  := Nil
	Local oProdutos  := Nil
	Local oStatus    := Nil
	Local oSubPJson  := Nil
	Local oSubProdut := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket)
	oCarga     := oDominio:oDados:oCargaMemoria
	oLogs      := oDominio:oDados:oLogs
	oMultiEmp  := oDominio:oMultiEmp
	oProdutos  := oDominio:oDados:oProdutos
	oStatus    := MrpDados_Status():New(cTicket)
	oSubProdut := oDominio:oDados:oSubProdutos
	lLogAtivo  := oLogs:logAtivado()

	//Busca os registros a serem processados
	If oStatus:preparaAmbiente(oDominio:oDados)
		lUsaME  := oMultiEmp:utilizaMultiEmpresa()
		lRevHWE := oDominio:oParametros["revisionInProductIndicator"] == "1" .And. oDominio:oParametros["lUsesProductIndicator"]

		If lRevHWE
			cSubQryRev := " COALESCE((SELECT HWE.HWE_REVATU"
			cSubQryRev +=             " FROM " + RetSqlName("HWE") + " HWE"
			cSubQryRev +=            " WHERE HWE.HWE_PROD = T4N.T4N_PROD"
			If lUsaME
				cSubQryRev +=          " AND " + oCarga:relacionaFilial("T4N", "T4N", "T4N_FILIAL", "HWE", "HWE", "HWE_FILIAL", .T., .T., .T.)
			Else
				cSubQryRev +=          " AND HWE.HWE_FILIAL = '" + xFilial("HWE") + "'"
			EndIf
			cSubQryRev +=              " AND HWE.D_E_L_E_T_ = ' '),"
			cSubQryRev +=           "(SELECT HWA.HWA_REVATU"
			cSubQryRev +=             " FROM " + RetSqlName("HWA") + " HWA"
			cSubQryRev +=            " WHERE HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"
			cSubQryRev +=              " AND HWA.HWA_PROD = T4N.T4N_PROD"
			cSubQryRev +=              " AND HWA.D_E_L_E_T_ = ' '))"
		Else
			cSubQryRev +=           "(SELECT HWA.HWA_REVATU"
			cSubQryRev +=             " FROM " + RetSqlName("HWA") + " HWA"
			cSubQryRev +=            " WHERE HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"
			cSubQryRev +=              " AND HWA.HWA_PROD = T4N.T4N_PROD"
			cSubQryRev +=              " AND HWA.D_E_L_E_T_ = ' ')"
		EndIf

		//Query recursiva "validaFilho" -> busca toda a estrutura em todos os níveis para validação de recursividade com subproduto.
		cStmtRec := " WITH validaFilho(T4N_FILIAL,T4N_PROD,T4N_COMP,T4N_QTD,T4N_PAI)"
		cStmtRec += " AS ( SELECT T4N_PAI.T4N_FILIAL, T4N_PAI.T4N_PROD, T4N_PAI.T4N_COMP,T4N_PAI.T4N_QTD, T4N_PAI.T4N_PROD
		cStmtRec +=        " FROM " + RetSqlName("T4N") + " T4N_PAI"
		If lRevHWE
			cStmtRec +=    " LEFT OUTER JOIN " + RetSqlName("HWE") + " HWE_PAI"
			cStmtRec +=      " ON T4N_PAI.T4N_PROD = HWE_PAI.HWE_PROD "
			cStmtRec +=     " AND HWE_PAI.D_E_L_E_T_ = ' '"
			If lUsaME
				cStmtRec += " AND " + oCarga:relacionaFilial("T4N", "T4N_PAI", "T4N_FILIAL", "HWE", "HWE_PAI", "HWE_FILIAL", .T., .T., .T.)
			Else
				cStmtRec += " AND HWE_PAI.HWE_FILIAL = '" + xFilial("HWE") + "'"
			EndIf
		EndIf
		cStmtRec +=       " INNER JOIN " + RetSqlName("HWA") + " HWA_PAI"
		cStmtRec +=          " ON HWA_PAI.D_E_L_E_T_ = ' '"
		cStmtRec +=         " AND HWA_PAI.HWA_FILIAL = '" + xFilial("HWA") + "'"
		cStmtRec +=         " AND HWA_PAI.HWA_BLOQUE <> '1'"
		cStmtRec +=         " AND HWA_PAI.HWA_PROD   = T4N_PAI.T4N_PROD"
		If lRevHWE
			cStmtRec +=     " AND COALESCE(HWE_PAI.HWE_REVATU, HWA_PAI.HWA_REVATU)"
		Else
			cStmtRec +=     " AND HWA_PAI.HWA_REVATU"
		EndIf
		cStmtRec +=             " BETWEEN T4N_PAI.T4N_REVINI AND T4N_PAI.T4N_REVFIM"
		cStmtRec +=       " WHERE T4N_PAI.D_E_L_E_T_ = ' '
		If lUsaME
			cStmtRec +=     " AND " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T., "T4N_PAI")
		Else
			cStmtRec +=     " AND T4N_PAI.T4N_FILIAL = '" + xFilial("T4N") + "' "
		EndIf
		cStmtRec +=       " UNION ALL"
		cStmtRec +=      " SELECT T4N.T4N_FILIAL, T4N.T4N_PROD, T4N.T4N_COMP, T4N.T4N_QTD, validaFilho.T4N_PAI"
		cStmtRec +=        " FROM " + RetSqlName("T4N") + " T4N"
		cStmtRec +=       " INNER JOIN validaFilho"
		cStmtRec +=          " ON validaFilho.T4N_COMP   = T4N.T4N_PROD"
		cStmtRec +=         " AND validaFilho.T4N_FILIAL = T4N.T4N_FILIAL"
		//Valida a revisão inicial/final do produto.
		//Não faz com join nas tabelas hwa/hwe pois em sql não é possível adicionar mais joins nesta parte da query recursiva
		cStmtRec +=         " AND " + cSubQryRev + " BETWEEN T4N.T4N_REVINI AND T4N.T4N_REVFIM"
		cStmtRec +=       " WHERE T4N.D_E_L_E_T_ = ' '"
		If lUsaME
			cStmtRec +=     " AND " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		Else
			cStmtRec +=     " AND T4N.T4N_FILIAL = '" + xFilial("T4N") + "' "
		EndIf
		cStmtRec += "),"

		//Query recursiva "EstruturaNegativa" -> retorna os produtos com quantidade negativa e o produto pai
		//para produção. Caso o produto negativo seja componente de um fantasma, retorna o pai do produto fantasma.
		cStmtRec += " EstruturaNegativa (SUBPRD, xT4N_FILIAL, xT4N_COMP, xT4N_PROD, xT4N_QTD, xT4N_QTDB, xT4N_DTINI, xT4N_DTFIM, xT4N_FIXA, xT4N_REVINI, xT4N_REVFIM, xT4N_FANTAS, xT4N_GROPC, xT4N_ITOPC, T4N_RECNO)"
		cStmtRec += " AS ( SELECT T4N.T4N_COMP AS SUBPRD,"
		cStmtRec +=             " T4N.T4N_FILIAL,"
		cStmtRec +=             " T4N.T4N_COMP,"
		cStmtRec +=             " T4N.T4N_PROD,"
		cStmtRec +=             " T4N.T4N_QTD,"
		cStmtRec +=             " (CASE WHEN T4N.T4N_QTDB <= 0 THEN 1 ELSE T4N.T4N_QTDB END) T4N_QTDB,"
		cStmtRec +=             " T4N.T4N_DTINI,"
		cStmtRec +=             " T4N.T4N_DTFIM,"
		cStmtRec +=             " T4N.T4N_FIXA,"
		cStmtRec +=             " T4N.T4N_REVINI,"
		cStmtRec +=             " T4N.T4N_REVFIM,"
		cStmtRec +=             " T4N.T4N_FANTAS,"
		cStmtRec +=             " T4N.T4N_GROPC,"
		cStmtRec +=             " T4N.T4N_ITOPC,"
		cStmtRec +=             " T4N.R_E_C_N_O_ T4N_RECNO"
		cStmtRec +=        " FROM " + RetSqlName("T4N") + " T4N"
		cStmtRec +=       " INNER JOIN " + RetSqlName("HWA") + " HWA_COMP"
		cStmtRec +=         " ON HWA_COMP.D_E_L_E_T_ = ' '"
		cStmtRec +=        " AND HWA_COMP.HWA_FILIAL = '" + xFilial("HWA") + "'"
		cStmtRec +=        " AND HWA_COMP.HWA_PROSBP = '1'"
		cStmtRec +=        " AND HWA_COMP.HWA_PROD = T4N.T4N_COMP"
		cStmtRec +=        " AND (HWA_COMP.HWA_ESTORI = ' ' OR HWA_COMP.HWA_ESTORI = T4N.T4N_PROD)"
		If lRevHWE
			cStmtRec +=   " LEFT OUTER JOIN " + RetSqlName("HWE") + " HWE_PAI"
			cStmtRec +=     " ON T4N.T4N_PROD = HWE_PAI.HWE_PROD "
			cStmtRec +=    " AND HWE_PAI.D_E_L_E_T_ = ' '"
			If lUsaME
				cStmtRec +=" AND " + oCarga:relacionaFilial("T4N", "T4N", "T4N_FILIAL", "HWE", "HWE_PAI", "HWE_FILIAL", .T., .T., .T.)
			Else
				cStmtRec +=" AND HWE_PAI.HWE_FILIAL = '" + xFilial("HWE") + "'"
			EndIf
		EndIf
		cStmtRec +=      " INNER JOIN " + RetSqlName("HWA") + " HWA_PAI"
		cStmtRec +=         " ON HWA_PAI.D_E_L_E_T_ = ' '"
		cStmtRec +=        " AND HWA_PAI.HWA_FILIAL = '" + xFilial("HWA") + "'"
		cStmtRec +=        " AND HWA_PAI.HWA_BLOQUE <> '1'"
		cStmtRec +=        " AND HWA_PAI.HWA_PROD = T4N.T4N_PROD"
		If lRevHWE
			cStmtRec +=    " AND COALESCE(HWE_PAI.HWE_REVATU, HWA_PAI.HWA_REVATU)"
		Else
			cStmtRec +=    " AND HWA_PAI.HWA_REVATU"
		EndIf
		cStmtRec +=            " BETWEEN T4N.T4N_REVINI AND T4N.T4N_REVFIM"
		cStmtRec +=      " WHERE T4N.D_E_L_E_T_ = ' '"
		cStmtRec +=        " AND T4N.T4N_QTD < 0
		If lUsaME
			cStmtRec +=    " AND " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		Else
			cStmtRec +=    " AND T4N.T4N_FILIAL = '" + xFilial("T4N") + "' "
		EndIf
		cStmtRec +=      " UNION ALL"
		cStmtRec +=      " SELECT EstruturaNegativa.SUBPRD,"
		cStmtRec +=             " T4N.T4N_FILIAL,"
		cStmtRec +=             " T4N.T4N_COMP,"
		cStmtRec +=             " T4N.T4N_PROD,"
		cStmtRec +=             " T4N.T4N_QTD,"
		cStmtRec +=             " (CASE WHEN T4N.T4N_QTDB <= 0 THEN 1 ELSE T4N.T4N_QTDB END) T4N_QTDB,"
		cStmtRec +=             " T4N.T4N_DTINI,"
		cStmtRec +=             " T4N.T4N_DTFIM,"
		cStmtRec +=             " T4N.T4N_FIXA,"
		cStmtRec +=             " T4N.T4N_REVINI,"
		cStmtRec +=             " T4N.T4N_REVFIM,"
		cStmtRec +=             " T4N.T4N_FANTAS,"
		cStmtRec +=             " T4N.T4N_GROPC,"
		cStmtRec +=             " T4N.T4N_ITOPC,"
		cStmtRec +=             " T4N.R_E_C_N_O_ T4N_RECNO"
		cStmtRec +=        " FROM EstruturaNegativa"
		cStmtRec +=       " INNER JOIN " + RetSqlName("T4N") + " T4N"
		cStmtRec +=          " ON T4N.D_E_L_E_T_ = ' '"
		If lUsaME
			cStmtRec +=     " AND " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		Else
			cStmtRec +=     " AND T4N.T4N_FILIAL = '" + xFilial("T4N") + "' "
		EndIf
		cStmtRec +=         " AND T4N.T4N_COMP = EstruturaNegativa.xT4N_PROD"
		cStmtRec +=         " AND T4N.T4N_FANTAS = 'T'
		//Valida a revisão inicial/final do produto.
		//Não faz com join nas tabelas hwa/hwe pois em sql não é possível adicionar mais joins nesta parte da query recursiva
		cStmtRec +=         " AND " + cSubQryRev + " BETWEEN T4N.T4N_REVINI AND T4N.T4N_REVFIM)"

		//Query que busca os dados com base nas recursividades declaradas acima
		cSql := " SELECT T4N.T4N_PROD,"
		cSql +=        " T4N.T4N_COMP,"
		cSql +=        " T4N.T4N_QTD,"
		cSql +=        " T4N.T4N_QTDB,"
		cSql +=        " T4N.T4N_FANTAS,"
		cSql +=        " T4N.T4N_SEQ,"
		cSql +=        " T4N.T4N_GROPC,"
		cSql +=        " T4N.T4N_ITOPC,"
		cSql +=        " T4N.T4N_DTINI,"
		cSql +=        " T4N.T4N_DTFIM,"
		cSql +=        " T4N.T4N_REVINI,"
		cSql +=        " T4N.T4N_REVFIM,"
		cSql +=        " T4N.T4N_FIXA,"
		cSql +=        " T4N.T4N_POTEN,"
		cSql +=        " T4N.T4N_PERDA,"
		cSql +=        " T4N.T4N_IDREG,"
		cSql +=        " T4N.T4N_FILIAL,"
		cSql +=        " T4N.T4N_ARMCON"
		cSql +=   " FROM " + RetSqlName("T4N") + " T4N"
		cSql +=  " INNER JOIN EstruturaNegativa"
		cSql +=     " ON EstruturaNegativa.T4N_RECNO = T4N.R_E_C_N_O_"
		cSql +=  " WHERE T4N.D_E_L_E_T_ = ' '"
		/*
			Valida se na estrutura onde o produto possui quantidade negativa,
			existirá também o consumo do mesmo produto, sendo no mesmo nível ou em níveis de estrutura diferentes.
			Ex:
			PA1
			 MP1 (qtd -1)
			 PI1
			  MP1 (qtd 5)
			Não pode utilizar a estrutura do PA1 para produzir o subproduto MP1, pois este irá gerar necessidade para PI1 e MP1 novamente.
		*/
		cSql +=    " AND NOT EXISTS (SELECT 1"
		cSql +=                      " FROM validaFilho"
		cSql +=                     " WHERE validaFilho.T4N_PAI  = T4N.T4N_PROD"
		cSql +=                       " AND validaFilho.T4N_COMP = EstruturaNegativa.SUBPRD"
		cSql +=                       " AND validaFilho.T4N_QTD  > 0)"
		/*
			Valida na estrutura utilizada se existe algum outro subproduto que geraria necessidade para o componente atual
			Ex:
			PA1
			 MP1 (qtd 1)

			PA2
			 MP1 (qtd -1)
			 MP2 (qtd 1)

			PA3
			 MP2 (qtd -1)
			 MP1 (qtd 1)

			Para atender a necessidade de PA1 -> MP1, não pode produzir PA2 pois este tem o consumo do subproduto
			MP2 que por sua vez seria produzido por PA3, e PA3 geraria nova necessidade para MP1.

			Outro exemplo de estrutura que gera a recursividade:
			PA1
			 MP1 (qtd -1)
			 PI (qtd 1)
			   MP2 (qtd 1)

			PA2
			 MP1 (qtd 1)
			 PI2 (qtd 1, produto fantasma)
			  MP2 (qtd -1)

		*/
		cSql +=   " AND NOT EXISTS (SELECT 1"
		cSql +=                     " FROM validaFilho"
		cSql +=                    " WHERE validaFilho.T4N_PAI = T4N.T4N_PROD"
		cSql +=                      " AND validaFilho.T4N_QTD > 0"
		cSql +=                      " AND EXISTS (SELECT 1"
		cSql +=                                    " FROM EstruturaNegativa ENEG"
		cSql +=                                   " WHERE ENEG.SUBPRD = validaFilho.T4N_COMP"
		cSql +=                                     " AND EXISTS( SELECT 1"
		cSql +=                                                   " FROM validaFilho vldFil"
		cSql +=                                                  " WHERE vldFil.T4N_PAI = ENEG.xT4N_PROD"
		cSql +=                                                    " AND (vldFil.T4N_COMP = ENEG.SUBPRD OR vldFil.T4N_COMP = EstruturaNegativa.SUBPRD)"
		cSql +=                                                    " AND vldFil.T4N_QTD > 0)))"

		//Ordenação dos dados
		cOrder := " ORDER BY T4N.T4N_FILIAL, T4N.T4N_COMP, T4N.T4N_PROD"

		If TcGetDb() == "POSTGRES"
			cStmtRec := StrTran(cStmtRec, 'WITH ', 'WITH recursive ')
		EndIf

		cQuery := cStmtRec
		cQuery += " SELECT COUNT(*) TOTAL FROM (" + cSql + ") T"

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Subprodutos (T4N)", {"Query totalizadora: " + cQuery})
		EndIf
		nTempoQry := MicroSeconds()

		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .T.)

		nTempoQry := MicroSeconds() - nTempoQry
		nTotal    := (cAlias)->(TOTAL)
		(cAlias)->(dbCloseArea())

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Subprodutos (T4N)", {"Quantidade de registros: " + cValToChar(nTotal), ;
			                                                      "Tempo da query totalizadora: " + cValToChar(nTempoQry)})
		EndIf
	EndIf

	oSubProdut:setFlag("qtd_registros_total", nTotal)
	oSubProdut:setFlag("qtd_registros_lidos", 0)

	If nTotal > 0
		oSubPJson := JsonObject():New()
		aAux      := Array(TAM_EST)
		cQuery    := cStmtRec + cSql + cOrder

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Subprodutos (T4N)", {"Query principal: " + cQuery})
		EndIf
		nTempoQry := MicroSeconds()

		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery ), cAlias, .T., .T.)

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Subprodutos (T4N)", {"Tempo da query principal: " + cValToChar(MicroSeconds() - nTempoQry)})
		EndIf

		TcSetField(cAlias, 'T4N_DTINI', 'D', 8, 0)
		TcSetField(cAlias, 'T4N_DTFIM', 'D', 8, 0)

		//Processa todos os registros encontrados
		While (cAlias)->(!Eof())
			nIndRegs++

			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .Or. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .And. oStatus:getStatus("status") == "4"
				oSubProdut:setFlag("termino_carga", "S") //Grava flag de conclusao global
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAlias)->T4N_FILIAL, oMultiEmp:tamanhoFilial())
			EndIf

			cComp := PadR((cAlias)->T4N_COMP, oCarga:nTamCod)
			aAux[EST_FILIAL] := cFilAux
			aAux[EST_CODPAI] := PadR((cAlias)->T4N_PROD, oCarga:nTamCod)
			aAux[EST_CODFIL] := cComp
			aAux[EST_QTD   ] := (cAlias)->T4N_QTD
			aAux[EST_QTDB  ] := (cAlias)->T4N_QTDB
			aAux[EST_FANT  ] := (cAlias)->T4N_FANTAS == "T"
			aAux[EST_TRT   ] := RTrim((cAlias)->T4N_SEQ)
			aAux[EST_GRPOPC] := RTrim((cAlias)->T4N_GROPC)
			aAux[EST_ITEOPC] := RTrim((cAlias)->T4N_ITOPC)
			aAux[EST_VLDINI] := (cAlias)->T4N_DTINI
			aAux[EST_VLDFIM] := (cAlias)->T4N_DTFIM
			aAux[EST_REVINI] := RTrim((cAlias)->T4N_REVINI)
			aAux[EST_REVFIM] := RTrim((cAlias)->T4N_REVFIM)
			aAux[EST_ALTERN] := "1"
			aAux[EST_FIXA  ] := (cAlias)->T4N_FIXA
			aAux[EST_POTEN ] := (cAlias)->T4N_POTEN
			aAux[EST_PERDA ] := (cAlias)->T4N_PERDA
			aAux[EST_ARMCON] := RTrim((cAlias)->T4N_ARMCON)

			cChave := cFilAux + cComp
			If oSubPJson:HasProperty(cChave) == .F.
				oSubPJson[cChave] := {}
			EndIf

			aAdd(oSubPJson[cChave], aClone(aAux))

			oSubProdut:setFlag("qtd_registros_lidos", 1, , , .T.)
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())
		aSize(aAux, 0)

		aNames := oSubPJson:GetNames()
		nTotal := Len(aNames)
		For nIndRegs := 1 To nTotal
			If !oSubProdut:addRow(aNames[nIndRegs], oSubPJson[aNames[nIndRegs]])
				If oStatus:getStatus("status") == "4"
					Exit
				EndIf
			EndIf
		Next

		//Aguarda Conclusão da Carga de Produtos - Atualiza Flag de SubProduto
		oDominio:oAglutina:aguardaProdutoCarga()
		For nIndRegs := 1 To nTotal
			cChave := aNames[nIndRegs]
			aSize(aAux, 0)
			If cChave != cOldChave .AND. oProdutos:getRow(1, cChave, Nil, @aAux)
				If oSubPJson[aNames[nIndRegs]][1][EST_QTD] < 0
					aAux[PRD_LSUBPR] := .T.
					If !oProdutos:updRow(1, cChave, Nil, aAux)
						If oStatus:getStatus("status") == "4"
							Exit
						EndIf
					EndIf
					cOldChave := cChave
				EndIf
			EndIf
		Next

		aSize(aNames, 0)
	EndIf

	//Grava flag de conclusao global
	oSubProdut:setFlag("termino_carga", "S")

	If lLogAtivo
		oLogs:gravaLog("carga_memoria", "Subprodutos (T4N)", {"Fim da carga. Tempo: " + cValToChar(MicroSeconds() - nTempoCarg)})
	EndIf

	//Limpa as variáveis da memória
	aSize(aAux, 0)
	aSize(aNames, 0)
	FreeObj(oSubPJson)

Return

/*/{Protheus.doc} versaoDaProducao
Carrega os dados da Versão da Produção

@author brunno.costa
@since 19/09/2019
@version 1.0
/*/
METHOD versaoDaProducao() CLASS MrpDados_Carga_Engenharia

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaVP", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaVP(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaVP
Processa a carga dos dados da Versão da Produção

@author brunno.costa
@since 16/10/2019
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpCargaVP(cTicket)
	Local aAux       := {}
	Local aRetPE     := {}
	Local cChave     := ""
	Local cFields    := ""
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cOrder     := "%T4M.T4M_FILIAL, T4M.T4M_PROD, T4M.T4M_DTINI, T4M.T4M_DTFIN%"
	Local cProduto   := ""
	Local cQueryCon  := ""
	Local lLogAtivo  := .F.
	Local lP712SQL   := ExistBlock("P712SQL")
	Local lUsaME     := .F.
	Local nIndRegs   := 0
	Local nTempoCarg := MicroSeconds()
	Local nTempoQry  := 0
	Local nTotal     := 0
	Local oCarga     := Nil
	Local oDominio   := Nil
	Local oLogs      := Nil
	Local oMultiEmp  := Nil
	Local oStatus    := Nil
	Local oVersDaPrd := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket)
	oCarga     := oDominio:oDados:oCargaMemoria
	oLogs      := oDominio:oDados:oLogs
	oMultiEmp  := oDominio:oMultiEmp
	oStatus    := MrpDados_Status():New(cTicket)
	oVersDaPrd := oDominio:oDados:oVersaoDaProducao
	lLogAtivo  := oLogs:logAtivado()

	//Busca os registros a serem processados
	If oStatus:preparaAmbiente(oDominio:oDados)

		lUsaME := oMultiEmp:utilizaMultiEmpresa()

        cFields := oCarga:trataOptimizerOracle()

		cFields += " T4M.T4M_IDREG, "
		cFields += " T4M.T4M_PROD, "
		cFields += " T4M.T4M_DTINI, "
		cFields += " T4M.T4M_DTFIN, "
		cFields += " T4M.T4M_QNTDE, "
		cFields += " T4M.T4M_QNTATE, "
		cFields += " T4M.T4M_ROTEIR, "
		cFields += " T4M.T4M_ARMCON, "
		cFields += " T4M.T4M_REV "

		If lUsaME
			cFields += ", T4M.T4M_FILIAL "
		EndIf

		cFields := "%" + cFields + "%"

		cQueryCon := "%" + RetSqlName("T4M") + " T4M "
		cQueryCon += oCarga:montaJoinHWA("T4M.T4M_PROD", cTicket, .T., "T4M.T4M_FILIAL", "T4M", oMultiEmp)

		cQueryCon += " WHERE "

		If lUsaME
			cQueryCon += oMultiEmp:queryFilial("T4M", "T4M_FILIAL", .T.)
		Else
			cQueryCon += " T4M.T4M_FILIAL = '" + xFilial("T4M") + "' "
		EndIf

		cQueryCon += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4M.T4M_PROD",.F.,.T.,.F.)

		cQueryCon += "%"

		If lP712SQL
			aRetPE := ExecBlock("P712SQL", .F., .F., {"T4M",cFields,cQueryCon,cOrder})

			If aRetPE != Nil .And. Len(aRetPE) == 3
				cFields   := aRetPE[1]
				cQueryCon := aRetPE[2]
				cOrder    := aRetPE[3]
			EndIf
		EndIf

        cFieldCnt := "%" + oCarga:trataOptimizerOracle() + "COUNT(1) TOTAL%"

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Versoes da Producao (T4M)", {"Query totalizadora: SELECT " + SubStr(cFieldCnt, 2, Len(cFieldCnt)-2) + ;
			                                                                                   " FROM " + SubStr(cQueryCon, 2, Len(cQueryCon)-2)})
		EndIf

		cAliasQry := GetNextAlias()
		nTempoQry := MicroSeconds()

		BeginSql Alias cAliasQry
		  SELECT %Exp:cFieldCnt%
		    FROM %Exp:cQueryCon%
		EndSql

		nTempoQry := MicroSeconds() - nTempoQry

		If (cAliasQry)->(!Eof())
			nTotal := (cAliasQry)->TOTAL
		EndIf
		(cAliasQry)->(dbCloseArea())

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Versoes da Producao (T4M)", {"Quantidade de registros: " + cValToChar(nTotal), ;
			                                                              "Tempo da query totalizadora: " + cValToChar(nTempoQry)})
		EndIf
	EndIf

	oVersDaPrd:setFlag("qtd_registros_total", nTotal, , , .T.)
	oVersDaPrd:setFlag("qtd_registros_lidos", 0     , , , .T.)

	If nTotal > 0
		aAux := Array(TAM_VDP)

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Versoes da Producao (T4M)", {"Query principal: SELECT " + SubStr(cFields, 2, Len(cFields)-2) + ;
			                                                                                " FROM " + SubStr(cQueryCon, 2, Len(cQueryCon)-2) + ;
			                                                                               " ORDER BY " + SubStr(cOrder, 2, Len(cOrder)-2)})
			nTempoQry := MicroSeconds()
		EndIf

		BeginSql Alias cAliasQry
		  COLUMN T4M_DTINI AS DATE
		  COLUMN T4M_DTFIN AS DATE
		  SELECT %Exp:cFields%
		    FROM %Exp:cQueryCon%
		   ORDER BY %Exp:cOrder%
		EndSql

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Versoes da Producao (T4M)", {"Tempo da query principal: " + cValToChar(MicroSeconds() - nTempoQry)})
		EndIf

		//Processa todos os registros encontrados
		While (cAliasQry)->(!Eof())
			nIndRegs++

			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
				oVersDaPrd:setFlag("termino_carga_VDP", "S")
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAliasQry)->T4M_FILIAL, oMultiEmp:tamanhoFilial())
			EndIf

			cProduto := (cAliasQry)->T4M_PROD
			cChave   := (cAliasQry)->T4M_IDREG

			//Guarda o registro na Matriz
			oVersDaPrd:trava(cChave)
			If !oVersDaPrd:existAList(cFilAux + cProduto)
				oVersDaPrd:createAList(cFilAux + cProduto)
			EndIf

			aAux[VDP_FILIAL ] := cFilAux
			aAux[VDP_PROD   ] := cProduto
			aAux[VDP_DTINI  ] := (cAliasQry)->T4M_DTINI
			aAux[VDP_DTFIN  ] := (cAliasQry)->T4M_DTFIN
			aAux[VDP_QNTDE  ] := (cAliasQry)->T4M_QNTDE
			aAux[VDP_QNTATE ] := (cAliasQry)->T4M_QNTATE
			aAux[VDP_REV    ] := (cAliasQry)->T4M_REV
			aAux[VDP_ROTEIRO] := (cAliasQry)->T4M_ROTEIR
			aAux[VDP_LOCAL  ] := (cAliasQry)->T4M_ARMCON
			aAux[VDP_CODIGO ] := RTrim(cChave)

			If !oVersDaPrd:setItemAList(cFilAux + cProduto, cChave, aAux)
				If oStatus:getStatus("status") == "4"
					Exit
				EndIf
			EndIf

			oVersDaPrd:destrava(cChave)
			oVersDaPrd:setFlag("qtd_registros_lidos", 1, , , .T.)

			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	//Grava flag de conclusão global
	oVersDaPrd:setFlag("termino_carga_VDP", "S")

	If lLogAtivo
		oLogs:gravaLog("carga_memoria", "Versoes da Producao (T4M)", {"Fim da carga. Tempo: " + cValToChar(MicroSeconds() - nTempoCarg)})
	EndIf

	//Limpa os arrays da memória
	aSize(aAux, 0)
	aAux := Nil
	aSize(aRetPE, 0)
	aRetPE := Nil

Return

/*/{Protheus.doc} produtos
Carrega os dados dos Produtos

@author brunno.costa
@since 19/09/2019
@version 1.0
/*/
METHOD produtos() CLASS MrpDados_Carga_Engenharia

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaPr", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaPr(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaPr
Processa a carga dos dados dos Produtos

@author brunno.costa
@since 16/10/2019
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpCargaPr(cTicket)
	Local aAux       := {}
	Local aFields    := {}
	Local aNames     := {}
	Local aPeriodos  := {}
	Local aRasAux    := {}
	Local aRegEmJson := {}
	Local aRegistro  := {}
	Local aRetPE     := {}
	Local cBanco     := ""
	Local cChave     := ""
	Local cChaveCQ   := ""
	Local cColumnNiv := "HWA_NIVEL"
	Local cDocCQ     := ""
	Local cDocSld    := ""
	Local cFields    := ""
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cFilFor    := ""
	Local cIdInterme := ""
	Local cIDT4V     := ""
	Local cIDT4VOld  := ""
	Local cMOpc      := ""
	Local cOldChave  := ""
	Local cOpcional  := ""
	Local cPriFil    := ""
	Local cProduto   := ""
	Local cQueryCon  := ""
	Local cTabOpc    := ""
	Local cValLote   := ""
	Local dValLote   := Nil
	Local lAgluProd  := .F.
	Local lConsidLt  := Iif(FindFunction("mrpLoteCQ"), mrpLoteCQ(), .F.)
	Local lHWX       := .F.
	Local lLogAtivo  := .F.
	Local lP712SINI  := ExistBlock("P712SINI")
	Local lP712SQL   := ExistBlock("P712SQL")
	Local lRastroEnt := .F.
	Local lUsaHWE    := .F.
	Local lUsaME     := .F.
	Local lVenceuLot := .F.
	Local nContador  := 0
	Local nEmin      := 0
	Local nEstSeg    := 0
	Local nIndFil    := 0
	Local nIndItem   := 0
	Local nIndRegs   := 0
	Local nLenPer    := 0
	Local nPerLote   := 0
	Local nQtNP      := 0
	Local nRecOpc    := 0
	Local nRejeitado := 0
	Local nSaldo     := 0
	Local nTempoCarg := MicroSeconds()
	Local nTempoQry  := 0
	Local nTotal     := 0
	Local nTotFil    := 1
	Local nTotPrd    := 0
	Local oCarga     := Nil
	Local oCQRejUsad := Nil
	Local oDominio   := Nil
	Local oLogs      := Nil
	Local oMultiEmp  := Nil
	Local oOpcionais := Nil
	Local oProdutos  := Nil
	Local oStatus    := Nil
	Local oTotNiveis := JsonObject():New()

	//Seta objetos do totalizador
	oTotNiveis["nProdutosN"] := JsonObject():New()
	oTotNiveis["nProdCalcN"] := JsonObject():New()

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket, .T.)
	oCarga     := oDominio:oDados:oCargaMemoria
	oLogs      := oDominio:oDados:oLogs
	oMultiEmp  := oDominio:oMultiEmp
	oProdutos  := oDominio:oDados:oProdutos
	oOpcionais := oDominio:oOpcionais
	oStatus    := MrpDados_Status():New(cTicket)
	lLogAtivo  := oLogs:logAtivado()

	If oDominio:oDados:semaforoNiveis("LOCK")
		oDominio:calcularNivel()
	Else
		oStatus:gravaErro("niveis", STR0085) //Falha ao obter acesso exclusivo para executar o recálculo de níveis.
	EndIf

	lRastroEnt := oDominio:oParametros["lRastreiaEntradas"]
	lUsaHWE    := oDominio:oParametros["lUsesProductIndicator"]
	lUsaME     := oMultiEmp:utilizaMultiEmpresa()
	cBanco     := AllTrim(TcGetDb())

	lHWX := FWAliasInDic("HWX",.F.)
	If lHWX .And. oDominio:oParametros["lSubtraiRejeitosCQ"]
		oCQRejUsad := JsonObject():New()
	EndIf

	If FwAliasInDic("SMI", .F.)
		dbSelectArea("SMI")
		lAgluProd  := FieldPos("MI_AGLUMRP") > 0
	EndIf

	//Busca os registros a serem processados
	If oStatus:preparaAmbiente(oDominio:oDados)
		aPeriodos := oDominio:oPeriodos:retornaArrayPeriodos()

		cFields += oCarga:trataOptimizerOracle()

		If lUsaME
			cColumnNiv := "MB_NIVEL"
			cPriFil    := oMultiEmp:filialPorIndice(1)
		Else
			cPriFil    := cFilAnt
		EndIf

		cFields   += queryField(oDominio, lUsaME)
		cQueryCon := queryProd(oDominio, aPeriodos, cPriFil, cTicket)
		cOrder    := "%HWA_FILIAL, " + cColumnNiv + ", HWA_PROD, T4V_VALID%"

		cFields := "%" + cFields + "%"

		If lP712SQL
			aRetPE := ExecBlock("P712SQL", .F., .F., {"HWA",cFields,cQueryCon,cOrder})

			If aRetPE != Nil .And. Len(aRetPE) == 3

				cFields   := aRetPE[1]
				cQueryCon := aRetPE[2]
				cOrder    := aRetPE[3]
			EndIf
		EndIf

		//Aguarda o cálculo dos níveis para fazer o SELECT na HWA
		If oCarga:aguardaCalculoNiveis(oStatus, .T.)
			nTempoCarg := MicroSeconds()
			cFieldCnt  := "%" + oCarga:trataOptimizerOracle() + " " + "COUNT(*) TOTAL%"

			If lLogAtivo
				oLogs:gravaLog("carga_memoria", "Produtos (HWA)", {"Query totalizadora: SELECT " + SubStr(cFieldCnt, 2, Len(cFieldCnt)-2) + ;
				                                                                        " FROM " + SubStr(cQueryCon, 2, Len(cQueryCon)-2)})
			EndIf

			cAliasQry := GetNextAlias()
			nTempoQry := MicroSeconds()

			BeginSql Alias cAliasQry
			  SELECT %Exp:cFieldCnt%
			    FROM %Exp:cQueryCon%
			EndSql

			nTempoQry := MicroSeconds() - nTempoQry

			If (cAliasQry)->(!Eof())
				nTotPrd := (cAliasQry)->TOTAL
			EndIf
			(cAliasQry)->(dbCloseArea())

			If lLogAtivo
				oLogs:gravaLog("carga_memoria", "Produtos (HWA)", {"Quantidade de registros: " + cValToChar(nTotPrd), ;
				                                                   "Tempo da query totalizadora: " + cValToChar(nTempoQry)})
			EndIf

			If lUsaME
				nTotFil := oMultiEmp:totalDeFiliais()
				nTotPrd := nTotPrd * nTotFil
			EndIf
		Else
			oProdutos:setFlag("termino_carga", "S")
		EndIf
	EndIf

	//Libera semáforo de calculo de níveis
	oDominio:oDados:semaforoNiveis("UNLOCK")

	oProdutos:setFlag("qtd_registros_total", nTotPrd, , , .T.)
	oProdutos:setFlag("qtd_registros_lidos", 0      , , , .T.)

	If nTotPrd > 0
		aAux    := Array(TAM_PRD)
		aAux[PRD_LOTVNC] := {}
		nLenPer := Len(aPeriodos)

		For nIndFil := 1 To nTotFil
			If lUsaME
				cFilFor := oMultiEmp:filialPorIndice(nIndFil)
			Else
				cFilFor := cFilAnt
			EndIf

			cQueryCon := queryProd(oDominio, aPeriodos, cFilFor, cTicket)

			If lLogAtivo
				oLogs:gravaLog("carga_memoria", "Produtos (HWA)", {"Query principal: SELECT " + SubStr(cFields, 2, Len(cFields)-2) + ;
				                                                                     " FROM " + SubStr(cQueryCon, 2, Len(cQueryCon)-2) + ;
				                                                                    " ORDER BY " + SubStr(cOrder, 2, Len(cOrder)-2)})
				nTempoQry := MicroSeconds()
			EndIf

			BeginSql Alias cAliasQry
			  SELECT %Exp:cFields%
			    FROM %Exp:cQueryCon%
			   ORDER BY %Exp:cOrder%
			EndSql

			If lLogAtivo
				oLogs:gravaLog("carga_memoria", "Produtos (HWA)", {"Tempo da query principal: " + cValToChar(MicroSeconds() - nTempoQry)})
			EndIf

			//Processa todos os registros encontrados
			While (cAliasQry)->(!Eof())

				nIndRegs++

				//Checa cancelamento a cada X delegacoes
				If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
					oProdutos:setFlag("termino_carga", "S")
					Exit
				EndIf

				cProduto := PadR((cAliasQry)->HWA_PROD, oCarga:nTamCod)
				cChave   := Iif(lUsaMe, PadR(cFilFor, oMultiEmp:tamanhoFilial()), '') + cProduto

				If cChave != cOldChave

					aAux[PRD_NIVEST] := RTrim((cAliasQry)->(&cColumnNiv))

					If lUsaME
						cFilAux := PadR(cFilFor, oMultiEmp:tamanhoFilial())

						aAux[PRD_LTTRAN] := (cAliasQry)->MI_LEADTR

						If fldTranSMI()
							aAux[PRD_TRANSF] := IIF(!Empty((cAliasQry)->MI_TRANSF),(cAliasQry)->MI_TRANSF, '1')
							aAux[PRD_FILCOM] := (cAliasQry)->MI_FILCOM
						Else
							aAux[PRD_TRANSF] := "1"
							aAux[PRD_FILCOM] := ""
						EndIf

						If fldLtMinTr()
							aAux[PRD_LMTRAN] := (cAliasQry)->MI_LMTRANS
						Else
							aAux[PRD_LMTRAN] := 0
						EndIf

						//Registra que esse produto possui estrutura em alguma filial
						If aAux[PRD_NIVEST] <> "99"
							oDominio:oDados:oProdutos:setFlag("|PossuiEstrutura|"+cProduto+"|", .T.)
						EndIf

						//Verifica se o Estoque de Segurança deve ser considerado nesta filial.
						//Se não for, zera as quantidades de estoque de segurança e ponto de pedido.
						If (cAliasQry)->EXISTE_HWE > 0
							nEstSeg := (cAliasQry)->HWE_ESTSEG
							nEmin   := (cAliasQry)->HWE_EMIN

						ElseIf cPriFil == cFilFor
							nEstSeg := (cAliasQry)->HWA_ESTSEG
							nEmin   := (cAliasQry)->HWA_EMIN

						Else
							nEstSeg := 0
							nEmin   := 0
						EndIf
					Else
						aAux[PRD_LTTRAN] := 0
						aAux[PRD_TRANSF] := "2"
						aAux[PRD_FILCOM] := ""

						If lUsaHWE .And. !Empty((cAliasQry)->HWE_PROD)
							nEstSeg := (cAliasQry)->HWE_ESTSEG
							nEmin   := (cAliasQry)->HWE_EMIN
						Else
							nEstSeg := (cAliasQry)->HWA_ESTSEG
							nEmin   := (cAliasQry)->HWA_EMIN
						EndIf
					EndIf

					cMopc := ""
					If lUsaHWE .And. !Empty((cAliasQry)->HWE_PROD)
						If (cAliasQry)->(HWE_MOPC) != Nil .And. !Empty((cAliasQry)->(HWE_MOPC))
							cMOpc   := (cAliasQry)->(HWE_MOPC)
							cTabOpc := 'HWE'
							nRecOpc := (cAliasQry)->(RECHWE)
						EndIf
					ElseIf (cAliasQry)->(HWA_MOPC) != Nil .And. !Empty((cAliasQry)->(HWA_MOPC))
						cMOpc   := (cAliasQry)->(HWA_MOPC)
						cTabOpc := 'HWA'
						nRecOpc := (cAliasQry)->(RECHWA)
					EndIf

					//Tratamento para quando possui o Opcional
					If !Empty(cMOpc)
						cIdInterme := ""
						cOpcional  := oOpcionais:converteJsonEmID(cFilAux, cMOpc, cTabOpc, nRecOpc, RTrim(cProduto), @cIdInterme, .T.)
						cOpcional  := Iif(Empty(cIdInterme), cOpcional, cIdInterme)
					Else
						cOpcional := ""
					EndIf

					aAux[PRD_FILIAL] := cFilAux
					aAux[PRD_COD   ] := cProduto
					aAux[PRD_NPERAT] := -1
					aAux[PRD_NPERMA] := -1
					aAux[PRD_NPERCA] := -1
					aAux[PRD_THREAD] := -1
					aAux[PRD_REINIC] := .F.
					aAux[PRD_IDOPC ] := ""
					aAux[PRD_DTHOFI] := Nil
					aAux[PRD_REVATU] := RTrim((cAliasQry)->HWA_REVATU)
					aAux[PRD_TIPE  ] := RTrim((cAliasQry)->HWA_TIPE)
					aAux[PRD_TIPO  ] := RTrim((cAliasQry)->HWA_TIPO)
					aAux[PRD_GRUPO ] := Iif(Empty((cAliasQry)->HWA_GRUPO), " ", RTrim((cAliasQry)->HWA_GRUPO))
					aAux[PRD_RASTRO] := RTrim((cAliasQry)->HWA_RASTRO)
					aAux[PRD_MRP   ] := RTrim((cAliasQry)->HWA_MRP)
					aAux[PRD_PROSBP] := RTrim((cAliasQry)->HWA_PROSBP)
					aAux[PRD_ESTORI] := RTrim((cAliasQry)->HWA_ESTORI)
					aAux[PRD_APROPR] := RTrim((cAliasQry)->HWA_APROPR)
					aAux[PRD_LE    ] := (cAliasQry)->HWA_LE
					aAux[PRD_PE    ] := (cAliasQry)->HWA_PE
					aAux[PRD_PPED  ] := nEmin
					aAux[PRD_TIPDEC] := Val((cAliasQry)->HWA_TIPDEC)
					aAux[PRD_NUMDEC] := Val((cAliasQry)->HWA_NUMDEC)
					aAux[PRD_QTEMB ] := (cAliasQry)->HWA_QE
					aAux[PRD_LM    ] := (cAliasQry)->HWA_LM
					aAux[PRD_TOLER ] := (cAliasQry)->HWA_TOLER
					aAux[PRD_EMAX  ] := (cAliasQry)->HWA_EMAX
					aAux[PRD_LOTSBP] := (cAliasQry)->HWA_LOTSBP
					aAux[PRD_CHAVE2] := aAux[PRD_NIVEST] + cFilAux + cProduto
					aAux[PRD_LOCPAD] := RTrim((cAliasQry)->HWA_LOCPAD)
					aAux[PRD_CALCES] := "F"
					aAux[PRD_CALENS] := "F"
					aAux[PRD_LSUBPR] := .F. //Indica se o produto é subproduto (possui estrutura negativa)
					aAux[PRD_ESTSEG] := nEstSeg //Considera o estoque de segurança na carga. Desfaz caso o parâmetro lEstoqueSeguranca for .F.
					aAux[PRD_QB    ] := Iif(fieldsQB(), (cAliasQry)->HWA_QB, Nil)
					aAux[PRD_CPOTEN] := RTrim((cAliasQry)->HWA_CPOTEN)
					aAux[PRD_ROTEIR] := RTrim((cAliasQry)->HWA_ROTOPE)

					If (cAliasQry)->HWA_MOD == "T"
						oDominio:oDados:oProdutos:setFlag("|MOD|"+cFilAux+cProduto+"|", .T.)
						aAux[PRD_MOD] := "T"
					Else
						aAux[PRD_MOD] := "F"
					EndIf

					//Considerar Horizonte Firme somente se for informado o Tipo
					If Empty((cAliasQry)->HWA_TPHFIX)
						aAux[PRD_HORFIR] := 0
						aAux[PRD_TPHOFI] := Nil
					Else
						aAux[PRD_HORFIR] := (cAliasQry)->HWA_HORFIX
						aAux[PRD_TPHOFI] := RTrim((cAliasQry)->HWA_TPHFIX)
					EndIf

					aAux[PRD_BLOQUE] := RTrim((cAliasQry)->HWA_BLOQUE)
					If aAux[PRD_BLOQUE] == "1"//Se bloqueado, não aplica Estoque de Segurança e Ponto de Pedido
						aAux[PRD_ESTSEG] := 0
						aAux[PRD_PPED]   := 0
					EndIf

					If lAgluProd
						aAux[PRD_AGLUT] := (cAliasQry)->MI_AGLUMRP
						If Empty(aAux[PRD_AGLUT])
							aAux[PRD_AGLUT] := 0
						Else
							//converte valor do MI_AGLUMRP para corresponder ao parâmetro "nTipoPeriodos"
							aAux[PRD_AGLUT] := MrpDados_Carga_Engenharia():tipoPeriodoAglutinaProduto(aAux[PRD_AGLUT])
						EndIf
					EndIf
				EndIf

				//Alterações referente SALDO INICIAL - INICIO
				nSaldo := 0
				cIDT4V := (cAliasQry)->T4V_IDREG
				If cIDT4V != cIDT4VOld
					nSaldo  := (cAliasQry)->T4V_QTD
					cDocSld := getDocSld((cAliasQry)->T4V_LOCAL, (cAliasQry)->T4V_LOTE, (cAliasQry)->T4V_SLOTE, (cAliasQry)->T4V_VALID)

					If nSaldo <> 0
						oCarga:addLogDocumento(cFilAux, cProduto, cOpcional, aPeriodos[1], cDocSld, "T4V", nSaldo)
					EndIf

					//Se o parâmetro da tela "Estoque EM Terceiro" estiver como "1 - Soma", soma o valor do campo T4V_QNPT
					If oDominio:oParametros["lEMTerceiro"]
						nSaldo += (cAliasQry)->T4V_QNPT

						If (cAliasQry)->T4V_QNPT > 0
							oCarga:addLogDocumento(cFilAux, cProduto, cOpcional, aPeriodos[1], cDocSld, "ET", (cAliasQry)->T4V_QNPT)
						EndIf
					EndIf

					//Se o parâmetro da tela "Estoque DE Terceiro" estiver como "1 - Subtrai", subtrai o valor do campo T4V_QTNP
					If oDominio:oParametros["lDETerceiro"]
						nQtNP := (cAliasQry)->T4V_QTNP
						If nQtNP > 0
							nSaldo -= nQtNP
							oCarga:addLogDocumento(cFilAux, cProduto, cOpcional, aPeriodos[1], cDocSld, "DT", -nQtNP)
						EndIf
					EndIf

					//Se o parâmetro da tela "Saldo Bloqueado por Lote" estiver como "1 - Subtrai", subtrai o valor do campo T4V_SLDBQ
					If oDominio:oParametros["lSubtraiLoteBloqueado"]
						nSaldo -= (cAliasQry)->T4V_SLDBQ

						If (cAliasQry)->T4V_SLDBQ > 0
							oCarga:addLogDocumento(cFilAux, cProduto, cOpcional, aPeriodos[1], cDocSld, "SB", -(cAliasQry)->T4V_SLDBQ)
						EndIf
					EndIf
				EndIf
				cIDT4VOld := cIDT4V

				//Se o parâmetro da tela "Estoque Rejeitado pelo CQ" estiver como "1 - Subtrai", subtrai o valor do campo (HWX_QTDE - HWX_QTDEV)
				nRejeitado := 0
				If oDominio:oParametros["lSubtraiRejeitosCQ"] .And. lHWX
					cChaveCQ := cFilAux + cProduto + (cAliasQry)->T4V_LOCAL

					If lConsidLt
						cChaveCQ += (cAliasQry)->T4V_LOTE +;
						            (cAliasQry)->T4V_SLOTE
					EndIf

					If lConsidLt .Or. (!lConsidLt .And. !oCQRejUsad:HasProperty(cChaveCQ))
						oCQRejUsad[cChaveCQ] := Nil
						nRejeitado := ((cAliasQry)->HWX_QTDE - (cAliasQry)->HWX_QTDEV)
						nSaldo -= nRejeitado

						cDocCQ := getDocSld((cAliasQry)->T4V_LOCAL                    ,;
						                     Iif(lConsidLt, (cAliasQry)->T4V_LOTE , ""),;
						                     Iif(lConsidLt, (cAliasQry)->T4V_SLOTE, ""),;
						                     Iif(lConsidLt, (cAliasQry)->T4V_VALID, ""))

						oCarga:addLogDocumento(cFilAux, cProduto, cOpcional, aPeriodos[1], cDocCq, "HWX", -nRejeitado)
					EndIf
				EndIf

				cValLote := (cAliasQry)->T4V_VALID
				If (!oDominio:oParametros["lExpiredLot"] .And. !Empty(cValLote)) .Or. (lRastroEnt .And. nSaldo > 0)
					dValLote := SToD(cValLote)
					aRasAux  := {nSaldo                        , ;
					             dValLote                      , ;
					             RTrim((cAliasQry)->T4V_LOCAL) , ;
					             RTrim((cAliasQry)->T4V_LOTE)  , ;
					             RTrim((cAliasQry)->T4V_SLOTE)   }
				EndIf

				If !oDominio:oParametros["lExpiredLot"] .And. !Empty(cValLote) .And. !Empty(aRasAux)
					If aPeriodos[nLenPer] > dValLote
						aAdd(aAux[PRD_LOTVNC], aClone(aRasAux))
						nPerLote := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dValLote)
						If nPerLote > 0 .And. nPerLote+1 <= nLenPer
							lVenceuLot := .T.
							//Registra o produto na matriz, com as quantidades zeradas para que o MRP
							//realize o cálculo dos saldos considerando os lotes vencidos, caso este produto não tenha nenhuma
							//necessidade nos períodos onde haverá o vencimento do lote.
							nPerLote++
							oDominio:oDados:criaMatriz(cFilAux, cProduto, cOpcional, nPerLote)
						EndIf
					EndIf
				EndIf

				/**
				* AS INFORMAÇÕES DE LOG E RASTREIO CONTINUAM A SER GRAVADAS REGISTRO A REGISTRO
				* A MANIPULAÇÃO DO SALDO INICIAL ACUMULADO POR PRODUTO/FILIAL PELO P.E. P712SINI DEIXARÁ A INFORMAÇÃO DE LOG E RASTREIO DISTORCIDAS
				*/

				If lRastroEnt .And. nSaldo > 0 .And. !Empty(aRasAux)
					oDominio:oRastreioEntradas:addSaldoInicial(cFilAux, aPeriodos[1], cProduto, aRasAux, cOpcional)
				EndIf
				aSize(aRasAux, 0)

				aAux[PRD_SLDDIS] := IIF(aAux[PRD_SLDDIS] == Nil,0,aAux[PRD_SLDDIS]) + nSaldo

				nContador++

				//Atualiza contador de registros lidos
				If Mod(nContador, 50) == 0
					oProdutos:setFlag("qtd_registros_lidos", nContador, , , .T.)
					nContador := 0
				EndIf

				(cAliasQry)->(dbSkip())

				If (cAliasQry)->(Eof()) .Or. ((cFilAux + PadR((cAliasQry)->HWA_PROD, oCarga:nTamCod)) != cChave)
					cOldChave := cChave
					If oTotNiveis["nProdutosN"] == Nil
						oTotNiveis["nProdutosN"][aAux[PRD_NIVEST]] := 1
					Else
						oTotNiveis["nProdutosN"][aAux[PRD_NIVEST]]++
					EndIf
					oTotNiveis["nProdutosN"][aAux[PRD_NIVEST]] := 0

					If lLogAtivo .And. aAux[PRD_ESTSEG] > 0
						cChaveLog := oLogs:montaChaveLog(cFilAux, cProduto, cOpcional, 1)
						oLogs:gravaLog("calculo", cChaveLog, {"Desconto de " + cValToChar(aAux[PRD_ESTSEG]) + " do saldo inicial devido ao Estoque de Seguranca. Calculo realizado: Saldo (" + cValToChar(aAux[PRD_SLDDIS]) + ") - aAux[PRD_ESTSEG] (" + cValToChar(aAux[PRD_ESTSEG]) + ")"}, .F. /*lWrite*/)
					EndIf

					aAux[PRD_SLDDIS] -= aAux[PRD_ESTSEG]

					If !Empty(cOpcional)
						oOpcionais:registraDadosOpcDefault(cChave, cOpcional, aAux[PRD_SLDDIS], aAux[PRD_ESTSEG], aAux[PRD_PPED])
						aAux[PRD_SLDDIS] := 0
						aAux[PRD_ESTSEG] := 0
						aAux[PRD_PPED  ] := 0
					EndIf

					If lP712SINI
						nSldPE := ExecBlock("P712SINI",.F.,.F.,{aAux[PRD_COD], aAux[PRD_SLDDIS], Iif(lUsaME, aAux[PRD_FILIAL], cFilAnt)})
						If ValType(nSldPE) == "N"
							aAux[PRD_SLDDIS] := nSldPE
						EndIf
					EndIf

					If !oProdutos:addRow(cChave, aAux)
						If oStatus:getStatus("status") == "4"
							Exit
						EndIf
					EndIf

					If lVenceuLot
						/*
							Se houve vencimento de lotes nos períodos do cálculo,
							registra o 1° período na matriz para que o saldo inicial
							seja gravado corretamente na HWB caso não exista nenhuma necessidade
							até o vencimento dos lotes
						*/
						oDominio:oDados:criaMatriz(cFilAux, cProduto, cOpcional, 1)

						//Grava flag identificando que haverá lote vencido para o produto+data
						cChave := "LTVENC" + CHR(10) +;
						          cFilAux + cProduto + Iif(!Empty(cOpcional) , "|" + cOpcional, "") +;
						          DtoS(oDominio:oPeriodos:retornaDataPeriodo(cFilAux, 1))

						oDominio:oDados:oMatriz:setFlag(cChave, .T., .F., .F.)
					EndIf

					aAux := Array(TAM_PRD)
					aAux[PRD_LOTVNC] := {}
					lVenceuLot := .F.
				EndIf

			End
			(cAliasQry)->(dbCloseArea())
		Next nIndFil
	EndIf

	oCarga:registraDocumentos("T4V")

	If oDominio:oParametros["lEMTerceiro"]
		oCarga:registraDocumentos("ET")
	EndIf

	If oDominio:oParametros["lDETerceiro"]
		oCarga:registraDocumentos("DT")
	EndIf

	If oDominio:oParametros["lSubtraiLoteBloqueado"]
		oCarga:registraDocumentos("SB")
	EndIf

	If oDominio:oParametros["lSubtraiRejeitosCQ"] .And. lHWX
		oCarga:registraDocumentos("HWX")
		FreeObj(oCQRejUsad)
	EndIf


	If lRastroEnt
		oDominio:oRastreioEntradas:efetivaInclusao()
	EndIf

	//Atualiza contador de registros lidos
	If nContador > 0
		oProdutos:setFlag("qtd_registros_lidos", nContador, , , .T.)
		nContador := 0
	EndIf

	//Atualiza totalizador de produtos por nível
	aNames := oTotNiveis["nProdutosN"]:GetNames()
	nTotal := Len(aNames)
	For nIndItem := 1 to nTotal
		oProdutos:setflag("nProdutosN" + aNames[nIndItem], oTotNiveis["nProdutosN"][aNames[nIndItem]], .F., .F., .T.) //incrementa
	Next

	//Atualiza contador de produtos calculados por nível
	aNames := oTotNiveis["nProdCalcN"]:GetNames()
	nTotal := Len(aNames)
	For nIndItem := 1 to nTotal
		oProdutos:setflag("nProdCalcN" + aNames[nIndItem], oTotNiveis["nProdCalcN"][aNames[nIndItem]], .F., .F., .T.) //incrementa
	Next
	aSize(aNames, 0)

	//Grava flag de conclusão global
	oProdutos:setFlag("termino_carga", "S")

	If lLogAtivo
		oLogs:gravaLog("carga_memoria", "Produtos (HWA)", {"Fim da carga. Tempo: " + cValToChar(MicroSeconds() - nTempoCarg)})
	EndIf

	//Limpa os arrays da memória
	aSize(aAux, 0)
	aAux := Nil
	aSize(aFields, 0)
	aFields := Nil
	aSize(aRegEmJson, 0)
	aRegEmJson := Nil
	aSize(aRegistro, 0)
	aRegistro := Nil
	aSize(aRetPE, 0)
	aRetPE := Nil

	FreeObj(oTotNiveis["nProdutosN"])
	FreeObj(oTotNiveis["nProdCalcN"])
	FreeObj(oTotNiveis)

Return

/*/{Protheus.doc} identificaProdutos
Verifica quais produtos devem ser considerados pelo MRP

@author lucas.franca
@since 15/06/2021
@version 1.0
/*/
METHOD identificaProdutos() CLASS MrpDados_Carga_Engenharia

	If Self:oCarga:utilizaCargaSeletiva()
		MrpIdentPr(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} tipoPeriodoAglutinaProduto
Converte o valor de aglutinação de produto (MI_AGLUMRP)
no número correspondente ao tipo de período do MRP, sendo:
1-Diário/2-Semanal/3-Quinzenal/4-Mensal/5-Semestral
Valores do MI_AGLUMRP:
'2'-Diário/'3'-Semanal/'4'-Quinzenal/'5'-Mensal/'7'-Semestral

@author lucas.franca
@since 15/06/2021
@version P12
@param 01 cTipoAglut, Caracter, Valor do MI_AGLUMRP para conversão
@return nPeriodo, Numeric, Tipo do período do MRP.
/*/
METHOD tipoPeriodoAglutinaProduto(cTipoAglut) CLASS MrpDados_Carga_Engenharia
	Local nPeriodo As Numeric

	nPeriodo := 0

	If _oTpAglPrd == Nil
		_oTpAglPrd := JsonObject():New()
		_oTpAglPrd["2"] := 1
		_oTpAglPrd["3"] := 2
		_oTpAglPrd["4"] := 3
		_oTpAglPrd["5"] := 4
		_oTpAglPrd["7"] := 5
	EndIf

	If _oTpAglPrd:HasProperty(cTipoAglut)
		nPeriodo := _oTpAglPrd[cTipoAglut]
	EndIf

Return nPeriodo

/*/{Protheus.doc} MrpIdentPr
Verifica os produtos que devem ser considerados pelo MRP

@author lucas.franca
@since 15/06/2021
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpIdentPr(cTicket)
	Local aPeriodos  := {}
	Local cBanco     := ""
	Local cInsert    := ""
	Local cSqlBasePR := ""
	Local cSqlEstrut := ""
	Local cSqlIns    := ""
	Local cWhere     := ""
	Local cWhereIN   := ""
	Local lHorFirme  := .F.
	Local lHWX       := .F.
	Local lLogAtivo  := .F.
	Local lUsaME     := .F.
	Local lConsidLt  := .F.
	Local nIndWhile  := 0
	Local nQtdOri    := 0
	Local nQtdPos    := 0
	Local nTempoCarg := MicroSeconds()
	Local nTempoQry  := 0
	Local oCarga     := Nil
	Local oCargaDocs := Nil
	Local oDominio   := Nil
	Local oLogs      := Nil
	Local oMultiEmp  := Nil
	Local oProdutos  := Nil
	Local oStatus    := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket, .T.)
	oCargaDocs := MrpDados_Carga_Documentos():New()
	oCarga     := oDominio:oDados:oCargaMemoria
	oLogs      := oDominio:oDados:oLogs
	oMultiEmp  := oDominio:oMultiEmp
	oProdutos  := oDominio:oDados:oProdutos
	oStatus    := MrpDados_Status():New(cTicket)
	lLogAtivo  := oLogs:logAtivado()

	//Busca os registros a serem processados
	If oStatus:preparaAmbiente(oDominio:oDados)
		aPeriodos := oDominio:oPeriodos:retornaArrayPeriodos()
		lConsidLt := FindFunction("mrpLoteCQ") .And. mrpLoteCQ()
		lUsaME    := oMultiEmp:utilizaMultiEmpresa()
		lHWX      := FWAliasInDic("HWX",.F.)
		lHorFirme := oDominio:oParametros["lHorizonteFirme"] .And. "|1.1|" $ oDominio:oParametros["cDocumentType"]
		cBanco    := TCGetDB()

		cInsert := "INSERT INTO " + RetSqlName("SMM") + " (MM_FILIAL, MM_TICKET, MM_PROD, D_E_L_E_T_, R_E_C_D_E_L_) "
		cSqlIns := "SELECT DISTINCT '"+xFilial("SMM")+"', '"+cTicket+"', HWA.HWA_PROD, ' ', 0 "
		cSqlIns +=  " FROM " + RetSqlName("HWA") + " HWA "

		//Se utiliza SBZ (HWE) faz o relation para verificar as políticas de estoque.
		If oDominio:oParametros["lUsesProductIndicator"]
			cSqlIns += " LEFT JOIN " + RetSqlName("HWE") + " HWE "
			cSqlIns +=   " ON " + oMultiEmp:queryFilial("HWE", "HWE_FILIAL", .T.)
			cSqlIns +=  " AND HWE.D_E_L_E_T_ = ' ' "
			cSqlIns +=  " AND HWE.HWE_PROD   = HWA.HWA_PROD "
		EndIf

		cSqlIns += " WHERE HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"
		cSqlIns +=   " AND HWA.D_E_L_E_T_ = ' ' "
		//Adiciona filtros seletivos do MRP.
		cSqlIns +=   " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("HWA.HWA_PROD", .F., .F., .F.)
		//Não carrega produtos bloqueados.
		cSqlIns +=   " AND HWA.HWA_BLOQUE <> '1'"
		//Não carrega produtos de nível 1 que estejam com o parâmetro HWA_MRP=Não.
		cSqlIns +=   " AND NOT ( "
		If oDominio:oParametros["lUsesProductIndicator"]
			cSqlIns +=          " ( (HWE.HWE_MRP IS NULL AND HWA.HWA_MRP = '2') "
			cSqlIns +=         " OR (HWE.HWE_MRP IS NOT NULL AND HWE.HWE_MRP = '2') )"
		Else
			cSqlIns +=            " HWA.HWA_MRP = '2' "
		EndIf

		cSqlIns +=            " AND EXISTS (SELECT T4N.T4N_PROD "
		cSqlIns +=                          " FROM " + RetSqlName("T4N") + " T4N "
		cSqlIns +=                         " WHERE " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		cSqlIns +=                           " AND T4N.D_E_L_E_T_ = ' ' "
		cSqlIns +=                           " AND T4N.T4N_PROD = HWA.HWA_PROD "
		cSqlIns +=                           " AND NOT EXISTS(SELECT 1 "
		cSqlIns +=                                            " FROM " + RetSqlName("T4N") + " T4NAUX "
		cSqlIns +=                                           " WHERE T4NAUX.T4N_FILIAL = T4N.T4N_FILIAL "
		cSqlIns +=                                             " AND T4NAUX.D_E_L_E_T_ = ' ' "
		cSqlIns +=                                             " AND T4NAUX.T4N_COMP   = T4N.T4N_PROD))) "

		//Guarda a query base de Produtos para uso posterior
		cSqlBasePR := cSqlIns

		//Adiciona filtro dos produtos que devem entrar no cálculo.
		cSqlIns +=   " AND EXISTS("
		//Adiciona condições para produtos com empenhos
		cSqlIns +=              " SELECT 1 "
		cSqlIns +=                " FROM " + RetSqlName("T4S") + " T4S "
		cSqlIns +=          " INNER JOIN " + RetSqlName("T4Q") + " T4Q "
		cSqlIns +=                  " ON T4Q.T4Q_OP  = T4S.T4S_OP "
		If lUsaME
			cSqlIns +=             " AND T4Q.T4Q_FILIAL = T4S.T4S_FILIAL "
		Else
			cSqlIns +=             " AND T4Q.T4Q_FILIAL = '" + xFilial("T4Q") + "' "
		EndIf

		cWhere := oCargaDocs:whereT4Q(oDominio, lHorFirme, .F., /*4*/, /*5*/, .F.)

		//Atribui Filtro Relacionado ao Horizonte Firme
		If lHorFirme
			cWhereIN := ""
			MrpDominio_HorizonteFirme():criaScriptIN(oDominio:oParametros["dDataIni"], "T4Q", "T4Q_PROD", "T4Q_DATA", cWhere, @cWhereIN, oDominio)
			cWhere += " AND ((T4Q.T4Q_TIPO <> '1') OR (T4Q.R_E_C_N_O_ IN ("
			cWhere += cWhereIN
			cWhere += ")))"
		EndIf

		cSqlIns +=                 " AND " + cWhere
		cSqlIns +=               " WHERE " + oMultiEmp:queryFilial("T4S", "T4S_FILIAL", .T.)
		cSqlIns +=                 " AND T4S.D_E_L_E_T_ = ' ' "
		cSqlIns +=                 " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4S.T4S_PROD")    //Valida o filtro de Tipo ou Grupo de Produtos

		If !("|2|" $ oDominio:oParametros["cDocumentType"])
			cSqlIns +=             " AND (T4S.T4S_QTD - T4S.T4S_QSUSP) <> 0 "
		EndIf

		//Parâmetro para filtrar os armazéns
		If !Empty(oDominio:oParametros["cWarehouses"])
			cSqlIns +=             " AND " + oDominio:oSeletivos:scriptInSQL("T4S.T4S_LOCAL", "cWarehouses")
		EndIf

		//Condição de relacionamento com o EXISTS da tabela HWA
		cSqlIns +=                 " AND T4S.T4S_PROD   = HWA.HWA_PROD "

		//Adiciona condições para produtos com ordem de produção com saldo.
		cSqlIns +=              " UNION "
		cSqlIns +=              " SELECT 1 "
		cSqlIns +=                " FROM " + RetSqlName("T4Q") + " T4Q "

		cWhere := oCargaDocs:whereT4Q(oDominio, lHorFirme, .T., .T., .T., .T.)
		cWhere +=                  " AND T4Q.T4Q_PROD   = HWA.HWA_PROD "
		//Atribui Filtro Relacionado ao Horizonte Firme
		If lHorFirme
			cWhereIN := ""
			MrpDominio_HorizonteFirme():criaScriptIN(oDominio:oParametros["dDataIni"], "T4Q", "T4Q_PROD", "T4Q_DATA", cWhere, @cWhereIN, oDominio)
			cWhere += " AND ((T4Q.T4Q_TIPO <> '1') OR (T4Q.R_E_C_N_O_ IN ("
			cWhere += cWhereIN
			cWhere += ")))"
		EndIf
		cSqlIns +=               " WHERE " + cWhere

		//Adiciona condições para produtos com saldo negativo
		cSqlIns +=              " UNION "
		cSqlIns +=              " SELECT 1 "
		cSqlIns +=                " FROM " + RetSqlName("T4V") + " T4V "

		//Relaciona Tabela de Rejeitos em CQ
		If oDominio:oParametros["lSubtraiRejeitosCQ"] .And. lHWX
			cSqlIns += " LEFT OUTER JOIN ( SELECT HWX.HWX_FILIAL, "
			cSqlIns +=                          " HWX.HWX_PROD, "
			cSqlIns +=                          " HWX.HWX_LOCAL, "
			If lConsidLt
				cSqlIns +=                      " HWX.HWX_LOTE, "
				cSqlIns +=                      " HWX.HWX_SLOTE, "
			EndIf
			cSqlIns +=                          " SUM(HWX.HWX_QTDE - HWX.HWX_QTDEV) HWXTOT "
			cSqlIns +=                     " FROM " + RetSqlName("HWX") + " HWX "
			cSqlIns +=                    " WHERE " + oMultiEmp:queryFilial("HWX", "HWX_FILIAL", .T.)
			If Len(aPeriodos) > 1
				cSqlIns +=                  " AND HWX.HWX_DATNF < '" + DToS(aPeriodos[2]) + "' "
			Else
				cSqlIns +=                  " AND HWX.HWX_DATNF <= '" + DToS(aPeriodos[1]) + "' "
			EndIf
			//Adiciona filtro de armazéns
			If !Empty(oDominio:oParametros["cWarehouses"])
				cSqlIns +=                  " AND " + oDominio:oSeletivos:scriptInSQL("HWX.HWX_LOCAL", "cWarehouses")
			EndIf

			//Relaciona com a tabela de armazéns (HWY)
			cSqlIns += localMRP("HWX.HWX_LOCAL", oMultiEmp:queryFilial("HWY", "", .F.))

			//Adiciona agrupamento para o SUM das quantidades e relaciona com o produto/armazém.
			cSqlIns +=                    " GROUP BY HWX.HWX_FILIAL, HWX.HWX_PROD, HWX.HWX_LOCAL "
			If lConsidLt
				cSqlIns +=                        ", HWX.HWX_LOTE, HWX.HWX_SLOTE "
			EndIf
			cSqlIns +=                  ") REJCQ ON REJCQ.HWX_PROD  = T4V.T4V_PROD "
			cSqlIns +=                        " AND REJCQ.HWX_LOCAL = T4V.T4V_LOCAL "
			If lConsidLt
				cSqlIns +=                  " AND REJCQ.HWX_LOTE  = T4V.T4V_LOTE "
				cSqlIns +=                  " AND REJCQ.HWX_SLOTE = T4V.T4V_SLOTE "
			EndIf
			cSqlIns += " AND " + oCarga:relacionaFilial("T4V", "T4V", "T4V_FILIAL", "HWX", "REJCQ", "HWX_FILIAL", .T., .F., .F.)
		EndIf

		cSqlIns +=               " WHERE " + oMultiEmp:queryFilial("T4V", "T4V_FILIAL", .T.)
		cSqlIns +=                 " AND T4V.D_E_L_E_T_ = ' ' "
		cSqlIns +=                 " AND T4V.T4V_PROD   = HWA.HWA_PROD "
		//Valida o filtro de Tipo ou Grupo de Produtos
		cSqlIns +=                 " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4V.T4V_PROD")

		//Parâmetro para filtrar os armazéns
		If !Empty(oDominio:oParametros["cWarehouses"])
			cSqlIns +=             " AND " + oDominio:oSeletivos:scriptInSQL("T4V.T4V_LOCAL", "cWarehouses")
		EndIf

		If !oDominio:oParametros["lExpiredLot"]
			cSqlIns +=             " AND (T4V_LOTE = ' ' OR T4V_VALID >= '" + DToS(aPeriodos[1]) + "') "
		EndIf

		If lUsaME
			cSqlIns += localMRP("T4V.T4V_LOCAL", oMultiEmp:queryFilial("HWY", "", .F.))
		Else
			cSqlIns += localMRP("T4V.T4V_LOCAL", " = '" + xFilial("HWY") + "'")
		EndIf

		cSqlIns +=                 " AND T4V.T4V_QTD "

		//Se o parâmetro da tela "Estoque EM Terceiro" estiver como "1 - Soma", soma o valor do campo T4V_QNPT
		If oDominio:oParametros["lEMTerceiro"]
			cSqlIns +=             " + T4V.T4V_QNPT "
		EndIf
		//Se o parâmetro da tela "Estoque DE Terceiro" estiver como "1 - Subtrai", subtrai o valor do campo T4V_QTNP
		If oDominio:oParametros["lDETerceiro"]
			cSqlIns +=             " - T4V.T4V_QTNP "
		EndIf
		//Se o parâmetro da tela "Saldo Bloqueado por Lote" estiver como "1 - Subtrai", subtrai o valor do campo T4V_SLDBQ
		If oDominio:oParametros["lSubtraiLoteBloqueado"]
			cSqlIns +=             " - T4V.T4V_SLDBQ "
		EndIf
		//Se o parâmetro da tela "Estoque Rejeitado pelo CQ" estiver como "1 - Subtrai", subtrai o valor do campo (HWX_QTDE - HWX_QTDEV)
		If lHWX .And. oDominio:oParametros["lSubtraiRejeitosCQ"]
			cSqlIns +=             " - COALESCE( REJCQ.HWXTOT, 0) "
		EndIf
		cSqlIns +=                        " < 0"

		//Adiciona condições para os produtos alternativos
		cSqlIns +=              " UNION "
		cSqlIns +=              " SELECT 1 "
		cSqlIns +=                " FROM " + RetSqlName("T4O") + " T4O "
		cSqlIns +=               " WHERE " + oMultiEmp:queryFilial("T4O", "T4O_FILIAL", .T.)
		cSqlIns +=                 " AND T4O.D_E_L_E_T_ = ' ' "
		cSqlIns +=                 " AND T4O.T4O_ALTERN = HWA.HWA_PROD "

		//Adiciona condições para os produtos com demandas
		cSqlIns +=              " UNION "
		cSqlIns +=              " SELECT 1 "
		cSqlIns +=                " FROM " + RetSqlName("T4J") + " T4J "
		cSqlIns +=               " WHERE " + oMultiEmp:queryFilial("T4J", "T4J_FILIAL", .T.)
		cSqlIns +=                 " AND T4J.D_E_L_E_T_ = ' ' "
		cSqlIns +=                 " AND T4J.T4J_PROC   = '3' "
		cSqlIns +=                 " AND T4J.T4J_PROD   = HWA.HWA_PROD )"

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Carga Seletiva 1 (SMM)", {"Produtos que possuem algum documento: " + cInsert + cSqlIns})
			nTempoQry := MicroSeconds()
		EndIf

		//Insere na SMM os produtos que possuem algum documento
		If TcSqlExec(cInsert + cSqlIns) < 0
			oStatus:gravaErro("memoria", STR0094) //"Erro ao identificar os produtos para processamento."
			Return
		EndIf

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Carga Seletiva 1 (SMM)", {"Tempo da query: " + cValToChar(MicroSeconds() - nTempoQry)})
		EndIf

		//Faz a verificação para inserir na SMM produtos que não possuem nenhum documento, mas que possuem estoque de segurança ou ponto de pedido
		If oDominio:oParametros["lEstoqueSeguranca"] .Or. oDominio:oParametros["lPontoPedido"]
			cSqlIns := cSqlBasePR
			cSqlIns += " AND ("
			//Especifica as condições para estoque de segurança e ponto de pedido
			If oDominio:oParametros["lEstoqueSeguranca"]
				If oDominio:oParametros["lUsesProductIndicator"]
					cSqlIns +=    " ( (HWE.HWE_ESTSEG IS NULL AND HWA.HWA_ESTSEG <> 0) "
					cSqlIns +=   " OR (HWE.HWE_ESTSEG IS NOT NULL AND HWE.HWE_ESTSEG <> 0) )"
				Else
					cSqlIns += " HWA.HWA_ESTSEG <> 0 "
				EndIf
			EndIf
			If oDominio:oParametros["lPontoPedido"]
				If oDominio:oParametros["lEstoqueSeguranca"]
					//Se utiliza estoque de segurança adiciona o OR para complementar a query anterior
					cSqlIns += " OR "
				EndIf
				If oDominio:oParametros["lUsesProductIndicator"]
					cSqlIns +=    " ( (HWE.HWE_EMIN IS NULL AND HWA.HWA_EMIN <> 0) "
					cSqlIns +=   " OR (HWE.HWE_EMIN IS NOT NULL AND HWE.HWE_EMIN <> 0) )"
				Else
					cSqlIns += " HWA.HWA_EMIN   <> 0 "
				EndIf
			EndIf
			cSqlIns += " ) "

			//Adiciona filtro para não incluir produtos duplicados na SMM
			cSqlIns += " AND NOT EXISTS(SELECT 1 "
			cSqlIns +=                  " FROM " + RetSqlName("SMM") + " SMM "
			cSqlIns +=                 " WHERE SMM.MM_FILIAL  = '" + xFilial("SMM") + "'"
			cSqlIns +=                   " AND SMM.D_E_L_E_T_ = ' ' "
			cSqlIns +=                   " AND SMM.MM_TICKET  = '" + cTicket + "' "
			cSqlIns +=                   " AND SMM.MM_PROD    = HWA.HWA_PROD ) "

			If lLogAtivo
				oLogs:gravaLog("carga_memoria", "Carga Seletiva 2 (SMM)", {"Produtos que possuem estoque de seguranca ou ponto de pedido: " + cInsert + cSqlIns})
				nTempoQry := MicroSeconds()
			EndIf

			//Insere na SMM os produtos que possuem estoque de segurança ou ponto de pedido, conforme parametrização do MRP.
			If TcSqlExec(cInsert + cSqlIns) < 0
				oStatus:gravaErro("memoria", STR0094) //"Erro ao identificar os produtos para processamento."
				Return
			EndIf

			If lLogAtivo
				oLogs:gravaLog("carga_memoria", "Carga Seletiva 2 (SMM)", {"Tempo da query: " + cValToChar(MicroSeconds() - nTempoQry)})
			EndIf
		EndIf

		//Faz a carga das estruturas dos produtos identificados.
		cSqlEstrut := "WITH PRODUTOMRP (T4N_PROD, T4N_COMP) "
		cSqlEstrut += " AS (SELECT T4N.T4N_PROD, T4N.T4N_COMP "
		cSqlEstrut +=       " FROM " + RetSqlName("T4N") + " T4N "
		cSqlEstrut +=      " INNER JOIN " + RetSqlName("SMM") + " SMM "
		cSqlEstrut +=              " ON SMM.MM_FILIAL  = '" + xFilial("SMM") + "'"
		cSqlEstrut +=             " AND SMM.D_E_L_E_T_ = ' ' "
		cSqlEstrut +=             " AND SMM.MM_TICKET  = '" + cTicket + "' "
		cSqlEstrut +=             " AND T4N.T4N_PROD   = SMM.MM_PROD "
		If lUsaME
			cSqlEstrut +=  " WHERE " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		Else
			cSqlEstrut +=  " WHERE T4N.T4N_FILIAL = '" + xFilial("T4N") + "'"
		EndIf
		cSqlEstrut +=        " AND T4N.D_E_L_E_T_ = ' ' "
		cSqlEstrut +=        " AND T4N.T4N_DTINI  <= '" + DtoS(oDominio:oPeriodos:ultimaDataDoMRP()) + "' "
		cSqlEstrut +=        " AND T4N.T4N_DTFIM  >= '" + DtoS(aPeriodos[1]) + "' "
		cSqlEstrut +=        " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4N.T4N_COMP", .T., /*lValidMRP*/, /*lUsaExists*/, .F.)
		cSqlEstrut +=        " AND NOT EXISTS(SELECT 1 "
		cSqlEstrut +=                         " FROM " + RetSqlName("SMM") + " SMM "
		cSqlEstrut +=                        " WHERE SMM.MM_FILIAL  = '" + xFilial("SMM") + "'"
		cSqlEstrut +=                          " AND SMM.D_E_L_E_T_ = ' ' "
		cSqlEstrut +=                          " AND SMM.MM_TICKET  = '" + cTicket + "' "
		cSqlEstrut +=                          " AND SMM.MM_PROD    = T4N.T4N_COMP ) "

		cSqlEstrut +=      " UNION ALL "

		cSqlEstrut +=     " SELECT T4N.T4N_PROD, T4N.T4N_COMP "
		cSqlEstrut +=       " FROM " + RetSqlName("T4N") + " T4N "
		cSqlEstrut +=      " INNER JOIN PRODUTOMRP "
		cSqlEstrut +=              " ON T4N.T4N_PROD = PRODUTOMRP.T4N_COMP "
		cSqlEstrut +=      " WHERE " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		cSqlEstrut +=        " AND T4N.D_E_L_E_T_ = ' ' "
		cSqlEstrut +=        " AND T4N.T4N_DTINI  <= '" + DtoS(oDominio:oPeriodos:ultimaDataDoMRP()) + "' "
		cSqlEstrut +=        " AND T4N.T4N_DTFIM  >= '" + DtoS(aPeriodos[1]) + "' "
		cSqlEstrut +=        " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4N.T4N_COMP", .T., /*lValidMRP*/, /*lUsaExists*/, .F.)
		cSqlEstrut +=        " AND NOT EXISTS(SELECT 1 "
		cSqlEstrut +=                         " FROM " + RetSqlName("SMM") + " SMM "
		cSqlEstrut +=                        " WHERE SMM.MM_FILIAL  = '" + xFilial("SMM") + "'"
		cSqlEstrut +=                          " AND SMM.D_E_L_E_T_ = ' ' "
		cSqlEstrut +=                          " AND SMM.MM_TICKET  = '" + cTicket + "' "
		cSqlEstrut +=                          " AND SMM.MM_PROD    = T4N.T4N_COMP )) "

		If cBanco != "ORACLE"
			cSqlEstrut += cInsert
		EndIf
		cSqlEstrut += " SELECT DISTINCT '"+xFilial("SMM")+"', '"+cTicket+"', T4N_COMP, ' ', 0 "
		cSqlEstrut +=   " FROM PRODUTOMRP "

		If cBanco == "ORACLE"
			cSqlEstrut := cInsert + cSqlEstrut
		EndIf

		If cBanco == "POSTGRES"
			//Altera sintaxe da clausula WITH
			cSqlEstrut := StrTran(cSqlEstrut, 'WITH ', 'WITH recursive ')
		EndIf

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Carga Seletiva 3 (SMM)", {"Estruturas dos produtos identificados: " + cSqlEstrut})
			nTempoQry := MicroSeconds()
		EndIf

		If TcSqlExec(cSqlEstrut) < 0
			oStatus:gravaErro("memoria", STR0095) //"Erro ao identificar os produtos (componentes) para processamento."
			Return
		EndIf

		If lLogAtivo
			oLogs:gravaLog("carga_memoria", "Carga Seletiva 3 (SMM)", {"Tempo da query: " + cValToChar(MicroSeconds() - nTempoQry)})
		EndIf

		//Inicia a carga de subprodutos e suas estruturas.
		cSqlIns := " WITH SUBPRD(MM_PROD, HWA_ESTORI, T4N_PROD) AS ("
		cSqlIns += " SELECT SMM.MM_PROD, HWA.HWA_ESTORI, T4N.T4N_PROD"
		cSqlIns +=   " FROM " + RetSqlName("SMM") + " SMM "
		cSqlIns +=  " INNER JOIN " + RetSqlName("HWA") + " HWA "
		cSqlIns +=     " ON HWA.HWA_PROD   = SMM.MM_PROD "
		cSqlIns +=    " AND HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"
		cSqlIns +=    " AND HWA.D_E_L_E_T_ = ' ' "
		cSqlIns +=    " AND HWA.HWA_PROSBP = '1' "
		cSqlIns +=  " INNER JOIN " + RetSqlName("T4N") + " T4N "
		cSqlIns +=     " ON " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		cSqlIns +=    " AND T4N.T4N_COMP   = SMM.MM_PROD "
		cSqlIns +=    " AND T4N.T4N_QTD    < 0 "
		cSqlIns +=    " AND T4N.D_E_L_E_T_ = ' ' "
		cSqlIns +=    " AND (T4N.T4N_PROD  = HWA.HWA_ESTORI OR HWA.HWA_ESTORI = ' ' ) "
		cSqlIns +=  " WHERE SMM.MM_FILIAL  = '" + xFilial("SMM") + "'"
		cSqlIns +=    " AND SMM.MM_TICKET  = '" + cTicket + "' "
		cSqlIns +=    " AND SMM.D_E_L_E_T_ = ' ' "
		cSqlIns +=  " UNION ALL "
		cSqlIns += " SELECT T4N.T4N_COMP, T4N.T4N_PROD AS HWA_ESTORI, T4N.T4N_PROD "
		cSqlIns +=   " FROM " + RetSqlName("T4N") + " T4N "
		cSqlIns +=  " INNER JOIN SUBPRD "
		cSqlIns +=     " ON SUBPRD.T4N_PROD = T4N.T4N_COMP "
		cSqlIns += 	  " AND (T4N.T4N_FANTAS  = 'T' OR T4N.T4N_QTD < 0) "
		cSqlIns +=  " WHERE " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
		cSqlIns +=    " AND T4N.D_E_L_E_T_ = ' ' ) "

		If cBanco != "ORACLE"
			cSqlIns += cInsert
		EndIf
		cSqlIns += " SELECT DISTINCT '"+xFilial("SMM")+"', '"+cTicket+"', T4N_PROD, ' ', 0 "
		cSqlIns +=   " FROM SUBPRD "
		cSqlIns +=  " WHERE NOT EXISTS(SELECT 1 "
		cSqlIns +=                     " FROM " + RetSqlName("SMM") + " SMM "
		cSqlIns +=                    " WHERE SMM.MM_FILIAL  = '" + xFilial("SMM") + "'"
		cSqlIns +=                      " AND SMM.D_E_L_E_T_ = ' ' "
		cSqlIns +=                      " AND SMM.MM_TICKET  = '" + cTicket + "' "
		cSqlIns +=                      " AND SMM.MM_PROD    = T4N_PROD) "

		If cBanco == "ORACLE"
			cSqlIns := cInsert + cSqlIns
		EndIf

		If cBanco == "POSTGRES"
			//Altera sintaxe da clausula WITH
			cSqlIns := StrTran(cSqlIns, 'WITH ', 'WITH recursive ')
		EndIf

		//Enquanto encontrar subprodutos, faz a query de carga de estruturas e de subprodutos,
		//até que todos os subprodutos sejam carregados.

		//Verifica a quantidade original de registros na SMM.
		nQtdOri := countSMM(cTicket,oDominio:oDados:oCargaMemoria)
		While .T.
			If lLogAtivo
				oLogs:gravaLog("carga_memoria", "Carga Seletiva 4 (SMM)", {"Subprodutos e suas estruturas: " + cSqlIns})
				nTempoQry := MicroSeconds()
			EndIf

			If TcSqlExec(cSqlIns) < 0
				oStatus:gravaErro("memoria", STR0097) //"Erro ao identificar os sub-produtos para processamento."
				Return
			EndIf

			If lLogAtivo
				oLogs:gravaLog("carga_memoria", "Carga Seletiva 4 (SMM)", {"Tempo da query: " + cValToChar(MicroSeconds() - nTempoQry)})
			EndIf

			//Checa cancelamento a cada X execucoes
			If (nIndWhile == 1 .OR. Mod(nIndWhile, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
				Exit
			EndIf
			nIndWhile++

			nQtdPos := countSMM(cTicket,oDominio:oDados:oCargaMemoria)

			If nQtdPos > nQtdOri
				nQtdOri := nQtdPos

				If lLogAtivo
					oLogs:gravaLog("carga_memoria", "Carga Seletiva 5 (SMM)", {"Estruturas dos subprodutos: " + cSqlEstrut})
					nTempoQry := MicroSeconds()
				EndIf

				//Foram encontrados subprodutos. Executa a inserção de Estruturas.
				If TcSqlExec(cSqlEstrut) < 0
					oStatus:gravaErro("memoria", STR0098) //"Erro ao identificar os componentes de sub-produtos para processamento."
					Return
				EndIf

				If lLogAtivo
					oLogs:gravaLog("carga_memoria", "Carga Seletiva 5 (SMM)", {"Tempo da query: " + cValToChar(MicroSeconds() - nTempoQry)})
				EndIf

				nQtdPos := countSMM(cTicket,oDominio:oDados:oCargaMemoria)
				If nQtdPos == nQtdOri
					//Se não foi inserido nenhum novo produto, interrompe o loop.
					Exit
				Else
					nQtdOri := nQtdPos
				EndIf
			Else
				//Não inseriu nenhum novo registro, interrompe o loop.
				Exit
			EndIf
		End
	EndIf

	//Grava flag de conclusão global
	oProdutos:setFlag("identificados_termino_carga", "S")

	If lLogAtivo
		oLogs:gravaLog("carga_memoria", "Carga Seletiva (SMM)", {"Fim da carga. Tempo: " + cValToChar(MicroSeconds() - nTempoCarg)})
	EndIf

Return

/*/{Protheus.doc} countSMM
Conta quantidade de registros da tabela SMM para o ticket.

@type Static Function
@author lucas.franca
@since 06/07/2021
@version P12.1.27
@param cTicket, Character, Número do ticket do MRP
@return nTotal, Numeric  , Quantidade de registros na SMM para o ticket.
/*/
Static Function countSMM(cTicket,oCarga)
	Local cAlias     := GetNextAlias()
	Local cFieldCnt  := ""
	Local nTotal     := 0

	CFieldCnt := "%" + oCarga:trataOptimizerOracle() + " " + "COUNT(*) TOTAL%"

	BeginSql Alias cAlias
		%noparser%
		SELECT %Exp:cFieldCnt%
		  FROM %Table:SMM%
		 WHERE MM_FILIAL = %xfilial:SMM%
		   AND MM_TICKET = %Exp:cTicket%
		   AND %NotDel%
	EndSql

	nTotal := (cAlias)->(TOTAL)
	(cAlias)->(dbCloseArea())
Return nTotal

/*/{Protheus.doc} queryField
Retorna os campos que serão utilizado para carga do produto

@author douglas.heydt
@since 05/12/2019
@version 1.0
@param 01 oDominio, objeto  , instância do objeto de domínio
       02 lUsaME  , lógico  , indica se usa o multi-empresa ou não
@return   cFields , caracter, campos que serão utilizado para carga do produto
/*/
Static Function queryField(oDominio, lUsaME)
	Local cFields    := ""
	Local oCarga     := Nil

    oCarga     := oDominio:oDados:oCargaMemoria

	If oDominio:oParametros["lUsesProductIndicator"]
		cFields += " COALESCE(HWE.HWE_PROD, HWA.HWA_PROD) AS HWA_PROD,"       + ;
				   " COALESCE(HWE.HWE_LE, HWA.HWA_LE) AS HWA_LE,"             + ;
				   " COALESCE(HWE.HWE_PE, HWA.HWA_PE) AS HWA_PE,"             + ;
				   " COALESCE(HWE.HWE_HORFIX, HWA.HWA_HORFIX) AS HWA_HORFIX," + ;
				   " COALESCE(HWE.HWE_TPHFIX, HWA.HWA_TPHFIX) AS HWA_TPHFIX," + ;
				   " COALESCE(HWE.HWE_TIPE, HWA.HWA_TIPE) AS HWA_TIPE,"       + ;
				   " COALESCE(HWE.HWE_LOCPAD, HWA.HWA_LOCPAD) AS HWA_LOCPAD," + ;
				   " COALESCE(HWE.HWE_QE, HWA.HWA_QE) AS HWA_QE,"             + ;
				   " COALESCE(HWE.HWE_LM, HWA.HWA_LM) AS HWA_LM,"             + ;
				   " COALESCE(HWE.HWE_TOLER, HWA.HWA_TOLER) AS HWA_TOLER,"    + ;
				   " COALESCE(HWE.HWE_MRP, HWA.HWA_MRP) AS HWA_MRP,"          + ;
				   " COALESCE(HWE.HWE_EMAX, HWA.HWA_EMAX) AS HWA_EMAX,"

		If fieldsQB()
			cFields += " COALESCE(HWE.HWE_QB, HWA.HWA_QB) AS HWA_QB,"
		EndIf
	Else
		cFields += " HWA.HWA_PROD,"   + ;
		           " HWA.HWA_LE,"     + ;
		           " HWA.HWA_PE,"     + ;
		           " HWA.HWA_HORFIX," + ;
		           " HWA.HWA_TPHFIX," + ;
		           " HWA.HWA_TIPE,"   + ;
		           " HWA.HWA_LOCPAD," + ;
		           " HWA.HWA_QE,"     + ;
		           " HWA.HWA_LM,"     + ;
		           " HWA.HWA_TOLER,"  + ;
		           " HWA.HWA_MRP,"    + ;
		           " HWA.HWA_EMAX,"

		If fieldsQB()
			cFields += " HWA.HWA_QB,"
		EndIf
	EndIf

	cFields += " COALESCE(HWA.HWA_EMIN,0) AS HWA_EMIN,"       + ;
	           " COALESCE(HWA.HWA_ESTSEG,0) AS HWA_ESTSEG,"   + ;
	           " COALESCE(HWA.HWA_TIPDEC,'1') AS HWA_TIPDEC," + ;
	           " COALESCE(HWA.HWA_NUMDEC,'0') AS HWA_NUMDEC," + ;
	           " COALESCE(HWA.HWA_TIPO,'') AS HWA_TIPO,"      + ;
	           " COALESCE(HWA.HWA_GRUPO,'') AS HWA_GRUPO,"    + ;
	           " COALESCE(HWA.HWA_RASTRO,'') AS HWA_RASTRO,"  + ;
	           " COALESCE(HWA.HWA_PROSBP,'') AS HWA_PROSBP,"  + ;
	           " COALESCE(HWA.HWA_LOTSBP,0) AS HWA_LOTSBP,"   + ;
	           " COALESCE(HWA.HWA_ESTORI,'') AS HWA_ESTORI,"  + ;
	           " COALESCE(HWA.HWA_APROPR,'') AS HWA_APROPR,"  + ;
	           " HWA.R_E_C_N_O_ RECHWA,"

	If oDominio:oParametros["revisionInProductIndicator"] == "1" .And. oDominio:oParametros["lUsesProductIndicator"]
		cFields += " COALESCE(HWE.HWE_REVATU, HWA.HWA_REVATU) AS HWA_REVATU,"
	Else
		cFields += " COALESCE(HWA.HWA_REVATU,'') AS HWA_REVATU,"
	EndIf

	//Se usa indicador de produto, acrescenta o campo de estoque de segurança e ponto de pedido da HWE
	If oDominio:oParametros["lUsesProductIndicator"]
		cFields += " COALESCE(HWE.HWE_EMIN,0) AS HWE_EMIN,"   + ;
		           " COALESCE(HWE.HWE_ESTSEG,0) AS HWE_ESTSEG," + ;
		           " COALESCE(HWE.HWE_PROD,'') AS HWE_PROD," + ;
		           " HWE.R_E_C_N_O_ RECHWE,"
	EndIf

	MrpDominio_MOD():retornaCondicaoProdutoMOD(oDominio:oParametros, @cFields)

	cFields += " COALESCE(HWA.HWA_CPOTEN,'2') AS HWA_CPOTEN," + ;
	           " COALESCE(HWA.HWA_BLOQUE,'2') AS HWA_BLOQUE,"

	dbSelectArea("HWA")
	If FieldPos("HWA_ROTOPE") > 0
		cFields += " COALESCE(HWA.HWA_ROTOPE,'') AS HWA_ROTOPE,"
	EndIf

	cFields += " COALESCE(T4V.T4V_QTD,0) AS T4V_QTD,"      +;
	           " COALESCE(T4V.T4V_IDREG,'') AS T4V_IDREG," +;
	           " COALESCE(T4V.T4V_LOCAL,'') AS T4V_LOCAL," +;
	           " COALESCE(T4V.T4V_LOTE,'') AS T4V_LOTE,"   +;
	           " COALESCE(T4V.T4V_SLOTE,'') AS T4V_SLOTE," +;
	           " COALESCE(T4V.T4V_VALID,'') AS T4V_VALID,"

	//Se o parâmetro da tela "Estoque EM Terceiro" estiver como "1 - Soma", carregar para memória o valor do campo T4V_QNPT
	If oDominio:oParametros["lEMTerceiro"]
		cFields += " COALESCE(T4V.T4V_QNPT,0) AS T4V_QNPT,"
	EndIf

	//Se o parâmetro da tela "Estoque DE Terceiro" estiver como 1 - Subtrai", carregar para memória o valor do campo T4V_QTNP
	If oDominio:oParametros["lDETerceiro"]
		cFields += " COALESCE(T4V.T4V_QTNP,0) AS T4V_QTNP,"
	EndIf

	//Se o parâmetro da tela "Saldo Bloqueado por Lote" estiver como "1 - Subtrai", carregar para memória o valor do campo T4V_SLDBQ
	If oDominio:oParametros["lSubtraiLoteBloqueado"]
		cFields += " COALESCE(T4V.T4V_SLDBQ,0) AS T4V_SLDBQ,"
	EndIf

	//Se o parâmetro da tela "Estoque Rejeitado pelo CQ" estiver como "1 - Subtrai", carregar para memória o valor do campo (HWX_QTDE - HWX_QTDEV)
	If oDominio:oParametros["lSubtraiRejeitosCQ"] .And. FWAliasInDic("HWX",.F.)
		cFields += " COALESCE(HWX.HWX_QTDE,0) AS HWX_QTDE," + ;
		           " COALESCE(HWX.HWX_QTDEV,0) AS HWX_QTDEV,"
	EndIf

	If lUsaME
		cFields += " COALESCE(SMB.MB_NIVEL,'99') AS MB_NIVEL," + ;
		           " COALESCE(SMI.MI_LEADTR,0) AS MI_LEADTR,"

		If fldTranSMI()
			cFields += " COALESCE(SMI.MI_TRANSF,'1') AS MI_TRANSF," + ;
			           " COALESCE(SMI.MI_FILCOM,'' ) AS MI_FILCOM,"
		EndIf

		If fldLtMinTr()
			cFields += " COALESCE(SMI.MI_LMTRANS, 0) AS MI_LMTRANS,"
		EndIf

		If oDominio:oParametros["lUsesProductIndicator"]
			cFields += " (SELECT COUNT(1)"                   + ;
			           " FROM " + RetSqlName("HWE") + " HWE" + ;
                       " WHERE HWE.HWE_PROD = HWA.HWA_PROD"  + ;
                       " AND " + oDominio:oMultiEmp:queryFilial("HWE", "HWE_FILIAL", .T.) + ")"
		Else
			cFields += " 0"
		EndIf

		cFields += " AS EXISTE_HWE,"
	Else
		cFields += " HWA.HWA_NIVEL,"
	EndIf

	If FwAliasInDic("SMI", .F.)
		dbSelectArea("SMI")
		If FieldPos("MI_AGLUMRP") > 0
			cFields += " SMI.MI_AGLUMRP,"
		EndIf
	EndIf

	//Campos de opcionais
	cFields += " HWA.HWA_ERPOPC,"
	If oDominio:oParametros["lUsesProductIndicator"]
		cFields += " HWE.HWE_ERPOPC,"
		cFields += " HWE.HWE_ERPMOP,"
		cFields += " HWE.HWE_MOPC, "
	EndIf
	cFields += " HWA.HWA_ERPMOP,"
	cFields += " HWA.HWA_MOPC "

	/*OBS - CAMPOS _ERPMOP E _MOPC DEVEM SER OS ÚLTIMOS CAMPOS DA QUERY POR SEREM DO TIPO MEMO*/

Return cFields

/*/{Protheus.doc} queryProd
Monta a query para carga de produtos

@type Static Function
@author lucas.franca
@since 06/10/2020
@version P12
@param 01 oDominio , objeto  , instância da classe de Dominio
@param 02 aPeriodos, array   , lista de períodos
@param 03 cFilAux  , caracter, filial para ser considerado na query
@param 04 cTicket  , caracter, ticket que está sendo processado
@return   cQuery   , caracter, query para carga de produtos
/*/
Static Function queryProd(oDominio, aPeriodos, cFilAux, cTicket)
	Local cQuery    := ""
	Local cTablePrd := IIf(oDominio:oParametros["lUsesProductIndicator"], "HWE", "HWA")
	Local lConsidLt := Iif(FindFunction("mrpLoteCQ"), mrpLoteCQ(), .F.)
	Local lHWX      := FWAliasInDic("HWX",.F.)

	cQuery += "% " + RetSqlName("HWA") + " HWA "

	//Relaciona Tabela de Saldos
	cQuery += " LEFT OUTER JOIN " + RetSqlName("T4V") + " T4V ON "
	cQuery +=            " HWA.HWA_PROD = T4V.T4V_PROD "
	cQuery +=        " AND T4V.D_E_L_E_T_ = ' ' "
	cQuery +=        " AND T4V.T4V_FILIAL = '" + xFilial("T4V", cFilAux) + "' "

	//Parâmetro para filtrar os armazéns
	If !Empty(oDominio:oParametros["cWarehouses"])
		cQuery += " AND " + oDominio:oSeletivos:scriptInSQL("T4V.T4V_LOCAL", "cWarehouses")
	EndIf

	//Valida o filtro de Tipo ou Grupo de Produtos
	cQuery += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4V.T4V_PROD", .F., .T., .T., .F.)

	If !oDominio:oParametros["lExpiredLot"]
		cQuery += " AND (T4V_LOTE = ' ' OR T4V_VALID >= '" + DToS(aPeriodos[1]) + "') "
	EndIf

	cQuery += localMRP("T4V.T4V_LOCAL", " = '" + xFilial("HWY", cFilAux) + "'")

	//Relaciona Tabela de Rejeitos em CQ
	If oDominio:oParametros["lSubtraiRejeitosCQ"] .And. lHWX
		cQuery += " LEFT OUTER JOIN ( SELECT HWX.HWX_PROD, "
		cQuery +=                          " HWX.HWX_LOCAL, "
		If lConsidLt
			cQuery +=                      " HWX_QTDE, "
			cQuery +=                      " HWX_QTDEV, "
			cQuery +=                      " HWX_LOTE, "
			cQuery +=                      " HWX_SLOTE "
		Else
			cQuery +=                      " SUM(HWX.HWX_QTDE) HWX_QTDE, "
			cQuery +=                      " SUM(HWX.HWX_QTDEV) HWX_QTDEV, "
			cQuery +=                      " ' ' HWX_LOTE, "
			cQuery +=                      " ' ' HWX_SLOTE "
		EndIf
		cQuery +=                     " FROM " + RetSqlName("HWX") + " HWX "
		cQuery +=                    " WHERE HWX.HWX_FILIAL = '" + xFilial("HWX", cFilAux) + "' "
		If Len(aPeriodos) > 1
			cQuery +=                  " AND HWX.HWX_DATNF < '" + DToS(aPeriodos[2]) + "' "
		Else
			cQuery +=                  " AND HWX.HWX_DATNF <= '" + DToS(aPeriodos[1]) + "' "
		EndIf
		//Adiciona filtro de armazéns
		If !Empty(oDominio:oParametros["cWarehouses"])
			cQuery +=                  " AND " + oDominio:oSeletivos:scriptInSQL("HWX.HWX_LOCAL", "cWarehouses")
		EndIf
		//Relaciona com a tabela de armazéns (HWY)
		cQuery += localMRP("HWX.HWX_LOCAL", " = '" + xFilial("HWY", cFilAux) + "'")
		//Adiciona agrupamento para o SUM das quantidades e relaciona com o produto/armazém.
		If !lConsidLt
			cQuery += " GROUP BY HWX.HWX_PROD, HWX.HWX_LOCAL "
		EndIf
		cQuery += " ) HWX ON HWA.HWA_PROD = HWX.HWX_PROD "
		cQuery +=      " AND T4V.T4V_LOCAL = HWX.HWX_LOCAL "
		If lConsidLt
			cQuery +=  " AND T4V.T4V_LOTE = HWX.HWX_LOTE "
			cQuery +=  " AND T4V.T4V_SLOTE = HWX.HWX_SLOTE "
		EndIf
	EndIf

	//Relaciona Tabela Indicador de Produtos
	If cTablePrd == "HWE"
		cQuery += " LEFT OUTER JOIN " + RetSqlName("HWE") + " HWE ON "
		cQuery +=            " HWA.HWA_PROD = HWE.HWE_PROD "
		cQuery +=        " AND HWE.D_E_L_E_T_ = ' ' "
		cQuery +=        " AND HWE.HWE_FILIAL = '" + xFilial("HWE", cFilAux) + "' "
	EndIf

	If oDominio:oMultiEmp:utilizaMultiEmpresa()
		//Relacionamento com a tabela de níveis do multi-empresa
		cQuery += " LEFT OUTER JOIN " + RetSqlName("SMB") + " SMB ON "
		cQuery +=            " SMB.MB_FILIAL  = '" + xFilial("SMB", cFilAux) + "' "
		cQuery +=        " AND SMB.MB_PROD    = HWA.HWA_PROD "
		cQuery +=        " AND SMB.D_E_L_E_T_ = ' ' "
	EndIf

	//Relaciona com a tabela SMI para identificar o LEAD TIME de TRANSFERÊNCIA/TIPO DE AGLUTINAÇÃO do produto.
	cQuery += " LEFT OUTER JOIN " + RetSqlName("SMI") + " SMI ON "
	cQuery +=            " SMI.MI_FILIAL  = '" + xFilial("SMI", cFilAux) + "' "
	cQuery +=        " AND SMI.MI_PRODUTO = HWA.HWA_PROD "
	cQuery +=        " AND SMI.D_E_L_E_T_ = ' ' "

	cQuery += oDominio:oDados:oCargaMemoria:montaJoinSMM("HWA.HWA_PROD",cTicket)

	cQuery += " WHERE HWA.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND HWA.HWA_FILIAL = '" + xFilial("HWA", cFilAux) + "'%"

Return cQuery

/*/{Protheus.doc} localMRP
Retorna instrução SQL para validar os saldos em estoque de locais que são considerados no MRP.

@type Static Function
@author renan.roeder
@since 11/08/2020
@version P12.1.31
@param 01 cCampo     , caracter, campo da tabela de saldos para relacionar a tabela HWY
@param 02 cQryFiliais, caracter, filiais a serem consideradas na query (= ou IN)
@return cExists, caracter, instrução sql para validar armazéns que entram no MRP.
/*/
Static Function localMRP(cCampo, cQryFiliais)
	Local cExists := ""

	If FWAliasInDic("HWY",.F.)
		cExists := " AND EXISTS (SELECT 1 FROM "+RetSqlName("HWY")+" HWY WHERE HWY_FILIAL " + cQryFiliais + " AND HWY.HWY_COD = "+cCampo+" AND HWY.HWY_MRP = '1') "
	EndIf

Return cExists

/*/{Protheus.doc} marcaPais
Marca flag que o produto tem opcional para os produtos de nivel acima ao nivel do componente recebido.
@type  Static Function
@author Lucas Fagundes
@since 26/10/2022
@version P12
@param 01 oJsPais   , Objeto  , Objeto json com os produtos pai de cada componente.
@param 02 cChaveComp, Caracter, Chave do componente que irá marcar os pais com opcional.
@param 03 oOpcionais, Objeto  , Instância da classe de opcionais que será usada para marcar a flag.
@return Nil
/*/
Static Function marcaPais(oJsPais, cChaveComp, oOpcionais)
	Local aMarca    := {}
	Local aPais     := {}
	Local cPai      := ""
	Local nIndPai   := 0
	Local nTamPais  := 0

	If oJsPais:HasProperty(cChaveComp)
		aPais    := oJsPais[cChaveComp]:getNames()
		nTamPais := Len(aPais)

		For nIndPai := 1 To nTamPais
			aAdd(aMarca, aPais[nIndPai])
		Next
	EndIf

	While !Empty(aMarca)
		cPai := aMarca[1]

		If !oOpcionais:getFlag("PRD_COM_OPC" + CHR(10) + cPai)
			oOpcionais:setFlag("PRD_COM_OPC" + CHR(10) + cPai, .T.)

			If oJsPais:HasProperty(cPai)
				aPais    := oJsPais[cPai]:getNames()
				nTamPais := Len(aPais)

				For nIndPai := 1 To nTamPais
					aAdd(aMarca, aPais[nIndPai])
				Next
			EndIf
		EndIf

		aDel(aMarca , 1)
		aSize(aMarca, Len(aMarca) - 1)
	End

	aSize(aPais , 0)
	aSize(aMarca, 0)
Return Nil

/*/{Protheus.doc} getDocSld
Monta o documento que será salvo na SMV para os registros de saldo.
@type  Static Function
@author Lucas Fagundes
@since 22/11/2022
@version P12
@param 01 cLocal   , Caracter, Armazém que está armazenado o saldo.
@param 02 cLote    , Caracter, Lote que está o saldo.
@param 03 cSubLote , Caracter, Sub-Lote que está o saldo.
@param 04 cValidade, Caracter, Validade do lote que está o saldo.
@return cDocSld, Caracter, Documento com as informações do saldo para salvar na SMV.
/*/
Static Function getDocSld(cLocal, cLote, cSubLote, cValidade)
	Local cDocSld := ""

	cDocSld := STR0100 + ": " + RTrim(cLocal) //Armazém
	If !Empty(cLote)
		cDocSld += "; " + STR0101 + ": " + RTrim(cLote) //Lote
		If !Empty(cSubLote)
			cDocSld += "; " + STR0102 + ": " + RTrim(cSubLote) //Sub-lote
		EndIf
		If !Empty(cValidade)
			cDocSld += "; " + STR0103 + ": " + DtoC(StoD(cValidade)) //"Validade"
		EndIf
	EndIf

Return cDocSld

/*/{Protheus.doc} fieldsQB
Retorna se os campos de quantidade base estão nas tabelas HWA e HWE.
@type  Static Function
@author Lucas Fagundes
@since 20/12/2022
@version P12
@return _lFieldsQB, Logico, Retorna se os campos estão na tabela.
/*/
Static Function fieldsQB()

	If _lFieldsQB == Nil
		_lFieldsQB := !Empty(GetSx3Cache("HWA_QB", "X3_TAMANHO")) .And. !Empty(GetSx3Cache("HWE_QB", "X3_TAMANHO"))
	EndIf

Return _lFieldsQB

/*/{Protheus.doc} compValid
Retorna se um componente da estrutura é valido e será usado no MRP.
Componente válido = Não está vencido antes do inicio do MRP
@type  Static Function
@author Lucas Fagundes
@since 13/09/2023
@version P12
@param 01 cRevIni  , Caracter, Revisão inicial do componente.
@param 02 cRevFim  , Caracter, Revisão final do componente.
@param 03 cRevAtu  , Caracter, Revisão atual da estrutura.
@param 04 dDataVenc, Caracter, Data de vencimento do componente.
@param 05 oParsMRP , Object  , Parâmetros do MRP.
@return lValido, Logico, Indica se o componente será considerado pelo MRP.
/*/
Static Function compValid(dDataVenc, oParsMRP)

Return dDataVenc >= oParsMRP["dDataIni"]

/*/{Protheus.doc} fldTranSMI
Verifica se possui os novos indicadores de transferência na tabela SMI

@type Static Function
@author marcelo.neumann
@since 01/11/2024
@version P12
@return _lFldTraMI, lógico, indica se possui os novos indicadores de transferência na tabela SMI
/*/
Static Function fldTranSMI()

	If _lFldTraMI == Nil
		_lFldTraMI := !Empty(GetSx3Cache("MI_TRANSF", "X3_TAMANHO"))
	EndIf

Return _lFldTraMI

/*/{Protheus.doc} fldLtMinTr
Verifica se possui o indicador de Lote Mínimo de transferência na tabela SMI

@type Static Function
@author marcelo.neumann
@since 31/03/2025
@version P12
@return _lFldLoTMI, lógico, indica se possui o indicador de Lote Mínimo de transferência na tabela SMI
/*/
Static Function fldLtMinTr()

	If _lFldLoTMI == Nil
		_lFldLoTMI := !Empty(GetSx3Cache("MI_LMTRANS", "X3_TAMANHO"))
	EndIf

Return _lFldLoTMI
