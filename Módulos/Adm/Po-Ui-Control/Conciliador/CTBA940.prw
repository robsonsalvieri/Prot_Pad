#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "CTBA940.CH"
#Include 'FWMVCDef.ch'

Function CTBA940()
Local nRetMnu	 := 0 as Numeric
Private aRotina	 := {} as Array

aRotina	:= MenuDef()

CTB940Menu(@nRetMnu)

If nRetMnu == 0
	MsgStop( STR0021+CRLF+STR0022+"CTBA940", STR0020 )  //"Atenção" //"Este usuário não possui acesso para executar essa operação." //"Menu: "
	Return
Endif

//Atualização das configurações
CTBA940J()

If FINDFUNCTION( 'FINA475J' )
	FINA475J()
Endif

If ReqMinimos()
    FWCallApp("ctba940",,,,,,,,,.T.)
EndIf

Return

Static Function ReqMinimos()

Local oBtnLink
Local cMsg	     := ""
Local cTitle     := ""
Local cSubTitle  := ""
Local cLink      := ""
Local cVDBAccess := ""
Local lRet       := .T.

//DBAccess
cVDBAccess := TcVersion()
If cVDBAccess < "21.1.1.8"
	cTitle    := STR0016 // ""Ambiente Desatualizado"
	cSubTitle := STR0009 // "Acesse o Portal do Cliente"
	cLink     := "https://suporte.totvs.com/portal/p/10098/download#000006/"

	cMsg += '<b> '+ STR0007 + ' </b><br>'  	// DBAccess está desatualizado
	cMsg += ' ' + STR0002 + ' ' + cVDBAccess + "<br>" 	//"Versão atual: " | " Build: "
	cMsg += ' ' + STR0003 + '21.1.1.8<br><br>'			//"Versão mínima: "###'ou maior igual a'
EndIf

If !Empty(cMsg)
	DEFINE DIALOG oDlg TITLE cTitle FROM 180,180 TO 500,750 PIXEL
	// Cria fonte para ser usada no TSay
	oFont := TFont():New('Courier new',,-15,.T.)

	lHtml := .T.
	oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

	oBtnLink := TButton():New( 145, 5, cSubTitle, oDlg,, 150 ,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
	oBtnLink:bLClicked := {|| ShellExecute("open", cLink,"","",3) }

	ACTIVATE DIALOG oDlg CENTERED

    lRet := .F.
EndIf
Return lRet



/*/{Protheus.doc} MenuDef
    Definição de menu de Acesso

    @return Array com o Menu
    @author TOTVS
    @since 20/03/2024
/*/

Static Function MenuDef()
	Local aRotina As Array

	aRotina := {}
	ADD OPTION aRotina TITLE STR0023 ACTION "a940Conc"  OPERATION 1 ACCESS 0 //"Conciliador"
	ADD OPTION aRotina TITLE STR0024 ACTION "a940Dash"  OPERATION 2 ACCESS 0 //"DashBoard"
	ADD OPTION aRotina TITLE STR0025 ACTION "a940Setup" OPERATION 3 ACCESS 0 //"Setup"
	ADD OPTION aRotina TITLE STR0026 ACTION "a940Geren" OPERATION 4 ACCESS 0 //"Gerenciar"
	ADD OPTION aRotina TITLE STR0027 ACTION "a940Acces" OPERATION 5 ACCESS 0 //"Controle de Acesso"

Return(aRotina)

/*/{Protheus.doc} getMenu940
    Definição de privilegio de Acesso ao Menu

    @return Json
    @author TOTVS
    @since 20/03/2024
/*/

Function CTB940Menu(nRetMnu As Numeric)

	Local jPrivUser	  As Json
	Local cUsersID	  As Character
	Local aRotina	  As Array
	Local nI		  As Numeric

	Default nRetMnu := 0

	aRotina   := MenuDef()
	cUsersID  := RetCodUsr(cUserName)	
	jPrivUser := JsonObject():New()

	For nI := 1 To Len(aRotina)
		jPrivUser[aRotina[nI][2]] := MPUserHasAccess('CTBA940', aRotina[nI][4], cUsersID)
		
		If jPrivUser[aRotina[nI][2]]
			nRetMnu++
		Endif
	Next nI

Return jPrivUser

/*/{Protheus.doc} JsToAdvpl
    Configura o Web Socket do sistema.

    @param oWebChannel, object
    @param cType, character
    @param cContent, character

    @author TOTVS
    @since 05/02/2025
/*/
Static Function JsToAdvpl(oWebChannel As Object, cType As Character, cContent As Character)
	Local jsonActions	as json
	Local aActionIds	as Array

	cType   	:= Upper(cType)
	aActionIds	:= {}

	Do Case
		Case cType == 'CTBA940AC'
			jsonActions := JsonObject():New()
			jsonActions:FromJson(cContent)

			If !Empty(jsonActions:hasProperty('action') .And. jsonActions:hasProperty('keys'))
				If Existblock(jsonActions['action'])
					ExecBlock(jsonActions['action'], .F., .F., { jsonActions['keys'] })
				EndIf
			EndIf
			
			oWebChannel:AdvPLToJS(jsonActions['receiveId'], ' ')
	End Case

Return
