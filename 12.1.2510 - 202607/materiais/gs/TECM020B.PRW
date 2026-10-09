#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/
{Protheus.doc} meuposto
Endpoint do aplicativo Meu Posto - Vers�o 2.
Retorna par�metros do sistema (SX6) em JSON.
@author levy.santos
@since 09/03/2025
@version 1.0
/*/
//------------------------------------------------------------------------------
WSRESTFUL appmeuposto DESCRIPTION "Meu Posto - API v3"

	WSDATA filial    as STRING
	WSDATA imei      as STRING
	WSDATA matricula as STRING

	WSMETHOD GET 	params        		DESCRIPTION "Retorna  SX6"     										    PATH "v3/parametros"		PRODUCES APPLICATION_JSON
	WSMETHOD GET 	searchImei			DESCRIPTION "Consulta IMEI do dispositivo e retorna os funcion�rios atrelados"	    PATH "v3/consultaImei"		PRODUCES APPLICATION_JSON
	WSMETHOD GET 	photoFunc			DESCRIPTION "Retorna foto do  (SRA)"        							    PATH "v3/fotoFuncionario"	PRODUCES APPLICATION_JSON
	WSMETHOD POST 	checkin          	DESCRIPTION "Registra (ABB/T40)" 										    PATH "v3/checkin"           PRODUCES APPLICATION_JSON
    WSMETHOD POST 	apontamento 		DESCRIPTION "Apontamento de checkin/checkout" 										PATH "v3/apontamento" 		PRODUCES APPLICATION_JSON
END WSRESTFUL

//------------------------------------------------------------------------------
/*/
{Protheus.doc} params
Endpoint que retorna os valores dos par�metros do Protheus (tabela SX6).

@return Retorna valores dos par�metros para configura��o do aplicativo Meu Posto
@author     levy.santos
@since      09/03/2025
@version	1.0
/*/
//------------------------------------------------------------------------------
WSMETHOD GET params WSREST appmeuposto
	Local oBtns := JsonObject():New()
	Local oJson := JsonObject():New()

	::SetContentType("application/json;charset=UTF-8")

	oJson["modoUso"]      := SuperGetMV("MV_GSMDUSO", .F., "1")
	oJson["modoCheckin"]  := SuperGetMV("MV_GSMDCHK", .F., "1")
	oJson["exibirBotoes"] := SuperGetMV("MV_GSEXBBT", .F., .T.)
	oJson["numeroBotoes"] := SuperGetMV("MV_GSNMRBT", .F., 4)

	oBtns["btn1"] := SuperGetMV("MV_GSDSCB1", .F., "Entrada")
	oBtns["btn2"] := SuperGetMV("MV_GSDSCB2", .F., "Pausa")
	oBtns["btn3"] := SuperGetMV("MV_GSDSCB3", .F., "Retorno")
	oBtns["btn4"] := SuperGetMV("MV_GSDSCB4", .F., "Sa�da")

	oJson["textoBotoes"] := oBtns

	Self:SetResponse(EncodeUTF8(oJson:toJSON()))

Return .T.

//------------------------------------------------------------------------------
/*/
{Protheus.doc} searchImei
Obt�m a lista de funcion�rios com base no IMEI do dispositivo.
@param imei     IMEI do dispositivo (obrigat�rio)

@return Retorna a lista dos funcion�rios com base no IMEI do dispositivo.
@author     levy.santos
@since      16/03/2025
@version	1.0
/*/
//------------------------------------------------------------------------------
WSMETHOD GET searchImei WSREST appmeuposto
	Local aResults         := {}
	Local cContrato        := ""
	Local cImei            := AllTrim(::imei)
	Local cLocal           := ""
	Local cNivelInstalacao := ""
	Local cPosto           := ""
	Local cQry             := ""
	Local cRetImei         := ""
	Local cTmp             := GetNextAlias()
	Local cValorNivel      := ""
	Local oItem            := JsonObject():New()
	Local oJson            := JsonObject():New()
	Local oQry             := Nil

	::SetContentType("application/json;charset=UTF-8")

	If Empty(cImei)
		SetRestFault(400, "Par�metro IMEI � obrigat�rio.")
		Return .F.
	EndIf

	cQry := " SELECT TFS.TFS_FILIAL, "
	cQry += " TFS.TFS_IMEI IMEI, "
	cQry += " CASE "
	cQry +=     " WHEN  TFS.TFS_NIVEL = 1 THEN 'Posto' "
	cQry +=     " WHEN  TFS.TFS_NIVEL = 2 THEN 'Local' "
	cQry +=     " WHEN  TFS.TFS_NIVEL = 3 THEN 'Contrato' "
	cQry +=     " ELSE 'Indefinido' "
	cQry +=     " END NIVEL, "
	cQry += " TFG.TFG_CODPAI POSTO, "
	cQry += " TFL.TFL_CODIGO LOCAL_ATENDIMENTO, "
	cQry += " TFL.TFL_CODPAI CONTRATO, "
	cQry += " TFS.TFS_DTAPON DATA_IMPLANTACAO "
	cQry += " FROM " + RetSqlName("TFS") + " TFS "
	cQry += " JOIN " + RetSqlName("TFL") + " TFL "
	cQry +=     " ON TFL.TFL_FILIAL = TFS.TFS_FILIAL "
	cQry +=     " AND TFL.TFL_CODIGO = TFS.TFS_CODTFL "
	cQry +=     " AND TFL.D_E_L_E_T_ = ' ' "
	cQry += " JOIN " + RetSqlName("TFG") + " TFG "
	cQry +=     " ON TFG.TFG_FILIAL = TFS.TFS_FILIAL "
	cQry +=     " AND TFG.TFG_COD = TFS.TFS_CODTFG "
	cQry +=     " AND TFG.D_E_L_E_T_ = ' ' "
	cQry += " WHERE TFS.TFS_MOV = 1 "
	cQry +=     " AND TFS.TFS_IMEI = ? "
	cQry +=     " AND TFS.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)
	oQry := FwExecStatement():New(cQry)

	oQry:SetString(1, cImei)

	cTmp := oQry:OpenAlias()
	oQry:Destroy()
	FwFreeObj(oQry)

	While !(cTmp)->(Eof())
		cRetImei := (cTmp)->IMEI
		cNivelInstalacao := AllTrim((cTmp)->NIVEL)
		cPosto := (cTmp)->POSTO
		cLocal := (cTmp)->LOCAL_ATENDIMENTO
		cContrato := (cTmp)->CONTRATO
		(cTmp)->(DbSkip())
	EndDo
	(cTmp)->(DbCloseArea())

	If cRetImei == ""
		SetRestFault(404, "IMEI n�o encontrado.")
		Return .F.
	EndIf

	cQry := " SELECT "
	cQry += " ABB.ABB_FILIAL, "
	cQry += " TFF.TFF_COD POSTO, "
	cQry += " TFL.TFL_CODIGO LOCAL_ATENDIMENTO, "
	cQry += " TFL.TFL_CODPAI CONTRATO, "
	cQry += " ABB.ABB_CODTEC, "
	cQry += " AA1.AA1_CDFUNC MATRICULA, "
	cQry += " AA1.AA1_NOMTEC, "
	cQry += " SRA.RA_NOME, "
	cQry += " SRA.RA_CIC, "
	cQry += " SRA.RA_FILIAL, "
	cQry += " SRA.RA_ADMISSA, "
	cQry += " SRA.RA_DEMISSA, "
	cQry += " SRA.RA_BITMAP, "
	cQry += " MAX(ABB.ABB_DTFIM) ULTIMA_ALOCACAO "
	cQry += " FROM " + RetSqlName("ABB") + " ABB "
	cQry += " INNER JOIN " + RetSqlName("ABQ") + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
	cQry +=     " AND ABQ.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF ON TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
	cQry +=     " AND TFF.TFF_COD = ABQ.ABQ_CODTFF "
	cQry +=     " AND TFF.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQry +=     " AND TFL.TFL_FILIAL = TFF.TFF_FILIAL "
	cQry +=     " AND TFL.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN " + RetSqlName("AA1") + " AA1 ON AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	cQry +=     " AND AA1.D_E_L_E_T_ = ' ' "
	cQry += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = AA1.AA1_CDFUNC "
	cQry +=     " AND SRA.RA_FILIAL = AA1.AA1_FUNFIL "
	cQry +=     " AND SRA.D_E_L_E_T_ = ' ' "
	cQry += " WHERE ABB.D_E_L_E_T_ = ' ' "

	//SE N�VEL = POSTO
	If cNivelInstalacao == "Posto"
		cQry += " AND TFF.TFF_COD = ? "
		cValorNivel := cPosto
	EndIf

	//SE N�VEL = LOCAL
	If cNivelInstalacao == "Local"
		cQry += " AND TFL.TFL_CODIGO = ? "
		cValorNivel := cLocal
	EndIf

	//SE N�VEL = CONTRATO
	If cNivelInstalacao == "Contrato"
		cQry += " AND TFL.TFL_CODPAI = ? "
		cValorNivel := cContrato
	EndIf
	
	cQry += " GROUP BY "
	cQry +=     " ABB.ABB_FILIAL, "
	cQry +=     " TFF.TFF_COD, "
	cQry +=     " TFL.TFL_CODIGO, "
	cQry +=     " TFL.TFL_CODPAI, "
	cQry +=     " AA1.AA1_NOMTEC, "
	cQry +=     " SRA.RA_NOME, "
	cQry +=     " SRA.RA_CIC, "
	cQry +=     " SRA.RA_FILIAL, "
	cQry +=     " SRA.RA_ADMISSA, "
	cQry += 	" SRA.RA_DEMISSA, "
	cQry +=     " AA1.AA1_CDFUNC, "
	cQry +=     " ABB.ABB_CODTEC, "
	cQry +=     " SRA.RA_BITMAP "

	cQry := ChangeQuery(cQry)
	oQry := FwExecStatement():New(cQry)

	oQry:SetString(1, cValorNivel)

	cTmp := oQry:OpenAlias()
	oQry:Destroy()
	FwFreeObj(oQry)

	While !(cTmp)->(Eof())
		oItem := JsonObject():New()
		oItem["codTec"] := (cTmp)->ABB_CODTEC
		oItem["matricula"] := (cTmp)->MATRICULA
		oItem["filialSRA"] := (cTmp)->RA_FILIAL
		oItem["nome"] := AllTrim((cTmp)->RA_NOME)
		oItem["cpf"] := AllTrim((cTmp)->RA_CIC)
		oItem["admissao"] := AllTrim((cTmp)->RA_ADMISSA)
		oItem["demissao"] := AllTrim((cTmp)->RA_DEMISSA)
		oItem["bitmap"] := AllTrim((cTmp)->RA_BITMAP)
		AAdd(aResults, oItem)
		(cTmp)->(DbSkip())
	EndDo
	(cTmp)->(DbCloseArea())

	oJson := JsonObject():New()

	oJson["nivelInstalacao"] := cNivelInstalacao
	oJson["results"] := aResults
	Self:SetResponse(EncodeUTF8(oJson:toJSON()))

Return .T.

//------------------------------------------------------------------------------
/*/
	{Protheus.doc} photoFunc
	Obt�m a foto do funcion�rio em base64.
	@param filial     Filial (obrigat�rio)
	@param matricula  Matr�cula do funcion�rio (obrigat�rio)

	@return Retorna a foto do funcion�rio em formato base64 em JSON.
	@author     diego.bezerra | levy.santos
	@since      09/03/2025
	@version	2.0
/*/
//------------------------------------------------------------------------------
WSMETHOD GET photoFunc WSREST appmeuposto
	Local cFile      := ""
	Local cFilFunc   := AllTrim(::filial)
	Local cMatricula := AllTrim(::matricula)
	Local cQry       := ""
	Local cTmp       := ""
	Local oFile      := Nil
	Local oJson      := JsonObject():New()
	Local oQry       := Nil
	Local xFile      := Nil
    Local cPathFile  := ""

	::SetContentType("application/json;charset=UTF-8")

	If Empty(cFilFunc)
		SetRestFault(400, "Par�metro filial � obrigat�rio.")
		Return .F.
	EndIf

	If Empty(cMatricula)
		SetRestFault(400, "Par�metro matr�cula � obrigat�rio.")
		Return .F.
	EndIf

	cQry := " SELECT "
	cQry += " RA_MAT, "
	cQry += " RA_NOME, "
	cQry += " RA_CIC, "
	cQry += " RA_BITMAP "
	cQry += " FROM " + RetSqlName("SRA") + " "
	cQry += " WHERE "
	cQry +=     " RA_FILIAL = ? "
	cQry +=     " AND RA_MAT = ? "
	cQry +=     " AND RA_BITMAP <> ' ' "
	cQry +=     " AND D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)
	oQry := FwExecStatement():New(cQry)

	oQry:SetString(1, cFilFunc)
	oQry:SetString(2, cMatricula)

	cTmp := oQry:OpenAlias()
	oQry:Destroy()
	FwFreeObj(oQry)

	While !(cTmp)->(Eof())
		cFile := AllTrim((cTmp)->RA_BITMAP) + ".jpg"
        cPathFile := cFile
		If RepExtract(AllTrim((cTmp)->RA_BITMAP), cFile) .And. File(cFile)
			oFile := FwFileReader():New(cFile)
			If oFile:Open()
				xFile := ReadAllFile(oFile:nHandlen)
				cFile := ENCODE64(xFile)
				oFile:Close()
				
				oJson := JsonObject():New()
				oJson["matricula"]   := (cTmp)->RA_MAT
				oJson["nome"]        := AllTrim((cTmp)->RA_NOME)
				oJson["CPF"]         := AllTrim((cTmp)->RA_CIC)
				oJson["fotoBase64"]  := cFile
			EndIf
			FErase(cPathFile)
		EndIf
		(cTmp)->(DbSkip())
	EndDo
	(cTmp)->(DbCloseArea())

	Self:SetResponse(EncodeUTF8(oJson:toJSON()))

Return .T.


Static Function ReadAllFile(nHandle)
    Local cBuff := Space(2048)
    Local cData := ""
    Local nLido := 0

    While (nLido := FRead(nHandle, @cBuff, Len(cBuff))) > 0
        cData += Left(cBuff, nLido)
    EndDo
Return cData

WSMETHOD POST apontamento WSREST appmeuposto

    Local lRet        := .T.
    Local cBody       := ""
    Local oJson       := Nil
    Local cResponse   := '{"successCode":200,"successMessage":"Apontamento gravado com sucesso."}'
    Local nStatusCode := 500
    Local cMessage    := "Internal Server Error"

    Self:SetContentType("application/json")
    cBody := Self:GetContent()

    If Empty(cBody)
        lRet        := .F.
        nStatusCode := 400
        cMessage    := "Dados nao encontrados no corpo da requisicao."
    Else
        FWJsonDeserialize(cBody, @oJson)

        If Empty(oJson)
            lRet        := .F.
            nStatusCode := 400
            cMessage    := "JSON invalido."
        ElseIf !GravaApontT40(oJson, @cMessage)
            lRet        := .F.
            nStatusCode := 400
        EndIf
    EndIf

    If lRet
        Self:SetResponse(EncodeUTF8(cResponse))
    Else
        SetRestFault(nStatusCode, EncodeUTF8(cMessage))
    EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GravaApontT40
Grava apontamento recebido na tabela T40.
/*/
//------------------------------------------------------------------------------
Static Function GravaApontT40(oJson, cMessage)
    Local lRet      := .F.
    Local cCpf      := ""
    Local cData     := ""
    Local cHorario  := ""
    Local nNumMar   := 0
    Local cLatitude := ""
    Local cLongit   := ""
    Local cModoUso  := ""
    Local cTipo     := ""
    Local cModo     := ""
    Local cCodRel   := ""
    Local cIdMar    := ""
    Local dDataMar  := Ctod("")
    Local nHora     := 0
    Local nMin      := 0
    Local nSeg      := 0
    Local nPosUso   := 0
    Local nPosTipo  := 0
    Local nPosIdMar := 0
    Local cProxireg := ""

    Default cMessage := "Nao foi possivel gravar o apontamento."

    cCpf      := AllTrim(IIf(ValType(oJson:cpf) == "C", oJson:cpf, cValToChar(oJson:cpf)))
    cData     := AllTrim(IIf(ValType(oJson:data) == "C", oJson:data, cValToChar(oJson:data)))
    cHorario  := AllTrim(IIf(ValType(oJson:horario) == "C", oJson:horario, cValToChar(oJson:horario)))
    cLatitude := AllTrim(IIf(ValType(oJson:latitude) == "C", oJson:latitude, cValToChar(oJson:latitude)))
    cLongit   := AllTrim(IIf(ValType(oJson:longitude) == "C", oJson:longitude, cValToChar(oJson:longitude)))
    cModoUso  := AllTrim(cValToChar(oJson:modoUso))
    cTipo     := AllTrim(cValToChar(oJson:tipoMarcacao))
    cModo     := AllTrim(cValToChar(oJson:modoMarcacao))
    cCodRel   := AllTrim(IIf(ValType(oJson:identificadorDispositivo) == "C", oJson:identificadorDispositivo, cValToChar(oJson:identificadorDispositivo)))
    cIdMar    := AllTrim(IIf(ValType(oJson:id) == "C", oJson:id, cValToChar(oJson:id)))

    If Empty(cCpf) .Or. Empty(cData) .Or. Empty(cHorario) .Or. Empty(cIdMar)
        cMessage := "Campos obrigatorios nao informados (cpf, data, horario, id)."
        Return .F.
    EndIf

    If Len(cHorario) <> 8 .Or. SubStr(cHorario, 3, 1) <> ":" .Or. SubStr(cHorario, 6, 1) <> ":"
        cMessage := "Horario invalido. Formato esperado: hh:mm:ss."
        Return .F.
    EndIf

    nHora := Val(SubStr(cHorario, 1, 2))
    nMin  := Val(SubStr(cHorario, 4, 2))
    nSeg  := Val(SubStr(cHorario, 7, 2))

    If nHora < 0 .Or. nHora > 23 .Or. nMin < 0 .Or. nMin > 59 .Or. nSeg < 0 .Or. nSeg > 59
        cMessage := "Horario invalido. Use valores entre 00:00:00 e 23:59:59."
        Return .F.
    EndIf

    nNumMar := (nHora * 3600) + (nMin * 60) + nSeg

    If Len(cData) == 10
        dDataMar := StoD(SubStr(cData, 7, 4) + SubStr(cData, 4, 2) + SubStr(cData, 1, 2))
    EndIf

    If Empty(dDataMar)
        cMessage := "Data invalida. Formato esperado: dd/mm/yyyy."
        Return .F.
    EndIf

    dbSelectArea("T40")
    T40->(dbSetOrder(1))
    nPosUso   := T40->(ColumnPos("T40_USO"))
    nPosTipo  := T40->(ColumnPos("T40_TIPO"))
    nPosIdMar := T40->(ColumnPos("T40_IDMAR"))
    cProxireg := TecProNum("T40","T40_VALCON",4)
    BEGIN TRANSACTION
        If RecLock("T40", .T.)
            T40->T40_FILIAL := xFilial("T40")
            T40->T40_VALCON := cProxireg
            T40->T40_CIC    := cCpf
            T40->T40_DATMAR := dDataMar
            T40->T40_NUMMAR := nNumMar
            T40->T40_LATITU := cLatitude
            T40->T40_LONGIT := cLongit
            If nPosUso > 0
                T40->T40_USO := cModoUso
            EndIf
            If nPosTipo > 0
                T40->T40_TIPO := cTipo
            EndIf
            T40->T40_CODREL := cCodRel
            If nPosIdMar > 0
                T40->T40_IDMAR := cIdMar
            EndIf
            T40->(MsUnlock())
            lRet := .T.
        EndIf
    END TRANSACTION

    If !lRet
        cMessage := "Falha ao gravar na tabela T40."
    Else
        // Atualiza batidas na agenda (ABB) com a mesma regra do TecUpdABB
        AtualizaAgendaApont(cCpf, dDataMar, cHorario, cTipo, cProxireg)
    EndIf

Return lRet



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecProNum

Obtem o cÃ¯Â¿Â½digo do prÃ¯Â¿Â½ximo registro da tabela t40

@param cAlias, string, alias da tabela
@param cCampo, string, nome do campo de controle que serÃ¯Â¿Â½ atualizado

@author     Diego Bezerra
@since      05/05/2026
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function TecProNum(cAlias,cCampo,nIndex)

Local aArea     := GetArea()
Local aAreaTmp  := (cAlias)->(GetArea())
Local cProxNum  := ""
Local lSeek     := .T.

Default cAlias := "T40"
Default cCampo := "T40_VALCON"
Default nIndex := 1

If cCampo == 'T40_VALCON'
    DbSelectArea('T40')
    DbSetOrder(1)
    While lSeek
        cProxNum    := GetSxeNum(cAlias, cCampo,, nIndex)
        lSeek       := DbSeek( xFilial('T40')+cProxNum)
    EndDO
Else 
    cProxNum := GetSxeNum(cAlias, cCampo,, nIndex)
EndIf

dbSelectArea(cAlias)
dbSetOrder(nIndex)

RestArea(aAreaTmp)
RestArea(aArea)

Return(cProxNum)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaAgendaApont

Fu��o para realizar a grava��o de marca��o checkin/checkout e atendimento da agenda
Apos gravacao na T40, localiza agenda (ABB + TDV) do atendente e atualiza ABB_HRCHIN
ou ABB_HRCOUT via TecAtuABB, conforme tipoMarcacao:
1=entrada1 (1E), 2=saida1 (1S), 3=entrada2 (2E), 4=saida2 (2S).
TDV.TDV_DTREF alinhado a ABB.ABB_DTINI (data de referencia da jornada; ex.: turno noturno 04/05 22h a 05/05 01h).

@param, cCpf, string, cpf do atendente - conforme sra
@param, dDtaMar, date, data da marca��o realizada via app
@param, cHorario, string, hor�rio da marca��o realizada via app - formato hh:mm:ss
@param, cTipoMar, string, tipo da marca��o 1=entrada1, 2=sa�da1, 3=entrada2, 4=sa�da2
@author     Diego Bezerra
@since      05/05/2026
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtualizaAgendaApont(cCpf, dDataMar, cHorario, cTipoMar, cProxireg)
    Local cAliasSRA := ""
    Local cFilFun   := ""
    Local cMatFun   := ""
    Local cQry      := ""
    Local cTempHora := ""
    Local nNumQuery := 1
    Local oQuery    := Nil

    Default cTipoMar  := ""
    Default cProxireg := ""

    If Empty(AllTrim(cCpf)) .Or. Empty(dDataMar) .Or. Empty(AllTrim(cHorario))
        Return .T.
    EndIf

    cTempHora := Left(AllTrim(cHorario), 5)
    If Empty(cTempHora)
        Return .T.
    EndIf

    cQry := " SELECT RA_FILIAL, RA_MAT FROM ? SRA WHERE "
    cQry += " SRA.RA_CIC = ? AND (RA_DEMISSA=' ' OR RA_DEMISSA > ?) AND "
    cQry += " SRA.D_E_L_E_T_ = ' ' "
    cQry := ChangeQuery(cQry)

    oQuery := FwExecStatement():New(cQry)
    oQuery:SetUnsafe( nNumQuery++, RetSQLName("SRA") )
    oQuery:SetString( nNumQuery++, AllTrim(cCpf) )
    oQuery:SetString( nNumQuery++, DTOS(dDataMar) )
    cAliasSRA := oQuery:OpenAlias()

    If !Empty(cAliasSRA) .And. Select(cAliasSRA) > 0
        dbSelectArea(cAliasSRA)
        If (cAliasSRA)->(!Eof())
            cFilFun := (cAliasSRA)->RA_FILIAL
            cMatFun := (cAliasSRA)->RA_MAT
        EndIf
        (cAliasSRA)->(DbCloseArea())
    EndIf

    If ValType(oQuery) == "O"
        oQuery:Destroy()
        FwFreeObj(oQuery)
    EndIf

    If !Empty(cFilFun + cMatFun)
        If AllTrim(cTipoMar) $ "1|2|3|4"
            // Quando vem tipo de marcacao, segue regra por periodo (mesma ideia do TecAbbUpd)
            TecAbbUpd(cFilFun, cMatFun, cCpf, dDataMar, cTempHora, cProxireg, AllTrim(cTipoMar))
        Else
            TecUpdABB(cCpf, dDataMar, cTempHora, cProxireg, cFilFun, cMatFun)
        EndIf
    EndIf

Return .T.

/*/{Protheus.doc} TecAbbUpd
Atualiza ABB por tipo de marcacao (1..4), com intrajornada.
/*/
Static Function TecAbbUpd(cFilFun,cMatFun,cCPF,dDataMarc,cHoraMarc,cCodMarc,cTipMarc)
    Local aAgendaABB := {}
    Local lAttFake1  := .F.
    Local lCheckIn   := .F.
    Local lCheckOut  := .F.
    Local lIntra     := .F.
    Local nABB       := 0
    Local nNumABB    := 0

    If cTipMarc $ "1|3"
        lCheckIn := .T.
    ElseIf cTipMarc $ "2|4"
        lCheckOut := .T.
    EndIf

    If cTipMarc $ "1|2"
        nNumABB := 1
    ElseIf cTipMarc $ "3|4"
        nNumABB := 2
    EndIf

    aAgendaABB := TeGetAgen(cCPF,dDataMarc,cFilFun,cMatFun)

    For nABB := 1 To Len(aAgendaABB)
        If nNumABB == nABB
            lIntra := Len(aAgendaABB) == 2 .And. aAgendaABB[nABB,14]

            dbSelectArea("ABB")
            ABB->(dbGoto(aAgendaABB[nNumABB,1]))
            If ABB->(!EOF())
                If RecLock("ABB", .F.)
                    If lCheckIn
                        ABB->ABB_MARENT  := cCodMarc
                        ABB->ABB_DTCHIN  := dDataMarc
                        ABB->ABB_HRCHIN  := cHoraMarc
                        ABB->ABB_CHEGOU  := "S"

                        // Batida fake de saida na primeira ABB (intrajornada)
                        If lIntra .And. nNumABB == 1 .And. cTipMarc == "1"
                            ABB->ABB_DTCHOU  := ABB->ABB_DTFIM
                            ABB->ABB_MARSAI  := ""
                            ABB->ABB_HRCOUT  := aAgendaABB[nABB,05]
                            ABB->ABB_SAIU    := "S"
                            ABB->ABB_ATENDE  := "1"
                        EndIf
                    EndIf

                    If lCheckOut
                        ABB->ABB_MARSAI  := cCodMarc
                        ABB->ABB_DTCHOU  := dDataMarc
                        ABB->ABB_HRCOUT  := cHoraMarc
                        ABB->ABB_SAIU    := "S"
                        ABB->ABB_ATENDE  := "1"

                        // Batida fake de entrada na segunda ABB (intrajornada)
                        If lIntra .And. nNumABB == 2 .And. cTipMarc == "4"
                            ABB->ABB_DTCHIN  := ABB->ABB_DTINI
                            ABB->ABB_MARENT  := ""
                            If aAgendaABB[nABB,4] > cHoraMarc
                                ABB->ABB_HRCHIN := TecConvHr(SubHoras(cHoraMarc, "00:01"))
                                lAttFake1 := .T.
                            Else
                                ABB->ABB_HRCHIN := aAgendaABB[nABB,4]
                            EndIf
                            ABB->ABB_CHEGOU  := "S"
                        EndIf
                    EndIf
                    ABB->(MsUnlock())
                EndIf
            EndIf
        EndIf
    Next nABB

    // Se ajustou fake da segunda ABB, sincroniza fake de saida da primeira ABB
    If lAttFake1 .And. Len(aAgendaABB) > 0
        dbSelectArea("ABB")
        ABB->(dbGoto(aAgendaABB[1,1]))
        If ABB->(!EOF())
            If RecLock("ABB", .F.)
                If ABB->ABB_HRCOUT > cHoraMarc
                    ABB->ABB_HRCOUT := TecConvHr(SubHoras(cHoraMarc, "00:01"))
                EndIf
                ABB->(MsUnlock())
            EndIf
        EndIf
    EndIf

    // Fallback: quando houver 2 periodos no dia e tipo final (4),
    // garante fechamento/abertura fake mesmo sem PA_COMPMAR = 'S'.
    If cTipMarc == "4"
        TecForcaFakeIntervalo(cCPF, dDataMarc, cHoraMarc, cFilFun, cMatFun)
    EndIf

    // Regra de marcacao automatica (batidas fake adicionais)
    If cTipMarc == "4"
        GetRegra(aAgendaABB, cCPF, dDataMarc, cHoraMarc)
    EndIf

Return

/*/{Protheus.doc} TecForcaFakeIntervalo
Forca batidas fake entre dois periodos no fechamento (tipo 4).
/*/
Static Function TecForcaFakeIntervalo(cCPF, dDataMarc, cHoraMarc, cFilFun, cMatFun)
    Local aAgendaABB := {}
    Local lNeedOut1  := .F.
    Local lNeedIn2   := .F.

    aAgendaABB := TeGetAgen(cCPF, dDataMarc, cFilFun, cMatFun)

    // Apenas para cenario com dois periodos na data
    If Len(aAgendaABB) <> 2
        Return
    EndIf

    // 1o periodo sem saida e 2o periodo sem entrada
    lNeedOut1 := !aAgendaABB[1,3]
    lNeedIn2  := !aAgendaABB[2,2]

    If lNeedOut1
        ABB->(dbGoto(aAgendaABB[1,1]))
        If ABB->(!EOF()) .And. RecLock("ABB", .F.)
            ABB->ABB_DTCHOU := ABB->ABB_DTFIM
            ABB->ABB_MARSAI := ""
            If aAgendaABB[1,5] > cHoraMarc
                ABB->ABB_HRCOUT := TecConvHr(SubHoras(cHoraMarc, "00:01"))
            Else
                ABB->ABB_HRCOUT := aAgendaABB[1,5]
            EndIf
            ABB->ABB_SAIU   := "S"
            ABB->ABB_ATENDE := "1"
            ABB->(MsUnlock())
        EndIf
    EndIf

    If lNeedIn2
        ABB->(dbGoto(aAgendaABB[2,1]))
        If ABB->(!EOF()) .And. RecLock("ABB", .F.)
            ABB->ABB_DTCHIN := ABB->ABB_DTINI
            ABB->ABB_MARENT := ""
            If aAgendaABB[2,4] > cHoraMarc
                ABB->ABB_HRCHIN := TecConvHr(SubHoras(cHoraMarc, "00:01"))
            Else
                ABB->ABB_HRCHIN := aAgendaABB[2,4]
            EndIf
            ABB->ABB_CHEGOU := "S"
            ABB->ABB_ATENDE := "1"
            ABB->(MsUnlock())
        EndIf
    EndIf

Return


/*/{Protheus.doc} GetRegra
Verifica regra da agenda/funcionario e cria batidas fake de intervalo.
/*/
Static Function GetRegra(aAgendaABB, cCPF, dDataMarc, cHoraMarc)
    Local aArea       := GetArea()
    Local cAliasABB   := ""
    Local cQry        := ""
    Local cRegra      := ""
    Local cMarcAuto   := ""
    Local lMV_MultFil := .F.
    Local nNumQuery   := 1
    Local nRecno      := 0
    Local nX          := 1
    Local oQuery      := Nil

    If Len(aAgendaABB) > 0
        lMV_MultFil := TecMultFil()
        nRecno      := aAgendaABB[1][1]

        If nRecno > 0
            cQry := " SELECT TFF.TFF_REGRA "
            cQry += " FROM ? ABB "
            cQry += " INNER JOIN ? ABQ ON "
            cQry += " ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
            If !lMV_MultFil
                cQry += " ABQ.ABQ_FILIAL = ? AND "
            Else
                cQry += " ? AND "
            EndIf
            cQry += " ABQ.D_E_L_E_T_ = ' ' "
            cQry += " INNER JOIN ? TFF ON "
            cQry += " TFF.TFF_COD = ABQ.ABQ_CODTFF AND "
            cQry += " TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
            cQry += " TFF.D_E_L_E_T_ = ' ' "
            cQry += " WHERE "
            If !lMV_MultFil
                cQry += " ABB.ABB_FILIAL = ? AND "
            EndIf
            cQry += " ABB.R_E_C_N_O_ = ? AND "
            cQry += " ABB.D_E_L_E_T_ = ' ' "

            cQry := ChangeQuery(cQry)
            oQuery := FwExecStatement():New(cQry)
            oQuery:SetUnsafe( nNumQuery++, RetSQLName("ABB") )
            oQuery:SetUnsafe( nNumQuery++, RetSQLName("ABQ") )
            If !lMV_MultFil
                oQuery:SetString( nNumQuery++, xFilial("ABQ") )
            Else
                oQuery:SetUnsafe( nNumQuery++, FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) )
            EndIf
            oQuery:SetUnsafe( nNumQuery++, RetSQLName("TFF") )
            If !lMV_MultFil
                oQuery:SetString( nNumQuery++, xFilial("ABB") )
            EndIf
            oQuery:SetNumeric( nNumQuery++, nRecno )

            cAliasABB := oQuery:OpenAlias()
            If !Empty(cAliasABB) .And. Select(cAliasABB) > 0
                dbSelectArea(cAliasABB)
                If (cAliasABB)->(!Eof())
                    cRegra := (cAliasABB)->TFF_REGRA
                EndIf
                (cAliasABB)->(DbCloseArea())
            EndIf

            If ValType(oQuery) == "O"
                oQuery:Destroy()
                FwFreeObj(oQuery)
            EndIf

            If Empty(cRegra)
                DbSelectArea("SRA")
                SRA->(DbSetOrder(5))
                If SRA->(dbSeek(xFilial("SRA") + cCPF))
                    cRegra := SRA->RA_REGRA
                EndIf
            EndIf

            If !Empty(cRegra)
                DbSelectArea("SPA")
                SPA->(DbSetOrder(1))
                If SPA->(dbSeek(xFilial("SPA") + cRegra))
                    cMarcAuto := SPA->PA_COMPMAR
                EndIf
            EndIf

            If cMarcAuto == "S"
                For nX := 1 To Len(aAgendaABB)
                    If !aAgendaABB[nX,14]
                        ABB->(dbGoto(aAgendaABB[nX,1]))
                        If RecLock("ABB", .F.)
                            If nX == 1
                                ABB->ABB_DTCHOU  := ABB->ABB_DTFIM
                                ABB->ABB_MARSAI  := ""
                                If aAgendaABB[nX,5] > cHoraMarc
                                    ABB->ABB_HRCOUT := TecConvHr(SubHoras(cHoraMarc, "00:01"))
                                Else
                                    ABB->ABB_HRCOUT := ABB->ABB_HRFIM
                                EndIf
                                ABB->ABB_SAIU   := "S"
                                ABB->ABB_ATENDE := "1"
                            Else
                                ABB->ABB_DTCHIN := ABB->ABB_DTINI
                                ABB->ABB_MARENT := ""
                                If aAgendaABB[nX,4] > cHoraMarc
                                    ABB->ABB_HRCHIN := TecConvHr(SubHoras(cHoraMarc, "00:01"))
                                Else
                                    ABB->ABB_HRCHIN := ABB->ABB_HRINI
                                EndIf
                                ABB->ABB_CHEGOU := "S"
                                ABB->ABB_ATENDE := "1"
                            EndIf
                            ABB->(MsUnlock())
                        EndIf
                    EndIf
                Next nX
            EndIf
        EndIf
    EndIf

    RestArea(aArea)
Return

Static Function TecUpdABB(cCic,dDTMarc,cTempHora,cProxireg,cFilFun,cMatFun)

Local aRtABB   := {}
Local cCicAnt  := ""
Local cHoraSav := ""
Local cMarcSav := ""
Local dDtAnt   := CToD("")
Local lPendSav := .T.
Local lOk      := .F.
Local nCont    := 0
Local nRecNSav := 0

If dDtAnt <> dDTMarc .OR. cCic <> cCicAnt
    dDtAnt  := dDTMarc
    cCicAnt := cCic
    aRtABB  := TeGetAgen(cCic,dDTMarc,cFilFun,cMatFun)
EndIf

For nCont := 1 To Len(aRtABB)
    cHoraSav := ""
    cMarcSav := ""
    lPendSav := .F.
    nRecNSav := 0

    ABB->(dbGoto(aRtABB[nCont,1]))
    RecLock("ABB", .F.)

    // INTRAJORNADA (SEM INTERVALO)
    If Len(aRtABB) == 2
        // No primeiro periodo, gera saida fake; no segundo, entrada fake
        If aRtABB[nCont,14]
            If nCont == 1 .And. !aRtABB[nCont,02] .And. (aRtABB[nCont+1,03]) .Or. ;
            (aRtABB[nCont,02] .And. !(dDTMarc == ABB->ABB_DTFIM .And. cTempHora < aRtABB[nCont,05]))
                ABB->ABB_DTCHOU  := ABB->ABB_DTFIM
                ABB->ABB_MARSAI  := ""
                ABB->ABB_HRCOUT  := aRtABB[nCont,05]
                ABB->ABB_SAIU    := "S"
                ABB->ABB_ATENDE  := "1"
                aRtABB[nCont,03] := .T.
                aRtABB[nCont,09] := dDTMarc
                aRtABB[nCont,11] := cTempHora
            ElseIf nCont == 2 .And. !aRtABB[nCont,2] .And. !(dDTMarc == ABB->ABB_DTINI .And. cTempHora < aRtABB[nCont,5])
                ABB->ABB_DTCHIN  := ABB->ABB_DTINI
                ABB->ABB_MARENT  := ""
                ABB->ABB_HRCHIN  := aRtABB[nCont,4]
                ABB->ABB_CHEGOU  := "S"
                aRtABB[nCont,02] := .T.
                aRtABB[nCont,08] := dDTMarc
                aRtABB[nCont,10] := cTempHora
            EndIf
        EndIf
    EndIf

    If !aRtABB[nCont,02] .And. !aRtABB[nCont,06]
        If nCont == 2 .And. aRtABB[1,09] == dDTMarc .And. aRtABB[1,11] > cTempHora .And. !aRtABB[1,07]
            cHoraSav := aRtABB[1,11]
            cMarcSav := aRtABB[1,13]
            lPendSav := .T.
            nRecNSav := aRtABB[1,01]
            ABB->ABB_DTCHIN  := dDTMarc
            ABB->ABB_MARENT  := cMarcSav
            ABB->ABB_HRCHIN  := cHoraSav
            ABB->ABB_CHEGOU  := "S"
            aRtABB[nCont,02] := .T.
            aRtABB[nCont,08] := dDTMarc
            aRtABB[nCont,10] := cHoraSav
        Else
            ABB->ABB_DTCHIN  := dDTMarc
            ABB->ABB_MARENT  := cProxireg
            ABB->ABB_HRCHIN  := cTempHora
            ABB->ABB_CHEGOU  := "S"
            aRtABB[nCont,02] := .T.
            aRtABB[nCont,08] := dDTMarc
            aRtABB[nCont,10] := cTempHora
        EndIf
        lOk := .T.
    ElseIf !aRtABB[nCont,03] .And. !aRtABB[nCont,07]
        If aRtABB[nCont,08] == dDTMarc .And. aRtABB[nCont,10] > cTempHora .And. !aRtABB[nCont,06]
            cHoraSav := TRIM(ABB->ABB_HRCHIN)
            cMarcSav := ABB->ABB_MARENT
            ABB->ABB_MARENT  := cProxireg
            ABB->ABB_HRCHIN  := cTempHora
            aRtABB[nCont,02] := .T.
            aRtABB[nCont,08] := dDTMarc
            aRtABB[nCont,10] := cTempHora
            ABB->ABB_DTCHOU  := dDTMarc
            ABB->ABB_MARSAI  := cMarcSav
            ABB->ABB_HRCOUT  := cHoraSav
            ABB->ABB_SAIU    := "S"
            ABB->ABB_ATENDE  := "1"
            aRtABB[nCont,03] := .T.
            aRtABB[nCont,09] := dDTMarc
            aRtABB[nCont,11] := cTempHora
        Else
            ABB->ABB_DTCHOU  := dDTMarc
            ABB->ABB_MARSAI  := cProxireg
            ABB->ABB_HRCOUT  := cTempHora
            ABB->ABB_SAIU    := "S"
            ABB->ABB_ATENDE  := "1"
            aRtABB[nCont,03] := .T.
            aRtABB[nCont,09] := dDTMarc
            aRtABB[nCont,11] := cTempHora
        EndIf
        lOk := .T.
    EndIf
    ABB->(MsUnlock())
    If lOk
        If lPendSav
            ABB->(dbGoto(nRecNSav))
            RecLock("ABB", .F.)
            ABB->ABB_DTCHOU  := dDTMarc
            ABB->ABB_MARSAI  := cProxireg
            ABB->ABB_HRCOUT  := cTempHora
            ABB->ABB_SAIU    := "S"
            ABB->ABB_ATENDE  := "1"
            aRtABB[nCont,03] := .T.
            aRtABB[nCont,09] := dDTMarc
            aRtABB[nCont,11] := cTempHora
            ABB->(MsUnlock())
        EndIf
        Exit
    EndIf
Next nCont

Return


/*/{Protheus.doc} TeGetAgen
Pesquisa agendas do atendente para atualizar batidas.
/*/
Static Function TeGetAgen(cCic,dDTMarc,cFilFun,cMatFun)
Local aArea      := GetArea()
Local aRet       := {}
Local cAliasABB  := ""
Local cQry       := ""
Local lMV_MultFil:= TecMultFil()
Local nNumQuery  := 1
Local oQuery     := Nil

cQry := " SELECT ABB.R_E_C_N_O_ RECABB, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_HRCHIN, ABB.ABB_HRCOUT, "
cQry += " ABB.ABB_MARENT, ABB.ABB_MARSAI, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_DTCHIN, ABB.ABB_DTCHOU "
cQry += " FROM ? ABB "
cQry += " INNER JOIN ? AA1 ON "
cQry += " AA1.AA1_FILIAL = ? AND "
cQry += " AA1.AA1_FUNFIL = ? AND "
cQry += " AA1.AA1_CDFUNC = ? AND "
cQry += " AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
cQry += " AA1.D_E_L_E_T_ = ' ' "
cQry += " INNER JOIN ? TDV ON "
cQry += " TDV.TDV_FILIAL= ABB.ABB_FILIAL AND "
cQry += " TDV.TDV_CODABB=ABB.ABB_CODIGO AND "
cQry += " TDV.D_E_L_E_T_ = ' ' "
cQry += " AND TDV.TDV_DTREF IN ( "
cQry += " SELECT DISTINCT TDV.TDV_DTREF "
cQry += " FROM ? ABB "
cQry += " INNER JOIN ? AA1 ON AA1.AA1_FILIAL = ? AND AA1.AA1_FUNFIL = ? AND AA1.AA1_CDFUNC = ? AND AA1.AA1_CODTEC = ABB.ABB_CODTEC AND AA1.D_E_L_E_T_ = ' ' "
cQry += " INNER JOIN ? TDV ON TDV.TDV_FILIAL = ABB.ABB_FILIAL AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.D_E_L_E_T_ = ' ' "
cQry += " WHERE "
If !lMV_MultFil
    cQry += " ABB.ABB_FILIAL = ? AND "
EndIf
cQry += " ABB.ABB_ATIVO = '1' AND ( ABB.ABB_DTINI = ? OR ABB.ABB_DTFIM = ? ) AND ABB.D_E_L_E_T_ = ' ') "
cQry += " WHERE "
If !lMV_MultFil
    cQry += " ABB.ABB_FILIAL = ? AND "
EndIf
cQry += " ABB.ABB_ATIVO = '1' AND "
cQry += " ABB.D_E_L_E_T_ = ' ' "
cQry += " ORDER BY ABB.ABB_DTINI, ABB.ABB_HRINI "

oQuery := FwExecStatement():New(cQry)
oQuery:SetUnsafe( nNumQuery++, RetSQLName("ABB") )
oQuery:SetUnsafe( nNumQuery++, RetSQLName("AA1") )
oQuery:SetString( nNumQuery++, FwxFilial("AA1",cFilFun) )
oQuery:SetString( nNumQuery++, cFilFun)
oQuery:SetString( nNumQuery++, cMatFun)
oQuery:SetUnsafe( nNumQuery++, RetSQLName("TDV") )
oQuery:SetUnsafe( nNumQuery++, RetSQLName("ABB") )
oQuery:SetUnsafe( nNumQuery++, RetSQLName("AA1") )
oQuery:SetString( nNumQuery++, FwxFilial("AA1",cFilFun) )
oQuery:SetString( nNumQuery++, cFilFun)
oQuery:SetString( nNumQuery++, cMatFun)
oQuery:SetUnsafe( nNumQuery++, RetSQLName("TDV") )
If !lMV_MultFil
    oQuery:SetString( nNumQuery++, FwxFilial("ABB",cFilFun) )
EndIf
oQuery:SetString( nNumQuery++, DTOS(dDTMarc) )
oQuery:SetString( nNumQuery++, DTOS(dDTMarc) )
If !lMV_MultFil
    oQuery:SetString( nNumQuery++, FwxFilial("ABB",cFilFun) )
EndIf

cAliasABB := oQuery:OpenAlias()

dbSelectArea(cAliasABB)
While (cAliasABB)->(!Eof())
    aAdd(aRet,{(cAliasABB)->RECABB,;
                !(Empty((cAliasABB)->ABB_HRCHIN).Or.Empty((cAliasABB)->ABB_MARENT)),;
                !(Empty((cAliasABB)->ABB_HRCOUT).Or.Empty((cAliasABB)->ABB_MARSAI)),;
                TRIM((cAliasABB)->ABB_HRINI),;
                TRIM((cAliasABB)->ABB_HRFIM),;
                .F.,;
                .F.,;
                SToD((cAliasABB)->ABB_DTCHIN),;
                SToD((cAliasABB)->ABB_DTCHOU),;
                (cAliasABB)->ABB_HRCHIN,;
                (cAliasABB)->ABB_HRCOUT,;
                (cAliasABB)->ABB_MARENT,;
                (cAliasABB)->ABB_MARSAI,;
                .F.})
    (cAliasABB)->(DbSkip())
EndDo
(cAliasABB)->(DbCloseArea())

If ValType(oQuery) == "O"
    oQuery:Destroy()
    FwFreeObj(oQuery)
EndIf

RestArea(aArea)

// Intrajornada (sem intervalo): fim do primeiro periodo = inicio do segundo
If Len(aRet) == 2
    If aRet[1,5] == aRet[2,4]
        aRet[1,14] := .T.
        aRet[2,14] := .T.
    EndIf
EndIf

Return aRet

