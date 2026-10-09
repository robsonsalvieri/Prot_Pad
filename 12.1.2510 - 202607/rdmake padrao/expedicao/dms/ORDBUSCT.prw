#Include "PROTHEUS.CH" 
#Include "TopConn.CH"
#INCLUDE "ORDBUSCB.CH"

// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º   12   º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ORDBUSCT º Autor ³ Peterson O. Paula  º Data ³ 20/05/26    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ ¹±±
±±ºDesc.    ³Imprime Ordem de Busca - Tranferência agrupada               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¹±±
±±ºUso       ³ OFIOM430                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± ±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ORDBUSCT()
    Local oReport
    Local aParams := {}
    Local cEmpr := ""
    Local nct := 0
    Local cOrcTit := ""

    Private cTitulo := ""
    Private cDesc := ""
    Private cAlias := "QRTVS3"
    Private cNomeRel := "ORDBUSCT"
    Private aOrdem := {}
    Private cOper := ""
    Private lLocAux := ( cPaisLoc == "ARG" .and. FindFunction("OA0040011_Locacoes_Auxiliares") )

    // Array de orçamentos selecionados
    // Estrutura esperada:
    // { {FILIAL, NUMORC}, {FILIAL, NUMORC} }
    Private aOrcRel := {}

    Default aORSelec := {}

    If Type("ParamIXB") != "U"
        aParams := ParamIXB
        // Primeiro parâmetro = array de orçamentos
        If Len(aParams) >= 1
            aORSelec := aParams[1]
        EndIf
        // Segundo parâmetro = empresa
        If Len(aParams) >= 2
            cEmpr := aParams[2]
        EndIf
    EndIf

    aSort(aORSelec, , , {|x, y| x[10] < y[10]}) // ordenar por Cliente+Loja

    // Caso não venha array, adiciona o orçamento corrente
    If len(aORSelec) > 0
       For nct = 1 to len(aORSelec)
           if aORSelec[nct,1] == .t. 
               AAdd(aOrcRel, { cEmpr, aORSelec[nct,2] }) 
               cOrcTit += aORSelec[nct,2] + ' / '
           endif
       next
    EndIf

    cTitulo := " "+STR0021 
    If len(aOrcRel) = 0 .or. empty(cEmpr)
        MsgAlert(STR0020) // Criar STR "Selecione pelo menos um Orçamento! "
        Return .T.
    Endif

    oReport := RptDefOT()
    oReport:nFontBody := 12
    oReport:oPage:nPaperSize := 9
    oReport:PrintDialog()

Return .T.

Static Function RptDefOT()
    Local oReport
    Local oSection1
    Local oSection2
	Local oSection3
	Local oSection4
		
	oReport := TReport():New(;
        cNomeRel,;
        cTitulo,;
        ,;
        {|oReport| RptRunOT(oReport)},;
        cDesc;
    )

    oReport:SetLineHeight(45)
    oSection1 := TRSection():New(oReport)
    oSection1:SetLinesBefore(1)
    oSection1:SetHeaderPage()

	TRCell():New(oSection1, "A1_COD"    , "SA1", STR0006,, 12) //Cód. Cli.
	TRCell():New(oSection1, "A1_NOME"   , "SA1", STR0007,, 40) //Cliente
    TrCell():New(oSection1, "A3_NOME"   , "SA3", STR0008,, 30) //Vendedor
	TRCell():New(oSection1,"VV1_FILIAL" , "VV1", STR0010,, 12) //Filial Destino

	oSection2 := TRSection():New(oReport)
    TRCell():New(oSection2, "COLP"      , ""   , ""     ,, 3)
	TRCell():New(oSection2, "NUMORC"    , ""   , STR0019,, 18) //Orçamento
	TRCell():New(oSection2, "SEQUEN"    , ""   , STR0011,, 12) //Seq
	TRCell():New(oSection2, "B1_GRUPO"  , "SB1", STR0012,, 06) //Grupo
	TRCell():New(oSection2, "B1_CODITE" , "SB1", STR0013,, 45) //Código
	TRCell():New(oSection2, "B1_DESC"   , "SB1", STR0014,, 30) //Descrição
	TRCell():New(oSection2, "B5_LOCALI2", "SB5", STR0015,, 24) //Locação
	TRCell():New(oSection2, "VS3_QTDITE", "VS3", STR0016,, 12) //Qtde.
	oSection2:SetLinesBefore(1)

	oSection3 := TRSection():New(oReport)
    TRCell():New(oSection3,"COL1",    '', '', , 10)
    TrCell():New(oSection3,"COLRESP", '', '', , 40)
    TrCell():New(oSection3,"COL3",    '', '', , 20)
    TrCell():New(oSection3,"COLPREST",'', '', , 40)
    TrCell():New(oSection3,"COL5",    '', '', , 10)
	oSection3:SetLinesBefore(5)
    oSection3:SetHeaderSection(.F.)

	If lLocAux

		oSection4 := TRSection():New(oReport,STR0018,{"SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// Locações Auxiliares
		oSection4:SetAutoSize(.t.)
		TRCell():New(oSection4, "GRUPO"  , "", RetTitle("B1_GRUPO")   , "@!" , 20,, {|| SB1->B1_GRUPO   } ,,, "LEFT" , .t.) // Grupo
		TRCell():New(oSection4, "CODITE" , "", RetTitle("B1_CODITE")  , "@!" , 30,, {|| SB1->B1_CODITE  } ,,, "LEFT" , .t.) // Codigo Item
		TRCell():New(oSection4, "cEndAux" , "", STR0018 ,	"@!" , 140,,  ,,, "LEFT" , .t.,,.t.) // Locações Auxiliares
		oSection4:SetLinesBefore(5)

	EndIf

Return oReport

Static Function RptRunOT(oReport)

    Local cQuery  := "SQLSDB"
    Local nCntFor := 0
    Local lEntrou := .F.

    Local oSection1 := oReport:Section(1)
    Local oSection2 := oReport:Section(2)
    Local oSection3 := oReport:Section(3)
    Local oSection4

    Local aRecSB1   := {}
    Local cEndVBU   := ""
    Local aRetVBU   := {}
    Local nCntSB1   := 0

    Local nOrc      := 0
    Local cFilVS1   := ""
    Local cNumOrc   := ""

    Local aTRB
    Local quebracli := ""

    If lLocAux
        oSection4 := oReport:Section(4)
    EndIf

    cAlias := "VS3"
    cDesc1 := STR0002
    aOrdem := {}

    lHabil := .F.
    lVS1_OBSNFI := .F.

    // =========================================================
    // LOOP DOS ORÇAMENTOS
    // =========================================================
    For nOrc := 1 To Len(aOrcRel)
        aTRB := {}
        aRecSB1 := {}
        lEntrou := .F.

        cFilVS1 := aOrcRel[nOrc][1]
        cNumOrc := aOrcRel[nOrc][2]

        DbSelectArea("VS1")
        DbSetOrder(1)
        If !DbSeek(xFilial("VS1") + cNumOrc)
            Loop
        EndIf

        DbSelectArea("VS3")
        DbSetOrder(1)

        If DbSeek(xFilial("VS3") + cNumOrc)
            While !Eof() .AND. VS3->VS3_FILIAL == xFilial("VS3") .AND. VS3->VS3_NUMORC == cNumOrc

                If VS3->VS3_QTDITE - VS3->VS3_QTDTRA > 0
                    lEntrou := .T.
                    Exit
                EndIf

                DbSkip()

            EndDo
        EndIf

        If !lEntrou
            Loop
        EndIf

        DbSelectArea("SA3")
        DbSetOrder(1)
        DbSeek(xFilial("SA3") + VS1->VS1_CODVEN)

        DbSelectArea("SA1")
        DbSetOrder(1)
        DbSeek(xFilial("SA1") + VS1->VS1_CLIFAT + VS1->VS1_LOJA)

        DbSelectArea("VV1")
        DbSetOrder(1)

        // =====================================================
        // PROCESSA ITENS VS3
        // =====================================================
        DbSelectArea("VS3")
        DbSetOrder(1)
        DbSeek(xFilial("VS3") + cNumOrc)

        While !Eof() .AND. VS3->VS3_FILIAL == xFilial("VS3") .AND. VS3->VS3_NUMORC == cNumOrc
            DbSelectArea("SB1")
            DbSetOrder(7)
            DbSeek(xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE)

            If Localiza(SB1->B1_COD)
                cQuery := " SELECT "
                cQuery += "     SDB.DB_LOCAL, "
                cQuery += "     SDB.DB_LOCALIZ, "
                cQuery += "     SDB.DB_QUANT "
                cQuery += " FROM "
                cQuery +=         RetSqlName("SDB") + " SDB "
                cQuery += " WHERE "
                cQuery += "     SDB.DB_FILIAL = '" + xFilial("SDB") + "' "
                cQuery += "     AND SDB.DB_PRODUTO = '" + SB1->B1_COD + "' "
                cQuery += "     AND SDB.DB_DOC = '" + VS3->VS3_DOCSDB + "' "
                cQuery += "     AND SDB.DB_QUANT > 0 "
                cQuery += "     AND SDB.DB_TM > '500' "
                cQuery += "     AND SDB.D_E_L_E_T_ = '' "
                cQuery += " ORDER BY SDB.R_E_C_N_O_ "
                TcQuery cQuery New Alias cAlias

                If !(cQuery)->(Eof())
                    Do While !(cQuery)->(Eof())
                        AADD(aTRB, ;
                            { ;
                                VS3->VS3_GRUITE, ;
                                VS3->VS3_CODITE, ;
                                Substr(SB1->B1_DESC,1,20), ;
                                (cQuery)->DB_LOCALIZ, ;
                                (cQuery)->DB_QUANT ;
                            } ;
                        )
                        (cQuery)->(DbSkip())
                    EndDo
                Else
                    DbSelectArea("SB5")
                    DbSetOrder(1)
                    DbSeek(xFilial("SB5") + SB1->B1_COD)

                    If VS3->VS3_QTDITE - VS3->VS3_QTDTRA > 0
                        AADD(aTRB, ;
                            { ;
                                VS3->VS3_GRUITE, ;
                                VS3->VS3_CODITE, ;
                                Substr(SB1->B1_DESC,1,20), ;
                                FM_PRODSBZ(SB1->B1_COD, "SB5->B5_LOCALI2"), ;
                                VS3->VS3_QTDITE - VS3->VS3_QTDTRA ;
                            } ;
                        )
                    EndIf
                EndIf
                (cQuery)->(DbCloseArea())
            Else
                DbSelectArea("SB5")
                DbSetOrder(1)
                DbSeek(xFilial("SB5") + SB1->B1_COD)

                If VS3->VS3_QTDITE - VS3->VS3_QTDTRA > 0
                    AADD(aTRB, ;
                        { ;
                            VS3->VS3_GRUITE, ;
                            VS3->VS3_CODITE, ;
                            Substr(SB1->B1_DESC,1,20), ;
                            FM_PRODSBZ(SB1->B1_COD, "SB5->B5_LOCALI2"), ;
                            VS3->VS3_QTDITE - VS3->VS3_QTDTRA ;
                        } ;
                    )
                EndIf
            EndIf

            DbSelectArea("VS3")
            DbSkip()
        EndDo

        // =====================================================
        // CABEÇALHO
        // =====================================================
        if quebracli <> (VS1->VS1_CLIFAT + VS1->VS1_LOJA)
            quebracli := VS1->VS1_CLIFAT + VS1->VS1_LOJA
            oSection1:Init()
            oSection1:Cell("A1_COD"):SetValue(Alltrim(VS1->VS1_CLIFAT + "-" + VS1->VS1_LOJA))
            oSection1:Cell("A1_NOME"):SetValue(Left(SA1->A1_NOME,35))
            oSection1:Cell("A3_NOME"):SetValue(Left(SA3->A3_NOME,10))
            oSection1:Cell("VV1_FILIAL"):SetValue(VS1->VS1_FILDES)

            oSection1:PrintLine()
            oSection1:Print()
            oSection1:Finish()
        endif
        // =====================================================
        // ITENS
        // =====================================================
        oSection2:Init()
        For nCntFor := 1 To Len(aTRB)
            oSection2:Cell("NUMORC"):SetValue(cNumOrc)
            oSection2:Cell("SEQUEN"):SetValue(StrZero(nCntFor,2))
            oSection2:Cell("B1_GRUPO"):SetValue(aTRB[nCntFor][1])
            oSection2:Cell("B1_CODITE"):SetValue(aTRB[nCntFor][2])
            oSection2:Cell("B1_DESC"):SetValue(aTRB[nCntFor][3])
            oSection2:Cell("B5_LOCALI2"):SetValue(aTRB[nCntFor][4])
            oSection2:Cell("VS3_QTDITE"):SetValue(aTRB[nCntFor][5])
            oSection2:PrintLine()

            If lLocAux
                SB1->(DbSeek(xFilial("SB1") + aTRB[nCntFor][1] + aTRB[nCntFor][2]))
                If aScan(aRecSB1, SB1->(RECNO())) == 0 .and. ;
                   OA0040031_Existe_Locacoes_Auxiliares(SB1->B1_COD)
                    aAdd(aRecSB1, SB1->(RECNO()))
                EndIf
            EndIf

        Next

        oSection2:Print()
        oSection2:Finish()


        // =====================================================
        // QUEBRA ENTRE ORÇAMENTOS
        // =====================================================
        // Somente se NÃO for o último orçamento
        If nOrc < Len(aOrcRel)
            oReport:PageBreak()
        EndIf

    Next

    // =====================================================
    // RODAPÉ FINAL DO RELATÓRIO
    // =====================================================
    // Executa SOMENTE UMA VEZ no final do relatório

    oSection3:Init()
    oSection3:Cell("COL1"):SetValue(Replicate(" ",10))
    oSection3:Cell("COLRESP"):SetValue(Replicate("_",40))
    oSection3:Cell("COL3"):SetValue(Replicate(" ",10))
    oSection3:Cell("COLPREST"):SetValue(Replicate("_",40))
    oSection3:Cell("COL5"):SetValue(Replicate(" ",10))
    oSection3:PrintLine()
    oReport:SkipLine(2)

    oSection3:Cell('COLRESP'):SetAlign('CENTER')
    oSection3:Cell('COLPREST'):SetAlign('CENTER')

    oSection3:Cell("COL1"):SetValue(Replicate(" ",10))
    oSection3:Cell("COLRESP"):SetValue(STR0003)
    oSection3:Cell("COL3"):SetValue(Replicate(" ",10))
    oSection3:Cell("COLPREST"):SetValue(STR0017)
    oSection3:Cell("COL5"):SetValue(Replicate(" ",10))
    oSection3:PrintLine()
    oSection3:Print()
    oSection3:Finish()

    // =====================================================
    // LOCAÇÕES AUXILIARES
    // =====================================================
    If lLocAux .and. Len(aRecSB1) > 0
        oSection4:Init()
        For nCntSB1 := 1 To Len(aRecSB1)
            SB1->(DbGoTo(aRecSB1[nCntSB1]))
            cEndVBU := ""
            aRetVBU := OA0040011_Locacoes_Auxiliares(SB1->B1_COD)
            For nCntFor := 1 To Len(aRetVBU)
                cEndVBU += aRetVBU[nCntFor,1] + "-" + ;
                                Alltrim(aRetVBU[nCntFor,2]) + ", "
            Next
            cEndVBU := Left(cEndVBU, Len(cEndVBU)-2)
            oSection4:Cell("cEndAux"):SetValue(cEndVBU)
            oSection4:PrintLine()
        Next
        oSection4:Finish()
    EndIf

Return oReport
