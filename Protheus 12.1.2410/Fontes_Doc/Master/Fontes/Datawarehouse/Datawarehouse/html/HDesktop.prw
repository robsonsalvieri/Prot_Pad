// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Htm
// Fonte  : HtmDesktop - Objeto THDesktop, responsável pela arvore e icones
// Dependencia Externa:
//				JSTree.js
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 06.05.02 | 1666-Debaldo      |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "hDesktop.ch"

/*
--------------------------------------------------------------------------------------
Classe: THDesktop
Uso   : Navegação em árvore (tree)
--------------------------------------------------------------------------------------
*/
class THDesktop from THItem

	data fcName
	data faNodes
	data faNodesDSK
	data faCoord
	data fcCSSName
	data fcURLFrame
	data fnIconesDef
	
	method New(aoPage) constructor
	method Free()       
	method NewHDesktop(aoPage)
	method FreeHDesktop()       
	
	method Name(acValue)
	method CSSName(acValue)
	method Width(anValue)
	method Height(anValue)
	
	method Buffer(aaBuffer)
	method Nodes()
	method NodesDSK()
	method AppName()
	method AddConsulta(anID, acName, acTipo, acDescricao, alHaveTable, alHaveGraph)
	method AddDSKConsulta(anIDParent, anID, acName, alType, acTipo, acDescricao, alHaveTable, alHaveGraph)
	method IconesDef()

endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(aoPage) class THDesktop
               
	::NewHDesktop(aoPage)
	
return

method Free() class THDesktop

	::FreeHDesktop()

return

method NewHDesktop(aoPage) class THDesktop

	::NewHItem(aoPage)
	::faCoord := { NIL, NIL }
	::fcCSSName := "tree"
	::faNodes := {}
	::faNodesDSK := {}
	::fnIconesDef := 1
	
return

method FreeHDesktop() class THDesktop

	::FreeHItem()

return

/*
--------------------------------------------------------------------------------------
Propriedade Name
--------------------------------------------------------------------------------------
*/                         
method Name(acValue) class THDesktop
               
	property ::fcName := acValue
	
return ::fcName

/*
--------------------------------------------------------------------------------------
Propriedade Icones Default
--------------------------------------------------------------------------------------
*/                         
method IconesDef(anValue) class THDesktop

	property ::fnIconesDef := anValue

return ::fnIconesDef

/*
--------------------------------------------------------------------------------------
Propriedade Width
--------------------------------------------------------------------------------------
*/                         
method Width(anValue) class THDesktop
               
	property ::faCoord[1] := anValue
	
return ::faCoord[1]

/*
--------------------------------------------------------------------------------------
Propriedade Height
--------------------------------------------------------------------------------------
*/                         
method Height(anValue) class THDesktop
               
	property ::faCoord[2] := anValue
	
return ::faCoord[2]

/*
--------------------------------------------------------------------------------------
Propriedade Class
--------------------------------------------------------------------------------------
*/                         
method CSSName(acValue) class THDesktop
	
	property ::fcCSSName := acValue
	
return ::fcCSSName

/*
--------------------------------------------------------------------------------------
Código HTM para o item
Arg: aaBuffer -> array, local de geração do HTML
Ret: cRet -> string, texto gerado
--------------------------------------------------------------------------------------
*/                         
method Buffer(aaBuffer) class THDesktop             
	local cAux    := "", aBuffer := {}, nInd, x
	Local aParams := {}
	Local aPesq   := {}
	Local cNom    := ""
	Local nPosCar := 0

	if valType(::Page()) != "U" .and. !empty(::Page():GoURL())
		return
	endif

	if valType(aaBuffer) != "U"
		aBuffer := aaBuffer
	endif
	
	aAdd(aBuffer, "<div name=" + ::Name() + " id=" + ::Name() + " class=" + ::CSSName() + ">") //onmouse=g.mouseout(off)
	
	cAux := urlImage("ic_corner.gif",.f., "hdesktop", .t.)
	aAdd(aParams, {"imagePath", left(cAux, rat("/", cAux)-1)})
	aAdd(aParams, {"CREATE_NODE_CONN", "5"})
	aAdd(aParams, {"CREATE_NODE_SLEEP", "500"})
	aAdd(aParams, {"LABEL_MY_FAVORITES", STR0004} ) //###"Meus Favoritos"
	aAdd(aParams, {"LABEL_DEFAULT_SCENARIO", STR0005} ) //###"Padrão"
	aAdd(aParams, {"LABEL_SCENARIO_MAINTENAINCE", STR0006} ) //###"Cenários (para incluir ou excluir, clique com o botão direito do mouse)"
	aAdd(aParams, {"LABEL_NEW_FOLDER", STR0007} ) //###"Nome da nova pasta:"
	aAdd(aParams, {"LABEL_ADDING_FOLDER", STR0008} ) //###"Adicionando pasta"
	aAdd(aParams, {"LABEL_NEW_SCENARIO", STR0009} ) //###"Nome do cenário:" 
	aAdd(aParams, {"LABEL_ASK_DEL_SCENARIO", STR0010} ) //###"Deseja realmente excluír o cenário "
	aAdd(aParams, {"LABEL_DEL_SCENARIO", STR0011} ) //###"Excluír o cenário"
	aAdd(aParams, {"LABEL_URL_WALLPAPER", STR0012} ) //###"Url da imagem de papel de parede:"
	aAdd(aParams, {"LABEL_WALLPAPER", STR0013} ) //###"Definir papel de parede"
	aAdd(aParams, {"LABEL_NEW_LINK", STR0014} ) //###"Url do arquivo:"
	aAdd(aParams, {"LABEL_ADDING_LINK", STR0015} ) //###"Adicionando link"
	aAdd(aParams, {"LABEL_TABLE", STR0016} ) //###"Tabela"
	aAdd(aParams, {"LABEL_GRAPH", STR0017} ) //###"Gráfico"
	aAdd(aParams, {"LABEL_FOLDER", STR0018} ) //###"Pasta"
	aAdd(aParams, {"LABEL_UPPER", STR0019} ) //###"Acima"
	aAdd(aParams, {"LABEL_NEW", STR0020} ) //###"Nova"
	aAdd(aParams, {"LABEL_ADDING_SCENARIO", STR0021} ) //###"Adicionar cenário"
	aAdd(aParams, {"LABEL_FILE", STR0022} ) //###"Arquivo"
	aAdd(aParams, {"LABEL_RENAME", STR0023} ) //###"Renomear"
	aAdd(aParams, {"LABEL_RENAMING", STR0024} ) //###"Renomeando nome "
	aAdd(aParams, {"LABEL_NEW_FILE", STR0025} ) //###"Novo"	

	// Caracteres especiais que serão retirados para o tratamento do html ocorrer de forma correta.		
	aPesq := {".", "#", "*", "@", "-"} 
			
	cNom := ::Name()
	
	// Tirar caracteres especiais e concatenar nome.
	For nInd := 1 To Len(aPesq)					
		
		nPosCar := At( aPesq[nInd], cNom ) // Recebe a posição do caractere especial, caso Exista.
					
		If nPosCar > 0			
			// Tira caractere especial.
			cNom := SubStr(cNom, 1, nPosCar - 1) + "" + SubStr(cNom, nPosCar + 1) 
			 
			// Zera contadora, para caso exista este mesmo caractere novamente.
			nInd := 0							
		EndIf
		
	Next nInd
	
	::Name(cNom) // Atribui o nome sem caracteres especiais.		
	
	// Chama applet java para montagem de desktop do usuário.
	tagApplet("br.com.microsiga.sigadw.applet.DWScriptDesktop", "app"+::Name(), ::Width(),  ::Height(), aParams, aBuffer)
	
	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, tagJS())
	aAdd(aBuffer, "function InitDesktop"+::AppName()+"()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "	var oApp = getApplet('"+::AppName()+"');")
	
	aAdd(aBuffer, '	oApp.addRoot(0, "' + STR0001 + '", 0);') //###"Desktop"
    aAdd(aBuffer, '	oApp.addRoot(1, "' + STR0002 + '", 8);') //###"Consultas"
    aAdd(aBuffer, '	oApp.addRoot(-99, 0, "' + STR0003 + '", 9);') //###"Favoritos"
	aAdd(aBuffer, '	oApp.addScenario(-1, "' + STR0005 + '");') //###"Padrão"
    	
	for nInd := 1 to len(::faNodes)
		x := ::faNodes[nInd]
		aAdd(aBuffer, " oApp.addNode('" + x[2] + "'," + DWStr(x[1]) + ", 2, 1, 8, true, " + iif(x[3] == "P"," 2, 2, '"," 3, 3, '") + x[3] + "','"+x[4]+"','"+iif(x[5], "1", "0")+iif(x[6], "1", "0")+"', " + iif(x[7], "true", "false") + ");")
	next
	
	for nInd := 1 to len(::faNodesDSK)
		x := ::faNodesDSK[nInd]
		// verifica se é um nó do tipo FOLDER OU é WALLPAPER
		if (x[4]==3 .OR. x[4]==12)
			aAdd(aBuffer, ' oApp.addNode("'+x[3]+'",'+DWStr(x[2])+', 0, '+DWStr(x[1])+','+DWStr(x[4])+', false, 0, 1, "'+ x[5]+'","","'+iif(x[7], "1", "0")+ iif(x[8], "1", "0") +'", ' + iif(x[9], "true", "false") + ');')
		else
			aAdd(aBuffer, ' oApp.addNode("'+x[3]+'",'+DWStr(x[2])+', 0, '+DWStr(x[1])+','+DWStr(x[4])+', false, ' + iif(x[5] == "P", " 2, 2", " 3, 3") + ',"'+x[5] + '","'+dwStr(x[6])+'","'+iif(x[7], "1", "0")+ iif(x[8], "1", "0") +'", ' + iif(x[9], "true", "false") + ');')
		endif
	next
	
	aAdd(aBuffer, " oApp.finalizedLoading()")
	aAdd(aBuffer, "}")
	aAdd(aBuffer, "</script>")
	
	aAdd(aBuffer, tagJS())
	
	aAdd(aBuffer, "	function u_bodyonload() {")
	aAdd(aBuffer, "		InitDesktop" + ::AppName() + "();")
	aAdd(aBuffer, "	}")
	
	aAdd(aBuffer, "</script>")
	
return DWConcatWSep(CRLF, aBuffer)

/*
--------------------------------------------------------------------------------------
Adiciona nós (nodes) a árvore
Arg: acParent -> string, nome do nó pai. Se vazio, insere como raiz
     acName -> string, nome do nó. Deve ser único.
     acCaption-> string, titulo do nó
     alCanSubnodes-> string, indica que o nó poderá vir a ter sub-nós
     acURL -> string, URL a ser executada quando nó acionado
	 alQryMaintPerm -> booleana, indica se o usuário pode ou não dar manutenção na consulta
Ret: lRet -> lógico, indica que o nó foi adicionado
--------------------------------------------------------------------------------------
*/                         
method AddConsulta(anID, acName, acTipo, acDescricao, alHaveTable, alHaveGraph, alQryMaintPerm) class THDesktop
   local lRet := .f.
	   
	aAdd(::faNodes, { anId, acName, acTipo, acDescricao, alHaveTable, alHaveGraph, alQryMaintPerm })
	lRet := .t.

return lRet

/*
--------------------------------------------------------------------------------------
Adiciona nós (nodes) a árvore
Arg: anIDParent -> numerico, Node pai
     anID -> ID da consulta
	 acName -> string, Nome
	 alType -> string, Type
	 acTipo -> string, Tipo
	 acDescricao -> string, descricao
	 alHaveTable -> logico, indica que há tabela
	 alHaveGraph -> logico, indica que há gráfico
	 alQryMaintPerm -> booleana, indica se o usuário pode ou não dar manutenção na consulta
Ret: lRet -> lógico, indica que o nó foi adicionado
--------------------------------------------------------------------------------------
*/                         
method AddDSKConsulta(anIDParent, anID, acName, alType, acTipo, acDescricao, alHaveTable, alHaveGraph, alQryMaintPerm) class THDesktop

	aAdd(::faNodesDSK, { anIDParent, anID, acName, alType, acTipo, acDescricao, alHaveTable, alHaveGraph, alQryMaintPerm })

return .t.

/*
--------------------------------------------------------------------------------------
Propriedade Nodes
--------------------------------------------------------------------------------------
*/                         
method Nodes() class THDesktop

return ::faNodes

/*
--------------------------------------------------------------------------------------
Propriedade Desktop
--------------------------------------------------------------------------------------
*/                         
method NodesDSK() class THDesktop

return ::faNodesDSK

/*
--------------------------------------------------------------------------------------
Nome do appName
--------------------------------------------------------------------------------------
*/                         
method AppName() class THDesktop

return 'app' + ::Name()