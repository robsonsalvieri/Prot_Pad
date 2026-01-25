#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPMONITOR.CH"

Static saTamVisao := TamSX3("HZB_CODIGO")
Static saTamSeque := TamSX3("HZC_SEQUEN")

/*/{Protheus.doc} PCPMonitorAPI
API REST dedicada ao Totvs Supply Monitor
@type  WSCLASS
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
/*/
WSRESTFUL PCPMonitorAPI DESCRIPTION STR0001 //"API REST dedicada ao Totvs Supply Monitor"

WSDATA filtraUsuario   AS BOOLEAN OPTIONAL
WSDATA page            AS INTEGER OPTIONAL
WSDATA pageSize        AS INTEGER OPTIONAL
WSDATA order           AS STRING  OPTIONAL
WSDATA filter          AS STRING  OPTIONAL
WSDATA codVisao        AS INTEGER OPTIONAL
WSDATA expand          AS STRING  OPTIONAL
WSDATA codMonitor      AS STRING  OPTIONAL
WSDATA sequencia       AS INTEGER OPTIONAL
WSDATA agrupador       AS STRING  OPTIONAL
WSDATA usuario         AS STRING  OPTIONAL
WSDATA value           AS STRING  OPTIONAL
WSDATA metodo          AS STRING  OPTIONAL
WSDATA filial          AS STRING  OPTIONAL
WSDATA Code            AS STRING  OPTIONAL
WSDATA tabela          AS STRING  OPTIONAL
WSDATA campoCodigo     AS STRING  OPTIONAL
WSDATA campoDescricao  AS STRING  OPTIONAL
WSDATA codUsuario      AS STRING  OPTIONAL
WSDATA codApresentacao AS STRING OPTIONAL
WSDATA logPadrao       AS BOOLEAN OPTIONAL
WSDATA codPropriedade  AS STRING  OPTIONAL

//Visão
WSMETHOD DELETE VISAOID;
	DESCRIPTION STR0006; //"Exclui uma Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/{codVisao}";
	PATH "api/pcp/v1/pcpmonitorapi/visao/{codVisao}";
    TTALK "v1"

WSMETHOD PUT VISAOID;
	DESCRIPTION STR0007; //"Edita uma Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/{codVisao}";
	PATH "api/pcp/v1/pcpmonitorapi/visao/{codVisao}";
    TTALK "v1"

WSMETHOD GET VISAOID;
	DESCRIPTION STR0008; //"Retorna os dados de uma Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/{codVisao}";
	PATH "api/pcp/v1/pcpmonitorapi/visao/{codVisao}";
    TTALK "v1"

WSMETHOD GET VISAO;
	DESCRIPTION STR0009; //"Retorna os dados de várias Visões"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao";
	PATH "api/pcp/v1/pcpmonitorapi/visao";
    TTALK "v1"

WSMETHOD POST VISAO;
	DESCRIPTION STR0010; //"Inclui uma Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao";
	PATH "api/pcp/v1/pcpmonitorapi/visao";
    TTALK "v1"

WSMETHOD GET VALIDVISAO;
	DESCRIPTION STR0055; //"Valida se o usuário pode criar visões";
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/allowCreation";
	PATH "api/pcp/v1/pcpmonitorapi/visao/allowCreation";
    TTALK "v1"

WSMETHOD GET USUARIOS;
	DESCRIPTION STR0038; //"Retorna a lista de Usuários do Sistema"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/usuarios";
	PATH "api/pcp/v1/pcpmonitorapi/usuarios";
    TTALK "v1"

WSMETHOD GET IDUSUARIO;
	DESCRIPTION STR0039; //"Retorna os dados de um Usuário do Sistema"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/usuarios/{usuario}";
	PATH "api/pcp/v1/pcpmonitorapi/usuarios/{usuario}";
    TTALK "v1"

WSMETHOD POST USUARIOS;
	DESCRIPTION STR0040; //"Inclui um usuário na Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/saveUsuarios";
	PATH "api/pcp/v1/pcpmonitorapi/visao/saveUsuarios";
    TTALK "v1"

WSMETHOD DELETE USUARIOS;
	DESCRIPTION STR0041; //"Exclui um usuário na Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/deleteUsuarios/{codVisao}/{usuario}";
	PATH "api/pcp/v1/pcpmonitorapi/visao/deleteUsuarios/{codVisao}/{usuario}";
    TTALK "v1"

WSMETHOD POST FAVORITAVISAO;
	DESCRIPTION STR0014; //"Atualiza uma Visão como favorita"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/favoritaVisao";
	PATH "api/pcp/v1/pcpmonitorapi/visao/favoritaVisao";
    TTALK "v1"

WSMETHOD POST DESFAVORITAVISAO;
	DESCRIPTION STR0028; //"Desfavorita uma Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/desfavoritaVisao";
	PATH "api/pcp/v1/pcpmonitorapi/visao/desfavoritaVisao";
    TTALK "v1"

//Monitor
WSMETHOD GET MODULO;
    DESCRIPTION STR0017; //"Retorna os Modulos que agruparão os Monitores"
    WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/modulos";
    PATH "api/pcp/v1/pcpmonitorapi/monitor/modulos";
    TTALK "v1"

WSMETHOD POST DATA;
    DESCRIPTION STR0018; //"Retorna os dados para apresentar no Monitor"
    WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/monitorDataSchema";
    PATH "api/pcp/v1/pcpmonitorapi/monitor/monitorDataSchema";
    TTALK "v1"

WSMETHOD POST VALIDATE;
    DESCRIPTION STR0019; //"Valida se o usuário tem acesso ao Monitor"
    WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/validate";
    PATH "api/pcp/v1/pcpmonitorapi/monitor/validate";
    TTALK "v1"

WSMETHOD GET MONITOR;
    DESCRIPTION STR0020; //"Retorna os Monitores"
    WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor";
    PATH "api/pcp/v1/pcpmonitorapi/monitor";
    TTALK "v1"

WSMETHOD GET IDMONITOR;
    DESCRIPTION STR0258; //"Retorna os dados do Monitor"
    WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}";
    PATH "api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}";
    TTALK "v1"

WSMETHOD DELETE MONITOR;
	DESCRIPTION STR0259; //"Exclui o Monitor Customizado"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}";
	PATH "api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}";
    TTALK "v1"

WSMETHOD PUT MONITOR;
	DESCRIPTION STR0260; //"Altera informações do Monitor Customizado"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}";
	PATH "api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}";
    TTALK "v1"

WSMETHOD POST MONITOR;
	DESCRIPTION STR0261; //"Inclui novo Monitor Customizado"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor";
	PATH "api/pcp/v1/pcpmonitorapi/monitor";
    TTALK "v1"

WSMETHOD POST PROPRIEDADE;
	DESCRIPTION STR0262; //"Inclui nova propriedade do Monitor"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/propriedade";
	PATH "api/pcp/v1/pcpmonitorapi/monitor/propriedade";
    TTALK "v1"

WSMETHOD PUT PROPRIEDADE;
	DESCRIPTION STR0263; //"Inclui nova propriedade do Monitor"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/propriedade/{codPropriedade}/{codMonitor}";
	PATH "api/pcp/v1/pcpmonitorapi/monitor/propriedade/{codPropriedade}/{codMonitor}";
    TTALK "v1"

WSMETHOD DELETE PROPRIEDADE;
	DESCRIPTION STR0264; //"Inclui nova propriedade do Monitor"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/propriedade/{codPropriedade}/{codMonitor}";
	PATH "api/pcp/v1/pcpmonitorapi/monitor/propriedade/{codPropriedade}/{codMonitor}";
    TTALK "v1"

WSMETHOD POST PROP_REORDER;
	DESCRIPTION STR0265; //"Ordena as propriedades do Monitor"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/propriedade/reorder";
	PATH "api/pcp/v1/pcpmonitorapi/monitor/propriedade/reorder";
    TTALK "v1"

WSMETHOD POST LOADMONITORS;
    DESCRIPTION STR0002; //"Realiza a carga dos Monitores"
    WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/loadMonitors";
    PATH "api/pcp/v1/pcpmonitorapi/monitor/loadMonitors";
    TTALK "v1"

WSMETHOD POST DETAILS;
    DESCRIPTION STR0004; //"Retorna os dados para montar os detalhes"
    WSSYNTAX "api/pcp/v1/pcpmonitorapi/monitor/details";
    PATH "api/pcp/v1/pcpmonitorapi/monitor/details";
    TTALK "v1"

//Visão Monitor
WSMETHOD GET GET_VISMONIT;
	DESCRIPTION STR0021; //"Retorna os Monitores da Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoMonitor";
	PATH "api/pcp/v1/pcpmonitorapi/visaoMonitor";
    TTALK "v1"

WSMETHOD PUT PUT_VISMONIT;
	DESCRIPTION STR0022; //"Altera os dados do Monitor na Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoMonitor/{codVisao}/{codMonitor}/{sequencia}";
	PATH "api/pcp/v1/pcpmonitorapi/visaoMonitor/{codVisao}/{codMonitor}/{sequencia}";
    TTALK "v1"

WSMETHOD POST POST_VISMONIT;
	DESCRIPTION STR0023; //"Inclui um Monitor em uma Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoMonitor";
	PATH "api/pcp/v1/pcpmonitorapi/visaoMonitor";
    TTALK "v1"

WSMETHOD DELETE DELETE_VISMONIT;
	DESCRIPTION STR0024; //"Exclui o Monitor da Visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoMonitor/{codVisao}/{codMonitor}/{sequencia}";
	PATH "api/pcp/v1/pcpmonitorapi/visaoMonitor/{codVisao}/{codMonitor}/{sequencia}";
    TTALK "v1"

WSMETHOD POST COPIA_VISAO;
	DESCRIPTION STR0045; //"Copia uma visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visao/copiaVisao/{codVisao}";
	PATH "api/pcp/v1/pcpmonitorapi/visao/copiaVisao/{codVisao}";
    TTALK "v1"

WSMETHOD POST ORDENA_MONIT;
	DESCRIPTION STR0233; //"Atualiza ordenação de monitores de uma visão"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoMonitor/reorder";
	PATH "api/pcp/v1/pcpmonitorapi/visaoMonitor/reorder";
    TTALK "v1"

//Consulta combo
WSMETHOD GET LISTA_CONSULTA;
	DESCRIPTION STR0048; //"Retorna uma lista de registros"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/consulta";
	PATH "api/pcp/v1/pcpmonitorapi/consulta";
    TTALK "v1"

WSMETHOD GET ITEM_CONSULTA;
	DESCRIPTION STR0049; //"Retorna um registro da lista"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/consulta/{value}";
	PATH "api/pcp/v1/pcpmonitorapi/consulta/{value}";
    TTALK "v1"

//Modo Apresentação
WSMETHOD GET APRESENTACOES;
	DESCRIPTION STR0236; //"Retorna as apresentações cadastradas"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario";
	PATH "api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario";
    TTALK "v1"

WSMETHOD POST APRESENTACAO;
	DESCRIPTION STR0237; //"Cria uma nova apresentação"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario";
	PATH "api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario";
    TTALK "v1"

WSMETHOD PUT APRESENTACAO;
	DESCRIPTION STR0238; //"Edita uma apresentação"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario/{codUsuario}/{codApresentacao}";
	PATH "api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario/{codUsuario}/{codApresentacao}";
    TTALK "v1"

WSMETHOD DELETE APRESENTACAO;
	DESCRIPTION STR0239; //"Exclui uma apresentação"
	WSSYNTAX "api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario/{codUsuario}/{codApresentacao}";
	PATH "api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario/{codUsuario}/{codApresentacao}";
    TTALK "v1"

END WSRESTFUL

/*/{Protheus.doc} POST DETAILS api/pcp/v1/pcpmonitorapi/monitor/details
Retorna os detalhes dos dados
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST DETAILS WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local cBody   := ::GetContent()
    Local lRet    := .T.
    Local oBody   := JsonObject():New()

    ::SetContentType("application/json")
	If oBody:FromJson(DecodeUTF8(cBody)) <> NIL .Or.; 
        !oBody:HasProperty("apiNegocio") .Or.;
        !oBody:HasProperty("page") .Or.;
        !oBody:HasProperty("propriedades")
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0035)) //"Parâmetros inválidos para busca dos dados dos detalhes."
    EndIf
    If lRet
        aReturn := buscaDetal(oBody)
        lRet    := aReturn[1]
        If lRet
            ::SetResponse(aReturn[2])
        EndIf
    EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} buscaDetal
Retorna os detalhes dos dados
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  oPropri, objeto Json, Objeto json com o corpo da requisição
@return aResult, array      , Array preparado com o retorno da requisição
/*/
Static Function buscaDetal(oBody)
    Local aResult   := {.T.,"",200}
    Local cFunc     := AllTrim(oBody["apiNegocio"])
    Local cRetorno  := ""
    Local nIndice   := 0
    Local nPagina   := 1
    Local oFiltro   := JsonObject():New()
    Local oPropri   := oBody["propriedades"]

    nPagina := oBody["page"]
    If oBody:HasProperty("serie") .And. !Empty(oBody["serie"])
        oFiltro["SERIE"] := oBody["serie"]
    EndIf
    If oBody:HasProperty("categoria") .And. !Empty(oBody["categoria"])
        oFiltro["CATEGORIA"] := oBody["categoria"]
    EndIf
    If oBody:HasProperty("parametrosDetalhe") .And. !Empty(oBody["parametrosDetalhe"])
        oFiltro["PARAMETROSDETALHE"] := oBody["parametrosDetalhe"]
    EndIf
    For nIndice := 1 To Len(oPropri)
        oFiltro[oPropri[nIndice]["codPropriedade"]] := oPropri[nIndice]["valorPropriedade"]
    Next nIndice
    cFunc := cFunc + "():BuscaDetalhes(oFiltro,nPagina)"
    cRetorno := &(cFunc)
    aResult[2] := EncodeUTF8(cRetorno)
    
    //Ponto de entrada utilizado para alterar caracteristicas dos monitores
	If ExistBlock("PBDetail")
		aResult[2] := ExecBlock("PBDetail",.F.,.F., {oBody["codVisao"], oBody["codMonitor"], oBody["sequencia"], aResult[2]})
	EndIf

    FREEOBJ(oFiltro)
Return aResult

/*/{Protheus.doc} POST LOADMONITORS api/pcp/v1/pcpmonitorapi/monitor/loadMonitors
Realiza a carga dos Monitores
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST LOADMONITORS WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local lRet       := .T.
    Local oJsonRet   := JsonObject():New()

	::SetContentType("application/json")
    If lRet
        Begin Transaction
            Begin Sequence
                lRet := cargaMonit()
            Recover
                lRet := .F.
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(EncodeUTF8(oJsonRet:ToJson()))
        Else
            SetRestFault(400,EncodeUTF8(STR0036)) //"Ocorreram erros na carga dos Monitores. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oJsonRet)
Return lRet

/*/{Protheus.doc} cargaMonit
Chama os métodos das classes de negócio para realizar a carga dos Monitores na base de dados
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
Static Function cargaMonit()
    Local aMonitores := {}
    Local nIndice    := 0
    Local lRet       := .T.

    PCPMonitorUtils():RetornaListaMonitoresPadrao(@aMonitores)
    For nIndice := 1 To Len(aMonitores)
        lRet := &(aMonitores[nIndice][1] + "():CargaMonitor()")
        If !lRet
            Exit
        EndIf
    Next nIndice
    FwFreeArray(aMonitores)
Return lRet

/*/{Protheus.doc} valPropr
Chama o método de validação de propriedades da classe negócio
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  oBody  , objeto json, Objeto json com as propriedades a serem validadas
@param  lValTam, logico     , Indica se validará o tamanho do conteúdo informado na propriedade
@return lRet   , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function valPropr(oBody,lValTam)
    Local aRetorno   := {.T.,""}
    Local cApiNeg    := oBody["apiNegocio"]
    Local cValor     := ""
    Local nIndice    := 0
    Local nLenProp   := Len(oBody["propriedades"])
    Local aTamPropVl := TamSX3("HZD_PROPVL")
    Local oFiltro    := JsonObject():New()

    Default lValTam := .F.

    If FindClass(cApiNeg)
        For nIndice := 1 To nLenProp
            oFiltro[oBody["propriedades"][nIndice]["codPropriedade"]] := oBody["propriedades"][nIndice]["valorPropriedade"]
        Next nIndice
        aRetorno := &(cApiNeg + "():ValidaPropriedades(oFiltro)")

        If lValTam .And. aRetorno[1]
            For nIndice := 1 To nLenProp
                cValor := fmtVlPrGrv(oBody["propriedades"][nIndice]["tipo"],oBody["propriedades"][nIndice]["valorPropriedade"])
                If aTamPropVl[3] == "C" .And. Len(cValor) > aTamPropVl[1]
                    aRetorno[1] := .F.
                    aRetorno[2] := STR0266 + "'" + oBody["propriedades"][nIndice]["titulo"] + "'" + STR0267 //"A propriedade " " ultrapassou o tamanho máximo permitido. Por favor, revise o conteúdo do campo."
                    Exit
                EndIf
                oBody["propriedades"][nIndice]["valorPropriedade"] := cValor
            Next nIndice
        EndIf
    Else
        aRetorno[1] := .F.
        aRetorno[2] := STR0268 + "'" + cApiNeg + "'" + STR0269 //"A classe " " não foi encontrada. É necessário que esta seja compilada no RPO para acesso ao Monitor."
    EndIf
    FreeObj(oFiltro)
Return aRetorno

/*/{Protheus.doc} DELETE DELETE_VISMONIT api/pcp/v1/pcpmonitorapi/visaoMonitor/{codVisao}/{codMonitor}/{sequencia}
Exclui um Monitor da Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	codVisao  , numerico, Codigo da Visão
@param	codMonitor, caracter, Codigo do Monitor
@param	sequencia , numerico, Sequencia do Monitor na Visão
@return lRet      , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD DELETE DELETE_VISMONIT PATHPARAM codVisao,codMonitor,sequencia WSSERVICE PCPMonitorAPI 
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local lRet        := .F.
    Local oJson       := JsonObject():New()

    ::SetContentType("application/json")
    Begin Transaction
        Begin Sequence
            lRet := excluiVisMt(::codVisao,::codMonitor,::sequencia)
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBloc)
    If lRet
        ::SetResponse(PCPMMsgSuc(oJson))
    Else
        SetRestFault(400,EncodeUTF8(STR0026)) //"Ocorreram erros na exclusão do Monitor da Visão. Contate o administrador do sistema."
    EndIf
	FreeObj(oJson)
Return lRet

/*/{Protheus.doc} excluiVisMt
Exclui um Monitor da Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	nCodVisao  , numerico, Codigo da Visão
@param	cCodMonit  , caracter, Codigo do Monitor
@param	nSequencia , numerico, Sequencia do Monitor na Visão
@return lRet       , logico  , Informa se o processo foi executado com sucesso
/*/
Static Function excluiVisMt(nCodVisao,cCodMonit,nSequencia)
    Local lRet    := .F.

    HZC->(dbSetOrder(1))
    If HZC->(dbSeek(xFilial("HZC")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])+cCodMonit+STR(nSequencia,saTamSeque[1],saTamSeque[2])))
        RecLock("HZC",.F.)
        HZC->(dbDelete())
        HZC->(MsUnlock())
        HZC->(dbCloseArea())
        
        HZD->(dbSetOrder(1))
        If HZD->(dbSeek(xFilial("HZD")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])+cCodMonit+STR(nSequencia,saTamSeque[1],saTamSeque[2])))
            lRet := .T.
            While HZD->(!Eof()) .And. HZD->(HZD_FILIAL+STR(HZD_VISAO,saTamVisao[1],saTamVisao[2])+HZD_MONIT+STR(HZD_SEQUEN,saTamSeque[1],saTamSeque[2])) == xFilial("HZD")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])+cCodMonit+STR(nSequencia,saTamSeque[1],saTamSeque[2])
                RecLock("HZD",.F.)
                HZD->(dbDelete())
                HZD->(MsUnlock())
                HZD->(dbSkip())
            End
            HZD->(dbCloseArea())
        Else
            DisarmTransaction()
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} POST POST_VISMONIT api/pcp/v1/pcpmonitorapi/visaoMonitor
Inclui um Monitor da Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST POST_VISMONIT WSSERVICE PCPMonitorAPI
    Local aRetValPr  := {}
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()
    Local oJsonRet   := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0027)) //"Parâmetros inválidos para inclusão do Monitor na Visão."
    EndIf
    aRetValPr := valPropr(oBody,.T.)
    If !aRetValPr[1]
        lRet := .F.
        SetRestFault(400,EncodeUTF8(aRetValPr[2]))
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence
                lRet := incluiVsMt(oBody)
            Recover
                lRet := .F.
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oJsonRet))
        Else
            SetRestFault(400,EncodeUTF8(STR0029)) //"Ocorreram erros na inclusão do Monitor na Visão. Contate o administrador do sistema."
        EndIf
    EndIf
    FwFreeArray(aRetValPr)
    FreeObj(oBody)
    FreeObj(oJsonRet)
Return lRet

/*/{Protheus.doc} incluiVsMt
Inclui um Monitor da Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	oBody  , objeto Json, body do POST
@return lRet   , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function incluiVsMt(oBody)
    Local cAlias    := GetNextAlias()
    Local cValProp  := ""
    Local lRet      := .T.
    Local nCodVisao := oBody["codVisao"]
    Local nIndice   := 0
    Local nSequen   := 0

    BeginSql Alias cAlias
		SELECT 
            MAX(HZC_SEQUEN) AS HZC_SEQUEN 
        FROM %Table:HZC% HZC
        WHERE HZC.HZC_FILIAL = %xFilial:HZC%
          AND HZC.HZC_VISAO  = %Exp:nCodVisao%
          AND HZC.%NotDel%
	EndSql
    nSequen := (cAlias)->HZC_SEQUEN + 1
    (cAlias)->(DbCloseArea())

    RecLock("HZC", .T.)
    HZC->HZC_FILIAL := xFilial("HZC")
    HZC->HZC_VISAO  := nCodVisao
    HZC->HZC_MONIT  := oBody["codMonitor"]
    HZC->HZC_SEQUEN := nSequen
    HZC->HZC_TITULO := oBody["titulo"]
    HZC->HZC_TAMAN  := oBody["tamanho"]
    HZC->HZC_POSIC  := IIF(oBody:HasProperty("posicao"),oBody["posicao"],0)
    HZC->HZC_TIPO   := oBody["tipo"]
    HZC->HZC_TIPOGR := oBody["subtipo"]
    HZC->HZC_ATUAUT := IIF(oBody:HasProperty("atualizaAutomatico") .And. oBody["atualizaAutomatico"],"S","N")
    HZC->HZC_TMPATU := oBody["tempoAtualizacao"]
    HZC->(MsUnlock())

    For nIndice := 1 To Len(oBody["propriedades"])
        cValProp := ""
        If oBody["propriedades"][nIndice]:HasProperty("valorPropriedade")
            cValProp := fmtVlPrGrv(oBody["propriedades"][nIndice]["tipo"],oBody["propriedades"][nIndice]["valorPropriedade"])
        EndIf
        RecLock("HZD", .T.)
        HZD->HZD_FILIAL := xFilial("HZD")
        HZD->HZD_VISAO  := nCodVisao
        HZD->HZD_MONIT  := oBody["codMonitor"]
        HZD->HZD_SEQUEN := nSequen
        HZD->HZD_PROP   := oBody["propriedades"][nIndice]["codPropriedade"]
        HZD->HZD_PROPVL := cValProp
        HZD->(MsUnlock())
    Next nIndice
Return lRet

Static Function fmtVlPrGrv(nTipo,xValor)
    If ValType(xValor) == "A" .And. (nTipo == 5 .Or. nTipo == 6 .Or. nTipo == 8)
        xValor := ArrTokStr(xValor,",")
    Else
        xValor := cValToChar(xValor)
    EndIf
Return xValor

/*/{Protheus.doc} POST VALIDATE api/pcp/v1/pcpmonitorapi/monitor/validate
Valida se o usuário tem acesso ao conteúdo do Monitor
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST VALIDATE WSSERVICE PCPMonitorAPI
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()
    Local oJsonRet   := JsonObject():New()

	::SetContentType("application/json")
	If oBody:FromJson(cBody) <> NIL .Or. !oBody:HasProperty("apiNegocio")
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0030)) //"Parâmetros inválidos para validar o acesso ao Monitor."
    EndIf
    If lRet
        lRet := valAccess(oBody["apiNegocio"])
        If lRet
            ::SetResponse(EncodeUTF8(oJsonRet:ToJson()))
        Else
            SetRestFault(400,EncodeUTF8(STR0037)) //"Acesso não permitido ao Monitor. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} valAccess
Valida se o usuário tem acesso à um item de menu
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	cAPINeg, caracter, Nome da função de negócio que está vinculada a regra, caso ela exista
@return lRet   , logico  , Informa se o processo foi executado com sucesso
/*/
Static Function valAccess(cAPINeg)
    Local lRet     := .F.
    Local nIndMenu := PCPMonitorUtils():RetornaIndiceListaMonitores(cAPINeg)
  
    IF nIndMenu > 0
        If MPUserHasAccess("PCPMONITOR",nIndMenu)
            lRet := .T.
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} GET MONITOR api/pcp/v1/pcpmonitorapi/monitor
Retorna os Monitores
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	agrupador, caracter, Modulo agrupador do Monitor
@param	expand   , caracter, Se expande o conteúdo das proprieadades do Monitor
@param	filter   , caracter, Filtro com o nome parcial do titulo ou objetivo do Monitor
@param  logPadrao, logico  , Indica se busca Monitor padrao
@return lRet     , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET MONITOR WSRECEIVE agrupador,expand,filter,logPadrao WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    Default ::agrupador := "", ::expand := "", ::filter := "", ::logPadrao := .T.

    ::SetContentType("application/json")
    aReturn := buscaMonit(::agrupador,::expand,::filter,,::logPadrao)
    lRet    := aReturn[1]
    If lRet
        ::SetResponse(aReturn[2])
    EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} GET MONITOR api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}
Retorna os dados do Monitor
@type WSMETHOD
@author renan.roeder
@since 13/09/2023
@version P12.1.2310
@param	codMonitor, caracter, Codigo do Monitor
@return lRet      , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET IDMONITOR PATHPARAM codMonitor WSRECEIVE expand WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    ::SetContentType("application/json")
    aReturn := buscaMonit(,::expand,,::codMonitor,.F.)
    lRet    := aReturn[1]
    If lRet
        ::SetResponse(aReturn[2])
    EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} buscaMonit
Retorna os Monitores
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	cAgrupador, caracter, Modulo agrupador do Monitor
@param	cExpand   , caracter, Se expande o conteúdo das proprieadades do Monitor
@param	cFilter   , caracter, Filtro com o nome parcial do titulo ou objetivo do Monitor
@param  cCodMonit , caracter, Codigo do Monitor
@param  lPadrao   , logico  , Indica se busca Monitor padrao
@return aResult   , array   , Array preparado com o retorno da requisição
/*/
Static Function buscaMonit(cAgrupador,cExpand,cFilter,cCodMonit,lPadrao)
    Local aResult   := {.T.,"",200}
    Local cAlias    := GetNextAlias()
    Local cCondic   := ""
    Local nPos      := 0
    Local oJson     := JsonObject():New()

    Default cAgrupador := "", cExpand := "", cFilter := "", cCodMonit := "", lPadrao := .T.

    cCondic += "%"
    cCondic += " " + RetSqlName("HZE") + " HZE "
    cCondic += "WHERE HZE.HZE_FILIAL = '" + xFilial("HZE") + "' "
    cCondic += "AND HZE.D_E_L_E_T_ = ' ' "
    If !Empty(cCodMonit)
        cCondic += "AND HZE.HZE_CODIGO = '"+cCodMonit+"' "
    Else
        If !Empty(cAgrupador)
            cCondic += "AND HZE.HZE_AGRUP = '"+cAgrupador+"' "
        EndIf
        If !Empty(cFilter)
            cCondic += "AND (UPPER(HZE.HZE_TITULO) LIKE '%"+UPPER(cFilter)+"%' OR UPPER(HZE.HZE_OBJTV) LIKE '%"+UPPER(cFilter)+"%') "
        EndIf
        If !lPadrao
            cCondic += " AND HZE.HZE_PADRAO = 'N' "
        Else
            DbSelectArea("HZE")
            If HZE->(FieldPos("HZE_USUAR")) > 0      
                cCondic += " AND (HZE.HZE_PADRAO = 'S' OR (HZE.HZE_PADRAO = 'N' AND (HZE.HZE_RASCUN = 'N' OR (HZE.HZE_RASCUN = 'S' AND HZE.HZE_USUAR = '" + RetCodUsr() + "')))) "
            EndIf
        EndIf
    EndIf
    cCondic += "%"

    BeginSql Alias cAlias
        SELECT
          HZE.HZE_CODIGO,HZE.HZE_TITULO,HZE.HZE_AGRUP,HZE.HZE_APINEG,HZE.HZE_TIPO,HZE.HZE_TIPOGR,
          HZE.HZE_PADRAO,HZE.HZE_TPDETL,HZE.HZE_TPPD,HZE.HZE_TPGRPD,HZE.HZE_VERSAO,HZE.HZE_RASCUN,
          HZE.HZE_OBJTV,HZE.HZE_EXJSON
        FROM %Exp:cCondic%
    EndSql
    oJson["hasNext"] := .F.
    oJson["items"] := {}
    While (cAlias)->(!Eof())
        aAdd(oJson["items"], JsonObject():New())
        nPos++
        oJson["items"][nPos]["codMonitor"]    := AllTrim((cAlias)->HZE_CODIGO)
        oJson["items"][nPos]["titulo"]        := AllTrim((cAlias)->HZE_TITULO)
        oJson["items"][nPos]["objetivo"]      := AllTrim((cAlias)->HZE_OBJTV)
        oJson["items"][nPos]["agrupador"]     := AllTrim((cAlias)->HZE_AGRUP)
        oJson["items"][nPos]["apiNegocio"]    := AllTrim((cAlias)->HZE_APINEG)
        oJson["items"][nPos]["logPadrao"]     := IIF((cAlias)->HZE_PADRAO == "S",.T.,.F.)
        oJson["items"][nPos]["opcoesTipo"]    := AllTrim((cAlias)->HZE_TIPO)
        oJson["items"][nPos]["opcoesSubtipo"] := AllTrim((cAlias)->HZE_TIPOGR)
        oJson["items"][nPos]["exemploJSON"]   := AllTrim((cAlias)->HZE_EXJSON)
        oJson["items"][nPos]["tipoDetalhe"]   := AllTrim((cAlias)->HZE_TPDETL)
        oJson["items"][nPos]["tipo"]          := AllTrim((cAlias)->HZE_TPPD)
        oJson["items"][nPos]["subtipo"]       := AllTrim((cAlias)->HZE_TPGRPD)
        oJson["items"][nPos]["versao"]        := AllTrim((cAlias)->HZE_VERSAO)
        oJson["items"][nPos]["rascunho"]      := IIF((cAlias)->HZE_RASCUN == "S",.T.,.F.)
        If cExpand == "propriedades"
            buscaMtPro(@oJson["items"][nPos],(cAlias)->HZE_CODIGO)
        EndIf
        (cAlias)->(dbSkip())
	End    
	(cAlias)->(dbCloseArea())
    aResult[2] := EncodeUTF8(oJson:ToJson())
    If !Empty(cCodMonit) .And. nPos > 0
        aResult[2] := EncodeUTF8(oJson["items"][nPos]:ToJson())
    EndIf
	FreeObj(oJson)
Return aResult

/*/{Protheus.doc} buscaMtPro
Retorna as propriedades do Monitor
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	oJson    , objeto Json, Objeto Json passado como referência para retornar as propriedades do Monitor
@param	cCodMonit, caracter   , Codigo do Monitor
@return Nil
/*/
Static Function buscaMtPro(oJson,cCodMonit)
    Local cAlias     := GetNextAlias()
    Local cOrder     := "HZF.HZF_FILIAL,HZF.HZF_MONIT,HZF.HZF_CODIGO"
    Local nPos       := 0

    DbSelectArea("HZF")
    If HZF->(FieldPos("HZF_POSIC")) > 0
        cOrder := "HZF.HZF_FILIAL,HZF.HZF_MONIT,HZF.HZF_POSIC,HZF.HZF_CODIGO"
    EndIf
    cOrder  := "%" + cOrder  + "%"
    BeginSql Alias cAlias
        SELECT
          HZF.HZF_CODIGO,HZF.HZF_MONIT,HZF.HZF_VALPAD,HZF.HZF_TITULO,HZF.HZF_TIPO,HZF.HZF_TAMTXT,HZF.HZF_TAMNUM,
          HZF.HZF_TAMDEC,HZF.HZF_CLSCMP,HZF.HZF_ESTCMP,HZF.HZF_ICNCMP,HZF.HZF_PRMADC
        FROM %table:HZF% HZF
        WHERE HZF.HZF_FILIAL = %xFilial:HZF%
          AND HZF.HZF_MONIT  = %Exp:cCodMonit%
          AND HZF.%NotDel%
          ORDER BY %Exp:cOrder%
    EndSql
    oJson["propriedades"] := {}
    While (cAlias)->(!Eof())   
        aAdd(oJson["propriedades"], JsonObject():New())
        nPos++
        oJson["propriedades"][nPos]["codPropriedade"]    := AllTrim((cAlias)->HZF_CODIGO)
        oJson["propriedades"][nPos]["codMonitor"]        := AllTrim((cAlias)->HZF_MONIT)
        oJson["propriedades"][nPos]["valorPadrao"]       := AllTrim((cAlias)->HZF_VALPAD)
        oJson["propriedades"][nPos]["titulo"]            := AllTrim((cAlias)->HZF_TITULO)
        oJson["propriedades"][nPos]["tipo"]              := (cAlias)->HZF_TIPO
        oJson["propriedades"][nPos]["tamanhoTexto"]      := (cAlias)->HZF_TAMTXT
        oJson["propriedades"][nPos]["tamanhoNumerico"]   := (cAlias)->HZF_TAMNUM
        oJson["propriedades"][nPos]["tamanhoDecimal"]    := (cAlias)->HZF_TAMDEC
        oJson["propriedades"][nPos]["classes"]           := AllTrim((cAlias)->HZF_CLSCMP)
        oJson["propriedades"][nPos]["estilos"]           := AllTrim((cAlias)->HZF_ESTCMP)
        oJson["propriedades"][nPos]["icone"]             := AllTrim((cAlias)->HZF_ICNCMP)
        atrbPrJson(oJson["propriedades"][nPos],(cAlias)->HZF_PRMADC)
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())
Return

/*/{Protheus.doc} DELETE MONITOR api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}
Exclui um Monitor Customizado
@type WSMETHOD
@author renan.roeder
@since 13/09/2023
@version P12.1.2310
@param	codMonitor, caracter, Codigo do Monitor
@return lRet      , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD DELETE MONITOR PATHPARAM codMonitor WSSERVICE PCPMonitorAPI 
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local lRet        := .F.

    ::SetContentType("application/json")
    Begin Transaction
        Begin Sequence
            lRet := excluiMoni(::codMonitor)
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBloc)
    If lRet
        ::SetResponse(PCPMMsgSuc())
    Else
        SetRestFault(400,EncodeUTF8(STR0246)) //"Ocorreram erros na exclusão do Monitor. Contate o administrador do sistema."
    EndIf
Return lRet

/*/{Protheus.doc} excluiMoni
Excluir o Monitor e suas propriedades e o cadastro nas visões
@type Static Function
@author renan.roeder
@since 14/09/2023
@version P12.1.2310
@param	cCodMonit, caracter, Codigo do Monitor
@return lRet     , logico  , Informa se o processo foi executado com sucesso
/*/
Static Function excluiMoni(cCodMonit)
    Local cDelHZE := ""
    Local cDelHZF := ""
    Local cDelHZC := ""
    Local cDelHZD := ""
    Local lRet    := .T.

    cDelHZE := "UPDATE " + RetSqlName("HZE") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE HZE_CODIGO = '"+cCodMonit+"'"
    If TcSqlExec(cDelHZE) < 0
        lRet := .F.
    Else
        cDelHZF := "UPDATE " + RetSqlName("HZF") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE HZF_MONIT = '"+cCodMonit+"'"
        If TcSqlExec(cDelHZF) < 0
            lRet := .F.
        Else
            cDelHZC := "UPDATE " + RetSqlName("HZC") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE HZC_MONIT = '"+cCodMonit+"'"
            If TcSqlExec(cDelHZC) < 0
                lRet := .F.
            Else
                cDelHZD := "UPDATE " + RetSqlName("HZD") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE HZD_MONIT = '"+cCodMonit+"'"
                If TcSqlExec(cDelHZD) < 0
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf
    If !lRet
        DisarmTransaction()
        LogMsg('PCPMonitorAPI', 0, 0, 1, '', '', Replicate("-",70) + CHR(10) + TcSqlError() + CHR(10) + Replicate("-",70))
    EndIf
Return lRet

/*/{Protheus.doc} PUT MONITOR api/pcp/v1/pcpmonitorapi/monitor/{codMonitor}
Altera informações do Monitor Customizado
@type WSMETHOD
@author renan.roeder
@since 13/09/2023
@version P12.1.2310
@param	codMonitor, caracter, Codigo do Monitor
@return lRet      , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD PUT MONITOR PATHPARAM codMonitor WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local lRet       := .F.
    Local cBody      := ::GetContent()
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0247)) //"Parâmetros inválidos para edição das propriedades do Monitor."
    EndIf
    Begin Transaction
        Begin Sequence
            lRet := editaMonit(::codMonitor,oBody)
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBloc)
    If lRet
        ::SetResponse(PCPMMsgSuc(oBody,STR0052)) //"Monitor exclusivo alterado com sucesso!"
    Else
        SetRestFault(400,EncodeUTF8(STR0248)) //"Ocorreram erros na alteração do Monitor. Contate o administrador do sistema."
    EndIf
	FreeObj(oBody)
Return lRet

/*/{Protheus.doc} editaMonit
Edita informações do Monitor Customizado
@type Static Function
@author renan.roeder
@since 14/09/2023
@version P12.1.2310
@param	cCodMonit, caracter   , Codigo do Monitor
@param  oMonitor , objeto json, Objeto Json com os dados do Monitor que devem ser gravados
@return lRet     , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function editaMonit(cCodMonit, oMonitor)
    Local lRet    := .F.

    HZE->(dbSetOrder(2))
    If HZE->(dbSeek(xFilial("HZE")+cCodMonit))
        RecLock("HZE", .F.)
            HZE->HZE_TITULO := oMonitor["titulo"]
            HZE->HZE_OBJTV  := oMonitor["objetivo"]
            HZE->HZE_AGRUP  := oMonitor["agrupador"]
            HZE->HZE_APINEG := oMonitor["apiNegocio"]
            HZE->HZE_TIPO   := oMonitor["opcoesTipo"]
            HZE->HZE_TIPOGR := oMonitor["opcoesSubtipo"]
            HZE->HZE_RASCUN := IIF(oMonitor["rascunho"],"S","N")
            //HZE->HZE_TPPD   := oMonitor["tipo"]
            //HZE->HZE_TPGRPD := oMonitor["subtipo"]
            //HZE->HZE_VERSAO := "0000000001"
        MsUnlock()
        HZE->(dbCloseArea())
        lRet := .T.
    EndIf
Return lRet

/*/{Protheus.doc} POST MONITOR api/pcp/v1/pcpmonitorapi/monitor
Inclui um Monitor Customizado
@type WSMETHOD
@author renan.roeder
@since 15/09/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST MONITOR WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0249)) //"Parâmetros inválidos para inclusão do Monitor"
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence
                lRet := incluiMoni(@oBody)
            Recover
                lRet := .F.
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody,STR0051)) //"Monitor exclusivo incluído com sucesso!"
        Else
            SetRestFault(400,EncodeUTF8(STR0250)) //"Ocorreram erros na inclusão do Monitor. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} incluiMoni
Inclui um Monitor Customizado
@type Static Function
@author renan.roeder
@since 14/09/2023
@version P12.1.2310
@param  oMonitor , objeto json, Objeto Json com os dados do Monitor que devem ser gravados
@return lRet     , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function incluiMoni(oMonitor)
    Local lRet   := .T.
    Local oCarga := PCPMonitorCarga():New(.T.)

    oCarga:setaTitulo(oMonitor["titulo"])
    oCarga:setaObjetivo(oMonitor["objetivo"])
    oCarga:setaAgrupador(oMonitor["agrupador"])
    oCarga:setaFuncaoNegocio(oMonitor["apiNegocio"])
    oCarga:setaTiposPermitidos(oMonitor["opcoesTipo"])
    oCarga:setaTiposGraficoPermitidos(oMonitor["opcoesSubtipo"])
    oCarga:setaTipoDetalhe("detalhe")
    oCarga:setaProprietarioMonitor(RetCodUsr())
    oCarga:setaRascunhoMonitor(oMonitor["rascunho"])
    oCarga:persisteCadastroMonitor()
    oMonitor["codMonitor"] := oCarga:recuperaCodigoMonitor()
    oCarga:destroy()
Return lRet

/*/{Protheus.doc} POST PROPRIEDADE api/pcp/v1/pcpmonitorapi/monitor/propriedade
Inclui uma propriedade do Monitor Customizado
@type WSMETHOD
@author renan.roeder
@since 15/09/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST PROPRIEDADE WSSERVICE PCPMonitorAPI
    Local aResult    := {.T.,"",200}
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        aResult[1] := .F.
        aResult[2] := STR0251 //"Parâmetros inválidos para inclusão da propriedade do Monitor"
    EndIf
    If aResult[1]
        Begin Transaction
            Begin Sequence
                aResult := incluiProp(oBody)
            Recover
                aResult[1] := .F.
                aResult[2] := STR0252 //"Ocorreram erros na inclusão da propriedade do Monitor. Contate o administrador do sistema."
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
    EndIf
    If aResult[1]
        ::SetResponse(PCPMMsgSuc(oBody))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUTF8(aResult[2]))
    EndIf
    FreeObj(oBody)
    FwFreeArray(aResult)
Return lRet

/*/{Protheus.doc} incluiProp
Inclui uma propriedade no Monitor Customizado
@type Static Function
@author renan.roeder
@since 14/09/2023
@version P12.1.2310
@param  oPropri , objeto json, Objeto Json com os dados da propriedade a ser gravada
@return lRet     , logico    , Informa se o processo foi executado com sucesso
/*/
Static Function incluiProp(oPropri)
    Local aResult  := {.T.,"",200}
    Local oCarga   := PCPMonitorCarga():New(.T.)
    Local oEstilos := JsonObject():New()
    Local oPrmAdc  := JsonObject():New()

    If oPropri:HasProperty("estilos")
        oEstilos:FromJson(oPropri["estilos"])
    EndIf
    oCarga:setaCodigoMonitor(oPropri["codMonitor"])
    If oPropri["tipo"] == 8
        If oPropri:HasProperty("parametrosServico")
            If !oPropri["parametrosServico"]:HasProperty("tabela") .Or.;
                Empty(oPropri["parametrosServico"]["tabela"]) .Or.;
                (!oPropri["tabelaGenerica"] .And. !AliasInDic(oPropri["parametrosServico"]["tabela"])) .Or.;
                (oPropri["tabelaGenerica"] .And. Len(FwGetSx5("00",oPropri["parametrosServico"]["tabela"])) <= 0)
                aResult[1] := .F.
                aResult[2] := STR0271 //"Necessário informar uma tabela válida para filtro do tipo Lookup."
            Else
                If !oPropri["tabelaGenerica"]
                    If !oPropri["parametrosServico"]:HasProperty("campoCodigo") .Or. Empty(oPropri["parametrosServico"]["campoCodigo"]) .Or. Empty(GetSX3Cache(oPropri["parametrosServico"]["campoCodigo"], "X3_CAMPO"))
                        aResult[1] := .F.
                        aResult[2] := STR0272 //"Necessário informar o campo de código da tabela válido para filtro do tipo Lookup."
                    Else
                        If !oPropri["parametrosServico"]:HasProperty("campoDescricao") .Or. Empty(oPropri["parametrosServico"]["campoDescricao"]) .Or. Empty(GetSX3Cache(oPropri["parametrosServico"]["campoDescricao"], "X3_CAMPO"))
                            aResult[1] := .F.
                            aResult[2] := STR0273 //"Necessário informar o campo de descrição da tabela válido para filtro do tipo Lookup."
                        EndIf
                    EndIf
                EndIf
            EndIf
        Else
            aResult[1] := .F.
            aResult[2] := STR0270 //"Necessário informar os campos de tabela, campo código e campo descrição para filtro do tipo Lookup."
        EndIf
        If aResult[1]
            If !oPropri["tabelaGenerica"]
                oCarga:setaPropriedadeLookupTabela(oPropri["codPropriedade"],;
                                                oPropri["titulo"],;
                                                oPropri["selecaoMultipla"],;
                                                oPropri["parametrosServico"]["tabela"],;
                                                oPropri["parametrosServico"]["campoCodigo"],;
                                                oPropri["parametrosServico"]["campoDescricao"],;
                                                IIF(oPropri:HasProperty("classes"),oPropri["classes"],""),;
                                                oEstilos)
            Else
                oCarga:setaPropriedadeLookupTabelaGenerica(oPropri["codPropriedade"],;
                                                        oPropri["titulo"],;
                                                        oPropri["selecaoMultipla"],;
                                                        oPropri["parametrosServico"]["tabela"],;
                                                        IIF(oPropri:HasProperty("classes"),oPropri["classes"],""),;
                                                        oEstilos)
            EndIf
            oCarga:persisteCadastroPropriedadesMonitor(oPropri["codMonitor"])
        EndIf
    Else
        If oPropri["tipo"] == 4 .Or. oPropri["tipo"] == 5
            oPrmAdc["opcoes"] := oPropri["opcoes"]
            If oPropri["tipo"] == 5
                oPropri["valorPadrao"] := ArrTokStr(oPropri["valorPadrao"],",")
            EndIf
        EndIf
        oCarga:setaPropriedade(oPropri["codPropriedade"],;
                               IIF(cValToChar(oPropri["tipo"]) $ "|1|2|4|5|",oPropri["valorPadrao"],""),;
                               oPropri["titulo"],;
                               oPropri["tipo"],;
                               IIF(oPropri["tipo"] == 1,oPropri["tamanhoTexto"],IIF(oPropri["tipo"] == 2,oPropri["tamanhoNumerico"],0)),;
                               IIF(oPropri["tipo"] == 2,oPropri["tamanhoDecimal"],0),;
                               IIF(oPropri:HasProperty("classes"),oPropri["classes"],""),;
                               oEstilos,;
                               IIF(cValToChar(oPropri["tipo"]) $ "|1|2|",oPropri["icone"],""),;
                               oPrmAdc)
        oCarga:persisteCadastroPropriedadesMonitor(oPropri["codMonitor"])
    EndIf
    oCarga:destroy()
    FreeObj(oEstilos)
    FreeObj(oPrmAdc)
Return aResult

/*/{Protheus.doc} PUT PROPRIEDADE api/pcp/v1/pcpmonitorapi/monitor/{codPropriedade}/{codMonitor}
Altera informações da propriedade do Monitor Customizado
@type WSMETHOD
@author renan.roeder
@since 13/09/2023
@version P12.1.2310
@param  codPropriedade, caracter, Codigo da Propriedade
@param	codMonitor    , caracter, Codigo do Monitor
@return lRet          , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD PUT PROPRIEDADE PATHPARAM codPropriedade,codMonitor WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local lRet       := .F.
    Local cBody      := ::GetContent()
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0253)) //"Parâmetros inválidos para edição das propriedades do Monitor da Visão."
    EndIf
    Begin Transaction
        Begin Sequence
            lRet := editaPropr(oBody)
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBloc)
    If lRet
        ::SetResponse(PCPMMsgSuc(oBody))
    Else
        SetRestFault(400,EncodeUTF8(STR0254)) //"Ocorreram erros na alteração da propriedade do Monitor. Contate o administrador do sistema."
    EndIf
	FreeObj(oBody)
Return lRet

/*/{Protheus.doc} editaPropr
Edita informações da propriedade no Monitor Customizado
@type Static Function
@author renan.roeder
@since 14/09/2023
@version P12.1.2310
@param  oPropri , objeto json, Objeto Json com os dados da propriedade a ser gravada
@return lRet     , logico    , Informa se o processo foi executado com sucesso
/*/
Static Function editaPropr(oPropri)
    Local lRet     := .F.
    Local oEstilos := JsonObject():New()
    Local oPrmAdc  := JsonObject():New()
   
    HZF->(dbSetOrder(1))
    If HZF->(dbSeek(xFilial("HZF")+oPropri["codMonitor"]+oPropri["codPropriedade"]))
        lRet := .T.
        RecLock("HZF", .F.)
            oEstilos:FromJson(oPropri["estilos"])
            If cValToChar(oPropri["tipo"]) $ "|1|2|4|5|"
                HZF->HZF_VALPAD := IIF(oPropri["tipo"] == 5, ArrTokStr(oPropri["valorPadrao"],","), oPropri["valorPadrao"])
                If oPropri["tipo"] == 1
                    HZF->HZF_TAMTXT := oPropri["tamanhoTexto"]
                    HZF->HZF_ICNCMP := oPropri["icone"]
                EndIf
                If oPropri["tipo"] == 2
                    HZF->HZF_TAMNUM := oPropri["tamanhoNumerico"]
                    HZF->HZF_TAMDEC := oPropri["tamanhoDecimal"]
                    HZF->HZF_ICNCMP := oPropri["icone"]
                EndIf
                If oPropri["tipo"] == 4 .Or. oPropri["tipo"] == 5
                    oPrmAdc:FromJson(HZF->HZF_PRMADC)
                    oPrmAdc["opcoes"] := oPropri["opcoes"]
                    HZF->HZF_PRMADC := oPrmAdc:ToJson()
                EndIf
            EndIf
            If oPropri["tipo"] == 8
                oPrmAdc:FromJson(HZF->HZF_PRMADC)
                oPrmAdc["parametrosServico"]["tabela"]         := oPropri["parametrosServico"]["tabela"]
                If !oPropri["tabelaGenerica"]
                    oPrmAdc["parametrosServico"]["campoCodigo"]    := oPropri["parametrosServico"]["campoCodigo"]
                    oPrmAdc["parametrosServico"]["campoDescricao"] := oPropri["parametrosServico"]["campoDescricao"]
                EndIf
                oPrmAdc["selecaoMultipla"]                     := oPropri["selecaoMultipla"]
                oPrmAdc["tabelaGenerica"]                      := oPropri["tabelaGenerica"]
                HZF->HZF_PRMADC := oPrmAdc:ToJson()
            EndIf
            HZF->HZF_TITULO := oPropri["titulo"]
            HZF->HZF_TIPO   := oPropri["tipo"]
            HZF->HZF_CLSCMP := oPropri["classes"]
            HZF->HZF_ESTCMP := oEstilos:ToJson()
        MsUnlock()
        HZF->(dbCloseArea())
    EndIf
    FreeObj(oEstilos)
    FreeObj(oPrmAdc)
Return lRet

/*/{Protheus.doc} DELETE PROPRIEDADE api/pcp/v1/pcpmonitorapi/monitor/propriedade/{codPropriedade}/{codMonitor}
Exclui uma propriedade do Monitor Customizado
@type WSMETHOD
@author renan.roeder
@since 18/09/2023
@version P12.1.2410
@param	codPropriedade, caracter, Codigo da Propriedade
@param  codMonitor    , caracter, Codigo do Monitor
@return lRet          , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD DELETE PROPRIEDADE PATHPARAM codPropriedade,codMonitor WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local lRet       := .T.

    ::SetContentType("application/json")
    Begin Transaction
        Begin Sequence
            lRet := excluiProp(::codPropriedade,::codMonitor)
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBloc)
    If lRet
        ::SetResponse(PCPMMsgSuc())
    Else
        SetRestFault(400,EncodeUTF8(STR0255)) //"Ocorreram erros na exclusão da propriedade do Monitor. Contate o administrador do sistema."
    EndIf
Return lRet

/*/{Protheus.doc} excluiProp
Exclui uma propriedade do Monitor Customizado
@type Static Function
@author renan.roeder
@since 18/09/2023
@version P12.1.2410
@param	cCodPropr, caracter, Codigo da Propriedade
@param  cCodMonit, caracter, Codigo do Monitor
@return lRet     , logico  , Informa se o processo foi executado com sucesso
/*/
Static Function excluiProp(cCodPropr,cCodMonit)
    Local lRet := .F.

    HZF->(dbSetOrder(1))
    If HZF->(dbSeek(xFilial("HZF")+cCodMonit+cCodPropr))
        lRet := .T.
        RecLock("HZF",.F.)
        HZF->(dbDelete())
        HZF->(MsUnlock())
    EndIf
    HZF->(dbCloseArea())
Return lRet

/*/{Protheus.doc} POST PROP_REORDER api/pcp/v1/pcpmonitorapi/monitor/propriedade/reorder
Ordena as propriedades do Monitor Customizado
@type WSMETHOD
@author renan.roeder
@since 22/09/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST PROP_REORDER WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0256)) //"Parâmetros inválidos para ordenação das propriedades do Monitor"
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence
                lRet := ordenaProp(oBody)
            Recover
                lRet := .F.
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc())
        Else
            SetRestFault(400,EncodeUTF8(STR0257)) //"Ocorreram erros na ordenação das propriedades do Monitor. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} ordenaProp
Exclui uma propriedade do Monitor Customizado
@type Static Function
@author renan.roeder
@since 18/09/2023
@version P12.1.2410
@param  oPropri, objeto json, Objeto Json com os dados da propriedade a ser ordenada
@return lRet   , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function ordenaProp(oPropri)
    Local lRet     := .F.
    Local nIndice  := 0
    
    For nIndice := 1 To Len(oPropri)
        HZF->(dbSetOrder(1))
        If HZF->(dbSeek(xFilial("HZF")+oPropri[nIndice]["codMonitor"]+oPropri[nIndice]["codPropriedade"]))
            lRet := .T.
            RecLock("HZF",.F.)
            HZF->HZF_POSIC := nIndice * 10
            HZF->(MsUnlock())
        EndIf
        HZF->(dbCloseArea())
        If !lRet
            DisarmTransaction()
            Exit
        EndIf
    Next nIndice
Return lRet

/*/{Protheus.doc} atrbPrJson
Atribui ao objeto json as propriedades adicionais gravadas no banco como string json
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	oJsonDest, json object, Objeto json que receberá as propriedades adicionais
@param  cJsonOrig, caracter   , String json com as propriedades adicionais
@return Nil
/*/
Static Function atrbPrJson(oJsonDest,cJsonOrig)
    Local aNames     := {}
    Local cError     := ""
    Local nIndice    := 0
    Local oJsonParam := JsonObject():New()

    cError := oJsonParam:FromJson(cJsonOrig)
    If cError == Nil
        aNames := oJsonParam:GetNames()
        For nIndice := 1 To Len (aNames)
            oJsonDest[aNames[nIndice]] := oJsonParam[aNames[nIndice]]
        Next nIndice
    EndIf
    FwFreeArray(aNames)
    FreeObj(oJsonParam)
Return

/*/{Protheus.doc} PUT PUT_VISMONIT api/pcp/v1/pcpmonitorapi/visaoMonitor/{codVisao}/{codMonitor}/{sequencia}
Edita as propriedades de um Monitor da Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	codVisao  , numerico, Codigo da Visão
@param	codMonitor, caracter, Codigo do Monitor
@param	sequencia , numerico, Sequencia do Monitor na Visão
@return lRet      , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD PUT PUT_VISMONIT PATHPARAM codVisao,codMonitor,sequencia WSSERVICE PCPMonitorAPI
    Local aRetValPr  := {}
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0031)) //"Parâmetros inválidos para edição das propriedades do Monitor da Visão."
    EndIf
    aRetValPr := valPropr(oBody,.T.)
    If !aRetValPr[1]
        lRet := .F.
        SetRestFault(400,EncodeUTF8(aRetValPr[2]))
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence
                lRet := editaVisMt(::codVisao,::codMonitor,::sequencia,oBody)
            Recover
                lRet := .F.
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody))
        Else
            SetRestFault(400,STR0033) //"Ocorreram erros na edição das propriedades do Monitor da Visão. Contate o administrador do sistema."
        EndIf
    EndIf
    FwFreeArray(aRetValPr)
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} editaVisMt
Edita as propriedades de um Monitor da Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	nCodVisao , numerico   , Codigo da Visão
@param	cCodMonit , caracter   , Codigo do Monitor
@param	nSequencia, numerico   , Sequencia do Monitor na Visão
@param	oVisaoMt  , objeto Json, Objeto Json com os dados do Monitor da Visão
@return lRet      , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function editaVisMt(nCodVisao, cCodMonit, nSequencia, oVisaoMt)
    Local lRet    := .F.
    Local nIndice := 0

    HZC->(dbSetOrder(1))
    If HZC->(dbSeek(xFilial("HZC")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])+cCodMonit+STR(nSequencia,saTamSeque[1],saTamSeque[2])))
        If oVisaoMt:HasProperty("atualizaAutomatico") .And. Empty(oVisaoMt["atualizaAutomatico"])
            oVisaoMt["tempoAtualizacao"] := 0
        EndIf
        RecLock("HZC",.F.)
        HZC->HZC_TITULO := oVisaoMt["titulo"]
        HZC->HZC_TAMAN  := oVisaoMt["tamanho"]
        HZC->HZC_POSIC  := oVisaoMt["posicao"]
        HZC->HZC_TIPO   := oVisaoMt["tipo"]
        HZC->HZC_TIPOGR := oVisaoMt["subtipo"]
        HZC->HZC_ATUAUT := IIF(oVisaoMt["tempoAtualizacao"] > 0, "S", "N")
        HZC->HZC_TMPATU := oVisaoMt["tempoAtualizacao"]
        HZC->(MsUnlock())
        HZC->(dbCloseArea())
        
        HZD->(dbSetOrder(1))
        If HZD->(dbSeek(xFilial("HZD")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])+cCodMonit+STR(nSequencia,saTamSeque[1],saTamSeque[2])))
            lRet := .T.
            While HZD->(!Eof()) .And. HZD->(HZD_FILIAL+STR(HZD_VISAO,saTamVisao[1],saTamVisao[2])+HZD_MONIT+STR(HZD_SEQUEN,saTamSeque[1],saTamSeque[2])) == xFilial("HZD")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])+cCodMonit+STR(nSequencia,saTamSeque[1],saTamSeque[2])
                nIndice := aScan(oVisaoMt["propriedades"], {|x| Alltrim(x["codPropriedade"]) == AllTrim(HZD->HZD_PROP)})
                If nIndice > 0
                    RecLock("HZD", .F.)
                    HZD->HZD_PROPVL := fmtVlPrGrv(oVisaoMt["propriedades"][nIndice]["tipo"],oVisaoMt["propriedades"][nIndice]["valorPropriedade"])
                    HZD->(MsUnlock())
                EndIf
                HZD->(dbSkip())
            End
            HZD->(dbCloseArea())
        Else
            DisarmTransaction()
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} POST DATA api/pcp/v1/pcpmonitorapi/monitor/monitorDataSchema
Retorna os dados de um Monitor da Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST DATA WSSERVICE PCPMonitorAPI
    Local aRetValPr  := {}
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()
    Local oJsonRet   := JsonObject():New()

	::SetContentType("application/json")
	If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0034)) //"Parâmetros inválidos para a busca dos dados da Visão."
    EndIf
    lRet := valAccess(oBody["apiNegocio"])
    If !lRet
        SetRestFault(400,EncodeUTF8(STR0037)) //"Acesso não permitido ao Monitor. Contate o administrador do sistema."
    EndIf
    If lRet
        aRetValPr := valPropr(oBody)
        If !aRetValPr[1]
            lRet := .F.
            SetRestFault(400,EncodeUTF8(aRetValPr[2]))
        EndIf
    EndIf
    If lRet        
        If buscaDados(oBody,oJsonRet)
            ::SetResponse(EncodeUTF8(oJsonRet:ToJson()))
        EndIf
    EndIf
    FwFreeArray(aRetValPr)
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} buscaDados
Retorna os dados de um Monitor da Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	oBody     , objeto Json, Objeto Json com o body da requisição
@param	oJsonRet  , objeto Json, Objeto Json passado como referência para retorno dos dados
@return lRet      , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function buscaDados(oBody,oJsonRet)
    Local cFunc   := AllTrim(oBody["apiNegocio"])
    Local lRet    := .T.
    Local nIndice := 0
    Local oFiltro := JsonObject():New()

    For nIndice := 1 To Len(oBody["propriedades"])
        oFiltro[oBody["propriedades"][nIndice]["codPropriedade"]] := oBody["propriedades"][nIndice]["valorPropriedade"]
    Next nIndice
    cFunc := cFunc + "():BuscaDados(oFiltro,oBody['tipo'],oBody['subtipo'])"
    oJsonRet:FromJson(&(cFunc))

    //Ponto de entrada utilizado para alterar caracteristicas dos monitores
	If ExistBlock("PBData")
		ExecBlock("PBData",.F.,.F., {oBody["codVisao"], oBody["codMonitor"], oBody["sequencia"], oJsonRet})
	EndIf

    FREEOBJ(oFiltro)
Return lRet

/*/{Protheus.doc} GET MODULO api/pcp/v1/pcpmonitorapi/monitor/modulos
Retorna os Modulos que irão agrupar os Monitores
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET MODULO WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    ::SetContentType("application/json")
    aReturn := buscaModul()
	lRet    := aReturn[1]
	If lRet
		::SetResponse(aReturn[2])
	EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} buscaModul
Retorna os Modulos que irão agrupar os Monitores
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return aResult  , array   , Array preparado com o retorno da requisição
/*/
Static Function buscaModul()
    Local aResult   := {.T.,"",200}
    Local cAlias    := GetNextAlias()
    Local cQuery    := ""
    Local nPos      := 0
    Local oJson     := JsonObject():New()

    cQuery := " SELECT HZE.HZE_AGRUP "
    cQuery += " FROM " + RetSqlName("HZE") + " HZE "
    cQuery += " WHERE HZE.HZE_FILIAL = '"+xFilial("HZE")+"' "
    cQuery += "   AND HZE.D_E_L_E_T_ = ' ' "
    DbSelectArea("HZE")
    If HZE->(FieldPos("HZE_USUAR")) > 0
        cQuery += "   AND (HZE.HZE_PADRAO = 'S' OR (HZE.HZE_PADRAO = 'N' AND (HZE.HZE_RASCUN = 'N' OR (HZE.HZE_RASCUN = 'S' AND HZE.HZE_USUAR = '" + RetCodUsr() + "')))) "    
    EndIf
    cQuery += " GROUP BY HZE.HZE_AGRUP "
    cQuery += " ORDER BY HZE.HZE_AGRUP"
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    oJson["hasNext"] := .F.
    oJson["items"] := {}
    While (cAlias)->(!Eof())
        aAdd(oJson["items"], JsonObject():New())
        nPos++
        oJson["items"][nPos]["agrupador"] := AllTrim((cAlias)->HZE_AGRUP)
        (cAlias)->(dbSkip())
	End    
	(cAlias)->(dbCloseArea())
    aResult[2] := EncodeUTF8(oJson:ToJson())
    aSize(oJson["items"],0)
	FreeObj(oJson)
Return aResult

/*/{Protheus.doc} GET GET_VISMONIT api/pcp/v1/pcpmonitorapi/visaoMonitor
Retorna os Monitores da Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	codVisao  , numerico, Codigo da Visão
@param	expand    , caracter, Se expande o conteúdo das proprieadades do Monitor
@param	order     , caracter, Nome da propriedade pela qual a consulta deve ser ordenada
@param	codMonitor, caracter, Codigo do Monitor
@return lRet      , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET GET_VISMONIT WSRECEIVE codVisao, expand, order, codMonitor WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    Default ::expand := "", ::order := "HZC_POSIC"

    ::SetContentType("application/json")
    aReturn := buscaMtVis(::codVisao,::expand, ::order, ::codMonitor)
	lRet    := aReturn[1]
	If lRet
		::SetResponse(aReturn[2])
	EndIf
	FwFreeArray(aReturn)    
Return lRet

/*/{Protheus.doc} buscaMtVis
Retorna os Monitores da Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	nCodVisao, numerico, Codigo da Visão
@param	cExpand  , caracter, Se expande o conteúdo das proprieadades do Monitor
@param	cOrder   , caracter, Nome da propriedade pela qual a consulta deve ser ordenada
@param	cCodMonit, caracter, Codigo do Monitor
@return aResult  , array   , Array preparado com o retorno da requisição
/*/
Static Function buscaMtVis(nCodVisao,cExpand,cOrder,cCodMonit)
    Local aResult   := {.T.,"",200}
    Local cAlias    := GetNextAlias()
    Local cCondic   := ""
    Local nPos      := 0
    Local oJson     := JsonObject():New()


    cCondic += "%"
    If !Empty(cCodMonit)
        cCondic += " HZE.HZE_CODIGO = '" + cCodMonit + "' "
    Else
        cCondic += " HZC.HZC_VISAO = '" + cValToChar(nCodVisao) + "' "
    EndIf
    cCondic += "%"

    BeginSql Alias cAlias
        SELECT
        HZC.HZC_VISAO,HZC.HZC_MONIT,HZC.HZC_SEQUEN,HZC.HZC_TITULO,HZC.HZC_TAMAN,
        HZC.HZC_POSIC,HZC.HZC_TIPO,HZC.HZC_TIPOGR,HZC.HZC_ATUAUT,HZC.HZC_TMPATU,
        HZE.HZE_CODIGO,HZE.HZE_AGRUP,HZE.HZE_APINEG,HZE.HZE_TIPO,HZE.HZE_TIPOGR,HZE.HZE_PADRAO,HZE.HZE_TPDETL,
        HZE.HZE_OBJTV,HZE.HZE_EXJSON
        FROM %table:HZC% HZC
        INNER JOIN %table:HZE% HZE ON HZE.HZE_FILIAL = %xFilial:HZE% AND HZE.HZE_CODIGO = HZC.HZC_MONIT AND HZE.%NotDel%
        WHERE HZC.HZC_FILIAL = %xFilial:HZC%
        AND %Exp:cCondic%
        AND HZC.%NotDel%
        ORDER BY HZC.HZC_POSIC
    EndSql
    oJson["hasNext"] := .F.
    oJson["items"] := {}
    While (cAlias)->(!Eof())
        aAdd(oJson["items"], JsonObject():New())
        nPos++
        oJson["items"][nPos]["codVisao"]           := (cAlias)->HZC_VISAO
        oJson["items"][nPos]["sequencia"]          := (cAlias)->HZC_SEQUEN
        oJson["items"][nPos]["titulo"]             := AllTrim((cAlias)->HZC_TITULO)
        oJson["items"][nPos]["tamanho"]            := (cAlias)->HZC_TAMAN
        oJson["items"][nPos]["posicao"]            := (cAlias)->HZC_POSIC
        oJson["items"][nPos]["tipo"]               := AllTrim((cAlias)->HZC_TIPO)
        oJson["items"][nPos]["subtipo"]            := AllTrim((cAlias)->HZC_TIPOGR)
        oJson["items"][nPos]["atualizaAutomatico"] := IIF((cAlias)->HZC_ATUAUT == "S",.T.,.F.)
        oJson["items"][nPos]["tempoAtualizacao"]   := (cAlias)->HZC_TMPATU
        oJson["items"][nPos]["codMonitor"]         := AllTrim((cAlias)->HZE_CODIGO)
        oJson["items"][nPos]["objetivo"]           := AllTrim((cAlias)->HZE_OBJTV)
        oJson["items"][nPos]["agrupador"]          := AllTrim((cAlias)->HZE_AGRUP)
        oJson["items"][nPos]["apiNegocio"]         := AllTrim((cAlias)->HZE_APINEG)
        oJson["items"][nPos]["logPadrao"]          := IIF((cAlias)->HZE_PADRAO == "S",.T.,.F.)
        oJson["items"][nPos]["opcoesTipo"]         := AllTrim((cAlias)->HZE_TIPO)
        oJson["items"][nPos]["opcoesSubtipo"]      := AllTrim((cAlias)->HZE_TIPOGR)
        oJson["items"][nPos]["exemploJSON"]        := AllTrim((cAlias)->HZE_EXJSON)
        oJson["items"][nPos]["tipoDetalhe"]        := AllTrim((cAlias)->HZE_TPDETL)

        If cExpand == "propriedades"
            buscaMtVPr(@oJson["items"][nPos],(cAlias)->HZC_VISAO,(cAlias)->HZC_MONIT,(cAlias)->HZC_SEQUEN)
        EndIf
        (cAlias)->(dbSkip())
	End    
	(cAlias)->(dbCloseArea())
    aResult[2] := EncodeUTF8(oJson:ToJson())
    aSize(oJson["items"],0)
	FreeObj(oJson)
Return aResult

/*/{Protheus.doc} buscaMtVPr
Retorna as propriedades do Monitor da Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	oJson    , objeto Json, Objeto Json passado como referência que retornará os dados da requisição
@param	nCodVisao, numerico   , Codigo da Visão
@param	cCodMonit, caracter   , Codigo do Monitor
@param	nSequen  , numerico   , Sequencia do Monitor
@return Nil
/*/
Static Function buscaMtVPr(oJson,nCodVisao,cCodMonit,nSequen)
    Local cAlias := GetNextAlias()
    Local cOrder := "HZF.HZF_FILIAL,HZF.HZF_MONIT,HZF.HZF_CODIGO"
    Local nPos   := 0

    DbSelectArea("HZF")
    If HZF->(FieldPos("HZF_POSIC")) > 0
        cOrder := "HZF.HZF_FILIAL,HZF.HZF_MONIT,HZF.HZF_POSIC,HZF.HZF_CODIGO"
    EndIf
    cOrder  := "%" + cOrder  + "%"
    BeginSql Alias cAlias
        SELECT
          HZD.HZD_VISAO,HZD.HZD_MONIT,HZD.HZD_SEQUEN,HZD.HZD_PROP,
          HZF.HZF_CODIGO,HZF.HZF_MONIT,HZF.HZF_VALPAD,HZF.HZF_TITULO,HZF.HZF_TIPO,HZF.HZF_TAMTXT,
          HZF.HZF_TAMNUM,HZF.HZF_TAMDEC,HZF.HZF_CLSCMP,HZF.HZF_ESTCMP,HZF.HZF_ICNCMP,
          HZD.HZD_PROPVL,HZF.HZF_PRMADC
        FROM %table:HZD% HZD
        INNER JOIN %table:HZF% HZF ON HZF.HZF_FILIAL = %xFilial:HZF% AND HZF.HZF_CODIGO = HZD.HZD_PROP AND HZF.HZF_MONIT = HZD.HZD_MONIT AND HZF.%NotDel%
        WHERE HZD.HZD_FILIAL = %xFilial:HZD%
          AND HZD.HZD_VISAO  = %Exp:nCodVisao%
          AND HZD.HZD_MONIT  = %Exp:cCodMonit%
          AND HZD.HZD_SEQUEN  = %Exp:nSequen%
          AND HZD.%NotDel%
        ORDER BY %Exp:cOrder%
    EndSql
    oJson["propriedades"] := {}
    While (cAlias)->(!Eof())        
        aAdd(oJson["propriedades"], JsonObject():New())
        nPos++
        oJson["propriedades"][nPos]["codPropriedade"]    := AllTrim((cAlias)->HZF_CODIGO)
        oJson["propriedades"][nPos]["codMonitor"]        := AllTrim((cAlias)->HZF_MONIT)
        oJson["propriedades"][nPos]["valorPadrao"]       := AllTrim((cAlias)->HZF_VALPAD)
        oJson["propriedades"][nPos]["titulo"]            := AllTrim((cAlias)->HZF_TITULO)
        oJson["propriedades"][nPos]["tipo"]              := (cAlias)->HZF_TIPO
        oJson["propriedades"][nPos]["tamanhoTexto"]      := (cAlias)->HZF_TAMTXT
        oJson["propriedades"][nPos]["tamanhoNumerico"]   := (cAlias)->HZF_TAMNUM
        oJson["propriedades"][nPos]["tamanhoDecimal"]    := (cAlias)->HZF_TAMDEC
        oJson["propriedades"][nPos]["classes"]           := AllTrim((cAlias)->HZF_CLSCMP)
        oJson["propriedades"][nPos]["estilos"]           := AllTrim((cAlias)->HZF_ESTCMP)
        oJson["propriedades"][nPos]["icone"]             := AllTrim((cAlias)->HZF_ICNCMP)
        atrbPrJson(oJson["propriedades"][nPos],(cAlias)->HZF_PRMADC)
        oJson["propriedades"][nPos]["valorPropriedade"]  := fmtVlPrRet(oJson["propriedades"][nPos],(cAlias)->HZD_PROPVL)
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())
Return

Static Function fmtVlPrRet(oJson,xValor)
    xValor := AllTrim(xValor)
    If oJson["tipo"] == 5 .Or.; 
       oJson["tipo"] == 6 .Or.;
      (oJson["tipo"] == 8 .And. (oJson:HasProperty("selecaoMultipla") .And. oJson["selecaoMultipla"]))
        xValor := StrTokArr(xValor,",")
    EndIf
Return xValor

/*/{Protheus.doc} DELETE VISAOID api/pcp/v1/pcpmonitorapi/visao/{codVisao}
Exclui uma Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	codVisao, numerico, Codigo da Visão
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD DELETE VISAOID PATHPARAM codVisao WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local lRet       := .T.
    Local oJson      := JsonObject():New()

    ::SetContentType("application/json")
    Begin Transaction
        Begin Sequence
            lRet := excluiVisao(::codVisao, @oJson)
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBloc)
    If lRet
        ::SetResponse(PCPMMsgSuc(oJson))
    Else
        SetRestFault(400,EncodeUTF8(STR0011)) //"Ocorreram erros na exclusão da Visão. Contate o administrador do sistema."
    EndIf
	FreeObj(oJson)
Return lRet

/*/{Protheus.doc} excluiVisao
Exclui uma Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	nCodVisao, numerico   , Codigo da Visão
@param	oJson    , objeto Json, Objeto Json passado como referência que retornará os dados da requisição
@return lRet     , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function excluiVisao(nCodVisao, oJson)
    Local lRet := .F.

    HZB->(dbSetOrder(1))
    If HZB->(dbSeek(xFilial("HZB")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])))
        lRet := .T.
        oJson["codVisao"]        := HZB->HZB_CODIGO
        oJson["codUsuario"]      := UsrRetName(HZB->HZB_USUAR)
        oJson["titulo"]          := AllTrim(HZB->HZB_TITULO)
        oJson["tituloAbreviado"] := AllTrim(HZB->HZB_TITABR)
        oJson["icone"]           := AllTrim(HZB->HZB_ICONE)
        oJson["posicao"]         := HZB->HZB_POSIC
        oJson["agrupador"]       := AllTrim(HZB->HZB_AGRUP)
        RecLock("HZB",.F.)
        HZB->(dbDelete())
        HZB->(MsUnlock())
    EndIf
    HZB->(dbCloseArea())
    If lRet
        HZC->(dbSetOrder(1))
        If HZC->(dbSeek(xFilial("HZC")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])))
            While HZC->(!Eof()) .And. HZC->(HZC_FILIAL+STR(HZC_VISAO,saTamVisao[1],saTamVisao[2])) == xFilial("HZC")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])
                RecLock("HZC",.F.)
                HZC->(dbDelete())
                HZC->(MsUnlock())
                HZC->(dbSkip())
            End
            HZC->(dbCloseArea())
            
            HZD->(dbSetOrder(1))
            If HZD->(dbSeek(xFilial("HZD")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])))
                While HZD->(!Eof()) .And. HZD->(HZD_FILIAL+STR(HZD_VISAO,saTamVisao[1],saTamVisao[2])) == xFilial("HZD")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])
                    RecLock("HZD",.F.)
                    HZD->(dbDelete())
                    HZD->(MsUnlock())
                    HZD->(dbSkip())
                End
                HZD->(dbCloseArea())
            Else
                lRet := .F.
                DisarmTransaction()
            EndIf
        EndIf
        If lRet
            HZG->(dbSetOrder(1))
            If HZG->(dbSeek(xFilial("HZG")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])))
                While HZG->(!Eof()) .And. HZG->(HZG_FILIAL+STR(HZG_VISAO,saTamVisao[1],saTamVisao[2])) == xFilial("HZG")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])
                    RecLock("HZG",.F.)
                    HZG->(dbDelete())
                    HZG->(MsUnlock())
                    HZG->(dbSkip())
                End
                HZG->(dbCloseArea())             
            EndIf        
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} PUT VISAOID api/pcp/v1/pcpmonitorapi/visao/{codVisao}
Altera uma Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	codVisao, numerico, Codigo da Visão
@return lRet    , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD PUT VISAOID PATHPARAM codVisao WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

	::SetContentType("application/json")
	If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0003)) //"Parâmetros inválidos para edição da visão."
    EndIf
    If lRet
        Begin Sequence
            lRet := editaVisao(::codVisao, oBody)        
        Recover
            lRet := .F.
        End Sequence
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody))
        Else
            SetRestFault(400,EncodeUTF8(STR0012)) //"Ocorreram erros na edição da Visão. Contate o administrador do sistema."
        EndIf
    EndIf
	FreeObj(oBody)
Return lRet

/*/{Protheus.doc} editaVisao
Altera uma Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	nCodVisao, numerico   , Codigo da Visão
@param	oVisao   , objeto Json, Objeto Json com o body da requisição
@return lRet     , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function editaVisao(nCodVisao, oVisao)
    Local lRet := .F.
    
    HZB->(dbSetOrder(1))
    If HZB->(dbSeek(xFilial("HZB")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])))
        lRet := .T.
        RecLock("HZB",.F.)
        HZB->HZB_TITULO := AllTrim(oVisao["titulo"])
        HZB->HZB_TITABR := AllTrim(oVisao["tituloAbreviado"])
        HZB->HZB_ICONE	:= oVisao["icone"] 
        HZB->HZB_POSIC	:= oVisao["posicao"]
        HZB->HZB_AGRUP	:= AllTrim(oVisao["agrupador"])
        HZB->(MsUnlock())
    EndIf
    HZB->(dbCloseArea())
Return lRet

/*/{Protheus.doc} GET VISAOID api/pcp/v1/pcpmonitorapi/visao/{codVisao}
Retorna os dados de uma Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	codVisao, numerico, Codigo da Visão
@param	expand  , caracter, Indica se deve trazer as informações de usuário
@return lRet    , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET VISAOID PATHPARAM codVisao WSRECEIVE expand WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    ::SetContentType("application/json")
    aReturn := buscaVisao(::codVisao,::expand)
	lRet    := aReturn[1]
	If lRet
		::SetResponse(aReturn[2])
	EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} buscaVisao
Retorna os dados de uma Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	nCodVisao, numerico, Codigo da Visão
@param	cExpand  , caracter, Indica se deve trazer as informações de usuário
@return aResult  , array   , Array preparado com o retorno da requisição
/*/
Static Function buscaVisao(nCodVisao,cExpand)
    Local aResult := {.T.,"",200}
    Local cUser   := RetCodUsr()
    Local nPos    := 0
    Local oJson   := JsonObject():New()

    HZB->(dbSetOrder(1))
    If HZB->(dbSeek(xFilial("HZB")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])))
        oJson["codVisao"]        := HZB->HZB_CODIGO
        oJson["codUsuario"]      := UsrRetName(HZB->HZB_USUAR)
        oJson["titulo"]          := AllTrim(HZB->HZB_TITULO)
        oJson["tituloAbreviado"] := AllTrim(HZB->HZB_TITABR)
        oJson["icone"]           := AllTrim(HZB->HZB_ICONE)
        oJson["posicao"]         := HZB->HZB_POSIC
        oJson["agrupador"]       := AllTrim(HZB->HZB_AGRUP)
        oJson["isAdministrador"] := HZB->HZB_USUAR == cUser
        oJson["allowCreation"]   := valAccess("IncluirVisao")
        If cExpand == "usuarios"
            oJson["usuarios"] := {}
            HZG->(dbSetOrder(1))
            If HZG->(dbSeek(xFilial("HZG")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])))
                While HZG->(!Eof()) .And. HZG->(HZG_FILIAL+STR(HZG_VISAO,saTamVisao[1],saTamVisao[2])) == xFilial("HZG")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])
                    If HZG->HZG_USUAR != HZB->HZB_USUAR 
                        aAdd(oJson["usuarios"],JsonObject():New())
                        nPos++
                        oJson["usuarios"][nPos]["codigo"] := HZG->HZG_USUAR
                        oJson["usuarios"][nPos]["visao"]  := HZG->HZG_VISAO
                        oJson["usuarios"][nPos]["nome"]   := UsrRetName(HZG->HZG_USUAR)
                    EndIf
                    HZG->(dbSkip())
                End
            EndIf
            HZG->(dbCloseArea())
        EndIf
    EndIf
    HZB->(dbCloseArea())
    aResult[2] := EncodeUTF8(oJson:ToJson())
    FreeObj(oJson)
Return aResult

/*/{Protheus.doc} GET VISAO api/pcp/v1/pcpmonitorapi/visao
Retorna as Visões
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	filtraUsuario, logico  , Retorna apenas as Visões do usuário
@param	page         , numerico, Número da página de consulta
@param	pageSize     , numerico, Tamanho da página de consulta
@param	order        , caracter, Nome da propriedade pela qual a consulta deve ser ordenada
@param	filter       , caracter, Filtro com o nome parcial do titulo,titulo abreviado ou agrupador da Visão
@return lRet         , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET VISAO WSRECEIVE filtraUsuario, page, pageSize, order, filter WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    Default filtraUsuario := .T., ::page := 1, ::pageSize := 20, ::order := "HZB_POSIC", ::filter := ""

    ::SetContentType("application/json")
    aReturn := buscaVisoes(::filtraUsuario,::page, ::pageSize, ::order,::filter)
	lRet    := aReturn[1]
	If lRet
		::SetResponse(aReturn[2])
	EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} buscaVisoes
Retorna as Visões
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	lFilUsuar, logico  , Retorna apenas as Visões do usuário
@param	nPage    , numerico, Número da página de consulta
@param	nPageSize, numerico, Tamanho da página de consulta
@param	cOrder   , caracter, Nome da propriedade pela qual a consulta deve ser ordenada
@param	cFilter  , caracter, Filtro com o nome parcial do titulo,titulo abreviado ou agrupador da Visão
@return aResult  , array   , Array preparado com o retorno da requisição
/*/
Static Function buscaVisoes(lFilUsuar,nPage,nPageSize,cOrder,cFilter)
    Local aResult   := {.T.,"",200}
    Local cAlias    := GetNextAlias()
    Local cQuery    := ""
    Local cUser     := RetCodUsr()
    Local nPos      := 0
    Local nStart    := 0
    Local oJson     := JsonObject():New()

    cQuery := " SELECT HZB.HZB_CODIGO,HZB.HZB_USUAR,HZB.HZB_TITULO,HZB.HZB_TITABR,HZB.HZB_ICONE,HZB.HZB_POSIC,HZB.HZB_AGRUP, "
    cQuery += " HZG.HZG_ADMIN,HZG.HZG_FAVOR "
    cQuery += " FROM " + RetSqlName("HZB") + " HZB "
    cQuery += " INNER JOIN " + RetSqlName("HZG") + " HZG ON HZG.HZG_VISAO = HZB.HZB_CODIGO AND HZG.HZG_USUAR = '"+cUser+"' AND HZG.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE HZB.HZB_FILIAL = '"+xFilial("HZB")+"' "
    If !Empty(cFilter)
        cQuery += " AND (UPPER(HZB.HZB_TITULO) LIKE '%"+UPPER(cFilter)+"%' OR UPPER(HZB.HZB_TITABR) LIKE '%"+UPPER(cFilter)+"%' OR UPPER(HZB.HZB_AGRUP) LIKE '%"+UPPER(cFilter)+"%') "
    EndIf
    cQuery += " AND HZB.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY HZB.HZB_POSIC"
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    oJson["items"] := {}
    While (cAlias)->(!Eof())        
        aAdd(oJson["items"], JsonObject():New())
        nPos++
        oJson["items"][nPos]["codVisao"]        := (cAlias)->HZB_CODIGO
        oJson["items"][nPos]["codUsuario"]      := UsrRetName((cAlias)->HZB_USUAR)
        oJson["items"][nPos]["titulo"]          := AllTrim((cAlias)->HZB_TITULO)
        oJson["items"][nPos]["tituloAbreviado"] := AllTrim((cAlias)->HZB_TITABR)
        oJson["items"][nPos]["icone"]           := AllTrim((cAlias)->HZB_ICONE)
        oJson["items"][nPos]["posicao"]         := (cAlias)->HZB_POSIC
        oJson["items"][nPos]["agrupador"]       := AllTrim((cAlias)->HZB_AGRUP)
        oJson["items"][nPos]["isAdministrador"] := (cAlias)->HZG_ADMIN == "S"
        oJson["items"][nPos]["isFavorita"]      := (cAlias)->HZG_FAVOR == "S"
        (cAlias)->(dbSkip())
		If nPos >= nPageSize
			Exit
		EndIf
	End
    oJson["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

    oJson["allowCreation"] := valAccess("IncluirVisao")

    aResult[2] := EncodeUTF8(oJson:ToJson())
    aSize(oJson["items"],0)
	FreeObj(oJson)
Return aResult

/*/{Protheus.doc} GET VALIDVISAO api/pcp/v1/pcpmonitorapi/visao/allowCreation
Retorna as Visões
@type WSMETHOD
@author douglas.heydt
@since 10/12/2023
@version P12.1.2310
@return lRet         , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET VALIDVISAO WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    ::SetContentType("application/json")
    aReturn := getPermiss()
	lRet    := aReturn[1]
	If lRet
		::SetResponse(aReturn[2])
	EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} getPermiss
Verifica se o usuário logado tem acesso à criação de visões
@type Static Function
@author douglas.heydt   
@since 04/12/2023
@version P12.1.2310
@return aResult  , array   , Array preparado com o retorno da requisição
/*/
Static Function getPermiss()
    Local aResult   := {.T.,"",200}
    Local oJson     := JsonObject():New()

    oJson["allowCreation"] := valAccess("IncluirVisao")
  
    aResult[2] := EncodeUTF8(oJson:ToJson())
	FreeObj(oJson)
Return aResult


/*/{Protheus.doc} POST VISAO api/pcp/v1/pcpmonitorapi/visao
Inclui uma Visão
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST VISAO WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()    
    Local oJsonRet   := JsonObject():New()

	::SetContentType("application/json")
	If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0005)) //"Parâmetros inválidos para inclusão da visão."
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence  
                oJsonRet["titulo"]          := AllTrim(oBody["titulo"])
                oJsonRet["tituloAbreviado"] := AllTrim(oBody["tituloAbreviado"])
                oJsonRet["icone"]           := oBody["icone"]
                oJsonRet["posicao"]         := oBody["posicao"]
                oJsonRet["agrupador"]       := AllTrim(oBody["agrupador"])
                oJsonRet["usuarios"]        := {}
                lRet := incluiVisao(@oJsonRet, oBody["usuarios"])
            Recover
                lRet := .F.         
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oJsonRet))
        Else
            SetRestFault(400,EncodeUTF8(STR0013)) //"Ocorreram erros na inclusão da Visão. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
    FreeObj(oJsonRet)
Return lRet

/*/{Protheus.doc} incluiVisao
Inclui uma Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	oVisao   , objeto Json, Objeto Json com o body da requisição
@param  aUsuarios, array      , Array de objetos com lista de usuários da Visão
@return lRet     , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function incluiVisao(oJson,aUsuarios)
    Local cAlias   := GetNextAlias()
    Local cUser    := RetCodUsr()
    Local lRet     := .T.
    Local nIndice  := 0

    oJson["codUsuario"] := cUser 
    BeginSql Alias cAlias
        %noparser%
        SELECT MAX(HZB_CODIGO) AS HZB_CODIGO FROM %Table:HZB% WHERE %NotDel%
    EndSql
    oJson["codVisao"] := (cAlias)->HZB_CODIGO + 1
    (cAlias)->(DbCloseArea())
    RecLock("HZB", .T.)
    HZB->HZB_FILIAL := xFilial("HZB")
    HZB->HZB_CODIGO := oJson["codVisao"]
    HZB->HZB_USUAR  := oJson["codUsuario"]
    HZB->HZB_TITULO := oJson["titulo"]
    HZB->HZB_TITABR := oJson["tituloAbreviado"]
    HZB->HZB_ICONE  := oJson["icone"]
    HZB->HZB_POSIC  := oJson["posicao"]
    HZB->HZB_AGRUP  := oJson["agrupador"]
    MsUnlock()
    insereHZG(oJson["codVisao"],oJson["codUsuario"],"S")
    For nIndice = 1 To Len(aUsuarios)
        insereHZG(oJson["codVisao"],aUsuarios[nIndice]["codigo"],"N")
        aUsuarios[nIndice]:DelName("$selected")
        aAdd(oJson["usuarios"],aUsuarios[nIndice])
    Next nIndice
Return lRet

/*/{Protheus.doc} insereHZG
Inclui um registro de Usuário da Visão na tabela HZG
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param nCodVisao, numerico, Codigo da Visão
@param cUsuario , caracter, Id do Usuário
@param cIsAdmin , caracter, "S" - Administrador da Visão / "N" - Seguidor da Visão
@return lRet    , logico  , Informa se o processo foi executado com sucesso
/*/
Static Function insereHZG(nCodVisao,cUsuario,cIsAdmin)
    RecLock("HZG", .T.)
    HZG->HZG_FILIAL := xFilial("HZG")
    HZG->HZG_VISAO  := nCodVisao
    HZG->HZG_USUAR  := cUsuario
    HZG->HZG_ADMIN  := cIsAdmin
    HZG->HZG_FAVOR  := "N"
    MsUnlock()
Return

/*/{Protheus.doc} POST USUARIOS api/pcp/v1/pcpmonitorapi/visao/saveUsuarios
Inclui um usuário a Visão
@type WSMETHOD
@author renan.roeder
@since 13/03/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST USUARIOS WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local cUser      := RetCodUsr()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0042)) //"Parâmetros inválidos para inclusão do Usuário na Visão."
    ElseIf oBody["codigo"] == cUser
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0015)) //"O administrador da Visão não pode ser adicionado como seguidor."
    EndIf
    If lRet
        Begin Sequence 
            lRet := inclUsrVis(oBody)
        Recover
            lRet := .F.         
        End Sequence
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody))
        Else
            SetRestFault(400,EncodeUTF8(STR0044)) //"Ocorreram erros na inclusão do Usuário na Visão. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} inclUsrVis
Inclui um usuário a Visão
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	oJson, objeto Json, Objeto Json com o body da requisição
@return lRet , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function inclUsrVis(oJson)
    Local lRet     := .T.

    RecLock("HZG", .T.)
    HZG->HZG_FILIAL := xFilial("HZG")
    HZG->HZG_VISAO  := oJson["visao"]
    HZG->HZG_USUAR  := oJson["codigo"]
    HZG->HZG_ADMIN  := "N"
    HZG->HZG_FAVOR  := "N"
    MsUnlock()
Return lRet

/*/{Protheus.doc} DELETE USUARIOS api/pcp/v1/pcpmonitorapi/visao/deleteUsuarios/{codVisao}/{usuario}
Exclui um usuário da Visão
@type WSMETHOD
@author renan.roeder
@since 13/03/2023
@version P12.1.2310
@param  codVisao, numerico, Codigo da Visão
@param  usuario , caracter, Id do Usuário
@return lRet    , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD DELETE USUARIOS PATHPARAM codVisao,usuario WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cUser      := IIF(::usuario == "currentUser",RetCodUsr(),::usuario)
    Local lRet       := .T.
    Local oJsonRet   := JsonObject():New()

    ::SetContentType("application/json")
    Begin Sequence
        oJsonRet["visao"]  := ::codVisao
        oJsonRet["codigo"] := cUser
        lRet := exclUsrVis(::codVisao,cUser)
    Recover
        lRet := .F.
    End Sequence
    ErrorBlock(bErrorBloc)
    If lRet
        ::SetResponse(PCPMMsgSuc(oJsonRet))
    Else
        SetRestFault(400,EncodeUTF8(STR0229)) //"Ocorreram erros ao desvincular o Usuário da Visão. Contate o administrador do sistema."
    EndIf
    FreeObj(oJsonRet)
Return lRet

/*/{Protheus.doc} exclUsrVis
Exclui um Usuário da Visão
@type Static Function
@author renan.roeder
@since 13/03/2023
@version P12.1.2310
@param  nCodVisao, numerico, Codigo da Visão
@param  cUsuario , caracter, Id do Usuário
@return lRet     , logico  , Informa se o processo foi executado com sucesso
/*/
Static Function exclUsrVis(nCodVisao,cUsuario)
    Local lRet := .F.

    HZG->(dbSetOrder(1))
    If HZG->(dbSeek(xFilial("HZG")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])+cUsuario))
        lRet := .T.
        RecLock("HZG",.F.)
        HZG->(dbDelete())
        HZG->(MsUnlock())
    EndIf
    HZG->(dbCloseArea())
Return lRet

/*/{Protheus.doc} GET USUARIOS api/pcp/v1/pcpmonitorapi/usuarios
Retorna a lista de usuários do sistema
@type WSMETHOD
@author renan.roeder
@since 13/03/2023
@version P12.1.2310
@param	page    , numerico, Número da página de consulta
@param	pageSize, numerico, Tamanho da página de consulta
@param	filter  , caracter, Filtro com o nome parcial do usuário
@return lRet    , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET USUARIOS WSRECEIVE page, pageSize, filter WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    Default ::page := 1, ::pageSize := 20, ::filter := ""

    ::SetContentType("application/json")
    aReturn := PCPMonitorConsultas():BuscaUsuarios(::page,::pageSize,,::filter,"","",.F.)
    lRet    := aReturn[1]
    If lRet
        aReturn[2] := StrTran(aReturn[2],"Code","codigo")
        aReturn[2] := StrTran(aReturn[2],"Description","nome")
        aReturn[2] := StrTran(aReturn[2],"Email","email")
        ::SetResponse(aReturn[2])
    EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} GET IDUSUARIO api/pcp/v1/pcpmonitorapi/usuarios/{usuario}
Retorna os dados de um Usuário do Sistema
@type WSMETHOD
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	usuario, numerico, Codigo da Usuário
@return lRet   , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET IDUSUARIO PATHPARAM usuario WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    ::SetContentType("application/json")
    aReturn := PCPMonitorConsultas():BuscaUsuarios(::page,::pageSize,::usuario,,"","",.T.)
	lRet    := aReturn[1]
    If lRet
        aReturn[2] := StrTran(aReturn[2],"Code","codigo")
        aReturn[2] := StrTran(aReturn[2],"Description","nome")
        aReturn[2] := StrTran(aReturn[2],"Email","email")
        ::SetResponse(aReturn[2])
    Else
        SetRestFault(400,EncodeUTF8("Usuário não encontrado."))
    EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} POST FAVORITAVISAO api/pcp/v1/pcpmonitorapi/visao/favoritaVisao
Atualiza uma Visão como favorita
@type WSMETHOD
@author renan.roeder
@since 30/03/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST FAVORITAVISAO WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0025)) //"Parâmetros inválidos para atualizar a Visão como favorita."
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence 
                lRet := favUserVis(oBody)
            Recover
                lRet := .F.         
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody))
        Else
            SetRestFault(400,EncodeUTF8(STR0016)) //"Ocorreram erros para atualizar a Visão como favorita. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} favUserVis
Atualiza uma Visão como favorita
@type Static Function
@author renan.roeder
@since 30/03/2023
@version P12.1.2310
@param	oBody, objeto json, Objeto json com o corpo da requisição
@return lRet , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function favUserVis(oBody)
    Local lRet  := .F.
    Local cUser := RetCodUsr()
    
    HZG->(dbSetOrder(2))
    If HZG->(dbSeek(xFilial("HZG")+cUser))
        lRet := .T.
        While HZG->(!Eof()) .And. HZG->(HZG_FILIAL+HZG_USUAR) == xFilial("HZG")+cUser
            RecLock("HZG", .F.)
            HZG->HZG_FAVOR := IIF(HZG->HZG_VISAO ==  oBody["codVisao"],"S","N")
            HZG->(MsUnlock())
            HZG->(dbSkip())
        End
        HZG->(dbCloseArea())
    EndIf
Return lRet

/*/{Protheus.doc} POST DESFAVORITAVISAO api/pcp/v1/pcpmonitorapi/visao/desfavoritaVisao
Desfavorita uma Visão
@type WSMETHOD
@author renan.roeder
@since 30/03/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST DESFAVORITAVISAO WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0032)) //"Parâmetros inválidos para desfavoritar a Visão."
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence 
                lRet := desfavUVis(oBody)
            Recover
                lRet := .F.         
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody))
        Else
            SetRestFault(400,EncodeUTF8(STR0043)) //"Ocorreram erros para desfavoritar a Visão. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} desfavUVis
Desfavorita uma Visão
@type Static Function
@author renan.roeder
@since 30/03/2023
@version P12.1.2310
@param	oBody, objeto json, Objeto json com o corpo da requisição
@return lRet , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function desfavUVis(oBody)
    Local cUser     := RetCodUsr()
    Local lRet      := .F.
    Local nCodVisao := oBody["codVisao"]
    
    HZG->(dbSetOrder(1))
    If HZG->(dbSeek(xFilial("HZG")+STR(nCodVisao,saTamVisao[1],saTamVisao[2])+cUser))
        lRet := .T.
        RecLock("HZG", .F.)
        HZG->HZG_FAVOR := "N"
        HZG->(MsUnlock())
        HZG->(dbCloseArea())
    EndIf
Return lRet

/*/{Protheus.doc} POST COPIA_VISAO api/pcp/v1/pcpmonitorapi/visao/copiaVisao/{codVisao}
Copia uma Visão
@type WSMETHOD
@author douglas.heydt
@since 06/04/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST COPIA_VISAO PATHPARAM codVisao WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()
    Local oVisao     := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0046)) //"Parâmetros inválidos para cópia da visão."
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence      
                lRet := copiaVisao(::codVisao,oBody["titulo"],@oVisao)
            Recover
                lRet := .F.         
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oVisao))
        Else
            SetRestFault(400,EncodeUTF8(STR0047)) //"Ocorreram erros na cópia da Visão. Contate o administrador do sistema."
        EndIf
    EndIF
    FreeObj(oBody)
    FreeObj(oVisao)
Return lRet

/*/{Protheus.doc} copiaVisao
Copia uma Visão
@type Static Function
@author douglas.heydt
@since 06/04/2023
@version P12.1.2310
@param  nCodVisao, numerico   , Codigo da Visão que será copiada
@param  cTitulo  , caracter   , Titulo da nova Visão
@param  oVisao   , objeto json, Objeto Json com os dados da Visão que será retornado na requisição
@return lRet     , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function copiaVisao(nCodVisao,cTitulo,oVisao)
    Local lRet       := .T.
    Local nPos       := 0
    Local oMonitores := JsonObject():New()

    //busca Visão
    oVisao:FromJson(DecodeUTF8(buscaVisao(nCodVisao,"")[2]))
    oVisao["titulo"]          := AllTrim(cTitulo)
    //Busca Monitores da Visão
    oMonitores:FromJson(DecodeUTF8(buscaMtVis(nCodVisao,"propriedades","")[2]))

    lRet := incluiVisao(@oVisao, {})
    If lRet
        For nPos := 1 To Len(oMonitores["items"])
            oMonitores["items"][nPos]["codVisao"] := oVisao["codVisao"]
            lRet := incluiVsMt(oMonitores["items"][nPos])
        Next nPos
    EndIf
    FreeObj(oMonitores)
Return lRet

/*/{Protheus.doc} GET LISTA_CONSULTA api/pcp/v1/pcpmonitorapi/consulta
Retorna uma lista de registros
@type WSMETHOD
@author renan.roeder
@since 24/04/2023
@version P12.1.2310
@param  page    , caracter, Número da página
@param  pageSize, caracter, Tamanho da página
@param  filter  , caracter, Filtro da busca
@param  order   , caracter, Ordem de busca
@param  metodo  , caracter, Método da classe de negócio
@param  filial  , caracter, Filial para consulta
@param  Code    , caracter, Id do registro
@return lRet    , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET LISTA_CONSULTA WSRECEIVE page,pageSize,filter,order,metodo,filial,Code,tabela,campoCodigo,campoDescricao WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    Default ::page := 1,::pageSize := 20,order := "",::filial := ""
    
    ::SetContentType("application/json")
    if Empty(::metodo)
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0050)) //"Parâmetros inválidos para a consulta."
    EndIf
    If lRet
        aReturn := exConsulta(::page,::pageSize,::Code,::filter,::order,::metodo,::filial,.F.,::tabela,::campoCodigo,::campoDescricao)
        lRet    := aReturn[1]
        If lRet
            ::SetResponse(aReturn[2])
        EndIf        
    EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} GET ITEM_CONSULTA api/pcp/v1/pcpmonitorapi/consulta/{value}
Retorna um registro da lista
@type WSMETHOD
@author renan.roeder
@since 24/04/2023
@version P12.1.2310
@param  value   , caracter, Id do registro
@param  metodo  , caracter, Método da classe de negócio
@param  filial  , caracter, Filial para consulta
@return lRet    , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET ITEM_CONSULTA PATHPARAM value WSRECEIVE metodo,filial,tabela,campoCodigo,campoDescricao WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    Default ::filial := ""
    
    ::SetContentType("application/json")
    if Empty(::metodo)
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0050)) //"Parâmetros inválidos para a consulta."
    EndIf
    If lRet
        aReturn := exConsulta(,,::value,,,::metodo,::filial,.T.,::tabela,::campoCodigo,::campoDescricao)
        lRet    := aReturn[1]
        If lRet
            ::SetResponse(aReturn[2])
        EndIf        
    EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} exConsulta
Retorna uma lista de registros
@type Static Function
@author renan.roeder
@since 24/04/2023
@version P12.1.2310
@param  nPage     , numerico, Número da página
@param  nPageSize , numerico, Tamanho da página
@param  cValue    , caracter, Id do Registro
@param  cFilter   , caracter, Filtro da busca
@param  cOrder    , caracter, Ordem de busca
@param  cMetodo   , caracter, Método da classe de negócio
@param  cFilialFlt, caracter, Filial para consulta
@param  lItemCons , logico  , Indica se retorna uma lista de items
@return aResult   , array   , Array preparado com o retorno da requisição
/*/
Static Function exConsulta(nPage,nPageSize,cValue,cFilter,cOrder,cMetodo,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc)
    Local aResult   := {.T.,"",200}

    Default nPage := 1,nPageSize := 10,cOrder := "",cFilialFlt := "", lItemCons := .F.

    cFilialFlt := IIF(cFilialFlt == "undefined","",cFilialFlt)
    cMetodo := cMetodo + "(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc)"
    aResult := &(cMetodo)
Return aResult

/*/{Protheus.doc} PCPMonitErr
Função executada quando a transação cai em exceção
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	e, objeto, Objeto com os dados do erro
@return Nil
/*/
Static Function PCPMonitErr(e)
	Local cMessage := AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack)
	
    LogMsg('PCPMonitorAPI', 0, 0, 1, '', '', Replicate("-",70) + CHR(10) + cMessage + CHR(10) + Replicate("-",70))
	If InTransact()
		DisarmTransaction()
	EndIf
Return

/*/{Protheus.doc} PCPMMsgSuc
Trata a mensagem de retorno de sucesso da requisição para mostrar o notification no front-end
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param	oJson    , objeto Json, Objeto Json passado como referência para retornar na requisição
@param	cMensagem, caracter   , Mensagem de retorno de sucesso da requisição
@return Nil
/*/
Static Function PCPMMsgSuc(oJson, cMensagem)
    Default oJson := JsonObject():New(), cMensagem := ""
    HTTPSetStatus(200)
    If !Empty(cMensagem)
        oJson["_messages"] := {}
        aAdd(oJson["_messages"], JsonObject():New())
        oJson["_messages"][1]["type"]            := "success"
        oJson["_messages"][1]["code"]            := "200"
        oJson["_messages"][1]["message"]         := cMensagem
        oJson["_messages"][1]["detailedMessage"] := ""
    EndIf
Return EncodeUTF8(oJson:ToJson())

/*/{Protheus.doc} POST ORDENA_MONIT api/pcp/v1/pcpmonitorapi/visaoMonitor/reorder
Realiza a ordenação de monitores de uma visão
@type WSMETHOD
@author douglas.heydt
@since 20/07/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST ORDENA_MONIT WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0235)) //"Parâmetros inválidos para ordenação dos Monitores da Visão."
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence
                lRet := ordenaMon(oBody)
            Recover
                lRet := .F.         
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody))
        Else
            SetRestFault(400,EncodeUTF8(STR0234)) //"Ocorreram erros na ordenação dos Monitores. Contate o administrador do sistema."
        EndIf
    EndIF
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc}
Atualiza a posição do monitor de uma visão
@type Function
@author douglas.heydt
@since 20/07/2023
@version P12.1.2310
@param  oBody, objeto json, Objeto com o corpo da requisição
@return lRet , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function ordenaMon(oBody)
    Local nIndice  := 0
    Local nPosicao := 0
    Local lRet     := .T.

    For nIndice := 1 to Len(oBody)
        nPosicao := nIndice * 10
        cSql := " UPDATE " + RetSqlName("HZC") + " "
        cSql += "   SET HZC_POSIC = " + cValToChar(nPosicao) + " "
        cSql += " WHERE HZC_FILIAL = '" + xFilial("HZC") + "' "
        cSql += "   AND HZC_VISAO  = "+ cValToChar(oBody[nIndice]["codVisao"]) + " "
        cSql += "   AND HZC_MONIT  = '"+ oBody[nIndice]["codMonitor"] + "' "
        cSql += "   AND HZC_SEQUEN = "+ cValToChar(oBody[nIndice]["sequencia"]) + " "
        If TCSQLExec(cSql) < 0
            DisarmTransaction()
            lRet := .F.
            Exit
        EndIf      
    Next nIndice
Return lRet

/*/{Protheus.doc} GET APRESENTACOES api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario
Retorna as apresentações cadastradas
@type WSMETHOD
@author douglas.heydt
@since 07/09/2023
@version P12.1.2310
@param	filtraUsuario, logico  , Retorna apenas as Visões do usuário
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET APRESENTACOES WSRECEIVE filtraUsuario WSSERVICE PCPMonitorAPI
    Local aReturn := {}
    Local lRet := .T.

    Default filtraUsuario := .T.

    ::SetContentType("application/json")
    aReturn := getApresen(::filtraUsuario)
	lRet    := aReturn[1]
	If lRet
		::SetResponse(aReturn[2])
	Else
        SetRestFault(aReturn[3], aReturn[2])
    EndIf
    FwFreeArray(aReturn)
Return lRet

/*/{Protheus.doc} getApresen
Retorna as apresentações
@type Static Function
@author douglas.heydt
@since 07/09/2023
@version P12.1.2310
@param	lFilUsuar, logico  , Retorna apenas as Visões do usuário
@return aResult  , array   , Array preparado com o retorno da requisição
/*/
Static Function getApresen(lFilUsuar)
    Local aResult   := {.T.,"",200}
    Local cAlias    := GetNextAlias()
    Local cQuery    := ""
    Local cUser     := RetCodUsr()
    Local nPos      := 0
    Local oJson     := JsonObject():New()
   
    If AliasInDic("HZH")
        cQuery := " SELECT HZH_CODAPR, HZH_DSCAPR, HZH_CODUSR, HZH_SEQVIS, HZH_TEMPTR"
        cQuery += " FROM " + RetSqlName("HZH")
        cQuery += " WHERE D_E_L_E_T_ = ' ' "
        If lFilUsuar
            cQuery += " AND HZH_CODUSR = '"+cUser+"' "
        EndIf
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
        
        oJson["items"] := {}
        While (cAlias)->(!Eof())        
            aAdd(oJson["items"], JsonObject():New())
            nPos++
            oJson["items"][nPos]["codigoApresentacao"] := (cAlias)->HZH_CODAPR
            oJson["items"][nPos]["nomeApresentacao"]   := (cAlias)->HZH_DSCAPR
            oJson["items"][nPos]["tempoTransicao"]     := (cAlias)->HZH_TEMPTR
            oJson["items"][nPos]["sequenciaVisoes"]    := (cAlias)->HZH_SEQVIS
            oJson["items"][nPos]["codUsuario"]         := (cAlias)->HZH_CODUSR
            (cAlias)->(dbSkip())
        End
        (cAlias)->(dbCloseArea())
        aResult[2] := EncodeUTF8(oJson:ToJson())
    Else
		aResult[1]:= .F.
		aResult[2]:= EncodeUTF8(STR0245) //"Tabela HZH não existe no dicionário de dados"
		aResult[3]:= 400
	EndIf
	FreeObj(oJson)
Return aResult

/*/{Protheus.doc} POST APRESENTACAO api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario
Cria uma nova apresentação
@type WSMETHOD
@author douglas.heydt
@since 07/09/2023
@version P12.1.2310
@return lRet, logico, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST APRESENTACAO WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0240)) //"Parâmetros inválidos para inclusão da apresentação."
    EndIf

    If existTitle(oBody["nomeApresentacao"])
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0274)) //"Nome da apresentação em uso! Informe outro nome."
    EndIf

    If lRet
        Begin Transaction
            Begin Sequence
                lRet := criaApres(oBody)
            Recover
                lRet := .F.
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody))
        Else
            SetRestFault(400,EncodeUTF8(STR0241)) //"Ocorreram erros na inclusão do apresentação. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} criaApres
Inclui uma apresentação de visões
@type Static Function
@author douglas.heydt
@since 07/09/2023
@version P12.1.2310
@param	oBody  , objeto Json, body do POST
@return lRet   , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function criaApres(oBody)
    Local cAlias    := GetNextAlias()
    Local cUser     := RetCodUsr()
    Local cCodApr   := ""
    Local lRet      := .T.
    
    BeginSql Alias cAlias
        SELECT 
            MAX(HZH_CODAPR) AS HZH_CODAPR 
        FROM %Table:HZH% HZH
        WHERE HZH.HZH_CODUSR = %Exp:cUser%
        AND HZH.%NotDel%
    EndSql

    If !Empty((cAlias)->HZH_CODAPR)
        cCodApr := PadL(cValToChar(Val((cAlias)->HZH_CODAPR) + 1), GetSx3Cache("HZH_CODAPR","X3_TAMANHO"), "0")
    Else
        cCodApr := PadL("1", GetSx3Cache("HZH_CODAPR","X3_TAMANHO"), "0")
    EndIf
    (cAlias)->(DbCloseArea())

    RecLock("HZH", .T.)
    HZH->HZH_FILIAL := xFilial("HZH")
    HZH->HZH_CODAPR := cCodApr
    HZH->HZH_DSCAPR := oBody["nomeApresentacao"]
    HZH->HZH_TEMPTR := oBody["tempoTransicao"]
    HZH->HZH_SEQVIS := oBody["sequenciaVisoes"]
    HZH->HZH_CODUSR := cUser
    HZH->(MsUnlock())
Return lRet

/*/{Protheus.doc} PUT APRESENTACAO api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario/{codUsuario}/{codApresentacao}
Edita uma apresentação
@type WSMETHOD
@author douglas.heydt
@since 07/09/2023
@version P12.1.2310
@return lRet      , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD PUT APRESENTACAO PATHPARAM codUsuario, codApresentacao WSSERVICE PCPMonitorAPI
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local cBody      := ::GetContent()
    Local lRet       := .T.
    Local oBody      := JsonObject():New()

    ::SetContentType("application/json")
    If oBody:FromJson(DecodeUTF8(cBody)) <> NIL
        lRet := .F.
        SetRestFault(400,EncodeUTF8(STR0242)) //"Parâmetros inválidos para edição da apresentação."
    EndIf
    If lRet
        Begin Transaction
            Begin Sequence
                lRet := editAPrese(::codUsuario, ::codApresentacao, oBody)
            Recover
                lRet := .F.
            End Sequence
        End Transaction
        ErrorBlock(bErrorBloc)
        If lRet
            ::SetResponse(PCPMMsgSuc(oBody))
        Else
            SetRestFault(400,STR0243) //"Ocorreram erros na edição da apresentação. Contate o administrador do sistema."
        EndIf
    EndIf
    FreeObj(oBody)
Return lRet

/*/{Protheus.doc} editAPrese
Edita uma apresentação de visões
@type Static Function
@author douglas.heydt
@since 07/09/2023
@version P12.1.2310
@param	cUsuario, caracter   , Código do usuário dono da apresentação
@param	cCodApr , caracter   , Codigo da apresentação
@param	oBody   , objeto Json, Objeto Json com os dados da apresentação
@return lRet    , logico     , Informa se o processo foi executado com sucesso
/*/
Static Function editAPrese(cUsuario, cCodApr, oBody)
    Local lRet    := .F.

    HZH->(dbSetOrder(1))
    If HZH->(dbSeek(xFilial("HZH")+cUsuario+cCodApr))
        RecLock("HZH",.F.)
        HZH->HZH_CODAPR := oBody["codigoApresentacao"]
        HZH->HZH_DSCAPR := oBody["nomeApresentacao"]
        HZH->HZH_TEMPTR := oBody["tempoTransicao"]
        HZH->HZH_SEQVIS := oBody["sequenciaVisoes"]
        HZH->HZH_CODUSR := oBody["codUsuario"]
        HZH->(MsUnlock())
        HZH->(dbCloseArea())
        lRet    := .T.
    EndIf
Return lRet

/*/{Protheus.doc} DELETE APRESENTACAO api/pcp/v1/pcpmonitorapi/visaoApresentacaoUsuario/{codUsuario}/{codApresentacao}
Exclui uma apresentação de visões
@type WSMETHOD
@author douglas.heydt
@since 07/09/2023
@version P12.1.2310
@param	codUsuario      , caracter, código do usuário dono da apresentação
@param	codApresentacao , number  , código da apresentação
@return lRet      , logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD DELETE APRESENTACAO PATHPARAM codUsuario, codApresentacao WSSERVICE PCPMonitorAPI 
    Local bErrorBloc := ErrorBlock({|e| PCPMonitErr(e), Break(e) })
    Local lRet        := .F.
    Local oJson       := JsonObject():New()

    Begin Transaction
        Begin Sequence
            lRet := excluiApre(::codUsuario,  PadL(::codApresentacao, GetSx3Cache("HZH_CODAPR","X3_TAMANHO"), "0") )
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBloc)
    If lRet
        ::SetResponse(PCPMMsgSuc(oJson))
    Else
        SetRestFault(400,EncodeUTF8(STR0244)) //"Ocorreram erros na exclusão da apresentação de visões. Contate o administrador do sistema."
    EndIf
	FreeObj(oJson)
Return lRet


/*/{Protheus.doc} excluiApre
Exclui uma apresentação de visões
@type Static Function
@author douglas.heydt
@since 08/09/2023
@version P12.1.2310
@param	cCodUser    , caracter, Usuário dono da apresentação
@param	cCodAprese  , caracter, código da apresentação
@return lRet        ,  logico , Informa se o processo foi executado com sucesso
/*/
Static Function excluiApre(cCodUser,cCodAprese)
    Local lRet    := .F.
    
    HZH->(dbSetOrder(1))
    If HZH->(dbSeek(xFilial("HZH")+cCodUser+cCodAprese))
        RecLock("HZH",.F.)
        HZH->(dbDelete())
        HZH->(MsUnlock())
        HZH->(dbCloseArea())
        lRet := .T.
    EndIf
Return lRet


/*/{Protheus.doc} existTitle
Verifica se já existe uma apresentação com o título passado para o mesmo usuário
@type Static Function
@author douglas.heydt
@since 17/10/2023
@version P12.1.2310
@param	cTitulo    , caracter, Titulo da apresentação
@return lExist     , logico , Informa se já existe uma apresentação com este título
/*/
Static Function existTitle(cTitulo)
    Local cAlias    := GetNextAlias()
    Local cQuery    := ""
    Local cUser     := RetCodUsr()
    Local lExist    := .F.
   
    If AliasInDic("HZH")
        cQuery := " SELECT HZH_CODAPR, HZH_DSCAPR, HZH_CODUSR "
        cQuery += " FROM " + RetSqlName("HZH")
        cQuery += " WHERE HZH_DSCAPR = '"+cTitulo+"' "
        cQuery  += " AND HZH_CODUSR = '"+cUser+"' "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
        
        If (cAlias)->(!Eof())        
          lExist := .T.
        EndIf
        (cAlias)->(dbCloseArea())
    EndIf
Return lExist
