#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"

/*/{Protheus.doc} PCPMonitorCarga
Classe para realizar a carga dos Monitores na base de dados
@type Class
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Class PCPMonitorCarga FROM LongNameClass
    Private DATA cCodigoMonitor              AS Character
    Private DATA cMensagemErro               AS Character
    Private DATA nNumeroPropriedadesMonitor  AS Numeric
    Private DATA oMonitor                    AS Object
    Private DATA oExemploJson                AS Object
    Private DATA aPropriedadesMonitor        AS Array

    Public Method New(lCustom) Constructor
    Public Method Destroy()

    Public Method setaTitulo(cTitulo)
    Public Method setaObjetivo(cObjetivo)
    Public Method setaAgrupador(cAgrup)
    Public Method setaFuncaoNegocio(cAPINeg)
    Public Method setaTiposPermitidos(cTiposPer)
    Public Method setaTiposGraficoPermitidos(cTpGrafPer)
    Public Method setaTipoPadrao(cTpPdr)
    Public Method setaTipoGraficoPadrao(cTpGrfPdr)
    Public Method setaExemploJsonGrafico(oSeries,aTags,aDetalhes,aCategorias,cTpGrfExp)
    Public Method setaExemploJsonTexto(lTabs,oExemplos)    
    Public Method setaPropriedade(cCodigo,cValPadrao,cTitulo,nTipo,cTamanho,cDecimal,cClasses,oEstilos,cIcone,oPrmAdc)
    Public Method setaPropriedadeFilial(cCodigo)
    Public Method setaPropriedadeUsuario(cCodigo,lSelecMult)
    Public Method setaPropriedadeProduto(cCodigo,lSelecMult)
    Public Method setaPropriedadeRecurso(cCodigo,lSelecMult)
    Public Method setaPropriedadeLookupTabela(cCodigo,cLabel,lSelecMult,cTabela,cCampoCod,cCampoDsc,cClasses,oEstilos)
    Public Method setaPropriedadeLookupTabelaGenerica(cCodigo,cLabel,lSelecMult,cTabela,cClasses,oEstilos)
    Public Method setaPropriedadePeriodoAtual(cCodigo,cValPad,cCodigoPer)
    Public Method setaPropriedadePeriodoLinhaTempo(cCodigo,cValPad,cCodPerQtd)
    Public Method setaTipoDetalhe(cTpDetalhe)
    Public Method gravaMonitorPropriedades()
    Public Method recuperaMensagemErro()
    Public Method registraErroTransacao(oErro)
    Public Method persisteCadastroMonitor()
    Public Method setaCodigoMonitor(cCodigo)
    Public Method setaProprietarioMonitor(cUser)
    Public Method setaRascunhoMonitor(lRascunho)
    Public Method recuperaCodigoMonitor()
    Public Method persisteCadastroPropriedadesMonitor()
    Public Method retornaProximaPosicaoPropriedade()
    Private Method montaJsonExemploTexto(oExemplo,oJson)
    Static Method monitorAtualizado(cApiNeg)
EndClass

/*/{Protheus.doc} New
Método construtor
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  lCustom, logico, Define se será realizada a carga de um Monitor customizado
@return Nil
/*/
Method New(lCustom) Class PCPMonitorCarga
    Default lCustom := .F.

    ::oMonitor                    := JsonObject():New()
    ::oMonitor["logPadrao"]       := !lCustom
    ::oMonitor["usuario"]         := ""
    ::oMonitor["rascunho"]        := "N"    
    ::oExemploJson                := JsonObject():New()
    ::aPropriedadesMonitor        := {}
    ::nNumeroPropriedadesMonitor  := 0
    ::cCodigoMonitor              := ""
    ::cMensagemErro               := ""
Return

/*/{Protheus.doc} Destroy
Libera os objetos da memória
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method Destroy() Class PCPMonitorCarga
    FreeObj(::oMonitor)
    FreeObj(::oExemploJson)
    FwFreeArray(::aPropriedadesMonitor)
Return

/*/{Protheus.doc} setaTitulo
Inclui o atributo titulo
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cTitulo, caracter, Titulo do Monitor
@return Nil
/*/
Method setaTitulo(cTitulo) Class PCPMonitorCarga
    ::oMonitor["titulo"] := cTitulo
Return

/*/{Protheus.doc} setaObjetivo
Inclui o atributo objetivo
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cObjetivo, caracter, Objetivo do Monitor
@return Nil
/*/
Method setaObjetivo(cObjetivo) Class PCPMonitorCarga
    ::oMonitor["objetivo"] := cObjetivo
Return

/*/{Protheus.doc} setaAgrupador
Inclui o atributo agrupador
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cAgrup, caracter, Agrupador do Monitor
@return Nil
/*/
Method setaAgrupador(cAgrup) Class PCPMonitorCarga
    ::oMonitor["agrupador"] := cAgrup
Return

/*/{Protheus.doc} setaFuncaoNegocio
Inclui o atributo apiNegocio
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cAPINeg, caracter, Função de negócio que retornará os dados do Monitor
@return Nil
/*/
Method setaFuncaoNegocio(cAPINeg) Class PCPMonitorCarga
    ::oMonitor["apiNegocio"] := cAPINeg
Return

/*/{Protheus.doc} setaTiposPermitidos
Inclui o atributo opcoesTipo
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cTiposPer, caracter, Tipos permitidos para o monitor (info;chart)
@return Nil
/*/
Method setaTiposPermitidos(cTiposPer) Class PCPMonitorCarga
    ::oMonitor["opcoesTipo"] := cTiposPer
Return

/*/{Protheus.doc} setaTiposGraficoPermitidos
Inclui o atributo opcoesSubtipo
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cTpGrafPer, caracter, Tipos permitidos de gráfico (pie;column;bar)
@return Nil
/*/
Method setaTiposGraficoPermitidos(cTpGrafPer) Class PCPMonitorCarga
    ::oMonitor["opcoesSubtipo"] := cTpGrafPer
Return

Method setaTipoPadrao(cTpPdr) Class PCPMonitorCarga
    ::oMonitor["tipo"] := cTpPdr
Return

Method setaTipoGraficoPadrao(cTpGrfPdr) Class PCPMonitorCarga
    ::oMonitor["subtipo"] := cTpGrfPdr
Return

/*/{Protheus.doc} setaExemploJsonGrafico
Atribui as configurações do exemplo do Monitor
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  oSeries  , objeto Json, Objeto Json com as Series do chart
@param  aTags    , array objetos, Array de objetos Json com as tags do Monitor
@param  aDetalhes, array objetos, Array de objetos Json com os detalhes do Monitor
@return Nil
/*/
Method setaExemploJsonGrafico(oSeries,aTags,aDetalhes,aCategorias,cTpGrfExp,oGaugeProp) Class PCPMonitorCarga
    Local aNSeries := oSeries:GetNames()
    Local nIndice  := 0

    Default oSeries := JsonObject():New(), aTags := {}, aDetalhes := {}, aCategorias := {}, oGaugeProp := JsonObject():New()

    ::oExemploJson["tipo"]    := "chart"
    ::oExemploJson["subtipo"] := cTpGrfExp
    ::oExemploJson["exemplo"] := JsonObject():New()
	::oExemploJson["exemplo"]["altura"]     := 250
    ::oExemploJson["exemplo"]["categorias"] := aCategorias
    ::oExemploJson["exemplo"]["gauge"]      := oGaugeProp
    ::oExemploJson["exemplo"]["series"]     := {}
    For nIndice := 1 To Len(aNSeries)
	    aAdd(::oExemploJson["exemplo"]["series"], JsonObject():New())
        ::oExemploJson["exemplo"]["series"][nIndice]["color"]   := oSeries[aNSeries[nIndice]][2]
        ::oExemploJson["exemplo"]["series"][nIndice]["data"]    := oSeries[aNSeries[nIndice]][1]
        ::oExemploJson["exemplo"]["series"][nIndice]["tooltip"] := ""
        ::oExemploJson["exemplo"]["series"][nIndice]["label"]   := aNSeries[nIndice]
    Next nIndice
    ::oExemploJson["exemplo"]["tags"] := {}
    For nIndice := 1 To Len(aTags)
        aAdd(::oExemploJson["exemplo"]["tags"], JsonObject():New())
        ::oExemploJson["exemplo"]["tags"][nIndice]["texto"]      := aTags[nIndice]["texto"]
        ::oExemploJson["exemplo"]["tags"][nIndice]["colorTexto"] := aTags[nIndice]["colorTexto"]
        ::oExemploJson["exemplo"]["tags"][nIndice]["icone"]      := aTags[nIndice]["icone"]
    Next nIndice     
    ::oExemploJson["exemplo"]["detalhes"] := {}
    For nIndice := 1 To Len(aDetalhes)
        aAdd(::oExemploJson["exemplo"]["detalhes"], JsonObject():New())
        ::oExemploJson["exemplo"]["detalhes"][nIndice]["texto"]     := aDetalhes[nIndice]["texto"]
        ::oExemploJson["exemplo"]["detalhes"][nIndice]["hyperlink"] := aDetalhes[nIndice]["hyperlink"]
        ::oExemploJson["exemplo"]["detalhes"][nIndice]["classe"]    := aDetalhes[nIndice]["classe"]
        ::oExemploJson["exemplo"]["detalhes"][nIndice]["icone"]     := aDetalhes[nIndice]["icone"]
    Next nIndice   
Return

Method setaExemploJsonTexto(lTabs,oExemplos) Class PCPMonitorCarga
    Local nIndice := 0

    ::oExemploJson["tipo"]    := "info"
    ::oExemploJson["usaTabs"] := lTabs
    If ::oExemploJson["usaTabs"]
        ::oExemploJson["exemplo"] := {}
        For nIndice := 1 To Len(oExemplos)
            aAdd(::oExemploJson["exemplo"], JsonObject():New())
            ::montaJsonExemploTexto(oExemplos[nIndice],::oExemploJson["exemplo"][nIndice])
        Next nIndice
    Else
        ::oExemploJson["exemplo"] := JsonObject():New()
        ::montaJsonExemploTexto(oExemplos,::oExemploJson["exemplo"])
    EndIf
Return

Method montaJsonExemploTexto(oExemplo,oJson) Class PCPMonitorCarga
    Local nIndice := 0

    oJson["corFundo"]  := oExemplo["corFundo"]
    oJson["corTitulo"] := oExemplo["corTitulo"]
    oJson["tags"]   := {}
    For nIndice := 1 To Len(oExemplo["tags"])
        aAdd(oJson["tags"],JsonObject():New())
        oJson["tags"][nIndice]["icone"]      := oExemplo["tags"][nIndice]["icone"]       
        oJson["tags"][nIndice]["colorTexto"] := oExemplo["tags"][nIndice]["colorTexto"]  
        oJson["tags"][nIndice]["texto"]      := oExemplo["tags"][nIndice]["texto"]       
    Next nIndice
    oJson["linhas"]    := {}
    For nIndice := 1 To Len(oExemplo["linhas"])
        aAdd(oJson["linhas"],JsonObject():New())
        oJson["linhas"][nIndice]["texto"]           := oExemplo["linhas"][nIndice]["texto"]
        oJson["linhas"][nIndice]["tipo"]            := oExemplo["linhas"][nIndice]["tipo"]          
        oJson["linhas"][nIndice]["classeTexto"]     := oExemplo["linhas"][nIndice]["classeTexto"]
        oJson["linhas"][nIndice]["styleTexto"]      := oExemplo["linhas"][nIndice]["styleTexto"]    
        oJson["linhas"][nIndice]["tituloProgresso"] := oExemplo["linhas"][nIndice]["tituloProgresso"]
        oJson["linhas"][nIndice]["valorProgresso"]  := oExemplo["linhas"][nIndice]["valorProgresso"]
        oJson["linhas"][nIndice]["icone"]           := oExemplo["linhas"][nIndice]["icone"] 
    Next nIndice
Return

/*/{Protheus.doc} setaPropriedade
Atribui uma propriedade ao filtro do Monitor
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cCodigo   , caracter   , Codigo da Propriedade
@param  cValPadrao, caracter   , Valor Padrão
@param  cTitulo   , caracter   , Titulo
@param  nTipo     , numerico   , Tipo do componente(1-Text;2-Numerico;3-Data;4-Select;5-Multi-Select)
@param  cTamanho  , caracter   , Tamanho do campo texto ou numerico
@param  cDecimal  , caracter   , Número de casas decimais do campo numerico
@param  cClasses  , caracter   , Classes para formatar o componente
@param  oEstilos  , objeto Json, Estilos para formatar o componente
@param  cIcone    , caracter   , Icone do componente
@param  oPrmAdc   , objeto json, Parametros adicionais
@return Nil
/*/
Method setaPropriedade(cCodigo,cValPadrao,cTitulo,nTipo,cTamanho,cDecimal,cClasses,oEstilos,cIcone,oPrmAdc) Class PCPMonitorCarga
    Default cValPadrao := "", cTamanho := 0, cDecimal := 0,cClasses := "",oEstilos := JsonObject():New(), cIcone := "",oPrmAdc := JsonObject():New()

    ::nNumeroPropriedadesMonitor++
    aAdd(::aPropriedadesMonitor, JsonObject():New())
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["codPropriedade"]       := cCodigo
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["valorPadrao"]          := cValPadrao
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["titulo"]               := cTitulo
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["tipo"]                 := nTipo
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["tamanhoTexto"]         := IIF(nTipo == 1,cTamanho,0)
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["tamanhoNumerico"]      := IIF(nTipo == 2,cTamanho,0)
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["tamanhoDecimal"]       := cDecimal
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["classes"]              := cClasses
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["estilos"]              := oEstilos:ToJson()
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["icone"]                := cIcone
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["parametrosAdicionais"] := oPrmAdc:ToJson()
    ::aPropriedadesMonitor[::nNumeroPropriedadesMonitor]["posicao"]              := ::retornaProximaPosicaoPropriedade(::nNumeroPropriedadesMonitor)
Return

/*/{Protheus.doc} setaTipoDetalhe
Inclui o atributo tipoDetalhe
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cTpDetalhe, caracter, Tipo de abertura do detalhe (modal;detalhe;externo(datasul))
@return Nil
/*/
Method setaTipoDetalhe(cTpDetalhe) Class PCPMonitorCarga
    ::oMonitor["tipoDetalhe"] := cTpDetalhe
Return

/*/{Protheus.doc} gravaMonitorPropriedades
Gerencia a gravação do Monitor e suas propriedades em base de dados
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method gravaMonitorPropriedades() Class PCPMonitorCarga
    Local bErrorBlck := Nil
    Local lRet        := .T.

	bErrorBlck := ErrorBlock({|oErro| ::registraErroTransacao(oErro), Break(oErro) })
    Begin Transaction
        Begin Sequence
                ::persisteCadastroMonitor()
                ::persisteCadastroPropriedadesMonitor()                
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBlck)
Return lRet

/*/{Protheus.doc} persisteCadastroMonitor
Persiste o Monitor em base de dados
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method persisteCadastroMonitor() Class PCPMonitorCarga
    Local cAlias   := GetNextAlias()

    BeginSql Alias cAlias
		%noparser%
		SELECT MAX(HZE_CODIGO) AS HZE_CODIGO FROM %Table:HZE% WHERE %NotDel%
	EndSql
    If Empty((cAlias)->HZE_CODIGO)
        ::cCodigoMonitor := PadL("1", GetSx3Cache("HZE_CODIGO","X3_TAMANHO"), "0")
    Else
        ::cCodigoMonitor := Soma1(PadL((cAlias)->HZE_CODIGO, GetSx3Cache("HZE_CODIGO","X3_TAMANHO"), "0"))
    EndIf
    RecLock("HZE", .T.)
        HZE->HZE_FILIAL := xFilial("HZE")
        HZE->HZE_CODIGO := ::cCodigoMonitor
        HZE->HZE_TITULO := ::oMonitor["titulo"]
        HZE->HZE_OBJTV  := ::oMonitor["objetivo"]
        HZE->HZE_AGRUP  := ::oMonitor["agrupador"]
        HZE->HZE_APINEG := ::oMonitor["apiNegocio"]
        HZE->HZE_TIPO   := ::oMonitor["opcoesTipo"]
        HZE->HZE_TIPOGR := ::oMonitor["opcoesSubtipo"]
        HZE->HZE_PADRAO := IIF(::oMonitor["logPadrao"],"S","N")
        HZE->HZE_EXJSON := ::oExemploJson:ToJson()
        HZE->HZE_TPDETL := ::oMonitor["tipoDetalhe"]
        HZE->HZE_TPPD   := ::oMonitor["tipo"]
        HZE->HZE_TPGRPD := ::oMonitor["subtipo"]
        HZE->HZE_VERSAO := "0000000001"
        If HZE->(FieldPos("HZE_USUAR")) > 0
            HZE->HZE_USUAR  := ::oMonitor["usuario"]
            HZE->HZE_RASCUN := ::oMonitor["rascunho"]
        EndIf
    MsUnlock()
Return

/*/{Protheus.doc} setaCodigoMonitor
Atribui o codigo do Monitor
@type Method
@author renan.roeder
@since 26/09/2023
@version P12.1.2310
@param  cCodMonitor, caracter, Codigo do monitor
@return Nil
/*/
Method setaCodigoMonitor(cCodMonitor) Class PCPMonitorCarga
    ::cCodigoMonitor := cCodMonitor
Return

Method setaProprietarioMonitor(cUser) Class PCPMonitorCarga
    ::oMonitor['usuario'] := cUser
Return

Method setaRascunhoMonitor(lRascunho) Class PCPMonitorCarga
    ::oMonitor['rascunho'] := IIF(lRascunho,"S","N")
Return

/*/{Protheus.doc} recuperaCodigoMonitor
Recupera o codigo do Monitor
@type Method
@author renan.roeder
@since 26/09/2023
@version P12.1.2310
@return cCodigoMonitor, caracter, Codigo do monitor
/*/
Method recuperaCodigoMonitor() Class PCPMonitorCarga
Return ::cCodigoMonitor

/*/{Protheus.doc} persisteCadastroPropriedadesMonitor
Persiste as propriedades do Monitor em base de dados
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method persisteCadastroPropriedadesMonitor() Class PCPMonitorCarga
    Local nIndice := 0

    For nIndice := 1 To ::nNumeroPropriedadesMonitor
        RecLock("HZF", .T.)
            HZF->HZF_FILIAL := xFilial("HZF")
            HZF->HZF_CODIGO := ::aPropriedadesMonitor[nIndice]["codPropriedade"]
            HZF->HZF_MONIT  := ::cCodigoMonitor
            HZF->HZF_VALPAD := ::aPropriedadesMonitor[nIndice]["valorPadrao"]
            HZF->HZF_TITULO := ::aPropriedadesMonitor[nIndice]["titulo"]
            HZF->HZF_TIPO   := ::aPropriedadesMonitor[nIndice]["tipo"]
            HZF->HZF_TAMTXT := ::aPropriedadesMonitor[nIndice]["tamanhoTexto"]
            HZF->HZF_TAMNUM := ::aPropriedadesMonitor[nIndice]["tamanhoNumerico"]
            HZF->HZF_TAMDEC := ::aPropriedadesMonitor[nIndice]["tamanhoDecimal"]
            HZF->HZF_CLSCMP := ::aPropriedadesMonitor[nIndice]["classes"]
            HZF->HZF_ESTCMP := ::aPropriedadesMonitor[nIndice]["estilos"]
            HZF->HZF_ICNCMP := ::aPropriedadesMonitor[nIndice]["icone"]
            HZF->HZF_PRMADC := ::aPropriedadesMonitor[nIndice]["parametrosAdicionais"]
            If HZF->(FieldPos("HZF_POSIC")) > 0
                HZF->HZF_POSIC := ::aPropriedadesMonitor[nIndice]["posicao"]
            EndIf
        MsUnlock()
    Next nIndice
Return

/*/{Protheus.doc} retornaProximaPosicaoPropriedade
Retorna a pro?xima posic?a?o da propriedade
@type Method
@author renan.roeder
@since 27/09/2023
@version P12.1.2310
@param  nIndice , numerico, Posição atual
@return nPosicao, numerico, Posição da proxima propriedade
/*/
Method retornaProximaPosicaoPropriedade(nIndice) Class PCPMonitorCarga
    Local cAlias   := GetNextAlias()
    Local cMonitor := ::cCodigoMonitor
    Local nPosicao := nIndice

    If !::oMonitor["logPadrao"]
        BeginSql Alias cAlias
            SELECT 
                MAX(HZF.HZF_POSIC) AS HZF_POSIC
            FROM %Table:HZF% HZF
            WHERE HZF.HZF_FILIAL = %xFilial:HZF% 
              AND HZF.HZF_MONIT  = %exp:cMonitor%
              AND HZF.%NotDel%
        EndSql
        If (cAlias)->HZF_POSIC > 0
            nPosicao := (cAlias)->HZF_POSIC + 1
        EndIf
        (cAlias)->(DbCloseArea())
    EndIf
Return nPosicao

/*/{Protheus.doc} registraErroTransacao
Registra o log de erro no appserver desfaz o que foi gravado na base de dados
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method registraErroTransacao(oErro) Class PCPMonitorCarga

    ::cMensagemErro := oErro:Description
	LogMsg('PCPMonitorCarga', 14, 4, 1, '', '',oErro:Description + CHR(10) + oErro:ErrorStack + CHR(10) + oErro:ErrorEnv)
	If InTransact()
		DisarmTransaction()
	EndIf
Return

/*/{Protheus.doc} recuperaMensagemErro
Recupera o atributo da classe com a mensagem de erro
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method recuperaMensagemErro() Class PCPMonitorCarga
Return ::cMensagemErro

/*/{Protheus.doc} recuperaMensagemErro
Recupera o atributo da classe com a mensagem de erro
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cApiNeg, caracter, Função de negócio vinculada ao Monitor
@param  cVersao, caracter, Versão atual do Monitor
@return lRet   , logico  , Retorna verdadeiro se a carga do Monitor já foi realizada
/*/
Method monitorAtualizado(cApiNeg,cVersao) Class PCPMonitorCarga
    Local cAlias := GetNextAlias()
    Local lRet   := .F.

    Default cVersao := "0000000001"

    BeginSql Alias cAlias
		SELECT 
            COUNT(HZE.HZE_CODIGO) AS TOTAL,
            MAX(HZE.HZE_VERSAO) AS VERSAO
        FROM %Table:HZE% HZE
        WHERE HZE.HZE_FILIAL = %xFilial:HZE% 
          AND HZE.HZE_APINEG = %exp:cApiNeg% 
          AND HZE.%NotDel%
	EndSql
    If (cAlias)->TOTAL > 0 .And. (cAlias)->VERSAO == cVersao
        lRet := .T.
    EndIf
    (cAlias)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} setaPropriedadeFilial
Adiciona ao objeto de carga do Monitor a propriedade Filial
@type Method
@author renan.roeder
@since 16/08/2023
@version P12.1.2310
@param  cCodigo, caracter, Codigo da propriedade
@return Nil
/*/
Method setaPropriedadeFilial(cCodigo) Class PCPMonitorCarga
    Local oPrmAdc := JsonObject():New()
    
    oPrmAdc["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]            := JsonObject():New()
    oPrmAdc["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
    oPrmAdc["labelSelect"]                  := "Description"
    oPrmAdc["valorSelect"]                  := "Code"
    ::setaPropriedade(cCodigo,"",STR0058,7,GetSx3Cache("HZD_FILIAL","X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc) //"Filial"
    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} setaPropriedadeUsuario
Adiciona ao objeto de carga do Monitor a propriedade Usuario
@type Method
@author renan.roeder
@since 16/08/2023
@version P12.1.2310
@param  cCodigo   , caracter, Codigo da propriedade
@param  lSelecMult, logico  , Indica se a propriedade é selecção múltipla
@return Nil
/*/
Method setaPropriedadeUsuario(cCodigo,lSelecMult) Class PCPMonitorCarga
    Local oPrmAdc := JsonObject():New()

    Default lSelecMult := .F.

    oPrmAdc["filtroServico"]                 := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]             := JsonObject():New()
    oPrmAdc["parametrosServico"]["filial"]   := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
    oPrmAdc["parametrosServico"]["metodo"]   := "PCPMonitorConsultas():BuscaUsuarios"
    oPrmAdc["selecaoMultipla"]               := lSelecMult
    oPrmAdc["colunas"]                       := {}
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][1]["property"]    := "Code"
        oPrmAdc["colunas"][1]["label"]       := "Código"
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][2]["property"]    := "Description"
        oPrmAdc["colunas"][2]["label"]       := "Nome"
    oPrmAdc["labelSelect"]                   := "Code"
    oPrmAdc["valorSelect"]                   := "Code"
    ::setaPropriedade(cCodigo,"",STR0141,8,GetSx3Cache("HZA_OPERAD","X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",,,oPrmAdc) //"Operador"
    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} setaPropriedadeProduto
Adiciona ao objeto de carga do Monitor a propriedade Produto
@type Method
@author renan.roeder
@since 16/08/2023
@version P12.1.2310
@param  cCodigo   , caracter, Codigo da propriedade
@param  lSelecMult, logico  , Indica se a propriedade é selecção múltipla
@return Nil
/*/
Method setaPropriedadeProduto(cCodigo,lSelecMult) Class PCPMonitorCarga
    Local oPrmAdc := JsonObject():New()

    Default lSelecMult := .F.

    oPrmAdc["filtroServico"]               := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]           := JsonObject():New()
    oPrmAdc["parametrosServico"]["filial"] := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
    oPrmAdc["parametrosServico"]["metodo"] := "PCPMonitorConsultas():BuscaProdutos"
    oPrmAdc["selecaoMultipla"]             := lSelecMult
    oPrmAdc["colunas"]                     := {}
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][1]["property"]  := "Code"
        oPrmAdc["colunas"][1]["label"]     := GetSx3Cache("B1_COD","X3_TITULO")
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][2]["property"]  := "Description"
        oPrmAdc["colunas"][2]["label"]     := GetSx3Cache("B1_DESC","X3_TITULO")
    oPrmAdc["labelSelect"]                 := "Code"
    oPrmAdc["valorSelect"]                 := "Code"
    ::setaPropriedade(cCodigo,"",STR0074,8,GetSx3Cache("B1_COD","X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc) //"Produto"

    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} setaPropriedadeRecurso
Adiciona ao objeto de carga do Monitor a propriedade Recurso
@type Method
@author renan.roeder
@since 16/08/2023
@version P12.1.2310
@param  cCodigo   , caracter, Codigo da propriedade
@param  lSelecMult, logico  , Indica se a propriedade é selecção múltipla
@return Nil
/*/
Method setaPropriedadeRecurso(cCodigo,lSelecMult) Class PCPMonitorCarga
    Local oPrmAdc := JsonObject():New()

    Default lSelecMult := .F.

    oPrmAdc["filtroServico"]               := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]           := JsonObject():New()
    oPrmAdc["parametrosServico"]["filial"] := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
    oPrmAdc["parametrosServico"]["metodo"] := "PCPMonitorConsultas():BuscaRecursos"
    oPrmAdc["selecaoMultipla"]             := lSelecMult
    oPrmAdc["colunas"]                     := {}
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][1]["property"]  := "Code"
        oPrmAdc["colunas"][1]["label"]     := GetSx3Cache("H1_CODIGO","X3_TITULO")
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][2]["property"]  := "Description"
        oPrmAdc["colunas"][2]["label"]     := GetSx3Cache("H1_DESCRI","X3_TITULO")
    oPrmAdc["labelSelect"]                 := "Code"
    oPrmAdc["valorSelect"]                 := "Code"
    ::setaPropriedade(cCodigo,"",STR0059,8,GetSx3Cache("H1_CODIGO","X3_TAMANHO"),0,"po-sm-12 po-md-6 po-lg-6 po-xl-6",,,oPrmAdc) //"Recurso"
    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} setaPropriedadePeriodoAtual
Adiciona ao objeto de carga do Monitor a propriedade Período do tipo "atual"
@type Method
@author renan.roeder
@since 16/08/2023
@version P12.1.2310
@param  cCodigo   , caracter, Codigo da propriedade
@param  cValPad   , caracter, Valor padrão
@param  cCodigoPer, caracter, Código do período
@return Nil
/*/
Method setaPropriedadePeriodoAtual(cCodigo,cValPad,cCodigoPer) Class PCPMonitorCarga
    Local oPrmAdc := JsonObject():New()

    oPrmAdc["opcoes"] := STR0184+":D;"+STR0185+":S; "+STR0186+":Q; "+STR0187+":M; "+STR0188+":X" //"Dia Atual:D; Semana Atual:S; Quinzena Atual:Q; Mês Atual:M; Personalizado:X"
    ::setaPropriedade(cCodigo,cValPad,STR0062,4,,,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc) //"Período"
    ::setaPropriedade(cCodigoPer,"",STR0063,2,2,0,"po-sm-12 po-md-6 po-lg-6 po-xl-6") //"Período personalizado (dias)"
    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} setaPropriedadePeriodoLinhaTempo
Adiciona ao objeto de carga do Monitor a propriedade Período do tipo "linha de tempo"
@type Method
@author renan.roeder
@since 16/08/2023
@version P12.1.2310
@param  cCodigo   , caracter, Codigo da propriedade
@param  cValPad   , caracter, Valor padrão
@param  cCodigoPer, caracter, Código do período
@return Nil
/*/
Method setaPropriedadePeriodoLinhaTempo(cCodigo,cValPad,cCodPerQtd) Class PCPMonitorCarga
    Local oPrmAdc := JsonObject():New()

    oPrmAdc["opcoes"] := STR0087+":D;"+STR0088+":S;"+STR0089+":Q;"+STR0090+":M"  //"Diário:D;Semanal:S;Quinzenal:Q;Mensal:M"
    ::setaPropriedade(cCodigo,cValPad, STR0092,4,,,"po-sm-12 po-md-6 po-lg-6 po-xl-6",/*oEstilos*/,/*cIcone*/,oPrmAdc) //"Tipo Período"
    ::setaPropriedade(cCodPerQtd,"", STR0093,2,2,0,"po-sm-12 po-md-6 po-lg-6 po-xl-6") //"Quantidade de períodos"
    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} setaPropriedadeLookupTabela
Adiciona ao objeto de carga do Monitor a propriedade lookup tabela generica
@type Method
@author renan.roeder
@since 16/08/2023
@version P12.1.2310
@param  cCodigo   , caracter, Codigo da propriedade
@param  cLabel    , caracter, Label do campo
@param  lSelecMult, logico  , Indica se a propriedade é selecção múltipla
@param  cTabela   , caracter, Tabela
@param  cCampoCod , caracter, Campo código
@param  cCampoDsc , caracter, Campo descrição
@param  cClasses  , caracter, Classes
@param  oEstilos  , caracter, Estilos
@param  nPosFil   , numerico, Posição da filial no cadastro das propriedades (1-99)
@return Nil
/*/
Method setaPropriedadeLookupTabela(cCodigo,cLabel,lSelecMult,cTabela,cCampoCod,cCampoDsc,cClasses,oEstilos,nPosFil) Class PCPMonitorCarga
    Local cCampoFil := GetSx3Cache(SUBSTR(cCampoCod,1,At("_",cCampoCod)-1) + "_FILIAL","X3_CAMPO")
    Local nPosCol   := 0
    Local oPrmAdc   := JsonObject():New()

    Default cClasses := "po-sm-12 po-md-6 po-lg-6 po-xl-6", oEstilos := JsonObject():New(), nPosFil := 1

    oPrmAdc["filtroServico"]                         := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]                     := JsonObject():New()
    oPrmAdc["parametrosServico"]["filial"]           := "${this.monitor.propriedades?.["+cValToChar(nPosFil-1)+"]?.valorPropriedade}"
    oPrmAdc["parametrosServico"]["metodo"]           := "PCPMonitorConsultas():BuscaCadastroTabela"
    oPrmAdc["parametrosServico"]["tabela"]           := cTabela
    oPrmAdc["parametrosServico"]["campoCodigo"]      := cCampoCod
    oPrmAdc["parametrosServico"]["campoDescricao"]   := cCampoDsc
    oPrmAdc["selecaoMultipla"]                       := lSelecMult
    oPrmAdc["tabelaGenerica"]                        := .F.
    oPrmAdc["colunas"]                               := {}
    If !Empty(cCampoFil) .And. FWModeAccess(cTabela, 3) == 'E'
        nPosCol++
        aAdd(oPrmAdc["colunas"], JsonObject():New())
            oPrmAdc["colunas"][nPosCol]["property"]  := "Branch"
            oPrmAdc["colunas"][nPosCol]["label"]     := GetSx3Cache(cCampoFil,"X3_TITULO")
    EndIf
    nPosCol++
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][nPosCol]["property"]      := "Code"
        oPrmAdc["colunas"][nPosCol]["label"]         := GetSx3Cache(cCampoCod,"X3_TITULO")
    nPosCol++
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][nPosCol]["property"]      := "Description"
        oPrmAdc["colunas"][nPosCol]["label"]         := GetSx3Cache(cCampoDsc,"X3_TITULO")
    oPrmAdc["labelSelect"]                           := "Code"
    oPrmAdc["valorSelect"]                           := "Code"
    ::setaPropriedade(cCodigo,"",cLabel,8,GetSx3Cache(cCampoCod,"X3_TAMANHO"),0,cClasses,oEstilos,/*cIcone*/,oPrmAdc)
    FreeObj(oPrmAdc)
Return

/*/{Protheus.doc} setaPropriedadeLookupTabelaGenerica
Adiciona ao objeto de carga do Monitor a propriedade lookup tabela generica
@type Method
@author renan.roeder
@since 16/08/2023
@version P12.1.2310
@param  cCodigo   , caracter, Codigo da propriedade
@param  cLabel    , caracter, Label do campo
@param  lSelecMult, logico  , Indica se a propriedade é selecção múltipla
@param  cTabela   , caracter, Tabela
@param  cClasses  , caracter, Classes
@param  oEstilos  , caracter, Estilos
@return Nil
/*/
Method setaPropriedadeLookupTabelaGenerica(cCodigo,cLabel,lSelecMult,cTabela,cClasses,oEstilos) Class PCPMonitorCarga
    Local nPosCol   := 0
    Local oPrmAdc   := JsonObject():New()

    Default cClasses := "po-sm-12 po-md-6 po-lg-6 po-xl-6", oEstilos := JsonObject():New()

    oPrmAdc["filtroServico"]                         := "/api/pcp/v1/pcpmonitorapi/consulta"
    oPrmAdc["parametrosServico"]                     := JsonObject():New()
    oPrmAdc["parametrosServico"]["metodo"]           := "PCPMonitorConsultas():BuscaCadastroTabelaGenerica"
    oPrmAdc["parametrosServico"]["tabela"]           := cTabela
    oPrmAdc["selecaoMultipla"]                       := lSelecMult
    oPrmAdc["tabelaGenerica"]                        := .T.
    oPrmAdc["colunas"]                               := {}
    nPosCol++
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][nPosCol]["property"]      := "Code"
        oPrmAdc["colunas"][nPosCol]["label"]         := GetSx3Cache("X5_CHAVE","X3_TITULO")
    nPosCol++
    aAdd(oPrmAdc["colunas"], JsonObject():New())
        oPrmAdc["colunas"][nPosCol]["property"]      := "Description"
        oPrmAdc["colunas"][nPosCol]["label"]         := GetSx3Cache("X5_DESCRI","X3_TITULO")
    oPrmAdc["labelSelect"]                           := "Code"
    oPrmAdc["valorSelect"]                           := "Code"
    ::setaPropriedade(cCodigo,"",cLabel,8,GetSx3Cache("X5_CHAVE","X3_TAMANHO"),0,cClasses,oEstilos,/*cIcone*/,oPrmAdc)
    FreeObj(oPrmAdc)
Return
