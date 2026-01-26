#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

#define MONTISSTAB "38"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenXTRFor
    Classe para a importacao dos arquivos XTR operadoraParaANS de Fornecimento Direto

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenXTRFor From CenMonXTR

	Method New() Constructor
    Method procFile()
    Method errosGuia(cPathTag,nPosCrit)
    Method procItens(cPathTag,nPosCrit)
    Method errosItens(cPathTag,nPosCrit)
 
EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenXTRFor

    _Super:new()
    self:cFileExten := ".xtr"
    self:cFolder    := "\monitoramento\xtr\"
    self:oCltAtuReg := CenCltBVQ():New()
    
return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procFile
    Processa um arquivo XTE de Fornecimento Direto

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procFile() Class CenXTRFor

    Local nGuia      := 0
    Local nCountReg  := 0
    Local nTagsGuia  := 0
    Local nPosCrit   := 0
    Local cPathTag   := ""

    cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados"
    nCountReg := self:oXML:XPathChildCount(cPathTag) //Verifico a quantidade de guias	

    for nGuia := 1 to nCountReg

        cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados/ans:fornecimentoDiretoMonitoramento"
        if nCountReg > 1
            cPathTag += "["+cValtoChar(nGuia)+"]"
        endIf
        nTagsGuia := self:oXML:XPathChildCount( cPathTag )

        oCltBVQ := CenCltBVQ():New()
        oCltBVQ:setValue("operatorRecord",self:cCodOpe)
        oCltBVQ:setValue("providerFormNumber",self:oXML:XPathGetNodeValue( cPathTag +"/ans:identificacaoFornecimentoDireto"))
        oCltBVQ:setValue("requirementCode",self:cCodObrig)
        oCltBVQ:setValue("referenceYear",self:cAno)
        oCltBVQ:setValue("commitmentCode",self:cMes)
        oCltBVQ:setValue("batchCode",self:cLote)
        oCltBVQ:setValue("formProcDt",StrTran(self:oXML:XPathGetNodeValue( cPathTag +"/ans:dataFornecimento"),"-",""))

        if oCltBVQ:bscChaPrim()
            oCltBVQ:mapFromDao()
        
            for nPosCrit := 1 to nTagsGuia
                self:errosGuia(cPathTag,nPosCrit)
                self:procItens(cPathTag,nPosCrit)         
            next
            oCltBVQ:setValue("status","5")
            oCltBVQ:update()
        endIf      
        oCltBVQ:destroy()
    next
    
return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} errosGuia
    Processa um arquivo XTE de Fornecimento Direto

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method errosGuia(cPathTag,nPosCrit) Class CenXTRFor

    Local cIdCampo  := ""
    Local cCodErro  := ""
    Local cPathCrit := cPathTag + "/ans:errosFornecimentoDireto"

    if nPosCrit == 1 .And. self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
        lFind := .T.
    else
        cPathCrit  := cPathTag + "/ans:errosFornecimentoDireto["+ cValtoChar(nPosCrit)  +"]"
        lFind := self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
    endIf

    if lFind
        cIdCampo := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identificadorCampo")
        cCodErro := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:codigoErro")

        oCritica :=  CriticaB3F():New()
        oCritica:setTpVld("3")
        oCritica:setAlias("BVQ")
        oCritica:setChaveOri(BVQ->(BVQ_CODOPE+BVQ_NMGPRE+BVQ_CDOBRI+BVQ_ANO+BVQ_CDCOMP+BVQ_LOTE+Dtos(BVQ_DTPRGU)))
        oCritica:setCodANS(cCodErro)
        oCritica:setDesOri(self:cLote)
        oCritica:setMsgCrit(self:oHmTissTer:getTermDesc(MONTISSTAB,cCodErro))
      
        self:grvCritica(oCritica,cIdCampo)

    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procItens
    Processa um arquivo XTE de Fornecimento Direto

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procItens(cPathTag,nPosCrit) Class CenXTRFor

    Local nX         := 0
    Local cPathCrit  := cPathTag + "/ans:errosItensFornecimentoDireto"
    Local nContCri   := self:oXML:XPathChildCount(cPathCrit)  
    Local cCodTab    := ""
    Local cCodGru    := ""
    Local cCodPro    := ""
     
    if nPosCrit == 1 .And. self:oXml:XPathHasNode(cPathCrit+"/ans:identProcedimento/ans:codigoTabela")
        lFind := .T.
    else
        cPathCrit  := cPathTag + "/ans:errosItensFornecimentoDireto["+cValtoChar(nPosCrit)+"]"
        lFind :=  self:oXml:XPathHasNode(cPathCrit+"/ans:identProcedimento/ans:codigoTabela")
    endIf

    if lFind
        cCodTab    := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identProcedimento/ans:codigoTabela")
        cCodGru    := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identProcedimento/ans:Procedimento/ans:grupoProcedimento")
        cCodPro    := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identProcedimento/ans:Procedimento/ans:codigoProcedimento")
      
        oCltBVT := CenCltBVT():New()
        oCltBVT:setValue("operatorRecord",self:cCodOpe)
        oCltBVT:setValue("providerFormNumber",self:oXML:XPathGetNodeValue( cPathTag +"/ans:identificacaoFornecimentoDireto"))
        oCltBVT:setValue("requirementCode",self:cCodObrig)
        oCltBVT:setValue("referenceYear",self:cAno)
        oCltBVT:setValue("commitmentCode",self:cMes)
        oCltBVT:setValue("batchCode",self:cLote)
        oCltBVT:setValue("formProcDt",StrTran(self:oXML:XPathGetNodeValue( cPathTag +"/ans:dataFornecimento"),"-",""))
        oCltBVT:setValue("procedureGroup",cCodGru)
        oCltBVT:setValue("tableCode",cCodTab)
        oCltBVT:setValue("procedureCode",cCodPro)
      
        if oCltBVT:bscChaPrim()
            oCltBVT:mapFromDao()
            for nX := 1 to nContCri
                self:errosItens(cPathCrit,nX)
            next
        endIf
        oCltBVT:destroy()
       
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} errosItens
    Processa os erros de uma guia de Fornecimento Direto

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method errosItens(cPathTag,nPosCrit) Class CenXTRFor

    Local cIdCampo  := ""
    Local cCodErro  := ""
    Local cPathCrit := cPathTag + "/ans:relacaoErros"
    Local lFind     := .F.

    if nPosCrit == 1 .And. self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
        lFind := .T.
    else
        cPathCrit  := cPathTag + "/ans:relacaoErros["+ cValtoChar(nPosCrit)+"]"
        iif (self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo"),lFind := .T.,lFind := .F.)
    endIf

    if lFind
        cIdCampo := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identificadorCampo")
        cCodErro := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:codigoErro")

        oCritica :=  CriticaB3F():New()
        oCritica:setTpVld("3")
        oCritica:setAlias("BVT")
        oCritica:setChaveOri(BVT->(BVT_CODOPE+BVT_NMGPRE+BVT_CDOBRI+BVT_ANO+BVT_CDCOMP+BVT_LOTE+Dtos(BVT_DTPRGU)+BVT_CODTAB+BVT_CODGRU+BVT_CODPRO))
        oCritica:setCodANS(cCodErro)
        oCritica:setDesOri(self:cLote)
        oCritica:setMsgCrit(self:oHmTissTer:getTermDesc(MONTISSTAB,cCodErro))
      
        self:grvCritica(oCritica,cIdCampo)
        
    endIf

Return
