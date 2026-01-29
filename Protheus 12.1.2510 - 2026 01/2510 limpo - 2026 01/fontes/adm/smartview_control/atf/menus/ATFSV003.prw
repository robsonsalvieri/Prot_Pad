#include "protheus.ch"
#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.atf.valuedposition.businessobject.tlpp	Posicao Valorizada dos Bens
Fonte/Perg      ATFR070	/ AFR070
@author     Controladoria
@since      21/09/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV003()

    Local lSuccess 	                as Logical
    Local cNome 	:= "backoffice.sv.atf.valuedposition"
    Local cError 	                as character
    Local cNomeFnt  := "ATFR070"    as character
    Local jParams	                as json

    aHiddenParams := {"MV_PAR05","MV_PAR06","MV_PAR07","MV_PAR08","MV_PAR09","MV_PAR11","MV_PAR12","MV_PAR13","MV_PAR15","MV_PAR16"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFA070")

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf    

Return
