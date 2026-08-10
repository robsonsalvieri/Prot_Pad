#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

#define MONTISSTAB "38"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenXTRGui
    Classe para a importacao dos arquivos XTR operadoraParaANS de Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenXTRGui From CenMonXTR

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
Method New() Class CenXTRGui

    _Super:new()
    self:cFileExten := ".xtr"
    self:cFolder    := "\monitoramento\xtr\"
    self:oCltAtuReg := CenCltBKR():New()
return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procFile
    Processa um arquivo XTE de Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procFile() Class CenXTRGui

    Local nGuia      := 0
    Local nCountReg  := 0
    Local nTagsGuia  := 0
    Local nPosCrit   := 0
    Local cPathTag   := ""

    //Tratamento Guias
    cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados"
    nCountReg := self:oXML:XPathChildCount(cPathTag) //Verifico a quantidade de guias	

    for nGuia := 1 to nCountReg //For de Guias

        cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados/ans:guiaMonitoramento"
        if nCountReg > 1
            cPathTag += "["+cValtoChar(nGuia)+"]"
        endIf
        nTagsGuia := self:oXML:XPathChildCount( cPathTag )

        oCltBKR := CenCltBKR():New()
        oCltBKR:setValue("operatorRecord",self:cCodOpe)
        oCltBKR:setValue("operatorFormNumber",self:oXML:XPathGetNodeValue( cPathTag +"/ans:numeroGuiaOperadora"))
        oCltBKR:setValue("requirementCode",self:cCodObrig)
        oCltBKR:setValue("referenceYear",self:cAno)
        oCltBKR:setValue("commitmentCode",self:cMes)
        oCltBKR:setValue("batchCode",self:cLote)
        oCltBKR:setValue("formProcDt",StrTran(self:oXML:XPathGetNodeValue( cPathTag +"/ans:dataProcessamento"),"-",""))

        if oCltBKR:bscChaPrim()
            oCltBKR:mapFromDao()
        
            for nPosCrit := 1 to nTagsGuia
                self:errosGuia(cPathTag,nPosCrit)
                self:procItens(cPathTag,nPosCrit)         
            next
            oCltBKR:setValue("status","5")
            oCltBKR:update()
        endIf      
        oCltBKR:destroy()
    next
    
return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} errosGuia
    Processa um arquivo XTE de Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method errosGuia(cPathTag,nPosCrit) Class CenXTRGui

    Local cIdCampo  := ""
    Local cCodErro  := ""
    Local cPathCrit := cPathTag + "/ans:errosGuia" 

    if nPosCrit == 1 .And. self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
        lFind := .T.
    else
        cPathCrit  := cPathTag + "/ans:errosGuia["+ cValtoChar(nPosCrit)  +"]"
        lFind := self:oXml:XPathHasNode(cPathCrit+"/ans:identificadorCampo")
    endIf

    if lFind
        cIdCampo := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identificadorCampo")
        cCodErro := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:codigoErro")

        oCritica :=  CriticaB3F():New()
        oCritica:setTpVld("3")
        oCritica:setAlias("BKR")
        oCritica:setChaveOri(BKR->(BKR_CODOPE+BKR_NMGOPE+BKR_CDOBRI+BKR_ANO+BKR_CDCOMP+BKR_LOTE+Dtos(BKR_DTPRGU)))
        oCritica:setCodANS(cCodErro)
        oCritica:setDesOri(self:cLote)
        oCritica:setMsgCrit(self:oHmTissTer:getTermDesc(MONTISSTAB,cCodErro))
      
        self:grvCritica(oCritica,cIdCampo)

    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procItens
    Processa um arquivo XTE de Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procItens(cPathTag,nPosCrit) Class CenXTRGui

    Local nX         := 0
    Local cPathCrit  := cPathTag + "/ans:errosItensGuia"
    Local nContCri   := self:oXML:XPathChildCount(cPathCrit)  
    Local cCodTab    := ""
    Local cCodGru    := ""
    Local cCodPro    := ""
    Local cCodDente  := ""
    Local cCodRegiao := ""
    Local cDenteFace := ""
  
    if nPosCrit == 1 .And. self:oXml:XPathHasNode(cPathCrit+"/ans:identProcedimento/ans:codigoTabela")
        lFind := .T.
    else
        cPathCrit  := cPathTag + "/ans:errosItensGuia["+cValtoChar(nPosCrit)+"]"  //Verifica se tem varias tags errosGuia
        lFind :=  self:oXml:XPathHasNode(cPathCrit+"/ans:identProcedimento/ans:codigoTabela")
    endIf

    if lFind
        cCodTab    := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identProcedimento/ans:codigoTabela")
        cCodGru    := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identProcedimento/ans:Procedimento/ans:grupoProcedimento")
        cCodPro    := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:identProcedimento/ans:Procedimento/ans:codigoProcedimento")
        cCodDente  := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:denteRegiao/ans:codDente")
        cCodRegiao := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:denteRegiao/ans:codRegiao")
        cDenteFace := self:oXML:XPathGetNodeValue( cPathCrit +"/ans:denteFace")
     
        oCltBKS := CenCltBKS():New()
        oCltBKS:setValue("operatorRecord",self:cCodOpe)
        oCltBKS:setValue("operatorFormNumber",self:oXML:XPathGetNodeValue( cPathTag +"/ans:numeroGuiaOperadora"))
        oCltBKS:setValue("requirementCode",self:cCodObrig)
        oCltBKS:setValue("referenceYear",self:cAno)
        oCltBKS:setValue("commitmentCode",self:cMes)
        oCltBKS:setValue("batchCode",self:cLote)
        oCltBKS:setValue("formProcDt",StrTran(self:oXML:XPathGetNodeValue( cPathTag +"/ans:dataProcessamento"),"-",""))
        oCltBKS:setValue("procedureGroup",cCodGru)
        oCltBKS:setValue("tableCode",cCodTab)
        oCltBKS:setValue("procedureCode",cCodPro)
        oCltBKS:setValue("toothCode",cCodDente)
        oCltBKS:setValue("regionCode",cCodRegiao)
        oCltBKS:setValue("toothFaceCode",cDenteFace)

        if oCltBKS:bscChaPrim()
            oCltBKS:mapFromDao()
            for nX := 1 to nContCri
                self:errosItens(cPathCrit,nX)
            next
        endIf
        oCltBKS:destroy()
       
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} errosItens
    Processa um arquivo XTE de Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method errosItens(cPathTag,nPosCrit) Class CenXTRGui

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
        oCritica:setAlias("BKS")
        oCritica:setChaveOri(BKS->(BKS_CODOPE+BKS_NMGOPE+BKS_CDOBRI+BKS_ANO+BKS_CDCOMP+BKS_LOTE+Dtos(BKS_DTPRGU)+BKS_CODGRU+BKS_CODTAB+BKS_CODPRO+BKS_CDDENT+BKS_CDREGI+BKS_CDFACE))
        oCritica:setCodANS(cCodErro)
        oCritica:setDesOri(self:cLote,cIdCampo)
        oCritica:setMsgCrit(self:oHmTissTer:getTermDesc(MONTISSTAB,cCodErro))
      
        self:grvCritica(oCritica,cIdCampo)
        
    endIf

Return
