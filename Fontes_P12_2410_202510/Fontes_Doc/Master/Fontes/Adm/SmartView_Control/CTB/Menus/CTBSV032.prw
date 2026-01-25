
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.balancesheetitem
@author Renan Gremes
@since 09/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV032()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR09","MV_PAR12","MV_PAR13","MV_PAR14","MV_PAR15","MV_PAR17","MV_PAR18","MV_PAR23"} as array
    Local cNome			 := "backoffice.sv.ctb.balancesheetitem"   as character
    Local cError		 := "" 	     as character
    Local jParams as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR120")   
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR120",,,, "Program " + cNome + " erro : " + cError)
    EndIf
    
    FreeObj(jParams)
    
Return 
