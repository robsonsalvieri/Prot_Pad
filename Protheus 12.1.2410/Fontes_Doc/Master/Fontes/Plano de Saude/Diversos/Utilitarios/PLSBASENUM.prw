#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} plsStrBNum
Converte string para base numérica qualquer entre 2 E 36.

@author Karine Riquena Limp
@since 03/08/2017
@version P12
@param cStr String a ser convertida
@param nBase Base a ser utilizada, 16 por exemplo para usar hexadecimal
@param nTam Tamanho da string de retorno, por exemplo na tabela ASCII um caractere em hexadecimal sempre tem tamanho 2
/*/
//-------------------------------------------------------------------
function plsStrBNum(cStr, nBase, nTam)

local cRet := ""
local nI	:= 1

for nI := 1 to len(cStr)
	cRet += NtoC(Asc(substr(cStr, nI,1)),nBase,nTam)
next nI

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} plsBNumStr
Converte string que está em base numerica entre 2 e 36 para string normal.

@author Karine Riquena Limp
@since 03/08/2017
@version P12
@param cStr String a ser convertida
@param nBase Base a ser convertida, 16 por exemplo se a string estiver em hexadecimal por exemplo
@param nTam Tamanho da letra na base que a string está, por exemplo na tabela ASCII um caractere em hexadecimal sempre tem tamanho 2, em octal, tamanho 3 
ou seja, se a string estiver em hexa o nTam deve ser 2 pois cada letra é um código de tamanho 2 exemplo: "TESTE" = 5445535445, 
54 = "T" 
45 = "E"
53 = "S"
54 = "T"
45 = "E"
/*/
//-------------------------------------------------------------------
function plsBNumStr(cStr, nBase, nTam)

local cRet := ""
local cLetra := ""
local nI	:= 1

for nI := 1 to len(cStr) step nTam
	cLetra := upper(substr(cStr, nI,nTam))
	cLetra := cton(cLetra, nBase)
	cLetra := chr(cLetra)
	cRet += cLetra
next nI

return cRet