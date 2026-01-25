#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV008()

    Local lSuccess As Logical
    Local cNome := "backoffice.sv.ctb.coinconversion"
    Local cError as character

    Local aHiddenParams := {} As Array
    Local jParams as json    

    aHiddenParams := {"MV_PAR22","MV_PAR13","MV_PAR14","MV_PAR15","MV_PAR16","MV_PAR18","MV_PAR10","MV_PAR25"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR045")   

    If GetRpoRelease() >= "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    Else 
        Conout("rotina não disponivel")`
    EndIf
 
Return
