#include "protheus.ch"

/*/{Protheus.doc} FINSV034
    @author guilherme.sordi@totvs.com.br
    @since 14/11/2023
    @version 12.1.2310
*/
Function FINSV034() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.deliveryofbankcommunication",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR034",,,, "Program backoffice.sv.fin.deliveryofbankcommunication not avaliable.")
    EndIf

Return lSuccess
