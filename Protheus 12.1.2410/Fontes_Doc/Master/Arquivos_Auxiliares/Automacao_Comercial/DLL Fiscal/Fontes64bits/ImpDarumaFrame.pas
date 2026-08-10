unit ImpDarumaFrame;

 //*****************************************************************************************
 //TrataTags -> As Tags não precisarão ser implementadas pois elas são baseadas nas flags da Daruma
 //o texto que o Protheus enviara contera a tag que irá direto para o comando da impressora
 //sem tratamento, como nas outras impressoras.
 //*****************************************************************************************

interface

uses
  Forms,  Dialogs,  ImpFiscMain,  ImpCheqMain,  Windows,  SysUtils,  classes,  LojxFun,
  FormSigtron,  IniFiles,  SIGDRCMLib_TLB,  Registry,  FileCtrl;

const
  pBuffSize = 200;

Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sigtron
///
  TImpDarumaFrameWork = class(TImpressoraFiscal)
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function AbreEcf:AnsiString; override;
    function FechaEcf:AnsiString; override;
    function LeituraX:AnsiString; override;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
    function RedZDado( MapaRes:AnsiString ):AnsiString; override;
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function PegaPDV:AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function LeAliquotas:AnsiString; override;
    function LeAliquotasISS:AnsiString; override;
    function LeCondPag:AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function Gaveta:AnsiString; override;
    function Status( Tipo:Integer; Texto:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function GravaCondPag( Condicao:AnsiString ):AnsiString; override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ): AnsiString; override;
    function PegaSerie:AnsiString; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString ;Vias:Integer; ImgQrCode: AnsiString):AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; Override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString):AnsiString; Override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; override;
    function DownMF( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override ;
    procedure AlimentaProperties; override;
    function HorarioVerao( Tipo:AnsiString ):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ): AnsiString; override;
    function GeraArquivoMFD(cDadoInicial, cDadoFinal, cTipoDownload, cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica, cChavePrivada: AnsiString; iUnicoArquivo: integer): AnsiString; Override;
    function CapturaBaseISSRedZ : AnsiString;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
    function AbreCNF(CPFCNPJ, Nome, Endereco : AnsiString): AnsiString; Override;
    function RecCNF( IndiceTot , Valor, ValorAcresc,ValorDesc : AnsiString): AnsiString; Override;
    function PgtoCNF( FrmPagto , Valor, InfoAdicional, ValorAcresc,ValorDesc : AnsiString): AnsiString; Override;
    function FechaCNF( Mensagem : AnsiString): AnsiString; Override;
  end;

  TImpDarumaFrameCV0909 = class(TImpDarumaFrameWork)
  public
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    //function DownMF( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override ;
  end;

Function TrataCupomNFiscal( StatusCupom : Integer): Integer;
Function CompNaoFiscalFW(sIndTotalizador,sCondicao,Valor,Texto : AnsiString) : AnsiString;
Function CompCredDebFW(sCOO,sCondicao,Valor,Texto : AnsiString) : Integer;
Function OpenDarumaFW( sPorta:AnsiString ) : AnsiString;
Function CloseDarumaFW : AnsiString;
Function TrataRetornoDarumaFW( var iRet:Integer ):AnsiString;
Function MsgErroDarumaFW( iIndice:Integer ):AnsiString;
Function Status_ImpressoraFW( lMensagem:Boolean ): Integer;
Function HabRetEstendido( nRespEstendida: Integer ) : AnsiString;
Function RegistroDarumaFW( sProduto1 , sProduto2, sProduto3, sProduto4 : AnsiString;  ValorChave : AnsiString ; Retorna : AnsiString = 'N' ): AnsiString;
Function RetornaInfoECFFW( pszIndiceInfo : AnsiString ; var pszRetorno : AnsiString ) : Integer;
Function TrataArq(cPathArq : AnsiString): Boolean;

/////---------------------------------------------------------------------------
implementation
var
  bOpened     : Boolean;
  fHandle     : THandle; //DarumaFrameWork
  lDescAcres  : Boolean = False;
  sMarca      : AnsiString;                         // Marca da ECF
  sPathEcfRegistry : AnsiString = 'C:\';            // Path da ECF no Registry
  sArqEcfDefault   : AnsiString = 'RETORNO.TXT';    // Arquivo Retorno
  sCaracterSep: AnsiString;

    //--------------------------------------
  // Funções DarumaFrameWork
  //--------------------------------------
  fFuncDaruma_FW_iCFAbrir_ECF_Daruma		: function (pszCPF: AnsiString; pszNome: AnsiString; pszEndereco: AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFAbrirPadrao_ECF_Daruma	: function (): Integer; StdCall;

  fFuncDaruma_FW_iCFVender_ECF_Daruma           : function (pszCargaTributaria:AnsiString; pszQuantidade:AnsiString; pszPrecoUnitario:AnsiString; pszTipoDescAcresc:AnsiString; pszValorDescAcresc:AnsiString; pszCodigoItem:AnsiString; pszUnidadeMedida:AnsiString; pszDescricaoItem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFVenderSemDesc_ECF_Daruma    : function (pszCargaTributaria:AnsiString; pszQuantidade:AnsiString; pszPrecoUnitario:AnsiString; pszCodigoItem:AnsiString; pszUnidadeMedida:AnsiString; pszDescricaoItem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFVenderResumido_ECF_Daruma   : function (pszCargaTributaria:AnsiString; pszPrecoUnitario:AnsiString; pszCodigoItem:AnsiString; pszDescricaoItem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFLancarAcrescimoItem_ECF_Daruma: function (pszNumItem:AnsiString; pszTipoDescAcresc:AnsiString; pszValorDescAcresc:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFLancarDescontoItem_ECF_Daruma: function (pszNumItem:AnsiString; pszTipoDescAcresc:AnsiString; pszValorDescAcresc:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFLancarAcrescimoUltimoItem_ECF_Daruma: function (pszTipoDescAcresc:AnsiString; pszValorDescAcresc:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFLancarDescontoUltimoItem_ECF_Daruma: function (pszTipoDescAcresc: AnsiString; pszValorDescAcresc:AnsiString): Integer; StdCall;

  fFuncDaruma_FW_iCFCancelarItem_ECF_Daruma     : function (pszNumItem: AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFCancelarUltimoItem_ECF_Daruma: function (): Integer; StdCall;

  fFuncDaruma_FW_iCFCancelarItemParcial_ECF_Daruma: function (pszNumItem:AnsiString;pszQuantidade: AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFCancelarUltimoItemParcial_ECF_Daruma: function (pszQuantidade: AnsiString): Integer; StdCall;

  fFuncDaruma_FW_iCFCancelarDescontoItem_ECF_Daruma: function (pszNumItem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFCancelarDescontoUltimoItem_ECF_Daruma: function (): Integer; StdCall;
  fFuncDaruma_FW_iCFCancelarAcrescimoItem_ECF_Daruma: function (pszNumItem:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_iCFCancelarAcrescimoUltimoItem_ECF_Daruma: function ():Integer; StdCall;

  fFuncDaruma_FW_iCFTotalizarCupom_ECF_Daruma   : function (pszTipoDescAcresc:AnsiString; pszValorDescAcresc:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFTotalizarCupomPadrao_ECF_Daruma: function (): Integer; StdCall;

  fFuncDaruma_FW_iCFCancelarDescontoSubtotal_ECF_Daruma : function (): Integer; StdCall;
  fFuncDaruma_FW_iCFCancelarAcrescimoSubtotal_ECF_Daruma: function (): Integer; StdCall;

  fFuncDaruma_FW_iCFEfetuarPagamentoPadrao_ECF_Daruma   : function (): Integer; StdCall;
  fFuncDaruma_FW_iCFEfetuarPagamentoFormatado_ECF_Daruma: function (pszFormaPgto:AnsiString; pszValor:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFEfetuarPagamento_ECF_Daruma         : function (pszFormaPgto:AnsiString;pszValor:AnsiString;pszInfoAdicional:AnsiString): Integer; StdCall;

  fFuncDaruma_FW_iCFEncerrar_ECF_Daruma                 : function (pszCupomAdicional:AnsiString;pszMensagem:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_iCFEncerrarPadrao_ECF_Daruma           : function (): Integer; StdCall;
  fFuncDaruma_FW_iCFEncerrarConfigMsg_ECF_Daruma        : function (pszMensagem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCFEncerrarResumido_ECF_Daruma         : function (): Integer; StdCall;
  fFuncDaruma_FW_iCFEmitirCupomAdicional_ECF_Daruma     : function (): Integer; StdCall;

  fFuncDaruma_FW_iCFCancelar_ECF_Daruma                 : function : Integer; StdCall;

  fFuncDaruma_FW_iCFIdentificarConsumidor_ECF_Daruma    : function (pszNome:AnsiString;pszEndereco:AnsiString; pszDoc:AnsiString): Integer; StdCall;

  fFuncDaruma_FW_iEstornarPagamento_ECF_Daruma          : function (pszFormaPgtoEstornado:AnsiString;pszFormaPgtoEfetivado:AnsiString;pszValor:AnsiString;pszInfoAdicional:AnsiString): Integer; StdCall;

  fFuncDaruma_FW_iCCDAbrir_ECF_Daruma                   : function (pszFormaPgto:AnsiString;pszParcelas:AnsiString;pszDocOrigem:AnsiString;pszValor:AnsiString;pszCPF:AnsiString;pszNome:AnsiString;pszEndereco:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCCDAbrirSimplificado_ECF_Daruma       : function (pszFormaPgto:AnsiString; pszParcelas:AnsiString;pszDocOrigem:AnsiString;pszValor: AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCCDAbrirPadrao_ECF_Daruma             : function (): Integer; StdCall;
  fFuncDaruma_FW_iCCDImprimirTexto_ECF_Daruma           : function (pszTexto:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCCDImprimirArquivo_ECF_Daruma         : function (pszArqOrigem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCCDFechar_ECF_Daruma                  : function (): Integer; StdCall;

  fFuncDaruma_FW_iCCDSegundaVia_ECF_Daruma              : function (): Integer; StdCall;

  fFuncDaruma_FW_iCCDEstornarPadrao_ECF_Daruma          : function (): Integer; StdCall;
  fFuncDaruma_FW_iCCDEstornar_ECF_Daruma                : function (pszCOO:AnsiString;pszCPF:AnsiString; pszNome:AnsiString; pszEndereco:AnsiString): Integer; StdCall;

  //TEF
  fFuncDaruma_FW_iTEF_ImprimirResposta_ECF_Daruma       : function (szArquivo:AnsiString; bTravarTeclado:Boolean):Integer; StdCall;
  fFuncDaruma_FW_iTEF_ImprimirRespostaCartao_ECF_Daruma : function (szArquivo:AnsiString; bTravarTeclado:Boolean; szForma:AnsiString; szValor:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_iTEF_Fechar_ECF_Daruma                 : function (): Integer; StdCall;
  fFuncDaruma_FW_eTEF_EsperarArquivo_ECF_Daruma         : function (szArquivo: AnsiString; iTempo:integer; bTravar:Boolean): Integer; StdCall;
  fFuncDaruma_FW_eTEF_TravarTeclado_ECF_Daruma          : function (bTravar:Boolean):Integer; StdCall;
  fFuncDaruma_FW_eTEF_SetarFoco_ECF_Daruma              : function (szNomeTela:AnsiString):Integer; StdCall;

  fFuncDaruma_FW_iCNFAbrir_ECF_Daruma                   : function (pszCPF:AnsiString; pszNome:AnsiString;pszEndereco:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFAbrirPadrao_ECF_Daruma             : function (): Integer; StdCall;

  fFuncDaruma_FW_iCNFReceber_ECF_Daruma                 : function (pszIndice:AnsiString;pszValor:AnsiString;pszTipoDescAcresc:AnsiString;pszValorDescAcresc:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFReceberSemDesc_ECF_Daruma          : function (pszIndice:AnsiString;pszValor:AnsiString): Integer; StdCall;

  fFuncDaruma_FW_iCNFCancelarItem_ECF_Daruma            : function (pszNumItem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFCancelarUltimoItem_ECF_Daruma      : function (): Integer; StdCall;

  fFuncDaruma_FW_iCNFCancelarAcrescimoItem_ECF_Daruma   : function (pszNumItem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFCancelarAcrescimoUltimoItem_ECF_Daruma : function (): Integer; StdCall;

  fFuncDaruma_FW_iCNFCancelarDescontoItem_ECF_Daruma    : function (pszNumItem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFCancelarDescontoUltimoItem_ECF_Daruma : function (): Integer; StdCall;

  fFuncDaruma_FW_iCNFTotalizarComprovante_ECF_Daruma    : function (pszTipoDescAcresc:AnsiString;pszValorDescAcresc:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFTotalizarComprovantePadrao_ECF_Daruma: function (): Integer; StdCall;

  fFuncDaruma_FW_iCNFCancelarAcrescimoSubtotal_ECF_Daruma: function (): Integer; StdCall;
  fFuncDaruma_FW_iCNFCancelarDescontoSubtotal_ECF_Daruma : function (): Integer; StdCall;

  fFuncDaruma_FW_iCNFEfetuarPagamento_ECF_Daruma        : function (pszFormaPgto:AnsiString;pszValor:AnsiString;pszInfoAdicional:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFEfetuarPagamentoFormatado_ECF_Daruma: function (pszFormaPgto:AnsiString;pszValor:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFEfetuarPagamentoPadrao_ECF_Daruma  : function (): Integer; StdCall;

  fFuncDaruma_FW_iCNFEncerrar_ECF_Daruma                : function (pszMensagem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iCNFEncerrarPadrao_ECF_Daruma          : function (): Integer; StdCall;

  fFuncDaruma_FW_iCNFCancelar_ECF_Daruma                : function (): Integer; StdCall;

  fFuncDaruma_FW_iRGAbrir_ECF_Daruma                    : function (pszNomeRG:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iRGAbrirIndice_ECF_Daruma              : function (iIndiceRG:Integer): Integer; StdCall;
  fFuncDaruma_FW_iRGAbrirPadrao_ECF_Daruma              : function (): Integer; StdCall;
  fFuncDaruma_FW_iRGImprimirTexto_ECF_Daruma            : function (pszTexto:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iRGFechar_ECF_Daruma                   : function (): Integer; StdCall;
  fFuncDaruma_FW_iRGImprimirArquivo_ECF_Daruma          : function (pszArquivo : AnsiString ) : Integer; StdCall;

  fFuncDaruma_FW_iLeituraX_ECF_Daruma                   : function : Integer; StdCall;
  fFuncDaruma_FW_rLeituraX_ECF_Daruma                   : function : Integer; StdCall;
  fFuncDaruma_FW_rLeituraXCustomizada_ECF_Daruma        : function (pszCaminho:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iReducaoZ_ECF_Daruma                   : function (pszData:AnsiString; pszHora:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iSangriaPadrao_ECF_Daruma              : function (): Integer; StdCall;
  fFuncDaruma_FW_iSangria_ECF_Daruma                    : function (pszValor:AnsiString; pszMensagem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iSuprimentoPadrao_ECF_Daruma           : function (): Integer; StdCall;
  fFuncDaruma_FW_iSuprimento_ECF_Daruma                 : function (pszValor:AnsiString; pszMensagem:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rGerarMapaResumo_ECF_Daruma            : function (): Integer; StdCall;

  fFuncDaruma_FW_iMFLerSerial_ECF_Daruma                : function (pszInicial:AnsiString; pszFinal:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_iMFLer_ECF_Daruma                      : function (pszInicial:AnsiString; pszFinal:AnsiString): Integer; StdCall;

  fFuncDaruma_FW_iAutenticarDocumento_DUAL_DarumaFramework : function(stTexto: AnsiString; stLocal: AnsiString; stTimeOut: AnsiString): Integer; StdCall;

  //Programação do ECF
  fFuncDaruma_FW_confCadastrarPadrao_ECF_Daruma         : function (pszCadastrar:AnsiString;pszValor:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_confCadastrar_ECF_Daruma               : function (pszCadastrar:AnsiString;pszValor:AnsiString;pszSeparador:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_confHabilitarHorarioVerao_ECF_Daruma   : function (): Integer; StdCall;
  fFuncDaruma_FW_confDesabilitarHorarioVerao_ECF_Daruma : function (): Integer; StdCall;
  fFuncDaruma_FW_confProgramarOperador_ECF_Daruma       : function (pszValor:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_confProgramarIDLoja_ECF_Daruma         : function (pszValor:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_confProgramarAvancoPapel_ECF_Daruma    : function (pszSepEntreLinhas:AnsiString;pszSepEntreDoc:AnsiString;pszLinhasGuilhotina:AnsiString;pszGuilhotina:AnsiString;pszImpClicheAntecipada:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_confHabilitarModoPreVenda_ECF_Daruma   : function (): Integer; StdCall;
  fFuncDaruma_FW_confDesabilitarModoPreVenda_ECF_Daruma : function (): Integer; StdCall;

  //Retornos e Status do ECF
  //Retornos
  fFuncDaruma_FW_rRetornarInformacao_ECF_Daruma         : function (pszIndice:AnsiString;pszRetornar:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rLerAliquotas_ECF_Daruma               : function (cAliquotas:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rLerMeiosPagto_ECF_Daruma              : function (pszRelatorios:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rLerRG_ECF_Daruma                      : function (pszRelatorios:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rLerCNF_ECF_Daruma                     : function (pszRelatorios:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rLerDecimais_ECF_Daruma                : function (pszDecimalQtde:AnsiString;pszDecimalValor:AnsiString;var piDecimalQtde:Integer; var piDecimalValor:Integer): Integer; StdCall;
  fFuncDaruma_FW_rLerDecimaisInt_ECF_Daruma             : function (piDecimalQtde:integer;piDecimalValor:integer): Integer; StdCall;
  fFuncDaruma_FW_rLerDecimaisStr_ECF_Daruma              : function (pszDecimalQtde:AnsiString;pszDecimalValor:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rDataHoraImpressora_ECF_Daruma         : function (pszData:AnsiString;pszHora:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rVerificarImpressoraLigada_ECF_Daruma  : function (): Integer; StdCall;
  fFuncDaruma_FW_rVerificarReducaoZ_ECF_Daruma          : function (zPendente:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rRetornarDadosReducaoZ_ECF_Daruma      : function (pszDados:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rRetornarVendaBruta_ECF_Daruma         : function (pszRetorno: AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rRetornarVendaLiquida_ECF_Daruma       : function (pszVendaLiquida: AnsiString): Integer; StdCall;

  //Status
  fFuncDaruma_FW_rStatusImpressora_ECF_Daruma           : function (pszStatus:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rInfoEstendida_ECF_Daruma              : function (var int:integer; char:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rInfoEstendida1_ECF_Daruma             : function (cInfoEx:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rInfoEstendida2_ECF_Daruma             : function (cInfoEx:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rInfoEstendida3_ECF_Daruma             : function (cInfoEx:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rInfoEstendida4_ECF_Daruma             : function (cInfoEx:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rInfoEstendida5_ECF_Daruma             : function (cInfoEx:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rStatusUltimoCmd_ECF_Daruma            : function (pszErro:AnsiString;pszAviso:AnsiString;var piErro:SmallInt;var piAviso:SmallInt): Integer; StdCall;
  fFuncDaruma_FW_rStatusUltimoCmdInt_ECF_Daruma         : function (var piErro:SmallInt;var piAviso:SmallInt): Integer; StdCall;
  fFuncDaruma_FW_rStatusUltimoCmdStr_ECF_Daruma         : function (cErro:AnsiString;cAviso:AnsiString): Integer; StdCall;

  //Status Cupom Fiscal
  fFuncDaruma_FW_rCFVerificarStatus_ECF_Daruma          : function (pszStatus:AnsiString; var piStatus:Integer): Integer; StdCall;
  fFuncDaruma_FW_rCFVerificarStatusInt_ECF_Daruma       : function (var iStatusCF:Integer): Integer; StdCall;
  fFuncDaruma_FW_rCFVerificarStatusStr_ECF_Daruma       : function (cStatusCF:AnsiString): Integer; StdCall;

  //Saldo a Pagar
  fFuncDaruma_FW_rCFSaldoAPagar_ECF_Daruma              : function (pszValor:AnsiString):Integer; StdCall;

  //Subtotal Cupom Fiscal
  fFuncDaruma_FW_rCFSubTotal_ECF_Daruma                 : function (pszValor:AnsiString):Integer; StdCall;

  //Gaveta, Autentica e Outros
  //Gaveta
  fFuncDaruma_FW_eAbrirGaveta_ECF_Daruma                : function (): Integer; StdCall;

  //Guilhotina
  fFuncDaruma_FW_eAcionarGuilhotina_ECF_Daruma          : function (pszTipoCorte:AnsiString): Integer; StdCall;

  //Código de Barras
  fFuncDaruma_FW_iImprimirCodigoBarras_ECF_Daruma       :function(pszTipo:AnsiString; pszLargura:AnsiString; pszAltura:AnsiString; pszImprTexto:AnsiString; pszCodigo:AnsiString; pszOrientacao:AnsiString; pszTextoLivre:AnsiString): Integer; StdCall;

  //Registry
  //Registry Cupom Fiscal
  fFuncDaruma_FW_regCFCupomAdicional_ECF_Daruma         : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFCupomAdicionalDllConfig_ECF_Daruma: function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFCupomAdicionalDllTitulo_ECF_Daruma: function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFCupomMania_ECF_Daruma             : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFFormaPgto_ECF_Daruma              : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFMensagemPromocional_ECF_Daruma    : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFQuantidade_ECF_Daruma             : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFTamanhoMinimoDescricao_ECF_Daruma : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFTipoDescAcresc_ECF_Daruma         : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFUnidadeMedida_ECF_Daruma          : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCFValorDescAcresc_ECF_Daruma        : function (pszParametro:AnsiString):Integer; StdCall;

  //Registry CCD
  fFuncDaruma_FW_regCCDDocOrigem_ECF_Daruma             : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCCDFormaPgto_ECF_Daruma             : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCCDLinhasTEF_ECF_Daruma             : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCCDParcelas_ECF_Daruma              : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regCCDValor_ECF_Daruma                 : function (pszParametro:AnsiString):Integer; StdCall;

  //Registry Cheque
  fFuncDaruma_FW_regChequeXLinha1_ECF_Daruma            : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regChequeXLinha2_ECF_Daruma            : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regChequeXLinha3_ECF_Daruma            : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regChequeYLinha1_ECF_Daruma            : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regChequeYLinha2_ECF_Daruma            : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regChequeYLinha3_ECF_Daruma            : function (pszParametro:AnsiString):Integer; StdCall;

  //Registry Compatibilidade
  fFuncDaruma_FW_regCompatibilidadeStatusFuncao_ECF_Daruma: function (pszParametro:AnsiString):Integer; StdCall;

  //Registry Sintegra
  fFuncDaruma_FW_regSintegra_ECF_Daruma                 : function (pszChave:AnsiString;pszValor:AnsiString):Integer; StdCall;

  //Registry Gerais
  fFuncDaruma_FW_regAlterarValor_Daruma                 : function (pszPathChave:AnsiString;pszValor:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regRetornaValorChave_DarumaFramework   : function (pszProduto:AnsiString;pszChave:AnsiString;pszValor:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regRetornaValorChave                   : function (pszProduto:AnsiString;pszChave:AnsiString;pszValor:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regLogin                               : function (pszPDV:AnsiString):Integer; StdCall;

  //Registry ECF
  fFuncDaruma_FW_regECFAguardarImpressao_ECF_Daruma     : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regECFArquivoLeituraX_ECF_Daruma       : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regECFAuditoria_ECF_Daruma             : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regECFCaracterSeparador_ECF_Daruma     : function (pszParametro:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_regECFMaxFechamentoAutomatico_ECF_Daruma: function (pszParametro:AnsiString):Integer; StdCall;

  //Geração Arquivos
  //Espelho MFD PAF-ECF
  fFuncDaruma_FW_rGerarEspelhoMFD_ECF_Daruma            : function (pszTipo:AnsiString; pszInicial:AnsiString;pszFinal:AnsiString): Integer; StdCall;

  //Relatório PAF-ECF ON-line
  fFuncDaruma_FW_rGerarRelatorio_ECF_Daruma             : function (szRelatorio:AnsiString; szTipo:AnsiString; szInicial:AnsiString; szFinal:AnsiString): Integer; StdCall;

  //Relatório PAF-ECF Off-line
  fFuncDaruma_FW_rGerarRelatorioOffline_ECF_Daruma      : function (szRelatorio:AnsiString; szTipo:AnsiString; szInicial:AnsiString; szFinal:AnsiString; szArquivo_MF:AnsiString; szArquivo_MFD:AnsiString; szArquivo_INF:AnsiString): Integer; StdCall;

  //Download Memórias
  fFuncDaruma_FW_rEfetuarDownloadMFD_ECF_Daruma         : function (pszTipo:AnsiString;pszInicial:AnsiString;pszFinal:AnsiString;pszNomeArquivo:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rEfetuarDownloadMF_ECF_Daruma          : function (pszNomeArquivo:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rEfetuarDownloadTDM_ECF_Daruma         : function (pszTipo:AnsiString; pszInicial:AnsiString;pszFinal:AnsiString;pszNomeArquivo:AnsiString): Integer; StdCall;

  //PAF-ECF
  //RSA - EAD PAF-ECF
  fFuncDaruma_FW_rAssinarRSA_ECF_Daruma                 : function (pszPathArquivo:AnsiString;pszChavePrivada:AnsiString;pszAssinaturaGerada:AnsiString): Integer; StdCall;

  //MD5
  fFuncDaruma_FW_rCalcularMD5_ECF_Daruma                : function (pszPathArquivo:AnsiString;pszMD5GeradoHex:AnsiString;pszMD5GeradoAscii:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rRetornarNumeroSerieCodificado_ECF_Daruma: function (pszSerialCriptografado:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rVerificarNumeroSerieCodificado_ECF_Daruma: function (pszSerialCriptografado:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rRetornarGTCodificado_ECF_Daruma       : function (pszGTCodificado:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rVerificarGTCodificado_ECF_Daruma      : function (pszGTCodificado:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_rCodigoModeloFiscal_ECF_Daruma         : function (szCodModelo:AnsiString): Integer; StdCall;

  //MENU-FISCAL
  //ESPECIAIS
  fFuncDaruma_FW_eAguardarCompactacao_ECF_Daruma        : function (): Integer; StdCall;
  fFuncDaruma_FW_eBuscarPortaVelocidade_ECF_Daruma      : function (): Integer; StdCall;
  fFuncDaruma_FW_eEnviarComando_ECF_Daruma              : function (cComando:AnsiString;var intiTamanhoComando:integer; var intiType:integer): Integer; StdCall;
  fFuncDaruma_FW_eRetornarAviso_ECF_Daruma              : function (): Integer; StdCall;
  fFuncDaruma_FW_eRetornarErro_ECF_Daruma               : function (): Integer; StdCall;
  fFuncDaruma_FW_eAuditar_Daruma                        : function (cAuditoria:AnsiString;var intiFlag:integer): Integer; StdCall;
  fFuncDaruma_FW_eDefinirProduto_Daruma                 : function (pszProduto:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_eDefinirModoRegistro_Daruma            : function (intiTipo:integer): Integer; StdCall;
  fFuncDaruma_FW_eVerificarVersaoDLL_Daruma             : function (pszRet:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_eVerificarVersaoDLL                    : function (pszRet:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_eInterpretarErro_ECF_Daruma            : function (iIndice:Integer; pszRetorno:AnsiString): Integer; StdCall;
  fFuncDaruma_FW_eInterpretarAviso_ECF_Daruma           : function (iIndice:Integer; pszRetorno:AnsiString): Integer; StdCall;
  ffuncDaruma_FW_eMemoriaFiscal_ECF_Daruma              : function (pszInicial:AnsiString; pszFinal:AnsiString; pszCompleta: Boolean; pszTipo:AnsiString):Integer; StdCall;
  fFuncDaruma_FW_eInterpretarRetorno_ECF_Daruma         : function (iIndice: Integer; pszRetorno: AnsiString): Integer; StdCall;
  fFuncDaruma_FW_eGerarQrCodeArquivo_DUAL_Daruma        : function ( pszPath , pszDados : AnsiString) : Integer; StdCall;
  fFuncDaruma_FW_eCarregarBitmapPromocional_ECF_Daruma  : function ( pszPathLogotipo , pszNumBitmap, pszOrientacao : AnsiString): Integer; StdCall;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
Function OpenDarumaFW( sPorta:AnsiString ) : AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: DarumaFrameWork.dll'+#13+
                  '(Atualize a DLL do Fabricante do ECF)');

      GravaLog('A função "'+sMsg+'" não existe na Dll: DarumaFrameWork.dll');
      Result := False;
    end
    else
      Result := True;
  end;
var
  aFunc: Pointer;
  iRet : Integer;
  bRet : Boolean;
  pTempPath  : PChar;
  sTempPath,sRetorno,sVelocidade,sIni : AnsiString;
  ListaArq : TStringList;
  BufferTemp : Array[0..144] of Char;
begin
    bRet     := True;
    fHandle  := LoadLibrary( 'DarumaFrameWork.dll' );
    sRetorno := '0';

    // Indica a possibilidade da utilização
    // via ActiveX portanto faz uma nova verificação.
    If (fHandle = 0) Then
    Begin
        GetTempPath(144,BufferTemp);
        sTempPath := trim(StrPas(BufferTemp))+'DarumaFrameWork.dll';
        pTempPath := PChar(sTempPath);
        fHandle   := LoadLibrary( pTempPath );
    End;

    if (fHandle <> 0) Then
    begin
      aFunc := GetProcAddress(fHandle,'iCCDEstornar_ECF_Daruma');
      if ValidPointer(aFunc, 'iCCDEstornar_ECF_Daruma')
      then fFuncDaruma_FW_iCCDEstornar_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iCCDEstornarPadrao_ECF_Daruma');
      if ValidPointer(aFunc, 'iCCDEstornarPadrao_ECF_Daruma')
      then fFuncDaruma_FW_iCCDEstornarPadrao_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iCCDFechar_ECF_Daruma');
      if ValidPointer(aFunc, 'iCCDFechar_ECF_Daruma')
      then fFuncDaruma_FW_iCCDFechar_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iCCDImprimirTexto_ECF_Daruma');
      if ValidPointer(aFunc, 'iCCDImprimirTexto_ECF_Daruma')
      then fFuncDaruma_FW_iCCDImprimirTexto_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iCCDAbrirSimplificado_ECF_Daruma');
      if ValidPointer(aFunc, 'iCCDAbrirSimplificado_ECF_Daruma')
      then fFuncDaruma_FW_iCCDAbrirSimplificado_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iCCDAbrirPadrao_ECF_Daruma');
      if ValidPointer(aFunc, 'iCCDAbrirPadrao_ECF_Daruma')
      then fFuncDaruma_FW_iCCDAbrirPadrao_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarItem_ECF_Daruma');
      if ValidPointer( aFunc , 'iCFCancelarItem_ECF_Daruma')
      then fFuncDaruma_FW_iCFCancelarItem_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFAbrir_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFAbrir_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFAbrir_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFAbrirPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFAbrirPadrao_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFAbrirPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFVender_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFVender_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFVender_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFVenderSemDesc_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFVenderSemDesc_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFVenderSemDesc_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFVenderResumido_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFVenderResumido_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFVenderResumido_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFLancarAcrescimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFLancarAcrescimoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFLancarAcrescimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFLancarDescontoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFLancarDescontoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFLancarDescontoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFLancarAcrescimoUltimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFLancarAcrescimoUltimoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFLancarAcrescimoUltimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFLancarDescontoUltimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFLancarDescontoUltimoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFLancarDescontoUltimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarUltimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarUltimoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarUltimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarItemParcial_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarItemParcial_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarItemParcial_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarUltimoItemParcial_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarUltimoItemParcial_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarUltimoItemParcial_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarDescontoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarDescontoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarDescontoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarDescontoUltimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarDescontoUltimoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarDescontoUltimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarAcrescimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarAcrescimoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarAcrescimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarAcrescimoUltimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarAcrescimoUltimoItem_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarAcrescimoUltimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFTotalizarCupom_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFTotalizarCupom_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFTotalizarCupom_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFTotalizarCupomPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFTotalizarCupomPadrao_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFTotalizarCupomPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarDescontoSubtotal_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarDescontoSubtotal_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarDescontoSubtotal_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelarAcrescimoSubtotal_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelarAcrescimoSubtotal_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFCancelarAcrescimoSubtotal_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFEfetuarPagamentoPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFEfetuarPagamentoPadrao_ECF_Daruma' ) then
        fFuncDaruma_FW_iCFEfetuarPagamentoPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFEfetuarPagamentoFormatado_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFEfetuarPagamentoFormatado_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFEfetuarPagamentoFormatado_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFEfetuarPagamento_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFEfetuarPagamento_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFEfetuarPagamento_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFEncerrar_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFEncerrar_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFEncerrar_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFEncerrarPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFEncerrarPadrao_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFEncerrarPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFEncerrarConfigMsg_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFEncerrarConfigMsg_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFEncerrarConfigMsg_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFEncerrarResumido_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFEncerrarResumido_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFEncerrarResumido_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFEmitirCupomAdicional_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFEmitirCupomAdicional_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFEmitirCupomAdicional_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFCancelar_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFCancelar_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFCancelar_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCFIdentificarConsumidor_ECF_Daruma');
      if ValidPointer( aFunc, 'iCFIdentificarConsumidor_ECF_Daruma' ) then
          fFuncDaruma_FW_iCFIdentificarConsumidor_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iEstornarPagamento_ECF_Daruma');
      if ValidPointer( aFunc, 'iEstornarPagamento_ECF_Daruma' ) then
          fFuncDaruma_FW_iEstornarPagamento_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCCDAbrir_ECF_Daruma');
      if ValidPointer( aFunc, 'iCCDAbrir_ECF_Daruma' )
      then fFuncDaruma_FW_iCCDAbrir_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'eTEF_EsperarArquivo_ECF_Daruma');
      if ValidPointer( aFunc, 'eTEF_EsperarArquivo_ECF_Daruma' ) then
          fFuncDaruma_FW_eTEF_EsperarArquivo_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'eTEF_TravarTeclado_ECF_Daruma');
      if ValidPointer( aFunc, 'eTEF_TravarTeclado_ECF_Daruma' ) then
          fFuncDaruma_FW_eTEF_TravarTeclado_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'eTEF_SetarFoco_ECF_Daruma');
      if ValidPointer( aFunc, 'eTEF_SetarFoco_ECF_Daruma' ) then
          fFuncDaruma_FW_eTEF_SetarFoco_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFAbrir_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFAbrir_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFAbrir_ECF_Daruma := aFunc
      else
        bRet := False;


      aFunc := GetProcAddress(fHandle,'iCNFAbrirPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFAbrirPadrao_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFAbrirPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFReceber_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFReceber_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFReceber_ECF_Daruma := aFunc
      else
        bRet := False;
 
      aFunc := GetProcAddress(fHandle,'iCNFReceberSemDesc_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFReceberSemDesc_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFReceberSemDesc_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelarItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelarItem_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelarItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelarUltimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelarUltimoItem_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelarUltimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelarAcrescimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelarAcrescimoItem_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelarAcrescimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelarAcrescimoUltimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelarAcrescimoUltimoItem_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelarAcrescimoUltimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelarDescontoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelarDescontoItem_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelarDescontoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelarDescontoUltimoItem_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelarDescontoUltimoItem_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelarDescontoUltimoItem_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFTotalizarComprovante_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFTotalizarComprovante_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFTotalizarComprovante_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFTotalizarComprovantePadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFTotalizarComprovantePadrao_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFTotalizarComprovantePadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelarAcrescimoSubtotal_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelarAcrescimoSubtotal_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelarAcrescimoSubtotal_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelarDescontoSubtotal_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelarDescontoSubtotal_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelarDescontoSubtotal_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFEfetuarPagamento_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFEfetuarPagamento_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFEfetuarPagamento_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFEfetuarPagamentoFormatado_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFEfetuarPagamentoFormatado_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFEfetuarPagamentoFormatado_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFEfetuarPagamentoPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFEfetuarPagamentoPadrao_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFEfetuarPagamentoPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFEncerrar_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFEncerrar_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFEncerrar_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFEncerrarPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFEncerrarPadrao_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFEncerrarPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iCNFCancelar_ECF_Daruma');
      if ValidPointer( aFunc, 'iCNFCancelar_ECF_Daruma' ) then
          fFuncDaruma_FW_iCNFCancelar_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iRGAbrir_ECF_Daruma');
      if ValidPointer( aFunc, 'iRGAbrir_ECF_Daruma' ) then
          fFuncDaruma_FW_iRGAbrir_ECF_Daruma := aFunc
      else
        bRet := False;


      aFunc := GetProcAddress(fHandle,'iRGAbrirIndice_ECF_Daruma');
      if ValidPointer( aFunc, 'iRGAbrirIndice_ECF_Daruma' ) then
          fFuncDaruma_FW_iRGAbrirIndice_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iRGAbrirPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iRGAbrirPadrao_ECF_Daruma' ) then
          fFuncDaruma_FW_iRGAbrirPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iRGImprimirTexto_ECF_Daruma');
      if ValidPointer( aFunc, 'iRGImprimirTexto_ECF_Daruma' ) then
          fFuncDaruma_FW_iRGImprimirTexto_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iRGFechar_ECF_Daruma');
      if ValidPointer( aFunc, 'iRGFechar_ECF_Daruma' ) then
          fFuncDaruma_FW_iRGFechar_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle , 'iRGImprimirArquivo_ECF_Daruma');
      if ValidPointer( aFunc , 'iRGImprimirArquivo_ECF_Daruma')
      then fFuncDaruma_FW_iRGImprimirArquivo_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iLeituraX_ECF_Daruma');
      if ValidPointer( aFunc, 'iLeituraX_ECF_Daruma' ) then
          fFuncDaruma_FW_iLeituraX_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rLeituraX_ECF_Daruma');
      if ValidPointer( aFunc, 'rLeituraX_ECF_Daruma' ) then
        fFuncDaruma_FW_rLeituraX_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rLeituraXCustomizada_ECF_Daruma');
      if ValidPointer( aFunc, 'rLeituraXCustomizada_ECF_Daruma' ) then
        fFuncDaruma_FW_rLeituraXCustomizada_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iReducaoZ_ECF_Daruma');
      if ValidPointer( aFunc, 'iReducaoZ_ECF_Daruma' ) then
        fFuncDaruma_FW_iReducaoZ_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iSangriaPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iSangriaPadrao_ECF_Daruma' ) then
        fFuncDaruma_FW_iSangriaPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iSangria_ECF_Daruma');
      if ValidPointer( aFunc, 'iSangria_ECF_Daruma' ) then
        fFuncDaruma_FW_iSangria_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iSuprimentoPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'iSuprimentoPadrao_ECF_Daruma' ) then
        fFuncDaruma_FW_iSuprimentoPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iSuprimento_ECF_Daruma');
      if ValidPointer( aFunc, 'iSuprimento_ECF_Daruma' ) then
        fFuncDaruma_FW_iSuprimento_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rGerarMapaResumo_ECF_Daruma');
      if ValidPointer( aFunc , 'rGerarMapaResumo_ECF_Daruma') then
         fFuncDaruma_FW_rGerarMapaResumo_ECF_Daruma := aFunc
      else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'iMFLerSerial_ECF_Daruma');
      if ValidPointer( aFunc, 'iMFLerSerial_ECF_Daruma' ) then
        fFuncDaruma_FW_iMFLerSerial_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iMFLer_ECF_Daruma');
      if ValidPointer( aFunc, 'iMFLer_ECF_Daruma' ) then
        fFuncDaruma_FW_iMFLer_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'iAutenticarDocumento_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'iAutenticarDocumento_DUAL_DarumaFramework')
      then fFuncDaruma_FW_iAutenticarDocumento_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'confCadastrarPadrao_ECF_Daruma');
      if ValidPointer( aFunc, 'confCadastrarPadrao_ECF_Daruma' ) then
        fFuncDaruma_FW_confCadastrarPadrao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'confCadastrar_ECF_Daruma');
      if ValidPointer( aFunc, 'confCadastrar_ECF_Daruma' ) then
        fFuncDaruma_FW_confCadastrar_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'confHabilitarHorarioVerao_ECF_Daruma');
      if ValidPointer( aFunc, 'confHabilitarHorarioVerao_ECF_Daruma' ) then
        fFuncDaruma_FW_confHabilitarHorarioVerao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'confDesabilitarHorarioVerao_ECF_Daruma');
      if ValidPointer( aFunc, 'confDesabilitarHorarioVerao_ECF_Daruma' ) then
        fFuncDaruma_FW_confDesabilitarHorarioVerao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'confProgramarOperador_ECF_Daruma');
      if ValidPointer( aFunc, 'confProgramarOperador_ECF_Daruma' ) then
        fFuncDaruma_FW_confProgramarOperador_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'confProgramarIDLoja_ECF_Daruma');
      if ValidPointer( aFunc, 'confProgramarIDLoja_ECF_Daruma' ) then
        fFuncDaruma_FW_confProgramarIDLoja_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'confProgramarAvancoPapel_ECF_Daruma');
      if ValidPointer( aFunc, 'confProgramarAvancoPapel_ECF_Daruma' ) then
        fFuncDaruma_FW_confProgramarAvancoPapel_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'confHabilitarModoPreVenda_ECF_Daruma');
      if ValidPointer( aFunc, 'confHabilitarModoPreVenda_ECF_Daruma' ) then
        fFuncDaruma_FW_confHabilitarModoPreVenda_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'confDesabilitarModoPreVenda_ECF_Daruma');
      if ValidPointer( aFunc, 'confDesabilitarModoPreVenda_ECF_Daruma' ) then
        fFuncDaruma_FW_confDesabilitarModoPreVenda_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rRetornarInformacao_ECF_Daruma');
      if ValidPointer( aFunc, 'rRetornarInformacao_ECF_Daruma' ) then
        fFuncDaruma_FW_rRetornarInformacao_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rRetornarVendaLiquida_ECF_Daruma');
      if ValidPointer( aFunc , 'rRetornarVendaLiquida_ECF_Daruma')
      then fFuncDaruma_FW_rRetornarVendaLiquida_ECF_Daruma := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'rLerAliquotas_ECF_Daruma');
      if ValidPointer( aFunc, 'rLerAliquotas_ECF_Daruma' ) then
        fFuncDaruma_FW_rLerAliquotas_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rLerMeiosPagto_ECF_Daruma');
      if ValidPointer( aFunc, 'rLerMeiosPagto_ECF_Daruma' ) then
        fFuncDaruma_FW_rLerMeiosPagto_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rLerRG_ECF_Daruma');
      if ValidPointer( aFunc, 'rLerRG_ECF_Daruma' ) then
        fFuncDaruma_FW_rLerRG_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rLerCNF_ECF_Daruma');
      if ValidPointer( aFunc, 'rLerCNF_ECF_Daruma' ) then
        fFuncDaruma_FW_rLerCNF_ECF_Daruma := aFunc
      else
        bRet := False;

       aFunc := GetProcAddress(fHandle,'rLerDecimais_ECF_Daruma');
      if ValidPointer( aFunc, 'rLerDecimais_ECF_Daruma' ) then
        fFuncDaruma_FW_rLerDecimais_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rLerDecimaisInt_ECF_Daruma');
      if ValidPointer( aFunc, 'rLerDecimaisInt_ECF_Daruma' ) then
        fFuncDaruma_FW_rLerDecimaisInt_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rLerDecimaisStr_ECF_Daruma');
      if ValidPointer( aFunc, 'rLerDecimaisStr_ECF_Daruma' ) then
        fFuncDaruma_FW_rLerDecimaisStr_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rDataHoraImpressora_ECF_Daruma');
      if ValidPointer( aFunc, 'rDataHoraImpressora_ECF_Daruma' ) then
        fFuncDaruma_FW_rDataHoraImpressora_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rVerificarImpressoraLigada_ECF_Daruma');
      if ValidPointer( aFunc, 'rVerificarImpressoraLigada_ECF_Daruma' ) then
        fFuncDaruma_FW_rVerificarImpressoraLigada_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rVerificarReducaoZ_ECF_Daruma');
      if ValidPointer( aFunc, 'rVerificarReducaoZ_ECF_Daruma' ) then
        fFuncDaruma_FW_rVerificarReducaoZ_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rRetornarDadosReducaoZ_ECF_Daruma');
      if ValidPointer( aFunc, 'rRetornarDadosReducaoZ_ECF_Daruma' ) then
          fFuncDaruma_FW_rRetornarDadosReducaoZ_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rRetornarVendaBruta_ECF_Daruma');
      If ValidPointer(aFunc , 'rRetornarVendaBruta_ECF_Daruma') then
        fFuncDaruma_FW_rRetornarVendaBruta_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rStatusImpressora_ECF_Daruma');
      if ValidPointer( aFunc, 'rStatusImpressora_ECF_Daruma' ) then
        fFuncDaruma_FW_rStatusImpressora_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle, 'rInfoEstendida_ECF_Daruma');
      if ValidPointer( aFunc , 'rInfoEstendida_ECF_Daruma') then
         fFuncDaruma_FW_rInfoEstendida_ECF_Daruma := aFunc
      else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'rInfoEstendida1_ECF_Daruma');
      if ValidPointer( aFunc, 'rInfoEstendida1_ECF_Daruma') then
        fFuncDaruma_FW_rInfoEstendida1_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rInfoEstendida2_ECF_Daruma');
      if ValidPointer( aFunc, 'rInfoEstendida2_ECF_Daruma') then
       fFuncDaruma_FW_rInfoEstendida2_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'rInfoEstendida3_ECF_Daruma');
       if ValidPointer( aFunc , 'rInfoEstendida3_ECF_Daruma') then
         fFuncDaruma_FW_rInfoEstendida3_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'rInfoEstendida4_ECF_Daruma');
       If ValidPointer( aFunc , 'rInfoEstendida4_ECF_Daruma') then
         fFuncDaruma_FW_rInfoEstendida4_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'rInfoEstendida5_ECF_Daruma');
       If ValidPointer( aFunc , 'rInfoEstendida5_ECF_Daruma') then
         fFuncDaruma_FW_rInfoEstendida5_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'rStatusUltimoCmd_ECF_Daruma');
      if ValidPointer( aFunc, 'rStatusUltimoCmd_ECF_Daruma') then
        fFuncDaruma_FW_rStatusUltimoCmd_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rStatusUltimoCmdInt_ECF_Daruma');
      if ValidPointer( aFunc, 'rStatusUltimoCmdInt_ECF_Daruma') then
       fFuncDaruma_FW_rStatusUltimoCmdInt_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'rStatusUltimoCmdStr_ECF_Daruma');
       if ValidPointer( aFunc , 'rStatusUltimoCmdStr_ECF_Daruma') then
         fFuncDaruma_FW_rStatusUltimoCmdStr_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'rCFVerificarStatus_ECF_Daruma');
       If ValidPointer( aFunc , 'rCFVerificarStatus_ECF_Daruma') then
         fFuncDaruma_FW_rCFVerificarStatus_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'rCFVerificarStatusInt_ECF_Daruma');
       If ValidPointer( aFunc , 'rCFVerificarStatusInt_ECF_Daruma') then
         fFuncDaruma_FW_rCFVerificarStatusInt_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'rCFVerificarStatusStr_ECF_Daruma');
      if ValidPointer( aFunc, 'rCFVerificarStatusStr_ECF_Daruma') then
        fFuncDaruma_FW_rCFVerificarStatusStr_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rCFSaldoAPagar_ECF_Daruma');
      if ValidPointer( aFunc, 'rCFSaldoAPagar_ECF_Daruma') then
       fFuncDaruma_FW_rCFSaldoAPagar_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'rCFSubTotal_ECF_Daruma');
       if ValidPointer( aFunc , 'rCFSubTotal_ECF_Daruma') then
         fFuncDaruma_FW_rCFSubTotal_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'eAbrirGaveta_ECF_Daruma');
       If ValidPointer( aFunc , 'eAbrirGaveta_ECF_Daruma') then
         fFuncDaruma_FW_eAbrirGaveta_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'eAcionarGuilhotina_ECF_Daruma');
       If ValidPointer( aFunc , 'eAcionarGuilhotina_ECF_Daruma') then
         fFuncDaruma_FW_eAcionarGuilhotina_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'iImprimirCodigoBarras_ECF_Daruma');
      if ValidPointer( aFunc, 'iImprimirCodigoBarras_ECF_Daruma') then
       fFuncDaruma_FW_iImprimirCodigoBarras_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'regCFCupomAdicional_ECF_Daruma');
       if ValidPointer( aFunc , 'regCFCupomAdicional_ECF_Daruma') then
         fFuncDaruma_FW_regCFCupomAdicional_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'regCFCupomAdicionalDllConfig_ECF_Daruma');
       If ValidPointer( aFunc , 'regCFCupomAdicionalDllConfig_ECF_Daruma') then
         fFuncDaruma_FW_regCFCupomAdicionalDllConfig_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'regCFCupomAdicionalDllTitulo_ECF_Daruma');
       If ValidPointer( aFunc , 'regCFCupomAdicionalDllTitulo_ECF_Daruma') then
         fFuncDaruma_FW_regCFCupomAdicionalDllTitulo_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'regCFCupomMania_ECF_Daruma');
      if ValidPointer( aFunc, 'regCFCupomMania_ECF_Daruma') then
        fFuncDaruma_FW_regCFCupomMania_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'regCFFormaPgto_ECF_Daruma');
      if ValidPointer( aFunc, 'regCFFormaPgto_ECF_Daruma') then
       fFuncDaruma_FW_regCFFormaPgto_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'regCFMensagemPromocional_ECF_Daruma');
       if ValidPointer( aFunc , 'regCFMensagemPromocional_ECF_Daruma') then
         fFuncDaruma_FW_regCFMensagemPromocional_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'regCFQuantidade_ECF_Daruma');
       If ValidPointer( aFunc , 'regCFQuantidade_ECF_Daruma') then
         fFuncDaruma_FW_regCFQuantidade_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'regCFTamanhoMinimoDescricao_ECF_Daruma');
       If ValidPointer( aFunc , 'regCFTamanhoMinimoDescricao_ECF_Daruma') then
         fFuncDaruma_FW_regCFTamanhoMinimoDescricao_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'regCFTipoDescAcresc_ECF_Daruma');
      if ValidPointer( aFunc, 'regCFTipoDescAcresc_ECF_Daruma') then
        fFuncDaruma_FW_regCFTipoDescAcresc_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'regCFUnidadeMedida_ECF_Daruma');
      if ValidPointer( aFunc, 'regCFUnidadeMedida_ECF_Daruma') then
       fFuncDaruma_FW_regCFUnidadeMedida_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'regCFValorDescAcresc_ECF_Daruma');
       if ValidPointer( aFunc , 'regCFValorDescAcresc_ECF_Daruma') then
         fFuncDaruma_FW_regCFValorDescAcresc_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'regCCDDocOrigem_ECF_Daruma');
       If ValidPointer( aFunc , 'regCCDDocOrigem_ECF_Daruma') then
         fFuncDaruma_FW_regCCDDocOrigem_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'regCCDFormaPgto_ECF_Daruma');
      if ValidPointer( aFunc, 'regCCDFormaPgto_ECF_Daruma') then
        fFuncDaruma_FW_regCCDFormaPgto_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'regCCDParcelas_ECF_Daruma');
      if ValidPointer( aFunc, 'regCCDParcelas_ECF_Daruma') then
       fFuncDaruma_FW_regCCDParcelas_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'regCCDLinhasTEF_ECF_Daruma');
       if ValidPointer( aFunc , 'regCCDLinhasTEF_ECF_Daruma') then
         fFuncDaruma_FW_regCCDLinhasTEF_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'regCCDValor_ECF_Daruma');
       If ValidPointer( aFunc , 'regCCDValor_ECF_Daruma') then
         fFuncDaruma_FW_regCCDValor_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'regChequeXLinha1_ECF_Daruma');
      if ValidPointer( aFunc, 'regChequeXLinha1_ECF_Daruma') then
        fFuncDaruma_FW_regChequeXLinha1_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'regChequeXLinha2_ECF_Daruma');
      if ValidPointer( aFunc, 'regChequeXLinha2_ECF_Daruma') then
       fFuncDaruma_FW_regChequeXLinha2_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'regChequeXLinha3_ECF_Daruma');
       if ValidPointer( aFunc , 'regChequeXLinha3_ECF_Daruma') then
         fFuncDaruma_FW_regChequeXLinha3_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'regChequeYLinha1_ECF_Daruma');
       If ValidPointer( aFunc , 'regChequeYLinha1_ECF_Daruma') then
         fFuncDaruma_FW_regChequeYLinha1_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'regChequeYLinha2_ECF_Daruma');
       If ValidPointer( aFunc , 'regChequeYLinha2_ECF_Daruma') then
         fFuncDaruma_FW_regChequeYLinha2_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'regChequeYLinha3_ECF_Daruma');
       if ValidPointer( aFunc, 'regChequeYLinha3_ECF_Daruma') then
         fFuncDaruma_FW_regChequeYLinha3_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle, 'regCompatibilidadeStatusFuncao_ECF_Daruma');
       if ValidPointer( aFunc , 'regCompatibilidadeStatusFuncao_ECF_Daruma') then
         fFuncDaruma_FW_regCompatibilidadeStatusFuncao_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'regSintegra_ECF_Daruma');
      if ValidPointer( aFunc, 'regSintegra_ECF_Daruma') then
        fFuncDaruma_FW_regSintegra_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'regAlterarValor_Daruma');
      if ValidPointer( aFunc, 'regAlterarValor_Daruma') then
       fFuncDaruma_FW_regAlterarValor_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'regRetornaValorChave_DarumaFramework');
       if ValidPointer( aFunc , 'regRetornaValorChave_DarumaFramework') then
         fFuncDaruma_FW_regRetornaValorChave_DarumaFramework := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'regRetornaValorChave');
       If ValidPointer( aFunc , 'regRetornaValorChave') then
         fFuncDaruma_FW_regRetornaValorChave := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'regLogin');
      if ValidPointer( aFunc, 'regLogin') then
        fFuncDaruma_FW_regLogin := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'regECFAguardarImpressao_ECF_Daruma');
      if ValidPointer( aFunc, 'regECFAguardarImpressao_ECF_Daruma') then
       fFuncDaruma_FW_regECFAguardarImpressao_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'regECFArquivoLeituraX_ECF_Daruma');
       if ValidPointer( aFunc , 'regECFArquivoLeituraX_ECF_Daruma') then
         fFuncDaruma_FW_regECFArquivoLeituraX_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'regECFAuditoria_ECF_Daruma');
       If ValidPointer( aFunc , 'regECFAuditoria_ECF_Daruma') then
         fFuncDaruma_FW_regECFAuditoria_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'regECFCaracterSeparador_ECF_Daruma');
      if ValidPointer( aFunc, 'regECFCaracterSeparador_ECF_Daruma') then
        fFuncDaruma_FW_regECFCaracterSeparador_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'regECFMaxFechamentoAutomatico_ECF_Daruma');
      if ValidPointer( aFunc, 'regECFMaxFechamentoAutomatico_ECF_Daruma') then
       fFuncDaruma_FW_regECFMaxFechamentoAutomatico_ECF_Daruma := aFunc
      else
       bRet := False;

      aFunc := GetProcAddress(fHandle,'rGerarEspelhoMFD_ECF_Daruma');
      if ValidPointer( aFunc, 'rGerarEspelhoMFD_ECF_Daruma') then
       fFuncDaruma_FW_rGerarEspelhoMFD_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'rGerarRelatorio_ECF_Daruma');
       if ValidPointer( aFunc , 'rGerarRelatorio_ECF_Daruma') then
         fFuncDaruma_FW_rGerarRelatorio_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'rGerarRelatorioOffline_ECF_Daruma');
       If ValidPointer( aFunc , 'rGerarRelatorioOffline_ECF_Daruma') then
         fFuncDaruma_FW_rGerarRelatorioOffline_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'rEfetuarDownloadMFD_ECF_Daruma');
       If ValidPointer( aFunc , 'rEfetuarDownloadMFD_ECF_Daruma') then
         fFuncDaruma_FW_rEfetuarDownloadMFD_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'rEfetuarDownloadMF_ECF_Daruma');
      if ValidPointer( aFunc, 'rEfetuarDownloadMF_ECF_Daruma') then
        fFuncDaruma_FW_rEfetuarDownloadMF_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rEfetuarDownloadTDM_ECF_Daruma');
      if ValidPointer( aFunc, 'rEfetuarDownloadTDM_ECF_Daruma') then
       fFuncDaruma_FW_rEfetuarDownloadTDM_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'rAssinarRSA_ECF_Daruma');
       if ValidPointer( aFunc , 'rAssinarRSA_ECF_Daruma') then
         fFuncDaruma_FW_rAssinarRSA_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'rRetornarNumeroSerieCodificado_ECF_Daruma');
       If ValidPointer( aFunc , 'rRetornarNumeroSerieCodificado_ECF_Daruma') then
         fFuncDaruma_FW_rRetornarNumeroSerieCodificado_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'rCalcularMD5_ECF_Daruma');
       If ValidPointer( aFunc , 'rCalcularMD5_ECF_Daruma') then
         fFuncDaruma_FW_rCalcularMD5_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'rVerificarNumeroSerieCodificado_ECF_Daruma');
      if ValidPointer( aFunc, 'rVerificarNumeroSerieCodificado_ECF_Daruma') then
        fFuncDaruma_FW_rVerificarNumeroSerieCodificado_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'rRetornarGTCodificado_ECF_Daruma');
      if ValidPointer( aFunc, 'rRetornarGTCodificado_ECF_Daruma') then
       fFuncDaruma_FW_rRetornarGTCodificado_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'rVerificarGTCodificado_ECF_Daruma');
       if ValidPointer( aFunc , 'rVerificarGTCodificado_ECF_Daruma') then
         fFuncDaruma_FW_rVerificarGTCodificado_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'rCodigoModeloFiscal_ECF_Daruma');
       If ValidPointer( aFunc , 'rCodigoModeloFiscal_ECF_Daruma') then
         fFuncDaruma_FW_rCodigoModeloFiscal_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'eAguardarCompactacao_ECF_Daruma');
       If ValidPointer( aFunc , 'eAguardarCompactacao_ECF_Daruma') then
         fFuncDaruma_FW_eAguardarCompactacao_ECF_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'eBuscarPortaVelocidade_ECF_Daruma');
      if ValidPointer( aFunc, 'eBuscarPortaVelocidade_ECF_Daruma') then
       fFuncDaruma_FW_eBuscarPortaVelocidade_ECF_Daruma := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'eEnviarComando_ECF_Daruma');
       if ValidPointer( aFunc , 'eEnviarComando_ECF_Daruma') then
         fFuncDaruma_FW_eEnviarComando_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'eRetornarAviso_ECF_Daruma');
       If ValidPointer( aFunc , 'eRetornarAviso_ECF_Daruma') then
         fFuncDaruma_FW_eRetornarAviso_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'eRetornarErro_ECF_Daruma');
       If ValidPointer( aFunc , 'eRetornarErro_ECF_Daruma') then
         fFuncDaruma_FW_eRetornarErro_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'eAuditar_Daruma');
       if ValidPointer( aFunc, 'eAuditar_Daruma') then
        fFuncDaruma_FW_eAuditar_Daruma := aFunc
       else
        bRet := False;

       aFunc := GetProcAddress(fHandle,'eDefinirProduto_Daruma');
       If ValidPointer( aFunc , 'eDefinirProduto_Daruma') then
         fFuncDaruma_FW_eDefinirProduto_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle , 'eDefinirModoRegistro_Daruma');
       If ValidPointer( aFunc , 'eDefinirModoRegistro_Daruma') then
         fFuncDaruma_FW_eDefinirModoRegistro_Daruma := aFunc
       else
         bRet := False;

      aFunc := GetProcAddress(fHandle,'eVerificarVersaoDLL_Daruma');
      if ValidPointer( aFunc, 'eVerificarVersaoDLL_Daruma') then
        fFuncDaruma_FW_eVerificarVersaoDLL_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'eVerificarVersaoDLL');
      if ValidPointer( aFunc, 'eVerificarVersaoDLL') then
       fFuncDaruma_FW_eVerificarVersaoDLL := aFunc
      else
       bRet := False;

       aFunc := GetProcAddress(fHandle, 'eInterpretarErro_ECF_Daruma');
       if ValidPointer( aFunc , 'eInterpretarErro_ECF_Daruma') then
         fFuncDaruma_FW_eInterpretarErro_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'eInterpretarAviso_ECF_Daruma');
       If ValidPointer( aFunc , 'eInterpretarAviso_ECF_Daruma') then
         fFuncDaruma_FW_eInterpretarAviso_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle,'eMemoriaFiscal_ECF_Daruma');
       If ValidPointer( aFunc , 'eMemoriaFiscal_ECF_Daruma')
       then fFuncDaruma_FW_eMemoriaFiscal_ECF_Daruma := aFunc
       else bRet := False;

       aFunc := GetProcAddress(fHandle,'eInterpretarRetorno_ECF_Daruma');
       If ValidPointer( aFunc , 'eInterpretarRetorno_ECF_Daruma')
       then fFuncDaruma_FW_eInterpretarRetorno_ECF_Daruma := aFunc
       else bRet := False;

       aFunc := GetProcAddress(fHandle,'eGerarQrCodeArquivo_DUAL_DarumaFramework');
       If ValidPointer( aFunc , 'eGerarQrCodeArquivo_DUAL_DarumaFramework')
       then fFuncDaruma_FW_eGerarQrCodeArquivo_DUAL_Daruma := aFunc
       else bRet := False;

       aFunc := GetProcAddress(fHandle,'eCarregarBitmapPromocional_ECF_Daruma');
       If ValidPointer(aFunc , 'eCarregarBitmapPromocional_ECF_Daruma')
       then fFuncDaruma_FW_eCarregarBitmapPromocional_ECF_Daruma := aFunc
       else bRet := False;

       if bRet
       then sRetorno := '0'
       else sRetorno := '1';
    end
    else
    begin
      ShowMessage('O arquivo DarumaFrameWork.dll não foi encontrado.');
      bRet := False;
      sRetorno := '1';
    end;

    If bRet then
    Begin
      //Muda a porta no XML
      RegistroDarumaFW('ECF','PortaSerial','','', Trim(sPorta));

      //Habilita o retorno estendido
      HabRetEstendido(1);

      //Desabilita a RedZ Automatica
      RegistroDarumaFW('ECF','ReducaoZAutomatica','','','0');

      //Habilita o Retorno de aviso de erro
      RegistroDarumaFW('ECF','RetornarAvisoErro','','','1');

      //Captura o caracter separador - é uma variável publica - não sobrescrever
      sCaracterSep := RegistroDarumaFW('ECF','','','','CaracterSeparador','S');
      If sCaracterSep[1] = '1'
      then sCaracterSep := Copy(sCaracterSep,3,Length(sCaracterSep))
      else
      begin
        GravaLog(' Verifique a TAG <CaracterSeparador> do arquivo DarumaFrameWork.xml ' +
        'e configure um caracter separador');
        sCaracterSep := ';';
      end;

      //Para o PAF-ECF com NFC-e, ajusto a porta e velocidade da DUAL para geração do qrCode
      //Porta
      RegistroDarumaFW('DUAL','PortaComunicacao','','', Trim(sPorta));

      //Velocidade
      sVelocidade := RegistroDarumaFW('ECF','','','','Velocidade','S');
      If sVelocidade[1] = '1' then
      begin
        sVelocidade := Copy(sVelocidade,3,Length(sVelocidade));
        RegistroDarumaFW('DUAL','Velocidade','','', sVelocidade);
      End;

      //Log do Arquivo de Configuração
      try
        sIni := ExtractFilePath(Application.ExeName) + 'DarumaFrameWork.XML';
        If FileExists(sIni) then
        Begin
          ListaArq := TStringList.Create;
          ListaArq.Clear;
          ListaArq.LoadFromFile(sIni);

          GravaLog(' ******** Arquivo DarumaFrameWork.XML *******');
          GravaLog( ListaArq.Text );
          GravaLog(' ******** Final da Leitura do Arquivo DarumaFrameWork.XML*******');
        End;
      except
        GravaLog('Não foi possível carregar/ler o arquivo de configuração DarumaFrameWork.XML');
      end;
    end;

    Result := sRetorno;
end;

//----------------------------------------------------------------------------
Function CloseDarumaFW : AnsiString;
var
  iRet : Integer;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      iRet := 1;
      GravaLog('CloseDarumaFW <- iRet:' + IntToStr(iRet));
      FreeLibrary(fHandle);
      fHandle := 0;
    end;
    bOpened := False;
  End;
  Result := '0';
end;


//----------------------------------------------------------------------------
Procedure TImpDarumaFrameWork.AlimentaProperties;
var
  iRet,nPos : Integer;
  sRet, sAliq : AnsiString;
begin
  /// Inicalização de variaveis
  ICMS := '';
  ISS := '';
  PDV := '';
  Eprom := '';
  Cnpj  := Space(18);
  Ie    := Space(18);
  NumLoja   := Space(4);
  NumSerie  := Space(15);
  TipoEcf   := '';
  MarcaEcf  := '';
  ModeloEcf := '';
  IndicaMFAdi  := '';
  DataIntEprom := '';
  HoraIntEprom := '';
  ContadorCro  := Space(4);
  ContadorCrz  := Space(4);
  GTInicial    := '';
  GTFinal      := Space(18);
  VendaBrutaDia:= Space(18);
  ReducaoEmitida := False;

  // Retorno de Aliquotas ( ICMS / ISS )
  sRet := Space( 150 );
  GravaLog('-> rLerAliquotas_ECF_Daruma ');
  iRet := fFuncDaruma_FW_rLerAliquotas_ECF_Daruma(sRet);
  GravaLog('<- rLerAliquotas_ECF_Daruma : ' + IntToStr(iRet));
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
  Begin
      While Length(sRet)>0 do
      begin
        nPos := Pos(';',sRet);

        If nPos > 0 Then
        Begin
          sAliq := Copy(sRet,1,nPos-1);
          Delete(sRet,1,nPos);
        End Else
        Begin
          sAliq := sRet;
          sRet  := '' ;
        End;

        //Não considera outros tipos de alíquotas não tributadas TF1, TF2, TN1,TI1...
        If (Length(sAliq) = 5) AND (sAliq[2] in ['0'..'9']) then
        Begin
          Try
            If Copy(sAliq,1,1) = 'T' Then
            Begin
              sAliq := Copy(sAliq,2,2)+','+Copy(sAliq,4,2);
              ICMS  := ICMS + FormataTexto(sAliq,5,2,1) +'|'
            End Else
            If Copy(sAliq,1,1) = 'S' Then
            Begin
              sAliq := Copy(sAliq,2,2)+','+Copy(sAliq,4,2);
              ISS   := ISS + FormataTexto(sAliq,5,2,1) +'|';
            End;
          Except
          End;
        End;
      end;
    End;

  //Retorno do Numero do Caixa (PDV)
  sRet := Space ( 3 );
  iRet := RetornaInfoECFFW('107',sRet);
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
  Begin
    If Pos(#0,sRet) > 0
    then PDV := Copy(sRet,1,Pos(#0,sRet)-1)
    Else PDV := Copy(sRet,1,3);

    //Para manter a compatibilidade com a Daruma32, foi adicionado ZERO para retorno com 4 posições
    If Length(PDV) = 3 Then PDV := '0'+PDV;
  End;

  // Retorno da Versão do Firmware (Eprom)
  sRet := Space( 6 );
  iRet := RetornaInfoECFFW( '83',sRet);
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
    Eprom := sRet ;


  // Retorna o CNPJ e alimenta Propriedade
  sRet := Space( 20 );
  iRet := RetornaInfoECFFW( '90', sRet );
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
    Cnpj := sRet ;

  // Retorna o IE e alimenta Propriedade
  sRet := Space( 20 );
  iRet := RetornaInfoECFFW( '91', sRet );
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
    Ie := sRet ;

  // Retorna o Numero da loja cadastrado no ECF
  sRet := Space( 4 );
  iRet := RetornaInfoECFFW( '129', sRet );
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
    NumLoja := Trim( sRet );

  // Retorna o Numero da Serie com 20 posições
  sRet := Space( 21 );
  iRet := RetornaInfoECFFW( '78', sRet );
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
    NumSerie := Copy(Trim( sRet ),1,20);

  // Retorna o Tipo do ECF
  TipoEcf := 'ECF-IF';

  // Retorna Marca do ECF
  MarcaEcf := sMarca;

  // Retorna Modelo do ECF
  sRet := Space( 6 );
  iRet := RetornaInfoECFFW('82', sRet );
  TrataRetornoDarumaFW( iRet );

  if Trim(sRet) = ''
  then sRet := '0';

  If iRet = 1
  then iRet := StrToInt(sRet);

  case iRet of
    10053 : ModeloEcf := 'FS600' ;
    10054 : ModeloEcf  := 'FS2100T' ;
    10058 : ModeloEcf  := 'FS600 USB' ;
    10059 : ModeloEcf  := 'FS700 L' ;
    10060 : ModeloEcf  := 'FS700 H' ;
    10061 : ModeloEcf  := 'FS700 M' ;
    10062 : ModeloEcf  := 'MACH 3' ;
    10063 : ModeloEcf  := 'MACH 1' ;
    10064 : ModeloEcf  := 'MACH 2' ;
    10068 : ModeloEcf  := 'FS800I';
  else
    ModeloEcf := 'FS800I';
  end;

  // Retorna Contador de Reinicio de Operação
  sRet := Space( 3 );
  iRet := RetornaInfoECFFW( '23', sRet );
  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  then ContadorCro := sRet;

  // Retorna Contador de ReduçãoZ
  sRet := Space( 4 );
  iRet := RetornaInfoECFFW( '24', sRet );
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
    ContadorCrz := sRet;

  // Retorna o valor Total Bruto Vendido até o momento do referido movimento
  sRet := Space( 18 );
  GravaLog('-> rRetornarVendaBruta_ECF_Daruma ');
  iRet := fFuncDaruma_FW_rRetornarVendaBruta_ECF_Daruma( sRet );
  GravaLog('<- rRetornarVendaBruta_ECF_Daruma : ' + IntToStr(iRet));
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
    VendaBrutaDia := sRet;

  // Retorna o valor do Grande Total da impressora
  sRet := Space( 18 );
  iRet := RetornaInfoECFFW( '1', sRet );
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
    GTFinal := sRet;


  // Retorna o valor do Grande Total no Inicio do Dia
  sRet := Space( 18 );
  iRet := RetornaInfoECFFW( '2', sRet );
  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  then GTInicial := sRet;

  //Path arquivos ECF
  try
    sPathEcfRegistry := RegistroDarumaFW('START','','','','LocalArquivosRelatorios','S');
    If sPathEcfRegistry[1] = '1' then
    begin
      sPathEcfRegistry := Copy(sPathEcfRegistry,3,Length(sPathEcfRegistry));

      {Força último caracter barra '\'}
      If (sPathEcfRegistry <> '') and (Copy(sPathEcfRegistry,Length(sPathEcfRegistry),1) <> '\')
      then sPathEcfRegistry := sPathEcfRegistry + '\' ;

      {Verifica se caminho existe, se não existir cria}
      Try
        if (sPathEcfRegistry <> '') and (not (sPathEcfRegistry = 'C:\')) then
        begin
          If (not DirectoryExists(sPathEcfRegistry)) and (Not ForceDirectories(sPathEcfRegistry))
          then MessageDlg( 'Caminho para retorno do ECF não encontrado:'+sPathEcfRegistry, mtError,[mbOK],0);
        end;
      Except
      End;
    end;

    {Configura Path para gerar registro tipo E}
    RegistroDarumaFW('AtoCotepe','Path','','',PathArquivo+DEFAULT_PATHARQMFD);
  finally
    GravaLog('-> Não foi possível alterar o registro');
  end;

end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.AbreCupom(Cliente,MensagemRodape: AnsiString): AnsiString;
var
  iRet : Integer;
  aAuxiliar : TaString;
  sCnpjCpf, sNomeCli, sEnd : AnsiString;
begin
  lDescAcres:=False;
  sCnpjCpf := '';
  sNomeCli := '';
  sEnd     := '';

  If Pos('|', Cliente) > 0 then
  begin
    MontaArray(Cliente, aAuxiliar);

    If Length( aAuxiliar ) >= 1 then
      sCnpjCpf := Copy( aAuxiliar[0], 1, 29 );

    If Length( aAuxiliar ) >= 2 then
      sNomeCli := Copy( aAuxiliar[1], 1, 30 );

    If Length( aAuxiliar ) >= 3 then
      sEnd := Copy( aAuxiliar[2], 1, 79 );
  end
  Else
    sCnpjCpf := Cliente;

  GravaLog('-> iCFAbrir_ECF_Daruma');
  iRet := fFuncDaruma_FW_iCFAbrir_ECF_Daruma(sCnpjCpf, sNomeCli, sEnd);
  GravaLog('<- iCFAbrir_ECF_Daruma : ' + IntToStr(iRet));

  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.AbreCupomNaoFiscal(Condicao,Valor,Totalizador, Texto: AnsiString): AnsiString;
var
  iRet,iPos : Integer;
  sRet,sRetFormas,sForma,sCOORecebimento : AnsiString;
begin
  // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if Pos('.', Valor) = 0 then
  begin
    Valor    := Trim(Valor);
    Valor    := Copy(Valor,1,length(Valor)-2)+'.'+Copy(Valor,length(Valor)-1,2);
  end;

  Valor    := Trim(FormataTexto( Valor, 14, 2, 3 ));
  Valor    := StrTran(Valor,'.',',');

  //*******************************************************************************
  // Pega o COO do cupom de recebimento para abrir um cupom vinculado
  //*******************************************************************************
  sRet := PegaCupom('');
  If Copy( sRet, 1, 1 ) = '0'
  then sCOORecebimento := Copy( sRet, 3, Length(sRet) );

  //*******************************************************************************
  // Abre o comprovante não fiscal. Tenta abrir um vinculado mas caso não consiga
  // faz um recebimento não fiscal para depois abrir o comprovante não fiscal
  // Condicao = Descricao da Forma de pagamento - Nao pode ser DINHEIRO
  //*******************************************************************************
  GravaLog(' iCCDAbrirSimplificado_ECF_Daruma -> '+Condicao+', '+Valor+', '+sCOORecebimento+' => TENTATIVA 1' );
  iRet := fFuncDaruma_FW_iCCDAbrirSimplificado_ECF_Daruma(pChar(Condicao),'1',sCOORecebimento,Valor);
  GravaLog(' iCCDAbrirSimplificado_ECF_Daruma <- iRet: '+IntToStr(iRet) );
  TrataRetornoDarumaFW( iRet );

  //Em caso de tentativa de abertura com erro mando o comando geral
  // pra poder vincular a primeira forma que possua vinculado
  If iRet <> 1 then
  begin
    GravaLog(' iCCDAbrirPadrao_ECF_Daruma -> ');
    iRet := fFuncDaruma_FW_iCCDAbrirPadrao_ECF_Daruma();
    GravaLog(' iCCDAbrirPadrao_ECF_Daruma <- iRet: '+IntToStr(iRet));
    TrataRetornoDarumaFW( iRet );
  end;

  sRet := Space(1);
  RetornaInfoECFFW('56',sRet);

  If sRet <> '0' //Ou seja o comprovante não foi aberto
  then Result := '0'
  Else
  begin
    //*******************************************************************************
    // Faz um recebimento não fiscal para abrir o cupom vinculado
    //*******************************************************************************
    sRet := CompNaoFiscalFW(Totalizador,Condicao,Valor,Texto);
    If sRet[1] = '1' then
    begin
      //*******************************************************************************
      // Pega o COO do cupom de recebimento para abrir um cupom vinculado
      //*******************************************************************************
      sCOORecebimento := Copy(sRet,3,6);

      //*******************************************************************************
      // Abre o comprovante vinculado
      //*******************************************************************************
      GravaLog(' -> iCCDAbrirSimplificado_ECF_Daruma: '+Condicao+', '+Valor+', '+sCOORecebimento + ' => TENTATIVA 2' );
      iRet := fFuncDaruma_FW_iCCDAbrirSimplificado_ECF_Daruma(pChar(Condicao),'1',sCOORecebimento,Valor);
      GravaLog(' <- iCCDAbrirSimplificado_ECF_Daruma: '+IntToStr(iRet) );
      TrataRetornoDarumaFW( iRet );

      If iRet = 1
      then Result := '0'
      Else
      Begin
        Status_ImpressoraFW( False );
        Result := '1';
      End;
    End
    Else
    Begin
      Status_ImpressoraFW( False );
      Result := '1';
    End;
  End;

  // Se apresentou algum erro monstra a mensagem
  If Result = '1'
  then TrataRetornoDarumaFW( iRet );
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.AbreEcf: AnsiString;
begin
    Result := '0';
end;

function TImpDarumaFrameWork.Abrir(sPorta: AnsiString; iHdlMain: Integer): AnsiString;
begin
  sMarca := 'DARUMA';
  Result := OpenDarumaFW(sPorta) ;

  // Carrega as aliquotas para ganhar performance
  if Copy(Result,1,1) = '0' then
  begin
    AlimentaProperties;
  end;

end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.CancelaCupom(Supervisor: AnsiString): AnsiString;
var
  iRet : Integer;
begin
  // Para cancelar um cupom aberto deve-ser ter ao menos um item vendido.
  GravaLog('-> iCFCancelar_ECF_Daruma');
  iRet := fFuncDaruma_FW_iCFCancelar_ECF_Daruma;
  GravaLog('<- iCFCancelar_ECF_Daruma : ' + IntToStr(iRet));
  TrataRetornoDarumaFW( iRet );

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.CancelaItem(numitem, codigo, descricao, qtde,
  vlrunit, vlrdesconto, aliquota: AnsiString): AnsiString;
var
  iRet : Integer;
begin
  NumItem := FormataTexto( numitem, 3, 0, 2 );
  GravaLog('-> iCFCancelarItem_ECF_Daruma');
  iRet := fFuncDaruma_FW_iCFCancelarItem_ECF_Daruma( NumItem );
  TrataRetornoDarumaFW( iRet );
  GravaLog('<- iCFCancelarItem_ECF_Daruma : ' + IntToStr(iRet));

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.DescontoTotal(vlrDesconto: AnsiString;nTipoImp: Integer): AnsiString;
var iRet: integer;
begin
  GravaLog('-> iCFTotalizarCupom_ECF_Daruma ');
  iRet := fFuncDaruma_FW_iCFTotalizarCupom_ECF_Daruma('D$', Pchar(vlrDesconto));
  TrataRetornoDarumaFW( iRet );
  GravaLog('<- iCFTotalizarCupom_ECF_Daruma : ' + IntToStr(iRet));

  If iRet = 1 then
  begin
    lDescAcres:=True;
    Result := '0';
  End
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.FechaCupom(Mensagem: AnsiString): AnsiString;
var
  iRet : Integer;
  sMsg : AnsiString;
begin
  //*****************************************************************************************
  //TrataTags e RemoveTags-> As Tags não precisarão ser implementadas pois elas são baseadas nas flags da Daruma
  //o texto que o Protheus enviara contera a tag que irá direto para o comando da impressora
  //sem tratamento, como nas outras impressoras.
  //*****************************************************************************************
  sMsg := Copy(Mensagem,1,383);
  GravaLog('iCFEncerrar_ECF_Daruma -> ' + Mensagem);
  if Trim(Mensagem) = ''
  then iRet := fFuncDaruma_FW_iCFEncerrarPadrao_ECF_Daruma()
  else iRet := fFuncDaruma_FW_iCFEncerrar_ECF_Daruma('0',sMsg);

  TrataRetornoDarumaFW( iRet );
  GravaLog(' iCFEncerrar_ECF_Daruma <- ' + IntToStr(iRet));

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.FechaCupomNaoFiscal: AnsiString;
var
  iRet : Integer;
begin
  GravaLog('-> iCCDFechar_ECF_Daruma');
  iRet := fFuncDaruma_FW_iCCDFechar_ECF_Daruma;
  TrataRetornoDarumaFW( iRet );
  GravaLog('<- iCCDFechar_ECF_Daruma : ' + IntToStr(iRet));

  If iRet = 1
  then Result := '0'
  else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.FechaEcf: AnsiString;
var
  iRet : Integer;
  sData : AnsiString;
  sHora : AnsiString;
begin
  // chama a funcao de ReducaoZ
  sData := DateToStr(Date);
  sHora := TimeToStr(Time);

  GravaLog('-> iReducaoZ_ECF_Daruma');
  iRet := fFuncDaruma_FW_iReducaoZ_ECF_Daruma( sData, sHora );
  TrataRetornoDarumaFW( iRet );
  GravaLog('<- iReducaoZ_ECF_Daruma : ' + IntToStr(iRet));

  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.Fechar(sPorta: AnsiString): AnsiString;
begin
  Result := '0';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.LeAliquotas: AnsiString;
begin
  Result := '0|' + ICMS;
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.LeAliquotasISS: AnsiString;
begin
  Result := '0|' + ISS;
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.LeituraX: AnsiString;
var
  iRet : Integer;
begin
  GravaLog('-> iLeituraX_ECF_Daruma');
  iRet := fFuncDaruma_FW_iLeituraX_ECF_Daruma();
  TrataRetornoDarumaFW( iRet );
  GravaLog('<- iLeituraX_ECF_Daruma : ' + IntToStr(iRet));

  if iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.Pagamento(Pagamento, Vinculado, Percepcion: AnsiString): AnsiString;
var iRet    : integer;
    sFrmPag : AnsiString;
    sVlrPag : AnsiString;
begin
    If not lDescAcres then
    begin
      GravaLog('-> iCFTotalizarCupomPadrao_ECF_Daruma');
      iRet := fFuncDaruma_FW_iCFTotalizarCupomPadrao_ECF_Daruma();
      GravaLog('<- iCFTotalizarCupomPadrao_ECF_Daruma : ' + IntToStr(iRet));
    end;

    while Length(pagamento) > 0 do
    begin
        sFrmPag:=Copy(Pagamento,1,Pos('|',Pagamento)-1);

        If sFrmPag = 'DINHEIRO' then sFrmPag:='Dinheiro';

        Pagamento:= Copy(Pagamento,Pos('|',pagamento)+1,Length(Pagamento));

        If Pos('|',Pagamento)>0 then
        begin
           sVlrPag:=Copy(Pagamento,1,Pos('|',pagamento)-1);
            Pagamento:= Copy(Pagamento,Pos('|',pagamento)+1,Length(Pagamento));
        end
        Else
        begin
           sVlrPag:=Copy(Pagamento,1,Length(pagamento));
           pagamento := '';
        End;

        sVlrPag:=Trim(FormataTexto(sVlrPag,12,2,3));

        GravaLog('-> iCFEfetuarPagamentoFormatado_ECF_Daruma');
        iRet := fFuncDaruma_FW_iCFEfetuarPagamentoFormatado_ECF_Daruma( Copy(sFrmPag,1,15) , sVlrPag);
        GravaLog('<- iCFEfetuarPagamentoFormatado_ECF_Daruma : ' + IntToStr(iRet));
    end;

    TrataRetornoDarumaFW( iRet );
    If iRet = 1
    then Result := '0'
    Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.PegaCupom(Cancelamento: AnsiString): AnsiString;
var
  iRet : Integer;
  lFinaliza : Boolean;
  iCont : Integer;
  sNumCupom : AnsiString;
begin
  lFinaliza := False;
  iCont     := 1;

  While (not lFinaliza) and (iCont <= 5)do
  begin
      { Pega o numero do cupom }
      sNumCupom := Space ( 6 );

      { Tenta pegar o numero do cupom. Se der algum erro, dá uma pausa
       de alguns segundo e tenta pegar o numero do cupom novamente. Faz isto por 5
       vezes, aumentando o intervalo de tempo entre as tentativas. }
      iRet := RetornaInfoECFFW('26',sNumCupom);
      TrataRetornoDarumaFW( iRet );

      If iRet = 1
      then lFinaliza := True
      else
      begin
        Sleep( 500 * iCont );
        Inc( iCont );
      end;
  end;

  { Verifica o retorno da função para pegar o numero do cupom }
  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  then Result := '0|' + sNumCupom
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.PegaPDV: AnsiString;
begin
  Result := '0|' + Pdv;
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.PegaSerie: AnsiString;
begin
  Result := '0|' + NumSerie;
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.RecebNFis(Totalizador, Valor,Forma: AnsiString): AnsiString;
var
   sRet : AnsiString;
begin
  sRet := CompNaoFiscalFW(Totalizador,Forma,Valor,'');

  if sRet[1] = '1'
  then Result := '0'
  else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.ReducaoZ(MapaRes: AnsiString): AnsiString;
    Function TrataLinha(Linha: AnsiString): AnsiString;
    var i: Integer;
    begin
         While Pos('?', Linha)>0 do
         begin
             i:=Pos('?', Linha);
             Linha[i]:=' ';
         end;
         Result := Linha;
    end;
var
  iRet, i, iPos, iSubTrib: Integer;
  sData, sHora , sFile, sLinha, sFlag,
  sValDeb ,sRetorno, sAliqISS, sPathDaruma,
  sAliquotas,sIcms,sVlrBIcms, sLinhaAux,sAImp,
  sAux, sTribIS1, sTribNS1, sTribFS1 : AnsiString;
  aRetorno, aFile : array of AnsiString;
  fFile : TextFile;
  bArred: Boolean;
  fAImp : Real;
begin
 Result := '1';
 If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(8);                                //**** Data do Movimento ****//
    iRet := RetornaInfoECFFW( '70', aRetorno[ 0] );
    aRetorno[0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],7,2);

    aRetorno[ 1] := PDV;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3]:= Space(4);                                //**** Numero de reducoes ****//
    iRet := RetornaInfoECFFW( '24', aRetorno[ 3] );
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    iRet := RetornaInfoECFFW( '1', aRetorno[ 4] );
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 5] := Space(6);                       //**** Numero documento inicial ****//
    iRet := RetornaInfoECFFW('27', aRetorno[5] );
    aRetorno[ 5] := FormataTexto(aRetorno[5],6,0,2);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    iRet := RetornaInfoECFFW('26', aRetorno[ 6] );
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[7] := Space (13);                         //**** Valor do Cancelamento ICMS****//
    iRet := RetornaInfoECFFW('13', aRetorno[7] );
    aRetorno[7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[7] := FormataTexto(aRetorno[7],15,2,1);

    aRetorno[8]:= Space(18);     //**** Venda Líquida ****
    iRet := fFuncDaruma_FW_rRetornarVendaLiquida_ECF_Daruma(aRetorno[8]);
    aRetorno[8] := Copy(aRetorno[8],1,Length(aRetorno[8])-2)+'.'+Copy(aRetorno[8],Length(aRetorno[8])-1,Length(aRetorno[8]));
    aRetorno[8] := FormataTexto(aRetorno[8],15,2,1);

    aRetorno[ 9] := Space (13);                         //**** Desconto ICMS****//
    iRet := RetornaInfoECFFW('11', aRetorno[ 9] );
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],13,2,1);

    sRetorno := Space (364);
    iRet := RetornaInfoECFFW('3', sRetorno );

    //**** SUBSTITUICAO TRIB ****// Posição 17 = (16*13)+1
    aRetorno[10] := Copy(sRetorno,(16*13)+1,13);
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],13,2,1);

    //**** ISENTO  ***// Posição 19 = (18*13)+1
    aRetorno[11] := Copy(sRetorno,(18*13)+1,13);
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],13,2,1);

    //**** NÃO TRIBUTADO ****// Posição 21 = (20*13)+1
    aRetorno[12] := Copy(sRetorno,(20*13)+1,13);
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],13,2,1);

    //Substituição de ISS - FS1 - Posição 23 = (22*13)+1
    sTribFS1 := Copy(sRetorno,(22*13)+1,13);
    sTribFS1 := Copy(sTribFS1,1,Length(sTribFS1)-2)+'.'+Copy(sTribFS1,Length(sTribFS1)-1,Length(sTribFS1));
    sTribFS1 := FormataTexto(sTribFS1,14,2,1);

    //Isenção de ISS - IS1 - Posição 25 = (24*13)+1
    sTribIS1 := Copy(sRetorno,(24*13)+1,13);
    sTribIS1 := Copy(sTribIS1,1,Length(sTribIS1)-2)+'.'+Copy(sTribIS1,Length(sTribIS1)-1,Length(sTribIS1));
    sTribIS1 := FormataTexto(sTribIS1,14,2,1);

    //Não incidencia de ISS - NS1 - Posição 27 = (26*13)+1
    sTribNS1 := Copy(sRetorno,(26*13)+1,13);
    sTribNS1 := Copy(sTribNS1,1,Length(sTribNS1)-2)+'.'+Copy(sTribNS1,Length(sTribNS1)-1,Length(sTribNS1));
    sTribNS1 := FormataTexto(sTribNS1,14,2,1);

    //**** Data da Reducao  Z ****//
    aRetorno[13] := Copy(StatusImp(2),3,10);
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);

    aRetorno[15] := FormataTexto('0',16, 0, 1);                         // --outros recebimentos--
    aRetorno[17] := ContadorCro;

    // desconto de ISS
    aRetorno[18] := Space(13);
    iRet := RetornaInfoECFFW('14',aRetorno[18]);
    aRetorno[18] := Copy(aRetorno[18],1,Length(aRetorno[18])-2)+'.'+Copy(aRetorno[18],Length(aRetorno[18])-1,Length(aRetorno[18]));
    aRetorno[18]:= FormataTexto( aRetorno[18], 11, 2, 1 );

    // cancelamento de ISS
    aRetorno[19] := Space(13);
    iRet := RetornaInfoECFFW('16',aRetorno[19]);
    aRetorno[19] := Copy(aRetorno[19],1,Length(aRetorno[19])-2)+'.'+Copy(aRetorno[19],Length(aRetorno[19])-1,Length(aRetorno[19]));
    aRetorno[19]:= FormataTexto( aRetorno[19], 13, 2, 1 );

    aRetorno[20]:= '00';                                         // QTD DE Aliquotas

    sAliqISS := CapturaBaseISSRedZ;     //Retorna os valores gastos de ISS separados por valor de Base
    aRetorno[16] := sAliqISS;

    If Copy(Trim(aRetorno[16]),Length(Trim(aRetorno[16])),1) <> ';'
    then aRetorno[16] := aRetorno[16] + ';';

    //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
    //Valor Debitado com 12 casas e 2 decimais + Separador ';'
    If StrToFloat(sTribIS1) > 0
    then aRetorno[16] := aRetorno[16] + 'IS1' + ' ' + sTribIS1 + ' ' + FormataTexto('0',14,2,1) + ';' ;

    If StrToFloat(sTribNS1) > 0
    then aRetorno[16] := aRetorno[16] + 'NS1' + ' ' + sTribNS1 + ' ' + FormataTexto('0',14,2,1) + ';' ;

    If StrToFloat(sTribFS1) > 0
    then aRetorno[16] := aRetorno[16] + 'FS1' + ' ' + sTribFS1 + ' ' + FormataTexto('0',14,2,1) + ';' ;

    //ICMS
    sLinha := Space( 364 );
    iRet := RetornaInfoECFFW('3',sLinha);
    TrataRetornoDarumaFW( iRet );

    if iRet = 1 then
    begin
      sAliquotas := Space( 150 );
      fFuncDaruma_FW_rLerAliquotas_ECF_Daruma( sAliquotas );
      sAliquotas := Trim( sAliquotas );

      bArred := (StatusImp(13) = '0');

      while (Length(sAliquotas) > 0) do
      begin
       If (Copy( sAliquotas, 1, 1 ) = 'T' ) and (not (AnsiUpperCase(sAliquotas)[2] in ['A'..'Z'])) then   // Separa só as aliquotas de ISS
       begin
         sIcms     := Copy( sAliquotas , 2 , 4 );

         If StrToFloat(sIcms) > 0 then
         begin
           aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
           // Aliquota '  ' Valor '  ' Imposto Debitado
           SetLength( aRetorno , Length(aRetorno) + 1);

           sVlrBIcms := Copy( sLinha , 1 , 13 );
           Insert('.',sVlrBIcms,Length(sVlrBIcms)-1);
           fAImp := (StrToFloat( sIcms ) / 100 )  * ( StrToFloat( sVlrBIcms ) /100 );

           If bArred
           then fAImp := Arredondar(fAImp,2);

           sAImp := FloatToStr( fAImp );
           sAImp := StrTran( sAImp,',','.');

           sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;
           sVlrBIcms := Replicate( '0' , 14 - Length(sVlrBIcms) ) + sVlrBIcms;

           If ( Length( sAImp ) - Pos( '.', sAImp ) > 2 ) And ( Pos( '.', sAImp ) > 0 )
           Then sAimp := Copy( sAImp, 1, Pos( '.', sAImp ) + 2 );

           If Pos( '.', sAImp ) = 0
           Then sAimp := '00000000000.00'
           Else sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;

           If Length( sAImp ) > 14
           Then sAImp := Copy( sAImp, Length( sAImp ) - 13, Length( sAImp ) );

           sLinhaAux:= 'T' + Copy(sIcms,1,2) + '.' + Copy(sIcms,3,2) + ' ' + FormataTexto(sVlrBIcms,14,2,1) + ' ' + Copy(sAImp,1,14);
           aRetorno[High(aRetorno)] := sLinhaAux; // Ex.: TXX.XX XXXXXXXXXXX.XX XXXXXXXXXXX.XX
         end;
       end;

       iPos := Pos(sCaracterSep,sAliquotas);

       If iPos = 0
       then iPos := Length(sAliquotas);

       sAliquotas := Copy( sAliquotas, iPos+1 , Length(sAliquotas) );
       sLinha  := Copy( sLinha , 14 , Length(sLinha) );
      end;
    end;
 end;

 Try
   GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
 Except
   GravaLog('Daruma - Redução Z - Erro na execução do comando: GrvTempRedZ()')
 End;

 If ((MapaRes = 'S') And (iRet = 1)) or (MapaRes <> 'S') then
 begin
  sData := DateToStr(Now);
  sHora := TimeToStr(Time);
  GravaLog('-> iReducaoZ_ECF_Daruma ');
  iRet := fFuncDaruma_FW_iReducaoZ_ECF_Daruma( sData, sHora );
  GravaLog('<- iReducaoZ_ECF_Daruma : ' + IntToStr(iRet));
  TrataRetornoDarumaFW( iRet );
 end;

 If aRetorno[0] = '01/01/00' then
 begin
    GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 01/01/00 ' +
             'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
    sAux := Space(8);
    iRet := RetornaInfoECFFW( '134', sAux );
    sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,7,2);
    aRetorno[0] := sAux;
    GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
 end;

 If iRet = 1 then
 begin
   Result := '0|';
   For i:= 0 to High(aRetorno) do
      Result := Result + aRetorno[i]+'|';
 end
 else
    Result := '1';

GravaLog('ReducaoZ -> iRet: ' + IntToStr(iRet) + ' Retorno : ' + Result);
GravaLog('ReducaoZ -Fim');
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.RegistraItem(codigo, descricao, qtde, vlrUnit,
  vlrdesconto, aliquota, vlTotIt, UnidMed: AnsiString;
  nTipoImp: Integer): AnsiString;
var
  iRet,iCasas : Integer;
  sTrib ,sAliquota,sIndiceISS, sAliqISS,sTipoQtd: AnsiString;
  bIssAlq : Boolean;
begin
  iCasas:=2;
  bIssAlq := False;

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    Result := '11';
    Exit;
  end;

  // Verifica o ponto decimal dos parâmetros
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');
  qtde := StrTran(qtde,',','.');

  // Verifica se existe a aliquota cadastrada na impressora.
  sTrib := Copy(aliquota,1,1);
  sAliquota := Copy(aliquota,2,5);
  sAliquota := StrTran( StrTran( sAliquota, ',', '' ), '.', '' );

  If Copy(aliquota,1,2) = 'FS' then
  begin
    sAliquota := 'FS1';
    bISSAlq := True;
  end;

  If Copy(aliquota,1,2) = 'IS' then
  begin
    sAliquota := 'IS1';
    bISSAlq := True;
  end;

  If Copy(aliquota,1,2) = 'NS' then
  begin
    sAliquota := 'NS1';
    bISSAlq := True;
  end;

  If bIssAlq = False then
  begin

    If sTrib = 'F' then
         sAliquota := 'FF';
    If sTrib = 'I' then
         sAliquota := 'II';
    If sTrib = 'N' then
         sAliquota := 'NN';
    If (sTrib = 'T') or ( sTrib = 'S' ) then
         sAliquota := FormataTexto(sAliquota,4,0,2);
  end;

  // Codigo só pode ser até 14 posicoes.
  Codigo := Copy(codigo+Space(14),1,14);

  // permite até 233 posições
  Descricao := Copy(Trim(Descricao),1,233);

  // Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
  sTipoQtd := 'F';

  // Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionária
  Qtde := FormataTexto( qtde, 7, 3, 2 );

  // Numero de cadas decimais para o preço unitário
  If Pos('.',vlrUnit) > 0 then
  begin
    If StrtoFloat(copy(vlrUnit,Pos('.',vlrUnit)+1,Length(vlrUnit))) > 99
    then iCasas := 3
    Else iCasas := 2;
  end;

  // Valor unitário deve ter até 8 digitos
  vlrUnit := FormataTexto( vlrUnit, 8, iCasas, 3 );
  vlrUnit := StrTran(vlrUnit,'.',',');

  // Valor desconto deve ter até 8 digitos
  vlrDesconto := FormataTexto( vlrDesconto, 8, 2, 2 );

  // Registra o Item
  GravaLog('-> iCFVender_ECF_Daruma  = ' + pChar( sTrib + sAliquota ) + ' , '  + pChar( Qtde ) + ' , '  +
           pChar( vlrUnit ) + ' , '  + 'D$' + ' , '  + pChar( vlrDesconto ) + ' , '  + pChar( Codigo )
            + ' , '  + pChar( UnidMed ) + ' , '  + pChar( descricao ));

  iRet := fFuncDaruma_FW_iCFVender_ECF_Daruma(pChar( sAliquota ),pChar( Qtde ),pChar( Trim(vlrUnit) ),
                                'D$',pChar( vlrDesconto ),pChar( Codigo ),pChar( UnidMed ),pChar( descricao ));

  GravaLog('<- iCFVender_ECF_Daruma : ' + IntToStr(iRet));

  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  then Result := '0'
  else Result := '1';
end;

//------------------------------------------------------------------------------
function HabRetEstendido( nRespEstendida: Integer ) : AnsiString;
var
  iRet : Integer;
begin
//Resposta estendida
iRet := StrToInt( RegistroDarumaFW('ECF','ReceberInfoEstendida','','',IntToStr(nRespEstendida)));
If iRet = 1
then Result := '0'
else Result := '1';

end;

//------------------------------------------------------------------------------
Function RegistroDarumaFW( sProduto1 , sProduto2, sProduto3, sProduto4 : AnsiString;  ValorChave : AnsiString ; Retorna : AnsiString = 'N' ): AnsiString;
var
   iRet : Integer;
   sChave,sParam1 , sParam2, sParam3,sParam4,sRet : AnsiString;
begin

If Retorna = 'N' then
begin
  sParam1 := Trim(sProduto1);
  sParam2 := Trim(sProduto2);
  sParam3 := Trim(sProduto3);
  sParam4 := Trim(sProduto4);

  While (Pos('\',sParam1) > 0) and (Pos('\',sParam2) > 0) and
        (Pos('\',sParam3) > 0) and (Pos('\',sParam4) > 0) do
  begin
    sParam1 := StringReplace(sParam1,'\','',[]);
    sParam2 := StringReplace(sParam2,'\','',[]);
    sParam3 := StringReplace(sParam3,'\','',[]);
    sParam4 := StringReplace(sParam4,'\','',[]);
  end;

  If sParam1 <> ''
  then sChave := Trim(sParam1);

  If sParam2 <> ''
  then sChave := sChave + '\' + sParam2;

  If sParam3 <> ''
  then sChave := sChave + '\' + sParam3;

  If sParam4 <> ''
  then sChave := sChave + '\' + sParam4;

  If Trim(sChave) <> '' then
  begin
    GravaLog('-> regAlterarValor_Daruma - Chave :' + sChave + ', ValorChave:' + ValorChave);
    iRet := fFuncDaruma_FW_regAlterarValor_Daruma(sChave,ValorChave);
    GravaLog('<- regAlterarValor_Daruma : ' + IntToStr(iRet));
  end;

  Result := IntToStr(iRet);
end
else
begin
  If (Trim(sProduto1) <> '') and (Trim(ValorChave) <> '') then
  begin
    If sProduto1[Length(sProduto1)] = '\'
    then sChave := Copy(sProduto1,1,Length(sProduto1)-1)
    else sChave := Trim(sProduto1);

    sRet := Space(100);
    GravaLog('-> regRetornaValorChave_DarumaFramework - Produto:' + sChave + ', Chave: ' + ValorChave );
    iRet := fFuncDaruma_FW_regRetornaValorChave_DarumaFramework(sChave,ValorChave,sRet);
    GravaLog('<- regRetornaValorChave_DarumaFramework :' + IntToStr(iRet));
    sRet:= Trim(sRet);

    If iRet = 1
    then Result := '1|' + sRet
    else Result := IntToStr(iRet);
  end
  else
    Result := '0';
end;

end;

//------------------------------------------------------------------------------
Function RetornaInfoECFFW( pszIndiceInfo : AnsiString ; var pszRetorno : AnsiString ) : Integer;
var
   iRet : Integer;
   sInd : AnsiString;
begin
//pszRetorno - já vem com o Space correto
GravaLog('rRetornarInformacao_ECF_Daruma -> Indice : ' + pszIndiceInfo );
iRet := fFuncDaruma_FW_rRetornarInformacao_ECF_Daruma(pszIndiceInfo, pszRetorno );
GravaLog('rRetornarInformacao_ECF_Daruma <- iRet: ' + IntToStr(iRet) );
Result := iRet;
end;

//------------------------------------------------------------------------------
function RetornoEstendido( iRetorno : Integer ): AnsiString;
Var
  sRet : AnsiString;
  iRet : Integer;
begin
sRet := Space(30);
GravaLog('-> rInfoEstendida_ECF_Daruma');
iRet := fFuncDaruma_FW_rInfoEstendida_ECF_Daruma(iRetorno,sRet);
GravaLog('<- rInfoEstendida_ECF_Daruma : ' + IntToStr(iRet));
Result := sRet ;
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.StatusImp(Tipo: Integer): AnsiString;
var
  iRet, i : Integer;
  sRet, Data, Hora, sDataHoje, sUltimoItem,sFormas : AnsiString;
  dDtHoje,dDtMov:TDateTime;
  FlagTruncamento : AnsiString;
  sVendaBruta, sSubTotal : AnsiString;
  sGrandeTotal : AnsiString;
  sContadorCrz: AnsiString;
  sLetraIndicativa: AnsiString;
  sDataIntEprom,sHoraIntEprom,sDataUltDoc,
  sCuponsEmitidos,sOperacoes,sGRG, sCDC: AnsiString;
begin
  //Tipo - Indica qual o status quer se obter da impressora
  //  1 - Obtem a Hora da Impressora
  //  2 - Obtem a Data da Impressora
  //  3 - Verifica o Papel
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  //  5 - Cupom Fechado ?
  //  6 - Ret. suprimento da impressora
  //  7 - ECF permite desconto por item
  //  8 - Verifica se o dia anterior foi fechado
  //  9 - Verifica o Status do ECF
  // 10 - Verifica se todos os itens foram impressos.
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  // 16 - Verifica se exige o extenso do cheque
  // 17 - Verifica venda bruta
  // 18 - Verifica Grande Total
  // 19 - Retorna a Data do Movimento
  // 20 - Verifica qual o CNPJ cadastrado na impressora
  // 21 - Retorna o IE cadastrado na impressora
  // 22 - Retorna o CRZ - Contador de Reduções Z
  // 23 - Retorna o CRO - Contador de Reinicio de Operações
  // 24 - Retorna a letra indicativa de MF adicional
  // 25 - Retorna o Tipo de ECF
  // 26 - Retorna a Marca do ECF
  // 27 - Retorna o Modelo do ECF
  // 28 - Retorna o Versão atual do Software Básico do ECF gravada na MF
  // 29 - Retorna a Data de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  // 30 - Retorna o Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  // 31 - Retorna o Nº de ordem seqüencial do ECF no estabelecimento usuário
  // 32 - Retorna o Grande Total Inicial
  // 33 - Retorna o Grande Total Final
  // 34 - Retorna a Venda Bruta Diaria
  // 35 - Retorna o Contador de Cupom Fiscal CCF
  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  // 37 - Retorna o Contador Geral de Relatório Gerencial
  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  // 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CÓDIGOS DE IDENTIFICAÇÃO DE ECF
  // 41 - Retorna o sequencial do último item vendido
  // 42 - Retorna o subtotal do cupom
 // 45  - Modelo Fiscal
 // 46 - Marca, Modelo e Firmware

  //  1 - Obtem a Hora da Impressora
  If Tipo = 1 then
  begin
    Data:=Space(8);
    Hora:=Space(6);
    GravaLog('-> rDataHoraImpressora_ECF_Daruma');
    iRet := fFuncDaruma_FW_rDataHoraImpressora_ECF_Daruma( Data, Hora );
    GravaLog('<- rDataHoraImpressora_ECF_Daruma : ' + IntToStr(iRet));
    TrataRetornoDarumaFw( iRet );
    If iRet = 1 then
    begin
      Result := '0|'+Copy(Hora,1,2)+':'+Copy(Hora,3,2)+':'+Copy(Hora,5,2);
    end
    Else
      Result := '1';
  end
  //  2 - Obtem a Data da Impressora
  Else If Tipo = 2 then
  begin
    Data:=Space(8);
    Hora:=Space(6);
    GravaLog('-> rDataHoraImpressora_ECF_Daruma');
    iRet := fFuncDaruma_FW_rDataHoraImpressora_ECF_Daruma( Data, Hora );
    GravaLog('<- rDataHoraImpressora_ECF_Daruma : ' + IntToStr(iRet));
    TrataRetornoDarumaFw( iRet );
    If iRet = 1 then
    begin
      Result := '0|'+Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,7,2);
    end
    Else
      Result := '1';
  end
  //  3 - Verifica o Papel
  Else If Tipo = 3 then
  begin
    sRet := Space(14);
    iRet := fFuncDaruma_FW_rStatusImpressora_ECF_Daruma( sRet );
    TrataRetornoDarumaFw( iRet );
    If sRet[4] in ['1','3','5','7','9','B','D','F']
    Then Result := '3'    // Bobina de papel ausente
    Else Result := '0';   // Bobina de papel presente
  end
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  Else if Tipo = 4 then
    Result := '0|TODOS'
  //  5 - Cupom Fechado ?
  Else If Tipo = 5 then
  begin
    sRet := Space(2);
    GravaLog('-> rCFVerificarStatus_ECF_Daruma');
    iRet := fFuncDaruma_FW_rCFVerificarStatus_ECF_Daruma( sRet, i );
    GravaLog('<- rCFVerificarStatus_ECF_Daruma : ' + IntToStr(iRet));
    TrataRetornoDarumaFw( iRet );
    If iRet = 1 then
    Begin
        if i = 1
        then Result := '7'    // aberto
        else Result := '0';  // Fechado
    End Else Result := '1';
  end
  //  6 - Ret. suprimento da impressora
  Else If Tipo = 6 then
  begin
      sRet := Space(573);
      iRet := RetornaInfoECFFW('169', sRet ); //Captura as valores das formas
      TrataRetornoDarumaFw( iRet );

      If iRet = 1 then
      begin
        sFormas := Copy(sRet,301,260); //Captura somente os valores
        sRet    := Copy(sRet,1,300);   //Captura somente as formas
        While Length(sRet) > 0 do
        begin
          If UpperCase(Trim(Copy(sRet,1,15))) = 'DINHEIRO'
          then Result := '0|' + Trim( FormataTexto(Copy(sFormas,1,11) + ',' + Copy(sFormas,12,2),12,2,3));

          sFormas := Copy(sFormas,14,Length(sFormas));
          sRet    := Copy(sRet,16,Length(sRet));
          Inc(i);
        end;
      end
      else Result:= '1';
  end
  //  7 - ECF permite desconto por item
  Else If Tipo = 7 then
    Result := '11'
  //  8 - Verifica se o dia anterior foi fechado
  Else If Tipo = 8 then
  begin
    Data     := Space(8);
    sDataHoje:= Space(6);
    sDataHoje:= Copy(StatusImp(2),3,8);

    sRet := Space(1);
    GravaLog('-> rVerificarReducaoZ_ECF_Daruma');
    iRet := fFuncDaruma_FW_rVerificarReducaoZ_ECF_Daruma(sRet);
    TrataRetornoDarumaFw( iRet );
    GravaLog('<- rVerificarReducaoZ_ECF_Daruma :' + IntToStr(iRet));

    If sRet = '1' //Se 1, redução Z pendente
    then Result := '10'
    else Result := '0';
  end
  //9 - Verifica o Status do ECF
  Else if Tipo = 9 Then
    result := '0'
  //10 - Verifica se todos os itens foram impressos.
  Else if Tipo = 10 Then
    result := '0'
  //11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  Else if Tipo = 11 then
      result := '1'
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  Else if Tipo = 12 then
      result := '1'
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  Else If Tipo = 13 then
  begin
    // Para o FlagTruncamento, retorna 1 se a impressora estiver no modo truncamento e 0 se estiver no modo arredondamento.
    // FlagTruncamento retorna , por exemplo : 1|A, significa que o comando foi executado com sucesso e a impressora Arredonda
    // Seguindo a compatibilidade de outras impressoras retorno valores padrões: 1 Trunca e 0 Arredonda
    FlagTruncamento := RegistroDarumaFW('ECF','','','','ArredondarTruncar','S');
    If FlagTruncamento[1] = '1' then
    begin
      If FlagTruncamento[3] = 'A'
      then Result := '0'
      else Result := '1';
    end
    Else Result := '1';
  end
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  else if Tipo = 14 then
  begin
    Result := '0'
  end
  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  else if Tipo = 15 then
    Result := '1'
  // 16 - Verifica se exige o extenso do cheque
  else if Tipo = 16 then
    Result := '1'
  // 17 - Verifica Venda Bruta
  else if Tipo = 17 then
  begin
    sVendaBruta := Space(18);
    GravaLog(' rRetornarVendaBruta_ECF_Daruma -> ');
    iRet := fFuncDaruma_FW_rRetornarVendaBruta_ECF_Daruma( sVendaBruta );
    TrataRetornoDarumaFw( iRet );
    GravaLog(' rRetornarVendaBruta_ECF_Daruma <- iRet:' + IntToStr(iRet));

    If iRet = 1 then
      Result := '0|' + sVendaBruta
    else
      Result := '1'
    End
  // 18 - Verifica Grande Total
  else if Tipo = 18 then
  begin
    sGrandeTotal := Space(18);
    iRet := RetornaInfoECFFW( '1', sGrandeTotal );

    TrataRetornoDarumaFw( iRet );
    If iRet = 1 then
      Result := '0|' + sGrandeTotal
    Else
      Result := '1'
    End
  // 19 - Retorna da data do movimento
  Else If Tipo = 19 then
  begin
    Data     := Space(8);
    sDataHoje:= Space(6);
    sDataHoje:= Copy(StatusImp(2),3,8);

    iRet := RetornaInfoECFFW( '70', Data );

    If ( Data='00000000' ) Or ( Data='01012000' ) or (Length(Data) < 8) then
        Result:= '0|' + sDataHoje
    else
    begin
        Data := Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,7,2);
        Result := '0|' + Data;
    End
  End

  // 20 - Retorna o CNPJ cadastrado na impressora
  else if Tipo = 20 then
    Result := '0|' + Cnpj

  // 21 - Retorna o IE cadastrado na impressora
  else if Tipo = 21 then
    Result := '0|' + Ie

  // 22 - Retorna o CRZ - Contador de Reduções Z
  else if Tipo = 22 then
  begin
    sContadorCrz := Space(4);
    If ReducaoEmitida then
    begin
      iRet := RetornaInfoECFFW( '24', sContadorCrz );
      TrataRetornoDarumaFw( iRet );
      If iRet = 1 then
      begin
        ContadorCrz := sContadorCrz ;
        Result := '0|' + ContadorCrz;
      end
      else
        Result := '1'
    end
    else
      Result := '0|' + ContadorCrz
  end

  // 23 - Retorna o CRO - Contador de Reinicio de Operações
  else if Tipo = 23 then
    Result := '0|' + ContadorCro

  // 24 - Retorna a letra indicativa de MF adicional
  else if Tipo = 24 then
  begin
    {Indice 78(20+1), retorna o número de fabricação do ECF(20 posicoes) + letra indicativa de MF Adicional(1 posicao(final), quando possuir)}
    If IndicaMFAdi = '' Then
    begin
       sLetraIndicativa := Space(21);
       iRet := RetornaInfoECFFW( '78', sLetraIndicativa );
       TrataRetornoDarumaFw( iRet );

       If iRet = 1 then
       begin
         IndicaMFAdi := Copy(sLetraIndicativa,21,1);
         Result      := '0|' + IndicaMFAdi;
       end else
         Result := '1'
    end else Result := '0|' + IndicaMFAdi;
  end

  // 25 - Retorna o Tipo de ECF
  else if Tipo = 25 then
    Result := '0|' + TipoEcf

  // 26 - Retorna a Marca do ECF
  else if Tipo = 26 then
    Result := '0|' + MarcaEcf

  // 27 - Retorna o Modelo do ECF
  else if Tipo = 27 then
    Result := '0|' + ModeloEcf

  // 28 - Retorna o Versão atual do Software Básico do ECF gravada na MF
  else if Tipo = 28 then
    Result := '0|' + Eprom

  // 29 - Retorna a Data de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  else if Tipo = 29 then
  begin
    If DataIntEprom = '' Then
    begin
      sDataIntEprom := Space(14);
      iRet := RetornaInfoECFFW( '85', sDataIntEprom );
      TrataRetornoDarumaFw( iRet );

      If iRet = 1 then
      begin
        DataIntEprom := Copy(sDataIntEprom,1,8);
        Result      := '0|' + DataIntEprom;
      end else
        Result := '1'
    end else Result := '0|' + DataIntEprom;
  end

  else if Tipo = 30 then
  begin
    If HoraIntEprom = '' Then
    begin
      sHoraIntEprom := Space(14);
      iRet := RetornaInfoECFFW( '85', sHoraIntEprom );
      TrataRetornoDarumaFw( iRet );
      If iRet = 1 then
      begin
        HoraIntEprom := Copy(sHoraIntEprom,Length(sHoraIntEprom)-5,6);
        Result      := '0|' + HoraIntEprom;
      end else
        Result := '1'
    end else Result := '0|' + HoraIntEprom;
  end

  // 31 - Retorna o Nº de ordem seqüencial do ECF no estabelecimento usuário
  else if Tipo = 31 then
    Result := '0|' + Pdv

  // 32 - Retorna o Grande Total Inicial
  else if Tipo = 32 then
  begin
    If ReducaoEmitida then
    begin
      // Retorna o Grande Total Inicial no dia
        sRet := Space(18);
        iRet := RetornaInfoECFFW( '2', sRet );
        TrataRetornoDarumaFw( iRet );

        If iRet = 1 then
        begin
          GTInicial := sRet;
          Result := '0|' + GTInicial
        end
        else
          Result := '1'
    end
    else
      Result := '0|' + GTInicial
  end

  // 33 - Retorna o Grande Total Final
  else if Tipo = 33 then
  begin
    If ReducaoEmitida then
    begin
      sRet := Space(18);
      iRet := RetornaInfoECFFW( '1', sRet );
      TrataRetornoDarumaFw( iRet );

      If iRet = 1 then
      begin
        GTInicial := sRet;
        Result := '0|' + GTFinal;
      end
      else
        Result := '1'
    end
    else
      Result := '0|' + GTFinal
  end

  // 34 - Retorna a Venda Bruta Diaria
  else if Tipo = 34 then
  begin
    If ReducaoEmitida then
    begin
      // Retorna o valor Total Bruto Vendido até o momento do referido movimento
      sVendaBruta := Space(18);
      GravaLog(' rRetornarVendaBruta_ECF_Daruma ->');
      iRet := fFuncDaruma_FW_rRetornarVendaBruta_ECF_Daruma( sVendaBruta );
      TrataRetornoDarumaFw( iRet );
      GravaLog(' rRetornarVendaBruta_ECF_Daruma <- iRet:' + IntToStr(iRet));
      If iRet = 1 then
      begin
        VendaBrutaDia := sVendaBruta;
        Result := '0|' + VendaBrutaDia;
      end
      else
        Result := '1'
    end
    else
      Result := '0|' + VendaBrutaDia
  end

  // 35 - Retorna o Contador de Cupom Fiscal CCF
  else if Tipo = 35 then
  begin
    sCuponsEmitidos := Space(6);
    iRet := RetornaInfoECFFW( '30', sCuponsEmitidos );
    TrataRetornoDarumaFw( iRet );

    If iRet = 1 then
      Result := '0|' + sCuponsEmitidos
    else
      Result := '1';
  end

  // 36 - Retorna o Contador Geral de Operação Não Fiscal - GNF
  else if Tipo = 36 then
  begin
    sOperacoes := Space(6);
    iRet := RetornaInfoECFFW( '28', sOperacoes );
    TrataRetornoDarumaFw( iRet );
    If iRet = 1 then
      Result := '0|' + sOperacoes
    Else
      Result := '1';
  end

  // 37 - Retorna o Contador Geral de Relatório Gerencial
  else if Tipo = 37 then
  begin
    sGRG := Space(6);
    iRet := RetornaInfoECFFW( '33', sGRG );
    TrataRetornoDarumaFw( iRet );

    If iRet = 1 then
      Result := '0|' + sGRG
    Else
      Result := '1';
  end

  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  else if Tipo = 38 then
  begin
    sCDC := Space(4);
    iRet := RetornaInfoECFFW( '45', sCDC );
    TrataRetornoDarumaFw( iRet );

    If iRet = 1 then
      Result := '0|' + sCDC
    Else
      Result := '1';
  end

  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  else if Tipo = 39 then
  begin
    sDataUltDoc := Space(14);
    iRet := RetornaInfoECFFW( '73', sDataUltDoc );
    TrataRetornoDarumaFw( iRet );

    If iRet = 1 then
    begin
      sDataUltDoc := Copy(sDataUltDoc,1,8);
      Result      := '0|' + sDataUltDoc;
    end else
      Result := '1'
  end

  // 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CÓDIGOS DE IDENTIFICAÇÃO DE ECF
  else if Tipo = 40 then
    Result := '0|' + CodigoEcf

  // 41 - Retorna o sequencial do último item vendido
  else if Tipo = 41 then
  Begin
    sUltimoItem := Space(3);
    iRet := RetornaInfoECFFW( '58', sUltimoItem );
    If iRet = 1 then
      Result := '0|' + sUltimoItem
    Else
      Result := '1';
  End

  // 42 - Retorna o subtotal do cupom
  else if Tipo = 42 then
  Begin
    sSubTotal := Space(12);
    iRet := RetornaInfoECFFW( '47', sSubTotal );
    If iRet = 1 then
      Result := '0|' + sSubTotal
    Else
      Result := '1';
  End
 else If Tipo = 45 then
        Result := '0|'// 45 Codigo Modelo Fiscal
 else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
          begin
              If (MarcaECF <> '') and (ModeloECF <> '')  then
                 Result := '0|'+MarcaECF  + ' ' + ModeloECF + ' - V. ' + Eprom
              Else
              Result := '1';
          end
  //Retorno não encontrado
  else
    Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.Suprimento(Tipo: Integer; Valor, Forma,
  Total: AnsiString; Modo: Integer; FormaSupr: AnsiString): AnsiString;
var
  iRet : Integer;
  sRet : AnsiString;
  nSuprimento : Real;
  sPath : AnsiString;
  fArquivo : TIniFile;
begin
  // Tipo = 1 - Verifica se tem troco disponivel
  // Tipo = 2 - Grava o valor informado no Suprimentos
  // Tipo = 3 - Sangra o valor informado

  Result := '1';

  Case Tipo of
      1: begin
          sRet := StatusImp(6);
          nSuprimento := StrToFloat(Copy(sRet,3,Length(sRet)));
          if nSuprimento >= StrToFloat(Valor) then
              Result := '8'
          else
              Result := '9'
          end;
      2: begin
          GravaLog('-> iSuprimento_ECF_Daruma');
          iRet:= fFuncDaruma_FW_iSuprimento_ECF_Daruma(Valor,Forma);
          GravaLog('<- iSuprimento_ECF_Daruma : ' + IntToStr(iRet));
          TrataRetornoDarumaFw( iRet );
          If iRet = 1
          then Result := '0'
          else Result := '1';

         end;
      3: begin
          GravaLog('-> iSuprimento_ECF_Daruma');
          iRet:= fFuncDaruma_FW_iSangria_ECF_Daruma(Valor,Forma);
          GravaLog('<- iSuprimento_ECF_Daruma : ' + IntToStr(iRet));
          TrataRetornoDarumaFw( iRet );
          If iRet = 1
          then Result := '0'
          else Result := '1';
         end;
    end;
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.TextoNaoFiscal(Texto: AnsiString; Vias: Integer): AnsiString;
var
  i: Integer;
  sTexto   : AnsiString;
  iRet,nPos: Integer;
  sLista   : TStringList;
Begin
  sLista := TStringList.Create;
  sLista.Clear;

  if Vias > 1 then
  Begin
    sTexto := Texto;
    i:=1;
    While i < Vias do
    Begin
      Texto:= Texto + sTexto;
      Inc(i);
    End;
  End;

  nPos := Pos(#10,Texto);
  While nPos > 0 do
  begin
    nPos    := Pos(#10,Texto);
    sTexto  := sTexto + Copy(Texto,1,nPos) ;
    Texto   := Copy(Texto,nPos+1,Length(Texto));

    If Length(sTexto) >= 350 Then
    Begin
      sLista.Add(sTexto);
      sTexto := ''
    end;
  end;

  If Trim(Texto) <> '' Then sTexto := ' ' + sTexto + Texto + #10;
  If Trim(sTexto) <> '' Then sLista.Add(sTexto);

  GravaLog(' iCCDImprimirTexto_ECF_Daruma -> Texto:' + Texto);
  For i:= 0 to sLista.Count-1 do
    iRet   := fFuncDaruma_FW_iCCDImprimirTexto_ECF_Daruma( sLista.Strings[i] );
  TrataRetornoDarumaFw( iRet );
  GravaLog('iCCDImprimirTexto_ECF_Daruma <- iRet: ' + IntToStr(iRet));

  if iRet = 1
  then Result := '0'
  else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.LeCondPag:AnsiString;
var
  iRet : Integer;
  sRet : AnsiString;
  sPagto : AnsiString;
begin
  sRet := Space(573);
  iRet := RetornaInfoECFFW('169', sRet ); //Captura as valores das formas
  TrataRetornoDarumaFw( iRet );

  If iRet = 1 then
  begin
    sPagto  := '';
    sRet    := Copy(sRet,1,300);   //Captura somente as formas

    While Length(sRet) > 0 do
    begin

      If Trim(Copy(sRet,1,15)) <> ''
      then sPagto := sPagto + Trim(Copy(sRet,1,15)) + '|';

      sRet := Copy(sRet,16,Length(sRet));
    end;

    Result := '0|' + sPagto;
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var iRet: integer;
begin
    GravaLog('-> iCFTotalizarCupom_ECF_Daruma');
    iRet := fFuncDaruma_FW_iCFTotalizarCupom_ECF_Daruma('A$', Pchar(vlrAcrescimo));
    GravaLog('<- iCFTotalizarCupom_ECF_Daruma : ' + IntToStr(iRet));
    TrataRetornoDarumaFW( iRet );
    If iRet >= 0 then
    Begin
       lDescAcres:=True;
       Result := '0';
    End
    Else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString;
var
  iRet : Integer;
  sParam1,sParam2,sTipoAux,sPathDestino,sArqDest: AnsiString;
  bPorCOO : Boolean;
begin

  //Parametro "Tipo" recebe AnsiString com duas posições, sendo a segunda posição: "S" para leitura simplificada e "C" para leitura completa
  //*** Opção disponível somente para modelos MFD FS600 e FS2100T
  sTipoAux := UpperCase(Copy(Tipo,1,1)) ;

  If Tipo[2] = 'C' then
  begin
    iRet := StrToInt( RegistroDarumaFW('ECF','LMFCompleta','','','1') );
    sArqDest := 'LMFC.TXT';
  end
  else
  begin
    iRet := StrToInt( RegistroDarumaFW('ECF','LMFCompleta','','','0') );
    sArqDest := 'LMFS.TXT';
  end;

  bPorCOO := ((Trim(ReducInicio) + Trim(ReducFim)) <> '');

  If bPorCOO  then
  Begin
    sParam1 := FormataTexto(ReducInicio,6,0,2);
    sParam2 := FormataTexto(ReducFim,6,0,2);
  end;

  if sTipoAux = 'I' then
  begin
      // Se o relatório for por Data
      If (not bPorCOO ) then
      begin
        sParam1 := FormataData( DataInicio, 4 );
        sParam2 := FormataData( DataFim, 4 );
      end;

      GravaLog('-> iMFLer_ECF_Daruma : (Param1 :' + sParam1 + ', Param2 : ' + sParam2);
      iRet := fFuncDaruma_FW_iMFLer_ECF_Daruma(sParam1,sParam2);
      GravaLog('<- iMFLer_ECF_Daruma : ' + IntToStr(iRet));
      TrataRetornoDarumaFW( iRet );
      If iRet = 1
      then Result := '0'
      Else Result := '1';
  end
  Else
  Begin
      If (not bPorCOO) then
      begin
        sParam1 := FormataData( DataInicio, 1 );
        sParam2 := FormataData( DataFim, 1 );
      end;

      GravaLog('-> iMFLerSerial_ECF_Daruma : (Param1 :' + sParam1 + ', Param2 : ' + sParam2);
      iRet := fFuncDaruma_FW_iMFLerSerial_ECF_Daruma(sParam1,sParam2);
      GravaLog('<- iMFLerSerial_ECF_Daruma :' + IntToStr(iRet));
      TrataRetornoDarumaFW( iRet );
      If iRet = 1  then
      begin
        sTipoAux := RegistroDarumaFW('START','','','','LocalArquivos','S');
        if sTipoAux[1] = '1' then
        begin
          sTipoAux := Copy(sTipoAux,3,Length(sTipoAux));

          sPathDestino := LeArqIni( ExtractFilePath(Application.ExeName) , 'SIGALOJA.INI', 'paf-ecf', 'patharquivo' , DEFAULT_PATHARQ);
          If sPathDestino[Length(sPathDestino)] <> '\'
          then sPathDestino := sPathDestino + '\';

          If not CopiarArquivo(sTipoAux+'Retorno.txt',sPathDestino+sArqDest) then
          begin
            MsgStop('Não foi possível copiar aquivo : [' + sTipoAux+'Retorno.txt ] para o caminho : [' + sPathDestino+ sArqDest +']');
            GravaLog('Não foi possível copiar aquivo : [' + sTipoAux+'Retorno.txt ] para o caminho : [' + sPathDestino+sArqDest +']');
          end;

          Result := '0';
        end
        else Result := '1';
      end
      else Result := '1';
  end;
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString;
begin
  MsgStop( MsgIndsImp );
  GravaLog(MsgIndsImp);
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
// Tipo = 1 - ICMS
// Tipo = 2 - ISS
var
  iRet : Integer;
begin
    Aliquota := FormataTexto(Aliquota,5,2,1);
    Aliquota := StrTran(Aliquota,'.','');

    If Tipo = 2
    then Aliquota := 'S' + Aliquota;

    GravaLog('-> confCadastrarPadrao_ECF_Daruma');
    iRet := fFuncDaruma_FW_confCadastrarPadrao_ECF_Daruma('ALIQUOTA',Aliquota);
    GravaLog('<- confCadastrarPadrao_ECF_Daruma : ' + IntToStr(iRet));
    TrataRetornoDarumaFW( iRet );
    If iRet = 1
    then Result := '0'
    Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
begin
  GravaLog('-> iAutenticarDocumento_DUAL_DarumaFramework');
  iRet := fFuncDaruma_FW_iAutenticarDocumento_DUAL_DarumaFramework(Texto,'1','40');
  GravaLog('<- iAutenticarDocumento_DUAL_DarumaFramework :' + IntToStr(iRet));
  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.Gaveta:AnsiString;
var
  iRet : Integer;
begin
  GravaLog('-> eAbrirGaveta_ECF_Daruma');
  iRet := fFuncDaruma_FW_eAbrirGaveta_ECF_Daruma();
  GravaLog('<- eAbrirGaveta_ECF_Daruma : ' + IntToStr(iRet));
  TrataRetornoDarumaFW( iRet );
  If iRet >= 0
  then Result := '0'
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.Status( Tipo:Integer; Texto:AnsiString ):AnsiString;
var
  bErro : Boolean;
begin
  bErro := False;
  case Tipo of
    1 : if Texto <> '0'
        then bErro := True;
  else
    bErro := False;
  end;

  If bErro
  then Result := '1'
  else Result := '0';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.GravaCondPag( Condicao:AnsiString ):AnsiString;
var
  iRet : Integer;
begin
  GravaLog('-> confCadastrarPadrao_ECF_Daruma');
  iRet := fFuncDaruma_FW_confCadastrarPadrao_ECF_Daruma('FPGTO',PChar(Condicao));
  GravaLog('<- confCadastrarPadrao_ECF_Daruma : ' + IntToStr(iRet));
  TrataRetornoDarumaFW(iRet);
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin
  GravaLog('-> confCadastrarPadrao_ECF_Daruma');
  iRet := fFuncDaruma_FW_confCadastrarPadrao_ECF_Daruma('TNF',Descricao);
  GravaLog('<- confCadastrarPadrao_ECF_Daruma : '  + IntToStr(iRet));
  TrataRetornoDarumaFW(iRet);
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.RelatorioGerencial( Texto:AnsiString ;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
var
  i       : Integer;
  iRet    : Integer;
  sTexto  : AnsiString;
  sInformacao : AnsiString;
begin
  Result := '0';
  //****************************************************************************
  // Verifica se existe cupom em aberto. Se existir, faz o fechamento
  //****************************************************************************
  sInformacao := Space(1);
  RetornaInfoECFFW('57', sInformacao );

  //****************************************************************************
  // Se houver cupom em aberto, faz o cancelamento
  //****************************************************************************
  If (Trim(sInformacao) <> '') and (StrToInt(sInformacao) in [5..8]) then
  begin
    GravaLog('-> iCNFCancelar_ECF_Daruma');
    iRet := fFuncDaruma_FW_iCNFCancelar_ECF_Daruma();
    GravaLog('<- iCNFCancelar_ECF_Daruma :' + IntToStr(iRet));
    TrataRetornoDarumaFW(iRet);
    If iRet = 1
    then Result := '0'
    else Result := '1';
  end;

  If Trim(ImgQrCode) <> '' then //deve carregar a Imagem antes de abrir o RG
  begin
    //Param 1 - Caminho e Nome da imagem ( C:\imagem.bmp ) até 200x200 em seu tamanho
    //Param 2 - Indice da Imagem a ser carregada ( 1 a 5 )
    //Param 3 - Orientação da Imagem , padrão '000'
    GravaLog(' eCarregarBitmapPromocional_ECF_Daruma ->');
    iRet := fFuncDaruma_FW_eCarregarBitmapPromocional_ECF_Daruma(ImgQrCode,'5','000');
    GravaLog(' eCarregarBitmapPromocional_ECF_Daruma <- iRet :' + IntToStr(iRet));
  end;
  
  //****************************************************************************
  // Verifica a quantidade de vias que é para imprimir
  //****************************************************************************
  if Vias > 1 then
  Begin
    sTexto := Texto;
    i:=1;
    While i < Vias do
    Begin
        Texto:= Texto+ sTexto;
        Inc(i);
    End;
  End;

  //***************************************************************************
  //Abre o Relatorio Gerencial
  //***************************************************************************
  GravaLog('iRGAbrirPadrao_ECF_Daruma ->');
  iRet := fFuncDaruma_FW_iRGAbrirPadrao_ECF_Daruma();
  TrataRetornoDarumaFW(iRet);
  GravaLog('iRGAbrirPadrao_ECF_Daruma <- iRet:' + IntToStr(iRet));

  //****************************************************************************
  // Envia o comando de impressao do relatorio gerencial
  //****************************************************************************
  If (iRet = 1) And (Length( Trim( Texto ) ) > 0) then
  begin
    GravaLog(' iRGImprimirTexto_ECF_Daruma -> ');

    While Length( Trim( Texto ) ) <> 0 do
    Begin
      iRet := fFuncDaruma_FW_iRGImprimirTexto_ECF_Daruma( Copy( Texto, 1, 400 ) );
      Texto := Copy( Texto, 401, Length( Texto ) );
    End;

    TrataRetornoDarumaFW(iRet);
    GravaLog('iRGImprimirTexto_ECF_Daruma <- iRet:' + IntToStr(iRet));
  end
  else
    Result := '0';

  If (iRet = 1) and ( Trim(ImgQrCode) <> '' ) then
  begin
    If FileExists(ImgQrCode) then
    begin
      //Envia a impressão da imagem carregada acima pelo indice
      GravaLog(' -> iRGImprimeArquivo ');
      iRet := fFuncDaruma_FW_iRGImprimirTexto_ECF_Daruma('<bmp>5</bmp>');
      GravaLog(' iRGImprimeArquivo -> iRet: ' + IntToStr(iRet));
    end;
  end;

  If iRet = 1 then
  begin
    GravaLog('-> iRGFechar_ECF_Daruma ');
    iRet := fFuncDaruma_FW_iRGFechar_ECF_Daruma();
    TrataRetornoDarumaFW(iRet);
    GravaLog('<- iRGFechar_ECF_Daruma :' + IntToStr(iRet));
  end;

  If iRet = 1
  then Result := '0'
  else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.DownloadMFD(sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Var
  iRet : Integer;   // Retorno da dll
  sMsg,sMsgOk,sMsgErr,sReg,sValIni,
  sValFim,sRetorno,sPathOrigem,
  sPathDestino,sNomeArq,sTpDown: AnsiString;
Begin
  sRetorno  := '1';

  sReg    := RegistroDarumaFW('START','','','','LocalArquivosRelatorios','S');
  If sReg[1] = '1'
  then sReg := Copy(sReg,3,Length(sReg));

  sMsg    := 'Função disponível somente para geração por COO.';
  sMsgOk  := 'Arquivo '+Trim(sReg)+'Retorno.txt gerado com sucesso.';
  sMsgErr := 'Erro na geração do arquivo.';


  If sTipo = '1' then
  begin
    Try
      sValIni := FormatDateTime('ddMMyy',StrToDateTime(sInicio));
      sValFim := FormatDateTime('ddMMyy',StrToDateTime(sFinal));
    except
      MessageDlg( sMsgErr, mtError,[mbOK],0);
      Exit;
    end;
  end
  else
  begin
    Try
      sValIni := FormataTexto(sInicio,6,0,2);
      sValFim := FormataTexto(sFinal,6,0,2);
    except
      MessageDlg( sMsgErr, mtError,[mbOK],0);
      Exit;
    end;
  end;

  If sTipo = '1'
  then sTpDown := 'DATAM'
  else sTpDown := 'COO';

  sNomeArq      := 'DOWNLOAD.MFD';

  GravaLog('rEfetuarDownloadMFD_ECF_Daruma -> Params : sTpDown [' + sTpDown + '] - Inicio [' + sValIni + '] - Fim [' + sValFim + ']');
  iRet := fFuncDaruma_FW_rEfetuarDownloadMFD_ECF_Daruma(pChar(sTpDown),Pchar(sValIni), Pchar(sValFim),sNomeArq);
  GravaLog('rEfetuarDownloadMFD_ECF_Daruma <- iRet: ' + IntToStr(iRet));
  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  Then begin
          sPathOrigem := RegistroDarumaFW('START','','','','LocalArquivos','S');
          If sPathOrigem[1] = '1'
          then sPathOrigem := Copy(sPathOrigem,3,Length(sPathOrigem));

          If sPathOrigem[Length(sPathOrigem)] <> '\'
          then sPathOrigem := sPathOrigem + '\';

          //Copia o arquivo gerado para que o Protheus possa autenticar o arquivo
          sPathDestino := LeArqIni( ExtractFilePath(Application.ExeName) , 'SIGALOJA.INI', 'paf-ecf', 'patharquivo' , DEFAULT_PATHARQ);
          If sPathDestino[Length(sPathDestino)] <> '\'
          then sPathDestino := sPathDestino + '\';

          if not DirectoryExists(sPathDestino)
          then ForceDirectories(sPathDestino);

          If not (CopiarArquivo(sPathOrigem+sNomeArq,sPathDestino + sNomeArq)) then
          begin
            ShowMessage('Erro ao copiar o arquivo [' + sPathOrigem + sNomeArq + '] para [' + sPathDestino + sNomeArq +']');
          end;
       end
  Else MessageDlg( sMsgErr, mtError,[mbOK],0);

  Result := sRetorno;
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.GeraRegTipoE(sTipo, sInicio, sFinal, sRazao,sEnd, sBinario: AnsiString): AnsiString;
Var
  tFindFile : TSearchRec;
  iRet,iX: integer;
  sTpIntervalo,sPathOrigem,sPathDestino,sNomeArq,sNomeArqBin,sPathBin,sLinha: AnsiString;
  ListaArquivo : TStringList;
  aArquivo : TextFile;
begin
  sNomeArqBin := 'DOWNLOAD.BIN';
  GravaLog('-> GeraRegTipoE : ' + sTipo + ',' + sInicio + ',' + sFinal + ',' + sRazao + ',' + sEnd + ',' + sBinario);

  //Quando por COO, preenche com zeros a esquerda para evitar erro
  If sTipo = '2' then
  begin
    sInicio := FormataTexto(sInicio,6,0,2);
    sFinal  := FormataTexto(sFinal,6,0,2);
    sTpIntervalo := 'COO';
    sNomeArq:= ' ATO_MFD_COO.TXT';
  end
  else
  begin
    sInicio := FormatDateTime('ddMMyyyy',StrToDate(sInicio));
    sFinal  := FormatDateTime('ddMMyyyy',StrToDate(sFinal));
    sTpIntervalo := 'DATAM';
    sNomeArq:= 'ATO_MFD_DATA.TXT';
  end;

  sPathOrigem := RegistroDarumaFW('START','','','','LocalArquivosRelatorios','S');
  If sPathOrigem[1] = '1'
  then sPathOrigem := Copy(sPathOrigem,3,Length(sPathOrigem));

  If sPathOrigem[Length(sPathOrigem)] <> '\'
  then sPathOrigem := sPathOrigem + '\';

  If sBinario = '1' then
  begin
    LimpaDir(sPathOrigem,'*','.bin');
  End;

  GravaLog('-> rGerarRelatorio_ECF_Daruma ( Tipo : MFD , Tipo de Intervalo : ' + sTpIntervalo +
                             ' , Inicio :' + sInicio + ', Final : ' + sFinal + ')');
  iRet    := fFuncDaruma_FW_rGerarRelatorio_ECF_Daruma(pChar('MFD'),pChar(sTpIntervalo),pChar(sInicio),pChar(sFinal));
  TrataRetornoDarumaFW(iRet);
  GravaLog('<- rGerarRelatorio_ECF_Daruma - iRet : ' + IntToStr(iRet));

  //Copia o arquivo gerado para que o Protheus possa autenticar o arquivo
  sPathDestino := LeArqIni( ExtractFilePath(Application.ExeName) , 'SIGALOJA.INI', 'paf-ecf', 'patharquivo' , DEFAULT_PATHARQ);
  If sPathDestino[Length(sPathDestino)] <> '\'
  then sPathDestino := sPathDestino + '\';

  sPathDestino := sPathDestino + DEFAULT_PATHARQMFD;

  if not DirectoryExists(sPathDestino)
  then ForceDirectories(sPathDestino);

  If sBinario = '1' then
  begin
    sPathBin  := sPathOrigem + '*.bin';
    iX := FindFirst(sPathBin,faAnyFile,tFindFile);
    if iX = 0 then
    begin
      If ( tFindFile.Attr and faDirectory ) <> faDirectory then
      begin
        sPathBin := sPathOrigem + tFindFile.Name;
      end;
    end;

    {if Pos(UpperCase('FS800i'), UpperCase( ModeloEcf )) > 0 then
    begin
      TrataArq(sPathBin);
    end;}

    If not (CopiarArquivo(sPathBin,sPathDestino + sNomeArqBin)) then
    begin
      ShowMessage('Erro ao copiar o arquivo [' + sPathBin + '] para [' + sPathDestino + sNomeArqBin +']');
      GravaLog(' GeraRegTipoE <- ' + 'Erro ao copiar o arquivo [' + sPathBin + '] para [' + sPathDestino + sNomeArqBin +']');
    end;
  end
  else
  begin
     //MFDNUMSERIE_DDMMAAAA_HHMMSS.txt - Padrão PAF
     sPathBin := UpperCase(sPathDestino + 'MFD' + NumSerie + '_' + FormatDateTime('ddMMyyyy', Date) + '_' + FormatDateTime('hhmmss', Time)+'.txt');
     DeleteFile(pChar(sPathBin));
     If (CopiarArquivo(sPathOrigem+sNomeArq,sPathBin))
     then DeleteFile(sPathOrigem+sNomeArq)
     else
        begin
          try
           trataArq(sPathBin);
          except
          end;

          If (not FileExists(sPathBin)) and (not (sTpIntervalo = 'COO'))
          then begin
                 ShowMessage('Erro ao copiar o arquivo [' + sPathOrigem+sNomeArq + '] para [' + sPathBin +']');
                 GravaLog(' GeraRegTipoE <- ' + 'Erro ao copiar o arquivo [' + sPathOrigem+sNomeArq + '] para [' + sPathBin +']');
               end;
        end;
  end;

  if iRet = 1
  then Result := '0'
  else Result := '1';
end;

//-------------------------------------------------------------------------------
function TImpDarumaFrameWork.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString;
Var
  iRet,i,nPos  : Integer;
  cTextoImpAux,sInformacao : AnsiString;
  sLista       : TStringList;
begin
  // Inicialização das variaveis
  Result      := '0';
  sLista      := TStringList.Create;
  sLista.Clear;

  //****************************************************************************
  // Verifica se existe cupom em aberto. Se existir, faz o fechamento
  //****************************************************************************
  sInformacao := Space(1);
  RetornaInfoECFFW('57', sInformacao );

  //****************************************************************************
  // Se houver cupom em aberto, faz o cancelamento
  //****************************************************************************
  If (Trim(sInformacao) <> '') and (StrToInt(sInformacao) in [5..8]) then
  begin
    GravaLog('-> iCNFCancelar_ECF_Daruma');
    iRet := fFuncDaruma_FW_iCNFCancelar_ECF_Daruma();
    GravaLog('<- iCNFCancelar_ECF_Daruma :' + IntToStr(iRet));
    TrataRetornoDarumaFW(iRet);
    If iRet = 1
    then Result := '0'
    else Result := '1';
  end;

  If Trim(ImgQrCode) <> '' then //deve carregar a Imagem antes de abrir o RG
  begin
    //Param 1 - Caminho e Nome da imagem ( C:\imagem.bmp ) até 200x200 em seu tamanho
    //Param 2 - Indice da Imagem a ser carregada ( 1 a 5 )
    //Param 3 - Orientação da Imagem , padrão '000'
    GravaLog('eCarregarBitmapPromocional_ECF_Daruma ->');
    iRet := fFuncDaruma_FW_eCarregarBitmapPromocional_ECF_Daruma(ImgQrCode,'5','000');
    GravaLog(' eCarregarBitmapPromocional_ECF_Daruma <- iRet :' + IntToStr(iRet));
  end;

  nPos := Pos(#10,cTextoImp);
  While nPos > 0 do
  Begin
      nPos          := Pos(#10,cTextoImp);
      cTextoImpAux  := cTextoImpAux + Copy(cTextoImp,1,nPos) ;
      cTextoImp     := Copy(cTextoImp,nPos+1,Length(cTextoImp));

      If Length(cTextoImpAux) >= 400 Then
      Begin
        sLista.Add(cTextoImpAux);
        cTextoImpAux := ''
      end;
   End;

   If Trim(cTextoImp) <> '' Then cTextoImpAux := ' ' + cTextoImpAux + cTextoImp + #10;
   If Trim(cTextoImpAux) <> '' Then sLista.Add(cTextoImpAux);

   For i := 1 to nVias do
   Begin
    GravaLog(' iRGAbrirIndice_ECF_Daruma -> Indice' + cIndTotalizador );
    iRet := fFuncDaruma_FW_iRGAbrirIndice_ECF_Daruma(StrToInt(cIndTotalizador));
    GravaLog(' <- iRGAbrirIndice_ECF_Daruma : ' + IntToStr(iRet) );

    TrataRetornoDarumaFW( iRet );
    If iRet <> 1 then
    Begin
      Result := '1';
      Exit;
    End;

    GravaLog(' iRGImprimirTexto_ECF_Daruma -> ' );

    For nPos := 0 to Pred(sLista.Count) do
      iRet := fFuncDaruma_FW_iRGImprimirTexto_ECF_Daruma(pChar(sLista.Strings[nPos]));

    GravaLog(' iRGImprimirTexto_ECF_Daruma - iRet: ' + IntToStr(iRet) );

    TrataRetornoDarumaFW( iRet );
    If iRet <> 1 then
    Begin
      Result := '1';
      Exit;
    End;

  If (iRet = 1) and ( Trim(ImgQrCode) <> '' ) then
    begin
      If FileExists(ImgQrCode) then
      begin
        //Envia a impressão da imagem carregada acima pelo indice
        GravaLog(' iRGImprimeArquivo -> [' + ImgQrCode + ']');
        iRet := fFuncDaruma_FW_iRGImprimirTexto_ECF_Daruma('<bmp>5</bmp>');
        GravaLog(' iRGImprimeArquivo -> iRet: ' + IntToStr(iRet));
      end;
    end;

    GravaLog(' -> iRGFechar_ECF_Daruma' );
    iRet:= fFuncDaruma_FW_iRGFechar_ECF_Daruma;
    GravaLog(' <- iRGFechar_ECF_Daruma : ' + IntToStr(iRet) );
    TrataRetornoDarumaFW( iRet );

    If iRet = 1
    then Result := '0'
    Else Result := '1';
  End;

  // Mostrar mensagem de erro se necessário
  If Result = '1'
  then TrataRetornoDarumaFW( iRet );
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.LeTotNFisc:AnsiString;
var
  iRet, i , iPosFim : Integer;
  sRet,sTotaliz,sSeparador : AnsiString;
begin
  sRet := Space( 360 );
  GravaLog('-> rLerCNF_ECF_Daruma');
  iRet := fFuncDaruma_FW_rLerCNF_ECF_Daruma( sRet );
  GravaLog('<- rLerCNF_ECF_Daruma : ' + IntToStr(iRet) + ', Totalizadores:' + sRet);
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
  begin
    sRet := Trim(sRet);
    If Pos(',',sRet) > 0
    then sSeparador := ',';

    If Pos(';',sRet) > 0
    then sSeparador := ';';

    sTotaliz := '';
    While Trim(sRet) <> '' do
    begin
      iPosFim := Pos(sSeparador,sRet);

      If iPosFim > 0
      then sTotaliz := sTotaliz + FormataTexto( IntToStr(i), 2, 0, 4) + ',' + Trim(Copy( sRet, 1, iPosFim-1 )) + '|'
      else sTotaliz := sTotaliz + FormataTexto( IntToStr(i), 2, 0, 4) + ',' + Trim(Copy( sRet, 1, Length(sRet))) + '|';

      sRet:= Copy(sRet,iPosFim+1,Length(sRet));
    end;

    Result := '0|' + sTotaliz;
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
Var
  iRet : Integer;
  sPedido ,sRet   : AnsiString;
  sTefPedido      : AnsiString;
  sCondicao       : AnsiString;
  sPath           : AnsiString;
  sTotalizadores  : AnsiString;
  fArquivo        : TIniFile;
  aAuxiliar       : TaString;
  lPedido         : Boolean;
  lTefPedido      : Boolean;
  sTotPedido      : AnsiString;     // Contem o totalizador do registrador PEDIDO
  sTotTefPedido   : AnsiString;     // Contem o totalizador do registrador TEFPEDIDO
  iX              : Integer;
  sMsg            : AnsiString;
  sArquivo        : AnsiString;
begin
  //*******************************************************************************
  // Para não forçar o cliente a utilizar registradores fixos do ECF na emissão
  // de cupom não fiscal vinculado e não vinculado para a impressão do comprovante
  // de venda (função abaixo) sera utilizado o arquivo DARUMA.INI
  // abaixo:
  //
  // [MICROSIGA]
  // Pedido=Nome do totalizador
  // TefPedido=Nome do totalizador
  // Condicao=Condição de pagamento
  //
  // Onde:
  // - Pedido deverá conter o nome do totalizador que irá conter os valores de registros
  // do cupom não fiscal ref. ao comprovante de venda
  // - TefPedido deverá conter o nome do totalizador que irá conter os valores de
  // de registros do cupom não fiscal ref. ao comprovante do TEF quando for utilizado
  // na venda assistida (LOJA701) com o conceito de reservas + pedidos.
  // Os valores default para esses totalizadores será "01"
  // - Condicao deverá conter a condição de pagamento que servirá para o recebimento
  // do comprovante não fiscal não vinculado
  //*******************************************************************************

  //*******************************************************************************
  // Inicialização das variaveis
  //*******************************************************************************
  Result      := '1';
  lPedido     := False;
  lTefPedido  := False;
  sArquivo    := 'DARUMA.INI';
  sPath       := '';

  sPath       := ExtractFilePath(Application.ExeName);
  fArquivo    := TIniFile.Create(sPath + sArquivo);

  fArquivo    := TIniFile.Create(sPath + sArquivo);
  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  //*******************************************************************************
  // Checa indice do totalizador pelo nome informado
  //*******************************************************************************
  sTotalizadores  := Space(360);
  GravaLog(' rLerCNF_ECF_Daruma ->');
  iRet            := fFuncDaruma_FW_rLerCNF_ECF_Daruma( sTotalizadores );
  GravaLog(' rLerCNF_ECF_Daruma <- iRet: ' + IntToStr(iRet) + ',Totalizadores:' + sTotalizadores);
  TrataRetornoDarumaFW( iRet );
  If iRet = 1 then
  begin
    If (Pos( UpperCase( sPedido ), UpperCase( sTotalizadores ) ) > 0) And (Pos( UpperCase( sTefPedido ), UpperCase( sTotalizadores ) ) > 0) then
    begin

      If Pos(',',sTotalizadores) > 0
      then sTotalizadores := StrTran( sTotalizadores, ',', '|' )
      else if Pos(';',sTotalizadores) > 0
           then sTotalizadores := StrTran( sTotalizadores, ';', '|' );

      MontaArray( sTotalizadores,aAuxiliar );

      iX := 0;
      While (iX < Length(aAuxiliar)) do
      begin

        If UpperCase(Trim(Copy( aAuxiliar[iX], 1, Length(aAuxiliar[iX]) ))) = UpperCase( sPedido ) then
        begin
          lPedido := True;
          sTotPedido := FormataTexto( IntToStr(iX+1), 2, 0, 2 );
        end;

        If UpperCase(Trim(Copy( aAuxiliar[iX], 1, Length(aAuxiliar[iX]) ))) = UpperCase( sTefPedido ) then
        begin
          lTefPedido := True;
          sTotTefPedido := FormataTexto( IntToStr(iX+1), 2, 0, 2 );
        end;

        If lPedido And lTefPedido
        then break;

        Inc( iX );
      end;
    end;
  end;

  // Faz o tratamento dos parâmetros
  Valor       := Trim(FormataTexto( Valor, 14, 2, 3 ));
  Valor       := StrTran( Valor, '.', ',' );
  sCondicao   := Copy( sCondicao, 1, 16 );

  // Faz o recebimento não fiscal / Comprovante não fiscal não vinculado
  If lPedido And lTefPedido then
  begin
    // Efetua a impressão do comprovante não fiscal não vinculado
    sRet := CompNaoFiscalFW(sTotPedido,sCondicao,Valor,'');

    if sRet[1] = '1'
    then Result := '0'
    else Result := '1';

    If (sRet[1] = '1') then
    begin
      // Efetua impressão do comprovante de credito e debito vinculado
      iRet := CompCredDebFW(Copy(sRet,3,6),sCondicao,Valor,Texto);
      If iRet = 1
      then Result := '0';

      If (iRet = 1) and (Tef = 'S') then
      begin
        // Checar se serah impresso o comprovante TEF. Caso afirmativo abre um novo
        // comprovante nao fiscal nao vinculado.
        sRet := CompNaoFiscalFW(sTotTefPedido,sCondicao,Valor,'');

        If sRet[1] = '1'
        then Result := '0'
        else Result := '1';
      end;

    end
    else
    begin
      If sRet[1] = '1'
      then Result := '0';
    end;

    //*******************************************************************************
    // Mostrar mensagem de erro se necessário
    //*******************************************************************************
    If Result = '1'
    then TrataRetornoDarumaFW( iRet );
  end
  Else
  begin
    //*******************************************************************************
    // Mostrar mensagem de erro caso os totalizadores não tenham sido encontrados
    //*******************************************************************************
    sMsg := '';
    If not lPedido then
      sMsg := sMsg + ' ' + sPedido;
    If not lTefPedido then
      sMsg := sMsg + ' ' + sTefPedido;
    If Trim(sMsg) <> '' then
      LjMsgDlg('Os totalizadores ' + sMsg + ' não existem no ECF. Checar o arquivo '+ sArquivo);
    Result := '1';
  end;

end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.RedZDado( MapaRes : AnsiString): AnsiString ;
Var
  aRetTemp: TaString;
  i,iRet: Integer;
  sAux: AnsiString;
begin

sAux := Space(8);                                //**** Data do Movimento ****//
iRet := RetornaInfoECFFW( '134', sAux );
TrataRetornoDarumaFW( iRet );

GravaLog('RetornaInfoECFFW(134) - Data Ult <- iRet:' + IntToStr(iRet));

If iRet = 1 then
Begin
  sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,4);
  aRetTemp := GetTempRedZ(sAux);

  Result := '0|';

  For i:= 0 to High(aRetTemp) do
    Result := Result + aRetTemp[i]+'|';

  GravaLog('Daruma Mapa Resumo(Recuperado) <- Retorno : '+ Result);
End;

end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.DownMF( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
var
  sPath,sArquivo,sArquivoTxt,sLinha : AnsiString;
  iRet  : Integer;
  mArqMF: TStringList;
  aArquivo : TextFile;
Begin
  sArquivo := 'DARUMA.MF';
  sArquivoTxt := 'MFISCAL.BIN';

  sPath := RegistroDarumaFW('START','','','','LocalArquivosRelatorios','S');
  If sPath[1] = '1'
  then sPath := Copy(sPath,3,Length(sPath));

  if sPath[Length(sPath)] <> '\'
  then sPath := sPath + '\';

  GravaLog('rEfetuarDownloadMF_ECF_Daruma -> Arquivo: ' + sPath+sArquivo);
  iRet := fFuncDaruma_FW_rEfetuarDownloadMF_ECF_Daruma(sArquivo);
  GravaLog('rEfetuarDownloadMF_ECF_Daruma <- iRet: ' + IntToStr(iRet));
  TrataRetornoDarumaFW(iRet);

  If iRet = 1 then
  begin
    DeleteFile(PathArquivo  + sArquivoTxt);
        
    If not CopiarArquivo( sPath + sArquivo , PathArquivo  + sArquivoTxt  ) then
    begin
      ShowMessage( 'Erro ao copiar o arquivo ' +  sPath + sArquivo + ' para ' + PathArquivo + sArquivoTxt );
      Result := '1';
    end
    else
    begin
      GravaLog(' Daruma DownloadMF( ' + sPath + sArquivo +','+ PathArquivo +  sArquivoTxt + ')' );
      Result := '0';
    end
  end
  Else Result := '1';
End;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.HorarioVerao( Tipo:AnsiString ):AnsiString;
var iRet : Integer;
begin
  Result := '0';
  If Trim( Tipo ) = '+' then
  begin
    //*******************************************************************
    // Coloca a impressora no horário de verao
    //*******************************************************************
    GravaLog('confHabilitarHorarioVerao_ECF_Daruma ->');
    iRet := fFuncDaruma_FW_confHabilitarHorarioVerao_ECF_Daruma();
    GravaLog('confHabilitarHorarioVerao_ECF_Daruma <- iRet:' + IntToStr(iRet));
    TrataRetornoDarumaFW( iRet );
    If iRet <> 1
    then Result := '1';
  end
  else
  begin
    //*******************************************************************
    // Tira a impressora no horário de verao
    //*******************************************************************
    GravaLog('confDesabilitarHorarioVerao_ECF_Daruma ->');
    iRet := fFuncDaruma_FW_confDesabilitarHorarioVerao_ECF_Daruma();
    GravaLog('confDesabilitarHorarioVerao_ECF_Daruma <- iRet:' + IntToStr(iRet));
    TrataRetornoDarumaFW( iRet );
    If iRet <> 1
    then Result := '1';
  end;
end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString): AnsiString;
var
  iRet : Integer;
begin
 //as informações saem no inicio do cupom, mantido por compatibilidade
 If (Trim(cCPFCNPJ) <> '') or (Trim(cCliente) <> '') or (Trim(cEndereco) <> '') then
 begin
   GravaLog(' iCFIdentificarConsumidor_ECF_Daruma ->');
   iRet := fFuncDaruma_FW_iCFIdentificarConsumidor_ECF_Daruma(pchar(cCliente), pchar(cEndereco), pchar(cCPFCNPJ));
   GravaLog(' iCFIdentificarConsumidor_ECF_Daruma <- iRet : ' + IntToStr(iRet));
   TrataRetornoDarumaFW( iRet );

   If iRet = 1
   then Result := '0|'
   else Result := '1|';
 end
 else
   Result := '0|';

end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
var
  iRet : Integer;
begin

 //existem duas funções na DarumaFrameWork para Estorno do CDC, neste caso
 //uso a que cancela o ultimo comprovante impresso, se utilizar a função iCCDEstornar_ECF_Daruma
 //e os parâmetros acima pode-se cancelar qualquer comprovante ( não somente o ultimo CCD )
If (Trim(COOCDC) <> '') and (Trim(CPFCNPJ) <> '') and (Trim(Cliente) <> '') and (Trim(Endereco) <> '') then
begin
  GravaLog('iCCDEstornar_ECF_Daruma -> COO:' + COOCDC + ', CpfCnpj: ' + CPFCNPJ + ', Cliente: ' + Cliente + ', Endereco:' + Endereco);
  iRet := fFuncDaruma_FW_iCCDEstornar_ECF_Daruma(pChar(COOCDC),pChar(CPFCNPJ),pChar(Cliente),pChar(Endereco));
  GravaLog('<- iCCDEstornar_ECF_Daruma : ' + IntToStr(iRet));
end
else
begin
  GravaLog('-> iCCDEstornarPadrao_ECF_Daruma ');
  iRet := fFuncDaruma_FW_iCCDEstornarPadrao_ECF_Daruma();
  GravaLog('<- iCCDEstornarPadrao_ECF_Daruma : ' + IntToStr(iRet));
end;

TrataRetornoDarumaFW( iRet );

if iRet = 1
then Result := '0|'
else Result := '1|';

end;

//----------------------------------------------------------------------------
function TImpDarumaFrameWork.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;
var
  i       : Integer;
  iRet    : Integer;
  sTexto,sAux,sInformacao,sRetorno : AnsiString;
begin
  sRetorno := '0';

  //****************************************************************************
  // Verifica se existe cupom não fiscal aberto. Se existir, faz o fechamento
  //****************************************************************************
  sInformacao := Space(1);
  iRet := RetornaInfoECFFW('57',sInformacao);
  i := 1;

  If iRet = 1 then
  begin
    iRet := TrataCupomNFiscal(StrToInt(sInformacao));
    If iRet <> 1
    then sRetorno := '1';

    If iRet = 1 then
    begin
      While i <= Vias do
      begin
        GravaLog('-> iRGAbrirPadrao_ECF_Daruma');
        iRet := fFuncDaruma_FW_iRGAbrirPadrao_ECF_Daruma();
        TrataRetornoDarumaFW(iRet);
        GravaLog('<- iRGAbrirPadrao_ECF_Daruma : ' + IntToStr(iRet));

        If iRet <> 1
        then sRetorno := '1'
        else
        begin
          GravaLog('iRGImprimirTexto_ECF_Daruma -> Cabecalho :' + Cabecalho);

          sAux := Cabecalho;
          While Length(Trim(sAux)) <> 0 do
          begin
            iRet := fFuncDaruma_FW_iRGImprimirTexto_ECF_Daruma( pChar(Copy( sAux, 1, 619 )) );
            sAux := Copy(sAux,620,Length(sAux));
          end;
          TrataRetornoDarumaFW(iRet);
          GravaLog('<- iRGImprimirTexto_ECF_Daruma : ' + IntToStr(iRet));

          If iRet <> 1
          then sRetorno := '1'
          else
          begin
            sTexto := Codigo;

            GravaLog('-> iImprimirCodigoBarras_ECF_Daruma ');
            while Length(sTexto) > 0 do
            begin
              iRet   := fFuncDaruma_FW_iImprimirCodigoBarras_ECF_Daruma( '04', '3', '125','0',
                                                              Copy(sTexto, 1, 50 ), 'h', Copy(Rodape,1,600));
              sTexto := Copy( sTexto, 51, Length( sTexto ) );
            end;

            TrataRetornoDarumaFW(iRet);
            GravaLog('<- iImprimirCodigoBarras_ECF_Daruma : ' + IntToStr(iRet));

            If iRet <> 1
            then sRetorno := '1';
          end;

          GravaLog('-> iRGFechar_ECF_Daruma');
          iRet := fFuncDaruma_FW_iRGFechar_ECF_Daruma();
          TrataRetornoDarumaFW(iRet);
          GravaLog('<- iRGFechar_ECF_Daruma : ' + IntToStr(iRet));

          If iRet = 1
          then sRetorno := '0'
          else sRetorno := '1';

        end;

        Inc(i);
      end;
    end;
  end
  else
     sRetorno := '1';

Result := sRetorno;

end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.GeraArquivoMFD(cDadoInicial, cDadoFinal,
  cTipoDownload, cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica,
  cChavePrivada: AnsiString; iUnicoArquivo: integer): AnsiString;

Var
  iRet: Integer;   // Retorno da dll
  sNumSerie2,sNomeArq, sArqOrigem, sArqDestino, sTpArquivo,sNomeArqDest : AnsiString;
begin
  {Pega número de série para compor o nome padrão do arquivo exigido pelo PAF-ECF}
  sNumSerie2 := PegaSerie;
  sNumSerie2 := Copy(sNumSerie2,3,Length(sNumSerie2)-2);

  {Configura o diretório onde serão gerados os arquivos pelo ECF}
  iRet := StrToInt(RegistroDarumaFW('START','LocalArquivosRelatorios','','',sPathEcfRegistry)); //PathArquivo
  TrataRetornoDarumaFW( iRet );

  If iRet = 1 then
  begin
    GravaLog('-> eBuscarPortaVelocidade_ECF_Daruma');
    iRet := fFuncDaruma_FW_eBuscarPortaVelocidade_ECF_Daruma();
    GravaLog('<- eBuscarPortaVelocidade_ECF_Daruma : ' + IntToStr(iRet));
    TrataRetornoDarumaFW( iRet );

    {Processa por data}
    If cTipoDownload = 'D' Then
    Begin
      {Formata valores}
      cDadoInicial  := FormatDateTime('ddMMyyyy',StrToDate(cDadoInicial));
      cDadoFinal    := FormatDateTime('ddMMyyyy',StrToDate(cDadoFinal));

      {Formata nome do Arquivo}
      sNomeArq := 'AtocotepeMF_Data.TXT';
      sTpArquivo := 'DATAM';
    End
    Else   {Processa por COO}
    Begin
      {Formata nome do Arquivo}
      sNomeArq := 'AtocotepeMF_COO.TXT';
      sTpArquivo := 'CRZ';
    End;
  End;

  If iRet = 1 then
  begin
    GravaLog('-> rGerarRelatorio_ECF_Daruma ');
    iRet := fFuncDaruma_FW_rGerarRelatorio_ECF_Daruma(pChar('MF'),pChar(sTpArquivo),pChar(cDadoInicial),pChar(cDadoFinal));
    GravaLog('rGerarRelatorio_ECF_Daruma <- iRet: ' + IntToStr(iRet));
    TrataRetornoDarumaFW( iRet );
  end;

  {Não Remove a assinatura -- não traz assinado}
  If iRet = 1 Then
  Begin
    //segundo o Ato Cotepe 17/04 o nome do arquivo a ser gerado eh: MFxxxxxx_aaaammdd_hhmmss.TXT
    //onde xxxxxxx: é a série do ECF
    //aaaammdd: data da geração do arquivo
    //hhmmss  : hora da geração do arquivo
    sNomeArqDest:= 'MF'+sNumSerie2+'_'+FormatDateTime('yyyyMMdd',Now)+'_'+FormatDateTime('hhmmss',Now)+'.TXT';
    //sArqDestino := PathArquivo + DEFAULT_PATHARQMFD + sNomeArqDest;
    sArqDestino := sPathEcfRegistry + sNomeArqDest;
    sArqOrigem  := sPathEcfRegistry + sNomeArq;

    //Caso exista, remove arquivo gerado com o mesmo nome
    If FileExists(sArqDestino)
    Then DeleteFile(sArqDestino);

    If not CopiarArquivo(sArqOrigem,sArqDestino) then
    begin
      MsgStop('Não foi possível copiar aquivo : [' + sArqOrigem + ' ] para o caminho : [' + sArqDestino +']');
      GravaLog('Não foi possível copiar aquivo : [' + sArqOrigem + ' ] para o caminho : [' + sArqDestino +']')
    end;
  End;

   If iRet = 1
   then Result := '0'
   Else Result := '1';
end;

//------------------------------------------------------------------------------
Function TrataCupomNFiscal( StatusCupom : Integer): Integer;
var
   iRet : Integer;
   bEncerra : Boolean;
begin
  bEncerra := False;
  iRet     := 0;
  GravaLog(' TrataCupomNFiscal -> StatusCupom ' + IntToStr(StatusCupom));

  Try
    Case StatusCupom of
      5..6: bEncerra := False; //Cancela o cupom

      7: begin
           GravaLog('-> iCNFEfetuarPagamentoPadrao_ECF_Daruma');
           iRet := fFuncDaruma_FW_iCNFEfetuarPagamentoPadrao_ECF_Daruma();
           GravaLog('<- iCNFEfetuarPagamentoPadrao_ECF_Daruma : ' + IntToStr(iRet));
           TrataRetornoDarumaFW(iRet);

           if iRet = 1
           then bEncerra := True;
         end;

      8: bEncerra := True; //Tenta efetuar o fechamento do cupom
    end;

    If bEncerra then
    begin
      GravaLog('-> iCNFEncerrarPadrao_ECF_Daruma');
      iRet := fFuncDaruma_FW_iCNFEncerrarPadrao_ECF_Daruma();
      GravaLog('<- iCNFEncerrarPadrao_ECF_Daruma');
      TrataRetornoDarumaFW(iRet);
      if iRet <> 1
      then bEncerra := False;
    end;

    If (not bEncerra) then
    begin
      GravaLog('-> iCNFCancelar_ECF_Daruma');
      iRet := fFuncDaruma_FW_iCNFCancelar_ECF_Daruma();
      GravaLog('<- iCNFCancelar_ECF_Daruma : ' + IntToStr(iRet));
    end;

  except
    GravaLog('-> iCNFCancelar_ECF_Daruma');
    iRet := fFuncDaruma_FW_iCNFCancelar_ECF_Daruma();
    GravaLog('<- iCNFCancelar_ECF_Daruma : ' + IntToStr(iRet));
  end;

  TrataRetornoDarumaFW(iRet);
  GravaLog(' <- iRet tratado : ' + IntToStr(iRet));
  Result := iRet;
end;

//------------------------------------------------------------------------------
Function CompNaoFiscalFW(sIndTotalizador,sCondicao,Valor,Texto : AnsiString) : AnsiString;
var
   iRet : Integer;
   sRetCOO : AnsiString;
begin
GravaLog('-> iCNFAbrirPadrao_ECF_Daruma');
iRet := fFuncDaruma_FW_iCNFAbrirPadrao_ECF_Daruma();
GravaLog('<- iCNFAbrirPadrao_ECF_Daruma : ' + IntToStr(iRet));
TrataRetornoDarumaFW(iRet);

If iRet = -12 then  //comprovante não fiscal aberto
begin
  GravaLog('-> iCNFCancelar_ECF_Daruma');
  iRet := fFuncDaruma_FW_iCNFCancelar_ECF_Daruma();
  GravaLog('<- iCNFCancelar_ECF_Daruma : ' + IntToStr(iRet));
  TrataRetornoDarumaFW(iRet);

  If iRet = 1 then
  begin
    GravaLog('-> iCNFAbrirPadrao_ECF_Daruma');
    iRet := fFuncDaruma_FW_iCNFAbrirPadrao_ECF_Daruma();
    GravaLog('<- iCNFAbrirPadrao_ECF_Daruma : ' + IntToStr(iRet));
    TrataRetornoDarumaFW(iRet);
  end;
end;

If iRet = 1 then
begin
  GravaLog('iCNFReceber_ECF_Daruma -> Indice :' + sIndTotalizador + ', Valor :' + Valor);
  iRet := fFuncDaruma_FW_iCNFReceberSemDesc_ECF_Daruma(pChar(sIndTotalizador),pChar(Valor));
  GravaLog('<- iCNFReceber_ECF_Daruma :' + IntToStr(iRet));
  TrataRetornoDarumaFW(iRet);

  if iRet = 1 then
  begin
    GravaLog(' -> iCNFTotalizarComprovantePadrao_ECF_Daruma');
    iRet := fFuncDaruma_FW_iCNFTotalizarComprovantePadrao_ECF_Daruma();
    GravaLog('<- iCNFTotalizarComprovantePadrao_ECF_Daruma :' + IntToStr(iRet));
    TrataRetornoDarumaFW(iRet);

    If iRet = 1 then
    begin
      GravaLog('iCNFEfetuarPagamentoFormatado_ECF_Daruma -> Condicao:' + sCondicao + ', Valor:' + Valor);
      iRet := fFuncDaruma_FW_iCNFEfetuarPagamentoFormatado_ECF_Daruma(pChar(sCondicao),pChar(Valor));
      GravaLog('<- iCNFEfetuarPagamentoFormatado_ECF_Daruma :' + IntToStr(iRet));
      TrataRetornoDarumaFW(iRet);

      If iRet = 1 then
      begin
        GravaLog('iCNFEncerrar_ECF_Daruma -> Texto:' + Texto);
        If Trim(Texto) = ''
        then iRet := fFuncDaruma_FW_iCNFEncerrarPadrao_ECF_Daruma()
        else iRet := fFuncDaruma_FW_iCNFEncerrar_ECF_Daruma(pChar(Texto));
        TrataRetornoDarumaFW(iRet);


        GravaLog(' <- iCNFEncerrar_ECF_Daruma :' + IntToStr(iRet));
        sRetCOO := Space(30);
        fFuncDaruma_FW_rInfoEstendida1_ECF_Daruma(sRetCOO);
        sRetCOO := Trim(sRetCOO);
        sRetCOO := Copy(sRetCOO,1,6);
      end;
    end;
  end;
end;

Result := IntToStr(iRet) + '|' + sRetCOO;
end;

//------------------------------------------------------------------------------
Function CompCredDebFW(sCOO,sCondicao,Valor,Texto : AnsiString) : Integer;
var
   iRet,i : Integer;
   sAux,sLinha : AnsiString;
   sLista: TStringList;
begin
GravaLog('iCCDAbrirSimplificado_ECF_Daruma -> Condicao:' + sCondicao + ',Parcelas : 1, COO:' + sCOO + ', Valor:' + Valor);
iRet := fFuncDaruma_FW_iCCDAbrirSimplificado_ECF_Daruma(pChar(sCondicao),'1',pChar(sCOO),pChar(Valor));
GravaLog('<- iCCDAbrirSimplificado_ECF_Daruma :' + IntToStr(iRet));
TrataRetornoDarumaFW(iRet);
sAux := Texto;

If iRet = 1 then
begin
  sLista := TStringList.Create;
  sLista.Create;

  i := Pos(#10,sAux);
  While i > 0 do
  Begin
    i      := Pos(#10,sAux);
    sLinha := sLinha + Copy(sAux,1,i) ;
    sAux   := Copy(sAux,i+1,Length(sAux));

    If Length(sLinha) >= 500 Then
    Begin
      sLista.Add(sLinha);
      sLinha := '';
    end;
  End;

  If Trim(sAux) <> '' Then sLinha := ' ' + sLinha + sAux + #10;
  If Trim(sLinha) <> '' Then sLista.Add(sLinha);

  GravaLog('iCCDImprimirTexto_ECF_Daruma -> ');

  For i:= 0 to sLista.Count-1 do
    iRet := fFuncDaruma_FW_iCCDImprimirTexto_ECF_Daruma(pChar(sLista.Strings[i]));

  GravaLog('<- iCCDImprimirTexto_ECF_Daruma :' + IntToStr(iRet));
  TrataRetornoDarumaFW(iRet);

  If iRet = 1 then
  begin
    GravaLog('-> iCCDFechar_ECF_Daruma');
    iRet := fFuncDaruma_FW_iCCDFechar_ECF_Daruma();
    GravaLog('<- iCCDFechar_ECF_Daruma :' + IntToStr(iRet));
    TrataRetornoDarumaFW(iRet);
  end;
end;

Result := iRet;
end;

//------------------------------------------------------------------------------
Function TImpDarumaFrameWork.CapturaBaseISSRedZ : AnsiString;
var
  sLinhaISS,sAliquotas,sIss,
  sVlrBISS, sLinhaAux,sAImp: AnsiString;
  iRet,iIndex,iPos: Integer;
  aRetorno : array of AnsiString;
  fAImp,fImpTotal : Real;
  bArred : Boolean;
begin
  iRet   := 0;
  iIndex := 0;
  Result := '';
  fImpTotal := 0;

  sLinhaISS := Space( 364 );
  iRet := RetornaInfoECFFW('3',sLinhaISS);
  TrataRetornoDarumaFW( iRet );

  if iRet = 1 then
  begin
    sAliquotas := Space( 150 );
    GravaLog(' rLerAliquotas_ECF_Daruma -> ');
    fFuncDaruma_FW_rLerAliquotas_ECF_Daruma( sAliquotas );
    GravaLog(' rLerAliquotas_ECF_Daruma <- iRet:' + IntToStr(iRet) + ', Aliquotas: ' + sAliquotas);
    sAliquotas := Trim( sAliquotas );
    bArred := (StatusImp(13) = '0');

    while (Length(sAliquotas) > 0) do
    begin
     If (Copy( sAliquotas, 1, 1 ) = 'S' ) and (not (AnsiUpperCase(sAliquotas)[2] in ['A'..'Z'])) then   // Separa só as aliquotas de ISS
     begin
       sIss     := Copy( sAliquotas , 2 , 4 );

       If StrToFloat(sIss) > 0 then
       begin
         SetLength( aRetorno , Length(aRetorno) + 1);
         sVlrBISS := Copy( sLinhaISS , 1 , 13 );
         Insert('.',sVlrBISS,Length(sVlrBISS)-1);

         fImpTotal := fImpTotal + StrToFloat(sVlrBISS);
         fAImp := (StrToFloat( sIss ) / 100 )  * ( StrToFloat( sVlrBISS ) /100 );

         If bArred
         then fAImp := Arredondar(fAImp,2);

         sAImp := StrTran(FloatToStr( fAImp ),',','.');

         sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;
         sVlrBISS := Replicate( '0' , 14 - Length( sVlrBISS ) ) + sVlrBISS;

         If ( Length( sAImp ) - Pos( '.', sAImp ) > 2 ) And ( Pos( '.', sAImp ) > 0 )
         Then sAimp := Copy( sAImp, 1, Pos( '.', sAImp ) + 2 );

         If Pos( '.', sAImp ) = 0
         Then sAimp := '00000000000.00'
         Else sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;

         If Length( sAImp ) > 14
         Then sAImp := Copy( sAImp, Length( sAImp ) - 13, Length( sAImp ) );

         sLinhaAux:= 'S' + Copy(sIss,1,2) + '.' + Copy(sIss,3,2) + ' ' + FormataTexto(sVlrBISS,14,2,1) + ' ' + Copy(sAImp,1,14);
         aRetorno[iIndex] := sLinhaAux; // Ex.: SXX.XX XXXXXXXXXXX.XX XXXXXXXXXXX.XX
         Inc(iIndex);
       end;
     end;

     iPos := Pos(sCaracterSep,sAliquotas);

     If iPos = 0
     then iPos := Length(sAliquotas);

     sAliquotas := Copy( sAliquotas, iPos+1 , Length(sAliquotas) );
     sLinhaISS  := Copy( sLinhaISS , 14 , Length(sLinhaISS) );
    end;

  end;

  Result := FormataTexto(StrTran(FloatToStr(fImpTotal),',',''),14,2,1,'.') + ' 00000000000.00' + ';';

  if Length(aRetorno) > 0 then
  begin
    For iIndex := 0 to Length(aRetorno)-1 do
      Result := Result + aRetorno[iIndex] + ';'
  end
  else
     Result := Result + '00000000000.00';
end;

//------------------------------------------------------------------------------
function TImpDarumaFrameWork.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
var
  iRet : Integer;
begin
GravaLog(' eGerarQrCodeArquivo_DUAL_Daruma -> SavePath [' + Trim(SavePath) + '] - QrCode [' + Trim(QrCode) + ']');
iRet := fFuncDaruma_FW_eGerarQrCodeArquivo_DUAL_Daruma(SavePath,Trim(QrCode));
GravaLog(' eGerarQrCodeArquivo_DUAL_Daruma <- iRet : ' + IntToStr(iRet));
TrataRetornoDarumaFW(iRet);
If FileExists(SavePath) then
begin
  iRet := 1;
  GravaLog(' Arquivo Gravado com Sucesso : ' + SavePath);
end
else iRet := 0;

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//------------------------------------------------------------------------------
function  TImpDarumaFrameWork.AbreCNF(CPFCNPJ, Nome, Endereco : AnsiString): AnsiString;
var
  iRet : Integer;
begin
GravaLog('iCNFAbrir_ECF_Daruma -> CPFCNPJ : ' + CPFCNPJ + ' ,Nome : ' + Nome +',Endereco : ' + Endereco);
iRet := fFuncDaruma_FW_iCNFAbrir_ECF_Daruma(CPFCNPJ,Nome,Endereco);
GravaLog('iCNFAbrir_ECF_Daruma <- iRet : ' + IntToStr(iRet));
TrataRetornoDarumaFW(iRet);

If iRet = -12 then  //comprovante não fiscal aberto
begin
  GravaLog('-> iCNFCancelar_ECF_Daruma');
  iRet := fFuncDaruma_FW_iCNFCancelar_ECF_Daruma();
  GravaLog('<- iCNFCancelar_ECF_Daruma : ' + IntToStr(iRet));
  TrataRetornoDarumaFW(iRet);

  If iRet = 1 then
  begin
    GravaLog(' iCNFAbrir_ECF_Daruma ->CpfCnpj,Nome,Endereco:'+CPFCNPJ + ',' + Nome + ',' + Endereco);
    iRet := fFuncDaruma_FW_iCNFAbrir_ECF_Daruma(CPFCNPJ,Nome,Endereco);
    GravaLog('<- iCNFAbrir_ECF_Daruma : ' + IntToStr(iRet));
    TrataRetornoDarumaFW(iRet);
  end;
end;

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//------------------------------------------------------------------------------
function  TImpDarumaFrameWork.RecCNF( IndiceTot , Valor, ValorAcresc,ValorDesc : AnsiString): AnsiString;
var
  iRet : Integer;
  cTipoAD,VlrAdDesc : AnsiString;
begin

iRet := 1;
cTipoAD := '';

//Descontos e acrescimos serão dados baseados no valor
If (Trim(ValorDesc) <> '') and (Trim(ValorDesc) <> '0') then
begin
  cTipoAD := 'D$';
  VlrAdDesc := ValorDesc;
end
else If (Trim(ValorAcresc) <> '') and (Trim(ValorAcresc) <> '0') then
     begin
       cTipoAD := 'A$';
       VlrAdDesc := ValorAcresc;
     end;

if cTipoAD <> '' then
begin
  GravaLog('iCNFReceber_ECF_Daruma -> Indice:' + IndiceTot + ',Valor:' + Valor + ', Tipo AD :' + cTipoAD + ',Valor AD:' + VlrAdDesc);
  iRet := fFuncDaruma_FW_iCNFReceber_ECF_Daruma(pChar(IndiceTot),pChar(Valor),cTipoAD,VlrAdDesc);
  GravaLog('<- iCNFReceber_ECF_Daruma :' + IntToStr(iRet));
end
else
begin
  GravaLog('iCNFReceberSemDesc_ECF_Daruma -> Indice:' + IndiceTot + ', Valor:' + Valor);
  iRet := fFuncDaruma_FW_iCNFReceberSemDesc_ECF_Daruma(pChar(IndiceTot),pChar(Valor));
  GravaLog('<- iCNFReceberSemDesc_ECF_Daruma :' + IntToStr(iRet));
end;

TrataRetornoDarumaFW(iRet);

If iRet = 1
then Result := '0|'
else Result := '1|';
end;


//------------------------------------------------------------------------------
function  TImpDarumaFrameWork.PgtoCNF( FrmPagto , Valor, InfoAdicional, ValorAcresc,ValorDesc : AnsiString): AnsiString;
var
  iRet : Integer;
  cTipoAD,VlrAdDesc,sFrmPag,sVlrPag : AnsiString;
begin

iRet := 1;
cTipoAD := '';

//Descontos e acrescimos serão dados baseados no valor
If (Trim(ValorDesc) <> '') and (Trim(ValorDesc) <> '0') then
begin
  cTipoAD := 'D$';
  VlrAdDesc := ValorDesc;
end
else If (Trim(ValorAcresc) <> '') and (Trim(ValorAcresc) <> '0') then
     begin
       cTipoAD := 'A$';
       VlrAdDesc := ValorAcresc;
     end;

if cTipoAD <> '' then
begin
  GravaLog('-> iCNFTotalizarComprovante_ECF_Daruma');
  iRet := fFuncDaruma_FW_iCNFTotalizarComprovante_ECF_Daruma(cTipoAD,VlrAdDesc);
  GravaLog('<- iCNFTotalizarComprovante_ECF_Daruma :' + IntToStr(iRet));
end
else
begin
  GravaLog('-> iCNFTotalizarComprovantePadrao_ECF_Daruma');
  iRet := fFuncDaruma_FW_iCNFTotalizarComprovantePadrao_ECF_Daruma();
  GravaLog('<- iCNFTotalizarComprovantePadrao_ECF_Daruma :' + IntToStr(iRet));
end;

TrataRetornoDarumaFW(iRet);

If iRet = 1 then
begin

    while Length(FrmPagto)>0 do
    begin
        sFrmPag:=Copy(FrmPagto,1,Pos('|',FrmPagto)-1);

        If sFrmPag = 'DINHEIRO' then sFrmPag:='Dinheiro';

        FrmPagto:= Copy(FrmPagto,Pos('|',FrmPagto)+1,Length(FrmPagto));

        If Pos('|',FrmPagto)>0 then
        begin
           sVlrPag:=Copy(FrmPagto,1,Pos('|',FrmPagto)-1);
            FrmPagto:= Copy(FrmPagto,Pos('|',FrmPagto)+1,Length(FrmPagto));
        end
        Else
        begin
           sVlrPag:=Copy(FrmPagto,1,Length(FrmPagto));
           FrmPagto := '';
        End;

        sVlrPag:=Trim(FormataTexto(sVlrPag,12,2,3));

        if Trim(InfoAdicional) <> '' then
        begin
          GravaLog('-> iCNFEfetuarPagamentoFormatado_ECF_Daruma');
          iRet := fFuncDaruma_FW_iCNFEfetuarPagamento_ECF_Daruma(Copy(sFrmPag,1,15) , sVlrPag,InfoAdicional);
          GravaLog('<- iCNFEfetuarPagamentoFormatado_ECF_Daruma :' + IntToStr(iRet));
        end
        else
        begin
          GravaLog('-> iCNFEfetuarPagamentoFormatado_ECF_Daruma');
          iRet := fFuncDaruma_FW_iCNFEfetuarPagamentoFormatado_ECF_Daruma(Copy(sFrmPag,1,15) , sVlrPag);
          GravaLog('<- iCNFEfetuarPagamentoFormatado_ECF_Daruma :' + IntToStr(iRet));
        end;
        TrataRetornoDarumaFW(iRet);
    end;
end;

If iRet = 1
then Result := '0|'
else Result := '1|';
end;

//------------------------------------------------------------------------------
function  TImpDarumaFrameWork.FechaCNF( Mensagem : AnsiString): AnsiString;
var
  iRet : Integer;
begin

iRet := 1;
GravaLog('-> iCNFEncerrar_ECF_Daruma');
If Trim(Mensagem) = ''
then iRet := fFuncDaruma_FW_iCNFEncerrarPadrao_ECF_Daruma()
else iRet := fFuncDaruma_FW_iCNFEncerrar_ECF_Daruma(pChar(Mensagem));
GravaLog('<- iCNFEncerrar_ECF_Daruma :' + IntToStr(iRet));

TrataRetornoDarumaFW(iRet);

If iRet = 1
then Result := '0|'
else Result := '1|';
end;

//----------------------------------------------------------------------------
Function TrataRetornoDarumaFw( var iRet:Integer  ):AnsiString;
var
  sMsg,sErro,sWarning : AnsiString;
  iErro,iWarning,iFuncRet: SmallInt;
begin

  If (iRet <> -12) and (iRet <> 1) then
  begin
    sMsg := MsgErroDarumaFW( iRet );
    MsgStop( sMsg );
  end
  else If (iRet = -12) then
  begin
    GravaLog('-> rStatusUltimoCmdInt_ECF_Daruma ');
    iFuncRet := fFuncDaruma_FW_rStatusUltimoCmdInt_ECF_Daruma(iErro,iWarning);
    GravaLog('<- rStatusUltimoCmdInt_ECF_Daruma :' + IntToStr(iFuncRet));

    sErro := Space(200);
    GravaLog('-> eInterpretarErro_ECF_Daruma');
    iFuncRet := fFuncDaruma_FW_eInterpretarErro_ECF_Daruma(iErro,sErro);
    GravaLog('<- eInterpretarErro_ECF_Daruma : ' + IntToStr(iFuncRet));

    sWarning := Space(200);
    GravaLog('-> eInterpretarAviso_ECF_Daruma');
    iFuncRet := fFuncDaruma_FW_eInterpretarAviso_ECF_Daruma(iWarning,sWarning);
    GravaLog('<- eInterpretarAviso_ECF_Daruma : ' + IntToStr(iFuncRet));

    if iWarning > 0 then
    begin
      GravaLog(' TrataRetornoDarumaFw -> Aviso(' + IntToStr(iWarning) + ') encontrado : ' + Trim(sWarning));

      If iWarning = 1
      then begin
             //ShowMessage('Papel Acabando');
             GravaLog('DarumaFrame -> Papel Acabando');
             iRet := 1;
           end
      else If iWarning = 2
      then begin
             LjMsgDlg('Tampa da Impressora Aberta');
             GravaLog('DarumaFrame -> Tampa da Impressora Aberta');
             iRet := -1;
           end
      else If iWarning = 4
      then begin
             LjMsgDlg('Bateria fraca');
             GravaLog('DarumaFrame -> Bateria fraca');
             iRet := 1;
           end
      else If iWarning = 40
      then begin
             LjMsgDlg('Compactando');
             GravaLog('DarumaFrame -> Compactando');
             iRet := -1;
           end;
    end;

    If (iErro > 0) then
    begin
      GravaLog(' TrataRetornoDarumaFw -> Erro(' + IntToStr(iErro) + ') encontrado : ' + Trim(sErro));

      If LowerCase(Trim(sErro)) = LowerCase('Papel acabando')
      then iRet := 1
      else
      begin
        iRet := -1;
        LjMsgDlg('Erro encontrado :' + Trim(sErro) );
        GravaLog('DarumaFrame -> Erro encontrado :' + Trim(sErro));
      end;
    end;

  end
  else if iRet = -27
       then Status_ImpressoraFW(False);

  Result := '';
end;

//----------------------------------------------------------------------------
Function MsgErroDarumaFW( iIndice:Integer ):AnsiString;
var
  sMsg : AnsiString;
  iRet : Integer;
begin
  //Nesta DLL os retornos por escrito retornam a partir do comando abaixo
  sMsg := Space(200);
  GravaLog('-> eInterpretarRetorno_ECF_Daruma ');
  iRet := fFuncDaruma_FW_eInterpretarRetorno_ECF_Daruma(iIndice,sMsg);
  GravaLog('<- eInterpretarRetorno_ECF_Daruma : ' + IntToStr(iRet));
  Result := 'DLL Fiscal DarumaFrameWork -> Retorno: ' + IntToStr(iIndice) + ' , Mensagem : ' + Trim(sMsg);
end;

//------------------------------------------------------------------------------
Function Status_ImpressoraFW( lMensagem:Boolean ): Integer;
var
   sRet,sRet2,sRet3,sRet4,sRet5,sMsg,sLinha : AnsiString;
   iRet : Integer;
begin
//Habilita Retorno Estendido no ECF
RegistroDarumaFW('ECF','ReceberInfoEstendida','','','1');

sLinha := CHR(10) + CHR(13);
sRet := Space(30);
sRet2 := Space(30);
sRet3 := Space(30);
sRet4 := Space(30);
sRet5 := Space(30);

GravaLog(' Capturando os retornos estendidos ...');
iRet := fFuncDaruma_FW_rInfoEstendida1_ECF_Daruma(sRet);
iRet := fFuncDaruma_FW_rInfoEstendida2_ECF_Daruma(sRet2);
iRet := fFuncDaruma_FW_rInfoEstendida3_ECF_Daruma(sRet3);
iRet := fFuncDaruma_FW_rInfoEstendida4_ECF_Daruma(sRet4);
iRet := fFuncDaruma_FW_rInfoEstendida5_ECF_Daruma(sRet5);

sMsg := 'Retorno 1: ' + Trim(sRet) + sLinha;
sMsg := sMsg + 'Retorno 2 :' + Trim(sRet2) + sLinha;
sMsg := sMsg + 'Retorno 3 :' + Trim(sRet3) + sLinha;
sMsg := sMsg + 'Retorno 4 :' + Trim(sRet4) + sLinha;
sMsg := sMsg + 'Retorno 5 :' + Trim(sRet5) + sLinha;

//if lMensagem
//then ShowMessage(sMsg);
GravaLog(' Retorno Estendido :' + sMsg);

Result := iRet;

end;

//------------------------------------------------------------------------------
Function TrataArq(cPathArq : AnsiString): Boolean;
var
  ListaArquivo : TStringList;
  aArquivo : TextFile;
  sLinha,sTexto : AnsiString;
  nPos,nX : Integer;
begin

Try
  ListaArquivo := TStringList.Create;
  ListaArquivo.Clear;
  ListaArquivo.LoadFromFile(cPathArq);
  sTexto := '';
  
  For nX := 0 to Pred(ListaArquivo.Count) do
  begin
    nPos := Pos('<InformacoesSobreArquivo>',ListaArquivo.Strings[nX]);

    If nPos = 0 then
    begin
     sTexto := sTexto + ListaArquivo.Strings[nX];
    End;
  end;

  DeleteFile(cPathArq);
  ListaArquivo.Clear;
  ListaArquivo.Add(sTexto);
  ListaArquivo.SaveToFile(cPathArq);
Except
end;

(*AssignFile(aArquivo,cPathArq);
sTexto := '';

{$I-}
Reset(aArquivo); // [ 3 ] Abre o arquivo texto para leitura
{$I+} // ativa a diretiva de Input

if (IOResult <> 0) // verifica o resultado da operação de abertura
then ListaArquivo.Add('Erro na abertura do arquivo !!!')
else
begin // [ 11 ] verifica se o ponteiro de arquivo atingiu a marca de final de arquivo
  Readln(aArquivo,sLinha);
  sTexto := sTexto + sLinha;

  while not Eof(aArquivo) do
  begin
    readln(aArquivo, sLinha); // [ 6 ] Lê uma linha do arquivo
    sTexto := sTexto + sLinha;
  end;
end;

CloseFile(aArquivo); // [ 8 ] Fecha o arquivo texto aberto
DeleteFile(cPathArq);
nPos := Pos('<InformacoesSobreArquivo>',sTexto);
If nPos > 0
then sTexto := Copy(sTexto,1,nPos-1)
else sTexto := sTexto;

ListaArquivo.Clear;
ListaArquivo.Add(sTexto);
ListaArquivo.SaveToFile(cPathArq);
Result := True;*)
end;

//******************************************************************************
//******************************************************************************
{ TImpDarumaFrameCV0909 }
(*function TImpDarumaFrameCV0909.DownMF(sTipo, sInicio, sFinal: AnsiString): AnsiString;
var
  sPath,sArquivo,sArquivoTxt,sLinha : AnsiString;
  iRet  : Integer;
  mArqMF: TStringList;
  aArquivo : TextFile;
Begin
  sArquivo := 'DARUMAMFISCAL.MF';
  sArquivoTxt := 'MFISCAL.BIN';
  {sPath := RegistroDarumaFW('START','','','','LocalArquivosRelatorios','S');
  If sPath[1] = '1'
  then sPath := Copy(sPath,3,Length(sPath));

  if sPath[Length(sPath)] <> '\'
  then sPath := sPath + '\';

  GravaLog('rEfetuarDownloadMF_ECF_Daruma -> Arquivo: ' + sPath+sArquivo);
  iRet := fFuncDaruma_FW_rEfetuarDownloadMF_ECF_Daruma(sPath+sArquivo);
  GravaLog('rEfetuarDownloadMF_ECF_Daruma <- iRet: ' + IntToStr(iRet));
  TrataRetornoDarumaFW(iRet);

  If iRet = 1 then
  begin
    TrataArq(sPath + sArquivo);

    If not CopiarArquivo( PChar(  sPath + sArquivo ), PChar( PathArquivo  + sArquivoTxt ), False ) then
    begin
      ShowMessage( 'Erro ao copiar o arquivo ' +  sPath + sArquivo + ' para ' + PathArquivo + sArquivoTxt );
      Result := '1';
    end
    else
    begin
      GravaLog(' Daruma DownloadMF ->( ' + sPath + sArquivo +','+ PathArquivo +  sArquivoTxt + ')' );
      Result := '0';
    end
  end
  Else Result := '1';  }

  mArqMF := TStringList.Create();
  mArqMF.Clear;
  mArqMF.Add(NumSerie + ' ' + Eprom);
  DeleteFile(PathArquivo  + sArquivoTxt);
  mArqMF.SaveToFile(PathArquivo  + sArquivoTxt);

  If FileExists(PathArquivo  + sArquivoTxt)
  then
  begin
    GravaLog(' Arquivo gravado [' + PathArquivo + sArquivoTxt + ']');
    Result := '0';
  end
  else
  begin
    ShowMessage( 'Erro ao criar o arquivo [' + PathArquivo + sArquivoTxt + ']');
    Result := '1';
  end;
End;  *)

//------------------------------------------------------------------------------
function TImpDarumaFrameCV0909.PegaCupom(Cancelamento: AnsiString): AnsiString;
var
  lFinaliza : Boolean;
  iCont,iRet : Integer;
  sNumCupom : AnsiString;
begin
  lFinaliza := False;
  iCont     := 1;

  While (not lFinaliza) and (iCont <= 5)do
  begin
      (* Pega o numero do cupom *)
      sNumCupom := Space ( 9 );

      {Tenta pegar o numero do cupom. Se der algum erro, dá uma pausa
       de alguns segundo e tenta pegar o numero do cupom novamente. Faz isto por 5
       vezes, aumentando o intervalo de tempo entre as tentativas. }

      iRet := RetornaInfoECFFW('26',sNumCupom);
      sNumCupom := sNumCupom;
      GravaLog(' PegaCupom - iRet: ' + IntToStr(iRet) + ' ; Numero do Cupom :' + sNumCupom);
      TrataRetornoDarumaFW( iRet );
      
      If iRet = 1
      then lFinaliza := True
      else
      begin
        Sleep( 500 * iCont );
        Inc( iCont );
      end;
  end;

  { Verifica o retorno da função para pegar o numero do cupom }
  TrataRetornoDarumaFW( iRet );
  If iRet = 1
  then Result := '0|' + sNumCupom
  Else Result := '1';
end;

initialization
 RegistraImpressora('DARUMA [FW] FS600 - V. 01.02.00' , TImpDarumaFrameWork  ,'BRA','080802');
 RegistraImpressora('DARUMA [FW] FS600 - V. 01.03.00' , TImpDarumaFrameWork  ,'BRA','080803');
 RegistraImpressora('DARUMA [FW] FS600 - V. 01.04.00' , TImpDarumaFrameWork  ,'BRA','080804');
 RegistraImpressora('DARUMA [FW] FS600 - V. 01.05.00' , TImpDarumaFrameWork  ,'BRA','080805');
 RegistraImpressora('DARUMA [FW] FS600 USB - V. 01.00.00' , TImpDarumaFrameWork  ,'BRA','080805');
 RegistraImpressora('DARUMA [FW] FS700 H - V. 01.01.00' , TImpDarumaFrameWork  ,'BRA','081201');
 RegistraImpressora('DARUMA [FW] FS700 M - V. 01.01.00' , TImpDarumaFrameWork  ,'BRA','081101');
 RegistraImpressora('DARUMA [FW] FS700 L - V. 01.00.00' , TImpDarumaFrameWork  ,'BRA','081001');
 RegistraImpressora('DARUMA [FW] FS700 MATCH 1 - V. 01.00.00' , TImpDarumaFrameWork  ,'BRA','081301');
 RegistraImpressora('DARUMA [FW] FS700 MATCH 2 - V. 01.00.00' , TImpDarumaFrameWork  ,'BRA','081401');
 RegistraImpressora('DARUMA [FW] FS700 MATCH 3 - V. 01.00.00' , TImpDarumaFrameWork  ,'BRA','081501'); 
 RegistraImpressora('DARUMA [FW] FS800i - V. 01.00.00' , TImpDarumaFrameCV0909  ,'BRA','081601');

end.
