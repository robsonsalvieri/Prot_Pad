#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.monetarycorrection.bra.tlpp		
Correção Monetária
@author Bruno Oliveira
@since 25/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV020()
    Local lSuccess       := .F. as logical       
    Local aHiddenParams  := {"MV_PAR04"} as array
    Local cNome          := "backoffice.sv.atf.monetarycorrection" as character
    Local cNomeFnt       := "ATFR170" as character
    Local cError  as character    
    Local jParams as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,cNomeFnt) 
    
    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFSV020",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
