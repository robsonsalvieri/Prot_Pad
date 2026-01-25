#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.ledgerbyaccountingitem.bra	Livro Razão Item Contábil
@author  Controladoria
@since   10/11/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV022()

    Local lSuccess  	:= .F. As Logical
    Local cNome 	    := "backoffice.sv.ctb.ledgerbyaccountingitem" as character
    Local cError 	    := ""  As character
    Local aHiddenParams := {"MV_PAR20","MV_PAR21","MV_PAR22","MV_PAR23","MV_PAR28","MV_PAR29"} as array
    Local jParams	    as json
    
    jParams := totvs.protheus.backoffice.sv.control.paramutil.ControlSvParamUtil():hiddenParam(aHiddenParams,"CTR480")  

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
