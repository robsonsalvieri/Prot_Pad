#include "msobject.ch"
#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.acquisitionbytransfer.bra.tlpp		
Aquisição por Transferência
@author  Controladoria
@since   26/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV022()
    Local lSuccess       := .F. as logical       
    Local aHiddenParams  := {"MV_PAR06"} as array
    Local cNome          := "backoffice.sv.atf.acquisitionbytransfer" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR250") 
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "ATFSV022",,,, "Program " + cNome + " erro : " + cError)
    EndIf
 
Return
