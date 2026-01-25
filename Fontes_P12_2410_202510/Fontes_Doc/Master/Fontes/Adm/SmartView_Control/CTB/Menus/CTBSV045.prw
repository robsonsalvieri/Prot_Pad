#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  wilton.santos
@since   27/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV045()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR13"} as array
    Local cNome          := "backoffice.sv.ctb.accountingentriescostcenter" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR095")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR095",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
