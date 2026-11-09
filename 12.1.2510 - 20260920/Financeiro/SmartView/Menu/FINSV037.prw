#Include 'totvs.ch'

/*/{Protheus.doc} FINSV037
    Chamada do Smart View no menu - backoffice.sv.fin.receiptreportbyclient - Recibos por Cliente

    @author fabioh.andrade@totvs.com.br
    @since 10/11/2023
    @version 12.1.2310
*/

Function FINSV037()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.receiptreportbyclient",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV037",,,, "Program backoffice.sv.fin.receiptreportbyclient not avaliable.")
    EndIf

Return
