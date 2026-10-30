// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Ferramentas
// Fonte  : DWLib - Rotinas de uso genérico
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 28.05.01 | 0548-Alan Candido |
// 14.11.07 | 0548-Alan Candido | BOPS 135941 - Implementação da função DWDBOwner()
// 23.11.07 | 0548-Alan Candido | BOPS 136453 - Tratamento de aviso para sp_rename (MS-SQL)
// 30.01.08 | 0548-Alan Candido | BOPS 140233 - Compatilização de código para uso pelos TotvsParam
// 10.04.08 | 0548-Alan Candido | BOPS 142154
//          |                   | Ajuste no tratamento de parametros (via prompt) na função PrepVal()
// 12.05.08 | 0548-Alan Cândido | BOPS 145666
//          |                   | Ajuste no tratamento de erro, quando não há uma aplicação
//          |                   | web definida
// 30.06.08 | 0548-Alan Cândido | BOPS 146579
//          |                   | Implementação de configuração para habilitar ou não a
//          |                   | edição/apresentação do campo TAB_CONSULTAS.habPOnl, 
//          |                   | através da chave "PanelOffLine" (ini)
// 06.08.08 | 0548-Alan Cândido | BOPS 151591
//          |                   | Ajuste na função webBuildArquive() de carga do arquivo build.dw, 
//          |                   | utilizado na verificação da versão do site
// 12.08.08 |0548-Alan Cândido  | BOPS 146580 (habilitado pelo define DWCACHE)
//          |                   | Implementação de novo sistema de leitura da consulta (uso de cache).
// 18.11.08 | 0548-Alan Candido | FNC 00000006227/2008 (8.11) e 00000006076/2008 (P10)
//          |                   | Implementação de parâmetros na função removeSpecialCharacteres(),
//          |                   | para tratar caracteres na faixa ASCII 0 a 31.
// 25.11.08 | 0548-Alan Candido | FNC 00000007374/2008 (10) e 00000007385/2008 (8.11)
//          |                   | Modificado procedimentos de validação de versão da aplicação 
//          |                   | e do site, através:
//          |                   | . Melhoria nas funções dwBuild(), isWebSiteUpdated(), 
//          |                   |   isBuildWebValid, DwGenWebBuild, dwGetStatus
//          |                   | .Implementação da função dwLastWebBuild()
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | . Implementação das funções: dwRegLang() e dwMask()
//          |                   | . Eliminação de rotina obsoleta: dwMakePicture()     
// 19.02.10 | 0548-Alan Candido | FNC 00000003657/2010 (9.12) e 00000001971/2010 (11)
//          |                   | Implementação de visual para P11 e adequação para o 'dashboard'
// --------------------------------------------------------------------------------------
     
#include "colors.ch"
#include "dwincs.ch"
#include "tbiconn.ch"
#include "DWLib.ch" 
#include "Shell.ch"  
#include "dwver.ch"

///### Verificar o SigaDW_
#define INI_SESSION_OF_SIGADW trataWebJobName() 

/*
--------------------------------------------------------------------------------------
Converte qualquer tipo de argumento para uma string
Arg: axValue -> qualquer tipo, valor a ser convertido em string
     alMacro -> logico, indica que o resultado será usado em macro
Ret: cRet -> string, axValue convertido em string 
--------------------------------------------------------------------------------------
*/                                 
function DWStr(axValue, alMacro)
	local cRet := ""
	local nInd
	local cValType := valType(axValue)

	default alMacro := .f.
	
	do case
		case cValType == "C" .or. cValType == "M"
			cRet := axValue
			if alMacro 
				if .not. (left(cRet, 1) $ "{'" +'"' .and. right(cRet, 1) $ "}'" +'"')
					if left(cRet, 4) != 'ctod'
						cRet := strTran(cRet, "'", "'+chr(39)+'")
						cRet := strTran(cRet, chr(13), "'+chr(13)+'")
						cRet := strTran(cRet, chr(10), "'+chr(10)+'")
						cRet := "'" + strTran(cRet, '"', "'+chr(34)+'") + "'"
					endif                                        
				endif
			endif
		case cValType == "N"
			cRet := allTrim(str(axValue))
		case cValType == "D"
			if alMacro 
				cRet := "ctod(" + chr(34) + dtoc(axValue) + chr(34) + ")"
			else
				cRet := dtoc(axValue)
			endif
		case cValType == "L"
			cRet := if(axValue, ".T.", ".F." )
		case cValType == "A"
			if alMacro 
				cRet := "{"
				for nInd := 1 to len(axValue)
					cRet := cRet + DWStr(axValue[nInd], alMacro) + iif(nInd = len(axValue), "", ",")
				next
				cRet := cRet + "}"
			else
				for nInd := 1 to len(axValue)
					cRet := cRet + DWStr(axValue[nInd], alMacro) + CRLF
				next
			endif
		case cValType == "B"
			cRet := DWStr(eval(axValue), alMacro)
		case cValType == "O"
			cRet := axValue:asString(alMacro)
		otherwise     
			if alMacro
				cRet := "NIL"
			else
				cRet := ""
			endif
	end
	
return cRet

function DWCallStack(x, y, alShow)
	local cRet := ""
	
	default x := 1
	default y := 99
	default alShow := .t.
	
	while !empty(procname(x+1)) .and. x <= y
		cRet += procname(x+1) + ":" + strzero(procline(x+1), 5) + " | "
		x++
	enddo
	   
	cRet := left(cRet, len(cRet) - 2)
	if alShow
		conout(cRet)
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Extrai o nome da macro
Arg: acLine -> string, linha a ser analizada e formatada
     aaVarList -> array, lista com os valores das variavéis
Ret: lRet -> boolean, macro localizada
--------------------------------------------------------------------------------------
*/                                 
#define DELIMITERS ' "<>:.)(&,]'

function HTMLFormat(acLine, aaVarList)
	local cRet := acLine + " ", cMask
	local nPos, nPosFin, nVar := 0
	
	if !empty(aaVarList)        
		cRet := strtran(cRet, "##", "&_35")
		while .T.
			nPos := at("#", cRet)
			if nPos == 0 .or. nVar == len(aaVarList)
				exit
			endif
			
			nPosFin := nPos + 1
			while (nPosFin < len(cRet)) .and. !(substr(cRet, nPosFin, 1) $ DELIMITERS)
				nPosFin++
			end                              
			nVar++  
			
			cMask := substr(cRet, nPos, nPosFin - nPos)
			if cMask == "#"
				cRet := substr(cRet, 1, nPos - 1) + ;
						DWStr(aaVarList[nVar]) + ;	
					  	substr(cRet, nPosFin)
			else
				cRet := substr(cRet, 1, nPos - 1) + ;
						transform(substr(cMask,2, len(cMask)-2), aaVarList[nVar]) + ;	
					  	substr(cRet, nPosFin + 1)
			endif
		enddo
//	   cRet := strtran(cRet, "&_35", "#")
	endif
return cRet

function DWConcatWSep(acSep, ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9, axA, alMacro)
	local cRet := '', nInd

	default alMacro := .f.

	if valType(ax1) == "A" .and. valType(ax2) == "U" 
		//## quando chamada do editor de expressõs HEDTEXP:Buffer()
		//aeval(ax1, { |x| iif(valType(x) != "U", cRet += acSep + DWStr(x, alMacro),nil) })
		for nInd := 1 to len(ax1)
			if valType(ax1[nInd]) != "U"
				cRet += acSep + DWStr(ax1[nInd], alMacro)
			endif
		next
		cRet := substr(cRet, len(acSep)+1)
	else
		cRet += iif(valType(ax1)=="U", "", DWStr(ax1, alMacro))
		cRet += iif(valType(ax2)=="U", "", acSep + DWStr(ax2, alMacro))
		cRet += iif(valType(ax3)=="U", "", acSep + DWStr(ax3, alMacro))
		cRet += iif(valType(ax4)=="U", "", acSep + DWStr(ax4, alMacro))
		cRet += iif(valType(ax5)=="U", "", acSep + DWStr(ax5, alMacro))
		cRet += iif(valType(ax6)=="U", "", acSep + DWStr(ax6, alMacro))
		cRet += iif(valType(ax7)=="U", "", acSep + DWStr(ax7, alMacro))
		cRet += iif(valType(ax8)=="U", "", acSep + DWStr(ax8, alMacro))
		cRet += iif(valType(ax9)=="U", "", acSep + DWStr(ax9, alMacro))
		cRet += iif(valType(axA)=="U", "", acSep + DWStr(axA, alMacro))
		cRet := rTrim(cRet)
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
"Tokeniza" uma linha 
Args: acLinha -> string, linha a ser "tokenizado"
		acSeparador -> string, caracter separador do token		
		alValReal -> logico, indica se os valores "tokenizados" devem ser reais
Ret: aRet -> array, lista tokenizada
--------------------------------------------------------------------------------------
*/                      
function DWToken(acLinha, acSeparador, alValReal, alDelSep)
	local aRet := { }
	local lAspas 	:= .f.
	local nInd		:= 0
	local cChar     := ""
	local cValue 	:= ""
	local cLinha 	:= ""
	local cAspas    := ""
		
	default acSeparador := ","
	default alValReal := .t.
	default alDelSep := .t.
	default acLinha 	:= ""

	cLinha := cBIStr(acLinha)

	for nInd := 1 to len(cLinha)
		cChar := substr(cLinha, nInd, 1)
		if cChar == acSeparador .and. !lAspas
			cValue := strTran(cValue, "\x22", '"')
			cValue := strTran(cValue, "\x27", "'")
			cValue := strTran(cValue, chr(13), "\n")
			cValue := strTran(cValue, chr(10), "")
			aAdd(aRet, cValue)
			cValue := ""
		else              
			if lAspas .and. cChar == cAspas
				lAspas := .f.
			elseif cChar == '"' .or. cChar == "'"
				lAspas := .T.                     
				cAspas := cChar
			endif
			cValue += cChar
		endif 		
	next

	if !empty(cValue)	
		aAdd(aRet, cValue)
	elseif right(cLinha, 1) == acSeparador
		aAdd(aRet, cValue)
	endif

	if !alDelSep
		aEval(aRet, { |x,i| aRet[i] := acSeparador + x }, 2)
	endif
	        
	if alValReal
		for nInd := 1 to len(aRet)
			if aRet[nInd] == '.'
			elseif left(aRet[nInd],1) == '"'
				aRet[nInd] := substr(aRet[nInd], 2, len(aRet[nInd])-2)
			elseif left(aRet[nInd],1) == '[' .and. len(aRet[nInd]) > 8
				aRet[nInd] := stod(substr(aRet[nInd], 2, len(aRet[nInd])-2))
			elseif left(aRet[nInd],1) == '.'
				aRet[nInd] := upper(aRet[nInd]) == '.T.' .or. upper(aRet[nInd]) == '.Y.'
			elseif DWIsDigit(aRet[nInd])
				aRet[nInd] := val(aRet[nInd])
			endif                                    
		next
	endif
	
return aRet

function execSintax(acExpressao, acMsg, alAviso)
return execWWarn(acExpressao, @acMsg, alAviso)

function execWWarn(acExpressao, acMsg, alAviso)
	private lOk := .t., oE, cExp := acExpressao

   default alAviso := .t.

	acMsg := ""            
	__DWErroCtrl := .t.
	begin sequence
		acMsg := __execstr(strTran(acExpressao, "&", ""))
	end sequence
	__DWErroCtrl := .f.

return lOk

function xmlNodeExist(oNode, cNode)
return XmlChildEx( oNode, upper(cNode) ) <> NIL 

/*
--------------------------------------------------------------------------------------
Verifica se uma string contem somente numero e "-"
Args: acText -> string, texto a ser verificado
Ret: lRet -> logico, somente digitos
--------------------------------------------------------------------------------------
*/                      
function DWIsDigit(acText)
	local lRet := .t.
   	local nInd, cAux

	acText := alltrim(acText)
	if !empty(acText)              
		if at("-", acText) > 1
			lRet := .f.
		else
			for nInd := 1 to len(acText)
				cAux := substr(acText, nInd, 1)
				if !isDigit(cAux) .and. (cAux <> "-") .and. (cAux <> ".")
					lRet := .f.
					exit
				endif
			next
		endif
	else
		lRet := .f.
	endif
	
return lRet
