#include "totvs.ch"
//------------------------------------------------------------------
//Exemplo de configuração de TGrid em array com navegação por linha
//------------------------------------------------------------------
#define GRID_MOVEUP       0
#define GRID_MOVEDOWN     1
#define GRID_MOVEHOME     2
#define GRID_MOVEEND      3
#define GRID_MOVEPAGEUP   4
#define GRID_MOVEPAGEDOWN 5
//------------------------------------------------------------------
//Valores para a propriedade nHScroll que define o comportamento da
//barra de rolagem horizontal
//------------------------------------------------------------------
#define GRID_HSCROLL_ASNEEDED   0
#define GRID_HSCROLL_ALWAYSOFF  1
#define GRID_HSCROLL_ALWAYSON   2
             
// MyGrid ( Classe para encapsular acesso ao componente TGrid )
//------------------------------------------------------------------------------
CLASS GFEGrid
    DATA oGrid
    DATA oFrame
    DATA oButtonsFrame
    DATA oButtonHome
    DATA oButtonPgUp
    DATA oButtonUp
    DATA oButtonDown
    DATA oButtonPgDown
    DATA oButtonEnd
    DATA aData
    DATA nLenData
    DATA nRecNo
    DATA nCursorPos
    DATA nVisibleRows
    DATA nFreeze
    DATA nHScroll
    DATA aColumn
        
    METHOD New(oDlg, aData, nMaxLinha, nAlt, nLarg, aColumn) CONSTRUCTOR
    METHOD onMove( o,nMvType,nCurPos,nOffSet,nVisRows )
    METHOD isBof()
    METHOD isEof()
    METHOD ShowData( nFirstRec, nCount )
    METHOD ClearRows()
    METHOD DoUpdate()
    METHOD SelectRow(n)
    METHOD GoHome()
    METHOD GoEnd()
    METHOD GoPgUp()
    METHOD GoPgDown()
    METHOD GoUp(nOffSet)
    METHOD GoDown(nOffSet)
    METHOD SetCSS(cCSS)
    METHOD SetFreeze(nFreeze)
    METHOD SetHScrollState(nHScroll)
    METHOD GetColumnsSize()
    METHOD GetCursorPos()
ENDCLASS

METHOD New(oDlg, aData, nMaxLinha, nAlt, nLarg, aColumn, cFunClk) CLASS GFEGrid
    Local oFont
    Local nI
    
    Default nMaxLinha := 14
    Default nAlt := 200
    Default nLarg := 200
    Default aColumn := {}
    Default cFunClk := ""
            
    ::oFrame:= tPanel():New(0,0,,oDlg,,,,,,nLarg,nAlt)
    ::nRecNo:= 1
    ::nCursorPos:= 0
    ::nVisibleRows:= nMaxLinha
    ::aData:= aData
    ::nLenData:= Len(aData)
    ::oGrid:= tGrid():New( ::oFrame )
    ::oGrid:Align:= CONTROL_ALIGN_ALLCLIENT
        
    ::oButtonsFrame:= tPanel():New(0,0,, ::oFrame,,,,,, 10,200,.F.,.T. )
    ::oButtonsFrame:Align:= CONTROL_ALIGN_RIGHT
    ::oButtonHome:= tBtnBmp():NewBar( "VCTOP.BMP",,,,, {||::GoHome()},,::oButtonsFrame )
    ::oButtonHome:Align:= CONTROL_ALIGN_TOP
    ::oButtonPgUp:= tBtnBmp():NewBar( "VCPGUP.BMP",,,,, {||::GoPgUp()},,::oButtonsFrame )
    ::oButtonPgUp:Align:= CONTROL_ALIGN_TOP
    ::oButtonUp:= tBtnBmp():NewBar( "VCUP.BMP",,,,,{||::GoUp(1)},,::oButtonsFrame )
    ::oButtonUp:Align:= CONTROL_ALIGN_TOP
    ::oButtonEnd:= tBtnBmp():NewBar( "VCBOTTOM.BMP",,,,, {||::GoEnd()},,::oButtonsFrame )
    ::oButtonEnd:Align:= CONTROL_ALIGN_BOTTOM
    ::oButtonPgDown:= tBtnBmp():NewBar( "VCPGDOWN.BMP",,,,, {||::GoPgDown()},,::oButtonsFrame )
    ::oButtonPgDown:Align:= CONTROL_ALIGN_BOTTOM
    ::oButtonDown:= tBtnBmp():NewBar( "VCDOWN.BMP",,,,, {||::GoDown(1)},,::oButtonsFrame )
    ::oButtonDown:Align:= CONTROL_ALIGN_BOTTOM
    
    For nI := 1 To Len(aColumn)
    	::oGrid:addColumn( aColumn[nI][1], aColumn[nI][2], aColumn[nI][3], aColumn[nI][4])
    Next nI
    
    ::oGrid:bCursorMove:= {|o,nMvType,nCurPos,nOffSet,nVisibleRows| ::onMove(o,nMvType,nCurPos,nOffSet,nVisibleRows) }
    ::ShowData(1)
    ::SelectRow( ::nCursorPos )
    ::oGrid:bLDblClick:= &cFunClk
RETURN

METHOD isBof() CLASS GFEGrid
RETURN  (::nRecno==1)

METHOD isEof() CLASS GFEGrid
RETURN (::nRecno==::nLenData)

METHOD GoHome() CLASS GFEGrid
    if ::isBof()
        return
    endif
    ::nRecno = 1
    ::oGrid:ClearRows()
    ::ShowData(1, ::nVisibleRows)
    ::nCursorPos:= 0
    ::SelectRow(::nCursorPos)
RETURN

METHOD GoEnd() CLASS GFEGrid
    if ::isEof()
        return
    endif
        
    ::nRecno:= ::nLenData
    ::oGrid:ClearRows()
    ::ShowData(::nRecno - ::nVisibleRows + 1, ::nVisibleRows)
    ::nCursorPos:= ::nVisibleRows-1
    ::SelectRow(::nCursorPos)
RETURN

METHOD GoPgUp() CLASS GFEGrid
	Local cb
	Local ci
	Local nX := 0

    If ::isBof()
        return
    EndIf
        
    If ::nCursorPos != 0
        ::nRecno -= ::nCursorPos
        If ::nRecno <= 0
            ::nRecno:=1
        EndIf
        ::nCursorPos:= 0
        ci := cValToChar(::nRecno)
        cb := "{|o| {"
        For nX := 1 To Len(::GetColumnsSize()) 
        	If nX == 1
        		cb += "Self:aData[" + ci + ",1]"
        	Else
        		cb += ",Self:aData[" + ci + "," + cValToChar(nX) + "]"
        	EndIf
        Next nX
        cb += "} }"
        ::oGrid:setRowData(::nCursorPos, &cb)
    Else
        ::nRecno -= ::nVisibleRows
        If ::nRecno <= 0
            ::nRecno:=1
        EndIf
        ::oGrid:ClearRows()
        ::ShowData( ::nRecno, ::nVisibleRows )
        ::nCursorPos:= 0
    EndIf
    ::SelectRow( ::nCursorPos )
RETURN

METHOD GoPgDown() CLASS GFEGrid
    Local nLastVisRow
        
    If ::isEof()
        return
    EndIf
        
    nLastVisRow:= ::nVisibleRows-1
        
    If ::nCursorPos!=nLastVisRow
        If ::nRecno+nLastVisRow > ::nLenData
            nLastVisRow:= ( ::nRecno+nLastVisRow ) - ::nLenData
            ::nRecno:= ::nLenData
        Else
            ::nRecNo += nLastVisRow
        EndIf
            
        ::nCursorPos:= nLastVisRow
        ::ShowData( ::nRecNo - ::nVisibleRows + 1, ::nVisibleRows )
    Else
        ::oGrid:ClearRows()
        ::nRecno += ::nVisibleRows
            
        If ::nRecno > ::nLenData
            ::nVisibleRows = ::nRecno-::nLenData
            ::nRecno:= ::nLenData
        EndIf
            
        ::ShowData( ::nRecNo - ::nVisibleRows + 1, ::nVisibleRows )
        ::nCursorPos:= ::nVisibleRows-1
    EndIf
        
    ::SelectRow( ::nCursorPos )
RETURN
        
METHOD GoUp(nOffSet) CLASS GFEGrid
    Local lAdjustCursor:= .F.
    Local ci
    Local cb
    Local nX
    
    If ::isBof()
        RETURN
    EndIf
    
    If ::nCursorPos==0
        ::oGrid:scrollLine(-1)
        lAdjustCursor:= .T.
    Else
        ::nCursorPos -= nOffSet
    EndIf
    ::nRecno -= nOffSet
    
    ci := cValToChar(::nRecno)
    cb := "{|o| {"
    For nX := 1 To Len(::GetColumnsSize()) 
      	If nX == 1
       		cb += "Self:aData[" + ci + ",1]"
       	Else
       		cb += ",Self:aData[" + ci + "," + cValToChar(nX) + "]"
       	EndIf
    Next nX
    cb += "} }"
    
    ::oGrid:setRowData( ::nCursorPos, &cb /*{|o| { ::aData[::nRecno,1], ::aData[::nRecno,2], ::aData[::nRecno,3] } }*/ )
        
    If lAdjustCursor
        ::nCursorPos:= 0
    EndIf
    ::SelectRow( ::nCursorPos )
RETURN

METHOD GoDown(nOffSet) CLASS GFEGrid
    Local lAdjustCursor:= .F.
    Local ci
    Local cb
    Local nX
    
    If ::isEof()
        RETURN
    EndIf
        
    If ::nCursorPos==::nVisibleRows-1
        ::oGrid:scrollLine(1)
        lAdjustCursor:= .T.
    Else
        ::nCursorPos += nOffSet
    EndIf
    ::nRecno += nOffSet
    
    ci := cValToChar(::nRecno)
    cb := "{|o| {"
    For nX := 1 To Len(::GetColumnsSize()) 
        If nX == 1
        	cb += "Self:aData[" + ci + ",1]"
        Else
        	cb += ",Self:aData[" + ci + "," + cValToChar(nX) + "]"
        EndIf
    Next nX
    cb += "} }"
    
    ::oGrid:setRowData( ::nCursorPos, &cb /*{|o| { ::aData[::nRecno,1], ::aData[::nRecno,2], ::aData[::nRecno,3] } }*/ )
        
    If lAdjustCursor
        ::nCursorPos:= ::nVisibleRows-1
    EndIf
    ::SelectRow( ::nCursorPos )
RETURN

METHOD onMove( oGrid,nMvType,nCurPos,nOffSet,nVisRows ) CLASS GFEGrid
    ::nCursorPos:= nCurPos
    ::nVisibleRows:= nVisRows
        
    If nMvType == GRID_MOVEUP
        ::GoUp(nOffSet)
    ElseIf nMvType == GRID_MOVEDOWN
        ::GoDown(nOffSet)
    ElseIf nMvType == GRID_MOVEHOME
        ::GoHome()
    ElseIf nMvType == GRID_MOVEEND
        ::GoEnd()
    ElseIf nMvType == GRID_MOVEPAGEUP
        ::GoPgUp()
    ElseIf nMvType == GRID_MOVEPAGEDOWN
        ::GoPgDown()
    EndIf
RETURN

METHOD ShowData( nFirstRec, nCount ) CLASS GFEGrid
    Local nI
    Local nX
    Local ci
    
    For nI := 1 To ::nLenData
        ci := cValToChar(nI)
        cb := "{|o| {"
        For nX := 1 To Len(::GetColumnsSize()) 
        	If nX == 1
        		cb += "Self:aData[" + ci + ",1]"
        	Else
        		cb += ",Self:aData[" + ci + "," + cValToChar(nX) + "]"
        	EndIf
        Next nX
        cb += "} }"
        
        ::oGrid:setRowData(nI,&cb)
    Next nI
RETURN

METHOD ClearRows() CLASS GFEGrid
    ::oGrid:ClearRows()
    ::nRecNo:=1
RETURN

METHOD DoUpdate() CLASS GFEGrid
    ::nRecNo:=1
    ::Showdata(1)
    ::SelectRow(0)
RETURN

METHOD SelectRow(n) CLASS GFEGrid
    valor := n - ::nCursorPos
    ::nRecno += valor
    If ::nRecno <= 0
      ::nRecno = 1
    EndIf
    ::nCursorPos:=n
    ::oGrid:setSelectedRow(n)
RETURN

METHOD SetCSS(cCSS) CLASS GFEGrid
    ::oGrid:setCSS(cCSS)
RETURN
    
METHOD SetFreeze(nFreeze) CLASS GFEGrid
    ::nFreeze := nFreeze
    ::oGrid:nFreeze := nFreeze
RETURN

METHOD SetHScrollState(nHScroll) CLASS GFEGrid
    ::nHScroll := nHScroll
    ::oGrid:nHScroll := nHScroll
RETURN

METHOD GetColumnsSize() CLASS GFEGrid
	Local nRet
	
	nRet := ::oGrid:GetColumnsSize()
RETURN nRet

METHOD GetCursorPos() CLASS GFEGrid
	Local aCurPos
	
	aCurPos := ::oGrid:GetCursorPos()
RETURN aCurPos