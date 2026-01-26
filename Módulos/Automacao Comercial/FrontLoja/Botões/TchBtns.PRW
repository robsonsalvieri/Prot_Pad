/* * *
 * Class BtnItem
 * * */                        
#INCLUDE "PROTHEUS.CH"  

Class BtnItem

	Data FCode
	Data FDescription
	Data FBlock
	Data FBackColor
	Data FForeColor

	Method New( cCode, cDescription, bBlock ) Constructor
	Method GetCode()
	Method GetDescription()
	Method SetBlock( bBlock )
	Method GetBlock()
	Method SetBackColor()
	Method GetBackColor()
	Method SetForeColor()
	Method GetForeColor()

EndClass

Method New( cCode, cDescription, bBlock ) Class BtnItem
	::FCode        := cCode
	::FDescription := cDescription
	::FBlock       := bBlock
Return( nil )

Method GetCode()  Class BtnItem
Return( ::FCode )

Method GetDescription()  Class BtnItem
Return( ::FDescription )

Method SetBlock( bBlock )  Class BtnItem
	::FBlock := bBlock
Return( nil )

Method GetBlock()  Class BtnItem
Return( ::FBlock )
Method SetBackColor( nBackColor ) Class BtnItem
	::FBackColor := nBackColor
Return( nil )

Method GetBackColor() Class BtnItem
Return( ::FBackColor )

Method SetForeColor( nForeColor ) Class BtnItem
	::FForeColor := nForeColor
Return( nil )

Method GetForeColor() Class BtnItem
Return( ::FForeColor )

/* * *
 * Class BtnGroup
 * * */

Class BtnGroup
	
	Data FCode
	Data FDescription
	Data FData
	Data FBackColor
	Data FForeColor
	
	Method New( cCode, cDescription ) Constructor
	Method GetCode()
	Method GetDescription()
	Method SetBackColor()
	Method GetBackColor()
	Method SetForeColor()
	Method GetForeColor()
	Method Add( cKind, oData )
	Method GetItemAt( nPos )
	Method GetItems()
	Method GetItemsQty()

EndClass

Method New( cCode, cDescription ) Class BtnGroup
	::FCode        := cCode
	::FDescription := cDescription
	::FData        := {}
Return( nil )

Method GetCode() Class BtnGroup
Return( ::FCode )

Method GetDescription() Class BtnGroup
Return( ::FDescription )

Method SetBackColor( nBackColor ) Class BtnGroup
	::FBackColor := nBackColor
Return( nil )

Method GetBackColor() Class BtnGroup
Return( ::FBackColor )

Method SetForeColor( nForeColor ) Class BtnGroup
	::FForeColor := nForeColor
Return( nil )

Method GetForeColor() Class BtnGroup
Return( ::FForeColor )
Method Add( cKind, oData ) Class BtnGroup

	Local nPos := 0

	If Upper(cKind) == "G" .OR. Upper(cKind) == "I" .OR. Upper(cKind) == "O"

		Aadd( ::FData, { cKind, oData } )
		nPos := Len( ::FData )

	EndIf

Return( nPos )

Method GetItemAt( nPos ) Class BtnGroup

	Local aData := {}

	If nPos <= Len( ::FData )
		aData := Aclone( ::FData[ nPos ] )
	EndIf

Return( aData )

Method GetItems() Class BtnGroup
Return( Aclone( ::FData ) )

Method GetItemsQty() Class BtnGroup
Return( Len( ::FData ) )


/* * *
 * Class TchButton
 * * */

Class TchButton From TButton

	Data FData
	Data FTipo
	Data FVezes
	Data FDlg
	Data FPagto

	Method Criar( nLeft, nTop, nWidth, nHeight, cName, cCaption, oFont, nBackColor, nForeColor, oOwner, cFunction, oData, cTipo, lVezes, oDlg, lPagto ) Constructor

EndClass

Method Criar( nLeft, nTop, nWidth, nHeight, cName, cCaption, oFont, nBackColor, nForeColor, oOwner, cFunction, oData, cTipo, lVezes, oDlg, lPagto ) Class TchButton
	:New( nTop, nLeft, cName, oOwner )
	
	::FData      := oData 
	::FTipo      := cTipo
	::FVezes     := lVezes
	::FDlg       := oDlg
	::FPagto     := lPagto
	::FBgColor   := nBackColor
	::FForeColor := nForeColor

	::nTop              := nTop
	::nLeft             := nLeft
	::cName 			:= cName
	::cCaption 		    := &( LjMacroBotao( AllTrim( cCaption ) ) )
	::nWidth 			:= nWidth
	::nHeight 			:= nHeight
	::lShowHint 		:= .F.
	::lReadOnly 		:= .F.
	::Align 			:= 0
	::oFont 			:= oFont
	::lVisibleControl 	:= .T.
	::blClicked 		:= {|| &(cFunction)( ::FData, ::FTipo, ::FVezes, ::FDlg, ::FPagto ) }

Return( nil )

function testechbtns()

return.T. 