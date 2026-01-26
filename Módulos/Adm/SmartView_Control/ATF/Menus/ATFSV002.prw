#include "protheus.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.acquisitions.bra.tlpp         Bens Adquiridos / acquisitions
Fonte/Perg  ATFR110	/ AFR110
@author     Controladoria
@since      OUT/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV002()
    Local lSuccess       := .F. as logical       
    Local aHiddenParams  := {"MV_PAR07", "MV_PAR13", "MV_PAR15"} as array
    Local cNome          := "backoffice.sv.atf.acquisitions" as character
    Local cError         as character
    Local cNomeFnt       := "ATFR110"    as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR110") 
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf 
 
Return
