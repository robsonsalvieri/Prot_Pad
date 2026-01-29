
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.inventorybalancesheet.bra.tlpp		
Balancete de Inventário
@author  Controladoria
@since   01/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV047()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := { } as array
    Local cNome			 := "backoffice.sv.ctb.inventorybalancesheet" as character
    Local cError		 := ""  as character
    Local jParams	    as json

    aHiddenParams := {"MV_PAR09", "MV_PAR11", "MV_PAR12", "MV_PAR13", "MV_PAR14",; 
                      "MV_PAR15", "MV_PAR16", "MV_PAR20", "MV_PAR26", "MV_PAR28", "MV_PAR29"}
    
    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR046") 

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR046",,,, "Program " + cNome + " erro : " + cError)
    EndIf

    FreeObj(jParams)
 
Return
