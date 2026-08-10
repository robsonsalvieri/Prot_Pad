#Include 'totvs.ch'

/*/{Protheus.doc} FINSV002
    Chamada do Smart View no menu - listofcancelledchecks - Relação de cheques devolvidos

    @author guilhermed.santos@totvs.com.br
    @since 21/09/2023
    @version 12.1.2310
*/

Function FINSV002()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.listofcancelledchecks",,,,,.F.,,.T., @cError)
        If !lSuccess
            Conout(cError)
        EndIf
    Else
        Conout("rotina não disponivel")
    EndIf

Return
