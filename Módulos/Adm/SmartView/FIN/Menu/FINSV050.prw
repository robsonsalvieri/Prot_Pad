#Include 'totvs.ch'

/*/{Protheus.doc} FINSV050
	Chamada do Smart View no menu - bankslist - Lista de Bancos
@author Everton Fregonezi Diniz
@since 13/05/2024
@version 12.1.2310
*/

Function FINSV050()

    Local lSuccess As Logical
    Local cError

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.bankslist",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV050",,,, "Program backoffice.sv.fin.bankslist not avaliable.")
    EndIf

Return
