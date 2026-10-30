#include "protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   23/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV016()

    Local lSuccess       := .F. as logical
    Local cNome          := "backoffice.sv.ctb.balancesheetmod3" as character
    Local cError         as character
    
    Local aHiddenParams := {} As Array
    Local jParams as json    

    aHiddenParams  := {"MV_PAR09", "MV_PAR11", "MV_PAR12", "MV_PAR13", "MV_PAR14", "MV_PAR15", "MV_PAR16",; 
                       "MV_PAR17", "MV_PAR18", "MV_PAR20", "MV_PAR22", "MV_PAR25", "MV_PAR30"}
    
    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTBR060")   
    
    If GetRpoRelease() >= "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    Else 
        Conout("rotina não disponivel")
    EndIf

    FreeObj(jParams)

Return
