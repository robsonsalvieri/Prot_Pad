#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSB4EEnt - Other RemunerationAPI
@type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSB4EEnt from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getJustifications(cRecno)

EndClass

Method New() Class PLSB4EEnt
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSB4EEnt

	local oJson     := JsonObject():New()
    local aProced   := {}
    local aGlosas   := {}
    local cCodPad   := ""
    local cCodPro   := ""
    local cData     := ""
    local cGlosas   := ""    
    local nX        := 0
    local aRet      := nil 
	default oJsonControl := CenJsonControl():New()

    aProced		:= PLGETPROC(self:getValue("tableCode"),self:getValue("eventCode"))
	cCodPad 	:= aProced[2]
	cCodPro 	:= aProced[3]
    cData       := self:getValue("date")
    cData       := substr(cData,7,2)  + "/" +; 
			       substr(cData,5,2) + "/" + ;
			       substr(cData,1,4)

    aGlosas     := Pls498DesG("",   self:getValue("healthInsurerId"),;
                                    self:getValue("typingLocation"),;
                                    self:getValue("protocol"),;
                                    self:getValue("healthInsurerFormNumber"),;
                                    self:getValue("movementOrigin"),; 
                                    self:getValue("tableCode"),;
                                    padr(self:getValue("eventCode"),16),;
                                    self:getValue("sequential"),;
                                    3)

    for nX:=1 to len(aGlosas)
        cGlosas += alltrim(aGlosas[nX]) + "<br>"
    next                                    

    aRet := self:getJustifications(self:getValue("recno"))
    oJsonControl:setProp(oJson,"tableCode",                 cCodPad)
    oJsonControl:setProp(oJson,"eventCode",                 cCodPro)
    oJsonControl:setProp(oJson,"eventDescription",          self:getValue("eventDescription"))
    oJsonControl:setProp(oJson,"reconsideredValue",         self:getValue("reconsideredValue"))
    oJsonControl:setProp(oJson,"acceptedValue",             self:getValue("acceptedValue"))
    oJsonControl:setProp(oJson,"providerJustification",     aRet[2])
    oJsonControl:setProp(oJson,"insurerJustification",      aRet[1])
    oJsonControl:setProp(oJson,"sequential",                self:getValue("sequential"))
    oJsonControl:setProp(oJson,"gloss",                     alltrim(cGlosas))
    oJsonControl:setProp(oJson,"date",                      cData)
    oJsonControl:setProp(oJson,"status",                    self:getValue("status"))

return oJson

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} destroy

@type  Class
@author Lucas Nonato
@since 01/03/2020
/*/
//------------------------------------------------------------------------------------------
Method destroy() Class PLSB4EEnt
	_Super:destroy()
	DelClassIntF()
Return

method getJustifications(cRecno) class PLSB4EEnt

    local cInsurerJust    := ''
    local cProviderJust   := ''

    B4E->(dbsetorder(1))
    B4E->(dbgoto(cRecno))
    cInsurerJust := B4E->B4E_JUSOPE
    cProviderJust := B4E->B4E_JUSPRE

Return { cInsurerJust, cProviderJust }
