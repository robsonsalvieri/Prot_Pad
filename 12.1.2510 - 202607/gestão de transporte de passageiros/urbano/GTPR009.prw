#INCLUDE 'TOTVS.CH'
#INCLUDE 'GTPR009.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR009
	Relatório operacional de viagem - ROV

    @type  Function
	@author Silas Gomes
	@since 30/10/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Function GTPR009()

    Local oReport as object

    oReport := Nil

    If ( !FindFunction("GTPHASACCESS") .Or. ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

        If Pergunte("GTPR009", .T.)
            oReport := ReportDef()
            oReport:PrintDialog()
        EndIf
    
    EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
	Função responsável pela criação de interface de impressão
    @type  Function
	@author Silas Gomes
	@since 30/10/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

    Local oReport   as object
    Local oSection  as object
    Local oSection2 as object
    Local oSection3 as object

    oReport := TReport():New("GTPR009", STR0001, "GTPR009", {|oReport| ReportPrint(oReport)}, "" ) //Relatório operacional de viagem - ROV
    oReport:SetTotalInLine(.T.)
    oReport:SetPortrait()  // Visualiza tipo retrato

    oSection  := TRSection():New(oReport, "Info"   , "H7F", , .F., .T., , , , , , , , , , .T.)
    oSection2 := TRSection():New(oReport, "Colab"  , "GYG", , .F., .T., , , , , , , , , , .T.)
    oSection3 := TRSection():New(oReport, "Viagens", "H7F", , .F., .T., , , , , , , , , , .T.)
    oSection3:SetLeftMargin(2)

    TRCell():New(oSection, "H6V_DESCRI" , "H6V", STR0002, X3Picture("H6V_DESCRI"), 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //LINHA
    TRCell():New(oSection, "H7F_DATA"   , "H7F", STR0003, X3Picture("H7F_DATA")  , 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //DATA
    TRCell():New(oSection, "H73_HRINI"  , "H73", STR0004, X3Picture("H73_HRINI") , 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //HORA SAIDA
    TRCell():New(oSection, "H7G_PREFIX" , "H7G", STR0005, X3Picture("H7G_PREFIX"), 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //VEÍCULO

    TRCell():New(oSection2, "MOTORISTA" , "GYG", STR0006,, 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //MOTORISTA
    TRCell():New(oSection2, "COBRADOR"  , "GYG", STR0007,, 80,,, "LEFT",, "RIGTH",,,.T.,,,.T.) //COBRADOR
    
    TRCell():New(oSection3, "H77_HRINIC", "H77", STR0008, X3Picture("H77_HRINIC"), 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //INICIO VIAGEM
    TRCell():New(oSection3, "H77_HRFINA", "H77", STR0009, X3Picture("H77_HRFINA"), 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //FINAL VIAGEM
    TRCell():New(oSection3, "ROLETAINI" , "H77", STR0010,, 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //INICIO ROLETA
    TRCell():New(oSection3, "ROLETAFIN" , "H77", STR0011,, 80,,, "LEFT",, "LEFT",,,.T.,,,.T.) //FINAL ROLETA

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
	Função responsável pela criação de interface de impressão
    @type  Function
	@author Silas Gomes
	@since 30/10/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)    

    Local oSection  as object
    Local oSection2 as object
    Local oSection3 as object
    Local oQuery    as object
    Local cAlias    as character
    Local cQuery    as character
    Local cParam1   as character
    Local cParam2   as character
    Local cParam3   as character
    Local cParam4   as character
    Local cMatMoto  as character
    Local cMatCob   as character
    Local cLinha    as character
    Local cData     as character
    Local lLinha    as logical

    oSection  := oReport:Section(1)
    oSection2 := oReport:Section(2)
    oSection3 := oReport:Section(3)
    oQuery    := Nil
    cAlias    := ""
    cQuery    := ""
    cParam1   := MV_PAR01 //Linha de
    cParam2   := MV_PAR02 //Linha até
    cParam3   := DTOS(MV_PAR03) //Data início
    cParam4   := DTOS(MV_PAR04) //Data final
    cMatMoto  := ''
    cMatCob   := ''
    cLinha    := ''
    cData     := ''
    lLinha    := .T.

    cQuery := " SELECT DISTINCT "
    cQuery +=   " H6V.H6V_FILIAL FILIAL, "
    cQuery +=   " H6V.H6V_CODLIN CODLINHA, "
    cQuery +=   " H6V.H6V_DESCRI LINHA, "
    cQuery +=   " H7F.H7F_DATA DIA, "
    cQuery +=   " H73.H73_HRINI HRINICIO, "
    cQuery +=   " H7G.H7G_PREFIX VEICULO, "
    cQuery +=   " H7G.H7G_CODGYG MOTORISTA, "
    cQuery +=   " H7G.H7G_CODCOB COBRADOR, "
    cQuery +=   " H77.H77_HRINIC INIVIAGEM, "
    cQuery +=   " H77.H77_HRFINA FINVIAGEM "
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
    cQuery +=   " LEFT JOIN ? H7F "
    cQuery +=       " ON H7F.H7F_FILIAL = H7G.H7G_FILIAL "
    cQuery +=           " AND H7F.H7F_CODIGO = H7G.H7G_CODH7F "
    cQuery +=           " AND H7F.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE H6V.H6V_FILIAL = ? "
    cQuery +=   " AND H6V.H6V_CODIGO >= ? AND H6V.H6V_CODIGO <= ? "
    cQuery +=   " AND H7F.H7F_DATA BETWEEN ? AND ? "
    cQuery +=   " AND H6V.H6V_STATUS = ? "
    cQuery +=   " AND H6V.D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetUnsafe(1, RetSqlName("H6V"))
    oQuery:SetUnsafe(2, RetSqlName("H77"))
    oQuery:SetString(3, xFilial("H77"))
    oQuery:SetUnsafe(4, RetSqlName("H73"))
    oQuery:SetString(5, xFilial("H73"))
    oQuery:SetUnsafe(6, RetSqlName("H7G"))
    oQuery:SetString(7, xFilial("H7G"))
    oQuery:SetUnsafe(8, RetSqlName("H7F"))

    //WHERE
    oQuery:SetString(9, xFilial("H6V"))
    oQuery:SetString(10, cParam1)
    oQuery:SetString(11, cParam2)
    oQuery:SetString(12, cParam3)
    oQuery:SetString(13, cParam4)
    oQuery:SetString(14, '1')

    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery( cQuery )

    oReport:SetMeter((cAlias)->(LastRec()))

    While (cAlias)->(!EoF())
        oSection:Init()
        oReport:IncMeter()

        cLinha := (cAlias)->CODLINHA
        cData  := (cAlias)->DIA

        cMatMoto := POSICIONE("GYG", 1, xFilial("GYG") + (cAlias)->MOTORISTA, "GYG_FUNCIO") + ' - ' + POSICIONE("GYG", 1, xFilial("GYG") + (cAlias)->MOTORISTA, "GYG_NOME")
        cMatCob := POSICIONE("GYG", 1, xFilial("GYG") + (cAlias)->COBRADOR, "GYG_FUNCIO") + ' - ' + POSICIONE("GYG", 1, xFilial("GYG") + (cAlias)->COBRADOR, "GYG_NOME")

        If lLinha
            oSection:Cell("H6V_DESCRI"):SetValue(AllTrim((cAlias)->CODLINHA) + " - " + AllTrim((cAlias)->LINHA))
            oSection:Cell("H7F_DATA"):SetValue( DTOC(STOD((cAlias)->DIA)))
            oSection:Cell("H73_HRINI"):SetValue(AllTrim((cAlias)->HRINICIO))
            oSection:Printline()
        
            oSection2:Init()        
            oSection2:Cell("MOTORISTA"):SetValue(cMatMoto)
            oSection2:Cell("COBRADOR"):SetValue(cMatCob)
            oSection2:Printline()

        EndIf

        oSection3:Init()

        oSection3:Cell("H77_HRINIC"):SetValue(AllTrim((cAlias)->INIVIAGEM))
        oSection3:Cell("H77_HRFINA"):SetValue(AllTrim((cAlias)->FINVIAGEM))
        oSection3:Cell("ROLETAINI"):SetValue(STR0012)
        oSection3:Cell("ROLETAFIN"):SetValue(STR0012)

        oSection3:Printline()

        (cAlias)->(DbSkip())

        If cLinha <> (cAlias)->CODLINHA .Or. cData <> (cAlias)->DIA
            lLinha := .T.
            oSection2:Finish()
            oSection3:Finish()
            oReport:EndPage()
            oSection:Finish()
        Else
            lLinha := .F.
        EndIf

    EndDo

    (cAlias)->(DBCloseArea())

Return
