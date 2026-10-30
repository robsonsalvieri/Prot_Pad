#include "PROTHEUS.CH"
#include "msobject.ch"


Function ATFSV023()
    Local lSuccess  := .F. as logical 
    Local cNome     := "backoffice.sv.atf.expansionofassets" 
    Local cError as character
    Local aHiddenParams  := {}  as array
    Local jParams	            as json

    aHiddenParams := {"MV_PAR08"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR260")

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFR260",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
