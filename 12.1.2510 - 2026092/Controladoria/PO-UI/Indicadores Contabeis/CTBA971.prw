#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "CTBA971.CH"

Function CTBA971()

	If ReqMinim971()
		FWCallApp("ctba971",,,,,,,,,.T.)
	EndIf

Return

/*{Protheus.doc ReqMinim971
Valida os requisitos minimos para acessar a nova rotina de rateio
@author TOTVS
@since 15/12/2023
@version P12
@project Squad Control
*/
Static Function ReqMinim971(lAutoDic, lAutoRlse)

	Local oBtnLink
	Local cMsg	     := ""
	Local cTitle     := ""
	Local cSubTitle  := ""
	Local cLink      := ""
	Local lRet       := .T.

	DEFAULT lAutoDic    := .F.
	DEFAULT lAutoRlse   := .F.

	If ! CTS->(FieldPos("CTS_ENTGRP")) > 0 
		FWAlertHelp( STR0001;//;
			, STR0002 ) //"Atualize seu dicionário de dados com a expedição continua para incluir o campo e utilizar o Agrupador Contábil."
		lRet := .F.
	EndIf

	//Release
	If  lRet .And. GetRPORelease() < "12.1.2310" .Or. lAutoRlse
		cTitle    := STR0003 // "Ambiente Desatualizado"
		cSubTitle := STR0004 // "Acesse o Portal do Cliente"
		cLink     := "https://suporte.totvs.com/portal/p/10098/download#000006/"

		cMsg += '<b>' + STR0005 + ' </b><br>' 	// "RPO está desatualizado"
		cMsg += ' ' + STR0006 + ' ' + GetRPORelease() + ' - ' + STR0007 + '12.1.2310 <br><br>' 	//"Versão atual: " | "Versão mínima: "
	EndIf

	If lRet .And. !Empty(cMsg)
		If !Isblind()
			DEFINE DIALOG oDlg TITLE cTitle FROM 180,180 TO 500,750 PIXEL
			// Cria fonte para ser usada no TSay
			oFont := TFont():New('Courier new',,-15,.T.)

			lHtml := .T.
			oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

			oBtnLink := TButton():New( 145, 5, cSubTitle, oDlg,, 150 ,12,,,.F.,.T.,.F.,,.F.,,,.F. )
			oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
			oBtnLink:bLClicked := {|| ShellExecute("open", cLink,"","",3) }

			ACTIVATE DIALOG oDlg CENTERED
		EndIf
		lRet := .F.
	EndIf

Return lRet
