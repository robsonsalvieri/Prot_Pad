
#include "msobject.ch"


Function ATFSV017()
    Local lSuccess  := .F. as logical 
    Local cNome     := "backoffice.sv.atf.apportionmentofexpensesbyasset" 
    Local cError as character
    Local aHiddenParams  := {}  as array
    Local jParams	            as json
    
    aHiddenParams := {"MV_PAR20"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR074")

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFSV017",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
