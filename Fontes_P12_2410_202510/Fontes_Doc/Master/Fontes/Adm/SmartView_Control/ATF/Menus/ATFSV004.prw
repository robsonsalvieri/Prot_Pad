#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.atf.razaoanaliticoativo.businessobject.tlpp	    Razão Analitico do Ativo Fixo / AnalyticalReasonFixedAsset
Fonte/Perg  ATFR130	/ ATR130
@author     Controladoria
@since      OUT/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV004()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {}  as array
    Local cNome          := "backoffice.sv.atf.analyticalreasonfixedasset" as character
    Local cError         as character
    Local cNomeFnt       := "ATFR130" as character
    Local jParams        as json

    aHiddenParams  := {"MV_PAR06", "MV_PAR08", "MV_PAR09", "MV_PAR10", "MV_PAR16"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR110") 
    
    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
    EndIf

    If ! lSuccess
        FwLogMsg("WARN",,cNomeFnt,,,,"Program "+ cNome +" erro: "+ cError )
    EndIf
 
Return
