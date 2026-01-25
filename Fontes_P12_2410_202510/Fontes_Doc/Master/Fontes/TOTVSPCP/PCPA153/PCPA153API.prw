#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA153.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE DEF_MRP_NTHREADS      8
#DEFINE DEF_ESPERA_ABERTURA   600

#DEFINE DEF_GLOBAL_ERRO       "MRP_DIAGNOSTICO_ERRO"
#DEFINE DEF_GLOBAL_MULTI_THR  "MRP_DIAGNOSTICO_MULTI_THREAD"
#DEFINE DEF_SEMAFORO_THREADS  "MRP_DIAGNOSTICO_SEMAFORO"
#DEFINE DEF_UID_ERROS         "MRP_DIAGNOSTICO_ERR"

#DEFINE DEF_UID_GLOBAL_AUX    "MRP_DIAGNOSTICO_GLB_AUX"
#DEFINE DEF_GLOBAL_FILIAIS    "MRP_DIAGNOSTICO_AFILIAIS"

#DEFINE DEF_UID_GLOBAL_STATUS "MRP_DIAGNOSTICO_UID_GLB"

//DEFINES dos agrupadores das validações
#DEFINE DEF_GRP_THREADS       "01-THREADS"
#DEFINE DEF_GRP_TABELAS       "02-TABELAS"
#DEFINE DEF_GRP_PROCEDURE     "03-PROCEDURE"
#DEFINE DEF_GRP_APPSERVER     "04-APPSERVER"
#DEFINE DEF_GRP_DBACCESS      "05-DBACCESS"
#DEFINE DEF_GRP_INTEGRACAO    "06-INTEGRACAO"
#DEFINE DEF_GRP_PERMISSAO     "07-PERMISSAO"
#DEFINE DEF_GRP_MULTIEMPRESA  "08-MULTIEMPRESA"
#DEFINE DEF_GRP_ESTRUTURA     "09-ESTRUTURA"
#DEFINE DEF_GRP_PRODUTO       "10-PRODUTO"

//DEFINES dos códigos das validações
#DEFINE DEF_COD_THR_ABERTURA  "THR_01"
#DEFINE DEF_COD_TAB_COMP_CCC  "TAB_01"
#DEFINE DEF_COD_TAB_COMP_EEE  "TAB_02"
#DEFINE DEF_COD_TAB_COMP_E_M  "TAB_03"
#DEFINE DEF_COD_TAB_TAM_CAMPO "TAB_04"
#DEFINE DEF_COD_PRC_24        "PRC_01"
#DEFINE DEF_COD_APP_MEMORY    "APP_01"
#DEFINE DEF_COD_APP_HEAP      "APP_02"
#DEFINE DEF_COD_APP_STRING    "APP_03"
#DEFINE DEF_COD_APP_FLOATING  "APP_04"
#DEFINE DEF_COD_DBA_BUILD     "DBA_01"
#DEFINE DEF_COD_DBA_STRING    "DBA_02"
#DEFINE DEF_COD_DBA_POSTGRES  "DBA_03"
#DEFINE DEF_COD_MUL_UTILIZA   "MUL_01"
#DEFINE DEF_COD_MUL_TABELAS   "MUL_02"
#DEFINE DEF_COD_MUL_FIL_CORR  "MUL_03"
#DEFINE DEF_COD_MUL_TES       "MUL_04"
#DEFINE DEF_COD_MUL_VLD_GRP   "MUL_05"
#DEFINE DEF_COD_MUL_CLIENTES  "MUL_06"
#DEFINE DEF_COD_MUL_COND_PAG  "MUL_07"
#DEFINE DEF_COD_MUL_FORNECED  "MUL_08"
#DEFINE DEF_COD_MUL_DEPCIRC   "MUL_09"
#DEFINE DEF_COD_MUL_FILCOM    "MUL_10"
#DEFINE DEF_COD_INT_ATIVA     "INT_01"
#DEFINE DEF_COD_INT_ALTERADA  "INT_02"
#DEFINE DEF_COD_INT_PENDEN    "INT_03"
#DEFINE DEF_COD_INT_TRIGGERS  "INT_04"
#DEFINE DEF_COD_INT_LIMPEZA   "INT_05"
#DEFINE DEF_COD_INT_JOBS      "INT_06"
#DEFINE DEF_COD_PER_BLOQ_FIL  "PER_01"
#DEFINE DEF_COD_PER_EM_USO    "PER_02"
#DEFINE DEF_COD_EST_RECURSIVA "EST_01"
#DEFINE DEF_COD_PRD_QUEBRA_LE "PRD_01"
#DEFINE DEF_COD_PRD_QUEBRA_LM "PRD_02"
#DEFINE DEF_COD_PRD_QUEBRA_EM "PRD_04"
#DEFINE DEF_QTD_VALIDACOES    35

//DEFINES para os status das validações
#DEFINE DEF_STATUS_PENDING    "pending"
#DEFINE DEF_STATUS_STARTED    "started"
#DEFINE DEF_STATUS_SUCCESS    "success"
#DEFINE DEF_STATUS_ALERT      "warning"
#DEFINE DEF_STATUS_ERROR      "error"
#DEFINE DEF_STATUS_IGNORED    "ignored"

//DEFINES para a gestão de procedures
#DEFINE DEF_SPS_FROM_RPO      "1"
#DEFINE DEF_SPS_UPDATED       "0"

Static __aFiliais := {}
Static __oFiliais := Nil

/*

FALTA IMPLEMENTAR:
==================
- Validação Multiempresa: Cliente/Fornecedor com o campo "Fil. Transf" preenchido (Alerta)
- Processamento travado: Ver alguma forma de liberar
*/

/*/{Protheus.doc} PCPdiagnosticoAPI
API que faz as validações da tela de Diagnóstico do MRP

@type WSCLASS
@author marcelo.neumann
@since 01/12/2023
@version P12
/*/
WSRESTFUL PCPDiagnosticoAPI DESCRIPTION STR0001//"API REST do Diagnóstico do MRP"

	WSDATA code AS STRING  OPTIONAL

	WSMETHOD GET LIST;
		DESCRIPTION STR0002; //"Retorna a lista de validações da tela de diagnóstico do MRP"
		WSSYNTAX "/api/pcp/v1/pcpdiagnosticoapi/list";
		PATH "/api/pcp/v1/pcpdiagnosticoapi/list";
		TTALK "v1"

	WSMETHOD GET START;
		DESCRIPTION STR0003; //"Inicia as validações da tela de diagnóstico do MRP"
		WSSYNTAX "/api/pcp/v1/pcpdiagnosticoapi/start";
		PATH "/api/pcp/v1/pcpdiagnosticoapi/start";
		TTALK "v1"

	WSMETHOD GET STATUS;
		DESCRIPTION STR0004; //"Recupera o status das validações"
		WSSYNTAX "/api/pcp/v1/pcpdiagnosticoapi/status";
		PATH "/api/pcp/v1/pcpdiagnosticoapi/status";
		TTALK "v1"

	/*SCHEDULER*/
	WSMETHOD GET SCHEDULER;
		DESCRIPTION STR0005; //"Retorna as integrações de api do MRP"
		WSSYNTAX "/api/pcp/v1/pcpdiagnosticoapi/scheduler";
		PATH "/api/pcp/v1/pcpdiagnosticoapi/scheduler";
		TTALK "v1"

	/*SCHEDULER*/
	WSMETHOD POST SCHEDULER;
		DESCRIPTION STR0006; //"Cria novo agendamento"
		WSSYNTAX "/api/pcp/v1/pcpdiagnosticoapi/scheduler/new";
		PATH "/api/pcp/v1/pcpdiagnosticoapi/scheduler/new";
		TTALK "v1"

	WSMETHOD DELETE SCHEDULER;
		DESCRIPTION STR0166; //"Exclui um agendamento"
		WSSYNTAX "/api/pcp/v1/pcpdiagnosticoapi/scheduler/{code}";
		PATH "/api/pcp/v1/pcpdiagnosticoapi/scheduler/{code}";
		TTALK "v1"

END WSRESTFUL

/*/{Protheus.doc} WSMETHOD GET LIST /api/pcp/v1/pcpdiagnosticoapi/list
Retorna a lista de validações da tela de diagnóstico do MRP

@type WSMETHOD
@author marcelo.neumann
@since 01/12/2023
@version P12
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET LIST WSSERVICE PCPdiagnosticoAPI
    Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA153"), Break(oError)})
    Local lReturn   := .T.

    ::SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getList()
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getList
Retorna a lista de validações da tela de diagnóstico do MRP

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return aReturn, Array, Array com as informações para retorno da API
/*/
Static Function getList()
    Local aReturn := Array(3)
    Local oJson   := JsonObject():New()

    oJson["hasNext"] := .F.
	oJson["items"  ] := getValidac()

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oJson:ToJson()

    aSize(oJson["items"], 0)
	FwFreeObj(oJson)

Return aReturn

/*/{Protheus.doc} getValidac
Busca todas as validações que a rotina faz

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return aValidac, Array, Array com as validações que a rotina faz com status Pendente
/*/
Static Function getValidac()
    Local aValidac := Array(DEF_QTD_VALIDACOES)
	Local nOrdem   := 1

	aValidac[nOrdem++] := jsonValida(DEF_GRP_THREADS     , DEF_COD_THR_ABERTURA , STR0007 ) //"Abertura de threads."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_TABELAS     , DEF_COD_TAB_COMP_CCC , STR0008 ) //"Compartilhamento das tabelas de controle."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_TABELAS     , DEF_COD_TAB_COMP_EEE , STR0009 ) //"Compartilhamento das tabelas de resultados."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_TABELAS     , DEF_COD_TAB_COMP_E_M , STR0010 ) //"Compartilhamento das tabelas compatíveis entre ERP e MRP."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_TABELAS     , DEF_COD_TAB_TAM_CAMPO, STR0011 ) //"Tamanho dos campos compatíveis entre ERP e MRP."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_PROCEDURE   , DEF_COD_PRC_24       , STR0012 ) //"Procedure 024 instalada e atualizada."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_APPSERVER   , DEF_COD_APP_MEMORY   , STR0015 ) //"Chave ServerMemoryLimit (AppServer) definida."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_APPSERVER   , DEF_COD_APP_HEAP     , STR0016 ) //"Chave HeapLimit (AppServer) definida."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_APPSERVER   , DEF_COD_APP_STRING   , STR0017 ) //"Chave MAXSTRINGSIZE (AppServer) definida."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_APPSERVER   , DEF_COD_APP_FLOATING , STR0018 ) //"Chave FloatingPointPrecise (AppServer) definida."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_DBACCESS    , DEF_COD_DBA_BUILD    , STR0020 ) //"Build do DbAccess compatível com o MRP."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_DBACCESS    , DEF_COD_DBA_STRING   , STR0021 ) //"Chave MAXSTRINGSIZE (DbAccess) definida."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_DBACCESS    , DEF_COD_DBA_POSTGRES , STR0022 ) //"Banco de dados suportado pelo MRP."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_UTILIZA  , STR0023 ) //"Valida a utilização do MRP Multi-Empresa."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_TABELAS  , STR0024 ) //"Tabelas de Produtos e Alternativos compartilhadas em todos os níveis (CCC)."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_FIL_CORR , STR0025 ) //"A Filial atual é a Filial Centralizadora."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_TES      , STR0026 ) //"Tipo de Entrada e Saída (TES) informado."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_VLD_GRP  , STR0027 ) //"Todas as filiais pertencem ao mesmo Grupo."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_CLIENTES , STR0028 ) //"As filiais são clientes umas das outras."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_COND_PAG , STR0029 ) //"Estão configuradas as Condições de Pagamento entre as filiais."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_FORNECED , STR0030 ) //"As filiais são fornecedoras umas das outras."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_DEPCIRC  , STR0209 ) //"Existem ciclos entre as filiais de compra."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_MULTIEMPRESA, DEF_COD_MUL_FILCOM   , STR0210 ) //"Filiais de compra dentro do grupo de empresas centralizadas"
	aValidac[nOrdem++] := jsonValida(DEF_GRP_INTEGRACAO  , DEF_COD_INT_ATIVA    , STR0031 ) //"Integração com o MRP habilitada."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_INTEGRACAO  , DEF_COD_INT_ALTERADA , STR0032 ) //"Sincronização dos dados (PCPA140)."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_INTEGRACAO  , DEF_COD_INT_PENDEN   , STR0033 ) //"Registros pendentes de integração."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_INTEGRACAO  , DEF_COD_INT_TRIGGERS , STR0034 ) //"Triggers atualizadas no banco de dados."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_INTEGRACAO  , DEF_COD_INT_LIMPEZA  , STR0035 ) //"Limpeza dos registros já integrados."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_INTEGRACAO  , DEF_COD_INT_JOBS     , STR0036 ) //"Agendamentos de integrações de tipo Schedule configurados."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_PERMISSAO   , DEF_COD_PER_BLOQ_FIL , STR0038 ) //"Bloqueio de execução na filial corrente."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_PERMISSAO   , DEF_COD_PER_EM_USO   , STR0039 ) //"MRP liberado para execução."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_ESTRUTURA   , DEF_COD_EST_RECURSIVA, STR0040 ) //"Recursividade nas estruturas de produtos."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_PRODUTO     , DEF_COD_PRD_QUEBRA_LE, STR0041 ) //"Produto com Lote Econômico com quantidade pequena."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_PRODUTO     , DEF_COD_PRD_QUEBRA_LM, STR0042 ) //"Produto com Lote Mínimo com quantidade pequena."
	aValidac[nOrdem++] := jsonValida(DEF_GRP_PRODUTO     , DEF_COD_PRD_QUEBRA_EM, STR0044 ) //"Produto com Quantidade de Embalagem pequena."

Return aValidac

/*/{Protheus.doc} jsonValida
Adiciona uma validação na lista

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 cAgrupador, Caracter  , Código do agrupador de validações
@param 02 cCodigo   , Caracter  , Código identificador da validação
@param 03 cDescricao, Caracter  , Descrição da validação
@return   oJson     , JsonObject, Objeto com o registro da validação com status Pendente
/*/
Static Function jsonValida(cAgrupador, cCodigo, cDescricao)
	Local oJson := JsonObject():New()

    oJson["agrupador"] := cAgrupador
    oJson["descGrupo"] := descAgrup(cAgrupador)
    oJson["codigo"   ] := cCodigo
    oJson["descricao"] := cDescricao
    oJson["status"   ] := DEF_STATUS_PENDING
    oJson["problema" ] := ""
    oJson["solucao"  ] := ""

Return oJson

/*/{Protheus.doc} WSMETHOD GET STATUS /api/pcp/v1/pcpdiagnosticoapi/status
Retorna o status das validações

@type WSMETHOD
@author marcelo.neumann
@since 01/12/2023
@version P12
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET STATUS WSSERVICE PCPdiagnosticoAPI
    Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA153"), Break(oError)})
    Local lReturn   := .T.

    ::SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getStatus()
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getStatus
Retorna o status das validações

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return aReturn, Array, Array com as informações para retorno da API
/*/
Static Function getStatus()
    Local aReturn    := Array(3)
	Local aStatus    := {}
	Local cErro      := ""
	Local nIndex     := 1
	Local nPosCopy   := 1
	Local nLenStatus := 0
    Local oJson      := JsonObject():New()

	cErro := GetGlbValue(DEF_GLOBAL_ERRO)

	If Empty(cErro)
		If VarGetAA(DEF_UID_GLOBAL_STATUS, aStatus)
			oJson["items"] := Array(DEF_QTD_VALIDACOES)

			aSort(aStatus, , , {|x,y| x[1] < y[1]})

			nLenStatus := Len(aStatus)
			For nIndex := 1 To nLenStatus
				aCopy(aStatus[nIndex][2], oJson["items"], , , nPosCopy)
				nPosCopy += Len(aStatus[nIndex][2])
			Next nIndex

			oJson["hasNext"] := aScan(oJson["items"], {|x| x["status"] == DEF_STATUS_PENDING .Or. x["status"] == DEF_STATUS_STARTED}) > 0

			aReturn[1] := .T.
			aReturn[2] := 200
			aReturn[3] := oJson:ToJson()

			If !oJson["hasNext"]
				finalProc()
			EndIf

    		aSize(oJson["items"], 0)
			aSize(aStatus, 0)
		Else
			aReturn[1] := .T.
			aReturn[2] := 200
			aReturn[3] := oJson:ToJson()
		EndIf
	Else
		aReturn := formatErro()
		finalProc()
	EndIf

	FwFreeObj(oJson)

Return aReturn

/*/{Protheus.doc} WSMETHOD GET START /api/pcp/v1/pcpdiagnosticoapi/start
Inicia as validações da tela de diagnóstico do MRP

@type WSMETHOD
@author marcelo.neumann
@since 01/12/2023
@version P12
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET START WSSERVICE PCPdiagnosticoAPI
    Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA153"), Break(oError)})
    Local lReturn   := .T.

    ::SetContentType("application/json")

	BEGIN SEQUENCE
		If iniGlobais()
			iniciaVld()
		EndIf

		aReturn := getStatus()
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} iniciaVld
Inicia o processamento das validações

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Static Function iniciaVld()

	If abreThreads()
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153Tabela")
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153Proced")
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153AppSer")
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153DbAcce")
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153MultEm")
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153Integr")
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153Permis")
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153Estrut")
		PCPIPCGO(DEF_SEMAFORO_THREADS, .F., "P153Produt")
	Else
		P153Tabela()
		P153Proced()
		P153AppSer()
		P153DbAcce()
		P153MultEm()
		P153Integr()
		P153Permis()
		P153Estrut()
		P153Produt()
	EndIf

Return Nil

/*/{Protheus.doc} iniGlobais
Inicia as variáveis globais utilizadas no processo

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return lSucesso, Lógico, Indica se as variáveis globais foram iniciadas com sucesso
/*/
Static Function iniGlobais()
	Local aInserir := {}
    Local aValidac := {}
	Local cErro    := ""
	Local lSucesso := .F.
	Local nIndex   := 1

    If VarSetUID(DEF_UID_GLOBAL_STATUS)
		aValidac := getValidac()

		For nIndex := 1 To DEF_QTD_VALIDACOES
			aValidac[nIndex]["status"] := DEF_STATUS_STARTED
			aAdd(aInserir, aValidac[nIndex])

			If nIndex == DEF_QTD_VALIDACOES .Or. aValidac[nIndex]["agrupador"] <> aValidac[nIndex+1]["agrupador"]
				lSucesso := VarSetAD(DEF_UID_GLOBAL_STATUS, aValidac[nIndex]["agrupador"], aInserir)
				aSize(aInserir, 0)

				If !lSucesso
					cErro := I18N(STR0046, {aValidac[nIndex]["agrupador"], DEF_UID_GLOBAL_STATUS }) //"Erro ao criar a lista #1[agrupador]# na seção de variáveis globais #2[secao]#."
					Exit
				EndIf
			EndIf
		Next nIndex

		aSize(aValidac, 0)
	Else
		cErro := I18N(STR0048, {DEF_UID_GLOBAL_STATUS} ) //"Erro ao criar a seção de variáveis globais #1[STATUS]#."
	EndIf

    If lSucesso .And. !VarSetUID(DEF_UID_GLOBAL_AUX)
		P153Error( I18N(STR0048, {DEF_UID_GLOBAL_AUX} ) ) //"Erro ao criar a seção de variáveis globais "
		lSucesso := .F.
	EndIf

	If !lSucesso
		P153Error(cErro)
	EndIf

Return lSucesso

/*/{Protheus.doc} abreThreads
Abre as threads do processamento

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return lAbriu, Lógico, Indica se as threads foram abertas
/*/
Static Function abreThreads()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_THREADS
	Local lAbriu     := .F.

	PutGlbValue(DEF_GLOBAL_MULTI_THR, "N")

	If !recGlobal(cAgrupador, @aStatus)
		Return lAbriu
	EndIf

	//DEF_COD_THR_ABERTURA
	lAbriu := iniThreads(@aStatus[1])

	gravaStats(cAgrupador, aStatus)

Return lAbriu

/*/{Protheus.doc} iniThreads
Cria e inicializa as threads do processamento

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function iniThreads(oStatus)
	Local lAbriu := .F.

	formSucess(@oStatus)

	PCPIPCStart(DEF_SEMAFORO_THREADS, DEF_MRP_NTHREADS, Nil, cEmpAnt, cFilAnt, DEF_UID_ERROS, 'P153Error()')

	If PCPIPCWIni(DEF_SEMAFORO_THREADS, DEF_ESPERA_ABERTURA)
		lAbriu := .T.
		PutGlbValue(DEF_GLOBAL_MULTI_THR, "S")
	Else
		oStatus["problema"] := I18N(STR0050, {cValToChar(DEF_MRP_NTHREADS)} ) //"Para a execução do MRP são necessárias #1[THREADS]# novas threads. Ocorreu algum erro que impediu as threads de serem abertas nesse ambiente."
		oStatus["solucao" ] := STR0052 //"Verifique se há algum limite de abertura de novas conexões definido no servidor."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

Return lAbriu

/*/{Protheus.doc} gravaStats
Grava a variável global com o status atual

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12P153Error
@param 01 cAgrupador, Caracter, Identificador do agrupador (lista da variável global)
@param 02 aStatus   , Array   , Status a ser gravado na variável global
@return Nil
/*/
Static Function gravaStats(cAgrupador, aStatus)

	If !VarSetAD(DEF_UID_GLOBAL_STATUS, cAgrupador, aStatus)
		P153Error(I18N(STR0053, {cAgrupador})) //"Ocorreu um erro ao gravar a variável global do agrupador: #1[AGRUPADOR]#"
	EndIf

Return

/*/{Protheus.doc} P153Error
Função centralizadora para o tratamento de erros do processo

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param cErroDet, Caracter, Erro a ser gravado e retornado pelo getStatus()
@return Nil
/*/
Function P153Error(cErroDet)
	Local oError := Nil

    If Empty(cErroDet)
        oError := PCPMultiThreadError():New(DEF_UID_ERROS, .F.)
        cErroDet := oError:getcError()
	EndIf

	PutGlbValue(DEF_GLOBAL_ERRO, cErroDet)
	FWLogMsg("ERROR", , "PCPA153", , , , cErroDet)

Return

/*/{Protheus.doc} formSucess
Retorna o json formatado como Sucesso

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function formSucess(oStatus)

	oStatus["problema"] := ""
	oStatus["solucao" ] := ""
	oStatus["status"  ] := DEF_STATUS_SUCCESS

Return

/*/{Protheus.doc} formIgnore
Retorna o json formatado como Sucesso

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@param 02 cDesc  , Caracter  , Mensagem com o motivo ao qual foi ignorado
@return Nil
/*/
Static Function formIgnore(oStatus, cDesc)
	Default cDesc := ""

	oStatus["problema"] := cDesc
	oStatus["solucao" ] := ""
	oStatus["status"  ] := DEF_STATUS_IGNORED

Return

/*/{Protheus.doc} formatErro
Formata o erro para retorno da API

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return aReturn, Array, Array com o erro formatado para retorno da API
/*/
Static Function formatErro()
    Local aReturn := Array(3)
	Local oJson   := JsonObject():New()

	oJson["items"          ] := {}
	oJson["message"        ] := STR0054 //"Problema na execução do diagnóstico."
	oJson["detailedMessage"] := GetGlbValue(DEF_GLOBAL_ERRO)

	aReturn[1] := .F.
	aReturn[2] := 400
	aReturn[3] := oJson:ToJson()

Return aReturn

/*/{Protheus.doc} finalProc
Cancela o processo (limpa globais, encerra threads)

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Static Function finalProc()

	If GetGlbValue(DEF_GLOBAL_MULTI_THR) == "S"
		PCPIPCFinish(DEF_SEMAFORO_THREADS, 10, DEF_MRP_NTHREADS)
	EndIf

	limpaGlb()

Return

/*/{Protheus.doc} limpaGlb
Limpa as variáveis globais

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Static Function limpaGlb()

	VarClean(DEF_UID_GLOBAL_STATUS)
	VarClean(DEF_UID_GLOBAL_AUX)

	ClearGlbValue(DEF_GLOBAL_MULTI_THR)
	ClearGlbValue(DEF_GLOBAL_ERRO)

Return

/*/{Protheus.doc} descAgrup
Retorna uma descrição para o agrupador

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param cAgrupador, Caracter, Código do agrupador
@return cDesAgrup, Caracter, Descrição do agrupador
/*/
Static Function descAgrup(cAgrupador)
	Local cDesAgrup := ""

	Do Case
		Case cAgrupador == DEF_GRP_THREADS
			cDesAgrup := STR0055 //"Threads"

		Case cAgrupador == DEF_GRP_TABELAS
			cDesAgrup := STR0056 //"Tabelas"

		Case cAgrupador == DEF_GRP_PROCEDURE
			cDesAgrup := STR0057 //"Procedure"

		Case cAgrupador == DEF_GRP_APPSERVER
			cDesAgrup := "AppServer"

		Case cAgrupador == DEF_GRP_DBACCESS
			cDesAgrup := "DBAccess"

		Case cAgrupador == DEF_GRP_INTEGRACAO
			cDesAgrup := STR0058 //"Integrações"

		Case cAgrupador == DEF_GRP_PERMISSAO
			cDesAgrup := STR0059 //"Permissões"

		Case cAgrupador == DEF_GRP_MULTIEMPRESA
			cDesAgrup := STR0060 //"Multi-Empresa"

		Case cAgrupador == DEF_GRP_ESTRUTURA
			cDesAgrup := STR0061 //"Estruturas de Produtos"

		Case cAgrupador == DEF_GRP_PRODUTO
			cDesAgrup := STR0062 //"Cadastro de Produtos"

	EndCase

Return cDesAgrup

/*/{Protheus.doc} msgLog
Grava uma mensagem de log no console

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatus, JsonObject, Objeto com as informações da validação
@param 02 nTipo  , Numérico  , Indica se a mensagem é de início ou fim da validação (1-Início ; 2-Fim)
@return Nil
/*/
Static Function msgLog(oStatus, nTipo)
	Local cMensagem := oStatus["codigo"]

	If nTipo == 1
		cMensagem += " Inicio"
	Else
		cMensagem += " Fim " +  oStatus["status"]
	EndIf

	FWLogMsg("INFO", , "PCPA153", oStatus["agrupador"], , oStatus["codigo"], cMensagem)

Return

/*/{Protheus.doc} P153Tabela
Faz as validações referentes aos compartilhamentos de tabelas

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153Tabela()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_TABELAS

	If recGlobal(cAgrupador, @aStatus)
		//DEF_COD_TAB_COMP_CCC
		vlTabContr(@aStatus[1])

		//DEF_COD_TAB_COMP_EEE
		vlTabResul(@aStatus[2])

		//DEF_COD_TAB_COMP_E_M
		vlCompExM(@aStatus[3])

		//DEF_COD_TAB_TAM_CAMPO
		vlTamCampo(@aStatus[4])

		gravaStats(cAgrupador, aStatus)
	EndIf

Return

/*/{Protheus.doc} vlTabContr
Valida o compartilhamento das tabelas de Controle do MRP

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlTabContr(oStatus)
	Local cTabErro := ""

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	cTabErro += vlComparti("HWL", "CCC")
	cTabErro += vlComparti("SMQ", "CCC")
	cTabErro += vlComparti("T4P", "CCC")
	cTabErro += vlComparti("T4R", "CCC")
	cTabErro := AllTrim( Stuff(cTabErro, 1, 1, "") )

	If !Empty(StrTran(cTabErro, ",", ""))
		oStatus["problema"] := STR0066 //"Algumas tabelas de controle estão com o compartilhamento incorreto."
		oStatus["solucao" ] := STR0067  + cTabErro + "." //"Altere o modo de compartilhamento das tabelas de controle para 'Compartilhado' (CCC): "
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlTabResul
Valida o compartilhamento das tabelas de Resultados do MRP

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlTabResul(oStatus)
	Local cTabErro := ""

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	cTabErro += vlComparti("HW1", "EEE")
	cTabErro += vlComparti("HW3", "EEE")
	cTabErro += vlComparti("HWB", "EEE")
	cTabErro += vlComparti("HWC", "EEE")
	cTabErro += vlComparti("HWD", "EEE")
	cTabErro += vlComparti("HWG", "EEE")
	cTabErro += vlComparti("HWM", "EEE")
	cTabErro += vlComparti("SMA", "EEE")
	cTabErro += vlComparti("SMB", "EEE")
	cTabErro += vlComparti("SME", "EEE")
	cTabErro += vlComparti("SMH", "EEE")
	cTabErro += vlComparti("SMV", "EEE")
	cTabErro := AllTrim( Stuff(cTabErro, 1, 1, "") )

	If !Empty(StrTran(cTabErro, ",", ""))
		oStatus["problema"] := STR0068 //"Algumas tabelas de resultados estão com o compartilhamento incorreto."
		oStatus["solucao" ] := I18N(STR0069, {cTabErro}) //"Altere o modo de compartilhamento das tabelas de resultados para 'Exclusivo' (EEE): #1[ERRO]#."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlComparti
Valida se uma determinada tabela está Exclusiva ou Compartilhada

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 cTabela  , Caracter, Tabela a ser verificado o compartilhamento
@param 02 cModoComp, Caracter, Modo correto de compartilhamento para a validação
@return   cTabErro , Caracter, Retorna a tabela com problema de compartilhamento
/*/
Static Function vlComparti(cTabela, cModoComp)
	Local cTabErro := ""

	If FWModeAccess(cTabela,1) + FWModeAccess(cTabela,2) + FWModeAccess(cTabela,3) <> cModoComp
		cTabErro := ", " + cTabela
	EndIf

Return cTabErro

/*/{Protheus.doc} vlCompExM
Valida se o compartilhamento das tabelas estão compatíveis entre ERP e MRP

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlCompExM(oStatus)
	Local aRetVld   := {}
	Local nQtdErros := 0

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	aRetVld   := VCoMRPxERP()
	nQtdErros := Len(aRetVld)

	If nQtdErros > 0
		If nQtdErros == 1
			oStatus["problema"] := I18N(STR0070,{aRetVld[1][1][1], aRetVld[1][2][1]})  //"O compartilhamento da tabela #1[TABELA]# está incompatível com o da #2[TABELA2]#"."
			oStatus["solucao" ] := STR0072 //"Ajuste o compartilhamento da tabela via Configurador."
		Else
			oStatus["problema"] := I18N(STR0073, {cValToChar(nQtdErros)} ) //"Existem #1[QTERROS]# tabelas com compartilhamento incompatível."
			oStatus["solucao" ] := STR0075 //"Acesse a rotina de Parâmetros de Integração MRP (PCPA139) para acessar a lista completa de tabelas a serem ajustadas via Configurador."
		EndIf
		oStatus["status"] := DEF_STATUS_ERROR
	EndIf

	msgLog(oStatus, 2)

	aSize(aRetVld, 0)
Return

/*/{Protheus.doc} vlTamCampo
Valida se o tamanho dos campos estão compatíveis entre ERP e MRP.

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlTamCampo(oStatus)
	Local aRetVld := {}

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	aRetVld := VldCampTam()

	If aRetVld[3] > 0
		If aRetVld[3] == 1
			oStatus["problema"] := aRetVld[1]
			oStatus["solucao" ] := STR0076 //"Ajuste o tamanho do campo via Configurador."
		Else
			oStatus["problema"] := I18N(STR0074, {cValToChar(aRetVld[3])} ) //"Existem #1[QTCAMPOS]# campos com incompatibilidade."
			oStatus["solucao" ] := STR0078 //"Acesse a rotina de Sincronização (PCPA140) para acessar a lista completa de campos a serem ajustados via Configurador."
		EndIf
		oStatus["status"] := DEF_STATUS_ERROR
	EndIf

	msgLog(oStatus, 2)

	aSize(aRetVld, 0)
Return

/*/{Protheus.doc} P153Proced
Valida se a procedure está instalada e atualizada na base

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153Proced()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_PROCEDURE
	Local cIdProced  := "24"
	Local cProcNam   := ""
	Local cVerProc   := ""
	Local oInstall   := Nil
	Local oProcesso  := Nil
	Local oProcesRPO := Nil

	If !recGlobal(cAgrupador, @aStatus)
		Return
	EndIf

	aStatus[1]["problema"] := ""
	aStatus[1]["solucao" ] := ""
	aStatus[1]["status"  ] := DEF_STATUS_SUCCESS

	//DEF_COD_PRC_24
	//Verifica se é possivel utilizar as funções de instalação automatica de procedures
	If FindFunction("SPSMigrated") .and. SPSMigrated()
		oProcesso := EngSPSStatus(cIdProced)

		If oProcesso["status"] <> DEF_SPS_UPDATED
			oProcesRPO := EngSPSGetProcess(DEF_SPS_FROM_RPO, oProcesso["process"], /*empresa*/)

			//Realiza a instalação da procedure
			If oProcesRPO["status"] <> "FALSE"
				oInstall := EngSPSInstall(oProcesso["process"], /*empresa*/, DEF_SPS_FROM_RPO)
				If !Empty(oInstall["error"])
					aStatus[1]["problema"] := STR0065 + CHR(10) + STR0079 + oInstall["idlog"] + STR0080 + oInstall["error"] //"Falha na instalação da procedure." "IDLog da operação [ "  " ] - Erro: "
					aStatus[1]["solucao" ] := STR0081 //"Verifique os detalhes da transação no configurador por meio do idLog da operação."
					aStatus[1]["status"  ] := DEF_STATUS_ERROR
				EndIf
			Else
				aStatus[1]["problema"] := STR0082 + oProcesso["process"] + STR0083 + oProcesRPO["error"] //"Não foi possivel obter o objeto do processo " " que está no RPO. Motivo: "
				aStatus[1]["solucao" ] := STR0084 //"Contate o administrador do sistema para atualizar o RPO."
				aStatus[1]["status"  ] := DEF_STATUS_ERROR
			EndIf
		EndIf
	Else
		cVerProc := EngSPS24Signature()
		cProcNam := GetSPName("MRP001", cIdProced)
		If !ExistProc(cProcNam, cVerProc)
			aStatus[1]["problema"] := STR0085 + AllTrim(cProcNam) + STR0086 //"Stored Procedure " " não instalada no banco de dados."
			aStatus[1]["solucao" ] := STR0087 //"Faça a instalação da procedure do MRP via SIGACFG."
			aStatus[1]["status"  ] := DEF_STATUS_ERROR
		EndIf
	EndIf

	gravaStats(cAgrupador, aStatus)

Return

/*/{Protheus.doc} P153AppSer
Faz as validações referentes ao AppServer

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153AppSer()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_APPSERVER

	If recGlobal(cAgrupador, @aStatus)
		//DEF_COD_APP_MEMORY
		vlChaveApp(@aStatus[1], "ServerMemoryLimit")

		//DEF_COD_APP_HEAP
		vlChaveApp(@aStatus[2], "HeapLimit")

		//DEF_COD_APP_STRING
		vlChaveApp(@aStatus[3], "MAXSTRINGSIZE")

		//DEF_COD_APP_FLOATING
		vlChaveApp(@aStatus[4], "FloatingPointPrecise")

		gravaStats(cAgrupador, aStatus)
	EndIf

Return

/*/{Protheus.doc} vlChaveApp
Valida a configuração de uma determinada chave do appserver

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@param 02 cChave , Caracter  , Chave do appserver a ser avaliada
@return Nil
/*/
Static Function vlChaveApp(oStatus, cChave)
	Local cValChave := GetPvProfString("GENERAL", cChave, "-1", GetAdv97())

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	Do Case
		Case cChave == "ServerMemoryLimit"
			If cValChave <> "-1"
				oStatus["problema"] := STR0092 //"A chave ServerMemoryLimit está definida no AppServer."
				oStatus["solucao" ] := STR0093 //"Atenção na utilização dessa chave, pois a falta de memória disponível no sistema pode levar à falha de processamento da rotina do MRP."
				oStatus["status"  ] := DEF_STATUS_ALERT
			EndIf

		Case cChave == "HeapLimit"
			If cValChave <> "-1"
				oStatus["problema"] := STR0094 //"A chave HeapLimit está definida no AppServer."
				oStatus["solucao" ] := STR0093 //"Atenção na utilização dessa chave, pois a falta de memória disponível no sistema pode levar à falha de processamento da rotina do MRP."
				oStatus["status"  ] := DEF_STATUS_ALERT
			EndIf

		Case cChave == "MAXSTRINGSIZE"
			If cValChave == "-1"
				oStatus["problema"] := STR0095 //"A chave MAXSTRINGSIZE não está definida no AppServer."
				oStatus["solucao" ] := STR0096 //"É aconselhável configurar a chave MAXSTRINGSIZE com o valor 500 no AppServer para evitar travamentos na sincronização dos dados e no cálculo do MRP."
				oStatus["status"  ] := DEF_STATUS_ALERT
			ElseIf cValChave > "0" .And. cValChave < "500"
				oStatus["problema"] := STR0097+" (" + cValChave + ")" //"A chave MAXSTRINGSIZE está definida com um valor menor que 500 no AppServer."
				oStatus["solucao" ] := STR0096 //"É aconselhável configurar a chave MAXSTRINGSIZE com o valor 500 no AppServer para evitar travamentos na sincronização dos dados e no cálculo do MRP."
				oStatus["status"  ] := DEF_STATUS_ALERT
			EndIf

		Case cChave == "FloatingPointPrecise"
			If cValChave <> "-1"
				oStatus["problema"] := STR0098 //"A chave FloatingPointPrecise está definida no AppServer."
				oStatus["solucao" ] := STR0099 //"A utilização dessa chave não é recomendada, pois pode causar comportamentos indevidos na execução do cálculo do MRP."
				oStatus["status"  ] := DEF_STATUS_ERROR
			EndIf

	EndCase

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} P153DbAcce
Valida se a procedure está instalada e atualizada na base

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153DbAcce()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_DBACCESS

	If recGlobal(cAgrupador, @aStatus)
		//DEF_COD_DBA_BUILD
		vlBuildDbA(@aStatus[1])

		//DEF_COD_DBA_STRING
		vlChaveDbA(@aStatus[2], "MAXSTRINGSIZE")

		//DEF_COD_DBA_POSTGRES
		vlBanco(@aStatus[3])

		gravaStats(cAgrupador, aStatus)
	EndIf

Return

/*/{Protheus.doc} vlBuildDbA
Valida se o binário do DbAccess é compatível

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlBuildDbA(oStatus)

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If TCVersion() < "21.1.1.1"
		oStatus["problema"] := STR0102 //"A versão do build do DBAccess deve ser 21.1.1.1 ou superior."
		oStatus["solucao" ] := STR0103 //"Atualize o build do DBAccess para a versão 21.1.1.1 (20220307) ou superior."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlChaveDbA
Valida a configuração de uma determinada chave do DbAccess

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@param 02 cChave , Caracter  , Chave do appserver a ser avaliada
@return Nil
/*/
Static Function vlChaveDbA(oStatus, cChave)
	Local cValChave := TCGetInfo(22)

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If Val(cValChave) < 524289024
		oStatus["problema"] := STR0106 //"A chave MAXSTRINGSIZE não está definida ou está definida com um valor menor que 500 no DbAccess."
		oStatus["solucao" ] := STR0105 //"É aconselhável configurar a chave MAXSTRINGSIZE com o valor 500 no DbAccess para evitar travamentos na sincronização dos dados e no cálculo do MRP."
		oStatus["status"  ] := DEF_STATUS_ALERT
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlBanco
Verifica se o banco de dados utilizado é suportado

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlBanco(oStatus)
	Local cBanco := Upper(TCGetDB())

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If cBanco == "POSTGRES"
		oStatus["problema"] := STR0107 //"O banco de dados utilizado é PostgreSQL. A configuração incorreta da conexão ODBC do banco PostgreSQL pode causar erros na execução do MRP."
		oStatus["solucao" ] := STR0108 //"Verifique a a conexão está configurada corretamente, conforme o documento: DBAccess - Como criar uma fonte de dados para uso com PostgreSQL."
		oStatus["status"  ] := DEF_STATUS_ALERT
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} P153Integr
Valida as integrações do MRP, se está ativo ou se precisa rodar a sincronização

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153Integr()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_INTEGRACAO

	If recGlobal(cAgrupador, @aStatus)
		//DEF_COD_INT_ATIVA
		vlAtiva(@aStatus[1])

		//DEF_COD_INT_ALTERADA
		vlSincroni(@aStatus[2])

		gravaStats(cAgrupador, aStatus)

		//DEF_COD_INT_PENDEN
		vlPendenc(@aStatus[3])

		gravaStats(cAgrupador, aStatus)

		//DEF_COD_INT_TRIGGERS
		vlTrgAtual(@aStatus[4])

		gravaStats(cAgrupador, aStatus)

		//DEF_COD_INT_LIMPEZA
		vlLimpeza(@aStatus[5])

		gravaStats(cAgrupador, aStatus)

		//DEF_COD_INT_JOBS
		vlSchedule(@aStatus[6])

		gravaStats(cAgrupador, aStatus)
	EndIf

Return

/*/{Protheus.doc} vlAtiva
Valida se a integração com o MRP está ativa (T4P)

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlAtiva(oStatus)
	Local cAlias := GetNextAlias()

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	BeginSql Alias cAlias
	   SELECT T4P_FILIAL, T4P_API, T4P_TPEXEC, T4P_ATIVO ,T4P_ALTER 
	    FROM %Table:T4P%
	   WHERE T4P_FILIAL = %xFilial:T4P%        
	     AND %NotDel%
	EndSql

	If (cAlias)->(Eof())
		oStatus["problema"] := STR0109 //"A integração ERP x MRP não está ativa."
		oStatus["solucao" ] := STR0110 //"Ative a integração através do programa Parâmetros de Integração MRP (PCPA139)."
		oStatus["status"  ] := DEF_STATUS_ERROR
	Else

		While (cAlias)->(!Eof())
			If (cAlias)-> T4P_ATIVO <> '1'
				oStatus["problema"] := STR0109 //"A integração ERP x MRP não está ativa."
				oStatus["solucao" ] := STR0110 //"Ative a integração através do programa Parâmetros de Integração MRP (PCPA139)."
				oStatus["status"  ] := DEF_STATUS_ERROR
				Exit
			EndIf
			(cAlias)->(dbSkip())
		End
	EndIf
	(cAlias)->(dbCloseArea())
	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlSincroni
Valida se é necessário rodar a sincronização pois teve alteração na configuração

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlSincroni(oStatus)
	Local cAlias := ""

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If SuperGetMV("MV_MRPSINC", .F., 1) <> 3
		cAlias := GetNextAlias()

		BeginSql Alias cAlias
    	  SELECT T4P_ALTER
		    FROM %Table:T4P%
		   WHERE T4P_FILIAL = %xFilial:T4P%
    	     AND T4P_API NOT IN ('MRPTRANSPORTINGLANES','MRPWAREHOUSEGROUP')
    	     AND T4P_ALTER   IN ('1','2')
		     AND %NotDel%
		   ORDER BY T4P_ALTER
		EndSql
		If (cAlias)->(!Eof())
			If (cAlias)->T4P_ALTER == '1'
				oStatus["problema"] := STR0111 //"A integração com o MRP esteve desativada por algum período."
			Else
				oStatus["problema"] := STR0112 //"Existem atualizações nas API's do MRP que requerem sincronização para garantir a integridade das informações."
			EndIf

			oStatus["solucao" ] := STR0113 //"Realize a sincronização dos dados (PCPA140)."
			oStatus["status"  ] := DEF_STATUS_ERROR
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlPendenc
Valida se existem pendências de integração na tabela T4R

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlPendenc(oStatus)
	Local cAlias := ""

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If SuperGetMV("MV_MRPSINC", .F., 1) == 1
		cAlias := GetNextAlias()

		BeginSql Alias cAlias
    	  SELECT T4R_IDPRC
		    FROM %Table:T4R%
		   WHERE T4R_FILIAL = %xFilial:T4R%
		     AND %NotDel%
		   ORDER BY T4R_IDPRC
		EndSql
		If (cAlias)->(!Eof())
			If Empty((cAlias)->T4R_IDPRC)
				oStatus["problema"] := STR0114 //"Existem registros pendentes de integração."
				oStatus["solucao" ] := STR0115 //"Configure/Execute o agendamento da integração das API's do MRP ou processe ao acessar a rotina do MRP (PCPA712)."
			Else
				oStatus["problema"] := STR0116 //"Existem registros pendentes de integração e que já estão sendo processados."
				oStatus["solucao" ] := STR0117 //"Aguarde o término das integrações para executar a rotina do MRP (PCPA712)."
			EndIf

			oStatus["status"] := DEF_STATUS_ALERT
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} P153Permis
Valida as permissões de acesso da rotina do MRP

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153Permis()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_PERMISSAO

	If recGlobal(cAgrupador, @aStatus)
		//DEF_COD_PER_BLOQ_FIL
		vlBloqFil(@aStatus[1])

		//DEF_COD_PER_EM_USO
		vlMRPEmUso(@aStatus[2])

		gravaStats(cAgrupador, aStatus)
	EndIf

Return

/*/{Protheus.doc} vlBloqFil
Verifica se a rotina está bloqueada na filial corrente

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlBloqFil(oStatus)

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If FWAliasInDic("SMQ",.F.) .And. !mrpInSMQ(cFilAnt)
		oStatus["problema"] := STR0120 //"A execução do MRP está bloqueada nesta filial."
		oStatus["solucao" ] := STR0121 //"Para executar o MRP nesta filial, realize o cadastro nas configurações (PCPA139)."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlMRPEmUso
Verifica se a rotina está sendo usada por alguma outra conexão

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlMRPEmUso(oStatus)
	Local aUltProc  := {}
	Local cAliasQry := GetNextAlias()
	Local oJsonAux  := Nil

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	BeginSql Alias cAliasQry
	  %noparser%
	  SELECT HW3_FILIAL, HW3_TICKET
	    FROM %Table:HW3% HW3
	   INNER JOIN (SELECT MAX(R_E_C_N_O_) AS RECNO
	                 FROM %Table:HW3%
	                WHERE %NotDel%
	                  AND HW3_FILIAL = %Exp:xFilial("HW3")%) MAXREC
	      ON HW3.R_E_C_N_O_ = MAXREC.RECNO
	EndSql
	If !(cAliasQry)->(Eof())
		aUltProc := MrpGet((cAliasQry)->HW3_FILIAL, (cAliasQry)->HW3_TICKET)

		If !Empty(aUltProc)
			oJsonAux := JsonObject():New()
			oJsonAux:fromJson(aUltProc[2])
			If oJsonAux["status"] != Nil .And. oJsonAux["status"] $ "1,2"
				If !Empty(oJsonAux["user"])
					oStatus["problema"] := STR0122 + AllTrim(UsrFullName(oJsonAux["user"])) + " (Ticket " + oJsonAux["ticket"] + ")." //"O MRP está sendo executado pelo usuário "
					oStatus["solucao" ] := STR0123 //"O MRP deve ser executado de forma exclusiva. Cancele e execução corrente ou aguarde a sua finalização."
					oStatus["status"  ] := DEF_STATUS_ERROR
				EndIf
			EndIf

			FreeObj(oJsonAux)
		EndIf

		aSize(aUltProc, 0)
	EndIf
	(cAliasQry)->(DbCloseArea())

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlTrgAtual
Verifica se a trigger está atualizada

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlTrgAtual(oStatus)
	Local lAbreTela := .T.

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If !MRPVldTrig(.F. /*lExibeHelp*/, /*cCodAPI*/  , .F. /*lInstala*/,     /*oModel*/, ;
	               .F. /*lExecJob*/  , /*aQryCompl*/,     /*lReteste*/, .F. /*lSchdl*/, ;
				   .F. /*lReItg*/    , /*cTicket*/  , @lAbreTela)
		oStatus["problema"] := STR0124 //"As triggers existentes na banco de dados estão inválidas."
		oStatus["solucao" ] := STR0125 //"Acesse a rotina de configuração (PCPA139) para ajustar as triggers."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlLimpeza
Valida e sugere a limpeza dos reistros já integrados da tabela T4R

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlLimpeza(oStatus)
	Local cAlias := ""

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	cAlias := GetNextAlias()

	BeginSql Alias cAlias
	  SELECT COUNT(1) TOTAL
	    FROM %Table:T4R%
	   WHERE T4R_FILIAL = %xFilial:T4R%
	     AND D_E_L_E_T_ = '*'
	EndSql
	If (cAlias)->(!Eof()) .And. (cAlias)->TOTAL > 100000
		oStatus["problema"] := I18N(STR0126, { cValToChar((cAlias)->TOTAL) }) //"Existem #1[QTDREG]# registros que podem ser eliminados da base de dados."
		oStatus["solucao" ] := STR0127 //"Execute a limpeza dos registros deletados (D_E_L_E_T_ = '*') da tabela T4R através do agendamento da rotina PCPA141T4R via Configurador -> Ambiente -> Schedule -> Schedule."
		oStatus["status"  ] := DEF_STATUS_ALERT
	EndIf
	(cAlias)->(dbCloseArea())

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlSchedule
Valida se as APIs que estão como Schedule possuem agendamento configurado

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlSchedule(oStatus)
	Local aSchedules := totvs.framework.schedule.utils.getSchedsByRotine("PCPA141")
	Local aApis      := RetApiZoom()
	Local cAliasT4P  := GetNextAlias()
	Local cApi       := ""
	Local nIndex     := 0
	Local lExiste    := .F.
	Local nTamSched  := Len(aSchedules)
	Local oSchedule  := totvs.framework.schedule.automatic():new()

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	BeginSql Alias cAliasT4P
	  SELECT DISTINCT T4P_API
	    FROM %Table:T4P%
	   WHERE T4P_FILIAL = %xFilial:T4P%
	     AND T4P_TPEXEC = '2'
	     AND %NotDel%
	EndSql
	While (cAliasT4P)->(!Eof())
		lExiste := .F.
		cApi    := AllTrim((cAliasT4P)->T4P_API)

		If aScan(aApis, {|x| x[1] == cApi}) > 0
			For nIndex := 1 To nTamSched
				oSchedule:setSchedule(aSchedules[nIndex])
				If ">"+cApi+"<" $ oSchedule:oSchedule:GetParam()
					lExiste := .T.
					Exit
				EndIf
			Next nIndex

			If !lExiste
				oStatus["problema"] := STR0128 //"API configurada como Schedule sem agendamento configurado."
				oStatus["solucao" ] := STR0129 //"Configure os agendamentos para as APIs configuradas como Schedule via Configurador -> Ambiente -> Schedule -> Schedule."
				oStatus["status"  ] := DEF_STATUS_ALERT
				Exit
			EndIf
		EndIf
		
		(cAliasT4P)->(dbSkip())
	End
	(cAliasT4P)->(dbCloseArea())

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} P153MultEm
Valida as configurações do Multi-Empresa

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153MultEm()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_MULTIEMPRESA
	Local cGrupo     := cEmpAnt
	Local cEmp       := FWCompany()
	Local cUnid      := FWUnitBusiness()
	Local cFil       := FwFilial()
	Local nX         := 0

	If !recGlobal(cAgrupador, @aStatus)
		Return
	EndIf

	setFiliais()

	cGrupo := PadR(cGrupo, GetSx3Cache("OP_CDEPGR", "X3_TAMANHO"))
	cEmp   := PadR(cEmp  , GetSx3Cache("OP_EMPRGR", "X3_TAMANHO"))
	cUnid  := PadR(cUnid , GetSx3Cache("OP_UNIDGR", "X3_TAMANHO"))
	cFil   := PadR(cFil  , GetSx3Cache("OP_CDESGR", "X3_TAMANHO"))

	SOO->(dbSetOrder(2))
	SOO->(dbSeek(xFilial("SOO") + cGrupo + cEmp + cUnid + cFil))

	SOP->(dbSetOrder(4))
	SOP->(dbSeek(xFilial("SOP") + cGrupo + cEmp + cUnid + cFil))

	//DEF_COD_MUL_UTILIZA
	If vlUsaMultE(@aStatus[1], cGrupo, cEmp, cUnid, cFil)
		//DEF_COD_MUL_TABELAS
		vlTabsMult(@aStatus[2])

		//DEF_COD_MUL_FIL_CORR
		vlFilCerta(@aStatus[3], cGrupo, cEmp, cUnid, cFil)

		//DEF_COD_MUL_TES
		vlCadTES(@aStatus[4], cGrupo, cEmp, cUnid, cFil)

		//DEF_COD_MUL_VLD_GRP
		vlFilsGrup(@aStatus[5], SOO->OO_CDEPCZ, SOO->OO_EMPRCZ, SOO->OO_UNIDCZ, SOO->OO_CDESCZ)

		gravaStats(cAgrupador, aStatus)

		//DEF_COD_MUL_CLIENTES
		//DEF_COD_MUL_COND_PAG
		vlClientes(@aStatus[6], @aStatus[7])

		gravaStats(cAgrupador, aStatus)

		//DEF_COD_MUL_FORNECED
		vlForneced(@aStatus[8])

		If FWAliasInDic("HZ8")
			//DEF_COD_MUL_DEPCIRC
			vlDepCirc(@aStatus[9])

			//DEF_COD_MUL_FILCOM
			vlFilCom(@aStatus[10])
		Else
			formIgnore(@aStatus[9], STR0211 ) //"Tabela HZ8 não encontrada."
			formIgnore(@aStatus[10], STR0211 ) //"Tabela HZ8 não encontrada."
		EndIf
		
	Else
		For nX := 2 To Len(aStatus)
			formIgnore(@aStatus[nX], STR0130 ) //"Não está utilizando o MRP Multi-Empresa."
		Next nX
	EndIf

	gravaStats(cAgrupador, aStatus)

Return

/*/{Protheus.doc} setFiliais
Salva na variável global as filiais que devem ser consideradas nas buscas

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Static Function setFiliais()
	Local aFiliais := {}
	Local nIndex   := 1
	Local nTotal   := 0

	aFiliais := A712FilME(.T.)
	nTotal   := Len(aFiliais)

	For nIndex := 1 To nTotal
		aAdd(__aFiliais, aFiliais[nIndex][1])
	Next nIndex

	If !VarSetAD(DEF_UID_GLOBAL_AUX, DEF_GLOBAL_FILIAIS, __aFiliais)
		P153Error(STR0046 + DEF_GLOBAL_FILIAIS + STR0047 + DEF_UID_GLOBAL_AUX + ".") //"Erro ao criar a lista " " na seção de variáveis globais "
	EndIf

	aSize(aFiliais, 0)

Return

/*/{Protheus.doc} getFiliais
Retorna as filiais que devem ser consideradas nas buscas

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return cReturn, Caracter, Filiais formatadas para o IN conforme o cAlias
/*/
Static Function getFiliais(cAlias)
	Local cFilAux  := ""
	Local nIndex   := 1
	Local nTotal   := 0
	Local cReturn  := ""
	Default cAlias := ""

	If Empty(__aFiliais)
		While !VarGetAD(DEF_UID_GLOBAL_AUX, DEF_GLOBAL_FILIAIS, __aFiliais)
			FWLogMsg("INFO", , "PCPA153", , , , "Aguardando gravacao do __aFiliais... (sleep)")
			Sleep(1000)
		End
	EndIf

	If !Empty(cAlias)
		If __oFiliais == Nil
			__oFiliais := JsonObject():New()
		EndIf

		If !__oFiliais:HasProperty(cAlias)
			nTotal  := Len(__aFiliais)
			cFilAux := xFilial(cAlias, __aFiliais[1])

			__oFiliais[cAlias] := "'" + cFilAux + "'"

			If !Empty(cFilAux)
				For nIndex := 2 To nTotal
					__oFiliais[cAlias] += ",'" + xFilial(cAlias, __aFiliais[nIndex]) + "'"
				Next nIndex
			EndIf
		EndIf

		cReturn := __oFiliais[cAlias]
	EndIf

Return cReturn

/*/{Protheus.doc} vlUsaMultE
Valida se está sendo utilizado o MRP Multi Empresa

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@param 02 cGrupo , Caracter  , Grupo de empresa corrente
@param 03 cEmp   , Caracter  , Empresa corrente
@param 04 cUnid  , Caracter  , Unidade corrente
@param 05 cFil   , Caracter  , Filial corrente
@return lUsaME   , Lógico    , Indica se está usando o Multi-Empresa
/*/
Static Function vlUsaMultE(oStatus, cGrupo, cEmp, cUnid, cFil)
	Local lUsaME   := .F.

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	//Verifica se é Filial Centralizadora
	If SOO->OO_FILIAL == xFilial("SOO") .And. SOO->OO_CDEPCZ == cGrupo .And. SOO->OO_EMPRCZ == cEmp .And. SOO->OO_UNIDCZ == cUnid .And. SOO->OO_CDESCZ == cFil
		lUsaME := .T.

	//Verifica se é Filial Centralizada
	ElseIf SOP->OP_FILIAL == xFilial("SOP") .And. SOP->OP_CDEPGR == cGrupo .And. SOP->OP_EMPRGR == cEmp .And. SOP->OP_UNIDGR == cUnid .And. SOP->OP_CDESGR == cFil
		lUsaME := .T.
	EndIf

	msgLog(oStatus, 2)

Return lUsaME

/*/{Protheus.doc} vlTabsMult
Valida o compartilhamento das tabelas de Produto e Alternativo

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlTabsMult(oStatus)

	Local lSB1 := .F.
	Local lSGI := .F.

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If !FWModeAccess("SB1",1) == "C" .Or. !FWModeAccess("SB1",2) == "C" .Or. !FWModeAccess("SB1",3) == "C"
		lSB1 := .T.
		oStatus["problema"] := STR0131 //"A tabela SB1 (Produtos) está com modo de compartilhamento incorreto."
		oStatus["solucao" ] := STR0132 //"Altere o modo de compartilhamento da tabela SB1 para 'Compartilhado' (CCC)."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	If !FWModeAccess("SGI",1) == "C" .Or. !FWModeAccess("SGI",2) == "C" .Or. !FWModeAccess("SGI",3) == "C"
		lSGI := .T.
		oStatus["problema"] := STR0133 //"A tabela SGI (Alternativos) está com modo de compartilhamento incorreto."
		oStatus["solucao" ] := STR0134 //"Altere o modo de compartilhamento da tabela SGI para 'Compartilhado' (CCC)."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	If lSB1 .And. lSGI
		oStatus["problema"] := STR0198 //"As tabelas SB1 (Produtos) e SGI (Alternativos) estão com o modo de compartilhamento incorreto."
		oStatus["solucao" ] := STR0197 //"Altere o modo de compartilhamento das tabelas para 'Compartilhado' (CCC)." 
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlFilCerta
Valida se está logado na filial Centralizadora

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@param 02 cGrupo , Caracter  , Grupo de empresa corrente
@param 03 cEmp   , Caracter  , Empresa corrente
@param 04 cUnid  , Caracter  , Unidade corrente
@param 05 cFil   , Caracter  , Filial corrente
@return Nil
/*/
Static Function vlFilCerta(oStatus, cGrupo, cEmp, cUnid, cFil)

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If SOP->OP_FILIAL == xFilial("SOP") .And. SOP->OP_CDEPGR == cGrupo .And. SOP->OP_EMPRGR == cEmp .And. SOP->OP_UNIDGR == cUnid .And. SOP->OP_CDESGR == cFil
		oStatus["problema"] := STR0135 + cFilAnt + STR0136 //"A Filial '"  "' está configurada como Filial Centralizada."
		oStatus["solucao" ] := STR0137 //"A execução do MRP Multi-Empresa deve ser realizada em uma Filial Centralizadora."
		oStatus["status"  ] := DEF_STATUS_ERROR

		//Posiciona a SOO na filial centralizadora para a próxima validação.
		SOO->(dbSeek(xFilial("SOO") + SOP->OP_CDEPCZ + SOP->OP_EMPRCZ + SOP->OP_UNIDCZ + SOP->OP_CDESCZ))
	EndIf

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlCadTES
Valida se foi informado o TES no cadastro do Multi-Empresa

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@param 02 cGrupo , Caracter  , Grupo de empresa corrente
@param 03 cEmp   , Caracter  , Empresa corrente
@param 04 cUnid  , Caracter  , Unidade corrente
@param 05 cFil   , Caracter  , Filial corrente
@return Nil
/*/
Static Function vlCadTES(oStatus, cGrupo, cEmp, cUnid, cFil)
	Local aAreaSOO := SOO->(GetArea())

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	If Empty(SOO->OO_TE) .Or. Empty(SOO->OO_TS)
		oStatus["problema"] := STR0138 //"Não foi informado o TES no cadastro das Empresas Centralizadoras."
		oStatus["solucao" ] := STR0139 //"Acesse o cadastro das Empresas Centralizadoras (PCPA106) e informe o TES Entrada e Saída (Outras Ações)."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	RestArea(aAreaSOO)
	aSize(aAreaSOO, 0)

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlFilsGrup
Valida se as filiais pertencem ao mesmo grupo de empresa

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@param 02 cGrupo , Caracter  , Grupo de empresa corrente
@param 03 cEmp   , Caracter  , Empresa corrente
@param 04 cUnid  , Caracter  , Unidade corrente
@param 05 cFil   , Caracter  , Filial corrente
@return Nil
/*/
Static Function vlFilsGrup(oStatus, cGrupo, cEmp, cUnid, cFil)
	Local cAlias := GetNextAlias()

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	BeginSql Alias cAlias
	  SELECT 1
	    FROM %table:SOP%
	   WHERE OP_FILIAL = %xFilial:SOP%
	     AND OP_CDEPCZ = %Exp:cGrupo%
	     AND OP_EMPRCZ = %Exp:cEmp%
	     AND OP_UNIDCZ = %Exp:cUnid%
	     AND OP_CDESCZ = %Exp:cFil%
	     AND OP_CDEPGR <> OP_CDEPCZ
	     AND %NotDel%
	EndSql
	If (cAlias)->(!Eof())
		oStatus["problema"] := STR0140 //"Existem empresas centralizadas que pertencem a outro Grupo de Empresa"
		oStatus["solucao" ] := STR0141 //"Corrija o cadastro da Empresa Centralizadora (PCPA106)."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf
	(cAlias)->(dbCloseArea())

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlClientes
Valida se as filiais estão cadastradas como Clientes umas das outras e se possuem Condição de Pagamento

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param 01 oStatusCli, JsonObject, Retorno da validação (cliente) conforme esperado pela API (referência)
@param 02 oStatusCon, JsonObject, Retorno da validação (condição de pagamento) conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlClientes(oStatusCli, oStatusCon)
	Local cAlias    := GetNextAlias()
	Local cFilDest  := ""
	Local cFilOrig  := ""
	Local cWhere    := ""
	Local lMVFilTrf := .F.
	Local lRetCli   := .T.
	Local lRetCon   := .T.
	Local nIndDest  := 1
	Local nIndOrig  := 1
	Local nTotFils  := Len(__aFiliais)
	Local oCGCFil   := JsonObject():New()

	msgLog(oStatusCli, 1)
	msgLog(oStatusCon, 1)
	formSucess(@oStatusCli)
	formSucess(@oStatusCon)

	lMVFilTrf := SuperGetMv("MV_FILTRF",.F.,.F.)

	For nIndOrig := 1 To nTotFils
		For nIndDest := 1 To nTotFils
			If nIndOrig == nIndDest
				Loop
			EndIf

			cFilOrig := __aFiliais[nIndOrig]
			cFilDest := __aFiliais[nIndDest]

			cWhere := "%A1_FILIAL = '" + xFilial("SA1", cFilOrig) + "'"
			If lMVFilTrf
				cWhere += " AND A1_FILTRF = '" + cFilDest + "'"
			Else
				If !oCGCFil:HasProperty(cFilDest)
					oCGCFil[cFilDest] := A311FilCGC(cFilDest)
				EndIf
				cWhere += " AND A1_CGC = '" + oCGCFil[cFilDest] + "'"
			EndIf
			cWhere += " AND D_E_L_E_T_ = ' '%"

			If Empty(oCGCFil[cFilDest]) .And. !lMVFilTrf
				lRetCli                := .F.
				oStatusCli["problema"] := STR0212 //"Existem filiais que não estão possuem CNPJ."
				oStatusCli["solucao" ] := STR0213 //"Verifique o cadastro das filiais cadastradas no MRP Multi-Empresa. Ou utilize o parâmetro MV_FILTRF"
				oStatusCli["status"  ] := DEF_STATUS_ERROR
				
				lRetCon                := .F.
				oStatusCon["problema"] := STR0212 //"Existem filiais que não estão possuem CNPJ."
				oStatusCon["solucao" ] := STR0213 //"Verifique o cadastro das filiais cadastradas no MRP Multi-Empresa. Ou utilize o parâmetro MV_FILTRF"
				oStatusCon["status"  ] := DEF_STATUS_ERROR
				Exit
			EndiF

			BeginSQL Alias cAlias
			  %NoParser%
			  SELECT A1_COD, A1_COND
			    FROM %Table:SA1%
			   WHERE %Exp:cWhere%
			EndSql
			If (cAlias)->(Eof())
				lRetCli                := .F.
				oStatusCli["problema"] := STR0142 //"Existem filiais que não estão cadastradas como cliente."
				oStatusCli["solucao" ] := STR0143 //"Verifique o cadastro de Clientes de todas as filiais cadastradas no MRP Multi-Empresa."
				oStatusCli["status"  ] := DEF_STATUS_ERROR

			ElseIf Empty((cAlias)->A1_COND)
				lRetCon                := .F.
				oStatusCon["problema"] := STR0144 //"Existem filiais que não possuem a condição de pagamento cadastrada."
				oStatusCon["solucao" ] := STR0145 //"Verifique o cadastro de Clientes de todas as filiais preenchendo o campo da Condição de Pagamento (A1_COND)."
				oStatusCon["status"  ] := DEF_STATUS_ERROR
			EndIf
			(cAlias)->(dbCloseArea())

			//Se as 2 validações já tiveram erro não precisa mais continuar
			If !lRetCli .And. !lRetCon
				Exit
			EndIf
		Next nIndDest

		//Se as 2 validações já tiveram erro não precisa mais continuar
		If !lRetCli .And. !lRetCon
			Exit
		EndIf
	Next nIndOrig

	FreeObj(oCGCFil)

	msgLog(oStatusCli, 2)
	msgLog(oStatusCon, 2)

Return

/*/{Protheus.doc} vlForneced
Valida se as filiais estão cadastradas como Clientes e Fornecedoras umas das outras e se possuem Condição de Pagamento

@type Static Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlForneced(oStatus)
	Local cAlias    := GetNextAlias()
	Local cFilDest  := ""
	Local cFilOrig  := ""
	Local cWhere    := ""
	Local lMVFilTrf := .F.
	Local lRet      := .T.
	Local nIndDest  := 1
	Local nIndOrig  := 1
	Local nTotFils  := Len(__aFiliais)
	Local oCGCFil   := JsonObject():New()

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	lMVFilTrf := SuperGetMv("MV_FILTRF",.F.,.F.)

	For nIndOrig := 1 To nTotFils
		For nIndDest := 1 To nTotFils
			If nIndOrig == nIndDest
				Loop
			EndIf

			cFilOrig := __aFiliais[nIndOrig]
			cFilDest := __aFiliais[nIndDest]

			cWhere := "%A2_FILIAL = '" + xFilial("SA2", cFilDest) + "'"
			If lMVFilTrf
				cWhere += " AND A2_FILTRF = '" + cFilOrig + "'"
			Else
				If !oCGCFil:HasProperty(cFilOrig)
					oCGCFil[cFilOrig] := A311FilCGC(cFilOrig)
				EndIf
				cWhere += " AND A2_CGC = '" + oCGCFil[cFilOrig] + "'"
			EndIf
			cWhere += " AND D_E_L_E_T_ = ' '%"

			BeginSQL Alias cAlias
			  %NoParser%
			  SELECT 1
			    FROM %table:SA2% SA2
			   WHERE %Exp:cWhere%
			EndSql
			If (cAlias)->(Eof())
				lRet                   := .F.
				oStatus["problema"] := STR0146 //"Existem filiais que não estão cadastradas como fornecedora."
				oStatus["solucao" ] := STR0147 //"Verifique o cadastro de Fornecedores de todas as filiais cadastradas no MRP Multi-Empresa."
				oStatus["status"  ] := DEF_STATUS_ERROR
			EndIf
			(cAlias)->(dbCloseArea())

			If !lRet
				Exit
			EndIf
		Next nIndDest

		If !lRet
			Exit
		EndIf
	Next nIndOrig

	FreeObj(oCGCFil)

	msgLog(oStatus, 2)

Return


/*/{Protheus.doc} vlFilCom
Verifica se as filiais de compra dos produtos pertencem ao grupo de empresas atual.

@type Static Function
@author douglas.heydt
@since 28/11/2024
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlFilCom(oStatus)
	Local cAlias   := GetNextAlias()
	Local cFiliais := ""
	Local cQuery   := ""
	Local nIndex   := 0
	Local lError   := .F.
	Local nTotFils := Len(__aFiliais)

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	For nIndex := 1 To nTotFils
		cFiliais += "'"+__aFiliais[nIndex]+"'"
		If nIndex <> nTotFils
			cFiliais += ","
		EndIf
	Next nIndex

	cQuery := " SELECT HZ8_FILIAL,HZ8_PROD,HZ8_FILCOM "
	cQuery += " FROM "+RetSqlName("HZ8")+" "
	cQuery += " WHERE HZ8_FILIAL IN ("+cFiliais+") AND HZ8_FILCOM <> '' AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	While (cAlias)->(!Eof())
		nPos := aScan(__aFiliais, {|x| x == (cAlias)->(HZ8_FILCOM)})			
		If nPos == 0
			lError := .T.
			Exit
		EndIf
		(cAlias)->(dbSkip())	
	End

	If lError
		oStatus["problema"] := STR0205 //"Existem Filiais de compra de produtos que não pertencem ao grupo de empresas do MRP."  
		oStatus["solucao" ] := STR0206 //"Corrija a filial de compra do produto na rotina MATA180, ou adicione a filial de compra ao grupo de empresas centralizadoras do MRP na rotina PCPA106."
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf

	(cAlias)->(dbCloseArea())

	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} vlDepCirc
Valida se as filiais de compra criam uma dependencia circular entre elas

@type Static Function
@author douglas.heydt
@since 21/11/2024
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlDepCirc(oStatus)
	Local aProds   := {}
	Local cAlias   := GetNextAlias()
	Local cBanco   := AllTrim(TcGetDb())
	Local cFiliais := ""
	Local cQuery   := ""
	Local lError   := .F.
	Local nIndex   := 0
	Local nTotal   := 0

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	nTotal := Len(__aFiliais)
	For nIndex := 1 To nTotal
		cFiliais += "'"+__aFiliais[nIndex]+"'"
		If nIndex <> nTotal
			cFiliais += ","
		EndIf
	Next nIndex

	If "POSTGRES" $ cBanco
		cQuery += "WITH RECURSIVE "
	Else
		cQuery += "WITH "
	EndIf

	cQuery += " RastroRecursivo (HZ8_FILIAL, HZ8_PROD, HZ8_FILCOM, Caminho, TemCiclo, Nivel) AS ( "
	cQuery += "	SELECT "
	cQuery += "		Base.HZ8_FILIAL, "
	cQuery += "		Base.HZ8_PROD, "
	cQuery += "		Base.HZ8_FILCOM, "
	cQuery += "		CAST(CAST(Base.HZ8_FILIAL AS VARCHAR(10)) || '-' || CAST(Base.HZ8_PROD AS VARCHAR(10)) AS VARCHAR(2000)) AS Caminho, "
	cQuery += "		0 AS TemCiclo, "
	cQuery += "		1 AS Nivel "
	cQuery += "	FROM "+RetSqlName("HZ8")+" Base "
	cQuery += "	WHERE Base.D_E_L_E_T_ = ' ' "
	cQuery += "		AND Base.HZ8_FILIAL IN ("+cFiliais+") "
	cQuery += "	UNION ALL
	cQuery += "	SELECT "
	cQuery += "		Recursiva.HZ8_FILIAL, "
	cQuery += "		Recursiva.HZ8_PROD, "
	cQuery += "		Recursiva.HZ8_FILCOM, "
	cQuery += "		CAST(Qry_Recurs.Caminho || '->' || CAST(Recursiva.HZ8_FILIAL AS VARCHAR(10)) || '-' || CAST(Recursiva.HZ8_PROD AS VARCHAR(10)) AS VARCHAR(2000)) AS Caminho, "
	cQuery += "		CASE "
	
	If "POSTGRES" $ cBanco
		cQuery += " 	WHEN POSITION('->' || CAST(Recursiva.HZ8_FILIAL AS VARCHAR(10)) || '-' || CAST(Recursiva.HZ8_PROD AS VARCHAR(10)) IN Qry_Recurs.Caminho) > 0  "
	ElseIf "ORACLE" $ cBanco
		cQuery += " 	WHEN INSTR('->' || CAST(Recursiva.HZ8_FILIAL AS VARCHAR(10)) || '-' || CAST(Recursiva.HZ8_PROD AS VARCHAR(10)), Qry_Recurs.Caminho, 1) > 0   "
	Else 
		cQuery += " 	WHEN CHARINDEX('->' + CAST(Recursiva.HZ8_FILIAL AS VARCHAR(10)) + '-' + CAST(Recursiva.HZ8_PROD AS VARCHAR(10)), Qry_Recurs.Caminho) > 0  "
	EndIf
	
	cQuery += "				AND NOT (Recursiva.HZ8_FILIAL = Recursiva.HZ8_FILCOM) THEN 1 "
	cQuery += "			ELSE 0 "
	cQuery += "		END AS TemCiclo, "
	cQuery += "		Qry_Recurs.Nivel + 1 AS Nivel "
	cQuery += "	FROM "+RetSqlName("HZ8")+" Recursiva "
	cQuery += "	INNER JOIN RastroRecursivo Qry_Recurs "
	cQuery += "		ON Qry_Recurs.HZ8_FILCOM = Recursiva.HZ8_FILIAL "
	cQuery += "		AND Qry_Recurs.HZ8_PROD = Recursiva.HZ8_PROD "
	cQuery += "	WHERE Recursiva.D_E_L_E_T_ = ' ' "
	cQuery += "		AND Qry_Recurs.TemCiclo = 0 "
	cQuery += "		AND Qry_Recurs.Nivel < 100 "
	cQuery += "     AND Recursiva.HZ8_FILIAL != Recursiva.HZ8_FILCOM "
	cQuery += ") "
	cQuery += "SELECT DISTINCT HZ8_PROD "
	cQuery += "FROM RastroRecursivo "
	cQuery += "WHERE TemCiclo = 1 "

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery,"||","+")
	EndIf

	BEGIN SEQUENCE
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
	RECOVER
		lError := .T.
	END SEQUENCE
	
	If !lError
		While (cAlias)->(!Eof())
			lError := .T.
			aAdd(aProds,  (cAlias)->(HZ8_PROD))
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())
	EndIf
	
	If lError
		oStatus["problema"] := I18N(STR0207, {ArrTokStr(aProds,", ",)}) //"Dependência circular detectada nas filiais de compra dos produtos: #1[PRODUTOS]#. "
		oStatus["solucao" ] := STR0208 //"Corrija as filiais de compra dos produtos (MATA180) para que não criem um ciclo entre si. "
		oStatus["status"  ] := DEF_STATUS_ERROR
	EndIf
	
	msgLog(oStatus, 2)

Return

/*/{Protheus.doc} P153Estrut
Faz as validações referentes às estruturas de produtos

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153Estrut()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_ESTRUTURA

	If recGlobal(cAgrupador, @aStatus)
		//DEF_COD_EST_RECURSIVA
		vlEstRecur(@aStatus[1])

		gravaStats(cAgrupador, aStatus)
	EndIf

Return

/*/{Protheus.doc} vlEstRecur
Valida se existem estruturas com recursividade

@type Static Function
@author marcelo.neumann
@since 09/02/2024
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlEstRecur(oStatus)
	Local nIndex := 1
	Local nTotal := 0

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	getFiliais()
	nTotal := Len(__aFiliais)

	For nIndex := 1 To nTotal
		If estrRecurs(__aFiliais[nIndex])
			oStatus["problema"] := STR0148 //"Existem estruturas recursivas na base."
			oStatus["solucao" ] := STR0149 //"Acesse o cadastro de Estrutura de Produto (PCPA200) e execute a validação em Outras Ações > Recursividade."
			oStatus["status"  ] := DEF_STATUS_ERROR
			Exit
		EndIf
	Next nIndex

	msgLog(oStatus, 2)
Return

/*/{Protheus.doc} estrRecurs
Verifica se há recursividade nas estruturas de uma filial

@type Static Function
@author marcelo.neumann
@since 09/02/2024
@version P12
@param cCodFil , Caracter, Código da filial que irá verificar se há recursividade
@return lExiste, Logico  , Indica se há ou não recursividade
/*/
Static Function estrRecurs(cCodFil)
	Local bErrBlock := ErrorBlock( {|oErro| P153ErrRec(oErro)} )
	Local cAlias    := GetNextAlias()
	Local cBanco    := TCGetDB()
	Local lExiste   := .F.
	Local cQuery    := ""
	Private lError  := .F.

	If "POSTGRES" $ cBanco
		cQuery := "WITH recursive RastroRecursivo(G1_COD, G1_COMP)"
		cQuery +=  " AS ("
		cQuery +=       " SELECT SG1_Base.G1_COD,"
		cQuery +=              " SG1_Base.G1_COMP,"
		cQuery +=         " CONCAT(CONCAT(';', CAST(SG1_BASE.R_E_C_N_O_ AS VARCHAR(11))), ' ; ') AS RECS, "
		cQuery +=         " FALSE recursivo "
		cQuery +=         " FROM " + RetSqlName("SG1") + " SG1_Base"
		cQuery +=        " WHERE SG1_Base.D_E_L_E_T_ = ' '"
		cQuery +=          " AND SG1_Base.G1_FILIAL  = '" + xFilial("SG1", cCodFil) + "'"
		cQuery +=        " UNION ALL"
		cQuery +=       " SELECT SG1_Rec.G1_COD,"
		cQuery +=              " SG1_Rec.G1_COMP,"
		cQuery +=              " CONCAT(CONCAT(QRY_RECURS.RECS, CAST(SG1_REC.R_E_C_N_O_ AS VARCHAR(11))), ';') AS RECS, "
        cQuery +=              " CASE "
		cQuery +=              "    WHEN POSITION(CONCAT(CONCAT(';', CAST(SG1_REC.R_E_C_N_O_ AS VARCHAR(11))), ';') IN QRY_RECURS.RECS) > 0 THEN TRUE "
		cQuery +=              "    ELSE FALSE "
		cQuery +=              " END recursivo "
		cQuery +=         " FROM " + RetSqlName("SG1") + " SG1_Rec"
		cQuery +=        " INNER JOIN RastroRecursivo Qry_Recurs"
		cQuery +=           " ON Qry_Recurs.G1_COMP = SG1_Rec.G1_COD"
		cQuery +=          " AND Qry_Recurs.recursivo = FALSE "
		cQuery +=        " WHERE SG1_Rec.D_E_L_E_T_ = ' '"
		cQuery +=          " AND SG1_Rec.G1_FILIAL  = '" + xFilial("SG1", cCodFil) + "')"
		cQuery +=  " SELECT COUNT(*) TOTAL "
		cQuery +=    " FROM RastroRecursivo Resultad "
		cQuery +=   " WHERE recursivo = TRUE "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T., .T.)

		If !(cAlias)->(Eof())
			If (cAlias)->TOTAL > 0
				lExiste := .T.
			Else
				lExiste := .F.
			EndIf
		EndIf

		(cAlias)->(dbCloseArea())
	Else
		cQuery := "WITH RastroRecursivo(G1_COD, G1_COMP)"
		cQuery +=  " AS ("
		cQuery +=       " SELECT SG1_Base.G1_COD,"
		cQuery +=              " SG1_Base.G1_COMP"
		cQuery +=         " FROM " + RetSqlName("SG1") + " SG1_Base"
		cQuery +=        " WHERE SG1_Base.D_E_L_E_T_ = ' '"
		cQuery +=          " AND SG1_Base.G1_FILIAL  = '" + xFilial("SG1", cCodFil) + "'"
		cQuery +=        " UNION ALL"
		cQuery +=       " SELECT SG1_Rec.G1_COD,"
		cQuery +=              " SG1_Rec.G1_COMP"
		cQuery +=         " FROM " + RetSqlName("SG1") + " SG1_Rec"
		cQuery +=        " INNER JOIN RastroRecursivo Qry_Recurs"
		cQuery +=           " ON Qry_Recurs.G1_COMP = SG1_Rec.G1_COD"
		cQuery +=        " WHERE SG1_Rec.D_E_L_E_T_ = ' '"
		cQuery +=          " AND SG1_Rec.G1_FILIAL  = '" + xFilial("SG1", cCodFil) + "')"
		cQuery +=  " SELECT COUNT(*) TOTAL "
		cQuery +=    " FROM RastroRecursivo Resultad"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

		If lError
			lExiste := .T.
		Else
			lExiste := .F.
			(cAlias)->(dbCloseArea())
		EndIf
	EndIf

	ErrorBlock(bErrBlock)

Return lExiste

/*/{Protheus.doc} P153ErrRec
Função executada pelo ErrorBlock para setar a variavel com erro

@type Static Function
@author marcelo.neumann
@since 09/02/2024
@version P12
@param oErro  , Objeto, Objeto de erro
@return lError, Lógico, Indica que houve erro na execução
/*/
Function P153ErrRec(oErro)

	lError := .T.

Return lError

/*/{Protheus.doc} P153Produt
Faz as validações referentes ao cadatro de produtos

@type Function
@author marcelo.neumann
@since 01/12/2023
@version P12
@return Nil
/*/
Function P153Produt()
	Local aStatus    := {}
	Local cAgrupador := DEF_GRP_PRODUTO

	If recGlobal(cAgrupador, @aStatus)
		//DEF_COD_PRD_QUEBRA_LE
		vlQuebraLE(@aStatus[1])
		gravaStats(cAgrupador, aStatus)

		//DEF_COD_PRD_QUEBRA_LM
		vlQuebraLM(@aStatus[2])
		gravaStats(cAgrupador, aStatus)

		//DEF_COD_PRD_QUEBRA_EM
		vlQuebraEm(@aStatus[3])
		gravaStats(cAgrupador, aStatus)
	EndIf

Return

/*/{Protheus.doc} vlQuebraLE
Valida se existem produtos com lote econômico com quantidade pequena

@type Static Function
@author marcelo.neumann
@since 09/02/2024
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlQuebraLE(oStatus)
	Local cAliasHWA := GetNextAlias()
	Local cAliasHWE := GetNextAlias()
	Local cFilsHWA  := "%" + getFiliais("HWA") + "%"
	Local cFilsHWE  := "%" + getFiliais("HWE") + "%"

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	BeginSql Alias cAliasHWA
	  SELECT Count(*) QTD_PROD_HWA
	    FROM %table:HWA%
	   WHERE HWA_FILIAL IN (%exp:cFilsHWA%)
	     AND HWA_LE      = 1
	     AND %NotDel%
	EndSql

	BeginSql Alias cAliasHWE
	  SELECT Count(*) QTD_PROD_HWE
	    FROM %table:HWE%
	   WHERE HWE_FILIAL IN (%exp:cFilsHWE%)
	     AND HWE_LE      = 1
	     AND %NotDel%
	EndSql

	If (cAliasHWA)->QTD_PROD_HWA > 0 .Or. (cAliasHWE)->QTD_PROD_HWE > 0
		oStatus["problema"] := I18N(STR0150, {Iif((cAliasHWA)->QTD_PROD_HWA > 0, cValToChar((cAliasHWA)->QTD_PROD_HWA), cValToChar((cAliasHWE)->QTD_PROD_HWE))}) //"Existem produtos ( #1[QTDPROD]# ) com Lote Econômico igual a 1."
		oStatus["solucao" ] := STR0151 //"Verifique a real necessidade do Lote Econômico para os produtos e/ou avalie a utilização do parâmetro MV_QLIMITE."
		oStatus["status"  ] := DEF_STATUS_ALERT
	EndIf
	(cAliasHWA)->(dbCloseArea())
	(cAliasHWE)->(dbCloseArea())

	msgLog(oStatus, 2)
Return

/*/{Protheus.doc} vlQuebraLM
Valida se existem produtos com lote mínimo com quantidade pequena

@type Static Function
@author marcelo.neumann
@since 09/02/2024
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlQuebraLM(oStatus)
	Local cAliasHWA := GetNextAlias()
	Local cAliasHWE := GetNextAlias()
	Local cFilsHWA  := "%" + getFiliais("HWA") + "%"
	Local cFilsHWE  := "%" + getFiliais("HWE") + "%"

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	BeginSql Alias cAliasHWA
		SELECT Count(*) QTD_PROD_HWA
		FROM %table:HWA%
		WHERE HWA_FILIAL IN (%exp:cFilsHWA%)
			AND HWA_LM = 1
			AND %NotDel%
	EndSql

	BeginSql Alias cAliasHWE
		SELECT Count(*) QTD_PROD_HWE
		FROM %table:HWE%
		WHERE HWE_FILIAL IN (%exp:cFilsHWE%)
			AND HWE_LM = 1
			AND %NotDel%
	EndSql

	If (cAliasHWA)->QTD_PROD_HWA > 0 .Or. (cAliasHWE)->QTD_PROD_HWE > 0
		oStatus["problema"] := I18N(STR0047, {Iif((cAliasHWA)->QTD_PROD_HWA > 0, cValToChar((cAliasHWA)->QTD_PROD_HWA), cValToChar((cAliasHWE)->QTD_PROD_HWE))}) //"Existem produtos ( #1[QTDPROD]# ) com Lote Mínimo igual a 1 e o parâmetro MV_FORCALM está ativo."
		oStatus["solucao" ] := STR0051 //"Verifique a real necessidade do Lote Mínimo para os produtos e/ou avalie a utilização dos parâmetros MV_FORCALM e MV_QLIMITE."
		oStatus["status"  ] := DEF_STATUS_ALERT
	EndIf
	(cAliasHWA)->(dbCloseArea())
	(cAliasHWE)->(dbCloseArea())

	msgLog(oStatus, 2)
Return

/*/{Protheus.doc} vlQuebraEm
Valida se existem produtos com quantidade pequena de embalagem

@type Static Function
@author marcelo.neumann
@since 09/02/2024
@version P12
@param oStatus, JsonObject, Retorno da validação conforme esperado pela API (referência)
@return Nil
/*/
Static Function vlQuebraEm(oStatus)
	Local cAliasHWA := GetNextAlias()
	Local cAliasHWE := GetNextAlias()
	Local cFilsHWA  := "%" + getFiliais("HWA") + "%"
	Local cFilsHWE  := "%" + getFiliais("HWE") + "%"

	msgLog(oStatus, 1)
	formSucess(@oStatus)

	BeginSql Alias cAliasHWA
	  SELECT Count(*) QTD_PROD_HWA
	    FROM %table:HWA%
	   WHERE HWA_FILIAL IN (%exp:cFilsHWA%)
	     AND HWA_QE      = 1
	     AND %NotDel%
	EndSql

	BeginSql Alias cAliasHWE
	  SELECT Count(*) QTD_PROD_HWE
	    FROM %table:HWE%
	   WHERE HWE_FILIAL IN (%exp:cFilsHWE%)
	     AND HWE_QE      = 1
	     AND %NotDel%
	EndSql

	If (cAliasHWA)->QTD_PROD_HWA > 0 .Or. (cAliasHWE)->QTD_PROD_HWE > 0
		oStatus["problema"] := I18N(STR0071, {Iif((cAliasHWA)->QTD_PROD_HWA > 0, cValToChar((cAliasHWA)->QTD_PROD_HWA), cValToChar((cAliasHWE)->QTD_PROD_HWE))}) //"Existem produtos (#1[QTDPROD]#) com quantidade de Embalagem igual a 1."
		oStatus["solucao" ] := STR0077 //"Verifique a real necessidade dessa quantidade de Embalagem e/ou avalie a utilização dos parâmetros MV_QLIMITE, MV_SUBSLE e MV_FORCALM."
		oStatus["status"  ] := DEF_STATUS_ALERT
	EndIf
	(cAliasHWA)->(dbCloseArea())
	(cAliasHWE)->(dbCloseArea())

	msgLog(oStatus, 2)
Return

/*/{Protheus.doc} WSMETHOD GET SCHEDULER /api/pcp/v1/pcpdiagnosticoapi/scheduler
Retorna as integrações de api do MRP

@type WSMETHOD
@author douglas.heydt
@since 27/02/2024
@version P12
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET SCHEDULER WSSERVICE PCPdiagnosticoAPI
    Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA153"), Break(oError)})
    Local lReturn   := .T.
	Local oAgend    := JsonObject():New()

    ::SetContentType("application/json")

	BEGIN SEQUENCE
		oAgend := getAgend()
		If Len(oAgend:getNames()) > 0
			aReturn := getSchList(oAgend)
		EndIf
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getSchList
Retorna a lista de apis do MRP e seus status

@type Static Function
@author douglas.heydt
@since 27/02/2024
@version P12
@param oAgend, JsonObject, Contém as apis definidas como execução em schedule na rotina Parâmetros de integração MRP (PCPA139)
@return aReturn, Array, Array com as informações para retorno da API
/*/
Static Function getSchList(oAgend)
    Local aResult   := {.T.,200, ""}
	Local aRetId    := {}
	Local aRetSch   := {}
	Local nNames    := Len(oAgend:GetNames())
	Local aNames    := oAgend:GetNames()
	Local cApi      := ""
	Local cName     := ""
	Local cPrevApi  := ""
	Local nCont     := 0
	Local nPosDet   := 0
	LOcal nX        := 0
    Local oJson     := JsonObject():New()
	Local oJsonAux  := JsonObject():New()
	Local oScheduleInfo
	
	oScheduleInfo := totvs.framework.schedule.information.ScheduleInformation():New()
	aRetId := oScheduleInfo:getIdSchedulesByRoutine("PCPA141")

	oJson["items"] := {}

	For nX:=1 to nNames
		cName := aNames[nX]
		oJsonAux[cName] := nX
		aAdd(oJson["items"], JsonObject():New())
		oJson["items"][nX]["api"]       := cName
		oJson["items"][nX]["descricao"] := oAgend[cName]["descricao"]
		oJson["items"][nX]["tipo"]      := oAgend[cName]["tipo"]
		oJson["items"][nX]["ativo"]     := oAgend[cName]["ativo"]
		oJson["items"][nX]["alterado"]  := oAgend[cName]["alterado"]
		oJson["items"][nX]["details"]   := {}
	Next nX

	If Len(aRetId) > 0
		For nCont := 1 to Len(aRetId)
			aRetSch := oScheduleInfo:getScheduleById(aRetId[nCont])
			cApi := Alltrim(aRetSch[1][2]["AMVPARAMS"][1][2])
			If oJsonAux:HasProperty(cApi)
				If !(cApi == cPrevApi)
					cPrevApi := cApi
					nPosDet := 0
				EndIf
				aAdd(oJson["items"][oJsonAux[cApi]]["details"], JsonObject():New())
				nPosDet++
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["codigo"]     := aRetSch[1][1]["CID"]
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["usuario"]    := UsrFullName(aRetSch[1][1]["CUSERID"])
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["rotina"]     := aRetSch[1][1]["CFUNCTION"]
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["data"]       := aRetSch[1][1]["DDATE"]
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["ambiente"]   := aRetSch[1][1]["CENV"]
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["modulo"]     := aRetSch[1][1]["NMODULE"]
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["ultimoDia"]  := Iif(!Empty(aRetSch[1][1]["DLASTDAYEXEC"]), aRetSch[1][1]["DLASTDAYEXEC"], '')
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["ultimaHora"] := Iif(!Empty(aRetSch[1][1]["CLASTTIMEEXEC"]), aRetSch[1][1]["CLASTTIMEEXEC"], ':')
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["status"]     := aRetSch[1][1]["CSTATUS"]
				oJson["items"][oJsonAux[cApi]]["details"][nPosDet]["api"]        := Alltrim(aRetSch[1][2]["AMVPARAMS"][1][2])
			EndIf
		Next nCont
	EndIf

    aResult[3] := oJson:ToJson()
    FreeObj(oJson)

Return aResult

/*/{Protheus.doc} getAgend
Retorna as apis definidas como schedule nos Parâmetros de integração MRP (PCPA139)

@type Static Function
@author douglas.heydt
@since 16/04/2024
@version P12
@return oJson, JsonObject, objeto com as apis
/*/
Static Function getAgend()
	Local aApis  := RetApiZoom()
	Local cAlias := GetNextAlias()
	Local cApi   := ""
	Local nPos   := 0
	Local oJson  := JsonObject():New()

	BeginSql Alias cAlias
      SELECT T4P_API, T4P_TPEXEC, T4P_ATIVO, T4P_ALTER
	    FROM %Table:T4P%
	   WHERE T4P_FILIAL = %xFilial:T4P%
         AND T4P_TPEXEC = '2'
	     AND %NotDel%
	EndSql

	While (cAlias)->(!Eof())
		cApi := Alltrim((cAlias)->T4P_API)
		nPos := aScan(aApis, {|x| x[1] == cApi})
		If nPos > 0
			oJson[cApi] := JsonObject():New()
			oJson[cApi]["descricao"] := P139GetAPI(cApi)
			oJson[cApi]["tipo"]      := (cAlias)->T4P_TPEXEC
			oJson[cApi]["ativo"]     := (cAlias)->T4P_ATIVO
			oJson[cApi]["alterado"]  := (cAlias)->T4P_ALTER
		EndIf
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())
Return oJson

/*/{Protheus.doc} POST SCHEDULER /api/pcp/v1/pcpdiagnosticoapi/scheduler/new
Cria novo agendamento
@type WSMETHOD
@author douglas.heydt
@since 29/04/2024
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST SCHEDULER WSSERVICE PCPdiagnosticoAPI
    Local cBody      := ::GetContent()
	Local cError     := ""
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

	::SetContentType("application/json")
	If oBody:FromJson(cBody) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0152)) //"Falha na validação do objeto"
    EndIf
    If lRet
        lRet := novoAgend(oBody, @cError)

        If lRet
            ::SetResponse('{"code":200}')
        Else
			PCPReturn(Self, {.F.,400,cError})
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*{Protheus.doc} novoAgend
Cria novo agendamento
@type  Static Function
@author douglas.heydt
@since 29/04/2024
@version P12
@param oBody, Object, Corpo da requisição.
@return lRet, logico, Informa se o processo foi executado com sucesso
*/
Static Function novoAgend(oBody, cError)
	Local aParams    := {}  as Array
	Local cCodUser   := RetCodUsr()
	Local cEnv       := GetEnvServer() as Character
	Local dDate      := Nil
	Local lFrequency := .T.
	Local lPeriod    := .T.
	Local lRet       := .T. as logical
	Local oScheduleAuto

	aAdd(aParams, oBody["executionParameter"]["api"])

	dDate := PCPConvDat(oBody["firstExecution"], 1) +1

	oScheduleAuto := totvs.framework.schedule.automatic():new()
	lRet := oScheduleAuto:setRoutine("PCPA141")
	If lRet
		oScheduleAuto:setFirstExecution(PCPConvDat(dDate),getTime(oBody["firstExecution"]))
		oScheduleAuto:setEnvironment(cEnv,{{cEmpAnt}})
		oScheduleAuto:setModule(10)
		oScheduleAuto:setUser(cCodUser)
		oScheduleAuto:setDescription("Schedule")
		oScheduleAuto:setRecurrence(oBody["recurrent"])
		oScheduleAuto:setParams(aParams)

		If oBody:HasProperty("daily")
			lPeriod := oScheduleAuto:setPeriod("D",,oBody["daily"]["hour"],oBody["daily"]["minute"])
			If oBody:HasProperty("rangeExecutions")
				lFrequency := oScheduleAuto:SetFrequency(getFreq(oBody["rangeExecutions"]["frequency"]["type"]),oBody["rangeExecutions"]["frequency"]["value"],/*nDayLimit*/, oBody["rangeExecutions"]["rangeLimit"]["hour"], oBody["rangeExecutions"]["rangeLimit"]["minute"]  )
			EndIf

		ElseIf oBody:HasProperty("weekly")
			lPeriod := oScheduleAuto:setPeriod("S",,oBody["weekly"]["hour"],oBody["weekly"]["minute"],oBody["weekly"]["daysOfWeek"])
			If oBody:HasProperty("rangeExecutions")
				lFrequency := oScheduleAuto:SetFrequency(getFreq(oBody["rangeExecutions"]["frequency"]["type"]),oBody["rangeExecutions"]["frequency"]["value"],/*nDayLimit*/, oBody["rangeExecutions"]["rangeLimit"]["hour"], oBody["rangeExecutions"]["rangeLimit"]["minute"]  )
			EndIf

		ElseIf oBody:HasProperty("monthly")
			lPeriod := oScheduleAuto:setPeriod("M",oBody["monthly"]["day"],oBody["monthly"]["hour"],oBody["monthly"]["minute"])
			If oBody:HasProperty("rangeExecutions")
				If oBody["rangeExecutions"]["frequency"]["type"] != "day"
					lFrequency := oScheduleAuto:SetFrequency(getFreq(oBody["rangeExecutions"]["frequency"]["type"]),oBody["rangeExecutions"]["frequency"]["value"],oBody["rangeExecutions"]["rangeLimit"]["day"], oBody["rangeExecutions"]["rangeLimit"]["hour"], oBody["rangeExecutions"]["rangeLimit"]["minute"]  )
				Else
					lFrequency := oScheduleAuto:SetFrequency(getFreq(oBody["rangeExecutions"]["frequency"]["type"]),oBody["rangeExecutions"]["frequency"]["value"],oBody["rangeExecutions"]["rangeLimit"]["day"] )
				EndIf
			EndIf
		Else
			lPeriod := oScheduleAuto:setPeriod("U") //periodicidade única
		EndIf

		If lPeriod .And. lFrequency
			If oScheduleAuto:createSchedule()
				lRet := .T.
			Else
				lRet := .F.
				cError := decodeutf8(oScheduleAuto:getErrorMessage())
			EndIf
		EndIf
	EndIf

	aSize(aParams, 0)
	FreeObj(oScheduleAuto)
Return lRet

/*{Protheus.doc} getTime
Recorta o horário definido em um string data no formato yyyy-mm-ddThh:mm:ss-03:00"
Ex: o Datetime "2024-07-16T15:00:00-03:00" retornará "15:00"
@type  Static Function
@author douglas.heydt
@since 29/04/2024
@version P12
@param cDateTime, Character,  Data em formato String yyyy-mm-ddThh:mm:ss-03:00"
@return cTime, Character, Retorna a hora no formato HH:MM
*/
Static Function getTime(cDateTime)
	If !Empty(cDateTime)
		cTime := SubStr(cDateTime, 12, 5)
	EndIf
Return cTime

/*{Protheus.doc} getFreq
Retorna o caracter correto para cada tipo de frequencia definida
@type  Static Function
@author douglas.heydt
@since 08/05/2024
@version P12
@param type, Character,  tipo de frequencia minute/hour/day
@return cReturn, Character, caractere que define o tipo de frequencia
*/
Static Function getFreq(type)

	Local cReturn as Character
	Do Case
		Case type == "minute"
			cReturn := "M"

		Case type == "hour"
			cReturn := "H"

		Case type == "day"
			cReturn := "D"
	EndCase
Return cReturn

/*/{Protheus.doc} DELETE SCHEDULER /api/pcp/v1/pcpdiagnosticoapi/scheduler/{code}
Faz a deleção de um schedule.
@type WSMETHOD
@author douglas.heydt
@since 29/04/2024
@version P12.1.2310
@param code, Character, Id do schedule a ser excluido.
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD DELETE SCHEDULER PATHPARAM code WSSERVICE PCPdiagnosticoAPI
    Local lRet := .T.
	Local cMsg := ""

    Self:SetContentType("application/json")
    lRet := lDelSched(Self:code, @cMsg)
	
	If lRet
		::SetResponse('{"code":200}')
	Else
		SetRestFault(400, cMsg) 
	EndIf

Return lRet

/*{Protheus.doc} lDelSched
Faz a deleção de um schedule.
@type  Static Function
@author douglas.heydt
@since 08/05/2024
@version P12
@param cCodigo, Character, Id do schedule a ser excluido.
@param cMsg   , Character, Mensagem caso houver erro
@return lRec, Lógico, Indica se conseguiu excluir o schedule.
*/
Static Function lDelSched(cCodigo, cMsg)
	local lRet := .T.   as logical
    Local oScheduleAuto as object

	oScheduleAuto := totvs.framework.schedule.automatic():new()

	// Indica o Agendamento a ser excluído
	oScheduleAuto:setSchedule(cCodigo)

	// Dispara Exclusão do Agendamento
	If !oScheduleAuto:deleteSchedule()
		cMsg := oScheduleAuto:getErrorMessage()
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} recGlobal
Recupera o conteudo de uma agrupador na variavel global.
@type  Static Function
@author Lucas Fagundes
@since 24/05/2024
@version P12
@param 01 cAgrupador, Caracter, Código do agrupador.
@param 02 aRet      , Array   , Retorna por referencia o conteudo da global.
@return lRec, Lógico, Indica se conseguiu recuperar a global.
/*/
Static Function recGlobal(cAgrupador, aRet)
	Local lRet := .T.

	If !VarGetAD(DEF_UID_GLOBAL_STATUS, cAgrupador, @aRet)
		P153Error(I18N(STR0049, {cAgrupador})) //"Ocorreu um erro ao recuperar a variável global do agrupador: #1[AGRUPADOR]#"
		lRet := .F.
	EndIf

Return lRet
