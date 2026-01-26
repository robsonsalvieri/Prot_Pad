#include "protheus.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.assetadvances.bra.tlpp	    Adiantamentos do Ativo Fixo / assetadvances
Fonte/Perg  ATFR090	/ ATR090
@author     Controladoria
@since      DEZ/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV018()

    Local lSuccess      := .F.          as logical 
    Local cError                        as character
    Local cNomeFnt      := "ATFR090"    as character
    Local cNome         := "backoffice.sv.atf.assetadvances" 
    Local aHiddenParams := {}           as array

    aHiddenParams := {"MV_PAR17","MV_PAR11"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR074")

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf    
    
Return 

