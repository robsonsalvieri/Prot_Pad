#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.accountx6months.bra.tlpp	
Conta X 6 Meses

@author Bruno Oliveira
@since 04/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV017()  
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR09","MV_PAR12","MV_PAR13","MV_PAR14","MV_PAR15","MV_PAR16","MV_PAR20"} as array
    Local cNome			 := "backoffice.sv.ctb.accountx6months"   as character
    Local cError		 := "" 	     as character
    Local jParams	    as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR260")   
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR260",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
