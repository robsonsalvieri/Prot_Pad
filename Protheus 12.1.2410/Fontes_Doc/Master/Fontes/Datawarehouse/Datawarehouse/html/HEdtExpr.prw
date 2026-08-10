// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Htm
// Fonte  : hEdtExpr - funções de geração de HTML de uso geral
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.06.06 | 0548-Alan Candido | Versão 3
// 18.01.08 | 0548-Alan Candido | BOPS 139342 - Implementação e adequação de código, 
//          |                   | em função de re-estruturação para compartilhamento de 
//          |                   | código.
// 10.04.08 | 0548-Alan Candido | BOPS 142154
//          |                   | Implementacao da macro @dwref na arvore de apoio
// 25.04.08 | 0548-Alan Candido | BOPS 144755
//          |                   | Correção na edição de expressões de alertas
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "dwQueryManu.ch"
#include "tbiconn.ch"
#INCLUDE "makeimp.ch"
#include "dwmakeim.ch"
#include "dwidprocs.ch"
#include "hEdtExpr.ch"

//Define a largura do campo de expressão de acordo com a versão do Protheus.
#ifdef VER_P10
	#define EXP_COLS 	80 
#else            
	#define EXP_COLS  	60 
#endif

/*
--------------------------------------------------------------------------------------
Código para construção de editor de expressões
--------------------------------------------------------------------------------------
*/
#define TYPE_EXP_SQL   "1"
#define TYPE_EXP_ADVPL "2"

#define IX_SIZE        11
#define IX_ISSQL        1
#define IX_CANCHANGE    2
#define IX_CANCOPY      3
#define IX_CANEDIT      4
#define IX_OBJ          5
#define IX_OBJID        6
#define IX_DOCTO        7
#define IX_EMBEDDED     8
#define IX_ALIAS        9
#define IX_EMPFIL      10
#define IX_SAMPLE      11

#define BAS_ID_PARAGRAFO     "1"
#define BAS_PARAGRAFO        { "Lorem ipsum dolor sit amet, consectetuer adipiscing sed diem nonummy nibh...", ;
                               "", ;
                               "Lorem ipsum dolor sit amet, consectetuer adipiscing sed diem nonummy nibh..." }

#define BAS_ID_ITALIC        "2"
#define BAS_ITALIC           { "*Lorem ipsum* dolor sit amet, ..." }

#define BAS_ID_UNDERLINE     "3"
#define BAS_UNDERLINE        { "_Lorem ipsum_ dolor sit amet, ..." }

#define BAS_ID_BOLD          "4"
#define BAS_BOLD             { "**Lorem ipsum** dolor sit amet, ..." }

#define BAS_ID_IDENT         "5"
#define BAS_IDENT            { "Lorem ipsum dolor sit amet, consectetuer adipiscing sed diem nonummy nibh..." ,;
                               "]", ;
															 "Lorem ipsum dolor sit amet, consectetuer adipiscing sed diem nonummy nibh..." ,;
                               "]", ;
															 "Lorem ipsum dolor sit amet, consectetuer adipiscing sed diem nonummy nibh..." ,;
                               "[", ;
                               "[", ;
															 "Lorem ipsum dolor sit amet, consectetuer adipiscing sed diem nonummy nibh..." }

#define HED_ID_TITLE         "10"
#define HED_TITLE            { "Lorem ipsum dolor", ;
                               "", ;
                               "Lorem ipsum dolor sit amet, consectetuer adipiscing sed diem nonummy nibh..." }
#define HED_ID_SUBTITLE      "11"
#define HED_SUBTITLE         { "=Lorem ipsum dolor", ;
                               "", ;
                               "Lorem ipsum dolor sit amet, consectetuer adipiscing sed diem nonummy nibh..." }

#define LIS_ID_BULLET        "20"
#define LIS_BULLET           { ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ; 
                               ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ;
                               ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh..." }

#define LIS_ID_NUMBER        "23"
#define LIS_NUMBER           { ".1 Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ; 
                               ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ;
                               ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh..." }

#define LIS_ID_ALPHA         "24"
#define LIS_ALPHA            { ".a Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ; 
                               ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ;
                               ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh..." }

#define LIS_ID_ROMAN         "26"
#define LIS_ROMAN            { ".i Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ; 
                               ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ;
                               ". Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh..." }

#define SPC_ID_LINE         "30"
#define SPC_LINE            { "Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh...", ; 
                               "---", ;
                               "Lorem ipsum dolorsit amet, consectetuer adipiscing sed diem nonummy nibh..." }

#define SPC_ID_LINK         "31"
#define SPC_LINK            "Lorem ipsum dolor sit amet [link:http://meusite.com.br], consectetuer adipiscing sed diem nonummy nibh..."

#define SPC_ID_MAIL         "32"
#define SPC_MAIL            "Lorem ipsum dolor sit amet [email:fulano@servidor], consectetuer adipiscing sed diem nonummy nibh..."

#define SPC_ID_MAILEX       "33"
#define SPC_MAILEX          "Lorem ipsum dolor sit amet [email:fulano@servidor fulano de tal], consectetuer adipiscing sed diem nonummy nibh..."

#define SPC_ID_IMG          "34"
#define SPC_IMG             "Lorem ipsum dolor sit amet [img:logo_dw_red.gif], consectetuer adipiscing sed diem nonummy nibh..."

#define SPC_ID_IMGLEFT      "35"
#define SPC_IMGLEFT         "Lorem ipsum dolor sit amet [img:logo_dw_red.gif 1], consectetuer adipiscing sed diem nonummy nibh..."

#define SPC_ID_IMGRIGHT     "36"
#define SPC_IMGRIGHT        "Lorem ipsum dolor sit amet [img:logo_dw_red.gif 2], consectetuer adipiscing sed diem nonummy nibh..."

#define SPC_ID_REF          "37"
#define SPC_REF             "Lorem ipsum dolor sit amet [ref:Trecho em latim], consectetuer adipiscing sed diem[ref:Também é latim] nonummy nibh..."

#define SPC_ID_SCHEMA       "38"
#define SPC_SCHEMA          { "Lorem ipsum dolor sit amet",;
														  "[schema]", ;
														  "consectetuer adipiscing sed diem nonummy nibh..." }
static __oRPC

function buildEdtExpr(acFormName, acTitle, alIsSQL, alCanChange, alSave, alCancel, alExecute, alRemove, alCopy, alBack, ;
			alEdit, acObj, anObjID, alDocto, alEmbedded, acAlias, acEmpFil, alSample) 
	local aBuffer := {}, aAux
	local lCmdButtons := .f., aButtons := {}
	local lEdit := !(dwVal(HttpGet->Oper) == OP_SUBMIT .or. dwVal(HttpGet->Oper) == OP_REC_DEL)
  	local oIFrames, aAuxFields

	default alSave    := .f.
	default alCancel  := .f.
	default alExecute := .f.
	default alRemove  := .f.
	default alCopy    := .f.
	default alBack    := .f.
	default alEdit    := .f.
	default acObj     := ""
	default anObjID   := 0
	default alDocto   := .f.
	default alEmbedded:= .f.
	default acAlias   := ""
	default acEmpFil  := ""
	default alSample  := .f.

	aAux := array(IX_SIZE)
	aAux[IX_ISSQL    ] := alIsSQL
	aAux[IX_CANCHANGE] := alCanChange
	aAux[IX_CANCOPY  ] := alCopy
	aAux[IX_CANEDIT  ] := alEdit
	aAux[IX_OBJ      ] := acObj
	aAux[IX_OBJID    ] := anObjID
	aAux[IX_DOCTO    ] := alDocto
	aAux[IX_EMBEDDED ] := alEmbedded
	aAux[IX_ALIAS    ] := acAlias
	aAux[IX_EMPFIL   ] := acEmpFil
	aAux[IX_SAMPLE   ] := alSample 
		
	dwSetProp("paramsEdt", aAux, "BUILDEDTEXPR")
  
	oIFrames := THIFrameMan():New()
	oIFrames:action(httpget->Action)
	//Define os iFrames da tela de Construção de Expressões. 
	oIFrames:AddFrame("iExpressao", "", 370, 480, {{"ReturnType", HttpGet->ReturnType}})
	oIFrames:AddFrame("iAuxiliar", "", 270, 480, {{"ReturnType", HttpGet->ReturnType}})
	oIFrames:Width(1)
	oIFrames:Height(1)
	
	lCmdButtons := alSave .or. alCancel .or. alExecute .or. alRemove .or. alCopy .or. alBack .or. alDocto
	
	aAdd(aBuffer, '<!-- buildEdtExp start -->')

	if lCmdButtons
		aAdd(aBuffer, tagJS())
		aAdd(aBuffer, "function " + acFormName+"submit(oSender)")
		aAdd(aBuffer, "{")
		aAdd(aBuffer, "  return false;")
		aAdd(aBuffer, "}")

		aAdd(aBuffer, "function " + acFormName+"_doExecEdtCmd(anCommand) {")
		aAdd(aBuffer, "	 var oForm = getElement('"+acFormName+"');")
		aAdd(aBuffer, "  if (anCommand == '"+EDT_CMD_COPY+"') {") 	   
		aAdd(aBuffer, " 	var oTextArea = getElement('edTextArea', window.frames['iExpressao'].document);")
		aAdd(aBuffer, " 	var oTextBase = getElement('edTextBase', window.frames['iExpressao'].document);")	
		aAdd(aBuffer, "  	oTextArea.value = oTextBase.value + ' ';")
		aAdd(aBuffer, "    	oTextArea.focus();")	
		aAdd(aBuffer, "  } else {") 	
		aAdd(aBuffer, "    	var oCmdTextArea = getElement('edCmdTextArea');")
		aAdd(aBuffer, "    	var oText = getElement('edText');")
		aAdd(aBuffer, "    	oCmdTextArea.value = anCommand;")
		aAdd(aBuffer, "    	oText.value = escape(getElement('edTextArea', window.frames['iExpressao'].document).value);")
		aAdd(aBuffer, "    	oForm.submit();")
		aAdd(aBuffer, "  }")
		aAdd(aBuffer, "  return false;")
		aAdd(aBuffer, "}")
		aAdd(aBuffer, "</script>")
	endif			

	if lCmdButtons
		if alSave
			makeButton(aButtons, BT_JAVA_SCRIPT, STR0013, acFormName+"_doExecEdtCmd('"+EDT_CMD_SAVE+"')") //###"Salvar"
		endif
		
		if alCancel
			makeButton(aButtons, BT_JAVA_SCRIPT, STR0015, acFormName+"_doExecEdtCmd('"+EDT_CMD_CANCEL+"')") //###"Cancelar"
		endif
		
		if alExecute
			makeButton(aButtons, BT_JAVA_SCRIPT, STR0027, acFormName+"_doExecEdtCmd('"+EDT_CMD_EXECUTE+"')") //###"Executar"
		endif
		
		if alDocto
			makeButton(aButtons, BT_JAVA_SCRIPT, STR0079, acFormName+"_doExecEdtCmd('"+EDT_CMD_VIEW+"')") //###"Visualizar"
		endif
		
		if alRemove
			makeButton(aButtons, BT_JAVA_SCRIPT, STR0029, acFormName+"_doExecEdtCmd('"+EDT_CMD_REMOVE+"')") //###"Remover"
		endif
		
		if alCopy
			makeButton(aButtons, BT_JAVA_SCRIPT, STR0031, acFormName+"_doExecEdtCmd('"+EDT_CMD_COPY+"')") //###"Copiar"
		endif
		
		if alBack
			makeButton(aButtons, BT_PREVIOUS) //, "Copiar", acFormName+"_doExecEdtCmd('"+EDT_CMD_COPY+"')")
		endif
	else
		makeButton(aButtons, BT_CLOSE)
	endif

  	aAuxFields := {}

  	makeHidden(aAuxFields, "edText", "")
  	makeHidden(aAuxFields, "edCmdTextArea", "")
    
	//O caracter especial # junto ao nome do formulário elimina os espaços laterais. 
	aAdd(aBuffer, buildForm("#"+acFormName, acTitle, AC_NONE, "", aButtons, {oIFrames, aAuxFields}, lEdit, "", /*abBody*/, /*abSubmit*/, .f., /*aaCols*/, 'width:100%'))

	aAdd(aBuffer, '<!-- buildEdtExp end -->')
return dwConcatWSep(CRLF, aBuffer)     

/*
--------------------------------------------------------------------------------------
Monta o iframe de edição de expressão
--------------------------------------------------------------------------------------
*/                         
function buildIExpressao(acFormName, acTextBefore, acTextAfter, aaSource, aaBase, ;
							alisSQL, alCanChange, alCanCopy, alCanEdit, alDocto, alEmbedded, acAlias, acEmpFil, alSample)
	local aBuffer := {}, aParams := {}
	local aParamsEdt := getParamsEdt()
	local aInd := {}, aKeys :={}, cAux, i
	local oDim, oCubFacts, oDimCub //oCube, 
	local aAux, aWhere := {}
	local cAlias, aFrom := {}, oTabSX9 := initTable(TAB_SX9)
	local aDe, aPara, nPos
			    
	default aaSource    := {}
	default aaBase      := {}
	default alIsSQL     := aParamsEdt[IX_ISSQL]
	default alCanChange := aParamsEdt[IX_CANCHANGE]
	default alCanCopy   := aParamsEdt[IX_CANCOPY]
	default alCanEdit   := aParamsEdt[IX_CANEDIT]
	default alDocto     := aParamsEdt[IX_DOCTO]
	default alEmbedded  := aParamsEdt[IX_EMBEDDED]
	default acAlias     := aParamsEdt[IX_ALIAS]
	default acEmpFil    := aParamsEdt[IX_EMPFIL]
	default alSample    := aParamsEdt[IX_SAMPLE]
	
	aAdd(aBuffer, '<!-- buildEdtExp start -->')        
	
	// Verfifica se a sql esta vazia para criar a suguestao	
	if  alIsSQL .and. dwConcatWSep(CRLF, aaSource) == "" .and. !(aParamsEdt[IX_OBJ] == OBJ_VIRTFLD_QRY .OR. aParamsEdt[IX_OBJ] == OBJ_VIRTFLD_CUB)
		if aParamsEdt[IX_OBJ] == OBJ_DIMENSION // Dimensao
			oDim := oSigaDW:OpenDim(aParamsEdt[6]) 
			aAdd(aaSource, "SELECT ")
			aAux := oDim:fields()
			for i:= 2 to len(aAux)
				if alEmbedded .and. aAux[i, FLD_NAME] == ATT_M0_CODIGO_NOME
					cAux := "%xEmpresa:"+acAlias + "% " + aAux[i, FLD_NAME]
				elseif alEmbedded .and. right(aAux[i, FLD_NAME], 6) == ATT_XX_FILIAL_NOME
					cAux := "%xFilial:"+acAlias + "% " + aAux[i, FLD_NAME]
					aAdd(aWhere, aAux[i, FLD_NAME] + " = %xFilial:" + acAlias + "% and " + acAlias + ".%notDel%")
				else
					cAux := aAux[i, FLD_NAME]
				endif			

				if !i==len(aAux)
					cAux += ", "
				endif                      
				aAdd(aaSource, "    " + cAux)
			next	      
			aAdd(aaSource, "from")
			if alEmbedded
				aAdd(aaSource, "    %table:" + acAlias + "% " + acAlias)
			else
				aAdd(aaSource, "    <" + STR0108 + ">") //###"DIMENSAO"
			endif

			if len(aWhere) > 0
				aAdd(aaSource, "where")
				aEval(aWhere, { |x| aAdd(aaSource, "    " + x)} )
			endif						
		elseif ( aParamsEdt[IX_OBJ] == OBJ_CUBE .AND. alSample) .OR. aParamsEdt[IX_OBJ] == OBJ_VIRTFLD_QRY .OR. aParamsEdt[IX_OBJ] == OBJ_VIRTFLD_CUB // Cubo OR Campo virtual de consulta ou cubo
			oCubFacts := InitTable(TAB_FACTFIELDS)
			oCubFacts:seek(2 , { aParamsEdt[6] } ) 
			while !oCubFacts:EoF() .and. oCubFacts:value("id_cubes") == aParamsEdt[6]			
				if oCubFacts:value("dimensao") == 0
					aAdd(aInd, oCubFacts:value("nome"))
				endif
				oCubFacts:_Next()
			enddo	

			aAdd(aaSource, "select ")
			for i := 1 to len(aInd)
				aAdd(aaSource, "  " + aInd[i] + ",")
			next     

			oDimCub := InitTable(TAB_DIM_CUBES)			
			oDimCub:Seek(2, { aParamsEdt[6] })
			while !oDimCub:EoF() .and. oDimCub:value("id_cube") == aParamsEdt[6]
				oDim := oSigaDW:OpenDim(oDimCub:value("id_dim"))			
				aAdd(aaSource, "  --" + oDim:Descricao())
				aKeys := oDim:Indexes()[2,4]
		    	if len(aKeys) > 0
					cAlias := oDim:alias()
					aDe := {}
					aPara := {}
		    		if !(cAlias==DIM_EMPFIL) .and. !(cAlias == acAlias)
//						aAdd(aFrom, "%table:" + cAlias + "% " + cAlias)
						if oTabSX9:seek(2, { acAlias, cAlias } )
							aDe := dwToken(oTabSx9:value("EXPDOM"), "+")
							aPara := dwToken(oTabSx9:value("EXPCDOM"), "+")
						endif
					endif
					
					for i:=1 to len(aKeys)                                    
						if alEmbedded .and. aKeys[i] == ATT_M0_CODIGO_NOME
							cAux := "%xEmpresa:" + cAlias + "% " + iif(cAlias==DIM_EMPFIL, "", cAlias + "_") + aKeys[i]
						elseif alEmbedded .and. aKeys[i] == ATT_M0_CODFIL_NOME
							cAux := "%xFilial:" + cAlias + "% " + iif(cAlias==DIM_EMPFIL, "", cAlias + "_") + aKeys[i]
						elseif alEmbedded .and. right(aKeys[i], 6) == ATT_XX_FILIAL_NOME
							cAux := "%xFilial:" + cAlias + "% " + aKeys[i]
							if cAlias == acAlias
								aAdd(aWhere, aKeys[i] + " = %xFilial:" + cAlias + "% and " + cAlias + ".%notDel%")
							endif
						else
							cAux := aKeys[i]
							nPos := ascan(aDe, { |x| x == cAux} )
							if nPos > 0
								cAux := aPara[nPos] + " " + cAux
							endif
						endif
						aAdd(aaSource, "    " + cAux + ",")
					next
				endif                  
				oDimCub:_next()
			enddo          
			aaSource[len(aaSource)] := left(aaSource[len(aaSource)], len(aaSource[len(aaSource)])-1)
			aAdd(aaSource, "from")

			if alEmbedded
				aAdd(aFrom, "%table:" + acAlias + "% " + acAlias)
				aEval(aFrom, { |x,i| aFrom[i] := aFrom[i] + "," }, 1, len(aFrom)-1 )
				aEval(aFrom, { |x| aAdd(aaSource, "    " + x) } )
			else
				aAdd(aaSource, "    <" + STR0109 + ">") //###"CUBO"
			endif

			if len(aWhere) > 0
				aAdd(aaSource, "where")
				aEval(aWhere, { |x,i| aWhere[i] := aWhere[i] + " and" }, 1, len(aWhere)-1 )
				aEval(aWhere, { |x| aAdd(aaSource, "    " + x )} )
			endif						
		endif
	endif

	if !empty(acTextBefore)
		prepMsg(aParams, acTextBefore, alIsSQL, alDocto)
	endif

	if alCanChange
		makeRadioField(aParams, "isSQL", "|" + STR0017,.t.,,iif(alIsSQL, TYPE_EXP_SQL, TYPE_EXP_ADVPL), { { "SQL", TYPE_EXP_SQL} , { "Adv/PL", TYPE_EXP_ADVPL }}) //###"Este bloco de código é uma expressão "
	elseif alDocto
		makeShow(aParams, "edTypeExpr", "|" + STR0017, STR0043) //###"Este bloco de código é uma expressão "###"Texto estruturado"
	else
		makeShow(aParams, "edTypeExpr", "|" + STR0017,iif(alIsSQL, "SQL", "Adv/PL")) //###"Este bloco de código é uma expressão "
		makeHidden(aParams, "isSQL", iif(alIsSQL, CHKBOX_ON, CHKBOX_OFF))
	endif
	
	if alCanCopy
#ifdef VER_P10
		makeTextArea(aParams, "edTextArea", "|" + STR0080, .f., EXP_COLS, 13,, dwConcatWSep(CRLF, aaSource)) //###"Expressão"
		makeTextArea(aParams, "edTextBase", "|" + STR0081, .f., EXP_COLS, 13,, dwConcatWSep(CRLF, aaBase)) 	 //###"Expressão (base)"
#else
		makeTextArea(aParams, "edTextArea", "|" + STR0080, .f., EXP_COLS, 10,, dwConcatWSep(CRLF, aaSource)) //###"Expressão"
		makeTextArea(aParams, "edTextBase", "|" + STR0081, .f., EXP_COLS, 9,, dwConcatWSep(CRLF, aaBase)) 	 //###"Expressão (base)"
#endif
	else
#ifdef VER_P10
		makeTextArea(aParams, "edTextArea", "|" + STR0080, .f., EXP_COLS, 29,, dwConcatWSep(CRLF, aaSource)) //###"Expressão"
#else
		makeTextArea(aParams, "edTextArea", "|" + STR0080, .f., EXP_COLS, 22,, dwConcatWSep(CRLF, aaSource)) //###"Expressão"
#endif
	endif

	if !empty(acTextAfter)
		prepMsg(aParams, acTextAfter, alIsSQL, alDocto)
	endif
	
	buildBodyFields(aBuffer, aParams, alCanEdit)

	aAdd(aBuffer, tagJS("doInsEdtExp"))
	                                
	aAdd(aBuffer, "function doInsEdtExp(acString)")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  var oTextArea = getElement('edTextArea', getParentElement(document).iExpressao);")
	aAdd(aBuffer, "  oTextArea.value += (oTextArea.length == 0?'':' ') + acString;")
	aAdd(aBuffer, "  oTextArea.change();")
	aAdd(aBuffer, "  oTextArea.focus();")
	aAdd(aBuffer, "}")
	aAdd(aBuffer, "</script>")      
	
	aAdd(aBuffer, '<!-- buildEdtExp end -->')
return "<html><body><form id='>" + acFormName + "'>" + dwConcatWSep(CRLF, aBuffer) + "</form></body></html>"

/*
--------------------------------------------------------------------------------------
Prepara as mensagens padrão para o from de edição de expressões
--------------------------------------------------------------------------------------
*/                         
static function prepMsg(aaFields, acMsg, alIsSQL, alDocto)
	local aMsg := DWToken(acMsg, "|")
	local cAux := ""

	if alDocto
	elseif len(aMsg) == 1	
		if left(acMsg, 2) == "@1" .or. left(acMsg, 2) == "@4" 
			cAux := dwFormat(STR0001 + "'[!X]'" + STR0002, { "<b>DW_VALUE</b>" }) //###"A variável reservada "###" conterá o valor de retorno."
			makeWarning(aaFields, cAux)
		elseif left(acMsg, 2) == "@2"
			if right(acMsg, 1) == "S"
				cAux := STR0082 //###"comando SQL"
			elseif right(acMsg, 1) == "L"
				cAux := STR0004 //###"logico"
			elseif right(acMsg, 1) == "D"
				cAux := STR0005 //###"data"
			elseif right(acMsg, 1) == "N"
				cAux := STR0006 //###"numérico"
			elseif right(acMsg, 1) == "A"
				cAux := STR0007 //###"array"
			else
				cAux := STR0008 //###"string"
			endif
			makeShow(aaFields, "edTipoRet", "|" + STR0003, cAux) //###"Este procedimento deverá ter como retorno, um valor do tipo "
		elseif left(acMsg, 2) == "@3" 
			cAux := iif(alIsSQL, "", "|" + STR0083) //###"As variavéis de trabalho devem possuir o prefixo 'dw' ou terem o escopo 'local'"
			//As variavéis de trabalho devem possuir o prefixo 'dw' ou terem o escopo 'local'")
			makeWarning(aaFields, cAux)
	   endif
	else
		aEval(aMsg, { |x| prepMsg(aaFields, x, alIsSQL) })
	endif                                                          
return

/*
--------------------------------------------------------------------------------------
Monta o iframe de apoio
--------------------------------------------------------------------------------------
*/                                                         	
function buildIAuxiliar(acFormName, alisSQL, acObj, anObjID, alDocto) 
  	local aAux := {}, aOpers := {}, oDim, oTree, oTreeList, oCube, oCubsFacts
  	local oDimCubs, aBuffer := {}
  	local aKeys, i, x, aCubInd
	local aParamsEdt := getParamsEdt()
	local oFilter, oConsulta
	local aFields, aEsp := {}
	
	default alIsSQL := aParamsEdt[IX_ISSQL]
	default acObj   := aParamsEdt[IX_OBJ]
	default anObjID := aParamsEdt[IX_OBJID]
	default alDocto := aParamsEdt[IX_DOCTO]
                                                    
	if alDocto
	elseif alIsSQL
		aAux := { "+", "-", "/", "*", "**", "(", ")", "=", ">", "<", ">=", "<=", "<>" }
		aEsp := { "@dwref(tipo, identificador)", "@dwref(tipo, identificador, titulo)", ;
              "@dwref(C, identificador)", "@dwref(C, identificador, titulo)", ;
              "@dwref(D, identificador)", "@dwref(D, identificador, titulo)", ;
              "@dwref(N, identificador)", "@dwref(N, identificador, titulo)" }
	else
		aAux := { "+", "-", "/", "*", "**", "(", ")", "$", "==", ">", "<", ">=", "<=", "<>" }
	endif
          
  // cria a lista de árvores
	oTreeList := THTreeList():New()
	oTreeList:Name("attCube")
	oTreeList:Width(1)
	oTreeList:Height(1)

	if len(aAux) > 0	
		oTree := THTree():New()
		oTree:Name("attOpers")
		oTree:SubTheme("treeDim")
		oTree:Width(1)
		oTree:UrlFrame("_self") 
		oTree:RootCaption(STR0111) //###"Apoio"
		oTree:AddNode(nil, "na_oper", STR0037) //###"Operadores"
		aEval(aAux, { |x, i| oTree:AddNode("na_oper", "na_oper"+dwStr(i), x, .f., "javascript:doInsEdtExp(\'"+x+"\')")})
		if len(aEsp) > 0
			oTree:AddNode(nil, "na_esp", STR0112) //###"Especiais"
			aEval(aEsp, { |x, i| oTree:AddNode("na_esp", "na_esp"+dwStr(i), x, .f., "javascript:doInsEdtExp(\'"+x+"\')")})
		endif
  		oTreeList:addToList(oTree)
	endif

	if alDocto
		oTree := THTree():New()
		oTree:Name("attStrucText")
		oTree:Width(1)
		oTree:UrlFrame("_self") 
		oTree:RootCaption(STR0043) //###"Texto estruturado"

		oTree:AddNode(nil, "na_bas", STR0084) //###"Fomatação básica"
		oTree:AddNode("na_bas", "na_bas1", STR0085		   	, .f., 'javascript:doShowSample('+BAS_ID_PARAGRAFO+")") //###"parágrafo"
		oTree:AddNode("na_bas", "na_bas2", STR0086 + " *"   , .f., 'javascript:doShowSample('+BAS_ID_ITALIC+")") //###"itálico"
		oTree:AddNode("na_bas", "na_bas3", STR0087 + " _"   , .f., 'javascript:doShowSample('+BAS_ID_UNDERLINE+")") //###"sublinhado"
		oTree:AddNode("na_bas", "na_bas4", STR0088 + " **"  , .f., 'javascript:doShowSample('+BAS_ID_BOLD+")") //###"negrito"
		oTree:AddNode("na_bas", "na_bas5", STR0089 + " ] ["	, .f., 'javascript:doShowSample('+BAS_ID_IDENT+")") //###"identação"

		oTree:AddNode(nil, "na_hed", STR0090) //###"Titulos"
		oTree:AddNode("na_hed", "na_hed1", STR0091, .f., 'javascript:doShowSample('+HED_ID_TITLE+")") //###"titulo"
		oTree:AddNode("na_hed", "na_hed2", STR0092, .f., 'javascript:doShowSample('+HED_ID_SUBTITLE+")") //###"sub-titulo"

		oTree:AddNode(nil, "na_lis", STR0093) //###"Listas"
		//oTree:AddNode("na_lis", "na_lisO", STR0094) //###"o 1o. item da lista"
		oTree:AddNode("na_lis", "na_lis1", STR0095+chr(223), .f., 'javascript:doShowSample('+LIS_ID_BULLET+")") //###"disco ."
		oTree:AddNode("na_lis", "na_lis4", "1,2,3 .1"+chr(223), .f., 'javascript:doShowSample('+LIS_ID_NUMBER+")")
		oTree:AddNode("na_lis", "na_lis5", "A,B,C .A"+chr(223), .f., 'javascript:doShowSample('+LIS_ID_ALPHA+")")
		//oTree:AddNode("na_lis", "na_lis9", STR0096+chr(223)) //###"demais itens da lista ."

		oTree:AddNode(nil, "na_spc", STR0097) //###"Especiais"
		oTree:AddNode("na_spc", "na_spc1", STR0098 + " ---";
																							          , .f., 'javascript:doShowSample('+SPC_ID_LINE+")") //###"linha horizontal"
		oTree:AddNode("na_spc", "na_spc2", STR0099, .f., 'javascript:doShowSample('+SPC_ID_LINK+")") //###"link externo [link:uri]"
		oTree:AddNode("na_spc", "na_spc3", STR0100, .f., 'javascript:doShowSample('+SPC_ID_MAIL+")") //###"e-mail [email:destinatario@server]"
		oTree:AddNode("na_spc", "na_spc4", STR0101, .f., 'javascript:doShowSample('+SPC_ID_MAILEX+")") //###"e-mail [email:destinatario@server destinatario]"
		oTree:AddNode("na_spc", "na_spc5", STR0102, .f., 'javascript:doShowSample('+SPC_ID_IMG+")") //###"imagem [img:nomeArquivo.gif]"
		oTree:AddNode("na_spc", "na_spc6", STR0103, .f., 'javascript:doShowSample('+SPC_ID_IMGLEFT+")") //###"imagem a esquerda [img:nomeArquivo.gif 1]"
		oTree:AddNode("na_spc", "na_spc7", STR0104, .f., 'javascript:doShowSample('+SPC_ID_IMGRIGHT+")") //###"imagem a direita [img:nomeArquivo.gif 2]"
		oTree:AddNode("na_spc", "na_spc8", STR0105, .f., 'javascript:doShowSample('+SPC_ID_REF+")") //###"refêrencia [ref:texto]"
		oTree:AddNode("na_spc", "na_spc9", STR0106, .f., 'javascript:doShowSample('+SPC_ID_SCHEMA+")") //###"esquema gráfico [schema]"
	
/*
		oTree:AddNode("na_par", "na_par1", "titulo |...", .f., 'javascript:doShowSample('+ID_SAMPLE_TITLE+")")
		oTree:AddNode("na_par", "na_par2", "sub-titulo ||...", .f., 'javascript:doShowSample('+ID_SAMPLE_SUBTITLE+")")
		oTree:AddNode("na_par", "na_par3", "marcação -...", .f., 'javascript:doShowSample('+ID_SAMPLE_MARK+")")
		oTree:AddNode("na_par", "na_par4", "sub-marcação --...", .f., 'javascript:doShowSample('+ID_SAMPLE_SUBMARK+")")
		oTree:AddNode("na_esp", "na_esp3", "envio emails", .t.)
		oTree:AddNode("na_esp3", "na_esp3a", "e-mail [email:destinatario@servidor]", .f., 'javascript:doShowSample('+ID_SAMPLE_MAIL1+")")
		oTree:AddNode("na_esp3", "na_esp3b", "e-mail [email:destinatario@servidor fulano de tal]", .f., 'javascript:doShowSample('+ID_SAMPLE_MAIL2+")")
		oTree:AddNode("na_esp", "na_esp4", "imagens", .t.)
		oTree:AddNode("na_esp4", "na_esp4a", "imagem [img:arquivo.gif]", .f., 'javascript:doShowSample('+ID_SAMPLE_IMG+")")
		oTree:AddNode("na_esp4", "na_esp4b", "imagem a esquerda [img:arquivo.gif 1]", .f., 'javascript:doShowSample('+ID_SAMPLE_IMGL+")")
		oTree:AddNode("na_esp4", "na_esp4c", "imagem a direita [img:arquivo.gif 2]", .f., 'javascript:doShowSample('+ID_SAMPLE_IMGR+")")
*/
  		oTreeList:addToList(oTree)
	endif
		  
	if acObj == OBJ_DIMENSION
		oDim := oSigaDW:OpenDim(anObjID)
	
		oTree := THTree():New()
		oTree:Name("attDim")
		oTree:SubTheme("treeDim")
		oTree:UrlFrame("_self") 
		oTree:RootCaption(oDim:Descricao() + "("+ oDim:Alias() +")")
		aFields := oDim:Fields()
		aKeys := oDim:Indexes()[2,4]
		
	    if len(aKeys) > 0
			oTree:AddNode(nil, "na_key", STR0106, .t., "",, oTree:addImage("ic_att_key_off.gif"), oTree:addImage("ic_att_key_on.gif")) //###"Chave"
		endif
	    
	    if len(aFields) - len(aKeys) - 1 > 0
			oTree:AddNode(nil, "na_att", STR0107, .t., "",, oTree:addImage("ic_dim_att_off.gif"), oTree:addImage("ic_dim_att_on.gif")) //###"Atributo"
		endif
		
		for i := 2 to len(aFields)
			x := aFields[i]
			if ascan(aKeys, {|y| y==x[FLD_NAME]}) == 0
				oTree:AddNode("na_att", "na_att_"+ str(i-1), x[FLD_TITLE], .f., "javascript:doInsEdtExp(\'"+oDim:Alias()+"->"+x[1]+"\')")
			else
				oTree:AddNode("na_key", "na_key_"+ str(i-1), x[FLD_TITLE], .f., "javascript:doInsEdtExp(\'"+oDim:Alias()+"->"+x[1]+"\')")
			endif
		next
    	oTreeList:addToList(oTree)
	elseif acObj == OBJ_CUBE .or. acObj == OBJ_QUERY .or. acObj == OBJ_FILTER .OR. aParamsEdt[IX_OBJ] == OBJ_VIRTFLD_QRY .OR. aParamsEdt[IX_OBJ] == OBJ_VIRTFLD_CUB
		// recupera os indicadores do cubo
    	if acObj == OBJ_QUERY .OR. aParamsEdt[IX_OBJ] == OBJ_VIRTFLD_QRY
      		oConsulta := TConsulta():New(anObjID)
      		nCubeID := oConsulta:CubeID()
    	elseif acObj == OBJ_FILTER
      		oFilter := initTable(TAB_WHERE)
      		oFilter:seek(1, { anObjID } )
      		oConsulta := TConsulta():New(oFilter:value("id_cons"))
      		nCubeID := oConsulta:CubeID()
    	else
      		nCubeID := anObjID
    	endif
        
		oCube := THCube():New(nCubeID)
		aCubInd := {}
	
		oCubsFacts := InitTable(TAB_FACTFIELDS)
		oCubsFacts:Seek(2, { nCubeID })
		while !oCubsFacts:EoF() .and. oCubsFacts:value("id_cubes") == nCubeID
			if oCubsFacts:value("dimensao") == 0
				aAdd(aCubInd, { oCubsFacts:value("nome"), oCubsFacts:value("descricao") })
			endif
			oCubsFacts:_Next()
		enddo
	
		if len(aCubInd) > 0
			oTree := THTree():New()
			oTree:Name("treeCubeInd")
			oTree:SubTheme("treeCubeInd")
			oTree:UrlFrame("_self") 
			oTree:RootCaption(oCube:Name())
		
			oTree:AddNode(nil, "na_indicad", STR0021, .t., "",, oTree:addImage("ic_att_key_off.gif"), oTree:addImage("ic_att_key_on.gif"))  //###"Indicadores"
		
			for i := 1 to len(aCubInd)
				oTree:AddNode("na_indicad", "na_indicad"+ str(i-1), aCubInd[i][2], .t., "javascript:doInsEdtExp(\'FATO->"+aCubInd[i][1]+"\')")
			next
		
			// adiciona a lista de árvores
			oTreeList:addToList(oTree)
		endif
	
		// recupera as dimensões do cubo
		oDimCubs := InitTable(TAB_DIM_CUBES)
		oDimCubs:Seek(2, { nCubeID })
		while !oDimCubs:EoF() .and. oDimCubs:value("id_cube") == nCubeID
			oDim := oSigaDW:OpenDim(oDimCubs:value("id_dim"))
			oTree := THTree():New()
			oTree:Name("attCube" + DwStr(oDimCubs:value("id_dim")))
			oTree:SubTheme("treeCube")
			oTree:UrlFrame("_self")
			oTree:RootCaption(oDim:Descricao() + "(" + oDim:Alias() + ")")
			aKeys := oDim:Indexes()[2,4]
    		if len(aKeys) > 0
				oTree:AddNode(nil, "ack", STR0106, .t., "",, oTree:addImage("ic_att_key_off.gif"), oTree:addImage("ic_att_key_on.gif")) //###"Chave"
			endif

		    if len(oDim:Fields()) - len(aKeys) - 1 > 0
				oTree:AddNode(nil, "aca", STR0107, .t., "",, oTree:addImage("ic_dim_att_off.gif"), oTree:addImage("ic_dim_att_on.gif")) //###"Atributo"
			endif

			for i := 2 to len(oDim:Fields())
				x :=  oDim:Fields()[i]
				if ascan(aKeys, {|y| y==x[FLD_NAME]}) == 0
					oTree:AddNode("aca", "na_att_"+ str(i-1), x[FLD_TITLE], .f., "javascript:doInsEdtExp(\'"+oDim:Alias()+"->"+x[1]+"\')")
				else
					oTree:AddNode("ack", "na_key_"+ str(i-1), x[FLD_TITLE], .f., "javascript:doInsEdtExp(\'"+oDim:Alias()+"->"+x[1]+"\')")
				endif
			next
			// adiciona a lista de árvores
			oTreeList:addToList(oTree)
		
			oDimCubs:_Next()
		enddo
	endif
	
	oTreeList:Buffer(aBuffer)
  
  	aAdd(aBuffer, tagJS())
	if alDocto
	  	aAdd(aBuffer, "function doShowSample(acIDSample)")
	  	aAdd(aBuffer, "{")
	  	aAdd(aBuffer, "  var oDivSamples = getObject('divSample');")
	  	aAdd(aBuffer, "  var oDivCmd = getObject('divSampleCmd');")
	  	aAdd(aBuffer, "  var oDivExe = getObject('divSampleExe');")
	  	aAdd(aBuffer, "  if (acIDSample == '"+BAS_ID_PARAGRAFO+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(BAS_PARAGRAFO) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(BAS_PARAGRAFO) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+BAS_ID_ITALIC+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(BAS_ITALIC) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(BAS_ITALIC) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+BAS_ID_UNDERLINE+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(BAS_UNDERLINE) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(BAS_UNDERLINE) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+BAS_ID_BOLD+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(BAS_BOLD) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(BAS_BOLD) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+BAS_ID_IDENT+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(BAS_IDENT) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(BAS_IDENT) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+HED_ID_TITLE+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(HED_TITLE) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(HED_TITLE) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+HED_ID_SUBTITLE+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(HED_SUBTITLE) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(HED_SUBTITLE) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+LIS_ID_BULLET+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(LIS_BULLET) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(LIS_BULLET) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+LIS_ID_NUMBER+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(LIS_NUMBER) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(LIS_NUMBER) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+LIS_ID_ALPHA+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(LIS_ALPHA) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(LIS_ALPHA) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+LIS_ID_ROMAN+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(LIS_ROMAN) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(LIS_ROMAN) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_LINE+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_LINE) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_LINE) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_LINK+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_LINK) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_LINK) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_MAIL+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_MAIL) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_MAIL) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_MAILEX+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_MAILEX) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_MAILEX) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_IMG+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_IMG) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_IMG) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_IMGLEFT+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_IMGLEFT) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_IMGLEFT) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_IMGRIGHT+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_IMGRIGHT) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_IMGRIGHT) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_REF+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_REF) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_REF) +"';")
	  	aAdd(aBuffer, "  } else if (acIDSample == '"+SPC_ID_SCHEMA+"')")
	  	aAdd(aBuffer, "  {")
	  	aAdd(aBuffer, "    oDivCmd.innerHTML = '"+prepCmdSample(SPC_SCHEMA) +"';")
	  	aAdd(aBuffer, "    oDivExe.innerHTML = '"+prepExeSample(SPC_SCHEMA) +"';")
	  	aAdd(aBuffer, "  }")
	
	  	aAdd(aBuffer, "  showElement(oDivSamples);")
	  	aAdd(aBuffer, "}")                                    
	endif

	aAdd(aBuffer, "function doInsEdtExp(acString)")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  var oTextArea = parent.document.iExpressao.document.getElementById('edTextArea');")
	aAdd(aBuffer, "  oTextArea.value += (oTextArea.length == 0?'':' ') + acString;")
	aAdd(aBuffer, "  oTextArea.focus();")
	aAdd(aBuffer, "}")
	aAdd(aBuffer, "</script>")
	
	if alDocto
		aAdd(aBuffer, "<div style='position:absolute;top:10%;display:none;width:170px; background:#b9dcff; border:1px solid red; padding:5px;' id='divSample'>")
		aAdd(aBuffer, "<div style='width:100%; background:#91c8ff; border:1px solid #2b8aec; padding:5px;text-align:left;margin-bottom:5px;' id='divSampleCmd'>")
		aAdd(aBuffer, "</div>")
		aAdd(aBuffer, "<div style='width:100%; border:1px solid #2b8aec; padding:5px;text-align:left;' id='divSampleExe'>")
		aAdd(aBuffer, "</div>")
		aAdd(aBuffer, "</div>")
	endif
return dwConcatWSep(CRLF, aBuffer)

function buildExecExpr(acFormName, acTitle, acSQL, acStrucTxt, nIdDsn, alEdit) 
	local aBuffer := {}, aAuxFields := {}, aButtons := {}
    local oTableExec 
    local aItens := {}, aCols := {}, nI, aAux, aItensAux  
    
    default alEdit := .T. 
    
	aAdd(aBuffer, '<!-- buildEdtExp start -->')
	makeHidden(aAuxFields, "edCmdTextArea", "")
    
    if (alEdit)                             
	    //Constrões os botões  Editar e Cancelar. 
		makeButton(aButtons, BT_JAVA_SCRIPT, STR0110, acFormName+"_doExecEdtCmd('"+EDT_CMD_EDIT+"')") //###"Editar"
		makeButton(aButtons, BT_JAVA_SCRIPT, STR0015, acFormName+"_doExecEdtCmd('"+EDT_CMD_CANCEL+"')") //###"Cancelar"
	else 
		makeButton(aButtons, BT_JAVA_SCRIPT, STR0114, "doClose(false)" )//###"Fechar"
	endif
	
	//Verifica se o argumento recebido é uma expressão SQL ou Texto Estruturado. 
	if valType(acSQL) == "C"
	   	oTableExec := CreateRPC(acSQL)               
		aAux := oTableExec:fields()
		for nI := 1 to len(aAux)
			makeEditCol(aCols, EDT_SHOW, 'ed' + aAux[nI,1], aAux[nI,1], .t., aAux[nI,2],  aAux[nI,3], 0) //Preenche colunas	
		next	     
	    	                                                                                                 
		aAux:= oTableExec:fields()
		while !oTableExec:EOF() .and. len(aItens) < 21
			aItensAux = array(len(aAux))
			for nI := 1 to len(aItensAux)
				aItensAux[nI] := oTableExec:value(aAux[nI,1])
			next
			aAdd(aItens, aItensAux)
			oTableExec:_next()		
		enddo 
		oTableExec:Close()
		close rpcconn __oRPC	
	
		//Monta edição em formato browse para exibição dos dados. 
		aAdd(aBuffer, buildFormBrowse(acFormName, acTitle, AC_NONE, "", aButtons, aCols, aItens,,,))  
	else   
		makeCustomFields(aAuxFields, "edStrucTxt", "<div style='overflow: scroll'>" + strTran(dwTxt2Html(nil, dwToken(strTran(acStrucTxt, LF, ""), CR, .f.)), CRLF, "<br>") + "</div>")
   		//Monta formulário simples para exibição do HTML formatado. 
   		aAdd(aBuffer, buildForm(acFormName, STR0113 , AC_NONE, "", aButtons, aAuxFields))
	endif       
	
	aAdd(aBuffer, tagJS())
	aAdd(aBuffer, "function " + acFormName+"_doExecEdtCmd(anCommand)")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  var oForm = getElement('"+acFormName+"');")
	aAdd(aBuffer, "  var oCmdTextArea = getElement('edCmdTextArea');")
	aAdd(aBuffer, "  oForm.submit();")
    aAdd(aBuffer, "  }")
	aAdd(aBuffer, "</script>")

	aAdd(aBuffer, '<!-- buildEdtExp end -->')
return dwConcatWSep(CRLF, aBuffer)

static function CreateRPC(acSQL)   
	local lOk 		:= .f.
	local oTable, oRPCTable
	local fcLastMsg              
	local nError 	:= 0
	local aParamsEdt:= getParamsEdt()
	local cEmpFil	:= aParamsEdt[IX_EMPFIL]
	
	//::ResetMsg()
  	if (httpSession->EDT_PARAM_DSN == .T.)
  	   oTable:= initTable(TAB_DSN)
  	   oTable:Seek(1,{httpSession->ID_DSN})
  	else
  	endif                                                                         

	if oTable:value("tipo_conn") == TC_TOP_CONNECT
		if empty(oTable:value("server")) .or. empty(oTable:value("banco_srv"))
			nError := 1                                                         
			fcLastMsg := STR0001 //"Parâmetros para conexão insuficientes/inválidos"
		endif                                                                  
	elseif empty(oTable:value("Server")) .or. empty(oTable:value("ambiente")) .or. empty(cEmpFil)
		nError:= 1
		fcLastMsg := STR0001 //"Parâmetros para conexão insuficientes/inválidos"
	endif

	if nError == 0
		RPCSetType(3)
		if oTable:value("tipo_conn") == TC_TOP_CONNECT
   			create rpcconn __oRPC;          	    	
				on server "localhost" port DWDefaultPort() ;
				environment getEnvServer() ;
				empresa DWEmpresa() filial DWFilial() clean
		else
			if at(":", oTable:value("Server")) > 0
				aAux := dwToken(oTable:value("Server"), ":",.F.)
			else
				aAux := { oTable:value("Server"), DwStr(DWDefaultPort()) }
			endif
 			create rpcconn __oRPC;              	
				on server aAux[1] port val(aAux[2]) ;
				environment oTable:value("ambiente") ;
				empresa dwEmpresa(cEmpFil) filial dwFilial(cEmpFil)
		endif			
		ErrorBlock({|e| __webError(e)})

		if valType(__oRPC) != "O"
			fcLastMsg := STR0002//"Erro na criação do RPC"  
			conout(STR0002)
		else                                                           
			oRPCTable := TRPCTable():new(__oRPC, dwMakeName("DW") ,"TOP")
			if oTable:value("tipo_conn") == TC_TOP_CONNECT
				oRPCTable:OpenDB(oTable:value("Server"), oTable:value("conex_srv"), ;
						oTable:value("banco_srv"), oTable:value("aliasTOP"))	
				oRPCTable:sql(acSQL)
				oRPCTable:Open()
			elseif oTable:value("tipo_conn") == TC_AP_SX
				if aParamsEdt[IX_EMBEDDED]	
					oRPCTable:Open(,.t.,acSQL)
				else
					oRPCTable:sql(acSQL)
					oRPCTable:Open()
				endif
			endif
		endif  
	endif                    
return oRPCTable

static function getParamsEdt()
	local aRet := dwGetProp("paramsEdt", "BUILDEDTEXPR")
	
	if valType(aRet) <> "A"
		aRet := { .f., .f., .f., .f., "", 0, .f., .f., "" }
		aRet := aSize(IX_SIZE)
		aFill(aRet, .f.)
		aRet[IX_OBJ] := ""
		aRet[IX_OBJID] := 0
	endif
return aRet

static function prepCmdSample(acSample)
return strTran(dwConcatWSep("<br>", acSample), "'", "\'")

static function prepExeSample(acSample)
return strTran(strTran(dwTxt2Html(nil, acSample), CRLF, "\n"), "'", "\'")