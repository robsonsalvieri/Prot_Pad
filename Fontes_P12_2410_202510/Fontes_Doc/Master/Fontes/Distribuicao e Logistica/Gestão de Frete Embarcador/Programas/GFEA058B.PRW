#INCLUDE "PROTHEUS.CH"
                   
//------------------------------------------------------------------- 
/*/{Protheus.doc} GFEA058B
                 
Cria o vinculo  entre a viagem e os romaneios

@sample
GFEA058B()

@author Siegklenes.Beulke	
@since 17/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
  
                                      
Function GFEA058B()                      

	Local oDlg
	Local nAlt := (GetScreenRes()[2]-250)
	Local nLrg := (GetScreenRes()[1]-100)
	Local oSize
	Local aPos
	Local lIsDark := GfeDark()
	
	If GWP->GWP_SIT == '2'
		GfeMsgErro("Não é possível relacionar romaneios em viagens que já partiram.")
		Return
	EndIf
	
	Private cCadastro := "Romaneio"
	Private cMarca := GetMark()
	Private oListDoc
	
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//---------------------------------------------- 
	CursorWait()
	aMKB :=    {{"OK"       ,"C",02,0},;
				{"FILIAL"   ,"C",FwSizeFilial(),0},;
				{"ROMANEIO" ,"C",10,0},;
				{"DTCRIACAO","D",08,0},;
				{"HORA"     ,"C",05,0},;
				{"TPOPER"   ,"C",50,0},;
				{"CLSFRETE" ,"C",50,0},;
				{"TPVEI"    ,"C",10,0}}

	aCpMKB  := {{"OK"        ,NIL,"",""},;
				{"FILIAL"    ,NIL,"Filial","@!"},;
				{"ROMANEIO"  ,NIL,"Romaneio","@!"},;
				{"DTCRIACAO" ,NIL,"Data de Criação",""},;	
				{"HORA"      ,NIL,"Hora","@R"},;
				{"TPOPER"    ,NIL,"Tipo de Operação",""},;
				{"CLSFRETE"  ,NIL,"Class. Frete",""},;
				{"TPVEI"     ,NIL,"Tipo de Veículo","@!"}}
	

	
	cAliMKB := GFECriaTab({aMKB, {"ROMANEIO"}})
	
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//----------------------------------------------
	
	aMKB2 := {  {"FILIAL"   ,"C",FwSizeFilial(),0},;
				{"ROMANEIO" ,"C",10,0},;
				{"DTCRIACAO","D",08,0},;
				{"HORA"     ,"C",05,0},;
				{"TPOPER"   ,"C",50,0},;
				{"CLSFRETE" ,"C",50,0},;
				{"TPVEI"    ,"C",10,0}}
	
	cAliMKB2 := GFECriaTab({aMKB2, {"ROMANEIO"}})
	
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
	
	If lIsDark
		DEFINE MSDIALOG oDlg TITLE cCadastro ;
								FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
								Of oMainWnd PIXEL	
	Else 
		DEFINE MSDIALOG oDlg TITLE cCadastro ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
							Of oMainWnd COLORS 0, 16777215 PIXEL
	EndIf 
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
	
	//------ Botao para adicionar relacionamento do romaneio com a viagem -----//
	oBtnAdd  := TBtnBmp():NewBar("PMSSETADOWN", "PMSSETADOWN",,,,{|| GFEA058BOK()},, oPnlBtn1,,, "",,,,, "")
	oBtnAdd:cToolTip := "Adicionar"
	oBtnAdd:Align    := CONTROL_ALIGN_TOP
	
//	//------ Botao para adicionar relacionamento do Documento de carga com o romaneio -----//
//	oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| GFE070FIL()},,oPnlBtn1,,,"",,,,,"")
//	oBtnFiltro:cToolTip := STR0016 //"Filtrar"
//	oBtnFiltro:Align    := CONTROL_ALIGN_TOP
//	
	//------Botão para selecionar Todos os componentes visiveis no Grid----------//
	oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||GFEA58BCHK(1)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := "Marca todos os documentos de frete em tela"
	oBtnChk:Align    := CONTROL_ALIGN_TOP
	
	//------Botão para selecionar Todos os componentes visiveis no Grid----------//
	oBtnChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||GFEA58BCHK(2)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := "Desmarca todos os documentos de frete em tela"
	oBtnChk:Align    := CONTROL_ALIGN_TOP
	
	//----- Painel superior do browse de documentos de carga, para colocar o titulo -----//
	oPnlBtn:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	@ 03,14  Say "Selecione romaneios para a viagem" Of oPnlBtn COLOR CLR_WHITE Pixel font oFont12B  //
	//---------------- Fim do painel superior da tela ------------------//
	
	//----- Painel inferior da tela, para o browse de documentos relacionados -----//
	oPanelC := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
	oPanelC:Align := CONTROL_ALIGN_BOTTOM
	
	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	oPnlBtn2:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),15,15,.F.,.F.)
	oPnlBtn2:Align := CONTROL_ALIGN_LEFT
	
	//------ Botao para excluir relacionamento do Documento de carga com o romaneio -----//
	oBtnDel  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{|| GFE58BDELRC()},,oPnlBtn2,,,"",,,,,"")
	oBtnDel:cToolTip := "Excluir"
	oBtnDel:Align    := CONTROL_ALIGN_TOP
	
	//----- Painel superior do browse de documentos relacionados, para colocar o titulo -----//
	oPnlBtn3:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn3:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	@ 03,14  Say "Romaneios da viagem relacionados" Of oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B 	 //
	//--------------- Fim do painel inferior da tela principal-----------------------//
	
	// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
	cCdTrp := GWP->GWP_CDTRP
	cDSTRAN := posicione("GU3",1,xFilial("GU3")+cCdTrp ,"GU3_NMEMIT")
	cNrViag := GWP->GWP_VIAGEM
	
	If lIsDark
		@ 07,10  Say "Viagem:"  Of oPnlA Pixel
		@ 05,22  MSGET cNrViag   Picture "@!" Of oPnlA When .F. SIZE 25,10   Pixel
		
		@ 07,69 Say "Transp:"   Of oPnlA Pixel
		@ 05,97 MSGET cCdTrp Picture "@!" Of oPnlA When .F. SIZE 50,10  Pixel
		@ 05,150 MSGET cDSTRAN Picture "@!" Of oPnlA When .F. SIZE 140,10  Pixel
	Else 
		@ 07,10  Say "Viagem:"  Of oPnlA COLOR CLR_BLACK Pixel
		@ 05,22  MSGET cNrViag   Picture "@!" Of oPnlA When .F. SIZE 25,10   Pixel
		
		@ 07,69 Say "Transp:"   Of oPnlA COLOR CLR_BLACK Pixel
		@ 05,97 MSGET cCdTrp Picture "@!" Of oPnlA When .F. SIZE 50,10  Pixel
		@ 05,150 MSGET cDSTRAN Picture "@!" Of oPnlA When .F. SIZE 140,10  Pixel
	EndIf	
	//---------Fim da criacao dos fields ----------//
	
	//--1----- Seleciona a temp-table de Documentos de cargas que nao foram relacionados ao romaneio e cria o browse -----//
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(1) )
	(cAliMKB)->( dbGoTop() )
	
	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPanelB)
	oMark:oBrowse:cToolTip := "Romaneios da viagem"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------Fim 1 -- criado o browse---------------//
	//--2----- Seleciona a temp-table de Documentos de cargas que ja foram relacionados ao romaneio e cria o browse -----//
	dbSelectArea(cAliMKB2)
	(cAliMKB2)->( dbSetOrder(1) )
	(cAliMKB2)->( dbGoTop() )
	@ 0,0 Listbox oListDoc Fields (cAliMKB2)->FILIAL,; 
	(cAliMKB2)->ROMANEIO,;
	(cAliMKB2)->DTCRIACAO,;
	(cAliMKB2)->HORA  ,;
	(cAliMKB2)->TPOPER   ,;
	(cAliMKB2)->CLSFRETE    ,;
	(cAliMKB2)->TPVEI,;
	FieldSizes TamSx3("GWN_FILIAL")[1],TamSx3("GWN_NRROM")[1],TamSx3("GWN_DTIMPL")[1],TamSx3("GWN_HRIMPL")[1],TamSx3("GWN_CDTPOP")[1],TamSx3("GWN_CDCLFR")[1],TamSx3("GWN_CDTPVC")[1];
	Size 140,290 Pixel Of oPanelC   ;
	HEADERS "Filial",;
	"Romaneio" ,;
	"Data de Criação" ,;
	"Hora" ,;
	"Tipo de Operação" ,;
	"Class. Frete" ,;
	"Tipo de Veículo"
	
	oListDoc:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------Fim 2--------------------//
	
	//----- Processa os registros e carrega os browses -----//
	Processa({|lEnd| GFE058BMKB()}, "Processando informações", "Aguarde")
	
	CursorArrow()
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, ;
			{|| oDlg:End()} ) CENTERED
	
	GFEDelTab(cAliMKB)
	GFEDelTab(cAliMKB2)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE058BMKB
Acrescenta os registros na tabela temporaria para que eles sejam exibidos na tela

@sample
GFE058BMKB()   

@author Siegklenes Beulke
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFE058BMKB()
	
	Local cNMREM, cNMDEST
	Local lFlag := .F.
	
//	Pergunte("GFEA058B",.F.)
	
	dbSelectArea(cAliMKB)
	ZAP
	
	dbSelectArea(cAliMKB2)
	ZAP
	
	cQuery := " SELECT DISTINCT '  ' OK, GWN.GWN_FILIAL FILIAL, GWN.GWN_NRROM ROMANEIO, GWN.GWN_DTIMPL DTCRIACAO, GWN.GWN_HRIMPL HORA, GWN.GWN_CDTPOP TPOPER, GWN.GWN_CDCLFR CLSFRETE , " 
	cQuery += " GWN.GWN_CDTPVC TPVEI "
	cQuery += " FROM " + RetSQLName("GWN") + " GWN "
	cQuery += " LEFT JOIN " + RetSQLName("GWF") + " GWF ON GWF.GWF_FILIAL = GWN.GWN_FILIAL AND GWF.GWF_NRROM = GWN.GWN_NRROM AND GWF.D_E_L_E_T_ = ' ' "	
	cQuery += " WHERE GWN.D_E_L_E_T_ = ' ' AND GWN.GWN_VIAGEM = ' ' AND "
	cQuery += "		(GWF.GWF_NRCALC IS NULL OR GWF.GWF_ORIGEM IN ('1','3')) AND"
	cQuery += "		GWN.GWN_SIT IN ('1','2') AND "
	cQuery += "		GWN.GWN_CDTRP = '" + GWP->GWP_CDTRP + "'"
	
	SqlToTrb(ChangeQuery(cQuery), aMKB, cAliMKB)
	
	cQuery := " SELECT GWN.GWN_FILIAL FILIAL, GWN.GWN_NRROM ROMANEIO, GWN.GWN_DTIMPL DTCRIACAO, GWN.GWN_HRIMPL HORA, GWN.GWN_CDTPOP TPOPER, GWN.GWN_CDCLFR CLSFRETE , " 
	cQuery += " GWN.GWN_CDTPVC TPVEI "
	cQuery += " FROM " + RetSQLName("GWN") + " GWN "
	cQuery += " WHERE GWN.D_E_L_E_T_ = ' ' AND "
	cQuery += "		GWN.GWN_VIAGEM = '" + GWP->GWP_VIAGEM + "'"
	
	SqlToTrb(ChangeQuery(cQuery), aMKB2, cAliMKB2)
	
	(cAliMKB)->( dbGoTop() )
	(cAliMKB2)->(dbGoTop() )
	oMark:oBrowse:Refresh()
	oListDoc:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA058BOK
Salva o número do Fatura de Frete no  Documentos de Frete da Fatura escolhido

@sample
GFEA058BOK()   


@author Siegklenes Beulke
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA058BOK()
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(1) )
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( Eof() )
		
		If (cAliMKB)->OK == cMarca
		
			dbSelectArea("GWN")
			GWN->( dbSetOrder(1) )
			If GWN->( msSeek((cAliMKB)->FILIAL + (cAliMKB)->ROMANEIO) )
				
				If !GFEA058RVG()
					MsgInfo("Não é possível vincular o romaneio " + Alltrim((cAliMKB)->ROMANEIO) + " que possui documento com frete combinado/simulação com origem erp.")
					Processa({|lEnd| GFE058BMKB()}, "Processando informações", "Aguarde")
					Return .F.
				EndIf
				
				RecLock("GWN", .F.)
					GWN->GWN_CALC := "4"
					GWN->GWN_MTCALC := "Foi vinculada uma viagem ao romaneio"
					GWN->GWN_DTCALC := CToD("  /  /    ")
					GWN->GWN_HRCALC := ""
				MsUnLock("GWN")
				GFE58ATVG(GWP->GWP_VIAGEM,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.,'')
				
			EndIf
			
		EndIf
		
		(cAliMKB)->( dbSkip() )
	EndDo
		
	Processa({|lEnd| GFE058BMKB()}, "Processando informações", "Aguarde")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE58BDELRC
Limpa o número do Romaneio 

@sample
GFE58BDELRC()   

@author Siegklenes Beulke
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE58BDELRC()

	dbSelectArea("GWN")
	GWN->( dbSetOrder(1) )
	If GWN->( msSeek((cAliMKB2)->FILIAL + (cAliMKB2)->ROMANEIO) )
	
		If GWN->GWN_SIT == '3' .Or. GWN->GWN_SIT == '4'
			If MsgYesNo("O romaneio está liberado/encerrado." + CRLF + "Não será possível vincular o romaneio em uma viagem até que seja reaberto." + CRLF + "Deseja reabrir o romaneio?")
				GFEA050REA()
			EndIf
		EndIf
		RecLock("GWN", .F.)
			GWN->GWN_CALC := "4"
			GWN->GWN_MTCALC := "Foi desvinculada a viagem do romaneio"
			GWN->GWN_DTCALC := CToD("  /  /    ")
			GWN->GWN_HRCALC := ""
		MsUnLock("GWN")
		GFE58ATVG('',GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.,GWP->GWP_VIAGEM)
		
	EndIf

	Processa({|lEnd| GFE058BMKB()}, "Processando informações", "Aguarde")
	
Return .T.

Static Function GFEA58BCHK(nOp)
	dbSelectArea(cAliMKB)
	
	(cAliMKB)->( dbGoTop() )
	
	While !(cAliMKB)->( Eof() )
	
	    If If(nOp==1,!IsMark("OK",cMarca),IsMark("OK",cMarca))
	    	RecLock(cAliMKB,.F.)
				
				(cAliMKB)->OK := If(nOp==1, cMarca, " ")
			
			MsUnlock(cAliMKB)
			
		EndIf
	
		(cAliMKB)->( dbSkip() )
	
	EndDo
	
	
	(cAliMKB)->( DbGoTop() )
	
	oMark:oBrowse:Refresh()
	
Return


