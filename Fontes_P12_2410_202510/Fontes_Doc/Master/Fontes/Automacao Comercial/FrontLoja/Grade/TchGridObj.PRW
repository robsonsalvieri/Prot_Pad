#INCLUDE "PROTHEUS.CH"
#INCLUDE "TchGridObj.ch"

/* * *
 * Class ObjGrid
 * * */
 
Class TchGridObj

	Data oPosition
	Data cTitle
	Data cMessage
	Data oOwnerDlg
	Data aHeader
	Data aSizes
	Data aData
	Data lMultiSelect
	Data bSelectEvent
	Data bCancelEvent
	Data aF3
	Data oBrowse
	Data oGridDlg
	Data bLine
	Data oBtnTop
	Data nCurrent
	Data lReturn
	Data lCentered
	Data cPntEntId

	Method New( nTop, nLeft, nHeight, nWidth, cTitle, cMessage, oOwnerDialog, aHeader, aSizes, aData, lMultiSelect, bSelectEvent, bCancelEvent, aF3, cPntEntId ) Constructor
	Method Activate()

	Method BrTop()
	Method BrPgUp()
	Method BrUp()
	Method BrDown()
	Method BrPgDn()
	Method BrBottom()
	Method BrSelCur()
	Method BrSelAll()
	Method BrUnsAll()
	Method BrInvSel()
	Method BrSelByF3()

	Method BrConfirm()
	Method BrCancel()

	Method GetSelData()
	Method GetSelItems()
	
EndClass     


Method New( nTop, nLeft, nHeight, nWidth, cTitle, cMessage, oOwnerDlg, aHeader, aSizes, aData, lMultiSelect, bSelectEvent, bCancelEvent, aF3, cPntEntId ) Class TchGridObj

	Local nIndex
	Local aNewData
	Local nNewHeight
	Local nNewWidth

	If ExistBlock( "TCHGRIDEP" )
		If cPntEntId == "FRTSELCONV"
			aNewData := ExecBlock( "TCHGRIDEP", .F., .F., { aData, cPntEntId } )
			If ValType( aNewData ) <> "A"
				MsgAlert( STR2001 )
			Else
				If Len( aNewData[1] ) <> Len( aData[1] )
					MsgAlert( STR2002 )
				Else
					aData := Aclone( aNewData )
				EndIf
			EndIf
		EndIf
	EndIf

	::cTitle    := cTitle
	::cMessage  := cMessage
    ::oOwnerDlg := oOwnerDlg
    ::aHeader   := aHeader
    ::aSizes    := aSizes
    ::aData     := Aclone( aData )
    ::lReturn   := .F.
    ::lCentered := Empty( nTop ) .OR. Empty( nLeft )

	If lMultiSelect != nil
		::lMultiSelect := lMultiSelect
	Else
		::lMultiSelect := .F.
	EndIf

	nNewHeight := nHeight
	nNewWidth  := nWidth

	If ::lMultiSelect
		If nNewHeight < 580
			nNewHeight := 580
		EndIf
	Else
		If aF3 <> nil
			If nNewHeight < 445
				nNewHeight := 445
			EndIf
		Else
			If nNewHeight < 395
				nNewHeight := 395
			EndIf
		EndIf
	EndIf
	
	If nNewWidth < 256
		nNewWidth := 256
	EndIf

	::oPosition := TchPosObj():New( nTop, nLeft, nNewHeight, nNewWidth )

	If ::lMultiSelect

		Asize( ::aHeader, Len( ::aHeader ) + 1 )
		Ains( ::aHeader, 1 )
		::aHeader[ 1 ] := ""

		Asize( ::aSizes, Len( aSizes ) + 1 )
		Ains( ::aSizes, 1 )
		::aSizes[ 1 ] := 5
		
		For nIndex := 1 To Len( ::aData )
			ASize( ::aData[ nIndex ], Len( ::aData[ nIndex ] ) + 1 ) 
			AIns( ::aData[ nIndex ], 1 )
			::aData[ nIndex, 1 ] := .F.
		Next

	EndIf

	Asize( ::aHeader, Len( ::aHeader ) + 1 )
	Ains( ::aHeader, 1 )
	::aHeader[ 1 ] := ""

	Asize( ::aSizes, Len( aSizes ) + 1 )
	Ains( ::aSizes, 1 )
	::aSizes[ 1 ] := 5

	For nIndex := 1 To Len( ::aData )
		ASize( ::aData[ nIndex ], Len( ::aData[ nIndex ] ) + 1 ) 
		AIns( ::aData[ nIndex ], 1 )
		::aData[ nIndex, 1 ] := ""
	Next

	::bSelectEvent := bSelectEvent
	::bCancelEvent := bCancelEvent
	::aF3          := aF3
	::cPntEntId    := cPntEntId

Return( nil )


Method Activate() Class TchGridObj

	Local oSel := LoadBitmap(GetResources(),'LBTIK')
	Local oUns := LoadBitmap(GetResources(),'LBNO')
	Local oBmp := LoadBitmap(GetResources(),'LINEHEIG')
	Local nTop := 10

	//DEFINE MSDIALOG ::oGridDlg TITLE ::cTitle FROM ::oPosition:GetTop(), ::oPosition:GetLeft() TO ::oPosition:GetBottom(), ::oPosition:GetRight() OF ::oOwnerDlg PIXEL STYLE  2147483647 //nOr( WS_VISIBLE, WS_POPUP )
	DEFINE MSDIALOG ::oGridDlg TITLE ::cTitle FROM ::oPosition:GetTop(), ::oPosition:GetLeft() TO ::oPosition:GetBottom(), ::oPosition:GetRight() OF ::oOwnerDlg PIXEL STYLE DS_MODALFRAME

	If !Empty( ::cMessage )
		@ 10,10 SAY ::cMessage CENTERED SIZE ::oPosition:GetWidth() / 2 - 40,10 OF ::oGridDlg PIXEL
		nTop := 20
	EndIf

	::oBrowse := TWBrowse():New( nTop, ; // y
	                             10, ; // x
	                             ::oPosition:GetWidth() / 2 - 40, ; // w
	                             ::oPosition:GetHeight() / 2 - 5 - nTop, ; // y
	                             nil, ;
	                             ::aHeader, ;
	                             ::aSizes, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             nil, ;
	                             .T., ;
	                             nil, ;
	                             .F., ;
	                             nil, ;
	                             .F., ;
	                             nil, ;
	                             .F., ;
	                             nil, ;
	                             nil, ;
	                             nil )

	::oBrowse:SetArray( ::aData )

	If !::lMultiSelect
		cbLine := ", oBmp"
		//cbLine := ""
		AEval(::aData[1],{|x,y| cbLine := cbLine + ", Self:aData[Self:oBrowse:nAt, " + AllTrim(Str(y,10,0)) + "] "}, 2 )
		cbLine := "{ || { " + Substr(cbLine,2) + " } }"
		::oBrowse:bLine := &(cbLine)
	Else
		cbLine := ", oBmp, IIf( Self:aData[Self:oBrowse:nAt,2], oSel, oUns )"
		//cbLine := ", IIf( Self:aData[Self:oBrowse:nAt,1], oSel, oUns )"
		AEval(::aData[1],{|x,y| cbLine := cbLine + ", Self:aData[Self:oBrowse:nAt, " + AllTrim(Str(y,10,0)) + "] "}, 3 )
		cbLine := "{ || { " + Substr(cbLine,2) + " } }"
		::oBrowse:bLine := &(cbLine)
	EndIf

	//y,x,w,h
	TchKeyObj():New(  15, ::oPosition:GetWidth() - 50, 40, 40, "oBtnTop",    ::oGridDlg, "C:\RA\VER811\GoTop.GIF",    "Primeiro",     { || ::BrTop() }    )
	TchKeyObj():New(  60, ::oPosition:GetWidth() - 50, 40, 40, "oBtnPgUp",   ::oGridDlg, "C:\RA\VER811\PageUp.GIF",   "Sobe página",  { || ::BrPgUp() }   )
	TchKeyObj():New( 105, ::oPosition:GetWidth() - 50, 40, 40, "oBtnUp",     ::oGridDlg, "C:\RA\VER811\Up.GIF",       "Acima",        { || ::BrUp() }     )
	TchKeyObj():New( 150, ::oPosition:GetWidth() - 50, 40, 40, "oBtnDown",   ::oGridDlg, "C:\RA\VER811\Down.GIF",     "Abaixo",       { || ::BrDown() }   )
	TchKeyObj():New( 195, ::oPosition:GetWidth() - 50, 40, 40, "oBtnPgDn",   ::oGridDlg, "C:\RA\VER811\PageDown.GIF", "Desce página", { || ::BrPgDn() }   )
	TchKeyObj():New( 240, ::oPosition:GetWidth() - 50, 40, 40, "oBtnBottom", ::oGridDlg, "C:\RA\VER811\GoBottom.GIF", "Último",       { || ::BrBottom() } )

	If ::lMultiSelect
		TchKeyObj():New( 295, ::oPosition:GetWidth() - 50, 40, 40, "oBtnSelCur", ::oGridDlg, "C:\RA\VER811\Select.GIF",          "Seleciona", { || ::BrSelCur() } )
		TchKeyObj():New( 340, ::oPosition:GetWidth() - 50, 40, 40, "oBtnSelAll", ::oGridDlg, "C:\RA\VER811\SelectAll.GIF",       "Todos",     { || ::BrSelAll() } )
		TchKeyObj():New( 385, ::oPosition:GetWidth() - 50, 40, 40, "oBtnUnsAll", ::oGridDlg, "C:\RA\VER811\UnselectAll.GIF",     "Nenhum",    { || ::BrUnsAll() } )
		TchKeyObj():New( 430, ::oPosition:GetWidth() - 50, 40, 40, "oBtnInvSel", ::oGridDlg, "C:\RA\VER811\InvertSelection.GIF", "Inverte",   { || ::BrInvSel() } )
	Else
		If ::aF3 <> nil
			TchKeyObj():New( 295, ::oPosition:GetWidth() - 50, 40, 40, "oBtnF3",     ::oGridDlg, "C:\RA\VER811\F3.GIF", "F3",    { || ::BrSelByF3() } )
		EndIf
	EndIf

	TchKeyObj():New( ::oPosition:GetHeight() - 95, ::oPosition:GetWidth() - 50, 40, 40, "oBtnConfirm", ::oGridDlg, "C:\RA\VER811\Confirm.GIF", "Confirma", {||::BrConfirm()} )
	TchKeyObj():New( ::oPosition:Getheight() - 50, ::oPosition:GetWidth() - 50, 40, 40, "oBtnCancel",  ::oGridDlg, "C:\RA\VER811\Cancel.GIF",  "Cancela",  {||::BrCancel()}  )

	If ::lCentered
		ACTIVATE MSDIALOG ::oGridDlg CENTERED
	Else
		ACTIVATE MSDIALOG ::oGridDlg
	EndIf

Return( ::lReturn )


Method BrTop() Class TchGridObj

	If Len( ::aData ) > 0
		::oBrowse:nAt := 1
	EndIf

Return( nil )


Method BrPgUp() Class TchGridObj
	If Len( ::aData ) > 0
		If ::oBrowse:nAt > 10
			::oBrowse:nAt -= 10
		Else
			::oBrowse:nAt := 1
		EndIf
	EndIf
Return( nil )


Method BrUp() Class TchGridObj
	If Len( ::aData ) > 0 .AND. ::oBrowse:nAt > 1
		::oBrowse:nAt--
	EndIf
Return( nil )


Method BrDown() Class TchGridObj
	If Len( ::aData ) > 0 .AND. ::oBrowse:nAt < Len( ::aData )
		::oBrowse:nAt++
	EndIf
Return( nil )


Method BrPgDn() Class TchGridObj
	If Len( ::aData ) > 0
		If ::oBrowse:nAt < Len( ::aData ) - 10
			::oBrowse:nAt += 10
		Else
			::oBrowse:nAt := Len( ::aData )
		EndIf
	EndIf
Return( nil )


Method BrBottom() Class TchGridObj
	If Len( ::aData ) > 0
		::oBrowse:nAt := Len( ::aData )
	EndIf
Return( Nil )


Method BrSelCur() Class TchGridObj
	::aData[ ::oBrowse:nAt, 2 ] := !::aData[ ::oBrowse:nAt, 2 ]
Return( nil )


Method BrSelAll() Class TchGridObj

	Local nPos
	
	For nPos := 1 To Len( ::aData )
		::aData[ nPos, 2 ] := .T.
	Next nPos

Return( nil )


Method BrUnsAll() Class TchGridObj

	Local nPos
	
	For nPos := 1 To Len( ::aData )
		::aData[ nPos, 2 ] := .F.
	Next nPos

Return( nil )


Method BrInvSel() Class TchGridObj

	Local nPos
	
	For nPos := 1 To Len( ::aData )
		::aData[ nPos, 2 ] := !::aData[ nPos, 2 ]
	Next nPos

Return( nil )


Method BrConfirm() Class TchGridObj

	::nCurrent := ::oBrowse:nAt

	If !Empty( ::bSelectEvent )
		Eval( ::bSelectEvent )
	EndIf

	::lReturn  := .T.

	::oGridDlg:End()

Return( nil )


Method BrCancel() Class TchGridObj

	If !Empty( ::bCancelEvent )
		Eval( ::bCancelEvent )
	EndIf
	
	::oGridDlg:End()

Return( nil )


Method BrSelByF3() Class TchGridObj

	Local nRow
	Local nCol
	Local nOffset
	Local bSimilar
	Local nFoundAt

	If ConPad1( nil, nil, nil, ::aF3[1], nil, nil, .F. )

		nFoundAt := 0

		nRow := 1

		If ::lMultiSelect
			nOffset := 2
		Else
			nOffset := 1
		EndIf

		While ( nFoundAt == 0 ) .AND. ( nRow <= Len( ::aData ) )

			bSimilar := .T.

			nCol := 1

			While nCol <= Len( ::aF3[2] ) .AND. bSimilar

				bSimilar := bSimilar .AND. ( ::aData[ nRow, nCol + nOffset ] == &( ::aF3[ 1 ] )->( FieldGet( FieldPos( ::aF3[ 2, nCol ] ) ) ) )
				
				nCol++

			End
			
			if bSimilar
				nFoundAt := nRow
			Endif

			nRow++

		End

		If nFoundAt <> 0
			::oBrowse:nAt := nFoundAt
			::BrConfirm()
		EndIF

	Endif

Return( nil )


Method GetSelData() Class TchGridObj

	Local aSelData := {}
	Local aTemp := {}
	Local nPos

	If Len( ::aData ) > 0

		If !::lMultiSelect

			aTemp := Array( Len( ::aData[ ::nCurrent ] ) - 1 )
			Acopy( ::aData[ ::nCurrent ], aTemp, 2 )
			Aadd( aSelData, aTemp )

		Else
	
			For nPos := 1 to Len( ::aData )
	
				If ::aData[ nPos, 2 ]

					aTemp := Array( Len( ::aData[ nPos ] ) - 2 )
					//Acopy( ::aData[ nPos ], aTemp, 3, Len( ::aData[ nPos ] ) - 1 )
					Acopy( ::aData[ nPos ], aTemp, 3 )
					Aadd( aSelData, aTemp )

				EndIf
	
			Next nPos
	
		EndIf

	EndIf

Return( aSelData )


Method GetSelItems() Class TchGridObj

	Local aSelItems := {}
	Local nPos

	If !::lMultiSelect

		aSelItems := { ::nCurrent }

	Else

		For nPos := 1 To Len( ::aData )

			If ::aData[ nPos, 2 ]
				Aadd( aSelItems, nPos  )
			EndIf

		Next nPos

	EndIf

Return( aSelItems ) 