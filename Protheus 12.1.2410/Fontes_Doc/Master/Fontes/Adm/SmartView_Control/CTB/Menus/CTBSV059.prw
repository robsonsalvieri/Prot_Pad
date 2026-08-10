
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.comparativebalanceofitemx6classvalues.bra.tlpp		
Balancete Comparativo de Item s/ 6 Cl. Valores
@author  Controladoria
@since   14/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV059()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR17","MV_PAR18","MV_PAR19","MV_PAR20","MV_PAR21","MV_PAR22","MV_PAR23","MV_PAR24"} as array
    Local cNome			 := "backoffice.sv.ctb.comparativebalanceofitemx6classvalues"   as character
    Local cError		 := "" 	     as character
    Local jParams as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR300")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTR300",,,, "Program " + cNome + " erro : " + cError)
    EndIf
    
    FreeObj(jParams)

Return
