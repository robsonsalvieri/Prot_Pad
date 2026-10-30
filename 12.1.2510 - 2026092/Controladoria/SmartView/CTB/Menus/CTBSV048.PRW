#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.balancesheetbyentities.bra balancete Por entidade
@author  Controladoria
@since   222/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV048()

    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR08", "MV_PAR11", "MV_PAR14"} as array
    Local cNome			 := "backoffice.sv.ctb.balancesheetbyentities"   as character
    Local cError		 := "" 	     as character
    Local jParams	    as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR051")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTRB051",,,, "Program " + cNome + " erro : " + cError)
    EndIf

Return
