#include "protheus.ch"

/*/{Protheus.doc} FINSV038
    Chamada do Smart View no menu.

    @author Matheus Monteiro da Silva
    @since 16/11/2023
    @version 12.1.2310
*/
Function FINSV038() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.billsreceivablebyinvoice",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINR038",,,, "Program backoffice.sv.fin.billsreceivablebyinvoice not avaliable.")
    EndIf
       

Return lSuccess
