
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.listrecoverablevalueofasset		
Relação do Valor Recuperável de Ativo

@author Renan Gremes
@since 15/01/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV028()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR13"} as array
    Local cNome          := "backoffice.sv.atf.listrecoverablevalueofasset" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR410")
    
    If GetRpoRelease() > "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFSV028",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
