#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PlsB1R
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PlsB1R from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PlsB1R
	_Super:New()
Return self

Method serialize(oJsonControl) Class PlsB1R

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"fileUrl" ,self:getValue("fileUrl")) // B1R_HATARQ
    oJsonControl:setProp(oJson,"accessToken" ,self:getValue("accessToken")) // B1R_HATTOK
    oJsonControl:setProp(oJson,"transactionType" ,self:getValue("transactionType")) // B1R_HATTIP
    oJsonControl:setProp(oJson,"healthProviderId" ,self:getValue("healthProviderId")) // B1R_ORIGEM
    oJsonControl:setProp(oJson,"protocol" ,self:getValue("protocol")) // B1R_PROTOC
    oJsonControl:setProp(oJson,"sourceProtocol" ,self:getValue("sourceProtocol")) // B1R_PROTOG
    oJsonControl:setProp(oJson,"uploadDate" ,self:getValue("uploadDate")) // B1R_DATSUB
    oJsonControl:setProp(oJson,"generatedProtocol" ,self:getValue("generatedProtocol")) // B1R_PROTOI
    oJsonControl:setProp(oJson,"status" ,self:getValue("status")) // B1R_STATUS
    
Return oJson

Method destroy() Class PlsB1R
	_Super:destroy()
	DelClassIntF()
return