#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.demonstrationcashflow.bra	DEMONSTRACAO DO FLUXO DE CAIXA 
@author  Controladoria
@since   222/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV058()

    Local lSuccess       := .F. as logical
    Local aHiddenParams  := { } as array
    Local cNome          := "backoffice.sv.ctb.demonstrationcashflow" as character
    Local cError         as character
    Local jParams        as json

    aHiddenParams  := {"MV_PAR06", "MV_PAR07", "MV_PAR10", "MV_PAR11","MV_PAR18",; 
                       "MV_PAR19", "MV_PAR20", "MV_PAR21", "MV_PAR22", "MV_PAR23"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR560")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR095",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
