#Include 'totvs.ch'

/*/{Protheus.doc} FINSV001
    Chamada do Smart View no menu - listofinvoices - Relação de faturas a pagar

    @author fabioh.andrade@totvs.com.br
    @since 16/10/2023
    @version 12.1.2310
*/

Function FINSV032()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.listofinvoices",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR032",,,, "Program backoffice.sv.fin.listofinvoices not avaliable.")
    EndIf

Return
