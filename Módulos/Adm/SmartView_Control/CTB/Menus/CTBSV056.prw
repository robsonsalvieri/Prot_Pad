
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   07/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV056()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := { } as array
    Local cNome			 := "backoffice.sv.ctb.statementofmonetaryvariation" as character
    Local cError		 := "" 	     as character
    Local jParams	    as json

    aHiddenParams  := {"MV_PAR08", "MV_PAR10", "MV_PAR11", "MV_PAR12", "MV_PAR13",; 
                       "MV_PAR14", "MV_PAR15", "MV_PAR20", "MV_PAR21"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR380")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR380",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)
 
Return
