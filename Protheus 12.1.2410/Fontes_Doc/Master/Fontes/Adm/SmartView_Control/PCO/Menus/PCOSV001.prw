#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.treports.pco.releases.bra.tlpp					Lançamentos
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function PCOSV001()
 
    Local lSuccess 	    := .F.          as Logical
    Local cNome 	    := "backoffice.sv.pco.releases" as character
    Local cError 	    := ""           as character
    Local cNomeFnt      := "PCOR400"    as character
    Local jParams	                    as json
    Local aHiddenParams := {}           as array
    
    
    aHiddenParams := {"MV_PAR13", "MV_PAR14", "MV_PAR15", "MV_PAR16", "MV_PAR15", "MV_PAR21", "MV_PAR24", "MV_PAR28"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"PCR400")

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf   
 
    FreeObj(jParams)

Return
