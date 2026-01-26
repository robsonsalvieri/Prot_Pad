
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.incomestatementverticalxhorizontalanalysis.bra.tlpp		
Demonstrativo Analise Vertical x Analise Horizontal
@author  Controladoria
@since   13/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV057()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR07", "MV_PAR08", "MV_PAR09", "MV_PAR14"} as array
    Local cNome			 := "backoffice.sv.ctb.incomestatementverticalxhorizontalanalysis" as character
    Local cError		 := ""  as character
    Local jParams	    as json   
    
    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR542") 
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBSV057",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)
 
Return
