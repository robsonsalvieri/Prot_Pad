#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx?wsdl
Gerado em        11/23/16 17:59:09
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _GOKBMRD ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSIntegracao
------------------------------------------------------------------------------- */

WSCLIENT WSIntegracao

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD DataTransfer
	WSMETHOD EstornoQuitacao
	WSMETHOD ConsultaMovimentos
	WSMETHOD ConsultaContrato
	WSMETHOD EmiteViagemVPR
	WSMETHOD CancelaViagemVPR
	WSMETHOD ValidaCancelamentoViagemVPR
	WSMETHOD IntegraDadosCadastroNacional
	WSMETHOD ConsultaOperacoes
	WSMETHOD ValidaCartaoVPR
	WSMETHOD ValidaCartaoVPRDesmembrado
	WSMETHOD ValidaCartaoExpressDesmembrado
	WSMETHOD ValidaCartaoExpress
	WSMETHOD EmiteContrato
	WSMETHOD ValidaDadosContrato
	WSMETHOD ValidaAberturaContrato
	WSMETHOD AutorizaPagamentoPostos
	WSMETHOD CancelaContrato
	WSMETHOD CancelaContratoProtocolo
	WSMETHOD RoteiroValorTotalVPRs
	WSMETHOD ConsultaCidadesOrigem
	WSMETHOD ConsultaCidadesOrigemDesmembrado
	WSMETHOD ConsultaCidadesDestino
	WSMETHOD ConsultaCidadesDestinoDesmembrado
	WSMETHOD ConsultaRoteiros
	WSMETHOD IntegraDadosCadastroNacionalDesmembrado
	WSMETHOD ConsultaRoteirosDesmembrado
	WSMETHOD IncluiMovimento
	WSMETHOD IncluiMovimentoControleViagem
	WSMETHOD AutorizaQuitacao
	WSMETHOD EmiteControleViagem
	WSMETHOD BaixaControleViagem
	WSMETHOD CancelaControleViagem
	WSMETHOD EstornoBaixaControleViagem
	WSMETHOD QuitaContrato
	WSMETHOD BaixaNotaFiscal
	WSMETHOD ImpostoAdicionalInclui
	WSMETHOD BaixaDocumentacaoContrato
	WSMETHOD ListaNotasFiscais
	WSMETHOD ListaCuponsNotaFiscal
	WSMETHOD AutorizaPagamento
	WSMETHOD AutorizaPagamentoContratos
	WSMETHOD ContratoConfirmaPagamento
	WSMETHOD AlteraMotoristaControleViagem
	WSMETHOD AlteraVeiculoControleViagem
	WSMETHOD AlteraDadosBancarios
	WSMETHOD ConsultaControleViagem
	WSMETHOD ContratoVinculaDocumento
	WSMETHOD SolicitaRoteiro
	WSMETHOD CartaoTaxaAtivacao
	WSMETHOD AlteraKmControleViagem
	WSMETHOD PedidoCargaContratoInclui
	WSMETHOD DocumentosBaixaAntecipada
	WSMETHOD AgendamentoMarcacao
	WSMETHOD CancelamentoAgendamentoMarcacao
	WSMETHOD IntegracaoErros
	WSMETHOD AlteraDocumentoContrato
	WSMETHOD AlteraMotoristaContrato
	WSMETHOD EmiteDocumento
	WSMETHOD CancelaDocumento
	WSMETHOD IncluiCreditoLitrosControleViagem
	WSMETHOD EmiteOS
	WSMETHOD CancelaOS
	WSMETHOD Versao
	WSMETHOD IncluirDebitoLitrosControleViagem
	WSMETHOD IntegraDadosCadastroInternacional
	WSMETHOD ConsultaCTe
	WSMETHOD InterrompeContrato
	WSMETHOD IntegraDadosCadastroNacionalANTT
	WSMETHOD AlteraPortadorCartao

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cstrCliente               AS string
	WSDATA   cstrAssinaturaDigital     AS string
	WSDATA   cstrXmlIn                 AS string
	WSDATA   cstrXmlOut                AS string
	WSDATA   cstrXmlErr                AS string
	WSDATA   lDataTransferResult       AS boolean
	WSDATA   lEstornoQuitacaoResult    AS boolean
	WSDATA   lConsultaMovimentosResult AS boolean
	WSDATA   lConsultaContratoResult   AS boolean
	WSDATA   lEmiteViagemVPRResult     AS boolean
	WSDATA   lCancelaViagemVPRResult   AS boolean
	WSDATA   lValidaCancelamentoViagemVPRResult AS boolean
	WSDATA   cstrXmlInContratado       AS string
	WSDATA   cstrXmlInMotorista        AS string
	WSDATA   cstrXmlInVeiculo          AS string
	WSDATA   cstrXmlInCarreta          AS string
	WSDATA   lIntegraDadosCadastroNacionalResult AS boolean
	WSDATA   lConsultaOperacoesResult  AS boolean
	WSDATA   cstrCartao                AS string
	WSDATA   lValidaCartaoVPRResult    AS boolean
	WSDATA   lValidaCartaoVPRDesmembradoResult AS boolean
	WSDATA   lValidaCartaoExpressDesmembradoResult AS boolean
	WSDATA   cstrTipoEmissao           AS string
	WSDATA   lValidaCartaoExpressResult AS boolean
	WSDATA   lEmiteContratoResult      AS boolean
	WSDATA   lValidaDadosContratoResult AS boolean
	WSDATA   lValidaAberturaContratoResult AS boolean
	WSDATA   lAutorizaPagamentoPostosResult AS boolean
	WSDATA   lCancelaContratoResult    AS boolean
	WSDATA   lCancelaContratoProtocoloResult AS boolean
	WSDATA   lRoteiroValorTotalVPRsResult AS boolean
	WSDATA   cstrEstado                AS string
	WSDATA   cstrPrimeiraLetraCidade   AS string
	WSDATA   lConsultaCidadesOrigemResult AS boolean
	WSDATA   lConsultaCidadesOrigemDesmembradoResult AS boolean
	WSDATA   lConsultaCidadesDestinoResult AS boolean
	WSDATA   lConsultaCidadesDestinoDesmembradoResult AS boolean
	WSDATA   cstrEstadoOrigem          AS string
	WSDATA   cstrCidadeOrigem          AS string
	WSDATA   cstrCEPOrigem             AS string
	WSDATA   cstrCodigoIBGEOrigem      AS string
	WSDATA   cstrEstadoDestino         AS string
	WSDATA   cstrCidadeDestino         AS string
	WSDATA   cstrCEPDestino            AS string
	WSDATA   cstrCodigoIBGEDestino     AS string
	WSDATA   lConsultaRoteirosResult   AS boolean
	WSDATA   lIntegraDadosCadastroNacionalDesmembradoResult AS boolean
	WSDATA   lConsultaRoteirosDesmembradoResult AS boolean
	WSDATA   lIncluiMovimentoResult    AS boolean
	WSDATA   lIncluiMovimentoControleViagemResult AS boolean
	WSDATA   lAutorizaQuitacaoResult   AS boolean
	WSDATA   lEmiteControleViagemResult AS boolean
	WSDATA   lBaixaControleViagemResult AS boolean
	WSDATA   lCancelaControleViagemResult AS boolean
	WSDATA   lEstornoBaixaControleViagemResult AS boolean
	WSDATA   lQuitaContratoResult      AS boolean
	WSDATA   lBaixaNotaFiscalResult    AS boolean
	WSDATA   lImpostoAdicionalIncluiResult AS boolean
	WSDATA   lBaixaDocumentacaoContratoResult AS boolean
	WSDATA   lListaNotasFiscaisResult  AS boolean
	WSDATA   lListaCuponsNotaFiscalResult AS boolean
	WSDATA   lAutorizaPagamentoResult  AS boolean
	WSDATA   lAutorizaPagamentoContratosResult AS boolean
	WSDATA   lContratoConfirmaPagamentoResult AS boolean
	WSDATA   lAlteraMotoristaControleViagemResult AS boolean
	WSDATA   lAlteraVeiculoControleViagemResult AS boolean
	WSDATA   lAlteraDadosBancariosResult AS boolean
	WSDATA   lConsultaControleViagemResult AS boolean
	WSDATA   lContratoVinculaDocumentoResult AS boolean
	WSDATA   lSolicitaRoteiroResult    AS boolean
	WSDATA   lCartaoTaxaAtivacaoResult AS boolean
	WSDATA   lAlteraKmControleViagemResult AS boolean
	WSDATA   lPedidoCargaContratoIncluiResult AS boolean
	WSDATA   lDocumentosBaixaAntecipadaResult AS boolean
	WSDATA   cstrPatio                 AS string
	WSDATA   lAgendamentoMarcacaoResult AS boolean
	WSDATA   lCancelamentoAgendamentoMarcacaoResult AS boolean
	WSDATA   lIntegracaoErrosResult    AS boolean
	WSDATA   lAlteraDocumentoContratoResult AS boolean
	WSDATA   lAlteraMotoristaContratoResult AS boolean
	WSDATA   lEmiteDocumentoResult     AS boolean
	WSDATA   lCancelaDocumentoResult   AS boolean
	WSDATA   lIncluiCreditoLitrosControleViagemResult AS boolean
	WSDATA   lEmiteOSResult            AS boolean
	WSDATA   lCancelaOSResult          AS boolean
	WSDATA   cVersaoResult             AS string
	WSDATA   lIncluirDebitoLitrosControleViagemResult AS boolean
	WSDATA   lIntegraDadosCadastroInternacionalResult AS boolean
	WSDATA   lConsultaCTeResult        AS boolean
	WSDATA   lInterrompeContratoResult AS boolean
	WSDATA   lIntegraDadosCadastroNacionalANTTResult AS boolean
	WSDATA   lAlteraPortadorCartaoResult AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSIntegracao
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160405 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSIntegracao
Return

WSMETHOD RESET WSCLIENT WSIntegracao
	::cstrCliente        := NIL 
	::cstrAssinaturaDigital := NIL 
	::cstrXmlIn          := NIL 
	::cstrXmlOut         := NIL 
	::cstrXmlErr         := NIL 
	::lDataTransferResult := NIL 
	::lEstornoQuitacaoResult := NIL 
	::lConsultaMovimentosResult := NIL 
	::lConsultaContratoResult := NIL 
	::lEmiteViagemVPRResult := NIL 
	::lCancelaViagemVPRResult := NIL 
	::lValidaCancelamentoViagemVPRResult := NIL 
	::cstrXmlInContratado := NIL 
	::cstrXmlInMotorista := NIL 
	::cstrXmlInVeiculo   := NIL 
	::cstrXmlInCarreta   := NIL 
	::lIntegraDadosCadastroNacionalResult := NIL 
	::lConsultaOperacoesResult := NIL 
	::cstrCartao         := NIL 
	::lValidaCartaoVPRResult := NIL 
	::lValidaCartaoVPRDesmembradoResult := NIL 
	::lValidaCartaoExpressDesmembradoResult := NIL 
	::cstrTipoEmissao    := NIL 
	::lValidaCartaoExpressResult := NIL 
	::lEmiteContratoResult := NIL 
	::lValidaDadosContratoResult := NIL 
	::lValidaAberturaContratoResult := NIL 
	::lAutorizaPagamentoPostosResult := NIL 
	::lCancelaContratoResult := NIL 
	::lCancelaContratoProtocoloResult := NIL 
	::lRoteiroValorTotalVPRsResult := NIL 
	::cstrEstado         := NIL 
	::cstrPrimeiraLetraCidade := NIL 
	::lConsultaCidadesOrigemResult := NIL 
	::lConsultaCidadesOrigemDesmembradoResult := NIL 
	::lConsultaCidadesDestinoResult := NIL 
	::lConsultaCidadesDestinoDesmembradoResult := NIL 
	::cstrEstadoOrigem   := NIL 
	::cstrCidadeOrigem   := NIL 
	::cstrCEPOrigem      := NIL 
	::cstrCodigoIBGEOrigem := NIL 
	::cstrEstadoDestino  := NIL 
	::cstrCidadeDestino  := NIL 
	::cstrCEPDestino     := NIL 
	::cstrCodigoIBGEDestino := NIL 
	::lConsultaRoteirosResult := NIL 
	::lIntegraDadosCadastroNacionalDesmembradoResult := NIL 
	::lConsultaRoteirosDesmembradoResult := NIL 
	::lIncluiMovimentoResult := NIL 
	::lIncluiMovimentoControleViagemResult := NIL 
	::lAutorizaQuitacaoResult := NIL 
	::lEmiteControleViagemResult := NIL 
	::lBaixaControleViagemResult := NIL 
	::lCancelaControleViagemResult := NIL 
	::lEstornoBaixaControleViagemResult := NIL 
	::lQuitaContratoResult := NIL 
	::lBaixaNotaFiscalResult := NIL 
	::lImpostoAdicionalIncluiResult := NIL 
	::lBaixaDocumentacaoContratoResult := NIL 
	::lListaNotasFiscaisResult := NIL 
	::lListaCuponsNotaFiscalResult := NIL 
	::lAutorizaPagamentoResult := NIL 
	::lAutorizaPagamentoContratosResult := NIL 
	::lContratoConfirmaPagamentoResult := NIL 
	::lAlteraMotoristaControleViagemResult := NIL 
	::lAlteraVeiculoControleViagemResult := NIL 
	::lAlteraDadosBancariosResult := NIL 
	::lConsultaControleViagemResult := NIL 
	::lContratoVinculaDocumentoResult := NIL 
	::lSolicitaRoteiroResult := NIL 
	::lCartaoTaxaAtivacaoResult := NIL 
	::lAlteraKmControleViagemResult := NIL 
	::lPedidoCargaContratoIncluiResult := NIL 
	::lDocumentosBaixaAntecipadaResult := NIL 
	::cstrPatio          := NIL 
	::lAgendamentoMarcacaoResult := NIL 
	::lCancelamentoAgendamentoMarcacaoResult := NIL 
	::lIntegracaoErrosResult := NIL 
	::lAlteraDocumentoContratoResult := NIL 
	::lAlteraMotoristaContratoResult := NIL 
	::lEmiteDocumentoResult := NIL 
	::lCancelaDocumentoResult := NIL 
	::lIncluiCreditoLitrosControleViagemResult := NIL 
	::lEmiteOSResult     := NIL 
	::lCancelaOSResult   := NIL 
	::cVersaoResult      := NIL 
	::lIncluirDebitoLitrosControleViagemResult := NIL 
	::lIntegraDadosCadastroInternacionalResult := NIL 
	::lConsultaCTeResult := NIL 
	::lInterrompeContratoResult := NIL 
	::lIntegraDadosCadastroNacionalANTTResult := NIL 
	::lAlteraPortadorCartaoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSIntegracao
Local oClone := WSIntegracao():New()
	oClone:_URL          := ::_URL 
	oClone:cstrCliente   := ::cstrCliente
	oClone:cstrAssinaturaDigital := ::cstrAssinaturaDigital
	oClone:cstrXmlIn     := ::cstrXmlIn
	oClone:cstrXmlOut    := ::cstrXmlOut
	oClone:cstrXmlErr    := ::cstrXmlErr
	oClone:lDataTransferResult := ::lDataTransferResult
	oClone:lEstornoQuitacaoResult := ::lEstornoQuitacaoResult
	oClone:lConsultaMovimentosResult := ::lConsultaMovimentosResult
	oClone:lConsultaContratoResult := ::lConsultaContratoResult
	oClone:lEmiteViagemVPRResult := ::lEmiteViagemVPRResult
	oClone:lCancelaViagemVPRResult := ::lCancelaViagemVPRResult
	oClone:lValidaCancelamentoViagemVPRResult := ::lValidaCancelamentoViagemVPRResult
	oClone:cstrXmlInContratado := ::cstrXmlInContratado
	oClone:cstrXmlInMotorista := ::cstrXmlInMotorista
	oClone:cstrXmlInVeiculo := ::cstrXmlInVeiculo
	oClone:cstrXmlInCarreta := ::cstrXmlInCarreta
	oClone:lIntegraDadosCadastroNacionalResult := ::lIntegraDadosCadastroNacionalResult
	oClone:lConsultaOperacoesResult := ::lConsultaOperacoesResult
	oClone:cstrCartao    := ::cstrCartao
	oClone:lValidaCartaoVPRResult := ::lValidaCartaoVPRResult
	oClone:lValidaCartaoVPRDesmembradoResult := ::lValidaCartaoVPRDesmembradoResult
	oClone:lValidaCartaoExpressDesmembradoResult := ::lValidaCartaoExpressDesmembradoResult
	oClone:cstrTipoEmissao := ::cstrTipoEmissao
	oClone:lValidaCartaoExpressResult := ::lValidaCartaoExpressResult
	oClone:lEmiteContratoResult := ::lEmiteContratoResult
	oClone:lValidaDadosContratoResult := ::lValidaDadosContratoResult
	oClone:lValidaAberturaContratoResult := ::lValidaAberturaContratoResult
	oClone:lAutorizaPagamentoPostosResult := ::lAutorizaPagamentoPostosResult
	oClone:lCancelaContratoResult := ::lCancelaContratoResult
	oClone:lCancelaContratoProtocoloResult := ::lCancelaContratoProtocoloResult
	oClone:lRoteiroValorTotalVPRsResult := ::lRoteiroValorTotalVPRsResult
	oClone:cstrEstado    := ::cstrEstado
	oClone:cstrPrimeiraLetraCidade := ::cstrPrimeiraLetraCidade
	oClone:lConsultaCidadesOrigemResult := ::lConsultaCidadesOrigemResult
	oClone:lConsultaCidadesOrigemDesmembradoResult := ::lConsultaCidadesOrigemDesmembradoResult
	oClone:lConsultaCidadesDestinoResult := ::lConsultaCidadesDestinoResult
	oClone:lConsultaCidadesDestinoDesmembradoResult := ::lConsultaCidadesDestinoDesmembradoResult
	oClone:cstrEstadoOrigem := ::cstrEstadoOrigem
	oClone:cstrCidadeOrigem := ::cstrCidadeOrigem
	oClone:cstrCEPOrigem := ::cstrCEPOrigem
	oClone:cstrCodigoIBGEOrigem := ::cstrCodigoIBGEOrigem
	oClone:cstrEstadoDestino := ::cstrEstadoDestino
	oClone:cstrCidadeDestino := ::cstrCidadeDestino
	oClone:cstrCEPDestino := ::cstrCEPDestino
	oClone:cstrCodigoIBGEDestino := ::cstrCodigoIBGEDestino
	oClone:lConsultaRoteirosResult := ::lConsultaRoteirosResult
	oClone:lIntegraDadosCadastroNacionalDesmembradoResult := ::lIntegraDadosCadastroNacionalDesmembradoResult
	oClone:lConsultaRoteirosDesmembradoResult := ::lConsultaRoteirosDesmembradoResult
	oClone:lIncluiMovimentoResult := ::lIncluiMovimentoResult
	oClone:lIncluiMovimentoControleViagemResult := ::lIncluiMovimentoControleViagemResult
	oClone:lAutorizaQuitacaoResult := ::lAutorizaQuitacaoResult
	oClone:lEmiteControleViagemResult := ::lEmiteControleViagemResult
	oClone:lBaixaControleViagemResult := ::lBaixaControleViagemResult
	oClone:lCancelaControleViagemResult := ::lCancelaControleViagemResult
	oClone:lEstornoBaixaControleViagemResult := ::lEstornoBaixaControleViagemResult
	oClone:lQuitaContratoResult := ::lQuitaContratoResult
	oClone:lBaixaNotaFiscalResult := ::lBaixaNotaFiscalResult
	oClone:lImpostoAdicionalIncluiResult := ::lImpostoAdicionalIncluiResult
	oClone:lBaixaDocumentacaoContratoResult := ::lBaixaDocumentacaoContratoResult
	oClone:lListaNotasFiscaisResult := ::lListaNotasFiscaisResult
	oClone:lListaCuponsNotaFiscalResult := ::lListaCuponsNotaFiscalResult
	oClone:lAutorizaPagamentoResult := ::lAutorizaPagamentoResult
	oClone:lAutorizaPagamentoContratosResult := ::lAutorizaPagamentoContratosResult
	oClone:lContratoConfirmaPagamentoResult := ::lContratoConfirmaPagamentoResult
	oClone:lAlteraMotoristaControleViagemResult := ::lAlteraMotoristaControleViagemResult
	oClone:lAlteraVeiculoControleViagemResult := ::lAlteraVeiculoControleViagemResult
	oClone:lAlteraDadosBancariosResult := ::lAlteraDadosBancariosResult
	oClone:lConsultaControleViagemResult := ::lConsultaControleViagemResult
	oClone:lContratoVinculaDocumentoResult := ::lContratoVinculaDocumentoResult
	oClone:lSolicitaRoteiroResult := ::lSolicitaRoteiroResult
	oClone:lCartaoTaxaAtivacaoResult := ::lCartaoTaxaAtivacaoResult
	oClone:lAlteraKmControleViagemResult := ::lAlteraKmControleViagemResult
	oClone:lPedidoCargaContratoIncluiResult := ::lPedidoCargaContratoIncluiResult
	oClone:lDocumentosBaixaAntecipadaResult := ::lDocumentosBaixaAntecipadaResult
	oClone:cstrPatio     := ::cstrPatio
	oClone:lAgendamentoMarcacaoResult := ::lAgendamentoMarcacaoResult
	oClone:lCancelamentoAgendamentoMarcacaoResult := ::lCancelamentoAgendamentoMarcacaoResult
	oClone:lIntegracaoErrosResult := ::lIntegracaoErrosResult
	oClone:lAlteraDocumentoContratoResult := ::lAlteraDocumentoContratoResult
	oClone:lAlteraMotoristaContratoResult := ::lAlteraMotoristaContratoResult
	oClone:lEmiteDocumentoResult := ::lEmiteDocumentoResult
	oClone:lCancelaDocumentoResult := ::lCancelaDocumentoResult
	oClone:lIncluiCreditoLitrosControleViagemResult := ::lIncluiCreditoLitrosControleViagemResult
	oClone:lEmiteOSResult := ::lEmiteOSResult
	oClone:lCancelaOSResult := ::lCancelaOSResult
	oClone:cVersaoResult := ::cVersaoResult
	oClone:lIncluirDebitoLitrosControleViagemResult := ::lIncluirDebitoLitrosControleViagemResult
	oClone:lIntegraDadosCadastroInternacionalResult := ::lIntegraDadosCadastroInternacionalResult
	oClone:lConsultaCTeResult := ::lConsultaCTeResult
	oClone:lInterrompeContratoResult := ::lInterrompeContratoResult
	oClone:lIntegraDadosCadastroNacionalANTTResult := ::lIntegraDadosCadastroNacionalANTTResult
	oClone:lAlteraPortadorCartaoResult := ::lAlteraPortadorCartaoResult
Return oClone

// WSDL Method DataTransfer of Service WSIntegracao

WSMETHOD DataTransfer WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lDataTransferResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DataTransfer xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</DataTransfer>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/DataTransfer",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lDataTransferResult :=  WSAdvValue( oXmlRet,"_DATATRANSFERRESPONSE:_DATATRANSFERRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_DATATRANSFERRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_DATATRANSFERRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EstornoQuitacao of Service WSIntegracao

WSMETHOD EstornoQuitacao WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lEstornoQuitacaoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EstornoQuitacao xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</EstornoQuitacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/EstornoQuitacao",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lEstornoQuitacaoResult :=  WSAdvValue( oXmlRet,"_ESTORNOQUITACAORESPONSE:_ESTORNOQUITACAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ESTORNOQUITACAORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaMovimentos of Service WSIntegracao

WSMETHOD ConsultaMovimentos WSSEND cstrCliente,cstrAssinaturaDigital,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaMovimentosResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaMovimentos xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaMovimentos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaMovimentos",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaMovimentosResult :=  WSAdvValue( oXmlRet,"_CONSULTAMOVIMENTOSRESPONSE:_CONSULTAMOVIMENTOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTAMOVIMENTOSRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTAMOVIMENTOSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaContrato of Service WSIntegracao

WSMETHOD ConsultaContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaContratoResult :=  WSAdvValue( oXmlRet,"_CONSULTACONTRATORESPONSE:_CONSULTACONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTACONTRATORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTACONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EmiteViagemVPR of Service WSIntegracao

WSMETHOD EmiteViagemVPR WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lEmiteViagemVPRResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EmiteViagemVPR xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</EmiteViagemVPR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/EmiteViagemVPR",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lEmiteViagemVPRResult :=  WSAdvValue( oXmlRet,"_EMITEVIAGEMVPRRESPONSE:_EMITEVIAGEMVPRRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_EMITEVIAGEMVPRRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_EMITEVIAGEMVPRRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelaViagemVPR of Service WSIntegracao

WSMETHOD CancelaViagemVPR WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lCancelaViagemVPRResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelaViagemVPR xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CancelaViagemVPR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/CancelaViagemVPR",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lCancelaViagemVPRResult :=  WSAdvValue( oXmlRet,"_CANCELAVIAGEMVPRRESPONSE:_CANCELAVIAGEMVPRRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CANCELAVIAGEMVPRRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ValidaCancelamentoViagemVPR of Service WSIntegracao

WSMETHOD ValidaCancelamentoViagemVPR WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lValidaCancelamentoViagemVPRResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ValidaCancelamentoViagemVPR xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ValidaCancelamentoViagemVPR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ValidaCancelamentoViagemVPR",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lValidaCancelamentoViagemVPRResult :=  WSAdvValue( oXmlRet,"_VALIDACANCELAMENTOVIAGEMVPRRESPONSE:_VALIDACANCELAMENTOVIAGEMVPRRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_VALIDACANCELAMENTOVIAGEMVPRRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegraDadosCadastroNacional of Service WSIntegracao

WSMETHOD IntegraDadosCadastroNacional WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlInContratado,cstrXmlInMotorista,cstrXmlInVeiculo,cstrXmlInCarreta,BYREF cstrXmlErr WSRECEIVE lIntegraDadosCadastroNacionalResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegraDadosCadastroNacional xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInContratado", ::cstrXmlInContratado, cstrXmlInContratado , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInMotorista", ::cstrXmlInMotorista, cstrXmlInMotorista , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInVeiculo", ::cstrXmlInVeiculo, cstrXmlInVeiculo , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInCarreta", ::cstrXmlInCarreta, cstrXmlInCarreta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IntegraDadosCadastroNacional>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IntegraDadosCadastroNacional",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIntegraDadosCadastroNacionalResult :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTRONACIONALRESPONSE:_INTEGRADADOSCADASTRONACIONALRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTRONACIONALRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaOperacoes of Service WSIntegracao

WSMETHOD ConsultaOperacoes WSSEND cstrCliente,cstrAssinaturaDigital,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaOperacoesResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaOperacoes xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaOperacoes>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaOperacoes",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaOperacoesResult :=  WSAdvValue( oXmlRet,"_CONSULTAOPERACOESRESPONSE:_CONSULTAOPERACOESRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTAOPERACOESRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTAOPERACOESRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ValidaCartaoVPR of Service WSIntegracao

WSMETHOD ValidaCartaoVPR WSSEND cstrCliente,cstrAssinaturaDigital,cstrCartao,BYREF cstrXmlErr WSRECEIVE lValidaCartaoVPRResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ValidaCartaoVPR xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strCartao", ::cstrCartao, cstrCartao , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ValidaCartaoVPR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ValidaCartaoVPR",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lValidaCartaoVPRResult :=  WSAdvValue( oXmlRet,"_VALIDACARTAOVPRRESPONSE:_VALIDACARTAOVPRRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_VALIDACARTAOVPRRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ValidaCartaoVPRDesmembrado of Service WSIntegracao

WSMETHOD ValidaCartaoVPRDesmembrado WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lValidaCartaoVPRDesmembradoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ValidaCartaoVPRDesmembrado xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ValidaCartaoVPRDesmembrado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ValidaCartaoVPRDesmembrado",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lValidaCartaoVPRDesmembradoResult :=  WSAdvValue( oXmlRet,"_VALIDACARTAOVPRDESMEMBRADORESPONSE:_VALIDACARTAOVPRDESMEMBRADORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_VALIDACARTAOVPRDESMEMBRADORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ValidaCartaoExpressDesmembrado of Service WSIntegracao

WSMETHOD ValidaCartaoExpressDesmembrado WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lValidaCartaoExpressDesmembradoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ValidaCartaoExpressDesmembrado xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ValidaCartaoExpressDesmembrado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ValidaCartaoExpressDesmembrado",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lValidaCartaoExpressDesmembradoResult :=  WSAdvValue( oXmlRet,"_VALIDACARTAOEXPRESSDESMEMBRADORESPONSE:_VALIDACARTAOEXPRESSDESMEMBRADORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_VALIDACARTAOEXPRESSDESMEMBRADORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ValidaCartaoExpress of Service WSIntegracao

WSMETHOD ValidaCartaoExpress WSSEND cstrCliente,cstrAssinaturaDigital,cstrCartao,cstrTipoEmissao,BYREF cstrXmlErr WSRECEIVE lValidaCartaoExpressResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ValidaCartaoExpress xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strCartao", ::cstrCartao, cstrCartao , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strTipoEmissao", ::cstrTipoEmissao, cstrTipoEmissao , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ValidaCartaoExpress>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ValidaCartaoExpress",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lValidaCartaoExpressResult :=  WSAdvValue( oXmlRet,"_VALIDACARTAOEXPRESSRESPONSE:_VALIDACARTAOEXPRESSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_VALIDACARTAOEXPRESSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EmiteContrato of Service WSIntegracao

WSMETHOD EmiteContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lEmiteContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EmiteContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</EmiteContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/EmiteContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lEmiteContratoResult :=  WSAdvValue( oXmlRet,"_EMITECONTRATORESPONSE:_EMITECONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_EMITECONTRATORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_EMITECONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ValidaDadosContrato of Service WSIntegracao

WSMETHOD ValidaDadosContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lValidaDadosContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ValidaDadosContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ValidaDadosContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ValidaDadosContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lValidaDadosContratoResult :=  WSAdvValue( oXmlRet,"_VALIDADADOSCONTRATORESPONSE:_VALIDADADOSCONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_VALIDADADOSCONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ValidaAberturaContrato of Service WSIntegracao

WSMETHOD ValidaAberturaContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lValidaAberturaContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ValidaAberturaContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ValidaAberturaContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ValidaAberturaContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lValidaAberturaContratoResult :=  WSAdvValue( oXmlRet,"_VALIDAABERTURACONTRATORESPONSE:_VALIDAABERTURACONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_VALIDAABERTURACONTRATORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_VALIDAABERTURACONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AutorizaPagamentoPostos of Service WSIntegracao

WSMETHOD AutorizaPagamentoPostos WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lAutorizaPagamentoPostosResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AutorizaPagamentoPostos xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AutorizaPagamentoPostos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AutorizaPagamentoPostos",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAutorizaPagamentoPostosResult :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTOPOSTOSRESPONSE:_AUTORIZAPAGAMENTOPOSTOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTOPOSTOSRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTOPOSTOSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelaContrato of Service WSIntegracao

WSMETHOD CancelaContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lCancelaContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelaContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CancelaContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/CancelaContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lCancelaContratoResult :=  WSAdvValue( oXmlRet,"_CANCELACONTRATORESPONSE:_CANCELACONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CANCELACONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 
END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelaContratoProtocolo of Service WSIntegracao

WSMETHOD CancelaContratoProtocolo WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lCancelaContratoProtocoloResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelaContratoProtocolo xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CancelaContratoProtocolo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/CancelaContratoProtocolo",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lCancelaContratoProtocoloResult :=  WSAdvValue( oXmlRet,"_CANCELACONTRATOPROTOCOLORESPONSE:_CANCELACONTRATOPROTOCOLORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CANCELACONTRATOPROTOCOLORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CANCELACONTRATOPROTOCOLORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RoteiroValorTotalVPRs of Service WSIntegracao

WSMETHOD RoteiroValorTotalVPRs WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lRoteiroValorTotalVPRsResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RoteiroValorTotalVPRs xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</RoteiroValorTotalVPRs>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/RoteiroValorTotalVPRs",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lRoteiroValorTotalVPRsResult :=  WSAdvValue( oXmlRet,"_ROTEIROVALORTOTALVPRSRESPONSE:_ROTEIROVALORTOTALVPRSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_ROTEIROVALORTOTALVPRSRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ROTEIROVALORTOTALVPRSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaCidadesOrigem of Service WSIntegracao

WSMETHOD ConsultaCidadesOrigem WSSEND cstrCliente,cstrAssinaturaDigital,cstrEstado,cstrPrimeiraLetraCidade,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaCidadesOrigemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaCidadesOrigem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strEstado", ::cstrEstado, cstrEstado , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strPrimeiraLetraCidade", ::cstrPrimeiraLetraCidade, cstrPrimeiraLetraCidade , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaCidadesOrigem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaCidadesOrigem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaCidadesOrigemResult :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESORIGEMRESPONSE:_CONSULTACIDADESORIGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESORIGEMRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESORIGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaCidadesOrigemDesmembrado of Service WSIntegracao

WSMETHOD ConsultaCidadesOrigemDesmembrado WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaCidadesOrigemDesmembradoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaCidadesOrigemDesmembrado xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaCidadesOrigemDesmembrado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaCidadesOrigemDesmembrado",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaCidadesOrigemDesmembradoResult :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESORIGEMDESMEMBRADORESPONSE:_CONSULTACIDADESORIGEMDESMEMBRADORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESORIGEMDESMEMBRADORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESORIGEMDESMEMBRADORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaCidadesDestino of Service WSIntegracao

WSMETHOD ConsultaCidadesDestino WSSEND cstrCliente,cstrAssinaturaDigital,cstrEstado,cstrPrimeiraLetraCidade,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaCidadesDestinoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaCidadesDestino xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strEstado", ::cstrEstado, cstrEstado , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strPrimeiraLetraCidade", ::cstrPrimeiraLetraCidade, cstrPrimeiraLetraCidade , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaCidadesDestino>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaCidadesDestino",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaCidadesDestinoResult :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESDESTINORESPONSE:_CONSULTACIDADESDESTINORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESDESTINORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESDESTINORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaCidadesDestinoDesmembrado of Service WSIntegracao

WSMETHOD ConsultaCidadesDestinoDesmembrado WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaCidadesDestinoDesmembradoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaCidadesDestinoDesmembrado xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaCidadesDestinoDesmembrado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaCidadesDestinoDesmembrado",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaCidadesDestinoDesmembradoResult :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESDESTINODESMEMBRADORESPONSE:_CONSULTACIDADESDESTINODESMEMBRADORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESDESTINODESMEMBRADORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTACIDADESDESTINODESMEMBRADORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaRoteiros of Service WSIntegracao

WSMETHOD ConsultaRoteiros WSSEND cstrCliente,cstrAssinaturaDigital,cstrEstadoOrigem,cstrCidadeOrigem,cstrCEPOrigem,cstrCodigoIBGEOrigem,cstrEstadoDestino,cstrCidadeDestino,cstrCEPDestino,cstrCodigoIBGEDestino,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaRoteirosResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaRoteiros xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strEstadoOrigem", ::cstrEstadoOrigem, cstrEstadoOrigem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strCidadeOrigem", ::cstrCidadeOrigem, cstrCidadeOrigem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strCEPOrigem", ::cstrCEPOrigem, cstrCEPOrigem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strCodigoIBGEOrigem", ::cstrCodigoIBGEOrigem, cstrCodigoIBGEOrigem , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strEstadoDestino", ::cstrEstadoDestino, cstrEstadoDestino , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strCidadeDestino", ::cstrCidadeDestino, cstrCidadeDestino , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strCEPDestino", ::cstrCEPDestino, cstrCEPDestino , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strCodigoIBGEDestino", ::cstrCodigoIBGEDestino, cstrCodigoIBGEDestino , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaRoteiros>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaRoteiros",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaRoteirosResult :=  WSAdvValue( oXmlRet,"_CONSULTAROTEIROSRESPONSE:_CONSULTAROTEIROSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTAROTEIROSRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTAROTEIROSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegraDadosCadastroNacionalDesmembrado of Service WSIntegracao

WSMETHOD IntegraDadosCadastroNacionalDesmembrado WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lIntegraDadosCadastroNacionalDesmembradoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegraDadosCadastroNacionalDesmembrado xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IntegraDadosCadastroNacionalDesmembrado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IntegraDadosCadastroNacionalDesmembrado",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIntegraDadosCadastroNacionalDesmembradoResult :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTRONACIONALDESMEMBRADORESPONSE:_INTEGRADADOSCADASTRONACIONALDESMEMBRADORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTRONACIONALDESMEMBRADORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTRONACIONALDESMEMBRADORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaRoteirosDesmembrado of Service WSIntegracao

WSMETHOD ConsultaRoteirosDesmembrado WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaRoteirosDesmembradoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaRoteirosDesmembrado xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaRoteirosDesmembrado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaRoteirosDesmembrado",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaRoteirosDesmembradoResult :=  WSAdvValue( oXmlRet,"_CONSULTAROTEIROSDESMEMBRADORESPONSE:_CONSULTAROTEIROSDESMEMBRADORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTAROTEIROSDESMEMBRADORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTAROTEIROSDESMEMBRADORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IncluiMovimento of Service WSIntegracao

WSMETHOD IncluiMovimento WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lIncluiMovimentoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IncluiMovimento xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IncluiMovimento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IncluiMovimento",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIncluiMovimentoResult :=  WSAdvValue( oXmlRet,"_INCLUIMOVIMENTORESPONSE:_INCLUIMOVIMENTORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INCLUIMOVIMENTORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IncluiMovimentoControleViagem of Service WSIntegracao

WSMETHOD IncluiMovimentoControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lIncluiMovimentoControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IncluiMovimentoControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IncluiMovimentoControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IncluiMovimentoControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIncluiMovimentoControleViagemResult :=  WSAdvValue( oXmlRet,"_INCLUIMOVIMENTOCONTROLEVIAGEMRESPONSE:_INCLUIMOVIMENTOCONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INCLUIMOVIMENTOCONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AutorizaQuitacao of Service WSIntegracao

WSMETHOD AutorizaQuitacao WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lAutorizaQuitacaoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AutorizaQuitacao xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AutorizaQuitacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AutorizaQuitacao",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAutorizaQuitacaoResult :=  WSAdvValue( oXmlRet,"_AUTORIZAQUITACAORESPONSE:_AUTORIZAQUITACAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_AUTORIZAQUITACAORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EmiteControleViagem of Service WSIntegracao

WSMETHOD EmiteControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lEmiteControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EmiteControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</EmiteControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/EmiteControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lEmiteControleViagemResult :=  WSAdvValue( oXmlRet,"_EMITECONTROLEVIAGEMRESPONSE:_EMITECONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_EMITECONTROLEVIAGEMRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_EMITECONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BaixaControleViagem of Service WSIntegracao

WSMETHOD BaixaControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lBaixaControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BaixaControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</BaixaControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/BaixaControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lBaixaControleViagemResult :=  WSAdvValue( oXmlRet,"_BAIXACONTROLEVIAGEMRESPONSE:_BAIXACONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_BAIXACONTROLEVIAGEMRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_BAIXACONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelaControleViagem of Service WSIntegracao

WSMETHOD CancelaControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lCancelaControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelaControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CancelaControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/CancelaControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lCancelaControleViagemResult :=  WSAdvValue( oXmlRet,"_CANCELACONTROLEVIAGEMRESPONSE:_CANCELACONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CANCELACONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EstornoBaixaControleViagem of Service WSIntegracao

WSMETHOD EstornoBaixaControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lEstornoBaixaControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EstornoBaixaControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</EstornoBaixaControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/EstornoBaixaControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lEstornoBaixaControleViagemResult :=  WSAdvValue( oXmlRet,"_ESTORNOBAIXACONTROLEVIAGEMRESPONSE:_ESTORNOBAIXACONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ESTORNOBAIXACONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method QuitaContrato of Service WSIntegracao

WSMETHOD QuitaContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lQuitaContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<QuitaContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</QuitaContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/QuitaContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lQuitaContratoResult :=  WSAdvValue( oXmlRet,"_QUITACONTRATORESPONSE:_QUITACONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_QUITACONTRATORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_QUITACONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BaixaNotaFiscal of Service WSIntegracao

WSMETHOD BaixaNotaFiscal WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lBaixaNotaFiscalResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BaixaNotaFiscal xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</BaixaNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/BaixaNotaFiscal",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lBaixaNotaFiscalResult :=  WSAdvValue( oXmlRet,"_BAIXANOTAFISCALRESPONSE:_BAIXANOTAFISCALRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_BAIXANOTAFISCALRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_BAIXANOTAFISCALRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImpostoAdicionalInclui of Service WSIntegracao

WSMETHOD ImpostoAdicionalInclui WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lImpostoAdicionalIncluiResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImpostoAdicionalInclui xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ImpostoAdicionalInclui>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ImpostoAdicionalInclui",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lImpostoAdicionalIncluiResult :=  WSAdvValue( oXmlRet,"_IMPOSTOADICIONALINCLUIRESPONSE:_IMPOSTOADICIONALINCLUIRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_IMPOSTOADICIONALINCLUIRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BaixaDocumentacaoContrato of Service WSIntegracao

WSMETHOD BaixaDocumentacaoContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lBaixaDocumentacaoContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BaixaDocumentacaoContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</BaixaDocumentacaoContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/BaixaDocumentacaoContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lBaixaDocumentacaoContratoResult :=  WSAdvValue( oXmlRet,"_BAIXADOCUMENTACAOCONTRATORESPONSE:_BAIXADOCUMENTACAOCONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_BAIXADOCUMENTACAOCONTRATORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_BAIXADOCUMENTACAOCONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListaNotasFiscais of Service WSIntegracao

WSMETHOD ListaNotasFiscais WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lListaNotasFiscaisResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListaNotasFiscais xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ListaNotasFiscais>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ListaNotasFiscais",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lListaNotasFiscaisResult :=  WSAdvValue( oXmlRet,"_LISTANOTASFISCAISRESPONSE:_LISTANOTASFISCAISRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_LISTANOTASFISCAISRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_LISTANOTASFISCAISRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListaCuponsNotaFiscal of Service WSIntegracao

WSMETHOD ListaCuponsNotaFiscal WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lListaCuponsNotaFiscalResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListaCuponsNotaFiscal xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ListaCuponsNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ListaCuponsNotaFiscal",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lListaCuponsNotaFiscalResult :=  WSAdvValue( oXmlRet,"_LISTACUPONSNOTAFISCALRESPONSE:_LISTACUPONSNOTAFISCALRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_LISTACUPONSNOTAFISCALRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_LISTACUPONSNOTAFISCALRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AutorizaPagamento of Service WSIntegracao

WSMETHOD AutorizaPagamento WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lAutorizaPagamentoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AutorizaPagamento xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AutorizaPagamento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AutorizaPagamento",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAutorizaPagamentoResult :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTORESPONSE:_AUTORIZAPAGAMENTORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AutorizaPagamentoContratos of Service WSIntegracao

WSMETHOD AutorizaPagamentoContratos WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lAutorizaPagamentoContratosResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AutorizaPagamentoContratos xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AutorizaPagamentoContratos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AutorizaPagamentoContratos",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAutorizaPagamentoContratosResult :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTOCONTRATOSRESPONSE:_AUTORIZAPAGAMENTOCONTRATOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTOCONTRATOSRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_AUTORIZAPAGAMENTOCONTRATOSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ContratoConfirmaPagamento of Service WSIntegracao

WSMETHOD ContratoConfirmaPagamento WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lContratoConfirmaPagamentoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ContratoConfirmaPagamento xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ContratoConfirmaPagamento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ContratoConfirmaPagamento",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lContratoConfirmaPagamentoResult :=  WSAdvValue( oXmlRet,"_CONTRATOCONFIRMAPAGAMENTORESPONSE:_CONTRATOCONFIRMAPAGAMENTORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONTRATOCONFIRMAPAGAMENTORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlteraMotoristaControleViagem of Service WSIntegracao

WSMETHOD AlteraMotoristaControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lAlteraMotoristaControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AlteraMotoristaControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlteraMotoristaControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AlteraMotoristaControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAlteraMotoristaControleViagemResult :=  WSAdvValue( oXmlRet,"_ALTERAMOTORISTACONTROLEVIAGEMRESPONSE:_ALTERAMOTORISTACONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ALTERAMOTORISTACONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlteraVeiculoControleViagem of Service WSIntegracao

WSMETHOD AlteraVeiculoControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lAlteraVeiculoControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AlteraVeiculoControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlteraVeiculoControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AlteraVeiculoControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAlteraVeiculoControleViagemResult :=  WSAdvValue( oXmlRet,"_ALTERAVEICULOCONTROLEVIAGEMRESPONSE:_ALTERAVEICULOCONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ALTERAVEICULOCONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlteraDadosBancarios of Service WSIntegracao

WSMETHOD AlteraDadosBancarios WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lAlteraDadosBancariosResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AlteraDadosBancarios xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlteraDadosBancarios>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AlteraDadosBancarios",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAlteraDadosBancariosResult :=  WSAdvValue( oXmlRet,"_ALTERADADOSBANCARIOSRESPONSE:_ALTERADADOSBANCARIOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ALTERADADOSBANCARIOSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaControleViagem of Service WSIntegracao

WSMETHOD ConsultaControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaControleViagemResult :=  WSAdvValue( oXmlRet,"_CONSULTACONTROLEVIAGEMRESPONSE:_CONSULTACONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTACONTROLEVIAGEMRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTACONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ContratoVinculaDocumento of Service WSIntegracao

WSMETHOD ContratoVinculaDocumento WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lContratoVinculaDocumentoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ContratoVinculaDocumento xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ContratoVinculaDocumento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ContratoVinculaDocumento",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lContratoVinculaDocumentoResult :=  WSAdvValue( oXmlRet,"_CONTRATOVINCULADOCUMENTORESPONSE:_CONTRATOVINCULADOCUMENTORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONTRATOVINCULADOCUMENTORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SolicitaRoteiro of Service WSIntegracao

WSMETHOD SolicitaRoteiro WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lSolicitaRoteiroResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SolicitaRoteiro xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</SolicitaRoteiro>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/SolicitaRoteiro",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lSolicitaRoteiroResult :=  WSAdvValue( oXmlRet,"_SOLICITAROTEIRORESPONSE:_SOLICITAROTEIRORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_SOLICITAROTEIRORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CartaoTaxaAtivacao of Service WSIntegracao

WSMETHOD CartaoTaxaAtivacao WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lCartaoTaxaAtivacaoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CartaoTaxaAtivacao xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CartaoTaxaAtivacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/CartaoTaxaAtivacao",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lCartaoTaxaAtivacaoResult :=  WSAdvValue( oXmlRet,"_CARTAOTAXAATIVACAORESPONSE:_CARTAOTAXAATIVACAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CARTAOTAXAATIVACAORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CARTAOTAXAATIVACAORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlteraKmControleViagem of Service WSIntegracao

WSMETHOD AlteraKmControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lAlteraKmControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AlteraKmControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlteraKmControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AlteraKmControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAlteraKmControleViagemResult :=  WSAdvValue( oXmlRet,"_ALTERAKMCONTROLEVIAGEMRESPONSE:_ALTERAKMCONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_ALTERAKMCONTROLEVIAGEMRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ALTERAKMCONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PedidoCargaContratoInclui of Service WSIntegracao

WSMETHOD PedidoCargaContratoInclui WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lPedidoCargaContratoIncluiResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PedidoCargaContratoInclui xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</PedidoCargaContratoInclui>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/PedidoCargaContratoInclui",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lPedidoCargaContratoIncluiResult :=  WSAdvValue( oXmlRet,"_PEDIDOCARGACONTRATOINCLUIRESPONSE:_PEDIDOCARGACONTRATOINCLUIRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_PEDIDOCARGACONTRATOINCLUIRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_PEDIDOCARGACONTRATOINCLUIRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DocumentosBaixaAntecipada of Service WSIntegracao

WSMETHOD DocumentosBaixaAntecipada WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lDocumentosBaixaAntecipadaResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DocumentosBaixaAntecipada xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</DocumentosBaixaAntecipada>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/DocumentosBaixaAntecipada",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lDocumentosBaixaAntecipadaResult :=  WSAdvValue( oXmlRet,"_DOCUMENTOSBAIXAANTECIPADARESPONSE:_DOCUMENTOSBAIXAANTECIPADARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_DOCUMENTOSBAIXAANTECIPADARESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AgendamentoMarcacao of Service WSIntegracao

WSMETHOD AgendamentoMarcacao WSSEND cstrPatio,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lAgendamentoMarcacaoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AgendamentoMarcacao xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strPatio", ::cstrPatio, cstrPatio , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AgendamentoMarcacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AgendamentoMarcacao",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAgendamentoMarcacaoResult :=  WSAdvValue( oXmlRet,"_AGENDAMENTOMARCACAORESPONSE:_AGENDAMENTOMARCACAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_AGENDAMENTOMARCACAORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_AGENDAMENTOMARCACAORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelamentoAgendamentoMarcacao of Service WSIntegracao

WSMETHOD CancelamentoAgendamentoMarcacao WSSEND cstrPatio,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lCancelamentoAgendamentoMarcacaoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelamentoAgendamentoMarcacao xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strPatio", ::cstrPatio, cstrPatio , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CancelamentoAgendamentoMarcacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/CancelamentoAgendamentoMarcacao",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lCancelamentoAgendamentoMarcacaoResult :=  WSAdvValue( oXmlRet,"_CANCELAMENTOAGENDAMENTOMARCACAORESPONSE:_CANCELAMENTOAGENDAMENTOMARCACAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CANCELAMENTOAGENDAMENTOMARCACAORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegracaoErros of Service WSIntegracao

WSMETHOD IntegracaoErros WSSEND cstrCliente,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lIntegracaoErrosResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegracaoErros xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IntegracaoErros>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IntegracaoErros",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIntegracaoErrosResult :=  WSAdvValue( oXmlRet,"_INTEGRACAOERROSRESPONSE:_INTEGRACAOERROSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INTEGRACAOERROSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlteraDocumentoContrato of Service WSIntegracao

WSMETHOD AlteraDocumentoContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lAlteraDocumentoContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AlteraDocumentoContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlteraDocumentoContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AlteraDocumentoContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAlteraDocumentoContratoResult :=  WSAdvValue( oXmlRet,"_ALTERADOCUMENTOCONTRATORESPONSE:_ALTERADOCUMENTOCONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_ALTERADOCUMENTOCONTRATORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ALTERADOCUMENTOCONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlteraMotoristaContrato of Service WSIntegracao

WSMETHOD AlteraMotoristaContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lAlteraMotoristaContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AlteraMotoristaContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlteraMotoristaContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AlteraMotoristaContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAlteraMotoristaContratoResult :=  WSAdvValue( oXmlRet,"_ALTERAMOTORISTACONTRATORESPONSE:_ALTERAMOTORISTACONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ALTERAMOTORISTACONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EmiteDocumento of Service WSIntegracao

WSMETHOD EmiteDocumento WSSEND cstrCliente,cstrAssinaturaDigital,BYREF cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lEmiteDocumentoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EmiteDocumento xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</EmiteDocumento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/EmiteDocumento",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lEmiteDocumentoResult :=  WSAdvValue( oXmlRet,"_EMITEDOCUMENTORESPONSE:_EMITEDOCUMENTORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlIn          :=  WSAdvValue( oXmlRet,"_EMITEDOCUMENTORESPONSE:_STRXMLIN:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlIn,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_EMITEDOCUMENTORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelaDocumento of Service WSIntegracao

WSMETHOD CancelaDocumento WSSEND cstrCliente,cstrAssinaturaDigital,BYREF cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lCancelaDocumentoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelaDocumento xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CancelaDocumento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/CancelaDocumento",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lCancelaDocumentoResult :=  WSAdvValue( oXmlRet,"_CANCELADOCUMENTORESPONSE:_CANCELADOCUMENTORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlIn          :=  WSAdvValue( oXmlRet,"_CANCELADOCUMENTORESPONSE:_STRXMLIN:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlIn,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CANCELADOCUMENTORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IncluiCreditoLitrosControleViagem of Service WSIntegracao

WSMETHOD IncluiCreditoLitrosControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,BYREF cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lIncluiCreditoLitrosControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IncluiCreditoLitrosControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IncluiCreditoLitrosControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IncluiCreditoLitrosControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIncluiCreditoLitrosControleViagemResult :=  WSAdvValue( oXmlRet,"_INCLUICREDITOLITROSCONTROLEVIAGEMRESPONSE:_INCLUICREDITOLITROSCONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlIn          :=  WSAdvValue( oXmlRet,"_INCLUICREDITOLITROSCONTROLEVIAGEMRESPONSE:_STRXMLIN:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlIn,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INCLUICREDITOLITROSCONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EmiteOS of Service WSIntegracao

WSMETHOD EmiteOS WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lEmiteOSResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EmiteOS xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</EmiteOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/EmiteOS",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lEmiteOSResult     :=  WSAdvValue( oXmlRet,"_EMITEOSRESPONSE:_EMITEOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_EMITEOSRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_EMITEOSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelaOS of Service WSIntegracao

WSMETHOD CancelaOS WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lCancelaOSResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelaOS xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CancelaOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/CancelaOS",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lCancelaOSResult   :=  WSAdvValue( oXmlRet,"_CANCELAOSRESPONSE:_CANCELAOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CANCELAOSRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Versao of Service WSIntegracao

WSMETHOD Versao WSSEND NULLPARAM WSRECEIVE cVersaoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Versao xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += "</Versao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/Versao",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::cVersaoResult      :=  WSAdvValue( oXmlRet,"_VERSAORESPONSE:_VERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IncluirDebitoLitrosControleViagem of Service WSIntegracao

WSMETHOD IncluirDebitoLitrosControleViagem WSSEND cstrCliente,cstrAssinaturaDigital,BYREF cstrXmlIn,BYREF cstrXmlErr WSRECEIVE lIncluirDebitoLitrosControleViagemResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IncluirDebitoLitrosControleViagem xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IncluirDebitoLitrosControleViagem>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IncluirDebitoLitrosControleViagem",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIncluirDebitoLitrosControleViagemResult :=  WSAdvValue( oXmlRet,"_INCLUIRDEBITOLITROSCONTROLEVIAGEMRESPONSE:_INCLUIRDEBITOLITROSCONTROLEVIAGEMRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlIn          :=  WSAdvValue( oXmlRet,"_INCLUIRDEBITOLITROSCONTROLEVIAGEMRESPONSE:_STRXMLIN:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlIn,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INCLUIRDEBITOLITROSCONTROLEVIAGEMRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegraDadosCadastroInternacional of Service WSIntegracao

WSMETHOD IntegraDadosCadastroInternacional WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlInContratado,cstrXmlInMotorista,cstrXmlInVeiculo,cstrXmlInCarreta,BYREF cstrXmlErr WSRECEIVE lIntegraDadosCadastroInternacionalResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegraDadosCadastroInternacional xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInContratado", ::cstrXmlInContratado, cstrXmlInContratado , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInMotorista", ::cstrXmlInMotorista, cstrXmlInMotorista , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInVeiculo", ::cstrXmlInVeiculo, cstrXmlInVeiculo , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInCarreta", ::cstrXmlInCarreta, cstrXmlInCarreta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IntegraDadosCadastroInternacional>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IntegraDadosCadastroInternacional",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIntegraDadosCadastroInternacionalResult :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTROINTERNACIONALRESPONSE:_INTEGRADADOSCADASTROINTERNACIONALRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTROINTERNACIONALRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaCTe of Service WSIntegracao

WSMETHOD ConsultaCTe WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lConsultaCTeResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaCTe xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ConsultaCTe>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/ConsultaCTe",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lConsultaCTeResult :=  WSAdvValue( oXmlRet,"_CONSULTACTERESPONSE:_CONSULTACTERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_CONSULTACTERESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_CONSULTACTERESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method InterrompeContrato of Service WSIntegracao

WSMETHOD InterrompeContrato WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lInterrompeContratoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<InterrompeContrato xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</InterrompeContrato>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/InterrompeContrato",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lInterrompeContratoResult :=  WSAdvValue( oXmlRet,"_INTERROMPECONTRATORESPONSE:_INTERROMPECONTRATORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_INTERROMPECONTRATORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INTERROMPECONTRATORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegraDadosCadastroNacionalANTT of Service WSIntegracao

WSMETHOD IntegraDadosCadastroNacionalANTT WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlInContratado,cstrXmlInMotorista,cstrXmlInVeiculo,cstrXmlInCarreta,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lIntegraDadosCadastroNacionalANTTResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegraDadosCadastroNacionalANTT xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInContratado", ::cstrXmlInContratado, cstrXmlInContratado , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInMotorista", ::cstrXmlInMotorista, cstrXmlInMotorista , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInVeiculo", ::cstrXmlInVeiculo, cstrXmlInVeiculo , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlInCarreta", ::cstrXmlInCarreta, cstrXmlInCarreta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IntegraDadosCadastroNacionalANTT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/IntegraDadosCadastroNacionalANTT",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lIntegraDadosCadastroNacionalANTTResult :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTRONACIONALANTTRESPONSE:_INTEGRADADOSCADASTRONACIONALANTTRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTRONACIONALANTTRESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_INTEGRADADOSCADASTRONACIONALANTTRESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlteraPortadorCartao of Service WSIntegracao

WSMETHOD AlteraPortadorCartao WSSEND cstrCliente,cstrAssinaturaDigital,cstrXmlIn,BYREF cstrXmlOut,BYREF cstrXmlErr WSRECEIVE lAlteraPortadorCartaoResult WSCLIENT WSIntegracao
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AlteraPortadorCartao xmlns="http://www.repom.com.br/RepomIntegracaoWs/Integracao">'
cSoap += WSSoapValue("strCliente", ::cstrCliente, cstrCliente , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strAssinaturaDigital", ::cstrAssinaturaDigital, cstrAssinaturaDigital , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlIn", ::cstrXmlIn, cstrXmlIn , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlOut", ::cstrXmlOut, cstrXmlOut , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("strXmlErr", ::cstrXmlErr, cstrXmlErr , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AlteraPortadorCartao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.repom.com.br/RepomIntegracaoWs/Integracao/AlteraPortadorCartao",; 
	"DOCUMENT","http://www.repom.com.br/RepomIntegracaoWs/Integracao",,,; 
	"http://qa.repom.com.br/repomintegracaows/integracao/integracao.asmx")

::Init()
::lAlteraPortadorCartaoResult :=  WSAdvValue( oXmlRet,"_ALTERAPORTADORCARTAORESPONSE:_ALTERAPORTADORCARTAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cstrXmlOut         :=  WSAdvValue( oXmlRet,"_ALTERAPORTADORCARTAORESPONSE:_STRXMLOUT:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlOut,NIL) 
::cstrXmlErr         :=  WSAdvValue( oXmlRet,"_ALTERAPORTADORCARTAORESPONSE:_STRXMLERR:TEXT","string",NIL,NIL,NIL,NIL,@cstrXmlErr,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



