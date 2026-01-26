#include "TOTVS.CH"

#define CRLF chr( 13 ) + chr( 10 )

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSB4DEnt - Other RemunerationAPI
@type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSB4DEnt from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getAttachments()
    Method maskDate(cDate)
    Method getJustifications(cRecno)

EndClass

Method New() Class PLSB4DEnt
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSB4DEnt
	local oJson           := JsonObject():New()
    local aRet            := nil
	default oJsonControl  := CenJsonControl():New()

    aRet := self:getJustifications(self:getValue("recno"))

    oJsonControl:setProp(oJson,"appealProtocol",            self:getValue("appealProtocol"))
    oJsonControl:setProp(oJson,"protocol",                  self:getValue("protocol"))
    oJsonControl:setProp(oJson,"newProtocol",               self:getValue("newProtocol"))
    oJsonControl:setProp(oJson,"autorizationNumber",        self:getValue("autorizationNumber"))
    oJsonControl:setProp(oJson,"requestDate",               self:maskDate(self:getValue("requestDate")))
    oJsonControl:setProp(oJson,"status",                    self:getValue("status"))
    oJsonControl:setProp(oJson,"origem",                    self:getValue("origem"))
    oJsonControl:setProp(oJson,"appealObject",              self:getValue("appealObject"))
    oJsonControl:setProp(oJson,"sequential",                self:getValue("sequential"))
    oJsonControl:setProp(oJson,"insurerJustification",      aRet[1])
    oJsonControl:setProp(oJson,"providerJustification",     aRet[2] + aRet[3])
    oJsonControl:setProp(oJson,"attachments",               ::getAttachments(self:getValue("attachmentsKey")))
    oJsonControl:setProp(oJson,"attachmentsKey",            self:getValue("attachmentsKey"))
    
return oJson

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} destroy

@type  Class
@author Lucas Nonato
@since 01/03/2020
/*/
//------------------------------------------------------------------------------------------
Method destroy() Class PLSB4DEnt
	_Super:destroy()
	DelClassIntF()
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} maskDate

@type  Class
@author Lucas Nonato
@since 01/03/2020
/*/
//------------------------------------------------------------------------------------------
Method maskDate(cDate) Class PLSB4DEnt
Return SubStr(cDate,1,4)+"-"+SubStr(cDate,5,2)+"-"+SubStr(cDate,7,2)

//-------------------------------------------------------------------
/*/{Protheus.doc} getAttachments
Query que retorna todos os customers

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
Method getAttachments(cChave) Class PLSB4DEnt
local cSql    := ""
local cRet      := ""
local nX        := 1

cSql += "SELECT ACB_OBJETO FROM " + retSqlName("AC9") + " AC9 "
cSql += " INNER JOIN " + retSqlName("ACB") + " ACB "	
cSql += " ON ACB_FILIAL = '"+xFilial("ACB")+"'  "	
cSql += " AND ACB_CODOBJ = AC9_CODOBJ "
cSql += " AND ACB.D_E_L_E_T_ = ' ' "
cSql += " WHERE AC9_FILIAL = '" + xFilial('AC9') + "' "
cSql += " AND AC9_ENTIDA = 'B4D' "
cSql += " AND AC9_CODENT = '" + xFilial('B4D') + cChave + "' "
cSql += " AND AC9.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbACB",.F.,.T.)

while !TrbACB->(eof())
    cRet += iif(nX==1,"",",")
    cRet += alltrim(TrbACB->ACB_OBJETO)
    nX++
    TrbACB->(dbskip())
enddo

TrbACB->(dbCloseArea())	

return cRet

method getJustifications(cRecno) class PLSB4DEnt

    local cInsurerJust    := ''
    local cProtocolJust   := ''
    local cFormNumberJust := ''

    B4D->(dbsetorder(1))
    B4D->(dbgoto(cRecno))
    cInsurerJust := B4D->B4D_JUSOPE
    cProtocolJust := B4D->B4D_JUSPRO
    cFormNumberJust := B4D->B4D_JUSGUI

Return { cInsurerJust, cProtocolJust, cFormNumberJust }
