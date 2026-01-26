#include "protheus.ch"

/*/{Protheus.doc} FINSV041
    @author guilherme.sordi@totvs.com.br
    @since 21/11/2023
    @version 12.1.2310
*/
Function FINSV041() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.bankstatementbybankcommunication",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR041",,,, "Program backoffice.sv.fin.bankstatementbybankcommunication not avaliable.")
    EndIf

Return lSuccess
