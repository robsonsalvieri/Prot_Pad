#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSJURGARANTIA.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurGarantia
Métodos WS REST do Jurídico para Garantias.

@since 08/01/2024
/*/
//-------------------------------------------------------------------
WSRESTFUL JURGARANTIA DESCRIPTION STR0001 //"Métodos WS REST do Jurídico para Garantias"

WSDATA filAprov  AS String
WSDATA codAprov  AS String
WSDATA descAprov AS String
WSDATA pageSize   AS Number

    WSMETHOD GET hasAPI          DESCRIPTION STR0003 PATH "hasApiJurGarantia" PRODUCES APPLICATION_JSON //"Retorna se a API existe no rpo"

    WSMETHOD GET getAprovCompras DESCRIPTION STR0002 PATH "getAprovCompras"   PRODUCES APPLICATION_JSON //"Busca aprovadores de compras"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} hasAPI
Retorna se a API existe no rpo

@since 26/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET hasAPI WSREST JURGARANTIA

	Self:SetContentType("application/json")
	Self:SetResponse('{"ok":"true"}')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getAprovCompras
Busca os dados dos aprovadores

@example GET -> http://localhost:12173/rest/JURGARANTIA/getAprovCompras
/*/
//-------------------------------------------------------------------
WSMETHOD GET getAprovCompras QUERYPARAM codAprov, pageSize WSREST JURGARANTIA
Local lRet       := .T.
Local nQtdReg    := 20
Local cCodAprov  := ""
Local oResponse  := Nil

    If !Empty(Self:pageSize)
        nQtdReg := Val(Self:pageSize)
    EndIf

    If !Empty(Self:codAprov)
        cCodAprov := Self:codAprov
    EndIf

    Self:SetContentType("application/json")

    oResponse := getListaAprovadores(cCodAprov, nQtdReg)

    Self:SetResponse(oResponse:toJson())
    oResponse:fromJson("{}")
    oResponse := NIL

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getListaAprovadores
Retorna os dados dos aprovadores

@param cCodAprov - Código aprovador
@param nQtdReg   - Quantidade de registros a serem retornados

@return - json contendo o objeto dos dados
/*/
//-------------------------------------------------------------------
Static Function getListaAprovadores(cCodAprov, nQtdReg)
Local oResponse := JsonObject():New()
Local oQuery    := Nil
Local cAlias    := GetNextAlias()
Local cQuery    := ""
Local nIndex    := 0
Local aParams   := {}

Default cCodAprov  := ""
Default nQtdReg    := 20

    cQuery += " SELECT AL_COD, "
    cQuery +=        " AL_USER "
    cQuery +=   " FROM " + RetSQLName("SAL") + " SAL "
    cQuery +=  " WHERE D_E_L_E_T_ = ' ' "
    cQuery +=    " AND AL_FILIAL = ? "
    Aadd(aParams,{ "C", xFilial('SAL') })

    If !Empty(cCodAprov)
        cQuery += " AND AL_COD = ? "
        Aadd(aParams,{ "C", cCodAprov })
    EndIf

    cQuery +=  " ORDER BY AL_COD "

    cQuery := ChangeQuery( cQuery )
    oQuery := FWPreparedStatement():New(cQuery)

    oQuery := JQueryPSPr(oQuery, aParams)
    cQuery := oQuery:GetFixQuery()
    MPSysOpenQuery(cQuery, cAlias)

    oResponse["aprovCompras"] := {}

    While ( cAlias )->( !EoF() ) .AND. nIndex < nQtdReg
        nIndex++

        aAdd(oResponse["aprovCompras"], JSonObject():New())
        oResponse["aprovCompras"][nIndex]["codigo"]    := (cAlias)->AL_COD
        oResponse["aprovCompras"][nIndex]["descricao"] := UsrRetName((cAlias)->AL_USER)

        (cAlias)->(DbSkip())
    EndDo

    oQuery := Nil
    (cAlias)->( DbCloseArea() )

    oResponse['total'] := Len(oResponse["aprovCompras"])

Return oResponse
