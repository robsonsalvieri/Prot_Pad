#INCLUDE "AdvCtrls.ch"
#INCLUDE "PROTHEUS.CH" 

Class TAdvColor

	Data FRed
	Data FGreen
	Data FBlue
	Data FValue

	Method New()
	Method NewRGB( nRed, nGreen, nBlue )
	Method NewValue( nValue )
	Method SetValue()
	Method GetValue()
	Method SetRed()
	Method GetRed()
	Method SetGreen()
	Method GetGreen()
	Method SetBlue()
	Method GetBlue()
	Method InvertColor()
	Method RGBToValue()
	Method ValueToRGB()
	Method GetBW()

EndClass



Method New() Class TAdvColor

	::FRed   := 0
	::FGreen := 0
	::FBlue  := 0
	::FValue := 0

Return( nil )



Method NewRGB( nRed, nGreen, nBlue ) Class TAdvColor

	::FRed   := ValidateRGB( nRed )
	::FGreen := ValidateRGB( nGreen )
	::FBlue  := ValidateRGB( nBlue )
	::RGBToValue()

Return( nil )



Method NewValue( nValue ) Class TAdvColor

	::FValue := ValidateValue( nValue )
	::ValueToRGB()

Return( nil )



Method SetValue( nValue ) Class TAdvColor

	::FValue := ValidateValue( nValue )
	::ValueToRGB()

Return( nil )



Method GetValue() Class TAdvColor
Return( ::FValue )



Method SetRed( nRed ) Class TAdvColor

	::FRed := ValidateRGB( nRed )
	::RGBToValue()

Return( nil )



Method GetRed() Class TAdvColor
Return( ::FRed )



Method SetGreen( nGreen ) Class TAdvColor

	::FGreen := ValidateRGB( nGreen )
	::RGBToValue()

Return( nil )



Method GetGreen() Class TAdvColor
Return( ::FGreen )



Method SetBlue( nBlue ) Class TAdvColor

	::FBlue := ValidateRGB( nBlue )
	::RGBToValue()

Return( nil )



Method GetBlue() Class TAdvColor
Return( ::FBlue )



Method InvertColor() Class TAdvColor

	::FValue := 16777215 - ::FValue
	::ValueToRGB()

Return( nil )



Method RGBToValue() Class TAdvColor

	::FValue := ::FRed + ( ::FGreen * 256 ) + ( ::FBlue * 65536 )

Return( nil )



Method ValueToRGB() Class TAdvColor

	::FBlue  := Int( ::FValue / 65536 )
	::FGreen := Int( ( ::FValue - ::FBlue * 65536 ) / 256 )
	::FRed   := ::FValue - ( ::FBlue * 65536 ) - ( ::FGreen * 256 )

Return( nil )



Method GetBW() Class TAdvColor

	Local nAvg := Int( ( ::FRed + ::FGreen + ::FBlue ) / 3 )

Return( nAvg + ( nAvg * 256 ) + ( nAvg * 65536 ) )



Static Function ValidateValue( nValue )

	Local nRet := IIf( nValue < 0, 0, IIf( nValue>16777215, 16777215, nValue ) )

Return( nRet )



Static Function ValidateRGB( nValue )

	Local nRet := IIf( nValue < 0, 0, IIf( nValue>255, 255, nValue ) )

Return( nRet )

function testeadvColor()

return.T. 