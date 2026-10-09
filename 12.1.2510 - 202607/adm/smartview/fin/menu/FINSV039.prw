#Include 'totvs.ch'

/*/{Protheus.doc} FINSV039
    Chamada do Smart View no menu - backoffice.sv.fin.collectionreceipts - Documentos de Recebimentos Diversos

    @author fabioh.andrade@totvs.com.br
    @since 10/11/2023
    @version 12.1.2310
*/

Function FINSV039()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.collectionreceipts",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV039",,,, "Program backoffice.sv.fin.collectionreceipts not avaliable.")
    EndIf

Return
