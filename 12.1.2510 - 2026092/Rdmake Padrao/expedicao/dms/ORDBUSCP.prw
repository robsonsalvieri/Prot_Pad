#Include "PROTHEUS.CH" 
#Include "TopConn.CH"
#INCLUDE "ORDBUSCP.CH"

// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º   12   º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ORDBUSCP º Autor ³ Andre Luis Almeida º Data ³  07/10/05    º±±
±±ºPrograma  ³ ORDBUSCP º Autor ³ Alecsandre Ferreira º Data ³ 10/09/21    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ ¹±±
±±ºDesc.     ³Imprime Ordem de Busca                                       º±±
±±ºDesc.     ³10/09/21 - Alteração do Report para utilizar a classe TReportº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¹±±
±±ºUso       ³ Balcao                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± ±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ORDBUSCP()	

   	Local oReport	
	Private cDesc := ""
	Private cAlias := "QRYVDD"
	Private cNomeRel := "ORDBUSCP"
	Private aOrdem := {}		
	Private lLocAux := ( cPaisLoc == "ARG" .and. FindFunction("OA0040011_Locacoes_Auxiliares") )
	Private cVddFilOrc := VDD->VDD_FILPED
	Private cVddFilDes := IIF(Empty(VDD->VDD_FILORC), VDD->VDD_FILOSV, VDD->VDD_FILORC)	
	Private cVddNumPed := IIF(Empty(VDD->VDD_FILORC), VDD->VDD_NUMOSV, VDD->VDD_NUMORC)
	Private lPedTraOsv := Empty(VDD->VDD_FILORC)
	Private cVddVenTra := VDD->VDD_VENTRA

	oReport := RptDefOB()
    oReport:nFontBody := 12
    oReport:oPage:nPaperSize := 9
    oReport:PrintDialog()
	
Return .T.

Static Function RptDefOB()

    Local oReport
    Local oSection1
    Local oSection2
	Local oSection3
	Local oSection4
		
	oReport := TReport():New(;
        cNomeRel,;
        " "+STR0001+" "+cVddNumPed,; // "Pedido de Tranf:"
        ,;
        {|oReport| RptRunOB(oReport)},;
        cDesc;
    )

	oReport:SetLineHeight(45)
    oSection1 := TRSection():New(oReport)
    oSection1:SetLinesBefore(1)
    oSection1:SetHeaderPage()

	TRCell():New(oSection1, "FILORIG"   , ""   , STR0016,, 40) //"Filial Origem"
	TrCell():New(oSection1, "A3_NOME"   , "SA3", STR0015,, 20) //"Vendedor"
	TRCell():New(oSection1, "FILDEST"   , ""   , STR0004,, 40) //"Filial Destino"

	oSection2 := TRSection():New(oReport)
	TRCell():New(oSection2, "SEQUEN"    , ""   , STR0005,, 12) //"Seq"
	TRCell():New(oSection2, "B1_GRUPO"  , "SB1", STR0006,, 12) //"Grupo"
	TRCell():New(oSection2, "B1_CODITE" , "SB1", STR0007,, 45) //"Código"
	TRCell():New(oSection2, "B1_DESC"   , "SB1", STR0008,, 30) //"Descrição"
	TRCell():New(oSection2, "B5_LOCALI2", "SB5", STR0009,, 24) //"Locação"
	TRCell():New(oSection2, "VDD_QUANT" , "VDD", STR0010,, 12) //"Qtde."
	oSection2:SetLinesBefore(2)

	oSection3 := TRSection():New(oReport)
    TRCell():New(oSection3,"COL1",    '', '', , 10)
    TrCell():New(oSection3,"COLRESP", '', '', , 40)
    TrCell():New(oSection3,"COL3",    '', '', , 20)
    TrCell():New(oSection3,"COLPREST",'', '', , 40)
    TrCell():New(oSection3,"COL5",    '', '', , 10)
	oSection3:SetLinesBefore(5)
    oSection3:SetHeaderSection(.F.)

	If lLocAux

		oSection4 := TRSection():New(oReport,STR0011,{"SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Locações Auxiliares"
		oSection4:SetAutoSize(.t.)
		TRCell():New(oSection4, "GRUPO"  , "", RetTitle("B1_GRUPO")   , "@!" , 20,, {|| SB1->B1_GRUPO   } ,,, "LEFT" , .t.) // Grupo
		TRCell():New(oSection4, "CODITE" , "", RetTitle("B1_CODITE")  , "@!" , 30,, {|| SB1->B1_CODITE  } ,,, "LEFT" , .t.) // Codigo Item
		TRCell():New(oSection4, "cEndAux" , "", STR0011 ,	"@!" , 140,,  ,,, "LEFT" , .t.,,.t.) // "Locações Auxiliares"
		oSection4:SetLinesBefore(5)

	EndIf

Return oReport

Static Function RptRunOB(oReport)
	
	Local nCntFor := 0
	Local aTRB := {}
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3 := oReport:Section(3)
	Local oSection4
	Local aRecSB1   := {}
	Local cEndVBU   := ""
	Local aRetVBU   := {}
	Local nCntSB1   := 0
	Local aSM0      := {}
	Local cFilDest  := ""
	Local cFilOrig  := ""
	Local cQuery    := ""
	Local cBkpFil
	Local lTemDados := .T.
	If lLocAux
		oSection4 := oReport:Section(4)
	EndIf
		
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+cVddVenTra)

	aSM0 := FWArrFilAtu(cEmpAnt,cVddFilOrc) // Filial Origem
	cFilOrig := cVddFilOrc+" - "+Alltrim(aSM0[7])

	aSM0 := FWArrFilAtu(cEmpAnt,cVddFilDes) // Filial Destino
	cFilDest := cVddFilDes+" - "+Alltrim(aSM0[7])
	
	cBkpFil := cFilAnt

	cQuery := " SELECT "
	cQuery += " 	VDD.VDD_GRUPO, "
	cQuery += " 	VDD.VDD_CODITE, "
	cQuery += " 	VDD.VDD_QUANT "
	cQuery += " FROM "
	cQuery += 		RetSqlName("VDD") + " VDD "
	cQuery += " WHERE "
	cQuery += " 	VDD.VDD_FILIAL = '" + xFilial("VDD") + "' "
	if lPedTraOsv
		cQuery += " AND VDD.VDD_FILOSV = '" + cVddFilDes + "' "
		cQuery += " AND VDD.VDD_NUMOSV = '" + cVddNumPed + "' "
	else
		cQuery += " AND VDD.VDD_FILORC = '" + cVddFilDes + "' "
		cQuery += " AND VDD.VDD_NUMORC = '" + cVddNumPed + "' "
	EndIf
	cQuery += " 	AND VDD.VDD_FILPED = '" + cVddFilOrc + "' " 
	cQuery += " 	AND VDD.VDD_STATUS NOT IN ('R','D') " //R = Rejeitado e D = Cancelado pela Origem
	cQuery += " 	AND VDD.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY "
	cQuery += "		VDD.R_E_C_N_O_ "
	TcQuery cQuery New Alias "QRYVDD"

	If !QRYVDD->(Eof())
		While !QRYVDD->(Eof())
			cFilAnt := cVddFilOrc

			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek(xFilial("SB1") + QRYVDD->VDD_GRUPO + QRYVDD->VDD_CODITE)

			DbSelectArea("SB5")
			DbSetOrder(1)
			DbSeek(xFilial("SB5")+SB1->B1_COD)
				
			AADD(aTRB,;
				{QRYVDD->VDD_GRUPO,;
				QRYVDD->VDD_CODITE,;
				Substr(SB1->B1_DESC,1,20),;
				FM_PRODSBZ(SB1->B1_COD, "SB5->B5_LOCALI2"),;
				QRYVDD->VDD_QUANT };
			)

			QRYVDD->(DbSkip())
		Enddo
	Else
		MsgInfo(STR0017) // "Nenhum item encontrado para pedido de transferência selecionado."	
		lTemDados := .F.	
	EndIf
	QRYVDD->(DbCloseArea())

	cFilAnt := cBkpFil

	IF lTemDados
		oSection1:Init()
		oSection1:Cell("FILORIG"):SetValue(left(cFilOrig, 35))
		oSection1:Cell("A3_NOME"):SetValue(left(SA3->A3_NOME, 10))	
		oSection1:Cell("FILDEST"):SetValue(left(cFilDest, 35))
		oSection1:PrintLine()
		oSection1:Print()
		oSection1:Finish()

		SB1->(DbSetOrder(7))

		oSection2:Init()
		For nCntFor := 1 To Len(aTRB)
			oSection2:Cell("SEQUEN"):SetValue(StrZero(nCntFor, 2))
			oSection2:Cell("B1_GRUPO"):SetValue(aTRB[nCntFor][1])
			oSection2:Cell("B1_CODITE"):SetValue(aTRB[nCntFor][2])
			oSection2:Cell("B1_DESC"):SetValue(aTRB[nCntFor][3])
			oSection2:Cell("B5_LOCALI2"):SetValue(aTRB[nCntFor][4])
			oSection2:Cell("VDD_QUANT"):SetValue(aTRB[nCntFor][5])
			oSection2:PrintLine()

			If lLocAux 
				SB1->(DbSeek(xFilial("SB1")+aTRB[nCntFor][1]+aTRB[nCntFor][2]))
				If aScan(aRecSB1,SB1->(RECNO())) == 0 .and. OA0040031_Existe_Locacoes_Auxiliares(SB1->B1_COD)
					aAdd(aRecSB1,SB1->(RECNO()))
				EndIf
			EndIf

		Next
		oSection2:Print()
		oSection2:Finish()

		oSection3:Init()
		oSection3:Cell("COL1"):SetValue(Replicate(" ", 10))
		oSection3:Cell("COLRESP"):SetValue(Replicate("_", 40))
		oSection3:Cell("COL3"):SetValue(Replicate(" ", 10))
		oSection3:Cell("COLPREST"):SetValue(Replicate("_", 40))
		oSection3:Cell("COL5"):SetValue(Replicate(" ", 10))
		oSection3:PrintLine()

		oReport:SkipLine(2)
		oSection3:Cell('COLRESP'):SetAlign('CENTER')
		oSection3:Cell('COLPREST'):SetAlign('CENTER')

		oSection3:Cell("COL1"):SetValue(Replicate(" ", 10))
		oSection3:Cell("COLRESP"):SetValue(STR0013) //Atendente
		oSection3:Cell("COL3"):SetValue(Replicate(" ", 10))
		oSection3:Cell("COLPREST"):SetValue(STR0014) //Retirado Por
		oSection3:Cell("COL5"):SetValue(Replicate(" ", 10))
		oSection3:PrintLine()
		
		oSection3:Print()
		oSection3:Finish()

		SB1->(DbSetOrder(1))

		If lLocAux .and. len(aRecSB1) > 0
			oSection4:Init()
			For nCntSB1 := 1 to len(aRecSB1)
				SB1->(DbGoTo(aRecSB1[nCntSB1]))
				cEndVBU := ""
				aRetVBU := OA0040011_Locacoes_Auxiliares(SB1->B1_COD)
				For nCntFor := 1 to len(aRetVBU)
					cEndVBU += aRetVBU[nCntFor,1]+"-"+Alltrim(aRetVBU[nCntFor,2])+", "
				Next
				cEndVBU := left(cEndVBU,len(cEndVBU)-2)
				oSection4:Cell("cEndAux"):SetValue(cEndVBU) //Insere o conteudo no espaço destinado
				oSection4:PrintLine()
			Next
			oSection4:Finish()
		EndIf
	EndIf

Return oReport
