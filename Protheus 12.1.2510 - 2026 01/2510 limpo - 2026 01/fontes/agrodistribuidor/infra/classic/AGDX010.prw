#INCLUDE "TOTVS.CH"
#INCLUDE "AGDX010.CH"

/*/{Protheus.doc} AGDX010
Faz a validação do código da moeda informada.
Tabelas SM2 e SX6.
@type function
@version 12
@author jc.maldonado
@since 26/03/2025
@param nCodMoeda, numeric, Código da Moeda
@param lHelp, logical, Habilita/Desabilita a mensagem de ajuda
@return logical, Resultado da validação
/*/
Function AGDX010(nCodMoeda, lHelp)
	Local cCodMoeda := cValToChar(nCodMoeda)
	Local cCampo    := "M2_MOEDA" + cCodMoeda
	Local cParam    := "MV_MOEDA" + cCodMoeda

	Default lHelp   := .F.

	If Empty(FWSX3Util():GetFieldStruct(cCampo))
		If lHelp
			AGDHELP(STR0001, STR0002, STR0003) // "AJUDA", "Código de moeda inválido.", "Informe um código de moeda válido."
		Endif
		Return .F.
	Endif

	If Empty(SUPERGETMV(cParam, .F. /*lHelp*/, ""))
		If lHelp
			AGDHELP(STR0001, STR0004, STR0005) // "AJUDA", "Parâmetro inválido para o código de moeda informado", "Verifique o cadastro do parâmetro do código da moeda informado."
		Endif
		Return .F.
	EndIf
Return .T.
