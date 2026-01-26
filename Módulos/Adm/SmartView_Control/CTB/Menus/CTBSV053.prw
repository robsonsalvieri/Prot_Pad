#include "protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  wilton.santos
@since   01/12/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV053()
    Local lSuccess  := .F. as logical 
    Local cNome     := "backoffice.sv.ctb.monthtomonthbalancecomparison" 
    Local cError as character
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "CTBR295",,,, "Program " + cNome + " erro : " + cError)
    EndIf 
Return
