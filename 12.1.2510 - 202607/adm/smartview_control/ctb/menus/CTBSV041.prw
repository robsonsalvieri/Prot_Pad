#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.referentialchartofaccounts.bra.tlpp			
Plano de Contas Referencial
@author  Controladoria
@since   25/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV041()

    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR05"} as array
    Local cNome          := "backoffice.sv.ctb.referentialchartofaccounts" as character
    Local cNomeFnt       := "CTBR025" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTBR025")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf

    FreeObj(jParams)

Return
