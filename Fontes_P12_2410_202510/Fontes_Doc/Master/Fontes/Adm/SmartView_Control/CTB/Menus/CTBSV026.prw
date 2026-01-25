#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.balancesheetaccountxcostcenter.bra.tlpp		
Balancete Conta x Centro de Custo
@author  Controladoria
@since   14/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV026()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR09", "MV_PAR11", "MV_PAR13", "MV_PAR18", "MV_PAR19", "MV_PAR20", "MV_PAR21", "MV_PAR22", "MV_PAR29"} as array
    Local cNome 	     := "backoffice.sv.ctb.balancesheetaccountxcostcenter" as character
    Local cError 	     as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR145")   
    
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
