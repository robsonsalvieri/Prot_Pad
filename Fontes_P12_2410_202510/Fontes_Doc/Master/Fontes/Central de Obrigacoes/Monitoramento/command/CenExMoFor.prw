#include "TOTVS.CH"
#include 'FWMVCDEF.CH'
#define MSGCAB 'mensagemEnvioANS'
#define HEADER 'cabecalho'
#define BODY   'Mensagem'
#define OPEANS 'operadoraParaANS'
#define FORDIR 'fornecimentoDiretoMonitoramento'
#define FOREVE 'procedimentos'
#define QTDFLUSH 20

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenExMoFor
    Classe para a geracao dos arquivos XTE operadoraParaANS do Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenExMoFor From CenExpoMon

    Method New() Constructor
    Method procRegist(oXml,oGuia,cSeqGui)
    Method procEveFor(oXml,oEvento,cSeqGui,cSeqIte)
   
EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenExMoFor

    _Super:new()
    self:oCltAlias := CenCltBVQ():New()

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procRegist
    Processa uma guia ao gerar o arquivo Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procRegist(oXml,oGuia,cSeqGui) Class CenExMoFor

    Local nContIte  := 0
    Local cNodeAux  := ""
    Local cNodeAux2 := ""
    Local cNodeAux3 := ""
    Local oCltBVT   := CenCltBVT():New()

    Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	:= nil

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):addNode(FORDIR+cSeqGui,FORDIR)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):addNode("tipoRegistro"):setValue(oGuia:getValue("monitoringRecordType"))
    
    //Node dadosBeneficiario
    cNodeAux  := "dadosBeneficiario"
    cNodeAux2 := "identBeneficiario"
	oDaoBenef:setMatric(oGuia:getValue("registration"))
	oDaoBenef:setCodOpe(oGuia:getValue("operatorRecord"))
    oBscBenef:buscar()
	if oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):addNode(cNodeAux):addNode(cNodeAux2)
        cNodeAux3 := "dadosSemCartao"
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):addNode(cNodeAux3)
        if !empty(oBenef:getCns())
            oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):getNode(cNodeAux3):addNode("numeroCartaoNacionalSaude"):setValue(oBenef:getCns())
        endIf     
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):getNode(cNodeAux3):addNode("sexo"):setValue(oBenef:getSexo())
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):getNode(cNodeAux3):addNode("dataNascimento"):setValue(self:maskDate(Dtos(oBenef:getDatNas())))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(cNodeAux):getNode(cNodeAux2):getNode(cNodeAux3):addNode("municipioResidencia"):setValue(oBenef:getCodMun())
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(cNodeAux):addNode("numeroRegistroPlano"):setValue(oBenef:getSusep())
        
        oBenef:destroy()   
        FreeObj(oBenef)
        oBenef := nil

    endIf 

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):addNode("identificacaoFornecimentoDireto"):setValue(oGuia:getValue("providerFormNumber"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):addNode("dataFornecimento"):setValue(self:maskDate(oGuia:getValue("formProcDt")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):addNode("valorTotalFornecimento"):setValue(self:maskValue(oGuia:getValue("valuePaidForm")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):addNode("valorTotalTabelaPropria"):setValue(self:maskValue(oGuia:getValue("ownTableTotalValue")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):addNode("valorTotalCoParticipacao"):setValue(self:maskValue(oGuia:getValue("coPaymentTotalValue")))

    //Node procedimentos
    oCltBVT:setValue("operatorRecord"    ,oGuia:getValue("operatorRecord"))
    oCltBVT:setValue("providerFormNumber",oGuia:getValue("providerFormNumber"))
    oCltBVT:setValue("requirementCode"   ,oGuia:getValue("requirementCode"))
    oCltBVT:setValue("referenceYear"     ,oGuia:getValue("referenceYear"))
    oCltBVT:setValue("commitmentCode"    ,oGuia:getValue("commitmentCode"))
    oCltBVT:setValue("batchCode"         ,oGuia:getValue("batchCode"))
    oCltBVT:setValue("formProcDt"        ,oGuia:getValue("formProcDt"))

    if oCltBVT:buscar()
        while oCltBVT:HasNext()
            nContIte++
            oEvento := oCltBVT:GetNext()
            self:procEveFor(oXml,oEvento,cSeqGui,cValtoChar(nContIte))
            
            oEvento:destroy()
            FreeObj(oEvento)
            oEvento := nil
        
        endDo
    endIf

    oBscBenef:destroy()
    FreeObj(oBscBenef)
    oBscBenef := nil
    
    oCltBVT:destroy()
    FreeObj(oCltBVT)
    oCltBVT := nil
 
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procEveFor
    Processa um evento ao gerar o arquivo Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procEveFor(oXml,oEvento,cSeqGui,cSeqIte) Class CenExMoFor

    Local cNodeAux  := ""
    Local cNodeAux2 := ""
    
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):addNode(FOREVE+cSeqIte,FOREVE)

    //Node identProcedimento 
    cNodeAux  := "identProcedimento"
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(FOREVE+cSeqIte):addNode(cNodeAux)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(FOREVE+cSeqIte):getNode(cNodeAux):addNode("codigoTabela"):setValue(oEvento:getValue("tableCode"))
    
    //Node Procedimento
    cNodeAux2 := "procedimento"
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(FOREVE+cSeqIte):getNode(cNodeAux):addNode(cNodeAux2)
    if !empty(oEvento:getValue("procedureGroup"))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(FOREVE+cSeqIte):getNode(cNodeAux):getNode(cNodeAux2):addNode("grupoProcedimento"):setValue(oEvento:getValue("procedureGroup"))
    else
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(FOREVE+cSeqIte):getNode(cNodeAux):getNode(cNodeAux2):addNode("codigoProcedimento"):setValue(oEvento:getValue("procedureCode"))
    endIf
    
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(FOREVE+cSeqIte):addNode("quantidadeFornecida"):setValue(self:maskValue(oEvento:getValue("enteredQuantity")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(FOREVE+cSeqIte):addNode("valorFornecido"):setValue(self:maskValue(oEvento:getValue("procedureValuePaid")))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(FORDIR+cSeqGui):getNode(FOREVE+cSeqIte):addNode("valorCoParticipacao"):setValue(self:maskValue(oEvento:getValue("coPaymentValue")))

Return