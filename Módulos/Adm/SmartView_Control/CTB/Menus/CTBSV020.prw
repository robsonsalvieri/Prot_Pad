#include "protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   23/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV020()
    Local lSuccess As Logical
    Local cNome := "backoffice.sv.ctb.chartofaccounts"
    Local cError as character
    Local cNomeFnt  := "CTBR010"    as character
    Local aHiddenParams := {}       As Array
    Local jParams as json    

    aHiddenParams := {"MV_PAR04","MV_PAR09","MV_PAR10","MV_PAR11"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR010")  
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf    

Return
