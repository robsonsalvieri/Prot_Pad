#INCLUDE 'TOTVS.CH'
#INCLUDE 'GTPR010A.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR010A
	Relatório de escala de serviço local
    @type  Function
	@author Silas Gomes
	@since 16/10/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Function GTPR010A()

    Local oReport as object

    oReport := Nil

    If ( !FindFunction("GTPHASACCESS") .Or. ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) )

        If Pergunte("GTPR010A", .T.)
            oReport := ReportDef()
            oReport:PrintDialog()
        EndIf

    EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
	Função responsável pela criação de interface de imppressão
    @type  Function
	@author Silas Gomes
	@since 09/10/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

    Local oReport   as object
    Local oSection  as object
    Local oSection1 as object
    Local oSection3 as object

    oReport := TReport():New("GTPR010A", STR0001, "GTPR010A", {|oReport| ReportPrint(oReport)}, "" ) //"Escala de serviço local"
    oReport:SetTotalInLine(.T.)
    oReport:SetLandscape()

    oSection := TRSection():New(oReport , "Dia",      "H7F",, .F., .T.,,,,,,,,,, .T.)

    oSection1 := TRSection():New(oReport, "Pegada",    "H76",, .F., .T.,,,,,,,,,, .T.)

    oSection3 := TRSection():New(oReport, "Serviços", "H73",, .F., .T.)
    oSection3:SetLeftMargin(1)

    TRCell():New(oSection, "H7F_DATA"    , "H6V", "  " ,                          , 80,,, "CENTER",, "CENTER",,,.T.,,,.T.) //DATA

    TRCell():New(oSection1, "PEGADA"     , "H76", "  " ,                          , 80,,, "CENTER",, "CENTER",,,.T.,,,.T.) //PEGADA

    TRCell():New(oSection3, "H6V_DESCRI" , "H6V", STR0002, X3Picture("H6V_DESCRI"), 40,,, "LEFT",,,,, .T.) //LINHA
    TRCell():New(oSection3, "H73_CODIGO" , "H73", STR0003, X3Picture("H73_CODIGO"), 40,,, "LEFT",,,,, .T.) //ESCALA
    TRCell():New(oSection3, "H7G_PREFIX" , "H7G", STR0004, X3Picture("H7G_PREFIX"), 40,,, "LEFT",,,,, .T.) //VEICULO
    TRCell():New(oSection3, "VEICULO_RES",      , STR0005,                        , 45,,, "LEFT",,,,, .T.) //VEIC.RES
    TRCell():New(oSection3, "H7G_CODGYG" , "GYG", STR0006, X3Picture("H7G_CODGYG"), 50,,, "LEFT",,,,, .T.) //MOTORISTA
    TRCell():New(oSection3, "MOTO_RES"   ,      , STR0007,                        , 46,,, "LEFT",,,,, .T.) //MOTO.RES
    TRCell():New(oSection3, "H7G_CODCOB" , "GYG", STR0008, X3Picture("H7G_CODCOB"), 45,,, "LEFT",,,,, .T.) //COBRADOR
    TRCell():New(oSection3, "COBR_RES"   ,      , STR0009,                        , 45,,, "LEFT",,,,, .T.) //COB.RES
    TRCell():New(oSection3, "H73_HRINI"  , "H73", STR0012,                        , 50,,, "LEFT",,,,, .T.) //INIC.JORNADA
    TRCell():New(oSection3, "SAIDA_GAR"  ,      , STR0011,                        , 64,,, "LEFT",,,,, .T.) //SAIDA GARAG.
    TRCell():New(oSection3, "H73_HRPART" , "H73", STR0010,                        , 40,,, "LEFT",,,,, .T.) //INIC. LINHA
    TRCell():New(oSection3, "H73_HRCHEG" , "H73", STR0023, X3Picture("H73_HRCHEG"), 40,,, "LEFT",,,,, .T.) //SAIDA LINHA
    TRCell():New(oSection3, "H73_HRTERM" , "H73", STR0014, X3Picture("H73_HRTERM"), 50,,, "LEFT",,,,, .T.) //TERM.JORNADA
    TRCell():New(oSection3, "ENCER_UNICO",      , STR0015,                        , 56,,, "LEFT",,,,, .T.) //ENCER.UNICO.
    TRCell():New(oSection3, "H6V_ORIDES" , "H6V", STR0016, X3Picture("H6V_ORIDES"), 98,,, "LEFT",,,,, .T.) //LOCAL DO INÍCIO.

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
	Função responsável pela criação de interface de impressão
    @type  Function
	@author Silas Gomes
	@since 09/10/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)

    Local oSection  as object
    Local oSection1 as object
    Local oSection3 as object
    Local oQuery    as object
    Local oQuery2   as object
    Local cAlias    as character
    Local cAlias2   as character
    Local cQuery    as character
    Local cQuery2   as character
    Local cParam1   as character
    Local cParam2   as character
    Local cParam3   as character
    Local cParam4   as character
    Local cMatMoto  as character
    Local cMatCob   as character
    Local cData     as character
    Local cPegadaI  as character
    Local cPegadaIF as character
    Local lDia      as logical
    Local lPegada   as logical

    oSection  := oReport:Section(1)
    oSection1 := oReport:Section(2)
    oSection3 := oReport:Section(3)
    oQuery    := Nil
    oQuery2   := Nil
    cAlias    := ""
    cAlias2   := ""
    cQuery    := ""
    cQuery2   := ""
    cParam1   := MV_PAR01 //Linha de
    cParam2   := MV_PAR02 //Linha até
    cParam3   := DTOS(MV_PAR03) //Data início
    cParam4   := DTOS(MV_PAR04) //Data final
    cMatMoto  := ''
    cMatCob   := ''
    cData     := ''
    lDia      := .T.
    lPegada   := .T.

    cQuery := " SELECT DISTINCT "
    cQuery +=   " H6V.H6V_FILIAL FILIAL, "
    cQuery +=   " H7F.H7F_DATA DIA, "
    cQuery +=   " H6V.H6V_CODLIN CODLINHA, "
    cQuery +=   " H6V.H6V_DESCRI LINHA, "
    cQuery +=   " H7F.H7F_DESH76 SERVICO, "
    cQuery +=   " H7G.H7G_PREFIX PRFVEICULO, "
    cQuery +=   " H7G.H7G_CODGYG MOTORISTA, "
    cQuery +=   " H7G.H7G_CODCOB COBRADOR, "
    cQuery +=   " H73.H73_HRINI HRINICIO, "
    cQuery +=   " H73.H73_HRCHEG SAIDALIN, "
    cQuery +=   " H73.H73_HRTERM HRTERMINO, "
    cQuery +=   " H6V.H6V_ORIGEM CODORI, "
    cQuery +=   " H76.H76_PEGINI PEGADAINI,"
    cQuery +=   " H6V.H6V_ORIDES ORIGEM "
    cQuery += " FROM ? H6V "
    cQuery +=   " LEFT JOIN ? H77 "
    cQuery +=       " ON H77.H77_FILIAL = ? "
    cQuery +=           " AND H77.H77_CODH6V = H6V.H6V_CODIGO "
    cQuery +=           " AND H77.D_E_L_E_T_ = '' "
    cQuery +=   " LEFT JOIN ? H73 "
    cQuery +=       " ON H73.H73_FILIAL = ? "
    cQuery +=           " AND H73.H73_CODIGO = H77.H77_CODH73 "
    cQuery +=           " AND H73.D_E_L_E_T_ = '' "
    cQuery +=   " INNER JOIN ? H7G "
    cQuery +=       " ON H7G.H7G_FILIAL = ? "
    cQuery +=           " AND H7G.H7G_CODH76 = H77.H77_CODH76 "
    cQuery +=           " AND H7G.H7G_CODH77 = H77.H77_CODIGO "
    cQuery +=           " AND H7G.D_E_L_E_T_ = '' "

    cQuery += " INNER JOIN ? H76 "
    cQuery += "       ON H76.H76_FILIAL = ? "
    cQuery += "       AND H76.H76_CODIGO = H7G.H7G_CODH76 "
    cQuery += "       AND H76.D_E_L_E_T_ = ' ' "

    cQuery +=   " LEFT JOIN ? H7F "
    cQuery +=       " ON H7F.H7F_FILIAL = H7G.H7G_FILIAL "
    cQuery +=           " AND H7F.H7F_CODIGO = H7G.H7G_CODH7F "
    cQuery +=           " AND H7F.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE H6V.H6V_FILIAL = ? "
    cQuery +=   " AND H6V.H6V_CODIGO >= ? AND H6V.H6V_CODIGO <= ? "
    cQuery +=   " AND H7F.H7F_DATA BETWEEN ? AND ? "
    cQuery +=   " AND H6V.H6V_STATUS = ? "
    cQuery +=   " AND H76.H76_PEGINI >= ? AND H76.H76_PEGINI <= ? "
    cQuery +=   " AND H6V.D_E_L_E_T_ = '' "
    cQuery += "ORDER BY H7F.H7F_DATA, H6V.H6V_CODLIN"

    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetUnsafe(1, RetSqlName("H6V"))
    oQuery:SetUnsafe(2, RetSqlName("H77"))
    oQuery:SetString(3, xFilial("H77"))
    oQuery:SetUnsafe(4, RetSqlName("H73"))
    oQuery:SetString(5, xFilial("H73"))
    oQuery:SetUnsafe(6, RetSqlName("H7G"))
    oQuery:SetString(7, xFilial("H7G"))
    oQuery:SetUnsafe(8, RetSqlName("H76"))
    oQuery:SetString(9, xFilial("H76"))
    oQuery:SetUnsafe(10, RetSqlName("H7F"))

    //WHERE
    oQuery:SetString(11, xFilial("H6V"))
    oQuery:SetString(12, cParam1)
    oQuery:SetString(13, cParam2)
    oQuery:SetString(14, cParam3)
    oQuery:SetString(15, cParam4)
    oQuery:SetString(16, '1')
    oQuery:SetString(17, MV_PAR05)
    oQuery:SetString(18, MV_PAR06)

    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery( cQuery )

    oReport:SetMeter((cAlias)->(LastRec()))

    While (cAlias)->(!EoF())
        oSection:Init()
        oReport:IncMeter()
        IncProc(STR0017)

        cData    := (cAlias)->DIA
        cPegadaI := (cAlias)->PEGADAINI

        cMatMoto := POSICIONE("GYG",1,xFilial("GYG") + (cAlias)->MOTORISTA, "GYG_FUNCIO")
        cMatCob := POSICIONE("GYG",1,xFilial("GYG") + (cAlias)->COBRADOR, "GYG_FUNCIO")

        If lDia
            oSection:Cell("H7F_DATA"):SetValue( DTOC(STOD((cAlias)->DIA)) + " - " + DIASEMANA(SToD((cAlias)->DIA)))
            oSection:Printline()
        EndIf

        If lDia .Or. lPegada
            cPegadaIF := ALLTRIM((cAlias)->PEGADAINI) + ' - ' + POSICIONE("GI1", 1, xFilial("GI1") + (cAlias)->PEGADAINI, "GI1_DESCRI")
            oSection1:Init()
            oSection1:Cell("PEGADA"):SetValue( STR0021 + ALLTRIM(cPegadaIF) + SPACE(10))
            oSection1:Printline()
        EndIf

        cQuery2 := " SELECT "
        cQuery2 += " MIN(H7G_HRINIC) HRPARTIDA, "
        cQuery2 += " MAX(H7G_HRFINA) HRCHEGADA "
        cQuery2 += " FROM ? H7G "
        cQuery2 += " INNER JOIN ? H7F "
        cQuery2 += "    ON H7F.H7F_FILIAL = H7G.H7G_FILIAL "
        cQuery2 +=      " AND H7F.H7F_CODIGO = H7G.H7G_CODH7F "
        cQuery2 +=      " AND H7F.H7F_DATA = ? "
        cQuery2 +=      " AND H7F.D_E_L_E_T_ = '' "
        cQuery2 += " WHERE H7G.H7G_FILIAL = ? "
        cQuery2 +=      " AND H7G.H7G_CODGYG = ? "
        cQuery2 +=      " AND H7G.H7G_CODCOB = ? "
        cQuery2 +=      " AND H7G.H7G_PREFIX = ? "
        cQuery2 +=      " AND H7G.D_E_L_E_T_ = '' "

        cQuery2 := ChangeQuery(cQuery2)
        oQuery2 := FWPreparedStatement():New(cQuery2)
        oQuery2:SetUnsafe(1, RetSqlName("H7G"))
        oQuery2:SetUnsafe(2, RetSqlName("H7F"))
        oQuery2:SetString(3, (cAlias)->DIA)
        oQuery2:SetString(4, xFilial("H7G"))
        oQuery2:SetString(5, (cAlias)->MOTORISTA )
        oQuery2:SetString(6, (cAlias)->COBRADOR )
        oQuery2:SetString(7, (cAlias)->PRFVEICULO )

        cQuery2 := oQuery2:GetFixQuery()
        cAlias2 := MPSysOpenQuery( cQuery2 )

        oSection3:Init()

        oSection3:Cell("H6V_DESCRI"):SetValue(AllTrim((cAlias)->CODLINHA))
        oSection3:Cell("H73_CODIGO"):SetValue(AllTrim((cAlias)->SERVICO))
        oSection3:Cell("H7G_PREFIX"):SetValue(AllTrim((cAlias)->PRFVEICULO))
        oSection3:Cell("VEICULO_RES"):SetValue(STR0018)
        oSection3:Cell("H7G_CODGYG"):SetValue(cMatMoto)
        oSection3:Cell("MOTO_RES"):SetValue(STR0018)
        oSection3:Cell("H7G_CODCOB"):SetValue(cMatCob)
        oSection3:Cell("COBR_RES"):SetValue(STR0018)
        oSection3:Cell("H73_HRINI"):SetValue(AllTrim((cAlias)->HRINICIO))
        oSection3:Cell("SAIDA_GAR"):SetValue(STR0018)

        If (cAlias2)->(!EoF())
            oSection3:Cell("H73_HRPART"):SetValue(Padl(AllTrim((cAlias2)->HRPARTIDA),5,"0"))
        EndIf

        oSection3:Cell("H73_HRCHEG"):SetValue(AllTrim((cAlias)->SAIDALIN))
        oSection3:Cell("H73_HRTERM"):SetValue(AllTrim((cAlias)->HRTERMINO))
        oSection3:Cell("ENCER_UNICO"):SetValue(STR0018)
        oSection3:Cell("H6V_ORIDES"):SetValue(AllTrim((cAlias)->CODORI) + ' - ' + AllTrim((cAlias)->ORIGEM) )

        oSection3:Printline()

        (cAlias)->(DbSkip())

        If cData <> (cAlias)->DIA
            lDia := .T.
            oReport:SkipLine(10)
            oReport:PrintText(STR0019) //"Assinatura dos Responsaveis."

            oReport:SkipLine(15)
            oReport:PrintText(STR0020)

            oSection1:Finish()
            oSection3:Finish()
            oReport:EndPage()
            oSection:Finish()

        Else
            lDia := .F.
            If (cPegadaI <> (cAlias)->PEGADAINI)
                lPegada := .T.
                oSection1:Finish()
                oSection3:Finish()
            Else
                lPegada := .F.
            EndIf
        EndIf

    EndDo

    (cAlias)->(DBCloseArea())

Return
