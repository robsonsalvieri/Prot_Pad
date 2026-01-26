
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.generaldiarybookmod2.bra	
Diário Geral por Documento Fiscal
@author  Gustavo Fernandes Campos
@since   06/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV051()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := { } as array
    Local cNome			 := "backoffice.sv.ctb.generaldiarybookmod2" as character
    Local cError		 := ""  as character
    Local jParams	    as json

    aHiddenParams := {"MV_PAR06", "MV_PAR07", "MV_PAR08", "MV_PAR09", "MV_PAR10",; 
                      "MV_PAR11", "MV_PAR14", "MV_PAR15", "MV_PAR16", "MV_PAR17",;
                      "MV_PAR19", "MV_PAR20"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR117") 
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR117",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
