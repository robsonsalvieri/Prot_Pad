#INCLUDE 'TOTVS.CH'
#include 'GTPR010.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR010
	Relatório de escala de colaborador
    @type  Function
	@author Silas Gomes
	@since 09/10/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Function GTPR010()

    Local oReport as object

    oReport := Nil

    If ( !FindFunction("GTPHASACCESS") .Or. ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

        If Pergunte("GTPR010", .T.)
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
    Local oSection2 as object

    oReport := TReport():New("GTPR010", STR0001, "GTPR010", {|oReport| ReportPrint(oReport)}, "" ) //"Relatório de escala de colaborador"
    oReport:SetTotalInLine(.T.)
    oReport:SetPortrait()  // Visualiza tipo retrato

    oSection := TRSection():New(oReport, "Colaborador", "GYG",, .F., .T.,,,, .T.,,,,,, .T.)
    TRCell():New(oSection, "GYG_FUNCIO", "GYG", STR0002, X3Picture("GYG_FUNCIO"), 80, , , "LEFT",,,,,,,,.T.) //COLABORADOR

    oSection2 := TRSection():New(oReport, "Horarios", "H73",, .F., .T., , , , .T.)
    oSection2:SetLeftMargin(2)

    TRCell():New(oSection2, "H7F_DATA"   ,  "H7F",  STR0003,                         ,  20,,, "LEFT") //DATA
    TRCell():New(oSection2, "H73_HRINI"  ,  "H73",  STR0004, X3Picture("H73_HRINI")  ,  20,,, "LEFT") //INÍCIO
    TRCell():New(oSection2, "H73_HRTERM" ,  "H73",  STR0005, X3Picture("H73_HRTERM") ,  20,,, "LEFT") //TÉRMINO
    TRCell():New(oSection2, "H7G_DSCLIN" ,  "H7G",  STR0006, X3Picture("H7G_DSCLIN") ,  75,,, "LEFT") //LINHA
    TRCell():New(oSection2, "H71_ORIGEM" ,  "H71",  STR0007, X3Picture("H71_ORIGEM") ,  70,,, "LEFT") //LOCAL DO INÍCIO
    TRCell():New(oSection2, "H7R_TIPO"   ,  "H7R",  STR0008, X3Picture("H7R_TIPO")   ,  30,,, "LEFT") //SITUAÇÃO

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
	Função responsável pela criação de interface de imppressão
    @type  Function
	@author Silas Gomes
	@since 09/10/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)    

    Local oSection   as object
    Local oSection2  as object
    Local oQuery     as object
    Local cAliasGYG  as character
    Local cAlias2    as character
    Local cQuery     as character
    Local cQuery2    as character
    Local cParam1    as character
    Local cParam2    as character
    Local cParam3    as character
    Local cParam4    as character
    Local cHrInicio  as character
    Local cHrTermino as character
    Local cCodColab  as character

    oSection   := oReport:Section(1)
    oSection2  := oReport:Section(2)
    oQuery     := Nil
    cAliasGYG  := ""
    cAlias2    := ""
    cQuery     := ""
    cQuery2    := ""
    cParam1    := MV_PAR01 //Colaborador de ?
    cParam2    := MV_PAR02 //Colaborador até ?
    cParam3    := DTOS(MV_PAR03) //Data ate
    cParam4    := DTOS(MV_PAR04) //Data ate
    cHrInicio  := ""
    cHrTermino := ""
    cCodColab  := ""

    cQuery := " SELECT DISTINCT "
    cQuery += "     GYG.GYG_FILIAL FILIAL, "
    cQuery += "     GYG.GYG_FUNCIO REGISTRO, "
    cQuery += "     GYG.GYG_NOME NOME, "
    cQuery += "     H71.H71_CODLIN CODLIN, "
    cQuery += "     H7G.H7G_DSCLIN LINHA, "
    cQuery += "     H7F.H7F_DATA DIA, "
    cQuery += "     H7R.H7R_TIPO SITUACAO, "
    cQuery += "     H71.H71_ORIGEM LOCALINI "
    cQuery += " FROM ? GYG "
    cQuery += "     LEFT JOIN ? H7G "
    cQuery += "         ON H7G.H7G_FILIAL = ? "
    cQuery += "         AND H7G.H7G_CODGYG = GYG.GYG_CODIGO "
    cQuery += "             OR H7G.H7G_CODCOB = GYG.GYG_CODIGO "
    cQuery += "         AND H7G.D_E_L_E_T_ = '' "
    cQuery += "     LEFT JOIN ? H7F "
    cQuery += "         ON H7F.H7F_FILIAL = H7G.H7G_FILIAL "
    cQuery += "             AND H7F.H7F_CODIGO = H7G.H7G_CODH7F "
    cQuery += "             AND H7F.D_E_L_E_T_ = '' "
    cQuery += "     LEFT JOIN ? H7R "
    cQuery += "         ON H7R.H7R_FILIAL = ? "
    cQuery += "             AND H7R.H7R_COLAB = GYG.GYG_CODIGO "
    cQuery += "             AND H7F.H7F_DATA = H7R.H7R_DATA "
    cQuery += "             AND H7R.D_E_L_E_T_ = '' "
    cQuery += "     LEFT JOIN ? H71 "
    cQuery += "         ON H71.H71_FILIAL = ? "
    cQuery += "             AND H71.H71_CODH6V = H7G.H7G_CODH6V "
    cQuery += "             AND H71.H71_STATUS = '1' "
    cQuery += "             AND H71.D_E_L_E_T_ = '' "
    cQuery += " WHERE GYG.GYG_FILIAL = ? "
    cQuery += "     AND H7F.H7F_DATA BETWEEN ? AND ? "
    cQuery += "     AND GYG.GYG_CODIGO >= ? AND GYG.GYG_CODIGO <= ? "
    cQuery += "     AND GYG.GYG_STATUS = '1' "
    cQuery += "     AND GYG.D_E_L_E_T_ = '' "
    cQuery += " GROUP BY GYG.GYG_FILIAL, GYG.GYG_FUNCIO, GYG.GYG_NOME, H71.H71_CODLIN, H7G.H7G_DSCLIN, H7F.H7F_DATA, H7R.H7R_TIPO, H71.H71_ORIGEM "

    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetUnsafe(1, RetSqlName("GYG"))
    oQuery:SetUnsafe(2, RetSqlName("H7G"))
    oQuery:SetString(3, xFilial("H7G"))
    oQuery:SetUnsafe(4, RetSqlName("H7F"))
    oQuery:SetUnsafe(5, RetSqlName("H7R"))
    oQuery:SetString(6, xFilial("H7R"))
    oQuery:SetUnsafe(7, RetSqlName("H71"))
    oQuery:SetString(8, xFilial("H71"))
    oQuery:SetString(9, xFilial("GYG"))
    oQuery:SetString(10, cParam3)
    oQuery:SetString(11, cParam4)
    oQuery:SetString(12, cParam1)
    oQuery:SetString(13, cParam2)

    cQuery := oQuery:GetFixQuery()
    cAliasGYG := MPSysOpenQuery( cQuery )

    oReport:SetMeter((cAliasGYG)->(LastRec()))

    While (cAliasGYG)->(!EoF())
        oSection:Init()
        oReport:IncMeter()
        IncProc(STR0009)

        If !(oSection:Cell("GYG_FUNCIO"):GetValue() == AllTrim((cAliasGYG)->REGISTRO) + " - " + AllTrim((cAliasGYG)->NOME))
            oSection:Cell("GYG_FUNCIO"):SetValue(AllTrim((cAliasGYG)->REGISTRO) + " - " + AllTrim((cAliasGYG)->NOME))
            oSection:Printline()
            oSection2:Init()
        EndIf

        cCodColab := POSICIONE("GYG", 2, xFilial("GYG") + (cAliasGYG)->REGISTRO, "GYG_CODIGO")

        cQuery2 := " SELECT "
        cQuery2 +=  " MIN(H7G_HRINIC) HRPARTIDA, "
        cQuery2 +=  " MAX(H7G_HRFINA) HRCHEGADA "
        cQuery2 += " FROM ? H7G "
        cQuery2 += " INNER JOIN ? H7F "
        cQuery2 += "    ON H7F.H7F_FILIAL = H7G.H7G_FILIAL "
        cQuery2 +=      " AND H7F.H7F_CODIGO = H7G.H7G_CODH7F "
        cQuery2 +=      " AND H7F.H7F_DATA = ? "
        cQuery2 +=      " AND H7F.D_E_L_E_T_ = '' "
        cQuery2 += " WHERE H7G.H7G_FILIAL = ? "
        cQuery2 +=      " AND (H7G.H7G_CODGYG = ? " 
        cQuery2 +=          " OR H7G.H7G_CODCOB = ?)
        cQuery2 +=      " AND H7G.D_E_L_E_T_ = '' "

        cQuery2 := ChangeQuery(cQuery2)
        oQuery2 := FWPreparedStatement():New(cQuery2)
        oQuery2:SetUnsafe(1, RetSqlName("H7G"))
        oQuery2:SetUnsafe(2, RetSqlName("H7F"))
        oQuery2:SetString(3, (cAliasGYG)->DIA)
        oQuery2:SetString(4, xFilial("H7G"))
        oQuery2:SetString(5, cCodColab )
        oQuery2:SetString(6, cCodColab )

        cQuery2 := oQuery2:GetFixQuery()
        cAlias2 := MPSysOpenQuery( cQuery2 )

        If Len(AllTrim((cAlias2)->HRPARTIDA)) < TamSx3("H73_HRINI")[1]
            cHrInicio  := SubStr(AllTrim((cAlias2)->HRPARTIDA), 1, 2) + ':' + SubStr(AllTrim((cAlias2)->HRPARTIDA), 3, 4)
        Else
            cHrInicio := AllTrim((cAlias2)->HRPARTIDA)
        EndIf

        If Len(AllTrim((cAlias2)->HRCHEGADA)) < TamSx3("H73_HRTERM")[1]
            cHrTermino := SubStr(AllTrim((cAlias2)->HRCHEGADA), 1, 2) + ':' + SubStr(AllTrim((cAlias2)->HRCHEGADA), 3, 4)
        Else
            cHrTermino := AllTrim((cAlias2)->HRCHEGADA)
        EndIf

        oSection2:Cell("H7F_DATA"):SetValue(SToD((cAliasGYG)->DIA))

        If !Empty((cAliasGYG)->SITUACAO) .And. (cAliasGYG)->SITUACAO <> '1'

            oSection2:Cell("H73_HRINI"):SetValue("")
            oSection2:Cell("H73_HRTERM"):SetValue("")
            oSection2:Cell("H7G_DSCLIN"):SetValue("")
            oSection2:Cell("H71_ORIGEM"):SetValue("")

            Do Case                   
                Case (cAliasGYG)->SITUACAO == '2'
                    oSection2:Cell("H7R_TIPO"):SetValue(STR0010) //Férias
                Case (cAliasGYG)->SITUACAO == '3'
                    oSection2:Cell("H7R_TIPO"):SetValue(STR0011) //Afastado
                Case (cAliasGYG)->SITUACAO == '4'
                    oSection2:Cell("H7R_TIPO"):SetValue(STR0012) //Folga
                Case (cAliasGYG)->SITUACAO == '5'
                    oSection2:Cell("H7R_TIPO"):SetValue(STR0013) //Não Trabalhado
                Case (cAliasGYG)->SITUACAO == '6'
                    oSection2:Cell("H7R_TIPO"):SetValue(STR0014) //Falta
            EndCase

        Else    
            oSection2:Cell("H73_HRINI"):SetValue(cHrInicio)
            oSection2:Cell("H73_HRTERM"):SetValue(cHrTermino)
            oSection2:Cell("H7G_DSCLIN"):SetValue(AllTrim((cAliasGYG)->CODLIN) + ' - ' + AllTrim((cAliasGYG)->LINHA))
            oSection2:Cell("H71_ORIGEM"):SetValue(AllTrim((cAliasGYG)->LOCALINI))
            oSection2:Cell("H7R_TIPO"):SetValue("Trabalhando") //Trabalhando
        EndIf

        oSection2:Printline()

        (cAliasGYG)->(DbSkip())

        If !(oSection:Cell("GYG_FUNCIO"):GetValue() == AllTrim((cAliasGYG)->REGISTRO) + " - " + AllTrim((cAliasGYG)->NOME))
            oSection:Finish()
            oSection2:Finish()
        EndIf    

    EndDo

    (cAliasGYG)->(DBCloseArea())
Return
