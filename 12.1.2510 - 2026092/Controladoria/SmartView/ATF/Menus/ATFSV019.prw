#include "protheus.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.atf.downloadedassets.bra    Baixas de bens do Ativo Fixo / downloadedassets
Fonte/Perg  ATFR120	/ ATR120
@author     Controladoria
@since      DEZ/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV019()
    Local lSuccess       := .F. as logical       
    Local aHiddenParams  := {"MV_PAR11", "MV_PAR13"} as array
    Local cNome          := "backoffice.sv.atf.downloadedassets" as character
    Local cNomeFnt       := "ATFR120"
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,cNomeFnt) 
    
    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf
 
Return
