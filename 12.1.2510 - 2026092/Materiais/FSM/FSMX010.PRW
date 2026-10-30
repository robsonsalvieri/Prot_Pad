#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmAgendaAtendimentos()
Função que retornar a agenda dos atendimentos 
@author fernanda.rigolin
@since 28/07/2026
@version 1.0
*/
//-------------------------------------------------------------------
Function fsmxageatd(oRequest, oResponse, cMsgRet)

    Local lRet := .T.
    Local oMapDatas := JsonObject():New()

    Local cDataInicio := ""
    Local cDataFinal  := ""

    oResponse["items"] := {}
    oResponse["total"] := 0

    cDataInicio := oRequest["dataInicio"]
    cDataFinal  := oRequest["dataFinal"]

    If Empty(cDataInicio)
    	SetRestFault(404, EncodeUtf8("Data Início não informada"))
    	Return .F.
    Endif	

    If Empty(cDataFinal)
    	SetRestFault(404, EncodeUtf8("Data Final não informada"))
    	Return .F.
    Endif		

    CarregaAgenda(;
        cDataInicio,;
        cDataFinal,;
        oMapDatas,;
        oResponse)

Return lRet

Static Function GetData(oMapDatas, oResponse, cData)

    Local oData := Nil
    Local nPos  := 0

    If oMapDatas:HasProperty(cData)
        nPos := oMapDatas[cData]
        Return oResponse["items"][nPos]
    EndIf

    oData := JsonObject():New()

    oData["data"] := cData
    oData["atendimentos"] := {}

    AAdd(oResponse["items"], oData)
    oMapDatas[cData] := Len(oResponse["items"])
Return oData


Static Function CarregaAgenda(;
    cDataInicio,;
    cDataFinal,;
    oMapDatas,;
    oResponse)

    Local cAlias  := GetNextAlias()
    Local cQuery  := ""
    Local oQryTmp := Nil

    Local nParam  := 1

    Local oItem   := Nil
    Local oData   := Nil
    Local cData   := ""
    Local cBanco  := AllTrim(TcGetDB())    

    cQuery += " SELECT "

    cQuery += "     JN3.JN3_CODIGO, "
	cQuery += "     JN3.JN3_FILIAL, "
    cQuery += "     JN3.JN3_DTPREV, "
    cQuery += "     JN3.JN3_CLIENT, "
    cQuery += "     JN3.JN3_LOJA, "
    cQuery += "     COALESCE(JN6.JN6_PRIORI, JN3.JN3_PRIORI) AS PRIORIDADE_ATEND, "
    cQuery += "     JN3.JN3_SITUAC, "

    cQuery += "     JN3.JN3_END, "
    cQuery += "     JN3.JN3_COMPL, "
    cQuery += "     JN3.JN3_BAIRRO, "
    cQuery += "     JN3.JN3_ESTADO, "

    cQuery += "     JN4.JN4_CODIGO, "
    cQuery += "     JN4.JN4_CODJN1, "
    cQuery += "     JN1.JN1_DESCRI, "    

    cQuery += "     JOK.JOK_CODIGO, "
    cQuery += "     JOK.JOK_DESCRI, "

    cQuery += "     JOJ.JOJ_CODIGO, "
    cQuery += "     JOJ.JOJ_DESCRI, "

    cQuery += "     SA1.A1_NOME, "
    cQuery += "     SA1.A1_ESTADO, "

    cQuery += "     JN6.JN6_CODIGO, "
	cQuery += "     JN6.JN6_FILIAL, "
    cQuery += "     JN6.JN6_DTINI, "
    cQuery += "     JN6.JN6_DTFIM, "
    cQuery += "     JN6.JN6_HRINI, "
    cQuery += "     JN6.JN6_HRFIM, "
    cQuery += "     JN6.JN6_CODAA1, "
    cQuery += "     JN6.JN6_SITUAC, "

    cQuery += "     AA1.AA1_CODTEC, "
    cQuery += "     AA1.AA1_NOMTEC, "

    cQuery += "     JNJ.JNJ_DTINI    AS HIST_DTINI, "
    cQuery += "     JNJ.JNJ_HRINI    AS HIST_HRINI, "
    cQuery += "     JNJ.JNJ_SITUAC    AS HIST_SITUAC, "

    If cBanco == 'MSSQL'
        cQuery += " CAST(JNJ.JNJ_JUSTIF AS VARCHAR(MAX)) HIST_JUSTIF "
    ElseIf cBanco == 'ORACLE'
        cQuery += " TO_CHAR(JNJ.JNJ_JUSTIF) HIST_JUSTIF "
    ElseIf cBanco == 'POSTGRES'
        cQuery += " CAST(JNJ.JNJ_JUSTIF AS TEXT) HIST_JUSTIF "
    Endif

    cQuery += " FROM " + RetSqlName("JN3") + " JN3 "

    cQuery += " INNER JOIN " + RetSqlName("JN4") + " JN4 "
    cQuery += "      ON JN4.JN4_FILIAL = ? "
    cQuery += "     AND JN4.JN4_CODJN3 = JN3.JN3_CODIGO "
    cQuery += "     AND JN4.D_E_L_E_T_ = ' ' "

    cQuery += " INNER JOIN " + RetSqlName("JN1") + " JN1 "
    cQuery += "      ON JN1.JN1_FILIAL = ? "
    cQuery += "     AND JN4.JN4_CODJN1 = JN1.JN1_CODIGO "
    cQuery += "     AND JN1.D_E_L_E_T_ = ' ' "    

    cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
    cQuery += "      ON SA1.A1_FILIAL = ? "
    cQuery += "     AND SA1.A1_COD = JN3.JN3_CLIENT "
    cQuery += "     AND SA1.A1_LOJA = JN3.JN3_LOJA "
    cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("JN6") + " JN6 "
    cQuery += "      ON JN6.JN6_FILIAL = ? "
    cQuery += "     AND JN6.JN6_CODJN4 = JN4.JN4_CODIGO "
    cQuery += "     AND JN6.D_E_L_E_T_ = ' ' "

    cQuery += " INNER JOIN " + RetSqlName("JOK") + " JOK "
    cQuery += "      ON JOK.JOK_FILIAL = ? "
    cQuery += "     AND JOK.JOK_CODIGO = COALESCE(JN6.JN6_CODJOK,JN3.JN3_CODJOK) "
    cQuery += "     AND JOK.D_E_L_E_T_ = ' ' "

    cQuery += " INNER JOIN " + RetSqlName("JOJ") + " JOJ "
    cQuery += "      ON JOJ.JOJ_FILIAL = ? "
    cQuery += "     AND JOJ.JOJ_CODIGO = COALESCE(JN6.JN6_CODJOJ,JN3.JN3_CODJOJ) "
    cQuery += "     AND JOJ.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("AA1") + " AA1 "
    cQuery += "      ON AA1.AA1_FILIAL = ? "
    cQuery += "     AND AA1.AA1_CODTEC = JN6.JN6_CODAA1 "
    cQuery += "     AND AA1.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("JNJ") + " JNJ "
    cQuery += "      ON JNJ.JNJ_FILIAL = JN6.JN6_FILIAL "
    cQuery += "     AND JNJ.JNJ_CODJN6 = JN6.JN6_CODIGO "
    cQuery += "     AND JNJ.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("JNJ") + " JNJ2 "
    cQuery += "      ON JNJ2.JNJ_FILIAL = JNJ.JNJ_FILIAL "
    cQuery += "     AND JNJ2.JNJ_CODJN6 = JNJ.JNJ_CODJN6 "
    cQuery += "     AND JNJ2.JNJ_CODIGO > JNJ.JNJ_CODIGO "
    cQuery += "     AND JNJ2.D_E_L_E_T_ = ' ' "    

    cQuery += " WHERE "
    cQuery += "      JN3.D_E_L_E_T_ = ' ' "
    cQuery += "  AND JN3.JN3_FILIAL = ? "

    cQuery += " AND ( "
    cQuery += "      (JN6.JN6_DTINI IS NOT NULL "
    cQuery += "       AND JN6.JN6_DTINI BETWEEN ? AND ?) "
    cQuery += "   OR "
    cQuery += "      (JN6.JN6_DTINI IS NULL "
    cQuery += "       AND JN3.JN3_DTPREV BETWEEN ? AND ?) "
    cQuery += " ) "
    cQuery += " AND JNJ2.JNJ_CODIGO IS NULL "

    cQuery += " ORDER BY "
    cQuery += "     COALESCE(JN6.JN6_DTINI,JN3.JN3_DTPREV), "
    cQuery += "     JN6.JN6_HRINI, "
    cQuery += "     JN3.JN3_CODIGO "

    oQryTmp := FWPreparedStatement():New(cQuery)

    oQryTmp:SetString(nParam++, xFilial("JN4"))
    oQryTmp:SetString(nParam++, xFilial("JN1"))
    oQryTmp:SetString(nParam++, xFilial("SA1"))
    oQryTmp:SetString(nParam++, xFilial("JN6"))
    oQryTmp:SetString(nParam++, xFilial("JOK"))
    oQryTmp:SetString(nParam++, xFilial("JOJ"))
    oQryTmp:SetString(nParam++, xFilial("AA1"))

    oQryTmp:SetString(nParam++, xFilial("JN3"))

    oQryTmp:SetDate(nParam++, StoD(cDataInicio))
    oQryTmp:SetDate(nParam++, StoD(cDataFinal))

    oQryTmp:SetDate(nParam++, StoD(cDataInicio))
    oQryTmp:SetDate(nParam++, StoD(cDataFinal))


    cQuery := oQryTmp:GetFixQuery()
    cAlias := MpSysOpenQuery(cQuery)

    While !(cAlias)->(Eof())
        If Empty((cAlias)->JN6_DTINI)
            cData := AllTrim(cValToChar((cAlias)->JN3_DTPREV))
        Else
            cData := AllTrim(cValToChar((cAlias)->JN6_DTINI))
        EndIf

        oData := GetData(oMapDatas, oResponse, cData)

        oItem := JsonObject():New()

        oItem["codigoOS"] := AllTrim((cAlias)->JN3_CODIGO)
        oItem["pkOS"] := Encode64((cAlias)->JN3_FILIAL + (cAlias)->JN3_CODIGO)

        If Empty((cAlias)->JN3_DTPREV)
            oItem["dataPrevista"] := ""
        Else
            oItem["dataPrevista"] := AllTrim(cValToChar((cAlias)->JN3_DTPREV))
        EndIf

        oItem["codigoCliente"] := AllTrim((cAlias)->JN3_CLIENT)
        oItem["lojaCliente"]   := AllTrim((cAlias)->JN3_LOJA)
        oItem["nomeCliente"]   := AllTrim(EncodeUtf8((cAlias)->A1_NOME))
        oItem["estadoCliente"] := AllTrim((cAlias)->A1_ESTADO)

        oItem["codigoJN4"]    := AllTrim((cAlias)->JN4_CODIGO)        
        oItem["codigoServico"]    := AllTrim((cAlias)->JN4_CODJN1)
        oItem["descricaoServico"] := AllTrim(EncodeUtf8((cAlias)->JN1_DESCRI))

        oItem["situcaoOS"] := AllTrim((cAlias)->JN3_SITUAC)
        oItem["situcaoAtendimento"] := AllTrim((cAlias)->JN6_SITUAC)

		oItem["codigoAtendimento"] := AllTrim((cAlias)->JN6_CODIGO)
		oItem["pkAtendimento"] := Encode64((cAlias)->JN6_FILIAL + (cAlias)->JN6_CODIGO)

        oItem["prioridade"] := AllTrim((cAlias)->PRIORIDADE_ATEND)

        oItem["endereco"]    := AllTrim((cAlias)->JN3_END)
        oItem["complemento"] := AllTrim((cAlias)->JN3_COMPL)
        oItem["bairro"]      := AllTrim((cAlias)->JN3_BAIRRO)
        oItem["estado"]      := AllTrim((cAlias)->JN3_ESTADO)

        oItem["tipoOcorrencia"]     := AllTrim((cAlias)->JOK_CODIGO)
        oItem["tipoOcorrenciaDesc"] := AllTrim(EncodeUtf8((cAlias)->JOK_DESCRI))

        oItem["tipoAtendimento"]     := AllTrim((cAlias)->JOJ_CODIGO)
        oItem["tipoAtendimentoDesc"] := AllTrim(EncodeUtf8((cAlias)->JOJ_DESCRI))

        If Empty((cAlias)->JN6_DTINI)
            oItem["dataInicio"] := ""
        Else
            oItem["dataInicio"] := AllTrim(cValToChar((cAlias)->JN6_DTINI))
        EndIf

        If Empty((cAlias)->JN6_DTFIM)
            oItem["dataFim"] := ""
        Else 
            oItem["dataFim"] := AllTrim(cValToChar((cAlias)->JN6_DTFIM))
        EndIf

        oItem["horaInicio"] := AllTrim((cAlias)->JN6_HRINI)
        oItem["horaFim"]    := AllTrim((cAlias)->JN6_HRFIM)

        oItem["codigoTecnico"] := AllTrim((cAlias)->AA1_CODTEC)
        oItem["nomeTecnico"]   := AllTrim(EncodeUtf8((cAlias)->AA1_NOMTEC))

        If Empty((cAlias)->HIST_DTINI)
            oItem["dataInicioHist"] := ""
        Else 
            oItem["dataInicioHist"] := AllTrim(cValToChar((cAlias)->HIST_DTINI))
        EndIf

        oItem["horaInicioHist"] := AllTrim((cAlias)->HIST_HRINI)
        oItem["justificativaHist"] := AllTrim(EncodeUtf8((cAlias)->HIST_JUSTIF))
        oItem["situcaoHist"] := AllTrim((cAlias)->HIST_SITUAC)

        AAdd(oData["atendimentos"], oItem)

        oResponse["total"]++

        (cAlias)->(DbSkip())
    EndDo

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf
Return

