
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.assetsdepreciatedbypercentage.bra.tlpp		
Bens Depreciados por %
@author  Controladoria
@since   26/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV021()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR11", "MV_PAR13"} as array
    Local cNome          := "backoffice.sv.atf.assetsdepreciatedbypercentage" as character
    Local cNomeFnt       := "ATFR200"
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,cNomeFnt) 
    
    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFSV013",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
