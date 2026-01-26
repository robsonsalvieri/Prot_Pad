#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.ClassifiedbyLot.bra	Lançamentos Classificados por Lote
@author  Controladoria
@since   24/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV025()

    Local lSuccess 	    := .F.  as Logical
    Local aHiddenParams := {}   as array
    Local cError 	    := ""   as character
    Local cNome 	:= "backoffice.sv.ctb.BookDiary" as character
    Local jParams	            as json

    aHiddenParams := {"MV_PAR06", "MV_PAR07", "MV_PAR08", "MV_PAR09", "MV_PAR10", "MV_PAR11", "MV_PAR14", "MV_PAR15",; 
                "MV_PAR16", "MV_PAR17","MV_PAR18","MV_PAR19"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR110")                    

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
