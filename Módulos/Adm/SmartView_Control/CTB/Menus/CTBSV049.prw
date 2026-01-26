#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.balancesheetbyentities.bra balancete Por entidade
@author  Controladoria
@since   222/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV049()

    Local lSuccess  := .F. as logical 
    Local cNome     := "backoffice.sv.ctb.conferenceTypingTaxDocuments" 
    Local cError    := "" as character
    Local jParams          as json
    Local aHiddenParams  := {"MV_PAR09", "MV_PAR10", "MV_PAR14","MV_PAR17"} as array

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR075")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTRB075",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
