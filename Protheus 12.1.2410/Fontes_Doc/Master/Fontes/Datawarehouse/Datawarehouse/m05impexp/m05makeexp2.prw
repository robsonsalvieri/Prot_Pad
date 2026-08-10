// ######################################################################################
// Projeto: DATAWAREHOUSE
// Modulo : MakeExp
// Fonte  : MakeExp - Classe para execução de exportações
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 05.02.03 | 1728 Fernando Patelli
// 10.02.06 | 0548-Alan Candido | Versão 3
// 28.09.07 | 0548-Alan Candido | BOPS 132327 - Integração com Excel, não enviava as linhas de dados
// 05.08.08 |0548-Alan Cândido  | BOPS 151288
//          |                   | Correção na formatação de indicadores de participação.
// 25.09.08 |0548-Alan Cândido  | BOPS 154605 (P9.12) e 154610 (P8.11)
//          |                   | . Correção no envio de caracteres de controle indevidos para a
//          |                   | integração Excel
//          |                   | . Ajuste de tratamento efetuado no método ::DescType()
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | . Adequação de geração de máscara em campos numéricos e datas, 
//          |                   | para respeitar o formato conforme idioma 
//          |                   | (chave RegionalLanguage na sessão do ambiente).
//          |                   | . Implementação da propriedade percIsInd()
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#INCLUDE "XMLXFUN.CH"
#include "m5mkexp.ch"
#define NO_SEND_DATA chr(253)

/*
-----------------------------------------------------------------------------------------
Identificador do array de estilos (style) para geração xml
-----------------------------------------------------------------------------------------
*/
#define ID_PARENT   1
#define ID_MASK     2

/*
--------------------------------------------------------------------------------------
Classe: TMakeExp
Uso   : Execução de exportações
--------------------------------------------------------------------------------------
*/
class TMakeExp2 from TDWObject
	data fcLogFile
	data fnTipo
	data fnID
	data fnIDTipo
	data fcWorkDir
	data fcFileName
	data fnFileType
	data foFileHandle
	data fcMailList
	data flMzp
	data fnLines
	data fnWriten
	data fnSentPerc
	data fbBeforeExec
	data fbAfterExec
	data flShowZero
	data flHideTotals
	data flHideEquals
	data flShowHeaders
	data flShowFiltering
	data flShowFormat
	data flPercIsInd
	data flExpAlert
	data faStyles
	data faAlerts
	data fcFieldSeparator
	data faInfoArray

	method New(anID, acLogFile) constructor
	method Free()
	method NewMakeExp2(anID, acLogFile)
	method FreeMakeExp2()
	method loadExportCfg()

	method WorkDir(acWorkDir)
	method FileName(acValue)
	method FileType(anValue)
	method Mzp(alValue)
	method FieldSeparator(acValue)
	method HideTotals(alValue)
	method HideEquals(alValue)
	method ShowHeaders(alValue)
	method ShowFiltering(alValue)
	method ShowZero(alValue)
	method BeforeExec(abValue)
	method AfterExec(abValue)
	method MailList(acValue)
	method InfoArray(aaValue)
	method DescType() 
	method IDTipo(anValue)
	method ShowFormat(alValue)
	method percIsInd(alValue)
	method ExpAlert(alValue)
	
	method ProcessExp(abLog)
	method WriteInit(anLines, aHeader, acWorksheetName, alDimOrCube) 
	method WriteLn(aaCels)
	method WriteFinish(aFooter)
	method addStyle(acParentStyle, acAdvPLMask)
 	method addAlert(acAlertID, acMsg)
 	method ExportDim(abLog)
	method ExportCube(abLog)

endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(anID, acLogFile) class TMakeExp2

	::NewMakeExp2(anID, acLogFile)

return
	 
method Free() class TMakeExp2

	::FreeMakeExp2()

return

method NewMakeExp2(anID, acLogFile) class TMakeExp2

	::NewObject() 
	
	::fcLogFile := acLogFile
	::fnID := anID
	::fnTipo := -1
	::fnIDTipo := -1
	::fcWorkDir := ""
	::fcFileName := ""
	::fnFileType := 0
	::foFileHandle := NIL
	::fbBeforeExec := NIL
	::fbAfterExec := NIL
	::flMzp := .f.
	::fcFieldSeparator := ","
	::flHideTotals := .f.
	::flHideEquals := .f.
	::flShowHeaders := .f.
	::flShowFiltering := .f.
	::flShowFormat := .f.
	::flPercIsInd := .f.
	::flExpAlert := .f.
	::flShowZero := .f.
	::fnLines := 0
	::fnWriten := 0
	::fnSentPerc := 0
	::faStyles := {}
	::faAlerts := {}
	
	::loadExportCfg()
	
return
	 
method FreeMakeExp2() class TMakeExp2

	::FreeObject()
	
return

method loadExportCfg() class TMakeExp2
	
	Local oExport 	:= InitTable(TAB_EXPORT)
	Local oConsulta := InitTable(TAB_CONSULTAS)  
	Local aTypes 	:= dwComboOptions(FILE_TYPES)
	
	if ::fnIDTipo < 0 .and. ::fnTipo == EX_CON //####TODO verificar como executar exportação direto Excel
		::fnIDTipo := abs(::fnIDTipo)
	elseif ::FileType() == FT_DIRECT_EXCEL
		// não possui configuração para ler do banco
		::WorkDir(DwTempPath())
		oConsulta:Seek(1, { ::fnIdTipo })
		::FileName("DirectExcel"+ oSigaDW:DWCurr()[2]+ "_" + oConsulta:value("tipo") + "_" + oConsulta:value("nome") + "_" + dwStr(oUserDW:UserId()) + ".XLS")
		::FileType(FT_DIRECT_EXCEL)
		::fnTipo := EX_CON
	elseif oExport:Seek(1, { ::fnID })
		::fnTipo := oExport:value("tipo") 
		::fnIDTipo := oExport:value("idtipo") 
		::WorkDir(DwExpFilesPath())
		if empty(::FileName())
			if ::fnTipo == EX_GRAF
				//::FileName("chart"+dwstr(DWLogin())+dwstr(::fnIDTipo) + aTypes[val(oExport:value("formato"))][FT_EXT])
				::FileName("chart"+dwstr(DWLogin())+dwstr(::fnIDTipo) + aTypes[1][FT_EXT])
			elseif ::fnTipo == EX_DIM
				::FileName("dim"+strzero(oExport:value("id"),5) + aTypes[val(oExport:value("formato"))][FT_EXT])
			elseif ::fnTipo == EX_CUBE
				::FileName("cub"+strzero(oExport:value("id"),5) + aTypes[val(oExport:value("formato"))][FT_EXT])
			else      
				oConsulta:Seek(1, { ::fnIdTipo })
				::FileName("con_"+ oSigaDW:DWCurr()[2]+ "_" + oConsulta:value("tipo") + "_" + oConsulta:value("nome") + "_" + iif(dwIsScheduler(),"0000",dwStr(oUserDW:UserId())) + aTypes[val(oExport:value("formato"))][FT_EXT])
			endif
		endif	
		::FileType(val(oExport:value("formato")))
		::MailList(oExport:value("maillist", .t.))
		::Mzp(oExport:value("mzp"))                
		if !empty(oExport:value("separator"))
			::FieldSeparator(oExport:value("separator",.t.))
		endif
		::HideTotals(oExport:value("hideTotals"))
		::HideEquals(oExport:value("hideEquals"))
		::ShowHeaders(oExport:value("showHeader"))
		::ShowFiltering(oExport:value("showFltrng"))
		::ShowZero(oExport:value("showZero"))
		::ShowFormat(oExport:value("showformat"))
		::percIsInd(oExport:value("percIsInd"))
		::ExpAlert(oExport:value("expAlert"))
	endif
	
return

/*
--------------------------------------------------------------------------------------
Propriedade WorkDir
--------------------------------------------------------------------------------------
*/
method WorkDir(acValue) class TMakeExp2

	if valType(acValue) != "U"
		if right(acValue,1) != "\"
			acValue += "\"
		endif
		property ::fcWorkdir := acValue
	endif
		
return ::fcWorkdir
/*
--------------------------------------------------------------------------------------
Propriedade FileName
--------------------------------------------------------------------------------------
*/
method FileName(acValue) class TMakeExp2

	property ::fcFileName := acValue
	
return ::fcFileName

/*
--------------------------------------------------------------------------------------
Propriedade IDTipo
--------------------------------------------------------------------------------------
*/
method IDTipo(anValue) class TMakeExp2

	property ::fnIdTipo := anValue
	
return ::fnIdTipo

/*
--------------------------------------------------------------------------------------
Tipo do arquivo
--------------------------------------------------------------------------------------
*/
method FileType(anValue) class TMakeExp2

	property ::fnFileType := anValue
	
return ::fnFileType
/*
--------------------------------------------------------------------------------------
Propriedade BeforeExec
--------------------------------------------------------------------------------------
*/
method BeforeExec(abValue) class TMakeExp2

	property ::fbBeforeExec := abValue
	
return ::fbBeforeExec

/*
--------------------------------------------------------------------------------------
Propriedade AfterExec
--------------------------------------------------------------------------------------
*/
method AfterExec(abValue) class TMakeExp2

	property ::fbAfterExec := abValue
	
return ::fbAfterExec

/*
--------------------------------------------------------------------------------------
Propriedade Mzp
--------------------------------------------------------------------------------------
*/
method Mzp(alValue) class TMakeExp2

	property ::flMzp := alValue
	
return ::flMzp

/*
--------------------------------------------------------------------------------------
Propriedade FieldSeparator
--------------------------------------------------------------------------------------
*/
method FieldSeparator(acValue) class TMakeExp2

	property ::fcFieldSeparator := acValue
	
return ::fcFieldSeparator

/*
--------------------------------------------------------------------------------------
Propriedade HideTotals
--------------------------------------------------------------------------------------
*/
method HideTotals(alValue) class TMakeExp2

	property ::flHideTotals := alValue
	
return ::flHideTotals

/*
--------------------------------------------------------------------------------------
Propriedade HideEquals
--------------------------------------------------------------------------------------
*/
method HideEquals(alValue) class TMakeExp2

	property ::flHideEquals := alValue
	
return ::flHideEquals

/*
--------------------------------------------------------------------------------------
Propriedade ShowHeaders
--------------------------------------------------------------------------------------
*/
method ShowHeaders(alValue) class TMakeExp2

	property ::flShowHeaders := alValue
	
return ::flShowHeaders

/*
--------------------------------------------------------------------------------------
Propriedade ShowFiltering
--------------------------------------------------------------------------------------
*/
method ShowFiltering(alValue) class TMakeExp2

	property ::flShowFiltering := alValue
	
return ::flShowFiltering

/*
--------------------------------------------------------------------------------------
Propriedade ShowFormat
--------------------------------------------------------------------------------------
*/
method ShowFormat(alValue) class TMakeExp2

	property ::flShowFormat := alValue
	
return ::flShowFormat

/*
--------------------------------------------------------------------------------------
Propriedade percIsInd
--------------------------------------------------------------------------------------
*/
method percIsInd(alValue) class TMakeExp2

	property ::flPercIsInd := alValue
	
return ::flPercIsInd

/*
--------------------------------------------------------------------------------------
Propriedade ExpAlert
--------------------------------------------------------------------------------------
*/
method ExpAlert(alValue) class TMakeExp2

	property ::flExpAlert := alValue
	
return ::flExpAlert


/*
--------------------------------------------------------------------------------------
Propriedade ShowZero
--------------------------------------------------------------------------------------
*/
method ShowZero(alValue) class TMakeExp2
                   
	property ::flShowZero := alValue
	
return ::flShowZero


/*
--------------------------------------------------------------------------------------
Propriedade MailList
--------------------------------------------------------------------------------------
*/
method MailList(acValue) class TMakeExp2

	property ::fcMailList := acValue
	
return ::fcMailList

/*
--------------------------------------------------------------------------------------
Propriedade InfoArray
--------------------------------------------------------------------------------------
*/
method InfoArray(aaValue) class TMakeExp2

	property ::faInfoArray := aaValue
	
return ::faInfoArray

/*
--------------------------------------------------------------------------------------
Propriedade DescType()
--------------------------------------------------------------------------------------
*/
method DescType() class TMakeExp2
	local cRet := ""
	local aTypes := dwComboOptions(FILE_TYPES)
                  
  if ::fileType() <> FT_DIRECT_EXCEL
  	cRet := aTypes[::FileType(),FT_DESC]
    cRet += "(*"+iif(::mzp(),".mzp",aTypes[::FileType(),FT_EXT])+")"
	else
	  	cRet := STR0014 //"Excel(integração)"
    	cRet += "(*.xls)"
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Processa exportção de arquivos 
--------------------------------------------------------------------------------------
*/                               
method processExp(abLog) class TMakeExp2
	local lOk := .t., lUpdateExport := .F.

	local cBuffer, aTypes := dwComboOptions(FILE_TYPES)
	local oExport
	
	If !(::fnTipo == EX_CON .OR. ::FileType() == FT_DIRECT_EXCEL)
		oExport := InitTable(TAB_EXPORT)
		If oExport:Seek(1, { ::fnID })
			lUpdateExport := .T.
		EndIf
	EndIf
	
	// Before
	if valType(::BeforeExec()) == "B"
		lOk := __runCB(::BeforeExec())
		if !lOk
			eval(abLog, IPC_ERRRO, STR0002)  //"Processo de exportação cancelada pela rotina de inicialização"
			return
		endif		
	endif
	
	// Cria destino
	if ::fnTipo != EX_GRAF
		eval(abLog, IPC_AVISO, STR0003 + ::WorkDir()+::FileName())  //"Criando arquivo destino "
		WFForceDir(::WorkDir())
		::foFileHandle := TDWFileIO():new(::WorkDir()+::FileName())
		if(!::foFileHandle:Create())
			eval(abLog, IPC_ERRO, STR0004 + dwStr(::foFileHandle:GetError()))  //"Erro no arquivo "
			return 	
		endif
		
		// Executando consulta e gravando
		// Novos tipos de exportação deverão ter uma entrada neste bloco com EXEC APH

		cBuffer := ""          
		if ::fnTipo == EX_DIM
      		::exportDim(abLog)
    	elseif ::fnTipo == EX_CUBE
        	::exportCube(abLog)
      	else                                                  
         //####TODO preparar sincronização com memória
//         if !dwIsScheduler()
//         	exportQuery(TConsulta():New(::fnID, TYPE_TABLE, .f.), self)
//         else
	         	exportQuery(TConsulta():New(::fnIDTipo, TYPE_TABLE, .t.), self)
//         endif 
	   endif
		if ::FileType() != FT_DIRECT_EXCEL
			::foFileHandle:Close()
			// mzp
			if(::mzp())
//				eval(abLog, IPC_ETAPA, "Compactando...", 0.40)
				wfzipfile(::WorkDir()+::FileName()+aTypes[::FileType(),FT_EXT], ::WorkDir()+::FileName()+".mzp")
				FErase(::WorkDir()+::FileName())
			endif	
		Else
			::foFileHandle:Close()
    	endif
		// Fechando
//		eval(abLog, IPC_ETAPA, "Exportacäo concluida.", 1.00)
	endif
	
	if lUpdateExport
		oExport:Update( {{"dtultima", date()}, {"hrultima", time()}} )
	endif
	
	// Processando lista de e-mails
	if len(::MailList()) != 0
//		eval(abLog, IPC_PROCESSO, "Notificando lista de e-mails.", 0.6)
		if empty(::InfoArray())		
			DWSendMail(STR0005 + ::FileName(),;  //"SigaDW - Arquivo exportado "
				"<br>"+STR0006+::FileName()+CRLF+;  //"Anexo: "
				"<br>"+STR0007+aTypes[6,FT_DESC]+CRLF+;  //"Tipo: " //::FileType()
				"<br>"+STR0008+DWStr(oExport:value("dtultima"))+CRLF+;  //"Data: "
				"<br>"+STR0009+DWStr(oExport:value("hrultima"))+CRLF,;  //"Hora: "
				::MailList(), nil, {::WorkDir()+::FileName()})
		else
			DWSendMail(::InfoArray()[1], ::InfoArray()[2],;
				::MailList(), nil, {::WorkDir()+::FileName()})
		endif
//		eval(abLog, IPC_PROCESSO, "Notificacäo concluida.", 0.8)
	endif

	// AfterExec
	if valType(::AfterExec()) == "B"
//		eval(abLog, IPC_PROCESSO, "Executando rotina de finalizacäo do usuario", 0.90)
		eval(::AfterExec())
//		eval(abLog, IPC_PROCESSO, "Rotina de finalizacäo do usuario executada", 0.95)
	endif

return

/*
--------------------------------------------------------------------------------------
WriteInit - Cria o gauge para acompanhamento
anLines - Numero total de linhas a serem escritas
--------------------------------------------------------------------------------------
*/                               
method WriteInit(anLines, aHeader, acWorksheetName, alDimOrCube) class TMakeExp2
	local nInd, aWSData
                           
	default acWorksheetName := "WorksheetName|WorksheetName"
	default alDimOrCube := .f.

	aWSData := dwToken(acWorksheetName, "|")
	if len(aWSData) == 1
		aWSData := { aWSData[1], aWSData[1] }
	endif
	::fnLines := anLines-1
	if ::FileType() == FT_HTM .or. ::FileType() == FT_EXCEL
		::foFileHandle:writeln("<html>")
		::foFileHandle:writeln("<head>")
		::foFileHandle:writeln("<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>")
		::foFileHandle:writeln("<style>")
		::foFileHandle:writeln("<!--table")
		If Upper( __Language ) == "PORTUGUESE"
			::foFileHandle:writeln('  { mso-displayed-decimal-separator:"\,"; mso-displayed-thousand-separator:"\.";}')
		Else
			::foFileHandle:writeln('  { mso-displayed-decimal-separator:"\."; mso-displayed-thousand-separator:"\,";}')
		EndIf
		::foFileHandle:writeln("   -->")
		::foFileHandle:writeln("</style>")
		::foFileHandle:writeln("<body>")
		if valType(aHeader) == "U"
			::foFileHandle:writeln("<table>")
		elseIf !(::ShowHeaders())
			::foFileHandle:writeln("<table cellpadding=0 cellspacing=0 border=1>")
		else
			::foFileHandle:writeln("<table>")
			If ::FileType() == FT_EXCEL
				::foFileHandle:writeln( "<tr><td colSpan='" + DwStr(len(aHeader)) + "'>Datawarehouse [ " + oSigaDW:DWCurr()[DW_NAME] + " ] - [ "  + oSigaDW:DWCurr()[DW_DESC] + " ]</td></tr>" )
				::foFileHandle:writeln( "<tr><td colSpan='" + DwStr(len(aHeader)) + "'>" + STR0010 + " " + aWSData[1] + " - " + aWSData[2] + "</td></tr>" ) //"Consulta"
				::foFileHandle:writeln( "<tr><td colSpan='" + DwStr(len(aHeader)) + "'>" + STR0011 + " " + DwStr(date()) + " - " + DwStr(time()) + "</td></tr>" ) //"Gerada em"
				::foFileHandle:writeln( "<tr><td colSpan='" + DwStr(len(aHeader)) + "'>&nbsp;</td></tr>" )
			EndIf
			aEval(aHeader, { |x| ::foFileHandle:writeln(x)})
		endif
	elseif ::FileType() == FT_DIRECT_EXCEL
		::foFileHandle:writeln("<html>"+CRLF)
		::foFileHandle:writeln("<head>"+CRLF)
		::foFileHandle:writeln("<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"+CRLF)
		::foFileHandle:writeln("<style>"+CRLF)
		::foFileHandle:writeln("<!--table"+CRLF)
		If Upper( __Language ) == "PORTUGUESE"
			::foFileHandle:writeln('  { mso-displayed-decimal-separator:"\,"; mso-displayed-thousand-separator:"\.";}'+CRLF)
		Else
			::foFileHandle:writeln('  { mso-displayed-decimal-separator:"\."; mso-displayed-thousand-separator:"\,";}'+CRLF)
		EndIf   
		
		If ::ShowFormat()
			BuildStylesCellTag(::faStyles)
		endif
		
		::foFileHandle:writeln("   -->"+CRLF)
		::foFileHandle:writeln("</style>"+CRLF)
		::foFileHandle:writeln("<body>"+CRLF)
		if valType(aHeader) == "U"
			::foFileHandle:writeln("<table>"+CRLF)
		else 
			aEval(aHeader, { |x| ::foFileHandle:writeln(x+CRLF)})
		endif
	elseif ::FileType() == FT_EXCEL_XML
		::foFileHandle:writeln('<?xml version="1.0" encoding="ISO-8859-1" ?>')
		::foFileHandle:writeln('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"')
		::foFileHandle:writeln(' xmlns:o="urn:schemas-microsoft-com:office:office"')
		::foFileHandle:writeln(' xmlns:x="urn:schemas-microsoft-com:office:excel"')
		::foFileHandle:writeln(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"')
		::foFileHandle:writeln(' xmlns:html="http://www.w3.org/TR/REC-html40">')
		::foFileHandle:writeln(' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">')
		::foFileHandle:writeln('   <LastAuthor>'+DWBuild()+'</LastAuthor>')
		::foFileHandle:writeln('   <Created>'+dt2Excel()+'</Created>')
		::foFileHandle:writeln('   <LastSaved>'+dt2Excel()+'</LastSaved>')
		::foFileHandle:writeln('   <Version></Version>')
		::foFileHandle:writeln(' </DocumentProperties>')
		if !empty(DWLocWebComp())
			::foFileHandle:writeln(' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">')
			::foFileHandle:writeln('  <DownloadComponents/>')
			::foFileHandle:writeln('  <LocationOfComponents HRef="'+DWLocWebComp()+'"/>')
			::foFileHandle:writeln(' </OfficeDocumentSettings>')
		endif

		::foFileHandle:writeln(' <Styles>')
		::foFileHandle:writeln(' <Style ss:ID="Default" ss:Name="Normal">')
		::foFileHandle:writeln(' <Alignment ss:Vertical="Bottom" />')
		::foFileHandle:writeln(' </Style>')
		if !alDimOrCube
			::foFileHandle:writeln(' <Style ss:ID="pivotHeaderDim">')
			::foFileHandle:writeln(' <Alignment ss:Horizontal="Left" />')
			::foFileHandle:writeln(' </Style>')
			::foFileHandle:writeln(' <Style ss:ID="pivotHeaderInd">')
			::foFileHandle:writeln(' <Alignment ss:Horizontal="Right" />')
			::foFileHandle:writeln(' </Style>')
			::foFileHandle:writeln(' <Style ss:ID="pivotInd">')
			::foFileHandle:writeln(' <Alignment ss:Horizontal="Right" />')
			::foFileHandle:writeln(' </Style>')
		else
			::foFileHandle:writeln(' <Style ss:ID="x131">')
			::foFileHandle:writeln(' <Alignment ss:Horizontal="Right" />')
			::foFileHandle:writeln(' </Style>')
			::foFileHandle:writeln(' <Style ss:ID="x124">')
			::foFileHandle:writeln(' <Alignment ss:Horizontal="Right" />')
			::foFileHandle:writeln(' </Style>')
			::foFileHandle:writeln(' <Style ss:ID="x125">')
			::foFileHandle:writeln(' <Alignment ss:Horizontal="Right" />')
			::foFileHandle:writeln(' </Style>')
		endif
		::foFileHandle:writeln(' </Styles>')

		::foFileHandle:writeln(' <Worksheet ss:Name="'+aWSData[1]+'">')
		::foFileHandle:writeln(' <Table>')

		::foFileHandle:writeln('<Row ss:AutoFitHeight="0">')
		buildCellTag({ dwConcatWSep(" ", { "Datawarehouse", "[", oSigaDW:DWCurr()[DW_NAME], "] - [", oSigaDW:DWCurr()[DW_DESC],"]" } )}, ::foFileHandle)
		::foFileHandle:writeln('</Row><Row ss:AutoFitHeight="0">')
		buildCellTag({ dwConcatWSep(" ", { STR0010, aWSData[1], "-", aWSData[2]}) }, ::foFileHandle)  //"Consulta"
		::foFileHandle:writeln('</Row><Row ss:AutoFitHeight="0">')
		buildCellTag({ dwConcatWSep(" ", { STR0011, date(), " - ", time()}) }, ::foFileHandle)  //"Gerada em"
		::foFileHandle:writeln('</Row><Row ss:AutoFitHeight="0">')
		buildCellTag({}, ::foFileHandle) /*Cria uma linha em branco entre o cabeçalho e os dados.*/
		::foFileHandle:writeln('</Row>')

		if valType(aHeader) == "U"
		elseIf ::ShowHeaders()
			for nInd := 1 to len(aHeader)
				::foFileHandle:writeln('<Row ss:AutoFitHeight="0">')
				buildCellTag(aHeader[nInd], ::foFileHandle)
				::foFileHandle:writeln("</Row>")
			next
		endif
	elseif ::ShowHeaders() .and. (::FileType() == FT_SDF .or. ::FileType() == FT_CSV)
		if !(valType(aHeader) == "U")
			for nInd := 1 to len(aHeader)
				buildCell(aHeader[nInd], ::foFileHandle, ::FieldSeparator())
				::foFileHandle:writeln("")
			next
			aEval(aHeader, { |x| x := alltrim(x) })
		endif
	endif	
return

/*
--------------------------------------------------------------------------------------
WriteLn
--------------------------------------------------------------------------------------
*/                               
method WriteLn(aaCels) class TMakeExp2
	local cAux, cStyle, cDirectExcel := "", cRet := ""
 	local nLen := len(aaCels), nPercent, nInd
  	local aParts := {}      

	if ::FileType() == FT_HTM .or. ::FileType() == FT_EXCEL   
	
		::foFileHandle:write("<tr>")
		for nInd := 1 to nLen          
			cAux := JSEncode(Alltrim(cBIStr(aaCels[nInd])))
			
		  	if cAux == NO_SEND_DATA
		  		cAux := "&nbsp;"
			endif 
			    
			::foFileHandle:write("<td>"+ cAux +"</td>")
		next		
		
		::foFileHandle:writeln("</tr>")
		
	elseif ::FileType() == FT_DIRECT_EXCEL

		::foFileHandle:writeln('<tr>' + CRLF)
		cAux := chr(167)
		for nInd := 1 to nLen
			aaCels[nInd] := alltrim(aaCels[nInd])
		  	if aaCels[nInd] == cAux
		    	aaCels[nInd] := "&nbsp;"
		  	endif
			::foFileHandle:writeln(buildXLSCellTag(aaCels[nInd], ::foFileHandle, ::ShowFormat(), ::ExpAlert()))
		next
		::foFileHandle:writeln("</tr>" + CRLF)   

	elseif ::FileType() == FT_EXCEL_XML
	   
		::foFileHandle:writeln('<Row ss:AutoFitHeight="0">')
		for nInd := 1 to nLen
			buildCellTag(aaCels[nInd], ::foFileHandle, ::faAlerts, ::ExpAlert(), ::ShowFormat(), ::percIsInd())
		next
		::foFileHandle:writeln('</Row>')   
		
	elseif ::FileType() == FT_SDF .or. ::FileType() == FT_CSV    
	
		aEval(aaCels, { |x, i| aaCels[i] := iif(valType(x) == "U", " ", alltrim(cBIStr(x))) })
		cAux := strTran(DWConcatWSep(::FieldSeparator(), aaCels), "&nbsp;", " ")
		cAux := strTran(cAux, "&ordm;", "")
		cAux := strTran(cAux, "&ordf;", "")
		::foFileHandle:writeln(cAux)  
		
	else // txt     
	               
		cAux := strTran(DWConcatWSep(" ", aaCels), "&nbsp;", " ")
		cAux := strTran(cAux, "&ordm;", "")
		cAux := strTran(cAux, "&ordf;", "")
		::foFileHandle:writeln(cAux)   
		
	endif       
	
	nPercent := round(::fnWriten/::fnLines * 100,1)
	if(nPercent%1) == 0 .and. !(::FileType() == FT_DIRECT_EXCEL)
		if(nPercent > ::fnSentPerc)
			::fnSentPerc := nPercent
		endif	
	endif	
	::fnWriten++  
	
return

/*
--------------------------------------------------------------------------------------
WriteFinish - Finaliza o acompanhamento da exportação
--------------------------------------------------------------------------------------
*/                               
method WriteFinish(aFooter) class TMakeExp2
	local nInd, oFile, cFileOut, cAux, aStyle
	local lSaveStyle := .f.
  
	if ::FileType() == FT_HTM .or. ::FileType() == FT_EXCEL
		if valType(aFooter) == "U"
			::foFileHandle:writeln("</table>"+CRLF+"</body>"+CRLF+"</html>")
		else 
			aEval(aFooter, { |x| ::foFileHandle:writeln(x)})
		endif
	elseif ::FileType() == FT_DIRECT_EXCEL
		if valType(aFooter) == "U"
			::foFileHandle:writeln("</table>"+CRLF+"</body>"+CRLF+"</html>")
		else 
			aEval(aFooter, { |x| ::foFileHandle:writeln(x)})
		endif
	elseif ::FileType() == FT_EXCEL_XML
		::foFileHandle:writeln('  </Table>')
		::foFileHandle:writeln(' </Worksheet>')
		::foFileHandle:writeln('</Workbook>')
  		::foFileHandle:Close()
		cFileOut := DWChgFileExt(::foFileHandle:Filename(), ".OUT")
		oFile := TDWFileIO():New(cFileOut)
		oFile:Create(FO_WRITE)
		if !oFile:IsOpen()
			DWRaise(ERR_003, SOL_015, STR0013 + " [ " + cFileOut + " ]")
		endif

		ft_fuse(::foFileHandle:Filename())
		while !ft_feof()
			cAux := ft_freadln()
			if alltrim(cAux) == "</Styles>"
				for nInd := 1 to len(::faStyles)                                                              
					aStyle := ::faStyles[nInd] 
					if empty(aStyle[ID_PARENT]) 
						oFile:writeln('<Style ss:ID="s'+dwStr(nInd)+'">')
					else
						oFile:writeln('<Style ss:ID="s'+dwStr(nInd)+'" ss:Parent="'+aStyle[ID_PARENT]+'">')
					endif
					if !empty(aStyle[ID_MASK]) 
						oFile:writeln(aStyle[ID_MASK])
					endif
						oFile:writeln("</Style>")
				next
			endif
			oFile:writeln(cAux)
			ft_fskip()
		enddo
		ft_fuse()
		oFile:Close()
		::foFileHandle:erase()
		oFile:rename(::foFileHandle:filename())
	endif	
return

/*
--------------------------------------------------------------------------------------
Exporta dados da dimensão
--------------------------------------------------------------------------------------
*/                               
method ExportDim(abLog) class TMakeExp2
  local oDim := oSigaDW:OpenDim(::fnIDTipo)
  local aHeader := {}, nTotal := oDim:recCount(), nLote
  local nRec := 0
    
  aEval(oDim:Fields(), { |x| aAdd(aHeader, x[FLD_NAME]) })

  ::writeInit(nTotal, aHeader, oDim:Alias(), .t.)

  nLote := int(nTotal / 0.05)
  if nLote == 0
     nLote := 1
  endif
  
  while !oDim:eof()                     
    nRec++
    if mod(nRec, 50) == 0
      eval(abLog, IPC_AVISO_SP, nRec, nTotal)
    endif
    ::writeLn(oDim:Record(8))
    oDim:_next()
  enddo
  
  ::writeFinish()
  
  oSigaDW:CloseDim(::fnIDTipo)
return

/*
--------------------------------------------------------------------------------------
Exporta dados do cubo
--------------------------------------------------------------------------------------
*/                               
method ExportCube(abLog) class TMakeExp2
  local oCube := oSigaDW:OpenCube(::fnIDTipo)
  local oQuery := oCube:Query()
  local aHeader := {}, nRec := 0
  local nTotal := oQuery:recCount(), nLote

  nLote := int(nTotal / 0.05)
  if nLote == 0
     nLote := 1
  endif

  aEval(oQuery:Fields(), { |x| aAdd(aHeader, x[FLD_NAME]) })

  ::writeInit(nTotal, aHeader, oCube:Name(), .t.)

  while !oQuery:eof()
    nRec++
    if mod(nRec, 50) == 0
      eval(abLog, IPC_AVISO_SP, nRec, nTotal)
    endif
    ::writeLn(oQuery:Record(8))
    oQuery:_next()
  enddo
  
  ::writeFinish()
  
  oSigaDW:CloseCube(::fnIDTipo)
return
           
/*
--------------------------------------------------------------------------------------
Adiciona códigos de estilo
--------------------------------------------------------------------------------------
*/                               
method addStyle(acParentStyle, acAdvPLMask, acMask) class TMakeExp2
	Local nPos, cTarget
	
	Default acParentStyle := ""
	Default acAdvPLMask := ""
	Default acMask := Nil   

  if left(acAdvPLMask, 1) == "@"
    acAdvPLMask := mask2Excel(acAdvPLMask)
  else
    acAdvPLMask := style2Excel(acAdvPLMask, acMask)
  endif
	
	cTarget := dwStr({ acParentStyle, acAdvPLMask })
	
	nPos := ascan(::faStyles, { |x| dwStr(x) == cTarget })

	if nPos == 0
		aAdd(::faStyles, { acParentStyle, acAdvPLMask })
		nPos := len(::faStyles)
	endif
	
return "s"+dwStr(nPos)         

/*
--------------------------------------------------------------------------------------
Adiciona mensagens de alertas
--------------------------------------------------------------------------------------
*/                               
method addAlert(acAlertID, acMsg) class TMakeExp2
	local nPos
	
	nPos := ascan(::faAlerts, { |x| x[1] == acAlertID })

	if nPos == 0
		aAdd(::faAlerts, { acAlertID, acMsg })
		nPos := len(::faAlerts)
	endif
	
return nPos

static function buildCellTag(acValue, aoStreamOut, aaAlerts, alExpAlert, alShowFormat, alPercIsInd)
	Local cRet := "", cAux, aAux
	Local nAgg, nInd, nPos, nInd2 
	Local aParts      
	
	if valType(acValue) == "A"
		for nInd := 1 to len(acValue)
			buildCellTag(acValue[nInd], aoStreamOut, aaAlerts, alExpAlert)
		next
	else
		
		Default aaAlerts 		:= {}
		Default alExpAlert 		:= .F.
		Default alShowFormat	:= .F.
		Default alPercIsInd 	:= .F. 
		
		alExpAlert := alExpAlert .and. len(aaAlerts) > 0
		acValue := dwStr(acValue)
		
		If acValue == NO_SEND_DATA
			acValue := "&nbsp;"
		Endif

		aParts := dwToken(acValue, "|", .F.)
		
		if !empty(acValue)
			if len(aParts) > 3
				aParts[1] := dwStr(aParts[1])
				 
				/*Idenfifica a função de agregação utlizada no indicador.*/                
				nAgg := DwVal(aParts[4])
 	        	
 	        	/*Os indicadores do tipo percentual [%] serão divididos por 100 para serem apresentados corretamente no Excel.*/
 	        	If (nAgg == AGG_PAR .or. nAgg == AGG_PARTOT .or. nAgg == AGG_PARGLOB .or. nAgg == AGG_ACUMPERC)
 	        	   	If (alShowFormat) .And. (!alPercIsInd)         	   	
 	        	   		aParts[2] := Alltrim(dwStr(DwVal(aParts[2])/100))	 	        		
 	        		EndIf
 	        	EndIf

				cRet := '<Cell ss:StyleID="'+aParts[1]+'"><Data ss:Type="'+typeAdv2Excel(aParts[3])+'">'+strTran(dwStr(aParts[2]), "&nbsp;", " ")+"</Data>
				if alExpAlert .and. len(aParts) == 5
					cAux := substr(aParts[5], 9)
					cAux := left(cAux, len(cAux)-1)
					aAux := dwToken(cAux, "-")
					cRet += "<Comment ss:Author='SigaDW'>"
					cRet += "<ss:Data xmlns='http://www.w3.org/TR/REC-html40'><B><Font html:Size='8' html:Color='#000000'>SigaDW:</Font></B>"
					cRet += "<Font html:Size='8' html:Color='#000000'>"
					for nInd2 := 1 to len(aAux)
						nPos := ascan(aaAlerts, { |x| x[1] == aAux[nInd2] } )
						if nPos <> 0
							cRet += "&#10;"+aaAlerts[nPos, 2]
						endif
					next
					cRet += "</Font></ss:Data></Comment>"
				endif
				cRet += "</Cell>"
			elseif len(aParts) == 2
				cRet := '<Cell ss:StyleID="'+dwStr(aParts[1])+'"><Data ss:Type="String">'+strTran(dwStr(aParts[2]), "&nbsp;", " ")+"</Data></Cell>"
			else
				cRet := '<Cell><Data ss:Type="String">'+strTran(dwStr(aParts[1]), "&nbsp;", " ")+"</Data></Cell>"
			endif
		else
			cRet := '<Cell><Data ss:Type="String"> </Data></Cell>"
		endif
	endif
	
	if valType(aoStreamOut) == "O" .and. !empty(cRet)
		aoStreamOut:writeLn(cRet)
		cRet := ""
	endif

return cRet

static function buildXLSCellTag(acValue, aoStreamOut, alShowFormat, alExpAlert)
	Local cClass := "", cRet := "" 
	Local nAgg, nInd 
	Local aParts  
	
	Default alShowFormat := .F.                                             
                                                    
 	if valType(acValue) == "A" .and. valtype(aoStreamOut) == "O"
 		for nInd := 1 to len(acValue)
 			cRet += buildCellTag(acValue[nInd], aoStreamOut)
 	  	next
 	else                         
 		acValue := dwStr(acValue)
		aParts := dwToken(acValue, "|", .f.)
		
		if !empty(acValue)
			if !empty(aParts[1])    
				cClass := If(alShowFormat, dwStr(aParts[1]), 'xl26')

				if len(aParts) >= 4
				
					/*Idenfifica a função de agregação utlizada no indicador.*/                
					nAgg := DwVal(aParts[4])
	 	        	
	 	        	/*Os indicadores do tipo percentual [%] serão divididos por 100 para serem apresentados corretamente no Excel.*/
	 	        	If (nAgg == AGG_PAR .or. nAgg == AGG_PARTOT .or. nAgg == AGG_PARGLOB .or. nAgg == AGG_ACUMPERC)
 	        	   		aParts[2] := Alltrim(dwStr(DwVal(aParts[2])/100))	 	        		
	 	        	EndIf

					cRet := '  <td class='+cClass+' x:num="'+strTran(dwStr(aParts[2]), "&nbsp;", " ")+'">'+strTran(dwStr(aParts[2]), "&nbsp;", " ")
					if len(aParts) == 5
            			cRet += "<comment ss:Author='SigaDW'><ss:Data xmlns='http://www.w3.org/TR/REC-html40'><b>"
            			cRet += " SigaDW:</b>&#10"
            			cRet += aParts[5] + "</ss:Data></Comment>"
           			endif
					cRet += "</td>"
				elseif len(aParts) == 2
					cRet := '  <td class='+cClass+'>'+strTran(dwStr(aParts[2]), "&nbsp;", " ")+"</td>"
				else
					cRet := ' <td class=xl31>'+strTran(dwStr(aParts[1]), "&nbsp;", " ")+"</td>"
				endif
			endif
		else
			cRet := ' <td class=xl31></td>'
		endif                                                      
	endif                                                      

	if valType(aoStreamOut) == "O" .and. !empty(cRet)
		aoStreamOut:writeLn(cRet)
		cRet := ""    
	elseif valType(cDirectExcel) == "C"
		cDirectExcel += cRet+CRLF
		cRet := ""
	endif

return cRet

static function buildCell(acValue, aoStreamOut, acSeparator)
	local aParts , cRet := "", nInd
                                                    
 	if valType(acValue) == "A"     
 		for nInd := 1 to len(acValue)
 			buildCell(acValue[nInd], aoStreamOut, acSeparator)
 		next
 	else
 		acValue := dwStr(acValue)
		aParts := dwToken(acValue, "|", .f.)
		if !empty(acValue)
			if len(aParts) == 3
				cRet := dwStr(aParts[2])
			elseif len(aParts) == 2
				cRet := dwStr(aParts[2])
			else
				cRet := dwStr(aParts[1])
			endif          
			cRet := strTran(cRet, "&nbsp;", " ")
			cRet := strTran(cRet, "&ordm;", "")
			cRet := strTran(cRet, "&ordf;", "")
		else                         
			cRet := " "
		endif     
		cRet += acSeparator                                                 
	endif                                                      

	if valType(aoStreamOut) == "O" .and. !empty(cRet)
		aoStreamOut:write(cRet)
		cRet := ""
	endif
	
return cRet

static function dt2Excel(adDate, acTime)

	default adDate := date()
	default acTime := time()
	
return strZero(year(adDate),4)+"-"+strZero(month(adDate),2)+"-"+strZero(day(adDate),2)+"T"+acTime+"Z"

static function typeAdv2Excel(acType)
	local cRet := ""
	
	if acType == "N"
		cRet := "Number"
	elseif acType == "D"
		cRet := "Date"
	elseif acType == "B"
		cRet := "Boolean"
	else
		cRet := "String"
	endif
	
return cRet        

static function mask2Excel(acMask)
	local cRet := alltrim(strTran(acMask, "@E", ""))
	local nPos := at(".", cRet)
	local cMaskPad := "_-* #,##0<dec>_-;\-* #,##0<dec>_-" 

	if nPos == 0
		cRet := strTran(cMaskPad, "<dec>", "")
	else		
		cRet := strTran(cMaskPad, "<dec>", strTran(substr(cRet, nPos), "9", "0"))
	endif

	cRet := "<NumberFormat ss:Format='"+cRet+"'/>"

return cRet 

static function style2Excel(acStyle, acMask)
	Local aRet := dwToken(acStyle, ";", .f.)
  	Local nAux :=	len(aRet), nInd
    Local cMask  := ''
     
	Default acMask := Nil
    
    /*Insere a tag NumberFormat para todos os indicadores*/                  
	If !(isNull(acMask))
		cMask := mask2Excel(acMask)	
	EndIf

	for nInd := 1 to nAux
	  if !empty(aRet[nInd])
	    	aAux := dwToken(aRet[nInd], ":", .f.)
	    	 
	  		if aAux[1] == "background-color"
        		aRet[nInd] := "<Interior ss:Color='"+aAux[2]+"' ss:Pattern='Solid'/>"
      		elseif aAux[1] == "color"
        		aRet[nInd] := "<Font ss:Color='"+aAux[2]+"'/>"
      		else
        		aRet[nInd] := ""
      		endif       
    	endif     
  	next   
  	
return dwConcatWSep(CRLF, aRet) + cMask

function __makeexp2()
return nil

static function BuildStylesCellTag(aaStyles, aoStreamOut)
	local nInd 			:= 0                                    
	local aStyle		:= {}
	local cDirectExcel 	:= ""
	
	for nInd := 1 to len(aaStyles)

		aStyle := aaStyles[nInd] 
		cRet := '.s'+dwStr(nInd)+CRLF
		if empty(aStyle[ID_PARENT]) 
			cRet += '	{mso-style-parent:s'+ dwStr(nInd) + ';'+CRLF
		else
			cRet += '	{mso-style-parent:'+aStyle[ID_PARENT]+';'+CRLF
		endif          			                       
			
		if empty(aStyle[ID_MASK]) 
			cRet += '	mso-number-format:Standard;}'+CRLF
		else
			cRet += '	mso-number-format:"'+aStyle[ID_MASK]+'";}'+CRLF
		endif

		if valType(aoStreamOut) == "O"
			aoStreamOut:writeln(cRet)
		else
		   cDirectExcel += cRet+CRLF
		endif
	next
return nil
