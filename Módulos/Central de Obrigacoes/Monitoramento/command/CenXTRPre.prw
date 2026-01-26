#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

#define MONTISSTAB "38"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenXTRPre
    Classe para a importacao dos arquivos XTR operadoraParaANS de Valor Preestabelecido

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenXTRPre From CenMonXTR

	Method New() Constructor
    Method procFile()
    Method errVlrPre(cPathTag,nPosCrit)
   
EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenXTRPre

    _Super:new()
    self:cFileExten := ".xtr"
    self:cFolder    := "\monitoramento\xtr\"
    self:oCltAtuReg := CenCltB9T():New()

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procFile
    Processa um arquivo XTE de Valor Preestabelecido

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procFile() Class CenXTRPre

    Local nGuia      := 0
    Local nCountReg  := 0
    Local nTagsGuia  := 0
    Local nPosCrit   := 0
    Local cPathTag   := ""
 
    cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados"
    nCountReg := self:oXML:XPathChildCount(cPathTag)

    for nGuia := 1 to nCountReg

        cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados/ans:valorPreestabelecidoMonitoramento"
        if nCountReg > 1
            cPathTag += "["+cValtoChar(nGuia)+"]"
        endIf
        nTagsGuia := self:oXML:XPathChildCount( cPathTag )
        
        oCltB9T := CenCltB9T():New()
        oCltB9T:setValue("operatorRecord",self:cCodOpe)
        oCltB9T:setValue("cnes",self:oXML:XPathGetNodeValue( cPathTag +"/ans:dadosContratadoExecutante/ans:CNES"))
        oCltB9T:setValue("providerCpfCnpj",self:oXML:XPathGetNodeValue( cPathTag +"/ans:dadosContratadoExecutante/ans:codigoCNPJ_CPF"))
        oCltB9T:setValue("cityOfProvider",self:oXML:XPathGetNodeValue( cPathTag +"/ans:dadosContratadoExecutante/ans:municipioExecutante"))
        oCltB9T:setValue("ansRecordNumber",self:oXML:XPathGetNodeValue( cPathTag +"/ans:registroANSOperadoraIntermediaria"))
        oCltB9T:setValue("presetValueIdent",self:oXML:XPathGetNodeValue( cPathTag +"/ans:identificacaoValorPreestabelecido"))
        oCltB9T:setValue("periodCover",self:oXML:XPathGetNodeValue( cPathTag +"/ans:competenciaCoberturaContratada"))
        oCltB9T:setValue("requirementCode",self:cCodObrig)
        oCltB9T:setValue("referenceYear",self:cAno)
        oCltB9T:setValue("commitmentCode",self:cMes)
        oCltB9T:setValue("batchCode",self:cLote)
        
        if oCltB9T:bscChaPrim()
            oCltB9T:mapFromDao()
        
            for nPosCrit := 1 to nTagsGuia
                self:errVlrPre(cPathTag,nPosCrit)
            next
            oCltB9T:setValue("status","5")
            oCltB9T:update()
        endIf      
        oCltB9T:destroy()
    next
    
return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} errVlrPre
    Processa os erros de um registro de Valor Preestabelecido

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method errVlrPre(cPathTag,nPosCrit) Class CenXTRPre

    Local cIdCampo  := ""
    Local cCodErro  := ""
    Local cPathCrit := cPathTag + "/ans:errosValorPreestabelecido" 

    if nPosCrit == 1 .And. self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
        lFind := .T.
    else
        cPathCrit  := cPathTag + "/ans:errosValorPreestabelecido["+ cValtoChar(nPosCrit)  +"]"
        lFind := self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
    endIf

    if lFind
        cIdCampo := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identificadorCampo")
        cCodErro := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:codigoErro")

        oCritica :=  CriticaB3F():New()
        oCritica:setTpVld("3")
        oCritica:setAlias("B9T")
        oCritica:setChaveOri(B9T->(B9T_CODOPE+B9T_CNES+B9T_CPFCNP+B9T_CDMNPR+B9T_RGOPIN+B9T_IDVLRP+B9T_COMCOB+B9T_CDOBRI+B9T_ANO+B9T_CDCOMP+B9T_LOTE))
        oCritica:setCodANS(cCodErro)
        oCritica:setDesOri(self:cLote)
        oCritica:setMsgCrit(self:oHmTissTer:getTermDesc(MONTISSTAB,cCodErro))
      
        self:grvCritica(oCritica,cIdCampo)

    endIf

Return
