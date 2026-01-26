
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.responsiblexassets.bra.tlpp		
Responsáveis x Bens

@author Bruno Oliveira
@since 25/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV025()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR07"} as array
    Local cNome          := "backoffice.sv.atf.responsiblexassets" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR320")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFSV025",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
