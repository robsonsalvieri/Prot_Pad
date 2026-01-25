#include "protheus.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funçao para chamada do relatorio do Smart View
backoffice.sv.atf.entriesbycostcenter.bra.tlpp      # Lançamento Por Centro de Custo / entriesbycostcenter
Fonte/Perg  ATFR190	/ ATR190
@author     Controladoria
@since      21/09/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV001()

    Local lSuccess                  as logical
    Local cNome     := "backoffice.sv.atf.entriesbycostcenter"
    Local cError                    as character
    Local cNomeFnt  := "ATFR190"    as character
    Local aHiddenParams  := {}  as array
    Local jParams	            as json

    aHiddenParams := {"MV_PAR09","MV_PAR11"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"ATR190")


    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf
 
Return
