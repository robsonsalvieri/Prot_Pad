#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.costcenterledger.bra.tlpp		
Razao Centro de Custo
@author  Controladoria
@since   07/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV021()

    Local cNome     := "backoffice.sv.ctb.costcenterledger"  as character
    Local jParams          as json
    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
    Local aHiddenParams  := {"MV_PAR20", "MV_PAR21", "MV_PAR22", "MV_PAR23", "MV_PAR28", "MV_PAR29", "MV_PAR14", "MV_PAR17"} as array
    
    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR440")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR112",,,, "Program " + cNome + " erro : " + cError)
    EndIf
    
    FreeObj(jParams)

Return
