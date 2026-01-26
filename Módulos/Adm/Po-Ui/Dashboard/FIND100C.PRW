#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "FIND100C.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100CNat

API de integração de Painéis de Saldo po Natureza

@author		Francisco Oliveira
@since		24/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

//SUBIDA PARA O D-1 EM 08/06/2021

WSRESTFUL FD100CNat DESCRIPTION "Saldo Por Natureza"
	WSDATA Fields	As Character	OPTIONAL
	WSDATA Order	As Character	OPTIONAL
	WSDATA Page		AS INTEGER  OPTIONAL
	WSDATA PageSize AS INTEGER  OPTIONAL
	WSDATA Code		As Character	OPTIONAL
    WSDATA idCard   As Character	OPTIONAL

    WSMETHOD POST itemsDetails ;
    DESCRIPTION "Carrega os Itens Utilizados para Montagem do Painel" ;
    WSSYNTAX "/cards/itemsDetails/{idCard}/{Order, Page, PageSize, Fields}" ;
    PATH "/cards/itemsDetails/{idCard}";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET headerItens ;
    DESCRIPTION "Carrega os Cabeçalhos a serem apresentados nos detalhes" ;
    WSSYNTAX "/cards/headerItens/" ;
    PATH "/cards/headerItens";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET cardInfo ;
    DESCRIPTION "Carrega as informações do Painel" ;
    WSSYNTAX "/cards/cardInfo/{idCard}" ;
    PATH "/cards/cardInfo/{idCard}";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET fieldsInfo ;
    DESCRIPTION "Carrega os campos que podem que ser utilizados" ;
    WSSYNTAX "/cards/fieldsInfo/{idCard}" ;
    PATH "/cards/fieldsInfo/{idCard}";
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
Carrega os Itens Utilizados para Montagem do Painel

@author		Francisco Oliveira
@since		24/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD POST itemsDetails PATHPARAM idCard WSRECEIVE Order, Page, PageSize, Fields WSSERVICE FD100CNat

    Local aHeader   AS Array
    Local aItems    AS Array
    Local aRet      AS Array
    Local aRetDatas AS Array
    Local aFilter   AS Array
    Local cBody     As Character
    Local cError    As Character
    Local cDtAux    As Character
    Local cMoeda    As Character
    Local dDataIni  As Character
    Local dDataFim  As Character
    Local idCard    As Character
    Local cAliasQry As Character
    Local lRet	    AS Logical
    Local lTable    AS Logical
    Local lOrderBy  AS Logical
    Local nCount    As Numeric
    Local nPage     As Numeric
    Local nPageSize As Numeric
    Local oBody     AS Object
    Local oCoreDash AS Object
    Local oJsonDD   AS Object

    aHeader   := {}
    aItems    := {}
    aRet      := {}
    aRetDatas := {}
    aFilter   := {}
    cBody     := IIF( Self:GetContent() == Nil, '', DecodeUtf8(Self:GetContent()))
    cError	  := "Erro na Requisição"
    lRet	    := .T.
    lTable    := .F.
    lOrderBy  := .T.
    oBody     := JsonObject():New()
    oCoreDash := CoreDash():New()
    oJsonDD   := JsonObject():New()
    dDataIni  := ""
    dDataFim  := ""
    cAliasQry := ""
    idCard    := self:idCard
    cDtAux    := ""
    cMoeda    := "01"
    nCount    := 1
    nPage     := 1
    nPageSize := 10

    Self:SetContentType("application/json")

    If !Empty(cBody)
        oBody:FromJson(cBody)
        If ValType(oBody["detailFilter"]) == "A"
            oJsonDD := oBody["detailFilter"]
        EndIf
    EndIf

    oCoreDash:SetFields(DePara())
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()

    aRetDatas := retDatas(aFilter)
    dMesIni   := aRetDatas[1]
    dAnoIni   := aRetDatas[2]
    dAnoFim   := aRetDatas[3]
    nPeriodo  := aRetDatas[4]

    dDataIni := dAnoIni + dMesIni + "01"
    dDataFim := DtoS(MonthSum(LastDate(StoD(dDataIni)), nPeriodo - 1))

    If Len(oJsonDD) == 0
        aHeader := FD100LHeNa( ,cMoeda)
        aItems  := FD100LItNa()

        oCoreDash:SetFields(aItems)
        oCoreDash:SetApiQstring(Self:aQueryString)
        aFilter  := oCoreDash:GetApiFilter()
        lOrderBy := Empty(oCoreDash:GetOrderBy())

        If idCard = "previsto"
          aRet := FD100LCard(dDataIni, dDataFim, "2", aFilter, lOrderBy )
        Else
          aRet := FD100LCard(dDataIni, dDataFim, "3", aFilter, lOrderBy )
        Endif
    ElseIf Len(oJsonDD) == 1
        cOrigem := oJsonDD[1]['tpmovto']
        cNatur  := oJsonDD[1]['codnatur']

        aItems  := FD100LItPR(Iif(cOrigem = "Receita", "SE1", "SE2"))
        aHeader := FD100LHePR()

        oCoreDash:SetFields(aItems)
        oCoreDash:SetApiQstring(Self:aQueryString)
        aFilter  := oCoreDash:GetApiFilter()

        For nCount := 1 to Len(Self:aQueryString)
            Do Case
                Case Upper(Self:aQueryString[nCount][1]) == "PAGE"
                    nPage := Self:aQueryString[nCount][2]
                
                Case Upper(Self:aQueryString[nCount][1]) == "PAGESIZE"
                    nPageSize := Self:aQueryString[nCount][2]
            EndCase
        Next nCount

        cAliasQry   := FD100LQyPR(cOrigem, cNatur, dDataIni, dDataFim, aFilter, nPage, nPageSize)
        lTable  := .T.
    Endif

    If !lTable
        oCoreDash:SetQuery(aRet[1])
        oCoreDash:SetWhere(aRet[2])
        oCoreDash:SetGroupBy(aRet[3])
    Else
        oCoreDash:SetTable(cAliasQry)
    Endif
    oCoreDash:BuildJson()

	If lRet
        oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson())
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()
    FreeObj(aRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET headerItens
Retorna o aHeader que será utilizado no detalhamento do Painel

@author		Francisco Oliveira
@since		24/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD GET headerItens WSSERVICE FD100CNat

    Local aHeader   AS Array
    Local oCoreDash AS Object
    Local oResponse	AS Object

    aHeader   := {}
    oCoreDash := CoreDash():New()
    oResponse := JsonObject():New()

    aHeader := {{"dtvencrea", STR0001 }} // "Data da Movimentação"

    oResponse["items"] := oCoreDash:SetPOHeader(aHeader)

    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET cardInfo
Método para retornar os dados do Painel

@author		Francisco Oliveira
@since		24/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD GET cardInfo PATHPARAM idCard WSRESTFUL FD100CNat

    Local aFilter   AS Array
    Local idCard    As Character
    Local lRet		AS Logical
    Local oCoreDash AS Object
    Local oResponse AS Object

    aFilter   := {}
    idCard    := self:idCard
    lRet	  := .T.
    oCoreDash := CoreDash():New()
    oResponse := JsonObject():New()

    oCoreDash:SetFields(DePara())
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()

    RetCardInfo( @oResponse, idCard, aFilter )

    self:SetResponse( EncodeUtf8(FwJsonSerialize(oResponse,.T.,.T.)) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	// Telemetria - Uso da classe FWLsPutAsyncInfo                  //
	// Mecanismo para registro de métricas e envio                  //
	// das mesmas ao License Serve da Totvs                         //
	//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

	FWLsPutAsyncInfo("LS006",RetCodUsr(),"06","FIND100C")

    oResponse := Nil
    FreeObj( oResponse )
    oCoreDash := Nil
    FreeObj( oCoreDash )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GET fieldsInfo
Carrega os campos que podem que ser utilizados

@author		Francisco Oliveira
@since		24/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD GET fieldsInfo PATHPARAM idCard WSSERVICE FD100CNat

    Local aItems    AS Array
    Local item      AS Array
    Local aBase     AS Array
    Local nJ        AS Numeric
    Local oResponse	AS Object
    Local idCard    As Character

    aItems    := {}
    item      := {}
    aBase     := {}
    nJ        := 0
    oResponse	:= JsonObject():New()
    idCard    := self:idCard

    If idCard = "previsto"
        Aadd(aBase, {STR0002 + " :", "prevreceita"}) // "Previsto Receita:"
        Aadd(aBase, {STR0003 + " :", "prevdespesa"}) // "Previsto Despesa:"
    Else
        Aadd(aBase, {STR0004 + " :", "realreceita"}) // "Realizado Receita:"
        Aadd(aBase, {STR0005 + " :", "realdespesa"}) // "Realizado Despesa:"
    Endif

    For nJ := 1 To Len(aBase)
        item := JsonObject():New()
        item["label"] := abase[nJ][1]
        item["value"] := abase[nJ][2]
        AADD(aItems, item)
    Next nJ

    oResponse["items"]  := aItems

    Self:SetResponse( oResponse:ToJson())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET headerItens
Retorna o aHeader que será utilizado no detalhamento do Painel

@author		Francisco Oliveira
@since		24/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function DePara() AS Array

Local aCampos   AS Array

aCampos := {{"dtvencrea", "E1_VENCREA" }}

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RetCardInfo
Retorna os dados que poderão ser apresentados no painel

@author		Francisco Oliveira
@since		24/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function RetCardInfo( oResponse, idCard, aFilter )

    Local item      AS Object
    Local aItems    AS Array
    Local aRetDatas AS Array
    Local aRetVlr   AS Array
    Local dMesIni   As Character
    Local dAnoIni   As Character
    Local dAnoFim   As Character
    Local cMoeda    As Character
    Local cPict     As Character
    Local cSimbMoe  As Character
    Local nPeriodo  AS Numeric
    Local nAux      AS Numeric
    Local nY        AS Numeric

    item    := JsonObject():New()
    aItems  := {}
    aRetVlr := {}
    cMoeda  := "01"
    cPict   := "@E 9,999,999,999.99"
    cSimbMoe:= SuperGetMV("MV_SIMB1")
    nAux    := 0
    nY      := 0

    aRetDatas := retDatas(aFilter)
    dMesIni   := aRetDatas[1]
    dAnoIni   := aRetDatas[2]
    dAnoFim   := aRetDatas[3]
    nPeriodo  := aRetDatas[4]

    If idCard = "previsto"
        nAux := 0
        aRetVlr := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "2")
        For nY := 1 To Len(aRetVlr)
            nAux += aRetVlr[nY]
        Next nY
        item["prevreceita"]  :=	cSimbMoe + ' ' +  Alltrim(Transform(nAux,cPict))

        nAux := 0
        aRetVlr := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "2")
        For nY := 1 To Len(aRetVlr)
            nAux += aRetVlr[nY]
        Next nY
        item["prevdespesa"]  :=	cSimbMoe + ' ' +  Alltrim(Transform(nAux,cPict))
        nAux := 0
    Else
        nAux := 0
        aRetVlr := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "3")
        For nY := 1 To Len(aRetVlr)
            nAux += aRetVlr[nY]
        Next nY
        item["realreceita"]  :=	cSimbMoe + ' ' +  Alltrim(Transform(nAux,cPict))

        nAux := 0
        aRetVlr := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "3")
        For nY := 1 To Len(aRetVlr)
            nAux += aRetVlr[nY]
        Next nY
        item["realdespesa"]  :=	cSimbMoe + ' ' +  Alltrim(Transform(nAux,cPict))
        nAux := 0
    Endif

    nAux := 0

    AADD(aItems, item)

    item := {}

    oResponse['hasNext']    := 'false'
    oResponse["items"]      := aItems

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RetCardInfo
Retorna os dados que poderão ser apresentados no painel

@author		Francisco Oliveira
@since		24/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function retDatas(aFilter AS Array) AS Array

    Local dMesIni   As Character
    Local dAnoIni   As Character
    Local dAnoFim   As Character
    Local nPeriodo  AS Numeric
    Local nPos1     As Numeric
    Local nPos2     As Numeric

    Default aFilter := {}

    dMesIni     := ""
    dAnoIni     := ""
    dAnoFim     := ""
    nPeriodo    := 0
    nPos1       := 0
    nPos2       := 0

    If Len(aFilter) > 0
        nPos1 := 12
        While !(SubStr(aFilter[1,1], nPos1, 1) $ '0123456789')
            nPos1++
        EndDo
        dMesIni  := substr(aFilter[1][1], nPos1 + 4 ,2)
        dAnoIni  := substr(aFilter[1][1], nPos1 ,4)

        If Len(aFilter) = 2
            dAnoFim  := dAnoIni
            nPos2 := 12
            While !(SubStr(aFilter[2,1], nPos2, 1) $ '0123456789')
                nPos2++
            EndDo
            nPeriodo := (DateDiffMonth(StoD(substr(aFilter[2][1], nPos2,8)),StoD(substr(aFilter[1][1], nPos1,8))) + 1)
        Else
            dAnoFim  := dAnoIni
            nPeriodo := 1
        Endif
    Else
        dMesIni  := Month2Str(Date())
        dAnoIni  := Year2Str(Date())
        dAnoFim  := dAnoIni
        nPeriodo := 1
    Endif

Return {dMesIni, dAnoIni, dAnoFim, nPeriodo}

/*
Exemplo de Função para personalização de filtro do Card.
User Function Operador(nPos)

Local aRetorno      := {}
Local cOperador     := ""
Local xVlrFiltro    := ""

Default nPos        := 0

If nPos == 1
    cOperador   := ">="
    xVlrFiltro  := '20200101'
Else
    cOperador   := "<="
    xVlrFiltro  := '20201231'
Endif

Aadd(aRetorno, cOperador)
Aadd(aRetorno, xVlrFiltro)

Return aRetorno
*/
