
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.accumulatedmovementcostcenterxaccount.bra.tlpp	
Mov. Acumulados C. Custo X Contas

@author Bruno Oliveira
@since 25/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV046()  
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR08","MV_PAR12","MV_PAR13","MV_PAR14","MV_PAR15","MV_PAR16"} as array
    Local cNome			 := "backoffice.sv.ctb.accumulatedmovementcostcenterxaccount"   as character
    Local cError		 := "" 	     as character
    Local jParams	    as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR280")   
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR280",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
