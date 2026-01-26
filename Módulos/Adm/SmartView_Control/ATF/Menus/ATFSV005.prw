#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.atf.razaoanaliticoativo.businessobject.tlpp	    Posicao Valorizada dos Bens na Data / valuedpositiondate
Fonte/Perg  ATFR130	/ ATR130
@author     Controladoria
@since      OUT/2023
@version    12.1.2310
*/
//-------------------------------------------------------------------
Function ATFSV005()
    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR03", "MV_PAR20", "MV_PAR21", "MV_PAR22", "MV_PAR23", "MV_PAR26"} as array
    Local cNome          := "backoffice.sv.atf.valuedpositiondate" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"AFR073")
    
    If GetRpoRelease() >= "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.T., @cError)
        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    Else 
        Conout("rotina não disponivel")
    EndIf

    FreeObj(jParams)

Return
