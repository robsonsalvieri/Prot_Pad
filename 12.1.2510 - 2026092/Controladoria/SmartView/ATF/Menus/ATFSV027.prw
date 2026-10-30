#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.provisionandrealizationofdepreciation.bra.tlpp		
Provisão e Realização da Depreciação
@author  Controladoria
@since   15/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV027()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR08", "MV_PAR11"} as array
    Local cNome          := "backoffice.sv.atf.provisionandrealizationofdepreciation" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR432")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "AFR432",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
