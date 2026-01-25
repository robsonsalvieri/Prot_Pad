#include "protheus.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.referenceplanreason.bra.tlpp				Razao do Plano Referencial
Fonte/Perg  CTBR404	/ CTBR404
@author     Controladoria
@since      21/09/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function CTBSV009()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := { } as array
    Local cNome          := "backoffice.sv.ctb.referenceplanreason" as character
    Local cNomeFnt       := "CTBR404" as character
    Local cError         as character
    Local jParams        as json

    aHiddenParams := {"MV_PAR08", "MV_PAR09", "MV_PAR10", "MV_PAR11",; 
                      "MV_PAR12", "MV_PAR13", "MV_PAR14", "MV_PAR15"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTBR404")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf

    FreeObj(jParams)

Return
