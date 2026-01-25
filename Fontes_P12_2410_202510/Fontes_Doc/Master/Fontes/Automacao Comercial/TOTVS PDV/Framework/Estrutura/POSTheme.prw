#INCLUDE "protheus.ch"
#INCLUDE "poscss.ch"

STATIC __ISFLY01 :=  FindFunction('ISFly01') .AND. ISFly01() 
STATIC __aColors := IIF(__ISFLY01, {'FF9300','F37021','F16E01','FF8000','FFA200'}, FWGetMonocromatic( "07334C" ) )
STATIC __aRGBColors 
STATIC __lHTML := FindFunction( "GetRemoteType" ) .And. GetRemoteType() == REMOTE_HTML

#DEFINE GET_CSS_FOCAL "QLineEdit:Focus { color: #"+__aColors[2]+"; background-color: #FFFFFF; border: 1px solid #"+__aColors[2]+";  }"

Static lClientHtml	:= GetCliHTML()

//-------------------------------------------------------------------
/*/{Protheus.doc} POSBaseColor
Seta a cor base a ser usada pelo gerador de CSS

@param cBaseColor Cor usada a ser usada como base para o css. Ex.: "FF5476"

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function POSBaseColor( cBaseColor )
	
	Local aRet := {}
	
	If !__ISFLY01
		aRet := FWGetMonocromatic( cBaseColor ) 
	
		__aColors := aRet
		CalcRgbColor(__aColors)
	EndIf

Return

//Converte para RGB as cores padroes em hexa
Static Function CalcRgbColor(aColors)
Local aRGBColor := {}
Local nX 

If aColors <> nil
	For nX := 1 to len(aColors)
	
		AADD(aRGBColor , {	Str(HexToDec( Subs(aColors[nX], 1, 2) )), ;
							  	Str(HexToDec( Subs(aColors[nX], 3, 2) )), ;
								Str(HexToDec( Subs(aColors[nX], 5, 2) ) ) } )						
		
	Next nX
EndIf
__aRGBColors := aClone(aRGBColor)
aRGBColor := ASize(aRGBColor,0)
Return 

Function GetPOSColors()

Return __aColors

//-------------------------------------------------------------------
/*/{Protheus.doc} POSCSS
Função responsável por retornar o CSS do componente passado por parâmetro

@param nType Numérico com o tipo do CSS a ser retornado
@param xPar01 Parâmetro opcional utilizado em alguns casos para complemento do CSS

@return cCSS String com o CSS solicitado

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function POSCSS( cAdvPLComp, nType, xPar01 )

	Local cCSS := ""
	
	Local cBGColor := "FFFFFF"

	Local nPxBrowse := 12 	// Pixel para Browse
	Local nPxNormal := 13	//Pixel para Label Normal(padrao)
	
		
	If oMainWnd:nClientWidth > 1300 .AND. oMainWnd:nClientWidth < 1600 //ENTRE 1300 E 1600 
		nPxBrowse:= 14
	Elseif oMainWnd:nClientWidth > 1600  .AND. oMainWnd:nClientWidth < 1900 //ENTRE 1900 E 1600
		nPxBrowse:= 16
	Elseif oMainWnd:nClientWidth > 1900 //MAIOR QUE 1900
		nPxBrowse:= 18
	Endif 

	If IsInCallStack("STIRodape") 
		 nPxNormal := 18
	Endif 

	If __aColors == nil
		return cCSS
	EndIf
	
	If __aRGBColors == nil
		CalcRgbColor(__aColors)
	EndIf

	Do Case
		Case nType == CSS_BG
			If FWIsMobile()
				cCSS += "Q3Frame { border: none; background-color: #DDDDDD; }"
			Else
				cCSS += "Q3Frame { fonte-size:12px; border: none; background-color: #"+__aColors[2]+"; }"
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "Q3Frame", cCSS )

		Case nType == CSS_BAR_TOP
			If FWIsMobile()
				cCSS += "Q3Frame { border: none; background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #"+__aColors[4]+", stop: 1 #"+__aColors[3]+"); }"
			Else
				cCSS += "Q3Frame { fonte-size:12px ; border: none; background-color: #"+__aColors[3]+"; }"
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "Q3Frame", cCSS )

		Case nType == CSS_BAR_BOTTOM
			If FWIsMobile()
				cCSS += "Q3Frame { border: none; border-top: "+FWResAdjSize(0.5)+"px solid #FFFFFF; background-color:  qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #F3F3F3, stop: 1 #D9D9D9);  }"
			Else
				cCSS += "Q3Frame {fonte-size:12px; border: none; background-color: #"+__aColors[3]+"; }"
			EndIf

			cCSS := FWCSSVerify( cAdvPLComp, "Q3Frame", cCSS )

		Case nType == CSS_BAR_ALERT
			If FWIsMobile()
				cCSS += "QLabel { font: bold "+FWResAdjSize(14)+"px; color: #666666; }"
			Else
				cCSS += "QLabel { font-weight: bold; font-size: 32px; color: #FFFFFF; }"
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )

		Case nType == CSS_BAR_BUTTON
			
			If FWIsMobile()
				cCSS += "QPushButton{ font: bold "+FWResAdjSize(13)+"px; color: #FFFFFF; border:none; " +; 
						"background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #"+__aColors[5]+", stop: 1 #"+__aColors[4]+"); " +;
						"outline :none; " 
						
				If xPar01
					cCSS +=	"qproperty-icon:url(rpo:fwskin_menu_hamburguer.svg); qproperty-iconSize: "+FWResAdjSize(26)+"px;" 	
					cCSS +=	"border-right: "+FWResAdjSize(0.5)+"px solid #"+__aColors[3]+";" 					
				EndIf
				cCSS += " }"		
						
			Else
				cCSS +=	 "QPushButton{ font-weight: bold; font-size: 12px; color: #FFFFFF; background: #"+__aColors[2]+"; border: none; }"
				cCSS +=	 "QPushButton:pressed{ background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, " + ;
									"stop: 0.0 #"+__aColors[3]+", stop: 0.5 #"+__aColors[1]+", stop: 0.5 #"+__aColors[1]+", stop: 1.0 #"+__aColors[2]+"); }"

			EndIf
			cCSs += "QPushButton::menu-indicator{ image:none; }"
			cCSS := FWCSSVerify( cAdvPLComp, "QPushButton", cCSS )

		Case nType == CSS_BAR_INFO
			If FWIsMobile()
				cCSS += "QLabel { qproperty-alignment:'AlignVCenter | AlignRight'; font: "+FWResAdjSize(12)+"px; color: #666666; padding-right:"+FWResAdjSize(5)+"px; }"
			Else
				cCSS += "QLabel { font-size: 12px; color: #FFFFFF; }"
			EndIf

			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )

		Case nType == CSS_BAR_LOGO
			If FWIsMobile()
				cCSS += "Q3Frame { border: none; background-color:  qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #F3F3F3, stop: 1 #D9D9D9);  }"
		
			Else
				cCSS += "Q3Frame { border: none; background-color: #"+__aColors[2]+"; box-shadow: 10px 10px 5px #888888; }"
			EndIf
			
			cCSS := FWCSSVerify( cAdvPLComp, "Q3Frame", cCSS )

		Case nType == CSS_BAR_MENU
			If FWIsMobile()
					
				cCSS += 'QMenu{ font: bold; font-size:  '+FWResAdjSize(13)+'px; font-family: "Arial"; color: #FFFFFF; background-color: #'+__aColors[5]+'; ' + ;
								"border-style: solid; border-left-width: "+FWResAdjSize(1)+"px; " + ;
								"border-right-width: "+FWResAdjSize(1)+"px; border-bottom-width: "+FWResAdjSize(1)+"px; " + ;
								"border-color: #"+__aColors[2]+"; width: "+ FWResAdjSize(Int(xPar01) )+ "px; }"
				cCSS += "QMenu::item{ padding: "+FWResAdjSize(15)+"px; padding-left: "+FWResAdjSize(25)+"px; border-style: solid; " + ;
								"border-bottom-width: "+FWResAdjSize(1)+"px; border-color: #"+__aColors[2]+"; }"
					
			Else
				cCSS += 'QMenu{ font-weight: bold; font-size: 13px; font-family: "Arial"; color: #FFFFFF; background-color: #'+__aColors[2]+'; ' + ;
								"border-style: solid; border-left-width: 1px; " + ;
								"border-right-width: 1px; border-bottom-width: 1px; " + ;
								"border-color: #"+__aColors[3]+"; width: "+AllTrim(Str(xPar01))+"px; }"
				cCSS += "QMenu::item{ padding: 10px; padding-left: 25px; border-style: solid; " + ;
								"border-bottom-width: 1px; border-color: #"+__aColors[3]+"; }"
				cCSS += "QMenu::item:selected{ background-color: #"+__aColors[3]+";}"
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "QMenu", cCSS )

		Case nType == CSS_BTN_FOCAL
			If FWIsMobile()
				cCSS +=	 "QPushButton{ font-size:  "+FWResAdjSize(13)+"px; font: bold large; padding: "+FWResAdjSize(4)+"px; color: #FFFFFF; " + ;
									"outline :none; "+;
									"background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #"+__aColors[1]+", stop: 1 #"+__aColors[3]+"); " +;
									"border: "+FWResAdjSize(1)+"px solid #"+__aColors[2]+"; border-radius: "+FWResAdjSize(6)+"px; }"
				cCSS +=	 "QPushButton:pressed { padding: "+FWResAdjSize(4)+"px; color: #FFFFFF; " + ;
									"background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #"+__aColors[3]+", stop: 1 #"+__aColors[1]+"); " +;
									"border: 1px solid #"+__aColors[2]+"; border-radius: 6px; }"
				cCSS +=	 "QPushButton:disabled{background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 rgba("+__aRGBColors[1][1]+" ,"+__aRGBColors[1][2]+","+__aRGBColors[1][3]+",50%), stop: 1 rgba("+__aRGBColors[3][1]+" ,"+__aRGBColors[3][2]+","+__aRGBColors[3][3]+",50%));" +;
						" border: 1px solid rgba("+__aRGBColors[2][1]+" ,"+__aRGBColors[2][2]+","+__aRGBColors[2][3]+"50%); color: #FFFFFF; }"
			Else
				cCSS += "QPushButton{ font-size: 13px; padding: 6px; background: #"+__aColors[4]+"; " + ;
								"border: 1px solid #"+__aColors[4]+"; border-radius: 6px; " + ;
								"background-image: linear-gradient(180deg, #3dafcc 0%,#0d9cbf 100%); "
				If !__lHTML
					cCSS += "color: #FFFFFF;"
				EndIf

				cCSS += "}"
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "QPushButton", cCSS )
			
		Case nType == CSS_BTN_NORMAL
			If FWIsMobile()
				cCSS +=	 "QPushButton{ font-size: "+FWResAdjSize(12)+"px; font: bold large; padding: "+FWResAdjSize(4)+"px; color: #777777; " + ;
									"outline :none; "+;
									"background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #FFFFFF, stop: 1 #E9EBF1); " +;
									"border: "+FWResAdjSize(1)+"px solid #BBBBBB; border-radius: "+FWResAdjSize(6)+"px; }"
				cCSS +=	 "QPushButton:pressed { font: bold large; padding: "+FWResAdjSize(4)+"px; color: #777777; " + ;
									"background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #E9EBF1, stop: 1 #FFFFFF); " +;
									"border: "+FWResAdjSize(1)+"px solid #BBBBBB; border-radius: "+FWResAdjSize(6)+"px; }"
				cCSS +=	 "QPushButton:disabled{background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 rgba(255,255,255,50%), stop: 1 rgba(233,235,241,50%));" +;
						" border: "+FWResAdjSize(1)+"px solid rgba(187,187,187,50%); color: rgba(119,119,119,50%); }"
						
			Else
				
				cCSS +=	 "QPushButton {font-weight: bold;font-size: 12px ; " + ;
						"padding: 4px; color: #858585; background: #FFFFFF; outline :none; " + ;
						" border: 1px solid #D4D4D4; border-bottom-color: #A4A4A6; border-radius: 6px; }
				cCSS +=	 "QPushButton:pressed { color: #FFFFFF; " + "background-image: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, " + ;
									"stop: 0.0 #757575, stop: 0.6 #878787, stop: 0.7 #878787, stop: 1.0 #909090); " + ;
									"border: 1px solid #787878; }"
				cCSS +=	 "QPushButton:disabled{ color: #BCBCBC; }"

			Endif
			cCSS := FWCSSVerify( cAdvPLComp, "QPushButton", cCSS )
			
		Case nType == CSS_BTN_ATIVO
			If FWIsMobile()
				cCSS += "QPushButton{ font-size: "+FWResAdjSize(12)+"px; font: bold large; padding: "+FWResAdjSize(6)+"px; color: #FFFFFF; " + ; 
									"background-color: #757575; " + ;
									"outline :none; "+;
									"border: "+FWResAdjSize(1)+"px solid #787878; border-bottom-color: #A4A4A6; border-radius: "+FWResAdjSize(6)+"px; }"
			
		
			Else
				
				if lClientHtml 
					cCSS += "QPushButton{ font-weight: bold; font-size: 12px; padding: 6px; color: #b5b5b5; "
					cCSS +=	"background-image: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, "
					cCSS +=	"stop: 0.0 #757575, stop: 0.6 #878787, stop: 0.7 #878787, stop: 1.0 #909090); "
					cCSS +=	"border: 2px solid #787878; border-bottom-color: #A4A4A6; border-radius: 6px; }"
				Else
					cCSS += "QPushButton{ font-weight: bold; font-size: 12px; padding: 6px; color: #FFFFFF; "
					cCSS +=	"background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, "
					cCSS +=	"stop: 0.0 #757575, stop: 0.6 #878787, stop: 0.7 #878787, stop: 1.0 #909090); " + ;
					"border: 1px solid #787878; border-bottom-color: #A4A4A6; border-radius: 6px; }"
				Endif 
				
			EndIf
								
			cCSS := FWCSSVerify( cAdvPLComp, "QPushButton", cCSS )

		Case nType == CSS_BTN_BUY
			cCSS +=  "QPushButton{ font-size:  "+FWResAdjSize(14)+"px; font: bold large; padding: "+FWResAdjSize(4)+"px; color: #BD2C08; " + ;
									"outline :none; "+;
									"background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #FFFF00, stop: 1 #FFC926); " +;
									"border: "+FWResAdjSize(1)+"px solid #BBBBBB;  }"
			
								
			cCSS := FWCSSVerify( cAdvPLComp, "QPushButton", cCSS )
		
		Case nType == CSS_BTN_LUPA
			cCSS += PosCss( cAdvPLComp, CSS_BTN_NORMAL, xPar01)
			cCSS +=  "QPushButton{ outline :none; qproperty-icon:url(rpo:fwskin_icon_lookup.svg); qproperty-iconSize: "+FWResAdjSize(30)+"px} "
								
			cCSS := FWCSSVerify( cAdvPLComp, "QPushButton", cCSS )
			
		Case nType == CSS_BTN_BARCODE
			cCSS += PosCss( cAdvPLComp, CSS_BTN_NORMAL, xPar01)
			cCSS +=  "QPushButton{ outline :none; qproperty-icon:url(rpo:fwskin_barcode.svg); qproperty-iconSize: "+FWResAdjSize(30)+"px} "
				
								
			cCSS := FWCSSVerify( cAdvPLComp, "QPushButton", cCSS )
		Case nType == CSS_BROWSE
			If FWIsMobile()
				cCSS += "QHeaderView::section { font: bold  "+FWResAdjSize(12)+"px; color: #FFFFFF; background-color: #666666; " + ;
									"border: "+FWResAdjSize(1)+"px solid #666666; height: "+FWResAdjSize(30)+"px; }"
				cCSS += "QTableView{ font: "+FWResAdjSize(12)+"px; alternate-background-color: #EEEEEE; background: #FFFFFF; color: #444444; border: none; " +;
									" selection-background-color: #FFFFFF;}"
			Else
				cCSS += "QHeaderView::section { font-weight: bold; font-size: 12px; color: #FFFFFF; background-color: #"+__aColors[3]+"; " + ;
								"border: 1px solid #"+__aColors[3]+"; height: 30px; }"
				cCSS += "QTableView{ font-size: "+Str(nPxBrowse)+"px; alternate-background-color: #E9E9E9; background: #FFFFFF; color: #000000; border: none; " + ;
								"selection-background-color: #FFFFFF; gridline-color: white; white-space: normal; }"
			EndIf
				         
		Case nType == CSS_BROWSE_HEADER_LEFT
			If FWIsMobile()
				cCSS += "QFrame { margin: 0px 0px 0px "+FWResAdjSize(5)+"px; background-color: #666666; }"
			Else
				cCSS += "QFrame { margin: 0px 0px 0px 5px; background-color: #"+__aColors[3]+"; }"
			EndIf
				
			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )

		Case nType == CSS_BROWSE_HEADER_RIGHT
			If FWIsMobile()
				cCSS += "QFrame { margin: 0px "+FWResAdjSize(10)+"px 0px 0px; background-color: #666666; }"
			Else
				cCSS += "QFrame { margin: 0px "+FWResAdjSize(10)+"px 0px 0px; background-color: #"+__aColors[3]+"; }"
			EndIf
				
			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )

		Case nType == CSS_LISTBOX
			If FWIsMobile()
				
				
				 cCSS += "Q3ListBox{ font:  "+FWResAdjSize(16)+"px; padding: 0px; background-color: #FFFFFF; margin: 0px;  " + ;
									"color: #000000; border: "+FWResAdjSize(1)+"px solid #DDDDDD; }"
				cCSS += "Q3ListBox::item{ padding: "+FWResAdjSize(15)+"px;  border-bottom: " + FWResAdjSize(1 ) + "px solid #DDDDDD;  "+;
						" }"		
				
				cCSS += "Q3ListBox::Item:selected{ background-color: '#"+__aColors[2]+"'; }"							
						
				cCSS += "QScrollBar::handle:vertical{width: "+FWResAdjSize(20)+"px; background: #C2C2C2; border: "+FWResAdjSize(1)+"px solid #C2C2C2; " + ;
									"border-radius: "+FWResAdjSize(3)+"px;}"
				cCSS += "QScrollBar:vertical{ background-color: #F2F2F2; border: "+FWResAdjSize(1)+"px solid #FFFFFF; width: "+FWResAdjSize(10)+"px; margin: "+FWResAdjSize(10)+"px 0px "+FWResAdjSize(10)+"px "+FWResAdjSize(2)+"px;}"
				cCSS += "QScrollBar::add-line:vertical{padding-left: "+FWResAdjSize(2)+"px; border: 0px; height: "+FWResAdjSize(8)+"px; " + ;
									"subcontrol-position: bottom; subcontrol-origin: margin;}"
				cCSS += "QScrollBar::sub-line:vertical{padding-left: "+FWResAdjSize(8)+"px; border: 0px; height: "+FWResAdjSize(8)+"px; " + ;
									"subcontrol-position: top; subcontrol-origin: margin;}"
				cCSS += "QScrollBar::up-arrow:vertical { background-image: url(rpo:pos_scroll_arrow_up.png); " + ;
									"background-repeat: no repeat; width: "+FWResAdjSize(8)+"px; height: "+FWResAdjSize(8)+"px;}"
				cCSS += "QScrollBar::down-arrow:vertical { background-image: url(rpo:pos_scroll_arrow_down.png); " + ;
									"background-repeat: no repeat; width: "+FWResAdjSize(8)+"px; height: "+FWResAdjSize(8)+"px;}"
				
				cCSS += "QWidget{ outline :none;  color:'#444444'; font-family: 'Arial'; " +;
						"  selection-color:'#FFFFFF' ;  }"
				
			Else
			
				cCSS += "Q3ListBox{ font-size: 18px; padding: 4px; background-color: #FFFFFF; margin: 0px; border-radius: 4px; " + ;
									"color: #000000; border: 1px solid #9B9B9B;  }"
				cCSS += "QScrollBar::handle:vertical{width: 20px; background: #C2C2C2; border: 1px solid #C2C2C2; " + ;
									"border-radius: 3px;}"
				cCSS += "QScrollBar:vertical{ background-color: #F2F2F2; border: 1px solid #FFFFFF; width: 10px; margin: 10px 0px 10px 2px;}"
				cCSS += "QScrollBar::add-line:vertical{padding-left: 2px; border: 0px; height: 8px; " + ;
									"subcontrol-position: bottom; subcontrol-origin: margin;}"
				cCSS += "QScrollBar::sub-line:vertical{padding-left: 2px; border: 0px; height: 8px; " + ;
									"subcontrol-position: top; subcontrol-origin: margin;}"
				cCSS += "QScrollBar::up-arrow:vertical { background-image: url(rpo:pos_scroll_arrow_up.png); " + ;
									"background-repeat: no repeat; width: 8px; height: 8px;}"
				cCSS += "QScrollBar::down-arrow:vertical { background-image: url(rpo:pos_scroll_arrow_down.png); " + ;
									"background-repeat: no repeat; width: 8px; height: 8px;}"
				cCSS += "QWidget{ font-size: 13px; font-family: 'Arial'; }"

			EndIf
			
			cCSS := FWCSSVerify( cAdvPLComp, "Q3ListBox", cCSS )

		Case nType == CSS_PANEL_LOGO
			If lClientHtml
					cCSS += "QFrame{ margin: 0px; background-color: #"+cBGColor+"; " + ;
									"border-radius: "+FWResAdjSize(8)+"px; border: "+FWResAdjSize(1)+"px solid #"+cBGColor+"; padding: "+FWResAdjSize(6)+"px; }"
			Else
				cCSS += "QFrame{ margin: "+FWResAdjSize(15)+"px "+FWResAdjSize(5)+"px "+FWResAdjSize(5)+"px "+FWResAdjSize(10)+"px; background-color: #"+cBGColor+"; " + ;
									"border-radius: "+FWResAdjSize(8)+"px; border: "+FWResAdjSize(1)+"px solid #"+cBGColor+"; padding: "+FWResAdjSize(6)+"px; }"
			Endif
			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )

		Case nType == CSS_PANEL_OPTION_TOP
			If lClientHtml
				cCSS += "QFrame{ margin: 0px; border: none; border-bottom: "+FWResAdjSize(1)+"px solid #F4F4F4; " + ;
									"border-radius: 0px; border-bottom-color: #D1D1D1; background-color: transparent; }"
			Else 
				cCSS += "QFrame{ margin: "+FWResAdjSize(10)+"px "+FWResAdjSize(5)+"px 0px "+FWResAdjSize(10)+"px; border: none; border-bottom: "+FWResAdjSize(1)+"px solid #F4F4F4; " + ;
									"border-radius: 0px; border-bottom-color: #D1D1D1; background-color: transparent; }"
			Endif 

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )

		Case nType == CSS_PANEL_CONTENT
			
			cCSS += "QFrame{ background-color: transparent; margin: none; border: none; }"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )

		Case nType == CSS_PANEL_OPTION_BOTTOM
			cCSS += "QFrame{ margin: "+FWResAdjSize(10)+"px "+FWResAdjSize(5)+"px 0px "+FWResAdjSize(10)+"px; border: none; border-top: "+FWResAdjSize(1)+"px solid #F4F4F4; " + ;
								"border-radius: 0px; border-top-color: #D1D1D1; background-color: transparent; }"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )

		Case nType == CSS_PANEL_CONTEXT
			If lClientHtml
				cCSS += "QFrame{ margin: 0px; background-color: #F4F4F4; border: "+FWResAdjSize(1)+"px solid #F4F4F4; "
			Else 
				cCSS += "QFrame{ margin: "+FWResAdjSize(5)+"px "+FWResAdjSize(5)+"px "+FWResAdjSize(15)+"px "+FWResAdjSize(10)+"px; background-color: #F4F4F4; " + ;
								" border: "+FWResAdjSize(1)+"px solid #F4F4F4; " 
			Endif 

			If Empty(xPar01)
				cCSS += " border-radius: "+FWResAdjSize(8)+"px;"					
			EndIf
			
			cCSS += "}"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )

		Case nType == CSS_PANEL_HEADER

			If FWIsMobile()
				cCSS += "QFrame{ margin: "+FWResAdjSize(15)+"px "+FWResAdjSize(10)+"px 0px "+FWResAdjSize(5)+"px; padding: "+FWResAdjSize(6)+"px; border: "+FWResAdjSize(1)+"px solid #"+cBGColor+"; " + ;
								"background-color: #"+cBGColor+"; " + ;
								"border-top-right-radius: "+FWResAdjSize(8)+"px; border-top-left-radius: "+FWResAdjSize(8)+"px; }"
			Else
				If lClientHtml
					cCSS += "QFrame{ margin: 0px; padding: 6px; border: 1px solid #FFFFFF; " + ;
								"background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, " + ;
								"stop: 0.0 #FFFFFF, stop: 0.6 #F0F0F0, stop: 0.7 #F0F0F0, stop: 1.0 #E5E1DE); " + ;
								"border-top-right-radius: 8px; border-top-left-radius: 8px; }"
				
				Else
					cCSS += "QFrame{ margin: 15px 10px 0px 5px; padding: 6px; border: 1px solid #FFFFFF; " + ;
									"background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, " + ;
									"stop: 0.0 #FFFFFF, stop: 0.6 #F0F0F0, stop: 0.7 #F0F0F0, stop: 1.0 #E5E1DE); " + ;
									"border-top-right-radius: 8px; border-top-left-radius: 8px; }"
				Endif 
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )

		Case nType == CSS_PANEL_FOOTER
			If lClientHtml
				cCSS += "QFrame{ margin: 0px; border: "+FWResAdjSize(1)+"px solid #FFFFFF; " + ;
							"background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, " + ;
							"stop: 0.0 #FFFFFF, stop: 0.6 #f0f0f0, stop: 0.7 #f0f0f0, stop: 1.0 #E5E1DE); " + ;
							"border-bottom-right-radius: "+FWResAdjSize(8)+"px; border-bottom-left-radius: "+FWResAdjSize(8)+"px; }"
			Else
				cCSS += "QFrame{ margin: 0px "+FWResAdjSize(10)+"px "+FWResAdjSize(15)+"px "+FWResAdjSize(5)+"px; border: "+FWResAdjSize(1)+"px solid #FFFFFF; " + ;
							"background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, " + ;
							"stop: 0.0 #FFFFFF, stop: 0.6 #f0f0f0, stop: 0.7 #f0f0f0, stop: 1.0 #E5E1DE); " + ;
							"border-bottom-right-radius: "+FWResAdjSize(8)+"px; border-bottom-left-radius: "+FWResAdjSize(8)+"px; }"
			Endif 
			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )
		
		Case nType == CSS_PANEL_BTN_FOOTER
		
			cCSS += "QFrame{ margin: "+FWResAdjSize(10)+"px "+FWResAdjSize(5)+"px 0px "+FWResAdjSize(10)+"px; border: none; border-top: "+FWResAdjSize(1)+"px solid #F4F4F4; " + ;
								"border-radius: 0px; border-top-color: #D1D1D1; background-color: transparent; }"
			
			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )
			
			
		Case nType == CSS_PANEL_BKGLOGIN
			cCSS += "QFrame{ background-color: #EEEEEE; border-left: "+FWResAdjSize(1)+"px solid #BBBBBB !important; border-right: "+FWResAdjSize(1)+"px solid #BBBBBB; }"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )
		
		Case nType == CSS_PANEL_LOGINGHEADER
			cCSS += PosCss( cAdvPLComp, CSS_PANEL_BKGLOGIN, xPar01)
			cCSS += "QFrame{ border-top-right-radius: "+FWResAdjSize(8)+"px; border-top: "+FWResAdjSize(1)+"px solid #BBBBBB; border-top-left-radius: "+FWResAdjSize(8)+"px; }"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )
		
		Case nType == CSS_PANEL_LOGINMAIN
			cCSS += PosCss( cAdvPLComp, CSS_PANEL_BKGLOGIN, xPar01)
			cCSS += "QFrame{ border-top: Transparent; }"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )	
		
		Case nType == CSS_PANEL_LOGINFOOTER
			cCSS += PosCss( cAdvPLComp, CSS_PANEL_BKGLOGIN, xPar01)
			cCSS +=  "QFrame{ border-bottom-right-radius: "+FWResAdjSize(8)+"px; border-bottom: "+FWResAdjSize(1)+"px solid #BBBBBB; border-bottom-left-radius: "+FWResAdjSize(8)+"px ; border-top:transparent;  }"
			
			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )	
		
		Case nType == CSS_PANEL_LOGINASKREG
			cCSS += "QFrame{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #EEEEEE, stop: 1 #FFFFFF); "+;
			" border-left: "+FWResAdjSize(1)+"px solid #BBBBBB !important; border-right: "+FWResAdjSize(1)+"px solid #BBBBBB;" +;
			" border-bottom-right-radius: "+FWResAdjSize(8)+"px; border-bottom: "+FWResAdjSize(1)+"px solid #BBBBBB; border-bottom-left-radius: "+FWResAdjSize(8)+"px ; border-top:transparent;  }"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )	
		
		Case nType == CSS_PANEL_LINEAUX
			cCSS += "QFrame{ border-bottom: "+FWResAdjSize(0.5)+"px solid #FFFFFF; border-top: "+FWResAdjSize(0.5)+"px solid #BBBBBB; border-radius:0px;}"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )		
		
		Case nType == CSS_PANEL_WIZARD
			cCSS += "QFrame{ background-color:#F0F0F0; }"

			cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )		
								

		Case nType == CSS_BREADCUMB
			If FWIsMobile()
				cCSS += "QLabel{ font: bold  "+FWResAdjSize(16)+"px; color: #"+__aColors[2]+"; background-color: transparent; border: none; margin: 0px; }"
			Else
				cCSS += "QLabel{ font-weight: bold; font-size: 16px; color: #C0C0C0; background-color: transparent; border: none; margin: 0px; }"
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )

		Case nType == CSS_LABEL_HEADER
			cCSS += "QLabel{ font-size:  "+FWResAdjSize(14)+"px; background-color: transparent; color: #000000; border: none; margin: 0px; }"

			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )

		Case nType == CSS_LABEL_FOCAL
			
			xPar01 := IIF( Empty(xPar01), '13', xPar01)
			IF !ValType(xPar01) == 'A'
				xPar01 := {'13', .T.}
			EndIf
			if lClientHtml
				cCSS += "QLabel{  font-size:"+ FWResAdjSize(15) + "px; color: #606060; background-color: transparent; border: none; margin: 0px; }"
			Else
			 	cCSS += "QLabel{ font:"+IIF(xPar01[2], 'bold ',' ') + FWResAdjSize(val(xPar01[1]) )+ "px; color: #606060; background-color: transparent; border: none; margin: 0px; }"
			Endif 
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )

		Case nType == CSS_LABEL_NORMAL
			If FWIsMobile()
				xPar01 := IIF( Empty(xPar01), '13', xPar01)
				IF !ValType(xPar01) == 'A'
					xPar01 := {'13', .T.}
				EndIf
				cCSS += "QLabel{ font: "+IIF(xPar01[2], 'bold ',' ') + FWResAdjSize(val(xPar01[1]) )+ "px; color: #444444; background-color: transparent; border: none; margin: 0px; }"
			Else
				cCSS += "QLabel{ font-size: "+Str(nPxNormal)+"px; color: #B2B2B2; background-color: transparent; border: none; margin: 0px; }" 
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )
		
		Case nType == CSS_LABEL_SUBTITLE
			If FWIsMobile()
				cCSS += "QLabel{ font:  "+FWResAdjSize(13)+"px; color: #"+__aColors[2]+"; background-color: transparent; border: none; margin: 0px; }"
			Else
				cCSS += "QLabel{ font: 13px; color: #B2B2B2; background-color: transparent; border: none; margin: 0px; }"
			EndIf
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )
		
		Case nType == CSS_GET_FOCAL
				cCSS +=	 "QLineEdit {  font-weight: bold; font-size:  "+FWResAdjSize(16)+"px; color: #656565; "+;
				" background-color: #FFFFFF; border: "+FWResAdjSize(1)+"px solid #9C9C9C; border-radius: "+FWResAdjSize(4)+"px; padding: "+FWResAdjSize(4)+"px; " 
				
				If FWIsMobile()
					cCSS +=	" min-height: "+FWResAdjSize(30)+"px;}"
				
					cCSS +="  TButtonGet{ min-width: "+FWResAdjSize(35)+"px;  outline :none; background:qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #FFFFFF, stop: 1 #E9EBF1); " +;
									"border: "+FWResAdjSize(1)+"px solid #BBBBBB; border-radius: "+FWResAdjSize(6)+"px; }"
				Else
					cCSS +=	"}"
				EndIf
				
				cCSS +=	 "QLineEdit:disabled { color:#656565; background-color: transparent; border: none; padding: 0px; }"
				If FWIsMobile()
					cCSS +=	 GET_CSS_FOCAL
				EndIf
			/*EndIf*/
			
			cCSS := FWCSSVerify( cAdvPLComp, "QLineEdit", cCSS )

		Case nType == CSS_GET_NORMAL
			If FWIsMobile()
				cCSS +=	 "QLineEdit { min-height: "+FWResAdjSize(30)+"px; font: bold; font-size:  "+FWResAdjSize(16)+"px; text-align: right; color: #888888;"+;
				" background-color: #FFFFFF; border: "+FWResAdjSize(1)+"px solid #BBBBBB; border-radius: "+FWResAdjSize(4)+"px; padding: "+FWResAdjSize(4)+"px;}"
				cCSS +=	 "QLineEdit:disabled {min-height: "+FWResAdjSize(30)+"px !important; color:#444444; background-color: transparent; border: none; }"
				cCSS +=	 GET_CSS_FOCAL
			Else
				If IsInCallStack("STIRodape") .AND. lClientHtml
					cCSS +=	 "QLineEdit { font-weight: bold; font-size: "+Str(nPxNormal)+"px; text-align: right; color: #656565; background-color: transparent; border: none; margin: 0px;}"
				Else 
					cCSS +=	 "QLineEdit { font-weight: bold; font-size: "+Str(nPxNormal)+"px; text-align: right; color: #656565; background-color: #FFFFFF; border: 1px solid #9C9C9C; border-radius: 4px; padding: 4px; }"
				Endif 
				cCSS +=	 "QLineEdit:disabled {color:#656565; background-color: transparent; border: none; }"
			EndIf
			
			cCSS := FWCSSVerify( cAdvPLComp, "QLineEdit", cCSS )
			
		Case nType == CSS_GET_TOTAL
			If FWIsMobile()
				cCSS +=	 "QLineEdit { font-size:  "+FWResAdjSize(16)+"px; text-align: right; color: #888888;"+;
				" background-color: #FFFFFF; border: "+FWResAdjSize(1)+"px solid #BBBBBB; border-radius: "+FWResAdjSize(4)+"px; padding: "+FWResAdjSize(4)+"px;}"
				cCSS +=	 "QLineEdit:disabled {color:#444444; background-color: transparent; border: none; }"
				cCSS +=	 GET_CSS_FOCAL
			Else
				cCSS +=	 "QLineEdit { font: bold; font-size: 13px; text-align: right; color: #656565; background-color: #FFFFFF; border: 1px solid #9C9C9C; border-radius: 4px; padding: 4px; }"
				cCSS +=	 "QLineEdit:disabled {color:#656565; background-color: transparent; border: none; }"
			EndIf
			
			cCSS := FWCSSVerify( cAdvPLComp, "QLineEdit", cCSS )

		Case nType == CSS_GET_ERROR
			If FWIsMobile()
				cCSS +=	 "QLineEdit {min-height: "+FWResAdjSize(30)+"px; font: bold; font-size:  "+FWResAdjSize(16)+"px; color: #888888; background-color: #FFF2F0;"+;
				" border: "+FWResAdjSize(1)+"px solid #E2938F; border-radius: "+FWResAdjSize(4)+"px; padding: "+FWResAdjSize(4)+"px;  }"
			
				cCSS +=	 GET_CSS_FOCAL
			EndIf			
			
			cCSS := FWCSSVerify( cAdvPLComp, "QLineEdit", cCSS )
		Case nType == CSS_LABEL_TOTAL
			If FWIsMobile()
				cCSS += "QLabel{ font: "+FWResAdjSize(40)+"px; color: #444444; background-color: transparent; border: none; margin: 0px; }"
			Else
				cCSS += "QLabel{ font-size: 35px; color: #656565; background-color: transparent; border: none; margin: 0px; }"
			EndIf			
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )
		
		Case nType == CSS_LABEL_TRIAL	
			cCSS += "QLabel{ font:bold; font-size:  "+FWResAdjSize(14)+"px; color: #BD2C08; background-color: #FFD000; border: none; margin: 0px; }"
		
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )
			
		Case nType == CSS_LABEL_REQUIRED
			cCSS += "QLabel{ font:bold; font-size:  "+FWResAdjSize(12)+"px; color: #DC4000; background-color:transparent; border: none; margin: 0px; }"
		
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )
			
			
		Case nType == CSS_CHECKBOX_DEFAULT
			If FWIsMobile() 
				cCSS += "QCheckBox { background-repeat: no-repeat;  "+;
							"    outline :none; "+;
							"    padding-top: 0px; "+;
							"	 font:bold; "+;
							"    font-size:  "+FWResAdjSize(13)+"px;  "+;
							"    color: #656565; "+;
							"    border: none;} "+;
							"QWidget { border-width: 0px ;}"+;
							" 	QCheckBox::indicator { "+;
						 	" width: "+FWResAdjSize(15)+"px;"+;
						   	" height: "+FWResAdjSize(15)+"px;}"
						
				cCSS := FWCSSVerify( cAdvPLComp, "QCheckBox", cCSS )
			EndIf	
			
		Case nType == CSS_CHOOSE_PAYMENT
			If FWIsMobile()  
				cCSS += "QWidget{border: none;}"+;
						 "QScrollBar:horizontal{"+;
							" border:none; max-height: "+FWResAdjSize(6)+"px; min-height: "+FWResAdjSize(6)+"px;"+;
							" background: none; border: none; margin: 0 0 0 0;"+;
						 "}"
						
				cCSS := FWCSSVerify( cAdvPLComp, "Q3ListBox", cCSS )
			EndIf
				
			
		Case nType == CSS_PAYMENT_ITEM
			If FWIsMobile()  
				cCSS += "QWidget{border: none; background-color: #FFFFFF;}"	
						
				cCSS := FWCSSVerify( cAdvPLComp, "QFrame", cCSS )
			EndIf
			
		Case nType == CSS_COMBOBOX
			If FWIsMobile() 
				cCSS +="QComboBox {font-size:  "+FWResAdjSize(20)+"px;  "+;
						"    color: #2462A6; "+;
						"    background-color: #ffffff; "+;
						"    min-height: "+FWResAdjSize(40)+"px; "+;
						"    max-height: "+FWResAdjSize(40)+"px; "+;
						"    border-style: solid; "+;
						"    border-width: 2px; "+;
						"    padding-left: 0px; } "+;
						"    QComboBox QAbstractItemView { "+;
	   					"    border: "+FWResAdjSize(2)+"px solid darkgray;"+;
	    				"    selection-background-color: #"+__aColors[2]+";}";
										
						
						
				cCSS := FWCSSVerify( cAdvPLComp, "TCOMBOBOX", cCSS )	
			EndIf	
			
		Case nTYpe == CSS_STEP_WIZ
				cCSS := "#"+__aColors[4]
				
		Case nType == CSS_LABEL_ALERT
			If FWIsMobile()
				cCSS += "QLabel{ font: "+FWResAdjSize(22)+"px; color: #444444; background-color: transparent; border: none; margin: 0px; }"
			Else
				cCSS += "QLabel{ font-size: 22px; color: #656565; background-color: transparent; border: none; margin: 0px; }"
			EndIf			
			cCSS := FWCSSVerify( cAdvPLComp, "QLabel", cCSS )
		
			
	EndCase
	
Return cCSS

//-------------------------------------------------------------------
/*/{Protheus.doc} POSBrwContainer
Função responsável por construir o container para o browse do POS

@param o Container para a construção da interface do browse

@return oContent Painel para construção do browse

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function POSBrwContainer(o)

	Local oContent
	Local oLeft
	Local oRight
	Local oRTop
	Local oRBottom
	Local oLTop
	Local oLBottom
	Local oLHeader
	Local oRHeader
	Local oSep

	@ 000,000 BITMAP oLeft RESOURCE "x.png" NOBORDER SIZE 007,000 OF o ADJUST PIXEL
	oLeft:Align := CONTROL_ALIGN_LEFT
	oLeft:ReadClientCoors(.T.,.T.)
	
		@ 000,000 BITMAP oLHeader RESOURCE "x.png" NOBORDER SIZE 000,016 OF oLeft ADJUST PIXEL
		oLHeader:Align := CONTROL_ALIGN_TOP
		oLHeader:SetCSS( POSCSS( GetClassName(oLHeader), CSS_BROWSE_HEADER_LEFT ) )
	
		@ oLHeader:nHeight/2,oLeft:nWidth/2-4.5 BITMAP oLTop RESOURCE "pos_brw_corner_tl.png" NOBORDER SIZE 04.5,04.5 OF oLeft ADJUST PIXEL
		
		@ oLeft:nHeight/2-4.5,oLeft:nWidth/2-4.5 BITMAP oLBottom RESOURCE "pos_brw_corner_bl.png" NOBORDER SIZE 04.5,04.5 OF oLeft ADJUST PIXEL
	
	@ 000,000 BITMAP oRight RESOURCE "x.png" NOBORDER SIZE 010,000 OF o ADJUST PIXEL
	oRight:Align := CONTROL_ALIGN_RIGHT
	oRight:ReadClientCoors(.T.,.T.)

		@ 000,000 BITMAP oRHeader RESOURCE "x.png" NOBORDER SIZE 000,016 OF oRight ADJUST PIXEL
		oRHeader:Align := CONTROL_ALIGN_TOP
		oRHeader:SetCSS( POSCSS( GetClassName(oRHeader), CSS_BROWSE_HEADER_RIGHT ) )

		@ oRHeader:nHeight/2,000 BITMAP oRTop RESOURCE "pos_brw_corner_tr.png" NOBORDER SIZE 04.5,04.5 OF oRight ADJUST PIXEL

		@ oRight:nHeight/2-4.5,000 BITMAP oRBottom RESOURCE "pos_brw_corner_br.png" NOBORDER SIZE 04.5,04.5 OF oRight ADJUST PIXEL

	@ 000,000 BITMAP oContent RESOURCE "x.png" NOBORDER SIZE o:nWidth/2-20,o:nHeight/2-20 OF o ADJUST PIXEL
	oContent:Align := CONTROL_ALIGN_ALLCLIENT

		@ 000,000 BITMAP oSep RESOURCE "pos_brw_degrade.png" NOBORDER SIZE 000,2.5 OF oContent ADJUST PIXEL
		oSep:Align := CONTROL_ALIGN_BOTTOM
		oSep:SetCSS( FWCSSVerify( GetClassName(oSep), "QFrame", "QFrame { background-color: #FFFFFF; }" ) )

		@ 000,000 BITMAP oContent RESOURCE "x.png" NOBORDER SIZE o:nWidth/2-20,o:nHeight/2-20 OF oContent ADJUST PIXEL
		oContent:Align := CONTROL_ALIGN_ALLCLIENT

Return oContent
