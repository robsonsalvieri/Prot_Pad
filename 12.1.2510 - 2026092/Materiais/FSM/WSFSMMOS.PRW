#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFSMMOS
    Métodos REST para novo app "Meu Técnico"

    @since 02/09/2026
    @version 1.0
    @author Silas Gomes

/*/
//-------------------------------------------------------------------
WSRESTFUL FSMMOS DESCRIPTION "WebService REST para o aplicativo 'Meu Técnico'"

    WSDATA cCodJn3 AS STRING

    WSMETHOD GET historico DESCRIPTION "Retorna o histórico de equipamentos" PATH "historico" PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} historico
    Retorna o histórico de equipamentos, incluindo laudos, checklists e peças solicitadas.

    @since 02/09/2026
    @version 1.0
    @author Silas Gomes

/*/
//-------------------------------------------------------------------
WSMETHOD GET historico WSRECEIVE cCodJn3 WSREST FSMMOS

    Local lRet      as logical
    Local oResponse as object
    Local oQuery    as object
    Local cQuery    as character
    Local cAlias    as character
    Local cMensagem as character
    Local nX        as numeric

    lRet      := .T.
    oResponse := JsonObject():New()
    oQuery    := Nil
    cQuery    := ""
    cAlias    := GetNextAlias()
    cMensagem := ""
    nX        := 0

    If Empty(Self:cCodJn3)
        lRet      := .F.
        cMensagem := "Código da O.S. não informado"
    EndIf

    If lRet

        cQuery := " SELECT "
        cQuery += " JN3.JN3_CODIGO OS, "
        cQuery += " CONCAT(JN6.JN6_DTINI, ' - ', "
        cQuery += " JN6.JN6_DTFIM) PERIODO, "
        cQuery += " CONCAT(JN6.JN6_HRINI, ' - ', "
        cQuery += " JN6.JN6_HRFIM) HORARIO, "
        cQuery += " CONCAT(JN6.JN6_CODAA1, ' - ', "
        cQuery += " AA1.AA1_NOMTEC) TECNICO, "
        cQuery += " JN3.JN3_CODPRO EQUIPAMENTO, "
        cQuery += " JN3.JN3_NUMSER ID_UNICO, "
        cQuery += " JN3.JN3_CODJOK TIPO_OCORRENCIA, "
        cQuery += " JOK.JOK_DESCRI DESC_OCORRENCIA, "
        cQuery += " JN3.JN3_SITUAC STATUS, "
        cQuery += " JN6.JN6_CODIGO ATENDIMENTO"
        cQuery += " FROM " + RetSqlName("JN3") + " JN3 "
        cQuery += " INNER JOIN " + RetSqlName("JN6") + " JN6 "
        cQuery += "    ON JN6.JN6_FILIAL = ? "
        cQuery += "   AND JN6.JN6_CODJN3 = JN3.JN3_CODIGO "
        cQuery += "   AND JN6.D_E_L_E_T_ = ? "
        cQuery += " LEFT JOIN " + RetSqlName("AA1") + " AA1 "
        cQuery += "    ON AA1.AA1_FILIAL = ? "
        cQuery += "   AND AA1.AA1_CODTEC = JN6.JN6_CODAA1 "
        cQuery += "   AND AA1.D_E_L_E_T_ = ? "
        cQuery += " LEFT JOIN " + RetSqlName("JOK") + " JOK "
        cQuery += "    ON JOK.JOK_FILIAL = ? "
        cQuery += "   AND JOK.JOK_CODIGO = JN3.JN3_CODJOK "
        cQuery += "   AND JOK.D_E_L_E_T_ = ? "
        cQuery += " WHERE JN3.JN3_FILIAL = ? "
        cQuery += "   AND JN3.D_E_L_E_T_ = ? "
        cQuery += "   AND JN3.JN3_CODIGO = ? "
        cQuery += " ORDER BY JN6.JN6_CODIGO "

        cQuery := ChangeQuery(cQuery)
        oQuery := FWPreparedStatement():New(cQuery)

        oQuery:SetString(1, xFilial("JN6"))
        oQuery:SetString(2, " ")
        oQuery:SetString(3, xFilial("AA1"))
        oQuery:SetString(4, " ")
        oQuery:SetString(5, xFilial("JOK"))
        oQuery:SetString(6, " ")
        oQuery:SetString(7, xFilial("JN3"))
        oQuery:SetString(8, " ")
        oQuery:SetString(9, Self:cCodJn3)

        cAlias := MPSysOpenQuery(oQuery:GetFixQuery())

        If (cAlias)->(!Eof())

            oResponse["historico"] := {}

            Do While (cAlias)->(!Eof())
                AAdd(oResponse["historico"], JsonObject():New())
                nX++
                oResponse["historico"][nX]["os"] := AllTrim((cAlias)->OS)
                oResponse["historico"][nX]["periodo"] := AllTrim((cAlias)->PERIODO)
                oResponse["historico"][nX]["horario"] := AllTrim((cAlias)->HORARIO)
                oResponse["historico"][nX]["tecnico"] := AllTrim((cAlias)->TECNICO)
                oResponse["historico"][nX]["equipamento"] := AllTrim((cAlias)->EQUIPAMENTO)
                oResponse["historico"][nX]["id_unico"] := AllTrim((cAlias)->ID_UNICO)
                oResponse["historico"][nX]["tipo_ocorrencia"] := AllTrim((cAlias)->TIPO_OCORRENCIA)
                oResponse["historico"][nX]["desc_ocorrencia"] := EncodeUTF8(AllTrim((cAlias)->DESC_OCORRENCIA))
                oResponse["historico"][nX]["status_os"] := AllTrim((cAlias)->STATUS)
                oResponse["historico"][nX]["atendimento"] := AllTrim((cAlias)->ATENDIMENTO)
                oResponse["historico"][nX]["laudos"] := GetLaudos(AllTrim((cAlias)->OS), AllTrim((cAlias)->ATENDIMENTO))
                oResponse["historico"][nX]["checklists"] := GetChecks(AllTrim((cAlias)->OS), AllTrim((cAlias)->ATENDIMENTO))
                oResponse["historico"][nX]["pecas_solicitadas"] := GetPecas(AllTrim((cAlias)->OS))

                (cAlias)->(DbSkip())
            EndDo

        Else
            lRet := .F.
            oResponse["errorCode"] := 400
            oResponse["errorMessage"] := EncodeUTF8("Não foram localizados registros")
        EndIf

        If Select(cAlias) > 0
            (cAlias)->(DbCloseArea())
        EndIf

        If ValType(oQuery) == "O"
            oQuery:Destroy()
            FreeObj(oQuery)
            oQuery := Nil
        EndIf

    Else
        oResponse["errorCode"] := 400
        oResponse["errorMessage"] := EncodeUTF8(cMensagem)
    EndIf

    ::SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLaudos
    Retorna todos os laudos vinculados ao atendimento.

    @since 02/09/2026
    @version 1.0
    @author Silas Gomes

/*/
//-------------------------------------------------------------------
Static Function GetLaudos(cCodJn3 as character, cCodJn6 as character)

    Local aLaudos as array
    Local oLaudo  as object
    Local oQuery  as object
    Local cQuery  as character
    Local cAlias  as character

    aLaudos := {}
    oLaudo  := Nil
    oQuery  := Nil
    cQuery  := ""
    cAlias  := GetNextAlias()

    cQuery := " SELECT "
    cQuery += " JNY.JNY_CODIGO CODIGO, "
    cQuery += " JNY.JNY_DESCRI DESCRICAO "
    cQuery += " FROM " + RetSqlName("JNY") + " JNY "
    cQuery += " WHERE JNY.JNY_FILIAL = ? "
    cQuery += "   AND JNY.JNY_CODJN3 = ? "
    cQuery += "   AND JNY.JNY_CODJN6 = ? "
    cQuery += "   AND JNY.D_E_L_E_T_ = ? "

    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, xFilial("JNY"))
    oQuery:SetString(2, cCodJn3)
    oQuery:SetString(3, cCodJn6)
    oQuery:SetString(4, " ")

    cAlias := MPSysOpenQuery(oQuery:GetFixQuery())

    Do While (cAlias)->(!Eof())
        oLaudo := JsonObject():New()
        oLaudo["codigo"] := AllTrim((cAlias)->CODIGO)
        oLaudo["descricao"] := EncodeUTF8(AllTrim((cAlias)->DESCRICAO))
        AAdd(aLaudos, oLaudo)
        (cAlias)->(DbSkip())
    EndDo

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf

    If ValType(oQuery) == "O"
        oQuery:Destroy()
        FreeObj(oQuery)
        oQuery := Nil
    EndIf

Return aLaudos

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChecks
    Retorna todos os checklists vinculados ao atendimento.

    @since 02/09/2026
    @version 1.0
    @author Silas Gomes

/*/
//-------------------------------------------------------------------
Static Function GetChecks(cCodJn3 as character, cCodJn6 as character)

    Local aChecks as array
    Local oCheck  as object
    Local oQuery  as object
    Local cQuery  as character
    Local cAlias  as character

    aChecks := {}
    oCheck  := Nil
    oQuery  := Nil
    cQuery  := ""
    cAlias  := GetNextAlias()

    cQuery := " SELECT "
    cQuery += " JNR.JNR_CODIGO CODIGO, "
    cQuery += " JNR.JNR_CODJN3 OS, "
    cQuery += " JNR.JNR_CODJNN CODJNN, "
    cQuery += " JNR.JNR_CODJND CODJND, "
    cQuery += " JNR.JNR_STATUS STATUS, "
    cQuery += " JND.JND_TITULO DESCRICAO "
    cQuery += " FROM " + RetSqlName("JNR") + " JNR "
    cQuery += " LEFT JOIN " + RetSqlName("JND") + " JND "
    cQuery += "    ON JND.JND_FILIAL = ? "
    cQuery += "   AND JND.JND_CODIGO = JNR.JNR_CODJND "
    cQuery += "   AND JND.JND_STATUS = ?"
    cQuery += "   AND JND.D_E_L_E_T_ = ? "
    cQuery += " WHERE JNR.JNR_FILIAL = ? "
    cQuery += "   AND JNR.JNR_CODJN3 = ? "
    cQuery += "   AND JNR.JNR_CODJN6 = ? "
    cQuery += "   AND JNR.D_E_L_E_T_ = ? "

    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, xFilial("JND"))
    oQuery:SetString(2, '2')
    oQuery:SetString(3, " ")
    oQuery:SetString(4, xFilial("JNR"))
    oQuery:SetString(5, cCodJn3)
    oQuery:SetString(6, cCodJn6)
    oQuery:SetString(7, " ")

    cAlias := MPSysOpenQuery(oQuery:GetFixQuery())

    Do While (cAlias)->(!Eof())
        oCheck := JsonObject():New()
        oCheck["codigo"] := (cAlias)->CODIGO
        oCheck["os"] := (cAlias)->OS
        oCheck["codjnn"] := (cAlias)->CODJNN
        oCheck["codjnd"] := (cAlias)->CODJND
        oCheck["status_chk"] := (cAlias)->STATUS
        oCheck["descricao"] := EncodeUTF8(AllTrim((cAlias)->DESCRICAO))
        AAdd(aChecks, oCheck)
        (cAlias)->(DbSkip())
    EndDo

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf

    If ValType(oQuery) == "O"
        oQuery:Destroy()
        FreeObj(oQuery)
        oQuery := Nil
    EndIf

Return aChecks

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPecas
    Retorna todas as peças solicitadas vinculadas ao atendimento.

    @since 03/09/2026
    @version 1.0
    @author Silas Gomes
/*/
//-------------------------------------------------------------------
Static Function GetPecas(cCodJn3 as character)

    Local aPecas as array
    Local oPeca  as object
    Local oQuery as object
    Local cQuery as character
    Local cAlias as character

    aPecas := {}
    oPeca  := Nil
    oQuery := Nil
    cQuery := ""
    cAlias := GetNextAlias()

    cQuery := " SELECT "
    cQuery += " JO4.JO4_CODJN3 OS, "
    cQuery += " JO4.JO4_CODJN6 ATENDIMENTO, "
    cQuery += " JO4.JO4_CODPRO PRODUTO, "
    cQuery += " JO4.JO4_QTDPRO QUANTIDADE, "
    cQuery += " JO4.JO4_STATUS STATUS, "
    cQuery += " SB1.B1_DESC DESCRICAO "
    cQuery += " FROM " + RetSqlName("JO4") + " JO4 "
    cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
    cQuery += " ON SB1.B1_FILIAL = ? "
    cQuery += " AND SB1.B1_COD = JO4.JO4_CODPRO "
    cQuery += " AND SB1.D_E_L_E_T_ = ? "
    cQuery += " WHERE JO4.JO4_FILIAL = ? "
    cQuery += "   AND JO4.JO4_CODJN3 = ? "
    cQuery += "   AND JO4.D_E_L_E_T_ = ? "

    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, xFilial("SB1"))
    oQuery:SetString(2, " ")
    oQuery:SetString(3, xFilial("JO4"))
    oQuery:SetString(4, cCodJn3)
    oQuery:SetString(5, " ") 

    cAlias := MPSysOpenQuery(oQuery:GetFixQuery())

    Do While (cAlias)->(!Eof())

        oPeca := JsonObject():New()
        oPeca["os"] := AllTrim((cAlias)->OS)
        oPeca["atendimento"] := AllTrim((cAlias)->ATENDIMENTO)
        oPeca["produto"] := AllTrim((cAlias)->PRODUTO)
        oPeca["quantidade"] := (cAlias)->QUANTIDADE
        oPeca["status_pecas"] := (cAlias)->STATUS
        oPeca["descricao"] := AllTrim((cAlias)->DESCRICAO)

        AAdd(aPecas, oPeca)

        (cAlias)->(DbSkip())

    EndDo

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf

    If ValType(oQuery) == "O"
        oQuery:Destroy()
        FreeObj(oQuery)
        oQuery := Nil
    EndIf

Return aPecas
