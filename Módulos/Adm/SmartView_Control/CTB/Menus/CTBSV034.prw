#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   23/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV034()   
    Local lSuccess      := .F. as logical
    Local aHiddenParams := {"MV_PAR03"} as array
    Local cNome			:= "backoffice.sv.ctb.accountingitem" as character
    Local cError		:= "" 	      as character
    Local cNomeFnt      := "CTBR030"  as character
    Local jParams as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR030")   
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf 
Return
