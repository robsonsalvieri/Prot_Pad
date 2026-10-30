#Include 'Protheus.ch'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSROBPEG
Robo de processamento em fila de Protocolo - Utilizado por Scheduller previamente configurado
@author    Jose Paulo
@version   V12
@since     01/06/2026
/-------------------------------------------------------------------------------------------*/
function PLSROBPEG()
    local oFila	     as object 
    local lSucess    as logical
    local cCodOpe    := ""

    oFila   := filaPContas():New()
    lSucess := oFila:setupFila()
    cCodOpe := PLSINTPAD()

    if oFila:getPeg()	
        PLconvRDA7( cCodOpe, oFila:cCodLdp, oFila:cCodPeg )
        oFila:addGuia()
    endif

    if oFila:getPegOk()
        BCI->(DbSetOrder(1))
        BCI->(Msseek(xfilial("BCI") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg))
        if BCI->BCI_FASE == "1"
	        PLPEGTOT() //atualiza totais
	        PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()),.t.,.t.) //Atualiza Status                 
        endIf
        oFila:close()
    endif    
    
    oFila:getEveError() 
    oFila:getGuiError()

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

Return  {'P', '', '', {}, 'PLSROBPEG - PEGs',,.T.,.T.}
