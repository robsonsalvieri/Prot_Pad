// ######################################################################################
// Projeto: DATAWAREHOUSE
// Modulo : Htm
// Fonte  : HPivot - Objeto TWDHtmTable, responsável pela montagem de tabelas
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 10.02.06 | 0548-Alan Candido | Versão 3
// 28/09/07 | 0548-Alan Candido | BOPS 132327 - Integração com Excel, não enviava as linhas de dados
// 10.04.08 | 0548-Alan Candido | BOPS 142154
//          |                   | Ajustes de lay-out de tela e exportação de consultas com DD
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

#define TAM_PIXEL_ATT 9
#define TAM_PIXEL_IND 5
#define LARG_MIN 150
#define TOTAL_PARC "%"
#define ASPAS_S "'"

#define SIDE_FULL   0
#define SIDE_ATT    1
#define SIDE_IND    2

/*
--------------------------------------------------------------------------------------
Classe: THPivot
Uso   : Monta grid de "pivoteamento" (cross-table)
--------------------------------------------------------------------------------------
*/
class THPivot from THItem

	data faHeader             // Armazena as células do cabeçalho
	data faHeaderX            // Armazena as células do cabeçalho
	data faIntFld				  // Nome internos das colunas	
	data faIntFldX				  // Nome internos das colunas	
	data faData               // Armazena as células do corpo
	data faDataX              // Armazena as células do header X
	data faFooter             // Armazena as células do rodapé
	data faColTags            // Armazena os tags de configuração ñ default para coluna
	data faColWidth           // Armazena a quantidade de decimais
	data faRowTags            // Armazena os tags de configuração ñ default para linha
	data fcWidth              // Largura da tabela
	data fcHeight             // Altura da tabela
	data flOnlyStr            // Indica que somente a estrutura será enviada
	data fcName
	data fnRecLimit
	data faExtraButtons
	data flRowNumber
	data fcUrlFrame
	data flRanking
	data fbBeforeRecord
	data fbAfterRecord
	data faMask
	data faDataType
	data faColType
	data faVirtCol
	data fcPagefile
	data fcURL
	data fxInitRow
	data flZebra    
	data fnTabSeq
	data flEmptyCell
	data flFilter
	data flToolBar
	data flNavigat
	data flForExcel
	data fnNumberInd
	data fcDrillKey
	data fcUsePanels
	data fnQtdeInd
	data fnQtdeAtt
	data fnWidthInd
	data fnWidthAtt
	data fnDrillLevel
	
	method New() constructor
	method Free()
	method NewHPivot()
	method FreeHPivot()

	method PrepHeader() 
	method InitTabExp(aaBuffer, alFormated, anDrillLevel)
	method Buffer(aaBuffer) 
	method EndTable(aaBuffer) 
	
	method Clear()
	method InitRow(axValue)
	method AddRow(aaValues)
	method AddCol(anCols)
	method InsertCol(anCol, anCols)
	method RowCount()
	method _ColCount()
	method Header(anCol, axValue)
	method HeaderX(anRow, axValue)
	method InternalField(anCol, acValue)
	method IntFieldX(anRow, acValue)
	method Data(anRow, anCol, axValue)
	method DataRow(anRow)
	method DataX(anCol, axValue)
	method getDataX(anRow)
	method ColTags(anCol, acValue)
	method CellTags(anRow, anCol, acValue)
	method ColWidth(anCol, anValue)
	method ColType(anCol, anValue)
	method Width(acValue)
	method Height(acValue)

	method Name(acValue)
	method AppName()
	method RecLimit(anValue)
	method AddButton(acCaption, acHint, acAction, acImage)
	method AddSeparator()
    method RowNumber(alValue)
    method UrlFrame(acValue)
	method Ranking(alValue)
	method FieldMask(acFieldname, acMask)
	method VirtualCol(acFieldname, acExpresssao)
	method Pagefile(acValue)
	method URL(acURL)
	method EmptyCell(alValue)
	method Filter(alValue)
	method beginDrill()
	method endDrill()
	method PrepProc(poConsulta)
	method ToolBar(alValue)
	method Navigat(alValue)
	method ForExcel(alValue)
	
	method BeforeAction(acValue)
	method Action(acValue)
	method AfterAction(acValue)
	method DrillKey(acValue)
	method UsePanels(acValue)  
	method Cols(anCols)
	method Rows(anRows)
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New() class THPivot

	::NewHPivot()

return
	 
method Free() class THPivot

	::FreeHPivot()

return

method NewHPivot() class THPivot

	::NewHItem()
	::Clear()
	::fcName  := DWMakeName("tb")

return
	 
method FreeHPivot() class THPivot

	::FreeHItem()

return

/*
--------------------------------------------------------------------------------------
Código HTM para o item
Arg: aaBuffer -> array, local de geração do HTML
Ret: cRet -> string, buffer
--------------------------------------------------------------------------------------
*/
method Buffer(aaBuffer) class THPivot

  dwRaise(ERR_002, SOL_005, "THPivot:Buffer() obsoleto")
  
return 

/*
--------------------------------------------------------------------------------------
Limpa a tabela
--------------------------------------------------------------------------------------
*/                         
method Clear() class THPivot

	::fcWidth  := "100%"
	::fcHeight := ""
	::fnRecLimit := 0
	::faExtraButtons := {} 
	::flRowNumber := .f.
	::faMask := {}
	::faVirtCol := {}
	::faColType := {}
	::flZebra := .t.
	::faHeader := {}
	::faHeaderX := {}
	::faIntFld := {}
	::faIntFldX := {}
	::faColWidth := {}
	::faColTags := {}
	::fnTabSeq := 0
	::flEmptyCell := .t.
	::flFilter := .t.
	::flToolBar := .t.
	::flNavigat := .t.
	::flForExcel := .f.
	::flOnlyStr := .t.
	::fnNumberInd := 0
	::faRowTags := {}
	::faDataX   := {}
	::faData   := {}
	::fcDrillKey := ""
	::fcUsePanels := PAN_SIMPLES
	::fnDrillLevel := 0
return

/*
--------------------------------------------------------------------------------------
Número de colunas
Arg: anCols -> numérico, número de colunas
Ret: 
--------------------------------------------------------------------------------------
*/                         
method Cols(anCols) class THPivot
	local aAux, nInd, nRow

	if valType(anCols) != "U"
	   if anCols != len(::faHeader)
	    aAux := aClone(::faHeader)
   		aSize(::faHeader, anCols)
	   	aFill(::faHeader, "")
	   	for nInd := 1 to min(anCols, len(aAux))
	   		::faHeader[nInd] := aAux[nInd]
   		next

		   aAux := aClone(::faIntFld)
   		aSize(::faIntFld, anCols)
	   	aFill(::faIntFld, "")
	   	for nInd := 1 to min(anCols, len(aAux))
	   		::faIntFld[nInd] := aAux[nInd]
   		next

   		aAux := aClone(::faData)
	   	aSize(::faData, len(aAux))
	   	for nInd := 1 to len(::faData)
	   	next
	   	for nRow := 1 to len(aAux)
   			::faData[nRow] := array(anCols)
   			for nInd := 1 to min(anCols, len(aAux[1])) 
					::faData[nRow, nInd] := aAux[nRow, nInd]
   			next
   		next

    aAux := aClone(::faColTags)
   		aSize(::faColTags, anCols)
	   	aFill(::faColTags, "")
	   	for nInd := 1 to min(anCols, len(aAux))
	   		::faColTags[nInd] := aAux[nInd]
   		next
		aAux := aClone(::faColWidth)
   		aSize(::faColWidth, anCols)
	   	aFill(::faColWidth, 0)
	   	for nInd := 1 to min(anCols, len(aAux))
	   		::faColWidth[nInd] := aAux[nInd]
   		next

   	endif
	endif
	
return len(::faHeader)

/*
--------------------------------------------------------------------------------------
Número de linhas
Arg: anRows -> numérico, número de linhas
Ret: 
--------------------------------------------------------------------------------------
*/                         
method Rows(anRows) class THPivot
	local aAux, nRow, nInd
       
	if valType(anRows) != "U"
    	if anRows != len(::faData)
   		aAux := aClone(::faData)
	   	aSize(::faData, anRows)
	   	for nInd := 1 to anRows
   			::faData[nInd] := {}
	   	next
	   	for nRow := 1 to min(len(::faData), len(aAux))
   			aSize(::faData[nRow], len(aAux[nRow]))
	   		for nInd := 1 to len(aAux[nRow])
		   		::faData[nRow, nInd] := aAux[nRow, nInd]
			   next
   		next
		endif
	endif
	
return len(::faData)

/*
--------------------------------------------------------------------------------------
Propriedade Header
Arg: anCol -> numérico, número da coluna
     axValue -> expressão, titulo da coluna
Ret: 
--------------------------------------------------------------------------------------
*/                         
method Header(anCol, axValue) class THPivot
             
	if anCol == -1
		anCol := ::_ColCount() + 1
	endif
	
	while anCol > ::_ColCount()
		::AddCol()
	enddo
	
	property ::faHeader[anCol] := axValue
	
return ::faHeader[anCol]

/*
--------------------------------------------------------------------------------------
Propriedade HeaderX
Arg: anRow -> numérico, número da linha
     axValue -> expressão, titulo da linha
Ret: 
--------------------------------------------------------------------------------------
*/                         
method HeaderX(anRow, axValue) class THPivot
             
	if anRow == -1
		anRow := len(::faHeaderX) + 1
	endif
	
	while anRow > len(::faHeaderX)
		aAdd(::faHeaderX, "")
	enddo
	
	property ::faHeaderX[anRow] := axValue
	
return ::faHeaderX[anRow]

/*
--------------------------------------------------------------------------------------
Propriedade InternalField
Arg: anCol -> numérico, número da coluna
     acValue -> string, nome do campo
Ret: 
--------------------------------------------------------------------------------------
*/                         
method InternalField(anCol, acValue) class THPivot
             
	if anCol == -1
		anCol := ::_ColCount() + 1
	endif
	
	while anCol > ::_ColCount()
		::AddCol()
	enddo
	
	property ::faIntFld[anCol] := acValue
	
return ::faIntFld[anCol]

/*
--------------------------------------------------------------------------------------
Propriedade IntFieldX
Arg: anCol -> numérico, número da coluna
     acValue -> string, nome do campo
Ret: 
--------------------------------------------------------------------------------------
*/                         
method IntFieldX(anCol, acValue) class THPivot
             
	if anCol == -1
		anCol := len(::faIntFldX) + 1
	endif
	
	while anCol > len(::faIntFldX)
		aAdd(::faIntFldX,"")
	enddo
	
	property ::faIntFldX[anCol] := acValue

return ::faIntFldX[anCol]

/*
--------------------------------------------------------------------------------------
Propriedade InitRow
Arg: axValue -> expressão, valor a usar para inicializar as células
Ret: 
--------------------------------------------------------------------------------------
*/                         
method InitRow(axValue) class THPivot

	property ::fxInitRow := axValue
	
return ::fxInitRow

/*
--------------------------------------------------------------------------------------
Propriedade EmptyCell
Arg: alValue -> logico, indica se as células vazias devem aparecer ou não
Ret: 
--------------------------------------------------------------------------------------
*/                         
method EmptyCell(alValue) class THPivot

	property ::flEmptyCell := alValue
	
return ::flEmptyCell

/*
--------------------------------------------------------------------------------------
Propriedade Filter
Arg: alValue -> logico, indica se os filtros aparecerem ou não
Ret: 
--------------------------------------------------------------------------------------
*/                         
method Filter(alValue) class THPivot

	property ::flFilter := alValue
	
return ::flFilter

/*
--------------------------------------------------------------------------------------
Propriedade ToolBar
Arg: alValue -> logico, indica se possui toolbar ou não
Ret: 
--------------------------------------------------------------------------------------
*/                         
method ToolBar(alValue) class THPivot

	property ::flToolBar := alValue
	
return ::flToolBar

/*
--------------------------------------------------------------------------------------
Propriedade Navigat
Arg: alValue -> logico, indica se possui barra de navegação ou não
Ret: 
--------------------------------------------------------------------------------------
*/                         
method Navigat(alValue) class THPivot

	property ::flNavigat := alValue
	
return ::flNavigat

/*
--------------------------------------------------------------------------------------
Propriedade ForExcel
Arg: alValue -> logico, indica se a saida será para excel formato xml
Ret: 
--------------------------------------------------------------------------------------
*/                         
method ForExcel(alValue) class THPivot

	property ::flForExcel := alValue
	
return ::flForExcel

/*
--------------------------------------------------------------------------------------
Propriedade ColTags
Arg: anCol -> numérico, número da coluna
     acValue -> string, tags HTML
Ret: 
--------------------------------------------------------------------------------------
*/                         
method ColTags(anCol, acValue) class THPivot

	while anCol > ::_ColCount()
		::AddCol()
	enddo

	property ::faColTags[anCol] := acValue
	
return ::faColTags[anCol]

/*
--------------------------------------------------------------------------------------
Propriedade CellTags
Arg: anRow, anCol -> numérico, número da linha e coluna
     acValue -> string, tags HTML
Ret: 
--------------------------------------------------------------------------------------
*/                         
method CellTags(anRow, anCol, acValue) class THPivot
	local aAux := ::faData[anRow, anCol], cRet := ""
	
	if valType(acValue) != "U"
		if valtype(aAux) != "A"
			aAux := { ::Data(anRow, anCol), acValue }
		else   
			aAux[2] := acValue
		endif
		::Data(anRow, anCol, aAux)	
		cRet := acValue
	elseif valtype(aAux) == "A"
		cRet := aAux[2]
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Propriedade ColWidth
Arg: anCol -> numérico, número da coluna
     anValue -> numerico, número de decimais
Ret: 
--------------------------------------------------------------------------------------
*/                         
method ColWidth(anCol, anValue) class THPivot

	while anCol > ::_ColCount()
		::AddCol()
	enddo

	property ::faColWidth[anCol] := anValue 
	
return ::faColWidth[anCol] - iif(::faColWidth[anCol]==0,0,2)

/*
--------------------------------------------------------------------------------------
Propriedade Data e DataRow
Arg: anRow -> numérico, número da linha
	  anCol -> numérico, número da coluna
     axValue -> expressão, dado
Ret: 
--------------------------------------------------------------------------------------
*/                         
method Data(anRow, anCol, axValue) class THPivot
	local xRet
	
	if valtype(axValue) != "U"
		while anCol > ::_ColCount()
			::AddCol()
		enddo
		while anRow > ::RowCount()
			::AddRow()
		enddo
		while len(::faData[anRow]) < ::_ColCount()
			aAdd(::faData[anRow], "")
		enddo

		::faData[anRow, anCol] := axValue
	elseif anRow > ::RowCount() .or. anCol > len(::faData[anRow])
		xRet := nil
	else        
		if valType(::faData[anRow, anCol]) == "A"
			xRet := ::faData[anRow, anCol, 1]
		else
			xRet := ::faData[anRow, anCol]
		endif
	endif	
	
return xRet

method DataRow(anRow) class THPivot

return ::faData[anRow]

/*
--------------------------------------------------------------------------------------
Propriedade DataX
Arg: anCol -> numérico, número da coluna
     axValue -> expressão, dado
Ret: 
--------------------------------------------------------------------------------------
*/                         
method DataX(anCol, axValue) class THPivot
	local xRet
	
	if valtype(axValue) != "U"
		if anCol == -1
			aAdd(::faDataX, nil)
			anCol := len(::faDataX)
		else
			while anCol > len(::faDataX)
				aAdd(::faDataX, nil)
			enddo
		endif
		if valType(axValue) == "C"	
			::faDataX[anCol] := DWToken(axValue,CHR(255),.f.)
		else
			::faDataX[anCol] := axValue
		endif
	elseif anCol > len(::faDataX)
		xRet := nil
	else        
		xRet := ::faDataX[anCol]
	endif	
	
return xRet

method getDataX(anRow) class THPivot
	local cRet := "", nInd, aAux := {}, nAntInd, cClass
	local cStyleAdc := ""
	
	for nInd := 1 to len(::faDataX)
		while len(::faDataX[nInd]) < anRow
			aAdd(::faDataX[nInd], "")
		enddo
		aAdd(aAux, { 0, ::faDataX[nInd, anRow] } )
	next                                             
	nAntInd := 1
	for nInd := 2 to len(aAux)
		if aAux[nAntInd,2] == aAux[nInd, 2]
			aAux[nAntInd, 1]++
			aAux[nInd] := nil
		else
			nAntInd := nInd
		endif
	next
	if !::flForExcel
		for nInd := 1 to len(aAux)
			if valType(aAux[nInd]) == "A"
				cStyleAdc := ""
				if chr(254) $ aAux[nInd, 2] 
					aAux[nInd, 2] := strTran(aAux[nInd, 2], chr(254), "")
					if empty(aAux[nInd, 2])
						aAux[nInd, 2] := "Sub-total"      
						cClass := "SubTotal"
     			else
						cClass := "Total"
					end
				else
					cClass := ""				
				endif
				cRet += "<td nowrap class=pivotHeaderXData" + cClass + iif(aAux[nInd, 1] > 0," colspan="+dwStr(aAux[nInd, 1]+1),"")+ cStyleAdc +">" + aAux[nInd, 2] + "</td>"
			endif
		next
	else
		for nInd := 1 to len(aAux)
			if valType(aAux[nInd]) == "A"
				if chr(254) $ aAux[nInd, 2] 
					aAux[nInd, 2] := strTran(aAux[nInd, 2], chr(254), "")
					cClass := "Total"
				else
					cClass := ""				
				endif
				cRet += dwStr(aAux[nInd, 1]+1) + ";" + aAux[nInd, 2] + "|"
			endif
		next
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Propriedade Width
--------------------------------------------------------------------------------------
*/                         
method Width(acValue) class THPivot

	property ::fcWidth := acValue

return ::fcWidth

/*
--------------------------------------------------------------------------------------
Propriedade Height
--------------------------------------------------------------------------------------
*/                         
method Height(acValue) class THPivot

	property ::fcHeight := acValue

return ::fcHeight

/*
--------------------------------------------------------------------------------------
Numero de linhas
Arg: 
Ret: nRet -> numérico, número de linhas
--------------------------------------------------------------------------------------
*/
method RowCount() class THPivot

return len(::faData)

/*
--------------------------------------------------------------------------------------
Numero de colunas
Arg: 
Ret: nRet -> numérico, número de linhas
--------------------------------------------------------------------------------------
*/
method _ColCount() class THPivot

return len(::faHeader)

/*
--------------------------------------------------------------------------------------
Adiciona linhas   
Arg: aaValues -> array, lista de valores
Ret: nRet -> numérico, número da 1a linha adicionada
--------------------------------------------------------------------------------------
*/                         
method AddRow(aaValues) class THPivot
   local nRet := ::RowCount() + 1
	local nInd := nRet

	if valtype(aaValues) != "A"
		aaValues := array(::_ColCount())
		aFill(aaValues, ::InitRow())
	endif		
	aAdd(::faData, array(::_ColCount()) )
	for nInd := 1 to len(aaValues)
		::faData[nRet, nInd] := aaValues[nInd]
	next      

/*
   nPos := ascan(::faRowTags, {|x| x[1] == nRet})
	if nPos == 0
		aAdd(::faRowTags, {nRet, "id='"+::RowID()+"'"} )
   else
		::faRowTags[nPos,2] := "id='"+::RowID()+"'"
   endif
*/
	::flZebra := !::flZebra
	
return nRet

/*
--------------------------------------------------------------------------------------
Insere/Adiciona colunas
Arg: anCol -> numérico, indica a coluna base
	  anCols -> numérico, número de colunas a adicionar
Ret: 
--------------------------------------------------------------------------------------
*/                         
method InsertCol(anCol, anCols) class THPivot
   local nRet := anCol + 1
	local nInd, nCol
	
	default anCols := 1

	aSize(::faHeader, len(::faHeader)+anCols)
	aSize(::faIntFld, len(::faHeader)+anCols)
	aSize(::faColTags, len(::faHeader)+anCols)
	aSize(::faColWidth, len(::faHeader)+anCols)
	aSize(::faColType, len(::faHeader)+anCols)
	aEval(::faData, { |x| aSize(x, len(::faHeader)+anCols) })

	for nCol := 1 to anCols 
		aIns(::faHeader, anCol)
		::faHeader[anCol] = ""
		aIns(::faIntFld, anCol)
		::faIntFld[anCol] = ""
		aIns(::faColTags, anCol)
		::faColTags[anCol] = ""
		aIns(::faColWidth, anCol)
		::faColWidth[anCol] = 0
		aIns(::faColType, anCol)
		::faColType[anCol] = ""
		aEval(::faData, { |x| aIns(x, anCol), x[anCol] = "" })
		anCol++
	next

return nRet

method AddCol(anCols) class THPivot
    local nRet := ::_ColCount() + 1
	local nInd, nCol
	local cAux
		
	default anCols := 1

	cAux := ::InitRow()
	for nCol := 1 to anCols 
		aAdd(::faHeader, "")
		aAdd(::faIntFld, "")
		aAdd(::faColTags, "")
		aAdd(::faColWidth, 0)
		aAdd(::faColType, "")     
		aEval(::faData, { |x| aAdd(x, cAux) })
	next

return nRet

/*
--------------------------------------------------------------------------------------
Propriedade Name
--------------------------------------------------------------------------------------
*/
method Name(acValue) class THPivot

	property ::fcName := acValue

return ::fcName

/*
--------------------------------------------------------------------------------------
Propriedade RecLimit
--------------------------------------------------------------------------------------
*/
method RecLimit(anValue)  class THPivot

	property ::fnRecLimit := anValue

return ::fnRecLimit

/*
--------------------------------------------------------------------------------------
Adiciona novas funcionalidades a barra de botões       
Args: acCaption -> string, texto de apresentação
		acHint -> string, texto com o "hint" do botão
		acAction -> string, ação a ser executada
--------------------------------------------------------------------------------------
*/
method AddButton(acCaption, acHint, acAction, acImage) class THPivot

	aAdd(::faExtraButtons, { acCaption, acHint, acAction, acImage } )
	
return

method AddSeparator() class THPivot

	aAdd(::faExtraButtons, { "", nil, nil, "ic_separador.gif" } )

return

/*
--------------------------------------------------------------------------------------
Propriedade RowNumber
--------------------------------------------------------------------------------------
*/
method RowNumber(alValue) class THPivot

	property ::flRowNumber := alValue
	
return ::flRowNumber

/*
--------------------------------------------------------------------------------------
Propriedade UrlFrame
--------------------------------------------------------------------------------------
*/
method UrlFrame(acValue) class THPivot

	property ::fcUrlFrame := acValue
	
return ::fcUrlFrame

/*
--------------------------------------------------------------------------------------
Propriedade Ranking
--------------------------------------------------------------------------------------
*/
method Ranking(alValue) class THPivot

	property ::flRanking := alValue
	
return ::flRanking

/*
--------------------------------------------------------------------------------------
Indica mascara de formatação
--------------------------------------------------------------------------------------
*/
method FieldMask(acFieldname, acMask) class THPivot
	local nPos, cRet := ""
	
	nPos := ascan(::faMask, { |x| acFieldname == x[1] })
	if  nPos == 0
		if valType(acMask) == "C"
			aAdd(::faMask, { acFieldname, acMask })
			cRet := acMask
		endif
	else
		if valType(acMask) == "C"
			::faMask[nPos,2] := acMask
			cRet := acMask
		else
			cRet := ::faMask[nPos,2]
		endif
	endif
		
return cRet

/*
--------------------------------------------------------------------------------------
Adiciona/recupera colunas virtuais
--------------------------------------------------------------------------------------
*/
method VirtualCol(acFieldname, acExpresssao) class THPivot
	local nPos, cRet := ""

	if valType(acFieldname)	== "U"
		return ::faVirtCol
	endif
	
	nPos := ascan(::faVirtCol, { |x| acFieldname == x[1] })
	if  nPos == 0                                            
		if valType(acExpresssao) == "C"
			aAdd(::faVirtCol, { acFieldname, acExpresssao})
			cRet := acExpresssao
		endif
	else
		if valType(acExpresssao) == "C"
			::faVirtCol[nPos,2] := acExpresssao
			cRet := acExpresssao
		else
			cRet := ::faVirtCol[nPos,2]
		endif
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Monta o nome do applet
--------------------------------------------------------------------------------------
*/
method AppName() class THPivot

return upper(::Owner():Name()+"table"+::Name()) //"table" + upper(::Name())

/*
--------------------------------------------------------------------------------------
Propriedade Pagefile
--------------------------------------------------------------------------------------
*/
method Pagefile(acValue) class THPivot

	property ::fcPagefile := acValue
	
return ::fcPagefile

/*
--------------------------------------------------------------------------------------
Propriedade URL
--------------------------------------------------------------------------------------
*/
method URL(acValue) class THPivot

	property ::fcURL := acValue
	
return ::fcURL

/*
--------------------------------------------------------------------------------------
Propriedade ColType
Arg: anCol -> numérico, número da coluna
     acValue -> string, tipo de dado
Ret: 
--------------------------------------------------------------------------------------
*/                         
method ColType(anCol, acValue) class THPivot

	while anCol > ::_ColCount()
		::AddCol()
	enddo

	property ::faColType[anCol] := acValue
	
return ::faColType[anCol]

method InitTabExp(aaBuffer, anDrillLevel, aoConsulta, alNoTotal) class THPivot
	local aBuffer := {}, nInd, xValue, aItems, i, x
	local nColSpan, nColSpanInd, cAux, lDrill, lDrillDown
	local cURLBase := ""
	local aAux, nAux, lIndCol, nInd2, nVazio, cDDKey
	
	default anDrillLevel := 9999999
	
	if valType(aaBuffer) != "U"
		aBuffer := aaBuffer
	endif
	
	::PrepProc(aoConsulta, alNoTotal)
	::PrepHeader()
	
	nColSpan := ::fnQtdeAtt
	nColSpanInd := ::fnQtdeInd
	
	if !::ForExcel()
		aAdd(aBuffer, "<table cellpadding=0 cellspacing=0 border=1>")
		aAdd(aBuffer,"<thead>")
	endif
	
	if len(::faHeaderX) > 0 
		if !::ForExcel()
			aEval(::faHeaderX, { |x, i| ;
			iif(empty(x), nil, ;
			aAdd(aBuffer, "<tr><td nowrap class=pivotHeaderX " + iif(nColSpan > 1," colSpan="+dwStr(min(anDrillLevel,nColSpan)),"")+">"+;
			DWStr(x) + "</td>" + ::getDataX(i) + "</tr>"))})
		else
			aAux := {}
			aEval(::faHeaderX, { |x, i| iif(empty(x), aAdd(aAux, "&nbsp;"), aAdd(aAux, dwStr(min(anDrillLevel,nColSpan))+";"+dwStr(x)+"|"+::getDataX(i)))})
			for nInd := 1 to len(aAux)
				aAux[nInd] := dwToken(aAux[nInd], "|")
				for nInd2 := 1 to len(aAux[nInd])
					cAux := aAux[nInd, nInd2]
					nVazio := dwVal(left(cAux, at(";", cAux)-1))
					if nVazio > 1
						cAux := substr(cAux, at(";", cAux)+1)
						if empty(cAux)
							cAux := "Sub-Total"
						endif
						aAux[nInd, nInd2] := array(nVazio)
						aFill(aAux[nInd, nInd2], "")
						aAux[nInd, nInd2, 1] := cAux
					else
						aAux[nInd, nInd2] := substr(cAux, at(";", cAux)+1)
					endif
				next
				aAdd(aBuffer, aAux[nInd])
			next
		endif
	else
		if !::ForExcel()
			aAdd(aBuffer, "<tr>")
			aAdd(aBuffer, "<td nowrap " + iif(nColSpan > 1," colSpan="+dwStr(nColSpan),"")+">&nbsp;</td>")
			aAdd(aBuffer, "<td nowrap colSpan="+dwStr(nColSpanInd)+">&nbsp;</td>")
			aAdd(aBuffer, "</tr>")
		else
			aAux := {}
			for nInd := 1 to nColSpan + nColSpanInd
				aAdd(aAux, "&nbsp;")
			next
			aAdd(aBuffer, aAux)
		endif
	endif
	
	if !::ForExcel()
		aAdd(aBuffer, "<tr id=H00>")
	else
		aAdd(aBuffer, "")
	endif
	
	for nInd := 1 to len(::faHeader)
		xValue := DWStr(::faHeader[nInd])
		lDrill := .f.
		lIndCol := .f.
		if !empty(xValue)
			cAux := ""
			if left(xValue,1) == "*"
				lDrill := .t.
				lDrillDown := .t.
				xValue := substr(xValue,2)
			elseif left(xValue,1) == "-"
				lDrill := .t.
				lDrillDown := .f.
				xValue := substr(xValue,2)
			endif
			if left(xValue,1) == "@"
				loop
			elseif !(left(xValue,1) $ "&>")
			elseif left(xValue,1) != ">"
				lIndCol := .t.
				xValue := substr(xValue, 2)
				cAux := ""
			else
				lDrill := .f.
				cAux := ""
			endif
			xValue := cAux + xValue
		else
			xValue := "&nbsp;"
		endif
		
		if nInd <= nColSpan
			if !::ForExcel()
				aAdd(aBuffer, "<td nowrap class=pivotHeaderDim " + ::faColTags[nInd] + ">" + xValue + "</td>")
			else
				xValue := "pivotHeaderDim|"+dwStr(xValue)
				xAux := aTail(aBuffer)
				if valType(xAux) == "A"
					aAdd(xAux, xValue)
				else
					aBuffer[len(aBuffer)] := { xValue }
				endif
			endif
		else
			if !::ForExcel()
				aAdd(aBuffer, "<td nowrap class=pivotHeaderInd " + ::faColTags[nInd] + ">" + xValue + "</td>")
			else
				xValue := "pivotHeaderInd|"+dwStr(xValue)
				xAux := aTail(aBuffer)
				if valType(xAux) == "A"
					aAdd(xAux, xValue)
				else
					aBuffer[len(aBuffer)] := { xValue }
				endif
			endif
		endif
	next
	
	if !::ForExcel()
		aAdd(aBuffer, "</tr>")
		aAdd(aBuffer, "</thead>")
	endif
	
return iif(valType(aaBuffer) == "U", DWStr(aBuffer), "")

/*
--------------------------------------------------------------------------------------
Código HTM para a finalização da tabela
Arg: aaBuffer -> array, local de geração do HTML
Ret: cRet -> string, buffer
--------------------------------------------------------------------------------------
*/                     
method EndTable(aaBuffer, alFormated) class THPivot
	local aBuffer := {}
		                                 
	default alFormated := .t.
	
    if valType(aaBuffer) != "U"
		aBuffer := aaBuffer
    endif

	if ::ForExcel()
	   aAdd(aBuffer, '<Row ss:AutoFitHeight=0>')
	endif
	
	if !::ForExcel()
		aAdd(aBuffer, "</table>")
	else
		aAdd(aBuffer, "</row>")
	endif

	if alFormated
		aAdd(aBuffer, "</div>")
	endif

return iif(valType(aaBuffer) == "U", DWStr(aBuffer), "")

/*
--------------------------------------------------------------------------------------
Prepara o header da tabela
--------------------------------------------------------------------------------------
*/                     
method PrepHeader() class THPivot
	local nRecSize, aColWidth, i, x

	nRecSize := 0
	aColWidth := aClone(::faColWidth)
	::fnQtdeInd := 0
	::fnQtdeAtt := 0
	::fnWidthInd := 0
	::fnWidthAtt := 0

	for i := 1 to len(aColWidth)
		x := aColWidth[i]
		if left(::faHeader[i],1) == "&"
			aColWidth[i] := max(LARG_MIN, (max(x, len(::faHeader[i]))) * TAM_PIXEL_IND)
			::fnQtdeInd++
			::fnWidthInd += aColWidth[i]
		else
			aColWidth[i] := max(LARG_MIN, (max(x, len(::faHeader[i]))) * TAM_PIXEL_ATT)
			::fnQtdeAtt++
			::fnWidthAtt += aColWidth[i]
		endif
		nRecSize += aColWidth[i]
		aColWidth[i] := dwStr(aColWidth[i])
	next
	
	aEval(::faColTags, { |x,i| iif(valtype(x)=="U",::faColTags[i] :="",nil ), ;
										iif("width"$x,nil,::faColTags[i]+=" width="+aColWidth[i]),;
										::faColWidth[i] := aColWidth[i] })
	::Width(DWStr(nRecSize))

return 

/*
--------------------------------------------------------------------------------------
Script de inicialização e finalização de drill
--------------------------------------------------------------------------------------
*/                     
method beginDrill() class THPivot
	local aBuffer := {}
	
	aAdd(aBuffer, tagJS())
	aAdd(aBuffer, 'var oDoc = top.principal.inferior_direito.document;')
	aAdd(aBuffer, 'var nRowBase = oDoc.currentRow.rowIndex;')
	aAdd(aBuffer, 'var nFirstRow = nRowBase;')
	::doProcRow(aBuffer)
	::doProcCell(aBuffer)
	aAdd(aBuffer, '</script>')

return DWConcatWSep(CRLF, aBuffer)

method endDrill() class THPivot
	local cRet := ''

	cRet += tagJS()
	cRet += 'var oFirstRow = getElement("'+::Name()+'", oDoc).rows(nFirstRow);'
	cRet += 'var oRow = oDoc.currentRow;'
	cRet += 'var oCell = oFirstRow.cells(oDoc.currentCellIndex);'+CRLF
	cRet += 'var oCellAux = oRow.cells(oDoc.currentCellIndex);'+CRLF
	cRet += 'var cAux = oCellAux.innerHTML;'+CRLF
	cRet += 'cAux = cAux.replace("wait.gif","up.gif");'
	if isFireFox()
		cRet += 'oCellAux.textContent = "&nbsp;&nbsp;" + oCell.textContent;'+CRLF
	else
		cRet += 'oCellAux.innerHTML = "&nbsp;&nbsp;" + oCell.innerText;'+CRLF
	endif
	
	cRet += 'oCellAux.firstRow = oFirstRow;'
	cRet += 'oCell.innerHTML = cAux;'+CRLF
	cRet += 'for (var nInd = 0; oRow.cells(nInd); nInd++) {'
	cRet += '	oRow.cells(nInd).oldClassName = oRow.cells(nInd).className; '
	cRet += '	oRow.cells(nInd).className += "Total"; }'
	cRet += '</script>'

return cRet

/*
--------------------------------------------------------------------------------------
Prepara para o processamento
--------------------------------------------------------------------------------------
*/
method PrepProc(poConsulta, alNoTotal) class THPivot
	local nInd      := 0
	local nCol      := 0
	local nColMax 	:= 0 
	local nColsX 	:= 0
	local nInd2		:= 0  
	local i 		:= 0
	local x         := 0
	local nPos      := 0
	
	local cFlag   	:= ""
	local cAux		:= "" 
	
	local aDimX		:= {}	
	local aDimY		:= {}
	local aInd		:= {}
	local aAux  	:= {} 
	local aAux2     := {}
 	local aIndAux 	:= {}         
	local aField 	:= {}
             
	local oQuery 

	default alNoTotal := .f.
           
	//Recupera a lista de campos dos eixos X, Y e Indicadores. 
	aDimX 		:= poConsulta:DimFieldsX()
	aDimY 		:= poConsulta:DimFieldsY()
	aInd  		:= poConsulta:Indicadores()   
		
	//Filtra apenas os indicadores utilizados na consulta.    
	aEval(aInd, {|x,i| iif(x:Ordem() > -1, aAdd(aIndAux, x), NIL)})
	aInd := aIndAux	
		
	//Recupera o tamanho de cada dimensão e a quantidade de Indicadores.  		
	nLenDimY 	:= len(aDimY)
	nLenDimX 	:= len(aDimX)
	nLenInd 	:= len(aInd)

	//Prepara as colunas do eixo Y. 
	if nLenDimY == 0
		::Header(1, "*>")
		::InternalField(1, "YD000")
		::ColWidth(1, 20)
		::fnDrillLevel := 0
	else       
	
		::fnDrillLevel := poConsulta:DrillLevel()  
		
		for nInd := 1 to len(aDimY) 
		
			if ::fnDrillLevel == 0
				::Header(nInd, DWCapitilize(aDimY[nInd]:Desc()))
			else
				::Header(nInd, iif(nInd == ::fnDrillLevel .and. nInd < nLenDimY, "*" ,iif(nInd < ::fnDrillLevel, "-", ""))+DWCapitilize(aDimY[nInd]:Desc()))
			endif   
			
			::InternalField(nInd, "Y" + aDimY[nInd]:Alias())
			::ColWidth(nInd, max(aDimY[nInd]:Tam()+aDimY[nInd]:NDec(), len(aDimY[nInd]:Mascara())) )
		next
	endif
	
	//Prepara as colunas do eixo X.
	if (nLenDimX <> 0)   
	
		for nInd := 1 to len(aDimX)
			cAux := iif(nInd != len(aDimX) .and. aDimX[nInd]:DrillDown(), ;
			"*" ,"")+DWCapitilize(aDimX[nInd]:Desc())
			::HeaderX(nInd, cAux)
			::IntFieldX(nInd, "X" + aDimX[nInd]:Alias())
		next    
		
		aAux := {}
		nColsX := poConsulta:readAxisX(aAux,,.t., alNoTotal)  
		
		for nInd2 := 1 to len(aAux)          
		
			aAux2 := dwToken(aAux[nInd2], CHR(255)) 
			
			for nInd := 1 to len(aAux2) - 1       

				if dwStr(aAux2[nInd]) != chr(254) .and. dwStr(aAux2[nInd]) != "TOTAL"  
				
					if empty(aAux2[nInd]) .or. dwStr(aAux2[nInd]) == "."
						aAux2[nInd] := "{vazio}"
					endif
				endif
			next      
			
			aAux[nInd2] := dwEncode(dwConcatWSep(CHR(255), aAux2))
		next           
		
		aEval(aAux, { |x| ::DataX(-1, x) })
	endif
	 
	//Prepara o cabeçalho da consulta. 
	if len(aInd) > 0    
	
		nCol := len(aDimY)
		cFlag := "&"   
		
		for nInd := 1 to max(nColsX, 1) step len(aInd)   
		
			if len(aInd) > 1 .and. poConsulta:IndSobrePosto()  
			
				aEval(aInd, { |x,i| ::ColWidth(nCol+i,max(x:Tam()+x:NDec(), len(x:Mascara()))), ;
				::ColTags(nCol + i, "align=right"),;
				nColMax := max(nColMax, ::ColWidth(nCol+i))}, 1,1)
				aEval(aInd, { |x,i| ::ColWidth(nCol+i,nColMax)}, 1,1)
				aAux := {}
				aEval(aInd, { |x,i|aAdd(aAux, DWCapitilize(x:AggTit(if(poConsulta:HaveAggFunc(x:ExpSQL()), 8, x:AggFunc()),x:Desc()))) })
				::Header(nCol + 1, cFlag + DWConcatWSep("<br>", aAux))
				nCol += len(aInd)
			else              
			
				for i := 1 to len(aInd)  
				
					x:= aInd[i]     
					
					if x:ordem() > 0
						nCol++
						::ColWidth(nCol, max(x:Tam()+x:NDec(), len(x:Mascara())))
						::ColTags(nCol, "align=right")
						nColMax := max(nColMax, ::ColWidth(nCol))
						::Header(nCol, cFlag + DWCapitilize( x:AggTit( iif( poConsulta:HaveAggFunc( x:ExpSQL() ), 8, x:AggFunc() ), x:Desc() ) ) )
					endif
				next
			endif
		next
	endif
	
return

/*
--------------------------------------------------------------------------------------
Propriedade DrillKey
--------------------------------------------------------------------------------------
*/
method DrillKey(acValue) class THPivot
	
	property ::fcDrillKey := acValue
	
return ::fcDrillKey

/*
--------------------------------------------------------------------------------------
Propriedade UsePanels
--------------------------------------------------------------------------------------
*/
method UsePanels(acValue) class THPivot
	
	property ::fcUsePanels := acValue
	
return ::fcUsePanels
	
/*
--------------------------------------------------------------------------------------
Métodos mantidos para manter a compatibilização
--------------------------------------------------------------------------------------
*/
method BeforeAction(acValue) class THPivot

return nil

method Action(acValue) class THPivot

return nil

method AfterAction(acValue) class THPivot

return nil

function _hPivot()
	if .f.
		_hPivot()
	endif
return
