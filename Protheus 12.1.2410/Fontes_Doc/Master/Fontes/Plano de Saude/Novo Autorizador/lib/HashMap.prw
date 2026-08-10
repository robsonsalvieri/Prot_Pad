#include "TOTVS.CH"

Class HashMap

    Data hMap
    Data lEmpty
	
	Method New() Constructor
    Method get(cProperty)
    Method set(cProperty,anyValue)
    Method empty()
    Method clean()
	
EndClass

Method New() Class HashMap
	self:hMap := THashMap():New()
	self:lEmpty := .T.
Return self

Method get(cProperty) Class HashMap
	Local anyValue := ""
	self:hMap:get(cProperty,@anyValue)
Return anyValue

Method set(cProperty,anyValue) Class HashMap
	self:lEmpty := .F.
	self:hMap:set(cProperty,@anyValue)
Return

Method empty() Class HashMap
Return self:lEmpty

Method clean() Class HashMap
	self:lEmpty := .T.
Return self:hMap:clean()
//