#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funçao para chamada do relatorio do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV001()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR13", "MV_PAR14", "MV_PAR15", "MV_PAR16", "MV_PAR20", "MV_PAR21"} as array
    Local cNome			 := "backoffice.sv.ctb.managementledger" as character
    Local cError		 := "" 	     as character
    Local jParams	    as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR430")   
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR430",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
