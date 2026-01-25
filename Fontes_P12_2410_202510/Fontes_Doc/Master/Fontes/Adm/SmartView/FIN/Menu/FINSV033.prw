#include "protheus.ch"

/*/{Protheus.doc} FINSV033
    @author guilherme.sordi@totvs.com.br
    @since 16/10/2023
    @version 12.1.2310
*/
Function FINSV033() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.compensationwithinportfolios",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR033",,,, "Program backoffice.sv.fin.compensationwithinportfolios not avaliable.")
    EndIf

Return lSuccess
