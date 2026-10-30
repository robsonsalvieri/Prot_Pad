#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.provisionandrealizationofdepreciation.bra.tlpp		
Demonstrativo de Ativos
@author  Controladoria
@since   22/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV015()
    Local lSuccess       := .F. as logical       
    Local aHiddenParams  := {"MV_PAR10", "MV_PAR12", "MV_PAR13", "MV_PAR14"} as array
    Local cNome          := "backoffice.sv.atf.fixedassetstatement" as character
    Local cNomeFnt       := "ATFR033" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,cNomeFnt) 
    
    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFR033",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
