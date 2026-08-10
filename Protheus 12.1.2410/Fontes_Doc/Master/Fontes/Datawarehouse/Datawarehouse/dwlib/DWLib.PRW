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
Libera objetos
Args: aoObj -> objecto, objeto a ser liberado
Ret: 
--------------------------------------------------------------------------------------
*/                      
function DWFreeObj(aoObj)
	
	if valtype(aoObj) == "O"
		aoObj:Free()
		FreeObj(aoObj)
	endif
	
return

/*
--------------------------------------------------------------------------------------
Monta a mensagem de erro conforme os código passados
Arg: anCodErro -> numérico, código de erro 
     anCodSol -> numérico, código de solução
     acComp -> string, texto complementar
     alHtml -> lógico, indica se é formato HTML ou não
     
Ret: cRet -> string, mensagem montada
--------------------------------------------------------------------------------------
*/                                 
function dwRaise(anCodErro, anCodSol, acComp, alHtml)

	appRaise(anCodErro, anCodSol, acComp, alHtml)

return

function appRaise(anCodErro, anCodSol, acComp, alHtml)
	default acComp := "" notdef space(01) + dwStr(acComp)
	default alHtml := .t.

	ExUserException(iif(alHtml, "T","F") + DWint2hex(anCodErro, 2) + DWint2hex(anCodSol, 2) + acComp)
		
return 

/*
--------------------------------------------------------------------------------------
Converte da base decimal para base hexadecimal
Arg: anValue -> numerico, valor a ser convertido
Ret: cRet -> string, valor em hexa
--------------------------------------------------------------------------------------
*/                                 
function DWint2hex(AValue, ASize)
	local nValue := int(AValue), nResto := '', cResto := ''

	while nValue > 0 
		nResto := nValue % 16
		do case
			case nResto == 10
				cResto := 'A' + cResto
			case nResto == 11
				cResto := 'B' + cResto
			case nResto == 12
				cResto := 'C' + cResto
			case nResto == 13
				cResto := 'D' + cResto
			case nResto == 14
				cResto := 'E' + cResto
			case nResto == 15
				cResto := 'F' + cResto
			otherwise
				cResto := str(nResto, 1) + cResto
		endcase           
		nValue := int(nValue / 16)
	end            

return (padl(cResto, ASize, "0"))
                                 
/*
--------------------------------------------------------------------------------------
Converte da base hexadecimal para base decimal
Arg: acValue -> string, valor a ser convertido
Ret: nRet -> numerico, valor em decimal
--------------------------------------------------------------------------------------
*/                                 
function DWhex2Int(AValue)               
	local nInd, nPotencia := 0, nVal, nRet := 0, cDig

	for nInd := len(AValue) to 1 step -1
		cDig := substr(AValue, nInd, 1)
		do case
			case cDig == "A"
				nVal := 10 
			case cDig == "B"
				nVal := 11 
			case cDig == "C"
				nVal := 12 
			case cDig == "D"
				nVal := 13 
			case cDig == "E"
				nVal := 14 
			case cDig == "F"
				nVal := 15 
			otherwise
				nVal := val(cDig)
		endcase           
		nRet += nVal * (16 ** nPotencia) 
		nPotencia++
	end            

return (nRet)

/*
--------------------------------------------------------------------------------------
Rotina de tratamento de erros
Arg: oE -> objeto, descrição do erro gerado 
     alRPC -> logico, indica que o erro ocorreu dentro de uma rotina RPC
Ret: 
--------------------------------------------------------------------------------------
*/
static __lastError
                                 
function __webError(oE)
	local lAviso := .f., cTipoErro := "Error ", cMsg := ""
	local nPilha := 2
	local oWebApp := getWebApp()
	local lAviso2 := .f.

  	__lastError	:= oE
  
  	if valType(oWebApp) == "O"
	  	oWebApp:clearError()
  		oWebApp:error(oE)
	endif
		
	if oE:gencode > 0
		if oE:gencode == 34 // Data width error
			lAviso := .t.
			cTipoErro := "Warning "
			cMsg := str(oE:gencode,4,0) + " - " + oE:Description
		elseif oE:gencode == 60 // Erro levantado pelo aplicativo
			lAviso := .t.
			lAviso2:= .t.
		  	if valType(oWebApp) == "O"
				cMsg := oWebApp:mountError(@lAviso2, .f.)
			else
				cMsg := str(oE:gencode,4,0) + " - " + oE:Description
			endif
			
			if left(cMsg, 1) == "#" //erro fatal
				cMsg := substr(cMsg, 2)
				oE:subCode := 0
			else
				oE:subCode := 100
			endif
			oE:Description := cMsg
		else
			cMsg := str(oE:gencode,4,0) + " - " + oE:Description
		endif
		
		if !lAviso
			CloseDB(.t.)
		endif
		
		if !lAviso2 .or. DWIsDebug()
			conout(">> " + cTipoErro + " " + replicate("*",50), cMsg, "Called from ")
			while ProcName( nPilha ) <> ""
				conout("    " + ProcName(nPilha) + " line " + strZero(procLine(nPilha), 5))
				nPilha++
			end
			conout(replicate("*",61))
		endif
	  
	  	if (oE:genCode <> 33 .and. oE:gencode <> 60) .or. ;
	     	valType(oWebApp) == "U" .or. !(oWebApp:className() == "TTOTVSMAIN")
				break
		endif
	else
		oE:Description := cMsg
	endif

return

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

/*
--------------------------------------------------------------------------------------
Converte qualquer tipo de argumento para uma string, sendo que se o dado
for numérico, acrescenta 0 (zeros) a esquerda
Arg: axValue -> qualquer tipo, valor a ser convertido em string
Ret: cRet -> string, axValue convertido em string 
--------------------------------------------------------------------------------------
*/                                 
function DWStrZero(axValue, anTam, anDec)
	local cRet

	if valType(axValue) == "N"
		cRet := strZero(axValue, anTam, anDec)
	else
		cRet := dwStr(axValue)
	endif		 
			
return cRet

/*
--------------------------------------------------------------------------------------
Converte uma string em um objeto
Arg: acValue -> string, valor a ser convertido em objeto
Ret: oRet -> objeto, objeto gerado a partir da string
--------------------------------------------------------------------------------------
*/                                 
function DWStr2Obj(acValue, aoOwner)
	local aAux := &(acValue), aPropList, aProp
	local cAux, nInd, nPos
	
	private _oRet := nil, _oAux

	if aAux[1, 2] == "_" .and. aAux[2, 2] == "_" .and. ;
		aAux[1, 1] == "CLASSNAME" .and. aAux[2, 1] == "OWNER"	
			cAux := aAux[1,3] + "():New(" + iif(aAux[2,3], "aoOwner","") + ")"
			_oRet := &(cAux)
			aPropList := classDataArr(_oRet)
			for nInd := 2 to len(aPropList)
				aProp := aPropList[nInd]     
				if !(aProp[1] == "OWNER")
					nPos := ascan(aAux, { |x| x[1]==aProp[1]})
					if nPos <> 0                      
						if aAux[nPos, 2] == "O"
							_oAux := dwStr2Obj(aAux[nPos, 3], oRet)
							cAux := "_oRet:"+aAux[nPos, 1] + " := _oAux"
						else
							cAux := "_oRet:"+aAux[nPos, 1] + " := " + dwStr(aAux[nPos, 3],.t.)
						endif
						&(cAux)
					endif
				endif
			next
	endif

return _oRet

/*
--------------------------------------------------------------------------------------
Converte qualquer tipo de argumento para um valor numérico
Arg: axValue -> qualquer tipo, valor a ser convertido em string
Ret: nRet -> numerico, axValue convertido em um numérico
--------------------------------------------------------------------------------------
*/                                 
function DWVal(axValue)
	local nRet := NIL

	if valType(axValue) == "U"
		nRet := 0
	elseif valType(axValue) == "D"
		nRet := val(dtos(axValue))
	elseif valType(axValue) == "L"
		nRet := iif(axValue, 1, 0)
	elseif valType(axValue) == "C"
		nRet := val(strTran(axValue, ",", "."))   
	elseif valType(axValue) == "N"
		nRet := axValue
	endif
	
return nRet

/*
--------------------------------------------------------------------------------------
Monta string de Build
Args: 
Ret: cRet -> string, identificação de build (produto - versão.release build xxxxx)
--------------------------------------------------------------------------------------
*/                                 
function DWBuild(alNoSpaces)
	local cRet := "SigaDW " + VERSION + "." + RELEASE + "." + BUILD
	
	default alNoSpaces := .f.
	
	cRet += " " + FASE
	
return iif(alNoSpaces, strTran(cRet, " ", "_"), cRet)

function DWBuildSite(alNoSpaces)
	local cRet := "Site " + DWLastWebBuild()
	
	default alNoSpaces := .f.
		
return iif(alNoSpaces, strTran(cRet, " ", "_"), cRet)

function DWLastBuild()
return DWMakeBuild(VERSION, RELEASE, BUILD)

/**
*/
function DWLastWebBuild()
return BUILD_WEB
  
/**
*/
function DWMakeBuild(anVersion, anRelease, anBuild)
return dwStr(anVersion) + "." + strZero(dwVal(anRelease),2) + "." + strZero(dwVal(anBuild),6)

/**
*/
function trataWebJobName()
	Local cJobName 	:= getWebJob()
	                
    If ( Empty(cJobName) )     
     	cJobName := alltrim(GetPvProfString("GENERAL", "DWWEBJOB", "", DWIniFile()))  
     	             
        If ( Empty(cJobName) )
			Conout(STR0212)  //"Chave DWWEBJOB não encontrada na sessão GENERAL no arquivo de configuração."
        EndIf
    EndIf                     
    
  	While ( Right( cJobName,1 ) == "_" )
		cJobName := Substr( cJobName, 1, rat( "_", cJobName ) -1 )
	EndDo
return cJobName

#define DESLOCAMENTO 3    // usado na geração da chave de acesso
static __StatInfo := {}

function dwStatOn(cTitle)
#ifdef ESTATISTICAS
	local aStatInfo, cMsg, cMsg2
	
	aAdd(__StatInfo, { cTitle, seconds(), 0, time() })
	aStatInfo := atail(__StatInfo)
	cMsg := padl(" (" + dwStr(len(__StatInfo))+ ")", 78, ".")
	cMsg2 := ">>> " + aStatInfo[4] + "-" + time() + " >" + space(len(__StatInfo)) + aStatInfo[1]
	conout(cMsg2 + substr(cMsg, len(cMsg2)))
#endif	
return 

function dwStatOff()
#ifdef ESTATISTICAS                                                     
	local cMsg := "", cMsg2 := ""
	local aStatInfo := atail(__StatInfo)

	aStatInfo[2] := seconds() - aStatInfo[2]
	aSize(__StatInfo, len(__StatInfo)-1)
	
	cMsg := padl(DWSecs2Str(aStatInfo[2]) + "(" + dwStr(len(__StatInfo)+1)+ ")", 78, ".")
	cMsg2 := ">>> " + aStatInfo[4] + "-" + time() + " >" + space(len(__StatInfo)+1) + aStatInfo[1]
	conout(cMsg2 + substr(cMsg, len(cMsg2)))
#endif
return 

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
Gera um ID único 
Arg: 
Ret: cRet -> ID gerado
--------------------------------------------------------------------------------------
*/                                 
function DWGeraID()   
	local cRet := DWint2hex(year(msdate()) - 1900, 2) + ;
			DWint2hex(month(msdate()), 1) + ;
			DWint2hex(day(msdate()), 1) + ;
			DWint2hex(seconds(), 4)
return cRet


/*
--------------------------------------------------------------------------------------
Gera um nome único a partir de um prefixo
Arg: acPrefixo -> string, prefixo a ser utilizado
Ret: cRet -> ID gerado
--------------------------------------------------------------------------------------
*/                                 
function DWMakeName(acPrefixo)
	local cRet := alltrim(acPrefixo), nRet
	local nCont := 50
	
	acPrefixo := "__" + cRet + "__"
	while !GlbLock() .and. !DWKillApp() //GlbLock(acPrefixo)
		sleep(100)                           
		nCont--
		if nCont == 0
			nCont := 50
		endif
	enddo
	nRet := val(GetGlbValue(acPrefixo)) + 1
	PutGlbValue(acPrefixo, DWStr(nRet))
	cRet += DWInt2Hex(nRet, 5)

	GlbUnlock()  //GlbUnlock(acPrefixo)	   

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

/*
--------------------------------------------------------------------------------------
Ajusta o EOL de expressão JScript
Arg: acJSExpress -> string, linha JScript a ser analizada
Ret: cRet -> string, EOL
--------------------------------------------------------------------------------------
*/                                 
function JSEol(acJSExpress)
	local cRet := alltrim(acJSExpress)
	
	if right(cRet, 2) == ";/"
		cRet := substr(cRet, 1, len(cRet) - 1)
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Concatena uma lista de argumentos
Arg: axP? -> qualquer tipo, valor a ser concatenado (máximo 10)
Ret: cRet -> string, axValue convertido em string 
--------------------------------------------------------------------------------------
*/                                 
function DWConcat(ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9, axA)
	local cRet := ;
			DWStr(ax1) + DWStr(ax2) + DWStr(ax3) + DWStr(ax4) + DWStr(ax5) + ;
			DWStr(ax6) + DWStr(ax7) + DWStr(ax8) + DWStr(ax9) + DWStr(axA) 
	
return cRet

/*
--------------------------------------------------------------------------------------
DWConcatena uma lista de argumentos usando um separador
Arg: acSep -> string, valor do separador 
     axP? -> qualquer tipo, valor a ser DWConcatenado (máximo 10)
Ret: cRet -> string, axValue convertido em string 
--------------------------------------------------------------------------------------
*/                                 
function DWConcatMacro(acSep, ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9, axA)
return DWConcatWSep(acSep, ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9, axA, .t.)


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


function __DWRPCError(oE, pcMsgErro)
	local lAviso := .f., lAviso2 := .f.
	local cTipoErro := "Error ", cMsg := "", cAux
	local nPilha := 2, lRet := .f.
	
	if oE:gencode > 0      
		if oE:gencode == 14 // Propriedade inválida
			lAviso := .t.
			cTipoErro := "Warning "
			cMsg := str(oE:gencode,4,0) + " - " + oE:Description 
		elseif oE:gencode == 34 // Data width error
			lAviso := .t.
			cTipoErro := "Warning "
			cMsg := str(oE:gencode,4,0) + " - " + oE:Description 
		elseif oE:gencode == 60 // Erro levantado pelo SigaDW
			cMsg := DWMntErr(@lAviso2, substr(oE:Description,2), iif(left(oE:Description,1)=="T", .t., .f.))
		else
			cMsg := str(oE:gencode,4,0) + " - " + oE:Description 
		endif
		conout(">> " + cTipoErro + " " + replicate("*",50), cMsg, "Called from ")
                                  
		if !lAviso2
			while ProcName( nPilha ) <> ""
				conout("    " + ProcName(nPilha) + " line " + strZero(procLine(nPilha), 5))
				nPilha++
			end
			conout(replicate("*",61))
			nPilha := 2
		
			cMsg += CRLF + cMsg
			cAux := ""
			while procname(nPilha) <> ""
				cAux += "Proc: " + procname(nPilha) + " line: " + DWStr(procline(nPilha)) + "<br>"+CRLF
				nPilha++
			enddo
		endif
		cMsg += CRLF + cAux
		oE:Description := cMsg
		pcMsgErro := cMsg
		lRet := .t.
	else
		oE:Description := str(oE:gencode,4,0) + " - " + oE:Description 
		pcMsgErro := cMsg
//		break oE
		break 
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Grava um log de atividade
Arg: acMsg -> string, mensagem a ser logada 
Ret: 
--------------------------------------------------------------------------------------
*/                                 
function DWLog(acMsg, acP1, acP2, acP3, acP4, acP6, acP7, acP8, acP9, acP10)
	local cRemoteAdd := "["+isNull(HttpHeadIn->Remote_Addr, "")+"] "
		
	acMsg := DWConcatWSep(CRLF+" .", { dtoc(date()) + " " + time() + "($"+dwInt2Hex(ThreadID(),4)+") "+cRemoteAdd +padr(procname(1),15) + " " + strZero(procline(1), 5), ;
			acMsg, acP1, acP2, acP3, acP4, acP6, acP7, acP8, acP9, acP10 } ) + CRLF

	conout(acMsg)
	
return

function DWLogArray(acMsg, aaP1)
	acMsg := DWConcatWSep(CRLF+" .", { "($"+dwInt2Hex(ThreadID(),4)+") " + padr(procname(1),15) + " " + strZero(procline(1),4) + " " + time(), acMsg } ) + CRLF
	acMsg += DWConcatWSep(CRLF+"  ", aaP1)
	conout(acMsg)
return

/*
--------------------------------------------------------------------------------------
Verifica se foi emitido um KillApp()
Args: 
Ret: lRet -> lógigo, KillApp() emitido
--------------------------------------------------------------------------------------
*/                                 
function DWKillApp()
	
	if KillApp()
		DWLOG(STR0007)/*//"Recebido KILLAPP"*/
		return .t.
	endif

return .f.

/*
--------------------------------------------------------------------------------------
Converte qualquer tipo de argumento para um tipo especifico
Arg: acType -> string, tipo de saída desejada (CNDL)
     axValue -> qualquer tipo, valor a ser convertido 
Ret: xRet -> valor convertido
--------------------------------------------------------------------------------------
*/                                 
function DWConvTo(acType, axValue)
	local xRet := axValue

	if valType(xRet) != acType
		xRet := DWStr(axValue)	
		if acType == "N"
			xRet := val(xRet)
		elseif acType == "D"
			xRet := iif("/" $ xRet, ctod(xRet), stod(xRet))
		elseif acType == "L"
			xRet := upper(xRet) $ ".T.|T|TRUE|Y|YES|ON|1"
		endif
	endif
	
return xRet		

/*
--------------------------------------------------------------------------------------
Codifica strings para o formato URLEncode
Arg: acValue -> string, valor a ser codificado
Ret: cRet -> string, valor codificado
--------------------------------------------------------------------------------------
*/                      
function URLEncode(acValue, alApplet)
	local cRet := acValue

	default alApplet := .f.	
	
	if !alApplet .and. valType(cRet) == "C"
		cRet := strtran(cRet, "%", "%25")
		cRet := strtran(cRet, "+", "%2B")
		cRet := strtran(cRet, "/", "%2F")
		cRet := strtran(cRet, "=", "%3D")	
		cRet := strtran(cRet, "&", "%26")
		cRet := strtran(cRet, "'", "%27")
		cRet := strtran(cRet, '"', "%22")
		cRet := strtran(cRet, ':', "%3A")
		cRet := strtran(cRet, '#', "%23")
	endif
		
return cRet

/*
--------------------------------------------------------------------------------------
Decodifica strings do formato URLEncode para string "normal"
Arg: acValue -> string, valor a ser decodificado
Ret: cRet -> string, valor decodificado
--------------------------------------------------------------------------------------
*/                      
function URLDecode(acValue)
	local cAux := acValue, cRet := "", nInd, cCode, cLetra

	if left(cAux,1) == "'" .or. left(cAux,1) == '"'
		cAux := substr(cAux, 2, len(cAux)-2)
	endif	

	for nInd := 1 to len(cAux)
		cLetra := substr(cAux, nInd, 1)
		if cLetra == "%"
			cCode := substr(cAux, nInd+1, 2)
			cRet += chr(hex2Int(cCode))
			nInd += 2
		else
			cRet += cLetra
		endif
	next

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

function DWTokenAdv(acLinha, acSeparador, aaIgnoreList) //aspas são ignoradas automaticamente
	local nOpen := 0, nInd, nInd2, cOpen, cClose, cLinha 
	local cCaracter, cLinhaOri := acLinha, aRet
		
	for nInd2 := 1 to len(aaIgnoreList)
		cOpen := left(aaIgnoreList[nInd2], 1)
		cClose := right(aaIgnoreList[nInd2], 1)
		cLinha := ""
		for nInd := 1 to len(cLinhaOri)
			cCaracter := substr(acLinha, nInd, 1)
			if cCaracter == cOpen
				nOpen++
			elseif cCaracter == cClose
				nOpen--
			endif           
			
			if cCaracter == acSeparador .and. nOpen <> 0 
				cLinha += chr(254)
			else
				cLinha += cCaracter
			endif
		next
		cLinhaOri := cLinha
	next
	   
	aRet := DWToken(cLinhaOri, acSeparador)
	aEval(aRet, { |x,i| aRet[i] := strTran(dwStr(x), chr(254), acSeparador)})
	
return aRet

/*
--------------------------------------------------------------------------------------
Gera o nome de tabelas
Args: acCateg -> string, categoria de tabela
		acComp -> string, complemento do nome   
		alUnique -> logico, indica que o nome gerado deverá ser unico
Ret: cRet -> string, nome da tabela
--------------------------------------------------------------------------------------
*/           
function DWTablename(acCateg, acComp, alUnique)
	local cRet := "D" + acCateg + "0"
		
	default alUnique := .f.

	cRet += acComp
	
return cRet

function DWCubename(anCubeID)
return DWTablename("C", DWint2hex(anCubeID, 4))

function DWDimName(anDimID)
return DWTablename("D", DWint2hex(anDimID, 4))

function DWCalName(anDimID)
return DWTablename("Z", DWint2hex(anDimID, 4))

function DWSumname(anConsID, acEixo)
return DWTablename(acEixo, DWint2hex(anConsID, 4))

function DWKeyDimname(anDimID)
return "ID_DIM" + DWint2hex(anDimID, 3)

function DWAttDimName(anAttID)
return "D" + DWint2hex(anAttID, 5)

function DWAttCubName(anAttID)
return "I" + DWint2hex(anAttID, 5)

/*
--------------------------------------------------------------------------------------
Verifique se há elementos duplicados e elimina-os
Args: aaList -> array, array a ser testada
      alKill -> boolean, elimina duplicidades
Ret: lRet -> boolean, indica se há ou não duplicidade
--------------------------------------------------------------------------------------
*/                      
function DplItems(aaList, alKill, alMark, alKillSecond)
	local lRet := .f., nInd, nInd2, aAux

	default alKill := .f.               
	default alMark := .f.
	default alKillSecond := .f.
	
	for nInd := 1 to len(aaList)
		for nInd2 := len(aaList) to 1 step -1
			if nInd <> nInd2 .and. valType(aaList[nInd2]) <> "U"
				if aaList[nInd] == aaList[nInd2] .OR. ;
					(valType(aaList[nInd]) == "O" .and. valType(aaList[nInd2]) == "O" .and. ;
					aaList[nInd]:asString() == aaList[nInd2]:asString())
						lRet := .t.
						if alKill .or. alMark
							if !alKillSecond
								aaList[nInd] := NIL
							else
								aaList[nInd2] := NIL
							endif
						endif
				endif
			endif
		next
	next

	if alKill
		aAux := PackArray(aaList)
		aSize(aaList, len(aAux))
		aEval(aAux, { |x,i| aaList[i] := x})
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Verifica se há elementos duplicados em um array de array e elimina-os
Args: aaList -> array, array a ser testada
      alKill -> boolean, elimina duplicidades
      alMark -> boolean, elimina duplicidades (igual ao alKill) porém não reajusta o tamanho do array
      anIndexComp -> numérico, contém o index utilizado para a comparação
      alKillSecond -> booleano, define para eliminar(kill) ou marcar(mark) o secondo elemento
Ret: lRet -> boolean, indica se há ou não duplicidade
--------------------------------------------------------------------------------------
*/                      
function DplArray(aaList, alKill, alMark, anIndexComp, alKillSecond)
	local lRet := .f., nInd, nInd2, aAux
	
	default alKill := .f.               
	default alMark := .f.
	default anIndexComp := 1
	default alKillSecond := .T.
	
	for nInd := 1 to len(aaList)
		for nInd2 := len(aaList) to 1 step -1
			if nInd <> nInd2 .and. valType(aaList[nInd]) <> "U" .and. valType(aaList[nInd2]) <> "U"
				if aaList[nInd][anIndexComp] == aaList[nInd2][anIndexComp] .OR. ;
					(valType(aaList[nInd][anIndexComp]) == "O" .and. valType(aaList[nInd2][anIndexComp]) == "O" .and. ;
					aaList[nInd][anIndexComp]:asString() == aaList[nInd2][anIndexComp]:asString())
						lRet := .t.
						if alKill .or. alMark
							if !alKillSecond
								aaList[nInd] := NIL
							else
								aaList[nInd2] := NIL
							endif
						endif
				endif
			endif
		next
	next
	
	if alKill
		aAux := PackArray(aaList)
		aSize(aaList, len(aAux))
		aEval(aAux, { |x,i| aaList[i] := x})
	endif
	
return lRet


/*
--------------------------------------------------------------------------------------
Verifica se há elementos duplicados em um array de array e elimina-os. Para isso, faz a comparação
	absoluta dos valores do subarray com o auxílio da função DwStr().
Args: aaList -> array, array a ser testada
      alKill -> boolean, elimina duplicidades
      alMark -> boolean, elimina duplicidades (igual ao alKill) porém não reajusta o tamanho do array
      alKillSecond -> booleano, define para eliminar(kill) ou marcar(mark) o secondo elemento
Ret: lRet -> boolean, indica se há ou não duplicidade
--------------------------------------------------------------------------------------
*/                      
function DplArrayAbs(aaList, alKill, alMark, alKillSecond)
	local lRet := .f., nInd, nInd2, aAux
	
	default alKill := .f.               
	default alMark := .f.
	default alKillSecond := .T.
	
	for nInd := 1 to len(aaList)
		for nInd2 := len(aaList) to 1 step -1
			if nInd <> nInd2 .and. valType(aaList[nInd]) <> "U" .and. valType(aaList[nInd2]) <> "U" ;
				.and. DwStr(aaList[nInd], .T.) == DwStr(aaList[nInd2], .T.)
					lRet := .t.
					if alKill .or. alMark
						if !alKillSecond
							aaList[nInd] := NIL
						else
							aaList[nInd2] := NIL
						endif
					endif
			endif
		next
	next
	
	if alKill
		aAux := PackArray(aaList)
		aSize(aaList, len(aAux))
		aEval(aAux, { |x,i| aaList[i] := x})
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Elimina elementos NIL de um array
Args: aaList -> array, array a ser compactada
Ret: aRet -> array, array compactado
--------------------------------------------------------------------------------------
*/                      
function PackArray(aaList)
	local aRet := {}, nInd
	
	for nInd := 1 to len(aaList)	
		if !empty(aaList[nInd]) .or. valType(aaList[nInd]) == "O"
			aAdd(aRet, aaList[nInd])
		endif
	next

return aRet

/*
--------------------------------------------------------------------------------------
Elimina elementos de um array e ajusta o tamanho
Args: aaList -> array, array 
		anElement -> integer, elemento a eliminar
Ret: 
--------------------------------------------------------------------------------------
*/                      
function DWADel(aaList, anElement)
	
	aDel(aaList, anElement)
	aSize(aaList, len(aaList)-1)

return 

/*
--------------------------------------------------------------------------------------
Converte valores em valores formatados para o JavaScript
Arg: axValue -> expressao, expressao a ser formatada
Ret: cRet -> string, texto formatado para JavaScrit
--------------------------------------------------------------------------------------
*/                                 
function JSEncode(axValue)
return DWEncode(DWStr(axValue), .t.)

/*
--------------------------------------------------------------------------------------
Gera código HTML "printável"
Arg: acValue -> string, texto HTML a imprimir
     alApplet -> logico, indica se a codificação é para applets java	
Ret: cRet -> string, texto HTML "printável"
--------------------------------------------------------------------------------------
*/                                 
function DelAspas(acValue, acAspas)
	local cRet := acValue

	default cRet := ''
	default acAspas := '"'
	
	if left(cRet,1) == acAspas
		cRet := substr(cRet, 2, len(cRet)-2)
	endif
	
return cRet

function DelAspasSimples(acValue)
return DelAspas(acValue, "'")

function DWTrataImpXML(acTexto)
   acTexto := strtran(acTexto, "&amp;", "&")
   acTexto := strtran(acTexto, "&apos;", "'")
   acTexto := strtran(acTexto, "&lt;", "<")
   acTexto := strtran(acTexto, "&gt;", ">")
   acTexto := strtran(acTexto, "&quot;", '"')            
return acTexto
              
function DWTrataExpXML(acTexto)
	acTexto := strtran(acTexto, "&", "&amp;")
   	acTexto := strtran(acTexto, "'", "&apos;")
   	acTexto := strtran(acTexto, "<", "&lt;")
   	acTexto := strtran(acTexto, ">", "&gt;")
   	acTexto := strtran(acTexto, '"', "&quot;")            
return acTexto


function DWEncode(acValue, alApplet)
	local cRet := acValue
	local aDe, aPara
	
	if valType(acValue) == "C"
	
		default alApplet := .f.
	
		if !alApplet                                                        
			aDe   := { "<"   , ">"   , "  "          , "\" , chr(167), chr(166) }
			aPara := { "&lt;", "&gt;", "&nbsp;&nbsp;", "\\", "&ordm;", "&ordf;"}
		else
			aDe   := { "\" , '"' , "'", CRLF, CR, LF }
			aPara := { "\\", '\"', "\'", "\n", "\n", "" }
		endif
		aEval(aDe, { |x, i|cRet := strTran(cRet, x, aPara[i]) })
	endif
	
return cRet	

/*
--------------------------------------------------------------------------------------
Valida o numero de licenças
Args: 
Ret: lRet -> lógico, licença válida
--------------------------------------------------------------------------------------
*/                      
function DWHaveLicense()
return .t.

/*
--------------------------------------------------------------------------------------
Deixa a primeira letra em maiusculas com palavras com 3 ou mais letras
Args: acValue -> string, valor a ser convertido
Ret: cRet -> string, valor convertido
--------------------------------------------------------------------------------------
*/                      
function DWCapitilize(acValue, alHtml, acChar)
	local aAux, nInd, cRet
	local bFormat, bFormat2

	default alHtml := .f.
	default acChar := space(1)
		
	if alHtml
		bFormat := { |x| left(x,1) + "<small>" + substr(x,2) + "</small>" }
		bFormat2 := { |x| "<small>" + (x) + "</small>" }
	else
		bFormat := { |x| upper(left(x,1)) + lower(substr(x,2)) }
		bFormat2 := { |x| lower(x) }
	endif
	
	aAux := DWToken(acValue, acChar, .f.)
	for nInd := 1 to len(aAux)
		aAux[nInd] := DWStr(aAux[nInd])
		if len(aAux[nInd]) > 2 .or. aAux[nInd] $ "[{}]"
			aAux[nInd] := eval(bFormat, aAux[nInd])
		else
			aAux[nInd] := eval(bFormat2, aAux[nInd])
		endif
	next
	
	cRet := DWConcatWSep(acChar, aAux)
		
	if acChar == space(1) .and. "." $ cRet
		cRet := DWCapitilize(cRet, alHtml, ".")
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Converte valores inteiros em código de cor RGB (hex)
Args: anRed, anGreem, anBlue -> numero, código da cor
Ret: cRet -> string, cor em hex
--------------------------------------------------------------------------------------
*/                      
function DWRGB(anRed, anGreen, anBlue)
return DWint2hex(anRed, 2) + DWint2hex(anGreen, 2) + DWint2hex(anBlue, 2)

/*
--------------------------------------------------------------------------------------
Prepara texto e envia para o HTTP
Args: acText -> string, texto a ser enviado
      alScroll -> lógico, indica se deve haver ou não scrool do documento
Ret: 
--------------------------------------------------------------------------------------
*/                      
function DWHttpSend(acText, alScroll, alNoCRLF, acDivID)
	local cAux

	default alScroll := .t.
	default alNoCRLF := .f.
	default acDivID := ""
	
	if HttpIsConnected()
		if type("oSigaDW") == "O" .and. oSigaDW:isSched()
			alScroll := .f.
		endif

		if empty(acDivID)
			if alScroll
				acText += CRLF+tagJS()+"window.scrollBy(0, 50);</script>"+CRLF
			endif
		else
			cAux := CRLF + tagJS()
			cAux +=        "getElement('"+acDivID+"').innerHTML = '"+acText+"';"
			cAux +=        "</script>"+CRLF
			acText := cAux
		endif
		
		if alNoCRLF
			acText := strTran(acText, CRLF, "")
		endif
		HttpSend(acText)
	endif

return len(acText)

function DWHttpAlter(acText)
return DWHttpSend(acText, .f., .t.)

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

/*
--------------------------------------------------------------------------------------
Converte para maiusculas, preservando se estiver estre aspas (simples ou dupla)
Args: acText
Ret: cRet
--------------------------------------------------------------------------------------
*/                      
function DWUpper(acText)
   	local cRet := ""
   	local cAspas := ""
   	local nInd, cAux
   
	for nInd := 1 to len(acText)	
   		cAux := substr(acText, nInd, 1)
   		if !empty(cAspas)
   			cRet += cAux
   		elseif cAux == "'"
   			cRet += cAux
   			cAspas := cAux 
   		elseif cAspas == cAux 
   			cRet += cAux
   			cAspas := ""
   		else
   			cRet += upper(cAux)
   		endif
	next
		
return cRet

/*
--------------------------------------------------------------------------------------
Converte expressões QBE para expressões em formato HTML
Args: acFieldname, string -> nome do campo ["|" id do campo]
      acTipo, string -> tipo do campo
      aaQbeExpr, array -> lista de expressões QBE
      acCaption, string -> titulo do campo
		acComp, string -> complemento a ser utilizado nos nomes internos de campos
		aaParams, string -> lista de parametros com valores dos parametros (:)
		alAnd, logico
		alMeta, logico => formato para Meta-dados
		alReadOnly, logico -> indica somente leitura (prompt)
Ret: String -> expressão QBE em formato HTML                       
--------------------------------------------------------------------------------------
*/                      
function QBE2Html(acFieldName, acTipo, aaQbeExpr, acCaption, acComp, aaParams, alAnd, alMeta, alReadOnly, alGraf, anTam)
   	local nInd, xValue, lNot, cRet
	local aParts
	local aSQL := {}, cExpr
	local acAnd := ""
	
	default aaParams := {}
	default alAnd := .f.
	default alMeta := .f.
	default alReadOnly := .f.
	default alGraf := .f.
	default anTam := 0

	if "|" $ acFieldName
		aParts := dwToken(acFieldName, "|")
		acFieldName := aParts[1]
		acComp := acFieldName + " id="+aParts[2]
	endif
	
	if alAnd
		acAnd := "<span class='operAnd'>"+STR0008+"</oper>"/*//" E "*/
	else
		acAnd := "<span class='operOr'>"+STR0009+"</oper>"/*//" OU "*/
	endif
	
	for nInd := 1 to len(aaQbeExpr)
		if valType(aaQbeExpr[nInd]) == "U"
			loop
		endif
		xValue := procRightSlash(DWStr(aaQbeExpr[nInd]), .t.)
		xValue := strTran(strTran(xValue, chr(13)), chr(10))
		
		lNot := upper(left(xValue,4)) == "NÃO " .or. ; // NÃO TRADUZIR, SÃO COMANDOS
				upper(left(xValue,4)) == "NAO "
		if lNot
			xValue := substr(xValue, 5)
		endif
		
		if right(upper(xValue),5) == "VAZIO"  // NÃO TRADUZIR , SÃO COMANDOS
			xValue := "["+substr(STR0013,2,5)+"]"/*//"<vazio>"*/
		endif
		
		if at("|", xValue) > 0 // in (lista)
			if ".." $ xValue
				cExpr := "["+acCaption+"<img src="+iif(__WebService, WPS_HOME_IMG, "dwGetFile.apw?file=")+"sirene.gif width=10 height=10>"+STR0100+"<br>" /*não é permitido o uso do operador '..' em conjunto com '|' ou '-']*/
			else
				cExpr := acFieldName + STR0014 + StrTran(xValue, "|",",") + " }"/*//" igual a um destes valores { "*/
			endif
		elseif at("-", xValue) > 0 // between (faixa)
			aParts := DWToken(xValue, "-", .f.)
			aSize(aParts, 2)
			aParts[1] := DWStr(PrepHtmlVal(acTipo, aParts[1], acComp, aaParams, alMeta, alReadOnly, anTam))
			aParts[2] := DWStr(PrepHtmlVal(acTipo, aParts[2], acComp, aaParams, alMeta, alReadOnly, anTam))
		
			if ".." $ aParts[1] .or. ".." $ aParts[2]
				cExpr := " ["+acCaption+"<img src="+iif(__WebService, WPS_HOME_IMG, "dwGetFile.apw?file=")+"sirene.gif width=10 height=10>"+STR0100+"<br>" /*não é permitido o uso do operador '..' em conjunto com '|' ou '-']*/
			elseif !empty(aParts[1]) .and. !empty(aParts[2])
				cExpr := acFieldName + STR0018 + aParts[1] + STR0019 + aParts[2] + " }"/*//" na faixa de { "###" } até { "*/
			elseif empty(aParts[1])
				cExpr := acFieldName + STR0020 + aParts[2] + " }"/*//" até { "*/
			else
				cExpr := acFieldName + STR0021 + aParts[1] + " }"/*//" a partir de { "*/
			endif
		elseif at("..", xValue) > 0 // like
			cExpr := acFieldName
			if acTipo != "D"
				if left(xValue, 2) == ".." .and. right(xValue, 2) == ".."
					cExpr += STR0015/*//" contém "*/
				elseif left(xValue, 2) == ".."
					cExpr += STR0016/*//" termina com '"*/
				elseif right(xValue, 2) == ".."
					cExpr += STR0017/*//" começa com '"*/
				endif
			else
				if left(xValue, 6) == "../../"
					cExpr += " " + STR0155 + " '" //###"ano"
				elseif right(xValue, 6) == "/../.."
					cExpr += " " + STR0156 + " '" //###"dia"
				elseif right(xValue, 3) == "/.." .and. left(xValue, 3) == "../"
					cExpr += " " + STR0157 + " '" //###"mês"
				elseif left(xValue, 3) == "../"
					cExpr += " " + STR0157 + "/" + STR0155 + " '" //###"mês"/"ano"
				elseif right(xValue, 3) == "/.."
					cExpr += " " + STR0156 + "/" + STR0157 + " '" //###"dia"/"mes"
				elseif substr(xValue, 3, 4) == "/../"
					cExpr += " " + STR0156 + "/" + STR0155 + " '" //###"dia"/"ano"
				else
					cExpr += xValue
				endif
			endif
			cExpr += PrepHtmlVal(acTipo, strTran(xValue, "..", ""), acComp, aaParams, alMeta, alReadOnly, anTam)
		elseif left(xValue, 2) == ">=" // greater or equal than
			cExpr := acFieldName + STR0022 + DWStr(PrepHtmlVal(acTipo, substr(xValue, 3), acComp, aaParams, alMeta, alReadOnly, anTam))/*//" maior ou igual a "*/
		elseif left(xValue, 2) == "<=" // less or equal than
			cExpr := acFieldName + STR0023 + DWStr(PrepHtmlVal(acTipo, substr(xValue, 3), acComp, aaParams, alMeta, alReadOnly, anTam))/*//" menor ou igual a "*/
		elseif left(xValue, 1) == ">" // greater than
			cExpr := acFieldName + STR0024 + DWStr(PrepHtmlVal(acTipo, substr(xValue, 2), acComp, aaParams, alMeta, alReadOnly, anTam))/*//" maior que "*/
		elseif left(xValue, 1) == "<" // less than
			cExpr := acFieldName + STR0025 + DWStr(PrepHtmlVal(acTipo, substr(xValue, 2), acComp, aaParams, alMeta, alReadOnly, anTam))/*//" menor que "*/
		else  // =
			cExpr := acFieldName + STR0026 + DWStr(PrepHtmlVal(acTipo, xValue, acComp, aaParams, alMeta, alReadOnly, anTam))/*//" igual a "*/
		endif
		
		if lNot
			cExpr := STR0027 + cExpr + ")"/*//"não("*/
		endif                                     

		aAdd(aSQL, procRightSlash(cExpr, .f., .t.))
	next

	if alGraf
	   	cRet := StrTran(" " + DWConcatWSep(acAnd, aSQL), " " + acFieldname + " ", "[" + acCaption +"] ")	
	else
	   	cRet := StrTran(" " + DWConcatWSep(acAnd, aSQL), " " + acFieldname + " ", "<span class='declarCaption'> [" + acCaption +"] </span>")
	   	cRet := StrTran(cRet, "{", "<span class='declarTarget'>{")
	   	cRet := StrTran(cRet, "}", "}</span>")
	endif

return cRet
	
/*
--------------------------------------------------------------------------------------
Converte expressões QBE para expressões em formato SQL
Args: acFieldname, string -> nome do campo
      acTipo, string -> tipo do campo
      aaQbeExpr, array -> lista de expressões QBE
      acAlias, string -> nome alternativo do campo
      acComp, string -> complemento utilizado nos parametros (:)
Ret: String -> expressão QBE em formato SQL
--------------------------------------------------------------------------------------
*/                      
function QBE2Sql(acFieldName, acTipo, aaQbeExpr, acCaption, acComp, aaParams, alAnd, alStruct)
  	local nInd, xValue, lNot, aParts, aSQL := {}, cExpr, acAnd, aAux
	local x,i
		
	default aaParams := {}
	default alAnd := .f.
	default alStruct := .f.

	if alAnd
		acAnd := " and "
	else
		acAnd := " or "
	endif

	for nInd := 1 to len(aaQbeExpr)
		if valType(aaQbeExpr[nInd]) == "U"
			loop
		endif

		xValue := procRightSlash(DWStr(aaQbeExpr[nInd]), .t.)
		xValue := strTran(strTran(xValue, chr(13)), chr(10))
					
		lNot := upper(left(xValue,4)) == "NÃO " .or. upper(left(xValue,4)) == "NAO " .or. lower(left(xValue,4)) == "não " .or. lower(left(xValue,4)) == "nao " // NÃO TRADUZIR , SÃO COMANDOS
		if lNot
			xValue := substr(xValue, 5)
		endif 
		
		if right(upper(xValue),5) == "VAZIO" // NÃO TRADUZIR , SÃO COMANDOS
			cExpr := acFieldName + " is null or "+acFieldName + "=" + iif(acTipo == "N", "0", "''")
		elseif at("|", xValue) > 0 // in (lista)
			if ".." $ xValue
				cExpr := ""
			else
				aAux := dwToken(xValue, "|", .F.)
		   		for i := 1 to len(aAux)
   					x := aAux[i]
   					if len(x) == 10 .and. substr(x,3, 1) == "/" .and. substr(x,6, 1) == "/"
   						aAux[i] := dwStr(dtos(ctod(x)), .t.)
   					elseif x == "{VAZIO}"
   						aAux[i] := "''"
		   			else 
		   				x := dwConvTo(acTipo, x)
   						aAux[i] := dwStr(x, .t.)
	   				endif
		   		next
				cExpr := acFieldName + " in ( " + dwConcatWSep(",",aAux) + " )"
			endif
		elseif at("-", xValue) > 0 // between (faixa)
 			aParts := DWToken(xValue, "-", .T.)
			aSize(aParts, 2)               
			if !empty(aParts[1])
				aParts[1] := DWStr(PrepSQLVal(acTipo, aParts[1], acComp, aaParams))
			endif

			if !empty(aParts[2])
				aParts[2] := DWStr(PrepSQLVal(acTipo, aParts[2], acComp, aaParams))
			endif

			if ".." $ aParts[1] .or. ".." $ aParts[2] 
				cExpr := ""
			elseif !empty(aParts[1]) .and. !empty(aParts[2]) 
				cExpr := acFieldName + " between " + aParts[1] + " and " + aParts[2]
			elseif empty(aParts[1]) .and. !empty(aParts[2])
				cExpr := acFieldName + " <= " + aParts[2]
			elseif !empty(aParts[1]) .and. empty(aParts[2])
				cExpr := acFieldName + " >= " + aParts[1]
			else //if alStruct                                                    
				if acTipo == "N"
					cExpr := acFieldName + " = 0"
				else 
				   cExpr := acFieldName + " = ''"
				endif
			endif
		elseif at("..", xValue) > 0 // like
			cExpr := acFieldName
			if !(acTipo == "D")
				// verifica se deve passar o nome do prompt (acComp) em casos tenha prompt ":"
				acComp := iif( at(":", xValue) > 0 , acComp, "" )
				
				if acTipo != "C" 		
			   		if acTipo = "N"  
			   		   	cExpr += " = " + DwStr(Val(strTran(PrepSQLVal(acTipo, xValue, acComp, aaParams), "..")))
			   		Else
			   			cExpr += " like '" + strTran(PrepSQLVal(acTipo, xValue, acComp, aaParams) + "'", "..", "%")
			   	    EndIf
			   	else   
		   			cExpr += " like " + strTran(PrepSQLVal(acTipo, xValue, acComp, aaParams), "..", "%")
			   	endif 			   			
			else   
				/*TODO - Rever todas as intruções abaixo*/			
				if left(xValue, 6) == "../../"
					cExpr := "@ano(" + cExpr + "," + right(xValue, 4) + ")"
				elseif right(xValue, 6) == "/../.."
					cExpr := "@dia("+cExpr+"," + left(xValue, 2) + ")"
				elseif right(xValue, 3) == "/.." .and. left(xValue, 3) == "../"
					cExpr := "@mes("+cExpr+"," + substr(xValue, 4, 2) + ")"
				elseif left(xValue, 3) == "../"
					cExpr := "@anomes("+cExpr+"," + right(xValue, 4) + substr(xValue, 4, 2) + ")"
				elseif right(xValue, 3) == "/.."
					cExpr := "@mesdia("+cExpr+"," + substr(xValue, 4, 2) + left(xValue, 2) + ")"
				elseif substr(xValue, 3, 4) == "/../"
					cExpr := "@anodia("+cExpr+"," + right(xValue, 4) + left(xValue, 2) + ")"			
				else  
					cExpr += " like '" + strTran(PrepSQLVal(acTipo, xValue, acComp, aaParams) + "'", "..", "%")					
				endif
			endif
		elseif left(xValue, 2) == ">=" // greater or equal than
			cExpr := acFieldName + " >= " + DWStr(PrepSQLVal(acTipo, substr(xValue, 3), acComp, aaParams))
		elseif left(xValue, 2) == "<=" // less or equal than
			cExpr := acFieldName + " <= " + DWStr(PrepSQLVal(acTipo, substr(xValue, 3), acComp, aaParams))
		elseif left(xValue, 1) == ">" // greater than
			cExpr := acFieldName + " > " + DWStr(PrepSQLVal(acTipo, substr(xValue, 2), acComp, aaParams))
		elseif left(xValue, 1) == "<" // less than
			cExpr := acFieldName + " < " + DWStr(PrepSQLVal(acTipo, substr(xValue, 2), acComp, aaParams))
		else  // =
			cAux := DWStr(PrepSQLVal(acTipo, xValue, acComp, aaParams))

			if !empty(cAux)
				If (acTipo) == 'D'  
					aDate  := DwToken(cAux, "/", .F.)
				   	cDtAux := ''
				   				    
				 	For i := Len(aDate) to 1 step -1
				 	    cDtAux += Alltrim(DwStr(aDate[i]) )
				 	Next i			
				
				 	cExpr := acFieldName + " like " + " '%" + strTran(cDtAux, "'", "") + "%'"					
				ElseIf (acTipo) == 'N'
			   		cExpr := acFieldName + " = " + DWStr( Val( strTran(cAux , "," , "." ) ) )    
				Else
					cExpr := acFieldName + " = " + cAux    
				EndIf                 
			elseif alStruct
				cExpr := acFieldName + " = " + DWStr(iif(acTipo=="N", 0, ASPAS_S+ASPAS_S))
			endif
		endif
		
		if lNot
			cExpr := "not(" + cExpr + ")"
		endif  
	
		if !empty(cExpr)
			aAdd(aSQL, procRightSlash(cExpr, .f., .t.))
		endif
	next
return DWConcatWSep(acAnd, aSQL)

static function procRightSlash(acValue, alProtect, alDelete)
	default alDelete := .f.
	
	if alProtect
		acValue := strTran(acValue, "\-", "\^")
		acValue := strTran(acValue, "\.", "\~")
	elseif alDelete
		acValue := strTran(acValue, "\^", "-")
		acValue := strTran(acValue, "\~", ".")
	else
		acValue := strTran(acValue, "\^", "\-")
		acValue := strTran(acValue, "\~", "\.")
	endif
return acValue

static Function PrepHtmlVal(acTipo, axValue, acComp, aaParams, alMeta, alReadOnly, anTam)
return PrepVal(acTipo, axValue, .t., acComp, aaParams, alMeta, alReadOnly, anTam)

static Function PrepSqlVal(acTipo, axValue, acComp, aaParams, alMeta)
return PrepVal(acTipo, axValue, .f., acComp, aaParams, alMeta, .f.)

static function prepValWPrompt(axValue, acComp, acTipo, aaParams, alHtml)
	local cOpen := "", cClose := "", cRet, nPos	
 	
	if left(axValue, 2) == ".."
		cOpen := '..'
		axValue := substr(axValue,3)
	endif

	if right(axValue, 2) == ".."
		cClose := '..'
		axValue := substr(axValue,1, len(axValue)-2)
	endif
	
	if acTipo == "C"
		cOpen := "'" + cOpen
		cClose := cClose + "'"
	endif         
	
	cRet := acComp + axValue
	nPos := ascan(aaParams, {|x| x[1] == cRet})   
	
	if nPos > 0
		if acTipo == "D"
			cRet := dtos(DWConvTo("D", aaParams[nPos][2]))
			if !alHtml
				cRet := "'"+cRet+"'"
			endif
		elseif acTipo == "C" .or. acTipo == "L"
			if alHtml
				cRet := Params[nPos][2]
			else
				cRet := "'"+DWConvTo("C", aaParams[nPos][2])+"'"
			endif
		else
			cRet := aaParams[nPos][2]
		endif
		cRet := cOpen + strTran(cRet, "'", "") + cClose
	else 
		cRet := cOpen + acComp + axValue + cClose	
	endif
	
	if !alHtml .and. empty(delAspas(cRet, "'"))
		cRet := ""
	endif		    
	
return cRet

static Function PrepVal(acTipo, axValue, alHtml, acComp, aaParams, alMeta, alReadOnly, anTam)
	local cRet := DWStr(axValue), nPos := 0
	local cOpen, cClose, cAux, cValue
	
	default acComp := "ed"
	default alMeta := .f.
	default alReadOnly := .f.
	default anTam := 0
	
	if left(cRet,1) =="&"
		cRet := &(substr(cRet,2))
	endif
	
	If valType(axValue) == "C" .and. left(axValue,1) == ":"  // prompt
		axValue := substr(axValue,2)
		if alHtml
			cAux := "pt"+acComp+axValue
			if alMeta
				cRet := "[&nbsp;:"+axValue+"&nbsp;]"
			else
				nPos := ascan(aaParams, { |x| x[1] == acComp+axValue })
				if nPos == 0
					nPos := ascan(aaParams, { |x| x[1] == cAux })
				endif					

				if nPos <> 0 .and. valType(aaParams[nPos,2]) == "C" .and. ;
					left(aaParams[nPos,2],1) == "&" .and. ;
					valType(oSigaDW) == "O" .and. !oUserDW:UserIsAdm()
						cRet := "'" + dwStr(&(substr(aaParams[nPos,2],2))) + "'"
				else
					if nPos <> 0
						cValue := aaParams[nPos][2]
					endif

					if alReadOnly
						cRet := { |nValue| makeText(NIL, cValue) }
					elseif acTipo == "C"
						cRet := { |nValue| makeField(NIL, cAux, "", .F., "C", anTam, 0, , cValue, ) }
					elseif acTipo == "N"
						cRet := { |nValue| makeField(NIL, cAux, "", .F., "N", 10, 0, , cValue, ) }
					elseif acTipo == "L"
						cRet := { |nValue| makeRadioField(NIL, cAux, "", .F., , { "T", "F"}, { STR0028, STR0010 }) }
					elseif acTipo == "D"                                           
						cRet := { |nValue| makeDateField(nil, cAux, "", , , , cValue) }
					endif

					if len(aaParams) != 0 .and. !alMeta
						nPos := ascan(aaParams, { |x| "PT"+upper(x[1]) == upper(cAux)})
						if nPos <> 0
							cRet := eval(cRet, DWStr(aaParams[nPos,2]))
						endif
					endif
				endif
			endif
		else
			cRet := prepValWPrompt(axValue, acComp, acTipo, aaParams, alHtml)
			
			//--------------------------------------------------------------
			// Tratamento realizado para compatibilidade com todos SGBD.
			// Valores do tipo "Data" são trazidos entre ''.  
			//--------------------------------------------------------------
			if ( acTipo == "D" )
				cRet := dwStr( cRet, .T.)
			endIf
		endif
	else
		if left(DWStr(axValue),2) == ".."
			cRet := prepValWPrompt(axValue, acComp, acTipo, aaParams, alHtml)
		elseif acTipo == "C" .or. acTipo == "L"
			cRet := "'" + dwStr(cRet) + "'"
		elseif acTipo == "N"
			cRet := dwStr(cRet)
		elseif acTipo == "D"
			if alHtml
				if left(cRet, 2) == "//"
					cRet := substr(cRet, 3)          // ../../9999
				elseif right(cRet, 2) == "//"
					cRet := left(cRet, len(cRet)-2) // 99/../..
				elseif left(cRet, 1) == "/" .and. right(cRet, 1) == "/"
					cRet := substr(cRet, 2, 2)      // ../99/..
				elseif left(cRet, 1) == "/"
					cRet := substr(cRet, 2)         // ../99/9999
				elseif right(cRet, 1) == "/"
					cRet := left(cRet, len(cRet)-1)         // ../99/9999
				elseif substr(cRet, 3, 2) == "//"
					cRet := left(cRet, 3) + right(cRet, 4)        // ../99/9999
				else
					cRet := cRet
				endif
			else
				if left(cRet, 6) == "../../"
					cRet := right(cRet, 4) + "%"
				elseif right(cRet, 6) == "/../.."
					cRet := "%" + left(cRet, 2)
				elseif right(cRet, 3) == "/.." .and. left(cRet, 3) == "../"
					cRet := "____" + substr(cRet, 4, 2) + "__"
				elseif left(cRet, 3) == "../"
					cRet := strTran(right(cRet, 4)+substr(cRet,4,2) + "__", "/", "")
				elseif right(cRet, 3) == "/.."
					cRet := "____" + substr(cRet, 4, 2) + left(cRet, 2)
				elseif substr(cRet, 3, 4) == "/../"
					cRet := right(cRet, 4) + "__" + left(cRet, 2)
				else  	
					cRet := dtos(ctod(cRet))
				endif
				cRet := "'" + cRet + "'"
			endif
		endif
	endif
	
	if valType(cRet) == "B"
		cRet := DWStr(eval(cRet))
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Recupera valores em outra tabela. Se registro não encontrado retorna NIL
Args: acAlias -> string, alias da tabela alvo
		axValue -> numerico ou string, ID/chave a ser pesquisada
		acFieldname -> string, nome do campo desejado
		anIndex -> integer, número do indice a ser utilizado
		alUseList -> boolean, indica para usar lista de valores associados ao campo
Ret: xValue -> expressao, valor do campo
--------------------------------------------------------------------------------------
*/                      
function DWLookup(acAlias, axValue, acFieldname, anIndex, alUseList)
	local xRet := nil
	local cOldAlias := alias()
	local oTable := InitTable(acAlias)
	local lClose := .f.	

	default alUseList := .f.

	if valType(oTable) != "U" 
		if !oTable:isOpen()
			lClose := .t.	
			oTable:Open()
		else
		   oTable:Refresh()
		endif			

		default anIndex := 1
	
		oTable:savePos()
 
		if DWStr(axValue)	== "-1"
			xRet := {}               
			oTable:Seek(anIndex, 0)

			if valType(acFieldName)=="B"
				dbEval( { || aAdd(xRet, eval(acFieldname, oTable)) })
			elseif !alUseList
				dbEval( { || aAdd(xRet, oTable:value(acFieldname)) })
			else
				dbEval( { || aAdd(xRet, oTable:ListVal(acFieldname)) })
			endif
		else                              
			if valType(axValue) != "A"
				axValue := { axValue }
			endif				

			if oTable:Seek(anIndex, axValue)
				if valType(acFieldName)=="B"
					xRet := eval(acFieldname, oTable)
				elseif !alUseList
					xRet := oTable:value(acFieldname)
				else
					xRet := oTable:ListVal(acFieldname)
				endif
			endif
		endif
		oTable:restPos()

		if lClose
			oTable:Close()
		endif
	elseif DWStr(axValue) == "-1"
		xRet := {}
	endif

	if !empty(cOldAlias)
		dbSelectArea(cOldAlias)
	endif
	
return xRet 

/*
--------------------------------------------------------------------------------------
Recupera o ID outra tabela. Se registro não encontrado retorna 0
Args: acAlias -> string, alias da tabela alvo
		anIndex -> numerico, numero do indice a ser utilizado
		axAlvo -> expressao, valor alvo
Ret: nValue -> numerico, ID recuperado
--------------------------------------------------------------------------------------
*/                      
function DWRecID(acAlias, anIndex, axValue)
	local nRet := 0
	local cOldAlias := alias()
	local oTable := InitTable(acAlias)

	oTable:savePos()
	if oTable:Seek(anIndex, { axValue })
		nRet := oTable:value('id')
	endif
	oTable:restPos()

	if !empty(cOldAlias)
		dbSelectArea(cOldAlias)
	endif
	
return nRet 

/*
--------------------------------------------------------------------------------------
Recupera valores em outra tabela, gerando um array com todos eles.
 Se registro não encontrado array retorna vazio (Master->Detail)
Args: acAlias -> string, alias da tabela detail
		axID -> numerico, ID a ser pesquisado
		acbFieldname -> string|code-block, nome do campo desejado ou um code block
		acFieldWhile -> string, nome do campo a usar na comparação while
Ret: aRet -> array, valor do campo
--------------------------------------------------------------------------------------
*/
function DWDetail(acAlias, axID, acbFieldname, acFieldWhile, anIndex, anDwID)
	local aRet := {}
	local cOldAlias := alias()
	local oTable := InitTable(acAlias)
	local bExec 
	local lAllRecords := .F.

	default anIndex := 2
	default anDwID	:= -1
	
	if valType(axId) == "N" .AND. axId == -1
		oTable:goTop()
		lAllRecords := .T.
	endif
	
	__DWIDTemp := anDwID
	if lAllRecords .or. oTable:Seek(anIndex, { axID })
		if valType(acbFieldname) == "B"
			bExec := acbFieldname
		else
			bExec := { |oTab| oTab:value(acbFieldname)}
		endif

		while !oTable:eof() .and. (lAllRecords .or. oTable:value(acFieldWhile) == axID)
			oTable:SavePos()
			if anDwID == -1 .or. oTable:value("id_dw") == anDwID
				aAdd(aRet, eval(bExec, oTable))
			endif
			oTable:RestPos()
			oTable:_Next()
		enddo			
	endif
	__DWIDTemp := -1
	
	if !empty(cOldAlias)
		dbSelectArea(cOldAlias)
	endif

return aRet 

/*
--------------------------------------------------------------------------------------
Verifica a sintaxe de expressões ADVPL
Args: acExpresso -> string, expressão ADVPL a ser avaliada
		acMsg -> string, variavel passada por referencia que receberá a msg de erro
Ret: lRet -> logico, indica se há erro ou não
--------------------------------------------------------------------------------------
*/                       
function ChkSintax(acExpressao, acMsg)
	private lRet := .t., oE
	
	__DWErroCtrl := .t.
	acMsg := ""            
	begin sequence
		__compstr(strTran(acExpressao, "&", ""))
//	recover using oE    
//		if valType(oE) == "O"
//			acMsg := oE:Description
//		else    
//			acMsg := STR0029/*//"Expressão com erro, 0,0"*/
//		endif                         
//		lRet := .f.
	end sequence
	__DWErroCtrl := .f.

return lRet

/*
--------------------------------------------------------------------------------------
Executa  expressões ADVPL
Args: acExpresso -> string, expressão ADVPL a ser executada
		acMsg -> string, variavel passada por referencia que receberá o resultado
Ret: lRet -> logico, indica se há erro ou não
--------------------------------------------------------------------------------------
*/            
static __DWRPCTable := nil
static __DWRoteiros := nil

function resetRoteiro(aoRPCTable)
	__DWRoteiros := {}
	__DWRPCTable := aoRPCTable
return

static function execCB(abCode)
return __runCB(abCode)

function DWSinonimo(acFieldName)
return __DWRPCTable:value(acFieldName)

function DWFildget(acFieldName)
return DWSinonimo(acFieldName)

static function sinonimo(acFieldName)
return DWSinonimo(acFieldName)

static function getSrcFld(acFieldName)
return DWSinonimo(acFieldName)

function execRoteiro(anIDRoteiro)
	local xRet := NIL
   	local nPos := ascan(__DWRoteiros, { |x| x[1] == anIDRoteiro })
   	local cRoteiro, aFields, nInd, aAux
	local cField
	
	__DWErroCtrl := .t.
	if nPos == 0     
		aAux := DWDetail(TAB_EXPR, anIDRoteiro, STR0030, "id")/*//"linha"*/
		begin sequence
   	  		aAdd(__DWRoteiros, { anIDRoteiro, __compstr(alltrim(DWConcatWSep(CRLF, aAux)))})
			recover //	using oE    
			conout("********* " + dwstr(anIDRoteiro) + STR0031)/*//" erro de compilação"*/
			aEval(aAux, { |x| conout(x)})
			
			if valType(oSigaDW) == "O"
				oSigaDW:Log(STR0032, "ID="+DWStr(anIDRoteiro))/*//"Roteiro com erro de compilação"*/
				aEval(aAux, { |x| oSigaDW:Log(x) })
			endif
   	  		aAdd(__DWRoteiros, { anIDRoteiro, __compstr('return')})
		end sequence
		nPos := len(__DWRoteiros)                                       
	endif

	begin sequence   
		xRet := execCB(__DWRoteiros[nPos, 2])
		recover //using oE
		//DWLog(oE:Description)
		DWLog('**** ' + STR0115) //###"Erro na execução do roteiro"
		DWLog(__DWRoteiros[nPos, 2])
		xRet := nil
	end sequence
	__DWErroCtrl := .f.
return xRet

function execWWarn(acExpressao, acMsg, alAviso)
	private lOk := .t., oE, cExp := acExpressao

   default alAviso := .t.

	acMsg := ""            
	__DWErroCtrl := .t.
	begin sequence
		acMsg := __execstr(strTran(acExpressao, "&", ""))
//	recover using oE
//		if alAviso
//			if valType(oE) == "U"
//				conout('','','**** Erro ao executar expressão via execSintax()', cExp) 
//				DWCallStack(2)
//				conout('------------------------','') 
//			else
//				acMsg := oE:Description
//			endif
//		endif
//		lOk := .f.
	end sequence
	__DWErroCtrl := .f.

return lOk

function execSintax(acExpressao, acMsg, alAviso)
return execWWarn(acExpressao, @acMsg, alAviso)

/*
--------------------------------------------------------------------------------------
Criptografia e descriptografia simples
Args: acValue -> string, valor a ser criptografado
		anLen -> numerico, tamanho final
Ret: cRet -> string, valor a criptografado
--------------------------------------------------------------------------------------
*/                      
function DWCripto(acValue, anLen, anDeslocamento)
	local cRet := "", nAux
	local nInd

	default anDeslocamento := DESLOCAMENTO
		    
	acValue := padr(acValue, anLen, " ")
	for nInd := 1 to len(acValue)
		nAux := asc(substr(acValue, nInd, 1)) + anDeslocamento
		if nAux > 255
			nAux := 32
		endif
		cRet += DWInt2Hex(nAux,2)
	next

return cRet

function DWUncripto(acValue, anDeslocamento)
	local cRet := "", nAux
	local nInd

	default anDeslocamento := DESLOCAMENTO
		
	for nInd := 1 to len(acValue) step 2
		nAux := DWHex2Int(substr(acValue, nInd, 2)) - anDeslocamento
		if nAux < 32
			nAux := 255
		endif
		cRet += chr(nAux)
	next

return cRet

/*
--------------------------------------------------------------------------------------
Prepara string para ser usada no Java
Args: acValue -> string, valor a ser preparado
Ret: cRet -> string, valor preparado
--------------------------------------------------------------------------------------
*/                      
function DWStrJava(acValue)
	local cRet := acValue

/*
	local nInd
	local aCodes := { { "'", "27" } , ;
							{ '\', DWInt2Hex(asc("\"),2) }, ;
							{ '"', "22" } }

	ascan(aCodes, { |x| cRet := strtran(cRet, x[1], "\u00"+x[2]) })

	for nInd := 1 to 31	
		cRet := strtran(cRet, chr(nInd), "\u" + DWInt2Hex(nInd,4))
	next
*/

return cRet

function DWChgFileExt(acFilename, acExtension)
	local nPos := 0
   
	if acFilename <> NIL .and. acExtension <> NIL
		acFilename := AllTrim(acFilename)
      	if (nPos := at(".", acFilename)) > 0
         	acFilename := left(acFilename, nPos - 1 ) + acExtension
      	else
         	acFilename += acExtension
      	end
   	end

return acFilename

/*
-----------------------------------------------------------------------
Monta e executa SQL para deleção de registros
-----------------------------------------------------------------------
*/
function DWDelAllRec(acTablename, acCondicao, aaParams, acMsgErro, aaAuxFrom, alEmbeddedSQL)
	local oQuery := TQuery():New("DELTRA"), lRet

	default aaParams := {}                                                   
	default aaAuxFrom := {}
	default alEmbeddedSQL := .f.
	
	if len(aaAuxFrom) == 0
		oQuery:FromList(acTablename)
	else
		oQuery:FromList(acTablename + "," + dwConcatWSep(",", aaAuxFrom))
	endif
	oQuery:WhereClause(acCondicao)
	oQuery:withDelete(.t.)
	oQuery:EmbeddedSQL(alEmbeddedSQL)

	aEval(aaParams, { |x, i| oQuery:params(i, x) })
	lRet := oQuery:ExecDel()
	tcRefresh(acTablename)
	
	if !lRet
		acMsgErro := oQuery:msg()
	endif
	
return lRet

/*
-----------------------------------------------------------------------
Retorna séria de configurações:
	. o código da empresa/filial de amarração 
	. porta default de conexção do Protheus
	. log de console do protheus
	. página HTML de inicialização após o login (frame do desktop)
	. banco de dados do sigaDW
-----------------------------------------------------------------------
*/
static __DWEmpFil := nil
static __DWHomePage := ""
static __DWTOP := { "", "", "", 0, 0 }
static __DWPort := -1
static __DWLogConsole := ""
static __DWLogCallJob := .f.
static __DWIsDebug := ""
static __DWSqlTrace := .f.
static __DWLogReq := .f.
static __DWShowHeaders := .f.
static __DWResetCons := .f.
static __DWUpdDBOwner := .f.
static __DWDBOwner := ""
static __DWDoCompact := .f.
static __DWDropWF := .t.
static __DWLocWebComp := ""
static __DWAggFunc := {}
static __DWDefaultTheme := ""
static __DWZeraAcum := .f.
static __DWRootPath := ""
static __DWWebPath := "" 
static __DWWidthColDD := 0
static __DWUsrBuild := 0
static __DWOraProcess := ORA_INSERT_INTO
static __DWOraImport := ORA_IMP_DEFAULT
static __DWMetaPath := SigaDwDirFiles()+"\metadata"
static __DWMetaUpldPath
static __DWErrorPath := SigaDwDirFiles()+"\dwerror"
static __DWLogsPath := SigaDwDirFiles()+"\dwlogs"
static __DWExpFilesPath := SigaDwDirFiles()+"\expfiles"
static __DWTempPath := SigaDwDirFiles()+"\temp"
static __DWRegLang := ""
static __DWOffLine := .f.

//Controle de DEMO da Educação 
static __DWJavaClient := .f.

function SigaDwDirFiles()
return "\SigaDwFiles"
                         
function DwMetaPath()
return __DWMetaPath

function DwMetaUpldPath()
	
	If valType(__DWMetaUpldPath) == "U"
		__DWMetaUpldPath := GetPvProfString(getWebHost(), "UploadPath", SigaDwDirFiles()+"\upload", GetADV97())
		WFForceDir(DwMetaUpldPath())
	EndIf

return __DWMetaUpldPath

function DwErrorPath()
return __DWErrorPath

function DwLogsPath()
return __DWLogsPath

function DwExpFilesPath()
return __DWExpFilesPath

function DwTempPath()
return __DWTempPath

/*
-----------------------------------------------------------------------
Nome do diretorio de arquivos de erro
-----------------------------------------------------------------------
*/
function DWErrorDir()
	local cDir := DwErrorPath()
	
	cDir += "\"+strZero(year(date()),4)+strZero(month(date()),2)+strZero(day(date()),2)
	if !file(cDir+"\*.*")	                                
		WFForceDir(cDir)
	endif
	
return cDir

/*
-----------------------------------------------------------------------
Nome do diretorio de arquivos de logs
-----------------------------------------------------------------------
*/
function DWLogsDir()
	local cDir := DwLogsPath()

	cDir += "\"+strZero(year(date()),4)+strZero(month(date()),2)+strZero(day(date()),2)
	if !file(cDir+"\*.*")
		WFForceDir(cDir)
	endif
	
return cDir

function DWUsrBuild()
return __DWUsrBuild

function DWLoadCfg()
	Local cIniFile		:= DWIniFile()
	Local cDatabase		:= ''
	Local cAlias      	:= ''
	Local cServer      	:= ''
	Local cIniSession	:= ''
	Local nPort        	:= 0
	Local aTopInfo		:= {}
	
	If ( ValType( __DWJobName ) == "U" )
		__DWJobName := trataWebJobName()
	endif
	
	cIniSession := __DWJobName
	
	If ( ValType( __DWEmpFil ) == "U" )
		__DWEmpFil := GetPvProfString( cIniSession, "EmpFil", "ERROR", cIniFile )
		
		If ( empty( __DWEmpFil ) .Or. __DWEmpFil == 'ERROR' )
			__DWEmpFil := "99/01"
			conout(STR0033 + " [" + cIniSession + "] webJob=" + GetWebJob())/*//"ATENÇÃO:"*/
			conout(STR0034 + "[" + cIniSession + "]" )
			conout(STR0035 + cIniFile + " ]")/*//"   Chave [ EmpFil ] não especificada ou incorreta na sessão [ SigaDW ]"###"   do arquivo de configuração [ "*/
			conout(STR0036,STR0037)/*//"   Será assumido [ Empresa=99 ] e [ Filial=01 ]."###"   Algumas funções podem apresentar problemas de execução."*/
		endif
		
		#ifdef VER_P10
			__DWDefaultTheme := alltrim(GetPvProfString(cIniSession, "Theme", "p10", cIniFile))
		#else
			#ifdef VER_P11
				__DWDefaultTheme := alltrim(GetPvProfString(cIniSession, "Theme", "p11", cIniFile))
			#else
				__DWDefaultTheme := alltrim(GetPvProfString(cIniSession, "Theme", "msiga", cIniFile))
			#endif
		#endif
		
		__DWZeraAcum := GetPvProfString(cIniSession, "ZeraAcumRow", "0", cIniFile) == "1"
		__DWWidthColDD := dwVal(GetPvProfString(cIniSession, "WidthColDD", "0", cIniFile))
		__DWUsrBuild := val(GetPvProfString(cIniSession, "Build", "0", cIniFile))
		__DWOraProcess := dwVal(GetPvProfString(cIniSession, "OracleAggOpt", dwStr(ORA_CTAS), cIniFile))
		__DWOraImport := dwVal(GetPvProfString(cIniSession, "OracleImpOpt", dwStr(ORA_IMP_INDEX), cIniFile))
		
		#ifdef VER_P11
			aTopInfo		:= FWGetTopInfo()
			
			cDatabase	:= aTopInfo[4]
			cAlias		:= aTopInfo[5]
			cServer		:= aTopInfo[1]
			nPort			:= aTopInfo[3]
			
			if Empty( nPort ) .OR. valtype( nPort ) == "U"
				nPort := -1
			endif
		#else
			/*Recupera as informaçãoes de conexão do ambiente do DW*/
			cDatabase := GetPvProfString(GetEnvServer(),"TopDataBase", "ERROR", cIniFile )
			cAlias    := GetPvProfString(GetEnvServer(),"TopAlias", "ERROR", cIniFile )
			cServer   := GetPvProfString(GetEnvServer(),"TopServer", "ERROR", cIniFile )
			nPort     := dwVal(GetPvProfString(GetEnvServer(),"TopPort","-1", cIniFile ))
			
			/*Recupera o conteúdo da chave Database da sessão TOPConect/DBAcess do INI*/
			if cDatabase == "ERROR"
				cDatabase := GetPvProfString("TopConnect","DataBase","ERROR", cIniFile )
				
				If cDatabase == "ERROR"
					cDatabase := GetPvProfString("TOTVSDBAccess","DataBase","ERROR", cIniFile )
				EndIf
			endif
			
			/*Recupera o conteúdo da chave Alias/DBAlias da sessão TOPConect/DBAcess do INI*/
			if cAlias == "ERROR"
				cAlias    := GetPvProfString("TopConnect","Alias","ERROR", cIniFile )
				
				If ( cAlias == "ERROR" )
					cAlias := GetPvProfString("TOTVSDBAccess","Alias","ERROR", cIniFile )
					
					If ( cAlias == "ERROR" )
						cAlias := GetPvProfString("TOTVSDBAccess","DBAlias","ERROR", cIniFile )
					EndIf
				EndIf
			endif
			
			/*Recupera o conteúdo da chave Server da sessão TOPConect/DBAcess do INI*/
			if cServer == "ERROR"
				cServer   := GetPvProfString("TopConnect","Server","ERROR", cIniFile )
				
				If cServer == "ERROR"
					cServer := GetPvProfString("TOTVSDBAccess","Server","ERROR", cIniFile )
				EndIf
			endif
			
			/*Recupera o conteúdo da chave Port/DBPort da sessão TOPConect/DBAcess do INI*/
			if nPort == -1
				nPort  := dwVal(GetPvProfString("TopConnect","Port","0", cIniFile ))
				
				If nPort == 0
					nPort := dwVal(GetPvProfString("TOTVSDBAccess","Port","0", cIniFile ))
					
					If nPort == 0
						nPort := dwVal(GetPvProfString("TOTVSDBAccess","DBPort","0", cIniFile ))
					EndIf
				EndIf
			endif
		#endif
		
		__DWTOP := { "", "", "", 0, 0 }
		__DWTop[1] := cServer
		__DWTop[2] := upper(cDataBase)
		__DWTop[3] := cAlias
		// determina a vers]ap do TC em uso
		__DWTop[4] := GetPvProfString("TopConnect","TopApi","ERROR", cIniFile )
		
		If __DWTop[4] == "ERROR"
			__DWTop[4] := GetPvProfString("TOTVSDBAccess","TopApi","ERROR", cIniFile )
		EndIf
		
		if __DWTop[4] == "ERROR"
			__DWTop[4] := iif(DWIsAp7(), TC_VER_32, TC_VER_40)
		else
			__DWTop[4] := iif("TOPAPI32" $ upper(__DWTop[4]) .or. ("AS" $ cAlias .and. "400" $ cAlias), TC_VER_32, TC_VER_40)
		endif
		__DWTop[5] := nPort
		
		__DWPort := val(GetPvProfString("TCP", "PORT", DWStr(PORT_PROTHEUS), cIniFile))
		__DWLogConsole := iif(GetPvProfString("GENERAL", "ConsoleLog", "0", cIniFile) == "1", GetPvProfString("GENERAL", "ConsoleFile", "", cIniFile),"")
		
		nPos := rat("\", __DWLogConsole)
		
		if nPos != 0
			__DWLogConsole := substr(__DWLogConsole, nPos, 255)
		endif
		
		__DWIsDebug := GetPvProfString(cIniSession, "Debug", "0", cIniFile) == '1'
		__DWDropWF := GetPvProfString(cIniSession, "DropWF", "1", cIniFile) == '1'
		__DWLogCallJob := GetPvProfString(cIniSession, "LogCallJob", "0", cIniFile) == "1"
		
		//Controle DEMO
		__DWJavaClient := GetPvProfString(cIniSession, "JAVACLIENT", "-128", cIniFile) == '-128'
		
		if GetPvProfString(cIniSession, "SqlTrace", "", cIniFile) == "*ALL"
			__DWSqlTrace := .t.
		else
			__DWSqlTrace := .f.
		endif
		__DWLogReq := GetPvProfString(cIniSession, "LogHttpReq", "0", cIniFile) == "1"
		__DWShowHeaders := GetPvProfString(cIniSession, "ShowHeaders", "0", cIniFile) == "1"
		__DWResetCons := GetPvProfString(cIniSession, "ResetCons", "0", cIniFile) == "1"
		__DWUpdDBOwner := GetPvProfString(cIniSession, "UpdDBOwner", "0", cIniFile) == "1"
		__DWDoCompact := GetPvProfString(cIniSession, "DoCompact", "0", cIniFile) == "1"
		
		__DWLocWebComp := GetPvProfString(cIniSession, "LocationWebComponents", "", cIniFile)
		__DWAggFunc := dwToken(GetPvProfString(cIniSession, "AggFunc", "", cIniFile), ",")
		__DWOffLine := GetPvProfString(cIniSession, "PanelOffLine", "0", cIniFile) == CHKBOX_ON
		__DWRegLang := GetPvProfString(GetEnvServer(),"RegionalLanguage","BRA", cIniFile )
	endif 	   
return
 

function DWEmpresa(acEmpFil)
	if valType(acEmpFil) == "U"
    	acEmpFil := __DWEmpFil
  	endif
return left(acEmpFil, 2)


Function DWFilial(acEmpFil)
	Local aEmpresa := {} 

	If ( valType( acEmpFil ) == 'U' )
		aEmpresa 	:= aBIToken( __DWEmpFil, '/', .F. )
		acEmpFil 	:= cBIStr( aEmpresa[2] )
     	acEmpFil 	:= StrTran( acEmpFil, '[', '')	
  		acEmpFil 	:= StrTran( acEmpFil, ']', '')			
	EndIf
	    
	If(at("/",acEmpFil)>0)
 		acEmpFil:=SubStr( acEmpFil,at("/",acEmpFil)+1,len(acEmpFil) )
 	EndIf
 	
Return acEmpFil

/*----------------------------------------------------------------------
@Function DWDirInclude()
Retorna o caminho do diretório de includes da estação onde é executada.
@Param
@Return
	(Caracter) Retorna o caminho do diretório de include.
----------------------------------------------------------------------*/
function DWDirInclude()
    /*Atribui a variável o conteúdo da chave DIRINCLUDE da sessao GENERAL do server.*/
	Local cDirInclude := GetPvProfString("GENERAL", "DIRINCLUDE", "", DWIniFile())		

	If empty(cDirInclude)
		Conout("============================" + STR0208 + "=============================")
		Conout(STR0158) //###"A falta da chave DIRINCLUDE na sessão [GENERAL] do arquivo de configuração"                                                                                                                                                                                                                                                                                                                                                                                                                                                   
		Conout(STR0159) //###"inviabiliza o uso de SQL EMBEDDED em conexões do tipo SX."
		Conout("================================================================")
	Endif
return cDirInclude

function DWLogReq()
return __DWLogReq
                
function DWShowHeaders()
return __DWShowHeaders

function DWDefaultTheme()
return __DWDefaultTheme
                       
function DWZeraAcum()
return __DWZeraAcum

function DWWidthColDD()
return __DWWidthColDD
                     
function DWOraProcess()
return __DWOraProcess

function DWOraImport()
return __DWOraImport

function DWResetCons(alFlag)
	if valType(alFlag)=="L"
		__DWResetCons := alFlag
		WritePProString(__DWJobName, "ResetCons", iif(alFlag, "1", "0"), DWIniFile())
		conout(STR0116 + " [" + iif(alFlag, STR0028, STR0090) + "]") //###"Chave 'ResetCons' alterada para"###"Sim"###"Não"
	endif
return __DWResetCons
                    
function DWUpdDBOwner(alFlag)
	if valType(alFlag)=="L"
		if __DWUpdDBOwner <> alFlag
			__DWUpdDBOwner := alFlag
		  	WritePProString(__DWJobName, "UpdDBOwner", iif(alFlag, "1", "0"), DWIniFile())
		  	conout(STR0160 + " [" + iif(alFlag, STR0028, STR0090) + "]") //###"Chave 'UpdDBOwner' alterada para"###"Sim"###"Não"
		endif 
	endif
return __DWUpdDBOwner

function DWDBOwner()
  	local oQuery, oAux, cOwner, aOwner

  	if empty(__DWDBOwner) .and. tcCanOpen("TOP_FIELD")
   		oAux := TTable():New("DWVEROWNER")
   		oQuery := TTable():New("DWVEROWNER")
    	oAux:addField(,"CPO1", "C", 10, 0)
    	oAux:addField(,"CPO2", "N", 10, 1)
 	  	oAux:addField(,"CPO3", "D")
       
    	if oAux:exists()
 	    	oAux:dropTable()
    	endif
 	  	oAux:createTable()
    	oAux:open()
 	  	oAux:close()
  
    	oQuery := TQuery():New(DWMakeName("TRA"))
    	oQuery:FromList("TOP_FIELD")
		if SGDB() == DB_DB2400
		  	oQuery:FieldList("FNAMF2 as FIELD_TABLE")
			oQuery:WhereClause("FNAMF2 LIKE '%"+(oAux:tableName())+"%'")
   		else      
	  		oQuery:FieldList("FIELD_TABLE")
			oQuery:WhereClause("FIELD_TABLE LIKE '%"+oAux:tableName()+"%'")
  		endif
		oQuery:WithDeleted(.t.)
		oQuery:MakeDistinct(.t.)
   		oQuery:Open()
    	cOwner := oQuery:value("FIELD_TABLE")
   		aOwner := dwToken(cOwner, ".")
   		oAux:dropTable()
   		oQuery:close()

    	__DWDBOwner := aOwner[1]
  	endif

return __DWDBOwner


function DWDoCompact(alFlag)
	if valType(alFlag)=="L"
		if __DWDoCompact <> alFlag
		  	__DWDoCompact := alFlag
		  	WritePProString(__DWJobName, "DoCompact", iif(alFlag, "1", "0"), DWIniFile())
		  	conout(STR0161 + " [" + iif(alFlag, STR0028, STR0090) + "]") //###"Chave 'doCompact' alterada para"###"Sim"###"Não"
		endif 
	endif
return __DWDoCompact

function DWDefaultPort()
return __DWPort

function DWLogConsole()
return __DWLogConsole

function DWIsDebug()
return __DWIsDebug

function DWIsFlex()
return isNull(httpGet->Flex, CHKBOX_OFF) == CHKBOX_ON

function DWIsAjax()
return !isNull(HTTPHEADIN->X_REQUESTED_WITH)

function DWDropWF()
return __DWDropWF

function DWLogCallJob
return __DWLogCallJob

function DWTopDBFull()
return DWTopServer() + ":" + iif(empty(DWTopPort()),dwStr(DWTopPort())+":","")+DWTopDB() + "/" + DWTopAlias()

function DWTopServer()
return __DWTop[1]

function DWTopDB()
return __DWTop[2]

function DWTopAlias()
return __DWTop[3]

function DWTopVersion()
return __DWTop[4]

function DWTopPort()
return __DWTop[5]

function DWRegLang()
return __DWRegLang

function DWTraceSQL(acSQL) 
	if __DWSqlTrace
		conout("---------------------------", DWCallStack(2,,.f.), dwConcatWSep(CRLF, acSQL), "---------------------------")
	endif
/*
	local nInd
		                                     
	if __DWSqlTrace[1]
		conout("---------------------------", DWCallStack(2), ". *ALL", acSQL, "---------------------------")
	elseif len(__DWSqlTrace) > 1
		acSQL := upper(acSQL)
		for nInd := 2 to len(__DWSqlTrace)
			if __DWSqlTrace[nInd] $ acSQL
				conout("---------------------------", DWCallStack(2), "." + __DWSqlTrace[nInd], acSQL, "---------------------------")
				exit
			endif
		next
	endif
*/
return

function DWLocWebComp()
return __DWLocWebComp

function DWAggFunc()
return __DWAggFunc

function DWRootPath()

	if empty(__DWRootPath)
		__DWRootPath := GetPvProfString(getEnvServer(), "RootPath", "", GetADV97())
		if !(right(__DWRootPath, 1) $ "/\")
			__DWRootPath += "/"
		endif
	endif

return __DWRootPath

function DWWebPath()

	if empty(__DWWebPath)
		__DWWebPath := GetPvProfString(getWebHost(), "Path", "web/sigadw3", GetADV97())
	endif

return __DWWebPath

function DWisDemo()
return  __DWJavaClient
  
/*
-----------------------------------------------------------------------
Indica se o campo TAB_CONSULTAS.habPOnl, esta habilitado para apresentação/ediçao
-----------------------------------------------------------------------
*/
function DWPanOffLine()
return __DWOffLine

/*
-----------------------------------------------------------------------
Retorna o nome do arquivo ini
-----------------------------------------------------------------------
*/
function DWIniFile()
return upper(GetADV97())

/*
-----------------------------------------------------------------------
Retorna se o server é AP7
-----------------------------------------------------------------------
*/
function DWisAp7()
return "AP7SRV.INI" == DWIniFile()

/*
-----------------------------------------------------------------------
Retorna se o server é AP8
-----------------------------------------------------------------------
*/
function DWisAp8()
return "MP8SRV.INI" == DWIniFile()

/*
-----------------------------------------------------------------------
Retorna se o server é AP10
-----------------------------------------------------------------------
*/

function DWisAp10()
return "TOTVSAPPSERVER.INI" == DWIniFile()

/*
-----------------------------------------------------------------------
Extrai os nomes dos prompts e seus ultimos valores digitados
-----------------------------------------------------------------------
*/
function PromptExtract(cWhereName, cQbe, cLastValue)
	local aRet := {}, aLastValue, cPrompt, cValue, x, y

	cQbe := alltrim(cQbe)
	cWhereName := alltrim(cWhereName)
	cLastValue := alltrim(cLastValue)
	
	aLastValue := DWToken(cLastValue, ";", .F.)
	
	for x := 1 to len(cQbe)
		if(substr(cQbe,x,1) == ":")
			cPrompt := ""
			for y := x+1 to len(cQbe)
				if(lower(substr(cQbe,y,1)) $ "abcdefghijklmnopqrstuwvxyz01234567890_")
					cPrompt += substr(cQbe,y,1)
				else
					exit
				endif
			next

			cValue := iif( len(aLastValue)<len(aRet)+1, "", aLastValue[len(aRet)+1] )
			if cValue == "''"
				cValue := ""
			endif
			aAdd(aRet, { "cb"+cWhereName+cPrompt, cValue })
		endif
	next	
			
return aRet

/*
-----------------------------------------------------------------------
Formata uma lista de parametros conforme a string de formatação
As mascaras devem estar delimitadas por []
-----------------------------------------------------------------------
*/
function DWFormat(acFmtString, aaParams)
	local nParam := 0
	local cRet := ''
	local nPosI, nPosF
	local cMask, cAux                   
	
	if len(aaParams) == 0
		cRet := acFmtString
	else
		acFmtString := strTran(acFmtString, "\[", chr(254))
		acFmtString := strTran(acFmtString, "\]", chr(255))
		for nPosI := 1 to len(acFmtString)
			cAux := substr(acFmtString, nPosI, 1)
			if cAux == '['
				cMask := ''
				nParam++
				if nParam <= len(aaParams)
					for nPosF := nPosI + 1 to len(acFmtString)
						cAux := substr(acFmtString, nPosF, 1)
						if cAux == ']'
							if !("X" $ cMask) 
                				cMask := dwMask(cMask)
              			endif
							cRet := cRet + transform(aaParams[nParam], cMask)
							nPosI := nPosF
							exit
						else
				         	cMask := cMask + cAux
			  			endif
					next       
				endif
			else
				cRet := cRet + cAux
			endif
		next
		cRet := strTran(cRet, chr(254), "[")
		cRet := strTran(cRet, chr(255), "]")
	endif
	
return cRet

/*
-----------------------------------------------------------------------
Executa comandos SQL
Args: acSQL -> string/array, com o(s) comando(s) a executar
Ret.: numerico, código de erro (0=ok)
-----------------------------------------------------------------------
*/
function DWSQLExec(acSQL)
	local nRet := 0, cErro, aSQL := acSQL, nInd, cCmd, cSQLOrig, nInd2
	local aIgnCmd := { "INSERT INTO", ;
					"DROP INDEX", ;
					"CREATE PROCEDURE", ;
					"CREATE INDEX", ;
					"CREATE UNIQUE", ;
					"CREATE CLUSTERED" }
	
	if empty(acSQL)
		return 0
	endif

	if valType(acSQL) == "C"
		aSQL := DWToken(strTran(acSQL, " and group", " group"), CRLF)
		nRet := DWSQLExec(aSQL)
	else
		if upper(atail(aSQL)) != "GO"
			aAdd(aSQL, "GO")
		endif
		
		cSQL := ""
		for nInd := 1 to len(aSQL)
			if upper(aSQL[nInd]) == "GO"
				cSQLOrig := cSQL
				if SGDB() == DB_ORACLE
					if "CREATE OR REPLACE PROCEDURE" $ upper(cSQL)
						cSQL := strTran(cSQL, CRLF, LF)
					elseif ("SELECT " $ upper(cSQL) .or. "INSERT " $ upper(cSQL))
						cSQL := strTran(cSQL, "''", "' '")
					endif
				endif
				cCmd := upper(substr(cSQL, 1, 30))
				
				for nInd2 := 1 to len(aIgnCmd)
					if aIgnCmd[nInd2] == substr(cCMD, 1, len(aIgnCmd[nInd2]))
						nInd2 := -1
						exit
					endif
				next
				
				if nInd2 != -1
					cSQL := DWParseSQL(cSQL, .f.)
				endif 
				cErro := tcSqlError()				
				cSQL := strTran(cSQL, "\\n", CRLF)
				cSQL := strTran(cSQL, "\n", CRLF)
				nRet := TcSqlExec(cSQL) 
				
				if (nRet <> 0) .and. (cErro == tcSqlError())
					nRet := 0
				endif
				
				if (nRet == -19 .or. nRet == -21) .and. ;
					("DROP TABLE" == upper(left(cSQL, 10)) .or. ;
					"DROP INDEX" == upper(left(cSQL, 10)) .or. ;
					"DROP VIEW" == upper(left(cSQL, 9)) .or. ;
					"DROP PROCEDURE" == upper(left(cSQL, 14)) .or. ;
					"DROP SEQUENCE" == upper(left(cSQL, 13)) .or. ;
					"EXEC SP_RENAME" == upper(left(cSQL, 14)) .or. ;
					"ALTER TABLE" == upper(left(cSQL, 11)))
						nRet := 0
				endif					
				
				if nRet <> 0
					cErro := tcSqlError() 
					
					/*Emite a mensagem de erro apenas no modo de DEBUG.*/
					If (DwIsDebug())					
						conout("########################################################")
						conout("SQLError Code " +DWStr(nRet), cErro)
						conout("-< Original >-------------------------------------------")
						conout(cSQLOrig)
						conout("-< MSParse >--------------------------------------------")
						conout(cSQL)
						conout("--------------------------------------------------------")
						DWCallStack()
						conout("########################################################")					
					EndIf
														
					if DWisWebEx()
						appRaise(ERR_008, SOL_002, cErro)
					endif
					exit
				endif		
				cSQL := ""
			else
				cSQL += aSQL[nInd] + CRLF
			endif		
		next
	endif		
		
return nRet

/*
-----------------------------------------------------------------------
Efetua um "strtran" ignorando a caixa
Args: acValue -> string, valor original
		acOldVal -> string, sub-string alvo (valor antigo)
		acNewal -> string, sub-string (novo valor)
Ret.: string, valor tratado
-----------------------------------------------------------------------
*/
function strTranIgnCase(acValue, acOldVal, acNewVal)
	local cRet := acValue, nPos := 0
	local nOldVal := len(acOldVal), nNewVal := len(acNewVal)
	local cAux, nInd
	
	acOldVal := upper(acOldVal)                                                
	cAux := ""
	for nInd := 1 to nNewVal
		cAux += substr(acNewVal, nInd, 1) + chr(254)
	next                                           
   	
   	while (nPos := at(acOldVal, upper(cRet))) != 0 
   		cRet := stuff(cRet, nPos, nOldVal, cAux)
   	enddo
	
return strTran(cRet, chr(254), "")

/*
-----------------------------------------------------------------------
Envia e-mails via o SigaWF
Args: acSubject -> string, assunto
      acText -> string, texto a ser enviado
      acTo -> string, destinatario
      acCc -> string, destinatario com cópia
Ret.: string, valor tratado
-----------------------------------------------------------------------
*/
function DWSendMail(acSubject, acText, acTo, acCc, aaAttachs, acEmpresa, acFilial, acBcc)
	local owf, omsg, nInd
	local cMailBox

	DWLoadCfg()

	default acTo := iif(Type("oSigaDW")=="O", oSigaDW:Notify()[2], "")
	default acCc := ''
	default acBcc := ''
	default aaAttachs := {}
	default acEmpresa := DWEmpresa()
	default acFilial := DWFilial()
	
	if DWisAP7()
		if !empty(acTo) .or. !empty(acCc)
			owf := twfobj( {acEmpresa, acFilial })
			omsg := owf:omail:oSmtpSrv:omsg
	
			omsg:cfrom := owf:omail:cName + " <" + owf:omail:cAddress + ">"
			omsg:cto := acTo
			omsg:ccc := acCc
			omsg:cbcc := acBcc
			omsg:csubject := acSubject
			omsg:cbody := acText
			
			for nInd := 1 to len(aaAttachs)
				if file(aaAttachs[nInd])
					omsg:attachFile(aaAttachs[nInd])
				endif	
			next	

			owf:omail:oSmtpSrv:Send()
   		endif
	else
		wfprepEnv(acEmpresa, acFilial)
     	cMailBox := WFGetMV("MV_WFMLBOX","(* " + STR0162 + "*)") //###"configuração da conta de WF inválida"
	    WFNewMsg(cMailBox, strTran(acTo, CRLF, ";"), strTran(acCC, CRLF, ";"), strTran(acBCC, CRLF, ";"), acSubject, acText, aaAttachs)
		wfSndMsg(cMailBox)
	endif   
return

/*
-----------------------------------------------------------------------
Prepara comando SQL para ser executado conforma o SGDB. Caso o comando
não possa ser processado, o código original será retornado
Args: acSQL -> string, comando SQL
      alRaise -> boolean, indica se erro deve ser levantado
Ret.: string, SQL preparado
-----------------------------------------------------------------------
*/
function DWParseSQL(acSQL, alRaise)
	local cRet := acSQL
	
	default alRaise := .f.      
  
	cRet := strTran(cRet, "'+chr(39)+'", "''")
	cRet := strTran(cRet, "'+chr(34)+'", '"')      

return cRet

/*
-----------------------------------------------------------------------
Cria e registra "campos" em HttpSession
Args: pcName -> string, nome da variavel
		axValue -> expressão, valor
Ret.: axValue -> expressão, valor
-----------------------------------------------------------------------
*/
function RegInSession(pcName, pxValue)

	if valType(pcName) == "U"
		HttpSession->ASession := {}
	else
		if ascan(HttpSession->ASession, { |x| x == pcName} )	== 0
			aAdd(HttpSession->ASession, pcName)
		endif
		
		if valType(pxValue) != "U"
			&("HttpSession->"+pcName+":="+dwStr(pxValue,.t.))
		endif
	endif
	
return iif(valType(pcName)=="C",&("HttpSession->"+pcName),nil)

/*
-----------------------------------------------------------------------
Cria e registra "campos" em HttpPost
Args: pcName -> string, nome da variavel
		axValue -> expressão, valor
Ret.: axValue -> expressão, valor
-----------------------------------------------------------------------
*/
function RegInPost(pcName , pxValue)

	if ascan(HttpPost->APost, { |x| x == upper(pcName)} )	== 0
		aAdd(HttpPost->APost, upper(pcName))
	endif
	
	if valType(pxValue) != "U"
		&("HttpPost->"+pcName+":="+dwStr(pxValue,.t.))
	endif
	
return &("HttpPost->"+pcName)

/*
-----------------------------------------------------------------------
DWEncodeParm - Codifica parametros a serem utilizados na URL
Args: acName - nome do parametro
		axValuee - expresão
Ret.: acValue -> string, parametro codificado
-----------------------------------------------------------------------
*/
function DWEncodeParm(acName, axValue)
	
	axValue := dwStr(axValue)
	
return iif(!empty(acName), iif(empty(axValue),"","&"+acName+"="+JSEncode(DWCripto(axValue, len(axValue)*2))), DWCripto(axValue, len(axValue)*2))

/*
-----------------------------------------------------------------------
DWDecodeParm - Decodifica parametros a serem utilizados na URL
Args: acValue - string, valor do parametro codificado
Ret.: acValue -> string, valor do parametro decodificado
-----------------------------------------------------------------------
*/
function DWDecodeParm(acValue)
return allTrim(DWUncripto(acValue))

/*
-----------------------------------------------------------------------
DWTrunc - Trunca um valor numérico sem arredondar
Args: anValue - valor a truncar
		anTam - tamanho final do número
		anDec - número de decimais
Ret.: anValue -> valor truncado
-----------------------------------------------------------------------
*/
function DWTrunc(anValue, anTam, anDec)
return val(Str(anValue, anTam, anDec))

/*
-----------------------------------------------------------------------
IsEmpty - Se empty(axValue) for verdadeiro, retorna axRetorno, retorna
		o próprio axValue mas no mesmo tipo de axRetorno
Args: axValue - valor a ser avaliado
		axRetorno - valor a retornar caso empty(axValue) seja .t.
Ret.: axRet -> valor a retorna processado
-----------------------------------------------------------------------
*/
function DWIsEmpty(axValue, axRetorno)
return (iif(empty(axValue), axRetorno, DWConvTo(valType(axRetorno), axValue) ))


/*
-----------------------------------------------------------------------
DWShowTables - Lista as workareas abertas
Args: alSX - indica que as SX´s também devem ser listadas
-----------------------------------------------------------------------
*/
function DWShowTables(acTitle, alSX)
	local nWorkArea, aAlias := {}
	
	default alSX := .f.
   
	for nWorkArea := 1 to 250
		dbSelectArea(nWorkArea)
		if !(alias() == "")
			if !alSX .and. left(alias(),2) $ "SX|SM|SI|CT"
				loop
			endif
			aAdd(aAlias, alias())
		endif
	next
	
	conout("---------------------------------------", padc(acTitle, 40))
	if len(aAlias) == 0
		conout(STR0163) //###"Não há workareas abertas"
	else
		conout(dwConcatWSep(CRLF, aAlias))
	endif
	conout("---------------------------------------")
return

/*
-----------------------------------------------------------------------
DWRefreshAll() - forca atualização nas tabelas do DW
-----------------------------------------------------------------------
*/
function DWRefreshAll(acPrefixo)
	local nWorkArea, nLen
	
	default acPrefixo := "DW"
  	
  	nLen := len(acPrefixo)
	
	for nWorkArea := 1 to 250
		dbSelectArea(nWorkArea)
		if !(alias() == "") .and. left(alias(), nLen) == acPrefixo
			tcRefresh(alias())
		endif
	next

return

/*
-----------------------------------------------------------------------
isXmlNode - Verifica se o node <cNode> existe em <oNode>
-----------------------------------------------------------------------
*/
function isXmlNode(oNode, cNode)
	local aAux := classDataArr(oNode)
	local lRet := .f., nPos
	
	cNode := upper(cNode)
	nPos := ascan(aAux, { |x| x[1] == cNode })
   	if nPos > 0
   		lRet := valType(aAux[nPos, 2]) != "U"
   	endif	       
   
return lRet

function xmlNodeExist(oNode, cNode)
return XmlChildEx( oNode, upper(cNode) ) <> NIL 

function getXmlNode(oNode, cNode)
	local aAux := classDataArr(oNode)
	local oRet := nil, nPos
	
	cNode := upper(cNode)
	nPos := ascan(aAux, { |x| x[1] == cNode })
   	if nPos > 0
   		oRet := aAux[nPos, 2]
   	endif	       
   
return oRet

/*
-----------------------------------------------------------------------
Rotinas para tratamento de wizard
-----------------------------------------------------------------------
*/
function DWWizardMode()
return isNull(HttpGet->w, "") == CHKBOX_ON

function DWStep()
return isNull(HttpGet->s, 0)

function DWIsStep(nStep)
return DWStep() == nStep

function DWIsFirstStep()
return DWStep() == 1

function DWIsLastStep()
return DWStep() == DWLastStep()

function DWLastStep()
return isNull(HttpGet->ls, 0)

function DWStepTitle(cComp)
return dwConcat(DWStep(), "/", DWLastStep(), cComp)

function DWStepError(cMsg)
	if valType(cMsg) == "C"
		HttpSession->WizardMessage := cMsg
	endif
return HttpSession->WizardMessage

function DWBackStep()
	
	if !DWIsFirstStep()
		HttpGet->s := dwStr(dwVal(HttpGet->s)-1)
	endif
	
return 

function DWNextStep()
	
	if !DWIsLastStep()
		HttpGet->s := dwStr(dwVal(HttpGet->s)+1)
	endif
	
return 

function DWGoStep(nStep)
	
	HttpGet->s := dwStr(nStep)
	
return 

/*
-----------------------------------------------------------------------
Remove informações do dicionário de dados do SigaDW
-----------------------------------------------------------------------
*/
function DWEraseDD(acTableName, acTipoInfo)
	local oDD := initTable(TAB_DD)
	local lAll
   
	default acTipoInfo := ""
	lAll := empty(acTipoInfo)
			
	if oDD:Seek(2, { acTableName, acTipoInfo }, .t.)
		while !oDD:Eof() .and. oDD:value("Tablename") == acTableName
			if lAll .or. oDD:value("Typeinfo") == acTipoInfo
				oDD:Delete()
			endif
			oDD:_Next()
		enddo
	endif

return

/*
-----------------------------------------------------------------------
Retorna um array com diversas informações sobre o SigaDW
-----------------------------------------------------------------------
*/
function DWGetStatus(alHtml, alTable)
	local aMsg := {}, cAux, aAux, i, x
	
	default alTable := .f.
	default alHtml := .f. .or. alTable

	// informaçoes gerais
	aAdd(aMsg, { STR0123, DWIniFile() } ) //###"Arquivo de configuração"
	aAdd(aMsg, { STR0164, __DWJobName } ) //###"Web Job"
	aAdd(aMsg, { STR0079, DWEmpresa() + "/" + DWFilial() } ) //###"Empresa/Filial [EmpFil]"
	aAdd(aMsg, { STR0080,  } ) //###"Base de dados"
	aAdd(aMsg, { STR0081, DWTopServer() } ) //###" Servidor [TopServer ou Server*]"
	
	if !empty(DWTopPort())
		aAdd(aMsg, { STR0082, DWTopPort() } ) //###" Porta [TopPort ou Port*]"
	endif
	
	aAdd(aMsg, { STR0165, DWTopDB() } ) //###" SGDB [TopDatabase ou Database*]"
	aAdd(aMsg, { STR0166, DWTopAlias() } ) //###" Alias [TopAlias ou Alias*]"
	aAdd(aMsg, { STR0083, } ) //###"* quando especificados na sessão [TopConnect]"
	
	// Otimização de agregação para Oracle
	if DWTopDB() == DB_ORACLE
		aAdd(aMsg, { STR0167,  } ) //###"Otimização (base Oracle)"
		aAdd(aMsg, { STR0168, iif(DWOraProcess()==ORA_INSERT_INTO, "default",iif(DWOraProcess()==ORA_MERGE, "merge", "ctas"))}) //###" Otimizador de agregação [OracleAggOpt]"
 		aAdd(aMsg, { STR0169, iif(DWOraImport()==ORA_IMP_DEFAULT, "default", iif(DWOraImport()==ORA_IMP_MERGE, "merge", STR0170))}) //###" Otimizador de importação [OracleImpOpt]"###"indexado"
	endif

	// gravação do metadados	
	cAux := alltrim(DwMetaPath())
	aAdd(aMsg, { STR0084, "" }) //###"Diretórios do Metadados"
	aAdd(aMsg, { STR0085, cAux }) //###"Armazenamento [MetadataPath]"
	
	aAdd(aMsg, { STR0087, "" }) //###"Diversos"
	
	// verifica se esta em modo debug
	aAdd(aMsg, { " "+STR0088+" [Debug]", iif(DWIsDebug(), "", STR0090 + " ") + STR0091}) //###"Modo informativo"###"Não###"Habilitado"
	
	// Log de requisições HTTP
	aAdd(aMsg, { " "+STR0092+" [LogHttpReq]", iif(DWLogReq(), "", STR0090 + " ") + STR0091} ) //###"Log requições HTTTP"###"Não###"Habilitado"
	
	// Apresenta headers
	aAdd(aMsg, { " "+STR0093+" [ShowHeaders]", iif(DWShowHeaders(), "", STR0090 + " ") + STR0141} ) //###"Cabeçalhos HTTP"###"Apresentar"

	// Invalidar consultas
	aAdd(aMsg, { " "+STR0094+" [ResetCons]", iif(DWResetCons(), STR0028, STR0090) } ) //###"Invalidar consultas"###"Sim"###"NÃO"

	// Trocar "owner" do SGDB()
  	if SGDB() == DB_ORACLE .or. SGDB() == DB_DB2
	  	aAdd(aMsg, { " "+STR0171+" [UpdDBOwner]'", iif(DWUpdDBOwner(), STR0028, STR0090) } ) //###"Ajustar 'owner' do banco de dados"###"Sim"###"NÃO"
	endif

	// Remoção do arquivo de trabalho da importação                          
	aAdd(aMsg, { " "+STR0095+" [DropWF]", iif(DWDropWF(), "", STR0028) + STR0142} ) //###"Arquivo importacäo"###"Remover"
 	
	// Log de chamadas a Jobs
	aAdd(aMsg, { " "+STR0096+" [LogCallJob]", iif(DWLogCallJob(), "", STR0090) + STR0091}) //###"Reg. chamadas a Job´s"###"Não###"Habilitado"

	// URL de localização do MS-Web Components, para instalação
	aAdd(aMsg, { " " + STR0097 + " [LocationWebComponents]", iif(empty(DWLocWebComp()), "(" + STR0098 + ")", DWLocWebComp()) } ) //###"URL MS-Web Comps"###"não informado"

	// Chave para ativação do campo TAB_CONSULTAS.habPOnl
	aAdd(aMsg, { " " + STR0197 + " [PanelOffLine]", iif(DWPanOffLine(), "", STR0090) + STR0091}) //###"Configurar consulta com Painel Off-line"###"Não###"Habilitado"#"Consulta Painel Off-line"
	
	// Diretórios de pesquisa dos includes, para uso de SQL Embedded
	if empty(DWDirInclude())		
		aAdd(aMsg, { " "+STR0172+" [DirInclude]", "(" + STR0132 + ")" } ) //###"Diretórios para 'include'"###"não informado"
	else                                                      
		aAdd(aMsg, { " "+STR0172+" [DirInclude]", "" } ) //###"Diretórios para 'include'"
		aEval(dwToken(DWDirInclude(), ";"), { |x| aAdd(aMsg, { "                                       ", x } )})
	endif
	
	// build
	aAdd(aMsg, { STR0099, "" } ) //###"Versão"
	aAdd(aMsg, { " SigaDW", "" })
	aAdd(aMsg, { "   Modulo", DWBuild() })
	aAdd(aMsg, { "   Site", DWBuildSite() })
	aAdd(aMsg, { " Protheus", getBuild() })
	aAdd(aMsg, { " TopConnect",  DWTopVersion()} )
	
	/* DEMO Educacao
	if DWIsDemo()
		aAdd(aMsg, { STR0196 } ) //###"Versão para demonstração - Não permitido nivel de administrador"
	end if */
	aEval(aMsg, { |x,i| aMsg[i] := { dwStr(x[1]), dwStr(x[2]) }})

	if alHtml
		if !alTable
			for i := 1 to len(aMsg)
				x := aMsg[i]
				if left(x[1],1) == "*"
					x[1] := "<small><i>      "+x[1]+"</i></small>"
				elseif empty(x[2])
					x[1] := "<b>"+x[1]+"</b>"
				endif
				aMsg[i] := { strTran(strTran(strTran(x[1], "[", "[<i>"), "]", "</i>]"), " ", "&nbsp;"), x[2] }
			next				
		else
			aAux := {}
			aAdd(aAux, "<table border=0 cellpadding=0 cellspacing=0 width=100% align=center>")
			aAdd(aAux, "<thead>")
			aAdd(aAux, "<tr>")
			aAdd(aAux, "<th width=50%>" + STR0145 + "</th>") //###"Propriedade"
			aAdd(aAux, "<th width=50%>" + STR0146 + "</th>") //###"Valor"
			aAdd(aAux, "</tr>")
			aAdd(aAux, "</thead>")
			aAdd(aAux, "<tbody>")
			
			for i := 1 to len(aMsg)
				x := aMsg[i]
				if left(x[1],1) == "*"
					x[1] := "<small><i>      "+x[1]+"</i></small>"
				elseif empty(x[2])
					x[1] := "<b>"+x[1]+"</b>"
				endif
			
				aMsg[i] := { strTran(strTran(strTran(x[1], "[", "[<i>"), "]", "</i>]"), " ", "&nbsp;"), x[2] }
				aAdd(aAux, "<tr>")
				x := aMsg[i]
				aAdd(aAux, "<td"+iif(empty(x[2])," colspan=2>",">")+strTran(strTran(strTran(x[1], "[", "[<i>"), "]", "</i>]"), " ", "&nbsp;")+"</td>")
				aAdd(aAux, "<td>"+strTran(x[2], " ", "&nbsp;")+"</td>")
				aAdd(aAux, "</tr>") 
			next				

			aAdd(aAux, "</tbody>")
			aAdd(aAux, "</table>")
			aMsg := dwConcatWSep(CRLF, aAux)
		endif
   else
		aEval(aMsg, { |x,i| aMsg[i] := iif(empty(x[2]), x[1], dwConcat(padr(x[1], 40, "."), " : ", x[2])) })
   endif
   
return aMsg


function ParsePath(acPath, acTipo)
   local cRet := ""

   acPath := alltrim(acPath)
   
   if acTipo == "PATH"
      cRet := substr(acPath, 1, rat("\", acPath)-1)
   elseif acTipo == "FILE"
      cRet := substr(acPath, rat("\", acPath)+1, rat(".", acPath)-(rat("\", acPath)+1))
   elseif acTipo == "EXT"
      cRet := substr(acPath, rat(".", acPath)+1)
   endif
   
return cRet

function ParseFile(acPath, acTipo)
   local cRet := ""

   acPath := alltrim(acPath)
   
   if acTipo == "FILE"
      cRet := substr(acPath, 1, rat(".", acPath)-1)
   elseif acTipo == "EXT"
      cRet := substr(acPath, rat(".", acPath)+1)
   endif
   
return cRet

/*
-----------------------------------------------------------------------
Retorna uma string com a diferenca em dias e horas entre duas datas/horas
Args(1): dDtIncial - data inicial
	   cHrInicial- hora inicial no formato HH:MM:SS
      dDtFinal - data final
	   cHrFinal- hora final no formato HH:MM:SS
Args(2): cDtHrIncial - data e hora inicial, no formato YYYYMMDD HH:MM:SS
         cDtHrFinal - data e hora final, no formato YYYYMMDD HH:MM:SS

Args(3): cDtHrIncial - data e hora inicial, no formato DD/MM/YYYY HH:MM:SS (set date)
         cDtHrFinal - data e hora final, no formato DD/MM/YYYY HH:MM:SS (set date)

Ret.: cRet -> string, no formato 9999 HH:MM:SS
-----------------------------------------------------------------------
*/
function DWElapTime(dDtInicial, cHrInicial, dDtFinal, cHrFinal)
	local nDias := 0, cHora := "00:00:00", aHr1, aHr2, nAux
	                                    
	if valType(dDtInicial) == "C"
		if "/" $ dDtInicial
	    	dDtInicial := dtos(ctod(left(dDtInicial, 10))) + right(dDtInicial, 8)
	    	cHrInicial := dtos(ctod(left(cHrInicial, 10))) + right(cHrInicial, 8)
	  	endif
	  	return DWElapTime(stod(left(dDtInicial, 8)), right(dDtInicial, 8), ;
					stod(left(cHrInicial, 8)), right(cHrInicial, 8))
	endif                                      
	
	if dDtFinal == dDtInicial
	  	if dwTime2Secs(cHrInicial) < dwTime2Secs(cHrFinal)
		  	cHora := elaptime(cHrInicial, cHrFinal)
	  	else
	  		cHora := "00:00:00"
	  	endif
	else
		nDias := dDtFinal - dDtInicial - 1
		aHr1 := dwToken(substr(DWElapTime(dDtInicial, cHrInicial, dDtInicial, "24:00:00"), 6), ":")
		aHr2 := dwToken(substr(DWElapTime(dDtFinal, "00:00:00", dDtFinal, cHrFinal), 6), ":")
		nAux := (aHr1[1] * 3600) + (aHr1[2] * 60) + aHr1[3] + ;
       			(aHr2[1] * 3600) + (aHr2[2] * 60) + aHr2[3]
		if nAux > 86399
			nDias++
			nAux -= 86400
		endif
		aHr1[1] := int(nAux/3600)
		nAux -= aHr1[1] * 3600
		aHr1[2] := int(nAux/60)
		nAux -= aHr1[2] * 60
		aHr1[3] := nAux
		
		cHora := strZero(aHr1[1], 2) + ":" + strZero(aHr1[2], 2) + ":" + strZero(aHr1[3], 2)
		if cHora == "24:00:00"
			cHora := "00:00:00"
		endif
	endif	

return strZero(nDias,4) + " " + cHora

/*
-----------------------------------------------------------------------
Retorna um numérico com a diferenca em segundos entre duas datas/horas
Args(1): dDtIncial - data inicial
	   cHrInicial- hora inicial no formato HH:MM:SS
      dDtFinal - data final
	   cHrFinal- hora final no formato HH:MM:SS
Args(2): cDtHrIncial - data e hora inicial, no formato YYYYMMDD HH:MM:SS
         cDtHrFinal - data e hora final, no formato YYYYMMDD HH:MM:SS

Ret.: nRet -> numero, diferenca em segundos
-----------------------------------------------------------------------
*/
#define SEGUNDOS_POR_DIA   86400
#define SEGUNDOS_POR_HORA   3600
#define SEGUNDOS_POR_MIN      60

function DWElapSecs(dDtInicial, cHrInicial, dDtFinal, cHrFinal)
	local cAux := DWElapTime(dDtInicial, cHrInicial, dDtFinal, cHrFinal)
	local aAux := dwToken(substr(cAux,6), ":")

return (dwVal(left(cAux, 4)) * SEGUNDOS_POR_DIA) +;
			(aAux[1] * SEGUNDOS_POR_HORA) +;
    		(aAux[2] * SEGUNDOS_POR_MIN) + ;
     		aAux[3]

function dwTime2Secs(acTime)
	local aAux := dwToken(acTime, ":")

return (dwVal(aAux[1]) * SEGUNDOS_POR_HORA) +;
			(dwVal(aAux[2]) * SEGUNDOS_POR_MIN) + ;
			dwVal(aAux[3])

  								     

/*
-----------------------------------------------------------------------
Converte segundos em DDD HH:MM:SS
Args: nSeconds - total de segundos
Ret.: cRet -> string, segundos convertidos em DDD HH:MM:SS
-----------------------------------------------------------------------
*/
function DWSecs2Str(nSeconds, alTotal, alFull)
	local cRet := "", nDia, nHora, nMin
	local nSecAux := nSeconds
	
	default alTotal := .f.
	default alFull  := .f.

	nDia := int(nSecAux / SEGUNDOS_POR_DIA)
	nSecAux -= nDia * SEGUNDOS_POR_DIA

	nHora := int(nSecAux / SEGUNDOS_POR_HORA)
	nSecAux -= nHora * SEGUNDOS_POR_HORA

	nMin := int(nSecAux / SEGUNDOS_POR_MIN)
	nSecAux -= nMin * SEGUNDOS_POR_MIN
	if nSecAux > 59
		nMin++
		nSecAux := 0
		if nMin > 59
			nHora++
			nMin := 0
			if nHora > 23
				nDia++
				nHora := 0
			endif
		endif
	endif

	if nDia > 0
		if alTotal
			cRet := dToC(date()+nDia) + " " 
		else
			cRet := "("+DWStr(nDia) + ")"
		endif
	endif

	cRet += strZero(nHora, 2) + ":" + strZero(nMin, 2) + ":" + strZero(nSecAux, 2)
	if alFull .and. !alTotal
		cRet := dToC(date()+nDia) + " " + cRet
	endif
	
return cRet

static function getFileAndSendIt(cFile, cType)
	local oFileHandle := TDWFileIO():new(cFile)
	
	if(oFileHandle:Open())
		HttpCTType(cType)
		HttpCTDisp('filename="' + cFile + '"')
		HttpCTLen(oFileHandle:Size())
		cDados := space(1024)
		while(oFileHandle:Read(@cDados) > 0)
			HttpSend(cDados)
		end
		oFileHandle:Close()               
	endif

function dwGetFile(cFile, cStyle, cType)
	local cType2 := cType
	
	default cType2 := ""

	getFileAndSendIt(dwPathFile(cFile, cStyle, @cType2), cType2)
						
return ""
                                    

/*
-----------------------------------------------------------------------
Gera uma senha de emergencia
-----------------------------------------------------------------------
*/
function dwValidBD(acSenha, acEmail, acUrl)
	local nStep := dwHex2Int(left(right(acSenha, 5), 1))
  	local cEnvName := getEnvServer()
  	local cSenha := "", nInd

  	acEMail := padr(MSCRC32STR(upper(acEMail)),8)
  	acURL := padr(MSCRC32STR("HTTP://"+upper(acURL)),8)
  	cEnvName := padr(MSCRC32STR(upper(cEnvName)),8)
  	cSenha := ""
  	for nInd := 0 to 2 
    	cSenha += substr(acEMail, nInd + nStep, 1)
    	cSenha += substr(acURL, nInd + nStep, 1)
    	cSenha += substr(cEnvName, nInd + nStep, 1)
  	next
  	cSenha += dwInt2Hex(nStep,1) + dwInt2Hex(date() - stod("19960404"), 4)
  	cSenha := upper(cSenha)

return cSenha == acSenha

static function buildBackDoor(aoDlg)
  	local nPos := ascan(aoDlg:aControls, { |x| x:cName == "oSay11" } )
  	local oSay := aoDlg:aControls[nPos]
  	local oUser, nRamdom, nInd, cAux, nStep
  	local cRandom, cEnvName, cEmail, cUrl
  	local aMsg := {}, cTo
                          
  	oSay:lVisibleControl := .T.      
  
  	aoDlg:refresh()
  	processMessages()
  
  	cEnvName := getEnvServer()
  	nPos := ascan(aoDlg:aControls, { |x| x:cName == "oGetEmail" } )
  	cEmail := alltrim(dw_email) // não funciona: alltrim(aoDlg:aControls[nPos]:getText())
  	cTo := cEmail
  	nPos := ascan(aoDlg:aControls, { |x| x:cName == "oGetUrl" } )
  	cUrl := alltrim(dw_url) // não funciona: alltrim(aoDlg:aControls[nPos]:getText())
  	nPos := ascan(aoDlg:aControls, { |x| x:cName == "oGetIP" } )
  	cIP := alltrim(dw_ip) // não funciona: alltrim(aoDlg:aControls[nPos]:getText())

  	SigaDWStart(GetPvProfString(alltrim(substr(dw_url,8,255)), "ResponseJob", "ERROR", upper(GetADV97())), .t.)
  	oUser := initTable(TAB_USER)

  	if oUser:seek(2, { "U", "DWADMIN" }, .f. ) .and. oUser:value("email") == cEMail
    	nStep := randomize(1, 4)
    	cEMail := padr(MSCRC32STR(upper(cEMail)),8)
    	cURL := padr(MSCRC32STR(upper(cURL)),8)
    	cEnvName := padr(MSCRC32STR(upper(cEnvName)),8)
    	cSenha := ""
    	for nInd := 0 to 2 
      		cSenha += substr(cEMail, nInd + nStep, 1)
      		cSenha += substr(cURL, nInd + nStep, 1)
      		cSenha += substr(cEnvName, nInd + nStep, 1)
    	next
    	cSenha += dwInt2Hex(nStep,1) + dwInt2Hex(date() - stod("19960404"), 4)
    	cSenha := upper(cSenha)
    	oSigaDW:Log(STR0173, "Login DWADMIN", STR0174 + " " + cSenha, STR0175+" " + cIP) //###"Solicitacão de senha de acesso de emergência"###"Senha"###"IP solicitante"
    	
    	aMsg := { STR0173 , ; //###"Solicitacão de senha de acesso de emergência"
				'', STR0176 + " " + oUser:value("nome"),; //###"Caro Sr(a)"
				'', STR0177 + " " + dtoc(date()) + " " + time() + " " + STR0178 + " " + cIP,; //###"Conforme solicitacäo efetuada, em "###"sob o IP"
				STR0179 + " " + DWBuild() + ".",; //###"estamos encaminhando sua senha de acesso ao"
				'', "Login DWADMIN", STR0174 + " " + cSenha,; //###"Senha"
				'', STR0180,; //###"Caso näo tenha solicitado a sua senha de acesso, favor comunicar a ocorrencia ao administrador da aplicacäo."
				'', STR0181 + ",", 'SigaDW' } //###"Grato pela compreensão"
   
    	dwLog(aMsg)
		DWSendMail("SIGADW - " + STR0182, DWConcatWSep(CRLF, aMsg), cTo, oSigaDW:Notify()[2]) //###"Senha de emergência"
    	msgAlert(STR0183 + " " + cTo + "." + STR0184) //###"A nova senha, foi enviada para o e-mail"###"Caso não o receba em até 24 horas, entre em contato com o administrador da aplicacäo ou consulte o 'log de console'."
  	else
    	dwLog(STR0185, STR0186, cTo, STR0175+" " + cIP) //###"Tentativa de solicitacão de senha de acesso de emergência"###"e-Mail"###"IP solicitante"
    	oSigaDW:Log(STR0185, STR0186, cTo, STR0175+" " + cIP) //###"Tentativa de solicitacão de senha de acesso de emergência"###"e-Mail"###"IP solicitante"
		CONOUT(oUser:value("email"))
    	msgAlert(STR0187) //###"Não foi possivel gerar a senha de emergência para o usuário."
  	endif

  aoDlg:end()

return 

main function dwBD()
  local oDlg,oSay1,oGet2,oSay4,oGet5,oSay6,oGet7,oSBtn8,oSBtn9, oSay10

  private dw_email := padr(".", 60)
  private dw_url := padr("http://" + STR0188, 60) //###"url.de.acesso"
  private dw_ip := getClientIP()
  
  oDlg := MSDIALOG():Create()
  oDlg:cName := "oDlg"
  oDlg:cCaption := STR0189 //###"Senha de emergência para o SigaDW"
  oDlg:nLeft := 0
  oDlg:nTop := 0
  oDlg:nWidth := 448
  oDlg:nHeight := 170
  oDlg:lShowHint := .F.
  oDlg:lCentered := .T.

  oSay1 := TSAY():Create(oDlg)
  oSay1:cName := "oSay1"
  oSay1:cCaption := STR0190 //###"e-Mail do administrador:"
  oSay1:nLeft := 10
  oSay1:nTop := 10
  oSay1:nWidth := 123
  oSay1:nHeight := 17
  oSay1:lShowHint := .F.
  oSay1:lReadOnly := .F.
  oSay1:Align := 0
  oSay1:lVisibleControl := .T.
  oSay1:lWordWrap := .F.
  oSay1:lTransparent := .T.

  oGet2 := TGET():Create(oDlg)
  oGet2:cName := "oGetEmail"
  oGet2:cCaption := dw_email
  oGet2:nLeft := 142
  oGet2:nTop := 10
  oGet2:nWidth := 285
  oGet2:nHeight := 21
  oGet2:lShowHint := .F.
  oGet2:lReadOnly := .F.
  oGet2:Align := 0
  oGet2:cVariable := "dw_email"
  oGet2:bSetGet := {|u| If(PCount()>0,dw_email:=u,dw_email) }
  oGet2:lVisibleControl := .T.
  oGet2:lPassword := .F.
  oGet2:lHasButton := .F.

  oSay5 := TSAY():Create(oDlg)
  oSay5:cName := "oSay5"
  oSay5:cCaption := STR0191 ///###"URL de acesso"
  oSay5:nLeft := 10
  oSay5:nTop := 60
  oSay5:nWidth := 123
  oSay5:nHeight := 17
  oSay5:lShowHint := .F.
  oSay5:lReadOnly := .F.
  oSay5:Align := 0
  oSay5:lVisibleControl := .T.
  oSay5:lWordWrap := .F.
  oSay5:lTransparent := .T.

  oGet6 := TGET():Create(oDlg)
  oGet6:cName := "oGetUrl"
  oGet6:cCaption := dw_url
  oGet6:nLeft := 142
  oGet6:nTop := 60
  oGet6:nWidth := 285
  oGet6:nHeight := 21
  oGet6:lShowHint := .F.
  oGet6:lReadOnly := .F.
  oGet6:Align := 0
  oGet6:cVariable := "dw_url"
  oGet6:bSetGet := {|u| If(PCount()>0,dw_url:=u,dw_url) }
  oGet6:lVisibleControl := .T.
  oGet6:lPassword := .F.
  oGet6:lHasButton := .F.

  oSay7 := TSAY():Create(oDlg)
  oSay7:cName := "oSay7"
  oSay7:cCaption := STR0175 + ":" //###"IP Solicitante"
  oSay7:nLeft := 10
  oSay7:nTop := 85
  oSay7:nWidth := 124
  oSay7:nHeight := 17
  oSay7:lShowHint := .F.
  oSay7:lReadOnly := .F.
  oSay7:Align := 0
  oSay7:lVisibleControl := .T.
  oSay7:lWordWrap := .F.
  oSay7:lTransparent := .T.

  oGet8 := TGET():Create(oDlg)
  oGet8:cName := "oGetIP"
  oGet8:cCaption := dw_ip
  oGet8:nLeft := 142
  oGet8:nTop := 85
  oGet8:nWidth := 285
  oGet8:nHeight := 21
  oGet8:lShowHint := .F.
  oGet8:lReadOnly := .T.
  oGet8:Align := 0
  oGet8:cVariable := "dw_ip"
  oGet8:bSetGet := {|u| If(PCount()>0,dw_ip:=u,dw_ip) }
  oGet8:lVisibleControl := .T.
  oGet8:lPassword := .F.
  oGet8:lHasButton := .F.

  oSBtn9 := SBUTTON():Create(oDlg)
  oSBtn9:cName := "oSBtn8"
  oSBtn9:cCaption := ""
  oSBtn9:nLeft := 316
  oSBtn9:nTop := 110
  oSBtn9:nWidth := 52
  oSBtn9:nHeight := 22
  oSBtn9:lShowHint := .F.
  oSBtn9:lReadOnly := .F.
  oSBtn9:Align := 0
  oSBtn9:lVisibleControl := .T.
  oSBtn9:nType := 2
  oSBtn9:bAction := {|| oDlg:End() }

  oSBtn10 := SBUTTON():Create(oDlg)
  oSBtn10:cName := "oSBtn10"
  oSBtn10:cCaption := ""
  oSBtn10:nLeft := 375
  oSBtn10:nTop := 110
  oSBtn10:nWidth := 52
  oSBtn10:nHeight := 22
  oSBtn10:lShowHint := .F.
  oSBtn10:lReadOnly := .F.
  oSBtn10:Align := 0
  oSBtn10:lVisibleControl := .T.
  oSBtn10:nType := 1
  oSBtn10:bAction := {|| buildBackDoor(oDlg) }
      
  oSay11 := TSAY():Create(oDlg)
  oSay11:cName := "oSay11"
  oSay11:cCaption := STR0192 //###"Aguarde. Gerando a nova senha."
  oSay11:nLeft := 11
  oSay11:nTop := 120
  oSay11:nWidth := 214
  oSay11:nHeight := 17
  oSay11:lShowHint := .F.
  oSay11:lReadOnly := .F.
  oSay11:Align := 0
  oSay11:lVisibleControl := .F.
  oSay11:lWordWrap := .F.
  oSay11:lTransparent := .F.
  oSay11:nClrText := CLR_WHITE
  oSay11:nClrPane := CLR_RED
  
  oDlg:Activate()

return

static function ParaEvitarAvisoErroAoCompilar()

	if .f.    
		getSrcFld(); Sinonimo()
		ParaEvitarAvisoErroAoCompilar()
	endif

return

/*
-----------------------------------------------------------------------
Efetua a carga de um arquivo XML, gerando o objeto XML espelho
-----------------------------------------------------------------------
*/
function DWLoadXML(acFilename, alPreProcess)
	local oXML, cError, cError1 := "", cError2 := ""
	local cFileOut
	
	default alPreProcess := .t.

	acFilename := fileFisicalDirectory(acFilename)
	
	if ".DWZ" $ upper(acFilename)
		MSDecomp(acFilename)
		ferase(acFilename)
		acFilename := DWChgFileExt(acFilename, ".DWM")
	endif
                        
	if alPreProcess
		//--------------------------------------------------------------
		// desvio da biblioteca do Protheus
		// A biblioteca do Protheus cria o arquivo .XXX no diretório 
		// (/system/), sendo que a function XmlParserFile grava os 
		// dados no arquivo da raíz do Protheus (/)
		//--------------------------------------------------------------
		cFileOut := DWChgFileExt(acFilename, ".XXX")
		oFile := TDWFileIO():New(cFileOut)
		oFile:Create(FO_WRITE)
		
		if !oFile:IsOpen()
			appRaise(ERR_002, SOL_005, "Internal Error in file [ " + acFileName + " ]")
		endif
		
		//--------------------------------------------------------------
		// desvio da biblioteca do Protheus
		// A biblioteca do Protheus lê o arquivo do diretório raíz 
		// do Protheus, então forçamos o diretório corrente para o 
		// diretório aonde foi realizado o upload do arquivo
		//--------------------------------------------------------------
		CurDir(DwMetaUpldPath())
		ft_fuse(acFilename)
		
		while !ft_feof()
			cAux := ft_freadln()
			oFile:writeln(convEntities(cAux))
			ft_fskip()
		enddo
		
		ft_fuse()
		oFile:Close()
		oXml := XmlParserFile(cFileOut,"_", @cError1, @cError2)
		oFile:Erase()
		CurDir(GetPvProfString(getEnvServer(), "StartPath", "", GetADV97()))
	else
		oXml := XmlParserFile(acFilename,"_", @cError1, @cError2)
	endif
	
	if !empty(cError1) .or. !empty(cError2)
		cError := "Warning: " + cError1 + " ******* Error: " + cError2
		appRaise(ERR_002, SOL_005, "XML Error [ " + cError + " ] in file [ " + acFileName + " ]")
	endif                              
	
return oXML

static function convEntities(acText)
	local cRet := acText
	
	cRet := strTran(cRet, "&Aacute;", "Á")  //    Capital A, acute accent
	cRet := strTran(cRet, "&Agrave;", "Á'") //    Capital A, grave accent
	cRet := strTran(cRet, "&Acirc;", "Â")   //    Capital A, circumflex accent
	cRet := strTran(cRet, "&Atilde;", "Ã")  //    Capital A, tilde
	cRet := strTran(cRet, "&Aring;", "Å")   //    Capital A, ring
	cRet := strTran(cRet, "&Auml;",  "Ä")   //    Capital A, dieresis or umlaut mark
	cRet := strTran(cRet, "&AElig;", "Æ")   //    Capital AE dipthong (ligature)
	cRet := strTran(cRet, "&Ccedil;", "Ç")  //    Capital C, cedilla
	cRet := strTran(cRet, "&Eacute;", "É")  //    Capital E, acute accent
	cRet := strTran(cRet, "&Egrave;", "È")  //    Capital E, grave accent
	cRet := strTran(cRet, "&Ecirc;", "Ê")   //    Capital E, circumflex accent
	cRet := strTran(cRet, "&Euml;", "Ë")    //    Capital E, dieresis or umlaut mark
	cRet := strTran(cRet, "&Iacute;", "Í")  //    Capital I, acute accent
	cRet := strTran(cRet, "&Igrave;", "Ì")  //    Capital I, grave accent
	cRet := strTran(cRet, "&Icirc;", "Î")   //    Capital I, circumflex accent
	cRet := strTran(cRet, "&Iuml;", "Ï")    //    Capital I, dieresis or umlaut mark
	cRet := strTran(cRet, "&ETH;", "Ð")     //    Capital Eth, Icelandic
	cRet := strTran(cRet, "&Ntilde;", "Ñ")  //    Capital N, tilde
	cRet := strTran(cRet, "&Oacute;", "Ó")  //    Capital O, acute accent
	cRet := strTran(cRet, "&Ograve;", "Ò")  //    Capital O, grave accent
	cRet := strTran(cRet, "&Ocirc;", "Ô")   //    Capital O, circumflex accent
	cRet := strTran(cRet, "&Otilde;", "Õ")  //    Capital O, tilde
	cRet := strTran(cRet, "&Ouml;", "Ö")    //    Capital O, dieresis or umlaut mark
	cRet := strTran(cRet, "&Oslash;", "Ø")  //    Capital O, slash
	cRet := strTran(cRet, "&Uacute;", "Ú")  //    Capital U, acute accent
	cRet := strTran(cRet, "&Ugrave;", "Ù")  //    Capital U, grave accent
	cRet := strTran(cRet, "&Ucirc;", "Û")   //    Capital U, circumflex accent
	cRet := strTran(cRet, "&Uuml;","Ü")     //    Capital U, dieresis or umlaut mark
	cRet := strTran(cRet, "&Yacute;", "Ý")  //    Capital Y, acute accent
	cRet := strTran(cRet, "&THORN;", "Þ")   //    Capital THORN, Icelandic
	//cRet := strTran(cRet, "&szlig;     Small sharp s, German (sz ligature)
	cRet := strTran(cRet, "&aacute;", "á")  //    Small a, acute accent
	cRet := strTran(cRet, "&agrave;", "à")  //    Small a, grave accent
	cRet := strTran(cRet, "&acirc;", "â")   //    Small a, circumflex accent
	cRet := strTran(cRet, "&atilde;", "ã")  //    Small a, tilde
	cRet := strTran(cRet, "&auml;", "ä")    //    Small a, dieresis or umlaut mark
	cRet := strTran(cRet, "&aelig;", "æ")   //    Small ae dipthong (ligature)
	cRet := strTran(cRet, "&ccedil;", "ç")  //    Small c, cedilla
	cRet := strTran(cRet, "&eacute;", "é")  //    Small e, acute accent
	cRet := strTran(cRet, "&egrave;", "è")  //    Small e, grave accent
	cRet := strTran(cRet, "&ecirc;", "ê")   //    Small e, circumflex accent
	cRet := strTran(cRet, "&euml;", "ë")    //    Small e, dieresis or umlaut mark
	cRet := strTran(cRet, "&iacute;", "í")  //    Small i, acute accent
	cRet := strTran(cRet, "&igrave;", "ì")  //    Small i, grave accent
	cRet := strTran(cRet, "&icirc;", "î")   //    Small i, circumflex accent
	cRet := strTran(cRet, "&iuml;", "ï")    //    Small i, dieresis or umlaut mark
	cRet := strTran(cRet, "&eth;", "ð")     //    Small eth, Icelandic
	cRet := strTran(cRet, "&ntilde;", "ñ")  //    Small n, tilde
	cRet := strTran(cRet, "&oacute;", "ó")  //    Small o, acute accent
	cRet := strTran(cRet, "&ograve;", "ò")  //    Small o, grave accent
	cRet := strTran(cRet, "&ocirc;", "ô")   //    Small o, circumflex accent
	cRet := strTran(cRet, "&otilde;", "õ")  //    Small o, tilde
	cRet := strTran(cRet, "&ouml;", "ö")    //    Small o, dieresis or umlaut mark
	cRet := strTran(cRet, "&oslash;", "ø")  //    Small o, slash
	cRet := strTran(cRet, "&uacute;", "ú")  //    Small u, acute accent
	cRet := strTran(cRet, "&ugrave;", "ù")  //    Small u, grave accent
	cRet := strTran(cRet, "&ucirc;", "û")   //    Small u, circumflex accent
	cRet := strTran(cRet, "&uuml;", "ü")    //    Small u, dieresis or umlaut mark
	cRet := strTran(cRet, "&yacute;", "ÿ")  //    Small y, acute accent
	cRet := strTran(cRet, "&thorn;", "þ")   //    Small thorn, Icelandic
	cRet := strTran(cRet, "&yuml;", "ÿ")    //    Small y, dieresis or umlaut mark

return cRet

function DWExistSP(cSPName)

	if type('cEmpAnt') == "U"
		cEmpAnt := DWEmpresa()
	endif

	if type('__aSPList') == "U"
		__aSPList := {}
	endif
	
return .f. //existProc(cSPName)

function DWexecSP(acSPname, axP1, axP2, axP3, axP4, axP5, axP6, axP7, axP8, axP9, axP0, alInit, alIgnoreResult)
	local aResult

	default alInit := .f.
  	default alIgnoreResult := .f.

	if valType(alInit) != "L"
 		appRaise(ERR_001, SOL_001, STR0101 + " " + acSPname) /* Excesso de parametros. Máximo permitido são 10. StoredProcedure:*/
	endif

	if !alInit	
		cEmpAnt := DWEmpresa()
	endif
	
	aResult := tcspexec(acSPname, axP1, axP2, axP3, axP4, axP5, axP6, axP7, axP8, axP9, axP0)
	if !alIgnoreResult .and. valType(aResult) == "U"         
		appRaise(ERR_001, SOL_001, "StoredProcedure: " + acSPname + " TopConnect message: " + tcSqlError() )
	endif

return aResult
               
function DWRemoteSP(acServer, acConType, acDataBase, acSPname, axP1, axP2, axP3, axP4, axP5, axP6, axP7, axP8, axP9, axP0)
return DWWaitJob(JOB_EXECSP, { acServer, acConType, acDataBase, acSPname, axP1, axP2, axP3, axP4, axP5, axP6, axP7, axP8, axP9, axP0 },, .f.) 

/*
user function tstDW()
	Local oDlg,oSBtn1,oSBtn2,oList3,oSay4
	
	oDlg := MSDIALOG():Create()
	oDlg:cName := "oDlg"
	oDlg:cCaption := "Teste DWRemote"
	oDlg:nLeft := 0
	oDlg:nTop := 0
	oDlg:nWidth := 208
	oDlg:nHeight := 256
	oDlg:lShowHint := .F.
	oDlg:lCentered := .F.


	oSBtn2 := SBUTTON():Create(oDlg)
	oSBtn2:cName := "oSBtn2"
	oSBtn2:cCaption := "oSBtn2"
	oSBtn2:nLeft := 52
	oSBtn2:nTop := 168
	oSBtn2:nWidth := 52
	oSBtn2:nHeight := 22
	oSBtn2:lShowHint := .F.
	oSBtn2:lReadOnly := .F.
	oSBtn2:Align := 0
	oSBtn2:lVisibleControl := .T.
	oSBtn2:nType := 1
	oSBtn2:bAction := {|| dwRemote("http://localhost/dw3", "gescom", oList3:aItems[oList3:nAt], 1) }

	oList3 := TLISTBOX():Create(oDlg)
	oList3:cName := "oList3"
	oList3:cCaption := "oList3"
	oList3:nLeft := 14
	oList3:nTop := 30
	oList3:nWidth := 154
	oList3:nHeight := 130
	oList3:lShowHint := .F.
	oList3:lReadOnly := .F.
	oList3:Align := 0
	oList3:lVisibleControl := .T.
	oList3:nAt := 0
	oList3:aItems := { "Acum","Alert2", "UF" }

	oSay4 := TSAY():Create(oDlg)
	oSay4:cName := "oSay4"
	oSay4:cCaption := "Selecione a consulta desejada"
	oSay4:nLeft := 12
	oSay4:nTop := 8
	oSay4:nWidth := 155
	oSay4:nHeight := 17
	oSay4:lShowHint := .F.
	oSay4:lReadOnly := .F.
	oSay4:Align := 0
	oSay4:lVisibleControl := .T.
	oSay4:lWordWrap := .F.
	oSay4:lTransparent := .F.

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) )
		
return
*/

user function tstDW()
  
  dwRemote("http://localhost/sigadw", "teste_dw", "graf", 2)

return

function DWRemoteR3(acHost, acDWName, acConsulta, anType)
	local o, oDlg, cTitle := acDWName + " - " + acConsulta  + " [SigaDW]"
	local cURL := acHost + ;
			"/h_m01showcons.apw?resetwindow=2&loadcons=true&id=0&info="+dwStr(anType)+;
			dwEncodeParm("dwacesss",DWConcatWSep("!", {acHost, upper(acDWName), alltrim(upper(subs(cUsuario,7,15))), time() }))+;
			'&name='+URLEncode(upper(acConsulta))+'&issched=on&'

	DEFINE MSDIALOG oDlg FROM 0, 0 TO 600, 800 TITLE cTitle PIXEL
    
    oDlg:lMaximized := .T.
    o:=TiBrowser():New(0,0,oDlg:nWidth / 2,oDlg:nHeight / 2, '',oDlg)
    o:Navigate(cURL)
 
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) )

return .T.    

//-------------------------------------------------------------------
/*/{Protheus.doc} DWRemote
Pertmite a visualização de uma consulta do SIGADW dentro do ambiente do SmartClient (Remote).

@param   cHost 		Caracter	URL do SIGADW.
@param   cDWName 		Caracter 	Nome do Data Warehouse
@param   cConsulta 	Caracter 	Nome da Consulta
@param   nType 		Numérico 	Tipo (1-Tabela, 2-Gráfico)
@param   cModelo 		Caracter	Modelo da Consulta (P - Pré-Definida, U - Usuário)
@param   lLink 		Lógico	 	Será link?
@author  BI Team
@version P11
@return  cRet Se lLink for verdadeiro, retorna a URL da consulta. Se falso, o retorno é vazio.
/*/
//-------------------------------------------------------------------
Function DWRemote(acHost, acDWName, acConsulta, anType, acModelo, alLink, acParGenerico)
	Local cTitle 			:= Upper(acDWName) + " - " + Upper(acConsulta)  + " [SigaDW]"
	Local cURL 			:= ""
	Local cRet 			:= ""
	Local nWindWidth 		:= 950
	Local nWindHeight 	:= 550

	Default acModelo 		:= "P"
	Default alLink		:= .F.
	Default acParGenerico:= ""

	// Monta a URL da consulta do DW.
	cURL := acHost
	cURL += "/w_sigadw3.apw"
	cURL += makeAction(AC_QUERY_EXEC,,.f.)
	cURL += dwEncodeParm("dwacesss", DWConcatWSep( "!", { acHost, Upper( UrlEncode( acDWName ) ), UrlEncode( DwStr( cUserName ) ), Time() }) )
	cURL += "&consName="
	cURL += Upper(acConsulta)
	cURL += "&oper=6&type="
	cURL += dwstr(anType)
	cURL += "&modelo="
	cURL += acModelo
	cURL += "&cache=0&genericParam="
	cURL += acParGenerico
	cURL += "&width="
	cURL += DwStr(nWindWidth)
	cURL += "&height="
	cURL += DwStr(nWindHeight)
	cURL += ",_blank,null,winManu0CAE2,1,1,null,null,false"

	If alLink
		cRet := cURL
	Else
		/*Realiza a chamada do browser padrão para exibir o resultado da consulta.*/
 		ShellExecute("Open", cURL, "" , "" , SW_SHOWMAXIMIZED)
	EndIf

Return cRet

static function txtStr2Html(alProc, alOnlyOne, acTxt, acTag, alEnd, acLinha, alNewPar)
	local nPos
  	local cEndTag := left(acTag,1) + "/" + substr(acTag, 2)
	
	default alNewPar := .f.
	
	alProc := .f.
				
	acLinha := alltrim(acLinha)
	while (nPos := at(acTxt, acLinha)) > 0
		if nPos == len(acLinha) .or. nPos == 1 .or. substr(acLinha, nPos-1, 1) < "0" .or. substr(acLinha, nPos-1, 1) > "z"
			alProc := .t.
			acLinha := substr(acLinha, 1, nPos-1) + acTag + substr(acLinha, nPos+len(acTxt))
			if alEnd
				nPos := at(acTxt, acLinha)
				if nPos > 0
					if nPos == len(acLinha) .or. nPos == 1 .or. substr(acLinha, nPos+len(acTxt)+1, 1) < "0" .or. substr(acLinha, nPos+len(acTxt)+1, 1) > "z"
						acLinha := substr(acLinha, 1, nPos-1) + cEndTag + substr(acLinha, nPos+len(acTxt))
					else
						acLinha := substr(acLinha, 1, nPos-1) + "/"+chr(255) + substr(acLinha, nPos+len(acTxt)+1)
					endif
				endif
			endif

			if alOnlyOne
				exit
			endif
		else
			acLinha := substr(acLinha, 1, nPos-1) + chr(255) + substr(acLinha, nPos+len(acTxt))
		endif
	enddo

	acLinha := strTran(acLinha, "/"+chr(255), cEndTag + " ")
	acLinha := strTran(acLinha, chr(255), acTxt)
	                
	if alNewPar .and. alProc
		acLinha += "</p>"
	endif

return acLinha

function txtLink2Html(alProc, acLinha) 
	local nPosI, nPos, nPosF
	
	alProc := .f.
				
	acLinha := alltrim(acLinha)
	while (nPosI := at("[link:", acLinha)) > 0
		alProc := .t.
		nPosF := at("]", acLinha)
		cAux := substr(acLinha, nPosI, nPosF - nPosI)                         
		
		nPos := at(" ", cAux)
		if nPos != 0
			cAux := "<a class='stxLink' href='" + substr(cAux, 7, nPos-1)+"' target='_blank'"
			cAux += ' onmouseover=' + ASPAS_D + "window.status='"+substr(cAux, nPos+1)+"';return true;" + ASPAS_D
			cAux += ">"+substr(cAux, nPos+1)
			cAux := left(cAux, len(cAux)-1) + "</a>"
		else
			cAux := substr(cAux, 7, len(cAux)-8)
			cAux := "<a href='" + cAux +"'" +;
					' onmouseover=' + ASPAS_D + "window.status='"+substr(cAux, nPos+1)+"';return true;" + ASPAS_D +;
					">"+cAux+"</a>"
		endif			
		acLinha := substr(acLinha, 1, nPosI-1) + cAux + substr(acLinha, nPosF+1)
	enddo
	
return acLinha

function txtImg2Html(alProc, acLinha)
	local nPosI, nPosF
	local cStyle := "stxImg"
		
	alProc := .f.
				
	acLinha := alltrim(acLinha)
	while (nPosI := at("[img:", acLinha)) > 0
		alProc := .t.
		nPosF := at("]", acLinha)
		cAux := substr(acLinha, nPosI, nPosF - nPosI)
		if right(cAux,1) == "1" // alinhamento a esquerda
			cStyle := "stxImgLeft"
		elseif right(cAux,1) == "2" // alinhamento a direita
			cStyle := "stxImgRight"
		else
			cAux += "  "
		endif
					
		cAux := tagImage(substr(cAux, 6, len(cAux)-7), -1, -1, , , "#"+cStyle)
		acLinha := substr(acLinha, 1, nPosI-1) + cAux + substr(acLinha, nPosF+1)
	enddo
	
return acLinha

function txtMail2Html(alProc, acLinha)
	local nPosI, nPos, nPosF, cAux, cAux2
	
	alProc := .f.
				
	acLinha := alltrim(acLinha)
	while (nPosI := at("[email:", acLinha)) > 0
		alProc := .t.
		nPosF := at("]", acLinha)
		cAux := substr(acLinha, nPosI+1, nPosF - nPosI - 1)
		nPos := at(" ", cAux)
		if nPos != 0
			cAux2 := "<a class='stxEMail' href='mailto:" + substr(cAux, 7, nPos-7)+"'>"
			cAux2 += tagImage("email.gif", 15, 18, STR0193+" "+substr(cAux, nPos)) +"&nbsp;<span class='stxEMailEx'>"+substr(cAux, nPos)+"</span>" //###"Enviar e-mail para"
			nPos++
		else
			cAux2 := "<a class='stxEMail' href='mailto:" + substr(cAux, 7)+"'>"
			cAux2 += tagImage("email.gif", 15, 18, STR0193+" "+substr(cAux, 7)) //###"Enviar e-mail para"
		endif			
		cAux2 += "</a>"
		acLinha := substr(acLinha, 1, nPosI-1) + cAux2 + substr(acLinha, nPosF+1)
	enddo
	
return acLinha

function txtRef2Html(alProc, acLinha, aaRefs)
	local nPosI, nPosF
	
	alProc := .f.
				
	acLinha := alltrim(acLinha)
	while (nPosI := at("[", acLinha)) > 0
		alProc := .t.
		nPosF := at("]", acLinha)
		cAux := substr(acLinha, nPosI+5, nPosF - nPosI - 5)
		aAdd(aaRefs, cAux)
		cAux := "<a class='stxRef' href='#ref" + int2Hex(len(aaRefs), 3) + "' name=ret" + int2Hex(len(aaRefs), 3) + ">" + chr(255) + dwStr(len(aaRefs)) + chr(254) + "</a>"
		acLinha := substr(acLinha, 1, nPosI-1) + cAux + substr(acLinha, nPosF+1)
	enddo

	if alProc
		acLinha := strtran(acLinha, chr(255), "[")
		acLinha := strtran(acLinha, chr(254), "]")
	endif
	
return acLinha

function txtRet2Html(acLinha, anNumber)
	local cNumber := dwInt2Hex(anNumber	,3)
	
	cAux := alltrim(acLinha)
	cAux := "<a class='stxNote' href'=#ret" + cNumber + "' name=ref" + cNumber + ">[" + dwStr(anNumber) + "]</a>" +;
				"<span class='stxNote'>" + cAux + "</span><br>"
	
return cAux


function schema2Html(aaText, anLinha, aaSchema)
	local cAux := ""

	anLinha++
	while !(left(aaText[anLinha], 14) == "[showSchemaEnd")
		aAdd(aaSchema, aaText[anLinha])
		anLinha++
	enddo
	
	cAux := substr(aaText[anLinha], 16)
	cAux := substr(cAux, 1, len(cAux) - 1)
	                                                                               
	//não colocar a unidade de medida, a mesma SEMPRE será px
	cAux := CRLF+"<canvas id='can"+cAux+"' width='400' height='400'></canvas>"+CRLF
return cAux

/*
--------------------------------------------------------------------------------------
Converte textos estruturados em HTML
--------------------------------------------------------------------------------------
*/
function DWTxt2Html(aaBuffer, aaText)
	local nInd, cLinha, lProc := .f., lCanClose := .t.
	local aList := {}, aSchema := {}
	local aBuffer := {}, aText
	local lBuffer := .t.
	local aRefs := {}, lParag := .t.
		
	if valType(aaBuffer) == "U"
		aaBuffer := aBuffer
		lBuffer := .f.
	endif

	if valType(aaText) == "C"
		aaText := { aaText }
	endif

	aText := aClone(aaText)
  	if len(aText) < 2
	  	lParag := .f.
	endif
	
	aAdd(aText, "")
	
	for nInd := 1 to len(aText) - 1
		lCanClose := len(aList) > 0
		cLinha := aText[nInd]

		if !empty(cLinha)
			// formatação de texto
			cLinha := txtStr2Html(@lProc, .f., "**", "<b>", .t., cLinha) // ** negrito
			cLinha := txtStr2Html(@lProc, .f., "*", "<i>", .t., cLinha)  // * italico
			cLinha := txtStr2Html(@lProc, .f., "_", "<u>", .t., cLinha)  // * sublinhado
			
			// especiais
			cLinha := txtMail2Html(@lProc, cLinha) // ** eMail
			cLinha := txtLink2Html(@lProc, cLinha) // ** link
			cLinha := txtImg2Html(@lProc, cLinha) // ** image
		endif   

		// paragrafo (linha em branco)
		if empty(cLinha)
		// linha horizontal
		elseif cLinha == "---"
			cLinha := "<hr class='stxHorzLine' noshade size='1'>"
		// acrescenta a indicação da posição do schema da dimensão/cubo
		elseif cLinha == "[schema]"
			cLinha := tagImage('schema.gif', -1, -1, , , "#stxSchema")
		// desenha o schema do objeto
		elseif cLinha == "[showSchemaBegin]"
			cLinha := schema2Html(aText, @nInd, aSchema)
			lCanClose := .t.
		// inicio de identação (] na linha)
		elseif cLinha == "]" 
			cLinha := "<blockquote class='stxIdent'>"
		// fecha identação ([ na linha)
		elseif cLinha == "["
			cLinha := "</blockquote>"
		// titulo ou sub-titulo (linha sem ponto-final (.) e seguida de uma linha em branco)
		elseif !(left(cLinha, 1) == ".") .and. !(right(cLinha,1) == ".") .and. (empty(aText[nInd+1]) .and. lParag)
			// sub-titulo começa com =
			if left(cLinha, 1) == "="                                
				cLinha := "<p class='stxSubTitle'>"+substr(cLinha,2)+"</p>"
			else
				cLinha := "<p class='stxTitle'>"+cLinha+"</p>"
			endif
			nInd++
		// lista (começa com '. ' e seguida de linha em branco)
		elseif /*empty(aText[nInd+1]) .and.*/ left(cLinha, 1) == "." .and. ;
				(left(cLinha,2) == ". "  .or. left(cLinha,3) == ".1 " .or.;
				left(cLinha,3) == ".I " .or. left(cLinha,3) == ".i " .or.;
				left(cLinha,3) == ".o " .or. left(cLinha,3) == ".x " .or.;
				left(cLinha,3) == ".A " .or. left(cLinha,3) == ".a ")
					lCanClose := .f.
  					if len(aList) == 0 .or. !(left(cLinha, 2) == ". ")
		    			// lista bullet (disco) (1o item começa com '. ')
						if left(cLinha, 2) == ". "
				  			aAdd(aList, { "ul", "stxList" })
		    			// lista numerada (1o item começa com '.1 ')
						elseif left(cLinha, 3) == ".1 "
				  			aAdd(aList, { "ol", "stxListNumber" })
		    			// lista alpha (1o item começa com '.a ')
						elseif left(cLinha, 3) == ".a "
				  			aAdd(aList, { "ol", "stxListAlpha" })
		    			// lista romana (1o item começa com '.i ')
						elseif left(cLinha, 3) == ".i "
				  			aAdd(aList, { "ol", "stxListRoman" })
				 		endif
						cLinha := "<"+aTail(aList)[1]+" class='"+aTail(aList)[2]+"'>"+CRLF+"<li>"+substr(cLinha,3)+"</li>"
					else
						cLinha := "<li>"+substr(cLinha,3)+"</li>"
					endif
		else
			//TODO Analisar a necessidade de utilização.     
        	cLinha := txtRef2Html(@lProc, cLinha, aRefs) //Marcas de referência.	      
		endif

		if lCanClose
			if len(aList) > 0
				cLinha += CRLF+"</"+aTail(aList)[1]+">"
				aSize(aList, len(aList)-1)
			endif
		endif

		if empty(cLinha)
			if len(aaBuffer) > 0
				aaBuffer[len(aaBuffer)] := aaBuffer[len(aaBuffer)] + "</p>"
			else
				aAdd(aaBuffer, "</p>")
			endif
		else
			aAdd(aaBuffer, cLinha)
		endif
	next

	while len(aList) > 0
		aAdd(aaBuffer, "</"+aTail(aList)[1]+">")
		aSize(aList, len(aList)-1)
	enddo

	if len(aRefs) > 0
		aAdd(aaBuffer, "<hr class='stxRefSep' noshade size='1'>")
		for nInd := 1 to len(aRefs)
			aAdd(aaBuffer, txtRet2Html(aRefs[nInd], nInd))
		next
	endif

	if len(aSchema) > 0
		aAdd(aaBuffer, tagJS())

		for nInd := 1 to len(aSchema)
			aAdd(aaBuffer, aSchema[nInd])
		next

		aAdd(aaBuffer, "function u_drawFunctions()")
		aAdd(aaBuffer, "{")

		if isInternetExplorer()
			//Intervalo pre-definido em 1 seg.
			aAdd(aaBuffer, "  oControl = setInterval('drawRoutines()', 1000);")
		endif

		aAdd(aaBuffer, "}")
		aAdd(aaBuffer, "</script>")
	endif
		
return iif(lBuffer, nil, dwConcatWSep(CRLF, aaBuffer))

/*
-----------------------------------------------------------------------
Executa o codeBlock para todos os datawares-houses do SigaDW
-----------------------------------------------------------------------
*/
function DWProcAllDW(acbFuncUpd, alSelectDW)
	local nInd, aAux

	default alSelectDW :=.t.
  	
  	aAux := oSigaDW:DWList():faItems
	if len(aAux) > 0
		for nInd := 1 to len(aAux)
			if !DWKillApp()
				conout(".. " + STR0194 + " " + dwStr(aAux[nInd,1]) + "-" + oSigaDW:DWList():faItems[nInd, 2]) //###"Processando DW"
				if alSelectDW
					oSigaDW:SelectDW(aAux[nInd, 2])
				endif
				eval(acbFuncUpd, aAux[nInd, 2])
			else
				conout("=========================================================================")
				conout(STR0195 + " KILLAPP") //###"Processo cancelado por recebimento de mensagem"
				conout("=========================================================================")
			endif
		next  
	endif

return
         
function DWProc2AllDW(acbFuncUpd)
	local nInd
	
	private oSigaDW := TSigaDW():New()

	if len(oSigaDW:DWList():faItems) > 0
		for nInd := 1 to len(oSigaDW:DWList():faItems)
			if !DWKillApp()
				conout(".. " + STR0194 + " " + chr(nInd + 47) + "-" + oSigaDW:DWList():faItems[nInd, 2]) //###"Processando DW"
				eval(acbFuncUpd, oSigaDW:DWList():faItems[nInd, 1])
			else
				conout("=========================================================================")
				conout(STR0195 + " KILLAPP") //###"Processo cancelado por recebimento de mensagem"
				conout("=========================================================================")
			endif
		next  
	endif

return

/*
-----------------------------------------------------------------------
Força a execução de um agendamento qualquer
-----------------------------------------------------------------------
*/
function DWExecSched(acCodExec)
	local oSched

	oSched := twfscheduler():new( { cEmpAnt, cFilAnt } )

return oSched:ExecTask(acCodExec)

/*
-----------------------------------------------------------------------
Verifica se a execução é por web
-----------------------------------------------------------------------
*/
function DWisWebEx()
return left(getWebJob(),9)  <> "WFONSTART" .and. right(getWebJob(),1)  <> "_"
                  
/*
----------------------------------------------------------------------
Verifica se a execução é por Scheduler
----------------------------------------------------------------------
*/
function dwIsScheduler()
return "WFLAUNCHER" $ upper(DWCallStack(,,.f.))

/*
-----------------------------------------------------------------------
Manipulação de bits
-----------------------------------------------------------------------
*/                          
#define BIT_NUMBERS 8
          
function dwInt2BitA(anValue)
	local aBits := array(BIT_NUMBERS), nInd
	local nValue := int(anValue), cResto := ''

	while nValue > 0 
		cResto := iif(nValue % 2==1, "1", "0") + cResto
		nValue := int(nValue / 2)
	end            
	cResto := right(replicate("0", BIT_NUMBERS) + cResto, BIT_NUMBERS)
	
	for nInd := 1 to BIT_NUMBERS
		aBits[nInd] := substr(cResto, nInd, 1)
	next
	
return aBits

function dwBitA2Int(aaValue)
	local nValue := 0, nInd
	
	for nInd := 1 to BIT_NUMBERS
		if aaValue[nInd] == '1'
			nValue += (2 ** (BIT_NUMBERS - nInd))
		endif
	next
	
return nValue

function DWsetBit(anValue, anBit, acBit)
	local aBits := dwInt2BitA(anValue)
	                               
	aBits[BIT_NUMBERS-anBit + 1] := acBit
	
return dwBitA2Int(aBits)

function DWsetBitOn(anValue, anBit)
return DWsetBit(anValue, anBit, '1')

function DWsetBitOff(anValue, anBit)
return DWsetBit(anValue, anBit, '0')

function DWtestBit(anValue, anBit)
	local aBits := dwInt2BitA(anValue)
	
return aBits[BIT_NUMBERS-anBit + 1] == '1'
		
/*
-----------------------------------------------------------------------
Le, grava e remove dados na sessão por "programa"
-----------------------------------------------------------------------
*/                                              
#define ID_PROCNAME  1
#define ID_VALUELIST 2
#define ID_NAME      1
#define ID_VALUE     2

function DWExistProp(acName, acProcName)
	local lRet := .f.
	local aPropList, nPos
	
	if valType(HttpSession->DWPropList) == "A"
		acProcName := upper(acProcName)
		acName := upper(acName)
		aPropList := HttpSession->DWPropList
	
		nPos := ascan(aPropList, { |x| x[ID_PROCNAME] == acProcName } )
		if nPos != 0
			aValueList := aPropList[nPos, ID_VALUELIST]
			lRet := ascan(aValueList, { |x| x[ID_NAME] == acName } ) <> 0
		endif		
	endif
		
return lRet

function DWGetProp(acName, acProcName)
	local nPos, aPropList, aValueList
	local xRet := NIL
	                                    
	default acProcName := procName(1)
	
	if valType(HttpSession->DWPropList) == "A"
		acProcName := upper(acProcName)
		acName := upper(acName)
		aPropList := HttpSession->DWPropList
	
		nPos := ascan(aPropList, { |x| x[ID_PROCNAME] == acProcName } )
		if nPos != 0
			aValueList := aPropList[nPos, ID_VALUELIST]
		
			nPos := ascan(aValueList, { |x| x[ID_NAME] == acName } )
			if nPos != 0
				xRet := aValueList[nPos, ID_VALUE]

				#ifdef DWCACHE
				#else
					if valType(xRet) == "C" .and. "CLASSNAME" $ xRet .and. "_" $ xRet
						xRet := DWStr2Obj(xRet)
					endif
				#endif				
			endif
		endif		
	endif		

return xRet

function DWSetProp(acName, axValue, acProcName)
	local aPropList, nPos, aValueList

	default acProcName := procName(1)

	acProcName := upper(acProcName)
	acName := upper(acName)

	if !(valType(HttpSession->DWPropList) == "A")
		HttpSession->DWPropList := {}
	endif
	aPropList := HttpSession->DWPropList		

	nPos := ascan(aPropList, { |x| x[ID_PROCNAME] == acProcName } )
	if nPos == 0
		aValueList := {}
		aAdd(aPropList, { acProcName, aValueList})
	else
		aValueList := aPropList[nPos, ID_VALUELIST]
	endif		
		
	nPos := ascan(aValueList, { |x| x[ID_NAME] == acName } )
	if nPos == 0
		aAdd(aValueList, { acName, nil } )
		nPos := len(aValueList)
	endif

	#ifdef DWCACHE
		if (valType(axValue) == "A")
	#else	
		if (valType(axValue) == "O")
			aValueList[nPos, ID_VALUE] := axValue:asString()
		elseif (valType(axValue) == "A")
	#endif
			aValueList[nPos, ID_VALUE] := aClone(axValue)
		else
			aValueList[nPos, ID_VALUE] := axValue
		endif
return

function DWDelProp(acName, acProcName)
	local aPropList, nPos, aValueList

	default acProcName := procName(1)

	acProcName := upper(acProcName)
	acName := upper(acName)

	if valType(HttpSession->DWPropList) == "A"
		aPropList := HttpSession->DWPropList		

		nPos := ascan(aPropList, { |x| x[ID_PROCNAME] == acProcName } )
		if nPos != 0
		    if valType(acName) == "U"
		    	aDel(aPropList, nPos)
		    	aSize(aPropList, len(aPropList)-1)
		    else
				aValueList := aPropList[nPos, ID_VALUELIST]
		    
				nPos := ascan(aValueList, { |x| x[ID_NAME] == acName } )
				if nPos != 0
		    		aDel(aValueList, nPos)
		    		aSize(aValueList, len(aValueList)-1)
				endif
			endif
		endif
	endif
	
return

/*
-----------------------------------------------------------------------
Elimina tabelas fisicamente
-----------------------------------------------------------------------
*/                          
function DWDropTable(acTable)

    if TCCanOpen(acTable)
     	TCDelFile(acTable)
    endif

return

/*
-----------------------------------------------------------------------
Retorna o texto referente a quebra de data utilizada
-----------------------------------------------------------------------
*/
function DWDtQuebra(anValor, acDelimIni, acDelimFim)
   	local cRet := ""
   
   	default acDelimIni := "("
   	default acDelimFim := ")"
      
   	if anValor > 0
		cRet := acDelimIni + DT_FIELDS[anValor+1] + acDelimFim
   	endif
return cRet                               

/*
-----------------------------------------------------------------------
Retorna o endereço da homePage
-----------------------------------------------------------------------
*/
function DWHomePage()
	local cRootPath
	
	if empty(__DWHomePage)
		__DWHomePage := getWebHost()
		if right(__DWHomePage,1) == "/" .or. right(__DWHomePage,1) == "\"
			__DWHomePage := substr(__DWHomePage, 1, len(__DWHomePage)-1)
		endif
		
		__DWHomePage := alltrim(getPvProfString(__DWHomePage, "path", "", DWIniFile()))
		if empty(__DWHomePage)
			conout("**********************************************************")
			conout(STR0117)
			conout(STR0118)
			conout(STR0119)
			conout("-----------------------------------------------------------")
			conout(STR0120)
			conout("**********************************************************")
		endif
		cRootPath := getSrvProfString("RootPath", "")

		if len(cRootPath) > 0
			if right(cRootPath,1) == "/" .or. right(cRootPath,1) == "\"
				cRootPath := substr(cRootPath, 1, len(cRootPath)-1)
			endif
			__DWHomePage := strTran(upper(__DWHomePage), upper(cRootPath), "")
		endif
	endif

return __DWHomePage

/*
-----------------------------------------------------------------------
Retorna o nome do campo D_E_L_E_T_
-----------------------------------------------------------------------
*/
function DWDelete()
	local cRet := 'D_E_L_E_T_'
   
	//----------------------------------------------
	// Valida o banco de dados utilizado, para  
	// tratamento do campo D_E_L_E_T_.
   	//----------------------------------------------
	if SGDB() == DB_DB2400
   		// Verifica se está utilizando o Top 2
   		If TCSrvType() == 'AS/400' 
      		cRet := '@DELETED@'
      	EndIf
   	EndIf
Return cRet

/*
-----------------------------------------------------------------------
Retorna o nome do campo C_U_R_V_A_A_B_C_
-----------------------------------------------------------------------
*/
function DWCurvaABC()
return 'C_U_R_V_A_A_B_C_'

/*
-----------------------------------------------------------------------
Retorna informações sobre a fonte de dados corrente
-----------------------------------------------------------------------
*/
function DWDSTipo()
	local oTab := initTable(TAB_DSN)
return oTab:value("tipo")

function DWDSNome()
	local oTab := initTable(TAB_DSN)
return oTab:value("nome")

function DWDSDescricao()
	local oTab := initTable(TAB_DSN)
return oTab:value("descricao")

function DWDSConector()
	local oTab := initTable(TAB_DSN)
return oTab:value("connector")

function DWDSTipoConn()
	local oTab := initTable(TAB_DSN)
return oTab:value("tipo_text")

function DWDSBancoSrv()
	local oTab := initTable(TAB_DSN)
return oTab:value("banco_srv")

function DWDSConexSrv()
	local oTab := initTable(TAB_DSN)
return oTab:value("conex_srv")

function DWDSAliasTC()
	local oTab := initTable(TAB_DSN)
return oTab:value("aliasTOP")

function DWDSServer()
	local oTab := initTable(TAB_DSN)
return oTab:value("server")

function DWDSEnvironment()
	local oTab := initTable(TAB_DSN)
return oTab:value("ambiente")

function DWDSAlias()
	local oTab := initTable(TAB_DSN)
return oTab:value("alias")

function DWDSEmp()
	local oTab := initTable(TAB_DSN)
return dwEmpresa(oTab:value("empfil"))

function DWDSFil()
	local oTab := initTable(TAB_DSN)
return dwFilial(oTab:value("empfil"))

function DWDSCaminho()
	local oTab := initTable(TAB_DSN)
return oTab:value("caminho")

function DWDSArquivo()
	local oTab := initTable(TAB_DSN)
return oTab:value("arquivo")

function DWDSTmpArq()
	local oTab := initTable(TAB_DSN)
	local cRet := "TMPDW"
	
	cRet += DWDSEmp()
	cRet += DWDSFil()
	cRet += int2Hex(oTab:value("id"), 3)
	
return cRet

function DWWebSitePath()
return strTran(lower(DWWebPath()), lower(DWRootPath()), "")
/*
-----------------------------------------------------------------------
Retira caracteres especificos de uma string, trocando, quando o caso
por um equivalente
-----------------------------------------------------------------------
*/
function dwStripChr(acValue)
  	local cRet := acValue
  
  	cRet := strTran(cRet, chr(9)	, " ") // tab -> 1 espaço
  	cRet := strTran(cRet, CRLF	, " ") // CR+LF -> 1 espaço 
return cRet

/*
-----------------------------------------------------------------------
Calcula uma previsão de tempo
-----------------------------------------------------------------------
*/
function dwPrevTime(adDtInic, acHrInic, pnQtde, pnTotRec, acPrev, acDuracao)
  	local nSecIni := dwElapSecs(adDtInic, "00:00:00", adDtInic, acHrInic)
	local nSecAux := dwElapSecs(adDtInic, acHrInic, date(), time())

	acPrev := ""
	acDuracao  := ""

	nSecAux := (nSecAux / pnQtde) * pnTotRec

  	acDuracao := DWSecs2Str(nSecAux, .t.)
	acPrev := DWSecs2Str(nSecAux + nSecIni, , .t.) 
          
return 

/*
-----------------------------------------------------------------------
Realiza a remoção de caracteres especiais
Parametros:
  acValueToTransform, string, valor a ser tratado
  alAsc0_31, logico, indica se caracteres na faixa ASCII 0 a 31 devem ser eliminados. Padrão .F.
Retorno:
  string, valor tratado  
-----------------------------------------------------------------------
*/
function removeSpecialCharacteres(acValueToTransform, alAsc0_31)
	Local cSpecCharc := "'(!$¨^~&()+\=[]{}/?:><,;`´"
	Local cReturn	 := ""
	Local nInd, cAux, nLenStr

  	default alAsc0_31 := .f.
	
  	nLenStr := len(acValueToTransform)
  	
	for nInd := 1 to nLenStr
		cAux := substr(acValueToTransform, nInd, 1)
		if !(cAux $ cSpecCharc .or. cAux $ '"')
			cReturn += substr(acValueToTransform, nInd, 1)
		endif
	next
	
  	if alAsc0_31
  		for nInd := 0 to 31
			cReturn := strTran(cReturn, chr(nInd), "")
    	next
  	endif	

return cReturn

/*
--------------------------------------------------------------------------------------
Function genérica para verificação da build para o site do sigadw
Args: aoObj -> objecto, objeto a ser liberado
Ret: retorna true caso seja compativel/válida. False caso contrário.
--------------------------------------------------------------------------------------
*/
function isWebSiteUpdated()
	Local lWebUpdated
	Local oUser, cPwsd
	
	// VERIFICA SE JÁ CHECOU O SITE PARA O USUÁRIO LOGADO
	If !(GetGlbValue("WebSiteChecked" + DwStr(HttpSession->SessionID)) == "CHECKED")
		conout(replicate("-", 70))
		conout(padc(STR0198, 70)) //###"Verificando WebSite do SigaDW"
		conout(replicate("-", 70))

		// VERIFICA SE ESTÁ ATUALIZADO
		lWebUpdated := isBuildWebValid( buildDwFromArquive() )

 		// Verifica se o arquivo de internacionalizaçao de .js está atualizado.           
		If !(GetGlbValue("jsLanguageChecked") == "CHECKED") .and. !validJSLanguage()
      		dWLog(STR0206)
	    	makeJSLanguage() 
	  		PutGlbValue("jsLanguageChecked", "CHECKED")
	  	endIf 

		// SE ESTÁ ATUALIZADO, SINALIZA QUE JÁ VERIFICOU O SITE PARA O USUÁRIO LOGADO
		If lWebUpdated
			PutGlbValue("WebSiteChecked" + DwStr(HttpSession->SessionID), "CHECKED")   
		// senão estiver atualizado, verifica pela chave de emergência
		ElseIf !empty(cPwsd := GetPvProfString(getWebHost(), "BuildWebEmerg", "", DWIniFile()))
			conout(replicate("-", 70))
			conout(STR0199) //###"Atenção: Site do SigaDW DESATUALIZADO. CONFERINDO CHAVE DE EMERGÊNCIA."
		
			oUser := InitTable(TAB_USER)
			oUser:Seek(3, { "DWADMIN" })
			If !oUser:EoF() .and. oUser:value("login") == "DWADMIN"
				If dwValidBD(cPwsd, oUser:value("email"), getWebHost())
					lWebUpdated := .T.
					conout(STR0200) //###"Chave Emergencial CONFERE"
					PutGlbValue("WebSiteChecked" + DwStr(HttpSession->SessionID), "CHECKED")
				Else
					conout(STR0201) //###"Chave Emergencial NAO CONFERE"
				EndIf
			EndIf
			conout(replicate("-", 70))
		EndIf
	Else
		lWebUpdated := .T.
	EndIf
	
return lWebUpdated

/*
--------------------------------------------------------------------------------------
Function de uso interno para retornar um objeto do tipo File para o arquivo contendo a
	build para o site do SigaDW
Args:
Ret: aoObj -> objecto, objeto do tipo File
--------------------------------------------------------------------------------------
*/
static function buildDwFromArquive()
	Local oFile := webBuildArquive()
	Local cReturn := ""
	
	if valType(oFile) == "O"
		oFile:Read(@cReturn, 12)
		oFile:Close()
	endif
	
return cReturn

/*
--------------------------------------------------------------------------------------
Function de uso interno para construir e abrir o arquivo contendo a build para o site do SigaDW
Args:
Ret: aoObj -> objecto, objeto do tipo File
--------------------------------------------------------------------------------------
*/
static function webBuildArquive()
	Local cFilePath := DWWebSitePath()
	Local cTemp := CurDir()
	
	CurDir(cFilePath)
	oFile := TDWFileIO():New(cFilePath + "\build.dw")
	if oFile:Exists()
		if !oFile:IsOpen()
			oFile:Open()
		endif
	else
		oFile := NIL
	endif
	
	CurDir(cTemp)
	
return oFile

/*
--------------------------------------------------------------------------------------
Function de uso interno para processar a lógica para a validação do build do SigaDW com
	a build do site do SigaDW
Args:
Ret: retorna true, caso seja compativel/válida, false caso contrário
--------------------------------------------------------------------------------------
*/
static function isBuildWebValid(acBuildArquive)
  	local dAux := stod('20'+DWLastWebBuild())
	local cBuild := dwCripto(Year(dAux)+Month(dAux)+Day(dAux), 6)
	local lValid := .F.
	
	If empty(acBuildArquive)
		conout(STR0202) //###"Site do SigaDW Inválido. Por favor, atualize-o."
		return .F.
	EndIf
	
	// valida a build do site
	lValid := (acBuildArquive == cBuild)// .or. (acBuildArquive == '333B333A3334')
	                                          // ^^^ usado para compatibilidade com formato anterior
	                                          // na proxima alteração de BUILD_WEB retirar 
	if !lValid
    	conout(padc(STR0205, 70)) //###"Versão do Site do SigaDW DESATUALIZADA"
		conout(replicate("-", 70))
	endIf
		
	conout("")
	
return lValid

/*
--------------------------------------------------------------------------------------
Main Function para gerar uma build para o site do sigadw, exibindo a build em um msgAlert
e no console do Protheus
Args:
Ret:
--------------------------------------------------------------------------------------
*/
main function dwGenWebBuild()
  	local dAux := stod('20'+DWLastWebBuild())
	local cBuild := dwCripto(Year(dAux)+Month(dAux)+Day(dAux), 6)
	
	conout("SigaDW Site Build Generated: " + cBuild)
	msgAlert(cBuild)	
return

/*
--------------------------------------------------------------------------------------
Trata a mascara numérica ou de data, de acordo com o pais.
Args: acMask, string, mascara numérica ou de data
Ret: string, mascara com o tratamento para o pais
--------------------------------------------------------------------------------------
*/
function dwMask(acMask)
	local cRet := acMask

  	if DWRegLang() == "BRA"
    	if len(cRet) > 2 .and. !(left(cRet, 3) == "@E")
      		cRet := "@E " + cRet
    	endif
  	endif

return cRet

/*
--------------------------------------------------------------------------------------
Assegura que os paths utilizados na montagem de endereço completo de arquivos terminem 
com BARRA INVERTIDA. 
@Param
	 (Caracter) cPath  Path a ser tratado. 
@Return
	 (Caracter) Path tratado com BARRA INVERTIDA (Ex.: \System\)
--------------------------------------------------------------------------------------
*/
function dwFixPath(cPath)
return cPath := iif( (right(cPath,1) $ "\/"), cPath, cPath + "\" )

/*--------------------------------------------------------------------------------------
Cria um registro de LOGIN no console do Protheus.
@Param   
	(Objeto) 	oUser 	Objeto da classe TDWUser
	(Caracter )	cAgente Browser utilizado para acessar o DW 
@Return 
	(Nil) Exibe mensagem no log do Protheus
--------------------------------------------------------------------------------------*/
function dwLoginTracker(oUser, cAgente)      
   Local cUserName := oUser:UserName()  
   
   Default cAgente := 'Browser Unidentified'  

return QQOut(cUserName + STR0210 + Time() + STR0211 + cAgente + CRLF) /*USUARIO efetuou login no SIGADW às HORA utilizando AGENTE*/

//-------------------------------------------------------------------
/*/{Protheus.doc} dwCompArray
Função que faz a comparação entre dois arrays.

@param   aaArrayA Array Primeiro vetor
@param   aaArrayB Array Segundo vetor
@author  BI Team
@version P11
@since   07/08/2013
@return  lResult Valor Booleano .T. Iguais ou .F. Diferentes
/*/
//-------------------------------------------------------------------
Function dwCompArray(aaArrayA, aaArrayB)
	Local lResult	:= .F.
	Local nCnt		:= 0
	
	Default aaArrayA := {}
	Default aaArrayB := {}
	
	If !Empty(aaArrayA) .And. !Empty(aaArrayB)
		If ValType(aaArrayA) == 'A' .And. ValType(aaArrayB) == 'A'
			If Len(aaArrayA) == Len(aaArrayB) // Não permite o array out of bounds.
				For nCnt := 1 To Len(aaArrayA)
					If aaArrayA[nCnt] != aaArrayB[nCnt]
						Return .F.
					EndIf
				Next nCnt
				lResult := .T.
			EndIf
		EndIf
	EndIf
Return lResult