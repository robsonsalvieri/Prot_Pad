#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjMdlSL4
Classe leve que simula, somente para leitura, o contrato de grid (SL4) exigido pelo
metodo STWReceiptTitle():DropTitles() -  Length(), GoLine(nLinha) e GetValue(cCampo) -
sem depender de FWFormModel/FWFormGridModel nem da tabela fisica SL4 aberta em workarea.
Utilizada para popular, a partir de payload JSON (PDV Omni), as formas de pagamento que
seriam originadas de um grid SL4 real em uma sessao interativa do TOTVS PDV.

@type    Class
@author  Bruno Almeida
@since   02/09/2026
@version v12
/*/
//-------------------------------------------------------------------------------------
Class LjMdlSL4

	Data aLinhas		// Array com as linhas do grid simulado. Cada linha e um Array de pares {cCampo, xValor}
	Data nLinAtu		// Ponteiro da linha corrente (posicionado via GoLine/AddLine)

	Method New()
	Method AddLine()
	Method SetValue(cCampo, xValor)
	Method GetValue(cCampo)
	Method GoLine(nLinha)
	Method Length()

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor. Inicializa o grid simulado vazio.

@type    Method
@author  Bruno Almeida
@since   02/09/2026
@version v12
@return  Self, Objeto, Instancia de LjMdlSL4
/*/
//-------------------------------------------------------------------------------------
Method New() Class LjMdlSL4

Self:aLinhas	:= {}
Self:nLinAtu	:= 0

Return Self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AddLine
Adiciona uma nova linha vazia ao final do grid simulado e posiciona nela.

@type    Method
@author  Bruno Almeida
@since   02/09/2026
@version v12
@return  nLinAtu, Numerico, Posicao da nova linha adicionada
/*/
//-------------------------------------------------------------------------------------
Method AddLine() Class LjMdlSL4

Aadd(Self:aLinhas, {})
Self:nLinAtu := Len(Self:aLinhas)

Return Self:nLinAtu

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetValue
Grava o valor de um campo na linha corrente do grid simulado.

@type    Method
@author  Bruno Almeida
@since   02/09/2026
@version v12
@param   cCampo, Caractere, Nome do campo (ex.: "L4_FORMA")
@param   xValor, Variante, Valor a ser gravado
/*/
//-------------------------------------------------------------------------------------
Method SetValue(cCampo, xValor) Class LjMdlSL4

Local nPos	:= 0
Local cChave	:= Upper(AllTrim(cCampo))

If Self:nLinAtu > 0 .And. Self:nLinAtu <= Len(Self:aLinhas)

	nPos := Ascan(Self:aLinhas[Self:nLinAtu], {|aItem| aItem[1] == cChave})

	If nPos > 0
		Self:aLinhas[Self:nLinAtu][nPos][2] := xValor
	Else
		Aadd(Self:aLinhas[Self:nLinAtu], {cChave, xValor})
	EndIf

EndIf

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetValue
Retorna o valor de um campo da linha corrente do grid simulado.

@type    Method
@author  Bruno Almeida
@since   02/09/2026
@version v12
@param   cCampo, Caractere, Nome do campo (ex.: "L4_FORMA")
@return  xValor, Variante, Valor do campo na linha corrente (Nil quando nao encontrado)
/*/
//-------------------------------------------------------------------------------------
Method GetValue(cCampo) Class LjMdlSL4

Local nPos		:= 0
Local xValor	:= Nil
Local cChave	:= Upper(AllTrim(cCampo))

If Self:nLinAtu > 0 .And. Self:nLinAtu <= Len(Self:aLinhas)

	nPos := Ascan(Self:aLinhas[Self:nLinAtu], {|aItem| aItem[1] == cChave})

	If nPos > 0
		xValor := Self:aLinhas[Self:nLinAtu][nPos][2]
	EndIf

EndIf

Return xValor

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GoLine
Posiciona o ponteiro de linha corrente do grid simulado.

@type    Method
@author  Bruno Almeida
@since   02/09/2026
@version v12
@param   nLinha, Numerico, Numero da linha a posicionar (1-based)
/*/
//-------------------------------------------------------------------------------------
Method GoLine(nLinha) Class LjMdlSL4

Self:nLinAtu := nLinha

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Length
Retorna a quantidade de linhas do grid simulado.

@type    Method
@author  Bruno Almeida
@since   02/09/2026
@version v12
@return  nTotal, Numerico, Quantidade de linhas
/*/
//-------------------------------------------------------------------------------------
Method Length() Class LjMdlSL4
Return Len(Self:aLinhas)
