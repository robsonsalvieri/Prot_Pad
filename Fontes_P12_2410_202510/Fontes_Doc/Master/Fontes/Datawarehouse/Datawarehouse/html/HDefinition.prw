// ######################################################################################
// Projeto: DATAWAREHOUSE
// Modulo : Htm
// Fonte  : HDefinition - THDefinition, responsável pela definição da consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 25.04.02 | Fernando Patelli  | Programador - B.I. - Novas Implementações
// 19.01.05 | 0548-Alan Candido | Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "HDefine.ch"

/*
--------------------------------------------------------------------------------------
Classe: THDefinition
Uso   : applet de definição de consultas
--------------------------------------------------------------------------------------
*/
class THDefinition from THItem
	                    
	data fcName					// Nome do layer
	data fnWidth				// Largura
	data fnHeight				// Altura
	data fnDefType				// Tabela ou grafico
	
	method New() constructor
	method Free()
	method NewHDefinition()
	method FreeHDefinition()

	method Name(acValue)
	method AppName()
	method Width()
	method Height()
	method DefType()

	method Buffer(aaBuffer)
	// method OnLoadBuffer(aaBuffer)  
	method CornerTitle(acValue)
	method CornerText(acValue)

endclass


// Construtor e destrutor da classe
// ---------------------------------------------------------------------------
method New() class THDefinition
	::NewHDefinition()
return
	 
method Free() class THDefinition
	::FreeHDefinition()
return

method NewHDefinition() class THDefinition
	::NewHItem()

	::fcName := DWMakeName("df")
	::fnWidth := 750
	::fnHeight := 400
	::fnDefType := TYPE_TABLE
return
	 
method FreeHDefinition() class THDefinition
	::FreeHItem()
return              

// ---------------------------------------------------------------------------


// Propriedades
// ---------------------------------------------------------------------------
// Name
method Name(acValue) class THDefinition
	property ::fcName := acValue
return ::fcName

// CornerTitle
method CornerTitle(acValue) class THDefinition
	property ::fcCornerTitle := acValue
return ::fcCornerTitle

// CornerText
method CornerText(acValue) class THDefinition
	property ::fcCornerText := acValue
return ::fcCornerText

// Width
method Width(anWidth) class THDefinition
	property ::fnWidth := anWidth
return ::fnWidth

// Heigth
method Height(anHeight) class THDefinition
	property ::fnHeight := anHeight
return ::fnHeight

// DefType
method DefType(anDefType) class THDefinition
	property ::fnDefType := anDefType
return ::fnDefType
// ---------------------------------------------------------------------------
// Metodos
// ---------------------------------------------------------------------------
// Monta o nome do applet
method AppName() class THDefinition
return upper("definition"+::Name()) 

// Monta o buffer para inserir no body
method Buffer(aaBuffer) class THDefinition
	local aBuffer := {}, cAux, nInd, nInd2
	local TEMPORAL, GRAPHTYPES, TEXTS, DIALOGY
	local aParams := {}								
	if valType(aaBuffer) != "U"
		aBuffer := aaBuffer
	endif

//	aAdd(aBuffer, "<div align=right style='width:"+::Width()+" height:"+::Height()+	";' id=div" + upper(::Name()) +"browse>")
	cAux := urlImage("ic_corner.gif",.f., "hdefinition", .t.)
	aAdd(aParams, { "imagePath", left(cAux, rat("/", cAux)-1) })
	if ::fnDefType == TYPE_GRAPH
		aAdd(aParams, { "GRAPH", "on" } )
	endif
	aAdd(aParams, { "PROPEXTEND", "on" } )
	
		
	TEMPORAL = { STR0001, STR0002, STR0003, STR0004, STR0005, STR0006, STR0007, ;
				 STR0008,	STR0009, STR0010, STR0011, STR0012, STR0013, STR0110}/*//"Mes"###"Quinzena"###"Semana"###"Dia"###"Dia da Semana"###"Dia do Ano"###"Semana do Ano"*/
   
	for nInd := 1 to len(TEMPORAL)
		aAdd(aParams, { "TEMPORAL_"+DWStr(nInd), TEMPORAL[nInd] })
	next
	
	GRAPHTYPES = { 	{ STR0014, "ic_barra.gif" }, 	;
					{ STR0015, "ic_barra3d.gif" }, 	;
					{ STR0016, "ic_coluna.gif" }, 	;
					{ STR0017, "ic_coluna3d.gif" }, ;
					{ STR0018, "ic_linha.gif" }, 	;
					{ STR0019, "ic_linha3d.gif" }, 	;
					{ STR0020, "ic_pizza.gif" } }
					/*//"BARRA"###"BARRA 3D"###"COLUNA"###"COLUNA 3D"###"LINHA"###"LINHA 3D"###"PIZZA"*/
	for nInd := 1 to len(GRAPHTYPES)
		aAdd(aParams, { "GRAPHTYPES_" + DWStr(nInd-1), GRAPHTYPES[nInd][1] })
		aAdd(aParams, { "GRAPHTYPES_" + DWStr(nInd-1) + "_IMG", GRAPHTYPES[nInd][2] })
	next	
	
	DIALOGY = { STR0021, STR0022, STR0023, STR0024, STR0025, STR0026,;
				STR0027, STR0028, STR0029, STR0030,;
				STR0031, STR0032, STR0033, STR0023, STR0024, STR0034,;
				STR0027, STR0028, STR0029, STR0030,;
				STR0031, STR0032, STR0035, STR0036, STR0037, STR0038, STR0050,;
				STR0051, STR0052, { STR0053, {'', STR0054, STR0055} },;
				STR0056, STR0057, STR0058, STR0059, ;
				STR0060, { STR0061, {'', STR0062, STR0063} }, STR0064, STR0065, ;
				{ STR0066, { {'', '0' }, {STR0067, '100'}, {STR0068, '200'} } }, ;
				{ STR0069, { {'', '0'}, {'50', '50'}, {'100', '100'} } }, ;
				STR0070, STR0071, STR0072, STR0073, STR0074, STR0075, ;
				STR0076, STR0077, STR0078, STR0079, STR0080, STR0081, ;
				STR0082, STR0083, STR0084, STR0085, STR0086, STR0087, ;
				STR0088, STR0089, ;
				STR0090, STR0091, STR0092, STR0093, STR0094, STR0095, STR0096, ;
				STR0097, STR0098, STR0099, STR0100, STR0104, STR0105, STR0106, ;
				STR0107, STR0108, STR0109	 }
				
	for nInd := 1 to len(DIALOGY)
		if valType(DIALOGY[nInd]) == "A"
			aAdd(aParams, { "DIALOGY_"+DWStr(nInd), DIALOGY[nInd][1] })
			for nInd2 := 1 to len(DIALOGY[nInd][2])
				if valType(DIALOGY[nInd][2][nInd2]) == "A"
					aAdd(aParams, { "DIALOGY_"+DWStr(nInd)+"_"+DWStr(nInd2)+"_LABEL", DIALOGY[nInd][2][nInd2][1] })
					aAdd(aParams, { "DIALOGY_"+DWStr(nInd)+"_"+DWStr(nInd2)+"_VALUE", DIALOGY[nInd][2][nInd2][2] })
				else
					aAdd(aParams, { "DIALOGY_"+DWStr(nInd)+"_"+DWStr(nInd2), DIALOGY[nInd][2][nInd2] })
				endif
			next
		else
			aAdd(aParams, { "DIALOGY_"+DWStr(nInd), DIALOGY[nInd] })
		endif
	next

	TEXTS = { 	{'DRILLDOWN',		STR0101},;
				{'DRILLPARENT_IMG', 'ic_drilldown_parent.gif'},;
				{'DRILLCHILD_IMG', 	'ic_drilldown_child.gif'},;
				{'TOTALIZE',		STR0102},;
				{'TOTALIZE_IMG',	'ic_totalize.gif'},;
				{'EIXOX', 	   		STR0041},;
				{'EIXOY',	   		STR0042},;
				{'AREAIND',   		STR0043},;
				{'TIPODEG',   		STR0044},;
				{'PROPS', 	  		STR0045},;
				{'DIMENSOES', 		STR0046},;
				{'INDICADORES', 	STR0047},;
				{'GRAFICO',    		STR0048},;
				{'TABELA', 	   		STR0049},;
				{'SUMARIO', 	   	STR0103} }
	for nInd := 1 to len(TEXTS)
		aAdd(aParams, { TEXTS[nInd,1], TEXTS[nInd,2] })
	next
	
	// monta as Funções Agregadores
	// label "Função Agregadora"
	aAdd(aParams, { "FUNC_AGREG", STR0089 })
	
	// icones de exibição da árvore
	aAdd(aParams, { "TREE_LEAF", "ic_pastafechada.gif" })
	aAdd(aParams, { "TREE_OPEN", "ic_pastaaberta.gif" })
	aAdd(aParams, { "TREE_CLOSE", "ic_pastafechada.gif" })

	// cor de fundo para áreas selecionadas com o mouse
	//aAdd(aParams, { "APPLETS_SELECTIONS", "0xefebde" })
    // cor de fundo da área de trabalho
	aAdd(aParams, { "APPLETS_BGCOLOR", "0xFFFFFF" })
	// cor de fundo da área do applet
	aAdd(aParams, { "APPLETS_WORKSPACE_BGCOLOR", "0xFFFFFF" })
	// cor de fundo padrão dos botão
	aAdd(aParams, { "BUTTON_BGCOLOR", "0xeceef2" })
	// cor de fundo do botão caso esteja com drill down
	aAdd(aParams, { "BUTTON_BGCOLOR_DRILLDOWN", "0x8793af" })
	// cor da fonte do botão caso esteja com drill down
	aAdd(aParams, { "BUTTON_FONTCOLOR_DRILLDOWN", "0x000000" })

	// cor de fundo da área de drag and drop quando tiver OK
	aAdd(aParams, { "BGCOLOR_DD_OK", "0xc6fff4" })
	
	// cor de fundo da área de drag and drop quando tiver OK
	aAdd(aParams, { "BGCOLOR_DD_NOK", "0xf66262" })
	
	// cria a tag applet
	tagApplet("br.com.microsiga.sigadw.applet.DWScriptDefinition", ::AppName(), ::Width(), ::Height(), aParams, aBuffer)

return iif(valType(aaBuffer) == "U", DWStr(aBuffer), "")