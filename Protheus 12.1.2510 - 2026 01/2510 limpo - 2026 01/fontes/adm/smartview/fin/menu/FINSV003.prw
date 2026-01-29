#Include 'totvs.ch'

/*/{Protheus.doc} FINSV003
    Chamada do Smart View no menu - billsrecwithholdingtaxes - Títulos a receber com retenção de impostos

    @author guilhermed.santos@totvs.com.br
    @since 21/09/2023
    @version 12.1.2310
*/

Function FINSV003()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.billsrecwithholdingtaxes",,,,,.F.,,.T., @cError)
        If !lSuccess
            Conout(cError)
        EndIf
    Else
        Conout("rotina não disponivel")
    EndIf

Return
