#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} PCPMonitorGauge
Classe para renderizar o componente de Gauge
@type Class
@author renan.roeder
@since 15/08/2023
@version P12.1.2310
@return Nil
/*/
Class PCPMonitorGauge FROM LongNameClass
    Private DATA oGauge AS Object

    Public Method New() Constructor
    Public Method Destroy()
    Public Method SetType(cType)
    Public Method SetMinValue(nValue)
    Public Method SetMaxValue(nValue)
    Public Method SetValue(nValue)
    Public Method SetValueStyle(cProperty,cValue)
    Public Method SetLabel(cLabel)
    Public Method SetLabelStyle(cProperty,cValue)
    Public Method SetPrepend(cPrepend)
    Public Method SetPrependStyle(cProperty,cValue)
    Public Method SetAppend(cAppend)
    Public Method SetAppendStyle(cProperty,cValue)
    Public Method SetThick(nThick)
    Public Method SetMargin(nMargin)
    Public Method SetThreshold(cValue,cColor,nBGOpacity)
    Public Method SetMarker(cLabel,cColor,nSize,cType)
    Public Method GetJsonObject()
EndClass

Method New() Class PCPMonitorGauge
    ::oGauge := JsonObject():New()
    ::SetType("arch")
    ::SetThick(20)
    ::SetMargin(15)
Return

Method Destroy () Class PCPMonitorGauge
    FreeObj(::oGauge)
Return

Method SetType(cType) Class PCPMonitorGauge
    ::oGauge["type"] := cType
Return

Method SetMinValue(nValue) Class PCPMonitorGauge
    ::oGauge["min"] := nValue
Return

Method SetMaxValue(nValue) Class PCPMonitorGauge
    ::oGauge["max"] := nValue
Return

Method SetValue(nValue) Class PCPMonitorGauge
    ::oGauge["value"] := nValue
Return

Method SetValueStyle(cProperty,cValue) Class PCPMonitorGauge
    If !::oGauge:HasProperty("valueStyle")
        ::oGauge["valueStyle"] := JsonObject():New()
    EndIf
    ::oGauge["valueStyle"][cProperty] := cValue
Return

Method SetLabel(cLabel) Class PCPMonitorGauge
    ::oGauge["label"] := cLabel
Return

Method SetLabelStyle(cProperty,cValue) Class PCPMonitorGauge
    If !::oGauge:HasProperty("labelStyle")
        ::oGauge["labelStyle"] := JsonObject():New()
    EndIf
    ::oGauge["labelStyle"][cProperty] := cValue
Return

Method SetPrepend(cPrepend) Class PCPMonitorGauge
    ::oGauge["prepend"] := cPrepend
Return

Method SetPrependStyle(cProperty,cValue) Class PCPMonitorGauge
    If !::oGauge:HasProperty("prependStyle")
        ::oGauge["prependStyle"] := JsonObject():New()
    EndIf
    ::oGauge["prependStyle"][cProperty] := cValue
Return

Method SetAppend(cAppend) Class PCPMonitorGauge
    ::oGauge["append"] := cAppend
Return

Method SetAppendStyle(cProperty,cValue) Class PCPMonitorGauge
    If !::oGauge:HasProperty("appendStyle")
        ::oGauge["appendStyle"] := JsonObject():New()
    EndIf
    ::oGauge["appendStyle"][cProperty] := cValue
Return

Method SetThick(nThick) Class PCPMonitorGauge
    ::oGauge["thick"] := nThick
Return

Method SetMargin(nMargin) Class PCPMonitorGauge
    ::oGauge["margin"] := nMargin
Return

Method SetThreshold(cValue,cColor,nBGOpacity) Class PCPMonitorGauge
    Default nBGOpacity := 0.2
    If !::oGauge:HasProperty("thresholds")
        ::oGauge["thresholds"] := JsonObject():New()
    EndIf
    ::oGauge["thresholds"][cValue] := JsonObject():New()
    ::oGauge["thresholds"][cValue]["color"]     := cColor
    ::oGauge["thresholds"][cValue]["bgOpacity"] := nBGOpacity
Return

Method SetMarker(cLabel,cColor,nSize,cType) Class PCPMonitorGauge
    Default cColor := COR_PRETO, nSize := 6, cType := "line"
    If !::oGauge:HasProperty("markers")
        ::oGauge["markers"] := JsonObject():New()
    EndIf
    ::oGauge["markers"][cLabel] :=  JsonObject():New()
    ::oGauge["markers"][cLabel]["color"] := cColor
    ::oGauge["markers"][cLabel]["size"]  := nSize
    ::oGauge["markers"][cLabel]["label"] := cLabel
    ::oGauge["markers"][cLabel]["type"]  := cType
Return

Method GetJsonObject() Class PCPMonitorGauge
Return ::oGauge
