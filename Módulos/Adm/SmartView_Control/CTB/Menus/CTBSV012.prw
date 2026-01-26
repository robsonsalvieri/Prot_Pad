#include "protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV012()

    Local lSuccess As Logical
    Local cNome := "backoffice.sv.ctb.balancesheetmod4" 
    Local cError as character

    Local aHiddenParams := {} As Array
    Local jParams as json    

    aHiddenParams := {"MV_PAR09","MV_PAR11","MV_PAR12","MV_PAR13","MV_PAR14","MV_PAR15","MV_PAR16",;
                      "MV_PAR17","MV_PAR19","MV_PAR21","MV_PAR24","MV_PAR28","MV_PAR30"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR040")      
    
    If GetRpoRelease() >= "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    Else 
        Conout("rotina não disponivel")
    EndIf 
Return
