#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.ctb.razaoanaliticoativo.businessobject.tlpp	    Demonstrativo de Renda / incomestatement
Fonte/Perg  CTBR540	/ CTR540
@author     Controladoria
@since      NOV/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function CTBSV044()

    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR07", "MV_PAR08", "MV_PAR09", "MV_PAR12"} as array
    Local cNome			 := "backoffice.sv.ctb.incomestatement" as character
    Local cError		 := ""  as character
    Local jParams	    as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR540") 
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",, "CTBR540",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)

Return
