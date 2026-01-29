#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.analyticalsyntheticbalancesheetmod1.bra.tlpp			
Balancete Analitico Sintetico Modelo 1
@author  Controladoria
@since   14/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV043()

    Local lSuccess 	    := .F.  as logical
    Local cError 	    := "" 	as character
    Local aHiddenParams  := {}  as array
    Local cNome 	     := "backoffice.sv.ctb.analyticalsyntheticbalancesheetmod1"
    Local jParams	            as json

    aHiddenParams := {"MV_PAR09", "MV_PAR12", "MV_PAR13", "MV_PAR14", "MV_PAR15", "MV_PAR21", "MV_PAR24", "MV_PAR28",; 
                    "MV_PAR29", "MV_PAR30"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR040")                    

    If GetRpoRelease() >= "12.1.2310"
        lSuccess 	:= totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)

        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    else 
        Conout("rotina não disponivel")
    endIf

    FreeObj(jParams)

Return
