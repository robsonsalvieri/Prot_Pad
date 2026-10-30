#Include 'Protheus.ch'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSROBGU
Robo de processamento em fila de Guias
@author    Jose Paulo
@version   V12
@since     01/06/2026
/*/
function PLSROBGU(aEmp)
    local oFila	    as object
    local lSucess   as logical

    oFila   := filaPContas():New()
    lSucess := oFila:setupFila()

    if oFila:getGuia()        
    	IIf(!PLSPEG001(oFila),oFila:addEvento(),oFila:guiaNaoProc())
    endif
    
    if oFila:getGuiaOk()        
    	PLSGUIA001(oFila)        
        oFila:fimGuia()
    endif

return

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author jose.paulo
@since 03/06/2026
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
Static Function Scheddef()

Return  {'P', '', '', {}, 'PLSROBGU - Guias',,.T.,.T.}
