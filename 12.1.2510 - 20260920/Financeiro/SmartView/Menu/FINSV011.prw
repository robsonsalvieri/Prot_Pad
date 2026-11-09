#Include 'totvs.ch'

/*/{Protheus.doc} FINSV011
    Chamada do Smart View no menu - generalaccountspayablestatus - Posição Geral do Contas a Pagar

    @author guilhermed.santos@totvs.com.br
    @since 21/09/2023
    @version 12.1.2310
*/

Function FINSV011()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.generalaccountspayablestatus",,,,,.F.,,.T., @cError)
        If !lSuccess
            Conout(cError)
        EndIf
    Else
        Conout("rotina não disponivel")
    EndIf

Return
