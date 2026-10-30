#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.valueclassreason.bra.tlpp		
Razao Classe Valor
@author  Controladoria
@since   06/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV033()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR20", "MV_PAR21", "MV_PAR22", "MV_PAR23", "MV_PAR28", "MV_PAR29"} as array
    Local cNome			 := "backoffice.sv.ctb.valueclassreason" as character
    Local cError		 := "" 	     as character
    Local jParams	    as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR490")   
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR490",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)
 
Return
