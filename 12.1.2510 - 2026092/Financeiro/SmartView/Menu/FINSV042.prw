#include "protheus.ch"

/*/{Protheus.doc} FINSV038
    Chamada do Smart View no menu.

    @author Matheus Monteiro da Silva
    @since 16/11/2023
    @version 12.1.2310
*/
Function FINSV042() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.customersaging",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR042",,,, "Program backoffice.sv.fin.customersaging not avaliable.")
    EndIf
       

Return lSuccess
