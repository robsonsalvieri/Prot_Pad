#INCLUDE "TOTVS.CH"
/*/{Protheus.doc}AGDX030
Verifica se a TES atualiza estoque
@type function
@version P12
@author scheronlini.martins
@since 10/04/2025
@return Logical, return_true or false
/*/
function AGDX030(cTES)
	Local lRet     := .T.
	Local aArea    := FWGetArea()

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))

	if SF4->(dbSeek(FWxFilial("SF4") + cTES)) .and. AllTrim(SF4->F4_ESTOQUE) == "N"
		lRet := .F.
	endif
	
	FWRestArea(aArea)
return lRet
