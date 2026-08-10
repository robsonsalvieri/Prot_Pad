#include "TOTVS.CH"

#define CARACTER "C"
#define NUMBER   "N"
#define BOOLEAN  "L"
#define DATE     "D"
#define ARRAY    "A"
#define OBJECT   "O"

Class AutAbstrata

    Data hMap

    Method New(hMap) Constructor    
    Method set(xKey,xValue)
    Method get(xKey, cType)

EndClass

Method New(HMap) Class AutAbstrata
    self:hMap := HMap
Return self

Method get(xKey, cType) Class AutAbstrata
    Local xValue := ""
    default cType := CARACTER
    self:hMap:get(xKey,@xValue)
    
    if empty(xValue) .and. cType <> CARACTER

        DO CASE
            CASE cType == NUMBER
                xValue := 0
            CASE cType == BOOLEAN
                xValue := .F.
            CASE cType == DATE
                xValue := ctod("")
            CASE cType == ARRAY
                xValue := {}
            CASE cType == OBJECT
                xValue := nil
        END CASE

    endIf
Return xValue

Method set(xKey,xValue) Class AutAbstrata
Return self:hMap:set(xKey,xValue)
//