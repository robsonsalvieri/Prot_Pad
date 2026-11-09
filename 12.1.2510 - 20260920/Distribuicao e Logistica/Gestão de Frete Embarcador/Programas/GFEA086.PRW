#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GFEA086
Apuração Período - Programa utilizado para fechamento de negociações por franquias e cotas

@author Alan Victor Lamb
@since 18/10/2013
@version 1.0
/*/
Function GFEA086()
	Local aSize := MsAdvSize()

	Private cFilDe
	Private cFilAte
	Private dCriaDe
	Private dCriaAte
	Private dLibDe
	Private dLibAte
	Private dRetDe
	Private dRetAte
	Private oDialog
	Private oBrwRom
	Private oBrwVei
	Private cCdTrp
	Private aRoms 	  := {}
	Private aRomsApur := {}
	Private cAliApur
	
	If Pergunte('GFEA086', .T.)
		cFilDe	 := MV_PAR01
		cFilAte	 := MV_PAR02
		dCriaDe	 := MV_PAR03
		dCriaAte := MV_PAR04
		dLibDe	 := MV_PAR05
		dLibAte	 := MV_PAR06
		dRetDe	 := MV_PAR07
		dRetAte	 := MV_PAR08
	Else
		Return
	EndIf

	oDialog := MSDialog():New(aSize[1], aSize[2], aSize[6], aSize[5], "Cálculo de Frete com Frota Dedicada",,,,, CLR_BLACK, CLR_WHITE,,, .T.)
	oDialog:Activate(,,,.T.,,,{|| Iniciar() })

	If !Empty(cAliApur)
		GFEDelTab(cAliApur)
	EndIf

Return Nil

Static Function Iniciar()
	Local nCount	:= 0
	Local aColsRom	:= {{'GWN_NRROM','GWN_NRROM'}, ;
						{'GWN_DTIMPL','GWN_DTIMPL'}, ;
						{'GWN_DTSAI','GWN_DTSAI'}, ;
						{'GWN_DTRET','GWN_DTRET'}, ;
						{'GWN_CDTPVC','GWN_CDTPVC'},;
						{'GWN_PLACAD','GWN_PLACAD'},;
						{'GWN_FECHAM',"GFEFldInfo('GWN_FECHAM',GWN_FECHAM,2)"}, ;
						{'GWN_SIT',"GFEFldInfo('GWN_SIT',GWN_SIT,2)"},;
						{'GWN_CALC',"GFEFldInfo('GWN_CALC',GWN_CALC,2)"}}

	Local aEmits
	Local oFWLayer
	Local oTree
	Local oTmp
	Local oPanelBot
	Local oQuit
	Local oPnlRom
	Local aFieldsVei
	Local oColumn

	Processa({|| aEmits := CarregaEmit() },'Aguarde', 'Carregando transportadores')

	If GFXCP12123("GWN_DSREAL") .And. GFXRL12123("GWN","GWN_DSREAL")
		Aadd(aColsRom,{'GWN_DSREAL','GWN_DSREAL'})
	EndIf

	If Len(aEmits) == 0
		MsgInfo('Não há transportadores com frota dedicada cadastrados.' + CRLF + 'Não é necessário realizar o fechamento.','Aviso')
		Return
	EndIf

	cCdTrp := aEmits[1][1]

	CriaTab()

	CursorWait()

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDialog,.F.)
	oFWLayer:AddLine('LINE',100,.F.)
	oFWLayer:AddCollumn('COLL',25,.T.,'LINE')
	oFWLayer:AddCollumn('COLR',75,.T.,'LINE')

	oFWLayer:AddWindow('COLL','WNDTRP','Transportadores',100,.F.,.F.,/*bAction*/,'LINE',/*bGotFocus*/)

	oPanelBot := tPanel():New(0,0,"",oFWLayer:GetWinPanel('COLL','WNDTRP','LINE'),,,,,RGB(239,243,247),000,015)
	oPanelBot:Align	:= CONTROL_ALIGN_BOTTOM

	oQuit := THButton():New(0, 0, "Parâmetros Romaneios", oPanelBot, {|| GFEA086001_Parametros() }, , , , )
	oQuit:Align := CONTROL_ALIGN_RIGHT
	oQuit:SetColor(RGB(002,070,112),)

	oTree := dbTree():New(0, 0, 0, 0, oFWLayer:GetWinPanel('COLL','WNDTRP','LINE'), {|oTree| TreeChange(oTree)},, .T.)
	oTree:BeginUpdate()

	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	For nCount := 1 To Len(aEmits)
		oTree:AddItem(PadR(aEmits[nCount][2], 100), PadR(aEmits[nCount][1],TamSX3("GU3_CDEMIT")[1]), 'CARGA','',,,1)
	Next nCount

	oTree:EndUpdate()

	oTmp := oFWLayer:GetColPanel('COLR','LINE')

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oTmp,.F.)

	oFWLayer:AddLine('LINET',50,.F.)
	oFWLayer:AddCollumn('COLT',100,.T.,'LINET')
	oFWLayer:AddLine('LINEB',50,.F.)
	oFWLayer:AddCollumn('COLB',100,.T.,'LINEB')

	oPnlRom := oFWLayer:GetColPanel('COLT','LINET')
	oPnlVei := oFWLayer:GetColPanel('COLB','LINEB')

	//
	// Browse Veículos
	//
	aFieldsVei := { {"Placa"			,"GU8_PLACA"	,"C",TamSX3("GU8_PLACA")[1]		,0,PESQPICT("GU8", "GU8_PLACA")	,1,10},;
					{"Cod Veículo"		,"GU8_CDVEIC"	,"C",TamSX3("GU8_CDVEIC")[1]	,0,""							,1,10},;
					{"Tipo Veículo"		,"GU8_CDTPVC"	,"C",TamSX3("GU8_CDTPVC")[1]	,0,""							,1,10},;
					{"Tabela"			,"GV9_NRTAB"	,"C",TamSX3("GV9_NRTAB")[1]		,0,""							,1,10},;
					{"Negociação"		,"GV9_NRNEG"	,"C",TamSX3("GV9_NRNEG")[1]		,0,""							,1,10},;
					{"Operação"			,"GV9_DSTPOP"	,"C",TamSX3("GV9_DSTPOP")[1]	,0,""							,1,10},;
					{"Qtde Romaneios"	,"QTD_ROM"		,"N",10							,0,""							,1,10},;
					{"Cota Não Ating"	,"COTANATING"	,"N",TamSX3("GV7_QTCOTA")[1]	,0,""							,1,10},;
					{"Valor Cota"		,"VALCOTA"		,"N",10							,2,PESQPICT("GV7", "GV7_VLALUG"),1,10},;
					{"Valor Locação"	,"GV7_VLALUG"	,"N",TamSX3("GV7_VLALUG")[1]	,2,PESQPICT("GV7", "GV7_VLALUG"),1,10},;
					{"Percurso Total"	,"DISTANCIA"	,"N",15							,2,""							,1,10},;
					{"Franquia" 		,"GV7_FRQKM"	,"N",TamSX3("GV7_FRQKM")[1]		,0,""							,1,10},;
					{"Excedente"		,"EXCEDEN"		,"N",TamSX3("GV7_FRQKM")[1]		,0,""							,1,10},;
					{"Frete Calculado"	,"FRETOT"		,"N",10							,2,PESQPICT("GV7", "GV7_VLALUG"),1,10},;
					{"Frete Fechamento"	,"VLRFECH"		,"N",10							,2,PESQPICT("GV7", "GV7_VLALUG"),1,10},;
					{"Emitente"			,"GV9_CDEMIT"	,"N",TamSX3("GV9_CDEMIT")[1]	,2,""							,1,10};
				}

	If GFXCP12123("GV7_QTCDED")
		Aadd(aFieldsVei, {"Quant Cálculos por", "GV7_QTCDED", "C", 10, 0, "", 1, 10})
		Aadd(aFieldsVei, {"Franquia por"	  , "GV7_ESCOKM", "C", 10, 0, "", 1, 10})
	EndIf

	oBrwVei := CriaBrowse(cAliApur, oPnlVei, 'Veículos', '',,'2')
	oBrwVei:AddButton("Gerar Cálculo", {|| GFEA086006() },,3,,.F.)
	oBrwVei:AddButton("Desfazer apuração", {|| GFEA086007() },,5,,.F.)
	oBrwVei:AddButton("Consultar Negociação", {|| GFEA086005() },,4,,.F.)
	oBrwVei:ForceQuitButton(.T.)

	For nCount := 1 To Len(aFieldsVei)
		oColumn := FWBrwColumn():New()
		oColumn:SetTitle(aFieldsVei[nCount][1])
		oColumn:SetData(&("{|| (cAliApur)->" + aFieldsVei[nCount][2] + "}"))
		oColumn:SetType(aFieldsVei[nCount][3])
		oColumn:SetDecimal(aFieldsVei[nCount][5])
		oColumn:SetPicture(aFieldsVei[nCount][6])
		oColumn:SetAlign(aFieldsVei[nCount][7])
		oColumn:SetSize(aFieldsVei[nCount][8])

		oBrwVei:SetColumns({oColumn})
	Next nCount

	oBrwVei:Activate()

	//
	// Browse Romaneios
	//
	oBrwRom := CriaBrowse('GWN', oPnlRom, 'Romaneios', 'GFEA086', .T., '1')
	oBrwRom:SetFilterDefault(FiltroRomaneios())

	If !Empty(aColsRom)

		For nCount := 1 To Len(oBrwRom:oBrowse:aColumns)
			oBrwRom:oBrowse:aColumns[nCount]:SetDelete(.T.)
		Next nCount

		oBrwRom:AddMarkColumns({|| MkColBMark() }, {|| MkColClick() }, {|| })

		For nCount := 1 To Len(aColsRom)
			oColumn := FWBrwColumn():New()
			oColumn:SetData( &("{|| "+aColsRom[nCount][2]+"}") )
			oColumn:SetTitle( X3COLTI(aColsRom[nCount][1]) )
			oColumn:SetOrder(nCount+1)
			oBrwRom:SetColumns({oColumn})
		Next nCount

	EndIf
	oBrwRom:Activate()

	CursorArrow()

Return

Static Function MkColBMark()
	Local lRet := 'LBNO'

	If Type('aRoms') == 'A'
		If aScan(aRoms,{|x| x[1] == GWN->GWN_FILIAL .And. x[2] == GWN->GWN_NRROM }) > 0
			lRet := 'LBOK'
		EndIf
	EndIf

Return lRet

Static Function MkColClick()
	Local lRet := .T.
	Local aAreaGWF, aAreaGWG, aAreaGV7
	Local cNrTab, cNrNeg, cCdFxTpvc, cCdTpOp

	If !(cAliApur)->(Eof())
		MsgStop('Existe uma apuração realizada para os romaneios selecionados. ' + CRLF + ;
				 'Desfaça a apuração ou gere os cálculos para poder marcar outros romaneios.', 'Aviso')
		lRet := .F.
	EndIf

	If lRet .And. GWN->GWN_CALC $ '2;4'
		MsgStop('Para ser considerado na apuração do período, ' + CRLF + ' o romaneio deve ter sido calculado.', 'Aviso')
		lRet := .F.
	EndIf

	If lRet .And. GWN->GWN_SIT $ '1;2'
		MsgStop('Só podem ser considerados na apuração do período romaneios liberados ou encerrados.', 'Aviso')
		lRet := .F.
	EndIf

	If lRet
		//
		// Validação para verificar se o romaneio tem a data de retorno informada,
		// obrigatório quando a negociação for por franquia (km)
		//

		dbSelectArea("GWF")
		aAreaGWF := GWF->(GetArea())
		GWF->(dbSetOrder(4))

		dbSelectArea("GWG")
		aAreaGWG := GWG->(GetArea())
		GWG->( dbSetOrder(1) )

		dbSelectArea("GV7")
		aAreaGV7 := GV7->(GetArea())
		GV7->(dbSetOrder(1))

		If GWF->(dbSeek(GWN->GWN_FILIAL+GWN->GWN_NRROM))

			While !GWF->(Eof()) .And. GWF->GWF_FILIAL == GWN->GWN_FILIAL .And. GWF->GWF_NRROM == GWN->GWN_NRROM

				If GWF->GWF_TPCALC == '1'
					dbSelectArea("GWG")
					GWG->( dbSetOrder(1) )
					If GWG->( dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC) )

						dbSelectArea("GVA")
						dbSetOrder(01)
						If dbSeek(xFilial("GVA")+GWG->GWG_CDEMIT+GWG->GWG_NRTAB)
							If (GVA->GVA_TPTAB == "1") //Tabela de Normal
								cNrTab := GWG->GWG_NRTAB
							Else
								cNrTab := GVA->GVA_TABVIN
							EndIf
						Else
							cNrTab := GWG->GWG_NRTAB
						EndIf
						cNrNeg	  := GWG->GWG_NRNEG
						cCdFxTpvc := GWG->GWG_CDFXTV
						cCdTpOp	  := GWG->GWG_CDTPOP

						dbSelectArea("GV7")
						GV7->(dbSetOrder(1))
						If GV7->(dbSeek(xFilial("GV7")+GWG->GWG_CDEMIT+GWG->GWG_NRTAB+GWG->GWG_NRNEG+GWG->GWG_CDFXTV))

							If (GV7->GV7_FRQKM > 0 .Or. GV7->GV7_VLKMEX > 0) .And. Empty(GWN->GWN_DTRET)
								MsgStop('Este romaneio utiliza negociação por franquia. ' + CRLF + 'Só pode ser selecionado para apuração após ser informada sua data de retorno.', 'Aviso')
								lRet := .F.
							EndIf

							Exit
						EndIf

					EndIf
				EndIf
				dbSelectArea("GWF")
				GWF->( dbSkip() )

			EndDo

		EndIf

		RestArea(aAreaGWF)
		RestArea(aAreaGWG)
		RestArea(aAreaGV7)
	EndIf

	If lRet
		If aScan(aRoms,{|x| x[1] == GWN->GWN_FILIAL .And. x[2] == GWN->GWN_NRROM }) == 0
			aAdd(aRoms, { GWN->GWN_FILIAL, GWN->GWN_NRROM, GWN->GWN_PLACAD, cNrTab, cNrNeg, cCdFxTpvc, cCdTpOp })
		Else
			aDel(aRoms,aScan(aRoms,{|x| x[1] == GWN->GWN_FILIAL .And. x[2] == GWN->GWN_NRROM }))
			aSize(aRoms, Len(aRoms) - 1)
		EndIf
	EndIf

Return lRet

Static Function FiltroRomaneios()
	Local cFiltro := " ( GWN_CALC $ '2;4' .OR. GWN_FECHAM == '2' )"

	//Romaneios com “Apuração Período” (GWN_FECHAM) igual a “2=Pendente” e os Romaneios com pendência de cálculo (GWN_CALC)
	cFiltro += " .AND. GWN_CDTRP = '" + cCdTrp + "' "

	//Parâmetros: Filial (de e até)
	cFiltro += " .AND. GWN_FILIAL >= '" + cFilDe + "' "
	cFiltro += " .AND. GWN_FILIAL <= '" + cFilAte + "' "

	// Data Criação (de e até)
	cFiltro += " .AND. GWN_DTIMPL >= SToD('" + DTOS(dCriaDe) + "') "
	cFiltro += " .AND. GWN_DTIMPL <= SToD('" + DTOS(dCriaAte) + "') "

	// Data Liberação (de e até)
	cFiltro += " .AND. GWN_DTSAI >= SToD('" + DTOS(dLibDe) + "') "
	cFiltro += " .AND. GWN_DTSAI <= SToD('" + DTOS(dLibAte) + "') "

	//Data de Retorno (de e até)
	If !Empty(dRetDe)
		cFiltro += " .AND. GWN_DTRET >= SToD('" + DTOS(dRetDe) + "') "
	EndIf

	If !Empty(dRetAte)
		cFiltro += " .AND. GWN_DTRET <= SToD('" + DTOS(dRetAte) + "') "
	EndIf

Return cFiltro

Function GFEA086001_Parametros()

	If Len(aRoms) == 0 .Or. MsgYesNo('Ao informar novos parâmetros sua seleção atual será perdida. '+CRLF+'Confirma esta ação?', 'Atenção')
		If Pergunte('GFEA086', .T.)
			cFilDe	 := MV_PAR01
			cFilAte	 := MV_PAR02
			dCriaDe	 := MV_PAR03
			dCriaAte := MV_PAR04
			dLibDe	 := MV_PAR05
			dLibAte	 := MV_PAR06
			dRetDe	 := MV_PAR07
			dRetAte	 := MV_PAR08

			Atualiza(,,.T.,.T.)
			oBrwRom:SetFilterDefault(FiltroRomaneios())
			Atualiza()
		EndIf
	EndIf

Return

Function GFEA086002_ConsultarRomaneio()
	FWExecView('Visualizar','GFEC050',MODEL_OPERATION_VIEW,,{||.T.})
Return

Function GFEA086003_RetirarPendencia()
	Local nPos
	Local lRet := .T.

	If !(cAliApur)->(Eof())
		MsgStop('Existe uma apuração realizada para os romaneios selecionados. ' + CRLF + ;
				'Desfaça a apuração ou gere os cálculos para poder retirar pendências dos romaneios.', 'Aviso')
		lRet := .F.
	EndIf

	If lRet .And. MsgYesNo('Deseja retirar a pendência do romaneio selecionado?' + CRLF + 'Esta ação não gera cálculo de fechamento.','Retirar pendência')

		RecLock('GWN',.F.)
			GWN->GWN_FECHAM := '4'
		MsUnlock()

		nPos := aScan(aRoms, {|x| x[1] == GWN->GWN_FILIAL .And. x[2] == GWN->GWN_NRROM })
		If nPos > 0
			aDel(aRoms, nPos)
			aSize(aRoms, Len(aRoms) - 1)

			nPos := aScan(aRomsApur, {|x| x[1] == GWN->GWN_FILIAL .And. x[2] == GWN->GWN_NRROM })
			If nPos > 0
				aDel(aRomsApur, nPos)
				aSize(aRomsApur, Len(aRomsApur) - 1)
			EndIf
		EndIf

		oBrwRom:SetFilterDefault(FiltroRomaneios())
		Atualiza()
	EndIf

	Atualiza()
Return

Function GFEA086004_ApurarDados()

	If Empty(aRoms) .Or. Len(aRoms) == 0
		MsgStop("Deve ser selecionado pelo menos um romaneio para realizar a apuração do período", "Apurar dados")
		Return
	EndIf

	aRomsApur := aRoms

	Processa({|| CarregaDados(),Atualiza(.F.,) }, "Aguarde", "Realizando apuração dos dados")

Return

Static Function CriaTab()
	Local aFields, aIndices, aStruct, nCount

	aFields := {{"RECNO"	,"C",10,0},;
				{"GU8_CDVEIC" ,"C",TamSX3("GU8_CDVEIC")[1],0},;
				{"GU8_CDTPVC" ,"C",TamSX3("GU8_CDTPVC")[1],0},;
				{"GU8_PLACA"  ,"C",TamSX3("GU8_PLACA")[1] ,0},;
				{"GV9_NRTAB"  ,"C",TamSX3("GV9_NRTAB")[1] ,0},;
				{"GV9_NRNEG"  ,"C",TamSX3("GV9_NRNEG")[1] ,0},;
				{"GV9_CDTPOP" ,"C",TamSX3("GV9_CDTPOP")[1],0},;
				{"GV9_CDCLFR" ,"C",TamSX3("GV9_CDCLFR")[1],0},;
				{"GV7_QTCOTA" ,"N",TamSX3("GV7_QTCOTA")[1],0},;
				{"GV7_CDFXTV" ,"C",TamSX3("GV7_CDFXTV")[1],0},;
				{"GV7_CDTPVC" ,"C",TamSX3("GV7_CDTPVC")[1],0},;
				{"COTANATING" ,"N",TamSX3("GV7_QTCOTA")[1],0},;
				{"GV7_VLALUG" ,"N",TamSX3("GV7_VLALUG")[1],TamSX3("GV7_VLALUG")[2]},;
				{"GV7_FRQKM"  ,"N",TamSX3("GV7_FRQKM")[1] ,0},;
				{"GV7_VLKMEX" ,"N",TamSX3("GV7_VLKMEX")[1],TamSX3("GV7_VLKMEX")[2]},;
				{"FRETOT" 	  ,"N",10					  ,2},;
				{"FREAVG" 	  ,"N",10					  ,2},;
				{"VALCOTA"	  ,"N",10					  ,2},;
				{"DISTANCIA"  ,"N",15                     ,2},;
				{"EXCEDEN"	  ,"N",TamSX3("GWN_HODSAI")[1],0},;
				{"QTD_ROM"	  ,"N",10                     ,0},;
				{"VLRFECH"	  ,"N",10                     ,2},;
				{"GV9_DSTPOP" ,"C",TamSX3("GV9_DSTPOP")[1],0},;
				{"GV9_CDEMIT" ,"C",TamSX3("GV9_CDEMIT")[1],0} ;
				}

	If GFXCP12123("GV7_QTCDED")
		Aadd(aFields,{"GV7_QTCDED", "C", 10,0})
		Aadd(aFields,{"GV7_ESCOKM", "C", 10,0})
	EndIf

	aIndices := {"RECNO+GU8_PLACA"}
	aStruct  := {}

	For nCount := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCount][1],; // Nome do campo
					  aFields[nCount][2],; // Tipo
					  aFields[nCount][3],; // Tamanho
					  aFields[nCount][4]}) // Decimal
	Next nCount

	cAliApur := GFECriaTab({aStruct,aIndices})
Return cAliApur

Static Function CarregaDados()
	Local cQuery
	Local nCount
	Local cTmp
	Local cRoms := ""
	Local nDistancia := 0

	For nCount := 1 To Len(aRomsApur)
		If nCount > 1
			cRoms += ","
		EndIf

		cRoms += "'" + aRomsApur[nCount][1] + aRomsApur[nCount][2] + "'"
	Next nCount

	dbSelectArea(cAliApur)
	ZAP

	If !Empty(cRoms)
		cQuery := "		SELECT GU8_CDVEIC, "
		cQuery += "		       GWN_CDTPVC GU8_CDTPVC, "
		cQuery += "		       GU8_PLACA, "
		cQuery += "		       GV9_NRTAB, "
		cQuery += "		       GV9_CDEMIT, "
		cQuery += "		       GV9_NRNEG,"
		cQuery += "		       GV9_CDTPOP,"
		cQuery += "		       GV9_CDCLFR,"
		cQuery += "			   GV7_QTCOTA,"
		cQuery += "			   GV7_VLALUG,"
		cQuery += "			   GV7_FRQKM,"
		cQuery += "			   GV7_VLKMEX,"
		cQuery += "			   GV7_CDFXTV,"
		cQuery += "			   GV7_CDTPVC,"
		cQuery += "			   SUM(GWI_VLFRET)+SUM(GWF_VLAJUS) FRETOT,"
		cQuery += "			   AVG(GWI_VLFRET)+AVG(GWF_VLAJUS) FREAVG,"
		cQuery += "			   SUM(CASE "
		cQuery += "			       WHEN GWN_DTRET != '' AND GWN_HODRET > GWN_HODSAI"
		cQuery += "			       THEN GWN_HODRET - GWN_HODSAI "
		cQuery += "			       WHEN GWN_DTRET != '' AND GWN_HODRET < GWN_HODSAI"
		cQuery += "			       THEN (GWN_HODRET+1000000)-GWN_HODSAI "
		cQuery += "			       ELSE 0"
		cQuery += "			       END) DISTANCIA,"
		cQuery += "			   COUNT(DISTINCT GWN_NRROM) QTD_ROM"
		If GFXCP12123("GV7_ESCOKM")
			cQuery += "			   ,GV7_QTCDED"
			cQuery += "			   ,GV7_ESCOKM"
		EndIf
		cQuery += "		 FROM "+RetSQLName("GWN")+" GWN "
		cQuery += "	     LEFT JOIN "+RetSQLName("GU8")+" GU8"
		cQuery += "	       ON GU8.GU8_PLACA = GWN.GWN_PLACAD"
		cQuery += "	      AND GU8.D_E_L_E_T_ = ''"
		cQuery += "	    INNER JOIN "+RetSQLName("GWF")+" GWF"
		cQuery += "	       ON GWF.GWF_FILIAL = GWN.GWN_FILIAL"
		cQuery += "		  AND GWF.GWF_NRROM = GWN.GWN_NRROM"
		cQuery += "		  AND GWF.GWF_TPCALC = '1'"
		cQuery += "		  AND GWF.D_E_L_E_T_ = ''"
		cQuery += "     INNER JOIN "+RetSQLName("GWG")+" GWG"
		cQuery += "        ON GWG.GWG_FILIAL = GWF.GWF_FILIAL"
		cQuery += "		  AND GWG.GWG_NRCALC = GWF.GWF_NRCALC"
		cQuery += "		  AND GWG.D_E_L_E_T_ = ''"
		cQuery += "		  AND GWG.R_E_C_N_O_ = (SELECT MIN(R_E_C_N_O_)" 
 		cQuery += "	  			                  FROM " + RetSQLName("GWG")
 		cQuery += "	     					  	 WHERE GWG_FILIAL = GWF.GWF_FILIAL "
 		cQuery += "	     					  	   AND GWG_NRCALC = GWF.GWF_NRCALC" 
 		cQuery += "	     					  	   AND D_E_L_E_T_ = '')"
		cQuery += "	    INNER JOIN ( SELECT GWI_FILIAL, GWI_NRCALC, SUM(GWI_VLFRET) GWI_VLFRET"
		cQuery += "	     	  		   FROM "+RetSQLName("GWI")
		cQuery += "	     	          WHERE GWI_TOTFRE = '1' AND D_E_L_E_T_ = ''"
		cQuery += "	     	       GROUP BY GWI_FILIAL, GWI_NRCALC ) GWI"
		cQuery += "	     	    ON GWI.GWI_FILIAL = GWF.GWF_FILIAL"
		cQuery += "	     	   AND GWI.GWI_NRCALC = GWF.GWF_NRCALC"
		cQuery += "     INNER JOIN "+RetSQLName("GVA")+" GVA"
		cQuery += "        ON GVA.GVA_CDEMIT = GWG.GWG_CDEMIT"
		cQuery += "       AND GVA.GVA_NRTAB = GWG.GWG_NRTAB"
		cQuery += "       AND GVA.D_E_L_E_T_ = ' ' "
		cQuery += "	    INNER JOIN "+RetSQLName("GV9")+" GV9"
		cQuery += "	       ON GV9.GV9_CDEMIT = (CASE GVA_TPTAB WHEN '1' THEN GWG.GWG_CDEMIT ELSE GVA.GVA_EMIVIN END) "
		cQuery += "		  AND GV9.GV9_NRTAB  = (CASE GVA_TPTAB WHEN '1' THEN GWG.GWG_NRTAB  ELSE GVA.GVA_TABVIN END) "
		cQuery += "		  AND GV9.GV9_NRNEG  = GWG.GWG_NRNEG"
		cQuery += "		  AND GV9.D_E_L_E_T_ = ''"
		cQuery += "		  AND GV9.GV9_TPLOTA = '3'"
		cQuery += "		INNER JOIN "+RetSQLName("GV7")+" GV7"
		cQuery += "		   ON GV7.GV7_FILIAL = GV9.GV9_FILIAL"
		cQuery += "		  AND GV7.GV7_CDEMIT = GV9.GV9_CDEMIT"
		cQuery += "		  AND GV7.GV7_NRTAB  = GV9.GV9_NRTAB"
		cQuery += "		  AND GV7.GV7_NRNEG  = GV9.GV9_NRNEG"
		cQuery += "		  AND GV7.GV7_CDTPVC = GWG.GWG_CDTPVC"
		cQuery += "		  AND GV7.D_E_L_E_T_ = ''"
		cQuery += "		WHERE GWN.D_E_L_E_T_ = ''"
		cQuery += "		  AND GWN.GWN_FILIAL || GWN.GWN_NRROM IN ("+cRoms+") "
		cQuery += "	 GROUP BY GU8_CDVEIC, GWN_CDTPVC, GU8_PLACA, GV9_CDEMIT, GV9_NRTAB, GV9_NRNEG, GV7_CDFXTV"
		cQuery += "		    , GV9_CDTPOP, GV7_QTCOTA, GV7_VLALUG, GV7_FRQKM, GV7_VLKMEX, GV9_CDCLFR, GV7_CDTPVC "
		If GFXCP12123("GV7_ESCOKM")
			cQuery += ", GV7_QTCDED, GV7_ESCOKM"
		EndIf

		cTmp := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
		dbSelectArea(cTmp)
		(cTmp)->(dbGoTop())

		If GFXCP12123("GV7_ESCOKM")
			cQuery := "	SELECT SUM(GWN_DSREAL) DISTANCIA "
		Else
			cQuery := " SELECT SUM(CASE WHEN GWN_DTRET != '' AND GWN_HODRET > GWN_HODSAI"
			cQuery += "			        THEN GWN_HODRET - GWN_HODSAI "
			cQuery += "			        WHEN GWN_DTRET != '' AND GWN_HODRET < GWN_HODSAI"
			cQuery += "			        THEN (GWN_HODRET+1000000)-GWN_HODSAI "
			cQuery += "			        ELSE 0"
			cQuery += "			        END) DISTANCIA "
		EndIf

		cQuery += "  FROM "+RetSQLName("GWN")+" GWN "
		cQuery += " WHERE GWN.D_E_L_E_T_ = ''"
		cQuery += "	  AND GWN.GWN_FILIAL || GWN.GWN_NRROM IN ("+cRoms+") "

		cTmp2 := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp2,.F.,.T.)
		dbSelectArea(cTmp2)
		(cTmp2)->(dbGoTop())
		nDistancia := (cTmp2)->DISTANCIA

		nCount := 1

		While (cTmp)->(!Eof())
			RecLock(cAliApur,.T.)
				(cAliApur)->RECNO := StrZero(nCount,10)
				nCount++
				(cAliApur)->GU8_CDVEIC := (cTmp)->GU8_CDVEIC
				(cAliApur)->GU8_CDTPVC := (cTmp)->GU8_CDTPVC
				(cAliApur)->GU8_PLACA  := (cTmp)->GU8_PLACA
				(cAliApur)->GV9_NRTAB  := (cTmp)->GV9_NRTAB
				(cAliApur)->GV9_CDEMIT := (cTmp)->GV9_CDEMIT
				(cAliApur)->GV9_NRNEG  := (cTmp)->GV9_NRNEG
				(cAliApur)->GV9_CDTPOP := (cTmp)->GV9_CDTPOP
				(cAliApur)->GV9_CDCLFR := (cTmp)->GV9_CDCLFR
				(cAliApur)->GV7_QTCOTA := (cTmp)->GV7_QTCOTA
				(cAliApur)->GV7_VLALUG := (cTmp)->GV7_VLALUG
				(cAliApur)->GV7_FRQKM  := (cTmp)->GV7_FRQKM
				(cAliApur)->GV7_CDFXTV := (cTmp)->GV7_CDFXTV
				(cAliApur)->GV7_VLKMEX := (cTmp)->GV7_VLKMEX
				(cAliApur)->GV7_CDTPVC := (cTmp)->GV7_CDTPVC
				(cAliApur)->FRETOT 	   := (cTmp)->FRETOT
				(cAliApur)->FREAVG 	   := (cTmp)->FREAVG
				(cAliApur)->DISTANCIA  := nDistancia
				(cAliApur)->QTD_ROM	   := (cTmp)->QTD_ROM
				(cAliApur)->VLRFECH    := 0
				(cAliApur)->GV9_DSTPOP := Posicione("GV4",1,xFilial("GV4")+(cTmp)->GV9_CDTPOP,"GV4_DSTPOP")
				(cAliApur)->EXCEDEN	   := 0
				(cAliApur)->COTANATING := 0
				(cAliApur)->VALCOTA	   := 0

				If GFXCP12123("GV7_QTCDED")
					If (cTmp)->GV7_QTCDED == "2"
						(cAliApur)->GV7_QTCDED := "Entrega"
					Else
						(cAliApur)->GV7_QTCDED := "Período"
					EndIf

					If (cTmp)->GV7_ESCOKM == "2"
						(cAliApur)->GV7_ESCOKM := "Romaneio"
					Else
						(cAliApur)->GV7_ESCOKM := "Período"
					EndIf
				EndIf

				// Cálculo do valor de fechamento por cotas
				If (cTmp)->GV7_QTCOTA > 0
					// Somente calcula se a cota de viagens não foi atingida
					If (cTmp)->GV7_QTCOTA > (cTmp)->QTD_ROM
						(cAliApur)->COTANATING := (cTmp)->GV7_QTCOTA - (cTmp)->QTD_ROM
						(cAliApur)->VLRFECH    := (cTmp)->FREAVG * ((cTmp)->GV7_QTCOTA - (cTmp)->QTD_ROM)
						(cAliApur)->VALCOTA	   := (cTmp)->FREAVG
					EndIf
				Else // Cálculo do valor de fechamento por franquia/locação/km excedente
					// Frete Calculado,Frete Fechamento,Val Calculo 
					lLocacao := (cTmp)->GV7_VLALUG > 0
					lFranquia := (cTmp)->GV7_FRQKM > 0
					lExcedente := (cTmp)->GV7_VLKMEX > 0

					nFech := 0
					nFech := (cTmp)->GV7_VLALUG - (cTmp)->FRETOT

					If lFranquia .Or. lExcedente
						If lExcedente
							If GFXCP12123("GV7_ESCOKM") .And. (cTmp)->GV7_ESCOKM == "2"
								(cAliApur)->EXCEDEN := nDistancia - ((cTmp)->QTD_ROM * (cTmp)->GV7_FRQKM)
							Else
								(cAliApur)->EXCEDEN := nDistancia - (cTmp)->GV7_FRQKM
							EndIf
						EndIf

						If !lLocacao .And. lFranquia .And. lExcedente .And. (cAliApur)->EXCEDEN > 0
							nFech := (cAliApur)->EXCEDEN * (cTmp)->GV7_VLKMEX
						Else
							If (cAliApur)->EXCEDEN > 0
								nFech := nFech + ( (cAliApur)->EXCEDEN * (cTmp)->GV7_VLKMEX )
							EndIf
						EndIf
					EndIf

					(cAliApur)->VLRFECH := Iif(nFech < 0, 0, nFech)
				EndIf

			MsUnlock(cAliApur)
			(cTmp)->(dbSkip())
		EndDo

		(cTmp)->(dbCloseArea())
		If GFXCP12123("GV7_ESCOKM")
			(cTmp2)->(dbCloseArea())
		EndIf
	EndIf
Return

Function GFEA086005_ConsultarNegociacao()
	Private cTB_CDEMIT := (cAliApur)->GV9_CDEMIT //PadR(cCdTrp, TamSX3("GU3_CDEMIT")[1])
	Private cTB_NRTAB  := (cAliApur)->GV9_NRTAB

	dbSelectArea("GV9")
	GV9->( dbSetOrder(1) )
	GV9->( dbSeek(xFilial("GV9") + cTB_CDEMIT + (cAliApur)->GV9_NRTAB + (cAliApur)->GV9_NRNEG) )

	FWExecView('Visualizar','GFEA061A',MODEL_OPERATION_VIEW,,{||.T.})
Return

Function GFEA086006_GerarCalculo()
	Local nCount 	:= 0
	Local aRet		:= {}
	Local aRomsCalc	:= {}
	Local lFech		:= .F.

	For nCount := 1 To Len(aRomsApur)
		If AllTrim(aRomsApur[nCount][3]) == AllTrim((cAliApur)->GU8_PLACA) .And. ;
		   AllTrim(aRomsApur[nCount][4]) == AllTrim((cAliApur)->GV9_NRTAB) .And. ;
		   AllTrim(aRomsApur[nCount][5]) == AllTrim((cAliApur)->GV9_NRNEG) .And. ;
		   AllTrim(aRomsApur[nCount][6]) == AllTrim((cAliApur)->GV7_CDFXTV)
 
			aAdd(aRomsCalc, aRomsApur[nCount] )
		EndIf
	Next nCount

	If !Empty(aRomsCalc) .And. Len(aRomsCalc) > 0
		If (cAliApur)->VLRFECH > 0
			aRet := Confirma(aRomsCalc)
			If aRet[1]
				Processa({|| aRet := NewCalcular(aRomsCalc, aRet[2] /*aCalc*/) }, 'Realizando cálculo de fechamento','Aguarde')

				lFech := .T.

				If Len(aRet) > 0
					MsgInfo("Foram gerado os cálculos.")
				EndIf
			EndIf
		Else
			If MsgYesNo("Como não há valor de fechamento os romaneios terão sua situação fechamento alteradas para 'Efetuada' sem a geração de um cálculo." + CRLF + "Confirma esta ação?", 'Aviso')
				lFech := .T.
			EndIf
		EndIf
	Else
		MsgInfo("Nenhum romaneio marcado para cálculo","Atenção")
	EndIf

	If lFech
		dbSelectArea("GWN")
		GWN->( dbSetOrder(1) )
		aAreaGWN := GWN->(GetArea())

		// Alterar situação de fechamento dos romaneio
		For nCount := 1 To Len(aRomsCalc)
			If GWN->(dbSeek(aRomsCalc[nCount][1]+aRomsCalc[nCount][2]))
				RecLock("GWN",.F.)
					GWN->GWN_FECHAM := '3'
					GWN->GWN_DTFECH := DDATABASE
				MsUnlock()
			EndIf
		Next nCount

		RestArea(aAreaGWN)

		For nCount := 1 To Len(aRomsCalc)
			aDel(aRomsApur, aScan(aRomsApur, {|x| x[1] == aRomsCalc[nCount][1] .And. x[2] == aRomsCalc[nCount][2] }))
			aSize(aRomsApur, Len(aRomsApur) - 1)
		Next nCount

		RecLock(cAliApur, .F.)
			(cAliApur)->( dbDelete() )
		MsUnlock(cAliApur)

		(cAliApur)->( dbSkip() )

		oBrwRom:SetFilterDefault(FiltroRomaneios())
		Atualiza()
	EndIf
Return

Function GFEA086007_DesfazerApuracao()
	If MsgYesNo('Deseja desfazer a apuração?' + CRLF + 'Para realizar uma nova apuração do período, selecione os romaneios e clique em "Apurar Dados"')
		dbSelectArea(cAliApur)
		ZAP

		aRomsApur := {}
		Atualiza()
	EndIf
Return

Static Function MenuDef()
	Local aRotina := {}

	// Operation 3 (Inclusão) - Quando o browse está sem registros, 
	// é o único tipo de "Operation" que ele aceita como ação relacionada
	//ADD OPTION aRotina TITLE 'Parâmetros'  		ACTION 'GFEA086001'	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Consultar Romaneio'	ACTION 'GFEA086002'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Retirar Pendência'	ACTION 'GFEA086003'	OPERATION 2 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Apurar Dados'		ACTION 'GFEA086004'	OPERATION 2 ACCESS 0

Return aRotina

Static Function TreeChange(oTree)

	CursorWait()

	cCdTrp := oTree:GetCargo()

	oBrwRom:SetFilterDefault(FiltroRomaneios())
	Atualiza(,,.T.,.T.)

	CursorArrow()

Return Nil

Static Function CriaBrowse(cAli, oOwner, cDescription, cMenuDef, lMark, profId)
	Local oBrowse
	Default lMark := .F.

	If lMark
		oBrowse := FWMarkBrowse():New()
	Else
		oBrowse := FWMBrowse():New()
	EndIf

	oBrowse:SetOwner(oOwner)
	oBrowse:SetAlias(cAli)
	oBrowse:SetDescription(cDescription)
	oBrowse:DisableDetails()
	oBrowse:SetLocate()
	oBrowse:SetProfileID(profId)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetMenuDef(cMenuDef)
	oBrowse:SetFixedBrowse(.T.)

Return oBrowse

Static Function CarregaEmit()
	Local aEmits := {}

	dbSelectArea('GU3')
	GU3->( dbSetOrder(5) )

	// Transportador
	If GU3->( dbSeek(xFilial('GU3')+'1') )
		While GU3->(!Eof()) .And. GU3->GU3_TRANSP == '1'
			If GU3->GU3_DEDIC == '1'
				aAdd(aEmits, { AllTrim(GU3->GU3_CDEMIT), AllTrim(GU3->GU3_CDEMIT) + '-' + AllTrim(GU3->GU3_NMEMIT) })
			EndIf

			GU3->( dbSkip() )
		EndDo
	EndIf

	// Autonomo
	GU3->( dbSetOrder(6) )
	If GU3->( dbSeek(xFilial('GU3')+'1') )
		While GU3->(!Eof()) .And. GU3->GU3_AUTON == '1'
			If GU3->GU3_DEDIC == '1'
				If aScan(aEmits, {|x| x[1] == AllTrim(GU3->GU3_CDEMIT)}) == 0
					aAdd(aEmits, { AllTrim(GU3->GU3_CDEMIT), AllTrim(GU3->GU3_CDEMIT) + '-' + AllTrim(GU3->GU3_NMEMIT) })
				EndIf
			EndIf

			GU3->( dbSkip() )
		EndDo
	EndIf

	aSort(aEmits,,,{|x,y| x[1] < y[1]})

Return aEmits

Static Function X3COLTI(cCampo)
	dbSelectArea("SX3")
	SX3->( dbSetOrder(2) )
	If SX3->( dbSeek(cCampo) )
		Return X3TITULO()
	EndIf
Return ''

Static Function CalcRom(aRomans, nVlFrete)
	Local nVlPis
	Local nPcIss
	Local nPcIcms
	Local nVlCofins
	Local nVlImposto
	Local nX        := 1
	Local nZ        := 1
	Local nDsReal   := 0
	Local nIcmBase  := nVlFrete
	Local nPiCoBas  := nVlFrete
	Local lRateia   := .F.
	Local lGeraCalc := .T.
	Local aCalc 	:= {}
	Local aDocCalc	:= {}
	Local nTotalRat := nVlFrete
	Local aAreaGWF 	:= GWF->(GetArea())
	Local nPcPis	:= GetMv("MV_PCPIS")
	Local nPcCoFi	:= GetMv("MV_PCCOFI")

	GWF->( dbSetOrder(4) )
	GWN->( dbSetOrder(1) )
	GW1->( dbSetOrder(9) )

	For nX := 1 To Len(aRomans)
		If GWF->( dbSeek( aRomans[nX][1] + aRomans[nX][2] ) )
			While !GWF->(Eof()) .And. GWF->GWF_FILIAL == aRomans[nX][1] .And. GWF->GWF_NRROM == aRomans[nX][2]
				If GWF->GWF_TPCALC == '1'
					nPiCoBas  := 0
					//nIcmBase  := 0

					If GWF->GWF_PCISS > 0 // Calcula ISS
						nPcIss := GWF->GWF_PCISS
						nVlImposto	:= nIcmBase * nPcIss / 100
					ElseIf GWF->GWF_PCICMS > 0 // Calcula ICMS
						nPcIcms := GWF->GWF_PCICMS
						nVlImposto := nIcmBase * nPcIcms / 100

						//Redução na base ICMS
						If GWF->GWF_PCREIC > 0
							nFatRed := 1 - GWF->GWF_PCREIC/100
							nVlImposto := (nIcmBase * nFatRed) * nPcIcms / 100
						EndIf
					EndIf

					nVlPis    := Round(nPiCoBas * (nPcPis /100), 2)
					nVlCofins := Round(nPiCoBas * (nPcCoFi /100 ), 2)

					nVlImposto := If(Empty(nVlImposto), 0, nVlImposto)

					aDocCalc := {}
					If !GFXCP12123("GV7_ESCOKM") .Or. (GFXCP12123("GV7_ESCOKM") .And. (AllTrim((cAliApur)->GV7_QTCDED) == "Período" .And. AllTrim((cAliApur)->GV7_ESCOKM) == "Período"))
						For nZ := 1 To Len(aRomans)
							If GFXCP1212210('GW1_FILROM')
								GW1->(dbSetOrder(21))
							EndIf
							If GW1->(dbSeek(aRomans[nZ][1] + aRomans[nZ][2]))
								While !GW1->(Eof()) .And. GW1->GW1_FILIAL == aRomans[nZ][1] .And. GW1->GW1_NRROM == aRomans[nZ][2]
									aAdd(aDocCalc, {GW1->GW1_FILIAL, GW1->GW1_SERDC, GW1->GW1_NRDC})

									GW1->( dbSkip() )
								EndDo
							EndIf
						Next nZ
					Else
						GWH->(dbSetOrder(1))
						If GWH->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
							While !GWH->(Eof()) .And. GWH->GWH_FILIAL == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
								aAdd(aDocCalc, {GWH->GWH_FILIAL, GWH->GWH_SERDC, GWH->GWH_NRDC})

								GWH->( dbSkip() )
							EndDo
						EndIf
					EndIf

					If (!GFXCP12123("GV7_ESCOKM") .And. lGeraCalc);
						.Or. (lGeraCalc .And. GFXCP12123("GV7_ESCOKM") .And. AllTrim((cAliApur)->GV7_QTCDED) == "Período" .And. AllTrim((cAliApur)->GV7_ESCOKM) == "Período")

						aAdd(aCalc, { GWF->GWF_FILIAL, ;
									  GWF->GWF_NRCALC, ;
									  GWF->GWF_FINCAL, ;
									  GWF->GWF_TPTRIB, ; // TIPO TRIBUTAÇÃO
									  GWF->GWF_PCISS, ;  // % ISS
									  GWF->GWF_PCICMS, ; // % ICMS APLICADO
									  GWF->GWF_PCREIC, ; // % REDUÇÃO ICMS
									  GWF->GWF_CRDICM, ;
									  GWF->GWF_CRDPC, ;
									  GWF->GWF_ADICIS, ;
									  GWF->GWF_TPFRET, ;
									  nVlPis, ; //12
									  nVlCofins, ;
									  nVlImposto, ;
									  GWF->GWF_EMIPAG, ;
									  GWF->GWF_IMPOST, ;
									  nTotalRat, ; //total do frete rateado //17
									  aDocCalc})
						lGeraCalc := .F.
						Exit

					ElseIf GFXCP12123("GV7_ESCOKM")
						GWN->( dbSeek( aRomans[nX][1] + aRomans[nX][2] ) )
						nDsReal := GWN->GWN_DSREAL
						If AllTrim((cAliApur)->GV7_QTCDED) == "Entrega" .And. AllTrim((cAliApur)->GV7_ESCOKM) == "Romaneio"
							If nDsReal > (cAliApur)->GV7_FRQKM
								nVlFrete := (nDsReal - (cAliApur)->GV7_FRQKM) * (cAliApur)->GV7_VLKMEX
								lRateia := .T.
							EndIf
						EndIf

						If lRateia .And. nDsReal > (cAliApur)->GV7_FRQKM .Or. (AllTrim((cAliApur)->GV7_QTCDED) == "Entrega" .And. AllTrim((cAliApur)->GV7_ESCOKM) == "Período")
							nTotalRat := GFEA086EXC(GWF->GWF_FILIAL, GWF->GWF_NRCALC,GWF->GWF_NRROM,nVlFrete)

							If nVlImposto == 0 .And. nTotalRat > 0
								If GWF->GWF_PCISS > 0 // Calcula ISS
									nVlImposto := nTotalRat * GWF->GWF_PCISS / 100
								ElseIf GWF->GWF_PCICMS > 0 // Calcula ICMS
									nVlImposto := nTotalRat * GWF->GWF_PCICMS / 100

									//Redução na base ICMS
									If GWF->GWF_PCREIC > 0
										nFatRed := 1 - GWF->GWF_PCREIC/100
										nVlImposto := (nTotalRat * nFatRed) * GWF->GWF_PCICMS / 100
									EndIf
								EndIf

								nVlPis     := Round(nTotalRat * (nPcPis /100 ), 2)
								nVlCofins  := Round(nTotalRat * (nPcCoFi /100 ), 2)
								nVlImposto := If(Empty(nVlImposto), 0, nVlImposto)
							EndIf
						Else
							lRateia   := .F.
							nTotalRat := 0
							GWF->( dbSkip() )
							Loop
						EndIf

						aAdd(aCalc, { GWF->GWF_FILIAL, ;
									  GWF->GWF_NRCALC, ;
									  GWF->GWF_FINCAL, ;
								  	  GWF->GWF_TPTRIB, ; // TIPO TRIBUTAÇÃO
									  GWF->GWF_PCISS, ;  // % ISS
									  GWF->GWF_PCICMS, ; // % ICMS APLICADO
									  GWF->GWF_PCREIC, ; // % REDUÇÃO ICMS
									  GWF->GWF_CRDICM, ;
									  GWF->GWF_CRDPC, ;
									  GWF->GWF_ADICIS, ;
									  GWF->GWF_TPFRET, ;
									  nVlPis, ; //12
									  nVlCofins, ;
									  nVlImposto, ;
									  GWF->GWF_EMIPAG, ;
									  GWF->GWF_IMPOST, ;
									  nTotalRat, ; //total do frete rateado //17
									  aDocCalc})												
					EndIf
				EndIf

				lRateia   := .F.
				nTotalRat := 0
				GWF->( dbSkip() )
			EndDo
		EndIf
	Next nX

	RestArea( aAreaGWF )
Return aCalc

Static Function CalcBase(aCalc)
	Local nX := 0
	Local aAreaGWN := GWN->(GetArea())
	Local aAreaGWF := GWF->(GetArea())

	GWF->(dbSetOrder(1))
	For nX := 1 To Len(aCalc)
		GWF->(dbSeek(aCalc[nX][1]+aCalc[nX][2]))
	Next nX

	FWExecView('Visualizar','GFEC080',MODEL_OPERATION_VIEW,,{||.T.})

	RestArea(aAreaGWN)
	RestArea(aAreaGWF)
Return

Static Function Confirma(aRomaneios)
	Local nI		  := 0
	Local cTpImp	  := ""
	Local lRet 		  := .F.
	Local nVlFrete 	  := (cAliApur)->VLRFECH
	Local aButtons 	  := {}
	Local aFechamento := {}
	Local aRet		  := {.F.,}
	Local aCalc 	  := CalcRom(aRomaneios,(cAliApur)->VLRFECH)

	Private nBaseICMS := nVlFrete
	Private nBaseISS  := nVlFrete
	Private nBasePIS  := nVlFrete
	Private nRedIcms  := 0
	Private nPcIcms   := 0
	Private nPcIss    := 0
	Private nVlPis    := 0
	Private nVlIcms   := 0
	Private nVlIss    := 0
	Private nVlCofins := 0
	Private lView	  := .T.

	aAdd(aButtons, {'',{|| CalcBase(aCalc) },'Cons Calc Base'})

	lRet := GFEA086LD(aCalc, nVlFrete)
	If lRet
		For nI := 1 To Len(aCalc)
			nVlPis 	  := aCalc[nI][12]
			nVlCofins := aCalc[nI][13]

			If aCalc[nI][5] > 0
				nVlIss  := aCalc[nI][14]
			Else
				nVlIcms := aCalc[nI][14]
			EndIf

			nRedIcms	:= aCalc[nI][7]
			nPcIcms		:= aCalc[nI][6]
			nPcIss		:= aCalc[nI][5]
			cTpImp 		:= aCalc[nI][16]

			aAdd(aFechamento, aCalc[nI] )
		Next nI

		aRet[1] := .T.
		aRet[2] := aFechamento
	EndIf

Return aRet

Static Function CalcICMS(nBase, nPct, nPctRed, cTpImp, cTpTrib)
	Local nRet := 0
	Local nFatRed

	If cTpImp == '1'
		nRet := nBase * nPct / 100

		//Redução na base ICMS
		If nPctRed > 0
			nFatRed := 1 - nPctRed / 100
			nRet := (nBase * nFatRed) * nPct / 100
		EndIf
	EndIf
Return nRet

Static Function CalcISS(nBase, nPct, cTpImp, cTpTrib)
	Local nRet := 0

	If cTpImp == '2'
		nRet	:= nBase * nPct / 100
	EndIf
Return nRet

Static Function CalcPIS(nBase)
	Local nRet := 0
	nRet := Round(nBase * (GetMv("MV_PCPIS") /100 ),2)
Return nRet

Static Function CalcCOFINS(nBase)
	Local nRet := 0
	nRet := Round(nBase * (GetMv("MV_PCCOFI") /100 ),2)
Return nRet

Static Function NewCalcular(aRomaneios, aCalc)
	Local cLog
	Local cCFEXCD
	Local cCFALUG
	Local cCFCOTA
	Local nQtItem
	Local nQtPeso
	Local nValMer
	Local nPes3
	Local nQtM3
	Local nNovoNrCalc
	Local lAdd       := .F.
	Local nX         := 0
	Local nZ         := 0
	Local nCount     := 0
	Local nExcedente := 0
	Local aRet       := {}
	Local cCdEmit    := PadR(cCdTrp, TamSX3("GU3_CDEMIT")[1])

	// Gera cálculos somente se o valor do fechamento for > 0
	If (cAliApur)->VLRFECH > 0

		dbSelectArea("GWF")
		GWF->( dbSetOrder(1) )
		For nX := 1 To Len(aCalc)
			nNovoNrCalc := GETSXENUM("GWF","GWF_NRCALC")

			aRet := { xFilial("GWF"), nNovoNrCalc }

			If !GWF->( dbSeek(xFilial("GWF")+nNovoNrCalc) )
				RecLock("GWF",.T.)
					GWF->GWF_FILIAL	:= xFilial("GWF")
					GWF->GWF_NRCALC	:= nNovoNrCalc
					GWF->GWF_DTCRIA	:= DDATABASE
					GWF->GWF_HRCRIA	:= TIME()
					GWF->GWF_USUCRI	:= cUserName
					GWF->GWF_TRANSP	:= cCdEmit
					GWF->GWF_AGRUP 	:= '2' // 2-Não
					GWF->GWF_ORIGEM	:= '3' // 3-APURAÇÃO PERÍODO
					GWF->GWF_TPCALC	:= '2' // 2-COMPL VALOR
					GWF->GWF_IDFRVI	:= '2'
					GWF->GWF_SEQTRE	:= '01'

					GWF->GWF_EMIPAG	:= aCalc[nX][15]
					GWF->GWF_IMPOST	:= aCalc[nX][16]

					// Dados copiados do cálculo normal do primeiro romaneio
					GWF->GWF_FINCAL	:= aCalc[nX][3]
					GWF->GWF_TPTRIB	:= aCalc[nX][4]
					GWF->GWF_PCISS	:= aCalc[nX][5]
					GWF->GWF_PCICMS	:= aCalc[nX][6]
					GWF->GWF_PCREIC	:= aCalc[nX][7]
					GWF->GWF_CRDICM	:= aCalc[nX][8]
					GWF->GWF_CRDPC	:= aCalc[nX][9]
					GWF->GWF_ADICIS	:= aCalc[nX][10]
					GWF->GWF_TPFRET := aCalc[nX][11]

					//
					GWF->GWF_BAPICO := aCalc[nX][17]
					GWF->GWF_VLPIS  := aCalc[nX][12]
					GWF->GWF_VLCOFI := aCalc[nX][13]

					GWF->GWF_BASICM := 0				
					GWF->GWF_VLICMS := 0
					GWF->GWF_BASISS := 0
					GWF->GWF_VLISS  := 0

					If aCalc[nX][5] > 0
						GWF->GWF_BASISS := aCalc[nX][17]
						GWF->GWF_VLISS  := aCalc[nX][14]
					Else
						GWF->GWF_BASICM := aCalc[nX][17]
						GWF->GWF_VLICMS := aCalc[nX][14]
					EndIf

					cRoms := ''

					For nCount := 1 To Len(aRomaneios)
						If nCount > 1
							cRoms += ','
						EndIf

						cRoms += aRomaneios[nCount][1] + '/' + aRomaneios[nCount][2]
					Next nCount

					cLog := "Calculo realizado pelo programa de fechamento." + CRLF
					cLog += "----------------------------------------------" + CRLF
					cLog += "Romaneios (filial/nr romaneio): " + CRLF + cRoms + CRLF
					cLog += "Cálculo base utilizado (filial/nr calc): " + CRLF 
					cLog += aCalc[nX][1] + "/" + aCalc[nX][2] + CRLF
					cLog += "----------------------------------------------" + CRLF

					If (cAliApur)->GV7_QTCOTA > 0
						cLog += "Neg. Cotas" + CRLF
						cLog += "Cotas contratadas: " + Str((cAliApur)->GV7_QTCOTA) + CRLF
						cLog += "Qtd não utilizada: " + Str((cAliApur)->QTD_ROM) + CRLF
						cLog += "Val médio serviço: " + Str((cAliApur)->FREAVG) + CRLF
						cLog += "Total Fech Cotas: " + Str((cAliApur)->VLRFECH) + CRLF

					Else
						nSaldo := (cAliApur)->FRETOT

						If (cAliApur)->GV7_VLALUG > 0
							cLog += "Neg. Locação" + CRLF
							cLog += "Valor aluguel: " + Str((cAliApur)->GV7_VLALUG) + CRLF
							cLog += "Valor já pago: " + Str((cAliApur)->FRETOT) + CRLF

							If (cAliApur)->GV7_VLALUG > (cAliApur)->FRETOT
								cLog += "Vl comp locação: " + Str((cAliApur)->GV7_VLALUG - (cAliApur)->FRETOT) + CRLF
								nSaldo := 0
							Else
								cLog   := "** Não gera componente locação **" + CRLF
								nSaldo := (cAliApur)->FRETOT - (cAliApur)->GV7_VLALUG 
							EndIf

							If nSaldo > 0
								cLog += "Saldo Vl Pago: " + Str(nSaldo) + CRLF
							EndIf
						EndIf

						If (cAliApur)->GV7_FRQKM > 0 .Or. (cAliApur)->GV7_VLKMEX > 0
							cLog += "Neg. Franquia Km" + CRLF
							cLog += "Franquia contratada: " + Str((cAliApur)->GV7_FRQKM) + CRLF
							cLog += "Franquia utilizada: " + Str((cAliApur)->DISTANCIA) + CRLF

							If (cAliApur)->DISTANCIA > (cAliApur)->GV7_FRQKM
								cLog += "Km Excedente: " + Str((cAliApur)->DISTANCIA - (cAliApur)->GV7_FRQKM) + CRLF
								cLog += "Valor x Km: " + Str((cAliApur)->GV7_VLKMEX) + CRLF

								If (cAliApur)->GV7_VLALUG <= 0 .And. (cAliApur)->GV7_FRQKM > 0
									nExcedente := ((cAliApur)->DISTANCIA - (cAliApur)->GV7_FRQKM) * (cAliApur)->GV7_VLKMEX	
								Else
									If nSaldo > 0
										cLog += "Saldo Vl Pago: " + Str(nSaldo) + CRLF
									EndIf

									nExcedente := ((cAliApur)->DISTANCIA - (cAliApur)->GV7_FRQKM) * (cAliApur)->GV7_VLKMEX - nSaldo
								EndIf

								cLog += "Vl comp franquia: " + Str(nExcedente) + CRLF
							Else
								cLog += "** Não houve excedente de km ** " + CRLF
							EndIf
						EndIf
					EndIf

					GWF->GWF_OBS := cLog //"Cálculo realizado pelo programa de fechamento"
				MsUnLock("GWF")

				lAdd := .T.
			EndIf

			// Relacionar doctos de carga
			If lAdd
				nQtPeso := 0
				nQtItem := 0
				nValMer := 0
				nPes3	:= 0
				nQtM3	:= 0

				GW1->(dbSetOrder(11))
				For nZ := 1 To Len(aCalc[nX][18])
					If GW1->(dbSeek(aCalc[nX][18][nZ][1] + aCalc[nX][18][nZ][2] + aCalc[nX][18][nZ][3]))
						While !GW1->(Eof()) .And. GW1->GW1_FILIAL == aCalc[nX][18][nZ][1] ;
											.And. GW1->GW1_SERDC == aCalc[nX][18][nZ][2] ;
											.And. GW1->GW1_NRDC == aCalc[nX][18][nZ][3]
							GWH->( dbSetOrder(1) )
							If !GWH->( dbSeek(xFilial("GWH")+nNovoNrCalc+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC) )
								RecLock("GWH",.T.)
									GWH->GWH_FILIAL  := xFilial("GWH")
									GWH->GWH_NRCALC  := nNovoNrCalc
									GWH->GWH_NRDC    := GW1->GW1_NRDC
									GWH->GWH_EMISDC  := GW1->GW1_EMISDC
									GWH->GWH_SERDC   := GW1->GW1_SERDC
									GWH->GWH_CDTPDC  := GW1->GW1_CDTPDC
								MsUnLock("GWH")
							EndIf

							If GWF->( dbSeek(xFilial("GWF")+nNovoNrCalc) )
								RecLock("GWF",.F.)
									If GFXCP1212210('GWF_FILROM') .And. !Empty(GW1->GW1_FILROM)
										GWF->GWF_FILROM	:= GW1->GW1_FILROM
									EndIf
									GWF->GWF_NRROM	:= GW1->GW1_NRROM
									GWF->GWF_EMIREM	:= GW1->GW1_CDREM
									GWF->GWF_EMIDES	:= GW1->GW1_CDDEST
								MsUnLock("GWF")
							EndIf

							dbSelectArea("GW8")
							GW8->(dbSetOrder(1))
							If GW8->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
								While !GW8->(Eof()) .And. GW8->GW8_FILIAL == GW1->GW1_FILIAL ;
													.And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC ;
													.And. GW8->GW8_EMISDC == GW8->GW8_EMISDC ;
													.And. GW8->GW8_SERDC == GW1->GW1_SERDC ;
													.And. GW8->GW8_NRDC == GW1->GW1_NRDC
									nQtPeso += GW8->GW8_PESOR
									nQtItem += GW8->GW8_QTDE
									nValMer += GW8->GW8_VALOR
									nPes3	+= GW8->GW8_PESOC
									nQtM3	+= GW8->GW8_VOLUME

									GW8->( dbSkip() )
								EndDo
							EndIf

							GW1->(dbSkip())
						EndDo
					EndIf
				Next nZ

				// Consultar qual o componente
				cCFEXCD := Posicione("GV9",1,xFilial("GV9")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG,"GV9_CFEXCD") // componente para excedente
				cCFALUG := Posicione("GV9",1,xFilial("GV9")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG,"GV9_CFALUG") // componente para locação
				cCFCOTA := Posicione("GV9",1,xFilial("GV9")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG,"GV9_CFCOTA") // componente para cota

				If (cAliApur)->GV7_QTCOTA > 0 // Negociação por cotas
					RecLock("GWI",.T.)
						GWI->GWI_FILIAL  := xFilial("GWI")
						GWI->GWI_NRCALC  := nNovoNrCalc
						GWI->GWI_CDCOMP  := cCFCOTA
						GWI->GWI_CDCLFR  := (cAliApur)->GV9_CDCLFR
						GWI->GWI_CDTPOP  := (cAliApur)->GV9_CDTPOP
						GWI->GWI_VLFRETE := (cAliApur)->VLRFECH
						GWI->GWI_TOTFRE  := "1"
						GWI->GWI_QTCALC  := (cAliApur)->GV7_QTCOTA - (cAliApur)->QTD_ROM // qtd cotas
						GWI->GWI_BASICM	 := Posicione("GUY",1,xFilial("GUY")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG+cCFCOTA,"GUY_BAPICO")
						GWI->GWI_BASPIS	 := Posicione("GUY",1,xFilial("GUY")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG+cCFCOTA,"GUY_BASIMP")
						GWI->GWI_IDMIN	 := '2'
					MsUnLock("GWI")

				Else // Negociação por franquia
					nSaldo := (cAliApur)->FRETOT

					If ( (cAliApur)->GV7_FRQKM > 0 .Or. (cAliApur)->GV7_VLKMEX > 0 ) .And. (cAliApur)->DISTANCIA > (cAliApur)->GV7_FRQKM
						If (cAliApur)->GV7_VLALUG <= 0 .And. (cAliApur)->GV7_FRQKM > 0
							nExcedente := ((cAliApur)->DISTANCIA - (cAliApur)->GV7_FRQKM) * (cAliApur)->GV7_VLKMEX
						Else
							nExcedente := ((cAliApur)->DISTANCIA - (cAliApur)->GV7_FRQKM) * (cAliApur)->GV7_VLKMEX - nSaldo
						EndIf
					EndIf

					// Locação
					If (cAliApur)->GV7_VLALUG > 0 // Negociação tem locação
						// Só cria o componente se o valor da locação for maior do que o valor já calculado
						If (cAliApur)->GV7_VLALUG > (cAliApur)->FRETOT
							RecLock("GWI",.T.)
								GWI->GWI_FILIAL  := xFilial("GWI")
								GWI->GWI_NRCALC  := nNovoNrCalc
								GWI->GWI_CDCOMP  := cCFALUG
								GWI->GWI_CDCLFR  := (cAliApur)->GV9_CDCLFR
								GWI->GWI_CDTPOP  := (cAliApur)->GV9_CDTPOP
								GWI->GWI_VLFRETE := aCalc[nX][17] - nExcedente
								GWI->GWI_TOTFRE  := "1"
								GWI->GWI_BASICM	 := Posicione("GUY",1,xFilial("GUY")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG+cCFALUG,"GUY_BAPICO")
								GWI->GWI_BASPIS	 := Posicione("GUY",1,xFilial("GUY")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG+cCFALUG,"GUY_BASIMP")
								GWI->GWI_QTCALC  := 1
								GWI->GWI_IDMIN	 := '2'
							MsUnLock("GWI")

							nSaldo := 0
						Else
							// Diminiu do saldo o valor já pago na locação
							nSaldo := (cAliApur)->FRETOT - (cAliApur)->GV7_VLALUG
						EndIf
					EndIf

					//Excedente franquia
					If ( (cAliApur)->GV7_FRQKM > 0 .Or. (cAliApur)->GV7_VLKMEX > 0 ) .And. (cAliApur)->DISTANCIA > (cAliApur)->GV7_FRQKM
						If cCFEXCD == cCFALUG .And. GWI->(dbSeek(xFilial("GWI")+nNovoNrCalc+(cAliApur)->GV9_CDCLFR+(cAliApur)->GV9_CDTPOP+cCFEXCD))
							RecLock("GWI",.F.)
								GWI->GWI_VLFRETE := GWI->GWI_VLFRETE + nExcedente
						Else
							RecLock("GWI",.T.)
								GWI->GWI_FILIAL  := xFilial("GWI")
								GWI->GWI_NRCALC  := nNovoNrCalc
								GWI->GWI_CDCOMP  := cCFEXCD
								GWI->GWI_CDCLFR  := (cAliApur)->GV9_CDCLFR
								GWI->GWI_CDTPOP  := (cAliApur)->GV9_CDTPOP
								GWI->GWI_TOTFRE  := "1"
								GWI->GWI_BASICM	 := Posicione("GUY",1,xFilial("GUY")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG+cCFEXCD,"GUY_BAPICO")
								GWI->GWI_BASPIS	 := Posicione("GUY",1,xFilial("GUY")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG+cCFEXCD,"GUY_BASIMP")
								GWI->GWI_QTCALC	 := (cAliApur)->DISTANCIA - (cAliApur)->GV7_FRQKM
								GWI->GWI_IDMIN	 := '2'
								GWI->GWI_VLFRETE := nExcedente
						EndIf
						MsUnLock("GWI")
					EndIf
				EndIf

				dbSelectArea("GWG")
				GWG->( dbSetOrder(1) )
				If !GWG->( dbSeek(xFilial("GWG") + nNovoNrCalc + (cAliApur)->GV9_CDCLFR + (cAliApur)->GV9_CDTPOP ) )
					RecLock("GWG",.T.)
						GWG->GWG_FILIAL := xFilial("GWG")
						GWG->GWG_NRCALC := nNovoNrCalc
						GWG->GWG_CDEMIT := cCdEmit
						GWG->GWG_DTVALI := Posicione("GV9",1,xFilial("GV9")+cCdEmit+(cAliApur)->GV9_NRTAB+(cAliApur)->GV9_NRNEG,"GV9_DTVALI")
						GWG->GWG_NRTAB  := (cAliApur)->GV9_NRTAB
						GWG->GWG_NRNEG  := (cAliApur)->GV9_NRNEG
						GWG->GWG_CDTPOP := (cAliApur)->GV9_CDTPOP
						GWG->GWG_CDCLFR := (cAliApur)->GV9_CDCLFR
						GWG->GWG_CDTPVC := (cAliApur)->GV7_CDTPVC
						GWG->GWG_CDFXTV := (cAliApur)->GV7_CDFXTV
						GWG->GWG_QTPESO := nQtPeso
						GWG->GWG_QTITEM := nQtItem
						GWG->GWG_VLMERC := nValMer
						GWG->GWG_PESCUB := nPes3
						GWG->GWG_QTM3   := nQtM3
					MsUnLock("GWG")
				EndIf

				ConfirmSX8()

				// Rateio contabil
				aRetRateio := GFERatCal(.F., nNovoNrCalc)
			EndIf
		Next nX
	EndIf

Return aRet

Static Function Atualiza(lRom, lVei, lDesmarca, lCarrega)
	Default lRom      := .T.
	Default lVei      := .T.
	Default lDesmarca := .F.
	Default lCarrega  := .F.

	If lDesmarca
		aRoms := {}
	EndIf

	If lCarrega
		If lDesmarca
			aRomsApur := {}
		EndIf

		CarregaDados()
	EndIf

	If lVei
		oBrwVei:UpdateBrowse()
	EndIf

	If lRom
		oBrwRom:Refresh()
	EndIf
Return

Function GFEA086LD(aCalc, nVlFrete)
	Local oSize
	Local oBrwCalc
	Local oColCalc
	Local nI 		 := 0
	Local aNewButton := {}
	Local aTtCalc 	 := {}
	Local aCmpCalc 	 := {}
	Local cUsrName	 := UsrRetName(RetCodUsr())

	Private cCalc 	 := ""
	Private lRetConf := .F.

	Static oDlgCalc

	aCmpCalc :=  {{"Nr. Cálculo"    , "NRCALC", "C", 06, 0, "999999"},;
				  {"Transportador"  , "TRANSP", "C", 15, 0, ""},;
				  {"Tipo Calc"	    , "TPCALC", "C", 01, 0, ""},;
				  {"Tipo Frete"     , "TPFRET", "C", 01, 0, ""},;
				  {"Data Criação"   , "DTCRIA", "D", 08, 0, ""},;
				  {"Hora Criação"   , "HRCRIA", "C", 05, 0, ""},;
				  {"Usuário Criação", "USUCRI", "C", 20, 0, ""},;
				  {"Tipo Tributação", "TPTRIB", "C", 01, 0, ""},;
				  {"Imposto"		, "IMPOST", "C", 01, 0, ""},;
				  {"Base ISS"		, "BASISS", "N", 15, 2, ""},;
				  {"Percentual ISS" , "PCISS" , "N", 15, 2, ""},;
				  {"Valor ISS" 		, "VLISS" , "N", 15, 2, ""},;
				  {"Valor ICMS" 	, "VLICMS", "N", 15, 2, ""},;
				  {"Base ICMS" 		, "BASICM", "N", 15, 2, ""},;
				  {"Percentual ICMS", "PCICMS", "N", 15, 2, ""},;
				  {"Credita ICMS" 	, "CRDICM", "C", 01, 0, ""},;
				  {"Base PIS/COFINS", "BAPICO", "N", 15, 2, ""},;
				  {"Valor PIS" 		, "VLPIS" , "N", 15, 2, ""},;
				  {"Valor COFINS" 	, "VLCOFI", "N", 15, 2, ""},;
				  {"Adiciona Imp" 	, "ADICIS", "C", 01, 2, ""},;
				  {"Valor de Frete" , "TOTFRE", "N", 15, 2, ""}}

	aTtCalc :=  {{"NRCALC", "C", 06, 0},;
			     {"TRANSP", "C", 15, 0},;
			     {"TPCALC", "C",  1, 0},;
			     {"TPFRET", "C",  1, 0},;
			     {"DTCRIA", "D",  8, 0},;
			     {"HRCRIA", "C",  5, 0},;
			     {"USUCRI", "C", 20, 0},;
			     {"TPTRIB", "C",  1, 0},;
			     {"IMPOST", "C",  1, 0},;
			     {"BASISS", "N", 15, 2},;
			     {"PCISS" , "N", 15, 2},;
			     {"VLISS" , "N", 15, 2},;
			     {"VLICMS", "N", 15, 2},;
			     {"BASICM", "N", 15, 2},;
			     {"PCICMS", "N", 15, 2},;
			     {"CRDICM", "C",  1, 0},;
			     {"BAPICO", "N", 15, 2},;
			     {"VLPIS" , "N", 15, 2},;
			     {"VLCOFI", "N", 15, 2},;
			     {"ADICIS", "C",  1, 0},;
			     {"TOTFRE", "N", 15, 2}}

	cCalc := GFECriaTab({aTtCalc, {"NRCALC"}})

	For nI := 1 To Len(aCalc)
		RecLock(cCalc, .T.)
			(cCalc)->NRCALC := cValToChar(nI)
		  	(cCalc)->TRANSP := cCdTrp
		  	(cCalc)->TPCALC := "2"
		  	(cCalc)->TPFRET := aCalc[nI][11]
		  	(cCalc)->DTCRIA := Date()
		  	(cCalc)->HRCRIA := Substr(Time(),1,5)
		  	(cCalc)->USUCRI := cUsrName
		  	(cCalc)->TPTRIB := aCalc[nI][4]
		  	(cCalc)->IMPOST := aCalc[nI][16]
		  	(cCalc)->BASISS := aCalc[nI][17]
		  	(cCalc)->PCISS  := aCalc[nI][5]
		  	If aCalc[nI][5] > 0
		  		(cCalc)->VLISS := aCalc[nI][14]
		  	Else
		  		(cCalc)->VLICMS := aCalc[nI][14]
		  	EndIf
		  	(cCalc)->BASICM := aCalc[nI][17]
		  	(cCalc)->PCICMS := aCalc[nI][6]
		  	(cCalc)->CRDICM := aCalc[nI][8]
		  	(cCalc)->BAPICO := aCalc[nI][17]
		  	(cCalc)->VLPIS  := aCalc[nI][12]
		  	(cCalc)->VLCOFI := aCalc[nI][13]
		  	(cCalc)->ADICIS := "2"
		  	(cCalc)->TOTFRE := aCalc[nI][17]
		(cCalc)->(MsUnlock())
	Next nI

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 100, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 470, 800})
	oSize:lLateral := .T.  // Calculo vertical
	oSize:Process() //executa os calculos

	DEFINE MSDIALOG oDlgCalc TITLE "Cálculos Complementares" FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] COLORS 0, 16777215 PIXEL

    /* -- Layers -- */
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgCalc, .F., .T.)

	// Cidades
	oFWLayer:AddLine('TOP', 100, .T.)
	oFWLayer:AddCollumn('Espaco1', 100, .T., 'TOP') 

	oLayerCalc := oFWLayer:GetColPanel('Espaco1', 'TOP')

	oBrwCalc := CriaBrowse(cCalc, oLayerCalc, 'Cálculos Complementares', '',,'2')
	oBrwCalc:SetDoubleClick({|| GFEA086DET()})
	oBrwCalc:ForceQuitButton(.T.)

	For nI := 1 To Len(aCmpCalc)
		oColCalc := FWBrwColumn():New()
		oColCalc:SetTitle(aCmpCalc[nI][1])
		oColCalc:SetData(&("{|| (cCalc)->" + aCmpCalc[nI][2] + "}"))
		oColCalc:SetType(aCmpCalc[nI][3])
		oColCalc:SetSize(aCmpCalc[nI][4])
		oColCalc:SetDecimal(aCmpCalc[nI][5])
		oColCalc:SetPicture(aCmpCalc[nI][6])

		oBrwCalc:SetColumns({oColCalc})
	Next nI

	oBrwCalc:Activate()

	ACTIVATE MSDIALOG oDlgCalc ON INIT EnchoiceBar(oDlgCalc,{|| If(GFEA086OK(),oDlgCalc:End(),Nil)},{||oDlgCalc:End()},,aNewButton) CENTERED

Return lRetConf

Function GFEA086EXC(cFilCalc, nNrCalc, nNrRom, nVlrTotal)
	Local nZ 		   := 0
	Local nY 		   := 0
	Local nQtM3	 	   := 0
	Local nPes3	 	   := 0
	Local nValMer 	   := 0
	Local nQtItem 	   := 0
	Local nPesoRom 	   := 0
	Local nVlrRateado  := 0
	Local nQtPesoTotal := 0
	Local nPesoPeriodo := 0
	Local aDocsRom     := {}
	Local oGFERomaneio := GFERomaneio():New()

	oGFERomaneio:setNrRom(nNrRom)
	aDocsRom := oGFERomaneio:getNrDC()

	GWH->(dbSetOrder(1))
	GW8->( dbSetOrder(1) )
	If GWH->(dbSeek(cFilCalc+nNrCalc))
		While !GWH->(Eof()) .And. GWH->GWH_FILIAL == cFilCalc .And. GWH->GWH_NRCALC == nNrCalc
			If GW8->(dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
				While !GW8->(Eof()) .And. GW8->GW8_FILIAL == GWH->GWH_FILIAL ;
									.And. GW8->GW8_CDTPDC == GWH->GWH_CDTPDC ;
									.And. GW8->GW8_EMISDC == GWH->GWH_EMISDC ;
									.And. GW8->GW8_SERDC == GWH->GWH_SERDC ;
									.And. GW8->GW8_NRDC == GWH->GWH_NRDC

					nQtPesoTotal += GW8->GW8_PESOR
					nQtItem += GW8->GW8_QTDE
					nValMer += GW8->GW8_VALOR
					nPes3	+= GW8->GW8_PESOC 
					nQtM3	+= GW8->GW8_VOLUME
					//somar outras informações de acordo com o critério

					GW8->( dbSkip() )
				EndDo
			EndIf
			GWH->( dbSkip() )
		EndDo
	EndIf

	For nZ := 1 To Len(aDocsRom)
		GW8->( dbSetOrder(1) )
		If GW8->( dbSeek(aDocsRom[nZ][1] + aDocsRom[nZ][2] + aDocsRom[nZ][3] + aDocsRom[nZ][4] + aDocsRom[nZ][5] ) )
			While !GW8->(Eof()) .And. GW8->GW8_FILIAL == aDocsRom[nZ][1] ;
								.And. GW8->GW8_CDTPDC == aDocsRom[nZ][2] ;
								.And. GW8->GW8_EMISDC == aDocsRom[nZ][3] ;
								.And. GW8->GW8_SERDC == aDocsRom[nZ][4] ;
								.And. GW8->GW8_NRDC == aDocsRom[nZ][5]

				nPesoRom += GW8->GW8_PESOR

				GW8->( dbSkip() )
			EndDo
		EndIf
	Next nZ

	If nPesoRom > 0
		If (AllTrim((cAliApur)->GV7_ESCOKM) == "Período")
			For nY := 1 To Len(aRoms)
				GW1->(dbSetOrder(16))
				If GW1->(dbSeek(aRoms[nY][1] + aRoms[nY][2]))
					While !GW1->(Eof()) .And. GW1->GW1_FILIAL == aRoms[nY][1] .And. GW1->GW1_NRROM == aRoms[nY][2]
						If GW8->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
							While !GW8->(Eof()) .And. GW8->GW8_FILIAL == GW1->GW1_FILIAL ;
												.And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC ;
												.And. GW8->GW8_EMISDC == GW1->GW1_EMISDC ;
												.And. GW8->GW8_SERDC == GW1->GW1_SERDC ;
												.And. GW8->GW8_NRDC == GW1->GW1_NRDC
								nPesoPeriodo += GW8->GW8_PESOR

								GW8->( dbSkip() )
							EndDo
						EndIf

						GW1->( dbSkip() )
					EndDo
				EndIf
			Next nY

			nVlrTotal := (nPesoRom / nPesoPeriodo) * nVlrTotal
			nVlrRateado := (nQtPesoTotal / nPesoRom) * nVlrTotal
		Else
			nVlrRateado := (nQtPesoTotal / nPesoRom) * nVlrTotal
		EndIf
	EndIf

Return nVlrRateado

Function GFEA086OK()
	lRetConf := .T.
Return .T.

Function GFEA086DET()
	Local aCoors
	Local oModelGWF
	Local oFWMVCWindow
	Local oView    := FWLoadView('GFEA086A')
	Local oModel   := oView:oModel
	Local oViewBkp := FwViewActive()

	aCoors := FWGetDialogSize(oMainWnd)
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	oModelGWF := oModel:GetModel("GFEA086A_GWF")

	oModelGWF:LoadValue("GWF_NRCALC",(cCalc)->NRCALC)
	oModelGWF:LoadValue("GWF_TRANSP",cCdTrp)
	oModelGWF:LoadValue("GWF_TPCALC",(cCalc)->TPCALC)

	oModelGWF:LoadValue("GWF_TPFRET",(cCalc)->TPFRET)
	oModelGWF:LoadValue("GWF_DTCRIA",(cCalc)->DTCRIA)
	oModelGWF:LoadValue("GWF_HRCRIA",(cCalc)->HRCRIA)
	oModelGWF:LoadValue("GWF_USUCRI",(cCalc)->USUCRI)

	oModelGWF:LoadValue("GWF_TPTRIB",(cCalc)->TPTRIB)
	oModelGWF:LoadValue("GWF_IMPOST",(cCalc)->IMPOST)
	oModelGWF:LoadValue("GWF_BASISS",(cCalc)->BASISS)
	oModelGWF:LoadValue("GWF_PCISS",(cCalc)->PCISS)
	oModelGWF:LoadValue("GWF_VLISS",(cCalc)->VLISS)
	oModelGWF:LoadValue("GWF_VLICMS",(cCalc)->VLICMS)
	oModelGWF:LoadValue("GWF_BASICM",(cCalc)->BASICM)
	oModelGWF:LoadValue("GWF_PCICMS",(cCalc)->PCICMS)
	oModelGWF:LoadValue("GWF_CRDICM",(cCalc)->CRDICM)
	oModelGWF:LoadValue("GWF_BAPICO",(cCalc)->BAPICO)
	oModelGWF:LoadValue("GWF_VLPIS" ,(cCalc)->VLPIS)
	oModelGWF:LoadValue("GWF_VLCOFI",(cCalc)->VLCOFI)
	oModelGWF:LoadValue("GWF_ADICIS",(cCalc)->ADICIS)

	oFWMVCWindow := FWMVCWindow():New()
	oFWMVCWindow:SetUseControlBar(.T.)
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered(.T.)
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
	oFWMVCWindow:SetTitle("Detalhes Cálculo")
	oFWMVCWindow:Activate(,,Nil,.F.)

	oModel:Deactivate()
	FreeObJ(oModel)
	FreeObJ(oView)
	FreeObJ(oFWMVCWindow)
	FwViewActive(oViewBkp)
Return
