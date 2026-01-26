#include "TOTVS.CH"
#include 'FWMVCDEF.CH'
#define MSGCAB 'mensagemEnvioANS'
#define HEADER 'cabecalho'
#define BODY   'Mensagem'
#define OPEANS 'operadoraParaANS'
#define OUTREM 'outraRemuneracaoMonitoramento'
#define QTDFLUSH 20

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenExMoRem
    Classe para a geracao dos arquivos XTE operadoraParaANS do Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenExMoRem From CenExpoMon

	Method New() Constructor
    Method procRegist(oXml,oOutRem,cSeqGui)
       
EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenExMoRem

    _Super:new()
    self:oCltAlias := CenCltBVZ():New()

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procRegist
    Processa uma guia ao gerar o arquivo Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procRegist(oXml,oOutRem,cSeqGui) Class CenExMoRem

    Local cNodeAux  := ""

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):addNode(OUTREM+cSeqGui,OUTREM)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(OUTREM+cSeqGui):addNode("tipoRegistro"):setValue(oOutRem:getValue("monitoringRecordType"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(OUTREM+cSeqGui):addNode("dataProcessamento"):setValue(self:maskDate(oOutRem:getValue("formProcDt")))

    cNodeAux  := "dadosRecebedor"
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(OUTREM+cSeqGui):addNode(cNodeAux)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(OUTREM+cSeqGui):getNode(cNodeAux):addNode("identificadorRecebedor"):setValue(oOutRem:getValue("identReceipt"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(OUTREM+cSeqGui):getNode(cNodeAux):addNode("codigoCNPJ_CPF"):setValue(oOutRem:getValue("providerCpfCnpj"))

	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(OUTREM+cSeqGui):addNode("valorTotalInformado"):setValue(self:maskValue(oOutRem:getValue("totalValueEntered")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(OUTREM+cSeqGui):addNode("valorTotalGlosa"):setValue(self:maskValue(oOutRem:getValue("totalDisallowValue")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(OUTREM+cSeqGui):addNode("valorTotalPago"):setValue(self:maskValue(oOutRem:getValue("totalValuePaid")))
 
Return