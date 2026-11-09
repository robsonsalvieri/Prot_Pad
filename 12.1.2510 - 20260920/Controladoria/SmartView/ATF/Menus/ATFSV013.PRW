
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV013()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR09", "MV_PAR13"}  as array
    Local cNome			 := "backoffice.sv.atf.balancetodepreciate" as character
    Local cError		 := "" 	as character
    Local jParams	            as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"ATR050")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFSV013",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
