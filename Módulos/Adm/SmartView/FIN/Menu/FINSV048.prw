#include "protheus.ch"

/*/{Protheus.doc} FINSV048
    Chamada do Smart View no menu 
    - Design de Relatório
    - Visão de Dados
    - Impressão PIX

    @author Guilherme de Paula Santos
    @since 22/09/2023
    @version 12.1.2310
*/
Function FINSV048() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character

    lSuccess := .F.

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.printofpix",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV040",,,, "Program backoffice.sv.fin.printofpix not avaliable.")
    EndIf

Return lSuccess
