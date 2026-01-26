// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Htm
// Fonte  : htmlPivot - Funções de geração de consultas (tabela)
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 28.09.05 | 0548-Alan Candido | Versão 3
// 01.10.07 | 0548-Alan Candido | BOPS 133149 - Tratamento de "&" na aprensetação HTML
// 01.02.08 | 0548-Alan Candido | BOPS 140001 - Tratamento de "&" na pesquisa de colunas
//          |                   | para efetuar a apresentação/totalização de indicadores
// 20.02.08 | 0548-Alan Candido | BOPS 140966 - Ajuste no processo de paginação para respeitar
//          |                   | o limite de linhas da tabela, quando há atributos no eixo Y
//          |                   | ou campos de apoio que não aparecem na consulta
// 27.02.08 | 0548-Alan Candido | BOPS 141545 - Ajuste no processo de DD, para abri-lo abaixo da
//          |                   | linha pai
// 06.03.08 | 0548-Alan Candido | BOPS 141436 - Correção na paginação com DD e exportação de DD
// 18.03.08 | 0548-Alan Candido | BOPS 142638 - Correção no processamento de DD, quando é acionado
//          |                   | *all* e ajuste na exportação
// 02.04.08 | 0548-Alan Candido | BOPS 143285 - Correção na paginação e abertura de DD
//          |                   | Nota: Atualizar o site   
// 10.04.08 | 0548-Alan Candido | BOPS 142154
//          |                   | Ajuste de lay-out e formatação de valores para exportação
//          |                   | (sinais de primeiro e primeira)
// 25.04.08 | 0548-Alan Candido | BOPS 144755
//          |                   | Correção no tratamento de opções de totalização, na exportação
// 25.04.08 | 0548-Alan Candido | BOPS 143506
//          |                   | Correção no calculo da largura das colunas de indicadores
// 05.05.08 | 0548-Alan Cândido | BOPS 145242 - correção de DD "all" ao abrir todos os niveis e 
//          |                   | fechar algum nivel anterior
// 12.05.08 | 0548-Alan Cândido | BOPS 145666
//          |                   | Ajuste de lay-out na apresentação da tabela da consulta,
//          |                   | quando ajustado para visualização em "painel-duplo"
// 29.05.08 | 0548-Alan Candido | BOPS 146059
//          |                   | Implementação de procedimentos para processar as opções
//          |                   | de totalização em consultas com ranking (rankSubTotal e rankTotal)
// 02.06.08 | 0548-Alan Candido | BOPS 146687
//          |                   | Correção nos procedimentos de aplicação de alertas
// 11.06.08 | 0548-Alan Candido | BOPS 147407
//          |                   | Ajuste no lay-out da consulta em tabela, quando há poucos atributos
//          |                   | no eixo Y ou poucos indicadores e a visualização esta ajustado para
//          |                   | painel duplo
//          |                   | Em algumas configurações de consulta com ranking, ao solicitar a 
//          |                   | apuração de "total outros", ocorria um erro de execução
//          |                   | Em algumas configurações de consulta com DD e atributos nos eixos XY,
//          |                   | ao efetuar a exportação com alguns niveis abertos, havia deslocamento
//          |                   | nas colunas de indicadores do último nível aberto.
// 26.06.08 | 0548-Alan Candido | BOPS 148647
//          |                   | Correção na apresentação de indicador com percentual acumulado,
//          |                   | quando foi selecionado campo virtual, onde um dos operandos da 
//          |                   | expressão não tenha sido selecionado para apresentação.
// 02.07.08 | 0548-Alan Candido | BOPS 148329
//          |                   | Ajuste no processamento de rank com as opções "outros", "sub-total" e
//          |                   | "total" ligadas.
// 04.07.08 | 0548-Alan Candido | BOPS 148822
//          |                   | Ajuste em atributos do tag <table>, para correta formatação das colunas.
// 14.07.08 | 0548-Alan Candido | BOPS 149353
//          |                   | Ajustes e isolamento de procedimenrtos de apuração de totais, 
//          |                   | quando o rank esta ativo.
// 15.07.08 | 0548-Alan Candido | BOPS 149725
//          |                   | Ajustes na exportação com DD, quando aciona-se o DD all no último nível.
// 05.08.08 |0548-Alan Cândido  | BOPS 151288
//          |                   | Correção na exportação de indicadores de participação, com e sem DD.
//          |                   | Ajuste na paginação de rank e no processamento da query, pois em algumas
//          |                   | situações, poderia ocorrer erro de SQL.
// 12.08.08 |0548-Alan Cândido  | BOPS 146580 (habilitado pelo define DWCACHE)
//          |                   | Implementação de novo sistema de leitura da consulta (uso de cache).
// 13.08.08 |0548-Alan Cândido  | BOPS 151292
//          |                   | Exportação: ajuste na formatação de atributos caracter de forma
//          |                   | a não eliminar zeros a esquerda, p.e. em atributo CÓDIGO
// 09.12.08 | 0548-Alan Candido | FNC 00000149278/811 (8.11) e 00000149278/912 (9.12)
//          |                   | Adequação de procedimentos para suportar ranking por
//          |                   | nivel de drill-down
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | . Adequação de geração de máscara em campos numéricos e datas, 
//          |                   | para respeitar o formato conforme idioma 
//          |                   | (chave RegionalLanguage na sessão do ambiente).
//          |                   | . Correção na formatação de valores percentuais para exportação.
// 17.12.08 | 0548-Alan Candido | FNC 00000010314/2008 (8.11) e 00000010370/2008 (9.12)
//          |                   | Ajuste em lay-out. Ao apresentar dados com DD e ranking,
//          |                   | foi acrescentado a "fim de consulta"
// 19.02.10 | 0548-Alan Candido | FNC 00000003657/2010 (9.12) e 00000001971/2010 (11)
//          |                   | Implementação de visual para P11 e adequação para o 'dashboard'
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "hDwHtmlPivot.ch"

#define NAV_SPECIAL "#"
#define SEP_DATA chr(255)
#define SEL_COL  "|"
#define MARK_LEN  6
#define EOF_MARK  "******"
#define NEXT_MARK "*next*"
#define PREV_MARK "*prev*"
#define NEXT_PREV_MARK "*both*"
#define NAV_MARKS NEXT_MARK  + chr(253) + PREV_MARK + chr(253) + NEXT_PREV_MARK
#define ALL_MARKS EOF_MARK + chr(253) + NAV_MARKS
#define SEL_DD    "!"
#define NO_SEND_DATA chr(253)
#define ASPAS_D   '"'
#define TR_LIMIT_MIN      30
#define TR_LIMIT          TR_LIMIT_MIN
#define TAG_IND           ">1"
#define TAG_INDTOTAL      ">2"
#define TAG_INDSUBTOTAL   ">3"
#define TAG_INDSUBTOTAL2  ">4"
#define TAG_DIM           "+1"
#define TAG_DIMTOTAL      "+2"
#DEFINE FONT_SIZE         7
#DEFINE FONT_SIZE_2       7
#define LARG_MIN          50 
#define LARG_BASE         50
#define LARG_BASE_ATT		  40
#define LARG_BASE_IND		  20
#define MAX_LINES         99999999999
#define SCROLL_AJUSTE     51
#define LIMIT_HEIGHT      740
#define CORRECAO_SIMPLES  6
#define CORRECAO_CURVA_ABC 27 // mesmo valor do estilo padding-left em pivot.css classe ".pivot table td.curva"
#define EAMP              "@amp;" //para uso interno
#define CORRECAO_DUPLO    27

/*
--------------------------------------------------------------------------------------
Monta formulários de apresentação de consulta
Args:
--------------------------------------------------------------------------------------
*/             
function showQuery(aaTabs, aoConsulta, aoExport)
	local aAux := {}, aBuffer := {}, aItens		:= {}
	local nInd, cAux, aParams
	local i, aAlerts
	local lShowQuery, cShowAba := "", cMsgConfOption := ""
	//Armazena data e hora da última importação do cubo.
	local dt_importacao := "" 
	local hr_importacao := ""   
	
	// INICIO LAYOUT PÁGINA
	if !(aoConsulta:_type() == TYPE_GRAPH)
		makeToolBar(aItens, .f., nil, nil, AC_QUERY_EXEC, "", .f., "", .f., .f.)
	endif
	
	if aoConsulta:canUserExp() .or. oUserDW:GetQryExportPerm(oSigaDW:DWCurrID(), aoConsulta:ID())
		//###"Exportar"###"Exporta os dados atuais"
		makeItemToolbar(aItens, STR0001, STR0002, "page_export.gif", ;
		"js:doLoad(" + makeAction(AC_QUERY_CFG_EXP, {{ "id", aoConsulta:ID() }, { "type", aoConsulta:_type() }, { "tipo", if(aoConsulta:_type() == TYPE_TABLE, EX_CON, EX_GRAF) }}) + ", '_window', null, 'winDWPrint', " + DwStr(TARGET_75_WINDOW) + "," + DwStr(TARGET_75_WINDOW)+")", "right")
	endif
	
	// constrói a aba de dados/consulta
	aDados := {}
	aAux := {}
	
	// adiciona os botões passados como parâmetros aos botões de funcionalidades
	if !(aoConsulta:_type() == TYPE_GRAPH)
		makeItemToolbar(aItens, STR0003, STR0004, "page_save.gif", "js:doSaveCfg()", "right") //###"Salvar"###"Salva a visualização atual das colunas"
		makeItemToolbar(aItens, STR0005, STR0006, "page_restore.gif", "js:doRestoreCfg()", "right") //###"Restaurar"###"Restaura padrão de visualização"
		
		//Verifica se existe alguma documentação relacionada a consulta.
		if ( !isNull( DWLoadExpr( aoConsulta:Document() ) ) )
			//O ícone só será exibido quando houver documentação.
			makeItemToolbar(aItens, STR0052 , STR0053, "ic_doc.gif", "js:doShowDocument();", "right") //###"Documentação"###"Exibe a documentação da consulta"
		endIf
		
		// zoom somente será para InternetExplorer
		If isInternetExplorer()
			makeItemToolbar(aItens, STR0007, STR0008, "zoom_minus.gif", "js:makeZoom(-1);", "right") //###"Diminuir Zoom"###"Diminuir o zoom do Gráfico"
			makeItemToolbar(aItens, STR0009, STR0010, "zoom_reset.gif", "js:makeZoom(0);", "right") //###"Restaurar Zoom"###"Aumentar o zoom do Gráfico"
			makeItemToolbar(aItens, STR0011, STR0012, "zoom_plus.gif", "js:makeZoom(1);", "right") //###"Aumentar Zoom"###"Aumentar o zoom do Gráfico"
		EndIf
		buildToolbar(aDados, aItens)
	endif
	
	/*Verifica se a opção de exibir última atualização do cubo na consulta está marcada ou se o usuário é administrador.*/
 	If (oSigaDW:ShowCubeUpdate())        
		/*Recupera a última data e hora de atualização do cubo.*/
		oCons := initTable(TAB_CONSULTAS)                                                                                             
		oCube := initTable(TAB_CUBESLIST)
		
		If oCons:Seek(1, { aoConsulta:ID() } )
			If oCube:Seek(1, { oCons:value("ID_CUBE") } )
				dt_importacao := oCube:value("DT_PROCESS")
				hr_importacao := oCube:value("HR_PROCESS")
			Else
				dt_importacao := "..."
				hr_importacao := "..."
			Endif                              
		Else
			dt_importacao := "..."
			hr_importacao := "..."
		Endif 
		/*Exibe a data e hora da última atualização do cubo.*/
		aAdd(aDados, "<div align='right'>")  
		aAdd(aDados, buildTitle(STR0055 + DToC(dt_importacao) + ' às ' + hr_importacao)) /*'Última atualização do cubo em DATA às HORA*/
		aAdd(aDados, "</div>")   
	EndIf 	 
		
	// verifica a opção de aplicação de filtros antes de executar a consulta
	lShowQuery := .T.
	if !(DwVal(HttpGet->Oper) == OP_SUBMIT)
		// não aplicar filtro em 1º plano
		if oSigaDW:ShowFilter() == "0"
			lShowQuery := .T.
			// aplicar filtro em 1º plano quando não aplicado
		elseif oSigaDW:ShowFilter() == "1"
			// possuir filtro para aplicar e ainda não aplicou nenhum filtro e não estiver com filtro aplicado "on"
			if len(aoConsulta:Where(.T.)) > 0 .and. len(aoConsulta:Where()) == 0 .and. !aoConsulta:Filtered()
				lShowQuery := .F.
				cShowAba := "abaFiltro"
				cMsgConfOption := STR0013 //###"Por favor, antes de executar a consulta, aplique um filtro na aba 'Filtros'"
			endif
			// aplicar filtro de seleção em 1º plano quando não tiver filtro
		elseif oSigaDW:ShowFilter() == "2"
			if empty(aoConsulta:AutoFilter())
				lShowQuery := .F.
				if !aoConsulta:Filtered() .or. empty(aoConsulta:Where(.T.))
					cShowAba := "abaSelection"
					cMsgConfOption := STR0014 //###"Por favor, antes de executar a consulta, aplique um filtro na aba 'Seleção'"
				elseif len(aoConsulta:Where(.T.)) > 0 .and. len(aoConsulta:Where()) == 0 .and. !aoConsulta:Filtered()
					cShowAba := "abaFiltro"
					cMsgConfOption := STR0015 //###"Por favor, antes de executar a consulta, aplique um filtro na aba 'Filtros'"
				else
					lShowQuery := .T.
				endif
			endif
		endif
	endif
	
	if lShowQuery
		if aoConsulta:_type() == TYPE_GRAPH
			buildChart(aDados, aoConsulta)
		else
			buildTable(aDados, aoConsulta, aoExport)
		endif
	else
		aAdd(aDados, cMsgConfOption)
	endif
	
	aAux := {}
	cAux := ""
	for nInd := 1 to len(aDados)
		if !empty(aDados[nInd])
			cAux += aDados[nInd] + CRLF
			if (nInd % 500) == 0
				makeCustomField(aAux, "frmDados"+dwStr(nInd), cAux, EDT_CUSTOM_CONT)
				cAux := ""
			endif
		endif
	next
	if !empty(cAux)
		makeCustomField(aAux, "frmDados"+dwStr(nInd+1), cAux)
	endif
	makeChildTabbed(aaTabs, "abaDados", STR0016, aAux) //###"Consulta"
	
	/* #### Apresentar telas conforme configurações
	if oSigaDW:ShowFilter() == OPTION_SHOWFILTER .and. oConsulta:HaveFilter() .and. isNull(HttpGet->loadcons,"")=="true"
	oWinWhere:Form():AfterCancel("doHideAll(); goFirst();")
	else
	oWinWhere:Form():AfterCancel("doHideAll();")
	endif
	*/
	
	aAdd(aBuffer, tagJS())
	
	//Exibe a documentação de consultas.
	aAdd(aBuffer, "function doShowDocument()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, " doLoad(" + makeAction( AC_DOCUMENTATION, { { "objID", aoConsulta:id() }, { "ObjType", OBJ_QUERY }  , { "edCmdTextArea", EDT_CMD_DISPLAY }  }) +  ",'_blank', null , 'winDWPrint' , '" + dwStr(TARGET_60_WINDOW) + "', '" + dwStr(TARGET_60_WINDOW) + "')" )
	aAdd(aBuffer, "}")
	
	// salva as configurações de coluna e paineis
	aAdd(aBuffer, "function doSaveCfg()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  var aWidthAtt = new Array();")
	aAdd(aBuffer, "  var aWidthInd = new Array();")
	aAdd(aBuffer, "  var nPerc = oAtt.currentStyle.width;")
	
	aAdd(aBuffer, "  for (var nInd = 0; nInd < oTabAttH.rows[0].cells.length; nInd++)")
	aAdd(aBuffer, "    aWidthAtt.push(oTabAttH.rows[0].cells[nInd].style.pixelWidth);")
	
	aAdd(aBuffer, "  for (var nInd = 0; nInd < oTabIndH.rows[0].cells.length; nInd++)")
	aAdd(aBuffer, "    aWidthInd.push(oTabIndH.rows[0].cells[nInd].style.pixelWidth);")
	
	aAdd(aBuffer, "  requestPivotData('" +makeAction(AC_QUERY_EXEC, { {"acao", "savecfg" } }) + ;
	"&panw='+nPerc+'&attw='+aWidthAtt.join()+'&indw='+aWidthInd.join()"+",'" + STR0017 + "');") //###"Operação efetuada com sucesso"
	aAdd(aBuffer, "}")
	
	// restauras as configurações de coluna e paineis
	aAdd(aBuffer, "function doRestoreCfg()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  requestPivotData(" +makeAction(AC_QUERY_EXEC, { {"acao", "restorecfg" } })+",'" + STR0017 + "');") //###"Operação efetuada com sucesso"
	aAdd(aBuffer, "  var cURL = prepParam(window.location.href, 'hideAtt', '');")
	aAdd(aBuffer, "  doLoadHere(cURL);")
	aAdd(aBuffer, "}")
	
	aAdd(aBuffer, "function requestPivotData(action, acMsg)")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  var dAux = new Date();")
	aAdd(aBuffer, "  var cForceReload = dAux.getTime().toString(16);")
	aAdd(aBuffer, '  var iFrame = getElement("ifRequest");')
	// função JavaScript para tratar a resposta de uma requisição/ação através do IFRAME
	aAdd(aBuffer, '  iFrame.onreadystatechange = handlerResponseData;')
	aAdd(aBuffer, '  action += "&jscript=' + CHKBOX_ON + '";')
	aAdd(aBuffer, "  action += cForceReload;")
	aAdd(aBuffer, "  iFrame.src = prepURL(action);")
	
	aAdd(aBuffer, "	 function handlerResponseData()")
	aAdd(aBuffer, "  {")
	aAdd(aBuffer, "	   if (iFrame.readyState == 'complete')")
	aAdd(aBuffer, "	   {")
	//	aAdd(aBuffer, "	 	   hideWait(oDocParent);")
	aAdd(aBuffer, "	     window.status = acMsg;")
	aAdd(aBuffer, '	   }')
	aAdd(aBuffer, '  }')
	aAdd(aBuffer, '}')
	
	aAdd(aBuffer, "	function makeZoom(anType) {")
	aAdd(aBuffer, "		var zoom = 5;")
	aAdd(aBuffer, "  	if (anType != 0) {")
	
	if aoConsulta:_type() == TYPE_TABLE
		aAdd(aBuffer, "  	zoom = 5;")
		aAdd(aBuffer, "	   	zoom = parseInt(zoom) / 100;")
		aAdd(aBuffer, "	   	if (anType > 0) {")
		aAdd(aBuffer, "	    	zoomComponent(getElement('pivotPan'), zoom)")
		aAdd(aBuffer, "	    } else if (anType < 0) {")
		aAdd(aBuffer, "	    	zoomComponent(getElement('pivotPan'), zoom * -1);")
		aAdd(aBuffer, "	    }")
	else
		aAdd(aBuffer, "	   	if (anType > 0) {")
		aAdd(aBuffer, "	    	getApplet('chart').setZoomIn(zoom);")
		aAdd(aBuffer, "	    } else if (anType < 0) {")
		aAdd(aBuffer, "	    	getApplet('chart').setZoomOut(zoom);")
		aAdd(aBuffer, "	    }")
	endif
	
	aAdd(aBuffer, "  	} else {")
	aAdd(aBuffer, "	       	zoom = 0;")
	
	if aoConsulta:_type() == TYPE_TABLE
		aAdd(aBuffer, "	     	zoomReset(getElement('pivotPan'));")
	else
		aAdd(aBuffer, "	       	getApplet('chart').setZoomRestore();")
	endif
	
	aAdd(aBuffer, "		}")
	aAdd(aBuffer, "	}")
	
	aAdd(aBuffer, '</script>')
	
	aAdd(aBuffer, tagJS())

	aAdd(aBuffer, "function u_pivotonload()")
	aAdd(aBuffer, "{")
		
	// verifica se deve processar a aba de dados da consulta
	if lShowQuery
		aAdd(aBuffer, "  initAba('abaDados');")
		if aoConsulta:_type() == TYPE_TABLE
			if aoConsulta:HaveDrillDown() .or. aoConsulta:DimCountX() + aoConsulta:DimCountY() < 2
				aAdd(aBuffer, "  setPivotObj(document, false);")
			else
				aAdd(aBuffer, "  setPivotObj(document, true);")
			endif

			if isNull(httpGet->dl) .or. '*all*' $ httpGet->dd
				aParams := { {"acao", FIRST_PAGE }, { "dd", httpGet->dd }, { "dl", httpGet->dl } }
			endif
			aAdd(aBuffer, "  requestData("+makeAction(AC_QUERY_EXEC, aParams) +");")
		endif
	else
		aAdd(aBuffer, "  initAba('" + cShowAba + "');")
		
		if cShowAba == "abaSelection"
			aAdd(aBuffer, "  doShowSelection()")
		endif
	endif
	aAdd(aBuffer, "}")
	
	aAdd(aBuffer, "function requestData(acAction)")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  requestPivotData(acAction, '');")
	aAdd(aBuffer, "}")
	
	aAdd(aBuffer,"function showHint ( cell, action)")
	aAdd(aBuffer,"{")
	if !isFireFox()
		aAdd(aBuffer,"	if (!cell.hasChildNodes())")
		aAdd(aBuffer,"	  return;")
		aAdd(aBuffer,"	var cN = cell.childNodes(0);")
		aAdd(aBuffer,"	var cGCR = cell.getClientRects()[0];")
		aAdd(aBuffer,"	var nH = cGCR.bottom - cGCR.top;")
		aAdd(aBuffer,"	var oAllHints = getElement('allHints');")
		aAdd(aBuffer,"	if ((cN.style) && (cN.style.divHint))")
		aAdd(aBuffer,"	{")
		aAdd(aBuffer,"		if ((action == 1) && !(isElementVisible(oAllHints)))")
		aAdd(aBuffer,"	  {")
		aAdd(aBuffer,"		  showElement(oAllHints);")
		aAdd(aBuffer,"		  var aHints = cN.style.divHint.split('-');")
		aAdd(aBuffer,"		  var aDivs = oAllHints.getElementsByTagName('DIV');")
		aAdd(aBuffer,"	    oAllHints.style.left = event.x;")
		aAdd(aBuffer,"	    oAllHints.style.top = event.y + nH;")
		aAdd(aBuffer,"		  for (var nInd = 0; nInd < aDivs.length; nInd++)")
		aAdd(aBuffer,"	    {")
		aAdd(aBuffer,"	      hideElement(aDivs[nInd]);")
		aAdd(aBuffer,"		    for (var nInd1 = 0; nInd1 < aHints.length; nInd1++)")
		aAdd(aBuffer,"	      {")
		aAdd(aBuffer,"          if (aDivs[nInd].id == 'al'+aHints[nInd1])")
		aAdd(aBuffer,"			      showElement(aDivs[nInd]);")
		aAdd(aBuffer,"	      }")
		aAdd(aBuffer,"	    }")
		aAdd(aBuffer,"	  } else if ((action == 2) && (isElementVisible(oAllHints)))")
		aAdd(aBuffer,"		    hideElement(oAllHints);")
		aAdd(aBuffer,"	}")
	endif
	aAdd(aBuffer,"}")
	aAdd(aBuffer, "</script>")
	
	if aoConsulta:HintOn() .and. aoConsulta:AlertOn()
		aAlerts := aoConsulta:Alerts()
		aAdd(aBuffer, "<div class='hint' id='allHints'>")
		for i:=1 to len(aAlerts)
			if empty(aAlerts[i]:Msgt())
				cAux := dwStr(aAlerts[i]:ExpHtml()[3])
			else
				cAux := dwStr(aAlerts[i]:Msgt())
			endif
			aAdd(aBuffer, "<div id='alT" + strZero(aAlerts[i]:ID(),4) + "'>" + cAux + "</div>")

			if empty(aAlerts[i]:MsgF())
				cAux := dwStr(aAlerts[i]:ExpHtml()[3])
			else
				cAux := dwStr(aAlerts[i]:MsgF())
			endif
			aAdd(aBuffer, "<div id='alF" + strZero(aAlerts[i]:ID(),4) + "'>" + cAux + "</div>")
		next
		aAdd(aBuffer, "</div>")
	endif		
return dwConcatWSep(CRLF, aBuffer)

#define IC_RESIZE_WIDTH   20

static function buildColResize(anCol, anWidthDef, alAtt, aoConsulta)
	local cPrefixo := iif(alAtt, "imgAttColResize.", "imgIndColResize.")
	local aMap := {}
	local aBuffer := {}       
	local nCol := anCol - 1
	local cJSFunc1 := "doResizeCol("+iif(alAtt, "1","2")+","+dwStr(nCol)+"," //onClick
	local cJSFunc2 := "doResizeColContinue(true,"+iif(alAtt, "1","2")+","+dwStr(nCol)+"," //onMouseOver
	local cJSFunc3 := "doResizeColContinue(false,"+iif(alAtt, "1","2")+","+dwStr(nCol)+"," //onMouseOut
		
	aAdd(aBuffer, tagImage("ic_resize_col.gif", IC_RESIZE_WIDTH, 8, , , "z-index:100;display:none;left:"+dwStr(int((anWidthDef-IC_RESIZE_WIDTH)/2))+";top:0;position:absolute", , cPrefixo+dwStr(nCol), .t.))
	aAdd(aMap, makeMap(MAP_RECT, { 0, 0, 4, 8}, STR0018, cJSFunc1 + "-5)", cJSFunc2 + "-1)", cJSFunc3 + "-1)")) //###"diminuir"
	aAdd(aMap, makeMap(MAP_RECT, { 6, 0,14, 8}, STR0019, cJSFunc1 + "0, " +dwStr(anWidthDef)+ ")")) //###"padrão"
	aAdd(aMap, makeMap(MAP_RECT, {16, 0,20, 8}, STR0020, cJSFunc1 + "5)", cJSFunc2 + "1)", cJSFunc3 + "-1)")) //###"aumentar"
	tagMap(aBuffer, cPrefixo+dwStr(nCol), aMap)
return dwConcatWSep(CRLF, aBuffer)

static function buildAttHeader(aaBuffer, aoConsulta, anTabWidth, alExp)
	local nInd
	local nCols
	local cAux
	local cAlt, cTitle
	local cColDesc, nAux
	local aCols := aoConsulta:DimFieldsY()
	local aWidth := aoConsulta:AttWidth()
	local nInitRow
	local nDLevel := aoConsulta:DrillLevel()
	local cStyle := ""
	
	aAdd(aaBuffer, "<table>") // ATENÇÂO: a formatação correta será efetuada mais abaixo
	nInitRow := len(aaBuffer) // usando como referencia nInitRow
	
	nCols := len(aCols)
	if nCols == 0
		aAdd(aaBuffer, "<col width='"+buildMeasure(1)+"'>")
	else
		for nInd := 1 to nCols
			cStyle := "width:" + buildMeasure(abs(aWidth[nInd])) + ";"
			if oSigaDW:WidthColDD() == -1 .and. nDLevel <> 0 .and. nInd > nDLevel
			 	if(isInternetExplorer())
					cStyle += displayNone()
			 	endif
			endif
			aAdd(aaBuffer, "<col id='AttHdr" + DwStr(aCols[nInd]:Alias()) + "' style='" + cStyle + "'>")
		next
	endif
	
	nAux := aoConsulta:DimCountX()
	if  nAux > 0
		aDimX := aoConsulta:DimFieldsX()
		for nInd := 1 to nAux
			aAdd(aaBuffer, "<tr id='H"+int2hex(nInd,2)+"' axis='X'>")
			cAux := "<td nowrap='true' class='headerX'"+iif(nCols>1, " colspan="+dwStr(nCols),"")+" id='"+aDimX[nInd]:alias()+"'>"
			if !alExp
				cTitle := aDimX[nInd]:DimName() + '->' + aDimX[nInd]:Name()
				cAlt := aDimX[nInd]:Desc()
				cTitle := cAlt + "(" + cTitle + ")"
				cColDesc := aDimX[nInd]:Desc()
				cAux += tagImage("ic_dimensao.gif" , 12, 12, cAlt, cTitle)

				if len(aDimX) > 1 .and. !aoConsulta:HaveDrillDown()
					cAux += tagImage("ic_hide_col.gif", 12, 12, STR0022, STR0023,,"js:doHideAtt(getParentElement(this), 0)") //###"Esconder"###"Esconde a coluna"
				endif
				cAux += cColDesc+tagImage("ic_cub_filter.gif" , 12, 12, STR0021, cTitle,,"js:doSelection(getParentElement(this), "+dwStr(aoConsulta:ID())+")") //###"Seleção"
				cAux += "</div>"
			endif
			cAux += "</td>
			aAdd(aaBuffer, cAux)
			aAdd(aaBuffer, "</tr>")
		next
	else
		aAdd(aaBuffer, "<tr id='H00' axis='X'>")
		aAdd(aaBuffer, "<td nowrap='true' class='headerX'"+iif(nCols>1, " colspan="+dwStr(nCols),"")+" id='D000' style='height:20px'>&nbsp;</td>")
		aAdd(aaBuffer, "</tr>")
	endif
	
	aAdd(aaBuffer, "<tr axis='Y' ID='H00'>")
	if nCols == 0
		cAux := "<td nowrap='true' UNSELECTABLE=on class='header' id=D000>"
		cAux += "&nbsp"
		cAux += "</td>"
		aAdd(aaBuffer, cAux)
	else
		for nInd := 1 to nCols
			cAux := "<td nowrap='true' unselectable=on class='header' id="+aCols[nInd]:alias()+">"
			if !alExp
				cTitle := aCols[nInd]:DimName() + '->' + aCols[nInd]:Name()
				cAlt := aCols[nInd]:Desc()
				cTitle := cAlt + "(" + cTitle + ")"
				cColDesc := aCols[nInd]:Desc()
				cAux += tagImage("ic_dimensao.gif" , 12, 12, cAlt, cTitle)

				if nCols > 1  .and. !aoConsulta:HaveDrillDown()
					cAux += tagImage("ic_hide_col.gif", 12, 12, STR0022, STR0023,,"js:doHideAtt(getParentElement(this), 1)") //###"Esconder"###"Esconde a coluna"
				endif
				
				if aoConsulta:HaveDrillDown() .and. nInd <> nCols
					cAux += tagImage("drillwait.gif", 9, 9, "","", cssCursorHand()+";margin-right:"+buildMeasure(5), ;
					"js:doDrillAll(this,"+dwStr(nInd+1)+",'')", "imgDD" + dwStr(nInd))
				endif
				cAux += cColDesc
				cAux += tagImage("ic_cub_filter.gif" , 12, 12, STR0021, cTitle,,"js:doSelection(getParentElement(this), "+dwStr(aoConsulta:ID())+")") //###"Seleção"
			endif
			cAux += "</td>"
			aAdd(aaBuffer, cAux)
		next
	endif
	aAdd(aaBuffer, "</tr>")
	aAdd(aaBuffer, "</table>")
	
	aaBuffer[nInitRow] := "<table summary='' class='att' id='attHeader' style='table-layout: auto;width:"+buildMeasure(1)+"'>"
return

static function buildIndHeader(aaBuffer, aoConsulta, anIndWidth,  alExp, anTabInd)
	local nInd, nCols, cAux, nAux
	local cAlt, cTitle, aColsX := {}
	local cColDesc, nInd1
	local nColsX := 0, lHeaderX := .f.
	local nInitRow, aWidth
	local aAux 			:= {}
	Local nCount 		:= 0
	Local cDescricao 	:= ""
	Local aDimFieldX	:= {}
	Local aMask		:= {} // Array que receberá as máscaras do eixo X.
	Local cMask		:= ""
	Local nX			:= 0
	Local nTpConsulta	:= 0
	Local nTamMax		:= 0
	Local nMaxStr	 	:= 0
	local oTabConfig := InitTable(TAB_CONFIG)
	
	default alExp := .f.
	
	aAdd(aaBuffer, "<table>") // ATENÇÂO: a formatação correta será efetuada mais abaixo.
	nInitRow := len(aaBuffer) // usando como referencia nInitRow

	aWidth		:= aoConsulta:IndWidth()
	aCols		:= aoConsulta:Indicadores()
	aDimFieldX	:= aoConsulta:DimFieldsX() // Recebe as dimensões do eixo X.

	// Alimenta array de máscaras.
	For nInd := 1 To Len(aDimFieldX)
		aAdd(aMask, DwStr(aDimFieldX[nInd]:Mascara()))
	Next nInd
	
	// retira indicadores adicionados por serem utilizados em campos virtuais
	aEval(aCols, {|xElem,i| iif(xElem:Ordem() > -1, aAdd(aAux, xElem), NIL)})
	aCols := aAux
	
	nCols := len(aCols)
	cAux := ""
	
	if aoConsulta:DimCountX() > 0
		nColsX := aoConsulta:readAxisX(aColsX, , .t., .f.)
		lHeaderX := .t.
		nAux := len(aWidth)
	else
		nAux := nCols
	endif
	
	//--------------------------------------------------------
	// Verificar o parâmetro TypeCon na tabela de configurações DW00100.
	//--------------------------------------------------------	
	if oTabConfig:Seek(2, { "view", "TypeCon" } )
		nTpConsulta := iif(oTabConfig:value("valor", .t.) == 'T', 1, 0)
	endif
	
	//--------------------------------------------------------
	// Verifica o tipo de cálculo das colunas.
	//--------------------------------------------------------
	If nTpConsulta == 0
		for nInd := 1 to nAux
			aAdd(aaBuffer, "<col width='"+buildMeasure(abs(aWidth[nInd]))+"'>")
		next
	Else
		nInd := 1		
		While nInd <= nAux
			For nX := 1 To Len(aCols)				
				//----------------------------------------------------------------
				// nTamMax recebe o tamanho máximo que os dados(números) da consulta
				// poderão ter. Criada porque o T O T A L utiliza outra fonte e 
				// outro tamanho e pode desposicionar a tabela.
				// * 10 porque é o tamanho em pixel dos números para Verdana 11.
				//----------------------------------------------------------------
				nTamMax := aCols[nX]:Tam() * 10
				
				//----------------------------------------------------------------
				// Recebe o tamanho em pixels da maior palavra da string.
				//----------------------------------------------------------------
				nMaxStr := DwcalcTxtPx(DwAnaliMax( aCols[nX]:Desc() ))
				
				//----------------------------------------------------------------
				// O Tamanho da coluna será o maior entre nTamMax e nMaxStr.
				//---------------------------------------------------------------- 				
				aAdd(aaBuffer, "<col width='" + iif(nTamMax > nMaxStr, DwStr(nTamMax), DwStr(nMaxStr)) + "px'>")
				nInd++
			Next
		EndDo
	EndIf		
	
	if lHeaderX
		nAux := 0
		aColsX[1] := dwToken(left(aColsX[1],len(aColsX[1])-1), chr(255))
		nAux := len(aColsX[1]) 
		
		for nInd := 2 to nColsX
			aColsX[nInd] := dwToken(left(aColsX[nInd],len(aColsX[nInd])-1), chr(255))
			aSize(aColsX[nInd], nAux)
		next 
		
		for nInd1 := 1 to nAux  
			aAdd(aaBuffer, "<tr>")
			
			for nInd := 1 to nColsX
				//----------------------------------------------------------------
				// Verificar o tipo da consulta, se for para verificar pela maior
				// palavra da string no style tem o break-word.
				//----------------------------------------------------------------
				cAux := "<td nowrap='true' class='headerX' "+ iif(nTpConsulta == 0, "", "style='word-wrap: break-word;")  + "'>"
				if valtype(aColsX[nInd, nInd1]) == "U" .or. ;
					(nInd < nColsX .and. dwStr(aColsX[nInd, nInd1]) == dwStr(aColsX[nInd+1, nInd1]))
					
					if empty(aColsX[nInd, nInd1]) 
						if nInd > 1 .and. empty(aColsX[nInd-1, nInd1])
							cAux += "&nbsp;"
						else
							cAux += STR0025 //###"Sub Total"
						endif  
					else
						cAux += "&nbsp;"
					endif 
				elseif valtype(aColsX[nInd, nInd1]) == "C" .AND. len(aColsX[nInd, nInd1]) == 0
					cAux += STR0025 //###"Sub Total"
				else
					// Recupera a descrição do atributo do eixo X.				    					
					If ValType(aColsX[nInd, nInd1]) == 'N'
						cMask := AllTrim(DwStr(aMask[nInd1])) // Recebe a máscara da dimensão.
						
						// Caso haja máscara, a formatação correta é efetuada. 
				    	If Empty(cMask)
				    		cDescricao := DwStr(aColsX[nInd, nInd1]) 
				    	Else
				    		cDescricao := DwStr(transform(aColsX[nInd, nInd1], cMask))
				    	EndIf
				    Else
				    	cDescricao := dwStr(aColsX[nInd, nInd1])
				    EndIf

					For nCount := 19 To Len(cDescricao) step 19
						/*Insere o marcador de quebra de página a cada dezenove caracteres.*/
						cDescricao := Stuff(cDescricao, nCount, 0, "<br>")
					Next nCount
					//cDescricao := StrTran( cDescricao, " ", "<br>", 0 , 1)
					cAux += strTran( cDescricao ," ", "&nbsp;")	
									
				endif  

				cAux += "</td>"
				aAdd(aaBuffer, cAux)
			next 
			aAdd(aaBuffer, "</tr>")
		next
	else
		aAdd(aaBuffer, "<tr>")
		aAdd(aaBuffer, "<td nowrap='true' class='headerX'"+iif(nAux>1, " colspan="+dwStr(nAux),"")+" id='D000' style='height:10px'>&nbsp;</td>")
		aAdd(aaBuffer, "</tr>")
	endif
	
	aAdd(aaBuffer, "<tr>")
	aAux := {}  
	
	for nInd := 1 to nCols
		cAux := "<td nowrap='true' onmouseover='showResizeTool(this, "+ASPAS_D+"Ind"+ASPAS_D+")' onmouseout='hideResizeTool(this, "+ASPAS_D+"Ind"+ASPAS_D+")' class='header'>"
		if !alExp
			cTitle := 'Fato->' + aCols[nInd]:AggTit(,,.t.)
			cAlt := aCols[nInd]:Desc()
			cTitle := cAlt + "(" + cTitle + ")"
			cColDesc := aCols[nInd]:AggTit(	iif( aoConsulta:HaveAggFunc( aCols[nInd]:ExpSQL() ), AGG_FORMULA, aCols[nInd]:AggFunc() ), aCols[nInd]:Desc() ) 

			if aoConsulta:FatorEscala() > 1
				cAlt += "(x "+ alltrim(transform(aoConsulta:FatorEscala(), dwMask("999,999,999"))) +")"
			endif
			
			cAux += tagImage("ic_indicador.gif" , 12, 12, cAlt, cTitle)
			cAux += cColDesc
			cAux += ""
		endif   
		cAux += "</td>"
		aAdd(aAux, cAux) 
	next
	
	if lHeaderX  
		for nInd1 := 1 to nColsX step nCols
			aEval(aAux, { |x| aAdd(aaBuffer, x) })
		next 
	else
		aEval(aAux, { |x| aAdd(aaBuffer, x) })
	endif
	
	aAdd(aaBuffer, "</tr>")
	aAdd(aaBuffer, "</table>")
	
	If nTpConsulta == 0
		aaBuffer[nInitRow] := "<table summary='' class='ind' id='indHeader' style='table-layout: auto; width:"+buildMeasure(anTabInd)+"'>"
	Else
		aaBuffer[nInitRow] := "<table summary='' class='ind' id='indHeader' style='table-layout: auto;'>"
	EndIf
return

static function buildAttData(aaBuffer, aoConsulta, anAttWidth)
	Local nCols
	Local nInd
	Local nInd2
	Local cClass
	Local nInitRow
  	Local aWidth 	:= aoConsulta:AttWidth()
	Local cStyle 	:= ""
	Local nDLevel 	:= aoConsulta:DrillLevel()
	Local aCols 	:= aoConsulta:DimFieldsY()
	Local cAlias 	:= ''            

	nCols := len(aCols)
  	
  	if nCols == 0
  		nCols := 1
  		aWidth := { 1 }
  	endif

	aAdd(aaBuffer, "<table>") // ATENÇÂO: a formatação correta será efetuada mais abaixo
	nInitRow := len(aaBuffer) // usando como referencia nInitRow

	for nInd := 1 to nCols
		cStyle := "width:" + buildMeasure(abs(aWidth[nInd])) + ";"
		if oSigaDW:WidthColDD() == -1 .and. nDLevel <> 0 .and. nInd > nDLevel
		 	if(isInternetExplorer())
				cStyle += displayNone()
			endif
		endif
		
		/*Evita array out off bounds quando não existe itens no eixo Y.*/
		If ( Len(aCols) >= nInd)
		   cAlias := DwStr(aCols[nInd]:Alias())		
		EndIf
		aAdd(aaBuffer, "<col id='AttData" + cAlias + "' style='" + cStyle + "'>")
	next

	// dados        
	for nInd := 1 to TR_LIMIT * nCols
		cClass := iif(oSigaDW:RowColor()=="1", "zebraOff", iif(mod(nInd,2) == 0, "zebraOff", "zebraOn"))
		cClass += iif(nInd > TR_LIMIT_MIN, " hidden", "")
		aAdd(aaBuffer, "<tr id='R"+dwInT2Hex(nInd,3)+"' class='"+cClass+"' onClick='pivotPickUp(1, this)' onMouseOver='pivotRollover(1, this, true)' onMouseOut='pivotRollover(1, this, false)'>")
		for nInd2 := 1 to nCols
			cStyle := ""
			// força o tamanho das colunas caso tenha sido definido pelo usuário
			if oSigaDW:WidthColDD() > 0 .and. nDLevel <> 0 .and. nInd > nDLevel
				cStyle += "style='width:" + buildMeasure(abs(aWidth[nInd2])) + ";'"
			endif
			aAdd(aaBuffer, "<td nowrap='true'"+cStyle+">&nbsp;</td>")
		next
		aAdd(aaBuffer, "</tr>")
	next
	aAdd(aaBuffer, "</table>")

	aaBuffer[nInitRow] := "<table summary='' class='att' id='tabAtt' style='table-layout: auto;width:"+buildMeasure(1)+"'>"
return

static function buildIndData(aaBuffer, aoConsulta, anIndWidth, anTabInd)
	local nCols, nInd, nInd2, nAttY
	local aInd := aoConsulta:Indicadores()
	local nColsX := 0, aColsX := {}
	local lHeaderX := .f., nInitRow
	local aAux := {}
	local nTpConsulta := 0
	Local nX := 0
	local oTabConfig := InitTable(TAB_CONFIG)
	
	// retira indicadores adicionados por serem utilizados em campos virtuais
	aEval(aInd, {|xElem,i| iif(xElem:Ordem() > -1, aAdd(aAux, xElem), NIL)})
	aInd := aAux
	
	nCols := len(aInd)
	aAdd(aaBuffer, "<table>") // ATENÇÂO: a formatação correta será efetuada mais abaixo
	nInitRow := len(aaBuffer) // usando como referencia nInitRow

	if aoConsulta:DimCountX() > 0
		nColsX := aoConsulta:readAxisX(aColsX)
		lHeaderX := .t.
	endif

	aWidth := aoConsulta:IndWidth()
	nCols := len(aWidth)
	
	//--------------------------------------------------------
	// Verificar o parâmetro TypeCon na tabela de configurações DW00100.
	//--------------------------------------------------------	
	if oTabConfig:Seek(2, { "view", "TypeCon" } )
		nTpConsulta := iif(oTabConfig:value("valor", .t.) == 'T', 1, 0)
	endif
	
	//--------------------------------------------------------
	// Verifica o tipo de cálculo das colunas.
	//--------------------------------------------------------
	If nTpConsulta == 0	
		for nInd := 1 to nCols
			aAdd(aaBuffer, "<col width='"+buildMeasure(abs(aWidth[nInd]))+"'>")
		next
	Else
		nInd := 1		
		While nInd <= nCols
			For nX := 1 To Len(aInd)
				//----------------------------------------------------------------
				// nTamMax recebe o tamanho máximo que os dados(números) da consulta
				// poderão ter. Criada porque o T O T A L utiliza outra fonte e 
				// outro tamanho e pode desposicionar a tabela.
				// * 10 porque é o tamanho em pixel dos números para Verdana 13.
				//----------------------------------------------------------------
				nTamMax := aInd[nX]:Tam() * 10
				
				//----------------------------------------------------------------
				// Recebe o tamanho em pixels da maior palavra da string.
				//----------------------------------------------------------------
				nMaxStr := DwcalcTxtPx(DwAnaliMax( aInd[nX]:Desc() ))
				
				//----------------------------------------------------------------
				// O Tamanho da coluna será o maior entre nTamMax e nMaxStr.
				//---------------------------------------------------------------- 				
				aAdd(aaBuffer, "<col width='" + iif(nTamMax > nMaxStr, DwStr(nTamMax), DwStr(nMaxStr)) + "px'>")
				nInd++				
			Next
		EndDo
	EndIf
	           
	// dados                         
	nAttY := aoConsulta:DimCountY()  
	if nAtty == 0
		nAttY := 1
	endif
	
	for nInd := 1 to TR_LIMIT * nAttY
		cClass := iif(oSigaDW:RowColor()=="1", "zebraOff", iif(mod(nInd,2) == 0, "zebraOff", "zebraOn"))
		cClass += iif(nInd > TR_LIMIT_MIN, " hidden", "")
		aAdd(aaBuffer, "<tr class='"+cClass+"' onClick='pivotPickUp(2, this)' onMouseOver='pivotRollover(2, this, true)' onMouseOut='pivotRollover(2, this, false)'>")
		for nInd2 := 1 to nCols
			if aoConsulta:HintOn() .AND. aoConsulta:AlertOn()   
				//Parametros da funcao: 1 - MouseOver; 2 - MouseOut
				aAdd(aaBuffer, "<td onMouseOver='showHint(this,1)' onmouseout='showHint(this,2)' nowrap='true'>&nbsp;</td>")
			else                                                                     
				aAdd(aaBuffer, "<td nowrap='true'>&nbsp;</td>")
			endif
		next
		aAdd(aaBuffer, "</tr>")
	next
	aAdd(aaBuffer, "</table>")

	If nTpConsulta == 0
		aaBuffer[nInitRow] := "<table summary='' class='ind' id='tabInd' style='table-layout: auto;width:"+buildMeasure(anTabInd)+"'>"			
	Else
		aaBuffer[nInitRow] := "<table summary='' class='ind' id='tabInd' style='table-layout: auto;'>"	
	EndIf
	
return

static function buildDragArea(aaBuffer)
	aAdd(aaBuffer, "<div id='dragArea'></div>")
return

static function buildTable(aaBuffer, aoConsulta, alNoTotal)
	local aBuffer := aaBuffer
	local aWidth
	local nAttWidth := 0, nIndWidth := 0
	local nAttDivWidth := 0, nIndDivWidth := 0
	local nDivWidth := 0, nTabInd := 1
	local lShowScroll := .T.

	// determina a largura dos atributos
	aWidth := calcWidthCols(aoConsulta, iif(valType(alNoTotal) == "L", alNoTotal, nil))
	nAttWidth := aWidth[1]
	nIndWidth := aWidth[2]
	
	// determina a largura das divisões e tabelaas
	nDivWidth := nAttWidth + nIndWidth
  	if oUserDW:UserPanel() == PAN_SIMPLES
		nAttDivWidth := nAttWidth
		nIndDivWidth := nIndWidth
	else       
		if nDivWidth > (HttpSession->Screen[SCREEN_WIDTH] * 0.85)
			if nAttWidth > ((HttpSession->Screen[SCREEN_WIDTH] * 0.85)/2)
				nAttDivWidth := (int(HttpSession->Screen[SCREEN_WIDTH] * 0.85)/2)
			else
				nAttDivWidth := nAttWidth
			endif
			nTabInd := (HttpSession->Screen[SCREEN_WIDTH] * 0.85) - nAttDivWidth
  			nIndDivWidth := nTabInd + CORRECAO_DUPLO + 90
			nTabInd := nIndDivWidth + 10
  			nDivWidth := 1
		else                          
			nAttDivWidth := nAttWidth 
			nIndDivWidth := nIndWidth 
			nTabInd := nIndDivWidth + 10
			lShowScroll := .F.
		endif		
	endif

	// prepara a divisão master
	aAdd(aBuffer, "<!-- query buildTable begin - modelo "+ iif(oUserDW:UserPanel() == PAN_SIMPLES, "(simples)", "(duplo)") +" -->")
	if isFireFox() // utilizado para ajustar o lay-out
		aAdd(aBuffer, "</td></tr><tr><td colspan='2'>")
	endif
  	
  	if oUserDW:UserPanel() == PAN_SIMPLES
  		If HttpSession->Origem == 'dwQryOnlineExec'
  			aAdd(aBuffer, '<div id="pivotPan" style="width:100%; height:770px; overflow: scroll;">')
  		Else
  			aAdd(aBuffer, '<div id="pivotPan" style="width:100%; height:'+buildMeasure(LIMIT_HEIGHT)+'; overflow: scroll;">')
  		EndIf
  		
		aAdd(aBuffer, "<table summary='' class='browse' id='browsePivot' style='table-layout: auto;width:"+buildMeasure(nDivWidth)+"'>")
		aAdd(aBuffer, "<col width='"+buildMeasure(nAttDivWidth)+"'>")
		aAdd(aBuffer, "<col width='"+buildMeasure(nIndDivWidth)+"'>")
	else
		aAdd(aBuffer, '<div id="pivotPan" style="width:100%; height:790px; overflow: scroll; overflow-x: scroll;">')
		aAdd(aBuffer, "<table summary='' class='browse' id='browsePivot' style='table-layout: auto;width:"+buildMeasure(nDivWidth)+"'>")
		aAdd(aBuffer, "<col width='"+buildMeasure(nAttDivWidth)+"'>")
		aAdd(aBuffer, "<col width='"+buildMeasure(nIndDivWidth)+"'>")
	endif

	//  --------------------------------------------------------------
	// header...
	aAdd(aBuffer, "<tr>")
	aAdd(aBuffer, "<td nowrap='true' bgcolor='#92AAC6'>")
                          
  	if oUserDW:UserPanel() == PAN_SIMPLES
		aAdd(aBuffer, "<div class='pivot' id='divAttHeader' style='overflow: hidden;'>")
	else
		aAdd(aBuffer, "<div class='pivot' id='divAttHeader' style='width:"+buildMeasure(nAttDivWidth) +";overflow: hidden;'>")
	endif
	buildAttHeader(aBuffer, aoConsulta, nAttWidth) // ...dos atributos        
  	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, "</td>")
	aAdd(aBuffer, "<td nowrap='true'>")
	
  	if oUserDW:UserPanel() == PAN_SIMPLES
 		aAdd(aBuffer, "<div class='pivot' id='divIndHeader' style='overflow: hidden;'>")
	else
		aAdd(aBuffer, "<div class='pivot duplo' style='width:"+buildMeasure(ntabInd) +";overflow: hidden;margin-right:25px' id='divIndHeader'>")
	endif
	buildIndHeader(aBuffer, aoConsulta, nIndWidth, , nTabInd) // ...dos indicadores
 	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, "</td>")
	aAdd(aBuffer, "</tr>")

	//  --------------------------------------------------------------
	// dados...
  	if oUserDW:UserPanel() == PAN_SIMPLES
		aAdd(aBuffer, "<tr style='height:"+buildMeasure(LIMIT_HEIGHT)+"'>")
		aAdd(aBuffer, "<td nowrap='true'>")
 		aAdd(aBuffer, "<div class='pivot' id='divAtt' style='overflow: hidden;'>")	
	else		
		/*Manter scroll horizontal ativo para evitar desalinhamento das informações na tabela.*/	
		aAdd(aBuffer, "<tr style='height:"+buildMeasure(LIMIT_HEIGHT-SCROLL_AJUSTE)+"'>")
		aAdd(aBuffer, "<td nowrap='true'>")
		aAdd(aBuffer, "<div class='pivot' id='divAtt' style='width:"+buildMeasure(nAttDivWidth)+";height:" + buildMeasure(LIMIT_HEIGHT) + "; overflow-x: scroll; overflow-y: hidden;' onscroll='verifyScrollTables(this, true);'>")
	endif
	buildAttData(aBuffer, aoConsulta, nAttWidth) // ...dos atributos
 	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, "</td>")
	aAdd(aBuffer, "<td nowrap='true'>")

	if oUserDW:UserPanel() == PAN_SIMPLES
 		aAdd(aBuffer, "<div class='pivot' style='overflow: hidden;'>")
	else  
		/*Manter scroll horizontal ativo para evitar desalinhamento das informações na tabela.*/	
		aAdd(aBuffer, "<div class='pivot duplo' id='divInd' style='width:"+buildMeasure(nIndDivWidth + CORRECAO_DUPLO) + ";height:" + buildMeasure(LIMIT_HEIGHT) + ";overflow: "+iif(lShowScroll, "scroll", "auto") +"; overflow-x: scroll;' onscroll='verifyScrollTables(this, false);'>")		
	endif
	buildIndData(aBuffer, aoConsulta, nIndWidth, nTabInd) // ...dos indicadores
 	aAdd(aBuffer, "</div>")
	
	//  --------------------------------------------------------------
	aAdd(aBuffer, "</td>")
	aAdd(aBuffer, "</tr>")
	aAdd(aBuffer, "</table>")
 	aAdd(aBuffer, "</div>")
 	buildDragArea(aaBuffer)

  // fecha divisao master

	// ...para resize das colunas
//	buildColResize(aaBuffer, aoConsulta:DimFieldsY(), aoConsulta:AttWidth(), .t., aoConsulta)
//	buildColResize(aaBuffer, aoConsulta:Indicadores(), aoConsulta:IndWidth(), .f., aoConsulta)

	// ...para resize dos paineis
	//if !(oUserDW:UserPanel() == PAN_SIMPLES)
//		aAdd(aBuffer, "<div class='pivotResize' id='divResize' typePan=3>&nbsp;</div>")
//		aAdd(aBuffer, "<div class='pivotResizeLine' id='divPanResizeLine'>&nbsp;</div>")
//	endif

	aAdd(aBuffer, "<!-- query buildTable end -  -->")
return

function showQueryPage(aoConsulta, acPage, anColsAtt, anColsInd)
	local aBuffer := {}, aDDKeys
	local nColsX := 0, aColsX := {}
	local nInd, nAux, aAux

	if aoConsulta:DimCountX() > 0
		nColsX := aoConsulta:readAxisX(aColsX, , .t., .t.)
	else
		nColsX := anColsInd
	endif
			
	aAdd(aBuffer, tagJS())
	aAdd(aBuffer, "window.l_queryPageonload = true;")
	aAdd(aBuffer, "function u_queryPageonload()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  var oDocParent = getParentDoc();")
	aAdd(aBuffer, "  showWait(oDocParent);")
	aAdd(aBuffer, "  var oRowAtt, oRowInd;")
	aAdd(aBuffer, "  var nRowBase = 0;")
	aAdd(aBuffer, "  var lInsertRow = false;")
	aAdd(aBuffer, "  var nRowAtt = 0;")
	aAdd(aBuffer, "  var nRowInd = 0;")
	aAdd(aBuffer, "  var oTabAtt  = getElement('tabAtt', oDocParent);")
	aAdd(aBuffer, "  var oTabInd  = getElement('tabInd', oDocParent);")
	aAdd(aBuffer, "  var oTabHeader = getElement('attHeader', oDocParent);")
  	if oUserDW:UserPanel() == PAN_SIMPLES
		aAdd(aBuffer, "  var oPivotPan  = getElement('pivotPan', oDocParent);")
	else
		aAdd(aBuffer, "  var oPanAtt  = getElement('divAtt', oDocParent);")
		aAdd(aBuffer, "  var oPanInd  = getElement('divInd', oDocParent);")
	endif
	aAdd(aBuffer, "  var oDocto = oTabAtt.ownerDocument;")
	aAdd(aBuffer, "  var aData = new Array();")                             
	aAdd(aBuffer, "  var cParentID = '';")
	
	// esconder as colunas de drilldown
	If oSigaDW:WidthColDD() == -1
		aAux := aoConsulta:DimFieldsY()
		If !empty(HttpGet->DD)
			aAdd(aBuffer, "	 getElement('AttHdr" + aAux[DwVal(HttpGet->DL)]:Alias() + "', oDocParent).style.display = '';")
			aAdd(aBuffer, "	 getElement('AttData" + aAux[DwVal(HttpGet->DL)]:Alias() + "', oDocParent).style.display = '';")
		ElseIf !empty(HttpGet->DU)
			// verifica se tem alguma drilldown no histórico, pois isto indicaria vários níveis de drilldown e por isso não pode esconder a coluna de drilldown
			If aScan( aoConsulta:DrillHist(), {|x| x[1] >= DwVal(HttpGet->DL)} ) == 0
				aAdd(aBuffer, "	 getElement('AttHdr" + aAux[DwVal(HttpGet->DL)+1]:Alias() + "', oDocParent).style.display = 'none';")
				aAdd(aBuffer, "	 getElement('AttData" + aAux[DwVal(HttpGet->DL)+1]:Alias() + "', oDocParent).style.display = 'none';")
			EndIf
		EndIf
		aAdd(aBuffer, "  hideWait(oDocParent);")
	EndIf
	
	aAdd(aBuffer, "  function prepRow(oWKTab, nWKRow, anCols, alAtt, alTotal)")
	aAdd(aBuffer, "  {")
	aAdd(aBuffer, "    var tbody, tr, td, text, oRowBase;")
	aAdd(aBuffer, "    if (lInsertRow)")
	aAdd(aBuffer, "    {")
	aAdd(aBuffer, "      tbody = oWKTab.tBodies[0];")
 	aAdd(aBuffer, "      tr = oDocto.createElement('TR');")
	aAdd(aBuffer, "      for (var nCell = 0; nCell < anCols; nCell++)")
	aAdd(aBuffer, "      {")
	aAdd(aBuffer, "        td = oDocto.createElement('TD');")
	aAdd(aBuffer, "        text = oDocto.createTextNode(' ');")
	aAdd(aBuffer, "        td.insertBefore(text, null);")
	aAdd(aBuffer, "        tr.insertBefore(td, null);")
	aAdd(aBuffer, "      }")
 	aAdd(aBuffer, "      var oRowBase = oWKTab.rows[nWKRow];")
	aAdd(aBuffer, "      tbody.insertBefore(tr, oRowBase);")
	aAdd(aBuffer, "      tr.parentRow = cParentID;")
	aAdd(aBuffer, "      tr.id = tr.parentRow + '_'+ tr.rowIndex.toString(16);")
	aAdd(aBuffer, "      var nType = alAtt?1:2;")
	aAdd(aBuffer, "      tr.onclick	= new Function ('pivotPickUp('+nType+', this)');")
	aAdd(aBuffer, "      tr.onmouseover	= new Function ('pivotRollover('+nType+', this, true)');")
	aAdd(aBuffer, "      tr.onmouseout	= new Function ('pivotRollover('+nType+', this, false)');")
 	aAdd(aBuffer, "      oRow = tr;")
 	aAdd(aBuffer, "    } else")
	aAdd(aBuffer, "    {")
 	aAdd(aBuffer, "      oRow = oWKTab.rows[nWKRow];")
	aAdd(aBuffer, "      if (!oRow)")
	aAdd(aBuffer, "      {")
	aAdd(aBuffer, "        var lOldInsertRow = lInsertRow;")
	aAdd(aBuffer, "        lInsertRow = true;")
 	aAdd(aBuffer, "        oRow = prepRow(oWKTab, nWKRow-1, anCols, alAtt, alTotal);")
	aAdd(aBuffer, "        lInsertRow = lOldInsertRow;")
	aAdd(aBuffer, "      }")
 	aAdd(aBuffer, "      oRow.parentRow = 0;")
 	aAdd(aBuffer, "      var oCells = oWKTab.rows[nWKRow].cells;")
	aAdd(aBuffer, "      for (var nCell = 0; nCell < anCols; nCell++) {")
	if aoConsulta:alertOn()
		aAdd(aBuffer, "      	oCells[nCell].style.backgroundColor = '';")
	endif

	if isFireFox()
		aAdd(aBuffer, "        oCells[nCell].textContent = '';")
	else
		aAdd(aBuffer, "        oCells[nCell].innerText = '';")
	endif
	aAdd(aBuffer, "      }")
	aAdd(aBuffer, "    }")

	if oSigaDW:RowColor()=="1"
		aAdd(aBuffer, "    oRow.className = 'zebraOff' + (alTotal?' total':'');")
	else                                                               	
		aAdd(aBuffer, "    oRow.className = 'zebra' + ((oRow.rowIndex % 2) == 0?'On':'Off') + (alTotal?' total':'');")
	endif
	aAdd(aBuffer, "    return oRow;")
	aAdd(aBuffer, "  }")

	aAdd(aBuffer, "  function setCurvaABC(oTR, cColor, cCurva)") 
	aAdd(aBuffer, "  {")
  	aAdd(aBuffer, "    function clearCurvaABC()")
  	aAdd(aBuffer, "    {")
  	aAdd(aBuffer, "      var re = /curva+|curva/gi;")
  	aAdd(aBuffer, "      oTR.cells[0].className = oTR.cells[0].className.replace(re, '');")
  	aAdd(aBuffer, "    }")
  	aAdd(aBuffer, "    clearCurvaABC();")
	aAdd(aBuffer, "    cColor = cColor?cColor:'';")
	aAdd(aBuffer, "    oTR.cells[0].style.backgroundColor = cColor;") 
	aAdd(aBuffer, "    if (cCurva)") 
	aAdd(aBuffer, "     oTR.cells[0].className = oTR.cells[0].className + ' curva curva' + cCurva;") 
  	aAdd(aBuffer, "    	for (var nCell = 1; nCell < oTR.cells.length; nCell++)")
	aAdd(aBuffer, "      oTR.cells[nCell].style.backgroundColor = cColor;") 
	aAdd(aBuffer, "  }")

	aAdd(aBuffer, "  function initRow(alTotal)")
	aAdd(aBuffer, "  {")
	aAdd(aBuffer, "    oRowAtt = prepRow(oTabAtt, nRowAtt, "+dwStr(anColsAtt)+", true, alTotal);")
	aAdd(aBuffer, "    oRowInd = prepRow(oTabInd, nRowInd, "+dwStr(nColsX)+", false, alTotal);")
 	aAdd(aBuffer, "    nRowAtt++;")
	aAdd(aBuffer, "    nRowInd++;")
	aAdd(aBuffer, "  } ")

	If !(oSigaDW:WidthColDD() == -1 .and. !empty(HttpGet->DU))
		aAdd(aBuffer, "  initVars();")
		makePage(aBuffer, aoConsulta, acPage)
	EndIF
	
  	if !empty(isNull(httpGet->idBase, ""))
		calcWidthCols(aoConsulta)
		aAdd(aBuffer, "  function initVars()")
		aAdd(aBuffer, "  {")
		aAdd(aBuffer, "    cParentID = '" + dwStr(httpGet->idBase) + "';")
		aAdd(aBuffer, "    nRowBase = " + dwStr(httpGet->rowBase) + " + 1;")
		aAdd(aBuffer, "    lInsertRow = true;")
		aAdd(aBuffer, "    nRowAtt = nRowBase;")
		aAdd(aBuffer, "    nRowInd = nRowBase;")
		aAdd(aBuffer, "  }")
		
		aAdd(aBuffer, "  doDrillEnd(oTabAtt.rows[nRowBase-1], oTabAtt.rows[nRowBase],"+; 
     			          dwStr(anColsAtt)+","+dwStr(abs(aoConsulta:AttWidth()[aoConsulta:DrillLevel()]))+", oTabHeader, oTabAtt,0);")
	else
		aAdd(aBuffer, "  function initVars()")
		aAdd(aBuffer, "  {")
		aAdd(aBuffer, "    cParentID = '';")
		aAdd(aBuffer, "    nRowBase = 0;")
		aAdd(aBuffer, "    lInsertRow = false;")
		aAdd(aBuffer, "    nRowAtt = nRowBase;")
		aAdd(aBuffer, "    nRowInd = nRowBase;")
		aAdd(aBuffer, "  }")       
		aAdd(aBuffer, "  while (oRowAtt = oTabAtt.rows[nRowAtt])")
		aAdd(aBuffer, "  {")
		aAdd(aBuffer, "    oTabAtt.deleteRow(nRowAtt);")
		aAdd(aBuffer, "    oTabInd.deleteRow(nRowInd);")
		aAdd(aBuffer, "  }")

		if aoConsulta:HaveDrillDown()
			nAux := aoConsulta:DrillLevel()
			for nInd := 1 to anColsAtt
				if nInd < nAux
					aAdd(aBuffer, "doChangeIcone(oTabHeader, "+dwStr(nInd)+","+urlImage("drillup.gif")+");")
				else
   					aAdd(aBuffer, "doChangeIcone(oTabHeader, "+dwStr(nInd)+","+urlImage("drilldown.gif")+");")
   				endif
   			next
		endif
	endif                                    

	if oUserDW:UserPanel() == PAN_SIMPLES
		aAdd(aBuffer, "  doAdjustHeight(oTabAtt, oTabInd);")
		if empty(aoConsulta:DDFilter())
			aAdd(aBuffer, "  oPivotPan.scrollTop = 0;")
		endif
	else
		if empty(aoConsulta:DDFilter())
			aAdd(aBuffer, "  oPanAtt.scrollTop = 0;")
			aAdd(aBuffer, "  oPanInd.scrollTop = 0;")
		endif
	endif

  	if aoConsulta:FatorEscala() > 1
		aAdd(aBuffer, "  var oSpan = getElement('msgButtonContainer', oDocParent);")
	  	aAdd(aBuffer, "  oSpan.innerHTML = '" + STR0026 + " "+ alltrim(transform(aoConsulta:FatorEscala(), dwMask("999,999,999"))) +"';") //###"Indicadores x"
  	endif

	aAdd(aBuffer, "  hideWait(oDocParent);")
	aAdd(aBuffer, "}")

	aAdd(aBuffer, "</script>")

	aEval(aBuffer, { |x| httpSend(x+CRLF) })
return ""

// variaveis de trabalho              

// ********************************************************************************************************
// ********************************************************************************************************
// ********************************************************************************************************
// ********************************************************************************************************
static function makePage(aaBuffer, aoConsulta, acPage, aoExport)
	local nOrder, aProgram, aAux, aRank, aWhere
	local nInd, nInd2, aIndexFields, cCols, cAux, dAux
	local cbProgram, lAux
	local cMask	:= ""
	local nRecLimit	:= 0
	local aAlerts
	
	// parametros de linha
	local cFilename, nPos
	local lView := .f., lForceLoad := .f.
	local cPrefixo := ""
	local aHeaders, aQryHeaders
	
	private lProcDD := .f.
	private lSubTotalRank := .f.
	private nFatorCorrecao := 1
	private _aaBuffer := aaBuffer
	private oConsulta := aoConsulta
	private cbEOF
	private nDrillLevel := 0, cAdvPlFilter := "", cMasterFilter := "", cOrderBy := ""
	private lPagingDesc := .f.
	private aRecValues := {}
	private nRowSend := 0, aRowSend
	private oDSExp
	private aDataPage
	private nDataRow, cOldWhereY
	private aDDKeys
	private oMakeExp := aoExport
	private lMakeExp := valType(oMakeExp) == "O"
	private lDplRow := iif(lMakeExp, oMakeExp:HideEquals(), .t.)
	private lNoTotals := iif(lMakeExp, oMakeExp:HideTotals(), .f.)
	private nRecPage := 0
	private n_LenDimY, nLenDimX, n_LenInd, aInd, aDimY, aDimX, nLastDimY
	private aColsX := {}, nColsX := 0, aTotGlobal, aTotGer, aTotAux, aTotPar, lTotGlob, lTotPar := .f., lOnlyPar := .f.
	private lCanShowTotal := .t.
	private cbEscala
	private lAjustarDD := .f.
	private lNextPage := !lMakeExp .and. oUserDW:showPageNav() == CHKBOX_ON
	private lPrevPage := !lMakeExp .and. oUserDW:showPageNav() == CHKBOX_ON .and. !(HttpGet->acao == FIRST_PAGE)
	private cSQLForPage := ""
	
	dwStatOn("TabPage " + iif(DWIsDebug(), aoConsulta:WorkFile()+ " (" + STR0027 + ":" + dwCubeName(aoConsulta:Cube():id()) + ")", aoConsulta:Name())) //###"Fato"
	#ifdef DWCACHE
	#else
		if aoConsulta:inCache()
			aoConsulta:updFromCache()
		endif
	#endif
	
	cOldWhereY := ""
	
	lSubTotalRank := oConsulta:rankOn() .and. oConsulta:rankSubtotal()
	if lSubTotalRank
		if oConsulta:haveDrillDown()
			if !(oConsulta:RankDef(oConsulta:drillLevel())[3] == RNK_MENORES)
				nFatorCorrecao := -1
			endif
		else
			if !(oConsulta:RankDef(1)[3] == RNK_MENORES)
				nFatorCorrecao := -1
			endif
		endif
	endif
	
	oConsulta:FieldList()
	aDimX := oConsulta:DimFieldsX()
	aDimY := oConsulta:DimFieldsY()
	aInd  := oConsulta:Indicadores()
	
	nLastDimY := len(oConsulta:DimFieldsY())
	n_LenDimY := oConsulta:DimCountY()
	nLenDimX := oConsulta:DimCountX()
	
	// retira indicadores adicionados por serem utilizados em campos virtuais
	aAux := {}
	aEval(aInd, {|xElem,i| iif(xElem:Ordem() > -1, aAdd(aAux, xElem), NIL)})
	aInd := aAux
	
	n_LenInd := len(aInd)
	
	aeval(aDimX, { |x| iif(x:Temporal() <> 0 .and. x:Temporal() <> DT_PERIODO, x:Tipo("N"), nil) })
	aeval(aDimY, { |x| iif(x:Temporal() <> 0 .and. x:Temporal() <> DT_PERIODO, x:Tipo("N"), nil) })
	
	// Prepara para o drill-down
	aFilter := {}
	if !empty(httpGet->DD)
		nDrillLevel := dwVal(HttpGet->DL) - 1
		httpGet->DD := URLDecode(httpGet->DD)
		if ("*all*" $ httpGet->dd)
			aAux := dwToken(httpGet->dd, "!")
			aSize(aAux, nDrillLevel)
			httpGet->DD := dwConcatWSep("!", aAux) + "!*all*!"
			lAjustarDD := .t.
		else
			lProcDD := .t.
		endif
		oConsulta:DrillParms(nDrillLevel, httpGet->DD)
	else
		nDrillLevel := oConsulta:DrillLevel()
	endif
	
	//Para consultas sem Drill Down, verificar a quantidade de registros, que sera apresentado em tela ,
	// que o usuario configurou. Caso o usuario nao tenha informado a quantidade de registros, sera assumido
	// o informado na configuracao do Administrador. 
	if lProcDD
		nRecLimit := max(PIVOT_SIZE - 1, nRecPage)
	elseif !lMakeExp
		nRecLimit := if(oUserDW:RecLimit() == 0, oSigaDW:RecLimit(), oUserDW:RecLimit())
		//======================================================================
		// Se não foi definido a quantidade máxima de registros no usuário e 
		// no DW, atribui um valor padrão para realizar o cálculo da paginação
		//======================================================================
		If nRecLimit == 0
			nRecLimit := 50
		EndIf
	endif
	
	if lMakeExp
		nRecPage := 100
	elseif lProcDD
		nRecPage := if((nDrillLevel + 1 > 1 .and. !(dwToken(oConsulta:DrillParms()[2], "!", .f.)[nDrillLevel] == "*all*")), MAX_LINES, nRecLimit)
	else
		nRecPage := nRecLimit
	end
	oConsulta:pageSize(nRecPage)
	
	if lProcDD .and. !empty(oConsulta:DrillParms()[2])
		aDDKeys := dwToken(oConsulta:DrillParms()[2], SEL_DD, .f.)
		aSize(aDDKeys, nDrillLevel)
		
		if nDrillLevel < nLastDimY
			nDrillLevel++
		endif
		oConsulta:PrepDrill(DRILLRESET)

		if nDrillLevel > 1
			while oConsulta:PrepDrill(DRILLDOWN, .f.) < nDrillLevel
			enddo
		endif
	endif
	
	aAux := oConsulta:AdvPlList(.t.)
	if oConsulta:Filtered() .and. len(aAux) > 0
		cAdvPlFilter := dwConcatWSep(".and.", aAux)
		oTable:Filter(cAdvPlFilter)
	endif
	
	// Verifica a aplicação de drill-down
	if nDrillLevel==0
		nDrillLevel := oConsulta:DrillLevel()
	endif
	
	if nDrillLevel != 0
		if lMakeExp .and. len(oConsulta:DrillHist()) > 0
			aEval(oConsulta:DrillHist(), { |x| nDrillLevel := max(nDrillLevel, x[1]) })
			nDrillLevel++
		endif
	endif
	
	// Tratar rank
	aAux := {}
	aeval(aDimY, { |x| aAdd(aAux, x:Alias())})
	
	aIndexFields := {}
	
	if oConsulta:HaveRank(nDrillLevel) .and. oConsulta:RankOn()
		lDplRow := !(oConsulta:rankStyle() == RNK_STY_CURVA_ABC)
		lNoTotals := !oConsulta:RankTotal() .and. ascan(aInd, { |x| x:AggFunc() == AGG_ACUM }) == 0
	endif
	
	if !empty(cAdvPlFilter)
		oTable:Filter(cAdvPlFilter)
	endif
	
	if lMakeExp
		aDataPage := {}
		oDSExp := oConsulta:GetDSForExport()
		cbEOF := { || oDSExp:eof() }
	else
		oDSExp := oConsulta:GetDS(acPage, lProcDD)
		if !isNull(httpGet->DD) .and. oConsulta:haveDrillDown()
			if empty(httpGet->DD)
				aAux := array(nDrillLevel+1)
				aFill(aAux, "*all*")
				oConsulta:updDDSql(nDrillLevel, dwConcatWSep("!", aAux), oDSExp:sqlInUse())
			else
				oConsulta:updDDSql(nDrillLevel-1, httpGet->DD, oDSExp:sqlInUse())
			endif
		endif
		cbEOF := { || oDSExp:EoF() .or. oConsulta:flEoF }
	endif
	cSQLForPage := oDSExp:sqlInUse()

	// Prepara o eixo X
	if nLenDimX > 0
		nColsX := oConsulta:readAxisX(aColsX, , , iif(lMakeExp, lNoTotals, nil), iif(lMakeExp, .f., nil))
	else
		aColsX := { "" }
		nColsX := 1
	endif
	
	// Apura total para calculo de participação total
	lTotPar := ascan(aInd, { |x| x:AggFunc() == AGG_PAR .or. x:AggFunc() == AGG_PARTOT .or. x:AggFunc() == AGG_ACUMPERC }) <> 0
	lOnlyPar := ascan(aInd, { |x| x:AggFunc() == AGG_PAR }) <> 0
	aTotPar := array(n_LenInd*nColsX)
	aTotAux := array(n_LenDimY)
	
#ifdef DWCACHE
	if !DWisWebEx() .or. !(valType(oConsulta:faTotGeral) == "A")
		aTotGer := array(n_LenInd*nColsX)
		getTotal(0, aTotGer)
		oConsulta:faTotGeral := aTotGer
	else
		aTotGer := oConsulta:faTotGeral
	endif
#else
	if !DWisWebEx() .or. !oConsulta:inCacheInfo("TotGeral")
		aTotGer := array(n_LenInd*nColsX)
		getTotal(0, aTotGer)
		oConsulta:setCacheInfo("TotGeral", aTotGer)
	else
		aTotGer := oConsulta:getCacheInfo("TotGeral")
	endif
#endif
	
	if lTotPar .or. oConsulta:RankOn()
		lAux := lNoTotals
		lNoTotals := .f.
		if n_LenDimY == 1 .or. oConsulta:RankOn()
			aTotPar := aClone(aTotGer)
			aTotAux := aClone(aTotGer)
			lTotPar := .f.
		endif
		lNoTotals := lAux
	endif
	
	lTotGlob := ascan(aInd, { |x| x:AggFunc() == AGG_PARGLOB }) <> 0
	if lTotGlob
#ifdef DWCACHE
		if !DWisWebEx() .or. !(valType(oConsulta:faTotGlobal) == "A")
			aTotGlobal := array(n_LenInd*nColsX)
			getTotGlobal(aTotGlobal)
			oConsulta:faTotGlobal := aTotGlobal
		else
			aTotGlobal := oConsulta:faTotGlobal
		endif
#else
		if !DWisWebEx() .or. !oConsulta:inCacheInfo("TotGlobal")
			aTotGlobal := array(n_LenInd*nColsX)
			getTotGlobal(aTotGlobal)
			oConsulta:setCacheInfo("TotGlobal", aClone(aTotGlobal))
		else
			aTotGlobal := oConsulta:getCacheInfo("TotGlobal")
		endif
#endif
	endif
	
	/*********************************************************************
	Inicia o download da página
	*********************************************************************/
	if (lMakeExp)
		for nInd := 1 to len(aInd)
			cMask := aInd[nInd]:Mascara()
			if !empty(cMask)
				oMakeExp:AddStyle("pivotInd", cMask)
			endif
		next nInd

		if aoConsulta:AlertOn() .and. oMakeExp:expAlert()
			aAlerts := aoConsulta:Alerts()
			for nInd := 1 to len(aAlerts)
				if empty(aAlerts[nInd]:Msgt())
					cAux := dwStr(aAlerts[nInd]:ExpHtml()[3])
				else
					cAux := dwStr(aAlerts[nInd]:Msgt())
				endif
				oMakeExp:addAlert('T' + strZero(aAlerts[nInd]:ID(),4), cAux)

				if empty(aAlerts[nInd]:MsgF())
					cAux := dwStr(aAlerts[nInd]:ExpHtml()[3])
				else
					cAux := dwStr(aAlerts[nInd]:MsgF())
				endif
				oMakeExp:addAlert('F' + strZero(aAlerts[nInd]:ID(),4), cAux)
			next
		endif
		
		aHeaders := {}
		aQryHeaders := oConsulta:HtmlHeader(lNoTotals, oMakeExp:FileType())
		// verifica se deve apresentar os filtros aplicados
		If oMakeExp:ShowFiltering()
			cCols := DwStr(n_LenDimY+n_LenInd)
			
			// verifica pelos filtros aplicados
			aAux := oConsulta:Where(.F.)
			If valType(aAux) == "A" .and. len(aAux) > 0
				cAux := ""
				aEval(aAux, {|oFilter| cAux += oFilter:ExpHtml("disabled",,,,, oConsulta:Params())[3] + STR0048 }) //###" E "
				cAux := left(cAux, len(cAux)-len(STR0048))
				aAdd(aHeaders, "<tr><td colSpan='" + cCols + "'><i><b>" + STR0045 + " </b>" + cAux + "</i></td></tr>") //###"Filtros aplicados:"
			EndIf
			
			// verifica a aplicação de Filtros de Seleção
			aAux := oConsulta:prepAutoFilter(,,.T.)
			If valType(aAux) == "A" .and. len(aAux) > 0
				cAux := ""
				aEval(aAux, {|cElem| cAux += "(" + cElem + ")" + STR0048}) //###" E "
				cAux := left(cAux, len(cAux)-len(STR0048))
				aAdd(aHeaders, "<tr><td colSpan='" + cCols + "'><i><b>" + STR0046 + " </b>" + cAux + "</i></td></tr>") //###"Filtros de Seleção:"
			EndIf
			aAdd(aHeaders, "<tr><td colSpan='" + cCols + "'>&nbsp;</td></tr>")
		EndIf
		
		aEval(aQryHeaders, {|x| aAdd(aHeaders, x)})
		
		oMakeExp:WriteInit(oConsulta:RecCount(), aHeaders, oConsulta:Name()+"|"+oConsulta:Desc())
	endif
	
	if oConsulta:FatorEscala() > 1
		cbEscala := &("{|| dwVal(cRet) / " + dwStr(oConsulta:FatorEscala()) +"}")
	else
		cbEscala := {|| dwVal(cRet) }
	endif
	
	/**********************************************************************
	Prepara "programa" de inicialização, avaliação e finalização de quebras
	**********************************************************************/
	aRowSend := array(iif(n_LenDimY==0,1,n_LenDimY))
	aFill(aRowSend, SEP_DATA)
	
	lCanShowTotal := oConsulta:Total() .and. (!lProcDD .or. lMakeExp)
	aProgram := {}
	aAdd(aProgram, "local _nRecNo,_nCol:=0, _aAux, _aWhere, _aRowAnt") //_lFirstRow := .f.,
	aAdd(aProgram, "local _nInd")
	aAdd(aProgram, "local _aDataDim:=array(iif(n_LenDimY>0,n_LenDimY,1))")
	aAdd(aProgram, "local _aTotInd:=array(iif(nColsX==1, n_LenInd, nColsX))")
	aAdd(aProgram, "local _aTotInd2:=array(len(_aTotInd))")
	aAdd(aProgram, "local _aImpTot := array(len(_aDataDim))")
	
	if len(aDimY) != 0
		aAdd(aProgram, "local _aTotInd3:=array(len(_aTotInd))")
	endif
	aAdd(aProgram, "local _" + DWCurvaABC() + " := nil")

	if oConsulta:RankOn()
		if oConsulta:RankStyle() == RNK_STY_CURVA_ABC
			aAdd(aProgram, "local _aTotCurvaABC:=array(len(_aTotInd))")
		endif

		if oConsulta:RankOutros() .or. oConsulta:RankTotal()
			aAdd(aProgram, "local _aTotOutros:=array(len(_aTotInd))")
		endif

		if oConsulta:RankSubTotal()
			aAdd(aProgram, "local _RnkField := '" + strTran(oConsulta:rankField()," desc", "") + "'")
			aAdd(aProgram, "local _RnkCol")
			aAdd(aProgram, "local _lFirstRow := .t.")
			aAdd(aProgram, "aAdd(_aTotInd, nil)")
			aAdd(aProgram, "aAdd(_aTotInd2, nil)")
			aAdd(aProgram, "aAdd(_aTotInd3, nil)")
			if oConsulta:RankOutros() .or. oConsulta:RankTotal()
				aAdd(aProgram, "aAdd(_aTotOutros, nil)")
			endif
		else
			aAdd(aProgram, "local _lFirstRow := .f.")
		endif
		aAdd(aProgram, "private _RnkMaxLimit := nil")
		aAdd(aProgram, "private _RnkMinLimit := nil")
	endif

	if len(aDimY) != 0
		aEval(aDimY, { |x| aAdd(aProgram, "local _"+x:Alias())})
	endif
	aAdd(aProgram, "aTotAux := array(n_LenDimY)")
	
	aAdd(aProgram, "If valType(HttpGet->acao) == 'C'")
	aAdd(aProgram, "	If HttpGet->acao == '" + PREVS_PAGE + "'")
	aAdd(aProgram, "		cbEOF := { |x| .F. }")
	aAdd(aProgram, "	EndIf")
	aAdd(aProgram, "	aDataPage := oConsulta:getPage(HttpGet->acao, oDSExp, lProcDD)")
	aAdd(aProgram, "Else")
	aAdd(aProgram, "	aDataPage := oConsulta:NextPage(oDSExp, lProcDD)")
	aAdd(aProgram, "EndIf")
	
	if len(aDimY) != 0
		if lSubTotalRank
			aAdd(aProgram, "_RnkCol := len(aDataPage[nDataRow])")
		endif
		
		aAdd(aProgram, "while isNotEOP()")
		if oConsulta:RankOn() .and. oConsulta:RankStyle() == RNK_STY_CURVA_ABC
			aAdd(aProgram, "_" + DWCurvaABC() + " := aTail(aDataPage[nDataRow])")
			aAdd(aProgram, "while isNotEOP() .and. _" + DWCurvaABC() + " == aTail(aDataPage[nDataRow])")
		endif

		if lSubTotalRank
			aAdd(aProgram, "  _lFirstRow := .t.")
		endif
		
		makeWhile(aProgram, 1, oConsulta:RankOn(), oConsulta:RankSubTotal() .and. oConsulta:dimCountY() > 1)
		
		if oConsulta:RankOn()
			if oConsulta:RankStyle() == RNK_STY_CURVA_ABC
				aAdd(aProgram, "enddo")
				aAdd(aProgram, "afill(_aTotCurvaABC, 0)")
				aAdd(aProgram, "if getTotal(-1     , _aTotCurvaABC, { " + ASPAS_D + DWCurvaABC() + " = '" + ASPAS_D + "+ _" + DWCurvaABC() + "+" + ASPAS_D + "'" + ASPAS_D + "})")
				aAdd(aProgram, "  sendRow(-1, _aDataDim, _aTotCurvaABC, .t., _nRecNo, _" + DWCurvaABC() + ")")
				aAdd(aProgram, "endif")
			endif
		endif
		aAdd(aProgram, "enddo")
		
		if lCanShowTotal
			aAdd(aProgram, "if eval(cbEOF)")
			aAdd(aProgram, "  afill(_aDataDim, '&nbsp;')")
			if oConsulta:RankOn()
				if  oConsulta:RankOutros() .and. oConsulta:haveRank()
					aAdd(aProgram, "  _aDataDim[1] := '[ " + STR0028 + " ]'") //###"Total Parcial"
					aAdd(aProgram, "  sendRow(0, _aDataDim, aTotGer, .t., 0, n_LenDimY, aTotGer)")
					aAdd(aProgram, "  if getRankOutros(_aTotOutros, _aTotInd)")
					aAdd(aProgram, "  	_aDataDim[1] := '[" + STR0030 + "]'") //###"outros"
					aAdd(aProgram, "    sendRow(0, _aDataDim, _aTotOutros, .f., 0, n_LenDimY, aTotGer)")
					aAdd(aProgram, "    oConsulta:rankOn(.f.)")
					aAdd(aProgram, "    getTotal(0, aTotGer)")
					aAdd(aProgram, "    oConsulta:rankOn(.t.)")
					aAdd(aProgram, "  endif")
				endif

				if oConsulta:RankTotal()
					if oConsulta:RankOutros()
						aAdd(aProgram, "  _aDataDim[1] := '["+ STR0029 +"]'") //###"T O T A L"
					else
						aAdd(aProgram, "  _aDataDim[1] := '[ " + STR0029 + " (" + STR0044 + ") ]'") //###"T O T A L" //"rank"
					endif
					aAdd(aProgram, "  sendRow(0, _aDataDim, aTotGer, .t., 0, n_LenDimY, aTotGer)")
     			else
					aAdd(aProgram, "  aFill(_aDataDim, '"+EOF_MARK+"')")
					aAdd(aProgram, "  aFill(_aTotInd, '"+EOF_MARK+"')")
					aAdd(aProgram, "  sendRow(0, _aDataDim, _aTotInd, .t., 0, n_LenDimY)")
				endif
			else
				aAdd(aProgram, "  _aDataDim[1] := '[ " + STR0029 + " ]'") //###"T O T A L"
				aAdd(aProgram, "  sendRow(0, _aDataDim, aTotGer, .t., 0, n_LenDimY, aTotGer)")
			endif

			if !lProcDD
				aAdd(aProgram, "else")
				if lNextPage .and. lPrevPage // .and. !(HttpGet->acao == FIRST_PAGE)
					aAdd(aProgram, "if oConsulta:haveNext()")
					aAdd(aProgram, "  aFill(_aDataDim, '"+NEXT_PREV_MARK+"')")
					aAdd(aProgram, "  aFill(_aTotInd, '"+NEXT_PREV_MARK+"')")
					aAdd(aProgram, "  sendRow(0, _aDataDim, _aTotInd, .t., 0, n_LenDimY)")
					aAdd(aProgram, "endif")
				elseif lNextPage
					aAdd(aProgram, "if oConsulta:haveNext()")
					aAdd(aProgram, "  aFill(_aDataDim, '"+NEXT_MARK+"')")
					aAdd(aProgram, "  aFill(_aTotInd, '"+NEXT_MARK+"')")
					aAdd(aProgram, "else")
					aAdd(aProgram, "  aFill(_aDataDim, '"+EOF_MARK+"')")
					aAdd(aProgram, "  aFill(_aTotInd, '"+EOF_MARK+"')")
					aAdd(aProgram, "endif")
					aAdd(aProgram, "sendRow(0, _aDataDim, _aTotInd, .t., 0, n_LenDimY)")
				elseif lPrevPage
					aAdd(aProgram, "if oConsulta:havePrevious()")
					aAdd(aProgram, "    aFill(_aDataDim, '"+PREV_MARK+"')")
					aAdd(aProgram, "    aFill(_aTotInd, '"+PREV_MARK+"')")
					aAdd(aProgram, "endif")
					aAdd(aProgram, "sendRow(0, _aDataDim, _aTotInd, .t., 0, n_LenDimY)")
				endif
			endif
			aAdd(aProgram, "endif")
		elseif !lProcDD
			// Se não for a última página não aparece a palavra F I M.
			aAdd(aProgram, "if eval(cbEOF)")
			aAdd(aProgram, "	aFill(_aDataDim, '&nbsp;')")
			aAdd(aProgram, "	aFill(_aTotInd, '&nbsp;')")
			aAdd(aProgram, "	_aDataDim[1] := '"+EOF_MARK+"';")
			aAdd(aProgram, "	sendRow(0, _aDataDim, _aTotInd, .t., 0, n_LenDimY)")
			aAdd(aProgram, "endif")
		endif
	else
		makeWhile2(aProgram, oConsulta:RankOn(), oConsulta:RankSubTotal())
	endif
	
	if lAjustarDD
		nDrillLevel := nDrillLevel + 1
	endif
	
	/*Exibe no console do server o programa gerado*/
	//aEval(aProgram, { |x,i| conout(dwConcat(x, " //Line:", str(i,3) ))})
	cbProgram := __compstr(dwConcatWSep(CRLF, aProgram))
	
	/*
	*********************************************************************
	Executa o "programa" gerado
	*********************************************************************
	*/
	dwStatOn("ExecCons " + iif(lMakeExp, STR0032, "")) //###"exportação"
	nDataRow := 1
	
	//if lMakeExp
	//  runExp()
	//else
	//	runCB()
		__runCB(cbProgram)
	//endif
	
	/**********************************************************************
	Finaliza a apresentação da página
	**********************************************************************/
	if lMakeExp
		oConsulta:endExp(oMakeExp)
	endif
	
	if valType(oDSExp) == "O"
		oDSExp:Close()
	endif
	
	dwStatOff()
	dwStatOff()
return 

static function isNotEOP()
return !dwKillApp() .and. nDataRow <= len(aDataPage)

static function prepDrill(anRecno, acValue, anLevel, acTag)
	local cRet := strTran(trim(dwStr(acValue)), " ", "&nbsp;"), nInd
	local cDDKey := ""
	
	if nDrillLevel != 0 
		if anLevel != nLastDimY
			for nInd := 1 to anLevel              
				if nDataRow < 2
					cDDKey += SEL_DD
				else
					cDDKey += dwStr(aDataPage[nDataRow-1, nInd]) + SEL_DD
				endif
			next		

			acValue := strTran(trim(dwStr(acValue)), " ", "&nbsp;")
			if anLevel == nDrillLevel   
				if !lMakeExp
					if  !(acTag == TAG_DIMTOTAL) .and. acValue != "[" + STR0030 + "]" //###"outros"
						cRet := tagImage("drilldown.gif", 9, 9, "","", cssCursorHand()+";margin-right:"+buildMeasure(5),"doDrill(this,"+dwStr(anLevel+1)+",escape('"+URLEncode(cDDKey)+"'))") + URLEncode(acValue)
 						cRet := strTran(cRet, "'", "\'")
					endif

					for nInd := n_LenDimY + 1 to nLastDimY 
						cRet += SEL_COL+SEP_DATA+acTag
					next
				endif
			endif
		endif
	endif   
return cRet

static function truncArray(aaValues)
	local nLen := len(aaValues), nInd

	if 	nLen > 0 .and. valType(aaValues[nLen]) == "U"
		for nInd := nLen to 1 step -1
			if valType(aaValues[nInd]) != "U"
				aSize(aaValues, nInd)
				exit
			endif
		next
	endif
return aaValues

static function getTotal(anLevel, aaTotal, aaWhere, anLevelX)
	local lRet := .t., aCols := 0, nInd
	local oQuery, cbFilter := {||.t.}
	local aAuxFilter := {}, aAux, x, i
	local aDados, nPos, lSum := .t., cSQL

	default anLevelX := -1
  
  	aFill(aaTotal, nil)

	// caso possui drilldown, só terá totalizante caso o nível seja a partir do nível original do DD
 	if anLevel > 0 .and. !lOnlyPar .and. ((oConsulta:RankSubTotal() .and. !aDimY[anLevel]:IsSubtotal()) .OR. ;
		  	 (oConsulta:HaveDrillDown() .and. anLevel <= oConsulta:DrillLevel()))
		return .f.
 	endif  
	
	// caso o nivel esteja desligado e não há participação, o processamento do mesmo é ignorado
	if anLevel > 0 .and. !lOnlyPar .and. !aDimY[anLevel]:IsSubtotal() 
		return .f.
	endif
	
	if !empty(aaWhere)
		if valtype(aaWhere[1])=="C" .and. "=" $ aaWhere[1]
		else
			trataAspas(aaWhere)
		endif
	endif

	oQuery := oConsulta:SQLTotal(anLevel, aaWhere,, anLevelX)
	if lSubTotalRank .and. anLevel > 0
		cSQL := oQuery:sqlInUse()
	  	oQuery:close()                                                       
	  	if valType(_RnkMaxLimit) == "N"
			  cSQL := strTran(cSQL, " " + dwStr(oConsulta:fnMinValue), " " + dwStr(_RnkMaxLimit))
	    endif

	  	if valType(_RnkMinLimit) == "N"
	  	  cSQL := strTran(cSQL, " " + dwStr(oConsulta:fnMaxValue), " " + dwStr(_RnkMinLimit))
	    endif
	    oQuery:Open(, cSQL)
	endif

	aCols := array(nLenDimX+1)
	nPos := 1
	lSum := valType(oQuery:Fields("L_E_V_E_L_")) == "U"
	while !oQuery:Eof()
		aFill(aCols, -1)
		if nLenDimX > 0
			if anLevelX <> -1 .and. oQuery:value("L_E_V_E_L_") == "1"       
        		for nInd := 1 to len(aCols) - 1
          			aCols[nInd] := len(aaTotal) - n_LenInd
        		next
      		else
		        for nInd := nLenDimX to 0 step -1         
        		  aCols[nInd+1] := searchCol(nInd!=nLenDimX, nInd, oQuery)
        		next
			endif
		else
			aCols[1] := searchCol(,,oQuery)
		endif                 

		for nInd := 1 to len(aCols)
			if aCols[nInd] > -1                                
				for i := 1 to len(aInd)   
					x := aInd[i]
					aaTotal[aCols[nInd]+i] := procCalcVal(x:AggFunc(), aaTotal[aCols[nInd]+i], oQuery:value(x:Alias()))
				next
			endif
		next
		oQuery:_Next()
	enddo
	oQuery:Close()

	if anLevel > 0
		lRet := lRet .and. aDimY[anLevel]:IsSubtotal()
		if lRet .and. oConsulta:rankOn()
			lRet := lSubTotalRank
		endif
	endif

  	if lMakeExp
		lRet := lRet .and. !lNoTotals
	endif
return lRet

static function procTotal(aoQuery, aaIndAcum)
	local aCols := 0, nInd
	local x, i

	aCols := array(nLenDimX+1)
	if nLenDimX == 0
		aCols[1] := searchCol(,,aoQuery)
	endif                 

	while !aoQuery:Eof()
		if nLenDimX > 0
 			for nInd := nLenDimX to 0 step -1
				aCols[nInd+1] := searchCol(nInd!=nLenDimX, nInd, aoQuery)
			next
		endif                 

		for nInd := 1 to len(aCols)
			if aCols[nInd] > -1                                
				for i := 1 to len(aInd)
					x := aInd[i]
					aaIndAcum[aCols[nInd]+i] := dwVal(aaIndAcum[aCols[nInd]+i]) + aoQuery:value(x:Alias())
				next
			endif
		next
		aoQuery:_Next()
	enddo
	aoQuery:Close()
return

static function getRankOutros(aaTotOutros, aaTotInd, anLevel)
  	local oQuery, lRet := .f.

  	if oConsulta:haveRank(anLevel) .and. oConsulta:RankOutros()
    	oQuery := oConsulta:SQLRnkTotOut(cSQLForPage)
    	procTotal(oQuery, aaTotOutros)
	    if valType(aaTotInd) == "A"
      		oConsulta:rankOn(.f.)
      		getTotal(0, aaTotInd)
      		oConsulta:rankOn(.t.)
    	endif
    	lRet := .t.
  	endif
return lRet

static function getTotGlobal(aaTotGlobal)
	local oQuery

	oQuery := oConsulta:SQLTotGlobal()
  	procTotal(oQuery, aaTotGlobal)
return .t.

static function prepData(axValue, acMask, acClassName, acStyle, acAliasInd, anLen, anDec, anAggFunc, anPos, aoMakeExp, acType, anLevel, aoInd, aaTotPar)
	local cRet, nVal, cStyle, aAux, cFormat := ""
	
	default acStyle := ""
	default acType := ""
	
	if valtype(axValue) == "A"
		cFormat := axValue[2]
		axValue := axValue[1]
	endif
	cRet := axValue
	
	if empty(cRet) .and. !(cRet == 0)
		cRet := "&nbsp;"
	else
		if anAggFunc == AGG_PAR .or. anAggFunc == AGG_PARTOT .or. anAggFunc == AGG_PARGLOB .or. anAggFunc == AGG_ACUMPERC
			cRet := dwVal(cRet)
		   	acMask := dwMask("999.999%") 
		   	
			if anAggFunc == AGG_PARGLOB
				aAux := aTotGlobal
			elseif anAggFunc == AGG_PARTOT .or. anAggFunc == AGG_ACUMPERC
				aAux := aTotGer
			else
				aAux := aaTotPar
			endif
			
			if valType(aAux) == "A" .and. len(aAux) >= anPos .and. valType(aAux[anPos]) != "U" .and. aAux[anPos] != 0
	    		if lMakeExp 
	    	  		if aoMakeExp:ShowFormat() .And. !(aoMakeExp:PercIsInd())		  
					  cRet := cRet * 100 / aAux[anPos]					  
					else  
		        		acMask := dwMask("999.999")
            			
            			if aoMakeExp:PercIsInd()
					    	cRet := cRet / aAux[anPos]
						else  
  					  		cRet := cRet * 100 / aAux[anPos]
  						endif  						
  					endif  						
	    		else
					cRet := cRet * 100 / aAux[anPos]
				endif				
			else
				cRet := ""
			endif

			if valType(cRet) == "N" .and. cRet > 100
				cRet := 100
			endif
		elseif !aoInd:canTotalize() .and. (acClassName == TAG_INDTOTAL .or. acClassName == TAG_INDSUBTOTAL .or. acClassName == TAG_INDSUBTOTAL2)
			cRet := "&nbsp;"
		else
			if empty(acMask) .and. valType(anLen) == "N"
				acMask := dwMask(replicate("9", anLen) + iif(anDec != 0, "." + replicate("9", dwVal(anDec)),""))
			endif
			cRet := eval(cbEscala)
		endif
		
		if acClassName != TAG_INDTOTAL .and. acClassName != TAG_INDSUBTOTAL .and. acClassName != TAG_INDSUBTOTAL2 .and. oConsulta:AlertOn()
			acStyle := iif(!empty(acStyle), ";","") + fmt2Html(cFormat, oConsulta:HintOn(), lMakeExp)
		endif
	endif
	
	// Exportação
	if(!lMakeExp)  
		if valType(cRet) == "C" .and. cRet == "&nbsp;"
		else
			nVal := dwVal(cRet)
			cRet := (iif(empty(acMask), dwStr(nVal), transform(nVal, acMask)))
			if right(cRet,1) == "*" // estouro de mascara
				cRet := "*"+dwStr(nVal)
			endif
		endif
		cRet := cRet + SEP_DATA + allTrim(acClassName) + SEP_DATA + allTrim(acStyle)
		cRet := strTran(cRet, "\\", "")   
	elseif valType(cRet) == "U"  
		cRet := ""      
	elseif (oMakeExp:FileType() == FT_DIRECT_EXCEL .or. oMakeExp:FileType() == FT_EXCEL_XML ;
	    	.or. oMakeExp:FileType() == 7) //dashboard	   
		if (empty(cRet) .or. (valType(cRet) == "C" .and. cRet == "&nbsp;")) .AND. acType == "N"
			cRet := "0"
		endif
		
		if !empty(acStyle) .and. oMakeExp:expAlert()
			cStyle := oMakeExp:AddStyle("pivotInd", acStyle, acMask)    
		elseif !empty(acMask)	
			cStyle := oMakeExp:AddStyle("pivotInd", acMask)	    		
		else 			
			cStyle := "pivotInd"
		endif 			    

		cRet := cStyle + SEL_COL + dwConvTo("C", cRet) + SEL_COL + acType + SEL_COL + DwStr(anAggFunc)		

		if "divHint" $ acStyle
			cRet += SEL_COL + substr(acStyle, at("divHint", acStyle))
    	endif      	
	else     
		nVal := dwVal(cRet)
		cRet := (iif(empty(acMask), dwStr(nVal), transform(nVal, acMask)))
		if right(cRet,1) == "*" // estouro de mascara
			cRet := "*"+dwStr(nVal)
		endif   
	endif
return allTrim(cRet)

static function fmt2Html(pcFmt, alHint)
	local cRet := "", cFmt, aFmt, nInd 

	if valType(pcFmt) == "C" .and. left(pcFmt, 1) == "@"
		aFmt := DWToken(pcFmt, ";", .f.)
		for nInd := 1 to len(aFmt)
			cFmt := aFmt[nInd]    
			if substr(cFmt, 3,1) == "B"
				cRet += "font-weight:bold;"
			elseif substr(cFmt, 3,1) == "I"
				cRet += "font-weight:italic;"
			endif

			if left(cFmt,2) == "@B"
				cRet += "background-color:#" + right(cFmt, 6) + ";"
			elseif left(cFmt,2) == "@F"
				cRet += "color:#" + right(cFmt, 6) + ";"
			endif

			if alHint .and. left(cFmt,1) == "#"
				  cRet += "divHint:" + substr(cFmt, 2) + ";"
			endif
		next
	endif	                              
return cRet

static function prepDim(axValue, acMask, acClassName, acStyle, aoMakeExp)
	local cRet

  	default acStyle := ""
	
	// Caso seja numérico mantém a máscara.
	If ValType( axValue ) != 'N'
		acMask := ""
	EndIf
	
	cRet := DWIsEmpty(axValue, iif(acClassName==TAG_DIMTOTAL,"",VAZIO))
		
	// Exportação
	if !lMakeExp
		cRet := (iif(empty(acMask), dwStr(cRet), transform(dwVal(cRet), acMask))) + SEP_DATA + allTrim(acClassName) + SEP_DATA + allTrim(acStyle)
	else
		cRet := iif(empty(acMask), AllTrim(dwStr(cRet)), AllTrim(transform(dwVal(cRet), acMask)))
	endif
return cRet

static function trataAspas(axValue)
	local cRet := "", nInd

	if valType(axValue) == "A"
		for nInd := 1 to len(axValue)
			axValue[nInd] := trataAspas(axValue[nInd])
		next
	elseif valType(axValue) == "C"
	  	if sgdb() == DB_DB2
		  	cRet := strTran(axValue, "'", "'||chr(39)||'")
		  	cRet := strTran(cRet, '"', "'||chr(34)||'")
	  	else
		  	cRet := strTran(axValue, "'", "'+chr(39)+'")
		  	cRet := strTran(cRet, '"', "'+chr(34)+'")
		endif  
	else
		cRet := axValue
	endif
return cRet

static function makeWhile(aaProgram, anLevel, alRank, alRankSubTotal)
	local lTotal := .f.
	local nAux := oConsulta:drillLevel()
	
	if nAux == 0
		nAux := n_LenDimY
	elseif lProcDD .or. lMakeExp
		nAux++
		if nAux > n_LenDimY
			nAux := n_LenDimY
		endif
	endif
	
	aAdd(aaProgram,  "_"+aDimY[anLevel]:Alias()+":=aDataPage[nDataRow,"+dwStr(anLevel)+"]")
	aAdd(aaProgram,  "_aDataDim["+dwStr(anLevel)+"]:=_"+aDimY[anLevel]:Alias())
	
	if anLevel == nAux
		aAdd(aaProgram, "aFill(_aTotInd, nil)")
	endif
	aAdd(aaProgram, "_aAux := {}")
	aEval(aDimY, { |x, i| aAdd(aaProgram, "aAdd(_aAux, _" + x:Alias() +")")}, 1, anLevel)

	if !(oConsulta:RankStyle() == RNK_STY_CURVA_ABC)
	  	if !(anLevel == nAux)
      		aAdd(aaProgram, "_aImpTot["+dwStr(anLevel)+"] := getTotal("+dwStr(anLevel)+", aTotPar, _aAux)")
		  	if lMakeExp .and. oConsulta:HaveDrillDown() .and. anLevel > 1
			  	aAdd(aaProgram, "if valType(aTotPar[1]) == 'U'")
  				aAdd(aaProgram, "  aTotAux["+dwStr(anLevel)+"] := aclone(aTotAux["+dwStr(anLevel-1)+"])")
		  		aAdd(aaProgram, "  aTotAux["+dwStr(anLevel-1)+"] := aclone(aTotGer)")
			  	aAdd(aaProgram, "else")
			  	aAdd(aaProgram, "  aTotAux["+dwStr(anLevel)+"] := aclone(aTotPar)")
  				aAdd(aaProgram, "endif")
	  		else
		  		aAdd(aaProgram, "aTotAux["+dwStr(anLevel)+"] := aclone(aTotPar)")
  			endif
		endif
	endif
	lTotal := .t.
	
	if oConsulta:RankOn() .and. oConsulta:RankStyle() == RNK_STY_CURVA_ABC
		aAux := { "while isNotEOP() .and. _" + DWCurvaABC() + " == aTail(aDataPage[nDataRow])" }
	else
		aAux := { "while isNotEOP()" }
	endif
	aEval(aDimY, { |x, i| aAdd(aAux, "_" + x:Alias() + " == aDataPage[nDataRow, "+dwStr(i)+"]")}, 1, anLevel)
	aAdd(aaProgram, dwConcatWSep(" .and. ", aAux))

	if anLevel == nAux
		aAdd(aaProgram, "  sumData(_aTotInd)")
		aAdd(aaProgram, "  _nRecNo := nDataRow")
		aAdd(aaProgram, "  _aRowAnt := aClone(aDataPage[nDataRow])")
		if lMakeExp
			if oMakeExp:flShowZero .or. oMakeExp:FileType() == FT_HTM
				aAdd(aaProgram, "  aEval(_aTotInd, { |x,i| _aTotInd[i] := iif(valType(x) == 'U', 0, x) })")
			endif
		endif
		aAdd(aaProgram, "nDataRow++")

		if lMakeExp
			aAdd(aaProgram, "if nDataRow > len(aDataPage) .and. !eval(cbEOF)")
			aAdd(aaProgram, "   dbSelectArea(oDSExp:Alias())")
			aAdd(aaProgram, "  	aDataPage := oConsulta:NextPage(oDSExp" + iif(!lMakeExp, ", lProcDD", "") + ")")
			aAdd(aaProgram, "   nDataRow := 1")
			aAdd(aaProgram, "endif")
		endif
		aAdd(aaProgram, "enddo")
		
		aAdd(aaProgram, "aEval(_aDataDim, { |x,i| _aDataDim[i] := _aRowAnt[i]})")
		if anLevel > 1
			aAdd(aaProgram, "sendRow("+dwStr(anLevel)+", _aDataDim, _aTotInd, .f., _nRecNo, _" + DWCurvaABC() + ", aTotAux["+dwStr(anLevel-1)+"])")
		else
			aAdd(aaProgram, "sendRow("+dwStr(anLevel)+", _aDataDim, _aTotInd, .f., _nRecNo, _" + DWCurvaABC() + ", aTotGer)")
		endif
		
		if lSubTotalRank
			aAdd(aaProgram, "if _lFirstRow")
			aAdd(aaProgram, "  _RnkMinLimit := aTail(_aTotInd)")
			aAdd(aaProgram, "  _lFirstRow := .f.")
			aAdd(aaProgram, "endif")
			aAdd(aaProgram, "_RnkMaxLimit := aTail(_aTotInd)")
		endif
	else
		makeWhile(aaProgram, anLevel+1, alRank, alRankSubTotal)
		
		aAdd(aaProgram, "enddo")
		aAdd(aaProgram,  "_aDataDim["+dwStr(anLevel+1)+"]:='&nbsp;'")
		if (!alRank .or. alRankSubTotal) .and. empty(oConsulta:DDFilter())
			if anLevel == 0
				aAdd(aaProgram, "if eval(cbEOF)")
			endif

			if alRankSubTotal
				aAdd(aaProgram, "_aAux := {}")
				aEval(aDimY, { |x, i| aAdd(aaProgram, "aAdd(_aAux, _" + x:Alias() +")")}, 1, anLevel)
				aAdd(aaProgram, "_aImpTot["+dwStr(anLevel)+"] := getTotal("+dwStr(anLevel)+", aTotPar, _aAux)")
				aAdd(aaProgram, "aTotAux["+dwStr(anLevel)+"] := aclone(aTotPar)")
			endif
			aAdd(aaProgram, "  if _aImpTot["+dwStr(anLevel)+"]")

			if anLevel > 1
				aAdd(aaProgram, "    sendRow("+dwStr(anLevel)+", _aDataDim, aTotAux["+dwStr(anLevel)+"], .t., nDataRow,"+dwStr(nAux)+", aTotAux["+dwStr(anLevel-1)+"])")
			else
				aAdd(aaProgram, "    sendRow("+dwStr(anLevel)+", _aDataDim, aTotAux["+dwStr(anLevel)+"], .t., nDataRow,"+dwStr(nAux)+", aTotGer)")
			endif
			aAdd(aaProgram, "    _lFirstRow := .f.")
			aAdd(aaProgram, "  endif")

			if anLevel == 0
				aAdd(aaProgram, "endif")
			endif
		endif
		
		if oConsulta:RankOn() .and. oConsulta:RankOutros() .and. (anLevel) == oConsulta:drillLevel()
			if !(lMakeExp) // .and. lNoTotals) $$$$$ALAN
				aAdd(aaProgram, "  aFill(_aTotOutros, nil)")
				aAdd(aaProgram, "  if getRankOutros(_aTotOutros, nil, "+dwStr(anLevel+1)+")")
				aAdd(aaProgram, "    _aDataDim["+dwStr(anLevel+1)+"] :=  '[" + STR0030 + "]'") //###"outros"
				aAdd(aaProgram, "   sendRow("+dwStr(anLevel+1)+", _aDataDim, _aTotOutros, .t., 0, n_LenDimY, aTotGer)")
				aAdd(aaProgram, "  endif")
			endif
		endif
	endif
return

static function makeWhile2(aaProgram, alRank)
	aAdd(aaProgram, "aFill(_aTotInd, nil)")
	aAdd(aaProgram, "_aDataDim[1]:= ''")

	aAdd(aaProgram, "while isNotEOP()")
	aAdd(aaProgram, "  sumData(_aTotInd)")
	aAdd(aaProgram, "  _nRecNo := nDataRow")
	aAdd(aaProgram, "  aRecValues := aDataPage[nDataRow]")
	aAdd(aaProgram, "  nDataRow++")
	aAdd(aaProgram, "enddo")

	aAdd(aaProgram, "sendRow(1, _aDataDim, _aTotInd, .f., _nRecNo, "+dwStr(n_LenDimY)+")")
return

static function searchCol(alTotalRow, anLevel, aoDataset)
	local nInd, cAlvo, nRet, i,  x

	default alTotalRow := .f.
	default anLevel := nLenDimX	  
	
	cAlvo := ""
	if valType(aoDataset) == "U"
		if alTotalRow
			if anLevel == 0
				aEval(aDimX, { |x| cAlvo += STR0033+SEP_DATA } ) //###"TOTAL"
			else
				aEval(aDimX, { |x,i| cAlvo += DWStrZero(ajustaEamp(x, aDataPage[nDataRow, n_lenDimY + i])	, x:Tam(), x:NDec())+SEP_DATA}, 1, anLevel)	
				cAlvo += chr(254)
			endif
		else                  
			aEval(aDimX, { |x, i| cAlvo += DWStrZero(ajustaEamp(x, aDataPage[nDataRow, n_lenDimY + i]), x:Tam(), x:NDec())+SEP_DATA}, 1, anLevel) 
		endif
	else
		if alTotalRow
			if anLevel == 0
				aEval(aDimX, { |x| cAlvo += STR0033+SEP_DATA } ) //###"TOTAL"
			else
				aEval(aDimX, { |x| cAlvo += DWStrZero(ajustaEamp(x, aoDataset:value(x:Alias())), x:Tam(), x:NDec())+SEP_DATA}, 1, anLevel)
				cAlvo += chr(254)
			endif
		else
			for i := 1 to anLevel
        		x := aDimX[i]
        		if !(valType(aoDataset:Fields(x:Alias())) == "U")
          			cAlvo += DWStrZero(ajustaEamp(x, aoDataset:value(x:Alias())), x:Tam(), x:NDec())+SEP_DATA
        		endif
      		next        
		endif
	endif	
	cAlvo := strTran(cAlvo, SEP_DATA+SEP_DATA, SEP_DATA+VAZIO+SEP_DATA)
	cAlvo := strTran(cAlvo, EAMP, "&")
  	nRet := (ascan(aColsX, { |x| x == cAlvo }) - 1)
return nRet

static function procCalcVal(anAggfunc, anOper1, anOper2)
	local nRet

	if valType(anOper1) == "U"
		if anAggfunc == AGG_AVG
			nRet := { anOper2, 1 , .t. }
		else
			nRet := anOper2
		endif
	else
		if anAggfunc == AGG_AVG
	    	if (valType(anOper1) == "C")
				anOper1 := &(anOper1)
		  	endif
			nRet := { anOper1[1] + anOper2, anOper1[2]+1 , .t. }
		else
			anOper1 := dwVal(anOper1)
			if anAggfunc == AGG_MIN
				nRet := min(anOper1,anOper2)
			elseif anAggfunc == AGG_MAX
				nRet := max(anOper1,anOper2)
			else
				nRet := anOper1 + anOper2
			endif
		endif
	endif
return nRet

static function procCalcAvg(anAggfunc, aaOper)
    Local nAux
	Local aRet := aaOper 
	
	/*Garante que o parâmetro recebido é um array.*/
	if (ValType(aaOper) == "A") 
		if anAggfunc == AGG_AVG
			if len(aaOper) > 2  
				/*impede a divisão por ZERO.*/
				if !(aaOper[2] == 0)
					nAux := aaOper[1] / aaOper[2]
					aRet := {nAux , nAux }
			    Else
			    	aRet := {0 , 0 }
			    EndIf			    
			endif
		endif
	endif
return aRet

static function procRow(aaRow, aaData, anCol, alTotal)
  	local i
  	Local nCount 	:= 0
  	Local nValor1	:= 0
  	Local nValor2	:= 0
  	Local nVlTotal	:= 0
  	Local nI		:= 0
  	
	for i := 1 to n_LenInd
    	if anCol + i <= len(aaData)
			if valType(aaRow[n_LenDimY + nLenDimX + i]) == "A" 
				if valType(aaData[anCol + i]) <> "A"
					aaData[anCol + i] := { aaData[anCol + i] , "" }
  				endif
				
				nValor1 := dwVal(aaData[anCol + i, 1]) + aaRow[n_LenDimY + nLenDimX + i, 1]

  				If alTotal
  					If aaRow[n_LenDimY + nLenDimX + i][4] == AGG_AVG
  						nVlTotal := 0  
  						nCount := 0

			    		For nI := i to len(aaData) - n_LenInd Step n_LenInd
			    			If valType(aaData[nI]) == "A"
			    				nCount++         
			    				nVlTotal := nVlTotal + nBIVal(aaData[nI][1]) 
			    			EndIf
			    		Next
  						nValor2 := ( nVlTotal / nCount )
  						nValor1 := nValor2
  					Else
  						nValor2 := nValor1 
  					EndIf
 				Else
  					nValor2 := aaRow[n_LenDimY + nLenDimX + i, 2]
  				EndIf
  				aaData[anCol + i, 1] := nValor1
				aaData[anCol + i, 2] := nValor2				
	  		else
		  		aaData[anCol + i] := dwVal(aaData[anCol + i]) + dwVal(aaRow[n_LenDimY + nLenDimX + i]) 
  			endif
    	endif
	next
	
  	if lSubTotalRank 
    	aaData[len(aaData)] := dwVal(aTail(aaRow)) * nFatorCorrecao
  	endif
return

static function sumData(aaData)
	local nCol := 0, nInd
	
	if nLenDimX > 0
		nCol := searchCol()
		if nCol < 0
			return
		endif
	endif
	
  	procRow(aDataPage[nDataRow], aaData, nCol, .f.)

	if nLenDimX > 0        
	  	for nInd := 0 to nLenDimX
	  		nCol := searchCol(.t., nInd)
	  		if !(nCol < 0)
        		procRow(aDataPage[nDataRow], aaData, nCol, .t.)
    		endif
		next  
	endif
return
  
static function mergeArray(aaTarget, aaSource, alSource)
	local nInd
	
	default alSource := .f.

	if alSource
		for nInd := 1 to len(aaSource)
			if !(valType(aaSource[nInd]) == "U")
				aaTarget[nInd] := iif(valType(aaSource[nInd]) == "A", aclone(aaSource[nInd]), aaSource[nInd])
			endif
		next
	else	
		for nInd := 1 to len(aaTarget)
			if valType(aaTarget[nInd]) == "U"
				aaTarget[nInd] := iif(valType(aaSource[nInd]) == "A", aclone(aaSource[nInd]), aaSource[nInd])
			endif
		next
	endif
return

static function sendRow(anLevel, aaDataDim, aaData, alTotal, anRecno, acClassABC, aaTotPar)
	local aDataAtt, aDataInd, nPos := 1, cTag, nInd, i, x
	local aDataDim, nAux, aAux, cAux, xAuxColor
	local bQuebra := .f., lEof := .f., nPosColor
	local cClassCor := "", nClass
	local cAction, nLenData, nLenColsX
	local nPosAux, nLenAux
	
	If ( DWIsWebEx() .And. ! HttpIsConnected() )
		//----------------------------------------------------
		// Veficica se a origem da exportação é o DSH ou SCHD. 
		//----------------------------------------------------
	 	If lMakeExp .and. ( AllTrim( GetClassName( oMakeExp ) ) $ "TDW2DSH|TMAKEEXP2" ) 
    	Else
			Return
		EndIf
	EndIf
	
	default alTotal := .f.

	aDataDim := aClone(aaDataDim)
	
	if alTotal .and. anLevel == -1 //totais da classificação
		aFill(aDataDim, "&nbsp;")
		nClass := ascan(oConsulta:CurvaABC(), { |x| x[ABC_CLASSIF] == acClassABC })
		aDataDim[1] := oConsulta:CurvaABC()[nClass, ABC_DESC]
		cClassCor := oConsulta:CurvaABC()[nClass, ABC_COR]

		if empty(aDataDim[1])
			aDataDim[1] := "==> " + STR0034 + " [<b> " + acClassABC + " </b>]" //###"Classificação"
		else
			aDataDim[1] := "==> " + aDataDim[1]
		endif
		anLevel := 0
	endif

	if !alTotal
		bQuebra := .f.
		nLenAux := len(aDataDim)
		
		for nInd := 1 to nLenAux
			if lDplRow
				/*Oculta os valores repeditos na exibição da consulta tabela*/
				if ( dwStr(aRowSend[nInd]) == dwStr(aDataDim[nInd]) )  .and. ( !bQuebra .and. (!oConsulta:FillAll() .or. oConsulta:HaveDrillDown() ) )
					aDataDim[nInd] := "&nbsp;"
				else
					aRowSend[nInd] := dwStr(aDataDim[nInd])
					bQuebra := .t.
				endif
			else
				aRowSend[nInd] := dwStr(aDataDim[nInd])
			endif
		next
	else
		aEval(aDataDim, { |x,i| aDataDim[i] := iif(valType(x)=="U", "", aDataDim[i])})
		if anLevel > 0
			aFill(aRowSend, chr(254))
			aEval(aDataDim, { |x,i| aRowSend[i] := aDataDim[i], aDataDim[i] := "&nbsp;" }, 1, anLevel-1)
		endif
	endif
	
	aDataAtt := array(len(aDataDim))
	aDataInd := array(len(aaData))
	
	if !alTotal
		nRecPage--
	endif
	
	cTag := iif(alTotal, TAG_DIMTOTAL, TAG_DIM)
	
	if n_LenDimY == 0
		aDataAtt[nPos] := prepDrill(anRecno, prepDim(x, ">", TAG_DIM, oMakeExp), 0, cTag)
	else
		for i := 1 to n_LenDimY
			x := aDataDim[i]
			if nDrillLevel <> 0 .and. i > nDrillLevel
				x := ""
			elseif !(left(dwStr(x), MARK_LEN) $ ALL_MARKS) //EOF_MARK & NEXT_MARK & PREV_MARK && NEXT_PREV_MARK
				if cTag == TAG_DIM .and. i >= nLastDimY
					cTag := TAG_DIM
				endif
				x := prepDim(ajustaEamp(aDimY[i], x), iif(i > n_LenDimY,"",aDimY[i]:Mascara()), cTag, oMakeExp)
			endif
			aDataAtt[nPos] := prepDrill(anRecno, x, i, cTag)
			nPos++
		next
	endif
	
	nPos := 1
	nLenData := len(aaData) - n_LenInd
	nLenColsX := len(aColsX)
	for nInd := 0 to nLenData step n_LenInd
		for i := 1 to len(aInd)
			cTag := iif(alTotal, TAG_INDTOTAL, TAG_IND)
			x := aInd[i]
			if valType(aaData[nInd + i]) == "U"
				if !lMakeExp
					aDataInd[nPos] := "&nbsp;"+SEP_DATA + cTag
				endif
			else
				if (nInd + i) <= nLenColsX
					if chr(254) $ aColsX[nInd + i]
						cTag := iif(alTotal, TAG_INDSUBTOTAL2, TAG_INDSUBTOTAL)
					endif
				endif
		
				if NO_SEND_DATA $ dwStr(aaData[nInd + i]) .or. (alTotal .and. !x:canTotalize())
					aDataInd[nPos] := NO_SEND_DATA
				else
					aaData[nInd + i] := procCalcAvg(x:aggfunc(), aaData[nInd + i])
					aDataInd[nPos] := prepData(aaData[nInd + i], x:Mascara(), cTag, nil, x:Alias(), x:Tam(), x:NDec(), x:AggFunc(), nInd + i, oMakeExp, x:Tipo(), anLevel, x, aaTotPar)
				endif
			endif
			nPos++
		next
	next
	
	if !lMakeExp
		aAux := dwToken(dwStr(aDataAtt[1]), SEP_DATA)
		if len(aAux) > 1 .and. aAux[2] == TAG_DIMTOTAL
			aAdd(_aaBuffer, "  initRow(true);")
			if valType(acClassABC) == "C"
				aAdd(_aaBuffer, "  setCurvaABC(oRowAtt, '"+cClassCor+"');")
				aAdd(_aaBuffer, "  setCurvaABC(oRowInd, '"+cClassCor+"');")
			elseif anLevel == 0
				aAdd(_aaBuffer, "  oRowAtt.className = oRowAtt.className + 'Geral';")
				aAdd(_aaBuffer, "  oRowInd.className = oRowInd.className + 'Geral';")
			endif
		else
			aAdd(_aaBuffer, "  initRow(false);")
			if valType(acClassABC) == "C"
				aAdd(_aaBuffer, "  setCurvaABC(oRowAtt, null, '"+acClassABC+"');")
			endif
		endif
		
		for nInd := 1 to len(aDataAtt)
			aAux := dwToken(strTran(dwStr(aDataAtt[nInd]), ASPAS_S, "\x27"), SEP_DATA, .F.)
			if len(aAux) > 0
				aAux[1] := strTran(dwStr(aAux[1]), "\x27", ASPAS_S)
				if !(aAux[1] == "&nbsp;") .and. !("%2526" $ aAux[1])
					if left(aAux[1], MARK_LEN) == EOF_MARK
						aAdd(_aaBuffer, "  oRowAtt.cells["+dwStr(nInd-1)+"].innerHTML = '[ " + STR0035 + " ]';") //###"F I M"
						lEof := .t.
					elseif left(aAux[1], MARK_LEN) $ NAV_MARKS
						cAction := ""
						if left(aAux[1], MARK_LEN) == PREV_MARK .or. left(aAux[1], MARK_LEN) == NEXT_PREV_MARK
							cAction += tagImage("page_back.gif", 16, 16, STR0036, STR0037,,"js:requestData("+makeAction(AC_QUERY_EXEC, { {"acao", PREVS_PAGE } })+")") //###"Anterior"###"Vai para a página anterior"
						endif

						if left(aAux[1], MARK_LEN) == NEXT_MARK .or. left(aAux[1], MARK_LEN) == NEXT_PREV_MARK
							cAction += tagImage("page_next.gif", 16, 16, STR0038, STR0039,,"js:requestData("+makeAction(AC_QUERY_EXEC, { {"acao", NEXT_PAGE } })+")") //###"Próxima"###"Vai para a próxima página"
						endif
						cAction := strTran(cAction, "'", "\'")
						aAdd(_aaBuffer, "  oRowAtt.cells["+dwStr(nInd-1)+"].innerHTML = '"+cAction+"';")
						lEof := .t.
					else
						cAux := strTran(strTran(aAux[1], "'", "\'"),"\\","\")
						cAux := strTran(cAux, "\n", "")
						cAux := strTran(cAux, "\t", "")
						cAux := strTran(cAux, EAMP, "&amp;")
						cAux := strTran(cAux, "&amp;ordm;", "&ordm;")
						cAux := strTran(cAux, "&amp;ordf;", "&ordf;")

						if "javascript:doDrill" $ cAux
							nPosAux := rat(">", cAux)
							aAdd(_aaBuffer, "  oRowAtt.cells["+dwStr(nInd-1)+"].innerHTML = ('" + substr(cAux, 1, nPosAux) +;
							"') + unescape('" + substr(cAux, nPosAux + 1) +"');")
						else
							aAdd(_aaBuffer, "  oRowAtt.cells["+dwStr(nInd-1)+"].innerHTML = unescape('" + cAux + "');")
						endif
					endif
				endif
			endif
		next
		
		for nInd := 1 to len(aDataInd)
			aDataInd[nInd] := dwStr(aDataInd[nInd])
			if !empty(aDataInd[nInd]) .and. !(aDataInd[nInd] == NO_SEND_DATA)
				aAux := dwToken(aDataInd[nInd], SEP_DATA, .f.)
				aAux[1] := dwStr(aAux[1])
				if !empty(aAux[1]) .and. !(aAux[1] == "&nbsp;")
					if lEof
						aAdd(_aaBuffer, "  oRowInd.cells["+dwStr(nInd-1)+"].innerHTML = '&nbsp;';")
					elseif empty(aAux[3])
						aAdd(_aaBuffer, "  oRowInd.cells["+dwStr(nInd-1)+"].innerHTML = '"+aAux[1]+"';")
					else
						aAux[3] := dwStr(aAux[3])
						xAuxColor := dwToken(aAux[3], ";",.f.)
						if (nPosColor := ascan(xAuxColor, { |x| "background-color" $ x })) <> 0
							xAuxColor := dwToken(xAuxColor[nPosColor], ":",.f.)[2]
							aAdd(_aaBuffer, "  oRowInd.cells["+dwStr(nInd-1)+"].style.backgroundColor = '"+xAuxColor+"';")
						endif
						aAdd(_aaBuffer, "  oRowInd.cells["+dwStr(nInd-1)+"].innerHTML = '<font style=" + ASPAS_D + aAux[3] + ASPAS_D + ">" +dwStr(aAux[1])+"</font>';")
					endif
				endif
			endif
		next

		if lEof
			aAdd(_aaBuffer, "  oRowAtt.className = oRowAtt.className + ' EOF_Mark';")
			aAdd(_aaBuffer, "  oRowInd.className = oRowInd.className + ' EOF_Mark';")
		endif
	else
		aExpAux := {}
		
		for nInd := 1 to len(aDataAtt)
			cAux := dwStr(aDataAtt[nInd])
			if "%2526" $ cAux .or. empty(cAux)
				cAux := "&nbsp;"
			else
				cAux := strTran(cAux, EAMP, "&amp;")
				cAux := strTran(cAux, "&amp;ordm;", "&ordm;")
				cAux := strTran(cAux, "&amp;ordf;", "&ordf;")
			endif
			aAdd(aExpAux, cAux)
		next
		
		for nInd := 1 to len(aDataInd)
			aAdd(aExpAux, aDataInd[nInd])
		next
		
		if lNoTotals
			aEval(aExpAux, { |x,i| iif(NO_SEND_DATA $ dwStr(x), aExpAux[i] := nil, iif(valtype(x)=="U", aExpAux[i] := "§", nil))})
			aExpAux := packArray(aExpAux)
			aEval(aExpAux, { |x,i| iif(dwStr(x) == "§", aExpAux[i] := "&nbsp", nil)})
			aExpAux := truncArray(aExpAux)
		else
			aExpAux := truncArray(aExpAux)
			aEval(aExpAux, { |x,i| iif(valType(x) == "U", aExpAux[i] := "&nbsp", nil)})
		endif
		
		aEval(aExpAux, { |x,i| aExpAux[i] := iif(valType(x) == "U", "&nbsp", x)})
		
		oMakeExp:writeln(aExpAux)   
	endif
return

/*
--------------------------------------------------------------------------------------
Exportação de consultas (tabela)
Args:
--------------------------------------------------------------------------------------
*/             
function exportQuery(aoConsulta, aoExport)
	local aBuffer := {}     
	
	if aoExport:FileType() != FT_DIRECT_EXCEL
		aoConsulta:RecupCacheArq()
	endif
	makePage(aBuffer, aoConsulta, '', aoExport)
return

function expDW2Dsh(aoConsulta, aoExport)
	local aBuffer := {}

  	if aoConsulta:RankStyle() == "C" //RNK_STY_CLEAR
    	aoConsulta:rankDef()
  	endif  
	makePage(aBuffer, aoConsulta, '', aoExport)
return

/*
--------------------------------------------------------------------------------------
Monta o applet do gráfico
Args:
--------------------------------------------------------------------------------------
*/
static function buildChart(aaBuffer, aoConsulta)
	local aParams := {}
	local nWidth  := 860
	local nHeight := 500
	local aGraphProps
	local lDocumento := !isNull( DWLoadExpr( aoConsulta:Document() ) )
	
	aAdd(aParams, { "CHART_DIIR_LICENSE", "RDST-245J-39ZJ-A6R8-ED7B-1DCB" })
	aAdd(aParams, { "dwprogram", HttpHeadIn->main + ".apw" })
	aAdd(aParams, { "dwaction", strTran(makeAction(AC_QUERY_GRAPH, { {"id", aoConsulta:ID()}, {"tipo", "2"}, {"oper", "6"}, {"loadpgdw", HttpGet->loadpgdw}, {"SESSIONID", DwStr(HttpCookies->SessionID)} } , .f.), "&amp;", "&") + "&amp;_forceReload=" + randByDate() + randByTime() })
	aAdd(aParams, { "msgerror", STR0040 }) //###"Nao existem dados para este nivel!"
	aAdd(aParams, { "MSLOADING", STR0041 }) //###"por favor aguarde, carregando..."
	aAdd(aParams, { "QUERY_TIME", "500" })
	aAdd(aParams, { "QUERY_MAX_TIME", "100000" })
	aAdd(aParams, { "BLOCK_GRAPH_REQUEST", "15" })
	aAdd(aParams, { "REQUEST_ERROR", STR0042 }) //###"Atenção, ocorreu um erro no processamento da requisição."
	aAdd(aParams, { "ERROR", STR0043 }) //###"erro na requisição"
	aAdd(aParams, { "IMG_ZOOM_IN", urlImage("ic_zoom_in.gif",.f., "hgraph", .t.) })
	aAdd(aParams, { "IMG_ZOOM_REST", urlImage("ic_zoom.gif",.f., "hgraph", .t.) })
	aAdd(aParams, { "IMG_ZOOM_OUT", urlImage("ic_zoom_out.gif",.f., "hgraph", .t.) })
	aAdd(aParams, { "IMG_EXPORT", urlImage("page_export.gif",.f., "hgraph", .t.) })
	aAdd(aParams, { "IMG_CLOSE", urlImage("page_close.gif",.f., "hgraph", .t.) })
	aAdd(aParams, { "URL_EXPORT_GRAPH", makeAction(AC_QUERY_CFG_EXP, {{"id", aoConsulta:ID()}, {"type", aoConsulta:_type()}, {"tipo", EX_GRAF}}) })
	aAdd(aParams, { "LABEL_ZOOM_IN", STR0011}) //###"Aumentar Zoom"
	aAdd(aParams, { "LABEL_ZOOM_REST", STR0009}) //###"Restaurar Zoom"
	aAdd(aParams, { "LABEL_ZOOM_OUT", STR0007}) //###"Diminuir Zoom"
	aAdd(aParams, { "LABEL_EXPORT", STR0001}) //###"Exportar"
	aAdd(aParams, { "LABEL_CLOSE", STR0049}) //###"Fechar DrillDown"
	aAdd(aParams, { "LABEL_NEXTDRILL", STR0050}) //###"próximo nível"
	aAdd(aParams, { "LABEL_PREVDRILL", STR0051}) //###"nível anterior"
	//Propriedades da documentação da consulta gráfico. 
	aAdd(aParams, { "IMG_DOCUMENT", urlImage("ic_doc.gif",.f., "hgraph", .t.) }) 
	aAdd(aParams, { "LABEL_DOCUMENT", STR0052}) //###"Documentação" 
	//A URL só será enviada para o Java caso exista documentação relacionada a consulta. 
	aAdd(aParams, { "URL_DOCUMENT", iif( lDocumento, makeAction( AC_DOCUMENTATION, {{ "objID", aoConsulta:id() }, { "ObjType", OBJ_QUERY }  , { "edCmdTextArea", EDT_CMD_DISPLAY }} ), "") } )
	
	aGraphProps := DWToken(aoConsulta:GraphYProps(), ";", .f.)
	setGraphYPropsDefault(aGraphProps)
	
	aAdd(aParams, { "DW_OPENDRILL",  Upper(aGraphProps[18]) })
	
	If !empty(HttpGet->dwacesss) .OR. isNull(HttpGet->loadpgdw, CHKBOX_OFF) == CHKBOX_ON
		aAdd(aParams, { "WINDOWLESS", "Windowless"})
		/*Correção no posicionamento dos Painéis Off-Line no Protheus.*/
		nWidth	:= if(Vazio(HttpGet->width)	, 820, DwVal(HttpGet->width) - 60) 
		nHeight := if(Vazio(HttpGet->height), 280, DwVal(HttpGet->height)- 70) 
	endif
	
	tagApplet("br.com.microsiga.sigadw.applet.DWScriptChart", 'chart', nWidth, nHeight, aParams, aaBuffer)
return

/*
--------------------------------------------------------------------------------------
Calcula a largura das colunas da tabela
Args:
--------------------------------------------------------------------------------------
*/             
static function calcWidthCols(aoConsulta, alNoTotal)
	local aWidth, nInd
	local aColsX := {}, aAux := {}
	local nColX := aoConsulta:readAxisX(aColsX, ,,alNoTotal, .f.)
	local aDimY := aoConsulta:DimFieldsY()
	local aInd := aoConsulta:Indicadores()
	local nLenDimY := aoConsulta:DimCountY()
	local nLenDimX := aoConsulta:DimCountX()
	local nLenInd
	local nAttWidth := 0, nIndWidth := 0
	local nDLevel := aoConsulta:DrillLevel()
	
	// retira indicadores adicionados por serem utilizados em campos virtuais
	aEval(aInd, {|xElem,i| iif(xElem:Ordem() > -1, aAdd(aAux, xElem), NIL)})
	aInd := aAux
	nLenInd := len(aInd)
	
	aWidth := aClone(aoConsulta:AttWidth())
	for nInd := 1 to nLenDimY
		if len(aWidth) < nInd
			aAdd(aWidth, 0)
		endif
		
		if aWidth[nInd] <= 0
			if oSigaDW:WidthColDD() > 0 .and. nDLevel <> 0 .and. nInd > nDLevel
				aWidth[nInd] := oSigaDW:WidthColDD()
				//Se a largura definida no .ini for 1(um), somar 0.1 para que na
				//montagem da coluna a função buildMeasure() não retorne 100%
				if aWidth[nInd] == 1
					aWidth[nInd] += 0.1
				endif
			else
		  		aWidth[nInd] := max(max(len(aDimY[nInd]:Desc()), aDimY[nInd]:Tam()+aDimY[nInd]:NDec()) * FONT_SIZE, LARG_MIN) + LARG_BASE_ATT
   			endif

			if aoConsulta:RankOn() .and. aoConsulta:RankStyle() == RNK_STY_CURVA_ABC
				nAttWidth += CORRECAO_CURVA_ABC
			endif
			nAttWidth += aWidth[nInd] + CORRECAO_SIMPLES
			aWidth[nInd] := -aWidth[nInd]
		endif		
  	next
	aoConsulta:AttWidth(aWidth)
	    
	// determina a largura dos indicadores
	aWidth := aClone(aoConsulta:IndWidth())
	for nInd := 1 to nLenInd
		if len(aWidth) < nInd
			aAdd(aWidth, 0)
		endif                    

		if aWidth[nInd] <= 0
			aWidth[nInd] := 0
			aWidth[nInd] := max(len(aInd[nInd]:AggTit())*FONT_SIZE_2, aWidth[nInd])
			aWidth[nInd] := max((aInd[nInd]:Tam()+aInd[nInd]:NDec())*FONT_SIZE_2, aWidth[nInd])
			aWidth[nInd] := max(LARG_MIN, aWidth[nInd]) + LARG_BASE_IND
			aWidth[nInd] := -aWidth[nInd]
		endif		
  	next                     
	
	aAux := {}
	if nColX > 0
		for nInd := 1 to nColX step nLenInd
			aEval(aWidth, { |x| aAdd(aAux, x), nIndWidth += abs(x) + CORRECAO_SIMPLES })
		next
		aWidth := aClone(aAux)
	else
		for nInd := 1 to len(aWidth)
			nIndWidth += abs(aWidth[nInd]) + CORRECAO_SIMPLES
		next
	endif
	aoConsulta:IndWidth(aWidth)
return { nAttWidth, nIndWidth }

static function ajustaEamp(oAtt, xValue)
  	local xRet := oAtt:adjustValue(xValue)
  
  	if valType(xRet) == "C" .and. !xRet == "&nbsp;"
    	xRet := strTran(xRet, "&", EAMP)
  	endif
return xRet

static function ApenasParaEleminarAvisosCompilador()
	if .f.
		BUILDCOLRESIZE(); ISNOTEOP(); MERGEARRAY(); SENDROW(); SUMDATA(); GETRANKOUTROS()
 		ApenasParaEleminarAvisosCompilador()
	endif
return
                      
//static function runCB()
//return

//static function runExp() 
//return
