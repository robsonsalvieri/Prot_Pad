#include "protheus.ch"

/*/{Protheus.doc} FINSV030
    Chamada do Smart View no menu.

    @author Matheus Monteiro da Silva
    @since 22/10/2023
    @version 12.1.2310
*/
Function FINSV036() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.taxgroupinformation",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR036",,,, "Program backoffice.sv.fin.taxgroupinformation not avaliable.")
    EndIf
       

Return lSuccess
