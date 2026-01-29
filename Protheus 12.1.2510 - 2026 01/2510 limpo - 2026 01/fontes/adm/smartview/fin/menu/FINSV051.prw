#Include 'totvs.ch'

/*/{Protheus.doc} FINSV051
	Chamada do Smart View no menu - ReplyOfBankCommunication - Retorno de Comunicação Bancária
@author guilhermed.santos@totvs.com.br
@since 21/02/2025
@version 12.1.2410
*/

Function FINSV051()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.replyofbankcommunication",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV051",,,, "Program backoffice.sv.fin.replyofbankcommunication not avaliable.")
    EndIf

Return
