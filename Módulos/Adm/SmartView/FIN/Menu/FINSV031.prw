#Include 'totvs.ch'

/*/{Protheus.doc} FINSV031
    Chamada do Smart View pelo menu.
    @author guilherme.sordi@totvs.com.br
    @since 06/11/2023
    @version 12.1.2310
*/

Function FINSV031()

    Local lSuccess As Logical
    Local xError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.pccstatement",,,,,.F.,,.T., @xError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR031",,,, "Program backoffice.sv.fin.pccstatement not avaliable.")
    EndIf

Return
