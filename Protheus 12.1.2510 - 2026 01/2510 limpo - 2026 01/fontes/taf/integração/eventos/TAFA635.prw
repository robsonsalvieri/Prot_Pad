#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TAFA635.CH"

Function TAFA635()
	Local cAppName  as character
	Local lTamChvel as logical

	cAppName  := "montev"

	If TAFAlsInDic("T7A")
		lTamChvel := TamSx3("T7A_CHVELE")[1] == TamSx3("C20_CHVELE")[1]
		If lTamChvel
			FWCallApp(cAppName)
		Else
			ModMonEvt()
		EndIf
	Else
		MsgAlert(STR0001) //"Opção não disponível, atualize o dicionário para uma expedição contínua"
	EndIf

Return

/*/{Protheus.doc} ModMonEvt
Função responsável por renderizar o modal com as informações sobre divergência de tamanho de campos 
@type static function
@author Evandro Italo
@since 04/12/2025
@version 1.0
@return Boolean, .T.
/*/
Static Function ModMonEvt()

	Local cWarning		as character
	Local cDisclaimer	as character
	Local cLink     	as character
	Local oModal 		as object
	Local oWarning		as object
	Local oDisclaimer	as object
	Local oContainer	as object
	Local oCSS			:= totvs.framework.css.ProtheusTheme():New()

	cLink	:= "https://tdn.totvs.com/display/public/TAF/Monitor+de+Eventos+-+TAF+-+P12"
	oModal 	:= FWDialogModal():New()

	oModal:SetEscClose(.T.)
	oModal:SetTitle(STR0002) // "Monitor de Eventos"
	oModal:SetSubTitle(STR0003) // "Opção não disponível"
	oModal:SetSize(150, 250)
	oModal:CreateDialog()
	oModal:AddCloseButton(Nil, STR0004) // "Fechar"

	oContainer := TPanel():New(000, 000,, oModal:GetPanelMain(),, .T.,,,, 249, 091,, .T.)

	cWarning := '<p>' + STR0005 + '</p>' // Foi detectada uma divergência no tamanho dos campos (T7A_CHVELE e C20_CHVELE). Entre em contato com o administrador do sistema.

	oWarning := TSay():New(002, 002, {|| cWarning}, oContainer,,,,,, .T.,,, 240, 090,,,,,, .T., 3)

	oWarning:SetCss("TSay { font-size: 12px; }")

	cDisclaimer := '<p>' + STR0006 + '</p>' // Para mais informações, acesse a documentação no TDN.

	oDisclaimer := TSay():New(050, 002, {|| cDisclaimer}, oContainer,,,,,, .T.,,, 240, 090,,,,,, .T., 2)

	oDisclaimer:SetCss("TSay { font-size: 12px; color: " + oCSS:oTheme:brand01Dark + "; }")

	THButton():New(065, 060, STR0007, oContainer, {|| ShellExecute("open", cLink, "", "", 1)}, 120, 010,, cLink) // "Clique aqui para acessar a documentação."

	oModal:Activate()

Return .T.
