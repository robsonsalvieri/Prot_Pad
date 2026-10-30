#include "protheus.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.atf.summarybyaccount	    Resumo por Conta
Fonte/Perg      ATFR080	/ AFR080
@author         Controladoria
@since          16/10/2023
@version        12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV009()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR20", "MV_PAR22"}  as array
    Local cNome          := "backoffice.sv.atf.summarybyaccount" as character
    Local cNomeFnt       := "ATFR080" as character
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR080")
    
    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf

    FreeObj(jParams)

Return
