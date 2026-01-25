
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.balancesheetitemxcostcenter
@author Bruno Oliveira (BO)
@since 11/12/2024
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV054()
    Local lSuccess  := .F. as logical 
    Local cNome     := "backoffice.sv.ctb.balancesheetitemxcostcenter" 
    Local cError as character

    Local aHiddenParams := {} As Array
    Local jParams as json    

    aHiddenParams := {"MV_PAR11","MV_PAR13","MV_PAR14","MV_PAR15","MV_PAR16","MV_PAR17","MV_PAR19","MV_PAR22"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR330")      
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBSV054",,,, "Program " + cNome + " erro : " + cError)
    EndIf
    
    FreeObj(jParams)
Return
