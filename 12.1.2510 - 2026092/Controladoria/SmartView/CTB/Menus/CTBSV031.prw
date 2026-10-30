
#include "msobject.ch"


Function CTBSV031()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := { } as array
    Local cNome			 := "backoffice.sv.ctb.balancecostcenter"   as character
    Local cError		 := "" 	     as character
    Local jParams	    as json

    aHiddenParams  := {"MV_PAR09", "MV_PAR11", "MV_PAR12", "MV_PAR13", "MV_PAR14", "MV_PAR15",;
                       "MV_PAR16", "MV_PAR17", "MV_PAR23", "MV_PAR24"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR200")   
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR200",,,, "Program " + cNome + " erro : " + cError)
    EndIf
    
    
Return 
