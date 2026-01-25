unit ImpSigTron;

 //*****************************************************************************************
 //TrataTags -> As Tags não precisarão ser implementadas pois elas são baseadas nas flags da Daruma
 //o texto que o Protheus enviara contera a tag que irá direto para o comando da impressora
 //sem tratamento, como nas outras impressoras.
 //*****************************************************************************************

interface

uses
  Forms,
  Dialogs,
  ImpFiscMain,
  ImpCheqMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  FormSigtron,
  IniFiles,
  SIGDRCMLib_TLB,
  Registry,
  FileCtrl;

const
  pBuffSize = 200;

Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sigtron
///
  TImpFiscalSigtron = class(TImpressoraFiscal)
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function AbreEcf:AnsiString; override;
    function FechaEcf:AnsiString; override;
    function LeituraX:AnsiString; override;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
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
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString; override;
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
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override ;
    function RedZDado( MapaRes:AnsiString ):AnsiString; override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sigtron 1.20
///
  TImpFiscalSigtron120 = class(TImpFiscalSigtron)
  public
    function PegaSerie:AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
end;

  TImpFiscalSigtron2000 = class(TImpFiscalSigtron)
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function AbreEcf:AnsiString; override;
    function LeAliquotas:AnsiString; override;
    function LeAliquotasISS:AnsiString; override;
    function PegaPDV:AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function LeCondPag:AnsiString; override;
    function GravaCondPag( Condicao:AnsiString ):AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;
  end;

  TImpFiscalDaruma120 = class(TImpFiscalSigtron)
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    procedure AlimentaProperties; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function LeituraX:AnsiString; override;
    function AbreEcf:AnsiString; override;
    function FechaEcf:AnsiString; override;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function PegaPDV:AnsiString; override;
    function LeAliquotas:AnsiString; override;
    function LeAliquotasISS:AnsiString; override;
    function LeCondPag:AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function Gaveta:AnsiString; override;
    function GravaCondPag( Condicao:AnsiString ):AnsiString; override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ): AnsiString; override;
    function PegaSerie:AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString ;Vias:Integer; ImgQrCode: AnsiString):AnsiString; override;
    function HorarioVerao( Tipo:AnsiString ):AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
end;

  TImpFiscalDaruma345 = class(TImpFiscalDaruma120)
  public
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
  end;

  TImpFiscalDaruma2000 = class(TImpFiscalDaruma120)
  public
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    procedure AlimentaProperties; override;
    function PegaSerie:AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString; Override;
  end;

  TImpFiscalDaruma2100 = class(TImpFiscalDaruma2000)
  public
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; Override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString):AnsiString; Override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ): AnsiString; override;
  end;

  TImpFiscalDaruma600_v0102 = class(TImpFiscalDaruma2100)
  public
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; Override;
  end;

  TImpFiscalDaruma600_v0103 = class(TImpFiscalDaruma2100)
  public
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; Override;
    function GeraArquivoMFD(cDadoInicial, cDadoFinal, cTipoDownload, cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica, cChavePrivada: AnsiString; iUnicoArquivo: integer): AnsiString; Override;
  end;

  TImpFiscalDarumaMatch = class(TImpFiscalDaruma600_v0103)
  public
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Sigtron FS-2000
///
  TImpChequeSigtron2000 = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;


////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Daruma utilizando DARUMA32.DLL
///
  TImpCheqDaruma2000 = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function Fechar(aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;

  TImpCheqDaruma2100 = class(TImpCheqDaruma2000);
////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenSigtron( sPorta,sCFGFile:AnsiString ) : AnsiString;
Function CloseSigtron : AnsiString;
Function OpenSigtronDLL : AnsiString;
Function CloseSigtronDLL : AnsiString;
Function OpenDaruma(sPorta: AnsiString) : AnsiString;
Function CloseDaruma : AnsiString;
Function TrataRetornoDaruma( var iRet:Integer; Tipo:Integer = 1 ):AnsiString;
Function MsgErroDaruma( iRet:Integer ):AnsiString;
Function Status_Impressora( lMensagem:Boolean; Tipo: integer = 1  ): Integer;
Function CapturaBaseISSRedZ : AnsiString;

implementation
var
  bOpened     : Boolean;
  fHandle     : THandle;
  fHandle2    : THandle; //DarumaFrameWork.dll
  sPortaAux   : AnsiString;
  sCFGFileAux : AnsiString;
  lDescAcres  : Boolean = False;
  sMarca      : AnsiString;                         // Marca da ECF
  sPathEcfRegistry : AnsiString = 'C:\';            // Path da ECF no Registry
  sArqEcfDefault   : AnsiString = 'RETORNO.TXT';    // Arquivo Retorno
  fFuncDAR_sDescEstendida    : function (Aliquota: AnsiString; Codigo: AnsiString; Desconto: AnsiString; Porcento: AnsiString; Preco: AnsiString; Quantidade: AnsiString; CasasDecimais: AnsiString;Unidade: AnsiString;descricao: AnsiString; Venda: AnsiString): Integer; StdCall;
  fFuncDAR_AbreSerial        : function (conf:AnsiString): Integer;stdcall;
  fFuncDAR_FechaSerial       : function (wait:char): Integer;stdcall;
  fFuncDAR_LeituraX          : function (wait:char): Integer;stdcall;
  fFuncDAR_Erro              : function (): Integer;stdcall;

  fFuncDaruma_FI_AbrePortaSerial        : function (): Integer;stdcall;
  fFuncDaruma_FI_FechaPortaSerial       : function (): Integer;stdcall;
  fFuncDaruma_FI_MapaResumo             : function (): Integer;stdcall;

  // Funções do Registry //////////////////////////////////////////////
  fFuncDaruma_Registry_ZAutomatica           : function (Automat: AnsiString ): Integer;stdcall;
  fFuncDaruma_Registry_RetornaValor          : function (NomeProduto, ChaveProduto : AnsiString; var Valor : AnsiString ): Integer;stdcall;
  fFuncDaruma_Registry_MFD_LeituraMFCompleta : function (Tipo: AnsiString): Integer; StdCall;
  fFuncDaruma_Registry_AlterarRegistry       : function (Produto: AnsiString; Chave: AnsiString; Valor: AnsiString): Integer; StdCall;

  // Funções dos Relatórios Fiscais //////////////////////////////////////////////
  fFuncDaruma_FI_LeituraX                           : function (): Integer;stdcall;
  fFuncDaruma_FI_ReducaoZ                           : function (sData, sHora: AnsiString): Integer;stdcall;
  fFuncDaruma_FI_RelatorioGerencial                 : function (Texto: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_FechaRelatorioGerencial            : function ():Integer; StdCall;
  fFuncDaruma_FI_LeituraMemoriaFiscalData           : function (DataInicial: AnsiString; DataFinal: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_LeituraMemoriaFiscalReducao        : function (ReducaoInicial: AnsiString; ReducaoFinal: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_LeituraMemoriaFiscalSerialData     : function (DataInicial: AnsiString; DataFinal: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_LeituraMemoriaFiscalSerialReducao  : function (ReducaoInicial: AnsiString; ReducaoFinal: AnsiString): Integer; StdCall;
  fFuncDaruma_FIMFD_AbreRelatorioGerencial          : function (NomeRelatorio: AnsiString): Integer; StdCall;
  fFuncDaruma_FIMFD_VerificaRelatoriosGerenciais    : function (RelatoriosGerenciais: AnsiString): Integer; StdCall;

  // Funções de Codigo de Barras
  fFuncDaruma_FIMFD_ImprimeCodigoBarras             :function (TipoCodBarras,CodigoBarras,LarguraBarra,AlturaBarra,ImprimeCodAbaixo: AnsiString): Integer;StdCall;

  // Funções de Inicialização ////////////////////////////////////////////////////
  fFuncDaruma_FI_NomeiaTotalizadorNaoSujeitoIcms    : function (Indice: Integer; Totalizador: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_ProgramaAliquota                   : function (Aliquota: AnsiString; ICMS_ISS: Integer): Integer; StdCall;
  fFuncDaruma_FI_CfgHorarioVerao                    : function (Tipo: AnsiString): Integer; StdCall;

  // Funções do Cupom Fiscal /////////////////////////////////////////////////////
  fFuncDaruma_FI_AbreCupom                          : function (CGC_CPF: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_VendeItem                          : function (Codigo,Descricao,Aliquota,TipoQuantidade,Quantidade:AnsiString; CasasDecimais:Integer; ValorUnitario,TipoDesconto,Desconto:AnsiString): Integer; StdCall;
  fFuncDaruma_FI_CancelaCupom                       : function ():Integer; StdCall;
  fFuncDaruma_FI_IniciaFechamentoCupom              : function (AcrescimoDesconto: AnsiString; TipoAcrescimoDesconto: AnsiString; ValorAcrescimoDesconto: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_EfetuaFormaPagamento               : function (FormaPagamento: AnsiString; ValorFormaPagamento: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_FechaCupom                         : function (FormaPagamento: AnsiString; AcrescimoDesconto: AnsiString; TipoAcrescimoDesconto: AnsiString; ValorAcrescimoDesconto: AnsiString; ValorPago: AnsiString; Mensagem: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_CancelaItemGenerico                : function (NumeroItem: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_AumentaDescricaoItem               : function (Descricao: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_TerminaFechamentoCupom             : function (Mensagem: AnsiString): Integer; StdCall;

  // Funções de Informações da Impressora ////////////////////////////////////////
  fFuncDaruma_FI_RetornoAliquotas                   : function (Aliquotas: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_LerAliquotasComIndice              : function (Aliquotas: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_RetornoImpressora                  : function (Var ACK: Integer; Var ST1: Integer; Var ST2: Integer): Integer; StdCall;
  fFuncDaruma_FI_NumeroCaixa                        : function (NumeroCaixa: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_VersaoFirmware                     : function (VersaoFirmware: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_DataMovimento                      : function (Data: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_NumeroReducoes                     : function (NumeroReducoes: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_GrandeTotal                        : function (GrandeTotal: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_NumeroCupom                        : function (NumeroCupom: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_Cancelamentos                      : function (ValorCancelamentos: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_Descontos                          : function (ValorDescontos: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_VerificaTotalizadoresParciais      : function (Totalizadores: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_VerificaFormasPagamentoEx          : function (Formas: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_VerificaIndiceAliquotasIss         : function (Flag: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_DataHoraImpressora                 : function (Data: AnsiString; Hora: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_VerificaEstadoImpressora           : function (Var ACK: Integer; Var ST1: Integer; Var ST2: Integer): Integer; StdCall;
  fFuncDaruma_FI_VerificaTruncamento                : function (Flag: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_NumeroSerie                        : function (NumeroSerie: AnsiString): Integer; StdCall;
  fFuncDaruma_FIR_RetornaCRO                        : function (Valor: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_RetornaErroExtendido               : function (Valor: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_StatusCupomFiscal                  : function (StatusCF: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_RetornaIndiceComprovanteNaoFiscal  : function (Totalizadro: AnsiString; var Indice:AnsiString): Integer; StdCall;
  fFuncDaruma_FI_PalavraStatusBinario               : function (Informacao: pchar): Integer; StdCall;
  fFuncDaruma_FI_StatusComprovanteNaoFiscalVinculado: function (Informacao: pchar): Integer; StdCall;
  fFuncDaruma_FI_VendaBruta                         : function (Venda: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_COO                                : function (Inicial, Final: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_CGC_IE                             : function (CGC: AnsiString;IE: AnsiString ): Integer; StdCall;
  fFuncDaruma_FI_VerificaRecebimentoNaoFiscal       : function (Totalizadores: AnsiString ): Integer; StdCall;
  fFuncDaruma_FIMFD_DownloadDaMFD                   : function (Str_Inicial, Str_Final: AnsiString ): Integer; StdCall;
  fFuncDaruma_FIMFD_RetornaInformacao               : function (Str_Indice, Str_Valor: AnsiString ): Integer; StdCall;
  fFuncDaruma_FI_NumeroLoja                         : function (NumeroLoja: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_VerificaModeloECF                  : function ():Integer; StdCall;
  fFuncDaruma_FI_RetornaCRO                         : function (Valor: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_RetornaCRZ                         : function (Valor: AnsiString): Integer; StdCall;
  fFuncDaruma_FIMFD_GerarAtoCotepePafData           : function (sDataInicial:AnsiString; sDataFinal:AnsiString): Integer; stdcall;
  fFuncDaruma_FIMFD_GerarAtoCotepePafCOO            : function (sCooInicial:AnsiString; sCooFinal:AnsiString): Integer; stdcall;
  fFuncDaruma_FIMFD_GerarMFPAF_DATA                 : function (sDataInicial:AnsiString; sDataFinal:AnsiString): Integer; stdcall;
  fFuncDaruma_FI_SubTotal                           : function (sSubTotal: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_UltimoItemVendido                  : function (sUltimoItem: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_DadosUltimaReducao                 : function (DadosReducao: AnsiString): Integer; StdCall;

  // Funções das Operações Não Fiscais ///////////////////////////////////////////
  fFuncDaruma_FI_RecebimentoNaoFiscal               : function (IndiceTotalizador: AnsiString; Valor: AnsiString; FormaPagamento: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_AbreComprovanteNaoFiscalVinculado  : function (FormaPagamento: AnsiString; Valor: AnsiString; NumeroCupom: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_UsaComprovanteNaoFiscalVinculado   : function (Texto: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_FechaComprovanteNaoFiscalVinculado : function ():Integer; StdCall;
  fFuncDaruma_FI_Sangria                            : function (Valor: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_Suprimento                         : function (Valor: AnsiString; FormaPagamento: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_VerificaTotalizadoresNaoFiscaisEx  : function (Totalizadores: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_NumeroOperacoesNaoFiscais          : function (valor: AnsiString): Integer; StdCall;

  // Funções de Autenticação e Gaveta de Dinheiro ////////////////////////////////
  fFuncDaruma_FI_Autenticacao                       : function ():Integer; StdCall;
  fFuncDaruma_FI_ProgramaCaracterAutenticacao       : function (Parametros: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_ProgramaFormasPagamento            : function (Moeda: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_AcionaGaveta                       : function ():Integer; StdCall;
  fFuncDaruma_FI_VerificaEstadoGaveta               : function ( Var EstadoGaveta: Integer ): Integer; StdCall;

  // Outras Funções
  fFuncDaruma_FI_AberturaDoDia          : function (ValorCompra, FormaPagamento: AnsiString ): Integer; StdCall;
  fFuncDaruma_FI_FechamentoDoDia        : function (): Integer;stdcall;

  // Funções de Impressão de Cheques /////////////////////////////////////////////
  fFuncDaruma_FI_ProgramaMoedaSingular              : function (MoedaSingular: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_ProgramaMoedaPlural                : function (MoedaPlural: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_CancelaImpressaoCheque             : function ():Integer; StdCall;
  fFuncDaruma_FI_VerificaStatusCheque               : function (Var StatusCheque: Integer): Integer; StdCall;
  fFuncDaruma_FI2000_ImprimirCheque                 : function (Banco: AnsiString; Cidade: AnsiString; Data: AnsiString; Favorecido: AnsiString; Valor: AnsiString; Orientacao: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_IncluiCidadeFavorecido             : function (Cidade: AnsiString; Favorecido: AnsiString): Integer; StdCall;
  fFuncDaruma_FI_ImprimeCopiaCheque                 : function ():Integer; StdCall;
  fFuncDaruma_FI_IdentificaConsumidor               : function (Nome: AnsiString; Endereco: AnsiString; CPF: AnsiString): Integer StdCall;

  // Funções DarumaFrameWork
  fFuncrGerarRelatorio_ECF_Daruma                   : function ( TipoRelatorio: AnsiString; TipoIntervalo: AnsiString; DadoInicio: AnsiString; DadoFinal: AnsiString): Integer; StdCall;
  fFunceBuscarPortaVelocidade_ECF_Daruma            : function () : Integer; StdCall;
  fFuncregAlterarValor_Daruma                       : function (PathChave : AnsiString ; Valor : AnsiString): Integer; StdCall; //Usado para leitura do arquivo de configuração DaruamFrameWork.xml
  fFunciCCDEstornar_ECF_Daruma                      : function ( COOCCD : AnsiString; CPFCNPJ : AnsiString ; Nome : AnsiString ; Endereco : AnsiString ): Integer; StdCall;
  fFunciCCDEstornarPadrao_ECF_Daruma                : function () : Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sigtron
///
function TImpFiscalSigtron.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
var sfile: AnsiString;
begin
  sFile := ExtractFilePath(Application.ExeName) + 'FS345.CFG';
  if FileExists(sFile) then
  begin
      Result := OpenSigtron( sPorta, 'FS345.CFG');
  end
  else
  begin
    Showmessage('Arquivo FS345.CFG não encontrado no diretório na aplicação');
    Result := '1';
  end;

end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  Result := CloseSigtron;
end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron.LeituraX : AnsiString;
begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Fiscal';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'LeituraX';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
  Result := '1|'
else
  Result := '0|';
end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron.ReducaoZ ( MapaRes:AnsiString ): AnsiString;
var
   sDia    :AnsiString;
   sMes    :AnsiString;
   sAno    :AnsiString;
   sHora   :AnsiString;
   sMinuto :AnsiString;
   sSegundo:AnsiString;

begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'LeituraRelogio';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
  Result := '1|'
else
   begin
  {Recebe retorno }
   sDia    :=FSigtron.SigDrCm1.Ret['Dia'];
   sMes    :=FSigtron.SigDrCm1.Ret['Mes'];
   sAno    :=FSigtron.SigDrCm1.Ret['Ano'];
   sHora   :=FSigtron.SigDrCm1.Ret['Hora'];
   sMinuto :=FSigtron.SigDrCm1.Ret['Minuto'];
   sSegundo:=FSigtron.SigDrCm1.Ret['Segundo'];

   {Biblioteca de Comandos}
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   {Nome do Comando}
   FSigtron.SigDrCm1.CmdName := 'ReducaoZ';
   FSigtron.SigDrCm1.Param['Dia']:=sDia;
   FSigtron.SigDrCm1.Param['Mes']:=sMes;
   FSigtron.SigDrCm1.Param['Ano']:=sAno;
   FSigtron.SigDrCm1.Param['Hora']:=sHora;
   FSigtron.SigDrCm1.Param['Minuto']:=sMinuto;
   FSigtron.SigDrCm1.Param['Segundo']:=sSegundo;
   {Envia comando}
    if FSigtron.SigDrCm1.send = -1 then
       Result := '1|'
    else
       Result := '0|';
    end;
end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron.LeAliquotas:AnsiString;

var
  sAliq:AnsiString;
  sAliqICM:AnsiString;
  iPont1:integer;

begin
{Nome do Comando}
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraAliquotaFiscalCarregada';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   result := '1|'
else
  begin
  sAliq:=FSigtron.SigDrCm1.Ret['Valor'];
  iPont1:=65;
  sAliqICM:='';
  While Trim(sAliq) <> '' do
    begin
    if ( copy(sAliq,1,1)= Chr(iPont1)) and ( copy(sAliq,2,1)<>'/') Then
       sAliqICM :=sAliqICM + copy(sAliq,2,2)+ '.' + copy(sAliq,4,2)+ '|' ;

    iPont1:=iPont1+1;
    sAliq:=copy(sAliq,6,Length(sAliq));
    end;
    result := '0|' + sAliqICM;
  end;
end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron.LeAliquotasISS:AnsiString;
var
  sAliq:AnsiString;
  sAliqISS:AnsiString;
  iPont2:integer;

begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraAliquotaFiscalCarregada';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   result := '1|'
else
  begin
  sAliq:=FSigtron.SigDrCm1.Ret['Valor'];
  iPont2:=97;
  sAliqISS:='';
  While Trim(sAliq) <> '' do
    begin
    if ( copy(sAliq,1,1)= Chr(iPont2)) and ( copy(sAliq,2,1)<>'/') Then
       sAliqISS :=sAliqISS+copy(sAliq,2,2)+'.'+copy(sAliq,4,2)+'|';

    iPont2:=iPont2+1;
    sAliq:=copy(sAliq,6,Length(sAliq));
    end;
    result := '0|' + sAliqISS;
  end;
end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron.LeCondPag:AnsiString;

var
  sForma:AnsiString;
  sPagto:AnsiString;

Begin
{Nome do Comando}
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraMensagensPersonalizados';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
     result := '1|'
else
  Begin
  {Recebe retorno e imprime}
  sForma:=FSigtron.SigDrCm1.Ret['NomeFormasPagto'];
  sPagto:='';
  While Length(sForma)<>0 do
      begin
      If Trim(Copy(sForma,2,17)) <> '' then
         sPagto := sPagto + Trim(copy(sForma,2,17)) + '|';

      sForma:=Copy(sForma,19,Length(sForma));
      end;
  end;
  if Length(sPagto) > 4 then
     result := '0|' + sPagto
  else
     result := '1|';
end;
//----------------------------------------------------------------------------
function TImpFiscalSigtron.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;

begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1. LibName := 'Fiscal';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'AberturaCupomFiscal';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
   Result := ' 0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iAcrescimo:integer;
  sNumero:AnsiString;
Begin
//Verifica se o cupom está aberto
If Copy(StatusImp(5),1,1) = '0' then
  iAcrescimo := 1
Else
  iAcrescimo := 0;

{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'LeituraEstadoDocumento';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
begin
  sNumero := FSigtron.SigDrCm1.Ret['NumeroCupom'];
  Result := ' 0|'+ FormataTexto(IntToStr(StrToInt(sNumero)-iAcrescimo),6,0,2);
end;

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.PegaPDV:AnsiString;
Begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'LeituraIdentificacao';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
  Result := ' 0|' + FSigtron.SigDrCm1.Ret['NumeroECF'];

end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
Begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Fiscal';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'CancelamentoItem';
FSigtron.SigDrCm1.Param['Item']:= FormataTexto(numItem,3,0,2);
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
  Result := ' 0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.CancelaCupom( Supervisor:AnsiString ):AnsiString;

Begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Fiscal';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'CancelaDocumento';
{Envia comando}
Sleep(1000);
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
  Result := ' 0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;

var
  sAliq:AnsiString;
  iPont1:integer;
  iPont2:integer;
  sTaxa: AnsiString;
  iRet : integer;
  sRet : AnsiString;
begin
//verifica se é para registra a venda do item ou só o desconto
if Trim(codigo+descricao+qtde+vlrUnit) = '' then
begin
  result := '11';
  exit;
end;
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraAliquotaFiscalCarregada';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
begin
  sAliq:=FSigtron.SigDrCm1.Ret['Valor'];
  iPont1:=65;  // Verificar os registradores maiusculos A- P (Icms)
  iPont2:=97;  // Verificar os registradores minusculos a - p (ISS)
  While Trim(sAliq) <> '' do
    begin
    sTaxa:=copy(aliquota,1,1)+'b';
    if ( copy(aliquota,1,1)='T') and ( copy(sAliq,1,1)= Chr(iPont1)) and
       ( copy(sAliq,2,1)<>'/') and ( StrToFloat(copy(sAliq,2,2)+ '.' + copy(sAliq,4,2))=StrToFloat(copy(aliquota,2,5))) Then
        begin
        sTaxa:=copy(aliquota,1,1)+copy(sAliq,1,1);
        Break;
        end;
    if ( copy(aliquota,1,1)='S') and ( copy(sAliq,1,1)= Chr(iPont2)) and
       ( copy(sAliq,2,1)<>'/') and ( StrToFloat( copy(sAliq,2,2)+ '.' + copy(sAliq,4,2)) = StrToFloat( copy(aliquota,2,5))) Then
        begin
        sTaxa:=copy(aliquota,1,1)+copy(sAliq,1,1);
        Break;
        end;
    iPont1:=iPont1+1;
    iPont2:=iPont2+1;
    sAliq:=copy(sAliq,6,Length(sAliq));
    end;


  // Optamos de manter a função extendida por causa do arredondamento da outra forma
  // pois sempre temos que manter o porcentual de desconto e não o valor, dando problemas
  // no arredondamento.
  Codigo:= Copy(Trim(Codigo)+Space(13),1,13);
  Descricao:=Trim(Descricao);

  vlrUnit:=FormataTexto(vlrUnit,9,3,2 );
  vlrDesconto:=Trim(FormataTexto(vlrDesconto,9,2,4));
  qtde:= Trim(FormataTexto(qtde, 8,3,2));

  sRet := OpenSigtronDLL;
  If sRet <> '1' then
  begin
    iRet := fFuncDAR_sDescEstendida(sTaxa,pchar(codigo),'2',pchar(vlrDesconto),pchar(vlrunit),pchar(qtde),'3',pchar('Un'),pchar(descricao),'1');
    if iRet = -1   then
    begin
      Result := '1'
    end
    else
      Result := '0';
  CloseSigtronDLL;
  end
  Else
    Result := '1';

end;

end;
//----------------------------------------------------------------------------
function TImpFiscalSigtron.AbreECF:AnsiString;
begin
Result := ' 0|';
end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron.FechaECF : AnsiString;
var
   sDia    :AnsiString;
   sMes    :AnsiString;
   sAno    :AnsiString;
   sHora   :AnsiString;
   sMinuto :AnsiString;
   sSegundo:AnsiString;

begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'LeituraRelogio';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
  Result := '1|'
else
   begin
  {Recebe retorno }
   sDia    :=FSigtron.SigDrCm1.Ret['Dia'];
   sMes    :=FSigtron.SigDrCm1.Ret['Mes'];
   sAno    :=FSigtron.SigDrCm1.Ret['Ano'];
   sHora   :=FSigtron.SigDrCm1.Ret['Hora'];
   sMinuto :=FSigtron.SigDrCm1.Ret['Minuto'];
   sSegundo:=FSigtron.SigDrCm1.Ret['Segundo'];

   {Biblioteca de Comandos}
   FSigtron.SigDrCm1.LibName         := 'Fiscal';
   {Nome do Comando}
   FSigtron.SigDrCm1.CmdName         := 'ReducaoZ';
   FSigtron.SigDrCm1.Param['Dia']    :=sDia;
   FSigtron.SigDrCm1.Param['Mes']    :=sMes;
   FSigtron.SigDrCm1.Param['Ano']    :=sAno;
   FSigtron.SigDrCm1.Param['Hora']   :=sHora;
   FSigtron.SigDrCm1.Param['Minuto'] :=sMinuto;
   FSigtron.SigDrCm1.Param['Segundo']:=sSegundo;
   {Envia comando}
   If FSigtron.SigDrCm1.send = -1 then
     Result := '1|'
   else
     Result := '0|';
   end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;

var
 aPag: array of array of AnsiString;  //Array para formas de Pagamento [Forma,Valor,Codigo na Impressora]
 aForma: array of AnsiString;
 iTam:Integer;
 iForma:integer;
 iPos:integer;
 sForma:AnsiString;
 bRet:Boolean;
begin
Pagamento := StrTran(Pagamento,'.','');
iForma:=0;
iTam:=0;
bRet:=True;
While Trim(Pagamento) <> '' do
  begin
  iPos:=Pos('|',Pagamento);
  if iPos <>1 then
     begin
     if iForma=0 Then // Descrição da AnsiString Pagamentos
        Begin
        SetLength( aPag,iTam+1 );
        SetLength( aPag[iTam],3);
        //Grava o descrição da forma de pagamento
        aPag[iTam,iForma]:=UpperCase(Copy(Pagamento,1,iPos-1));
        end
      else  // Valor da AnsiString Pagamentos
        //Grava o Valor do pagamento em 12 posicões
        aPag[iTam,iForma]:=FormataTexto(Copy(Pagamento,1,iPos-1),12,0,2);

     if iForma = 1 then
        begin
        iForma:=0;
        inc(iTam);
        end
     else
         inc(iForma);
     end;
  Pagamento:=copy(Pagamento,iPos+1,length(Pagamento));
  end;

//Leitura da Forma de Pagamento
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraMensagensPersonalizados';
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Begin
   sForma:=FSigtron.SigDrCm1.Ret['NomeFormasPagto'];
   // Gravar o array com as forma de Pagamento da Impressora
   iTam:=0;
   While Length(sForma)<>0 do
       begin
       If Trim(Copy(sForma,2,17)) <> '' then
          Begin
          SetLength( aForma, iTam+1 );
          aForma[iTam]:=UpperCase(Trim(copy(sForma,2,17)));
          Inc(iTam);
          end;

       sForma:=Copy(sForma,19,Length(sForma));
       end;
   // Gravar no Array de Pagamentos, codigo da forma de Pagamento da Impressora
   // sendo de A á Z, ( chr(65) á Chr(81) )
   for iTam:=0 to High(aPag) do
      for iForma:=0 to High(aForma) do
          if aPag[iTam,0] = aForma[iForma] Then
             begin
             aPag[iTam,2]:=Chr(65+iForma);
             Break;
             end;
   // Totalizacao do Cupom - caso nao tenha executado por Desconto no Total ou no Acrescimo Total
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   FSigtron.SigDrCm1.CmdName := 'TotalizacaoCupomFiscal';
   FSigtron.SigDrCm1.Param['TipoDescAcres']:='1';
   FSigtron.SigDrCm1.Param['ValorDescAcres']:='00000000000';
   FSigtron.SigDrCm1.send;

   // Executa todas as formas de pagamento recebidas
   for iForma:=0 to High(aPag) do
      Begin
      //Nome do Comando
      FSigtron.SigDrCm1.LibName := 'Fiscal';
      FSigtron.SigDrCm1.CmdName := 'DescricaoPagamento';
      FSigtron.SigDrCm1.Param['ValorPagamento']:=aPag[iForma,1];
      FSigtron.SigDrCm1.Param['FormaPagamento']:=aPag[iForma,2];
      if FSigtron.SigDrCm1.send = -1 then
         Begin
         bRet:=False;
         Break;
         end
      end;

   if bRet then
      if StrToInt(FSigtron.SigDrCm1.Ret['Saldo'])<>0 Then
      // ???? Saber qual decisao tomar quando o valor não bater
         bRet:=False;

   if not bRet then
      Result := '1|'
   else
      Result := '0|';

   end;
end;
//----------------------------------------------------------------------------
function TImpFiscalSigtron.FechaCupom( Mensagem:AnsiString ):AnsiString;

begin
{Nome do Comando}
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'FechamentoCupomComMensagem';
FSigtron.SigDrCm1.Param['Mensagem']:=Mensagem;
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Result := '0|'
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString;
Begin
// ??? VlrDEsconto = XXXX.XX ?
vlrDesconto:= StrTran(vlrDesconto,'.','');

{Nome do Comando}
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'TotalizacaoCupomFiscal';
FSigtron.SigDrCm1.Param['TipoDescAcres']:='1';
FSigtron.SigDrCm1.Param['ValorDescAcres']:=FormataTexto(vlrDesconto,12,0,2 );
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Result := '0|'

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
Begin
// ??? VlrDEsconto = XXXX.XX ?
vlrAcrescimo:= StrTran(vlrAcrescimo,'.','');

{Nome do Comando}
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'TotalizacaoCupomFiscal';
FSigtron.SigDrCm1.Param['TipoDescAcres']:='3';
FSigtron.SigDrCm1.Param['ValorDescAcres']:=FormataTexto(vlrAcrescimo,12,0,2 );
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Result := '0|'

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString;

Begin
  FSigtron.SigDrCm1.LibName := 'Fiscal';
  FSigtron.SigDrCm1.CmdName := 'LeituraMemoria';
  FSigtron.SigDrCm1.Param['TipoLeitura']:='x';
  FSigtron.SigDrCm1.Param['Data_ou_COO_Inicial']:=FormataData( DataInicio,1 );
  FSigtron.SigDrCm1.Param['Data_ou_COO_Final']  :=FormataData( DataFim,1 );
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Result := '0|'

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
var
  sAliq : AnsiString;
  aAliq : TaString;
  bAchou : Boolean;
  i : Integer;
begin
if Tipo = 1 then      // aliquota de ICMS
  begin
  bAchou := False;
  sAliq := LeAliquotas;
  MontaArray(Copy(sAliq,2,Length(sAliq)), aAliq);
  For i:=0 to Length(aAliq)-1 do
     if StrTran(aAliq[i],',','.') = StrTran(Aliquota,',','.') then
        bAchou := True;

     if not bAchou then
        if Length(aAliq) < 16 then
           begin
           StrTran(Aliquota,',','');
           Aliquota:=FormataTexto(Aliquota,4,2,2);
           FSigtron.SigDrCm1.LibName := 'Configuracao';
           FSigtron.SigDrCm1.CmdName := 'CargaAliquotaICMS';
           FSigtron.SigDrCm1.Param['Aliquota']:=Aliquota;
           if FSigtron.SigDrCm1.send = -1 then
              result := '1|'
           else
              result := '0|';
           end
        else
           begin
           ShowMessage('Não há mais espaço para gravar alíquotas.');
           result := '6|';
           end
     else
        begin
        ShowMessage('Aliquota já Cadastrada.');
        result := '4|';
        end;
  end
else if Tipo = 2 then     // aliquota de ISS
     begin
     bAchou := False;
     sAliq := LeAliquotasISS;
     MontaArray(sAliq, aAliq);

     For i:=0 to Length(aAliq)-1 do
       if StrTran(aAliq[i],',','.') = StrTran(Aliquota,',','.') then
          bAchou := True;

       if not bAchou then
          if Length(aAliq) < 5 then  // ??? Nao ha limite de aliquota
             begin
             StrTran(Aliquota,',','');
             Aliquota:=FormataTexto(Aliquota,4,2,2);
             FSigtron.SigDrCm1.LibName := 'Configuracao';
             FSigtron.SigDrCm1.CmdName := 'CargaAliquotaISS';
             FSigtron.SigDrCm1.Param['Aliquota']:=Aliquota;
             if FSigtron.SigDrCm1.send = -1 then
                result := '1|'
             else
                result := '0|';
             end
          else
            begin
            ShowMessage('Não há mais espaço para gravar alíquotas.');
            result := '6|'
            end
       else
          begin
          ShowMessage('Aliquota já Cadastrada.');
          result := '4|';
          end;
     end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;

    function Comprovante( Comprovante,Tipo:AnsiString ) : AnsiString;
    var
    sForma:AnsiString;
    iTam:integer;

    Begin
    //Saber o nome do Totalizador
    FSigtron.SigDrCm1.LibName := 'Leitura';
    FSigtron.SigDrCm1.CmdName := 'LeituraMensagensPersonalizados';
    if FSigtron.SigDrCm1.send = -1 then
       result := ' '
    else
       Begin
       if tipo='V' then
          sForma:=FSigtron.SigDrCm1.Ret['NomeCNFVs']
       else
          sForma:=FSigtron.SigDrCm1.Ret['NomeCNFNVs'];

       iTam:=0;
       While Length(sForma)<>0 do
            begin
            If Trim(Copy(sForma,2,17)) <> '' then
               If UpperCase(Trim(copy(sForma,2,21)))=UpperCase(Trim(copy(Totalizador,1,22))) then
                  Break;

            sForma:=Copy(sForma,23,Length(sForma));
            inc(iTam);
            end;
        Result:=Chr(65+iTam);
       end;
    end;
Var
  sNumeroCupom:AnsiString;
  aForma: array of AnsiString;
  sForma:AnsiString;
  sIdentificacao:AnsiString;
  sFormaPaga:AnsiString;
  iTam:Integer;

begin

Valor:=StrTran(Valor,'.','');
Valor:=FormataTexto(Valor,12,0,2 );

//Pegar a letra do resistrador da forma de pagamento
//Leitura da Forma de Pagamento
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraMensagensPersonalizados';
if FSigtron.SigDrCm1.send = -1 then
   Begin
   Result := '1|';
   exit;
   end;

sForma:=FSigtron.SigDrCm1.Ret['NomeFormasPagto'];
// Gravar o array com as forma de Pagamento
iTam:=0;
While Length(sForma)<>0 do
    begin
    If Trim(Copy(sForma,2,17)) <> '' then
       Begin
       SetLength( aForma, iTam+1 );
       aForma[iTam]:=UpperCase(Trim(copy(sForma,2,17)));
       Inc(iTam);
       end;

    sForma:=Copy(sForma,19,Length(sForma));
    end;

for iTam:=0 to High(aForma) do
    if aForma[iTam] = UpperCase(Condicao) Then
       Begin
       //Pegando a letra da forma de pagamento
       sFormaPaga:=chr(65+iTam);
       Break;
       end;
iTam:=-1;
// Pegar o numero do cupom a ser vinculado.
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraEstadoDocumento';
if FSigtron.SigDrCm1.send <> -1 then
   begin
   //Emissao do Cupom NAO Fiscal VINCULADO
   sNumeroCupom:=FSigtron.SigDrCm1.Ret['NumeroCupom'];
   //Pegando o numero do Cupom
   sNumeroCupom:=IntToStr(StrToInt(sNumeroCupom)-1);
   sNumeroCupom:=FormataTexto(sNumeroCupom,6,0,2);

   //Saber o nome do Totalizador
   sIdentificacao:=Comprovante(Totalizador,'V');

   //Abrindo cupom não fiscal vinculado.
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   FSigtron.SigDrCm1.CmdName := 'AberturaCNFV';
   FSigtron.SigDrCm1.Param['IdentificacaoCNFV']:=sIdentificacao;
   FSigtron.SigDrCm1.Param['TipoCNFV']:=sFormaPaga;
   FSigtron.SigDrCm1.Param['COOorigem']:=sNumeroCupom;
   FSigtron.SigDrCm1.Param['ValorVinculado']:=Valor;
   iTam:=FSigtron.SigDrCm1.send;
   end;

if iTam=-1 then
   Begin
   //Abrindo cupom não fiscal não vinculado.
   sIdentificacao:=Comprovante(Totalizador,'NV');
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   FSigtron.SigDrCm1.CmdName := 'EmissaoCNFNV';
   FSigtron.SigDrCm1.Param['IdentificacaoCNFNV']:=sIdentificacao;
   FSigtron.SigDrCm1.Param['DescontoAcrescimo']:='3';
   FSigtron.SigDrCm1.Param['DescAcres']:=Valor;
   FSigtron.SigDrCm1.Param['Mensagem']:='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
   iTam:=FSigtron.SigDrCm1.send;
   end;

if iTam=-1 then
   result := '1|'
else
   result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var
  bRet : Boolean;
  iPos:Integer;
  sLinha:AnsiString;

begin
bRet:=True;
iPos:=Pos(#10,Texto);
while iPos<>0 do
  begin
  sLinha:=Copy(Texto,1,iPos-1);
  FSigtron.SigDrCm1.LibName := 'Fiscal';
  FSigtron.SigDrCm1.CmdName := 'LinhaTexto';
  FSigtron.SigDrCm1.Param['TextoLivre']:=sLinha+chr(10);
  //FSigtron.SigDrCm1.Param['TextoLivre']:=Texto;
  if FSigtron.SigDrCm1.send = -1 then
     Begin
     bRet:= False;
     Break;
     End;

  Texto:=Copy(Texto,iPos+1,Length(Texto));
  iPos:=Pos(#10,Texto);

  end;
if not bRet then
   result := '1|'
else
   result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.FechaCupomNaoFiscal: AnsiString;

Begin
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'FechamentoComprovante';
if FSigtron.SigDrCm1.send = -1 then
   result := '1|'
else
   result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.ReImpCupomNaoFiscal( Texto:AnsiString ): AnsiString;
begin
  // para posterior implementacao
  result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString;
begin
  // para posterior implementacao
  result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  bRet : Boolean;
  i    : Integer;
begin
bRet:=True;
For i:=1 to Vezes do
  begin
  ShowMessage('Posicione o Documento para Autenticação.');
  FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
  FSigtron.SigDrCm1.CmdName := 'Autenticacao';
  FSigtron.SigDrCm1.Param['Mensagem']:= Texto;
  if FSigtron.SigDrCm1.send = -1 then
     Begin
     bRet:=False;
     Break;
     end;

  end;
if not bRet then
   result := '1|'
else
   result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
begin
  if Tipo = 1 then
    result := '0'
  else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.Gaveta:AnsiString;
begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'AbreGaveta';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
  Result := '1|'
else
  Result := '0|';

end;
//----------------------------------------------------------------------------
function TImpFiscalSigtron.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ): AnsiString;

Begin
if ( copy(Descricao,1,1)<>'+') and ( copy(Descricao,1,1)<>'-') and ( copy(Descricao,1,1)<>'V') then
   Begin
   ShowMessage('O primeiro caracter deve definir o tipo, sendo:'+chr(10)+chr(13)+
               'V = Vincular a forma de pagamento'+chr(10)+chr(13)+
               '+ = Para entrada de valores       '+chr(10)+chr(13)+
               '- = Para saida de valores         '+chr(10)+chr(13));
    result:='1|';
    exit;
    end;

FSigtron.SigDrCm1.LibName := 'Configuracao';
FSigtron.SigDrCm1.CmdName := 'CriacaoCNF';
FSigtron.SigDrCm1.Param['TipoCNF']:=copy(Descricao,1,1);
FSigtron.SigDrCm1.Param['NomeCNF']:=UpperCase(copy(Descricao,2,length(Descricao)));
if FSigtron.SigDrCm1.send = -1 then
   result := '1|'
else
   result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.GravaCondPag( Condicao:AnsiString ):AnsiString;

var
  sForma:AnsiString;
  iTam  :Integer;
  aForma: array of AnsiString;
  bRet  :Boolean;
  sPos  : AnsiString;
Begin
condicao:=UpperCase(Trim(copy(condicao,1,17)));

//Leitura da Forma de Pagamento
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraMensagensPersonalizados';
if FSigtron.SigDrCm1.send = -1 then
   begin
   Result := '1|';
   exit;
   end;

sForma:=FSigtron.SigDrCm1.Ret['NomeFormasPagto'];
// Gravar o array com as forma de Pagamento da Impressora
iTam:=0;
bRet:=false;
While Length(sForma)<>0 do
    begin
    SetLength( aForma, iTam+1 );
    aForma[iTam]:=UpperCase(Trim(copy(sForma,2,17)));
    If aForma[iTam]=Condicao then
       begin
       bRet:=True;
       Break;
       end;

    Inc(iTam);
    sForma:=Copy(sForma,19,Length(sForma));
    end;

If bRet then
   begin
   ShowMessage('Condição já cadastrada');
   result:='1|';
   exit;
   end;

bRet:= False;
sPos:='';
for iTam:=0 to High(aForma) do
    if ( aForma[iTam]='') or ( aForma[iTam]='PAGAMENTO TIPO '+chr(65+iTam) ) Then
       begin
       sPos:=chr(65+iTam);
       bRet:=True;
       Break;
       end;

if not bRet then
   begin
   ShowMessage('Não há mais espaço para gravar Condição de Pagamento.');
   result:='1|';
   exit;
   end;

sForma:='PGX'+sPos+copy(Condicao+space(17),1,17);
FSigtron.SigDrCm1.LibName := 'Configuracao';
FSigtron.SigDrCm1.CmdName := 'PersonalizacaoMensagens';
FSigtron.SigDrCm1.Param['PersonalizaMensagem']:=sForma;
if FSigtron.SigDrCm1.send = -1 then
   result := '1|'
else
   result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.Status( Tipo:Integer; Texto:AnsiString ):AnsiString;
var
  bErro : Boolean;
begin
  bErro := False;
  case Tipo of
    1 : if Texto <> '0' then
            bErro := True;
    else
      bErro := False;
    end;

  If bErro then
    result := '1'
  else
    result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.StatusImp( Tipo:Integer ):AnsiString;
//Tipo - Indica qual o status quer se obter da impressora
//  1 - Obtem a Hora da Impressora
//  2 - Obtem a Data da Impressora
//  3 - Verifica o Papel
//  4 - Verifica se é possível cancelar um ou todos os itens.
//  5 - Cupom Fechado ?
//  6 - Ret. suprimento da impressora
//  7 - ECF permite desconto por item
//  8 - Verica se o dia anterior foi fechado
//  9 - Verifica o Status do ECF
// 10 - Verifica se todos os itens foram impressos.
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
// 13 - Verifica se o ECF Arredonda o Valor do Item
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
// 16 - Verifica se exige o extenso do cheque
// 17 - Verifica Venda Bruta (RICMS 01 - SC - ANEXO 09)
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware
var
  sTipo:AnsiString;
begin
If Tipo = 1 then
   begin
   // Verifica a hora da impressora
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'LeituraRelogio';
   if FSigtron.SigDrCm1.send = -1 then
      Result := '1|'
   else
      result := '0|' + FSigtron.SigDrCm1.Ret['Hora'] + ':' + FSigtron.SigDrCm1.Ret['Minuto'] + ':'+FSigtron.SigDrCm1.Ret['Segundo']
   end

else if Tipo = 2 then
   begin
   // Verifica a hora da impressora
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'LeituraRelogio';
   if FSigtron.SigDrCm1.send = -1 then
      Result := '1|'
   else
      result := '0|' + FSigtron.SigDrCm1.Ret['Dia'] + '/' + FSigtron.SigDrCm1.Ret['Mes']+ '/'+FSigtron.SigDrCm1.Ret['Ano']
   end

else if Tipo = 3 then // Verifica o estado do papel
   begin
   sTipo:='02468ACE';
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'PalavraDeStatus';
   if FSigtron.SigDrCm1.send <> -1 then
      if Pos(Chr(StrToInt(FSigtron.SigDrCm1.Ret['S1'])),sTipo)<>0 then
         result := '0|'
      else
         result := '1|'

   end

else if Tipo = 4 then
    result := '0|TODOS'

  //Cupom Fechado ?
else if Tipo = 5 then
   begin
   sTipo:='012389AB';
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'PalavraDeStatus';
   if FSigtron.SigDrCm1.send <> -1 then
      if Pos(Chr(StrToInt(FSigtron.SigDrCm1.Ret['S4'])),sTipo)<>0 then
         result := '0|'
      else
         result := '7|'
   end
  //Ret. suprimento da impressora
else if Tipo = 6 then
  begin
  result := '0|0.00';
  end
// Verif.se ECF permite desconto por item
else if Tipo = 7 then
  result := '1|'
// Verifica se o ECF foi fechado no dia anterior
else if Tipo = 8 then
   begin
   sTipo:='014589CD';
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'PalavraDeStatus';
   if FSigtron.SigDrCm1.send <> -1 then
      if Pos(Chr(StrToInt(FSigtron.SigDrCm1.Ret['S4'])),sTipo)<>0 then
         result := '0|'
      else
         result := '1|'
   end
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
  result := '0'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  result := '0'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 then
  result := '1'
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
else if Tipo = 12 then
  result := '1'
// 13 - Verifica se o ECF Arredonda o Valor do Item
else if Tipo = 13 then
  result := '1'
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
else if Tipo = 14 then
  // 0 - Fechada
  Result := '0'
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
  Result := '1'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
  Result := '1'

// 20 ao 40 - Retorno criado para o PAF-ECF
else if (Tipo >= 20) AND (Tipo <= 40) then
  Result := '0'
else If Tipo = 45 then
       Result := '0|'// 45 Codigo Modelo Fiscal
else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
       Result := '0|'// 45 Codigo Modelo Fiscal
  //Retorno não encontrado
else
  Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.LeTotNFisc:AnsiString;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
function TImpFiscalSigtron.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalSigtron.RedZDado( MapaRes : AnsiString): AnsiString ;
Begin
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalSigtron.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
  Result := OpenSigtron( sPorta, 'FS2K.CFG' );
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.LeAliquotas:AnsiString;
var
  sAliq:AnsiString;
  sAliqICM:AnsiString;
  iPont1:integer;

begin
{Nome do Comando}
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraAliquotas';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   result := '1|'
else
  begin
  sAliq:='';
  for iPont1 := 0 to 15 do
     begin
     sAliq:=sAliq+FSigtron.SigDrCm1.Ret['T'+chr(65+iPont1)];
     end;

  iPont1:=65;
  sAliqICM:='';
  While Trim(sAliq) <> '' do
    begin
    if ( copy(sAliq,1,1)= Chr(iPont1)) and ( copy(sAliq,2,1)<>'/') Then
       sAliqICM :=sAliqICM + copy(sAliq,2,2)+ '.' + copy(sAliq,4,2)+ '|' ;

    iPont1:=iPont1+1;
    sAliq:=copy(sAliq,6,Length(sAliq));
    end;
    result := '0|' + sAliqICM;
  end;
end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron2000.LeAliquotasISS:AnsiString;
var
  sAliq:AnsiString;
  sAliqISS:AnsiString;
  iPont2:integer;

begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraAliquotas';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   result := '1|'
else
  begin
  sAliq:='';
  for iPont2:= 0 to 15 do
     begin
     sAliq:=sAliq+FSigtron.SigDrCm1.Ret['T'+chr(65+iPont2)];
     end;

  iPont2:=97;
  sAliqISS:='';
  While Trim(sAliq) <> '' do
    begin
    if ( copy(sAliq,1,1)= Chr(iPont2)) and ( copy(sAliq,2,1)<>'/') Then
       sAliqISS :=sAliqISS+copy(sAliq,2,2)+'.'+copy(sAliq,4,2)+'|';

    iPont2:=iPont2+1;
    sAliq:=copy(sAliq,6,Length(sAliq));
    end;
    result := '0|' + sAliqISS;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.PegaPDV:AnsiString;
Begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'LeituraIdECF';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
  Result := ' 0|' + FSigtron.SigDrCm1.Ret['ECF'];
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.PegaCupom(Cancelamento:AnsiString):AnsiString;
Begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'EstadoDocumento';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
  Result := '0|'+ FSigtron.SigDrCm1.Ret['COO'];;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
var
  sAliq : AnsiString;
  aAliq : TaString;
  bAchou : Boolean;
  i : Integer;
begin
if Tipo = 1 then      // aliquota de ICMS
  begin
  bAchou := False;
  sAliq := LeAliquotas;
  MontaArray(Copy(sAliq,2,Length(sAliq)), aAliq);
  For i:=0 to Length(aAliq)-1 do
     if StrTran(aAliq[i],',','.') = StrTran(Aliquota,',','.') then
        bAchou := True;

     if not bAchou then
        if Length(aAliq) < 16 then
           begin
           StrTran(Aliquota,',','');
           Aliquota:=FormataTexto(Aliquota,4,2,2);
           FSigtron.SigDrCm1.LibName := 'Configuracao';
           FSigtron.SigDrCm1.CmdName := 'CargaAliquota';
           FSigtron.SigDrCm1.Param['TipoImposto']:='I';
           FSigtron.SigDrCm1.Param['Aliquota']:=Aliquota;
           if FSigtron.SigDrCm1.send = -1 then
              result := '1|'
           else
              result := '0|';
           end
        else
           begin
           ShowMessage('Não há mais espaço para gravar alíquotas.');
           result := '6|';
           end
     else
        begin
        ShowMessage('Aliquota já Cadastrada.');
        result := '4|';
        end;
  end
else if Tipo = 2 then     // aliquota de ISS
     begin
     bAchou := False;
     sAliq := LeAliquotasISS;
     MontaArray(sAliq, aAliq);

     For i:=0 to Length(aAliq)-1 do
       if StrTran(aAliq[i],',','.') = StrTran(Aliquota,',','.') then
          bAchou := True;

       if not bAchou then
          if Length(aAliq) < 5 then  // ??? Nao ha limite de aliquota
             begin
             StrTran(Aliquota,',','');
             Aliquota:=FormataTexto(Aliquota,4,2,2);
             FSigtron.SigDrCm1.LibName             := 'Configuracao';
             FSigtron.SigDrCm1.CmdName             := 'CargaAliquota';
             FSigtron.SigDrCm1.Param['TipoImposto']:='S';
             FSigtron.SigDrCm1.Param['Aliquota']   :=Aliquota;
             if FSigtron.SigDrCm1.send = -1 then
                result := '1|'
             else
                result := '0|';
             end
          else
            begin
            ShowMessage('Não há mais espaço para gravar alíquotas.');
            result := '6|'
            end
       else
          begin
          ShowMessage('Aliquota já Cadastrada.');
          result := '4|';
          end;
     end;
end;

//---------------------------------------------------------------------------
function TImpFiscalSigtron2000.LeCondPag:AnsiString;
var
  sForma:AnsiString;
  sPagto:AnsiString;
  i     : Integer;

Begin
{Nome do Comando}
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraPersonalizacoes';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
     result := '1|'
else
  Begin
  for i:= 1 to 32 do
     sForma:=sForma+FSigtron.SigDrCm1.Ret['Pagamento'+FormataTexto(IntToStr(i),2,0,2 )];

  sPagto:='';
  While Length(sForma)<>0 do
      begin
      If Trim(Copy(sForma,2,1)) <> chr(255) then
         sPagto := sPagto + Trim(copy(sForma,2,21)) + '|';

      sForma:=Copy(sForma,23,Length(sForma));
      end;
  end;
  if Length(sPagto) > 4 then
     result := '0|' + sPagto
  else
     result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.GravaCondPag( Condicao:AnsiString ):AnsiString;
var
  sForma:AnsiString;
  iReg    : Integer;
  i       : Integer;
  Tipo    : AnsiString;

Begin
if ( Copy(Condicao,1,1)<>'+') and ( Copy(Condicao,1,1)<>'-')  then
   Begin
   ShowMessage('O primeiro caracter definie o tipo da forma de Pagamento, sendo: '+chr(13)+chr(10)+
               '(+) Forma de pagamento com cupom vinculado'+chr(13)+chr(10)+
               '(-) Forma de pagamento sem cupom vinculado'+chr(13)+chr(10));

   result := '1';
   exit;
   end;

if copy(condicao,1,1)='+' then
   Tipo:='V' // Forma vinculada
else
   Tipo:=' ';

condicao:=UpperCase(Trim(copy(condicao,2,21)));

//Leitura das formas de pagamento
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraPersonalizacoes';
if FSigtron.SigDrCm1.send = -1 then
   Begin
   result := '1';
   exit;
   end
else
  Begin
  iReg:=0;
  for i:= 1 to 32 do
     Begin
     sForma:=FSigtron.SigDrCm1.Ret['Pagamento'+FormataTexto(IntToStr(i),2,0,2 )];
     sForma:=UpperCase(Trim(Copy(sForma,2,length(sForma))));
     if sForma=Condicao then
        Begin
        ShowMessage('Condição já cadastrada.');
        result := '1';
        exit;
        end;
     If ( Trim(Copy(sForma,2,1)) =chr(255) ) and ( iReg=0 ) then
        if ( Tipo='V' ) then
           begin
           if i >16  then
              iReg:=(i-17)+51    // a Faixa das formas de pagamanto vinculadas é 51-66
           end
        else
            iReg:=i;
     end;
  end;

if iReg=0 then
   begin
   ShowMessage('Não há mais espaço para gravar Condição de Pagamento.');
   result:='1|';
   exit;
   end;

FSigtron.SigDrCm1.LibName := 'Configuracao';
FSigtron.SigDrCm1.CmdName := 'PersonalizacaoNomePagamento';
FSigtron.SigDrCm1.Param['CodigoPagamento']:=formataTexto(IntToStr(iReg),2,0,2);
FSigtron.SigDrCm1.Param['DescricaoPagamento']:=Copy(Condicao+space(21),1,21);
if FSigtron.SigDrCm1.send = -1 then
   begin
   result := '1|'
   end
else
   result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sAliq:AnsiString;
  iPont1:integer;
  iPont2:integer;
  sTaxa:AnsiString;
  sItem  : AnsiString;
begin
//verifica se é para registra a venda do item ou só o desconto
if ( Trim(codigo+descricao)='') and ( StrToFloat(vlrdesconto)>0.00 ) then
   begin
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'EstadoDocumento';
   if FSigtron.SigDrCm1.send <> -1 then
      Begin
      sItem:= FSigtron.SigDrCm1.Ret['UltimoItem'];
      FSigtron.SigDrCm1.LibName := 'Fiscal';
      FSigtron.SigDrCm1.CmdName := 'DescontoEmItem';
      FSigtron.SigDrCm1.Param['NumeroItem']:=sItem;
      FSigtron.SigDrCm1.Param['TipoOperacao']:='1';
      FSigtron.SigDrCm1.Param['Taxa']:=FormataTexto(vlrdesconto,9,2,2);
      if FSigtron.SigDrCm1.send = -1 then
         Result := ' 1'
      else
         Result := '0|';

      end
   else
      Result := ' 1';

   exit;
   end;

{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraAliquotas';
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
  begin
  sAliq:='';
  for iPont2:= 0 to 15 do
     begin
     sAliq:=sAliq+FSigtron.SigDrCm1.Ret['T'+chr(65+iPont2)];
     end;

  iPont1:=65;  // Verificar os registradores maiusculos A- P (Icms)
  iPont2:=97;  // Verificar os registradores minusculos a - p (ISS)
  While Trim(sAliq) <> '' do
    begin
    if ( copy(aliquota,1,1)='T') and ( copy(sAliq,1,1)= Chr(iPont1)) and
       ( copy(sAliq,2,1)<>'/') and ( StrToFloat(copy(sAliq,2,2)+ '.' + copy(sAliq,4,2))=StrToFloat(copy(aliquota,2,5))) Then
        begin
        sTaxa:=copy(aliquota,1,1)+copy(sAliq,1,1);
        Break;
        end;
    if ( copy(aliquota,1,1)='S') and ( copy(sAliq,1,1)= Chr(iPont2)) and
       ( copy(sAliq,2,1)<>'/') and ( StrToFloat( copy(sAliq,2,2)+ '.' + copy(sAliq,4,2)) = StrToFloat( copy(aliquota,2,5))) Then
        begin
        sTaxa:=copy(aliquota,1,1)+copy(sAliq,1,1);
        Break;
        end;
    iPont1:=iPont1+1;
    iPont2:=iPont2+1;
    sAliq:=copy(sAliq,6,Length(sAliq));
    end;
  vlrDesconto:=FormataTexto(vlrdesconto,9,2,2);
  vlrUnit:=FormataTexto(vlrUnit,10,3,2 );
  qtde:=FormataTexto(qtde,8,3,2 );
  Codigo:=Space(18-length(Trim(Codigo)))+Trim(Codigo);
  Descricao:=copy(Descricao,1,30);
  {Biblioteca de Comandos}
  FSigtron.SigDrCm1.LibName := 'Fiscal';
  {Nome do Comando}
  FSigtron.SigDrCm1.CmdName := 'DescricaoProduto';
  FSigtron.SigDrCm1.Param['SituacaoTributaria']:=sTaxa;
  FSigtron.SigDrCm1.Param['Codigo']:=Codigo;
  FSigtron.SigDrCm1.Param['TipoOperacao']:='1';
  FSigtron.SigDrCm1.Param['Taxa']:= vlrDesconto;
  FSigtron.SigDrCm1.Param['PrecoUnitario']:=vlrUnit;
  FSigtron.SigDrCm1.Param['Quantidade']:=qtde;
  FSigtron.SigDrCm1.Param['Unidade']:='  ';
  FSigtron.SigDrCm1.Param['Descricao']:=descricao;
  if FSigtron.SigDrCm1.send = -1 then
     Result := ' 1|'
  else
    Result := ' 0|';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;
var
 aPag: array of array of AnsiString;  //Array para formas de Pagamento [Forma,Valor,Codigo na Impressora]
 aForma: array of AnsiString;
 iTam:Integer;
 iForma,i:integer;
 iPos:integer;
 sForma:AnsiString;
 bRet:Boolean;
begin
Pagamento := StrTran(Pagamento,'.','');
iForma:=0;
iTam:=0;
bRet:=True;
While Trim(Pagamento) <> '' do
  begin
  iPos:=Pos('|',Pagamento);
  if iPos <>1 then
     begin
     if iForma=0 Then // Descrição da AnsiString Pagamentos
        Begin
        SetLength( aPag,iTam+1 );
        SetLength( aPag[iTam],3);
        //Grava o descrição da forma de pagamento
        aPag[iTam,iForma]:=UpperCase(Copy(Pagamento,1,iPos-1));
        end
      else  // Valor da AnsiString Pagamentos
        //Grava o Valor do pagamento em 12 posicões
        aPag[iTam,iForma]:=FormataTexto(Copy(Pagamento,1,iPos-1),12,0,2);

     if iForma = 1 then
        begin
        iForma:=0;
        inc(iTam);
        end
     else
         inc(iForma);
     end;
  Pagamento:=copy(Pagamento,iPos+1,length(Pagamento));
  end;

FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraPersonalizacoes';
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Begin
   for i:= 1 to 32 do
     sForma:=sForma+FSigtron.SigDrCm1.Ret['Pagamento'+FormataTexto(IntToStr(i),2,0,2 )];

   // Gravar o array com as forma de Pagamento da Impressora
   iTam:=0;
   While Length(sForma)<>0 do
       begin
       SetLength( aForma, iTam+1 );
       aForma[iTam]:=UpperCase(Trim(copy(sForma,2,21)));
       Inc(iTam);

       sForma:=Copy(sForma,23,Length(sForma));
       end;
   // Gravar no Array de Pagamentos, codigo da forma de Pagamento da Impressora
   // sendo de A á Z, ( chr(65) á Chr(81) )
   for iTam:=0 to High(aPag) do
      for iForma:=0 to High(aForma) do
          if aPag[iTam,0] = aForma[iForma] Then
             begin
             if iForma>15 then
                aPag[iTam,2]:=FormataTexto(IntToStr( (iForma-16)+51 ),2,0,2)
             else
                aPag[iTam,2]:=FormataTexto(IntToStr(iForma+1),2,0,2);

             Break;
             end;
   // Totalizacao do Cupom - caso nao tenha executado por Desconto no Total ou no Acrescimo Total
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   FSigtron.SigDrCm1.CmdName := 'Totalizacao';
   FSigtron.SigDrCm1.Param['TipoOperacao']:='1';
   FSigtron.SigDrCm1.Param['Valor']:='00000000000';
   FSigtron.SigDrCm1.send;

   // Executa todas as formas de pagamento recebidas
   for iForma:=0 to High(aPag) do
      Begin
      //Nome do Comando
      FSigtron.SigDrCm1.LibName := 'Fiscal';
      FSigtron.SigDrCm1.CmdName := 'DescricaoPagamento';
      FSigtron.SigDrCm1.Param['Valor']:=aPag[iForma,1];
      FSigtron.SigDrCm1.Param['Tipo'] :=aPag[iForma,2];
      if FSigtron.SigDrCm1.send = -1 then
         Begin
         bRet:=False;
         Break;
         end
      end;

   if bRet then
      if StrToInt(FSigtron.SigDrCm1.Ret['Saldo'])<>0 Then
      // ???? Saber qual decisao tomar quando o valor não bater
         bRet:=False;

   if not bRet then
      Result := '1|'
   else
      Result := '0|';

   end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.FechaCupom( Mensagem:AnsiString ):AnsiString;
begin
{Nome do Comando}
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'FechamentoFiscal';
FSigtron.SigDrCm1.Param['Adicional']:='X'; // Para impressao do cupom adicional colocar letra A
FSigtron.SigDrCm1.Param['Mensagem']:=Mensagem;
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Result := '0|'
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.CancelaCupom( Supervisor:AnsiString ):AnsiString;
Begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'CancelamentoUltimoDocumento';
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
  Result := ' 0|';

end;
//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
Begin
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'CancelamentoItem';
FSigtron.SigDrCm1.Param['NumeroItem']:= numItem;
if FSigtron.SigDrCm1.send = -1 then
   Result := ' 1|'
else
  Result := ' 0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString;
Begin
vlrDesconto:= StrTran(vlrDesconto,'.','');
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'Totalizacao';
FSigtron.SigDrCm1.Param['TipoOperacao']:='1';
FSigtron.SigDrCm1.Param['Valor']:=FormataTexto(vlrDesconto,12,0,2 );
{Envia comando}
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Result := '0|'

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
Begin
// ??? VlrDEsconto = XXXX.XX ?
vlrAcrescimo:= StrTran(vlrAcrescimo,'.','');
FSigtron.SigDrCm1.LibName := 'Fiscal';
FSigtron.SigDrCm1.CmdName := 'Totalizacao';
FSigtron.SigDrCm1.Param['TipoOperacao']:='3';
FSigtron.SigDrCm1.Param['Valor']:=FormataTexto(vlrAcrescimo,12,0,2 );
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Result := '0|'

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
Var
  sNumeroCupom:AnsiString;
  aForma: array of AnsiString;
  sForma:AnsiString;
  sIdentificacao:AnsiString;
  sFormaPaga:AnsiString;
  iTam:Integer;
  sRet: AnsiString;
  sRet2: AnsiString;
begin

Valor:=StrTran(Valor,'.','');
Valor:=FormataTexto(Valor,12,0,2 );
Condicao:=UpperCase(Condicao);

sFormaPaga:='99';
//Pegar a letra do resistrador da forma de pagamento
//Leitura da Forma de Pagamento
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraPersonalizacoes';
if FSigtron.SigDrCm1.send = -1 then
   Begin
   Result := '1|';
   exit;
   end;

for iTam:= 1 to 32 do
   sForma:=sForma+FSigtron.SigDrCm1.Ret['Pagamento'+FormataTexto(IntToStr(iTam),2,0,2 )];

// Gravar o array com as forma de Pagamento
iTam:=0;
While Length(sForma)<>0 do
    begin
    SetLength( aForma, iTam+1 );
    aForma[iTam]:=UpperCase(Trim(copy(sForma,2,21)));
    Inc(iTam);

    sForma:=Copy(sForma,23,Length(sForma));
    end;

for iTam:=0 to High(aForma) do
    if aForma[iTam] = UpperCase(Condicao) Then
       Begin
       //Pegando o Codigo da forma de pagamento
       if iTam>15 then
          sFormaPaga  :=FormataTexto(IntToStr( (iTam-16)+51) ,2,0,2)
       else
          sFormaPaga  :=FormataTexto(IntToStr(iTam),2,0,2);

       Break;
       end;

if sFormaPaga<>'99' then
   begin
   // Pegar o numero do cupom a ser vinculado.

   sNumeroCupom:=Copy(PegaCupom('F'),3,6);
   sNumeroCupom:=FormataTexto(sNumeroCupom,6,0,2);

   //Abrindo cupom não fiscal vinculado.
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   FSigtron.SigDrCm1.CmdName := 'AberturaCNFV';
   FSigtron.SigDrCm1.Param['CodigoPagamento']:=sFormaPaga;
   FSigtron.SigDrCm1.Param['COO_Origem']:=sNumeroCupom;
   FSigtron.SigDrCm1.Param['ValorPagamento']:=Valor;
   if FSigtron.SigDrCm1.send= -1 then
      Result := '1|'
   else
      Result := '0|';
   end
else
   // Cupom nao Fiscal nao Vinculado
   Begin
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'LeituraPersonalizacoes';
   if FSigtron.SigDrCm1.send = -1 then
      result := '1|'
   else
      begin
      sIdentificacao:='99';
      for iTam:= 1 to 16 do
         Begin
         sRet:=FSigtron.SigDrCm1.Ret['CNFNV_'+FormataTexto(IntToStr(iTam),2,0,2 )];
         sRet:=UpperCase(Trim(Copy(sRet,2,length(sRet))));
         sRet2:=Trim(Condicao);
         if sRet=sRet2 then
            begin
            sIdentificacao:=FormataTexto(IntToStr(iTam),2,0,2);
            break;
            end;
         end;
      if sIdentificacao='99' then
         begin
         ShowMessage('Totalizador não Cadastrada.');
         result := '1|';
         end
      else
         Begin
         FSigtron.SigDrCm1.LibName := 'Fiscal';
         FSigtron.SigDrCm1.CmdName := 'EmissaoCNFNV';
         FSigtron.SigDrCm1.Param['Identificacao']:=sIdentificacao;
         FSigtron.SigDrCm1.Param['TipoDesconto']:='1';
         FSigtron.SigDrCm1.Param['Desconto']:='000000000000';
         FSigtron.SigDrCm1.Param['Valor']:=Valor;
         FSigtron.SigDrCm1.Param['Texto']:='';
         if FSigtron.SigDrCm1.send=-1 then
            result := '1|'
         else
            result := '0|';
         end;
      end;
   end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ): AnsiString;
var
  i     : Integer;
  iReg  : Integer;
  sret,sRet2  : AnsiString;
Begin
if trim(Numero)='' then
   Begin
   if ( copy(Descricao,1,1)<>'+') and ( copy(Descricao,1,1)<>'-')  then
      Begin
      ShowMessage('O primeiro caracter deve definir o tipo, sendo:'+chr(10)+chr(13)+
                  '+ = Para entrada de valores       '+chr(10)+chr(13)+
                  '- = Para saida de valores         '+chr(10)+chr(13));
      result:='1|';
      exit;
      end;

   Descricao:=UpperCase(Descricao);

   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'LeituraPersonalizacoes';
   if FSigtron.SigDrCm1.send = -1 then
      Begin
      result := '1|';
      exit;
      end;
   iReg:=0;
   for i:= 1 to 16 do
      Begin
      sRet:=FSigtron.SigDrCm1.Ret['CNFNV_'+FormataTexto(IntToStr(i),2,0,2 )];
      sRet:=UpperCase(Trim(Copy(sRet,2,length(sRet))));
      sRet2:=Trim(copy(Descricao,2,length(Descricao)));
      if ( sRet=sRet2 ) then
         Begin
         ShowMessage('Totalizador já Cadastrado.');
         result := '1|';
         exit;
         end;

      if copy(sRet,1,1)<>chr(255) then
         Inc(iReg);
      end;

   if iReg>= 16 then
      begin
      ShowMessage('Não há mais espaço para gravar totalizadores.');
      result := '6|';
      exit;
      end;

   FSigtron.SigDrCm1.LibName := 'Configuracao';
   FSigtron.SigDrCm1.CmdName := 'CriacaoComprovanteNFNV';
   FSigtron.SigDrCm1.Param['TipoComprovante']:=copy(Descricao,1,1);
   FSigtron.SigDrCm1.Param['NomeComprovante']:=UpperCase(copy(Descricao,2,length(Descricao)));
   if FSigtron.SigDrCm1.send = -1 then
      result := '1|'
   else
      result := '0|';
   end
else
   if ( StrToInt(Numero)<16 ) or ( Trim(Descricao)='') then
      Begin
      ShowMessage('Para cadastro dos totalizadores não Fiscais usar a faixa de registradores :'+chr(10)+chr(13)+
                  '16 a 32 -> Cupom nao Fiscal Vinculado  '+chr(10)+chr(13)+
                  '51 a 66 -> Cupom nao Fiscal Vinculado de mesmo nome automatico '+chr(10)+chr(13));
      result:='1|';
      exit;
      end
   else
     begin
     Descricao:=UpperCase(Descricao);
     FSigtron.SigDrCm1.LibName := 'Configuracao';
     FSigtron.SigDrCm1.CmdName := 'PersonalizacaoNomePagamento';
     FSigtron.SigDrCm1.Param['CodigoPagamento']:=formataTexto(Numero,2,0,2);
     FSigtron.SigDrCm1.Param['DescricaoPagamento']:=copy(Descricao+space(21),1,21);
     if FSigtron.SigDrCm1.send = -1 then
        result := '1|'
     else
        result := '0|';
     end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var
  bRet : Boolean;
  iPos:Integer;
  sLinha:AnsiString;

begin
bRet:=True;
iPos:=Pos(#10,Texto);
while iPos<>0 do
  begin
  sLinha:=Copy(Texto,1,iPos-1);
  FSigtron.SigDrCm1.LibName := 'Fiscal';
  FSigtron.SigDrCm1.CmdName := 'Texto';
  FSigtron.SigDrCm1.Param['Texto']:=sLinha+chr(10);
  //FSigtron.SigDrCm1.Param['TextoLivre']:=Texto;
  if FSigtron.SigDrCm1.send = -1 then
     Begin
     bRet:= False;
     Break;
     End;

  Texto:=Copy(Texto,iPos+1,Length(Texto));
  iPos:=Pos(#10,Texto);

  end;
if not bRet then
   result := '1|'
else
   result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.FechaCupomNaoFiscal: AnsiString;
Begin
  FSigtron.SigDrCm1.LibName := 'Fiscal';
  FSigtron.SigDrCm1.CmdName := 'FechamentoCNF';
  if FSigtron.SigDrCm1.send = -1 then
    result := '1|'
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.StatusImp( Tipo:Integer ):AnsiString;
//Tipo - Indica qual o status quer se obter da impressora
//  1 - Obtem a Hora da Impressora
//  2 - Obtem a Data da Impressora
//  3 - Verifica o Papel
//  4 - Verifica se é possível cancelar um ou todos os itens.
//  5 - Cupom Fechado ?
//  6 - Ret. suprimento da impressora
//  7 - ECF permite desconto por item
//  8 - Verica se o dia anterior foi fechado
//  9 - Verifica o Status do ECF
// 10 - Verifica se todos os itens foram impressos.
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
// 13 - Verifica se o ECF Arredonda o Valor do Item
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
// 16 - Verifica se exige o extenso do cheque
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware

var
  sTipo: AnsiString;

begin
If Tipo = 1 then
   begin
   // Verifica a hora da impressora
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'LeituraRelogio';
   if FSigtron.SigDrCm1.send = -1 then
      Result := '1|'
   else
      result := '0|' + FSigtron.SigDrCm1.Ret['Hora'] + ':' + FSigtron.SigDrCm1.Ret['Minuto'] + ':'+FSigtron.SigDrCm1.Ret['Segundo']
   end

else if Tipo = 2 then
   begin
   // Verifica a hora da impressora
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'LeituraRelogio';
   if FSigtron.SigDrCm1.send = -1 then
      Result := '1|'
   else
      result := '0|' + FSigtron.SigDrCm1.Ret['Dia'] + '/' + FSigtron.SigDrCm1.Ret['Mes']+ '/'+FSigtron.SigDrCm1.Ret['Ano']
   end

else if Tipo = 3 then // Verifica o estado do papel
   begin
   sTipo:='2367ABEF';
   FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
   FSigtron.SigDrCm1.CmdName := 'Status';
   if FSigtron.SigDrCm1.send <> -1 then
      if Pos(AnsiString(FSigtron.SigDrCm1.Ret['S2']),sTipo)<>0 then
         result := '0|'
      else
         result := '1|'

   end

else if Tipo = 4 then
    result := '0|TODOS'

  //Cupom Fechado ?
else if Tipo = 5 then
   begin
   FSigtron.SigDrCm1.LibName := 'Leitura';
   FSigtron.SigDrCm1.CmdName := 'InformacaoUltimoDocumento';
   if FSigtron.SigDrCm1.send =-1 then
      result := '1|'
   else
       if FSigtron.SigDrCm1.Ret['COO']='000000' then
          result := '1|'
       else
          result := '0|';
   end
  //Ret. suprimento da impressora
else if Tipo = 6 then
  begin
  result := '0|0.00';
  end
// Verif.se ECF permite desconto por item
else if Tipo = 7 then
  result := '0|'
// Verifica se o ECF foi fechado no dia anterior
else if Tipo = 8 then
   begin
   sTipo:='01234567';
   FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
   FSigtron.SigDrCm1.CmdName := 'Status';
   if FSigtron.SigDrCm1.send <> -1 then
      if Pos(AnsiString(FSigtron.SigDrCm1.Ret['S4']),sTipo)=0 then
         result := '0|'
      else
         result := '1|'
   end
//9 - Verifica o Status do ECF
else if Tipo = 9 then
  result := '0'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 then
  result := '0'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 then
  result := '1'
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
else if Tipo = 12 then
  result := '1'
// 13 - Verifica se o ECF Arredonda o Valor do Item
else if Tipo = 13 then
  result := '1'
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
else if Tipo = 14 then
  // 0 - Fechada
  Result := '0'
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
  Result := '1'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
  Result := '1'
// 20 ao 40 - Retorno criado para o PAF-ECF
else if (Tipo >= 20) AND (Tipo <= 40) then
  Result := '0'
else If Tipo = 45 then
     Result := '0|'// 45 Codigo Modelo Fiscal
else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
      Result := '0|'// 45 Codigo Modelo Fiscal
//Retorno não encontrado
else
  Result := '1';
end;


//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString;
Var
  sRet:AnsiString;

begin
  Valor:=FormataTexto(Valor,12,2,2);
  Verso:=copy(Trim(Verso)+space(120),1,120);
  Data:=FormataData(StrToDate(Data),2);
  sRet:='00';
  FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
  FSigtron.SigDrCm1.CmdName := 'Banco';
  FSigtron.SigDrCm1.Param['Banco']:=FormataTexto(Banco,3,0,2);
  if FSigtron.SigDrCm1.send <> -1 then
     begin
     FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
     FSigtron.SigDrCm1.CmdName := 'Cidade';
     FSigtron.SigDrCm1.Param['Cidade']:=copy(Trim(Cidade)+space(25),1,25);
     if FSigtron.SigDrCm1.send <> -1 then
        begin
        FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
        FSigtron.SigDrCm1.CmdName := 'Data';
        FSigtron.SigDrCm1.Param['Dia']:=Copy(Data,1,2);
        FSigtron.SigDrCm1.Param['Mes']:=Copy(Data,3,2);
        FSigtron.SigDrCm1.Param['Ano']:=Copy(Data,5,4);
        if FSigtron.SigDrCm1.send <> -1 then
           Begin
           FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
           FSigtron.SigDrCm1.CmdName := 'Favorecido';
           FSigtron.SigDrCm1.Param['Favorecido']:=copy(Trim(Favorec)+space(65),1,65);
           if FSigtron.SigDrCm1.send <> -1 then
              begin
              FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
              FSigtron.SigDrCm1.CmdName := 'TextoVerso';
              FSigtron.SigDrCm1.Param['Texto']:=Valor;
              if FSigtron.SigDrCm1.send <> -1 then
                 Begin
                 FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
                 FSigtron.SigDrCm1.CmdName := 'ImpressaoChequeV';
                 FSigtron.SigDrCm1.Param['Valor']:=Valor;
                 if FSigtron.SigDrCm1.send <> -1 then
                    sRet:='99';
                 end;
              end;
            end;  
        end;
     end;
  if sRet='99' then
     result := '0|'
  else
     result := '1|'
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString;
var
  sDataInicio,sDataFinal: AnsiString;
  Local: AnsiString;
Begin
   sDataInicio:=FormataData( DataInicio,1 );
   sDataFinal :=FormataData( DataFim   ,1 );
   //Variavél que sera utilizada quando for implementada a opção de leitura da memoria fiscal por reduçao
   Local :='1';

  if local='1' then
     Local:='x'
  else
     Local:='s';
  {
   //Sera utilizada quando for implementada a opção de leitura da memoria fiscal por reduçao
  if Trim(ReducaoInicio)<>'' then
     Begin
     FSigtron.SigDrCm1.LibName := 'Fiscal';
     FSigtron.SigDrCm1.CmdName := 'LeituraMFPorCRZ';
     FSigtron.SigDrCm1.Param['TipoLeitura']:=Local;
     FSigtron.SigDrCm1.Param['Inicio']:=FormataTexto( ReducaoInicio,4,0,2 );
     FSigtron.SigDrCm1.Param['Final' ] :=FormataTexto( ReducaoFim,4,0,2 );
     if FSigtron.SigDrCm1.send = -1 then
        result := '1|'
      else
        result := '0|'
     end
    }

     FSigtron.SigDrCm1.LibName := 'Fiscal';
     FSigtron.SigDrCm1.CmdName := 'LeituraMFPorDatas';
     FSigtron.SigDrCm1.Param['TipoLeitura']:=Local;
     FSigtron.SigDrCm1.Param['DiaInicio']:= Copy(sDataInicio,1,2);
     FSigtron.SigDrCm1.Param['MesInicio']:= Copy(sDataInicio,3,2);
     FSigtron.SigDrCm1.Param['AnoInicio']:= Copy(sDataInicio,5,4);
     FSigtron.SigDrCm1.Param['DiaFinal']:=Copy(sDataFinal,1,2);
     FSigtron.SigDrCm1.Param['MesFinal']:=Copy(sDataFinal,3,2);
     FSigtron.SigDrCm1.Param['AnoFinal']:=Copy(sDataFinal,5,4);
     if FSigtron.SigDrCm1.send = -1 then
        Result := '1|'
     else
       Result := '0|'
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Sigtron FS-2000
///
function TImpChequeSigtron2000.Abrir( aPorta:AnsiString ): Boolean;
begin
  Result := (Copy(OpenSigtron( aPorta, 'FS2K.CFG' ),1,1) = '0');
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron2000.AbreECF:AnsiString;
Var
  sRedZ :  AnsiString;
  sLeitX: AnsiString;
  sTemp : AnsiString;

begin
Result := '0|';
sRedZ :='01234567';
sLeitX:='014589CD';
FSigtron.SigDrCm1.LibName := 'OperacaoEspecial';
FSigtron.SigDrCm1.CmdName := 'Status';
if FSigtron.SigDrCm1.send <> -1 then
   begin
   sTemp:=FSigtron.SigDrCm1.Ret['S4'];
   if Pos(sTemp,sRedZ)<>0 then
      ShowMessage('Redução Z, pendende')
   else
     if Pos(sTemp,sLeitX)<>0 then
        Begin
        Result := '1|';
        if Copy(LeituraX,1,1)='0' then
           Result := ' 0|';
        End
   end;
end;

//----------------------------------------------------------------------------
function TImpChequeSigtron2000.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  bRet : Boolean;
  sCidade  : AnsiString;
  sFavorec : AnsiString;
  sVerso   : AnsiString;
  sValor   : AnsiString;
  sData    : AnsiString;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  // O tamanho maximo para a impressao da Cidade eh 12.
  sCidade  := Trim(Copy(Cidade,1,12));
  sFavorec := Trim(Copy(Favorec,1,65));
  sVerso   := Trim(Copy(Verso,1,80));
  sValor   := FormataTexto(Valor,12,2,2);
  bRet := False;
  With FSigtron.SigDrCm1 Do
  Begin
    LibName := 'OperacaoEspecial';
    CmdName := 'Banco';
    Param['Banco'] := Banco;
    if Send <> -1 then
    begin
      LibName := 'OperacaoEspecial';
      CmdName := 'Cidade';
      Param['Cidade'] := sCidade;
      if Send <> -1 then
      begin
        LibName := 'OperacaoEspecial';
        CmdName := 'Data';
        Param['Dia'] := Copy(Data,7,2);
        Param['Mes'] := Copy(Data,5,2);
        Param['Ano'] := Copy(Data,1,4);
        if Send <> -1 then
        begin
          LibName := 'OperacaoEspecial';
          CmdName := 'Favorecido';
          Param['Favorecido'] := sFavorec;
          if Send <> -1 then
          begin
            LibName := 'OperacaoEspecial';
            CmdName := 'ImpressaoChequeV';
            Param['Valor'] := sValor;
            if Send <> -1 then
            begin
              bRet := True;
              if sVerso <> '' then
              begin
                Showmessage('Insira o verso do cheque e tecle <ENTER>');
                LibName := 'OperacaoEspecial';
                CmdName := 'TextoVerso';
                Param['Texto'] := sVerso;
                Send;
              end;
            end;
          end;
        end;
      end;
    end;
  End;
  Result := bRet;
end;

//----------------------------------------------------------------------------
function TImpChequeSigtron2000.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequeSigtron2000.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
end;

//----------------------------------------------------------------------------
function TImpChequeSigtron2000.Fechar( aPorta:AnsiString ): Boolean;
begin
  Result := (Copy(CloseSigtron,1,1) = '0');
end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenSigtron( sPorta, sCFGFile:AnsiString ) : AnsiString;
begin
  sPortaAux := sPorta;
  sCFGFileAux := sCFGFile;
  If bOpened Then
    Result := '0|'
  Else
  Begin
    FSigtron := TFSigtron.Create(NIL);
    With FSigtron.SigDrCm1 Do
    Begin
      DeviceType  := 1;
      CtsFlow     := True;
      DsrFlow     := True;
      CmdFileName := sCFGFile;
      TimeOut     := 6000;
      LibName     := 'Fiscal';
      CommConfig  := sPorta+': baud=9600 parity=N data=8 stop=1';
    End;

    bOpened := True;
    Result := '0|';

    if Not FSigtron.SigDrCm1.Open then
    begin
      ShowMessage('Erro na abertura da porta');
      bOpened := False;
      result := '1|';
    end;
  End;
end;

//----------------------------------------------------------------------------
Function OpenSigtronDLL : AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: fs345_32.dll'+#13+
                  '(Atualize a versão da DLL do Fabricante do ECF)');
      Result := False;
    end
    else
      Result := True;
  end;
var
  aFunc: Pointer;
  iRet : Integer;
  sConf: AnsiString;
begin
  CloseSigtron;
  If bOpened Then
    Result := '0|'
  Else
  Begin
    fHandle := LoadLibrary( 'fs345_32.dll' );
    if (fHandle <> 0) Then
    begin
      aFunc := GetProcAddress(fHandle,'DAR_sDescEstendida');
      if ValidPointer( aFunc, 'DAR_sDescEstendida' ) then
        fFuncDAR_sDescEstendida := aFunc;

      aFunc := GetProcAddress(fHandle,'DAR_AbreSerial');
      if ValidPointer( aFunc, 'DAR_AbreSerial' ) then
        fFuncDAR_AbreSerial := aFunc;

      aFunc := GetProcAddress(fHandle,'DAR_FechaSerial');
      if ValidPointer( aFunc, 'DAR_FechaSerial' ) then
        fFuncDAR_FechaSerial := aFunc;

      aFunc := GetProcAddress(fHandle,'DAR_LeituraX');
      if ValidPointer( aFunc, 'DAR_LeituraX' ) then
        fFuncDAR_LeituraX := aFunc;

      aFunc := GetProcAddress(fHandle,'DAR_Erro');
      if ValidPointer( aFunc, 'DAR_Erro' ) then
        fFuncDAR_Erro := aFunc;

      bOpened := True;
      Result := '0|';
       // Esse comando só irá fazer a abertura da porta. Não checa se a impressora está ou não ligada.
      sConf := (sPortaAux + ':9600,n,8,1');
      iRet := fFuncDAR_AbreSerial(sConf);
      if iRet = -1 then
      begin
        bOpened := False;
        result := '1|';
      end;
    end
    else
        result := '1|';
  End;
end;

//----------------------------------------------------------------------------
Function CloseSigtron : AnsiString;
begin
  Result := '0|';
  bOpened := False;
  FSigtron.Free;
  FSigtron := NIL;
end;

//----------------------------------------------------------------------------
Function CloseSigtronDLL : AnsiString;
var iRet : integer;
begin
  iRet := fFuncDAR_FechaSerial('1');
  If iRet <> -1 then
  begin
    bOpened := False;
    If OpenSigtron(sPortaAux, sCFGFileAux) <> '1|' then
      Result := '0';
  End
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.PegaSerie : AnsiString;
begin
    result := '1|Funcao nao disponivel';
end;

//-----------------------------------------------------------
function TImpFiscalSigtron.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
begin
  ShowMessage('Recurso de emissão de pedido não disponível para essa impressora.');
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString;
begin
  Result := RelatorioGerencial(cTextoImp , nVias ,ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.RelatorioGerencial( Texto:AnsiString ;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
var sRet : AnsiString;
begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Fiscal';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'AberturaRelatorio';
    {Envia comando}
    if FSigtron.SigDrCm1.send = -1 then
      Result := '1|'
    else
    Begin
        // Tempo para imprimir a Leitura X
        Sleep(18000);
        sRet := TextoNaoFiscal( Texto, Vias);

        If Copy(sRet,1,1) = '0' then
        Begin
            FSigtron.SigDrCm1.LibName := 'Fiscal';
            FSigtron.SigDrCm1.CmdName := 'FechamentoComprovante';
            if FSigtron.SigDrCm1.send = -1 then
               Result := '1|'
            else
               Result := '0|';
        End
        Else
        Begin
            ShowMessage('Erro ao tentar imprimir as linhas de texto !');
            Result := '1|';
        End;
    end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;
//------------------------------------------------------------------------------
function TImpFiscalSigtron.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( 'Função não disponível para este equipamento', mtError,[mbOK],0);
  Result := '1';
End;

//----------------------------------------------------------------------------
function TImpFiscalSigtron120.PegaSerie : AnsiString;
var
  sRet : AnsiString;
begin
{Biblioteca de Comandos}
FSigtron.SigDrCm1.LibName := 'Leitura';
{Nome do Comando}
FSigtron.SigDrCm1.CmdName := 'LeituraIdentificacao';
    {Envia comando}
    if FSigtron.SigDrCm1.send = -1 then
      Result := '1|'
    else
    Begin
      sRet := FSigtron.SigDrCm1.Ret['NumeroSerie'];
      Result := '0'+'|'+sReT;
    End;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron120.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;

var
 aPag: array of array of AnsiString;  //Array para formas de Pagamento [Forma,Valor,Codigo na Impressora]
 aForma: array of AnsiString;
 iTam:Integer;
 iForma:integer;
 iPos:integer;
 sForma,sPagAux:AnsiString;
 bRet:Boolean;
begin
sPagAux := '';
    While Pos('|',Pagamento)>0 do
    Begin
        sPagAux    := sPagAux + Copy(Pagamento,1,Pos('|',Pagamento)-1);
        Pagamento := Copy(Pagamento,Pos('|',Pagamento)+1,Length(Pagamento));
        sPagAux    := sPagAux +'|'+Trim(FormataTexto(Copy(Pagamento,1,Pos('|',Pagamento)-1),12,2,3,'.'))+'|';
        Pagamento := Copy(Pagamento,Pos('|',Pagamento)+1,Length(Pagamento));
    End;
Pagamento := sPagAux;
Pagamento := StrTran(Pagamento,'.','');
iForma:=0;
iTam:=0;
bRet:=True;
While Trim(Pagamento) <> '' do
  begin
  iPos:=Pos('|',Pagamento);
  if iPos <>1 then
     begin
     if iForma=0 Then // Descrição da AnsiString Pagamentos
        Begin
        SetLength( aPag,iTam+1 );
        SetLength( aPag[iTam],3);
        //Grava o descrição da forma de pagamento
        aPag[iTam,iForma]:=UpperCase(Copy(Pagamento,1,iPos-1));
        end
      else  // Valor da AnsiString Pagamentos
        //Grava o Valor do pagamento em 12 posicões
        aPag[iTam,iForma]:=FormataTexto(Copy(Pagamento,1,iPos-1),12,0,2);

     if iForma = 1 then
        begin
        iForma:=0;
        inc(iTam);
        end
     else
         inc(iForma);
     end;
  Pagamento:=copy(Pagamento,iPos+1,length(Pagamento));
  end;

//Leitura da Forma de Pagamento
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraMensagensPersonalizados';
if FSigtron.SigDrCm1.send = -1 then
   Result := '1|'
else
   Begin
   sForma:=FSigtron.SigDrCm1.Ret['NomeFormasPagto'];
   // Gravar o array com as forma de Pagamento da Impressora
   iTam:=0;
   While Length(sForma)<>0 do
       begin
       If Trim(Copy(sForma,2,17)) <> '' then
          Begin
          SetLength( aForma, iTam+1 );
          aForma[iTam]:=UpperCase(Trim(copy(sForma,2,17)));
          Inc(iTam);
          end;

       sForma:=Copy(sForma,19,Length(sForma));
       end;
   // Gravar no Array de Pagamentos, codigo da forma de Pagamento da Impressora
   // sendo de A á Z, ( chr(65) á Chr(81) )
   for iTam:=0 to High(aPag) do
      for iForma:=0 to High(aForma) do
          if aPag[iTam,0] = aForma[iForma] Then
             begin
             aPag[iTam,2]:=Chr(65+iForma);
             Break;
             end;
   // Totalizacao do Cupom - caso nao tenha executado por Desconto no Total ou no Acrescimo Total
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   FSigtron.SigDrCm1.CmdName := 'TotalizacaoCupomFiscal';
   FSigtron.SigDrCm1.Param['TipoDescAcres']:='1';
   FSigtron.SigDrCm1.Param['ValorDescAcres']:='00000000000';
   FSigtron.SigDrCm1.send;

   // Executa todas as formas de pagamento recebidas
   for iForma:=0 to High(aPag) do
      Begin
      //Nome do Comando
      FSigtron.SigDrCm1.LibName := 'Fiscal';
      FSigtron.SigDrCm1.CmdName := 'DescricaoPagamento';
      FSigtron.SigDrCm1.Param['ValorPagamento']:=aPag[iForma,1];
      FSigtron.SigDrCm1.Param['FormaPagamento']:=aPag[iForma,2];
      if FSigtron.SigDrCm1.send = -1 then
         Begin
         bRet:=False;
         Break;
         end
      end;

   if bRet then
      if StrToInt(FSigtron.SigDrCm1.Ret['Saldo'])<>0 Then
      // ???? Saber qual decisao tomar quando o valor não bater
         bRet:=False;

   if not bRet then
      Result := '1|'
   else
      Result := '0|';

   end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron120.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;

    function Comprovante( Comprovante,Tipo:AnsiString ) : AnsiString;
    var
    sForma:AnsiString;
    iTam:integer;

    Begin
    //Saber o nome do Totalizador
    FSigtron.SigDrCm1.LibName := 'Leitura';
    FSigtron.SigDrCm1.CmdName := 'LeituraMensagensPersonalizados';
    if FSigtron.SigDrCm1.send = -1 then
       result := ' '
    else
       Begin
       if tipo='V' then
          sForma:=FSigtron.SigDrCm1.Ret['NomeCNFVs']
       else
          sForma:=FSigtron.SigDrCm1.Ret['NomeCNFNVs'];

       iTam:=0;
       While Length(sForma)<>0 do
            begin
            If Trim(Copy(sForma,2,17)) <> '' then
               If UpperCase(Trim(copy(sForma,2,21)))=UpperCase(Trim(copy(Totalizador,1,22))) then
                  Break;

            sForma:=Copy(sForma,23,Length(sForma));
            inc(iTam);
            end;
        Result:=Chr(65+iTam);
       end;
    end;
Var
  sNumeroCupom:AnsiString;
  aForma: array of AnsiString;
  sForma:AnsiString;
  sIdentificacao:AnsiString;
  sFormaPaga:AnsiString;
  iTam:Integer;

begin

Valor:=StrTran(Valor,'.','');
Valor:=FormataTexto(Valor,12,0,2 );

//Pegar a letra do resistrador da forma de pagamento
//Leitura da Forma de Pagamento
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraMensagensPersonalizados';
if FSigtron.SigDrCm1.send = -1 then
   Begin
   Result := '1|';
   exit;
   end;

sForma:=FSigtron.SigDrCm1.Ret['NomeFormasPagto'];
// Gravar o array com as forma de Pagamento
iTam:=0;
While Length(sForma)<>0 do
    begin
    If Trim(Copy(sForma,2,17)) <> '' then
       Begin
       SetLength( aForma, iTam+1 );
       aForma[iTam]:=UpperCase(Trim(copy(sForma,2,17)));
       Inc(iTam);
       end;

    sForma:=Copy(sForma,19,Length(sForma));
    end;

for iTam:=0 to High(aForma) do
    if Length(aForma[iTam]) < 16 then
    begin
        if Trim(aForma[iTam]) = Trim(UpperCase(Condicao)) Then
        Begin
           //Pegando a letra da forma de pagamento
           sFormaPaga:=chr(65+iTam);
           Break;
        end;
    End
    Else
        if Copy(aForma[iTam],1,16) = Trim(UpperCase(Condicao)) Then
        Begin
           //Pegando a letra da forma de pagamento
           sFormaPaga:=chr(65+iTam);
           Break;
        end;


iTam:=-1;
// Pegar o numero do cupom a ser vinculado.
FSigtron.SigDrCm1.LibName := 'Leitura';
FSigtron.SigDrCm1.CmdName := 'LeituraEstadoDocumento';
if FSigtron.SigDrCm1.send <> -1 then
   begin
   //Emissao do Cupom NAO Fiscal VINCULADO
   sNumeroCupom:=FSigtron.SigDrCm1.Ret['NumeroCupom'];
   //Pegando o numero do Cupom
   sNumeroCupom:=IntToStr(StrToInt(sNumeroCupom)-1);
   sNumeroCupom:=FormataTexto(sNumeroCupom,6,0,2);

   //Saber o nome do Totalizador
   sIdentificacao:=Comprovante(Totalizador,'V');

   //Abrindo cupom não fiscal vinculado.
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   FSigtron.SigDrCm1.CmdName := 'AberturaCNFV';
   FSigtron.SigDrCm1.Param['IdentificacaoCNFV']:=sIdentificacao;
   FSigtron.SigDrCm1.Param['TipoCNFV']:=sFormaPaga;
   FSigtron.SigDrCm1.Param['COOorigem']:=sNumeroCupom;
   FSigtron.SigDrCm1.Param['ValorVinculado']:=Valor;
   iTam:=FSigtron.SigDrCm1.send;
   end;

if iTam=-1 then
   Begin
   //Abrindo cupom não fiscal não vinculado.
   sIdentificacao:=Comprovante(Totalizador,'NV');
   FSigtron.SigDrCm1.LibName := 'Fiscal';
   FSigtron.SigDrCm1.CmdName := 'EmissaoCNFNV';
   FSigtron.SigDrCm1.Param['IdentificacaoCNFNV']:=sIdentificacao;
   FSigtron.SigDrCm1.Param['DescontoAcrescimo']:='0';
   FSigtron.SigDrCm1.Param['DescAcres']:='000000000000';
   FSigtron.SigDrCm1.Param['Valor']:=Valor;
   FSigtron.SigDrCm1.Param['Mensagem']:='';
   iTam:=FSigtron.SigDrCm1.send;
   end;

if iTam=-1 then
   result := '1|'
else
   result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalSigtron120.Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
Var sRet: AnsiString;
begin
    if Forma = '' then Forma := 'DINHEIRO';

  Case Tipo of
    1:  Result := '0';
    2:  begin
            sRet := AbreCupomNaoFiscal( Forma,Valor,'SUPRIMENTO','');
            If copy(sRet,1,1) = '0' then
                sRet := Pagamento(Forma+'|'+Valor+'|','N','');
            Result := sRet
        end;
    3:  Result := AbreCupomNaoFiscal( Forma,Valor,'SANGRIA','');
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.Abrir(sPorta: AnsiString; iHdlMain:Integer) : AnsiString;
var
 iRet : Integer;
begin
  sMarca := 'DARUMA';
  Result := OpenDaruma( sPorta );
  // Carrega as aliquotas para ganhar performance
  if Copy(Result,1,1) = '0' then
  begin
    AlimentaProperties;

    If (fHandle <> 0) and (fHandle2 <> 0) then //Necessário configurar isto quando utiliza as duas dlls Daruma32.dll + DarumaFrameWork.dll
    begin
      iRet := fFuncDaruma_Registry_AlterarRegistry('ECF','CONTROLEPORTA','2');
      TrataRetornoDaruma( iRet );

      iRet := fFuncDaruma_Registry_AlterarRegistry('ECF','ThreadNoStartup','0');
      TrataRetornoDaruma( iRet );

      iRet := fFunceBuscarPortaVelocidade_ECF_Daruma();
      TrataRetornoDaruma( iRet );
      If iRet = 1 then
      begin
        iRet := fFuncregAlterarValor_Daruma('ECF\ControleAutomatico','0');
        TrataRetornoDaruma( iRet );
      end;  
    end;
  end;
end;

//---------------------------------------------------------------------------
function TImpFiscalDaruma120.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  Result := CloseDaruma;
end;

//----------------------------------------------------------------------------
Function TImpFiscalDaruma120.LeituraX:AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncDaruma_FI_LeituraX;
  TrataRetornoDaruma( iRet );
  if iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.AbreEcf:AnsiString;
begin
    Result := '0'
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.FechaEcf:AnsiString;
var
  iRet : Integer;
  sData : AnsiString;
  sHora : AnsiString;
begin
  // chama a funcao de ReducaoZ
  sData := DateToStr(Date);
  sHora := TimeToStr(Time);
  iRet := fFuncDaruma_FI_ReducaoZ( sData, sHora );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.ReducaoZ(MapaRes:AnsiString):AnsiString;
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
  iRet, i, iSubTrib: Integer;
  sData, sHora : AnsiString;
  aRetorno, aFile : array of AnsiString;
  sRetorno, sAliqISS : AnsiString;
  Reg:  TRegistry;
  sPathDaruma : AnsiString;
  fFile : TextFile;
  sFile, sLinha, sFlag, sValDeb : AnsiString;
  rValDeb : Real;
begin
 Result := '1';
 If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    iRet := fFuncDaruma_FI_DataMovimento(aRetorno[ 0]);
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := PDV;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0' then
      aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));


    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    iRet := fFuncDaruma_FI_NumeroReducoes( aRetorno[3] );
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    iRet := fFuncDaruma_FI_GrandeTotal( aRetorno[ 4] );
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    iRet := fFuncDaruma_FI_NumeroCupom( aRetorno[ 6] );
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[ 5] := aRetorno[ 6];

    aRetorno[ 7] := Space (14);                         //**** Valor do Cancelamento ****//
    iRet := fFuncDaruma_FI_Cancelamentos( aRetorno[ 7] );
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    aRetorno[ 9] := Space (14);                         //**** Desconto ****//
    iRet := fFuncDaruma_FI_Descontos( aRetorno[ 9] );
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    sRetorno := Space(445);
    iRet := fFuncDaruma_FI_VerificaTotalizadoresParciais(sRetorno);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[11] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[12] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** Nao tributado Nao Tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[10] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);

    aRetorno[15] := FormataTexto('0',16, 0, 1);                         // --outros recebimentos--


    aRetorno[17] := Space(4);
    iRet := fFuncDaruma_FIR_RetornaCRO( aRetorno[17] );
    aRetorno[17] := Copy( aRetorno[ 17 ], 2, Length( aRetorno[ 17 ] ) );

    aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS
    aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS
    aRetorno[20]:= '00';                                         // QTD DE Aliquotas


 end;

  sData := DateToStr(Date);
  sHora := TimeToStr(Time);
  iRet := fFuncDaruma_FI_ReducaoZ( sData, sHora );
  TrataRetornoDaruma( iRet );

  If iRet = 1 then
  begin
        If Trim(MapaRes) = 'S' then
        begin
            //******************************************************************
            //* Pega o caminho no registry do windows em qual path será gravado
            //* o arquivo RETORNO.TXT
            //******************************************************************
            sPathDaruma := 'C:\';
            Reg := TRegistry.Create;
            try
              Reg.RootKey := HKEY_LOCAL_MACHINE;
              if Reg.OpenKey('\Software\Daruma\ECF\', True)
              then sPathDaruma := Reg.ReadString( 'Path' );
            finally
              Reg.CloseKey;
              Reg.Free;
            end;

            //******************************************************************
            //* Chama a funcao para pegar as informacoes do MapaResumo
            //******************************************************************
            iRet := fFuncDaruma_FI_MapaResumo();
            TrataRetornoDaruma( iRet );
            If iRet = 1 then
            begin

                sFile :=  sPathDaruma + 'RETORNO.TXT' ;
                If FileExists(sFile) then
                begin
                    AssignFile(fFile, sFile);
                    Reset(fFile);
                    sFlag:='';
                    ReadLn(fFile, sLinha);

                    iSubTrib := 0;
                    i := 0;

                    While not Eof(fFile) do
                    Begin
                      If Trim( sLinha ) <> '' then
                      Begin
                        SetLength( aFile, Length(aFile) + 1 );
                        aFile[ i ] := sLinha;
                        ReadLn(fFile, sLinha);
                        i := i+1;
                      End
                      Else
                        ReadLn(fFile, sLinha);
                    End;

                    CloseFile(fFile);
                    For i := 0 to Length( aFile ) - 1 Do
                    Begin
                        If iSubTrib = 1 then iSubTrib := 2;

                        sLinha := aFile[ i ];
                        sLinha := TrataLinha(sLinha);
                        if ( Pos( 'Venda LÝquida..........:',sLinha ) >0 ) Or
                           ( Pos( 'Venda Líquida..........:',sLinha ) >0 ) then  // Venda Liquida
                            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida

                        if ( Pos('ISS....................:',sLinha)>0) then  // Totais ISS
                        begin
                          sAliqISS := CapturaBaseISSRedZ;     //Retorna os valores gastos de ISS separados por valor de Base
                        //                      ' Valor '  ' Imposto Debitado
                            aRetorno[16] :=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),14,2,1,'.')+
                                        ' 00000000000.00' + ';' + sAliqISS;
                        end;

                        if ( Pos('SubstituiþÒo Tributßria:',sLinha)>0) Or
                           ( Pos('Substituição Tributária:',sLinha)>0) then  // Totais ISS
                            iSubTrib := 1;

                        if iSubTrib = 2 then
                        begin
                            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);

                            // Aliquota '  ' Valor '  ' Imposto Debitado
                            SetLength( aRetorno, Length(aRetorno)+1 );
                            rValDeb := StrToFloat( Copy( sLinha, 1, 4 ) ) / 10000;
                            rValDeb := rValDeb * StrToFloat( StrTran( Trim( StrTran( Copy( sLinha, Length( sLinha ) - 14, 15 ),'.','' ) ), ',', '.' ) );
                            sValDeb := FloatToStr( rValDeb );
                            sValDeb := StrTran( sValDeb, ',', '.' );
                            sValDeb := FormataTexto( sValDeb, 14, 2, 1, '.' );
                            aRetorno[High(aRetorno)] := 'T'+Copy(sLinha,1,2) +','+Copy(sLinha,3,2) +' ' + FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),14,2,1,'.')+ ' ' + sValDeb;
                        end;

                    End;

                    Result := '0|';
                    For i:= 0 to High(aRetorno) do
                         Result := Result + aRetorno[i]+'|';

                end;
            end;
        end
        else
            Result := '0|';
    end
    else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
var
  iRet : Integer;
begin
  lDescAcres:=False;

  {Quebram | parametro padrão ao abrir Cupom(CPF,Nome,Endereco), Daruma espera apenas o CPF/CNPJ}
  If Pos('|',Cliente) > 0 Then
    Cliente := Copy(Cliente,1,Pos('|',Cliente)-1);

  If Length( Cliente ) > 29 then
    Cliente := Copy( Cliente, 1, 29 );
  iRet := fFuncDaruma_FI_AbreCupom( Cliente );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet : Integer;
  sNumCupom : AnsiString;
begin
  sNumCupom := Space( 6 );
  iRet := fFuncDaruma_FI_NumeroCupom( sNumCupom );
 // se o cupom estiver aberto, o valor retornado é o do próprio cupom
 // se estiver fechado, o valor retornado é do próximo cupom
  If StatusImp(5) = '0' then
      sNumCupom := FormataTexto(IntToStr(StrToInt(sNumCupom)-1),6,0,2)
  Else
      sNumCupom := FormataTexto(IntToStr(StrToInt(sNumCupom)),6,0,2);

  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Result := '0|' + sNumCupom
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.PegaPDV:AnsiString;
begin
  Result := '0|' + Pdv;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.LeAliquotas:AnsiString;
begin
  Result := '0|' + ICMS;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.LeAliquotasISS:AnsiString;
begin
  Result := '0|' + ISS;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.LeCondPag:AnsiString;
var
  iRet, i : Integer;
  sRet : AnsiString;
  sPagto : AnsiString;
begin
  sRet := Space( 3016 );
  iRet := fFuncDaruma_FI_VerificaFormasPagamentoEx( sRet );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
  begin
    sPagto := '';
    For i:=0 to 15 do
        If Trim(Copy(sRet,1,16))<>'' then
        begin
            sPagto := sPagto + Trim(copy( sRet, 1, 16 )) + '|';
            sRet:= Copy(sRet,58,Length(sRet));
        end
        Else
        Begin
            sRet:= Copy(sRet,58,Length(sRet));
        end;
    Result := '0|' + sPagto;
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  iRet : Integer;
begin
  NumItem := FormataTexto( numitem, 3, 0, 2 );
  iRet := fFuncDaruma_FI_CancelaItemGenerico( NumItem );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.CancelaCupom(Supervisor:AnsiString):AnsiString;
var
  iRet : Integer;
begin
  // Para cancelar um cupom aberto deve-ser ter ao menos um item vendido.
  iRet := fFuncDaruma_FI_CancelaCupom;
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  iRet : Integer;
  sTrib : AnsiString;
  sAliquota : AnsiString;
  sIndiceISS, sAliqISS : AnsiString;
  sTipoQtd : AnsiString;
  iCasas: Integer;
begin
  iCasas:=2;
  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    result := '11';
    exit;
  end;

  // Verifica o ponto decimal dos parâmetros
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');
  qtde := StrTran(qtde,',','.');

  // Verifica se existe a aliquota cadastrada na impressora.
  sTrib := Copy(aliquota,1,1);
  sAliquota := Copy(aliquota,2,5);
  sAliquota := StrTran( StrTran( sAliquota, ',', '' ), '.', '' );

  If sTrib = 'F' then
       sAliquota := 'FF';
  If sTrib = 'I' then
       sAliquota := 'II';
  If sTrib = 'N' then
       sAliquota := 'NN';
  If sTrib = 'T' then
       sAliquota := FormataTexto(sAliquota,4,0,2);
  If sTrib = 'S' then
  Begin
        sAliquota := '';
        sAliqISS := LeAliquotasISS();
        sAliqISS := Copy(sAliqISS, 3, Length(sAliqISS));
        sIndiceISS := Space(48);
        iRet := fFuncDaruma_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoDaruma(iRet);
        If iRet = 1 then
        Begin
            While (sAliquota = '') and (Length(sIndiceISS)>0) do
            Begin
                If StrToFloat(Copy(sAliqISS,1,5)) = StrToFloat(Copy(aliquota,2,length(aliquota))) then
                    sAliquota := Copy(sIndiceISS,1,2)
                Else
                Begin
                    sAliqISS := Copy(sAliqISS,7,Length(sAliqISS));
                    If Pos(',',sIndiceISS) > 0 then
                        sIndiceISS := Copy(sIndiceISS, Pos(',',sIndiceISS)+1, Length(sIndiceISS))
                    Else
                        sIndiceISS := '';
                End;
            End;
            If sAliquota = '' then
            Begin
                MessageDlg('Alíquota não programada',mtError,[mbOK],0);
                Result := '1';
                exit;
            End
        End;
  End;

  // Codigo só pode ser até 13 posicoes.
  Codigo := Copy(codigo+Space(13),1,13);

  Descricao := Trim(Descricao);
  If Length(Descricao) < 29 then
          Descricao := Copy(Descricao+Space(29),1,29)
  Else If Length(Descricao) > 29 then
  Begin
          fFuncDaruma_FI_AumentaDescricaoItem(Descricao);
          // Coloca o tamanho da descrição para 29 posições 
          Descricao:=Copy(Descricao, 1, 29);
  End;

  // Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
  sTipoQtd := 'F';

  // Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionária
  Qtde := FormataTexto( qtde, 7, 3, 2 );

  // Numero de cadas decimais para o preço unitário
  If Pos('.',vlrUnit) > 0 then
    If StrtoFloat(copy(vlrUnit,Pos('.',vlrUnit)+1,Length(vlrUnit))) > 99 then
      iCasas := 3
    Else
      iCasas := 2;

  // Valor unitário deve ter até 8 digitos
  vlrUnit := FormataTexto( vlrUnit, 8, iCasas, 2 );

  // Valor desconto deve ter até 8 digitos
  vlrDesconto := FormataTexto( vlrDesconto, 8, 2, 2 );

  // Retistra o Item
  iRet := fFuncDaruma_FI_VendeItem( pChar( Codigo ),pChar( descricao ),pChar( sAliquota ),pChar( sTipoQtd ),pChar( Qtde ), iCasas ,pChar( vlrUnit ),'$',pChar( vlrDesconto ));
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
  iRet : Integer;
begin
  //*****************************************************************************************
  //TrataTags e RemoveTags-> As Tags não precisarão ser implementadas pois elas são baseadas nas flags da Daruma
  //o texto que o Protheus enviara contera a tag que irá direto para o comando da impressora
  //sem tratamento, como nas outras impressoras.
  //*****************************************************************************************
    iRet := fFuncDaruma_FI_TerminaFechamentoCupom(Mensagem);
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
    begin
       iRet := Status_Impressora( True );
       if iRet = 1 then
            Result := '0'
        else
            Result := '1';
    end
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;
var iRet    : integer;
    sFrmPag : AnsiString;
    sVlrPag : AnsiString;
begin
    If not lDescAcres then
        iRet := fFuncDaruma_FI_IniciaFechamentoCupom('D', '$', Pchar('0.00'));

    while Length(pagamento)>0 do
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

        iRet := fFuncDaruma_FI_EfetuaFormaPagamento( sFrmPag , sVlrPag);
    end;
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
       Result := '0'
    Else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString;
var iRet: integer;
begin
    iRet := fFuncDaruma_FI_IniciaFechamentoCupom('D', '$', Pchar(vlrDesconto));
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
    begin
       lDescAcres:=True;
       Result := '0';
    End
    Else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var iRet: integer;
begin
    iRet := fFuncDaruma_FI_IniciaFechamentoCupom('A','$', Pchar(vlrAcrescimo));
    TrataRetornoDaruma( iRet );
    If iRet >= 0 then
    Begin
       lDescAcres:=True;
       Result := '0';
    End
    Else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet, i : Integer;
  sRet, Data, Hora, sDataHoje, sCNPJ, sIE, sUltimoItem : AnsiString;
  dDtHoje,dDtMov:TDateTime;
  iAck, iSt1, iSt2 : Integer;
  FlagTruncamento : AnsiString;
  sVendaBruta, sSubTotal : AnsiString;
  sGrandeTotal : AnsiString;
  sLetraIndicativa: AnsiString;
  sContadorCrz: AnsiString;
  sDataIntEprom,sHoraIntEprom,sGTFinal, sCuponsEmitidos,sOperacoes,sGRG, sCDC: AnsiString;
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
  // 20 - Verifica o CNPJ cadastrado na impressora
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
    Data:=Space(6);
    Hora:=Space(6);
    iRet := fFuncDaruma_FI_DataHoraImpressora( Data, Hora );
    TrataRetornoDaruma( iRet );
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
    Data:=Space(6);
    Hora:=Space(6);
    iRet := fFuncDaruma_FI_DataHoraImpressora( Data, Hora );
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
    begin
      Result := '0|'+Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,5,2);
    end
    Else
      Result := '1';
  end
  //  3 - Verifica o Papel
  Else If Tipo = 3 then
  begin
    iRet := fFuncDaruma_FI_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
    If iSt1 >= 128  Then
        Result := '3'    // Falta papel.
    Else If iSt1 >= 64 Then
        Result := '2'    // Pouco papel
    Else
        Result := '0';
  end
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  Else if Tipo = 4 then
    Result := '0|TODOS'
  //  5 - Cupom Fechado ?
  Else If Tipo = 5 then
  begin
    iRet := fFuncDaruma_FI_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
    if iSt1 >= 128 then iSt1 := iSt1 -128;
    if iSt1 >= 64  then iSt1 := iSt1 -64;
    if iSt1 >= 32  then iSt1 := iSt1 -32;
    if iSt1 >= 16  then iSt1 := iSt1 -16;
    if iSt1 >= 8   then iSt1 := iSt1 -8;
    if iSt1 >= 4   then iSt1 := iSt1 -4;
    if iSt1 >= 2 then
        Result := '7'    // aberto
    Else
        Result := '0';  // Fechado
  end
  //  6 - Ret. suprimento da impressora
  Else If Tipo = 6 then
  begin
      sRet := Space(3016);
      iRet := fFuncDaruma_FI_VerificaFormasPagamentoEx( sRet );
      TrataRetornoDaruma( iRet );
      If iRet = 1 then
      begin
        i:=1;
        Repeat
            If UpperCase(Trim(Copy(sRet,1,16)))='DINHEIRO' then
                Result:='0|' + Trim(FormataTexto(Copy(sRet,17,18)+','+Copy(sRet,35,2),12,2,3));
            sRet:=Copy(sRet,58, Length(sRet));
            Inc(i);
        Until (UpperCase(Trim(Copy(sRet,1,16)))<>'DINHEIRO') and (i<=50);
      end
      else
      begin
            Result:= '1';
      end;
  end
  //  7 - ECF permite desconto por item
  Else If Tipo = 7 then
    Result := '11'
  //  8 - Verifica se o dia anterior foi fechado
  Else If Tipo = 8 then
  begin
    Data     := Space(6);
    sDataHoje:= Space(6);
    iRet:=fFuncDaruma_FI_DataMovimento(Data);
    If Data='000000' then
        Result:= '0'
    else
    begin
        sDataHoje:= Copy(StatusImp(2),3,8);
        dDtHoje  := StrToDate(sDataHoje);
        Data := Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,5,2);
        dDtMov   := StrToDate(Data);
        If (dDtMov < dDtHoje) then    // reducao pendente
           Result := '10'
        Else
           Result := '0';
    end;
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
    FlagTruncamento := Space(1);
    // Para o FlagTruncamento, retorna 1 se a impressora estiver no modo truncamento e 0 se estiver no modo arredondamento.
    iRet := fFuncDaruma_FI_VerificaTruncamento( FlagTruncamento );
    If iRet = 1 then
      Result := Copy( FlagTruncamento, 1, 1 )
    Else
      Result := '1';
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
    iRet := fFuncDaruma_FI_VendaBruta( sVendaBruta );
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
      Result := '0|' + sVendaBruta
    else
      Result := '1'
    End
  // 18 - Verifica Grande Total
  else if Tipo = 18 then
  begin
    sGrandeTotal := Space(18);
    iRet := fFuncDaruma_FI_GrandeTotal( sGrandeTotal );
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
      Result := '0|' + sGrandeTotal
    Else
      Result := '1'
    End
  // 19 - Retorna da data do movimento
  Else If Tipo = 19 then
  begin
    Data     := Space(6);
    sDataHoje:= Space(6);
    iRet:=fFuncDaruma_FI_DataMovimento(Data);
    If ( Data='000000' ) Or ( Data='010100' )then
        Result:= '0|' + Data
    else
    begin
        sDataHoje:= Copy(StatusImp(2),3,8);
        dDtHoje  := StrToDate(sDataHoje);
        Data := Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,5,2);
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
      iRet := fFuncDaruma_FI_RetornaCRZ(sContadorCrz);
      TrataRetornoDaruma( iRet );
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
    //Função não disponível para este equipamento
    Result := '0|'

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
    //Função não disponível para este equipamento
    Result := '0|'

  // 30 - Retorna o Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  else if Tipo = 30 then
    //Função não disponível para este equipamento
    Result := '0|'

  // 31 - Retorna o Nº de ordem seqüencial do ECF no estabelecimento usuário
  else if Tipo = 31 then
    Result := '0|' + Pdv

  // 32 - Retorna o Grande Total Inicial
  else if Tipo = 32 then
  begin
    If ReducaoEmitida then
    begin
      // Calcula o Grande Total Inicial, (GTFinal - VendaBrutaDia)
      try
        sGTFinal := Space(18);
        iRet := fFuncDaruma_FI_GrandeTotal(sGTFinal);
        TrataRetornoDaruma( iRet );

        If Not(iRet = 1) then Abort;//foi tratado com Try para evitar que apenas o último comando retorne 1

        sVendaBruta := Space(18);
        iRet := fFuncDaruma_FI_VendaBruta(sVendaBruta);
        TrataRetornoDaruma( iRet );
      except
      end;

      If iRet = 1 then
      begin
        GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );
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
      sGTFinal := Space(18);
      iRet := fFuncDaruma_FI_GrandeTotal(sGTFinal);
      TrataRetornoDaruma( iRet );
      If iRet = 1 then
      begin
        GTInicial := sGTFinal;
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
      sVendaBruta := Space(18);
      iRet := fFuncDaruma_FI_VendaBruta( sVendaBruta );
      TrataRetornoDaruma( iRet );
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
    //Função não disponível para este equipamento
    Result := '0|'

  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  else if Tipo = 36 then
  begin
    sOperacoes := Space(6);
    iRet := fFuncDaruma_FI_NumeroOperacoesNaoFiscais(sOperacoes);
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
      Result := '0|' + sOperacoes
    Else
      Result := '1';
  end

  // 37 - Retorna o Contador Geral de Relatório Gerencial
  else if Tipo = 37 then
    //Função não disponível para este equipamento
    Result := '0|'

  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  else if Tipo = 38 then
    //Função não disponível para este equipamento
    Result := '0|'

  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  else if Tipo = 39 then
    //Função não disponível para este equipamento
    Result := '0|'

  // 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CÓDIGOS DE IDENTIFICAÇÃO DE ECF
  else if Tipo = 40 then
    Result := '0|' + CodigoEcf

  // 41 - Retorna o sequencial do último item vendido
  else if Tipo = 41 then
  Begin
    sUltimoItem := Space(4);
    iRet := fFuncDaruma_FI_UltimoItemVendido( sUltimoItem );
    If iRet = 1 then
      Result := '0|' + sUltimoItem
    Else
      Result := '1';
  End

  // 42 - Retorna o subtotal do cupom
  else if Tipo = 42 then
  Begin
    sSubTotal := Space(14);
    iRet := fFuncDaruma_FI_SubTotal( sSubTotal );
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

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString;
var
  iRet : Integer;
  sDatai : AnsiString;
  sDataf : AnsiString;
  sTipoAux: AnsiString;
begin

  //Parametro "Tipo" recebe AnsiString com duas posições, sendo a segunda posição: "S" para leitura simplificada e "C" para leitura completa
  //*** Opção disponível somente para modelos MFD FS600 e FS2100T
  sTipoAux := UpperCase(Copy(Tipo,1,1)) ;

  if sTipoAux = 'I' then
  begin
      // Se o relatório for por Data
      If Trim(ReducInicio) + Trim(ReducFim) = '' then
      begin
        sDatai := FormataData( DataInicio, 4 );
        sDataf := FormataData( DataFim, 4 );
        iRet := fFuncDaruma_FI_LeituraMemoriaFiscalData(sDatai,sDataf);
        TrataRetornoDaruma( iRet );
        If iRet >= 0 then
          Result := '0'
        Else
          Result := '1';
      end
      Else       // Se o relatório será por redução Z
      Begin
        iRet :=fFuncDaruma_FI_LeituraMemoriaFiscalReducao(Pchar(ReducInicio),Pchar(ReducFim));
        TrataRetornoDaruma( iRet );
        If iRet >= 0 then
          Result := '0'
        Else
          Result := '1';
      end;
  end
  Else
  Begin
      // Se o relatório for por Data
      If Trim(ReducInicio) + Trim(ReducFim) = '' then
      begin
        sDatai := FormataData( DataInicio, 1 );
        sDataf := FormataData( DataFim, 1 );
        iRet := fFuncDaruma_FI_LeituraMemoriaFiscalSerialData(sDatai,sDataf);
        TrataRetornoDaruma( iRet );
        If iRet = 1 then
          Result := '0'
        Else
          Result := '1';
      end
      Else       // Se o relatório será por redução Z
      Begin
        iRet :=fFuncDaruma_FI_LeituraMemoriaFiscalSerialReducao(ReducInicio,ReducFim);
        TrataRetornoDaruma( iRet );
        If iRet = 1 then
          Result := '0'
        Else
          Result := '1';
      end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
// Tipo = 1 - ICMS
// Tipo = 2 - ISS
var
  iRet : Integer;
begin
    If Tipo=1 then Tipo := 0;
    If Tipo=2 then Tipo := 1;
    Aliquota := FormataTexto(Aliquota,5,2,1);
    Aliquota := StrTran(Aliquota,'.','');
    iRet := fFuncDaruma_FI_ProgramaAliquota( PChar(Aliquota) , Tipo );
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
    begin
       iRet := Status_Impressora( True );
       If iRet = 1 then
           Result := '0'
       Else
       begin
           Status_Impressora( True, 2 );
           Result := '1';
       end;
    end
    Else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
  sRet : AnsiString;
  sCOORecebimento : AnsiString;
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
  sRet := PegaCupom( ' ' );
  If Copy( sRet, 1, 1 ) = '0' then
  begin
    sCOORecebimento := Copy( sRet, 3, Length(sRet) );
  end;
  //*******************************************************************************
  // Abre o comprovante não fiscal. Tenta abrir um vinculado mas caso não consiga
  // faz um recebimento não fiscal para depois abrir o comprovante não fiscal
  // Condicao = Descricao da Forma de pagamento - Nao pode ser DINHEIRO
  //*******************************************************************************
  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Daruma_FI_AbreComprovanteNaoFiscalVinculado: '+Condicao+', '+Valor+', '+sCOORecebimento+' =>TENTATIVA 1' ));
  iRet := fFuncDaruma_FI_AbreComprovanteNaoFiscalVinculado( Condicao, Valor, sCOORecebimento );
  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Daruma_FI_AbreComprovanteNaoFiscalVinculado: '+IntToStr(iRet) ));
  If Status_Impressora( False) = 1 then
    Result := '0'
  Else
  begin
         //*******************************************************************************
         // Faz um recebimento não fiscal para abrir o cupom vinculado
         //*******************************************************************************
         WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Daruma_FI_RecebimentoNaoFiscal: '+Totalizador+', '+Valor+', '+Condicao ));
         iRet := fFuncDaruma_FI_RecebimentoNaoFiscal( pchar(Totalizador), pchar(Valor), pchar(Condicao) );
         WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Daruma_FI_RecebimentoNaoFiscal: '+IntToStr(iRet) ));
         If iRet = 1 then
         begin
           //*******************************************************************************
           // Pega o COO do cupom de recebimento para abrir um cupom vinculado
           //*******************************************************************************
           sRet := PegaCupom( ' ' );
           If Copy( sRet, 1, 1 ) = '0' then
           begin
             sCOORecebimento := Copy( sRet, 3, Length(sRet) );
           end;
            //*******************************************************************************
            // Abre o comprovante vinculado
            //*******************************************************************************
            iRet := fFuncDaruma_FI_AbreComprovanteNaoFiscalVinculado( Condicao, Valor, sCOORecebimento );
            WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Daruma_FI_AbreComprovanteNaoFiscalVinculado: '+Condicao+', '+Valor+', '+sCOORecebimento+' =>TENTATIVA 2' ));
            WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Daruma_FI_AbreComprovanteNaoFiscalVinculado: '+IntToStr(iRet) ));
            If iRet = 1 then
            Begin
              Result := '0';
            End
            Else
            Begin
              Status_Impressora( False, 0 );
              Result := '1';
            End;
         End
         Else
         Begin
            Status_Impressora( False, 0 );
            Result := '1';
         End;
  End;

  //*******************************************************************************
  // Se apresentou algum erro monstra a mensagem
  //*******************************************************************************
  If Result = '1' then
    TrataRetornoDaruma( iRet, 0 );

end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.TextoNaoFiscal( Texto:AnsiString; Vias:Integer ):AnsiString;
var
  i: Integer;
  sTexto  : AnsiString;
  iRet    : Integer;
  sLinha  :AnsiString;
Begin
  Result := '0';
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

  // Laço para imprimir toda a mensagem
  While ( Trim(Texto)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 40 caracter do Texto
         If Pos(#10,Copy(Texto,1,41))>1 then
         begin
            sLinha := Copy(Texto,1, Pos(#10,Texto)-1);
            Texto  := Copy(Texto,Pos(#10,Texto)+1, Length(Texto));
         End
         Else If Pos(#10,Copy(Texto,1,41))=1 then
         Begin
            sLinha := #13;
            Texto := Copy(Texto,2,Length(Texto));
         End
         Else
         Begin
            sLinha := Copy(Texto,1, 40);
            Texto  := Copy(Texto,41, Length(Texto));
         End;
         iRet   := fFuncDaruma_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
         // Ocorreu erro na impressão do cupom
         if iRet<>1 then
         Begin
            Result := '1';
            Break;
         End;
      End;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.FechaCupomNaoFiscal: AnsiString;
var
  iRet : Integer;
begin
  fFuncDaruma_FI_FechaComprovanteNaoFiscalVinculado;
  iRet := Status_Impressora( True );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString;
begin
  MsgStop( MsgIndsImp );
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncDaruma_FI_Autenticacao();
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
      Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.RelatorioGerencial( Texto:AnsiString ;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
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
  SetLength ( sInformacao, 2 );
  fFuncDaruma_FI_StatusComprovanteNaoFiscalVinculado( PChar(sInformacao) );
  If Status_Impressora( False ) = 1 then
  begin
    //****************************************************************************
    // Se houver cupom em aberto, faz o cancelamento
    //****************************************************************************
    If sInformacao[1] = '1' then
    begin
      fFuncDaruma_FI_FechaComprovanteNaoFiscalVinculado;
      If Status_Impressora( False ) = 1 then Result := '0' else Result := '1';
    end;
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

  //****************************************************************************
  // Envia o comando de impressao do relatorio gerencial
  //****************************************************************************
  If Length( Trim( Texto ) ) > 0 then
  begin
    While Length( Trim( Texto ) ) <> 0 do
    Begin
      iRet := fFuncDaruma_FI_RelatorioGerencial( Copy( Texto, 1, 400 ) );
      Texto := Copy( Texto, 401, Length( Texto ) );
    End;
    If Status_Impressora( False ) = 1 then Result := '0' else Result := '1';
  end
  else
    Result := '0';

  //****************************************************************************
  // Fecha o relatorio gerencial
  //****************************************************************************
   GravaLog(' FechaRelatorioGerencial ->');
   fFuncDaruma_FI_FechaRelatorioGerencial;
   GravaLog(' FechaRelatorioGerencial <- ');

  If Status_Impressora( False ) = 1
  then Result := '0'
  else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma120.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
var iRet : Integer;
begin

  iRet := fFuncDaruma_FI_RecebimentoNaoFiscal( pchar(Totalizador), pchar(Valor), pchar(Forma) );
  TrataRetornoDaruma(iRet);
  if iRet = 1 then
    Result := '0'
  else
    Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma120.HorarioVerao( Tipo:AnsiString ):AnsiString;
var iRet : Integer;
begin
  Result := '0';
  If Trim( Tipo ) = '+' then
  begin
          //*******************************************************************
          // Coloca a impressora no horário de verao
          //*******************************************************************
          iRet := fFuncDaruma_FI_CfgHorarioVerao('1');
          TrataRetornoDaruma( iRet );
          If iRet <> 1 then
            Result := '1';
  end
  else
  begin
          //*******************************************************************
          // Tira a impressora no horário de verao
          //*******************************************************************
          iRet := fFuncDaruma_FI_CfgHorarioVerao('0');
          TrataRetornoDaruma( iRet );
          If iRet <> 1 then
            Result := '1';
  end;
end;
//----------------------------------------------------------------------------
Procedure TImpFiscalDaruma120.AlimentaProperties;
var
  iRet : Integer;
  sRet, sAliq : AnsiString;
  Reg: TRegistry;
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
  sRet := Space( 300 );
  iRet := fFuncDaruma_FI_LerAliquotasComIndice(sRet);
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
  Begin
      While Length(sRet)>0 do
      begin
        sAliq := Copy(sRet,3,2)+','+Copy(sRet,5,2);
        If Copy(sRet,1,1) = 'T' then
            ICMS  := ICMS + FormataTexto(sAliq,5,2,1) +'|'
        Else if Copy(sRet,1,1) = 'S' then
            ISS   := ISS + FormataTexto(sAliq,5,2,1) +'|';
        sRet  := Copy(sRet,7,Length(sRet));
      end;
    End;

  // Retorno do Numero do Caixa (PDV)
  sRet := Space ( 4 );
  iRet := fFuncDaruma_FI_NumeroCaixa( sRet );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    If Pos(#0,sRet) > 0 then
      PDV := Copy(sRet,1,Pos(#0,sRet)-1)
    Else
      PDV := Copy(sRet,1,4);

  // Retorno da Versão do Firmware (Eprom)
  sRet := Space( 4 );
  iRet := fFuncDaruma_FI_VersaoFirmware( sRet );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Eprom := Copy(sRet,1,Pos(#0,sRet)-1);

  // Retorna o CNPJ
  // Retorna a IE
  iRet := fFuncDaruma_FI_CGC_IE( Cnpj, Ie );
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Numero da loja cadastrado no ECF
  iRet := fFuncDaruma_FI_NumeroLoja( NumLoja );
  NumLoja := Trim( NumLoja );
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Numero da Serie
  iRet := fFuncDaruma_FI_NumeroSerie( NumSerie );
  NumSerie := Trim( NumSerie );
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Tipo do ECF
  TipoEcf := 'ECF-IF';

  // Retorna Marca do ECF
  MarcaEcf := sMarca;

  // Retorna Modelo do ECF
  iRet := fFuncDaruma_FI_VerificaModeloECF;
  case iRet of
   1 : ModeloEcf := 'FS345' ;
   2 : ModeloEcf := 'FS318' ;
   3 : ModeloEcf := 'FS2000' ;
   4 : ModeloEcf := 'FS600' ;
  end;

  // Retorna Contador de Reinicio de Operação
  IRet := fFuncDaruma_FI_RetornaCRO(ContadorCro);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna Contador de ReduçãoZ
  IRet := fFuncDaruma_FI_RetornaCRZ(ContadorCrz);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o valor Total Bruto Vendido até o momento do referido movimento
  IRet := fFuncDaruma_FI_VendaBruta(VendaBrutaDia);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o valor do Grande Total da impressora
  IRet := fFuncDaruma_FI_GrandeTotal(GTFinal);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Calcula o Grande Total Inicial
  GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );


  //Path arquivos ECF
  try
    Reg := TRegistry.Create;
    Reg.RootKey:=HKEY_LOCAL_MACHINE;
    Reg.OpenKey('\Software\DARUMA\ECF',False);
    sPathEcfRegistry := Reg.ReadString('Path');
    {Força último caracter barra '\'}
    If Copy(sPathEcfRegistry,Length(sPathEcfRegistry),1) <> '\' then
       sPathEcfRegistry := sPathEcfRegistry + '\' ;

    {Verifica se caminho existe, se não existir cria}
    if (not DirectoryExists(sPathEcfRegistry)) and (Not ForceDirectories(sPathEcfRegistry)) then
       MessageDlg( 'Caminho para retorno do ECF não encontrado:'+sPathEcfRegistry, mtError,[mbOK],0);

    {Configura Path para gerar registro tipo E}
    if Reg.OpenKey('\Software\DARUMA\AtoCotepe',False) then
       Reg.WriteString('Path',PathArquivo+DEFAULT_PATHARQMFD);
  finally
    Reg.Free ;
  end;
  
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.Suprimento( Tipo:Integer; Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
var
  iRet : Integer;
  sRet : AnsiString;
  nSuprimento : Real;
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
         iRet:= fFuncDaruma_FI_Suprimento(Valor,Forma);
         TrataRetornoDaruma( iRet );
             If iRet = 1 then
                 Result := '0'
             Else
                 Result := '1';
        end;
    3: begin
         iRet:= fFuncDaruma_FI_Sangria(Valor);
         TrataRetornoDaruma( iRet );
             If iRet = 1 then
                 Result := '0'
             Else
                 Result := '1';
       end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.GravaCondPag( Condicao:AnsiString ):AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncDaruma_FI_ProgramaFormasPagamento(PChar(Condicao));
  TrataRetornoDaruma(iRet);
  If iRet = 1 then
  begin
       iRet := Status_Impressora( True );
       If iRet = 1 then
       begin
           iRet := Status_Impressora( True, 2 );
           If iRet <> 1 then
               Result := '1'
           else
               Result := '0';
       end
       Else
       begin
           iRet := Status_Impressora( True, 2 );
           If iRet <> 1 then
               Result := '1'
           else
               Result := '0';
       end;
  end
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncDaruma_FI_NomeiaTotalizadorNaoSujeitoIcms(StrToInt(Numero),Descricao);
  TrataRetornoDaruma(iRet);
  If iRet = 1 then
  begin
       iRet := Status_Impressora( True );
       If iRet = 1 then
           Result := '0'
        Else
           Result := '1';
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.Gaveta:AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncDaruma_FI_AcionaGaveta;
  TrataRetornoDaruma( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.PegaSerie:AnsiString;
begin
  Result := '0|' + NumSerie;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
Var
  iRet            : Integer;
  sPedido         : AnsiString;
  sTefPedido      : AnsiString;
  sCondicao       : AnsiString;
  sPath           : AnsiString;
  pPath           : pChar;
  sTotalizadores  : AnsiString;
  fArquivo        : TIniFile;
  aAuxiliar       : TaString;
  lPedido         : Boolean;
  lTefPedido      : Boolean;
  sTotPedido      : AnsiString;     // Contem o totalizador do registrador PEDIDO
  sTotTefPedido   : AnsiString;     // Contem o totalizador do registrador TEFPEDIDO
  iX              : Integer;
  sMsg            : AnsiString;
  sLinha          : AnsiString;
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
  pPath       := Pchar(Replicate('0',100));
  sArquivo    := 'DARUMA.INI';
  sPath       := '';

  //*******************************************************************************
  // Pega os nomes dos totalizadores no arquivo de configuração (BEMAFI32.INI)
  //*******************************************************************************
  //GetSystemDirectory(pPath, 100);
  //sPath := StrPas( pPath );

  sPath       := ExtractFilePath(Application.ExeName);
  fArquivo    := TIniFile.Create(sPath + sArquivo);


  fArquivo    := TIniFile.Create(sPath + sArquivo);
  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  //*******************************************************************************
  // Checa indice do totalizador pelo nome informado
  //*******************************************************************************
  sTotalizadores  := Space(2200);
  iRet            := fFuncDaruma_FI_VerificaRecebimentoNaoFiscal( sTotalizadores );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
  begin
    If (Pos( sPedido, sTotalizadores ) > 0) And (Pos( sTefPedido, sTotalizadores ) > 0) then
    begin
      sTotalizadores := StrTran( sTotalizadores, ',', '|' );
      MontaArray( sTotalizadores,aAuxiliar );

      iX := 0;
      While (iX < Length(aAuxiliar)) do
      begin
        If UpperCase(Trim(Copy( aAuxiliar[iX], 25, 19 ))) = UpperCase( sPedido ) then
        begin
          lPedido := True;
          sTotPedido := FormataTexto( IntToStr(iX+1), 2, 0, 2 );
        end;
        If UpperCase(Trim(Copy( aAuxiliar[iX], 25, 19 ))) = UpperCase( sTefPedido ) then
        begin
          lTefPedido := True;
          sTotTefPedido := FormataTexto( IntToStr(iX+1), 2, 0, 2 );
        end;
        If lPedido And lTefPedido then break;
        Inc( iX );
      end;
    end;
  end;

  //*******************************************************************************
  // Faz o tratamento dos parâmetros
  //*******************************************************************************
  Valor       := Trim(FormataTexto( Valor, 14, 2, 3 ));
  Valor       := StrTran( Valor, '.', ',' );
  sCondicao   := Copy( sCondicao, 1, 16 );

  //*******************************************************************************
  // Faz o recebimento não fiscal / Comprovante não fiscal não vinculado
  //*******************************************************************************
  If lPedido And lTefPedido then
  begin
    //*******************************************************************************
    // Abre o comprovante não fiscal não vinculado
    //*******************************************************************************
    iRet := fFuncDaruma_FI_RecebimentoNaoFiscal( sPedido, Valor, sCondicao );
    If Status_Impressora( False ) = 1 then
    begin

      //*******************************************************************************
      // Abre o comprovante não fiscal vinculado
      //*******************************************************************************
      iRet := fFuncDaruma_FI_AbreComprovanteNaoFiscalVinculado( sCondicao, '', '' );
      If Status_Impressora( False ) = 1 then
      begin
          While Length( Texto ) > 0 do
          begin
            sLinha := Copy( Texto, 1, 618 );
            iRet := fFuncDaruma_FI_UsaComprovanteNaoFiscalVinculado( sLinha );
            Texto := Copy( Texto, 619, Length(Texto)-618 );
          end;

          If Status_Impressora( False ) = 1 then
          begin
            iRet := fFuncDaruma_FI_FechaComprovanteNaoFiscalVinculado;
            If Status_Impressora( False ) = 1 then
            begin
              //*******************************************************************************
              // Checar se serah impresso o comprovante TEF. Caso afirmativo abre um novo
              // comprovante nao fiscal nao vinculado.
              //*******************************************************************************
              If Tef = 'S' then
              begin
                iRet := fFuncDaruma_FI_RecebimentoNaoFiscal ( sTotTefPedido, Valor, sCondicao );
                If Status_Impressora( False ) = 1 then
                  Result := '0';
              end
              Else
                Result := '0';
            end;
          end;
      end;
    end;
    //*******************************************************************************
    // Mostrar mensagem de erro se necessário
    //*******************************************************************************
    If Result = '1' then
      TrataRetornoDaruma( iRet );

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

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.LeTotNFisc:AnsiString;
var
  iRet, i, iPosF : Integer;
  sRet : AnsiString;
  sTotaliz : AnsiString;
begin
  sRet := Space( 300 );
  iRet := fFuncDaruma_FI_VerificaTotalizadoresNaoFiscaisEx( sRet );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
  begin
    sTotaliz := '';
    iPosF := Pos(',', sRet);
    If iPosF = 0 then iPosF := Length(sRet);
    For i:=1 to 16 do
      begin
        If Trim(Copy(sRet,1,iPosF-1))<>'' then
         begin
            sTotaliz := sTotaliz + FormataTexto( IntToStr(i), 2, 0, 4) + ',' + Trim(copy( sRet, 1, iPosF - 1 )) + '|';
         end;
         sRet:= Copy(sRet,iPosF+1,Length(sRet));
         iPosF := Pos(',', sRet);
         If iPosF = 0 then iPosF := Length(sRet);
      end;
    Result := '0|' + sTotaliz;
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString): AnsiString;
var
  iRet : Integer;
begin
 if LogDLL
 then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Daruma_FI_IdentificaConsumidor '));

 iRet := fFuncDaruma_FI_IdentificaConsumidor(pchar(cCliente), pchar(cEndereco), pchar(cCPFCNPJ));

 if LogDLL
 then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Daruma_FI_IdentificaConsumidor: ' + IntToStr(iRet)));

 TrataRetornoDaruma( iRet );

 If iRet = 1
 then Result := '0|'
 else Result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma120.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
var
  iRet : Integer;
begin

If fHandle2 <> 0 then//Handle da darumaframework
begin
   //existem duas funções na DarumaFrameWork para Estorno do CDC, neste caso
   //uso a que cancela o ultimo comprovante impresso, se utilizar a função iCCDEstornar_ECF_Daruma
   //e os parâmetros acima pode-se cancelar qualquer comprovante
   If LogDLL
   then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now) + '-> iCCDEstornarPadrao_ECF_Daruma '));

   iRet := fFunciCCDEstornarPadrao_ECF_Daruma();

   If LogDLL
   then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now) + '<- iCCDEstornarPadrao_ECF_Daruma : ' + IntToStr(iRet)));

   TrataRetornoDaruma( iRet );

   if iRet = 1
   then Result := '0|'
   else Result := '1|';

end
else
begin
  //Segundo o suporte da Daruma, para a Daruma32.dll não é necessário estornar o
  //comprovante de Credito e Debito pois isto é feito automaticamente pela DLL 
  If LogDLL
  then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Estorno comprovante de CCD '));

  Result := '0|';
end;

end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma345.Suprimento( Tipo:Integer; Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
var
  iRet : Integer;
  sRet : AnsiString;
  nSuprimento : Real;
  sPath : AnsiString;
  sAdv  : AnsiString;
  fArquivo : TIniFile;
begin
  // Tipo = 1 - Verifica se tem troco disponivel
  // Tipo = 2 - Grava o valor informado no Suprimentos
  // Tipo = 3 - Sangra o valor informado

  Result := '1';

  if Forma = '' then
  begin
    sPath := ExtractFilePath(Application.ExeName);
    fArquivo := TIniFile.Create(sPath+'\SIGALOJA.INI');
    If fArquivo.ReadString('DARUMA', 'SUPRIMENTO', '' ) = '' then
        Result := '2';
    Forma := fArquivo.ReadString('DARUMA', 'SUPRIMENTO', '' );
  end;

  if Result <> '2' then
  begin
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
            iRet:= fFuncDaruma_FI_Suprimento(Valor,Forma);
            TrataRetornoDaruma( iRet );
            If iRet = 1 then
                Result := '0'
            else
                Result := '1';
            end;
        3: begin
            iRet:= fFuncDaruma_FI_Sangria(Valor);
            TrataRetornoDaruma( iRet );
            If iRet = 1 then
                Result := '0'
            else
                Result := '1';
            end;
      end;
    end
    else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma2000.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  iRet : Integer;
  sTrib : AnsiString;
  sAliquota : AnsiString;
  sIndiceISS, sAliqISS : AnsiString;
  sTipoQtd : AnsiString;
  iCasas: Integer;
begin
  iCasas:=2;
  // Essa impressora não aceita códigos inferiores a 6 caracteres
  While Length(Trim(Codigo)) < 6 do
    Codigo := '0' + Trim(Codigo);

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    result := '11';
    exit;
  end;

  // Verifica o ponto decimal dos parâmetros
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');
  qtde := StrTran(qtde,',','.');

  // Verifica se existe a aliquota cadastrada na impressora.
  sTrib := Copy(aliquota,1,1);
  sAliquota := Copy(aliquota,2,5);
  sAliquota := StrTran( StrTran( sAliquota, ',', '' ), '.', '' );

  If sTrib = 'F' then
       sAliquota := 'FF';
  If sTrib = 'I' then
       sAliquota := 'II';
  If sTrib = 'N' then
       sAliquota := 'NN';
  If sTrib = 'T' then
       sAliquota := FormataTexto(sAliquota,4,0,2);
  If sTrib = 'S' then
  Begin
        sAliquota := '';
        sAliqISS := LeAliquotasISS();
        sAliqISS := Copy(sAliqISS, 3, Length(sAliqISS));
        sIndiceISS := Space(48);
        iRet := fFuncDaruma_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoDaruma(iRet);
        If iRet = 1 then
        Begin
            While (sAliquota = '') and (Length(sIndiceISS)>0) do
            Begin
                If StrToFloat(Copy(sAliqISS,1,5)) = StrToFloat(Copy(aliquota,2,length(aliquota))) then
                    sAliquota := Copy(sIndiceISS,1,2)
                Else
                Begin
                    sAliqISS := Copy(sAliqISS,7,Length(sAliqISS));
                    If Pos(',',sIndiceISS) > 0 then
                        sIndiceISS := Copy(sIndiceISS, Pos(',',sIndiceISS)+1, Length(sIndiceISS))
                    Else
                        sIndiceISS := '';
                End;
            End;
            If sAliquota = '' then
            Begin
                MessageDlg('Alíquota não programada',mtError,[mbOK],0);
                Result := '1';
                exit;
            End
        End;
  End;

  // Codigo só pode ser até 14 posicoes.
  Codigo := Copy(codigo+Space(14),1,14);

  Descricao := Trim(Descricao);
  If Length(Descricao) < 29 then
          Descricao := Copy(Descricao+Space(29),1,29)
  Else If Length(Descricao) > 29 then
  Begin
          fFuncDaruma_FI_AumentaDescricaoItem(Descricao);
          // Coloca o tamanho da descrição para 29 posições
          Descricao:=Copy(Descricao, 1, 29);
  End;

  // Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
  sTipoQtd := 'F';

  // Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionária
  Qtde := FormataTexto( qtde, 7, 3, 2 );

  // Numero de cadas decimais para o preço unitário
  If Pos('.',vlrUnit) > 0 then
    If StrtoFloat(copy(vlrUnit,Pos('.',vlrUnit)+1,Length(vlrUnit))) > 99 then
      iCasas := 3
    Else
      iCasas := 2;

  // Valor unitário deve ter até 8 digitos
  vlrUnit := FormataTexto( vlrUnit, 8, iCasas, 2 );

  // Valor desconto deve ter até 8 digitos
  vlrDesconto := FormataTexto( vlrDesconto, 8, 2, 2 );

  // Registra o Item
  iRet := fFuncDaruma_FI_VendeItem( pChar( Codigo ),pChar( descricao ),pChar( sAliquota ),pChar( sTipoQtd ),pChar( Qtde ), iCasas ,pChar( vlrUnit ),'$',pChar( vlrDesconto ));
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma2000.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet, i : Integer;
  sRet, Data, Hora, sDataHoje,sCNPJ,sIE, sUltimoItem : AnsiString;
  dDtHoje,dDtMov:TDateTime;
  iAck, iSt1, iSt2 : Integer;
  FlagTruncamento : AnsiString;
  sVendaBruta, sSubTotal : AnsiString;
  sGrandeTotal : AnsiString;
  sContadorCrz: AnsiString;
  sLetraIndicativa: AnsiString;
  sDataIntEprom,sHoraIntEprom,sDataUltDoc,sGTFinal, sCuponsEmitidos,sOperacoes,sGRG, sCDC: AnsiString;
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
    Data:=Space(6);
    Hora:=Space(6);
    iRet := fFuncDaruma_FI_DataHoraImpressora( Data, Hora );
    TrataRetornoDaruma( iRet );
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
    Data:=Space(6);
    Hora:=Space(6);
    iRet := fFuncDaruma_FI_DataHoraImpressora( Data, Hora );
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
    begin
      Result := '0|'+Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,5,2);
    end
    Else
      Result := '1';
  end
  //  3 - Verifica o Papel
  Else If Tipo = 3 then
  begin
    iRet := fFuncDaruma_FI_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
    If iSt1 >= 128  Then
        Result := '3'    // Falta papel.
    Else If iSt1 >= 64 Then
        Result := '2'    // Pouco papel
    Else
        Result := '0';
  end
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  Else if Tipo = 4 then
    Result := '0|TODOS'
  //  5 - Cupom Fechado ?
  Else If Tipo = 5 then
  begin
    sRet := Space(2);
    iRet := fFuncDaruma_FI_StatusCupomFiscal (sRet);
    if copy(sRet,1,1) = '1' then
        Result := '7'    // aberto
    Else
        Result := '0';  // Fechado
  end
  //  6 - Ret. suprimento da impressora
  Else If Tipo = 6 then
  begin
      sRet := Space(3016);
      iRet := fFuncDaruma_FI_VerificaFormasPagamentoEx( sRet );
      TrataRetornoDaruma( iRet );
      If iRet = 1 then
      begin
        i:=1;
        Repeat
            If UpperCase(Trim(Copy(sRet,1,16)))='DINHEIRO' then
                Result:='0|' + Trim(FormataTexto(Copy(sRet,17,18)+','+Copy(sRet,35,2),12,2,3));
            sRet:=Copy(sRet,58, Length(sRet));
            Inc(i);
        Until (UpperCase(Trim(Copy(sRet,1,16)))<>'DINHEIRO') and (i<=50);
      end
      else
      begin
            Result:= '1';
      end;
  end
  //  7 - ECF permite desconto por item
  Else If Tipo = 7 then
    Result := '11'
  //  8 - Verifica se o dia anterior foi fechado
  Else If Tipo = 8 then
  begin
    Data     := Space(6);
    sDataHoje:= Space(6);
    iRet:=fFuncDaruma_FI_DataMovimento(Data);
    If ( Data='000000' ) Or ( Data='010100' )then
        Result:= '0'
    else
    begin
        sDataHoje:= Copy(StatusImp(2),3,8);
        dDtHoje  := StrToDate(sDataHoje);
        Data := Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,5,2);
        dDtMov   := StrToDate(Data);
        If (dDtMov < dDtHoje) then    // reducao pendente
           Result := '10'
        Else
           Result := '0';
    end;
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
    FlagTruncamento := Space(1);
    // Para o FlagTruncamento, retorna 1 se a impressora estiver no modo truncamento e 0 se estiver no modo arredondamento.
    iRet := fFuncDaruma_FI_VerificaTruncamento( FlagTruncamento );
    If iRet = 1 then
      Result := Copy( FlagTruncamento, 1, 1 )
    Else
      Result := '1';
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
    SetLength( sVendaBruta, 18 );
    iRet := fFuncDaruma_FI_VendaBruta( sVendaBruta );
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
      Result := '0|' + sVendaBruta
    else
      Result := '1'
    End
  // 18 - Verifica Grande Total
  else if Tipo = 18 then
  begin
    SetLength( sGrandeTotal, 18 );
    iRet := fFuncDaruma_FI_GrandeTotal( sGrandeTotal );
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
      Result := '0|' + sGrandeTotal
    Else
      Result := '1'
    End
  // 19 - Retorna da data do movimento
  Else If Tipo = 19 then
  begin
    Data     := Space(6);
    sDataHoje:= Space(6);
    sDataHoje:= Copy(StatusImp(2),3,8);
    iRet:=fFuncDaruma_FI_DataMovimento(Data);
    If ( Data='000000' ) Or ( Data='010100' )then
        Result:= '0|' + sDataHoje
    else
    begin
        dDtHoje  := StrToDate(sDataHoje);
        Data := Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,5,2);
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
      iRet := fFuncDaruma_FI_RetornaCRZ(sContadorCrz);
      TrataRetornoDaruma( iRet );
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
       iRet := fFuncDaruma_FIMFD_RetornaInformacao( '78', sLetraIndicativa );
       TrataRetornoDaruma( iRet );

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
      iRet := fFuncDaruma_FIMFD_RetornaInformacao( '85', sDataIntEprom );
      TrataRetornoDaruma( iRet );

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
      iRet := fFuncDaruma_FIMFD_RetornaInformacao( '85', sHoraIntEprom );
      TrataRetornoDaruma( iRet );
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
      // Calcula o Grande Total Inicial, (GTFinal - VendaBrutaDia)
      try
        sGTFinal := Space(18);
        iRet := fFuncDaruma_FI_GrandeTotal(sGTFinal);
        TrataRetornoDaruma( iRet );

        If Not(iRet = 1) then Abort;//foi tratado com Try para evitar que apenas o último comando retorne 1

        sVendaBruta := Space(18);
        iRet := fFuncDaruma_FI_VendaBruta(sVendaBruta);
        TrataRetornoDaruma( iRet );
      except
      end;

      If iRet = 1 then
      begin
        GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );
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
      sGTFinal := Space(18);
      iRet := fFuncDaruma_FI_GrandeTotal(sGTFinal);
      TrataRetornoDaruma( iRet );
      If iRet = 1 then
      begin
        GTInicial := sGTFinal;
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
      sVendaBruta := Space(18);
      iRet := fFuncDaruma_FI_VendaBruta( sVendaBruta );
      TrataRetornoDaruma( iRet );
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
    iRet := fFuncDaruma_FIMFD_RetornaInformacao( '30', sCuponsEmitidos );
    TrataRetornoDaruma( iRet );

    If iRet = 1 then
      Result := '0|' + sCuponsEmitidos
    else
      Result := '1';
  end

  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  else if Tipo = 36 then
  begin
    sOperacoes := Space(6);
    iRet := fFuncDaruma_FI_NumeroOperacoesNaoFiscais(sOperacoes);
    TrataRetornoDaruma( iRet );
    If iRet = 1 then
      Result := '0|' + sOperacoes
    Else
      Result := '1';
  end

  // 37 - Retorna o Contador Geral de Relatório Gerencial
  else if Tipo = 37 then
  begin
    sGRG := Space(6);
    iRet := fFuncDaruma_FIMFD_RetornaInformacao( '33', sGRG);
    TrataRetornoDaruma( iRet );

    If iRet = 1 then
      Result := '0|' + sGRG
    Else
      Result := '1';
  end

  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  else if Tipo = 38 then
  begin
    sCDC := Space(4);
    iRet := fFuncDaruma_FIMFD_RetornaInformacao( '45', sCDC);      
    TrataRetornoDaruma( iRet );

    If iRet = 1 then
      Result := '0|' + sCDC
    Else
      Result := '1';
  end

  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  else if Tipo = 39 then
  begin
    sDataUltDoc := Space(14);
    iRet := fFuncDaruma_FIMFD_RetornaInformacao( '73', sDataUltDoc );
    TrataRetornoDaruma( iRet );

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
    sUltimoItem := Space(4);
    iRet := fFuncDaruma_FI_UltimoItemVendido( sUltimoItem );
    If iRet = 1 then
      Result := '0|' + sUltimoItem
    Else
      Result := '1';
  End

  // 42 - Retorna o subtotal do cupom
  else if Tipo = 42 then
  Begin
    sSubTotal := Space(14);
    iRet := fFuncDaruma_FI_SubTotal( sSubTotal );
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

//----------------------------------------------------------------------------
function TImpFiscalDaruma2000.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet : Integer;
  sCIni : AnsiString;
  lFinaliza : Boolean;
  iCont : Integer;
  sNumCupom : AnsiString;
begin
  lFinaliza := False;
  iCont     := 1;

  While (not lFinaliza) and (iCont <= 5)do
  begin
      //****************************************************************************
      //* Pega o numero do cupom
      //****************************************************************************
      SetLength( sNumCupom, 6 );
      SetLength( sCIni, 6 );
      iRet := fFuncDaruma_FI_COO( sCIni, sNumCupom );
      //****************************************************************************
      //* Tenta pegar o numero do cupom. Se der algum erro, dá uma pausa
      //* de alguns segundo e tenta pegar o numero do cupom novamente. Faz isto por 5
      //* vezes, aumentando o intervalo de tempo entre as tentativas.
      //****************************************************************************
      If iRet = 1 then
      begin
        lFinaliza := True;
      end
      else
      begin
        Sleep( 500 * iCont );
        Inc( iCont );
      end;
  end;

  //****************************************************************************
  //* Verifica o retorno da função para pegar o numero do cupom
  //****************************************************************************
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Result := '0|' + sNumCupom
  Else
    Result := '1';
end;
//-----------------------------------------------------------
function TImpCheqDaruma2000.Abrir( aPorta:AnsiString ): Boolean;
begin
  If Not bOpened Then
      Result := (Copy(OpenDaruma(aPorta),1,1) = '0')
  Else
      Result := True;
end;

//----------------------------------------------------------------------------
function TImpCheqDaruma2000.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  iRet : Integer;
  sData: AnsiString;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;
  Valor := Pchar(Trim(FormataTexto(Valor,12,2,4)));
//  iRet := fFuncDaruma_FI2000_ProgramaMoedaPlural( 'reais' );
  iRet := fFuncDaruma_FI2000_ImprimirCheque(Banco,Cidade,Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,1,4),Favorec,Valor,'H');
  TrataRetornoDaruma(iRet);
  if iRet = 1 then
      result := True
  Else
      result := False;
end;

//----------------------------------------------------------------------------
function TImpCheqDaruma2000.Fechar( aPorta:AnsiString ): Boolean;
begin
  Result := (Copy(CloseDaruma,1,1) = '0');
end;

//----------------------------------------------------------------------------
function TImpCheqDaruma2000.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
end;

//----------------------------------------------------------------------------
Function TrataRetornoDaruma( var iRet:Integer; Tipo: integer = 1  ):AnsiString;
var
  sMsg : AnsiString;
begin
  If (iRet < 1) and (iRet > -27) then
  begin
    sMsg := MsgErroDaruma( iRet );
    MsgStop( sMsg );
  end
  else if iRet = -27 then
    iRet := Status_Impressora(False, Tipo)
  else if iRet = -99 then
  begin
    sMsg := 'Parâmetro Inválido';
    MsgStop( sMsg );
  end;

  Result := '';
end;

//----------------------------------------------------------------------------
Function MsgErroDaruma( iRet:Integer ):AnsiString;
var
  sMsg : AnsiString;
begin
  sMsg := '';
  Case iRet of
     0  : sMsg := 'Erro de comunicação ou Fim de Papel';
    -1  : sMsg := 'Erro de execução da função';
    -2  : sMsg := 'Parâmetro inválido';
    -3  : sMsg := 'Alíquota não programada';
    -4  : sMsg := 'A Chave ou Valor no Registry não Foi Encontado ';
    -5  : sMsg := 'Erro ao abrir a porta de comunicação';
    -6  : sMsg := 'Impressora desligada ou desconectada';
    -8  : sMsg := 'Erro ao criar ou gravar no arquivo STATUS.TXT ou RETORNO.TXT. ';
    -9  : sMsg := 'Erro ao fechar a porta';
    -24 : sMsg := 'Forma de pagamento não programada.';
    -25 : sMsg := 'Totalizador não fiscal não programado.';
  end;
  Result :=  sMsg;
end;

// ------------------- Analisa Retorno da Impressora --------------------
Function Status_Impressora( lMensagem:Boolean; Tipo: integer = 1 ): Integer;
Var iACK, iST1, iST2, iRet: Integer;
    sRet : AnsiString;
Begin
If Tipo = 1 then
Begin
    iACK := 0;
    iST1 := 0;
    iST2 := 0;
    iRet := fFuncDaruma_FI_RetornoImpressora(iACK, iST1, iST2);
    If iACK = 6 then
    begin
          // Verifica ST1
          If iST1 >= 128 Then begin iST1 := iST1 - 128; iRet := 1 ; If lMensagem then ShowMessage('Fim de Papel'); end;
          If iST1 >= 64  Then begin iST1 := iST1 - 64;  iRet := 1 ; {If lMensagem then  ShowMessage('Pouco Papel');} end;
          If iST1 >= 32  Then begin iST1 := iST1 - 32;  iRet := 1 ; If lMensagem then ShowMessage('Erro no Relógio'); end;
          If iST1 >= 16  Then begin iST1 := iST1 - 16;  iRet := 1 ; If lMensagem then ShowMessage('Impressora em Erro'); end;
          If iST1 >= 8   Then begin iST1 := iST1 - 8;   iRet := 1 ; If lMensagem then ShowMessage('CMD não iniciado com ESC'); end;
          If iST1 >= 4   Then begin iST1 := iST1 - 4;   iRet := 1 ; If lMensagem then ShowMessage('Comando Inexistente'); end;
          If iST1 >= 2   Then begin iST1 := iST1 - 2;   iRet := 1 ; If lMensagem then ShowMessage('Cupom Aberto'); end;
          If iST1 >= 1   Then begin iST1 := iST1 - 1;   iRet := 1 ; If lMensagem then ShowMessage('Nº de Parâmetros Inválidos'); end;

          // Verifica ST2

          If iST2 >= 128 Then begin iST2 := iST2 - 128; iRet := 1 ; If lMensagem then ShowMessage('Tipo de Parâmetro Inválido'); end;
          If iST2 >= 64  Then begin iST2 := iST2 - 64;  iRet := 1 ; If lMensagem then ShowMessage('Memória Fiscal Lotada'); end;
          If iST2 >= 32  Then begin iST2 := iST2 - 32;  iRet := 1 ; If lMensagem then ShowMessage('CMOS não Volátil'); end;
          If iST2 >= 16  Then begin iST2 := iST2 - 16;  iRet := 1 ; If lMensagem then ShowMessage('Alíquota Não Programada'); end;
          If iST2 >= 8   Then begin iST2 := iST2 - 8;   iRet := 1 ; If lMensagem then ShowMessage('Alíquotas Lotadas'); end;
          If iST2 >= 4   Then begin iST2 := iST2 - 4;   iRet := 1 ; If lMensagem then ShowMessage('Cancelamento Não Permitido'); end;
          If iST2 >= 2   Then begin iST2 := iST2 - 2;   iRet := 1 ; If lMensagem then ShowMessage('CGC/IE Não Programados'); end;
          If iST2 >= 1   Then begin iST2 := iST2 - 1;   iRet := -1; {If lMensagem then ShowMessage('Comando Não Executado');} end;
    End;
End
Else
Begin
    sRet := Space(4);
    iRet := fFuncDaruma_FI_RetornaErroExtendido(sRet);
    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Daruma_FI_RetornaErroExtendido: '+IntToStr(iRet) ));
    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Daruma_FI_RetornaErroExtendido: '+sRet ));
    If Pos('000',sRet) = 0 then
        Begin
        If Pos('00',sRet)>0 Then begin iRet:= -1; {If lMensagem then ShowMessage('IF em modo Manutenção. Foi ligada sem o Jumper de Operação');} end;
        If Pos('01',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Comando disponível somente em modo Manutenção'); end;
        If Pos('02',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Erro durante a gravação da Memória Fiscal'); end;
        If Pos('03',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Memória Fiscal esgotada'); end;
        If Pos('04',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Erro no relógio interno da IF'); end;
        If Pos('05',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Falha mecânica na IF'); end;
        If Pos('06',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Erro durante a leitura da Memória Fiscal'); end;
        If Pos('10',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Documento sendo emitido'); end;
        If Pos('11',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Documento não foi aberto'); end;
        If Pos('12',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Não existe documento a cancelar'); end;
        If Pos('13',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage('Dígito não numérico não esperado foi encontrado nos parâmetros'); end;
        If Pos('14',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Não há mais memória disponível para esta operação'); end;
        If Pos('15',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Item a cancelar não foi encontrado'); end;
        If Pos('16',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Erro de sintaxe no comando'); end;
        If Pos('17',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' "Estouro" de capacidade numérica (overflow)'); end;
        If Pos('18',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Selecionado totalizador tributado com alíquota de imposto não definida'); end;
        If Pos('19',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Memória Fiscal vazia'); end;
        If Pos('20',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Não existem campos que requerem atualização'); end;
        If Pos('21',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Detectado proximidade do final da bobina de papel'); end;
        If Pos('22',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Cupom de Redução Z já foi emitido. IF inoperante até 0:00h do próximo dia'); end;
        If Pos('23',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Redução Z do período anterior ainda pendente. IF inoperante'); end;
        If Pos('24',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Valor de desconto ou acréscimo inválido (limitado a 100%)'); end;
        If Pos('25',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Caracter inválido foi encontrado nos parâmetros'); end;
        If Pos('27',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Nenhum periférico conectado a interface auxiliar'); end;
        If Pos('28',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Foi encontrado um campo em zero'); end;
        If Pos('29',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Documento anterior não foi Cupom Fiscal. Não pode emitir Cupom Adicional'); end;
        If Pos('30',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Acumulador Não Fiscal selecionado não é válido ou não está disponível'); end;
        If Pos('31',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Não pode autenticar. Excedeu 4 repetições ou não é permitida nesta fase'); end;
        If Pos('32',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Cupom adicional inibido por configuração'); end;
        If Pos('35',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Relógio Interno Inoperante'); end;
        If Pos('36',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Versão do firmware gravada na Memória Fiscal não é a esperada'); end;
        If Pos('37',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Alíquota de imposto informada já está carregada na memória'); end;
        If Pos('38',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Forma de pagamento selecionada não é válida'); end;
        If Pos('39',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Erro na seqüência de fechamento do Cupom Fiscal'); end;
        If Pos('40',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' IF em Jornada Fiscal. Alteração da configuração não é permitida'); end;
        If Pos('41',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Data inválida. Data fornecida é inferior à última gravada na Memória Fiscal'); end;
        If Pos('42',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Leitura X inicial ainda não foi emitida'); end;
        If Pos('43',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Não pode emitir Comprovante Vinculado'); end;
        If Pos('44',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Cupom de Orçamento não permitido para este estabelecimento'); end;
        If Pos('45',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Campo obrigatório em branco'); end;
        If Pos('48',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Não pode estornar'); end;
        If Pos('49',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Forma de pagamento indicada não encontrada'); end;
        If Pos('50',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Fim da bobina de papel'); end;
        If Pos('51',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Nenhum usuário cadastrado na MF'); end;
        If Pos('52',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' MF não instalada ou não inicializada'); end;
        If Pos('61',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Queda de energia durante a emissão de Cupom Fiscal'); end;
        If Pos('76',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Desconto em ISS não permitido (somente para versão 1.11 do Estado de Santa Catarina)'); end;
        If Pos('77',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Acréscimo em IOF inibido'); end;
        If Pos('80',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Periférico na interface auxiliar não pode ser reconhecido'); end;
        If Pos('81',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Solicitado preenchimento de cheque de banco desconhecido'); end;
        If Pos('82',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Solicitado transmissão de mensagem nula pela interface auxiliar'); end;
        If Pos('83',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Extenso do cheque não cabe no espaço disponível'); end;
        If Pos('84',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Erro na comunicação com a interface auxiliar'); end;
        If Pos('85',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Erro no dígito verificador durante comunicação com a PertoCheck'); end;
        If Pos('86',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Falha na carga de geometria de folha de cheque'); end;
        If Pos('87',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Parâmetro invállido para o campo de data do cheque'); end;
        If Pos('90',sRet)>0 Then begin iRet:= -1; If lMensagem then ShowMessage(' Sequência de validação de número de série inválida'); end;
        End;
End;
Result := iRet;
End;

//----------------------------------------------------------------------------
Function OpenDaruma  ( sPorta:AnsiString ) : AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: Daruma32.dll'+#13+
                  '(Atualize a DLL do Fabricante do ECF)');
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
  sTempPath  : AnsiString;
  BufferTemp : Array[0..144] of Char;
begin
    Result := '1|';
    bRet := True;
    fHandle := LoadLibrary( 'Daruma32.dll' );
    fHandle2:= 0 ;//fHandle2:= LoadLibrary( 'DarumaFrameWork.dll' );

    // Indica a possibilidade da utilização
    // via ActiveX portanto faz uma nova verificação.
    // Inicio
    If (fHandle = 0) Then
    Begin
        GetTempPath(144,BufferTemp);
        sTempPath := trim(StrPas(BufferTemp))+'Daruma32.dll';
        pTempPath := PChar(sTempPath);
        fHandle   := LoadLibrary( pTempPath );
    End;
    // Fim

    if (fHandle <> 0) Then //And (fHandle2 <> 0)Then
    begin
      aFunc := GetProcAddress(fHandle,'Daruma_FI_AbrePortaSerial');
      if ValidPointer( aFunc, 'Daruma_FI_AbrePortaSerial' ) then
        fFuncDaruma_FI_AbrePortaSerial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_FechaPortaSerial');
      if ValidPointer( aFunc, 'Daruma_FI_FechaPortaSerial' ) then
        fFuncDaruma_FI_FechaPortaSerial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_MapaResumo');
      if ValidPointer( aFunc, 'Daruma_FI_MapaResumo' ) then
        fFuncDaruma_FI_MapaResumo := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_AberturaDoDia');
      if ValidPointer( aFunc, 'Daruma_FI_AberturaDoDia' ) then
        fFuncDaruma_FI_AberturaDoDia := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_FechamentoDoDia');
      if ValidPointer( aFunc, 'Daruma_FI_FechamentoDoDia' ) then
        fFuncDaruma_FI_FechamentoDoDia := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_LeituraX');
      if ValidPointer( aFunc, 'Daruma_FI_LeituraX' ) then
        fFuncDaruma_FI_LeituraX := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_Registry_RetornaValor');
      if ValidPointer( aFunc, 'Daruma_Registry_RetornaValor' ) then
        fFuncDaruma_Registry_RetornaValor := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_ReducaoZ');
      if ValidPointer( aFunc, 'Daruma_FI_ReducaoZ' ) then
        fFuncDaruma_FI_ReducaoZ := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_DadosUltimaReducao');
      if ValidPointer( aFunc, 'Daruma_FI_DadosUltimaReducao' ) then
        fFuncDaruma_FI_DadosUltimaReducao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_RetornoAliquotas');
      if ValidPointer( aFunc, 'Daruma_FI_RetornoAliquotas' ) then
        fFuncDaruma_FI_RetornoAliquotas := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_RetornoImpressora');
      if ValidPointer( aFunc, 'Daruma_FI_RetornoImpressora' ) then
        fFuncDaruma_FI_RetornoImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_NumeroCaixa');
      if ValidPointer( aFunc, 'Daruma_FI_NumeroCaixa' ) then
        fFuncDaruma_FI_NumeroCaixa := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VersaoFirmware');
      if ValidPointer( aFunc, 'Daruma_FI_VersaoFirmware' ) then
        fFuncDaruma_FI_VersaoFirmware := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_DataMovimento');
      if ValidPointer( aFunc, 'Daruma_FI_DataMovimento' ) then
        fFuncDaruma_FI_DataMovimento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_NumeroReducoes');
      if ValidPointer( aFunc, 'Daruma_FI_NumeroReducoes' ) then
        fFuncDaruma_FI_NumeroReducoes := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_GrandeTotal');
      if ValidPointer( aFunc, 'Daruma_FI_GrandeTotal' ) then
        fFuncDaruma_FI_GrandeTotal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_NumeroCupom');
      if ValidPointer( aFunc, 'Daruma_FI_NumeroCupom' ) then
        fFuncDaruma_FI_NumeroCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_Cancelamentos');
      if ValidPointer( aFunc, 'Daruma_FI_Cancelamentos' ) then
        fFuncDaruma_FI_Cancelamentos := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_Descontos');
      if ValidPointer( aFunc, 'Daruma_FI_Descontos' ) then
        fFuncDaruma_FI_Descontos := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaTotalizadoresParciais');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaTotalizadoresParciais' ) then
        fFuncDaruma_FI_VerificaTotalizadoresParciais := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaTotalizadoresParciais');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaTotalizadoresParciais' ) then
        fFuncDaruma_FI_VerificaTotalizadoresParciais := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_AbreCupom');
      if ValidPointer( aFunc, 'Daruma_FI_AbreCupom' ) then
          fFuncDaruma_FI_AbreCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VendeItem');
      if ValidPointer( aFunc, 'Daruma_FI_VendeItem' ) then
          fFuncDaruma_FI_VendeItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_CancelaCupom');
      if ValidPointer( aFunc, 'Daruma_FI_CancelaCupom' ) then
          fFuncDaruma_FI_CancelaCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_IniciaFechamentoCupom');
      if ValidPointer( aFunc, 'Daruma_FI_IniciaFechamentoCupom' ) then
          fFuncDaruma_FI_IniciaFechamentoCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_EfetuaFormaPagamento');
      if ValidPointer( aFunc, 'Daruma_FI_EfetuaFormaPagamento' ) then
          fFuncDaruma_FI_EfetuaFormaPagamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_FechaCupom');
      if ValidPointer( aFunc, 'Daruma_FI_FechaCupom' ) then
          fFuncDaruma_FI_FechaCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaFormasPagamentoEx');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaFormasPagamentoEx' ) then
          fFuncDaruma_FI_VerificaFormasPagamentoEx := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_CancelaItemGenerico');
      if ValidPointer( aFunc, 'Daruma_FI_CancelaItemGenerico' ) then
          fFuncDaruma_FI_CancelaItemGenerico := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_TerminaFechamentoCupom');
      if ValidPointer( aFunc, 'Daruma_FI_TerminaFechamentoCupom' ) then
          fFuncDaruma_FI_TerminaFechamentoCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaIndiceAliquotasIss');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaIndiceAliquotasIss' ) then
          fFuncDaruma_FI_VerificaIndiceAliquotasIss := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_DataHoraImpressora');
      if ValidPointer( aFunc, 'Daruma_FI_DataHoraImpressora' ) then
          fFuncDaruma_FI_DataHoraImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaEstadoImpressora');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaEstadoImpressora' ) then
          fFuncDaruma_FI_VerificaEstadoImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaTruncamento');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaTruncamento' ) then
          fFuncDaruma_FI_VerificaTruncamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_RelatorioGerencial');
      if ValidPointer( aFunc, 'Daruma_FI_RelatorioGerencial' ) then
          fFuncDaruma_FI_RelatorioGerencial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FIMFD_ImprimeCodigoBarras');
      if ValidPointer( aFunc, 'Daruma_FIMFD_ImprimeCodigoBarras' ) then
          fFuncDaruma_FIMFD_ImprimeCodigoBarras := aFunc
      else
        bRet := False;


      aFunc := GetProcAddress(fHandle,'Daruma_FI_FechaRelatorioGerencial');
      if ValidPointer( aFunc, 'Daruma_FI_FechaRelatorioGerencial' ) then
          fFuncDaruma_FI_FechaRelatorioGerencial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_LeituraMemoriaFiscalData');
      if ValidPointer( aFunc, 'Daruma_FI_LeituraMemoriaFiscalData' ) then
          fFuncDaruma_FI_LeituraMemoriaFiscalData := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_LeituraMemoriaFiscalReducao');
      if ValidPointer( aFunc, 'Daruma_FI_LeituraMemoriaFiscalReducao' ) then
          fFuncDaruma_FI_LeituraMemoriaFiscalReducao := aFunc
      else
        bRet := False;
 
      aFunc := GetProcAddress(fHandle,'Daruma_FI_LeituraMemoriaFiscalSerialData');
      if ValidPointer( aFunc, 'Daruma_FI_LeituraMemoriaFiscalSerialData' ) then
          fFuncDaruma_FI_LeituraMemoriaFiscalSerialData := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_LeituraMemoriaFiscalSerialReducao');
      if ValidPointer( aFunc, 'Daruma_FI_LeituraMemoriaFiscalSerialReducao' ) then
          fFuncDaruma_FI_LeituraMemoriaFiscalSerialReducao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_ProgramaAliquota');
      if ValidPointer( aFunc, 'Daruma_FI_ProgramaAliquota' ) then
          fFuncDaruma_FI_ProgramaAliquota := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_CfgHorarioVerao');
      if ValidPointer( aFunc, 'Daruma_FI_CfgHorarioVerao' ) then
          fFuncDaruma_FI_CfgHorarioVerao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_RecebimentoNaoFiscal');
      if ValidPointer( aFunc, 'Daruma_FI_RecebimentoNaoFiscal' ) then
          fFuncDaruma_FI_RecebimentoNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_AbreComprovanteNaoFiscalVinculado');
      if ValidPointer( aFunc, 'Daruma_FI_AbreComprovanteNaoFiscalVinculado' ) then
          fFuncDaruma_FI_AbreComprovanteNaoFiscalVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_UsaComprovanteNaoFiscalVinculado');
      if ValidPointer( aFunc, 'Daruma_FI_UsaComprovanteNaoFiscalVinculado' ) then
          fFuncDaruma_FI_UsaComprovanteNaoFiscalVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_FechaComprovanteNaoFiscalVinculado');
      if ValidPointer( aFunc, 'Daruma_FI_FechaComprovanteNaoFiscalVinculado' ) then
          fFuncDaruma_FI_FechaComprovanteNaoFiscalVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_Sangria');
      if ValidPointer( aFunc, 'Daruma_FI_Sangria' ) then
          fFuncDaruma_FI_Sangria := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_Suprimento');
      if ValidPointer( aFunc, 'Daruma_FI_Suprimento' ) then
          fFuncDaruma_FI_Suprimento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaTotalizadoresNaoFiscaisEx');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaTotalizadoresNaoFiscaisEx' ) then
          fFuncDaruma_FI_VerificaTotalizadoresNaoFiscaisEx := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_Autenticacao');
      if ValidPointer( aFunc, 'Daruma_FI_Autenticacao' ) then
          fFuncDaruma_FI_Autenticacao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_ProgramaCaracterAutenticacao');
      if ValidPointer( aFunc, 'Daruma_FI_ProgramaCaracterAutenticacao' ) then
          fFuncDaruma_FI_ProgramaCaracterAutenticacao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_AcionaGaveta');
      if ValidPointer( aFunc, 'Daruma_FI_AcionaGaveta' ) then
          fFuncDaruma_FI_AcionaGaveta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaEstadoGaveta');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaEstadoGaveta' ) then
          fFuncDaruma_FI_VerificaEstadoGaveta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_NomeiaTotalizadorNaoSujeitoIcms');
      if ValidPointer( aFunc, 'Daruma_FI_NomeiaTotalizadorNaoSujeitoIcms' ) then
          fFuncDaruma_FI_NomeiaTotalizadorNaoSujeitoIcms := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_NumeroSerie');
      if ValidPointer( aFunc, 'Daruma_FI_NumeroSerie' ) then
          fFuncDaruma_FI_NumeroSerie := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_LerAliquotasComIndice');
      if ValidPointer( aFunc, 'Daruma_FI_LerAliquotasComIndice' ) then
          fFuncDaruma_FI_LerAliquotasComIndice := aFunc
      else
        bRet := False;


      aFunc := GetProcAddress(fHandle,'Daruma_FI_ProgramaFormasPagamento');
      if ValidPointer( aFunc, 'Daruma_FI_ProgramaFormasPagamento' ) then
          fFuncDaruma_FI_ProgramaFormasPagamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_Registry_ZAutomatica');
      if ValidPointer( aFunc, 'Daruma_Registry_ZAutomatica' ) then
          fFuncDaruma_Registry_ZAutomatica := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FIR_RetornaCRO');
      if ValidPointer( aFunc, 'Daruma_FIR_RetornaCRO' ) then
          fFuncDaruma_FIR_RetornaCRO := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_RetornaErroExtendido');
      if ValidPointer( aFunc, 'Daruma_FI_RetornaErroExtendido' ) then
          fFuncDaruma_FI_RetornaErroExtendido := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_AumentaDescricaoItem');
      if ValidPointer( aFunc, 'Daruma_FI_AumentaDescricaoItem' ) then
          fFuncDaruma_FI_AumentaDescricaoItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_ProgramaMoedaSingular');
      if ValidPointer( aFunc, 'Daruma_FI_ProgramaMoedaSingular' ) then
        fFuncDaruma_FI_ProgramaMoedaSingular := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_ProgramaMoedaPlural');
      if ValidPointer( aFunc, 'Daruma_FI_ProgramaMoedaPlural' ) then
        fFuncDaruma_FI_ProgramaMoedaPlural := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_CancelaImpressaoCheque');
      if ValidPointer( aFunc, 'Daruma_FI_CancelaImpressaoCheque' ) then
        fFuncDaruma_FI_CancelaImpressaoCheque := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaStatusCheque');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaStatusCheque' ) then
        fFuncDaruma_FI_VerificaStatusCheque := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI2000_ImprimirCheque');
      if ValidPointer( aFunc, 'Daruma_FI2000_ImprimirCheque' ) then
        fFuncDaruma_FI2000_ImprimirCheque := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_IncluiCidadeFavorecido');
      if ValidPointer( aFunc, 'Daruma_FI_IncluiCidadeFavorecido' ) then
        fFuncDaruma_FI_IncluiCidadeFavorecido := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_ImprimeCopiaCheque');
      if ValidPointer( aFunc, 'Daruma_FI_ImprimeCopiaCheque' ) then
        fFuncDaruma_FI_ImprimeCopiaCheque := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_StatusCupomFiscal');
      if ValidPointer( aFunc, 'Daruma_FI_StatusCupomFiscal' ) then
        fFuncDaruma_FI_StatusCupomFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_RetornaIndiceComprovanteNaoFiscal');
      if ValidPointer( aFunc, 'Daruma_FI_RetornaIndiceComprovanteNaoFiscal' ) then
        fFuncDaruma_FI_RetornaIndiceComprovanteNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_PalavraStatusBinario');
      if ValidPointer( aFunc, 'Daruma_FI_PalavraStatusBinario' ) then
        fFuncDaruma_FI_PalavraStatusBinario := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_StatusComprovanteNaoFiscalVinculado');
      if ValidPointer( aFunc, 'Daruma_FI_StatusComprovanteNaoFiscalVinculado' ) then
        fFuncDaruma_FI_StatusComprovanteNaoFiscalVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VendaBruta');
      if ValidPointer( aFunc, 'Daruma_FI_VendaBruta' ) then
        fFuncDaruma_FI_VendaBruta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_COO');
      if ValidPointer( aFunc, 'Daruma_FI_COO' ) then
        fFuncDaruma_FI_COO := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_CGC_IE');
      if ValidPointer( aFunc, 'Daruma_FI_CGC_IE' ) then
        fFuncDaruma_FI_CGC_IE := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaRecebimentoNaoFiscal');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaRecebimentoNaoFiscal' ) then
        fFuncDaruma_FI_VerificaRecebimentoNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FIMFD_DownloadDaMFD');
      if ValidPointer( aFunc, 'Daruma_FIMFD_DownloadDaMFD' ) then
        fFuncDaruma_FIMFD_DownloadDaMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FIMFD_RetornaInformacao');
      if ValidPointer( aFunc, 'Daruma_FIMFD_RetornaInformacao' ) then
        fFuncDaruma_FIMFD_RetornaInformacao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_NumeroLoja');
      if ValidPointer( aFunc, 'Daruma_FI_NumeroLoja' ) then
        fFuncDaruma_FI_NumeroLoja := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_VerificaModeloECF');
      if ValidPointer( aFunc, 'Daruma_FI_VerificaModeloECF' ) then
        fFuncDaruma_FI_VerificaModeloECF := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_RetornaCRO');
      if ValidPointer( aFunc, 'Daruma_FI_RetornaCRO' ) then
        fFuncDaruma_FI_RetornaCRO := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_RetornaCRZ');
      if ValidPointer( aFunc, 'Daruma_FI_RetornaCRZ' ) then
        fFuncDaruma_FI_RetornaCRZ := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_Registry_MFD_LeituraMFCompleta');
      if ValidPointer( aFunc, 'Daruma_Registry_MFD_LeituraMFCompleta' ) then
        fFuncDaruma_Registry_MFD_LeituraMFCompleta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FIMFD_GerarAtoCotepePafData');
      if ValidPointer( aFunc, 'Daruma_FIMFD_GerarAtoCotepePafData' ) then
        fFuncDaruma_FIMFD_GerarAtoCotepePafData := aFunc
      else
        bRet := False;

       aFunc := GetProcAddress(fHandle,'Daruma_FIMFD_GerarMFPAF_Data');
      if ValidPointer( aFunc, 'Daruma_FIMFD_GerarMFPAF_Data' ) then
        fFuncDaruma_FIMFD_GerarMFPAF_Data := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FIMFD_GerarAtoCotepePafCOO');
      if ValidPointer( aFunc, 'Daruma_FIMFD_GerarAtoCotepePafCOO' ) then
        fFuncDaruma_FIMFD_GerarAtoCotepePafCOO := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_Registry_AlterarRegistry');
      if ValidPointer( aFunc, 'Daruma_Registry_AlterarRegistry' ) then
        fFuncDaruma_Registry_AlterarRegistry := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_IdentificaConsumidor');
      if ValidPointer( aFunc, 'Daruma_FI_IdentificaConsumidor' ) then
        fFuncDaruma_FI_IdentificaConsumidor := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_SubTotal');
      if ValidPointer( aFunc, 'Daruma_FI_SubTotal' ) then
        fFuncDaruma_FI_SubTotal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_UltimoItemVendido');
      if ValidPointer( aFunc, 'Daruma_FI_UltimoItemVendido' ) then
        fFuncDaruma_FI_UltimoItemVendido := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FI_NumeroOperacoesNaoFiscais');
      if ValidPointer( aFunc, 'Daruma_FI_NumeroOperacoesNaoFiscais' ) then
          fFuncDaruma_FI_NumeroOperacoesNaoFiscais := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Daruma_FIMFD_AbreRelatorioGerencial');
      if ValidPointer( aFunc, 'Daruma_FIMFD_AbreRelatorioGerencial' ) then
        fFuncDaruma_FIMFD_AbreRelatorioGerencial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle, 'Daruma_FIMFD_VerificaRelatoriosGerenciais');
      if ValidPointer( aFunc , 'Daruma_FIMFD_VerificaRelatoriosGerenciais') then
         fFuncDaruma_FIMFD_VerificaRelatoriosGerenciais := aFunc
      else
         bRet := False;

      //Funções da DarumaFrameWork.dll não utilizar ainda
      {*
      aFunc := GetProcAddress(fHandle2,'rGerarRelatorio_ECF_Daruma');
      if ValidPointer( aFunc, 'rGerarRelatorio_ECF_Daruma') then
        fFuncrGerarRelatorio_ECF_Daruma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle2,'eBuscarPortaVelocidade_ECF_Daruma');
      if ValidPointer( aFunc, 'eBuscarPortaVelocidade_ECF_Daruma') then
       fFunceBuscarPortaVelocidade_ECF_Daruma := aFunc
      else
       bRet := False;*

       aFunc := GetProcAddress(fHandle2, 'regAlterarValor_Daruma');
       if ValidPointer( aFunc , 'regAlterarValor_Daruma') then
         fFuncregAlterarValor_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle2,'iCCDEstornar_ECF_Daruma');
       If ValidPointer( aFunc , 'iCCDEstornar_ECF_Daruma') then
         fFunciCCDEstornar_ECF_Daruma := aFunc
       else
         bRet := False;

       aFunc := GetProcAddress(fHandle2 , 'iCCDEstornarPadrao_ECF_Daruma');
       If ValidPointer( aFunc , 'iCCDEstornarPadrao_ECF_Daruma') then
         fFunciCCDEstornarPadrao_ECF_Daruma := aFunc
       else
         bRet := False; }

    end
    else
    begin
      //ShowMessage('O(s) arquivo(s) Daruma32.DLL/DarumaFrameWork.dll não foi(ram) encontrado(s). ');
      ShowMessage('O arquivo Daruma32.DLL não foi encontrado.');
      bRet := False;
    end;

    If bRet then
    Begin
      Result := '0|';
      iRet := fFuncDaruma_Registry_ZAutomatica('0');
      If iRet = 1 then
      begin
          // Esse comando só irá fazer a abertura da porta. Não checa se a impressora está ou não ligada.
          iRet := fFuncDaruma_FI_AbrePortaSerial();
          if iRet <> 1 then
          begin
            bOpened := False;
            Result := '1|';
          end;
      End
      Else
           Result := '1';
    end
    else
        Result := '1|';
end;

//----------------------------------------------------------------------------
Function CloseDaruma : AnsiString;
var
  iRet : Integer;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      iRet := fFuncDaruma_FI_FechaPortaSerial;
      TrataRetornoDaruma( iRet );
      FreeLibrary(fHandle);
      fHandle := 0;
    end;
    bOpened := False;
  End;
  Result := '0';
end;

//-----------------------------------------------------------
function TImpFiscalDaruma2000.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
Var
  iRet            : Integer;
  sPedido         : AnsiString;
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
  sArquivoIni     : AnsiString;
  sRet            : AnsiString;
  sCOORecebimento : AnsiString;
  sLinha          : AnsiString;
begin
  //******************************************************************************
  // Para não forçar o cliente a utilizar registradores fixos do ECF na emissão
  // de cupom não fiscal vinculado e não vinculado para a impressão do comprovante
  // de venda (função abaixo) sera utilizado o arquivo DARUMA.INI com o conteudo
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
  // - Condicao deverá conter a condição de pagamento que servirá para o recebimento
  // do comprovante não fiscal não vinculado
  //*******************************************************************************

  //*******************************************************************************
  // Inicialização das variaveis
  //*******************************************************************************
  Result      := '1';
  lPedido     := False;
  lTefPedido  := False;
  sArquivoIni := 'DARUMA.INI';
  sPath       := '';

  //*******************************************************************************
  // Pega os nomes dos totalizadores no arquivo de configuração (DARUMA.INI)
  //*******************************************************************************
  sPath       := ExtractFilePath(Application.ExeName);
  fArquivo    := TIniFile.Create(sPath + sArquivoIni);
  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Condicao', 'Dinheiro' );

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  //*******************************************************************************
  // Libera as variaveis
  //*******************************************************************************
  fArquivo.Free;

  //*******************************************************************************
  // Checa os totalizadores cadastrados no ECF.
  // Chama a funcao de leitura dos totalizadores nao fiscais do ECF
  //*******************************************************************************
  sTotalizadores  := Space(300); 
  iRet            := fFuncDaruma_FI_VerificaTotalizadoresNaoFiscaisEx( sTotalizadores );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
  begin
    //*******************************************************************************
    // Verifica se os totalizadores informados no .INI existem na impressora
    // Valida os primeiros 19 caracteres porque a funcao de verificaTotalizadoresNaoFiscal
    // só retorna os 19 primeiros.
    //*******************************************************************************
    sPedido     := Copy( sPedido, 1, 19 );
    sTefPedido  := Copy( sTefPedido, 1, 19 );
    If (Pos( UpperCase(sPedido), UpperCase(sTotalizadores) ) > 0) And (Pos( UpperCase(sTefPedido), UpperCase(sTotalizadores) ) > 0) then
    begin
      sTotalizadores := StrTran( sTotalizadores, ',', '|' );
      MontaArray( sTotalizadores,aAuxiliar );
      iX := 0;
      While (iX < Length(aAuxiliar)) do
      begin
        //*******************************************************************************
        // O totalizador 01 da Daruma é sempre SANGRIA (isto foi informado pelo Alexandre do
        // suporte da Daruma Tel.(41)3361-6076/6005. Por este motivo, sempre que a rotina
        // encontrar o totalizador considera sempre mais 1 como sendo sua posição.
        //*******************************************************************************
        //*******************************************************************************
        // Tira as strings e coloca as strings em maiusculo para comparar e ver se o
        // totalizador é o mesmo
        //*******************************************************************************
        If UpperCase(Trim(aAuxiliar[iX])) = UpperCase(Trim(sPedido)) then
        begin
          lPedido := True;
          sTotPedido := Trim(aAuxiliar[iX]);
        end;
        //*******************************************************************************
        // Tira as strings e coloca as strings em maiusculo para comparar e ver se o
        // totalizador é o mesmo
        //*******************************************************************************
        If UpperCase(Trim(aAuxiliar[iX])) = UpperCase(Trim(sTefPedido)) then
        begin
          lTefPedido := True;
          sTotTefPedido := Trim(aAuxiliar[iX]);
        end;
        //*******************************************************************************
        // Se nao existir os totalizadores no ECF nao pode continuar.
        //*******************************************************************************
        If lPedido And lTefPedido then break;
        //*******************************************************************************
        // Incrementa a variavel iX para controle do While.
        //*******************************************************************************
        Inc( iX );
      end;
    end;
  end;

  //*******************************************************************************
  // Faz o tratamento dos parâmetros
  //*******************************************************************************
  Valor       := Trim(FormataTexto( Valor, 14, 2, 3 ));

  //*******************************************************************************
  // Faz o recebimento não fiscal / Comprovante não fiscal não vinculado
  // apenas se existirem os totalizadores nao fiscais.
  //*******************************************************************************
  If lPedido And lTefPedido then
  begin
    Result := '1';
    //*******************************************************************************
    // Abre o comprovante não fiscal. Tenta abrir um vinculado mas caso não consiga
    // faz um recebimento não fiscal para depois abrir o comprovante não fiscal
    // Condicao = Descricao da Forma de pagamento - Nao pode ser DINHEIRO
    //*******************************************************************************
    iRet := fFuncDaruma_FI_RecebimentoNaoFiscal( pchar(sPedido), pchar(Valor), pchar(sCondicao) );
    If Status_Impressora( False ) = 1 then
    begin

      //*******************************************************************************
      // Abre o comprovante não fiscal vinculado
      //*******************************************************************************
      iRet := fFuncDaruma_FI_AbreComprovanteNaoFiscalVinculado( sCondicao, '', '' );
      If Status_Impressora( False ) = 1 then
      begin
          While Length( Texto ) > 0 do
          begin
            sLinha := Copy( Texto, 1, 618 );
            iRet := fFuncDaruma_FI_UsaComprovanteNaoFiscalVinculado( sLinha );
            Texto := Copy( Texto, 619, Length(Texto)-618 );
          end;

          If Status_Impressora( False ) = 1 then
          begin
            iRet := fFuncDaruma_FI_FechaComprovanteNaoFiscalVinculado;
            If Status_Impressora( False ) = 1 then
            begin
              //*******************************************************************************
              // Checar se serah impresso o comprovante TEF. Caso afirmativo abre um novo
              // comprovante nao fiscal nao vinculado.
              //*******************************************************************************
              If Tef = 'S' then
              begin
                iRet := fFuncDaruma_FI_RecebimentoNaoFiscal ( sTotTefPedido, Valor, sCondicao );
                If Status_Impressora( False ) = 1 then
                  Result := '0';
              end
              Else
                Result := '0';
            end;
          end;
      end;
    end;
    //*******************************************************************************
    // Mostrar mensagem de erro se necessário
    //*******************************************************************************
    If Result = '1' then
      TrataRetornoDaruma( iRet );

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
      LjMsgDlg('Os totalizadores ' + sMsg + ' não existem no ECF. Checar o arquivo DARUMA.INI' );
    Result := '1';
  end;

end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma2000.PegaSerie : AnsiString;
Begin
  Result := '0|' + NumSerie;
End;

//------------------------------------------------------------------------------
function TImpFiscalDaruma2100.DownloadMFD(sTipo, sInicio,
  sFinal: AnsiString): AnsiString;
Var
  iRet                : Integer;   // Retorno da dll
  sMsg: AnsiString;
  sRetorno : AnsiString;
Begin
  Result   := '1';
  sRetorno := '1';
  sMsg     := 'Função disponível somente para geração por COO.';

  If sTipo = '1' Then
    MessageDlg( sMsg, mtInformation,[mbOK],0);

  If sTipo = '2' Then
  Begin
    sInicio := FormataTexto(sInicio,6,0,2);
    sFinal  := FormataTexto(sFinal,6,0,2);

    iRet := fFuncDaruma_FIMFD_DownloadDaMFD( Pchar(sInicio), Pchar(sFinal) );
    TrataRetornoDaruma( iRet, 0 );

    if iRet = 1 then
      sRetorno := CopRenArquivo( sPathEcfRegistry, sArqEcfDefault, PathArquivo, ArqDownTXT );
  End;

  Result := sRetorno ;
end;

//----------------------------------------------------------------------------
function TImpFiscalDaruma2100.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;
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
  SetLength ( sInformacao, 2 );
  fFuncDaruma_FI_StatusComprovanteNaoFiscalVinculado( PChar(sInformacao) );
  If Status_Impressora( False ) = 1 then
  begin
    //****************************************************************************
    // Se houver cupom em aberto, faz o cancelamento
    //****************************************************************************
    If sInformacao[1] = '1' then
    begin
      fFuncDaruma_FI_FechaComprovanteNaoFiscalVinculado;
      If Status_Impressora( False ) = 1 then Result := '0' else Result := '1';
    end;
  end;

  //****************************************************************************
  // Verifica a quantidade de vias que é para imprimir
  //****************************************************************************
  if Vias > 1 then
  Begin
    sTexto := Codigo;
    i:=1;
    While i < Vias do
    Begin
        Codigo:= Codigo+ sTexto;
        Inc(i);
    End;
  End;

  //****************************************************************************
  // Envia o comando de impressao da abertura do relatorio gerencial
  //****************************************************************************
  //fFuncDaruma_FIMFD_AbreRelatorioGerencial( pChar('1') );
  //If Status_Impressora( False ) = 1 then Result := '0' else Result := '1';

  iRet := fFuncDaruma_FI_RelatorioGerencial( Copy( Cabecalho, 1, 400 ) );
  If Status_Impressora( False ) = 1 then Result := '0' else Result := '1';

  //****************************************************************************
  // Envia o comando de impressao do relatorio gerencial
  //****************************************************************************
  If Length( Trim( Codigo ) ) > 0 then
  begin
    While Length( Trim( Codigo ) ) <> 0 do
    Begin
      iRet := fFuncDaruma_FIMFD_ImprimeCodigoBarras( pChar('04'),pChar(Copy( Codigo, 1, 400 )),'3',pChar('125'),'1' );
      Codigo := Copy( Codigo, 401, Length( Codigo ) );
    End;
    If Status_Impressora( False ) = 1 then Result := '0' else Result := '1';
  end
  else
    Result := '0';

  iRet := fFuncDaruma_FI_RelatorioGerencial( Copy( Rodape, 1, 400 ) );
  If Status_Impressora( False ) = 1 then Result := '0' else Result := '1';

  //****************************************************************************
  // Fecha o relatorio gerencial
  //****************************************************************************
  fFuncDaruma_FI_FechaRelatorioGerencial;
  If Status_Impressora( False ) = 1 then Result := '0' else Result := '1';

end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma2100.GeraRegTipoE(sTipo, sInicio, sFinal, sRazao,sEnd, sBinario: AnsiString): AnsiString;
Var
  iRet: integer;
  sArquivo: AnsiString;
begin
  GravaLog('Entrou na função GeraRegTipoE') ;

  //Quando por COO, preenche com zeros a esquerda para evitar erro
  If sTipo = '2' then
  begin
    sInicio := FormataTexto(sInicio,6,0,2);
    sFinal  := FormataTexto(sFinal,6,0,2);
    iRet    := fFuncDaruma_FIMFD_GerarAtoCotepePafCOO(sInicio,sFinal);
  end
  else
  begin
    sInicio := FormatDateTime('ddmmyyyy',StrToDate(sInicio));
    sFinal  := FormatDateTime('ddmmyyyy',StrToDate(sFinal));
    iRet    := fFuncDaruma_FIMFD_GerarAtoCotepePafData(sInicio,sFinal);
  end;

  GravaLog('Parametros: iRet : ' + IntToStr(iRet));

  TrataRetornoDaruma(iRet);
  if iRet = 1
  then Result := '0'
  else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma2100.TextoNaoFiscal( Texto:AnsiString; Vias:Integer ):AnsiString;
var
  i: Integer;
  sTexto  : AnsiString;
  iRet    : Integer;
  sLinha  :AnsiString;
Begin
  Result := '0';
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

  // Laço para imprimir toda a mensagem
  While ( Trim(Texto)<>'' ) do
      Begin
       { sLinha := '';
         // Laço para pegar 40 caracter do Texto
         If Pos(#10,Copy(Texto,1,41))>1 then
         begin
            sLinha := Copy(Texto,1, Pos(#10,Texto)-1);
            Texto  := Copy(Texto,Pos(#10,Texto)+1, Length(Texto));
         End
         Else If Pos(#10,Copy(Texto,1,41))=1 then
         Begin
            sLinha := #13;
            Texto := Copy(Texto,2,Length(Texto));
         End
         Else
         Begin
            sLinha := Copy(Texto,1, 400);
            Texto  := Copy(Texto,401, Length(Texto));
         End;
         iRet   := fFuncDaruma_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
         // Ocorreu erro na impressão do cupom
         if iRet<>1 then
         Begin
            Result := '1';
            Break;
         End;}
         sLinha := Copy(Texto,1, 400);
         Texto  := Copy(Texto,401, Length(Texto));
         iRet   := fFuncDaruma_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
         TrataRetornoDaruma( iRet, 0 );
      End;
end;

//----------------------------------------------------------------------------

function TImpFiscalDaruma2000.MemoriaFiscal(DataInicio, DataFim: TDateTime;
  ReducInicio, ReducFim, Tipo: AnsiString): AnsiString;
var
  iRet : Integer;
  sDatai : AnsiString;
  sDataf : AnsiString;
  sTipoAux: AnsiString;
begin
  //Parametro "Tipo" recebe AnsiString com duas posições:
  //Primeira posição: "I" para impressão e "A" salvar arquivo
  //Segunda posição: "S" para leitura simplificada e "C" para leitura completa

  sTipoAux := UpperCase(Copy(Tipo,2,1)) ; //Configura se Leitura será Simplificada ou Completa, dafault = 'C' Completa.

  If sTipoAux = 'S' then
     iRet := fFuncDaruma_Registry_MFD_LeituraMFCompleta('0')
  else
     iRet := fFuncDaruma_Registry_MFD_LeituraMFCompleta('1');

  TrataRetornoDaruma( iRet );

  If iRet <> 1 then
  begin
    Result := '1';
    exit;
  end;

  sTipoAux := UpperCase(Copy(Tipo,1,1)) ;

  if sTipoAux = 'I' then
  begin
      // Se o relatório for por Data
      If Trim(ReducInicio) + Trim(ReducFim) = '' then
      begin
        sDatai := FormataData( DataInicio, 4 );
        sDataf := FormataData( DataFim, 4 );
        iRet := fFuncDaruma_FI_LeituraMemoriaFiscalData(sDatai,sDataf);
        TrataRetornoDaruma( iRet );
        If iRet >= 0 then
          Result := '0'
        Else
          Result := '1';
      end
      Else       // Se o relatório será por redução Z
      Begin
        iRet :=fFuncDaruma_FI_LeituraMemoriaFiscalReducao(Pchar(ReducInicio),Pchar(ReducFim));
        TrataRetornoDaruma( iRet );
        If iRet >= 0 then
          Result := '0'
        Else
          Result := '1';
      end;
  end
  Else
  Begin
      // Se o relatório for por Data
      If Trim(ReducInicio) + Trim(ReducFim) = '' then
      begin
        sDatai := FormataData( DataInicio, 1 );
        sDataf := FormataData( DataFim, 1 );
        iRet := fFuncDaruma_FI_LeituraMemoriaFiscalSerialData(sDatai,sDataf);
        TrataRetornoDaruma( iRet );
        If iRet = 1 then
          Result := '0'
        Else
          Result := '1';
      end
      Else       // Se o relatório será por redução Z
      Begin
        iRet :=fFuncDaruma_FI_LeituraMemoriaFiscalSerialReducao(ReducInicio,ReducFim);
        TrataRetornoDaruma( iRet );
        If iRet = 1 then
          Result := '0'
        Else
          Result := '1';
      end;

      //verifica se irá salvar relatório Completo/Simplificado
      If (Result = '0') then
      Begin
        sTipoAux := UpperCase(Copy(Tipo,2,1)) ;

        If sTipoAux = 'S' Then
          Result := CopRenArquivo( sPathEcfRegistry, sArqEcfDefault, PathArquivo, DEFAULT_ARQMEMSIM )
        Else
          Result := CopRenArquivo( sPathEcfRegistry, sArqEcfDefault, PathArquivo, DEFAULT_ARQMEMCOM );
      End ;

  end;
end;

//------------------------------------------------------------------------------
procedure TImpFiscalDaruma2000.AlimentaProperties;
var
  iRet : Integer;
  sRet, sAliq : AnsiString;
  Reg: TRegistry;
begin
  /// Inicalização de variaveis
  ICMS := '';
  ISS := '';
  PDV := '';
  Eprom := '';
  Cnpj  := Space(18);
  Ie    := Space(18);
  NumLoja   := Space(4);
  NumSerie  := Space(21);
  TipoEcf   := '';
  MarcaEcf  := '';
  ModeloEcf := '';
  IndicaMFAdi  := '';
  DataIntEprom := '';
  HoraIntEprom := '';
  ContadorCro  := Space(4);
  ContadorCrz  := Space(4);
  GTInicial      := '';
  GTFinal        := Space(18);
  VendaBrutaDia  := Space(18);
  ReducaoEmitida := False;

  // Retorno de Aliquotas ( ICMS / ISS )
  sRet := Space( 300 );
  iRet := fFuncDaruma_FI_LerAliquotasComIndice(sRet);
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
  Begin
      While Length(sRet)>0 do
      begin
        sAliq := Copy(sRet,3,2)+','+Copy(sRet,5,2);
        If Copy(sRet,1,1) = 'T' then
            ICMS  := ICMS + FormataTexto(sAliq,5,2,1) +'|'
        Else if Copy(sRet,1,1) = 'S' then
            ISS   := ISS + FormataTexto(sAliq,5,2,1) +'|';
        sRet  := Copy(sRet,7,Length(sRet));
      end;
    End;

  // Retorno do Numero do Caixa (PDV)
  sRet := Space ( 4 );
  iRet := fFuncDaruma_FI_NumeroCaixa( sRet );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    If Pos(#0,sRet) > 0 then
      PDV := Copy(sRet,1,Pos(#0,sRet)-1)
    Else
      PDV := Copy(sRet,1,4);

  // Retorno da Versão do Firmware (Eprom)
  sRet := Space( 6 );
  iRet := fFuncDaruma_FIMFD_RetornaInformacao( '83', sRet );
  TrataRetornoDaruma( iRet );
  If iRet = 1 then
    Eprom := sRet ;

  // Retorna o CNPJ
  // Retorna a IE
  iRet := fFuncDaruma_FI_CGC_IE( Cnpj, Ie );
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Numero da loja cadastrado no ECF
  iRet := fFuncDaruma_FI_NumeroLoja( NumLoja );
  NumLoja := Trim( NumLoja );
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Numero da Serie com 20 posições
  iRet := fFuncDaruma_FIMFD_RetornaInformacao( '78', NumSerie );
  NumSerie := Copy(Trim( NumSerie ),1,20);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Tipo do ECF
  TipoEcf := 'ECF-IF';

  // Retorna Marca do ECF
  MarcaEcf := sMarca;

  // Retorna Modelo do ECF
  iRet := fFuncDaruma_FI_VerificaModeloECF;
  case iRet of
   1 : ModeloEcf := 'FS345' ;
   2 : ModeloEcf := 'FS318' ;
   3 : ModeloEcf := 'FS2000' ;
   4 : ModeloEcf := 'FS600' ;
   5 : ModeloEcf := 'FS700' ;
  end;

  // Retorna Contador de Reinicio de Operação
  IRet := fFuncDaruma_FI_RetornaCRO(ContadorCro);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna Contador de ReduçãoZ
  IRet := fFuncDaruma_FI_RetornaCRZ(ContadorCrz);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o valor Total Bruto Vendido até o momento do referido movimento
  IRet := fFuncDaruma_FI_VendaBruta(VendaBrutaDia);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o valor do Grande Total da impressora
  IRet := fFuncDaruma_FI_GrandeTotal(GTFinal);
  TrataRetornoDaruma( iRet );
  If iRet <> 1 then
    exit;

  // Calcula o Grande Total Inicial
  GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );


  //Path arquivos ECF
  try
    Reg := TRegistry.Create;
    Reg.RootKey:=HKEY_LOCAL_MACHINE;
    Reg.OpenKey('\Software\DARUMA\ECF',False);
    sPathEcfRegistry := Reg.ReadString('Path');
    {Força último caracter barra '\'}
    If Copy(sPathEcfRegistry,Length(sPathEcfRegistry),1) <> '\' then
       sPathEcfRegistry := sPathEcfRegistry + '\' ;

    {Verifica se caminho existe, se não existir cria}
    if (not DirectoryExists(sPathEcfRegistry)) and (Not ForceDirectories(sPathEcfRegistry)) then
       MessageDlg( 'Caminho para retorno do ECF não encontrado:'+sPathEcfRegistry, mtError,[mbOK],0);

    {Configura Path para gerar registro tipo E}
    if Reg.OpenKey('\Software\DARUMA\AtoCotepe',False) then
       Reg.WriteString('Path',PathArquivo+DEFAULT_PATHARQMFD);
  finally
    Reg.Free ;
  end;

end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma600_v0102.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Var
  iRet                : Integer;   // Retorno da dll
  sMsg,sMsgOk,sMsgErr : AnsiString;
  Reg                 : TRegistry;
Begin
  Result  := '1';
  Reg := TRegistry.Create;
  Reg.RootKey:=HKEY_LOCAL_MACHINE;
  Reg.OpenKey('\Software\DARUMA\ECF',False);
  sMsg    := 'Função disponível somente para geração por COO.';
  sMsgOk  := 'Arquivo '+Reg.ReadString('Path')+'Retorno.txt gerado com sucesso.';
  sMsgErr := 'Erro na geração do arquivo.';

  If sTipo = '1' Then
    MessageDlg( sMsg, mtInformation,[mbOK],0);

  If sTipo = '2' Then
  Begin
    iRet := fFuncDaruma_FIMFD_DownloadDaMFD( Pchar(sInicio), Pchar(sFinal) );
    TrataRetornoDaruma( iRet, 0 );
    If iRet = 1 Then
      MessageDlg( sMsgOk, mtInformation,[mbOK],0)
    Else
      MessageDlg( sMsgErr, mtError,[mbOK],0);
  End;

end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma600_v0103.DownloadMFD(sTipo, sInicio, sFinal: AnsiString): AnsiString;
Var
  iRet: Integer;   // Retorno da dll
  sMsgErr : AnsiString;
  sRetorno : AnsiString;
Begin
  Result   := '1';
  sRetorno := '1';
  sMsgErr  := 'Erro na geração do arquivo.';

  //Quando por COO, preenche com zeros a esquerda para evitar erro
  If sTipo = '2' then
  begin
    sInicio := FormataTexto(sInicio,6,0,2);
    sFinal  := FormataTexto(sFinal,6,0,2);
  end;

  iRet := fFuncDaruma_FIMFD_DownloadDaMFD( Pchar(sInicio), Pchar(sFinal) );
  TrataRetornoDaruma( iRet, 0 );

  if iRet = 1 then
    sRetorno := CopRenArquivo( sPathEcfRegistry, sArqEcfDefault, PathArquivo, ArqDownTXT );

  If not(sRetorno = '0') then
    MessageDlg( sMsgErr, mtError,[mbOK],0);

  Result := sRetorno ;
end;

//------------------------------------------------------------------------------
function TImpFiscalSigtron.GeraRegTipoE(sTipo, sInicio, sFinal, sRazao,  sEnd, sBinario : AnsiString):AnsiString;

begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
end;

//------------------------------------------------------------------------------
function CapturaBaseISSRedZ : AnsiString;
var
  sLinhaISS,sAliquotas,sIss,
  sVlrBISS, sLinhaAux,sAImp: AnsiString;
  iRet,iModelo,iIndex: Integer;
  aRetorno : array of AnsiString;
  fAImp : Real;
begin
  iRet   := 0;
  iIndex := 0;
  Result := '';

  sLinhaISS := Space( 631 );
  iRet := fFuncDaruma_FI_DadosUltimaReducao(sLinhaISS); // Comando usado para impressoras termica e matriciais

  //sLinhaISS := Space( 1164 ); - O Comando abaixo só pode ser utilizado para impressoras térmicas
  //iRet := fFuncDaruma_FIMFD_RetornaInformacao( '140' , sLinhaISS ); //Comando retorna informações provindas da última redução Z efetuada

  TrataRetornoDaruma( iRet );

  if iRet = 1 then
  begin
    sLinhaISS := Copy( sLinhaISS,  118 , 224 );
    //sLinhaISS := Copy( sLinhaISS , 130 , 224 ); //captura somente o texto que traz os valores tributados de ICMS e ISS  - Usar com o comando para impressoras térmicas

    sAliquotas := Space( 300 );
    fFuncDaruma_FI_LerAliquotasComIndice( sAliquotas );
    sAliquotas := Trim( sAliquotas );

    while Length(sAliquotas) > 0 do
    begin
     If Copy( sAliquotas, 1, 1 ) = 'S' then   // Separa só as aliquotas de ISS
     begin
       SetLength( aRetorno , Length(aRetorno) + 1);
       sIss     := Copy( sAliquotas , 3 , 4 );
       sVlrBISS := Copy( sLinhaISS , 1 , 14 );
       Insert('.',sVlrBISS,Length(sVlrBISS)-1);

       fAImp := (StrToFloat( sIss ) / 100 )  * ( StrToFloat( sVlrBISS ) /100 );
       sAImp := FloatToStr( fAImp );
       sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;

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

     sAliquotas := Copy( sAliquotas, 7 , Length(sAliquotas) );
     sLinhaISS  := Copy( sLinhaISS , 15 , Length(sLinhaISS) );
    end;

  end;

  if Length(aRetorno) > 0 then
  begin
    For iIndex := 0 to Length(aRetorno)-1 do
     Result := Result + aRetorno[iIndex] + ';'
  end
  else
     Result := '00000000000.00'
end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma600_v0103.GeraArquivoMFD(cDadoInicial, cDadoFinal,
  cTipoDownload, cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica,
  cChavePrivada: AnsiString; iUnicoArquivo: integer): AnsiString;

Const sNomeArqOrigem = 'AtocotepeMF_Data.TXT';

Var
  iRet: Integer;   // Retorno da dll
  sPath: AnsiString; //Caminho onde o ECF gera os arquivos
  sNumSerie2,sNomeArq, sArqOrigem, sArqDestino : AnsiString;
  sStringList: TStringlist;
begin
  {Pega número de série para compor o nome padrão do arquivo exigido pelo PAF-ECF}
  sNumSerie2 := PegaSerie;
  sNumSerie2 := Copy(sNumSerie2,3,Length(sNumSerie2)-2);

  {Configura o diretório onde serão gerados os arquivos pelo ECF}
  iRet := fFuncDaruma_Registry_AlterarRegistry('AtoCotepe', 'Path',sPathEcfRegistry); //PathArquivo
  TrataRetornoDaruma( iRet, 0 );

  {Processa por data}
  If cTipoDownload = 'D' Then
  Begin
    {Formata valores}
    cDadoInicial  := FormatDateTime('ddMMyyyy',StrToDate(cDadoInicial));
    cDadoFinal    := FormatDateTime('ddMMyyyy',StrToDate(cDadoFinal));

    {Formata nome do Arquivo}
    //sNomeArq  := sNumSerie2 + '_' + Copy(cDadoInicial,1,Length(cDadoInicial)-4) + '12_' + Copy(cDadoFinal,1,Length(cDadoFinal)-4) + '12.TXT';
    sNomeArq := 'AtocotepeMF_Data.TXT';

    //iRet :=  fFuncDaruma_FIMFD_GerarAtoCotepePafData(cDadoInicial, cDadoFinal);
    iRet :=  fFuncDaruma_FIMFD_GerarMFPAF_Data(cDadoInicial, cDadoFinal);
    TrataRetornoDaruma( iRet , 0 );

    //Comando da DarumaFramework.dll
    (*iRet := fFunceBuscarPortaVelocidade_ECF_Daruma();
    TrataRetornoDaruma( iRet , 0);
    If iRet = 1 then
    begin
      {Executa o método que irá gerar o arquivo(ATO_MF_DATA) por Data}
      iRet := fFuncrGerarRelatorio_ECF_Daruma('MF','DATAM',cDadoInicial,cDadoFinal);
      TrataRetornoDaruma( iRet, 0 );
    end; *)
  End Else   {Processa por COO}
  Begin
    {Formata nome do Arquivo}
    //sNomeArq  := sNumSerie2 + '_' + cDadoInicial + '_' + cDadoFinal + '.TXT';
    sNomeArq := 'AtocotepeMF_COO.TXT';

    iRet :=  fFuncDaruma_FIMFD_GerarAtoCotepePafCOO(cDadoInicial , cDadoFinal);
    TrataRetornoDaruma( iRet , 0 );

    //Comando da DarumaFramework.dll    
    (*iRet := fFunceBuscarPortaVelocidade_ECF_Daruma();
    TrataRetornoDaruma( iRet , 0);
    If iRet = 1 then
    begin
      {Executa o método que irá gerar o arquivo(ATO_MF_DATA) por Data}
      iRet := fFuncrGerarRelatorio_ECF_Daruma('MF','CRZ',cDadoInicial,cDadoFinal);
      TrataRetornoDaruma( iRet, 0 );
    end; *)
  End;

  {Não Remove a assinatura -- não traz assinado}
  If iRet = 1 Then
  Begin
    sArqDestino := PathArquivo+sNomeArq;
    sArqOrigem  := sPathEcfRegistry + sNomeArqOrigem;

    //Caso exista, remove arquivo gerado com o mesmo nome
    If FileExists(sArqDestino) Then
       DeleteFile(sArqDestino);

    CopyFile(pChar(sArqOrigem),pChar(sArqDestino),False)
  End;

   If iRet = 1 then
       Result := '0'
   Else
       Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDaruma2000.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString;

   function RetornaNomeTot(sRelGerenciais : AnsiString ; PosTotalizador : Integer) : AnsiString;
   var
     sRet,sAux : AnsiString;
     nQtdeVirg,nPosVirg: Integer;
   begin
     nPosVirg  := 0;
     nQtdeVirg := 0;
     sAux      := sRelGerenciais ;

     If PosTotalizador > 1 then
     begin
        while nQtdeVirg < (PosTotalizador-1) do
        begin
         nPosVirg := Pos(',',sAux);
         sAux := StringReplace(sAux,',','|',[]);
         Inc(nQtdeVirg);
        end;
        sRet := Copy(sAux,nPosVirg+1,(Pos(',',sAux)-1)-nPosVirg);
     end
     else
     begin
      nPosVirg := Pos(',',sAux);  
      sRet := Copy(sAux,1,nPosVirg-1);
     end;

     Result := sRet;
   end;

Var
  iRet,i,nPos: Integer;
  cTextoImpAux, sRelGerenciais, cNomeTot : AnsiString;
  bImprime        : Boolean;
  sLista          : TStringList;
begin
  //*******************************************************************************
  // Inicialização das variaveis
  //*******************************************************************************
  Result      := '1';
  bImprime    := False;
  sLista      := TStringList.Create;

  SetLength( sRelGerenciais , 321 );
  iRet := fFuncDaruma_FIMFD_VerificaRelatoriosGerenciais( sRelGerenciais );
  TrataRetornoDaruma( iRet );

  if iRet = 1 then
  begin
    cIndTotalizador :=  Trim(cIndTotalizador);
    Val(cIndTotalizador,i,nPos);

    //Valida relatório gerencial pelo nome
    If not (i > 0)
    then i := 1; //caso haja algum problema manda o gerencial padrão

    If i > 0 then
    begin
     bImprime := True;
     cNomeTot := RetornaNomeTot( sRelGerenciais , i );
    end;
  end;

  if bImprime then
  begin
      sLista.Clear;
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
           GravaLog(' -> AbreRelatorioGerencial' );
           iRet := fFuncDaruma_FIMFD_AbreRelatorioGerencial( pChar(cNomeTot) );
           GravaLog(' <- AbreRelatorioGerencial: ' + IntToStr(iRet));

           TrataRetornoDaruma( iRet );
           If (iRet = 0) then
           Begin
             Result := '1';
             Exit;
           End;

           GravaLog(' -> Daruma_FI_RelatorioGerencial' );

           For nPos := 0 to sLista.Count-1 do
              iRet := fFuncDaruma_FI_RelatorioGerencial( pChar(sLista.Strings[nPos]));

           GravaLog(' <- Daruma_FI_RelatorioGerencial: ' + IntToStr(iRet) );

           TrataRetornoDaruma( iRet );
           If (iRet = 0) then
           Begin
             Result := '1';
             Exit;
           End;

          GravaLog(' -> FechaRelatorioGerencial' );
          iRet:= fFuncDaruma_FI_FechaRelatorioGerencial;
          GravaLog(' <- FechaRelatorioGerencial : ' + IntToStr(iRet) );
          TrataRetornoDaruma( iRet );

          If iRet = 1
          then Result := '0'
          Else Result := '1';
      End;

      //*******************************************************************************
      // Mostrar mensagem de erro se necessário
      //*******************************************************************************
      If Result = '1' then
        TrataRetornoDaruma( iRet );
  end
  else
  begin
    //*******************************************************************************
    // Mostrar mensagem de erro caso os totalizadores não tenham sido encontrados
    //*******************************************************************************  
    LjMsgDlg('O Relatório Gerencial ' + Trim(cIndTotalizador) + ' não existem no ECF. ' );
    Result := '1';
  end;

end;

//------------------------------------------------------------------------------
function TImpFiscalDarumaMatch.ReducaoZ( MapaRes : AnsiString ): AnsiString;
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
  iRet, i, iSubTrib: Integer;
  sData, sHora : AnsiString;
  aRetorno, aFile : array of AnsiString;
  sRetorno, sAliqISS : AnsiString;
  Reg:  TRegistry;
  sPathDaruma : AnsiString;
  fFile : TextFile;
  sFile, sLinha, sFlag, sValDeb : AnsiString;
  rValDeb : Real;
begin
 Result := '1';
 If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    iRet := fFuncDaruma_FI_DataMovimento(aRetorno[ 0]);
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := PDV;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0' then
      aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));


    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    iRet := fFuncDaruma_FI_NumeroReducoes( aRetorno[3] );
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    iRet := fFuncDaruma_FI_GrandeTotal( aRetorno[ 4] );
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    iRet := fFuncDaruma_FI_NumeroCupom( aRetorno[ 6] );
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[ 5] := aRetorno[ 6];

    aRetorno[ 7] := Space (14);                         //**** Valor do Cancelamento ****//
    iRet := fFuncDaruma_FI_Cancelamentos( aRetorno[ 7] );
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    aRetorno[ 9] := Space (14);                         //**** Desconto ****//
    iRet := fFuncDaruma_FI_Descontos( aRetorno[ 9] );
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    sRetorno := Space(445);
    iRet := fFuncDaruma_FI_VerificaTotalizadoresParciais(sRetorno);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[11] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[12] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** Nao tributado Nao Tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[10] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);

    aRetorno[15] := FormataTexto('0',16, 0, 1);                         // --outros recebimentos--


    aRetorno[17] := Space(4);
    iRet := fFuncDaruma_FIR_RetornaCRO( aRetorno[17] );
    aRetorno[17] := Copy( aRetorno[ 17 ], 2, Length( aRetorno[ 17 ] ) );

    aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS
    aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS
    aRetorno[20]:= '00';                                         // QTD DE Aliquotas


 end;

  sData := DateToStr(Date);
  sHora := TimeToStr(Time);

  //altera o tempo de espera para o modelo MATCH 2
  iRet := fFuncDaruma_Registry_AlterarRegistry('ECF','TempoEsperaLeitura','30000');
  TrataRetornoDaruma( iRet );

  if iRet = 1
  then WriteLog('sigaloja.log', DateTimeToStr(Now) + '<- Daruma_Registry_AlterarRegistry : alterado tempo de espera')
  else WriteLog('sigaloja.log', DateTimeToStr(Now) + '<- Daruma_Registry_AlterarRegistry : sem sucesso na execução');

  If LogDLL
  then WriteLog('sigaloja.log', DateTimeToStr(Now) + '-> Daruma_FI_ReducaoZ ');

  iRet := fFuncDaruma_FI_ReducaoZ( sData, sHora );
  TrataRetornoDaruma( iRet );

  If LogDLL
  then WriteLog('sigaloja.log', DateTimeToStr(Now) + '<- Daruma_FI_ReducaoZ : ' + IntToStr(iRet));

  If iRet = 1 then
  begin
    //Retorna para o conteúdo anterior
    iRet := fFuncDaruma_Registry_AlterarRegistry('ECF','TempoEsperaLeitura','150');
    TrataRetornoDaruma( iRet );

    if iRet = 1
    then WriteLog('sigaloja.log', DateTimeToStr(Now) + '<- Daruma_Registry_AlterarRegistry : alterado tempo de espera')
    else WriteLog('sigaloja.log', DateTimeToStr(Now) + '<- Daruma_Registry_AlterarRegistry : sem sucesso na execução');

        If Trim(MapaRes) = 'S' then
        begin
            //******************************************************************
            //* Pega o caminho no registry do windows em qual path será gravado
            //* o arquivo RETORNO.TXT
            //******************************************************************
            sPathDaruma := 'C:\';
            Reg := TRegistry.Create;
            try
              Reg.RootKey := HKEY_LOCAL_MACHINE;
              if Reg.OpenKey('\Software\Daruma\ECF\', True)
              then sPathDaruma := Reg.ReadString( 'Path' );
            finally
              Reg.CloseKey;
              Reg.Free;
            end;

            //******************************************************************
            //* Chama a funcao para pegar as informacoes do MapaResumo
            //******************************************************************
            iRet := fFuncDaruma_FI_MapaResumo();
            TrataRetornoDaruma( iRet );
            If iRet = 1 then
            begin

                sFile :=  sPathDaruma + 'RETORNO.TXT' ;
                If FileExists(sFile) then
                begin
                    AssignFile(fFile, sFile);
                    Reset(fFile);
                    sFlag:='';
                    ReadLn(fFile, sLinha);

                    iSubTrib := 0;
                    i := 0;

                    While not Eof(fFile) do
                    Begin
                      If Trim( sLinha ) <> '' then
                      Begin
                        SetLength( aFile, Length(aFile) + 1 );
                        aFile[ i ] := sLinha;
                        ReadLn(fFile, sLinha);
                        i := i+1;
                      End
                      Else
                        ReadLn(fFile, sLinha);
                    End;

                    CloseFile(fFile);
                    For i := 0 to Length( aFile ) - 1 Do
                    Begin
                        If iSubTrib = 1 then iSubTrib := 2;

                        sLinha := aFile[ i ];
                        sLinha := TrataLinha(sLinha);
                        if ( Pos( 'Venda LÝquida..........:',sLinha ) >0 ) Or
                           ( Pos( 'Venda Líquida..........:',sLinha ) >0 ) then  // Venda Liquida
                            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida

                        if ( Pos('ISS....................:',sLinha)>0) then  // Totais ISS
                        begin
                          sAliqISS := CapturaBaseISSRedZ;     //Retorna os valores gastos de ISS separados por valor de Base
                        //                      ' Valor '  ' Imposto Debitado
                            aRetorno[16] :=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),14,2,1,'.')+
                                        ' 00000000000.00' + ';' + sAliqISS;
                        end;

                        if ( Pos('SubstituiþÒo Tributßria:',sLinha)>0) Or
                           ( Pos('Substituição Tributária:',sLinha)>0) then  // Totais ISS
                            iSubTrib := 1;

                        if iSubTrib = 2 then
                        begin
                            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);

                            // Aliquota '  ' Valor '  ' Imposto Debitado
                            SetLength( aRetorno, Length(aRetorno)+1 );
                            rValDeb := StrToFloat( Copy( sLinha, 1, 4 ) ) / 10000;
                            rValDeb := rValDeb * StrToFloat( StrTran( Trim( StrTran( Copy( sLinha, Length( sLinha ) - 14, 15 ),'.','' ) ), ',', '.' ) );
                            sValDeb := FloatToStr( rValDeb );
                            sValDeb := StrTran( sValDeb, ',', '.' );
                            sValDeb := FormataTexto( sValDeb, 14, 2, 1, '.' );
                            aRetorno[High(aRetorno)] := 'T'+Copy(sLinha,1,2) +','+Copy(sLinha,3,2) +' ' + FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),14,2,1,'.')+ ' ' + sValDeb;
                        end;

                    End;

                    Result := '0|';
                    For i:= 0 to High(aRetorno) do
                         Result := Result + aRetorno[i]+'|';

                end;
            end;
        end
        else
            Result := '0|';
    end
    else
       Result := '1';
end;


function TImpFiscalSigtron.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

(*initialization
  RegistraImpressora('SIGTRON FS345 - V. 01.00'   , TImpFiscalSigtron          ,'BRA',' ');
  RegistraImpressora('SIGTRON FS345 - V. 01.20'   , TImpFiscalSigtron120       ,'BRA',' ');
  RegistraImpressora('DARUMA FS345 -  V. 01.20'   , TImpFiscalDaruma345        ,'BRA','080504');
  RegistraImpressora('DARUMA FS345 -  V. 01.22'   , TImpFiscalDaruma345        ,'BRA','080504');
  RegistraImpressora('DARUMA FS2000 - V. 01.00'   , TImpFiscalDaruma2000       ,'BRA','080101');
  RegistraImpressora('DARUMA FS2000 - V. 01.02'   , TImpFiscalDaruma2000       ,'BRA','080103');
  RegistraImpressora('DARUMA FS600 - V. 01.02.00' , TImpFiscalDaruma600_v0102  ,'BRA','080802');
  RegistraImpressora('DARUMA FS600 - V. 01.03.00' , TImpFiscalDaruma600_v0103  ,'BRA','080803');
  RegistraImpressora('DARUMA FS600 - V. 01.04.00' , TImpFiscalDaruma600_v0103  ,'BRA','080804');
  RegistraImpressora('DARUMA FS600 - V. 01.05.00' , TImpFiscalDaruma600_v0103  ,'BRA','080805');
  RegistraImpressora('DARUMA FS700 H - V. 01.01.00' , TImpFiscalDaruma600_v0103  ,'BRA','081201');
  RegistraImpressora('DARUMA FS700 M - V. 01.01.00' , TImpFiscalDaruma600_v0103  ,'BRA','081101');
  RegistraImpressora('DARUMA FS700 L - V. 01.00.00' , TImpFiscalDaruma600_v0103  ,'BRA','081001');
  RegistraImpressora('DARUMA FS700 MATCH - V. 01.00.00' , TImpFiscalDarumaMatch  ,'BRA','081401'); //Geral para as todas as MATCHS : 1,2 e 3
  RegistraImpressora('DARUMA FS2100 - V. 01.02.00', TImpFiscalDaruma2100       ,'BRA','080202');
  RegistraImpressora('SIGTRON FS2000 - V. 01.00'  , TImpFiscalSigtron2000      ,'BRA',' ');
  RegistraImpCheque ('SIGTRON FS2000', TImpChequeSigtron2000                   ,'BRA');
  RegistraImpCheque ('DARUMA FS2100', TImpCheqDaruma2100                       ,'BRA');
  RegistraImpCheque ('DARUMA FS2000 V1.00', TImpCheqDaruma2000                 ,'BRA');
  RegistraImpCheque ('DARUMA FS2000 V1.02', TImpCheqDaruma2000                 ,'BRA');*)
//----------------------------------------------------------------------------
end.
