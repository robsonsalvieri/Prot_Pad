#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.ledger2coin.bra	Razão 2 moedas
@author  Controladoria
@since   24/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV027()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {}  as array
    Local cNome 	     := "backoffice.sv.ctb.ledger2coin" as character
    Local cError 	     as character
    Local jParams        as json

    aHiddenParams := { "MV_PAR14", "MV_PAR21", "MV_PAR22",; 
                      "MV_PAR23", "MV_PAR24", "MV_PAR26"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR410") 
    
    If GetRpoRelease() >= "12.1.2310"
        lSuccess 	:= totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)

        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    else 
        Conout("rotina não disponivel")
    endIf

    FreeObj(jParams)
    
Return
