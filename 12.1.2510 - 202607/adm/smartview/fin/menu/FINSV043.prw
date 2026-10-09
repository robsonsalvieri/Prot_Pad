#include "protheus.ch"

/*/{Protheus.doc} FINSV043
    Chamada do Smart View no menu.

    @author Matheus Monteiro da Silva
    @since 28/11/2023
    @version 12.1.2310
*/
Function FINSV043() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.suppliersaging",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR043",,,, "Program backoffice.sv.fin.suppliersaging not avaliable.")
    EndIf
       

Return lSuccess
