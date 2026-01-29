#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.demonstrativeresult.bra	Demonstrativo de Resultados ( DRE )
@author  Controladoria
@since   222/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV015()

    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR07", "MV_PAR10", "MV_PAR11", "MV_PAR16","MV_PAR19"} as array
    Local cNome          := "backoffice.sv.ctb.demonstrativeresult" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR510")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR510",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
