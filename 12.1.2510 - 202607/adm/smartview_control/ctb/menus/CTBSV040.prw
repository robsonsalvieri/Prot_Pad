#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.sv.ctb.listofmanagementvision	Listagem da Visão Gerencial
@author  Controladoria
@since   16/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function CTBSV040()

    Local lSuccess 	As Logical
    Local cNome 	:= "backoffice.sv.ctb.listofmanagementvision"
    Local cError 	As character
    
    If GetRpoRelease() >= "12.1.2310"

        lSuccess 	:= totvs.framework.treports.callTReports(cNome,,,,,.F.,,.F., @cError)

        If !lSuccess
            Conout("Erro na geração, verificar: " +cError)
        EndIf

    else 
        Conout("rotina não disponivel")
    endIf

Return
