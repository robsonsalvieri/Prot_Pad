// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : M05 - ImpExp
// Fonte  : m05export - Efetua a exportação de dados 
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 1728 Fernando Patelli
// 10.02.06 | 0548-Alan Candido | Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "dwIdProcs.ch"
#include "m5export.ch"

#define FLAG_NOTIFICAR "<!--NOTIFICAR "

function m05export(anID, acFlag, acIPCId, anTipo, aaInfo)
local nID, cMsg := "", oMakeExp, lExcel, cFilename
local cbAux := { | anTypeRec, axP1, axP2, axP3| ShowMsg(anTypeRec, axP1, axP2, axP3) }
local cType
local bLogFile
local cNotificar := ""
local oFile

private cLogFile
private aNotificar := oSigaDW:Notify()
private cIPCId := upper(allTrim(acIPCId))

// Verifica a opção de gerar log de importações/exportações (propriedade "Log de Importação/Exportações")
If oSigaDW:LogImpExp()
	cType := "EXP" + DwInt2hex(anID, 8) + DwStr(anTipo) + oSigaDW:DWCurr()[2]
	bLogFile := { |xMsg, cTitle| oSigaDW:LogEvent(xMsg+"</br>", cTitle, cType, cLogFile) }
	eval(bLogFile, dwFormat("\[[@]] " + STR0001, {oSigaDW:DWCurr()[2]}), STR0001) //###"Exportacäo de dados"
Else
	// limpa o code block de geração de evento
	bLogFile := { |xMsg, cTitle| NIL }
	// loga o evento no sigadw, para aparecer no menu Logs do SigaDW
	oSigaDW:Log(dwFormat("\[[@]] " + STR0001, {oSigaDW:DWCurr()[2]})) //###"Exportacäo de dados"
EndIf

if len(aNotificar) <> 2
	aSize(aNotificar,2)
	aeval(aNotificar, { |x,i| iif(valType(x)=="U", aNotificar[i] := "", nil)})
endif

nID := anID
//####TODO - verificar como ficam o processo de exportação direto Excell
//preparacao
//if lExcel
oMakeExp := TMakeExp2():New(nID, cLogFile)
oMakeExp:IDTipo(nID)
oMakeExp:FileType(anTipo)
oMakeExp:MailList("")
oMakeExp:loadExportCfg()

eval(cbAux, IPC_PROCESSO, IMP_PRO_INIT, 2)

if valType(aaInfo) == "A"
	atzInfo(aaInfo, bLogFile)
endif                                                       '

oMakeExp:processExp(cbAux)

// lê e retorna o conteúdo do arquivo gerado na integração SigaDW e Excel
If oMakeExp:FileType() == FT_DIRECT_EXCEL
	
	ft_fuse(oMakeExp:WorkDir()+oMakeExp:FileName())
	while !ft_feof()
		httpSend(ft_freadln())
		ft_fskip()
	enddo
	ft_fuse()
	
	// apaga o arquivo temporário
	oFile := TDWFileIO():new(oMakeExp:WorkDir()+oMakeExp:FileName())
	If oFile:Exists()
		oFile:Erase()
	EndIf
	
EndIf


eval(cbAux, IPC_TERMINO, { oMakeExp:Workdir(), oMakeExp:filename() })
return iif(!empty(cNotificar), cLogFile, "")

static function ShowMsg(anTypeRec, axP1, axP2, axP3)

	sendIpcMsg(cIPCId, anTypeRec, axP1, axP2, axP3)

return 


static function atzInfo(aaInfo, abLogFile)

	ShowMsg(IPC_INFO, aaInfo)

	if valType(abLogFile) == "B"          
		eval(abLogFile, "</blockquote>"+buildSubTitle(STR0018)+"<blockquote>")
		aEval(aaInfo, { |x| eval(abLogFile, x)})
	endif
	
return