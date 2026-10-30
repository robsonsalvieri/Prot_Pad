#Include "TOTVS.CH"

/*/{Protheus.doc} P157CallApp
Realiza a abertura da tela do cockpit do MRP.
Obs.: A abertura é realizada neste fonte (.prw) e não no fonte de interface (.tlpp) devido a execução da função jsToAdvpl que não pode ser chamada no tlpp.
@type  Function
@author Lucas Fagundes
@since 18/08/2026
@version P12
/*/
Function P157CallApp()

    FwCallApp("cockpit-mrp")

Return Nil

/*/{Protheus.doc} jsToAdvpl
Bloco de código que receberá as chamadas da tela.

@type  Static Function
@author Lucas Fag
@since 05/08/2026
@version P12
@param oWebChannel, Object, Instancia da classe TWebEngine.
@param cType, Caracter, Parâmetro de tipo.
@param cContent, Caracter, Conteúdo enviado pela tela.
@return .T.
/*/
Static Function jsToAdvpl(oWebChannel, cType, cContent)

Return PCPA157Interface():processJsToAdvpl(oWebChannel, cType, cContent)
