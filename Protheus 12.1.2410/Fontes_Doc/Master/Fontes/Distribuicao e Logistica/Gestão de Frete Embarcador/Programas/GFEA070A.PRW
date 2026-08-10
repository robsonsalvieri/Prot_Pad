#INCLUDE "GFEA070A.ch"
#INCLUDE "PROTHEUS.CH"

STATIC lGFEA0701 := ExistBlock("GFEA0701")

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA070A
                 
Cria o vinculo entre o Fatura de Frete e um Documentos de Frete da Fatura.

@sample
GFEA070A(oModel)

@author Felipe Rafael Mendes	
@since 17/11/09
@version 1.0
/*/
//-------------------------------------------------------------------                         
Function GFEA070A()
	Local aPos
	Local oDlg
	Local oSize
	Local cDSTRAN, dDTEMIS, cEMIFAT ,cNRFAT
	Local aCpPE     := {}
	Local lOk 		:= .F.
	Local nAlt 		:= (GetScreenRes()[2])
	Local nLrg 		:= (GetScreenRes()[1])
	Local lGFEA70A2 := ExistBlock("GFEA70A2")
	Local lGFEA70A5 := ExistBlock("GFEA70A5")

	Private cGW6_SITAPR
	Private cCadastro := STR0001 //"Documento de Frete"
	Private _lFiltro  := .F.
	Private cMarca    := GetMark()
	Private cMarcaR   := GetMark()

	Private aAuxDF    := {}
	Private aDFRelFat := {}
	Private cSomaVlDF := 0

	GFEA70TSEL()

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	Pergunte("GFEA070A", .F.)

	aMKB := {{"OK"    , "C", 02, 0},;
		{"FILIAL", "C", Len(cFilAnt), 0},;
		{"CDESP" , "C", TamSX3("GW3_CDESP")[1], 0},;
		{"EMISDF", "C", TamSX3("GU3_CDEMIT")[1], 0},;
		{"SERDF" , "C", TamSX3("GW3_SERDF")[1], 0},;
		{"NRDF"  , "C", TamSX3("GW3_NRDF")[1], 0},;
		{"VLDF"  , "N", TamSX3("GW3_VLDF")[1], 2},;
		{"DTEMIS", "D", TamSX3("GW3_DTEMIS")[1], 0},;
		{"CDREM" , "C", TamSX3("GU3_CDEMIT")[1], 0},;
		{"NMREM" , "C", TamSX3("GU3_NMEMIT")[1], 0},;
		{"CDDEST", "C", TamSX3("GU3_CDEMIT")[1], 0},;
		{"NMDEST", "C", TamSX3("GU3_NMEMIT")[1], 0},;
		{"TPDF"  , "C", TamSX3("GW3_TPDF")[1], 0},;
		{"DTENT" , "D", TamSX3("GW3_DTENT")[1], 0}}

	If lGFEA70A2
		aMKB := ExecBlock("GFEA70A2",.F.,.F.,{ aMKB })
	EndIf

	aCpMKB  := {{"OK"    , Nil, ""     , ""},;
		{"FILIAL", Nil, "Filial", ""},;  //Filial
	{"CDESP" , Nil, STR0003, "@R"},; //"Especie"
	{"EMISDF", Nil, STR0004, "@!"},; //"Emissor"
	{"SERDF" , Nil, STR0005, "@!"},; //"Serie"
	{"NRDF"  , Nil, STR0006, "@!"},; //"Nr Documento"
	{"VLDF"  , Nil, STR0007, "@E 999,999,999.99"},; //"Vl Documento"
	{"DTEMIS", Nil, STR0008, ""},; //"Dt Emissao"
	{"CDREM" , Nil, STR0009, "@!"},; //"Remetente"
	{"NMREM" , Nil, STR0010, "@!"},; //"Nome Remetente"
	{"CDDEST", Nil, STR0011, "@!"},; //"Destinatario"
	{"NMDEST", Nil, STR0012, "@!"},; //"Nome Destinatario"
	{"TPDF"  , NIL, STR0013, "@!"},; //"Tipo"
	{"DTENT" , NIL, STR0014, ""}} //"Dt Entrada"

	// Ponto de entrada que permite alterar e incluir novas opções no Browse
	If lGFEA70A5
		aCpPE := ExecBlock("GFEA70A5",.F.,.F.,{ aCpMKB })
		If ValType(aCpPE) == "A" .And. !Empty(aCpPE)
			aCpMKB := aCpPE
		EndIf
	EndIf

	cAliMKB := GFECriaTab({aMKB, {"CDESP","NRDF"}})
	cAliMKB2 := GFECriaTab({aMKB, {"CDESP","NRDF"}})

	//--------------------------
	// Montagem da tela
	//--------------------------

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000,000, nAlt,nLrg})
	oSize:lLateral     := .F.  // Calculo vertical
	oSize:Process() //executa os calculos

	//Array com as posições dinamicas se quiser alterar o tamnho da tela é so alterar o tamanho do SetWindowSize
	aPos := {oSize:GetDimension("ENCHOICE","LININI"),;
		oSize:GetDimension("ENCHOICE","COLINI"),;
		oSize:GetDimension("ENCHOICE","XSIZE"),;
		oSize:GetDimension("ENCHOICE","YSIZE")}

	DEFINE MSDIALOG oDlg TITLE cCadastro ;
		FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
		TO oSize:aWindSize[3],oSize:aWindSize[4] ;
		Of oMainWnd COLORS 0, 16777215 PIXEL
	oDlg:lEscClose := .F.

	oPnlCnt := tPanel():New(aPos[1],aPos[2],,oDlg,,,,,,aPos[3],aPos[4],.F.,.F.)

	//----- Painel superior da tela principal, com as informacoes do romaneio -----//
	oPnlA := tPanel():New(00,00,,oPnlCnt,,,,,,10,20,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	//----- Splitter para permitir ao usuario movimentar os paineis dos browses -----//
	oSplitter := tSplitter():New( 0,0,oPnlCnt,100,100,1 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	//----- Painel superior da tela, para o browse de documentos de cargas -----//
	oPanelB := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
	oPanelB:Align := CONTROL_ALIGN_TOP

	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	oPnlBtn1:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),15,15,.F.,.F.)
	oPnlBtn1:Align := CONTROL_ALIGN_LEFT

	//------ Botao para adicionar relacionamento do Documento de carga com o romaneio -----//
	oBtnAdd  := TBtnBmp():NewBar("PMSSETADOWN", "PMSSETADOWN",,,,{|| GFEA070AOK()},, oPnlBtn1,,, "",,,,, "")
	oBtnAdd:cToolTip := STR0015 //"Adicionar"
	oBtnAdd:Align    := CONTROL_ALIGN_TOP

	//------ Botao para adicionar relacionamento do Documento de carga com o romaneio -----//
	oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| GFE070FIL()},,oPnlBtn1,,,"",,,,,"")
	oBtnFiltro:cToolTip := STR0016 //"Filtrar"
	oBtnFiltro:Align    := CONTROL_ALIGN_TOP

	//------Botão para selecionar Todos os componentes visiveis no Grid----------//
	oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||GFEA70ACHK(1, cAliMKB, oMark, cMarca)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := "Marca todos os documentos de frete em tela"
	oBtnChk:Align    := CONTROL_ALIGN_TOP

	//------Botão para selecionar Todos os componentes visiveis no Grid----------//
	oBtnChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||GFEA70ACHK(2, cAliMKB, oMark, cMarca)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := "Desmarca todos os documentos de frete em tela"
	oBtnChk:Align    := CONTROL_ALIGN_TOP

	//----- Painel superior do browse de documentos de carga, para colocar o titulo -----//
	oPnlBtn:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	@ 03,14  Say STR0017 Of oPnlBtn COLOR CLR_WHITE Pixel font oFont12B  //"Selecione Documentos de Frete da Fatura "
	//---------------- Fim do painel superior da tela ------------------//

	//----- Painel inferior da tela, para o browse de documentos relacionados -----//
	oPanelC := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
	oPanelC:Align := CONTROL_ALIGN_BOTTOM

	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	oPnlBtn2:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),15,15,.F.,.F.)
	oPnlBtn2:Align := CONTROL_ALIGN_LEFT

	//------ Botao para excluir relacionamento do Documento de carga com o romaneio -----//
	oBtnDel  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{|| GFE70DELDC()},,oPnlBtn2,,,"",,,,,"")
	oBtnDel:cToolTip := STR0018 //"Excluir"
	oBtnDel:Align    := CONTROL_ALIGN_TOP

	//------Botão para selecionar Todos os componentes visiveis no Grid----------//
	oBtnCh2 := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||GFEA70ACHK(1, cAliMKB2, oMarkRel, cMarcaR)},,oPnlBtn2,,,"",,,,,"")
	oBtnCh2:cToolTip := "Marca todos os documentos de frete em tela"
	oBtnCh2:Align    := CONTROL_ALIGN_TOP

	//------Botão para selecionar Todos os componentes visiveis no Grid----------//
	oBtnCh2 := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||GFEA70ACHK(2, cAliMKB2, oMarkRel, cMarcaR)},,oPnlBtn2,,,"",,,,,"")
	oBtnCh2:cToolTip := "Desmarca todos os documentos de frete em tela"
	oBtnCh2:Align    := CONTROL_ALIGN_TOP

	//----- Painel superior do browse de documentos relacionados, para colocar o titulo -----//
	oPnlBtn3:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn3:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	@ 03,14  Say STR0019 Of oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B 	 //"Documentos de Frete da Fatura Relacionados "
	//--------------- Fim do painel inferior da tela principal-----------------------//

	//---- Painel inferior - Rodapé ---//
	oPanelD := TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,18,.F.,.F.)
	oPanelD:Align := CONTROL_ALIGN_BOTTOM

	oSayRdp := tSay():New(07,15,{||"Qtde de Docs Relacionados:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) 
	oSayRdp := tSay():New(07,210,{||"Totalizador de Valor:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20)

	oGetRdp := TGet():New(05,100,{|u| If(PCount()>0,Len(aDFRelFat):=u, Len(aDFRelFat))},oPanelD,30,8,'999999999'		      ,,,,,,,.T.,,,{|| .F.},,,,,,,"Len(aDFRelFat)",,,,,.T.,.T.) //Qtde Doc Relacionados
	oGetRdp := TGet():New(05,270,{|u| If(PCount()>0,cSomaVlDF:=u, cSomaVlDF)},oPanelD,50,8,'@E 999,999,999.99',,,,,,,.T.,,,{|| .F.},,,,,,,"cSomaVlDF",,,,,.T.,.T.) // Totalizador

	// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
	cFil    := GW6->GW6_FILIAL
	cEMIFAT := GW6->GW6_EMIFAT
	cDSTRAN := posicione("GU3",1,xFilial("GU3")+cEMIFAT ,"GU3_NMEMIT")
	dDTEMIS := GW6->GW6_DTEMIS
	cNRFAT  := GW6->GW6_NRFAT

	@ 07,10  Say STR0020 Of oPnlA COLOR CLR_BLACK Pixel //"Filial: "
	@ 05,22  MSGET cFil   Picture "@!" Of oPnlA When .F. SIZE 25,10   Pixel

	@ 07,69  Say STR0021 Of oPnlA COLOR CLR_BLACK Pixel //"Dt Emissão: "
	@ 05,97  MSGET dDTEMIS Picture "@!" Of oPnlA When .F. SIZE 40,10 Pixel

	@ 07,148  Say STR0022 Of oPnlA COLOR CLR_BLACK Pixel //"Nr Fatura: "
	@ 05,173  MSGET cNRFAT Picture "@!" Of oPnlA When .F. SIZE 85,10   Pixel

	@ 07,270 Say STR0023   Of oPnlA COLOR CLR_BLACK Pixel //"Emissor:"
	@ 05,291 MSGET cEMIFAT Picture "@!" Of oPnlA When .F. SIZE 50,10  Pixel
	@ 05,344 MSGET cDSTRAN Picture "@!" Of oPnlA When .F. SIZE 140,10  Pixel

	//---------Fim da criacao dos fields ----------//

	//--1----- Seleciona a temp-table de Documentos de cargas que nao foram relacionados ao romaneio e cria o browse -----//
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(1) )
	(cAliMKB)->( dbGoTop() )

	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPanelB)
	oMark:oBrowse:cToolTip := STR0024 //"Documentos de Frete da Fatura"
	oMark:oBrowse:bAllMark := {|| GFE070MK(cAliMKB, oMark, cMarca) }
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//--------------Fim 1 -- criado o browse---------------//
	//--2----- Seleciona a temp-table de Documentos de cargas que ja foram relacionados ao romaneio e cria o browse -----//
	dbSelectArea(cAliMKB2)
	(cAliMKB2)->( dbSetOrder(1) )
	(cAliMKB2)->( dbGoTop() )

	oMarkRel := MsSelect():New(cAliMKB2,"OK",,aCpMKB,,@cMarcaR,{0,0,0,0},,,oPanelC)
	oMarkRel:oBrowse:bAllMark := {|| GFE070MK(cAliMKB2, oMarkRel, cMarcaR) }
	oMarkRel:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//--------------Fim 2--------------------//

	//----- Processa os registros e carrega os browses -----//
	Processa({|lEnd| GFE070MKB()}, STR0026, STR0027) //"Processando informações"###"Aguarde"

	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lOk := .F., oDlg:End()}, ;
		{|| lOk := .T., ODlg:End()},,,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/, /*lPadrao*/, .F. /*lHasOK*/) CENTERED

	//------ Limpa as tabelas temporarias -----//
	IIF(aDFRelFat==NIL,,aSize(aDFRelFat,0))

	GFEDelTab(cAliMKB)
	GFEDelTab(cAliMKB2)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE070MKB
Acrescenta os registros na tabela temporaria para que eles sejam exibidos na tela

@sample
GFE070MKB()   

@author Felipe Rafael Mendes
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFE070MKB()
	Local lGFEA70A3 := ExistBlock("GFEA70A3")
	Local lGFEA70A4 := ExistBlock("GFEA70A4")

	Pergunte("GFEA070A",.F.)

	dbSelectArea(cAliMKB)
	ZAP

	dbSelectArea(cAliMKB2)
	ZAP

	cQuery := " SELECT '  ' OK, GW3.GW3_FILIAL FILIAL, GW3.GW3_CDESP CDESP, GW3.GW3_EMISDF EMISDF, GW3.GW3_SERDF SERDF, GW3.GW3_NRDF NRDF , "
	cQuery += " GW3.GW3_VLDF VLDF, GW3.GW3_DTEMIS DTEMIS, GW3.GW3_CDREM CDREM, GU3REM.GU3_NMEMIT NMREM, GW3.GW3_CDDEST CDDEST, "
	cQuery += " GU3DES.GU3_NMEMIT NMDEST, GW3.GW3_TPDF TPDF, GW3.GW3_DTENT DTENT "
	cQuery += " FROM " + RetSQLName("GW3") + " GW3 "
	cQuery += " INNER JOIN " + RetSQLName("GU3") + " GU3EMI ON GU3EMI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW3.GW3_EMISDF "
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3REM ON GU3REM.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW3.GW3_CDREM AND GU3REM.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW3.GW3_CDDEST AND GU3DES.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE GW3.D_E_L_E_T_ = ' ' AND GU3EMI.D_E_L_E_T_ = ' ' AND "
	cQuery += "		GW3.GW3_FILFAT = '" + Space(TamSX3("GW3_FILFAT")[1]) + "' AND GW3.GW3_EMIFAT = '" + Space(TamSX3("GW3_EMIFAT")[1]) + "' AND "
	cQuery += "		GW3.GW3_SERFAT = '" + Space(TamSX3("GW3_SERFAT")[1]) + "' AND GW3.GW3_NRFAT = '" + Space(TamSX3("GW3_NRFAT")[1]) + "' AND "
	cQuery += "		GW3.GW3_DTEMFA = '" + Space(TamSX3("GW3_DTEMFA")[1]) + "' AND "
	cQuery += " 		GW3.GW3_FILIAL = '" + GW6->GW6_FILIAL + "' AND "
	cQuery += " 	(GW3.GW3_EMISDF = '" + GW6->GW6_EMIFAT + "' OR GU3EMI.GU3_CDEMFT = '" + GW6->GW6_EMIFAT + "' ) "

	If _lFiltro

		cQuery += " AND GW3.GW3_CDESP >= '" + MV_PAR01 + "' AND GW3.GW3_CDESP <= '" + MV_PAR02 + "' "
		cQuery += " AND GW3.GW3_EMISDF >= '" + MV_PAR03 + "' AND GW3.GW3_EMISDF <= '" + MV_PAR04 + "' "
		cQuery += " AND GW3.GW3_SERDF >= '" + MV_PAR05 + "' AND GW3.GW3_SERDF <= '" + MV_PAR06 + "' "
		cQuery += " AND GW3.GW3_NRDF >= '" + MV_PAR07 + "' AND GW3.GW3_NRDF <= '" + MV_PAR08 + "' "
		cQuery += " AND GW3.GW3_DTEMIS >= '" + DToS(MV_PAR09) + "' AND GW3.GW3_DTEMIS <= '" + DToS(MV_PAR10) + "' "

		If MV_PAR12 == 2
			cQuery += " AND GW3.GW3_TPDF <> '1' "
		EndIf

		If MV_PAR13 == 2
			cQuery += " AND GW3.GW3_TPDF <> '2' "
		EndIf

		If MV_PAR14 == 2
			cQuery += " AND GW3.GW3_TPDF <> '3' "
		EndIf

		If MV_PAR15 == 2
			cQuery += " AND GW3.GW3_TPDF <> '4' "
		EndIf

		If MV_PAR16 == 2
			cQuery += " AND GW3.GW3_TPDF <> '5' "
		EndIf

		If MV_PAR17 == 2
			cQuery += " AND GW3.GW3_TPDF <> '6' "
		EndIf

		If MV_PAR18 == 2
			cQuery += " AND GW3.GW3_TPDF <> '7' "
		EndIf
	EndIf

	If lGFEA70A3
		cQuery += ExecBlock("GFEA70A3",.F.,.F.,{ cQuery })
	EndIf

	GFEToTrb(cQuery, aMKB, cAliMKB)

	cQuery := " SELECT '  ' OK, GW3.GW3_FILIAL FILIAL, GW3.GW3_CDESP CDESP, GW3.GW3_EMISDF EMISDF, GW3.GW3_SERDF SERDF, GW3.GW3_NRDF NRDF , "
	cQuery += " GW3.GW3_VLDF VLDF, GW3.GW3_DTEMIS DTEMIS, GW3.GW3_CDREM CDREM, GU3REM.GU3_NMEMIT NMREM, GW3.GW3_CDDEST CDDEST, "
	cQuery += " GU3DES.GU3_NMEMIT NMDEST, GW3.GW3_TPDF TPDF, GW3.GW3_DTENT DTENT "
	cQuery += " FROM " + RetSQLName("GW3") + " GW3 "
	cQuery += " INNER JOIN " + RetSQLName("GU3") + " GU3EMI ON GU3EMI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW3.GW3_EMISDF "
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3REM ON GU3REM.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW3.GW3_CDREM AND GU3REM.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW3.GW3_CDDEST AND GU3DES.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE GW3.D_E_L_E_T_ = ' ' AND GU3EMI.D_E_L_E_T_ = ' ' AND "
	cQuery += "		GW3.GW3_FILFAT = '" + GW6->GW6_FILIAL + "' AND GW3.GW3_EMIFAT = '" + GW6->GW6_EMIFAT + "' AND "
	cQuery += "		GW3.GW3_SERFAT = '" + GW6->GW6_SERFAT + "' AND GW3.GW3_NRFAT = '" + GW6->GW6_NRFAT + "' AND "
	cQuery += "		GW3.GW3_DTEMFA = '" + DToS(GW6->GW6_DTEMIS) + "' "

	If lGFEA70A4
		cQuery += ExecBlock("GFEA70A4",.F.,.F.,{ cQuery })
	EndIf

	GFEToTrb(cQuery, aMKB, cAliMKB2)

	If !Empty(Mv_par11)
		If MV_PAR11 == 1 .Or. MV_PAR11 == 2

			(cAliMKB)->( dbSetOrder(MV_PAR11) )
			(cAliMKB2)->(dbSetOrder(MV_PAR11) )
		EndIf
	Else
		(cAliMKB)->( dbSetOrder(1) )
		(cAliMKB2)->(dbSetOrder(1) )
	EndIf

	(cAliMKB)->( dbGoTop() )
	(cAliMKB2)->(dbGoTop() )
	GFEA70TSEL()
	oMark:oBrowse:Refresh()
	oMarkRel:oBrowse:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA070AOK
Salva o número do Fatura de Frete no  Documentos de Frete da Fatura escolhido

@sample
GFEA070AOK()   


@author Felipe Rafael Mendes
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA070AOK()
	// Início Ponto de Entrada Britania
	If ExistBlock("XGFE070A")
		aRotAdic := ExecBlock("XGFE070A",.f.,.f.,{GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS, cAliMKB})
		if aRotAdic == .F.
			Return .F.
		endif
	EndIf
	// Fim Ponto de EntradaBritania

	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(1) )
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( Eof() )

		If (cAliMKB)->OK == cMarca

			dbSelectArea("GW3")
			GW3->( dbSetOrder(1) )
			If GW3->( dbSeek((cAliMKB)->FILIAL + (cAliMKB)->CDESP + (cAliMKB)->EMISDF + (cAliMKB)->SERDF + (cAliMKB)->NRDF + DToS((cAliMKB)->DTEMIS)) )

				/* Não permitir vincular documentos de frete para um emissor diferente do emissor da fatura exceto quando no cadastro de 
				emitentes o emissor do documento de frete indicar que o emissor da fatura é seu emissor de faturamento; */
				If GW6->GW6_EMIFAT != GW3->GW3_EMISDF .And. GW6->GW6_EMIFAT != Posicione("GU3", 1, xFilial("GU3") + GW3->GW3_EMISDF, "GU3_CDEMFT")
					Help( ,, 'Help',, STR0029, 1, 0 ) //"Não é permitido vincular documentos de frete para um emissor diferente do emissor da fatura "
					Return .F.
				EndIf 
				
				//Não permitir vincular\desvincular documentos de frete da Fatura quando a situação financeira da fatura for "Pendente" ou "Atualizada"
				If GW6->GW6_SITFIN == "2" .Or. GW6->GW6_SITFIN == "4" .Or. GW6->GW6_SITFIN == "5" 
					Help( ,, 'Help',, STR0030, 1, 0 ) //"Não é permitido vincular documentos de frete da Fatura quando a situação financeira da fatura for 'Pendente' ou 'Atualizada'"
					Return .F.
				EndIf  
					
				If GW3->GW3_TPDF == "3" .And. GW3->GW3_VLDF == 0
					Help( ,, 'HELP',, "Não é permitido incluir um documento de frete(" + GW3->GW3_CDESP + "/" + GW3->GW3_NRDF + "/" + GW3->GW3_SERDF +") deste tipo com valor zerado em uma fatura.", 1, 0)
					Return .F.
				EndIf
					
				RecLock("GW3", .F.)
					GW3->GW3_FILFAT := GW6->GW6_FILIAL
					GW3->GW3_EMIFAT := GW6->GW6_EMIFAT
					GW3->GW3_SERFAT := GW6->GW6_SERFAT
					GW3->GW3_NRFAT  := GW6->GW6_NRFAT
					GW3->GW3_DTEMFA := GW6->GW6_DTEMIS
				GW3->( MsUnlock() )
				
				RecLock("GW6", .F.)		
					//Subtrai o valor dos impostos do Doc Frete
				    If Posicione("GVT", 1, xFilial('GVT') + GW3->GW3_CDESP, "GVT_TPIMP") == '1'
				    	GW6->GW6_VLICMS += GW3->GW3_VLIMP
				    	GW6->GW6_VLFATU += GW3->GW3_IMPRET
				    	GW6->GW6_VLICRE += GW3->GW3_IMPRET
					Else
					 	GW6->GW6_VLISS += GW3->GW3_VLIMP
					 	GW6->GW6_VLFATU += GW3->GW3_IMPRET
					 	GW6->GW6_VLISRE += GW3->GW3_IMPRET
					EndIf
				GW6->( MsUnlock() )

				//Ao vincular ou desvincular documentos de frete em uma fatura nas situações "Bloqueada","Aprovada Sistema" ou "Aprovada Usuário" alterar a situação da fatura para "Recebida".
				If GW6->GW6_SITAPR != "1" 
					RecLock("GW6", .F.)
						GW6->GW6_SITAPR := "1"
					GW6->( MsUnlock() )
				EndIf
					
				// Retorna a PF para situação Enviada, se for o caso
				GFEA071CON("2")
			EndIf
			
		EndIf
		
		(cAliMKB)->( dbSkip() )
	EndDo
	
	If !IsBlind()
		GFEA70TSEL()
	EndIf
	
	Processa({|lEnd| GFE070MKB()}, STR0026, STR0027) //"Processando informações"###"Aguarde"

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE70DELDC
Limpa os dados da Fatura

@sample
GFE70DELDC()   

@author Felipe Rafael Mendes
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE70DELDC() 

	// Início Ponto de Entrada Britania
	If ExistBlock("XGFE70DE")
		aRetorno := ExecBlock("XGFE70DE",.f.,.f.,{GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS})
		If aRetorno == .F.
			Return .F. 
		EndIf
	EndIf
	// Fim Ponto de EntradaBritania
	(cAliMKB2)->(dbGoTop())
	While !(cAliMKB2)->(EOF())
		If (cAliMKB2)->OK == cMarcaR
			dbSelectArea("GW3")
			GW3->( dbSetOrder(1) )
			If GW3->( dbSeek((cAliMKB2)->FILIAL + (cAliMKB2)->CDESP + (cAliMKB2)->EMISDF + (cAliMKB2)->SERDF + (cAliMKB2)->NRDF + DToS((cAliMKB2)->DTEMIS)) ) 
		
				If GW6->GW6_SITFIN == "2" .Or. GW6->GW6_SITFIN == "4" .Or. GW6->GW6_SITFIN == "5"
					Help( ,, 'Help',, STR0033, 1, 0 )  //"Não é permitido desvincular documentos de frete da Fatura quando a situação financeira da fatura for 'Pendente' ou 'Atualizada'"
					Return .F.
				EndIf
		
				// Ponto de entrada para permitir manipulação de tabela
				// na exclusão de documento de frete vinculado a fatura
				If lGFEA0701
					ExecBlock("GFEA0701",.F.,.F.)
				EndIf
		
				RecLock("GW3", .F.)
					GW3->GW3_FILFAT := ""
					GW3->GW3_EMIFAT := ""
					GW3->GW3_SERFAT := ""
					GW3->GW3_NRFAT  := ""
					GW3->GW3_DTEMFA := CtoD(" / / ") 
				GW3->( MsUnlock() )
				
				RecLock("GW6", .F.)		
					//Subtrai o valor dos impostos do Doc Frete
				    If Posicione("GVT", 1, xFilial('GVT') + GW3->GW3_CDESP, "GVT_TPIMP") == '1'
				    	GW6->GW6_VLICMS -= GW3->GW3_VLIMP
				    	GW6->GW6_VLFATU -= GW3->GW3_IMPRET
				    	GW6->GW6_VLICRE -= GW3->GW3_IMPRET
					Else
					 	GW6->GW6_VLISS -= GW3->GW3_VLIMP
					 	GW6->GW6_VLFATU -= GW3->GW3_IMPRET
					 	GW6->GW6_VLISRE -= GW3->GW3_IMPRET
					EndIf
				GW6->( MsUnlock() )
				
				//Ao vincular ou desvincular documentos de frete em uma fatura nas situações "Bloqueada","Aprovada Sistema" ou "Aprovada Usuário" alterar a situação da fatura para "Recebida".
				If GW6->GW6_SITAPR != "1"
					RecLock("GW6", .F.)
						GW6->GW6_SITAPR := "1"
					GW6->( MsUnlock() )
				EndIf
				
				// Retorna a PF para situação Enviada, se for o caso
				GFEA071CON("2")
			EndIf
		EndIf
	(cAliMKB2)->(dbSkip())
	EndDo

	GFEA70TSEL()
		
	Processa({|lEnd| GFE070MKB()}, STR0026, STR0027) //"Processando informações"###"Aguarde"
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE070FIL()
Filtro do Browse

@sample
GFE070FIL()  

@author Felipe Rafael Mendes
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE070FIL()
	
	If Pergunte("GFEA070A", .T.)
		
		_lFiltro := .T.
		
		GFE070MKB()
		
	EndIf
	
Return .T.


Static Function GFEA70ACHK(nOp, cAliMkb, oMark, cMarcax)

	dbSelectArea(cAliMkb )
	(cAliMkb)->( dbGoTop() )
	while !Eof()
	
	    If If(nOp==1,!IsMark("OK",cMarcax),IsMark("OK",cMarcax))
	    	RecLock(cAliMkb,.F.)
				(cAliMkb)->OK := If(nOp==1, cMarcax , " ")
			MsUnlock(cAliMkb)
		EndIf
	
		(cAliMkb)->( dbSkip() )
	endDo
	
	( cAliMkb )->( DbGoTop() )
	oMark:oBrowse:Refresh()
	
Return

Static Function GFE070MK(cAliMKB, oMark, cMarcax )
    
    dbSelectArea(cAliMkb)
	(cAliMkb)->( dbGoTop() )
    While !Eof()
    
        RecLock(cAliMkb,.F.)
            (cAliMkb)->OK := If(IsMark("OK",cMarcax), " ", cMarcax)
        MsUnlock(cAliMkb)
        
        (cAliMkb)->( dbSkip() )
    
    EndDo
    
    (cAliMkb)->( DbGoTop() )
	oMark:oBrowse:Refresh()

Return

Static Function GFEToTrb( cQuery, aStruTmp, cAliasTmp, nTotalReg )
	Local nI		:= 0
	Local nJ        := 0
	Local nF        := 0
	Local nTotalRec := 0
	Local aStruQry 	:= {}
	Local cAliasTab := GetNextAlias()	    // Obtem o alias para a tabela temporária
	Default nTotalReg := 0

	cQuery := ChangeQuery(cQuery)
	MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTab, .F., .T.)},STR0012)
	For nJ := 1 to Len(aStruTmp)
		If !(aStruTmp[nJ,2] $ 'CM')
			TCSetField(cAliasTab, aStruTmp[nJ,1], aStruTmp[nJ,2],aStruTmp[nJ,3],aStruTmp[nJ,4])
		EndIf
	Next nJ
	nTotalRec:= (cAliasTab)->(RecCount())
	aStruQry := (cAliasTab)->(DbStruct())
	nF			:= Len(aStruQry)
	(cAliasTab)->(DbGoTop())
	ProcRegua( nTotalRec )
	While ! (cAliasTab)->(Eof())
		If nTotalReg%5000 = 0 
			IncProc()
		EndIf
		IncProc()
		(cAliasTmp)->(DbAppend())
		For nI := 1 To nF
			If aStruQry[nI,2] <> 'M'
				(cAliasTmp)->(FieldPut(FieldPos(aStruQry[nI,1]),(cAliasTab)->(FieldGet((cAliasTab)->(FieldPos(aStruQry[nI,1]))))))
			Endif
		Next nI
		nTotalReg++
		(cAliasTab)->(DbSkip())
	End
	(cAliasTab)->(dbCloseArea())
	DbSelectArea(cAliasTmp)
Return Nil

/*
{Protheus.doc} GFEA70TSEL
Função que realiza a busca Documentos de Frete Relacionados a Fatura de Frete.
Confere a quantidade de documentos relacionados e realiza a soma dos seus
respectivos valores. Preenche os totais nos campos do rodapé.

@sample
GFEA70TSEL()

@author philippe.bretas
@since 24/09/2024
@version 1.0
*/     

Static Function GFEA70TSEL()
	Local nX  := 0
	Local cAliasGW3 := GetNextAlias()

	//Reset das variaveis antes de realizar a busca
	aAuxDF	  := {}
	aDFRelFat := {}
	cSomaVlDF := 0

	//Busca DF Relacionados a Fatura de Frete
	BeginSQL Alias cAliasGW3
		SELECT GW3.GW3_VLDF   AS VLDF,
			   GW3.R_E_C_N_O_ AS RECNOGW3			   
		FROM %Table:GW3% GW3
		WHERE GW3.GW3_FILFAT = %Exp:GW6->GW6_FILIAL%
		AND GW3.GW3_EMIFAT   = %Exp:GW6->GW6_EMIFAT%
		AND GW3.GW3_NRFAT    = %Exp:GW6->GW6_NRFAT%
		AND GW3.GW3_SERFAT   = %Exp:GW6->GW6_SERFAT%
		AND GW3.GW3_DTEMFA   = %Exp:GW6->GW6_DTEMIS%
		AND GW3.%NotDel%
	EndSQL

	While (cAliasGW3)->(!EoF())
		AADD(aAuxDF, (cAliasGW3)->RECNOGW3)
		AADD(aDFRelFat,{(cAliasGW3)->RECNOGW3,;
						(cAliasGW3)->VLDF})
		(cAliasGW3)->(DbSkip())
	EndDo
	(cAliasGW3)->(dbCloseArea())

	//Soma os valores dos DF Relacionados
	For nX:= 1 To Len(aDFRelFat)
		cSomaVlDF += aDFRelFat[nX][2]
	Next

Return cSomaVlDF
