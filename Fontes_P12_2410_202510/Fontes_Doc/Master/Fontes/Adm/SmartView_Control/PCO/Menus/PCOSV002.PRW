
#include "msobject.ch"


Function PCOSV002()
    Local lSuccess  := .F. as logical 
    Local cNome     := "backoffice.sv.pco.budgetspreadsheetmod2" 
    Local cError as character
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "PCOSV002",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
