#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.assetsheet.bra.tlpp		
Plano de Contas Referencial
@author  Controladoria
@since   26/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV011()
    Local lSuccess       := .F. as logical       
    Local aHiddenParams  := {"MV_PAR16", "MV_PAR17", "MV_PAR22", "MV_PAR24"} as array
    Local cNome          := "backoffice.sv.atf.assetsheet" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR030")    

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFSV011",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)
 
Return
