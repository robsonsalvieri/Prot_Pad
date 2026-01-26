#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "CTBA961.CH"

Function CTBA961()

If ReqMinimos()
    FWCallApp("ctba961",,,,,,,,,.T.)
EndIf

Return

Static Function ReqMinimos(lAutoRlse)

Local oBtnLink
Local cMsg	     := ""
Local cTitle     := ""
Local cSubTitle  := ""
Local cLink      := ""
Local lRet       := .T.

Default lAutoRlse   := .F.

//Release
If  (lRet .And. GetRPORelease() < "12.1.2310") .Or. lAutoRlse
    cTitle    := STR0001 // "Ambiente Desatualizado"
	cSubTitle := STR0002 // "Acesse o Portal do Cliente"
	cLink     := "https://suporte.totvs.com/portal/p/10098/download#000006/"

	cMsg += '<b>' + STR0003 + ' </b><br>' 	// "RPO está desatualizado"
    cMsg += ' ' + STR0004 + ' ' + GetRPORelease() + ' - ' + STR0005 + '12.1.2310 <br><br>' 	//"Versão atual: " | "Versão mínima: "
EndIf

If lRet .And. !Empty(cMsg)
    If !Isblind()
        DEFINE DIALOG oDlg TITLE cTitle FROM 180, 180 TO 500, 750 PIXEL
        //Cria fonte para ser usada no TSay
        oFont := TFont():New("Courier new",, -15,.T.)

        lHtml := .T.
        oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,, lHtml)

        oBtnLink := TButton():New(145, 5, cSubTitle, oDlg,, 150, 12,,, .F., .T., .F.,, .F.,,, .F.)
        oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
        oBtnLink:bLClicked := {|| ShellExecute("open", cLink, "", "", 3)}

        ACTIVATE DIALOG oDlg CENTERED
    EndIf
    lRet := .F.
EndIf

Return lRet
