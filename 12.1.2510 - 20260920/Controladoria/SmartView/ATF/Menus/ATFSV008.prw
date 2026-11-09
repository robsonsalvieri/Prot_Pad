#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  Funcao para chamada do relatorio do Smart View
backoffice.atf.assets.tlpp	Posição Valorizada
@author  Controladoria
@since   21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV008()

    Local lSuccess 	As Logical
    Local cNome 	:= "backoffice.sv.atf.assets"
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
