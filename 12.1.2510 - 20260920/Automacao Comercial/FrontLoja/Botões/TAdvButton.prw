#INCLUDE "AdvCtrls.ch"
#INCLUDE "PROTHEUS.CH" 

Class TAdvButton From TPanel

	Data FOwner
	Data FLeft
	Data FTop
	Data FWidth
	Data FHeight
	Data FCaption
	Data FBgColor
	Data FFont
	Data FBrdrWidth
	Data FBrdrColor
	Data FEnabled
	Data FClickBlock
	Data FData

	Method New( oOwner, nLeft, nTop, nWidth, nHeight, cCaption, oBgColor, oFont, nBrdrWidth, oBrdrColor, blClickBlock, oData ) Constructor
	
	Method GetData()
	Method SetEnabled()
	
EndClass

Method New( oOwner, nLeft, nTop, nWidth, nHeight, cCaption, oBgColor, oFont, nBrdrWidth, oBrdrColor, blClickBlock, oData ) Class TAdvButton
	:New( nTop, nLeft, cCaption, oOwner, oFont:GetFont(), .T., .F., oFont:GetColor():GetValue(), oBgColor:GetValue(), nWidth, nHeight, .F., .T. )

	::FOwner      := oOwner
	::FLeft       := nLeft
	::FTop        := nTop
	::FWidth      := nWidth
	::FHeight     := nHeight
	::FCaption    := cCaption
	::FBgColor    := oBgColor
	::FFont       := oFont
	::FBrdrWidth  := nBrdrWidth
	::FBrdrColor  := oBrdrColor
	::FEnabled    := .T.
	::FClickBlock := blClickBlock
	::FData       := oData

	If blClickBlock <> nil
		::blClicked := { || IIf( Self:FEnabled, ( ShowClick( Self ), Eval( blClickBlock, Self:FData ) ), nil ) }
	Else
		::blClicked := { || IIf( Self:FEnabled, ShowClick( Self ), nil ) }
	EndIf

Return()

Method GetData() Class TAdvButton
Return( ::FData )

Method SetEnabled( bEnabled ) Class TAdvButton
	::FEnabled := bEnabled
	If ::FEnabled
		::nClrPane := ::FBgColor
		::nClrText := ::FFont:GetColor()
	Else
		::nClrPane := ::FBgColor:GetBW()
		::nClrText := ::FFont:GetColor():GetBW()
	Endif
Return( nil )

Static Function ShowClick( oAdvBtn )

	Local nOrigBack := oAdvBtn:nClrPane
	Local nOrigFore := oAdvBtn:nClrText
	Local oNewBack  := TAdvColor():NewValue( nOrigBack )
	Local oNewFore  := TAdvColor():NewValue( nOrigFore )

	oNewBack:InvertColor()
	oNewFore:InvertColor()
	oAdvBtn:nClrPane := oNewBack:GetValue()
	oAdvBtn:nClrText := oNewFore:GetValue()
	ProcessMessages() 
	Sleep(50)
	oAdvBtn:nClrPane := nOrigBack
	oAdvBtn:nClrText := nOrigFore

Return( nil )

function testeadvbutton()

return.T.	