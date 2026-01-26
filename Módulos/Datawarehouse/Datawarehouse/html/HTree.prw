// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Htm
// Fonte  : HtmTree - Objeto THTree, responsável por navegação em árvore "Tree"
// Dependencia Externa:
//				JSTree.js
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: THTree
Uso   : Navegação em árvore (tree)
--------------------------------------------------------------------------------------
*/
class THTree from THItem
   	
	data fcName
	data faNodes
	data faCoord
	data fcURLFrame
	data faImages
	data fcBackground
	data fcBackcolor
	data fcRootCaption
	data fcRootURL
	data fcSubTheme
	data flTreeList
	
	method New(aoOwner) constructor
	method Free()       
	method NewHTree(aoOwner)
	method FreeHTree()
	
	method Name(acValue)
	method Width(anValue)
	method Height(anValue)
	method TreeList(alIsTreeList)
	
	method Buffer(aBuffer, alBottom)
	method ListNodes(aaBuffer, aaNodes, aaStringNodes, acParentName, alNoParm)
	method SearchNode(acName, aaNodes)
	method CountUntilSearch(acName, aaNodes) 
	method AddNode(acParent, acName, acCaption, alCanSubnodes, acURL, alCheckbox, nNormalIndex, nExpandIndex, cData)
	method AddImage(acImageFile)
	method ImageCount()
	method ExpandNode(acName)
	method SetString(acName, acValue)
	method urlFrame(acValue)
	method Background(acImageFile)
	method Backcolor(acColor)
	method Nodes()
	method AppName()
	method RootCaption(acValue)
	method RootURL(acValue)
	method SubTheme(acValue)

endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(aoOwner) class THTree
               
	::NewHTree(aoOwner)
	
return

method Free() class THTree

	::FreeHTree()

return

method NewHTree(aoOwner) class THTree

	::NewHItem(aoOwner)
	::faNodes := {}
	::faImages := {}
	::faCoord := { 0, 0}
	::fcURLFrame := ""
	::fcBackground	:= ""
	::fcBackcolor := "#FFFFFF"
	::fcRootCaption := ""
	::fcRootURL := ""
	::fcSubTheme := "tree"
	::flTreeList := .F.
		
return

method FreeHTree() class THTree

	::FreeHItem()

return

/*
--------------------------------------------------------------------------------------
Propriedade Name
--------------------------------------------------------------------------------------
*/                         
method Name(acValue) class THTree
               
	property ::fcName := acValue
	
return ::fcName

/*
--------------------------------------------------------------------------------------
Propriedade Width
--------------------------------------------------------------------------------------
*/                         
method Width(anValue) class THTree
               
	property ::faCoord[1] := anValue
	
return ::faCoord[1]

/*
--------------------------------------------------------------------------------------
Propriedade Height
--------------------------------------------------------------------------------------
*/                         
method Height(anValue) class THTree
               
	property ::faCoord[2] := anValue
	
return ::faCoord[2]

/*
--------------------------------------------------------------------------------------
Propriedade TreeList
--------------------------------------------------------------------------------------
*/
method TreeList(alIsTreeList) class THTree
               
	property ::flTreeList := alIsTreeList
	
return ::flTreeList

/*
--------------------------------------------------------------------------------------
Gera código HTML dos nós
Arg: aaBuffer -> array, local de geração do HTML
	  aaNodes -> array, lista de nós
	  aaStringNodes -> array, lista de nomes de nós
	  acParentName -> string, nome do nó pai
Ret: 
--------------------------------------------------------------------------------------
*/                         
method ListNodes(aaBuffer, aaNodes, aaStringNodes, acParentName) class THTree
	local nInd, aSubNodes
	local cAux

	default acParentName := "node"
	
	if len(aaNodes) > 0
		for nInd := 1 to len(aaNodes)
			cImg := iif(aaNodes[nInd, 9]>0,"|"+urlImage(::faImages[aaNodes[nInd, 9]], .f., ::SubTheme()),"" )
			if len(aaNodes[nInd, 2]) > 0
				aSubNodes := {}
				::ListNodes(aSubNodes, aaNodes[nInd, 2], aaStringNodes, acParentName + dwstr(nInd-1) + "_")
				cAux := DWConcat("['", aaNodes[nInd, 3], cImg + "','", aaNodes[nInd, 5], "',"+DWConcatWSep(CRLF, aSubNodes) ,"]")
			else
				cAux := DWConcat("['", aaNodes[nInd, 3], cImg + "','", aaNodes[nInd, 5], "']")
			endif        
			cAux := cAux + iif(nInd!=len(aaNodes),",","")
			aAdd(aaBuffer, cAux)
		next
	else
		cAux := DWConcat("['", VAZIO, "" + "','", "", "',"+DWConcatWSep(CRLF, {}) ,"]")
		aAdd(aaBuffer, cAux)
	endif
    
return 

/*
--------------------------------------------------------------------------------------
Código HTM para o item
Arg: aBuffer -> array, local de geração do HTML
Ret: 
--------------------------------------------------------------------------------------
*/                         
method Buffer(aBuffer, alBottom) class THTree
	local cAux := ""
	local aStringNodes := {}
	local cSubTheme
	local cVarItems, cVarTempl
	                                             
	cAux := "<div align='left' id=" + ::Name() + " style='"
	if !empty(::fcBackground)
		if left(::fcBackground, 6) == "color:"
			cAux += "background:" + substr(::fcBackground,7)+";"
		else
			cAux += "background-image:url(" + urlImage(::fcBackground) + ");"
		endif	
	endif	         
	cAux += "width:"+buildMeasure(::Width())+";"
	if !empty(::Height())
		cAux += "height:"+ buildMeasure(::Height()) + ";"
	endif             
	cAux += "' class='FormContainer'>"
	aAdd(aBuffer, cAux)
	aAdd(aBuffer, tagJS())
	
	cVarTempl = "tree_tpl" + ::Name() + randByTime()
	
	aAdd(aBuffer, "var " + cVarTempl + " = {")
	if empty(::urlFrame())
		aAdd(aBuffer, "	'target'  : '_self',")
	else
		aAdd(aBuffer, "	'target'  : '"+::urlFrame()+"',")
	endif                                                         
	cSubTheme := iif(empty(::SubTheme()), "tree", ::SubTheme())
	aAdd(aBuffer, "	'icon_e'  : "+urlImage("empty.gif",, cSubTheme)      +",") // empty image
	aAdd(aBuffer, "	'icon_l'  : "+urlImage("line.gif",, cSubTheme)       +",") // vertical line
	aAdd(aBuffer, "	'icon_48' : "+urlImage("base.gif",, cSubTheme)       +",") // root icon closed
	aAdd(aBuffer, "	'icon_52' : "+urlImage("base.gif",, cSubTheme)       +",") // root icon selected
	aAdd(aBuffer, "	'icon_56' : "+urlImage("base.gif",, cSubTheme)       +",") // root icon opened
	aAdd(aBuffer, "	'icon_60' : "+urlImage("base.gif",, cSubTheme)       +",") // root icon selected
	aAdd(aBuffer, "	'icon_32' : "+urlImage("base.gif",, cSubTheme)       +",") // root icon normal
	aAdd(aBuffer, "	'icon_36' : "+urlImage("base.gif",, cSubTheme)       +",") // root icon normal

	aAdd(aBuffer, "	'icon_16' : "+urlImage("folder.gif",, cSubTheme)     +",") // node icon normal
	aAdd(aBuffer, "	'icon_20' : "+urlImage("folderopen.gif",, cSubTheme) +",") // node icon selected
	aAdd(aBuffer, "	'icon_24' : "+urlImage("folder.gif",, cSubTheme)     +",") // node icon opened
	aAdd(aBuffer, "	'icon_28' : "+urlImage("folderopen.gif",, cSubTheme) +",") // node icon selected opened

	aAdd(aBuffer, "	'icon_0'  : "+urlImage("page.gif",, cSubTheme)       +",") // leaf icon normal
	aAdd(aBuffer, "	'icon_4'  : "+urlImage("page.gif",, cSubTheme)       +",") // leaf icon selected
	aAdd(aBuffer, "	'icon_8'  : "+urlImage("page.gif",, cSubTheme)       +",") // leaf icon opened
	aAdd(aBuffer, "	'icon_12' : "+urlImage("page.gif",, cSubTheme)       +",") // leaf icon selected

	aAdd(aBuffer, "	'icon_2'  : "+urlImage("joinbottom.gif",, cSubTheme) +",") // junction for leaf
	aAdd(aBuffer, "	'icon_3'  : "+urlImage("join.gif",, cSubTheme)       +",") // junction for last leaf
	aAdd(aBuffer, "	'icon_18' : "+urlImage("plusbottom.gif",, cSubTheme) +",") // junction for closed node
	aAdd(aBuffer, "	'icon_19' : "+urlImage("plus.gif",, cSubTheme)       +",") // junctioin for last closed node
	aAdd(aBuffer, "	'icon_26' : "+urlImage("minusbottom.gif",, cSubTheme)+",") // junction for opened node
	aAdd(aBuffer, "	'icon_27' : "+urlImage("minus.gif",, cSubTheme)          ) // junctioin for last opended node

	aAdd(aBuffer, "};")
	
	cVarItems := "TREE_ITEMS" + ::Name() + randByTime()
	aAdd(aBuffer, "var " + cVarItems + " = [")
	if !empty(::RootCaption())
		aAdd(aBuffer, "['"+ ::RootCaption()+ "','" + ::RootURL() + "', ")
		::ListNodes(aBuffer, ::faNodes, aStringNodes)
		aAdd(aBuffer, "]")
	else
		::ListNodes(aBuffer, ::faNodes, aStringNodes)
	endif			
	aAdd(aBuffer, "];")
	aAdd(aBuffer, 'new tree (' + cVarItems + ', ' + cVarTempl + ', "' + ::Name() + '");')
	aAdd(aBuffer, "</script>")
    
	aAdd(aBuffer, "</div>")

	alBottom := .f.
	
return

/*
--------------------------------------------------------------------------------------
Busca por um nó especifico
Arg: acName -> string, nome do nó
	  aaNodes -> array, lista de nós a fazer a busca
Ret: aRet -> array, nó localizado (ou NIL caso não ache)
--------------------------------------------------------------------------------------
*/                         
method SearchNode(acName, aaNodes) class THTree
	local nInd
	local aRet := NIL

// { cName, { }, cCaption, lCanSubnodes }	
	default aaNodes := ::faNodes
	
	for nInd := 1 to len(aaNodes)
		if aaNodes[nInd, 1] == acName
			aRet := aaNodes[nInd]
			exit
		endif
		if len(aaNodes[nInd, 2]) <> 0
			aRet := ::SearchNode(acName, aaNodes[nInd, 2])
			if valType(aRet) == "A"
				exit
			endif
		endif
	next	

return aRet

/*
--------------------------------------------------------------------------------------
Busca por um nó especifico
Arg: acName -> string, nome do nó
	  aaNodes -> array, lista de nós a fazer a busca
Ret: aRet -> array, nó localizado (ou NIL caso não ache)
--------------------------------------------------------------------------------------
*/                         
method CountUntilSearch(acName, aaNodes) class THTree
	local nInd
	local nCount := 0
	
	default aaNodes := ::faNodes
	
	for nInd := 1 to len(aaNodes)
		nCount++
		if aaNodes[nInd, 1] == acName
			exit
		elseif aaNodes[nInd, 1] > acName
			nCount--
			exit
		endif
		if len(aaNodes[nInd, 2]) <> 0
			nCount += ::CountUntilSearch(acName, aaNodes[nInd, 2])
		endif
	next	

return nCount

/*
--------------------------------------------------------------------------------------
Adiciona nós (nodes) a árvore
Arg: acParent -> string, nome do nó pai. Se vazio, insere como raiz
     acName -> string, nome do nó. Deve ser único.
     acCaption-> string, titulo do nó
     alCanSubnodes-> string, indica que o nó poderá vir a ter sub-nós
     acURL -> string, URL a ser executada quando nó acionado
Ret: lRet -> lógico, indica que o nó foi adicionado
--------------------------------------------------------------------------------------
*/                         
method AddNode(acParent, acName, acCaption, alCanSubnodes, acURL, alCheckbox, nImageIndex, nExpandIndex, cData) class THTree
   local aNode
   local lRet := .f.
	   

	default acCaption := acName
	default alCanSubnodes := .t.
	default acURL := ""
	
	default nImageIndex := 0
	default nExpandIndex := 0
	default cData := ""
	
	if valType(::SearchNode(acName)) != "A"
		if empty(acParent)
			aAdd(::faNodes, { acName, {}, acCaption, alCanSubnodes, acURL, alCheckbox, .f., nil, nImageIndex, nExpandIndex, cData, nil })
			lRet := .t.
		else
			aNode := ::SearchNode(acParent)
			if valType(aNode) == "A"
				aAdd(aNode[2], { acName, {}, acCaption, alCanSubnodes, acURL, alCheckbox, .f., nil, nImageIndex, nExpandIndex, cData, acParent })
			else
				aAdd(::faNodes, { acName, {}, acCaption, alCanSubnodes, acURL, alCheckbox, .f., nil, nImageIndex, nExpandIndex, cData, acParent })
			endif
			lRet := .t.
		endif
	endif	

return lRet

/*
--------------------------------------------------------------------------------------
Método AddImage
Arg: acImageFile -> string, path+nome do arquivo de imagem
--------------------------------------------------------------------------------------
*/                         
method AddImage(acImageFile) class THTree

	aAdd(::faImages, acImageFile)

return ::ImageCount()

/*
--------------------------------------------------------------------------------------
Método ImageCount
Ret: numerico, qtde de imagens adicionadas ate o momento
--------------------------------------------------------------------------------------
*/                         
method ImageCount() class THTree
return len(::faImages)

/*
--------------------------------------------------------------------------------------
Método expandNode
Arg: acName -> string, nome do node a ser expadido
--------------------------------------------------------------------------------------
*/                         
method ExpandNode(acName) class THTree
	local aNode := ::SearchNode(acName, ::Nodes())
	
	if valType(aNode) == "A"
		aNode[7] := .t.
		if !empty(aNode[12])
			::ExpandNode(aNode[12])
		endif
	endif
	
return 

/*
--------------------------------------------------------------------------------------
Propriedade URLFrame
Arg: acURLFrame -> string, frame destino
--------------------------------------------------------------------------------------
*/                         
method urlFrame(acValue) class THTree

	property ::fcURLFrame := acValue
	
return ::fcURLFrame


/*
--------------------------------------------------------------------------------------
Propriedade Background
Arg: acImageFile -> string, path+nome do arquivo a ser colocado como background
--------------------------------------------------------------------------------------
*/                         
method Background(acImageFile) class THTree

	property ::fcBackground := acImageFile

return ::fcBackground

/*
--------------------------------------------------------------------------------------
Propriedade Backcolor
Arg: acColor -> string, cor rgb em hexa, será a cor de fundo da árvore
--------------------------------------------------------------------------------------
*/                         
method Backcolor(acColor) class THTree

	property ::fcBackcolor := acColor

return ::fcBackcolor

/*
--------------------------------------------------------------------------------------
Propriedade Nodes
--------------------------------------------------------------------------------------
*/                         
method Nodes() class THTree

return ::faNodes

/*
--------------------------------------------------------------------------------------
Ajusta string de node
--------------------------------------------------------------------------------------
*/                         
method SetString(acName, acValue) class THTree
	local aNode := ::SearchNode(acName, ::Nodes())
	
	if valType(aNode) == "A"
		aNode[8] := acValue
	endif
return

/*
--------------------------------------------------------------------------------------
Nome do appName
--------------------------------------------------------------------------------------
*/                         
method AppName() class THTree

return 'app' + ::Name()

/*
--------------------------------------------------------------------------------------
Texto do nó "root"
--------------------------------------------------------------------------------------
*/                         
method RootCaption(acValue) class THTree

	property ::fcRootCaption := acValue
	
return ::fcRootCaption

/*
--------------------------------------------------------------------------------------
URL do nó "root"
--------------------------------------------------------------------------------------
*/                         
method RootURL(acValue) class THTree

	property ::fcRootURL := acValue
	
return ::fcRootURL

/*
--------------------------------------------------------------------------------------
Subtema
--------------------------------------------------------------------------------------
*/                         
method SubTheme(acValue) class THTree

	property ::fcSubTheme := acValue
	
return ::fcSubTheme