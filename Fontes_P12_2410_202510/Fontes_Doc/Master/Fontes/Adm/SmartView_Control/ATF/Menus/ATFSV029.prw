#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.simulationrecoverablevalueassets.tlpp		
Provisão e Realização da Depreciação
@author  Controladoria
@since   21/01/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV029()

Local aHiddenParams  := {"MV_PAR07"}  as array
Local cError         := ""  as character
Local cNome          := "backoffice.sv.atf.simulationrecoverablevalueassets" as character 
Local jParams               as json
Local lSuccess       := .F. as logical

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR411")
    
    if GetRpoRelease() > '12.1.2310'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    endif

    if !lSuccess
        FwLogMsg("WARN",, "ATFSV029",,,, "Program " + cNome + " erro : " + cError)
    endif

    FreeObj(jParams)

Return
