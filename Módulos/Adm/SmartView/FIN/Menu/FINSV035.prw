#Include 'totvs.ch'

/*/{Protheus.doc} FINSV035
    Chamada do Smart View no menu - postrelationbylot - Relação de baixas por lote

    @author fabioh.andrade@totvs.com.br
    @since 20/10/2023
    @version 12.1.2310
*/

Function FINSV035()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.postrelationbylot",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR035",,,, "Program backoffice.sv.fin.postrelationbylot not avaliable.")
    EndIf

Return
