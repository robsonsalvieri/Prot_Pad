#include "TOTVS.CH"
#include 'FWMVCDEF.CH'
#define MSGCAB 'mensagemEnvioANS'
#define HEADER 'cabecalho'
#define BODY   'Mensagem'
#define OPEANS 'operadoraParaANS'
#define VALPRE 'valorPreestabelecidoMonitoramento'
#define QTDFLUSH 20

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenExMoPre
    Classe para a geracao dos arquivos XTE operadoraParaANS do Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenExMoPre From CenExpoMon

	Method New() Constructor
    Method procRegist(oXml,oValPre,cSeqPre)
       
EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenExMoPre

    _Super:new()
    self:oCltAlias := CenCltB9T():New()

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procRegist
    Processa uma guia ao gerar o arquivo Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procRegist(oXml,oValPre,cSeqPre) Class CenExMoPre

    Local cNodeAux  := ""

    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):addNode(VALPRE+cSeqPre,VALPRE)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):addNode("tipoRegistro"):setValue(oValPre:getValue("monitoringRecordType"))
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):addNode("competenciaCoberturaContratada"):setValue(oValPre:getValue("periodCover"))

    cNodeAux  := "dadosPrestador"
    if empty(oValPre:getValue("ansRecordNumber"))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):addNode(cNodeAux)
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):getNode(cNodeAux):addNode("CNES"):setValue(oValPre:getValue("cnes"))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):getNode(cNodeAux):addNode("identificadorPrestador"):setValue(oValPre:getValue("providerIdentifier"))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):getNode(cNodeAux):addNode("codigoCNPJ_CPF"):setValue(oValPre:getValue("providerCpfCnpj"))
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):getNode(cNodeAux):addNode("municipioPrestador"):setValue(oValPre:getValue("cityOfProvider"))
    else    
        oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):addNode("registroANSOperadoraIntermediaria"):setValue(oValPre:getValue("ansRecordNumber"))
    endIf

	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):addNode("identificacaoValorPreestabelecido"):setValue(self:maskValue(oValPre:getValue("presetValueIdent")))
	oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):getNode(VALPRE+cSeqPre):addNode("valorPreestabelecido"):setValue(self:maskValue(oValPre:getValue("presetValue")))
	 
Return