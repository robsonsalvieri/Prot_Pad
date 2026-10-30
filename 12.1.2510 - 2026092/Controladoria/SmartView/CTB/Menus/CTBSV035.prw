
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.balancesheetmod5.bra.tlpp		
Balanço Modelo 5
@author  Controladoria
@since   14/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV035()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR10", "MV_PAR11", "MV_PAR12", "MV_PAR20", "MV_PAR21"} as array
    Local cNome			 := "backoffice.sv.ctb.balancesheetmod5"   as character
    Local cError		 := "" 	     as character
    Local jParams as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR044")
    
    If GetRpoRelease() >= "12.1.2310" 
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError) 
		If !lSuccess
            Conout(cError)
        EndIf
    else 
        Conout("rotina não disponivel")
    endIf
    
    FreeObj(jParams)

Return
