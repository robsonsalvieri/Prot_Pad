#include "TOTVS.CH"
#include 'FWMVCDEF.CH'
#define MSGCAB 'mensagemEnvioANS'
#define HEADER 'cabecalho'
#define BODY   'Mensagem'
#define OPEANS 'operadoraParaANS'
#define GUIMON 'guiaMonitoramento'
#define GUIEVE 'procedimentos'
#define GUIPAC 'detalhePacote'
#define NAME 1
#define NODE 2
#define QTDFLUSH 20

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenExMoGui
    Classe para a geracao dos arquivos XTE operadoraParaANS do Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenExMoGui From CenExpoMon

	Method New() Constructor
    Method procRegist(oXml,oGuia,cSeqGui)
    Method procEveGui(oXml,oEvento,cSeqGui,cSeqIte,cTipGui)
    Method procPacGui(oXml,oPacote,cSeqGui,cSeqIte,cSeqPac)

EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenExMoGui

    _Super:new()
    self:oCltAlias := CenCltBKR():New()

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procRegist
    Processa uma guia ao gerar o arquivo Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procRegist(oXml,oGuia,cSeqGui) Class CenExMoGui

    Local nContIte  := 0
    Local cNodeAux  := ""
    Local cNodeAux2 := ""
    Local oCltBKS   := CenCltBKS():New()

    Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	:= nil

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):addNode(GUIMON+cSeqGui,GUIMON)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("tipoRegistro"):setValue(oGuia:getValue("monitoringRecordType"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("versaoTISSPrestador"):setValue(self:getVerTiss(oGuia:getValue("tissProviderVersion") ) ):setObrig(.F.)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("formaEnvio"):setValue(oGuia:getValue("submissionMethod"))

    //Node dadosContratadoExecutante
    cNodeAux := "dadosContratadoExecutante"
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode(cNodeAux)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("CNES"):setValue(oGuia:getValue("cnes"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("identificadorExecutante"):setValue(oGuia:getValue("executerId"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("codigoCNPJ_CPF"):setValue(oGuia:getValue("providerCpfCnpj"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("municipioExecutante"):setValue(oGuia:getValue("executingCityCode"))

    if !Empty(oGuia:getValue("ansRecordNumber"))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("registroANSOperadoraIntermediaria"):setValue(oGuia:getValue("ansRecordNumber")):setObrig(.F.)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("tipoAtendimentoOperadoraIntermediaria"):setValue("1"):setObrig(.F.)
    endIf

    //Node dadosBeneficiario
    cNodeAux  := "dadosBeneficiario"
    cNodeAux2 := "identBeneficiario"

	oDaoBenef:setMatric(oGuia:getValue("registration"))
	oDaoBenef:setCodOpe(oGuia:getValue("operatorRecord"))
    oBscBenef:buscar()

	if oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode(cNodeAux)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode(cNodeAux2)
        If !Empty(oBenef:getCns())
            oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):addNode("numeroCartaoNacionalSaude"):setValue(oBenef:getCns())
        EndIf
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):addNode("sexo"):setValue(oBenef:getSexo())
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):addNode("dataNascimento"):setValue(self:maskDate(Dtos(oBenef:getDatNas())))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):addNode("municipioResidencia"):setValue(oBenef:getCodMun())
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("numeroRegistroPlano"):setValue(oBenef:getSusep())
        oBenef:destroy()
        FreeObj(oBenef)
        oBenef := nil
    endIf

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("tipoEventoAtencao"):setValue(oGuia:getValue("aEventType"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("origemEventoAtencao"):setValue(oGuia:getValue("eventOrigin"))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("numeroGuia_prestador"):setValue(oGuia:getValue("providerFormNumber"))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("numeroGuia_operadora"):setValue(oGuia:getValue("operatorFormNumber"))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("identificacaoReembolso"):setValue( IIf(Empty(oGuia:getValue("refundId")),"0", oGuia:getValue("refundId")) ) 
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("identificacaoValorPreestabelecido"):setValue(oGuia:getValue("presetValueIdent")):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("guiaSolicitacaoInternacao"):setValue(oGuia:getValue("hospitalizationRequest")):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("dataSolicitacao"):setValue(self:maskDate(oGuia:getValue("requestDate"))):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("numeroGuiaSPSADTPrincipal"):setValue(oGuia:getValue("mainFormNumb")):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("dataAutorizacao"):setValue(self:maskDate(oGuia:getValue("authorizationDate"))):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("dataRealizacao"):setValue(self:maskDate(oGuia:getValue("executionDate")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("dataInicialFaturamento"):setValue(self:maskDate(oGuia:getValue("invoicingStartDate"))):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("dataFimPeriodo"):setValue(self:maskDate(oGuia:getValue("invoicingEndDate"))):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("dataProtocoloCobranca"):setValue(self:maskDate(oGuia:getValue("collectionProtocolDate")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("dataPagamento"):setValue(self:maskDate(oGuia:getValue("paymentDt"))):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("dataProcessamentoGuia"):setValue(self:maskDate(oGuia:getValue("formProcDt")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("tipoConsulta"):setValue(oGuia:getValue("appointmentType")):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("cboExecutante"):setValue(oGuia:getValue("cboSCode")):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("indicacaoRecemNato"):setValue(oGuia:getValue("newborn")):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("indicacaoAcidente"):setValue(oGuia:getValue("indicAccident")):setObrig(.F.)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("caraterAtendimento"):setValue(oGuia:getValue("admissionType")):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("tipoInternacao"):setValue(oGuia:getValue("hospTp")):setObrig(.F.)
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("regimeInternacao"):setValue(oGuia:getValue("hospRegime")):setObrig(.F.)

    //Node CID
    if !Empty(oGuia:getValue("icdDiagnosis1")) .Or. ;
       !Empty(oGuia:getValue("icdDiagnosis2")) .Or. ;
       !Empty(oGuia:getValue("icdDiagnosis3")) .Or. ;
       !Empty(oGuia:getValue("icdDiagnosis4")) 

        cNodeAux  := "diagnosticosCID10"
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode(cNodeAux):setObrig(.F.)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("diagnosticoCID"):setValue(oGuia:getValue("icdDiagnosis1")):setObrig(.F.)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("diagnosticoCID"):setValue(oGuia:getValue("icdDiagnosis2")):setObrig(.F.)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("diagnosticoCID"):setValue(oGuia:getValue("icdDiagnosis3")):setObrig(.F.)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("diagnosticoCID"):setValue(oGuia:getValue("icdDiagnosis4")):setObrig(.F.)

    endif
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("tipoAtendimento"):setValue(oGuia:getValue("serviceType")):setObrig(.F.)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("tipoFaturamento"):setValue(oGuia:getValue("invoicingTp")):setObrig(.F.)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("diariasAcompanhante"):setValue(oGuia:getValue("escortDailyRates")):setObrig(.F.)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("diariasUTI"):setValue(oGuia:getValue("icuDailyRates")):setObrig(.F.)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("motivoSaida"):setValue(oGuia:getValue("outflowType")):setObrig(.F.)

    //Node valoresGuia
    cNodeAux  := "valoresGuia"
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode(cNodeAux)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalInformado"):setValue(self:maskValue(oGuia:getValue("totalValueEntered")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorProcessado"):setValue(self:maskValue(oGuia:getValue("valueProcessed")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalPagoProcedimentos"):setValue(self:maskValue(oGuia:getValue("procedureTotalValuePai")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalDiarias"):setValue(self:maskValue(oGuia:getValue("dailyRatesTotalValue")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalTaxas"):setValue(self:maskValue(oGuia:getValue("feesTotalValue")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalMateriais"):setValue(self:maskValue(oGuia:getValue("materialsTotalValue")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalOPME"):setValue(self:maskValue(oGuia:getValue("totalOpmeValue")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalMedicamentos"):setValue(self:maskValue(oGuia:getValue("medicationTotalValue")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorGlosaGuia"):setValue(self:maskValue(oGuia:getValue("formDisallowanceValue")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorPagoGuia"):setValue(self:maskValue(oGuia:getValue("valuePaidForm")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorPagoFornecedores"):setValue(self:maskValue(oGuia:getValue("valuePaidSuppliers")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalTabelaPropria"):setValue(self:maskValue(oGuia:getValue("ownTableTotalValue")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(cNodeAux):addNode("valorTotalCoParticipacao"):setValue(self:maskValue(oGuia:getValue("coPaymentTotalValue")))

    //Node Declaracao de Nascidos/Obitos
    oCltBN0   := CenCltBN0():New()
    oCltBN0:setValue("operatorRecord"    ,oGuia:getValue("operatorRecord")) 
    oCltBN0:setValue("operatorFormNumber",oGuia:getValue("operatorFormNumber"))
    oCltBN0:setValue("requirementCode"   ,oGuia:getValue("requirementCode"))
    oCltBN0:setValue("referenceYear"     ,oGuia:getValue("referenceYear"))
    oCltBN0:setValue("commitmentCode"    ,oGuia:getValue("commitmentCode"))
    oCltBN0:setValue("batchCode"         ,oGuia:getValue("batchCode"))
    oCltBN0:setValue("formProcDt"        ,oGuia:getValue("formProcDt"))

    if oCltBN0:bscCertXML()
        while oCltBN0:HasNext()
            oDeclar := oCltBN0:GetNext()
            if oDeclar:getValue("certificateType") == "1"
                oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("declaracaoNascido"):setValue(oDeclar:getValue("certificateNumber")):setObrig(.F.)
            else    
                oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode("declaracaoObito"):setValue(oDeclar:getValue("certificateNumber")):setObrig(.F.)
            endIf

            oDeclar:destroy()
            FreeObj(oDeclar)
            oDeclar := nil

        endDo
    endIf

    oCltBN0:destroy()
    FreeObj(oCltBN0)
    oCltBN0 := nil
  
    //Node procedimentos
    oCltBKS:setValue("operatorRecord"    ,oGuia:getValue("operatorRecord")) 
    oCltBKS:setValue("operatorFormNumber",oGuia:getValue("operatorFormNumber"))
    oCltBKS:setValue("requirementCode"   ,oGuia:getValue("requirementCode"))
    oCltBKS:setValue("referenceYear"     ,oGuia:getValue("referenceYear"))
    oCltBKS:setValue("commitmentCode"    ,oGuia:getValue("commitmentCode"))
    oCltBKS:setValue("batchCode"         ,oGuia:getValue("batchCode"))
    oCltBKS:setValue("formProcDt"        ,oGuia:getValue("formProcDt"))

    if oCltBKS:buscar()
        while oCltBKS:HasNext()
            nContIte++
            oEvento := oCltBKS:GetNext()
            self:procEveGui(oXml,oEvento,cSeqGui,cValtoChar(nContIte),oGuia:getValue("aEventType"))

            oEvento:destroy()
            FreeObj(oEvento)
            oEvento := nil
        endDo
    endIf

    oCltBKS:destroy()
    FreeObj(oCltBKS)
    oCltBKS := nil
    
Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procEveGui
    Processa um evento ao gerar o arquivo Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procEveGui(oXml,oEvento,cSeqGui,cSeqIte,cTipGui) Class CenExMoGui

    Local nContPac  := 0
    Local cNodeAux  := ""
    Local cNodeAux2 := ""
    Default cTipGui := ""

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):addNode(GUIEVE+cSeqIte,GUIEVE)

    //Node identProcedimento 
    cNodeAux  := "identProcedimento"
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode(cNodeAux)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(cNodeAux):addNode("codigoTabela"):setValue(oEvento:getValue("tableCode"))
    
    //Node Procedimento
    cNodeAux2 := "Procedimento"
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(cNodeAux):addNode(cNodeAux2)
    if !empty(oEvento:getValue("procedureGroup"))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(cNodeAux):getNode(cNodeAux2):addNode("grupoProcedimento"):setValue(oEvento:getValue("procedureGroup"))
    else
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(cNodeAux):getNode(cNodeAux2):addNode("codigoProcedimento"):setValue(oEvento:getValue("procedureCode"))
    endIf

    //Node denteRegiao
    if !Empty(oEvento:getValue("toothCode"))
        cNodeAux  := "denteRegiao"
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode(cNodeAux):setObrig(.F.)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(cNodeAux):addNode("codDente"):setValue(oEvento:getValue("toothCode"))
    elseIf !Empty(oEvento:getValue("regionCode"))
        cNodeAux  := "denteRegiao"
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode(cNodeAux)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(cNodeAux):addNode("codRegiao"):setValue(oEvento:getValue("regionCode"))
    endif

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode("denteFace"):setValue(oEvento:getValue("toothFaceCode")):setObrig(.F.)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode("quantidadeInformada"):setValue(self:maskValue(oEvento:getValue("enteredQuantity")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode("valorInformado"):setValue(self:maskValue(oEvento:getValue("valueEntered")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode("quantidadePaga"):setValue(self:maskValue(oEvento:getValue("quantityPaid")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode("valorPagoProc"):setValue(self:maskValue(oEvento:getValue("procedureValuePaid")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode("valorPagoFornecedor"):setValue(self:maskValue(oEvento:getValue("valuePaidSupplier")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode("CNPJFornecedor"):setValue(oEvento:getValue("supplierCnpj")):setObrig(.F.)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode("valorCoParticipacao"):setValue(IIF(alltrim(cTipGui) == "3","0",self:maskValue(oEvento:getValue("coPaymentValue"))))

    //Node detalhePacote
    if oEvento:getValue("package") == "1"

        oCltBKT   := CenCltBKT():New()
        oCltBKT:setValue("operatorRecord"    ,oEvento:getValue("operatorRecord")) 
        oCltBKT:setValue("operatorFormNumber",oEvento:getValue("operatorFormNumber"))
        oCltBKT:setValue("requirementCode"   ,oEvento:getValue("requirementCode"))
        oCltBKT:setValue("referenceYear"     ,oEvento:getValue("referenceYear"))
        oCltBKT:setValue("commitmentCode"    ,oEvento:getValue("commitmentCode"))
        oCltBKT:setValue("batchCode"         ,oEvento:getValue("batchCode"))
        oCltBKT:setValue("formProcDt"        ,oEvento:getValue("formProcDt"))
        oCltBKT:setValue("tableCode"         ,oEvento:getValue("tableCode"))
        oCltBKT:setValue("procedureCode"     ,oEvento:getValue("procedureCode"))
        nContPac := 0

        if oCltBKT:buscar()
            while oCltBKT:HasNext()
                oPacote := oCltBKT:GetNext()
                nContPac++
                self:procPacGui(oXml,oPacote,cSeqGui,cSeqIte,cValtoChar(nContPac))
                oPacote:destroy()
                FreeObj(oPacote)
                oPacote := nil
            endDo
        endIf
        oCltBKT:destroy()
        FreeObj(oCltBKT)
        oCltBKT := nil
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procPacGui
    Processa um pacote ao gerar o arquivo Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procPacGui(oXml,oPacote,cSeqGui,cSeqIte,cSeqPac) Class CenExMoGui

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):addNode(GUIPAC+cSeqPac,GUIPAC)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(GUIPAC+cSeqPac):addNode("codigoTabela"):setValue(oPacote:getValue("itemTableCode"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(GUIPAC+cSeqPac):addNode("codigoProcedimento"):setValue(oPacote:getValue("itemProCode"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(GUIMON+cSeqGui):getNode(GUIEVE+cSeqIte):getNode(GUIPAC+cSeqPac):addNode("quantidade"):setValue(self:maskValue(oPacote:getValue("packageQuantity")))
    
Return