#Include "TOTVS.ch"
#Include "TOPCONN.CH"
#Include "TECR027.CH"
Static cAutoPerg := "TECR027"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR027
Relatorio de Locais x Supervisores

@author Junior Geraldo Dos Santos
@since 05/02/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------

Function TECR027()

Local oReport

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Supervisor de ?											   ³
//³ MV_PAR02 : Supervisor ate ?											   ³
//³ MV_PAR03 : Local de ?												   ³
//³ MV_PAR04 : Local ate ?												   ³
//³ MV_PAR05 : Data de ?												   ³
//³ MV_PAR06 : Data ate?												   ³
//³ MV_PAR07 : Área de Supervisor ?                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Pergunte("TECR027",.T.)
	Return
EndIf

oReport := ReportDef()
oReport:PrintDialog()
Return
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Monta as definições do relatorio de Supervisores de Locais de Atendimento

@author  Junior Geraldo Dos Santos
@version P12.1.30
@since 	 05/02/2020
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef()

Local cTitulo := STR0001 //"Relatório de Supervisores de Locais"
Local oReport
Local oSection1
Local oSection2
Local oSection3

oReport	:= TReport():New("TECR027", cTitulo, "TECR027" , {|oReport| PrintReport(oReport)},STR0001)//"Relatório de Supervisores"

oSection1 := TRSection():New(oReport,"Supervisores","AA1")
oSection1:SetHeaderPage()
TRCell():New(oSection1,"AA1_CODTEC","AA1", STR0003)//Cód. Supervisor
TRCell():New(oSection1,"AA1_NOMTEC","AA1", STR0004)//Supervisor
TRCell():New(oSection1,"AA1_FUNCAO","AA1", STR0005)//Função
TRCell():New(oSection1,"AA1_FONE"  ,"AA1", STR0006)//Telefone

oSection2 := TRSection():New(oSection1,STR0016,"TGS")//"Área de supervisão"
TRCell():New(oSection2,"TGS_COD" 	,"TGS", STR0017) //"Código da área"
TRCell():New(oSection2,"TGS_DESCRI" ,"TGS", STR0018) //"Área"
oSection2:SetLeftMargin(02)

oSection3 := TRSection():New(oSection2,STR0013,"TXI")//Locais
TRCell():New(oSection3,"TXI_LOCAL" ,"TXI", STR0007) //"Código do Local"
TRCell():New(oSection3,"TXI_DESLOC","TXI", STR0008) //"Local"
TRCell():New(oSection3,"TXI_FUNCAO","TXI", STR0014) //"Código da Função"
TRCell():New(oSection3,"TXI_DFUNC" ,"TXI", STR0009,,20) //"Função"
TRCell():New(oSection3,"TXI_TURNO" ,"TXI", STR0015) //"Código do Turno"
TRCell():New(oSection3,"TXI_DTURNO","TXI", STR0010,,20) //"Turno"
TRCell():New(oSection3,"TXI_PERIOD","TXI", STR0019) //"Período"
TRCell():New(oSection3,"TXI_DTINI" ,"TXI", STR0011) //"Ínicio"
TRCell():New(oSection3,"TXI_DTFIM" ,"TXI", STR0012) //"Fim"
oSection3:SetLeftMargin(04)

Return oReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Gera o Relatorio Supervisores por locais

@author  Junior Geraldo dos Santos
@version P12.1.30
@since 	 05/02/2020
@return  Nil
/*/
//-------------------------------------------------------------------------------------

Static Function PrintReport(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)
Local cQuery     := ""
Local nOrder	 := 1
Local lAreaSuper := SuperGetMV("MV_GSARSUP",,.F.) // Permite habilitar uso de área de supervisão nos Locais de Atendimentos.
Local oQry       := Nil

MakeSqlExpr("TECR027")

If TableInDic("TXI")

	Private cAliasTXI := ""

	cQuery := " SELECT AA1_CODTEC,"
	cQuery +=        " AA1_NOMTEC,"
	cQuery +=        " AA1_FUNCAO,"
	cQuery +=        " AA1_FONE,"
	cQuery +=        " TXI_LOCAL,"
	cQuery +=        " ABS.ABS_LOCAL,"
	cQuery +=        " ABS.ABS_DESCRI AS TXI_DESLOC,"
	cQuery +=        " TXI_CODTEC,"
	cQuery +=        " SRJ.RJ_FUNCAO,"
	cQuery +=        " TXI_FUNCAO,"
	cQuery +=        " SRJ.RJ_DESC AS TXI_DFUNC,"
	cQuery +=        " TXI_TURNO,"
	cQuery +=        " SR6.R6_TURNO,"
	cQuery +=        " SR6.R6_DESC AS TXI_DTURNO,"
	cQuery +=        " TXI_DTINI,"
	cQuery +=        " TXI_DTFIM,"
	cQuery +=        " TXI_CODTGS,"
	cQuery +=        " TGS_COD,"
	cQuery +=        " ISNULL(TGS_DESCRI,'AREA VAZIA') TGS_DESCRI,"
	cQuery +=        " TXI_PERIOD "
	cQuery += " FROM ? AA1 "
	cQuery +=      " INNER JOIN ? TXI "
	cQuery +=              " ON TXI.TXI_FILIAL = ?"
	cQuery +=                 " AND TXI.TXI_CODTEC = AA1.AA1_CODTEC"
	cQuery +=                 " AND TXI.D_E_L_E_T_ = ' ' "
	cQuery +=      " LEFT JOIN ? TGS "
	cQuery +=             " ON TGS.TGS_FILIAL = ? "
	cQuery +=                " AND TGS.TGS_COD = TXI.TXI_CODTGS"
	cQuery +=                " AND TGS.D_E_L_E_T_ = ' ' "
	cQuery +=      " LEFT JOIN ? ABS "
	cQuery +=             " ON ABS.ABS_FILIAL = ? "
	cQuery +=                " AND ABS.ABS_LOCAL = TXI.TXI_LOCAL"
	cQuery +=                " AND ABS.D_E_L_E_T_ = ' ' "
	If lAreaSuper .And. !Empty(Alltrim(MV_PAR07))
		cQuery += " AND ? " // CODIGO DA AREA DE SUPERVISAO
	EndIf
	cQuery +=      " LEFT JOIN ? SRJ "
	cQuery +=             " ON SRJ.RJ_FILIAL = ? "
	cQuery +=                " AND SRJ.RJ_FUNCAO = TXI.TXI_FUNCAO"
	cQuery +=                " AND SRJ.D_E_L_E_T_ = ' ' "
	cQuery +=      " LEFT JOIN ? SR6 "
	cQuery +=             " ON SR6.R6_FILIAL = ? "
	cQuery +=                " AND SR6.R6_TURNO = TXI.TXI_TURNO"
	cQuery +=                " AND SR6.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE AA1_FILIAL = ? "
	cQuery +=       " AND AA1_SUPERV = '1' "
	cQuery +=       " AND TXI.TXI_CODTEC BETWEEN ? AND ? "
	cQuery +=       " AND TXI.TXI_LOCAL BETWEEN ? AND ? "
	cQuery +=       " AND ((TXI.TXI_DTINI <= ? OR TXI.TXI_DTINI BETWEEN ? AND ?)"
	cQuery +=       " AND  (TXI.TXI_DTFIM >= ? OR TXI.TXI_DTFIM BETWEEN ? AND ?) OR TXI_DTINI = ' ' OR TXI_DTFIM = ' ') "
	If !lAreaSuper .And. !Empty(Alltrim(MV_PAR07))
		cQuery +=   " AND ?" // CODIGO DA AREA DE SUPERVISAO
	EndIf
	cQuery +=       " AND AA1.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery( cQuery )
	oQry := FwExecStatement():New(cQuery)

	oQry:SetUnsafe( nOrder++, RetSqlName( "AA1" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "TXI" ) )
	oQry:SetString( nOrder++, FwxFilial( "TXI" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "TGS" ) )
	oQry:SetString( nOrder++, FwxFilial( "TGS" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "ABS" ) )
	oQry:SetString( nOrder++, FwxFilial( "ABS" ) )
	If lAreaSuper .And. !Empty(MV_PAR07)
		oQry:SetUnsafe( nOrder++, Replace(MV_PAR07,"TXI_CODTGS","ABS_CODSUP") )
	EndIf
	oQry:SetUnsafe( nOrder++, RetSqlName( "SRJ" ) )
	oQry:SetString( nOrder++, FwxFilial( "SRJ" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "SR6" ) )
	oQry:SetString( nOrder++, FwxFilial( "SR6" ) )
	oQry:SetString( nOrder++, FwxFilial( "AA1" ) )
	oQry:SetString( nOrder++, MV_PAR01 )
	oQry:SetString( nOrder++, MV_PAR02 )
	oQry:SetString( nOrder++, MV_PAR03 )
	oQry:SetString( nOrder++, MV_PAR04 )
	oQry:SetDate( nOrder++, MV_PAR05 )
	oQry:SetDate( nOrder++, MV_PAR05 )
	oQry:SetDate( nOrder++, MV_PAR06 )
	oQry:SetDate( nOrder++, MV_PAR06 )
	oQry:SetDate( nOrder++, MV_PAR05 )
	oQry:SetDate( nOrder++, MV_PAR06 )

	If !lAreaSuper .And. !Empty(Alltrim(MV_PAR07))
		oQry:SetUnsafe( nOrder++, MV_PAR07 )
	EndIf

	cAliasTXI := oQry:OpenAlias()

	oSection1:SetQuery(cAliasTXI, cQuery)

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAliasTXI)->TXI_CODTEC == cParam},{|| (cAliasTXI)->AA1_CODTEC })

	oSection3:SetParentQuery()
	oSection3:SetParentFilter({|cParam| (cAliasTXI)->TXI_CODTGS + (cAliasTXI)->TXI_CODTEC  == cParam },{||  (cAliasTXI)->TGS_COD + (cAliasTXI)->AA1_CODTEC  })

	//Executa impressão
	oSection1:Print()

	(cAliasTXI)->(DbCloseArea())
	oQry:Destroy()
	FwFreeObj(oQry)
EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Junior Geraldo
@since 05/02/2020
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg
