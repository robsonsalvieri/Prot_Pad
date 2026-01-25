#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

#define GUIMON '1'
#define GUIFOR '2'
#define GUIOUT '3'
#define GUIPRE '4'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenGerXTE
    Classe para a geracao dos arquivos XTE operadoraParaANS do Monitoramento

    @type  Class
    @author everton.mateus
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenGerXTE

    Data cCodOpe as String
    Data cAno as String
    Data cMes as String 
    Data cCodObrig as String
    Data cForRem as String
    Data cCodLote as String
    //Propriedades para casos de teste
    Data cFileName as String
    Data cError as String
    Data cWarning as String

	Method New() Constructor
   
    //Metodos Guia Monitoramento
    Method gerArq()
    Method factGerador(cTipoLote)
    Method factClRem()
EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author everton.mateus
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenGerXTE
    self:cCodOpe := ""
    self:cCodObrig := ""
    self:cAno := ""
    self:cMes := ""
    self:cForRem := ""
    self:cCodLote := ""
    self:cFileName := ""
    self:cError    := ""
    self:cWarning  := ""
return self

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Processa a geracao dos arquivos XTE de determinada Competencia/Ano

    @type  Class
    @author everton.mateus
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method gerArq() Class CenGerXTE
    
    Local oCltBKW := CenCltBKW():New()

    oCltBKW:setValue("operatorRecord"  ,self:cCodOpe)
    oCltBKW:SetValue("requirementCode" ,self:cCodObrig) 
    oCltBKW:SetValue("referenceYear"   ,self:cAno)
    oCltBKW:SetValue("commitmentCode"  ,self:cMes)
    oCltBKW:SetValue("remunerationType",self:cForRem)
    oCltBKW:SetValue("batchCode"       ,self:cCodLote)

    if oCltBKW:bscGerXTE()
        while oCltBKW:HasNext()
            
            oLote := oCltBKW:GetNext()
            oGerador := self:factGerador(oLote:getValue("remunerationType"))
            oGerador:cCodOpe := oLote:getValue("operatorRecord")
            oGerador:cCodObrig := oLote:getValue("requirementCode") 
            oGerador:cAno := oLote:getValue("referenceYear")
            oGerador:cMes := oLote:getValue("commitmentCode")
            oGerador:procLote(oCltBKW)
            self:cFileName := oGerador:cFileName
            self:cError    := oGerador:cError
            self:cWarning  := oGerador:cWarning
            If !Empty(oLote:getValue("batchCode"))
                oClt := self:factClRem(oLote:getValue("remunerationType"))
                oClt:setValue("operatorRecord"  ,oLote:getValue("operatorRecord"))
                oClt:SetValue("requirementCode" ,oLote:getValue("requirementCode")) 
                oClt:SetValue("referenceYear"   ,oLote:getValue("referenceYear"))
                oClt:SetValue("commitmentCode"  ,oLote:getValue("commitmentCode"))
                oClt:SetValue("remunerationType",oLote:getValue("remunerationType"))
                oClt:SetValue("batchCode"       ,oLote:getValue("batchCode"))

                oClt:staPosLot()
                oClt:destroy()
                FreeObj(oClt)
                oClt:= nil
            endIf
            oGerador:destroy()
            oLote:destroy()
            FreeObj(oGerador)
            FreeObj(oLote)
            oLote := nil
            oGerador := nil
        endDo

    endIf
    oCltBKW:destroy()
    FreeObj(oCltBKW)
    oCltBKW := nil
Return

Method factGerador(cTipoLote) Class CenGerXTE
    Local oGerador := nil

    If cTipoLote == GUIMON 
        oGerador := CenExMoGui():New()
    ElseIf cTipoLote == GUIFOR 
        oGerador := CenExMoFOr():New()
    ElseIf cTipoLote == GUIOUT 
        oGerador := CenExMoRem():New()
    ElseIf cTipoLote == GUIPRE 
        oGerador := CenExMoPre():New()
    EndIf

Return oGerador

Method factClRem(cForRem) Class CenGerXTE

    Local oClt:=nil 

    If cForRem == GUIMON
        oClt := CenCltBKR():New()
  //    oClt:setValue("operatorRecord"  ,self:cCodOpe) 
    elseif  cForRem == GUIFOR
        oClt := CenCltBVQ():New()
    elseif  cForRem == GUIOUT
        oClt := CenCltBVZ():New()
    elseif  cForRem == GUIPRE
        oClt := CenCltB9T():New()
    endIf

Return oClt