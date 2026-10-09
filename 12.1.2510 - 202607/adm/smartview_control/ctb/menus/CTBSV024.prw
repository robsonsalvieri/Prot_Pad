
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author Renan Gremes
@since 09/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV024()   
    Local lSuccess      := .F. as logical
    Local aHiddenParams := {"MV_PAR09", "MV_PAR12", "MV_PAR13", "MV_PAR14", "MV_PAR15", "MV_PAR16", "MV_PAR18", "MV_PAR20", "MV_PAR24"}  as array
    Local cNome			:= "backoffice.sv.ctb.accountx12months" as character
    Local cError		:= ""  as character
    Local jParams as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR265")   
    
    If GetRpoRelease() >= "12.1.2310" 
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError) 
		If !lSuccess
            Conout(cError)
        EndIf
    else 
        Conout("rotina não disponivel")
    endIf
    
Return
