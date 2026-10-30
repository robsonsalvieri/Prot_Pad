#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  wilton.santos
@since   04/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV007()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR01", "MV_PAR20", "MV_PAR25"} as array
    Local cNome          := "backoffice.sv.atf.valuedposition12months" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR073")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFR073",,,, "Program " + cNome + " erro : " + cError)
    EndIf 

    FreeObj(jParams)

Return
