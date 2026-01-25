#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.entrieswithbridgeaccount.bra.tlpp			Lançamentos de Apuraçao com Conta Ponte
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV013()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR10", "MV_PAR11", "MV_PAR12", "MV_PAR13"} as array
    Local cNome          := "backoffice.sv.ctb.entrieswithbridgeaccount" as character
    Local cNomeFnt       := "CTBR600" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR600")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf

    FreeObj(jParams)
  
Return
