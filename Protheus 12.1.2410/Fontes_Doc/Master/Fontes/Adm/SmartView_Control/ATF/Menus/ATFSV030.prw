#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.assetratechangehistory.tlpp		
Histórico Alteração de Taxa do Ativo
@author  Controladoria
@since   08/05/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV030()
    local cError   as character
    local cNome    as character 
    local lSuccess as logical

    cError   := ""
    cNome    := "backoffice.sv.atf.assetratechangehistory"
    lSuccess := .F.
    
    if GetRpoRelease() > "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,,.F.,,.T., @cError)
    endif

    if !lSuccess
        FwLogMsg("WARN",, "ATFSV030",,,, "Program " + cNome + " erro : " + cError)
    endif

Return
