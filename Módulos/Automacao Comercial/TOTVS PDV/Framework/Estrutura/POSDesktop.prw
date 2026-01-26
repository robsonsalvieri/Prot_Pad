#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "poscss.ch"

#DEFINE FONT_NAME 1
#DEFINE FONT_SIZE 2
#DEFINE FONT_BOLD 3
#DEFINE FONT_ITALIC 4
#DEFINE FONT_UNDERLINE 5

STATIC aFontButton := { "Arial", 12, .T., .F., .F. }
STATIC aFontInfo := { "Arial", 12, .F., .F., .F. }
STATIC aFontMenu := { "Arial", 13, .T., .F., .F. }
STATIC aFontAlert := { "Arial", IIF(FWIsMobile(),14,32), .T., .F., .F. }
STATIC __ISFLY01 :=  FindFunction('ISFly01') .AND. ISFly01()

//-------------------------------------------------------------------
/*/{Protheus.doc} POSDesktop
Objetivo desta classe é preparar a interface para a utilização
do novo POS

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS POSDesktop

	DATA cBG

	DATA oMsgBarTop
	DATA oMsgBarBottom
	DATA oDesktop
	DATA oOwner

	METHOD New() CONSTRUCTOR

	METHOD Activate()
	METHOD Deactivate()

	METHOD AddTLMenuItem()
	
	METHOD GetDesktop()

	METHOD SetBAlert()
	METHOD SetBGImage()
	METHOD SetBInfo( cInfo )	
	METHOD SetTInfo( cInfo )
	METHOD SetTRMenu()
	METHOD SetTLMenu()
	METHOD GetPanelLogoBottom()
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor

@param oDlg Dialog container onde será construida a interface

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New( oDlg ) CLASS POSDesktop
	PARAMTYPE 00 VAR oDlg AS OBJECT

	::oOwner := oDlg
	::oMsgBarTop := POSMsgBarTop():New( oDlg )
	::oMsgBarBottom := POSMsgBarBottom():New( oDlg )
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate
Ativa a classe, este método constrói a interface

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Activate() CLASS POSDesktop

	Local cBG := If( ::cBG <> Nil, ::cBG, "pos_bg_geral.png" )

	Local oBG
	
	Local oOwner := ::oOwner

	::oMsgBarTop:Activate()
	::oMsgBarBottom:Activate()
	
	If ::cBG == Nil
		@ 000,000 BITMAP oBG RESOURCE "x.png" NOBORDER SIZE 000,020 OF oOwner ADJUST PIXEL
		oBG:Align := CONTROL_ALIGN_ALLCLIENT
		oBG:SetCSS( POSCSS( GetClassName(oBG), CSS_BG ) )
		oOwner := oBG
	EndIf

	@ 000,000 BITMAP ::oDesktop RESOURCE cBG NOBORDER SIZE 000,020 OF oOwner ADJUST PIXEL
	::oDesktop:Align := CONTROL_ALIGN_ALLCLIENT
	::oDesktop:ReadClientCoors(.T.,.T.)
	::oDesktop:SetCSS( FWCSSVerify( GetClassName(::oDesktop), "Q3Frame", "Q3Frame { background-color: none; }") )
		
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Deactivate
Desativa a clase

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Deactivate() CLASS POSDesktop

	::oMsgBarTop:Deactivate()
	::oMsgBarBottom:Deactivate()

	FreeObj(::oDesktop)

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} AddTLMenuItem
Adiciona um item de menu popup no botão superior a esquerda

@param cDescr String de descrição do botão
@param bAction Bloco de ação do botão

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AddTLMenuItem( cDescr, bAction) CLASS POSDesktop
	PARAMTYPE 00 VAR cDescr  AS CHARACTER
	PARAMTYPE 01 VAR bAction AS BLOCK

	::oMsgBarTop:AddLMenuItem( cDescr, bAction  )
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDesktop
Retorna o painel disponível para a construção da area de 
trabalho do POS

@return oDesktop Container para a construção do POS 

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetDesktop() CLASS POSDesktop
RETURN ::oDesktop

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBAlert
Seta alerta na barra inferior da interface

@param cAlert String com o alerta a ser exibido

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetBAlert( cAlert ) CLASS POSDesktop
	PARAMTYPE 00 VAR cAlert AS CHARACTER

	::oMsgBarBottom:SetAlert( cAlert )
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBGImage
Seta imagem de fundo da interface do POS

@param cBG Nome da imagem que deve estar compilada no repositório

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetBGImage( cBG ) CLASS POSDesktop
	PARAMTYPE 00 VAR cBG AS CHARACTER
	
	::cBG := cBG 
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBInfo
Seta informação a ser exibida na barra inferior da interface

@param cInfo String com informação a ser exibida

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetBInfo( cInfo ) CLASS POSDesktop
	::oMsgBarBottom:SetInfo( cInfo )
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTInfo
Seta informação a ser exibida na barra superior da interface

@param cInfo String com informação a ser exibida

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetTInfo( cInfo ) CLASS POSDesktop
	::oMsgBarTop:SetInfo( cInfo )
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTLMenu
Seta descrição e atalho do menu superior a esquerda

@param cDescr Descrição do menu superior a esquerda
@param nHotKey Numérico com o código da tecla de atalho do menu superior a esquerda

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetTLMenu( cDescr, nHotKey ) CLASS POSDesktop
	::oMsgBarTop:SetLMenu( cDescr, nHotKey )
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTRMenu
Seta descrição e atalho do menu superior a direita

@param cDescr Descrição do menu superior a diteita
@param nHotKey Numérico com o código da tecla de atalho do menu superior a direita
@param bAction Bloco com a ação a ser executada no menu superior a direita

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetTRMenu( cDescr, nHotKey, bAction ) CLASS POSDesktop
	::oMsgBarTop:SetRMenu( cDescr, nHotKey, bAction )
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPanelLogoBottom
Retorna o panel da barra inferior

@return oPanel barra inferior

@author  Ricardo Augusto da Costa
@since   20/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetPanelLogoBottom() CLASS POSDesktop
RETURN Self:oMsgBarBottom:GetPanelLogoBottom()


//-------------------------------------------------------------------
/*/{Protheus.doc} POSMsgBarTop
Classe responsável pela montagem da barra superior

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS POSMsgBarTop
	
	DATA aLOptions

	DATA bRAction

	DATA cInfo
	DATA cRMDescr
	DATA cLMDescr

	DATA nLMHotKey
	DATA nRMHotKey

	DATA oBar
	DATA oInfo
	DATA oLBtn
	DATA oOwner
	DATA oRBtn
	
	METHOD New()
	
	METHOD Activate()
	METHOD Deactivate()

	METHOD AddLMenuItem()
	METHOD MenuLAction()
	
	METHOD SetInfo()
	METHOD SetLMenu()
	METHOD SetRMenu()
	


ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor

@param Container para a construção da barra

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New( oOwner ) CLASS POSMsgBarTop

	::aLOptions := {}
	
	::cInfo := ""
	
	::oOwner := oOwner

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate
Método para a ativação da classe

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Activate() CLASS POSMsgBarTop

	Local cTitle
	
	Local nHeight
	Local nWidth
	Local nX
	Local oFontSize 		:= FWFontSize():New()
	Local oMenu
	Local oMenuItem
	local nLogoWidth 		:= 52
	Local nLogoHeight 		:= 21.6
	Local nLogoMargin 		:= 15
	Local lClientHtml		:=  .F.
	Local cVerWebApp		:= ""
  	
	//Verifica se o SmartClient é via WebApp ou não.
	GetRemoteType(@cVerWebApp) 
  	lClientHtml:= 'HTML' $ UPPER(cVerWebApp) 
	Conout("SmartClient-> " + cVerWebApp)


	
	@ 000,000 BITMAP ::oBar RESOURCE "x.png" NOBORDER SIZE 000,020 OF ::oOwner ADJUST PIXEL
	::oBar:Align := CONTROL_ALIGN_TOP
	::oBar:SetCSS( POSCSS( GetClassName(::oBar), CSS_BAR_TOP ) )
	::oBar:ReadClientCoors(.T.,.T.)

	cTitle := ::cLMDescr + IIF(!FWIsMobile()," (" + GetKey(::nLMHotKey) + ")", '')
	nWidth := oFontSize:getTextWidth( cTitle, aFontButton[FONT_NAME], aFontButton[FONT_SIZE], aFontButton[FONT_BOLD], aFontButton[FONT_ITALIC], aFontButton[FONT_UNDERLINE] )/2
	
	If FwIsMobile()
		nWidth += Val(FWResAdjSize(26)) //adiciona a largura do icone de menu
	EndIf
	
	@ 000, 000 BUTTON ::oLBtn PROMPT cTitle SIZE nWidth+020,000 ACTION ::bRAction/*{|| MsgAlert("Teste") }*/ OF ::oBar PIXEL
	::oLBtn:Align := CONTROL_ALIGN_LEFT
	::oLBtn:SetCSS( POSCSS( GetClassName(::oLBtn), CSS_BAR_BUTTON, .T. ) )
	Self:oLBtn:LCANGOTFOCUS := .F.

	
	//-------------------------------------------------------------
	// Verifica qual o maior titulo do submenu
	//-------------------------------------------------------------
	For nX := 1 To Len(::aLOptions)
		nWidth := Max( nWidth, oFontSize:getTextWidth( OemToAnsi(::aLOptions[nX][1]), aFontMenu[FONT_NAME], aFontMenu[FONT_SIZE], aFontMenu[FONT_BOLD], aFontMenu[FONT_ITALIC], aFontMenu[FONT_UNDERLINE] ) )
	Next nX
	nWidth += 100 // adiciona margem para icones
	
	oMenu := TMenu():New(0,0,0,0,.T.)
	
   	//-------------------------------------------------------------
	// Cria submenus
	//-------------------------------------------------------------
	For nX := 1 To Len(::aLOptions)
		oMenuItem := TMenuItem():New(,OemToAnsi(::aLOptions[nX][1]+IIF(lClientHtml, "", Space(300))),OemToAnsi(::aLOptions[nX][1]+IIF(lClientHtml, "",Space(300))),,,,,,,,,,,,.T.)
		oMenuItem:bAction := ::aLOptions[nX][2]
			
		oMenu:Add( oMenuItem )
	Next nX
	::oLBtn:SetPopupMenu(oMenu)
	SetKey( ::nLMHotKey, {|| oMenu:Activate(::oLBtn:nLeft, ::oLBtn:nTop+::oLBtn:nHeight) } )
	//-------------------------------------------------------------
	// Atribui css ao menu
	//-------------------------------------------------------------
	oMenu:SetCSS( POSCSS( GetClassName(oMenu), CSS_BAR_MENU, nWidth ) )

	If FWIsMobile() .And. __ISFLY01
		//divide por 4 pq precisa dividir por 2 pela diferença de ponto e pixel e dividir por 2 pela metade da altura, para centralizar
		::oRBtn := TSVG():New((::oBar:nheight/4 - nLogoHeight/2 ),::oBar:nWidth/2 - (nLogoWidth + nLogoMargin),::oBar,nLogoWidth,nLogoHeight,GEtApoRes("fwskin_logo_flyrede.svg"),.T.)
		::oRBtn:SetCSS( FWCSSVerify( GetClassName(::oRBtn), "Q3Frame", "Q3Frame { background-color: transparent; border:none; }") )
		
	Else
		cTitle := ::cRMDescr + IIF(!FWIsMobile()," (" + GetKey(::nRMHotKey) + ")",'')
		nWidth := oFontSize:getTextWidth( cTitle, aFontButton[FONT_NAME], aFontButton[FONT_SIZE], aFontButton[FONT_BOLD], aFontButton[FONT_ITALIC], aFontButton[FONT_UNDERLINE] )/2
		@ 000, 000 BUTTON ::oRBtn PROMPT cTitle SIZE nWidth+020,000 OF ::oBar PIXEL
		::oRBtn:bAction := ::bRAction
		::oRBtn:Align := CONTROL_ALIGN_RIGHT
		::oRBtn:SetCSS( POSCSS( GetClassName(::oRBtn), CSS_BAR_BUTTON ) )
		Self:oRBtn:LCANGOTFOCUS := .F.	
	
		SetKey( ::nRMHotKey, ::bRAction )
	EndIf
	
	If !FWIsMobile()
		cTitle := ::cInfo+Space(10)
		nWidth := ::oBar:nWidth-::oLBtn:nWidth-::oRBtn:nWidth 	
		nHeight := oFontSize:getTextHeight( cTitle, aFontInfo[FONT_NAME], aFontInfo[FONT_SIZE], aFontInfo[FONT_BOLD], aFontInfo[FONT_ITALIC], aFontInfo[FONT_UNDERLINE] )
		@ (::oBar:nHeight-nHeight)/2/2, (::oBar:nWidth-::oRBtn:nWidth-nWidth)/2 SAY ::oInfo PROMPT cTitle RIGHT OF ::oBar PIXEL
		::oInfo:Align:= CONTROL_ALIGN_RIGHT
		::oInfo:nWidth := nWidth
		::oInfo:nHeight := nHeight
		::oInfo:SetCSS( POSCSS( GetClassName(::oInfo), CSS_BAR_INFO ) )
	EndIf
	
RETURN

Method MenuLAction(o, cID) Class POSMsgBarTop
Local nX := Val(cID)
Eval(::aLOptions[nX][2])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Deactivate
Método para a desativação da classe

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Deactivate() CLASS POSMsgBarTop

	aSize( ::aLOptions, 0 )
	::aLOptions := Nil

	::bRAction := Nil

	FreeObj(::oBar)
	FreeObj(::oInfo)
	FreeObj(::oLBtn)
	FreeObj(::oRBtn)

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} AddLMenuItem
Método para adicionar um item ao menu superior a esquerda

@param cDescr String com a descrição do item
@param bAction Ação do item do menu

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AddLMenuItem( cDescr, bAction) CLASS POSMsgBarTop
	aAdd( ::aLOptions, { cDescr, bAction } )
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetInfo
Seta informação a ser exibida na barra superior da interface

@param cInfo String com informação a ser exibida

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetInfo(cInfo) CLASS POSMsgBarTop
	Local nWidth
	Local nHeight

	Local oFontSize := FWFontSize():New()

	::cInfo := cInfo

	If ::oInfo <> Nil
		nWidth := oFontSize:getTextWidth( cInfo, aFontInfo[FONT_NAME], aFontInfo[FONT_SIZE], aFontInfo[FONT_BOLD], aFontInfo[FONT_ITALIC], aFontInfo[FONT_UNDERLINE] )
		nHeight := oFontSize:getTextHeight( cInfo, aFontInfo[FONT_NAME], aFontInfo[FONT_SIZE], aFontInfo[FONT_BOLD], aFontInfo[FONT_ITALIC], aFontInfo[FONT_UNDERLINE] )

		::oInfo:cCaption := cInfo

		::oInfo:nWidth := nWidth
		::oInfo:nHeight := nHeight
		::oInfo:Refresh()	
	EndIf
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLMenu
Seta descrição e tecla de atalho do menu superior a esquerda

@param cDescr String com a descriçao do menu a esquerda
@param nHotKey Numérico com o código da tecla de atalho do menu a esquerda

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetLMenu( cDescr, nHotKey ) CLASS POSMsgBarTop
	::cLMDescr := cDescr
	::nLMHotKey := nHotKey
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetRMenu
Seta descrição, tecla de atalho e ação do menu superior a direita

@param cDescr String com a descriçao do menu a direita
@param nHotKey Numérico com o código da tecla de atalho do menu a direita
@param bAction Bloco de ação do menu superior a direita

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetRMenu( cDescr, nHotKey, bAction ) CLASS POSMsgBarTop
	::bRAction := bAction
	::cRMDescr := cDescr
	::nRMHotKey := nHotKey
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} POSMsgBarBottom
Classe responsável pela criação da barra inferior da interface

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS POSMsgBarBottom

	DATA cInfo
	DATA cRMDescr

	DATA oAlert
	DATA oBar
	DATA oInfo
	DATA oOwner
	DATA oPanelLogo
	
	METHOD New()
	
	METHOD Activate()
	METHOD Deactivate()

	METHOD SetInfo()
	METHOD SetAlert()
	
	METHOD GetPanelLogoBottom()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor

@param oOwner Container para a construção da barra

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New( oOwner ) CLASS POSMsgBarBottom

	::cInfo := ""

	::oOwner := oOwner

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate
Método responsável por ativar a classe

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Activate() CLASS POSMsgBarBottom

	Local cTitle
	
	Local nWidth
	Local nHeight

	Local oFont
	Local oFontSize := FWFontSize():New()
	Local oLogo

	

	@ 000,000 BITMAP ::oBar RESOURCE "x.png" NOBORDER SIZE 000,030 OF ::oOwner ADJUST PIXEL
	::oBar:Align := CONTROL_ALIGN_BOTTOM
	::oBar:SetCSS( POSCSS( GetClassName(::oBar), CSS_BAR_BOTTOM ) )
	::oBar:ReadClientCoors(.T.,.T.)

	
	@ 000,000 BITMAP ::oPanelLogo RESOURCE "x.png" NOBORDER SIZE 066,000 OF ::oBar ADJUST PIXEL
	::oPanelLogo:Align := CONTROL_ALIGN_RIGHT
	::oPanelLogo:SetCSS( POSCSS( GetClassName(::oPanelLogo), CSS_BAR_LOGO ) )

	If !FWIsMobile()
		@ 003,013 BITMAP oLogo RESOURCE  FwGetImgCss('pos_logo_hor_branco')  NOBORDER SIZE 040.37,015 OF ::oPanelLogo ADJUST PIXEL
	EndIf
	
	cTitle := ::cInfo+Space(10)
	nWidth := oFontSize:getTextWidth( cTitle, aFontInfo[FONT_NAME], aFontInfo[FONT_SIZE], aFontInfo[FONT_BOLD], aFontInfo[FONT_ITALIC], aFontInfo[FONT_UNDERLINE] )
	nHeight := oFontSize:getTextHeight( cTitle, aFontInfo[FONT_NAME], aFontInfo[FONT_SIZE], aFontInfo[FONT_BOLD], aFontInfo[FONT_ITALIC], aFontInfo[FONT_UNDERLINE] )
	@ (::oBar:nHeight-nHeight)/2/2, (::oBar:nWidth-(IIF(::oPanelLogo <> nil,::oPanelLogo:nWidth,0))-nWidth)/2 SAY ::oInfo PROMPT cTitle  OF ::oBar PIXEL
	::oInfo:nWidth := nWidth
	::oInfo:nHeight := nHeight
	::oInfo:Align := CONTROL_ALIGN_RIGHT
	::oInfo:SetCSS( POSCSS( GetClassName(::oInfo), CSS_BAR_INFO ) )

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Deactivate
Método responsável por desativar a classe

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Deactivate() CLASS POSMsgBarBottom

	FreeObj(::oAlert)
	FreeObj(::oBar)
	FreeObj(::oInfo)

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetInfo
Método responsável por atribuir as informações que serão exibidas na barra inferior

@param cInfo String com as informações que serão exibidas na barra inferior

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetInfo( cInfo ) CLASS POSMsgBarBottom
	Local nWidth
	Local nHeight
	
	Local oFontSize := FWFontSize():New()
	
	::cInfo := cInfo

	If ::oInfo <> Nil
		nWidth := oFontSize:getTextWidth( cInfo, aFontInfo[FONT_NAME], aFontInfo[FONT_SIZE], aFontInfo[FONT_BOLD], aFontInfo[FONT_ITALIC], aFontInfo[FONT_UNDERLINE] )
		nHeight := oFontSize:getTextHeight( cInfo, aFontInfo[FONT_NAME], aFontInfo[FONT_SIZE], aFontInfo[FONT_BOLD], aFontInfo[FONT_ITALIC], aFontInfo[FONT_UNDERLINE] )

		::oInfo:cCaption := cInfo
		::oInfo:nWidth := nWidth
		::oInfo:nHeight := nHeight
		::oInfo:Refresh()	
	EndIf
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} SetAlert
Método responsável por setar o alerta na barra inferior

@param cAlert String com o alerta a ser exibido

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetAlert( cAlert ) CLASS POSMsgBarBottom

	Local cTitle := ""
	
	Local nWidth
	Local nHeight

	Local oFontSize := FWFontSize():New()

	cTitle := cAlert+Space(10)
	nWidth := oFontSize:getTextWidth( cTitle, aFontAlert[FONT_NAME], aFontAlert[FONT_SIZE], aFontAlert[FONT_BOLD], aFontAlert[FONT_ITALIC], aFontAlert[FONT_UNDERLINE] )
	nHeight := oFontSize:getTextHeight( cTitle, aFontAlert[FONT_NAME], aFontAlert[FONT_SIZE], aFontAlert[FONT_BOLD], aFontAlert[FONT_ITALIC], aFontAlert[FONT_UNDERLINE] )
	If ::oAlert == Nil 
		@ (::oBar:nHeight-nHeight)/2/2, 10 SAY ::oAlert PROMPT cTitle OF ::oBar PIXEL
		::oAlert:SetCSS( POSCSS( GetClassName(::oAlert),  CSS_BAR_ALERT) )
		//::oAlert:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		::oAlert:cCaption := cTitle
	EndIf
	::oAlert:nWidth := nWidth
	::oAlert:nHeight := nHeight
	::oAlert:Refresh()	

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPanelLogoBottom
Retorna o panel da barra inferior

@return oPanel barra inferior

@author  Ricardo Augusto da Costa
@since   20/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetPanelLogoBottom() CLASS POSMsgBarBottom
RETURN Self:oPanelLogo

//-------------------------------------------------------------------
/*/{Protheus.doc} GetKey
Função responsável por retornar a descriação da tecla de atalho

@param Numérico com o código ASC da tecla de atalho

@return String com a descrição da tecla de atalho passada por parametro

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetKey( nKey )

	Local cRet
	
	If FWIsMobile()
		Return ''
	EndIf
	
	Do Case
		Case nKey == VK_F1
			cRet := "F1"
		Case nKey == VK_F2
			cRet := "F2"
		Case nKey == VK_F3
			cRet := "F3"
		Case nKey == VK_F4
			cRet := "F4"
		Case nKey == VK_F5
			cRet := "F5"
		Case nKey == VK_F6
			cRet := "F6"
		Case nKey == VK_F7
			cRet := "F7"
		Case nKey == VK_F8
			cRet := "F8"
		Case nKey == VK_F9
			cRet := "F9"
		Case nKey == VK_F10
			cRet := "F10"
		Case nKey == VK_F11
			cRet := "F11"
		Case nKey == VK_F12
			cRet := "F12"
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} __POSDesktop
Função para geração de patch

@author  Bruno Lopes Malafaia
@since   26/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function __POSDesktop()
Return

