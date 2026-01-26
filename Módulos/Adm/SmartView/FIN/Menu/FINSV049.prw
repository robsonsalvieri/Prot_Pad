#Include 'totvs.ch'

/*/{Protheus.doc} FINSV049
    Chamada do Smart View no menu - customermovementsbymonth - Movimento Mês a Mês

    @author fabioh.andrade@totvs.com.br
    @since 20/12/2023
    @version 12.1.2310
*/

Function FINSV049()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.customermovementsbymonth",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV049",,,, "Program backoffice.sv.fin.customermovementsbymonth not avaliable.")
    EndIf

Return
