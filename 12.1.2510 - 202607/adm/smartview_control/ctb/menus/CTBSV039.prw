#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.ClassifiedbyLot.bra	Lançamentos Classificados por Lote
@author  Controladoria
@since   24/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV039()

    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR12", "MV_PAR16", "MV_PAR17"} as array
    Local cNome          := "backoffice.sv.ctb.ClassifiedbyLot" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR080")
    
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
