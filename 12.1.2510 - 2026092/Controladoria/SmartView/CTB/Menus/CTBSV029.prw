#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.balancepatrimonial.bra	Balanço Patrimonial
@author  Controladoria
@since   22/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV029()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR05", "MV_PAR06", "MV_PAR07", "MV_PAR13", "MV_PAR14"} as array
    Local cNome          := "backoffice.sv.ctb.balancepatrimonial" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR500")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR095",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
