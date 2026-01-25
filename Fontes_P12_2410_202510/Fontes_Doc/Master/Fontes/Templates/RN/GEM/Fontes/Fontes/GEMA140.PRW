#INCLUDE "GEMA140.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEMA140  ³ Autor ³ Cristiano Denardi     ³ Data ³ 26.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerenciador de empreendimentos		            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
TEMPLATE Function GEMA140( nCallOpcx )

Private aRotina := MenuDef()

// Define o cabecalho da tela de atualizacoes
Private cCadastro := OemToAnsi(STR0007) //"Gerenciador de Empreendimentos"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

DbSelectArea("LK3")
DbSetOrder(1) // LK3_FILIAL + LK3_CODEMP + LK3_DESCRI

If nCallOpcx <> Nil
	GEMDlgEmp("LK3",LK3->(RecNo()),nCallOpcx)
Else
	mBrowse(6,1,22,75,"LK3",,,,,,,,,,,,,) 
EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GEM140Alt ³ Autor ³ Reynaldo Miyashita    ³ Data ³27.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Alteracao do Cadastro de Empreendimentos.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEM140Alt( cAlias ,nReg ,nOpcx )
Local dHabite  := stod("")
Local lRecCalc := .F.
Local aArea    := GetArea()

	If (AxAltera(cAlias,nReg,nOpcx,,,,,,,,) == 1)
		// deve verificar os campos chaves de estrutura para serem atualizados
		dbSelectArea("LK5")
		dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
		dbSeek(xFilial("LK5")+LK3->LK3_CODEMP )
		While !Eof() .AND. LK5->LK5_FILIAL+LK5->LK5_CODEMP == xFilial("LK5")+LK3->LK3_CODEMP
		
			RecLock("LK5",.F.)
				LK5->LK5_PREVHB := LK3->LK3_PREVHB
				LK5->LK5_HABITE := LK3->LK3_HABITE
			MsUnLock()
			
			dbSelectArea("LK5")
			dbSkip()
		End

		// deve verificar os campos chaves de estrutura e unidade para serem atualizados
		dbSelectArea("LIQ")
		dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
		dbSeek(xFilial("LIQ")+LK3->LK3_CODEMP )
		While !Eof() .AND. LIQ->LIQ_FILIAL+LIQ->LIQ_CODEMP == xFilial("LIQ")+LK3->LK3_CODEMP
		    
		
			If LIQ->LIQ_STATUS == "CA" .and. (LIQ->LIQ_PREVHB <> LK3->LK3_PREVHB .or. LIQ->LIQ_HABITE <> LK3->LK3_HABITE)
				lRecCalc := .T.
			EndIf
			
			RecLock("LIQ",.F.)
				//LIQ->LIQ_SITUA  := LK3->LK3_SITUAC
				LIQ->LIQ_END    := LK3->LK3_END
				LIQ->LIQ_BAIRRO := LK3->LK3_BAIRRO
				LIQ->LIQ_CEP    := LK3->LK3_CEP
				LIQ->LIQ_CIDADE := LK3->LK3_CIDADE
				LIQ->LIQ_UF     := LK3->LK3_UF
				LIQ->LIQ_PREVHB := LK3->LK3_PREVHB
				LIQ->LIQ_HABITE := LK3->LK3_HABITE
				
				If LIQ->(FieldPos("LIQ_COD_DI"))>0 .AND. LK3->(FieldPos("LK3_COD_DI"))>0
					LIQ->LIQ_COD_DI := LK3->LK3_COD_DI  // Codigo do municipio da DIMOB
				EndIf
				
			MsUnLock()
			
			If lRecCalc 
				dbSelectArea("LIU")
				dbSetOrder(2) // LIU_FILIAL+LIU_CODEMP
				If dbSeek(xFilial("LIU")+LIQ->LIQ_COD)
					dbSelectArea("LIT")
					dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
					If dbSeek(xFilial("LIU")+LIU->LIU_NCONTR)
						
						dHabite := iIf( Empty(LIQ->LIQ_HABITE) ,LIQ->LIQ_PREVHB ,LIQ->LIQ_HABITE )
						t_GMPRCContr( dHabite ,,LIT->(Recno()) )
						
					EndIf
				EndIf
			EndIf
			
			dbSelectArea("LIQ")
			dbSkip()
		End
	EndIf
	
	RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GEMA140Dlg³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao     ³±±
±±³          ³ de Empreendimentos.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEM140Dlg( cAlias ,nReg ,nOpcx )

Local cCadastro := STR0008 //"Cadastro de Empreendimento"
Local oMenu
Local oTree
Local oDlg
Local bChange   := {|| NIL }
Local bContext  := {|| NIL }
Local aMenu     := {}
Local aStatus    :={}
Local nRecLIQ    := 0
Local cArquivo  := ""
Local l140Inclui := .F.
Local l140Visual := .F.
Local l140Altera := .F.
Local l140Exclui := .F.
Local lContinua  := .T.
Local lConfirma 

	// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
	Do Case
		Case (aRotina[nOpcx][4] == 2)
			l140Visual := .T.
		Case (aRotina[nOpcx][4] == 3) .Or. (aRotina[nOpcx,4] == 6)
			l140Inclui	:= .T.
		Case (aRotina[nOpcx][4] == 4)
			l140Altera	:= .T.
		Case (aRotina[nOpcx][4] == 5)
			l140Exclui	:= .T.
			l140Visual	:= .T.
			lConfirma   := .F.
	EndCase

	// utiliza a funcao axInclui para incluir o Projeto
	If l140Inclui
		If AxInclui(cAlias,nReg,nOpcx,,,,,,"t_GEMEmpAtu()" ,) <>1
			lContinua := .F.
		EndIf
	EndIf
	If l140Exclui
		nRecLIQ := LIQ->(Recno())
		dbSelectArea("LIQ")
		dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
		MsSeek(xFilial("LIQ")+LK3->LK3_CODEMP)
		aStatus	:=	{0,0,0}
		While !Eof() .And. xFilial('LIQ')+LK3->LK3_CODEMP == LIQ_FILIAL+LIQ_CODEMP 
			Do Case
			// Reservado
			Case LIQ->LIQ_STATUS == "RE"
				aStatus[1]++
			// Contrato Assinado 
			Case LIQ->LIQ_STATUS == "CA"
				aStatus[2]++
			// Outros
			Case LIQ->LIQ_STATUS <> "LV"
				aStatus[3]++
			EndCase
			Dbskip()
		EndDo
		LIQ->(dbGoto(nRecLIQ))
		
		If aStatus[1]+aStatus[2]+aStatus[3] > 0
		 /* ####################
		   Atencao
		    Existem unidades vendidas e ou reservadas, nao sera possivel excluir o emprendimento.
			 Detalhe:
			 	Reservadas         :
			 	Contrato assinado  :
			 	Outros             :
					Ok 		   
		   #####################
		 */
			Aviso(STR0025,STR0026+CRLF+STR0027+CRLF+;
					STR0028 + STRZERO(aStatus[1],3)+CRLF+;
					STR0029+ STRZERO(aStatus[2],3)+CRLF+;
					STR0030+ STRZERO(aStatus[3],3)+CRLF,{STR0031},3) 
			lContinua	:=	.F.
		Endif
		lConfirma   := .T.
	EndIf
	
	If lContinua
		//
		// monta o menu
		//
		MENU oMenu POPUP
			MENUITEM STR0009 ACTION iIf(GEM140to141(3,@oTree,"1",cArquivo),Eval(bRefresh),.T.)) //"Incluir Estrutura"
			MENUITEM STR0010 ACTION iIf(GEM140to141(3,@oTree,"2",cArquivo),Eval(bRefresh),.T.)) //"Incluir Unidade"
			MENUITEM STR0024 ACTION iIf(GEM140to141(3,@oTree,"3",cArquivo),Eval(bRefresh),.T.)) //"Incluir Multiplas Unidades"
			MENUITEM STR0011 ACTION iIf(GEM140to141(4,@oTree,   ,cArquivo),Eval(bRefresh),.T.)) //"Alterar"
			MENUITEM STR0002 ACTION     GEM140to141(2,@oTree,   ,cArquivo)  //"Visualizar"
			MENUITEM STR0006 ACTION iIf(GEM140to141(5,@oTree,   ,cArquivo),Eval(bRefresh),.T.)) //"Excluir"
		ENDMENU
		  
		// monta a barra de menus
		aMenu := {;
		         {STR0012, {||NIL }, NIL, STR0013},; //"Informações"###"Inform."
		         {STR0014  , {||GMA140MnuControl(@oMenu,@oTree,cArquivo,l140Visual),oMenu:Activate(55,45,oDlg) },NIL,STR0015 }} //"Estrutura"###"Estrut."
		         
		GEMDlgEmp( cCadastro,@oMenu,@oTree,bChange,@lConfirma,@aMenu,@oDlg,@cArquivo,bContext)
    	
		If l140Exclui .And. lConfirma
			MADelLK3(,LK3->(recno()))
		EndIf
		
	EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMDlgEmp ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que a tela de visualizacao do empreendimento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GEMDlgEmp( cCadastro,oMenu,oTree,bChange,lConfirma,aMenu,oDlg,cArquivo,bContext)

	// Tipo Arvore (default)
	If GetNewPar("MV_GEMEMPR","1") == "1"
		AuxDlgEmp1( cCadastro,oMenu,@oTree,bChange,lConfirma,aMenu,oDlg,@cArquivo,bContext)
		
	// Tipo Browse
	Else 
		AuxDlgEmp2( cCadastro,oMenu,@oTree,bChange,lConfirma,aMenu,oDlg,@cArquivo,bContext)
    EndIf
    
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxDlgEmp1³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que a tela de visualizacao do empreendimento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxDlgEmp1( cCadastro,oMenu,oTree,bChange,lConfirma,aMenu,oDlg,cArquivo,bContext)
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10
Local nTamTree	:= If(oMainWnd:nClientWidth > 800,208,150)

Local aPanel
Local oPanelTop
Local oFont
Local oBtn
Local nCol         := 2
Local nCount       := 0
Local aEnch        := {NIL,NIL,NIL}
Local aCoordScroll := {}
Local AsvAlias     := {}
Local nOldEnch     := 1
Local aHeaderSV1   := {{},{}}
Local aColsSV1	   := {{},{}}
Local aHeaderSV2   := {{},{},{},{},{},{}}
Local aColsSV2	   := {{},{},{},{},{},{}}

PRIVATE bRefresh	:= {|| GEMTreeSTR(@oTree,Nil,.T.),Eval(oTree:bChange)}

SaveInter()

RegToMemory("LK3",.F.)

DEFINE FONT oFont NAME "Arial" SIZE 0, -10
DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight 
oDlg:lMaximized := .T.

	//
	// Monta a barra de menus 
	//
	aPanelTop := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,1245,23,.T.,.T. )
	aPanelTop:Align := CONTROL_ALIGN_TOP
	@00,00 BITMAP oBmp1 RESNAME "PMSSUPE" SIZE 1200,50 NOBORDER PIXEL Of aPanelTop
	oBmp1:Align:= CONTROL_ALIGN_TOP
	nCol := 2
	
	For nCount := 1 to Len(aMenu)
		oBtn := TButton():New( 10, nCol,aMenu[nCount][4],aPanelTop,aMenu[nCount][2],24,12, , , ,.T.)
		oBtn:cToolTip := aMenu[nCount][1]
		nCol += 24
	Next nCount

	oBtn := TButton():New( 10, nCol,STR0016,aPanelTop,{|| HelProg() },24,12, , , ,.T.) //"Help"
	oBtn:cToolTip := STR0016 //"Help"
	nCol += 24

	// Botao OK
	If lConfirma<>Nil
		// OK
		oBtn := TButton():New( 10, nCol,STR0017,oPanelTop,{|| lConfirma:=.T.,oDlg:End() },24,12, , , ,.T.) //"Confirma"
		oBtn:cToolTip := STR0017 + " < Ctrl-O >" //"Confirma"
		nCol += 24
	EndIf
    
	// Sair
	oBtn := TButton():New( 10, nCol,STR0018,oPanelTop,{|| oDlg:End() },24,12, , , ,.T.) //"Sair"
	oBtn:cToolTip := STR0018 +" < Ctrl-X >" //"Sair"
	nCol += 24
    
	//
	// 
	//
	oPanel := TPanel():New(24,nTamTree,'',oDlg, oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-nTamTree,((nBottom-nTop)/2),.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	lOneColumn := If((nRight-nLeft)/2-(nTamTree)>312,.F.,.T.)

	aPosObj	:=	{((((nBottom-nTop)/2)-40)*0.4)+5,; //40% da tela em altura + 5 (onde comeca o browse)
					0,;
					((nBottom-nTop)/2)-46,;   //Ultimo pixel (altura)
					(nRight-nLeft)/2-(nTamTree+3)} //Ultimo pixel (largura)
	
	aCoordScroll:=	{((nBottom-nTop)/2)-40, (nRight-nLeft)/2-(nTamTree)}  //Ultimos pixels para o Scroll (altura e largura)
	
	//
	// Carrega os dados do Cadastro do Empreendimento
	//
	aAdd(aSVAlias,"LK3")
	RegToMemory("LK3",.F.)
	aEnch[1]   := {NIL}
	aEnch[1][1]:= MsMGet():New("LK3",LK3->(RecNo()),2,,,,,{0,0,((nBottom-nTop)/2)-40,(nRight-nLeft)/2-nTamTree},,3,,,,oPanel,,,lOneColumn)
	aEnch[1][1]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//
	// Carrega os dados do Cadastro das Unidades
	//
	aAdd(aSVAlias,"LIQ")
	RegToMemory("LIQ",.F.)
	aEnch[2]	:= {Nil,NIL}
	aEnch[2][1] := TScrollBox():New( oPanel, 0,0,((nBottom-nTop))-40,(nRight-nLeft)-nTamTree )
	aEnch[2][1]:Align := CONTROL_ALIGN_ALLCLIENT
	aEnch[2][1]:Hide()
	aEnch[2][2] := MsMGet():New("LIQ",LIQ->(RecNo()),2,,,,,{0,0,((((nBottom-nTop)/2)-40)*0.4),(nRight-nLeft)/2-(nTamTree+3)},,3,,,,aEnch[2][1],,)
	aEnch[2][2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	//
	// Carrega os dados do Cadastro da Estrutura
	//
	aAdd(aSVAlias,"LK5")
	RegToMemory("LK5",.F.)
	aEnch[3]   := {Nil,Nil}
	aEnch[3][1]:= TScrollBox():New( oPanel, 0, 0,aCoordScroll[1],aCoordScroll[2],.T.,.T.,.T.)
	aEnch[3][1]:Align := CONTROL_ALIGN_ALLCLIENT
	aEnch[3][1]:Hide()
	aEnch[3][2]:= MsMGet():New("LK5",LK5->(RecNo()),2,,,,,{0,0,((((nBottom-nTop)/2)-40)*0.4),(nRight-nLeft)/2-(nTamTree+3)},,3,,,,aEnch[3][1],,)
	aEnch[3][2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//
	// Monta a arvore do empreendimento
	//
	oTree := dbTree():New(24, 0,(nBottom/2)+5, nTamTree-2, oDlg,,,.T.)
	oTree:Align := CONTROL_ALIGN_LEFT
	oTree:bChange := {|| GEMDlgView(@oTree,@aSVAlias,@aEnch,{0,0,((nBottom-nTop)/2)-40,(nRight-nLeft)/2-nTamTree},@nOldEnch,@oPanel,,{aColsSV1},{aHeaderSV1}),Eval(bChange)}
	oTree:SetFont(oFont)
	oTree:lShowHint:= .F. 
	
	GEMTreeSTR(@oTree,,Nil,.T.)
	
	//Posiciona no primeiro registro do tree
	oTree:TreeSeek("LK3"+StrZero(LK3->(RecNo()),12))
	oTree:BrClicked	:= bContext
    
ACTIVATE MSDIALOG oDlg 

RestInter()

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMDlgView³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que visualiza a unidade ou estrutura.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GEMDlgView(oTree,aSVAlias,aEnch,aPos,nOldEnch,oPanel,cArquivo,aColsO,aHeaderO)

Local cAlias	
Local nRecView	
Local nPosAlias	

If oTree == Nil
	cAlias   := (cArquivo)->ALIAS
	nRecView := (cArquivo)->RECNO
Else
	cAlias   := SubStr(oTree:GetCargo(),1,3)
	nRecView := Val(SubStr(oTree:GetCargo(),4,12))
EndIf
nPosAlias := aScan(aSVAlias,cAlias)

If nRecView <> 0
	If ValType(aEnch[nOldEnch])=="A"
		aEnch[nOldEnch][1]:Hide()
	Else
		aEnch[nOldEnch]:Hide()
	Endif
	dbSelectArea(cAlias)
	MsGoto(nRecView)
	RegToMemory(cAlias,.F.)
	If nPosAlias > 0
		Do Case
			// Empreendimento
			Case cAlias == "LK3"    
				aEnch[1][1]:Refresh()
				aEnch[1][1]:Show()
				nOldEnch:=1
			// Unidades
			Case cAlias == "LIQ"    
			
				M->LIQ_UNID := T_GEMLIQUNI( LIQ->LIQ_CODEMP ,LIQ->LIQ_STRPAI ,LIQ->LIQ_COD )
				
				aEnch[2][1]:Refresh()
				aEnch[2][2]:EnchRefreshAll()
				aEnch[2][1]:Show()
				nOldEnch:=2
				
			// Estrutura
			Case cAlias == "LK5"    
				aEnch[3][1]:Refresh()
				aEnch[3][2]:EnchRefreshAll()
				aEnch[3][1]:Show()
				nOldEnch:=3
		EndCase
	EndIf
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMTreeSTR³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o Tree do Empreendimento pela Estrutura      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GEMTreeSTR(oTree,aEstrutura,bCondicao,lReset)
Local lRet

CursorWait()

PmsNewProc()

lRet := Processa({||AuxTreeSTR(@oTree,aEstrutura,bCondicao,lReset)},STR0019) //"Processando..."

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxTreeSTR³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o Tree do Empreendimento por Estrutura       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxTreeSTR(oTree,aEstrutura,bCondicao,lReset)

Local aArea		:= GetArea()
Local aAreaLK5  := LK5->(GetArea())
Local lViewCod	:= .T. 
Local cChaveAnt 

DEFAULT lReset 		:= .T.                                                    

If lReset
	cChaveAnt := oTree:GetCargo()
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()
EndIf
oTree:Hide()
oTree:BeginUpdate()
oTree:TreeSeek("")
oTree:AddItem(OemToAnsi(LK3->LK3_DESCRI),"LK3"+StrZero(LK3->(RecNo()),12),GEMRetRes("LK3",LK3->(RecNo()),.T. ),GEMRetRes("LK3",LK3->(RecNo()),.T. ),,,1)

dbSelectArea("LK5")
dbSetOrder(2) // LK5_CODEMP+LK5_NIVEL
MsSeek(xFilial("LK5")+LK3->LK3_CODEMP)
While !Eof() .And. LK5->LK5_FILIAL+LK5->LK5_CODEMP+LK5->LK5_NIVEL;
					==xFilial("LK3")+LK3->LK3_CODEMP+"001"
	GEMSTRUNI(@oTree,LK5->LK5_CODEMP+LK5->LK5_STRUCT,,;
	          bCondicao,, 2,lViewCod,"LK3"+StrZero(LK3->(RecNo()),12))
	dbSkip()
End

oTree:EndUpdate()
oTree:TreeSeek(cChaveAnt)
oTree:Show()

RestArea(aAreaLK5)
RestArea(aArea)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMSTRUNI³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta a Unidade no Tree do Empreendimento.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GEMSTRUNI(oTree,cChave,aEstrutura,bCondicao,nPaiMat,nNivel,lViewCod,cSeekAdd)

Local nx		:= 0
Local aArea		:= GetArea()
Local aAreaLK5	:= LK5->(GetArea())
Local aAreaLIQ	:= LIQ->(GetArea())
Local aAuxArea  := {}
Local aDocLK5	:= {}

Local aNodes    := {}  // array utilizado na ordenacao de tarefas e EDTs
Local nNode     := 0   // contador utilizado para iteracao com aNodes

PmsIncProc(.T.,1)
oTree:TreeSeek(cSeekAdd)
oTree:AddItem(If(lViewCod,Alltrim(LK5->LK5_STRUCT)+"-","")+Alltrim(Substr(LK5->LK5_DESCRI,1,50)),"LK5"+StrZero(LK5->(RecNo()),12),GEMRetRes("LK5",LK5->(RecNo()),.T. ),GEMRetRes("LK5",LK5->(RecNo()),.T. ),,,2)
cSeekAdd := "LK5"+StrZero(LK5->(RecNo()),12)
oTree:TreeSeek(cSeekAdd)

dbSelectArea("LIQ")
dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
dbSeek(xFilial("LIQ")+cChave)
// Filial + empreendimento + estrutura
While !Eof() .And. LIQ->LIQ_FILIAL+LIQ->LIQ_CODEMP+LIQ->LIQ_STRPAI;
				   ==xFilial("LIQ")+cChave
	aAdd(aNodes, { "UNI" ;
	              ,LIQ->(Recno());
	              ,LIQ->LIQ_COD  })
	              
	dbSelectArea("LIQ")
	dbSkip()
End	

dbSelectArea("LK5")
dbSetOrder(3) // LK5_CODEMP+LK5_STRPAI
MsSeek(xFilial("LK5")+cChave)
// Filial + empreendimento + estrutura
While !Eof() .And. LK5->LK5_FILIAL+LK5->LK5_CODEMP+LK5->LK5_STRPAI ;
				   ==xFilial("LK5")+cChave
	aAdd(aNodes, {"STR",;
	              LK5->(Recno()),;
	              LK5->LK5_STRUCT})
	dbSkip()
EndDo

// ordenacao conjunta de tarefa/EDTs
aSort(aNodes, , , {|x, y| x[3] < y[3] })
			
For nNode := 1 To Len(aNodes)
	If aNodes[nNode][1] == "UNI"  // tarefa
	
		LIQ->(dbGoto(aNodes[nNode][2]))

		GEMAddUNI(@oTree,LIQ->LIQ_CODEMP+LIQ->LIQ_COD, aEstrutura,;
		          bCondicao,,nNivel,lViewCod,cSeekAdd)

	Else
		LK5->(dbGoto(aNodes[nNode][2]))
		
		GEMSTRUNI(@oTree,LK5->LK5_CODEMP+LK5->LK5_STRUCT, aEstrutura,;
		          bCondicao,,nNivel,lViewCod,cSeekAdd)
	EndIf
Next nNode
	
RestArea(aAreaLIQ)
RestArea(aAreaLK5)
RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMAddUNI³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta a Unidade no Tree do Empreendimento.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GEMAddUNI(oTree,cChave,aEstrutura,bCondicao,nPaiEdt,nNivel,lViewCod,cSeekAdd)

Local aArea		:= GetArea()
Local aAreaLIQ	:= LIQ->(GetArea())
Local aAreaLK5	:= LK5->(GetArea())

PmsIncProc(.T.,1)

oTree:TreeSeek(cSeekAdd)
oTree:AddItem(If(lViewCod,AllTrim(LIQ->LIQ_COD)+"-","")+AllTrim(Substr(LIQ->LIQ_DESC,1,50)),"LIQ"+StrZero(LIQ->(RecNo()),12),GEMRetRes("LIQ",LIQ->(RecNo()),.T. ),GEMRetRes("LIQ",LIQ->(RecNo()),.T. ),,,2)

oTree:TreeSeek("LIQ"+StrZero(LIQ->(RecNo()),12))

RestArea(aAreaLIQ)
RestArea(aAreaLK5)
RestArea(aArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMRetRes³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que Define as imagens a serem mostradas no Tree        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GEMRetRes(cAlias,nRecNo,lString)
Local oRet
Local cBmpName := ""
Local nRecAtu	:= 0

DEFAULT lString := .F.

dbSelectArea(cAlias)
nRecAtu	:=	Recno()
dbGoto(nRecNo)

// corrige o erro quando
// a linha do projeto esta
// selecionada e foi selecionada
// a impressao
//
// correcao temporaria, necessario
// descobrir a origem do problema
If AllTrim(cAlias)==""
	Return
EndIf

If cAlias == "LK5"
	If lString 
		oRet := "BPMSEDT4"
	Else
		oRet := LoadBitmap( GetResources(), "BPMSEDT4" )
	EndIf
ElseIf cAlias == "LIQ"

	Do Case
		// Livre - "verde"
		Case LIQ->LIQ_STATUS = "LV"
			cBmpName := "PMSTASK4"
		// Reservado - "amarelo"
		Case LIQ->LIQ_STATUS = "RE"
			cBmpName := "PMSTASK2"
		// Contrato Assinado - "Vermelho"
		Case LIQ->LIQ_STATUS = "CA"
			cBmpName := "PMSTASK1"
		// Outros - "Cinza"
		Otherwise
			cBmpName := "PMSTASK3"
	EndCase
	
	If lString 
		oRet := cBmpName 
	Else
		oRet := LoadBitmap( GetResources(), cBmpName )
	EndIf
	
ElseIf cAlias == "LK3"
	If lString 
		oRet := "BMPTABLE"
	Else
		oRet := LoadBitmap( GetResources(), "BMPTABLE" )
	EndIf
EndIf

dbGoto(nRecAtu)

Return oRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GEM140to14³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta a EDT/Tarefa no Tree do Projeto.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GEM140to141( nOPC ,oTree ,cStruct ,cArquivo )

Local aArea		:= GetArea()
Local cSTRAtu
Local nRecLK5
Local aGetCpos
Local cAlias	
Local nRecAlias	
Local lRefresh := .F.
Local aMask    := {}
Local nPosMask := 0
Local cCodigo  := ""
Local lWizard := .F.
Local nX		:= 1
Local cZeros	:= ""

If oTree!= Nil
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
Else 
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
	If nOpc == 3
		If cAlias == "LIQ"
			Aviso(STR0020,STR0021,{"Ok"},2) //"Opcao invalida."###"Novos niveis e tarefas so poderao ser adicionados a uma EDT"
			Return
		EndIf
	EndIf
Endif

dbSelectArea(cAlias)
dbGoto(nRecAlias)
Do Case
	// Incluir
	Case nOpc == 3
		//
		// estrutura
		//
		If cStruct == "1"
			cSTRAtu := LK3->LK3_CODEMP
			cNivelLK5 := If(cAlias=="LK5",LK5->LK5_NIVEL,"000")
			If cNivelLK5 <> "000"
				cSTRAtu		:= LK5->LK5_STRUCT
			EndIf
			
			cNivelLK5 := StrZero(val(cNivelLK5) + 1, TamSX3("LK5_NIVEL")[1])
			
			aMask := T_GEMmascCnf( LK3->LK3_MASCAR )
			nPosMask := aScan( aMask[2] ,{|x| x[1] == Val(LK5->LK5_NIVEL)+1 })
			If nPosMask >0 
				cCodigo := Space(aMask[2][nPosMask][2])
	            cZeros  := StrZero(0,Len(cCodigo)) 
	
				aGetCpos := {	{"LK5_CODEMP" ,LK3->LK3_CODEMP ,.F.},;
								{"LK5_NIVEL"  ,cNivelLK5       ,.F.},;
								{"LK5_STRPAI" ,cSTRAtu         ,.F.},;
								{"LK5_PREVHB" ,LK3->LK3_PREVHB ,.F.},;
								{"LK5_HABITE" ,LK3->LK3_HABITE ,.F.}}
                    
               	aAdd(aGetCpos,{"LK5_STRUCT",Alltrim(GEMNewUni( LK3->LK3_CODEMP ,LK5->LK5_STRUCT ,LK5->LK5_NIVEL ))+cZeros,.F.} )    

				aAdd(aGetCpos,{"LK5_ESTRUT",,.F.} )

				lRefresh := t_GEMA142( "LK5",,3,aGetCpos)
				
				If nRecLK5 <> Nil .And. cArquivo == Nil
					GEMTreeSTR(@oTree)
				EndIf
			
			Else
				msgAlert(STR0022) //"Não é possivel, acrescentar nova estrutura abaixo do nivel atual."
				lRefresh := .F.
			EndIf
			
		//
		// Unidades (cStruct == "2")
		// .And.
		// Multiplas Unidades -> WIZARD (cStruct == "3")
		//
		Else
			cSTRAtu := LK3->LK3_CODEMP
			cNivelLK5 := If(cAlias=="LK5",LK5->LK5_NIVEL,"000")
			If cNivelLK5 <> "000"
				cSTRAtu		:= LK5->LK5_STRUCT
			EndIf
			
			aMask := T_GEMmascCnf( LK3->LK3_MASCAR )
			nPosMask := aScan( aMask[2] ,{|x| x[1] == Val(LK5->LK5_NIVEL)+1 })
			If nPosMask >0 
				cCodigo := Space(aMask[2][nPosMask][2])
			
				aGetCpos := {}
				aAdd(aGetCpos  ,{"LIQ_Unid",cCodigo ,.F.})
				
				aAdd(aGetCpos  ,{"LIQ_COD",GEMNewUni( LK3->LK3_CODEMP ,cStrAtu ,cNivelLK5 ) ,.F.})
	
				// Empreendimento
				aAdd(aGetCpos  ,{"LIQ_CODEMP" ,LK3->LK3_CODEMP ,.T.}) // Codigo do Empreendimento
	//			aAdd(aGetCpos  ,{"LIQ_QTDEDI" ,0               ,.T.}) // Edificios    
				aAdd(aGetCpos  ,{"LIQ_SITUA"  ,LK3->LK3_SITUAC ,.T.}) // Situacao 
				aAdd(aGetCpos  ,{"LIQ_END"    ,LK3->LK3_END    ,.T.}) // Endereco
				aAdd(aGetCpos  ,{"LIQ_BAIRRO" ,LK3->LK3_BAIRRO ,.T.}) // Bairro
				aAdd(aGetCpos  ,{"LIQ_CEP"    ,LK3->LK3_CEP    ,.T.}) // CEP
				aAdd(aGetCpos  ,{"LIQ_CIDADE" ,LK3->LK3_CIDADE ,.T.}) // Cidade
				aAdd(aGetCpos  ,{"LIQ_UF"     ,LK3->LK3_UF     ,.T.}) // UF
				If LIQ->(FieldPos("LIQ_COD_DI"))>0 .AND. LK3->(FieldPos("LK3_COD_DI"))>0
					aAdd(aGetCpos  ,{"LIQ_COD_DI" ,LK3->LK3_COD_DI,.T.}) // Codigo do municipio da DIMOB
				EndIf
				
				If cAlias == "LK5"
					aAdd(aGetCpos  ,{"LIQ_PREVHB" ,LK5->LK5_PREVHB ,.T.}) // Data Prevista do Habite-se
					aAdd(aGetCpos  ,{"LIQ_HABITE" ,LK5->LK5_HABITE ,.T.}) // Data do Habite-se
				Else
					aAdd(aGetCpos  ,{"LIQ_PREVHB" ,LK3->LK3_PREVHB ,.T.}) // Data Prevista do Habite-se
					aAdd(aGetCpos  ,{"LIQ_HABITE" ,LK3->LK3_HABITE ,.T.}) // Data do Habite-se
				EndIf
	
				// Estrutura
				aAdd(aGetCpos  ,{"LIQ_STRPAI" ,cSTRAtu  ,.T.}) // Codigo da Estrutura
				
				
				//////////////////////////////////
				// Verifica se eh inclusao simples
				// ou usa Wizard
				If cStruct == "2"
					lWizard := .F.
				ElseIf cStruct == "3"
					lWizard := .T.
				Endif
				
				lRefresh := t_GEMA010( "LIQ",,3,aGetCpos,lWizard )
			Else
				msgAlert(STR0023) //"Não é possivel, acrescentar unidades abaixo do nivel atual."
				lRefresh := .F.
			EndIf

		EndIf
	// Visualizar a estrutura
	Case nOpc == 2 .And. cAlias == "LK5"
		t_GEMA142( "LK5",,2,aGetCpos )
		lRefresh := .F.
		
	// visualizar a unidade
	Case nOpc == 2 .And. cAlias == "LIQ"
		t_GEMA010( "LIQ",,2,aGetCpos )
		lRefresh := .F.
		
	// alterar a estrutura
	Case nOpc == 4 .And. cAlias == "LK5"
		lRefresh := t_GEMA142( "LK5",,4,aGetCpos )
		
	// alterar a unidade
	Case nOpc == 4 .And. cAlias == "LIQ"
		lRefresh := t_GEMA010( "LIQ",,4,aGetCpos )
		
	// excluir a estrutura
	Case nOpc == 5 .And. cAlias == "LK5"
		lRefresh := t_GEMA142( "LK5",,5,aGetCpos )
		
	// excluir a unidade
	Case nOpc == 5 .And. cAlias == "LIQ"
		lRefresh := t_GEMA010( "LIQ",,5,aGetCpos )
		
EndCase

//FreeUsedCode(.T.)

RestArea(aArea)

Return( lRefresh )


Template Function GEMEmpAtu()
Local aArea    := GetArea()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o arquivo de Estrutura EDT com o nivel 001        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("LK5",.T.)
	LK5->LK5_FILIAL	:= xFilial("LK5")
	LK5->LK5_CODEMP	:= LK3->LK3_CODEMP
	LK5->LK5_DESCRI	:= LK3->LK3_DESCRI
	LK5->LK5_STRUCT := LK3->LK3_CODEMP
	LK5->LK5_PREVHB := LK3->LK3_PREVHB
	LK5->LK5_HABITE := LK3->LK3_HABITE
	LK5->LK5_NIVEL	:= "001"
	MsUnlock()
	
RestArea( aArea )

Return( .T. )

Function GEM140VLD( cValor )
Return( .T. )


Static Function GEMNewUni( cCodEmpr ,cCodStr ,cNivel )
Local aArea    := GetArea()
Local aAreaLK3 := LK3->(GetArea())
Local aMask    := {}
Local cCodigo  := ""
Local nPosMask := 0

dbSelectArea("LK3")
dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
If dbSeek(xFilial("LK3")+cCodEmpr )
	aMask := T_GEMmascCnf( LK3->LK3_MASCAR )
	
	nPosMask := aScan( aMask[2] ,{|x| x[1] == Val(cNivel) })
	
	If nPosMask > 0
	
		cCodigo := alltrim(cCodStr) + aMask[2][nPosMask][3]
		
		nPosMask := aScan( aMask[2] ,{|x| x[1] == Val(cNivel)+1 })
		
		If nPosMask > 0
			cCodigo := cCodigo + space(aMask[2][nPosMask][2])
		EndIf
			
	Else
		cCodigo := alltrim(cCodStr) +"ERR"
	EndIf
	
EndIf

restArea(aAreaLK3)
restArea(aArea)

Return( cCodigo )

//
// habilita/desabilita as opcoes do menu
//
Static Function GMA140MnuControl(oMenu,oTree,cArquivo,lVisual)
Local aArea		:= GetArea()
Local cAlias	
Local nRecView	

If oTree == Nil 
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

dbSelectArea(cAlias)
dbGoto(nRecView)

If !lVisual	
	Do Case 
		Case cAlias == "LK5" .And. LK5->LK5_NIVEL=="001" // Estrutura do empreendimento
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Enable()
			oMenu:aItems[3]:Enable()
			oMenu:aItems[4]:Disable()
			oMenu:aItems[5]:Enable()
			oMenu:aItems[6]:Disable()

		Case cAlias == "LK5" .And. LK5->LK5_NIVEL!="001" // Estrutura difente de empreendimento
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Enable()
			oMenu:aItems[3]:Enable()
			oMenu:aItems[4]:Enable()
			oMenu:aItems[5]:Enable()
			oMenu:aItems[6]:Enable()

		Case cAlias == "LIQ" // Unidades
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Enable()
			oMenu:aItems[5]:Enable()
			oMenu:aItems[6]:Enable()

		OtherWise
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Disable()
			oMenu:aItems[5]:Disable()
			oMenu:aItems[6]:Disable()
	EndCase
Else
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
	oMenu:aItems[4]:Disable()
	oMenu:aItems[5]:Enable()
	oMenu:aItems[6]:Disable()
EndIf
RestArea(aArea)
Return


//
// Exclui o Empreendimento
//
Function MaDelLK3(cEmpr,nRecLK3)

Local aArea	:= GetArea()
Local aAreaLK3	:= LK3->(GetArea())
Local aAreaLK5	:= LK5->(GetArea())
Local aAreaLIQ	:= LIQ->(GetArea())
Local lContinua	:= .T.

dbSelectArea("LK3")
If nRecLK3<>Nil
	dbGoto(nRecLK3)
	cEmpr := LK3->LK3_CODEMP
Else
	dbSelectArea("LK3")
	dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
	lContinua	:= MsSeek(xFilial("LK3")+cEmpr)
	nRecLK3		:= RecNo()
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros da ESTRUTURA e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("LK5")
	dbSetOrder(2) // LK5_CODEMP+LK5_NIVEL
	MsSeek(xFilial("LK5")+cEmpr)
	While !Eof() .And. xFilial("LK5")+cEmpr==LK5->LK5_FILIAL+LK5->LK5_CODEMP
		MaDelLK5(,,LK5->(RecNo()))
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o refistro do LK3                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("LK3")
	dbGoto(nRecLK3)
	RecLock("LK3",.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf	
	
RestArea(aAreaLIQ)
RestArea(aAreaLK5)
RestArea(aAreaLK3)
RestArea(aArea)
Return( .T. )

//
// Exclui a Estrutura e as estruturas / tarefas filhas
//
Function MaDelLK5( cEmpr ,cStruct ,nRecLK5 )
Local aArea	:= GetArea()
Local aAreaLK5	:= LK5->(GetArea())
Local lContinua	:= .T.

dbSelectArea("LK5")
If nRecLK5<>Nil
	dbGoto(nRecLK5)
	cEmpr   := LK5->LK5_CODEMP
	cStruct := LK5->LK5_STRUCT
Else
	dbSetOrder(1) // LK5_CODEMP+LK5_STRUCT
	lContinua	:= MsSeek(xFilial("LK5")+cEmpr+cStruct)
	nRecLK5		:= RecNo()
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no LK5 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("LK5")
	dbSetOrder(3) //LK5_CODEMP+LK5_STRPAI
	MsSeek(xFilial("LK5")+cEmpr+cStruct)
	While !Eof() .And. xFilial("LK5")+cEmpr+cStruct==;
		LK5->LK5_FILIAL+LK5->LK5_CODEMP+LK5->LK5_STRUCT
		MaDelLK5(,,LK5->(RecNo()))
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no LIQ e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("LIQ")
	dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
	MsSeek(xFilial("LIQ")+cEmpr+cStruct)
	While !Eof() .And. xFilial("LIQ")+cEmpr+cStruct==;
		LIQ->LIQ_FILIAL+LIQ->LIQ_CODEMP+LIQ->LIQ_STRPAI
		MaDelLIQ(,,LIQ->(RecNo()))
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o refistro do LK5                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("LK5")
	dbGoto(nRecLK5)
	cEmpr   := LK5->LK5_CODEMP
	cStruct := LK5->LK5_STRUCT
	RecLock("LK5",.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf	
	
RestArea(aAreaLK5)
RestArea(aArea)

Return( .T. )

//
// exclui a unidade
//
Function MaDelLIQ(cEmpr,cUnid,nRecLIQ)
Local aArea	    := GetArea()
Local aAreaLIQ	:= LIQ->(GetArea())
Local aAreaLK5	:= LK5->(GetArea())

Local lContinua	:= .T.

dbSelectArea("LIQ")
If nRecLIQ<>Nil
	dbGoto(nRecLIQ)
	cEmpr := LIQ->LIQ_CODEMP
	cUnid := LIQ->LIQ_COD
Else
	dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
	lContinua	:= MsSeek(xFilial("LIQ")+cEmpr+cUnid)
	nRecLIQ		:= RecNo()
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o refistro do LIQ                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FkCommit()
	dbSelectArea("LIQ")
	dbGoto(nRecLIQ)
	cEmpr := LIQ->LIQ_CODEMP
	cUnid := LIQ->LIQ_COD
	
	RecLock("LIQ",.F.,.T.)
	dbDelete()
	MsUnlock()
	
EndIf	
	
RestArea(aAreaLIQ)
RestArea(aAreaLK5)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AuxDlgEmp2³ Autor ³ Reynaldo Miyashita    ³ Data ³ 27.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que a tela de visualizacao do empreendimento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxDlgEmp2(cCadastro ,oMenu ,oTree ,bChange ,lConfirma ,aMenu ,oDlg ,cArquivo ,bContext)
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10
Local nTamTree	:= If(oMainWnd:nClientWidth > 800,208,150)

Local aPanel
Local oPanelTop
Local oFont
Local oBtn
Local nCol         := 2
Local nCount       := 0
Local aEnch        := {NIL,NIL,NIL}
Local aCoordScroll := {}
Local AsvAlias     := {}
Local nOldEnch     := 1
Local aHeaderSV1   := {{},{}}
Local aColsSV1	   := {{},{}}
Local aHeaderSV2   := {{},{},{},{},{},{}}
Local aColsSV2	   := {{},{},{},{},{},{}}
Local aAlter	   := {}
Local nX           := 0
Local nNivelMax    := 10
Local lRecno       := .T.
Local aExpand	   := {}
Local lZap         := .T.
Local cFilhos      := "LK5/LIQ"
Local oMenos	:= LoadBitmap( GetResources(), "SHORTCUTMINUS" )
Local oMais		:= LoadBitmap( GetResources(), "SHORTCUTPLUS" )
Local oAll		:= LoadBitmap( GetResources(), "PMSEXPALL" )
Local oCmp		:= LoadBitmap( GetResources(), "PMSEXPCMP" )
Local aMask     := {}
Local nNivel	:= 0

PRIVATE aCampos  := {{"LIQ_COD","LK5_STRUCT",8,,,.F.,"",},{"LIQ_DESC","LK5_DESCRI",55,,,.F.,"",150}}
PRIVATE bRefresh	:= {|| (GemAtuBrw(cArquivo,nNivelMax,lRecno,aExpand,lZap,cFilhos,nNivel),Eval(oBrowse:bChange),oBrowse:Refresh())}
PRIVATE aStru	 := {}
PRIVATE aHeader  := {}

	cArquivo := CriaTrab(,.F.)
	
	SaveInter()
	
	RegToMemory("LK3",.F.)
	
	For nx := 1 to Len(aCampos)
		dbSelectArea("SX3")
		dbSetOrder(2)
		If MsSeek(aCampos[nx ,1])
			aAdd(aHeader,{If(Empty(aCampos[nx,5]),X3TITULO(),aCampos[nx,5]),"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)-1),X3_PICTURE,If(aCampos[nx,3]!=Nil,aCampos[nx,3],X3_TAMANHO),If(aCampos[nx,4]!=Nil,aCampos[nx,4],X3_DECIMAL),aCampos[nx,7]+"('"+aCampos[nx,1]+"','"+aCampos[nx,2]+"','"+cArquivo+"')",X3_USADO,X3_TIPO,cArquivo,X3_CONTEXT})
			aAdd(aStru,{"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)),X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			If aCampos[nx,6]
				aAdd(aAlter,"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)))
			EndIf		
		EndIf
	Next nX
	aAdd(aStru,{"CTRLNIV","C",1,0})
	aAdd(aStru,{"L_I_XO","C",1,0})
	aAdd(aStru,{"ALIAS","C",3,0})
	aAdd(aStru,{"NIVTREE","N",3,0})
	aAdd(aStru,{"RECNO","N",14,0})
	aAdd(aStru,{"FLAG","L",1,0})
	aAdd(aStru,{"RECIND","C",128,0})
	
	dbCreate(cArquivo,aStru)
	dbUseArea(.T.,,cArquivo,cArquivo,.F.,.F.)
	IndRegua(cArquivo,cArquivo,"RECIND")
	
	
	aMask := T_GEMmascCnf( M->LK3_MASCAR )
	nNivel	:= 	aMask[02 ,Len(aMask[02]) ,01]

	If LK3->(FieldPos("LK3_NMAX")) > 0
		If LK3->LK3_NMAX > 0
			nNivelMax := LK3->LK3_NMAX
		Else
			nNivelMax := 1
		EndIf
	Else
		nNivelMax := 2000	
	EndIf
	
	nNivelMax := GemAtuBrw(cArquivo,nNivelMax,lRecno,aExpand,lZap,cFilhos,nNivel)
	
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight 
	oDlg:lMaximized := .T.

	//
	// Monta a barra de menus 
	//
	aPanelTop := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,1245,23,.T.,.T. )
	aPanelTop:Align := CONTROL_ALIGN_TOP
	@00,00 BITMAP oBmp1 RESNAME "PMSSUPE" SIZE 1200,50 NOBORDER PIXEL Of aPanelTop
	oBmp1:Align:= CONTROL_ALIGN_TOP
	nCol := 2
	
	For nCount := 1 to Len(aMenu)
		oBtn := TButton():New( 10, nCol,aMenu[nCount,4],aPanelTop,aMenu[nCount,2],24,12, , , ,.T.)
		oBtn:cToolTip := aMenu[nCount,1]
		nCol += 24
	Next nCount

	oBtn := TButton():New( 10, nCol,STR0016,aPanelTop,{|| HelProg() },24,12, , , ,.T.) //"Help"
	oBtn:cToolTip := STR0016 //"Help"
	nCol += 24

	// Botao OK
	If lConfirma<>Nil
		// OK
		oBtn := TButton():New( 10, nCol,STR0017,oPanelTop,{|| lConfirma:=.T.,oDlg:End() },24,12, , , ,.T.) //"Confirma"
		oBtn:cToolTip := STR0017 + " < Ctrl-O >" //"Confirma"
		nCol += 24
	EndIf
    
	// Sair
	oBtn := TButton():New( 10, nCol,STR0018,oPanelTop,{|| oDlg:End() },24,12, , , ,.T.) //"Sair"
	oBtn:cToolTip := STR0018 +" < Ctrl-X >" //"Sair"
	nCol += 24
    
	//
	// 
	//
	oPanel := TPanel():New(24,nTamTree,'',oDlg, oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-nTamTree,((nBottom-nTop)/2),.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	lOneColumn := !((nRight-nLeft)/2-(nTamTree)>312)

	aPosObj	:=	{((((nBottom-nTop)/2)-40)*0.4)+5,; //40% da tela em altura + 5 (onde comeca o browse)
					0,;
					((nBottom-nTop)/2)-46,;   //Ultimo pixel (altura)
					(nRight-nLeft)/2-(nTamTree+3)} //Ultimo pixel (largura)
	
	aCoordScroll:=	{((nBottom-nTop)/2)-40, (nRight-nLeft)/2-(nTamTree)}  //Ultimos pixels para o Scroll (altura e largura)
	
	//
	// Carrega os dados do Cadastro do Empreendimento
	//
	aAdd(aSVAlias,"LK3")
	RegToMemory("LK3" ,.F.)
	aEnch[1]   := {NIL}
	aEnch[1,1] := MsMGet():New("LK3" ,LK3->(RecNo()) ,2,,,,,{0 ,0 ,((nBottom-nTop)/2)-40 ,(nRight-nLeft)/2-nTamTree} ,,3 ,,,,oPanel ,,,lOneColumn)
	aEnch[1,1]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//
	// Carrega os dados do Cadastro das Unidades
	//
	aAdd(aSVAlias,"LIQ")
	RegToMemory("LIQ",.F.)
	aEnch[2]	:= {Nil,NIL}
	aEnch[2,1] := TScrollBox():New( oPanel, 0,0,((nBottom-nTop))-40,(nRight-nLeft)-nTamTree )
	aEnch[2,1]:Align := CONTROL_ALIGN_ALLCLIENT
	aEnch[2,1]:Hide()
	aEnch[2,2] := MsMGet():New("LIQ",LIQ->(RecNo()),2,,,,,{0,0,((((nBottom-nTop)/2)-40)*0.4),(nRight-nLeft)/2-(nTamTree+3)},,3,,,,aEnch[2,1],,)
	aEnch[2,2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	//
	// Carrega os dados do Cadastro da Estrutura
	//
	aAdd(aSVAlias,"LK5")
	RegToMemory("LK5",.F.)
	aEnch[3]   := {Nil,Nil}
	aEnch[3,1]:= TScrollBox():New( oPanel, 0, 0,aCoordScroll[1],aCoordScroll[2],.T.,.T.,.T.)
	aEnch[3,1]:Align := CONTROL_ALIGN_ALLCLIENT
	aEnch[3,1]:Hide()
	aEnch[3,2]:= MsMGet():New("LK5",LK5->(RecNo()),2,,,,,{0,0,((((nBottom-nTop)/2)-40)*0.4),(nRight-nLeft)/2-(nTamTree+3)},,3,,,,aEnch[3,1],,)
	aEnch[3,2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea(cArquivo)
	dbGotop()
	nAlias	:= Select()
																							
	oBrowse := TcBrowse():New( 23, 1,nTamTree, 70, , , , oDlg, ,,,,{|| (GEMBrwExp(cArquivo,aExpand,@nNivelMax), GemAtuBrw(cArquivo,nNivelMax,,aExpand,,cFilhos,nNivel)),oBrowse:Refresh() },,oFont,,,,, .F.,cArquivo, .T.,, .F., , ,.f. )
	oBrowse:bChange := {|| GEMDlgView(@oTree,@aSVAlias,@aEnch,{0,0,((nBottom-nTop)/2)-40,(nRight-nLeft)/2-nTamTree},@nOldEnch,@oPanel,cArquivo,{aColsSV1},{aHeaderSV1}),Eval(bChange)}
	oBrowse:AddColumn( TCColumn():New( "",{ || If((cArquivo)->CTRLNIV=="-",oMenos,If((cArquivo)->CTRLNIV=="+",oMais,If((cArquivo)->CTRLNIV=="*",oAll,If((cArquivo)->CTRLNIV=="!",oCmp,Nil) )))},,,,"RIGHT" , 6, .T., .F.,,,, .T., ))
	oBrowse:AddColumn( TCColumn():New( "",{ || GEMRetRes((cArquivo)->ALIAS,(cArquivo)->RECNO ) },,,, "LEFT", 15, .T., .F.,,,, .T., ))
	oBrowse:Align := CONTROL_ALIGN_LEFT
	For nx := 1 to Len(aCampos)
		If Substr(aCampos[nx,1],1,1)=="$"
			aAuxRet := &(Substr(aCampos[nx,1],2,Len(aCampos[nx,1])-1)+"(2)")
			oBrowse:AddColumn( TCColumn():New( aAuxRet[1], FieldWBlock( aAuxRet[2] , nAlias ),AllTrim(aAuxRet[3]),,, if(aAuxRet[5]=="N","RIGHT","LEFT"), If(aCampos[nx,8]!=Nil,aCampos[nx,,8],If(aAuxRet[4]>Len(aAuxRet[1]),(aAuxRet[4]*3),(LEN(aAuxRet[1])*3))), .F., .F.,,,, .F., ) )
		ElseIf Substr(aCampos[nx,1],1,1)=="%"
	//%123456789012%C%99%2%12345678901234567890123456789012345%123456789012345678901234567890123456789012345678901234567890
			oBrowse:AddColumn( TCColumn():New( Trim(Substr(aCampos[nx,1],2,12)), FieldWBlock( "FORM"+StrZero(nx,2,0) , nAlias ) ,Substr(aCampos[nx,1],22,35),,, if(Substr(aCampos[nx,1],15,1)=="N","RIGHT","LEFT"), If(Val(Substr(aCampos[nx,,1],17,2))>Len(AllTrim(Substr(aCampos[nx,1],2,12))),(Val(Substr(aCampos[nx,1],17,2))*3),(Len(AllTrim(Substr(aCampos[nx,1],2,12)))*3)), .F., .F.,,,, .F., ) )
		Else
			dbSelectArea("SX3")
			dbSetOrder(2)
			If MsSeek(aCampos[nx,1])
				oBrowse:AddColumn( TCColumn():New( Trim(x3titulo()), FieldWBlock( "X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)), nAlias ),AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(aCampos[nx,8]!=Nil,aCampos[nx,8],If(X3_TAMANHO>Len(X3_TITULO),(X3_TAMANHO*5),(LEN(X3_TITULO)*5))), .F., .F.,,,, .F., ) )
			EndIf
		EndIf
	Next nX
	oBrowse:AddColumn( TCColumn():New( "",{|| " " },,,, "LEFT", 5, .T., .F.,,,, .T., ))
	dbSelectArea(cArquivo)
	oBrowse:Refresh()
	
ACTIVATE MSDIALOG oDlg ON INIT (oBrowse:Refresh())

RestInter()

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAtuPlan³ Autor ³ Edson Maricate        ³ Data ³ 11-03-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao do arquivo de trabalho.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GemAtuBrw(cArquivo,nNivelMax,lRecno,aExpand,lZap,cFilhos,nIndent)
Local nNivelAtu		:= 1
Local aProcForm		:= {}
Local aArea			:= GetArea()
Local aAreaTMP
Local nX := 0
Local nY := 0

Local cCodEmpr := "1"
Local cAliasEmpr := "EMPR"

DEFAULT nNivelMax	:= 13
DEFAULT lRecNo		:= .T.
DEFAULT lZap		:= .T.
DEFAULT cFilhos		:= "LK5/LIQ"
DEFAULT nIndent		:= 3

CursorWait()

dbSelectArea(cArquivo)
aAreaTMP	:= GetArea()
dbGotop()
If lZap
	If !InTransact()
		Zap
		Pack
	Else
		While !EOF()
			RecLock(cArquivo,.F.)
			DbDelete()
			MsUnLock()
			DbSkip()             
		Enddo			
	Endif	
EndIf

RecLock(cArquivo,.T.)
(cArquivo)->XIQ_COD  := LK3->LK3_CODEMP
(cArquivo)->XIQ_DESC := LK3->LK3_DESCRI

If lRecNo
	(cArquivo)->RECNO := LK3->(RecNo())
	(cArquivo)->ALIAS := "LK3"
	(cArquivo)->NIVTREE := 0
EndIf

LK5->(dbSetOrder(2))
If LK5->(MsSeek(xFilial()+LK3->LK3_CODEMP+"001"))
	aProcForm	:= {}
	For nX := 1 to Len(aCampos)
		If aCampos[nx,1]=="LIQ_COD" .AND. (nPos := LK5->(FieldPos(aCampos[nx,2]))) > 0 
			FieldPut(FieldPos("X"+Right(aCampos[nx,1],Len(aCampos[nx,1])-1)),LK5->(FieldGet(nPos)))
		ElseIf aCampos[nx,1]=="LIQ_DESC" .AND. (nPos := LK5->(FieldPos(aCampos[nx,2]))) > 0
			FieldPut(FieldPos("X"+Right(aCampos[nx,1],Len(aCampos[nx,1])-1)),SPACE((VAL(LK5->LK5_NIVEL)-1)*nIndent)+LK5->(FieldGet(nPos)))
		EndIf
	Next nX

EndIf

If nNivelMax == 2000
	(cArquivo)->CTRLNIV	:= "*"
	nNivelMax := 3
ElseIf nNivelMax == 1000
	(cArquivo)->CTRLNIV	:= "!"
	nNivelMax := 3
Else
	(cArquivo)->CTRLNIV	:= "*"
EndIf

MsUnlock()

If aExpand != Nil                                                                                       
	If !Empty(aExpand).And. (nPos:=aScan(aExpand,{|x|x[1]==(cArquivo)->ALIAS+(cArquivo)->XIQ_COD})) >0
      aExpand[nPos,2] :=.T.
	Else
		aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XIQ_COD,.T.})	
	Endif
EndIf

dbSelectArea("LK5")
dbSetOrder(2)
MsSeek(xFilial()+LK3->LK3_CODEMP+"001")
While !Eof() .And. LK5->(LK5_FILIAL+LK5_CODEMP+LK5_NIVEL);
                   ==xFilial("LK5")+LK3->LK3_CODEMP+"001"
	GEMAddBrw(LK5->(LK5_CODEMP+LK5_STRUCT),cArquivo,@nNivelAtu,nNivelMax,lRecNo,@aExpand,cFilhos,nIndent)
	dbSelectArea("LK5")
	dbSkip()
EndDo

CursorArrow()

RestArea(aAreaTmp)
RestArea(aArea)
    
// Testa se o registro existe no arquivo temporario no caso de exclusao da ultima tarefa
If (cArquivo)->( EoF() )
	(cArquivo)->( dbGoTo( LastRec() ) )
EndIf

Return nNivelAtu

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³05/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := { {OemToAnsi(STR0001) ,"AxPesqui"    , 0, 1,,.F.},;  //'Pesquisar'
                   {OemToAnsi(STR0002) ,"t_GEM140Dlg" , 0, 2},; //"Visualizar"
			       {OemToAnsi(STR0003) ,"t_GEM140Dlg" , 0, 3},; //"Incluir"
			       {OemToAnsi(STR0004) ,"t_GEM140Alt" , 0, 4},; //"Alt.Cadastro"
			       {OemToAnsi(STR0005) ,"t_GEM140Dlg" , 0, 4},; //"Alt.Estrutura"
			       {OemToAnsi(STR0006) ,"t_GEM140Dlg" , 0, 5}} //"Excluir"
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMAddBrw ³ Autor ³ Edson Maricate        ³ Data ³ 11-03-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria o registro no arquivo de trabalho.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GEMAddBrw(cChave,cArquivo,nNivelAtu,nNivelMax,lRecNo,aExpand,cFilhos,nIndent,lEdtPos,cPai)
Local aArea	:= GetArea()
Local aAuxArea
Local aAreaLIQ	:= LIQ->(GetArea())
Local aAreaLK5	:= LK5->(GetArea())
Local aProcForm	:= {}
Local lFilho 	:= .F.
Local aRecPai	:= {}
Local nPosS	
Local nX := 0
Local nY := 0
Local lSeekFilho := .F.
Local nPos		 :=	0
Local aNodes     := {}  // array utilizado na ordenacao de tarefas e EDTs
Local nNode      := 0   // contador utilizado para iteracao com aNodes
Local aRecLK5	 := {}
Local cNivel     := ""
Local aAreaTmp   := {}
Local nTotNodes  := 0
Local lISAM      := .T.
Local nNivelLIQ := 1
Local lNivelLIQ := .T.
	
DEFAULT nIndent	:= 3
DEFAULT lEDTPos	:=	.T.
DEFAULT cPai   	:=	""

	If lEdtPos .And. (nNivelMax >= Val(LK5->LK5_NIVEL) .OR. (( nPosS:=aScan(aExpand,{|x| x[1]=="LK5"+LK5->LK5_STRPAI } )) > 0 .And.aExpand[nPosS,2] ))
	
		If Val(LK5->LK5_NIVEL) > nNivelAtu
			nNivelAtu := Val(LK5->LK5_NIVEL)
		EndIf
		
		RecLock(cArquivo,.T.)
		aRecPai := (cArquivo)->(GetArea())
		aProcForm	:= {}
		For nX := 1 to Len(aCampos)
			If aCampos[nx,1]=="LIQ_COD" .and. (nPos := LK5->(FieldPos(aCampos[nx,2]))) > 0
				FieldPut(FieldPos("X"+Substr(aCampos[nx,1],2,Len(aCampos[nx,1])-1)),LK5->(FieldGet(nPos)))
			ElseIf aCampos[nx,1]=="LIQ_DESC" .and. (nPos := LK5->(FieldPos(aCampos[nx,2]))) > 0
				FieldPut(FieldPos("X"+Substr(aCampos[nx,1],2,Len(aCampos[nx,1])-1)),SPACE((VAL(LK5->LK5_NIVEL)-1)*nIndent)+LK5->(FieldGet(nPos)))
			EndIf
		Next nX

		dbSelectArea(cArquivo)
		aRecLK5	:= LK5->(GetArea())
		(cArquivo)->CTRLNIV	:= "+"

		If lRecNo
			(cArquivo)->RECNO := LK5->(RecNo())
			(cArquivo)->ALIAS := "LK5"
			(cArquivo)->NIVTREE := nNivelAtu
		EndIf
		
		(cArquivo)->RECIND := cPai + Dec2Base63((cArquivo)->(RECNO()),4)
		MsUnlock()
		
		cPai:= rTrim((cArquivo)->RECIND)
	EndIf

LK5->(dbSetOrder(3))
LIQ->(dbSetOrder(4))
lSeekFilho := LK5->(MsSeek(xFilial()+cChave)) .Or. LIQ->(MsSeek(xFilial()+cChave))

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao for mostrar as EDTs tem que mostrar todas as tarefas, ³
//³independentemente da configurcao do aExpand.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
If aExpand == Nil .Or. Empty(aExpand) ;
   .Or. (( nPosS:=aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+(cArquivo)->XIQ_COD} )) > 0 .And. aExpand[nPosS,2] ) ;
   .Or. nNivelMax<10000

	// verifica as unidades filhas
	dbSelectArea("LIQ")
	dbSetOrder(4)
	If MsSeek(xFilial("LIQ")+cChave)
		If LIQ->(FieldPos("LIQ_NIVEL") > 0)
			cNivel := Soma1(LIQ->LIQ_NIVEL)
		EndIf
		While !Eof() .And. LIQ->(LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI) ;
		                == xFilial("LIQ")+cChave
			
			aAdd(aNodes ,{"UNI",;
				              LIQ->(Recno()),;
					          LIQ->LIQ_COD})
				          
			dbSelectArea("LIQ")
			dbSkip()
		EndDo
	EndIf
	
	// verifica as estruturas filhas
	dbSelectArea("LK5")
	dbSetOrder(3)
	If MsSeek(xFilial("LK5")+cChave)
		cNivel := Soma1(LK5->LK5_NIVEL)
		While !Eof() .And. LK5->(LK5_FILIAL+LK5_CODEMP+LK5_STRPAI);
					       ==xFilial("LK5")+cChave
			lSeekFilho	 := .T.
			If nNivelMax >= Val(LK5->LK5_NIVEL) .Or. (( nPosS:=aScan(aExpand,{|x| x[1]=="LK5"+LK5->LK5_STRPAI} ))>0 .And. aExpand[nPosS,2] )
				lFilho := .T.
	      
				// adiciona a EDT em aNodes, para ser ordenado
				aAdd(aNodes, {"STR",;
				              LK5->(Recno()),;
				              LK5->LK5_STRUCT})
				              
			EndIf
			dbSelectArea("LK5")
			dbSkip()
		EndDo
	EndIf
	
	// ordenacao conjunta de tarefas e EDTs
	aSort(aNodes, , , {|x, y| x[3] < y[3]})
	nTotNodes := Len(aNodes)
	For nNode := 1 To nTotNodes
		If aNodes[nNode,1] == "UNI"
			LIQ->(dbGoto(aNodes[nNode,2]))
			
			If LIQ->(FieldPos("LIQ_NIVEL") > 0)
				lNivelLIQ := (nNivelMax >= Val(LIQ->LIQ_NIVEL))
				nNivelLIQ := Val(LIQ->LIQ_NIVEL)
			EndIf

			If lNivelLIQ .And. (( nPosS:=aScan(aExpand,{|x| x[1]=="LK5"+LIQ->LIQ_STRPAI } )) > 0 .And.aExpand[nPosS,2] )
			
				lFilho := .T.
				
				dbSelectArea(cArquivo)
				RecLock(cArquivo,.T.)
				aProcForm	:= {}
				
				For nX := 1 to Len(aCampos)
					If aCampos[nx,1]=="LIQ_COD" .AND. (nPos := LIQ->(FieldPos(aCampos[nx,1]))) > 0 
						FieldPut(FieldPos("X"+Substr(aCampos[nx,1],2,Len(aCampos[nx,1])-1)),LIQ->(FieldGet(nPos)))
					ElseIf aCampos[nx,1]=="LIQ_DESC" .AND. (nPos := LIQ->(FieldPos(aCampos[nx,1]))) > 0 
						FieldPut(FieldPos("X"+Substr(aCampos[nx,1],2,Len(aCampos[nx,1])-1)),SPACE((nNivelLIQ-1)*nIndent)+LIQ->(FieldGet(nPos)))
					EndIf
				Next nX
						
				If lRecNo
					(cArquivo)->RECNO := LIQ->(RecNo())
					(cArquivo)->ALIAS := "LIQ"
				EndIf
				
					(cArquivo)->RECIND := cPai + Dec2Base63((cArquivo)->(RECNO()),4)
				
				MsUnlock()
				
			EndIf
			
		Else
			LK5->(dbGoto(aNodes[nNode,2]))
			GEMAddBrw(LK5->(LK5_CODEMP+LK5_STRUCT),cArquivo,@nNivelAtu,nNivelMax,lRecNo,@aExpand,cFilhos,nIndent,,cPai)
		EndIF
	Next nX
	
	If lFilho .And. !Empty(aRecPai)
		RestArea(aRecPai)
		RecLock(cArquivo,.F.)
			(cArquivo)->CTRLNIV	:= "-"
		MsUnlock()
		If aExpand != Nil
			If !Empty(aExpand).And. (nPos:=aScan(aExpand,{|x|x[1]==(cArquivo)->ALIAS+(cArquivo)->XIQ_COD})) >0
				aExpand[nPos,2] :=.T.
			Else
				aAdd(aExpand,{(cArquivo)->(ALIAS+XIQ_COD),.T.})	
			Endif
		EndIf
	EndIf
EndIf

If !lSeekFilho	.And. !Empty(aRecLK5)
	RestArea(aRecLK5)
	RecLock(cArquivo,.F.)
		(cArquivo)->CTRLNIV	:= " "
	MsUnlock()
EndIf

RestArea(aAreaLK5)
RestArea(aAreaLIQ)
RestArea(aArea)
Return

Static Function GEMBrwExp(cArquivo,aExpand,nNivelMax)
Local nPos
Local lTotal	:=	.F.

If !Empty(aExpand).And. (nPos:=aScan(aExpand,{|x|x[1]==(cArquivo)->(ALIAS+XIQ_COD)})) > 0
	If (cArquivo)->CTRLNIV == "-"
		aExpand[nPos,2] := .F.
		If nNivelMax == 1000 .OR. nNivelMax == 2000
			If (cArquivo)->NIVTREE > 1
				nNivelMax := (cArquivo)->NIVTREE-1
			Else
				nNivelMax := (cArquivo)->NIVTREE
			EndIf	
		Else
			If nNivelMax > 1
				nNivelMax--
			EndIf	
		EndIf	
	ElseIf (cArquivo)->CTRLNIV == "+"
		aExpand[nPos,2] := .T.
		If nNivelMax == 1000 .OR. nNivelMax == 2000
			nNivelMax := (cArquivo)->NIVTREE+1
		Else
			nNivelMax++
		EndIf	
	ElseIf (cArquivo)->CTRLNIV == "*"
		lTotal	:=	.T.
		nNivelMax := 1000
		aExpand := {}
		dbSelectArea(cArquivo)
		dbGotop()
		If !InTransact()
			Zap
			Pack
		Else
			While !EOF()
				RecLock(cArquivo,.F.)
				DbDelete()
				MsUnLock()
				DbSkip()             
			Enddo			
		Endif	
	ElseIf (cArquivo)->CTRLNIV == "!"
		lTotal	:=	.T.
		nNivelMax := 2000
		aExpand := {}
	EndIf
Else
	If (cArquivo)->CTRLNIV == "-"
		aAdd(aExpand,{(cArquivo)->(ALIAS+XIQ_COD),.F.})
	ElseIf (cArquivo)->CTRLNIV == "+"
		aAdd(aExpand,{(cArquivo)->(ALIAS+XIQ_COD),.T.})	
	ElseIf (cArquivo)->CTRLNIV == "*"
		lTotal	:=	.T.
		nNivelMax := 2000
		aExpand := {}		
		dbSelectArea(cArquivo)
		dbGotop()
		If !InTransact()
			Zap
			Pack
		Else
			While !EOF()
				RecLock(cArquivo,.F.)
				DbDelete()
				MsUnLock()
				DbSkip()             
			Enddo			
		Endif	
	ElseIf (cArquivo)->CTRLNIV == "!"
		lTotal	:=	.T.
		nNivelMax := 1000
		aExpand := {}
	EndIf
EndIf

Return lTotal

Static Function Dec2Base63(nNum,nTam)
Local aDigitos	:=	{" ","!","#","$","%","&","(",")","*","+","-",".","/","0","1","2","3","4","5","6","7","8","9",";",":","<","=",">","?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\","]","^","_","{","|","}"}
Local nBase	:=	Len(aDigitos)
Local cRes	:=	''
While nNum >= nBase
   nMod	:= Mod(nNum,nBase)
   nNum	:= Int(nNum/nBase)
	cRes	:=	aDigitos[nMod+1]+cRes
Enddo
cRes	:=	aDigitos[nNum+1]+cRes	
cRes	:=	PadL(cRes,nTam)

Return cRes
                              
// FUNCAO CHAMADO VIA X3_RELACAO DO CAMPO VIRTUAL LK5_STRUCT
Function Gem140Desc()
Local cNome := ""
Local aArea := GetArea()
Local aAreaLK5 := LK5->(GetArea())

If !(LK5->LK5_STRPAI==SPACE(Len(LK5->LK5_STRPAI)))
	dbSelectArea("LK5")
	dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
	dbSeek(xFilial("LK5")+LK5->LK5_CODEMP+LK5->LK5_STRPAI)
	
	If Type("LK5->LK5_DESCRI")<>"U"
		cNome := LK5->LK5_DESCRI
	Endif
Else
	cNome := LK5->LK5_DESCRI
Endif
	
RestArea(aAreaLK5)
RestArea(aArea)

Return cNome
