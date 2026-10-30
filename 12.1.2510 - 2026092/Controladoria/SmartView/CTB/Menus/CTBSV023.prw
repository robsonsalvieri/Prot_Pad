#include "protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV023()
    Local lSuccess      := .F.    as Logical
    Local cError        := ""     as character 
    Local aHiddenParams := {}     as Array
    Local jParams                 as json   
    Local cNome         := "backoffice.sv.ctb.balsheetcostcenterxaccount" as character 
    
    aHiddenParams := {"MV_PAR11","MV_PAR14","MV_PAR15","MV_PAR16","MV_PAR17","MV_PAR18","MV_PAR20","MV_PAR21","MV_PAR28","MV_PAR29","MV_PAR30",;
    "MV_PAR31","MV_PAR32","MV_PAR37"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR180")

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
