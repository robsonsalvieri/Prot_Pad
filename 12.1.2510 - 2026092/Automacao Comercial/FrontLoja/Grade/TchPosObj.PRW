#INCLUDE "TchGridObj.ch"

Class TchPosObj

	Data nLeft
	Data nTop
	Data nWidth
	Data nHeight

	Method New( nTop, nLeft, nHeight, nWidth ) Constructor
	Method GetTop()
	Method GetLeft()
	Method GetHeight()
	Method GetWidth()
	Method GetBottom()
	Method GetRight()
	
EndClass

Method New( nTop, nLeft, nHeight, nWidth ) class TchPosObj

	If !Empty( nTop )
		::nTop    := nTop
	Else
		::nTop    := 0
	EndIf
	If !Empty( nLeft )
		::nLeft   := nLeft
	Else
		::nLeft   := 0
	EndIf
	::nHeight := nHeight	
	::nWidth  := nWidth

return

Method GetTop() class TchPosObj
Return ::nTop

Method GetLeft() class TchPosObj
Return ::nLeft

Method GetHeight() class TchPosObj
Return ::nHeight

Method GetWidth() class TchPosObj
Return ::nWidth

Method GetBottom() class TchPosObj
Return ::nTop + ::nHeight

Method GetRight() class TchPosObj
Return ::nLeft + ::nWidth 