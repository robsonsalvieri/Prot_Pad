#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLUtzUsEnt - Other RemunerationAPI
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLUtzUsEnt from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method maskDate(cDate)

EndClass

Method New() Class PLUtzUsEnt
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLUtzUsEnt

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode"))
    oJsonControl:setProp(oJson,"procedureName",self:getValue("procedureName"))
    oJsonControl:setProp(oJson,"executionDate",self:maskDate(self:getValue("executionDate")))
    oJsonControl:setProp(oJson,"subscribername",self:getValue("subscribername"))
    oJsonControl:setProp(oJson,"healthProviderCode",self:getValue("healthProviderCode"))
    oJsonControl:setProp(oJson,"healthProviderName",self:getValue("healthProviderName"))
    oJsonControl:setProp(oJson,"serviceType",self:getValue("serviceType"))
    oJsonControl:setProp(oJson,"serviceTypeDescription",self:getValue("serviceTypeDescription"))
    oJsonControl:setProp(oJson,"quantity",self:getValue("quantity"))
    oJsonControl:setProp(oJson,"healthProviderDocument",self:getValue("healthProviderDocument"))
    oJsonControl:setProp(oJson,"cid",self:getValue("cid"))
    oJsonControl:setProp(oJson,"toothRegion",self:getValue("toothRegion"))
    oJsonControl:setProp(oJson,"face",self:getValue("face"))
    oJsonControl:setProp(oJson,"paidValue",self:getValue("paidValue"))
    oJsonControl:setProp(oJson,"disallowanceValue",self:getValue("disallowanceValue"))
    oJsonControl:setProp(oJson,"coPaymentValue",self:getValue("coPaymentValue"))
    oJsonControl:setProp(oJson,"origin",self:getValue("origin"))
    oJsonControl:setProp(oJson,"procedureType",self:getValue("procedureType"))
    oJsonControl:setProp(oJson,"gender",self:getValue("gender"))
    oJsonControl:setProp(oJson,"birthDate",self:maskDate(self:getValue("birthDate")))
    oJsonControl:setProp(oJson,"inclusionDate",self:maskDate(self:getValue("inclusionDate")))
    oJsonControl:setProp(oJson,"blockDate",self:maskDate(self:getValue("blockDate")))
    oJsonControl:setProp(oJson,"userType",self:getValue("userType"))
    oJsonControl:setProp(oJson,"countyCode",self:getValue("countyCode"))
   
    //Campos de juncao de query
    oJsonControl:setProp(oJson,"subscriberId",self:getValue("MATRIC"))
    oJsonControl:setProp(oJson,"hospitalizationNumber",self:getValue("GUIAINT"))
    oJsonControl:setProp(oJson,"status",self:getValue("STATUS"))

Return oJson


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} destroy

    @type  Class
    @author sakai
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method destroy() Class PLUtzUsEnt
	_Super:destroy()
	DelClassIntF()
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} maskDate

    @type  Class
    @author sakai
    @since 12/08/2020
/*/
//------------------------------------------------------------------------------------------
Method maskDate(cDate) Class PLUtzUsEnt

    Local cMaskDate := ""

    If !Empty(cDate)
        cMaskDate := SubStr(cDate,1,4)+"-"+SubStr(cDate,5,2)+"-"+SubStr(cDate,7,2)
    EndIf

Return cMaskDate