#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"
#INCLUDE "FWMVCDEF.CH"

//Tempo de espera para aguardar a abertura da thread
#DEFINE TEMPO_AGUARDA_ABERTURA 600

#DEFINE NAO_ALOCOU_ALTERNATIVO '0'
#DEFINE ALOCOU_ALTERNATIVO     '1'

#DEFINE TIPO_AUTORIZACAO_ENTREGA 2

#DEFINE OPERACAO_INCLUSAO  3
#DEFINE OPERACAO_ALTERACAO 4

#DEFINE SH9_TIPO_EXCECAO  "E"
#DEFINE SH9_TIPO_BLOQUEIO "B"

Static _cFilHWF   := ""
Static _cFilSMF   := ""
Static _cFilSVM   := ""
Static _lPerdInf  := Nil
Static _lFldRecAl := Nil
Static _nTamPrg   := Nil
Static _oCachePer := Nil
Static _lOptOrcl  := FindFunction("PCPOptOrcl")
Static _oQryComp  := Nil
Static _oQryOper  := Nil
Static _cTempoPla := Nil
Static _lDicFerra := Nil

//Estáticas tela de OP efetivadas
Static _aOpsTela  := {}
Static _lContinua := .F.
Static _lShowView := .T.
Static _oViewExec := Nil

// Opções de limpeza
#DEFINE DESEFETIVAR_TUDO 1
#DEFINE SELECAO_MANUAL   2
#DEFINE POR_FILTROS      3

/*/{Protheus.doc} PCPA152Efetivacao
Classe responsável pelo controle da efetivação de programações do CRP

@author Marcelo Neumann
@since 21/11/2023
@version P12
/*/
Class PCPA152Efetivacao From PCPA152Process
	Private Data dDataAtual   as Caracter
	Private Data cErroDet     as Caracter
	Private Data cErroMsg     as Caracter
	Private Data cSeqInic     as Caracter
	Private Data cSeqHZL      as Caracter
	Private Data cBanco       as Caracter
	Private Data nTotProc     as Number
	Private Data lGravaPCP    as Logical
	Private Data oTempOrdens  as Object
	Private Data oTempCompras as Object
	Private Data oDatasSC     as Object
	Private Data oLogCotacao  as Object
	Private Data oBuscaBloque as Object
	Private Data oBulkBloque  as Object

	//Métodos de contrução
	Public Method new(cProgram, lRecupera) Constructor
	Public Method destroy()

	//Métodos de inicialização
	Private Method setaAtributos(cProg)

	//Métodos públicos
	Public Method efetivaProgramacao(cProg, cDataAtu)
	Public Method permiteEfetivar(cProg)

	//Métodos do processamento - Efetivacao
	Private Method atualizaSC2()
	Private Method atualizaSD4()
	Private Method criaTemporaria()
	Private Method dessacramentaOrdens()
	Private Method geraTabelaHWF()
	Public Method iniciaEfetivacao()
	Private Method ajustaCompras()
	Public  Method processaEfetivacao()
	Private Method efetivaFerramentas()

	//Métodos do processamento - Gravacao PCP
	Public Method gravaDadosPCP()
	Private Method cadastraExcecoes()
	Private Method ajustaBloqueios()
	Private Method cadastraBloqueios()

	//Métodos ajuste de compras
	Private Method criaTempCompras()
	Private Method getFieldsTempCompras()
	Private Method carregaTempCompras(cAlias)
	Private Method getDataInicioCompra()
	Private Method getDatasAutorizacaoEntrega()
	Private Method geraOcorrenciaDataCompra()
	Private Method updateSC1()
	Private Method updateSC7()
	Private Method updateSC8()

	//Métodos auxiliares
	Private Method aguardaFimProcessamento()
	Public Method esperaFimThreads()
	Private Method atualizaProcessamento(cDescricao, nPercent, nQtdProc)
	Private Method getFieldsCadastroBloqueio()
	Private Method removeBloqueios(cRecurso, cCCusto, dData, cInicio, cFim)

	//Métodos tela de OP efetivadas
	Static Method abreTela(cFiltrOp, aFiliais)
	Static  Method deletaHWF(cOp, cFil)

EndClass

/*/{Protheus.doc} new
Método contrutor da classe PCPA152Efetivacao

@author Marcelo Neumann
@since 21/11/2023
@version P12
@param 01 cProgram , Caracter, Número da programação que será efetivada
@param 02 lRecupera, Lógico  , Indica se deve recurperar os valores (nova thread)
@param 03 aParams  , Array   , Array com os parâmetros da programação.
@return Self, Object, Nova instância da classe
/*/
Method new(cProgram, lRecupera, aParams) Class PCPA152Efetivacao
	Default cProgram  := ""
	Default lRecupera := .F.

	_cFilHWF := xFilial("HWF")
	_cFilSVM := xFilial("SVM")
	_cFilSMF := xFilial("SMF")

	Self:cErroMsg := ""
	Self:cErroDet := ""
	Self:cSeqInic := ""
	Self:cSeqHZL  := ""
	Self:cBanco   := TcGetDb()
	Self:nTotProc := 0

	Self:oDatasSC    := JsonObject():New()
	Self:oLogCotacao := JsonObject():New()

	//Se a classe já foi instanciada em outra thread, recupera o que já se tem
	If lRecupera
		_Super:new(cProgram)
		Self:cSeqInic  := PadL("1", GetSx3Cache("HWF_SEQ", "X3_TAMANHO"), "0")
		Self:nTotProc  := _Super:retornaValorGlobal("PROCESSO_TOTAL")
		Self:lGravaPCP := _Super:retornaParametro("MV_GRAVPCP")

		If temDicFerr()
			Self:cSeqHZL := PadL("1", GetSx3Cache("HZL_SEQ", "X3_TAMANHO"), "0")
		EndIf
	Else
		_Super:new()

		Self:setaAtributos(cProgram, aParams)
	EndIf

Return Self

/*/{Protheus.doc} destroy
Método destrutor da classe

@author Marcelo Neumann
@since 21/11/2023
@version P12
@return Nil
/*/
Method destroy() Class PCPA152Efetivacao

	If _Super:retornaValorGlobal("PROCESSO_THREADS") >= 0
		PCPIPCFinish(_Super:getSemaforoThreads(), 10, 1)

		If !Self:oProcError:possuiErro()
			_Super:atualizaStatusProgramacao(STATUS_EFETIVADO)
		EndIf

		_Super:limpaSecaoGlobal(.T.)
	EndIf

	_Super:destroy()

Return Nil

/*/{Protheus.doc} PCPA152EFE
API de controle da efetivação da programação

@type WSCLASS
@author Marcelo Neumann
@since 21/11/2023
@version P12
/*/
WSRESTFUL PCPA152EFE DESCRIPTION "PCPA152EFE" FORMAT APPLICATION_JSON
	WSDATA centroTrab       as STRING  OPTIONAL
	WSDATA dataAtual        as STRING  OPTIONAL
	WSDATA dataEfetiva      as STRING  OPTIONAL
	WSDATA dataInicialStart as STRING  OPTIONAL
	WSDATA dataFinalStart   as STRING  OPTIONAL
	WSDATA dataInicialEnd   as STRING  OPTIONAL
	WSDATA dataFinalEnd     as STRING  OPTIONAL
	WSDATA ferramenta       as STRING  OPTIONAL
	WSDATA horaFinal        as STRING  OPTIONAL
	WSDATA horaInicial      as STRING  OPTIONAL
	WSDATA operacao         as STRING  OPTIONAL
	WSDATA ordemProducao    as STRING  OPTIONAL
	WSDATA produto          as STRING  OPTIONAL
	WSDATA programacao      as STRING  OPTIONAL
	WSDATA quickOrder       as STRING  OPTIONAL
	WSDATA recurso          as STRING  OPTIONAL
	WSDATA page             AS INTEGER OPTIONAL
	WSDATA pageSize         AS INTEGER OPTIONAL
	WSDATA finalizada       AS BOOLEAN OPTIONAL

	WSMETHOD POST EFETIVA;
		DESCRIPTION STR0386; //"Inicia a efetivação da programação da produção"
		WSSYNTAX "/api/pcp/v1/pcpa152efe/{programacao}";
		PATH "/api/pcp/v1/pcpa152efe/{programacao}";
		TTALK "v1"

	WSMETHOD GET STATUS;
		DESCRIPTION STR0397; //"Recupera o status do processamento da efetivação"
		WSSYNTAX "/api/pcp/v1/pcpa152efe/status/{programacao}";
		PATH "/api/pcp/v1/pcpa152efe/status/{programacao}";
		TTALK "v1"

	WSMETHOD GET CONSULTA;
		DESCRIPTION STR0397; //"Consulta as Ordens Efetivadas Tabela HWF"
		WSSYNTAX "/api/pcp/v1/pcpa152efe/consulta/{programacao}";
		PATH "/api/pcp/v1/pcpa152efe/consulta/{programacao}";
		TTALK "v1"

	WSMETHOD GET ORDENS;
		DESCRIPTION STR0448; // "Retorna as ordens de produção efetivadas"
		WSSYNTAX "/api/pcp/v1/pcpa152efe/ordens";
		PATH "/api/pcp/v1/pcpa152efe/ordens";
		TTALK "v1"

	WSMETHOD GET OPERACOES;
		DESCRIPTION STR0449; // "Retorna as operações efetivadas de uma ordem de produção."
		WSSYNTAX "/api/pcp/v1/pcpa152efe/operacoes/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152efe/operacoes/{ordemProducao}";
		TTALK "v1"

	WSMETHOD POST DESEFETIVA;
		DESCRIPTION STR0527; // "Desefetiva uma ordem de produção"
		WSSYNTAX "/api/pcp/v1/pcpa152efe/desefetiva/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152efe/desefetiva/{ordemProducao}";
		TTALK "v1"

	WSMETHOD POST DESFET_LOTE;
		DESCRIPTION STR0546; // "Desefetiva as ordens de produção em lote."
		WSSYNTAX "/api/pcp/v1/pcpa152efe/desefetiva";
		PATH "/api/pcp/v1/pcpa152efe/desefetiva";
		TTALK "v1"

	WSMETHOD GET OCORRENCIAS;
		DESCRIPTION STR0585; // "Retorna as ocorrências das ordens efetivadas"
		WSSYNTAX "/api/pcp/v1/pcpa152efe/ocorrencias";
		PATH "/api/pcp/v1/pcpa152efe/ocorrencias";
		TTALK "v1"

	WSMETHOD GET COMPARATIVO;
		DESCRIPTION STR0640; // "Retorna o comparativo das ordens de produção planejadas e executadas"
		WSSYNTAX "/api/pcp/v1/pcpa152efe/comparativo/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152efe/comparativo/{ordemProducao}";
		TTALK "v1"

	WSMETHOD GET COMPOPER;
		DESCRIPTION STR0641; // "Retorna as operações das ordens de produção planejadas e executadas"
		WSSYNTAX "/api/pcp/v1/pcpa152efe/comparativo/operacoes/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152efe/comparativo/operacoes/{ordemProducao}";
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} POST EFETIVA /api/pcp/v1/pcpa152efe/{programacao}
Inicia a efetivação da programação da produção

@type WSMETHOD
@author Marcelo Neumann
@since 21/11/2023
@version P12
@param programacao, Caracter, Código da programação
@return lSucesso, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD POST EFETIVA PATHPARAM programacao QUERYPARAM dataAtual WSSERVICE PCPA152EFE
	Local aParams   := {}
	Local aReturn   := {}
	Local cBody     := Self:getContent()
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), oProcEfet:Destroy(), Break(oError)})
	Local lSucesso  := .T.
	Local oProcEfet := Nil
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		oBody:fromJson(cBody)
		aParams   := oBody["listaParametros"]
		oProcEfet := PCPA152Efetivacao():New(Self:programacao, .F., aParams)
		aReturn   := oProcEfet:efetivaProgramacao(Self:programacao, Self:dataAtual)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} GET STATUS /api/pcp/v1/pcpa152efe/status/{programacao}
Retorna o status do processamento da efetivação

@type WSMETHOD
@author Marcelo Neumann
@since 06/12/2023
@version P12
@param programacao, Caracter, Número da programação
@return lSucesso   , Lógico  , Indica se teve sucesso na requisição
/*/
WSMETHOD GET STATUS PATHPARAM programacao WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getStatus(Self:programacao)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} getStatus
Função responsavel por obter o progresso de uma efetivação

@author Marcelo Neumann
@since 06/12/2023
@version P12
@param cProg, Caracter, Código da programação que irá buscar
@return aReturn, Array, Array com as informações para o retorno do rest
/*/
Static Function getStatus(cProg)
	Local cAlias     := GetNextAlias()
	Local aReturn    := Array(3)
	Local cDescricao := ""
	Local cMsg       := ""
	Local cMsgDet    := ""
	Local lError     := .F.
	Local lGravaPCP  := .F.
	Local nPerceEfet := 0
	Local nPerceGrav := 0
	Local nPercent   := 0
	Local oProcess   := PCPA152Process():New(cProg)
	Local oReturn    := JsonObject():New()

	If oProcess:retornaValorGlobal("GRAVA_PCP", @lError) .And. !lError
		lGravaPCP := .T.
	EndIf

	nPerceEfet := oProcess:retornaValorGlobal("PROCESSO_PERCENTUAL" + CHAR_ETAPAS_EFETIVACAO, @lError)
	If lGravaPCP .And. !lError
		nPerceGrav := oProcess:retornaValorGlobal("PROCESSO_PERCENTUAL" + CHAR_ETAPAS_GRAVA_PCP, @lError)

	ElseIf !lError
		nPerceGrav := 100

	EndIf

	If !lError
		nPercent := (nPerceEfet + nPerceGrav) / 2

		cDescricao := oProcess:retornaValorGlobal("PROCESSO_DESCRICAO" + CHAR_ETAPAS_EFETIVACAO, @lError)
		If lGravaPCP .And. nPerceEfet == 100
			cDescricao := oProcess:retornaValorGlobal("PROCESSO_DESCRICAO" + CHAR_ETAPAS_GRAVA_PCP, @lError)

		EndIf

		If Empty(cDescricao) .Or. lError
			cDescricao := ""
		EndIf
	EndIf

	If (Empty(nPercent) .And. nPercent <> 0) .Or. lError .Or. oProcess:oProcError:possuiErro()
		T4X->(dbSetOrder(1))
		If T4X->(dbSeek(xFilial("T4X") + cProg)) .And. T4X->T4X_STATUS == STATUS_EFETIVADO
			nPercent := 100
		Else
			cMsg    := STR0398 //"Não foi possível obter o status do processamento da efetivação."
			cMsgDet := STR0398 //"Não foi possível obter o status do processamento da efetivação."

			BeginSql Alias cAlias
			SELECT T4Z_MSG, T4Z_MSGDET
				FROM %Table:T4Z%
			WHERE T4Z_FILIAL = %xFilial:T4Z%
				AND T4Z_PROG   = %Exp:cProg%
				AND %NotDel%
			ORDER BY T4Z_SEQ DESC
			EndSql
			If !Empty((cAlias)->T4Z_MSG)
				cMsg := AllTrim((cAlias)->T4Z_MSG)
			EndIf
			If !Empty((cAlias)->T4Z_MSGDET)
				cMsgDet := AllTrim((cAlias)->T4Z_MSGDET)
			EndIf
			(cAlias)->(dbCloseArea())

			oReturn["erroMsg"] := cMsg
			oReturn["erroDet"] := cMsgDet
		EndIf
	EndIf

	oReturn["hasNext"] := .F.
	If nPercent >= 0
		oReturn["descricao" ] := cDescricao
		oReturn["percentual"] := nPercent
	EndIf

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

Return aReturn

/*/{Protheus.doc} GET CONSULTA /api/pcp/v1/pcpa152efe/consulta/
Retorna a consulta das ordens efetivadas tabela HWF

@type WSMETHOD
@author Jefferson Possidonio
@since 08/02/2024
@version P12
@param 01 programacao, Caracter, Número da programação
@param 02 dataEfetiva, Caracter, data selecionada para consulta
@param 03 horaInicial, Caracter, hora inicial selecionada para consulta
@param 04 horaFinal  , Caracter, hora final selecionada para consulta
@param 05 recurso    , Caracter, recurso selecionada para consulta
@param 06 ferramenta , Caracter, ferramenta selecionada para consulta
@return lSucesso     , Lógico  , Indica se teve sucesso na requisição
/*/
WSMETHOD GET CONSULTA PATHPARAM programacao QUERYPARAM dataEfetiva, horaInicial, horaFinal, recurso, ferramenta WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getEfetiva(Self:dataEfetiva, Self:horaInicial, Self:horaFinal, Self:recurso, Self:programacao, Self:ferramenta)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} getEfetiva
Função responsavel por obter a consulta das ordens efetivadas

@author Jefferson Possidonio
@since 08/02/2024
@version P12
@param 01 cDataEfe  , Caracter, data selecionada para consulta
@param 02 cHoraIni  , Caracter, hora inicial selecionada para consulta
@param 03 cHoraFim  , Caracter, hora final selecionada para consulta
@param 04 cRecurso  , Caracter, recurso selecionada para consulta
@param 05 cPrograma , Caracter, Numero da programação
@param 06 cFerrament, Caracter, Ferramenta selecionada para consulta
@return aReturn, Array, Array com as informações para o retorno do rest
/*/
Static Function getEfetiva(cDataEfe, cHoraIni, cHoraFim, cRecurso, cPrograma, cFerrament)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local nCont   := 0
	Local oReturn := JsonObject():New()

	If Empty(cFerrament)
		cQuery := " SELECT HWF.HWF_OP NUMOP,"
		cQuery +=        " SB1.B1_COD,"
		cQuery +=        " SB1.B1_DESC,"
		cQuery +=        " HWF.HWF_OPER OPERACAO,"
		cQuery +=        " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) DESCOPER,"
		cQuery +=        " HWF.HWF_CTRAB || ' - ' || SHB.HB_NOME CTRAB,"
		cQuery +=        " HWF.HWF_HRINI INICIO,"
		cQuery +=        " HWF.HWF_HRFIM FIM,"
		cQuery +=        " HWF.HWF_TEMPOT TEMPOT,"
		cQuery +=        " HWF.HWF_PROG PROGRAMACAO,"
		cQuery +=        " HWF.HWF_TIPO TIPO,"
		If gravaAlt()
			cQuery +=    " HWF.HWF_RECALT RECALT,"
		Else
			cQuery +=    "'"  + NAO_ALOCOU_ALTERNATIVO + "' RECALT,"
		EndIf
		cQuery +=        " HWF.HWF_RECURS RECURSO"
		cQuery +=   " FROM " + RetSqlName("HWF") + " HWF"
		cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2"
		cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "'"
		cQuery +=    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
		cQuery +=    " AND SC2.D_E_L_E_T_ = ' '"
		cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1"
		cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
		cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO"
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN " + RetSqlName("SHB") + " SHB"
		cQuery +=     " ON SHB.HB_FILIAL  = '" + xFilial("SHB") + "'"
		cQuery +=    " AND SHB.HB_COD     = HWF.HWF_CTRAB"
		cQuery +=    " AND SHB.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN " + RetSqlName("SG2") + " SG2"
		cQuery +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "'"
		cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO"
		cQuery +=    " AND SG2.G2_OPERAC  = HWF.HWF_OPER"
		cQuery +=    " AND SG2.G2_CODIGO  = HWF.HWF_ROTEIR"
		cQuery +=    " AND SG2.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN " + RetSqlName("SHY") + " SHY"
		cQuery +=     " ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "'"
		cQuery +=    " AND SHY.HY_OP      = HWF.HWF_OP"
		cQuery +=    " AND SHY.HY_TEMPAD  <> 0"
		cQuery +=    " AND SHY.HY_OPERAC  = HWF.HWF_OPER"
		cQuery +=    " AND SHY.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "'"
		cQuery +=    " AND HWF.HWF_DATA   = '" + Replace(cDataEfe, "-", "") + "'"
		cQuery +=    " AND ((HWF.HWF_HRINI BETWEEN '" + cHoraIni + "' AND '" + cHoraFim + "') OR"
		cQuery +=         " (HWF.HWF_HRFIM BETWEEN '" + cHoraIni + "' AND '" + cHoraFim + "'))"
		cQuery +=    " AND HWF.HWF_RECURS = '" + cRecurso + "'"
		cQuery +=    " AND NOT EXISTS (SELECT 1"
		cQuery +=                      " FROM " + RetSqlName("SMF") + " SMF"
		cQuery +=                     " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "'"
		cQuery +=                       " AND SMF.MF_PROG    = '" + cPrograma + "'"
		cQuery +=                       " AND SMF.MF_RECURSO = HWF.HWF_RECURS"
		cQuery +=                       " AND SMF.MF_OP      = HWF.HWF_OP"
		cQuery +=                       " AND SMF.MF_OPER    = HWF.HWF_OPER"
		cQuery +=                       " AND SMF.D_E_L_E_T_ = ' ')"
		cQuery +=    " AND HWF.D_E_L_E_T_ = ' '"
	Else
		cQuery := " SELECT HZL.HZL_OP NUMOP,"
		cQuery +=        " SB1.B1_COD,"
		cQuery +=        " SB1.B1_DESC,"
		cQuery +=        " HZL.HZL_OPER OPERACAO,"
		cQuery +=        " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) DESCOPER,"
		cQuery +=        " HZL.HZL_CTRAB || ' - ' || SHB.HB_NOME CTRAB,"
		cQuery +=        " HZL.HZL_INICIO INICIO,"
		cQuery +=        " HZL.HZL_FIM FIM,"
		cQuery +=        " HZL.HZL_TEMPOT TEMPOT,"
		cQuery +=        " HZL.HZL_PROG PROGRAMACAO,"
		cQuery +=        " HZL.HZL_TIPO TIPO,"
		cQuery +=        "'" + NAO_ALOCOU_ALTERNATIVO + "' RECALT,"
		cQuery +=        " HZL.HZL_RECURS RECURSO"
		cQuery +=   " FROM " + RetSqlName("HZL") + " HZL"
		cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2"
		cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "'"
		cQuery +=    " AND " + PCPQrySC2("SC2", "HZL.HZL_OP")
		cQuery +=    " AND SC2.D_E_L_E_T_ = ' '"
		cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1"
		cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
		cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO"
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN " + RetSqlName("SHB") + " SHB"
		cQuery +=     " ON SHB.HB_FILIAL  = '" + xFilial("SHB") + "'"
		cQuery +=    " AND SHB.HB_COD     = HZL.HZL_CTRAB"
		cQuery +=    " AND SHB.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
		cQuery +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
		cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
		cQuery +=    " AND SG2.G2_OPERAC  = HZL.HZL_OPER "
		cQuery +=    " AND SG2.G2_CODIGO  = SC2.C2_ROTEIRO "
		cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SHY") + " SHY"
		cQuery +=     " ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "'"
		cQuery +=    " AND SHY.HY_OP      = HZL.HZL_OP"
		cQuery +=    " AND SHY.HY_TEMPAD  <> 0"
		cQuery +=    " AND SHY.HY_OPERAC  = HZL.HZL_OPER"
		cQuery +=    " AND SHY.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE HZL.HZL_FILIAL = '" + xFilial("HZL") + "'"
		cQuery +=    " AND HZL.HZL_DATA   = '" + Replace(cDataEfe, "-", "") + "'"
		cQuery +=    " AND ((HZL.HZL_INICIO BETWEEN '" + cHoraIni + "' AND '" + cHoraFim + "') OR"
		cQuery +=         " (HZL.HZL_FIM    BETWEEN '" + cHoraIni + "' AND '" + cHoraFim + "'))"
		cQuery +=    " AND HZL.HZL_FERRAM = '" + cFerrament + "'"
		cQuery +=    " AND NOT EXISTS (SELECT 1"
		cQuery +=                      " FROM " + RetSqlName("SMF") + " SMF"
		cQuery +=                     " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "'"
		cQuery +=                       " AND SMF.MF_PROG    = '" + cPrograma + "'"
		cQuery +=                       " AND SMF.MF_RECURSO = HZL.HZL_FERRAM"
		cQuery +=                       " AND SMF.MF_OP      = HZL.HZL_OP"
		cQuery +=                       " AND SMF.MF_OPER    = HZL.HZL_OPER"
		cQuery +=                       " AND SMF.D_E_L_E_T_ = ' ')"
		cQuery +=    " AND HZL.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=  " ORDER BY INICIO"

	If "MSSQL" $ TcGetDb()
        cQuery := StrTran(cQuery, "||", "+")
    EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nCont++

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCont]["op"               ] := (cAlias)->NUMOP
		oReturn["items"][nCont]["produto"          ] := RTrim((cAlias)->B1_COD) + " - " + RTrim((cAlias)->B1_DESC)
		oReturn["items"][nCont]["operacao"         ] := RTrim((cAlias)->OPERACAO) + If(Empty((cAlias)->DESCOPER),""," - " + RTrim((cAlias)->DESCOPER))
		oReturn["items"][nCont]["centrotrabalho"   ] := Rtrim((cAlias)->CTRAB)
		oReturn["items"][nCont]["horainicio"       ] := (cAlias)->INICIO
		oReturn["items"][nCont]["horafim"          ] := (cAlias)->FIM
		oReturn["items"][nCont]["tempo"            ] := __Min2Hrs((cAlias)->TEMPOT,.T.)
		oReturn["items"][nCont]["tipo"             ] := cValToChar((cAlias)->TIPO)
		oReturn["items"][nCont]["programacao"      ] := (cAlias)->PROGRAMACAO
		oReturn["items"][nCont]["alocouAlternativo"] := (cAlias)->RECALT == ALOCOU_ALTERNATIVO
		oReturn["items"][nCont]["recurso"          ] := (cAlias)->RECURSO

		(cAlias)->(dbSkip())
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)

Return aReturn

/*/{Protheus.doc} efetivaProgramacao
Inicia a efetivação da programação da produção

@author Marcelo Neumann
@since 21/11/2023
@version P12
@param 01 cProg   , Caracter, Número da programação que será efetivada
@param 02 cDataAtu, Caracter, Database em que está sendo executada a efetivação
@return aReturn, Array, Retorno do processamento da efetivação
/*/
Method efetivaProgramacao(cProg, cDataAtu) Class PCPA152Efetivacao
	Local aReturn   := {.T., 200, ""}
	Local cRecover  := 'P152ErroEf("' + Self:cProg + '")'
	Local lSucesso  := _Super:permiteProsseguir()
	Local cStatus   := "PEND"
	Default cDataAtu := ""

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Efetivando a programacao " + cProg})

	Self:dDataAtual := IIf(Empty(cDataAtu), dDatabase, CToD(cDataAtu))

	If lSucesso
		_Super:gravaValorGlobal("PROCESSO_THREADS", 0)
		lSucesso := Self:permiteEfetivar(cProg)
	EndIf

	If lSucesso
		Self:gravaValorGlobal("INICIO_PROCESSAMENTO", "PEND")

		Self:oProcError:startJob("P152IniEfe", getEnvServer(), .F., cEmpAnt, cFilAnt, Self:cProg, /*oVar02*/, /*oVar03*/, /*oVar04*/, ;
		                         /*oVar05*/, /*oVar06*/, /*oVar07*/, /*oVar08*/, /*oVar09*/, /*oVar10*/, /*bRecover*/, cRecover)

		While cStatus == 'PEND' .And. !Self:oProcError:possuiErro()
			cStatus := Self:retornaValorGlobal("INICIO_PROCESSAMENTO")
			If cStatus == 'PEND'
				Sleep(500)
			EndIf
		End

		lSucesso := cStatus == "OK"
	EndIf

	If !lSucesso
		If Empty(Self:cErroMsg)
			Self:getMsgErro(@Self:cErroMsg, @Self:cErroDet)
		EndIf

		oReturn := JsonObject():New()
		oReturn["message"        ] := Self:cErroMsg
		oReturn["detailedMessage"] := Self:cErroDet

		aReturn[1] := .F.
		aReturn[2] := 400
		aReturn[3] := oReturn:toJson()

		Self:destroy()
	EndIf

Return aReturn

/*/{Protheus.doc} P152IniEfe
Thread master da efetivação.
Responsavel por iniciar e finalizar a efetivação

@type  Function
@author Lucas Fagundes
@since 04/02/2025
@version P12
@param cProg, Caracter, Número da programação que será efetivada.
@return Nil
/*/
Function P152IniEfe(cProg)
	Local oEfet    := PCPA152Efetivacao():New(cProg, .T.)
	Local lSucesso := .T.

	lSucesso := oEfet:iniciaEfetivacao()

	oEfet:gravaValorGlobal("INICIO_PROCESSAMENTO", Iif(lSucesso, "OK", "ERRO"))

	If lSucesso
		oEfet:esperaFimThreads()
	EndIf

	oEfet:destroy()
Return Nil

/*/{Protheus.doc} esperaFimThreads
Aguarda o fim da threads abertas para o processamento.
@author Lucas Fagundes
@since 04/02/2025
@version P12
@return Nil
/*/
Method esperaFimThreads() Class PCPA152Efetivacao

	Self:aguardaFimProcessamento()

	While Self:retornaValorGlobal("PROCESSO_THREADS") > 0 .And. !Self:oProcError:possuiErro()
		Sleep(50)
	End

Return Nil

/*/{Protheus.doc} permiteEfetivar
Valida se essa programação pode ser efetivada

@author Marcelo Neumann
@since 21/11/2023
@version P12
@param cProg, Caracter, Número da programação que será efetivada
@return lSucesso, Lógico, Retorno indicando sucesso ou informando o erro que ocorreu
/*/
Method permiteEfetivar(cProg) Class PCPA152Efetivacao
	Local cAlias   := GetNextAlias()
	Local cCompOP  := ""
	Local lSucesso := .T.

	BeginSql Alias cAlias
      SELECT Count(*) TOTPROC
        FROM %Table:SMF% SMF
       INNER JOIN %Table:SVM% SVM
          ON SVM.VM_FILIAL = %Exp:_cFilSVM%
         AND SVM.VM_PROG   = SMF.MF_PROG
		 AND SVM.VM_ID     = SMF.MF_ID
         AND SVM.%NotDel%
       WHERE SMF.MF_FILIAL = %Exp:_cFilSMF%
         AND SMF.MF_PROG   = %Exp:cProg%
         AND SMF.%NotDel%
	EndSql
	Self:nTotProc := (cAlias)->TOTPROC
	_Super:gravaValorGlobal("PROCESSO_TOTAL", Self:nTotProc)
	(cAlias)->(dbCloseArea())

	If Self:nTotProc < 1
		lSucesso      := .F.
		Self:cErroMsg := STR0387 //"Não é possível efetivar essa programação."
		Self:cErroDet := STR0390 //"Não existem ordens de produção nessa programação para serem efetivadas."
	EndIf

	If lSucesso
		BeginSql Alias cAlias
		  COLUMN MIN_INICIO AS DATE
    	  SELECT Min(SVM.VM_DATA) MIN_INICIO
    	    FROM %Table:SMF% SMF
    	   INNER JOIN %Table:SVM% SVM
    	      ON SVM.VM_FILIAL = %Exp:_cFilSVM%
    	     AND SVM.VM_PROG   = SMF.MF_PROG
			 AND SVM.VM_ID     = SMF.MF_ID
    	     AND SVM.%NotDel%
    	   WHERE SMF.MF_FILIAL = %Exp:_cFilSMF%
    	     AND SMF.MF_PROG   = %Exp:cProg%
    	     AND SMF.%NotDel%
		EndSql
		If (cAlias)->MIN_INICIO < Self:dDataAtual
			lSucesso      := .F.
			Self:cErroMsg := STR0387 //"Não é possível efetivar essa programação."
			Self:cErroDet := STR0407 //"Existem ordens de produção programadas para iniciar em data anterior à data atual. Será necessário refazer a programação."
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf

	If lSucesso
		cCompOP := "%" + PCPQrySC2("SC2", "SMF.MF_OP") + "%"
		//Verifica se alguma OP foi excluída após a programação
		BeginSql Alias cAlias
    	  SELECT 1
    	    FROM %Table:SMF% SMF
    	   WHERE SMF.MF_FILIAL = %Exp:_cFilSMF%
    	     AND SMF.MF_PROG   = %Exp:cProg%
    	     AND SMF.%NotDel%
    	     AND NOT EXISTS (SELECT 1
		                       FROM %Table:SC2% SC2
    	                      WHERE SC2.C2_FILIAL = %xFilial:SC2%
    	                        AND %Exp:cCompOP%
    	                        AND SC2.%NotDel%)
		EndSql
		If (cAlias)->(!Eof())
			lSucesso      := .F.
			Self:cErroMsg := STR0387 //"Não é possível efetivar essa programação."
			Self:cErroDet := STR0388 //"Algumas ordens de produção programadas foram excluídas. Será necessário refazer a programação."
		End
		(cAlias)->(dbCloseArea())
	EndIf

	If lSucesso
		//Verifica se alguma OP foi efetivada após a programação
		BeginSql Alias cAlias
    	  SELECT 1
		    FROM %Table:HWF% HWF
		   INNER JOIN %Table:SMF% SMF
		      ON SMF.MF_FILIAL  = %Exp:_cFilSMF%
    	     AND SMF.MF_PROG    = %Exp:cProg%
    	     AND SMF.MF_OP      = HWF.HWF_OP
    	     AND SMF.%NotDel%
		   WHERE HWF.HWF_FILIAL = %Exp:_cFilHWF%
    	     AND HWF.HWF_PROG  <> SMF.MF_PROGEF
		     AND HWF.%NotDel%
		EndSql
		If (cAlias)->(!Eof())
			lSucesso      := .F.
			Self:cErroMsg := STR0387 //"Não é possível efetivar essa programação."
			Self:cErroDet := STR0389 //"Algumas ordens de produção foram efetivadas após o processamento dessa programação. Será necessário refazer a programação."
		End
		(cAlias)->(dbCloseArea())
	EndIf

	If lSucesso
		cCompOP := "%" + PCPQrySC2("SC2", "SMF.MF_OP") + "%"
		// Verifica se alguma operação foi excluida após a programação
		BeginSql Alias cAlias
			SELECT 1
			  FROM %Table:SMF% SMF
			 INNER JOIN %Table:SC2% SC2
			    ON SC2.C2_FILIAL = %xFilial:SC2%
			   AND %Exp:cCompOP%
			   AND SC2.%NotDel%
			 WHERE SMF.MF_FILIAL = %Exp:_cFilSMF%
			   AND SMF.MF_PROG   = %Exp:cProg%
			   AND NOT EXISTS (SELECT 1
			                     FROM %Table:SG2% SG2
			                    WHERE SG2.G2_FILIAL  = %xFilial:SG2%
			                      AND SG2.G2_CODIGO  = SMF.MF_ROTEIRO
			                      AND SG2.G2_PRODUTO = SC2.C2_PRODUTO
			                      AND SG2.G2_OPERAC  = SMF.MF_OPER
			                      AND SG2.D_E_L_E_T_ = ' ')
			   AND NOT EXISTS (SELECT 1
			                     FROM %Table:SHY% SHY
			                    WHERE SHY.HY_FILIAL  = %xFilial:SHY%
			                      AND SHY.HY_OP      = SMF.MF_OP
			                      AND SHY.HY_OPERAC  = SMF.MF_OPER
			                      AND SHY.HY_ROTEIRO = SMF.MF_ROTEIRO
			                      AND SHY.D_E_L_E_T_ = ' ')
			   AND SMF.%NotDel%
		EndSql
		If (cAlias)->(!Eof())
			lSucesso      := .F.
			Self:cErroMsg := STR0387 //"Não é possível efetivar essa programação."
			Self:cErroDet := STR0560 //"Algumas operações foram excluídas após a processamento dessa programação. Será necessário refazer a programação."
		End
		(cAlias)->(dbCloseArea())
	EndIf

	If !lSucesso
		Self:gravaErro(CHAR_ETAPAS_EFETIVACAO, Self:cErroMsg, Self:cErroDet)
	EndIf

Return lSucesso

/*/{Protheus.doc} iniciaEfetivacao
Inicia o processo de efetivação da programação

@author Marcelo Neumann
@since 21/11/2023
@version P12
@return lSucesso, Logico, Indica se finalizou o processamento com sucesso
/*/
Method iniciaEfetivacao() Class PCPA152Efetivacao
	Local cRecover   := 'P152ErroEf("' + Self:cProg + '")'
	Local cSemaforo  := _Super:getSemaforoThreads()
	Local lSucesso   := .T.
	Local nQtdThread := 1

	lSucesso := _Super:criaNovaEtapa(CHAR_ETAPAS_EFETIVACAO, STATUS_EXECUCAO)
	If lSucesso
		lSucesso := _Super:criaNovaEtapa(CHAR_ETAPAS_GRAVA_PCP, STATUS_EXECUCAO)
	EndIf

	If lSucesso .And. Self:lGravaPCP
		nQtdThread++

	ElseIf lSucesso
		_Super:atualizaEtapa(CHAR_ETAPAS_GRAVA_PCP, STATUS_CONCLUIDO)
		_Super:gravaValorGlobal("PROC_GRAVA_PCP", "OK")

	EndIf

	If lSucesso
		PCPIPCStart(cSemaforo, nQtdThread, Nil, cEmpAnt, cFilAnt, Self:cUIdError, cRecover)
		lSucesso := PCPIPCWIni(cSemaforo, TEMPO_AGUARDA_ABERTURA)
	EndIf

	If lSucesso
		_Super:gravaValorGlobal("PROCESSO_THREADS", nQtdThread)
		Self:atualizaProcessamento(STR0399, 0) //"Preparando a efetivação..."

		lSucesso := PCPIPCGO(cSemaforo, .F., "P152Efetiv", Self:cProg)
		If lSucesso
			_Super:gravaValorGlobal("PROC_EFETIVACAO", "PROC")

			If Self:lGravaPCP
				lSucesso := PCPIPCGO(cSemaforo, .F., "P152GravaPCP", Self:cProg)

				If lSucesso
					_Super:gravaValorGlobal("PROC_GRAVA_PCP", "PROC")
				EndIf
			EndIf
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} P152Efetiv
Inicia a efetivação de uma programação em uma nova thread

@author Marcelo Neumann
@since 05/12/2023
@version P12
@param cProg, Caracter, Código da programação.
@return Nil
/*/
Function P152Efetiv(cProg)
	Local oEfetiva := PCPA152Efetivacao():New(cProg, .T.)

	oEfetiva:processaEfetivacao()

Return Nil

/*/{Protheus.doc} criaTemporaria
Cria tabela temporária com as informações necessárias para a atualização
das tabelas SC2 e SD4

@author lucas.franca
@since 25/03/2024
@version P12
@return lSucesso, Logic, Indica se criou corretamente a temporária
/*/
Method criaTemporaria() Class PCPA152Efetivacao
	Local aFields    := {}
	Local cSql       := ""
	Local nTamNum    := GetSX3Cache("C2_NUM"    , "X3_TAMANHO")
	Local nTamItem   := GetSX3Cache("C2_ITEM"   , "X3_TAMANHO")
	Local nTamSeq    := GetSX3Cache("C2_SEQUEN" , "X3_TAMANHO")
	Local nTamItmGrd := GetSX3Cache("C2_ITEMGRD", "X3_TAMANHO")
	Local nPosStart  := 1
	Local nTempoIni  := MicroSeconds()
	Local nTempoQuer := MicroSeconds()
	Local lSucesso   := .T.

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Inicio da etapa de criacao da tabela temporaria"})

	Self:atualizaProcessamento(STR0436, 1) //"Selecionando registros para efetivação..."

	Self:oTempOrdens := FwTemporaryTable():New(GetNextAlias())

	aAdd(aFields, {"MF_NUM"    , "C", nTamNum                           , 0})
	aAdd(aFields, {"MF_ITEM"   , "C", nTamItem                          , 0})
	aAdd(aFields, {"MF_SEQUEN" , "C", nTamSeq                           , 0})
	aAdd(aFields, {"MF_ITEMGRD", "C", nTamItmGrd                        , 0})
	aAdd(aFields, {"MF_OP"     , "C", GetSX3Cache("MF_OP", "X3_TAMANHO"), 0})
	aAdd(aFields, {"DATAINI"   , "D", 8                                 , 0})
	aAdd(aFields, {"DATAFIM"   , "D", 8                                 , 0})
	aAdd(aFields, {"HORAINI"   , "C", 5                                 , 0})
	aAdd(aFields, {"HORAFIM"   , "C", 5                                 , 0})
	aAdd(aFields, {"MF_ID"     , "C", GetSX3Cache("MF_ID", "X3_TAMANHO"), 0})

	Self:oTempOrdens:setFields(aFields)
	Self:oTempOrdens:AddIndex("01", {"MF_NUM", "MF_ITEM", "MF_SEQUEN", "MF_ITEMGRD"})
	Self:oTempOrdens:AddIndex("02", {"MF_OP"})

	Self:oTempOrdens:Create()
	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo CREATE Efetivacao oTempOrdens: " + cValToChar(MicroSeconds() - nTempoQuer)})

	aSize(aFields, 0)

	cSql := " INSERT INTO " + Self:oTempOrdens:GetTableNameForQuery()
	cSql +=       " (MF_NUM,"
	cSql +=        " MF_ITEM,"
	cSql +=        " MF_SEQUEN,"
	cSql +=        " MF_ITEMGRD,"
	cSql +=        " MF_OP,"
	cSql +=        " DATAINI,"
	cSql +=        " DATAFIM,"
	cSql +=        " MF_ID)"

	cSql += " SELECT SubStr(SMF.MF_OP, " + cValToChar(nPosStart) + "," + cValToChar(nTamNum   ) + ") MF_NUM,"
	nPosStart += nTamNum
	cSql +=        " SubStr(SMF.MF_OP, " + cValToChar(nPosStart) + "," + cValToChar(nTamItem  ) + ") MF_ITEM,"
	nPosStart += nTamItem
	cSql +=        " SubStr(SMF.MF_OP, " + cValToChar(nPosStart) + "," + cValToChar(nTamSeq   ) + ") MF_SEQUEN,"
	nPosStart += nTamSeq
	cSql +=        " SubStr(SMF.MF_OP, " + cValToChar(nPosStart) + "," + cValToChar(nTamItmGrd) + ") MF_ITEMGRD,"
	cSql +=        " SMF.MF_OP,"
	cSql +=        " MIN(SVM.VM_DATA) DATAINI,"
	cSql +=        " MAX(SVM.VM_DATA) DATAFIM,"
	cSql +=        " MIN(SMF.MF_ID) MF_ID"
	cSql +=   " FROM " + RetSqlName("SMF") + " SMF"
	cSql +=  " INNER JOIN " + RetSqlName("SVM") + " SVM"
	cSql +=     " ON SVM.VM_FILIAL = SMF.MF_FILIAL"
	cSql +=    " AND SVM.VM_PROG = SMF.MF_PROG"
	cSql +=    " AND SVM.VM_ID   = SMF.MF_ID"
	cSql +=    " AND SVM.D_E_L_E_T_ = ' ' "
	cSql +=  " WHERE SMF.MF_FILIAL = '" + xFilial("SMF") + "'"
	cSql +=    " AND SMF.MF_PROG = '" + Self:cProg + "'"
	cSql +=    " AND SMF.D_E_L_E_T_ = ' '"
	cSql +=  " GROUP BY SMF.MF_OP"

	If TCGetDb() != "ORACLE"
		cSql := StrTran(cSql, "SubStr", "SubString")
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query INSERT Efetivacao oTempOrdens: " + cSql})
	nTempoQuer := MicroSeconds()
	lSucesso   := TcSqlExec(cSql) >= 0
	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo INSERT Efetivacao oTempOrdens: " + cValToChar(MicroSeconds() - nTempoQuer)})

	If lSucesso
		//Faz um update para preencher as colunas HORAINI e HORAFIM.
		cSql := " UPDATE " + Self:oTempOrdens:GetTableNameForQuery()
		cSql +=    " SET HORAINI = (SELECT MIN(SVM.VM_INICIO)"
		cSql +=                     " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
		cSql +=                    " INNER JOIN " + RetSqlName("SMF") + " SMF"
		cSql +=                       " ON SMF.MF_FILIAL = '" + xFilial("SMF") + "'"
		cSql +=                      " AND SMF.MF_PROG = '" + Self:cProg + "'"
		cSql +=                      " AND SMF.MF_OP   = TMP_ORDEM.MF_OP"
		cSql +=                      " AND SMF.D_E_L_E_T_ = ' '"
		cSql +=                    " INNER JOIN " + RetSqlName("SVM") + " SVM"
		cSql +=                       " ON SVM.VM_FILIAL = SMF.MF_FILIAL"
		cSql +=                      " AND SVM.VM_PROG = SMF.MF_PROG"
		cSql +=                      " AND SVM.VM_ID = SMF.MF_ID"
		cSql +=                      " AND SVM.VM_DATA = TMP_ORDEM.DATAINI"
		cSql +=                      " AND SVM.D_E_L_E_T_ = ' '"
		cSql +=                    " WHERE TMP_ORDEM.MF_OP = " + Self:oTempOrdens:GetTableNameForQuery() + ".MF_OP"
		cSql +=                    " GROUP BY TMP_ORDEM.MF_OP, TMP_ORDEM.DATAINI, TMP_ORDEM.DATAFIM),"
		cSql +=        " HORAFIM = (SELECT MAX(SVM.VM_FIM)"
		cSql +=                     " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
		cSql +=                    " INNER JOIN " + RetSqlName("SMF") + " SMF"
		cSql +=                       " ON SMF.MF_FILIAL = '" + xFilial("SMF") + "'"
		cSql +=                      " AND SMF.MF_PROG = '" + Self:cProg + "'"
		cSql +=                      " AND SMF.MF_OP   = TMP_ORDEM.MF_OP"
		cSql +=                      " AND SMF.D_E_L_E_T_ = ' '"
		cSql +=                    " INNER JOIN " + RetSqlName("SVM") + " SVM"
		cSql +=                       " ON SVM.VM_FILIAL = SMF.MF_FILIAL"
		cSql +=                      " AND SVM.VM_PROG = SMF.MF_PROG"
		cSql +=                      " AND SVM.VM_ID = SMF.MF_ID"
		cSql +=                      " AND SVM.VM_DATA = TMP_ORDEM.DATAFIM"
		cSql +=                      " AND SVM.D_E_L_E_T_ = ' '"
		cSql +=                    " WHERE TMP_ORDEM.MF_OP = " + Self:oTempOrdens:GetTableNameForQuery() + ".MF_OP"
		cSql +=                    " GROUP BY TMP_ORDEM.MF_OP, TMP_ORDEM.DATAINI, TMP_ORDEM.DATAFIM)"

		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query UPDATE Efetivacao oTempOrdens: " + cSql})
		nTempoQuer := MicroSeconds()
		lSucesso   := TcSqlExec(cSql) >= 0
		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo UPDATE Efetivacao oTempOrdens: " + cValToChar(MicroSeconds() - nTempoQuer)})
	EndIf

	If lSucesso == .F.
		Self:cErroMsg := STR0434 //"Erro ao identificar as ordens de produção para processamento."
		Self:cErroDet := TCSqlError() + cSql
	EndIf

	Self:atualizaProcessamento(/*cDescricao*/, 4)

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Fim da etapa de criacao da tabela temporaria: " + cValToChar(MicroSeconds() - nTempoIni)})

Return lSucesso

/*/{Protheus.doc} processaEfetivacao
Processa a efetivação da programação

@author Marcelo Neumann
@since 21/11/2023
@version P12
@return Nil
/*/
Method processaEfetivacao() Class PCPA152Efetivacao
	Local lSucesso  := .T.
	Local nTempoIni := MicroSeconds()

	lSucesso := Self:criaTemporaria()

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Inicio do processo da efetivacao da programacao"})

	BEGIN TRANSACTION
		//Dessacramenta as Ordens que serão Efetivadas
		If lSucesso
			lSucesso := Self:dessacramentaOrdens()
		EndIf

		//Cria a tabela de Efetivação
		If lSucesso
			lSucesso := Self:geraTabelaHWF()
		EndIf

		//Atualiza Data e Status da Ordem de Produção
		If lSucesso
			lSucesso := Self:atualizaSC2()
		EndIf

		//Atualiza Datas dos Empenhos
		If lSucesso
			lSucesso := Self:atualizaSD4()
		EndIf

		// Atualiza Data dos Documentos de Compra
		If lSucesso .And. _Super:retornaParametro("ajustaCompras")
			lSucesso := Self:ajustaCompras()
		EndIf

		// Cria Tabela de Ferramentas Efetivacadas
		If lSucesso .And. temDicFerr() .And. _Super:retornaParametro("utilizaFerramentas")
			lSucesso := Self:efetivaFerramentas()
		EndIf

		If lSucesso
			_Super:gravaValorGlobal("PROC_EFETIVACAO", "OK")
			Self:atualizaProcessamento(/*cDescricao*/, 100)
			lSucesso := Self:aguardaFimProcessamento()
		EndIf

		If lSucesso
			_Super:atualizaEtapa(CHAR_ETAPAS_EFETIVACAO, STATUS_CONCLUIDO)
		Else
			P152ErroEf(Self:cProg, Self:cErroMsg, Self:cErroDet, CHAR_ETAPAS_EFETIVACAO)
		EndIf
	END TRANSACTION

	If Self:oTempOrdens != Nil
		Self:oTempOrdens:Delete()
		FreeObj(Self:oTempOrdens)
	EndIf

	If Self:oTempCompras != Nil
		Self:oTempCompras:Delete()
		FreeObj(Self:oTempCompras)
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Fim do processo da efetivacao da programacao: " + cValToChar(MicroSeconds() - nTempoIni)})
	_Super:gravaValorGlobal("PROCESSO_THREADS", 0, .F., .T., -1)

Return

/*/{Protheus.doc} deletaHWF
Deleta ordens efetivadas da tabela (HWF)
@type Static Method
@author Jefferson Possidonio
@since 12/04/2024
@version P12
@param 01 cOp      , Caracter, Número da OP
@param 02 cFil     , Caracter, Filial a ser processada
@return   lSucesso , Lógico  , Indica se deletou com sucesso a ordem de produção da tabela HWF
/*/
Method deletaHWF(cOp, cFil) Class PCPA152Efetivacao

	Local cUpdate  := ""

	cUpdate := "UPDATE " + RetSqlName("HWF")
	cUpdate +=   " SET D_E_L_E_T_   = '*',"
	cUpdate +=       " R_E_C_D_E_L_ = R_E_C_N_O_"
	cUpdate += " WHERE HWF_FILIAL   = '" + cFil + "'"
	cUpdate +=   " AND D_E_L_E_T_   = ' '"
	cUpdate +=   " AND HWF_OP = '" + cOp + "'"

	If TcSqlExec(cUpdate) < 0
		Final(STR0486, TcSqlError()) //"Ocorreu um erro ao remover a ordem de produção da tabela (HWF)."
	EndIf

Return

/*/{Protheus.doc} dessacramentaOrdens
Dessacramenta as Ordens que serão Efetivadas

@author Marcelo Neumann
@since 21/11/2023
@version P12
@return lSucesso, Logico, Indica se finalizou o processamento com sucesso
/*/
Method dessacramentaOrdens() Class PCPA152Efetivacao
	Local cUpdate   := ""
	Local lSucesso  := .T.
	Local nTempoQry := 0
	Local nTempoTot := MicroSeconds()

	Self:atualizaProcessamento(STR0400, 5) //"Desfazendo efetivações anteriores..."

	cUpdate := "UPDATE " + RetSqlName("HWF")
	cUpdate +=   " SET D_E_L_E_T_   = '*',"
	cUpdate +=       " R_E_C_D_E_L_ = R_E_C_N_O_"
	cUpdate += " WHERE HWF_FILIAL   = '" + _cFilHWF + "'"
	cUpdate +=   " AND D_E_L_E_T_   = ' '"
	cUpdate +=   " AND EXISTS (SELECT 1"
	cUpdate +=                 " FROM " + RetSqlName("SMF") + " SMF"
	cUpdate +=                " WHERE SMF.MF_FILIAL  = '" + _cFilSMF + "'"
	cUpdate +=                  " AND SMF.MF_OP      = HWF_OP"
	cUpdate +=                  " AND SMF.MF_PROG    = '" + Self:cProg + "'"
	cUpdate +=                  " AND SMF.D_E_L_E_T_ = ' ')"

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query dessacramentaOrdens: " + cUpdate})
	nTempoQry := MicroSeconds()

	If TcSqlExec(cUpdate) < 0
		lSucesso      := .F.
		Self:cErroMsg := STR0392 //"Erro ao dessacramentar as ordens que estavam efetivadas."
		Self:cErroDet := TCSqlError() + cUpdate
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query dessacramentaOrdens: " + cValToChar(MicroSeconds() - nTempoQry)})

	If lSucesso .And. temDicFerr()
		cUpdate := " UPDATE " + RetSqlName("HZL")
		cUpdate +=    " SET D_E_L_E_T_   = '*',"
		cUpdate +=        " R_E_C_D_E_L_ = R_E_C_N_O_ "
		cUpdate +=  " WHERE HZL_FILIAL   = '" + xFilial("HZL") + "' "
		cUpdate +=    " AND D_E_L_E_T_   = ' ' "
		cUpdate +=    " AND EXISTS (SELECT 1 "
		cUpdate +=                  " FROM " + RetSqlName("SMF") + " SMF "
		cUpdate +=                 " WHERE SMF.MF_FILIAL  = '" + _cFilSMF + "' "
		cUpdate +=                   " AND SMF.MF_OP      = HZL_OP "
		cUpdate +=                   " AND SMF.MF_PROG    = '" + Self:cProg + "' "
		cUpdate +=                   " AND SMF.D_E_L_E_T_ = ' ') "

		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query dessacramenta ferramentas: " + cUpdate})
		nTempoQry := MicroSeconds()

		If TcSqlExec(cUpdate) < 0
			lSucesso      := .F.
			Self:cErroMsg := STR0681 // "Erro ao desefetivar as ferramentas."
			Self:cErroDet := TCSqlError() + cUpdate
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query dessacramenta ferramentas: " + cValToChar(MicroSeconds() - nTempoQry)})
	EndIf

	If lSucesso

		Self:atualizaProcessamento(STR0593, 6) // "Apagando ocorrências de desefetivação manual"

		cUpdate := " UPDATE " + RetSqlName("SVY")
		cUpdate +=    " SET D_E_L_E_T_   = '*',"
		cUpdate +=        " R_E_C_D_E_L_ = R_E_C_N_O_"
		cUpdate +=  " WHERE VY_FILIAL  = '" + xFilial("SVY") + "' "
		cUpdate +=    " AND VY_PROG    = '" + progZero()     + "' "
		cUpdate +=    " AND VY_TIPO    = '" + LOG_DESEFETIVOU_MANUAL + "' "
		cUpdate +=    " AND VY_OP IN (SELECT DISTINCT SMF.MF_OP "
		cUpdate +=                    " FROM " + RetSqlName("SMF") + " SMF "
		cUpdate +=                   " WHERE SMF.MF_FILIAL  = '" + _cFilSMF   + "' "
		cUpdate +=                     " AND SMF.MF_PROG    = '" + Self:cProg + "' "
		cUpdate +=                     " AND SMF.D_E_L_E_T_ = ' ') "
		cUpdate +=    " AND D_E_L_E_T_ = ' ' "

		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query apaga ocorrencias: " + cUpdate})
		nTempoQry := MicroSeconds()

		If TcSqlExec(cUpdate) < 0
			lSucesso      := .F.
			Self:cErroMsg := STR0586 // "Erro ao apagar as ocorrências de desefetivação manual."
			Self:cErroDet := TCSqlError() + cUpdate
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query apaga ocorrencias: " + cValToChar(MicroSeconds() - nTempoQry)})
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo metodo dessacramentaOrdens: " + cValToChar(MicroSeconds() - nTempoTot)})

	Self:atualizaProcessamento(/*cDescricao*/, 9)

Return lSucesso

/*/{Protheus.doc} geraTabelaHWF
Cria a tabela de Efetivação

@author Marcelo Neumann
@since 21/11/2023
@version P12
@return lSucesso, Logico, Indica se finalizou o processamento com sucesso
/*/
Method geraTabelaHWF() Class PCPA152Efetivacao
	Local aInserir   := {}
	Local cAlias     := GetNextAlias()
	Local cProg      := Self:cProg
	Local cQuery     := ""
	Local lInserir   := .F.
	Local lSucesso   := .T.
	Local lAlocAlt   := .F.
	Local cSeqHWF    := Self:cSeqInic
	Local nQtdProc   := 0
	Local nTamInsere := ARRAY_HWF_TAMANHO
	Local nTempoIni  := MicroSeconds()
	Local nTempoQuer := 0
	Local oBulk      := FwBulk():New(RetSqlName("HWF"))

	If !gravaAlt()
		nTamInsere--
	EndIf

	Self:atualizaProcessamento(STR0401, 10) //"Processando a efetivação..."

	oBulk:SetFields(tabFields("HWF"))

	cQuery := " SELECT SMF.MF_OP, "
	cQuery +=        " SMF.MF_OPER, "
	cQuery +=        " SMF.MF_RECURSO, "
	cQuery +=        " SMF.MF_CTRAB, "
	cQuery +=        " SVM.VM_DATA, "
	cQuery +=        " SVM.VM_INICIO, "
	cQuery +=        " SVM.VM_FIM, "
	cQuery +=        " SVM.VM_TEMPO, "
	cQuery +=        " SMF.MF_ROTEIRO, "
	cQuery +=        " SVM.VM_TIPO "
	If gravaAlt()
		cQuery +=   ", HZ7.HZ7_SEQ "
	EndIf
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	If gravaAlt()
		cQuery += " INNER JOIN " + RetSqlName("HZ7") + " HZ7 "
		cQuery +=    " ON HZ7.HZ7_FILIAL = '" + xFilial("HZ7") + "' "
		cQuery +=   " AND HZ7.HZ7_PROG   = SMF.MF_PROG "
		cQuery +=   " AND HZ7.HZ7_ID     = SMF.MF_ID "
		cQuery +=   " AND HZ7.HZ7_RECURS = SMF.MF_RECURSO "
		cQuery +=   " AND HZ7.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery +=  " INNER JOIN " + RetSqlName("SVM") + " SVM "
	cQuery +=     " ON SVM.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=    " AND SVM.VM_PROG    = SMF.MF_PROG "
	cQuery +=    " AND SVM.VM_ID      = SMF.MF_ID "
	cQuery +=    " AND SVM.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
	cQuery +=    " AND SMF.MF_PROG    = '" + cProg + "' "
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY SMF.MF_OP, SMF.MF_OPER, SMF.MF_RECURSO, SVM.VM_DATA, SVM.VM_SEQ, SVM.VM_INICIO "

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query geraTabelaHWF:" + cQuery })
	nTempoQuer := MicroSeconds()

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query geraTabelaHWF: " + cValToChar(MicroSeconds() - nTempoQuer)})

	While (cAlias)->(!Eof()) .And. lSucesso
		nQtdProc++

		If !Empty(aInserir)
			If (cAlias)->MF_OP      == aInserir[ARRAY_HWF_OP    ] .And. ;
			   (cAlias)->MF_OPER    == aInserir[ARRAY_HWF_OPER  ] .And. ;
			   (cAlias)->MF_RECURSO == aInserir[ARRAY_HWF_RECURS]

				//Agrupa registros da mesma data onde a Hora Final é igual a Hora Inicial
				If (cAlias)->VM_DATA   == aInserir[ARRAY_HWF_DATA ] .And. ;
				   (cAlias)->VM_INICIO == aInserir[ARRAY_HWF_HRFIM] .And. ;
				   (cAlias)->VM_TIPO   == aInserir[ARRAY_HWF_TIPO ]
					aInserir[ARRAY_HWF_HRFIM ] := (cAlias)->VM_FIM
					aInserir[ARRAY_HWF_TEMPOT] += (cAlias)->VM_TEMPO
				Else
					lInserir := .T.
				EndIf
			Else
				cSeqHWF  := Self:cSeqInic
				lInserir := .T.
			EndIf
		EndIf

		If lInserir
			lSucesso := oBulk:addData(aInserir)
			lInserir := .F.

			aSize(aInserir, 0)
		EndIf

		Self:atualizaProcessamento(/*cDescricao*/, /*nPercent*/, nQtdProc)

		If Empty(aInserir)
			aInserir := Array(nTamInsere)
			aInserir[ARRAY_HWF_FILIAL] := _cFilHWF
			aInserir[ARRAY_HWF_OP    ] := (cAlias)->MF_OP
			aInserir[ARRAY_HWF_OPER  ] := (cAlias)->MF_OPER
			aInserir[ARRAY_HWF_RECURS] := (cAlias)->MF_RECURSO
			aInserir[ARRAY_HWF_CTRAB ] := (cAlias)->MF_CTRAB
			aInserir[ARRAY_HWF_DATA  ] := (cAlias)->VM_DATA
			aInserir[ARRAY_HWF_SEQ   ] := cSeqHWF
			aInserir[ARRAY_HWF_HRINI ] := (cAlias)->VM_INICIO
			aInserir[ARRAY_HWF_HRFIM ] := (cAlias)->VM_FIM
			aInserir[ARRAY_HWF_TEMPOT] := (cAlias)->VM_TEMPO
			aInserir[ARRAY_HWF_STATUS] := STATUS_ATIVO
			aInserir[ARRAY_HWF_PROG  ] := cProg
			aInserir[ARRAY_HWF_ROTEIR] := (cAlias)->MF_ROTEIRO
			aInserir[ARRAY_HWF_TIPO  ] := (cAlias)->VM_TIPO

			If gravaAlt()
				lAlocAlt := (cAlias)->HZ7_SEQ != PCPA152TempoOperacao():getSequenciaRecursoPrincipal()

				aInserir[ARRAY_HWF_RECALT] := Iif(lAlocAlt, ALOCOU_ALTERNATIVO, NAO_ALOCOU_ALTERNATIVO)
			EndIf

			cSeqHWF := Soma1(cSeqHWF)
		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If lSucesso .And. !Empty(aInserir)
		lSucesso := oBulk:addData(aInserir)
		Self:atualizaProcessamento(/*cDescricao*/, /*nPercent*/, nQtdProc)
	EndIf

	If lSucesso
		If !oBulk:close()
			lSucesso      := .F.
			Self:cErroMsg := i18n(STR0182, {"HWF"}) //"Erro na gravação da tabela #1[tabela]#."
			Self:cErroDet := oBulk:getError()
		EndIf
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo gravacao da tabela HWF: " + cValToChar(MicroSeconds() - nTempoIni)})

	oBulk:destroy()
	aSize(aInserir, 0)

Return lSucesso

/*/{Protheus.doc} atualizaSC2
Atualiza Data e Status da Ordem de Produção

@author Marcelo Neumann
@since 21/11/2023
@version P12
@return lSucesso, Logico, Indica se finalizou o processamento com sucesso
/*/
Method atualizaSC2() Class PCPA152Efetivacao
	Local cUpdate  	 := ""
	Local cWhere   	 := ""
	Local lSucesso 	 := .T.
	Local nTempoIni  := MicroSeconds()
	Local nTempoQuer := 0

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Inicio da etapa de atualizacao"})

	Self:atualizaProcessamento(STR0402, 91) //"Atualizando ordens de produção..."

	cUpdate := "UPDATE " + RetSqlName("SC2")
	cUpdate +=   " SET C2_STATUS = '" + STATUS_ORDEM_EFETIVADA + "',"
	cUpdate +=       " C2_DATPRI = (SELECT TMP_ORDEM.DATAINI"
	cUpdate +=                      " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
	cUpdate +=                     " WHERE TMP_ORDEM.MF_NUM = C2_NUM"
	cUpdate +=                       " AND TMP_ORDEM.MF_ITEM = C2_ITEM"
	cUpdate +=                       " AND TMP_ORDEM.MF_SEQUEN = C2_SEQUEN"
	cUpdate +=                       " AND TMP_ORDEM.MF_ITEMGRD = C2_ITEMGRD),"
	cUpdate +=       " C2_DATPRF = (SELECT TMP_ORDEM.DATAFIM"
	cUpdate +=                      " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
	cUpdate +=                     " WHERE TMP_ORDEM.MF_NUM = C2_NUM"
	cUpdate +=                       " AND TMP_ORDEM.MF_ITEM = C2_ITEM"
	cUpdate +=                       " AND TMP_ORDEM.MF_SEQUEN = C2_SEQUEN"
	cUpdate +=                       " AND TMP_ORDEM.MF_ITEMGRD = C2_ITEMGRD)"
	cWhere  := " WHERE C2_FILIAL  = '" + xFilial("SC2") + "'"
	cWhere  +=   " AND D_E_L_E_T_ = ' '"
	cWhere  +=   " AND EXISTS(SELECT 1"
	cWhere  +=                " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
	cWhere  +=               " WHERE TMP_ORDEM.MF_NUM = C2_NUM"
	cWhere  +=                 " AND TMP_ORDEM.MF_ITEM = C2_ITEM"
	cWhere  +=                 " AND TMP_ORDEM.MF_SEQUEN = C2_SEQUEN"
	cWhere  +=                 " AND TMP_ORDEM.MF_ITEMGRD = C2_ITEMGRD)"

	cUpdate := cUpdate + cWhere

	If "MSSQL" $ TcGetDb()
        cUpdate := StrTran(cUpdate, "||", "+")
    EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query atualizaSC2 C2_STATUS: " + cUpdate})
	nTempoQuer := MicroSeconds()
	lSucesso   := TcSqlExec(cUpdate) >= 0
	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query atualizaSC2 C2_STATUS: " + cValToChar(MicroSeconds() - nTempoQuer)})

	Self:atualizaProcessamento(/*cDescricao*/, 92)

	If lSucesso
		cUpdate := "UPDATE " + RetSqlName("SC2")
		cUpdate +=   " SET C2_DATAJI = C2_DATPRI,"
		cUpdate +=       " C2_HORAJI = (SELECT TMP_ORDEM.HORAINI"
		cUpdate +=                      " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
		cUpdate +=                     " WHERE TMP_ORDEM.MF_NUM = C2_NUM"
		cUpdate +=                       " AND TMP_ORDEM.MF_ITEM = C2_ITEM"
		cUpdate +=                       " AND TMP_ORDEM.MF_SEQUEN = C2_SEQUEN"
		cUpdate +=                       " AND TMP_ORDEM.MF_ITEMGRD = C2_ITEMGRD),"
		cUpdate +=       " C2_DATAJF = C2_DATPRF,"
		cUpdate +=       " C2_HORAJF = (SELECT TMP_ORDEM.HORAFIM"
		cUpdate +=                      " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
		cUpdate +=                     " WHERE TMP_ORDEM.MF_NUM = C2_NUM"
		cUpdate +=                       " AND TMP_ORDEM.MF_ITEM = C2_ITEM"
		cUpdate +=                       " AND TMP_ORDEM.MF_SEQUEN = C2_SEQUEN"
		cUpdate +=                       " AND TMP_ORDEM.MF_ITEMGRD = C2_ITEMGRD)"

		cUpdate := cUpdate + cWhere

		If "MSSQL" $ TcGetDb()
			cUpdate := StrTran(cUpdate, "||", "+")
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query atualizaSC2 C2_DATAJI: " + cUpdate})
		nTempoQuer := MicroSeconds()
		lSucesso   := TcSqlExec(cUpdate) >= 0
		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query atualizaSC2 C2_DATAJI: " + cValToChar(MicroSeconds() - nTempoQuer)})
	EndIf

	If lSucesso
		cUpdate := "UPDATE " + RetSqlName("SC2")
		cUpdate +=   " SET C2_STATUS = 'N' "
		cWhere  := " WHERE C2_FILIAL  = '" + xFilial("SC2") + "'"
		cWhere  +=   " AND D_E_L_E_T_ = ' '"
		cWhere  +=   " AND EXISTS (SELECT 1"
		cWhere  +=                 " FROM " + RetSqlName("SMF") + " SMF"
		cWhere  +=                " WHERE SMF.MF_FILIAL    = '" + _cFilSMF + "'"
		cWhere  +=                  " AND SMF.MF_PROG      = '" + Self:cProg + "'"
		cWhere  +=                  " AND " + PCPQrySC2("", "SMF.MF_OP") //Compara C2_NUM.. com MF_OP
		cWhere  +=                  " AND SMF.D_E_L_E_T_   = ' ')"
		cWhere  +=   " AND NOT EXISTS (SELECT 1"
		cWhere  +=                     " FROM " + RetSqlName("HWF") + " HWF"
		cWhere  +=                    " WHERE HWF.HWF_FILIAL    = '" + _cFilHWF + "'"
		cWhere  +=                      " AND HWF.HWF_PROG      = '" + Self:cProg + "'"
		cWhere  +=                      " AND " + PCPQrySC2("", "HWF.HWF_OP") //Compara C2_NUM.. com HWF_OP
		cWhere  +=                      " AND HWF.D_E_L_E_T_    = ' ')"

		cUpdate := cUpdate + cWhere

		If "MSSQL" $ TcGetDb()
			cUpdate := StrTran(cUpdate, "||", "+")
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query atualizaSC2 C2_STATUS: " + cUpdate})
		nTempoQuer := MicroSeconds()
		lSucesso   := TcSqlExec(cUpdate) >= 0
		Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query atualizaSC2 C2_STATUS: " + cValToChar(MicroSeconds() - nTempoQuer)})
	EndIf

	If !lSucesso
		Self:cErroMsg := i18n(STR0393, {"SC2"}) //"Erro ao atualizar a tabela #1[TABELA]#"
		Self:cErroDet := TCSqlError() + cUpdate
	EndIf

	Self:atualizaProcessamento(/*cDescricao*/, 93)

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Fim da etapa de atualizacao: " + cValToChar(MicroSeconds() - nTempoIni)})

Return lSucesso

/*/{Protheus.doc} atualizaSD4
Atualiza Datas dos Empenhos

@author Marcelo Neumann
@since 21/11/2023
@version P12
@return lSucesso, Logico, Indica se finalizou o processamento com sucesso
/*/
Method atualizaSD4() Class PCPA152Efetivacao
	Local cUpdate   := ""
	Local lSucesso  := .T.
	Local nTempoIni := 0

	Self:atualizaProcessamento(STR0403, 94) //"Atualizando empenhos..."

	cUpdate := "UPDATE " + RetSqlName("SD4")
	cUpdate +=   " SET D4_DATA = (SELECT TMP_ORDEM.DATAINI"
	cUpdate +=                    " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
	cUpdate +=                   " WHERE TMP_ORDEM.MF_OP = D4_OP)"
	cUpdate += " WHERE D4_FILIAL  = '" + xFilial("SD4") + "'"
	cUpdate +=   " AND D_E_L_E_T_ = ' '"
	cUpdate +=   " AND EXISTS(SELECT 1"
	cUpdate +=                " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " TMP_ORDEM"
	cUpdate +=               " WHERE TMP_ORDEM.MF_OP = D4_OP)"

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query atualizaSD4: " + cUpdate})
	nTempoIni := MicroSeconds()

	If TcSqlExec(cUpdate) < 0
		lSucesso      := .F.
		Self:cErroMsg := i18n(STR0393, {"SD4"}) //"Erro ao atualizar a tabela #1[TABELA]#"
		Self:cErroDet := TCSqlError() + cUpdate
 	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query atualizaSD4: " + cValToChar(MicroSeconds() - nTempoIni)})

	Self:atualizaProcessamento(/*cDescricao*/, 95)

Return lSucesso

/*/{Protheus.doc} atualizaProcessamento
Atualiza o percentual de processamento

@author Marcelo Neumann
@since 21/11/2023
@version P12
@param 01 cDescricao, Caracter, Descrição do processo que está sendo feito
@param 02 nPercent  , Numérico, Percentual de processamento a ser atualizado (não calcula o %)
@param 03 nQtdProc  , Numérico, Quantidade de registros processados
@return Nil
/*/
Method atualizaProcessamento(cDescricao, nPercent, nQtdProc, cEtapa) Class PCPA152Efetivacao
	Default cEtapa := CHAR_ETAPAS_EFETIVACAO

	If Empty(nPercent) .And. !Empty(nQtdProc)
		//Atualiza o percentual a cada 20 registros
		If Mod(nQtdProc, 20) == 0
			nPercent := 10 + ((nQtdProc * 85) / Self:nTotProc)
		EndIf
	EndIf

	If !Empty(nPercent) .Or. nPercent == 0
		_Super:gravaValorGlobal("PROCESSO_PERCENTUAL" + cEtapa, nPercent)
	EndIf

	If !Empty(cDescricao)
		_Super:gravaValorGlobal("PROCESSO_DESCRICAO" + cEtapa, cDescricao)
	EndIf

Return

/*/{Protheus.doc} tabFields
Carrega a estrutura da tabela para gravação usando FwBulk
O array de retorno deve sempre seguir a ordem das colunas definidas nas constantes utilizadas para a tabela

@author Marcelo Neumann
@since 21/11/2023
@version P12
@param cTabela, Caracter, Alias da tabela que irá retornar os campos.
@return aEstrut, Array, Array com os campos da estrutura da tabela HWF
/*/
Static Function tabFields(cTabela)
	Local aEstrut := {}

	If cTabela == "HWF"
		aAdd(aEstrut, {"HWF_FILIAL"})
		aAdd(aEstrut, {"HWF_OP"    })
		aAdd(aEstrut, {"HWF_OPER"  })
		aAdd(aEstrut, {"HWF_RECURS"})
		aAdd(aEstrut, {"HWF_CTRAB" })
		aAdd(aEstrut, {"HWF_TEMPOT"})
		aAdd(aEstrut, {"HWF_DATA"  })
		aAdd(aEstrut, {"HWF_SEQ"   })
		aAdd(aEstrut, {"HWF_HRINI" })
		aAdd(aEstrut, {"HWF_HRFIM" })
		aAdd(aEstrut, {"HWF_STATUS"})
		aAdd(aEstrut, {"HWF_PROG"  })
		aAdd(aEstrut, {"HWF_ROTEIR"})
		aAdd(aEstrut, {"HWF_TIPO"  })

		If gravaAlt()
			aAdd(aEstrut, {"HWF_RECALT"})
		EndIf

	ElseIf cTabela == "HZL"
		aAdd(aEstrut, {"HZL_FILIAL"})
		aAdd(aEstrut, {"HZL_OP"    })
		aAdd(aEstrut, {"HZL_OPER"  })
		aAdd(aEstrut, {"HZL_RECURS"})
		aAdd(aEstrut, {"HZL_CTRAB" })
		aAdd(aEstrut, {"HZL_FERRAM"})
		aAdd(aEstrut, {"HZL_DATA"  })
		aAdd(aEstrut, {"HZL_SEQ"   })
		aAdd(aEstrut, {"HZL_INICIO"})
		aAdd(aEstrut, {"HZL_FIM"   })
		aAdd(aEstrut, {"HZL_TEMPOT"})
		aAdd(aEstrut, {"HZL_STATUS"})
		aAdd(aEstrut, {"HZL_PROG"  })
		aAdd(aEstrut, {"HZL_TIPO"  })
		aAdd(aEstrut, {"HZL_SEQFER"})

	EndIf

Return aEstrut

/*/{Protheus.doc} P152ErroEf
Tratamento de erro de processamento

@author Marcelo Neumann
@since 21/11/2023
@version P12
@param 01 cProg   , Caracter, Número da programação que ocorreu o erro
@param 02 cErroMsg, Caracter, Mensagem resumida do erro
@param 03 cErroDet, Caracter, Mensagem detalhada do erro
@param 04 cEtapa  , Caracter, Etapa do processo que ocorreu o erro
@return Nil
/*/
Function P152ErroEf(cProg, cErroMsg, cErroDet, cEtapa)
	Local oEfetiva := Nil

	If InTransact()
		DisarmTransaction()
	EndIf

	oEfetiva := PCPA152Efetivacao():New(cProg, .T.)

	If Empty(cErroMsg)
		oEfetiva:getMsgErro(@cErroMsg, @cErroDet)
	EndIf

	If Empty(cEtapa)
		oEfetiva:gravaErro(CHAR_ETAPAS_EFETIVACAO, cErroMsg, cErroDet)
		oEfetiva:gravaErro(CHAR_ETAPAS_GRAVA_PCP , cErroMsg, cErroDet)
		oEfetiva:destroy()
	Else
		oEfetiva:gravaErro(cEtapa, cErroMsg, cErroDet)
	EndIf

Return

/*/{Protheus.doc} GET ORDENS /api/pcp/v1/pcpa152efe/ordens
Retorna as ordens de produção efetivadas.
@type WSMETHOD
@author Lucas Fagundes
@since 05/04/2024
@version P12
@param 01 page            , Number  , Páginação da consulta.
@param 02 pageSize        , Number  , Tamanho da paginação da consulta.
@param 03 ordemProducao   , Caracter, Filtro de ordem de produção.
@param 04 produto         , Caracter, Filtro de produto.
@param 05 operacao        , Caracter, Filtro de operação.
@param 06 recurso         , Caracter, Filtro de recurso.
@param 07 centroTrab      , Caracter, Filtro de centro de trabalho.
@param 08 dataInicialStart, Caracter, Filtro de data inicial (DE).
@param 09 dataFinalStart  , Caracter, Filtro de data final (DE).
@param 10 dataInicialEnd  , Caracter, Filtro de data inicial (ATÉ).
@param 11 dataFinalEnd    , Caracter, Filtro de data final (ATÉ).
@param 12 quickOrder      , Caracter, Filtro rápido de ordem de produção.
@return lSucesso, Lógico, Indica se teve sucesso na requisição.
/*/
WSMETHOD GET ORDENS QUERYPARAM page, pageSize, ordemProducao, produto, operacao, recurso, centroTrab, dataInicialStart, dataFinalStart, dataInicialEnd, dataFinalEnd, quickOrder, finalizada WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOrdens(Self:page, Self:pageSize, Self:ordemProducao, Self:produto, Self:operacao, Self:recurso, Self:centroTrab, Self:quickOrder, PCPConvDat(Self:dataInicialStart, 1), PCPConvDat(Self:dataFinalStart, 1), PCPConvDat(Self:dataInicialEnd, 1), PCPConvDat(Self:dataFinalEnd, 1), Self:finalizada)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} getOrdens
Busca as ordens de produção efetivadas.
@type  Static Function
@author Lucas Fagundes
@since 05/04/2024
@version P12
@param 01 nPage     , Number  , Páginação da consulta.
@param 02 nPageSize , Number  , Tamanho da paginação da consulta.
@param 03 cOrdem    , Caracter, Filtro de ordem de produção (IN).
@param 04 cProduto  , Caracter, Filtro de produto.
@param 05 cOperac   , Caracter, Filtro de operação.
@param 06 cRecurso  , Caracter, Filtro de recurso.
@param 07 cCT       , Caracter, Filtro de centro de trabalho.
@param 08 cOrderLike, Caracter, Filtro de ordem de produção (LIKE).
@param 09 dIniDe    , Date    , Filtro data de inicio (DE)
@param 10 dFimDe    , Date    , Filtro data de entrega (DE)
@param 11 dIniAte   , Date    , Filtro data de inicio (ATÉ)
@param 12 dFimAte   , Date    , Filtro data de entrega (ATÉ)
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getOrdens(nPage, nPageSize, cOrdem, cProduto, cOperac, cRecurso, cCT, cOrderLike, dIniDe, dFimDe, dIniAte, dFimAte, lFinaliza)
	Local aReturn  := Array(3)
	Local cAlias   := GetNextAlias()
	Local cQuery   := ""
	Local lPerdInf := getPerInf()
	Local nCount   := 0
	Local nSaldo   := 0
	Local nStart   := 0
	Local oReturn  := JsonObject():New()
	Default lFinaliza := .F.

	cQuery := " SELECT DISTINCT HWF.HWF_OP, "
	cQuery +=                 " SC2.C2_PRODUTO, "
	cQuery +=                 " SB1.B1_DESC, "
	cQuery +=                 " SC2.C2_QUANT, "
	cQuery +=                 " SC2.C2_QUJE, "
	cQuery +=                 " SC2.C2_PERDA, "
	cQuery +=                 " SC2.C2_DATPRI, "
	cQuery +=                 " SC2.C2_DATPRF, "
	cQuery +=                 " HWF.HWF_ROTEIR, "
	cQuery +=                 " HWF.HWF_PROG, "
	cQuery +=                 " SC2.C2_DATRF"
	cQuery +=   " FROM " + RetSqlName("HWF") + " HWF "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
	If !lFinaliza
		cQuery +=    " AND SC2.C2_DATRF   = ' ' "
	EndIf
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
	cQuery +=    " AND HWF.D_E_L_E_T_ = ' ' "

	If !Empty(cOrdem)
		cQuery += " AND HWF.HWF_OP IN ('" + StrTran(cOrdem, ",", "','") + "') "
	EndIf

	If !Empty(cProduto)
		cQuery += " AND SC2.C2_PRODUTO IN ('" + StrTran(cProduto, ",", "','") + "') "
	EndIf

	If !Empty(cOperac)
		cQuery += " AND HWF.HWF_OPER LIKE '" + cOperac + "%' "
	EndIf

	If !Empty(cRecurso)
		cQuery += " AND HWF.HWF_RECURS IN ('" + StrTran(cRecurso, ",", "','") + "') "
	EndIf

	If cCT != Nil
		cQuery += " AND HWF.HWF_CTRAB IN ('" + StrTran(cCT, ",", "','") + "') "
	EndIf

	If !Empty(dIniDe)
		cQuery += " AND SC2.C2_DATPRI >= '" + DToS(dIniDe) + "' "
	EndIf

	If !Empty(dIniAte)
		cQuery += " AND SC2.C2_DATPRI <= '" + DToS(dIniAte) + "' "
	EndIf

	If !Empty(dFimDe)
		cQuery += " AND SC2.C2_DATPRF >= '" + DToS(dFimDe) + "' "
	EndIf

	If !Empty(dFimAte)
		cQuery += " AND SC2.C2_DATPRF <= '" + DToS(dFimAte) + "' "
	EndIf

	If !Empty(cOrderLike)
		cQuery += " AND HWF.HWF_OP LIKE '" + cOrderLike + "%' "
	EndIf

	cQuery +=  " ORDER BY HWF.HWF_OP "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ((nPage-1) * nPageSize)

		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nCount++

		nSaldo := (cAlias)->C2_QUANT - (cAlias)->C2_QUJE
		If !lPerdInf
			nSaldo -= (cAlias)->C2_PERDA
		EndIf

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["ordemProducao"] := (cAlias)->HWF_OP
		oReturn["items"][nCount]["produto"      ] := RTrim((cAlias)->C2_PRODUTO) + " - " + RTrim((cAlias)->B1_DESC)
		oReturn["items"][nCount]["saldo"        ] := Max(0, nSaldo)
		oReturn["items"][nCount]["dataInicio"   ] := PCPConvDat((cAlias)->C2_DATPRI, 4)
		oReturn["items"][nCount]["dataEntrega"  ] := PCPConvDat((cAlias)->C2_DATPRF, 4)
		oReturn["items"][nCount]["roteiro"      ] := (cAlias)->HWF_ROTEIR
		oReturn["items"][nCount]["details"      ] := Nil
		If Empty((cAlias)->C2_DATRF)
			oReturn["items"][nCount]["acoes"] := {"desefetivar", "comparativo"}
		Else
			oReturn["items"][nCount]["acoes"] := {"comparativo"}
		EndIf
		oReturn["items"][nCount]["programacao"      ] := (cAlias)->HWF_PROG

		(cAlias)->(dbSkip())
		If nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET OPERACOES /api/pcp/v1/pcpa152efe/operacoes/{ordemProducao}
Retorna as operações efetivadas de uma ordem de produção.
@type WSMETHOD
@author Lucas Fagundes
@since 05/04/2024
@version P12
@param 01 ordemProducao, Caracter, Código da ordem de produção.
@param 02 page         , Number  , Páginação da consulta.
@param 03 pageSize     , Number  , Tamanho da paginação da consulta.
@param 04 operacao     , Caracter, Filtro de operação.
@param 05 recurso      , Caracter, Filtro de recurso.
@param 06 centroTrab   , Caracter, Filtro de centro de trabalho.
@return lSucesso, Lógico, Indica se teve sucesso na requisição.
/*/
WSMETHOD GET OPERACOES PATHPARAM ordemProducao QUERYPARAM page, pageSize, operacao, recurso, centroTrab WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOperac(Self:page, Self:pageSize, Self:ordemProducao, Self:operacao, Self:recurso, Self:centroTrab)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} getOperac
Busca as operações efetivadas de uma ordem de produção.
@type  Static Function
@author Lucas Fagundes
@since 05/04/2024
@version P12
@param 01 nPage    , Number  , Páginação da consulta.
@param 02 nPageSize, Number  , Tamanho da paginação da consulta.
@param 03 cOrdem   , Caracter, Ordem de produção que vai buscar as operações.
@param 04 cOperac  , Caracter, Filtro de operação.
@param 05 cRecurso , Caracter, Filtro de recurso.
@param 06 cCT      , Caracter, Filtro de centro de trabalho.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getOperac(nPage, nPageSize, cOrdem, cOperac, cRecurso, cCT)
	Local aReturn    := Array(3)
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local lPerdInf   := getPerInf()
	Local lApontar   := usrPodeApo()
	Local nCount     := 0
	Local nSaldo     := 0
	Local nStart     := 0
	Local oReturn    := JsonObject():New()
	Local oChaveApon := Nil

	cQuery += " SELECT operacoes.HWF_OPER, "
	cQuery +=        " operacoes.descricao, "
	cQuery +=        " operacoes.HWF_RECURS, "
	cQuery +=        " operacoes.H1_DESCRI, "
	cQuery +=        " operacoes.HWF_CTRAB, "
	cQuery +=        " operacoes.HB_NOME, "
	cQuery +=        " operacoes.C2_QUANT, "
	cQuery +=        " operacoes.dataIni, "
	cQuery +=        " operacoes.horaIni, "
	cQuery +=        " operacoes.dataFim, "
	cQuery +=        " operacoes.horaFim, "
	cQuery +=        " COALESCE(SUM(SH6a.H6_QTDPROD), 0) H6_QTDPROD, "
	cQuery +=        " COALESCE(SUM(SH6a.H6_QTDPERD), 0) H6_QTDPERD, "
	cQuery +=        " operacoes.C2_DATRF, "
	cQuery +=        " operacoes.HWF_RECALT "
	cQuery +=   " FROM ("

	cQuery += " SELECT DISTINCT HWF.HWF_OP, "
	cQuery +=                 " HWF.HWF_OPER, "
	cQuery +=                 " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) descricao, "
	cQuery +=                 " HWF.HWF_RECURS, "
	cQuery +=                 " SH1.H1_DESCRI, "
	cQuery +=                 " HWF.HWF_CTRAB, "
	cQuery +=                 " SHB.HB_NOME, "
	cQuery +=                 " SC2.C2_QUANT, "
	cQuery +=                 " HWFmenor.HWF_DATA dataIni, "
	cQuery +=                 " HWFmenor.HWF_HRINI horaIni, "
	cQuery +=                 " HWFmaior.HWF_DATA dataFim, "
	cQuery +=                 " HWFmaior.HWF_HRFIM horaFim, "
	cQuery +=                 " SC2.C2_DATRF, "
	If gravaAlt()
		cQuery +=             " HWF.HWF_RECALT "
	Else
		cQuery +=             " '" + NAO_ALOCOU_ALTERNATIVO + "' HWF_RECALT "
	EndIf
	cQuery +=   " FROM " + RetSqlName("HWF") + " HWF "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SHY") + " SHY "
	cQuery +=     " ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
	cQuery +=    " AND SHY.HY_OP      = HWF.HWF_OP "
	cQuery +=    " AND SHY.HY_ROTEIRO = HWF.HWF_ROTEIR "
	cQuery +=    " AND SHY.HY_OPERAC  = HWF.HWF_OPER "
	cQuery +=    " AND SHY.HY_TEMPAD  <> 0 "
	cQuery +=    " AND SHY.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
	cQuery +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
	cQuery +=    " AND SG2.G2_CODIGO  = HWF.HWF_ROTEIR "
	cQuery +=    " AND SG2.G2_OPERAC  = HWF.HWF_OPER "
	cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cQuery +=    " AND SHY.HY_OP IS NULL "
	cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cQuery +=    " AND SH1.H1_CODIGO  = HWF.HWF_RECURS "
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SHB") + " SHB "
	cQuery +=     " ON SHB.HB_FILIAL  = '" + xFilial("SHB") + "' "
	cQuery +=    " AND SHB.HB_COD     = HWF.HWF_CTRAB "
	cQuery +=    " AND SHB.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("HWF") + " HWFmenor "
	cQuery +=     " ON HWFmenor.HWF_FILIAL = HWF.HWF_FILIAL "
	cQuery +=    " AND HWFmenor.HWF_OP     = HWF.HWF_OP "
	cQuery +=    " AND HWFmenor.HWF_OPER   = HWF.HWF_OPER "
	cQuery +=    " AND HWFmenor.HWF_SEQ    = (SELECT MIN(HWFmenorAux.HWF_SEQ) "
	cQuery +=                                 " FROM " + RetSqlName("HWF") + " HWFmenorAux "
	cQuery +=                                " WHERE HWFmenorAux.HWF_FILIAL = HWFmenor.HWF_FILIAL "
	cQuery +=                                  " AND HWFmenorAux.HWF_OP     = HWFmenor.HWF_OP "
	cQuery +=                                  " AND HWFmenorAux.HWF_OPER   = HWFmenor.HWF_OPER "
	cQuery +=                                  " AND HWFmenorAux.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND HWFmenor.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("HWF") + " HWFmaior "
	cQuery +=     " ON HWFmaior.HWF_FILIAL = HWF.HWF_FILIAL "
	cQuery +=    " AND HWFmaior.HWF_OP     = HWF.HWF_OP "
	cQuery +=    " AND HWFmaior.HWF_OPER   = HWF.HWF_OPER "
	cQuery +=    " AND HWFmaior.HWF_SEQ    = (SELECT MAX(HWFmaiorAux.HWF_SEQ) "
	cQuery +=                                 " FROM " + RetSqlName("HWF") + " HWFmaiorAux "
	cQuery +=                                " WHERE HWFmaiorAux.HWF_FILIAL = HWFmaior.HWF_FILIAL "
	cQuery +=                                  " AND HWFmaiorAux.HWF_OP     = HWFmaior.HWF_OP "
	cQuery +=                                  " AND HWFmaiorAux.HWF_OPER   = HWFmaior.HWF_OPER "
	cQuery +=                                  " AND HWFmaiorAux.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND HWFmaior.D_E_L_E_T_  = ' ' "
	cQuery +=  " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
	cQuery +=    " AND HWF.HWF_OP     = '" + cOrdem + "' "
	cQuery +=    " AND NOT EXISTS (SELECT 1 "
	cQuery +=                      " FROM " + RetSqlName("SH6") + " SH6b "
	cQuery +=                     " WHERE SH6b.H6_FILIAL  = '" + xFilial("SH6") + "' "
	cQuery +=                       " AND SH6b.H6_OP      = HWF.HWF_OP "
	cQuery +=                       " AND SH6b.H6_OPERAC  = HWF.HWF_OPER "
	cQuery +=                       " AND SH6b.H6_PT      = 'T' "
	cQuery +=                       " AND SH6b.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND HWF.D_E_L_E_T_ = ' ' "

	If !Empty(cOperac)
		cQuery += " AND HWF.HWF_OPER LIKE '" + cOperac + "%' "
	EndIf

	If !Empty(cRecurso)
		cQuery += " AND HWF.HWF_RECURS IN ('" + StrTran(cRecurso, ",", "','") + "') "
	EndIf

	If cCT != Nil
		cQuery += " AND HWF.HWF_CTRAB IN ('" + StrTran(cCT, ",", "','") + "') "
	EndIf

	cQuery += ") operacoes "
	cQuery +=   " LEFT JOIN " + RetSqlName("SH6") + " SH6a "
	cQuery +=     " ON SH6a.H6_FILIAL  = '" + xFilial("SH6") + "' "
	cQuery +=    " AND SH6a.H6_OP      = operacoes.HWF_OP "
	cQuery +=    " AND SH6a.H6_OPERAC  = operacoes.HWF_OPER "
	cQuery +=    " AND SH6a.D_E_L_E_T_ = ' ' "
	cQuery +=  " GROUP BY operacoes.HWF_OPER, "
	cQuery +=           " operacoes.descricao, "
	cQuery +=           " operacoes.HWF_RECURS, "
	cQuery +=           " operacoes.H1_DESCRI, "
	cQuery +=           " operacoes.HWF_CTRAB, "
	cQuery +=           " operacoes.HB_NOME, "
	cQuery +=           " operacoes.C2_QUANT, "
	cQuery +=           " operacoes.dataIni, "
	cQuery +=           " operacoes.horaIni, "
	cQuery +=           " operacoes.dataFim, "
	cQuery +=           " operacoes.horaFim, "
	cQuery +=           " operacoes.C2_DATRF, "
	cQuery +=           " operacoes.HWF_RECALT "
	cQuery +=  " ORDER BY operacoes.HWF_OPER "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	TcSetField(cAlias, 'dataIni', 'D', GetSx3Cache("HWF_DATA", "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'dataFim', 'D', GetSx3Cache("HWF_DATA", "X3_TAMANHO"), 0)

	If nPage > 1
		nStart := ((nPage-1) * nPageSize)

		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		If lApontar .And. Empty((cAlias)->C2_DATRF)
			oChaveApon := JsonObject():New()
			oChaveApon["ordem"   ] := cOrdem
			oChaveApon["operacao"] := (cAlias)->HWF_OPER
			oReturn["items"][nCount]["acoes"] := {"apontar"}
		EndIf

		nSaldo := (cAlias)->C2_QUANT - (cAlias)->H6_QTDPROD
		If !lPerdInf
			nSaldo -= (cAlias)->H6_QTDPERD
		EndIf

		oReturn["items"][nCount]["operacao"] := RTrim((cAlias)->HWF_OPER)
		If !Empty((cAlias)->descricao)
			oReturn["items"][nCount]["operacao"] += " - " + RTrim((cAlias)->descricao)
		EndIf

		oReturn["items"][nCount]["centroDeTrabalho"] := RTrim((cAlias)->HWF_CTRAB) + " - " + RTrim((cAlias)->HB_NOME)
		If Empty((cAlias)->HWF_CTRAB)
			oReturn["items"][nCount]["centroDeTrabalho"] := STR0140 // "Centro de trabalho em branco"
		EndIf

		oReturn["items"][nCount]["recurso"          ] := RTrim((cAlias)->HWF_RECURS) + " - " + RTrim((cAlias)->H1_DESCRI)
		oReturn["items"][nCount]["dataInicial"      ] := DToC((cAlias)->dataIni) + " - " + (cAlias)->horaIni
		oReturn["items"][nCount]["dataFinal"        ] := DToC((cAlias)->dataFim) + " - " + (cAlias)->horaFim
		oReturn["items"][nCount]["saldo"            ] := Max(nSaldo, 0)
		oReturn["items"][nCount]["chaveApontamento" ] := oChaveApon
		oReturn["items"][nCount]["alocouAlternativo"] := (cAlias)->HWF_RECALT == ALOCOU_ALTERNATIVO

		oChaveApon := Nil

		(cAlias)->(dbSkip())
		If nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getPerInf
Retorna o valor do parâmetro MV_PERDINF.
@type  Static Function
@author Lucas Fagundes
@since 11/04/2024
@version P12
@return _lPerdInf, Lógico, Valor do parâmetro MV_PERDINF.
/*/
Static Function getPerInf()

	If _lPerdInf == Nil
		_lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)
	EndIf

Return _lPerdInf

/*/{Protheus.doc} abreTela
Abre a tela de consulta de OPs Efetivadas
@author Jefferson Possidonio
@since 12/04/2024
@version P12
@param 01 cFiltrOp , Caracter, Filtro com as Ops a serem consultadas.
@param 02 aFiliais , Array   , Array com as filiais a serem processadas.
@return _lContinua , lógico  , Indica se continua para a exclusão das OPs.
/*/
Method abreTela(cFiltrOp, aFiliais) Class PCPA152Efetivacao
	Local aButtons := {}
	Local cQuery   := getQuery(aFiliais, cFiltrOp)
	Local oModel   := Nil
	Local oView    := Nil

	FWMsgRun(Nil, {|| buscaEfet(cQuery)}, STR0483, STR0484) // "Aguarde" "Validando ordens efetivadas..."

	If Len(_aOpsTela) == 0
		Return .T.
	EndIf

	If _oViewExec == Nil
		oModel := montaModel()
		oView  := montaView(oModel)

		aButtons  := { {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F. ,Nil}, {.F., Nil}, {.F., Nil},;
		               {.T., STR0088}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil} } // "Confirmar"

		_oViewExec := FWViewExec():New()

		_oViewExec:setView(oView)

		_oViewExec:setTitle(STR0475) // "Ordens de Produção Efetivadas"
		_oViewExec:setOperation(MODEL_OPERATION_VIEW)
		_oViewExec:setReduction(45)

		_oViewExec:setButtons(aButtons)
		_oViewExec:setCancel({|oModel| _lContinua := .T.})
	EndIf

	If _lShowView
		_oViewExec:openView(.F.)
	Endif

	_aOpsTela := {}

Return _lContinua

/*/{Protheus.doc} montaModel
Monta o modelo de dados para consulta de ordens de produção efetivadas do CRP.
@author Jefferson Possidonio
@since 12/04/2024
@version P12
@return Nil
/*/
Static Function montaModel()
	Local oStruCab   := FWFormModelStruct():New()
	Local oStruGrid  := FWFormStruct(1, "HWF", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|HWF_FILIAL|HWF_OP|HWF_OPER|"})
	Local oModel     := MPFormModel():New("PCPA152Efetivacao")

	oStruCab:AddField("", "", "CAB", "N", 2, 0, {|| .T.}, Nil, {}, .T., Nil, .F., .F., .F., Nil)

	oModel:addFields("CAB_INVISIVEL", /*cOwner*/, oStruCab, , , {|| loadCabInv()})
	oModel:GetModel("CAB_INVISIVEL"):SetDescription(STR0475) // "Ordens de Produção Efetivadas"
	oModel:GetModel("CAB_INVISIVEL"):SetOnlyQuery(.T.)
	oModel:GetModel("CAB_INVISIVEL"):setForceLoad(.T.)

	oStruGrid:AddField(STR0165, STR0165, "C2_PRODUTO", "C", GetSx3Cache("C2_PRODUTO", "X3_TAMANHO"), GetSx3Cache("C2_PRODUTO", "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Produto"
	oStruGrid:AddField(STR0200, STR0200, "B1_DESC"   , "C", 25                                     , GetSx3Cache("B1_DESC"   , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Descrição"
	oStruGrid:AddField(STR0200, STR0200, "DESCRICAO" , "C", GetSX3Cache("G2_DESCRI" , "X3_TAMANHO"), GetSx3Cache("G2_DESCRI" , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Descrição"
	oStruGrid:AddField(STR0036, STR0036, "DATAINI"   , "D", GetSx3Cache("HWF_DATA"  , "X3_TAMANHO"), GetSx3Cache("HWF_DATA"  , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Data inicial"
	oStruGrid:AddField(STR0037, STR0037, "DATAFIM"   , "D", GetSx3Cache("HWF_DATA"  , "X3_TAMANHO"), GetSx3Cache("HWF_DATA"  , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Data final"

	oModel:AddGrid("GRID_EFETIVADAS", "CAB_INVISIVEL", oStruGrid, , , , ,{|oGridModel| _aOpsTela})
	oModel:GetModel("GRID_EFETIVADAS"):SetDescription(STR0475) // "Ordens de Produção Efetivadas"
	oModel:GetModel("GRID_EFETIVADAS"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID_EFETIVADAS"):SetOptional(.T.)
	oModel:GetModel("GRID_EFETIVADAS"):setForceLoad(.T.)

	oModel:SetDescription(STR0475 + CRLF + STR0474) //"Ordens de Produção Efetivadas" + "Deseja Continuar"
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} montaView
Monta a view para a tela de consulta das OPs efetivadas do CRP.
@author Jefferson Possidonio
@since 12/04/2024
@version P12
@return Nil
/*/
Static Function montaView(oModel)
	Local oStruGrid := FWFormStruct(2, "HWF", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|HWF_FILIAL|HWF_OP|HWF_OPER|"})
	Local oView     := FWFormView():New()

	oView:SetModel(oModel)

	oStruGrid:AddField("C2_PRODUTO", "03", STR0165, STR0165, {}, "C", GetSX3Cache("C2_PRODUTO" , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Produto"
	oStruGrid:AddField("B1_DESC"   , "04", STR0200, STR0200, {}, "C", GetSX3Cache("B1_DESC"    , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Descrição"
	oStruGrid:AddField("DESCRICAO" , "06", STR0200, STR0200, {}, "C", GetSX3Cache("G2_DESCRI"  , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Descrição"
	oStruGrid:AddField("DATAINI"   , "07", STR0036, STR0036, {}, "D", GetSX3Cache("HWF_DATA"   , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Data inicial"
	oStruGrid:AddField("DATAFIM"   , "08", STR0037, STR0037, {}, "D", GetSX3Cache("HWF_DATA"   , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Data final"

	oStruGrid:SetProperty("HWF_FILIAL", MVC_VIEW_ORDEM, "01")
	oStruGrid:SetProperty("HWF_OP"    , MVC_VIEW_ORDEM, "02")
	oStruGrid:SetProperty("HWF_OPER"  , MVC_VIEW_ORDEM, "05")

	oView:AddOtherObject("VIEWLABEL", {|oPanel| criaLabel(oPanel)})
	oView:AddGrid("V_GRID_EFETIVADAS", oStruGrid, "GRID_EFETIVADAS")

	oView:CreateHorizontalBox("BOX_LABEL",5)
	oView:CreateHorizontalBox("BOX_GRID", 95)

	oView:SetOwnerView("VIEWLABEL", 'BOX_LABEL')
	oView:SetOwnerView("V_GRID_EFETIVADAS", 'BOX_GRID')

	oView:SetViewProperty("V_GRID_EFETIVADAS", "ONLYVIEW")
	oView:SetViewProperty("V_GRID_EFETIVADAS", "GRIDFILTER", {.T.})
	oView:SetViewProperty("V_GRID_EFETIVADAS", "GRIDSEEK", {.T.})

	oView:showUpdateMsg(.F.)

	oView:AddUserButton(STR0056, "", {|oView| cancelDEL(oView)}, , , , .T.) // "Cancelar"

Return oView

/*/{Protheus.doc} loadCabInv
Carga do cabeçalho invisivel da consulta de OPs efetivadas do CRP.
@type  Static Function
@author Jefferson Possidonio
@since 16/04/2024
@version P12
@return aLoad, Array, Dados do cabeçalho invisivel.
/*/
Static Function loadCabInv()
	Local aLoad := {}

	aAdd(aLoad, {1}) //dados
	aAdd(aLoad, 1  ) //recno

Return aLoad

/*/{Protheus.doc} buscaEfet
Realiza a carga dos dados para consulta na tela de Efetivadas do CRP.
@author Jefferson Possidonio
@since 16/04/2024
@version P12
@return Nil
/*/
Static Function buscaEfet(cQuery)
	Local cAlias := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	TcSetField(cAlias, 'DATAINI', 'D', 8, 0)
	TcSetField(cAlias, 'DATAFIM', 'D', 8, 0)

	_aOpsTela := {}

	While (cAlias)->(!EoF())
		aAdd(_aOpsTela, {0, { (cAlias)->HWF_FILIAL,;
		                      (cAlias)->HWF_OP    ,;
		                      (cAlias)->HWF_OPER  ,;
		                      (cAlias)->C2_PRODUTO,;
		                      (cAlias)->B1_DESC   ,;
							  (cAlias)->DESCRICAO ,;
		                      (cAlias)->DATAINI   ,;
		                      (cAlias)->DATAFIM   }})
		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} getQuery
Retorna a query para buscar as ordens efetivadas do CRP.
@author Jefferson Possidonio
@since 16/04/2024
@version P12
@param 01 aFiliais, Array   , Array com as filiais a serem processadas.
@param 02 cFiltrOp, Caracter, Filtro com as Ops a serem consultadas.
@return cQuery, Caracter, Query para buscar as ordens efetivadas do CRP.
/*/
Static Function getQuery(aFiliais, cFiltOp)
	Local cOptmzrOrc := " "
	Local cQuery     := ""

	If _lOptOrcl
		//Verifica tratamento de compatibilidade para o Oracle.
		cOptmzrOrc := PCPOptOrcl()
	EndIf

	cQuery += " SELECT " + cOptmzrOrc + " DISTINCT "
	cQuery +=                 " HWF.HWF_FILIAL,"
	cQuery +=                 " HWF.HWF_OP,"
	cQuery +=                 " SC2.C2_PRODUTO,"
	cQuery +=                 " SB1.B1_DESC,"
	cQuery +=                 " HWF.HWF_OPER,"
	cQuery +=                 " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) DESCRICAO, "
	cQuery +=                 " hwfMenor.HWF_DATA DATAINI,"
	cQuery +=                 " hwfMaior.HWF_DATA DATAFIM "
	cQuery +=   " FROM " + RetSqlName("HWF") + " HWF"
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2"
	cQuery +=     " ON " + filtroFil("C2_FILIAL", "SC2", aFiliais)
	cQuery += 	 " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
	cQuery +=    " AND SC2.C2_DATRF   = ' '"
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("HWF") + " hwfMenor"
	cQuery +=     " ON hwfMenor.HWF_FILIAL = HWF.HWF_FILIAL"
	cQuery +=    " AND hwfMenor.HWF_OP     = HWF.HWF_OP"
	cQuery +=    " AND hwfMenor.HWF_OPER   = HWF.HWF_OPER"
	cQuery +=    " AND hwfMenor.HWF_RECURS = HWF.HWF_RECURS"
	cQuery +=    " AND hwfMenor.HWF_CTRAB  = HWF.HWF_CTRAB"
	cQuery +=    " AND hwfMenor.HWF_SEQ    = (SELECT Min(hwfMenorAux.HWF_SEQ)"
	cQuery +=								  " FROM " + RetSqlName("HWF") + " hwfMenorAux"
	cQuery +=								 " WHERE hwfMenorAux.HWF_FILIAL = hwfMenor.HWF_FILIAL"
	cQuery += 								   " AND hwfMenorAux.HWF_OP     = hwfMenor.HWF_OP"
	cQuery += 							       " AND hwfMenorAux.HWF_OPER   = hwfMenor.HWF_OPER"
	cQuery += 							       " AND hwfMenorAux.HWF_RECURS = hwfMenor.HWF_RECURS"
	cQuery += 							       " AND hwfMenorAux.HWF_CTRAB  = hwfMenor.HWF_CTRAB"
	cQuery += 							       " AND hwfMenorAux.D_E_L_E_T_ = ' ')"
	cQuery +=    " AND hwfMenor.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN " + RetSqlName("HWF") + " hwfMaior"
	cQuery +=	  " ON hwfMaior.HWF_FILIAL = HWF.HWF_FILIAL"
	cQuery += 	 " AND hwfMaior.HWF_OP     = HWF.HWF_OP"
	cQuery += 	 " AND hwfMaior.HWF_OPER   = HWF.HWF_OPER"
	cQuery += 	 " AND hwfMaior.HWF_RECURS = HWF.HWF_RECURS"
	cQuery += 	 " AND hwfMaior.HWF_CTRAB  = HWF.HWF_CTRAB"
	cQuery += 	 " AND hwfMaior.HWF_SEQ    = (SELECT Max(hwfMaiorAux.HWF_SEQ)"
	cQuery += 								  " FROM " + RetSqlName("HWF") + " hwfMaiorAux"
	cQuery += 								 " WHERE hwfMaiorAux.HWF_FILIAL = hwfMaior.HWF_FILIAL"
	cQuery += 								   " AND hwfMaiorAux.HWF_OP     = hwfMaior.HWF_OP"
	cQuery += 								   " AND hwfMaiorAux.HWF_OPER   = hwfMaior.HWF_OPER"
	cQuery += 								   " AND hwfMaiorAux.HWF_RECURS = hwfMaior.HWF_RECURS"
	cQuery += 								   " AND hwfMaiorAux.HWF_CTRAB  = hwfMaior.HWF_CTRAB"
	cQuery += 								   " AND hwfMaiorAux.D_E_L_E_T_ = ' ')"
	cQuery +=    " AND hwfMaior.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cQuery += 	  " ON " + filtroFil("B1_FILIAL", "SB1", aFiliais)
	cQuery += 	 " AND SB1.B1_COD     = SC2.C2_PRODUTO"
	cQuery += 	 " AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN " + RetSqlName("SHY") + " SHY "
	cQuery +=    " ON " + filtroFil("HY_FILIAL", "SHY", aFiliais)
	cQuery +=   " AND SHY.HY_OP      = HWF.HWF_OP "
	cQuery +=   " AND SHY.HY_ROTEIRO = HWF.HWF_ROTEIR "
	cQuery +=   " AND SHY.HY_OPERAC  = HWF.HWF_OPER "
	cQuery +=   " AND SHY.HY_TEMPAD  <> 0 "
	cQuery +=   " AND SHY.D_E_L_E_T_ = ' ' "
	cQuery +=  " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
	cQuery +=    " ON " + filtroFil("G2_FILIAL", "SG2", aFiliais)
	cQuery +=   " AND SG2.G2_CODIGO  = HWF.HWF_ROTEIR "
	cQuery +=   " AND SG2.G2_OPERAC  = HWF.HWF_OPER "
	cQuery +=   " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cQuery +=   " AND SHY.HY_OP IS NULL "
	cQuery +=   " AND SG2.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE HWF." + filtroFil("HWF_FILIAL", "HWF", aFiliais)
	cQuery +=  cFiltOp
	cQuery += 	 " AND HWF.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY HWF.HWF_OP, HWF.HWF_OPER"

	If "MSSQL" $ TcGetDb()
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

Return cQuery

/*/{Protheus.doc} cancelDEL
Fechar a view com a ação do botão cancelar
@type  Static Function
@author Jefferson Possidonio
@since 16/04/2024
@version P12
@param oView, Objeto, Instância da view da tela.
@return lFecha, Logico, Indica se deve fechar a tela.
/*/
Static Function cancelDEL(oView)
	oView:CloseOwner()
Return .F.

/*/{Protheus.doc} criaLabel
Monta o label para exibir a mensagem na tela de ordens de produção efetivadas.
@author Jefferson Possidonio
@since 02/05/2024
@version 1.0
@return Nil
@param oPanel, Objeto, Painel criado pelo método AddOtherObject
/*/
Static Function criaLabel(oPanel)
	Local oSay  := Nil
	Local oFont := TFont():New(,,,.T.,.T.)

	oSay := TSay():New(01,10,{||STR0476},oPanel,,oFont,,,,.T.,,,oPanel:nWidth/2,oPanel:nHeight/2) //"Existe(m) ordem(ns) de produção efetivada(s) no CRP. Deseja Continuar?"
	oSay:lWordWrap = .F.
Return

/*/{Protheus.doc} filtroFil
Cria string filtro com filtro da filial para busca dos campos multivalorados.
@type  Static Function
@author Jefferson Possidonio
@since 13/05/2024
@version P12
@param 01 cFieldFil, Caracter, Nome do campo filial para fazer o filtro.
@param 02 cAlias   , Caracter, Alias da tabela para realizar o xFilial.
@param 03 aFiliais , Array	 , Array com as filiais do multiempresa
@return cFiltro, Caracter, Filtro de filial IN ou = para a query.
/*/
Static Function filtroFil(cFieldFil, cAlias, aFiliais)
	Local cFiltro  := ""
	Local nIndex   := 0
	Local nTotFils := 0
	Default aFiliais := {cFilAnt}

	nTotFils := Len(aFiliais)
	If nTotFils > 1
		cFiltro := cFieldFil + " IN ("

		For nIndex := 1 To nTotFils
			If nIndex > 1
				cFiltro += ","
			EndIf
			cFiltro += "'" + xFilial(cAlias, aFiliais[nIndex]) + "'"
		Next nIndex
		cFiltro += ")"

	Else
		cFiltro := cFieldFil + " = '" + xFilial(cAlias) + "' "
	EndIf

Return cFiltro

/*/{Protheus.doc} POST DESEFETIVA /api/pcp/v1/pcpa152efe/desefetiva/{ordemProducao}
Desefetiva uma ordem de produção.
@type WSMETHOD
@author Lucas Fagundes
@since 12/08/2024
@version P12
@param ordemProducao, caracter, Ordem de produção que será desefetivada.
@return lSucesso, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD POST DESEFETIVA PATHPARAM ordemProducao WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := desefetiva(Self:ordemProducao)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} desefetiva
Desefetiva uma ordem de produção.
@type  Static Function
@author Lucas Fagundes
@since 12/08/2024
@version P12
@param cOrdem, Caracter, Ordem de produção que será desefetivada.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function desefetiva(cOrdem)
	Local aReturn   := Array(3)
	Local cError    := ""
	Local cErrorDet := ""
	Local cUpdate   := ""
	Local lSucesso  := .T.
	Local oReturn   := JsonObject():New()

	cOrdem := "'" + cOrdem + "'"

	BEGIN TRANSACTION
		logDesefet(cOrdem, Nil)

		cUpdate := " UPDATE " + RetSqlName("SC2")
		cUpdate +=    " SET C2_STATUS = 'N' "
		cUpdate +=  " WHERE C2_FILIAL = '" + xFilial("SC2") + "' "
		cUpdate +=    " AND " + PCPQrySC2("", cOrdem)
		cUpdate +=    " AND D_E_L_E_T_ = ' ' "

		If TcSqlExec(cUpdate) < 0
			lSucesso  := .F.
			cError    := i18n(STR0528, {"SC2"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
			cErrorDet := AllTrim(TcSqlError())
		EndIf

		If lSucesso
			lSucesso := ajustProgs(cOrdem)
		EndIf

		If lSucesso
			cUpdate := " UPDATE " + RetSqlName("HWF")
			cUpdate +=    " SET D_E_L_E_T_   = '*', "
			cUpdate +=        " R_E_C_D_E_L_ = R_E_C_N_O_ "
			cUpdate +=  " WHERE HWF_FILIAL = '" + xFilial("HWF") + "' "
			cUpdate +=    " AND HWF_OP     = "  + cOrdem
			cUpdate +=    " AND D_E_L_E_T_ = ' ' "

			If TcSqlExec(cUpdate) < 0
				lSucesso  := .F.
				cError    := i18n(STR0528, {"HWF"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
				cErrorDet := AllTrim(TcSqlError())
			EndIf
		EndIf

		If lSucesso .And. temDicFerr()
			cUpdate := " UPDATE " + RetSqlName("HZL")
			cUpdate +=    " SET D_E_L_E_T_   = '*', "
			cUpdate +=        " R_E_C_D_E_L_ = R_E_C_N_O_ "
			cUpdate +=  " WHERE HZL_FILIAL = '" + xFilial("HZL") + "' "
			cUpdate +=    " AND HZL_OP     = "  + cOrdem
			cUpdate +=    " AND D_E_L_E_T_ = ' ' "

			If TcSqlExec(cUpdate) < 0
				lSucesso  := .F.
				cError    := i18n(STR0528, {"HZL"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
				cErrorDet := AllTrim(TcSqlError())
			EndIf
		EndIf

		If !lSucesso
			DisarmTransaction()
		EndIf

	END TRANSACTION

	aReturn[1] := lSucesso
	aReturn[2] := 200
	If !lSucesso
		aReturn[2] := 500

		oReturn["message"        ] := cError
		oReturn["detailedMessage"] := cErrorDet
	EndIf
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} POST DESFET_LOTE
Desefetiva ordens de produção em lote.
@type WSMETHOD
@author Lucas Fagundes
@since 15/08/2024
@version P12
@return lSucesso, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD POST DESFET_LOTE WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.
	Local cBody     := ""
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	cBody := decodeUTF8(Self:getContent())
	oBody:fromJson(cBody)

	BEGIN SEQUENCE
		aReturn := desefeLote(oBody)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} desefeLote
Realiza a desefetivação das ordens de produção em lote.
@type  Static Function
@author Lucas Fagundes
@since 15/08/2024
@version P12
@param oParams, Object, Json com os parâmetros para desefetivação.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function desefeLote(oParams)
	Local aReturn    := Array(3)
	Local cBanco     := TcGetDb()
	Local cError     := ""
	Local cErrorDet  := ""
	Local cFiltroSC2 := ""
	Local cQryAjuste := ""
	Local cUpdate    := ""
	Local lSucesso   := .T.
	Local oFiltros   := Nil
	Local oReturn    := JsonObject():New()

	BEGIN TRANSACTION
		cFiltroSC2 :=     " SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
		cFiltroSC2 += " AND SC2.C2_DATRF   = ' ' "
		cFiltroSC2 += " AND SC2.D_E_L_E_T_ = ' ' "

		If oParams["opcaoDeDesefetivacao"] == SELECAO_MANUAL
			cFiltroSC2 += " AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD IN ('" + ArrToKStr(oParams["ordens"], "','") + "') "

		ElseIf oParams["opcaoDeDesefetivacao"] == POR_FILTROS
			oFiltros := oParams["filtros"]

			If !Empty(oFiltros["ordens"])
				cFiltroSC2 += " AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD IN ('" + ArrToKStr(oFiltros["ordens"], "','") + "') "
			EndIf
			If !Empty(oFiltros["produtos"])
				cFiltroSC2 += " AND SC2.C2_PRODUTO IN ('" + ArrToKStr(oFiltros["produtos"], "','") + "') "
			EndIf
			If !Empty(oFiltros["inicio"]["start"])
				cFiltroSC2 += " AND SC2.C2_DATPRI >= '" + DToS(PCPConvDat(oFiltros["inicio"]["start"], 1)) + "' "
			EndIf
			If !Empty(oFiltros["inicio"]["end"])
				cFiltroSC2 += " AND SC2.C2_DATPRI <= '" + DToS(PCPConvDat(oFiltros["inicio"]["end"], 1)) + "' "
			EndIf
			If !Empty(oFiltros["entrega"]["start"])
				cFiltroSC2 += " AND SC2.C2_DATPRF >= '" + DToS(PCPConvDat(oFiltros["entrega"]["start"], 1)) + "' "
			EndIf
			If !Empty(oFiltros["entrega"]["end"])
				cFiltroSC2 += " AND SC2.C2_DATPRF <= '" + DToS(PCPConvDat(oFiltros["entrega"]["end"], 1)) + "' "
			EndIf

			oFiltros := Nil
		EndIf

		logDesefet(Nil, cFiltroSC2)

		cQryAjuste := "SELECT SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD"
		cQryAjuste +=  " FROM " + RetSqlName("SC2") + " SC2"
		cQryAjuste += " WHERE " + cFiltroSC2

		If "MSSQL" $ cBanco
			cQryAjuste := StrTran(cQryAjuste, "||", "+")
		EndIf

		lSucesso := ajustProgs(cQryAjuste)

		If lSucesso
			cUpdate := " UPDATE " + RetSqlName("SC2")
			cUpdate +=    " SET C2_STATUS  = 'N' "
			cUpdate +=  " WHERE EXISTS (SELECT 1 "
			cUpdate +=                  " FROM " + RetSqlName("HWF") + " HWF "
			cUpdate +=                 " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
			cUpdate +=                 "   AND " + PCPQrySC2("", "HWF.HWF_OP")
			cUpdate +=                 "   AND HWF.D_E_L_E_T_ = ' ') "
			cUpdate +=    " AND " + cFiltroSC2

			If "MSSQL" $ cBanco
				cUpdate := StrTran(cUpdate, "||", "+")
			EndIf
			cUpdate := StrTran(cUpdate, "SC2.", "")

			If TcSqlExec(cUpdate) < 0
				lSucesso  := .F.
				cError    := i18n(STR0528, {"SC2"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
				cErrorDet := AllTrim(TcSqlError())
			EndIf
		EndIf

		If lSucesso
			cUpdate := " UPDATE " + RetSqlName("HWF")
			cUpdate +=    " SET D_E_L_E_T_   = '*', "
			cUpdate +=        " R_E_C_D_E_L_ = R_E_C_N_O_ "
			cUpdate +=  " WHERE HWF_FILIAL = '" + xFilial("HWF") + "' "
			cUpdate +=    " AND D_E_L_E_T_ = ' ' "
			cUpdate +=    " AND HWF_OP    IN (SELECT SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD ordem "
			cUpdate +=                        " FROM " + RetSqlName("SC2") + " SC2 "
			cUpdate +=                       " WHERE " + cFiltroSC2 + ") "

			If "MSSQL" $ cBanco
				cUpdate := StrTran(cUpdate, "||", "+")
			EndIf

			If TcSqlExec(cUpdate) < 0
				lSucesso  := .F.
				cError    := i18n(STR0528, {"HWF"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
				cErrorDet := AllTrim(TcSqlError())
			EndIf
		EndIf

		If lSucesso .And. temDicFerr()
			cUpdate := " UPDATE " + RetSqlName("HZL")
			cUpdate +=    " SET D_E_L_E_T_   = '*', "
			cUpdate +=        " R_E_C_D_E_L_ = R_E_C_N_O_ "
			cUpdate +=  " WHERE HZL_FILIAL = '" + xFilial("HZL") + "' "
			cUpdate +=    " AND D_E_L_E_T_ = ' ' "
			cUpdate +=    " AND HZL_OP    IN (SELECT SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD ordem "
			cUpdate +=                        " FROM " + RetSqlName("SC2") + " SC2 "
			cUpdate +=                       " WHERE " + cFiltroSC2 + ") "

			If "MSSQL" $ cBanco
				cUpdate := StrTran(cUpdate, "||", "+")
			EndIf

			If TcSqlExec(cUpdate) < 0
				lSucesso  := .F.
				cError    := i18n(STR0528, {"HZL"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
				cErrorDet := AllTrim(TcSqlError())
			EndIf
		EndIf

		If !lSucesso
			DisarmTransaction()
		EndIf

	END TRANSACTION

	aReturn[1] := lSucesso
	aReturn[2] := 200
	If !lSucesso
		aReturn[2] := 500

		oReturn["message"        ] := cError
		oReturn["detailedMessage"] := cErrorDet
	EndIf
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} usrPodeApo
Retorna permissão do usuário referente a inclusão de apontamento na rotina MATA681

@type  Static Function
@author lucas.franca
@since 06/09/2024
@version P12
@return _oCachePer[cUsuario], Logic, Indica se o usuário tem permissão para incluir apontamento
/*/
Static Function usrPodeApo()
	Local aMenu    := Nil
	Local nPos     := 0
	Local cUsuario := RetCodUsr()

	If _oCachePer == Nil
		_oCachePer := JsonObject():New()
	EndIf

	If !_oCachePer:hasProperty(cUsuario)
		_oCachePer[cUsuario] := .F.

		aMenu := FwLoadMenuDef("MATA681")
		nPos  := aScan(aMenu, {|x| x[4] == 3}) //procura no menu a operação de inclusão
		If nPos > 0
			_oCachePer[cUsuario] := MPUserHasAccess("MATA681", nPos)
		EndIf
	EndIf

Return _oCachePer[cUsuario]

/*/{Protheus.doc} logDesefet
Gera log indicando que a ordem foi desefetivada
@type  Static Function
@author Lucas Fagundes
@since 25/09/2024
@version P12
@param 01 cOrdem    , Caracter, Ordem que está sendo desefetivada manualmente.
@param 02 cFiltroSC2, Caracter, Filtro de desefetivação em lote.
@return Nil
/*/
Static Function logDesefet(cOrdem, cFiltroSC2)
	Local cAlias   := GetNextAlias()
	Local cData    := DToC(dDatabase)
	Local cId      := ""
	Local cProg    := progZero()
	Local cQuery   := ""
	Local cUsuario := RetCodUsr()

	cQuery := " SELECT DISTINCT HWF.HWF_OP, "
	cQuery +=                 " HWF.HWF_PROG, "
	cQuery +=                 " (SELECT MAX(SVY.VY_ID) "
	cQuery +=                    " FROM " + RetSqlName("SVY") + " SVY "
	cQuery +=                   " WHERE SVY.VY_FILIAL  = '" + xFilial("SVY") + "' "
	cQuery +=                     " AND SVY.VY_PROG    = '" + cProg + "' "
	cQuery +=                     " AND SVY.D_E_L_E_T_ = ' ') id "
	cQuery +=   " FROM " + RetSqlName("HWF") + " HWF "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "

	If !Empty(cFiltroSC2)
		cQuery += " AND " + cFiltroSC2

		If "MSSQL" $ TcGetDb()
			cQuery := StrTran(cQuery, "||", "+")
		EndIf
	EndIf

	cQuery +=  " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
	cQuery +=    " AND HWF.D_E_L_E_T_ = ' ' "

	If !Empty(cOrdem)
		cQuery += " AND HWF.HWF_OP = " + cOrdem
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If (cAlias)->(!EoF()) .And. !Empty((cAlias)->id)
		cId := (cAlias)->id
	Else
		cId := PadL(0, GetSx3Cache("VY_ID", "X3_TAMANHO"), "0")
	EndIf

	While (cAlias)->(!EoF())
		cId := Soma1(cId)

		RecLock("SVY", .T.)
			SVY->VY_FILIAL  := xFilial("SVY")
			SVY->VY_PROG    := cProg
			SVY->VY_ID      := cId
			SVY->VY_TIPO    := LOG_DESEFETIVOU_MANUAL
			SVY->VY_OP      := (cAlias)->HWF_OP
			SVY->VY_OCORREN := i18n(STR0587, {cData, cUsuario}) // "Ordem de produção desefetivada em #1[data]# pelo usuário #2[usuário]#."
		SVY->(MsUnLock())

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} GET OCORRENCIAS /api/pcp/v1/pcpa152efe/ocorrencias
Retorna as ocorrências das ordens efetivadas.
@type WSMETHOD
@author Lucas Fagundes
@since 26/09/2024
@version P12
@param 01 page            , Numerico, Pagina da consulta
@param 02 pageSize        , Numerico, Tamanho da pagina
@param 03 ordemProducao   , Caracter, Filtro de ordem de produção
@param 04 produto         , Caracter, Filtro de produto
@param 05 dataInicialStart, Caracter, Filtro de data de inicio (DE)
@param 06 dataInicialEnd  , Caracter, Filtro de data de inicio (ATE)
@param 07 dataFinalStart  , Caracter, Filtro de data de entrega (DE)
@param 08 dataFinalEnd    , Caracter, Filtro de data de entrega (ATE)
@param 09 quickOrder      , Caracter, Filtro de ordem de produção (LIKE)
@return lSucesso, Lógico, Indica se teve sucesso na requisição
/*/
WSMETHOD GET OCORRENCIAS QUERYPARAM page, pageSize, ordemProducao, produto, dataInicialStart, dataInicialEnd, dataFinalStart, dataFinalEnd, quickOrder WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOcorren(Self:page, Self:pageSize, Self:ordemProducao, Self:produto, PCPConvDat(Self:dataInicialStart, 1), PCPConvDat(Self:dataInicialEnd, 1), PCPConvDat(Self:dataFinalStart, 1), PCPConvDat(Self:dataFinalEnd, 1), Self:quickOrder)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} getOcorren
Busca as ocorrências relacionadas a efetivação.
@type  Static Function
@author Lucas Fagundes
@since 26/09/2024
@version P12
@param 01 nPage    , Numerico, Pagina da consulta
@param 02 nPageSize, Numerico, Tamanho da pagina
@param 03 cOrdem   , Caracter, Filtro de ordem de produção
@param 04 cProduto , Caracter, Filtro de produto
@param 05 dIniDe   , Date    , Filtro de data de inicio (DE)
@param 06 dIniAte  , Date    , Filtro de data de inicio (ATE)
@param 07 dEntDe   , Date    , Filtro de data de entrega (DE)
@param 08 dEntAte  , Date    , Filtro de data de entrega (ATE)
@param 09 cOPLike  , Caracter, Filtro de ordem de produção (LIKE)
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getOcorren(nPage, nPageSize, cOrdem, cProduto, dIniDe, dIniAte, dEntDe, dEntAte, cOPLike)
	Local aReturn  := Array(3)
	Local cAlias   := GetNextAlias()
	Local cQuery   := ""
	Local lPerdInf := getPerInf()
	Local nCount   := 0
	Local nSaldo   := 0
	Local nStart   := 0
	Local oReturn  := JsonObject():New()

	cQuery := " SELECT SVY.VY_OP,      "
	cQuery +=        " SC2.C2_PRODUTO, "
	cQuery +=        " SB1.B1_DESC,    "
	cQuery +=        " SC2.C2_QUANT,   "
	cQuery +=        " SC2.C2_QUJE,    "
	cQuery +=        " SC2.C2_PERDA,   "
	cQuery +=        " SC2.C2_DATPRI,  "
	cQuery +=        " SC2.C2_DATPRF,  "
	cQuery +=        " SVY.VY_OCORREN  "
	cQuery +=   " FROM " + RetSqlName("SVY") + " SVY "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND " + PCPQrySC2("SC2", "SVY.VY_OP")
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	If !Empty(cProduto)
		cQuery += " AND SC2.C2_PRODUTO IN ('" + StrTran(cProduto, ",", "','") + "') "
	EndIf
	If !Empty(dIniDe)
		cQuery += " AND SC2.C2_DATPRI >= '" + DToS(dIniDe) + "' "
	EndIf
	If !Empty(dIniAte)
		cQuery += " AND SC2.C2_DATPRI <= '" + DToS(dIniAte) + "' "
	EndIf
	If !Empty(dEntDe)
		cQuery += " AND SC2.C2_DATPRF >= '" + DToS(dEntDe) + "' "
	EndIf
	If !Empty(dEntAte)
		cQuery += " AND SC2.C2_DATPRF <= '" + DToS(dEntAte) + "' "
	EndIf
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SVY.VY_FILIAL  = '" + xFilial("SVY") + "' "
	cQuery +=    " AND SVY.VY_PROG    = '" + progZero()     + "' "
	cQuery +=    " AND SVY.VY_TIPO    = '" + LOG_DESEFETIVOU_MANUAL + "' "
	cQuery +=    " AND SVY.D_E_L_E_T_ = ' ' "
	If !Empty(cOrdem)
		cQuery += " AND SVY.VY_OP IN ('" + StrTran(cOrdem, ",", "','") + "') "
	EndIf
	If !Empty(cOPLike)
		cQuery += " AND SVY.VY_OP LIKE '" + cOPLike + "%' "
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ((nPage-1) * nPageSize)

		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nCount++

		nSaldo := (cAlias)->C2_QUANT - (cAlias)->C2_QUJE
		If !lPerdInf
			nSaldo -= (cAlias)->C2_PERDA
		EndIf

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["ordemProducao"] := (cAlias)->VY_OP
		oReturn["items"][nCount]["produto"      ] := RTrim((cAlias)->C2_PRODUTO) + " - " + RTrim((cAlias)->B1_DESC)
		oReturn["items"][nCount]["saldo"        ] := Max(0, nSaldo)
		oReturn["items"][nCount]["dataInicio"   ] := PCPConvDat((cAlias)->C2_DATPRI, 4)
		oReturn["items"][nCount]["dataEntrega"  ] := PCPConvDat((cAlias)->C2_DATPRF, 4)
		oReturn["items"][nCount]["ocorrencia"   ] := (cAlias)->VY_OCORREN

		(cAlias)->(dbSkip())

		If nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())

	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} progZero
Retorna o código da programação zero.
@type  Static Function
@author Lucas Fagundes
@since 26/09/2024
@version P12
@return Caracter, Código da programação zero.
/*/
Static Function progZero()

	If _nTamPrg == Nil
		_nTamPrg := GetSx3Cache("T4X_PROG", "X3_TAMANHO")
	EndIf

Return PadL(0, _nTamPrg, "0")

/*/{Protheus.doc} gravaAlt
Verifica se o campo para indicar recurso alternativo está presente no dicionario de dados.
@type  Static Function
@author Lucas Fagundes
@since 21/10/2024
@version P12
@return _lFldRecAl, Logico, Indica se o campo HWF_RECALT esta no dicionario de dados.
/*/
Static Function gravaAlt()

	If _lFldRecAl == Nil
		_lFldRecAl := GetSX3Cache("HWF_RECALT", "X3_TAMANHO") > 0
	EndIf

Return _lFldRecAl

/*/{Protheus.doc} GET COMPARATIVO /api/pcp/v1/pcpa152efe/comparativo/{ordemProducao}
Retorna as informações do comparativo da OP

@type WSMETHOD
@author Breno Soares
@since 11/12/2024
@version P12
@param ordemProducao, Caracter, Ordem de produção para comparativo.
@return lSucesso, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET COMPARATIVO PATHPARAM ordemProducao WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getCompar(Self:ordemProducao)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} getCompar
Busca as informações de uma OP para comparativo
@type  Static Function
@author Breno Soares
@since 11/12/2024
@version P12
@param 01 cOrdemProd, Character, Ordem de produção para comparativo.
@return aResult, Array, Array com as informações de retorno da API.
/*/
Static Function getCompar(cOrdemProd)
	Local aResult  := {}
	Local cAlias   := ""
	Local cQuery   := ""
	Local lPerdInf := getPerInf()
	Local nSaldo   := 0
	Local oJson    := JsonObject():New()

	If _oQryComp == Nil
		_oQryComp := FwExecStatement():New()

		cQuery +=    " SELECT DISTINCT HWF.HWF_PROG, "
		cQuery +=                    " HWF.HWF_OP, "
		cQuery +=                    " SC2.C2_PRODUTO, "
		cQuery +=                    " SB1.B1_DESC, "
		cQuery +=                    " HWF.HWF_ROTEIR, "
		cQuery +=                    " SC2.C2_QUANT, "
		cQuery +=                    " SC2.C2_QUJE, "
		cQuery +=                    " SC2.C2_PERDA, "
		cQuery +=                    " COALESCE(SMF.MF_SALDO, -1) saldoCRP, "
		cQuery +=                    " COALESCE(SUM(HWF.HWF_TEMPOT), 0) tempoPlaneja, "
		cQuery +=                    " SH6.H6_TEMPO tempoApontado, "
		cQuery +=                    " SC2.C2_DATPRI, "
		cQuery +=                    " SC2.C2_DATPRF, "
		cQuery +=                    " SC2.C2_DATRF "
		cQuery +=      " FROM " + RetSqlName("HWF") + " HWF "
		cQuery +=     " INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery +=        " ON SC2.C2_FILIAL  = ? "
		cQuery +=       " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
		cQuery +=       " AND SC2.D_E_L_E_T_ = ' ' "
		cQuery +=     " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery +=        " ON SB1.B1_FILIAL  = ? "
		cQuery +=       " AND SB1.B1_COD     = SC2.C2_PRODUTO "
		cQuery +=       " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=      " LEFT JOIN " + RetSqlName("SMF") + " SMF "
		cQuery +=        " ON SMF.MF_FILIAL  = ? "
		cQuery +=       " AND SMF.MF_PROG    = HWF.HWF_PROG "
		cQuery +=       " AND SMF.MF_OP      = HWF.HWF_OP "
		cQuery +=       " AND SMF.MF_OPER    = HWF.HWF_OPER "
		cQuery +=       " AND SMF.MF_RECURSO = HWF.HWF_RECURS "
		cQuery +=       " AND SMF.D_E_L_E_T_ = ' ' "
		cQuery +=     " LEFT JOIN " + RetSqlName("SH6") + " SH6 "
		cQuery +=        " ON SH6.H6_FILIAL  = ? "
		cQuery +=       " AND SH6.H6_OP      = HWF.HWF_OP "
		cQuery +=       " AND SH6.H6_OPERAC  = HWF.HWF_OPER "
		cQuery +=       " AND SH6.D_E_L_E_T_ = ' ' "
		cQuery +=     " WHERE HWF.HWF_FILIAL = ? "
		cQuery +=       " AND HWF.HWF_OP     = ? "
		cQuery +=       " AND HWF.D_E_L_E_T_ = ' ' "
		cQuery +=     " GROUP BY HWF_PROG, "
		cQuery +=              " HWF_OP, "
		cQuery +=              " C2_PRODUTO, "
		cQuery +=              " B1_DESC, "
		cQuery +=              " HWF_ROTEIR, "
		cQuery +=              " C2_QUANT, "
		cQuery +=              " C2_QUJE, "
		cQuery +=              " C2_PERDA, "
		cQuery +=              " MF_SALDO, "
		cQuery +=              " HWF_TEMPOT, "
		cQuery +=              " H6_TEMPO, "
		cQuery +=              " C2_DATPRI, "
		cQuery +=              " C2_DATPRF, "
		cQuery +=              " C2_DATRF "

		_oQryComp:setQuery(cQuery)
	EndIf

	_oQryComp:SetString(1, xFilial("SC2"))
	_oQryComp:SetString(2, xFilial("SB1"))
	_oQryComp:SetString(3, xFilial("SMF"))
	_oQryComp:SetString(4, xFilial("SH6"))
	_oQryComp:SetString(5, xFilial("HWF"))
	_oQryComp:SetString(6, cOrdemProd)

	cAlias := _oQryComp:OpenAlias()

	While (cAlias)->(!Eof())

		nSaldo := (cAlias)->C2_QUANT - (cAlias)->C2_QUJE
		If !lPerdInf
			nSaldo -= (cAlias)->C2_PERDA
		EndIf

		oJson["programacao"   ] := (cAlias)->HWF_PROG
		oJson["ordemProducao" ] := (cAlias)->HWF_OP
		oJson["produto"       ] := (cAlias)->C2_PRODUTO + " - " + (cAlias)->B1_DESC
		oJson["roteiro"       ] := (cAlias)->HWF_ROTEIR
		oJson["quantidade"    ] := (cAlias)->C2_QUANT
		If (cAlias)->saldoCRP == -1
			oJson["saldoCRP"] := "-"
		Else
			oJson["saldoCRP"] := (cAlias)->saldoCRP
		EndIf
		oJson["saldoOP"       ] := nSaldo
		oJson["tempoPlanejado"] := __Min2Hrs((cAlias)->tempoPlaneja, .T.)
		oJson["tempoApontado" ] := __Min2Hrs(somaTempo((cAlias)->tempoApontado), .T.)
		oJson["datas"         ] := PCPConvDat((cAlias)->C2_DATPRI, 4) + " - " + PCPConvDat((cAlias)->C2_DATPRF, 4)
		oJson["finalizacao"   ] := PCPConvDat((cAlias)->C2_DATRF, 4)

		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

	aAdd(aResult, .T.)
	aAdd(aResult, 200)
	aAdd(aResult, oJson:toJson())

	FwFreeObj(oJson)
	_cTempoPla := Nil

Return aResult

/*/{Protheus.doc} GET COMPOPER /api/pcp/v1/pcpa152efe/comparativo/operacoes/{ordemProducao}
Retorno das operações da OP para comparativo

@type WSMETHOD
@author Breno Soares
@since 11/12/2024
@version P12
@param ordemProducao, Caracter, Ordem de produção para comparativo.
@return lSucesso, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET COMPOPER PATHPARAM ordemProducao WSSERVICE PCPA152EFE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152EFE"), Break(oError)})
	Local lSucesso  := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getComOper(Self:ordemProducao)
	END SEQUENCE

	lSucesso := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lSucesso

/*/{Protheus.doc} getComOper
Busca as operações de uma OP para comparativo
@type  Static Function
@author Breno Soares
@since 11/12/2024
@version P12
@param 01 cOrdemProd, Character, Ordem de produção para comparativo.
@return aResult, Array, Array com as informações de retorno da API.
/*/
Static Function getComOper(cOrdemProd)
	Local aResult  := {}
	Local cAlias   := ""
	Local cQuery   := ""
	Local lPerdInf := getPerInf()
	Local nCont    := 0
	Local nSaldo   := 0
	Local oJson    := JsonObject():New()

	If _oQryOper == Nil
		_oQryOper := FwExecStatement():New()

		cQuery += " SELECT operacoes.HWF_OPER, "
		cQuery +=        " operacoes.descricao, "
		cQuery +=        " operacoes.HWF_RECURS, "
		cQuery +=        " operacoes.H1_DESCRI, "
		cQuery +=        " operacoes.HWF_CTRAB, "
		cQuery +=        " operacoes.HB_NOME, "
		cQuery +=        " operacoes.C2_QUANT, "
		cQuery +=        " operacoes.dataIni, "
		cQuery +=        " operacoes.horaIni, "
		cQuery +=        " operacoes.dataFim, "
		cQuery +=        " operacoes.horaFim, "
		cQuery +=        " COALESCE(SUM(SH6a.H6_QTDPROD), 0) qtdProd, "
		cQuery +=        " COALESCE(SUM(SH6a.H6_QTDPERD), 0) qtdPerda, "
		cQuery +=        " SH6a.H6_TEMPO tempoApontado, "
		cQuery +=        " COALESCE(MAX(SH6a.H6_DATAFIN), ' ') dataFinaliza, "
		cQuery +=        " operacoes.saldoCRP, "
		cQuery +=        " operacoes.tempoPlanejado "
		cQuery +=   " FROM ("

		cQuery += " SELECT DISTINCT HWF.HWF_OP, "
		cQuery +=                 " HWF.HWF_OPER, "
		cQuery +=                 " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) descricao, "
		cQuery +=                 " HWF.HWF_RECURS, "
		cQuery +=                 " SH1.H1_DESCRI, "
		cQuery +=                 " HWF.HWF_CTRAB, "
		cQuery +=                 " SHB.HB_NOME, "
		cQuery +=                 " SC2.C2_QUANT, "
		cQuery +=                 " HWFmenor.HWF_DATA dataIni, "
		cQuery +=                 " HWFmenor.HWF_HRINI horaIni, "
		cQuery +=                 " HWFmaior.HWF_DATA dataFim, "
		cQuery +=                 " HWFmaior.HWF_HRFIM horaFim, "
		cQuery +=                 " COALESCE(SMF.MF_SALDO, -1) saldoCRP, "
		cQuery +=                 " COALESCE(SUM(HWF.HWF_TEMPOT), 0) tempoPlanejado "
		cQuery +=   " FROM " + RetSqlName("HWF") + " HWF "
		cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery +=     " ON SC2.C2_FILIAL  = ? "
		cQuery +=    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
		cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SHY") + " SHY "
		cQuery +=     " ON SHY.HY_FILIAL  = ? "
		cQuery +=    " AND SHY.HY_OP      = HWF.HWF_OP "
		cQuery +=    " AND SHY.HY_ROTEIRO = HWF.HWF_ROTEIR "
		cQuery +=    " AND SHY.HY_OPERAC  = HWF.HWF_OPER "
		cQuery +=    " AND SHY.HY_TEMPAD  <> 0 "
		cQuery +=    " AND SHY.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
		cQuery +=     " ON SG2.G2_FILIAL  = ? "
		cQuery +=    " AND SG2.G2_CODIGO  = HWF.HWF_ROTEIR "
		cQuery +=    " AND SG2.G2_OPERAC  = HWF.HWF_OPER "
		cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
		cQuery +=    " AND SHY.HY_OP IS NULL "
		cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
		cQuery +=     " ON SH1.H1_FILIAL  = ? "
		cQuery +=    " AND SH1.H1_CODIGO  = HWF.HWF_RECURS "
		cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SHB") + " SHB "
		cQuery +=     " ON SHB.HB_FILIAL  = ? "
		cQuery +=    " AND SHB.HB_COD     = HWF.HWF_CTRAB "
		cQuery +=    " AND SHB.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SMF") + " SMF "
		cQuery +=     " ON SMF.MF_FILIAL  = ? "
		cQuery +=    " AND SMF.MF_PROG    = HWF.HWF_PROG "
		cQuery +=    " AND SMF.MF_OP      = ? "
		cQuery +=    " AND SMF.MF_OPER    = HWF.HWF_OPER "
		cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("HWF") + " HWFmenor "
		cQuery +=     " ON HWFmenor.HWF_FILIAL = HWF.HWF_FILIAL "
		cQuery +=    " AND HWFmenor.HWF_OP     = HWF.HWF_OP "
		cQuery +=    " AND HWFmenor.HWF_OPER   = HWF.HWF_OPER "
		cQuery +=    " AND HWFmenor.HWF_SEQ    = (SELECT MIN(HWFmenorAux.HWF_SEQ) "
		cQuery +=                                 " FROM " + RetSqlName("HWF") + " HWFmenorAux "
		cQuery +=                                " WHERE HWFmenorAux.HWF_FILIAL = HWFmenor.HWF_FILIAL "
		cQuery +=                                  " AND HWFmenorAux.HWF_OP     = HWFmenor.HWF_OP "
		cQuery +=                                  " AND HWFmenorAux.HWF_OPER   = HWFmenor.HWF_OPER "
		cQuery +=                                  " AND HWFmenorAux.D_E_L_E_T_ = ' ') "
		cQuery +=    " AND HWFmenor.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("HWF") + " HWFmaior "
		cQuery +=     " ON HWFmaior.HWF_FILIAL = HWF.HWF_FILIAL "
		cQuery +=    " AND HWFmaior.HWF_OP     = HWF.HWF_OP "
		cQuery +=    " AND HWFmaior.HWF_OPER   = HWF.HWF_OPER "
		cQuery +=    " AND HWFmaior.HWF_SEQ    = (SELECT MAX(HWFmaiorAux.HWF_SEQ) "
		cQuery +=                                 " FROM " + RetSqlName("HWF") + " HWFmaiorAux "
		cQuery +=                                " WHERE HWFmaiorAux.HWF_FILIAL = HWFmaior.HWF_FILIAL "
		cQuery +=                                  " AND HWFmaiorAux.HWF_OP     = HWFmaior.HWF_OP "
		cQuery +=                                  " AND HWFmaiorAux.HWF_OPER   = HWFmaior.HWF_OPER "
		cQuery +=                                  " AND HWFmaiorAux.D_E_L_E_T_ = ' ') "
		cQuery +=    " AND HWFmaior.D_E_L_E_T_  = ' ' "
		cQuery +=  " WHERE HWF.HWF_FILIAL = ? "
		cQuery +=    " AND HWF.HWF_OP     = ? "
		cQuery +=    " AND NOT EXISTS (SELECT 1 "
		cQuery +=                      " FROM " + RetSqlName("SH6") + " SH6b "
		cQuery +=                     " WHERE SH6b.H6_FILIAL  = ? "
		cQuery +=                       " AND SH6b.H6_OP      = HWF.HWF_OP "
		cQuery +=                       " AND SH6b.H6_OPERAC  = HWF.HWF_OPER "
		cQuery +=                       " AND SH6b.H6_PT      = 'T' "
		cQuery +=                       " AND SH6b.D_E_L_E_T_ = ' ') "
		cQuery +=    " AND HWF.D_E_L_E_T_ = ' ' "
		cQuery +=  " GROUP BY HWF.HWF_OP, "
		cQuery +=           " HWF.HWF_OPER, "
		cQuery +=           " SHY.HY_DESCRI, "
		cQuery +=           " SG2.G2_DESCRI, "
		cQuery +=           " HWF.HWF_RECURS, "
		cQuery +=           " SH1.H1_DESCRI, "
		cQuery +=           " HWF.HWF_CTRAB, "
		cQuery +=           " SHB.HB_NOME, "
		cQuery +=           " SC2.C2_QUANT, "
		cQuery +=           " HWFmenor.HWF_DATA, "
		cQuery +=           " HWFmenor.HWF_HRINI, "
		cQuery +=           " HWFmaior.HWF_DATA, "
		cQuery +=           " HWFmaior.HWF_HRFIM, "
		cQuery +=           " SMF.MF_SALDO "
		cQuery += ") operacoes "
		cQuery +=   " LEFT JOIN " + RetSqlName("SH6") + " SH6a "
		cQuery +=     " ON SH6a.H6_FILIAL  = ? "
		cQuery +=    " AND SH6a.H6_OP      = operacoes.HWF_OP "
		cQuery +=    " AND SH6a.H6_OPERAC  = operacoes.HWF_OPER "
		cQuery +=    " AND SH6a.D_E_L_E_T_ = ' ' "
		cQuery +=  " GROUP BY operacoes.HWF_OPER, "
		cQuery +=           " operacoes.descricao, "
		cQuery +=           " operacoes.HWF_RECURS, "
		cQuery +=           " operacoes.H1_DESCRI, "
		cQuery +=           " operacoes.HWF_CTRAB, "
		cQuery +=           " operacoes.HB_NOME, "
		cQuery +=           " operacoes.C2_QUANT, "
		cQuery +=           " operacoes.dataIni, "
		cQuery +=           " operacoes.horaIni, "
		cQuery +=           " operacoes.dataFim, "
		cQuery +=           " operacoes.horaFim, "
		cQuery +=           " operacoes.saldoCRP, "
		cQuery +=           " operacoes.tempoPlanejado, "
		cQuery +=           " H6_TEMPO, "
    	cQuery +=           " H6_DATAFIN "
		cQuery +=  " ORDER BY operacoes.HWF_OPER "

		_oQryOper:SetQuery(cQuery)
	EndIf

	_oQryOper:SetString(1, xFilial("SC2"))
	_oQryOper:SetString(2, xFilial("SHY"))
	_oQryOper:SetString(3, xFilial("SG2"))
	_oQryOper:SetString(4, xFilial("SH1"))
	_oQryOper:SetString(5, xFilial("SHB"))
	_oQryOper:SetString(6, xFilial("SMF"))
	_oQryOper:SetString(7, cOrdemProd)
	_oQryOper:SetString(8, xFilial("HWF"))
	_oQryOper:SetString(9, cOrdemProd)
	_oQryOper:SetString(10, xFilial("SH6"))
	_oQryOper:SetString(11, xFilial("SH6"))

	cAlias := _oQryOper:OpenAlias()

	oJson["items"] := {}

	While (cAlias)->(!Eof())
		nCont++
		aAdd(oJson["items"], JsonObject():New())

		nSaldo := (cAlias)->C2_QUANT - (cAlias)->qtdProd
		If !lPerdInf
			nSaldo -= (cAlias)->qtdPerda
		EndIf

		oJson["items"][nCont]["operacao"      ] := RTrim((cAlias)->HWF_OPER)
		If !Empty((cAlias)->descricao)
			oJson["items"][nCont]["operacao"  ] += " - " + RTrim((cAlias)->descricao)
		EndIf
		oJson["items"][nCont]["recurso"       ] := RTrim((cAlias)->HWF_RECURS) + " - " + RTrim((cAlias)->H1_DESCRI)
		oJson["items"][nCont]["centTrabalho"  ] := RTrim((cAlias)->HWF_CTRAB) + " - " + RTrim((cAlias)->HB_NOME)
		If Empty((cAlias)->HWF_CTRAB)
			oJson["items"][nCont]["centTrabalho"  ] := STR0140 // "Centro de trabalho em branco"
		EndIf
		oJson["items"][nCont]["dataIni"       ] := PCPConvDat((cAlias)->dataIni, 4) + " - " + (cAlias)->horaIni
		oJson["items"][nCont]["dataFim"       ] := PCPConvDat((cAlias)->dataFim, 4) + " - " + (cAlias)->horaFim
		If (cAlias)->saldoCRP == -1
			oJson["items"][nCont]["saldoCRP"] := "-"
		Else
			oJson["items"][nCont]["saldoCRP"] := (cAlias)->saldoCRP
		EndIf
		oJson["items"][nCont]["saldoOper"     ] := Max(nSaldo, 0)
		oJson["items"][nCont]["tempoPlanejado"] := __Min2Hrs((cAlias)->tempoPlanejado, .T.)
		oJson["items"][nCont]["tempoApontado" ] := __Min2Hrs(somaTempo((cAlias)->tempoApontado), .T.)
		oJson["items"][nCont]["dataFinaliza"  ] := PCPConvDat((cAlias)->dataFinaliza, 4)

		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

	aAdd(aResult, .T.)
	aAdd(aResult, 200)
	aAdd(aResult, oJson:toJson())

	FwFreeObj(oJson)
	_cTempoPla := Nil

Return aResult

/*/{Protheus.doc} somaTempo
Soma as horas da H6_TEMPO
@type  Static Function
@author Breno Soares
@since 11/12/2024
@version P12
@param 01 cTempo, Character, Tempo a ser somado.
@return _cTempoPla, Character, Retorna o somatorio das horas da H6_TEMPO.
/*/
Static Function somaTempo(cTempo)

	If _cTempoPla == Nil
		_cTempoPla := __Hrs2Min(cTempo)
	Else
		_cTempoPla += __Hrs2Min(cTempo)
	EndIf

Return _cTempoPla

/*/{Protheus.doc} setaAtributos
Seta os atributos da classe para controle de processamento
@author Marcelo Neumann
@since 24/11/2023
@version P12
@param 01 cProg  , Caracter, Código da programação.
@param 02 aParams, Array   , Array com os parâmetros da programação.
@return Nil
/*/
Method setaAtributos(cProg, aParams) Class PCPA152Efetivacao

	Self:cProg      := cProg
	Self:cEtapaIni  := CHAR_ETAPAS_EFETIVACAO
	Self:lReproc    := .F.
	Self:lContinua  := .T.
	Self:lGravaPCP  := .F.

	If Self:iniciaUIdGlobal(.T.)
		_Super:carregaParametros(aParams)
		_Super:atualizaParametros(aParams)
		_Super:gravaAtributosGlobais()

		Self:lGravaPCP := _Super:retornaParametro("MV_GRAVPCP")
		_Super:gravaValorGlobal("GRAVA_PCP", Self:lGravaPCP)
	EndIf


Return Nil

/*/{Protheus.doc} ajustaCompras
Ajusta as datas das solicitações de compra, autorização de entrega e cotações.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@return lSucesso, Lógico, Retorna se teve sucesso na atualização das datas das compras.
/*/
Method ajustaCompras() Class PCPA152Efetivacao
	Local cAlias  := GetNextAlias()
	Local cErro   := ""
	Local cQuery  := ""
	Local nIniMtd := MicroSeconds()
	Local nIniQry := 0
	Local lSucesso := .T.

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Inicio ajuste de compras"})

	cQuery := " SELECT SC1.R_E_C_N_O_ recno, "
	cQuery +=        " 'SC1'          origem, "
	cQuery +=        " SC2.C2_DATAJI  dataOP, "
	cQuery +=        " SC1.C1_PRODUTO produto, "
	cQuery +=        " SC1.C1_NUM     num, "
	cQuery +=        " SC1.C1_ITEM    item, "
	cQuery +=        " ''             sequen, "
	cQuery +=        " SC1.C1_ITEMGRD itemGrd, "
	cQuery +=        " TEMP.MF_OP     ordemProducao, "
	cQuery +=        " SC1.C1_DINICOM dataInicio, "
	cQuery +=        " SC1.C1_DATPRF  dataFim, "
	cQuery +=        " SC1.C1_QUANT   quantidade, "
	cQuery +=        " ''             fornecedor, "
	cQuery +=        " ''             loja, "
	cQuery +=        " ''             numSC, "
	cQuery +=        " ''             itemSC, "
	cQuery +=        " TEMP.MF_ID     idOP "
	cQuery +=   " FROM " + RetSqlName("SC1") + " SC1 "
	cQuery +=  " INNER JOIN " + Self:oTempOrdens:GetTableNameForQuery() + " TEMP "
	cQuery +=     " ON SC1.C1_OP = TEMP.MF_OP "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND SC2.C2_NUM     = TEMP.MF_NUM "
	cQuery +=    " AND SC2.C2_ITEM    = TEMP.MF_ITEM "
	cQuery +=    " AND SC2.C2_SEQUEN  = TEMP.MF_SEQUEN "
	cQuery +=    " AND SC2.C2_ITEMGRD = TEMP.MF_ITEMGRD "
	cQuery +=    " AND SC2.C2_DATAJI <> SC1.C1_DATPRF "
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SC1.C1_FILIAL  = '" + xFilial("SC1") + "' "
	cQuery +=    " AND SC1.D_E_L_E_T_ = ' ' "
	cQuery +=  " UNION "
	cQuery += " SELECT SC7.R_E_C_N_O_ recno, "
	cQuery +=        " 'SC7'          origem, "
	cQuery +=        " SC2.C2_DATAJI  dataOP, "
	cQuery +=        " SC7.C7_PRODUTO produto, "
	cQuery +=        " SC7.C7_NUM     num, "
	cQuery +=        " SC7.C7_ITEM    item, "
	cQuery +=        " SC7.C7_SEQUEN  sequen, "
	cQuery +=        " SC7.C7_ITEMGRD itemGrd, "
	cQuery +=        " TEMP.MF_OP     ordemProducao, "
	cQuery +=        " SC7.C7_DINICOM dataInicio, "
	cQuery +=        " SC7.C7_DATPRF  dataFim, "
	cQuery +=        " SC7.C7_QUANT   quantidade, "
	cQuery +=        " SC7.C7_FORNECE fornecedor, "
	cQuery +=        " SC7.C7_LOJA    loja, "
	cQuery +=        " SC7.C7_NUMSC   numSC, "
	cQuery +=        " SC7.C7_ITEMSC  itemSC, "
	cQuery +=        " TEMP.MF_ID     idOP "
	cQuery +=   " FROM " + RetSqlName("SC7") + " SC7 "
	cQuery +=  " INNER JOIN " + Self:oTempOrdens:GetTableNameForQuery() + " TEMP "
	cQuery +=     " ON SC7.C7_OP = TEMP.MF_OP "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND SC2.C2_NUM     = TEMP.MF_NUM "
	cQuery +=    " AND SC2.C2_ITEM    = TEMP.MF_ITEM "
	cQuery +=    " AND SC2.C2_SEQUEN  = TEMP.MF_SEQUEN "
	cQuery +=    " AND SC2.C2_ITEMGRD = TEMP.MF_ITEMGRD "
	cQuery +=    " AND SC2.C2_DATAJI <> SC7.C7_DATPRF "
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SC7.C7_FILIAL  = '" + xFilial("SC7") + "' "
	cQuery +=    " AND SC7.C7_TIPO    = " + cValToChar(TIPO_AUTORIZACAO_ENTREGA)
	cQuery +=    " AND SC7.D_E_L_E_T_ = ' ' "
	cQuery +=  " UNION "
	cQuery += " SELECT SC8.R_E_C_N_O_ recno, "
	cQuery +=        " 'SC8'          origem, "
	cQuery +=        " SC2.C2_DATAJI  dataOP, "
	cQuery +=        " SC8.C8_PRODUTO produto, "
	cQuery +=        " SC8.C8_NUM     num, "
	cQuery +=        " ''             item, "
	cQuery +=        " ''             sequen, "
	cQuery +=        " ''             itemGrd, "
	cQuery +=        " TEMP.MF_OP     ordemProducao, "
	cQuery +=        " ''             dataInicio, "
	cQuery +=        " SC8.C8_DATPRF  dataFim, "
	cQuery +=        " SC8.C8_QUANT   quantidade, "
	cQuery +=        " ''             fornecedor, "
	cQuery +=        " ''             loja, "
	cQuery +=        " ''             numSC, "
	cQuery +=        " ''             itemSC, "
	cQuery +=        " TEMP.MF_ID     idOP "
	cQuery +=   " FROM " + RetSqlName("SC8") + " SC8 "
	cQuery +=  " INNER JOIN " + RetSqlName("SC1") + " SC1 "
	cQuery +=     " ON SC1.C1_FILIAL  = '" + xFilial("SC1") + "' "
	cQuery +=    " AND SC8.C8_NUM     = SC1.C1_COTACAO "
	cQuery +=    " AND SC1.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + Self:oTempOrdens:GetTableNameForQuery() + " TEMP "
	cQuery +=     " ON SC1.C1_OP = TEMP.MF_OP "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND SC2.C2_NUM     = TEMP.MF_NUM "
	cQuery +=    " AND SC2.C2_ITEM    = TEMP.MF_ITEM "
	cQuery +=    " AND SC2.C2_SEQUEN  = TEMP.MF_SEQUEN "
	cQuery +=    " AND SC2.C2_ITEMGRD = TEMP.MF_ITEMGRD "
	cQuery +=    " AND SC2.C2_DATAJI <> SC1.C1_DATPRF "
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SC8.C8_FILIAL  = '" + xFilial("SC8") + "' "
	cQuery +=    " AND SC8.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY origem "

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query metodo ajustaCompras: " + cQuery})
	nIniQry := MicroSeconds()

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	TcSetField(cAlias, 'dataOP'    , 'D', GetSx3Cache("C2_DATAJI" , "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'dataInicio', 'D', GetSx3Cache("C1_DINICOM", "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'dataFim'   , 'D', GetSx3Cache("C1_DATPRF" , "X3_TAMANHO"), 0)

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query ajustaCompras: " + cValToChar(MicroSeconds() - nIniQry)})

	If (cAlias)->(!EoF())
		Self:criaTempCompras()

		Self:atualizaProcessamento(STR0654, 96) // "Calculando data dos documentos de compra"
		If !Self:carregaTempCompras(cAlias)
			lSucesso := .F.
			cErro    := STR0655 // "Ocorreu um erro ao carregar a tabela temporaria de compras"
		EndIf

		Self:atualizaProcessamento(STR0656, 97) // "Atualizando solicitações de compra"
		If lSucesso .And. !Self:updateSC1()
			lSucesso := .F.
			cErro    := i18n(STR0528, {"SC1"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
		EndIf

		Self:atualizaProcessamento(STR0657, 98) //  "Atualizando autorizações de entrega"
		If lSucesso .And. !Self:updateSC7()
			lSucesso := .F.
			cErro    := i18n(STR0528, {"SC7"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
		EndIf

		Self:atualizaProcessamento(STR0658, 99) // "Atualizando cotações"
		If lSucesso .And. !Self:updateSC8()
			lSucesso := .F.
			cErro    := i18n(STR0528, {"SC8"}) // "Ocorreu um erro ao atualizar a tabela #1[tabela]#."
		EndIf

		If lSucesso
			Self:oOcorrens:localToGlobal()

			lSucesso := Self:oOcorrens:gravaOcorrencias()
		EndIf
	EndIf
	(cAlias)->(dbCloseArea())

	If !lSucesso
		Self:cErroMsg := cErro
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Fim ajuste de compras. Tempo de atualizacao dos registros: " + cValToChar(MicroSeconds() - nIniMtd)})

Return lSucesso

/*/{Protheus.doc} criaTempCompras
Cria tabela temporaria para armazenar a data das compras antes do update.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@return Nil
/*/
Method criaTempCompras() Class PCPA152Efetivacao
	Local aFields := Self:getFieldsTempCompras()

	Self:oTempCompras := FwTemporaryTable():New(GetNextAlias(), aFields)

	Self:oTempCompras:AddIndex("01", {"TABELA", "RECNO"})

	Self:oTempCompras:Create()

Return Nil

/*/{Protheus.doc} getFieldsTempCompras
Retorna os campos da tabela temporaria de compras.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@return aFields, Array, Array com os campos da tabela temporaria de compras.
/*/
Method getFieldsTempCompras() Class PCPA152Efetivacao
	Local aFields := {}

	aAdd(aFields, {"RECNO"  , "N", 11, 0})
	aAdd(aFields, {"DATAINI", "D",  8, 0})
	aAdd(aFields, {"DATAFIM", "D",  8, 0})
	aAdd(aFields, {"DATATRF", "D",  8, 0})
	aAdd(aFields, {"DATACQ" , "D",  8, 0})
	aAdd(aFields, {"TABELA" , "C",  3, 0})

Return aFields

/*/{Protheus.doc} carregaTempCompras
Carrega a tabela temporaria com as novas datas das compras.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@param cAlias, Caracter, Alias com as compras que serão atualizadas.
@return lSucesso, Lógico, Retorna se teve sucesso na inserção dos registros.
/*/
Method carregaTempCompras(cAlias) Class PCPA152Efetivacao
	Local cProduto := ""
	Local cTabDoc  := ""
	Local cNumDoc  := ""
	Local dDataFim := Nil
	Local dDataIni := Nil
	Local lSucesso := .T.
	Local nRecno   := 0
	Local oBulk    := Nil
	Local nIniMtd  := MicroSeconds()
	Local dDataTrf := Nil
	Local dDataCQ  := Nil

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Inicio carregamento da tabela temporaria de compras"})

	oBulk := FwBulk():New(Self:oTempCompras:getTableNameForTCFunctions())
	oBulk:setFields(Self:getFieldsTempCompras())

	While (cAlias)->(!EoF()) .And. lSucesso
		cTabDoc    := (cAlias)->origem
		nRecno     := (cAlias)->recno
		dDataFim   := (cAlias)->dataOP
		cProduto   := (cAlias)->produto

		dDataIni := Self:getDataInicioCompra(cTabDoc, dDataFim, cProduto, cAlias, @dDataTrf, @dDataCQ)

		lSucesso := oBulk:addData({nRecno, dDataIni, dDataFim, dDataTrf, dDataCQ, cTabDoc})

		Self:geraOcorrenciaDataCompra(cAlias, dDataIni, dDataFim)

		If cTabDoc == "SC1"
			cNumDoc := (cAlias)->num + (cAlias)->item
			Self:oDatasSC[cNumDoc] := dDataIni
		EndIf

		(cAlias)->(dbSkip())
	End

	Self:cErroDet := oBulk:getError()
	If lSucesso
		lSucesso      := oBulk:close()
		Self:cErroDet := oBulk:getError()
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Fim do carregamento da tabela temporaria de compras. Tempo total: " + cValToChar(MicroSeconds() - nIniMtd)})

	oBulk:destroy()
	FreeObj(oBulk)
Return lSucesso

/*/{Protheus.doc} getDataInicioCompra
Calcula a nova data de inicio do documento de compra.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@param 01 cTabDoc , Caracter, Tabela que o documento de compra esta gravado (SC1/SC7).
@param 02 dDataFim, Date    , Nova data de entrega do documento.
@param 03 cProduto, Caracter, Produto cadastrado no documento.
@param 04 cAlias  , Caracter, Alias com as informações para calculo das datas da autorização de entrega.
@param 05 dNovaTrf, Date    , Nova data para o campo C7_DINITRF da autorização de entrega.
@param 06 dNovaCQ , Date    , Nova data para o campo C7_DINICQ  da autorização de entrega.
@return dDataIni, Date, Nova data de inicio da compra
/*/
Method getDataInicioCompra(cTabDoc, dDataFim, cProduto, cAlias, dNovaTrf, dNovaCQ) Class PCPA152Efetivacao
	Local dDataIni := dDataFim

	// Posiciona o produto para uso na função de compras
	SB1->(dbSeek(xFilial("SB1")+cProduto))

	If cTabDoc == "SC1"
		dDataIni := getIniTime(dDataFim)

	ElseIf cTabDoc == "SC7"
		dDataIni := Self:getDatasAutorizacaoEntrega(dDataFim, cAlias, @dNovaTrf, @dNovaCQ)

	EndIf

Return dDataIni

/*/{Protheus.doc} getDatasAutorizacaoEntrega
Calcula as novas datas da autorização de entrega.
(Baseado na função A120lTime() do mata120)

@author Lucas Fagundes
@since 17/12/2024
@version P12
@param 01 dDataFim, Date    , Nova data de entrega da autorização de entrega.
@param 02 cAlias  , Caracter, Alias com as informações da autorização de entrega.
@param 04 dNovaTrf, Date    , Retorna por referência a nova data para o campo C7_DINITRF.
@param 05 dNovaCQ , Date    , Retorna por referência a nova data para o campo C7_DINICQ.
@return dIniAutEnt, Date, Nova data de inicio da autorização de entrega.
/*/
Method getDatasAutorizacaoEntrega(dDataFim, cAlias, dNovaTrf, dNovaCQ) Class PCPA152Efetivacao
	Local cFornecedor := (cAlias)->fornecedor
	Local cFPrzCq     := ""
	Local cLoja       := (cAlias)->loja
	Local cNumSC      := ""
	Local cProduto    := (cAlias)->produto
	Local dIniAutEnt  := Nil
	Local dIniSC      := Nil
	Local nPrazCQ     := 0
	Local nPrazoCQ    := 0
	Local nQuantidade := (cAlias)->quantidade
	Local nTempTra    := 0

	cNumSC   := (cAlias)->numSC + (cAlias)->itemSC
	nTempTra := Posicione("SA5", 2, xFilial("SA5") + cProduto, "A5_TEMPTRA")
	cFPrzCq  := Posicione("SB5", 1, xFilial("SB5") + cProduto, "B5_FPRZCQ")
	nPrazCQ  := Posicione("SB5", 1, xFilial("SB5") + cProduto, "B5_PRZCQ")
	nPrazoCQ := Iif(Empty(cFPrzCq), nPrazCQ, Formula(cFPrzCq))

	dNovaCQ	   := dDataFim - nPrazoCQ
	dNovaTrf   := dNovaCQ  - nTempTra
	dIniAutEnt := dNovaTrf - CalcPrazo(cProduto, nQuantidade, cFornecedor, cLoja)

	If !Empty(cNumSC)
		dIniSC := Iif(Self:oDatasSC:hasProperty(cNumSC), Self:oDatasSC[cNumSC], GetAdvFval("SC1", "C1_DINICOM", xFilial("SC1") + cNumSC, 1))

		If !Empty(dIniSC)
			dIniAutEnt := dIniSC
		EndIf
	EndIf

Return dIniAutEnt

/*/{Protheus.doc} geraOcorrenciaDataCompra
Gera ocorrência de data alterada para o documento de compra.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@param 01 cAlias  , Caracter, Alias com a compra que irá gerar ocorrência.
@param 02 dNovoIni, Date    , Nova data de inicio do documento de compra.
@param 03 dNovoFim, Date    , Nova data de entrega do documento de compra.
@return Nil
/*/
Method geraOcorrenciaDataCompra(cAlias, dNovoIni, dNovoFim) Class PCPA152Efetivacao
	Local cChaveOco  := ""
	Local cDocumento := (cAlias)->num + (cAlias)->item + (cAlias)->sequen + (cAlias)->itemGrd
	Local cIdReg     := (cAlias)->idOP
	Local cOrdem     := (cAlias)->ordemProducao
	Local cTabDoc    := (cAlias)->origem
	Local dFimAtual  := (cAlias)->dataFim
	Local dIniAtual  := (cAlias)->dataInicio

	cChaveOco := cDocumento + cTabDoc

	If cTabDoc == "SC8"
		If Self:oLogCotacao:hasProperty(cDocumento)
			Return Nil
		EndIf

		Self:oLogCotacao[cDocumento] := .T.
	EndIf

	If dNovoIni != dIniAtual .Or. dNovoFim != dFimAtual
		Self:oOcorrens:adicionaOcorrencia(LOG_COMPRA_ALTERADA, cChaveOco, cIdReg, cOrdem, "", "", "", "", {cDocumento, cTabDoc, dIniAtual, dFimAtual, dNovoIni, dNovoFim})

		If dNovoIni < Self:dDataAtual
			Self:oOcorrens:adicionaOcorrencia(LOG_COMPRA_ANTERIOR_DATA_BASE, cChaveOco, cIdReg, cOrdem, "", "", "", "", {cDocumento, cTabDoc})
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} updateSC1
Atualiza a tabela SC1 com as novas datas na tabela temporaria de compras.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@return lSucesso, Lógico, Indica que atualizou com sucesso a tabela
/*/
Method updateSC1() Class PCPA152Efetivacao
	Local cUpdate  := ""
	Local lSucesso := .T.
	Local nIniQry  := 0

	If Self:cBanco == "ORACLE"
		cUpdate := " UPDATE " + RetSqlName("SC1") + " SC1 "
		cUpdate +=    " SET (SC1.C1_DINICOM, "
		cUpdate +=         " SC1.C1_DATPRF) = (SELECT TEMPAUX.DATAINI, "
		cUpdate +=                                  " TEMPAUX.DATAFIM "
		cUpdate +=                             " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=                            " WHERE TEMPAUX.RECNO  = SC1.R_E_C_N_O_ "
		cUpdate +=                              " AND TEMPAUX.TABELA = 'SC1') "
		cUpdate +=  " WHERE EXISTS (SELECT 1 "
		cUpdate +=                  " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=                 " WHERE TEMPAUX.RECNO  = SC1.R_E_C_N_O_ "
		cUpdate +=                   " AND TEMPAUX.TABELA = 'SC1')"
	Else
		cUpdate := " UPDATE " + RetSqlName("SC1")
		cUpdate +=    " SET C1_DINICOM = TEMP.DATAINI, "
		cUpdate +=        " C1_DATPRF  = TEMP.DATAFIM "
		cUpdate +=   " FROM (SELECT TEMPAUX.DATAINI, "
		cUpdate +=                " TEMPAUX.DATAFIM, "
		cUpdate +=                " TEMPAUX.RECNO "
		cUpdate +=           " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=          " WHERE TEMPAUX.TABELA = 'SC1') TEMP "
		cUpdate +=  " WHERE " + RetSqlName("SC1") + ".R_E_C_N_O_ = TEMP.RECNO "
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query update do metodo atualizaSC1: " + cUpdate})
	nIniQry := MicroSeconds()

	If TcSqlExec(cUpdate) < 0
		lSucesso      := .F.
		Self:cErroDet := AllTrim(TcSqlError())
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query update do metodo atualizaSC1: " + cValToChar(MicroSeconds() - nIniQry)})

Return lSucesso

/*/{Protheus.doc} updateSC7
Atualiza a tabela SC7 com as novas datas na tabela temporaria de compras.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@return lSucesso, Lógico, Indica que atualizou com sucesso a tabela
/*/
Method updateSC7() Class PCPA152Efetivacao
	Local cUpdate  := ""
	Local lSucesso := .T.
	Local nIniQry  := 0

	If Self:cBanco == "ORACLE"
		cUpdate := " UPDATE " + RetSqlName("SC7") + " SC7 "
		cUpdate +=    " SET (SC7.C7_DINICOM, "
		cUpdate +=         " SC7.C7_DATPRF, "
		cUpdate +=         " SC7.C7_DINITRA, "
		cUpdate +=         " SC7.C7_DINICQ) = (SELECT TEMPAUX.DATAINI, "
		cUpdate +=                                  " TEMPAUX.DATAFIM, "
		cUpdate +=                                  " TEMPAUX.DATATRF, "
		cUpdate +=                                  " TEMPAUX.DATACQ "
		cUpdate +=                             " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=                            " WHERE TEMPAUX.RECNO  = SC7.R_E_C_N_O_ "
		cUpdate +=                              " AND TEMPAUX.TABELA = 'SC7') "
		cUpdate +=  " WHERE EXISTS (SELECT 1 "
		cUpdate +=                  " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=                 " WHERE TEMPAUX.RECNO  = SC7.R_E_C_N_O_ "
		cUpdate +=                   " AND TEMPAUX.TABELA = 'SC7')"
	Else
		cUpdate := " UPDATE " + RetSqlName("SC7")
		cUpdate +=    " SET C7_DINICOM = TEMP.DATAINI, "
		cUpdate +=        " C7_DATPRF  = TEMP.DATAFIM, "
		cUpdate +=        " C7_DINITRA = TEMP.DATATRF, "
		cUpdate +=        " C7_DINICQ  = TEMP.DATACQ "
		cUpdate +=   " FROM (SELECT TEMPAUX.DATAINI, "
		cUpdate +=                " TEMPAUX.DATAFIM, "
		cUpdate +=                " TEMPAUX.DATATRF, "
		cUpdate +=                " TEMPAUX.DATACQ, "
		cUpdate +=                " TEMPAUX.RECNO "
		cUpdate +=           " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=          " WHERE TEMPAUX.TABELA = 'SC7') TEMP "
		cUpdate +=  " WHERE " + RetSqlName("SC7") + ".R_E_C_N_O_ = TEMP.RECNO "
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query update do metodo atualizaSC7: " + cUpdate})
	nIniQry := MicroSeconds()

	If TcSqlExec(cUpdate) < 0
		lSucesso      := .F.
		Self:cErroDet := AllTrim(TcSqlError())
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query update do metodo atualizaSC7: " + cValToChar(MicroSeconds() - nIniQry)})

Return lSucesso

/*/{Protheus.doc} updateSC8
Atualiza a tabela SC8 com as novas datas na tabela temporaria de compras.

@author Lucas Fagundes
@since 13/12/2024
@version P12
@return lSucesso, Lógico, Indica que atualizou com sucesso a tabela
/*/
Method updateSC8() Class PCPA152Efetivacao
	Local cUpdate  := ""
	Local lSucesso := .T.
	Local nIniQry  := 0

	If Self:cBanco == "ORACLE"
		cUpdate := " UPDATE " + RetSqlName("SC8") + " SC8 "
		cUpdate +=    " SET (SC8.C8_DATPRF) = (SELECT TEMPAUX.DATAFIM "
		cUpdate +=                             " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=                            " WHERE TEMPAUX.RECNO  = SC8.R_E_C_N_O_ "
		cUpdate +=                              " AND TEMPAUX.TABELA = 'SC8') "
		cUpdate +=  " WHERE EXISTS (SELECT 1 "
		cUpdate +=                  " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=                 " WHERE TEMPAUX.RECNO  = SC8.R_E_C_N_O_ "
		cUpdate +=                   " AND TEMPAUX.TABELA = 'SC8')"
	Else
		cUpdate := " UPDATE " + RetSqlName("SC8")
		cUpdate +=    " SET C8_DATPRF = TEMP.DATAFIM "
		cUpdate +=   " FROM (SELECT TEMPAUX.DATAFIM, "
		cUpdate +=                " TEMPAUX.RECNO "
		cUpdate +=           " FROM " + Self:oTempCompras:getTableNameForQuery() + " TEMPAUX "
		cUpdate +=          " WHERE TEMPAUX.TABELA = 'SC8') TEMP "
		cUpdate +=  " WHERE " + RetSqlName("SC8") + ".R_E_C_N_O_ = TEMP.RECNO "
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query update do metodo atualizaSC8: " + cUpdate})
	nIniQry := MicroSeconds()

	If TcSqlExec(cUpdate) < 0
		lSucesso      := .F.
		Self:cErroDet := AllTrim(TcSqlError())
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query update do metodo atualizaSC8: " + cValToChar(MicroSeconds() - nIniQry)})

Return lSucesso

/*/{Protheus.doc} ajustProgs
Atualiza as programações que consideraram a OP que está sendo desefetivada

@author Marcelo Neumann
@since 11/03/2025
@version P12
@param cOrdens  , Caracter, OPs que estão sendo desefetivadas
@return lSucesso, Lógico  , Indica que ajustou com sucesso as programações
/*/
Static Function ajustProgs(cOrdens)
	Local aProgrs  := {}
	Local aReturn  := {}
	Local cAlias   := GetNextAlias()
	Local cQuery   := ""
	Local cProgAnt := Nil
	Local cRecAnt  := Nil
	Local dDataAnt := Nil
	Local lSucesso := .T.
	Local nIndData := 0
	Local nIndHora := 0
	Local nIndProg := 0
	Local nIndRec  := 0
	Local nTotProg := 0
	Local nTotRec  := 0
	Local nTotData := 0

	//Busca o horário da OP que está sendo desefetivada
	cQuery := "SELECT DISTINCT SMK.MK_PROG, SMR.MR_TIPO, SMR.MR_RECURSO, SMK.MK_DATDISP, HWF.HWF_HRINI AS HRINI, HWF.HWF_HRFIM AS HRFIM, '' MR_SEQFER"
	cQuery +=  " FROM " + RetSqlName("SMK") + " SMK"
	cQuery += " INNER JOIN " + RetSqlName("T4X") + " T4X"
	cQuery +=    " ON T4X.T4X_FILIAL  = '" + xFilial("T4X") + "'"
	cQuery +=   " AND T4X.T4X_PROG    = SMK.MK_PROG"
	cQuery +=   " AND T4X.T4X_STATUS IN ('" + STATUS_DISTRIBUIDA + "','" + STATUS_NIVELADO + "')"
	cQuery +=   " AND T4X.D_E_L_E_T_  = ' '"
	cQuery += " INNER JOIN " + RetSqlName("SMR") + " SMR"
	cQuery +=    " ON SMR.MR_FILIAL  = '" + xFilial("SMR") + "'"
	cQuery +=   " AND SMR.MR_PROG    = SMK.MK_PROG"
	cQuery +=   " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO + "'"
	cQuery +=   " AND SMR.MR_DATDISP = SMK.MK_DATDISP"
	cQuery +=   " AND SMR.MR_DISP    = SMK.MK_DISP"
	cQuery +=   " AND SMR.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("HWF") + " HWF"
	cQuery +=    " ON HWF.HWF_FILIAL = '" + xFilial("HWF") + "'"
	cQuery +=   " AND HWF.HWF_OP    IN (" + cOrdens + ")"
	cQuery +=   " AND HWF.HWF_RECURS = SMR.MR_RECURSO"
	cQuery +=   " AND HWF.HWF_DATA   = SMR.MR_DATDISP"
	cQuery +=   " AND HWF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SMK.MK_FILIAL  = '" + xFilial("SMK") + "'"
	cQuery +=   " AND SMK.MK_TIPO    = '" + HORA_EFETIVADA + "'"
	cQuery +=   " AND SMK.MK_DATDISP = HWF.HWF_DATA"
	cQuery +=   " AND ( HWF.HWF_HRINI BETWEEN SMK.MK_HRINI AND SMK.MK_HRFIM OR "
	cQuery +=         " HWF.HWF_HRFIM BETWEEN SMK.MK_HRINI AND SMK.MK_HRFIM )"
	cQuery +=   " AND SMK.D_E_L_E_T_ = ' '"

	If temDicFerr()
		cQuery +=  " UNION"
		cQuery += " SELECT DISTINCT SMK.MK_PROG, SMR.MR_TIPO, SMR.MR_RECURSO, SMK.MK_DATDISP, HZL.HZL_INICIO AS HRINI, HZL.HZL_FIM AS HRFIM, SMR.MR_SEQFER"
		cQuery +=   " FROM " + RetSqlName("SMK") + " SMK"
		cQuery += " INNER JOIN " + RetSqlName("T4X") + " T4X"
		cQuery +=    " ON T4X.T4X_FILIAL  = '" + xFilial("T4X") + "'"
		cQuery +=   " AND T4X.T4X_PROG    = SMK.MK_PROG"
		cQuery +=   " AND T4X.T4X_STATUS IN ('" + STATUS_DISTRIBUIDA + "','" + STATUS_NIVELADO + "')"
		cQuery +=   " AND T4X.D_E_L_E_T_  = ' '"
		cQuery +=  " INNER JOIN " + RetSqlName("SMR") + " SMR"
		cQuery +=     " ON SMR.MR_FILIAL  = '" + xFilial("SMR") + "'"
		cQuery +=    " AND SMR.MR_PROG    = SMK.MK_PROG"
		cQuery +=    " AND SMR.MR_TIPO    = '" + MR_TIPO_FERRAMENTA + "'"
		cQuery +=    " AND SMR.MR_DATDISP = SMK.MK_DATDISP"
		cQuery +=    " AND SMR.MR_DISP    = SMK.MK_DISP"
		cQuery +=    " AND SMR.D_E_L_E_T_ = ' '"
		cQuery +=  " INNER JOIN " + RetSqlName("HZL") + " HZL"
		cQuery +=     " ON HZL.HZL_FILIAL = '" + xFilial("HZL") + "'"
		cQuery +=    " AND HZL.HZL_OP    IN (" + cOrdens + ")"
		cQuery +=    " AND HZL.HZL_FERRAM = SMR.MR_RECURSO"
		cQuery +=    " AND HZL.HZL_SEQFER = SMR.MR_SEQFER"
		cQuery +=    " AND HZL.HZL_DATA   = SMR.MR_DATDISP"
		cQuery +=    " AND HZL.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE SMK.MK_FILIAL  = '" + xFilial("SMK") + "'"
		cQuery +=    " AND SMK.MK_TIPO    = '" + HORA_EFETIVADA + "'"
		cQuery +=    " AND SMK.MK_DATDISP = HZL.HZL_DATA"
		cQuery +=    " AND ( HZL.HZL_INICIO BETWEEN SMK.MK_HRINI AND SMK.MK_HRFIM OR"
		cQuery +=          " HZL.HZL_FIM BETWEEN SMK.MK_HRINI AND SMK.MK_HRFIM )"
		cQuery +=    " AND SMK.D_E_L_E_T_ = ' '"
	EndIf

	cQuery +=  " ORDER BY 1, 2, 3, 4"

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	TcSetField(cAlias, 'MK_DATDISP', 'D', GetSx3Cache("MK_DATDISP", "X3_TAMANHO"), 0)

	//Cria o array aProgrs com todas as programações que precisam ter a disponibilidade ajustada
	While (cAlias)->(!EoF())
		If cProgAnt <> (cAlias)->MK_PROG
			cProgAnt := (cAlias)->MK_PROG
			cRecAnt  := Nil
			nIndRec  := 0

			nIndProg++
			aAdd(aProgrs, JsonObject():New())
			aProgrs[nIndProg]["programacao"] := (cAlias)->MK_PROG
			aProgrs[nIndProg]["recursos"   ] := {}
		EndIf

		If cRecAnt <> (cAlias)->MR_TIPO + (cAlias)->MR_RECURSO
			cRecAnt  := (cAlias)->MR_TIPO + (cAlias)->MR_RECURSO
			dDataAnt := Nil
			nIndData := 0

			nIndRec++
			aAdd(aProgrs[nIndProg]["recursos"], JsonObject():New())
			aProgrs[nIndProg]["recursos"][nIndRec]["recurso"] := (cAlias)->MR_RECURSO
			aProgrs[nIndProg]["recursos"][nIndRec]["datas"  ] := {}
		EndIf

		If dDataAnt <> (cAlias)->MK_DATDISP
			dDataAnt := (cAlias)->MK_DATDISP
			nIndHora := 0

			nIndData++
			aAdd(aProgrs[nIndProg]["recursos"][nIndRec]["datas"], JsonObject():New())
 			aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["dataFinal"    ] := DToS((cAlias)->MK_DATDISP)
			aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["dataInicial"  ] := DToS((cAlias)->MK_DATDISP)
			aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["recursos"     ] := {(cAlias)->MR_RECURSO}
			aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["tipo"         ] := (cAlias)->MR_TIPO
			aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["seqFerramenta"] := (cAlias)->MR_SEQFER
			aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["criaDisp"     ] := ((cAlias)->MR_TIPO == MR_TIPO_RECURSO)
			aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["detalhes"     ] := {}
		EndIf

		nIndHora++
		aAdd(aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["detalhes"], JsonObject():New())

		aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["detalhes"][nIndHora]["horaInicial"] := (cAlias)->HRINI
		aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["detalhes"][nIndHora]["horaFinal"  ] := (cAlias)->HRFIM
		aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["detalhes"][nIndHora]["tipo"       ] := HORA_DISPONIVEL
		aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData]["detalhes"][nIndHora]["bloqueado"  ] := HORA_NAO_BLOQUEADA
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	nTotProg := nIndProg

	For nIndProg := 1 To nTotProg
		nTotRec := Len(aProgrs[nIndProg]["recursos"])

		For nIndRec := 1 To nTotRec
			nTotData := Len(aProgrs[nIndProg]["recursos"][nIndRec]["datas"])

			For nIndData := 1 To nTotData
				aReturn  := P152UpdMul(aProgrs[nIndProg]["programacao"], aProgrs[nIndProg]["recursos"][nIndRec]["datas"][nIndData])
				lSucesso := aReturn[1]
				If !lSucesso
					Exit
				EndIf
			Next nIndData

			aSize(aProgrs[nIndProg]["recursos"][nIndRec]["datas"], 0)
			FwFreeObj(aProgrs[nIndProg]["recursos"][nIndRec])

			If !lSucesso
				Exit
			EndIf
		Next nIndRec

		aSize(aProgrs[nIndProg]["recursos"], 0)
		FwFreeObj(aProgrs[nIndProg])

		If !lSucesso
			Exit
		EndIf
	Next nIndProg

	If nTotProg > 0
		aSize(aProgrs, 0)
	EndIf

Return lSucesso

/*/{Protheus.doc} P152GravaPCP
Inicia a gravação dos registros no PCP.

@type  Function
@author Lucas Fagundes
@since 30/01/2025
@version P12
@param cProg, Caracter, Código da programação.
@return Nil
/*/
Function P152GravaPCP(cProg)
	Local oEfetiva := PCPA152Efetivacao():New(cProg, .T.)

	oEfetiva:gravaDadosPCP()

Return Nil

/*/{Protheus.doc} gravaDadosPCP
Grava as mudanças de calendario nos cadastros do PCP.
@author Lucas Fagundes
@since 30/01/2025
@version P12
@return Nil
/*/
Method gravaDadosPCP() Class PCPA152Efetivacao
	Local nTempoIni := MicroSeconds()

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Inicio do processo de atualizacao dos cadastros no PCP"})

	Begin Transaction

		Self:atualizaProcessamento(STR0669, 0, Nil, CHAR_ETAPAS_GRAVA_PCP) // "Cadastrando exceções de calendario"
		lSucesso := Self:cadastraExcecoes()

		If lSucesso
			Self:atualizaProcessamento(STR0670, 50, Nil, CHAR_ETAPAS_GRAVA_PCP) // "Removendo bloqueios de recursos"
			lSucesso := Self:ajustaBloqueios()

			If lSucesso
				Self:atualizaProcessamento(STR0671, 75, Nil, CHAR_ETAPAS_GRAVA_PCP) // "Cadastrando bloqueios de recursos"
				lSucesso := Self:cadastraBloqueios()
			EndIf

			If lSucesso .And. Self:oBulkBloque != Nil
				lSucesso := Self:oBulkBloque:close()
			EndIf

			If !lSucesso
				Self:cErroMsg := STR0672 // "Ocorreu um erro ao atualizar os cadastros de bloqueios."

				If Self:oBulkBloque != Nil
					Self:cErroDet := Self:oBulkBloque:getError()
				EndIf
			EndIf
		EndIf

		If lSucesso
			_Super:gravaValorGlobal("PROC_GRAVA_PCP", "OK")
			Self:atualizaProcessamento(Nil, 100, Nil, CHAR_ETAPAS_GRAVA_PCP)
			lSucesso := Self:aguardaFimProcessamento()
		EndIf

		If lSucesso
			_Super:atualizaEtapa(CHAR_ETAPAS_GRAVA_PCP, STATUS_CONCLUIDO)
		Else
			P152ErroEf(Self:cProg, Self:cErroMsg, Self:cErroDet, CHAR_ETAPAS_GRAVA_PCP)
		EndIf

	End Transaction

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Fim do processo de atualizacao dos cadastros no PCP: " + cValToChar(MicroSeconds() - nTempoIni)})
	_Super:gravaValorGlobal("PROCESSO_THREADS", 0, .F., .T., -1)

Return Nil

/*/{Protheus.doc} cadastraExcecoes
Cadastra as disponibilidades alteradas como exceções de calendario no PCP.
@author Lucas Fagundes
@since 31/01/2025
@version P12
@return lSucesso, Logico, Indica se cadastrou as exceções com sucesso.
/*/
Method cadastraExcecoes() Class PCPA152Efetivacao
	Local aCab       := {}
	Local aHoras     := {}
	Local aItens     := {}
	Local cAlias     := GetNextAlias()
	Local cCCusto    := ""
	Local cDescricao := "CRP - " + Self:cProg
	Local cFilSH9    := xFilial("SH9")
	Local cIdDisp    := ""
	Local cQuery     := ""
	Local cRecurso   := ""
	Local dData      := Nil
	Local lAltera    := .F.
	Local lSucesso   := .T.
	Local nFim       := 0
	Local nInicio    := 0
	Local nOperacao  := 0
	Local nTamCusto  := GetSX3Cache("H9_CCUSTO", "X3_TAMANHO")
	Local nTamRec    := GetSX3Cache("H9_RECURSO", "X3_TAMANHO")
	Local nTempoIni  := MicroSeconds()
	Local nTempoQry  := 0
	Private lMsErroAuto := .F.

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Inicio da gravacao das excecoes de calendario"})

	cQuery := " SELECT SMR.MR_RECURSO, "
	cQuery +=        " SMR.MR_DISP, "
	cQuery +=        " SMR.MR_DATDISP, "
	cQuery +=        " SMR.MR_ALTDISP, "
	cQuery +=        " SMK.MK_HRINI, "
	cQuery +=        " SMK.MK_HRFIM, "
	cQuery +=        " SMK.MK_TIPO, "
	cQuery +=        " SH1.H1_CCUSTO "
	cQuery +=   " FROM " + RetSqlName("SMR") + " SMR "
	cQuery +=   " LEFT JOIN " + RetSqlName("SMK") + " SMK "
	cQuery +=     " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "' "
	cQuery +=    " AND SMK.MK_PROG    = SMR.MR_PROG "
	cQuery +=    " AND SMK.MK_DISP    = SMR.MR_DISP "
	cQuery +=    " AND SMK.MK_TIPO   IN ('" + HORA_DISPONIVEL + "', '" + HORA_EXTRA + "', '" + HORA_PARADA + "') "
	cQuery +=    " AND SMK.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cQuery +=    " AND SH1.H1_CODIGO  = SMR.MR_RECURSO "
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMR.MR_FILIAL  = '" + xFilial("SMR")  + "' "
	cQuery +=    " AND SMR.MR_PROG    = '" + Self:cProg      + "' "
	cQuery +=    " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO + "' "
	cQuery +=    " AND SMR.MR_ALTDISP <> '" + NAO_ALTEROU_DISPONIBILIDADE + "' "
	cQuery +=    " AND SMR.D_E_L_E_T_ = ' ' "

	nTempoQry := MicroSeconds()
	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Query busca excecoes: " + cQuery})

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	TcSetField(cAlias, 'MR_DATDISP', 'D', GetSx3Cache("MR_DATDISP", "X3_TAMANHO"), 0)

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Tempo query busca excecoes: " + cValToChar(MicroSeconds() - nTempoQry)})

	SH9->(dbSetOrder(1))

	While (cAlias)->(!EoF())
		aHoras   := {}
		aItens   := {}
		cIdDisp  := (cAlias)->MR_DISP
		dData    := (cAlias)->MR_DATDISP
		cRecurso := PADR((cAlias)->MR_RECURSO, nTamRec  , " ")
		cCCusto  := PADR((cAlias)->H1_CCUSTO , nTamCusto, " ")

		lAltera := SH9->(dbSeek(cFilSH9 + SH9_TIPO_EXCECAO + cCCusto + cRecurso + DToS(dData)))

		aCab := {;
			{"H9_DTINI"  , dData     , Nil},;
            {"H9_RECURSO", cRecurso  , Nil},;
			{"H9_CCUSTO" , cCCusto   , Nil},;
            {"H9_MOTIVO" , cDescricao, Nil};
		}

		While (cAlias)->(!EoF()) .And. (cAlias)->MR_DISP == cIdDisp
			If (cAlias)->MR_ALTDISP != DELETOU_DISPONIBILIDADE .And. (cAlias)->MK_TIPO != HORA_PARADA
				nInicio := Val(StrTran((cAlias)->MK_HRINI, ":", "."))
				nFim    := Val(StrTran((cAlias)->MK_HRFIM, ":", "."))

				aAdd(aHoras, {nInicio, nFim})
			EndIf
			(cAlias)->(dbSkip())
		End

		aAdd(aItens, aHoras)

		nOperacao := Iif(lAltera, OPERACAO_ALTERACAO, OPERACAO_INCLUSAO)

		MSExecAuto({|v, x, y, z| MATA640(v, x, y, z)}, .F., nOperacao, aCab, aItens)
		lSucesso := !lMsErroAuto

		If !lSucesso
			Self:cErroMsg := STR0673 // "Erro ao cadastrar as exceções de calendario"
			Self:cErroDet := MemoRead(NomeAutoLog())
			Exit
		EndIf

		aSize(aCab, 0)
		aSize(aHoras, 0)
		aSize(aItens, 0)
	End
	(cAlias)->(dbCloseArea())

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Fim da gravacao das excecoes de calendario: " + cValToChar(MicroSeconds() - nTempoIni)})

Return lSucesso

/*/{Protheus.doc} cadastraBloqueios
Cadastra os bloqueios alterados no PCP.
@author Lucas Fagundes
@since 31/01/2025
@version P12
@return lSucesso, Logico, Indica se cadastrou os bloqueios com sucesso.
/*/
Method cadastraBloqueios() Class PCPA152Efetivacao
	Local cAlias     := GetNextAlias()
	Local cCCusto    := ""
	Local cDescricao := "CRP - " + Self:cProg
	Local cFim       := ""
	Local cIdDisp    := ""
	Local cInicio    := ""
	Local cQuery     := ""
	Local cFilSH9	:= xFilial("SH9")
	Local dData      := Nil
	Local lSucesso   := .T.
	Local nTempoIni  := MicroSeconds()
	Local nTempoQry  := 0
	Local lInsere    := .F.

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Inicio da gravacao dos bloqueios"})

	If Self:oBulkBloque == Nil
		Self:oBulkBloque := FwBulk():New(RetSqlName("SH9"))
		Self:oBulkBloque:setFields(Self:getFieldsCadastroBloqueio())
	EndIf

	cQuery := " SELECT SMR.MR_RECURSO, "
	cQuery +=        " SMR.MR_DISP, "
	cQuery +=        " SMR.MR_DATDISP, "
	cQuery +=        " SMR.MR_ALTDISP, "
	cQuery +=        " SMK.MK_HRINI, "
	cQuery +=        " SMK.MK_HRFIM, "
	cQuery +=        " SH1.H1_CCUSTO "
	cQuery +=   " FROM " + RetSqlName("SMR") + " SMR "
	cQuery +=  " INNER JOIN " + RetSqlName("SMK") + " SMK "
	cQuery +=     " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "' "
	cQuery +=    " AND SMK.MK_PROG    = SMR.MR_PROG "
	cQuery +=    " AND SMK.MK_DISP    = SMR.MR_DISP "
	cQuery +=    " AND SMK.MK_BLOQUE  = '" + HORA_BLOQUEADA + "' "
	cQuery +=    " AND SMK.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cQuery +=    " AND SH1.H1_CODIGO  = SMR.MR_RECURSO "
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMR.MR_FILIAL  = '" + xFilial("SMR")  + "' "
	cQuery +=    " AND SMR.MR_PROG    = '" + Self:cProg      + "' "
	cQuery +=    " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO + "' "
	cQuery +=    " AND SMR.MR_ALTDISP = '" + ALTEROU_DISPONIBILIDADE + "' "
	cQuery +=    " AND SMR.D_E_L_E_T_ = ' ' "

	nTempoQry := MicroSeconds()
	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Query busca bloqueios: " + cQuery})

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	TcSetField(cAlias, 'MR_DATDISP', 'D', GetSx3Cache("MR_DATDISP", "X3_TAMANHO"), 0)

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Tempo query busca bloqueios: " + cValToChar(MicroSeconds() - nTempoQry)})

	While (cAlias)->(!EoF()) .And. lSucesso
		cIdDisp  := (cAlias)->MR_DISP
		dData    := (cAlias)->MR_DATDISP
		cRecurso := (cAlias)->MR_RECURSO
		cCCusto  := (cAlias)->H1_CCUSTO
		cInicio  := (cAlias)->MK_HRINI
		cFim     := (cAlias)->MK_HRFIM
		lInsere  := .F.

		While (cAlias)->(!EoF()) .And. !lInsere .And. lSucesso

			If (cAlias)->MK_HRINI == cFim
				cFim := (cAlias)->MK_HRFIM
			EndIf

			(cAlias)->(dbSkip())

			lInsere := (cAlias)->MR_DISP != cIdDisp .Or. (cAlias)->MK_HRINI != cFim
			If lInsere
				lSucesso := Self:oBulkBloque:addData({cFilSH9, cRecurso, cCCusto, cDescricao, dData, dData, cInicio, cFim, SH9_TIPO_BLOQUEIO})
			EndIf
		End
	End
	(cAlias)->(dbCloseArea())

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Fim da gravacao dos bloqueios: " + cValToChar(MicroSeconds() - nTempoIni)})

Return lSucesso

/*/{Protheus.doc} aguardaFimProcessamento
Aguarda o fim do processamento de todas as threads.
@author Lucas Fagundes
@since 31/01/2025
@version P12
@return lSucesso, Lógico, Indica se todas as threads finalizaram com sucesso.
/*/
Method aguardaFimProcessamento() Class PCPA152Efetivacao
	Local lSucesso := .T.

	While (_Super:retornaValorGlobal("PROC_EFETIVACAO") != "OK" .Or. _Super:retornaValorGlobal("PROC_GRAVA_PCP") != "OK") .And. !Self:oProcError:possuiErro()
		Sleep(100)
	End
	lSucesso := !Self:oProcError:possuiErro()

Return lSucesso

/*/{Protheus.doc} getFieldsCadastroBloqueio
Retorna os campos utilizados no insert dos bloqueios.
@author Lucas Fagundes
@since 03/02/2025
@version P12
@return aFields, Array, Campos usados no insert dos bloqueios.
/*/
Method getFieldsCadastroBloqueio() Class PCPA152Efetivacao
	Local aFields := {}

	aAdd(aFields, {"H9_FILIAL"})
	aAdd(aFields, {"H9_RECURSO"})
	aAdd(aFields, {"H9_CCUSTO"})
	aAdd(aFields, {"H9_MOTIVO"})
	aAdd(aFields, {"H9_DTINI"})
	aAdd(aFields, {"H9_DTFIM"})
	aAdd(aFields, {"H9_HRINI"})
	aAdd(aFields, {"H9_HRFIM"})
	aAdd(aFields, {"H9_TIPO"})

Return aFields

/*/{Protheus.doc} ajustaBloqueios
Ajusta os bloqueios de recursos que tiveram a disponibilidade alterada na programação.
@author Lucas Fagundes
@since 04/02/2025
@version P12
@return lSucesso, Logico, Indica se ajustou os bloqueios com sucesso.
/*/
Method ajustaBloqueios() Class PCPA152Efetivacao
	Local cAlias    := GetNextAlias()
	Local cCCusto   := ""
	Local cFim      := ""
	Local cIdDisp   := ""
	Local cInicio   := ""
	Local cQuery    := ""
	Local cRecurso  := ""
	Local dData     := Nil
	Local lRemove   := .F.
	Local lSucesso  := .T.
	Local nTempoIni := MicroSeconds()
	Local nTempoQry := 0

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Inicio da remocao dos bloqueios"})

	cQuery := " SELECT SMR.MR_RECURSO, "
	cQuery +=        " SMR.MR_DISP, "
	cQuery +=        " SMR.MR_DATDISP, "
	cQuery +=        " SMR.MR_ALTDISP, "
	cQuery +=        " SMK.MK_HRINI, "
	cQuery +=        " SMK.MK_HRFIM, "
	cQuery +=        " SH1.H1_CCUSTO "
	cQuery +=   " FROM " + RetSqlName("SMR") + " SMR "
	cQuery +=   " LEFT JOIN " + RetSqlName("SMK") + " SMK "
	cQuery +=     " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "' "
	cQuery +=    " AND SMK.MK_PROG    = SMR.MR_PROG "
	cQuery +=    " AND SMK.MK_DISP    = SMR.MR_DISP "
	cQuery +=    " AND SMK.MK_BLOQUE  = '" + HORA_NAO_BLOQUEADA + "' "
	cQuery +=    " AND SMK.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cQuery +=    " AND SH1.H1_CODIGO  = SMR.MR_RECURSO "
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMR.MR_FILIAL  = '" + xFilial("SMR")  + "' "
	cQuery +=    " AND SMR.MR_PROG    = '" + Self:cProg      + "' "
	cQuery +=    " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO + "' "
	cQuery +=    " AND SMR.MR_ALTDISP <> '" + NAO_ALTEROU_DISPONIBILIDADE + "' "
	cQuery +=    " AND SMR.D_E_L_E_T_ = ' ' "

	nTempoQry := MicroSeconds()
	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Query busca bloqueios: " + cQuery})

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	TcSetField(cAlias, 'MR_DATDISP', 'D', GetSx3Cache("MR_DATDISP", "X3_TAMANHO"), 0)

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Tempo query busca bloqueios: " + cValToChar(MicroSeconds() - nTempoQry)})

	While (cAlias)->(!EoF()) .And. lSucesso
		cCCusto  := (cAlias)->H1_CCUSTO
		cIdDisp  := (cAlias)->MR_DISP
		cRecurso := (cAlias)->MR_RECURSO
		dData    := (cAlias)->MR_DATDISP
		lRemove  := .F.

		If (cAlias)->MR_ALTDISP == DELETOU_DISPONIBILIDADE
			cInicio := "00:00"
			cFim    := "23:59"
		Else
			cInicio := (cAlias)->MK_HRINI
			cFim := (cAlias)->MK_HRFIM
		EndIf

		While (cAlias)->(!EoF()) .And. !lRemove .And. lSucesso

			If (cAlias)->MK_HRINI == cFim
				cFim := (cAlias)->MK_HRFIM
			EndIf

			(cAlias)->(dbSkip())

			lRemove := (cAlias)->MR_DISP != cIdDisp .Or. (cAlias)->MK_HRINI != cFim
			If lRemove
				lSucesso := Self:removeBloqueios(cRecurso, cCCusto, dData, cInicio, cFim)
			EndIf
		End
	End
	(cAlias)->(dbCloseArea())

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Fim da remocao dos bloqueios: " + cValToChar(MicroSeconds() - nTempoIni)})

Return lSucesso

/*/{Protheus.doc} removeBloqueios
Remove os bloqueios dentro de um determinado periodo.
@author Lucas Fagundes
@since 04/02/2025
@version P12
@param 01 cRecurso, Caracter, Código do recurso que terá os bloqueios removidos.
@param 02 cCCusto , Caracter, Código do centro de custo do recurso que terá os bloqueios removidos.
@param 03 dData   , Date	, Data dos bloqueios que serão removidos.
@param 04 cInicio , Caracter, Hora de inicio dos bloqueios que serão removidos.
@param 05 cFim    , Caracter, Hora de final dos bloqueios que serão removidos.
@return lSucesso, Lógico, Indica se removeu os bloqueios com sucesso.
/*/
Method removeBloqueios(cRecurso, cCCusto, dData, cInicio, cFim) Class PCPA152Efetivacao
	Local cAlias     := ""
	Local cDescricao := ""
	Local cFilSH9    := xFilial("SH9")
	Local cHrFimBloq := ""
	Local cHrIniBloq := ""
	Local cQuery     := ""
	Local cHrAux     := ""
	Local dDtAux     := Nil
	Local dFimBloq   := Nil
	Local dIniBloq   := Nil
	Local nRecno     := 0
	Local lSucesso   := .T.

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVA_PCP, {"Excluindo bloqueios dos recurso " + cRecurso + " no dia " + DToC(dData) + " das " + cInicio + " as " + cFim})

	If Self:oBulkBloque == Nil
		Self:oBulkBloque := FwBulk():New(RetSqlName("SH9"))
		Self:oBulkBloque:setFields(Self:getFieldsCadastroBloqueio())
	EndIf

	If Self:oBuscaBloque == Nil
		cQuery := " SELECT SH9.H9_MOTIVO, "
		cQuery +=        " SH9.H9_DTINI, "
		cQuery +=        " SH9.H9_DTFIM, "
		cQuery +=        " SH9.H9_HRINI, "
		cQuery +=        " SH9.H9_HRFIM, "
		cQuery +=        " SH9.R_E_C_N_O_ "
		cQuery +=   " FROM " + RetSqlName("SH9") + " SH9 "
		cQuery +=  " WHERE SH9.H9_FILIAL  = ? "
		cQuery +=    " AND SH9.H9_TIPO    = ? "
		cQuery +=    " AND SH9.H9_RECURSO = ? "
		cQuery +=    " AND SH9.H9_CCUSTO  = ? "
		cQuery +=    " AND ( "
		cQuery +=          " (SH9.H9_DTINI = ? AND SH9.H9_HRINI < ?) OR "
		cQuery +=          " (SH9.H9_DTINI < ? AND (SH9.H9_DTFIM > ? OR (SH9.H9_DTFIM = ? AND SH9.H9_HRFIM > ?))) "
		cQuery +=        " ) "
		cQuery +=    " AND SH9.D_E_L_E_T_ = ' ' "

		Self:oBuscaBloque := FwExecStatement():New(cQuery)

		Self:oBuscaBloque:setString(1, xFilial("SH9"))
		Self:oBuscaBloque:setString(2, SH9_TIPO_BLOQUEIO)
	EndIf

	Self:oBuscaBloque:setString(3, cRecurso)
	Self:oBuscaBloque:setString(4, cCCusto)
	Self:oBuscaBloque:setDate(5, dData)
	Self:oBuscaBloque:setString(6, cFim)
	Self:oBuscaBloque:setDate(7, dData)
	Self:oBuscaBloque:setDate(8, dData)
	Self:oBuscaBloque:setDate(9, dData)
	Self:oBuscaBloque:setString(10, cInicio)

	cAlias := Self:oBuscaBloque:openAlias()

	TcSetField(cAlias, 'H9_DTINI', 'D', GetSx3Cache("H9_DTINI", "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'H9_DTFIM', 'D', GetSx3Cache("H9_DTFIM", "X3_TAMANHO"), 0)

	While (cAlias)->(!EoF())
		cDescricao := (cAlias)->H9_MOTIVO
		cHrFimBloq := (cAlias)->H9_HRFIM
		cHrIniBloq := (cAlias)->H9_HRINI
		dFimBloq   := (cAlias)->H9_DTFIM
		dIniBloq   := (cAlias)->H9_DTINI
		nRecno     := (cAlias)->R_E_C_N_O_

		SH9->(dbGoTo(nRecno))

		// Se o bloqueio esta TODO dentro do periodo de exclusão, exclui por inteiro.
		If dIniBloq == dData .And. cHrIniBloq >= cInicio .And. dFimBloq == dData .And. cHrFimBloq <= cFim
			RecLock("SH9")
				SH9->(dbDelete())
			SH9->(MsUnLock())

		// Se o bloqueio inicia antes do periodo de exclusão, ajusta a hora final do bloqueio.
		ElseIf dIniBloq < dData .Or. (dIniBloq == dData .And. cHrIniBloq < cInicio)
			dDtAux := dData
			cHrAux := cInicio

			// Se o periodo inicia no começo do dia, finaliza no final do dia anterior.
			If cInicio == "00:00" .And. dIniBloq < dData
				dDtAux--
				cHrAux := "23:59"
			EndIf

			RecLock("SH9")
				SH9->H9_DTFIM := dDtAux
				SH9->H9_HRFIM := cHrAux
			SH9->(MsUnLock())

			// Se o bloqueio termina depois do periodo de exclusão, insere um novo bloqueio com o tempo após o periodo.
			If dFimBloq > dData .Or. (dFimBloq == dData .And. cHrFimBloq > cFim)
				dDtAux := dData
				cHrAux := cFim

				// Se o periodo liberado vai até o final do dia, insere o novo bloqueio no próximo dia.
				If cFim >= "23:59" .And. dFimBloq > dData
					dDtAux++
					cHrAux := "00:00"
				EndIf

				lSucesso := Self:oBulkBloque:addData({cFilSH9, cRecurso, cCCusto, cDescricao, dDtAux, dFimBloq, cHrAux, cHrFimBloq, SH9_TIPO_BLOQUEIO})
			EndIf

		// Se o bloqueio inicia durante o periodo de exclusão, ajusta a hora inicial do bloqueio.
		ElseIf dIniBloq == dData .And. cHrIniBloq > cInicio
			dDtAux := dData
			cHrAux := cFim

			// Se o periodo liberado vai até o final do dia, começa o bloqueio no próximo dia.
			If cFim >= "23:59" .And. dFimBloq > dData
				dDtAux++
				cHrAux := "00:00"
			EndIf

			RecLock("SH9")
				SH9->H9_DTINI := dDtAux
				SH9->H9_HRINI := cHrAux
			SH9->(MsUnLock())

		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return lSucesso

/*/{Protheus.doc} efetivaFerramentas
Realiza a efetivação das ferramentas, gerando a tabela HZL.
@author Lucas Fagundes
@since 25/04/2025
@version P12
@return lSucesso, Logico, Indica se gerou a tabela sem erros.
/*/
Method efetivaFerramentas() Class PCPA152Efetivacao
	Local aInsert    := {}
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local cSeqHZL    := Self:cSeqHZL
	Local lInserir   := .T.
	Local lSucesso   := .T.
	Local nTempoIni  := MicroSeconds()
	Local nTempoQuer := 0
	Local oBulk      := Nil

	oBulk := FwBulk():New(RetSqlName("HZL"))
	oBulk:SetFields(tabFields("HZL"))

	Self:atualizaProcessamento("Efetivando ferramentas", 99)

	cQuery := " SELECT SMF.MF_OP, "
	cQuery +=        " SMF.MF_OPER, "
	cQuery +=        " SMF.MF_RECURSO, "
	cQuery +=        " SMF.MF_CTRAB, "
	cQuery +=        " HZJ.HZJ_FERRAM, "
	cQuery +=        " HZK.HZK_DATA, "
	cQuery +=        " HZK.HZK_INICIO, "
	cQuery +=        " HZK.HZK_FIM, "
	cQuery +=        " HZK.HZK_TEMPO, "
	cQuery +=        " HZK.HZK_SEQFER, "
	cQuery +=        " SVM.VM_TIPO "
	cQuery +=   " FROM " + RetSqlName("HZK") + " HZK "
	cQuery +=  " INNER JOIN " + RetSqlName("HZJ") + " HZJ "
	cQuery +=     " ON HZJ.HZJ_FILIAL = '" + xFilial("HZJ") + "' "
	cQuery +=    " AND HZJ.HZJ_PROG   = HZK.HZK_PROG "
	cQuery +=    " AND HZJ.HZJ_ID     = HZK.HZK_ID "
	cQuery +=    " AND HZJ.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SMF") +  " SMF "
	cQuery +=     " ON SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
	cQuery +=    " AND SMF.MF_PROG    = HZK.HZK_PROG "
	cQuery +=    " AND SMF.MF_ID      = HZK.HZK_IDOPER "
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SVM") + " SVM "
	cQuery +=     " ON SVM.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=    " AND SVM.VM_PROG    = HZK.HZK_PROG "
	cQuery +=    " AND SVM.VM_ID      = HZK.HZK_IDOPER "
	cQuery +=    " AND SVM.VM_SEQ     = HZK.HZK_SEQALO "
	cQuery +=    " AND SVM.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE HZK.HZK_FILIAL = '" + xFilial("HZK") + "' "
	cQuery +=    " AND HZK.HZK_PROG   = '" + Self:cProg + "' "
	cQuery +=    " AND HZK.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY SMF.MF_OP, SMF.MF_OPER, HZJ.HZJ_FERRAM, HZK.HZK_DATA, HZK.HZK_INICIO "

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Query efetivaFerramentas:" + cQuery })
	nTempoQuer := MicroSeconds()

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo query efetivaFerramentas: " + cValToChar(MicroSeconds() - nTempoQuer)})

	While (cAlias)->(!EoF()) .And. lSucesso
		lInserir := .F.

		If !Empty(aInsert)
			If aInsert[ARRAY_HZL_OP    ] == (cAlias)->MF_OP      .And.;
			   aInsert[ARRAY_HZL_OPER  ] == (cAlias)->MF_OPER    .And.;
			   aInsert[ARRAY_HZL_FERRAM] == (cAlias)->HZJ_FERRAM .And.;
			   aInsert[ARRAY_HZL_SEQFER] == (cAlias)->HZK_SEQFER

				If aInsert[ARRAY_HZL_DATA] == (cAlias)->HZK_DATA   .And.;
				   aInsert[ARRAY_HZL_FIM ] == (cAlias)->HZK_INICIO .And.;
				   aInsert[ARRAY_HZL_TIPO] == (cAlias)->VM_TIPO
					aInsert[ARRAY_HZL_FIM   ] := (cAlias)->HZK_FIM
					aInsert[ARRAY_HZL_TEMPOT] += (cAlias)->HZK_TEMPO
				Else
					lInserir := .T.
				EndIf
			Else
				cSeqHZL := Self:cSeqHZL
				lInserir := .T.
			EndIf
		EndIf

		If lInserir
			lSucesso := oBulk:addData(aInsert)
			aSize(aInsert, 0)
		EndIf

		If Empty(aInsert)
			aInsert := Array(ARRAY_HZL_TAMANHO)

			aInsert[ARRAY_HZL_FILIAL] := xFilial("HZL")
			aInsert[ARRAY_HZL_OP    ] := (cAlias)->MF_OP
			aInsert[ARRAY_HZL_OPER  ] := (cAlias)->MF_OPER
			aInsert[ARRAY_HZL_RECURS] := (cAlias)->MF_RECURSO
			aInsert[ARRAY_HZL_CTRAB ] := (cAlias)->MF_CTRAB
			aInsert[ARRAY_HZL_FERRAM] := (cAlias)->HZJ_FERRAM
			aInsert[ARRAY_HZL_DATA  ] := (cAlias)->HZK_DATA
			aInsert[ARRAY_HZL_SEQ   ] := cSeqHZL
			aInsert[ARRAY_HZL_INICIO] := (cAlias)->HZK_INICIO
			aInsert[ARRAY_HZL_FIM   ] := (cAlias)->HZK_FIM
			aInsert[ARRAY_HZL_TEMPOT] := (cAlias)->HZK_TEMPO
			aInsert[ARRAY_HZL_STATUS] := STATUS_ATIVO
			aInsert[ARRAY_HZL_PROG  ] := Self:cProg
			aInsert[ARRAY_HZL_TIPO  ] := (cAlias)->VM_TIPO
			aInsert[ARRAY_HZL_SEQFER] := (cAlias)->HZK_SEQFER

			cSeqHZL  := Soma1(cSeqHZL)
		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If lSucesso .And. !Empty(aInsert)
		lSucesso := oBulk:addData(aInsert)
		aSize(aInsert, 0)
	EndIf

	Self:cErroDet := oBulk:getError()
	If lSucesso
		lSucesso := oBulk:close()
		Self:cErroDet := oBulk:getError()
	EndIf

	If !lSucesso
		Self:cErroMsg := i18n(STR0182, {"HZL"}) // "Erro na gravação da tabela #1[tabela]#."
	EndIf

	Self:oLogs:gravaLog(CHAR_ETAPAS_EFETIVACAO, {"Tempo gravacao da tabela HZL: " + cValToChar(MicroSeconds() - nTempoIni)})

	oBulk:destroy()
	aSize(aInsert, 0)
Return lSucesso

/*/{Protheus.doc} temDicFerr
Retorna se existe o dicionario de ferramentas.
@type  Static Function
@author Lucas Fagundes
@since 28/04/2025
@version P12
@return _lDicFerra, Logico, Indica se possui a tabela de ferramentas efetivadas.
/*/
Static Function temDicFerr()

	If _lDicFerra == Nil
		_lDicFerra := GetSx3Cache("MF_TPALOFE", "X3_TAMANHO") > 0
	EndIf

Return _lDicFerra
