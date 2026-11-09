#include "protheus.ch"

/*/{Protheus.doc} FINSV052
    Chamada do Smart View no menu 
    Relatório detalhado e simplificado
    Quitação de Débitos

    @author matheus.monteiro@totvs.com.br
    @since 04/03/2026
    @version 12.1.2510
*/
Function FINSV052() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character

    lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.debitsettlement",,,,,.F.,,.T., @cError)
    If !lSuccess
        Conout(cError)
    EndIf

Return lSuccess
