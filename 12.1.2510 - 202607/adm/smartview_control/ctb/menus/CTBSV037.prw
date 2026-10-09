#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.ctb.balancesheet6columns.bra.tlpp		
Balancete 6 Colunas
@author  Controladoria
@since   09/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV037()

    Local lSuccess       := .F. as logical
    Local aHiddenParams  := {"MV_PAR09", "MV_PAR12", "MV_PAR13", "MV_PAR14", "MV_PAR15", "MV_PAR17", "MV_PAR21", "MV_PAR24"} as array
    Local cNome          := "backoffice.sv.ctb.balancesheet6columns" as character 
    Local cError         as character
    Local jParams        as json

    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR170")
    
    If GetRpoRelease() >= "12.1.2310"

        lSuccess 	:= totvs.framework.treports.callTReports(cNome,,,,jParams,.F.,,.F., @cError)

        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf

    else 
        Conout("rotina não disponivel")
    endIf

    FreeObj(jParams)

Return
