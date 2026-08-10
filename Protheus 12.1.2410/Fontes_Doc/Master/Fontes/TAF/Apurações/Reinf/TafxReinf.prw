#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFXREINF.CH"

#DEFINE  F_MARK 		01
#DEFINE  F_C1E_ID 		02
#DEFINE  F_C1E_FILTAF 	03
#DEFINE  F_C1E_CODFIL 	04
#DEFINE  F_C1E_NOME 	05
#DEFINE  F_C1E_CNPJ 	06
#DEFINE  F_C1E_STATUS 	07
#DEFINE  F_CANCHECK 	08
#DEFINE  F_C1E_MATRIZ 	09 

#DEFINE  E_MARK 		01
#DEFINE  E_LEGENDA 		02
#DEFINE  E_NOME		 	03
#DEFINE  E_DESC		 	04 
#DEFINE  CRLF 			Chr(13) + Chr(10)

#DEFINE BTNLINK "QPushButton { font: bold 'Verdana' } QPushButton { font-size: 11px; } QPushButton { color: #024670 } QPushButton { text-decoration: underline } QPushButton { background: transparent;} QPushButton { border: none !important;}"

Static __oTmpFil 	:= Nil 
Static __vldFils	:= Nil
Static __cLayFil	:= ""

static _TmFilTaf := NIL
static _TmId 	 := NIL
static _TmCodFil := NIL
static _TmNome   := NIL

Static __cEvtTot 		:= Nil
Static __cEvtTotContrib := Nil
Static __lRowNum 		:= Nil

Function TafxReinf(oFather)

	Local cFunction	as char
	Local lRet 		as logical
	Local nOpc      as numeric

	If NewPaREINF()
		Return .F.
	EndIf

	cFunction := ProcName()
	nOpc 	  := 2 //View

	//Protect Data / Log de acesso / Central de Obrigacoes
	If FindFunction('FwPDLogUser')
		FwPDLogUser(cFunction, nOpc)
	EndIf

	lRet := TafApReinf(oFather)

	TafDelTmpFil()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafApReinf
Rotina principal de apuração da REINF
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return Nil
/*/
//-------------------------------------------------------------------
Function TafApReinf( oFather as object ) as logical

	Local aParamRei		as array
	Local lDock			as logical
	Local cCadastro 	as character
	Local PANEL_CFG 	as array
	Local aColFils		as array
	Local aColSizes 	as array
	Local aInd			as array
	Local aColEvts		as array
	Local lRet 			as logical  
	Local oDlgPar		as object
	Local aCoord		as array
	Local dDtIni		as Date
	Local dDtFim 		as Date
	Local cPeriodo      as character
	Local lPeriodo      as logical	
	Local oMainBrw		as object
	Local oFont 		as object
	Local oFont2		as object
	Local oFont3		as object
	Local oButt1		as object
	Local oButt2		as object
	Local oButt3		as object
	Local oButt4		as object
	Local oButt5		as object
	Local oButtEnd		as object
	Local oButLeg       as object
	Local aSize     	as array
	Local aArea     	as array
	Local aObjects  	as array
	Local aPosObj 		as array
	Local aPos 	    	as array
	Local aCpoH     	as array
	Local cDescView 	as character
	Local aCombo    	as array
	Local aPerg     	as array
	Local cInd          as character
	Local aCond			as array
	Local cCond         as character 
	Local cInfo			as character
	Local aItems		as array
	Local aWindow		as array
	Local aColumn		as array
    Local nTotMarkE    	as numeric
    Local cTotMarkE    	as character
    Local nTotMarkF    	as numeric	
    Local cTotMarkF    	as character
	Local bPsq	   		as codeblock
	Local bOk			as codeblock
	Local bInit			as codeblock
	Local bVisLog		as codeblock
	Local bVisMVC		as codeblock
	Local bDelApur		as codeblock
	Local bMonitor		as codeblock
	Local bSetPeriodo	as codeblock
	Local bClose		as codeblock
	Local bTafRX098		as codeblock
	Local bTafRcp		as codeblock
	Local bLegFil       as codeblock
	Local aLin 			as array
	Local nMaxAlt		as numeric
	Local lMatriz		as logical
	Local lFechamento	as logical
	Local oDtIni		as object
	Local oDtFim		as object
	Local oPeriodo		as object	
	Local oEventos		as object
	Local oRadio		as object
	
	Local oDataPer		as object
	Local oInfo			as object
	Local oInfoObs		as object
	Local nModel		as numeric
	Local oApp			as object
	Local oBReinf		as object
	Local oSayTitle		as object
	Local nButt			as numeric
	Local nOpcAcum 		as numeric
	Local nOpcAviso		as numeric
	Local nRadio		as numeric
	Local aButtons		as array
	Local aAmbR			as array
	Local aRadio		as array
	Local aRadioBlc		as array
	Local cVerReinf 	as character
	Local cAmbReinf		as character
	Local cCNPJFil		as character
	Local lValid		as logical
	Local lInfo			as logical
	Local lReinfAtu		as logical
	Local nPosStat      as numeric
	Local oSay			as Object
	Local oBtnLink		as Object
	Local oFontHigth	as Object
	Local oFontDlgPar	as Object
	Local cMsg			as Character

	//Local aEventos	as array

	Private oPanel		as object
	Private aRotReinf	as array
	Private oTotMarkE	as object
	Private oTotMarkF	as object
	Private nSpacTot    as numeric 	
	Private lSelectFil 	as logical
	Private aEventos	as array
	
	Private aFiliais	as array
	Private oRed		as object
	Private oGreen		as object
	Private oYellow		as object
	Private oBlue		as object
	Private oBlack		as object
	Private oOrange		as object	
	Private oOk			as object
	Private oNO			as object
	Private oMemoEvt	as object
	Private oArea		as object
	Private nCountAll   as numeric
	Private cKeyEmp		as object
	Private lReinf		as logical
	Private lShowAllFil as logical
	Private lHighRes	as logical
	Private cStatPer    as character
	Private aParamX		as array
	Private oButtEvtFch as object

	Private lOpcFEvt 	as logical

	Default aEventos	:= {}
	
	aParamRei	:= Array(1)
	lValid		:= Left(GetNewPar( "MV_TAFRVLD", "N" ),1) == "S"
	aSize 		:= MsAdvSize()
	aFullSize	:= FWGetDialogSize( oMainWnd )
	lDock		:= oFather <> Nil
	PANEL_CFG 	:= { 000, 000, 0640, 1100 }
	aColFils	:= {" "," ",STR0008,STR0009,STR0010,STR0011,STR0012} //,STR0013+" eSocial"}//{" ","ID","Filial TAF","Cod Filial","Razão Social", "CNPJ/CPF","Status"}
	aColSizes 	:= {05,05,25,30,30,50,30,30}
	aInd		:= {STR0008,STR0009,STR0010,STR0011,STR0012}//,STR0013+" eSocial"} //{"ID","Filial TAF","Cod Filial","Razão Social", "CNPJ/CPF","Status"} 
	aColEvts	:= {" "," ",STR0014,STR0015} //{" "," ","Evento","Descrição"}
	lRet 		:= .F.  
	
	oDlgPar		:= Nil
	oSayTitle	:= Nil
	oArea		:= FWLayer():New()
	aCoord		:= { 000, 000, 0600, 1300 }
	dDtIni		:= FirstDay(Date())
	dDtFim 		:= LastDay(Date())
	lPeriodo    := .T.	
	oFont 		:= TFont():New("Tahoma",08,12,,.T.,,,,.T.)
	oFont2		:= TFont():New("Verdana",08,12,,.T.,,,,.T.)
	oFont3		:= TFont():New("Courier New",09,12,,.T.,,,,.T.)
	oButt1		:= Nil
	oButt2		:= Nil
	oButt3		:= Nil
	oButt4		:= Nil
	oButt5		:= Nil
	oButtEnd	:= Nil
	oRadio		:= Nil
	
	lOpcFEvt	:= .F.	

	aArea     	:= GetArea()
	aObjects  	:= {}
	aPosObj 	:= {}
	aPos 	    := {012,005,200,600}
	aCpoH     	:= {}
	cDescView 	:= ""
	aCombo    	:= {}
	aPerg     	:= {}
	cInd        := Space(60) 
	aCond		:= {STR0016,STR0017}//{"Igual à","Contém"}
	cCond       := Space(60) 
	cInfo		:= Space(60)
	aItems		:= {}
	aWindow		:= {}
	aColumn		:= {}
	aRadio		:= {}
	aRadioBlc		:= {}
	nTotMarkE   := 0	
	cTotMarkE   := STRZERO(nTotMarkE,4)
	nTotMarkF   := 1	
	cTotMarkF   := STRZERO(nTotMarkF,4)
	nOpcAviso	:= 0
	aLin 		:= {-1,05}
	nMaxAlt		:= 107
	lMatriz		:= .F.
	oDtIni		:= Nil
	oDtFim		:= Nil
	oPeriodo	:= Nil	
	nModel		:= 1
	oMainBrw	:= Nil
	oApp		:= Nil
	oBReinf		:= Nil
	nButt		:= 0
	nRadio		:= 0
	
	aButtons	:= {}
	cCNPJFil	:= ""
	aParamX		:= Array(8)

	oPanel           := Nil
	aRotReinf        := {}
	oTotMarkE        := Nil
	oTotMarkF        := Nil
	nSpacTot         := 70
	lSelectFil       := .T.
	aEventos         := {}
	aFiliais         := {}
	oRed             := LoadBitmap( GetResources( ), LegAccMode( "BR_VERMELHO" ) )
	oGreen           := LoadBitmap( GetResources( ), LegAccMode( "BR_VERDE" ) )
	oYellow          := LoadBitmap( GetResources( ), LegAccMode( "BR_AMARELO" ) )
	oBlue            := LoadBitmap( GetResources( ), LegAccMode( "BR_AZUL" ) )
	oBlack           := LoadBitmap( GetResources( ), LegAccMode( "BR_PRETO" ) )
	oOrange          := LoadBitmap( GetResources( ), LegAccMode( "BR_LARANJA" ) )
	oOk              := LoadBitmap(GetResources(),"LBOK")
	oNO              := LoadBitmap(GetResources(),"LBNO")
	oMemoEvt         := Nil
	nCountAll        := 0
	cKeyEmp          := cEmpAnt+cFilAnt
	lReinf           := .T.
	lShowAllFil      := .T.
	lFechamento      := .T.
	lHighRes         := Len( aFullSize ) > 3 .And. aFullSize[04] > 1800 .And. aFullSize[03] > 800
	nOpcAcum         := 0
	nPosStat         := 175
	__cEvtTot        := GetTotalizerEventCode("evtTot")
	__cEvtTotContrib := GetTotalizerEventCode("evtTotContrib")
	// Habilitar

	bClose		:= {|| MsgYesNo( STR0068 ) } //"Deseja sair ?"
	bPsq	   	:= {|| ProcPsq( aInd, cInd, aCond, cCond, cInfo , oListEmp) }	
	bOk			:= {|| lRet := .T.,oDlgPar:End() }
	bSetPeriodo	:= {|| SetPeriodo( cPeriodo, oEventos, oListEvt , aEventos, aFiliais, oRadio:nOption,1 ) }
	bInit		:= {|| InitProc( cPeriodo, dDtIni, dDtFim, aEventos, aFiliais, oEventos, oListEvt,1),eVal( bSetPeriodo )}	
	bVisLog		:= {|| TafViewLog( GetFIlter( "V0K->V0K_EVENTO",aEventos[oListEvt:nAt][03] ) ,aEventos[oListEvt:nAt][03], cPeriodo )}
	bVisMVC		:= {|| TafViewMVC( aEventos[oListEvt:nAt][03] , cPeriodo ) }
	bDelApur	:= {|| TafDelApur( aEventos[oListEvt:nAt][03] , cPeriodo ) }
	bMonitor	:= {|| TAFMONREI(cPeriodo) , eVal( bSetPeriodo )}
	bVisExc		:= {|| TafViewMVC( "R-9000", cPeriodo)  }
	bConfig		:= {|| TafParView( ,,"5" ) , xAtuCabec( IIf( lHighres, oSayTitle, oDlgPar ) ) }
	bSobre		:= {|| TafInfoReinf() }
	bVisAcum	:= {|| nOpcAcum := Aviso(STR0063,STR0063+":"+CRLF+__cEvtTot+"-"+STR0140+CRLF+__cEvtTotContrib+"-"+STR0141,{__cEvtTot,__cEvtTotContrib},2) ,; //  "R-9001-Totalizadores por Evento" ##"R-9011-Totalizadores por Período"
						IIf( nOpcAcum == 1, TafViewMVC( __cEvtTot, cPeriodo), IIf( nOpcAcum == 2, TafViewMVC( __cEvtTotContrib, cPeriodo), Nil ) ) }
						bLegFil     := {|| ViewLegFil( ) }
	IniVar()

	oFontHigth  := TFont():New('Arial',,-15,,.F.)
	oFontDlgPar := TFont():New('Arial',,-11,,.F.)

	cMsg := " Atenção! A partir de 01/04/2022 este monitor da EFD REINF se tornará" 
	cMsg += " obsoleto e será substituído pelo novo painel REINF. O Evento R-2055"
	cMsg += " estará disponível somente no novo Painel. Para mais informações acesse o link."

	bTafRX098 	:= {|| TAFRX098(cPeriodo, "R-2098", ValidFils( aFiliais )) } //"Reabertura do Perído R-2098"

	bTafRcp		:= {|| RelREINF(aEventos, oListEvt:nAt, cPeriodo, aFiliais)} //"Chama a função que valida qual relatório do REINF será gerado."
	
	If FLoadProf(@aParamRei) 
		cPeriodo := aParamRei[1]
		
		If Len( cperiodo ) == 6
			cPeriodo := Left(cPeriodo,2) + "-" + Right( cperiodo, 4 )	
		EndIf 
	Else 
		cPeriodo := TafPeReinf("-")	
	EndIf 

	cStatPer	:= "Aberto"
	cDescBTPEr	:= "Fechar Período"
	aAmbR		:= {"1 - Produção","2 - Pré Produção - Dados reais","3 - Pré Produção - dados fictícios"}
	cVerReinf	:= StrTran( SuperGetMv('MV_TAFVLRE',.F.,"1_03_02") , "_","." )
	cAmbReinf	:= Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
	
	// se o conteudo do parametro for vazio, inicia a variavel com '2'
	if empty(cAmbReinf); cAmbReinf := '2'; endif
	
	nAmbR		:= aScan( aAmbr,{|x| Left(x,1) == cAmbReinf })
	cAmbReinf	:= aAmbR[nAmbR]

	cSp			:= Space( aFullSize[04] / 65 )
	cCadastro 	:= STR0001 + cSp + " - " + cSp + "Versão: "+cVerReinf + cSp + " - "+ cSp + "Ambiente: "+cAmbReinf + cSp + " - "+ cSp + "Pré-Validação: "+IIf( lValid, "Ativa", "Inativa")
	lInfo 		:= .T.
	lReinfAtu	:= .t.

	DBSelectArea("C1E")
	C1E->( DBSetOrder(3) )
	If C1E->( DbSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, _TmFilTaf ) + "1" ) )
		If C1E->C1E_MATRIZ == .T.
			lMatriz := .T.
		EndIf
		cCNPJFil:= AllTrim(Posicione("SM0",1,cEmpAnt+C1E->C1E_FILTAF, "M0_CGC"))
	EndIf
	
	If FindFunction("TafParView")
//		SetKey(VK_F12, {|| TafParView( ,,"5" ) , xAtuCabec( IIf( lHighres, oSayTitle, oDlgPar ) ) })
		SetKey(VK_F12, bConfig )
	EndIf	
	
	if lMatriz
		if strtran(cVerReinf,'.','') >= '10400' 
			lReinfAtu  := TafColumnPos('V0W_CNOEST') .and. !X3Obrigat("V0B_PGTOS") 
		endif	
	endif	
	
	If lMatriz .And. Len( cCNPJFil ) >= 11 .and. lReinfAtu

		FWMsgRun(,{|| aRotReinf	:= TAFRotinas(,,,5) },, STR0003 ) // "Carregando Eventos..."		

		FWMsgRun(,{|| lReinf	:= TAFVdReinf(.T.) },, STR0003 ) // "Carregando Eventos..."		
		
		If lReinf 

			//Carrega a lista de filiais
			cFilterFil 	:= " .T."
			FWMsgRun(,{|| aFiliais 	:= LoadFil( cFilterFil ) },,STR0002 )	// "Carregando Filiais..." 	


		
			//Carrega a lista de eventos
			cFilterEvt 	:= " .T."
			FWMsgRun(,{|| aEventos 	:= TafReinfEV( cFilterEvt,,1 ) },, STR0003 ) // "Carregando Eventos..."				
			
			nFils   := Len( aFiliais )
			nEvts   := Len( aEventos )

			
			//resoluçao 1280 x 768
			aScreen   := GetScreenRes()
			aScreen[1]:= aScreen[1]-20
			aScreen[2]:= aScreen[2]-20

			//-------------------------------------------------- DIALOG ---------------------------------------------------------------
			If lDock
				oDlgPar := oFather
				aWindow := {016,080,057,025}
				lHighRes := .F.	
			Else

				If lHighRes
					oMainBrw := MSDialog():New(000,000,aFullSize[03],aFullSize[04],STR0001,,,,DS_MODALFRAME,CLR_BLACK,CLR_WHITE,,,.T.) 
					aWindow := {016,080,057,025}		
				Else
					If aFullSize[03] < 600 .Or. aFullSize[04] < 1340
						aCoord	:= { 000, 000, ( aFullSize[03] * 0.90 ), ( aFullSize[04] * 0.90 ) }
					EndIf
					oDlgPar := MSDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],cCadastro,,,,DS_MODALFRAME,CLR_BLACK,CLR_WHITE,,,.T.) 
					aWindow := {016,080,057,025}
				EndIf
			EndIf

			//#######################################################################################################################################
			//#######################################################################################################################################
			// 							Exibe uma interface maior e otimizada para altas resoluções de monitor
			//#######################################################################################################################################
			//#######################################################################################################################################
			If lHighRes
				// Simula a montagem do TafSmallApp
				@ 000, 000 MSPANEL oPanelTop OF oMainBrw SIZE 000,60 COLOR CLR_RED, CLR_RED
				oPanelTop:Align := CONTROL_ALIGN_TOP

				@ 000, 000 MSPANEL oPanelHeader OF oPanelTop SIZE 000,000 COLOR CLR_WHITE, CLR_WHITE
				oPanelHeader:Align := CONTROL_ALIGN_ALLCLIENT
				
				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_header_barra.png" SIZE 000,50 OF oPanelHeader PIXEL NO BORDER
				oImg:lStretch := .T.
				oImg:Align := CONTROL_ALIGN_ALLCLIENT	
				
				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_logo_totvs.png" SIZE 100,37 OF oPanelHeader PIXEL NO BORDER
				oImg:Align := CONTROL_ALIGN_LEFT
				
				@ 000, 000 MSPANEL oPanelMenu OF oPanelTop SIZE 000,022 COLOR CLR_BLACK, CLR_BLACK
				oPanelMenu:Align := CONTROL_ALIGN_BOTTOM

				@ 000, 000 MSPANEL oPanelButton OF oPanelMenu SIZE 000,000 
				oPanelButton:Align := CONTROL_ALIGN_ALLCLIENT
				
				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_bg_menu.png" SIZE 000,22 OF oPanelButton PIXEL NO BORDER
				oImg:lStretch := .T.
				oImg:Align := CONTROL_ALIGN_ALLCLIENT
				
				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_space.png" SIZE 3,22 OF oPanelButton PIXEL NO BORDER
				oImg:Align := CONTROL_ALIGN_LEFT

				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_menu_esq.png" SIZE 6.5,22 OF oPanelButton PIXEL NO BORDER
				oImg:Align := CONTROL_ALIGN_LEFT    

				oClose:= THButton():New(08, 930 ,'Sair',oPanelButton,{|| IIf(eval( bClose ),(oMainBrw:End()),) },15,7,,/*'Sair da tela de apuraçao'*/)
				oClose:nClrText := CLR_WHITE

				@ 000, 000 MSPANEL oPanelCenter OF oMainBrw SIZE 000,030 COLOR CLR_BLUE, CLR_WHITE
				oPanelCenter:Align := CONTROL_ALIGN_ALLCLIENT
				
				@ 000, 000 MSPANEL oPanelSpace OF oPanelCenter SIZE 12,000 //COLOR CLR_BLUE, CLR_BLUE
				oPanelSpace:Align := CONTROL_ALIGN_LEFT

				@ 000, 000 MSPANEL oPanelSpace OF oPanelCenter SIZE 12,000 //COLOR CLR_BLUE, CLR_BLUE
				oPanelSpace:Align := CONTROL_ALIGN_RIGHT

				@ 000, 000 MSPANEL oPanelTitle OF oPanelCenter SIZE 000,026 COLOR CLR_BLACK, CLR_BLACK
				oPanelTitle:Align := CONTROL_ALIGN_TOP
				
				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_title_esq.png" SIZE 10,26 OF oPanelTitle PIXEL NO BORDER
				oImg:Align := CONTROL_ALIGN_LEFT       
				
				@ 000,000 BITMAP oBgTitle2 RESOURCE "TafSmallApp_smallbg_title.png" SIZE 080,26 OF oPanelTitle PIXEL NO BORDER
				oBgTitle2:lStretch := .T.
				oBgTitle2:Align := CONTROL_ALIGN_LEFT	
				
				@ 000,000 BITMAP oBgTitle1 RESOURCE "TafSmallApp_smallbg_title.png" SIZE 000,26 OF oPanelTitle PIXEL NO BORDER
				oBgTitle1:lStretch := .T.
				oBgTitle1:Align := CONTROL_ALIGN_ALLCLIENT   			
				
				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_title_dir.png" SIZE 10,26 OF oPanelTitle PIXEL NO BORDER
				oImg:Align := CONTROL_ALIGN_RIGHT  	
				
				DEFINE FONT oFontx NAME "Arial" SIZE 0, 22 BOLD
				@ 008.5, 020 SAY oSayTitle PROMPT cCadastro  OF oPanelTitle PIXEL COLOR RGB(38, 65, 98) FONT oFontx
				
				@ 000, 000 MSPANEL oPanelSpace OF oPanelCenter SIZE 000,006
				oPanelSpace:Align := CONTROL_ALIGN_TOP

				@ 000, 000 MSPANEL oPanelBottom OF oMainBrw SIZE 000,028.5
				oPanelBottom:Align := CONTROL_ALIGN_BOTTOM
				
				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_bottom_bg.png" SIZE 000,28.5 OF oPanelBottom PIXEL NO BORDER
				oImg:lStretch := .T.
				oImg:Align := CONTROL_ALIGN_ALLCLIENT

				@ 000,000 BITMAP oImg RESOURCE "TafSmallApp_bottom_img.png" SIZE 147,28.5 OF oPanelBottom PIXEL NO BORDER
				oImg:Align := CONTROL_ALIGN_LEFT  

				@ 000, 000 MSPANEL oDlgPar OF oPanelCenter SIZE 000,300 
				oDlgPar:Align := CONTROL_ALIGN_ALLCLIENT

				//Adição da label informando a descontinuidade da rotina em Novembro de 2021 - Monitor de alta resolução
				oSay := TSay():New(000,000,,oPanelHeader,,oFontHigth,,,,.T.,, RGB( 128, 0, 0 ),1925,12,,,,,,.T.)
				oBtnLink := THButton():New( 000, 000, cMsg, oSay, {||ShellExecute("open","https://tdn.totvs.com/x/o4l-Hw","","",1)}, 740, , oFontHigth , /*[ bWhen ]*/,, )
				oBtnLink:nClrText := CLR_WHITE

				lDock := .T.
			EndIf
			//#######################################################################################################################################

			oArea:Init(oDlgPar,.F., .F. )
			oArea:AddLine("L01",nMaxAlt,.T.)

			//Adição da label informando a descontinuidade da rotina em Novembro de 2021 - Monitor com baixa resolução
			if !lHighRes
				oSay := TSay():New(000,000,,oDlgPar,,oFontDlgPar,,,,.T.,, RGB( 128, 0, 0 ),1920,10,,,,,,.T.)
				oBtnLink := THButton():New( 000, 000, cMsg, oSay, {||ShellExecute("open","https://tdn.totvs.com/x/o4l-Hw","","",1)}, /*400*/550, , oFontDlgPar , , /*[ bWhen ]*/,, )
				oBtnLink:nClrText := CLR_WHITE
			EndIF
			//nModel := Aviso("Modelo","Escolha o modelo da tela.",{"Modelo 1","Modelo 2"})

			If nModel == 1
				//-----------
				//³Colunas  ³
				//-----------
				If lSelectFil
					If lHighRes
						aColumn := {045,045,010}
					Else
						aColumn := {044,044,012}
					EndIf
					oArea:AddCollumn("L01C01",aColumn[01],.F.,"L01") //Parametros
					oArea:AddCollumn("L01C02",aColumn[02],.F.,"L01") //Empresas
					oArea:AddCollumn("L01C03",aColumn[03],.F.,"L01") //Botoes
				Else
					aColumn := {090,000,010}
					oArea:AddCollumn("L01C01",aColumn[01],.F.,"L01") //Parametros
					oArea:AddCollumn("L01C03",aColumn[03],.F.,"L01") //Botoes
				EndIf
				//-----------
				//³Paineis  ³
				//-----------
				If !lHighRes
					oArea:AddWindow("L01C01","QRBLINHA",,2,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) 
					oArea:AddWindow("L01C02","QRBLINHA",,2,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
				ENDIF

				oArea:AddWindow("L01C01","PERIODO",STR0005,aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Período"
				oDataPer	:= oArea:GetWinPanel("L01C01","PERIODO","L01")
			
				oArea:AddWindow("L01C01","EVENTOS",STR0006,aWindow[03],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)//"Eventos"
				oEventos	:= oArea:GetWinPanel("L01C01","EVENTOS","L01")

				oArea:AddWindow("L01C01","INFO",STR0007,aWindow[04],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Legenda Dos Eventos"
				oInfo	:= oArea:GetWinPanel("L01C01","INFO","L01")

				//-----------------------------------------------------------------------
				If lPeriodo 
//					@ aLin[01],002 SAY STR0018 FONT oFont COLOR CLR_BLUE Pixel Of oDataPer //"Período Mes/Ano : "
//					@ aLin[02],002 MSGET oPeriodo VAR cPeriodo PICTURE "@E 99-9999" SIZE 060,08 PIXEL OF oDataPer Valid( Eval(bSetPeriodo) )

//					@ aLin[02],125 TO aLin[02]+10,200 Pixel Of oDataPer
//					@ aLin[02]+2,130 SAY oStatPer VAR cStatPer FONT oFont COLOR CLR_BLUE Pixel Of oDataPer //"Período Mes/Ano : "

//					@ aLin[01],125 SAY "Status do Período" FONT oFont COLOR CLR_BLUE Pixel Of oDataPer //"Período Mes/Ano : "
//					@ aLin[02],125 MSGET oStatPer VAR cStatPer SIZE 060,08 PIXEL OF oDataPer 

					oSayPer  	:= TSay():New(aLin[01],002, {|| STR0018 } ,oDataPer,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)

					oPeriodo    := TGet():New(aLin[02],002, {|u| If( PCount()>0, cPeriodo:=u, cPeriodo )},oDataPer, 060, 008,"@E 99-9999", bSetPeriodo,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPeriodo,,,, ) ///*oFont*/,,,,,,,,,/*bChange*/,,,,,,,,/*lHasButton*/,,,/*cLabelText*/,,,,,,)

					oButDT 		:= tButton():New(aLin[02]-3,070,STR0022	,oDataPer,bSetPeriodo		,40,14,,/*oFont*/,,.T.,,,,/*bWhen*/) // Atualizar"
					oButDT:SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) ) 

					oPeriodo:cTooltip := STR0019//"Período de apuração."
					oPeriodo:cTooltip += CRLF+STR0020 //"Informar o Período de apuração no formato MM/AAAA."
					oPeriodo:cTooltip += CRLF+STR0021 //"Importante: Nem todos os eventos sofrem influencia direta do período."
		
					//###########################################################
					if lHighres
						oSayStat  	:= TSay():New(aLin[01],nPosStat, {|| "Status do Período" } ,oDataPer,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
						oStatPer	:= TGet():New(aLin[02],nPosStat, {|| cStatPer },oDataPer, 060, 008,, {||.T.},CLR_BLUE,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cStatPer,,,, )  ///*oFont*/,,,,,,,,,/*bChange*/,,,,,,,,/*lHasButton*/,,,/*cLabelText*/,,,,,,)
					else
						oSayStat  	:= TSay():New(aLin[01],(nPosStat * 0.7), {|| "Status do Período" } ,oDataPer,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
						oStatPer	:= TGet():New(aLin[02],(nPosStat * 0.7), {|| cStatPer },oDataPer, 060, 008,, {||.T.},CLR_BLUE,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cStatPer,,,, )  ///*oFont*/,,,,,,,,,/*bChange*/,,,,,,,,/*lHasButton*/,,,/*cLabelText*/,,,,,,)
					endif
//					oButPer 	:= tButton():New(aLin[02]-1,187,cDescBTPEr	,oDataPer,{|| Alert("Deseja realmente "+cDescBTPEr+"?" ) }		,50,11,,/*oFont*/,,.T.,,,,/*bWhen*/) // Atualizar"

				Else
					@ aLin[01],002 SAY STR0023 FONT oFont COLOR CLR_BLUE Pixel Of oDataPer //"Data Inicial:"
					@ aLin[02],002 MSGET oDtIni VAR dDtIni SIZE 060,08 PIXEL OF oDataPer 
					oDtIni:cTooltip := STR0025 //"Data inicial do período de apuração."
					oDtIni:cTooltip += CRLF+STR0027 //"Importante: Nem todos os eventos sofrem influencia das datas e ambas devem ser informadas dentro do mesmo mês."

					@ aLin[01],072 SAY STR0024 FONT oFont COLOR CLR_BLUE Pixel Of oDataPer //"Data Final:" 
					@ aLin[02],072 MSGET oDtFim VAR dDtFim SIZE 060,08 PIXEL OF oDataPer 
					oDtFim:cTooltip := STR0026 //"Data final do período de apuração. "
					oDtFim:cTooltip += CRLF+STR0027 //"Importante: Nem todos os eventos sofrem influencia das datas e ambas devem ser informadas dentro do mesmo mês."
				EndIf

				//----------------------------Lista dos Eventos--------------------------------------------
				
				//Montagem do radio button, para mudança das visões na tela de apuração. 
				nRadio := 1
				aRadio := {'Movimentações', 'Apurações', 'Transmissões'}

				oRadio := TRadMenu():New(0,0,aRadio,,oEventos,,,,,,,,180,12,,,,.T.,.T.)
				oRadio:Align := CONTROL_ALIGN_TOP
					
				oRadio:bSetGet 	:= {|u|Iif (PCount()==0,nRadio,nRadio:=u)}		
				oRadio:bChange	:= {|| AltVisao(oInfo, oRadio:nOption, cPeriodo, oEventos, oListEvt, aEventos, aFiliais), Eval(bSetPeriodo)}
				//------------------------------------------------------------------------

				oListEvt := TWBrowse():New(0,0,100,100,,aColEvts,,oEventos)
				oListEvt:Align := CONTROL_ALIGN_ALLCLIENT
				oListEvt:SetArray( aEventos )
				oListEvt:bLine := {|| {IIF(aEventos[oListEvt:nAt][01],oOk,oNo),;
										aEventos[oListEvt:nAt][02],;
										aEventos[oListEvt:nAt][03],;
										aEventos[oListEvt:nAt][04]}}
				oListEvt:SetFocus()
				oListEvt:BlDblClick 	:= {|| IIf( aEventos[oListEvt:nAt,2] <> oBlack .And. aEventos[oListEvt:nAt,2] <> oBlue ,aEventos[oListEvt:nAt,1] := !aEventos[oListEvt:nAt,1],nil),;
												oListEvt:DrawSelect(),;
												BrwRefresh( oListEvt, Len(TafReinfEV( cFilterEvt,,1 )), @oTotMarkE, .F. )}
				oListEvt:nAt   := 1
				
				cDescTotE 			:= STR0028 +StrZero(Len(TafReinfEV( cFilterEvt,,1 )),4)+' | '+ STR0029+ cTotMarkE //"Total de Registros: "##"Total Selecionados: "
				@ 000, 000 Say oTotMarkE Prompt cDescTotE FONT oFont COLOR CLR_BLUE Size  60, 08 Of oEventos Pixel
				oTotMarkE:Align := CONTROL_ALIGN_BOTTOM

				DrawLegend(oInfo, oRadio:nOption)
				BrwRefresh( oListEvt, Len(TafReinfEV( cFilterEvt,,1 )), @oTotMarkE )

				If lSelectFil
					oArea:AddWindow("L01C02","PESQFIL",STR0030 ,aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Pesquisa de Filiais"
					oPesqFil	:= oArea:GetWinPanel("L01C02","PESQFIL","L01")
				
					oArea:AddWindow("L01C02","FILIAIS",STR0031 ,aWindow[03],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Filiais"
					oFiliais	:= oArea:GetWinPanel("L01C02","FILIAIS","L01")

					oArea:AddWindow("L01C02","DET",STR0083/*STR0032*/,aWindow[04],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) // "Conteúdo Online"
					oDet	:= oArea:GetWinPanel("L01C02","DET","L01")

//					oBReinf := TButton():New(002,000,STR0079,oDet,{||OpenReinf()}, 70,10,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Documentação REINF"
//					oBReinf:SetCSS(BTNLINK)

					//-------------------------------------Filiais-----------------------------------
				if lHighres
						@ aLin[01],002 SAY STR0033 FONT oFont COLOR CLR_BLUE Pixel Of oPesqFil//"Pesquisa por:"
						@ aLin[02],002 COMBOBOX oInd VAR cInd ITEMS aInd SIZE 055,08 PIXEL OF oPesqFil

						@ aLin[01],067 SAY STR0034 FONT oFont COLOR CLR_BLUE Pixel Of oPesqFil//"Condição:"
						@ aLin[02],067 COMBOBOX oCond VAR cCond ITEMS aCond SIZE 045,08 PIXEL OF oPesqFil

						@ aLin[01],122 SAY STR0035 FONT oFont COLOR CLR_BLUE Pixel Of oPesqFil//"Informação:"
						@ aLin[02],122 MSGET oInfoObs VAR cInfo SIZE 090,08 PIXEL OF oPesqFil

						oButPsq := tButton():New(aLin[02]-3,215,STR0036		,oPesqFil,bPsq	,35,14,,/*oFont*/,,.T.,,,,/*bWhen*/) //"&Pesquisar"
						oButPsq:SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) )

						oButLeg := tButton():New(aLin[02]-3,253, STR0127 ,oPesqFil,bLegFil	,50, 14,,/*oFont*/,,.T.,,,,/*bWhen*/) //"Legenda Filiais"
						oButLeg:SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) )
					else
						@ aLin[01],002 SAY STR0033 FONT oFont COLOR CLR_BLUE Pixel Of oPesqFil//"Pesquisa por:"
						@ aLin[02],002 COMBOBOX oInd VAR cInd ITEMS aInd SIZE 045,08 PIXEL OF oPesqFil

						@ aLin[01],048 SAY STR0034 FONT oFont COLOR CLR_BLUE Pixel Of oPesqFil//"Condição:"
						@ aLin[02],048 COMBOBOX oCond VAR cCond ITEMS aCond SIZE 035,08 PIXEL OF oPesqFil

						@ aLin[01],085 SAY STR0035 FONT oFont COLOR CLR_BLUE Pixel Of oPesqFil//"Informação:"
						@ aLin[02],085 MSGET oInfoObs VAR cInfo SIZE 060,08 PIXEL OF oPesqFil

						oButPsq := tButton():New(aLin[02]-3,145,STR0036		,oPesqFil,bPsq	,35,14,,/*oFont*/,,.T.,,,,/*bWhen*/) //"&Pesquisar"
						oButPsq:SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) )

						oButLeg := tButton():New(aLin[02]-3,183, STR0127 ,oPesqFil,bLegFil	,50, 14,,/*oFont*/,,.T.,,,,/*bWhen*/) //"Legenda Filiais"
						oButLeg:SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) )
				endif
					//-----------------------------------Lista das filiais--------------------------
					oListEmp := TWBrowse():New(0,0,100,100,,aColFils,aColSizes,oFiliais)
					oListEmp:Align := CONTROL_ALIGN_ALLCLIENT
					oListEmp:SetArray( aFiliais )

					oListEmp:bLine := {|| {	IIF( aFiliais[oListEmp:nAt][F_MARK]	,oOk,oNo),;
											IIF( aFiliais[oListEmp:nAt][F_CANCHECK]	,oGreen,oRed) ,;
												aFiliais[oListEmp:nAt][F_C1E_ID]		,;
												aFiliais[oListEmp:nAt][F_C1E_FILTAF]	,;
												aFiliais[oListEmp:nAt][F_C1E_CODFIL]	,;
												aFiliais[oListEmp:nAt][F_C1E_NOME]		,;
												aFiliais[oListEmp:nAt][F_C1E_CNPJ]		}}
												//aFiliais[oListEmp:nAt][F_C1E_STATUS]}}

					oListEmp:SetFocus()

					oListEmp:BlDblClick := {|| 	iif( CtrChkFl(oListEmp) .And. !empty(aFiliais[oListEmp:nAt,2]) .And. aFiliais[oListEmp:nAt][F_CANCHECK] ,;
						( aFiliais[oListEmp:nAt,1] := !aFiliais[oListEmp:nAt,1] ,;
						 oListEmp:DrawSelect() ,__vldFils := nil,;
						  AtuBrwFil( oListEmp, nFils, @oTotMarkF ) ,;
						 Eval(bSetPeriodo) ) , .F. )}					

					oListEmp:BHEADERCLICK := { |oBrw, ncol| ChkFils(oBrw, ncol, bSetPeriodo),;
								 AtuBrwFil( oListEmp, nFils, @oTotMarkF )  }

					cDescTotF 			:= STR0028 +StrZero(nFils,4)+' | '+STR0029 + cTotMarkF  //"Total de Registros: "##"Total Selecionados: "

					@ 000, 000 Say oTotMarkF Prompt cDescTotF FONT oFont COLOR CLR_BLUE Size  60, 08 Of oFiliais Pixel
					oTotMarkF:Align := CONTROL_ALIGN_BOTTOM

				DrawObs( oDet, lHighRes )

				AtuBrwFil( oListEmp, nFils, @oTotMarkF )
				EndIf

			EndIf
			//--------------------------------------Funções--------------------------------------------------
			oArea:AddWindow("L01C03","L01C02P01",STR0037 ,nMaxAlt,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/) //"Funções"
			oAreaBut := oArea:GetWinPanel("L01C03","L01C02P01","L01")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Painel 03-Botoes            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aButtons,{ STR0038				, bInit 				,STR0045 +CRLF +STR0046 } )	//"&Processar"	###"Processa as apurações dos eventos marcados no Grid, "+CRLF+"gerando os movimentos para transmissão ao governo."
			if lHighRes
				AADD(aButtons,{ STR0063 + STR0039	, bVisLog 				,STR0047 +CRLF +STR0048 } )	//"Logs"		###"Visualiza os logs das apurações do evento posicionado no Grid "+CRLF+"e seus respectivos detalhes."
				AADD(aButtons,{ STR0063 + STR0040	, bVisMVC 				,STR0049 +CRLF +STR0048 } )	//"Apurações"	###"Visualiza o Browse das apurações do evento posicionado no Grid "+CRLF+"e seus respectivos detalhes."
			else
				AADD(aButtons,{ STR0122, bVisLog ,STR0047 +CRLF +STR0048 } ) //"Vis.Log" ###"Visualiza os logs das apurações do evento posicionado no Grid "+CRLF+"e seus respectivos detalhes."
				AADD(aButtons,{ STR0123, bVisMVC ,STR0049 +CRLF +STR0048 } ) //"Vis.Apuração" ###"Visualiza o Browse das apurações do evento posicionado no Grid "+CRLF+"e seus respectivos detalhes.
			endif

			If FindFunction("TAFA501")
				if lHighRes
					AADD(aButtons,{ STR0084 , bVisAcum ,STR0086 } )	//"Visualizar Totalizadores" ## "Visualiza os totalizadores dos eventos autorizados no período."
				else
					AADD(aButtons,{ STR0124, bVisAcum ,STR0086 } ) //"Vis.Totalizador" ## "Visualiza os totalizadores dos eventos autorizados no período."
				endif
			EndIf

			If FindFunction("TAFA490")
				if lHighRes
					AADD(aButtons,{ STR0085 , bVisExc ,STR0087 } ) //"Visualiza as exclusões geradas/transmitidas no período."
				else
					AADD(aButtons,{ STR0125 , bVisExc ,STR0087 } ) //"Vis.Exclusão" ## "Visualiza as exclusões geradas/transmitidas no período."
				endif
			EndIf

			If FindFunction("TAFMONREI") 
				AADD(aButtons,{ STR0041			, bMonitor ,STR0041 				} )	//"Monitor"
			EndIf

			If FindFunction("TafParView")
				AADD(aButtons,{ STR0090			, bConfig ,STR0092 				} )	//"Configurações"##"Edita as configurações de ambiente da EFD Reinf."		
			EndIf

			If lInfo
				AADD(aButtons,{ STR0091			, bSobre , STR0093 				} )	//"Sobre"	##"Informações da versão das rotinas."	
			EndIf
			
			If FindFunction("TAFAPR2098")
				if lHighRes
					AADD(aButtons, {STR0111, bTafRX098, STR0112 }) //"Reabertura"
				else
					AADD(aButtons, {STR0126, bTafRX098, STR0112 }) //"Reabre.R2098"
				endif
			endif

			If FindFunction("TAFARCP")
				AADD(aButtons,{ STR0108			, bTafRcp , STR0107				} )	//'Relatório' ## 'Relatório de previsão da apuração dos eventos.'
			endif

			
					//-----------------------------------------------------------------------------------------------
			nAltBut 	:= 018
			nLinBut 	:= 000

			If !lDock .And. !lHighRes
				//nLinBut		+= nAltBut
				oButtEnd 	:= tButton():New(nLinBut,000,STR0042				,oAreaBut,bOk 		,oAreaBut:nClientWidth/2,nAltBut,,oFont,,.T.,,,,/*bWhen*/)//"Sair"
				oButtEnd:cTooltip := STR0050 //"Sai da rotina de processamento de apurações da Reinf."
				oButtEnd:SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) ) 
				nLinBut		+= nAltBut
				nLinBut		+= nAltBut
			EndIf

			For nButt := 1 To Len( aButtons )
				&("oButt"+StrZero(nButt) ) := tButton():New(nLinBut, 000, aButtons[nButt][01]	,oAreaBut,aButtons[nButt][02]	,oAreaBut:nClientWidth/2,nAltBut,,/*oFont*/,,.T.,,,,/*bWhen*/)			
				&("oButt"+StrZero(nButt) ):cTooltip := aButtons[nButt][03]
				&("oButt"+StrZero(nButt) ):SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) ) 
				nLinBut		+= nAltBut
			Next
 
			If lOpcFEvt
				//nLinBut		+= nAltBut
				oButtEvtFch 	:= tButton():New(nLinBut,000,cDescBTPEr,oAreaBut,{|| MsgInfo("Fechamento!")},oAreaBut:nClientWidth/2,nAltBut,,oFont,,.T.,,,,/*bWhen*/)//"Sair"
				oButtEvtFch:cTooltip := "Fechamento do período" //"Sai da rotina de processamento de apurações da Reinf."
				oButtEvtFch:SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) ) 

				nLinBut		+= nAltBut
				nLinBut		+= nAltBut				
			EndIf
			
			//	Atualiza os status dos Eventos
			Eval(bSetPeriodo)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lDock .And. !lHighRes
				oDlgPar:Activate(,,,.T.,/*valid*/,,/*On Init*/)

			Else
				oMainBrw:Activate(,,,.T.,/*valid*/,,/*On Init*/)
			EndIf
		EndIf			
	Else

		If !lMatriz
			Aviso(STR0043,STR0044, { STR0042 }, 2 ) //"Rotina indisponível" , "Só é possivel acessar a rotina de Apuração/Reinf logado na filial matriz."
		ElseIf Len( cCNPJFil ) < 11
			Aviso(STR0043,STR0088, { STR0042 }, 2 ) //"O Código de Inscrição (CNPJ) da matriz está em branco no cadastro de empresas."
		elseif !lReinfAtu
			//Aviso(STR0113,STR0114+CRLF+CRLF+STR0115+CRLF+CRLF+STR0116, { STR0042 }, 3 ) //"Ambiente desatualizado!" ###"O ambiente TAF encontra-se desatualizado com relação as alterações referentes ao layout 1.04.00 da EFD Reinf." ###"As rotinas disponíveis no repositório de dados (RPO) estão mais atualizadas que o dicionário de dados."###"Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF.""Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF.""Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF.""Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF.""Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF." 	
			nOpcAviso := Aviso(STR0113,STR0114+CRLF+CRLF+STR0115+CRLF+CRLF+STR0116+CRLF+CRLF+STR0117+CRLF+STR0118, { STR0042, STR0119 }, 3 ) //"**IMPORTANTE*/No caso do diferencial referente ao layout 1.4 já ter sido executado, siga as instruções do FAQ"
		
			if nOpcAviso == 2 // FAQ
				shellExecute("Open", "http://tdn.totvs.com/x/y4DlGg", "", "", 1 ) 
			EndIf

		EndIf 
	EndIf 
	RestArea(aArea)
	If !lDock
//		oMainBrw := nil
//		oDlgPar	 := nil	

		FreeObj( oMainBrw )
		FreeObj( oDlgPar)
	EndIf

	SetKey(VK_F12, {||})

Return( lRet )    

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Roberto Souza
@since 21/02/2018
@version 1.0 
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina as array

	aRotina := {}

	//Carregamento apenas na rotina de privilegios do configurador
	 If Alltrim( Upper( funname() ) ) == "CFGA530" //Necessario protecao para nao carregar o menu funcional ao logar no módulo TAF.
	 	//Funcao incluida no aRotina para liberar acesso aos usuários pelo cadastro de privilégio.(Padrão pelo configurador.)

		aAdd( aRotina, {'Configurações','TafParView',0,3} )
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFIlter
Monta um filtro para a visualização de LOG
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return cFilter
/*/
//-------------------------------------------------------------------
Static Function GetFIlter( cCampo , xInfo )
	Local cFilter as character

	cFilter := " AllTrim("+cCampo+") == AllTrim('"+xInfo+"')"
	cFilter += " .And. V0K_FILIAL == '"+xFilial("V0K")+"'"

Return( cFilter)


/*/{Protheus.doc} AtuEvent
	Função responsável pela atualização da grid de eventos para apuração.
	@type  Static Function
	@author José Mauro
	@since 10/09/2019
	@version 1.0
	@return nil
	/*/
Static Function AtuEvent(oListEvt,oEventos,aEventos,nOpc)

	aEventos := {}
	aEventos := TafReinfEV(,,nOpc) 

	oListEvt:Align := CONTROL_ALIGN_ALLCLIENT
	oListEvt:SetArray( aEventos )
	oListEvt:bLine := {|| {IIF(aEventos[oListEvt:nAt][01],oOk,oNo),;
						aEventos[oListEvt:nAt][02],;
						aEventos[oListEvt:nAt][03],;
						aEventos[oListEvt:nAt][04]}}
	oListEvt:SetFocus()
	oEventos:Refresh()
	oListEvt:Refresh()
	
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPeriodo
Ajusta os status dos eventos baseado no periodo informado
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	


@return lRet
/*/
//-------------------------------------------------------------------
Static Function SetPeriodo( cPeriodo, oEventos, oListEvt , aEventos, aFiliais, nOpc,nOpc2)

	Local aParamRei	as array
	Local lRet 		as logical 
		 
	aParamRei	:= Array(1)
	lRet 		:= at(' ',cPeriodo) = 0  .and. len(StrTran(cPeriodo,'-','')) = 6 .and. !empty( ctod( '01/'+StrTran(cPeriodo,'-','/') ) )

	if lRet
		cPeriodo := StrTran(cPeriodo,"-","")
		aParamRei[1] := cPeriodo
		
		FSalvProf(aParamRei)

		FWMsgRun(,{|| GetStatEvt(cPeriodo,,,@aEventos, aFiliais, nOpc, oStatPer,nOpc2) },,STR0051 )	//"Carregando Status dos Eventos..."	

		BrwRefresh( oListEvt, Len( aEventos ), @oTotMarkE, .F. )
		
		oListEvt:Align := CONTROL_ALIGN_ALLCLIENT
		oListEvt:SetArray( aEventos )
		oListEvt:bLine := {|| {IIF(aEventos[oListEvt:nAt][01],oOk,oNo),;
							aEventos[oListEvt:nAt][02],;
							aEventos[oListEvt:nAt][03],;
							aEventos[oListEvt:nAt][04]}}
		oListEvt:SetFocus()
		oListEvt:Refresh()
		oEventos:Refresh()
		
		aList := aClone( aEventos )
		
		If lOpcFEvt 
			oButtEvtFch:cTitle   := IIf( oStatPer:cTitle == STR0095 , "Reabrir ","Fechar ") +"Período"
			oButtEvtFch:cCaption := oButtEvtFch:cTitle
		EndIf
	else	
		Aviso('Aviso',STR0020,{'OK'},2)
	endif

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcPsq
Efetua a busca no grid
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return lRet
/*/
//-------------------------------------------------------------------
Static Function ProcPsq( aInd, cInd, aCond, cCond, cInfo , oLbx )
	Local lRet 		as logical
	Local aSeek 	as array
	Local nCol  	as numeric
	Local nCond		as numeric
	Local nPosIni   as numeric
	Local nModo 	as numeric

	lRet 		:= .T.
	aSeek 		:= oLbx:AARRAY
	nCol  		:= aScan( aInd,	{|x| Alltrim(x) == AllTrim(cInd) } ) + 1
	nCond		:= aScan( aCond,{|x| Alltrim(x) == AllTrim(cCond) } )
	nPosIni   	:= oLbx:NAT
	nModo 		:= 2    

	If nCond == 1
		nSeek := aScan( aSeek, {|x| Upper(Alltrim(cInfo)) == Upper(x[nCol]) })	                 
	ElseIf nCond == 2
		nSeek := aScan( aSeek, {|x| Upper(Alltrim(cInfo)) $  Upper(x[nCol]) })	                 
	EndIf	                    
    
	If nSeek == 0
		nSeek := 1
	EndIf
                     
	oLbx:NAT := nSeek

Return( lRet )       

    
//-------------------------------------------------------------------
/*/{Protheus.doc} PrefByTab
Identifica o prefixo dos campos de acordo com a tabela
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return lRet
/*/
//-------------------------------------------------------------------
Static Function PrefByTab( cTable, cPref, nPref )
	Local lRet 	as logical

	lRet := .T.

	If Substr( cTable, 1, 1 ) == "S"
		cPref := Substr( cTable, 2, 2 )	+ "_"	
		nPref := 3
	Else
		cPref := Substr( cTable, 1, 3 )	+ "_" 
		nPref := 4
	EndIf
	
Return( lRet ) 



//--------------------------------------------------------------------
/*/{Protheus.doc} BrwRefresh
Efetua o Refresh em todos Objetos atualizaveis

@author Roberto Souza
@since 20/02/2018
@version 1
/*/
//--------------------------------------------------------------------
Static Function BrwRefresh( oListBox, nTots, oTotMark, lAtuLabel )

	Local lRet		as logical
	Local nMarked 	as numeric
	Local aList     as array 
	
	Default lAtuLabel := .T.
	
	aList   := aClone(oListBox:AARRAY)
	lRet := .T.
	nMarked := GetNumMkd( aList )             

	oTotMark:cTitle := STR0028 +StrZero(nTots,4)+' | '+STR0029 + StrZero(nMarked,4)//"Total de Registros: "##"Total de Registros: "##"Total Selecionados: "
	oListBox:Refresh()
	
	nPosX099 := aScan( aList,{|x| x[E_NOME] $ "R-2099|R-4099"})
	If nPosX099 > 0 .And. lAtuLabel
		If aList[nPosX099][E_LEGENDA] == oBlue
			oStatPer:cTitle 	:= STR0095 //"Fechado"
			cStatPer 			:= oStatPer:cTitle
			oStatPer:nClrText 	:= CLR_RED
		Else 
			oStatPer:cTitle 	:= STR0094 //"Aberto"
			cStatPer 			:= oStatPer:cTitle
			oStatPer:nClrText 	:= CLR_GREEN
		EndIf
		oStatPer:Refresh()
	EndIf
Return( lRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} AtuBrwFil
Efetua o Refresh nos objetos da filial

@author Wesley Pinheiro
@since 27/01/2020
@version 1
/*/
//--------------------------------------------------------------------
Static Function AtuBrwFil( oListBox, nTots, oTotMark )
	
	Local nMarked 	as numeric
	Local aList     as array 
	
	aList   := aClone( oListBox:AARRAY )
	nMarked := GetNumMkd( aList )             

	oTotMark:cTitle := STR0028 +StrZero( nTots, 4 ) + ' | ' + STR0029 + StrZero( nMarked, 4 ) //"Total de Registros: "##"Total de Registros: "##"Total Selecionados: "
	oListBox:Refresh( )
	
Return              

//--------------------------------------------------------------------
/*/{Protheus.doc} GetNumMkd
Atualiza o numero de linhas selecionadas

@author Roberto Souza
@since 20/02/2018
@version 1
/*/
//--------------------------------------------------------------------
Static Function GetNumMkd( aList )
	Local nMarked as numeric
	Local Nx      as numeric

	nMarked := 0
	Nx      := 0
            
	For Nx := 1 To Len(aList) 
   		If aList[Nx][01]
	   		nMarked++	
		EndIf
	Next              
Return( nMarked )			  


    
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFil
CArrega as filiais para processamento da REINF
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return lRet
/*/
//-------------------------------------------------------------------
Static Function LoadFil( cFilterFil , lJob )
	Local aFils		as array
	Local cKeyEmp   as character
	Local lValid	as logical
	Local lCanCheck as logical
	Local nRecnoSM0	as numeric
	Local cCNPJMat	as character
	Local cTpInscr 	as character

	Default cFilterFil 	:= ".T."
	Default lJob    	:= .F.

	lShowAllFil	:= Iif( Type( "lShowAllFil" ) == "U", .F., lShowAllFil ) 

	aFils		:= {}
	cKeyEmp   	:= cEmpAnt+cFilAnt
	lValid		:= .T.
	lCanCheck 	:= .T.
	nRecnoSM0	:= SM0->( Recno() )
	cCNPJMat	:= AllTrim( SM0->M0_CGC )
	cTpInscr 	:= Iif( Len( cCNPJMat ) == 14, "1", "2" )

	If !lJob

		DbSelectArea("C1E")
		C1E->(DbSetOrder( 1 ))
		DbGoTop()

		While C1E->( !Eof() )

			If C1E->C1E_ATIVO == "1" .And. &cFilterFil
				lValid 	:= .T.
				cCNPJFil:= AllTrim(Posicione("SM0",1,cEmpAnt+C1E->C1E_FILTAF, "M0_CGC"))

				If cTpInscr == "1"
					lCanCheck := Left( cCNPJMat, 8 ) == Left( cCNPJFil, 8 ) 
				Else
					lCanCheck := cCNPJMat == AllTrim( cCNPJFil )
				EndIf
				
				If lCanCheck .Or. lShowAllFil
					
					AADD( aFils ,{	lCanCheck,;
									C1E->C1E_ID,;
									AllTrim(C1E->C1E_FILTAF),;
									AllTrim(C1E->C1E_CODFIL),;
									AllTrim(C1E->C1E_NOME),;
									AllTrim(Posicione("SM0",1,cEmpAnt+C1E->C1E_FILTAF, "M0_CGC")),;
									AllTrim(Capital(TAF421Sts(C1E->C1E_STATUS))),;
									lCanCheck,;
									C1E->C1E_MATRIZ})		
				EndIf
			EndIf	
			C1E->( DbSkip() )
		EndDo
	Else
		AADD( aFils ,{.F.,"000001","01","9901","Filial 01","","","","","","","","",""})
		AADD( aFils ,{.F.,"000002","02","9902","Filial 02","","","","","","","","",""})
		AADD( aFils ,{.F.,"000003","03","9903","Filial 03","","","","","","","","",""})
	EndIf

	// Caso não haja filiais ativas, preenche com uma linha
	If Empty( aFils)
		AADD( aFils ,{	.F.,;
						"------",;
						"--",;
						"--",;
						"------------------------------",;
						"-------------------------","---",""})	
	EndIf
	DbSelectArea("SM0")
	SM0->(DbSeek(cKeyEmp)) /*cEmpAnt+cFilAnt*/
Return( aFils ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFR2098
Processa evento de reabertura do período (R-2098)
@author Bruno Cremaschi
@since 25/09/2018
@version 1.0 

@aParam cPeriodo, cEvento, aFiliais	

@return lRet
/*/
//-------------------------------------------------------------------
Static Function TAFRX098(cPeriodo, cEvento, aFiliais)
	Local cIdLog	as character
	Local lValid	as logical
	Local oProcess	as object

	cIdLog 	 := TafXLogIni( cIdLog, cEvento )
	cPeriodo := StrTran(cPeriodo,"-","")
	lValid	 := Left(GetNewPar( "MV_TAFRVLD", "N" ),1) == "S"
	oProcess := Nil
	oProcess := MsNewProcess():New( { || TAFAPR2098( cEvento, cPeriodo,/*dDtIni*/,/*dDtFim*/, cIdLog, aFiliais , oProcess, lValid ) }, STR0053 ) //"Carregando Predecessões..."
	oProcess:Activate()
	FreeObj(oProcess)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TafReinfEV
Carrega os eventos para processamento da REINF
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aEventos
/*/
//-------------------------------------------------------------------
Function TafReinfEV( cFilterEvt as character, lAll as logical, nOpc as numeric ) as array
	Local aEventos 	as array
	Local lRecAD	as logical
	Local l2050 	as logical 
	Local l2060 	as logical 
	Local l3010		as logical
	Local lPeriodo  as logical

	aEventos         := {}
	lPeriodo         := TAFAlsInDic("V1O")
	l2050            := FindFunction("TAFApR2050") .And. lPeriodo
	l2060            := FindFunction("TAFApR2060") .And. lPeriodo
	l3010            := FindFunction("TAFAPR3010") .And. lPeriodo
	lRecAD           := FindFunction("TAFAPRECAD") .And. lPeriodo
	__cEvtTot        := GetTotalizerEventCode("evtTot")
	__cEvtTotContrib := GetTotalizerEventCode("evtTotContrib")
	

	Default lAll := .F.

	AADD( aEventos,{.F.,oRed,"R-1000","Informações do Contribuinte", "Detalhamento e informações úteis do evento."})
	AADD( aEventos,{.F.,oRed,"R-1070","Tabela de Processos Administrativos/Judiciais", "Detalhamento e informações úteis do evento."})

	// Tabela T9B
	if nOpc == 1

		AADD( aEventos,{.F.,oRed,"R-2010","Retenção Contribuição Previdenciária - Serviços Tomados", "Detalhamento e informações úteis do evento."})
		AADD( aEventos,{.F.,oRed,"R-2020","Retenção Contribuição Previdenciária - Serviços Prestados", "Detalhamento e informações úteis do evento."})

		If lRecAD
			AADD( aEventos,{.F.,oRed,"R-2030","Recursos Recebidos por Associação Desportiva", "Detalhamento e informações úteis do evento."})
			AADD( aEventos,{.F.,oRed,"R-2040","Recursos Repassados para Associação Desportiva", "Detalhamento e informações úteis do evento."})
		EndIf		
		
		If l2050
			AADD( aEventos,{.F.,oRed,"R-2050","Comercialização da Produção por Produtor Rural PJ/Agroindústria", "Detalhamento e informações úteis do evento."})
		EndIf
		
		If l2060
			AADD( aEventos,{.F.,oRed,"R-2060","Contribuição Previdenciária sobre a Receita Bruta - CPRB", "Detalhamento e informações úteis do evento."})
		EndIf
		
		If l3010
			AADD( aEventos,{.F.,oRed,"R-3010","Receita de Espetáculo Desportivo", "Detalhamento e informações úteis do evento."})
		EndIF
		
		If lPeriodo
			AADD( aEventos,{.F.,oRed,"R-2099","Fechamento dos Eventos Periódicos", "Detalhamento e informações úteis do evento."})
		EndIf

	ENDIF 

 Return( aEventos )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatEvt
Atribui as legendas de acordo com os Status.
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aEventos
/*/
//-------------------------------------------------------------------
Static Function GetStatEvt( cPeriodo,dDtIni,dDtFim, aEventos, aFiliais, nOpc, oStatPer,nOpc2 )
	
Local Nx 			as numeric
Local lRet  		as logical
Local cStat 		as character
Local cAliasV1O		as character
Local cStat2099		as character	
Local cBloco        as character
Local cAlias        as character
Local cEventFech    as character
Local cEventAber    as character
Local cFromV1O		as Character 
Local cWhereV1O		as Character 

Local lAberto		as logical  
  
Local lIndV1O       as logical

Default dDtIni 		:= FirstDay(Date())
Default dDtFim 		:= LastDay(Date())

cAlias     	:= "V0B"
cBloco     	:= "20"
cEventFech 	:= "R-2099"
cEventAber 	:= "R-2098"
lIndV1O 	:= .F. 
cFromV1O    := ""
cWhereV1O   := ""

Nx 			:= 0
lRet  		:= .F.
cAliasV1O	:= GetNextAlias()
cStat 		:= "1"
cStat2099 	:= "1"	
lAberto		:= .T.


DbSelectArea("SM0")
SM0->(DbSeek(cKeyEmp)) /*cEmpAnt+cFilAnt*/

nCountAll++ 
cPeriodo := StrTran(cPeriodo,"-","")

If nOpc2 == 2
	cAlias     := "V3W"
	cBloco     := "40"
	cEventFech := "R-4099"
	cEventAber := "R-4098"
endif

For Nx := 1 To Len( aEventos )
	aEventos[Nx][E_MARK] 	  := .F.				
	If !( aEventos[Nx][E_NOME] $ cEventFech)
		//Verifica os status das visões Movimentações e Apurações.
		If !(nOpc == 3)  .Or. aEventos[Nx][E_NOME] $ "R-1000"    
			cStat := TafRStatEv( cPeriodo, aEventos[Nx][E_MARK] ,aEventos[Nx][E_LEGENDA] ,aEventos[Nx][E_NOME], aFiliais, nOpc  )
		EndIf

		//Verifica os status da visão Transmissões apenas.
		If nOpc == 3 .And. !( aEventos[Nx][E_NOME] $ "R-1000")
			aStats := TafEvRStat( aFiliais, cPeriodo, aEventos[Nx][E_NOME] , @cStat)
		EndIf
		If cStat == "1" // Apuração não efetuada para o periodo
			aEventos[nx][E_LEGENDA] := oRed
		ElseIf cStat == "2"
			aEventos[nx][E_LEGENDA] := oYellow
		ElseIf cStat == "3"
			aEventos[nx][E_LEGENDA] := oGreen
		ElseIf cStat == "4"
			aEventos[nx][E_LEGENDA] := oBlue
			aEventos[nx][E_MARK] := .F.	
		ElseIf cStat == "5"
			aEventos[nx][E_LEGENDA] := oBlack
			aEventos[nx][E_MARK] := .F.
		ElseIf cStat == "6"
			aEventos[nx][E_LEGENDA] := oOrange
		EndIf
	EndIf	
Next

	//Query para montar o Status do Período
	cFromV1O  := RetSqlName("V1O") + " V1O1 "
	cWhereV1O := " V1O1.V1O_FILIAL = '" + xFilial("V1O") + "'"
	cWhereV1O += " AND V1O1.V1O_PERAPU  = '" + cPeriodo + "'"
	cWhereV1O += " AND V1O1.V1O_ATIVO  = '1'  "
	cWhereV1O += " AND V1O1.V1O_EVENTO = 'A'  "

	cWhereV1O += " AND V1O1.D_E_L_E_T_ = ' '  "
	cWhereV1O += " AND V1O1.V1O_DATA || V1O1.V1O_HORA = (  "     
	cWhereV1O += " SELECT MAX(V1O2.V1O_DATA || V1O2.V1O_HORA)
	cWhereV1O += " FROM " + RetSqlName("V1O") + " V1O2 "
	cWhereV1O += "	WHERE V1O2.V1O_PERAPU     = '" + cPeriodo + "'"
	cWhereV1O += "	AND V1O2.V1O_ATIVO  = '1' 
	cWhereV1O += "	AND V1O2.D_E_L_E_T_ = ' '"
	cWhereV1O += "	AND V1O2.V1O_EVENTO = 'A'  

	cWhereV1O += "	AND V1O2.V1O_FILIAL = '" + xFilial("V1O") + "'"

	cFromV1O  := "%" + cFromV1O   + "%" 
	cWhereV1O := "%" + cWhereV1O  + "%" 

//Verifica os status do evento R-2099.
 nPosX099 := aScan( aEventos,{|x| x[E_NOME] == cEventFech})
If nPosX099 > 0
	If TAFAlsInDic( "V1O" )
		
		BeginSql ALIAS cAliasV1O
			SELECT 
				V1O1.V1O_NOMEVE
			FROM 
				%Exp:cFromV1O%
			WHERE 
				%Exp:cWhereV1O%			
		EndSql

		If !(cAliasV1O)->(Eof()) 
			If !Empty((cAliasV1O)->V1O_NOMEVE) 
				If cEventAber $ (cAliasV1O)->V1O_NOMEVE
					oStatPer:cTitle 	:= STR0096 //"Reaberto"
					cStatPer 			:= oStatPer:cTitle 
				ElseIf cEventFech $ (cAliasV1O)->V1O_NOMEVE
					oStatPer:cTitle 	:= STR0095 //"Fechado"
					cStatPer 			:= oStatPer:cTitle
					oStatPer:nClrText 	:= CLR_RED
				EndIf
			Else 
				oStatPer:cTitle 	:= STR0094 //"Aberto"
				cStatPer 			:= oStatPer:cTitle
				oStatPer:nClrText 	:= CLR_GREEN
			EndIf
			oStatPer:Refresh()
			
			If cEventFech $ (cAliasV1O)->V1O_NOMEVE .And. nOpc == 3
				lAberto := .F.	
				aEventos[nPosX099][E_LEGENDA] := oBlue	
				aEventos[nPosX099][E_MARK] 	  := .F.
			ElseIf cEventFech $ (cAliasV1O)->V1O_NOMEVE .And. nOpc == 2
				lAberto := .F.	
				aEventos[nPosX099][E_LEGENDA] := oGreen	
				aEventos[nPosX099][E_MARK] 	  := .F.
			ElseIf nOpc == 1
				lAberto := .F.	
				aEventos[nPosX099][E_LEGENDA] := oBlack
				aEventos[nPosX099][E_MARK] 	  := .F.	
			Else
				If nOpc == 1
					lAberto := .T.
					aEventos[nPosX099][E_LEGENDA] := oBlack
				Else	
					lAberto := .T.	
					//Verifica se tem uma apuração de fechamento
					DBSelectArea( cAlias )
					(cAlias)->( DbSetOrder(2) )
					If (cAlias)->( DbSeek( xFilial(cAlias) + cPeriodo + "1") ) .And. (cAlias)->&(cAlias+"_STATUS") <> "4" .And. nOpc == 2
						aEventos[nPosX099][E_LEGENDA] := oGreen
					Else
						aEventos[nPosX099][E_LEGENDA] := oRed
					EndIf		
				EndIf				
			EndIf
		Else
			DBSelectArea( "V1O" )
			V1O->(DBSetOrder(2)) // V1O_FILIAL, V1O_PERAPU, V1O_ATIVO,V1O_BLOCO,R_E_C_N_O_, D_E_L_E_T_

			lIndV1O := V1O->( DbSeek( xFilial( "V1O" ) +cPeriodo+"1") )
			if lIndV1O
				If !Empty(V1O->V1O_NOMEVE)
					If cEventAber $ V1O->V1O_NOMEVE
						oStatPer:cTitle 	:= STR0096 //"Reaberto"
						cStatPer 			:= oStatPer:cTitle 
					ElseIf cEventFech $ V1O->V1O_NOMEVE
						oStatPer:cTitle 	:= STR0095 //"Fechado"
						cStatPer 			:= oStatPer:cTitle
						oStatPer:nClrText 	:= CLR_RED
					EndIf
				Else 
					oStatPer:cTitle 	:= STR0094 //"Aberto"
					cStatPer 			:= oStatPer:cTitle
					oStatPer:nClrText 	:= CLR_GREEN
				EndIf
			Else
				oStatPer:cTitle 	:= "Aberto" //"Aberto"
			    cStatPer 			:= oStatPer:cTitle		
			EndIf
			
			oStatPer:Refresh() 
			
			If cEventFech $ V1O->V1O_NOMEVE .And. nOpc == 3
				lAberto := .F.	
				aEventos[nPosX099][E_LEGENDA] := oBlue	
				aEventos[nPosX099][E_MARK] 	  := .F.
			ElseIf cEventFech $ V1O->V1O_NOMEVE .And. nOpc == 2
				lAberto := .F.	
				aEventos[nPosX099][E_LEGENDA] := oGreen	
				aEventos[nPosX099][E_MARK] 	  := .F.
			ElseIf nOpc == 1
				lAberto := .F.	
				aEventos[nPosX099][E_LEGENDA] := oBlack
				aEventos[nPosX099][E_MARK] 	  := .F.	
			Else
				If nOpc == 1
					lAberto := .T.
					aEventos[nPosX099][E_LEGENDA] := oBlack
				Else	
					lAberto := .T.	
					//Verifica se tem uma apuração de fechamento
					DBSelectArea( cAlias )
					(cAlias)->( DbSetOrder(2) )
					If (cAlias)->( DbSeek( xFilial(cAlias) + cPeriodo + "1") ) .And. (cAlias)->&(cAlias+"_STATUS") <> "4" .And. nOpc == 2
						aEventos[nPosX099][E_LEGENDA] := oGreen
					Else
						aEventos[nPosX099][E_LEGENDA] := oRed
					EndIf		
				EndIf				
			EndIf													
		EndIf
	Else
		// Para Evento R-2099, considero todos os Status dos Eventos
		nPosX099 := aScan( aEventos,{|x| x[E_NOME] == cEventFech})
		If nPosX099 > 0 
			DBSelectArea( cAlias )
			DbSetOrder(2)
			If (cAlias)->( DbSeek( xFilial(cAlias) + cPeriodo + "1") )	
				If (cAlias)->&(cAlias+"_STATUS") =='4' .And. nOpc == 3
					cStat := "4" 
					// Evento Apurado e Autorizado
					aEventos[nPosX099][E_LEGENDA] := oBlue
					aEventos[nPosX099][E_MARK] 	  := .F.	
				ElseIf (cAlias)->&(cAlias+"_STATUS") =='4' .And. nOpc == 2
					cStat := "4" 
					// Evento Apurado e Autorizado
					aEventos[nPosX099][E_LEGENDA] := oGreen
					aEventos[nPosX099][E_MARK] 	  := .F.			
				ElseIf (cAlias)->&(cAlias+"_STATUS") <>'4' .And. nOpc == 3
					// Evento Apurado mas não autorizado
					aEventos[nPosX099][E_LEGENDA] := oRed
				ElseIf (cAlias)->&(cAlias+"_STATUS") <>'4' .And. nOpc == 2
					// Evento Apurado mas não autorizado
					aEventos[nPosX099][E_LEGENDA] := oGreen
				ElseIf nOpc == 1
					//Sem Movimento
					aEventos[nPosX099][E_LEGENDA] := oBlack
				EndIf
			Else
				If nOpc == 1
					//Sem Movimento
					aEventos[nPosX099][E_LEGENDA] := oBlack
				Else
					// Evento disponível mas não apurado
					aEventos[nPosX099][E_LEGENDA] := oRed
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

if select(cAliasV1O) > 0 
	//## Importante verificar ##
	(cAliasV1O)->(DbCloseArea())
endif

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafRStatEv
Retorna os Status dos Eventos de acordo com o periodo
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return cRet
/*/
//-------------------------------------------------------------------
Function TafRStatEv( cPeriodo as character, lChecked as logical, oLegenda as object, cEvento as character, aFiliais as array, nOpc as numeric, nQtdApur as numeric, nQtdNApur as numeric, lApur as logical, lGetStatus as logical, cCNPJC1H as character, nTotDocOk as numeric, nTotDocNo as numeric, lApi as logical, nTotFor as numeric) as character
	Local cRet 		as character
	Local cKeyT9U	as character 
	Local nTamFil 	as numeric
	Local nRetOk	as numeric
	Local nRetNo	as numeric
	Local nCont 	as numeric
	Local lBlc40    as logical	
	Local aFilCont  as array 
	Local aRet1050  as array

	Default	nQtdApur	:=	0
	Default	nQtdNApur	:=	0
	Default	lApur		:=	.f.
	Default lGetStatus	:=	.f.
	Default cCNPJC1H	:= ''
	Default nTotDocOk	:= 0 
	Default nTotDocNo	:= 0
	Default lBlc40      := .F.
	Default lApi		:= .F.

	IniVar()

	cRet             := "5" // Default Black
	nTamFil          := _TmFilTaf
	cKeyT9U          := ""
	nRetOk           := 0
	nRetNo           := 0
	nCont            := 0
	lBlc40           := TAFAlsInDic("V5C") .AND. TafColumnPos("LEM_PRID40") .And. FindFunction("TAFQRY40XX")
	aFilCont         := {}
	aRet1050         := {}
	__cEvtTot        := GetTotalizerEventCode("evtTot")
	__cEvtTotContrib := GetTotalizerEventCode("evtTotContrib")

	cPeriodo := StrTran(cPeriodo,"-","")
	
	If cEvento == "R-1000"
		cRet := RetSt1000( aFiliais, nOpc, @nRetOk, @nRetNo )
	ElseIf cEvento == "R-1050"
		cRet := "1"
		aRet1050 := RetSt1050( aFiliais, cPeriodo, cEvento, lApi)

		nRetOk := aRet1050[01] //Apurados
		nRetNo := aRet1050[02] //Não Apurados
		nRetAut:= aRet1050[03] //Transmitidos
		
		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 //Sem Movimento
			cRet := "5"
		ElseIf nOpc == 2 .And. (nRetOk == 0 .And. nRetNo > 0) //Não Apurado
			cRet := "1"
		ElseIf nOpc == 2 .And. (nRetOk > 0 .And. nRetNo > 0) //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) // Não transmitido
			cRet := "3"
		EndIf
	ElseIf cEvento == "R-1070"
		cRet := "1"
		aRet1070 := RetSt1070( aFiliais, cPeriodo, cEvento, lApi)

		nRetOk := aRet1070[01] //Apurados
		nRetNo := aRet1070[02] //Não Apurados
		nRetAut:= aRet1070[03] //Transmitidos
		
		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 //Sem Movimento
			cRet := "5"
		ElseIf nOpc == 1 .And. (nRetOk > 0 .Or. nRetNo > 0)	//Possui Movimento
			cRet := "3"
		ElseIf nOpc == 2 .And. (nRetOk == 0 .And. nRetNo > 0) //Não Apurado
			cRet := "1"
		ElseIf nOpc == 2 .And. (nRetOk > 0 .And. nRetNo > 0) //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) // Não transmitido
			cRet := "3"
		EndIf
	ElseIf cEvento $ "R-2010|R-2020|"
		nRetOk := RetSt2000( aFiliais, cPeriodo, cEvento, .T., cCNPJC1H, lApur, @nTotDocOk, lApi,)
		nRetNo := RetSt2000( aFiliais, cPeriodo, cEvento, .F., cCNPJC1H, lApur, @nTotDocNo, lApi,)

		//Adicionei mais uma vez a chamada desta função para realizar a contagem de fornecedores/clientes.
		If lApi
			RetSt2000( aFiliais, cPeriodo, cEvento, .F., cCNPJC1H, lApur, , lApi,@nTotFor, .T.)
		EndIf
		
		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 // Sem Movimento
			cRet := "5"
		ElseIf nOpc == 1 .And. (nRetOk > 0 .Or. nRetNo > 0) //Possui Movimento
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo > 0 //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk == 0 .And. nRetNo > 0 //Não Apurado
			cRet := "1"		
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) // Não transmitido
			cRet := "3"						
		EndIf	
	ElseIf cEvento == "R-2030"
		nRetOk := RetStRecAD(aFiliais, cPeriodo, cEvento, .T., lApi, @nTotDocOk, @aFilCont, @nCont)
		nRetNo := RetStRecAD(aFiliais, cPeriodo, cEvento, .F., lApi, @nTotDocOk, @aFilCont, @nCont)

		if lApi  .and. nRetOk!=0
			nRetOk -= nCont
		endIf
	
		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 // Sem Movimento
			cRet := "5"
		ElseIf nOpc == 1 .And. (nRetOk > 0 .Or. nRetNo > 0) //Possui Movimento
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo > 0 //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk == 0 .And. nRetNo > 0 //Não Apurado
			cRet := "1"
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) // Não transmitido
			cRet := "3"									
		EndIf
	ElseIf cEvento == "R-2040"
		nRetOk := RetStRecAD(aFiliais, cPeriodo, cEvento, .T., lApi, @nTotDocOk, @aFilCont, @nCont)
		nRetNo := RetStRecAD(aFiliais, cPeriodo, cEvento, .F., lApi, @nTotDocOk, @aFilCont, @nCont)

		if lApi  .and. nRetOk!=0
			nRetOk -= nCont
		endIf

		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 // Sem Movimento
			cRet := "5"
		ElseIf nOpc == 1 .And. (nRetOk > 0 .Or. nRetNo > 0) //Possui Movimento
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo > 0 //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk == 0 .And. nRetNo > 0 //Não Apurado
			cRet := "1"
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) // Não transmitido
			cRet := "3"								
		EndIf
	ElseIf cEvento $ "R-2050"
		nRetOk := RetSt2050( aFiliais, cPeriodo, cEvento, .T., lApur, lGetStatus, cCNPJC1H, @nTotDocOk, lApi)
		nRetNo := RetSt2050( aFiliais, cPeriodo, cEvento, .F., lApur, lGetStatus, cCNPJC1H, @nTotDocNo, lApi)

		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 // Sem Movimento
			cRet := "5"
		ElseIf nOpc == 1 .And. (nRetOk > 0 .Or. nRetNo > 0) //Possui Movimento
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo > 0 //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk == 0 .And. nRetNo > 0 //Não Apurado
			cRet := "1"
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) //Não transmitido
			cRet := "3"
		EndIf
	ElseIf cEvento $ "R-2055"
		nRetOk := RetSt2055( aFiliais, cPeriodo, cEvento, .T., lApur, lGetStatus, @nTotDocOk, lApi)
		nRetNo := RetSt2055( aFiliais, cPeriodo, cEvento, .F., lApur, lGetStatus, @nTotDocNo, lApi)
		nTotFor:= RetSt2055( aFiliais, cPeriodo, cEvento, .F., .T., .F., @nTotFor, lApi)

		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 // Sem Movimento
			cRet := "5"
		ElseIf nOpc == 1 .And. (nRetOk > 0 .Or. nRetNo > 0) //Possui Movimento
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo > 0 //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk == 0 .And. nRetNo > 0 //Não Apurado
			cRet := "1"
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) //Não transmitido
			cRet := "3"
		EndIf
	ElseIf cEvento == "R-2060"
		nRetOk := RetSt2060( aFiliais, cPeriodo, cEvento, .T.)
		nRetNo := RetSt2060( aFiliais, cPeriodo, cEvento, .F.)

		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 // Sem Movimento
			cRet := "5"
		ElseIf nOpc == 1 .And. (nRetOk > 0 .Or. nRetNo > 0) //Possui Movimento
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo > 0 //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk == 0 .And. nRetNo > 0 //Não Apurado
			cRet := "1"
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) // Não transmitido
			cRet := "3"								
		EndIf
	ElseIf cEvento == "R-3010"
		nRetOk := RetSt3010( aFiliais, cPeriodo, cEvento, .T., lApi)
		nRetNo := RetSt3010( aFiliais, cPeriodo, cEvento, .F., lApi)

		If (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 // Sem Movimento
			cRet := "5"
		ElseIf nOpc == 1 .And. (nRetOk > 0 .Or. nRetNo > 0) //Possui Movimento
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo > 0 //Apurado Parcial
			cRet := "2"
		ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
			cRet := "3"
		ElseIf nOpc == 2 .And. nRetOk == 0 .And. nRetNo > 0 //Não Apurado
			cRet := "1"	
		ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) // Não transmitido
			cRet := "3"	 						
		EndIf
	ElseIf cEvento == __cEvtTot
		DbSelectArea("V0W") 
		DbSetOrder( 2 )
		If V0W->( DbSeek( xFilial("V0W")+ cPeriodo) )
			While AllTrim(V0W->V0W_PERAPU) == AllTrim(cPeriodo) .And. V0W->(!Eof())
				If V0W->V0W_ATIVO == "1" .And. V0W->V0W_STATUS == "4" 
					cRet := "4"
				EndIf
				V0W->( DbSkip() )
			EndDo	
		EndIf	
	ElseIf cEvento == __cEvtTotContrib
		DbSelectArea("V0C")
		DbSetOrder( 2 )
		If V0C->( DbSeek( xFilial("V0C")+ cPeriodo) )
			While AllTrim(V0C->V0C_PERAPU) == AllTrim(cPeriodo) .And. V0C->(!Eof())
				If V0C->V0C_ATIVO == "1" .And. V0C->V0C_STATUS == "4"
					cRet := "4"
				EndIf
				V0C->( DbSkip() )
			EndDo	
		EndIf		
	EndIf

	// ALIMETO PARA A API DO PORTAL THF
	nQtdApur	:=	nRetOk
	nQtdNApur	:=	nRetNo

Return( cRet )



//-------------------------------------------------------------------
/*/{Protheus.doc} InitProc
Chamada do processamento das apurações
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function InitProc( cPeriodo, dDtIni, dDtFim, aEventos, aFiliais, oEventos, oListEvt,nOpc )
	Local aRet 		as array
	Local aSelFils 	as array
	Local oProcess	as object
	Local oSayEvt	as object
	Local cErro		as character
	Local cWarning  as character
	Local cMsg      as character
	Local nX      	as numeric
	Local aProcess  as array
	Local aSayEvt   as array
	Default nOpc := 1

	aRet 		:= {}
	aSelFils 	:= ValidFils( aFiliais )
	oProcess 	:=	Nil
	oSayEvt 	:=	Nil
	cPeriodo 	:= StrTran(cPeriodo,"-","")
	cErro		:= ""
	cWarning  	:= ""
	cmsg        := cWarning +CRLF+ STR0052 //"Deseja prosseguir com a apuração dos eventos?"
	nX 			:= 0
	aProcess    := {}
	aSayEvt  	:= {}
	
	If ValidProc( cPeriodo, aEventos, aFiliais, @cErro, @cWarning )

		If !Empty(cErro)
			Aviso( STR0070, cErro, {"Ok"},3) //"Atenção"
			cMsg:= cWarning +CRLF+ STR0121  //"Deseja prosseguir com a apuração dos demais eventos?"
		endif

		If MsgYesNo( cMsg ) 
			if nOpc == 1
				oProcess := MsNewProcess():New( { || aRet := GoProc(oProcess, cPeriodo, dDtIni, dDtFim, aEventos, aSelFils,oEventos, oListEvt,oSayEvt,nOpc )}, STR0053 ) //"Carregando Predecessões..."
				oProcess:Activate()
			else
				For nX := 1 to Len(aEventos)
					if aEventos[Nx][01] .AND. (aEventos[Nx][03] == "R-1070" .OR. aEventos[Nx][03] == "R-1000")
						AADD(aProcess,{aEventos[Nx][01],aEventos[Nx][2],aEventos[Nx][3],aEventos[Nx][4],aEventos[Nx][5]})
					elseif aEventos[Nx][01] .AND. (aEventos[Nx][03] == "R-4010" .OR. aEventos[Nx][03] == "R-4020" .OR. aEventos[Nx][03] == "R-4040" .OR. aEventos[Nx][03] == "R-4099")
						AADD(aSayEvt,{aEventos[Nx][01],aEventos[Nx][2],aEventos[Nx][3],aEventos[Nx][4],aEventos[Nx][5]})
					EndIf
				Next Nx

				if len(aProcess) > 0 
					oProcess := MsNewProcess():New( { || aRet := GoProc(oProcess, cPeriodo, dDtIni, dDtFim, aProcess, aSelFils,oEventos, oListEvt,nil,nOpc )}, STR0053 ) //"Carregando Predecessões..."
					oProcess:Activate()
				endif
					
				if len(aSayEvt) > 0 
					FWMsgRun( Nil , { |oSayEvt| aRet := GoProc( oProcess, cPeriodo, dDtIni, dDtFim, aSayEvt, aSelFils,oEventos,oListEvt,oSayEvt,nOpc ) } , "Processando", "Processando a rotina..." )
				EndIF
		EndIf	
		EndIf				
	Else

		If Empty( cErro )
			cErro := STR0069 // "Parametros inválidos para apuração."
		EndIf	
		
		Aviso( STR0070, cErro, {"Ok"},3) //"Atenção"
	EndIf
	
Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidProc
Valida a chamada de apurações.
@author Roberto Souza
@since 16/03/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function ValidProc( cPeriodo, aEventos, aFiliais, cErro, cWarning )
	Local lRet 		as logical
	Local lEvento	as logical
	Local lFiliais	as logical
	Local lPeriodo	as logical
	Local nX 		as numeric
	Local nTemApur  as numeric
	Local cStat     as character
	Local cStatMov	as character


	Default cErro 	:= ""
	Default cWarning:= ""
	
	lRet 		:= .T.
	lEvento 	:= .F.
	lFiliais	:= .F.
	lPeriodo	:= .F.
	nX 			:= 0
	nTemApur	:= 0  //Controla se tem eventos para serem apurados. 
	cStat 		:= ""
	cStatMov	:= ""

	cPeriodo 	:= StrTran(cPeriodo,"-","")
	// Tratamento para periodo
	// Implementar futuramente
	lPeriodo 	:= .T.

	For nX := 1 To Len( aEventos )
		If aEventos[nX][01]
			lEvento := .T.
		EndIf
	Next	

	For nX := 1 To Len( aFiliais )
		If aFiliais[nX][F_MARK]
			lFiliais := .T.
		EndIf
		If !aFiliais[nX][F_MARK] .And. aFiliais[nX][F_CANCHECK]
			cWarning := STR0071 //"Existem filiais recomendadas para apuração que não foram selecionadas."
		EndIf
	Next	
	
	BEGIN SEQUENCE	
		If !lPeriodo
			cErro 	+= STR0072 + CRLF //"-Período inválido para apuração."
			lRet	:= .F.
			BREAK
		EndIf 

		If !lEvento
			cErro 	+= STR0073 + CRLF //"-Nenhum evento selecionado para apuração."
			lRet	:= .F.
			BREAK
		EndIf

		If !lFiliais
			cErro 	+= STR0074 + CRLF //"-Nenhuma Filial selecionada para apuração."
			lRet	:= .F. 
			BREAK
		EndIf

		For Nx := 1 To Len( aEventos ) 
							
			If  aEventos[Nx] [E_MARK] == .T. 
				If aEventos[Nx][E_LEGENDA]:cname $ "BR_VERDE"  
                    If !( aEventos[Nx][E_NOME] $ "R-1000|R-2099")
						
						//retorna o status dos eventos transmitidos
						TafEvRStat( aFiliais, cPeriodo, aEventos[Nx][E_NOME] , @cStat)
						
						// retorna o status dos registros na base, legado
						cStatMov := TafRStatEv( cPeriodo, aEventos[Nx][E_MARK] ,aEventos[Nx][E_LEGENDA] ,aEventos[Nx][E_NOME], aFiliais, 2  )
						
						// se estão transmitodos e não tem nada a ser apurado, a apuração é bloqueada
						If cStat == "4" .and. cStatMov == '3'
				    		aEventos[Nx] [E_MARK] := .F.
							cErro	+= STR0014 + " " + aEventos[Nx][3] + " " + STR0120 + CRLF  //"Evento R-XXXX já transmitido, não houveram alterações. A apuração não será realizada."                
			     		else
							nTemApur++
						EndIf 
					else
						nTemApur++
					EndIf	
				else
					nTemApur++
				Endif
			EndIf
		Next 
	
		If nTemApur == 0
			lRet := .F.
		EndIf

	END SEQUENCE	

Return( lRet ) 	
//-------------------------------------------------------------------
/*/{Protheus.doc} GoProc
Distribuição do processamento das apurações
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function GoProc( oProcess, cPeriodo, dDtIni, dDtFim, aEventos, aFiliais, oEventos, oListEvt,oSayEvt,nOpc )
	Local Nx 		as numeric
	Local cEvento	as character
	Local cIdLog	as character
	Local cFuncExec as character
	Local lDemo		as logical
	Local lValid	as logical
	Local cLog		as character
	Local cRetApur	as character

	Private cPerAReinf as character

	Nx 			:= 0
	cEvento		:= ""
	cIdLog		:= ""
	cFuncExec 	:= ""			
	aRotReinf	:= Iif( Type( "aRotReinf" ) == "U", TAFRotinas(,,,5), aRotReinf ) 
	lDemo		:= .T.
	cLog		:= ""
	lValid		:= Left(GetNewPar( "MV_TAFRVLD", "N" ),1) == "S"
	cPerAReinf 	:= cPeriodo
	cRetApur	:= ""

	// if nOpc == 1 .OR. aEventos[Nx][03] == "R-1070" .OR. aEventos[Nx][03] == "R-1000" 
	// 	oProcess:SetRegua1( Len(aEventos) )
	// 	oProcess:SetRegua2( 1 )
	// 	oProcess:IncRegua1( STR0054 ) //"Processando apuração dos eventos"
	// else
	// 	oSayEvt:cCaption := "Processando apuração dos eventos" //"Processando apuração dos eventos"
	// 	ProcessMessages()	
	// EndIf

	For Nx := 1 To Len(aEventos )
		If aEventos[Nx][01]

		if nOpc == 1 .OR. aEventos[Nx][03] == "R-1070" .OR. aEventos[Nx][03] == "R-1000" 
			oProcess:SetRegua1( Len(aEventos) )
			oProcess:SetRegua2( 1 )
			oProcess:IncRegua1( STR0054 ) //"Processando apuração dos eventos"
		else
			oSayEvt:cCaption := "Processando apuração dos eventos" //"Processando apuração dos eventos"
			ProcessMessages()	
		EndIf

			cEvento	:= aEventos[Nx][03] 
			// Busca o Evento no TafRotinas
			nPosEvt := aScan( aRotReinf, {|x| AllTrim(x[04]) == cEvento })
			// Verifica se encontrou e se tem rotina de apuração configurada
			If nPosEvt > 0 .And. Len( aRotReinf[nPosEvt] ) >= 16
				cFuncExec 	:= aRotReinf[nPosEvt][16]
				cAliasProc 	:= aRotReinf[nPosEvt][03]
				// Confirma se a função informada está compilada
				If !Empty( cFuncExec ) .And. FindFunction( cFuncExec ) .And. TAFAlsInDic( cAliasProc )	 	
					cIdLog := TafXLogIni( cIdLog, cEvento )

					if nOpc == 1 .OR. aEventos[Nx][03] == "R-1070" .OR. aEventos[Nx][03] == "R-1000" 
						oProcess:IncRegua1( STR0075 + cEvento   ) // "Processando evento : "
						oProcess:IncRegua2( STR0075 + cEvento   ) // "Processando evento : "
					else
						oSayEvt:cCaption := STR0075 + cEvento  //"Processando evento : "
						ProcessMessages()
					EndIF
					
					cLog +=  cEvento + " - "+Time() + " - "
					// Ponto para Execução de MultiThread por evento
					cRetApur := ""

					if nOpc == 1 .OR. aEventos[Nx][03] == "R-1070" .OR. aEventos[Nx][03] == "R-1000" 
						bFuncExec := &("{ || cRetApur := " +cFuncExec+"( '"+cEvento+ "', '"+ cPeriodo +"',/*dDtIni*/,/*dDtFim*/, @cIdLog , aFiliais , oProcess, lValid ) }")
					else
						bFuncExec := &("{ || cRetApur := " +cFuncExec+"( '"+cEvento+ "', '"+ cPeriodo +"',/*dDtIni*/,/*dDtFim*/, @cIdLog , aFiliais , oSayEvt, lValid ) }")
					EndIF
					eVal( bFuncExec )
					cLog +=  Time() + IIf(!Empty(cRetApur)," - " +cRetApur,"")+CRLF 
					TafXLogFim( cIdLog, aEventos[Nx][03] )
				ElseIf lDemo
					cIdLog := TafXLogIni( cIdLog, cEvento )

					if nOpc == 1 .OR. aEventos[Nx][03] == "R-1070" .OR. aEventos[Nx][03] == "R-1000" 
						oProcess:IncRegua2( cEvento +" - "+aEventos[Nx][04]  )
					else
						oSayEvt:cCaption := cEvento + " - " + aEventos[Nx][04]
						ProcessMessages()
					EndIF
					
					TafXLog( cIdLog, cEvento, "ALERTA"		, "Mensagem de Alerta." )
					TafXLog( cIdLog, cEvento, "ERRO"		, "Mensagem de erro." )
					TafXLog( cIdLog, cEvento, "MSG"			, "Mensagem." )
					TafXLog( cIdLog, cEvento, "CANCEL"		, "Mensagem de cancelado pelo operador." )

					TafXLogFim( cIdLog, aEventos[Nx][03] ) 

				EndIf
			EndIf
		EndIf	
	Next
	If !Empty( cLog )

		cLog 	:= STR0076 +CRLF+STR0077 +CRLF+ cLog // "Visualize os LOGS para maiores detalhes." ## "Evento  -    Inicio    -    Fim" 
		//TafAviso( STR0078,cLog,{"Ok"},3) // "Apuração finalizada"
		Aviso( STR0078,cLog,{"Ok"},3) // "Apuração finalizada"		
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AltVisao
Executa a atualização da tela de apuração, quando alterada a visão via radio button.

@author Bruno Cremaschi
@since 31/10/2018
@version 1.0 

@aParam	

@return
/*/
//-------------------------------------------------------------------
Static Function AltVisao(oLeg ,nOpc, cPeriodo, oEventos, oListEvt , aEventos, aFiliais)

oLeg:FreeChildren()
DrawLegend(oLeg, nOpc)

//SetPeriodo( cPeriodo, oEventos, oListEvt , aEventos, aFiliais, nOpc) 

return


//-------------------------------------------------------------------
/*/{Protheus.doc} TafViewMVC
Executa a chamada do browse padrão pbaseada em um evento.
Necessária a definição da Static Function BrowseDef no Fonte destino.

@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return
/*/
//-------------------------------------------------------------------
Function TafViewMVC( cEvento , cPeriodo ) 

	Local aRotReinf		as array
	Local cFunction		as char
	Local nPosEvt		as numeric
	Local nOpc      	as numeric
	Local cFuncAnt		as character
	
	Private cPerAReinf as character

	Default cEvento		:= ""
	
	cFuncAnt := FunName()
	nOpc := 2 //View

	If cEvento == "R-1000" .OR. cEvento == "R-2099"
	
		If cEvento == "R-1000"
			cFunction := "TAFA494"
		Else
			cFunction := "TAFA496"
		EndIf

		//Protect Data / Log de acesso / Central de Obrigacoes
		Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

	EndIf

	aRotReinf	:= TAFRotinas(,,,5)
	nPosEvt		:= 0
	cPerAReinf 	:= StrTran(cPeriodo,"-","")

	nPosEvt := aScan( aRotReinf, {|x| AllTrim(x[04]) == cEvento })

	If nPosEvt > 0 
		cFuncExec 	:= aRotReinf[nPosEvt][01]
		cAliasProc 	:= aRotReinf[nPosEvt][03]
/*
		Aviso("TafViewMVC",	"Evento :"+cEvento+CRLF+;
							"Alias :"+cAliasProc+CRLF+;
							"Modelo :"+cFuncExec ,;
		{"Ok"})
*/
		If FindFunction( cFuncExec ) .And. TAFAlsInDic( cAliasProc )
			SetFunName(cFuncExec)
			FWMsgRun(,{|| FWLoadBrw( cFuncExec ) },,STR0055+cEvento+"..." ) //"Executando visualização do evento "
			SetFunName(cFuncAnt)
		Else
			Aviso("Reinf",STR0056 + cEvento + STR0057,{"Ok"}) //"Definições de visualização do evento "##" não disponíveis"
		EndIf
	Endif	

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelApur
Executa a chamada do browse padrão pbaseada em um evento.
Necessária a definição da Static Function BrowseDef no Fonte destino.

@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return
/*/
//-------------------------------------------------------------------
Function TafDelApur( cEvento, cPeriodo ) 

	Local aRotReinf		:= TAFRotinas()
	Local nPosEvt		:= 0
	
	Default cEvento		:= ""

	nPosEvt := aScan( aRotReinf, {|x| AllTrim(x[04]) == cEvento })

	Aviso("Exclusão de Apuração","Deseja excluir as apurações efetuadas:" + CRLF + "Evento : "+cEvento ,{"Não"} ) //"Definições de visualização do evento "##" não disponíveis"

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} DrawLegend
Desenha as legendas dos status dos eventos 
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function DrawLegend( oFather, nOpc )

	Local oFont1	:= TFont():New("Tahoma",08,13,,.T.,,,,.T.)
	Local oLeg01 	:= Nil
	Local oLeg02 	:= Nil
	Local oLeg03 	:= Nil
	Local oLeg04	:= Nil
	Local oSay01	:= Nil
	Local oSay02	:= Nil
	Local oSay03	:= Nil
	Local oSay04	:= Nil

	//Realiza a montagem do quadro de legendas, de acordo com a opção selecionada no radio button.
	If nOpc == 1
		oLeg01 := TBitmap():New(001,005,110,010,, LegAccMode( "BR_PRETO" ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
		oLeg02 := TBitmap():New(011,005,110,010,, LegAccMode( "BR_VERDE" ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
			
		oSay01 := TSay():New(002,015,{|| "Não existe movimento para o período" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento não disponível para apuração"
		oSay02 := TSay():New(012,015,{|| "Existe movimento para o período" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento apurado para o período"

	ElseIf nOpc == 2
		oLeg01 := TBitmap():New(001,005,110,010,, LegAccMode( "BR_VERMELHO" ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
		oLeg02 := TBitmap():New(011,005,110,010,, LegAccMode( "BR_AMARELO"  ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
		oLeg03 := TBitmap():New(021,005,110,010,, LegAccMode( "BR_VERDE"    ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
		oLeg04 := TBitmap():New(031,005,110,010,, LegAccMode( "BR_PRETO"    ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)

		oSay01 := TSay():New(002,015,{|| "Evento não apurado" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento não disponível para apuração"
		oSay02 := TSay():New(012,015,{|| "Evento parcialmente apurado" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento apurado para o período"
		oSay03 := TSay():New(022,015,{|| "Evento apurado" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento apurado parcialmente para o período"
		oSay04 := TSay():New(032,015,{|| "Não existe movimento para o período" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento não disponível para apuração"
	ElseIf nOpc == 3
		oLeg01 := TBitmap():New(001,005,110,010,, LegAccMode( "BR_VERMELHO" ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
		oLeg02 := TBitmap():New(011,005,110,010,, LegAccMode( "BR_LARANJA"  ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
		oLeg03 := TBitmap():New(021,005,110,010,, LegAccMode( "BR_AZUL"     ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
		oLeg04 := TBitmap():New(031,005,110,010,, LegAccMode( "BR_PRETO"    ),.T.,oFather,{||},,.F.,.F.,,,.F.,,.T.,,.F.)

		oSay01 := TSay():New(002,015,{|| "Evento não transmitido" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento não disponível para apuração"
		oSay02 := TSay():New(012,015,{|| "Evento transmitido e parcialmente autorizado" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento apurado para o período"
		oSay03 := TSay():New(022,015,{|| "Evento transmitido e autorizado" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento apurado parcialmente para o período"
		oSay04 := TSay():New(032,015,{|| "Evento não elegível para transmissão" }	,oFather,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,,)//"Evento não disponível para apuração"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DrawObs
Desenha as legendas dos status dos eventos 
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function DrawObs( oFather, lHighRes )

	Local oFont1	as object
	Local oFont2	as object
	Local oFont3	as object
	Local aItens	as array
	Local nButt		as numeric
	Local nLinBut	as numeric
	Local nColBut	as numeric
	Local nAltBut	as numeric
	Default lHighRes := .t.

	oFont1	:= TFont():New("Tahoma",08,12,,.T.,,,,.T.)
	oFont2	:= TFont():New("Verdana",08,12,,.T.,,,,.T.)
	oFont3	:= TFont():New("Courier New",09,12,,.T.,,,,.T.)
	nButt	:= 0
	aItens 	:= {}

	if lHighRes
		// Futuramente dinamizar para consultar area do TDN com os links a serem exibidos
		AADD( aItens,{	"Documentação Reinf"+CRLF+"( Clique aqui )",;
						"http://tdn.totvs.com/x/CUKIF" })

		AADD( aItens,{	"FAQ "+CRLF+"Transmitido/Aguardando"+CRLF+"Evento Assinado Reinf"+CRLF+"( Clique aqui )",;
						"http://tdn.totvs.com/x/qcUgFQ" })

		AADD( aItens,{	"FAQ "+CRLF+"Adaptação para"+CRLF+"Versão 1.04.00 - EFD Reinf"+CRLF+"( Clique aqui )",;
						"http://tdn.totvs.com/x/vt9EGQ" })

		AADD( aItens,{	"FAQ "+CRLF+"Migração base de dados"+CRLF+"Homologação / Produção"+CRLF+"( Clique aqui )",;
						"http://tdn.totvs.com/x/i4ScEw" })
	else
		AADD( aItens,{	"Doc.Reinf"+CRLF+"( Clique aqui )",;
						"http://tdn.totvs.com/x/CUKIF" })

		AADD( aItens,{	"FAQ "+CRLF+"Transm./Aguard."+CRLF+"Evt.Assinado"+CRLF+"( Clique aqui )",;
						"http://tdn.totvs.com/x/qcUgFQ" })

		AADD( aItens,{	"FAQ "+CRLF+"Adaptação"+CRLF+"1.04.00 EFD Reinf"+CRLF+"( Clique aqui )",;
						"http://tdn.totvs.com/x/vt9EGQ" })

		AADD( aItens,{	"FAQ "+CRLF+"Migração Homolog."+CRLF+"Produção"+CRLF+"( Clique aqui )",;
						"http://tdn.totvs.com/x/i4ScEw" })
	endif

	nLinBut		:= 012
	nColBut		:= 000
	nAltBut		:= oFather:nClientHeight/3
	
	For nButt := 1 To Len( aItens )
		&("bExec"+StrZero(nButt) ) 		:= &("{ || GoToLink( '"+aItens[nButt][02] +"')}")
		&("oBtLink"+StrZero(nButt) ) 	:= tButton():New(nLinBut, nColBut + 1 , aItens[nButt][01]	,oFather,;
			&("bExec"+StrZero(nButt) )	,(oFather:nClientWidth/2) / Len( aItens ) - 2 ,nAltBut,,/*oFont1*/,,.T.,,,,/*bWhen*/)			
		&("oBtLink"+StrZero(nButt) ):cTooltip := aItens[nButt][02]
		If lHighRes
			&("oBtLink"+StrZero(nButt) ):SETCSS( MyGetCSS( "STYLE_BTN_COMFIRM" ) ) 
		EndIf
		nColBut		+= ( oFather:nClientWidth/2) / Len( aItens )
	Next
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafPeReinf
CArrega o periodo vigente para processamento das apurações
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Function TafPeReinf( cMask )
	Local cPeriodo	:= Space(7)

	Default cMask 	:= ""

	IniVar()

	If TAFAlsInDic( "V1O" ) //.And. TAFVdReinf()
		DBSelectArea("V1O")
		V1O->(DBSetOrder(2)) // V1O_FILIAL, V1O_PERAPU, V1O_ATIVO, R_E_C_N_O_, D_E_L_E_T_
		V1O->(DbGoTop())
		If V1O->(Eof())
			cPeriodo := Posicione("C1E",3, xFilial("C1E") + PadR( SM0->M0_CODFIL, _TmFilTaf ) + "1" , "C1E_INIPER")
			If !Empty( cPeriodo )
				Taf503Grv("", cPeriodo,Date(), Time(), "")
			EndIf	
		Else
			cAlaisP := GetNextAlias()

			BeginSql ALIAS cAlaisP
				SELECT MIN(V1O_PERAPU) V1O_PERAPU FROM %TABLE:V1O%	V1O 
				WHERE V1O_NOMEVE IN ('','R-2098','R2098')
				AND V1O_ATIVO='1'
				AND V1O.%NOTDEL%
			EndSql
			DbSelectArea( cAlaisP )
			If (cAlaisP)->( !Eof() )
				cPeriodo := (cAlaisP)->V1O_PERAPU
			EndIf
		EndIf
	EndIf

	If Empty( cPeriodo )
		cPeriodo := TafProxPer( ,, cMask )
		//cPeriodo := StrZero( nMonth, 2) + "/" + StrZero( nYear, 4 )
	EndIf

	If Len( cperiodo ) == 6
		cPeriodo := Left(cPeriodo,2) + cMask + Right( cperiodo, 4 )
	EndIf
Return( cPeriodo )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafProxPer
Calcula o proximo periodo ou o anterior

@param lnext, logico, Se .T. retorna o proximo periodo, se .F. retorna o periodo anterior
@param cPerAtu, caracter, informe o periodo atual MMAAAA  	

@author Karen Honda
@since 21/02/2018
@version 1.0 

@aParam	

@return cPeriodo
/*/
//-------------------------------------------------------------------
Function TafProxPer(lnext,cPerAtu, cMask)
	Local cPeriodo	:= Space(7)
	Local nMonth	:= Month( Date() )
	Local nYear		:= Year( Date() )

	Default lNext 	:= .F.
	Default cPerAtu := ""
	Default cMask	:= ""
	
	If !Empty(cPerAtu)
		cPerAtu := StrTran(StrTran(cPerAtu,"-",""),"/","")
		
		nMonth := Val(SubStr( cPerAtu,1,2))
		nYear	:= Val(SubStr( cPerAtu,3,4))
	EndIf

	If nMonth > 0 .and. nYear > 0
		If lnext
			If nMonth == 12
				nMonth	:= 1
				nYear++ 
			Else
				nMonth++
			EndIf
		Else
			If nMonth == 1
				nMonth	:= 12
				nYear--
			Else
				nMonth--
			EndIf
		EndIf	
	EndIf	
	cPeriodo := StrZero( nMonth, 2) + cMask + StrZero( nYear, 4 )
	
Return( cPeriodo )


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidFils
Retorna apenas as filiais selecionadas
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Function ValidFils( aFiliais )
	Local nFiliais := 0
	Local aNewFils := {}

	IniVar()

	For nFiliais := 1 To Len( aFiliais )
		If aFiliais[nFiliais][01]
			AADD( aNewFils,{ ;
				Padr(aFiliais[nFiliais][F_C1E_ID	], _TmId ),;
				Padr(aFiliais[nFiliais][F_C1E_FILTAF], _TmFilTaf ),;
				Padr(aFiliais[nFiliais][F_C1E_CODFIL], _TmCodFil ),;
				Padr(aFiliais[nFiliais][F_C1E_NOME  ], _TmNome ),;
				Padr(aFiliais[nFiliais][F_C1E_CNPJ  ],14),;
				Padr(aFiliais[nFiliais][F_C1E_STATUS],30),;
				aFiliais[nFiliais][F_C1E_MATRIZ]} )
		EndIf
	Next nFiliais

Return( aNewFils )


//-------------------------------------------------------------------
/*/{Protheus.doc} TafXRFils
Retorna apenas as filiais selecionadas
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Function TafXRFils( aFiliais , nOpc)
	Local nFiliais := 0
	Local aNewFils := {}

	Default nOpc := 1

	IniVar()
	
	If nOpc == 1
		For nFiliais := 1 To Len( aFiliais )
			If aFiliais[nFiliais][01]
				AADD( aNewFils,{ ;
					Padr(aFiliais[nFiliais][F_C1E_ID	],_TmId		),;
					Padr(aFiliais[nFiliais][F_C1E_FILTAF],_TmFilTaf	),;
					Padr(aFiliais[nFiliais][F_C1E_CODFIL],_TmCodFil	),;
					Padr(aFiliais[nFiliais][F_C1E_NOME  ],_TmNome	),;
					Padr(aFiliais[nFiliais][F_C1E_CNPJ  ],14),;
					Padr(aFiliais[nFiliais][F_C1E_STATUS],30),;
					aFiliais[nFiliais][F_C1E_MATRIZ]} )
			EndIf
		Next nFiliais
	ElseIf nOpc == 2

		For nFiliais := 1 To Len( aFiliais )
			AADD( aNewFils,{ .T., ; 
					Padr(aFiliais[nFiliais][01]	,_TmId		),;
					Padr(aFiliais[nFiliais][02]	,_TmFilTaf	),;
					Padr(aFiliais[nFiliais][03]	,_TmCodFil	),;
					Padr(aFiliais[nFiliais][04]	,_TmNome	),;
					Padr(aFiliais[nFiliais][05]	,14),;
					Padr(aFiliais[nFiliais][06]	,30),;
					.T.,;
					aFiliais[nFiliais][7]} )
		Next nFiliais

	EndIf
Return( aNewFils )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSt2000
Retorna o status de apuração para os eventos R-20XX
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetSt2000( aFiliais, cPeriodo, cEvento , lIdProc, cCNPJC1H, lApur, nTotDoc, lApiReinf,nTotFor, lRetFor )
	
	Local aInfoEUF	as array
	Local cAliasST	as character
	Local cJoinC1HNf as character
	Local cJoinC1HFt as character
	Local nTotOK	as numeric
	Local nTotNo	as numeric
	Local cCondC20	as character
	Local cCondLEM	as character
	Local cWhereC20 as character
	Local cWhereLEM as character
	Local cFils		as character
	
	Local cFilC20	as character
	Local cFilLEM	as character	
	Local cSelectFT	as character
	Local cSelectNF	as character
	Local cChvForn	as character
	Local cOrderBy	as character
	Local cChvDoc	as character
	Local cKeyAtu	as character
	Local cKeyOld	as character
	Local aSelFil   as character
	Local cDataIni  as character
	Local cDataFim  as character

	Default lApiReinf := .F.
	Default lIdProc   := .T.
	Default lRetfor   := .F.
	Default nTotDoc	  := 0
	Default cPeriodo  := ' '
	Default	lApur	  := .F.

	nTotFor := 0

	aInfoEUF 	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	cAliasST	:= GetNextAlias()
	cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	cJoinC1HNf	:= ""
	cJoinC1HFt	:= ""
	nTotOK		:= 0
	nTotNo		:= 0
	cCondC20	:= ""
	cCondLEM	:= ""
	cWhereC20 	:= ""
	cWhereLEM 	:= ""
	cSelectFT	:= ""
	cSelectNF	:= ""
	cChvForn	:= ""
	cOrderBy	:= ""
	cChvDoc		:= ""
	cKeyAtu		:= ""
	cKeyOld		:= ""

	aSelFil		:= ValidFils( aFiliais )
	cFils		:= TafRetFilC("C20",  aSelFil ) //TafRetIn( ValidFils( aFiliais ) ,,"A", .F., 2 )
	cFilC20		:= xFilial("C20")
	cFilLEM		:= xFilial("LEM")
	cCNPJC1H	:= AllTrim(cCNPJC1H)

	cPeriodo := Right(cPeriodo,4)+Left(cPeriodo,2)

	cDataIni := cPeriodo + "01" //ex: 20220201
	cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

	If cEvento == "R-2010"
		cWhereC20 := " C20.C20_INDOPE = '0' AND "
		cWhereLEM := " LEM.LEM_NATTIT = '0' AND "
	ElseIf cEvento == "R-2020"
		cWhereC20 := " C20.C20_INDOPE = '1' AND "
		cWhereLEM := " LEM.LEM_NATTIT = '1' AND "
	EndIf

	If !Empty( cFilC20 )
		cWhereC20 += " C20.C20_FILIAL IN "+cFils+" AND "
	EndIf
	If !Empty( cFilLem )
		cWhereLEM += " LEM.LEM_FILIAL IN "+cFils+" AND "
	EndIf	

	If lIdProc
		cCondC20 := "% "+cWhereC20 +" C20.C20_DTDOC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND C20.C20_PROCID <> '' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') %"
		cCondLEM := "% "+cWhereLEM +" LEM.LEM_DTEMIS BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND LEM.LEM_PROCID <> '' %"
	Else
		cCondC20 := "% "+cWhereC20 +" C20.C20_DTDOC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND C20.C20_PROCID = '' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') %"
		cCondLEM := "% "+cWhereLEM +" LEM.LEM_DTEMIS BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND LEM.LEM_PROCID = '' %"	
	EndIF
	
	IF lRetFor	
		cCondC20 := "% "+cWhereC20 +" C20.C20_DTDOC BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') %"
		cCondLEM := "% "+cWhereLEM +" LEM.LEM_DTEMIS BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "'%"
	EndIf

	cJoinC1HNf := "% " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR AND C1H.C1H_PPES = '2' AND C1H.C1H_CNPJ <> '' AND C1H.C1H_INDDES <> '1' "
	
	if !empty(cCNPJC1H)
		
			if len(cCNPJC1H) == 14
				cJoinC1HNf += " AND C1H.C1H_CNPJ = '" + cCNPJC1H + "'"  
				cJoinC1HNf += " AND (T9C.T9C_TPINSC IS NULL OR (T9C.T9C_INDOBR = '0') OR (T9C.T9C_INDOBR IN ('1','2') AND T9C.T9C_NRINSC LIKE '%SEM CODIGO%' )) "
			else
				cJoinC1HNf += " AND T9C.T9C_NRINSC = '" + cCNPJC1H + "' "
			endIf
	endif
	
	cJoinC1HFt := "% " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = LEM.LEM_IDPART AND C1H.C1H_PPES = '2' AND C1H.C1H_CNPJ <> '' AND C1H.C1H_INDDES <> '1' "	
	
	if !empty(cCNPJC1H)
		if len(cCNPJC1H) == 14
			cJoinC1HFt += " AND C1H.C1H_CNPJ = '" + cCNPJC1H + "'"  
			cJoinC1HFt += " AND (T9C.T9C_TPINSC IS NULL OR (T9C.T9C_INDOBR = '0') OR (T9C.T9C_INDOBR IN ('1','2') AND T9C.T9C_NRINSC LIKE '%SEM CODIGO%' )) "
		else
			cJoinC1HFt += " AND T9C.T9C_NRINSC = '" + cCNPJC1H + "' "
		endIf
	endif

	If cCompC1H == "EEE"
		cJoinC1HNf += " AND C1H.C1H_FILIAL = C20.C20_FILIAL "			
		cJoinC1HFt += " AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "			
	Else
		If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
			cJoinC1HNf += " AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + " = SUBSTRING(C20.C20_FILIAL, 1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" 
			cJoinC1HFt += " AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + " = SUBSTRING(LEM.LEM_FILIAL, 1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" 
		ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
			cJoinC1HNf += " AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + " = SUBSTRING(C20.C20_FILIAL, 1," +  cValToChar(aInfoEUF[1]) + ")" 
			cJoinC1HFt += " AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + " = SUBSTRING(LEM.LEM_FILIAL, 1," +  cValToChar(aInfoEUF[1]) + ")" 
		EndIf
	EndIf

	cJoinC1HNf += " %"
	cJoinC1HFt += " %"

	if lApur
		cSelectNF := "% C20.C20_FILIAL AS FIL, CASE WHEN T9C.T9C_TPINSC IS NULL OR T9C.T9C_INDOBR = '0' THEN C1H.C1H_CNPJ ELSE T9C.T9C_NRINSC END AS CNPJ,  C20.C20_CHVNF AS CHVNF, T9C.T9C_TPINSC AS TPINSC, %"
		cSelectFT := "% LEM.LEM_FILIAL FIL, CASE WHEN T9C.T9C_TPINSC IS NULL OR T9C.T9C_INDOBR = '0' THEN C1H.C1H_CNPJ ELSE T9C.T9C_NRINSC END AS CNPJ, LEM.LEM_NUMERO||LEM.LEM_PREFIX AS CHVNF, T9C.T9C_TPINSC AS TPINSC, %" 
	
		if lApiReinf
			cOrderBy  := "% CNPJ %"
		else
			cOrderBy  := "% FIL, CNPJ %"
		endif
	else
		cSelectNF := "% COUNT(*) TOTAL,  %"			
		cSelectFT := "% COUNT(*) TOTAL,  %"
		cOrderBy  := "% TOTAL %"	
	endif

	BeginSql ALIAS cAliasST
	
		SELECT 
			%Exp:cSelectNF%
			'NFS' AS ROTINA
		FROM %table:C20% C20
		INNER JOIN %table:C30% C30 ON C20.C20_FILIAL = C30_FILIAL
			AND C20.C20_CHVNF = C30.C30_CHVNF
			AND C30.C30_IDTSER <> '' AND C30.C30_TPREPA = ''
			AND C30.%NotDel%
		INNER JOIN %table:C35% C35 ON C30.C30_FILIAL = C35_FILIAL
			AND C30.C30_CHVNF = C35.C35_CHVNF
			AND C30.C30_NUMITE = C35.C35_NUMITE
			AND C30.C30_CODITE = C35.C35_CODITE  
			AND C35.C35_CODTRI = '000013'
			AND C35.%NotDel%
		LEFT JOIN %table:T9C% T9C ON T9C.T9C_ID = C20.C20_IDOBR
			AND T9C.%NotDel%
		INNER JOIN 
			%Exp:cJoinC1HNf% 
			AND C1H.%NotDel%
		WHERE C20.%NotDel%
			AND %Exp:cCondC20% 

	UNION ALL
	
		SELECT 
			%Exp:cSelectFT%
			'FAT' AS ROTINA
			FROM %table:LEM% LEM
		INNER JOIN %table:T5M% T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL
			AND T5M.T5M_ID = LEM.LEM_ID
			AND T5M.T5M_IDPART = LEM.LEM_IDPART
			AND T5M.T5M_NUMFAT = LEM.LEM_NUMERO
			AND T5M.T5M_BSINSS > 0 AND T5M.T5M_TPREPA = ''
			AND T5M.T5M_IDTSER <> ''
			AND T5M.%NotDel%
		LEFT JOIN %table:T9C% T9C ON T9C.T9C_FILIAL = LEM.LEM_FILIAL
			AND T9C.T9C_ID = LEM.LEM_IDOBRA
			AND T9C.%NotDel%
		INNER JOIN
			%Exp:cJoinC1HFt% 
			AND C1H.%NotDel%
		WHERE LEM.LEM_DOCORI = ' '
			AND %Exp:cCondLEM% 
			AND LEM.%NotDel%
		ORDER BY %Exp:cOrderBy% 
	EndSql			

	DbSelectArea(cAliasST)
	(cAliasST)->(DbGoTop())
	if !lApur
		While (cAliasST)->(!Eof())
			nTotOK += (cAliasST)->TOTAL
			(cAliasST)->(DbSkip())
		EndDo
	
	elseif lApiReinf
		While (cAliasST)->(!Eof())
			cKeyAtu := FWSM0Util():GetSM0Data( cEmpAnt , (cAliasST)->(FIL) , { "M0_CGC" } )[1][2] + (cAliasST)->(CNPJ)			
			If cKeyOld <> cKeyAtu	
				cKeyOld := cKeyAtu
				nTotOK ++
			Endif

			if cChvForn <> (cAliasST)->(CNPJ) 
				nTotFor++
			endif

			if cChvDoc	<> (cAliasST)->(FIL+CHVNF)
				nTotDoc++
			endif

			cChvForn := (cAliasST)->(CNPJ)
			cChvDoc := (cAliasST)->(FIL+CHVNF)
			(cAliasST)->(dbSkip())
		EndDo
	else
		While (cAliasST)->(!Eof())
			if cChvForn <> (cAliasST)->(FIL+CNPJ)
				nTotOK ++
			endif
			
			if cChvDoc	<> (cAliasST)->(FIL+CHVNF)
				nTotDoc++
			endif

			cChvDoc := (cAliasST)->(FIL+CHVNF)
			cChvForn := (cAliasST)->(FIL+CNPJ)

			(cAliasST)->(DbSkip())
		EndDo
	endif 
	(cAliasST)->(DbCloseArea())
Return( nTotOK )


//-------------------------------------------------------------------
/*/{Protheus.doc} RetSt1050
Retorna o status de apuração para os eventos R-1050
@author Rafael de Paula Leme
@since 10/11/2022
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetSt1050( aFiliais, cPeriodo, cEvento , lAgltProc )
	Local cAliasST	as Character
	Local cSelect	as Character
	Local cFrom		as Character
	Local cWhere 	as Character
	Local cFilsV3X	as Character
	Local nTotOK	as Numeric
	Local nTotNo	as Numeric
	Local nTotAut	as Numeric
	Local aSelFils  as Array


	cAliasST := GetNextAlias()
	nTotOK	 := 0
	nTotNo	 := 0
	nTotAut  := 0 
	cSelect	 := ""
	cFrom	 := ""
	cWhere 	 := ""
	aSelFils := ValidFils(aFiliais)
	cFilsV3X := TafRetFilC("V3X", aSelFils )
	
	cSelect	+= " DISTINCT V3X.V3X_FILIAL, V3X.V3X_CNPJ, V3X.V3X_PROCID "
	cFrom   += RetSqlName( "V3X" ) + " V3X "
	cWhere	+= " V3X.V3X_ATIVO IN (' ', '1')"
	cWhere	+= " AND V3X.D_E_L_E_T_ = ' ' "
	cWhere  += " AND V3X.V3X_FILIAL = '" + xFilial('V3X') +"'"
	
	cSelect		:= "%" + cSelect 	+ "%"
	cFrom  		:= "%" + cFrom   	+ "%"
	cWhere 		:= "%" + cWhere  	+ "%"

	BeginSql Alias cAliasST
		SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %EXP:cWhere%
	EndSql

	DbSelectArea(cAliasST)
	(cAliasST)->(DbGoTop())
	
	While (cAliasST)->(!Eof())
		If !Empty((cAliasST)->V3X_PROCID)
			nTotOK++
		Else
			nTotNo++
		EndIf

		(cAliasST)->(DbSkip())
	EndDo 
	
	(cAliasST)->(DbCloseArea())


Return( {nTotOK, nTotNo, nTotAut } )	

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSt1070
Retorna o status de apuração para os eventos R-1070
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetSt1070( aFiliais, cPeriodo, cEvento , lAgltProc )
	Local cAliasST	as character
	Local cAliasT9V	as character
	Local cSelect	as character
	Local cFrom		as character
	Local cWhere 	as character
	Local cWhereT9V	as character
	Local cFils		as character
	Local cProcAnt	as character
	Local nTotOK	as numeric
	Local nTotNo	as numeric
	Local nTotAut	as numeric
	Local aSelFils 	as array

	default lAgltProc := .F. //Aglutina os registros por número de processo

	aSelFils 	:= ValidFils(aFiliais)
	cAliasST	:= GetNextAlias()
	cAliasT9V	:= GetNextAlias()
	nTotOK		:= 0
	nTotNo		:= 0
	nTotAut		:= 0
	cSelect		:= ""
	cFrom		:= ""
	cWhere 		:= ""
	cWhereT9V 	:= ""
	//cFils 		:= TafRetIn( ValidFils( aFiliais ) ,,"A", .F., 2 )
	cFilC1G		:= xFilial("C1G")
	cProcAnt	:= ""

	cSelect	:= " DISTINCT C1G_FILIAL, C1G_PROCID "
	if lAgltProc
		cSelect += ", C1G_NUMPRO"
	EndIf
	
 	cFrom		:= RetSqlName( "C1G" ) + " C1G " 
	cFrom		+= " INNER JOIN " + RetSqlName( "T5L" ) + " T5L "
	cFrom		+= "  ON T5L.T5L_ID = C1G.C1G_ID "
	cFrom		+= " AND T5L.T5L_VERSAO = C1G.C1G_VERSAO "	
	cFrom		+= " AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "
	cFrom		+= " AND T5L.D_E_L_E_T_ = ' '"
	 
	cFrom		+= " LEFT JOIN " + RetSqlName( "C09" ) + " C09 "
	cFrom		+= "  ON C09.C09_ID = C1G.C1G_UFVARA "
	cFrom		+= " AND C09.C09_FILIAL = '' "
	cFrom		+= " AND C09.D_E_L_E_T_ = ' ' "
	
	cFrom		+= " LEFT JOIN  " + RetSqlName( "C07" ) + " C07 "
	cFrom		+= "  ON C07.C07_ID = C1G.C1G_CODMUN "
	cFrom		+= " AND C07.C07_FILIAL = '' "
	cFrom		+= " AND C07.D_E_L_E_T_ = ' ' "
		 
	cFrom		+= " LEFT JOIN " + RetSqlName( "C8S" ) + " C8S "
	cFrom		+= "  ON C8S.C8S_ID = T5L.T5L_INDDEC "
	cFrom		+= " AND C8S.C8S_FILIAL = '' " 
	cFrom		+= " AND C8S.D_E_L_E_T_ = ' ' "
	
	cWhere		:= " C1G.C1G_ATIVO IN (' ', '1') AND C1G.D_E_L_E_T_ = ' ' "
	If !Empty(cFilC1G)
		cFils := TafRetFilC("C1G", aSelFils)
		
		cWhere		+= " AND C1G.C1G_FILIAL IN " + cFils + " "
		cWhereT9V	+= " AND T9V.T9V_FILIAL IN " + cFils + " "
	EndIf
	cWhere		+= " AND C1G.C1G_ESOCIA = '' "
	
	cSelect		:= "%" + cSelect 	+ "%"
	cFrom  		:= "%" + cFrom   	+ "%"
	cWhere 		:= "%" + cWhere  	+ "%"
	cWhereT9V 	:= "%" + cWhereT9V 	+ "%"

	BeginSql Alias cAliasST
		SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %EXP:cWhere%
	EndSql
	DbSelectArea(cAliasST)
	(cAliasST)->(DbGoTop())
	
	While (cAliasST)->(!Eof())
		if !lAgltProc
			If !Empty((cAliasST)->C1G_PROCID)
				nTotOK++
			Else
				nTotNo++
			EndIf
		else
			If !Empty((cAliasST)->C1G_PROCID)
				if (cAliasST)->C1G_NUMPRO <> cProcAnt
					nTotOK++
				endif
			Else
				if (cAliasST)->C1G_NUMPRO <> cProcAnt
					nTotNo++
				endif
			EndIf
			
			cProcAnt := (cAliasST)->C1G_NUMPRO
		endif

		(cAliasST)->(DbSkip())
	EndDo 
	(cAliasST)->(DbCloseArea())


	BeginSql Alias cAliasT9V
		SELECT T9V_STATUS FROM %table:T9V% T9V
		WHERE T9V.%NotDel%
		AND T9V_ATIVO = '1'
		AND T9V_STATUS ='4'
		%EXP:cWhereT9V%	
	EndSql
	DbSelectArea(cAliasT9V)
	(cAliasT9V)->(DbGoTop())
	
	While (cAliasT9V)->(!Eof())
			nTotAut++
		(cAliasT9V)->(DbSkip())
	EndDo 
	(cAliasT9V)->(DbCloseArea())


Return( {nTotOK, nTotNo, nTotAut } )	


//-------------------------------------------------------------------
/*/{Protheus.doc} RetSt1000
Retorna o status de apuração para os eventos R-1000
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetSt1000( aFiliais, nOpc, nRetOk, nRetNo)

	Local cRet 		as character
	Local cKeyT9U	as character
	Local nTamFil 	as numeric
	Local cProcID 	as character
	Local lMov		as logical
	Local aAreaT9U	as Array

	default nRetOk	:= 0
	default nRetNo	:= 0

	IniVar()

	cRet 		:= "1"
	cKeyT9U		:= ""
	nTamFil 	:= _TmFilTaf
	cProcId 	:= ""
	aAreaT9U	:= T9U->(GetArea())
	lMov		:= .F.

	DBSelectArea("C1E")
	C1E->( DBSetOrder(3) )
	If C1E->( DbSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, nTamFil ) + "1" ) )
		cKeyT9U := xFilial("C1E") + C1E->C1E_ID + C1E->C1E_ATIVO
		cProcID	:= C1E->C1E_PROCID
		if !Empty(cProcID)
			nRetOk	+=  1
		else
			nRetNo	+=	1
		endif
		lMov := .T.
	EndIf
	
	//Verifica o status pela visão selecionada na tela.
	//nOpc = 1-Movimentações
	//nOpc = 2-Apurações
	//nOpc = 3-Transmissões
	If nOpc == 1 .And. lMov //Possui Movimento
		cRet := "3"
	ElseIf (nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 3) .And. !lMov //Sem Movimento
		cRet := "5"
	ElseIf nOpc == 2 .And. lMov .And. Empty( cProcID ) //Não Apurado//Não Transmitido
		cRet := "1"
	ElseIf nOpc == 2 .And. lMov .And. !Empty( cProcID ) 
		DBSelectArea("T9U")
		T9U->( DBSetOrder(3) ) // T9U->T9U_FILIAL + T9U->T9U_ID + T9U->T9U_VERSAO
		If T9U->( DbSeek( cKeyT9U ))
			If T9U->T9U_STATUS $ "23" //Apurado
				cRet := "3"
			Else
				If Empty(T9U->T9U_PROTUL) .And. T9U->T9U_STATUS $ " 0" 
					cRet := "3" //Apurado
				ElseIf !Empty(T9U->T9U_PROTUL) .And. T9U->T9U_STATUS $ "4"
					cRet := "3" //Apurado
				Else
					cRet := "2" //Apurado Parcialmente
				Endif
			EndIf
		Endif
	ElseIf nOpc == 3 .And. lMov
		DBSelectArea("T9U")
		T9U->( DBSetOrder(3) ) // T9U->T9U_FILIAL + T9U->T9U_ID + T9U->T9U_VERSAO
		If T9U->( DbSeek( cKeyT9U ))
			If T9U->T9U_STATUS $ "4" //Transmitido
				cRet := "4"
			ElseIf !(T9U->T9U_STATUS $ "4") //Não Transmitido
				cRet := "1"
			EndIf			
		EndIf
	EndIf

	RestArea(aAreaT9U)

Return( cRet ) 




//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVdReinf
Verifica a estrutura necessária para apuração REINF
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Function TAFVdReinf( lMsg, cFunction, cMsg )
	Local lRet 	as logical
	Local Nx	as numeric	
	Local cErro as character
	Local aEnt	as array
	
	Default lMsg		:= .T.
	Default cFunction	:= ""
	Default cMsg		:= ""

	lRet             := .T.
	Nx               := 0
	cErro            := ""
	aEnt             := {}
	__cEvtTot        := GetTotalizerEventCode("evtTot")
	__cEvtTotContrib := GetTotalizerEventCode("evtTotContrib")

	AADD(aEnt,{"C20","Documento Fiscal"})
	AADD(aEnt,{"LEM","Fatura/Recibo"})
	AADD(aEnt,{"C5M","CPRB"}) 
	AADD(aEnt,{"T9F","Boletim de atividade Desportiva"})

	AADD(aEnt,{"V0B", "R-2099-Fechamento de Período"})
	AADD(aEnt,{"V1A", "R-2098-Reabertura de Período"})
	AADD(aEnt,{"V0W", __cEvtTot + "-Totalizadores por Evento"})
	AADD(aEnt,{"V0C", __cEvtTotContrib + "-Totalizadores por Período"})
	AADD(aEnt,{"V1O", "Períodos EFD REINF"})
	
	If !TafColumnPos("C1E_INIPER")
		cErro +=  "Estrutura da tabela C1E está desatualizada."+CRLF+"Aplique as atualizações de dicionário para Reinf."+CRLF
	EndIf
	
	aRotReinf := Iif( Type( "aRotReinf" ) == "U", TafRotinas(,,,5) , aRotReinf  )

	For Nx := 1 To Len( aRotReinf )
		If !Empty( aRotReinf[Nx][04] ) .And. Alltrim( aRotReinf[Nx][04] ) $ "R-1000|R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-9000"
			If !TAFAlsInDic(aRotReinf[Nx][03])
				cErro +=  STR0064 +aRotReinf[Nx][03] +CRLF // "Tabela não Encontrada : "
			EndIf
		EndIf	
	Next

	If !TafColumnPos("V0W_CRTOM") .Or. !TafColumnPos("V0H_CRRECR") 
		//cErro +=  "Estruturas dos totalizadores 'R-9001' e 'R-9011' estão desatualizadas."+CRLF+"Aplique as atualizações de dicionário para Reinf."+CRLF
		// Habilitar com a expedição do dicionário depois de 04/06/2018
		Aviso("Atenção","Estruturas dos totalizadores '" + __cEvtTot +  "' e '" + __cEvtTotContrib + "' estão desatualizadas."+CRLF+"Aplique as atualizações de dicionário para Reinf.",{"Ok"})
	EndIf

	// Testa o modo de acesso das tabelas de documentos
	For Nx := 1  To Len( aEnt )
		cEnt := FWModeAccess( aEnt[Nx][01],1)+FWModeAccess( aEnt[Nx][01],2)+FWModeAccess( aEnt[Nx][01],3)
		If cEnt <> "EEE"
			cErro += "Tabela ["+aEnt[Nx][01] +"-"+aEnt[Nx][02]+"] deve obrigatoriamente ser exclusiva em todos os níveis."+CRLF
		EndIf
	Next

	If lMsg .And. !Empty(cErro)
		cMsg001 := STR0065
		cMsg002 := STR0066

		If !Empty( cFunction )
			cMsg001 := StrTran( cMsg002, "a Apuração Reinf", cFunction )
		EndIf
		If !Empty( cMsg )
			cMsg002 := StrTran( cMsg002, "a Apuração Reinf", cMsg )
		EndIf
		Aviso(cMsg001,cMsg002+CRLF+; //"Apuração Reinf Indisponível"###"Foram encontradas Inconsistencias que impedem a Apuração Reinf."
			STR0067+CRLF+cErro,{"Ok"},3) //"Corrija os erros apontados:"
		lret := .F.
	EndIf
Return( lRet )




//-------------------------------------------------------------------
/*/{Protheus.doc} TafRetIn
Função que retorna string IN pra usar em query.
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Function TafRetIn( uDado , cPipe, cTipo, lAllTrim , nPos ) 
	Local cRet 		as character
	Local cParRet 	as character
	Local Nx 		as numeric
	Default uDado	:= ""
	Default cTipo 	:= ValType( uDado )
	Default cPipe 	:= ","
	Default nPos	:= 1
	Default lAllTrim:= .F.	

	cRet := ""

	If cTipo == "A" 
		
		For Nx := 1 To Len( uDado )
			cParRet := AllToChar( uDado[Nx][nPos] )
			If lAllTrim
				cParRet := AllTrim( cParRet )
			EndIf
			cRet += "'" + cParRet + "'"
			If Nx < Len( uDado )
				cRet += ","
			EndIf
		Next
		cRet := "("+cRet+")"
	ElseIf cTipo == "C"
		cRet := FormatIn( uDado, cPipe )
	EndIf

Return( cRet )

/*
Vazio = Aguardando validação do TAF.
// Delete
0 = Registro validado pelo TAF - Aguardando transmissão ao Governo.
1 = Registro com inconsistências encontradas pelo TAF - Não será enviado ao Governo.
3 = Registro com inconsistências retornadas pelo Governo.
--Se tiver protocolo anterior, deve restaurar

// Aguarde
2 = Registro já transmitido ao Governo, aguardando retorno.
6 = Exclusão transmitida ao Governo, aguardando retorno.

// Gera Exclusão
4 = Registro transmitido ao Governo com retorno consistente.
7 = Exclusão transmitida ao Governo com retorno consistente.

*/

//-------------------------------------------------------------------
/*/{Protheus.doc} MyGetCSS 
Função responsavel por retornar o CSS do objeto passado por 
parametro de acordo com o tema setado
Referencia à função SmallAppGetCSS()

@param Id do css do objeto para retorno do CSS  

@return CSS do componente passado por parametro

@author  Roberto Souza
@since   14/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MyGetCSS( cCSS )

	Local cRet as character

	cRet := ""

	Do Case
		Case cCSS == "STYLE0001"
			If GetRemoteType() == 5
				cRet := "input { color: #004b78; "+;
								" border-style: solid; "+;
								" border-width: 2px } "
			Else
				cRet := "QLineEdit {	color: #ffffff } "+;
						"QLineEdit {			border-style: solid } "+;
						"QLineEdit {			border-image: url(rpo:TafSmallApp_DarkBorderBlk.png) 6 6 6 6 stretch }"+;		
						"QLineEdit {			border-width: 6px }"+;
						"QLineEdit:hover { 		color: #ffffff } "+;
						"QLineEdit:hover { 		border-style: solid } "+;
						"QLineEdit:hover {		border-image: url(rpo:TafSmallApp_DarkBorderBlkOver.png) 6 6 6 6 stretch }"+;		
						"QLineEdit:hover {		border-width: 6px }"+;
						"QLineEdit:focus { 		color: #ffffff } "+;
						"QLineEdit:focus { 		border-style: solid } "+;
						"QLineEdit:focus {		border-image: url(rpo:TafSmallApp_DarkBorderBlkFocus.png) 6 6 6 6 stretch }"+;		
						"QLineEdit:focus {		border-width: 6px }"  
			EndIf 
			
		Case cCSS == "STYLE0002"
			If GetRemoteType() == 5
				cRet := "img { display:none; } "+;
						"input { border-width: 1px; "+;
							"border-style: solid; "+; 
							"border-color: #ced7de; "+;
							"border-radius: 5px 5px 5px 5px; "+;
							"background-color: #f7f7ff; "+;
							"background-image: url(rpo:button_2.png); "+;
							"color: #4e6195 }"
			Else
				cRet := "QPushButton {	color: #4e6195 } "+;
						"QPushButton { 			border-style: solid } "+;                           	
						"QPushButton {			border-image: url(rpo:TafSmallApp_DarkBorderBl.png) 9 9 9 9 stretch }"+;		
						"QPushButton {			border-width: 9px }"+;
						"QPushButton:hover { 	color: #000000 } "+;
						"QPushButton:hover { 	border-style: solid } "+;
						"QPushButton:hover {	border-image: url(rpo:TafSmallApp_DarkBorderBlFocus.png) 9 9 9 9 stretch }"+;		
						"QPushButton:hover {	border-width: 9px }"+;
						"QPushButton:focus { 	color: #000000 } "+;
						"QPushButton:focus { 	border-style: solid } "+;
						"QPushButton:focus {	border-image: url(rpo:TafSmallApp_DarkBorderBlFocus.png) 9 9 9 9 stretch }"+;		
						"QPushButton:focus {	border-width: 9px }"+;
						"QPushButton:pressed { 	color: #000000 } "+;
						"QPushButton:pressed { 	border-style: solid } "+;
						"QPushButton:pressed {	border-image: url(rpo:TafSmallApp_DarkBorderBlFocus.png) 9 9 9 9 stretch }"+;		
						"QPushButton:pressed {	border-width: 9px }" 
			EndIf
			
		Case cCSS == "STYLE_COMBOBOX"
			If GetRemoteType() == 5
				cRet := "{ border-width: 2px; "+;
							"border-style: solid; "+; 
							"border-color: #e6e6e6; "+;
							"border-radius: 5px 5px 5px 5px; "+;
							"background-repeat: repeat-y; "+;
							"background-image: url(rpo:TafSmallApp_SetaScroll.png); "+;
							"background-position: right; "+;
							"color: #000000; "+;
							"height: 26px }"
						
			Else
				cRet := "QComboBox{color:#000000;"+;
								" border-style:solid;"+;
								" border-width:9px;"+;
								" background-position:right;"+;
								" min-height:12px;"+;
								" padding-right:5px;"+;
								" border-image:url(rpo:cssComBobox.png) 9 9 17 9 stretch;}"+;
						"QComboBox::down-arrow{image:url(rpo:TafSmallApp_SetaScroll.png);}"+;
						"QComboBox:content{border-image:url(rpo:cssComBobox.png) 9 9 9 9 stretch}"+;
						"QComboBox::down-arrow:on{top:1px;left: 1px;}"+;
						"QComboBox::drop-down{subcontrol-origin:padding;"+;
								" subcontrol-position:top right;"+;
								" width:15px;"+;
								" border-left-width:1px;"+;
								" border-left-color:darkgray;"+;
								" border-left-style:solid;"+;
								" border-top-right-radius:3px;"+;
								" border-bottom-right-radius:3px;}"+;
						"QComboBox QListView{background-color:#fff;}" 
			EndIf  
			
		Case cCSS == "STYLE_BTN_COMFIRM"
			If GetRemoteType() == 5
				cRet := "img { display:none; } "+;
						"input { border-width: 1px; "+;
								"border-style: solid; "+; 
								"border-color: #aeaeae; "+;
								"border-radius: 5px 5px 5px 5px; "+;
								"color: #000000; "+;
								"background-image: url(rpo:button_confirm.png) }"
						
			Else
				cRet := "QPushButton {			color: #000000 } "+;
						"QPushButton { 			border-style: solid } "+;                           	
						"QPushButton {			border-image: url(rpo:TafSmallApp_cssBtnConfirm.png) 10 10 10 10 stretch }"+;		
						"QPushButton {			border-width: 10px }"+;
						"QPushButton:hover { 	color: #000000 } "+;
						"QPushButton:hover {	border-style: solid } "+;                           	
						"QPushButton:hover {	border-image: url(rpo:TafSmallApp_cssBtnConfirm.png) 10 10 10 10 stretch }"+;		
						"QPushButton:focus { 	color: #000000 } "+;
						"QPushButton:focus { 	border-style: solid } "+;
						"QPushButton:focus {	border-image: url(rpo:TafSmallApp_cssBtnConfirm.png) 10 10 10 10 stretch }"+;		
						"QPushButton:focus {	border-width: 10px }"
			EndIf    

		Case cCSS == "STYLE_BTN"
			If GetRemoteType() == 5
				cRet := "input { color: #FFFFFF; "+;
								"background-image: url(rpo:button_back3.png) }"  
								
			Else
				cRet := "QPushButton {			color: #FFFFFF } "+;
						"QPushButton { 			padding-top: 2px } "+;
						"QPushButton { 			border-style: solid } "+;                           	
						"QPushButton {			border-image: url(rpo:TafSmallApp_cssBtn.png) 15 15 15 15 stretch }"+;		
						"QPushButton {			border-width: 15px }"+;
						"QPushButton:hover { 	color: #FFFFFF } "+;
						"QPushButton:hover {	border-style: solid } "+;                           	
						"QPushButton:hover {	border-image: url(rpo:TafSmallApp_cssBtnOver.png) 15 15 15 15 stretch }"+;		
						"QPushButton:hover {	border-width: 15px }"+;
						"QPushButton:focus { 	color: #FFFFFF } "+;
						"QPushButton:focus { 	border-style: solid } "+;
						"QPushButton:focus {	border-image: url(rpo:TafSmallApp_cssBtnClick.png) 15 15 15 15 stretch }"+;		
						"QPushButton:focus {	border-width: 15px }"
			EndIf 
			
		Case cCSS == "STYLE_SUBMENU_BTN"
			If GetRemoteType() == 5
				cRet := "input { color: #264162; "+;
								"background-image: url(rpo:TafSmallApp_bg_submenu.png) }"  
								
			Else
				cRet := "QPushButton {			color: #264162 }"+;
						"QPushButton {			border-image: url(rpo:TafSmallApp_bg_submenu.png) stretch } "+;
						"QPushButton:hover {	text-decoration: underline }"
			EndIf		
			
		Case cCSS == "STYLE_BTN_CLOSE"
			If GetRemoteType() == 5
				cRet := "input { color: #FFFFFF; "+;
								"background-image: url(rpo:button_back3.png) }"
								
			Else

				cRet := "QPushButton {			color: #FFFFFF } "+;
						"QPushButton { 			padding-top: 2px } "+;
						"QPushButton { 			border-style: solid } "+;
						"QPushButton {			border-image: url(rpo:TafSmallApp_cssGet.png) 15 15 15 15 stretch }"+;						
						"QPushButton {			border-width: 15px }"+;
						"QPushButton:hover { 	color: #FFFFFF } "+;
						"QPushButton:hover {	border-style: solid } "+;                           	
						"QPushButton:hover {	border-image: url(rpo:TafSmallApp_cssBtnOver.png) 15 15 15 15 stretch }"+;		
						"QPushButton:hover {	border-width: 15px }"+;
						"QPushButton:focus { 	color: #FFFFFF } "+;
						"QPushButton:focus { 	border-style: solid } "+;
						"QPushButton:focus {	border-image: url(rpo:TafSmallApp_cssBtnClick.png) 15 15 15 15 stretch }"+;		
						"QPushButton:focus {	border-width: 15px }"

			EndIf  
			
		Case cCSS == "GENERAL_PANEL"
			If GetRemoteType() == 5
				cRet := "input {  border-style: solid; "+;
								" border-width: 0px } "
			EndIf  
			
		Case cCSS == "SMALL_DROPDOWN_BUTTON"

				cRet := "QPushButton {			color: #000000 } "+;
								"QPushButton { 			border-style: solid } "+;                           	
								"QPushButton {			border-image: url(rpo:TafSmallApp_cssBtnConfirm.png) 10 10 10 10 stretch }"+;		
								"QPushButton {			border-width: 10px }"+;
								"QPushButton:hover { 	color: #000000 } "+;
								"QPushButton:hover {	border-style: solid } "+;                           	
								"QPushButton:hover {	border-image: url(rpo:TafSmallApp_cssBtnConfirm.png) 10 10 10 10 stretch }"+;		
								"QPushButton:hover {	border-width: 10px }"+;
								"QPushButton:focus { 	color: #000000 } "+;
								"QPushButton:focus { 	border-style: solid } "+;
								"QPushButton:focus {	border-image: url(rpo:TafSmallApp_cssBtnConfirm.png) 10 10 10 10 stretch }"+;		
								"QPushButton:focus {	border-width: 10px }"+;
							"QPushButton:menu-indicator{ image:url(rpo:small_dropdown_seta.png); "+;
							"    subcontrol-position:right; "+;
							"    subcontrol-origin:padding; "+;
							"    left:-2px; }"
			
		Case cCSS == "SMALL_DROPDOWN_BUTTON_MENU"

				cRet := "QMenu { border-style: none;background-color: #f3f3f3; }"+;
							"QMenu::item:selected{color: #000000;text-decoration: underline;}"+;
							"QMenu::item { background-color:transparent; padding: 2px 6px 2px 6px;}"					
			
		OtherWise
			cRet := ""
	EndCase

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSt2050
Retorna o status de apuração para os eventos R-2050
@author anieli.rodrigues
@since 27/03/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetSt2050(aFiliais, cPeriodo, cEvento , lIdProc, lApur, lGetStatus, cCNPJC1H, nTotDoc, lApi)

	Local aSelFils	as array
	Local cAliasST	as character
	Local cQuery	as character
	Local cChvTst	as character
	Local cChvForn	as character
	Local nTotOK	as numeric
	Local nTotNo	as numeric
	
	Default lIdProc := .T.
	Default	lApur	:=	.f.
	Default lGetStatus	:=	.f.
	Default nTotDoc	:= 0

	aSelFils 	:= ValidFils(aFiliais)
	cAliasST	:= GetNextAlias()
	cPeriodo 	:= Right(cPeriodo,4)+Left(cPeriodo,2)
	cQuery		:= "%" + Qury2050(cPeriodo, lApur, lIdProc, aSelFils, lGetStatus, cCNPJC1H) + "%"
	cChvTst		:= ""
	cFilAux		:= ""
	cChvForn	:= ""
	nTotOK		:= 0
	nTotNo		:= 0
	
	BeginSql Alias cAliasST
		SELECT
		%EXP:cQuery%	
	EndSql

	DbSelectArea(cAliasST)
	(cAliasST)->(DbGoTop())
	if !lApur
		While (cAliasST)->(!Eof())
			nTotOK += (cAliasST)->TOTAL
			(cAliasST)->(DbSkip())
		EndDo 
	else
		While (cAliasST)->(!Eof())
			if lApi
				nTotOk := HndlTotDoc(cAliasST, aFiliais, @nTotDoc)
			else
				if cChvTst	<> (cAliasST)->(FIL+CHVNF)
					nTotOK++
				endif
			EndIf

			cChvTst := (cAliasST)->(FIL+CHVNF)
			(cAliasST)->(DbSkip())
		EndDo 
	endif

	(cAliasST)->(DbCloseArea())
Return( nTotOK )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSt2055
Retorna o status de apuração para os eventos R-2055
@author Denis Souza
@since 28/01/2021
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetSt2055(aFiliais, cPeriodo, cEvento , lIdProc, lApur, lGetStatus, nTotDoc, lApi)

Local aSelFils	as Array
Local cAliasST	as Character
Local cQuery	as Character
Local cQueryC20	as Character
Local cQueryLEM	as Character
Local aInfoEUF	as Array
Local cCompC1H	as Character
Local cFiliais	as Character
Local cBd		as Character
Local cConcat   as Character
Local cGrpByC1H as Character
Local nTotFor	as Numeric

Default lIdProc 	:= .T.
Default	lApur		:= .F.
Default lGetStatus	:= .F.
Default nTotDoc		:= 0

aSelFils := ValidFils(aFiliais)
cAliasST := GetNextAlias()
cPeriodo := Right(cPeriodo,4)+Left(cPeriodo,2)
nTotFor  := 0
//cQuery	 := "%" + Qury2055(cPeriodo, lApur, lIdProc, aSelFils, lGetStatus) + "%"

aInfoEUF := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
cCompC1H := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cFiliais := TafRetFilC("C20", aSelFils) 
cBd 	 := TcGetDb()

cQueryC20 := ""
cQueryLEM := ""

cQueryC20 +=  " FROM " + RetSqlName( 'C20' ) + " C20"
cQueryC20 += " INNER JOIN " + RetSqlName( 'C1H' ) + " C1H ON "
If cCompC1H == "EEE"
	cQueryC20 += " C1H.C1H_FILIAL = C20.C20_FILIAL "			
Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQueryC20 += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
		ElseIf cBd $ "INFORMIX"
			cQueryC20 += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] = C20.C20_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] "
		Else
			cQueryC20 += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
		EndIf
	ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQueryC20 += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
		ElseIf cBd $ "INFORMIX"
			cQueryC20 += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] = C20.C20_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] "
		Else
			cQueryC20 += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
		EndIf
	Else
		cQueryC20 += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf

cQueryC20 += " AND C1H.C1H_ID     = C20.C20_CODPAR "
cQueryC20 += " AND C1H.C1H_RAMO   = '4' "
cQueryC20 += " AND C1H.D_E_L_E_T_ = ' ' "

cQueryC20 += 	" INNER JOIN " + RetSqlName( 'C30' ) + " C30 "
cQueryC20 += 	" ON C30.C30_FILIAL = C20.C20_FILIAL "
cQueryC20 += 	" AND C30.C30_CHVNF = C20.C20_CHVNF "
cQueryC20 += 	" AND C30.D_E_L_E_T_ = ' ' "

cQueryC20 += " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_ID = C30.C30_CFOP"
cQueryC20 += 	"       AND C0Y.D_E_L_E_T_ = ' ' "
cQueryC20 += " WHERE C20.C20_FILIAL IN " + cFiliais + " "

If !lApur  .or. lGetStatus// Consulta Status
	If lIdProc
		cQueryC20	+= "AND C20.C20_PROCID <> '" + Padr(" ", TamSx3("C20_PROCID")[1]) + "' "
	Else
		cQueryC20	+= "AND C20.C20_PROCID = '" + Padr(" ", TamSx3("C20_PROCID")[1]) + "' "
	EndIf	
EndIf

cQueryC20 +=   " AND C20.C20_INDOPE = '0' " //Entrada

If cBd $ "ORACLE|POSTGRES|DB2"
	cQueryC20 += " AND SUBSTR(C20.C20_DTDOC,1,6) = '" + cPeriodo + "' "
ElseIf cBd $ "INFORMIX"
	cQueryC20 += " AND C20.C20_DTDOC[1,6] = '" + cPeriodo + "' "
Else
	cQueryC20 += " AND SUBSTRING(C20.C20_DTDOC, 1, 6) = '" + cPeriodo + "' "
EndIf

cQueryC20 += " AND (C20.C20_CODSIT <> '000003' AND C20.C20_CODSIT <> '000004' AND C20.C20_CODSIT <> '000005' AND C20.C20_CODSIT <> '000006') " //Canceladas/Denegadas/Inutilizadas
cQueryC20 += " AND C20.C20_TPDOC <> '000002' " // Notas de devolução
cQueryC20 += " AND C20.D_E_L_E_T_ = ' ' "
cQueryC20 += " AND NOT EXISTS (SELECT C30.C30_CHVNF FROM " + RetSQLName("C30") + " C30 "
cQueryC20 += " WHERE C30.C30_FILIAL = C20.C20_FILIAL "
cQueryC20 += " AND C30.C30_CHVNF = C20.C20_CHVNF "
cQueryC20 += " AND (C30.C30_IDTSER != '" + Padr(" ", TamSx3("C30_IDTSER")[1]) + "' OR C30.C30_SRVMUN != '" + Padr(" ", TamSx3("C30_SRVMUN")[1]) + "' "
cQueryC20 += " OR C30.C30_CODSER != '" + Padr(" ", TamSx3("C30_CODSER")[1]) + "' OR C30.C30_TPREPA != '" + Padr(" ", TamSx3("C30_TPREPA")[1]) + "') "
cQueryC20 += " AND C30.D_E_L_E_T_ = ' ') "
//-----------------------------------------------------------------------------------------------------------------------------------------------------
cQueryC20 +=   " AND EXISTS (SELECT 1 "
cQueryC20 +=                 " FROM " + RetSqlName('C35') + " C35"
cQueryC20 +=                " WHERE C35.C35_FILIAL = C20.C20_FILIAL "
cQueryC20 +=                  " AND C20.C20_CHVNF  = C35.C35_CHVNF "
cQueryC20 +=                  " AND C35.C35_CODTRI IN ('000013','000024','000025') "
cQueryC20 +=                  " AND C35.D_E_L_E_T_ = ' ' ) "



cQueryLEM += " FROM " + RetSqlName("LEM") + " LEM "
cQueryLEM += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
If cCompC1H == "EEE"
	cQueryLEM += " C1H.C1H_FILIAL = LEM.LEM_FILIAL "			
Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQueryLEM += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
		ElseIf cBd $ "INFORMIX"
			cQueryLEM += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] = LEM.LEM_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] "
		Else
			cQueryLEM += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
		EndIf
	ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQueryLEM += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
		ElseIf cBd $ "INFORMIX"
			cQueryLEM += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] = LEM.LEM_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] "
		Else
			cQueryLEM += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
		EndIf
	Else
		cQueryLEM += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf

cQueryLEM += " AND C1H.C1H_ID = LEM.LEM_IDPART "
cQueryLEM += " AND C1H.C1H_RAMO = '4' "
cQueryLEM += " AND C1H.D_E_L_E_T_ = ' ' "
cQueryLEM += " WHERE "
cQueryLEM += " LEM.LEM_FILIAL IN " + cFiliais + " "
If !lApur  .or. lGetStatus// Consulta Status
	If lIdProc
		cQueryLEM	+= "AND LEM.LEM_PROCID <> '" + Padr(" ", TamSx3("LEM_PROCID")[1]) + "' "
	Else
		cQueryLEM	+= "AND LEM.LEM_PROCID = '" + Padr(" ", TamSx3("LEM_PROCID")[1]) + "' "
	EndIf	
EndIf
cQueryLEM += " AND LEM.LEM_NATTIT = '0' "
cQueryLEM += " AND LEM.LEM_DOCORI = '" + Padr(" ", TamSx3("LEM_DOCORI")[1]) + "' "
If cBd $ "ORACLE|POSTGRES|DB2"
	cQueryLEM += " AND SUBSTR(LEM.LEM_DTEMIS,1,6) = '" + cPeriodo + "' "
ElseIf cBd $ "INFORMIX"
	cQueryLEM += " AND LEM.LEM_DTEMIS[1,6] = '" + cPeriodo + "' "
Else
	cQueryLEM += " AND SUBSTRING(LEM.LEM_DTEMIS, 1, 6) = '" + cPeriodo + "' "
EndIf
cQueryLEM +=	" AND (LEM.LEM_VLRGIL > 0 OR LEM.LEM_VLRSEN > 0 OR LEM.LEM_VLRCP > 0) "
cQueryLEM +=	" AND LEM.D_E_L_E_T_ = ' ' "
cQueryLEM +=	" AND NOT EXISTS (SELECT T5M.T5M_NUMFAT FROM " + RetSqlName("T5M") + " T5M WHERE T5M.T5M_FILIAL = LEM.LEM_FILIAL "
cQueryLEM +=	" AND T5M.T5M_ID = LEM.LEM_ID "
cQueryLEM +=	" AND T5M.T5M_IDPART = LEM.LEM_IDPART "
cQueryLEM +=	" AND T5M.T5M_NUMFAT = LEM.LEM_NUMERO "
cQueryLEM +=	" AND (T5M.T5M_IDTSER != '" + Padr(" ", TamSx3("T5M_IDTSER")[1]) + "' "
cQueryLEM +=	" OR T5M.T5M_TPREPA != '" + Padr(" ", TamSx3("T5M_TPREPA")[1]) + "' ) "
cQueryLEM +=	" AND T5M.D_E_L_E_T_ = ' ') "


If cBd $ "POSTGRES"
	cConcat 	:= " CONCAT(C1H.C1H_CNPJ,C1H.C1H_CPF) "
	cGrpByC1H   := " CONCAT(C1H.C1H_CNPJ,C1H.C1H_CPF) "
ElseIf cBd $ "ORACLE|DB2|OPENEDGE"
	cConcat 	:= " (C1H.C1H_CNPJ || C1H.C1H_CPF) "
	cGrpByC1H   := " (C1H.C1H_CNPJ || C1H.C1H_CPF) "
ElseIf cBd $ "INFORMIX"
	cConcat 	:= " (C1H.C1H_CNPJ || C1H.C1H_CPF) "
	cGrpByC1H   := " C1H.C1H_CNPJ , C1H.C1H_CPF "
Else
	cConcat 	:= " (C1H.C1H_CNPJ+C1H.C1H_CPF) "	
	cGrpByC1H   := " (C1H.C1H_CNPJ+C1H.C1H_CPF) "
EndIf


If lApur .and. !lGetStatus
	//Contagem de fornecedores
	
	cQuery := " COUNT(PARTIC) TOTAL FROM ("
	cQuery += " SELECT FIL, PARTIC FROM ("
	cQuery += " SELECT C20.C20_FILIAL FIL, " + cConcat + " PARTIC "
	cQuery += cQueryC20 
	cQuery += " GROUP BY C20.C20_FILIAL, C1H.C1H_CNPJ , C1H.C1H_CPF "
	cQuery +=	" UNION ALL " // Query para buscar os títulos na tabela LEM conforme os parâmetros abaixo.
	cQuery += " SELECT LEM.LEM_FILIAL FIL, " + cConcat + " PARTIC "
	cQuery += cQueryLEM
	cQuery += " GROUP BY LEM.LEM_FILIAL, C1H.C1H_CNPJ , C1H.C1H_CPF "
	cQuery += " ) TB1 "
	cQuery += " GROUP BY TB1.FIL, TB1.PARTIC ) TB2 "
Else
	
	cQuery := " Sum(CHV) CHV, COUNT(PARTIC) TOTAL FROM ("
	cQuery += " SELECT FIL, SUM(CHV) CHV, PARTIC FROM( "
	cQuery += " SELECT NF.FIL, COUNT(NF.CHV) CHV, NF.PARTIC FROM ("
	cQuery += " SELECT DISTINCT C20.C20_FILIAL FIL,"
    cQuery += " C20.C20_CHVNF CHV, "
	cQuery += cConcat + " PARTIC "
	cQuery += cQueryC20
	cQuery += " GROUP BY C20.C20_FILIAL, C20.C20_CHVNF, " + cGrpByC1H + " ) NF "
	cQuery += " GROUP BY NF.FIL, NF.CHV, NF.PARTIC "
	cQuery +=	" UNION ALL "
	cQuery += " SELECT LEM.LEM_FILIAL FIL,"
	cQuery += " count(LEM.LEM_ID) CHV, "
    cQuery += cConcat + " PARTIC "
	cQuery += cQueryLEM
	cQuery += " GROUP BY LEM.LEM_FILIAL, " + cGrpByC1H + " "
	cQuery += " ) TB1 "
	cQuery += " GROUP BY TB1.FIL, TB1.PARTIC) TB2 "
EndIf
cQuery := "%" + cQuery + "%"

BeginSql Alias cAliasST
	SELECT
		%EXP:cQuery%
EndSql		
If lApur .and. !lGetStatus
	nTotDoc := (cAliasST)->TOTAL
Else
	nTotDoc := (cAliasST)->CHV
EndIf	
nTotFor := (cAliasST)->TOTAL
(cAliasST)->(DbCloseArea())

Return nTotFor

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSt2060
Retorna o status de apuração para os eventos R-2060
@author Denis Souza
@since 29/03/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetSt2060(aFiliais, cPeriodo, cEvento, lIdProc)

	Local aSelFils	as array
	Local cAliasST	as character
	Local nTotOK	as numeric
	Local cQry		as character
	Local oPrepare 	as Object
	Local aBind 	as Array
	Local nI    	as Numeric
	Local aInfoEUF	as Array
	Local aRet		as Array

	Default aFiliais := {}
	Default cPeriodo := ''
	Default cEvento  := ''
	Default lIdProc  := .T.

	aSelFils := {}
	cAliasST := ''
	nTotOK	 := 0
	cQry	 := ''
	oPrepare := Nil
	aBind 	 := {}
	nI    	 := 0
	aInfoEUF := {}
	aRet	 := {}

	aSelFils := ValidFils(aFiliais)
	cPeriodo := Right(cPeriodo,4)+Left(cPeriodo,2)
	aInfoEUF := TAFTamEUF(Upper(AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_LEIAUTE'})[1][2])))
	aRet	 := Qury2060(cPeriodo,.F.,lIdProc,aSelFils,aInfoEUF)

	If Len(aRet) >= 1
		cQry  := "SELECT " + aRet[1][1]
		aBind := Aclone(aRet[1][2])
		TafBindQry(cQry, @oPrepare, @aBind, @cAliasST)
		nTotOK := CountFil(cAliasST, lIdProc) //realiza o close da tabela
		If oPrepare != Nil
			oPrepare:Destroy()
			freeObj(oPrepare)
			oPrepare := Nil
		EndIf
	EndIf

Return( nTotOK )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSt3010
Retorna o status de apuração para os eventos R-3010
@author Roberto Souza
@since 10/04/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetSt3010(aFiliais, cPeriodo, cEvento , lIdProc, lApi)

	Local aSelFils	as array
	Local cAliasST	as character
	Local cQuery	as character
	Local nTotOK	as numeric
	Local alPosQry	As Array
	
	Default lIdProc := .T.
	Default lApi 	:= .F.
	
	cQuery		:= ""
	aSelFils 	:= ValidFils(aFiliais)
	cAliasST	:= GetNextAlias()
	cPeriodo 	:= Right(cPeriodo,4)+Left(cPeriodo,2)
	nTotOK		:= 0
	
	alPosQry 	:= Qury3010(cPeriodo, .F., lIdProc, aSelFils,,, lApi)

	If Len(alPosQry) >= 1
		cQuery := "%" + alPosQry[1][1] + "%"

		BeginSql Alias cAliasST
			SELECT
			%EXP:cQuery%	
		EndSql
	
		DbSelectArea(cAliasST)
		(cAliasST)->(DbGoTop())
		While (cAliasST)->(!Eof())
			nTotOK += (cAliasST)->TOTAL
			(cAliasST)->(DbSkip())
		EndDo 
		(cAliasST)->(DbCloseArea())			
	EndIf

Return( nTotOK )
//-------------------------------------------------------------------
/*/{Protheus.doc} RetStRecAD
Retorna o status de apuração para os eventos R-2030/R-2040 - Recursos Recebidos/Repassados para Associação Desportiva
@author anieli.rodrigues
@since 02/04/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function RetStRecAD(aFiliais, cPeriodo, cEvento , lIdProc, lApi, nTotDoc, aFilCont, nCont) 

	Local oPrepare  as object
	Local aSelFils	as array
	Local aBind     as array
	Local cAliasST	as character
	Local cQuery	as character
	Local nTotOK	as numeric
	Local nTotNo	as numeric
	Local nI        as numeric
	
	Default lIdProc  := .T.
	Default nTotDoc  :=  0
	Default lApi	 := .F.
	Default aFilCont := {}
	Default nCont	 := 0

	oPrepare    := Nil
	aSelFils 	:= ValidFils(aFiliais)
	aBind       := {}
	cAliasST	:= GetNextAlias()
	cPeriodo 	:= Right(cPeriodo,4)+Left(cPeriodo,2)
	cQuery		:= QryApRecAd(cPeriodo, .F., lIdProc, aSelFils, cEvento, lApi, @aBind)
	nTotOK		:= 0
	nTotNo		:= 0
	nI          := 0
	
	cQuery := ChangeQuery(cQuery)
	oPrepare := FwExecStatement():New(cQuery)

	For nI := 1 To Len(aBind)
		If Valtype(aBind[nI]) == 'A'
        	oPrepare:setIn(nI, aBind[nI])
    	Else
        	oPrepare:setString(nI, aBind[nI])
    	Endif
	Next nI

    oPrepare:OpenAlias(cAliasST)

	(cAliasST)->(DbGoTop())
	While (cAliasST)->(!Eof())
		if lApi
			nTotOk := HndlTotDoc(cAliasST, aFiliais, @nTotDoc, lIdProc, @aFilCont, @nCont)
		else
			nTotOK += (cAliasST)->TOTAL
		endIf
		(cAliasST)->(DbSkip())
	EndDo 
	
	(cAliasST)->(DbCloseArea())
	freeObj(oPrepare)

Return( nTotOK )

//-------------------------------------------------------------------
/*/{Protheus.doc} HndlTotDoc
Retorna a quantidade de documentos e contribuintes, para apresentação nos CARDS do TAF THF.
@author Bruno Cremaschi
@since 22/11/2019
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Static Function HndlTotDoc(cAliasST, aFiliais, nTotDoc, lIdProc, aFilCont, nCont)

local cCNPJMat  as character
local cFilMat	as character
local cChvAux	as character
local cFilAux	as character
local nRet		as numeric
local nDifCNPJ  as numeric
local nX 		as numeric

Default lIdProc  := .T.
Default aFilCont := {}
Default	nCont	 := 0
Default nTotDoc  := 0
Default aFiliais := {}
Default cAliasST := ""

cFilMat		:= ""
cCNPJMat	:= ""
cFilAux		:= ""
cChvAux		:= ""
nDifCNPJ 	:= 0
nRet		:= 0
nX 			:= 0

cFilMat		:= aFiliais[aScan(aFiliais, {|x| x[9] == .T. })][3]
cCNPJMat 	:= aFiliais[aScan(aFiliais, {|x| AllTrim(x[3]) == AllTrim(cFilMat) })][6]
nDifCNPJ	:= aScan(aFiliais, {|x| AllTrim(x[6]) <> cCNPJMat })

While (cAliasST)->(!EOF())
	If cChvAux	<> (cAliasST)->(FIL+CHVNF)
		nTotDoc++
	Endif

	If nDifCNPJ > 0 .OR. lIdProc
		If AllTrim(cFilAux) <> AllTrim((cAliasST)->FIL)
			nRet++
			if FWIsInCallStack("RetStRecAD")
				if lIdProc
					aAdd( aFilCont , AllTrim((cAliasST)->FIL) )
				else
					for nX := 1 to len(aFilCont)
						if AllTrim((cAliasST)->FIL) == aFilCont[nX]
							nCont ++
						endIf
					next nX
				endIf
			endIf
		EndIf
		cFilAux := (cAliasST)->FIL
	Else
		If AllTrim(cFilMat) == AllTrim((cAliasST)->FIL) .And. Alltrim(cFilAux) <> AllTrim((cAliasST)->FIL)
			nRet++
			if FWIsInCallStack("RetStRecAD") .and. !lIdProc
				nCont++
			endIf
		ElseIf FWIsInCallStack("RetStRecAD") .and. !lIdProc .and. nCont==0
			nCont++
			nRet++
		EndIf
	EndIf

	cFilAux	:= (cAliasST)->FIL
	cChvAux := (cAliasST)->(FIL+CHVNF)
	(cAliasST)->(dbSkip())
EndDo

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafEvRStat
Retorna o status de transmissão para os eventos
@author Roberto Souza
@since 13/04/2018
@version 1.0 

@aParam	

@return aRet
/*/
//-------------------------------------------------------------------
Function TafEvRStat( aFiliais, cPeriodo, cEvento , cStat, cFiltStat, cEventAdd, lApi )
	Local cTab	 	as character
	Local cTabDB	as character
	Local cFils		as character
	Local cFilTab	as character
	Local cBd		As character
	Local cNrInsc	as character
	Local nPosEvt	as numeric
	Local nRegAll	as numeric
	Local nRegAut	as numeric	 
	Local nRegExc	as numeric	
	Local nMatriz   as numeric
	Local lOkEvt	as logical
	Local aRet		as array
	Local aSelFils	as array
	Local aSM0 		as array

	Default cEvento		:= ""
	Default cPeriodo	:= ""
	Default	cStat		:= ""
	Default cFiltStat	:= "" // API WSTAF001 Filtro Status
	Default cEventAdd	:= "" // API WSTAF001 eventos adicionais para processamento além dos eventos R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-3010|
	Default lApi 		:= .F.
	
	cPeriodo	:= StrTran(StrTran(cPeriodo,"-",""),"/","")
	cStat 		:= ""
	cBd			:= TcGetDb()
	aRotReinf 	:= Iif( Type( "aRotReinf" ) == "U", TafRotinas(,,,5) , aRotReinf  )	
	nPosEvt 	:= aScan( aRotReinf, {|x| AllTrim(x[04]) == cEvento })
	lOkEvt		:= cEvento $ "R-1050|R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-3010|R-4010|R-4020|R-4040|R-4080|"+cEventAdd
	cNrInsc		:= ""
	aRet 		:= {}
	aSelFils	:= {}
	aSM0		:= {}
	nRegAll		:= 0
	nRegAut		:= 0
	nRegExc		:= 0	
	nMatriz		:= 0

	If nPosEvt > 0 .And. lOkEvt 

		cTab 	:= GetNextAlias()
		cTabDB	:= aRotReinf[nPosEvt][03]
		cCpoPer	:= cTabDB+"_PERAPU"
		cCpoStat:= "%"+cTabDB+"_STATUS"+"%" 
		cWhere 	:= "% "+cTabDB+"_ATIVO ='1'"

		//Tratamento para contagem correta dos registros apurados no monitor po ui reinf
		if Upper(Alltrim(cEvento)) $ "R-1070|R-2060"
			cWhere 	+= "AND " + cTabDB + "_PROCID <> ' ' "
		endif

		if lApi .and. cEvento == "R-1000"
			aSM0 	:= WsLoadFil()
			nMatriz := aScan(aSM0,{|x| x[F_C1E_MATRIZ] })
			cNrInsc := aSM0[nMatriz][6]   

			cWhere 	+= "AND " + cTabDB + "_NRINSC = '" + cNrInsc + " '"  
		endIf

		aSelFils	:= ValidFils( aFiliais )
		//cFils 		:= TafRetIn(  aSelFils,,"A", .F., 2 )
		cFils 		:= TafRetFilC(cTabDB, aSelFils )
		
		cFilTab		:= xFilial( cTabDB )

		If TafColumnPos( cCpoPer ) .And. !Empty( cPeriodo ) //.And. !( cEvento $ "R-3010" )
			if cEvento == "R-3010"
				if !lApi
					If cBd $ "ORACLE|POSTGRES|DB2"
						cWhere	+=  " AND SUBSTR("+cTabDB+"_DTAPUR,1,6) = '"+ substr(cPeriodo,3,4)+substr(cPeriodo,1,2) +"'"			
					ElseIf cBd $ "INFORMIX"
						cWhere	+=  "AND " +cTabDB+"_DTAPUR[1,6] = '"+ substr(cPeriodo,3,4)+substr(cPeriodo,1,2) +"'"	
					Else
						cWhere	+=  " AND SUBSTRING("+cTabDB+"_DTAPUR,1,6) = '"+ substr(cPeriodo,3,4)+substr(cPeriodo,1,2) +"'"
					EndIf
				endIf
			else
				cWhere 	+= " AND "+cCpoPer+" = '"+cPeriodo+"'"
			endif
		EndIf
		If !Empty(cFilTab) .And. !(cEvento $ "R-1070")
			cWhere	+= " AND "+cTabDB+"_FILIAL IN " + cFils + " "
		ElseIf !Empty(cFilTab) .And. cEvento $ "R-1070"
			cFils := TafRetFilC(cTabDB, aSelFils)

			cWhere	+= " AND "+cTabDB+"_FILIAL IN " + cFils + " "
		EndIf

		if !empty(cFiltStat)
			cWhere	+= " AND ("+cTabDB+"_STATUS IN (" + cFiltStat + ") "
			if "0" $ cFiltStat
				cWhere	+= " OR "+cTabDB+"_STATUS = ' ' )"
			else
				cWhere	+= " )"
			endif
		else
			if !cEvento == 'R-9000'
				// STATUS 6 e 7 REMOVIDO PARA NÃO CONTAR COMO TRANSMITIDOS
				// STATUS 6 = PENDENTE EXCLUSÃO GOVERNO
				// STATUS 7 = EXCLUSAO VALIDADA PELO GOVERNO
				cWhere	+= " AND "+cTabDB+"_STATUS NOT IN ('6','7') "
			endif
		endif

		cWhere 	+= "%"

		cTabDB	:= "%"+RetSqlName(cTabDB)+"%" 
		
		// Tratamento realizado para retornar os registros da tabela T9D apenas quando o evento não for R-9000, pois essa query com UNION
		// é responsável por retornar a quantidade de registros excluídos (T9D) do evento (cEvento).
		// O registro R-9000 não possuí registros excluídos na tabela (T9D). Portanto não existe a necessidade de executar a query com o UNION.
		IF !cEvento == 'R-9000'
		
			BeginSql Alias cTab
				SELECT %Exp:cCpoStat% STATUS,
					COUNT(*) TOTAL
				FROM %Exp:cTabDB%
				WHERE %notdel% AND %Exp:cWhere%
				GROUP BY %Exp:cCpoStat%

				UNION 
				
				SELECT
					TB1.STATUS STATUS, COUNT(*) TOTAL
				FROM
					(SELECT
						'7' STATUS
					FROM %TABLE:T9D% T9D
					INNER JOIN %TABLE:T9B% T9B
					ON T9D.T9D_IDTPEV = T9B_ID
						AND T9B.T9B_CODIGO = %Exp:cEvento%
						AND T9B.D_E_L_E_T_ = ' '
					WHERE
						T9D.T9D_FILIAL = %Exp:cFilAnt% AND 
						T9D.T9D_PERAPU = %Exp:cPeriodo% AND
						T9D.D_E_L_E_T_ = ' ') TB1
				GROUP BY TB1.STATUS

			EndSql
		ELSE
			BeginSql Alias cTab
				SELECT %Exp:cCpoStat% STATUS,
					COUNT(*) TOTAL
				FROM %Exp:cTabDB%
				WHERE %notdel% AND %Exp:cWhere%
				GROUP BY %Exp:cCpoStat%

			EndSql
		ENDIF
		
		DbSelectArea( cTab )
	
		If (cTab)->(!Eof())
			While (cTab)->(!Eof())
				cDescStat := TAF421Sts( (cTab)->STATUS )
				AADD( aRet ,{	(cTab)->TOTAL	,;
								(cTab)->STATUS	,; 
								cDescStat })	
				nRegAll += (cTab)->TOTAL
				If (cTab)->STATUS == "4"
					nRegAut := (cTab)->TOTAL
				EndIf	
				If (cTab)->STATUS == "7" // Exclusão Autorizada
					nRegExc := (cTab)->TOTAL
				EndIf	

				(cTab)->(DbSkip())
			EndDo
		EndIf 

		If nRegAll > 0 
			If nRegAll == (nRegAut + nRegExc)
				//Só terá status "autorizado" se ao menos 1 registro estiver autorizado, caso contrario ficara "não transmitido".
				cStat := iif(nRegAut > 0,'4','1')  
			ElseIf nRegAll > (nRegAut + nRegExc) .And. nRegAut > 0
				cStat := "6" // Parcialmente Transmitido
			ElseIf nRegAll > (nRegAut + nRegExc) .And. nRegAut == 0
				cStat := "1"
			EndIf
		Else 
			cStat := "5"
		EndIf 
		/*
		_STATUS = " " "AGUARDANDO PROCESSAMENTO"
		_STATUS = "0" "VÁLIDO"
		_STATUS = "1" "INVÁLIDO"
		_STATUS = "2" "TRANSMITIDO (AGUARDANDO RETORNO)"
		_STATUS = "3" "TRANSMITIDO INVÁLIDO"
		_STATUS = "4" "TRANSMITIDO VÁLIDO"
		_STATUS = "6" "PENDENTE DE EXCLUSÃO"
		_STATUS = "7" "EXCLUSÃO EFETIVADA"
		*/
		(cTab)->(DbCloseArea())
	EndIf
	
Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} OpenReinf
Abre o navegador padrão com a página sobre o TAF REINF
@author Leonardo Kichitaro
@since 16/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function OpenReinf()
	
	cURL := "http://tdn.totvs.com/x/CUKIF" //Incluir o link para a pagina do REINF
	
	shellExecute("Open", cURL, "", "", 1 )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GoToLink
Abre um link no navegador
@author Roberto Souza
@since 16/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GoToLink( cUrl , oFather )
	ShellExecute("Open", cURL, "", "", 1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xAtuCabec
Atualiza os cabeçalhos de acordo com as informações alteradas
@author Roberto Souza
@since 16/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function xAtuCabec( oMain )

	Local aAmbR			as array
	Local cVerReinf		as character
	Local cAmbReinf		as character
	Local cSp			as character
	Local cCadastro 	as character
	Local lValid		as logical
	SuperGetMv()

	aAmbR		:= {"1 - Produção","2 - Pré Produção - Dados reais","3 - Pré Produção - dados fictícios"}
	cVerReinf	:= StrTran( SuperGetMv('MV_TAFVLRE',.F.,"1_03_02") , "_","." )
	cAmbReinf	:= Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
	cAmbReinf   := Iif( Empty( cAmbReinf ), "2", cAmbReinf ) // Se o parâmetro estiver vazio, inicio com valor '2 - Pré Produção'
	nAmbR		:= aScan( aAmbr,{|x| Left(x,1) == cAmbReinf })
	cAmbReinf	:= aAmbR[nAmbR]
	cSp			:= Space( aFullSize[04] / 65 )
	lValid		:= Left(GetNewPar( "MV_TAFRVLD", "N" ),1) == "S"
	cCadastro 	:= STR0001 + cSp + " - " + cSp + "Versão: "+cVerReinf + cSp + " - "+ cSp + "Ambiente: "+cAmbReinf + cSp + " - "+ cSp + "Pré-Validação: "+IIf( lValid, "Ativa", "Inativa")
	
	oMain:cCaption		:= 	cCadastro
	
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} ReinfRules
Regras comuns para validação dos registros de apuração conforme as regras do manual da Reinf.
Obs. Deve-se tratar aqui apenas as regras formais e/ou comuns aos eventos.
Regras específicas deve-se tratar na apuração.

@author Roberto Souza
@since 04/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function ReinfRules( cAlias, cRegra, aLogErro, aDadosUtil, cAliasPai, lErro )
	Local cLogErro			as character
	Local cIdReg			as character
	Local cCampo			as character
	Local cVsReinf 			as character
	Local cCodClaF			as character
	Local cPeriodo			as character
	Local cPerIni			as character 
	Local cPerFim			as character
	Local lMsgErro			as logical
	Local lVSup13			as logical
	Default aLogErro		:=	{}
	Default aDadosUtil		:=	{}
	Default cAliasPai		:=	""
	Default lErro			:= .F.

	cLogErro	:= ""
	cIdReg 		:= ""
	cCampo		:= ""
	cVsReinf 	:= StrTran( SuperGetMv('MV_TAFVLRE',.F.,"1_03_02") , "_","" )
	cCodClaF	:= ""
	lMsgErro	:= .F.
	lVSup13 	:= Alltrim(cVsReinf) > '10300'

	If Empty( cAliasPai )
		cAliasPai := cAlias 
	EndiF

	DbSelectArea( cAlias )

	If cRegra == "REGRA_INFO_PERIODO_CONFLITANTE"
		/*---------------------------------------------------------------------------------------------
		Em caso de {inclusao} ou {alteracao}, não pode haver outro registro cujo período seja
		conflitante com a inclusão ou alteração.
		-----------------------------------------------------------------------------------------------*/		
		If aDadosUtil[1][3] $ "IA"
			cAliasV := GetNextAlias()
			cIdReg	:= aDadosUtil[1][1]
			cDtIni	:= aDadosUtil[1][2]

			BeginSql ALIAS cAliasV
				SELECT * FROM %Table:T9U% T9U
					WHERE T9U.%notdel%
					AND T9U_ID = %Exp:cIdReg%
					AND T9U_ATIVO = '1'
					AND T9U_DTINI <> %Exp:cDtIni% 
			EndSql
			
			If (cAliasV)->(!EoF())
				AADD(aLogErro,{ "T9U_DTINI","Em caso de {inclusao} ou {alteracao}, não pode haver outro registro cujo período seja conflitante com a inclusão ou alteração.", "T9U", nRecno }) 
				cLogErro += "REGRA_INFO_PERIODO_CONFLITANTE" +CRLF+"Em caso de {inclusao} ou {alteracao}, não pode haver outro registro cujo período seja conflitante com a inclusão ou alteração."+CRLF
			EndIf
		EndIf
	ElseIf cRegra == "REGRA_EXISTE_INFO_CONTRIBUINTE"

		/*---------------------------------------------------------------------------------------------
		//O evento somente pode ser recepcionado se existir evento de informações cadastrais do 
		//contribuinte vigente para a data do evento, ou seja, a data do evento (ou período de apuração, 
		//no caso de evento periódico) deve estar compreendida entre o {iniValid} e {fimValid} do evento 
		//de informações do contribuinte.
		-----------------------------------------------------------------------------------------------*/		
		//aDadosUtil[1,1] - cId 
		//aDadosUtil[1,2] - cPeriodo

		T9U->(DbSetOrder(3)) //T9U_FILIAL, T9U_ID, T9U_ATIVO

		If T9U->( MsSeek( xFilial('T9U') + aDadosUtil[1,1] + '1' ) ) 
			
			cPeriodo	:= Substr(aDadosUtil[1,2], 3, 4) + Substr(aDadosUtil[1,2], 1, 2)
			cPerIni 	:= Substr(T9U->T9U_DTINI, 3, 4) + Substr(T9U->T9U_DTINI, 1, 2)
			cPerFim 	:= Substr(T9U->T9U_DTFIN, 3, 4) + Substr(T9U->T9U_DTFIN, 1, 2)
			If cPeriodo < cPerIni
				aAdd(aLogErro,{ "T9U_ID", "O período de validade de informações cadastrais do contribuinte não está de acordo com o período do evento, ou seja, o período do evento deve estar compreendido entre o {iniValid} e {fimValid} do evento de informações do contribuinte. Verifique o cadastro de complemento de empresa e efetue uma nova apuração do evento R-1000.", cAlias, T9U->(Recno()), cAliasPai,,"" })  //"O período de validade de informações cadastrais do contribuinte não está de acordo com o período do evento, ou seja, o período do evento deve estar compreendido entre o {iniValid} e {fimValid} do evento de informações do contribuinte. Verifique o cadastro de complemento de empresa e efetue uma nova apuração do evento R-1000."
				cLogErro += "Regra : "+cRegra + CRLF
				cLogErro += "Campo : "+"C1E_ID" + CRLF	
				cLogErro += "O período de validade de informações cadastrais do contribuinte não está de acordo com o período do evento, ou seja, o período do evento deve estar compreendido entre o {iniValid} e {fimValid} do evento de informações do contribuinte. Verifique o cadastro de complemento de empresa e efetue uma nova apuração do evento R-1000."+CRLF
			ElseIf !Empty(T9U->T9U_DTFIN) .And. cPeriodo > cPerFim
				aAdd(aLogErro,{ "T9U_ID", "O período de validade de informações cadastrais do contribuinte não está de acordo com o período do evento, ou seja, o período do evento deve estar compreendido entre o {iniValid} e {fimValid} do evento de informações do contribuinte. Verifique o cadastro de complemento de empresa e efetue uma nova apuração do evento R-1000.", cAlias, T9U->(Recno()), cAliasPai,,"" })  //"O período de validade de informações cadastrais do contribuinte não está de acordo com o período do evento, ou seja, o período do evento deve estar compreendido entre o {iniValid} e {fimValid} do evento de informações do contribuinte. Verifique o cadastro de complemento de empresa e efetue uma nova apuração do evento R-1000."
				cLogErro += "Regra : "+cRegra + CRLF
				cLogErro += "Campo : "+"C1E_ID" + CRLF	
				cLogErro += "O período de validade de informações cadastrais do contribuinte não está de acordo com o período do evento, ou seja, o período do evento deve estar compreendido entre o {iniValid} e {fimValid} do evento de informações do contribuinte. Verifique o cadastro de complemento de empresa e efetue uma nova apuração do evento R-1000."+CRLF
			EndIf
		Else
			aAdd(aLogErro,{ "T9U_ID", "Não foi localizado evento de informações cadastrais do contribuinte, verifique o cadastro de complemento de empresa e efetue a apuração do evento R-1000.", cAlias, T9U->(Recno()), cAliasPai,,"" })  //"Não foi localizado evento de informações cadastrais do contribuinte, verifique o cadastro de complemento de empresa e efetue a apuração do evento R-1000."
			cLogErro += "Regra : "+cRegra + CRLF
			cLogErro += "Campo : "+"C1E_ID" + CRLF				
			cLogErro += "Não foi localizado evento de informações cadastrais do contribuinte, verifique o cadastro de complemento de empresa e efetue a apuração do evento R-1000." + CRLF

		Endif 		

	ElseIf cRegra == "REGRA_TAF_EXISTE_PROCESSO" 	
		//aDadosUtil[1,1] - cFilial 
		//aDadosUtil[1,2] - cNumProc
		//aDadosUtil[1,3] - cCodSus

		T9V->(DbSetOrder(5)) //T9V_FILIAL, T9V_ID, T9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
		T9X->(DbSetOrder(1)) //T9X_FILIAL, T9X_ID, T9X_VERSAO, T9X_CODSUS, R_E_C_N_O_, D_E_L_E_T_
		If !T9V->(MsSeek(aDadosUtil[1,1] + aDadosUtil[1,2] +'1'))
			aAdd(aLogErro,{ "T9U_ID", "O processo deve existir na tabela de PROCESSOS. Verifique o cadastro de Processos Referenciados e efetue a apuração do evento R-1070.", cAlias, T9v->(Recno()), cAliasPai,,"" })
			cLogErro += "O processo deve existir na tabela de PROCESSOS. Verifique o cadastro de Processos Referenciados e efetue a apuração do evento R-1070." + CRLF
		Else
			If !T9X->(MsSeek(T9V->T9V_FILIAL + T9V->T9V_ID + T9V->T9V_VERSAO + aDadosUtil[1,3]))
				aAdd(aLogErro,{ "T9X_ID", "A suspensão deve constar na tabela de processos (R-1070 - campo {codSusp}), vinculado ao número do processo informado em {nrProcRetPrinc}. Verifique o cadastro de Processos Referenciados e efetue a apuração do evento R-1070.", cAlias, T9U->(Recno()), cAliasPai,,"" })
				cLogErro += "A suspensão deve constar na tabela de processos (R-1070 - campo {codSusp}), vinculado ao número do processo informado em {nrProcRetPrinc}. Verifique o cadastro de Processos Referenciados e efetue a apuração do evento R-1070." + CRLF
			EndIf
		Endif 		

	ElseIf cRegra == "REGRA_TAF_DTINI_EVENTO"
	/*	Preencher com o mês e ano de início da validade das informações prestadas no evento, no formato AAAA-MM. Validação: Deve ser uma data válida, igual ou posterior à data inicial de implantação da EFD-Reinf, no formato AAAA-MM.*/
		//aDadosUtil[1][1] - cId 
		//aDadosUtil[1][2] - cDtIni
		//aDadosUtil[1][3] - cDtFim
		//aDadosUtil[1][4] - cEmail
		//aDadosUtil[1][5] - cDDDFone
		//aDadosUtil[1][6] - cFone
		//aDadosUtil[1][7] - cDDDCel
		//aDadosUtil[1][8] - cCel
		//Valida apenas se o campo está vazio pois o inicio de apuração e o campo do contribuinte é o mesmo campo
		If Empty( aDadosUtil[1][2] )
			aAdd(aLogErro,{ "C1E_INIPER", "Preencher com o mês e ano de início da validade das informações prestadas no evento, no formato AAAA-MM. Validação: Deve ser uma data válida, igual ou posterior à data inicial de implantação da EFD-Reinf, no formato AAAA-MM.", cAlias, C1E->(Recno()), cAliasPai,,"" }) 
			cLogErro += "Regra : "+cRegra + CRLF
			cLogErro += "Campo : "+"C1E_INIPER" + CRLF
			cLogErro += "Preencher com o mês e ano de início da validade das informações prestadas no evento, no formato AAAA-MM. Validação: Deve ser uma data válida, igual ou posterior à data inicial de implantação da EFD-Reinf, no formato AAAA-MM."+CRLF			
		EndIf

	ElseIf cRegra == "REGRA_TAF_DTFIM_EVENTO"
	/* Preencher com o mês e ano de término da validade das informações, se houver. Validação: Se informado, deve estar no formato AAAA-MM e ser um período igual ou posterior a {iniValid} */
		If !Empty( aDadosUtil[1][3] ) .And. aDadosUtil[1][2] > aDadosUtil[1][3]
			aAdd(aLogErro,{ "C1E_FINPER", "Preencher com o mês e ano de término da validade das informações, se houver. Validação: Se informado, deve estar no formato AAAA-MM e ser um período igual ou posterior a {iniValid} ", cAlias, C1E->(Recno()), cAliasPai,,"" }) 
			cLogErro += "Regra : "+cRegra + CRLF
			cLogErro += "Campo : "+"C1E_FINPER" + CRLF
			cLogErro += "Preencher com o mês e ano de início da validade das informações prestadas no evento, no formato AAAA-MM. Validação: Deve ser uma data válida, igual ou posterior à data inicial de implantação da EFD-Reinf, no formato AAAA-MM."+CRLF			
		EndIf


	ElseIf cRegra == "REGRA_TAF_EMAIL"
	/* Endereço eletrônico Validação: O e-mail deve possuir o caractere "@" e este não pode estar no início e/ou no final do endereço informado. Deve possuir no mínimo um caractere "." depois do @ e não pode estar no final do endereço informado. */
		cEmail := AllTrim( aDadosUtil[1][4] )
		cCampo := IIf( TafColumnPos("C1E_REMAIL"),"C1E_EMAIL / C1E_REMAIL","C1E_EMAIL" )

		If !xVldMail( cEmail )
			aAdd(aLogErro,{ cCampo, "Endereço eletrônico Validação: O e-mail deve possuir o caractere '@' e este não pode estar no início e/ou no final do endereço informado. Deve possuir no mínimo um caractere '.' depois do @ e não pode estar no final do endereço informado.", cAlias, C1E->(Recno()), cAliasPai,,"" }) 
			cLogErro += "Regra    : "+cRegra + CRLF
			cLogErro += "Campo(s) : "+cCampo + CRLF		
			cLogErro += "Endereço eletrônico Validação: O e-mail deve possuir o caractere '@' e este não pode estar no início e/ou no final do endereço informado. Deve possuir no mínimo um caractere '.' depois do @ e não pode estar no final do endereço informado."+CRLF			
		EndIf

	ElseIf cRegra == "REGRA_TAF_FONE"
	/* Informar o número do telefone, com DDD. Validação: Se preenchido, deve conter apenas números com o mínimo de dez dígitos.*/
	// Informar o número do telefone, com DDD. Validação: O preenchimento é obrigatório se o campo {foneCel} não for preenchido. Se preenchido, deve conter apenas números, com o mínimo de dez dígitos.

		cDDDFone	:= AllTrim( aDadosUtil[1][5] )
		cFone 		:= AllTrim( aDadosUtil[1][6] )
		cDDDCel  	:= AllTrim( aDadosUtil[1][7] )
		cCel  		:= AllTrim( aDadosUtil[1][8] )	

		If !Empty( cDDDCel + cCel )
			If !XVldFone( cDDDCel , cCel )
				cCampo := IIf( TafColumnPos("C1E_RCELC"),"C1E_CELCNT / C1E_RCELC","C1E_CELCNT" )		
				aAdd(aLogErro,{ cCampo, "Informar o número do telefone, com DDD. Validação: Se preenchido, deve conter apenas números com o mínimo de dez dígitos.", cAlias, C1E->(Recno()), cAliasPai,,"" }) 
				cLogErro += "Regra    : "+cRegra + CRLF
				cLogErro += "Campo(s) : "+cCampo + CRLF			
				cLogErro += "Informar o número do telefone, com DDD. Validação: Se preenchido, deve conter apenas números com o mínimo de dez dígitos."+CRLF			
			ElseIf !XVldFone( cDDDFone , cFone )
				cCampo := IIf( TafColumnPos("C1E_RFONEC"),"C1E_FONCNT / C1E_RFONEC","C1E_FONCNT" )						
				aAdd(aLogErro,{ cCampo, "Informar o número do telefone, com DDD. Validação: Se preenchido, deve conter apenas números com o mínimo de dez dígitos.", cAlias, C1E->(Recno()), cAliasPai,,"" }) 
				cLogErro += "Regra    : "+cRegra + CRLF
				cLogErro += "Campo(s) : "+cCampo + CRLF			
				cLogErro += "Informar o número do telefone, com DDD. Validação: Se preenchido, deve conter apenas números com o mínimo de dez dígitos."+CRLF			
			EndIf
		Else
			If !XVldFone( cDDDFone , cFone )
				cCampo := IIf( TafColumnPos("C1E_RFONEC"),"C1E_FONCNT / C1E_RFONEC","C1E_FONCNT" )						
				aAdd(aLogErro,{ cCampo, "Informar o número do telefone, com DDD. Validação: O preenchimento é obrigatório se o campo {foneCel} não for preenchido. Se preenchido, deve conter apenas números, com o mínimo de dez dígitos.", cAlias, C1E->(Recno()), cAliasPai,,"" }) 
				cLogErro += "Regra    : "+cRegra + CRLF
				cLogErro += "Campo(s) : "+cCampo + CRLF		
				cLogErro += "Informar o número do telefone, com DDD. Validação: O preenchimento é obrigatório se o campo {foneCel} não for preenchido. Se preenchido, deve conter apenas números, com o mínimo de dez dígitos."+CRLF			
			EndIf
		EndIf
	ElseIf cRegra == "REGRA_TAF_PROCESSO_NUM_VALIDO"
		/*
		NNNNNNN-DD.AAAA.J.TR.OOOO

		NNNNNNN - 7 dígitos que indicam o número de ordem de autuação do processo, no ano de autuação e na unidade jurisdicional de origem; no caso de tribunais de justiça que fizeram a opção de que trata o art. 1º, § 1.º-A, da Resolução 65/2008, o número de ordem é relativo ao tribunal de origem ao invés da unidade de origem;
		DD - 2 dígitos verificadores da integridade do número, calculados a partir de todos os demais dígitos
		AAAA - 4 dígitos indicadores do ano da autuação;
		J - 1 dígito identificador do segmento do Judiciário a que pertence o processo, sendo o dígito 1 para o Supremo Tribunal Federal, 2 para o Conselho Nacional de Justiça, 3 para o Superior Tribunal de Justiça, 4 para a Justiça Federal, 5 para a Justiça do Trabalho, 6 para a Justiça Eleitoral, 7 para a Justiça Militar da União, 8 para a Justiça dos Estados e do Distrito Federal e Territórios, e 9 para a Justiça Militar Estadual;
		TR - 2 dígitos que identificam o tribunal ou conselho do segmento do Poder Judiciário a que pertence o processo; para os tribunais superiores (STF, STJ, TST, TSE e STM) e o CNJ, o código deverá ser preenchido com zero (00), para os Conselhos da Justiça Federal e Superior da Justiça do Trabalho, deverá ser preenchido com o número 90 (noventa), para os demais tribunais, com um número identificador do tribunal;
		OOOO - 4 dígitos identificadores da unidade de origem do processo, seguindo regras diversas para cada um dos segmentos do Judiciário, à exceção dos tribunais e conselhos, que terão esses dígitos preenchidos com zero (0000); esses códigos foram fornecidos pelos tribunais e estão à disposição para consulta no sítio do CNJ.

		##### Não existem critérios e informações suficientes para se basear a validação
		*/
	ElseIf lVSup13 .And. cRegra == "REGRA_TAF_DESONERACAO"
		If Empty( aDadosUtil[1][10] ) //Classificacao Tributaria
			lMsgErro := .T.
		Else
			cCodClaF := Posicione("C8D",1,xFilial("C8D") + aDadosUtil[1][10] , "C8D_CODIGO")

			If aDadosUtil[1][9] == "1" 		//desoneração = 1 Empresa enquadrada
				If ( cCodClaF <> "02" .And. cCodClaF <> "03" .And. cCodClaF <> "99" )
					lMsgErro := .T.
				EndIf
			/*
			//Trecho comentado devido a opção "pode ser" significar opcional e nos demais casos devem ser igual a [0].
			elseif aDadosUtil[1][9] == "0" .Or. Empty( aDadosUtil[1][9] ) //desoneração = 0 Nao Aplicavel, Para desoneração vazio o TAF apura com 0-Nao Aplicavel
				if ( cCodClaF == "02" .Or. cCodClaF == "03" .Or. cCodClaF == "99" )
					lMsgErro := .T.
				endif
			*/
			EndIf
		EndIf

		If lMsgErro
			cCampo := "C1E_INDDES / C1E_CLAFIS"
			aAdd(aLogErro,{cCampo,STR0109 + STR0110,cAlias,C1E->(Recno()),cAliasPai,,""}) //#"Informar a desoneração de folha e a classificação tributária compatível."#"Validação: Pode ser igual a [1] apenas se a classificação tributária for igual a [02, 03, 99]. Nos demais casos deve ser igual a [0]."
			cLogErro += "Regra    : " + cRegra + CRLF
			cLogErro += "Campo(s) : " + cCampo + CRLF
			cLogErro += STR0109 + STR0110 + CRLF //#"Informar a desoneração de folha e a classificação tributária compatível."#"Validação: Pode ser igual a [1] apenas se a classificação tributária for igual a [02, 03, 99]. Nos demais casos deve ser igual a [0]."
		EndIf
	ElseIf lVSup13 .And. cRegra == "REGRA_TAF_DTOBITO"
		cCampo := "C1E_DTOBITO"
		aAdd(aLogErro,{ cCampo, "Informação permitida apenas se tipo de inscrição do contribuinte for igual a CPF.", cAlias, C1E->(Recno()), cAliasPai,,"" }) 
		cNrInsc := Posicione("SM0",1,SM0->M0_CODIGO + aDadosUtil[2][1],"M0_CGC")
		cTpInsc := Iif(Len(Alltrim(cNrInsc)) == 11, "2", "1")
		If cTpInsc == "1" .And. AllTrim(aDadosUtil[2][2]) <> ""
			cLogErro += "Regra    : "+cRegra + CRLF
			cLogErro += "Campo(s) : "+cCampo + CRLF			
			cLogErro += "Informação permitida apenas se o tipo de inscrição do contribuinte for igual a CPF."+CRLF
		EndIf			
	EndIf

//	(cAlias)->( DBGoTo( nRecno ) )

Return( cLogErro )


//-------------------------------------------------------------------
/*/{Protheus.doc} TafRetFilC
Função utilizada para retornar string de filiais a serem utilizadas numa query, 
considerando o compartilhamento do alias informado 

@author anieli.rodrigues
@since 01/06/2018
@version 12.1.17

@param cAliasCp - charactere - Alias que será utilizado para avaliação do compartilhamento
@param aSelFil	- filiais selecionadas para inclusão na cláusula IN
/*/
//-------------------------------------------------------------------

Function TafRetFilC(cCompAlias, aSelFils, lFilOrig)

Local cFilIn 	as character
Local cTable 	as character

Local nFil		as numeric
Local nAfil 	as numeric 
Local nTamFil	as numeric
Local nLimTmp	as numeric
Local cInsertValue as character
Local cAtualxFil as character
Local cLayTable as character

Default lFilOrig := .F.

cInsertValue := ""
cAtualxFil := ""
cFilIn := ""
nAfil := Len(aSelFils)
nLimTmp := 50
	
If nAfil <= nLimTmp	
	For nFil := 1 To Len(aSelFils)
		
		If !(xFilial(cCompAlias, aSelFils[nFil][2]) $ cFilIn)
			If nFil <> 1 .And. nFil < Len(cFilIn)
				cFilIn += ","
			EndIf
			
			cFilIn += "'" + xFilial(cCompAlias, aSelFils[nFil][2]) + "'"
		EndIf 
		
	Next nFil
		
	cFilIn := "(" + cFilIn + ")"
Else	
	cTmpFil := GetNextAlias()
	nTamFil = Len(xFilial("C1E"))
	cTable := ""
	aStruTmp := {}
	cLayTable := FWModeAccess(cCompAlias,1)+FWModeAccess(cCompAlias,2)+FWModeAccess(cCompAlias,3)
	If __cLayFil != cLayTable
		__cLayFil := cLayTable

		aAdd( aStruTmp, {'TMPFIL','C',nTamFil,0} )
			
		__oTmpFil := FwTemporaryTable():New( cTmpFil )
		__oTmpFil:SetFields( aStruTmp )
		__oTmpFil:AddIndex( '01', {'TMPFIL'} )
		__oTmpFil:Create()

		cTable	:= __oTmpFil:GetRealName()
				
		cInsert := " INSERT INTO " + cTable  + "  (TMPFIL)  "
		For nFil := 1 to Len(aSelFils)
			cAtualxFil := Iif(lFilOrig, aSelFils[nFil][2], xFilial(cCompAlias,aSelFils[nFil][2]) ) 
			cInsertValue := " VALUES ('" + cAtualxFil + "')  "
			TcSqlExec( cInsert + cInsertValue)
		Next nFil                      

		( cTmpFil )->(DbGoTop())
	Else
		cTable	:= __oTmpFil:GetRealName()
	EndIf
		

	If Upper(TcGetDb()) $ "MSSQL7"
		cTable := StrTran (cTable,'dbo.') 
	EndIf

	cFilIn := "( SELECT TMPFIL FROM " + cTable + ")"
EndIf
Return cFilIn 
//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelTmpFil()

Limpa a tabela temporária criada para seleção de filiais

@author Karen
@since 07/06/2021
@version 1.0

/*/ 
//-------------------------------------------------------------------
Static Function TafDelTmpFil() As Character
	If __oTmpFil <> Nil
		__oTmpFil:Delete()
		__oTmpFil := Nil
	Endif
	__cLayFil := ""
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TamEUF()

Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

@author
@since
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function TAFTamEUF(cLayout)

	Local aTam 	As Array
	Local nAte 	As Numeric
	Local nlA 	As Numeric
	Default cLayout := Upper(AllTrim(SM0->M0_LEIAUTE))

	aTam := {0,0,0}
	nAte := Len(cLayout)
	nlA	 := 0

	For nlA := 1 to nAte
		if Upper(substring(cLayout,nlA,1)) == "E"
			++aTam[1]
		elseif Upper(substring(cLayout,nlA,1)) == "U"
			++aTam[2]
		elseif Upper(substring(cLayout,nlA ,1)) == "F"
			++aTam[3]
		endif
	Next nlA

Return aTam



//-------------------------------------------------------------------
/*/{Protheus.doc} TamTafXProf
Manupulação de Profile para gravar preferencias

@author
@since
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function TafXProf( nOpc, aParamX )
	Local nJ			as numeric
	Local  nX			as numeric
	Local cBarra 		as char
	Local cUserName		as char
	Local cNomeProf 	as char
	Local aParLoad		as array
	Local aAuxPar		as array
	Local lRetorno		as logical
	Local cJsonProf		as char
	Local aObjProf		as array
	Local cArquivo		as char
	Local cWrite		as char
	
	Private cLinha		as char
	
	Default nOp 		:= 1
	nJ			:= 0
	nX			:= 0
	cBarra 		:= 	Iif ( IsSrvUnix() , "/" , "\" )
	cUserName	:= __cUserID
	cNomeProf	:= FunName() +"_" +cUserName
	aParLoad	:= {}
	aAuxPar		:= {}
	lRetorno	:= .F.
	cJsonProf	:= ""
	aObjProf	:= Nil
	cLinha		:=	""
	cArquivo	:= cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" 
	cWrite		:= ""

	If nOpc == 1 // Load
		
		If !ExistDir ( cBarra + "PROFILE" + cBarra )
			Makedir ( cBarra + "PROFILE" + cBarra )
		EndIf

		If File(cArquivo)
		
			If FT_FUse(cArquivo ) <> -1
		
				FT_FGoTop()
				While ( !FT_FEof() )
					cLinha := FT_FReadLn() 
					//aAdd(aParLoad,&(cLinha))
					cJsonProf += cLinha 
					FT_FSkip ()
				Enddo		
				If FT_FUse() <> -1
					lRetorno := .T.
				EndIf
				
				// Deserializa a String JSON 
				If FwJsonDeserialize(cJsonProf, @aObjProf)
					If Len(aObjProf) == Len(aParamX)
						For nJ := 1 To Len(aObjProf)
							aParamX[nJ] := aObjProf[nJ]
						Next nJ
					Else
						lRetorno := .F.
					EndIf
				Else
					//Apago o arquivo quando não está de acordo para que na proxima execução
					//o sistema recrie corretamente evitando error.log.
					FErase(cArquivo,,.T.)
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	ElseIf nOpc == 2 //Save
		cWrite := FwJsonSerialize( aParamX )
		lRetorno := MemoWrite ( cArquivo , cWrite )
	EndIf

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafInfoReinf
Exibe uma tela com as principais rotinas da Reinf e a data de atualização.
@author Roberto Souza
@since 04/05/2018
@version 12.1.17
@return

/*/ 
//-------------------------------------------------------------------
Function TafInfoReinf()
	Local Nx 		as numeric
	Local aInfo 	as array
	Local aBase		as array
	Local aCoord 	as array
	Local aCabec	as array

	Nx               := 0
	aInfo            := {}
	aBase            := {}
	aCoord           := {000, 000, 500, 900}
	aCabec           := {}
	__cEvtTot        := GetTotalizerEventCode("evtTot")
	__cEvtTotContrib := GetTotalizerEventCode("evtTotContrib")

	AADD( aBase ,{ "TafxReinf.prw" ,STR0097 			})//"Interface de apuração EFD-Reinf" })
	AADD( aBase ,{ "TafAPR1000.prw",STR0098 + " R-1000" })//"Rotina de apuração"
	AADD( aBase ,{ "TafAPR1070.prw",STR0098 + " R-1070" })
	AADD( aBase ,{ "TafAPR2050.prw",STR0098 + " R-2050" })
	AADD( aBase ,{ "TafAPR2060.prw",STR0098 + " R-2060" })
	AADD( aBase ,{ "TafAPRCP.prw"  ,STR0098 + " R-2010 / R-2020" })
	AADD( aBase ,{ "TafAPRECAD.prw",STR0098 + " R-2030 / R-2040" })	
	AADD( aBase ,{ "TafAPR3010.prw",STR0098 + " R-3010" })
	AADD( aBase ,{ "TafAPR2099.prw",STR0098 + " R-2099" })

	AADD( aBase ,{ "TAFAPR4020.prw",STR0098 + " R-4020" })	
	AADD( aBase ,{ "TAFAPR4010.prw",STR0098 + " R-4010" })	
	AADD( aBase ,{ "TAFQRY40XX.prw",STR0098 + " R-4010 / R-4020" })	
	
	AADD( aBase ,{ "TAFA494.prw",STR0099 + " R-1000"				}) //"Cadastro do Evento"
	AADD( aBase ,{ "TAFA495.prw",STR0099 + " R-1070"				})
	AADD( aBase ,{ "TAFA486.prw",STR0099 + " R-2010"				}) 	
	AADD( aBase ,{ "TAFA478.prw",STR0099 + " R-2020"				})
	AADD( aBase ,{ "TAFA255.prw",STR0099 + " R-2030"				})
	AADD( aBase ,{ "TAFA491.prw",STR0099 + " R-2040"				})
	AADD( aBase ,{ "TAFA492.prw",STR0099 + " R-2050"				})
	AADD( aBase ,{ "TAFA499.prw",STR0099 + " R-2060"				})
	AADD( aBase ,{ "TAFA493.prw",STR0099 + " R-3010"				})
	AADD( aBase ,{ "TAFA496.prw",STR0099 + " R-2099"				})
	AADD( aBase ,{ "TAFA501.prw",STR0099 + " " + __cEvtTot			})
	AADD( aBase ,{ "TAFA497.prw",STR0099 + " " + __cEvtTotContrib	})
	AADD( aBase ,{ "TAFA490.prw",STR0099 + " R-9000"				})

	//Bloco 40
	AADD( aBase ,{ "TAFA545.prw",STR0099 + " R-4010" })
	AADD( aBase ,{ "TAFA546.prw",STR0099 + " R-4020" })
	AADD( aBase ,{ "TAFA543.prw",STR0099 + " R-4040" })

	For Nx := 1 To Len( aBase )
		aRet := GetAPOInfo( aBase[Nx][01] ) 
		If !Empty( aRet )
			AADD( aRet , aBase[Nx][02] )
			AADD( aInfo ,aRet )
		EndIf	
	Next
	aCabec := {STR0100 , STR0101 , STR0102 , STR0103 , STR0104 , STR0015} //"Programa","Tipo","Build","Data","Hora", "Descrição"
	TaflistBox(,aCoord, aCabec , aInfo, {60,25,25,25,25,50},,,,"EFD-Reinf",STR0093) //"Versões - EFD-Reinf"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CtrChkFl
Rotina para tratar a Marcação das Filiais afim de centralizar 
ou descentralizar as informações.
@author Denis Souza
@since 03/07/2018
@version 1.0 

@aParam	
oListEmp - Objeto lista empresas/filiais

@return
lRet - Efetua ou Não a Marcação 
/*/
//-------------------------------------------------------------------
Static Function CtrChkFl( oListEmp )
	
	Local aList 	As array
	Local lRet		As logical
	Local nMarked 	As numeric

	aList 	:= aClone( oListEmp:AARRAY )
	lRet	:= .T.
	nMarked := GetNumMkd( aList )
	
	//Se estiver com .T. significa que sera desabilitada
	if nMarked == 1 .And. aList[oListEmp:nAt][1] 
		lRet := .F.
		MsgAlert(STR0089) //#"Não é possível desmarcar todas as filiais."
	endif

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FLoadProf
Lê arquivo de profile e "alimenta" os parâmetros
@author Leonardo Kichitaro
@since 19/04/2018
@version 1.0
@return ${lRetorno}, ${Informa se a rotina foi executada com sucesso}
/*/
//--------------------------------------------------------------------
Static Function FLoadProf(aParamRei)
	Local nJ			as numeric
	Local cBarra 		as char
	Local cUserName		as char
	Local cNomeProf 	as char
	Local aParLoad		as array
	Local aAuxPar		as array
	Local lRetorno		as logical
	Local cJsonProf		as char
	Local aObjProf		as array
	Local cArquivo		as char
	Private cLinha		as char
	
	nJ			:=	0
	cBarra 		:= 	Iif ( IsSrvUnix() , "/" , "\" )
	cUserName	:= __cUserID
	cNomeProf 	:= ""
	aParLoad	:= {}
	aAuxPar		:= {}
	lRetorno	:= .F.
	cJsonProf	:= ""
	aObjProf	:= Nil
	cLinha		:=	""
	cArquivo	:= ""
	
	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf
	
	cNomeProf	:=	FunName() +"_" +cUserName
	cArquivo := cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" 
	If File (cArquivo)
	
		If FT_FUse (cArquivo ) <> -1
	
			FT_FGoTop ()
			While ( !FT_FEof () )
				cLinha := FT_FReadLn () 
				//aAdd(aParLoad,&(cLinha))
				cJsonProf += cLinha 
				FT_FSkip ()
			Enddo		
			If FT_FUse() != -1
				lRetorno := .T.
			EndIf
			
			// Deserializa a String JSON 
			If FwJsonDeserialize(cJsonProf, @aObjProf)
				If Len(aObjProf) == Len(aParamRei)
					For nJ := 1 To Len(aObjProf)
						If nJ <> 15 .And. nJ <> 14  //filiais e paramTAFKEY não devem ser reaproveitáveis
							aParamRei[nJ] := aObjProf[nJ]
						EndIf
					Next nJ
				Else
					lRetorno := .F.
				EndIf
			Else
				//Apago o arquivo quando não está de acordo para que na proxima execução
				//o sistema recrie corretamente evitando error.log.
				FErase(cArquivo,,.T.)
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
Return (lRetorno)

//--------------------------------------------------------------------
/*/{Protheus.doc} FSalvProf
Grava os Parâmentros em um arquivo de profile
@author Leonardo Kichitaro
@since 19/04/2018
@version 1.0
@return ${boolean}, ${A função MemoWrite Retorna True ou False}
/*/
//--------------------------------------------------------------------
Static Function FSalvProf (aParamRei)
	Local  nX			as numeric
	Local  cWrite		as char
	Local  cBarra		as char
	Local  lRet			as logical	    
	Local  cUserName	as char
	Local  cNomeProf 	as char
	
	nX			:= 0
	cWrite		:= ""
	cBarra		:= If ( IsSrvUnix () , "/" , "\" )
	lRet		:= .F.	    
	cUserName	:= __cUserID
	cNomeProf 	:= ""
		
	// --> Gera a string em formato JSON
	cWrite := FwJsonSerialize(aParamRei)
		
	cNomeProf	:=	FunName() +"_" +cUserName
		
Return (MemoWrite ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" , cWrite ))

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkFils
Rotina realizada para adicionar o evento de click na primeira coluna do header e 
marcar/desmarcar todas as filiais.
@author Matheus Prada
@since 12/08/2019
@version 1.0 

@aParam	
oBrw e nCol - São usados para identificar qual coluna está sendo clicada
oListEmp:AARRAY - Array do objeto de empresas
/*/
//-------------------------------------------------------------------
Static Function ChkFils(oBrw, ncol, bAtuPeriodo)

Local	nCount	:= 0
Local	lMarked	:= .F.

	If nCol == 1

		For nCount := 1 To Len(oListEmp:AARRAY)
			If oListEmp:AARRAY[nCount][F_CANCHECK] == .T. .AND. ( oListEmp:AARRAY[nCount][F_MARK] == .F. ) //Verifica se existe uma filial que podia estar selecionada mas não está
				lMarked := .T.
				Exit
			EndIF
		Next

		For nCount := 1 To Len(oListEmp:AARRAY)
			If lMarked
				If oListEmp:AARRAY[nCount][F_CANCHECK] == .T.
					If oListEmp:AARRAY[nCount][F_MARK] == .F. //Marca todas as filiais se exister 1 que podia mas não está selecionada
						oListEmp:AARRAY[nCount][F_MARK] := .T.
					EndIf
				EndIf
			Else
				
				If oListEmp:AARRAY[nCount][F_MARK] == .T. .AND. oListEmp:AARRAY[nCount][F_CANCHECK] == .T.
					
					If AllTrim( oListEmp:AARRAY[nCount][F_C1E_FILTAF] ) != Alltrim( cFilAnt )
						oListEmp:AARRAY[nCount][F_MARK] := .F.
					EndIf
				EndIf
			
			EndIf
		Next

		Eval(bAtuPeriodo)//Atualiza o status dos eventos de acordo com as filiais selecionadas
	EndIf

	oBrw:Refresh()

return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} RelREINF
Rotina realizada para executar o relatório do REINF selecionado.
@author Matheus Prada
@since 18/10/2019
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function RelREINF(aEventos, nAt, cPeriodo, aFiliais)

	If aEventos[nAt][03] $ "R-2010|R-2020"
		TAFARCP(cPeriodo, ValidFils(aFiliais), aEventos[nAt][03])
	ElseIf aEventos[nAt][03] $ "R-2050"
		If findFunction('TAFAR2050')	
			TAFAR2050(cPeriodo, ValidFils(aFiliais))
		EndIf	
	Else
		MsgAlert(STR0106) // "Relatório válido apenas para os eventos R-2010, R-2020 e R-2050 no momento."
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewLegFil
Tela de legenda do quadro Filiais 
@author Wesley Pinheiro	
@since 27/01/2020
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function ViewLegFil( )
	Local aCores   

	aCores := {	{ LegAccMode( "BR_VERDE" )   ,STR0128, },; // "Mesma Raiz CNPJ ( selecionável para apuração )"
			    { LegAccMode( "BR_VERMELHO" ),STR0129, }}  // "Raiz CNPJ diferente ( não selecionavel para apuração )"	

	BrwLegenda( STR0127,, aCores ) // "Legenda Filiais"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CountFil
Rotina que contará quantas filiais existem com o mesmo CNPJ
@author Matheus Prada
@since 17/01/2019
@version 1.0 
/*/
//-------------------------------------------------------------------
Function CountFil(cAlias, lIdProc)

Local nX		as numeric
Local nTotal	as numeric
Local lPROCID	as logical
Local aCount	as array
Local aGetSM0	as array

nX		:= 0
nTotal	:= 0
aCount	:= {}
aGetSM0 := SM0->(GetArea()) 
lPROCID := .F.

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

While (cAlias)->(!Eof())

	If Empty((cAlias)->NRINSC)
		If (cAlias)->VALOR > 0
			AADD( aCount, Posicione("SM0",1,cEmpAnt+(cAlias)->FILIAL, "M0_CGC"))

			While aScan( aCount, {|x| Alltrim( x ) == Alltrim(Posicione("SM0",1,cEmpAnt+(cAlias)->FILIAL, "M0_CGC")) } ) > 0 .AND. (cAlias)->(!Eof())
				If Empty((cAlias)->PROCID) 
					lPROCID := .T.
				EndIf
				(cAlias)->(DbSkip())
			EndDo

			If lIdProc
				nTotal := Iif(!lPROCID,nTotal+1,nTotal)
			Else
				nTotal := Iif(lPROCID,nTotal+1,nTotal)
			EndIf

			lPROCID := .F.
		Else
			(cAlias)->(DbSkip())
		EndIf

	Else

		If (cAlias)->V48VATIV > 0
			AADD( aCount, (cAlias)->NRINSC)
			
			While aScan( aCount, {|x|  x == (cAlias)->NRINSC } ) > 0 .AND. (cAlias)->(!Eof())
				If Empty((cAlias)->V48PROCID) 
					lPROCID := .T.
				EndIf
				(cAlias)->(DbSkip())
			EndDo

			If lIdProc
				nTotal := Iif(!lPROCID,nTotal+1,nTotal)   
			Else
				nTotal := Iif(lPROCID,nTotal+1,nTotal) 
			EndIf

			lPROCID := .F.
		Else
			(cAlias)->(DbSkip())
		EndIf

	EndIf

EndDo
RestArea(aGetSM0)
(cAlias)->(DbCloseArea())

Return nTotal

//------------------------------------------------------------------------------------
/*/{Protheus.doc} NewPaREINF
Apresenta mensagem de descontinuação do painel REINF.
@type			Function
@author			Felipe Guarnieri
@since			12/11/2020
@version		1.0
@param			
@Return			null
/*/
//------------------------------------------------------------------------------------
Function NewPaREINF()
	
	Local cButton	:= ""
	Local cMsg  	:= ""	
	Local lReturn	:= .F.
	Local oModal 	:= Nil
	Local oBtn1		:= Nil
	Local oBtn2		:= Nil
	Local oFontText	:= TFont():New('Arial',, -16, .T.)
	Local oFontBtn	:= TFont():New('Arial',, -16, .T., .T.,,,,, .T.)
	
	//Configurando a janela para apresentação	
	oModal := FWDialogModal():New()

	oModal:SetEscClose(.T.)
	oModal:SetTitle(STR0133) 						// "Utilize o novo Painel Reinf!"
	oModal:SetSize(160, 400)
	oModal:CreateDialog()
	
	If GetRPORelease() == "12.1.2210"
		cMsg  	:= STR0130 + CRLF + CRLF 			// "Prezado cliente"
		cMsg	+= STR0131 + CRLF + CRLF			// "Para realizar consultas e transmissões dos eventos e obrigações do EFD-Reinf, utilize o novo Painel Reinf."
		cMsg	+= STR0132							// "Clique nos links abaixo para saber o passo a passo, de como configurar o novo Painel Reinf e também conhecê-lo com mais detalhes."

		cButton	:= STR0137							// "Fechar"
		lReturn := .T.
	Else
		cMsg 	:= STR0130 + CRLF + CRLF			// "Prezado cliente"
		cMsg 	+= STR0134 + CRLF + CRLF			// "Esta rotina já se encontra em processo de substituição e ficará obsoleta a partir do dia 01/04/2022, nenhuma nova melhoria será implementada nesta rotina e novas legislações da EFD REINF serão entregues somente através do novo painel REINF."
		cMsg 	+= STR0135							// "Programe URGENTEMENTE a utilização do novo painel REINF !!!"
	
		cButton	:= STR0136							// "Estou ciente"
	EndIf

	oModal:addCloseButton(Nil, cButton)

	//Faz o imput da mensagem na tela.
	TSay():New(30, 15, {|| cMsg},,, oFontText,,,, .T.,,, 350, 100,,,,,, .T.)
	
	//Cria o botão com link para de *Como configurar o Painel REINF* 
	oBtn1 := THButton():New(110, 010, STR0138,, {|| ShellExecute("Open", "https://tdn.totvs.com/pages/releaseview.action?pageId=528452172", "", "C:\", 1 )}, 150, 20,oFontBtn, STR0138) 	// "Como configurar o Painel REINF"
	
	oBtn1:SetCss("QPushButton{ color: #21a4c4; }")
	
	//Cria o botão com link para de *Novo Painel REINF* 
	oBtn2 := THButton():New(110, 200, STR0139,, {|| ShellExecute( "Open", "https://tdn.totvs.com/display/TAF/Painel+REINF", "", "C:\", 1 )}, 150, 20, oFontBtn, STR0139) 					// "Conheça a nova rotina do Painel REINF"
	
	oBtn2:SetCss("QPushButton{ color: #21a4c4; }")
		
	//Ativa o objeto
	oModal:Activate()

Return lReturn

/*/{Protheus.doc} IniVar
Realiza a inicialização das variaveis statics
@type			Function
@author			Wesley Matos
@since			04/10/2022
@version		1.0
@param			
@Return			null
/*/

Static Function IniVar()

if _TmFilTaf == Nil
 
	_TmFilTaf := TamSX3( "C1E_FILTAF" )[1]
	_TmId 	  := TamSX3( "C1E_ID" )[1]
	_TmCodFil := TamSX3( "C1E_CODFIL" )[1]
	_TmNome   := TamSX3( "C1E_NOME" )[1]

endif

return

/*------------------------------------------------------------------------------------------
{Protheus.doc} GrvSubMdl
@description	Função com o objetivo de gravar os SubModels do MVC espelho do evento R-4010
				quando é feita uma exclusão via R-9000
@author			Carlos Eduardo Boy
@since			18/10/2022
------------------------------------------------------------------------------------------*/
Function GrvSubMdl(oModel, oJsonGrv)
Local lRet 		:= .t.
Local nItens	:= 0
Local nFields	:= 0
Local nModels	:= 0
Local lSubModel := .f.
Local lItens	:= aScan( oJsonGrv:GetNames(), {|x| x == 'items'}) > 0 //Verifica se o submodel tem itens para serem gravados
Local cSubModel	:= oJsonGrv['id'] //Pega o nome do submodel
Local xValue	:= nil
Local cType		:= ''

if lItens
	//Passa item a item do Submodel
	for nItens := 1 to len(  oJsonGrv['items'] )
		
		//Adiciona uma nova linha no grid caso seja necessário!
		if oModel:GetModel(cSubModel):length() < nItens; oModel:GetModel(cSubModel):AddLine(); endif
		
		//Pega nome e conteudo dos campos que precisam ser gravado e carrega no submodel
		for nFields := 1 to len( oJsonGrv['items'][nItens]['fields'] )
			cField := oJsonGrv['items'][nItens]['fields'][nFields]['id']
			if x3uso(getSx3Cache(cField,'X3_USADO')) 

				xValue := oJsonGrv['items'][nItens]['fields'][nFields]:GetJsonText('value')
				if xValue == 'null'; xValue := ''; endif // Verifica se o campo tem contudo para gravar

				cType := oJsonGrv['struct'][nFields]['datatype'] //Pega o tipo de dado do campo
				//Comverte para o tipo correto de dado
				if cType == 'D'
					xValue := stod(xValue)
				elseif cType == 'N'
					xValue := val(xValue)
				endif	
				//Carrega o dado no model
				oModel:LoadValue( cSubModel, cField , xValue )
			endif
		next
		
		//Verifica se tem submodel
		lSubModel := aScan( oJsonGrv['items'][nItens]:GetNames(), {|x| x == 'models'}) > 0
		if lSubModel
			//Faz a chamada da função de gravação dos submodes caso seja necessário
			for nModels := 1 to len(oJsonGrv['items'][nItens]['models'])
				//Chama a gravação dos submodels de forma recursiva.
				GrvSubMdl(oModel, oJsonGrv['items'][nItens]['models'][nModels])
			next
		endif	
	next
endif	

return lRet

/*/{Protheus.doc} GetTotalizerEventCode
	Obtém o Código do Evento Totalizador para a versão do leiaute parametrizada baseado na Tag chave do XML do Totalizador

	@type  Function
	@author Fabio Mendonça
	@since 06/12/2022
	@version 1.0

	@param cTotEvtTag, character, Tag Chave do XML do Totalizador

	@return cRet, character, Código do Evento Totalizador segundo leiaute parametrizado
/*/
Function GetTotalizerEventCode(cTotEvtTag as character) as character

	Local cRet    		as character
	Local nLayoutVer	as numeric
	Local aTotEvtVer	as array
	Local cTotStaticVar	as character

	Default cTotEvtTag	:= ""

	cTotStaticVar	:= "__c" + cTotEvtTag

	// Se variável estática já estiver preenchida, apenas retorna valor existente
	If &(cTotStaticVar) != Nil
		cRet 		:= &(cTotStaticVar)
	Else
		cRet		:= ""
		nLayoutVer	:= IIf(AllTrim(StrTran(SuperGetMv("MV_TAFVLRE", .F., "1_05_01"), "_", "")) < "20000", 1, 2)
		aTotEvtVer	:= Nil

		Do Case
			Case cTotEvtTag == "evtTot"
				aTotEvtVer 	:= {"R-5001", "R-9001"}			
			Case cTotEvtTag == "evtTotContrib"	
				aTotEvtVer 	:= {"R-5011", "R-9011"}		
		EndCase

		If aTotEvtVer != Nil
			cRet				:= aTotEvtVer[nLayoutVer]

			&(cTotStaticVar)	:= cRet
		EndIf
	EndIf
	
Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafBdVers
@type			function
@description	Retorna versao do Oracle
@author			Denis Souza
@since			08/03/2023
@param			cDb	- banco de dados
@return			cVersion - Versao do banco ex:
'ORACLE DATABASE 11G EXPRESS EDITION RELEASE 11.2.0.2.0 - 64BIT PRODUCTION'
/*/
//---------------------------------------------------------------------
Function TafBdVers( lAutomato )

Local cVersion 	as Character
Local cQuery	as Character
Local cDb 		as Character
Local cNextAlias as Character

Default lAutomato := .F.

If __lRowNum == NIL

	cQuery	   := ''	
	cVersion   := ''
	cDb 	   := TAFGetDB()
	cNextAlias := ''
	__lRowNum	   := .F.	 

	If "ORA" $ cDb
		cQuery := "SELECT UPPER(BANNER) VERSION FROM v$version WHERE UPPER(BANNER) LIKE '%ORACLE%' "
	ElseIf "MSSQL" $ cDb
		cQuery := "SELECT CAST( SERVERPROPERTY('productversion') AS VARCHAR(128)) VERSION "
	ElseIf "INFORMIX" $ cDb .or. "DB2" $ cDb 
		__lRowNum := .T.
	EndIf

	If !Empty(cQuery) 

		cNextAlias := MPSysOpenQuery(cQuery)

		While ( cNextAlias )->( !Eof() )
			cVersion += UPPER(AllTrim( ( cNextAlias )->VERSION ))
			If "ORA" $ cDb
				If "11G" $ cVersion .Or. "ORACLE DATABASE 11" $ cVersion
					__lRowNum := .T.
				EndIf
                If "10G" $ cVersion .Or. "ORACLE DATABASE 10" $ cVersion .or. lAutomato
                    __lRowNum := .T.
                EndIf
			ElseIf "MSSQL" $ cDb
				If Val(Substr(cVersion,1,At(".", cVersion)-1)) <= 10
					__lRowNum := .T.
				EndIf			
			EndIf
			( cNextAlias )->( DBSkip() )
		EndDo

		( cNextAlias )->( DBCloseArea() )
	EndIf
EndIf
Return __lRowNum

//-------------------------------------------------------------------
/*/{Protheus.doc} TafBindQry()

Funcao generica de bind e execucao de query com FwExecStatement e OpenAlias

@author Denis Souza
@since	30/12/2024
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function TafBindQry(cQry, oPrepare, aBind, cAliasApr)

	Local nI   		as Numeric
	Local nAte 		as Numeric
	Local cTypeBind as character

	Default cQry   	  := ''
	Default oPrepare  := nil
	Default aBind	  := {}
	Default cAliasApr := ''

	nI		  := 0
	nAte	  := Len(aBind)
	cAliasApr := GetNextAlias()
	cTypeBind := ''
	cQry	  := ChangeQuery(cQry)
	oPrepare  := FwExecStatement():New( cQry )

	For nI := 1 To nAte
		cTypeBind := Valtype(aBind[nI])
		If cTypeBind == 'C'
			oPrepare:setString( nI, aBind[nI] )
		ElseIf cTypeBind == 'A'
			oPrepare:setIn( nI, aBind[nI] )
		ElseIf cTypeBind == 'N'
			oPrepare:setNumeric( nI, aBind[nI] )
		Endif
	Next nI

	oPrepare:cbasequery := oPrepare:getfixquery()

	oPrepare:OpenAlias(cAliasApr)

	aSize(aBind,0)
	aBind := {}

Return Nil
