#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

#define MONTISSTAB "38"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenXTRRem
    Classe para a importacao dos arquivos XTR operadoraParaANS de Outra Remuneracao

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenXTRRem From CenMonXTR
	Method New() Constructor
    Method procFile()
    Method errOutRem(cPathTag,nPosCrit)
EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenXTRRem

    _Super:new()
    self:cFileExten := ".xtr"
    self:cFolder    := "\monitoramento\xtr\"
    self:oCltAtuReg := CenCltBVZ():New()

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procFile
    Processa um arquivo XTE de Outra Remuneracao

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procFile() Class CenXTRRem

    Local nGuia      := 0
    Local nCountReg  := 0
    Local nTagsGuia  := 0
    Local nPosCrit   := 0
    Local cPathTag   := ""
 
    cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados"
    nCountReg := self:oXML:XPathChildCount(cPathTag)

    for nGuia := 1 to nCountReg

        cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados/ans:outraRemuneracaoMonitoramento"
        if nCountReg > 1
            cPathTag += "["+cValtoChar(nGuia)+"]"
        endIf
        nTagsGuia := self:oXML:XPathChildCount( cPathTag )

        oCltBVZ := CenCltBVZ():New()
        oCltBVZ:setValue("operatorRecord",self:cCodOpe)
        oCltBVZ:setValue("providerCpfCnpj",self:oXML:XPathGetNodeValue( cPathTag +"/ans:dadosRecebedor/ans:codigoCNPJ_CPF"))
        oCltBVZ:setValue("requirementCode",self:cCodObrig)
        oCltBVZ:setValue("referenceYear",self:cAno)
        oCltBVZ:setValue("commitmentCode",self:cMes)
        oCltBVZ:setValue("batchCode",self:cLote)
        oCltBVZ:setValue("formProcDt",StrTran(self:oXML:XPathGetNodeValue( cPathTag +"/ans:dataProcessamento"),"-",""))

        if oCltBVZ:bscChaPrim()
            oCltBVZ:mapFromDao()
        
            for nPosCrit := 1 to nTagsGuia
                self:errOutRem(cPathTag,nPosCrit)
            next
            oCltBVZ:setValue("status","5")
            oCltBVZ:update()
        endIf      
        oCltBVZ:destroy()
    next
    
return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} errOutRem
    Processa os erros de um registro de Outra Remuneracao

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method errOutRem(cPathTag,nPosCrit) Class CenXTRRem

    Local cIdCampo  := ""
    Local cCodErro  := ""
    Local cPathCrit := cPathTag + "/ans:errosOutraRemuneracao" 

    if nPosCrit == 1 .And. self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
        lFind := .T.
    else
        cPathCrit  := cPathTag + "/ans:errosOutraRemuneracao["+ cValtoChar(nPosCrit)  +"]"
        lFind := self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
    endIf

    if lFind
        cIdCampo := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identificadorCampo")
        cCodErro := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:codigoErro")

        oCritica :=  CriticaB3F():New()
        oCritica:setTpVld("3")
        oCritica:setAlias("BVZ")
        oCritica:setChaveOri(BVZ->(BVZ_CODOPE+BVZ_CPFCNP+BVZ_CDOBRI+BVZ_ANO+BVZ_CDCOMP+BVZ_LOTE+Dtos(BVZ_DTPROC)))
        oCritica:setCodANS(cCodErro)
        oCritica:setDesOri(self:cLote)
        oCritica:setMsgCrit(self:oHmTissTer:getTermDesc(MONTISSTAB,cCodErro))
      
        self:grvCritica(oCritica,cIdCampo)

    endIf

Return
