#include "protheus.ch"
#include "finsv046.ch"

/*/{Protheus.doc} FINSV046
    Chamada do Smart View no menu.

    @author Matheus Monteiro da Silva
    @since 28/11/2023
    @version 12.1.2310
*/
Function FINSV046() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character

    if !FWSX1Util():ExistPergunte("FINT029")
		FINSV046HLP()
        return
	endIf
 
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.settlementsfinancial",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR046",,,, "Program backoffice.sv.fin.settlementsfinancial not avaliable.")
    EndIf
       

Return lSuccess


/*/{Protheus.doc} FINSV046HLP
    Exibe Finhelp na chamada do menu FINSV046

    @author guilhermed.santos@totvs.com.br
    @since 19/12/2024
    @version 12.1.2410
*/
static function FINSV046HLP()
    Local cMsg 		    := "" as character
	Local cTitulo 	    := "" as character
	Local aBtLinks 	    := ARRAY(1,2) as array
	Local cColorTitle   := "" as character
	Local cColorSubTitle := "" as character
	Local cColorText 	:= "" as character

	setHelpColors(@cColorTitle,@cColorSubTitle,@cColorText)

	cTitulo  := STR0001 + " - " + STR0002 //FINSV046 - Liquidações financeiras

	cMsg := "<font size='5' color='"+ cColorTitle +"'><b>" + STR0003 + " - " + STR0001 + "</b></font><br/><br/>"//HELP - FINSV046

	cMsg += "<font size='3' color='"+ cColorSubTitle +"'><b>" + STR0004 + "</b></font><br/>" //Ocorrência
	cMsg += "<font size='3' color='"+ cColorText +"'>" + STR0005 + "</font><br/><br/>"//Grupo de perguntas FINT029 ausente.

	cMsg += "<font size='3' color='"+ cColorSubTitle +"'><b>" + STR0006 + "</b></font><br/>" //Solução
	cMsg += "<font size='3' color='"+ cColorText +"'>" + STR0007 + "</font><br/><br/>" //A criação do grupo de perguntas pode ser realizada através da aplicação de pacote acumulado do Backoffice com data igual ou superior a 10/01/2025, ou manualmente conforme documentação.

	cMsg += "<font size='3' color='"+ cColorSubTitle +"'><b>" + STR0008 + "</b></font>" //Para maiores informações acesse:
	cMsg += "<br/><br/>"

	aBtLinks[1,1] :=  STR0009 + " - " + STR0001 //Documento de referência - FINSV046
	aBtLinks[1,2] := "https://tdn.totvs.com/pages/viewpage.action?pageId=899193532"

    FinHelp(cTitulo, cMsg, aBtLinks, 400, 600)
Return
