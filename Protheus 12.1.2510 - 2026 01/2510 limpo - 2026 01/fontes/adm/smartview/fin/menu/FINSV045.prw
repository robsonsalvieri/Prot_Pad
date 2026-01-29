#Include 'totvs.ch'

/*/{Protheus.doc} FINSV045
    Chamada do Smart View no menu - efficiencyofaccpayable - Eficiência do Contas a Pagar

    @author fabioh.andrade@totvs.com.br
    @since 04/12/2023
    @version 12.1.2310
*/

Function FINSV045()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.efficiencyofaccpayable",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV045",,,, "Program backoffice.sv.fin.efficiencyofaccpayable not avaliable.")
    EndIf

Return
