#Include 'totvs.ch'

/*/{Protheus.doc} FINSV040
    Chamada do Smart View no menu - generalaccountsreceivablestatus - Posição Geral do Contas a Receber

    @author guilhermed.santos@totvs.com.br
    @since 21/09/2023
    @version 12.1.2310
*/

Function FINSV040()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.generalaccountsreceivablestatus",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV040",,,, "Program backoffice.sv.fin.generalaccountsreceivablestatus not avaliable.")
    EndIf

Return
