#Include 'totvs.ch'

/*/{Protheus.doc} FINSV044
    Chamada do Smart View no menu - finanacialsummary - Resumo Financeiro

    @author fabioh.andrade@totvs.com.br
    @since 13/12/2023
    @version 12.1.2310
*/

Function FINSV044()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.financialsummary",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV044",,,, "Program backoffice.sv.fin.financialsummary not avaliable.")
    EndIf

Return
