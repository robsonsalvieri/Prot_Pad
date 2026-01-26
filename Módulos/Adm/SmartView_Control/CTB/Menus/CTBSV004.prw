#include "protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  FunÃ§Ã£o para chamada do relatÃ³rio do Smart View
 
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV004()
    Local lSuccess As Logical
    Local cNome := "backoffice.sv.ctb.accountx6branches"
    Local cError as character
    
    Local aHiddenParams  := {}  as array
    Local jParams	            as json
    
    aHiddenParams := {"MV_PAR15","MV_PAR17","MV_PAR18","MV_PAR19","MV_PAR20","MV_PAR21","MV_PAR22","MV_PAR26"}

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR250")
    
    If GetRpoRelease() >= "12.1.2310"
        lSuccess := totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)
        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf
    else 
        Conout("rotina não disponivel")`
    endIf
 
Return