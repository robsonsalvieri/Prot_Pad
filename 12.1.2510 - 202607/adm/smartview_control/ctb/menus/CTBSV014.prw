#include "protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc}  funcao para chamada do relatorio do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV014()

    Local lSuccess as Logical
    Local cNome := "backoffice.sv.ctb.balancesheetmod2"
    Local cError   as character

    Local aHiddenParams := {} As Array
    Local jParams as json    

    aHiddenParams := {"MV_PAR20","MV_PAR23","MV_PAR24","MV_PAR11","MV_PAR12","MV_PAR13","MV_PAR14","MV_PAR15","MV_PAR16","MV_PAR09"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR160")    
    
    If GetRpoRelease() >= "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    Else 
        Conout("rotina não disponivel")
    EndIf
 
Return
