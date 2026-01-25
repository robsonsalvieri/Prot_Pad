// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : M04 - Tools
// Fonte  : m04Utils - Funções de extensão ao SigaDW, para uso em filtros, p.e.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.06.06 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "tbiconn.ch"
#include "dwM04Utils.ch"

/*
-----------------------------------------------------------------------------------------
Recupera parâmetros passados ao SigaDW, através de chamada pelo remoto Protheus
-----------------------------------------------------------------------------------------
*/
function DWRmtParam(acParamName, acDefault)
	local cAux
	private _cRet

	if DWisWebEx()
		cAux := "_cRet := HttpGet->rmt_"+acParamName
		&(cAux)

		if valType(_cRet) == "C"
			cAux := "HttpSession->rmt_"+acParamName+" := "+ dwStr(_cRet,.t.)
			&(cAux)
		endif

		if valType(_cRet) == "U"
			cAux := "_cRet := HttpSession->rmt_"+acParamName
			&(cAux)
		endif

	endif

	default _cRet := acDefault

return _cRet

/*
-----------------------------------------------------------------------------------------
Recupera os dados (registro) de uma dimensão especifica
-----------------------------------------------------------------------------------------
*/
function DWDimOneRec(acDimensao, aaKeysValues, aaValues)
	local lRet := .f.
	local oDim, aRecord

	if oSigaDW:Dimensao():Seek(2, { acDimensao } , .t.)
		oDim := oSigaDW:OpenDim(oSigaDW:Dimensao():value("id"))
	
		if oDim:Seek(2, aaKeysValues, .t.)
			lRet := .t.
			aRecord := oDim:Record(7, , .f.)
			aSize(aaValues, 0)
			aEval(aRecord, { |x| aAdd(aaValues, { x[1], x[2] }) })
		endif
	
		oDim:Close()
	endif

return lRet

/*
-----------------------------------------------------------------------------------------
Recupera o valor de um "campo" especifico da array. Array multi-dimensional, onde cada
item é composto por { <nome do campo>, <valor> }
-----------------------------------------------------------------------------------------
*/
function DWArrValue(aaValues, acKeyName)
	local xRet := nil
	local nPos

	acKeyName := lower(acKeyName)
	nPos := ascan(aaValues, { |x| x[1] == acKeyName })
	if nPos > 0
		xRet := aaValues[nPos, 2]
	endif

return xRet

/*
-----------------------------------------------------------------------------------------
Permite a execução de consultas pelo remote, com passagem de parametros e maior area de
ocupação da tela. <aaParams> é uma array multi-dimensional, onde cada item é composto
por { <nome do parametro>, <valor> }.
-----------------------------------------------------------------------------------------
*/
function DWRemoteEx(acHost, acDWName, acConsulta, anType, acType, aaParams, alMax, alAutoInc, acEmail)
	local o, oDlg, cTitle := acDWName + " - " + acConsulta  + " [SigaDW]"
	local cURL , nInd, nWidth := 800, nHeigth := 600
	local cHttpGet

	default acType := "P"
	default anType := 1
	default aaParams := {}
	default alMax := .t.
	default alAutoInc	 := .f.
	default acEmail := ""

	if alMax
		nWidth := 1012
		nHeigth := 584
	endif

	acType := alltrim(upper(acType))

	acType := iif(acType <> "P" .and. acType <> "U", "P", acType)
	anType := iif(anType <> 1 .and. anType <> 2,1, anType)

	if alAutoInc
		cHttpGet := httpGet( acHost + "/h_m01help.apw", "source=_autouser_" +dwEncodeParm("user",DWConcatWSep("!", {acHost, acDWName, alltrim(upper(subs(cUsuario,7,15))), time(), acEmail })) , 60 )
	endif                                                                             
	
	cURL := acHost + "/w_sigadw3.apw" + makeAction(AC_QUERY_EXEC,,.f.) + dwEncodeParm("dwacesss",DWConcatWSep("!", {acHost, upper(acDWName),  alltrim(subs(cUsuario,7,15)), time(), })) + "&consName=" + upper(acConsulta) + "&oper=6&type=" + dwstr(anType) + "&cache=0,_blank,null,winManu0CAE2,1,1,null,null,false"

	for nInd := 1 to len(aaParams)
		cURL += "&rmt_" + aaParams[nInd, 1] + "=" + URLEncode(aaParams[nInd, 2])
	next

	DEFINE MSDIALOG oDlg FROM 0, 0 TO nHeigth, nWidth TITLE cTitle PIXEL

	oDlg:lMaximized := .T.
	o:=TiBrowser():New(0,0, 10, 10, '',oDlg)
	o:Align := CONTROL_ALIGN_ALLCLIENT
	o:Navigate(cURL)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) )

return .T.

/*
-----------------------------------------------------------------------------------------
Geração de consultas direto no MS-Excel a partir do remote
-----------------------------------------------------------------------------------------
*/                                                                                                     
function DWRmtExcel(acHost, acDWName, acConsulta, anType, acType, aaParams, alAutoInc, acEmail)

  msgRun( OemToAnsi(STR0001),'', ; //###'Favor aguardar. Processando a solicitação...'
     {||DWRmt2Excel(acHost, acDWName, acConsulta, anType, acType, aaParams, alAutoInc, acEmail)})

static function DWRmt2Excel(acHost, acDWName, acConsulta, anType, acType, aaParams, alAutoInc, acEmail)
	local oExcelApp  := nil, nInd
	local cArquivo   := CriaTrab(,.F.)+".csv"
	local cLocalPath := allTrim(GetTempPath())
	local nHandle    := 0, lRet := .F.    
	local cUser      := alltrim(upper(subs(cUsuario,7,15)))

	default acType := "P"
	default anType := 1
	default aaParams := {}
	default alAutoInc := .f.
	default acEmail := ""
	
	if ApOleClient("MsExcel")
		if alAutoInc
			cHttpGet := httpGet( acHost + "/h_m01help.apw", "source=_autouser_" +dwEncodeParm("user",DWConcatWSep("!", {acHost, acDWName, alltrim(upper(subs(cUsuario,7,15))), time(), acEmail })) , 60 )
		endif
	
		if (nHandle := FCreate(cLocalPath + "\"+cArquivo)) > 0
			// prepara arquivo de parametros para ser lido pelo MS-Excel
			fwrite(nHandle, "PARAM;VALUE" + CRLF)
			fwrite(nHandle, "USER;"+ cUser + CRLF)
			fwrite(nHandle, "HOST;"+ acHost + CRLF)
			fwrite(nHandle, "DW;"+ acDWName + CRLF)
			fwrite(nHandle, "QUERY;"+ acConsulta + CRLF)
			fwrite(nHandle, "TYPE_QUERY;"+ dwStr(anType) + CRLF)
			fwrite(nHandle, "TYPE;"+ acType + CRLF)
			fwrite(nHandle, "PARAMS;")
			for nInd := 1 to len(aaParams)
				fwrite(nHandle, "&rmt_" + aaParams[nInd, 1] + "=" + URLEncode(dwStr(aaParams[nInd, 2])))
			next
			fwrite(nHandle, ";"+CRLF)
			fclose(nHandle)
		
			// copia o arquivo de integração do remote->MS-Excel->SigaDW
			CpyS2T("\dwexcel.xls", cLocalPath, .T.)
		
			// inicia a execução do MS-Excel
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(cLocalPath + "\" + cArquivo)
			oExcelApp:WorkBooks:Open(cLocalPath + "\dwexcel.xls")
			oExcelApp:SetVisible(.T.)
		
			lRet := .T.
		else
			msgStop(STR0002) //###"Não foi possivel iniciar arquivo de comunicação com MS-Excel."
		endif
	else
		msgStop(STR0003) //###"MS-Excel nao acessivel."
	endIf

return lRet
/*
function TSTRMT()
DWRemoteEx("http://localhost", "teste", "acum", 1, "P", , , .t.)
return
*/

function tstExcel()
	DWRmtExcel("http://localhost", "teste", "acum", 1, "P", {{ "UF", "SP"}} , .t.)
return