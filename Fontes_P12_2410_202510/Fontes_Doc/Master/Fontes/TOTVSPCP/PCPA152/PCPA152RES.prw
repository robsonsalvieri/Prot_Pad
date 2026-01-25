#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

#DEFINE ALOCADA      "A"
#DEFINE SEM_ALOCACAO "SA"
#DEFINE FINALIZADA   "F"

#DEFINE DEPENDECY_TYPE_FF 0
#DEFINE DEPENDECY_TYPE_FS 1
#DEFINE DEPENDECY_TYPE_SF 2
#DEFINE DEPENDECY_TYPE_SS 3

Static _oQryArvor := Nil
Static _oQryInfOp := Nil
Static _oQryOper  := Nil
Static _oNameUsr  := Nil
Static _oQryOpOpc := Nil
Static _oQryOpc   := Nil
Static _oDicionar := Nil
Static _oQryFerra := Nil

/*/{Protheus.doc} PCPA152RES
API que envia as informações para tela do CRP.

@type  WSCLASS
@author Marcelo Neumann
@since 01/02/2023
@version P12
/*/
WSRESTFUL PCPA152RES DESCRIPTION "PCPA152RES" FORMAT APPLICATION_JSON
	WSDATA bloqueio        AS BOOLEAN OPTIONAL
	WSDATA comAlocacao     AS BOOLEAN OPTIONAL
	WSDATA efetivado       AS BOOLEAN OPTIONAL
	WSDATA Excluidas       AS BOOLEAN OPTIONAL
	WSDATA filterHWF       AS BOOLEAN OPTIONAL
	WSDATA FilterIN        AS BOOLEAN OPTIONAL
	WSDATA HorasBloqueadas AS BOOLEAN OPTIONAL
	WSDATA PageFiltro      AS BOOLEAN OPTIONAL
	WSDATA possuiAlocacao  AS BOOLEAN OPTIONAL
	WSDATA DataFinal       AS DATE    OPTIONAL
	WSDATA DataInicial     AS DATE    OPTIONAL
	WSDATA Page            AS INTEGER OPTIONAL
	WSDATA PageSize        AS INTEGER OPTIONAL
	WSDATA arvore          AS STRING OPTIONAL
	WSDATA centroTrabalho  AS STRING OPTIONAL
	WSDATA codigo          AS STRING OPTIONAL
	WSDATA descricao       AS STRING OPTIONAL
	WSDATA ferramentas     AS STRING OPTIONAL
	WSDATA Filter          AS STRING OPTIONAL
	WSDATA FiltroRecurso   AS STRING OPTIONAL
	WSDATA FiltroTipoHoras AS STRING OPTIONAL
	WSDATA grupo           AS STRING OPTIONAL
	WSDATA ordemProducao   AS STRING OPTIONAL
	WSDATA produto         AS STRING OPTIONAL
	WSDATA Programacao     AS STRING OPTIONAL
	WSDATA recursos        AS STRING OPTIONAL
	WSDATA status          AS STRING OPTIONAL
	WSDATA tipo            AS STRING OPTIONAL
	WSDATA usuario         AS STRING OPTIONAL

	WSMETHOD GET PROGRAMACOES;
		DESCRIPTION STR0026; //"Retorna todas as programações realizadas"
		WSSYNTAX "/api/pcp/v1/pcpa152res/programacoes" ;
		PATH "/api/pcp/v1/pcpa152res/programacoes" ;
		TTALK "v1"

	WSMETHOD GET RECURSOS;
		DESCRIPTION STR0027; //"Retorna todos os recursos"
		WSSYNTAX "/api/pcp/v1/pcpa152res/recursos" ;
		PATH "/api/pcp/v1/pcpa152res/recursos" ;
		TTALK "v1"

	WSMETHOD GET CENTROTRAB;
		DESCRIPTION STR0139; // "Retorna os centros de trabalho"
		WSSYNTAX "/api/pcp/v1/pcpa152res/centrotrab" ;
		PATH "/api/pcp/v1/pcpa152res/centrotrab" ;
		TTALK "v1"

	WSMETHOD GET PRODUTOS;
		DESCRIPTION STR0157 ; // "Retorna os produtos"
		WSSYNTAX "/api/pcp/v1/pcpa152res/produtos" ;
		PATH "/api/pcp/v1/pcpa152res/produtos" ;
		TTALK "v1"

	WSMETHOD GET GRUPOS;
		DESCRIPTION STR0158 ; // "Retorna os grupos de produto"
		WSSYNTAX "/api/pcp/v1/pcpa152res/grupos" ;
		PATH "/api/pcp/v1/pcpa152res/grupos" ;
		TTALK "v1"

	WSMETHOD GET TIPOS;
		DESCRIPTION STR0159 ; // "Retorna os tipos de produto"
		WSSYNTAX "/api/pcp/v1/pcpa152res/tipos" ;
		PATH "/api/pcp/v1/pcpa152res/tipos" ;
		TTALK "v1"

	WSMETHOD GET ORDENS;
		DESCRIPTION STR0160 ; // "Retorna as ordens de producao"
		WSSYNTAX "/api/pcp/v1/pcpa152res/ordens" ;
		PATH "/api/pcp/v1/pcpa152res/ordens" ;
		TTALK "v1"

	WSMETHOD GET PROGORDENS;
		DESCRIPTION STR0180; // "Retorna as ordens de produção consideradas em uma programação."
		WSSYNTAX "/api/pcp/v1/pcpa152res/ordens/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152res/ordens/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST RECGANTT;
		DESCRIPTION STR0210; // "Retorna os recursos que serão exibidos no gantt"
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/recursos" ;
		PATH "/api/pcp/v1/pcpa152res/{programacao}/recursos" ;
		TTALK "v1"

	WSMETHOD GET PARAMETROS;
		DESCRIPTION STR0255; // "Retorna os parâmetros de uma programação"
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/parametros" ;
		PATH "/api/pcp/v1/pcpa152res/{programacao}/parametros" ;
		TTALK "v1"

	WSMETHOD GET ARVORE;
		DESCRIPTION STR0287; // "Retorna as ordens de produção de uma árvore"
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/arvore/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152res/{programacao}/arvore/{ordemProducao}";
		TTALK "v1"

	WSMETHOD GET ORDEM;
		DESCRIPTION STR0288; // "Retorna as informações de uma ordem de produção"
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/ordem/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152res/{programacao}/ordem/{ordemProducao}";
		TTALK "v1"

	WSMETHOD GET OPERACOES;
		DESCRIPTION STR0289; // "Retorna as operações de uma ordem de produção"
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/operacoes/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152res/{programacao}/operacoes/{ordemProducao}";
		TTALK "v1"

	WSMETHOD GET FERRAMENTAS;
		DESCRIPTION STR0689; // "Retorna as ferramentas de uma ordem de produção"
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/ferramentas/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152res/{programacao}/ferramentas/{ordemProducao}";
		TTALK "v1"

	WSMETHOD GET ARVPROG;
		DESCRIPTION STR0319; // "Retorna as árvores de uma programação"
		WSSYNTAX "/api/pcp/v1/pcpa152res/arvores";
		PATH "/api/pcp/v1/pcpa152res/arvores";
		TTALK "v1"

	WSMETHOD GET CRONOLOGIA;
		DESCRIPTION STR0477; // "Retorna os registros para exibição da cronologia"
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/cronologia/{ordemProducao}";
		PATH "/api/pcp/v1/pcpa152res/{programacao}/cronologia/{ordemProducao}";
		TTALK "v1"

	WSMETHOD POST DATAORDEM;
		DESCRIPTION STR0497; // "Retorna a data de uma ordem de produção no CRP."
		WSSYNTAX "/api/pcp/v1/pcpa152res/buscaOrdem";
		PATH "/api/pcp/v1/pcpa152res/buscaOrdem";
		TTALK "v1"

	WSMETHOD POST CAPACIDADE;
		DESCRIPTION STR0520; // "Retorna os eventos para exibição na tela de capacidade do CRP."
		WSSYNTAX "/api/pcp/v1/pcpa152res/capacidade/{programacao}";
		PATH "/api/pcp/v1/pcpa152res/capacidade/{programacao}";
		TTALK "v1"

	WSMETHOD GET OPTIONAL;
		DESCRIPTION STR0621; // "Busca os opcionais do produto em uma ordem."
		WSSYNTAX "/api/pcp/v1/pcpa152res/opcional/{ordemProducao}" ;
		PATH "/api/pcp/v1/pcpa152res/opcional/{ordemProducao}" ;
		TTALK "v1"

	WSMETHOD GET OPOPCIONAL;
		DESCRIPTION STR0622; // "Busca os dados de uma ordem de produção."
		WSSYNTAX "/api/pcp/v1/pcpa152res/ordemProducao/opcional/{programacao}/{ordemProducao}" ;
		PATH "/api/pcp/v1/pcpa152res/ordemProducao/opcional/{programacao}/{ordemProducao}" ;
		TTALK "v1"

	WSMETHOD GET OPOPERACAO;
		DESCRIPTION STR0623; // "Busca as operacões de uma ordem de produção."
		WSSYNTAX "/api/pcp/v1/pcpa152res/operacao/opcional/{programacao}/{ordemProducao}" ;
		PATH "/api/pcp/v1/pcpa152res/operacao/opcional/{programacao}/{ordemProducao}" ;
		TTALK "v1"

	WSMETHOD GET FERRGANTT;
		DESCRIPTION STR0694; // "Retorna as ferramentas utilizadas em uma programação."
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/ferramentas" ;
		PATH "/api/pcp/v1/pcpa152res/{programacao}/ferramentas" ;
		TTALK "v1"

	WSMETHOD GET ALOCFERR;
		DESCRIPTION STR0695; // "Retorna os periodos de alocação nas ferramentas."
		WSSYNTAX "/api/pcp/v1/pcpa152res/{programacao}/ferramentas/alocacao" ;
		PATH "/api/pcp/v1/pcpa152res/{programacao}/ferramentas/alocacao" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET PROGRAMACOES /api/pcp/v1/pcpa152res/programacoes
Retorna as programações processadas

@type  WSMETHOD
@author Marcelo Neumann
@since 01/02/2023
@version P12
@param 01 Filter     , Caracter, Código da programação
@param 02 Page       , Numérico, Número da página a ser buscada
@param 03 PageSize   , Numérico, Tamanho da página
@param 04 codigo     , Caracter, Filtro de programação.
@param 05 status     , Caracter, Filtro de status da programação.
@param 06 usuario    , Caracter, Filtro de usuario.
@param 07 DataInicial, Date    , Filtro de data de inicio da programação.
@param 08 DataFinal  , Date    , Filtro de data final da programação.
@param 09 Excluidas  , Logico  , Indica que deve filtrar as programações excluidas.
@param 10 descricao  , Caracter, Filtro de descrição.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET PROGRAMACOES QUERYPARAM Filter, Page, PageSize, codigo, status, usuario, DataInicial, DataFinal, Excluidas, descricao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodProg  := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodProg := Self:Filter
		Else
			cCodProg := Self:codigo
		EndIf

		aReturn := GetProgr(cCodProg, Self:Page, Self:PageSize, Self:status, Self:usuario, Self:DataInicial, Self:DataFinal, Self:Excluidas, Self:descricao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} GetProgr
Retorna as programações processadas

@type Static Function
@author Marcelo Neumann
@since 07/02/2023
@version P12
@param 01 cProgramac, Caracter, Código da programação
@param 02 nPage     , Numérico, Número da página a ser buscada
@param 03 nPageSize , Numérico, Tamanho da página
@param 04 cStatus   , Caracter, Filtro de status.
@param 05 cUsuario  , Caracter, Filtro de usuario.
@param 06 dDataIni  , Date    , Filtro de data de inicio.
@param 07 dDataFim  , Date    , Filtro de data final.
@param 08 lExcluidas, Logico  , Indica que deve filtrar as programações excluidas.
@param 09 cDescri   , Caracter, Filtro de descrição.
@return aReturn, Array, Retorna as programações encontradas
/*/
Static Function GetProgr(cProgramac, nPage, nPageSize, cStatus, cUsuario, dDataIni, dDataFim, lExcluidas, cDescri)
	Local aReturn      := Array(3)
	Local cAlias       := GetNextAlias()
	Local cFilT4Y      := xFilial("T4Y")
	Local nPos         := 0
	Local oReturn      := JsonObject():New()
	Default cProgramac := ""
	Default lExcluidas := .F.
	Default nPage      := 1
	Default nPageSize  := 20

	dbSelectArea("T4X")
	SMR->(dbSetOrder(1))

	cQuery := "SELECT T4X.T4X_PROG   programacao, "
	cQuery +=       " T4X.T4X_STATUS idStatus,    "
	cQuery +=       " T4X.T4X_USER   usuario,     "
	cQuery +=       " dataInicial.T4Y_VALOR dataInicial, "
	cQuery +=       " dataFinal.T4Y_VALOR dataFinal,"
	cQuery +=       " T4X.T4X_REPROC pendReproc,"
	cQuery +=       " dataRealFim.T4Y_VALOR dataRealFim,"
	cQuery +=       " T4X.T4X_DESCRI "
	cQuery +=  " FROM " + RetSqlName("T4X") + " T4X "
	cQuery += " INNER JOIN " + RetSqlName("T4Y") + " dataInicial "
	cQuery +=    " ON dataInicial.T4Y_PROG   = T4X.T4X_PROG  "
	cQuery +=   " AND dataInicial.T4Y_PARAM  = 'dataInicial' "
	cQuery +=   " AND dataInicial.D_E_L_E_T_ = ' '           "
	cQuery +=   " AND dataInicial.T4Y_FILIAL = '" + cFilT4Y + "' "

	If !Empty(dDataIni)
		cQuery += " AND dataInicial.T4Y_VALOR >= '" + PCPConvDat(dDataIni, 2) + "' "
	EndIf

	cQuery += " INNER JOIN " + RetSqlName("T4Y") + " dataFinal "
	cQuery +=    " ON dataFinal.T4Y_PROG   = T4X.T4X_PROG "
	cQuery +=   " AND dataFinal.T4Y_PARAM  = 'dataFinal'  "
	cQuery +=   " AND dataFinal.D_E_L_E_T_ = ' '          "
	cQuery +=   " AND dataFinal.T4Y_FILIAL = '" + cFilT4Y + "' "

	If !Empty(dDataFim)
		cQuery += " AND dataFinal.T4Y_VALOR <= '" + PCPConvDat(dDataFim, 2) + "'"
	EndIf

	cQuery += " INNER JOIN " + RetSqlName("T4Y") + " dataRealFim "
	cQuery +=    " ON dataRealFim.T4Y_PROG   = T4X.T4X_PROG "
	cQuery +=   " AND dataRealFim.T4Y_PARAM  = 'dataRealFim'  "
	cQuery +=   " AND dataRealFim.D_E_L_E_T_ = ' '          "
	cQuery +=   " AND dataRealFim.T4Y_FILIAL = '" + cFilT4Y + "' "

	cQuery += " WHERE T4X.T4X_FILIAL = '" + xFilial("T4X") + "'"
	cQuery +=   " AND T4X.D_E_L_E_T_ = ' '"

	If !Empty(cProgramac)
		cQuery += " AND T4X.T4X_PROG like '%" + cProgramac + "%'"
	EndIf

	If !lExcluidas
		cQuery += " AND T4X.T4X_STATUS != 'E' "
	EndIf

	If !Empty(cStatus)
		cQuery += " AND T4X.T4X_STATUS " + getFilter(cStatus, Nil, .T.)
	EndIf

	If !Empty(cUsuario)
		cQuery += " AND UPPER(T4X.T4X_USER) " + getFilter(cUsuario, Nil, .F.)
	EndIf

	If !Empty(cDescri)
		cQuery += " AND UPPER(T4X.T4X_DESCRI) " + getFilter(cDescri, Nil, .F.)
	EndIf

	cQuery += " ORDER BY programacao DESC "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nPos++
		aAdd(oReturn["items"], JsonObject():New())
		oReturn["items"][nPos]["programacao"            ] := RTrim((cAlias)->programacao)
		oReturn["items"][nPos]["idStatus"               ] := RTrim((cAlias)->idStatus)
		oReturn["items"][nPos]["dataInicial"            ] := PCPConvDat((cAlias)->dataInicial, 3)
		oReturn["items"][nPos]["dataFinal"              ] := PCPConvDat((cAlias)->dataFinal  , 3)
		oReturn["items"][nPos]["dataRealFim"            ] := PCPConvDat((cAlias)->dataRealFim, 3)
		oReturn["items"][nPos]["usuario"                ] := getUser((cAlias)->usuario)
		oReturn["items"][nPos]["status"                 ] := PCPA152Process():getDescricaoStatus(oReturn["items"][nPos]["idStatus"])
		oReturn["items"][nPos]["parametros"             ] := P152GetPar(oReturn["items"][nPos]["programacao"])
		oReturn["items"][nPos]["reprocessamentoPendente"] := (cAlias)->pendReproc == REPROCESSAMENTO_PENDENTE
		oReturn["items"][nPos]["existeDisponibilidade"  ] := SMR->(msSeek(xFilial("SMR") + (cAlias)->programacao))
		oReturn["items"][nPos]["descricao"              ] := RTrim((cAlias)->T4X_DESCRI)

		(cAlias)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0029 //"Não existem programações para atender os filtros informados."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	aSize(oReturn["items"], 0)
	FwFreeObj(oReturn)

Return aReturn

/*/{Protheus.doc} getUser
Busca o nome do usuário e guarda cache da informação

@type  Static Function
@author lucas.franca
@since 29/10/2024
@version P12
@param cIdUser, Caracter, ID do usuário
@return _oNameUsr[cIdUser], Caracter, Nome do usuário
/*/
Static Function getUser(cIdUser)
	If _oNameUsr == Nil
		_oNameUsr := JsonObject():New()
	EndIf
	If !_oNameUsr:hasProperty(cIdUser)
		_oNameUsr[cIdUser] := UsrRetName(cIdUser)
	EndIf
Return _oNameUsr[cIdUser]

/*/{Protheus.doc} GET RECURSOS /api/pcp/v1/pcpa152res/recursos
Retorna os recursos existentes

@type  WSMETHOD
@author Marcelo Neumann
@since 01/02/2023
@version P12
@param 01 Filter     , Caracter, Código do recurso
@param 02 Page       , Numérico, Número da página a ser buscada
@param 03 PageSize   , Numérico, Tamanho da página
@param 04 FilterIN   , Logico  , Indica que deve filtrar a query com IN.
@param 05 codigo     , Caracter, Filtro para codigo do recurso.
@param 06 descricao  , Caracter, Filtro para descroção do recurso.
@param 07 programacao, Caracter, Filtra apenas os recursos de uma programação.
@param 08 filterHWF  , Logico  , Indica que deve buscar os recursos da tabela HWF.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET RECURSOS QUERYPARAM Filter, Page, PageSize, FilterIN, codigo, descricao, programacao, filterHWF WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodRecur := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodRecur := Self:Filter
		Else
			cCodRecur := Self:codigo
		EndIf

		aReturn := GetRecurs(cCodRecur, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao, Self:programacao, Self:filterHWF)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} GetRecurs
Retorna os recursos existentes

@type Static Function
@author Marcelo Neumann
@since 07/02/2023
@version P12
@param 01 cRecurso  , Caracter, Código do recurso
@param 02 nPage     , Numérico, Número da página a ser buscada
@param 03 nPageSize , Numérico, Tamanho da página
@param 04 lInFilter , Logico  , Indica que deve filtrar a query com IN.
@param 05 cDescri   , Caracter, Filtro para descrição do recurso.
@param 06 cProg     , Caracter, Código para retornar apenas os recursos usado em uma programação.
@param 07 lFiltraHWF, Logico  , Indica que deve filtrar os recursos da tabela HWF.
@return aReturn, array, Retorna os recursos encontrados
/*/
Static Function GetRecurs(cRecurso, nPage, nPageSize, lInFilter, cDescri, cProg, lFiltraHWF)
	Local aReturn      := Array(3)
	Local cAlias       := GetNextAlias()
	Local lPagina      := .T.
	Local nPos         := 0
	Local oReturn      := JsonObject():New()
	Default cRecurso   := ""
	Default nPage      := 1
	Default nPageSize  := 20
	Default lFiltraHWF := .F.

	cQuery := "SELECT SH1.H1_CODIGO recurso,"                   + ;
	                " SH1.H1_DESCRI descricaoRecurso"           + ;
	           " FROM " + RetSqlName("SH1") + " SH1 "           + ;
	          " WHERE SH1.H1_FILIAL = '" + xFilial("SH1") + "'" + ;
	            " AND SH1.D_E_L_E_T_ = ' '"

	If !Empty(cRecurso)
		cQuery += " AND UPPER(SH1.H1_CODIGO) " + getFilter(cRecurso, Nil, lInFilter)
	EndIf

	If !Empty(cDescri)
		cQuery += " AND UPPER(SH1.H1_DESCRI) " + getFilter(cDescri, Nil, lInFilter)
	EndIf

	If !Empty(cProg)
		cQuery += " AND SH1.H1_CODIGO IN (SELECT DISTINCT SMR.MR_RECURSO "
		cQuery +=                         " FROM " + RetSqlName("SMR") + " SMR "
		cQuery +=                        " WHERE SMR.MR_FILIAL  = '" + xFilial("SMR") + "' "
		cQuery +=                          " AND SMR.MR_PROG    = '" + cProg + "' "
		cQuery +=                          " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO + "' "
		cQuery +=                          " AND SMR.D_E_L_E_T_ = ' ')"
	EndIf

	If lFiltraHWF
		cQuery += " AND EXISTS (SELECT 1 "
		cQuery +=               " FROM " + RetSqlName("HWF") + " HWF "
		cQuery +=              " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
		cQuery +=                " AND HWF.HWF_RECURS = SH1.H1_CODIGO "
		cQuery +=                " AND HWF.D_E_L_E_T_ = ' ') "
	EndIf

	cQuery += " ORDER BY recurso "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cRecurso))
	While (cAlias)->(!EoF())
		nPos++
		aAdd(oReturn["items"], JsonObject():New())
		oReturn["items"][nPos]["recurso"         ] := (cAlias)->recurso
		oReturn["items"][nPos]["descricaoRecurso"] := RTrim((cAlias)->descricaoRecurso)
		oReturn["items"][nPos]["color"           ] := "gray"

		(cAlias)->(dbSkip())

		//Verifica tamanho da página
		If lPagina .And. nPos >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0030 //"Não existem recursos para atender os filtros informados."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	aSize(oReturn["items"], 0)
	FwFreeObj(oReturn)

Return aReturn

/*/{Protheus.doc} GetDispon
Retorna a disponibilidade dos recursos da programação

@type Static Function
@author Marcelo Neumann
@since 07/02/2023
@version P12
@param 01 cProgramac, Caracter, Número da programação
@param 02 oParams   , Object  , Json com os parâmetros para busca da disponibilidade.
@param 03 oUsoDisp  , Object  , Json com as alocações das ordens.
@return aReturn, Array, Retorna a disponibilidade encontrada
/*/
Static Function GetDispon(cProgramac, oParams, oUsoDisp)
	Local aReturn    := {}
	Local cAlias     := GetNextAlias()
	Local cChaveDisp := ""
	Local cQryInTip  := ""
	Local cQuery     := ""
	Local nIndUso    := 0
	Local nTotUso    := 0
	Local oAlocInfo  := Nil
	Local oItem      := NIl
	Local oItemAux   := NIl
	Local oLastAdd   := Nil

	Default cProgramac := ""

	//Se não foi selecionado nenhum tipo de hora para ser exibido ou se não houver recursos para exibir.
	If (Empty(oParams["tipoHoras"]) .And. !oParams["horasBloqueadas"]) .Or. Empty(oParams["recursos"])
		Return aReturn
	EndIf

	cQuery := "SELECT SMR.MR_RECURSO recurso,"                      + ;
	                " SH1.H1_DESCRI  descRecurso,"                  + ;
	                " SMK.MK_DATDISP data,"                         + ;
	                " SMK.MK_HRINI   horaInicio,"                   + ;
	                " SMK.MK_HRFIM   horaFim,"                      + ;
	                " SMK.MK_TIPO    tipoHora,"                     + ;
	                " SMK.MK_BLOQUE  bloqueada,"                    + ;
	                " SMK.R_E_C_N_O_ id,"                           + ;
	                " SMK.MK_DISP    idDisponibilidade, "           + ;
	                " SMK.MK_SEQ     seqDisponibilidade "           + ;
	           " FROM " + RetSqlName("SMK") + " SMK"                + ;
	          " INNER JOIN " + RetSqlName("SMR") + " SMR"           + ;
	             " ON SMR.MR_FILIAL   = SMK.MK_FILIAL"              + ;
	            " AND SMR.MR_PROG     = SMK.MK_PROG"                + ;
	            " AND SMR.MR_TIPO     = '" + MR_TIPO_RECURSO + "' " + ;
	            " AND SMR.MR_DISP     = SMK.MK_DISP"                + ;
	            " AND SMR.D_E_L_E_T_  = ' '"                        + ;
	            " AND SMR.MR_RECURSO IN ('" + ArrToKStr(oParams["recursos"], "','") + "') " + ;
	          " INNER JOIN " + RetSqlName("SH1") + " SH1"           + ;
	             " ON SH1.H1_FILIAL   = '" + xFilial("SH1")   + "'" + ;
	            " AND SH1.H1_CODIGO   = SMR.MR_RECURSO"             + ;
	            " AND SH1.D_E_L_E_T_  = ' '"                        + ;
	          " WHERE SMK.MK_FILIAL   = '" + xFilial("SMK")   + "'" + ;
	            " AND SMK.MK_PROG     = '" + cProgramac       + "'" + ;
	            " AND SMK.MK_DATDISP >= '" + PCPConvDat(oParams["dataInicio"], 6) + "'" + ;
	            " AND SMK.MK_DATDISP  < '" + PCPConvDat(oParams["dataFinal" ], 6) + "'" + ;
	            " AND SMK.D_E_L_E_T_  = ' '"

	If oParams["tipoHoras"] <> "1234"
		cQryInTip := getInTipo(oParams["tipoHoras"])

		cQuery += " AND SMK.MK_TIPO IN (" + cQryInTip + ")"
	EndIf

	If !oParams["horasBloqueadas"]
		cQuery += " AND SMK.MK_BLOQUE = '2'"
	EndIf

	cQuery += " ORDER BY recurso, data, horaInicio"

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	TcSetField(cAlias, 'data', 'D', GetSx3Cache("T4X_DTINI", "X3_TAMANHO"), 0)

	While (cAlias)->(!EoF())
		cChaveDisp := getChvDisp((cAlias)->idDisponibilidade, (cAlias)->seqDisponibilidade)
		oItemAux := JsonObject():New()

		oItemAux["id"         ] := (cAlias)->id
		oItemAux["resourceId" ] := RTrim((cAlias)->recurso)
		oItemAux["description"] := RTrim((cAlias)->descRecurso)
		oItemAux["tipoHora"   ] := (cAlias)->tipoHora
		oItemAux["bloqueada"  ] := (cAlias)->bloqueada == "1"
		oItemAux["data"       ] := (cAlias)->data
		oItemAux["horaInicio" ] := (cAlias)->horaInicio
		oItemAux["horaFim"    ] := (cAlias)->horaFim
		oItemAux["folder"     ] := 'recursos'

		If !oParams["disponibilidadeAlocada"] .And. oUsoDisp:hasProperty(cChaveDisp) .And. (cAlias)->tipoHora != HORA_EFETIVADA
			nTotUso := Len(oUsoDisp[cChaveDisp])

			For nIndUso := 1 To nTotUso
				oAlocInfo := oUsoDisp[cChaveDisp][nIndUso]
				oItem     := JsonObject():New()

				oItem["id"         ] := oItemAux["id"         ]
				oItem["resourceId" ] := oItemAux["resourceId" ]
				oItem["description"] := oItemAux["description"]
				oItem["tipoHora"   ] := oItemAux["tipoHora"   ]
				oItem["bloqueada"  ] := oItemAux["bloqueada"  ]
				oItem["data"       ] := oItemAux["data"       ]
				oItem["horaInicio" ] := oItemAux["horaInicio" ]
				oItem["horaFim"    ] := oItemAux["horaFim"    ]
				oItem["folder"     ] := oItemAux["folder"     ]

				If oAlocInfo["horaInicio"] > oItemAux["horaInicio"]
					If oItem["horaFim"] > oAlocInfo["horaInicio"]
						oItem["horaFim"] := oAlocInfo["horaInicio"]
					EndIf

					oItemAux["horaInicio"] := oAlocInfo["horaFim"]
				Else
					If oAlocInfo["horaFim"] < oItemAux["horaFim"]
						oItemAux["horaInicio"] := oAlocInfo["horaFim"]
					Else
						oItemAux["horaInicio"] := oItemAux["horaFim"]
						Exit
					EndIf

					Loop
				EndIf

				If oLastAdd != Nil .And.;
				  (oItem["data"      ] == oLastAdd["data"      ] .And.;
				   oItem["horaInicio"] == oLastAdd["horaFim"   ] .And.;
				   oItem["resourceId"] == oLastAdd["resourceId"] .And.;
				   oItem["tipoHora"  ] == oLastAdd["tipoHora"  ] .And.;
				   oItem["bloqueada" ] == oLastAdd["bloqueada" ])

					oLastAdd["horaFim"] := oItem["horaFim"]
					oLastAdd["end"    ] := getDataJS(oLastAdd["data"], oLastAdd["horaFim"])
				Else
					oItem["start"] := getDataJS(oItem["data"], oItem["horaInicio"])
					oItem["end"  ] := getDataJS(oItem["data"], oItem["horaFim"   ])

					aAdd(aReturn, oItem)
					oLastAdd := oItem
				EndIf
				oItem := Nil

				If oItemAux["horaInicio"] >= oItemAux["horaFim"]
					Exit
				EndIf
			Next
		EndIf

		If oItemAux["horaFim"] > oItemAux["horaInicio"]
			If oLastAdd != Nil .And.;
			  (oItemAux["data"      ] == oLastAdd["data"      ] .And.;
			   oItemAux["horaInicio"] == oLastAdd["horaFim"   ] .And.;
			   oItemAux["resourceId"] == oLastAdd["resourceId"] .And.;
			   oItemAux["tipoHora"  ] == oLastAdd["tipoHora"  ] .And.;
			   oItemAux["bloqueada" ] == oLastAdd["bloqueada" ])

				oLastAdd["horaFim"] := oItemAux["horaFim"]
				oLastAdd["end"    ] := getDataJS(oLastAdd["data"], oLastAdd["horaFim"])
			Else
				oItemAux["start"] := getDataJS(oItemAux["data"], oItemAux["horaInicio"])
				oItemAux["end"  ] := getDataJS(oItemAux["data"], oItemAux["horaFim"   ])

				aAdd(aReturn, oItemAux)
				oLastAdd := oItemAux
			EndIf
		EndIf

		(cAlias)->(dbSkip())

		oItemAux := Nil
	End
	(cAlias)->(dbCloseArea())

	oLastAdd := Nil
Return aReturn

/*/{Protheus.doc} getInTipo
Retorna o conteudo para o IN do filtro de tipo de horas
@type  Static Function
@author Lucas Fagundes
@since 22/08/2023
@version P12
@param cTipHoras, Caracter, Valor recebido como filtro de horas.
@return cQryInTip, Caracter, Conteudo para o filtro IN do tipo de horas.
/*/
Static Function getInTipo(cTipHoras)
	Local cQryInTip := ""
	Local nLen      := Len(cTipHoras)
	Local nInd      := 0

	cQryInTip += "'" + SubStr(cTipHoras, 1, 1) + "'"

	For nInd := 2 To nLen
		cQryInTip += ",'" + SubStr(cTipHoras, nInd, 1) + "'"
	Next

Return cQryInTip

/*/{Protheus.doc} GetRecsDis
Retorna os recursos que serão exibidos no gantt de acordo com a paginação.

@type Static Function
@author Marcelo Neumann
@since 07/02/2023
@version P12
@param 01 cProgramac, Caracter, Número da programação que está sendo pesquisada
@param 02 nPage     , Numerico, Pagina dos recursos na tela.
@param 03 nPageSize , Numerico, Tamanho da paginação da tela.
@param 04 oParams   , Object  , Corpo da requisição com os parâmetros para filtrar a busca.
@return Nil
/*/
Static Function GetRecsDis(cProgramac, nPage, nPageSize, oParams)
	Local aReturn    := Array(3)
	Local cAlias     := GetNextAlias()
	Local cFrom      := ""
	Local cOrder     := ""
	Local cSelect    := ""
	Local cWhere     := ""
	Local lPagina    := nPageSize > 0
	Local lFiltraOP  := .F.
	Local lFiltraArv := .F.
	Local nInd       := 0
	Local nStart     := 0
	Local oReturn    := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 10

	dbSelectArea("SMR")
	dbSelectArea("SMK")

	lFiltraOP  := !Empty(oParams["ordemProducao"])
	lFiltraArv := !Empty(oParams["arvore"])

	oReturn["recursos"  ] := {}
	oReturn["quantidade"] := 0
	oReturn["hasNext"   ] := .F.

	cSelect := /*SELECT*/" DISTINCT SMT.MT_RECURSO recurso, SH1.H1_DESCRI descricaoRecurso "

	cFrom :=  /*FROM*/RetSqlName("SMT") + " SMT "
	cFrom += " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cFrom +=    " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cFrom +=   " AND SH1.H1_CODIGO  = SMT.MT_RECURSO "
	cFrom +=   " AND SH1.D_E_L_E_T_ = ' ' "

	If oParams["comAlocacao"] .Or. lFiltraOP .Or. lFiltraArv
		cFrom += " INNER JOIN " + RetSqlName("SMF") + " SMF "
		cFrom +=    " ON SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
		cFrom +=   " AND SMF.MF_PROG    = SMT.MT_PROG "
		cFrom +=   " AND SMF.MF_RECURSO = SMT.MT_RECURSO "

		If lFiltraOP
			cFrom += " AND SMF.MF_OP IN ('" + ArrToKStr(oParams["ordemProducao"], "','") + "') "
		EndIf

		If lFiltraArv
			cFrom += " AND SMF.MF_ARVORE IN ('" + ArrToKStr(oParams["arvore"], "','") + "') "
		EndIf
		cFrom +=   " AND SMF.D_E_L_E_T_ = ' '"

		If oParams["comAlocacao"]
			cFrom += " INNER JOIN " + RetSqlName("SVM") + " SVM"
			cFrom +=         " ON SVM.VM_FILIAL  = '" + xFilial("SVM") + "'"
			cFrom +=        " AND SVM.VM_PROG    = SMF.MF_PROG"
			cFrom +=        " AND SVM.VM_ID      = SMF.MF_ID"
			cFrom +=        " AND SVM.D_E_L_E_T_ = ' '"
		EndIf

	EndIf

	cWhere :=/*WHERE*/" SMT.MT_FILIAL = '" + xFilial("SMT") + "' "
	cWhere +=  " AND SMT.MT_PROG = '" + cProgramac + "'"

	If !Empty(oParams["recurso"])
		cWhere += " AND SMT.MT_RECURSO IN ('" + ArrToKStr(oParams["recurso"], "','") + "')"
	EndIf

	If !Empty(oParams["centroTrabalho"])
		cWhere += " AND SMT.MT_CTRAB IN ('" + ArrToKStr(oParams["centroTrabalho"], "','") + "')"
	EndIf

	cWhere +=  " AND SMT.D_E_L_E_T_ = ' ' "

	cOrder := " recurso "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"
	cOrder  := "%" + cOrder  + "%"

	If nPage == 1 /*Calcula quantidade total apenas na primeira execução*/
		BeginSql Alias cAlias
		%noparser%
		SELECT COUNT(1) TOTAL
			FROM (SELECT %exp:cSelect%
					FROM %exp:cFrom%
				WHERE %exp:cWhere%) cont
		EndSql

		oReturn["quantidade"] := (cAlias)->TOTAL
		(cAlias)->(dbCloseArea())
	EndIf

	If oReturn["quantidade"] > 0 .Or. nPage > 1
		BeginSql Alias cAlias
			%noparser%
			SELECT %exp:cSelect%
			  FROM %exp:cFrom%
			 WHERE %exp:cWhere%
			 ORDER BY %exp: cOrder%
		EndSql

		If nPage > 1 .And. lPagina
			nStart := ( (nPage-1) * nPageSize )
			If nStart > 0
				(cAlias)->(dbSkip(nStart))
			EndIf
		EndIf

		While (cAlias)->(!Eof())
			nInd++
			aAdd(oReturn["recursos"], JsonObject():New())
			oReturn["recursos"][nInd]["recurso"         ] := RTrim((cAlias)->recurso)
			oReturn["recursos"][nInd]["descricaoRecurso"] := RTrim((cAlias)->recurso) + " - " +RTrim((cAlias)->descricaoRecurso)
			oReturn["recursos"][nInd]["color"           ] := "gray"

			(cAlias)->(dbSkip())
			If nInd >= nPageSize .And. lPagina
				Exit
			EndIf
		End

		oReturn["hasNext"] := (cAlias)->(!EoF())
		(cAlias)->(dbCloseArea())
	EndIf

	aReturn[1] := .T.
	aReturn[2] := 200
	If oReturn["quantidade"] == 0
		aReturn[2] := 206
	EndIf
	aReturn[3] := oReturn:toJson()

Return aReturn

/*/{Protheus.doc} GET CENTROTRAB /api/pcp/v1/pcpa152res/centrotrab
Retorna os centros de trabalho para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 24/03/2023
@version P12
@param 01 Filter   , Caracter, Filtro dos centros de trabalho.
@param 02 Page     , Numerico, Página que será carregado na tela.
@param 03 PageSize , Numerico, Tamanho da página.
@param 04 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 05 codigo   , Caracter, Filtro para o codigo do centro de trabalho
@param 06 descricao, Caracter, Filtro para a descrição do centro de trabalho
@param 07 filterHWF, Logico  , Indica que deve buscar os centros de trabalho da tabela HWF.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET CENTROTRAB QUERYPARAM Filter, Page, PageSize, FilterIN, codigo, descricao, filterHWF WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodCT    := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodCT := Self:Filter
		Else
			cCodCT := Self:codigo
		EndIf

		aReturn := getCenTrab(cCodCT, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao, Self:filterHWF)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getCenTrab
Retorna os centros de trabalho para filtro da programação.
@type  Function
@author Lucas Fagundes
@since 16/03/2023
@version P12
@param 01 cFilter   , Caracter, Filtro dos centros de trabalho.
@param 02 nPage     , Numerico, Página que será carregado na tela.
@param 03 nPageSize , Numerico, Tamanho da página.
@param 04 lInFilter , Logico  , Indica que deve filtrar a query com IN.
@param 05 cDescCT   , Caracter, Filtra os centros de trabalho pela descrição.
@param 06 lFiltraHWF, Logico  , Indica que deve retornar os centro de trabalho da tabela HWF.
@return aReturn, Array, Array para return da API.
/*/
Function getCenTrab(cFilter, nPage, nPageSize, lInFilter, cDescCT, lFiltraHWF)
	Local aReturn    := Array(3)
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local lPagina    := .T.
	Local lAddBranco := .F.
	Local nCount     := 0
	Local nStart     := 0
	Local oReturn    := JsonObject():New()
	Local lEmBranco  := .F.

	Default nPage      := 1
	Default nPageSize  := 20
	Default lFiltraHWF := .F.

	If !Empty(cFilter)
		cFilter := getFilter(cFilter, @lEmBranco, lInFilter)
	EndIf

	oReturn["items"] := {}

	cQuery := " SELECT SHB.HB_COD  centroTrab, "
	cQuery +=        " SHB.HB_NOME descricaoCentroTrab "

	If lFiltraHWF
		cQuery +=  " , CASE WHEN EXISTS (SELECT 1 "
		cQuery +=                        " FROM " + RetSqlName("HWF") + " HWFb "
		cQuery +=                       " WHERE HWFb.HWF_FILIAL = '" + xFilial("HWF") + "' "
		cQuery +=                         " AND HWFb.HWF_CTRAB  = ' ' "
		cQuery +=                         " AND HWFb.D_E_L_E_T_ = ' ') "
		cQuery +=           " THEN 'S' "
		cQuery +=           " ELSE 'N' "
		cQuery +=     " END temBranco "
	EndIf

	cQuery +=   " FROM " + RetSqlName("SHB") + " SHB "
	cQuery +=  " WHERE SHB.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SHB.HB_FILIAL = '" + xFilial("SHB") + "' "

	If !Empty(cFilter)
		cQuery += " AND UPPER(SHB.HB_COD) " + cFilter
	EndIf

	If !Empty(cDescCT)
		cQuery += " AND UPPER(SHB.HB_NOME) " + getFilter(cDescCT, /*lEmBranco*/, lInFilter)
	EndIf

	If lFiltraHWF
		cQuery += " AND EXISTS (SELECT 1 "
		cQuery +=               " FROM " + RetSqlName("HWF") + " HWF "
		cQuery +=              " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
		cQuery +=                " AND HWF.HWF_CTRAB  = SHB.HB_COD "
		cQuery +=                " AND HWF.D_E_L_E_T_ = ' ') "
	EndIf

	cQuery += " ORDER BY centroTrab "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	/* Adiciona o centro de trabalho em branco quando:
	   1- Não estiver filtrando a tabela HWF e não estiver realizando outros filtros.
	   2- Não estiver filtrando a tabela HWF e estiver filtrando codigo em branco.
	   3- Estiver filtrando a tabela HWF e na tabela HWF houver registro com o centro de trabalho em branco.
	*/
	lAddBranco := (!lFiltraHWF .And. ((Empty(cFilter) .And. Empty(cDescCT)) .Or. lEmBranco)) .Or.;
	                lFiltraHWF .And. (cAlias)->temBranco == "S"

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )

		// Inicia um registro a menos da paginação devido ao centro de trabalho em branco adicionado na página 1.
		If lAddBranco
			nStart -= 1
		EndIf

		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	ElseIf lAddBranco
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["centroTrab"         ] := " "
		oReturn["items"][nCount]["descricaoCentroTrab"] := STR0140 // "Centro de trabalho em branco"
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["centroTrab"         ] := (cAlias)->centroTrab
		oReturn["items"][nCount]["descricaoCentroTrab"] := (cAlias)->descricaoCentroTrab

		(cAlias)->(dbSkip())
		If lPagina .And. nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getFilter
Monta condição para o IN dos filtros na query.
@type  Static Function
@author Lucas Fagundes
@since 23/03/2023
@version P12
@param 01 cFilter  , Caracter, String que vai coverter para fazer o IN na query.
@param 02 lEmBranco, Logico  , Retorna por referencia se está selecionado para filtrar valores em branco.
@param 03 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 04 cColuna  , Caracter, Coluna da tabela para formatar com o tamanho exato.
@return cCondQry, Caracter, Condição do filtro para a query.
/*/
Static Function getFilter(cFilter, lEmBranco, lInFilter, cColuna)
	Local aFiltro  := {}
	Local cCondQry := ""
	Local nIndex   := 0
	Local nTamCol  := 0
	Local nTotal   := 0
	Default cColuna := ""

	cFilter := Upper(cFilter)

	If lInFilter
		If !Empty(cColuna)
			nTamCol := GetSx3Cache(cColuna, "X3_TAMANHO")
		EndIf

		aFiltro := StrTokArr(cFilter, ",")
		nTotal  := Len(aFiltro)

		cCondQry := " IN ("

		For nIndex := 1 To nTotal
			If nTamCol > 0
				aFiltro[nIndex] := PadR(aFiltro[nIndex], nTamCol)
			EndIf

			If aFiltro[nIndex] == "' '"
				lEmBranco := .T.
				cCondQry += " ' ' "
			Else
				cCondQry += " '" + aFiltro[nIndex] + "' "
			EndIf

			If nIndex < nTotal
				cCondQry += ","
			EndIf
		Next

		cCondQry += " ) "

		aSize(aFiltro, 0)
	Else
		cCondQry := " LIKE '" + cFilter + "%' "
	EndIf

Return cCondQry

/*/{Protheus.doc} GET PRODUTOS /api/pcp/v1/pcpa152res/produtos
Retorna os produtos para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Filter   , Caracter, Filtro dos produtos.
@param 02 Page     , Numerico, Página que será carregado na tela.
@param 03 PageSize , Numerico, Tamanho da página.
@param 04 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 05 codigo   , Caracter, Filtro de produto.
@param 06 descricao, Caracter, Filtro de descrição.
@param 07 tipo     , Caracter, Filtro de tipo.
@param 08 grupo    , Caracter, Filtro de grupo.
@param 09 filterHWF, Logico  , Indica que deve buscar os produtos das ordens da tabela HWF.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET PRODUTOS QUERYPARAM Filter, Page, PageSize, FilterIN, codigo, descricao, tipo, grupo, filterHWF WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodProd  := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodProd := Self:Filter
		Else
			cCodProd := Self:codigo
		EndIf

		aReturn := getProds(cCodProd, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao, Self:tipo, Self:grupo, Self:filterHWF)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getProds
Retorna os produtos para exibir em tela.
@type  Static Function
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 cFilter   , Caracter, Filtro dos produtos.
@param 02 nPage     , Numerico, Página que será carregado na tela.
@param 03 nPageSize , Numerico, Tamanho da página.
@param 04 lInFilter , Logico  , Indica que deve filtrar a query com IN.
@param 05 cDesc     , Caracter, Filtro de descrição.
@param 06 cTipo     , Caracter, Filtro de tipo.
@param 07 cGrupo    , Caracter, Filtro de grupo.
@param 08 lFiltraHWF, Logico  , Indica que o produto deve existir em uma ordem de produção da tabela HWF.
@return aReturn, Array, Array para return da API.
/*/
Static Function getProds(cFilter, nPage, nPageSize, lInFilter, cDesc, cTipo, cGrupo, lFiltraHWF)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local lPagina := .T.
	Local nCount  := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	Default nPage      := 1
	Default nPageSize  := 20
	Default lFiltraHWF := .F.

	If !Empty(cFilter)
		cFilter := getFilter(cFilter, /*lEmBranco*/, lInFilter)
	EndIf

	oReturn["items"] := {}

	cQuery := " SELECT SB1.B1_COD  codProduto,  "
	cQuery +=        " SB1.B1_DESC descProduto, "
	cQuery +=        " SB1.B1_TIPO tipo,        "
	cQuery +=        " SB1.B1_GRUPO grupo       "
	cQuery +=   " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery +=  " WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "

	If !Empty(cFilter)
		cQuery += " AND UPPER(SB1.B1_COD) " + cFilter
	EndIf

	If !Empty(cDesc)
		cQuery += " AND UPPER(SB1.B1_DESC) " + getFilter(cDesc, /*lEmBranco*/, lInFilter)
	EndIf

	If !Empty(cTipo)
		cQuery += " AND UPPER(SB1.B1_TIPO) " + getFilter(cTipo, /*lEmBranco*/, .T.)
	EndIf

	If !Empty(cGrupo)
		cQuery += " AND UPPER(SB1.B1_GRUPO) " + getFilter(cGrupo, /*lEmBranco*/, .T.)
	EndIf

	If lFiltraHWF
		cQuery += " AND EXISTS (SELECT 1 "
		cQuery +=               " FROM " + RetSqlName("SC2") + " SC2 "
		cQuery +=              " INNER JOIN " + RetSqlName("HWF") + " HWF "
		cQuery +=                 " ON HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
		cQuery +=                " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
		cQuery +=                " AND HWF.D_E_L_E_T_ = ' ' "
		cQuery +=              " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
		cQuery +=                " AND SC2.C2_PRODUTO = SB1.B1_COD "
		cQuery +=                " AND SC2.D_E_L_E_T_ = ' ') "
	EndIf

	cQuery += " ORDER BY codProduto "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["codProduto" ] := (cAlias)->codProduto
		oReturn["items"][nCount]["descProduto"] := (cAlias)->descProduto
		oReturn["items"][nCount]["tipo"       ] := (cAlias)->tipo
		oReturn["items"][nCount]["grupo"      ] := (cAlias)->grupo

		(cAlias)->(dbSkip())
		If lPagina .And. nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET GRUPOS /api/pcp/v1/pcpa152res/grupos
Retorna os grupos de produto para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Filter   , Caracter, Filtro dos grupos.
@param 02 Page     , Numerico, Página que será carregado na tela.
@param 03 PageSize , Numerico, Tamanho da página.
@param 04 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 05 codigo   , Caracter, Filtro de código.
@param 06 descricao, Caracter, Filtro de descrição.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET GRUPOS QUERYPARAM Filter, Page, PageSize, FilterIN, codigo, descricao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodGrp   := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodGrp := Self:Filter
		Else
			cCodGrp := Self:codigo
		EndIf

		aReturn := getGrupos(cCodGrp, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getGrupos
Retorna os grupos de produto para exibir em tela.
@type  Static Function
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 cFilter  , Caracter, Filtro dos grupos.
@param 02 nPage    , Numerico, Página que será carregado na tela.
@param 03 nPageSize, Numerico, Tamanho da página.
@param 04 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 05 cDescGrp , Caracter, Filtro de descrição do grupo de produtos.
@return aReturn, Array, Array para return da API.
/*/
Static Function getGrupos(cFilter, nPage, nPageSize, lInFilter, cDescGrp)
	Local aReturn   := Array(3)
	Local cAlias    := GetNextAlias()
	Local cQuery    := ""
	Local lEmBranco := .F.
	Local lPagina   := .T.
	Local nCount    := 0
	Local nStart    := 0
	Local oReturn   := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	If !Empty(cFilter)
		cFilter := getFilter(cFilter, @lEmBranco, lInFilter)
	EndIf

	oReturn["items"  ] := {}

	cQuery := " SELECT BM_GRUPO  grupoProd, "
	cQuery +=        " BM_DESC   descGrupo "
	cQuery +=   " FROM " + RetSqlName("SBM")
	cQuery +=  " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=    " AND BM_FILIAL = '" + xFilial("SBM") + "' "

	If !Empty(cFilter)
		cQuery += " AND UPPER(BM_GRUPO) " + cFilter
	EndIf

	If !Empty(cDescGrp)
		cQuery += " AND UPPER(BM_DESC) " + getFilter(cDescGrp, /*lEmBranco*/, lInFilter)
	EndIf

	cQuery += " ORDER BY grupoProd "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )

		// Quando não houver filtro, inicia um registro a menos na paginação devido ao grupo em branco adicionado na página 1.
		If Empty(cFilter) .And. Empty(cDescGrp)
			nStart -= 1
		EndIf

		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf

	ElseIf (Empty(cFilter) .And. Empty(cDescGrp)) .Or. lEmBranco
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["grupoProd"] := " "
		oReturn["items"][nCount]["descGrupo"] := STR0176 // "Grupo em branco."
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["grupoProd"] := (cAlias)->grupoProd
		oReturn["items"][nCount]["descGrupo"] := (cAlias)->descGrupo

		(cAlias)->(dbSkip())
		If lPagina .And. nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET TIPOS /api/pcp/v1/pcpa152res/tipos
Retorna os tipos de produto para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Filter   , Caracter, Filtro dos tipos.
@param 02 Page     , Numerico, Página que será carregado na tela.
@param 03 PageSize , Numerico, Tamanho da página.
@param 04 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 05 codigo   , Caracter, Filtro de codigo.
@param 06 descricao, Caracter, Filtro de descrição.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET TIPOS QUERYPARAM Filter, Page, PageSize, FilterIN, codigo, descricao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodTipo  := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodTipo := Self:Filter
		Else
			cCodTipo := Self:codigo
		EndIf

		aReturn := getTipos(cCodTipo, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getTipos
Retorna os tipos de produto para exibir em tela.
@type  Static Function
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 cFilter  , Caracter, Filtro dos tipos.
@param 02 nPage    , Numerico, Página que será carregado na tela.
@param 03 nPageSize, Numerico, Tamanho da página.
@param 04 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 05 cDescTp  , Caracter, Filtra pela descrição do tipo.
@return aReturn, Array, Array para return da API.
/*/
Static Function getTipos(cFilter, nPage, nPageSize, lInFilter, cDescTp)
	Local aReturn    := Array(3)
	Local aTipos     := {}
	Local lFiltroCod := !Empty(cFilter)
	Local lFiltroDes := !Empty(cDescTp)
	Local lInsere    := .F.
	Local lPagina    := .T.
	Local nContFilt  := 0
	Local nIndex     := 1
	Local nInseridos := 0
	Local nStart     := 0
	Local nTotal     := 0
	Local oReturn    := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	oReturn["items"] := {}

	aTipos := FwGetSX5("02")
	nTotal := Len(aTipos)

	If lFiltroCod
		cFilter := Upper(cFilter)
	EndIf

	If lFiltroDes
		cDescTp := Upper(cDescTp)
	EndIf

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0 .And. (!lFiltroCod .And. !lFiltroDes)
			nIndex := nStart+1
		EndIf
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While nIndex <= nTotal .And. (!lPagina .Or. nInseridos < nPageSize)
		If !lFiltroCod .And. !lFiltroDes
			lInsere := .T.
		Else
			If lInFilter
				lInsere := (!lFiltroCod .Or. Upper(RTrim(aTipos[nIndex][3])) $ cFilter) .And.;
				           (!lFiltroDes .Or. Upper(RTrim(aTipos[nIndex][4])) $ cDescTp)
			Else
				lInsere := (!lFiltroCod .Or. "|" + cFilter $ "|" + Upper(aTipos[nIndex][3])) .And.;
				           (!lFiltroDes .Or. "|" + cDescTp $ "|" + Upper(aTipos[nIndex][4]))
			EndIf

			If lInsere
				nContFilt++
				lInsere := nContFilt > nStart
			EndIf
		EndIf

		If lInsere
			nInseridos++
			aAdd(oReturn["items"], JsonObject():New())
			oReturn["items"][nInseridos]["tipoProd"] := aTipos[nIndex][3]
			oReturn["items"][nInseridos]["descTipo"] := aTipos[nIndex][4]
		EndIf
		nIndex++
	End

	If lPagina
		oReturn["hasNext"] := nIndex < nTotal
	Else
		lInsere := .F.

		While nIndex <= nTotal
			If lInFilter
				lInsere := RTrim(aTipos[nIndex][3]) $ cFilter
			Else
				lInsere := "|" + cFilter $ "|" + aTipos[nIndex][3]
			EndIf
			nIndex++
		End

		oReturn["hasNext"] := lInsere
	EndIf

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
	FwFreeArray(aTipos)
Return aReturn

/*/{Protheus.doc} GET ORDENS /api/pcp/v1/pcpa152res/ordens
Retorna as ordens de producao para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Filter        , Caracter, Filtro dos tipos.
@param 02 Page          , Numerico, Página que será carregado na tela.
@param 03 PageSize      , Numerico, Tamanho da página.
@param 04 FilterIN      , Logico  , Indica que deve filtrar a query com IN.
@param 05 codigo        , Caracter, Filtro de codigo.
@param 06 produto       , Caracter, Filtro de produto.
@param 07 tipo          , Caracter, Filtro de tipo.
@param 08 DataInicial   , Date    , Filtro de data de inicio.
@param 09 DataFinal     , Date    , Filtro de data de entrega.
@param 10 PageFiltro    , Logico  , Indica se o filtro será paginado.
@param 11 filterHWF     , Logico  , Indica que deve buscar as ordens da tabela HWF.
@param 12 possuiAlocacao, Logico  , Indica que deve buscar apenas ordens com alocação.
@param 13 programacao   , Caracter, Fintro de programação.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET ORDENS QUERYPARAM Filter, Page, PageSize, FilterIN, codigo, produto, tipo, DataInicial, DataFinal, PageFiltro, filterHWF, possuiAlocacao, programacao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodOp    := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodOp := Self:Filter
		Else
			cCodOp := Self:codigo
		EndIf

		aReturn := getOrdens(cCodOp, Self:Page, Self:PageSize, Self:FilterIN, Self:programacao, Self:produto, Self:tipo, Self:DataInicial, Self:DataFinal, Self:PageFiltro, Self:filterHWF, Self:possuiAlocacao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getOrdens
Retorna as ordens de producao para exibir em tela.
@type  Static Function
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 cFilter   , Caracter, Filtro dos tipos.
@param 02 nPage     , Numerico, Página que será carregado na tela.
@param 03 nPageSize , Numerico, Tamanho da página.
@param 04 lInFilter , Logico  , Indica que deve filtrar a query com IN.
@param 05 cProg     , Caracter, Código da programação para fazer o filtro na tabela SMF.
@param 06 cProduto  , Caracter, Filtro de produto.
@param 07 cTipo     , Caracter, Filtro por tipo de ordem de produção.
@param 08 dDataIni  , Date    , Filtro de data inicial.
@param 09 dDataFim  , Date    , Filtro de data de entrega.
@param 10 lPagFilt  , Logico  , Indica se o filtro será paginado.
@param 11 lFiltraHWF, Logico  , Indica que deve verificar a existencia da ordem de produção na tabela HWF.
@param 12 lTemAloc  , Logico  , Indica que deve buscar apenas as ordens com alocação.
@return aReturn, Array, Array para return da API.
/*/
Static Function getOrdens(cFilter, nPage, nPageSize, lInFilter, cProg, cProduto, cTipo, dDataIni, dDataFim, lPagFilt, lFiltraHWF, lTemAloc)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cBanco  := TcGetDb()
	Local cQuery  := ""
	Local lPagina := .T.
	Local nCount  := 0
	Local nLimit  := 1000
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	Default nPage      := 1
	Default nPageSize  := 20
	Default lPagFilt   := .T.
	Default lFiltraHWF := .F.
	Default lTemAloc   := .F.

	If !Empty(cFilter)
		cFilter := getFilter(cFilter, /*lEmBranco*/, lInFilter)
	EndIf

	oReturn["items"] := {}

	cQuery := "SELECT SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD ordemProd, "
	cQuery +=        " SC2.C2_QUANT quant,    "
	cQuery +=        " SC2.C2_TPOP tipo,      "
	cQuery +=        " SC2.C2_DATPRI dataIni, "
	cQuery +=        " SC2.C2_DATPRF dataFim, "
	cQuery +=        " SC2.C2_PRODUTO produto "
	cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
	cQuery +=  " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "

	If !Empty(cFilter)
		If cBanco == "POSTGRES"
			cQuery += " AND UPPER(CONCAT(SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD)) " + cFilter
		Else
			cQuery += " AND UPPER(SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD) " + cFilter
		EndIf
	EndIf

	If !Empty(cProduto)
		cQuery += " AND UPPER(SC2.C2_PRODUTO) " + getFilter(cProduto, /*lEmBranco*/, .T.)
	EndIf

	If !Empty(cTipo)
		cQuery += " AND SC2.C2_TPOP " + getFilter(cTipo, /*lEmBranco*/, .T.)
	EndIf

	If !Empty(dDataIni)
		cQuery += " AND SC2.C2_DATPRI >= '" + DToS(dDataIni) + "' "
	EndIf

	If !Empty(dDataFim)
		cQuery += " AND SC2.C2_DATPRF <= '" + DToS(dDataFim) + "' "
	EndIf

	If !Empty(cProg)
		cQuery += " AND EXISTS(SELECT 1"
		cQuery +=              " FROM " + RetSqlName("SMF") + " SMF "
		If lTemAloc
			cQuery +=         " INNER JOIN " + RetSqlName("SVM") + " SVM "
			cQuery +=            " ON SVM.VM_FILIAL  = '" + xFilial("SVM") + "' "
			cQuery +=           " AND SVM.VM_PROG    = SMF.MF_PROG "
			cQuery +=           " AND SVM.VM_ID      = SMF.MF_ID "
			cQuery +=           " AND SVM.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery +=             " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
		cQuery +=               " AND SMF.MF_PROG    = '" + cProg + "' "
		cQuery +=               " AND " + PCPQrySC2("SC2", "SMF.MF_OP")
		cQuery +=               " AND SMF.D_E_L_E_T_ = ' ' )"
	EndIf

	If lFiltraHWF
		cQuery += " AND EXISTS (SELECT 1 "
		cQuery +=               " FROM " + RetSqlName("HWF") + " HWF "
		cQuery +=              " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
		cQuery +=                " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
		cQuery +=                " AND HWF.D_E_L_E_T_ = ' ') "
	EndIf

	If Empty(cProg) .Or. lFiltraHWF
		cQuery += " AND SC2.C2_DATRF = ' ' "
	EndIf

	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "

	cQuery += " ORDER BY ordemProd"

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["ordemProd"] := (cAlias)->ordemProd
		oReturn["items"][nCount]["quant"    ] := (cAlias)->quant
		oReturn["items"][nCount]["tipo"     ] := Iif((cAlias)->tipo == "F", STR0161 /*"Firme"*/, STR0162 /*"Prevista"*/)
		oReturn["items"][nCount]["dataIni"  ] := PCPConvDat((cAlias)->dataIni, 4)
		oReturn["items"][nCount]["dataFim"  ] := PCPConvDat((cAlias)->dataFim, 4)
		oReturn["items"][nCount]["produto"  ] := (cAlias)->produto

		(cAlias)->(dbSkip())
		If lPagina .And. nCount >= nPageSize
			If lPagFilt
				Exit

			ElseIf nCount == nLimit
				If (cAlias)->(!EoF())
					oReturn["_messages"] := {JsonObject():New()}
					oReturn["_messages"][1]["message"        ] := i18n(STR0453, {cValToChar(nLimit)}) //"Limite de registros atingido: serão consideradas somente os 1000 primeiros registros."
					oReturn["_messages"][1]["type"           ] := "information"
					oReturn["_messages"][1]["detailedMessage"] := i18n(STR0454, {cValToChar(nLimit)}) //"A consulta atingiu o limite máximo de registros que é de 1000. Restrinja mais a sua busca."
				EndIf
				Exit
			EndIf
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getDistrib
Retorna a distribuição das ordens de produção para exibir no gant.
@type  Static Function
@author Lucas Fagundes
@since 11/04/2023
@version P12
@param 01 cProg   , Caracter, Código da programação que está sendo consultada.
@param 02 oParams , Object  , Corpo da requisição com os filtros da busca.
@param 03 oUsoDisp, Object  , Retorna por referência o id das disponibilidades com alocação.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getDistrib(cProg, oParams, oUsoDisp)
	Local aReturn    := {}
	Local aTipos     := {}
	Local cAlias     := GetNextAlias()
	Local cBanco     := TcGetDb()
	Local cChaveDisp := ""
	Local cQuery     := ""
	Local oItem      := Nil
	Local oItemDisp  := Nil
	Local oLastAdd   := Nil
	Default oUsoDisp := JsonObject():New()

	aTipos := {cValToChar(VM_TIPO_SETUP), cValToChar(VM_TIPO_PRODUCAO), cValToChar(VM_TIPO_FINALIZACAO)}
	If oParams["tempoRemocao"]
		aAdd(aTipos, cValToChar(VM_TIPO_REMOCAO))
	EndIf

	cQuery := "SELECT SMF.MF_OP      ordem,"
	cQuery +=       " SMF.MF_OPER    operacao,"
	cQuery +=       " SMF.MF_RECURSO recurso,"
	cQuery +=       " SVM.VM_DATA    data,"
	cQuery +=       " SVM.VM_INICIO  horaInicio,"
	cQuery +=       " SVM.VM_FIM     horaFim,"
	cQuery +=       " SC2.C2_PRODUTO produto,"
	cQuery +=       " SMF.MF_ARVORE  arvore,"
	cQuery +=       " CASE SC2.C2_STATUS"
	cQuery +=          " WHEN 'S' THEN"
	cQuery +=             " COALESCE((SELECT DISTINCT 1"
	cQuery +=                         " FROM " + RetSqlName("HWF") + " HWF"
	cQuery +=                        " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "'"
	cQuery +=                          " AND HWF.HWF_OP     = SMF.MF_OP"
	cQuery +=                          " AND HWF.HWF_STATUS = '" + STATUS_ATIVO + "' "
	cQuery +=                          " AND HWF.D_E_L_E_T_ = ' '), 0)"
	cQuery +=          " ELSE"
	cQuery +=             " 0"
	cQuery +=       " END         status,"
	cQuery +=       " SVM.VM_TIPO tipo,"
	cQuery +=       " SVM.VM_DISP     idDisponibilidade, "
	cQuery +=       " SVM.VM_SEQDISP  seqDisponibilidade "
	cQuery +=  " FROM " + RetSqlName("SVM") + " SVM"
	cQuery += " INNER JOIN " + RetSqlName("SMF") + " SMF"
	cQuery +=    " ON SMF.MF_FILIAL  = '" + xFilial("SMF") + "'"
	cQuery +=   " AND SMF.MF_PROG    = SVM.VM_PROG"
	cQuery +=   " AND SMF.MF_ID      = SVM.VM_ID"
	cQuery +=   " AND SMF.D_E_L_E_T_ = ' '"

	If !Empty(oParams["recurso"])
		cQuery += " AND SMF.MF_RECURSO IN ('" + ArrToKStr(oParams["recurso"], "','") + "') "
	EndIf

	If !Empty(oParams["ordemProducao"])
		cQuery += " AND SMF.MF_OP IN ('" + ArrToKStr(oParams["ordemProducao"], "','") + "') "
	EndIf

	If !Empty(oParams["arvore"])
		cQuery += " AND SMF.MF_ARVORE IN ('" + ArrToKStr(oParams["arvore"], "','") + "') "
	EndIf

	If !Empty(oParams["horas"])
		cQuery += " INNER JOIN " + RetSqlName("SMK") + " SMK"
		cQuery +=    " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "'"
		cQuery +=   " AND SMK.MK_PROG    = SVM.VM_PROG"
		cQuery +=   " AND SMK.MK_DISP    = SVM.VM_DISP"
		cQuery +=   " AND SMK.MK_SEQ     = SVM.VM_SEQDISP"
		cQuery +=   " AND SMK.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SMK.MK_TIPO   IN (" + getInTipo(oParams["horas"]) + ")"
	EndIf

	cQuery += " INNER JOIN " + RetSqlName("SC2") + " SC2"
	cQuery +=    " ON " + PCPQrySC2("SC2", "SMF.MF_OP")
	cQuery +=   " AND SC2.C2_FILIAL   = '" + xFilial("SC2") + "'"
	cQuery +=   " AND SC2.D_E_L_E_T_  = ' '"

	If !Empty(oParams["produto"])
		cQuery += " AND SC2.C2_PRODUTO IN ('" + ArrToKStr(oParams["produto"], "','") + "') "
	EndIf

	If !Empty(oParams["tipo"]) .Or. !Empty(oParams["grupo"])
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "    ON SB1.B1_COD = SC2.C2_PRODUTO "

		If !Empty(oParams["grupo"])
			cQuery += " AND SB1.B1_GRUPO IN ('" + ArrToKStr(oParams["grupo"], "','") + "') "
		EndIf

		If !Empty(oParams["tipo"])
			cQuery += " AND SB1.B1_TIPO IN ('" + ArrToKStr(oParams["tipo"], "','") + "') "
		EndIf

		cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery += " WHERE SVM.VM_FILIAL   = '" + xFilial("SVM") + "'"
	cQuery +=   " AND SVM.VM_PROG     = '" + cProg + "'"
	cQuery +=   " AND SVM.VM_DATA    >= '" + PCPConvDat(oParams["dataInicio"], 6) + "'"
	cQuery +=   " AND SVM.VM_DATA     < '" + PCPConvDat(oParams["dataFim"], 6) + "'"
	cQuery +=   " AND SVM.VM_TIPO    IN (" + ArrToKStr(aTipos, ",") + ")"
	cQuery +=   " AND SVM.D_E_L_E_T_  = ' '"

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	cQuery += " ORDER BY recurso, data, horaInicio, ordem, operacao, tipo "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	TcSetField(cAlias, 'data', 'D', 8, 0)

	While (cAlias)->(!EoF())
		cChaveDisp := getChvDisp((cAlias)->idDisponibilidade, (cAlias)->seqDisponibilidade)
		oItem      := JsonObject():New()
		oItemDisp  := JsonObject():New()

		oItem["title"        ] := i18n(STR0181, {RTrim((cAlias)->ordem), RTrim((cAlias)->operacao), RTrim((cAlias)->produto)}) // "OP: #1[ordemProducao]#, Operação: #2[operacao]#, Produto: #3[produto]#"
		oItem["resourceId"   ] := RTrim((cAlias)->recurso)
		oItem["status"       ] := IIf((cAlias)->status == 1, 'E', 'N') //OP Efetivada pelo CRP
		oItem["ordemProducao"] := (cAlias)->ordem
		oItem["arvore"       ] := (cAlias)->arvore
		oItem["operacao"     ] := (cAlias)->operacao
		oItem["tipoAlocacao" ] := (cAlias)->tipo
		oItem["data"         ] := (cAlias)->data
		oItem["horaInicio"   ] := (cAlias)->horaInicio
		oItem["horaFim"      ] := (cAlias)->horaFim
		oItem["start"        ] := getDataJS((cAlias)->data, (cAlias)->horaInicio)
		oItem["end"          ] := getDataJS((cAlias)->data, (cAlias)->horaFim)
		oItem["folder"       ] := 'recursos'

		If !oUsoDisp:hasProperty(cChaveDisp)
			oUsoDisp[cChaveDisp] := {}
		EndIf

		oItemDisp:set(oItem)
		aAdd(oUsoDisp[cChaveDisp], oItemDisp)

		If oLastAdd != Nil .And. oParams["agrupaQuebras"] .And.;
		  (oItem["data"         ] == oLastAdd["data"         ] .And.;
		   oItem["horaInicio"   ] == oLastAdd["horaFim"      ] .And.;
		   oItem["resourceId"   ] == oLastAdd["resourceId"   ] .And.;
		   oItem["ordemProducao"] == oLastAdd["ordemProducao"] .And.;
		   oItem["operacao"     ] == oLastAdd["operacao"     ] .And.;
		   oItem["tipoAlocacao" ] == oLastAdd["tipoAlocacao" ])

			oLastAdd["horaFim"] := oItem["horaFim"]
			oLastAdd["end"    ] := getDataJS(oLastAdd["data"], oLastAdd["horaFim"])
		Else
			aAdd(aReturn, oItem)
			oLastAdd := oItem
		EndIf

		(cAlias)->(dbSkip())

		oItem     := Nil
		oItemDisp := Nil
	End
	(cAlias)->(dbCloseArea())

	oLastAdd := Nil
Return aReturn

/*/{Protheus.doc} GET PROGORDENS /api/pcp/v1/pcpa152res/ordens/{programacao}
Retorna as ordens de producao para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Programacao   , Caracter, Código da programação.
@param 02 Filter        , Caracter, Filtro dos tipos.
@param 03 Page          , Numerico, Página que será carregado na tela.
@param 04 PageSize      , Numerico, Tamanho da página.
@param 05 FilterIN      , Logico  , Indica que deve filtrar a query com IN.
@param 06 codigo        , Caracter, Filtro de código da op.
@param 07 produto       , Caracter, Filtro de produto.
@param 08 tipo          , Caracter, Filtro de tipo.
@param 09 DataInicial   , Date    , Filtro de data de inicio.
@param 10 DataFinal     , Date    , Filtro de data de entrega.
@param 11 PageFiltro    , Logico  , Indica se o filtro será paginado.
@param 12 filterHWF     , Logico  , Indica que deve buscar as ordens da tabela HWF.
@param 13 possuiAlocacao, Logico  , Indica que deve buscar apenas ordens com alocação.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET PROGORDENS PATHPARAM Programacao QUERYPARAM Filter, Page, PageSize, FilterIN, codigo, produto, tipo, DataInicial, DataFinal, PageFiltro, filterHWF, possuiAlocacao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodOP    := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodOP := Self:Filter
		Else
			cCodOP := Self:codigo
		EndIf

		aReturn := getOrdens(cCodOP, Self:Page, Self:PageSize, Self:FilterIN, Self:Programacao, Self:produto, Self:tipo, Self:DataInicial, Self:DataFinal, Self:PageFiltro, Self:filterHWF, Self:possuiAlocacao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} POST RECGANTT /api/pcp/v1/pcpa152res/{programacao}/recursos
Retorna os recursos de uma programação para exibir no gantt.

@type  WSMETHOD
@author Lucas Fagundes
@since 14/06/2023
@version P12
@param 01 Programacao     , Caracter, Código da programação.
@param 02 Page            , Numerico, Paginação dos recursos.
@param 03 PageSize        , Numerico, Tamanho da pagina de recursos.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD POST RECGANTT PATHPARAM Programacao QUERYPARAM Page, PageSize WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local cBody     := ""
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local oBody     := JsonObject():New()

	cBody := DecodeUTF8(Self:getContent())
	oBody:FromJson(cBody)

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := GetRecsDis(Self:Programacao, Self:Page, Self:PageSize, oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)
Return lReturn

/*/{Protheus.doc} GET PARAMETROS /api/pcp/v1/pcpa152res/{programacao}/parametros
Retorna os parâmetros de uma programação

@type  WSMETHOD
@author Lucas Fagundes
@since 11/07/2023
@version P12
@param Programacao, Caracter, Código da programação.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET PARAMETROS PATHPARAM Programacao WSSERVICE PCPA152RES
	Local aReturn := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getParams(Self:Programacao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getParams
Retorna os parâmetros de uma programação.
@type  Static Function
@author Lucas Fagundes
@since 11/07/2023
@version P12
@param cProg, Caracter, Código da programação.
@return aReturn, Array, Array para retorno da API
/*/
Static Function getParams(cProg)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cLista  := ""
	Local cParam  := ""
	Local cValor  := ""
	Local oReturn := JsonObject():New()

	oReturn["items"  ] := {}
	oReturn["hasNext"] := .F.

	T4X->(DbSetOrder(1))
	If !Empty(cProg) .And. T4X->(DbSeek(xFilial("T4X")+cProg))
		aAdd(oReturn["items"], getParInfo("usuario", T4X->T4X_USER, ""))
		aAdd(oReturn["items"], getParInfo("descricao", T4X->T4X_DESCRI, ""))

		BeginSql Alias cAlias
			SELECT T4Y_PARAM,
				T4Y_VALOR,
				T4Y_LISTA
			FROM %table:T4Y%
			WHERE T4Y_FILIAL = %xFilial:T4Y%
			AND T4Y_PROG   = %Exp:cProg%
			AND %notDel%
			ORDER BY T4Y_SEQ, T4Y_PARAM
		EndSql

		While (cAlias)->(!EoF())
			cParam := Trim((cAlias)->T4Y_PARAM)
			cValor := Trim((cAlias)->T4Y_VALOR)
			cLista := (cAlias)->T4Y_LISTA

			aAdd(oReturn["items"], getParInfo(cParam, cValor, cLista))

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

		aReturn[1] := .T.
		aReturn[2] := 200
	Else
		oReturn["message"        ] := STR0005 // "Programação não encontrada"
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
	EndIf
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getParInfo
Retorna as informações do parâmetro.
@type  Static Function
@author Lucas Fagundes
@since 11/07/2023
@version P12
@param 01 cParam, Caractere, Código do parâmetro
@param 02 cValor, Caractere, Valor do parâmetro.
@param 03 cLista, Caractere, Valor do parâmetro no campo lista.
@return oParam, Object, Json com as informações do parâmetro
/*/
Static Function getParInfo(cParam, cValor, cLista)
	Local oParam := JsonObject():New()
	Local aLista := StrTokArr(cLista, CHR(10))

	oParam["parametro"] := cParam

	If cParam == "usuario"
		oParam["descricao"] := STR0038 // "Usuario"
		oParam["label"    ] := UsrRetName(cValor)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "setup"
		oParam["descricao"] := STR0198 // "Setup"
		oParam["label"    ] := cValor
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "descricaoSetup"
		oParam["descricao"] := STR0201 // "Descrição do setup"
		oParam["label"    ] := cValor
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "dataInicial"
		oParam["descricao"] := STR0036 // "Data inicial"
		oParam["label"    ] := PCPConvDat(cValor, 3)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "dataFinal"
		oParam["descricao"] := STR0037 // "Data final"
		oParam["label"    ] := PCPConvDat(cValor, 3)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "dataRealFim"
		oParam["descricao"] := STR0413 // "Última alocação"
		oParam["label"    ] := PCPConvDat(cValor, 3)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "horaInicial"
		oParam["descricao"] := STR0081 // "Hora inicial"
		oParam["label"    ] := cValor
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "centroTrabalho"
		oParam["descricao"] := STR0145 // "Centro de trabalho"
		oParam["label"    ] := parLst2Str("centroTrabalho", aLista)
		oParam["detalhes" ] := Iif(!Empty(oParam["label"]), "viewDetail", "")
		oParam["valor"    ] := aLista

	ElseIf cParam == "recursos"
		oParam["descricao"] := STR0130 // "Recursos"
		oParam["label"    ] := parLst2Str("recursos", aLista)
		oParam["detalhes" ] := Iif(!Empty(oParam["label"]), "viewDetail", "")
		oParam["valor"    ] := aLista

	ElseIf cParam == "nivelamentoAutomatico"
		oParam["descricao"] := STR0246 // "Nivelamento Automático?"
		oParam["label"    ] := lblParBool(cValor, .F.)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Iif(cValor == "true", .T., .F.)

	ElseIf cParam == "tipoOP"
		oParam["descricao"] := STR0144 // "Tipo ordens de produção"
		oParam["label"    ] := lblParNum("tipoOP", cValor)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Val(cValor)

	ElseIf cParam == "ordemProducao"
		oParam["descricao"] := STR0163 // "Ordem de Produção"
		oParam["label"    ] := parLst2Str("ordemProducao", aLista)
		oParam["detalhes" ] := Iif(!Empty(oParam["label"]), "viewDetail", "")
		oParam["valor"    ] := aLista

	ElseIf cParam == "priorizacao"
		oParam["descricao"] := STR0146 // "Priorização"
		oParam["label"    ] := lblParNum("priorizacao", cValor)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Val(cValor)

	ElseIf cParam == "produto"
		oParam["descricao"] := STR0165 // "Produto"
		oParam["label"    ] := parLst2Str("produto", aLista)
		oParam["detalhes" ] := Iif(!Empty(oParam["label"]), "viewDetail", "")
		oParam["valor"    ] := aLista

	ElseIf cParam == "grupoProduto"
		oParam["descricao"] := STR0167 // "Grupo"
		oParam["label"    ] := parLst2Str("grupoProduto", aLista)
		oParam["detalhes" ] := Iif(!Empty(oParam["label"]), "viewDetail", "")
		oParam["valor"    ] := aLista

	ElseIf cParam == "tipoProduto"
		oParam["descricao"] := STR0169 // "Tipo"
		oParam["label"    ] := parLst2Str("tipoProduto", aLista)
		oParam["detalhes" ] := Iif(!Empty(oParam["label"]), "viewDetail", "")
		oParam["valor"    ] := aLista

	ElseIf cParam == "dataNivelamento"
		oParam["descricao"] := STR0290 // "Data nivelamento"
		oParam["label"    ] := lblParNum("dataNivelamento", cValor)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Val(cValor)

	ElseIf cParam == "replanejaSacramentadas"
		oParam["descricao"] := STR0366 // "Replaneja efetivadas?"
		oParam["label"    ] := lblParBool(cValor, .F.)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Iif(cValor == "true", .T., .F.)

	ElseIf cParam == "utiliza_shy"
		oParam["descricao"] := STR0409 // "Utiliza SHY"?"
		oParam["label"    ] := lblParBool(cValor, .F.)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Iif(cValor == "true", .T., .F.)

	ElseIf cParam == "existesfc"
		oParam["descricao"] := STR0410 // "Existe SFC"?"
		oParam["label"    ] := lblParBool(cValor, .F.)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Iif(cValor == "true", .T., .F.)

	ElseIf cParam == "descricao"
		oParam["descricao"] := STR0432 // "Descrição da programação"
		oParam["label"    ] := cValor
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "ticketMRP"
		oParam["descricao"] := STR0450 // "Ticket MRP"
		oParam["label"    ] := parLst2Str("ticketMRP", aLista)
		oParam["detalhes" ] := Iif(!Empty(oParam["label"]), "viewDetail", "")
		oParam["valor"    ] := aLista

	ElseIf cParam == "quebraOperacoes"
		oParam["descricao"] := STR0460 // "Permite quebra das operações"
		oParam["label"    ] := lblParBool(cValor, .F.)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Iif(cValor == "true", .T., .F.)

	ElseIf cParam == "tipoAlternativo"
		oParam["descricao"] := STR0580 // "Uso dos alternativos"
		oParam["label"    ] := lblParNum(cParam, cValor)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Val(cValor)

	ElseIf cParam == "ordensAtrasadas"
		oParam["descricao"] := STR0590 // "Considera ordens atrasadas?"
		oParam["label"    ] := lblParBool(cValor, .F.)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Val(cValor)

	ElseIf cParam == "ajustaCompras"
		oParam["descricao"] := STR0642 // "Ajusta compras?"
		oParam["label"    ] := lblParBool(cValor, .F.)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Val(cValor)

	ElseIf cParam == "dataFimDisponibilidade"
		oParam["descricao"] := STR0661 // "Data final do calculo da disponibilidade"
		oParam["label"    ] := PCPConvDat(cValor, 3)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	ElseIf cParam == "utilizaFerramentas"
		oParam["descricao"] := STR0676 // "Utiliza ferramentas?"
		oParam["label"    ] := lblParBool(cValor, .F.)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := cValor

	Else
		oParam["descricao"] := cParam
		oParam["label"    ] := Iif(Empty(cLista), cValor, cLista)
		oParam["detalhes" ] := ""
		oParam["valor"    ] := Iif(Empty(aLista), cValor, aLista)

		If SubStr(cParam, 1, 3) == "MV_"
			oParam["descricao"] := GetDescMV(cParam)

			If cParam $ "|MV_PERDINF|MV_PCPATOR|MV_LOGCRP|"
				oParam["label"] := lblParBool(cValor, .T.)

			ElseIf cParam == "MV_TPHR"
				oParam["label"] := Iif(cValor == "N", STR0256, Iif(cValor == "C", STR0257, cValor)) // "N = Normal" "C = Centesimal"

			EndIf
		EndIf
	EndIf

Return oParam

/*/{Protheus.doc} parLst2Str
Converte um parâmetro do tipo lista para string.
@type  Static Function
@author Lucas Fagundes
@since 11/07/2023
@version P12
@param cParam, Caractere, Código do parâmetro
@param aLista, Array    , Conteudo do parâmetro em formato de lista.
@return cLsStr, Caracter, Conteudo do parâmetro convertido para string.
/*/
Static Function parLst2Str(cParam, aLista)
	Local cLsStr := ""
	Local nIndex := 1
	Local nTotal := Len(aLista)

	For nIndex := 1 To nTotal

		If Empty(aLista[nIndex])
			If cParam == "centroTrabalho"
				cLsStr += STR0140 // "Centro de trabalho em branco"
			ElseIf cParam == "grupoProduto"
				cLsStr += STR0176 // "Grupo em branco."
			EndIf
		Else
			cLsStr += Trim(aLista[nIndex])
		EndIf

		If nIndex < nTotal
			cLsStr += ", "
		EndIf
	Next

Return cLsStr

/*/{Protheus.doc} lblParNum
Retorna a label dos parâmetros númericos
@type  Static Function
@author Lucas Fagundes
@since 11/07/2023
@version P12
@param 01 cParam, Caractere, Código do parâmetro
@param 02 cValor, Caractere, Valor do parâmetro.
@return cLabel, Caractere, Label para o valor do parâmetro
/*/
Static Function lblParNum(cParam, cValor)
	Local nValor := Val(cValor)
	Local cLabel := cValor

	If cParam == "tipoOP"
		If nValor == PARAM_TIPO_OP_FIRMES
			cLabel := STR0148 // "Firmes"
		ElseIf nValor == PARAM_TIPO_OP_PREVISTAS
			cLabel := STR0149 // "Previstas"
		ElseIf nValor == PARAM_TIPO_OP_AMBAS
			cLabel := STR0150 // "Ambas"
		EndIf
	ElseIf cParam == "priorizacao"
		If nValor == PARAM_PRIORIZACAO_DATA_INICIO
			cLabel := STR0151 // "Data de início"
		ElseIf nValor == PARAM_PRIORIZACAO_DATA_ENTREGA
			cLabel := STR0152 // "Data de entrega"
		EndIf
	ElseIf cParam == "dataNivelamento"
		If nValor == PARAM_DATA_NIV_DAT_OP
			cLabel := STR0292 // "Data da ordem de produção"
		ElseIf nValor == PARAM_DATA_NIV_DAT_PRG
			cLabel := STR0294 // "Data da programação"
		EndIf
	ElseIf cParam == "tipoAlternativo"
		If nValor == TIPO_ALTERNATIVO_POR_ALOCACAO
			cLabel := STR0581 // "Melhor data de início/entrega"
		ElseIf nValor == TIPO_ALTERNATIVO_POR_TEMPO
			cLabel := STR0582 //"Melhor tempo"
		EndIf
	EndIf

Return cLabel

/*/{Protheus.doc} lblParBool
Retorna label para os parâmetro do tipo booleano
@type  Static Function
@author Lucas Fagundes
@since 11/07/2023
@version P12
@param 01 cValor, Caractere, Valor do parâmetro
@param 02 lMV   , Logico   , Indica que é um parâmetro MV
@return cLabel, Caractere, Label do parâmetro
/*/
Static Function lblParBool(cValor, lMV)
	Local cLabel := cValor

	If cValor == "true"
		cLabel := Iif(lMV, STR0258, STR0050) // "Verdadeiro" "Sim"
	ElseIf cValor == "false"
		cLabel := Iif(lMV, STR0259, STR0049) // "Falso" "Não"
	EndIf

Return cLabel

/*/{Protheus.doc} GetDescMV
Função para trazer a descrição do parametro MV

@type  Static Function
@author Lucas Fagundes
@since 11/07/2023
@version P12
@param cParam, Character, Código do parâmetro
@return cParDesc, caracter, descrição do parametro
/*/
Static Function GetDescMV(cParam)
	Local cParDesc := ""

	If FWSX6Util():ExistsParam( cParam )
		GetMV(cParam)

		cParDesc := StrTran(x6Descric() + " ", "  ", " ")
		cParDesc += StrTran(x6Desc1() + " " , "  ", " ")
		cParDesc += x6Desc2()
		cParDesc := cParam + ": " + StrTran(AllTrim(cParDesc), "  ", " ")

		If "- " $ cParDesc .And. Substr(cParDesc,  At("- ", cParDesc) - 1, 1) != " "
			cParDesc := StrTran(AllTrim(cParDesc), "- ", "")
		EndIf
	Else
		cParDesc := cParam
	EndIf

Return cParDesc

/*/{Protheus.doc} GET ARVORE /api/pcp/v1/pcpa152res/{programacao}/arvore/{ordemProducao}
Retorna a árvore com todas as ordens a partir do número de uma ordem de produção.

@type  WSMETHOD
@author Lucas Fagundes
@since 02/08/2023
@version P12
@param 01 programacao  , Caracter, Código da programação
@param 02 ordemProducao, Caracter, Código da ordem de produção que irá buscar a árvore.
@param 03 arvore       , Caracter, Código da árvore.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET ARVORE PATHPARAM programacao, ordemProducao QUERYPARAM arvore WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getArvore(Self:programacao, Self:arvore, Self:ordemProducao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getArvore
Busca as ordens de produção de uma árvore.
@type  Static Function
@author Lucas Fagundes
@since 02/08/2023
@version P12
@param 01 cProg  , Caracter, Código da programação.
@param 02 cArvore, Caracter, Código da árvore que irá buscar.
@param 03 cCodOp , Caracter, Código da ordem de produção.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getArvore(cProg, cArvore, cCodOp)
	Local aReturn := Array(3)
	Local cAlias  := ""
	Local cOpPai  := ""
	Local cQuery  := ""
	Local lOpPai  := .T.
	Local oFilhas := JsonObject():New()
	Local oInfoOp := Nil
	Local oReturn := JsonObject():New()
	Default cArvore := ""

	If _oQryArvor == Nil
		_oQryArvor := FwExecStatement():New()

		cQuery += " SELECT DISTINCT SMF.MF_OP, "
		cQuery +=                 " SC2.C2_SEQUEN, "
		cQuery +=                 " SC2.C2_PRODUTO, "
		cQuery +=                 " CASE C2_SEQPAI "
		cQuery +=                 "     WHEN ' ' THEN C2_SEQPAI "
		cQuery +=                 "     ELSE SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQPAI||SC2.C2_ITEMGRD "
		cQuery +=                 " END opPai "

		cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
		cQuery +=   " INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery +=      " ON RTRIM(SMF.MF_OP) = RTRIM(SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD) "
		cQuery +=     " AND SC2.C2_FILIAL  = ? "
		cQuery +=     " AND SC2.D_E_L_E_T_ = ' ' "

		cQuery +=   " WHERE SMF.MF_FILIAL  = ? "
		cQuery +=     " AND SMF.MF_PROG    = ? "
		cQuery +=     " AND ((SMF.MF_ARVORE != ' ' AND SMF.MF_ARVORE = ?) "
		cQuery +=       " OR (SMF.MF_ARVORE  = ' ' AND SMF.MF_OP     = ?)) "
		cQuery +=     " AND SMF.D_E_L_E_T_ = ' ' "

		cQuery +=   " ORDER BY SC2.C2_SEQUEN "

		If "MSSQL" $ TcGetDb()
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryArvor:setQuery(cQuery)
	EndIf

	_oQryArvor:setString(1, xFilial("SC2")) // C2_FILIAL
	_oQryArvor:setString(2, xFilial("SMF")) // MF_FILIAL
	_oQryArvor:setString(3, cProg         ) // MF_PROG
	_oQryArvor:setString(4, cArvore       ) // MF_ARVORE
	_oQryArvor:setString(5, cCodOp        ) // MF_OP

	cAlias := _oQryArvor:openAlias()

	oReturn["items"  ] := {}
	oReturn["hasNext"] := .F.

	While (cAlias)->(!EoF())
		oInfoOp := JsonObject():New()

		oInfoOp["ordemProducao"] := (cAlias)->MF_OP
		oInfoOp["label"        ] := i18n("#1[ordem]# - #2[produto]#", {Trim((cAlias)->MF_OP), Trim((cAlias)->C2_PRODUTO)})

		If !oFilhas:hasProperty(oInfoOp["ordemProducao"])
			oFilhas[oInfoOp["ordemProducao"]] := {}
		EndIf
		oInfoOp["ordensFilhas"] := oFilhas[oInfoOp["ordemProducao"]]

		If lOpPai
			lOpPai := .F.

			aAdd(oReturn["items"], oInfoOp)
		Else
			cOpPai := (cAlias)->opPai

			aAdd(oFilhas[cOpPai], oInfoOp)
		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If Empty(oReturn["items"])
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
	Else
		aReturn[1] := .T.
		aReturn[2] := 200
	EndIf
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oFilhas )
	FwFreeObj(oInfoOp )
	FwFreeObj(oReturn )
Return aReturn

/*/{Protheus.doc} GET ORDEM /api/pcp/v1/pcpa152res/{programacao}/ordem/{ordemProducao}
Retorna as informações de uma ordem de produção

@type  WSMETHOD
@author Lucas Fagundes
@since 02/08/2023
@version P12
@param 01 programacao  , Caracter, Código da programação.
@param 02 ordemProducao, Caracter, Código da ordem de producao.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET ORDEM PATHPARAM programacao, ordemProducao WSSERVICE PCPA152RES
	Local aReturn := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getInfoOp(Self:programacao, Self:ordemProducao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getInfoOp
Retorna as informações de uma ordem de produção
@type  Static Function
@author Lucas Fagundes
@since 02/08/2023
@version P12
@param 01 cProg , Caracter, Código da programação.
@param 02 cCodOp, Caracter, Código da ordem de producao.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getInfoOp(cProg, cCodOp)
	Local aReturn := Array(3)
	Local cAlias  := ""
	Local cQuery  := ""
	Local oReturn := JsonObject():New()

	If _oQryInfOp == Nil
		_oQryInfOp := FwExecStatement():New()

		cQuery += " SELECT SMF.MF_OP, "
		cQuery += "        SC2.C2_PRODUTO, "
		cQuery += "        SB1.B1_DESC, "
		cQuery += "        SC2.C2_QUANT, "
		cQuery += "        CASE T4Y.T4Y_VALOR "
		cQuery += "            WHEN 'true' THEN SC2.C2_QUANT-SC2.C2_QUJE-SC2.C2_PERDA "
		cQuery += "            ELSE SC2.C2_QUANT-SC2.C2_QUJE "
		cQuery += "        END saldo, "
		cQuery += "        SMF.MF_DTINI, "
		cQuery += "        SMF.MF_DTENT, "
		cQuery += "        SMF.MF_PRIOR, "
		cQuery += "        SMF.MF_ROTEIRO, "
		cQuery += "        (SELECT SUM(SVM.VM_TEMPO) "
		cQuery += "           FROM " + RetSqlName("SMF") + " SMF2 "
		cQuery += "          INNER JOIN " + RetSqlName("SVM") + " SVM "
		cQuery += "             ON SVM.VM_FILIAL  = ? "
		cQuery += "            AND SVM.VM_PROG    = SMF2.MF_PROG "
		cQuery += "            AND SVM.VM_ID      = SMF2.MF_ID "
		cQuery += "            AND SVM.D_E_L_E_T_ = ' ' "
		cQuery += "          WHERE SMF2.MF_FILIAL  = SMF.MF_FILIAL "
		cQuery += "            AND SMF2.MF_PROG    = SMF.MF_PROG "
		cQuery += "            AND SMF2.MF_OP      = SMF.MF_OP "
		cQuery += "            AND SMF2.D_E_L_E_T_ = ' ') tempoTotal "

		cQuery += "   FROM " + RetSqlName("SMF") + " SMF "

		cQuery += "  INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery += "     ON " + PCPQrySC2("SC2", "SMF.MF_OP")
		cQuery += "    AND SC2.C2_FILIAL    =  ?  "
		cQuery += "    AND SC2.D_E_L_E_T_   = ' ' "

		cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "     ON SB1.B1_COD     = SC2.C2_PRODUTO "
		cQuery += "    AND SB1.B1_FILIAL  =  ?  "
		cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "

		cQuery += "  INNER JOIN " + RetSqlName("T4Y") + " T4Y "
		cQuery += "     ON T4Y.T4Y_PROG   = SMF.MF_PROG  "
		cQuery += "    AND T4Y.T4Y_PARAM  = 'MV_PERDINF' "
		cQuery += "    AND T4Y.T4Y_FILIAL =  ?  "
		cQuery += "    AND T4Y.D_E_L_E_T_ = ' ' "

		cQuery += "  WHERE SMF.MF_FILIAL  =  ?  "
		cQuery += "    AND SMF.MF_PROG    =  ?  "
		cQuery += "    AND SMF.MF_PRIOR   = (SELECT MIN(SMFPrior.MF_PRIOR) "
		cQuery += "                            FROM " + RetSqlName("SMF") + " SMFPrior "
		cQuery += "                           WHERE SMFPrior.MF_FILIAL = ? "
		cQuery += "                             AND SMFPrior.MF_PROG   = ? "
		cQuery += "                             AND SMFPrior.MF_OP     = ?) "
		cQuery += "    AND SMF.D_E_L_E_T_ = ' ' "

		If "MSSQL" $ TcGetDb()
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryInfOp:setQuery(cQuery)
	EndIf

	_oQryInfOp:setString(1, xFilial("SVM")) // VM_FILIAL
	_oQryInfOp:setString(2, xFilial("SC2")) // C2_FILIAL
	_oQryInfOp:setString(3, xFilial("SB1")) // B1_FILIAL
	_oQryInfOp:setString(4, xFilial("T4Y")) // T4Y_FILIAL
	_oQryInfOp:setString(5, xFilial("SMF")) // MF_FILIAL
	_oQryInfOp:setString(6, cProg         ) // MF_PROG
	_oQryInfOp:setString(7, xFilial("SMF")) // MF_FILIAL
	_oQryInfOp:setString(8, cProg         ) // MF_PROG
	_oQryInfOp:setString(9, cCodOp        ) // MF_OP

	cAlias := _oQryInfOp:openAlias()

	oReturn["items"  ] := {}
	oReturn["hasNext"] := .F.

	If (cAlias)->(!Eof())
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][1]["ordemProducao"  ] := Trim((cAlias)->MF_OP)
		oReturn["items"][1]["produto"        ] := i18n("#1[produto]# - #2[descricao]#", {Trim((cAlias)->C2_PRODUTO), Trim((cAlias)->B1_DESC)})
		oReturn["items"][1]["quantidade"     ] := (cAlias)->C2_QUANT
		oReturn["items"][1]["saldo"          ] := (cAlias)->saldo
		oReturn["items"][1]["data"           ] := PCPConvDat((cAlias)->MF_DTINI, 4) + " - " + PCPConvDat((cAlias)->MF_DTENT, 4)
		oReturn["items"][1]["prioridade"     ] := Val((cAlias)->MF_PRIOR)
		oReturn["items"][1]["roteiro"        ] := (cAlias)->MF_ROTEIRO
		oReturn["items"][1]["tempoTotal"     ] := __Min2Hrs((cAlias)->tempoTotal, .T.)
	EndIf
	(cAlias)->(dbCloseArea())

	If Empty(oReturn["items"])
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
	Else
		aReturn[1] := .T.
		aReturn[2] := 200
	EndIf
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn )
Return aReturn

/*/{Protheus.doc} GET OPERACOES /api/pcp/v1/pcpa152res/{programacao}/operacoes/{ordemProducao}
Retorna as operações de uma ordem de produção

@type  WSMETHOD
@author Lucas Fagundes
@since 03/08/2023
@version P12
@param 01 programacao  , Caracter, Código da programação.
@param 02 ordemProducao, Caracter, Código da ordem de producao.
@param 03 Page         , Numerico, Pagina da tela.
@param 04 PageSize     , Numerico, Quantidades de registro por paginação.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET OPERACOES PATHPARAM programacao, ordemProducao QUERYPARAM Page, PageSize WSSERVICE PCPA152RES
	Local aReturn := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOperOP(Self:programacao, Self:ordemProducao, Self:Page, Self:PageSize)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getOperOP
Busca as operações de uma ordem de produção.
@type  Static Function
@author Lucas Fagundes
@since 03/08/2023
@version P12
@param 01 cProg    , Caracter, Código da programação.
@param 02 cCodOrdem, Caracter, Código da ordem de producao.
@param 03 nPage    , Numerico, Pagina da tela.
@param 04 nPageSize, Numerico, Quantidades de registro por paginação.
@return aReturn, Array, Array com as informações de retorno da API
/*/
Static Function getOperOP(cProg, cCodOrdem, nPage, nPageSize)
	Local aReturn := Array(3)
	Local cAlias  := ""
	Local cBanco  := TcGetDb()
	Local cFilSVM := xFilial("SVM")
	Local cQuery  := ""
	Local nCont   := 0
	Local nParam  := 1
	Local nStart  := 0
	Local oItem   := Nil
	Local oReturn := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	If _oQryOper == Nil
		_oQryOper := FwExecStatement():New()

		cQuery += " SELECT SMF.MF_OPER, "
		cQuery += "        COALESCE(SHY.HY_DESCRI,SG2.G2_DESCRI) AS G2_DESCRI, "
		cQuery += "        SMF.MF_RECURSO, "
		cQuery += "        SH1.H1_DESCRI, "
		cQuery += "        SMF.MF_CTRAB, "
		cQuery += "        SHB.HB_NOME, "
		cQuery += "        SMF.MF_SALDO, "
		cQuery += "        svmMenor.VM_DATA dataInicial, "
		cQuery += "        svmMenor.VM_INICIO horaInicial, "
		cQuery += "        svmMaior.VM_DATA dataFinal, "
		cQuery += "        svmMaior.VM_FIM horaFinal, "
		cQuery += "        COALESCE((SELECT SUM(SVMProd.VM_TEMPO) "
		cQuery += "                    FROM " + RetSqlName("SVM") + " SVMProd "
		cQuery += "                   WHERE SVMProd.VM_FILIAL  = ? "
		cQuery += "                     AND SVMProd.VM_PROG    = SMF.MF_PROG "
		cQuery += "                     AND SVMProd.VM_ID      = SMF.MF_ID "
		cQuery += "                     AND SVMProd.VM_TIPO    = " + cValToChar(VM_TIPO_PRODUCAO)
		cQuery += "                     AND SVMProd.D_E_L_E_T_ = ' '), 0) tempoProd, "
		cQuery += "        COALESCE((SELECT SUM(SVMSetup.VM_TEMPO) "
		cQuery += "                    FROM " + RetSqlName("SVM") + " SVMSetup "
		cQuery += "                   WHERE SVMSetup.VM_FILIAL  = ? "
		cQuery += "                     AND SVMSetup.VM_PROG    = SMF.MF_PROG "
		cQuery += "                     AND SVMSetup.VM_ID      = SMF.MF_ID "
		cQuery += "                     AND SVMSetup.VM_TIPO    = " + cValToChar(VM_TIPO_SETUP)
		cQuery += "                     AND SVMSetup.D_E_L_E_T_ = ' '), 0) tempoSetup, "
		cQuery += "        SMF.MF_TMPFINA, "
		If dicCampo("MF_SOBREPO")
			cQuery +=   " SMF.MF_SOBREPO, "
		EndIf
		If possuiHZ7()
			cQuery +=   " HZ7.HZ7_SEQ, "
		EndIf
		If dicCampo("MF_REMOCAO")
			cQuery +=   " SMF.MF_REMOCAO, "
		EndIf

		cQuery +=       " COALESCE((SELECT " + Iif("MSSQL" $ cBanco, " TOP 1 ", "") + " SMR.MR_SITUACA "
		cQuery +=                   " FROM " + RetSqlName("SMR") + " SMR "
		cQuery +=                  " WHERE SMR.MR_FILIAL  =  ? "
		cQuery +=                    " AND SMR.MR_PROG    = SMF.MF_PROG "
		cQuery +=                    " AND SMR.MR_RECURSO = SMF.MF_RECURSO "
		cQuery +=                    " AND SMR.MR_TIPO	 =  '" + MR_TIPO_RECURSO + "' "
		If cBanco == "ORACLE"
			cQuery +=                " AND ROWNUM = 1 "
		EndIf
		cQuery +=                    " AND SMR.D_E_L_E_T_ = ' ' "
		If cBanco == "POSTGRES"
			cQuery +=              " LIMIT 1 "
		EndIf
		cQuery +=                 "), '" + RECURSO_NAO_ILIMITADO + "') recursoIlimitado "

		cQuery += "   FROM " + RetSqlName("SMF") + " SMF "

		cQuery += "  INNER JOIN " + RetSqlName("SH1") + " SH1 "
		cQuery += "     ON SH1.H1_FILIAL  = ? "
		cQuery += "    AND SH1.H1_CODIGO  = SMF.MF_RECURSO "
		cQuery += "    AND SH1.D_E_L_E_T_ = ' ' "

		cQuery += "  INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery += "     ON " + PCPQrySC2("SC2", "SMF.MF_OP")
		cQuery += "    AND SC2.C2_FILIAL  =  ?  "
		cQuery += "    AND SC2.D_E_L_E_T_ = ' ' "

		If possuiHZ7()
			cQuery += " INNER JOIN " + RetSqlName("HZ7") + " HZ7 "
			cQuery +=    " ON HZ7.HZ7_FILIAL = ? "
			cQuery +=   " AND HZ7.HZ7_PROG   = SMF.MF_PROG "
			cQuery +=   " AND HZ7.HZ7_ID     = SMF.MF_ID "
			cQuery +=   " AND HZ7.HZ7_RECURS = SMF.MF_RECURSO "
			cQuery +=   " AND HZ7.D_E_L_E_T_ = ' ' "
		EndIf

		cQuery += "  LEFT JOIN " + RetSqlName("SG2") + " SG2 "
		cQuery += "     ON SG2.G2_FILIAL  = ? "
		cQuery += "    AND SG2.G2_CODIGO  = SMF.MF_ROTEIRO "
		cQuery += "    AND SG2.G2_OPERAC  = SMF.MF_OPER "
		cQuery += "    AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
		cQuery += "    AND SG2.D_E_L_E_T_ = ' ' "

		cQuery += "  LEFT JOIN " + RetSqlName("SHY") + " SHY "
		cQuery += "     ON SHY.HY_FILIAL  = ? "
		cQuery += "    AND SHY.HY_OP      = ? "
		cQuery += "    AND SHY.HY_ROTEIRO = SMF.MF_ROTEIRO "
		cQuery += "    AND SHY.HY_OPERAC  = SMF.MF_OPER "
		cQuery += "    AND SHY.HY_TEMPAD <> 0 "
		cQuery += "    AND SHY.D_E_L_E_T_ = ' ' "

		cQuery += "  LEFT JOIN " + RetSqlName("SHB") + " SHB "
		cQuery += "     ON SHB.HB_FILIAL  = ? "
		cQuery += "    AND SHB.HB_COD     = SMF.MF_CTRAB "
		cQuery += "    AND SHB.D_E_L_E_T_ = ' ' "

		cQuery += "   LEFT JOIN " + RetSqlName("SVM") + " svmMenor "
		cQuery += "     ON svmMenor.VM_FILIAL  = ? "
		cQuery += "    AND svmMenor.VM_PROG    = SMF.MF_PROG "
		cQuery += "    AND svmMenor.VM_ID      = SMF.MF_ID "
		cQuery += "    AND svmMenor.D_E_L_E_T_ = ' ' "
		cQuery += "    AND svmMenor.VM_SEQ     = (SELECT MIN(SVM1.VM_SEQ) "
		cQuery += "                                 FROM " + RetSqlName("SVM") + " SVM1 "
		cQuery += "                                WHERE SVM1.VM_FILIAL  = svmMenor.VM_FILIAL "
		cQuery += "                                  AND SVM1.VM_PROG    = svmMenor.VM_PROG   "
		cQuery += "                                  AND SVM1.VM_ID      = svmMenor.VM_ID     "
		cQuery += "                                  AND SVM1.D_E_L_E_T_ = ' ') "

		cQuery += "   LEFT JOIN " + RetSqlName("SVM") + " svmMaior "
		cQuery += "     ON svmMaior.VM_FILIAL  = ? "
		cQuery += "    AND svmMaior.VM_PROG    = SMF.MF_PROG "
		cQuery += "    AND svmMaior.VM_ID      = SMF.MF_ID "
		cQuery += "    AND svmMaior.D_E_L_E_T_ = ' ' "
		cQuery += "    AND svmMaior.VM_SEQ     = (SELECT MAX(SVM2.VM_SEQ) "
		cQuery += "                                 FROM " + RetSqlName("SVM") + " SVM2 "
		cQuery += "                                WHERE SVM2.VM_FILIAL  = svmMaior.VM_FILIAL "
		cQuery += "                                  AND SVM2.VM_PROG    = svmMaior.VM_PROG   "
		cQuery += "                                  AND SVM2.VM_ID      = svmMaior.VM_ID     "
		cQuery += "                                  AND SVM2.D_E_L_E_T_ = ' ') "

		cQuery += "  WHERE SMF.MF_FILIAL  =  ? "
		cQuery += "    AND SMF.MF_PROG    =  ? "
		cQuery += "    AND SMF.MF_OP      =  ? "
		cQuery += "    AND SMF.D_E_L_E_T_ = ' ' "

		cQuery += " ORDER BY SMF.MF_OPER "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryOper:setQuery(cQuery)
	EndIf

	_oQryOper:setString(nParam++, cFilSVM       ) // VM_FILIAL
	_oQryOper:setString(nParam++, cFilSVM       ) // VM_FILIAL
	_oQryOper:setString(nParam++, xFilial("SMR")) // H1_FILIAL
	_oQryOper:setString(nParam++, xFilial("SH1")) // H1_FILIAL
	_oQryOper:setString(nParam++, xFilial("SC2")) // C2_FILIAL
	If possuiHZ7()
		_oQryOper:setString(nParam++, xFilial("HZ7")) // HZ7_FILIAL
	EndIf
	_oQryOper:setString(nParam++, xFilial("SG2")) // G2_FILIAL
	_oQryOper:setString(nParam++, xFilial("SHY")) // HY_FILIAL
	_oQryOper:setString(nParam++, cCodOrdem     ) // HY_OP
	_oQryOper:setString(nParam++, xFilial("SHB")) // HB_FILIAL
	_oQryOper:setString(nParam++, cFilSVM       ) // VM_FILIAL
	_oQryOper:setString(nParam++, cFilSVM      ) // VM_FILIAL
	_oQryOper:setString(nParam++, xFilial("SMF")) // MF_FILIAL
	_oQryOper:setString(nParam++, cProg         ) // MF_PROG
	_oQryOper:setString(nParam++, cCodOrdem     ) // MF_OP

	cAlias := _oQryOper:openAlias()

	oReturn["items"  ] := {}
	oReturn["hasNext"] := .F.

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	While (cAlias)->(!EoF())
		oItem := JsonObject():New()
		nCont++

		oItem["operacao"         ] := (cAlias)->MF_OPER
		oItem["labelOperacao"    ] := i18n(Iif(Empty((cAlias)->G2_DESCRI), "#1[codigo]#", "#1[codigo]# - #2[descricao]#"), {(cAlias)->MF_OPER, (cAlias)->G2_DESCRI})
		oItem["recurso"          ] := i18n("#1[codigo]# - #2[descricao]#", {Trim((cAlias)->MF_RECURSO), Trim((cAlias)->H1_DESCRI)})
		oItem["centroDeTrabalho" ] := Iif(!Empty((cAlias)->MF_CTRAB), i18n("#1[codigo]# - #2[descricao]#", {Trim((cAlias)->MF_CTRAB), Trim((cAlias)->HB_NOME)}), "")
		oItem["saldo"            ] := (cAlias)->MF_SALDO
		oItem["inicioOperacao"   ] := i18n("#1[data]# - #2[hora]#", {PCPConvDat((cAlias)->dataInicial, 4), (cAlias)->horaInicial})
		oItem["terminoOperacao"  ] := i18n("#1[data]# - #2[hora]#", {PCPConvDat((cAlias)->dataFinal  , 4), (cAlias)->horaFinal  })
		oItem["tempoOperacao"    ] := __Min2Hrs((cAlias)->tempoProd , .T.)
		oItem["tempoSetup"       ] := __Min2Hrs((cAlias)->tempoSetup, .T.)
		oItem["tempoFinalizacao" ] := __Min2Hrs((cAlias)->MF_TMPFINA, .T.)
		oItem["tempoSobreposicao"] := IIf(dicCampo("MF_SOBREPO"), __Min2Hrs((cAlias)->MF_SOBREPO, .T.), " ")
		oItem["tempoRemocao"     ] := IIf(dicCampo("MF_REMOCAO"), __Min2Hrs((cAlias)->MF_REMOCAO, .T.), " ")
		oItem["alocouAlternativo"] := .F.
		oItem["recursoIlimitado" ] := (cAlias)->recursoIlimitado == RECURSO_ILIMITADO

		If (cAlias)->MF_SALDO == 0
			oItem["tipoAlocacao"] := FINALIZADA
		ElseIf Empty((cAlias)->dataInicial)
			oItem["tipoAlocacao"] := SEM_ALOCACAO
		Else
			oItem["tipoAlocacao"] := ALOCADA
		EndIf

		If possuiHZ7()
			oItem["alocouAlternativo"] := (cAlias)->HZ7_SEQ != PCPA152TempoOperacao():getSequenciaRecursoPrincipal()
		EndIf

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())
		If nCont >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If Empty(oReturn["items"])
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
	Else
		aReturn[1] := .T.
		aReturn[2] := 200
	EndIf
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
	FwFreeObj(oItem  )
Return aReturn

/*/{Protheus.doc} GET FERRAMENTAS /api/pcp/v1/pcpa152ferram/{programacao}/ordens/{ordemProducao}
Retorna a utilização das ferramentas em uma ordem de produção
@type  WSMETHOD
@author Lucas Fagundes
@since 21/08/2025
@version P12
@param 01 programacao  , Caracter, Código da programação que será buscada
@param 02 ordemProducao, Caracter, Número da ordem de produção que será buscada
@param 03 page         , Numérico, Número da página a ser buscada
@param 04 pageSize     , Numérico, Tamanho da página
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET FERRAMENTAS PATHPARAM programacao, ordemProducao QUERYPARAM Page, PageSize WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getFerraOP(Self:programacao, Self:ordemProducao, Self:Page, Self:PageSize)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getFerraOP
Retorna os detalhes de utilização de uma ferramenta em uma programação e ordem de produção.
@type  Static Function
@author Lucas Fagundes
@since 21/08/2025
@version P12
@param cProg    , Caracter, Código da programação que será buscada
@param cOrdem   , Caracter, Número da ordem de produção que será buscada
@param nPage    , Numerico, Número da página a ser buscada
@param nPageSize, Numerico, Tamanho da página
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getFerraOP(cProg, cOrdem, nPage, nPageSize)
	Local aReturn := Array(3)
	Local cAlias  := ""
	Local cQuery  := ""
	Local nCont   := 0
	Local nStart  := 0
	Local nParam  := 1
	Local oItem   := Nil
	Local oReturn := JsonObject():New()

	If _oQryFerra == Nil
		_oQryFerra := FwExecStatement():New()

		cQuery += " SELECT SMF.MF_OPER, "
		cQuery +=        " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) descricao, "
		cQuery +=        " HZJ.HZJ_FERRAM, "
		cQuery +=        " SH4.H4_DESCRI, "
		cQuery +=        " HZKinicio.HZK_DATA dataInicial, "
		cQuery +=        " HZKinicio.HZK_INICIO horaInicial, "
		cQuery +=        " HZKfim.HZK_DATA dataFinal, "
		cQuery +=        " HZKfim.HZK_FIM horaFinal, "
		cQuery +=        " COALESCE((SELECT SUM(HZKtempo.HZK_TEMPO) "
		cQuery +=                    " FROM " + RetSqlName("HZK") + " HZKtempo "
		cQuery +=                   " WHERE HZKtempo.HZK_FILIAL = ? "
		cQuery +=                     " AND HZKtempo.HZK_PROG   = HZJ.HZJ_PROG "
		cQuery +=                     " AND HZKtempo.HZK_ID     = HZJ.HZJ_ID "
		cQuery +=                     " AND HZKtempo.D_E_L_E_T_ = ' '), 0) tempo, "
		cQuery +=        " HZJ.HZJ_ALTERN, "
		cQuery +=        " SMF.MF_TPALOFE "
		cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
		cQuery +=  " INNER JOIN " + RetSqlName("HZJ") + " HZJ "
		cQuery +=     " ON HZJ.HZJ_FILIAL = ? "
		cQuery +=    " AND HZJ.HZJ_PROG   = SMF.MF_PROG "
		cQuery +=    " AND HZJ.HZJ_OPER   = SMF.MF_ID "
		cQuery +=    " AND HZJ.D_E_L_E_T_ = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("HZK") + " HZKinicio "
		cQuery +=     " ON HZKinicio.HZK_FILIAL = ? "
		cQuery +=    " AND HZKinicio.HZK_PROG   = HZJ.HZJ_PROG "
		cQuery +=    " AND HZKinicio.HZK_ID     = HZJ.HZJ_ID "
		cQuery +=    " AND HZKinicio.HZK_SEQ    = (SELECT MIN(HZKb.HZK_SEQ) "
		cQuery +=                                  " FROM " + RetSqlName("HZK") + " HZKb "
		cQuery +=                                 " WHERE HZKb.HZK_FILIAL = ? "
		cQuery +=                                   " AND HZKb.HZK_PROG   = HZKinicio.HZK_PROG "
		cQuery +=                                   " AND HZKb.HZK_ID     = HZKinicio.HZK_ID "
		cQuery +=                                   " AND HZKb.D_E_L_E_T_ = ' ') "
		cQuery +=    " AND HZKinicio.D_E_L_E_T_ = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("HZK") + " HZKfim "
		cQuery +=     " ON HZKfim.HZK_FILIAL = ? "
		cQuery +=    " AND HZKfim.HZK_PROG   = HZJ.HZJ_PROG "
		cQuery +=    " AND HZKfim.HZK_ID     = HZJ.HZJ_ID "
		cQuery +=    " AND HZKfim.HZK_SEQ    = (SELECT MAX(HZKc.HZK_SEQ) "
		cQuery +=                               " FROM " + RetSqlName("HZK") + " HZKc "
		cQuery +=                              " WHERE HZKc.HZK_FILIAL = ? "
		cQuery +=                                " AND HZKc.HZK_PROG   = HZKfim.HZK_PROG "
		cQuery +=                                " AND HZKc.HZK_ID     = HZKfim.HZK_ID "
		cQuery +=                                " AND HZKc.D_E_L_E_T_ = ' ') "
		cQuery +=    " AND HZKfim.D_E_L_E_T_ = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery +=     " ON SC2.C2_FILIAL  = ? "
		cQuery +=    " AND " + PCPQrySC2("SC2", "SMF.MF_OP")
		cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SHY") + " SHY "
		cQuery +=     " ON SHY.HY_FILIAL  = ? "
		cQuery +=    " AND SHY.HY_OP      = SMF.MF_OP "
		cQuery +=    " AND SHY.HY_ROTEIRO = SMF.MF_ROTEIRO "
		cQuery +=    " AND SHY.HY_OPERAC  = SMF.MF_OPER  "
		cQuery +=    " AND SHY.HY_TEMPAD  <> 0 "
		cQuery +=    " AND SHY.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
		cQuery +=     " ON SG2.G2_FILIAL  = ? "
		cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
		cQuery +=    " AND SG2.G2_CODIGO  = SMF.MF_ROTEIRO "
		cQuery +=    " AND SG2.G2_OPERAC  = SMF.MF_OPER "
		cQuery +=    " AND SHY.HY_OP IS NULL "
		cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("SH4") + " SH4 "
		cQuery +=     " ON SH4.H4_FILIAL  = ? "
		cQuery +=    " AND SH4.H4_CODIGO  = HZJ.HZJ_FERRAM "
		cQuery +=    " AND SH4.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE SMF.MF_FILIAL = ? "
		cQuery +=    " AND SMF.MF_PROG   = ? "
		cQuery +=    " AND SMF.MF_OP     = ? "
		cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
		cQuery +=  " ORDER BY SMF.MF_OPER, HZKinicio.HZK_DATA, HZKinicio.HZK_INICIO "

		_oQryFerra:setQuery(cQuery)
	EndIf

	_oQryFerra:setString(nParam++, xFilial("HZK")) // HZK_FILIAL
	_oQryFerra:setString(nParam++, xFilial("HZJ")) // HZJ_FILIAL
	_oQryFerra:setString(nParam++, xFilial("HZK")) // HZK_FILIAL
	_oQryFerra:setString(nParam++, xFilial("HZK")) // HZK_FILIAL
	_oQryFerra:setString(nParam++, xFilial("HZK")) // HZK_FILIAL
	_oQryFerra:setString(nParam++, xFilial("HZK")) // HZK_FILIAL
	_oQryFerra:setString(nParam++, xFilial("SC2")) // C2_FILIAL
	_oQryFerra:setString(nParam++, xFilial("SHY")) // HY_FILIAL
	_oQryFerra:setString(nParam++, xFilial("SG2")) // G2_FILIAL
	_oQryFerra:setString(nParam++, xFilial("SH4")) // H4_FILIAL
	_oQryFerra:setString(nParam++, xFilial("SMF")) // MF_FILIAL
	_oQryFerra:setString(nParam++, cProg ) // MF_PROG
	_oQryFerra:setString(nParam++, cOrdem) // MF_OP

	cAlias := _oQryFerra:openAlias()

	If nPage > 1
		nStart := ((nPage-1) * nPageSize)

		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"  ] := {}
	oReturn["hasNext"] := .F.

	While (cAlias)->(!EoF())
		oItem := JsonObject():New()
		nCont++

		oItem["operacao"      ] := (cAlias)->MF_OPER
		oItem["labelOperacao" ] := (cAlias)->MF_OPER + Iif(!Empty((cAlias)->descricao), " - " + (cAlias)->descricao, "")
		oItem["ferramenta"    ] := (cAlias)->HZJ_FERRAM + " - " + (cAlias)->H4_DESCRI
		oItem["inicio"        ] := i18n("#1[data]# - #2[hora]#", {PCPConvDat((cAlias)->dataInicial, 4), (cAlias)->horaInicial})
		oItem["termino"       ] := i18n("#1[data]# - #2[hora]#", {PCPConvDat((cAlias)->dataFinal  , 4), (cAlias)->horaFinal  })
		oItem["tempo"         ] := __Min2Hrs((cAlias)->tempo, .T.)
		oItem["alternativa"   ] := (cAlias)->HZJ_ALTERN == "1"
		oItem["tipoAlocacao"  ] := (cAlias)->MF_TPALOFE

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())
		If nCont >= nPageSize
			Exit
		EndIf
	End
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET ARVPROG /api/pcp/v1/pcpa152res/arvores
Retorna as árvores de uma programação.
@type  WSMETHOD
@author Lucas Fagundes
@since 22/08/2023
@version P12
@param 01 programacao  , Caracter, Código da programação.
@param 02 Filter       , Caracter, Filtro código da árvore.
@param 03 codigo       , Caracter, Filtro código da árvore.
@param 04 ordemProducao, Caracter, Filtro código ordem de produção pai.
@param 05 produto      , Caracter, Filtro código produto pai.
@param 06 Page         , Numerico, Página que será carregada.
@param 07 PageSize     , Numerico, Quantidade de registros por página.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET ARVPROG QUERYPARAM programacao, Filter, codigo, ordemProducao, produto, Page, PageSize WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getArvProg(Self:programacao, Self:codigo, Self:ordemProducao, Self:produto, Self:Page, Self:PageSize, Self:Filter)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getArvProg
Retorna as árvores de uma programação.
@type  Static Function
@author Lucas Fagundes
@since 22/08/2023
@version P12
@param 01 cProg     , Caracter, Código da programação.
@param 02 cCodArv   , Caracter, Filtro código da árvore.
@param 03 cCodOrdem , Caracter, Filtro código ordem de produção pai.
@param 04 cCodProd  , Caracter, Filtro código produto pai.
@param 05 nPage     , Numerico, Página que será carregada.
@param 06 nPageSize , Numerico, Quantidade de registros por página.
@param 07 cOrdemLike, Caracter, Filtro de like para ordem de produção.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function getArvProg(cProg, cCodArv, cCodOrdem, cCodProd, nPage, nPageSize, cOrdemLike)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cBanco  := TcGetDb()
	Local cQuery  := ""
	Local nCount  := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	cQuery += " SELECT DISTINCT SMF.MF_ARVORE, "
	cQuery += "                 SC2.C2_PRODUTO, "
	cQuery += "                 SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD ordemPai  "
	cQuery += "   FROM " + RetSqlName("SMF") + " SMF "
	cQuery += "   LEFT JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery += "     ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery += "    AND SC2.D_E_L_E_T_ = ' ' "

	If "MSSQL" $ cBanco
		cQuery += "AND SC2.R_E_C_N_O_ = SMF.MF_ARVORE "
	Else
		cQuery += "AND CAST(SC2.R_E_C_N_O_ AS VARCHAR(15)) = SMF.MF_ARVORE "
	EndIf

	cQuery += "  WHERE SMF.MF_FILIAL   = '" + xFilial("SMF") + "' "
	cQuery += "    AND SMF.MF_PROG     = '" + cProg + "' "
	cQuery += "    AND SMF.D_E_L_E_T_  = ' ' "

	If !Empty(cCodArv)
		cQuery += " AND SMF.MF_ARVORE LIKE '" + cCodArv + "%' "
	EndIf

	If !Empty(cCodOrdem)
		cQuery += " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD IN ('" + StrTran(cCodOrdem, ",", "','") + "') "
	EndIf

	If !Empty(cOrdemLike)
		cQuery += " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD LIKE '" + cOrdemLike + "%' "
	EndIf

	If !Empty(cCodProd)
		cQuery += " AND SC2.C2_PRODUTO IN ('" + StrTran(cCodProd, ",", "','") + "') "
	EndIf

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"  ] := {}
	oReturn["hasNext"] := .F.

	While (cAlias)->(!EoF())
		nCount++

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["arvore"    ] := (cAlias)->MF_ARVORE
		oReturn["items"][nCount]["ordemPai"  ] := (cAlias)->ordemPai
		oReturn["items"][nCount]["produtoPai"] := (cAlias)->C2_PRODUTO

		If Empty((cAlias)->MF_ARVORE)
			oReturn["items"][nCount]["arvore"  ] := " "
			oReturn["items"][nCount]["ordemPai"] := STR0320 // "Árvore em branco"
		EndIf

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

/*/{Protheus.doc} GET CRONOLOGIA /api/pcp/v1/pcpa152res/{programacao}/cronologia/{ordemProducao}
Retorna os registros para exibição da cronologia de uma árvore/ordem de produção.
@type  WSMETHOD
@author Lucas Fagundes
@since 18/04/2024
@version P12
@param 01 programacao  , Caracter, Programação que irá buscar os registros.
@param 02 ordemProducao, Caracter, Ordem de produção que irá buscar os registros.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET CRONOLOGIA PATHPARAM programacao, ordemProducao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getCrono(Self:programacao, Self:ordemProducao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getCrono
Retorna os registros de data/hora para exibir na tela de cronologia.
@type  Static Function
@author Lucas Fagundes
@since 18/04/2024
@version P12
@param 01 cProg , Caracter, Programação que irá buscar as datas.
@param 02 cOrdem, Caracter, Ordem de produção que irá buscar os registros.
@return aReturn, Array, Array com as informaçãoes de retorno da API.
/*/
Static Function getCrono(cProg, cOrdem)
	Local aReturn   := Array(3)
	Local cAlias    := GetNextAlias()
	Local cBanco    := TcGetDb()
	Local cId       := ""
	Local cIdPai    := ""
	Local cOP       := ""
	Local cOPAnt    := ""
	Local cOperAnt  := ""
	Local cQuery    := ""
	Local dFimArv   := Nil
	Local dFimOP    := Nil
	Local dIniArv   := Nil
	Local dIniOP    := Nil
	Local nHrFimArv := Nil
	Local nHrFimOP  := Nil
	Local nHrIniArv := Nil
	Local nHrIniOP  := Nil
	Local oArvore   := JsonObject():New()
	Local oOrdem    := JsonObject():New()
	Local oRefs     := JsonObject():New()
	Local oReturn   := JsonObject():New()

	cOrdem := PadR(cOrdem, GetSX3Cache("C2_OP", "X3_TAMANHO"))

	cQuery += " WITH ordens(C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, C2_SEQPAI, C2_PRODUTO) AS ( "
	cQuery += " SELECT SC2Base.C2_NUM, "
	cQuery +=       "  SC2Base.C2_ITEM, "
	cQuery +=       "  SC2Base.C2_SEQUEN, "
	cQuery +=       "  SC2Base.C2_ITEMGRD, "
	cQuery += Iif(cBanco == "POSTGRES", "  CAST('000' AS TEXT) C2_SEQPAI, ", "  '000' C2_SEQPAI, ")
	cQuery +=       "  SC2Base.C2_PRODUTO "
	cQuery +=   " FROM " + RetSqlName("SC2") + " SC2Base "
	cQuery +=  " WHERE SC2Base.C2_FILIAL = '" + xFilial("SC2") + "' "
	cQuery +=    " AND SC2Base.C2_NUM||SC2Base.C2_ITEM||SC2Base.C2_SEQUEN||SC2Base.C2_ITEMGRD = '" + cOrdem + "' "
	cQuery +=    " AND SC2Base.D_E_L_E_T_ = ' ' "
	cQuery +=  " UNION ALL "
	cQuery += " SELECT SC2.C2_NUM, "
	cQuery +=        " SC2.C2_ITEM, "
	cQuery +=        " SC2.C2_SEQUEN, "
	cQuery +=        " SC2.C2_ITEMGRD, "
	cQuery +=        " SC2.C2_SEQPAI, "
	cQuery +=        " SC2.C2_PRODUTO "
	cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
	cQuery +=  " INNER JOIN ordens SC2Rec "
	cQuery +=     " ON SC2Rec.C2_NUM    = SC2.C2_NUM "
	cQuery +=    " AND SC2Rec.C2_ITEM   = SC2.C2_ITEM "
	cQuery +=    " AND SC2Rec.C2_SEQUEN = SC2.C2_SEQPAI "
	cQuery +=  " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ') "
	cQuery += " SELECT SMF.MF_OP, "
	cQuery +=       "  SMF.MF_OPER, "
	cQuery +=       "  COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) descricao, "
	cQuery +=       "  SMF.MF_RECURSO, "
	cQuery +=       "  SVMMenor.VM_DATA dataInicio, "
	cQuery +=       "  SVMMenor.VM_INICIO horaInicio, "
	cQuery +=       "  SVMMaior.VM_DATA dataFim, "
	cQuery +=       "  SVMMaior.VM_FIM horaFim, "
	cQuery +=       "  SC2.C2_NUM, "
	cQuery +=       "  SC2.C2_ITEM, "
	cQuery +=       "  SC2.C2_SEQUEN, "
	cQuery +=       "  SC2.C2_ITEMGRD, "
	cQuery +=       "  SC2.C2_SEQPAI, "
	cQuery +=       "  SC2.C2_PRODUTO, "
	cQuery +=       "  SB1.B1_DESC, "
	cQuery +=       "  SH1.H1_DESCRI, "
	cQuery +=       "  SMF.MF_CTRAB, "
	cQuery +=       "  SHB.HB_NOME, "
	cQuery +=       "  SMF.MF_PROG, "
	cQuery +=       "  SMF.MF_ARVORE, "
	If possuiHZ7()
		cQuery +=   "  HZ7.HZ7_SEQ, "
	EndIf
	cQuery +=       "  SH1.H1_ILIMITA "
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	If possuiHZ7()
		cQuery +=  " INNER JOIN " + RetSqlName("HZ7") + " HZ7 "
		cQuery +=     " ON HZ7.HZ7_FILIAL = '" + xFilial("HZ7") + "' "
		cQuery +=    " AND HZ7.HZ7_PROG   = SMF.MF_PROG "
		cQuery +=    " AND HZ7.HZ7_ID     = SMF.MF_ID "
		cQuery +=    " AND HZ7.HZ7_RECURS = SMF.MF_RECURSO "
		cQuery +=    " AND HZ7.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery +=  " INNER JOIN ordens SC2 "
	cQuery +=     " ON " + PCPQrySC2("SC2", "SMF.MF_OP")
	cQuery +=   " LEFT JOIN " + RetSqlName("SHY") + " SHY "
	cQuery +=     " ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
	cQuery +=    " AND SHY.HY_OP      = SMF.MF_OP "
	cQuery +=    " AND SHY.HY_ROTEIRO = SMF.MF_ROTEIRO "
	cQuery +=    " AND SHY.HY_OPERAC  = SMF.MF_OPER "
	cQuery +=    " AND SHY.HY_TEMPAD  <> 0 "
	cQuery +=    " AND SHY.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
	cQuery +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
	cQuery +=    " AND SG2.G2_CODIGO  = SMF.MF_ROTEIRO "
	cQuery +=    " AND SG2.G2_OPERAC  = SMF.MF_OPER "
	cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cQuery +=    " AND SHY.HY_OP IS NULL "
	cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cQuery +=    " AND SH1.H1_CODIGO  = SMF.MF_RECURSO "
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SHB") + " SHB "
	cQuery +=     " ON SHB.HB_FILIAL  = '" + xFilial("SHB") + "' "
	cQuery +=    " AND SHB.HB_COD     = SMF.MF_CTRAB "
	cQuery +=    " AND SHB.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SVM") + " SVMMaior "
	cQuery +=     " ON SVMMaior.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=    " AND SVMMaior.VM_PROG    = SMF.MF_PROG "
	cQuery +=    " AND SVMMaior.VM_ID      = SMF.MF_ID "
	cQuery +=    " AND SVMMaior.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SVM") + " SVMMenor "
	cQuery +=     " ON SVMMenor.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=    " AND SVMMenor.VM_PROG    = SMF.MF_PROG "
	cQuery +=    " AND SVMMenor.VM_ID      = SMF.MF_ID "
	cQuery +=    " AND SVMMenor.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMF.MF_FILIAL = '" + xFilial("SMF") + "' "
	cQuery +=    " AND SMF.MF_PROG   = '" + cProg + "' "
	cQuery +=    " AND ((SMF.MF_ARVORE  = ' ' AND SMF.MF_OP = '" + cOrdem + "') OR "
	cQuery +=         " (SMF.MF_ARVORE  = (SELECT DISTINCT SMFArv.MF_ARVORE "
	cQuery +=                              " FROM " + RetSqlName("SMF") + " SMFArv "
	cQuery +=                             " WHERE SMFArv.MF_FILIAL  = '" + xFilial("SMF") + "' "
	cQuery +=                               " AND SMFArv.MF_PROG    = '" + cProg  + "' "
	cQuery +=                               " AND SMFArv.MF_OP      = '" + cOrdem + "' "
	cQuery +=                               " AND SMFArv.D_E_L_E_T_ = ' ') AND "
	cQuery +=          " SMF.MF_ARVORE != ' ')) "

	// Filtro VM_SEQ dos joins SVMMaior e SVMMenor deve ser feito no WHERE. Caso feito diretamente no JOIN ocorre erro em ORACLE.
	cQuery +=    " AND SVMMenor.VM_SEQ = (SELECT MIN(seqSVMMenor.VM_SEQ) "
	cQuery +=                             " FROM " + RetSqlName("SVM") + " seqSVMMenor "
	cQuery +=                            " WHERE seqSVMMenor.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=                              " AND seqSVMMenor.VM_PROG    = SVMMenor.VM_PROG "
	cQuery +=                              " AND seqSVMMenor.VM_ID      = SVMMenor.VM_ID "
	cQuery +=                              " AND seqSVMMenor.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND SVMMaior.VM_SEQ = (SELECT MAX(seqSVMMaior.VM_SEQ) "
	cQuery +=                             " FROM " + RetSqlName("SVM") + " seqSVMMaior "
	cQuery +=                            " WHERE seqSVMMaior.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=                              " AND seqSVMMaior.VM_PROG    = SVMMaior.VM_PROG "
	cQuery +=                              " AND seqSVMMaior.VM_ID      = SVMMaior.VM_ID "
	cQuery +=                              " AND seqSVMMaior.D_E_L_E_T_ = ' ') "

	cQuery +=  " ORDER BY SMF.MF_OP, SMF.MF_OPER "

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	If cBanco == "POSTGRES"
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	TcSetField(cAlias, 'dataInicio', 'D', GetSx3Cache("VM_DATA", "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'dataFim'   , 'D', GetSx3Cache("VM_DATA", "X3_TAMANHO"), 0)

	oReturn["data"        ] := {}
	oReturn["dependencies"] := {}

	If (cAlias)->(!EoF())
		aAdd(oReturn["data"], oArvore)
		oRefs["AGRUPADOR"] := oArvore

		oArvore["ordemProducao"] := i18n(STR0478, {cOrdem}) //"Sequenciamento ordem #1[ordem]#"
		oArvore["id"           ] := "AGRUPADOR"
		oArvore["title"        ] := ""
		oArvore["produto"      ] := ""
		oArvore["start"        ] := Nil
		oArvore["end"          ] := Nil
		oArvore["filhas"       ] := {}
		oArvore["operacoes"    ] := JsonObject():New()
		oArvore["operacoes"    ]["data"        ] := {}
		oArvore["operacoes"    ]["dependencies"] := {}

		While (cAlias)->(!EoF())
			cId    := (cAlias)->C2_NUM + (cAlias)->C2_ITEM + (cAlias)->C2_SEQUEN + (cAlias)->C2_ITEMGRD
			cIdPai := (cAlias)->C2_NUM + (cAlias)->C2_ITEM + (cAlias)->C2_SEQPAI + (cAlias)->C2_ITEMGRD

			If cOP != (cAlias)->MF_OP
				oOrdem := JsonObject():New()
				cOP    := (cAlias)->MF_OP

				If oRefs:hasProperty(cIdPai)
					aAdd(oRefs[cIdPai]["filhas"], oOrdem)
				Else
					aAdd(oRefs["AGRUPADOR"]["filhas"], oOrdem)
				EndIf
				oRefs[cId] := oOrdem

				oOrdem["id"           ] := cId
				oOrdem["ordemProducao"] := cOP
				oOrdem["produto"      ] := RTrim((cAlias)->C2_PRODUTO) + " - " + RTrim((cAlias)->B1_DESC)
				oOrdem["title"        ] := ""
				oOrdem["start"        ] := Nil
				oOrdem["end"          ] := Nil
				oOrdem["filhas"       ] := {}
				oOrdem["operacoes"    ] := JsonObject():New()
				oOrdem["operacoes"    ]["data"        ] := {}
				oOrdem["operacoes"    ]["dependencies"] := {}
				oOrdem["programacao"  ] := (cAlias)->MF_PROG
				oOrdem["arvore"       ] := (cAlias)->MF_ARVORE
				oOrdem["operacao"     ] := (cAlias)->MF_OPER

				addDep(oReturn["dependencies"], cId, cIdPai, DEPENDECY_TYPE_FS)
			EndIf

			If dIniArv == Nil .Or. (cAlias)->dataInicio < dIniArv .Or. ((cAlias)->dataInicio == dIniArv .And. __Hrs2Min((cAlias)->horaInicio) < nHrIniArv)
				dIniArv   := (cAlias)->dataInicio
				nHrIniArv := __Hrs2Min((cAlias)->horaInicio)
			EndIf

			If dFimArv == Nil .Or. (cAlias)->dataFim > dFimArv .Or. ((cAlias)->dataFim == dFimArv .And. __Hrs2Min((cAlias)->horaFim) > nHrFimArv)
				dFimArv   := (cAlias)->dataFim
				nHrFimArv := __Hrs2Min((cAlias)->horaFim)
			EndIf

			If dIniOP == Nil .Or. (cAlias)->dataInicio < dIniOP .Or. ((cAlias)->dataInicio == dIniOP .And. __Hrs2Min((cAlias)->horaInicio) < nHrIniOP)
				dIniOP   := (cAlias)->dataInicio
				nHrIniOP := __Hrs2Min((cAlias)->horaInicio)
			EndIf

			If dFimOP == Nil .Or. (cAlias)->dataFim > dFimOP .Or. ((cAlias)->dataFim == dFimOP .And. __Hrs2Min((cAlias)->horaFim) > nHrFimOP)
				dFimOP   := (cAlias)->dataFim
				nHrFimOP := __Hrs2Min((cAlias)->horaFim)
			EndIf

			oOrdem["title"] := i18n(STR0660, {AllTrim(cOP), RTrim((cAlias)->C2_PRODUTO), PCPConvDat(DtoS(dIniOP), 4), __Min2Hrs(nHrIniOP, .T.), PCPConvDat(DtoS(dFimOP), 4), __Min2Hrs(nHrFimOP, .T.)}) // "Ordem: #1[ordem]#, Produto: #2[produto]#, Início: #3[dataini]# - #4[horaini]#, Fim: #5[datafim]# - #6[horafim]#"

			aAdd(oOrdem["operacoes"]["data"], JsonObject():New())

			aTail(oOrdem["operacoes"]["data"])["id"               ] := cId + (cAlias)->MF_OPER
			aTail(oOrdem["operacoes"]["data"])["operacao"         ] := (cAlias)->MF_OPER
			aTail(oOrdem["operacoes"]["data"])["recurso"          ] := RTrim((cAlias)->MF_RECURSO) + " - " + RTrim((cAlias)->H1_DESCRI)
			aTail(oOrdem["operacoes"]["data"])["title"            ] := i18n(STR0664, {AllTrim((cAlias)->MF_OPER), AllTrim((cAlias)->MF_RECURSO), PCPConvDat(DtoS(dIniOP), 4), __Min2Hrs(nHrIniOP, .T.), PCPConvDat(DtoS(dFimOP), 4), __Min2Hrs(nHrFimOP, .T.)})//"Operação: #1[operacao]#, Recurso: #2[recurso]#, Início: #3[dataini]# - #4[horaini]#, Fim: #5[datafim]# - #6[horafim]#"
			aTail(oOrdem["operacoes"]["data"])["start"            ] := getDataJS((cAlias)->dataInicio, (cAlias)->horaInicio)
			aTail(oOrdem["operacoes"]["data"])["end"              ] := getDataJS((cAlias)->dataFim   , (cAlias)->horaFim   )
			aTail(oOrdem["operacoes"]["data"])["alocouAlternativo"] := .F.
			aTail(oOrdem["operacoes"]["data"])["recursoIlimitado" ] := (cAlias)->H1_ILIMITA == "S"

			If !Empty((cAlias)->descricao)
				aTail(oOrdem["operacoes"]["data"])["operacao"] += " - " + RTrim((cAlias)->descricao)
			EndIf

			If Empty((cAlias)->MF_CTRAB)
				aTail(oOrdem["operacoes"]["data"])["centroTrab"] := STR0140 // "Centro de trabalho em branco"
			Else
				aTail(oOrdem["operacoes"]["data"])["centroTrab"] := (cAlias)->MF_CTRAB + " - " + (cAlias)->HB_NOME
			EndIf

			If possuiHZ7()
				aTail(oOrdem["operacoes"]["data"])["alocouAlternativo"] := (cAlias)->HZ7_SEQ != PCPA152TempoOperacao():getSequenciaRecursoPrincipal()
			EndIf

			If Empty(cOperAnt)
				addDep(oOrdem["operacoes"]["dependencies"],;
					cId                                ,;
					cId + (cAlias)->MF_OPER            ,;
					DEPENDECY_TYPE_SS                   )
			Else
				addDep(oOrdem["operacoes"]["dependencies"],;
					cId + cOperAnt                     ,;
					cId + (cAlias)->MF_OPER            ,;
					DEPENDECY_TYPE_FS                   )
			EndIf

			cOperAnt := (cAlias)->MF_OPER
			(cAlias)->(dbSkip())

			If cOP != (cAlias)->MF_OP
				oOrdem["start"] := getDataJS(dIniOP, __Min2Hrs(nHrIniOP, .T.))
				oOrdem["end"  ] := getDataJS(dFimOP, __Min2Hrs(nHrFimOP, .T.))

				cOPAnt   := cOP
				cOperAnt := ""
				dIniOP   := Nil
				dFimOP   := Nil
				nHrIniOP := Nil
				nHrFimOP := Nil
			EndIf
		End
		(cAlias)->(dbCloseArea())

		oArvore["start"] := getDataJS(dIniArv, __Min2Hrs(nHrIniArv, .T.))
		oArvore["end"  ] := getDataJS(dFimArv, __Min2Hrs(nHrFimArv, .T.))
	EndIf

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oArvore)
	FreeObj(oOrdem)
	FreeObj(oRefs)
	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getDataJS
Converte data e hora (formato hh:mm) em string para criar objeto date do javascript.
@type  Static Function
@author Lucas Fagundes
@since 18/04/2024
@version P12
@param dData, Date    , Data que será convertida.
@param cHora, Caracter, Hora que será convertida.
@return cDataJs, Caracter, String para criar objeto date no javascript.
/*/
Static Function getDataJS(dData, cHora)
	Local cDataJs := ""

	cDataJs := PCPConvDat(dData, 2) + "T" + cHora + ":00.000"

Return cDataJs

/*/{Protheus.doc} addDep
Cria dependência entre dois ids do gantt da tela de cronologia.
@type  Static Function
@author Lucas Fagundes
@since 18/04/2024
@version P12
@param 01 aDeps  , Array   , Array com as dependecias (retorna por referência a nova dependência adicionada).
@param 02 nFromId, Numerico, Id que irá sair a dependência.
@param 03 nIdTo  , Numerico, Id que irá chegar a dependência.
@param 04 nType  , Numerico, Tipo de dependência.
@return Nil
/*/
Static Function addDep(aDeps, nFromId, nIdTo, nType)

	aAdd(aDeps, JsonObject():New())

	aTail(aDeps)["id"    ] := Len(aDeps)
	aTail(aDeps)["fromId"] := nFromId
	aTail(aDeps)["toId"  ] := nIdTo
	aTail(aDeps)["type"  ] := nType

Return Nil

/*/{Protheus.doc} POST DATAORDEM /api/pcp/v1/pcpa152res/buscaOrdem
Retorna a data de inicio de uma ordem de produção no CRP.
@type  WSMETHOD
@author Lucas Fagundes
@since 27/05/2024
@version P12
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD POST DATAORDEM WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local cBody     := ""
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local oBody     := JsonObject():New()

	cBody := DecodeUTF8(Self:getContent())
	oBody:FromJson(cBody)

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getDataOP(oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)
Return lReturn

/*/{Protheus.doc} getDataOP
Busca a data de inicio de uma ordem de produção em uma programação do CRP.
@type  Static Function
@author Lucas Fagundes
@since 27/05/2024
@version P12
@param oParams, Object, Corpo da requisição com os parâmetros para busca da op e do recurso.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getDataOP(oParams)
	Local aReturn    := Array(3)
	Local cAlias     := GetNextAlias()
	Local cOper      := oParams["operacao"]
	Local cOrdem     := oParams["ordemProducao"]
	Local cProg      := oParams["programacao"]
	Local cQuery     := ""
	Local lLimpaFilt := .F.
	Local oReturn    := JsonObject():New()

	cQuery += " SELECT SMF.MF_OP, "
	cQuery +=        " SMF.MF_OPER, "
	cQuery +=        " SMF.MF_RECURSO, "
	cQuery +=        " SMF.MF_CTRAB, "
	cQuery +=        " SVM.VM_DATA, "
	cQuery +=        " SVM.VM_INICIO "
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	cQuery +=  " INNER JOIN " + RetSqlName("SVM") + " SVM "
	cQuery +=     " ON SVM.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=    " AND SVM.VM_PROG    = SMF.MF_PROG "
	cQuery +=    " AND SVM.VM_ID      = SMF.MF_ID "
	cQuery +=    " AND SVM.VM_SEQ     = (SELECT MIN(SVM2.VM_SEQ) "
	cQuery +=                            " FROM " + RetSqlName("SVM") + " SVM2 "
	cQuery +=                           " WHERE SVM2.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=                             " AND SVM2.VM_PROG    = SMF.MF_PROG "
	cQuery +=                             " AND SVM2.VM_ID      = SMF.MF_ID "
	cQuery +=                             " AND SVM2.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND SVM.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
	cQuery +=    " AND SMF.MF_PROG    = '" + cProg  + "' "
	cQuery +=    " AND SMF.MF_OP      = '" + cOrdem + "' "

	If !Empty(cOper)
		cQuery += " AND SMF.MF_OPER = '" + cOper + "' "
	EndIf

	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY SVM.VM_DATA, SVM.VM_INICIO "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	TcSetField(cAlias, 'VM_DATA', 'D', GetSx3Cache("VM_DATA", "X3_TAMANHO"), 0)

	If (cAlias)->(!EoF())
		oReturn["dataInicio" ] := getDataJS((cAlias)->VM_DATA, (cAlias)->VM_INICIO)
		oReturn["recurso"    ] := (cAlias)->MF_RECURSO
		oReturn["pageRecurso"] := getPageRec((cAlias)->MF_RECURSO, oParams, @lLimpaFilt)

		If !lLimpaFilt
			lLimpaFilt := !vldFiltOP(oParams, (cAlias)->VM_DATA, (cAlias)->MF_RECURSO)
		EndIf

		oReturn["limpaFiltros"] := lLimpaFilt

		aReturn[1] := .T.
		aReturn[2] := 200
	Else
		aReturn[1] := .F.
		aReturn[2] := 400

		oReturn["message"] := STR0498 // "Ordem de produção não encontrada!"
		If Empty(cOper)
			oReturn["detailedMessage"] := STR0499 // "Verifique se a ordem de produção informada foi considerada e alocada na programação."
		Else
			oReturn["detailedMessage"] := STR0500 // "Verifique se a ordem de produção e a operação informada foram consideradas e alocadas na programação."
		EndIf
	EndIf
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getPageRec
Busca a página de um recurso.
@type  Static Function
@author Lucas Fagundes
@since 27/05/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá buscar a página.
@param 02 oParams   , Object  , Parâmetros para busca dos recursos.
@param 03 lLimpaFilt, Logico  , Retorna por referência se será necessario limpar os filtros.
@return nPage, Numerico, Pagina do recurso que está sendo buscado.
/*/
Static Function getPageRec(cRecurso, oParams, lLimpaFilt)
	Local aRecs   := {}
	Local aReturn := {}
	Local nPage   := 0
	Local nPos    := 0
	Local oJson   := JsonObject():New()

	If !Empty(oParams["filtrosRecursos"]["recurso"])
		nPos := aScan(oParams["filtrosRecursos"]["recurso"], {|cRec| cRec == cRecurso})

		lLimpaFilt := nPos == 0
	EndIf

	If !lLimpaFilt
		aReturn := GetRecsDis(oParams["programacao"], 1, 0, oParams["filtrosRecursos"])

		oJson:fromJson(aReturn[3])
		aRecs := oJson["recursos"]

		nPos := aScan(aRecs, {|oRecurso| oRecurso["recurso"] == RTrim(cRecurso)})
		If nPos > 0
			nPage := Int(nPos / oParams["filtrosRecursos"]["pageSize"]) + 1
		Else
			lLimpaFilt := .T.
			oJson := JsonObject():New()

			aSize(aReturn, 0)
			aSize(aRecs, 0)
		EndIf
	EndIf

	If lLimpaFilt
		oJson["comAlocacao"] := .T.

		aReturn := GetRecsDis(oParams["programacao"], 1, 0, oJson)
		oJson   := JsonObject():New()

		oJson:fromJson(aReturn[3])
		aRecs := oJson["recursos"]

		nPos := aScan(aRecs, {|oRecurso| oRecurso["recurso"] == RTrim(cRecurso)})
		If nPos > 0
			nPage := Int(nPos / oParams["filtrosRecursos"]["pageSize"]) + 1
		EndIf
	EndIf

	FreeObj(oJson)
	aSize(aReturn, 0)
	aSize(aRecs, 0)
Return nPage

/*/{Protheus.doc} vldFiltOP
Verifica se irá encontrar a ordem de produção que está sendo buscada.
@type  Static Function
@author Lucas Fagundes
@since 27/05/2024
@version P12
@param 01 oParams , Object, Parâmetros da busca de ordem de produção.
@param 02 dData   , Date, Data de inicio da ordem de produção.
@param 03 cRecurso, Caracter, Recurso que a ordem está alocada.
@return lEncontra, Logico, Indica se irá encontrar a ordem de produção com os filtros atuais.
/*/
Static Function vldFiltOP(oParams, dData, cRecurso)
	Local aReturn   := {}
	Local lEncontra := .F.

	oParams["filtrosOrdemProducao"]["recurso"   ] := {cRecurso}
	oParams["filtrosOrdemProducao"]["dataInicio"] := PCPConvDat(dData, 2)
	oParams["filtrosOrdemProducao"]["dataFim"   ] := PCPConvDat((dData+1), 2)

	aReturn := getDistrib(oParams["programacao"], oParams["filtrosOrdemProducao"])

	lEncontra := aScan(aReturn, {|oItem| oItem["ordemProducao"] == oParams["ordemProducao"] .And. oItem["resourceId"] == RTrim(cRecurso)}) > 0

	aSize(aReturn, 0)
Return lEncontra

/*/{Protheus.doc} POST CAPACIDADE /api/pcp/v1/pcpa152res/capacidade/{programacao}
Retorna os eventos para exibição na tela de capacidade do CRP.
@type  WSMETHOD
@author Lucas Fagundes
@since 12/07/2024
@version P12
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD POST CAPACIDADE PATHPARAM programacao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local cBody     := ""
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local oBody     := JsonObject():New()

	cBody := DecodeUTF8(Self:getContent())
	oBody:FromJson(cBody)

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getCapac(Self:programacao, oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)
Return lReturn

/*/{Protheus.doc} getCapac
Busca as informações para exibição da capacidade dos recursos.
@type  Static Function
@author Lucas Fagundes
@since 12/07/2024
@version P12
@param 01 cProg  , Caracter, Programação que irá buscar as informações.
@param 02 oParams, Object  , Json com os parâmetros para busca das informações.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getCapac(cProg, oParams)
	Local aReturn  := Array(3)
	Local oReturn  := JsonObject():New()
	Local oUsoDisp := JsonObject():New()

	oReturn["alocacoes"      ] := getDistrib(cProg, oParams["buscaAlocacoes"], @oUsoDisp)
	oReturn["disponibilidade"] := GetDispon(cProg, oParams["buscaDisponibilidade"], oUsoDisp)

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oUsoDisp)
	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getChvDisp
Retorna a chave de um registro de disponibilidade.
@type  Static Function
@author Lucas Fagundes
@since 25/07/2024
@version P12
@param 01 cIdDisp , Caracter, Id da disponibilidade
@param 02 cSeqDisp, Caracter, Sequencia da disponibilidade
@return cChave, Caracter, Chave do registro.
/*/
Static Function getChvDisp(cIdDisp, cSeqDisp)
	Local cChave := cIdDisp + "_" + cSeqDisp

Return cChave

/*/{Protheus.doc} possuiHZ7
Verifica se a tabela HZ7 está presente no dicionario de dados.
@type  Static Function
@author Lucas Fagundes
@since 18/10/2024
@version P12
@return _oDicionar["HZ7"], Logico, Indica se possui a tabela HZ7 no dicionario de dados.
/*/
Static Function possuiHZ7()

	If _oDicionar == Nil
		_oDicionar := JsonObject():New()
	EndIf

	If !_oDicionar:hasProperty("HZ7")
		_oDicionar["HZ7"] := AliasInDic("HZ7")
	EndIf

Return _oDicionar["HZ7"]

/*/{Protheus.doc} dicCampo
Verifica se uma coluna está presente no dicionario de dados.
@type  Static Function
@author Marcelo Neumann
@since 19/02/2025
@version P12
@param cCampo, Caracter, Campo que será verificado.
@return lExiste, Logico, Indica se possui a coluna no dicionario de dados.
/*/
Static Function dicCampo(cCampo)
	Local lExiste := .T.

	If _oDicionar == Nil
		_oDicionar := JsonObject():New()
	EndIf

	If !_oDicionar:hasProperty(cCampo)
		_oDicionar[cCampo] := GetSx3Cache(cCampo, "X3_TAMANHO") > 0
	EndIf
	lExiste := _oDicionar[cCampo]

Return lExiste

/*/{Protheus.doc} GET OPTIONAL /api/pcp/v1/pcpa152res/opcional/{ordemProducao}
Retorna os opcionais do produto de acordo com a ordem de produção

@type WSMETHOD
@author breno.ferreira
@since 24/10/2024
@version P12.1.2410
@param 01 ordemProducao, Caracter, Ordem de produção do CRP
@return   lReturn      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPTIONAL PATHPARAM ordemProducao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getPCPOpc(Self:ordemProducao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getPCPOpc
Retorna os opcionais do produto de acordo com a ordem de produção

@type Static Function
@author breno.ferreira
@since 24/10/2024
@version P12.1.2410
@param 01 cOp, Character, ordem de produção do CRP
@return   aResult , Array   , Array com as informacoes da requisicao
/*/
Static Function getPCPOpc(cOp)
	Local aOpcional  := {}
	Local aResult    := {}
	Local nIndex     := 0
	Local oJson      := JsonObject():New()
	Local nTotal     := 0

	oJson["items"] := {}

	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+cOp))

	aOpcional := ListOpcPcp(SC2->C2_PRODUTO, SC2->C2_MOPC, SC2->C2_OPC, 2)

	nTotal := Len(aOpcional)
	If nTotal > 0
		For nIndex := 1 To nTotal
			aAdd(oJson["items"], JsonObject():New())
			oJson["items"][nIndex]["product"          ] := aOpcional[nIndex][1]
			oJson["items"][nIndex]["description"      ] := aOpcional[nIndex][2]
			oJson["items"][nIndex]["groupOptional"    ] := aOpcional[nIndex][3]
			oJson["items"][nIndex]["descGroupOptional"] := aOpcional[nIndex][4]
			oJson["items"][nIndex]["itemOptional"     ] := aOpcional[nIndex][5]
			oJson["items"][nIndex]["descItemOptional" ] := aOpcional[nIndex][6]

			aSize(aOpcional[nIndex], 0)
		Next nIndex

		aAdd(aResult, .T.)
		aAdd(aResult, 200)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))

		aSize(aOpcional, 0)
	Endif

	FwFreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET OPOPCIONAL /api/pcp/v1/pcpa152res/ordemProducao/opcional/{programacao}/{ordemProducao}
Retorna os dados de uma ordem de produção

@type WSMETHOD
@author breno.ferreira
@since 29/10/2024
@version P12.1.24
@param 01 programacao, Caracter, programação do CRP
@param 02 ordemProducao, Caracter, Ordem de produção do CRP
@param 03 efetivadas, Logical, valida se é busca de efetivadas.
@return   lReturn      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPOPCIONAL QUERYPARAM programacao, ordemProducao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOpcOP(Self:programacao, Self:ordemProducao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getOpcOP
Retorna os dados de uma ordem de produção

@type Static Function
@author breno.ferreira
@since 29/10/2024
@version P12.1.2410
@param 01 cProg, Character, programação do CRP
@param 02 cOp, Character, ordem de produção do CRP
@return   aResult , Array   , Array com as informacoes da requisicao
/*/
Static Function getOpcOP(cProg, cOp)
	Local aResult   := {}
	Local cAlias    := ""
	Local cQuery    := ""
	Local cSituacao := ""
	Local lPerdInf  := SuperGetMV("MV_PERDINF",.F.,.F.)
	Local nDecs     := GetSx3Cache("C2_QUANT", "X3_TAMANHO")
	Local oItem     := JsonObject():New()
	Local nPosParam := 1

	If _oQryOpOpc == Nil
		_oQryOpOpc := FwExecStatement():New()

		cQuery := " SELECT DISTINCT SC2.C2_PRODUTO produto, "
		cQuery +=                 " SB1.B1_DESC descrProd, "
		cQuery +=                 " SC2.C2_QUANT quantidade, "
		cQuery +=                 " SC2.C2_QUJE qtdProd, "
		cQuery +=                 " SC2.C2_PERDA perda, "
		cQuery +=                 " SC2.C2_DATPRI datPri, "
		cQuery +=                 " SC2.C2_DATPRF datPrf, "
		cQuery +=                 " CASE SC2.C2_STATUS "
    	cQuery +=                     " WHEN 'S' THEN '1' "
    	cQuery +=                     " ELSE SC2.C2_TPOP "
    	cQuery +=                 " END SITUACAO, "
		cQuery +=                 " SC2.C2_PRIOR prioridade, "
		cQuery +=                 " SMF.MF_ROTEIRO roteiro "
		cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
		cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery +=     " ON SB1.B1_FILIAL  = ? "
		cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("SMF") + " SMF "
		cQuery +=     " ON SMF.MF_FILIAL = ? "
		cQuery +=    " AND SMF.MF_PROG   = ? "
		cQuery +=    " AND " + PCPQrySC2("SC2", "SMF.MF_OP")
		cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE SC2.C2_FILIAL  = ? "
		If "POSTGRES" $ TCGetDB()
			cQuery += " AND RTRIM(CONCAT(SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD)) = RTRIM(?) "
		Else
			cQuery += " AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD = ? "
		EndIf
		cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "

		If "MSSQL" $ TCGetDB()
			//Substitui concatenação || por +
			cQuery := StrTran(cQuery, '||', '+')
		EndIf

		_oQryOpOpc:setQuery(cQuery)
	EndIf

	_oQryOpOpc:SetString(nPosParam++, xFilial("SB1"))
	_oQryOpOpc:SetString(nPosParam++, xFilial("SMF"))
	_oQryOpOpc:SetString(nPosParam++, cProg)
	_oQryOpOpc:SetString(nPosParam++, xFilial("SC2"))
	_oQryOpOpc:SetString(nPosParam++, cOp)

	cAlias := _oQryOpOpc:OpenAlias()

	While (cAlias)->(!Eof())

		If (cAlias)->SITUACAO == '1'
			cSituacao := STR0608 //'Efetivada'
		ElseIf (cAlias)->SITUACAO == 'F'
			cSituacao := STR0609 //'Firme'
		ElseIf (cAlias)->SITUACAO == 'P'
			cSituacao := STR0610 //'Prevista'
		EndIf

		oItem["produto"     ] := Trim((cAlias)->produto) + " - " + Trim((cAlias)->descrProd)
		oItem["quantidade"  ] := (cAlias)->quantidade
		oItem["saldo"       ] := Max(0,NoRound((cAlias)->quantidade - (cAlias)->qtdProd - If(lPerdInf,0, (cAlias)->perda), nDecs))
		oItem["previsao"    ] := PCPConvDat((cAlias)->datPri, 4) + " - " + PCPConvDat((cAlias)->datPrf, 4)
		oItem["situacao"    ] := cSituacao
		oItem["prioridade"  ] := (cAlias)->prioridade
		oItem["roteiro"     ] := (cAlias)->roteiro
		oItem["viewOptional"] := {STR0624}

		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

	aAdd(aResult, .T.)
	aAdd(aResult, 200)
	aAdd(aResult, oItem:toJson())

	FwFreeObj(oItem)

Return aResult

/*/{Protheus.doc} GET OPOPERACAO /api/pcp/v1/pcpa152res/ordemProducao/opcional/{programacao}/{ordemProducao}
Retorna as operações de uma ordem de produção

@type WSMETHOD
@author breno.ferreira
@since 29/10/2024
@version P12.1.24
@param 01 programacao, Caracter, programação do CRP
@param 02 ordemProducao, Caracter, Ordem de produção do CRP
@param 03 Page       , Numérico, Número da página a ser buscada
@param 04 PageSize   , Numérico, Tamanho da página
@return   lReturn      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPOPERACAO QUERYPARAM programacao, ordemProducao, page, pageSize WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOpOper(Self:programacao, Self:ordemProducao, Self:page, Self:pageSize)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getOpOper
Retorna os dados de uma ordem de produção

@type Static Function
@author breno.ferreira
@since 29/10/2024
@version P12.1.2410
@param 01 cProg, Character, programação do CRP
@param 02 cOp, Character, ordem de produção do CRP
@param 03 nPage, Numérico, Número da página a ser buscada
@param 04 nPageSize, Numérico, Tamanho da página
@return   aResult , Array   , Array com as informacoes da requisicao
/*/
Static Function getOpOper(cProg, cOp, nPage, nPageSize)
	Local aResult   := {}
	Local cAlias    := ""
	Local cQuery    := ""
	Local cTipo     := ""
	Local nCont     := 0
	Local nPosParam := 0
	Local nStart    := 0
	Local oItem     := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	If _oQryOpc == Nil
		_oQryOpc := FwExecStatement():New()

		cQuery += " SELECT DISTINCT SMF.MF_OPER as operacao, "
		cQuery +=                 " SMF.MF_RECURSO as recurso, "
		cQuery +=                 " SH1.H1_DESCRI as recDescri, "
		cQuery +=                 " SMF.MF_CTRAB as centTrab, "
		cQuery +=                 " SHB.HB_NOME as ctDescri, "
		cQuery +=                 " SMF.MF_TEMPO as tempo, "
		cQuery +=                 " SMF.MF_SETUP as setup, "
		cQuery +=                 " SMF.MF_TMPFINA as finalizacao, "
		cQuery +=                 " SMF.MF_SALDO as saldo, "
		cQuery +=                 " SH1.H1_ILIMITA as ilimitado, "
		If possuiHZ7()
			cQuery +=             " SMF.MF_TPOPER as tipo, "
			cQuery +=             " HZ7.HZ7_MAOOBR as maoObra, "
			cQuery +=             " HZ7.HZ7_SEQ as sequencia "
		Else
			cQuery +=             " '" + TIPO_OPERACAO_NORMAL + "' as tipo, "
			cQuery +=             " 0 as maoObra, "
			cQuery +=             " ' ' as sequencia "
		EndIf
		If dicCampo("MF_REMOCAO")
			cQuery +=             " , SMF.MF_REMOCAO remocao "
		EndIf
		cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
		cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
		cQuery +=     " ON SH1.H1_FILIAL  = ? "
		cQuery +=    " AND SH1.H1_CODIGO  = SMF.MF_RECURSO "
		cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SHB") + " SHB "
		cQuery +=     " ON SHB.HB_FILIAL  = ? "
		cQuery +=    " AND SHB.HB_COD     = SMF.MF_CTRAB "
		cQuery +=    " AND SHB.D_E_L_E_T_ = ' ' "
		If possuiHZ7()
			cQuery +=  " INNER JOIN " + RetSqlName("HZ7") + " HZ7 "
			cQuery +=     " ON HZ7.HZ7_FILIAL = ? "
			cQuery +=    " AND HZ7.HZ7_PROG   = SMF.MF_PROG "
			cQuery +=    " AND HZ7.HZ7_RECURS = SMF.MF_RECURSO "
			cQuery +=    " AND HZ7.HZ7_ID     = SMF.MF_ID "
			cQuery +=    " AND HZ7.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery +=  " WHERE SMF.MF_FILIAL  = ? "
		cQuery +=    " AND SMF.MF_PROG    = ? "
		cQuery +=    " AND SMF.MF_OP      = ? "
		cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
		cQuery +=  " ORDER BY operacao "

		_oQryOpc:setQuery(cQuery)
	EndIf

	nPosParam := 1

	_oQryOpc:SetString(nPosParam++, xFilial("SH1"))
	_oQryOpc:SetString(nPosParam++, xFilial("SHB"))
	If possuiHZ7()
		_oQryOpc:SetString(nPosParam++, xFilial("HZ7"))
	EndIf
	_oQryOpc:SetString(nPosParam++, xFilial("SMF"))
	_oQryOpc:SetString(nPosParam++, cProg)
	_oQryOpc:SetString(nPosParam++, cOp)

	cAlias := _oQryOpc:OpenAlias()

	If nPage >= 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oItem["items"] := {}

	While (cAlias)->(!Eof())
		nCont++
		aAdd(oItem["items"], JsonObject():New())

		If (cAlias)->tipo == TIPO_OPERACAO_NORMAL
			cTipo := STR0611//'Normal'

		ElseIf (cAlias)->tipo == TIPO_OPERACAO_TEMPO_FIXO
			cTipo := STR0612 //'Tempo Fixo'

		ElseIf (cAlias)->tipo == TIPO_OPERACAO_ILIMITADA
			cTipo := STR0613//'Ilimitado'

		ElseIf (cAlias)->tipo == TIPO_OPERACAO_TEMPO_MINIMO
			cTipo := STR0614 //'Tempo Minimo'

		EndIf

		oItem["items"][nCont]["operacao"         ] := (cAlias)->operacao
		oItem["items"][nCont]["recurso"          ] := Trim((cAlias)->recurso) + " - " + Trim((cAlias)->recDescri)
		oItem["items"][nCont]["centTrab"         ] := Trim((cAlias)->centTrab) + " - " + Trim((cAlias)->ctDescri)
		oItem["items"][nCont]["tempo"            ] := __Min2Hrs((cALias)->tempo, .T.)
		oItem["items"][nCont]["setup"            ] := __Min2Hrs((cAlias)->setup, .T.)
		oItem["items"][nCont]["finalizacao"      ] := __Min2Hrs((cAlias)->finalizacao, .T.)
		oItem["items"][nCont]["saldo"            ] := (cAlias)->saldo
		oItem["items"][nCont]["tipo"             ] := cTipo
		oItem["items"][nCont]["maoObra"          ] := (cAlias)->maoObra
		oItem["items"][nCont]["remocao"          ] := Iif(dicCampo("MF_REMOCAO"), __Min2Hrs((cAlias)->remocao, .T.), " ")
		oItem["items"][nCont]["alocouAlternativo"] := .F.
		oItem["items"][nCont]["recursoIlimitado" ] := (cAlias)->ilimitado == "S"

		If possuiHZ7()
			oItem["items"][nCont]["alocouAlternativo"] := (cAlias)->sequencia != PCPA152TempoOperacao():getSequenciaRecursoPrincipal()
		EndIf

		(cAlias)->(dbSkip())
		If nCont >= nPageSize
			Exit
		EndIf
	End

	oItem["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

	aAdd(aResult, .T.)
	aAdd(aResult, 200)
	aAdd(aResult, oItem:toJson())

	FwFreeObj(oItem)

Return aResult

/*/{Protheus.doc} GET FERRGANTT /api/pcp/v1/pcpa152res/{programacao}/ferramentas
Retorna as ferramentas utilizadas em uma programação.

@type WSMETHOD
@author Lucas Fagundes
@since 04/09/2025
@version P12
@param programacao   , Caracter, Código da programação do CRP.
@param page          , Numérico, Número da página a ser buscada.
@param pageSize      , Numérico, Tamanho da página (se passado 0, cancela a paginacao).
@param filter        , Caracter, Filtra o codigo da ferramenta (LIKE).
@param descricao     , Caracter, Filtro a descrição da ferramenta (LIKE).
@param comAlocacao   , Logico  , Apenas ferramentas com alocação.
@param ferramentas   , Caracter, Filtra o codigo das ferramentas (IN).
@param arvore        , Caracter, Filtra arvores.
@param ordemProducao , Caracter, Filtra ordens de produção.
@param centroTrabalho, Caracter, Filtra centros de trabalho.
@return lReturn, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET FERRGANTT PATHPARAM programacao QUERYPARAM page, pageSize, filter, descricao, comAlocacao, ferramentas, arvore, ordemProducao, centroTrabalho WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := ferrGantt(Self:programacao, Self:page, Self:pageSize, Self:filter, Self:descricao, Self:comAlocacao, Self:ferramentas, Self:arvore, Self:ordemProducao, Self:centroTrabalho)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	aSize(aReturn,  0)
Return lReturn

/*/{Protheus.doc} ferrGantt
Busca as ferramentas utilizadas em uma programação.
@type  Static Function
@author Lucas Fagundes
@since 04/09/2025
@version P12
@param 01 cProg     , Caracter, Código da programação do CRP.
@param 02 nPage     , Numerico, Número da página a ser buscada.
@param 03 nPageSize , Numerico, Tamanho da página (se passado 0, cancela a paginacao).
@param 04 cCodigo   , Caracter, Filtra o codigo da ferramenta (LIKE).
@param 05 cDescricao, Caracter, Filtro a descrição da ferramenta (LIKE).
@param 06 lComAloc  , Logico  , Apenas ferramentas com alocação.
@param 07 cFerrams  , Caracter, Filtra o codigo das ferramentas (IN).
@param 08 cArvores  , Caracter, Filtra arvores (IN).
@param 09 cOrdens   , Caracter, Filtra ordens de produção (IN).
@param 10 cCTs      , Caracter, Filtra centros de trabalho (IN).
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function ferrGantt(cProg, nPage, nPageSize, cCodigo, cDescricao, lComAloc, cFerrams, cArvores, cOrdens, cCTs)
	Local aReturn  := Array(3)
	Local cAlias   := GetNextAlias()
	Local cQryCont := ""
	Local cQuery   := ""
	Local lPagina  := nPageSize > 0
	Local nPos     := 0
	Local nStart   := 0
	Local oReturn  := JsonObject():New()

	oReturn["total"      ] := 0
	oReturn["ferramentas"] := {}
	oReturn["hasNext"    ] := .F.

	cQuery := " SELECT DISTINCT HZJ.HZJ_FERRAM, SH4.H4_DESCRI "
	cQuery +=   " FROM " + RetSqlName("HZJ") + " HZJ "
	cQuery +=  " INNER JOIN " + RetSqlName("SH4") + " SH4 "
	cQuery +=     " ON SH4.H4_FILIAL  = '" + xFilial("SH4") + "' "
	cQuery +=    " AND SH4.H4_CODIGO  = HZJ.HZJ_FERRAM "
	If !Empty(cDescricao)
		cQuery += " AND SH4.H4_DESCRI LIKE '%" + cDescricao + "%' "
	EndIf
	cQuery +=    " AND SH4.D_E_L_E_T_ = ' ' "
	If lComAloc
		cQuery += " INNER JOIN " + RetSqlName("HZK") + " HZK "
		cQuery +=    " ON HZK.HZK_FILIAL = '" + xFilial("HZK") + "' "
		cQuery +=   " AND HZK.HZK_PROG   = HZJ.HZJ_PROG "
		cQuery +=   " AND HZK.HZK_ID     = HZJ.HZJ_ID "
		cQuery +=   " AND HZK.D_E_L_E_T_ = ' ' "
	EndIf
	If !Empty(cArvores) .Or. !Empty(cOrdens) .Or. !Empty(cCTs)
		cQuery += " INNER JOIN " + RetSqlName("SMF") + " SMF "
		cQuery +=    " ON SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
		cQuery +=   " AND SMF.MF_PROG    = HZJ.HZJ_PROG "
		cQuery +=   " AND SMF.MF_ID      = HZJ.HZJ_OPER "
		If !Empty(cOrdens)
			cQuery += " AND SMF.MF_OP IN ('" + StrTran(cOrdens, ",", "','") + "') "
		EndIf
		If !Empty(cArvores)
			cQuery += " AND SMF.MF_ARVORE IN ('" + StrTran(cArvores, ",", "','") + "') "
		EndIf
		If !Empty(cCTs)
			cQuery += " AND SMF.MF_CTRAB IN ('" + StrTran(cCTs, ",", "','") + "') "
		EndIf
		cQuery +=   " AND SMF.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery +=  " WHERE HZJ.HZJ_FILIAL = '" + xFilial("HZJ") + "' "
	cQuery +=    " AND HZJ.HZJ_PROG   = '" + cProg          + "' "
	If !Empty(cCodigo)
		cQuery += " AND HZJ.HZJ_FERRAM LIKE '" + cCodigo + "%' "
	EndIf
	If !Empty(cFerrams)
		cQuery += " AND HZJ.HZJ_FERRAM IN ('" + StrTran(cFerrams, ",", "','") + "') "
	EndIf
	cQuery +=    " AND HZJ.D_E_L_E_T_ = ' ' "

	If lPagina .And. nPage == 1
		cQryCont += " SELECT COUNT(cont.HZJ_FERRAM) total "
		cQryCont +=   " FROM (" + cQuery + ") cont "

		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQryCont), cAlias, .F., .F.)

		If (cAlias)->(!EoF())
			oReturn["total"] := (cAlias)->total
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf

	If !lPagina .Or. (oReturn["total"] > 0 .Or. nPage > 1)

		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

		If lPagina .And. nPage > 1
			nStart := ((nPage-1) * nPageSize)

			If nStart > 0
				(cAlias)->(dbSkip(nStart))
			EndIf
		EndIf

		While (cAlias)->(!EoF())
			nPos++

			aAdd(oReturn["ferramentas"], JsonObject():New())
			oReturn["ferramentas"][nPos]["ferramenta"] := (cAlias)->HZJ_FERRAM
			oReturn["ferramentas"][nPos]["descricao" ] := RTrim((cAlias)->HZJ_FERRAM) + " - " + (cAlias)->H4_DESCRI
			oReturn["ferramentas"][nPos]["color"     ] := "gray"

			(cAlias)->(dbSkip())
			If lPagina .And. nPos >= nPageSize
				Exit
			EndIf
		End

		oReturn["hasNext"] := (cAlias)->(!EoF())
		(cAlias)->(dbCloseArea())
	EndIf

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET ALOCFERR /api/pcp/v1/pcpa152res/{programacao}/ferramentas/alocacao
Retorna os periodos de alocação nas ferramentas

@type WSMETHOD
@author Lucas Fagundes
@since 04/09/2025
@version P12
@param programacao   , Caracter, Programação do CRP.
@param DataInicial   , Date    , Data inicial dos periodos.
@param DataFinal     , Date    , Data final dos periodos.
@param ferramentas   , Caracter, Ferramentas que irá retornar a alocação.
@param bloqueio      , Logico  , Filtro de horas bloqueadas.
@param efetivado     , Logico  , Filtro de horas efetivadas.
@param recursos      , Caracter, Filtro de recursos.
@param centroTrabalho, Caracter, Filtro de centro de trabalho.
@param ordemProducao , Caracter, Filtro de ordem de produção.
@param arvore        , Caracter, Filtro de arvore.
@param produto       , Caracter, Filtro de produto.
@param tipo          , Caracter, Filtro de tipo de produto.
@param grupo         , Caracter, Filtro de grupo de produto.
@return lReturn, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALOCFERR PATHPARAM programacao QUERYPARAM DataInicial, DataFinal, ferramentas, bloqueio, efetivado, recursos, centroTrabalho, ordemProducao, arvore, produto, tipo, grupo WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := alocFerr(Self:programacao, Self:DataInicial, Self:DataFinal, Self:ferramentas, Self:bloqueio, Self:efetivado, Self:recursos, Self:centroTrabalho, Self:ordemProducao, Self:arvore, Self:produto, Self:tipo, Self:grupo)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	aSize(aReturn, 0)
Return lReturn

/*/{Protheus.doc} alocFerr
Retorna a alocação das ferramentas para exibir na tela de capacidade.
@type  Static Function
@author Lucas Fagundes
@since 05/09/2025
@version P12
@param cProg     , Caracter, Programação do CRP.
@param dDataIni  , Date    , Data inicial dos periodos.
@param dDataFim  , Date    , Data final dos periodos.
@param cFerrams  , Array   , Ferramentas que irá retornar a alocação.
@param lBloqueios, Logico  , Filtro de horas bloqueadas.
@param lEfetivado, Logico  , Filtro de horas efetivadas.
@param cRecursos , Array   , Filtro de recursos.
@param cCTs      , Array   , Filtro de centro de trabalho.
@param cOrdens   , Array   , Filtro de ordem de produção.
@param cArvores  , Array   , Filtro de arvore.
@param cProdutos , Array   , Filtro de produto.
@param cTipos    , Array   , Filtro de tipo de produto.
@param cGrupos   , Array   , Filtro de grupo de produto.
@return aReturn, Array, Array coms as informações de retorno da API.
/*/
Static Function alocFerr(cProg, dDataIni, dDataFim, cFerrams, lBloqueios, lEfetivado, cRecursos, cCTs, cOrdens, cArvores, cProdutos, cTipos, cGrupos)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local oEvent  := Nil
	Local oReturn := JsonObject():New()

	cFerrams := StrTran(cFerrams, ",", "','")

	cQuery := " SELECT SMF.MF_OP ordemProducao, "
	cQuery +=        " SMF.MF_RECURSO recurso, "
	cQuery +=        " SMF.MF_OPER operacao, "
	cQuery +=        " SC2.C2_PRODUTO produto, "
	cQuery +=        " HZJ.HZJ_FERRAM ferramenta, "
	cQuery +=        " SH4.H4_DESCRI descricao, "
	cQuery +=        " HZK.HZK_DATA data, "
	cQuery +=        " HZK.HZK_INICIO inicio, "
	cQuery +=        " HZK.HZK_FIM fim, "
	cQuery +=        " SVM.VM_TIPO tipoSVM, "
	cQuery +=        " '' tipoSMK, "
	cQuery +=        " 'HZK' origem, "
	cQuery +=        " CASE "
	cQuery +=            " WHEN SC2.C2_STATUS = 'S' THEN 'E' "
	cQuery +=            " ELSE SC2.C2_STATUS "
	cQuery +=        " END statusOP, "
	cQuery +=        " SMF.MF_ARVORE arvore "
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	cQuery +=  " INNER JOIN " + RetSqlName("HZJ") + " HZJ "
	cQuery +=     " ON HZJ.HZJ_FILIAL  = '" + xFilial("HZJ") + "' "
	cQuery +=    " AND HZJ.HZJ_PROG    = SMF.MF_PROG "
	cQuery +=    " AND HZJ.HZJ_OPER    = SMF.MF_ID "
	cQuery +=    " AND HZJ.HZJ_FERRAM IN ('" + cFerrams + "') "
	cQuery +=    " AND HZJ.D_E_L_E_T_  = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("HZK") + " HZK "
	cQuery +=     " ON HZK_FILIAL     = '" + xFilial("HZK") + "' "
	cQuery +=    " AND HZK.HZK_PROG   = HZJ.HZJ_PROG "
	cQuery +=    " AND HZK.HZK_ID     = HZJ.HZJ_ID  "
	cQuery +=    " AND HZK.HZK_DATA  >= '" + DToS(dDataIni) + "' "
	cQuery +=    " AND HZK.HZK_DATA  <= '" + DToS(dDataFim) + "' "
	cQuery +=    " AND HZK.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND " + PCPQrySC2("SC2", "SMF.MF_OP")
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
	If !Empty(cProdutos)
		cQuery += " AND SB1.B1_COD IN ('" + StrTran(cProdutos, ",", "','") + "') "
	EndIf
	If !Empty(cTipos)
		cQuery += " AND SB1.B1_TIPO IN ('" + StrTran(cTipos, ",", "','") + "') "
	EndIf
	If !Empty(cGrupos)
		cQuery += " AND SB1.B1_GRUPO IN ('" + StrTran(cGrupos, ",", "','") + "') "
	EndIf
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SVM") + " SVM "
	cQuery +=     " ON SVM.VM_FILIAL  = '" + xFilial("SVM") + "' "
	cQuery +=    " AND SVM.VM_PROG    = HZK.HZK_PROG "
	cQuery +=    " AND SVM.VM_ID      = HZK.HZK_IDOPER "
	cQuery +=    " AND SVM.VM_SEQ     = HZK.HZK_SEQALO "
	cQuery +=    " AND SVM.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SH4") + " SH4 "
	cQuery +=     " ON SH4.H4_FILIAL  = '" + xFilial("SH4") + "' "
	cQuery +=    " AND SH4.H4_CODIGO  = HZJ.HZJ_FERRAM "
	cQuery +=    " AND SH4.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
	cQuery +=    " AND SMF.MF_PROG    = '" + cProg          + "' "
	If !Empty(cRecursos)
		cQuery += " AND SMF.MF_RECURSO IN ('" + StrTran(cRecursos, ",", "','") + "') "
	EndIf
	If !Empty(cCTs)
		cQuery += " AND SMF.MF_CTRAB IN ('" + StrTran(cCTs, ",", "','") + "') "
	EndIf
	If !Empty(cOrdens)
		cQuery += " AND SMF.MF_OP IN ('" + StrTran(cOrdens, ",", "','") + "') "
	EndIf
	If !Empty(cArvores)
		cQuery += " AND SMF.MF_ARVORE IN ('" + StrTran(cArvores, ",", "','") + "') "
	EndIf
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "

	If lBloqueios .Or. lEfetivado
		cQuery +=  " UNION ALL "
		cQuery += " SELECT '' ordemProducao, "
		cQuery +=        " '' recurso, "
		cQuery +=        " '' operacao, "
		cQuery +=        " '' produto, "
		cQuery +=        " SMR.MR_RECURSO ferramenta, "
		cQuery +=        " SH4.H4_DESCRI descricao, "
		cQuery +=        " SMK.MK_DATDISP data, "
		cQuery +=        " SMK.MK_HRINI inicio, "
		cQuery +=        " SMK.MK_HRFIM fim, "
		cQuery +=        " 0 tipoSVM, "
		cQuery +=        " SMK.MK_TIPO tipoSMK, "
		cQuery +=        " 'SMK' origem, "
		cQuery +=        " '' statusOP, "
		cQuery +=        " '' arvore "
		cQuery +=   " FROM " + RetSqlName("SMR") + " SMR "
		cQuery +=  " INNER JOIN " + RetSqlName("SMK") + " SMK "
		cQuery +=     " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "' "
		cQuery +=    " AND SMK.MK_PROG    = SMR.MR_PROG "
		cQuery +=    " AND SMK.MK_DISP    = SMR.MR_DISP "
		If !lBloqueios
			cQuery += " AND SMK.MK_BLOQUE = '" + HORA_NAO_BLOQUEADA + "' "
		EndIf
		If !lEfetivado
			cQuery += " AND SMK.MK_TIPO  != '" + HORA_EFETIVADA + "' "
		EndIf
		cQuery +=    " AND SMK.D_E_L_E_T_ = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("SH4") + " SH4 "
		cQuery +=     " ON SH4.H4_FILIAL  = '" + xFilial("SH4") + "' "
		cQuery +=    " AND SH4.H4_CODIGO  = SMR.MR_RECURSO "
		cQuery +=    " AND SH4.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE SMR.MR_FILIAL   = '" + xFilial("SMR") + "' "
		cQuery +=    " AND SMR.MR_PROG     = '" + cProg + "' "
		cQuery +=    " AND SMR.MR_RECURSO IN ('" + cFerrams + "') "
		cQuery +=    " AND SMR.MR_TIPO     = '" + MR_TIPO_FERRAMENTA + "' "
		cQuery +=    " AND SMR.D_E_L_E_T_  = ' ' "
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	TcSetField(cAlias, 'data', 'D', GetSx3Cache("HZK_DATA", "X3_TAMANHO"), 0)

	oReturn["eventos"] := {}

	While (cAlias)->(!EoF())
		oEvent := JsonObject():New()

		oEvent["start"        ] := getDataJS((cAlias)->data, (cAlias)->inicio)
		oEvent["end"          ] := getDataJS((cAlias)->data, (cAlias)->fim)
		oEvent["resourceId"   ] := (cAlias)->recurso
		oEvent["ferramenta"   ] := (cAlias)->ferramenta
		oEvent["description"  ] := RTrim((cAlias)->descricao)
		oEvent["ordemProducao"] := (cAlias)->ordemProducao
		oEvent["operacao"     ] := (cAlias)->operacao
		oEvent["status"       ] := (cAlias)->statusOP
		oEvent["arvore"       ] := (cAlias)->arvore
		oEvent["folder"       ] := 'ferramentas'

		If (cAlias)->origem == "HZK"
			oEvent["title"] := i18n(STR0696, {Rtrim((cAlias)->ordemProducao), RTrim((cAlias)->recurso),; // "OP: #1[ordemProducao]#, Recurso: #2[recurso]#, Operação: #3[operacao]#, Produto: #4[produto]#"
			                                  RTrim((cAlias)->operacao), RTrim((cAlias)->produto)})
			oEvent["tipo" ] := cValToChar((cAlias)->tipoSVM)
		Else
			oEvent["title"] := "."
			oEvent["tipo" ] := Iif((cAlias)->tipoSMK == HORA_EFETIVADA, "E", "B")
		EndIf

		aAdd(oReturn["eventos"], oEvent)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
Return aReturn
