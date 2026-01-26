#include "protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV018()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {}  as array
    Local cNome			 := "backoffice.sv.ctb.ledger" as character
    Local cError		 := "" 	as character
    Local jParams	            as json

    aHiddenParams := {"MV_PAR21", "MV_PAR22", "MV_PAR23", "MV_PAR24", "MV_PAR28", "MV_PAR29", "MV_PAR31", "MV_PAR32",; 
                      "MV_PAR34", "MV_PAR35", "MV_PAR36", "MV_PAR37", "MV_PAR38", "MV_PAR39", "MV_PAR40", "MV_PAR41", "MV_PAR42"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR400")
    
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
