// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Htm
// Fonte  : htmlLib - funções de geração de HTML de uso geral
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 28.09.05 | 0548-Alan Candido | Versão 3
// 22.11.07 | 0548-Alan Candido | BOPS 136453 - Correção na função getWebHost(), quando a mesma
//          |                   |    for utilizada fora do contexto web
// 18.01.08 | 0548-Alan Candido | BOPS 139342 - Implementação e adequação de código, 
//          |                   | em função de re-estruturação para compartilhamento de 
//          |                   | código.
// 23.01.08 | 0548-Alan Candido | BOPS 136637 - Otimização no processamento de registros
//          |                   | da tabela TAB_IPC (acompanhmento de processos).
// 30.01.08 | 0548-Alan Candido | BOPS 140233 - Compatibilização de código para uso pelos TotvsParam
// 20.02.08 | 0548-Alan Candido | BOPS 140966 - Compatibilização de código para uso pelos TotvsParam
// 13.03.08 | 0548-Alan Candido | BOPS 142638 - Implementação de passagem do identificador de sessão
//          |                   |   via requisição httpGet. Esta opção só é aceita quando a requisição
//          |                   |   vier a partir do 'portal TotvsUp'.
//          |                   |   Compatibilização de código para uso pelos TotvsParam
// 10.04.08 | 0548-Alan Candido | BOPS 142154
//          |                   | Compatibilização de código para uso pelos TotvsParam
//          |                   | Implementação da função makeTopOper e buildTopOper
//          |                   | Ajuste na apresentação de campos data (makeDateField())
// 25.04.08 | 0548-Alan Candido | BOPS 144755
//          |                   | Compatibilização de código para uso pelos TotvsParam
// 28.04.08 |0548-Alan Cândido  | BOPS 1444809
//          |                   | Implementação da chamada de rotina de validação para formulários
//          |                   | criados pela função buildMiniForm()
// 26.09.08 | 0548-Alan Candido | BOPS 154282
//          |                   | Ajuste de lay-out, na apresentação do log de execução
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | . Adequação de geração de máscara em campos numéricos e datas, 
//          |                   | para respeitar o formato conforme idioma 
//          |                   | (chave RegionalLanguage na sessão do ambiente).
// 30.12.08 |0548-Alan Candido  | FNC 00000011160/2008 (8.11) e 00000011201/2008 (P10)
//          |                   | Compatibilização de código para uso pelos TotvsParam
// 19.02.10 | 0548-Alan Candido | FNC 00000003657/2010 (9.12) e 00000001971/2010 (11)
//          |                   | Implementação de visual para P11 e adequação para o 'dashboard'
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "htmlLib.ch"

#define NAV_SPECIAL "#"
#define TABLE_MIN_WIDTH 450
#define TAM_PIXEL_ATT 8
#define TAM_PIXEL_ATT_AJUSTE 3

/*
--------------------------------------------------------------------------------------
Obtem o nome do webHost utilizado
--------------------------------------------------------------------------------------
*/
function getWebHost()
	local cAux, aAux, nPos
	local cRet := ""
  
	if valType(HttpHeadin->AHeaders) == "A" .and. len(HttpHeadin->AHeaders) > 0
		cAux := substr(HttpHeadin->AHeaders[1], at("/", HttpHeadin->AHeaders[1]))
  	aAux := dwToken(cAux, "/")
		nPos := 0
	
		for nPos := 1 to len(aAux)
			if ".apw" $ aAux[nPos]
    		exit
    	endif  
  	next
  	aSize(aAux, nPos-1)
    cRet := HttpHeadin->Host + dwConcatWSep("/", aAux)
	else
		cRet := ""
	endif
	
return cRet                                     

/*
--------------------------------------------------------------------------------------
Gera a tag para carga de bibliotecas JS
Args: acJSFile - nome do arquivo de bibliotecas JS
--------------------------------------------------------------------------------------
*/                    
function tagJSLib(acJSFile)

return "<script type='text/javascript' src='"+acJSFile+"'></script>"

/*
--------------------------------------------------------------------------------------
Gera a tag para rotinas JS
--------------------------------------------------------------------------------------
*/                    
function tagJS()

return "<script type='text/javascript'>"

/*
--------------------------------------------------------------------------------------
Gera a tag <img>
Args: acImageFile - nome do arquivo de imagem
      anWidth - largura
      anHeight - altura
      acHint - "hint"
      acAltText - texto alternativo
      acStyle - estilos complementares
      acOnClick - envento JS a ser executado
      acID - id da imagem
      alMap - indica use de <map> (recomenda-se informar acID)
      alRollover - indica se a imagem criada deverá possuir rollover
      alDisabled - indica se a imagem deverá apresentar efeitos de imagem desabilitada para o usuário
--------------------------------------------------------------------------------------
*/                    
function tagImage(acImageFile, anWidth, anHeight, acHint, acAltText, acStyle, acOnClick, acID, alMap, alRollover, alDisabled, acValue)
	local cRet := "", cClass := "", cStyle := ""

	default acHint := "" 
	default acAltText := acHint
	default acStyle := "" 
	default acOnClick := ""
	default acID := ""
	default anWidth := 16
	default anHeight := 16
	default alMap := .f.
	default alRollover := .T.
	default alDisabled := .F.
	default acValue	 := ""

	if !empty(acStyle)  
		if left(acStyle,1) == "#"
			cClass := ' class="'+substr(acStyle,2)+'" '
			acStyle := ""
		else
			acStyle += ";"
		endif
	endif
					
  if !dwIsFlex()

	cRet += "<img "+cClass
	if !empty(acID)
		cRet += " id='"+acID+"' "
	endif                      
	if alMap
		cRet += " usemap='#map"+acID + "' "
	endif

	cStyle := acStyle

	if !empty(anWidth) .and. anWidth <> -1
    cStyle += "width:"+buildMeasure(anWidth)+";"
	endif
	if !empty(anHeight) .and. anHeight <> -1
    cStyle += "height:"+buildMeasure(anHeight)+";"
	endif    

	if !empty(acOnClick)
    cStyle += cssCursorHand()+";"
	endif
	
  endif //dwIsFlex()
  	
	if !empty(cStyle)
		cRet += " style='"+cStyle +"'"
	endif

	if !alDisabled
		if !empty(urlImage(strTran(acImageFile, ".gif", "_on.gif"), .f.))
			acImageFile := urlImage(strTran(acImageFile, ".gif", "_off.gif"))
		else
			acImageFile := urlImage(acImageFile)
		endif
	else
		acImageFile := urlImage(strTran(acImageFile, ".gif", "_dis.gif"))
	endif
 
  if !dwIsFlex()					

	if !empty(acOnClick)
	  cRet += " onClick="+ makeJSAction(acOnClick)
	endif
	
	if alRollover
		cRet += " onMouseOver='doMouseOver_img(this)'"
		cRet += " onMouseOut='doMouseOut_img(this)'"     
		//evento não suportado pelo W3C
		//cRet += " onMouseEnter='doMouseEnter_img(this)'" 
	endif

	if !empty(acValue)
		cRet += " value=" + acValue
	endif
	
	cRet += " border='0' alt='"+acAltText+"' title='"+acHint+"' src="+acImageFile+">"
  else //isFlex
    cRet := delAspas(acImageFile, ASPAS_S);
//	  cRet += " alt='"+acAltText+"' title='"+acHint+"' src="+acImageFile+" />"
  endif //isFlex
return cRet

/*
--------------------------------------------------------------------------------------
Constroe as informações para mapeamento de imagem
Args: acMapType, tipo do mapeamento
	  aaCoords, array com as coordenadas { left, top, width, height }
      acAlt, texto de micro-help
      acMouseClick, ação a ser executada no evento "onMouseClick" (href)
      acMouseOver, ação a ser executada no evento "onMouseOver"
      acMouseOut, ação a ser executada no evento "onMouseOut"
Ret.: aRet - array, com as informações de mapeamento
--------------------------------------------------------------------------------------
*/
function makeMap(acMapType, aaCoords, acAlt, acMouseClick, acMouseOver, acMouseOut)
	local aRet := array(MAP_SIZE)
	
	aRet[MAP_TYPE] := acMapType
	aRet[MAP_COORDS] := { aaCoords[1], aaCoords[2], aaCoords[3], aaCoords[4] }
	aRet[MAP_ALT] := isnull(acAlt, "")
	aRet[MAP_MOUSE_OVER] := isNull(acMouseOver, "")
	aRet[MAP_MOUSE_OUT] := isNull(acMouseOut, "")
	aRet[MAP_MOUSE_HREF] := isNull(acMouseClick, "")

return aRet
	                                 
/*
--------------------------------------------------------------------------------------
Gera a tag <map>
Args: acImgID - id da imagem que será mapeada
      aaMapInfo - array, com o mapeamento
--------------------------------------------------------------------------------------
*/
function tagMap(aaBuffer, acImgID, aaMapInfo)
    local nInd, aMap, cAux
    
	aAdd(aaBuffer, "<map name='map"+acImgID+"'>")
	for nInd := 1 to len(aaMapInfo)
		aMap := aaMapInfo[nInd]
		cAux := "<area shape='"+aMap[MAP_TYPE]+"' coords='"+dwConcatWSep(",",aMap[MAP_COORDS])+"'"
		cAux += iif(empty(aMap[MAP_ALT]), "", " alt='"+aMap[MAP_ALT]+"'")
		cAux += iif(empty(aMap[MAP_MOUSE_OVER]), "", " onmouseover="+makeJSAction(aMap[MAP_MOUSE_OVER]))
		cAux += iif(empty(aMap[MAP_MOUSE_OUT]), "", " onmouseout="+makeJSAction(aMap[MAP_MOUSE_OUT]))
		cAux += " href="+makeJSAction(aMap[MAP_MOUSE_HREF])
		cAux += " onMouseOver="+ASPAS_D+"window.status='"+dwStr(aMap[MAP_ALT])+"';return true;"+ASPAS_D+">"
		aAdd(aaBuffer, cAux)
	next
	aAdd(aaBuffer, "</map>")

return

/*
--------------------------------------------------------------------------------------
Gera a tag <input>
Args: 
--------------------------------------------------------------------------------------
*/                    
function tagInput(acName, nLen, xValue, aaEvents, anMaxLen)
	default nLen := 0
	
return tagInputEx( EDT_EDIT /*acEdtType*/, acName /*acFieldName*/, "C" /*acType*/, nLen /*anLen*/, ;
                   0 /*anDec*/, xValue /*axValue*/, nil /*aaOptions*/,.t. /*alEdit*/, aaEvents /*aaEvents*/, ;
                   nil /*acCaption*/, nil /*acHotKey*/, nil /*alKey*/, nil /*alOnlyOneCol*/,;
                   nil /*alDotButton*/, nil /*alChoosed*/, nil /*acDotAction*/, anMaxLen/*anMaxLen*/)

/*
--------------------------------------------------------------------------------------
Gera a tag <input> em modo extendido
Args: 
--------------------------------------------------------------------------------------
*/                    
function tagInputEx(acEdtType, acFieldName, acType, anLen, anDec, axValue, aaOptions, alEdit, aaEvents, acCaption, acHotKey, alKey, alOnlyOneCol, alDotButton, alChoosed, acDotAction, anMaxLen, alShowKbe)
	local nLen, cLine := "", nInd, cKey := '', cKeyLabel := ""
	local cLen := "", cEvents := "", aEvent
	local lGrupoOpen := .f., cHotKey
	local aAux, cNewLine := ""

	local cSttsClass := ""
	local cOnKey := ""
	
	default alOnlyOneCol := .f.
	default alKey := .f.
	default alDotButton := .f.
	default alChoosed := .F.
	default acDotAction := ""
	default anMaxLen := anLen
	default alShowKbe := .F.
	
	if alOnlyOneCol	.and. acType == "M"
		cNewLine := "<br>"
	endif
	if alKey
		cKey := " key "
		cKeyLabel := " class='key' "
	endif
	
	if alEdit
		default aaEvents := {}
		for nInd := 1 to len(aaEvents)
			aEvent := aaEvents[nInd]
			cEvents += aEvent[FFLD_EVENTNAME]+'="'+aEvent[FFLD_EVENTJS]+'" '
		next
		cEvents := " " + alltrim(cEvents)
	else
		cLen += ' disabled '
	endif
    
	// verifica se ocorreu algum erro de validação e se tem algum valor no GET
	if !empty(HttpGet->gencode) .AND. valType(acFieldName) == "C" .AND. !empty(&("HttpGet->" + acFieldName))
		axValue := URLDecode(DwStr(&("HttpGet->" + acFieldName)))
	endif
    
	if acEdtType == EDT_DUALLIST
		aAux := {}
		aAdd(aAux, '<table class="duallist" summary="" width="100%">')
		aAdd(aAux, '<col width="270px" valign="top">')
		aAdd(aAux, '<col valign="top" align="center" width="45px">')
		aAdd(aAux, '<col width="270px" valign="top">')
		aAdd(aAux, '<col valign="top" align="center" width="45px">')
		aAdd(aAux, "<thead>")
		aAdd(aAux, "<tr>")
		aAdd(aAux, "<td align=center>"+acCaption[1]+"</td>")
		aAdd(aAux, "<td>&nbsp;</td>")
		aAdd(aAux, "<td align=center>"+acCaption[2]+"</td>")
		aAdd(aAux, "<td>&nbsp;</td>")
		aAdd(aAux, "</tr>")
		aAdd(aAux, "</thead>")
		aAdd(aAux, "<tbody>")
		aAdd(aAux, "<tr>")
		aAdd(aAux, "<td>")  
		aAdd(aAux, tagInputEx(EDT_LISTBOX, acFieldName[1], "C", 15, 0, , aaOptions[1], alEdit, , "", , , .t.))
		aAdd(aAux, "</td>")
		aAdd(aAux, '<td align="center" valign="top">')
		aAdd(aAux, tagButton(BT_JAVA_SCRIPT, "&gt;"   , "moveDualList(this.form."+acFieldName[1]+",this.form."+acFieldName[2]+")", "small",,,alEdit)+"<br>")
		aAdd(aAux, tagButton(BT_JAVA_SCRIPT, "&gt;&gt;", "moveDualList(this.form."+acFieldName[1]+",this.form."+acFieldName[2]+", true)", "small",,,alEdit)+"<br>")
		aAdd(aAux, tagButton(BT_JAVA_SCRIPT, "&lt;&lt;", "moveDualList(this.form."+acFieldName[2]+",this.form."+acFieldName[1]+", true)", "small",,,alEdit)+"<br>")
		aAdd(aAux, tagButton(BT_JAVA_SCRIPT, "&lt;"   , "moveDualList(this.form."+acFieldName[2]+",this.form."+acFieldName[1]+")", "small",,,alEdit))
		aAdd(aAux, "</td>")
		aAdd(aAux, "<td>")
		aAdd(aAux, tagInputEx(EDT_LISTBOX, acFieldName[2], "C", 15, 0, , aaOptions[2], alEdit, , "", , , .t.))
		aAdd(aAux, "</td>")
		aAdd(aAux, '<td align="center" valign="top">')
		aAdd(aAux, tagButton(BT_JAVA_SCRIPT, "^", "ordemDualList(this.form."+acFieldName[2]+",false)", "small",,,alEdit)+"<br>")
		aAdd(aAux, tagButton(BT_JAVA_SCRIPT, "v", "ordemDualList(this.form."+acFieldName[2]+",true)", "small",,,alEdit))
		aAdd(aAux, "</td>")
		aAdd(aAux, "</tr>")
		aAdd(aAux, "</table>")
		cLine += dwConcatWSep(CRLF, aAux)
	elseif acEdtType == EDT_CHECKBOX2
		// verifica se ocorreu algum erro de validação e se tem algum valor no GET
		if !empty(HttpGet->gencode) .AND. valType(acFieldName) == "C" .AND. !empty(&("HttpGet->" + acFieldName))
			axValue := ( URLDecode(DwStr(&("HttpGet->" + substr(acFieldName, 4)))) == CHKBOX_ON)
		endif
	
		axValue := (valType(axValue) == "L" .and. axValue) .or. alChoosed
		if axValue
			cLen += ' checked="checked" '
    endif               
		cLine += '<input class="chkbox" type="checkbox" ' + cLen + cEvents + ' name="'+acFieldName+'" id="'+acFieldName+'" value="'+CHKBOX_ON+'"'
		if !empty(acCaption)
			cLine += '>'
			cHotKey := iif(empty(acHotKey), "", ' accesskey="'+dwStr(acHotKey)+'" for="'+acFieldName+'"')
			if !alOnlyOneCol
				cLine += "</td><td class='buildFormBody'>"
			endif
			cLine += '<label'+cKeyLabel+cHotKey+'>'+acCaption+'</label>'
		endif
	elseif acEdtType == EDT_HCHILD_CHECK
		cLine += '<input class="chkbox" type="checkbox" '+cLen+' onfocus="doFocus(this)" onblur="doBlur(this)" name="'+acFieldName+'" id="'+acFieldName+'" value="'+DWTrataExpXML(dwStr(axValue))+'"'
		
		if (valType(axValue) == "L" .and. axValue) .or. alChoosed
			cLen += ' checked="checked" '
		endif
		
		if !empty(cLen)
			cLine += cLen
		endif
		cLine += ">"
		
		if !empty(acCaption)
			cHotKey := iif(empty(acHotKey), "", ' accesskey="'+dwStr(acHotKey)+'" for="'+acFieldName+'"')
			cLine += '<label'+cKeyLabel+cHotKey+'>'+acCaption+'</label>'
		endif
		
		cHotKey := iif(empty(acHotKey), "", ' accesskey="'+dwStr(acHotKey)+'" for="'+acFieldName+'"')
		if !alOnlyOneCol
			cLine += '</td><td>'
		endif
		
	elseif acEdtType == EDT_HCHECK
		cLine += '<input class="chkbox" type="checkbox" '+cLen+'onfocus="doFocus(this)" onblur="doBlur(this)" onclick="doSelAll(this, this.form)" name="'+acFieldName+'" id="'+acFieldName+'" value="'+DWTrataExpXML(dwStr(axValue))+'"'
		
		if (valType(axValue) == "L" .and. axValue) .or. alChoosed
			cLine += ' checked="checked" '
		endif
		
		cLine += ">"
		
		cHotKey := iif(empty(acHotKey), "", ' accesskey="'+dwStr(acHotKey)+'" for="'+acFieldName+'"')
		if !alOnlyOneCol
			cLine += "</td><td>"
		endif
		
		if !empty(acCaption)
			cLine += '<label'+cKeyLabel+cHotKey+'>'+acCaption+'</label>'
		endif
	elseif acEdtType == EDT_MULTI_STATUS
		// itera pelo array contendo as opções de status
		for nInd := 1 to len(aaOptions)
			// compara o STATUS das opções com o status atual do checkbox
			if aaOptions[nInd][1] == axValue[2]
				// recupera o css do status atual do checkbox
				cSttsClass := aaOptions[nInd][2]
				exit
			endif
		next
		cLine += '&nbsp;<input class="' + cSttsClass + '" type="checkbox" ' + cLen + 'onfocus="doFocus(this)" onblur="doBlur(this)" onclick="" name="' + acFieldName + '" id="' + acFieldName + '" value="' + DWTrataExpXML(dwStr(axValue[1])) + '"'
			
		if alChoosed
			cLen += ' checked="checked" '
		endif
			
		if !empty(cLen)
			cLine += cLen
		endif
		cLine += ">"
		if !empty(acCaption)
			cHotKey := iif(empty(acHotKey), "", ' accesskey="'+dwStr(acHotKey)+'" for="'+acFieldName+'"')
			if !alOnlyOneCol
				cLine += "</td><td class='buildFormBody'>"
			endif
			cLine += '<label'+cKeyLabel+cHotKey+'>'+acCaption+'</label>'
		endif
    else 
		if !empty(acCaption)                                     
			cHotKey := iif(empty(acHotKey), "", ' accesskey="'+dwStr(acHotKey)+'" for="'+acFieldName+'"')
			cLine += '<label'+cKeyLabel+cHotKey+'>'+acCaption+'</label>'+cNewLine
#ifdef VER_P11
			cLine += '<br>'
#endif			
			if !alOnlyOneCol
				cLine += '</td><td class="buildFormBody">'
			endif
		endif
		
		if acEdtType == EDT_EDIT .or. acEdtType == EDT_PASSWORD
			nLen := anLen+anDec
			if acType == "N"
				nLen += 1
			endif
			
			if nLen < 120
//				cLen := ' maxlength="' + dwStr(iif(anMaxLen < (nLen-1), nLen, anMaxLen)) + '"'
				cLen := ' maxlength="' + dwStr(anMaxLen) + '"'
			else
				nLen := 100
			endif
			
			cLen += ' size="'+dwStr(nLen)+'"'
			if acEdtType == EDT_PASSWORD
				cLen += ' type="password" '
			endif
			
			if alDotButton
				// verifica se ocorreu algum erro de validação e se tem algum valor no GET
				if !empty(HttpGet->gencode) .AND. valType(acFieldName) == "C" .AND. !empty(&("HttpGet->" + substr(acFieldName, 4)))
					axValue := URLDecode(DwStr(&("HttpGet->" + substr(acFieldName, 4))))
				endif
			endif
			
			if !empty(DwStr(axValue))
				if !alDotButton
					cLen += ' value="'+dwStr(axValue)+'"'
				elseif !empty(axValue) .and. left(axValue, 1) == "#" // valor possui uma cor como valor
					cLen += ' style="background-color: ' + axValue + '" readonly'
					cLen += ' value="'+dwStr(axValue)+'"'
				else
					cLen += ' value="'+dwStr(axValue)+'"'
				endif
			endif
			cLine += '<input '+cLen+cEvents+' class="' + cKey + '"' + iif(alEdit,'',' readOnly') + ' name="' + acFieldName+'" id="'+acFieldName+'">'
			if acType == "D"
				cLine += tagImage("ic_calendar.gif", 19, 19, "", "", , "showCalendar('"+acFieldName+"')")
			elseif acType == "H"
				cLine += tagImage("ic_clock.gif", 19, 19, "", "", , "showClockTable('"+acFieldName+"')")
			end
		elseif acEdtType == EDT_SHOW
			nLen := anLen+anDec        
			cLen += ' style="width:'+buildMeasure(iif(nLen == 0, 0.9, nLen*8))+';'
			if acType == "N"
				cLen += "text-align: right;"
			elseif acType == "D" .or. acType == "L"
				cLen += "text-align: center;"
			endif
			if alOnlyOneCol
				cLen += "margin-left: 5px;"
			endif
			cLen += '" readonly'
			cLen += ' value="'+dwStr(axValue)+'"'
			cLine += '<input '+cLen+cEvents+' class="readOnly" name="'+acFieldName+'" id="'+acFieldName+'">'
		elseif acEdtType == EDT_PROGRESSBAR
			cLine += "<div class='progressBar'>"+CRLF
			cLine += "<div class='progressBarEmbolo' id='"+acFieldName+"'>"+CRLF
			cLine += "&nbsp;"+CRLF
			cLine += "</div>"+CRLF
			cLine += "</div>"+CRLF
		elseif acEdtType == EDT_CHECKBOX
			// verifica se ocorreu algum erro de validação e se tem algum valor no GET
			if !empty(HttpGet->gencode) .AND. valType(acFieldName) == "C" .AND. !empty(&("HttpGet->" + acFieldName))
				axValue := ( URLDecode(DwStr(&("HttpGet->" + acFieldName))) == CHKBOX_ON)
			endif
			
			if (valType(axValue) == "L" .and. axValue) .or. (dwStr(axValue) == CHKBOX_ON)
				cLen += ' checked="checked" '
			endif
			
    	cLine += '<input class="chkbox" type="checkbox" ' + cLen + ;
	             ' onfocus="doFocus(this)" onblur="doBlur(this)" name="'+acFieldName + '" id="'+acFieldName + '"' +;
	             ' value="' + iif(valType(axValue) == "L", CHKBOX_ON, DWTrataExpXML(dwStr(axValue) ) ) + '">' + CRLF
		elseif acEdtType == EDT_CUSTOM .or. acEdtType == EDT_CUSTOM_CONT .or. acEdtType == EDT_TABBED_GROUP
			cLine += strTran(axValue, CUSTOM_EVENT, cEvents)+CRLF
		elseif acEdtType == EDT_COMBO .or. acEdtType == EDT_LISTBOX
			if acEdtType == EDT_LISTBOX
				cLen += ' multiple onClick="doFocus(this);" '
			endif
			cLine += '<select size="'+iif(acEdtType == EDT_LISTBOX, '10','1')+'" name="'+acFieldName+'" id="'+acFieldName+'" '+cEvents+cLen + iif (!empty(axValue) .and. left(DwStr(axValue), 1) == "#", " style='background-color: " + axValue + "'", "")
			cLine += ">" + CRLF
			if len(aaOptions) > 0
				for nInd := 1 to len(aaOptions)
					aOption := aaOptions[nInd]
					if left(aOption[1],1) == '-'
						if lGrupoOpen
							cLine += '</optgroup>'+CRLF
						endif
						lGrupoOpen := .t.
						cLine += '<optgroup label="'+substr(aOption[1],2)+'">"'+CRLF
					else
						cLine += '<option value="'+dwStr(aOption[2])+'"'+iif(dwStr(aOption[2])==dwStr(axValue), " selected", "")+'>'+iif(empty(aOption[1]), "&nbsp;", aOption[1])+'</option>'+CRLF
					endif
				next
				if lGrupoOpen
					cLine += '</optgroup>'+CRLF
				endif
			elseif !empty(axValue)
				cLine += '<option value="' + dwStr(axValue) + '" selected>&nbsp;</option>' + CRLF
			endif
			cLine += '</select>'
		elseif acEdtType == EDT_RADIO
			for nInd := 1 to len(aaOptions)
				aOption := aaOptions[nInd]
				cLine += '<input class="radio" type="radio" name="'+acFieldName+'" id="'+acFieldName+'" value="'+dwStr(aOption[2])+'"'+iif(dwStr(aOption[2])==dwStr(axValue), " checked", "")+ cLen +cEvents+'>'+aOption[1]+CRLF
			next
		elseif acEdtType == EDT_TEXTAREA
			cLine += '<textarea '+cLen+'name="'+acFieldName+'" id="'+acFieldName+'" rows="'+DwStr(anLen)+'" cols="'+DwStr(anDec)+'"' + iif (!alEdit, " readonly", "") + ' onClick="doFocus(this);" '+cEvents+'>'+DwStr(axValue)+'</textarea>'
		elseif acEdtType == EDT_UPLOAD
			cLine += '<input type="file" ' + cLen + 'name="' + acFieldName + '" id="' + acFieldName + iif (alEdit, '"', '" disabled') + ' onClick="doFocus(this);">'
		else
			cLine += '&nbsp;'
		endif
		if alDotButton
			if empty(acDotAction)
				if isFireFox()
					acDotAction := acFieldName+"_dot(this, event)"
				else
					acDotAction := acFieldName+"_dot(this)"
				endif
			endif
			cLine += tagButton(BT_JAVA_SCRIPT, "...", acDotAction, "small",,"dot"+acFieldName)
		endif
		if (alShowKbe)
			cLine += tagImage("ic_hlpqbe.gif", 16, 16, "QBE", STR0143 ,,"showHlpQbe(true)")
		EndIf
	endif
	
return cLine
              
/*
--------------------------------------------------------------------------------------
Gera a tag <a>, para envio de e-mail
--------------------------------------------------------------------------------------
*/                                  
function tagMailTo(acTo, acToName, alOmite)

	default alOmite := .f.
	
return tagLink("mailto:"+acTo, iif(alOmite, "", acToName), tagImage("email.gif", 20, 20, STR0087 + acToName + "(" + acTo + ")", STR0087 + acToName + "(" + acTo + ")")) //###"e-mail para: "

/*
--------------------------------------------------------------------------------------
Gera a tag <a>
--------------------------------------------------------------------------------------
*/
function tagLinkBefore(acActionLink, acText, acTagImage, aaParams, anTarget, alConfirma)

return tagLink(acActionLink, acText, acTagImage, aaParams, anTarget, .t.,,,,, alConfirma)

function tagLink(acActionLink, acText, acTagImage, aaParams, ancTarget, alImageBefore, anWidth, anHeight, anTop, anLeft, alConfirma)
	local cRet := "", cSizePos, cTarget
	local aParams, cAction
  
	default acTagImage := ""
	default ancTarget := TARGET_SAMEWINDOW
	default aaParams := {}
	default alImageBefore := .f.
	default alConfirma := .f.
	                    
	if valType(aaParams) == "A"
		aParams := packArray(aClone(aaParams))
	else
		aParams :=	{}
	end if
	
	if left(acActionLink, 5) == "http:"
		cRet += "<a href='" + acActionLink + "'"
		if valType(ancTarget) == "N"
			if ancTarget == TARGET_MODAL
				cTarget := "_modal"
			elseif ancTarget == TARGET_HIDDEN
				cTarget := "_hidden"
			elseif ancTarget == TARGET_BLANK
				cTarget := "_blank"
			else
				cTarget := "_blank"
			endif
			cRet += " target='"+cTarget+"' "
		endif
	else
		if acActionLink == "#"
			acActionLink := ""
		endif

		prepareParams(aParams)
				
		if !(ancTarget == TARGET_SAMEWINDOW)
			anWidth := isNull(anWidth, ancTarget)
			anHeight := isNull(anHeight, ancTarget)
			cSizePos := dwStr(isNull(anWidth, "null")) + "," + dwStr(isNull(anHeight, "null")) + ","
			cSizePos += dwStr(isNull(anTop, "null")) + "," + dwStr(isNull(anLeft, "null"))
			if ancTarget == TARGET_MODAL
				cTarget := "_modal"
			elseif ancTarget == TARGET_HIDDEN
				cTarget := "_hidden"
			elseif ancTarget == TARGET_BLANK .OR. ancTarget == TARGET_90_BLANK
				if !(ancTarget == TARGET_90_BLANK)
					anWidth 	:= TARGET_75_WINDOW
					anHeight 	:= TARGET_75_WINDOW
				elseif ancTarget == TARGET_100_WINDOW
					anWidth 	:= TARGET_100_WINDOW
					anHeight 	:= TARGET_100_WINDOW
				else
					anWidth 	:= TARGET_90_WINDOW
					anHeight 	:= TARGET_90_WINDOW
				endif
				
				cSizePos := dwStr(isNull(anWidth, "null")) + "," + dwStr(isNull(anHeight, "null")) + ","
				cSizePos += dwStr(isNull(anTop, "null")) + "," + dwStr(isNull(anLeft, "null"))
				cTarget := "_blank"
			else
				cTarget := "_window"
			endif                                       
			cAction := iif('?action' $ acActionLink, acActionLink, strTran(makeAction(acActionLink, aParams),"'", "\'"))
			cRet += "<a href=" + makeJSAction('doLoad('+cAction+',"'+cTarget+'",null,"winManu'+dwInt2Hex(seconds(),5)+'",'+cSizePos+","+iif(alConfirma, "true","false")+")")
		else
			if !empty(acActionLink)
				cRet += "<a href=" + makeAction(acActionLink, aParams)
				if valType(ancTarget) == "C"
					cRet += " target='"+ancTarget+"' "
				endif
			endif
		endif
	endif
	
	if !empty(acText)
		cRet += " onMouseOver="+ASPAS_D+"window.status='"+ acText +"';return true;"+ASPAS_D
	endif
	
	if !empty(acActionLink)
		cRet += ">"
	endif
	
	if alImageBefore
		cRet += acTagImage + acText
	else
		cRet += acText + acTagImage
	endif
	
	if !empty(acActionLink)
		cRet += "</a>"
	endif
	
return cRet	

/*
--------------------------------------------------------------------------------------
Gera a tag <a> com target em nova janela
--------------------------------------------------------------------------------------
*/
function tagLinkWin(acActionLink, acText, acTagImage, aaParams, anTarget, anWidth, anHeight, anTop, anLeft, alConfirma)

return tagLink(acActionLink, acText, acTagImage, aaParams, anTarget, , anWidth, anHeight, anTop, anLeft, alConfirma)

/*
--------------------------------------------------------------------------------------
Gera a tag <a> com target TARGET_MODAL
--------------------------------------------------------------------------------------
*/
static function tagLinkModal(acActionLink, acText, acTagImage, aaParams)

return tagLink(acActionLink, acText, acTagImage, aaParams, TARGET_WINDOW /*TARGET_MODAL*/,, TARGET_50_WINDOW, TARGET_50_WINDOW)

/*
--------------------------------------------------------------------------------------
Gera a tag <a> com target TARGET_75_WINDOW
--------------------------------------------------------------------------------------
*/          
/*
static function tagLink75Win(acActionLink, acText, acTagImage, aaParams)

return tagLink(acActionLink, acText, acTagImage, aaParams, TARGET_WINDOW, ,TARGET_75_WINDOW, TARGET_75_WINDOW)
*/
/*
--------------------------------------------------------------------------------------
Gera a tag <a> com target TARGET_50_WINDOW
--------------------------------------------------------------------------------------
*/
function tagLink50Win(acActionLink, acText, acTagImage, aaParams)

return tagLink(acActionLink, acText, acTagImage, aaParams, TARGET_WINDOW, , TARGET_50_WINDOW, TARGET_50_WINDOW)

/*
--------------------------------------------------------------------------------------
Gera a tag <a> com target TARGET_25_WINDOW
--------------------------------------------------------------------------------------
*/              
/*
static function tagLink25Win(acActionLink, acText, acTagImage, aaParams)

return tagLink(acActionLink, acText, acTagImage, aaParams, TARGET_WINDOW,, TARGET_25_WINDOW, TARGET_25_WINDOW)
*/
/*
--------------------------------------------------------------------------------------
Gera a tag <a> com target TARGET_CUSTOM
--------------------------------------------------------------------------------------
*/
/*
static function tagLinkCustomWin(acActionLink, acText, acTagImage, aaParams, anWidth, anHeight, anTop, anLeft)

return tagLink(acActionLink, acText, acTagImage, aaParams, TARGET_WINDOW, ,anWidth, anHeight, anTop, anLeft)
*/

/*
--------------------------------------------------------------------------------------
Gera a url de uma imagem, verificando a estrutura de temas
Args: acImageFile - nome do arquivo de imagem
      alAspas - indica se deve retornar o arquivo com aspas ou não
--------------------------------------------------------------------------------------
*/                    
function urlImage(acImageFile, alAspas, acSubTheme, alFullPath)

return urlFile(acImageFile, alAspas, nil, acSubTheme, alFullPath)

/*
--------------------------------------------------------------------------------------
Gera a url de arquivos em geral, verificando a estrutura de temas
Args: acFilename - nome do arquivo 
      alAspas - indica se deve retornar o arquivo com aspas ou não
      acTheme - nome do tema
      acSubTheme - nome do sub-tema                                            
      alFullPath - retorna a url completa
--------------------------------------------------------------------------------------
*/                    
function urlFile(acFileName, alAspas, acTheme, acSubTheme, alFullPath)
	local cRet := acFileName
	local cRootPath := GetPvProfString(getEnvServer(), "RootPath", "", GetADV97())
	local cPatchWeb := GetPvProfString(getWebHost(), "Path", "web/sigadw3", GetADV97())
  local oWebApp := getWebApp()
		                      
	default alAspas := .t.
  default acTheme := oWebApp:theme()
  default acSubTheme := ""
	default alFullPath := .f.
	
	if !(right(cRootPath, 1) $ "/\")
		cRootPath += "/"
	endif
			
	cPatchWeb := substr(cPatchWeb, len(cRootPath))
	if !empty(acSubTheme) .and. file(cPatchWeb+"/themes/"+acTheme+"/"+acSubTheme+"/"+cRet)
		cRet := "themes/"+acTheme+"/"+acSubTheme+"/"+cRet
	elseif file(cPatchWeb+"/themes/custom/"+cRet)
		cRet := "themes/custom/"+cRet
	elseif file(cPatchWeb+"/themes/"+acTheme+"/"+cRet)
		cRet := "themes/"+acTheme+"/"+cRet
	elseif file(cPatchWeb+"/themes/"+cRet)
		cRet := "themes/"+cRet
	elseif file(cPatchWeb+"/"+cRet)
		cRet := cRet
	else  
		if DWIsDebug() .and. !("_on" $ cRet)
			conout(STR0014 + " [" + cRet + "] " + STR0015)
			conout("         " + STR0016 + " ["+acTheme+"/"+acSubTheme+"]")
		endif
		cRet := ""
	endif

	if alFullPath
		cRet := "http://"+ getWebHost() + "/" + cRet
	endif   
	
	if alAspas
		cRet := "'" + cRet + "'"
	endif
	
return cRet			
      
/*
--------------------------------------------------------------------------------------
Monta a url do arquivo CSS, conforme o tema
Args: 
--------------------------------------------------------------------------------------
*/                    
function urlCSS(acCSSName, acDevice)
	local cRet, cBase
  local oWebApp := getWebApp()
	
	if valType(acCSSName) == "U"
		cBase := oWebApp:theme() + iif (!empty(acDevice), "_" + acDevice, "")
		cRet := urlFile(cBase + iif(isFireFox(), "_ff.css", "_ie.css"))
		if empty(cRet)
			cRet := cBase + ".css"
		endif
	else
		cRet := urlFile(acCSSName)
	endif
return cRet

/*
--------------------------------------------------------------------------------------
Monta a url do arquivo CSS de impressão, conforme o tema
Args: 
--------------------------------------------------------------------------------------
*/                    
function urlCSSPrint(acCSSName)
return urlCSS(acCSSName, "print")

/*
--------------------------------------------------------------------------------------
Prepara qualquer campos de formulários
--------------------------------------------------------------------------------------
*/                    
Function makeFieldDef(acEdtType, acName, acCaption, acHotkey, alRequired, acType, anLen, anDec, axValue, aaOptions, alKey, alDefaultEvents, alChoosed, anMaxLen, alShowKbe, lIsUser)
	Local aEvents := {}
	
	Default alKey := .f.
	Default alDefaultEvents := .t.
	Default alChoosed := .F.
	Default alRequired := .F.
	Default anDec := 0
	Default anMaxLen := anLen
	Default lIsUser := .F. // Por Default é setado que não é manutenção de usuário.

	if acEdtType == EDT_CUSTOM .or. acEdtType == EDT_CUSTOM_CONT .or. acEdtType == EDT_TABBED_PANE .or.;
		 acEdtType == EDT_TABBED_CHILD .or. acEdtType == EDT_TABBED_JSPANE .or. acEdtType == EDT_LEGEND .or. ;
		 acEdtType == EDT_TABBED_GROUP
	elseif alDefaultEvents
		aEvents := { { "onfocus", "doFocus(this)", .f.}, ;
		             { "onblur", "doBlur(this, '"+iif(alKey .and. acType == "C", "B", acType)+"')", .f. } }
		if acType == "N"
			if isFireFox()
				aAdd(aEvents, { "onkeypress", "return checkNumber(this, event)", .f. })
			else
				aAdd(aEvents, { "onkeypress", "return checkNumber(this)", .f. })
			endif
		ElseIf alKey .and. acType == "C"
			If isFireFox()				
				If lIsUser  // Caso seja manutenção de usuário.
					aAdd(aEvents, { "onkeypress", "return checkKeyForUser(this, event)", .f. })
				Else
					aAdd(aEvents, { "onkeypress", "return checkKey(this, event)", .f. })
				EndIf
			Else
				If lIsUser
					aAdd(aEvents, { "onkeypress", "return checkKeyForUser(this)", .f. })
				Else
					aAdd(aEvents, { "onkeypress", "return checkKey(this)", .f. })
				EndIF
			EndIf
		elseif acType == "D"
			if isFireFox()
				aAdd(aEvents, { "onkeypress", "return checkDate(this, event)", .f. })
			else
				aAdd(aEvents, { "onkeypress", "return checkDate(this)", .f. })
			endif
		endif	
	endif

return { acEdtType, acName, acCaption, acHotkey, alRequired, acType, anLen, anDec, axValue, aaOptions, alKey, aEvents, .f., alChoosed, "", .F., anMaxLen, .F. }

/*
--------------------------------------------------------------------------------------
Prepara coluna para edição
--------------------------------------------------------------------------------------
*/                    
function makeEditCol(aaCols, anEdtType, acFieldName, acCaption, alRequired, acType, anLen, anDec, aaOptions, alDotButton, alReadOnly, alDotDefAct, anMaxLen)
  local aField
  
  default alDotButton 	:= .f.
  default alReadOnly 	:= .t.
  default alDotDefAct 	:= .T.
  default anMaxLen 		:= anLen
                                
  if anEdtType == EDT_HIDDEN                                        
    aField := makeFieldDef(EDT_SHOW, acFieldName, "", "", .f., "C", 1, 0)
    aField[FFLD_EDTTYPE] := anEdtType
  else
    aField := makeFieldDef(anEdtType, acFieldName, acCaption, "", alRequired, acType, anLen, anDec, nil, aaOptions, nil, , , anMaxLen)
  endif
  
  if alDotButton  
    aField[FFLD_DOTBUTTON] := alDotButton
    aField[FFLD_DOTINPUT] := !alReadOnly
    if alDotDefAct
			if isFireFox()
		    aField[FFLD_DOTBTNACT] := acFieldName+"_dot(this, '"+acFieldName+"', event)"
			else
		    aField[FFLD_DOTBTNACT] := acFieldName+"_dot(this, '"+acFieldName+"')"
			endif
  	endif
  endif

  aAdd(aaCols, aField)
  
return

/*
--------------------------------------------------------------------------------------
Prepara legenda para formulários
Args:
  acImage, string, nome do arquivo de imagem
  acText, texto da legenda
--------------------------------------------------------------------------------------
*/                    
function makeLegend(aaFields, acImage, acText)

	aAdd(aaFields, makeFieldDef(EDT_LEGEND, acImage, acText))

return

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (edit)
--------------------------------------------------------------------------------------
*/                    
function makeField(aaFields, acFieldName, acCaption, alRequired, acType, anLen, anDec, acHotKey, axValue, alKey, lIsUser)
	Local aLocalFields
	Local cOptionalReturn
	
	Default lIsUser := .F. // Por Default é setado que não é manutenção de usuário.

	if acType == "L"
		If lIsUser			
			aLocalFields := makeFieldDef(EDT_CHECKBOX, acFieldName, acCaption, acHotKey, alRequired, acType, 1, 0, axValue, nil,alKey,,,,,lIsUser)
		Else
			aLocalFields := makeFieldDef(EDT_CHECKBOX, acFieldName, acCaption, acHotKey, alRequired, acType, 1, 0, axValue, nil,alKey)
		EndIf
	ElseIf acType == "D"
		If lIsUser
			aLocalFields := makeFieldDef(EDT_EDIT, acFieldName, acCaption, acHotKey, alRequired, acType, 10, 0, axValue, nil,alKey,,,,,lIsUser)
		Else
			aLocalFields := makeFieldDef(EDT_EDIT, acFieldName, acCaption, acHotKey, alRequired, acType, 10, 0, axValue, nil,alKey)			
		EndIf			
	Else
		If lIsUser
			aLocalFields := makeFieldDef(EDT_EDIT, acFieldName, acCaption, acHotKey, alRequired, acType, anLen, anDec, axValue, nil,alKey,,,,,lIsUser)
		Else
			aLocalFields := makeFieldDef(EDT_EDIT, acFieldName, acCaption, acHotKey, alRequired, acType, anLen, anDec, axValue, nil,alKey)
		EndIf			
	EndIf

	if valType(aaFields) == "U"
		cOptionalReturn := buildComponent(aLocalFields, .T., .T.)
	else
		aAdd(aaFields, aLocalFields)
	endif

return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários do tipo data (edit)
--------------------------------------------------------------------------------------
*/                    
function makeDateField(aaFields, acFieldName, acCaption, acDateFormat, alRequired, acHotKey, axValue, alKey)

	default acDateFormat := "dd/mm/aaaa"
	default axValue	  	 := ""

return makeField(aaFields, acFieldName, acCaption, alRequired, "D", 10, 0, acHotKey, axValue, alKey)

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (edit) com botão de ação associado
--------------------------------------------------------------------------------------
*/                    
function makeDotField(aaFields, acFieldName, acCaption, alRequired, acType, anLen, anDec, acHotKey, axValue, alKey, acJSFuncName, alInputEnabled, alShowKbe)
	Local cEventName := "_dot"
	Local nPos
	
	default alInputEnabled := .F.
	
	if acType == "M"                                                  
	  	default anDec := 0
		makeTextArea(aaFields, acFieldName, acCaption, alRequired, iif(anDec == 0, 30, anDec), anLen, acHotKey, axValue)
	else
		makeField(aaFields, acFieldName, acCaption, alRequired, acType, anLen, anDec, acHotKey, axValue, alKey)
  	endif
    
  	if !empty(acJSFuncName)
   		cEventName := "_dotjs"
   	endif
    
 	nPos := ascan(aaFields, { |x| x[FFLD_NAME] == acFieldName })
	aaFields[nPos, FFLD_DOTINPUT] := alInputEnabled
	aaFields[nPos, FFLD_SHOWKBE] := alShowKbe
    
  	evtField(aaFields, acFieldName, cEventName, acJSFuncName)
	
return

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (check)
--------------------------------------------------------------------------------------
*/                    
function makeCheckField(aaFields, acFieldName, acCaption, alRequired, acHotKey, axValue, alChoosed)
	local aCheckField, cOptionalReturn
	
	default alChoosed 	:= .F.
	default axValue		:= .F.
	
	aCheckField := makeFieldDef(EDT_CHECKBOX2, acFieldName, acCaption, acHotKey, alRequired, "L", 1, 0, axValue, , , , alChoosed)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aCheckField)
	else
		cOptionalReturn := buildComponent(aCheckField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (check)
--------------------------------------------------------------------------------------
*/
#define STTS_MARKED      "chkbox marked"
#define STTS_NOT_MARKED  "chkbox notMarked"
#define STTS_INHERITANCE "chkbox inheritance"

#define CSS_MARKED       "chkbox statusMarked"
#define CSS_NOT_MARKED   "chkbox statusNotMarked"
#define CSS_INHERITANCE  "chkbox statusInheritance"

function makeCheckMultipleStatus(aaFields, acFieldName, acCaption, alRequired, acHotKey, axValue, alSelected, alInheritance, aaPossibleStatus)
	local aCheckField, cOptionalReturn, cStatus, xValue, lChoosed := .F.
	
	default aaPossibleStatus := { { STTS_MARKED, CSS_MARKED }, { STTS_NOT_MARKED, CSS_NOT_MARKED }, { STTS_INHERITANCE, CSS_INHERITANCE } }
	default alSelected := .F.
	default alInheritance := .F.
	
	if alSelected
		cStatus := STTS_MARKED
		lChoosed := .T.
	elseif alInheritance
		cStatus := STTS_INHERITANCE
		lChoosed := .T.
	else
		cStatus := STTS_NOT_MARKED
	endif
	
	if valType(axValue) == "U"
		xValue := { "", cStatus }
	else
		xValue := { axValue, cStatus }
	endif
	
	aCheckField := makeFieldDef(EDT_MULTI_STATUS, acFieldName, acCaption, acHotKey, alRequired, "L", 1, 0, xValue, aaPossibleStatus, , , lChoosed)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aCheckField)
	else
		cOptionalReturn := buildComponent(aCheckField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara campo customizado
--------------------------------------------------------------------------------------
*/                    
function makeCustomField(aaFields, acFieldName, acHtmlCode, acEditType)
	Local aLocalFields, nInd
	Local cOptionalReturn
    
  default acEditType := EDT_CUSTOM

	if valType(acHtmlCode) == "A"
		aAux := {}         
		cOptionalReturn := "<div id='blk"+acFieldName+"'>"
		for nInd := 1 to len(acHtmlCode)
			cOptionalReturn += buildComponent(acHtmlCode[nInd], .T., .T.)
		next
		cOptionalReturn += "</div>"
		aAdd(aaFields, makeFieldDef(acEditType, acFieldName, , , , , , , cOptionalReturn, , , , ))
	else
		aLocalFields := makeFieldDef(acEditType, acFieldName, , , , , , , acHtmlCode, , , , )
		if valType(aaFields) == "U"
			cOptionalReturn := buildComponent(aLocalFields, .T., .T.)
		else
			aAdd(aaFields, aLocalFields)
		endif
	endif
		
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara span para receber atualizações
--------------------------------------------------------------------------------------
*/                    
function makeSpan(aaFields, acSpanID)

return makeCustomField(aaFields, acSpanID, "<span id='"+acSpanID+"'></span>")

/*
--------------------------------------------------------------------------------------
Prepara div dentro do form 
--------------------------------------------------------------------------------------
*/                    
function makeDivForm(aaFields, acFieldName, acCaption, anHeight, alScrollY, alScrollX)
  local aBuffer := {}
  local cStyle := ""
  
  default alScrollY := .f.
  default alScrollX := .f.
  
  cStyle += "height:"+buildMeasure(anHeight) + ";"

  if alScrollY 
  	cStyle += "overflow-y:auto;"
  else
  	cStyle += "overflow-y:hidden;"
	endif

  if alScrollX
  	cStyle += "overflow-x:auto;"
  else
  	cStyle += "overflow-x:hidden;"
	endif
  
	aAdd(aBuffer, "<div id='"+acFieldName+"' style='"+cStyle+"'>")
	aAdd(aBuffer, "</div>")

  makeSubTitle(aaFields, acCaption) //, acActTitle, acAction)
	
return makeCustomField(aaFields, acFieldName, dwConcatWSep(CRLF, aBuffer), EDT_CUSTOM)

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (radio)
--------------------------------------------------------------------------------------
*/                    
function makeRadioField(aaFields, acFieldName, acCaption, alRequired, acHotKey, axValue, aaOptions)

	aAdd(aaFields, makeFieldDef(EDT_RADIO, acFieldName, acCaption, acHotKey, alRequired, "C", 1, 0, axValue, aaOptions))

return

/*
--------------------------------------------------------------------------------------
Prepara texto simples
--------------------------------------------------------------------------------------
*/
function makeTextArea(aaFields, acFieldName, acCaption, alRequired, nCols, nRows, acHotKey, axValue)
	
	aAdd(aaFields, makeFieldDef(EDT_TEXTAREA, acFieldName, acCaption, acHotKey, alRequired, "M", nRows, nCols, axValue))
	
return

/*
--------------------------------------------------------------------------------------
Prepara evento para um campo de formulários
--------------------------------------------------------------------------------------
*/
function evtField(aaFields, acFieldName, acEventName, acJSFuncName, alFireOnInit)
	local nPos, aEvents

	default alFireOnInit := .f.
	
	nPos := ascan(aaFields, { |x| x[FFLD_NAME] == acFieldName })
	aEvents := aaFields[nPos, FFLD_EVENTS]
			
	if valType(acJSFuncName) == "U"
		acJSFuncName := acFieldName + "_" + acEventName + "(this)"
	endif

	if acEventName == "_dot"
		aaFields[nPos, FFLD_DOTBUTTON] := .t.
	elseif acEventName == "_dotjs"
		aaFields[nPos, FFLD_DOTBUTTON] := .t.
		aaFields[nPos, FFLD_DOTBTNACT] := acJSFuncName
	else
		nPos := ascan(aEvents, { |x| x[FFLD_EVENTNAME] == acEventName })
		if nPos == 0
			aAdd(aEvents, { acEventName, acJSFuncName, alFireOnInit } )
		else		
			aEvents[nPos, FFLD_EVENTJS] += ";" + acJSFuncName
		endif
	endif
return

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (check) com searador dos campos checks filhos
--------------------------------------------------------------------------------------
*/                    
function makeHCheckField(aaFields, acFieldName, acCaption, alRequired, alChild, acHotKey, axValue, alChoosed)
	Local cType := EDT_HCHILD_CHECK
	Local cOptionalReturn
	Local aCheckField
	
	default alChild 	:= .T.
	default alChoosed 	:= .F.
	
	if !alChild
		cType := EDT_HCHECK
	endif
	
	aCheckField := makeFieldDef(cType, acFieldName, acCaption, acHotKey, alRequired, "L", 1, 0, axValue, , , , alChoosed)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aCheckField)
	else
		cOptionalReturn := buildComponent(aCheckField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara campos de upload de arquivos
--------------------------------------------------------------------------------------
*/                    
function makeFileField(aaFields, acFieldName, acCaption, alRequired, acHotKey, axValue)
	Local cOptionalReturn
	Local aField
		
	aField := makeFieldDef(EDT_UPLOAD, acFieldName, acCaption, acHotKey, alRequired, "F", 15, 0, axValue)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aField)
	else
		cOptionalReturn := buildComponent(aField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara titulo H1
--------------------------------------------------------------------------------------
*/
function makeH1(aaFields, acText)
	aAdd(aaFields, makeFieldDef(EDT_H1, '', acText, nil, nil, "C", nil, nil, nil))
return

/*
--------------------------------------------------------------------------------------
Monta HTML de titulo H1
--------------------------------------------------------------------------------------
*/
function buildH1(acText)

return '<div class="dw_h1">' + acText + '</div>'

/*
--------------------------------------------------------------------------------------
Prepara titulo H2
--------------------------------------------------------------------------------------
*/
function makeH2(aaFields, acText)
	aAdd(aaFields, makeFieldDef(EDT_H2, '', acText, nil, nil, "C", nil, nil, nil))
return

/*
--------------------------------------------------------------------------------------
Monta HTML de titulo H2
--------------------------------------------------------------------------------------
*/
function buildH2(acText)

return '<div class="dw_h2">' + acText + '</div>'

/*
--------------------------------------------------------------------------------------
Prepara titulo
--------------------------------------------------------------------------------------
*/
function makeTitle(aaFields, acTitle)
	
	Local aCheckField, cOptionalReturn
	
	aCheckField := makeFieldDef(EDT_TITLE, '', acTitle, nil, nil, "C", nil, nil, nil)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aCheckField)
	else
		cOptionalReturn := buildComponent(aCheckField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Monta HTML de titulo
--------------------------------------------------------------------------------------
*/
function buildTitle(acTitle)

return '<span class="dw_title">'+acTitle+'</span>'
		
/*
--------------------------------------------------------------------------------------
Prepara sub-titulo
--------------------------------------------------------------------------------------
*/
function makeSubTitle(aaFields, acTitle, acActTitle, acAction)
	Local aCheckField, cOptionalReturn
	
	aCheckField := makeFieldDef(EDT_SUBTITLE, '', acTitle, nil, nil, "C", nil, acActTitle, acAction)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aCheckField)
	else
		cOptionalReturn := buildComponent(aCheckField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Monta HTML de sub-titulo
--------------------------------------------------------------------------------------
*/
function buildPtTitle(acTitle)
	local cRet := ""
	
  if httpSession->PORTAL
		cRet := "<h2 STYLE='margin-bottom:0px;margin-top:0px'>"+acTitle+"</h2>"
  else
		cRet := "<p align='justify' class='titulo'>&raquo; "+ acTitle + "</p>"
	endif
	
return cRet

function buildSubTitle(acSubTitle, acOperation, acAction)
	local oWebApp := getWebApp()
	local cRet := iif(!(valType(oWebApp) == "U") .and. oWebApp:theme()==THEME_TOTVSUP, ;
									"<h2 style='margin-bottom:5px;margin-top:10px;'>"+acSubTitle+"</h2>", ;
									"<span class='dw_subtitle'>"+acSubTitle+"</span>")
	
	if valType(acOperation) == "C"
		cRet += tagButton(BT_JAVA_SCRIPT, acOperation, 'doLoad('+acAction+',"_window",null,"null","' + DwStr(TARGET_75_WINDOW) + '","' + DwStr(TARGET_75_WINDOW) + '")', nil, nil, nil)
	endif	
	
return cRet

/*
--------------------------------------------------------------------------------------
Monta HTML de mensagem de atenção
--------------------------------------------------------------------------------------
*/
function buildAttention(acText)

return '<span class="attention">'+acText+'</span>'

/*
--------------------------------------------------------------------------------------
Monta HTML de mensagem de aviso
--------------------------------------------------------------------------------------
*/
function buildWarning(acText)

return '<span class="warning">'+acText+'</span>'

/*
--------------------------------------------------------------------------------------
Prepara texto simples
--------------------------------------------------------------------------------------
*/
function makeText(aaFields, acText)
	Local aCheckField, cOptionalReturn

	aCheckField := makeFieldDef(EDT_TEXT, '', DwStr(acText), nil, nil, "C", nil, nil, nil)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aCheckField)
	else
		cOptionalReturn := buildComponent(aCheckField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara linha em branco
--------------------------------------------------------------------------------------
*/
function makeBlankRow(aaFields)
	
	aAdd(aaFields, makeFieldDef(EDT_BLANK, '', '', nil, nil, "C", nil, nil, nil))
	
return

/*
--------------------------------------------------------------------------------------
Prepara texto de warning/atenção
--------------------------------------------------------------------------------------
*/
function makeAttention(aaFields, acText)

	Local aField, cOptionalReturn
	
	aField := makeFieldDef(EDT_ATTENTION, '', acText, nil, nil, "C", nil, nil, nil)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aField)
	else
		cOptionalReturn := buildComponent(aField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara seleção dual-list
--------------------------------------------------------------------------------------
*/
function makeDualList(aaFields, acSubTitle, acSrcCaption, acSrcField, aaSrcOptions,acTargCaption, acTargField, aaTargOptions, alRequired, acHotKey)

	aAdd(aaFields, makeFieldDef(EDT_SUBTITLE, "", acSubTitle, acHotKey, alRequired, "C", 0, 0, nil, nil))
	aAdd(aaFields, makeFieldDef(EDT_DUALLIST, { acSrcField, acTargField }, { acSrcCaption, acTargCaption } , acHotKey, alRequired, "C", 0, 0, nil, { aClone(aaSrcOptions), aClone(aaTargOptions) }))

return

/*
--------------------------------------------------------------------------------------
Prepara texto de warning
--------------------------------------------------------------------------------------
*/
function makeWarning(aaFields, acText)
	
	Local aField, cOptionalReturn
	
	aField := makeFieldDef(EDT_WARNING, '', acText, nil, nil, "C", nil, nil, nil)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aField)
	else
		cOptionalReturn := buildComponent(aField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Gera o código de confirmação
--------------------------------------------------------------------------------------
*/       
function buildConfCode(nRandByTime)
	local cConfCode := "", nInd, cLetter
	
	if dwIsAjax()
		for nInd := 1 to 5
      cLetter := "@"
			while !isDigit(cLetter) .and. !isAlpha(cLetter)
				cLetter := chr(randomize(48, 122))
			enddo
			cConfCode += cLetter
		next
	else
	default nRandByTime := randByTime()

	cConfCode := "<big><span style='border:1px solid black;color:red;letter-spacing:2px;background-color:#dddddd'><b>&nbsp;&nbsp;" ;
   			+ nRandByTime + "&nbsp;&nbsp;</b></span></big>"
	endif

return cConfCode

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (edit) que são chaves unicas
--------------------------------------------------------------------------------------
*/                    
function makeKeyField(aaFields, acFieldName, acCaption, alRequired, acType, anLen, anDec, acHotKey, axValue, lIsUser)

	Default lIsUser := .F.

	makeField(aaFields, acFieldName, acCaption, alRequired, acType, anLen, anDec, acHotKey, axValue, .t., lIsUser)

return	

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (password)
--------------------------------------------------------------------------------------
*/                    
function makePassword(aaFields, acFieldName, acCaption, alRequired, acType, anLen, anDec, acHotKey, axValue, anMaxLen)

	aAdd(aaFields, makeFieldDef(EDT_PASSWORD, acFieldName, acCaption, acHotKey, alRequired, acType, anLen, anDec, axValue,,,,,anMaxLen))

return	

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (hidden)
--------------------------------------------------------------------------------------
*/                    
function makeHidden(aaFields, acFieldName, axValue)
	Local aField, cOptionalReturn
	
	aField := makeFieldDef(EDT_HIDDEN, acFieldName, nil, nil, nil, nil, nil, nil, axValue, nil, nil, .f.)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aField)
	else
		cOptionalReturn := buildComponent(aField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (progressBar)
--------------------------------------------------------------------------------------
*/                    
function makeProgressBar(aaFields, acFieldName, anValue)
	Local aField, cOptionalReturn
	
	aField := makeFieldDef(EDT_PROGRESSBAR, acFieldName, "", nil, nil, nil, nil, nil, anValue, nil, nil, .f.)
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aField)
	else
		cOptionalReturn := buildComponent(aField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (show)
--------------------------------------------------------------------------------------
*/                    
function makeShow(aaFields, acFieldName, acCaption, axValue, anLen)
	local aField, cOptionalReturn
	
	default anLen := len(axValue)
	
	aField := makeFieldDef(EDT_SHOW, acFieldName, acCaption, nil, .f., "C", anLen, 0, axValue)

	if valType(aaFields) == "A"
		aAdd(aaFields, aField)
	else
		cOptionalReturn := buildComponent(aField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (combos)
Args: 
--------------------------------------------------------------------------------------
*/                    
function makeCombo(aaFields, acFieldName, acCaption, alRequired, aaOptionList, acHotKey, axValue)
	local nTam := -1, nInd
	local aField, cOptionalReturn
	
	for nInd := 1 to len(aaOptionList)
		nTam := max(nTam, len(aaOptionList[nInd,1]))
	next
	
	aField := makeFieldDef(EDT_COMBO, acFieldName, acCaption, acHotKey, alRequired, "C", nTam, 0, axValue, aClone(aaOptionList))
	
	if valType(aaFields) == "A"
		aAdd(aaFields, aField)
	else
		cOptionalReturn := buildComponent(aField, .T., .T.)
	endif
	
return cOptionalReturn

/*
--------------------------------------------------------------------------------------
Prepara um combo de tipos válidos atributo ou indicadores para o DW
Args: 
--------------------------------------------------------------------------------------
*/
function makeDWTypesCombo(aaFields, acFieldName, acCaption, alRequired, acHotKey, axValue)

	makeCombo(aaFields, acFieldName, acCaption, alRequired, dwComboOptions(ADVPL_FIELD_TYPES), acHotKey, axValue)
	
return

/*
--------------------------------------------------------------------------------------
Prepara um combo de classes válidos para o DW
Args: 
--------------------------------------------------------------------------------------
*/
function makeDWClassesCombo(aaFields, acFieldName, acCaption, alRequired, acHotKey, axValue)

	Local aDWClass := { {STR0017, "D"}, ; 	//###"Dimensão"
	 					{STR0018, "A"}, ;	//###"Aditivo"
	 					{STR0019, "S"}, ;	//###"Semi-Aditivo"
	 					{STR0020, "M"}, ;	//###"Mini-Dimensão"
	 					{STR0021, "C"} }	//###"Calculado"
	makeCombo(aaFields, acFieldName, acCaption, alRequired, aDWClass, acHotKey, axValue)
	
return
/*
--------------------------------------------------------------------------------------
Prepara campos de formulários (listbox)
Args: 
--------------------------------------------------------------------------------------
*/                    
function makeListBox(aaFields, acFieldName, acCaption, alRequired, aaOptionList, acHotKey, axValue)
	local nTam := -1, nInd
	
	for nInd := 1 to len(aaOptionList)
		nTam := max(nTam, len(aaOptionList[nInd,1]))
	next
	
	aAdd(aaFields, makeFieldDef(EDT_LISTBOX, acFieldName, acCaption, acHotKey, alRequired, "C", nTam, 0, axValue, aClone(aaOptionList)))

return	

/*
--------------------------------------------------------------------------------------
Prepara botões adicionais de operações (edição)
Args: 
Observação:
  Na necessidade de testar a disponibilidade ou não do botão, com base nos dados da
  linha corrente, crie um função JS chamada "u_operActIsEnable", que recebe como paramento
  o número posicional do botão acionado e o ID da linha associada ao botão.
  O retorno desta, deve ser um valor lógico.
--------------------------------------------------------------------------------------
*/                    
function makeOperAct(aaOperButtons, acCaption, acIcone, acAction, aaParams, anTargetWin, alMenu, alConf, alAlwaysVisible)
	default anTargetWin 	:= TARGET_50_WINDOW
	default alMenu 			:= .T.
	default alConf 			:= .f.
	default alAlwaysVisible := .f.
	
	aAdd(aaOperButtons, { acCaption, acIcone, acAction, aaParams, anTargetWin, alMenu, alConf, alAlwaysVisible })

return

/*
--------------------------------------------------------------------------------------
Prepara botões
Args: 
--------------------------------------------------------------------------------------
*/                    
function makeButton(aaButtons, acType, acCaption, acAction, alSmall, aaActionParams, alEnabled, acID)
	local cRet, aBuffer := {}
	
	default alSmall := .f.
	default aaActionParams := {}
	default alEnabled := .t.
	default acID := ""

	if valType(aaButtons) == "A"
	  if dwIsAjax() .and. len(aaButtons) == 0
			aAdd(aaButtons, { BT_NO_INS_DEFAULT, "", "", .f., {}, .f., "" })
		endif	  	
		aAdd(aaButtons, { acType, acCaption, acAction, alSmall, aaActionParams, alEnabled, acID })
	else
		buildButton(aBuffer, {{ acType, acCaption, acAction, alSmall, aaActionParams, alEnabled, acID }})
		cRet := dwConcatWSep(CRLF, aBuffer)
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Gera o HTML para botões
Args: 
--------------------------------------------------------------------------------------
*/                    
function buildButton(aaBuffer, aaButtons, alForm)
	local nInd, aButton
	default alForm := .f.
	
	if alForm
		aAdd(aaBuffer, '<tr>')
		aAdd(aaBuffer, '<td>&nbsp;</td>')
		aAdd(aaBuffer, '<td colspan="2">') //nowrap 
	endif
		
	for nInd := 1 to len(aaButtons)
		aButton := aaButtons[nInd]
		if aButton[BTN_TYPE] == BT_NO_INS_DEFAULT
		elseif aButton[BTN_TYPE] == BT_RIGHT_ALIGN
		elseif aButton[BTN_TYPE] == BT_BREAKROW
			aAdd(aaBuffer, "<br>")
		elseif aButton[BTN_TYPE] = BT_CUSTOM
			aAdd(aaBuffer, aButton[BTN_CAPTION])
		else
			aAdd(aaBuffer, tagButton(aButton[BTN_TYPE], aButton[BTN_CAPTION], aButton[BTN_ACTION], iif(valType(aButton[BTN_SMALL]) == "L" .AND. aButton[BTN_SMALL],"small",""), aButton[BTN_ACTPARMS], aButton[BTN_ID], aButton[BTN_ENABLE]))
		endif
	next      

	if alForm
		aAdd(aaBuffer, '</td><td>&nbsp;</td>')
		aAdd(aaBuffer, '</tr>')
	endif
		
return

/*
--------------------------------------------------------------------------------------
Gera o HTML para botões
Args: 
--------------------------------------------------------------------------------------
*/                    
function buildStepsButton(aaBuffer, aaButtons, alForm)
	local nInd
	default alForm := .f.
	
	if alForm
		aAdd(aaBuffer, '<tr>')
		aAdd(aaBuffer, '<td>&nbsp;</td>')
		aAdd(aaBuffer, '<td colspan="2">') //nowrap 
	endif
		
	for nInd := 1 to len(aaButtons)
		aAdd(aaBuffer, aaButtons[nInd][2])
	next      

	if alForm
		aAdd(aaBuffer, '</td><td>&nbsp;</td>')
		aAdd(aaBuffer, '</tr>')
	endif
		
return

/*
--------------------------------------------------------------------------------------
Executa um ação automaticamente, se o usuário não interferir
--------------------------------------------------------------------------------------
*/
function buildAutoStart(acAction, acMsg, anTime) //em segundos
	local aBuffer := {}

	default acMsg := ""

	acMsg += "<br><small>" + STR0022 + " <span id='statusTime'>" + dwStr(anTime) + "</span>&nbsp;" + STR0023 + ".</small>"	//###"O procedimento será iniciado em"###segundos
	acMsg += "<br><br>"+tagButton(BT_JAVA_SCRIPT, STR0024, "doNow()") 	//###"Agora"
	acMsg += tagButton(BT_JAVA_SCRIPT, STR0025, "doCancelAutoStart()") //###"Cancelar"
	
	default anTime := 8
			
	aAdd(aBuffer, '<!-- autoStartAction -->')     
	aAdd(aBuffer, buildMessage(acMsg))
	aAdd(aBuffer, tagJS())

	aAdd(aBuffer, "var xTimeout = setInterval('doCountDown()', 1000);")
	aAdd(aBuffer, "var nTime = "+dwStr(anTime+1)+";")
	aAdd(aBuffer, "var oTime = getElement('statusTime');")

	aAdd(aBuffer, "function doNow()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  nTime = -1;")
	aAdd(aBuffer, "}")

	aAdd(aBuffer, "function doCountDown()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  nTime--;")
	aAdd(aBuffer, "  if (nTime < 1)")
	aAdd(aBuffer, "  {")
	aAdd(aBuffer, "    clearTimeout(xTimeout);") 
	aAdd(aBuffer, "    oTime.innerHTML = '" + STR0026 + "'") //###"Iniciando..."
	aAdd(aBuffer, "    " + acAction + ";")
	aAdd(aBuffer, "  }")                    
	aAdd(aBuffer, "  oTime.innerHTML = (nTime<10?'0':'') + nTime;")
	aAdd(aBuffer, "}")
	aAdd(aBuffer, "function doCancelAutoStart()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "    clearTimeout(xTimeout);") 
	aAdd(aBuffer, "    hideElement(getParentElement(getParentElement(oTime)));")
	aAdd(aBuffer, "}")
	
	aAdd(aBuffer, '</script>')

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Monta um auto-refresh com nova ação
--------------------------------------------------------------------------------------
*/
function buildAutoAction(acAction, aaParams, acMsg, alRelOpener, acOpenerWind, anTime, anWidth, anHeight)
	local aBuffer := {}

	default acMsg := STR0013 //###"Operação concluída com sucesso.<br>Favor aguardar...."
	default acOpenerWind := 'document'
	default alRelOpener := .t.
	default anTime := 2000
	
	aAdd(aBuffer, buildMessage(acMsg))
	aAdd(aBuffer, tagJS())

  if valType(anWidth) == "N" .and. valType(anHeight) == "N"
		aAdd(aBuffer, "setWindowSize("+iif(anWidth>1.1,dwStr(anWidth),"Math.floor(window.screen.availWidth * " +dwStr(anWidth)+"),") + ;
		                               iif(anHeight>1.1,dwStr(anHeight),"Math.floor(window.screen.availHeight * " +dwStr(anHeight)+"));"))
  endif
    
	if !(acAction == AC_NONE)
		aAdd(aBuffer, 'disableAllButtons();')
		aAdd(aBuffer, 'var xTimeout = setTimeout("goURL()", '+dwStr(anTime)+');')
		aAdd(aBuffer, 'function goURL()')
		aAdd(aBuffer, '{')
		aAdd(aBuffer, 'clearTimeout(xTimeout);') 
		if left(acAction, 3) == "js:"
			aAdd(aBuffer, "var cParams = "+makeAction("", aaParams)+";")
			aAdd(aBuffer, substr(acAction, 4)+';')
		elseif !empty(acAction) .and. !alRelOpener
			aAdd(aBuffer, "doLoadHere(" + makeAction(acAction, aaParams) + ","+ acOpenerWind + ".location);")
		else
			aAdd(aBuffer, 'doClose('+iif(alRelOpener,'true','false')+');')
		endif
		aAdd(aBuffer, '}')
		aAdd(aBuffer, '</script>')
	endif
		
return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Apresenta um "box" com um aviso
--------------------------------------------------------------------------------------
*/
function buildMessage(acMsg, alFullSize, alCloseButton)
	local aBuffer := {}
	
	default alFullSize := .f.
  default alCloseButton := .f.

	if alFullSize
		aAdd(aBuffer, '<div id="divWarningSrv" class="formWarningFull">')
	else
		aAdd(aBuffer, '<div id="divWarningSrv" class="formWarningSrv shadow2">')
	endif
	aAdd(aBuffer, acMsg)
	
	if alCloseButton
		aAdd(aBuffer, "<br><br>"+tagButton(BT_JAVA_SCRIPT, STR0109, "hideElement(getElement('divWarningSrv'))")) //"Continuar"
	endif
	
	aAdd(aBuffer, '</div>')

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Apresenta um "box" com um alerta
--------------------------------------------------------------------------------------
*/
function buildAlert(acMsg, aaParams)
	local aBuffer := {}
  local cMsg

  default aaParams := {}
  
  cMsg := dwFormat(acMsg, aaParams)
  
	aAdd(aBuffer, tagJS())
	
	aAdd(aBuffer, "var oModal = getModalForm();")
	aAdd(aBuffer, "doConfOk = function()")
	aAdd(aBuffer, "  {")
	aAdd(aBuffer, "	  doCloseModalForm();")
	aAdd(aBuffer, "  }")
	aAdd(aBuffer, "$('divModalFormTitle').innerHTML = '" + STR0101 + "';") //###"AVISO"
	aAdd(aBuffer, "$('divModalFormBody').innerHTML = '<p>"+cMsg+"<\/p>';")
	aAdd(aBuffer, "$('divModalFormMsg').innerHTML = '';")
	aAdd(aBuffer, "$('divModalFormButton').innerHTML = '<button onclick="+ASPAS_D+"javascript:doConfOk();"+ASPAS_D+">" + STR0102 + "<\/button><br/>';") //###"Prosseguir"
	aAdd(aBuffer, "oModal.style.display = 'block';")

	aAdd(aBuffer, "</script>")

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Apresenta um "box" com uma mensagem, que é fechado após um determinado periodo (segundos)
--------------------------------------------------------------------------------------
*/
function buildAutoMessage(acMsg, alFullSize, anTime)
	local aBuffer := {}
	
	default anTime := 2000
	
	aAdd(aBuffer, buildMessage(acMsg, alFullSize))
	
	aAdd(aBuffer, tagJS())
	aAdd(aBuffer, 'var xTimeout = setTimeout("closeMessage()", '+dwStr(anTime)+');')
	aAdd(aBuffer, 'function closeMessage() {')
	aAdd(aBuffer, '	clearTimeout(xTimeout);') 
	aAdd(aBuffer, '	hideElement(getElement("divWarningSrv"));')
	aAdd(aBuffer, '}')
	aAdd(aBuffer, '</script>')
	
return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Apresenta um "box" com um aviso e aguarda o usuário acionar "SIM" ou "NÃO", disparando
a função JS associada ao evento.
Nota: Antes de chamar esta função, no Adv/PL asp, deve-se definir a variavel JS REMOVE_ITEM.
      Esta variavel, conterá um complemento, p.e. o que esta sendo processado.
--------------------------------------------------------------------------------------
*/
function buildYesNo(acMsg, acJSYes, acJSNo)
	local aBuffer := {}

  default acJSNo := ""
	
	aAdd(aBuffer, "var oModal = getModalForm();")
	aAdd(aBuffer, "doYes = function()")
	aAdd(aBuffer, "  {")
	aAdd(aBuffer, "	  doCloseModalForm();")
	aAdd(aBuffer, "   if ("+acJSYes+")")
	aAdd(aBuffer, "   {")
	aAdd(aBuffer, "     "+acJSYes)
	aAdd(aBuffer, "   }")
	aAdd(aBuffer, "  }")
	aAdd(aBuffer, "doNo = function()")
	aAdd(aBuffer, "  {")
	aAdd(aBuffer, "	   doCloseModalForm();")
  if !empty(acJSNo)
		aAdd(aBuffer, "   if ("+acJSNo+")")
		aAdd(aBuffer, "   {")
		aAdd(aBuffer, "    ("+acJSNo+")")
		aAdd(aBuffer, "   }")
	endif
	aAdd(aBuffer, "  }")
	aAdd(aBuffer, "$('divModalFormTitle').innerHTML = '" + STR0115 + "';") //###"Solicitação de confirmação"
	aAdd(aBuffer, "$('divModalFormBody').innerHTML = '<p><br><br>"+acMsg+"<br><br><\/p>';")
	aAdd(aBuffer, "$('divModalFormMsg').innerHTML = REMOVE_ITEM;")
	aAdd(aBuffer, "$('divModalFormButton').innerHTML = '<input type="+ASPAS_D+"button"+ASPAS_D+" onclick="+ASPAS_D+"javascript:doYes();"+ASPAS_D+" value="+ASPAS_D + STR0116 /*"Sim"*/ +ASPAS_D+ ">';")
	aAdd(aBuffer, "$('divModalFormButton').innerHTML += '<input type="+ASPAS_D+"button"+ASPAS_D+" onclick="+ASPAS_D+"javascript:doNo();"+ASPAS_D+" value="+ASPAS_D + STR0117 /*"Não"*/ +ASPAS_D+ "><br/>';")
	aAdd(aBuffer, "oModal.style.display = 'block';")

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Monta um auto-refresh na janela principal e fecha a janela pop-up
--------------------------------------------------------------------------------------
*/
function buildAutoClose(alRefresh, acMsg, acOpenerWind, anTime, alFullSize)
	local aBuffer := {}
	
	default alRefresh := .t.	
	default acMsg := STR0013 //###"Operação concluída com sucesso.<br>Favor aguardar...."
	default anTime := 2000

	aAdd(aBuffer, buildMessage(acMsg, alFullSize))
	aAdd(aBuffer, tagJS())
	aAdd(aBuffer, 'disableAllButtons();')
	aAdd(aBuffer, 'var xTimeout = setTimeout("doClose('+iif(alRefresh, 'true','false')+')", '+dwStr(anTime)+');')
	aAdd(aBuffer, '</script>')         
	
return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Monta formulários
Args: acFormName, string, nome do form
      acTitle, string, titulo (se o valor for NIL, o form excluirá a barra de título)
      acAction, string, ação a ser executada (submit)
      acOper, 
      aaButtons
      aaParams
      alEdit
      acAlign
      abBody
      abSubmit
      alCheckList
      aaCols
      acStyle
      alBottom
      acDivID
      aaOperButtons
      acEncyType
      aaToolBar
      acMethod
      aaActionParams, string, contendo os parâmetros à serem acrescidos ao action do formulário
--------------------------------------------------------------------------------------
*/
function buildPortlet(anWidth, ;
			acFormName, acTitle, acAction, acOper, aaButtons, aaParams, alEdit, acAlign, abBody, abSubmit, alCheckList, aaCols, acStyle, ;
			alBottom, acDivID, aaOperButtons, acEncyType, aaToolBar, acMethod, aaActionParams, acBorder, alShowMessageArea)
	local aBuffer := {}
  local cWidth := iif(valType(anWidth) == "N", "width:" + buildMeasure(anWidth) + ";", "")
  local oWebApp := getWebApp();
  
  default acTitle := ""

// if dwIsDebug() .and. !empty(acTitle)
//    acTitle += "<div style='display:inline;background-color:yellow;height:10px'>&nbsp;&nbsp;<font color=gray>("+procname(2)+':'+procname(1)+")</font>&nbsp;&nbsp;</div>"
//  endif

	aAdd(aBuffer, "<!-- buildPortlet start aph/apl "+procname(2)+":"+procname(1)+" -->")
  if oWebApp:isPortal()
		aAdd(aBuffer, beginCont2(acTitle))
	  buildForm(acFormName, acTitle, acAction, acOper, aaButtons, aaParams, alEdit, acAlign, abBody, abSubmit, alCheckList, aaCols, acStyle, ;
	            alBottom, acDivID, aaOperButtons, acEncyType, aaToolBar, acMethod, aaActionParams, acBorder, alShowMessageArea, ;
	            aBuffer, .t.)
		aAdd(aBuffer, endCont2())
  else
		aAdd(aBuffer, "<div class='portlet' style='" + cWidth + "'>")
	  aAdd(aBuffer, "  <div style='width:100%'>")
		aAdd(aBuffer, "    <div class='boxTitulo'>")
		aAdd(aBuffer, "      <div class='content'>")
		aAdd(aBuffer, "        <div class='t'></div>")
		aAdd(aBuffer,            acTitle+buildFrmTitle())
		aAdd(aBuffer, "        </div>")
		aAdd(aBuffer, "      </div>")
		aAdd(aBuffer, "    </div>")
		aAdd(aBuffer, "    <div style='clear:both;'></div>")
		aAdd(aBuffer, "    <div class='fundoClaro'>")
		aAdd(aBuffer, "      <div style='padding: 0px 5px 0px 5px;'>")

		acBorder := ""
		acTitle := nil
		acAlign := ALG_CLIENT

	  buildForm(acFormName, acTitle, acAction, acOper, aaButtons, aaParams, alEdit, acAlign, abBody, abSubmit, alCheckList, aaCols, acStyle, ;
	            alBottom, acDivID, aaOperButtons, acEncyType, aaToolBar, acMethod, aaActionParams, acBorder, alShowMessageArea, ;
	            aBuffer, .t.)

		aAdd(aBuffer, "    </div>")
		aAdd(aBuffer, "  </div>")
		aAdd(aBuffer, "</div>")
	endif
	aAdd(aBuffer, '<!-- buildPortlet end -->')
	
	aEval(aBuffer, { |x| httpSend(x+CRLF) })

return ""

function beginCont2(acTitle, aaTopLinks, aaLeftLinks, acID, alSend)
	local aBuffer := {}
  local nInd, cRet := ""
    
  default acTitle := ""
  default aaTopLinks := {}
  default aaLeftLinks := {}
  default acID := ""
  default alSend := .t.
  
//  if dwIsDebug()
//    acTitle += "<span style='background-color:yellow;line-height:10px'>&nbsp;&nbsp;"+ ; 
//               "<font style='font-family: Arial; color: gray; font-size: 10px;'>(" +;
//               procname(2)+':'+procname(1)+")</font>&nbsp;&nbsp;</span>"
//  endif

	aAdd(aBuffer, "<!-- content2 start aph/apl "+procname(2)+":"+procname(1)+" -->")
	aAdd(aBuffer, "<div id='"+acID+"' class='conteudo02'>")
	aAdd(aBuffer, "  <div class='fundoClaro'>")
	aAdd(aBuffer, "    <div style='position:relative; width:950px; margin: 0px auto;'>")
	aAdd(aBuffer, "      <div style='position:relative; height:35px; padding-top:5px;'>")
	aAdd(aBuffer, "        <div style='position:relative; float:left;'>")
  aAdd(aBuffer, "          <h1>" + acTitle + "</h1>")
	aAdd(aBuffer, "        </div>")

	// links do titulo
	for nInd := len(aaTopLinks) to 1 step -1
		aAdd(aBuffer, "        <div style='position:relative; float:right; padding-top:19px; margin-right:10px;'>")
		aAdd(aBuffer, "          <a href=" + aaTopLinks[nInd, 2] + ">" + aaTopLinks[nInd, 1] + "</a>")
		aAdd(aBuffer, "        </div>")
  next
	  
	aAdd(aBuffer, "        <div style='clear:both'>")
	aAdd(aBuffer, "        </div>")
	aAdd(aBuffer, "      </div>")
	aAdd(aBuffer, "      <div class='hSeparator'></div>")
	aAdd(aBuffer, "      <div id='"+acID+"_content'>")
	aAdd(aBuffer, "        <div id='"+acID+"_left'style='position:relative; width:100%;'>")
	if valType(aaLeftLinks) == "A"
		aAdd(aBuffer, "          <div class='itens'>")

	  // links dos itens a esquerda
	  if len(aaLeftLinks) == 0
			aAdd(aBuffer, "          &nbsp;")
		else  
 		  aAdd(aBuffer, "        <div class='itensLista'>")
		  for nInd := 1 to len(aaLeftLinks)
				aAdd(aBuffer, "          <a href=" + aaLeftLinks[nInd, 2] + ">" + aaLeftLinks[nInd, 1] + "</a>")
			next
			aAdd(aBuffer, "        </div>")
		endif
	
		aAdd(aBuffer, "      </div>")
	endif
		
	// prepara area conteúdo
	aAdd(aBuffer, "      <div id='"+acID+"_right' class='conteudoTexto'>")

	//aEval(aBuffer, { |x| conout(x) }) //####debug
  if alSend
		aEval(aBuffer, { |x| httpSend(x+CRLF) })
	else
		cRet := dwConcatWSep(CRLF, aBuffer)
	endif
	
return cRet

function endCont2(alSend)
	local aBuffer := {}, cRet := ""
  local oWebApp := getWebApp()
                        
  default alSend := .t.

	if oWebApp:isError()
		aAdd(aBuffer, '         <div class="combordaMsgSrv">'+prepFormMsg(oWebApp:getMsgError())+'</div>')
	endif

	aAdd(aBuffer, "          </div>")
	aAdd(aBuffer, "        </div>")
	aAdd(aBuffer, "        <div style='position:relative; clear:both'>")
	aAdd(aBuffer, "      </div>")
	aAdd(aBuffer, "    </div>")
	aAdd(aBuffer, "  </div>")
	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, "<!-- content2 end aph/apl "+procname(2)+":"+procname(1)+" -->")
 
	//aEval(aBuffer, { |x| conout(x) }) //####debug
  if alSend
		aEval(aBuffer, { |x| httpSend(x+CRLF) })
	else
		cRet := dwConcatWSep(CRLF, aBuffer)
	endif
	
return cRet

/**
 * Esta função tem como finalidade montar todos os formulários do sistema.
 * 
 * @param acFormName (String) = Nome do formulário
 * @param acTitle (String)    = Título do formulário.
 * @param lPrinting (Boolean) = Informa se é impressão.
 * @author Helio Leal
 * @since 19/06/2013
 */
function buildForm(acFormName, acTitle, acAction, acOper, aaButtons, aaParams, alEdit, acAlign, abBody, abSubmit, alCheckList, aaCols, acStyle, ;
			alBottom, acDivID, aaOperButtons, acEncyType, aaToolBar, acMethod, aaActionParams, acBorder, alShowMessageArea , ;
			aaBuffer, alPortlet, lPrinting)
	local cSubmit := "", cAction, nInd, nInd2
	local aBuffer := {}, aParams := {}, aEvents, aEvent
	local lShowNextBtn := .T., lShowPrevBtn := .T., lShowCancBtn := .T., aAux := {}, aButtons := {}
	local cTabStyle := "", oAux
	local cTabStyle2 := "", lDefButtons := .t.
	local lWithContainer := .f.
	local oWebApp := getWebApp()
	local cClassContainer := iif(isNull(HttpSession->FolderMenu) .OR. HttpSession->FolderMenu, "container", "containerTree")
	local cColAlign := "align='center' "
	local lRightAlign := ascan(aaButtons, { |x| x[1] == BT_RIGHT_ALIGN }) > 0
  
  	if valType(aaBuffer) == "A"
		aBuffer := aaBuffer
	endif
	
	aAdd(aBuffer, '<!-- buildForm start aph/apl '+procname(2)+':'+procname(1)+' -->')

 	default acTitle := ""	
	default alEdit := !(dwVal(HttpGet->Oper) == OP_SUBMIT .or. dwVal(HttpGet->Oper) == OP_REC_DEL)
	default acAlign := ALG_CENTER
	default acOper := ""
	default alCheckList := .f.
	default aaButtons := {}
	default acStyle := ""
	default alBottom := .t.
	default acDivID	:= "divBuildForm"
	default aaOperButtons := {}
	default acEncyType := ""
	default aaToolBar := {}
	default acMethod := "post"
	default aaActionParams := {}
	default acBorder := "comborda"
	default alShowMessageArea := .t.
  	default alPortlet := .f.
  	Default lPrinting := .F. // Por Default é considerado que não é impressão.

	if acAlign == ALG_CLIENT
		cTabStyle2 := "width:100%;height:100%;margin:0px;padding:0px;"
		acStyle := cTabStyle2
	endif 

	if dwIsAjax() .and. ascan(aaButtons, { |x| x[1] == BT_NO_INS_DEFAULT }) > 0
		lDefButtons := .f.
	endif

	if empty(acEncyType)
		//---------------------------------------------------------------------------
		// Verifica o tipo de codificação que os dados serão enviados.
		//---------------------------------------------------------------------------
		if ValType( aaParams ) == "A" .And. AScan( aaParams, { |x| ValType( x ) == "A" .And. ValType( x[1] ) == "C" .And. x[1] == EDT_UPLOAD } ) > 0
			//---------------------------------------------------------------------------
			// Quando usuário irá enviar arquivos de seu computador para o servidor.
			//---------------------------------------------------------------------------
			acEncyType := "multipart/form-data"
		else
			//---------------------------------------------------------------------------
			// Tipo de codificação de uso geral.
			//---------------------------------------------------------------------------
			acEncyType := "application/x-www-form-urlencoded"
		endif
	endif
	
	aEval(aaActionParams, { |aElem| aAdd(aParams, aElem) })
	
	if left(acFormName, 1) == "#"
		cTabStyle2 := acStyle
		acStyle := ""
		acFormName := substr(acFormName, 2)
	endif
	if right(acFormName, 1) == "#"
		lWithContainer := .t.
		acFormName := substr(acFormName, 1, len(acFormName)-1)
	endif
	
	cSubmit := ' onsubmit="return('+acFormName+'Submit(this))"'
	
	if !empty(acStyle)
		acStyle := ' style="'+acStyle+'"'
	endif
	
	if empty(acOper)
		if left(acAction, 1) == "@"
			cAction := substr(acAction,2)
		else
			cAction := makeAction(acAction, aParams)
		endif
	else
		aAdd(aParams, { "oper", acOper })
		aAdd(aParams, { "suboper", HttpSession->subOper })
		if acOper == OP_SUBMIT
			if lDefButtons			
			if !empty(aaButtons) .and. len(aaButtons) > 0
				for nInd := 1 to len(aaButtons)
					if aaButtons[nInd][1] == BT_SUBMIT
						lShowNextBtn := .F.
						aAdd(aAux, aaButtons[nInd])
						aaButtons[nInd] := NIL
					elseif aaButtons[nInd][1] == BT_PREVIOUS
						lShowPrevBtn := .F.
						aAdd(aAux, aaButtons[nInd])
						aaButtons[nInd] := NIL
					elseif aaButtons[nInd][1] == BT_CANCEL
						lShowCancBtn := .F.
						aAdd(aAux, aaButtons[nInd])
						aaButtons[nInd] := NIL
					endif
				next
			endif
			
			if lShowNextBtn
				makeButton(aButtons, BT_SUBMIT)
			else
				for nInd := 1 to len(aAux)
					if aAux[nInd][1] == BT_SUBMIT
						aAdd(aButtons, aAux[nInd])
						exit
					endif
				next
			endif
			
			if !lShowPrevBtn
				for nInd := 1 to len(aAux)
					if aAux[nInd][1] == BT_PREVIOUS
						aAdd(aButtons, aAux[nInd])
						exit
					endif
				next
			endif
			
			if lShowCancBtn
				makeButton(aButtons, BT_CANCEL)
			else
				for nInd := 1 to len(aAux)
					if aAux[nInd][1] == BT_CANCEL
						aAdd(aButtons, aAux[nInd])
						exit
					endif
				next
			endif
			
			if !(dwVal(HttpSession->subOper) == OP_REC_DEL)
				makeButton(aaButtons, BT_RESET)
			endif
			endif
			
			for nInd := 1 to len(aaButtons)
				if !empty(aaButtons[nInd])
					if !(aaButtons[nInd, 1] == BT_NO_INS_DEFAULT)
						aAdd(aButtons, aaButtons[nInd])
					endif
				endif
			next
			aaButtons := aButtons
		elseif acOper == OP_DISPLAY
			makeButton(aaButtons, BT_CLOSE)
		elseif acOper == OP_STEP
			if !empty(aaButtons) .and. len(aaButtons) > 0
				for nInd := 1 to len(aaButtons)
					if aaButtons[nInd][1] == BT_NEXT
						lShowNextBtn := .F.
					elseif  aaButtons[nInd][1] == BT_PREVIOUS
						lShowPrevBtn := .F.
					elseif aaButtons[nInd][1] == BT_CANCEL
						lShowCancBtn := .F.
					endif
					
					if !lShowNextBtn .or. !lShowPrevBtn .or. !lShowCancBtn
						aAdd(aAux, aaButtons[nInd])
						aaButtons[nInd] := NIL
					endif
				next
			endif
			
			if dwIsAjax()                   
				httpGet->_step := dwVal(httpGet->_step)               
				nLastStep := oWebApp:getLastStep(acFormName) 
				lShowPrevBtn := HttpGet->_step > 1
				lShowNextBtn := HttpGet->_step < nLastStep .and. nLastStep > 1
      endif
      
			if lShowNextBtn
				makeButton(aButtons, BT_NEXT)
			else
				for nInd := 1 to len(aAux)
					if aAux[nInd][1] == BT_NEXT
						aAdd(aButtons, aAux[nInd])
						exit
					endif
				next
			endif
			
			if lShowPrevBtn
				makeButton(aButtons, BT_PREVIOUS)
			else
				for nInd := 1 to len(aAux)
					if aAux[nInd][1] == BT_PREVIOUS
						aAdd(aButtons, aAux[nInd])
						exit
					endif
				next
			endif
			
			if lShowCancBtn
				makeButton(aButtons, BT_CANCEL)
			else
				for nInd := 1 to len(aAux)
					if aAux[nInd][1] == BT_CANCEL
						aAdd(aButtons, aAux[nInd])
						exit
					endif
				next
			endif
			
			for nInd := 1 to len(aaButtons)
				if !empty(aaButtons[nInd])
					aAdd(aButtons, aaButtons[nInd])
				endif
			next
			aaButtons := aButtons
			
			if dwIsAjax()
				aAdd(aParams, { "_step", httpGet->_step })
			else
				aAdd(aParams, { "dw_step", HttpSession->dw_step })
			endif
		endif
		cAction := makeAction(acAction, aParams)
	endif
	
 	if dwIsAjax() .and. cAction == '#'     //Caso não utilize o div, a tela não aparece no IE
		aAdd(aBuffer, '<div name="'+acFormName+'" id="'+acFormName+'">')
	else
		aAdd(aBuffer, '<form enctype="' + acEncyType + '" method="'+acMethod+'" action='+cAction+' name="'+acFormName+'" id="'+acFormName+'"'+cSubmit+acStyle+'>')
	endif
	
	if valType(aaParams) == "O" .or. (len(aaParams) > 0 .and. valType(aaParams[1]) == "O")
		if valType(aaParams) == "O"
			oAux := aaParams
			aAux := {}
		else
			oAux := aaParams[1]
			aAux := aaParams[2]
		endif
		cTabStyle := ""
		if !empty(oAux:width())
			cTabStyle += "width:" + buildMeasure(oAux:width()) + ";"
		endif
		if !empty(oAux:height())
			cTabStyle += "height:" + buildMeasure(oAux:height()) + ";"
		endif
		if !(valtype(aAux) == "U")
			If lPrinting
				buildBodyFields(aBuffer, aAux, alEdit, alCheckList, , EDT_HIDDEN, , .T.) // somente campos hidden
			Else
				buildBodyFields(aBuffer, aAux, alEdit, alCheckList, , EDT_HIDDEN) // somente campos hidden
			EndIf
		endif
	else
		makeHotKeys(aaParams)
		if valType(abBody) == "B"
			eval(abBody, aBuffer, aaParams, alEdit, alCheckList, ,.t.) // somente campos hidden
		else
			If lPrinting 
				buildBodyFields(aBuffer, aaParams, alEdit, alCheckList, , EDT_HIDDEN, , .T.) // somente campos hidden
			Else
				buildBodyFields(aBuffer, aaParams, alEdit, alCheckList, , EDT_HIDDEN) // somente campos hidden
			EndIf
		endif
	endif
	
	cTabStyle =+ cTabStyle2
	If !empty(cTabStyle)
		cTabStyle := ' style="'+cTabStyle+'" '
	EndIf

	// Se for impressão, as informações ocupam 100% da tela.	
	If lPrinting
		cClassContainer := ''			
		cTabStyle += "margin-top: 5px;"
		cTabStyle += "width:100%;"
	EndIf
	
	aAdd(aBuffer, '<table class="' + cClassContainer + '" summary="" '+cTabStyle+'>')
	aAdd(aBuffer, '<col width="1px">')
	aAdd(aBuffer, '<col>')
	aAdd(aBuffer, '<col width="1px">')
	aAdd(aBuffer, '<tbody>')
	
	
	if !isNull(acTitle) .and. !empty(acTitle)
		aAdd(aBuffer, '<tr>')
		aAdd(aBuffer, '  <td class="' + acBorder + '_tit_esq"></td>')
		if alPortlet    
		  if left(acTitle, 1) == "#"
		    if left(acTitle, 2) == "##"
				  aAdd(aBuffer, '  <td><h2 STYLE="margin-bottom:0px;margin-top:0px">'+substr(acTitle, 3)+buildFrmTitle()+'</h2>')
				else
				  aAdd(aBuffer, '  <td><h2 STYLE="margin-bottom:5px;margin-top:10px">'+substr(acTitle, 2)+buildFrmTitle()+'</h2>')
				endif
		  	aAdd(aBuffer, "      <div class='hSeparator'></div></td>")
		  else
				aAdd(aBuffer, '  <td><h2 STYLE="margin-bottom:5px;margin-top:10px">'+acTitle+buildFrmTitle()+'</h2></td>')
			endif
		else
			aAdd(aBuffer, '  <td class="titulo">'+acTitle+buildFrmTitle()+'</td>')
		endif
		aAdd(aBuffer, '  <td class="' + acBorder + '_tit_dir"></td>')
		aAdd(aBuffer, '</tr>')
	endif
	
	aAdd(aBuffer, '<tr>')
	aAdd(aBuffer, '	<td class="' + acBorder + '_esq"></td>')
	aAdd(aBuffer, '	<td valign="top">')
	// miolo (area de montagem dos "campos")
	
	if lWithContainer
		aAdd(aBuffer, "<div class='FormContainer'>")
	endif
	
	if valType(aaParams) == "O" .or. (len(aaParams) > 0 .and. valType(aaParams[1]) == "O")
		if valType(aaParams) == "O"
			oAux := aaParams
		else
			oAux := aaParams[1]
		endif
		aAdd(aBuffer, '<!-- buildForm objectBody ('+oAux:classname()+') start -->')
		oAux:Buffer(aBuffer, @alBottom)
		aAdd(aBuffer, '<!-- buildForm objectBody ('+oAux:classname()+') end -->')
	elseif valType(abBody) == "B"
		eval(abBody, aBuffer, aaParams, alEdit, alCheckList)
	else
		If lPrinting		
			buildBodyFields(aBuffer, aaParams, alEdit, alCheckList,,, !(acBorder == "form") .and. !empty(acBorder), .T.)
		Else
			buildBodyFields(aBuffer, aaParams, alEdit, alCheckList,,, !(acBorder == "form") .and. !empty(acBorder))
		EndIf
	endif
	
	if lWithContainer
		aAdd(aBuffer, "</div>")
	endif
	
	aAdd(aBuffer, '	</td>')
	aAdd(aBuffer, '	<td class="' + acBorder + '_dir"></td>')
	aAdd(aBuffer, '</tr>')
	
	// area de mensagens
	if alBottom
		if alShowMessageArea
			aAdd(aBuffer, '<tr>')
		else
			aAdd(aBuffer, '<tr style="'+displayNone()+'">')
		endif
		aAdd(aBuffer, '  <td class="' + acBorder + '_esq"></td>')
		aAdd(aBuffer, '  <td class="' + acBorder + '_meio form_row_sep">') //nowrap
    if !(oWebApp:className() == "TTOTVSMAIN")		
  		aAdd(aBuffer, '    <div id="formMsg" class="formMsg"></div>')
#ifdef VER_P11  		
	  	aAdd(aBuffer, '    <div id="formMsgHint" class="formMsgHint P11"></div>')
#else	  	
	  	aAdd(aBuffer, '    <div id="formMsgHint" class="formMsgHint"></div>')
#endif	  	
	  endif
		if oWebApp:isError()
			aAdd(aBuffer, '  <div class="' + acBorder + 'MsgSrv">'+prepFormMsg(oWebApp:getMsgError())+'</div>')
		endif
		if len(aaOperButtons) > 0
			cLine := '       <div id="formBtn">'
			for nInd := 1 to len(aaOperButtons)
				cLine += aaOperButtons[nInd][2]
			next
			cLine += '       </div>'
			aAdd(aBuffer, cLine)
		endif
		aAdd(aBuffer, '  </td>')
		aAdd(aBuffer, '  <td class="' + acBorder + '_dir"></td>')
		aAdd(aBuffer, '</tr>')
		
		// area de legendas
		if valType(aaParams) == "A" .and. len(aaParams) > 0 .and. !(valType(aaParams[1]) == "O") .and. ;
			ascan(aaParams, { |x| x[FFLD_EDTTYPE] == EDT_LEGEND } ) > 0
			aAdd(aBuffer, '<tr>')
			aAdd(aBuffer, '  <td class="' + acBorder + '_esq"></td>')
			aAdd(aBuffer, '  <td class="' + acBorder + '_meio">')
			buildBodyFields(aBuffer, aaParams, alEdit, alCheckList, ,EDT_LEGEND)
			aAdd(aBuffer, '  </td>')
			aAdd(aBuffer, '  <td class="' + acBorder + '_dir"></td>')
			aAdd(aBuffer, '</tr>')
		endif
		
		// area de mensagens
		if len(aaButtons) <> 0
			aAdd(aBuffer, "<tr><td class='" + acBorder + "_esq'>")
			aAdd(aBuffer, "</td>")
			aAdd(aBuffer, '<td class="' + acBorder + '_meio">')
			aAdd(aBuffer, "<span id='msgButtonContainer' class='warning'>")
			aAdd(aBuffer, "</span>")
  	  if lRightAlign
				aAdd(aBuffer, '<div style="text-align:right;brackground-color:gray" class="buttonContainer">')
			else
				aAdd(aBuffer, '<div class="buttonContainer">')
			endif
			buildButton(aBuffer, aaButtons)
			aAdd(aBuffer, '</div>')
			aAdd(aBuffer, '</td>')
			aAdd(aBuffer, '<td class="' + acBorder + '_dir"></td>')
			aAdd(aBuffer, '</tr>')
		endif
	endif
	
	if !(acBorder == "form")
		if !empty(acBorder)
			aAdd(aBuffer, '<tr>')
			aAdd(aBuffer, '  <td class="comborda_inf_esq" valign="top"></td>')
			aAdd(aBuffer, '  <td class="comborda_inf"></td>')
			aAdd(aBuffer, '  <td class="comborda_inf_dir" valign="top"></td>')
			aAdd(aBuffer, '</tr>')
		endif
	endif
	
	aAdd(aBuffer, '</tbody>')
	aAdd(aBuffer, '</table>')

  if dwIsAjax() .and. cAction == '#' //Caso não utilize o div, a tela não aparece no IE
		aAdd(aBuffer, '</div')
	else
		aAdd(aBuffer, '</form>')
  endif
	
	if (valtype(aaParams) == "A" .and. len(aaParams) > 0) .and. !(valtype(aaParams[1]) == "O")
		aAdd(aBuffer, tagJS())
    if DWIsAjax()
			aAdd(aBuffer, acFormName+"Submit = function(oSender)")
		else
			aAdd(aBuffer, "function "+acFormName+"Submit(oSender)")
		endif
		aAdd(aBuffer, "{")
		aAdd(aBuffer, " var lRet = true;")
		
		if isNull(HttpSession->subOper, 0) <> OP_REC_DEL .and. alEdit
			buildValidFields(aBuffer, aaParams, ,iif(acFormName == "frmUsers", .T., .F.))
			
			if valType(abSubmit) == "B"
				aAdd(aBuffer, "if (lRet) {")
				eval(abSubmit, aBuffer, aaParams, alEdit)
				aAdd(aBuffer, "}")
			endif
			
			aAdd(aBuffer, "if (lRet)")
			aAdd(aBuffer, "  try { lRet = lRet && " + acFormName + "_valid(oSender); } catch ( err  ) { lRet = true };")
		endif
		
		if !(valType(aaParams[1]) == "O")
			if ascan(aaParams, { |x| x[FFLD_EDTTYPE] == EDT_DUALLIST }) <> 0
				aAdd(aBuffer, "  if (lRet)")
				aAdd(aBuffer, "  {")
				for nInd := 1 to len(aaParams)
					if aaParams[nInd, FFLD_EDTTYPE] == EDT_DUALLIST
						aAdd(aBuffer, '    prepDualList(oSender.'+aaParams[nInd, FFLD_NAME][1]+');')
						aAdd(aBuffer, '    prepDualList(oSender.'+aaParams[nInd, FFLD_NAME][2]+');')
					endif
				next
				aAdd(aBuffer, "  }")
				
				aAdd(aBuffer, "  return lRet;")
				aAdd(aBuffer, "}")
    		if DWIsAjax()
					aAdd(aBuffer, "moveDualList = function(fbox, tbox, all)")
				else
				aAdd(aBuffer, "function moveDualList(fbox, tbox, all)")
				endif
				aAdd(aBuffer, "{")
				aAdd(aBuffer, "  var aSaveOpt = new Array();")
				aAdd(aBuffer, "  for (var nInd = 0; nInd < fbox.length; nInd++)")
				aAdd(aBuffer, "  {")
				aAdd(aBuffer, "    if ((fbox.options[nInd].selected) || (all))")
				aAdd(aBuffer, "      tbox.options[tbox.length] = new Option(fbox.options[nInd].text, fbox.options[nInd].value);")
				aAdd(aBuffer, "    else")
				aAdd(aBuffer, "      aSaveOpt[aSaveOpt.length] = new Option(fbox.options[nInd].text, fbox.options[nInd].value);")
				aAdd(aBuffer, "	 }")
				aAdd(aBuffer, "  fbox.length = 0;")
				aAdd(aBuffer, "  for (var nInd = 0; nInd < aSaveOpt.length; nInd++)")
				aAdd(aBuffer, "    fbox.options[nInd] = aSaveOpt[nInd];")
				aAdd(aBuffer, "}")
    		if DWIsAjax()
					aAdd(aBuffer, "prepDualList = function(oSender)")
				else
				aAdd(aBuffer, "function prepDualList(oSender)")
				endif
				aAdd(aBuffer, "{")
				aAdd(aBuffer, "  var aOptions = oSender.options;")
				aAdd(aBuffer, "  for (var nInd = 0; nInd < aOptions.length; nInd++)")
				aAdd(aBuffer, "    aOptions[nInd].selected = true;")
				aAdd(aBuffer, "  return true;")
				aAdd(aBuffer, "}")
    		if DWIsAjax()
					aAdd(aBuffer, "function ordemDualList(tbox, direction)")
				else
					aAdd(aBuffer, "ordemDualList = function(tbox, direction)")
				endif
				aAdd(aBuffer, "{")
				aAdd(aBuffer, "  if (!direction)")
				aAdd(aBuffer, "  {")
				aAdd(aBuffer, "    for (var nInd = 1; nInd < tbox.length; nInd++)")
				aAdd(aBuffer, "    {")
				aAdd(aBuffer, "      if ((tbox.options[nInd].selected))")
				aAdd(aBuffer, "      {")
				aAdd(aBuffer, "        var oAux = tbox.options[nInd-1];")
				aAdd(aBuffer, "        tbox.options[nInd-1] = new Option(tbox.options[nInd].text, tbox.options[nInd].value);")
				aAdd(aBuffer, "        tbox.options[nInd] = new Option(oAux.text, oAux.value);")
				aAdd(aBuffer, "        tbox.options[nInd-1].selected = true;")
				aAdd(aBuffer, "        break;")
				aAdd(aBuffer, "      }")
				aAdd(aBuffer, "    }")
				aAdd(aBuffer, "  } else")
				aAdd(aBuffer, "  {")
				aAdd(aBuffer, "    for (var nInd = 0; nInd < tbox.length - 1; nInd++)")
				aAdd(aBuffer, "    {")
				aAdd(aBuffer, "      if ((tbox.options[nInd].selected))")
				aAdd(aBuffer, "      {")
				aAdd(aBuffer, "        var oAux = tbox.options[nInd+1];")
				aAdd(aBuffer, "        tbox.options[nInd+1] = new Option(tbox.options[nInd].text, tbox.options[nInd].value);")
				aAdd(aBuffer, "        tbox.options[nInd] = new Option(oAux.text, oAux.value);")
				aAdd(aBuffer, "        tbox.options[nInd+1].selected = true;")
				aAdd(aBuffer, "        break;")
				aAdd(aBuffer, "      }")
				aAdd(aBuffer, "    }")
				aAdd(aBuffer, "  }")
				aAdd(aBuffer, "}")
			else
				aAdd(aBuffer, "  return lRet;")
				aAdd(aBuffer, "}")
			endif
			
			for nInd := 1 to len(aaParams)
				if len(aaParams[nInd]) <> BTN_SIZE_ARRAY .and. len(aaParams[nInd]) >= FFLD_EVENTS
					aEvents := aaParams[nInd, FFLD_EVENTS]
					for nInd2 := 1 to len(aEvents)
						aEvent := aEvents[nInd2]
						if len(aEvent) > 0 .and. aEvent[FFLD_FIREONINIT]
							aAdd(aBuffer, strTran(aEvent[FFLD_EVENTJS], "this", 'getElement("'+aaParams[nInd, FFLD_NAME]+'")')+";")
						endif
					next
				endif
			next
			
			aAdd(aBuffer, "</script>")
		endif
	endif
	
	aAdd(aBuffer, '<!-- buildForm end -->')
	
  if valType(aaBuffer) == "U"
		//aEval(aBuffer, { |x| conout(x) }) //####debug
		aEval(aBuffer, { |x| httpSend(x+CRLF) })
	endif
	 
return ""


/*
--------------------------------------------------------------------------------------
Monta formulários de checkList
Args:
--------------------------------------------------------------------------------------
*/
function buildCheckList(acFormName, acTitle, acAction, acOper, aaButtons, aaParams, acAlign, abBody, abSubmit)
	default abSubmit := {||}
	
return buildForm(acFormName+"#", acTitle, acAction, acOper, aaButtons, aaParams, .t., acAlign, abBody, abSubmit, .t.)

/*
--------------------------------------------------------------------------------------
Monta ações
Args:
--------------------------------------------------------------------------------------
*/
function ajaxAction(acTarget, acAction, aaParams)
	local cRet := ""   
  
	if acAction == AC_NONE
		cRet := "#"
	else                                                  
		cRet := "javascript:" + ajaxGet(acTarget, acAction, aaParams )
		cRet := ASPAS_D + cRet + ASPAS_D
	endif
		
return cRet
                
static function ajaxBaseGet(acAjaxFunc, acTarget, acAction,  aaParams)
  local cTarget := acTarget
  
  default aaParams := {}
  
  if left(cTarget, 3) == "js:"
  	cTarget := substr(cTarget, 4)
	else  	
  	cTarget := "'" + cTarget + "'"
 endif

return acAjaxFunc + "("+cTarget+",''," + params2Ajax({ acAction, aaParams }) + ");"

function ajaxGetConf(acTarget, acAction,  aaParams)
  local cRet := ajaxBaseGet("doGetWithConfirm@", acTarget, acAction,  aaParams)

  cRet := strTran(cRet, "doGetWithConfirm@(", "doGetWithConfirm('" + buildConfCode() + "',")

return cRet

function ajaxGet(acTarget, acAction,  aaParams)

return ajaxBaseGet("doGet", acTarget, acAction,  aaParams)

function ajaxGetApped(acTarget, acAction,  aaParams)

return ajaxBaseGet("doGetAndAppend", acTarget, acAction,  aaParams)

function ajaxPost(acFormID, acTarget, acAction,  aaParams)
  local cFormID := acFormID
  local cTarget := acTarget
  
  default aaParams := {}
  
  if left(cFormID, 3) == "js:"
  	cFormID := substr(cFormID, 4)
	else  	
  	cFormID := "'" + cFormID + "'"
 endif

  if left(cTarget, 3) == "js:"
  	cTarget := substr(cTarget, 4)
	else  	
  	cTarget := "'" + cTarget + "'"
 endif

return "doPostData("+cFormID+","+cTarget+",''," + params2Ajax({ acAction, aaParams }) + ");"

function makeAction(acAction, aaParams, alAspas)
	local aAux := {}, cParams
	local cRet := "", aParams := iif(valType(aaParams) == "A", aClone(aaParams), {})
	
	default alAspas 		:= .T.
	
	//Tratamento genérico para a prevenção de caching.
	aAdd(aParams, { "noCache", randByTime() + dwStr(randomize(1,50)) })

#ifdef VER_P11	
	if isNull(httpGet->_ow, CHKBOX_OFF) == CHKBOX_ON
		aAdd(aParams, { "_ow", CHKBOX_ON })
	endif
#endif
	
	prepareParams(aParams)
	
	if acAction == AC_NONE
		cRet := "#"
	else
		aEval(aParams, { |x| aAdd(aAux, x[1]+"="+dwStr(x[2]))})
		cParams := dwConcatWSep("&", aAux)
		if !empty(cParams)
			cParams := "&" + cParams
		endif
		
		if valType(acAction) == "C" .and. left(acAction,7) == "mailto:"
			cRet := acAction + cParams
		elseif valType(acAction) == "C" .and. left(acAction,3) == "js:"
			cRet := "javascript:" + substr(acAction,4)
		else
			cRet := "?action=" + acAction + cParams
			
			If isInternetExplorer()
				cRet := strTran(cRet, "&", "&amp;")
			EndIf
		endif
		
		if alAspas
			cRet := '"' + cRet + '"'
		endif
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Monta o corpo de formularios
Args:
--------------------------------------------------------------------------------------
*/
function buildBodyFields(aaBuffer, aaFields, alEdit, alOnlyOneCol, acCssName, acTypeOnly, alZebra, lPrinting)
	local nInd, aField, lCustomField, lPar := .F.
	local aHiddens := {}, aTabbedChilds := {}
	local cLine := "", cLineAux := "", cRemarks, lCloseTable := .f., lOpenTable := .t.
	local aOneCol := { EDT_H1, EDT_H2, EDT_TITLE, EDT_SUBTITLE, EDT_TEXT, EDT_ATTENTION, ;
										 EDT_BLANK, EDT_WARNING, EDT_DUALLIST, EDT_TABBED_PANE, EDT_TABBED_CHILD, ;
										 EDT_TABBED_JSPANE, EDT_CUSTOM, EDT_CUSTOM_CONT, EDT_PROGRESSBAR, EDT_TABBED_GROUP }
	local aBuffer := {}, lBuffer := .f., lFirstLine := .t., lLastLine := .f.
	local lPutTD := .t., lCloseTD := .f.
	local aaBufferAux := {}, nLenCaption := 0, cAux
	local lLastField := .f., nLenFields
	Local cEstiloBorda := ""
	
	Default lPrinting := .F.	 
	default acCssName := "form"
	default acTypeOnly := ""
	default alZebra := .t.
#ifdef VER_P11
  alOnlyOneCol := .t.
#else
	default alOnlyOneCol := .t.
#endif

	alZebra := alZebra .and. !alOnlyOneCol
	
	if !(valType(aaBuffer) == "A")
		aaBuffer := aBuffer
		lBuffer := .f.
	endif
	cRemarks := "<!-- buildBodyFields @ CSS " + acCssName + iif(empty(acTypeOnly), " - only " + acTypeOnly,"") + " fields -->"
	
	aAdd(aaBuffer, strTran(cRemarks, "@", "begin"))
	
  nLenFields := len(aaFields)	
	for nInd := 1 to nLenFields
	  lLastField := nInd == nLenFields
		aField := aClone(aaFields[nInd])
		cLine := ""
		
		if !empty(acTypeOnly)
			if !(aField[FFLD_EDTTYPE] == acTypeOnly)
				if aField[FFLD_EDTTYPE] == EDT_TABBED_PANE
					buildBodyFields(aaBuffer, aField[FFLD_VALUE], alEdit, alOnlyOneCol, acCssName, acTypeOnly, alZebra)	
				elseif aField[FFLD_EDTTYPE] == EDT_TABBED_CHILD
					buildBodyFields(aaBuffer, aField[11], alEdit, alOnlyOneCol, acCssName, acTypeOnly, alZebra)	
				endif
				loop
			elseif aField[FFLD_EDTTYPE] == EDT_LEGEND
				aAdd(aaBuffer, buildComponent(aField, alEdit, .t.))
			endif
		elseif aField[FFLD_EDTTYPE] == EDT_HIDDEN
			loop
		endif
		
		if (acTypeOnly == EDT_HIDDEN)
			if (aField[FFLD_EDTTYPE] == EDT_HIDDEN)
				// verifica se ocorreu algum erro de validação e se tem algum valor no GET
				if !empty(HttpGet->gencode) .AND. valType(aField[FFLD_NAME]) == "C" .AND. !empty(&("HttpGet->" + aField[FFLD_NAME]))
					aField[FFLD_VALUE] := URLDecode(DwStr(&("HttpGet->" + aField[FFLD_NAME])))
				endif
				aAdd(aaBuffer, '<input type="hidden" name="'+aField[FFLD_NAME]+'" id="'+aField[FFLD_NAME]+'" value='+dwStr(aField[FFLD_VALUE],.t.)+'>')
			endif
		elseif (aField[FFLD_EDTTYPE] == EDT_LEGEND)
			loop
		elseif aField[FFLD_EDTTYPE] == EDT_TABBED_CHILD
			loop
		else
			if lOpenTable
				if lCloseTable
			  	if lLastLine
						lLastLine := .f.
					endif
					aAdd(aaBufferAux, '  </table>')
					lCloseTable := .f.
				endif				
				
				// Se for impressão adiciona uma borda nas redondezas.
				If lPrinting
					cEstiloBorda := 'style = "border: 1px solid black;"'					
				EndIf				
				
				aAdd(aaBuffer, '  <table class="buildForm" summary="" '+ cEstiloBorda + '>')
				lOpenTable := .f.
				lCloseTable := .t.
#ifdef VER_P11
#else
				alOnlyOneCol := .f.
#endif
				lFirstLine := .t.
				lPutTD := .t.
				lCloseTD := .f.
			endif
			
			// constroi a tag html do componente
			if lFirstLine
				lFirstLine := .f.
				lLastLine := .t.
			endif
			if lPutTD
				if alZebra
					aAdd(aaBufferAux, "<tr class='zebra"+iif(lPar, "On","Off")+"'>")
					lPar := !lPar
				else
					aAdd(aaBufferAux, "<tr>")
				endif
				cLine += "<td"
				if alOnlyOneCol .or. aScan(aOneCol, { |x| x==aField[FFLD_EDTTYPE]}) != 0 .or. ;
				   left(aField[FFLD_CAPTION],1) == "|"
				   if lLastField
							cLine += " valign='bottom' class='buildFormOneCol' colspan='2'"
      		 else
    					cLine += " class='buildFormOneCol' colspan='2'"
				   endif
				else
					cLine += " class='buildFormLabel'"
				endif

				// verifica se o campo em questão é um campo válido (exclui-se os campos de texto, título, etc.)
				if !(	aField[FFLD_EDTTYPE] == EDT_LEGEND .OR. ;
						aField[FFLD_EDTTYPE] == EDT_H1 .OR. ;
						aField[FFLD_EDTTYPE] == EDT_H2 .OR. ;
						aField[FFLD_EDTTYPE] == EDT_TITLE .OR. ;
						aField[FFLD_EDTTYPE] == EDT_SUBTITLE .OR. ;
						aField[FFLD_EDTTYPE] == EDT_TEXT .OR. ;
						aField[FFLD_EDTTYPE] == EDT_ATTENTION .OR. ;
						aField[FFLD_EDTTYPE] == EDT_WARNING .OR. ;
						aField[FFLD_EDTTYPE] == EDT_BLANK .OR. ;
						aField[FFLD_EDTTYPE] == EDT_CHECKBOX .OR. ;
						aField[FFLD_EDTTYPE] == EDT_CHECKBOX2 .OR. ;
						aField[FFLD_EDTTYPE] == EDT_CUSTOM)
					cLine += "@width"
				endif
			endif
			
			if (aField[FFLD_EDTTYPE] == EDT_TABBED_PANE)
				cLine += ">"
				aAdd(aaBufferAux, cLine)
				buildTabbedPane(aaBufferAux, aField)
				aAdd(aaBufferAux, "<td>")
			else
				if lPutTD
					cLine += ">"
				endif                     
				
				cLine += buildComponent(aField, alEdit, alOnlyOneCol)
				
				// verifica se o campo em questão é um campo válido (exclui-se os campos de texto, título, etc.)
				if !(	aField[FFLD_EDTTYPE] == EDT_LEGEND .OR. ;
						aField[FFLD_EDTTYPE] == EDT_H1 .OR. ;
						aField[FFLD_EDTTYPE] == EDT_H2 .OR. ;
						aField[FFLD_EDTTYPE] == EDT_TITLE .OR. ;
						aField[FFLD_EDTTYPE] == EDT_SUBTITLE .OR. ;
						aField[FFLD_EDTTYPE] == EDT_TEXT .OR. ;
						aField[FFLD_EDTTYPE] == EDT_ATTENTION .OR. ;
						aField[FFLD_EDTTYPE] == EDT_WARNING .OR. ;
						aField[FFLD_EDTTYPE] == EDT_BLANK .OR. ;
						aField[FFLD_EDTTYPE] == EDT_CHECKBOX .OR. ;
						aField[FFLD_EDTTYPE] == EDT_CHECKBOX2 .OR. ;
						aField[FFLD_EDTTYPE] == EDT_CUSTOM)
					// realiza o cálculo do tamanho do label dos campos
					if !empty(aField[FFLD_CAPTION])
						cAux := DwStr(aField[FFLD_CAPTION])
						cAux := strTran(cAux, "<u>", "")
						cAux := strTran(cAux, "</u>", "")
						
						if len(aField[FFLD_CAPTION]) > nLenCaption
							nLenCaption := len(aField[FFLD_CAPTION])
						endif
					endif
				endif
				
				if aField[FFLD_EDTTYPE] == EDT_CUSTOM_CONT
					lPutTD := .f.
					lCloseTD := .t.
				endif									
				if lPutTD
					cLine += "</td>"
				endif
				aAdd(aaBufferAux, cLine)
			endif

			if lPutTD
				aAdd(aaBufferAux, '</tr>')
			endif
		endif
	next

	if !(acTypeOnly == EDT_HIDDEN	)
		// tamanho dos campos vezes 7 (7 é o número aproximado de pixels necessários para a apresentação de cada carácter)
		nLenCaption *= 7
#ifdef VER_P11		
#else
		aAdd(aaBuffer, "    <tr class='meiaLinha'><td class='buildFormLabel'" + iif(nLenCaption > 0, " style='width:" + DwStr(nLenCaption) + "px;'", "") + "></td><td class='buildFormBody'></td></tr>")
#endif		
		aEval(aaBufferAux, {|aElem| aAdd(aaBuffer, strTran(aElem, "@width", ' style="width:' + buildMeasure( iif(nLenCaption == 0, 1, nLenCaption) ) + '"'))})
	
		if lCloseTD
				aAdd(aaBuffer, "</td>")
				aAdd(aaBuffer, "</tr>")
		endif
		if lLastLine
			//	aAdd(aaBuffer, "    <tr class='meiaLinha'><td class='buildFormLabel'></td><td class='buildFormBody'></td></tr>")
			lLastLine := .f.
		endif
		if lCloseTable
			aAdd(aaBuffer, '  </table>')
		endif
	endif
		
	aAdd(aaBuffer, strTran(cRemarks, "@", "end"))
	
return iif(lBuffer,"",dwConcatWSep(CRLF, aBuffer))

/*
--------------------------------------------------------------------------------------
Constroi o bloco de abas em formularios
Args:	aaBuffer, array, buffer de armazenamento
      TabbedPane, array, contendo todas as propriedades e atributos do componente
--------------------------------------------------------------------------------------
*/
static function buildTabbedPane(aaBuffer, aaTabbedPane)
	local nInd, cLine, aFields, lEdit := .t.
	local aChildFields := aaTabbedPane[9]
	local aChildNames := {}, nCntAba := 1
	local nLimAbas := 7, aAux
	
	aAdd(aaBuffer, '<!-- tabbedPane Begin -->')
	aAdd(aaBuffer, "<div id='"+aaTabbedPane[2]+"' class='DwTabbedGroup'>")
	
	aAdd(aaBuffer, "  <table summary= '' align='left' class='DwTabbed'>")
	aAdd(aaBuffer, "    <tr>")
	if Upper(left(aChildFields[1, 2],5)) == "ABADW"
		nLimAbas := 5
	endif
	for nInd := 1 to len(aChildFields)
		cLine := '      <td id="DwTabbed' + aChildFields[nInd, 2] + '"><div title="'+dwStr(aChildFields[nInd, 3])+'">'
	  aAux := dwToken(aChildFields[nInd, 4], ";")
	  aSize(aAux,2)
	  if empty(aAux[1])
		  cLine += "<a href='#' onClick='javascript:showAba(" + ASPAS_D + aChildFields[nInd, 2] + ASPAS_D + ");' "
	  else
		  cLine += "<a href='#' onClick='javascript:"+aAux[1]+";showAba(" + ASPAS_D + aChildFields[nInd, 2] + ASPAS_D + ");' "
    endif
		cLine += " onMouseOver="+ASPAS_D+"window.status='';return true;"+ASPAS_D+">"
		cLine += DwStr(aChildFields[nInd, 3]) + "</a></div></td>"
		aAdd(aaBuffer, cLine)
		if nCntAba == nLimAbas
			aAdd(aaBuffer, "    </tr>")
			aAdd(aaBuffer, "    <tr>")
			nCntAba := 0
		endif
		aAdd(aChildNames, aChildFields[nInd, 2] )
		nCntAba++
	next
	for nInd := nCntAba to nLimAbas
    aAdd(aaBuffer, "      <td style='background-image:none'></td>")
  next
	aAdd(aaBuffer, "    </tr>")
	aAdd(aaBuffer, "  </table>")
	aAdd(aaBuffer, "</div>")
	
	if isFireFox() // utilizado para ajustar o lay-out
		aAdd(aaBuffer, "</td></tr><tr><td colspan='2'>")
	endif
	
	for nInd := 1 to len(aChildFields)
		aFields := {}
		aAdd(aaBuffer, '<!-- tabbedChild begin ' + aChildFields[nInd, 2] +' -->')
		aAdd(aaBuffer, "<div id='"+aChildFields[nInd, 2]+"' class='DwTabbedChild" + iif(isNull(HttpGet->loadpgdw, CHKBOX_OFF) == CHKBOX_ON, " DwTabbedChildPainel", "") + "'>")
		buildBodyFields(aaBuffer, aChildFields[nInd, 11], lEdit)
		aAdd(aaBuffer, "</div>")
		aAdd(aaBuffer, '<!-- tabbedChild end ' + aChildFields[nInd, 2] +' -->')
	next
	
	aAdd(aaBuffer, tagJS())
	aAdd(aaBuffer, "initAbaList(new Array('" + dwConcatWSep("','", aChildNames) + "'));")
	aAdd(aaBuffer, "</script>")
	
	if lEdit
		aAdd(aaBuffer, tagJS())
		for nInd := 1 to len(aChildNames)
			aAdd(aaBuffer, "function "+aChildNames[nInd]+"Submit(oSender)")
			aAdd(aaBuffer, "{")
		  aAdd(aaBuffer, "  var lRet = true;")
		  aAux := dwToken(aChildFields[nInd, 4], ";")
		  aSize(aAux,2)
		  if !empty(aAux[2])
			  aAdd(aaBuffer, "  lRet = "+aAux[2]+";")
      endif			  
	    buildValidFields(aaBuffer, aChildFields[nInd, 11])
	    	aAdd(aaBuffer, "  if (!(lRet)) initAba('"+aChildNames[nInd]+"');")
		  aAdd(aaBuffer, "  return lRet;")
	    aAdd(aaBuffer, "}")
		next
		aAdd(aaBuffer, "function "+aaTabbedPane[2]+"Submit(oSender)")
		aAdd(aaBuffer, "{")                    
		if len(aChildNames) == 0
		  aAdd(aaBuffer, "  return true;")
		else
		  aAdd(aaBuffer, "  var lRet = true;")
		  for nInd := 1 to len(aChildNames)
			  aAdd(aaBuffer, "  lRet = lRet && "+aChildNames[nInd]+"Submit(oSender);")
			  aAdd(aaBuffer, "  if (!(lRet)) return lRet;")
		  next
		  aAdd(aaBuffer, "  return lRet;")
		endif
		aAdd(aaBuffer, "}")
		aAdd(aaBuffer, "</script>")
	endif
	
	aAdd(aaBuffer, '<!-- tabbedPane End -->')

return

/*
--------------------------------------------------------------------------------------
Constroi a tag html para um component esecífico. Obs: Sem Label
Args:	aaField, array, contendo todas as propriedades e atributos do componente. Este array
	deve ser o mesmo que os métodos de construção de componentes (makeXXX()) definem
		alEdit, lógico, com opções de editável ou não
--------------------------------------------------------------------------------------
*/
static function buildComponent(aaField, alEdit, alOnlyOneCol)
	local cLine	:= "", lOnlyOneCol, cCaption

	default alEdit := .T.
	
	if aaField[FFLD_EDTTYPE] == EDT_LEGEND
    cLine += "<span class='legenda'>"
		cLine += tagImage(aaField[FFLD_NAME], 15, 15)+ aaField[FFLD_CAPTION]
    cLine += "</span>"
	elseif aaField[FFLD_EDTTYPE] == EDT_H1
		cLine += buildH1(aaField[FFLD_CAPTION])
	elseif aaField[FFLD_EDTTYPE] == EDT_H2
		cLine += buildH2(aaField[FFLD_CAPTION])
	elseif aaField[FFLD_EDTTYPE] == EDT_TITLE
		cLine += buildTitle(aaField[FFLD_CAPTION])
	elseif aaField[FFLD_EDTTYPE] == EDT_SUBTITLE
		cLine += buildSubTitle(aaField[FFLD_CAPTION], aaField[FFLD_OPERATION], aaField[FFLD_ACTION])
	elseif aaField[FFLD_EDTTYPE] == EDT_TEXT
	  if left(aaField[FFLD_CAPTION], 4) == "<!--"
			cLine += aaField[FFLD_CAPTION]
	  else
		cLine += '<span class="dw_text">'+aaField[FFLD_CAPTION]+'</span>'
		endif
	elseif aaField[FFLD_EDTTYPE] == EDT_ATTENTION
		cLine += buildAttention(aaField[FFLD_CAPTION])
	elseif aaField[FFLD_EDTTYPE] == EDT_WARNING
		cLine += buildWarning(aaField[FFLD_CAPTION])
	elseif aaField[FFLD_EDTTYPE] == EDT_BLANK
		cLine += '&nbsp;'
	else                
		if valtype(aaField[FFLD_CAPTION]) == "C" .and. left(aaField[FFLD_CAPTION],1) == "|" //força uma coluna
			lOnlyOneCol := .t.
			cCaption := substr(aaField[FFLD_CAPTION],2)
		else	                              
			lOnlyOneCol := alOnlyOneCol
			cCaption := aaField[FFLD_CAPTION]
		endif
		if len(aaField) == BTN_SIZE_ARRAY
			cLine += tagButton(aaField[BTN_TYPE], aaField[BTN_CAPTION], aaField[BTN_ACTION], iif(aaField[BTN_SMALL],"small",""))
		else                                                        
			if aaField[FFLD_DOTBUTTON] .AND. !aaField[FFLD_DOTINPUT]
				alEdit := .f.
			endif
			
			cLine += tagInputEx(aaField[FFLD_EDTTYPE], aaField[FFLD_NAME], aaField[FFLD_TYPE], ; 
					aaField[FFLD_LEN], aaField[FFLD_DEC], aaField[FFLD_VALUE], aaField[FFLD_OPTIONS], ;
					alEdit, aaField[FFLD_EVENTS], cCaption, aaField[FFLD_HOTKEY], ;
					aaField[FFLD_KEY], lOnlyOneCol, aaField[FFLD_DOTBUTTON], aaField[FFLD_CHOOSE], ;
					aaField[FFLD_DOTBTNACT], aaField[FFLD_LEN_MAX], aaField[FFLD_SHOWKBE])
		endif
	endif
	
return cLine

/*
--------------------------------------------------------------------------------------
Monta a validação de campos
Args:
--------------------------------------------------------------------------------------
*/
static function buildValidFields(aaBuffer, aaFields, acSufixo, lIsUser)
	local nInd, aField, cLine := ""
	local aDescart := { EDT_HIDDEN, EDT_SHOW, EDT_H1, EDT_H2, EDT_TITLE, EDT_SUBTITLE, EDT_TEXT, ;
			EDT_ATTENTION, EDT_BLANK, EDT_WARNING, EDT_RADIO, EDT_PROGRESSBAR, ;
			BT_SUBMIT, BT_RESET, BT_BUTTON, BT_CANCEL, BT_NEXT, BT_PREVIOUS, BT_PROCESS, ;
			BT_JAVA_SCRIPT, BT_PRINT, BT_CLOSE, BT_DOWNLOAD, BT_FINALIZE, BT_ADT_OPER, BT_BREAKROW ,;
			EDT_CUSTOM, EDT_CUSTOM_CONT, EDT_TABBED_GROUP, EDT_TABBED_PANE, EDT_TABBED_CHILD, EDT_TABBED_JSPANE, ;
			EDT_LEGEND }
	
	default acSufixo := ""
	default lIsUser := .F.
	
	
	for nInd := 1 to len(aaFields)
		aField := aaFields[nInd]
		if aScan(aDescart, aField[FFLD_EDTTYPE]) == 0
		  cLine := ""
			if valType(aField[FFLD_NAME]) == "A" // trata a dualist
				cLine += "if (!(doValidField(oSender."+aField[FFLD_NAME][2]+acSufixo+", "
			else
				//If aField[FFLD_NAME] == "edLogin" 
				iF lIsUser .And. aField[FFLD_NAME] == "edLogin"
					cLine += "if (!(doValidUser(oSender."+aField[FFLD_NAME]+acSufixo+", "
				Else
					cLine += "if (!(doValidField(oSender."+aField[FFLD_NAME]+acSufixo+", "
				EndIf						
			endif
			cLine += iif(valType(aField[FFLD_REQUIRED]) == "L" .AND. aField[FFLD_REQUIRED], "true", "false")
			cLine += ","
			if aField[FFLD_TYPE] == "C" .and. aField[FFLD_KEY]
				cLine += '"B",'  // somente A-Z0-9_
			else 
				cLine += '"'+left(aField[FFLD_TYPE],1) + '",'
			endif
			cLine += dwStr(aField[FFLD_LEN]) + ","
			cLine += dwStr(aField[FFLD_DEC]) + "))) " 
			cLine += "lRet = false;"
			aAdd(aaBuffer, cLine + CRLF)
		elseif aField[FFLD_EDTTYPE] == EDT_TABBED_PANE //EDT_TABBED_GROUP
	    cLine := "if (!("+aField[FFLD_NAME]+"Submit(oSender))) lRet = false;"
			aAdd(aaBuffer, cLine + CRLF)
		elseif aField[FFLD_EDTTYPE] == EDT_TABBED_CHILD
	    cLine := "if (!("+aField[FFLD_NAME]+"Submit(oSender))) lRet = false;"
			aAdd(aaBuffer, cLine + CRLF)
		endif
	next

return

/*
--------------------------------------------------------------------------------------
Monta a "hot-keys"
Args:
--------------------------------------------------------------------------------------
*/
static function validHotKeys(aaFields, acHotKey)
	local nInd, lRet := .t., aField
	                                                 
	acHotKey := upper(acHotKey)
	if (acHotKey >= "0" .and. acHotKey <= "9") .or. ;
       (acHotKey >= "A" .and. acHotKey <= "Z")
		for nInd := 1 to len(aaFields)
			aField := aaFields[nInd]
			if valType(aField[FFLD_HOTKEY]) == "U" .or. empty(aField[FFLD_HOTKEY])
			elseif upper(aField[FFLD_HOTKEY]) == acHotKey
				lRet := .f.
				exit
			endif   
		next
	endif
	
return lRet

static function makeHotKeys(aaFields)
	local nInd, nInd2, aField, cHotKey, lOpenTag := .f.
	local aDescart := { EDT_HIDDEN, EDT_SHOW, EDT_H1, EDT_H2, EDT_TITLE, EDT_CHECKBOX,;
	        EDT_CHECKBOX2, EDT_PROGRESSBAR, EDT_SUBTITLE, EDT_TEXT, EDT_ATTENTION, EDT_BLANK, ;
	        EDT_WARNING, EDT_DUALLIST, BT_SUBMIT, BT_RESET, BT_BUTTON, BT_CANCEL, BT_NEXT, ;
	        BT_PREVIOUS, BT_PROCESS, BT_JAVA_SCRIPT, BT_PRINT, BT_CLOSE, BT_DOWNLOAD, ;
	        BT_FINALIZE, BT_ADT_OPER, BT_BREAKROW, EDT_CUSTOM, EDT_CUSTOM_CONT, EDT_TABBED_PANE, ;
	        EDT_TABBED_CHILD, EDT_TABBED_JSPANE, EDT_LEGEND, EDT_IFRAME, EDT_TABBED_GROUP }
	
	for nInd := 1 to len(aaFields)
		aField := aaFields[nInd]
		if aScan(aDescart, aField[FFLD_EDTTYPE]) == 0
			if valType(aField[FFLD_HOTKEY]) == "U" .or. empty(aField[FFLD_HOTKEY])
				lOpenTag := .f.
				for nInd2 := 1 to len(aField[FFLD_CAPTION])
					cHotKey := substr(aField[FFLD_CAPTION], nInd2, 1)
					if (cHotKey >= "0" .and. cHotKey <= "9") .or. ;
					   (cHotKey >= "A" .and. cHotKey <= "Z") .or. ;					
					   (cHotKey >= "a" .and. cHotKey <= "c")
						if lOpenTag
							if cHotKey == ">"
								lOpenTag := .f.
							endif
						elseif cHotKey == "<"
							lOpenTag := .t.
						elseif validHotKey(aaFields, cHotKey)
							aField[FFLD_HOTKEY] := cHotKey
							aField[FFLD_CAPTION] := substr(aField[FFLD_CAPTION], 1, nInd2-1)+'<u>'+aField[FFLD_HOTKEY]+'</u>'+ substr(aField[FFLD_CAPTION], nInd2+1)
				    	    exit
					  	endif
					endif
				next
			endif
		endif
	next
	
return	

/*
--------------------------------------------------------------------------------------
Monta o tag <button>
Args:
--------------------------------------------------------------------------------------
*/
function tagButton(acType, acText, acAction, acAdtClass, aaActionParams, acID, alEnable)
	local cRet := ""
  local oWebApp := getWebApp()
  local lAnchor := .f.

	default acAdtClass := ""
	default aaActionParams := {}
	default acID := ""
	default alEnable := .t.

  if valType(acAction) == "C"
    if left(acAction,2) == "A:"
      lAnchor := .t.
      acAction := substr(acAction, 3)
    endif
  endif
  
 	if DwIsWebEx() .and. HttpIsConnected() .and. oWebApp:isPortal()
    cRet += '<input type="button"'
 	elseif lAnchor
		cRet += '<a href="js:void(0)"'
 	else
		cRet += '<button'
	endif
	cRet += iif(empty(acID), "", " id='"+acID+"' name='"+acID+"'")
	
	if !alEnable
		cRet += " disabled "
	endif

	if acType == BT_SUBMIT
		if empty(acText)
   			acText := STR0001 //###"enviar"
 		endif
		cRet += ' onclick=' + makeJSAction("doSubmit(this.form,"+iif(dwIsAjax(), "true", "false")+")", .t.)
	elseif acType == BT_PROCESS
		if empty(acText)
 			acText := STR0001 //###"enviar"
 		endif
		cRet += ' onclick=' + makeJSAction("doSubmit(this.form,"+iif(dwIsAjax(), "true", "false")+")", .t.)
	elseif acType == BT_RESET
		if empty(acText)
			acText := STR0002 //###"desfazer"
		endif
		cRet += ' onclick=' + makeJSAction('doReset(this.form)', .f.)
	elseif acType == BT_CANCEL
		if empty(acText)
 			acText := STR0003 //###"cancelar"
 		endif
		cRet += ' onclick=' + makeJSAction('doClose(false)', .t.)
	elseif acType == BT_NEXT
		if empty(acText)
			acText := STR0004 //###"próximo"
		endif
		if dwIsAjax()
			cRet += ' onclick=' + makeJSAction('doNextStep()')
		else
      		cRet += ' type="submit"'
		endif
	elseif acType == BT_PREVIOUS
 		if empty(acText)
 			acText := STR0005 //###"anterior"
 		endif
 		if empty(acAction)
 			if dwIsAjax()
				cRet += ' onclick=' + makeJSAction('doPreviousStep()')
			else
				cRet += ' onclick=' + makeJSAction('history.back()')
			endif
		else
			cRet += " onclick='window.location=" + makeAction(acAction, aaActionParams) + "';"
		endif
	elseif acType == BT_JAVA_SCRIPT
		cRet += ' onclick=' + makeJSAction(acAction, .t.)
	elseif acType == BT_PRINT
		if empty(acText)
			acText := STR0006 //####"imprimir"
		endif
		cRet += ' onclick=' + makeJSAction("doPrint()", .t.)
	elseif acType == BT_CLOSE
		if empty(acText)
			acText := STR0007 //####"fechar"
		endif
		cRet += ' onclick=' + makeJSAction('doClose()', .t.)
	elseif acType == BT_DOWNLOAD
		if empty(acText)
			acText := STR0008 //####"download"
		endif
		cRet += " onclick=" + makeJSAction("doLoad(" + acAction + ",'_DwPrint',null,'WinDWPrint'," + DwStr(TARGET_50_WINDOW) + "," + DwStr(TARGET_50_WINDOW) + ")", .t.)
	elseif acType == BT_FINALIZE
		if empty(acText)
			acText := STR0009 //###"finalizar"
		endif
		cRet += ' onclick=' + makeJSAction('doLoadHere('+makeAction(acAction)+')', .t.)
	elseif acType == BT_START_UPLOAD
	  // aaActionParams => array composto de 3 itens, onde:
	  //   [1] = string, div target para o AJAX
	  //   [2] = string, ID de processo ("tipo de upload a ser efetuado")
	  //   [3] = string, parametros necessários a execução do upload (complemento)
		if empty(acText)
			acText := STR0114 //###"upload"
		endif
		cRet += ' onclick=' + ajaxGet(aaActionParams[1], AC_START_UPLOAD,  { { "process", aaActionParams[2] } , { "params", aaActionParams[3] } })
	else
		cRet += ' onclick=' + makeJSAction('doLoadHere('+makeAction(acAction)+')', .t.)
	endif

 	if DwIsWebEx() .and. HttpIsConnected() .and. oWebApp:isPortal()
		cRet += ' value="'+acText+'">'
 	else
		cRet += ' onmouseout="this.className='+ASPAS_S+acAdtClass+ASPAS_S+'"'
 		cRet += ' onmouseover="this.className='+ASPAS_S+"ativo"+acAdtClass+ASPAS_S+'"'
 		cRet += ' class="'+iif(alEnable, "", "inativo") + acAdtClass + '" value="' + acText + '">'
		cRet += acText
		if lAnchor
		  cRet += '</a>'
		else
		  cRet += '</button>'
	  endif
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Prepara uma ação de JavaScript
Args: acAction, string, ação a ser executada
      alDisable, logico, desabilita o botão, após a execução
--------------------------------------------------------------------------------------
*/
static function makeJSAction(acAction, alDisable)
	local cRet
	default alDisable := .f.

	if alDisable
		cRet := '"javascript: !enableElement(this,'+strTran(acAction, '"', "'")+'); return false;"'
	else
		cRet := '"javascript:'+strTran(acAction, '"', "'")+';"'
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Prepara um item de lista
Args:
--------------------------------------------------------------------------------------
*/
function makeListItem(acLink, acAlt, acDescription, acIcone, aaParams, alMark, anFlexOptions)
	local cTagImage
  local aRet := array(LIST_SIZE)
  
	default alMark := .f.
	default anFlexOptions := 0
	
	if alMark                                                         
		cTagImage := tagImage(acIcone, -1, -1, acAlt, acDescription, "#marked")
	else
 		cTagImage := tagImage(acIcone, -1, -1, acAlt, acDescription)
	endif	
                                                         
  aRet[LIST_LINK ] := makeAction(acLink, aaParams)
  aRet[LIST_ICONE] := cTagImage
  aRet[LIST_NAME ] := acAlt
  aRet[LIST_DESC ] := acDescription
  aRet[LIST_FLEX ] := anFlexOptions

return aRet

/*
--------------------------------------------------------------------------------------
Monta a lista de itens
Args:
--------------------------------------------------------------------------------------
*/
function buildList(acTitle, aItens, anType, acActionList, aaButtons)
	local nInd, aBuffer := {}, cAux
	local cStyle := ""
	
	default anType := LIST_MINI
	default acActionList := ""
	default aaButtons := {}
	
	if !DWisFlex()
		if anType == LIST_MINI
			cStyle := "icone_mini"
		elseif anType == LIST_TOP_DOWN
			cStyle := "icone_top_down"
		else
			cStyle := "icone_list"
		endif

		aAdd(aBuffer, '<!-- buildList start aph/apl '+procname(2)+':'+procname(1)+' -->')
		aAdd(aBuffer, '<table summary="" class="buildList">')
		aAdd(aBuffer, '<col width="18px">')
		aAdd(aBuffer, '<col>')
		aAdd(aBuffer, '<col width="18px">')
		
		aAdd(aBuffer, '<tr>')
		aAdd(aBuffer, '<td class="comborda_sup_esq"></td>')
		aAdd(aBuffer, '<td class="comborda_sup"></td>')
		aAdd(aBuffer, '<td class="comborda_sup_dir"></td>')
		aAdd(aBuffer, '</tr>')
		aAdd(aBuffer, '<tr>')

		aAdd(aBuffer, '<td class="comborda_tit_esq"></td>')
		aAdd(aBuffer, '<td class="titulo">' + acTitle + '</td>')
		aAdd(aBuffer, '<td class="comborda_tit_dir"></td>')
		aAdd(aBuffer, '</tr>')
		aAdd(aBuffer, '<tr>')
		aAdd(aBuffer, '<td class="comborda_esq"></td>')
		aAdd(aBuffer, '<td>')
		
		aAdd(aBuffer, '<div id="divMini" class="'+cStyle+' shadow">')
		if valType(aItens) == "A" .AND. len(aItens) > 0
			for nInd := 1 to len(aItens)
				cAux := '<div class="shadow"><a href='+dwStr(aItens[nInd, LIST_LINK])
				cAux += " onMouseOver="+ASPAS_D+"window.status='';return true;"+ASPAS_D+">"
				cAux += aItens[nInd, LIST_ICONE]
				if anType == LIST_TOP_DOWN
					cAux += '<span class="icone_name">'+dwstr(aItens[nInd, LIST_NAME])+'</span>'
				else
					cAux += '<span class="icone_name">'+dwstr(left(aItens[nInd, LIST_NAME],5 ))
					cAux += iif(len(aItens[nInd, LIST_NAME]) > 5, "...","")+'</span>'
				endif
				aAdd(aBuffer, cAux)
				aAdd(aBuffer, '<span class="icone_desc">'+aItens[nInd, LIST_DESC]+'</span></a></div>')
			next
		else
			//Exibição de texto no local de DWS (Desabilitado)
			//aAdd(aBuffer, makeWarning(NIL, "A pesquisa não retornou nenhum resultado. Por favor, volte e refaça a pesquisa."))
		endif
		aAdd(aBuffer, '</div>')
		
		aAdd(aBuffer, '</td>')
		aAdd(aBuffer, '<td class="comborda_dir"></td>')
		aAdd(aBuffer, '</tr>')
		aAdd(aBuffer, '<tr>')
		aAdd(aBuffer, '<td class="comborda_esq"></td>')
		aAdd(aBuffer, '<td style="text-align: right;">')
		
		// constrói os botões extras
		if !(len(aaButtons) == 0)
			for nInd := 1 to len(aaButtons)
				aAdd(aBuffer, '<span ' + aaButtons[nInd][NAV_ALIGN] + '>')
				aAdd(aBuffer, 	aaButtons[nInd][NAV_ICONE])
				aAdd(aBuffer, '</span>')
			next
		endif
		
		if !empty(acActionList)
			aAdd(aBuffer, tagLinkModal(acActionLink, "", tagImage("ic_setup.gif", 14, 14, STR0027, STR0028))) //###"Disponibilidade"###"Permite configurar a disponibilidade dos datawarehouses"
		endif
		if anType == LIST_TOP_DOWN
		elseif anType == LIST_MINI
			aAdd(aBuffer, tagImage("ic_list.gif", 16, 13, STR0029, STR0030, nil, "doChangeView(this, getImageList())")) //###"Lista"###"Apresenta informações em uma lista detalhada"
		else
			aAdd(aBuffer, tagImage("ic_mini.gif", 12, 12, STR0031, STR0032, nil, "doChangeView(this, getImageList())")) //###"Miniaturas"###"Apresenta informações em forma resumida"
		endif
		aAdd(aBuffer, '  </td>')
		aAdd(aBuffer, '  <td class="comborda_dir"></td>')
		aAdd(aBuffer, '</tr>')
		aAdd(aBuffer, '<tr>')
		aAdd(aBuffer, '  <td class="comborda_inf_esq" valign="top"></td>')
		aAdd(aBuffer, '  <td class="comborda_inf"></td>')
		aAdd(aBuffer, '  <td class="comborda_inf_dir" valign="top"></td>')
		aAdd(aBuffer, '</tr>')
		aAdd(aBuffer, '</table>')
		
		aAdd(aBuffer, '<!-- buildList end -->')
	else
		aAdd(aBuffer, "<buildList>")
		if valType(aItens) == "A" .and. len(aItens) > 0
			for nInd := 1 to len(aItens)
				aAdd(aBuffer, "<item>")
				aAdd(aBuffer, "  <href>" + delAspas(aItens[nInd, LIST_LINK]) + "</href>")
				aAdd(aBuffer, "  <icone>" + aItens[nInd, LIST_ICONE] + "</icone>")
				aAdd(aBuffer, "  <name>" + aItens[nInd, LIST_NAME] + "</name>")
				aAdd(aBuffer, "  <description>" + aItens[nInd, LIST_DESC] + "</description>")
				aAdd(aBuffer, "</item>")
			next
		endif
		aAdd(aBuffer, "</buildList>")
	endif
	
	if dwIsFlex()
		flexSend(aBuffer)
	else
		aEval(aBuffer, { |x| httpSend(x + CRLF) })
	endif

return ""

/*
--------------------------------------------------------------------------------------
Prepara a aba para montagem
Args:
--------------------------------------------------------------------------------------
*/
function makeAba(aaAbas, acCaption, axID, acAction)
	local aRet
	if valtype(axID) == "A"
		aRet := { axID[1][2], acCaption, aClone(axID), {}, acAction }
	else
		aRet := { axID, acCaption, nil, {}, acAction }
	endif 

	aAdd(aaAbas, aRet)

return aRet

/*
--------------------------------------------------------------------------------------
Monta a navegação
Args:
--------------------------------------------------------------------------------------
*/
static function buildMenu(aaBuffer, anNumber, aaMenus, aoTree, acParentNode, acAction)
	local nInd, aItem, lOpenList, aMenuAux := {}
	local cLine := ""
	
	if !(valType(aoTree) == "O")
		for nInd := 1 to len(aaMenus)
			aItem := aaMenus[nInd]                         
			
			if len(aItem) > 2 .and. valType(aItem[3]) == "A"
				aAdd(aMenuAux, { aItem[1], "" })
				aEval(aItem[3], { |x| aAdd(aMenuAux, { x[1], x[2] })})
			else
				aAdd(aMenuAux, { aItem[1], aItem[2] })
			endif		
		next
		
		aAdd(aaBuffer, '<!-- buildMenuStart -->')
		if isFireFox()
			aAdd(aaBuffer, '<div class="dropMenu shadow" id="divMenu'+dwStr(anNumber)+'" onmouseover="javascript:overpopupmenu=true;" onmouseout="javascript:overpopupmenu=false;">')
		else
#ifdef VER_P11
			aAdd(aaBuffer, '<div class="dropMenu shadow P11" id="divMenu'+dwStr(anNumber)+'" onmouseover="javascript:overpopupmenu=true;">')
#else
			aAdd(aaBuffer, '<div class="dropMenu shadow" id="divMenu'+dwStr(anNumber)+'" onmouseover="javascript:overpopupmenu=true;">')
#endif
		endif
		aAdd(aaBuffer, '<table id="operMenuTab" summary="">')
		aAdd(aaBuffer, '<col width="15px">')
		aAdd(aaBuffer, '<col>')
		for nInd := 1 to len(aMenuAux)
			aItem := aMenuAux[nInd]
			cLine := "<tr><td"
			if empty(aItem[2])                               
			elseif aItem[2] == atail(HttpSession->CurrentAba)
				cLine += " class='current'"
			endif            
			cLine += "></td><td>"
			if empty(aItem[2])
			else                                               
				cLine += tagLink(acAction, aItem[1], nil, {{"aba", aItem[2]}})
			endif                         
			cLine += "</td></tr>"
			aAdd(aaBuffer, cLine)
		next
		aAdd(aaBuffer, '</table>')
		aAdd(aaBuffer, '</div>')
		aAdd(aaBuffer, '<!-- buildMenuEnd -->')
	else
		for nInd := 1 to len(aaMenus)
			aItem := aaMenus[nInd]
			aoTree:AddNode(acParentNode, acParentNode + "_" + dwStr(nInd), aItem[1], .f., iif (!empty(acAction) .and. !empty(aItem[2]), makeAction(acAction, {{ "aba", aItem[2]}}, .f.), ""))
			if len(aItem) > 2 .and. valType(aItem[3]) == "A"
				buildMenu(aaBuffer, anNumber, aItem[3], aoTree, acParentNode + "_" + dwStr(nInd), acAction)
			endif
		next
	endif
return

static function buildAba(aaBuffer, aaAba, acCurrentAba, alFolder, aaMenus, anPos, acLevel, acAction, acStyle, acSubStyle)
	local cLine

	default acLevel := ""
	default acStyle := ""
	default acSubStyle := ""

	cLine := "<a " + iif(empty(aaAba[ABA_ID]),"", "id='"+aaAba[ABA_ID]+"'")
	if aaAba[ABA_ID] == acCurrentAba
		// define o link de navegação
		addNavegMenu(tagLink(acAction, aaAba[ABA_CAPTION], nil, {{"aba", aaAba[ABA_ID]}}))
	endif
	if valType(aaAba[ABA_MENU]) == "A"
		cLine += if(!empty(acSubStyle), ' class="' + acSubStyle + if(ascan(aaAba[ABA_MENU], { |x| x[2] == acCurrentAba}) > 0, 'Ativo', '') + '"',' ')
		if alFolder
			aAdd(aaMenus, aaAba[ABA_MENU])
			cLine += " onmouseover=" + makeJSAction("doShowMenu("+dwStr(len(aaMenus))+","+dwStr(anPos)+", event);" +;
					"window.status='"+aaAba[ABA_CAPTION]+"';return true")
		else
			cLine += " onmouseover=" + ASPAS_D + "window.status='"+aaAba[ABA_CAPTION]+"';return true;" + ASPAS_D
		endif
	else
		cLine += if(!empty(acSubStyle), ' class="' + acSubStyle + if(aaAba[ABA_ID] == acCurrentAba, 'Ativo', '') + '"',' ')
		if left(acAction, 3) == "js:"
			cLine += " href="+makeJSAction(acAction)
		else
			cLine += " href="+makeAction(acAction, {{ "aba", aaAba[ABA_ID]}})
		endif
		cLine += " onmouseover=" + ASPAS_D + "window.status='"+aaAba[ABA_CAPTION]+"';return true;" + ASPAS_D
	endif
	cLine += ">"
	if alFolder
		cLine += aaAba[ABA_CAPTION]
	else
		if aaAba[ABA_ID] == acCurrentAba
			cLine += tagImage("tree_close.gif", nil, nil, nil, nil,"#treeIcone")
		elseif !(valType(aaAba[ABA_MENU]) == "A")
			cLine += tagImage("tree_end.gif", nil, nil, nil, nil,"#treeIcone")
		else
			cLine += tagImage("tree_open.gif", nil, nil, nil, nil,"#treeIcone")
		endif
		cLine += aaAba[ABA_CAPTION]
	endif
	cLine += "</a>"

	if alFolder
		if valType(aaAba[ABA_MENU]) == "A"
			cLine := '<td ' + if(!empty(acStyle), ' class="' + acStyle + if(ascan(aaAba[ABA_MENU], { |x| x[len(x)] == acCurrentAba}) > 0, 'Ativo', '') + '"',' ') + '>' + cLine + '</td>'
		else
			cLine := '<td ' + if(!empty(acStyle), ' class="' + acStyle + if(aaAba[ABA_ID] == acCurrentAba, "Ativo", "") + '"', "") + '>' + cLine + '</td>'
		endif
	endif
		
	aAdd(aaBuffer, cLine)
return 

static function buildFolder(aBuffer, aAbas, aaCurrents, acAction)
	local nInd, aAba, aAba2
	local aMenus := {}
	local cTemp := ""

	aAdd(aBuffer, '<!-- buildFolder Begin -->')
	aAdd(aBuffer, '<div id="folder" class="folder">')
	aAdd(aBuffer, '<table summary="">')
	aAdd(aBuffer, '<tr>')
	for nInd := 1 to len(aAbas)
		aAba := aAbas[nInd]
		if len(aAba[ABA_ABAS]) > 0
			aAba2 := aAba[ABA_ABAS]
		elseif !empty(aAba[ABA_ACTION])
			acAction := aAba[ABA_ACTION]
		endif
		buildAba(aBuffer, aAba, aaCurrents[1], .t., aMenus, nInd, , acAction, "menu", "menu")
	next
	aAdd(aBuffer, '</tr>')
	aAdd(aBuffer, '</table>')
	
	aAdd(aBuffer, '<!-- buildSubFolder Begin -->')
	aAdd(aBuffer, '<div id="subFolder" class="subFolder">')
	aAdd(aBuffer, '<table summary="">')
	aAdd(aBuffer, '<tr>')
	if !empty(aAba2) .and. len(aAba2) > 0
		for nInd := 1 to len(aAba2)
			aAba := aAba2[nInd]
			buildAba(aBuffer, aAba, if(aaCurrents[2] <> "apoio_conexao",aaCurrents[2], aaCurrents[3]) , .t., aMenus, nInd, ,acAction, "subMenu", "subFolder")
		next
		for nInd := len(aAba2) to 6
			aAdd(aBuffer, '<td>&nbsp;</td>')
		next
		aAdd(aBuffer, '<td style="text-align: right;">')

		buildOperationalButtons(aBuffer)
		
		aAdd(aBuffer, '&nbsp;</td>')
	endif
	aAdd(aBuffer, '</tr>')
	aAdd(aBuffer, '</table>')
	aAdd(aBuffer, '</div>')
	aAdd(aBuffer, ' <!-- buildSubFolder End -->')

	aAdd(aBuffer, '</div>')
	aAdd(aBuffer, '<!-- buildFolder End -->')

	if len(aMenus) > 0
		for nInd := 1 to len(aMenus)
			buildMenu(aBuffer, nInd, aMenus[nInd], .f., ,acAction)
		next
		aAdd(aBuffer, tagJS())
		for nInd := 1 to len(aMenus)
		  aAdd(aBuffer, 'startMenu('+dwStr(nInd)+');')
		next
		aAdd(aBuffer, '</script>')
	endif
//	aAdd(aBuffer, '</div>')
	aAdd(aBuffer, '<!-- buildSubFolder End -->')
	
	// define o link de navegação
	addNavegMenu(cTemp)
	
	// cria o menu de navegação por links
	makeNavegMenu()            
	
return

static function buildOperationalButtons(aaBuffer)               
	local cHelpServer := alltrim(oSigaDW:HelpServer())
	local defHelp := ""
	Local cLang := Lower( __Language )
	
	// --------------------------------------------------------
	// No Protheus 11 a ULR do help é diferente do Protheus 10.
	// -------------------------------------------------------- 
	#ifdef VER_P10
		defHelp := cLang +"/sigadw_"
	#else            
		defHelp := cLang +"/mergedprojects/sigadw/"
	#endif

	// --------------------------------------------------------
	// No Protheus 11 o botão de ajuda é exibido no rodapé.
	// --------------------------------------------------------   
	#ifdef VER_P11
	#else
		aAdd(aaBuffer, tagImage("ic_ajuda_peq_off.gif", 12, 12, STR0088,,,"js:doHelp(this,'"+cHelpServer+"/"+defHelp+"introducao.htm')"))	 //###"Ajuda"
	#endif 
	
	// --------------------------------------------------------
	// No Protheus 11 apenas o menu horizontal é utilizado.
	// --------------------------------------------------------   
	if isNull(HttpSession->isDWSelected, .f.)
		#ifdef VER_P11
		#else
			aAdd(aaBuffer, tagLink(AC_CHANGE_MENU, "", tagImage("ic_arvore.gif", 12, 12, STR0033))) //###"Menu vertical"
		#endif
	endif
	 
	// --------------------------------------------------------
	// No Protheus 11 apenas o cabeçalho mínimo  é utilizado.
	// --------------------------------------------------------   
	if isNull(HttpSession->isLogged, .f.)   
		#ifdef VER_P11
		#else
			if isNull(HttpSession->MiniHeader, CHKBOX_OFF) == CHKBOX_OFF
				aAdd(aaBuffer, tagImage("ic_min.gif",12, 12, STR0034,,,"doMinMax(this)")) //###"Cabeçalho mínimo"
			else
				aAdd(aaBuffer, tagImage("ic_max.gif",12, 12, STR0035,,,"doMinMax(this)")) //###"Cabeçalho normal"
			endif 
		#endif
	endif  

	// --------------------------------------------------------
	// No Protheus 10 e 11 a selação de menu é utilizada.
	// --------------------------------------------------------   	
	if isNull(HttpSession->isDWSelected, .f.)
		aAdd(aaBuffer, tagLink(AC_CHANGEDW, "", tagImage("ic_select_dw.gif", 12, 12, STR0036))) //###"Selecionar outro Dw"
	endif
return

/*
--------------------------------------------------------------------------------------
Define um "nó" para a arvore
Args:
--------------------------------------------------------------------------------------
*/
function makeTreeNode(aaTree, acCaption, acID, aaAction, alCanOpen, aaSubNodes) //aaAction = { action, { { paramName, paramValue },...}
	local aRet

  default acID := dwMakeName("tre")

  if !(valType(aaAction) == "A")
    aaAction := AC_NONE
  endif  
  
	aRet := { acID, acCaption, aaAction, alCanOpen, aaSubNodes }

  if valType(aaTree) == "A"
		aAdd(aaTree, aRet)
	endif

return aRet

/*
--------------------------------------------------------------------------------------
Prepara parametros para serem enviados por AJAX
Args:
--------------------------------------------------------------------------------------
*/
static function params2Ajax(aaParams)
  local cRet := '{', aAux, nInd, nLen
  
  if len(aaParams) == 2 .and. valType(aaParams[2]) == "A"
    cRet += "action:'" + aaParams[1] + "',"
    aAux := aClone(aaParams[2])
  else
    aAux := aClone(aaParams)
  endif
  prepareParams(aAux)  
  nLen := len(aAux)        
  for nInd := 1 to nLen
    aAux[nInd, 2] := dwStr(aAux[nInd, 2]) 
    if left(aAux[nInd, 2], 3) == "js:"
			aAux[nInd, 2] := substr(aAux[nInd, 2], 4)
		else
			aAux[nInd, 2] := "'" + aAux[nInd, 2] + "'"
		endif
    aAux[nInd] := aAux[nInd, 1] + ":" + aAux[nInd, 2]
  next
  
  cRet += dwConcatWSep(",", aAux)
  cRet += "}"
  
return cRet

/*
--------------------------------------------------------------------------------------
Adiciona "nós" na arvore
Args:
--------------------------------------------------------------------------------------
*/
static function addTreeChilds(aaBuffer, aaItems, anLevel)
  local nInd, nLen := len(aaItems)  
  local aItem
  
//{ acID, acCaption, aaAction, alCanOpen, aaSubNodes }
	
	for nInd := 1 to nLen
    aItem := aaItems[nInd]
    if valType(aItem[3]) == "A"
      cLink := ajaxAction("main_content", aItem[3,1], aItem[3,2])
			aAdd(aaBuffer, "<li id='"+aItem[1]+"' onclick="+cLink+">"+aItem[2]+"</li>")
    elseif valType(aItem[5]) == "A" .and. len(aItem[5]) > 0 //sub-items
  		aAdd(aaBuffer, "<li id='"+aItem[1]+"'>"+aItem[2])
			aAdd(aaBuffer, "  <ul>")
      addTreeChilds(aaBuffer, aItem[5])
			aAdd(aaBuffer, "  </ul>")
  		aAdd(aaBuffer, "</li>")
    elseif aItem[4]
  		aAdd(aaBuffer, "<li id='"+aItem[1]+"'>"+aItem[2])
			aAdd(aaBuffer, "  <ul id='ul"+aItem[1]+"'>")
  		aAdd(aaBuffer, "    <li>_empty_</li>")
			aAdd(aaBuffer, "  </ul>")
			aAdd(aaBuffer, "</li>")
    else
  		aAdd(aaBuffer, "<li id='"+aItem[1]+"'>"+aItem[2]+"</li>")
    endif
  next
  
return

/*
--------------------------------------------------------------------------------------
Monta sub-arvore
Args:
--------------------------------------------------------------------------------------
*/
function htmlSubTree(aaItems, acRootNode, acTreeID, alSend, anHeight)
	local aBuffer := {}

  default acRootNode := ""
  default acTreeID := ""
  default alSend := .f.
    
  if !empty(acRootNode)
		aAdd(aBuffer, "<p class='mktreeRoot'>"+acRootNode+"</p>")
	endif

  if valType(anHeight) == "N"
  	aAdd(aBuffer, "<div class='mktreeRoot' style='max-height:"+buildMeasure(anHeight)+"'>")
	endif
	
  aAdd(aBuffer, "<ul class='mktree' id='"+acTreeID+"'>")

  addTreeChilds(aBuffer, aaItems)
  
  aAdd(aBuffer, "</ul>")

  if valType(anHeight) == "N"
  	aAdd(aBuffer, "</div>")
	endif
  
  if alSend
		//aEval(aBuffer, { |x| conout(x) }) //####debug
		aEval(aBuffer, { |x| httpSend(x+CRLF)})
		aBuffer := {}
	endif

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Constroi uma arvore (HTML)
Args:
--------------------------------------------------------------------------------------
*/
function htmlTree(aaItems, acRootNode, acTreeID, acMainTreeID, anHeight)
  local aBuffer := {}, nInd
  
  default acMainTreeID := acTreeID
    
  htmlSubTree(aaItems, acRootNode, acTreeID, .t., anHeight)

  aAdd(aBuffer, "<script>")
	aAdd(aBuffer, "convertTree('"+acTreeID+"',do"+acMainTreeID+"_onexpand);")
  aAdd(aBuffer, "</script>")
	//aEval(aBuffer, { |x| conout(x) }) //####debug
	aEval(aBuffer, { |x| httpSend(dwStr(x)+CRLF)})
	aBuffer := {}

return ""

/*
--------------------------------------------------------------------------------------
Constroi a arvore
Args:
--------------------------------------------------------------------------------------
*/
static function buildTree(aBuffer, aAbas, aaCurrents, acAction)
	local nInd, nInd2, aAba, aAba2
	local oTree, lBottom := .f.
	local lSubNodes := .f., cParentNode, cNode
	local cJSCall := ""
	local cTemp := ""
	local cLinkAux
	local aAux

	if !dwIsFlex()
		oTree := THTree():New()
		oTree:Name("navTree")
		oTree:Width(1)
		oTree:UrlFrame("_self")
		oTree:RootCaption("Navegação")
		
		for nInd := 1 to len(aAbas)
			aAba := aAbas[nInd]
			lSubNodes := valType(aAba[ABA_ABAS]) == "A" .and. len(aAba[ABA_ABAS]) > 0
			cParentNode := "na_" + dwStr(nInd)
			oTree:AddNode(nil, cParentNode, aAba[ABA_CAPTION], lSubNodes, iif (!empty(acAction), makeAction(acAction, {{ "aba", aAba[ABA_ID]}}, .f.), ""))
			if lSubNodes
				for nInd2 := 1 to len(aAba[ABA_ABAS])
					aAba2 := aAba[ABA_ABAS, nInd2]
					cNode := cParentNode + "_"+ dwStr(nInd2)
					
					if valType(aAba2[ABA_MENU]) == "A"
						oTree:AddNode(cParentNode, cNode, aAba2[ABA_CAPTION], valType(aAba2[ABA_MENU]) == "A", iif (!empty(acAction) .AND. !empty(aAba2[ABA_ID]), makeAction(acAction, {{ "aba", aAba2[ABA_ID]}}, .f.), ""))
						buildMenu(aBuffer, nInd2, aAba2[ABA_MENU], oTree, cNode, acAction)
					elseif valType(aAba2[ABA_ABAS]) == "A"
						oTree:AddNode(cParentNode, cNode, aAba2[ABA_CAPTION], valType(aAba2[ABA_ABAS]) == "A", iif (!empty(acAction) .AND. !empty(aAba2[ABA_ID]), makeAction(acAction, {{ "aba", aAba2[ABA_ID]}}, .f.), ""))
						buildMenu(aBuffer, nInd2, aAba2[ABA_ABAS], oTree, cNode, acAction)
					endif
					
					if aaCurrents[2] == aAba2[ABA_ID] ;
						.AND. !(valType(aAba2[ABA_MENU]) == "A") ;
						.AND. (!(valType(aAba2[ABA_ABAS]) == "A") .OR. len(aAba2[ABA_ABAS]) == 0)
						// define o link de navegação
						addNavegMenu(aAba2[ABA_CAPTION])
						cJSCall += "trees[0].toggle(" + DwStr(oTree:CountUntilSearch(cParentNode)) + "); trees[0].select(" + DwStr(oTree:CountUntilSearch(cNode)) + ")"
					else
						if valType(aAba2[ABA_MENU]) == "A"
							aAux := aAba2[ABA_MENU]
						elseif valType(aAba2[ABA_ABAS]) == "A"
							aAux := aAba2[ABA_ABAS]
						endif
						
						// recupera o link de navegação
						if valType(aAux) == "A"
							cLinkAux := getNavegMenu() + '|' + aAba2[ABA_CAPTION]
							cTemp := OpenNodesUntilSearch(aAux, oTree, aaCurrents, cNode + "_")
							if !empty(cTemp)
								// define o link de navegação
								addNavegMenu(cLinkAux, , .T.)
								cJSCall += "trees[0].toggle(" + DwStr(oTree:CountUntilSearch(cParentNode)) + ");" + ;
								"trees[0].toggle(" + DwStr(oTree:CountUntilSearch(cNode)) + ");" + cTemp
							endif
						endif
					endif
				next
			endif
		next
		
		// cria o menu de navegação por links
		makeNavegMenu()
		
		aAdd(aBuffer, '<div id="page_tree" class="page_tree">')
		
		// ser for menu do tipo árvore
		if !HttpSession->FolderMenu
			buildOperationalButtons(aBuffer)
		endif
		
		oTree:Buffer(aBuffer, @lBottom)
		
		aAdd(aBuffer, '</div>')
	else
		cJSCall := ""
	endif

return cJSCall

/*
--------------------------------------------------------------------------------------
Função responsável por pesquisar um abrir uma árvore do tipo tree até encontrar um nó específico
Args:	aaNodes, array, contém o array aonde deverá ser pesquisado o nó
		aoTree, objeto, contém o objeto do tipo árvore tree
		aaCurrentAba, array, array que contém a aba atual
		acNodeIndex, string, index atual sendo pesquisado na árvore/tree
Ret.: string, contém os comandos JavaScript para abrir a árvore até o nó
--------------------------------------------------------------------------------------
*/
static function OpenNodesUntilSearch(aaNodes, aoTree, aaCurrentAba, acNodeIndex)

	local nInd, nInd2
	local cJSCall := "", cTemp, cLinkAux
	
	for nInd := 1 to len(aaNodes)
		if len(aaNodes[nInd]) > 2 .and. valType(aaNodes[nInd, 3]) == "A" .and. len(aaNodes[nInd, 3]) <> 0
			cLinkAux := getNavegMenu() + '|' + aaNodes[nInd, 1]
			cTemp := OpenNodesUntilSearch(aaNodes[nInd, 3], aoTree, aaCurrentAba, acNodeIndex + DwStr(nInd) + "_")
			if !empty(cTemp)
				// define o link de navegação
				addNavegMenu(cLinkAux, , .T.)
				cJSCall += "trees[0].toggle(" + DwStr(aoTree:CountUntilSearch(acNodeIndex + DwStr(nInd))) + "); " + cTemp
			endif
		else
			if aScan(aaCurrentAba, {|cAba| cAba == aaNodes[nInd, 2]}) > 0
				for nInd2 := 1 to len(aaCurrentAba)
					if aaNodes[nInd, 2] == aaCurrentAba[nInd2]
						// define o link de navegação
						addNavegMenu(aaNodes[nInd, 1])
						cJSCall += " trees[0].select(" + DwStr(aoTree:CountUntilSearch(acNodeIndex + DwStr(nInd))) + ");"
					endif
				next
			endif
		endif
	next	

return cJSCall

/*
--------------------------------------------------------------------------------------
Função responsável por pesquisar SUBMENUS do tipo folder
Args:	aaNodes, array, contém o array aonde estão os submenus
		aaCurrentAba, array, array que contém a aba atual
Ret.: string, contém os links para um determinado nó do menu Folder (será utilizado em um menu de navegação)
--------------------------------------------------------------------------------------
*/
static function SearchMenus(aaNodes, aaCurrentAba)

	local nInd, nInd2
	local cTemp := "", cTemp2 := "", cLinkAux
	
	if !empty(aaNodes)
		for nInd := 1 to len(aaNodes)
			if len(aaNodes[nInd]) > 2 .and. valType(aaNodes[nInd, 3]) == "A" .and. len(aaNodes[nInd, 3]) <> 0
				cTemp2 += SearchMenus(aaNodes[nInd, 3], aaCurrentAba)
				if !empty(cTemp2)
					cTemp += "|" + aaNodes[nInd, 1] + cTemp2
				endif
			else
				if aScan(aaCurrentAba, {|cAba| cAba == aaNodes[nInd, 2]}) > 0
					for nInd2 := 1 to len(aaCurrentAba)
						if aaNodes[nInd, 2] == aaCurrentAba[nInd2]
							cTemp += '|' + tagLink(AC_SELECT_ABA, aaNodes[nInd, 1], nil, {{"aba", aaNodes[nInd, 2]}})
						endif
					next
				endif
			endif
		next
	endif
	
return cTemp

function buildNaveg(aBuffer, aAbas, aaCurrents, alFolderMenu, acAction)
	
	Local cTreeReturn
	
	default acAction := AC_SELECT_ABA

	if !dwIsFlex()
		
		if alFolderMenu
			aAdd(aBuffer, '<!-- buildNaveg begin -->')
			buildFolder(aBuffer, aAbas, aaCurrents, acAction)
			aAdd(aBuffer, '<!-- buildNavegEnd -->')
		else
			aAdd(aBuffer, '<!-- buildTree begin -->')
			cTreeReturn := buildTree(aBuffer, aAbas, aaCurrents, acAction)
			aAdd(aBuffer, '<!-- buildTree end -->')
		endif
	else
		cTreeReturn := ""
	endif
	
return cTreeReturn

function buildToolbar(aaBuffer, aaToolButtons, acBrowseExtraCSS)
	local aBuffer := aaBuffer
  local aItens := aaToolButtons, aItem
  local nInd, cBrowseExtraCSS
  
	default acBrowseExtraCSS := ""

	cBrowseExtraCSS := acBrowseExtraCSS
	
	aAdd(aBuffer, '<!-- buildBrowse toolbar start -->')
	aAdd(aBuffer, '<div id="divToolbar" class="toolbar_normal' + cBrowseExtraCSS + '">')
	for nInd := 1 to len(aItens)
		aItem := aItens[nInd]
		if valType(aItem[NAV_ACTION]) == "U"
			loop
		endif
		if aItem[NAV_LABEL] == NAV_SPECIAL
			aAdd(aBuffer, '<div '+aItem[NAV_ALIGN]+'>'+aItem[NAV_ICONE])
			aAdd(aBuffer, '<span class="toolbar_label' + cBrowseExtraCSS + '">&nbsp;</span></div>')
		else
			if valType(aItem[NAV_ACTION]) == "A"
				aAdd(aBuffer, '<div '+aItem[NAV_ALIGN]+'>' + tagLinkWin(aItem[NAV_ACTION][1], '', aItem[NAV_ICONE], {{"suboper", aItem[NAV_ACTION][2]}}, aItem[NAV_WINDOW_SIZE]))
			else
				aAdd(aBuffer, '<div '+aItem[NAV_ALIGN]+'>' +tagLink(aItem[NAV_ACTION], '', aItem[NAV_ICONE]))
			endif
			aAdd(aBuffer, '<span class="toolbar_label' + cBrowseExtraCSS + '">'+iif(empty(aItem[NAV_LABEL]), "&nbsp;",aItem[NAV_LABEL]) +"</span></div>")
		endif
	next
	aAdd(aBuffer, '</div>')
	aAdd(aBuffer, '<!-- buildBrowse toolbar end -->')

return
	
/*
--------------------------------------------------------------------------------------
Monta um iframe
Args:
--------------------------------------------------------------------------------------
*/
function buildIframe(aaBuffer, acAction, aaParams, acID, anWidth, anHeight, alScroll, acURL, alCons)
	Local aBuffer := isNull(aaBuffer, {})
	Local aParams, cSize := ""
  	Local cScrolling := ""
  	Local lConsulta := .F.
  	
	Default aaParams	:= {}
	Default acID 		:= ""
	Default alScroll 	:= .F.
	Default acURL 	:= ""
	Default alCons	:= .F.

	aParams := aClone(aaParams)
	
	if !empty(acID)
		acID := " id='"+acID+"' name='"+acID+"'"
	endif

	aAdd(aBuffer, '<!-- buildIframe begin -->')                                    
	if !empty(anWidth)
		cSize += "width:" + buildMeasure(anWidth) + ";"
	endif
	if !empty(anHeight)			
		If alCons
			cSize += "height:900px;"
		Else
			cSize += "height:" + buildMeasure(anHeight) + ";"
		EndIf
	endif
	
	if alScroll
		cSize += "overflow:auto;"
	else
	  cSize += "overflow:hide;"
	endif
	
	if empty(acAction)
		aAdd(aBuffer, "<iframe" + acID + cScrolling + " allowtransparency='true' frameborder='0' style='"+cSize+"'" + iif(!empty(acURL), " src='" + acURL + "'", "") + "></iframe>")
	else
		aAdd(aParams, { "frame", CHKBOX_ON})
		aAdd(aBuffer, "<iframe" + acID + cScrolling + " allowtransparency='true' frameborder='0' style='"+cSize+"' src=" + makeAction(acAction,  aParams) + '></iframe>')
	endif

	aAdd(aBuffer, '<!-- buildIframe end -->')

return	iif(isNull(aaBuffer), dwConcatWSep(CRLF, aBuffer), nil)

/*
--------------------------------------------------------------------------------------
Prepara item da toolbar superior
Args:
--------------------------------------------------------------------------------------
*/
function makeItemToolbar(aaToolbar, acLabel, acHint, acIcone, acAction, acAlign, acWindowSize)
	local cJSAction
	
	default acAlign := ""
	default acWindowSize := TARGET_98_WINDOW
		
	if !empty(acAlign)
		acAlign := " style='float:"+acAlign+"' "
	endif

	if !(valType(acAction) == "A")
		if left(acAction, 3) == "js:"
			cJSAction := substr(acAction, 4)
			acAction := AC_NONE
		endif
	else

	endif

	aAdd(aaToolbar, { acLabel, tagImage(acIcone, NIL, NIL, acLabel, acHint, nil, cJSAction), iif(valtype()=="A",aClone(acAction), acAction), acAlign, acWindowSize })

return

/*
--------------------------------------------------------------------------------------
Prepara item da toolbar superior
Args:
--------------------------------------------------------------------------------------
*/
function makeStepsToolbar(aaToolbar, acType, acLabel, acHint, acIcone, acAction, acAlign)
	local cJSAction
	
	default acAlign := ""
	
	if !empty(acAlign)
		acAlign := " style='float:"+acAlign+"' "
	endif
	
	if acType == BT_JAVA_SCRIPT
		aAdd(aaToolbar, { acLabel, tagButton(BT_JAVA_SCRIPT, acLabel, acAction), aClone(acAction), acAlign, "" })
	elseif left(acAction, 3) == "js:"
		aAdd(aaToolbar, { acLabel, tagImage(acIcone, nil, nil, acHint, nil, nil, substr(acAction, 4)) + " " + acLabel, acAction, acAlign })
	else	
		aAdd(aaToolbar, { acLabel, tagImage(acIcone, nil, nil, acHint, nil, nil, cJSAction), acAction, acAlign, "" })
	endif
return

function makeSepToolbar(aaToolbar)

	aAdd(aaToolbar, { "", tagImage("page_sep.gif", 6, 22), makeAction(AC_NONE), "", nil })

return

function makeSpecialToolbar(aaToolbar, acTag)

	aAdd(aaToolbar, { NAV_SPECIAL, acTag, "", "" }) //NAV_SPECIAL = BT_CUSTOM

return

/*
--------------------------------------------------------------------------------------
Monta titulo do formulario
Args:
--------------------------------------------------------------------------------------
*/
function buildFrmTitle(acOper)
	local cRet := ""
	local cAux
	
	cAux := HttpGet->subOper
	if !empty(cAux) .and. !(dwVal(cAux) == OP_NONE)
		acOper := cAux
	endif
	
	cAux := HttpGet->oper
	if !empty(cAux) .and. !(dwVal(cAux) == OP_NONE)
		acOper := cAux
	endif
	
	cAux := HttpSession->subOper
	if !empty(cAux) .and. !(dwVal(cAux) == OP_NONE)
		acOper := cAux
	endif
	
	acOper := dwVal(acOper)
	
	if acOper == OP_REC_EDIT
		cRet := STR0010 //###"alteração"
	elseif acOper == OP_REC_DEL
		cRet := STR0011 //###"exclusão"
	elseif acOper == OP_REC_NEW
		cRet := STR0012 //###"novo"
	endif
	
	if empty(cRet) .and. valtype(acOper) == "C"
		cRet := lower(acOper)
	endif               
	
	if !empty(cRet)		 
		cRet := " <small>(" + cRet + ")</small>"
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Function que verificará se para um registro/linha da browse, esta deverá ter
	os botões desabilitados ou não
Args: aaRowData, array, array contendo um registro/linha e em que cada subarray terá os
	campos/valores retornados pela consula da browse
      acFieldComp, string, contém o nome do campo para o qual será feita a verificação
      axValueCompDisable, valor do campo, contém o valor para o campo que deverá ser verificado.
      acOperador, string, contém o operador utilizado na comparação. Default: operador ==
      anIndexData, numérico, contém o index do qual deverá ser recuperado o valor do aaRowData
 	para a comparação. Default: 2
--------------------------------------------------------------------------------------
*/
function procRowsVisually(aaRowData, acFieldComp, axValueCompDisable, acOperador, anIndexData)
	
	Local nPos
	Local lResult := .F.
	
	default acOperador 	:= " == "
	default anIndexData	:= 2
	
	nPos := aScan(aaRowData, {|aElem| upper(acFieldComp) == upper(aElem[FLD_NAME])})
	if nPos > 0 .and. &(DwStr(aaRowData[nPos][anIndexData]) + acOperador + DwStr(axValueCompDisable))
		lResult := .T.
	endif
	
return lResult

/*
--------------------------------------------------------------------------------------
Monta browse para apresentação de dados, com paginação
Args:
--------------------------------------------------------------------------------------
*/
function buildBrowse(acTitle, alForEdit, acTableName, aaShowFields, aaOrderFields, aaKeyField, abProcRow, aaWhere, aaButtons, anRows, acActionManut, acActionBrowse, aaOperButtons, acWarning, abProcFields, alIsInitTable, aaFuncionButtons, anMaxRecords, alShowNew, acSubmitParmsJS, aaActionParams, alDistinctRecords, abViewProcRow)
	local cAux, nAux, cRet := "", lFilterDW := .f., nReg := MAX_REG_POR_PAGINA
	Local aBuffer	:= {}, aBufferAux := {}, aBuffer2Aux := {}, aBuffer2 := {}, aBuffer3 := {}
	Local oTable, oBrowser
	Local nInd, nInd2, nInd3
	Local aResult, aItens	:= {}, aExtraItens := {}
	Local nCols	:= 0, aHeader, nRow := 0, aRow
	Local bFieldType, cFieldType, cField
	Local lOrder, cImgOrder := "", cAllFields := ""
	Local bConcatFields := {|aElem| iif (empty(cAllFields), ;
														cAllFields := '"' + aElem[FLD_NAME] + '"', ;
														cAllFields += ',"' + aElem[FLD_NAME] + '"')}
	Local aQBE := {}, aQBEField, aFields, aField
	Local cBrowserAction, aOperButtons, aOperBtn, aAux
	Local cWhere := "", cShowField, lVisible
	Local cCRUDOper := AC_REC_MANUT, cImage, cLabel
	Local aColumnSizes	:= {}, nColumnSize, nPos, nTableSize := 0
	Local lPrinting := .F., cBrowseExtraCSS := ""
	local aCustomFields := {}, aOperMenu := {}
	local lImgDisabled := .F.
	local nWidthOper, lOperCols := .f.
  	local oXML
  	local oRow
	local cColAlign := "align='center' "
	
	Local nVisible 		:= 0 //Contados - Campos visíveis do browser.
	Local aEventos 		:= {} //Eventos do input de pesquisa.
	Local lShowQbe 		:= oSigaDw:ShowQbe() //Exibe auxílio QBE?
	Local lShowOpened	    := (oSigaDw:AutoQbe() == OPTION_APPLY_SHOWOPENED) //Exibe área de pesquisa aberta?
	Local nContCampo      := 0	// Receberá a quantidade de campos.
	Local nFldSize        := 0
	Local aNomesCamp      :={}
	
	default aaButtons         := {}
	default aaWhere           := {}
	default anRows            := nReg
	default acActionManut     := cCRUDOper
	default acActionBrowse    := AC_BROWSER
	default aaOperButtons     := {}
	default alIsInitTable     := .T.
	default aaFuncionButtons  := {}
	default alShowNew         := alForEdit
	default acSubmitParmsJS   := ""
	default aaActionParams    := {}
	default alDistinctRecords := .F.	
	
	nReg := anRows

	aEval(aaActionParams, {|aElem| acSubmitParmsJS += ("&" + dwStr(aElem[1]) + "=" + dwStr(aElem[2]))})
	
	// prepara ações de edição padrão e extras
	aOperButtons := {}
	if alForEdit
		aAux := aClone(aaActionParams)
		aAdd(aAux, {"oper", OP_REC_EDIT})
		makeOperAct(aOperButtons, STR0103, "ic_rec_edit.gif", acActionManut, aAux, TARGET_60_WINDOW, .f.) //###"Editar"
		
		aAux := aClone(aaActionParams)
		aAdd(aAux, {"oper", OP_REC_DEL})
		makeOperAct(aOperButtons, STR0104, "ic_rec_del.gif", acActionManut, aAux, TARGET_60_WINDOW, .f.) //###"Remover"
	endif
	aEval(aaOperButtons, { |x| aAdd(aOperButtons, x) })
	
	// inicializa o browser
	oBrowser := TDWBrowser():New(anRows)
	oBrowser:Warning(acWarning)
	oBrowser:IsInitTableDW(alIsInitTable)
	oBrowser:MaxRecords(anMaxRecords)
	oBrowser:DistinctRecords(alDistinctRecords)
	
	oBrowser:Table(acTableName)
	if empty(aaShowFields) .OR. empty(aaOrderFields)
		oTable := initTable(acTableName)
	endif
	
	// verifica a lista de campos a serem exibidos, caso não seja válida recupera do objeto table
	if empty(aaShowFields)
		aaShowFields := {}
		aFields      := oTable:Fields()
		for nInd := 1 to len(aFields)
			aField := aFields[nInd]
			if !(valType(aField[FLD_GET]) == "B" .or. valType(aField[FLD_SET]) == "B")
				aAdd(aaShowFields, {aField[FLD_NAME], aField[FLD_TYPE], aField[FLD_LEN], aField[FLD_DEC], aField[FLD_TITLE], aField[FLD_VISIBLE]})
			endif
		next
	endif
	
	// adiciona os campos a serem exibidos na tela
	aEval(aaShowFields, {|aField| oBrowser:addShowField(aField[FLD_NAME], aField[FLD_TYPE], aField[FLD_LEN], aField[FLD_DEC], ,aField[5])})
	
	nCols := len(aaShowFields)
	
	// caso o argumento aaOrderFields esteja inválido, recupera o index da tabela
	if empty(aaOrderFields)
		aIndex := oTable:Indexes()[2,4]
		aaOrderFieds := {}
		FOR nInd := 1 TO len(aIndex)
			// adiciona os campos de ordenação da página
			oBrowser:addOrderField(aIndex[nInd], .T.)
			aAdd(aaOrderFields, aIndex)
		NEXT
	ELSE
		aEval(aaOrderFields, {|aElem| oBrowser:addOrderField(aElem[1], aElem[2])})
	ENDIF
	
	if valType(oTable) == "O"
		lFilterDW := oTable:HaveDWField()
		oTable:Free()
	elseif alIsInitTable
		oTable 		:= initTable(acTableName)
		lFilterDW 	:= oTable:HaveDWField()
		oTable:Free()
	endif
	
	// adiciona o campo chave
	// caso não tenha sido passado como argumento os campos chaves, pega da ordenação
	IF empty(aaKeyField)
		aEval(aaOrderFields, {|aElem| oBrowser:addKeyField(aElem[1])})
	else
		aEval(aaKeyField, {|aElem| oBrowser:addKeyField(aElem)})
	ENDIF
	
	// verifica pelo filtro por id do dw
	if lFilterDW
		aAdd(aaWhere, { "ID_DW = " + dwStr(oSigaDW:DWCurrID()) })
	endif
	
	// adiciona uma claúsula where passada como parametro
	if len(aaWhere) <> 0
		oBrowser:where(DWConcatWSep(" AND ", aaWhere))
	endif
	
	// recupera a ação e o seu valor (quando necessário)
	cAcao 				:= HttpGet->acao
	cValorAcao	    	:= HttpGet->valorAcao

	/*Trata a pesquisa por QBE*/
	if cAcao == QUERY_QBE
		/*Recupera todos os conjuntos CHAVE|VALOR passados como argumento na URL.*/
		aQBE := DWToken(isNull(HttpGet->QBEfield, ""), ',', .F., .T.)
		
		for nInd := 1 TO len(aQBE)
			/*Recupera, individualmente, cada conjunto CHAVE|VALOR passado como argumento na URL.*/ 
			aQBEField := DWToken(aQBE[nInd], "§", .F., .T.)
			/*A chave DTx identifica uma data completa no formato DD/MM/AAAA.*/
			If ( allTrim(aQBEField[1]) == "DTx" )                     
				/*Transforma a data para AAAAMMDD*/
				aQBEField[1] := "DT"
				aQBEField[2] := DToS(CtoD(aQBEField[2]))		
			EndIf	        
		     /*Adiciona a restrição no browser.*/
			oBrowser:addQBE(allTrim(aQBEField[1]), aQBEField[2])
		next
	endif
	
	//prepara a ação requisitada
	oBrowser:tratarAcao(cAcao, cValorAcao)
	
	// executa a pesquisa e recupera o resultado
	aResult := oBrowser:executarQuery(cAcao, cValorAcao, abProcRow)
	if nReg < oBrowser:NumberRecordsPag()
		nReg := oBrowser:NumberRecordsPag()
	endif
	
	// verifica se está em modo de impressão
	if !dwIsFlex()
		
		lPrinting := oBrowser:isPrinting()
		if lPrinting
			cBrowseExtraCSS += "_preview"
		else
			makeToolBar(aItens, oBrowser:ShowAllRecords(), oBrowser:CurrentPage(), ;
			oBrowser:TotalPage(), acActionBrowse, acSubmitParmsJS, ;
			alShowNew, acActionManut)
			
			makeExtraToolbar(aExtraItens, oBrowser:Warning(), acActionBrowse, "" )
			aEval(aaButtons, { |x| aAdd(aExtraItens, x) })
			
			// adiciona os botões passados como parâmetros aos botões de funcionalidades
			if len(aaFuncionButtons) > 0
				for nInd := 1 to len(aaFuncionButtons)
					aAdd(aItens, aaFuncionButtons[nInd])
				next
			endif
		endif
		
		aAdd(aBuffer, '<!-- buildBrowse -->')
		
		// verifica se não está em modo de impressão E necessitar apresentar botões operacionais
		lOperCol := !lPrinting //.AND. len(aOperButtons) <> 0
		if lOperCol
			nCols++
		endif
		
		// verifica se não está em modo de impressão
		if !lPrinting
			// verifica se é editável, sendo assim será exibido um link para edição do registro,
			// ou se serão adicionados botões extras de edição na 1ª coluna de cada registro
			if alForEdit .or. lOperCol
				aAdd(aBufferAux, "<th class='barratitulobrowse'>"+tagImage("page_search.gif", nil, nil, STR0037, STR0038,,"js:doQBEQuery(1)")+"</th>") //###"Seleção"###"Permite a seleção de dados"
			endif
		endif
		
		// realiza um processamento para cada linha exibida,
		// passa como parâmetro o array de campos e um array com os valores de um registro (se não for
		// passado o array será reconhecido como um processamento de HEADER
		if valType(abProcFields) == "B"
			//nCols++
			eval(abProcFields, aBufferAux)
		endif
		
		// exibe os campos de headers		
		for nInd := 1 to len(aaShowFields)
			aHeader := aaShowFields[nInd]
			If !aHeader[6] // FLD_VISIBLE
				loop
			EndIf
			
			// calcula o tamanho que a coluna deverá ter
			if (len(aHeader[5]) + 4) > aHeader[FLD_LEN]
				aAdd(aColumnSizes, {aHeader[FLD_NAME], len(aHeader[5]) + 4})
			else
				aAdd(aColumnSizes, {aHeader[FLD_NAME], aHeader[FLD_LEN]})
			endif
			cLine := '<th class="barratitulobrowse" name="t'+ DwStr(nInd) +'" id="t'+ DwStr(nInd) +'">' 			
		

			//Exibe o Help QBE nos browsers de acordo com a opção escolhida no menu configurações.
			//Atenção: O id do <img/> é sequencial e representa a coluna no qual o controle está posicionado. 
			if (lShowQbe)								
				cLine += tagImage("ic_hlpqbe.gif", 16, 16, "QBE", STR0143 ,, "doShowQbe(this)", DwStr(nVisible ++ ) ) 
			EndIf	
				
			if aHeader[FLD_TYPE] == "M"
				nCols--
				loop
			endif
			if empty(aHeader[1])
				cLine += "&nbsp;"
			else
				lOrder := oBrowser:campoOrdenado(aHeader[FLD_NAME])
				if lOrder == .T.
					if oBrowser:retrieveOrder() == oBrowser:ordenarAsc()
						lOrder 		:= .F.
						cImgOrder 	:=	tagImage('tabela_ordenacao_seta_up.gif', 8, 14)
					else
						lOrder 		:= .T.
						cImgOrder 	:=	tagImage('tabela_ordenacao_seta_down.gif', 8, 14)
					endif
				else
					lOrder := .T.
					cImgOrder 	:=	tagImage('transparente.gif', 16, 16)
				endif
				aHeader[5] := DWCapitilize(aHeader[5])
				//---------------------------------------------------------------------------
				// verifica se não está em modo de impressão
				//---------------------------------------------------------------------------
				if !lPrinting
					cLine += "<a class='textotitulobrowse' href='javascript:requestData(" + makeAction(acActionBrowse, {{ "acao", ORDER_PAGE}, { "valorAcao", aHeader[FLD_NAME] }}) + ");'"
					cLine += ' onmouseover=' + ASPAS_D + "window.status='"+aHeader[5]+"';return true;" + ASPAS_D + ">"
					cLine += aHeader[5] + cImgOrder + "</a>"
				else
					cLine += '<span class="DwTitlePreview">' + aHeader[5] + cImgOrder + '</span>'
				endif
			endif
			cLine += "</th>"
			if isFireFox() .and. !aaShowFields[nInd, 6]
				aAdd(aBuffer2Aux, cLine)
			else
				aAdd(aBufferAux, cLine)
			endif
		next
		aEval(aBuffer2Aux, { |x| aAdd(aBufferAux, x) })
		aAdd(aBufferAux, '</tr>')
		aBuffer2Aux := {}
		
		//---------------------------------------------------------------------------
		// verifica se não está em modo de impressão
		//---------------------------------------------------------------------------
		If !lPrinting
			//---------------------------------------------------------------------------
			// exibe os campos de pesquisa QBE
			//---------------------------------------------------------------------------
			aAdd(aBufferAux, '<tr id="pesquisaQBE" class="pesquisaQBE' + cBrowseExtraCSS + '" style="'+displayNone(lShowOpened)+';">')

			//---------------------------------------------------------------------------
			// se o browse tiver botões para editar o regitro, adiciona uma coluna em branco para não desalinhar os campos de QBE
			//---------------------------------------------------------------------------
			If alForEdit .or. lOperCol
				cLine := "<th>"
				cLine += tagImage("ic_apply.gif", nil, nil, STR0039, STR0040,,"js:doQBEQuery(2)") //###"Aplicar"###"Aplica a seleção de dados"
				cLine += "&nbsp;"
				cLine += tagImage("ic_cancel.gif", nil, nil, STR0025, STR0041,,"js:doQBEQuery(3)") //###"Cancelar"###"Cancela a seleção de dados"
				cLine += "</th>"
				aAdd(aBufferAux, cLine)
			EndIf
			
			//---------------------------------------------------------------------------
			// se o browse um processamento de colunas, adiciona uma coluna em branco para não desalinhar os campos de QBE
			//---------------------------------------------------------------------------
			if valType(abProcFields) == "B"
				//cLine := "<th>&nbsp;</th>"
				//aAdd(aBufferAux, cLine)
			endif
			for nInd := 1 to len(aaShowFields)
				aHeader := aaShowFields[nInd]
				
				If !aHeader[6] // FLD_VISIBLE
					loop
				EndIf
				
				cLine := '<th>'
				if aHeader[FLD_TYPE] == "M"
					loop
				endif
				if empty(aHeader[FLD_NAME])
					cLine += "&nbsp;"
				else
					eval(bConcatFields, aHeader) 
					
				 	if (oSigaDw:AutoQbe() != OPTION_NOTAPPLY )				
				   		aEventos := {{ "onKeyUp", "doKeyUp(this)" }} 
				  	endIf    
    		                    
            		Aadd(aEventos, { "onBlur", "doBlur(this)" })        
	
					cLine += tagInput("pesquisar" + aHeader[FLD_NAME], aHeader[FLD_LEN], "", aEventos , 255)
				endif
				cLine += "</th>"
				if isFireFox() .and. !aaShowFields[nInd, 6]
					aAdd(aBuffer2Aux, cLine)
				else
					aAdd(aBufferAux, cLine)
				endif
			next
			aEval(aBuffer2Aux, { |x| aAdd(aBufferAux, x) })
			aBuffer2Aux := {}
			aAdd(aBufferAux, '</tr>')
		EndIf
		aAdd(aBufferAux, '</thead>')   
		aAdd(aBufferAux, '<tbody>')
		
		nRow := 0
		while nRow < len(aResult) .OR. nRow < nReg
			nRow++
			
			// caso exista menos registros do que a quantidade de linhas a exibir, será exibida linha "em branco"
			if len(aResult) < nRow
				aAdd(aBufferAux, '<tr class="zebra'+iif(mod(nRow, 2) == 0, "On","Off") + cBrowseExtraCSS + '" onMouseOver="makeRollover(this, true);" onMouseOut="makeRollover(this, false);">')
				
				aNomesCamp := {}
				
				For nInd := 1 To nCols - 1
					If !aaShowFields[nInd, 6] // FLD_VISIBLE						
						loop
					EndIf
					
					aAdd(aNomesCamp, DwStr(nInd))					
				Next nInd
				
				for nInd := 1 to nCols
				
					if isFireFox() .and. nInd < len(aaShowFields) .and. !aaShowFields[nInd, 6]							
						aAdd(aBuffer2Aux, '<td name="t'+ iif (nInd > Len(aNomesCamp), "", aNomesCamp[nInd]) +'" id="t'+ iif (nInd > Len(aNomesCamp), "", aNomesCamp[nInd]) +'">&nbsp;</td>')						
					else
						aAdd(aBufferAux, '<td name="t'+ iif (nInd > Len(aNomesCamp), "", aNomesCamp[nInd]) +'" id="t'+ iif (nInd > Len(aNomesCamp), "", aNomesCamp[nInd]) +'">&nbsp;</td>')				
					endif
				next
				aEval(aBuffer2Aux, { |x| aAdd(aBufferAux, x)})
				aBuffer2Aux := {}
				aAdd(aBufferAux, '</tr>')
				loop
			endif
			
			aAdd(aBufferAux, '<tr class="zebra'+iif(mod(nRow, 2) == 0, "On","Off") + cBrowseExtraCSS + '" onMouseOver="makeRollover(this, true);" onMouseOut="makeRollover(this, false);">')
			
			aRow := aResult[nRow]
			
			if !(valType(aRow) == "A") .or. !(valType(aRow[1]) == "A")
				exit
			endif
			
			// realiza um processamento para cada linha exibida,
			// passa como parâmetro o array de campos e um array com os valores de um registro (se não for
			// passado o array será reconhecido como um processamento de HEADER
			if valType(abProcFields) == "B"
				eval(abProcFields, aBufferAux, { aRow })
			endif
			
			// verifica se os botões de operações deverão estar desabilitados para esta linha/row
			if !isNull(abViewProcRow)
				lImgDisabled := eval(abViewProcRow, aRow)
			endif
			
			// verifica se não está em modo de impressão E necessitar de exibir botões de operações básicas
			if lOperCol
				cLine := '<td>'
				// botões de operação direto na linha
				for nInd := 1 to len(aOperButtons)
					aOperBtn := aOperButtons[nInd]
					if !aOperBtn[OPB_MENU]
						aAux := {{ "id", aRow[1][2] }}
						if !(valType(aOperBtn[OPB_PARAMS]) == "U")
							aEval(aOperBtn[OPB_PARAMS], { |x| aAdd(aAux, { x[1], x[2]})})
						endif
						if aOperBtn[OPB_AWS_VISIB] .OR. !lImgDisabled
							cLine += tagLinkWin(aOperBtn[OPB_ACTION], "", tagImage(aOperBtn[OPB_ICONE], 12, 12, aOperBtn[OPB_CAPTION]), aAux, aOperBtn[OPB_TARGETWIN],,,,, aOperBtn[OPB_CONFIRM])
						else
							cLine += tagImage(aOperBtn[OPB_ICONE], 12, 12, aOperBtn[OPB_CAPTION], , , , , , , lImgDisabled)
						endif
					endif
				next

				// verifica se há operação em menu e cria acesso
				if ascan(aOperButtons, { |x| x[OPB_MENU] }) > 0
					aAux := { { "id", aRow[1][2] } }
					if !(valType(aOperBtn[OPB_PARAMS]) == "U")
						aEval(aOperBtn[OPB_PARAMS], { |x| aAdd(aAux, { x[1], x[2]})})
					endif
					cAux := "{"
					aEval(aAux, { |x| cAux += x[1] + ":" + dwStr(x[2], .t.) + ","})
					cAux := strTran(cAux, ".T.", "true")
					cAux := strTran(cAux, ".F.", "false")
					cAux := substr(cAux, 1, len(cAux)-1) + "}"
					cLine += tagImage('ic_oper_menu.gif', 12, 12, STR0042, STR0043,, "doShowOperMenu("+cAux+iif(isFireFox(), ", event","")+")") //###"Mais..."###"Apresenta menu com mais operações"
				endif
				cLine += '</td>'
				aAdd(aBufferAux, cLine)
				
				// prepara menu de operações
				if ascan(aOperButtons, { |x| x[OPB_MENU] }) > 0
					if len(aOperMenu) == 0
						if isFireFox()
							aAdd(aOperMenu, '<div class="dropMenu shadow" id="operMenu" onmouseover="javascript:overpopupmenu=true;" onmouseout="javascript:overpopupmenu=false;">')
						else
#ifdef VER_P11
							aAdd(aOperMenu, '<div class="dropMenu shadow P11" id="operMenu" onmouseover="javascript:overpopupmenu=true;">')
#else
							aAdd(aOperMenu, '<div class="dropMenu shadow" id="operMenu" onmouseover="javascript:overpopupmenu=true;">')
#endif							
						endif
						aAdd(aOperMenu, '<table id="operMenuTab" summary="">')
						aAdd(aOperMenu, '<col width="15px">')
						aAdd(aOperMenu, '<col>')
						for nInd := 1 to len(aOperButtons)
							aOperBtn := aOperButtons[nInd]
							if aOperBtn[OPB_MENU]
								cLine := ""
								aAux := {{ "id", '@id' }}
								if !(valType(aOperBtn[OPB_PARAMS]) == "U")
									aEval(aOperBtn[OPB_PARAMS], { |x| aAdd(aAux, { x[1], x[2]})})
								endif
								cLine += "<tr><td></td><td>"
								cLine += tagLinkBefore(aOperBtn[OPB_ACTION], aOperBtn[OPB_CAPTION], tagImage(aOperBtn[OPB_ICONE], 12, 12, aOperBtn[OPB_CAPTION]), aAux, aOperBtn[OPB_TARGETWIN], aOperBtn[OPB_CONFIRM])
								cLine += "</td></tr>"
								//							cLine := strTran(cLine, "javascript:doLoad", "javascript:doHideMenu(this);doLoad")
								aAdd(aOperMenu, cLine)
							endif
						next
						
						aAdd(aOperMenu, '</table>')
						aAdd(aOperMenu, '</div>')
					endif
				endif
			endif
			
			for nInd2 := 1 to len(aRow)
				cLine := '<td name="t'+ DwStr(nInd2) +'" id="t'+ DwStr(nInd2) +'">'
				
				If !aaShowFields[nInd2, 6] //FLD_VISIBLE
					loop
				EndIf
				
				nPos := aScan(aColumnSizes, { |aColumns| aColumns[1] == aRow[nInd2][1] })
				nColumnSize := aColumnSizes[nPos][2]
				
				if !(valType(aRow[nInd2]) == "A")
					exit
				endif
				
				cFieldType := oBrowser:findFieldProperty(FIELD_TYPE, aRow[nInd2][1])
				
				if cFieldType == "N"
					cLine += DWStr(aRow[nInd2][2])
				elseif cFieldType == "D"
					cLine += DwStr(CTOD(DwStr(aRow[nInd2][2])))
				elseif cFieldType == "L"
					cLine += tagImage(iif(aRow[nInd2][2], "ic_true.gif", "ic_false.gif"), 13, 13)
				elseif cFieldType == "I"
					if cFieldType == "C"
						cLine += tagImage(aRow[nInd2][2])
					else
						for nInd2 := 1 to len(aRow[2])
							aAux := dwToken(aRow[nInd2][2], "|")
							aSize(aAux,2)
							cLine += tagImage(aAux[1], nil, nil,aAux[2], nil,"margin-right:3px;")
						next
					endif
				else
					cLine += aRow[nInd2][2]
				endif
				
				if valType(aRow[nInd2][2]) == "C" .and. aRow[nInd2][2] == ""
					cLine += "&nbsp;"
				endif
				
				cLine += '</td>'
				
				if isFireFox() .and. !aaShowFields[nInd2, 6]
					aAdd(aBuffer2Aux, cLine)
				else
					aAdd(aBufferAux, cLine)
				endif
			next
			aEval(aBuffer2Aux, { |x| aAdd(aBufferAux, x)})
			aBuffer2Aux := {}
			aAdd(aBufferAux, '</tr>')
		enddo
		
		// verifica se não está em modo de impressão E necessitar apresentar botões operacionais
		if !lPrinting .and. lOperCol
			nWidthOper = max((min(len(aOperButtons), 3)+2) * 12, 50)
			nTableSize += nWidthOper
			cLine := '<col valign="top" '+cColAlign+'width="'+buildMeasure(nWidthOper)+'">'
			aAdd(aBuffer2, cLine)
		endif
		
		If lPrinting
			// Recebe a quantidade de campos que aparecerão na impressão.		
			For nInd := 1 To Len(aaShowFields)				
				aHeader := aaShowFields[nInd]
				If !aHeader[6] //FLD_VISIBLE
					loop
				EndIf			
				nContCampo++			
			Next nInd			
			
			// Largura (width) que as colunas terão.
			nFldSize := Round(int(HttpSession->Screen[SCREEN_WIDTH] * 0.8) / nContCampo, 0)					
			
		EndIf
		
		For nInd := 1 to len(aaShowFields)
			aHeader := aaShowFields[nInd]
			If !aHeader[6] //FLD_VISIBLE
				loop
			EndIf
			cLine := ''
			if aHeader[3] > 0 .or. aHeader[2] <> "C"
				cLine += '<col name="t'+ DwStr(nInd) +'" valign="top"'
				if aHeader[2] == "C" .or. aHeader[2] == "M"
				elseif aHeader[2] == "N"
					cLine += " align='right'"
				else
					cLine += " align='center'"
				endif
				
				nPos := aScan(aColumnSize, { |aElem| aElem[1] == aHeader[1] })
				
				aColumnSize[nPos][2] *= TAM_PIXEL_ATT
				
				If !lPrinting
					cLine += " style='
					
					if !aaShowFields[nInd, 6]
						cLine += displayNone()
					else
						If lPrinting
							cLine += "width:" + DwStr(nFldSize) +"px;"
						Else
							cLine += "width:" + buildMeasure(aColumnSize[nPos][2] + 5)+";"
						EndIf
						nTableSize += aColumnSize[nPos][2] + 5
					endif
					
					cLine += "'>"
				EndIf
			endif
			
			if isFireFox() .and. !aaShowFields[nInd, 6]
				aAdd(aBuffer3, cLine)
			else
				aAdd(aBuffer2, cLine)
			endif
		Next
		aEval(aBuffer3, { |x| aAdd(aBuffer2, x)})
		aBuffer3 := {}
		
		// verifica se não está em modo de impressão
		if !lPrinting
			aEval(aExtraItens, { |x| aAdd(aItens, x)})
			buildToolbar(aBuffer, aItens, cBrowseExtraCSS)
			makeCustomField(aCustomFields, 'toolbar', dwConcatWSep(CRLF, aBuffer))
			aBuffer := {}
		endif
		
		aAdd(aBuffer, '<!-- buildBrowse browse start -->')
		nAux := int(HttpSession->Screen[SCREEN_WIDTH] * 0.8)
		if nTableSize < nAux
			nAux := nTableSize+20
		endif
		
		cAux := "width:" + buildMeasure(1)
		aAdd(aBuffer, '<div id="divBrowser" style="'+cAux+'" class="form_browse' + cBrowseExtraCSS + iif (!HttpSession->FolderMenu, "_tree", "") + '">')
		
		If lPrinting
			aAdd(aBuffer, '<table border="1">')
		Else		
			aAdd(aBuffer, '<table summary="" style="width:'+buildMeasure(nTableSize)+'" id="buildBrowseData" class="browse' + cBrowseExtraCSS + iif (!HttpSession->FolderMenu, "_tree", "") + '" cellpadding="3" border=1 ' + iif (lPrinting, ' style="width:' + buildMeasure(nTableSize) + '"', '') + '>')
		EndIf
		
		aEval(aBuffer2, { |x| aAdd(aBuffer, x) })
		
		aAdd(aBuffer, '<thead>')
		aAdd(aBuffer, '<tr>')
		
		aEval(aBufferAux, { |x| aAdd(aBuffer, x) })
		
		aAdd(aBuffer, '</tbody>')
		aAdd(aBuffer, '</table>')
		
		aAdd(aBuffer, '</div>')
		aAdd(aBuffer, '<!-- buildBrowse browse end 1 -->')
		
		if len(aExtraItens) > 0
			aAdd(aBuffer, '<!-- buildBrowse extrabutton begin -->')
			aAdd(aBuffer, '<div id="divToolbarInferior" class="toolbar_normal' + cBrowseExtraCSS + '">')
			// cria a div responsável por exibir a descrição da pesquisa QBE
			if !lPrinting// .OR. !empty(oBrowser:getQBEInHtml())
				makeSpecialToolbar(aExtraItens, '<div id="divQBE"' + iif (lPrinting, ' style="width=' + buildMeasure(nTableSize) + '"', '') + ' class="form_qbe' + cBrowseExtraCSS + '">' + oBrowser:getQBEInHtml() + '</div>') //nowrap
			endif
			
			for nInd := 1 to len(aExtraItens)
				aItem := aExtraItens[nInd]
				if aItem[NAV_LABEL] == NAV_SPECIAL
					aAdd(aBuffer, '<div '+aItem[NAV_ALIGN]+'>'+aItem[NAV_ICONE])
					aAdd(aBuffer, '<span class="toolbar_label' + cBrowseExtraCSS + '">&nbsp;</span></div>')
				elseif empty(aItem[NAV_ACTION])
					aAdd(aBuffer, '<div '+aItem[NAV_ALIGN]+'>'+aItem[NAV_ICONE])
					aAdd(aBuffer, '<span class="toolbar_label' + cBrowseExtraCSS + '">'+aItem[NAV_LABEL]+'</span></div>')
				endif
			next
			aAdd(aBuffer, '</div>')
			
			aAdd(aBuffer, '<!-- buildBrowse extrabutton end -->')
		endif
		
		if !lPrinting
			aAdd(aBuffer, '<!-- buildOperMenu Start -->')
			aEval(aOperMenu, { |x| aAdd(aBuffer, x) })
			aAdd(aBuffer, '<!-- buildOperMenu End -->')
		endif
		
		aAdd(aBuffer, '<!-- buildBrowse body end -->')
				   
		aAdd(aBuffer, '<!-- buildBrowse DivQBE start-->')
		aAdd(aBuffer, buildExQBE())
		aAdd(aBuffer, '<!-- buildBrowse DivQBE end -->')

		if lPrinting
			aAdd(aBuffer, '<div id="toolbar_preview" class="toolbar_preview">')
			aAdd(aBuffer, makeButton(NIL, BT_PRINT))
			aAdd(aBuffer, makeButton(NIL, BT_CLOSE))
			
			aAdd(aBuffer, "<br>" + makeAttenton(NIL, STR0044)) //####"Recomendamos impressão orientada como 'Landscape' (ou 'Deitada')."
			aAdd(aBuffer, "<br>" + makeAttenton(NIL, STR0045 + tagImage("zoom_plus.gif", , , STR0046, STR0046, , 'zoomIn(getElement("buildBrowseData"))'))) //###"Se necessário, utilize-se do zoom para aumentar "###"Aumentar zoom da listagem"
			aAdd(aBuffer, makeAttenton(NIL, STR0047 + tagImage("zoom_reset.gif", , , STR0048, STR0048, , 'zoomReset(getElement("buildBrowseData"))'))) //###" ou normal "###"Listagem em tamanho real"
			aAdd(aBuffer, makeAttenton(NIL, STR0049 + tagImage("zoom_minus.gif", , , STR0050, STR0050, , 'zoomOut(getElement("buildBrowseData"))') + ' a tabela.')) //###" ou diminuir "###"Diminuir zoom da listagem"
			aAdd(aBuffer, '</div>')
		endif
		
		// funções JavaScript
		aAdd(aBuffer, tagJS())		         		
		         		
		aAdd(aBuffer, 'var campos = new Array(' + cAllFields + ');')     
		aAdd(aBuffer, 'var inter = null;')
		
		If lPrinting	
			aAdd(aBuffer, 'var showMode = "table-cell";')
			aAdd(aBuffer, 'if (document.all) showMode="block";')
				
			aAdd(aBuffer, 'var cells = document.getElementsByName("t");')
			aAdd(aBuffer, 'for(j = 0; j < cells.length; j++) cells[j].style.display = "none";')
			
			// Parametriza impressão específica para conexões.
			If acTableName == TAB_CONEXAO				
				aAdd(aBuffer, 'var cells_quatro = document.getElementsByName("t6");')
				aAdd(aBuffer, 'for(j = 0; j < cells_quatro.length; j++) cells_quatro[j].style.width = "130px";')				
			EndIf					
		EndIf
		
		//Exibe a tela de auxílio Qbe.       	
		aAdd(aBuffer, 'function doShowQbe(oSource)')
		aAdd(aBuffer, '{') 
		aAdd(aBuffer, 		'showHlpQbe(false, getElement( "pesquisar" + campos[oSource.id]), hlpQbe_onafterapply);')
		aAdd(aBuffer, '}')
		          
        //Executa a função doQBEQuery quando houver um intervalo de 2 segundos na digitação do termo procurado.        
		aAdd(aBuffer, 'function doKeyUp(oSource) ')
		aAdd(aBuffer, '{') 	
		aAdd(aBuffer, ' 	clearTimeout(inter); ')	
		aAdd(aBuffer, '	  	inter = setTimeout("doQBEQuery(2, true)",2000); ')	
   		aAdd(aBuffer, '}')      
                       
        //Função executada após a aplicação do QBE por meio da tela de auxílio. 
		aAdd(aBuffer, 'function hlpQbe_onafterapply(alApply)')
		aAdd(aBuffer, '{')     
		aAdd(aBuffer, ' if (alApply) {')     
		aAdd(aBuffer, '  doQBEQuery(2);')
		aAdd(aBuffer, '  }')                     
		aAdd(aBuffer, ' }')  
       
		// função JavaScript para pesquisar através de QBE 
		// Parametros: 	acAction - Ação a ser realizada (1,2 ou 3). 
		//				bAuto	 - Execução automárica.  
		aAdd(aBuffer, 'function doQBEQuery(acAction, bAuto)')
		aAdd(aBuffer, '{')		
		aAdd(aBuffer, '  if (acAction == 1)') //apresenta a caixa do QBE
		aAdd(aBuffer, '  {')
		aAdd(aBuffer, '    var oQBE = getElement("pesquisaQBE");')
		aAdd(aBuffer, '    if (isElementVisible(oQBE))')
		aAdd(aBuffer, '      hideElement(oQBE)')
		aAdd(aBuffer, '    else')
		aAdd(aBuffer, '      showElementQBE(oQBE);')
		aAdd(aBuffer, '  } else')
		aAdd(aBuffer, '  {') 		
		aAdd(aBuffer, '  var concatCampos = "";')
		aAdd(aBuffer, '  if (acAction == 3)') // limpa a seleção
		aAdd(aBuffer, '  {')
		aAdd(aBuffer, '     for (i = 0; i < campos.length; i++)')
		aAdd(aBuffer, '       getElement("pesquisar" + campos[i]).value = "";')
		aAdd(aBuffer, '  } else') 		
		aAdd(aBuffer, '  {')    		
		aAdd(aBuffer, ' 	 var re = /[\<\>\|\/\-]|(^nao)|(^vazio)|(^\.\.)|(\.\.$)|(^=)/gi; ')  
		aAdd(aBuffer, ' 	 var cConteudo = ""; ') 					
		aAdd(aBuffer, '      for (i = 0; i < campos.length; i++)')
		aAdd(aBuffer, '        if (allTrim(getElement("pesquisar" + campos[i])) != "")')	   
		aAdd(aBuffer, ' 		 {')                                                   
		aAdd(aBuffer, ' 		    var campo = (getElement("pesquisar" + campos[i]).value); ')	
									/*Trata a existência de campos sem valor definido*/
		aAdd(aBuffer, ' 		    if( campo != undefined)')
		aAdd(aBuffer, ' 		 	{')     				                             
		aAdd(aBuffer, ' 		    	if(campo.match(re))')
		aAdd(aBuffer, ' 		 		{') 		
		aAdd(aBuffer, '						cConteudo = campos[i] + "§" + (getElement("pesquisar" + campos[i]).value);   ')		
											/*Realiza a substituição de ',', utilizado para tokenizar o resultado, por '.'*/ 
		aAdd(aBuffer, '             		concatCampos += "&QBEfield=" + cConteudo.replace(/\,/g, "."); ') 
       	aAdd(aBuffer, '  		    	} else') 
        aAdd(aBuffer, '             	{')		 
        aAdd(aBuffer, '						cConteudo = campos[i] + "§" + ".." + (getElement("pesquisar" + campos[i]).value) + "..";')				
								   			/*Realiza a substituição de ',', utilizado para tokenizar o resultado, por '.'*/ 	    
	    aAdd(aBuffer, '             		concatCampos += "&QBEfield=" + cConteudo.replace(/\,/g, "."); ') 
		aAdd(aBuffer, '             	}')
		aAdd(aBuffer, '             }')		
		aAdd(aBuffer, '          }')   								
		aAdd(aBuffer, '      	 if (concatCampos == "")')
		                               
		
		if (oSigaDw:AutoQbe() == OPTION_NOTAPPLY )	
	   		aAdd(aBuffer, '     	 {')
			aAdd(aBuffer, '        		alert("' + STR0051 + '");') //###"Favor preencher ao menos um campo para seleção."
			aAdd(aBuffer, '        		return;')
	   		aAdd(aBuffer, '      	 }') 
		else
			aAdd(aBuffer, '     	 {')
			aAdd(aBuffer, '       		doQBEQuery(3);')  
			aAdd(aBuffer, '       		return;')
	   		aAdd(aBuffer, '      	 }') 		
		endIf 		       
		
		aAdd(aBuffer, '    }')     
	   	aAdd(aBuffer, '    var oBrowser = getElement("buildBrowseData");')
	   	aAdd(aBuffer, '    var oBody = oBrowser.tBodies[0];') 
		aAdd(aBuffer, '    requestData(' + makeAction(acActionBrowse, { {"acao", QUERY_QBE } }) + '+ concatCampos, oBody);')
		aAdd(aBuffer, '  }')
		aAdd(aBuffer, '}')	
		
		// Função JavaScript responsável por mostrar ou não o QBE de consulta na página.
		// @Param oElement elemento que receberá o tratamento de display
		// @Param alInline se for IE menor do que 10 verifica se é para colocar tipo inline ou block
		// @Since 14/04/2015
		// @Author Helio Leal
		aAdd(aBuffer, 'function showElementQBE(oElement, alInLine)')
		aAdd(aBuffer, '{')
		// Verifica se o IE que o usuário está utilizando é o IE 10, se for o display recebe vazio.
		aAdd(aBuffer, '	if (document.documentMode < 10) {')
		aAdd(aBuffer, ' 		oElement.style.display = alInLine?"inline":"block"')
		aAdd(aBuffer, '	} else {')
		aAdd(aBuffer, ' 		oElement.style.display = ""')
		aAdd(aBuffer, '	}')
		aAdd(aBuffer, '}')

		// função JavaScript para ação de selecionar uma página específica da paginação
		aAdd(aBuffer, '	function doSelectPage(acParams) {')
		aAdd(aBuffer, '		if (allTrim(getElement("edSelPag").value) == ""')
		aAdd(aBuffer, '				|| getElement("edSelPag").value.indexOf("/") > -1')
		aAdd(aBuffer, '					|| isNaN(parseInt(getElement("edSelPag").value))) {')
		aAdd(aBuffer, '			alert("' + STR0110 + '");') //###"Por favor, informe um número válido da página a ser selecionada"
		aAdd(aBuffer, '			getElement("edSelPag").focus();')
		aAdd(aBuffer, '			return false;')
		aAdd(aBuffer, '		}')
		
		aAdd(aBuffer, '		requestData(' + makeAction(acActionBrowse, { {"acao", SELCT_PAGE} }) + ' + "&valorAcao=" + getElement("edSelPag").value + acParams);')
		aAdd(aBuffer, '	}')
		
		// função JavaScript para requisição de uma ação "por baixo dos panos"
		aAdd(aBuffer, "function requestData(action, aoTarget)")
		aAdd(aBuffer, "{")
		aAdd(aBuffer, "  var re = /&amp;/gi;")
		aAdd(aBuffer, "  try {")
		aAdd(aBuffer, "  	u_controlBrowseRequest(action.replace(re, '&'), aoTarget);")
		aAdd(aBuffer, "  } catch (err) {")
		aAdd(aBuffer, "  	showWait();")
		aAdd(aBuffer, "  	doRequestData(action.replace(re, '&'), aoTarget, endRequestData);")
		aAdd(aBuffer, "  }")
		aAdd(aBuffer, "	}")
		
		aAdd(aBuffer, "function endRequestData()")
		aAdd(aBuffer, "{")
		aAdd(aBuffer, "	 hideWait();")
		aAdd(aBuffer, '}')
		
		// função JavaScript para ação de selecionar uma página específica da paginação
		aAdd(aBuffer, 'function doAllRecords()')
		aAdd(aBuffer, '{')
		aAdd(aBuffer, '	 var nPag = getElement("edSelPag");')
		aAdd(aBuffer, '	 var cURL = location.href;')
		aAdd(aBuffer, '	 cURL = prepParam(cURL, "acao", "'+QUERY_ALLRECORDS+'")')
 		aAdd(aBuffer, '	 cURL = prepParam(cURL, "valorAcao", nPag)')
		aAdd(aBuffer, '	 requestData(cURL);')
		aAdd(aBuffer, '}')
		
		// função JavaScript para impressão da browser
		aAdd(aBuffer, '	function doPrint() {')
		aAdd(aBuffer, '		hideElement(getElement("toolbar_preview"));')		
		aAdd(aBuffer, '		window.print();')
		aAdd(aBuffer, '		showElement(getElement("toolbar_preview"));')
		aAdd(aBuffer, '	}')		
		
		aAdd(aBuffer, '</script>')
		
		makeCustomField(aCustomFields, 'browse', dwConcatWSep(CRLF, aBuffer))

		HttpSession->subOper 	:= NIL
		HttpGet->oper			:= NIL
		
		// Se for impressão adiciona o último parâmetro na função.
		If lPrinting		
			cRet := buildForm("frm" + acTableName, acTitle, "@"+makeAction(acActionBrowse, { { "acao", QUERY_QBE } }), ;
			""/*acOper*/, aaButtons, aCustomFields /*aaParams*/, alForEdit, /*acAlign*/, /*abBody*/, ;
			/*abSubmit*/, .f./*alCheckList*/, /*aaCols*/, /*cBrowserCSS*/, .f. /*alBottom*/, ;
			/*acDivID*/, /*aaOperButtons*/, /*acEncyType*/, aItens /*aaToolBar*/, "get" /*acMethod*/, , , , , , .T., )		
		Else		
			cRet := buildForm("frm" + acTableName, acTitle, "@"+makeAction(acActionBrowse, { { "acao", QUERY_QBE } }), ;
			""/*acOper*/, aaButtons, aCustomFields /*aaParams*/, alForEdit, /*acAlign*/, /*abBody*/, ;
			/*abSubmit*/, .f./*alCheckList*/, /*aaCols*/, /*cBrowserCSS*/, .f. /*alBottom*/, ;
			/*acDivID*/, /*aaOperButtons*/, /*acEncyType*/, aItens /*aaToolBar*/, "get" /*acMethod*/)		
		EndIf
		
	else // prepara o XML para o flex
    aXML := {}

		nRow := 0
		while nRow < len(aResult) .and. nRow < nReg
			nRow++  
			
			aRow := aResult[nRow]
			
			if !(valType(aRow) == "A") .or. !(valType(aRow[1]) == "A")
				exit
			endif
      oRow := TBIXMLNode():New("row")
      aAdd(aXML, oRow)
			
			// verifica se os botões de operações deverão estar desabilitados para esta linha/row
			if !isNull(abViewProcRow)
				lImgDisabled := eval(abViewProcRow, aRow)
			endif
			
/*
			// verifica se não está em modo de impressão E necessitar de exibir botões de operações básicas
			if lOperCol
				cLine := '<td>'
				// botões de operação direto na linha
				for nInd := 1 to len(aOperButtons)
					aOperBtn := aOperButtons[nInd]
					if !aOperBtn[OPB_MENU]
						aAux := {{ "id", aRow[1][2] }}
						if !(valType(aOperBtn[OPB_PARAMS]) == "U")
							aEval(aOperBtn[OPB_PARAMS], { |x| aAdd(aAux, { x[1], x[2]})})
						endif
						if aOperBtn[OPB_AWS_VISIB] .OR. !lImgDisabled
							cLine += tagLinkWin(aOperBtn[OPB_ACTION], "", tagImage(aOperBtn[OPB_ICONE], 12, 12, aOperBtn[OPB_CAPTION]), aAux, aOperBtn[OPB_TARGETWIN],,,,, aOperBtn[OPB_CONFIRM])
						else
							cLine += tagImage(aOperBtn[OPB_ICONE], 12, 12, aOperBtn[OPB_CAPTION], , , , , , , lImgDisabled)
						endif
					endif
				next
				
				// verifica se há operação em menu e cria acesso
				if ascan(aOperButtons, { |x| x[OPB_MENU] }) > 0
					aAux := { { "id", aRow[1][2] } }
					if !(valType(aOperBtn[OPB_PARAMS]) == "U")
						aEval(aOperBtn[OPB_PARAMS], { |x| aAdd(aAux, { x[1], x[2]})})
					endif
					cAux := "{"
					aEval(aAux, { |x| cAux += x[1] + ":" + dwStr(x[2], .t.) + ","})
					cAux := strTran(cAux, ".T.", "true")
					cAux := strTran(cAux, ".F.", "false")
					cAux := substr(cAux, 1, len(cAux)-1) + "}"
					cLine += tagImage('ic_oper_menu.gif', 12, 12, STR0042, STR0043,, "doShowOperMenu("+cAux+iif(isFireFox(), ", event","")+")") //###"Mais..."###"Apresenta menu com mais operações"
				endif
				cLine += '</td>'
				aAdd(aBufferAux, cLine)
				
				// prepara menu de operações
				if ascan(aOperButtons, { |x| x[OPB_MENU] }) > 0
					if len(aOperMenu) == 0
						if isFireFox()
							aAdd(aOperMenu, '<div class="dropMenu shadow" id="operMenu" onmouseover="javascript:overpopupmenu=true;" onmouseout="javascript:overpopupmenu=false;">')
						else
#ifdef VER_P11
							aAdd(aOperMenu, '<div class="dropMenu shadow P11" id="operMenu" onmouseover="javascript:overpopupmenu=true;">')
#else							
							aAdd(aOperMenu, '<div class="dropMenu shadow" id="operMenu" onmouseover="javascript:overpopupmenu=true;">')
#endif							
						endif
						aAdd(aOperMenu, '<table id="operMenuTab" summary="">')
						aAdd(aOperMenu, '<col width="15px">')
						aAdd(aOperMenu, '<col>')
						for nInd := 1 to len(aOperButtons)
							aOperBtn := aOperButtons[nInd]
							if aOperBtn[OPB_MENU]
								cLine := ""
								aAux := {{ "id", '@id' }}
								if !(valType(aOperBtn[OPB_PARAMS]) == "U")
									aEval(aOperBtn[OPB_PARAMS], { |x| aAdd(aAux, { x[1], x[2]})})
								endif
								cLine += "<tr><td></td><td>"
								cLine += tagLinkBefore(aOperBtn[OPB_ACTION], aOperBtn[OPB_CAPTION], tagImage(aOperBtn[OPB_ICONE], 12, 12, aOperBtn[OPB_CAPTION]), aAux, aOperBtn[OPB_TARGETWIN], aOperBtn[OPB_CONFIRM])
								cLine += "</td></tr>"
								//							cLine := strTran(cLine, "javascript:doLoad", "javascript:doHideMenu(this);doLoad")
								aAdd(aOperMenu, cLine)
							endif
						next
						
						aAdd(aOperMenu, '</table>')
						aAdd(aOperMenu, '</div>')
					endif
				endif
			endif
*/			
			for nInd2 := 1 to len(aRow)
				oRow:oAddChild(TBIXMLNode():New(aRow[nInd2][1], DWTrataExpXML(DWStr(aRow[nInd2][2]))))
			next
		enddo
		flexSend(aXML)
	endif
	
	// libera o objeto
	oBrowser:Free()

return cRet

/*
--------------------------------------------------------------------------------------
Monta formulários de edição em formato sem o desenho
Args:
--------------------------------------------------------------------------------------
*/
function buildMiniForm(acFormName, acAction, acOper, aaParams, alEdit, acIFrame, alOnlyOneColumn)
	local cSubmit := "", cAction, nInd, nInd2
	local aBuffer := {}, aParams := {}, aEvents, aEvent
	local lShowNextBtn := .T., lShowPrevBtn := .T., lShowCancBtn := .T., aAux := {}, aButtons := {}
	local lWithContainer := .f.
	local oWebApp := getWebApp()
    	
  if right(acFormName, 1) == "#"
		lWithContainer := .t.
  	acFormName := substr(acFormName, 1, len(acFormName)-1)
	endif

	aAdd(aBuffer, '<!-- buildMiniForm start -->')
	
	default alEdit := !(dwVal(HttpGet->Oper) == OP_SUBMIT .or. dwVal(HttpGet->Oper) == OP_REC_DEL)
	default acOper := ""
	default acIFrame := ""
	
	cSubmit := ' onsubmit="return('+acFormName+'Submit(this))"'

	if empty(acOper)
		if left(acAction, 1) == "@"
			cAction := substr(acAction,2)
		else
			cAction := makeAction(acAction)
		endif
	else	                          
		aAdd(aParams, { "oper", acOper })
		aAdd(aParams, { "suboper", HttpSession->subOper })
		aAdd(aParams, { "jscript", CHKBOX_ON })
		if !empty(acIFrame)
		  aAdd(aParams, { "iframe", acIFrame })
		endif
		
		if acOper == OP_SUBMIT
			makeButton(aButtons, BT_SUBMIT)           
			if !(dwVal(HttpSession->subOper) == OP_REC_DEL)
				makeButton(aButtons, BT_RESET)
			endif
			//makeButton(aButtons, BT_CANCEL)
		endif
		
		cAction := makeAction(acAction, aParams)
	endif
	aAdd(aBuffer, '<form enctype="application/x-www-form-urlencoded" method="post" action='+cAction+' id="'+acFormName+'"'+cSubmit+'>')

	if oWebApp:isError()
		aAdd(aBuffer, '<div class="formMsgSrv">'+prepFormMsg(oWebApp:getMsgError())+'</div>')
	endif

	if lWithContainer
		aAdd(aBuffer, "<div class='FormContainer'>")
	endif
	if !(valType(aaParams) == "O")
		makeHotKeys(aaParams)
		buildBodyFields(aBuffer, aaParams, alEdit, .f., , EDT_HIDDEN) // somente campos hidden
		buildBodyFields(aBuffer, aaParams, alEdit, alOnlyOneColumn)
	else
		aAdd(aBuffer, '<!-- buildMiniForm objectBody ('+aaParams:classname()+') start -->')
		aaParams:Buffer(aBuffer, @alBottom)
		aAdd(aBuffer, '<!-- buildMiniForm objectBody ('+aaParams:classname()+') endt -->')
	endif
    
	if valType(aaParams) == "A" .and. ascan(aaParams, { |x| x[FFLD_EDTTYPE] == EDT_LEGEND } ) > 0
		buildBodyFields(aBuffer, aaParams, alEdit, .f., , EDT_LEGEND)
	endif

	if len(aButtons) <> 0
		aAdd(aBuffer, "<br>")
		buildButton(aBuffer, aButtons)
	endif
	
	if lWithContainer
		aAdd(aBuffer, "</div>")
	endif

	aAdd(aBuffer, '</form>')

	if !(valtype(aaParams) == "O")
		aAdd(aBuffer, tagJS())
		aAdd(aBuffer, "function "+acFormName+"Submit(oSender)")
		aAdd(aBuffer, "{")
		aAdd(aBuffer, "  var lRet = true;")
		if alEdit
			buildValidFields(aBuffer, aaParams)
		endif
	  aAdd(aBuffer, "  if (lRet)")
	  aAdd(aBuffer, "    try { lRet = lRet && " + acFormName + "_valid(oSender); } catch ( err  ) { lRet = true };")
		if ascan(aaParams, { |x| x[FFLD_EDTTYPE] == EDT_DUALLIST }) <> 0
			aAdd(aBuffer, "  if (lRet)")
			aAdd(aBuffer, "  {")
			for nInd := 1 to len(aaParams)
				if aaParams[nInd, FFLD_EDTTYPE] == EDT_DUALLIST
					aAdd(aBuffer, '    prepDualList(oSender.'+aaParams[nInd, FFLD_NAME][1]+');')     
					aAdd(aBuffer, '    prepDualList(oSender.'+aaParams[nInd, FFLD_NAME][2]+');')     
				endif
			next
			aAdd(aBuffer, "  }")
		endif

		aAdd(aBuffer, "  return lRet;")
		aAdd(aBuffer, "}")

		if ascan(aaParams, { |x| x[FFLD_EDTTYPE] == EDT_DUALLIST }) <> 0
			aAdd(aBuffer, "function moveDualList(fbox, tbox, all)")
			aAdd(aBuffer, "{")
			aAdd(aBuffer, "  var aSaveOpt = new Array();")
			aAdd(aBuffer, "  for (var nInd = 0; nInd < fbox.length; nInd++)")
			aAdd(aBuffer, "  {")
			aAdd(aBuffer, "    if ((fbox.options[nInd].selected) || (all))")
			aAdd(aBuffer, "      tbox.options[tbox.length] = new Option(fbox.options[nInd].text, fbox.options[nInd].value);")
			aAdd(aBuffer, "    else")
			aAdd(aBuffer, "      aSaveOpt[aSaveOpt.length] = new Option(fbox.options[nInd].text, fbox.options[nInd].value);")
			aAdd(aBuffer, "	 }")
			aAdd(aBuffer, "  fbox.length = 0;")
			aAdd(aBuffer, "  for (var nInd = 0; nInd < aSaveOpt.length; nInd++)")
			aAdd(aBuffer, "    fbox.options[nInd] = aSaveOpt[nInd];")
			aAdd(aBuffer, "}")

			aAdd(aBuffer, "function prepDualList(oSender)")
			aAdd(aBuffer, "{")
			aAdd(aBuffer, "  var aOptions = oSender.options;")
			aAdd(aBuffer, "  for (var nInd = 0; nInd < aOptions.length; nInd++)")
			aAdd(aBuffer, "    aOptions[nInd].selected = true;")
			aAdd(aBuffer, "  return true;")
			aAdd(aBuffer, "}")

			aAdd(aBuffer, "function ordemDualList(tbox, direction)")
			aAdd(aBuffer, "{")
			aAdd(aBuffer, "  if (!direction)")
			aAdd(aBuffer, "  {")
			aAdd(aBuffer, "    for (var nInd = 1; nInd < tbox.length; nInd++)")
			aAdd(aBuffer, "    {")
			aAdd(aBuffer, "      if ((tbox.options[nInd].selected))")
			aAdd(aBuffer, "      {")
			aAdd(aBuffer, "        var oAux = tbox.options[nInd-1];")
			aAdd(aBuffer, "        tbox.options[nInd-1] = new Option(tbox.options[nInd].text, tbox.options[nInd].value);")
			aAdd(aBuffer, "        tbox.options[nInd] = new Option(oAux.text, oAux.value);")
			aAdd(aBuffer, "        tbox.options[nInd-1].selected = true;")
			aAdd(aBuffer, "        break;")
			aAdd(aBuffer, "      }")
			aAdd(aBuffer, "    }")
			aAdd(aBuffer, "  } else")
			aAdd(aBuffer, "  {")
			aAdd(aBuffer, "    for (var nInd = 0; nInd < tbox.length - 1; nInd++)")
			aAdd(aBuffer, "    {")
			aAdd(aBuffer, "      if ((tbox.options[nInd].selected))")
			aAdd(aBuffer, "      {")
			aAdd(aBuffer, "        var oAux = tbox.options[nInd+1];")
			aAdd(aBuffer, "        tbox.options[nInd+1] = new Option(tbox.options[nInd].text, tbox.options[nInd].value);")
			aAdd(aBuffer, "        tbox.options[nInd] = new Option(oAux.text, oAux.value);")
			aAdd(aBuffer, "        tbox.options[nInd+1].selected = true;")
			aAdd(aBuffer, "        break;")
			aAdd(aBuffer, "      }")
			aAdd(aBuffer, "    }")
			aAdd(aBuffer, "  }")
			aAdd(aBuffer, "}")
		endif
	
		for nInd := 1 to len(aaParams)
			if len(aaParams[nInd]) <> BTN_SIZE_ARRAY .and. len(aaParams[nInd]) >= FFLD_EVENTS
				aEvents := aaParams[nInd, FFLD_EVENTS]
				for nInd2 := 1 to len(aEvents)
					aEvent := aEvents[nInd2]
					if len(aEvent) > 0 .and. aEvent[FFLD_FIREONINIT]
						aAdd(aBuffer, strTran(aEvent[FFLD_EVENTJS], 'this', 'getElement("'+aaParams[nInd, FFLD_NAME]+'")')+";")
					endif
				next
			endif
		next

		aAdd(aBuffer, "</script>")
    endif
    
	aAdd(aBuffer, '<!-- buildMiniForm end -->')
 
return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Monta formulários de edição em formato browse
Args: acFormName, string, nome do formulário html
      acTitle, string, titulo do formulário
      acAction, string, ação a ser executada (submit)
      acOper, string, operação a ser executada (submit)
      aaButtons, array, lista de botões a serem apresentados ao final do formulário
      aaCols, array, definição das colunas da tabela (utilize makeEditCol() para gerar os itens)
      aaFields, array, lista de dados a serem apresentados (array 2 dimensão, onde cada item e´uma linha (1d)
                       e cada elemento (2d) é o dado da respectiva coluna
      alEdit, logico, indica se é para edição (.T.) ou somente leitura (.F.)
      alBrowser, logico,
      anQtdeCols, numerico, numero de colunas (blocos) 
      aaBefFields, logico, lista de campos a serem apresentados antes da tabela (use makeField() e outras para gerar os itens)
Args:
--------------------------------------------------------------------------------------
*/
function buildFormBrowse(acFormName, acTitle, acAction, acOper, aaButtons, aaCols, aaFields, alEdit, alBrowser, anQtdeCols, aaBefFields)
	local aFields, aItens := {}
	local aValidFields := {}, cHTML
	local lBox := .t.
	local aBuffer 
		
	default aaButtons := {}
	default alEdit		:= .t.
	default alBrowser := .f.
	default anQtdeCols  := 1
	default aaBefFields := {}
			                   
	if left(acFormName, 1) == "#"
		lBox := .f.
		acFormName := substr(acFormName, 2)
	endif
	
	aFields := {}
	makeHidden(aFields, "_rowCount", len(aaFields))
	makeHidden(aFields, "_rc_" + acFormName, len(aaFields))
	aEval(aaBefFields, { |x| aAdd(aFields, aClone(x)) } )
	makeCustomField(aFields, "browse", buildEditBrowse(aaCols, aaFields, alEdit, anQtdeCols, aValidFields, lBox, acFormName+"browse"))
	
	cHTML := tagJS() + CRLF
	cHTML += 'function ' + acFormName + '_valid(oSender)' + CRLF
	cHTML += '{' + CRLF
	cHTML += '	var lRet = true;' + CRLF
	
	aEval(aValidFields, {|x| cHTML += x})
	
	cHTML += '	return lRet;' + CRLF
	cHTML += '}' + CRLF
	cHTML += '</script>' + CRLF
	makeCustomField(aFields, "edFormValid", cHTML)

	if lBox
		cHTML := buildForm(acFormName, acTitle, acAction, acOper, aaButtons, ;
               aFields /*aaParams*/, alEdit, nil /*acAlign*/, nil /*abBody*/, nil /*abSubmit*/, ;
               nil /*alCheckList*/, nil /*aaCols*/, nil /*acStyle*/, nil /*alBottom*/, nil /*acDivID*/, ;
               nil /*aaOperButtons*/, nil /*acEncyType*/, nil /*aaToolBar*/, nil /*acMethod*/, ;
               nil /*aaActionParams*/, nil /*acBorder*/, nil /*alShowMessageArea*/)	
  else
  	aBuffer := {}
  	aAdd(aBuffer, "<div id='div"+acFormName+"'>")
		buildBodyFields(aBuffer, aFields /*aaParams*/, alEdit, /*alCheckList*/, , EDT_HIDDEN) // somente campos hidden
		buildBodyFields(aBuffer, aFields /*aaParams*/, alEdit, /*alCheckList*/, , , .f.)
  	aAdd(aBuffer, "</div>")
		cHTML := dwConcatWSep(CRLF, aBuffer)
	endif
	
return cHTML

/*
--------------------------------------------------------------------------------------
Monta edição em formato browse
Args: aaCols, definição das colunas da tabela (utilize makeEditCol() para gerar os itens)
      aaFields, array, lista de dados a serem apresentados (array 2 dimensão, onde cada item e´uma linha (1d)
                       e cada elemento (2d) é o dado da respectiva coluna
      alEdit, logico, indica se é para edição (.T.) ou somente leitura (.F.)
      anQtdeCols, numerico, numero de colunas (blocos) 
      aaValidFields, array, 
      alBorder, 
      acID, string, ID do objeto HTML
Ret: string, código HTML
--------------------------------------------------------------------------------------
*/
function buildEditBrowse(aaCols, aaFields, alEdit, anQtdeCols, aaValidFields, alBorder, acID, anHeight)
	local aBuffer := {}, aHeader
 	local nColValue, nInd, nInd2, nInd3
 	local cLine, nRow := 0, nQtdCols  
 	local cTableStyle := "", nWidth
 	
	default alEdit := .t.
	default anQtdeCols := 1
	default alBorder := .t.
  	default acID := ""
  default anHeight := 0
  	
	nQtdCols := anQtdeCols

	if alBorder
		aAdd(aBuffer, '<div id="divBrowser" style="width:100%" class="form_browse">')
	else
		cTableStyle := "width:auto;border:none;height:" +iif(anHeight > 0, buildMeasure(anHeight), "auto")
		aAdd(aBuffer, '<div id="divBrowser'+acID+'"  class="form_browse" style="'+cTableStyle+'">')
//		cTableStyle := " style='width:auto;height:auto;'"
	endif

	aAdd(aBuffer, '<table summary="" ' + iif(empty(acID), '', ' id="'+acID+'" ') + 'class="browse" cellpadding="1" cellspacing="1"'+cTableStyle+'>')

	for nInd2 := 0 to nQtdCols - 1
		for nInd := 1 to len(aaCols)
			aHeader := aaCols[nInd]
			cLine := ''
			if aHeader[FFLD_LEN] > 0 .or. aHeader[FFLD_TYPE] <> "C"
				cLine += '<col '
				if aHeader[FFLD_TYPE] == "C" .or. aHeader[FFLD_TYPE] == "M"
				elseif aHeader[FFLD_TYPE] == "N"
					cLine += " align='right'"
				else
					cLine += " align='center'"
				endif        
				if aHeader[FFLD_LEN] > 0                                                 
					cAux := aHeader[FFLD_CAPTION] 
					if at("<", cAux) > 1
						cAux := substr(cAux, 1, at("<", cAux) - 1)
					endif       
        	if aHeader[FFLD_EDTTYPE] == EDT_PICTURE
						nWidth := max(aHeader[FFLD_LEN]+aHeader[FFLD_DEC],len(cAux)) * (TAM_PIXEL_ATT/2)
					else
						nWidth := (max(aHeader[FFLD_LEN]+aHeader[FFLD_DEC], len(cAux))*TAM_PIXEL_ATT)+TAM_PIXEL_ATT_AJUSTE+1
					endif
					if aHeader[FFLD_DOTBUTTON]
						nWidth += 30
					endif
					
					cLine += " width='"+buildMeasure(nWidth)+"'"
				endif
        if aHeader[FFLD_EDTTYPE] == EDT_HIDDEN
					cLine += " style='"+displayNone()+"'"
				endif
				cLine += ">"
			endif
			aAdd(aBuffer, cLine)
		next
	next 
	
	aAdd(aBuffer, '<thead>')
	aAdd(aBuffer, '<tr>')    

	// exibe os campos de headers
	for nInd2 := 0 to nQtdCols - 1
		for nInd := 1 to len(aaCols)
			aHeader := aaCols[nInd]
			cLine := "<th>" 
			if aHeader[FLD_TYPE] == "M"
				loop              
			endif
			if empty(aHeader[FFLD_CAPTION])
				cLine += "&nbsp;"
			else
				cLine += aHeader[FFLD_CAPTION] 
			endif        
			cLine += "</th>"
			aAdd(aBuffer, cLine)
		next
	next	
	aAdd(aBuffer, '</tr>')
	aAdd(aBuffer, '</thead>')
	
	aAdd(aBuffer, '<tbody>')

  nRow := 1		
 	while nRow <= len(aaFields)
		aAdd(aBuffer, '<tr id="R'+dwInt2Hex(nRow,4)+'" class="zebra'+iif(mod(nRow, 2) == 0, "On","Off")+ '">')
		
		for nInd3 := 0 to nQtdCols - 1
			nColValue := 0
			aRow := aaFields[nRow]
			for nInd2 := 1 to len(aRow)
				nColValue++
				cLine := '<td align="center">'
				aHeader := aaCols[nColValue]
				aOptions := {}                           
				if (valtype(aHeader[FFLD_OPTIONS]) == "A") .AND. len(aHeader[FFLD_OPTIONS]) > 0 ;
					.AND. valType(aHeader[FFLD_OPTIONS][1]) == "A" .AND. len(aHeader[FFLD_OPTIONS][1]) > 0 ;
					.AND. valType(aHeader[FFLD_OPTIONS][1][1]) == "A"
					aOptions := aHeader[FFLD_OPTIONS][nRow]
				else
					aOptions := aHeader[FFLD_OPTIONS]
				endif	 
				if aHeader[FFLD_EDTTYPE] == EDT_PICTURE
					cLine += tagImage(aHeader[FFLD_OPTIONS,1],aHeader[FFLD_LEN],aHeader[FFLD_LEN],STR0089,,,aHeader[FFLD_OPTIONS,2], aHeader[FFLD_NAME]+dwStr(aRow[nInd2]),,,,dwStr(aRow[nInd2]) ) //###"Remover DW"
				else
					cLine += tagInputEx(iif(aHeader[FFLD_EDTTYPE] == EDT_HIDDEN, EDT_EDIT, aHeader[FFLD_EDTTYPE]),;
					 			aHeader[FFLD_NAME]+dwInt2Hex(nRow,4), aHeader[FFLD_TYPE], ; 
								aHeader[FFLD_LEN], aHeader[FFLD_DEC], aRow[nInd2], ;
								aOptions, alEdit,;
						    aHeader[FFLD_EVENTS], , aHeader[FFLD_HOTKEY], aHeader[FFLD_KEY], , ;
						    aHeader[FFLD_DOTBUTTON], aHeader[FFLD_CHOOSE], aHeader[FFLD_DOTBTNACT], aHeader[FFLD_LEN_MAX])

					if !isNull(aaValidFields)                          
						buildValidFields(aaValidFields, {{ aHeader[FFLD_EDTTYPE], aHeader[FFLD_NAME] + dwInt2Hex(nRow,4), ;
												aHeader[FFLD_CAPTION], aHeader[FFLD_HOTKEY], aHeader[FFLD_REQUIRED], ;
												aHeader[FFLD_TYPE], aHeader[FFLD_LEN], aHeader[FFLD_DEC], ;
												aHeader[FFLD_OPERATION], aHeader[FFLD_VALUE], aHeader[FFLD_ACTION], ;
												iif (valType(aHeader[FFLD_OPTIONS]) == "A" .AND. len(aHeader[FFLD_OPTIONS]) >= nRow, aHeader[FFLD_OPTIONS][nRow], aHeader[FFLD_OPTIONS]), aHeader[FFLD_KEY], aHeader[FFLD_EVENTS] ;
												}})
					endif
	
				endif
				cLine += '</td>'
				aAdd(aBuffer, cLine)
			next
			nRow++                
			if nRow > len(aaFields)
			  exit
			endif
		next
		aAdd(aBuffer, '</tr>')
	enddo
	
	aAdd(aBuffer, '</tbody>')
	aAdd(aBuffer, '</table>')
	aAdd(aBuffer, '</div>')

	aAdd(aBuffer, '<!-- buildBrowse browse end 2 -->')
	aAdd(aBuffer, '<!-- buildBrowse body end -->')

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Monta e retorna uma tabela exibindo os dados passados como argumento
Args: aaData, array, contendo os camos a serem exibidos
		anCols, númerico, contendo o número de colunas a serem exibidas. Default 2
		aaHeader, array, contendo a descrição dos headers das colunas
		acClassName, string, contendo o nome da propriedade class utilizadas nas tags htm
		anColSize, númerico|array, contendo o tamanho das colunas desta tabela em porcentagem.
	Default: 100% / anCols = tamanho%
--------------------------------------------------------------------------------------
*/
function displayData(aaData, anCols, aaHeader, acClassName, anColSize)
	Local aBuffering 	:= ""
	Local nInd, nInd2, aAux := {}, lZebra := .f.
	local aColSize

	default anCols 			:= 2
	default aaHeader 		:= {STR0111, STR0112} //###"Campo"###"Valor"
	default acClassName 	:= ""
	
	// define o tamanho de cada coluna 100% / pelo número de colunas
	default anColSize		:= 1 / anCols

	aColSize := array(anCols)
	if valType(anColSize) == "A"
		aEval(anColSize, { |x,i| aColSize[i] := x })
	else
		aFill(aColSize, anColSize)
	endif 
	
	if !empty(acClassName)
		acClassName := "_" + acClassName
	endif
	
	aAux := aClone(aaData)
	aBuffering += '<!-- displayData -->' + CRLF
	aBuffering += '<div class="displayData' + acClassName + '">' + CRLF
		
	//aBuffering += '<table summary="" class="displayData' + acClassName + '" border=1 borderColorDark=#ffffff borderColorLight=#ACC4DD>' + CRLF
	aBuffering += '<table summary="" class="displayData' + acClassName + '" border=1>' + CRLF
	for nInd := 1 to len(aColSize)
		aBuffering += "<col width="+buildMeasure(aColSize[nInd]) +">" + CRLF
	next
	aBuffering += '<thead><tr>' + CRLF
	for nInd := 1 to len(aaHeader)
		if nInd == len(aaHeader) .and. nInd < anCols
			aBuffering += '<td colSpan="' + DwStr(anCols - nInd + 1) + '">' + aaHeader[nInd] + '</td>' + CRLF
		else
			aBuffering += '<td>' + aaHeader[nInd] + '</td>' + CRLF
		endif
	next

	aBuffering += '</tr></thead><tbody>' + CRLF
	
	for nInd := 1 to len(aAux)
		lZebra := !lZebra
		aBuffering += '<tr class="zebra' + iif(lZebra, 'On', 'Off') + acClassName + '">' + CRLF
		
		if anCols == 1
			aBuffering += '<td>' + dwStr(aAux[nInd]) + '</td>' + CRLF
		elseif valType(aAux[nInd]) == "A"
			if len(aAux[nInd]) == 1
				aBuffering += '<td colspan="' + DwStr(anCols) + '">' + DwStr(aAux[nInd][1]) + '</td>' + CRLF
			elseif len(aAux[nInd]) > 1
				for nInd2 := 1 to len(aAux[nInd])
					aBuffering += '<td>&nbsp;' + DwStr(aAux[nInd][nInd2]) + '</td>' + CRLF
				next
			endif
		else
			nInd2 := 1
			// exibe os registros em colunas até completar o número de colunas (anCols)
			while nInd2 <= anCols
				if nInd <= len(aAux)
					aBuffering += '<td>&nbsp;' + dwStr(aAux[nInd]) + '</td>' + CRLF
				else
					aBuffering += '<td>&nbsp;</td>' + CRLF
				endif
				
				nInd++
				nInd2++
			enddo
			
			if nInd2 > 0
				nInd--
			endif
		endif
		
		aBuffering += '</tr>' + CRLF
	next
	
	aBuffering += '</tbody></table>' + CRLF
	
	aBuffering += '</div>' + CRLF
	
return aBuffering

/*
--------------------------------------------------------------------------------------
Monta uma janela com o formato de impressão
Args: aaComponents, array de array, contendo as componentes a serem exibidos na tela
		aaButtons, array de array, contendo os botões a serem exibidos na janela. Opcional:
			senão for passados nada, serão exibidos os botões de print (imprimir) e close (fechar)
		alShowDefaultButtons, booleano, opção para exibir ou não os botões default. Opcional
--------------------------------------------------------------------------------------
*/
function buildPrint(aaComponents, aaButtons, alShowDefaultButtons)
	
	Local aBuffer		:= {}
	
	default aaButtons := { {BT_PRINT, "acText", "acAction"}, {BT_CLOSE, "acText", "acAction"} }
	default alShowDefaultButtons := .T.
	
	aAdd(aBuffer, '<div id="divPrint" class="divPrint">')
	
	aAdd(aBuffer, '	<div id="divComponents">')
	aAdd(aBuffer, '	<table summary=""  id="tablePrint">')
	
	// constroi os componentes html
	buildBodyFields(aBuffer, aaComponents, .F., .T., "print")
	
	aAdd(aBuffer, '	</table>')
	aAdd(aBuffer, '	</div>')
	
	aAdd(aBuffer, '	<div id="divButtons">')
	
	// constroi os componentes buttons
	if alShowDefaultButtons
		buildButton(aBuffer, aaButtons)
	endif
	
	aAdd(aBuffer, '	</div>')
	aAdd(aBuffer, '</div>')
		
return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Monta uma janela com o formato de download de um arquivo
Args: acNameFile, string, contendo o nome do arquivo com o path completo
		acFileRelPath, string, contendo o caminho relativo do arquivo em relação ao servidor web
		isMeta, logico, informando se é MetaDados para executar o arquivo em XML
--------------------------------------------------------------------------------------
*/                      
#define KBYTE 1024

function linkDownload(acNameFile, acFileRelPath, acIcone, alInline)
  local cRet
  local aParams := { {"file", acNameFile}, { "relPath", acFileRelPath }}

	default alInline := .f.

  if alInLine
    cRet := tagLink(AC_EXEC_DOWNLOAD_INLINE, "", tagImage(acIcone, 18, 18, STR0090), aParams, TARGET_BLANK) //###"Abre o documento"
  else
    cRet := tagLink(AC_EXEC_DOWNLOAD, "", tagImage(acIcone, 18, 18, STR0091), aParams, TARGET_BLANK) //###"Inicia o download de documento"
  endif
  
return cRet

function buildDownload(acNameFile, acFileRelPath, alIsMeta)
	local aBuffer := {}, aFields := {}, aButtons := {}
	local oFileHandle, nBase, nSize, cPic
	local cMaskSize := dwMask("99,999.9")
	
  default alIsMeta := .f.
    
	oFileHandle := TDWFileIO():new(acFileRelPath + acNameFile)
	if oFileHandle:Open()          
		nSize := oFileHandle:Size()
		oFileHandle:Close()
		if nSize < KBYTE
			nBase := 1                   
			cPic := "bytes"
			cMaskSize := dwMask("999,999")
		elseif nSize < KBYTE * 1000
			nBase := KBYTE 
			cPic := "KBytes"
		else
			nBase := KBYTE * 1000
			cPic := "MBytes"
		endif
		cSize := transform(nSize / nBase, cMaskSize) + " " + cPic

		aAdd(aBuffer, '<div class="divDownload">')
		aAdd(aBuffer, '	<div id="divMensagem">')
		aAdd(aBuffer, '		' + STR0052 + ' <b>[ ' + acNameFile + ']</b>, ' + STR0053 + ' <b>[ ' + cSize + ' ]</b>, ' + STR0054) //###"O processo de baixa do arquivo"###"com"###"terá inicio dentro de alguns segundos.<br>Será apresentado uma janela, onde você deve informar o local e nome com o qual o arquivo será salvo."
		aAdd(aBuffer, '		<p>' + STR0055) //###"Após o término da baixa do arquivo, favor fechar esta janela."
		aAdd(aBuffer, '		<br>' + STR0056 + tagLink(AC_EXEC_DOWNLOAD, STR0057, , { {"file", acFileRelPath + acNameFile }, iif(alIsMeta, {"extensFile","XML"}, nil)})) //###//###"Obs: caso o procedimento não ocorra, "###"clique aqui"
		aAdd(aBuffer, '	</p></div>')
		aAdd(aBuffer, tagJS())
		aAdd(aBuffer, 'var xTimeout = setTimeout("goURL()", 2000);')
		aAdd(aBuffer, 'function goURL() {')
		aAdd(aBuffer, '	clearTimeout(xTimeout);')
		if (alIsMeta) 
			aAdd(aBuffer, '	doLoadHere(' + makeAction(AC_EXEC_DOWNLOAD, {{"file", dwEncode(acFileRelPath + acNameFile) }, {"extensFile","XML"}} ) + ');')
		else
			aAdd(aBuffer, '	doLoadHere(' + makeAction(AC_EXEC_DOWNLOAD, {{"file", dwEncode(acFileRelPath + acNameFile) }, {"forceDownload", .T. }} ) + ');')		
		end if
		aAdd(aBuffer, '}')
		aAdd(aBuffer, '</script>')

		makeCustomField(aFields, '', dwConcatWSep(CRLF, aBuffer))
	else
		makeCustomField(aFields, '', buildWarning(STR0058))
	endif

	makeButton(aButtons, BT_CANCEL, STR0059) //###"Fechar"
		
return buildForm('frmDownload', STR0060, AC_NONE, , aButtons, aFields) //"Download de arquivos"

/*
--------------------------------------------------------------------------------------
Monta a janela de download (tela de "save as")
Args:
--------------------------------------------------------------------------------------
*/
function DWExecDownload(acFilename, alIsMeta, alForceDownload)
	Local oFileHandle, cDados := '', aBuffer, cNameTemp
	local cNome := ""
	local cExtensao := ""
                                                                             
    default alIsMeta := .f.
    default alForceDownload := .F.                    
    
	oFileHandle := TDWFileIO():new(acFilename)
	if(oFileHandle:Open())
		If ".htm" $ acFilename .AND. !alForceDownload
			aBuffer := {}
			oSigaDW:buildCabec(aBuffer)    
			aAdd(aBuffer, buildAttention(STR0061 + " [ <b>" + acFilename + "</b> ]<br>")) //###"<b>ATENÇÃO<b>: Este é o conteúdo do arquivo"
			aAdd(aBuffer, buildWarning(STR0062 + "<br>")) //###"Caso exista botões de submissão, links ou assemelhados, não os acione."
			aAdd(aBuffer, buildWarning(STR0063)) //###"Eventualmente poderá ocorrer erro de JavaScript, ignore-os."
			aEval(aBuffer, { |x| httpSend(x+CRLF)})
			httpSend("<div id='page_body' class='page_body shadow' style='margin:10px;padding:3px;overflow:auto; text-align:left;width:510px;height:400px;'>"+CRLF)
		Else                      
			if alIsMeta
				cNameTemp := oSigaDW:DwCurr()[2]+"-meta"			                      			
			else
				cNameTemp := acFileName
			end if		
		                                        
		 	splitPath(cNameTemp, , , @cNome, @cExtensao)
			if ".xls" $ acFilename .or. ".xml" $ acFilename
				HttpCTType( "application/vnd.ms-excel;")
			else
				HttpCTType( "application/octet-stream;")
			endif                                      
			HttpCTDisp( 'attachment; filename='+ cNome + cExtensao )
			HttpCTLen(oFileHandle:Size())
		EndIf
		cDados := space(1024)
		while(oFileHandle:Read(@cDados) > 0)
			HttpSend(cDados)
		end
		oFileHandle:Close()
		if ".htm" $ acFilename .AND. !alForceDownload
			httpSend("</div>"+CRLF)
			httpSend("<div align='right'>"+tagButton(BT_CLOSE)+"</div>"+CRLF)
			httpSend(tagJS()+CRLF)
			httpSend("setWindowSize(600, 650);"+CRLF)
			httpSend("</script>"+CRLF)
		endif
	endif	
return

/*
--------------------------------------------------------------------------------------
Executa a finalização do "upload"
Args:
--------------------------------------------------------------------------------------
*/
function DWExecUpload(acUplFilename, acDestDir, acDestFile, alRefresh)
	local cAux := "", oUplFile, oUplDest
	local cBuffer := space(1024), aBuffer := {}
	local nBytes := 1024
			
	default acDestDir := ""
	default acDestFile := ""
	//acUplFilename := fileFisicalDirectory(acUplFilename)	
	if !empty(acDestFile)
		oSigaDW:buildCabec(aBuffer) 
		aEval(aBuffer, { |x| httpSend(x+CRLF)})
		HttpSend(buildMessage(STR0064 + ' [' + acUplFilename +' ]')+CRLF) //###"Processando carga do arquivo"
		
		oUplFile := TDWFileIO():new(acUplFilename)
		if !empty(acDestDir)
			cAux += acDestDir + "\"
		endif
		cAux += acDestFile
		//cAux := fileFisicalDirectory(cAux)	
		oUplDest := TDWFileIO():new(cAux)

		oUplFile:open()
		if oUplDest:Exists()
			oUplDest:erase()
		endif
		oUplDest:create()
		
		while(oUplFile:Read(@cBuffer, @nBytes) > 0)
			oUplDest:write(cBuffer, nBytes)
		enddo			

		oUplFile:close()
		oUplDest:close()

		HttpSend(buildAutoClose(alRefresh, STR0065)+CRLF) //###"Processo concluído."
	else
		appRaise(ERR_002, SOL_002, STR0066) //###"Não foi informado arquivo de destino."
	endif
return

/*
--------------------------------------------------------------------------------------
Verifica a execução de processos rodando em JOB com IPC
Args:
--------------------------------------------------------------------------------------
*/          
function DWVerifyProcess(alList, acIPC, aaWhenFinish)
  local aIpcList, nInd

  default aaWhenFinish := {}
	
  if alList
    aIpcList := dwToken(acIPC, "|")
    for nInd := 1 to len(aIpcList)
      verifyProcess(aIpcList[nInd], nil, "pb"+aIpcList[nInd])
    next                                     
  else
    verifyProcess(acIPC, aaWhenFinish)
  endif

return 

static function verifyProcess(acIPC, aaWhenFinish, acProgressBar)
  local xP1, xP2, xP3, nRecType, Nind
  local cAux := "", cAuxPar := ""
  local oQuery := initQuery(SEL_IPC)
  local lDel := .t.
  
  default aaWhenFinish := {}
  default acProgressBar := "pbProcesso"
  
  acIPC := upper(allTrim(acIPC))
  oQuery:Params(1, acIPC)
  oQuery:Params(2, seconds())
  oQuery:Open()
  while !oQuery:EOF()
    // Valores de nRecType e parametros necessários
    // IPC_INFO              - array -> Texto simples a ser apresentado
    // IPC_TEMPO             - cInicio, cDuracao, cTermino
    // IPC_PROCESSO          - cDescricao, nPercentual -> do processo como um todo
    // IPC_ETAPA             - cDescricao, nPercentual -> da etapa, dentro de um processo
    // IPC_AVISO             - cAviso -> texto simples a ser apresentado
    // IPC_AVISO_SP          - qtde proc, total a processar
    // IPC_ERRO              - cAviso -> texto simples a ser apresentado e indica termino com erro
    // IPC_TERMINO           - cAviso -> texto simples a ser apresentado e indica termino com sucesso
    // IPC_TERMINO_W_WARNING - cAviso -> texto simples a ser apresentado e indica termino com restrição
    //emula a função ipcWait()
    nRecType := oQuery:value("rectype")
    xP1 := &(oQuery:value("info1"))
    xP2 := &(oQuery:value("info2"))
    xP3 := &(oQuery:value("info3"))
    
    if nRecType == IPC_BUFFER
      xP1 := dwToken(xP1, ";")
      for nInd := 1 to len(xP1)
        aSize(xP1[nInd], 4)
        trataVerifyProcess(acProgressBar, xP1[nInd, 1], xP1[nInd, 2], xP1[nInd, 3], xP1[nInd, 4])
      next
    elseif nRecType == IPC_ERRO .or. nRecType == IPC_TERMINO .or. nRecType == IPC_TERMINO_W_WARNING
      trataVerifyProcess(acProgressBar, nRecType, xP1, xP2, xP3)
    else
      trataVerifyProcess(acProgressBar, nRecType, xP1, xP2, xP3)
    endif
    
    if nRecType == IPC_TERMINO .OR. nRecType == IPC_ERRO .or. nRecType == IPC_TERMINO_W_WARNING
      if nRecType == IPC_TERMINO
        trataVerifyProcess(acProgressBar, IPC_AVISO, STR0067) //###"Finalizado com sucesso."
      elseif nRecType == IPC_TERMINO_W_WARNING
        trataVerifyProcess(acProgressBar, IPC_AVISO, STR0068) //###"Finalizado com restrição. Verifique o Log."
      else
        trataVerifyProcess(acProgressBar, IPC_AVISO, STR0069) //###"Ocorreu um erro durante o processo. Verifique o Log."
      endif
      
      if !empty(aaWhenFinish)
        aEval(__WebApp:getLibJS(), { |x| cAux += tagJSLib(x) + CRLF })
        cAux += tagJS() + CRLF
        cAuxPar := "var axParams = new Array();"+CRLF
        if !(valType(xP1) == "U")
          if valType(xP1) == "A"
            for nInd := 1 to len(xP1)
              cAuxPar += "axParams.push('"+dwEncode(dwStr(xP1[nInd])) + "');"+CRLF
            next
          else
            cAuxPar := "var axParams = " + dwEncode(dwStr(xP1,.t.)) + ";"+CRLF
          endif
        endif
        cAux += cAuxPar
        cAux += dwConcatWSep(CRLF, aaWhenFinish)+ CRLF
        cAux += "</script>"+CRLF
        HttpSession->afterProcess := nil
      else
        DWHttpSend(buildAutoAction(AC_NONE, , STR0065), .f.) //###"Processo concluído."
      endif
      cAux += "<script>"+CRLF
      cAux += "var oWin = oDocForUpdate.parentWindow;"+ CRLF
      cAux += "if (oWin['xInterval']) { oWin['xStopRefresh'] = 1; oWin['nInterval'] = 0; }"+ CRLF
      cAux += "</script>"+CRLF
      DWHttpSend(cAux, .f.)
    endif
    oQuery:_next()
    lDel := .t.
  enddo
  oQuery:close()
  if lDel
	  oQuery:ExecDel()
	endif

return 

static function trataVerifyProcess(acProgressBar, nRecType, xP1, xP2, xP3)
	local cAux 

	if nRecType == IPC_INFO
		cAux := DWAtzProgInfo(0, xP1)
	elseif nRecType == IPC_TEMPO
		cAux := atzProgress(nRecType, nil, nil, nil, nil, nil, nil, xP1, xP2, xP3)
	elseif nRecType == IPC_PROCESSO
		cAux := atzProgress(nRecType, acProgressBar, xP1)
	elseif nRecType == IPC_ETAPA
		cAux := atzProgress(nRecType, acProgressBar, nil, xP1, xP2)
	elseif nRecType == IPC_AVISO 
		cAux := atzProgress(nRecType, acProgressBar, nil, nil, nil, nil, xP1)
	elseif nRecType == IPC_AVISO_SP
		cAux := STR0105 + " " + dwFormat("[9,999,999]/[9,999,999] ([999.999%])", {xP1, xP2, xP1 / xP2 * 100}) //###"Processando"
		cAux := atzProgress(IPC_AVISO, acProgressBar, nil, nil, nil, nil, cAux)
	elseif nRecType == IPC_ERRO .or. nRecType == IPC_TERMINO .or. nRecType == IPC_TERMINO_W_WARNING
		cAux := atzProgress(nRecType, acProgressBar, nil, nil, nil, nil, xP1)
	endif			

	if !empty(cAux)
		DWHttpSend(cAux, .f.)
	endif

return

/*              		
--------------------------------------------------------------------------------------
Recupera o diretório de arquivos do servidor web
Args:
--------------------------------------------------------------------------------------
*/            
function fileFisicalDirectory(acWebPath)
	Local cRootPath, cFilePath
  	
	default acWebPath := GetPvProfString(getEnvServer(), "RootPath", "", GetADV97())
	
	cRootPath := GetPvProfString(getEnvServer(), "RootPath", "", GetADV97())
	if upper(left(acWebPath, len(cRootPath)+1)) == upper(cRootPath) + "\"
		cFilePath := substr(acWebPath, len(cRootPath)+1)
	else
		cFilePath := acWebPath
	endif
		
return cFilePath

/*              		
--------------------------------------------------------------------------------------
Recupera o diretório de arquivos do root servidor
Args:
--------------------------------------------------------------------------------------
*/
function fileRootFisicalDirectory(acRootPath)
	Local cRootPath, cFilePath
  	
	default cRootPath := GetPvProfString(getEnvServer(), "RootPath", "", GetADV97())
	
	if upper(left(acRootPath, len(cRootPath)+1)) == upper(cRootPath)
		cFilePath := substr(acRootPath, len(cRootPath)+1)
	else
		cFilePath := acRootPath
	endif
		
return cFilePath

/*
--------------------------------------------------------------------------------------
Gera um número aleatório
Args:
--------------------------------------------------------------------------------------
*/
function randByTime()
	
	Local cConfCode := time()
	
	if (seconds() % 2 == 0)
  		cConfCode := substr(cConfCode,8,2) + substr(cConfCode,1,2) + substr(cConfCode,4,2)
	else
  		cConfCode := substr(cConfCode,4,2) + substr(cConfCode,8,2) + substr(cConfCode,1,2)
	endif
	
	cConfCode := substr(cConfCode,1,1) + substr(cConfCode,3,1) + substr(cConfCode,5,1) +;
             		substr(cConfCode,2,1) + substr(cConfCode,4,1) + substr(cConfCode,6,1)
return cConfCode

/*
--------------------------------------------------------------------------------------
Gera um número aleatório
Args:
--------------------------------------------------------------------------------------
*/
function randByDate()
	
	Local cConfCode := DTOC(Date())
	
	cConfCode := substr(cConfCode,8,2) + substr(cConfCode,1,2) + substr(cConfCode,4,2)	
	cConfCode := substr(cConfCode,1,1) + substr(cConfCode,3,1) + substr(cConfCode,5,1) +;
             		substr(cConfCode,2,1) + substr(cConfCode,4,1) + substr(cConfCode,6,1)
return cConfCode

/*
--------------------------------------------------------------------------------------
Código para acionamento do DOM
--------------------------------------------------------------------------------------
*/
function DWShowDOM()
	
return tagJSLib("jsdom.js") + CRLF + ;
		tagButton(BT_JAVA_SCRIPT, "DOM", "openDOMBrowser('_document')")

/*
--------------------------------------------------------------------------------------
Função responsável por criar a chamada a função que gerará o código Html do applet,
	podendo passar ou não parâmetros
Args: acAppName - nome da classe do applet
	  acObjName - nome da instância do applet
	  acWidth - tamanho/width do applet
	  acHeight - tamanho/height do applet
	  aaParams - array contendo os parâmetros a serem passados para o applet (OPCIONAL)
	  aaBuffer - array, buffer utilizado para montagem da tag (OPCIONAL)
--------------------------------------------------------------------------------------
*/
function tagApplet(acAppName, acObjName, anWidth, anHeight, aaParams, aaBuffer)
	local aBuffer := {}
	
	default aaParams := {}
	default aaBuffer := aBuffer
	
	DWTagApplet(acAppName, acObjName, anWidth, anHeight, aaParams, aaBuffer)
			
return iif(valType(aaBuffer) == "A", nil, dwConcatWSep(CRLF, aaBuffer))

/*
--------------------------------------------------------------------------------------
Função responsável por gerar o código HTML de chamada de applet
Args: acAppName - nome da classe do applet
	  acObjName - nome da instância do applet
	  acWidth - tamanho/width do applet
	  acHeight - tamanho/height do applet
	  aaParams - array contendo os parâmetros a serem passados para o applet
	  aaBuffer - array, buffer utilizado para montagem da tag
--------------------------------------------------------------------------------------
*/
function DWTagApplet(acAppName, acObjName, anWidth, anHeight, aaParams, aaBuffer)
	local cWidth, cHeight, nInd, cAux := ""
	
	default anWidth := buildMeasure(1)
	default anHeight :=buildMeasure(1)
	
	cWidth  := dwStr(anWidth)
	cHeight := dwStr(anHeight)
	
	aAdd(aaParams, {"DWSESSION", HttpCookies->SessionID})
	
	aEval(aaParams, { |xElem| cAux += (xElem[1]+':='+strTran(dwStr(xElem[2]), '"', '')+'|') })
	cAux := substr(cAux, 0, len(cAux)-1)
	
	aAdd(aaBuffer, tagJS())
	aAdd(aaBuffer, "	writeApplet('" + acAppName + ".class', '" + strTran(oSigaDW:JarFile(), "'", '') + "','" + acObjName + "','" + cWidth + "','" + cHeight + "', '" + cAux + "', '" + STR0070 + "');") //###"Erro ao carregar o applet. Por favor, verifique a ativação da Máquina Virtual da SUN e tente novamente"
	
	aAdd(aaBuffer, ''+;
		'	function changeAppSize() {'+;
		'		getApplet("' + acObjName + '").width = getApplet("' + acObjName + '").parentElement.width;'+;
		'		getApplet("' + acObjName + '").height = getApplet("' + acObjName + '").parentElement.height;'+;
		'	}'+;
		'	//changeAppSize();'+;
		'	</script>')

return 

/*
-----------------------------------------------------------------------
Gera HTML de atualização da caixa "Informações" no form de 
acompanhamento
Args:
-----------------------------------------------------------------------
*/
function DWAtzProgInfo(anInfo, aaInfo)
	local aBuffer := {}

	/*Remedia erro no acompanhamento do processo de importação (Support).*/
	If !(ValType(aaInfo) == 'A')
		aaInfo := {}	
	EndIf

	if anInfo == 0 //Campo "Informações"
		aAdd(aBuffer, tagJS())
		aAdd(aBuffer, "var oInfo = window.frameElement.ownerDocument.getElementById('edInfo');")
		aAdd(aBuffer, "oInfo.value = '';")
		aEval(aaInfo, { |x| aAdd(aBuffer, "oInfo.value = oInfo.value + '"+x+"' + '\n';")})
		aAdd(aBuffer, "</script>")
	endif

return dwConcatWSep(CRLF, aBuffer)

/*
-----------------------------------------------------------------------
Gera HTML de atualização da barra de progresso
Args:
-----------------------------------------------------------------------
*/
static function atzProgress(anRecType, acProgressBar, anPercProc, acEtapa, anPercEtapa, acCompl, acAviso, acInicio, acDuracao, acTermino)
  local aBuffer := {}, cClassname, cTit
  local cHoje, cAgora := ""

  default acCompl := ""
  
  aAdd(aBuffer, tagJS())
  aAdd(aBuffer, "var oDocForUpdate = window.frameElement.ownerDocument;")
  aAdd(aBuffer, "var oProgMask;")
  
  if (valType(acAviso) == "C")
    acAviso := DWEncode(acAviso)
    aAdd(aBuffer, "oDocForUpdate.getElementById('formMsg').className = 'infoImport';")
    aAdd(aBuffer, "oDocForUpdate.getElementById('formMsg').innerHTML = '"+acAviso+"';")
  endif
  
  if anRecType == IPC_ERRO .or. anRecType == IPC_TERMINO .or. anRecType == IPC_TERMINO_W_WARNING
    cClassname := iif(anRecType == IPC_ERRO, "progressBarErro", "progressBarFim")
    cTit := iif(anRecType == IPC_ERRO, "ERRO", STR0071) //###"Término normal"
    
    aAdd(aBuffer, "oProgBar = oDocForUpdate.getElementById('"+acProgressBar+"');")
    aAdd(aBuffer, "oProgBar.title = '"+cTit+"';")
    aAdd(aBuffer, "oProgBar.style.clip = 'rect(0, 246, 24, 0)';"+CRLF)
    aAdd(aBuffer, "oProgBar.className = oProgBar.className + ' "+cClassname+"';"+CRLF)
    aAdd(aBuffer, "oProgBar = oDocForUpdate.getElementById('pbEtapa');")
    aAdd(aBuffer, "oProgBar.title = '"+cTit+"';")
    aAdd(aBuffer, "oProgBar.style.clip = 'rect(0, 246, 24, 0)';"+CRLF)
    aAdd(aBuffer, "oProgBar.className = oProgBar.className + ' "+cClassname+"';"+CRLF)
  else
    cHoje := dtoc(date()) + " "
    if empty(acDuracao) .and. !empty(acInicio) .and. !empty(acTermino)
      acDuracao := DWElapTime(acInicio, acTermino)
    endif

    if !empty(acInicio)
      aAdd(aBuffer, "oDocForUpdate.getElementById('edInicio').value = '"+strTran(acInicio, cHoje, "")+"';")
    endif                  
    
    if !empty(acDuracao)
      if !(valType(acTermino) == "U")
        aAux := dwToken(acTermino, " ")
        if len(aAux) == 2
          if "(" $ aAux[2]
            cAgora := " / " + STR0113 //###"Restante: MAIS DE 24 HORAS"
          else       
            nAux := dwElapSecs(date(), time(), ctod(aAux[1]), aAux[2])
            if nAux <> 0
              cAgora := " / " + STR0072 + " " + DWSecs2Str(nAux) //###"Restante:"
            endif
          endif
        endif
        aAdd(aBuffer, "oDocForUpdate.getElementById('edDuracao').value = '"+iif(!empty(acDuracao), STR0106 + ": ", "")+acDuracao+cAgora+"';") //###"Total"
      else
        aAdd(aBuffer, "oDocForUpdate.getElementById('edDuracao').value = '"+strTran(acDuracao, "0000 ", "")+"';")
      endif
    endif
    if !empty(acTermino)
      aAdd(aBuffer, "oDocForUpdate.getElementById('edTermino').value = '"+strTran(acTermino, cHoje, "")+"';")
    endif

    if !(valType(anPercProc) == "U")
      aAdd(aBuffer, "oProgBar = oDocForUpdate.getElementById('"+acProgressBar+"');")
      aAdd(aBuffer, "oProgBar.title = '"+transform(anPercProc*100, dwMask("999.999%"))+"';")
      aAdd(aBuffer, "oProgBar.style.clip = 'rect(0, "+dwStr(anPercProc*246)+", 24, 0)';"+CRLF)
    endif
    if !(valType(acEtapa) == "U")
      aAdd(aBuffer, "oDocForUpdate.getElementById('edEtapa').value = '"+acEtapa+"';")
    endif
    if !(valType(anPercEtapa) == "U")
      aAdd(aBuffer, "oProgBar = oDocForUpdate.getElementById('pbEtapa');")
      aAdd(aBuffer, "oProgBar.title = '"+transform(anPercEtapa*100, dwMask("999.999%"))+acCompl+"';")
      aAdd(aBuffer, "oProgBar.style.clip = 'rect(0, "+dwStr(anPercEtapa*246)+", 24, 0)';"+CRLF)
    endif
  endif
  
  aAdd(aBuffer, "</script>")

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Função responsável por exibir o applet contendo uma tabela com todos os campos da
	dimensão para inclusão de dados para o filtro
Args: aaBuffer - array para buffer da geração de código html
	  aaListFields - array contendo a lista de campos a serem exibidos
	  acFormName - nome do formulário
	  aaParms - array contendo os parâmetros 
--------------------------------------------------------------------------------------
*/
#define IND_ROWS 10

function MakeWhere(aaBuffer, aaListFields, acFormName, aaParms, anRows)
	local nInd, aAux
	
	default anRows := IND_ROWS
	
	while len(aaParms) < len(aaListFields)
		aAdd(aaParms, {})
	enddo	

	for nInd := 1 to len(aaParms)
		aAux := DWToken(DWStr(aaParms[nInd])+",", ",", .f.)
		if valType(aAux) == "A"
			while len(aAux) < len(aaListFields)
				aAdd(aAux, space(1))
			enddo
			aaParms[nInd] := aAux		
		endif
	next                   
	
return

/*
--------------------------------------------------------------------------------------
Função responsável em processar os tags criados especificamente para uso pelo
SigaDW, de forma a facilitar desenvolvedores e usuários.
Os tags DW não podem ser encadeados.
Em caso se falha no processamento dos tags, será enviado o texto de entrada
sem nenhum tipo de tratamento.

Args: acHTML - string, texto com os tags sigadw
Ret.: string, texto HTML com os tags SigaDW traduzidos
--------------------------------------------------------------------------------------
*/
//####TODO - documentar o tags especial 
// <dw:user [login]>

//anPos obrigatorio passar por referencia (@)
static function nextToken(acToken, acSource, anPos)
	local nPosI, nPosF
	local nLenToken
    
	if valType(acSource) == "A" .AND. valType(acToken) == "A"
		nPosF 		:= len(acSource)
		nLenToken 	:= len(acToken)
	
		anPos := 0
		for nPosI := 1 to nPosF
			if substr(acSource, nPosI, nLenToken) == acToken
				anPos := nPosI
				exit
			endif
		next
	endif
			
return anPos <> 0

function buildDWTags(acHTML)
	local cAux := acHTML, cTag := "", cLinha
	local cRet := "", nPos := 0
	local cNome, cMail, lAdmin, oTable
   
	__DWErroCtrl := .t.
	begin sequence
		while nextToken("<dw:", cAux, @nPos)
			cRet += substr(cAux, 1, nPos-1)
			cAux := substr(cAux, nPos)
			if nextToken(">", cAux, @nPos)
				cTag := substr(cAux, 5, nPos-5)
				if substr(cTag, 1, 4) == "user"
					aTokens := dwToken(substr(cTag, 6, len(cTag)-1), " ")
					if len(aTokens) == 0
						break
					endif
					//####TODO - verificar o uso de Session para objetos
					// apresenta alguns problemas, salva de codeblocks não é feita
					oTable := initTable(TAB_USER) //oUserDW:Table()
					
					if oUserDW:LoginName() == upper(aTokens[1])
						cNome := oUserDW:Username()
						cMail := oUserDW:Email()
						lAdmin := oUserDW:UserIsAdm()
					elseif oTable:Seek(2, { "U", upper(aTokens[1]) }, .t.)
						cNome := oUserDW:Table():value("nome")
						cMail := oUserDW:Table():value("email")
						lAdmin := oUserDW:Table():value("admin")
					else
						cNome := aTokens[1]
						cMail := aTokens[1]
						lAdmin := nil
					endif		 
					cLinha := "<span class='dw_user'>"
					if valtype(lAdmin) == "U" // não é usuário SigaDW			
						cLinha += tagMailTo(cMail, cNome)
					else
						cLinha += cNome + " " + tagMailTo(cMail, cNome, .t.)
						//####TODO - desenvolver envio de mensagens user-to-user    
						cLinha += tagImage("message.gif", 20, 20, STR0092 + cNome, ,, "") //###"mensagem para : "
					endif
					cLinha += "</span>"
				else
					break
				endif    
				cAux := substr(cAux, nPos+1)
			else
				break
			endif
			cRet += cLinha
			cTag := ""

		enddo
	recover //	using oE    
		cRet := acHTML
	end sequence
	__DWErroCtrl := .f.

return cRet

/*
--------------------------------------------------------------------------------------
Função responsável por recuperar o caminho do diretório de upload de arquivos
Args:
Ret.: string, texto com a caminho
--------------------------------------------------------------------------------------
*/
function UploadDir()
return GetPvProfString(getWebHost(), "UploadPath", "", GetADV97())

/*
--------------------------------------------------------------------------------------
Função responsável por modelar uma aba de exibição de dados tabeladas
Args:	aaFields, array, contém o buffer de código Html
		acAbaName, string, contém o nome para esta aba
		aaCompFields, array, contém os campos a serem exibidos por esta aba "filha"
		alEdit, logico, indica se é editavel ou não 
		acOnShow, string, nome de uma função JS que será executa na apresentação do conteúdo da aba
Ret.: string, texto com a saída do processamento (caso não tenha sido passado o argumento aaFields)
--------------------------------------------------------------------------------------
*/
function makeChildTabbed(aaFields, acAbaName, acTitle, aaCompFields, alEdit, acOnShow, acOnSubmit)
	   
	default acOnShow := ""
	default acOnSubmit := ""
	
	aAdd(aaFields, makeFieldDef(EDT_TABBED_CHILD, acAbaName, acTitle, acOnShow+";"+acOnSubmit,,,,,,, aClone(aaCompFields)))

return

/*
--------------------------------------------------------------------------------------
Função responsável por modelar uma exibição de dados tabeladas com abas
Args:	aaFields, array, contém o buffer de código Html
		acAbaGroupName, string, contém o nome para esta aba/grupo de abas
		aaChildFields, array, array que contém o array de abas flhas (contém os campos Html criados pelo usuário)
--------------------------------------------------------------------------------------
*/
function makeTabbedPane(aaFields, acAbaGroupName, aaChildFields)

	aAdd(aaFields, makeFieldDef(EDT_TABBED_PANE, acAbaGroupName, , , , , , , aClone(aaChildFields)))

return

/*
--------------------------------------------------------------------------------------
Função responsável por modelar uma aba de exibição de dados tabeladas sendo que a chamada/link
deverá ser apartir de uma função de javascript (passada como argumento: acJSAction)
Args:	aaFields, array, contém o buffer de código Html
		acAbaName, string, contém o nome para esta aba
		acJSAction, string, contém a função JavaScript a ser chamada pelo menu desta aba
--------------------------------------------------------------------------------------
*/
function makeJSChildTabbed(aaFields, acAbaName, acTitle, acJSAction, alBody)
  default alBody := .t.
  
	aAdd(aaFields, { acAbaName, acTitle, acJSAction, alBody })
	
return

/*
--------------------------------------------------------------------------------------
Verifica se o navegador sendo utilizado é o FireFox
--------------------------------------------------------------------------------------
*/
function isFireFox()

return "Firefox" $ isNull(HttpHeadIn->User_Agent, "")

/*
--------------------------------------------------------------------------------------
Verifica se o navegador sendo utilizado é o Explorer
--------------------------------------------------------------------------------------
*/
function isInternetExplorer()
return "MSIE" $ isNull(HttpHeadIn->User_Agent, "")

function isIE6()
return isInternetExplorer() .and. "MSIE 6.0" $ isNull(HttpHeadIn->User_Agent, "XXXX")

function isIE8()
return isInternetExplorer() .and. "MSIE 8." $ isNull(HttpHeadIn->User_Agent, "XXXX")

/*
--------------------------------------------------------------------------------------
Monta a propriedade de estilo cursor (style.cursor), para o tipo hand/pointer
--------------------------------------------------------------------------------------
*/
function cssCursorHand()

return iif(isFireFox(), "cursor:pointer", "cursor:hand")

/*
--------------------------------------------------------------------------------------
Monta e envia parte do cabeçalho HTML
--------------------------------------------------------------------------------------
*/
function DWSendHeader()
	local aBuffer := {}
	
	aAdd(aBuffer, "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//"+IDIOMA+"'>")
	aAdd(aBuffer, "<html>")
	aAdd(aBuffer, "<head>")
	aAdd(aBuffer, "<title>" + __WebApp:getTitle() + "</title>") 
	aAdd(aBuffer, "<meta http-equiv='X-UA-Compatible' content='IE=EmulateIE7'/>") 	
	aAdd(aBuffer, "<meta http-equiv='content-type' content='text/html; charset=ISO-8859-1'>")  
	aAdd(aBuffer, "<meta name='author' content='"+DWAuthor()+"'>")
	aAdd(aBuffer, "<meta name='Generator' content='APServer - Modulo SigaDW'>")
	aAdd(aBuffer, "<meta name='Content-Script-Type' content='application/x-javascript'>")
	aAdd(aBuffer, "<meta http-equiv='Cache-control' content='no-cache'>")
	aAdd(aBuffer, "<meta http-equiv='Expires' content='0'>")
	aAdd(aBuffer, "<meta name='Robots' content='none,noarchive'>") //noindex,nofollow = none
	aAdd(aBuffer, "<link rel='icon' href="+urlImage('favico.ico')+">")
	aAdd(aBuffer, "<link rel='shortcut icon' href="+urlImage('favico.ico')+">")	
	if isNull(HttpGet->ws, "") == "on"
		aAdd(aBuffer, "<meta name='DWSESSIONID' content='"+HttpCookies->SessionID+"'>")
	endif

	// Disable IE6 image toolbar
	if isInternetExplorer()
		aAdd(aBuffer, "<meta http-equiv='imagetoolbar' content='no'>")
	endif
	aEval(__WebApp:getLibJS(), { |x| aAdd(aBuffer, tagJSLib(x)) })

	if !dwIsAjax() .and. !(__WebApp:className() == "TTOTVSMAIN")
		aAdd(aBuffer, tagJS())
		aAdd(aBuffer, "function getTagWaitImage()")
		aAdd(aBuffer, "{")
		aAdd(aBuffer, '  return "' + tagImage("wait.gif", 99, 40, nil, nil, nil, nil, "waitImg")+'"')
		aAdd(aBuffer, "}")
		// o desligamento da barra de "wait", é efetuada no evento onLoad do <body>
		aAdd(aBuffer, "showWait();")
		aAdd(aBuffer, "</script>")
	endif
	
	aEval(aBuffer, { |x| httpSend(x + CRLF) })

return

/*
--------------------------------------------------------------------------------------
Monta o link para o site da Microsiga
--------------------------------------------------------------------------------------
*/
function link2Siga(alLogo)
	local cRet := "", cTexto := ""
	              
	default alLogo := .f.

	if alLogo
		cRet := tagImage("logo_rodape.gif", 102,41, STR0093) //###"Web-site da Microsiga Intelligence S.A."
	else
		cTexto := "TOTVS S/A"
	endif
	cRet := tagLinkWin("http://www.totvs.com", cTexto, cRet,,TARGET_WINDOW)
      	
return cRet

/*
--------------------------------------------------------------------------------------
Complemento do meta tag Author
--------------------------------------------------------------------------------------
*/
function dwAuthor()

return "TOTVS S/A - Inteligencia Protheus - B.I."

/*
--------------------------------------------------------------------------------------
Monta o link para o site da Totvs
--------------------------------------------------------------------------------------
*/
function link2Totvs(alLogo)
	local cRet := "", cTexto := ""
	              
	default alLogo := .f.

	if alLogo
		cRet := tagImage("logo_totvs.gif", 102,41, STR0094) //###"Web-site da TOTVS S.A."
	else
		cTexto := "TOTVS S.A."
	endif
	cRet := tagLinkWin("http://www.totvs.com.br", cTexto, cRet,,TARGET_WINDOW)
      	
return cRet

/*
--------------------------------------------------------------------------------------
Monta o link para o site de todas as empresas do grupo Totvs
--------------------------------------------------------------------------------------
*/
function link2Todos(alLogo)

return link2Siga(alLogo) // + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + link2Totvs(alLogo)

/*
--------------------------------------------------------------------------------------
Monta o link com os selos de validção do W3C
--------------------------------------------------------------------------------------
*/
function linkValidados()

return linkValHtml() + "&nbsp;&nbsp;" + linkValCSS()

function linkValHtml()

return tagLinkWin("http://validator.w3.org", "", tagImage('w3c_html.gif', 80, 15, STR0095, STR0096), , TARGET_WINDOW) //###"HTML 4.01 Transitional v&aacute;lido!"###"Web-site da World Wide Web Consortium"

function linkValTidy()
                    
return tagLinkWin("http://users.skynet.be/mgueury/mozilla/", "", tagImage('tidy_16.gif', 39, 16, STR0097, "Marc´s cyberhome"), , TARGET_WINDOW) //###"Validado por HTML Validator (basedeado no Tidy)"

function linkValCSS()

return tagLinkWin("http://jigsaw.w3.org/css-validator", "", tagImage('w3c_css.gif' , 80, 15, STR0098, STR0099), , TARGET_WINDOW) //###"CSS válido!"###"Web-site da World Wide Web Consortium"


/*
--------------------------------------------------------------------------------------
Monta parametro de medida
--------------------------------------------------------------------------------------
*/
function buildMeasure(anMeasure)
	local cRet := ""

	if valType(anMeasure) == "N"
		cRet := iif(anMeasure < 1.1, dwStr(int(anMeasure*100))+"%", dwStr(anMeasure)+"px")
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Prepara a toolbar
--------------------------------------------------------------------------------------
*/
Function makeToolBar(aaItens, alShowAllRecords, anCurrentPage, anTotalPage, acActionBrowse, acSubmitParmsJS, ;
					alShowNew, acActionManut, alShowPrint, alShowBtnAllRec)
	Local cImage, cLabel

	Default acSubmitParmsJS := ""
	Default alShowPrint := .t.
	Default alShowBtnAllRec := .t.
			          
	If alShowAllRecords
		makeSpecialToolbar(aaItens, "<div style='width:200px;visibility:hidden'></div>")
	Else
		makeItemToolbar(aaItens, STR0073, STR0074, "page_first.gif", ; //###"Primeira"###"Primeira Página"
					'js:requestData(' + makeAction(acActionBrowse, { { "acao", FIRST_PAGE } } ) + ;
						iif (!empty(acSubmitParmsJS), ' + "' + acSubmitParmsJS + '"', "") + ')')
		makeItemToolbar(aaItens, STR0075, STR0076, "page_back.gif", ; //###"Anterior"###"Página Anterior"
					'js:requestData(' + makeAction(acActionBrowse, { { "acao", PREVS_PAGE } } ) + ;
						iif (!empty(acSubmitParmsJS), ' + "' + acSubmitParmsJS + '"', "") + ')')
		If ValType(anCurrentPage) == "N"
			makeSpecialToolbar(aaItens, tagInput('edSelPag', 8, DWStr(anCurrentPage) + "/" + DWStr(anTotalPage)))
			makeItemToolbar(aaItens, STR0077, STR0077, "page_target.gif",; //###"Página selecionada"
					"js:doSelectPage('" + acSubmitParmsJS + "')")
		EndIf
		makeItemToolbar(aaItens, STR0078, STR0079, "page_next.gif", ; //###"Próxima"###"Próxima Página"
				'js:requestData(' + makeAction(acActionBrowse, { { "acao", NEXT_PAGE } } ) + ;
				iif (!empty(acSubmitParmsJS), ' + "' + acSubmitParmsJS + '"', "") + ')')
		makeItemToolbar(aaItens, STR0080, STR0081, "page_last.gif",; //###"Última"###"Última Página"
				'js:requestData(' + makeAction(acActionBrowse, { { "acao", LAST_PAGE  } } ) + ;
				iif (!empty(acSubmitParmsJS), ' + "' + acSubmitParmsJS + '"', "") + ')')
	EndIf

	//----------------------------------------------------------------
	// Verifica se é para aparecer o botão novo.
	//----------------------------------------------------------------
	If alShowNew 
		//----------------------------------------------------------------
		// Caso o usuário logado seja admin o botão de novo sempre irá aparecer.
		//----------------------------------------------------------------
		If 	oUserDW:UserIsAdm()
			makeItemToolbar(aaItens, STR0012, STR0012, "page_new.gif", {acActionManut + acSubmitParmsJS, OP_REC_NEW},, TARGET_50_WINDOW) //###"Novo"
		Else
			If oUserDW:UserIsAdm() .and. (HttpGet->Action == AC_SELECT_ABA .OR. HttpGet->Action == AC_SELECT_DW) .and. HttpSession->CurrentAba[2] == "querys_users"
				//----------------------------------------------------------------
				// Nao tem acesso a criação de consultas de usuario, entao o botao NOVO nao pode ser exibido.
				//----------------------------------------------------------------
			Else
				makeItemToolbar(aaItens, STR0012, STR0012, "page_new.gif", {acActionManut + acSubmitParmsJS, OP_REC_NEW},, TARGET_50_WINDOW) //###"Novo"
			EndIf
		EndIf
	EndIf

	makeSepToolbar(aaItens)
	
	//----------------------------------------------------------------
	// Verifica se não está em modo de impressão.
	//----------------------------------------------------------------
	If alShowAllRecords
		cImage := "ic_show_paging.gif"
		cLabel := STR0107 //###"Exibir Paginação"
	Else
		cImage := "ic_show_all.gif"
		cLabel := STR0108 //###"Exibir Todos"
	EndIf
		
	If alShowBtnAllRec
		makeItemToolbar(aaItens, cLabel, cLabel, cImage, "js:doAllRecords()", "right")
	EndIf
			
	makeDefaultToolBar(aaItens, acActionBrowse, alShowPrint, acSubmitParmsJS)

Return 

/*
--------------------------------------------------------------------------------------
Prepara os botões defaults para toolbar
--------------------------------------------------------------------------------------
*/
function makeDefaultToolBar(aaItens, acActionBrowse, alShowPrint, acSubmitParmsJS)
	local nPosHelp := 0
	local defHelp := ""
	local cHelpServer := alltrim("http://"+oSigaDW:HelpServer())
	Local cLang := Lower( __Language )

	default alShowPrint 	:= .t.
	                                                                                                
	#ifdef VER_P10
		defHelp := cLang +"/sigadw_"
	#else
		defHelp := cLang +"/mergedprojects/sigadw/"
	#endif 
	
	makeItemToolbar(aaItens, STR0082, STR0083, ; //###"Atualizar"###"Efetua uma atualização da página"
						"ic_refresh.gif", "js:doRefresh(document)", "right")
	makeItemToolbar(aaItens, STR0084, STR0085, "ic_toolbar_label.gif", ; //###"Apresenta legenda"###"Legendas"
						'js:doChangeToolbar(this, "divToolbar", getImageList())', "right")
	if alShowPrint
		makeItemToolbar(aaItens, STR0086, STR0086, "page_print.gif", ; //###"Imprimir"
				"js:doPreviewPrint(" + ;
					makeAction(acActionBrowse, { 	{ "acao", PRINT_PAGE }, ;
													{ "valorAcao", "" }, ;
													{ "isPrinting", CHKBOX_ON }, ;
													{ "", acSubmitParmsJS} ;
												} ) + ")", "right")                       
	endif                        
 	if ( nPos := ascan(oSigaDW:faHelps, { |x| x[1] == acActionBrowse } ) ) > 0	
 		//###"Ajuda"###"Aciona o help da pagina"
		makeItemToolbar(aaItens, STR0088, STR0100, "ic_ajuda_off.gif", ;
					"js:doHelp(this,'"+cHelpServer+"/"+defHelp+oSigaDW:faHelps[nPos][2]+"')", "right")
	elseif ( nPos := ascan(oSigaDW:faHelps, { |x| x[1] == HttpSession->CurrentAba[2] } ) ) > 0
		//###"Ajuda"###"Aciona o help da pagina"
		makeItemToolbar(aaItens, STR0088, STR0100, "ic_ajuda_off.gif", ;
					"js:doHelp(this,'"+cHelpServer+"/"+defHelp+oSigaDW:faHelps[nPos][2]+"')", "right")
	endif
	
return

/*
--------------------------------------------------------------------------------------
Prepara a toolbar com botões extra
--------------------------------------------------------------------------------------
*/
function makeExtraToolbar(aaExtraItens, acWarning, acAction, acValorAcao )

	if !empty(acWarning)
		makeSpecialToolbar(aaExtraItens, '<div>' + buildWarning(acWarning) +"</div>")
	endif
		
return

/*
--------------------------------------------------------------------------------------
Prepara a lista de parametros
--------------------------------------------------------------------------------------
*/
static function prepareParams(aaParams)
	local nInd, lHaveSessionID := .f., oWebApp := getWebApp()
	
	for nInd := 1 to len(aaParams)
		if valtype(aaParams[nInd, 2]) == "L"
			aaParams[nInd, 2] := iif(aaParams[nInd, 2], CHKBOX_ON, CHKBOX_OFF)
		endif
		if (aaParams[nInd, 1] == SESSION_ID_PARAM)
			lHaveSessionID := .t.
		endif
	next
   	
   	// garante que o SessionID vai estar em todos os links do dw. Necessário para acesso via Remote Protheus,
   	// pois acabava perdendo o id ao abrir novas páginas secundárias
  	if HttpIsConnected() .and. !lHaveSessionID .and. ;
  			( oWebApp:isPortal() .OR. !isNull(HttpGet->dwacesss) .OR. !isNull(&("httpGet->"+SESSION_ID_PARAM)) )
  		If !isNull( &("httpGet->"+SESSION_ID_PARAM) )
  			aAdd(aaParams, { SESSION_ID_PARAM, &("httpGet->"+SESSION_ID_PARAM) })
		ElseIf !isNull(httpSession->SessionID)
  			aAdd(aaParams, { SESSION_ID_PARAM, httpSession->SessionID })
	  	EndIf
	endif
	
return

/*
--------------------------------------------------------------------------------------
Prepara mensagem para ser apresentada em "forms"
--------------------------------------------------------------------------------------
*/
static function prepFormMsg(acMsg)
	local aMsg := dwToken(strTran(acMsg, LF, ""), CR)
	local cRet := "", nInd
	
	for nInd := 1 to len(aMsg)
		if !(allTrim(aMsg[nInd]) == "")
			cRet += aMsg[nInd] + iif(right(aMsg[nInd], 4) == "<br>", "", "<br>")
		endif
	next
	
return substr(cRet, 1, len(cRet) - 4)

/*
--------------------------------------------------------------------------------------
Prepara atributo de visibilidade
--------------------------------------------------------------------------------------
*/    

function displayNone(lCancel)
	Local cRet := ""
	
	Default lCancel := .F. 
	
	if (lCancel) 
	  	cRet := iif(isInternetExplorer(), "display:block;", "visibility:table-row")
	else
		cRet := iif(isInternetExplorer(), "display:none;", "visibility:collapse")
	endIf        
return cRet

/*
--------------------------------------------------------------------------------------
Envia buffer para o Flex
--------------------------------------------------------------------------------------
*/
static function flexSend(aaBuffer)
	local nInd
	local nLenBuffer := len(aaBuffer)
  local lRoot := .f.
//usar: utf-8
	if valType(aaBuffer)=="A"
		for nInd := 1 to nLenBuffer
    	cAux := aaBuffer[nInd]
    	if valType(cAux) == "O"
    		cAux := cAux:cXMLString()
    		if !lRoot
    		  cAux := "<>"
    		  lRoot := .t.
    		endif
    	endif
    	cAux := strTran(cAux, "<i>", "")
    	cAux := strTran(cAux, "</i>", "")
    	httpSend(cAux)
  	next
  	if lRoot
    	httpSend("</>")
    endif
  else
    cAux := aaBuffer
   	httpSend(cAux)
  endif
 
return

static __WebApp
static __WebUsr
/*
--------------------------------------------------------------------------------------
Ajusta/Recupera o objeto WebApp corrente
--------------------------------------------------------------------------------------
*/
function setWebApp(aoWebApp)
  __WebApp := aoWebApp
return

function getWebApp()
	
	If httpIsConnected() .AND. valType(__WebApp) == "U" .AND. valType(oSigaDw) == "O"
		__WebApp := oSigaDw
	EndIf
	
return __WebApp

/*
--------------------------------------------------------------------------------------
Ajusta/Recupera o objeto WebUsr corrente
--------------------------------------------------------------------------------------
*/
function setWebUsr(aoWebUsr)
  __WebUsr := aoWebUsr
return

function getWebUsr()
return __WebUsr

/*
--------------------------------------------------------------------------------------
Adiciona itens de semaforo
Args:
--------------------------------------------------------------------------------------
*/
static function addSemaforoChilds(aaBuffer, aaItems)
  local nInd, nLen := len(aaItems)  
  local aItem
  
//{ acID, acCaption, aaAction, anStatus}
	
	for nInd := 1 to nLen
    aItem := aaItems[nInd]
    if valType(aItem[3]) == "A"
    	cLink := 'javaScript:doGet("main_content", "w_totvsparam.apw", ' + params2Ajax(aItem[3])+');' //page_body
			aAdd(aaBuffer, "<li id='"+aItem[1]+"' onclick='"+cLink+"'>"+aItem[2]+"</li>")
    else
			aAdd(aaBuffer, "<li id='"+aItem[1]+"'>"+aItem[2]+"</li>")
		endif    	
  next
  
return

/*
--------------------------------------------------------------------------------------
Monta semaforo
Args:
--------------------------------------------------------------------------------------
*/
function htmlSemaphoro(aaItems, acTitle, acID, alSend)
	local aBuffer := {}

  default acTitle := ""
  default acID := ""
  default alSend := .f.
      
  if !empty(acTitle)
		if left(acTitle, 1) == "#"
 			aAdd(aBuffer, "<h2 style='margin-bottom:5px;margin-top:10px'>"+substr(acTitle,2)+"</h2>")
		else  		
 			aAdd(aBuffer, "<p class='acSemaphoroRoot'>"+acTitle+"</p>")
 		endif
	endif

  aAdd(aBuffer, "<ul class='acSemaphoro' id='"+acID+"'>")

  addSemaforoChilds(aBuffer, aaItems)
  
  aAdd(aBuffer, "</ul>")
  
  if alSend
		//aEval(aBuffer, { |x| conout(x) }) //####debug
		aEval(aBuffer, { |x| httpSend(x+CRLF)})
		aBuffer := {}
	endif

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Define um "item" para o semaforo
Args:
--------------------------------------------------------------------------------------
*/
function makeSemaphoroNode(aaSemaphoro, acCaption, acID, aaAction, anStatus) //aaAction = { action, { { paramName, paramValue },...}
	local aRet

  default acID := dwMakeName("sem")

  if !(valType(aaAction) == "A")
    aaAction := AC_NONE
  endif  
  
	aRet := { acID, acCaption, aaAction, anStatus }

  if valType(aaSemaphoro) == "A"
		aAdd(aaSemaphoro, aRet)
	endif

return aRet


/*
--------------------------------------------------------------------------------------
Define um "item" para a lista de operações
Args:
--------------------------------------------------------------------------------------
*/
/*
--------------------------------------------------------------------------------------
Prepara uma mini-tool bar (esta sempre sera alinha a direita)
Para definir o conteúdo utilize a função makeItemToolBar
--------------------------------------------------------------------------------------
*/
function makeMiniToolBar(aaItens)
  local aBuffer := {}
  local aItens := aaItens, aItem
  local nInd
	
	aAdd(aBuffer, "<!-- miniToolbar start -->")
  aAdd(aBuffer, "<div style='float:right; margin-right:5px;'>")

	for nInd := 1 to len(aItens)
		aItem := aItens[nInd]
		if valType(aItem[NAV_ACTION]) == "U"
			loop
		endif
		if aItem[NAV_LABEL] == NAV_SPECIAL
			aAdd(aBuffer, aItem[NAV_ICONE])
		else
			if valType(aItem[NAV_ACTION]) == "A"
				aAdd(aBuffer, '<span '+aItem[NAV_ALIGN]+'>' + tagLinkWin(aItem[NAV_ACTION][1], '', aItem[NAV_ICONE], {{"suboper", aItem[NAV_ACTION][2]}}, aItem[NAV_WINDOW_SIZE]) + "</span>")
			else
				aAdd(aBuffer, '<span '+aItem[NAV_ALIGN]+'>' +tagLink(aItem[NAV_ACTION], '', aItem[NAV_ICONE]) + "</span>")
			endif
		endif
	next
	aAdd(aBuffer, '</div>')
	aAdd(aBuffer, '<!-- miniToolbar end -->')
	
	aEval(aBuffer, { |x| conout(x) }) //####debug

return dwConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Constrõe a div utilizada para auxílio na elaboração de expressões de filtro/seleção
QBE (Query-By-Example)
--------------------------------------------------------------------------------------
*/
function buildExQBE()
	local aBuffer := {}
		
	aAdd(aBuffer, "<div id='divHelpQbeMain' class='helpQbeMain'>")
	
	aAdd(aBuffer, "<table class='tableHelpQbe'>")
	aAdd(aBuffer, "<col width='15%'>")
	aAdd(aBuffer, "<col width='30%'>")
	aAdd(aBuffer, "<col align='left'>")
	aAdd(aBuffer, "<thead>")
	aAdd(aBuffer, "QBE")
	aAdd(aBuffer, "	<tbody>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <th>" + STR0118 + "</th>") //###"Selecione"
	aAdd(aBuffer, "    <th>" + STR0119 + "</th>") //###"Descrição QBE"
	aAdd(aBuffer, "    <th>" + STR0120 + "</th>") //###"Definição de Valores"
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "	</tbody>")
	aAdd(aBuffer, "</thead>")
	
	aAdd(aBuffer, "	<tr><td>")
	aAdd(aBuffer, "	<div id='divHelpQbeCompon' class='helpQbe'>")
	aAdd(aBuffer, "	<table class='tableHelpQbe' border='1'>")
	aAdd(aBuffer, "	<col width='15%'>")
	aAdd(aBuffer, "	<col width='30%'>")
	aAdd(aBuffer, "	<col align='left'>")
	
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='1'></td>")
	aAdd(aBuffer, "    <td>" + STR0121 + "</td>") //###"Igual a vazio"
	aAdd(aBuffer, "    <td></td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='2'></td>")
	aAdd(aBuffer, "    <td>" + STR0122 + "</td>") //###"Igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue12", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='3'></td>")
	aAdd(aBuffer, "    <td>" + STR0123 + "</td>") //###"Igual a um destes valores"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue13", 15, "", , 40)+ " p.e. 001|003|006|007</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='4'></td>")
	aAdd(aBuffer, "    <td>" + STR0124 + "</td>") //###"Está entre"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue14", 15, "", , 100) + " e " + tagInput("edHlpQBEValue24", 15, "", , 100)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='5'></td>")
	aAdd(aBuffer, "    <td>" + STR0125 + "</td>") //###"Diferente de"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue15", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='6'></td>")
	aAdd(aBuffer, "    <td>" + STR0126 + "</td>") //###"Menor que"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue16", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='7'></td>")
	aAdd(aBuffer, "    <td>" + STR0127 + "</td>") //###"Menor ou igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue17", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='8'></td>")
	aAdd(aBuffer, "    <td>" + STR0128 + "</td>") //###"Maior ou igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue18", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='9'></td>")
	aAdd(aBuffer, "    <td>" + STR0129 + "</td>") //###"Maior que"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue19", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='10'></td>")
	aAdd(aBuffer, "    <td>" + STR0130 + "</td>") //###"Inicie com o texto"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue110", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='11'></td>")
	aAdd(aBuffer, "    <td>" + STR0131 + "</td>") //###"Contenha no texto"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue111", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='12'></td>")
	aAdd(aBuffer, "    <td>" + STR0132 + "</td>") //###"Termine com o texto"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue112", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='13'></td>")
	aAdd(aBuffer, "    <td>" + STR0133 + "</td>") //###"Dia igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue113", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='14'></td>")
	aAdd(aBuffer, "    <td>" + STR0134 + "</td>") //###"Mes igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue114", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='15'></td>")
	aAdd(aBuffer, "    <td>" + STR0135 + "</td>") //###"Ano igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue115", 15, "", , 40)+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='16'></td>")
	aAdd(aBuffer, "    <td>" + STR0136 + "</td>") //###"Dia/Mês igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue116",  2, "", , ) + " / "+tagInput("edHlpQBEValue216",  2, "", , )+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='17'></td>")
	aAdd(aBuffer, "    <td>" + STR0137 + "</td>") //###"Dia/Ano igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue117",  2, "", , ) + " / "+tagInput("edHlpQBEValue217",  4, "", , )+"</td>")
	aAdd(aBuffer, "  </tr>")
	aAdd(aBuffer, "  <tr class='zebraOn'>")
	aAdd(aBuffer, "    <td><input type='radio' class='radio' name='edHlpQBE' id='edHlpQBE' value='18'></td>")
	aAdd(aBuffer, "    <td>" + STR0138 + "</td>") //###"Mês/Ano igual a"
	aAdd(aBuffer, "    <td>"+tagInput("edHlpQBEValue118",  2, "", , ) + " / "+tagInput("edHlpQBEValue218",  4, "", , )+"</td>")
	aAdd(aBuffer, "  </tr>")
	
	aAdd(aBuffer, "  <tr class='zebraOff'>")
	aAdd(aBuffer, "    <td colspan='3'><input type='checkbox' class='form_input' name='edHlpQBENeg' id='edHlpQBENeg'>" + STR0139 + "</td>") //###"Negativa"
	aAdd(aBuffer, "  </tr>")
	
	aAdd(aBuffer, "</table>")
	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, "</td></tr>")
	
	aAdd(aBuffer, "<tr><td colSpan=3>")           
	
	aAdd(aBuffer, 	makeButton(, BT_JAVA_SCRIPT, STR0140, "applyHlpQBE(true)")) //###"Aplicar"
	aAdd(aBuffer, 	makeButton(, BT_JAVA_SCRIPT, STR0141, "applyHlpQBE(false)")) //###"Fechar"
	aAdd(aBuffer, 	makeButton(, BT_JAVA_SCRIPT, STR0142, "clearHlpQBE()")) //###"Limpar"  
	
	aAdd(aBuffer, "</td></tr>")
	aAdd(aBuffer, "</table>")
	
	aAdd(aBuffer, "</div>")
                                                
return dwConcatWSep(CRLF, aBuffer)          

/*-------------------------------------------------------------   
Monta um formulário informativo.
@Param
	cTitle 			Título do Formulário.
	cInformation   	Identificador da mensagem a ser exibida.
@Rerurn
	Caracter  (function buildForm)
-------------------------------------------------------------*/
function buildInformation(cTitle, cInformation)
   	local aBuffer := {}, aFields := {}, aButtons := {}
	 
	Do Case
		Case cInformation == "IE8"	
			aAdd(aBuffer, '<div id="divInformation">')   
			aAdd(aBuffer, '		<h4>' + STR0144 + '</h4>')/*Habilitar modo de exibição de compatibilidade para sites específicos,usando o Internet Explorer 8*/ 
			aAdd(aBuffer, '		<p>' + STR0145 + '</p>')/*"Para habilitar o modo de exibição de compatibilidade para sites específicos, execute essas etapas:"*/
			aAdd(aBuffer, '		<ol type=1 >') 
			aAdd(aBuffer, ' 		<li>' + STR0146 + '</li>') /*Abra o site do SIGADW no Internet Explorer 8.*/ 
			aAdd(aBuffer, ' 		<li>' + STR0147 /*Clique no ícone*/ + ' <strong> ' + STR0148 /*modo de exibição de compatibilidade*/ + ' </strong> ' + STR0149/*que está localizado diretamente à direita da barra de endereços.*/ +'</li>') 
			aAdd(aBuffer, '		</ol>')                                                     
			aAdd(aBuffer, '		<center>')
			aAdd(aBuffer, 			'<p>' +tagImage('Info_Compatibility.jpg',152,54) + '</p>') 
			aAdd(aBuffer, '		</center>')
			aAdd(aBuffer, '		 <p>' + STR0150 + '</p>')/*Depois de habilitar o modo de compatibilidade, o site será atualizado automaticamente, e você poderá ver uma mensagem informando que o site está sendo executado no modo de compatibilidade.*/
			aAdd(aBuffer, '</div>')
		/*
		Case cInformation == "ALIAS"
			Inserir sua mensagem de informação personalizada aqui.
		*/		
	endCase  
	   	   
	makeCustomField(aFields, '', dwConcatWSep(CRLF, aBuffer))   	       
	makeButton(aButtons, BT_CANCEL, STR0151)/*Voltar*/ 

	
return buildForm('frmInformation', cTitle , AC_NONE, , aButtons, aFields)


//-------------------------------------------------------------------
/*/{Protheus.doc} DwcalcTxtPx
Função que retorna em pixels o tamanho de uma string
@Param cString String a ser tratada.
@Return Integer tamanho em pixels dessa string
@Author  Helio Leal
@Since   04/06/2014
/*/
//-------------------------------------------------------------------
Function DwcalcTxtPx(cString)	
	Local nInd			:= 0
	Local aPixWidths 	:= {}
	Local nTamPx		:= 0
	Local cLetra		:= ""
	
	aPixWidths := DwGetPixels()

	For nInd := 1 To Len(cString)	
		cLetra := Upper( SubStr(cString, nInd, 1) )
		nPos := aScan( aPixWidths, { |aX| aX[2] == cLetra } )

		If nPos > 0 .And. nPos < 27
			nTamPx += aPixWidths[nPos, 1]
		Else
			nTamPx += 10
		EndIf		 
	Next
	
Return nTamPx

//-------------------------------------------------------------------
/*/{Protheus.doc} DwGetPixels
Função que retorna um array com o tamanho em pixel de cada caractere.
Obs: Retorna para a fonte Verdana, que é utilizada na consulta.
@Return  Array = vetor que o tamanho em pixel e o caracter. 
@Author  Helio Leal
@Since   04/06/2014
/*/
//-------------------------------------------------------------------
Function DwGetPixels()
	Local aTam := {;
						{12,"A"},; // Pixel // Asc // Letra.
						{11,"B"},;
						{11,"C"},;
						{12,"D"},;
						{10,"E"},;
						{10,"F"},;
						{12,"G"},;
						{12,"H"},;
						{8 ,"I"},;
						{8 ,"J"},;
						{12,"K"},;
						{10,"L"},;
						{14,"M"},;
						{12,"N"},;
						{13,"O"},;
						{11,"P"},;
						{13,"Q"},;
						{12,"R"},;
						{11,"S"},;
						{10,"T"},;
						{12,"U"},;
						{11,"V"},;
						{16,"W"},;
						{11,"X"},;
						{11,"Y"},;
						{10,"Z"};
					}
Return aTam

//-------------------------------------------------------------------
/*/{Protheus.doc} DwAnaliMax
Função que analisa uma string e retorna a maior palavra dela.
Exemplo: quantidade de vendas, ele retorna 'quantidade'
@Param   cString String = String a ser analisada
@Return  String = Maior palavra da 'frase'
@Author  Helio Leal
@Since   04/06/2014
/*/
//-------------------------------------------------------------------
Function DwAnaliMax(cString)
	Local aStrs 	:= {}
	Local nInd		:= 0
	Local cMaior	:= ""

	aStrs := strTokArr(cString, " ")

	cMaior := aStrs[1]

	// Rotina que recebe o maior conteúdo do array.
	For nInd := 1 To Len(aStrs)
		If (Len(cMaior) < Len(aStrs[nInd]))
			cMaior := aStrs[nInd]
		EndIf
	Next
	
Return cMaior
