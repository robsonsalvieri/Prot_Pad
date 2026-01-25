#Include 'protheus.ch'

Class PrjOutCNX From PrjImpOut
	Data cCodOpe
	Data cCodEmp
	Data cCodCon
	Data cNumCon
	Data cVerCon
	Data cSubCon
	Data cVerSub

	Method new()

EndClass

Method new() Class PrjOutCNX
	_Super:new()
	self:cCodOpe := "0001"
	self:cCodEmp := "9991"
	self:cCodCon := "9991"
	self:cNumCon := "900000000001"
	self:cVerCon := "001"
Return self