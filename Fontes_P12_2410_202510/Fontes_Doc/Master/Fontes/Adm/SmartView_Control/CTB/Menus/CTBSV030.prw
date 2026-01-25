
#include "msobject.ch"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.balancesheetaccountxitem.bra	Balancete de Contas x Itens
@author  Controladoria
@since   22/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV030()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR11","MV_PAR13","MV_PAR14","MV_PAR15","MV_PAR16","MV_PAR17","MV_PAR19","MV_PAR20","MV_PAR21","MV_PAR28"} as array
    Local cNome          := "backoffice.sv.ctb.balancesheetaccountxitem" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR140")
 
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
