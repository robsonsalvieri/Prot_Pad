#include "TOTVS.CH"

/*/{Protheus.doc} P156CallApp
Realiza a abertura do app de acompanhamento de pedidos.
Obs.: A abertura é realizada neste fonte (.prw) e não no fonte de interface (.tlpp) devido a execução da função jsToAdvpl que não pode ser chamada no tlpp.

@type  Function
@author Lucas Fagundes
@since 26/08/2026
@version P12
@return Nil
/*/
Function P156CallApp()

    FwCallApp("acompanhamento-pedidos")

Return Nil

/*/{Protheus.doc} jsToAdvpl
Bloco de código que receberá as chamadas da tela.

@type  Static Function
@author Lucas Fagundes
@since 26/08/2026
@version P12
@param oWebChannel, Object, Instancia da classe TWebEngine.
@param cType, Caracter, Parâmetro de tipo.
@param cContent, Caracter, Conteúdo enviado pela tela.
@return .T.
/*/
Static Function jsToAdvpl(oWebChannel, cType, cContent)

Return PCPA156Interface():processJsToAdvpl(oWebChannel, cType, cContent)
