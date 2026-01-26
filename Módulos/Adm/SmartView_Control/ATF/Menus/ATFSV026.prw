#include "protheus.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ATFSV026
Função para chamada do relatório do Smart View
backoffice.sv.atf.depreciationprojection.bra.tlpp	    Projeção de Depreciação / depreciationprojection
Fonte/Perg  ATFR350	/ AF350A
@author     Controladoria
@since      DEZ/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV026()
    Local lSuccess       := .F. as logical       
    Local aHiddenParams  := {"MV_PAR11", "MV_PAR12"} as array
    Local cNome          := "backoffice.sv.atf.depreciationprojection" as character
    Local cNomeFnt       := "ATFR350"
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
