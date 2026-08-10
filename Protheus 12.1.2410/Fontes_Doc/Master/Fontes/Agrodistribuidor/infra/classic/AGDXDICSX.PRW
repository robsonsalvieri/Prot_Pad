#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} AGDXSIXCHV
Retorna a chave do indice da tabela
@type function
@version P12.1.2410 
@author claudineia.reinert
@since 17/12/2024
@param cTab, character, Codigo da tabela
@param nOrdem, numeric, ordem do indice
@return character, retorna CHAVE do indice(SIX) da tabela
/*/
Function AGDXSIXCHV(cTab, nOrdem)
	Local nX := 0
	Local cChave := ""
	Local aIndex := {}

	If FWSIXUtil():ExistIndex( cTab , cValToChar(nOrdem) , .F.)
		aIndex := FWSIXUtil():GetAliasIndexes(cTab)[nOrdem]
		For nX := 1 to Len(aIndex)
			IF nX > 1
				cChave += "+"
			EndIf
			cChave += Alltrim(aIndex[nX])
		Next nX
	EndIf

return cChave

