#INCLUDE "AdvCtrls.ch"
#INCLUDE "PROTHEUS.CH" 

Class TAdvFont

	Data FName
	Data FColor
	Data FSize
	Data FHeight
	Data FBold
	Data FItalic
	Data FUnderline
	Data FFont

	Method New( cName, nSize, nHeight, oColor, bBold, bItalic, bUnderline ) Constructor
	
	Method SetName()
	Method GetName()
	Method SetSize()
	Method GetSize()
	Method SetHeight()
	Method GetHeight()
	Method SetColor()
	Method GetColor()
	Method SetBold()
	Method GetBold()
	Method SetItalic()
	Method GetItalic()
	Method SetUnderline()
	Method GetUnderline()
	Method GetFont()
	Method CreateFont()

EndClass



Method New(  cName, nSize, nHeight, oColor, bBold, bItalic, bUnderline ) Class TAdvFont

	::FName      := cName
	::FColor     := oColor
	::FSize      := nSize
	::FHeight    := nHeight
	::FBold      := bBold
	::FItalic    := bItalic
	::FUnderline := bUnderline

	::CreateFont()
	
Return( nil )



Method SetName( cName ) Class TAdvFont
	::FName := cName
	::CreateFont()
Return( nil )



Method GetName() Class TAdvFont
Return( ::FName )



Method SetSize( nSize ) Class TAdvFont
	::FSize := nSize
	::CreateFont()
Return( nil )



Method GetSize() Class TAdvFont
Return( ::FSize )



Method SetHeight( nHeight ) Class TAdvFont
	::FHeight := nHeight
	::CreateFont()
Return( nil )



Method GetHeight() Class TAdvFont
Return( ::Height )



Method SetColor( oColor ) Class TAdvFont
	::FColor := oColor
	::CreateFont()
Return( nil )



Method GetColor() Class TAdvFont
Return( ::FColor )



Method SetBold( bBold ) Class TAdvFont
	::FBold := bBold
	::CreateFont()
Return( nil )



Method GetBold() Class TAdvFont
Return( ::FBold )



Method SetItalic( bItalic ) Class TAdvFont
	::FItalic := bItalic
	::CreateFont()
Return( nil )



Method GetItalic() Class TAdvFont
Return( ::FItalic )



Method SetUnderline( bUnderline ) Class TAdvFont
	::FUnderline := bUnderline
	::CreateFont()
Return( nil )



Method GetUnderline() Class TAdvFont
Return( ::FUnderline )



Method GetFont() Class TAdvFont
Return( ::FFont )


Method CreateFont() Class TAdvFont

	::FFont := TFont():New( ::FName, ::FSize, ::FHeight, nil, ::FBold, nil, nil, nil, ::FItalic, ::FUnderline )

Return()

function testeadvfont()

return.T. 