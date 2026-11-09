#INCLUDE "PROTHEUS.CH"

Class TchKeyObj

	Method New( nTop, nLeft, nHeight, nWidth, cName, oOwner, cBitmap, cCaption, bClicked ) Constructor

EndClass

Method New( nTop, nLeft, nHeight, nWidth, cName, oOwner, cBitmap, cCaption, bClicked ) Class TchKeyObj

	Local oKey
    Local oPosition

	//y,x,w,h
	oPosition := TchPosObj():New( nTop, nLeft, Iif( Empty( nWidth ), 40, nWidth ), Iif( Empty( nHeight ), 40, nHeight ) )
	oKey := TBITMAP():Create( oOwner )
	oKey:cName           := cName
	oKey:cBmpFile        := cBitmap
	oKey:cCaption        := cCaption
	oKey:nTop            := oPosition:GetTop()
	oKey:nLeft           := oPosition:GetLeft()
	oKey:nHeight         := oPosition:GetHeight()
	oKey:nWidth          := oPosition:GetWidth()
	oKey:lShowHint       := .F.
	oKey:lReadOnly       := .F.
	oKey:Align           := 0
	oKey:lVisibleControl := .T.
	oKey:lStretch        := .T.
	oKey:lAutoSize       := .F.
	oKey:bLClicked       := bClicked

Return( oKey ) 