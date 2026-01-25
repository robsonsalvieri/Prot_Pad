#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV006()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR05", "MV_PAR08"} as array
    Local cNome          := "backoffice.sv.ctb.entitybyledger" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR060")
    
    If GetRpoRelease() >= "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    else 
        Conout("rotina não disponivel")
    endIf
    
    FreeObj(jParams)

Return
