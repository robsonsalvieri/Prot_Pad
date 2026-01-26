#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   23/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV042()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR03"} as array
    Local cNome			 := "backoffice.sv.ctb.valueclass" as character
    Local cError		 := "" 	     as character
    Local jParams	    as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR090")
    
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
