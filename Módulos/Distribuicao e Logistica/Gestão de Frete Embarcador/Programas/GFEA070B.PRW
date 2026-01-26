#INCLUDE "GFEA070B.ch"
#INCLUDE "PROTHEUS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA070B
                 
Cria o vinculo entre o Fatura de Frete e PRE-Fatura.

@sample
GFEA070B()

@author Felipe Rafael Mendes	
@since 17/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
                                      
Function GFEA070B()                      

	Local oDlg
	Local nAlt := (GetScreenRes()[2]-400)
	Local nLrg := (GetScreenRes()[1]-200)
	Local cDSTRAN, dDTEMIS, cEMIFAT ,cNRFAT  
	Local oSize
	Local aPos
	Local cCodFil := xFilial("GW6")
	Private cGW6_SITAPR
	Private cCadastro := STR0001 //"Pré-Fatura"
	Private cMarca := GetMark()
	Private oListDoc
	Private cAliMKB  := Nil
	Private cAliMKB2 := Nil
	Private aMKB     := Nil
	Private aMKB2    := Nil
	
	// Criacao das tabela temporarias das Pré-fatuas para os Browses
	// Pré-faturas não vinculadas	
	aMKB :=   { {"OK"     , "C", 02, 0},;
				{"FILIAL", "C", Len(cFilAnt), 0},;
				{"NRPF"   , "C", TAMSX3("GWJ_NRPF")[1],0},;
				{"CDTRP"  , "C", TamSX3("GU3_CDEMIT")[1], 0},;
				{"NMTRP"  , "C", 50, 0},;
				{"VLPF"   , "N", 12, 2},;
				{"SIT"    , "C", 01, 0},;
				{"SITDES" , "C", 15, 0},;
				{"DTIMPL" , "D", 08, 0},;
				{"HRIMPL" , "C", 05, 0},;
				{"USUIMP" , "C", 50, 0},;
				{"DTENV"  , "D", 08, 0},;
				{"HRENV"  , "C", 05, 0}}
	
	aCpMKB := {{"OK"    , Nil, ""     , ""                 },;
			   {"FILIAL", Nil, "Filial", ""                },; //Filial
			   {"NRPF"  , Nil, STR0003, TAMSX3("GWJ_NRPF")[1],0         },; //"Pre-fatura"
			   {"CDTRP" , Nil, STR0004, "999999999"        },; //"Transportador"
			   {"NMTRP" , Nil, STR0005, "@!"               },; //"Nome Transportador"
			   {"VLPF"  , Nil, STR0006, "@E 999,999,999.99"},; //"Valor Pré-Fatura"
			   {"SIT"   , Nil, STR0007, "@!"               },; //"Situação"
			   {"SITDES", Nil, STR0008, "@!"               },; //"Descrição Situação"
			   {"DTIMPL", Nil, STR0009, ""                 },; //"Dt Criação"
			   {"HRIMPL", Nil, STR0010, ""                 },; //"Hr Criação"
			   {"USUIMP", Nil, STR0011, ""                 },; //"Usuário Gerador"
			   {"DTENV" , Nil, STR0012, ""                 },; //"Dt Envio"
			   {"HRENV" , Nil, STR0013, ""                 }} //"Hr Envio"
	
	cAliMKB := GFECriaTab({aMKB, {"NRPF"}}) 

	//Pré-faturas vinculadas	
	aMKB2 := {{"NRPF"  , "C", TAMSX3("GWJ_NRPF")[1],0},;
			  {"FILIAL", "C", Len(cFilAnt), 0},;
			  {"CDTRP" , "C", TamSX3("GU3_CDEMIT")[1], 0},;
			  {"NMTRP" , "C", 50, 0},; 
			  {"VLPF"  , "N", 12, 2},;
			  {"SIT"   , "C", 01, 0},;
			  {"SITDES", "C", 15, 0},;
			  {"DTIMPL", "D", 08, 0},;
			  {"HRIMPL", "C", 05, 0},;
			  {"USUIMP", "C", 50, 0},;
			  {"DTENV" , "D", 08, 0},;
			  {"HRENV" , "C", 05, 0}}
	
	cAliMKB2 := GFECriaTab({aMKB2, {"NRPF"}})
	
	//--------------------------
	// Montagem da tela        
	//--------------------------
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000,000, nAlt,nLrg})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
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
					oBtnAdd  := TBtnBmp():NewBar("DOWN", "DOWN",,,,{|| GFEA070BOK()},, oPnlBtn1,,, "",,,,, "")
					oBtnAdd:cToolTip := STR0014 //"Adicionar"
					oBtnAdd:Align    := CONTROL_ALIGN_TOP
					
					//------ Botao para adicionar relacionamento do Documento de carga com o romaneio -----//			
					oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro", "brw_filtro",,,,{|| GFE070FL()},, oPnlBtn1,,, "",,,,, "")
					oBtnFiltro:cToolTip := STR0028 //"Filtrar"
					oBtnFiltro:Align    := CONTROL_ALIGN_TOP
			
	 		//----- Painel superior do browse de documentos de carga, para colocar o titulo -----//
			oPnlBtn:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,12,.F.,.F.)
				oPnlBtn:Align := CONTROL_ALIGN_TOP
				oFont12B := TFont():New('Arial',,-12,,.T.)
	    		@ 03,14  Say STR0015 Of oPnlBtn COLOR CLR_WHITE Pixel font oFont12B  //"Selecione a Pré-Fatura "
	 	//---------------- Fim do painel superior da tela ------------------//
		
		//----- Painel inferior da tela, para o browse de documentos relacionados -----//
		oPanelC := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
			oPanelC:Align := CONTROL_ALIGN_BOTTOM
			
			//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	   		oPnlBtn2:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),15,15,.F.,.F.)
				oPnlBtn2:Align := CONTROL_ALIGN_LEFT
		    
				    //------ Botao para excluir relacionamento do Documento de carga com o romaneio -----//			
					oBtnDel  := TBtnBmp():NewBar("UP", "UP",,,,{|| GFE70DELD()},, oPnlBtn2,,, "",,,,, "")
					oBtnDel:cToolTip := STR0016 //"Excluir"
					oBtnDel:Align    := CONTROL_ALIGN_TOP
					
			//----- Painel superior do browse de documentos relacionados, para colocar o titulo -----//	
		    	oPnlBtn3:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,12,.F.,.F.)
				oPnlBtn3:Align := CONTROL_ALIGN_TOP
				oFont12B := TFont():New('Arial',,-12,,.T.)
	    		@ 03,14  Say STR0017 Of oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B 	 //"Pré-Fatura Relacionadas "
		//--------------- Fim do painel inferior da tela principal-----------------------//

	// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
	cEMIFAT := GW6->GW6_EMIFAT
	cDSTRAN := Posicione("GU3", 1, xFilial("GU3") + cEMIFAT, "GU3_NMEMIT")	
	dDTEMIS := GW6->GW6_DTEMIS
	cNRFAT  := GW6->GW6_NRFAT   
	
	@ 07,10  Say STR0018 Of oPnlA COLOR CLR_BLACK Pixel //"Filial: "
   	@ 05,22  MSGET cCodFil Picture "@!" Of oPnlA Valid When .F. SIZE 25,10 Pixel
   	        
	@ 07,69   Say STR0019 Of oPnlA COLOR CLR_BLACK Pixel //"Dt Emissão: "
   	@ 05,97   MSGET dDTEMIS Picture "@!" Of oPnlA Valid When .F. SIZE 40,10  Pixel
	        
	@ 07,148  Say STR0020 Of oPnlA COLOR CLR_BLACK Pixel //"Nr Fatura: "
    @ 05,173  MSGET cNRFAT Picture "@!" Of oPnlA Valid When .F. SIZE 85,10  Pixel
	        
	@ 07,270 Say STR0021   Of oPnlA COLOR CLR_BLACK Pixel //"Emissor:"
	@ 05,291 MSGET cEMIFAT Picture "@!" Of oPnlA Valid When .F. SIZE 50,10   Pixel
	@ 05,344 MSGET cDSTRAN Picture "@!" Of oPnlA Valid When .F. SIZE 140,10  Pixel
	
	//---------Fim da criacao dos fields ----------//
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(1) )
	(cAliMKB)->( dbGoTop() )
	
	oMark := MsSelect():New(cAliMKB, "OK",, aCpMKB,, @cMarca, {0,0,0,0},,, oPanelB)
	oMark:oBrowse:cToolTip := STR0001 //"Pré-Fatura"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//-------------------------------
	
	dbSelectArea(cAliMKB2)
	(cAliMKB2)->( dbSetOrder(1) )
	(cAliMKB2)->( dbGoTop() )
	
	@ 0,0 Listbox oListDoc Fields (cAliMKB2)->FILIAL ,;
								  (cAliMKB2)->NRPF   ,;
	                              (cAliMKB2)->CDTRP  ,;
								  (cAliMKB2)->NMTRP  ,;
								  Transform((cAliMKB2)->VLPF,'@E 999,999,999.99'),; //transforma um campo numerico numa string com mascara
								  (cAliMKB2)->SIT    ,; 
							      (cAliMKB2)->SITDES ,; 
							      (cAliMKB2)->DTIMPL ,;
			                      (cAliMKB2)->HRIMPL ,;
			                      (cAliMKB2)->USUIMP ,;
								  (cAliMKB2)->DTENV  ,;
								  (cAliMKB2)->HRENV  ,; 
								  FieldSizes 08,TamSx3("GU3_CDEMIT")[1],50,12,20,08,05,50,08,05;
			                      Size 140,290 Pixel Of oPanelC  ;
			                      HEADERS "Filial",; //Filial
			                      		  STR0003 ,; //"Pre-fatura"
										  STR0004 ,; //"Transportador"
										  STR0005 ,; //"Nome Transportador"
										  STR0006 ,; //"Valor Pré-Fatura"
										  STR0007 ,; //"Situação"
										  STR0008 ,; //"Descrição Situação"
										  STR0009 ,; //"Dt Criação"
										  STR0010 ,; //"Hr Criação"
										  STR0011 ,; //"Usuário Gerador"
										  STR0012 ,; //"Dt Envio"
										  STR0013    //"Hr Envio"
	                                

	oListDoc:Align := CONTROL_ALIGN_ALLCLIENT
	
	//----- Processa os registros e carrega os browses -----//
	Processa({|lEnd| GFE070MKB(GW6->GW6_FILIAL, GW6->GW6_EMIFAT)}, STR0022, STR0023) //"Processando informações"###"Aguarde"
	CursorArrow()

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{|| GFEA070BOK(), oDlg:End()},;
		{||ODlg:End()},,,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/, /*lPadrao*/, .F. /*lHasOK*/) CENTERED
	
	//------ Limpa as tabelas temporarias -----//
	
	GFEDelTab(cAliMKB)
	GFEDelTab(cAliMKB2)
	
	dbSelectArea("GWJ")
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

Static Function GFE070MKB(cFilGW6, cTrpGW6)
	Local nVLPF := 0
	Local aComboSit := StrTokArr(Posicione("SX3", 2, "GWJ_SIT", "X3_CBOX"), ';')
 	Local cGU3IDFED := Posicione("GU3", 1, xFilial("GU3") + cTrpGW6, "GU3_IDFED")
 	
	dbSelectArea(cAliMKB)
	ZAP
	
	dbSelectArea(cAliMKB2)
	ZAP

	//Browse 1 - Documentos não vinculados a uma fatura.
	cQuery := " SELECT '' AS OK, GWJ.GWJ_FILIAL AS FILIAL, GWJ.GWJ_NRPF AS NRPF, GWJ.GWJ_CDTRP AS CDTRP, GU3.GU3_NMEMIT AS NMTRP, "
	cQuery += "'' AS VLPF, "
	cQuery += " GWJ.GWJ_SIT AS SIT, '' AS SITDES, GWJ.GWJ_DTIMPL AS DTIMPL, GWJ.GWJ_HRIMPL AS HRIMPL, GWJ.GWJ_USUIMP AS USUIMP, "
	cQuery += " GWJ.GWJ_DTENV AS DTENV, GWJ.GWJ_HRENV AS HRENV "
	cQuery += " FROM " + RetSQLName("GWJ") + " GWJ "
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3"
	cQuery += " ON GU3.GU3_FILIAL = '" + xFilial("GU3") + "' "
	cQuery += " AND GU3.GU3_CDEMIT = GWJ.GWJ_CDTRP "
	cQuery += " WHERE GWJ.D_E_L_E_T_ = ' ' "
	cQuery += " AND GWJ.GWJ_FILIAL = '"+cFilGW6+"'"
	If (SuperGetMV('MV_VLCNPJ',,'1')) == "2" 
		cQuery += " AND GWJ.GWJ_CDTRP IN (SELECT GU3_CDEMIT FROM "+RetSQLName("GU3")+" WHERE GU3_FILIAL = '" + xFilial("GU3") + "' AND SUBSTRING(GU3_IDFED,1,8) = SUBSTRING('"+cGU3IDFED+"',1,8))"		
	else
		cQuery += " AND GWJ.GWJ_CDTRP = '"+cTrpGW6+"'"
	EndIf
	cQuery += " AND GWJ.GWJ_FILFAT = '' AND GWJ.GWJ_EMIFAT = ''  AND GWJ.GWJ_SERFAT = '' AND GWJ.GWJ_NRFAT = '' AND GWJ.GWJ_DTEMFA = '' "
	If SuperGetMv("MV_GFEPF1",,'1') == '1'
		cQuery += " AND GWJ.GWJ_SIT = '3' "
	Else
		cQuery += " AND (GWJ.GWJ_SIT = '2' OR GWJ.GWJ_SIT = '3') "
	EndIf
	cQuery += " ORDER BY GWJ.GWJ_FILIAL, GWJ.GWJ_CDTRP "

	cQuery := ChangeQuery(cQuery)
	GFEToTrb(cQuery, aMKB, cAliMKB)
	//dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliMKB, .T.)
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( EOF() )
		nVLPF := 0
		dbSelectArea("GWF")
		GWF->( dbSetOrder(3) )
		GWF->( dbSeek((cAliMKB)->FILIAL + (cAliMKB)->NRPF) )
		While !GWF->( Eof() ) .And. GWF->GWF_FILPRE == (cAliMKB)->FILIAL .And. GWF->GWF_NRPREF == (cAliMKB)->NRPF        
		                                           
			nVLPF += VLTOTFRET()
			
			dbSelectArea("GWF")
			GWF->( dbSkip() )
		EndDo
		
		RecLock(cAliMKB, .F.)
			(cAliMKB)->VLPF := nVLPF
			(cAliMKB)->SITDES := SubStr(aComboSit[Val((cAliMKB)->SIT)], 3, 15)
		(cAliMKB)->( MsUnlock() )
		
		(cAliMKB)->( dbSkip() )
	EndDo
	
	//Browse 2 - Documentos vinculados a fatura.
	
	cQuery := ""
	cQuery := " SELECT '' AS OK, GWJ.GWJ_FILIAL AS FILIAL, GWJ.GWJ_NRPF AS NRPF, GWJ.GWJ_CDTRP AS CDTRP, "
	cQuery += " GU3.GU3_NMEMIT AS NMTRP, '' AS VLPF, "
	cQuery += " GWJ.GWJ_SIT AS SIT, '' AS SITDES, GWJ.GWJ_DTIMPL AS DTIMPL, GWJ.GWJ_HRIMPL AS HRIMPL, GWJ.GWJ_USUIMP AS USUIMP, "
	cQuery += " GWJ.GWJ_DTENV AS DTENV, GWJ.GWJ_HRENV AS HRENV "
	cQuery += " FROM "+RetSQLName("GWJ")+" GWJ "
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3"
	cQuery += " ON GU3.GU3_FILIAL = '" + xFilial("GU3") + "'" 
	cQuery += " AND GU3.GU3_CDEMIT = GWJ.GWJ_CDTRP "
	cQuery += " WHERE GWJ.D_E_L_E_T_ = ' ' AND "
	cQuery += " GWJ.GWJ_FILFAT = '"+ GW6->GW6_FILIAL +"' AND "
	cQuery += " GWJ.GWJ_EMIFAT = '"+ GW6->GW6_EMIFAT +"' AND "
	cQuery += " GWJ.GWJ_SERFAT = '"+ GW6->GW6_SERFAT +"' AND "
	cQuery += " GWJ.GWJ_NRFAT  = '"+ GW6->GW6_NRFAT  +"' AND "
	cQuery += " GWJ.GWJ_DTEMFA = '"+ DToS(GW6->GW6_DTEMIS) +"' AND "
	cQuery += " GWJ.GWJ_FILIAL = '"+ cFilGW6 +"'"
	If (SuperGetMV('MV_VLCNPJ',,'1')) == "2" 
		cQuery += " AND GWJ.GWJ_CDTRP IN (SELECT GU3_CDEMIT FROM "+RetSQLName("GU3")+" WHERE GU3_FILIAL = '" + xFilial("GU3") + "' AND SUBSTRING(GU3_IDFED,1,8) = SUBSTRING('"+cGU3IDFED+"',1,8))"		
	Else 	
		cQuery += " AND GWJ.GWJ_CDTRP = '"+cTrpGW6+"'"
	EndIf
	cQuery += " AND (GWJ.GWJ_SIT = '2' OR GWJ.GWJ_SIT = '3') "
	cQuery += " ORDER BY GWJ.GWJ_FILIAL, GWJ.GWJ_CDTRP "
	
	cQuery := ChangeQuery(cQuery)
	GFEToTrb(cQuery, aMKB2, cAliMKB2)
	//dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliMKB2, .T.) 
	
	dbSelectArea(cAliMKB2)
	(cAliMKB2)->( dbGoTop() )
	While !(cAliMKB2)->( EOF() )
		nVLPF := 0
		dbSelectArea("GWF")
		GWF->( dbSetOrder(3) )
		GWF->( dbSeek((cAliMKB2)->FILIAL + (cAliMKB2)->NRPF) )
		While !GWF->( Eof() ) .And. GWF->GWF_FILPRE == (cAliMKB2)->FILIAL .And. GWF->GWF_NRPREF == (cAliMKB2)->NRPF        
		                                           
			nVLPF += VLTOTFRET()
			
			dbSelectArea("GWF")
			GWF->( dbSkip() )
		EndDo
		
		RecLock(cAliMKB2, .F.)
			(cAliMKB2)->VLPF := nVLPF
			(cAliMKB2)->SITDES := SubStr(aComboSit[Val((cAliMKB2)->SIT)], 3, 15)
		(cAliMKB2)->( MsUnlock() )
		
		(cAliMKB2)->( dbSkip() )
	EndDo
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbGoTop() )
	oMark:oBrowse:Refresh()
    
	dbSelectArea(cAliMKB2)
	(cAliMKB2)->( dbGoTop() )
	oListDoc:Refresh()
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA070BOK
Salva o número do Fatura de Frete no  Documentos de Frete da Fatura escolhido

@sample
GFEA070BOK()

@author Felipe Rafael Mendes
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
		 
Function GFEA070BOK()
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(1) )
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( Eof() )
		
		If IsMark('OK', cMarca)
			
			dbSelectArea("GWJ")
			GWJ->( dbSetOrder(1) )
			If GWJ->( dbSeek((cAliMKB)->FILIAL + (cAliMKB)->NRPF) )
				
				//Não permitir vincular\desvincular documentos de frete da Fatura quando a situação financeira da fatura for "Pendente" ou "Atualizada"
				If GW6->GW6_SITFIN = "2" .Or. GW6->GW6_SITFIN = "4" 
					Help(,, 'Help',, STR0025, 1, 0 ) //"Não é permitido vincular documentos de frete da Fatura quando a situação financeira da fatura for 'Pendente' ou 'Atualizada'"
					Return .F.
				EndIf
									
				RecLock("GWJ", .F.)
					GWJ->GWJ_FILFAT := GW6->GW6_FILIAL
					GWJ->GWJ_EMIFAT := GW6->GW6_EMIFAT
					GWJ->GWJ_SERFAT := GW6->GW6_SERFAT
					GWJ->GWJ_NRFAT  := GW6->GW6_NRFAT
					GWJ->GWJ_DTEMFA := GW6->GW6_DTEMIS
				GWJ->( MsUnlock() )
				
				//Ao vincular ou desvincular pre-fatura em uma fatura nas situações "Bloqueada","Aprovada Sistema" ou "Aprovada Usuário" alterar a situação da fatura para "Recebida".
				If GW6->GW6_SITAPR != "1"
					
					RecLock("GW6", .F.)
						GW6->GW6_SITAPR := "1"
					GW6->( MsUnLock() )
					
				EndIf
				// Retorna a PF para situação Enviada, se for o caso
				GFEA071CON("2")	
				
			EndIf
			
		EndIf
		
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSkip() )
	EndDo
		
	Processa({|lEnd| GFE070MKB(GW6->GW6_FILIAL, GW6->GW6_EMIFAT)}, STR0022, STR0023) //"Processando informações" //"Aguarde"
	
	(cAliMKB2)->( dbGoTop() )
		
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE70DELD
LIMPA o número do Romaneio 

@sample
GFE70DELD()

@author Felipe Rafael Mendes
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFE70DELD()

	dbSelectArea("GWJ")
	GWJ->( dbSetOrder(1) )
	If GWJ->( dbSeek((cAliMKB2)->FILIAL + (cAliMKB2)->NRPF) )
		   
		//Não permitir vincular\desvincular documentos de frete da Fatura quando a situação financeira da fatura for "Pendente" ou "Atualizada"
		If GW6->GW6_SITFIN = "2" .Or. GW6->GW6_SITFIN = "4" 
			Help( ,, 'Help',, STR0025, 1, 0 ) //"Não é permitido vincular documentos de frete da Fatura quando a situação financeira da fatura for 'Pendente' ou 'Atualizada'"
			Return .F.
		EndIf
		// Retorna a PF para situação Enviada, se for o caso
		GFEA071CON("2")	
	    	
		RecLock("GWJ", .F.)
			GWJ->GWJ_FILFAT := ""
			GWJ->GWJ_EMIFAT := ""
			GWJ->GWJ_SERFAT := ""
			GWJ->GWJ_NRFAT  := ""
			GWJ->GWJ_DTEMFA := CtoD(" / / ") 
		GWJ->( MsUnlock() )
		
		//Ao vincular ou desvincular pre-fatura em uma fatura nas situações "Bloqueada","Aprovada Sistema" ou "Aprovada Usuário" alterar a situação da fatura para "Recebida".
		If GW6->GW6_SITAPR != "1"
			RecLock("GW6", .F.)
				GW6->GW6_SITAPR := "1"
			GW6->( MsUnlock() )
		EndIf
		
	EndIf
	
	Processa({|lEnd| GFE070MKB(GW6->GW6_FILIAL, GW6->GW6_EMIFAT)}, STR0022, STR0023) //"Processando informações"###"Aguarde"
	
	(cAliMKB2)->( dbGoTop() )
	
Return .T.

//--------------------------------------------------

Function GFE070FL()

	If Pergunte("GFEA070B", .T.)
	
		dbSelectArea(cAliMKB)
	
		Set Filter To (cAliMKB)->NRPF   >= MV_PAR01 .And. (cAliMKB)->NRPF   <= MV_PAR02 .And. ;
					  (cAliMKB)->DTIMPL >= MV_PAR03 .And. (cAliMKB)->DTIMPL <= MV_PAR04
	
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbGoTop() )
		oMark:oBrowse:Refresh()				  
		
	EndIf
	
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
