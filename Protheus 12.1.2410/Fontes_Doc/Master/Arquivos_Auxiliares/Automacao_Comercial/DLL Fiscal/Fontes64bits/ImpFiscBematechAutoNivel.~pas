unit ImpFiscBematechAutoNivel;

interface

uses
  Dialogs, ImpFiscMain, ImpCheqMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms, CMC7Main, StdCtrls, ShellApi, FileCtrl;

Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Bematech - DLL de Alto Nível
///
  TImpBematech = class(TImpressoraFiscal)
  private
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function AbreEcf:String; override;
    function FechaEcf:String; override;
    function LeituraX:String; override;
    function ReducaoZ(MapaRes:String):String; override;
    function RedZDado(MapaRes:String):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function PegaPDV:String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function CancelaCupom(Supervisor:String):String; override;
    function LeCondPag:String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String; Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function Suprimento( Tipo:Integer; Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function Gaveta:String; override;
    function RelatorioGerencial( Texto:String ;Vias:Integer;ImgQrCode: String): String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;
    function PegaSerie:String; override;
    function GravaCondPag( Condicao:String ):String; override;
    function ImpostosCupom(Texto: String): String; override;
    function TotalizadorNaoFiscal( Numero,Descricao:String ):String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function HorarioVerao( Tipo:String ):String; override;
    procedure AlimentaProperties; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; Override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : String ):String; Override;
    function Retorna_Informacoes( iRetorno : Integer ): String;
    function LeTotNFisc:String; Override;
    function DownMF( sTipo, sInicio, sFinal : String ):String; override;
    function ImpTxtFis(Texto : String) : String; override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
  end;

  TImpBematech40 = class(TImpBematech)
  private
  public
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
  end;

  TImpBematech2000 = class(TImpBematech)
  private
  public
    // Informação retirada da documentação da BEMAFI32.DLL
    //* IMPORTANTE *
    //Não é necessário alterar o software para trabalhar com a impressora fiscal térmica (MFD),
    //pois todas as funções utilizadas na impressora fiscal matricial são compatíveis,
    //basta apenas ligar a chave "Impressora", na seção MFD (Impressora=1) e executar a aplicação.
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function ReducaoZ(MapaRes:String):String; override;
    function PegaSerie:String; override;
    function TextoNaoFiscal( Texto:String; Vias:Integer ):String;override;
    function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; Override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String; Override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String; override;
    procedure AlimentaProperties; override;
    function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String ) : String; Override;
    function GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: integer; cChavePublica: string; cChavePrivada: string; iUnicoArquivo: integer ): String; override;
    function LeTotNFisc:String; override;
    function DownMF( sTipo, sInicio, sFinal : String ):String; override;
    function RedZDado(MapaRes:String):String; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
    function AbreCNF(CPFCNPJ, Nome, Endereco : String): String; Override;
    function RecCNF( IndiceTot , Valor, ValorAcresc,ValorDesc : String): String; Override;
    function PgtoCNF( FrmPagto , Valor, InfoAdicional, ValorAcresc,ValorDesc : String): String; Override;
    function FechaCNF( Mensagem : String): String; Override;
  end;

  TImpBematech2000_0302 = class(TImpBematech2000)
  public
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String; override;
  end;

  TImpBematech2100 = class(TImpBematech2000_0302)
  public
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String; Override;
    function GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: integer; cChavePublica: string; cChavePrivada: string; iUnicoArquivo: integer ): String; override;
  end;

  TImpBematech2100_0101 = class(TImpBematech2100)
  public
    function ReducaoZ(MapaRes:String):String; override;
  end;

  TImpBematech3000 = class(TImpBematech2100)
  public
    function ReducaoZ(MapaRes:String):String; override;
  end;

  TImpBematech6000 = class(TImpBematech3000)
  public
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function ReducaoZ(MapaRes:String):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : String ):String; Override;
    function GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: integer;
                                 cChavePublica: string; cChavePrivada: string; iUnicoArquivo: integer ): String; override;
  end;

  TImpBematech7000 = class(TImpBematech6000)
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function ReducaoZ(MapaRes:String):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : String ):String; Override;
    function GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: integer;
                                 cChavePublica: string; cChavePrivada: string; iUnicoArquivo: integer ): String; override;
  end;

  TImpBematech4000 = class(TImpBematech7000)
  public
   function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
   function ReducaoZ(MapaRes:String):String; override;
  end;

  TImpBematech4200 = class(TImpBematech4000)
  public
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function ReducaoZ( MapaRes: String ) : String; override;
    procedure AlimentaProperties; Override;
    function Suprimento( Tipo:Integer; Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function AbreCNF(CPFCNPJ, Nome, Endereco : String): String; Override;
    function RecCNF( IndiceTot , Valor, ValorAcresc,ValorDesc : String): String; Override;
    function FechaCNF( Mensagem : String): String; Override;
    function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String ) : String; Override;
    function DownloadMFD( sTipo, sInicio, sFinal: String ):String; Override;
    function PegaCupom(Cancelamento:String):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : String ):String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String; Override;
    function RedZDado(MapaRes:String):String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
  end;

  TImpYanco8000 = class(TImpBematech)
  private
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function PegaPDV:String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function ReducaoZ(MapaRes:String):String; override;
    function CancelaCupom(Supervisor:String):String; override;
  end;

  TImpBematechMP25FI = class(TImpBematech)
  private
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function TextoNaoFiscal( Texto:String; Vias:Integer ):String; override;
    function ReducaoZ(MapaRes:String):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function PegaSerie:String; override;
    function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    procedure AlimentaProperties; override;    
  end;

  TImpBematechMP25FIR = class(TImpBematech)
  private
  public
    function AbreCupomRest(Mesa, Cliente: String):String; override;
    function RegistraItemRest( Mesa, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: String): String; override;
    function CancelaItemRest( Mesa,Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: String): String; override;
    function ConferenciaMesa( Mesa, Acres, Desc: String):String; override;
    function ImprimeCardapio:String; override;
    function LeCardapio:String; override;
    function LeMesasAbertas:String; override;
    function RelatMesasAbertas(Tipo: String):String; override;
    function LeRegistrosVendaRest(Mesa: String):String; override;
    function FechaCupomMesa( Pgto, Acres, Desc, Mensagem:String ): String; override;
    function FechaCupContaDividida( NumeroCupons, Acres, Desc, Pagamento, ValorCliente, Cliente: String): String; override;
    function TransfMesas( Origem, Destino: String): String; override;
    function TransfItem( MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc, MesaDestino: String): String; override;
  public
  end;

  ////////////////////////////////////////////////////////////////////////////////
  ///  Impressora de Cheque Bematech
  TImpCheqBematech = class(TImpressoraCheque)
  public
    function Abrir( aPorta:String ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar(aPorta:String ): Boolean; override;
    function StatusCh( Tipo:Integer ):String; override;
  end;

  // MP 6000TH - Impressora de Cheque
  TImpCheqBem6000 = class(TImpCheqBematech)
  public
    function Abrir( aPorta:String ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
  end;

  // MP 7000TH - Impressora de Cheque
  TImpCheqBem7000 = class(TImpCheqBem6000)
  public
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
  end;
////////////////////////////////////////////////////////////////////////////////
  TCMC7_BEMA = class( TCMC7 )
  public
    function Abrir( aPorta, sMensagem: String  ):String; Override;
    function LeDocumento:String; Override;
    function Fechar:String; Override;
  end;

  // MP 6000TH - Leitor de CMC7
  TCmc7Bem6000 = class(TCMC7_BEMA)
  public
    function Abrir( aPorta, sMensagem: String  ):String; Override;
  end;

Function ArqIniBematech( sPorta, sModeloImp, sImpressora:String ):Boolean;
Function OpenBematech( sPorta:String; lEstendido:Boolean = False ):String;
Function CloseBematech : String;
Function TrataRetornoBematech( var iRet:Integer; lEstendido:Boolean = False ):String;
Function MsgErroBematech( iRet:Integer ):String;
Function Status_Impressora( lMensagem:Boolean; lEstendido:Boolean = False ): Integer;
Function Verifica_Status( lMensagem:Boolean; lEstendido:Boolean = False ): Integer;
Function Retorno_Estendido( iST3 : Integer ): String;
Function TrataTags( Mensagem : String ) : String;
Procedure CancelaCNF;
Function ValidaFrmPgto4200( var Condicao : String; var iIndice : Integer): Boolean;

//----------------------------------------------------------------------------
implementation

{ Constantes globais  }
Const
  sArqIniBema  = 'BEMAFI32.INI';
  sArqDllBema  = 'BEMAFI32.DLL';
  sArqRetBema  = 'RETORNO.TXT';
  sArqBemaMfd1 = 'BEMAMFD.DLL';
  sArqBemaMfd2 = 'BEMAMFD2.DLL';

  sArqDownMFD  = 'DOWNLOAD.MFD';
  sTagNegritoIni = Chr(27)+Chr(69);
  sTagNegritoFim = Chr(27)+Chr(70);
  sTagItalicoIni = Chr(27)+Chr(52);
  sTagItalicoFim = Chr(27)+Chr(53);
  sTagCondensadoIni = Chr(27)+Chr(15);
  sTagCondensadoFim = Chr(18);
  sTagExpandidoIni = Chr(27)+Chr(87)+Chr(01);
  sTagExpandidoFim = Chr(27)+Chr(87)+Chr(48);
  sTagDuplaAltura = Chr(27)+Chr(86);

var
  fHandle  : THandle; //'BEMAFI32.DLL'
  fHandle1 : THandle; //'BEMAMFD.DLL'
  fHandle2 : THandle; //'BEMAMFD2.DLL'

  // Funções de Inicialização ////////////////////////////////////////////////////
  fFuncBematech_FI_AlteraSimboloMoeda                 : function (SimboloMoeda: String): Integer; StdCall;
  fFuncBematech_FI_ProgramaAliquota                   : function (Aliquota: String; ICMS_ISS: Integer): Integer; StdCall;
  fFuncBematech_FI_ProgramaHorarioVerao               : function ():Integer; StdCall;
  fFuncBematech_FI_NomeiaDepartamento                 : function (Indice: Integer; Departamento: String): Integer; StdCall;
  fFuncBematech_FI_ProgramaArredondamento             : function ():Integer; StdCall;
  fFuncBematech_FI_LinhasEntreCupons                  : function (Linhas: Integer): Integer; StdCall;
  fFuncBematech_FI_EspacoEntreLinhas                  : function (Dots: Integer): Integer; StdCall;
  fFuncBematech_FI_ForcaImpactoAgulhas                : function (ForcaImpacto: Integer): Integer; StdCall;
  fFuncBematech_FI_NomeiaTotalizadorNaoSujeitoIcms    : function (Indice: Integer; Totalizador: String): Integer; StdCall;

  // Funções do Cupom Fiscal /////////////////////////////////////////////////////
  fFuncBematech_FI_AbreCupom                          : function (CGC_CPF: String): Integer; StdCall;
  fFuncBematech_FI_AbreCupomMFD                       : function (CGC_CPF, Nome, Endereco : String): Integer; StdCall;
  fFuncBematech_FI_VendeItem                          : function (Codigo,Descricao,Aliquota,TipoQuantidade,Quantidade:String; CasasDecimais:Integer; ValorUnitario,TipoDesconto,Desconto:String): Integer; StdCall;
  fFuncBematech_FI_VendeItemDepartamento              : function (Codigo: String; Descricao: String; Aliquota: String; ValorUnitario: String; Quantidade: String; Acrescimo: String; Desconto: String; IndiceDepartamento: String; UnidadeMedida: String): Integer; StdCall;
  fFuncBematech_FI_CancelaItemAnterior                : function ():Integer; StdCall;
  fFuncBematech_FI_CancelaItemGenerico                : function (NumeroItem: String): Integer; StdCall;
  fFuncBematech_FI_CancelaCupom                       : function ():Integer; StdCall;
  fFuncBematech_FI_FechaCupomResumido                 : function (FormaPagamento: String; Mensagem: String): Integer; StdCall;
  fFuncBematech_FI_FechaCupom                         : function (FormaPagamento: String; AcrescimoDesconto: String; TipoAcrescimoDesconto: String; ValorAcrescimoDesconto: String; ValorPago: String; Mensagem: String): Integer; StdCall;
  fFuncBematech_FI_ResetaImpressora                   : function ():Integer; StdCall;
  fFuncBematech_FI_IniciaFechamentoCupom              : function (AcrescimoDesconto: String; TipoAcrescimoDesconto: String; ValorAcrescimoDesconto: String): Integer; StdCall;
  fFuncBematech_FI_EfetuaFormaPagamento               : function (FormaPagamento: String; ValorFormaPagamento: String): Integer; StdCall;
  fFuncBematech_FI_EfetuaFormaPagamentoDescricaoForma : function (FormaPagamento: string; ValorFormaPagamento: string; DescricaoFormaPagto: string ): integer; StdCall;
  fFuncBematech_FI_TerminaFechamentoCupom             : function (Mensagem: String): Integer; StdCall;
  fFuncBematech_FI_EstornoFormasPagamento             : function (FormaOrigem: String; FormaDestino: String; Valor: String): Integer; StdCall;
  fFuncBematech_FI_UsaUnidadeMedida                   : function (UnidadeMedida: String): Integer; StdCall;
  fFuncBematech_FI_AumentaDescricaoItem               : function (Descricao: String): Integer; StdCall;
  fFuncBematech_FI_ContadorCupomFiscalMFD             : function (CuponsEmitidos: String): Integer; StdCall;

  // Funções dos Relatórios Fiscais //////////////////////////////////////////////
  fFuncBematech_FI_LeituraX                             : function ():Integer; StdCall;
  fFuncBematech_FI_ReducaoZ                             : function (Data: String; Hora: String): Integer; StdCall;
  fFuncBematech_FI_RelatorioGerencial                   : function (Texto: String): Integer; StdCall;
  fFuncBematech_FI_FechaRelatorioGerencial              : function ():Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalData             : function (DataInicial: String; DataFinal: String): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalReducao          : function (ReducaoInicial: String; ReducaoFinal: String): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalSerialData       : function (DataInicial: String; DataFinal: String): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalSerialReducao    : function (ReducaoInicial: String; ReducaoFinal: String): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalDataMFD          : function (DataInicial: String; DataFinal: String; cTipo:String): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalReducaoMFD       : function (ReducaoInicial: String; ReducaoFinal: String; cTipo:String): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalSerialDataMFD    : function (DataInicial: String; DataFinal: String; cTipo:String): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalSerialReducaoMFD : function (ReducaoInicial: String; ReducaoFinal: String; cTipo:String): Integer; StdCall;
  fFuncBematech_FI_AbreRelatorioGerencialMFD            : function (cIndice : String): Integer; StdCall;
  fFuncBematech_FI_VerificaRelatorioGerencialMFD        : function (Relatorios : String) : Integer; StdCall;
  fFuncBematech_FI_UsaRelatorioGerencialMFD             : function (Texto : String) : Integer; StdCall;
  fFuncBematech_FI_CodigoBarrasITFMFD                   : function (Codigo: String) : Integer; StdCall;
  fFuncBematech_FI_ConfiguraCodigoBarrasMFD             : function ( Altura , Largura, Posicao, Fonte, Margem : Integer): Integer; StdCall;

  // Funções das Operações Não Fiscais ///////////////////////////////////////////
  fFuncBematech_FI_RecebimentoNaoFiscal               : function (IndiceTotalizador: String; Valor: String; FormaPagamento: String): Integer; StdCall;
  fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado  : function (FormaPagamento: String; Valor: String; NumeroCupom: String): Integer; StdCall;
  fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado   : function (Texto: String): Integer; StdCall;
  fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado : function ():Integer; StdCall;
  fFuncBematech_FI_Sangria                            : function (Valor: String): Integer; StdCall;
  fFuncBematech_FI_Suprimento                         : function (Valor: String; FormaPagamento: String): Integer; StdCall;

  // Funções de Informações da Impressora ////////////////////////////////////////
  fFuncBematech_FI_NumeroSerie                        : function (NumeroSerie: String): Integer; StdCall;
  fFuncBematech_FI_NumeroSerieMFD                     : function (NumeroSerie: String): Integer; StdCall;
  fFuncBematech_FI_SubTotal                           : function (SubTotal: String): Integer; StdCall;
  fFuncBematech_FI_NumeroCupom                        : function (NumeroCupom: String): Integer; StdCall;
  fFuncBematech_FI_LeituraXSerial                     : function ():Integer; StdCall;
  fFuncBematech_FI_VersaoFirmware                     : function (VersaoFirmware: String): Integer; StdCall;
  fFuncBematech_FI_VersaoFirmwareMFD                  : function (VersaoFirmware: String): Integer; StdCall;
  fFuncBematech_FI_CGC_IE                             : function (CGC: String; IE: String): Integer; StdCall;
  fFuncBematech_FI_GrandeTotal                        : function (GrandeTotal: String): Integer; StdCall;
  fFuncBematech_FI_Cancelamentos                      : function (ValorCancelamentos: String): Integer; StdCall;
  fFuncBematech_FI_Descontos                          : function (ValorDescontos: String): Integer; StdCall;
  fFuncBematech_FI_NumeroOperacoesNaoFiscais          : function (NumeroOperacoes: String): Integer; StdCall;
  fFuncBematech_FI_NumeroCuponsCancelados             : function (NumeroCancelamentos: String): Integer; StdCall;
  fFuncBematech_FI_NumeroIntervencoes                 : function (NumeroIntervencoes: String): Integer; StdCall;
  fFuncBematech_FI_NumeroReducoes                     : function (NumeroReducoes: String): Integer; StdCall;
  fFuncBematech_FI_NumeroSubstituicoesProprietario    : function (NumeroSubstituicoes: String): Integer; StdCall;
  fFuncBematech_FI_UltimoItemVendido                  : function (NumeroItem: String): Integer; StdCall;
  fFuncBematech_FI_ClicheProprietario                 : function (Cliche: String): Integer; StdCall;
  fFuncBematech_FI_NumeroCaixa                        : function (NumeroCaixa: String): Integer; StdCall;
  fFuncBematech_FI_NumeroLoja                         : function (NumeroLoja: String): Integer; StdCall;
  fFuncBematech_FI_SimboloMoeda                       : function (SimboloMoeda: String): Integer; StdCall;
  fFuncBematech_FI_MinutosLigada                      : function (Minutos: String): Integer; StdCall;
  fFuncBematech_FI_MinutosImprimindo                  : function (Minutos: String): Integer; StdCall;
  fFuncBematech_FI_VerificaModoOperacao               : function (Modo: string): Integer; StdCall;
  fFuncBematech_FI_VerificaEpromConectada             : function (Flag: String): Integer; StdCall;
  fFuncBematech_FI_FlagsFiscais                       : function (Var Flag: Integer): Integer; StdCall;
  fFuncBematech_FI_ValorPagoUltimoCupom               : function (ValorCupom: String): Integer; StdCall;
  fFuncBematech_FI_DataHoraImpressora                 : function (Data: String; Hora: String): Integer; StdCall;
  fFuncBematech_FI_ContadoresTotalizadoresNaoFiscais  : function (Contadores: String): Integer; StdCall;
  fFuncBematech_FI_VerificaTotalizadoresNaoFiscais    : function (Totalizadores: String): Integer; StdCall;
  fFuncBematech_FI_VerificaTotalizadoresNaoFiscaisMFD : function (Totalizadores: String): Integer; StdCall;
  fFuncBematech_FI_DataHoraReducao                    : function (Data: String; Hora: String): Integer; StdCall;
  fFuncBematech_FI_DataMovimento                      : function (Data: String): Integer; StdCall;
  fFuncBematech_FI_VerificaTruncamento                : function (Flag: string): Integer; StdCall;
  fFuncBematech_FI_Acrescimos                         : function (ValorAcrescimos: String): Integer; StdCall;
  fFuncBematech_FI_ContadorBilhetePassagem            : function (ContadorPassagem: String): Integer; StdCall;
  fFuncBematech_FI_VerificaAliquotasIss               : function (Flag: String): Integer; StdCall;
  fFuncBematech_FI_VerificaFormasPagamento            : function (Formas: String): Integer; StdCall;
  fFuncBematech_FI_VerificaRecebimentoNaoFiscal       : function (Recebimentos: String): Integer; StdCall;
  fFuncBematech_FI_VerificaRecebimentoNaoFiscalMFD    : function (Recebimentos: String): Integer; StdCall;
  fFuncBematech_FI_VerificaDepartamentos              : function (Departamentos: String): Integer; StdCall;
  fFuncBematech_FI_VerificaTipoImpressora             : function (Var TipoImpressora: Integer): Integer; StdCall;
  fFuncBematech_FI_VerificaTotalizadoresParciais      : function (Totalizadores: String): Integer; StdCall;
  fFuncBematech_FI_VerificaTotalizadoresParciaisMFD   : function (Totalizadores: String): Integer; StdCall;
  fFuncBematech_FI_RetornoAliquotas                   : function (Aliquotas: String): Integer; StdCall;
  fFuncBematech_FI_VerificaEstadoImpressora           : function (Var ACK: Integer; Var ST1: Integer; Var ST2: Integer): Integer; StdCall;
  fFuncBematech_FI_VerificaEstadoImpressoraMFD        : function (Var ACK: Integer; Var ST1: Integer; Var ST2: Integer;  Var ST3: Integer): Integer; StdCall;
  fFuncBematech_FI_DadosUltimaReducao                 : function (DadosReducao: String): Integer; StdCall;
  fFuncBematech_FI_DadosUltimaReducaoMFD              : function (DadosReducao: String): Integer; StdCall;
  fFuncBematech_FI_MonitoramentoPapel                 : function (Var Linhas: Integer): Integer; StdCall;
  fFuncBematech_FI_VerificaIndiceAliquotasIss         : function (Flag: String): Integer; StdCall;
  fFuncBematech_FI_VendaBruta                         : function (sVendaBruta: String) : Integer; Stdcall;
  fFuncBematech_FI_CNPJMFD                            : function (CNPJ: String): Integer; StdCall;
  fFuncBematech_FI_InscricaoEstadualMFD               : function ( IE : String): Integer; StdCall;
  fFuncBematech_FI_RegistrosTipo60                    : function ():Integer; StdCall;
  fFuncBematech_FI_ModeloImpressora                   : function (sModelo: String):Integer; StdCall;
  fFuncBematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional : function (sDtHrGrvUser, sDtHrGrvSb, sMemFisAdi : String):Integer; StdCall;
  fFuncBematech_FI_MarcaModeloTipoImpressoraMFD       : function (sMarca, sModelo, sTipo: String):Integer; StdCall;
  fFuncBematech_FI_FlagsFiscais3MFD                   : function (Flag: Integer): Integer; StdCall;
  fFuncBematech_FI_ContadorRelatoriosGerenciaisMFD    : function (sCRG: String):Integer; StdCall;
  fFuncBematech_FI_ContadorComprovantesCreditoMFD     : function (sCDC: String):Integer; StdCall;
  fFuncBematech_FI_DataHoraUltimoDocumentoMFD         : function (sDataHora: String):Integer; StdCall;

  // Funções de Autenticação e Gaveta de Dinheiro ////////////////////////////////
  fFuncBematech_FI_Autenticacao                       : function ():Integer; StdCall;
  fFuncBematech_FI_ProgramaCaracterAutenticacao       : function (Parametros: String): Integer; StdCall;
  fFuncBematech_FI_AcionaGaveta                       : function ():Integer; StdCall;
  fFuncBematech_FI_VerificaEstadoGaveta               : function (Var EstadoGaveta: Integer): Integer; StdCall;

  // Funções de Impressão de Cheques /////////////////////////////////////////////
  fFuncBematech_FI_ProgramaMoedaSingular              : function (MoedaSingular: String): Integer; StdCall;
  fFuncBematech_FI_ProgramaMoedaPlural                : function (MoedaPlural: String): Integer; StdCall;
  fFuncBematech_FI_CancelaImpressaoCheque             : function ():Integer; StdCall;
  fFuncBematech_FI_VerificaStatusCheque               : function (Var StatusCheque: Integer): Integer; StdCall;
  fFuncBematech_FI_ImprimeCheque                      : function (Banco: String; Valor: String; Favorecido: String; Cidade: String; Data: String; Mensagem: String): Integer; StdCall;
  fFuncBematech_FI_ImprimeChequeMFD                   : function (Banco: String; Valor: String; Favorecido: String; Cidade: String; Data: String; Mensagem: String; Verso, Linhas : String): Integer; StdCall;
  fFuncBematech_FI_ImprimeChequeMFDeX                 : function (Banco: String; Valor: String; Favorecido: String; Cidade: String; Data: String; Mensagem: String; Fonte : String): Integer; StdCall;
  fFuncBematech_FI_IncluiCidadeFavorecido             : function (Cidade: String; Favorecido: String): Integer; StdCall;
  fFuncBematech_FI_ImprimeCopiaCheque                 : function ():Integer; StdCall;
  fFuncBematech_FI_LeituraChequeMFD                   : function (Codigo: String): Integer; StdCall;

  // Outras Funções //////////////////////////////////////////////////////////////
  fFuncBematech_FI_AbrePortaSerial                    : function ():Integer; StdCall;
  fFuncBematech_FI_RetornoImpressora                  : function (Var ACK: Integer; Var ST1: Integer; Var ST2: Integer): Integer; StdCall;
  fFuncBematech_FI_RetornoImpressoraMFD               : function (Var ACK: Integer; Var ST1: Integer; Var ST2: Integer; Var ST3: Integer): Integer; StdCall;
  fFuncBematech_FI_FechaPortaSerial                   : function ():Integer; StdCall;
  fFuncBematech_FI_MapaResumo                         : function ():Integer; StdCall;
  fFuncBematech_FI_AberturaDoDia                      : function (ValorCompra: string; FormaPagamento: string ): Integer; StdCall;
  fFuncBematech_FI_FechamentoDoDia                    : function ():Integer; StdCall;
  fFuncBematech_FI_ImprimeConfiguracoesImpressora     : function ():Integer; StdCall;
  fFuncBematech_FI_ImprimeDepartamentos               : function ():Integer; StdCall;
  fFuncBematech_FI_RelatorioTipo60Analitico           : function ():Integer; StdCall;
  fFuncBematech_FI_RelatorioTipo60Mestre              : function ():Integer; StdCall;
  fFuncBematech_FI_VerificaImpressoraLigada           : function ():Integer; StdCall;
  fFuncBematech_FI_VersaoDll                          : function ( VersaoDll : string):Integer; StdCall;
  fFuncBematech_FI_HabilitaDesabilitaRetornoEstendidoMFD: function ( FlagRetorno : string):Integer; StdCall;

  // Funções MFD
  fFuncBematech_FI_DownloadMFD                        : function( sArquivo, sTipo, sInicio, sFinal, sUsuario : String ):Integer; StdCall;
  fFuncBematech_FI_FormatoDadosMFD                    : function( sArquivo, sDestino, sFormato, sTipo, sInicio, sFinal, sUsuario: String ):Integer; StdCall;
  fFuncBematech_FI_ProgramaIdAplicativoMFD            : function( sAplicativo : String ):Integer;StdCall;
  fFuncBemaGeraRegistrosTipoEMFD1                     : function( cArqMFD: string; cArqTXT: string; cDataInicial: string; cDataFinal: string; cRazao: string; cEndereco: string; cPAR1: string; cCMD: string; cPAR2: string; cPAR3: string; cPAR4: string; cPAR5: string; cPAR6: string; cPAR7: string; cPAR8: string; cPAR9: string; cPAR10: string; cPAR11: string; cPAR12: string; cPAR13: string; cPAR14: string ): Integer; StdCall;
  fFuncBemaGeraRegistrosTipoEMFD2                     : function( cArqMFD: string; cArqTXT: string; cDataInicial: string; cDataFinal: string; cRazao: string; cEndereco: string; cPAR1: string; cCMD: string; cPAR2: string; cPAR3: string; cPAR4: string; cPAR5: string; cPAR6: string; cPAR7: string; cPAR8: string; cPAR9: string; cPAR10: string; cPAR11: string; cPAR12: string; cPAR13: string; cPAR14: string ): Integer; StdCall;
  fFuncBematech_FI_GeraArquivoMFD                     : function( cNomeArquivoOrigem: string; cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: Integer; cChavePublica: string; cChavePrivada: string; iUnicoArquivo: Integer ): Integer;  StdCall;
  fFuncBematech_FI_ArquivoMFDPath                     : function( ArquivoOrigem, ArquivoDestino,DadoInicial,DadoFinal, TipoDownload,Usuario: String; TipoGeracao: Integer; ChavePublica,ChavePrivada: String; UnicoArquivo: Integer): Integer; StdCall;
  fFuncBematech_FI_EstornoNaoFiscalVinculadoMFD       : function( CPFCNPJ: String ; Nome : String ; Endereco : String) : Integer; StdCall;
  fFuncBematech_FI_DownloadMF                         : function( sArquivo: String): Integer;  StdCall;

  // Funções para a Impressora Restaurante
  fFuncBematech_FIR_AbreCupomRestaurante              :function( Mesa: String; CGC_CPF: String ): Integer; StdCall;
  fFuncBematech_FIR_RegistraVenda                     :function( Mesa: String; Codigo: String; Descricao: String; Aliquota: String; Quantidade: String; ValorUnitario: String; FlagAcrescimoDesconto: String; ValorAcrescimoDesconto: String ): Integer; StdCall;
  fFuncBematech_FIR_CancelaVenda                      :function( Mesa: String; Codigo: String; Descricao: String; Aliquota: String; Quantidade: String; ValorUnitario: String; FlagAcrescimoDesconto: String; ValorAcrescimoDesconto: String ): Integer; StdCall;
  fFuncBematech_FIR_AbreConferenciaMesa               :function( Mesa: String ): Integer; StdCall;
  fFuncBematech_FIR_FechaConferenciaMesa              :function( FlagAcrescimoDesconto: String; TipoAcrescimoDesconto: String; ValorAcrescimoDesconto: String ): Integer; StdCall;
  fFuncBematech_FIR_TransferenciaMesa                 :function( MesaOrigem: String; MesaDestino: String ): Integer; StdCall;
  fFuncBematech_FIR_ContaDividida                     :function( NumeroCupons: String; ValorPago: String; CGC_CPF: String ): Integer; StdCall;
  fFuncBematech_FIR_FechaCupomContaDividida           :function( NumeroCupons: String; FlagAcrescimoDesconto: String; TipoAcrescimoDesconto: String; ValorAcrescimoDesconto: String; FormasPagamento: String; ValorFormasPagamento: String; ValorPagoCliente: String; CGC_CPF: String ): Integer; StdCall;
  fFuncBematech_FIR_TransferenciaItem                 :function( MesaOrigem: String; Codigo: String; Descricao: String; Aliquota: String; Quantidade: String; ValorUnitario: String; FlagAcrescimoDesconto: String; ValorAcrescimoDesconto: String; MesaDestino: String ): Integer; StdCall;
  fFuncBematech_FIR_RelatorioMesasAbertas             :function( TipoRelatorio: Integer ): Integer; StdCall;
  fFuncBematech_FIR_ImprimeCardapio                   :function(): Integer; StdCall;
  fFuncBematech_FIR_ConferenciaMesa                   :function (Mesa: String; FlagAcrescimoDesconto: String; TipoAcrescimoDesconto: String; ValorAcrescimoDesconto: String) : Integer; StdCall;
  fFuncBematech_FIR_RelatorioMesasAbertasSerial       :function(): Integer; StdCall;
  fFuncBematech_FIR_CardapioPelaSerial                :function(): Integer; StdCall;
  fFuncBematech_FIR_RegistroVendaSerial               :function( Mesa: String ): Integer; StdCall;
  fFuncBematech_FIR_VerificaMemoriaLivre              :function( Bytes: String ): Integer; StdCall;
  fFuncBematech_FIR_FechaCupomRestaurante             :function( FormaPagamento: String; FlagAcrescimoDesconto: String; TipoAcrescimoDesconto: String; ValorAcrescimoDesconto: String; ValorFormaPagto: String; Mensagem: String ): Integer; StdCall;
  fFuncBematech_FIR_FechaCupomResumidoRestaurante     :function( FormaPagamento: String; Mensagem: String ): Integer; StdCall;

  // Funções para chave EAD
  fFuncGenkKey                                        :function( ChavePublica, ChavePrivada: String ): Integer; StdCall;
  fFuncGenerateEAD                                    :function( NomeArquivo, ChavePublica, ChavePrivada, RegistroEAD: String; Grava: Integer ): Integer; StdCall;

  //Funções específicas da impressora fiscal MP-4200 TH FI (Conv. 09/09)
  fFuncBematech_FI_MinutosEmitindoDocumentosFiscaisCV0909: function( cMinutos: string ): Integer;  StdCall;
  fFuncBematech_FI_NumeroCupomCV0909: function( cNumero: string ): Integer;  StdCall;
  fFuncBematech_FI_NumeroOperacoesNaoFiscaisCV0909: function( cNumero: string ): Integer;  StdCall;
  fFuncBematech_FI_NumeroSerieCV0909: function( cNumero: string ): Integer;  StdCall;
  fFuncBematech_FI_RetornoAliquotasCV0909: function( cAliquotas: string ): Integer;  StdCall;
  fFuncBematech_FI_RetornoImpressoraCV0909: function( iCAT: integer; iRET0: integer; iRET1: integer; iRET2: integer; iRET3: integer ): Integer;  StdCall;
  fFuncBematech_FI_VerificaFormasPagamentoCV0909: function( cFormar: string ): Integer;  StdCall;
  fFuncBematech_FI_VerificaIndiceAliquotasIssCV0909: function( cIndices: string ): Integer;  StdCall;
  fFuncBematech_FI_VerificaRecebimentoNaoFiscalCV0909: function(cRecebimentos: string ): Integer;  StdCall;
  fFuncBematech_FI_VerificaTotalizadoresNaoFiscaisCV0909: function( cTotalizadores: string ): Integer;  StdCall;
  fFuncBematech_FI_VersaoFirmwareCV0909: function( cVersao: string ): Integer;  StdCall;
  fFuncBematech_FI_TempoEmitindoOperacionalCV0909: function( cTempoEmitindo: string; cTempoOperacional: string ): Integer;  StdCall;
  fFuncBematech_FI_AbreComprovanteNaoFiscalVinculadoCV0909: function( iSequencia: integer; cIndice: string; iQtdeParcela: integer; iNumeroParcela: integer; cCPF: string; cNome: string; cEndereco: string ): Integer;  StdCall;
  fFuncBematech_FI_AbreCupomCV0909: function( cCPF: string; cNome: string; cEndereco: string ): Integer;  StdCall;
  fFuncBematech_FI_AbreRecebimentoNaoFiscalCV0909: function( cCPF: string; cNome: string; cEndereco: string ): Integer;  StdCall;
  fFuncBematech_FI_AbreRelatorioGerencialCV0909: function( cRelatorio: string ): Integer;  StdCall;
  fFuncBematech_FI_AcionaGuilhotinaCV0909: function( iModo: integer ): Integer;  StdCall;
  fFuncBematech_FI_AcrescimoDescontoItemCV0909: function( cItem: string; cTipo: string; cModo: string; cValor: string ): Integer;  StdCall;
  fFuncBematech_FI_AcrescimoDescontoSubtotalCV0909: function( cTipo: string; cModo: string; cValor: string ): Integer;  StdCall;
  fFuncBematech_FI_CancelaAcrescimoDescontoItemCV0909: function( cTipo: string; cItem: string ): Integer;  StdCall;
  fFuncBematech_FI_CancelaAcrescimoDescontoSubtotalCV0909: function( cTipo: string ): Integer;  StdCall;
  fFuncBematech_FI_CancelaCupomCV0909: function( cCOO: string ): Integer;  StdCall;
  fFuncBematech_FI_CancelaCupomAtualCV0909: function : Integer;  StdCall;
  fFuncBematech_FI_DownloadMFCV0909: function( cNomeArquivo: string; cTipo: string; cDadoInicial: string; cDadoFinal: string ): Integer;  StdCall;
  fFuncBematech_FI_DownloadMFDCV0909: function( cNomeArquivo: string; cTipoDownload: string; cDadoInicial: string; cDadoFinal: string ): Integer;  StdCall;
  fFuncBematech_FI_DownloadSBCV0909: function( cNomeArquivo: string ): Integer;  StdCall;
  fFuncBematech_FI_EfetuaFormaPagamentoIndiceCV0909: function( cIndice: string; cValor: string; cParcelas: string; cDescricao: string; cCodigoPagamento: string ): Integer;  StdCall;
  fFuncBematech_FI_EfetuaRecebimentoNaoFiscalCV0909: function( cIndiceTotalizador: string; cValor: string ): Integer;  StdCall;
  fFuncBematech_FI_EstornoFormasPagamentoCV0909: function( cFormaOrigem: string; cFormaDestino: string; cValor: string; iSequenciaForma: integer; cMensagem: string ): Integer;  StdCall;
  fFuncBematech_FI_EstornoNaoFiscalVinculadoCV0909: function( cCPF: string; cNome: string; cEndereco: string; cCOO: string ): Integer;  StdCall;
  fFuncBematech_FI_FechaRecebimentoNaoFiscalCV0909: function( cInformacao: string; iGuilhotina: integer ): Integer; StdCall;
  fFuncBematech_FI_FechaRelatorioGerencialCV0909: function( iGuilhotina: integer ): Integer;  StdCall;
  fFuncBematech_FI_ImpressaoFitaDetalheCV0909: function( cTipo: string; cDadoInicial: string; cDadoFinal: string ): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalDataCV0909: function( cDataInicial: string; cDataFinal: string; cFlag: string ): Integer; StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalReducaoCV0909: function(cReducaoInicial: string; cReducaoFinal: string; cFlag: string ): Integer;  StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalSerialDataCV0909: function( cDataInicial: string; cDataFinal: string; cFlag: string ): Integer;  StdCall;
  fFuncBematech_FI_LeituraMemoriaFiscalSerialReducaoCV0909: function( cReducaoInicial: string; cReducaoFinal: string; cFlag: string ): Integer;  StdCall;
  fFuncBematech_FI_ReducaoZCV0909: function ( cData: string; cHora: string; iTransmite: integer ): Integer;  StdCall;
  fFuncBematech_FI_ReimpressaoNaoFiscalVinculadoCV0909: function (): Integer;  StdCall;
  fFuncBematech_FI_SangriaCV0909: function( cValor: string; cInformacao: string ): Integer;  StdCall;
  fFuncBematech_FI_SegundaViaNaoFiscalVinculadoCV0909: function (): Integer;  StdCall;
  fFuncBematech_FI_SuprimentoCV0909: function( cValor: string; cInformacao: string ): Integer;  StdCall;
  fFuncBematech_FI_TerminaFechamentoCupomCV0909: function( cInformacao: string; iCupomAdicional: integer; iGuilhotina: integer ): Integer;  StdCall;
  fFuncBematech_FI_UsaRelatorioGerencialCV0909: function( cTexto: string ): Integer;  StdCall;
  fFuncBematech_FI_VendeItemCV0909: function( cCodigo: string; cDescricao: string; cAliquota: string; cQuantidade: string; iDecimalQtde: integer; cValor: string; cUnidadeMedida: string; iDecimalValor: integer; cModo: string ): Integer;  StdCall;
  fFuncBematech_FI_InterrompeLeiturasCV0909: function : Integer;  StdCall;
  fFuncBematech_FI_ImprimeRTDCV0909: function( cMensagem: string ): Integer;  StdCall;
  fFuncBematech_FI_BufferRespostaCV0909: function( cBuffer: string ): Integer;  StdCall;
  fFuncBematech_FI_ProgramaAliquotaCV0909: function( cValor: string; iTipo: integer; cIndice: string ): Integer;  StdCall;
  fFuncBematech_FI_ProgramaHorarioVeraoCV0909: function( iModo: integer ): Integer;  StdCall;
  fFuncBematech_FI_NomeiaTotalizadorNaoSujeitoIcmsCV0909: function( iIndice: integer; cDescricao: string; cSituacao: string ): Integer;  StdCall;
  fFuncBematech_FI_ProgramaIdAplicativoCV0909: function( cID: string ): Integer;  StdCall;
  fFuncBematech_FI_NomeiaRelatorioGerencialCV0909: function( cIndice: string; cDescricao: string ): Integer;  StdCall;
  fFuncBematech_FI_ProgramaFormaPagamentoCV0909: function( cIndice: string; cDescricao: string; iVincula: integer ): Integer;  StdCall;
  fFuncBematech_FI_DadosUltimaReducaoCV0909: function( cDados: string ): Integer;  StdCall;
  fFuncBematech_FI_AbreRecebimentoNaoFiscalMFD : function ( cCPF ,  cNomeCliente ,  cEnderecoCliente : String ) : Integer; StdCall;
  fFuncBematech_FI_FechaRecebimentoNaoFiscalMFD: function ( cMensagem : String): Integer; StdCall;
  fFuncBematech_FI_EfetuaRecebimentoNaoFiscalMFD : function ( cIndice , cValor : String ): Integer; StdCall;
  fFuncBematech_FI_VerificaFormasPagamentoMFD : function (sFPgto : String ): Integer; StdCall;
  fFuncBematech_FI_IniciaFechamentoRecebimentoNaoFiscalMFD: function ( cAcresDesc, cTipoAcresDesc , cValorAcres , cValorDesc :  String):Integer; StdCall;
  fFuncBematech_FI_EfetuaFormaPagamentoMFD: function ( cFormaPgto , cValorPago , cNumeroParcelas , cMsg : String ): Integer; StdCall;
  fFuncBematech_FI_SubTotalizaRecebimentoMFD : function (): Integer; StdCall;
  fFuncBematech_FI_TotalizaRecebimentoMFD : function () : Integer; StdCall;
  fFuncBematech_FI_VendaLiquida: function ( cValor : String ) : Integer; StdCall;

  bOpened   : Boolean;
  lDescAcres: Boolean = False;
  Path      : String;
  aIndAliq  : array of string;
  sMarca    : String;               // Marca da ECF
  lError    : Boolean = False;      // Controle de Erro para Alimentar Propriedades

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
Function LeArqBema(sSessao,sChave: String): String;
var
  fArq : TIniFile;
  sPath,sIni : String;
Begin
  sPath := ExtractFilePath(Application.ExeName);
  Result:= '';

  If Copy(sPath,Length(sPath),1) = '\' then
  begin
    sIni := sPath + sArqIniBema;
    Path  := sPath ;
  end
  Else
  begin
    sIni := sPath + '\' + sArqIniBema;
    Path  := sPath + '\';
  end;

  If FileExists(sIni) then
  begin
    Try
      fArq := TInifile.Create( sIni );
      Result := fArq.ReadString( sSessao, sChave, '' );
      fArq.Free;
    Except
      GravaLog('Erro na leitura do Arquivo ' + sArqIniBema);
      Result := '';
    End;
  end;
End;

//------------------------------------------------------------------------------
Function ArqIniBematech( sPorta, sModeloImp, sImpressora:String ):Boolean;
var
  fArq : TIniFile;
  ListaArq: TStringList;
  sPath,sIni : String;
  lRet : Boolean;
begin
  lRet := True;

  sPath := ExtractFilePath(Application.ExeName);

  If Copy(sPath,Length(sPath),1) = '\' then
  begin
    sIni := sPath + sArqIniBema;
    Path  := sPath ;
  end
  Else
  begin
    sIni := sPath + '\' + sArqIniBema;
    Path  := sPath + '\';
  end;

  If FileExists(sIni) then
  begin
    Try
      fArq := TInifile.Create( sIni );

      If fArq.ReadString( 'Sistema', 'Porta', '' ) <> UpperCase(sPorta) then
        fArq.WriteString( 'Sistema', 'Porta', UpperCase(sPorta) );

      // '1'-grava status.txt  '0'-retorna via serial
      If fArq.ReadString( 'Sistema', 'Status', '' ) <> '0' then
        fArq.WriteString( 'Sistema', 'Status', '0' );

      // '1'-grava retorno.txt '0'-retorna via serial
      If fArq.ReadString( 'Sistema', 'Retorno', '' ) <> '0' then
        fArq.WriteString( 'Sistema', 'Retorno', '0' );

      // '1'-grava log (Bemafi32.log) '0'-Não grava log
      If fArq.ReadString( 'Sistema', 'Log', '' ) = '' then
        fArq.WriteString( 'Sistema', 'Log', '1' );

      // '1'-Retorna -27 se houve algum erro na impressora
      // '0'-apenas trata se o comando foi enviado corretamente pela BEMAFI32.DLL, não trata erros na impressora.
      If fArq.ReadString( 'Sistema', 'StatusFuncao', '' ) <> '1' then
        fArq.WriteString( 'Sistema', 'StatusFuncao', '1' );

      // '0'-controle da porta pelo sistema
      // '1'-a bemafi32.dll fecha e abre a porta a cada comando executado.
      If fArq.ReadString( 'Sistema', 'ControlePorta', '' ) <> '1' then
        fArq.WriteString( 'Sistema', 'ControlePorta', '1' );

      // 'BEMATECH'-nome da impressora usada
      // 'YANCO'-nome da impressora usada
      If fArq.ReadString( 'Sistema', 'ModeloImp', '' ) <> sModeloImp then
        fArq.WriteString( 'Sistema', 'ModeloImp', sModeloImp );

      //'0' - Impressora sem MFD -- Retorna número de série com 15 dígitos
      //'1' - Impressora com MFD -- Retorna número de série com 20 dígitos
      //'2' - Impressora com MFD -- Retorna número de série com 20 dígitos Mp7000 Hardware IBM
      fArq.WriteString( 'MFD', 'Impressora', sImpressora );

      fArq.Free;

      Try
        //Log do Arquivo de Configuração
        ListaArq := TStringList.Create;
        ListaArq.Clear;
        ListaArq.LoadFromFile(sIni);

        GravaLog(' ******** Arquivo BEMAFI32.INI *******');
        GravaLog( ListaArq.Text );
        GravaLog(' ******** Final da Leitura do Arquivo BEMAFI32.INI *******');
      Except
        GravaLog(' Não foi possível carregar/ler o arquivo BEMAFI32.INI ');
      End;

    Except
      lRet := False;
    End;
  end
  Else
  begin
    LjMsgDlg( 'Arquivo ' + sIni + ' não encontrado. ');
    lRet := False;
  end;

  Result := lRet;
end;

//----------------------------------------------------------------------------
Function OpenBematech( sPorta:String; lEstendido:Boolean = False ) : String;

  function ValidPointer( aPointer: Pointer; sMSg:String; sArqDll:String = sArqDllBema ; bEmiteMsg : Boolean = True) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      If bEmiteMsg
      then LjMsgDlg('A função "' + sMsg + '" não existe na Dll: ' + sArqDll +#13+
                 '(Atualize as DLLs do Fabricante do ECF)');
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
  sTempPath,cFlag : String;
  BufferTemp : Array[0..144] of Char;
begin
  cFlag  := '1';
  Result := '0|';
  If Not bOpened Then
  Begin
    fHandle  := LoadLibrary( sArqDllBema );
    fHandle1 := LoadLibrary( sArqBemaMfd1 );
    fHandle2 := LoadLibrary( sArqBemaMfd2 );

    // Indica a possibilidade da utilização
    // via ActiveX portanto faz uma nova verificação.
    // Inicio
    If (fHandle = 0) Then
    Begin
        GetTempPath(144,BufferTemp);
        sTempPath := trim(StrPas(BufferTemp)) + sArqDllBema ;
        pTempPath := PChar(sTempPath);
        fHandle   := LoadLibrary( pTempPath );
    End;
    // Fim

    if (fHandle <> 0) AND (fHandle1 <> 0) AND (fHandle2 <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AlteraSimboloMoeda');
      if ValidPointer( aFunc, 'Bematech_FI_AlteraSimboloMoeda' ) then
        fFuncBematech_FI_AlteraSimboloMoeda := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaAliquota');
      if ValidPointer( aFunc, 'Bematech_FI_ProgramaAliquota' ) then
        fFuncBematech_FI_ProgramaAliquota := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NomeiaTotalizadorNaoSujeitoIcms');
      if ValidPointer( aFunc, 'Bematech_FI_NomeiaTotalizadorNaoSujeitoIcms' ) then
        fFuncBematech_FI_NomeiaTotalizadorNaoSujeitoIcms := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaHorarioVerao');
      if ValidPointer( aFunc, 'Bematech_FI_ProgramaHorarioVerao' ) then
        fFuncBematech_FI_ProgramaHorarioVerao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NomeiaDepartamento');
      if ValidPointer( aFunc, 'Bematech_FI_NomeiaDepartamento' ) then
        fFuncBematech_FI_NomeiaDepartamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaArredondamento');
      if ValidPointer( aFunc, 'Bematech_FI_ProgramaArredondamento' ) then
        fFuncBematech_FI_ProgramaArredondamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaTruncamento');
      if ValidPointer( aFunc, 'Bematech_FI_ProgramaTruncamento' ) then
        fFuncBematech_FI_ProgramaArredondamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LinhasEntreCupons');
      if ValidPointer( aFunc, 'Bematech_FI_LinhasEntreCupons' ) then
        fFuncBematech_FI_LinhasEntreCupons := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_EspacoEntreLinhas');
      if ValidPointer( aFunc, 'Bematech_FI_EspacoEntreLinhas' ) then
        fFuncBematech_FI_EspacoEntreLinhas := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ForcaImpactoAgulhas');
      if ValidPointer( aFunc, 'Bematech_FI_ForcaImpactoAgulhas' ) then
        fFuncBematech_FI_ForcaImpactoAgulhas := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreCupom');
      if ValidPointer( aFunc, 'Bematech_FI_AbreCupom' ) then
        fFuncBematech_FI_AbreCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreCupomMFD');
      if ValidPointer( aFunc, 'Bematech_FI_AbreCupomMFD' ) then
        fFuncBematech_FI_AbreCupomMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VendeItem');
      if ValidPointer( aFunc, 'Bematech_FI_VendeItem' ) then
        fFuncBematech_FI_VendeItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VendeItemDepartamento');
      if ValidPointer( aFunc, 'Bematech_FI_VendeItemDepartamento' ) then
        fFuncBematech_FI_VendeItemDepartamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_CancelaItemAnterior');
      if ValidPointer( aFunc, 'Bematech_FI_CancelaItemAnterior' ) then
        fFuncBematech_FI_CancelaItemAnterior := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_CancelaItemGenerico');
      if ValidPointer( aFunc, 'Bematech_FI_CancelaItemGenerico' ) then
        fFuncBematech_FI_CancelaItemGenerico := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_CancelaCupom');
      if ValidPointer( aFunc, 'Bematech_FI_CancelaCupom' ) then
        fFuncBematech_FI_CancelaCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_FechaCupomResumido');
      if ValidPointer( aFunc, 'Bematech_FI_FechaCupomResumido' ) then
        fFuncBematech_FI_FechaCupomResumido := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_FechaCupom');
      if ValidPointer( aFunc, 'Bematech_FI_FechaCupom' ) then
        fFuncBematech_FI_FechaCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ResetaImpressora');
      if ValidPointer( aFunc, 'Bematech_FI_ResetaImpressora' ) then
        fFuncBematech_FI_ResetaImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_IniciaFechamentoCupom');
      if ValidPointer( aFunc, 'Bematech_FI_IniciaFechamentoCupom' ) then
        fFuncBematech_FI_IniciaFechamentoCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_EfetuaFormaPagamento');
      if ValidPointer( aFunc, 'Bematech_FI_EfetuaFormaPagamento' ) then
        fFuncBematech_FI_EfetuaFormaPagamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_EfetuaFormaPagamentoDescricaoForma');
      if ValidPointer( aFunc, 'Bematech_FI_EfetuaFormaPagamentoDescricaoForma' ) then
        fFuncBematech_FI_EfetuaFormaPagamentoDescricaoForma := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_TerminaFechamentoCupom');
      if ValidPointer( aFunc, 'Bematech_FI_TerminaFechamentoCupom' ) then
        fFuncBematech_FI_TerminaFechamentoCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_EstornoFormasPagamento');
      if ValidPointer( aFunc, 'Bematech_FI_EstornoFormasPagamento' ) then
        fFuncBematech_FI_EstornoFormasPagamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_UsaUnidadeMedida');
      if ValidPointer( aFunc, 'Bematech_FI_UsaUnidadeMedida' ) then
        fFuncBematech_FI_UsaUnidadeMedida := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AumentaDescricaoItem');
      if ValidPointer( aFunc, 'Bematech_FI_AumentaDescricaoItem' ) then
        fFuncBematech_FI_AumentaDescricaoItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ContadorCupomFiscalMFD');
      if ValidPointer( aFunc, 'Bematech_FI_ContadorCupomFiscalMFD' ) then
        fFuncBematech_FI_ContadorCupomFiscalMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraX');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraX' ) then
        fFuncBematech_FI_LeituraX := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ReducaoZ');
      if ValidPointer( aFunc, 'Bematech_FI_ReducaoZ' ) then
        fFuncBematech_FI_ReducaoZ := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_RelatorioGerencial');
      if ValidPointer( aFunc, 'Bematech_FI_RelatorioGerencial' ) then
        fFuncBematech_FI_RelatorioGerencial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_FechaRelatorioGerencial');
      if ValidPointer( aFunc, 'Bematech_FI_FechaRelatorioGerencial' ) then
        fFuncBematech_FI_FechaRelatorioGerencial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalData');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraMemoriaFiscalData' ) then
        fFuncBematech_FI_LeituraMemoriaFiscalData := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalReducao');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraMemoriaFiscalReducao' ) then
        fFuncBematech_FI_LeituraMemoriaFiscalReducao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalSerialData');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraMemoriaFiscalSerialData' ) then
        fFuncBematech_FI_LeituraMemoriaFiscalSerialData := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalSerialReducao');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraMemoriaFiscalSerialReducao' ) then
        fFuncBematech_FI_LeituraMemoriaFiscalSerialReducao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalDataMFD');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraMemoriaFiscalDataMFD' ) then
        fFuncBematech_FI_LeituraMemoriaFiscalDataMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalReducaoMFD');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraMemoriaFiscalReducaoMFD' ) then
        fFuncBematech_FI_LeituraMemoriaFiscalReducaoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalSerialDataMFD');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraMemoriaFiscalSerialDataMFD' ) then
        fFuncBematech_FI_LeituraMemoriaFiscalSerialDataMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalSerialReducaoMFD');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraMemoriaFiscalSerialReducaoMFD' ) then
        fFuncBematech_FI_LeituraMemoriaFiscalSerialReducaoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_RecebimentoNaoFiscal');
      if ValidPointer( aFunc, 'Bematech_FI_RecebimentoNaoFiscal' ) then
        fFuncBematech_FI_RecebimentoNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreComprovanteNaoFiscalVinculado');
      if ValidPointer( aFunc, 'Bematech_FI_AbreComprovanteNaoFiscalVinculado' ) then
        fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_UsaComprovanteNaoFiscalVinculado');
      if ValidPointer( aFunc, 'Bematech_FI_UsaComprovanteNaoFiscalVinculado' ) then
        fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_FechaComprovanteNaoFiscalVinculado');
      if ValidPointer( aFunc, 'Bematech_FI_FechaComprovanteNaoFiscalVinculado' ) then
        fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_Sangria');
      if ValidPointer( aFunc, 'Bematech_FI_Sangria' ) then
        fFuncBematech_FI_Sangria := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_Suprimento');
      if ValidPointer( aFunc, 'Bematech_FI_Suprimento' ) then
        fFuncBematech_FI_Suprimento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroSerie');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroSerie' ) then
        fFuncBematech_FI_NumeroSerie := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroSerieMFD');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroSerieMFD' ) then
        fFuncBematech_FI_NumeroSerieMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_SubTotal');
      if ValidPointer( aFunc, 'Bematech_FI_SubTotal' ) then
        fFuncBematech_FI_SubTotal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroCupom');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroCupom' ) then
        fFuncBematech_FI_NumeroCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraXSerial');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraXSerial' ) then
        fFuncBematech_FI_LeituraXSerial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VersaoFirmware');
      if ValidPointer( aFunc, 'Bematech_FI_VersaoFirmware' ) then
        fFuncBematech_FI_VersaoFirmware := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VersaoFirmwareMFD');
      if ValidPointer( aFunc, 'Bematech_FI_VersaoFirmwareMFD' ) then
        fFuncBematech_FI_VersaoFirmwareMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_CGC_IE');
      if ValidPointer( aFunc, 'Bematech_FI_CGC_IE' ) then
        fFuncBematech_FI_CGC_IE := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_GrandeTotal');
      if ValidPointer( aFunc, 'Bematech_FI_GrandeTotal' ) then
        fFuncBematech_FI_GrandeTotal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_Cancelamentos');
      if ValidPointer( aFunc, 'Bematech_FI_Cancelamentos' ) then
        fFuncBematech_FI_Cancelamentos := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_Descontos');
      if ValidPointer( aFunc, 'Bematech_FI_Descontos' ) then
        fFuncBematech_FI_Descontos := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroOperacoesNaoFiscais');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroOperacoesNaoFiscais' ) then
        fFuncBematech_FI_NumeroOperacoesNaoFiscais := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroCuponsCancelados');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroCuponsCancelados' ) then
        fFuncBematech_FI_NumeroCuponsCancelados := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroIntervencoes');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroIntervencoes' ) then
        fFuncBematech_FI_NumeroIntervencoes := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroReducoes');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroReducoes' ) then
        fFuncBematech_FI_NumeroReducoes := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroSubstituicoesProprietario');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroSubstituicoesProprietario' ) then
        fFuncBematech_FI_NumeroSubstituicoesProprietario := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_UltimoItemVendido');
      if ValidPointer( aFunc, 'Bematech_FI_UltimoItemVendido' ) then
        fFuncBematech_FI_UltimoItemVendido := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ClicheProprietario');
      if ValidPointer( aFunc, 'Bematech_FI_ClicheProprietario' ) then
        fFuncBematech_FI_ClicheProprietario := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroCaixa');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroCaixa' ) then
        fFuncBematech_FI_NumeroCaixa := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroLoja');
      if ValidPointer( aFunc, 'Bematech_FI_NumeroLoja' ) then
        fFuncBematech_FI_NumeroLoja := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_SimboloMoeda');
      if ValidPointer( aFunc, 'Bematech_FI_SimboloMoeda' ) then
        fFuncBematech_FI_SimboloMoeda := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_MinutosLigada');
      if ValidPointer( aFunc, 'Bematech_FI_MinutosLigada' ) then
        fFuncBematech_FI_MinutosLigada := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_MinutosImprimindo');
      if ValidPointer( aFunc, 'Bematech_FI_MinutosImprimindo' ) then
        fFuncBematech_FI_MinutosImprimindo := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaModoOperacao');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaModoOperacao' ) then
        fFuncBematech_FI_VerificaModoOperacao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaEpromConectada');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaEpromConectada' ) then
        fFuncBematech_FI_VerificaEpromConectada := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_FlagsFiscais');
      if ValidPointer( aFunc, 'Bematech_FI_FlagsFiscais' ) then
        fFuncBematech_FI_FlagsFiscais := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ValorPagoUltimoCupom');
      if ValidPointer( aFunc, 'Bematech_FI_ValorPagoUltimoCupom' ) then
        fFuncBematech_FI_ValorPagoUltimoCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_DataHoraImpressora');
      if ValidPointer( aFunc, 'Bematech_FI_DataHoraImpressora' ) then
        fFuncBematech_FI_DataHoraImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ContadoresTotalizadoresNaoFiscais');
      if ValidPointer( aFunc, 'Bematech_FI_ContadoresTotalizadoresNaoFiscais' ) then
        fFuncBematech_FI_ContadoresTotalizadoresNaoFiscais := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaTotalizadoresNaoFiscais');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaTotalizadoresNaoFiscais' ) then
        fFuncBematech_FI_VerificaTotalizadoresNaoFiscais := aFunc
      else
        bRet := False;

       aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaTotalizadoresNaoFiscaisMFD');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaTotalizadoresNaoFiscaisMFD' ) then
        fFuncBematech_FI_VerificaTotalizadoresNaoFiscaisMFD := aFunc
      else
        bRet := False;


      aFunc := GetProcAddress(fHandle,'Bematech_FI_DataHoraReducao');
      if ValidPointer( aFunc, 'Bematech_FI_DataHoraReducao' ) then
        fFuncBematech_FI_DataHoraReducao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_DataMovimento');
      if ValidPointer( aFunc, 'Bematech_FI_DataMovimento' ) then
        fFuncBematech_FI_DataMovimento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaTruncamento');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaTruncamento' ) then
        fFuncBematech_FI_VerificaTruncamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_Acrescimos');
      if ValidPointer( aFunc, 'Bematech_FI_Acrescimos' ) then
        fFuncBematech_FI_Acrescimos := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ContadorBilhetePassagem');
      if ValidPointer( aFunc, 'Bematech_FI_ContadorBilhetePassagem' ) then
        fFuncBematech_FI_ContadorBilhetePassagem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaAliquotasIss');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaAliquotasIss' ) then
        fFuncBematech_FI_VerificaAliquotasIss := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaFormasPagamento');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaFormasPagamento' ) then
        fFuncBematech_FI_VerificaFormasPagamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaRecebimentoNaoFiscal');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaRecebimentoNaoFiscal' ) then
        fFuncBematech_FI_VerificaRecebimentoNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaRecebimentoNaoFiscalMFD');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaRecebimentoNaoFiscalMFD' ) then
        fFuncBematech_FI_VerificaRecebimentoNaoFiscalMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaDepartamentos');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaDepartamentos' ) then
        fFuncBematech_FI_VerificaDepartamentos := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaTipoImpressora');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaTipoImpressora' ) then
        fFuncBematech_FI_VerificaTipoImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaTotalizadoresParciais');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaTotalizadoresParciais' )
      then fFuncBematech_FI_VerificaTotalizadoresParciais := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaTotalizadoresParciaisMFD');
      If ValidPointer( aFunc , 'Bematech_FI_VerificaTotalizadoresParciaisMFD')
      then fFuncBematech_FI_VerificaTotalizadoresParciaisMFD := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_RetornoAliquotas');
      if ValidPointer( aFunc, 'Bematech_FI_RetornoAliquotas' ) then
        fFuncBematech_FI_RetornoAliquotas := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaEstadoImpressora');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaEstadoImpressora' ) then
        fFuncBematech_FI_VerificaEstadoImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaEstadoImpressoraMFD');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaEstadoImpressoraMFD' ) then
        fFuncBematech_FI_VerificaEstadoImpressoraMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_DadosUltimaReducao');
      if ValidPointer( aFunc, 'Bematech_FI_DadosUltimaReducao' ) then
        fFuncBematech_FI_DadosUltimaReducao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_DadosUltimaReducaoMFD');
      if ValidPointer( aFunc, 'Bematech_FI_DadosUltimaReducaoMFD' ) then
        fFuncBematech_FI_DadosUltimaReducaoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_MonitoramentoPapel');
      if ValidPointer( aFunc, 'Bematech_FI_MonitoramentoPapel' ) then
        fFuncBematech_FI_MonitoramentoPapel := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaIndiceAliquotasIss');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaIndiceAliquotasIss' ) then
        fFuncBematech_FI_VerificaIndiceAliquotasIss := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_Autenticacao');
      if ValidPointer( aFunc, 'Bematech_FI_Autenticacao' ) then
        fFuncBematech_FI_Autenticacao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaCaracterAutenticacao');
      if ValidPointer( aFunc, 'Bematech_FI_ProgramaCaracterAutenticacao' ) then
        fFuncBematech_FI_ProgramaCaracterAutenticacao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AcionaGaveta');
      if ValidPointer( aFunc, 'Bematech_FI_AcionaGaveta' ) then
        fFuncBematech_FI_AcionaGaveta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaEstadoGaveta');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaEstadoGaveta' ) then
        fFuncBematech_FI_VerificaEstadoGaveta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaMoedaSingular');
      if ValidPointer( aFunc, 'Bematech_FI_ProgramaMoedaSingular' ) then
        fFuncBematech_FI_ProgramaMoedaSingular := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaMoedaPlural');
      if ValidPointer( aFunc, 'Bematech_FI_ProgramaMoedaPlural' ) then
        fFuncBematech_FI_ProgramaMoedaPlural := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_CancelaImpressaoCheque');
      if ValidPointer( aFunc, 'Bematech_FI_CancelaImpressaoCheque' ) then
        fFuncBematech_FI_CancelaImpressaoCheque := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaStatusCheque');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaStatusCheque' ) then
        fFuncBematech_FI_VerificaStatusCheque := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ImprimeCheque');
      if ValidPointer( aFunc, 'Bematech_FI_ImprimeCheque' ) then
        fFuncBematech_FI_ImprimeCheque := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ImprimeChequeMFD');
      if ValidPointer( aFunc, 'Bematech_FI_ImprimeChequeMFD' ) then
        fFuncBematech_FI_ImprimeChequeMFD := aFunc
      else
        bRet := False;

     aFunc := GetProcAddress(fHandle,'Bematech_FI_ImprimeChequeMFDEx');
      if ValidPointer( aFunc, 'Bematech_FI_ImprimeChequeMFDEx' ) then
        fFuncBematech_FI_ImprimeChequeMFDEx := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_IncluiCidadeFavorecido');
      if ValidPointer( aFunc, 'Bematech_FI_IncluiCidadeFavorecido' ) then
        fFuncBematech_FI_IncluiCidadeFavorecido := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ImprimeCopiaCheque');
      if ValidPointer( aFunc, 'Bematech_FI_ImprimeCopiaCheque' ) then
        fFuncBematech_FI_ImprimeCopiaCheque := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraChequeMFD');
      if ValidPointer( aFunc, 'Bematech_FI_LeituraChequeMFD' ) then
        fFuncBematech_FI_LeituraChequeMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AbrePortaSerial');
      if ValidPointer( aFunc, 'Bematech_FI_AbrePortaSerial' ) then
        fFuncBematech_FI_AbrePortaSerial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_RetornoImpressoraMFD');
      if ValidPointer( aFunc, 'Bematech_FI_RetornoImpressoraMFD' ) then
        fFuncBematech_FI_RetornoImpressoraMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_RetornoImpressora');
      if ValidPointer( aFunc, 'Bematech_FI_RetornoImpressora' ) then
        fFuncBematech_FI_RetornoImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_FechaPortaSerial');
      if ValidPointer( aFunc, 'Bematech_FI_FechaPortaSerial' ) then
        fFuncBematech_FI_FechaPortaSerial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_MapaResumo');
      if ValidPointer( aFunc, 'Bematech_FI_MapaResumo' ) then
        fFuncBematech_FI_MapaResumo := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AberturaDoDia');
      if ValidPointer( aFunc, 'Bematech_FI_AberturaDoDia' ) then
        fFuncBematech_FI_AberturaDoDia := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_FechamentoDoDia');
      if ValidPointer( aFunc, 'Bematech_FI_FechamentoDoDia' ) then
        fFuncBematech_FI_FechamentoDoDia := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ImprimeConfiguracoesImpressora');
      if ValidPointer( aFunc, 'Bematech_FI_ImprimeConfiguracoesImpressora' ) then
        fFuncBematech_FI_ImprimeConfiguracoesImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ImprimeDepartamentos');
      if ValidPointer( aFunc, 'Bematech_FI_ImprimeDepartamentos' ) then
        fFuncBematech_FI_ImprimeDepartamentos := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_RelatorioTipo60Analitico');
      if ValidPointer( aFunc, 'Bematech_FI_RelatorioTipo60Analitico' ) then
        fFuncBematech_FI_RelatorioTipo60Analitico := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_RelatorioTipo60Mestre');
      if ValidPointer( aFunc, 'Bematech_FI_RelatorioTipo60Mestre' ) then
        fFuncBematech_FI_RelatorioTipo60Mestre := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaImpressoraLigada');
      if ValidPointer( aFunc, 'Bematech_FI_VerificaImpressoraLigada' ) then
        fFuncBematech_FI_VerificaImpressoraLigada := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_HabilitaDesabilitaRetornoEstendidoMFD');
      if ValidPointer( aFunc, 'Bematech_FI_HabilitaDesabilitaRetornoEstendidoMFD' ) then
        fFuncBematech_FI_HabilitaDesabilitaRetornoEstendidoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VersaoDll');
      if ValidPointer( aFunc, 'Bematech_FI_VersaoDll' ) then
        fFuncBematech_FI_VersaoDll := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VendaBruta');
      if ValidPointer( aFunc, 'Bematech_FI_VendaBruta' ) then
        fFuncBematech_FI_VendaBruta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_GrandeTotal');
      if ValidPointer( aFunc, 'Bematech_FI_GrandeTotal' ) then
        fFuncBematech_FI_GrandeTotal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_DownloadMFD');
      if ValidPointer( aFunc, 'Bematech_FI_DownloadMFD' ) then
        fFuncBematech_FI_DownloadMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_FormatoDadosMFD');
      if ValidPointer( aFunc, 'Bematech_FI_FormatoDadosMFD' ) then
        fFuncBematech_FI_FormatoDadosMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaIdAplicativoMFD');
      if ValidPointer( aFunc, 'Bematech_FI_ProgramaIdAplicativoMFD' ) then
        fFuncBematech_FI_ProgramaIdAplicativoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FIR_AbreCupomRestaurante');
      If (ValidPointer( aFunc, 'Bematech_FIR_AbreCupomRestaurante',sArqIniBema,False )) then
      begin

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_AbreCupomRestaurante');
        if ValidPointer( aFunc, 'Bematech_FIR_AbreCupomRestaurante' )
        then  fFuncBematech_FIR_AbreCupomRestaurante := aFunc
        else  bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_RegistraVenda');
        if ValidPointer( aFunc, 'Bematech_FIR_RegistraVenda' ) then
          fFuncBematech_FIR_RegistraVenda := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_CancelaVenda');
        if ValidPointer( aFunc, 'Bematech_FIR_CancelaVenda' ) then
          fFuncBematech_FIR_CancelaVenda := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_AbreConferenciaMesa');
        if ValidPointer( aFunc, 'Bematech_FIR_AbreConferenciaMesa' ) then
          fFuncBematech_FIR_AbreConferenciaMesa := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_FechaConferenciaMesa');
        if ValidPointer( aFunc, 'Bematech_FIR_FechaConferenciaMesa' ) then
          fFuncBematech_FIR_FechaConferenciaMesa := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_TransferenciaMesa');
        if ValidPointer( aFunc, 'Bematech_FIR_TransferenciaMesa' ) then
          fFuncBematech_FIR_TransferenciaMesa := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_ContaDividida');
        if ValidPointer( aFunc, 'Bematech_FIR_ContaDividida' ) then
          fFuncBematech_FIR_ContaDividida := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_ContaDividida');
        if ValidPointer( aFunc, 'Bematech_FIR_ContaDividida' ) then
          fFuncBematech_FIR_ContaDividida := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_FechaCupomContaDividida');
        if ValidPointer( aFunc, 'Bematech_FIR_FechaCupomContaDividida' ) then
          fFuncBematech_FIR_FechaCupomContaDividida := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_TransferenciaItem');
        if ValidPointer( aFunc, 'Bematech_FIR_TransferenciaItem' ) then
          fFuncBematech_FIR_TransferenciaItem := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_RelatorioMesasAbertas');
        if ValidPointer( aFunc, 'Bematech_FIR_RelatorioMesasAbertas' ) then
          fFuncBematech_FIR_RelatorioMesasAbertas := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_ImprimeCardapio');
        if ValidPointer( aFunc, 'Bematech_FIR_ImprimeCardapio' ) then
          fFuncBematech_FIR_ImprimeCardapio := aFunc
        else
          bRet := False;

       aFunc := GetProcAddress(fHandle,'Bematech_FIR_ConferenciaMesa');
        if ValidPointer( aFunc, 'Bematech_FIR_ConferenciaMesa' ) then
          fFuncBematech_FIR_ConferenciaMesa := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_ConferenciaMesa');
        if ValidPointer( aFunc, 'Bematech_FIR_ConferenciaMesa' ) then
          fFuncBematech_FIR_ConferenciaMesa := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_RelatorioMesasAbertasSerial');
        if ValidPointer( aFunc, 'Bematech_FIR_RelatorioMesasAbertasSerial' ) then
          fFuncBematech_FIR_RelatorioMesasAbertasSerial := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_CardapioPelaSerial');
        if ValidPointer( aFunc, 'Bematech_FIR_CardapioPelaSerial' ) then
          fFuncBematech_FIR_CardapioPelaSerial := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_RegistroVendaSerial');
        if ValidPointer( aFunc, 'Bematech_FIR_RegistroVendaSerial' ) then
          fFuncBematech_FIR_RegistroVendaSerial := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_VerificaMemoriaLivre');
        if ValidPointer( aFunc, 'Bematech_FIR_VerificaMemoriaLivre' ) then
          fFuncBematech_FIR_VerificaMemoriaLivre := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_FechaCupomRestaurante');
        if ValidPointer( aFunc, 'Bematech_FIR_FechaCupomRestaurante' ) then
          fFuncBematech_FIR_FechaCupomRestaurante := aFunc
        else
          bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FIR_FechaCupomResumidoRestaurante');
        if ValidPointer( aFunc, 'Bematech_FIR_FechaCupomResumidoRestaurante' ) then
          fFuncBematech_FIR_FechaCupomResumidoRestaurante := aFunc
        else
          bRet := False;
      end
      else
      begin
        GravaLog('Funções para impressora restaurante não são carregadas, pois não existem na DLL');
      end;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_CNPJMFD');
      if ValidPointer( aFunc, 'Bematech_FI_CNPJMFD' ) then
        fFuncBematech_FI_CNPJMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_InscricaoEstadualMFD');
      if ValidPointer( aFunc , 'Bematech_FI_InscricaoEstadualMFD')
      then fFuncBematech_FI_InscricaoEstadualMFD := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_RegistrosTipo60');
      if ValidPointer( aFunc, 'Bematech_FI_RegistrosTipo60' ) then
        fFuncBematech_FI_RegistrosTipo60 := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ModeloImpressora');
      if ValidPointer( aFunc, 'Bematech_FI_ModeloImpressora' ) then
        fFuncBematech_FI_ModeloImpressora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional');
      if ValidPointer( aFunc, 'Bematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional' ) then
        fFuncBematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_MarcaModeloTipoImpressoraMFD');
      if ValidPointer( aFunc, 'Bematech_FI_MarcaModeloTipoImpressoraMFD' ) then
        fFuncBematech_FI_MarcaModeloTipoImpressoraMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ContadorRelatoriosGerenciaisMFD');
      if ValidPointer( aFunc, 'Bematech_FI_ContadorRelatoriosGerenciaisMFD' ) then
        fFuncBematech_FI_ContadorRelatoriosGerenciaisMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ContadorComprovantesCreditoMFD');
      if ValidPointer( aFunc, 'Bematech_FI_ContadorComprovantesCreditoMFD' ) then
        fFuncBematech_FI_ContadorComprovantesCreditoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_DataHoraUltimoDocumentoMFD');
      if ValidPointer( aFunc, 'Bematech_FI_DataHoraUltimoDocumentoMFD' ) then
        fFuncBematech_FI_DataHoraUltimoDocumentoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle1,'BemaGeraRegistrosTipoE');
      if ValidPointer( aFunc, 'BemaGeraRegistrosTipoE', sArqBemaMfd1 ) then
        fFuncBemaGeraRegistrosTipoEMFD1 := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle2,'BemaGeraRegistrosTipoE');
      if ValidPointer( aFunc, 'BemaGeraRegistrosTipoE', sArqBemaMfd2 ) then
        fFuncBemaGeraRegistrosTipoEMFD2 := aFunc
      else
        bRet := False;


      aFunc := GetProcAddress(fHandle,'Bematech_FI_ArquivoMFD');
      if ValidPointer( aFunc, 'Bematech_FI_ArquivoMFD' ) then
        fFuncBematech_FI_GeraArquivoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ArquivoMFDPath');
      If ValidPointer( aFunc , 'Bematech_FI_ArquivoMFDPath')
      then fFuncBematech_FI_ArquivoMFDPath := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreRelatorioGerencialMFD');
      if  ValidPointer( aFunc, 'Bematech_FI_AbreRelatorioGerencialMFD') then
        fFuncBematech_FI_AbreRelatorioGerencialMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaRelatorioGerencialMFD');
      if ValidPointer( aFunc , 'Bematech_FI_VerificaRelatorioGerencialMFD') then
        fFuncBematech_FI_VerificaRelatorioGerencialMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_UsaRelatorioGerencialMFD');
      If ValidPointer( aFunc , 'Bematech_FI_UsaRelatorioGerencialMFD' ) then
        fFuncBematech_FI_UsaRelatorioGerencialMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_CodigoBarrasITFMFD');
      If ValidPointer( aFunc , 'Bematech_FI_CodigoBarrasITFMFD' ) then
        fFuncBematech_FI_CodigoBarrasITFMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_ConfiguraCodigoBarrasMFD');
      if ValidPointer( aFunc , 'Bematech_FI_ConfiguraCodigoBarrasMFD')
      then fFuncBematech_FI_ConfiguraCodigoBarrasMFD := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_EstornoNaoFiscalVinculadoMFD');
      If ValidPointer( aFunc , 'Bematech_FI_EstornoNaoFiscalVinculadoMFD' ) then
        fFuncBematech_FI_EstornoNaoFiscalVinculadoMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_DownloadMF');
      If ValidPointer( aFunc , 'Bematech_FI_DownloadMF' )
      then fFuncBematech_FI_DownloadMF := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreRecebimentoNaoFiscalMFD');
      If ValidPointer( aFunc , 'Bematech_FI_AbreRecebimentoNaoFiscalMFD')
      then fFuncBematech_FI_AbreRecebimentoNaoFiscalMFD := aFunc
      else bRet := False;

      aFunc := GetProcAddress( fHandle , 'Bematech_FI_FechaRecebimentoNaoFiscalMFD');
      if ValidPointer( aFunc , 'Bematech_FI_FechaRecebimentoNaoFiscalMFD')
      then fFuncBematech_FI_FechaRecebimentoNaoFiscalMFD := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_EfetuaRecebimentoNaoFiscalMFD');
      if ValidPointer( aFunc , 'Bematech_FI_EfetuaRecebimentoNaoFiscalMFD')
      then fFuncBematech_FI_EfetuaRecebimentoNaoFiscalMFD := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaFormasPagamentoMFD');
      If ValidPointer( aFunc , 'Bematech_FI_VerificaFormasPagamentoMFD')
      then fFuncBematech_FI_VerificaFormasPagamentoMFD := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Bematech_FI_MinutosEmitindoDocumentosFiscaisCV0909');
      If (ValidPointer( aFunc, 'Bematech_FI_MinutosEmitindoDocumentosFiscaisCV0909',sArqIniBema,False )) then
      begin

        aFunc := GetProcAddress(fHandle,'Bematech_FI_MinutosEmitindoDocumentosFiscaisCV0909');
        if ValidPointer(aFunc , 'Bematech_FI_MinutosEmitindoDocumentosFiscaisCV0909')
        then fFuncBematech_FI_MinutosEmitindoDocumentosFiscaisCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_IniciaFechamentoRecebimentoNaoFiscalMFD');
        if ValidPointer(aFunc,'Bematech_FI_IniciaFechamentoRecebimentoNaoFiscalMFD')
        then ffuncBematech_FI_IniciaFechamentoRecebimentoNaoFiscalMFD := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_EfetuaFormaPagamentoMFD');
        If ValidPointer(aFunc,'Bematech_FI_EfetuaFormaPagamentoMFD')
        then fFuncBematech_FI_EfetuaFormaPagamentoMFD := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_SubTotalizaRecebimentoMFD');
        If ValidPointer(aFunc,'Bematech_FI_SubTotalizaRecebimentoMFD')
        then fFuncBematech_FI_SubTotalizaRecebimentoMFD := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_TotalizaRecebimentoMFD');
        If ValidPointer(aFunc,'Bematech_FI_TotalizaRecebimentoMFD')
        then fFuncBematech_FI_TotalizaRecebimentoMFD := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaRecebimentoNaoFiscalMFD');
        If ValidPointer(aFunc , 'Bematech_FI_VerificaRecebimentoNaoFiscalMFD')
        then fFuncBematech_FI_VerificaRecebimentoNaoFiscalMFD := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroCupomCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_NumeroCupomCV0909' )
        then fFuncBematech_FI_NumeroCupomCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroOperacoesNaoFiscaisCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_NumeroOperacoesNaoFiscaisCV0909' )
        then fFuncBematech_FI_NumeroOperacoesNaoFiscaisCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_NumeroSerieCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_NumeroSerieCV0909' )
        then fFuncBematech_FI_NumeroSerieCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_RetornoAliquotasCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_RetornoAliquotasCV0909' )
        then fFuncBematech_FI_RetornoAliquotasCV0909 := aFunc
        else bRet := False;


        aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaFormasPagamentoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_VerificaFormasPagamentoCV0909' )
        then fFuncBematech_FI_VerificaFormasPagamentoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaIndiceAliquotasIssCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_VerificaIndiceAliquotasIssCV0909' )
        then fFuncBematech_FI_VerificaIndiceAliquotasIssCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaRecebimentoNaoFiscalCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_VerificaRecebimentoNaoFiscalCV0909' )
        then fFuncBematech_FI_VerificaRecebimentoNaoFiscalCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_VerificaTotalizadoresNaoFiscaisCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_VerificaTotalizadoresNaoFiscaisCV0909' )
        then fFuncBematech_FI_VerificaTotalizadoresNaoFiscaisCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_VersaoFirmwareCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_VersaoFirmwareCV0909' )
        then fFuncBematech_FI_VersaoFirmwareCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_TempoEmitindoOperacionalCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_TempoEmitindoOperacionalCV0909' )
        then fFuncBematech_FI_TempoEmitindoOperacionalCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreComprovanteNaoFiscalVinculadoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_AbreComprovanteNaoFiscalVinculadoCV0909' )
        then fFuncBematech_FI_AbreComprovanteNaoFiscalVinculadoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreCupomCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_AbreCupomCV0909' )
        then fFuncBematech_FI_AbreCupomCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreRecebimentoNaoFiscalCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_AbreRecebimentoNaoFiscalCV0909' )
        then fFuncBematech_FI_AbreRecebimentoNaoFiscalCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_AbreRelatorioGerencialCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_AbreRelatorioGerencialCV0909' )
        then fFuncBematech_FI_AbreRelatorioGerencialCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_AcionaGuilhotinaCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_AcionaGuilhotinaCV0909' )
        then fFuncBematech_FI_AcionaGuilhotinaCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_AcrescimoDescontoItemCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_AcrescimoDescontoItemCV0909' )
        then fFuncBematech_FI_AcrescimoDescontoItemCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_AcrescimoDescontoSubtotalCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_AcrescimoDescontoSubtotalCV0909' )
        then fFuncBematech_FI_AcrescimoDescontoSubtotalCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_CancelaAcrescimoDescontoItemCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_CancelaAcrescimoDescontoItemCV0909' )
        then fFuncBematech_FI_CancelaAcrescimoDescontoItemCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_CancelaAcrescimoDescontoSubtotalCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_CancelaAcrescimoDescontoSubtotalCV0909' )
        then fFuncBematech_FI_CancelaAcrescimoDescontoSubtotalCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_CancelaCupomCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_CancelaCupomCV0909' )
        then fFuncBematech_FI_CancelaCupomCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_CancelaCupomAtualCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_CancelaCupomAtualCV0909' )
        then fFuncBematech_FI_CancelaCupomAtualCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_DownloadMFCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_DownloadMFCV0909' )
        then fFuncBematech_FI_DownloadMFCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_DownloadMFDCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_DownloadMFDCV0909' )
        then fFuncBematech_FI_DownloadMFDCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_DownloadSBCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_DownloadSBCV0909' )
        then fFuncBematech_FI_DownloadSBCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_EfetuaFormaPagamentoIndiceCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_EfetuaFormaPagamentoIndiceCV0909' )
        then fFuncBematech_FI_EfetuaFormaPagamentoIndiceCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_EfetuaRecebimentoNaoFiscalCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_EfetuaRecebimentoNaoFiscalCV0909' )
        then fFuncBematech_FI_EfetuaRecebimentoNaoFiscalCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_EstornoFormasPagamentoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_EstornoFormasPagamentoCV0909' )
        then fFuncBematech_FI_EstornoFormasPagamentoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_EstornoNaoFiscalVinculadoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_EstornoNaoFiscalVinculadoCV0909' )
        then fFuncBematech_FI_EstornoNaoFiscalVinculadoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_FechaRecebimentoNaoFiscalCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_FechaRecebimentoNaoFiscalCV0909' )
        then fFuncBematech_FI_FechaRecebimentoNaoFiscalCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_FechaRelatorioGerencialCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_FechaRelatorioGerencialCV0909' )
        then fFuncBematech_FI_FechaRelatorioGerencialCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_ImpressaoFitaDetalheCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_ImpressaoFitaDetalheCV0909' )
        then fFuncBematech_FI_ImpressaoFitaDetalheCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalDataCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_LeituraMemoriaFiscalDataCV0909' )
        then fFuncBematech_FI_LeituraMemoriaFiscalDataCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalReducaoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_LeituraMemoriaFiscalReducaoCV0909' )
        then fFuncBematech_FI_LeituraMemoriaFiscalReducaoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalSerialDataCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_LeituraMemoriaFiscalSerialDataCV0909' )
        then fFuncBematech_FI_LeituraMemoriaFiscalSerialDataCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_LeituraMemoriaFiscalSerialReducaoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_LeituraMemoriaFiscalSerialReducaoCV0909' )
        then fFuncBematech_FI_LeituraMemoriaFiscalSerialReducaoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_ReducaoZCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_ReducaoZCV0909' )
        then fFuncBematech_FI_ReducaoZCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_ReimpressaoNaoFiscalVinculadoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_ReimpressaoNaoFiscalVinculadoCV0909' )
        then fFuncBematech_FI_ReimpressaoNaoFiscalVinculadoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_SangriaCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_SangriaCV0909' )
        then fFuncBematech_FI_SangriaCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_SegundaViaNaoFiscalVinculadoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_SegundaViaNaoFiscalVinculadoCV0909' )
        then fFuncBematech_FI_SegundaViaNaoFiscalVinculadoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_SuprimentoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_SuprimentoCV0909' )
        then fFuncBematech_FI_SuprimentoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_TerminaFechamentoCupomCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_TerminaFechamentoCupomCV0909' )
        then fFuncBematech_FI_TerminaFechamentoCupomCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_UsaRelatorioGerencialCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_UsaRelatorioGerencialCV0909' )
        then fFuncBematech_FI_UsaRelatorioGerencialCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_VendeItemCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_VendeItemCV0909' )
        then fFuncBematech_FI_VendeItemCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_InterrompeLeiturasCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_InterrompeLeiturasCV0909' )
        then fFuncBematech_FI_InterrompeLeiturasCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_ImprimeRTDCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_ImprimeRTDCV0909' )
        then fFuncBematech_FI_ImprimeRTDCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_BufferRespostaCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_BufferRespostaCV0909' )
        then fFuncBematech_FI_BufferRespostaCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaAliquotaCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_ProgramaAliquotaCV0909' )
        then fFuncBematech_FI_ProgramaAliquotaCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaHorarioVeraoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_ProgramaHorarioVeraoCV0909' )
        then fFuncBematech_FI_ProgramaHorarioVeraoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_NomeiaTotalizadorNaoSujeitoIcmsCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_NomeiaTotalizadorNaoSujeitoIcmsCV0909' )
        then fFuncBematech_FI_NomeiaTotalizadorNaoSujeitoIcmsCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaIdAplicativoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_ProgramaIdAplicativoCV0909' )
        then fFuncBematech_FI_ProgramaIdAplicativoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_NomeiaRelatorioGerencialCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_NomeiaRelatorioGerencialCV0909' )
        then fFuncBematech_FI_NomeiaRelatorioGerencialCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_ProgramaFormaPagamentoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_ProgramaFormaPagamentoCV0909' )
        then fFuncBematech_FI_ProgramaFormaPagamentoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_DadosUltimaReducaoCV0909');
        If ValidPointer( aFunc , 'Bematech_FI_DadosUltimaReducaoCV0909' )
        then fFuncBematech_FI_DadosUltimaReducaoCV0909 := aFunc
        else bRet := False;

        aFunc := GetProcAddress(fHandle,'Bematech_FI_VendaLiquida');
        If ValidPointer( aFunc , 'Bematech_FI_VendaLiquida' )
        then fFuncBematech_FI_VendaLiquida := aFunc
        else bRet := False;
      end
      else
      begin
        GravaLog(' Funções do Convênio 0909 não foram encontradas ');
      end;
    end
    else
    begin
       LjMsgDlg('Algum dos arquivos ' + sArqDllBema + ' ou ' + sArqBemaMfd1 + ' ou ' + sArqBemaMfd2 + ' não foi encontrado.');
       bRet := False;
    end;

    if bRet then
    begin
      //a Bemafi32.DLL abre e fecha a porta automáticamente
      iRet := 1;
      If iRet <> 1 then
      begin
        LjMsgDlg('Erro na abertura da porta');
        result := '1|';
      end
      else bOpened := True;

      If lEstendido Then
      begin
        GravaLog('  Bematech_FI_HabilitaDesabilitaRetornoEstendidoMFD -> ');
        iRet := fFuncBematech_FI_HabilitaDesabilitaRetornoEstendidoMFD(pchar(cFlag));
        GravaLog('  Bematech_FI_HabilitaDesabilitaRetornoEstendidoMFD <- iRet:' + IntToStr(iRet));
      end;
    end
    else
    begin
      result := '1|';
    end;
  End;
End;

//----------------------------------------------------------------------------
Function CloseBematech : String;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      //a Bemafi32.DLL abre e fecha a porta automáticamente
      fHandle := 0;
    end;
    bOpened := False;
  End;
  Result := '0';
end;

//----------------------------------------------------------------------------
Function TrataRetornoBematech( var iRet:Integer; lEstendido:Boolean = False ):String;
var
  sMsg : String;
begin

 GravaLog(' Retorno Bematech <- iRet: '+ IntToStr(iRet) );

  If (iRet < 1) and (iRet > -27) then
  begin
    sMsg := MsgErroBematech( iRet );
    If sMsg <> '' then
    begin
      MessageDlg( sMsg, mtError,[mbOK],0);
      GravaLog(' Erro na execução do comando anterior com mensagem de erro - [' + sMsg + ']');
    end;

    Status_Impressora(True, lEstendido);
    lError := True;
  end
  else if iRet = -27 then
  begin
    lError := True;
    iRet := Status_Impressora(False, lEstendido);
    GravaLog(' Erro na execução do comando anterior ');
  end;

  Result := '';
end;

// ------------------- Analisa Retorno da Impressora --------------------
Function Status_Impressora( lMensagem:Boolean; lEstendido:Boolean = False ): Integer;
Var
  iACK, iST1, iST2, iST3, iRet: Integer;
  sMensagem : String;
Begin
    iACK := 0;
    iST1 := 0;
    iST2 := 0;
    iST3 := 0;
    sMensagem := '';

    If lEstendido Then
      iRet := fFuncBematech_FI_RetornoImpressoraMFD(iACK, iST1, iST2, iST3)
    Else
      iRet := fFuncBematech_FI_RetornoImpressora(iACK, iST1, iST2);

      If lEstendido Then
        begin
          sMensagem := ' ' + Retorno_Estendido( iST3 );
           GravaLog(' <- Status Bematech: ACK:'+ IntToStr(iACK) + ', ST1:' + IntToStr(iST1) + ', ST2:' + IntToStr(iST2) + ', ST3:' + IntToStr(iST3) + sMensagem );
        end
      Else
         GravaLog(' <- Status Bematech: ACK:'+ IntToStr(iACK) + ', ST1:' + IntToStr(iST1) + ', ST2:' + IntToStr(iST2) );

    If iACK = 21 Then
    Begin
      Result := -27
    End
    Else
    Begin
      If (iACK = 6) and ((iST1 <> 0) or (iST2 <> 0)) then
      begin
          // Verifica ST1
          If iST1 >= 128 Then begin iST1 := iST1 - 128; iRet := 0 ; If lMensagem then LjMsgDlg('Fim de Papel'); end;
          If iST1 >= 64  Then begin iST1 := iST1 - 64;  iRet := 1 ; {If lMensagem then LjMsgDlg('Pouco Papel');}lError := False; end;
          If iST1 >= 32  Then begin iST1 := iST1 - 32;  iRet := 0 ; If lMensagem then LjMsgDlg('Erro no Relógio'); end;
          If iST1 >= 16  Then begin iST1 := iST1 - 16;  iRet := 0 ; If lMensagem then LjMsgDlg('Impressora em Erro'); end;
          If iST1 >= 8   Then begin iST1 := iST1 - 8;   iRet := 0 ; If lMensagem then LjMsgDlg('CMD não iniciado com ESC'); end;
          If iST1 >= 4   Then begin iST1 := iST1 - 4;   iRet := 0 ; If lMensagem then LjMsgDlg('Comando Inexistente'); end;
          If iST1 >= 2   Then begin iST1 := iST1 - 2;   iRet := 0 ; If lMensagem then LjMsgDlg('Cupom Aberto'); end;
          If iST1 >= 1   Then begin iST1 := iST1 - 1;   iRet := 0 ; If lMensagem then LjMsgDlg('Nº de Parâmetros Inválidos'); end;

          // Verifica ST2
          If iST2 >= 128 Then begin iST2 := iST2 - 128; iRet := 0 ; If lMensagem then LjMsgDlg('Tipo de Parâmetro Inválido'); end;
          If iST2 >= 64  Then begin iST2 := iST2 - 64;  iRet := 0 ; If lMensagem then LjMsgDlg('Memória Fiscal Lotada'); end;
          If iST2 >= 32  Then begin iST2 := iST2 - 32;  iRet := 0 ; If lMensagem then LjMsgDlg('CMOS não Volátil'); end;
          If iST2 >= 16  Then begin iST2 := iST2 - 16;  iRet := 0 ; If lMensagem then LjMsgDlg('Alíquota Não Programada'); end;
          If iST2 >= 8   Then begin iST2 := iST2 - 8;   iRet := 0 ; If lMensagem then LjMsgDlg('Alíquotas Lotadas'); end;
          If iST2 >= 4   Then begin iST2 := iST2 - 4;   iRet := 0 ; If lMensagem then LjMsgDlg('Cancelamento Não Permitido'); end;
          If iST2 >= 2   Then begin iST2 := iST2 - 2;   iRet := 0 ; If lMensagem then LjMsgDlg('CGC/IE Não Programados'); end;
          If iST2 >= 1   Then begin iST2 := iST2 - 1;   iRet := 0 ; {If lMensagem then LjMsgDlg('Comando Não Executado');} end;
      End;
      Result := iRet;
    End;
End;

//----------------------------------------------------------------------------
Function MsgErroBematech( iRet:Integer ):String;
var
  sMsg : String;
begin
  sMsg := '';
  Case iRet of
     0  : sMsg := 'Erro de comunicação';
    -1  : sMsg := 'Erro de execução da função';
    -2  : sMsg := 'Parâmetro inválido';
    -3  : sMsg := 'Alíquota não programada';
    -4  : sMsg := 'Arquivo BemaFi32.ini não encontrado ou parâmetro inválido para o nome da porta';
    -5  : sMsg := 'Erro ao abrir a porta de comunicação';
    -6  : sMsg := 'Impressora desligada ou desconectada';
    -7  : sMsg := 'Banco não localizado no arquivo de configuração BemaFi32.ini';
    -8  : sMsg := 'Erro ao criar ou gravar no arquivo status.txt ou retorno.txt';
    -9  : sMsg := 'Erro ao fechar a porta';
    -18 : sMsg := 'Não foi possível abrir arquivo INTPOS.001';
    -19 : sMsg := 'Parâmetro diferentes';
    -20 : sMsg := 'Transação cancelada pelo Operador';
    -21 : sMsg := 'A Transação não foi aprovada';
    -22 : sMsg := 'Não foi possível terminal a Impressão';
    -23 : sMsg := 'Não foi possível terminal a Operação';
  end;
  Result :=  sMsg;
end;

// ------------------- Verifica Status da Impressora --------------------
Function Verifica_Status( lMensagem:Boolean; lEstendido:Boolean = False ): Integer;
Var
  iACK, iST1, iST2, iST3, iRet: Integer;
  sMensagem : String;
Begin
    iACK := 0;
    iST1 := 0;
    iST2 := 0;
    iST3 := 0;
    sMensagem := '';

    If lEstendido Then
    begin
      GravaLog('-> Bematech_FI_VerificaEstadoImpressoraMFD(iACK, iST1, iST2, iST3)');
      iRet := fFuncBematech_FI_VerificaEstadoImpressoraMFD(iACK, iST1, iST2, iST3);
    end
    Else
    begin
      GravaLog(' -> Bematech_FI_VerificaEstadoImpressora(iACK, iST1, iST2)');
      iRet := fFuncBematech_FI_VerificaEstadoImpressora(iACK, iST1, iST2);
    end;

    If (iACK = 6) and ((iST1 <> 0) or (iST2 <> 0) or (iST3 <> 0)) then
    begin

      // Verifica ST1
      If iST1 <> 0 then
      begin
        If iST1 >= 128 Then begin iST1 := iST1 - 128; iRet := 0 ; sMensagem := 'Fim de Papel'; end;
        If iST1 >= 64  Then begin iST1 := iST1 - 64;  iRet := 1 ; sMensagem := 'Pouco Papel'; end;
        If iST1 >= 32  Then begin iST1 := iST1 - 32;  iRet := 0 ; sMensagem := 'Erro no Relógio'; end;
        If iST1 >= 16  Then begin iST1 := iST1 - 16;  iRet := 0 ; sMensagem := 'Impressora em Erro'; end;
        If iST1 >= 8   Then begin iST1 := iST1 - 8;   iRet := 0 ; sMensagem := 'CMD não iniciado com ESC'; end;
        If iST1 >= 4   Then begin iST1 := iST1 - 4;   iRet := 0 ; sMensagem := 'Comando Inexistente'; end;
        If iST1 >= 2   Then begin iST1 := iST1 - 2;   iRet := 0 ; sMensagem := 'Cupom Aberto'; end;
        If iST1 >= 1   Then begin iST1 := iST1 - 1;   iRet := 0 ; sMensagem := 'Nº de Parâmetros Inválidos'; end;
      end;

      // Verifica ST2
      If iST2 <> 0 then
      begin
        If iST2 >= 128 Then begin iST2 := iST2 - 128; iRet := 0 ; sMensagem := 'Tipo de Parâmetro Inválido'; end;
        If iST2 >= 64  Then begin iST2 := iST2 - 64;  iRet := 0 ; sMensagem := 'Memória Fiscal Lotada'; end;
        If iST2 >= 32  Then begin iST2 := iST2 - 32;  iRet := 0 ; sMensagem := 'CMOS não Volátil'; end;
        If iST2 >= 16  Then begin iST2 := iST2 - 16;  iRet := 0 ; sMensagem := 'Alíquota Não Programada'; end;
        If iST2 >= 8   Then begin iST2 := iST2 - 8;   iRet := 0 ; sMensagem := 'Alíquotas Lotadas'; end;
        If iST2 >= 4   Then begin iST2 := iST2 - 4;   iRet := 0 ; sMensagem := 'Cancelamento Não Permitido'; end;
        If iST2 >= 2   Then begin iST2 := iST2 - 2;   iRet := 0 ; sMensagem := 'CGC/IE Não Programados'; end;
        If iST2 >= 1   Then begin iST2 := iST2 - 1;   iRet := 0 ; sMensagem := 'Comando Não Executado'; end;
      end;

      //Verifica ST3
      If iST3 <> 0 then
      begin
        iRet := 1;
        sMensagem := Retorno_Estendido( iST3 );
      end;

      //Apresentacao de Mensagem
      If lMensagem then LjMsgDlg(sMensagem);

    end;

    If lEstendido Then
       GravaLog(' <- Retorno Bematech: ACK:'+ IntToStr(iACK) + ', ST1:' + IntToStr(iST1) + ', ST2:' + IntToStr(iST2) + ', ST3:' + IntToStr(iST3) + sMensagem )
    Else
       GravaLog(' <- Retorno Bematech: ACK:'+ IntToStr(iACK) + ', ST1:' + IntToStr(iST1) + ', ST2:' + IntToStr(iST2) );

    Result := iRet;
End;

//----------------------------------------------------------------------------
Function Retorno_Estendido( iST3 : Integer ): String;
Var sMensagem : String;
begin

  Case iST3 of
    1 : sMensagem := 'COMANDO INVÁLIDO';
    2 : sMensagem := 'ERRO DESCONHECIDO';
    3 : sMensagem := 'NÚMERO DE PARÂMETRO INVÁLIDO';
    4 : sMensagem := 'TIPO DE PARÂMETRO INVÁLIDO';
    5 : sMensagem := 'TODAS ALÍQUOTAS JÁ PROGRAMADAS';
    6 : sMensagem := 'TOTALIZADOR NÃO FISCAL JÁ PROGRAMADO';
    7 : sMensagem := 'CUPOM FISCAL ABERTO';
    8 : sMensagem := 'CUPOM FISCAL FECHADO';
    9 : sMensagem := 'ECF OCUPADO';
   10 : sMensagem := 'IMPRESSORA EM ERRO';
   11 : sMensagem := 'IMPRESSORA SEM PAPEL';
   12 : sMensagem := 'IMPRESSORA COM CABEÇA LEVANTADA';
   13 : sMensagem := 'IMPRESSORA OFF LINE';
   14 : sMensagem := 'ALÍQUOTA NÃO PROGRAMADA';
   15 : sMensagem := 'TERMINADOR DE STRING FALTANDO';
   16 : sMensagem := 'ACRÉSCIMO OU DESCONTO MAIOR QUE O TOTAL DO CUPOM FISCAL';
   17 : sMensagem := 'CUPOM FISCAL SEM ITEM VENDIDO';
   18 : sMensagem := 'COMANDO NÃO EFETIVADO';
   19 : sMensagem := 'SEM ESPAÇO PARA NOVAS FORMAS DE PAGAMENTO';
   20 : sMensagem := 'FORMA DE PAGAMENTO NÃO PROGRAMADA';
   21 : sMensagem := 'ÍNDICE MAIOR QUE NÚMERO DE FORMA DE PAGAMENTO';
   22 : sMensagem := 'FORMAS DE PAGAMENTO ENCERRADAS';
   23 : sMensagem := 'CUPOM NÃO TOTALIZADO';
   24 : sMensagem := 'COMANDO MAIOR QUE 7Fh (1   27d)';
   25 : sMensagem := 'CUPOM FISCAL ABERTO E SEM ÍTEM';
   26 : sMensagem := 'CANCELAMENTO NÃO IMEDIATAMENTE APÓS';
   27 : sMensagem := 'CANCELAMENTO JÁ EFETUADO';
   28 : sMensagem := 'COMPROVANTE DE CRÉDITO OU DÉBITO NÃO PERMITIDO OU JÁ EMITIDO';
   29 : sMensagem := 'MEIO DE PAGAMENTO NÃO PERMITE TEF';
   30 : sMensagem := 'SEM COMPROVANTE NÃO FISCAL ABERTO';
   31 : sMensagem := 'COMPROVANTE DE CRÉDITO OU DÉBITO JÁ ABERTO';
   32 : sMensagem := 'REIMPRESSÃO NÃO PERMITIDA';
   33 : sMensagem := 'COMPROVANTE NÃO FISCAL JÁ ABERTO';
   34 : sMensagem := 'TOTALIZADOR NÃO FISCAL NÃO PROGRAMADO';
   35 : sMensagem := 'CUPOM NÃO FISCAL SEM ÍTEM VENDIDO';
   36 : sMensagem := 'ACRÉSCIMO E DESCONTO MAIOR QUE TOTAL CNF';
   37 : sMensagem := 'MEIO DE PAGAMENTO NÃO INDICADO';
   38 : sMensagem := 'MEIO DE PAGAMENTO DIFERENTE DO TOTAL DO RECEBIMENTO';
   39 : sMensagem := 'NÃO PERMITIDO MAIS DE UMA SANGRIA OU SUPRIMENTO';
   40 : sMensagem := 'RELATÓRIO GERENCIAL JÁ PROGRAMADO';
   41 : sMensagem := 'RELATÓRIO GERENCIAL NÃO PROGRAMADO';
   42 : sMensagem := 'RELATÓRIO GERENCIAL NÃO PERMITIDO';
   43 : sMensagem := 'MFD NÃO INICIALIZADA';
   44 : sMensagem := 'MFD AUSENTE';
   45 : sMensagem := 'MFD SEM NÚMERO DE SÉRIE';
   46 : sMensagem := 'MFD JÁ INICIALIZADA';
   47 : sMensagem := 'MFD LOTADA';
   48 : sMensagem := 'CUPOM NÃO FISCAL ABERTO';
   49 : sMensagem := 'MEMÓRIA FISCAL DESCONECTADA';
   50 : sMensagem := 'MEMÓRIA FISCAL SEM NÚMERO DE SÉRIE DA MFD';
   51 : sMensagem := 'MEMÓRIA FISCAL LOTADA';
   52 : sMensagem := 'DATA INICIAL INVÁLIDA';
   53 : sMensagem := 'DATA FINAL INVÁLIDA';
   54 : sMensagem := 'CONTADOR DE REDUÇÃO Z INICIAL INVÁLIDO';
   55 : sMensagem := 'CONTADOR DE REDUÇÃO Z FINAL INVÁLIDO';
   56 : sMensagem := 'ERRO DE ALOCAÇÃO';
   57 : sMensagem := 'DADOS DO RTC INCORRETOS';
   58 : sMensagem := 'DATA ANTERIOR AO ÚLTIMO DOCUMENTO EMITIDO';
   59 : sMensagem := 'FORA DE INTERVENÇÃO TÉCNICA';
   60 : sMensagem := 'EM INTERVENÇÃO TÉCNICA';
   61 : sMensagem := 'ERRO NA MEMÓRIA DE TRABALHO';
   62 : sMensagem := 'JÁ HOUVE MOVIMENTO NO DIA';
   63 : sMensagem := 'BLOQUEIO POR RZ';
   64 : sMensagem := 'FORMA DE PAGAMENTO ABERTA';
   65 : sMensagem := 'AGUARDANDO PRIMEIRO PROPRIETÁRIO';
   66 : sMensagem := 'AGUARDANDO RZ';
   67 : sMensagem := 'ECF OU LOJA IGUAL A ZERO';
   68 : sMensagem := 'CUPOM ADICIONAL NÃO PERMITIDO';
   69 : sMensagem := 'DESCONTO MAIOR QUE TOTAL VENDIDO EM ICMS';
   70 : sMensagem := 'RECEBIMENTO NÃO FISCAL NULO NÃO PERMITIDO';
   71 : sMensagem := 'ACRÉSCIMO OU DESCONTO MAIOR QUE TOTAL NÃO FISCAL';
   72 : sMensagem := 'MEMÓRIA FISCAL LOTADA PARA NOVO CARTUCHO';
   73 : sMensagem := 'ERRO DE GRAVAÇÃO NA MF';
   74 : sMensagem := 'ERRO DE GRAVAÇÃO NA MFD';
   75 : sMensagem := 'DADOS DO RTC ANTERIORES AO ÚLTIMO DOC ARMAZENADO';
   76 : sMensagem := 'MEMÓRIA FISCAL SEM ESPAÇO PARA GRAVAR LEITURAS DA MFD';
   77 : sMensagem := 'MEMÓRIA FISCAL SEM ESPAÇO PARA GRAVAR VERSAO DO SB';
   78 : sMensagem := 'DESCRIÇÃO IGUAL A DEFAULT NÃO PERMITIDO';
   79 : sMensagem := 'EXTRAPOLADO NÚMERO DE REPETIÇÕES PERMITIDAS';
   80 : sMensagem := 'SEGUNDA VIA DO COMPROVANTE DE CRÉDITO OU DÉBITO NÃO PERMITIDO';
   81 : sMensagem := 'PARCELAMENTO FORA DA SEQUÊNCIA';
   82 : sMensagem := 'COMPROVANTE DE CRÉDITO OU DÉBITO ABERTO';
   83 : sMensagem := 'TEXTO COM SEQUÊNCIA DE ESC INVÁLIDA';
   84 : sMensagem := 'TEXTO COM SEQUÊNCIA DE ESC INCOMPLETA';
   85 : sMensagem := 'VENDA COM VALOR NULO';
   86 : sMensagem := 'ESTORNO DE VALOR NULO';
   87 : sMensagem := 'FORMA DE PAGAMENTO DIFERENTE DO TOTAL DA SANGRIA';
   88 : sMensagem := 'REDUÇÃO NÃO PERMITIDA EM INTERVENÇÃO TÉCNICA';
   89 : sMensagem := 'AGUARDANDO RZ PARA ENTRADA EM INTERVENÇÃO TÉCNICA';
   90 : sMensagem := 'FORMA DE PAGAMENTO COM VALOR NULO NÃO PERMITIDO';
   91 : sMensagem := 'ACRÉSCIMO E DESCONTO MAIOR QUE VALOR DO ÍTEM';
   92 : sMensagem := 'AUTENTICAÇÃO NÃO PERMITIDA';
   93 : sMensagem := 'TIMEOUT NA VALIDAÇÃO';
   94 : sMensagem := 'COMANDO NÃO EXECUTADO EM IMPRESSORA BILHETE DE PASSAGEM';
   95 : sMensagem := 'COMANDO NÃO EXECUTADO EM IMPRESSORA DE CUPOM FISCAL';
   96 : sMensagem := 'CUPOM NÃO FISCAL FECHADO';
   97 : sMensagem := 'PARÂMETRO NÃO ASCII EM CAMPO ASCII';
   98 : sMensagem := 'PARÂMETRO NÃO ASCII NUMÉRICO EM CAMPO ASCII NUMÉRICO';
   99 : sMensagem := 'TIPO DE TRANSPORTE INVÁLIDO';
  100 : sMensagem := 'DATA E HORA INVÁLIDA';
  101 : sMensagem := 'SEM RELATÓRIO GERENCIAL OU COMPROVANTE DE CRÉDITO OU DÉBITO ABERTO';
  102 : sMensagem := 'NÚMERO DO TOTALIZADOR NÃO FISCAL INVÁLIDO';
  103 : sMensagem := 'PARÂMETRO DE ACRÉSCIMO OU DESCONTO INVÁLIDO';
  104 : sMensagem := 'ACRÉSCIMO OU DESCONTO EM SANGRIA OU SUPRIMENTO NÃO PERMITIDO';
  105 : sMensagem := 'NÚMERO DO RELATÓRIO GERENCIAL INVÁLIDO';
  106 : sMensagem := 'FORMA DE PAGAMENTO ORIGEM NÃO PROGRAMADA';
  107 : sMensagem := 'FORMA DE PAGAMENTO DESTINO NÃO PROGRAMADA';
  108 : sMensagem := 'ESTORNO MAIOR QUE FORMA PAGAMENTO';
  109 : sMensagem := 'CARACTER NUMÉRICO NA CODIFICAÇÃO GT NÃO PERMITIDO';
  110 : sMensagem := 'ERRO NA INICIALIZAÇÃO DA MF';
  111 : sMensagem := 'NOME DO TOTALIZADOR EM BRANCO NÃO PERMITIDO';
  112 : sMensagem := 'DATA E HORA ANTERIORES AO ÚLTIMO DOC ARMAZENADO';
  113 : sMensagem := 'PARÂMETRO DE ACRÉSCIMO OU DESCONTO INVÁLIDO';
  114 : sMensagem := 'ÍTEM ANTERIOR AOS TREZENTOS ÚLTIMOS';
  115 : sMensagem := 'ÍTEM NÃO EXISTE OU JÁ CANCELADO';
  116 : sMensagem := 'CÓDIGO COM ESPAÇOS NÃO PERMITIDO';
  117 : sMensagem := 'DESCRICAO SEM CARACTER ALFABÉTICO NÃO PERMITIDO';
  118 : sMensagem := 'ACRÉSCIMO MAIOR QUE VALOR DO ÍTEM';
  119 : sMensagem := 'DESCONTO MAIOR QUE VALOR DO ÍTEM';
  120 : sMensagem := 'DESCONTO EM ISS NÃO PERMITIDO';
  121 : sMensagem := 'ACRÉSCIMO EM ÍTEM JÁ EFETUADO';
  122 : sMensagem := 'DESCONTO EM ÍTEM JÁ EFETUADO';
  123 : sMensagem := 'ERRO NA MEMÓRIA FISCAL CHAMAR CREDENCIADO';
  124 : sMensagem := 'AGUARDANDO GRAVAÇÃO NA MEMÓRIA FISCAL';
  125 : sMensagem := 'CARACTER REPETIDO NA CODIFICAÇÃO DO GT';
  126 : sMensagem := 'VERSÃO JÁ GRAVADA NA MEMÓRIA FISCAL';
  127 : sMensagem := 'ESTOURO DE CAPACIDADE NO CHEQUE';
  128 : sMensagem := 'TIMEOUT NA LEITURA DO CHEQUE';
  129 : sMensagem := 'MÊS INVÁLIDO';
  130 : sMensagem := 'COORDENADA INVÁLIDA';
  131 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO';
  132 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO NO VALOR';
  133 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO NO EXTENSO';
  134 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO NO FAVORECIDO';
  135 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO NA LOCALIDADE';
  136 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO NO OPCIONAL';
  137 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO NO DIA';
  138 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO NO MÊS';
  139 : sMensagem := 'SOBREPOSIÇÃO DE TEXTO NO ANO';
  140 : sMensagem := 'USANDO MFD DE OUTRO ECF';
  141 : sMensagem := 'PRIMEIRO DADO DIFERENTE DE ESC OU   1C';
  142 : sMensagem := 'NÃO PERMITIDO ALTERAR SEM INTERVENÇÃO TÉCNICA';
  143 : sMensagem := 'DADOS DA ÚLTIMA RZ CORROMPIDOS';
  144 : sMensagem := 'COMANDO NÃO PERMITIDO NO MODO INICIALIZAÇÃO';
  145 : sMensagem := 'AGUARDANDO ACERTO DE RELÓGIO';
  146 : sMensagem := 'MFD JÁ INICIALIZADA PARA OUTRA MF';
  147 : sMensagem := 'AGUARDANDO ACERTO DO RELÓGIO OU DESBLOQUEIO PELO TECLADO';
  148 : sMensagem := 'VALOR FORMA DE PAGAMENTO MAIOR QUE MÁXIMO PERMITIDO';
  149 : sMensagem := 'RAZÃO SOCIAL EM BRANCO';
  150 : sMensagem := 'NOME DE FANTASIA EM BRANCO';
  151 : sMensagem := 'ENDEREÇO EM BRANCO';
  152 : sMensagem := 'ESTORNO DE CDC NÃO PERMITIDO';
  153 : sMensagem := 'DADOS DO PROPRIETÁRIO IGUAIS AO ATUAL';
  154 : sMensagem := 'ESTORNO DE FORMA DE PAGAMENTO NÃO PERMITIDO';
  155 : sMensagem := 'DESCRIÇÃO FORMA DE PAGAMENTO IGUAL JÁ PROGRAMADA';
  156 : sMensagem := 'ACERTO DE HORÁRIO DE VERÃO SÓ IMEDIATAMENTE APÓS RZ';
  157 : sMensagem := 'IT NÃO PERMITIDA MF RESERVADA PARA RZ';
  158 : sMensagem := 'SENHA CNPJ INVÁLIDA';
  159 : sMensagem := 'TIMEOUT NA INICIALIZAÇÃO DA NOVA MF';
  160 : sMensagem := 'NÃO ENCONTRADO DADOS NA MFD';
  161 : sMensagem := 'SANGRIA OU SUPRIMENTO DEVEM SER ÚNICOS NO CNF';
  162 : sMensagem := 'ÍNDICE DA FORMA DE PAGAMENTO NULO NÃO PERMITIDO';
  163 : sMensagem := 'UF DESTINO INVÁLIDA';
  164 : sMensagem := 'TIPO DE TRANSPORTE INCOMPATÍVEL COM UF DESTINO';
  165 : sMensagem := 'DESCRIÇÃO DO PRIMEIRO ÍTEM DO BILHETE DE PASSAGEM DIFERENTE DE "TARIFA"';
  166 : sMensagem := 'AGUARDANDO IMPRESSÃO DE CHEQUE OU AUTENTICAÇÃO';
  167 : sMensagem := 'NÃO PERMITIDO PROGRAMAÇAO CNPJ IE COM ESPAÇOS EM BRANCO';
  168 : sMensagem := 'NÃO PERMITIDO PROGRAMAÇÃO UF COM ESPAÇOS EM BRANCO';
  169 : sMensagem := 'NÚMERO DE IMPRESSÕES DA FITA DETALHE NESTA INTERVENÇÃO TÉCNICA ESGOTADO';
  170 : sMensagem := 'CF JÁ SUBTOTALIZADO';
  171 : sMensagem := 'CUPOM NÃO SUBTOTALIZADO';
  172 : sMensagem := 'ACRÉSCIMO EM SUBTOTAL JÁ EFETUADO';
  173 : sMensagem := 'DESCONTO EM SUBTOTAL JÁ EFETUADO';
  174 : sMensagem := 'ACRÉSCIMO NULO NÃO PERMITIDO';
  175 : sMensagem := 'DESCONTO NULO NÃO PERMITIDO';
  176 : sMensagem := 'CANCELAMENTO DE ACRÉSCIMO OU DESCONTO EM SUBTOTAL NÃO PERMITIDO';
  177 : sMensagem := 'DATA INVÁLIDA';
  178 : sMensagem := 'VALOR DO CHEQUE NULO NÃO PERMITIDO';
  179 : sMensagem := 'VALOR DO CHEQUE INVÁLIDO';
  180 : sMensagem := 'CHEQUE SEM LOCALIDADE NÃO PERMITIDO';
  181 : sMensagem := 'CANCELAMENTO ACRÉSCIMO EM ÍTEM NÃO PERMITIDO';
  182 : sMensagem := 'CANCELAMENTO DESCONTO EM ÍTEM NÃO PERMITIDO';
  183 : sMensagem := 'NÚMERO MÁXIMO DE ÍTENS ATINGIDO';
  184 : sMensagem := 'NÚMERO DE ÍTEM NULO NÃO PERMITIDO';
  185 : sMensagem := 'MAIS QUE DUAS ALÍQUOTAS DIFERENTES NO BILHETE DE PASSAGEM NÃO PERMITIDO';
  186 : sMensagem := 'ACRÉSCIMO OU DESCONTO EM ITEM NÃO PERMITIDO';
  187 : sMensagem := 'CANCELAMENTO DE ACRÉSCIMO OU DESCONTO EM ITEM NÃO PERMITIDO';
  188 : sMensagem := 'CLICHE JÁ IMPRESSO';
  189 : sMensagem := 'TEXTO OPCIONAL DO CHEQUE EXCEDEU O MÁXIMO PERMITIDO';
  190 : sMensagem := 'IMPRESSÃO AUTOMÁTICA NO VERSO NÃO PERMITIDO NESTE EQUIPAMENTO';
  191 : sMensagem := 'TIMEOUT NA INSERÇÃO DO CHEQUE';
  192 : sMensagem := 'OVERFLOW NA CAPACIDADE DE TEXTO DO COMPROVANTE DE CRÉDITO OU DÉBITO';
  193 : sMensagem := 'PROGRAMAÇÃO DE ESPAÇOS ENTRE CUPONS MENOR QUE O MÍNIMO PERMITIDO';
  194 : sMensagem := 'EQUIPAMENTO NÃO POSSUI LEITOR DE CHEQUE';
  195 : sMensagem := 'PROGRAMAÇÃO DE ALÍQUOTA COM VALOR NULO NÃO PERMITIDO';
  196 : sMensagem := 'PARÂMETRO BAUD RATE INVÁLIDO';
  197 : sMensagem := 'CONFIGURAÇÃO PERMITIDA SOMENTE PELA PORTA DOS FISCO';
  198 : sMensagem := 'VALOR TOTAL DO ITEM EXCEDE   1  1 DÍGITOS';
  199 : sMensagem := 'PROGRAMAÇÃO DA MOEDA COM ESPAÇOS EM BRACO NÃO PERMITIDO';
  200 : sMensagem := 'CASAS DECIMAIS DEVEM SER PROGRAMADAS COM 2 OU 3';
  201 : sMensagem := 'NÃO PERMITE CADASTRAR USUÁRIOS DIFERENTES NA MESMA MFD';
  202 : sMensagem := 'IDENTIFICAÇÃO DO CONSUMIDOR NÃO PERMITIDA PARA SANGRIA OU SUPRIMENTO';
  203 : sMensagem := 'CASAS DECIMAIS EM QUANTIDADE MAIOR DO QUE A PERMITIDA';
  204 : sMensagem := 'CASAS DECIMAIS DO UNITÁRIO MAIOR DO QUE O PERMITIDA';
  205 : sMensagem := 'POSIÇÃO RESERVADA PARA ICMS';
  206 : sMensagem := 'POSIÇÃO RESERVADA PARA ISS';
  207 : sMensagem := 'TODAS AS ALÍQUOTAS COM A MESMA VINCULAÇÃO NÃO PERMITIDO';
  208 : sMensagem := 'DATA DE EMBARQUE ANTERIOR A DATA DE EMISSÃO';
  209 : sMensagem := 'ALÍQUOTA DE ISS NÃO PERMITIDA SEM INSCRIÇÃO MUNICIPAL';
  210 : sMensagem := 'RETORNO PACOTE CLICHE FORA DA SEQUÊNCIA';
  211 : sMensagem := 'ESPAÇO PARA ARMAZENAMENTO DO CLICHE ESGOTADO';
  212 : sMensagem := 'CLICHE GRÁFICO NÃO DISPONÍVEL PARA CONFIRMAÇÃO';
  213 : sMensagem := 'CRC DO CLICHE GRÁFICO DIFERENTE DO INFORMADO';
  214 : sMensagem := 'INTERVALO INVÁLIDO';
  215 : sMensagem := 'USUÁRIO JÁ PROGRAMADO';
  217 : sMensagem := 'DETECTADA ABERTURA DO EQUIPAMENTO';
  218 : sMensagem := 'CANCELAMENTO DE ACRÉSCIMO/DESCONTO NÃO PERMITIDO';
  end;

  Result := sMensagem;

End;

//----------------------------------------------------------------------------
function TImpBematech.Abrir(sPorta : String; iHdlMain:Integer) : String;
begin
  sMarca := 'BEMATECH';

  // Verifica o arquivo de configuracao da Bematech.
  If ArqIniBematech( sPorta, sMarca, '0' ) then
  begin
    If Not bOpened Then
      Result := OpenBematech(sPorta)
    Else
      Result := '0';
    // Carrega as aliquotas e N. PDV para ganhar performance
    If Copy(Result,1,1) = '0' then
    begin
      AlimentaProperties;
      If lError then
      begin
        Result := '1';
        LjMsgDlg( MsgErroProp );
      end
    end
  end
  Else
    LjMsgDlg( 'Problemas com o arquivo ' + sArqIniBema );
end;

//----------------------------------------------------------------------------
function TImpBematech.Fechar( sPorta:String ):String;
begin
  Result := CloseBematech;
end;

//----------------------------------------------------------------------------
function TImpBematech.AbreEcf:String;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpBematech.FechaEcf:String;
var
  iRet : Integer;
  sData : String;
  sHora : String;
begin
  // chama a funcao de ReducaoZ
  DateTimeToString( sData, 'ddmmyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  GravaLog(' Bematech_FI_ReducaoZ -> ');
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  GravaLog(' Bematech_FI_ReducaoZ <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.LeituraX:String;
var
  iRet : Integer;
begin
  GravaLog(' Bematech_FI_LeituraX -> ');
  iRet := fFuncBematech_FI_LeituraX;
  GravaLog(' Bematech_FI_LeituraX <- iRet:' + IntToStr(iREt));
  TrataRetornoBematech( iRet );
  if iRet = 1
  then  Result := '0'
  Else  Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.ReducaoZ(MapaRes:String):String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i : Integer;
  sData, sHora : String;
  aRetorno : array of String;
  sRetorno : String;
  sLinhaISS, sTotalISS : String;
  fFile : TextFile;
  sFile, sLinha, sFlag : String;
  fBase, fAliq : Real;
begin
 If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := Pdv;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[ 5] := aRetorno[ 6];

    aRetorno[ 7] := Space (14);                         //**** Valor do Cancelamento ****//
    iRet := fFuncBematech_FI_Cancelamentos( aRetorno[ 7] );
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    aRetorno[ 9] := Space (14);                         //**** Desconto ****//
    iRet := fFuncBematech_FI_Descontos( aRetorno[ 9] );
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    sRetorno := Space(445);
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciais(sRetorno);

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

    aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS
    aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS
    aRetorno[20]:= '00';                                         // QTD DE Aliquotas

    iRet := fFuncBematech_FI_LeituraXSerial();
    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
      sFile := LeArqBema('Sistema','Path') + '\' +'RETORNO.TXT';

      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '';
        While not Eof(fFile) do
        Begin
          ReadLn(fFile, sLinha);
          sLinha := TrataLinha(sLinha);
          if ( Pos('COO DO PRIMEIRO CUPOM FISCAL' , UpperCase(sLinha))>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
          if ( Pos('VENDA LÖQUIDA',UpperCase(sLinha))>0) or ( Pos('VENDA LÍQUIDA',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
          if ( Pos('REIN¡CIO ',UpperCase(sLinha))>0) or ( Pos('REINÍCIO ',UpperCase(sLinha))>0) or ( Pos('Reinício',sLinha)>0) then  // CRO - Contador de Reinício de Operação
            aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
          if ( Pos('TOTAL',UpperCase(sLinha))>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
          begin
            if sFlag = 'S' // Verifica se é aliquota de ISS e soma o total ao array
            then aRetorno[16] := sTotalISS + ';' + aRetorno[16];

            // desliga a captura das aliquotas
            sFlag:='';
          end;

          if ( sFlag='T' ) and ( Copy(sLinha,4,1)='T' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            sLinha := StrTran( sLinha, '*', ' ' );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            if Copy(sLinha,24,1) = ',' then
              aRetorno[High(aRetorno)]:=Copy(sLinha,4,6)+' '+FormataTexto(StrTran(Copy(sLinha,13,14),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,28,13),'.',''),14,2,1,'.')
            Else
              aRetorno[High(aRetorno)]:=Copy(sLinha,4,6)+' '+FormataTexto(StrTran(Copy(sLinha,16,14),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,36,13),'.',''),14,2,1,'.');
          End;

          // Totais ISS
          if ( sFlag='S' ) and ( Copy(sLinha,4,1)='S' ) then
          Begin
            // ' Valor '  ' Imposto Debitado
             fBase:= StrToFloat(StrTran(StrTran(copy(sLinha,14,16),'.',''),',','.'));
             fAliq:= StrToFloat(StrTran(StrTran(copy(sLinha,32,17),'.',''),',','.'));
             sTotalISS :=FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,1,14))+ fBase) ,14,2,1)+' '+
                            FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,16,14))+ fAliq) ,14,2,1);
                          //Aliquota                    //Valor Base                                    //Valor Debitado
             sLinhaISS := StrTran(Copy( sLinha , 1 , 6),',','.') + ' ' + FormataTexto(FloatToStr(fBase) ,14,2,1) + ' ' +
                           FormataTexto(FloatToStr(fAliq) ,14,2,1) + ';' ; // ';' separador de aliquotas de ISS
             aRetorno[16] := aRetorno[16] + sLinhaISS ;
          End;

          if (Pos('---------------Tributados---------------',sLinha)>0) then
          // Liga a captura das aliquotas de ICMS
            sFlag:='T';
          if (Pos('------------------ISS-------------------',sLinha)>0) then
          begin
            // Liga a captura das aliquotas de ISS
            sFlag:='S';
            sTotalISS := '00000000000.00 00000000000.00';
          end;
        end;
        CloseFile(fFile);

        If Trim(aRetorno[16]) = ''
        then aRetorno[16]:= '00000000000.00 00000000000.00';
      end
    end;
 end;

  DateTimeToString( sData, 'ddmmyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    ReducaoEmitida := True;

    If Trim(MapaRes) ='S' then
    begin
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';
    end
    Else
        Result := '0';
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.AbreCupom(Cliente:String; MensagemRodape:String):String;
var
  iRet : Integer;
begin
  lDescAcres:=False;

  If Pos('|', Cliente) > 0 then
    Cliente := Copy( Cliente, 1, (Pos('|',Cliente) - 1));

  If Length( Cliente ) > 29 then
    Cliente := Copy( Cliente, 1, 29 );

  GravaLog(' Bematech_FI_AbreCupom ->');
  iRet := fFuncBematech_FI_AbreCupom( Cliente );
  GravaLog(' Bematech_FI_AbreCupom <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  // Este Sleep foi colocado pois ocorre falha quando usa a funcao NumeroCupom logo em seguida.
  // Conforme conversa na Bematech, estão fazendo uma revisão neste comando.
  // Tirar o Sleep quando estiver Ok.
  Sleep(3000);
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.PegaCupom(Cancelamento:String):String;
var
  iRet : Integer;
  sNumCupom : String;
begin
  sNumCupom := Space( 6 );
  GravaLog(' Bematech_FI_NumeroCupom -> ');
  iRet := fFuncBematech_FI_NumeroCupom( sNumCupom );
  GravaLog(' Bematech_FI_NumeroCupom <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  If iRet = 1
  then Result := '0|' + sNumCupom
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.PegaPDV:String;
begin
  Result := '0|' + Pdv;
end;

//----------------------------------------------------------------------------
function TImpBematech.LeAliquotas:String;
begin
  Result := '0|' + ICMS;
end;

//----------------------------------------------------------------------------
function TImpBematech.LeAliquotasISS:String;
begin
  Result := '0|' + ISS;
end;

//----------------------------------------------------------------------------
function TImpBematech.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
    function CapturaIndAliqtICMS(AliqBusca: string): String;
    var i: Integer;
        sRet : String;
    begin
        i := 1;
        sRet := '';
        Repeat
            If Pos(AliqBusca, aIndAliq[i])>0 then
               sRet := aIndAliq[i-1]
            Else
               i := i + 2;
        Until (sRet <> '') or (i > 20);
        Result := sRet;
    end;
var
  iRet : Integer;
  sTrib,sAliquota,sIndiceISS, sAliqISS, sTipoQtd : String;
  iCasas: Integer;
  bIssAlq : Boolean;
begin
  iCasas:=2;
  bIssAlq := False;
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
  End;

  If sTrib = 'T' then
  begin
     sAliquota := FormataTexto(Copy(aliquota,2,5),4,2,1,'.');
     If Pos(sAliquota, ISS)> 0 then
     begin
         sAliquota := CapturaIndAliqtICMS('T'+sAliquota);
     end
     Else
         sAliquota := FormataTexto(StrTran( StrTran( sAliquota, ',', '' ), '.', '' ),4,0,2);
  end;
  
  If sTrib = 'S' then
  Begin
        sAliquota := '';
        sAliqISS := LeAliquotasISS();
        sAliqISS := Copy(sAliqISS, 3, Length(sAliqISS));
        sIndiceISS := Space(48);
        iRet := fFuncBematech_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoBematech(iRet);
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
    fFuncBematech_FI_AumentaDescricaoItem(Descricao);
    // Coloca o tamanho da descrição para 29 posições devido a uma obrigatoriedade da função Bematech_FI_VendeItem
    Descricao:=Copy(Descricao, 1, 29);
  End;

  // Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
  sTipoQtd := 'F';

  // Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionária
  Qtde := FormataTexto( qtde, 7, 3, 2 );

  // Numero de cadas decimais para o preço unitário
  If Pos('.',vlrUnit) > 0 then
    If StrtoFloat(copy(vlrUnit,Pos('.',vlrUnit)+1,Length(vlrUnit))) > 99
    then iCasas := 3
    Else iCasas := 2;

  // Valor unitário deve ter até 8 digitos
  vlrUnit := FormataTexto( vlrUnit, 8, iCasas, 2 );

  // Valor desconto deve ter até 8 digitos
  vlrDesconto := FormataTexto( vlrDesconto, 8, 2, 2 );

  // Usa a unidade de medida
  If Trim(UnidMed) <> '' Then
  Begin
    If Length(UnidMed) > 2  Then
    begin
      //Unidade de Medida deve ter até 2 dígitos
      UnidMed := Copy(UnidMed,1,2);
    end;
    GravaLog(' Bematech_FI_UsaUnidadeMedida -> ' + UnidMed );
    iRet := fFuncBematech_FI_UsaUnidadeMedida(UnidMed);
    GravaLog(' Bematech_FI_UsaUnidadeMedida <- iRet: ' + IntToStr(iRet) )
  End;

  If iRet <> 1
  then Result := '1';

  // Registra o Item
  GravaLog('-> Bematech_FI_VendeItem  = ' + pChar( sTrib + sAliquota ) + ' , ' + sTipoQtd + ' , '  + pChar( Qtde ) + ' , '  +
           pChar( vlrUnit ) + ' , '  + '$' + ' , '  + pChar( vlrDesconto ) + ' , '  + pChar( Codigo )
            + ' , '  + pChar( UnidMed ) + ' , '  + pChar( descricao ));

  iRet := fFuncBematech_FI_VendeItem( Codigo, descricao, sAliquota, sTipoQtd, Qtde, iCasas, vlrUnit,'$', vlrDesconto );

  GravaLog('<- Bematech_FI_VendeItem : ' + IntToStr(iRet));

  TrataRetornoBematech( iRet );
  If iRet = 1
  then Result := '0'
  Else Result := '1';

end;

//----------------------------------------------------------------------------
function TImpBematech.CancelaCupom(Supervisor:String):String;
var
  iRet : Integer;
begin
  // Para cancelar um cupom aberto deve-ser ter ao menos um item vendido.
  GravaLog(' Bematech_FI_CancelaCupom ');
  iRet := fFuncBematech_FI_CancelaCupom;
  GravaLog(' Bematech_FI_CancelaCupom <- iRet :' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.LeCondPag:String;
var
  iRet, i : Integer;
  sRet : String;
  sPagto : String;
begin
  sRet := Space( 3016 );
  iRet := fFuncBematech_FI_VerificaFormasPagamento( sRet );
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    sPagto := '';
    For i:=0 to 48 do
        If Trim(Copy(sRet,1,16))<>'' then
        begin
            sPagto := sPagto + Trim(copy( sRet, 1, 16 )) + '|';
            sRet:= Copy(sRet,59,Length(sRet));
        end
        Else
        Begin
            sRet:= Copy(sRet,59,Length(sRet));
        end;
    Result := '0|' + sPagto;
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.LeTotNFisc:String;

 //Inicio função Estática RetornaIndiceTot
 function RetornaIndiceTot(sRelGerenciais : String ; PosTotalizador : Integer) : String;
   var
     sRet,sAux : String;
     nCont,nQtdeVirg,nPosVirg: Integer;
   begin
     sRet      := '01';
     nCont     := 0 ;
     nQtdeVirg := 0;
     sAux      := sRelGerenciais ;
     while nCont < PosTotalizador do
     begin
       nPosVirg := Pos(',',sAux);
       StringReplace(sAux,',','|',[]);
       If nPosVirg > 0 then
       begin
        Inc(nQtdeVirg);
        nCont := nCont + nPosVirg;
       end;
     end;

     If nQtdeVirg > 0
     then sRet := FormataTexto(IntToStr(nQtdeVirg),2,0,1);

     Result := sRet;
   end;
   //final Função Estática Retona Indice Tot


var
  iRet, iPos, iCont : Integer;
  sRet, sAux : String;
  sTotaliz : String;
begin
  sRet := Space( 179);
  iRet := fFuncBematech_FI_VerificaTotalizadoresNaoFiscais( sRet );

  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    sTotaliz := '';
    iPos := Pos(',', sRet);
    sAux := sRet;
    iCont := 0;
    If iPos = 0 then iPos := Length(sRet);
    while iPos > 0 do
     begin
       sAux := Copy(sRet, 1, iPos-1);
       sRet := Copy(sRet, iPos+1, length(sRet)-iPos) ;
       iPos := Pos(',', sRet);
       If iPos = 0 then iPos := Length(sRet);
       Inc(iCont);
       sTotaliz := sTotaliz + FormataTexto( IntToStr(iCont), 2, 0, 4) + ',' + sAux + '|';
     end;

    Result := '0|' + sTotaliz;
  end
  Else
    Result := '1';
 
end;

//----------------------------------------------------------------------------
function TImpBematech.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var
  iRet : Integer;
begin
  NumItem := FormataTexto( numitem, 3, 0, 2 );
  GravaLog(' Bematech_FI_CancelaItemGenerico -> ' + numitem);
  iRet := fFuncBematech_FI_CancelaItemGenerico( NumItem );
  GravaLog(' Bematech_FI_CancelaItemGenerico <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.FechaCupom( Mensagem:String ):String;
var
  iRet : Integer;
  cMsg : String;
begin
    cMsg := TrataTags( Mensagem );
    If Length(cMsg) > 380 then
    begin
      GravaLog( ' FechaCupom - Será efetuado o corte da mensagem pois esta enviando conteudo maior' +
      ' do que o permitido pela impressora - ' + CHR(10) + CHR(13) +
      ' Verifique configurações de mensagem ' +
      'no cadastro de Estação ou o parametro MV_LJFISMS  ' + CHR(10) + CHR(13) +
      ' Deixo-os em branco / Diminua o conteúdo / Modifique as mensagens ' );

      cMsg := Copy(cMsg,1,380);
      GravaLog('FechaCupom - Corte efetuado em 380 caracteres ');

    end;
    GravaLog(' Bematech_FI_TerminaFechamentoCupom -> ' + cMsg);
    iRet := fFuncBematech_FI_TerminaFechamentoCupom(cMsg);
    GravaLog(' Bematech_FI_TerminaFechamentoCupom <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
       iRet := Status_Impressora( True );
       if iRet = 1
       then Result := '0'
       else Result := '1';
    end
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;
var iRet    : integer;
    sFrmPag : String;
    sVlrPag : String;
begin
    If not lDescAcres then
    begin
      GravaLog(' Bematech_FI_IniciaFechamentoCupom -> D , $ , 0.00');
      iRet := fFuncBematech_FI_IniciaFechamentoCupom('D', '$', Pchar('0.00'));
      GravaLog(' Bematech_FI_IniciaFechamentoCupom <- iRet : ' + IntToStr(iRet));
    end;

    while Length(pagamento)>0 do
    begin
      If Pos('|',Pagamento) > 17
      then sFrmPag := Copy(Pagamento,1,16)
      else sFrmPag:=Copy(Pagamento,1,Pos('|',Pagamento)-1);

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

      GravaLog(' Bematech_FI_EfetuaFormaPagamento -> Forma: ' + sFrmPag + ', Valor :' + sVlrPag );
      iRet := fFuncBematech_FI_EfetuaFormaPagamento( sFrmPag , sVlrPag);
      GravaLog(' Bematech_FI_EfetuaFormaPagamento <- iRet:' + IntToStr(iRet) );
    end;

    TrataRetornoBematech( iRet );
    If iRet = 1
    then Result := '0'
    Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String;
var iRet: integer;
begin
    GravaLog(' Bematech_FI_IniciaFechamentoCupom -> Desconto: ' + vlrDesconto );
    iRet := fFuncBematech_FI_IniciaFechamentoCupom('D', '$', Pchar(vlrDesconto));
    GravaLog(' Bematech_FI_IniciaFechamentoCupom <- iRet:' + IntToStr(iRet) );
    TrataRetornoBematech( iRet );

    If iRet = 1 then
    begin
       lDescAcres:=True;
       Result := '0';
    End
    Else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.AcrescimoTotal( vlrAcrescimo:String ): String;
var iRet: integer;
begin
    GravaLog(' Bematech_FI_IniciaFechamentoCupom -> Acrescimo: ' + vlrAcrescimo );
    iRet := fFuncBematech_FI_IniciaFechamentoCupom('A','$', Pchar(vlrAcrescimo));
    GravaLog(' Bematech_FI_IniciaFechamentoCupom <- iRet:' + IntToStr(iRet) );
    TrataRetornoBematech( iRet );
    If iRet >= 0 then
    Begin
       lDescAcres:=True;
       Result := '0';
    End
    Else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String;
var
  iRet : Integer;
  sDatai : String;
  sDataf : String;
  sPath  : String;
begin

  //if Tipo='I' then
  //Impressao
  if Pos( 'I', UpperCase( Tipo ) ) > 0 then
  begin
      // Se o relatório for por Data
      If Trim(ReducInicio) + Trim(ReducFim) = '' then
      begin
        sDatai := FormataData( DataInicio, 1 );
        sDataf := FormataData( DataFim, 1 );
        iRet := fFuncBematech_FI_LeituraMemoriaFiscalData(sDatai,sDataf);
        TrataRetornoBematech( iRet );
        If iRet >= 0 then
          Result := '0'
        Else
          Result := '1';
      end
      Else       // Se o relatório será por redução Z
      Begin
        iRet :=fFuncBematech_FI_LeituraMemoriaFiscalReducao(Pchar(ReducInicio),Pchar(ReducFim));
        TrataRetornoBematech( iRet );
        If iRet >= 0 then
          Result := '0'
        Else
          Result := '1';
      end;
  end
  //Arquivo
  Else
  Begin
      // Se o relatório for por Data
      If Trim(ReducInicio) + Trim(ReducFim) = '' then
      begin
        sDatai := FormataData( DataInicio, 4 );
        sDataf := FormataData( DataFim, 4 );
        iRet := fFuncBematech_FI_LeituraMemoriaFiscalSerialData(sDatai,sDataf);
      end
      Else       // Se o relatório será por redução Z
        iRet :=fFuncBematech_FI_LeituraMemoriaFiscalSerialReducao(ReducInicio,ReducFim);

      TrataRetornoBematech( iRet );
      If iRet = 1 then
      Begin
        // Pega caminho onde foi gravado o arquivo RETORNO.TXT
        sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );
        // Grava arquivo no local indicado
        Result := CopRenArquivo( sPath, sArqRetBema, PathArquivo, DEFAULT_ARQMEMCOM );
      end
      Else
         Result := '1';

  end;

end;

//----------------------------------------------------------------------------
function TImpBematech.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
// Tipo = 1 - ICMS
// Tipo = 2 - ISS
var
  iRet : Integer;
begin
    If Tipo=1 then Tipo := 0;
    If Tipo=2 then Tipo := 1;
    Aliquota := FormataTexto(Aliquota,5,2,1);
    Aliquota := StrTran(Aliquota,'.',',');
    iRet := fFuncBematech_FI_ProgramaAliquota( Aliquota , Tipo );
    TrataRetornoBematech( iRet );
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
function TImpBematech.AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String;
var
  iRet: Integer;
begin
  GravaLog(' -> AbreCupomNaoFiscal: INICIO' );
  GravaLog(' -> AbreCupomNaoFiscal: '+Condicao+'|'+Valor+'|'+Totalizador+'|'+Texto );
  // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if Pos('.', Valor) = 0 then
  begin
    Valor    := Trim(Valor);
    Valor    := Copy(Valor,1,length(Valor)-2)+'.'+Copy(Valor,length(Valor)-1,2);
  end;

  Valor    := Trim(FormataTexto( Valor, 14, 2, 3 ));
  Valor    := StrTran(Valor,'.',',');
//  A forma de pagamento utilizada no comprovante vinculado não pode ser "Dinheiro",
// mas pode ser "DINHEIRO".
  Condicao := Copy( Condicao, 1, 16 );

  //*******************************************************************************
  // Abre o comprovante não fiscal. Tenta abrir um vinculado mas caso não consiga
  // faz um recebimento não fiscal para depois abrir o comprovante não fiscal
  // Condicao = Descricao da Forma de pagamento - Nao pode ser DINHEIRO
  //*******************************************************************************
  Status_Impressora( False );
  GravaLog(' -> AbreComprovanteNaoFiscalVinculado: TEF' );
  iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( Condicao , '', '' );
  GravaLog(' <- AbreComprovanteNaoFiscalVinculado: '+ IntToStr(iRet) );
  If iRet <> 0 then
  Begin
      If Status_Impressora( False ) = 1
      then  Result := '0'
      Else
      begin
             //*******************************************************************************
             // Faz um recebimento não fiscal para abrir o cupom vinculado
             //*******************************************************************************
             GravaLog(' -> RecebimentoNaoFiscal: '+Totalizador+'|'+Valor+'|'+Condicao );
             iRet := fFuncBematech_FI_RecebimentoNaoFiscal( pchar(Totalizador), pchar(Valor), pchar(Condicao) );
             GravaLog(' <- RecebimentoNaoFiscal: '+ IntToStr(iRet) );
             If Status_Impressora( False ) = 1 then
             begin
                //*******************************************************************************
                // Abre o comprovante vinculado
                //*******************************************************************************
                GravaLog(' -> AbreComprovanteNaoFiscalVinculado: RECEBIMENTO' );
                iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( Condicao, '', '' );
                GravaLog(' <- AbreComprovanteNaoFiscalVinculado: '+ IntToStr(iRet) );
                TrataRetornoBematech( iRet );
                If Status_Impressora( False ) = 1 then
                begin
                  If iRet = 1 then
                  begin
                    Result := '0';
                  End
                  Else
                    Result := '1';
                end;
             end
             Else
                Result := '1';
      end;
  End
  Else
    Result := '1';

  //*******************************************************************************
  // Se apresentou algum erro monstra a mensagem
  //*******************************************************************************
  If Result = '1'
  then TrataRetornoBematech( iRet );

  GravaLog(' AbreCupomNaoFiscal: FIM' );
end;

//----------------------------------------------------------------------------
function TImpBematech.TextoNaoFiscal( Texto:String; Vias:Integer ):String;
var
  i: Integer;
  sTexto  : String;
  iRet    : Integer;
  sLinha  :String;
  sVerDll : String;
  iConta : integer;
  sVerDllT : String;
  
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

 //Pegar a versao da dll
  for iConta := 1 to 9 do sVerDll := sVerDll + ' ';
  iRet := fFuncBematech_FI_VersaoDll( sVerDll );

  sVerDllT := StringReplace(sVerDll,',','',[rfReplaceAll]);

  // A partir da versao 4.1.2.0 que foi retirado o CR+LF, dessa forma verifica a versao
  //para saber o que fazer
  if StrToInt( sVerDllT ) < 4120
  then
  Begin

  // Laço para imprimir toda a mensagem
    While ( Trim(Texto)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 40 caracter do Texto
         If Pos(#10,Copy(Texto,1,41))>1 then
         begin
            sLinha := Copy(Texto,1, Pos(#10,Texto)-1);
            Texto  := Copy(Texto,Pos(#10,Texto)+1, Length(Texto));
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> Linha' + sLinha);
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
            TrataRetornoBematech( iRet );
         End
         Else If Pos(#10,Copy(Texto,1,41))=1 then
         Begin
            //manda os avancos de linha
            Texto := Copy(Texto,2,Length(Texto));
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> #13');
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( #13 );
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
         End
         Else
         Begin
            sLinha := Copy(Texto,1, 40);
            Texto  := Copy(Texto,41, Length(Texto));
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> QuebraLinha + Linha:' + sLinha);
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLinha + #10 + #13 );
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
            TrataRetornoBematech( iRet );
         End;

         // Ocorreu erro na impressão do cupom
         if iRet<>1 then
         Begin
            Result := '1';
            Break;
         End;
      End;
  end

  else
  begin
     While ( Trim(Texto)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 40 caracter do Texto
         If Pos(#10,Copy(Texto,1,41))>1 then
         begin
            sLinha := Copy(Texto,1, Pos(#10,Texto)-1) + #10 + #13;
            Texto  := Copy(Texto,Pos(#10,Texto)+1, Length(Texto));
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> Linha' + sLinha);
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
            TrataRetornoBematech( iRet );
         End
         Else If Pos(#10,Copy(Texto,1,41))=1 then
         Begin
            //envia os avancos de linha
            Texto := Copy(Texto,2,Length(Texto));
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> QuebraLinha ');
            iRet  := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( #10 + #13 );
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
         End
         Else
         Begin
            sLinha := Copy(Texto,1, 40) + #10 + #13;
            Texto  := Copy(Texto,41, Length(Texto));
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> Linha' + sLinha);
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
            GravaLog( ' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
            TrataRetornoBematech( iRet );
         End;

         // Ocorreu erro na impressão do cupom
         if iRet<>1 then
         Begin
            Result := '1';
            Break;
         End;
      End;
  end;
end;

//----------------------------------------------------------------------------
function TImpBematech.FechaCupomNaoFiscal: String;
var
  iRet : Integer;
begin
  GravaLog('Bematech_FI_FechaComprovanteNaoFiscalVinculado ->');
  iRet := fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
  GravaLog('Bematech_FI_FechaComprovanteNaoFiscalVinculado <- iRet : ' + IntToStr(iRet));

  If iRet = 1
  then Result := '0'
  else
  Begin
    iRet := Status_Impressora( True );
    If iRet = 1
    then Result := '0'
    Else Result := '1';
  End;

end;

//----------------------------------------------------------------------------
function TImpBematech.ReImpCupomNaoFiscal( Texto:String ):String;
begin
  LjMsgDlg( MsgIndsImp );
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpBematech.Suprimento( Tipo:Integer; Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
var
  iRet : Integer;
  sRet : String;
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
         GravaLog( ' Bematech_FI_Suprimento ->');
         iRet:= fFuncBematech_FI_Suprimento(Valor,Forma);
         GravaLog( ' Bematech_FI_Suprimento <- iRet: ' + IntToStr(iRet));
         TrataRetornoBematech( iRet );
         If iRet = 1
         then Result := '0'
         Else Result := '1';
        end;
    3: begin
         GravaLog( ' Bematech_FI_Sangria ->');
         iRet:= fFuncBematech_FI_Sangria(Valor);
         GravaLog( ' Bematech_FI_Sangria <- iRet: ' + IntToStr(iRet));
         TrataRetornoBematech( iRet );
         If iRet = 1
         then Result := '0'
         Else Result := '1';
       end;
  end;
end;

//----------------------------------------------------------------------------
function TImpBematech.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var
  iRet : Integer;
begin
  GravaLog( ' Bematech_FI_Autenticacao ->');
  iRet := fFuncBematech_FI_Autenticacao;
  GravaLog( ' Bematech_FI_Autenticacao <- iRet: ' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  If iRet = 1 then
      Result := '0'
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpBematech.StatusImp( Tipo:Integer ):String;
var
  iRet : Integer;
  sRet, Data, Hora, sDataHoje, sOperacoes, sUltimoItem,
  FlagTruncamento,sVendaBruta, sSubTotal, sGrandeTotal,
  sDataMov: String;
  dDtHoje,dDtMov : TDateTime;
  i,iAck, iSt1, iSt2 : Integer;
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
  // 17 - Verifica Venda Bruta (RICMS 01 - SC - ANEXO 09)
  // 18 - Verifica Grande Total (RICMS 01 - SC - ANEXO 09)
  // 19 - Retorna a data do movimento da impressora
  // 20 - Retorna o CNPJ cadastrado na impressora
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
    GravaLog(' Bematech_FI_DataHoraImpressora -> Status(1)');
    iRet := fFuncBematech_FI_DataHoraImpressora( Data, Hora );
    GravaLog(' Bematech_FI_DataHoraImpressora <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet );
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
    GravaLog(' Bematech_FI_DataHoraImpressora -> Status(2)');
    iRet := fFuncBematech_FI_DataHoraImpressora( Data, Hora );
    GravaLog(' Bematech_FI_DataHoraImpressora <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet );
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
    GravaLog(' Bematech_FI_VerificaEstadoImpressora -> Status(3)');
    iRet := fFuncBematech_FI_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
    GravaLog(' Bematech_FI_VerificaEstadoImpressora <- iRet:' + IntToStr(iRet));
    If iSt1 >= 128 Then
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
    GravaLog(' Bematech_FI_VerificaEstadoImpressora -> Status(5)');
    iRet := fFuncBematech_FI_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
    GravaLog(' Bematech_FI_VerificaEstadoImpressora <- iRet:' + IntToStr(iRet));
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
      GravaLog( ' Bematech_FI_VerificaFormasPagamento ->');
      iRet := fFuncBematech_FI_VerificaFormasPagamento( sRet );
      GravaLog( ' Bematech_FI_VerificaFormasPagamento <- iRet:'+IntToStr(iRet));
      TrataRetornoBematech( iRet );
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
    GravaLog(' Bematech_FI_DataMovimento ->');
    iRet:=fFuncBematech_FI_DataMovimento(Data);
    GravaLog(' Bematech_FI_DataMovimento <- iRet:' + IntToStr(iRet));
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

  //  9 - Verifica o Status do ECF
  Else If Tipo = 9 then
    Result := '0'

  // 10 - Verifica se todos os itens foram impressos.
  Else If Tipo = 10 then
    Result := '0'

  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  Else If Tipo = 11 then
    Result := '1'

  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  Else If Tipo = 12 then
    Result := '1'

  // 13 - Verifica se o ECF Arredonda o Valor do Item
  Else If Tipo = 13 then
  begin
    FlagTruncamento := Space(2);
    // Para o FlagTruncamento, retorna 1 se a impressora estiver no modo truncamento e 0 se estiver no modo arredondamento.
    GravaLog('Bematech_FI_VerificaTruncamento - >');
    iRet := fFuncBematech_FI_VerificaTruncamento( FlagTruncamento );
    GravaLog(' Bematech_FI_VerificaTruncamento <- iRet : ' + IntToStr(iRet));
    If iRet = 1 then
      Result := Copy( FlagTruncamento, 1, 1 )
    Else
      Result := '1';
  end

  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  else if Tipo = 14 then
    Result := '0'

  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  else if Tipo = 15 then
    Result := '1'

  // 16 - Verifica se exige o extenso do cheque
  else if Tipo = 16 then
    Result := '1'

  // 17 - Verifica venda bruta
  else if Tipo = 17 then
  begin
    sVendaBruta := Space(18);
    GravaLog( ' Bematech_FI_VendaBruta ->');
    iRet := fFuncBematech_FI_VendaBruta( sVendaBRuta );
    GravaLog( ' Bematech_FI_VendaBruta <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet );
    If iRet = 1 then
        Result := '0|' + sVendaBRuta
    Else
        Result := '1';
  end

  // 18 - Verifica Grande Total
  else if Tipo = 18 then
  begin
    sGrandeTotal:= Space(18);
    GravaLog( ' Bematech_FI_GrandeTotal -> ');
    iRet := fFuncBematech_FI_GrandeTotal( sGrandeTotal );
    GravaLog('  Bematech_FI_GrandeTotal <- iRet: ' + IntToStr(iRet) + ' / Retorno:' + sGrandeTotal );
    TrataRetornoBematech( iRet );
    If iRet = 1 then
        Result := '0|' + sGrandeTotal
    Else
        Result := '1';
  end

  // 19 - Verifica a data de movimento da impressora
  else if Tipo = 19 then
  begin
    sDataMov    := Space(6);
    sDataHoje   := Space(6);
    GravaLog('  Bematech_FI_DataMovimento -> ' );
    iRet        := fFuncBematech_FI_DataMovimento( sDataMov );
    GravaLog('  Bematech_FI_DataMovimento <- iRet: ' + IntToStr(iRet) + ' / Retorno:' + sDataMov );
    TrataRetornoBematech( iRet );
    If iRet = 1 Then
      begin
        sDataHoje := Copy(StatusImp(2),3,8);
          If sDataMov = '000000' then
            Result:= '2|'+ sDataHoje
          else
            begin
              sDataMov     := Copy(sDataMov,1,2)+'/'+Copy(sDataMov,3,2)+'/'+Copy(sDataMov,5,2);
              If (StrToDate(sDataMov) < StrToDate(sDataHoje)) then    // reducao pendente
                Result := '0|'+ sDataMov
              Else
                Result := '2|'+ sDataHoje;
            end
      end
    else
      // Retornou erro na opercao do 19
      Result := '-1';
  end

  // 20 - Retorna o CNPJ cadastrado na impressora
  else if Tipo = 20 then
    Result := '0|' + Cnpj

  // 21 - Retorna o IE cadastrado na impressora
  else if Tipo = 21 then
    Result := '0|' + Ie

  // 22 - Retorna o CRZ - Contador de Reduções Z
  else if Tipo = 22 then
  begin
    If ReducaoEmitida then
    begin
      GravaLog('  Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('  Bematech_FI_RegistrosTipo60 <- iRet: ' + IntToStr(iRet));
      TrataRetornoBematech( iRet );
      If iRet = 1 then
      begin
        ContadorCrz := LeArqRetorno( Path, sArqIniBema, 55 , 3 );
        Result := '0|' + ContadorCrz
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
    If IndicaMFAdi = '' Then
      IndicaMFAdi := Retorna_Informacoes(1);
    Result := '0|' + IndicaMFAdi;
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
      DataIntEprom := Retorna_Informacoes(2);
    Result := '0|' + DataIntEprom;
  end

  // 30 - Retorna o Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  else if Tipo = 30 then
  begin
    If HoraIntEprom = '' Then
      HoraIntEprom := Retorna_Informacoes(3);
    Result := '0|' + HoraIntEprom;
  end

  // 31 - Retorna o Nº de ordem seqüencial do ECF no estabelecimento usuário
  else if Tipo = 31 then
    Result := '0|' + Pdv

  // 32 - Retorna o Grande Total Inicial
  else if Tipo = 32 then
  begin
    If ReducaoEmitida then
    begin
      GravaLog('  Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('  Bematech_FI_RegistrosTipo60 <- iRet: ' + IntToStr(iRet));
      TrataRetornoBematech( iRet );
      If iRet = 1 then
      begin
        VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
        GTFinal       := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
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
      GravaLog('  Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('  Bematech_FI_RegistrosTipo60 <- iRet: ' + IntToStr(iRet));
      TrataRetornoBematech( iRet );
      If iRet = 1 then
      begin
        GTFinal := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
        Result := '0|' + GTFinal
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
      GravaLog('  Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('  Bematech_FI_RegistrosTipo60 <- iRet: ' + IntToStr(iRet));
      TrataRetornoBematech( iRet );
      If iRet = 1 then
      begin
        VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
        Result := '0|' + VendaBrutaDia
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
    iRet := fFuncBematech_FI_NumeroOperacoesNaoFiscais( sOperacoes );
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
    iRet := fFuncBematech_FI_UltimoItemVendido( sUltimoItem );
    If iRet = 1 then
      Result := '0|' + sUltimoItem
    Else
      Result := '1';
  End

  // 42 - Retorna o subtotal do cupom
  else if Tipo = 42 then
  Begin
    sSubTotal := Space(14);
    iRet := fFuncBematech_FI_SubTotal( sSubTotal );
    If iRet = 1 then
      Result := '0|' + sSubTotal
    Else
      Result := '1';
  End

 else If Tipo = 45 then
        Result := '0|'// 45 Codigo Modelo Fiscal
 else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
        Result := '0|'// 45 Codigo Modelo Fiscal
  //Retorno não encontrado                                                           ?
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.Gaveta:String;
var
  iRet : Integer;
begin
  iRet := fFuncBematech_FI_AcionaGaveta;
  TrataRetornoBematech( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.GravaCondPag( Condicao:String ):String;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpBematech.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
var
  iRet, i : Integer;
  sTexto  : String;
  sLinha  :String;

begin
  Result := '0';
  // Fecha o cupom não fiscal
  fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
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
     For i:= 1 to 40 do
     Begin
         // Caso encontre um CHR(10) (Line Feed) imprime a linha
         If Copy(Texto,i,1) = #10 then
            Break;
         sLinha := sLinha + Copy(Texto,i,1);
     end;
     sLinha := Copy(sLinha+space(40),1,40);
     Texto  := Copy(Texto,i+1,Length(Texto));
     iRet:=fFuncBematech_FI_RelatorioGerencial(sLinha);
     TrataRetornoBematech( iRet );
     // Ocorreu erro na impressão do cupom
     if iRet=0 then
     Begin
        Result := '1';
        Exit;
     End;
  End;

  GravaLog(' Bematech_FI_FechaRelatorioGerencial ->');
  iRet:= fFuncBematech_FI_FechaRelatorioGerencial;
  GravaLog(' Bematech_FI_FechaRelatorioGerencial <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech(iRet);

  If iRet=1
  then Result:='0'
  Else Result := '1';

  GravaLog('RelatorioGerencial -> Result: '+Result);
end;

//----------------------------------------------------------------------------
function TImpBematech.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;
var
  iRet, i : Integer;
  sCodigo, sAux :String;
begin
  Result := '0';
  i := 1;

  // Fecha o cupom não fiscal
  GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado -> ');
  iRet := fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
  GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));

  // Laço para imprimir toda a mensagem
  While i <= Vias do
  Begin
     // ---------------------------------------
     GravaLog('Bematech_FI_AbreRelatorioGerencialMFD ->');
     iRet := fFuncBematech_FI_AbreRelatorioGerencialMFD(pChar('01'));
     GravaLog('Bematech_FI_AbreRelatorioGerencialMFD <- iRet:' + IntToStr(iRet));
     TrataRetornoBematech( iRet );

     If iRet = 1 then
     begin
       sAux := Cabecalho;

       GravaLog('Bematech_FI_UsaRelatorioGerencialMFD -> Cabeçalho :' + sAux);
       While Length(Trim(sAux)) <> 0 do
       begin
         iRet := fFuncBematech_FI_UsaRelatorioGerencialMFD(Copy(sAux,1,618));
         sAux := Copy(sAux,619,Length(sAux));
       end;
       TrataRetornoBematech( iRet );
       GravaLog('Bematech_FI_UsaRelatorioGerencialMFD <- iRet :' + IntToStr(iRet));

       if iRet = 1 then
       begin

        GravaLog(' Bematech_FI_ConfiguraCodigoBarrasMFD -> 162,0,0,0,0');
        iRet := fFuncBematech_FI_ConfiguraCodigoBarrasMFD(162,0,0,0,0);
        GravaLog(' Bematech_FI_ConfiguraCodigoBarrasMFD <- iRet: ' + IntToStr(iRet));

         sCodigo := Codigo;
         GravaLog(' Bematech_FI_CodigoBarrasITFMFD -> Código: ' + sCodigo );
         While Length(Trim(sCodigo)) <> 0 do
         begin
            //O tamanho máximo permitido segundo o manual é 30, quando configurado largura 0
           iRet   := fFuncBematech_FI_CodigoBarrasITFMFD( pChar(Copy(sCodigo,1,30)) );
           sCodigo := Copy(sCodigo,31,Length(sCodigo));
         end;
         GravaLog(' Bematech_FI_CodigoBarrasITFMFD <- iRet : ' + IntToStr(iRet) );
         TrataRetornoBematech( iRet );

         If iRet = 1 then
         begin
           sAux := Rodape;
           GravaLog('Bematech_FI_UsaRelatorioGerencialMFD -> Rodape :' + Rodape);
           While Length(Trim(sAux)) <> 0 do
           begin
             iRet := fFuncBematech_FI_UsaRelatorioGerencialMFD(Copy(sAux,1,618));
             sAux := Copy(sAux,619,Length(sAux));
           end;

           TrataRetornoBematech( iRet );
           GravaLog('Bematech_FI_UsaRelatorioGerencialMFD <- iRet :' + IntToStr(iRet));
         end;
       end;

       GravaLog('Bematech_FI_FechaRelatorioGerencial ->');
       iRet:= fFuncBematech_FI_FechaRelatorioGerencial;
       GravaLog('Bematech_FI_FechaRelatorioGerencial <- iRet :' + IntToStr(iRet));
       TrataRetornoBematech(iRet);
     end;

     if iRet <> 1 then
     Begin
        Result := '1';
        Exit;
     End;

     Inc(i);
  End;

  If iRet = 1
  then Result:='0'
  Else Result := '1';

  GravaLog(' ImprimeCodBarrasITF <- Retorno :' + Result);
end;

//----------------------------------------------------------------------------
function TImpBematech.PegaSerie:String;
begin
  Result := '0|' + NumSerie;
end;

//----------------------------------------------------------------------------
function TImpBematech.TotalizadorNaoFiscal( Numero,Descricao:String ) : String;
var
  iRet : Integer;
begin
  iRet := fFuncBematech_FI_NomeiaTotalizadorNaoSujeitoIcms(StrToInt(Numero),Descricao);
  TrataRetornoBematech(iRet);
  If iRet = 1 then
  begin
    Result := '0';
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
Procedure TImpBematech.AlimentaProperties;
    Procedure CargaIndiceAliq();
    var i, iRet : Integer;
        sIndiceISS, sISS, sICMS : String;
    begin
      try
        sICMS := ICMS;
        sIndiceISS := Space(48);
        iRet := fFuncBematech_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoBematech(iRet);
        If (iRet = 1) And (sIndiceISS[1] <> #0) then
        Begin
            i := 1;
            While Length(sICMS)>0 do
            Begin
                SetLength(aIndAliq,Length(aIndAliq)+2);
                aIndAliq[Length(aIndAliq)-2] := FormataTexto(IntToStr(i),2,0,2);
                If i <> StrToInt(Copy(sIndiceISS,1,2)) then
                begin
                  aIndAliq[Length(aIndAliq)-1] := 'T' + Copy(sICMS,1, Pos('|', sICMS)-1);
                end
                Else
                begin
                  aIndAliq[Length(aIndAliq)-1] := 'S' + Copy(sICMS,1, Pos('|', sICMS)-1);
                  sIndiceISS:= Copy(sIndiceISS,Pos(',', sIndiceISS)+1, Length(sIndiceISS));
                End;
                sICMS := Copy(sICMS,Pos('|', sICMS)+1, Length(sICMS));
                i := i + 1;
            End;
        End;
      Except
      end;
    End;
var
  iRet : Integer;
  sRet, sICMS, sISS, sAliq : String;
  lErro : Boolean;
begin
  // Inicalização de propriedades
  ICMS  := '';
  ISS   := '';
  Pdv   := '';
  Eprom := '';
  Cnpj  := Space(18);
  Ie    := Space(15);
  NumLoja   := Space(4);
  NumSerie  := Space(15);
  TipoEcf   := '';
  MarcaEcf  := '';
  ModeloEcf := Space(10);
  IndicaMFAdi  := '';
  DataIntEprom := '';
  HoraIntEprom := '';
  ContadorCro  := '';
  ContadorCrz  := '';
  GTInicial    := '';
  GTFinal      := '';
  VendaBrutaDia:= '';
  ReducaoEmitida := False;
  //--------------------------

  // Inicalização de variaveis
  lError := False;
  //--------------------------

  // Retorno de Aliquotas ( ISS )
  Try
   lErro := False;
   WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (79) -> ');
   sRet := Space( 79 );
   iRet := fFuncBematech_FI_VerificaAliquotasIss( sRet );
   TrataRetornoBematech( iRet );
   WriteLog('sigaloja.log', 'Bematech_FI_VerificaAliquotasIss (79) <- Retorno :' + IntToStr(iRet));
  Except on E:Exception do
    begin
     WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (79) <- ' + E.className + ' Erro :' + E.message);
     lErro := True;
    end;
  End;

  If lErro Then
  begin
    Try
     WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (80) -> ');
     sRet := Space( 80 );
     iRet := fFuncBematech_FI_VerificaAliquotasIss( sRet );
     TrataRetornoBematech( iRet );
     WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (80) <- Retorno :' + IntToStr(iRet));
     lErro := False;
    Except on E:Exception do
      begin
       WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (80) <- ' + E.className + ' Erro :' + E.message);
       lErro := True;
      end;
    End;
  End;
  
  If iRet = 1 then
  begin
    sISS := Trim( StrTran( sRet, ',', '|' ) );
    While Length(sISS)>0 do
    begin
      sAliq := Copy(sISS,1,2)+','+Copy(sISS,3,2);
      ISS   := ISS + FormataTexto(sAliq,5,2,1) +'|';
      sISS  := Copy(sISS,6,Length(sISS));
    end
  end
  Else
    exit;

  // Retorno de Aliquotas ( ICMS )
  Try
   WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (79) -> ');
   sRet := Space( 79 );
   iRet := fFuncBematech_FI_RetornoAliquotas( sRet );
   TrataRetornoBematech( iRet );
   WriteLog('sigaloja.log', 'Bematech_FI_RetornoAliquotas (79) <- Retorno :' + IntToStr(iRet));
   lErro := False;
  Except on E:Exception do
    begin
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (79) <- ' + E.className + ' Erro :' + E.message);
     lErro := True;
    end;
  End;

  If lErro Then
  begin
    Try
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) -> ');
     sRet := Space( 80 );
     iRet := fFuncBematech_FI_RetornoAliquotas( sRet );
     TrataRetornoBematech( iRet );
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) <- Retorno :' + IntToStr(iRet));
     lErro := False;
    Except on E:Exception do
      begin
       WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) <- ' + E.className + ' Erro :' + E.message);
       lErro := True;
      end;
    End;
  End;

  If iRet = 1 then
  begin
    sICMS := Trim( StrTran( sRet, ',', '|' ) );
    While Length(sICMS)>0 do
    begin
      sAliq := Copy(sICMS,1,2)+','+Copy(sICMS,3,2);
      ICMS  := ICMS + FormataTexto(sAliq,5,2,1) + '|';
      sICMS := Copy(sICMS,6,Length(sICMS));
    end;
    CargaIndiceAliq()
  end
  Else
    exit;

  // Retorno do Numero do Caixa (PDV)
  sRet := Space ( 4 );
  iRet := fFuncBematech_FI_NumeroCaixa( sRet );
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    If Pos(#0,sRet) > 0 then
      Pdv := Copy(sRet,1,Pos(#0,sRet)-1)
    Else
      Pdv := Copy(sRet,1,4);
  end
  Else
    exit;

  // Retorno da Versão do Firmware (Eprom)
  sRet := Space( 4 );
  iRet := fFuncBematech_FI_VersaoFirmware( sRet );
  TrataRetornoBematech( iRet );
  If iRet = 1 then
    Eprom := Copy(sRet,1,Pos(#0,sRet)-1)
  Else
    exit;

  // Retorna o CNPJ
  // Retorna a IE
  iRet := fFuncBematech_FI_CGC_IE( Cnpj, Ie );
  TrataRetornoBematech( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Numero da loja cadastrado no ECF
  iRet := fFuncBematech_FI_NumeroLoja( NumLoja );
  NumLoja := Trim( NumLoja );
  TrataRetornoBematech( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Numero da Serie
  iRet := fFuncBematech_FI_NumeroSerie( NumSerie );
  NumSerie := Trim( NumSerie );
  TrataRetornoBematech( iRet );
  If iRet <> 1 then
    exit;

  // Retorna o Tipo do ECF
  TipoEcf := 'ECF-IF';

  // Retorna Marca do ECF
  MarcaEcf := sMarca;

  // Retorna Modelo do ECF
  iRet := fFuncBematech_FI_ModeloImpressora( ModeloEcf );
  TrataRetornoBematech( iRet );
  If iRet = 1
  then ModeloEcf := Trim( ModeloEcf )
  Else exit;

  // Retorna Data de gravação do último usuário da impressora
  // Retorna Hora de gravação do último usuário da impressora
  // Retorna Data de Instalação da Eprom
  // Retorna Hora de Instalação da Eprom
  // Retorna Letra indicativa de MF adicional
  { RETORNA ERRO SE FEITO NA INICIALIZACAO
  iRet := fFuncBematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional( sAuxDtU, sAuxDtS, sAuxMfA);
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    DataGrvUsuario := StrTran( Copy( sAuxDtU, 1, 10 ), '/', '');
    HoraGrvUsuario := StrTran( Copy( sAuxDtU, 12, 8 ), ':', '');
    DataIntEprom := StrTran( Copy( sAuxDtS, 1, 10 ), '/', '');
    HoraIntEprom := StrTran( Copy( sAuxDtS, 12, 8 ), ':', '');
    IndicaMFAdi  := sAuxMfA;
  end
  Else
    exit;
  }

  // Retorna Contador de Reinicio de Operação
  // Retorna Contador de ReduçãoZ
  iRet := fFuncBematech_FI_RegistrosTipo60();
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    ContadorCro := LeArqRetorno( Path, sArqIniBema, 49, 6 );
    ContadorCrz := LeArqRetorno( Path, sArqIniBema, 55, 3 );
  end
  Else
    exit;

  //Retorna o Grande Total Inicial
  //Retorna o Grande Total Final
  //Retorna a Venda Bruta Diaria
  iRet := fFuncBematech_FI_RegistrosTipo60();
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
    GTFinal       := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
    GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );
  end
  Else
    exit;

end;

//------------------------------------------------------------------------------
function TImpBematech.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpBematech.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//----------------------------------------------------------------------------
function TImpBematech.Retorna_Informacoes( iRetorno : Integer ): String;
Var
  sRetorno, sAuxDtU, sAuxDtS, sAuxMfA : String;
  iRet     : Integer;
begin

  sRetorno := '';
  sAuxDtU := Space(20);
  sAuxDtS := Space(20);
  sAuxMfA := Space(5);

  // Esse comando demora para ter o retorno da DLL da Bematech, entao abaixo foi carregado as propriedades, para executar apenas umaq vez.
  GravaLog('-> Bematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional( sAuxDtU, sAuxDtS, sAuxMfA )');
  iRet := fFuncBematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional( sAuxDtU, sAuxDtS, sAuxMfA );
  TrataRetornoBematech( iRet, True );

  If iRet = 1 then
  begin

    IndicaMFAdi    := Trim( sAuxMfA );
    DataIntEprom   := StrTran( Copy( sAuxDtU, 1, 10 ), '/', '');
    HoraIntEprom   := StrTran( Copy( sAuxDtU, 12, 8 ), ':', '');
    DataGrvUsuario := StrTran( Copy( sAuxDtS, 1, 10 ), '/', '');
    HoraGrvUsuario := StrTran( Copy( sAuxDtS, 12, 8 ), ':', '');

    DataGrvUsuario := Copy( DataGrvUsuario, 5, 4) + Copy( DataGrvUsuario, 3, 2) + Copy( DataGrvUsuario, 1, 2);
    DataIntEprom   := Copy( DataIntEprom, 5, 4) + Copy( DataIntEprom, 3, 2) + Copy( DataIntEprom, 1, 2);

    Case iRetorno of
      1 : sRetorno := IndicaMFAdi;           // Retorna Letra indicativa de MF adicional
      2 : sRetorno := DataIntEprom;          // Retorna Data de Instalação da Eprom
      3 : sRetorno := HoraIntEprom;          // Retorna Hora de Instalação da Eprom
      4 : sRetorno := DataGrvUsuario;        // Retorna Data de gravação do último usuário da impressora
      5 : sRetorno := HoraIntEprom;          // Retorna Hora de gravação do último usuário da impressora
    end;

  end;

  Result := sRetorno;
end;

//-----------------------------------------------------------
function TImpBematech40.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
Var
  iRet            : Integer;
  sPedido         : String;
  sTefPedido      : String;
  sCondicao       : String;
  sPath           : String;
  sTotalizadores  : String;
  fArquivo        : TIniFile;
  aAuxiliar       : TaString;
  lPedido         : Boolean;
  lTefPedido      : Boolean;
  sTotPedido      : String;     // Contem o totalizador do registrador PEDIDO
  sTotTefPedido   : String;     // Contem o totalizador do registrador TEFPEDIDO
  iX              : Integer;
  sMsg            : String;
  sLinha          : String;
  sLista          : TStringList;
begin
  //*******************************************************************************
  // Para não forçar o cliente a utilizar registradores fixos do ECF na emissão
  // de cupom não fiscal vinculado e não vinculado para a impressão do comprovante
  // de venda (função abaixo) sera utilizado o arquivo BEMAFI32.INI
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

  // Pega os nomes dos totalizadores no arquivo de configuração (BEMAFI32.INI)
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo    := TIniFile.Create(sPath+ '\' + sArqIniBema);

  GravaLog(' Path do Arquivo : ' + sPath);
  GravaLog(' Arquivo : ' + sArqIniBema);

  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  If fArquivo.ReadString('Microsiga', 'IndTotPed', '') = '' then
    fArquivo.WriteString('Microsiga', 'IndTotPed', '01');

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  Gravalog('sPedido :' + sPedido);
  Gravalog('sTefPedido :' + sTefPedido);
  Gravalog('sCondicao :' + sCondicao);  

  //*******************************************************************************
  // Checa indice do totalizador pelo nome informado
  //*******************************************************************************
  sTotalizadores  := Space(2200);
  GravaLog('Bematech_FI_VerificaRecebimentoNaoFiscal ->');
  iRet  := fFuncBematech_FI_VerificaRecebimentoNaoFiscal( sTotalizadores );
  GravaLog('Bematech_FI_VerificaRecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));
  GravaLog('Totalizadores: ' + sTotalizadores);
  TrataRetornoBematech( iRet );
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
  end
  else
  begin
    GravaLog('Bematech: Capturou Totalizador do INI');
    sTotPedido  := fArquivo.ReadString('Microsiga', 'IndTotPed', '');
    GravaLog('sTotPedido:' + sTotPedido);
    lTefPedido := True;
    lPedido := True;
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
    GravaLog('Bematech_FI_RecebimentoNaoFiscal -> ' + sTotPedido + ',' + Valor + ',' + sCondicao);
    iRet := fFuncBematech_FI_RecebimentoNaoFiscal ( sTotPedido, Valor, sCondicao );
    GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));
    If Status_Impressora( False ) = 1 then
    begin
      //*******************************************************************************
      // Abre o comprovante não fiscal vinculado
      //*******************************************************************************
      GravaLog('Bematech_FI_AbreComprovanteNaoFiscalVinculado -> ' + sCondicao);
      iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado(sCondicao, '', '' );
      GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));
      If Status_Impressora( False ) = 1 then
      begin
          sLista := TStringList.Create;
          sLista.Clear;

          iX := Pos(#10,Texto);
          While iX > 0 do
          Begin
              iX      := Pos(#10,Texto);
              sLinha  := sLinha + Copy(Texto,1,iX) ;
              Texto   := Copy(Texto,iX+1,Length(Texto));

              If Length(sLinha) >= 500 Then
              Begin
                sLista.Add(sLinha);
                sLinha := '';
              end;
          End;

          If Trim(Texto) <> '' Then sLinha := ' ' + sLinha + Texto + #10;
          If Trim(sLinha) <> '' Then sLista.Add(sLinha);

          GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> ');

          For iX:= 0 to sLista.Count-1 do
              iRet := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLista.Strings[iX] );

          GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- :' + IntToStr(iRet));

          If Status_Impressora( False ) = 1 then
          begin
            GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado -> ');
            iRet := fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
            GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));

            If Status_Impressora( False ) = 1 then
            begin
              //*******************************************************************************
              // Checar se serah impresso o comprovante TEF. Caso afirmativo abre um novo
              // comprovante nao fiscal nao vinculado.
              //*******************************************************************************
              If Tef = 'S' then
              begin
                GravaLog(' Bematech_FI_RecebimentoNaoFiscal -> ');
                iRet := fFuncBematech_FI_RecebimentoNaoFiscal ( sTotTefPedido, Valor, sCondicao );
                GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));
                If Status_Impressora( False ) = 1
                then  Result := '0';
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
      TrataRetornoBematech( iRet );

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
      LjMsgDlg('Os totalizadores ' + sMsg + ' não existem no ECF. Checar o arquivo ' + sArqIniBema );
    Result := '1';
  end;

  //*******************************************************************************
  // Libera as variaveis
  //*******************************************************************************
  fArquivo.Free;

  //*******************************************************************************
  // Faz uma pausa forçada pois estava dando erro ao chamar outra função logo após
  // esta ao utilizar a MP40FI II
  //*******************************************************************************
  Sleep( 3500 );

end;

//---------------------------------------------------------------------------
function TImpBematech.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;


//----------------------------------------------------------------------------
function TImpBematech.DownMF( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//-----------------------------------------------------------
function TImpCheqBematech.Abrir( aPorta:String ): Boolean;
var
    pPath  : Pchar;
    sPath  : String;
    sIni   : String;
  fArquivo : TIniFile;
begin
  pPath := PChar(Space(100));
  GetSystemDirectory(pPath, 100);
  sPath := StrPas( pPath );

  If Copy(sPath,Length(sPath),1)= '\' then
  begin
     sIni := sPath + sArqIniBema;
     Path  := sPath ;
  end
  Else
  begin
     sIni := sPath + '\' + sArqIniBema;
     Path  := sPath + '\';
  end;

  fArquivo := TIniFile.Create(sIni);
  fArquivo.WriteString('Sistema', 'ModeloImp', 'Bematech' );
  fArquivo.WriteString('MFD', 'Impressora', '0' );

  If Not bOpened
  Then Result := (Copy(OpenBematech(aPorta),1,1) = '0')
  Else Result := True;
end;

//----------------------------------------------------------------------------
function TImpCheqBematech.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  iRet : Integer;
  sData: String;
  iStatus : Integer;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Imprimir: '+ Banco+'|'+Valor+'|'+Favorec+'|'+Cidade+'|'+Data+'|'+Mensagem+'|'+Verso+'|'+Extenso+'|'+Chancela ));
  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Bematech_FI_ProgramaMoedaPlural:' ));
  iRet := fFuncBematech_FI_ProgramaMoedaPlural( Pchar('reais') );
  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Bematech_FI_ProgramaMoedaPlural:'+IntToStr(iRet) ));
  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Bematech_FI_ImprimeCheque:' ));
  iRet := fFuncBematech_FI_ImprimeCheque(Banco, Valor, Favorec, Cidade, Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,1,4), Mensagem);
  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Bematech_FI_ImprimeCheque:'+IntToStr(iRet) ));
  sleep( 2000 );
  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Bematech_FI_VerificaStatusCheque:' ));
  fFuncBematech_FI_VerificaStatusCheque( iStatus );
  WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Bematech_FI_VerificaStatusCheque:'+IntToStr(iStatus) ));

  If iRet = 1 then
  begin
    While iStatus = 2 do // Cheque esta sendo impresso!
    Begin
      fFuncBematech_FI_VerificaStatusCheque( iStatus );
      sleep( 2000 );
    End;
    TrataRetornoBematech(iRet);
  End;
  if iRet = 1 then
      result := True
  Else
      result := False;
end;

//----------------------------------------------------------------------------
function TImpCheqBematech.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Função não implementada para este equipamento' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpCheqBematech.Fechar( aPorta:String ): Boolean;
begin
  Result := (Copy(CloseBematech,1,1) = '0');
end;

//----------------------------------------------------------------------------
function TImpCheqBematech.StatusCh( Tipo:Integer ):String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
end;

//-----------------------------------------------------------
function TImpCheqBem6000.Abrir( aPorta:String ): Boolean;
var
  sPath  : String;
  sIni   : String;
  fArquivo : TIniFile;
begin
  sPath := ExtractFilePath(Application.ExeName);

  If Copy(sPath,Length(sPath),1)= '\' then
  begin
    sIni := sPath + sArqIniBema;
    Path  := sPath ;
  end
  Else
  begin
    sIni := sPath + '\' + sArqIniBema;
    Path  := sPath + '\';
  end;

  fArquivo    := TIniFile.Create(sIni);
  fArquivo.WriteString('Sistema', 'ModeloImp', 'Bematech' );
  fArquivo.WriteString('MFD', 'Impressora', '1' );

  If Not bOpened Then
      Result := (Copy(OpenBematech(aPorta,True),1,1) = '0')
  Else
      Result := True;
end;

//-----------------------------------------------------------------------------
function TImpCheqBem6000.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  iRet,iVezes : Integer;
  sData: String;
begin
  GravaLog(' -> Imprimir: '+ Banco+'|'+Valor+'|'+Favorec+'|'+Cidade+'|'+Data+'|'+Mensagem+'|'+Verso+'|'+Extenso+'|'+Chancela );
  iVezes := 1;
  If length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  iRet := 0;

  While iVezes < 5 do //Esse While verifica se o cheque esta inserido, se estiver manda o comando
  Begin
    //WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> VerificaStatusCheque: ' ));
    //fFuncBematech_FI_VerificaStatusCheque( iStatus );
    //WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- VerificaStatusCheque: '+ 'iStatus' ));
    //If (iStatus = 1) Or (iStatus = 3) then
    //Begin
      ShowMessage( 'Insira o cheque!' );
      WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> ImprimeChequeMFD: '+ Banco+'|'+Valor+'|'+Favorec+'|'+Cidade+'|'+Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,1,4)+'|'+Mensagem+'|0'+'|0' ));
      iRet := fFuncBematech_FI_ImprimeChequeMFD( Banco, Valor, Favorec, Cidade, Copy(Data,7,2) + Copy(Data,5,2) + Copy(Data,1,4), Mensagem, '0', '0' );
      WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- ImprimeChequeMFD: '+ 'iRet' ));
      //iVezes := 6; // Se mandar para a impressora sai do looping
    //End
    //Else
    //Begin
      //ShowMessage( 'Insira o cheque!' );
      iVezes := iVezes + 1;
      Sleep( 1000 );
    //End;

    if iRet = 1 then
      iVezes := 6
    else
      TrataRetornoBematech( iRet, True );
  End;

  //If iRet = 1 then //Se o retorno de impressao do cheque foi ok, checa o status da impressão do cheque
  //begin
  //  While iStatus <> 1 do // iStatus = 1 -> Impressão ok; 2 -> Cheque em impressão; 3-> Cheque posicionado; 4 -> Aguardando posicionamento
  //  Begin
  //    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> VerificaStatusCheque: ' ));
  //    fFuncBematech_FI_VerificaStatusCheque( iStatus );
  //    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- VerificaStatusCheque: '+ 'iStatus' ));
  //    sleep( 1000 );
  //  End;
  //  TrataRetornoBematech(iRet);
  //End;

  if iRet = 1 then
      result := True
  Else
      result := False;

end;

//----------------------------------------------------------------------------
function TImpCheqBem7000.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  iRet,iVezes : Integer;
  sData: String;
begin
  GravaLog(' -> Imprimir: '+ Banco+'|'+Valor+'|'+Favorec+'|'+Cidade+'|'+Data+'|'+Mensagem+'|'+Verso+'|'+Extenso+'|'+Chancela );
  iVezes := 1;
  If length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  iRet := 0;

  While iVezes < 5 do //Esse While verifica se o cheque esta inserido, se estiver manda o comando
  Begin
    //WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> VerificaStatusCheque: ' ));
    //fFuncBematech_FI_VerificaStatusCheque( iStatus );
    //WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- VerificaStatusCheque: '+ 'iStatus' ));
    //If (iStatus = 1) Or (iStatus = 3) then
    //Begin
      ShowMessage( 'Insira o cheque!' );
      WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> ImprimeChequeMFDEx: '+ Banco+'|'+Valor+'|'+Favorec+'|'+Cidade+'|'+Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,1,4)+'|'+Mensagem+'|0' ));
      iRet := fFuncBematech_FI_ImprimeChequeMFDEx( Banco, Valor, Favorec, Cidade, Copy(Data,7,2) + Copy(Data,5,2) + Copy(Data,1,4), Mensagem, '0' );
      WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- ImprimeChequeMFDEx: '+ IntToStr(iRet) ));
      //iVezes := 6; // Se mandar para a impressora sai do looping
    //End
    //Else
    //Begin
    //  ShowMessage( 'Insira o cheque!' );
      iVezes := iVezes + 1;
      Sleep( 1000 );
    //End;

    if iRet = 1 then
      iVezes := 6
    else
      TrataRetornoBematech( iRet, True );
  End;

  //If iRet = 1 then //Se o retorno de impressao do cheque foi ok, checa o status da impressão do cheque
  //begin
  //  While iStatus <> 1 do // iStatus = 1 -> Impressão ok; 2 -> Cheque em impressão; 3-> Cheque posicionado; 4 -> Aguardando posicionamento
  //  Begin
  //    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> VerificaStatusCheque: ' ));
  //    fFuncBematech_FI_VerificaStatusCheque( iStatus );
  //    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- VerificaStatusCheque: '+ 'iStatus' ));
  //    Sleep( 1000 );
  //  End;
  //  TrataRetornoBematech(iRet);
  //End;

  if iRet = 1 then
      result := True
  Else
      result := False;

end;

//----------------------------------------------------------------------------
function TImpBematech.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
Var
  iRet            : Integer;
  sPedido         : String;
  sTefPedido      : String;
  sCondicao       : String;
  sPath           : String;
  sTotalizadores  : String;
  fArquivo        : TIniFile;
  aAuxiliar       : TaString;
  lPedido         : Boolean;
  lTefPedido      : Boolean;
  sTotPedido      : String;     // Contem o totalizador do registrador PEDIDO
  sTotTefPedido   : String;     // Contem o totalizador do registrador TEFPEDIDO
  iX              : Integer;
  sMsg            : String;
  sLinha          : String;
  sLista          : TStringList;
begin
  //*******************************************************************************
  // Para não forçar o cliente a utilizar registradores fixos do ECF na emissão
  // de cupom não fiscal vinculado e não vinculado para a impressão do comprovante
  // de venda (função abaixo) sera utilizado o arquivo BEMAFI32.INI
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

  // Pega os nomes dos totalizadores no arquivo de configuração (BEMAFI32.INI)
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath + '\' + sArqIniBema);

  GravaLog(' Path do Arquivo : ' + sPath);
  GravaLog(' Arquivo : ' + sArqIniBema);

  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = ''
  then  fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  If fArquivo.ReadString('Microsiga', 'IndTotPed', '') = '' then
    fArquivo.WriteString('Microsiga', 'IndTotPed', '01');

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  Gravalog('sPedido :' + sPedido);
  Gravalog('sTefPedido :' + sTefPedido);
  Gravalog('sCondicao :' + sCondicao);  

  //*******************************************************************************
  // Checa indice do totalizador pelo nome informado
  //*******************************************************************************
  sTotalizadores  := Space(2200);
  GravaLog('Bematech_FI_VerificaRecebimentoNaoFiscal ->');
  iRet            := fFuncBematech_FI_VerificaRecebimentoNaoFiscal( sTotalizadores );
  GravaLog('Bematech_FI_VerificaRecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));
  GravaLog('Totalizadores:' + sTotalizadores);
  TrataRetornoBematech( iRet );
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
  end
  else
  begin
    GravaLog('Bematech: Capturou totalizador do INI');
    sTotPedido  := fArquivo.ReadString('Microsiga', 'IndTotPed', '');
    GravaLog('sTotPedido:' + sTotPedido);
    lPedido := True;
    lTefPedido := True;
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
    GravaLog(' Bematech_FI_RecebimentoNaoFiscal ->');
    iRet := fFuncBematech_FI_RecebimentoNaoFiscal ( sTotPedido, Valor, sCondicao );
    GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));
    If Status_Impressora( False ) = 1 then
    begin

      //*******************************************************************************
      // Abre o comprovante não fiscal vinculado
      //*******************************************************************************
      GravaLog('Bematech_FI_AbreComprovanteNaoFiscalVinculado ->' + sCondicao);
      iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( sCondicao, '', '' );
      GravaLog('Bematech_FI_AbreComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));
      If Status_Impressora( False ) = 1 then
      begin
          sLista := TStringList.Create;
          sLista.Clear;

          iX := Pos(#10,Texto);
          While iX > 0 do
          Begin
              iX      := Pos(#10,Texto);
              sLinha  := sLinha + Copy(Texto,1,iX) ;
              Texto   := Copy(Texto,iX+1,Length(Texto));

              If Length(sLinha) >= 500 Then
              Begin
                sLista.Add(sLinha);
                sLinha := '';
              end;
          End;

          If Trim(Texto) <> '' Then sLinha := ' ' + sLinha + Texto + #10;
          If Trim(sLinha) <> '' Then sLista.Add(sLinha);

          GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> ');

          For iX := 0 to sLista.Count-1 do
             iRet := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLista.Strings[iX] );

          GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- ' + IntToStr(iRet));

          If Status_Impressora( False ) = 1 then
          begin
            GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado -> ');
            iRet := fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
            GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
            If Status_Impressora( False ) = 1 then
            begin
              //*******************************************************************************
              // Checar se serah impresso o comprovante TEF. Caso afirmativo abre um novo
              // comprovante nao fiscal nao vinculado.
              //*******************************************************************************
              If Tef = 'S' then
              begin
                GravaLog(' Bematech_FI_RecebimentoNaoFiscal -> ' + sTotTefPedido + ',' + Valor +',' + sCondicao );
                iRet := fFuncBematech_FI_RecebimentoNaoFiscal ( sTotTefPedido, Valor, sCondicao );
                GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet: ' + IntToStr(iRet));
                If Status_Impressora( False ) = 1
                then Result := '0';
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
      TrataRetornoBematech( iRet );

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
      LjMsgDlg('Os totalizadores ' + sMsg + ' não existem no ECF. Checar o arquivo ' + sArqIniBema );
    Result := '1';
  end;

  //*******************************************************************************
  // Libera as variaveis
  //*******************************************************************************
  fArquivo.Free;

end;

//----------------------------------------------------------------------------
function TImpBematech.RecebNFis( Totalizador, Valor, Forma:String ): String;
var iRet : Integer;
    sValorTratado,sFormaTratada : String;
begin
  sValorTratado := Trim(Valor);
  sFormaTratada := Copy(Trim(Forma),1,16);
  GravaLog('Bematech_FI_RecebimentoNaoFiscal -> Totalizador : ' + Trim(Totalizador) + ' , Valor (Tratado): ' +
                sValorTratado + ' , Forma (Tratado):' + sFormaTratada);
  iRet := fFuncBematech_FI_RecebimentoNaoFiscal( pchar(Trim(Totalizador)), pchar(sValorTratado), pchar(sFormaTratada) );
  GravaLog('Bematech_FI_RecebimentoNaoFiscal <- iRet: ' + IntToStr(iRet));
  TrataRetornoBematech(iRet);
  if iRet = 1
  then Result := '0'
  else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.HorarioVerao( Tipo:String ):String;
var iRet : Integer;
begin
  iRet := fFuncBematech_FI_ProgramaHorarioVerao();
  if iRet = 1 then
    Result := '0'
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech.RedZDado(MapaRes:String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '0';
End;

//----------------------------------------------------------------------------
function TImpBematech.ImpTxtFis(Texto : String) : String;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
end;

//------------------------------------------------------------------------------
function TImpBematech.GrvQrCode(SavePath, QrCode: String): String;
begin
 GravaLog(' GrvQrCode - não implementado para esse modelo ');
 Result := '0';
end;

//----------------------------------------------------------------------------
function TImpYanco8000.Abrir(sPorta : String; iHdlMain:Integer) : String;
begin
  sMarca := 'YANCO';
  
  // Verifica o arquivo de configuracao da Bematech.
  If ArqIniBematech( sPorta, sMarca , '0' ) then
  begin
    Result := OpenBematech( sPorta );
    // Carrega as aliquotas e N. PDV para ganhar performance
    if Copy(Result,1,1) = '0' then
    begin
      AlimentaProperties;
      If lError then
      begin
        Result := '1';
        LjMsgDlg( MsgErroProp );
      end
    end
  end
  Else
    LjMsgDlg( 'Problemas com o arquivo ' + sArqIniBema );
end;

//----------------------------------------------------------------------------
function TImpYanco8000.PegaPDV:String;
begin
  Result := '0|' + FormataTexto(Pdv,3,0,2);
end;

//----------------------------------------------------------------------------
function TImpYanco8000.PegaCupom(Cancelamento:String):String;
var
  iRet : Integer;
  sNumCupom : String;
begin
  sNumCupom := Space( 6 );
  iRet := fFuncBematech_FI_NumeroCupom( sNumCupom );
  TrataRetornoBematech( iRet );
  If iRet = 1 then
    If StatusImp(5)= '7' then
        Result := '0|' + sNumCupom
    Else
        Result := '0|' + FormataTexto(IntToStr(StrToInt(sNumCupom)-1),6,0,2)
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpYanco8000.ReducaoZ(MapaRes:String):String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i: Integer;
  sData, sHora : String;
  aRetorno : array of String;
  sRetorno : String;
  fFile : TextFile;
  sFile, sLinha, sFlag : String;
begin
 If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := Pdv;                //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0' then
      aRetorno[ 2] := FormataTexto(Trim(Copy(aRetorno[2],3,Length(aRetorno[2]))),13,0,2);

    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[ 5] := aRetorno[ 6];

    aRetorno[ 7] := Space (14);                         //**** Valor do Cancelamento ****//
    iRet := fFuncBematech_FI_Cancelamentos( aRetorno[ 7] );
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    aRetorno[ 9] := Space (14);                         //**** Desconto ****//
    iRet := fFuncBematech_FI_Descontos( aRetorno[ 9] );
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    sRetorno := Space(445);
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciais(sRetorno);

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

    sRetorno := Space(4);
    iRet := fFuncBematech_FI_NumeroIntervencoes(sRetorno);
    aRetorno[17]:= FormataTexto(sRetorno,3,0,2);

    aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS
    aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS
    aRetorno[20]:= '00';                                         // QTD DE Aliquotas

    iRet := fFuncBematech_FI_LeituraXSerial();
    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path') + '\' +'RETORNO.TXT';
      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '00000000000.00 00000000000.00';
        While not Eof(fFile) do
        Begin
          ReadLn(fFile, sLinha);
          sLinha := TrataLinha(sLinha);
          if ( Pos('COO DO PRIMEIRO CUPOM FISCAL' , UpperCase(sLinha))>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
          if ( Pos('VENDA LIQUIDA',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
          if ( Pos('TOTAL',UpperCase(sLinha))>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
            // desliga a captura das aliquotas
            sFlag:='';

          if ( sFlag='T' ) and ( Copy(sLinha,1,1)='T' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            aRetorno[High(aRetorno)]:= Copy(sLinha,1,6)+' '+FormataTexto(StrTran(Copy(sLinha,20,23),'.',''),14,2,1,'.')+ ' ' + FormataTexto('0',14,2,1,'.');
          End;

          if (Pos('--------[ SITUACOES TRIBUTARIAS ]---------',sLinha)>0) then
          // Liga a captura das aliquotas de ICMS
            sFlag:='T';
        end;
        CloseFile(fFile);
      end
    end;
 end;

  DateTimeToString( sData, 'ddmmyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    ReducaoEmitida := True;

    If Trim(MapaRes) ='S' then
    begin
       iRet := fFuncBematech_FI_MapaResumo();
       TrataRetornoBematech( iRet );
       If iRet = 1 then
       begin
          sFile := LeArqBema('Sistema', 'Path')+'\' +'RETORNO.TXT';
          if FileExists(sFile) then
          Begin
            AssignFile(fFile, sFile);
            Reset(fFile);
            While not Eof(fFile) do
            Begin
              ReadLn(fFile, sLinha);
              sLinha := TrataLinha(sLinha);
              if ( Pos('ISS' , UpperCase(sLinha))>0) then
                aRetorno[16]:=FormataTexto(Copy(sLinha,25,Length(sLinha)),14,2,1)+ ' 00000000000.00';
            end;
            CloseFile(fFile);
          end;
       end;
       Result := '0|';
       For i:= 0 to High(aRetorno) do
            Result := Result + aRetorno[i]+'|';
    end
    Else
        Result := '0';
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpYanco8000.CancelaCupom(Supervisor:String):String;
var
  iFlag, iRet : Integer;
  sRet, sSubTot: String;
begin
  iRet := fFuncBematech_FI_CancelaCupom;
  TrataRetornoBematech( iRet );
  If iRet = 1 then
    Result := '0'
  Else
  begin
    iFlag := 0;
    iRet := fFuncBematech_FI_FlagsFiscais(iFlag);
    If iRet = 1 then
    begin
        // Testa se já efetuou formas de pagamento
        If iFlag >= 128 Then iFlag := iFlag - 128;
        If iFlag >= 32  Then iFlag := iFlag - 32;
        If iFlag >= 8   Then iFlag := iFlag - 8;
        If iFlag >= 4   Then iFlag := iFlag - 4;
        If iFlag >= 2   Then
        begin
            sSubTot := Space(14);
            // ver qto falta para encerrar o cupom
            iRet := fFuncBematech_FI_SubTotal(sSubTot);
            If iRet = 1 then
            begin
                sRet := FechaCupom('');
                If sRet = '0' then
                begin
                    iRet := fFuncBematech_FI_CancelaCupom;
                    If iRet = 1 then
                       Result := '0'
                    Else
                       Result:= '1';
                End
                Else
                  // pagar a diferenca
                    sRet :=Pagamento('DINHEIRO|'+ Trim(sSubTot),'','');
                    sRet := FechaCupom('');
                    iRet := fFuncBematech_FI_CancelaCupom;
            end
            else
                Result := '1';
        end
        else if iFlag = 1 then
        begin
            iRet := fFuncBematech_FI_TerminaFechamentoCupom('');
            iRet := fFuncBematech_FI_CancelaCupom;
        end;
    end
    else
        Result := '1';
  end;
end;

//----------------------------------------------------------------------------
function TImpBematech2000.Abrir(sPorta : String; iHdlMain:Integer) : String;

begin
  sMarca := 'BEMATECH';

  // Verifica o arquivo de configuracao da Bematech.
  If ArqIniBematech( sPorta, sMarca, '1' ) then
  begin
    Result := OpenBematech( sPorta, True );
    // Carrega as aliquotas e N. PDV para ganhar performance
    if Copy(Result,1,1) = '0' then
    begin
      AlimentaProperties;
      If lError then
      begin
        Result := '1';
        LjMsgDlg( MsgErroProp );
      end
    end
  end
  Else
    LjMsgDlg( 'Problemas com o arquivo ' + sArqIniBema );
end;

//-----------------------------------------------------------
function TImpBematech2000.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
Var
  iRet            : Integer;
  sPedido, sTefPedido, sCondicao, sPath, sTotalizadores : String;
  fArquivo        : TIniFile;
  aAuxiliar       : TaString;
  lPedido         : Boolean;
  lTefPedido      : Boolean;
  sTotPedido      : String;     // Contem o totalizador do registrador PEDIDO
  sTotTefPedido   : String;     // Contem o totalizador do registrador TEFPEDIDO
  iX              : Integer;
  sMsg            : String;
  sLinha          : String;
  sLista          : TStringList;
begin
  //*******************************************************************************
  // Para não forçar o cliente a utilizar registradores fixos do ECF na emissão
  // de cupom não fiscal vinculado e não vinculado para a impressão do comprovante
  // de venda (função abaixo) sera utilizado o arquivo BEMAFI32.INI
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

  // Pega os nomes dos totalizadores no arquivo de configuração (BEMAFI32.INI)
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo    := TIniFile.Create(sPath + '\' + sArqIniBema);

  GravaLog(' Path do Arquivo : ' + sPath);
  GravaLog(' Arquivo : ' + sArqIniBema);

  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  If fArquivo.ReadString('Microsiga', 'IndTotPed', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'IndTotPed', '01' );

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  Gravalog('sPedido :' + sPedido);
  Gravalog('sTefPedido :' + sTefPedido);
  Gravalog('sCondicao :' + sCondicao);

  //*******************************************************************************
  // Checa indice do totalizador pelo nome informado
  //*******************************************************************************
  sTotalizadores  := Space(1077);
  GravaLog(' Bematech_FI_VerificaRecebimentoNaoFiscalMFD - > ');
  iRet := fFuncBematech_FI_VerificaRecebimentoNaoFiscalMFD( sTotalizadores );
  GravaLog(' Bematech_FI_VerificaRecebimentoNaoFiscalMFD <-  iRet : ' + IntToStr(iRet));
  GravaLog('Totalizadores do ECF: ' + sTotalizadores);

  TrataRetornoBematech( iRet, True );
  If iRet = 1 then
  begin
    If (Pos( sPedido, sTotalizadores ) > 0) And (Pos( sTefPedido, sTotalizadores ) > 0) then
    begin
      sTotalizadores := StrTran( sTotalizadores, ',', '|' );
      MontaArray( sTotalizadores,aAuxiliar );

      iX := 0;
      While (iX < Length(aAuxiliar)) do
      begin
        If UpperCase(Trim(Copy( aAuxiliar[iX], 1, 19 ))) = UpperCase( sPedido ) then 
        begin
          lPedido := True;
          sTotPedido := FormataTexto( IntToStr(iX+1), 2, 0, 2 );
        end;
        If UpperCase(Trim(Copy( aAuxiliar[iX], 1, 19 ))) = UpperCase( sTefPedido ) then
        begin
          lTefPedido := True;
          sTotTefPedido := FormataTexto( IntToStr(iX+1), 2, 0, 2 );
        end;
        If lPedido And lTefPedido then break;
        Inc( iX );
      end;
    end;
  end
  else
  begin
    GravaLog(' Bematech -> Capturou o totalizador do INI');
    sTotPedido  := fArquivo.ReadString('Microsiga', 'IndTotPed', '');
    GravaLog('sTotPedido:' + sTotPedido);
    lPedido := True;
    lTefPedido := True;
  end;

  GravaLog('sTotPedido:' + sTotPedido);

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
    GravaLog(' Bematech_FI_RecebimentoNaoFiscal -> (' + sTotPedido + ',' + Valor + ',' + sCondicao + ')');
    iRet := fFuncBematech_FI_RecebimentoNaoFiscal(sTotPedido, Valor, sCondicao );
    GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet: ' + IntToStr(iRet));
    If Status_Impressora( False, True ) = 1 then
    begin
      //*******************************************************************************
      // Abre o comprovante não fiscal vinculado
      //*******************************************************************************
      GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado -> ' + sCondicao );
      iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( sCondicao, '', '' );
      GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado <- iRet :' + IntToStr(iRet));
      If Status_Impressora( False, True ) = 1 then
      begin
          sLista := TStringList.Create;
          sLista.Clear;

          iX := Pos(#10,Texto);
          While iX > 0 do
          Begin
            iX      := Pos(#10,Texto);
            sLinha  := sLinha + Copy(Texto,1,iX) ;
            Texto   := Copy(Texto,iX+1,Length(Texto));

            If Length(sLinha) >= 500 Then
            Begin
              sLista.Add(sLinha);
              sLinha := '';
            end;
          End;

          If Trim(Texto) <> '' Then sLinha := ' ' + sLinha + Texto + #10;
          If Trim(sLinha) <> '' Then sLista.Add(sLinha);

          GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> ');

          For iX:= 0 to sLista.Count-1 do
              iRet := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLista.Strings[iX] );

          GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- :' + IntToStr(iRet));

          If Status_Impressora( False, True ) = 1 then
          begin
            GravaLog('Bematech_FI_FechaComprovanteNaoFiscalVinculado ->');
            iRet := fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
            GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet) );

            If Status_Impressora( False, True ) = 1 then
            begin
              //*******************************************************************************
              // Checar se serah impresso o comprovante TEF. Caso afirmativo abre um novo
              // comprovante nao fiscal nao vinculado.
              //*******************************************************************************
              If Tef = 'S' then
              begin
                GravaLog(' Bematech_FI_RecebimentoNaoFiscal -> (' + sTotPedido + ',' + Valor + ',' + sCondicao + ')');
                iRet := fFuncBematech_FI_RecebimentoNaoFiscal ( sTotTefPedido, Valor, sCondicao );
                GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet: ' + IntToStr(iRet));                
                If Status_Impressora( False, True ) = 1 then
                  Result := '0';
              end
              Else
                Result := '0';
            end;
          end;
      end;
    end;

    // Mostrar mensagem de erro se necessário
    If Result = '1'
    then TrataRetornoBematech( iRet, True );
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
      LjMsgDlg('Os totalizadores ' + sMsg + ' não existem no ECF. Checar o arquivo ' + sArqIniBema );
    Result := '1';
  end;

  //*******************************************************************************
  // Libera as variaveis
  //*******************************************************************************
  fArquivo.Free;
end;

//----------------------------------------------------------------------------
function TImpBematech2000.AbreCupom(Cliente:String; MensagemRodape:String):String;
var
  iRet : Integer;
  aAuxiliar : TaString;
  sCnpjCpf, sNomeCli, sEnd : String;
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
      sEnd := Copy( aAuxiliar[2], 1, 80 );
  end
  Else
    sCnpjCpf := Cliente;

  GravaLog(' Bematech_FI_AbreCupomMFD ->');
  iRet := fFuncBematech_FI_AbreCupomMFD(sCnpjCpf, sNomeCli, sEnd);
  GravaLog(' Bematech_FI_AbreCupomMFD <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );

  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech2000.StatusImp( Tipo:Integer ):String;
    Function TrataFlag(iFlag: integer): integer;
    Begin
      Result := 0;
      if iFlag >= 128 then iFlag := iFlag -128;
      if iFlag >= 32  then iFlag := iFlag -32;
      if iFlag >= 8   then iFlag := iFlag -8;
      if iFlag >= 4   then iFlag := iFlag -4;
      if iFlag >= 2   then iFlag := iFlag -2;

      if iFlag = 1 then Result := 1;
    End;
var
  iRet, iFlag, i, iAck, iSt1, iSt2 : Integer;
  sRet, Data, Hora, sDataHoje, FlagTruncamento, sCuponsEmitidos, sUltimoItem,
  sOperacoes, sCRG, sCDC, sDataHora,  sVendaBruta, sSubTotal,sGrandeTotal, sDataMov: String;
  dDtHoje,dDtMov:TDateTime;
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
  // 19 - Retorna a data do movimento
  // 20 - Verifica qual é o CNPJ cadastrado na Impressora
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

  //  1 - Obtem a Hora da Impressora
  sVendaBruta := Space(20);
  sGrandeTotal := Space(20);
  If Tipo = 1 then
  begin
    Data:=Space(6);
    Hora:=Space(6);
    iRet := fFuncBematech_FI_DataHoraImpressora( Data, Hora );
    TrataRetornoBematech( iRet, True );
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
    iRet := fFuncBematech_FI_DataHoraImpressora( Data, Hora );
    TrataRetornoBematech( iRet, True );
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
    iRet := fFuncBematech_FI_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
    TrataRetornoBematech( iRet, True );
    If iSt1 >= 128 Then
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
    iRet := fFuncBematech_FI_FlagsFiscais(iFlag);
    iRet := TrataFlag(iFlag);
    If iRet = 1 Then
        Result := '7'    // aberto
    Else
        Result := '0';  // Fechado
  end
  //  6 - Ret. suprimento da impressora
  Else If Tipo = 6 then
  begin
      sRet := Space(3016);
      iRet := fFuncBematech_FI_VerificaFormasPagamento( sRet );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        i:=1;
        Repeat
            If UpperCase(Trim(Copy(sRet,1,16)))='DINHEIRO'
            then  Result := '0|' + Trim(FormataTexto(Copy(sRet,17,18)+','+Copy(sRet,35,2),12,2,3));

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
                iRet:=fFuncBematech_FI_DataMovimento(Data);
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
  //  9 - Verifica o Status do ECF
  Else If Tipo = 9 then
        begin
           If Verifica_Status( False, False ) <> 1 then
                   Begin
                      iRet := fFuncBematech_FI_FlagsFiscais(iFlag);
                      iRet := TrataFlag(iFlag);
                        If iRet = 1 Then
                          Result := '0'    // aberto
                        Else
                          Result := '-1';  // Fechado
                   End
           else
                   Result := '0';
        end
  // 10 - Verifica se todos os itens foram impressos.
  Else If Tipo = 10 then
    Result := '0'
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  Else If Tipo = 11 then
    Result := '1'
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  Else If Tipo = 12 then
    Result := '1'
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  Else If Tipo = 13 then
  begin
    FlagTruncamento := Space(2);
    // Para o FlagTruncamento, retorna 1 se a impressora estiver no modo truncamento e 0 se estiver no modo arredondamento.
    iRet := fFuncBematech_FI_VerificaTruncamento( FlagTruncamento );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := Copy( FlagTruncamento, 1, 1 )
    Else
      Result := '1';
  end
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  else if Tipo = 14 then
    Result := '0'
  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  else if Tipo = 15 then
    Result := '1'
  // 16 - Verifica se exige o extenso do cheque
  else if Tipo = 16 then
    Result := '1'
  // 17 - Verifica venda bruta
  else if Tipo = 17 then
  begin
    GravaLog('Bematech_FI_VendaBruta ->');
    iRet := fFuncBematech_FI_VendaBruta( sVendaBRuta );
    GravaLog('Bematech_FI_VendaBruta <- iRet: '+ IntToStr(iRet) + ', Retorno:' + sVendaBRuta );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sVendaBRuta;
  end
  // 18 - Verifica Grande Total
  else if Tipo = 18 then
  begin
    GravaLog('Bematech_FI_GrandeTotal ->');
    iRet := fFuncBematech_FI_GrandeTotal( sGrandeTotal );
    GravaLog('Bematech_FI_GrandeTotal <- iRet: '+ IntToStr(iRet) + ', Retorno:' + sGrandeTotal );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sGrandeTotal;
  end
  // 19 - Retorna a data do movimento da impressora
  else if Tipo = 19 then
  begin
    sDataMov    := Space(6);
    sDataHoje   := Space(6);
    GravaLog('Bematech_FI_DataMovimento ->');
    iRet        := fFuncBematech_FI_DataMovimento( sDataMov );
    GravaLog('Bematech_FI_DataMovimento <- iRet: '+ IntToStr(iRet) + ', Retorno:' + sDataMov );
    TrataRetornoBematech( iRet, True );

    If iRet = 1 Then
     begin
      sDataHoje    := Copy(StatusImp(2),3,8);
      If sDataMov = '000000' then
          Result:= '2|'+ sDataHoje
      else

         begin
             sDataMov     := Copy(sDataMov,1,2)+'/'+Copy(sDataMov,3,2)+'/'+Copy(sDataMov,5,2);
             If (StrToDate(sDataMov) < StrToDate(sDataHoje)) then    // reducao pendente
                Result := '0|'+ sDataMov
             Else
                Result := '2|'+ sDataHoje;
          end
     end
    else
        //Retornou erro na operacao do 19
        Result := '-1';
  end

  // 20 - Retorna o CNPJ cadastrado na impressora
  else if Tipo = 20 then
    Result := '0|' + Cnpj

  // 21 - Retorna o IE cadastrado na impressora
  else if Tipo = 21 then
    Result := '0|' + Ie

  // 22 - Retorna o CRZ - Contador de Reduções Z
  else if Tipo = 22 then
  begin
    If ReducaoEmitida then
    begin
      GravaLog('Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('Bematech_FI_RegistrosTipo60 <- iRet: '+ IntToStr(iRet) );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        ContadorCrz := LeArqRetorno( Path, sArqIniBema, 55 , 3 );
        Result := '0|' + ContadorCrz
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
    If IndicaMFAdi = '' Then
      IndicaMFAdi := Retorna_Informacoes(1);
    Result := '0|' + IndicaMFAdi;
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
      DataIntEprom := Retorna_Informacoes(2);
    Result := '0|' + DataIntEprom;
  end

  // 30 - Retorna o Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  else if Tipo = 30 then
  begin
    If HoraIntEprom = '' Then
      HoraIntEprom := Retorna_Informacoes(3);
    Result := '0|' + HoraIntEprom;
  end

  // 31 - Retorna o Nº de ordem seqüencial do ECF no estabelecimento usuário
  else if Tipo = 31 then
    Result := '0|' + Pdv

  // 32 - Retorna o Grande Total Inicial
  else if Tipo = 32 then
  begin
    If ReducaoEmitida then
    begin
      GravaLog('Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('Bematech_FI_RegistrosTipo60 <- iRet: '+ IntToStr(iRet) );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
        GTFinal       := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
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
      GravaLog('Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('Bematech_FI_RegistrosTipo60 <- iRet: '+ IntToStr(iRet) );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        GTFinal := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
        Result := '0|' + GTFinal
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
      GravaLog('Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('Bematech_FI_RegistrosTipo60 <- iRet: '+ IntToStr(iRet) );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
        Result := '0|' + VendaBrutaDia
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
    iRet := fFuncBematech_FI_ContadorCupomFiscalMFD(sCuponsEmitidos);
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sCuponsEmitidos
    else
      Result := '1';
  end

  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  else if Tipo = 36 then
  begin
    sOperacoes := Space(6);
    iRet := fFuncBematech_FI_NumeroOperacoesNaoFiscais( sOperacoes );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sOperacoes
    Else
      Result := '1';
  end

  // 37 - Retorna o Contador Geral de Relatório Gerencial
  else if Tipo = 37 then
  begin
    sCRG := Space(6);
    iRet := fFuncBematech_FI_ContadorRelatoriosGerenciaisMFD( sCRG );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sCRG
    Else
      Result := '1';
  end

  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  else if Tipo = 38 then
  begin
    sCDC := Space(4);
    iRet := fFuncBematech_FI_ContadorComprovantesCreditoMFD( sCDC );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sCDC
    Else
      Result := '1';
  end

  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  else if Tipo = 39 then
  begin
    sDataHora := Space(12);
    iRet := fFuncBematech_FI_DataHoraUltimoDocumentoMFD( sDataHora );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sDataHora
    Else
      Result := '1';
  end

  // 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CÓDIGOS DE IDENTIFICAÇÃO DE ECF
  else if Tipo = 40 then
    Result := '0|' + CodigoEcf

  // 41 - Retorna o sequencial do último item vendido
  else if Tipo = 41 then
  Begin
    sUltimoItem := Space(4);
    iRet := fFuncBematech_FI_UltimoItemVendido( sUltimoItem );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sUltimoItem
    Else
      Result := '1';
  End

  // 42 - Retorna o subtotal do cupom
  else if Tipo = 42 then
  Begin
    sSubTotal := Space(14);
    iRet := fFuncBematech_FI_SubTotal( sSubTotal );
    TrataRetornoBematech( iRet, True );
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
function TImpBematech2000.ReducaoZ(MapaRes:String):String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i, iPos : Integer;
  aRetorno,aFile : array of String;
  sData, sHora, sLinhaISS, sTotalISS,
  sRetorno, sFile, sLinha, sFlag,
  sAux, sAux2, sTribIS1, sTribNS1, sTribFS1 : String;
  fFile : TextFile;
  fBase, fAliq, fValor1, fValor2 : Real;
  aAuxiliar : TaString;
begin
If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    GravaLog(' Bematech_FI_DataMovimento - > ');
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    GravaLog(' Bematech_FI_DataMovimento <- iRet:' + IntToStr(iRet));
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := Pdv;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                              //**** Numero de reducoes ****//
    GravaLog(' Bematech_FI_NumeroReducoes - > ');
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    GravaLog(' Bematech_FI_NumeroReducoes <- iRet:' + IntToStr(iRet));
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    GravaLog(' Bematech_FI_GrandeTotal - > ');
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    GravaLog(' Bematech_FI_GrandeTotal <- iRet:' + IntToStr(iRet));
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    GravaLog(' Bematech_FI_NumeroCupom - > ');
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    GravaLog(' Bematech_FI_NumeroCupom <- iRet:' + IntToStr(iRet));
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[ 5] := aRetorno[ 6];

    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//

    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2); //***** Numero do comprovante da Redução z

    aRetorno[15] := FormataTexto('0',16, 0, 1);           // --outros recebimentos--

    {
      *********************************************
      ********* TOTALIZADORES DO ECF **************
      *********************************************
    }

    sRetorno := Space(889);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD - > ');
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciaisMFD(sRetorno);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD <- iRet:' + IntToStr(iRet));

    sRetorno := StrTran( sRetorno , ',' , '|' );
    MontaArray( sRetorno , aAuxiliar );

    aRetorno[11] := aAuxiliar[1];           //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    aRetorno[12] := aAuxiliar[2];           //**** Nao tributado Nao Tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    aRetorno[10] := aAuxiliar[3];           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    sTribIS1 := Copy(aAuxiliar[4],1,Length(aAuxiliar[4])-2)+'.'+Copy(aAuxiliar[4],Length(aAuxiliar[4])-1,Length( aAuxiliar[4]));//Isenção de ISS
    sTribNS1 := Copy(aAuxiliar[5],1,Length(aAuxiliar[5])-2)+'.'+Copy(aAuxiliar[5],Length(aAuxiliar[5])-1,Length( aAuxiliar[5]));//Não incidencia de ISS
    sTribFS1 := Copy(aAuxiliar[6],1,Length(aAuxiliar[6])-2)+'.'+Copy(aAuxiliar[6],Length(aAuxiliar[6])-1,Length( aAuxiliar[6]));//Substituição de ISS

    //Descontos sobre ICMS
    aRetorno[ 9] := aAuxiliar[7];
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    //aAuxiliar[8]; //Acrescimo sobre ICMS

    //Cancelamentos sobre ICMS
    aRetorno[ 7] := aAuxiliar[9];
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    // desconto de ISS
    sRetorno := aAuxiliar[10];
    aRetorno[18]:= Copy(sRetorno,1,Pos(',',sRetorno)-1);
    aRetorno[18]:= Copy(aRetorno[18],1,Length(aRetorno[18])-2)+'.'+Copy(aRetorno[18],Length(aRetorno[18])-1,Length(aRetorno[18]));
    aRetorno[18]:= FormataTexto(aRetorno[18], 11, 2, 1 );

    //aAuxiliar[11]; //Acrescimo sobre ISS

    //Cancelamento sobre ISS
    sRetorno := aAuxiliar[12];
    aRetorno[19]:= Copy(sRetorno,1,Pos(',',sRetorno)-1);
    aRetorno[19]:= Copy(aRetorno[19],1,Length(aRetorno[19])-2)+'.'+Copy(aRetorno[19],Length(aRetorno[19])-1,Length(aRetorno[19]));
    aRetorno[19]:= FormataTexto(aRetorno[19], 11, 2, 1 );

    // QTD DE Aliquotas
    aRetorno[20]:= '00';

    GravaLog(' Bematech_FI_LeituraXSerial -> ');
    iRet := fFuncBematech_FI_LeituraXSerial();
    GravaLog(' Bematech_FI_LeituraXSerial <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path')+'\' +'RETORNO.TXT';
      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '';
        ReadLn(fFile, sLinha);

        While ( Pos(#$A,UpperCase( sLinha) )) > 0 Do
        Begin
            iPos := Pos(#$A,UpperCase( sLinha) );
            SetLength( aFile, Length(aFile) + 1 );
            aFile[ High(aFile) ] := Copy( sLinha,1,iPos -1 );
            sLinha := Copy( sLinha,iPos + 1,Length(sLinha) );
        End;

        CloseFile(fFile);

        For iPos := 0 to Length( aFile )-1 Do
        Begin
          sLinha := aFile[ iPos ];
          sLinha := TrataLinha(sLinha);
          if ( Pos('Contador de Cupom Fiscal:' ,sLinha)>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
          if ( Pos('VENDA LÖQUIDA:',sLinha)>0) or ( Pos('VENDA LÍQUIDA:',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
          if ( Pos('Contador de Reinício de Operação:',sLinha)>0) Or
             ( Pos('Contador de Rein¡cio de Opera‡Æo:',sLinha)>0) Or
             ( Pos('CONTADOR DE REINÍCIO DE OPERAÇÃO:',UpperCase(sLinha))>0) then  // CRO - Contador de Reinício de Operação
            aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
          if ( Pos('Total ',sLinha)>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
          begin
            if sFlag = 'S' // Verifica se é aliquota de ISS e soma o total ao array
            then aRetorno[16] := sTotalISS + ';' + aRetorno[16];

            // desliga a captura das aliquotas
            sFlag:='';
          end;

          if ( sFlag='T' ) and ( Copy(sLinha,1,1)='T' ) and ( Copy(sLinha,2,1)<>'o' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            sLinha := StrTran( sLinha, '*', ' ' );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            aRetorno[High(aRetorno)]:=Copy(sLinha,1,6)+' '+FormataTexto(StrTran(Copy(sLinha,8,21),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,30,19),'.',''),14,2,1,'.')
          End;

          // Totais ISS
          if ( sFlag='S' ) and ( Copy(sLinha,1,1)='S' ) then
          Begin
            // ' Valor '  ' Imposto Debitado
             fBase:= StrToFloat(StrTran(StrTran(copy(sLinha,12,24),'.',''),',','.'));
             fAliq:= StrToFloat(StrTran(StrTran(copy(sLinha,32,20),'.',''),',','.'));

             sTotalISS := FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,1,14))+ fBase) ,14,2,1)+' '+
                            FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,16,14))+ fAliq) ,14,2,1);
                          //Aliquota                    //Valor Base                                    //Valor Debitado
             sLinhaISS := StrTran(Copy( sLinha , 1 , 6),',','.') + ' ' + FormataTexto(FloatToStr(fBase) ,14,2,1) + ' ' +
                           FormataTexto(FloatToStr(fAliq) ,14,2,1) + ';' ; // ';' separador de aliquotas de ISS
             aRetorno[16] := aRetorno[16] + sLinhaISS ;
          End;

          // Liga a captura das aliquotas de ICMS
          if (Pos('----------ICMS----------',sLinha)>0)
          then sFlag:='T';

          // Liga a captura das aliquotas de ISS
          if (Pos('---------ISSQN----------',sLinha)>0) then
          begin
            sFlag:='S';
            sTotalISS := '00000000000.00 00000000000.00';
          end;
        end;

        If Trim(aRetorno[16]) = ''
        then aRetorno[16]:= '00000000000.00 00000000000.00';

        //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
        //   Valor Debitado com 12 casas e 2 decimais + Separador ';'        
        If StrToFloat(sTribIS1) > 0
        then aRetorno[16] := aRetorno[16] + 'IS1' + ' ' +
                                FormataTexto(sTribIS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribNS1) > 0
        then aRetorno[16] := aRetorno[16] + 'NS1' + ' ' +
                                 FormataTexto(sTribNS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribFS1) > 0
        then aRetorno[16] := aRetorno[16] + 'FS1' + ' ' +
                                FormataTexto(sTribFS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

      end
      else
      begin
        GravaLog(' Arquivo ' + sFile + ' não encontrado. Bases não serão gravadas ');
      end;
    end;
 end;

  Try
    GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
  Except
    GravaLog('Bematech - Redução Z - Erro na execução do comando: GrvTempRedZ()')
  End;

  DateTimeToString( sData, 'ddmmyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );

  GravaLog(' Bematech_FI_ReducaoZ -> ');
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  GravaLog(' Bematech_FI_ReducaoZ <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );
  GravaLog(' Bematech_FI_ReducaoZ <- iRet:' + IntToStr(iRet));

  If iRet = 1 then
  begin
    ReducaoEmitida := True;

    If aRetorno[0] = '00/00/00' then
    begin
      GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 00/00/00 ' +
               'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
      sAux := Space(6);
      sAux2:= Space(6);
      GravaLog(' Bematech_FI_DataHoraReducao -> ');
      iRet := fFuncBematech_FI_DataHoraReducao( sAux , sAux2);
      GravaLog(' Bematech_FI_DataHoraReducao <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux + ' , Hora: ' + sAux2);
      sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
      aRetorno[0] := sAux;
      GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
    end;

    If Trim(MapaRes) = 'S' then
    begin
       //*************************************************************************
       // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
       //*************************************************************************
       aAuxiliar:= NIL;
       sRetorno := Space( 20000 );
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> ');
       iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sRetorno );
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> iRet: ' + IntToStr(iRet) + ' - Retorno :' + Trim(sRetorno));
       sRetorno := StrTran( sRetorno, ',', '|' );
       MontaArray( sRetorno, aAuxiliar );

       //*************************************************************************
       // Grava o valor do desconto
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[23] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[24] ) / 100;
       aRetorno[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // desconto de ISS

       //*************************************************************************
       // Grava o valor do cancelamento
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[27] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[28] ) / 100;
       aRetorno[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[19]:= FormataTexto( FloatToStr(fValor2) , 11, 2, 1 );                 // cancelamento de ISS

       //*************************************************************************
       // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
       //*************************************************************************
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';

       GravaLog(' <- Retorno Mapa Resumo: '+ Result );
    end
    Else
        Result := '0';
  end
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
Procedure TImpBematech2000.AlimentaProperties;
    Procedure CargaIndiceAliq();
    var i, iRet : Integer;
        sIndiceISS, sISS, sICMS : String;
    begin
      try
        sICMS := ICMS;
        sIndiceISS := Space(48);
        iRet := fFuncBematech_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoBematech(iRet);
        If (iRet = 1) And (sIndiceISS[1] <> #0) then
        Begin
            i := 1;
            While Length(sICMS)>0 do
            Begin
                SetLength(aIndAliq,Length(aIndAliq)+2);
                aIndAliq[Length(aIndAliq)-2] := FormataTexto(IntToStr(i),2,0,2);
                If i <> StrToInt(Copy(sIndiceISS,1,2)) then
                begin
                  aIndAliq[Length(aIndAliq)-1] := 'T' + Copy(sICMS,1, Pos('|', sICMS)-1);
                end
                Else
                begin
                  aIndAliq[Length(aIndAliq)-1] := 'S' + Copy(sICMS,1, Pos('|', sICMS)-1);
                  sIndiceISS:= Copy(sIndiceISS,Pos(',', sIndiceISS)+1, Length(sIndiceISS));
                End;
                sICMS := Copy(sICMS,Pos('|', sICMS)+1, Length(sICMS));
                i := i + 1;
            End;
        End;
      except
      end;
    End;
var
  iRet : Integer;
  sRet, sICMS, sISS, sAliq, sDadosUltZ : String;
  lEstendido,lErro : Boolean;
begin

   GravaLog(' -> AlimentaProperties - INICIALIZA AS VARIAVEIS' );
   
  // Inicalização de propriedades
  ICMS  := '';
  ISS   := '';
  Pdv   := '';
  Eprom := '';
  Cnpj  := Space(18);
  Ie    := Space(15);
  NumLoja   := Space(4);
  NumSerie  := Space(20);
  TipoEcf   := Space(7);
  MarcaEcf  := Space(15);
  ModeloEcf := Space(20);
  IndicaMFAdi  := '';
  DataIntEprom := '';
  HoraIntEprom := '';
  ContadorCro  := '';
  ContadorCrz  := '';
  ReducaoEmitida := False;
  //--------------------------

  // Inicalização de variaveis
  sDadosUltZ   := Space(20000);
  lEstendido   := true;

  lError := False;
  //--------------------------

  GravaLog(' -> AlimentaProperties - RETORNA ALIQUOTAS ISS' );

  // Retorno de Aliquotas ( ISS )
  Try
   WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (79) -> ');
   sRet := Space( 79 );
   iRet := fFuncBematech_FI_VerificaAliquotasIss( sRet );
   TrataRetornoBematech( iRet, lEstendido );
   WriteLog('sigaloja.log', 'Bematech_FI_VerificaAliquotasIss (79) <- Retorno :' + IntToStr(iRet));
   lErro := False;
  Except on E:Exception do
    begin
     WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (79) <- ' + E.className + ' Erro :' + E.message);
     lErro := True;
    end;
  End;

  If lErro Then
  begin
    Try
     WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (80) -> ');
     sRet := Space( 80 );
     iRet := fFuncBematech_FI_VerificaAliquotasIss( sRet );
     TrataRetornoBematech( iRet, lEstendido );
     WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (80) <- Retorno :' + IntToStr(iRet));
     lErro := False;
    Except on E:Exception do
      begin
       WriteLog('sigaloja.log','Bematech_FI_VerificaAliquotasIss (80) <- ' + E.className + ' Erro :' + E.message);
       lErro := True;
      end;
    End;
  End;

  If iRet = 1 then
  begin
    sISS := Trim( StrTran( sRet, ',', '|' ) );
    While Length(sISS)>0 do
    begin
      sAliq := Copy(sISS,1,2)+','+Copy(sISS,3,2);
      ISS   := ISS + FormataTexto(sAliq,5,2,1) + '|';
      sISS  := Copy(sISS,6,Length(sISS));
    end
  end
  Else
    exit;

  GravaLog(' <- AlimentaProperties - ALIQUOTAS ISS: '+sISS );
  GravaLog(' -> AlimentaProperties - RETORNA ALIQUOTAS ICMS' );

// Retorno de Aliquotas ( ICMS )
  Try
   WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (79) -> ');
   sRet := Space( 79 );
   iRet := fFuncBematech_FI_RetornoAliquotas( sRet );
   TrataRetornoBematech( iRet, lEstendido );
   WriteLog('sigaloja.log', 'Bematech_FI_RetornoAliquotas (79) <- Retorno :' + IntToStr(iRet));
   lErro := False;
  Except on E:Exception do
    begin
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (79) <- ' + E.className + ' Erro :' + E.message);
     lErro := True;
    end;
  End;

  If lErro Then
  begin
    Try
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) -> ');
     sRet := Space( 80 );
     iRet := fFuncBematech_FI_RetornoAliquotas( sRet );
     TrataRetornoBematech( iRet, lEstendido );
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) <- Retorno :' + IntToStr(iRet));
     lErro := False;
    Except on E:Exception do
      begin
       WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) <- ' + E.className + ' Erro :' + E.message);
       lErro := True;
      end;
    End;
  End;

  If iRet = 1 then
  begin
    sICMS := Trim( StrTran( sRet, ',', '|' ) );
    While Length(sICMS)>0 do
    begin
      sAliq := Copy(sICMS,1,2)+','+Copy(sICMS,3,2);
      ICMS  := ICMS + FormataTexto(sAliq,5,2,1) + '|';
      sICMS := Copy(sICMS,6,Length(sICMS));
    end;
    CargaIndiceAliq()
  end
  Else
    exit;
  If LogDLL Then
  begin
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - ALIQUOTAS ICMS: '+sICMS ));
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - RETORNA NUMERO DO PDV' ));
  end;
     
  // Retorno do Numero do Caixa (PDV)
  sRet := Space ( 4 );
  iRet := fFuncBematech_FI_NumeroCaixa( sRet );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
  begin
    If Pos(#0,sRet) > 0 then
      Pdv := Copy(sRet,1,Pos(#0,sRet)-1)
    Else
      Pdv := Copy(sRet,1,4);
  end
  Else
    exit;
    
  If LogDLL Then
  begin
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - NUMERO DO PDV: '+Pdv ));
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - RETORNA FIRMWARE' ));
  end;
     
  // Retorno da Versão do Firmware (Eprom)
  sRet := Space( 6 );
  iRet := fFuncBematech_FI_VersaoFirmwareMFD( sRet );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
    Eprom := sRet
  Else
    exit;
  If LogDLL Then
  begin
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - FIRMWARE: '+Eprom ));
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - RETORNA CNPJ/IE' ));
  end;

  // Retorna o CNPJ
  // Retorna a IE
  iRet := fFuncBematech_FI_CGC_IE( Cnpj, Ie );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet <> 1 then
    exit;
    
  If LogDLL Then
  begin
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - CNPJ: '+Cnpj+' / IE: '+Ie ));
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - RETORNA NUMERO DA LOJA' ));
  end;
  // Retorna o Numero da loja cadastrado no ECF
  iRet := fFuncBematech_FI_NumeroLoja( NumLoja );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
    NumLoja := Trim( NumLoja )
  Else
    exit;

  If LogDLL Then
  begin
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - NUMERO DA LOJA: '+NumLoja ));
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - RETORNA NUMERO DE SERIE' ));
  end;

  // Retorna o Numero da Serie
  iRet := fFuncBematech_FI_NumeroSerieMFD( NumSerie );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
    NumSerie := Trim( NumSerie )
  Else
    exit;
  If LogDLL Then
  begin
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - NUMERO DE SERIE: '+NumSerie ));
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - RETORNA MARCA/MODELO/TIPO ECF' ));
  end;
     
  // Retorna Marca do ECF
  // Retorna Modelo do ECF
  // Retorna o Tipo do ECF
  iRet := fFuncBematech_FI_MarcaModeloTipoImpressoraMFD( MarcaEcf, ModeloEcf, TipoEcf );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
  begin
    MarcaEcf  := Trim( MarcaEcf );
    ModeloEcf := Trim( ModeloEcf );
    TipoEcf   := Trim( TipoEcf );
  end
  Else
    exit;

  GravaLog(' <- AlimentaProperties - MARCA: '+MarcaEcf+' / MODELO: '+ModeloEcf+' / TIPO ECF: '+TipoEcf );

  // Retorna Data de gravação do último usuário da impressora
  // Retorna Hora de gravação do último usuário da impressora
  // Retorna Data de Instalação da Eprom
  // Retorna Hora de Instalação da Eprom
  // Retorna Letra indicativa de MF adicional
  {
  iRet := fFuncBematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional( sAuxDtU, sAuxDtS, sAuxMfA);
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
  begin
    DataGrvUsuario := StrTran( Copy( sAuxDtU, 1, 10 ), '/', '');
    HoraGrvUsuario := StrTran( Copy( sAuxDtU, 12, 8 ), ':', '');
    DataIntEprom := StrTran( Copy( sAuxDtS, 1, 10 ), '/', '');
    HoraIntEprom := StrTran( Copy( sAuxDtS, 12, 8 ), ':', '');
    IndicaMFAdi  := sAuxMfA;
  end
  Else
    exit;
  }

  GravaLog(' -> AlimentaProperties - RETORNA NUMERO CRO/CRZ' );

  // Retorna Contador de Reinicio de Operação
  // Retorna Contador de ReduçãoZ
  GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> ');
  iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sDadosUltZ );
  GravaLog(' Bematech_FI_DadosUltimaReducaoMFD <- iRet : ' + IntToStr(iRet) +' - Retorno: ' + sDadosUltZ);

  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
  begin
    ContadorCro  := Copy( sDadosUltZ, 4, 4 );
    ContadorCrz  := Copy( sDadosUltZ, 9, 4 );
  end
  Else
    exit;
  If LogDLL Then
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - CRO: '+ContadorCro+' / CRZ: '+ContadorCrz ));

  If LogDLL Then
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> AlimentaProperties - RETORNA GT INICIAL / GT FINAL / VENDA BRUTA DIARIA' ));
  //Retorna o Grande Total Inicial
  //Retorna o Grande Total Final
  //Retorna a Venda Bruta Diaria
  iRet := fFuncBematech_FI_RegistrosTipo60();
  If LogDLL Then
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - Bematech_FI_RegistrosTipo60: '+IntToStr(iRet) ));
  TrataRetornoBematech( iRet, lEstendido );
  If LogDLL Then
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - TrataRetornoBematech' ));
  If iRet = 1 then
  begin
    If LogDLL Then
       WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - VendaBrutaDia' ));
    VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
    If LogDLL Then
       WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - VendaBrutaDia: '+VendaBrutaDia ));
    If LogDLL Then
       WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - GTFinal' ));
    GTFinal       := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
    If LogDLL Then
       WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - GTFinal: '+GTFinal ));
    If LogDLL Then
       WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - GTInicial' ));
    GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );
    If LogDLL Then
       WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - VendaBrutaDia: '+VendaBrutaDia+' / GTFinal: '+GTFinal+' / GTInicial: '+GTInicial ));
  end
  Else
    exit;
  If LogDLL Then
     WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- AlimentaProperties - VendaBrutaDia: '+VendaBrutaDia+' / GTFinal: '+GTFinal+' / GTInicial: '+GTInicial ));

end;

 //---------------------------------------------------------------------------
function TImpBematech3000.ReducaoZ(MapaRes:String):String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i, iPos : Integer;
  aRetorno,aFile : array of String;
  sData, sHora, sRetorno , sLinhaISS,
  sTotalISS, sFile, sLinha, sFlag,
  sAux, sAux2, sTribIS1, sTribNS1, sTribFS1 : String;
  fFile : TextFile;
  fBase, fAliq, fValor1, fValor2 : Real;
  aAuxiliar : TaString;
begin
If Trim(MapaRes) = 'S' then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    GravaLog(' Bematech_FI_DataMovimento -> ');
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    GravaLog(' Bematech_FI_DataMovimento <- iRet:' + IntToStr(iRet));
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := Pdv;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0' then
      aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    GravaLog(' Bematech_FI_NumeroReducoes ->');
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    GravaLog(' Bematech_FI_NumeroReducoes <- iRet:' + IntToStr(iRet));
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    GravaLog(' Bematech_FI_GrandeTotal ->');
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    GravaLog(' Bematech_FI_GrandeTotal <- iRet:' + IntToStr(iRet));
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    GravaLog(' Bematech_FI_NumeroCupom ->');
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    GravaLog(' Bematech_FI_NumeroCupom <- iRet:' + IntToStr(iRet));
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);
    aRetorno[ 5] := aRetorno[ 6];

    aRetorno[13] := Copy(StatusImp(2),3,10);              //**** Data da Reducao  Z ****//
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);
    aRetorno[15] := FormataTexto('0',16, 0, 1);           // --outros recebimentos--

    { *********************************************
      ********* TOTALIZADORES DO ECF **************
      *********************************************}

    sRetorno := Space(889);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD - > ');
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciaisMFD(sRetorno);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD <- iRet:' + IntToStr(iRet));

    sRetorno := StrTran( sRetorno , ',' , '|' );
    MontaArray( sRetorno , aAuxiliar );

    aRetorno[11] := aAuxiliar[1];           //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    aRetorno[12] := aAuxiliar[2];           //**** Nao tributado Nao Tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    aRetorno[10] := aAuxiliar[3];           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    sTribIS1 := Copy(aAuxiliar[4],1,Length(aAuxiliar[4])-2)+'.'+Copy(aAuxiliar[4],Length(aAuxiliar[4])-1,Length( aAuxiliar[4]));//Isenção de ISS
    sTribNS1 := Copy(aAuxiliar[5],1,Length(aAuxiliar[5])-2)+'.'+Copy(aAuxiliar[5],Length(aAuxiliar[5])-1,Length( aAuxiliar[5]));//Não incidencia de ISS
    sTribFS1 := Copy(aAuxiliar[6],1,Length(aAuxiliar[6])-2)+'.'+Copy(aAuxiliar[6],Length(aAuxiliar[6])-1,Length( aAuxiliar[6]));//Substituição de ISS

    //Descontos sobre ICMS
    aRetorno[ 9] := aAuxiliar[7];
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    //aAuxiliar[8]; //Acrescimo sobre ICMS

    //Cancelamentos sobre ICMS
    aRetorno[ 7] := aAuxiliar[9];
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    //desconto de ISS
    aRetorno[18]:= aAuxiliar[10];
    aRetorno[18]:= Copy(aRetorno[18],1,Length(aRetorno[18])-2)+'.'+Copy(aRetorno[18],Length(aRetorno[18])-1,Length(aRetorno[18]));
    aRetorno[18]:= FormataTexto(aRetorno[18], 11, 2, 1 );

    //aAuxiliar[11]; //Acrescimo sobre ISS

    //Cancelamento sobre ISS
    aRetorno[19]:= aAuxiliar[12];
    aRetorno[19]:= Copy(aRetorno[19],1,Length(aRetorno[19])-2)+'.'+Copy(aRetorno[19],Length(aRetorno[19])-1,Length(aRetorno[19]));
    aRetorno[19]:= FormataTexto(aRetorno[19], 11, 2, 1 );

    aRetorno[20]:= '00';   // QTD DE Aliquotas

    GravaLog(' Bematech_FI_LeituraXSerial -> ');
    iRet := fFuncBematech_FI_LeituraXSerial();
    GravaLog(' Bematech_FI_LeituraXSerial <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path')+'\' +'RETORNO.TXT';
      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '';
        ReadLn(fFile, sLinha);

        While ( Pos(#$A,UpperCase( sLinha) )) > 0 Do
        Begin
          iPos := Pos(#$A,UpperCase( sLinha) );
          SetLength( aFile, Length(aFile) + 1 );
          aFile[ High(aFile) ] := Copy( sLinha,1,iPos -1 );
          sLinha := Copy( sLinha,iPos + 1,Length(sLinha) );
        End;

        CloseFile(fFile);

        For iPos := 0 to Length( aFile )-1 Do
        Begin
          sLinha := aFile[ iPos ];
          sLinha := TrataLinha(sLinha);
          if ( Pos('Contador de Cupom Fiscal:' ,sLinha)>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
          if ( Pos('VENDA LÖQUIDA:',sLinha)>0) or ( Pos('VENDA LÍQUIDA:',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
          if ( Pos('Contador de Reinício de Operação:',sLinha)>0) Or
             ( Pos('Contador de Rein¡cio de Opera‡Æo:',sLinha)>0) Or
             ( Pos('CONTADOR DE REINÍCIO DE OPERAÇÃO:',UpperCase(sLinha))>0) then  // CRO - Contador de Reinício de Operação
            aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
          if ( Pos('Total ',sLinha)>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
          begin
            if sFlag = 'S' // Verifica se é aliquota de ISS e soma o total ao array
            then aRetorno[16] := sTotalISS + ';' + aRetorno[16];

            // desliga a captura das aliquotas
            sFlag:='';
          end;

          if ( sFlag='T' ) and ( Copy(sLinha,1,1)='T' ) and ( Copy(sLinha,2,1)<>'o' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            sLinha := StrTran( sLinha, '*', ' ' );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            aRetorno[High(aRetorno)]:= Copy(sLinha,1,6)+' '+
                                       FormataTexto(StrTran(Copy(sLinha,8,22),'.',''),14,2,1,'.')+' '+
                                       FormataTexto(StrTran(Copy(sLinha,30,19),'.',''),14,2,1,'.');
          End;

          // Totais ISS
          if ( sFlag='S' ) and ( Copy(sLinha,1,1)='S' ) then
          Begin
            // ' Valor '  ' Imposto Debitado
             fBase:= StrToFloat(StrTran(StrTran(copy(sLinha,12,24),'.',''),',','.'));
             fAliq:= StrToFloat(StrTran(StrTran(copy(sLinha,32,20),'.',''),',','.'));
             sTotalISS :=FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,1,14))+ fBase) ,14,2,1)+' '+
                            FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,16,14))+ fAliq) ,14,2,1);
                          //Aliquota                    //Valor Base                                    //Valor Debitado
             sLinhaISS := StrTran(Copy( sLinha , 1 , 6),',','.') + ' ' + FormataTexto(FloatToStr(fBase) ,14,2,1) + ' ' +
                           FormataTexto(FloatToStr(fAliq) ,14,2,1) + ';' ; // ';' separador de aliquotas de ISS
             aRetorno[16] := aRetorno[16] + sLinhaISS ;
          End;

          if (Pos('          ICMS          ',sLinha)>0) then
          // Liga a captura das aliquotas de ICMS
            sFlag:='T';
          if (Pos('         ISSQN          ',sLinha)>0) then
          begin
            // Liga a captura das aliquotas de ISS
            sFlag:='S';
            sTotalISS := '00000000000.00 00000000000.00';
          end;
        end;

        If Trim(aRetorno[16]) = ''
        then aRetorno[16]:= '00000000000.00 00000000000.00';

        //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
        //   Valor Debitado com 12 casas e 2 decimais + Separador ';'        
        If StrToFloat(sTribIS1) > 0
        then aRetorno[16] := aRetorno[16] + 'IS1' + ' ' +
                                FormataTexto(sTribIS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribNS1) > 0
        then aRetorno[16] := aRetorno[16] + 'NS1' + ' ' +
                                 FormataTexto(sTribNS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribFS1) > 0
        then aRetorno[16] := aRetorno[16] + 'FS1' + ' ' +
                                FormataTexto(sTribFS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;
      end
      else
      begin
        GravaLog(' Arquivo ' + sFile + ' não encontrado. Portanto as informações de alíquota não serão gravadas');
      end;
    end;
 end;

  Try
    GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
  Except
    GravaLog('Bematech - Redução Z - Erro na execução do comando: GrvTempRedZ()')
  End;

  DateTimeToString( sData, 'ddmmyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  GravaLog(' Bematech_FI_ReducaoZ -> ');
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  GravaLog(' Bematech_FI_ReducaoZ <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );
  If iRet = 1 then
  begin
    ReducaoEmitida := True;

    If aRetorno[0] = '00/00/00' then
    begin
      GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 00/00/00 ' +
               'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
      sAux := Space(6);
      sAux2:= Space(6);
      GravaLog(' Bematech_FI_DataHoraReducao -> ');
      iRet := fFuncBematech_FI_DataHoraReducao( sAux , sAux2);
      GravaLog(' Bematech_FI_DataHoraReducao <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux + ' , Hora: ' + sAux2);
      sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
      aRetorno[0] := sAux;
      GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
    end;

    If Trim(MapaRes) = 'S' then
    begin
       //*************************************************************************
       // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
       //*************************************************************************
       sRetorno := Space( 20000 );
       aAuxiliar:= NIL;
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD ->');
       iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sRetorno );
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD <- iRet:' + IntToStr(iRet));
       sRetorno := StrTran( sRetorno, ',', '|' );
       MontaArray( sRetorno, aAuxiliar );

       //*************************************************************************
       // Grava o valor do desconto
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[23] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[24] ) / 100;
       aRetorno[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );

       //*************************************************************************
       // Grava o valor do cancelamento
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[27] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[28] ) / 100;
       aRetorno[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[19]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );

       //*************************************************************************
       // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
       //*************************************************************************
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';

       GravaLog(' <- Retorno Mapa Resumo: '+ Result );

    end
    Else
        Result := '0';
  end
  Else
    Result := '1';

end;

//---------------------------------------------------------------------------
function TImpBematech4000.Abrir(sPorta: String; iHdlMain: Integer): String;
begin
sMarca := 'BEMATECH';

If ArqIniBematech( sPorta, sMarca, '1' ) then
begin
  Result := OpenBematech( sPorta, True );
  // Carrega as aliquotas e N. PDV para ganhar performance
  if Copy(Result,1,1) = '0' then
  begin
    AlimentaProperties;
    If lError then
    begin
      Result := '1';
      LjMsgDlg( MsgErroProp );
    end
  end
end
Else LjMsgDlg( 'Problemas com o arquivo ' + sArqIniBema );

end;

//------------------------------------------------------------------------------
function TImpBematech4000.ReducaoZ(MapaRes:String):String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i, iPos : Integer;
  aRetorno,aFile : array of String;
  sRetorno,  sData, sHora ,sLinhaISS,
  sTotalISS,sFile, sLinha, sFlag ,
  sAux, sAux2, sTribIS1, sTribNS1, sTribFS1 : String;
  fFile : TextFile;
  fBase, fAliq, fValor1, fValor2  : Real;
  aAuxiliar : TaString;
begin
If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    GravaLog('Bematech_FI_DataMovimento -> ');
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    GravaLog('Bematech_FI_DataMovimento <- iRet:' + IntToStr(iRet));
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := PDV;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    GravaLog('Bematech_FI_NumeroReducoes -> ');
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    GravaLog('Bematech_FI_NumeroReducoes <- iRet:' + IntToStr(iRet));
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    GravaLog('Bematech_FI_GrandeTotal -> ');
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    GravaLog('Bematech_FI_GrandeTotal <- iRet:' + IntToStr(iRet));
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    GravaLog('Bematech_FI_NumeroCupom <- iRet:' + IntToStr(iRet));
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    GravaLog('Bematech_FI_NumeroCupom <- iRet:' + IntToStr(iRet));
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[ 5] := aRetorno[ 6];
    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);
    aRetorno[15] := FormataTexto('0',16, 0, 1);                         // --outros recebimentos--

    { *********************************************
      ********* TOTALIZADORES DO ECF **************
      ********************************************* }

    sRetorno := Space(889);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD - > ');
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciaisMFD(sRetorno);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD <- iRet:' + IntToStr(iRet));

    sRetorno := StrTran( sRetorno , ',' , '|' );
    MontaArray( sRetorno , aAuxiliar );

    aRetorno[11] := aAuxiliar[1];           //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    aRetorno[12] := aAuxiliar[2];           //**** Nao tributado Nao Tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    aRetorno[10] := aAuxiliar[3];           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    sTribIS1 := Copy(aAuxiliar[4],1,Length(aAuxiliar[4])-2)+'.'+Copy(aAuxiliar[4],Length(aAuxiliar[4])-1,Length( aAuxiliar[4]));//Isenção de ISS
    sTribNS1 := Copy(aAuxiliar[5],1,Length(aAuxiliar[5])-2)+'.'+Copy(aAuxiliar[5],Length(aAuxiliar[5])-1,Length( aAuxiliar[5]));//Não incidencia de ISS
    sTribFS1 := Copy(aAuxiliar[6],1,Length(aAuxiliar[6])-2)+'.'+Copy(aAuxiliar[6],Length(aAuxiliar[6])-1,Length( aAuxiliar[6]));//Substituição de ISS

    //**** Desconto de ICMS ****//
    aRetorno[ 9] := aAuxiliar[7];
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    //aAuxiliar[8]; //Acrescimo sobre ICMS

    //**** Valor do Cancelamento de ICMS ****//
    aRetorno[ 7] := aAuxiliar[9];
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    // desconto de ISS
    aRetorno[18]:= aAuxiliar[10];
    aRetorno[18]:= Copy(aRetorno[18],1,Length(aRetorno[18])-2)+'.'+Copy(aRetorno[18],Length(aRetorno[18])-1,Length(aRetorno[18]));
    aRetorno[18]:= FormataTexto(aRetorno[18], 11, 2, 1 );

    //aAuxiliar[11]; //Acrescimo sobre ISS

    //Cancelamento sobre ISS
    aRetorno[19]:= aAuxiliar[12];
    aRetorno[19]:= Copy(aRetorno[19],1,Length(aRetorno[19])-2)+'.'+Copy(aRetorno[19],Length(aRetorno[19])-1,Length(aRetorno[19]));
    aRetorno[19]:= FormataTexto(aRetorno[19], 11, 2, 1 );

    // QTD DE Aliquotas
    aRetorno[20]:= '00';

    GravaLog('Bematech_FI_LeituraXSerial -> ');
    iRet := fFuncBematech_FI_LeituraXSerial();
    GravaLog('Bematech_FI_LeituraXSerial <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet, True );

    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path' )+'\' +'RETORNO.TXT';
      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '';
        ReadLn(fFile, sLinha);

        While ( Pos(#$A,UpperCase( sLinha) )) > 0 Do
        Begin
            iPos := Pos(#$A,UpperCase( sLinha) );
            SetLength( aFile, Length(aFile) + 1 );
            aFile[ High(aFile) ] := Copy( sLinha,1,iPos -1 );
            sLinha := Copy( sLinha,iPos + 1,Length(sLinha) );
        End;

        CloseFile(fFile);

        For iPos := 0 to Length( aFile )-1 Do
        Begin
          sLinha := aFile[ iPos ];
          sLinha := TrataLinha(sLinha);
          if ( Pos('Contador de Cupom Fiscal:' ,sLinha)>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
          if ( Pos('VENDA LÖQUIDA:',sLinha)>0) or ( Pos('VENDA LÍQUIDA:',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
          if ( Pos('Contador de Reinício de Operação:',sLinha)>0) Or
             ( Pos('Contador de Rein¡cio de Opera‡Æo:',sLinha)>0) Or
             ( Pos('CONTADOR DE REINÍCIO DE OPERAÇÃO:',UpperCase(sLinha))>0) then  // CRO - Contador de Reinício de Operação
            aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
          if ( Pos('Total ',sLinha)>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
          begin
            if sFlag = 'S' // Verifica se é aliquota de ISS e soma o total ao array
            then aRetorno[16] := sTotalISS + ';' + aRetorno[16];

            // desliga a captura das aliquotas
            sFlag:='';
          end;

          if ( sFlag='T' ) and ( Copy(sLinha,3,1)='T' ) and ( Copy(sLinha,2,1)<>'o' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            sLinha := StrTran( sLinha, '*', ' ' );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            aRetorno[High(aRetorno)]:=Copy(sLinha,3,6)+' '+FormataTexto(StrTran(Copy(sLinha,10,20),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,30,20),'.',''),14,2,1,'.');
          End;

          // Totais ISS
          if ( sFlag='S' ) and ( Copy(sLinha,3,1)='S' ) then
          Begin
            // ' Valor '  ' Imposto Debitado
             fBase:= StrToFloat(StrTran(StrTran(copy(sLinha,10,20),'.',''),',','.'));
             fAliq:= StrToFloat(StrTran(StrTran(copy(sLinha,30,20),'.',''),',','.'));
             sTotalISS :=FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,1,14))+ fBase) ,14,2,1)+' '+
                            FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,16,14))+ fAliq) ,14,2,1);
                          //Aliquota                    //Valor Base                                    //Valor Debitado
             sLinhaISS := StrTran(Copy( sLinha , 1 , 8),',','.') + ' ' + FormataTexto(FloatToStr(fBase) ,14,2,1) + ' ' +
                           FormataTexto(FloatToStr(fAliq) ,14,2,1) + ';' ; // ';' separador de aliquotas de ISS
             aRetorno[16] := aRetorno[16] + sLinhaISS ;
          End;

          if (Pos('                      ICMS                      ',sLinha)>0) then
          // Liga a captura das aliquotas de ICMS
            sFlag:='T';
          if (Pos('                     ISSQN                      ',sLinha)>0) then
          begin
            // Liga a captura das aliquotas de ISS
            sFlag:='S';
            sTotalISS := '00000000000.00 00000000000.00';
          end;
        end;

        If Trim(aRetorno[16]) = ''
        then aRetorno[16]:= '00000000000.00 00000000000.00';

         //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
        //   Valor Debitado com 12 casas e 2 decimais + Separador ';'        
        If StrToFloat(sTribIS1) > 0
        then aRetorno[16] := aRetorno[16] + 'IS1' + ' ' +
                                FormataTexto(sTribIS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribNS1) > 0
        then aRetorno[16] := aRetorno[16] + 'NS1' + ' ' +
                                 FormataTexto(sTribNS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribFS1) > 0
        then aRetorno[16] := aRetorno[16] + 'FS1' + ' ' +
                                FormataTexto(sTribFS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

      end
      else
      begin
        GravaLog('Arquivo ' + sFile + ' não encontrado. Portanto informações das alíquotas não serão gravadas');
      end;
    end;
 end;

  Try
    GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
  Except
    GravaLog('Bematech - Redução Z - Erro na execução do comando: GrvTempRedZ()')
  End;

  DateTimeToString( sData, 'ddMMyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  GravaLog('Bematech_FI_ReducaoZ ->');
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  GravaLog('Bematech_FI_ReducaoZ <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );

  If iRet = 1 then
  begin

    If aRetorno[0] = '00/00/00' then
    begin
      GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 00/00/00 ' +
               'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
      sAux := Space(6);
      sAux2:= Space(6);
      GravaLog(' Bematech_FI_DataHoraReducao -> ');
      iRet := fFuncBematech_FI_DataHoraReducao( sAux , sAux2);
      GravaLog(' Bematech_FI_DataHoraReducao <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux + ' , Hora: ' + sAux2);
      sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
      aRetorno[0] := sAux;
      GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
    end;

    If Trim(MapaRes) = 'S' then
    begin
       //*************************************************************************
       // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
       //*************************************************************************
       sRetorno := Space( 20000 );
       aAuxiliar:= NIL;
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> ');
       iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sRetorno );
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD <- iRet: ' + IntToStr(iRet));
       sRetorno := StrTran( sRetorno, ',', '|' );
       MontaArray( sRetorno, aAuxiliar );

       //*************************************************************************
       // Grava o valor do desconto
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[23] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[24] ) / 100;
       aRetorno[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );

       //*************************************************************************
       // Grava o valor do cancelamento
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[27] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[28] ) / 100;
       aRetorno[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[19]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );

       //*************************************************************************
       // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
       //*************************************************************************
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';

      GravaLog(' Retorno Mapa Resumo <- '+ Result );

    end
    Else
        Result := '0';
  end
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpBematech2000.PegaSerie:String;
begin
  Result := '0|' + NumSerie;
end;

//------------------------------------------------------------------------------
function TImpBematech2000.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
    function CapturaIndAliqtICMS(AliqBusca: string): String;
    var i: Integer;
        sRet : String;
    begin
        i := 1;
        sRet := '';
        Repeat
            If Pos(AliqBusca, aIndAliq[i])>0 then
               sRet := aIndAliq[i-1]
            Else
               i := i + 2;
        Until (sRet <> '') or (i > 20);
        Result := sRet;
    end;
var
  iRet : Integer;
  sTrib, sAliquota, sIndiceISS, sAliqISS, sTipoQtd : String;
  iCasas: Integer;
  bIssAlq : Boolean;
begin
  iCasas:=2;
  bIssAlq := False;

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
  End;

  If sTrib = 'T' then
  begin
       sAliquota := FormataTexto(Copy(aliquota,2,5),4,2,1,'.');
       If Pos(sAliquota, ISS)> 0 then
       begin
           sAliquota := CapturaIndAliqtICMS('T'+sAliquota);
       end
       Else
           sAliquota := FormataTexto(StrTran( StrTran( sAliquota, ',', '' ), '.', '' ),4,0,2);
  end;
  If sTrib = 'S' then
  Begin
        sAliquota := '';
        sAliqISS := LeAliquotasISS();
        sAliqISS := Copy(sAliqISS, 3, Length(sAliqISS));
        sIndiceISS := Space(48);
        iRet := fFuncBematech_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoBematech(iRet, True);
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

  //Codigo só pode ser até 49 posicoes.
  Codigo := Trim( Copy(codigo,1,49) );

  descricao := Trim(descricao);
  If Length(descricao) > 200
  then descricao := Copy(descricao,1,200);

  // Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
  sTipoQtd := 'F';

  // Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionária
  Qtde := FormataTexto( qtde, 7, 3, 1 );

  // Numero de cadas decimais para o preço unitário
  If Pos('.',vlrUnit) > 0 then
  begin
    If StrtoFloat(copy(vlrUnit,Pos('.',vlrUnit)+1,Length(vlrUnit))) > 99
    then iCasas := 3
    Else iCasas := 2;
  end;

  // Valor unitário deve ter até 8 digitos
  vlrUnit := FormataTexto( vlrUnit, 9, 3, 2 );

  // Valor desconto deve ter até 8 digitos
  vlrDesconto := FormataTexto( vlrDesconto, 10, 2, 2 );

  //Unidade de Medida deve ter até 2 dígitos
  If Length(UnidMed) > 2 then
  begin
    UnidMed := Copy(UnidMed,1,2);
  End;

  // Retistra o Item
  GravaLog('Bematech_FI_VendeItemDepartamento ->' + Codigo +',' + descricao+',' +
                 sAliquota+',' + vlrUnit+',' + Qtde+',' + '0'+',' + vlrDesconto+',' + '01'+',' + UnidMed);

  qtde := StringReplace(qtde,'.',',',[]);

  iRet := fFuncBematech_FI_VendeItemDepartamento( Codigo, descricao, sAliquota, vlrUnit, Qtde, '0', vlrDesconto, '01', UnidMed);
  GravaLog('Bematech_FI_VendeItemDepartamento <- iRet :' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );
  If iRet = 1
  then Result := '0'
  Else Result := '1';

end;

//----------------------------------------------------------------------------
function TImpBematech2000.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String;
var
  iRet : Integer;
  sDatai,sDataf,cTipo,sPath : String;
begin
  cTipo := '';

  // Pega o tipo gerado s =Simplificado / c =Completo
  Tipo  := LowerCase( Tipo );
  cTipo := Copy( Tipo, 2, 1);

  If Length(Tipo) <= 1 Then
    cTipo := 'c';

  If Pos( 'i', Tipo ) > 0 then
  begin
    // Se o relatório for por Data
    If Trim(ReducInicio) + Trim(ReducFim) = '' then
    begin
      sDatai := FormataData( DataInicio, 1 );
      sDataf := FormataData( DataFim, 1 );
      GravaLog(' Bematech_FI_LeituraMemoriaFiscalDataMFD -> DataIni: ' + sDatai + ',DataFim: ' + sDataf + ', Tipo: ' + Tipo);
      iRet := fFuncBematech_FI_LeituraMemoriaFiscalDataMFD(Pchar(sDatai),Pchar(sDataf),Pchar(cTipo));
      GravaLog(' Bematech_FI_LeituraMemoriaFiscalDataMFD <- iRet: ' + IntToStr(iRet));
    end
    // Se o relatório será por redução Z
    Else
    begin
      GravaLog(' Bematech_FI_LeituraMemoriaFiscalDataMFD -> ReducInicio: ' + ReducInicio + ',ReducFim: ' + ReducFim + ', Tipo: ' + Tipo);
      iRet :=fFuncBematech_FI_LeituraMemoriaFiscalReducaoMFD(Pchar(ReducInicio),Pchar(ReducFim),Pchar(cTipo));
      GravaLog(' Bematech_FI_LeituraMemoriaFiscalReducaoMFD <- iRet: ' + IntToStr(iRet));
    end;

    TrataRetornoBematech( iRet, True );
    If iRet >= 0
    then Result := '0'
    Else Result := '1';
  end
  Else
  begin
      // Se o relatório for por Data
      If Trim(ReducInicio) + Trim(ReducFim) = '' then
      begin
        sDatai := FormataData( DataInicio, 4 );
        sDataf := FormataData( DataFim, 4 );
        GravaLog(' Bematech_FI_LeituraMemoriaFiscalSerialDataMFD -> sDatai: ' + sDatai + ',sDataf: ' + sDataf + ', Tipo: ' + Tipo);
        iRet := fFuncBematech_FI_LeituraMemoriaFiscalSerialDataMFD(Pchar(sDatai),Pchar(sDataf),Pchar(cTipo));
        GravaLog(' Bematech_FI_LeituraMemoriaFiscalSerialDataMFD <- iRet: ' + IntToStr(iRet));
      end
      // Se o relatório será por redução Z
      Else
      begin
        GravaLog(' Bematech_FI_LeituraMemoriaFiscalSerialReducaoMFD -> ReducInicio: ' + ReducInicio + ',ReducFim: ' + ReducFim + ', Tipo: ' + Tipo);
        iRet :=fFuncBematech_FI_LeituraMemoriaFiscalSerialReducaoMFD(Pchar(ReducInicio),Pchar(ReducFim),Pchar(cTipo));
        GravaLog(' Bematech_FI_LeituraMemoriaFiscalSerialReducaoMFD <- iRet: ' + IntToStr(iRet));
      end;

      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        // Pega caminho onde foi gravado o arquivo RETORNO.TXT
        sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

        // Grava o arquivo no local indicado
        If cTipo = 's' Then
          Result := CopRenArquivo( sPath, sArqRetBema, PathArquivo, DEFAULT_ARQMEMSIM )
        Else
          Result := CopRenArquivo( sPath, sArqRetBema, PathArquivo, DEFAULT_ARQMEMCOM );
      end
      Else
        Result := '1';
  end;

end;


//----------------------------------------------------------------------------
function TImpBematech2000.GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string;
                                         cUsuario: string; iTipoGeracao: integer; cChavePublica: string;
                                         cChavePrivada: string; iUnicoArquivo: integer ): String;
var
   iRet : Integer;
   sNomeArq: String;
   sNumSerie2: String;
   sPath: String; //Caminho onde o ECF gera os arquivos
   sTipo: String; //Tipo do DownloadMFD( 1 = Data, 2 = Coo )
Const
   sArquivo = 'DOWNLOAD.MFD';
   sUsuario = '1' ;    // Usuario do movimento
begin
  // Pega caminho onde grava os arquivos da bemafi32.ini(DOWNLOAD.MFD)
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  //Pega número de série para compor o nome do arquivo gerado pelo ECF
  sNumSerie2 := PegaSerie;
  sNumSerie2 := Copy(sNumSerie2,3,Length(sNumSerie2)-2);

  //Formata Nome do arquivo que será gerado pelo ECF: Numero de Série + DadoInicial + _ + DadoFinal + .TXT, quando por data o formato será ddMMyy
  If cTipoDownload = 'D' Then
  Begin
    sTipo     := '1';
    sNomeArq  := sNumSerie2 + '_' + FormatDateTime('ddMMyy', StrToDate(cDadoInicial)) + '_' + FormatDateTime('ddMMyy', StrToDate(cDadoFinal)) + '.TXT';
  End
  Else
  Begin
    //Compativel apenas por Data
    MessageDlg( MsgIndsImp, mtError,[mbOK],0);
    Exit;
  End;

  //Gera arquivo Download.MFD necessário para a function GeraArquivoMFD
  GravaLog(' Bematech_FI_DownloadMFD -> sPath + sArquivo : ' + sPath + sArquivo + ',sTipo: ' + sTipo + ', cDadoInicial: ' + cDadoInicial +
          ', cDadoFinal : ' + cDadoFinal + ', sUsuario : ' + sUsuario);
  iRet := fFuncBematech_FI_DownloadMFD( sPath + sArquivo, sTipo, cDadoInicial, cDadoFinal, sUsuario );
  GravaLog(' Bematech_FI_DownloadMFD <- iRet: ' + IntToStr(iRet));
  TrataRetornoBematech( iRet );

  //Remove barra, comando espera data sem barra
  cDadoInicial := SubstituiStr(cDadoInicial, '/', '');
  cDadoFinal   := SubstituiStr(cDadoFinal, '/', '');

  //Chama função para criação do arquivo Ato Cotepe 1704, conforme esperado no roteiro de testes do PAF-ECF versão 1.4
  If iRet = 1 Then
  Begin
    GravaLog(' BemaGeraRegistrosTipoEMFD1 ');
    iRet := fFuncBemaGeraRegistrosTipoEMFD1( sPath + sArqDownMFD  ,
                                   pchar( sPath + sNomeArq ) ,
                                   cDadoInicial,
                                   cDadoFinal,
                                   '' ,
                                   '' ,
                                   '' ,
                                   '2',
                                   '' , '', '', '', '', '', '', '', '', '', '', '', '' );
   GravaLog(' BemaGeraRegistrosTipoEMFD1 <- iRet: ' + IntToStr(iRet));
  End;

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech2000.DownMF( sTipo, sInicio, sFinal : String ): String;
var
   iRet : Integer;
   sPath: String; //Caminho onde o ECF gera os arquivos
Const
   sArquivo = 'MFISCAL.MF';
   sArquivoTxt = 'MFISCAL.BIN';
   sUsuario = '1' ;    // Usuario do movimento
begin
  // Pega caminho onde grava os arquivos da bemafi32.ini(DOWNLOAD.MFD)
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  //Gera arquivo Download.MFD necessário para a function GeraArquivoMFD
  GravaLog(' Bematech_FI_DownloadMF -> ');
  iRet := fFuncBematech_FI_DownloadMF( sPath + sArquivo);
  GravaLog(' Bematech_FI_DownloadMF <- iRet : ' + IntToStr(iRet));
  TrataRetornoBematech( iRet );

   If iRet = 1 then
   begin
    If not CopyFile( PChar(  sPath + sArquivo ), PChar( PathArquivo  + sArquivoTxt ), False ) then
    begin
      ShowMessage( 'Erro ao copiar o arquivo ' +  sPath + sArquivo + ' para ' + PathArquivo + sArquivoTxt );
      GravaLog( 'Erro ao copiar o arquivo ' +  sPath + sArquivo + ' para ' + PathArquivo + sArquivoTxt );
      Result := '1';
    end
    else
    begin
      GravaLog('-> BemaDownloadMF( ' + sPath + sArquivo +','+ PathArquivo +  sArquivoTxt + ')' );
      Result := '0';
    end
   end
   Else
       Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech2000.TextoNaoFiscal( Texto:String; Vias:Integer ):String;
var
  sTexto,sVerDll, sVerDllT : String;
  i,iRet,nCar,nTamTexto, nPos: Integer;
  sLista : TStringList;
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

 //Pegar a versao da dll
  for i := 1 to 9 do sVerDll := sVerDll + ' ';
  iRet := fFuncBematech_FI_VersaoDll( sVerDll );

  sVerDllT := StringReplace(sVerDll,',','',[rfReplaceAll]);

  // A partir da versao 4.1.2.0 que foi retirado o CR+LF, dessa forma verifica a versao
  //para saber o que fazer
  if StrToInt( sVerDllT ) < 4120 then
  Begin
    nCar := 0;
    nTamTexto := Length( Texto );
    While (nTamTexto >= nCar) and (Texto <> '') do
    begin
      sTexto := Copy( Texto, 1, 420 );
      Texto  := Copy( Texto, 421, Length( Texto ) );
      GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> ' + sTexto );
      iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sTexto );
      GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet : ' + IntToStr(iRet));
      TrataRetornoBematech( iRet, True );

      If iRet <> 1 Then
      Begin
        Result := '1';
        Exit;
      End;

      nCar := nCar + Length( sTexto );
    end
  end
  else
  begin
    sLista := TStringList.Create;
    sLista.Clear;
    sTexto := '';
    nPos   := Pos(#10,Texto);

    While nPos > 0 do
    begin
      nPos    := Pos(#10,Texto);
      sTexto  := sTexto + Copy(Texto,1,nPos) ;
      Texto   := Copy(Texto,nPos+1,Length(Texto));

      If Length(sTexto) >= 450 Then
      Begin
        sLista.Add(sTexto);
        sTexto := '';
      end;
    end;

    If Trim(Texto) <> '' Then sTexto := ' ' + sTexto + Texto + #10;
    If Trim(sTexto) <> '' Then sLista.Add(sTexto);

    GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> ' + sTexto );
    For i:= 0 to sLista.Count-1 do
      iRet := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLista.Strings[i] );
    GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet : ' + IntToStr(iRet));

    TrataRetornoBematech( iRet, True );
    If iRet <> 1
    Then Result := '1';
  End;
end;

//----------------------------------------------------------------------------
function TImpBematech2000.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
var
  iRet, i, nPos  : Integer;
  sTexto    : String;
  homolog   : Boolean;
  IniFile   : TIniFile;
  sLista    : TStringList;
begin
  GravaLog(' -> RelatorioGerencial');

  //**************************************************************//
  // Esta seção será utilizada somente no caso de homologação TEF //
  // [HOMOLOGACAO]                                                //
  // homolog = 1                                                  //
  // trecho comentado pois o cliente possuia a chave de homologacao
  // ligada e causou problema, portanto somente descomentar em
  // caso de teste e/ou homologacao
  //**************************************************************//
 { IniFile := TIniFile.Create(ExpandFileName('sigaloja.ini'));
  IniFile.SectionExists('HOMOLOGACAO');
  homolog := (IniFile.ReadInteger('HOMOLOGACAO','homolog',0) = 1);

  If Not(CompareText(Texto, 'FechaRelatorioGerencial') = 0) then
  Begin

    GravaLog(' -> RelatorioGerencial: NAO E FECHAMENTO');
    Result := '0';

    If homolog = False then
    Begin
      GravaLog(' -> Bematech_FI_FechaComprovanteNaoFiscalVinculado' );
      fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
      GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado <- ');
    End;

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

    sLista := TStringList.Create;
    sLista.Clear;
    nPos := Pos(#10,Texto);
    sTexto := '';

    While nPos > 0 do
    begin
      nPos := Pos(#10,Texto);
      sTexto  := sTexto + Copy(Texto,1,nPos) ;
      Texto   := Copy(Texto,nPos+1,Length(Texto));

      If Length(sTexto) >= 500 Then
      Begin
        sLista.Add(sTexto);
        sTexto := ''
      end;
    End;

   If Trim(Texto) <> '' Then sTexto := ' ' + sTexto + Texto + #10;
   If Trim(sTexto) <> '' Then sLista.Add(sTexto);

   GravaLog(' Bematech_FI_RelatorioGerencial ->');

   For i:= 0 to sLista.Count-1 do
     iRet  := fFuncBematech_FI_RelatorioGerencial( sLista.Strings[i] );

   GravaLog(' Bematech_FI_RelatorioGerencial <- iRet: ' + IntToStr(iRet));

   TrataRetornoBematech( iRet, True );

    if iRet <> 1 then
    begin
      Result := '1';
      Exit;
    end;

    If homolog = False then
    Begin
      GravaLog(' -> Bematech_FI_FechaRelatorioGerencial' );
      iRet:= fFuncBematech_FI_FechaRelatorioGerencial;
      GravaLog(' <- Bematech_FI_FechaRelatorioGerencial <- iRet: ' + IntToStr(iRet));
      TrataRetornoBematech(iRet, True);

      If iRet=1
      then Result := '0'
      Else Result := '1';
    end;
  End
  Else
  Begin
    GravaLog(' -> Bematech_FI_FechaRelatorioGerencial' );
    iRet:= fFuncBematech_FI_FechaRelatorioGerencial;
    GravaLog(' <- Bematech_FI_FechaRelatorioGerencial <- iRet: ' + IntToStr(iRet));

    TrataRetornoBematech(iRet, True);
    If iRet = 1
    then Result := '0'
    Else Result := '1';
  End; }

  Result := '0';
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

  sLista := TStringList.Create;
  sLista.Clear;
  nPos := Pos(#10,Texto);
  sTexto := '';

  While nPos > 0 do
  begin
    nPos := Pos(#10,Texto);
    sTexto  := sTexto + Copy(Texto,1,nPos) ;
    Texto   := Copy(Texto,nPos+1,Length(Texto));

    If Length(sTexto) >= 500 Then
    Begin
      sLista.Add(sTexto);
      sTexto := ''
    end;
  End;

  If Trim(Texto) <> ''
  Then sTexto := ' ' + sTexto + Texto + #10;

  If Trim(sTexto) <> ''
  Then sLista.Add(sTexto);

  GravaLog(' Bematech_FI_RelatorioGerencial ->');

  For i:= 0 to sLista.Count-1 do
    iRet  := fFuncBematech_FI_RelatorioGerencial( sLista.Strings[i] );

  GravaLog(' Bematech_FI_RelatorioGerencial <- iRet: ' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );

  if iRet = 1 then
  begin
    GravaLog(' -> Bematech_FI_FechaRelatorioGerencial' );
    iRet:= fFuncBematech_FI_FechaRelatorioGerencial;
    GravaLog(' <- Bematech_FI_FechaRelatorioGerencial <- iRet: ' + IntToStr(iRet));
    TrataRetornoBematech(iRet, True);
  end
  else
  begin
    GravaLog(' Erro na tentativa da impressão do Relatorio Gerencial ');
  end;

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech2000.DownloadMFD( sTipo, sInicio, sFinal: String ):String;
Var
  sArquivo : String;    // Arquivo de download da MFD
  sUsuario : String;    // Usuario do movimento
  sDestino : String;    // Arquivo de destino depois de convertido
  iRet     : Integer;   // Retorno da dll
  sPath    : String;    // String onde foi gerado o arquivo pela Bematech
Begin
  Result := '1';
  sArquivo := 'DOWNLOAD.MFD';
  sDestino := 'DOWNLOAD.TXT';
  sUsuario := '1';

  // Pega caminho onde grava os arquivos da bemafi32.ini
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );
  GravaLog(' Bematech_FI_DownloadMFD -> '+ sPath + sArquivo + ',' + sTipo +','
    + sInicio + ',' + sFinal + ',' + sUsuario);
  iRet := fFuncBematech_FI_DownloadMFD( sPath + sArquivo, sTipo, sInicio, sFinal, sUsuario );
  TrataRetornoBematech(iRet, True);
  GravaLog(' Bematech_FI_DownloadMFD <- iRet:' + IntToStr(iRet));

  If iRet = 1 then
  begin

    if not DirectoryExists(PathArquivo)
    then ForceDirectories(PathArquivo);

    If (CopyFile(pChar(sPath+sArquivo),pChar(PathArquivo+sArquivo),False))
    then Result := '0'
    else ShowMessage('Erro ao copiar o arquivo [' + sPath+sArquivo + '] para [' + PathArquivo+sArquivo +']');
  end
  else
  begin
    GravaLog(' Erro na execução do comando Bematech_FI_DownloadMFD ');
  end;

  {If iRet = 1 Then
  Begin
    GravaLog(' Bematech_FI_FormatoDadosMFD -> ' + sPath + sArquivo + ',' +  sPath + sDestino + ',0,' + sTipo +','
    + sInicio + ',' + sFinal + ','  + sUsuario);
    iRet := fFuncBematech_FI_FormatoDadosMFD(  sPath + sArquivo,  sPath + sDestino, '0', sTipo, sInicio, sFinal, sUsuario );
    TrataRetornoBematech(iRet, True);
    GravaLog(' Bematech_FI_DownloadMFD <- iRet:' + IntToStr(iRet));

    // Grava arquivo no local indicado
    If iRet = 1
    Then Result := CopRenArquivo( sPath, sDestino, PathArquivo, ArqDownTXT );
  End;}
end;

//----------------------------------------------------------------------------
function TImpBematech2000.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Var
  sRetorno, cLinha,sPath : String;
  iRet : integer;
  sNomeArq,sNomeArqTmp, sNomeArqBin, sArqGerado : String;
  cArqTemp, cArqTempTXT : TextFile;
Begin
  sNomeArq    := ArqDownTXT;
  sNomeArqTmp := 'DOWNLOADTMP.TXT';
  sRetorno    := '1';
  sNomeArqBin := 'DOWNLOAD.BIN';

  sRetorno := DownloadMFD( sTipo, sInicio, sFinal );

  // Pega caminho onde grava os arquivos da bemafi32.ini
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  If sRetorno = '0' then
  begin

    //POR COO
    If sTipo = '2' Then
    begin
      // Abre o arquivo DOWNLOAD.TXT com a imagem dos cupons capturados.
      AssignFile( cArqTemp, PathArquivo + sNomeArq );
      Reset( cArqTemp );

      // Cria o arquivo DOWNLOADTMP.TXT para guardar a imagens dos cupons capturados, retirando as linhas em branco.
      AssignFile( cArqTempTXT, sNomeArqTmp );
      Rewrite( cArqTempTXT );

      cLinha := '';
      while not EOF( cArqTemp ) do
      begin
         Readln( cArqTemp, cLinha );
         if ( cLinha <> '' )
         then Writeln( cArqTempTXT, cLinha );
      end;

      CloseFile( cArqTemp );
      CloseFile( cArqTempTXT );
    end;

    //Geracao de arquivo BIN para o PAF-ECF
    If not (sBinario = '1') then
    begin
        // Tira as barras
        sInicio := SubstituiStr(sInicio, '/', '');
        sFinal  := SubstituiStr(sFinal, '/', '');

        //Padrão PAF-ECF
        sArqGerado :=  UpperCase(PathArquivo + DEFAULT_PATHARQMFD + 'MFD' + NumSerie + '_' +
                                        FormatDateTime('ddMMyyyy', Date) + '_' + FormatDateTime('hhmmss', Time)+'.txt');

        GravaLog('-> BemaGeraRegistrosTipoE( ' + sPath + sArqDownMFD +','+ sArqGerado +','+
                                                 sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ '2' + ')' );

        iRet := fFuncBemaGeraRegistrosTipoEMFD1( sPath + sArqDownMFD  ,
                                     sArqGerado   ,
                                     sInicio,
                                     sFinal ,
                                     sRazao ,
                                     sEnd   ,
                                     '' ,
                                     '2',
                                     '' , '', '', '', '', '', '', '', '', '', '', '', '' );

        If iRet <> 0
        then sRetorno := '1';

    end
    else
       If not CopyFile( PChar(  sPath + sArqDownMFD ), PChar( PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin ), False ) then
       begin
         GravaLog( 'GeraRegTipoE ->' + 'Erro ao copiar o arquivo ' +  sPath + sArqDownMFD + ' para ' + PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin );
         ShowMessage( 'Erro ao copiar o arquivo ' +  sPath + sArqDownMFD + ' para ' + PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin );
         sRetorno := '1';
       end
       else GravaLog('-> BemaGeraRegistrosTipoE - formato binario( ' + sPath + sArqDownMFD +','+ PathArquivo +
                          DEFAULT_PATHARQMFD + sNomeArqBin +','+ sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ sBinario + ')' );
    end;

  Result := sRetorno;

end;

//----------------------------------------------------------------------------
function TImpBematech2000.RedZDado(MapaRes:String):String;
Var
  aRetTemp: TaString;
  i,iRet: Integer;
  sAux,sRetorno: String;
  fValor1, fValor2 : Real;
  aAuxiliar : TaString;
begin
  Result := '0|';

  //*************************************************************************
  // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
  //*************************************************************************
  sRetorno := Space( 20000 );
  GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> ');
  iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sRetorno );
  GravaLog(' Bematech_FI_DadosUltimaReducaoMFD <- iRet:' + IntToStr(iRet) + ' - Ret:' + sRetorno);

  If Length(sRetorno) > 0 Then
  Begin
    sRetorno := StrTran( sRetorno, ',', '|' );
    MontaArray( sRetorno, aAuxiliar );
  End;

  If iRet = 1 then
  Begin
    //Captura dados armazenados em arquivo antes do comando para emissão da ReducaoZ
    sAux := aAuxiliar[1] ; //data do movimento da ultima Z
    sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
    aRetTemp := GetTempRedZ(sAux);
  End;

  If Length(aRetTemp) >= 18 Then
  Begin

    //*************************************************************************
    // Grava o valor do desconto
    //*************************************************************************
    fValor1 := StrToFloat( aAuxiliar[23] ) / 100;
    fValor2 := StrToFloat( aAuxiliar[24] ) / 100;
    aRetTemp[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
    aRetTemp[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // desconto de ISS

    //*************************************************************************
    // Grava o valor de cancelamento
    //*************************************************************************
    fValor1 := StrToFloat( aAuxiliar[27] ) / 100;
    fValor2 := StrToFloat( aAuxiliar[28] ) / 100;
    aRetTemp[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
    aRetTemp[19]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // cancelamento de ISS

    //*************************************************************************
    // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
    //*************************************************************************
    For i:= 0 to Length(aRetTemp)-1 do
    begin
      Result := Result + aRetTemp[i]+'|';
    End;

    GravaLog('Bematech Mapa Resumo(Recuperado) <- Retorno : '+ Result);
  End Else  GravaLog('Bematech Mapa Resumo(Recuperado) <- Retorno : Nao possui dados da ultima reducao');

End;



//----------------------------------------------------------------------------
function TImpBematech2000.LeTotNFisc:String;

 //Inicio função Estática RetornaIndiceTot
 function RetornaIndiceTot(sRelGerenciais : String ; PosTotalizador : Integer) : String;
   var
     sRet,sAux : String;
     nCont,nQtdeVirg,nPosVirg: Integer;
   begin
     sRet      := '01';
     nCont     := 0 ;
     nQtdeVirg := 0;
     sAux      := sRelGerenciais ;
     while nCont < PosTotalizador do
     begin
       nPosVirg := Pos(',',sAux);
       StringReplace(sAux,',','|',[]);
       If nPosVirg > 0 then
       begin
        Inc(nQtdeVirg);
        nCont := nCont + nPosVirg;
       end;
     end;

     If nQtdeVirg > 0
     then sRet := FormataTexto(IntToStr(nQtdeVirg),2,0,1);

     Result := sRet;
   end;
   //final Função Estática Retona Indice Tot


var
  iRet, iPos, iCont : Integer;
  sRet, sAux, sTotaliz : String;
begin
  sRet := Space(599);
  GravaLog(' Bematech_FI_VerificaTotalizadoresNaoFiscaisMFD ->');
  iRet := fFuncBematech_FI_VerificaTotalizadoresNaoFiscaisMFD( sRet );
  GravaLog(' Bematech_FI_VerificaTotalizadoresNaoFiscaisMFD <- iRet:' + IntToStr(iRet));

  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    sTotaliz := '';
    iPos := Pos(',', sRet);
    sAux := sRet;
    iCont := 0;
    If iPos = 0 then iPos := Length(sRet);

    while iPos > 0 do
     begin
       sAux := Trim(Copy(sRet, 1, iPos-1));
       sRet := Copy(sRet, iPos+1, length(sRet)-iPos) ;
       iPos := Pos(',', sRet);
       If iPos = 0 then iPos := Length(sRet);
       Inc(iCont);
       sTotaliz := sTotaliz + FormataTexto( IntToStr(iCont), 2, 0, 4) + ',' + sAux + '|';
     end;

    Result := '0|' + sTotaliz;
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematech2000.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpBematech2000.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
var
  iRet : Integer;
begin

GravaLog(' -> Bematech_FI_EstornoNaoFiscalVinculadoMFD - Dados :(' + CPFCNPJ + ' ' + Cliente + ' ' + Endereco + ')');
iRet := fFuncBematech_FI_EstornoNaoFiscalVinculadoMFD(pChar(CPFCNPJ),pChar(Cliente),pChar(Endereco));
GravaLog(' <- Bematech_FI_EstornoNaoFiscalVinculadoMFD - Retorno :' + IntToStr(iRet));

TrataRetornoBematech( iRet );
If (iRet <> 1) then
Begin
  Result := '1';
  Exit;
End;

GravaLog(' -> Bematech_FI_UsaComprovanteNaoFiscalVinculado - Dados :(' + Mensagem + ')');
iRet := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado(pChar(Mensagem));
GravaLog(' <- Bematech_FI_UsaComprovanteNaoFiscalVinculado - Retorno :' + IntToStr(iRet));

TrataRetornoBematech( iRet );
If iRet <> 1 Then
Begin
  Result := '1';
  Exit;
End;

GravaLog(' -> Bematech_FI_FechaComprovanteNaoFiscalVinculado ');
iRet := fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado();
GravaLog(' <- Bematech_FI_FechaComprovanteNaoFiscalVinculado - Retorno :' + IntToStr(iRet));

TrataRetornoBematech( iRet );

If iRet = 1
then Result := '0'
Else Result := '1';

end;


//----------------------------------------------------------------------------
function TImpBematech2000_0302.AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String;
var
  iRet : Integer;
  sForma : String;
begin
  iRet := 0;
  
  // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if Pos('.', Valor) = 0 then
  begin
    Valor    := Trim(Valor);
    Valor    := Copy(Valor,1,length(Valor)-2)+'.'+Copy(Valor,length(Valor)-1,2);
  end;

  Valor    := Trim(FormataTexto( Valor, 14, 2, 3 ));
  Valor    := StrTran(Valor,'.',',');

  //  A forma de pagamento utilizada no comprovante vinculado não pode ser "Dinheiro",
  // mas pode ser "DINHEIRO".
  Condicao := Copy( Condicao, 1, 16 );

  GravaLog(' AbreCupomNaoFiscal -> Condicao :' + Condicao + ' , Valor :' + Valor
         + ', Totalizador :' + Totalizador + ', Texto:' + Texto);

  sForma := Condicao;
  //*******************************************************************************
  // Abre o comprovante não fiscal. Tenta abrir um vinculado mas caso não consiga
  // faz um recebimento não fiscal para depois abrir o comprovante não fiscal
  // Condicao = Descricao da Forma de pagamento - Nao pode ser DINHEIRO
  //*******************************************************************************
  Status_Impressora( False, True );
  GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado -> ');
  iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( sForma , '', '' );
  GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
  If iRet <> 0 then
  Begin
      If Status_Impressora( False, True ) = 1
      then Result := '0'
      Else
      begin
         //*******************************************************************************
         // Faz um recebimento não fiscal para abrir o cupom vinculado
         //*******************************************************************************
         GravaLog(' Bematech_FI_RecebimentoNaoFiscal ->');
         iRet := fFuncBematech_FI_RecebimentoNaoFiscal( pchar(Totalizador), pchar(Valor), pchar(sForma) );
         GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet :' + IntToStr(iRet));
         If Status_Impressora( False, True ) = 1 then
         begin
            //*******************************************************************************
            // Abre o comprovante vinculado
            //*******************************************************************************
            GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado -> ');
            iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( sForma, '', '' );
            GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
            TrataRetornoBematech( iRet );
            If Status_Impressora( False, True ) = 1 then
            begin
              If iRet = 1
              then Result := '0'
              Else Result := '1';
            end;
         end
         Else
            Result := '1';
      end;
  End
  Else
    Result := '1';

  // Se apresentou algum erro monstra a mensagem
  If Result = '1'
  then TrataRetornoBematech( iRet );
end;

//------------------------------------------------------------------------------
function TImpBematech2100.GeraArquivoMFD(cDadoInicial, cDadoFinal,
  cTipoDownload, cUsuario: string; iTipoGeracao: integer; cChavePublica,
  cChavePrivada: string; iUnicoArquivo: integer): String;
var
   iRet : Integer;
   sNomeArq: String;
   sNumSerie2: String;
   sPath: String; //Caminho onde o ECF gera os arquivos
   sTipo: String; //Tipo do DownloadMFD( 1 = Data, 2 = Coo )
Const
   sArquivo = 'DOWNLOAD.MFD';
   sUsuario = '1' ;    // Usuario do movimento
begin
  // Pega caminho onde grava os arquivos da bemafi32.ini(DOWNLOAD.MFD)
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  //Pega número de série para compor o nome do arquivo gerado pelo ECF
  sNumSerie2 := PegaSerie;
  sNumSerie2 := Copy(sNumSerie2,3,Length(sNumSerie2)-2);

  //Formata Nome do arquivo que será gerado pelo ECF: Numero de Série + DadoInicial + _ + DadoFinal + .TXT, quando por data o formato será ddMMyy
  If cTipoDownload = 'D' Then
  Begin
    sTipo     := '1';
    sNomeArq  := sNumSerie2 + '_' + FormatDateTime('ddMMyy', StrToDate(cDadoInicial)) + '_' + FormatDateTime('ddMMyy', StrToDate(cDadoFinal)) + '.TXT';
  End
  Else
  Begin
    //Compativel apenas por Data
    MessageDlg( MsgIndsImp, mtError,[mbOK],0);
    Exit;
  End;

  //Gera arquivo Download.MFD necessário para a function GeraArquivoMFD
  GravaLog(' Bematech_FI_DownloadMFD -> Arquivo: ' + sPath + sArquivo + ', Tipo: ' + sTipo + ', DadoIni: ' + cDadoInicial + ', DadoFim:' + cDadoFinal +', Usuario: 1');
  iRet := fFuncBematech_FI_DownloadMFD( sPath + sArquivo, sTipo, cDadoInicial, cDadoFinal, sUsuario );
  GravaLog(' Bematech_FI_DownloadMFD <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet );

  //Remove barra, comando espera data sem barra
  cDadoInicial := SubstituiStr(cDadoInicial, '/', '');
  cDadoFinal   := SubstituiStr(cDadoFinal, '/', '');

  //Chama função para criação do arquivo Ato Cotepe 1704, conforme esperado no roteiro de testes do PAF-ECF
  If iRet = 1 Then
  Begin
    GravaLog(' BemaGeraRegistrosTipoEMFD2 -> Arquivo:' + sPath + sArqDownMFD +
                ' ArqTXT: ' + sPath + sNomeArq + ',DadoIni :' + cDadoInicial + ', DadoFim: '+ cDadoFinal +
                ', CMD: 2');
    iRet := fFuncBemaGeraRegistrosTipoEMFD2( sPath + sArqDownMFD  ,
                                 pchar( sPath + sNomeArq ) ,
                                 cDadoInicial,
                                 cDadoFinal,
                                 '' ,
                                 '' ,
                                 '' ,
                                 '2',
                                 '' , '', '', '', '', '', '', '', '', '', '', '', '' );
    GravaLog(' BemaGeraRegistrosTipoEMFD2 <- iRet: ' + IntToStr(iRet));
  End;

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpBematech2100.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Var
  sRetorno, cLinha , sPath : String;
  iRet : integer;
  sNomeArq , sNomeArqTmp, sNomeArqBin , sArqGerado: String;
  cArqTemp , cArqTempTXT : TextFile;
  Texto       : TStringList;
  dVarAux     : TDateTime;
Begin
  sNomeArq      := ArqDownTXT;
  sNomeArqTmp   := 'DOWNLOADTMP.TXT';
  sNomeArqBin   := 'DOWNLOAD.BIN';
  sRetorno      := '1';

  sRetorno := DownloadMFD( sTipo, sInicio, sFinal );

  //Pega caminho onde grava os arquivos da bemafi32.ini
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  GravaLog('-> BemaGeraRegistrosTipoE ( ' + sTipo +','+ sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ sBinario + ')' );
  If sRetorno = '0' then
  begin

    //POR COO
    If sTipo = '2' Then
    begin
     // Abre o arquivo DOWNLOAD.TXT com a imagem dos cupons capturados.
     AssignFile( cArqTemp, PathArquivo + sNomeArq );
     Reset( cArqTemp );

     // Cria o arquivo DOWNLOADTMP.TXT para guardar a imagens dos cupons capturados, retirando as linhas em branco.
     AssignFile( cArqTempTXT, sNomeArqTmp );
     Rewrite( cArqTempTXT );

     cLinha := '';
     while not EOF( cArqTemp ) do
     begin
       Readln( cArqTemp, cLinha );
       if ( cLinha <> '' )
       then Writeln( cArqTempTXT, cLinha );
     end;

     CloseFile( cArqTemp );
     CloseFile( cArqTempTXT );

     // Cria um objeto do tipo TStringList.
     Texto := TStringList.Create;
     Texto.LoadFromFile( sNomeArqTmp );

     // Copia as informações de data inicial e final, dentro do objeto Texto.
     sInicio := copy( Texto.Strings[ 7 ], 1, 10 );

     Try
       dVarAux := StrToDateTime(sInicio);
     Except
       Try
         sInicio := copy( Texto.Strings[ 6 ], 1, 10 );
         dVarAux := StrToDateTime(sInicio);
       Except
       End;
     End;

     sFinal  := copy( Texto.Strings[ Texto.Count - 2 ], 20, 10 );
    end;

    If sBinario <> '1' then
    begin
      // Tira as barras
      sInicio := SubstituiStr(sInicio, '/', '');
      sFinal  := SubstituiStr(sFinal, '/', '');

      sArqGerado :=  UpperCase(PathArquivo + DEFAULT_PATHARQMFD + 'MFD' + NumSerie + '_' +
                                FormatDateTime('ddMMyyyy', Date) + '_' + FormatDateTime('hhmmss', Time)+'.txt');

      GravaLog(' BemaGeraRegistrosTipoEMFD2 -> ' +  sPath + sArqDownMFD +','+ sArqGerado +','+ sInicio +','+ sFinal +
                                                ','+ sRazao +','+ sEnd +',' +','+ '2' + ')' );

      iRet := fFuncBemaGeraRegistrosTipoEMFD2( sPath + sArqDownMFD ,
                                               sArqGerado  ,
                                               sInicio,
                                               sFinal ,
                                               sRazao ,
                                               sEnd   ,
                                               '' ,
                                               '2',
                                               '' , '', '', '', '', '', '', '', '', '', '', '', '' );
     GravaLog(' BemaGeraRegistrosTipoEMFD2 <- iRet:' + IntToStr(iRet));

      If iRet <> 0
      then sRetorno := '1';
    end
    else
    begin
      If not CopyFile( PChar(  sPath + sArqDownMFD ), PChar( PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin ), False ) then
      begin
        GravaLog('Erro ao copiar o arquivo ' +  sPath + sArqDownMFD + ' para ' + PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin);
        ShowMessage( 'Erro ao copiar o arquivo ' +  sPath + sArqDownMFD + ' para ' + PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin );
        sRetorno := '1';
      end
      else
        GravaLog(' BemaGeraRegistrosTipoE <- formato binario( ' + sPath + sArqDownMFD +','+ PathArquivo +
                        DEFAULT_PATHARQMFD + sNomeArqBin +','+ sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ sBinario + ')' );
    end;
  end;
  Result := sRetorno;
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FI.PegaSerie:String;
begin
  Result := '0|' + NumSerie;
end;

//------------------------------------------------------------------------------
function TImpBematechMP25FI.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
var
  iRet, i, nTamTexto, nCar : Integer;
  sTexto  : String;
begin
  Result := '0';
  // Fecha o cupom não fiscal
  fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
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
    nCar := 0;
    nTamTexto := Length( Texto );
    While (nTamTexto >= nCar) and (Texto <> '') do
    begin
      sTexto := Copy( Texto, 1, 600 );
      Texto  := Copy( Texto, 601, Length( Texto ) );
      iRet   := fFuncBematech_FI_RelatorioGerencial( sTexto );
      TrataRetornoBematech( iRet );
      nCar := nCar + Length( sTexto );
    end;
    // Ocorreu erro na impressão do cupom
    if iRet = 0 then
    Begin
      Result := '1';
      Exit;
    End;
  End;

  GravaLog(' Bematech FechaRelatorioGerencial ->');
  iRet:= fFuncBematech_FI_FechaRelatorioGerencial;
  GravaLog(' <- FechaRelatorioGerencial - iRet : ' + IntToStr(iRet));
  TrataRetornoBematech(iRet);

  If iRet = 1
  then Result:='0'
  Else Result := '1';

end;


//------------------------------------------------------------------------------
function TImpBematechMP25FI.Abrir(sPorta : String; iHdlMain:Integer) : String;
begin
  sMarca := 'BEMATECH';

  // Verifica o arquivo de configuracao da Bematech.
  If ArqIniBematech( sPorta, sMarca, '1' ) then
  begin
    Result := OpenBematech( sPorta, True );
    // Carrega as aliquotas e N. PDV para ganhar performance
    if Copy(Result,1,1) = '0' then
    begin
      AlimentaProperties;
      If lError then
      begin
        Result := '1';
        LjMsgDlg( MsgErroProp );
      end
    end
  end
  Else
    LjMsgDlg( 'Problemas com o arquivo ' + sArqIniBema );

end;

//----------------------------------------------------------------------------
function TImpBematechMP25FI.TextoNaoFiscal( Texto:String; Vias:Integer ):String;
var
  i: Integer;
  sTexto  : String;
  iRet    : Integer;
  sLinha  :String;
  sVerDll : String;
  iConta : integer;
  sVerDllT : String;

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

 //verifica a versao da dll
  for iConta := 1 to 9 do sVerDll := sVerDll + ' ';
  iRet := fFuncBematech_FI_VersaoDll( sVerDll );

  sVerDllT := StringReplace(sVerDll,',','',[rfReplaceAll]);

  //A partir da versao 4.1.2.0 que foi retirado o CR+L, por isso existe a verificacao de versao
  if StrToInt( sVerDllT ) < 4120
  then
  Begin

  // Laço para imprimir toda a mensagem
    While ( Trim(Texto)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 40 caracter do Texto
         If Pos(#10,Copy(Texto,1,41))>1 then
         begin
            sLinha := Copy(Texto,1, Pos(#10,Texto)-1);
            Texto  := Copy(Texto,Pos(#10,Texto)+1, Length(Texto));
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
            TrataRetornoBematech( iRet );
         End
         Else If Pos(#10,Copy(Texto,1,41))=1 then
         Begin
            //manda os avanços de linha
            Texto := Copy(Texto,2,Length(Texto));
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( #13 );
         End
         Else
         Begin
            sLinha := Copy(Texto,1, 40);
            Texto  := Copy(Texto,41, Length(Texto));
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
            TrataRetornoBematech( iRet );
         End;

         // Ocorreu erro na impressão do cupom
         if iRet<>1 then
         Begin
            Result := '1';
            Break;
         End;
      End;
  end

  else
  begin
     While ( Trim(Texto)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 40 caracter do Texto
         If Pos(#10,Copy(Texto,1,41))>1 then
         begin
            sLinha := Copy(Texto,1, Pos(#10,Texto)-1) + #10 + #13;
            Texto  := Copy(Texto,Pos(#10,Texto)+1, Length(Texto));
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
            TrataRetornoBematech( iRet );
         End
         Else If Pos(#10,Copy(Texto,1,41))=1 then
         Begin
            Texto := Copy(Texto,2,Length(Texto));
            iRet  := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( #10 + #13 );
         End
         Else
         Begin
            sLinha := Copy(Texto,1, 40) + #10 + #13;
            Texto  := Copy(Texto,41, Length(Texto));
            iRet   := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLinha  );
            TrataRetornoBematech( iRet );
         End;

         // Ocorreu erro na impressão do cupom
         if iRet<>1 then
         Begin
            Result := '1';
            Break;
         End;
      End;
  end;
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FI.ReducaoZ(MapaRes:String):String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i, iPos : Integer;
  sData, sHora, sRetorno, sLinhaISS,
  sTotalISS,sFile, sLinha, sFlag : String;
  aRetorno,aFile : array of String;
  fFile : TextFile;
  fBase, fAliq,fValor1, fValor2 : Real;
  aAuxiliar : TaString;
begin
If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := Pdv;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0' then
      aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[ 5] := aRetorno[ 6];

    aRetorno[ 7] := Space (14);                         //**** Valor do Cancelamento ****//
    iRet := fFuncBematech_FI_Cancelamentos( aRetorno[ 7] );
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    aRetorno[ 9] := Space (14);                         //**** Desconto ****//
    iRet := fFuncBematech_FI_Descontos( aRetorno[ 9] );
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    sRetorno := Space(445);
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciais(sRetorno);

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

    aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS
    aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS
    aRetorno[20]:= '00';                                         // QTD DE Aliquotas

    iRet := fFuncBematech_FI_LeituraXSerial();
    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path' )+'\' +'RETORNO.TXT';
      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '';
        ReadLn(fFile, sLinha);

        While ( Pos(#$A,UpperCase( sLinha) )) > 0 Do
            Begin
                iPos := Pos(#$A,UpperCase( sLinha) );
                SetLength( aFile, Length(aFile) + 1 );
                aFile[ High(aFile) ] := Copy( sLinha,1,iPos -1 );
                sLinha := Copy( sLinha,iPos + 1,Length(sLinha) );
            End;

        CloseFile(fFile);

        For iPos := 0 to Length( aFile )-1 Do
        Begin
          sLinha := aFile[ iPos ];
          sLinha := TrataLinha(sLinha);
          if ( Pos('Contador de Cupom Fiscal:' ,sLinha)>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
          if ( Pos('VENDA LÖQUIDA:',sLinha)>0) or ( Pos('VENDA LÍQUIDA:',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
          if ( Pos('Contador de Rein¡cio de Opera‡Æo:',sLinha)>0) or ( Pos('CONTADOR DE REINÍCIO DE OPERAÇÃO:',UpperCase(sLinha))>0) then  // CRO - Contador de Reinício de Operação
            aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
          if ( Pos('Total ',sLinha)>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
          begin
            if sFlag = 'S' // Verifica se é aliquota de ISS e soma o total ao array
            then aRetorno[16] := sTotalISS + ';' + aRetorno[16];

            // desliga a captura das aliquotas
            sFlag:='';
          end;

          if ( sFlag='T' ) and ( Copy(sLinha,1,1)='T' ) and ( Copy(sLinha,2,1)<>'o' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            sLinha := StrTran( sLinha, '*', ' ' );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            sLinha := StrTran( sLinha, '*', ' ' );
            aRetorno[High(aRetorno)]:=Copy(sLinha,1,6)+' '+FormataTexto(StrTran(Copy(sLinha,8,21),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,30,19),'.',''),14,2,1,'.')
          End;

          // Totais ISS
          if ( sFlag='S' ) and ( Copy(sLinha,1,1)='S' ) then
          Begin
            // ' Valor '  ' Imposto Debitado
             fBase:= StrToFloat(StrTran(StrTran(copy(sLinha,12,24),'.',''),',','.'));
             fAliq:= StrToFloat(StrTran(StrTran(copy(sLinha,32,20),'.',''),',','.'));
             sTotalISS :=FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,1,14))+ fBase) ,14,2,1)+' '+
                            FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,16,14))+ fAliq) ,14,2,1);
                          //Aliquota                    //Valor Base                                    //Valor Debitado
             sLinhaISS := StrTran(Copy( sLinha , 1 , 6),',','.') + ' ' + FormataTexto(FloatToStr(fBase) ,14,2,1) + ' ' +
                           FormataTexto(FloatToStr(fAliq) ,14,2,1) + ';' ; // ';' separador de aliquotas de ISS
             aRetorno[16] := aRetorno[16] + sLinhaISS ;
          End;

          if (Pos('----------ICMS----------',sLinha)>0) then
          // Liga a captura das aliquotas de ICMS
            sFlag:='T';
          if (Pos('---------ISSQN----------',sLinha)>0) then
          begin
            // Liga a captura das aliquotas de ISS
            sFlag:='S';
            sTotalISS := '00000000000.00 00000000000.00';            
          end;
        end;

        If Trim(aRetorno[16]) = ''
        then aRetorno[16]:= '00000000000.00 00000000000.00';

      end
    end;
 end;

  DateTimeToString( sData, 'ddmmyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    ReducaoEmitida := True;

    If Trim(MapaRes) = 'S' then
    begin
       //*************************************************************************
       // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
       //**************************** *********************************************
       sRetorno := Space( 20000 );
       aAuxiliar:= NIL;
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> ');
       iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sRetorno );
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD <- iRet :' + IntToStr(iRet) + ' - sRetorno :' + sRetorno);
       sRetorno := StrTran( sRetorno, ',', '|' );
       MontaArray( sRetorno, aAuxiliar );

       //*************************************************************************
       // Grava o valor do desconto
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[23] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[24] ) / 100;
       aRetorno[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // desconto de ISS

       //*************************************************************************
       // Grava o valor do cancelamento
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[27] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[28] ) / 100;
       aRetorno[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[19]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // cancelamento de ISS

       //*************************************************************************
       // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
       //*************************************************************************
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';

    end
    Else
        Result := '0';
  end
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpBematechMP25FI.FechaCupom( Mensagem:String ):String;
var
  iRet, i: Integer;
  sTexto : String;
  sLinha : String;
begin
   // Laço para imprimir toda a mensagem
  While ( Trim(Mensagem)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 48 caracter do Texto
         For i:= 1 to 48 do
         Begin
             // Caso encontre um CHR(10) (Line Feed) imprime a linha
             If Copy(Mensagem,i,1) = #10 then
                Break;
             sLinha := sLinha + Copy(Mensagem,i,1);
         end;
         sLinha := Copy(sLinha+space(48),1,48);
         sTexto := sTexto + sLinha;
         Mensagem  := Copy(Mensagem,i+2,Length(Mensagem));
  End;

    iRet := fFuncBematech_FI_TerminaFechamentoCupom(sTexto);
    TrataRetornoBematech( iRet );
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
function TImpBematechMP25FI.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
    function CapturaIndAliqtICMS(AliqBusca: string): String;
    var i: Integer;
        sRet : String;
    begin
        i := 1;
        sRet := '';
        Repeat
            If Pos(AliqBusca, aIndAliq[i])>0 then
               sRet := aIndAliq[i-1]
            Else
               i := i + 2;
        Until (sRet <> '') or (i > 20);
        Result := sRet;
    end;
var
  iRet : Integer;
  sTrib : String;
  sAliquota : String;
  sIndiceISS, sAliqISS: String;
  sTipoQtd : String;
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
  begin
       sAliquota := FormataTexto(Copy(aliquota,2,5),4,2,1,'.');
       If Pos(sAliquota, ISS)> 0 then
       begin
           sAliquota := CapturaIndAliqtICMS('T'+sAliquota);
       end
       Else
           sAliquota := FormataTexto(StrTran( StrTran( sAliquota, ',', '' ), '.', '' ),4,0,2);
  end;
  If sTrib = 'S' then
  Begin
        sAliquota := '';
        sAliqISS := LeAliquotasISS();
        sAliqISS := Copy(sAliqISS, 3, Length(sAliqISS));
        sIndiceISS := Space(48);
        iRet := fFuncBematech_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoBematech(iRet);
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
          fFuncBematech_FI_AumentaDescricaoItem(Descricao);
          // Coloca o tamanho da descrição para 29 posições devido a uma obrigatoriedade da função Bematech_FI_VendeItem
          Descricao:=Copy(Descricao, 1, 29);
  End;

  // Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
  sTipoQtd := 'F';

  // Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionária
  Qtde := FormataTexto( qtde, 7, 3, 2 );

  // Numero de casas decimais para o preço unitário
  If Pos('.',vlrUnit) > 0 then
    If StrtoFloat(copy(vlrUnit,Pos('.',vlrUnit)+1,Length(vlrUnit))) > 99 then
      iCasas := 3
    Else
      iCasas := 2;

  // Valor unitário deve ter até 8 digitos
  vlrUnit := FormataTexto( vlrUnit, 8, 3, 2 );

  // Valor desconto deve ter até 8 digitos
  vlrDesconto := FormataTexto( vlrDesconto, 8, 2, 2 );

  //Unidade de Medida deve ter até 2 dígitos
  If Length(UnidMed) > 2 then
  begin
    UnidMed := Copy(UnidMed,1,2);
  end;

  // Retistra o Item
  iRet := fFuncBematech_FI_VendeItemDepartamento( Codigo, descricao, sAliquota, vlrUnit, Qtde, '0', vlrDesconto,'01',UnidMed);
  TrataRetornoBematech( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.AbreCupomRest(Mesa, Cliente: String):String;
var iRet: integer;
    iVezes : integer;
    lContinua : boolean;
begin
  iVezes := 1;
  lContinua := True;
  Result := '1';

  While (iVezes < 10) AND (lContinua) do
  begin
    try
      iRet := fFuncBematech_FIR_AbreCupomRestaurante(Mesa,Cliente);
      TrataRetornoBematech( iRet );
      If iRet = 1 then
      begin
          iRet := Status_Impressora( True );
          if iRet = 1 then Result := '0'
          else Result := '1';
      end
      Else
          Result := '1';
      lContinua := False;
    except
      Inc( iVezes );
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.RegistraItemRest( Mesa, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: String): String;
var iRet: integer;
    sTrib, sAliquota: string;
    sAliqISS, sIndiceISS: string;
begin
  Mesa := Trim(FormataTexto(Mesa,4,0,2));
  Codigo := Trim(Codigo);
  If Length(Codigo) > 14 Then
      Codigo := Copy(Codigo,1,14);
  Descricao := Copy(Descricao+Space(17), 1,17 );
  Qtde := Trim(FormataTexto(Qtde,6,3,4));
  VlrUnit := Trim(FormataTexto(VlrUnit,8,2,4));

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
        iRet := fFuncBematech_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoBematech(iRet);
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

  if StrToInt(Acres)>0 then
      iRet := fFuncBematech_FIR_RegistraVenda( Mesa, Codigo, Descricao, sAliquota, Qtde, VlrUnit,'A',Acres)
  else if StrToInt(Desc)>0 then
      iRet := fFuncBematech_FIR_RegistraVenda( Mesa, Codigo, Descricao, sAliquota, Qtde, VlrUnit,'D',Desc)
  else
      iRet := fFuncBematech_FIR_RegistraVenda( Mesa, Codigo, Descricao, sAliquota, Qtde, VlrUnit,'D','0');

  TrataRetornoBematech( iRet );
  if iRet = 1 then
  begin
      iRet := Status_Impressora( True );
      if iRet = 1 then Result := '0'
      else Result := '1';
  end
  else
      Result := '1';

end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.CancelaItemRest( Mesa,Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: String): String;
var sTrib, sAliquota: String;
    iRet: Integer;
begin
  Mesa := Trim(FormataTexto(Mesa,4,0,4));
  If Length(Codigo) > 14 then
      Codigo := Copy(Codigo,1,14);
  Descricao := Copy(Descricao+Space(17), 1,17 );
  Qtde := Trim(FormataTexto(Qtde,6,3,4));
  VlrUnit := Trim(FormataTexto(VlrUnit,8,2,4));

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

  if StrToInt(Acres)>0 then
      iRet := fFuncBematech_FIR_CancelaVenda( Mesa, Codigo, Descricao, sAliquota, Qtde, VlrUnit,'A',Acres)
  else if StrToInt(Desc)>0 then
      iRet := fFuncBematech_FIR_CancelaVenda( Mesa, Codigo, Descricao, sAliquota, Qtde, VlrUnit,'D',Desc)
  else
      iRet := fFuncBematech_FIR_CancelaVenda( Mesa, Codigo, Descricao, sAliquota, Qtde, VlrUnit,'D','0');

  TrataRetornoBematech( iRet );
  if iRet = 1 then
  begin
      iRet := Status_Impressora( True );
      if iRet = 1 then Result := '0'
      else Result := '1';
  end
  else
      Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.ConferenciaMesa( Mesa, Acres, Desc: String):String;
var iRet: integer;
begin
  iRet := fFuncBematech_FIR_AbreConferenciaMesa(Mesa);
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
      if StrToInt(Acres)>0 then
          iRet := fFuncBematech_FIR_FechaConferenciaMesa( 'A','%',Acres)
      else if StrToInt(Desc)>0 then
          iRet := fFuncBematech_FIR_FechaConferenciaMesa( 'D','$',Desc)
      else
          iRet := fFuncBematech_FIR_FechaConferenciaMesa( 'A','$','0,00');
  end
  else
        Result := '1';

  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
      iRet := Status_Impressora( True );
      if iRet = 1 then Result := '0'
      else Result := '1';
  end
  Else
      Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.ImprimeCardapio:String;
var iRet: integer;
begin
    iRet := fFuncBematech_FIR_ImprimeCardapio;
    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
        iRet := Status_Impressora( True );
        if iRet = 1 then Result := '0'
        else Result := '1';
    end
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.LeCardapio:String;
var iRet: integer;
begin
    iRet := fFuncBematech_FIR_CardapioPelaSerial;
    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
        iRet := Status_Impressora( True );
        if iRet = 1 then Result := '0'
        else Result := '1';
    end
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.LeMesasAbertas:String;
    Function TrataLinha(Linha: String): String;
    var i: Integer;
    begin
         While Pos('?', Linha)>0 do
         begin
             i:=Pos('?', Linha);
             Linha[i]:=' ';
         end;
         Result := Linha;
    end;
var iRet: integer;
  fFile : TextFile;
  sFile, sLinha, sRet, sFlag: String;
begin
    sRet := '';
    iRet := fFuncBematech_FIR_RelatorioMesasAbertasSerial;
    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path' )+'\' +'RETORNO.TXT';
      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag := '';
        While not Eof(fFile) do
        Begin
          ReadLn(fFile, sLinha);
          sLinha := TrataLinha(sLinha);
          if sFlag = 'T' then
          begin
            If (Pos(Copy(sLinha,1,4),sRet) = 0) and
                    (sLinha<>'')  and (Pos('REG    ',sLinha) > 0) then
                         sRet := sRet + Copy(sLinha,1,4) + '|';
          End;
          if ( Pos('__DESCRIÇÃO_______VLR_UNIT._________VLR_ACR/DES_' , UpperCase(sLinha))>0) then
            sFlag := 'T';
          if ( Pos('------------------------------------------------' , UpperCase(sLinha))>0) then
            sFlag := '';
        End;
        CloseFile(fFile);
      End;


      iRet := Status_Impressora( True );
      if iRet = 1 then Result := '0|'+sRet
      else Result := '1';
    end
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.RelatMesasAbertas(Tipo: String):String;
var iRet: integer;
begin
    iRet :=  fFuncBematech_FIR_RelatorioMesasAbertas( StrToInt(Tipo) );
    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
        iRet := Status_Impressora( True );
        if iRet = 1 then Result := '0'
        else Result := '1';
    end
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.LeRegistrosVendaRest(Mesa: String):String;
var iRet: integer;
begin
    iRet :=  fFuncBematech_FIR_RegistroVendaSerial( Mesa );

    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
        iRet := Status_Impressora( True );
        if iRet = 1 then Result := '0'
        else Result := '1';
    end
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.FechaCupomMesa( Pgto, Acres, Desc, Mensagem:String ): String;
var iRet: Integer;
    nTipoImp:Integer;
    sRet: String;
begin
  Acres := Trim(FormataTexto(Acres,14,2,4));
  Desc := FormataTexto(Desc,14,2,4);
  if StrToInt(Acres)>0 then
  begin
      sRet := AcrescimoTotal( Acres );
      If sRet = '0' then
      begin
          sRet := Pagamento(Pgto, '', '');
          If sRet = '0' then
          begin
             sRet := FechaCupom( Mensagem );
             Result := '0';
          end
          else
            Result := '1';
      end
      else
        Result := '1';
  end
  else if StrToInt(Desc)>0 then
  begin
      sRet := DescontoTotal( Desc ,nTipoImp);
      If sRet = '0' then
      begin
          sRet := Pagamento(Pgto, '', '');
          If sRet = '0' then
          begin
             sRet := FechaCupom( Mensagem );
             Result := '0';
          end
          else
            Result := '1';
      end
      else
        Result := '1';
  end
  else
  begin
      If Pos('|',Pgto)> 0 then
          Pgto := Copy(Pgto,1,Pos('|',Pgto)-1);
      iRet := fFuncBematech_FIR_FechaCupomResumidoRestaurante( Pgto, Mensagem);

      TrataRetornoBematech( iRet );
        If iRet = 1 then
        begin
            iRet := Status_Impressora( True );
            if iRet = 1 then Result := '0'
            else Result := '1';
        end
        Else
            Result := '1';
  End;
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.FechaCupContaDividida( NumeroCupons, Acres, Desc, Pagamento, ValorCliente, Cliente: String): String;
var iRet: Integer;
    FormasPgto, ValorFormasPgto: String;
begin
  Acres := Trim(FormataTexto(Acres,14,2,4));
  Desc := FormataTexto(Desc,14,2,4);

  ValorCliente := StrTran(ValorCliente,'|',';');
  ValorCliente := Copy(ValorCliente,1,Length(ValorCliente)-1);

  Cliente := StrTran(Cliente,'|',';');
  Cliente := Copy(Cliente,1,Length(Cliente)-1);

  while Length(pagamento)>0 do
  begin
      If Pos('|',Pagamento)>17 then
      begin
          If UpperCase(Trim(Copy(Pagamento,1,16))) = 'DINHEIRO' then
              FormasPgto := FormasPgto + ';' + 'Dinheiro' 
          else
              FormasPgto := FormasPgto + ';' + Copy(Pagamento,1,16) ;

          Pagamento := copy(Pagamento,17,length(Pagamento));
          ValorFormasPgto := ValorFormasPgto + ';' + copy(Pagamento,1,Pos('|',Pagamento)-1);
          Pagamento := copy(Pagamento,Pos('|',Pagamento)+1,length(Pagamento));
      end
      else
      begin
          If UpperCase(Trim(Copy(Pagamento,1,Pos('|',Pagamento)-1))) = 'DINHEIRO' then
              FormasPgto := FormasPgto + ';' + 'Dinheiro'
          else
              FormasPgto := FormasPgto + ';' + Copy(Pagamento,1,Pos('|',Pagamento)-1) ;

          Pagamento := copy(Pagamento,Pos('|',Pagamento)+1,length(Pagamento));
          ValorFormasPgto := ValorFormasPgto + ';' + copy(Pagamento,1,Pos('|',Pagamento)-1);
          Pagamento := copy(Pagamento,Pos('|',Pagamento)+1,length(Pagamento));
      end;
  end;

  FormasPgto := Copy(FormasPgto,2, Length(FormasPgto));
  ValorFormasPgto := Copy(ValorFormasPgto,2, Length(ValorFormasPgto));

  //************************************************************************************
  //*  Faz o tratamento para trocar o ponto decimal pela virgula para enviar para o ECF
  //************************************************************************************
  ValorFormasPgto   := StrTran( ValorFormasPgto, '.', ',' );
  ValorCliente      := StrTran( ValorCliente, '.', ',' );

  //************************************************************************************
  //*  Chama a funcao para registrar a conta dividida no ECF                          
  //************************************************************************************
  if StrToInt(Acres)>0 then
  begin
    iRet := fFuncBematech_FIR_FechaCupomContaDividida( NumeroCupons, 'A', '$', Acres, FormasPgto, ValorFormasPgto, ValorCliente, Cliente);
  end
  else if StrToInt(Desc)>0 then
  begin
    iRet := fFuncBematech_FIR_FechaCupomContaDividida( NumeroCupons, 'D', '$', Desc, FormasPgto, ValorFormasPgto, ValorCliente, Cliente);
  end
  else
    iRet := fFuncBematech_FIR_FechaCupomContaDividida( NumeroCupons, 'D', '$', '0', FormasPgto, ValorFormasPgto, ValorCliente, Cliente);


    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
        iRet := Status_Impressora( True );
        if iRet = 1 then Result := '0'
        else Result := '1';
    end
    Else
        Result := '1';

end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.TransfMesas( Origem, Destino: String): String;
var iRet: integer;
begin
    iRet := fFuncBematech_FIR_TransferenciaMesa ( Origem, Destino);

    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
        iRet := Status_Impressora( True );
        if iRet = 1 then Result := '0'
        else Result := '1';
    end
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpBematechMP25FIR.TransfItem( MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc, MesaDestino: String): String;
var sTrib, sAliquota: String;
    iRet: Integer;
begin
  MesaOrigem := Trim(FormataTexto(MesaOrigem,4,0,4));
  MesaDestino := Trim(FormataTexto(MesaDestino,4,0,4));
  If Length(Codigo) > 14 then
      Codigo := Copy(Codigo,1,14);
  Qtde := Trim(FormataTexto(Qtde,6,3,4));
  VlrUnit := Trim(FormataTexto(VlrUnit,8,2,4));

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

  if StrToInt(Acres)>0 then
      iRet := fFuncBematech_FIR_TransferenciaItem ( MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, 'A', Acres, MesaDestino)
  else if StrToInt(Desc)>0 then
      iRet := fFuncBematech_FIR_TransferenciaItem ( MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, 'D', Desc, MesaDestino)
  else
      iRet := fFuncBematech_FIR_TransferenciaItem ( MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, 'D', '0', MesaDestino);

    TrataRetornoBematech( iRet );
    If iRet = 1 then
    begin
        iRet := Status_Impressora( True );
        if iRet = 1 then Result := '0'
        else Result := '1';
    end
    Else
        Result := '1';
end;

//------------------------------------------------------------------------------
function TImpBematech6000.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var
  iRet, iVezes : Integer;
begin
  GravaLog(' INICIO AUTENTICACAO ->');
  iVezes := 1;
  While iVezes < 5 do //Esse While verifica se o documento esta inserido, se estiver manda o comando
  Begin
    //WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> Bematech_FI_VerificaStatusCheque:' ));
    //fFuncBematech_FI_VerificaStatusCheque( iStatus );
    //WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Bematech_FI_VerificaStatusCheque: '+ IntToStr(iStatus) ));
    //If (iStatus = 1) Or (iStatus = 3) then
    //Begin
      ShowMessage( 'Insira o documento para autenticação!' );
      GravaLog('Bematech_FI_Autenticacao ->' );
      iRet := fFuncBematech_FI_Autenticacao;
      GravaLog('Bematech_FI_Autenticacao <- iRet: '+ IntToStr(iRet));
      //iVezes := 6; // Se mandar para a impressora sai do looping
    //End
    //Else
    //Begin
      //ShowMessage( 'Insira o documento para autenticação!' );
      iVezes := iVezes + 1;
      Sleep( 1000 );
    //End;
    If iRet = 1 then
      iVezes := 6
    Else
      TrataRetornoBematech( iRet, True );
  End;

  //If iRet = 1 then //Se o retorno de impressao do cheque foi ok, checa o status da impressão do cheque
  //begin
  //  While iStatus <> 1 do // iStatus = 1 -> Impressão ok; 2 -> Cheque em impressão; 3-> Cheque posicionado; 4 -> Aguardando posicionamento
  //  Begin
  //    fFuncBematech_FI_VerificaStatusCheque( iStatus );
  //    sleep( 1000 );
  //  End;
  //  TrataRetornoBematech(iRet);
  //End;
  GravaLog(' -> FIM AUTENTICACAO' );

  If iRet = 1
  then Result := '0'
  Else Result := '1';

end;

//------------------------------------------------------------------------------
function TImpBematech6000.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
Var
  iRet            : Integer;
  sPedido         : String;
  sTefPedido      : String;
  sCondicao       : String;
  sPath           : String;
  sTotalizadores  : String;
  fArquivo        : TIniFile;
  aAuxiliar       : TaString;
  lPedido         : Boolean;
  lTefPedido      : Boolean;
  sTotPedido      : String;     // Contem o totalizador do registrador PEDIDO
  sTotTefPedido   : String;     // Contem o totalizador do registrador TEFPEDIDO
  iX              : Integer;
  sMsg            : String;
  sLinha          : String;
  sLista          : TStringList;
begin
  //*******************************************************************************
  // Para não forçar o cliente a utilizar registradores fixos do ECF na emissão
  // de cupom não fiscal vinculado e não vinculado para a impressão do comprovante
  // de venda (função abaixo) sera utilizado o arquivo BEMAFI32.INI
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

  // Pega os nomes dos totalizadores no arquivo de configuração (BEMAFI32.INI)
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo    := TIniFile.Create(sPath + '\' + sArqIniBema);

  GravaLog(' Path do Arquivo : ' + sPath);
  GravaLog(' Arquivo : ' + sArqIniBema);

  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  If fArquivo.ReadString('Microsiga', 'IndTotPed', '') = '' then
    fArquivo.WriteString('Microsiga', 'IndTotPed', '01');

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  Gravalog('sPedido :' + sPedido);
  Gravalog('sTefPedido :' + sTefPedido);
  Gravalog('sCondicao :' + sCondicao);

  //*******************************************************************************
  // Checa indice do totalizador pelo nome informado
  //*******************************************************************************
  sTotalizadores  := Space(1077);
  GravaLog(' Bematech_FI_VerificaRecebimentoNaoFiscalMFD ->');
  iRet  := fFuncBematech_FI_VerificaRecebimentoNaoFiscalMFD( sTotalizadores );
  GravaLog(' Bematech_FI_VerificaRecebimentoNaoFiscalMFD <- iRet:'+IntToStr(iRet));
  GravaLog('Totalizadores:' + sTotalizadores);
  TrataRetornoBematech( iRet, True );
  If iRet = 1 then
  begin
    If (Pos( sPedido, sTotalizadores ) > 0) And (Pos( sTefPedido, sTotalizadores ) > 0) then
    begin
      sTotalizadores := StrTran( sTotalizadores, ',', '|' );
      MontaArray( sTotalizadores,aAuxiliar );

      iX := 0;
      While (iX < Length(aAuxiliar)) do
      begin
        If UpperCase(Trim(Copy( aAuxiliar[iX], 1, 19 ))) = UpperCase( sPedido ) then    
        begin
          lPedido := True;
          sTotPedido := FormataTexto( IntToStr(iX+1), 2, 0, 2 );
        end;
        If UpperCase(Trim(Copy( aAuxiliar[iX], 1, 19 ))) = UpperCase( sTefPedido ) then
        begin
          lTefPedido := True;
          sTotTefPedido := FormataTexto( IntToStr(iX+1), 2, 0, 2 );                       
        end;
        If lPedido And lTefPedido then break;
        Inc( iX );
      end;
    end;
  end
  else
  begin
    GravaLog('Bematech : Capturou totalizador do INI');
    sTotPedido  := fArquivo.ReadString('Microsiga', 'IndTotPed', '');
    GravaLog('sTotPedido: ' + sTotPedido );
    lPedido := True;
    lTefPedido := True;
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
    GravaLog(' Bematech_FI_RecebimentoNaoFiscal -> ' + sTotPedido + ',' + Valor + ',' + sCondicao);
    iRet := fFuncBematech_FI_RecebimentoNaoFiscal ( sTotPedido, Valor, sCondicao );
    GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));
    If Status_Impressora( False ) = 1 then
    begin

      //*******************************************************************************
      // Abre o comprovante não fiscal vinculado
      //*******************************************************************************
      GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado -> ' + sCondicao);
      iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( sCondicao, '', '' );
      GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));
      If Status_Impressora( False ) = 1 then
      begin
          sLista := TStringList.Create;
          sLista.Clear;

          iX := Pos(#10,Texto);
          While iX > 0 do
          Begin
              iX      := Pos(#10,Texto);
              sLinha  := sLinha + Copy(Texto,1,iX) ;
              Texto   := Copy(Texto,iX+1,Length(Texto));

              If Length(sLinha) >= 500 Then
              Begin
                sLista.Add(sLinha);
                sLinha := '';
              end;
          End;

          If Trim(Texto) <> '' Then sLinha := ' ' + sLinha + Texto + #10;
          If Trim(sLinha) <> '' Then sLista.Add(sLinha);

          GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado -> ');

          For iX:= 0 to sLista.Count-1 do
              iRet := fFuncBematech_FI_UsaComprovanteNaoFiscalVinculado( sLista.Strings[iX] );

          GravaLog(' Bematech_FI_UsaComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));

          If Status_Impressora( False ) = 1 then
          begin
            GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado -> ');
            iRet := fFuncBematech_FI_FechaComprovanteNaoFiscalVinculado;
            GravaLog(' Bematech_FI_FechaComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));
            If Status_Impressora( False ) = 1 then
            begin
              //*******************************************************************************
              // Checar se serah impresso o comprovante TEF. Caso afirmativo abre um novo
              // comprovante nao fiscal nao vinculado.
              //*******************************************************************************
              If Tef = 'S' then
              begin
                GravaLog(' Bematech_FI_RecebimentoNaoFiscal -> ');
                iRet := fFuncBematech_FI_RecebimentoNaoFiscal ( sTotTefPedido, Valor, sCondicao );
                GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));

                If Status_Impressora( False ) = 1
                then Result := '0';
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
      TrataRetornoBematech( iRet, True );

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
      LjMsgDlg('Os totalizadores ' + sMsg + ' não existem no ECF. Checar o arquivo ' + sArqIniBema );
    Result := '1';
  end;

  //*******************************************************************************
  // Libera as variaveis
  //*******************************************************************************
  fArquivo.Free;
end;

//---------------------------------------------------------------------------- 
function TImpBematech6000.ReducaoZ(MapaRes:String):String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i, iPos : Integer;
  sData, sHora, sRetorno , sLinhaISS,
  sTotalISS,sFile, sLinha, sFlag,
  sAux, sAux2, sTribIS1, sTribNS1, sTribFS1 : String;
  aRetorno,aFile : array of String;
  fFile : TextFile;
  fBase, fAliq, fValor1, fValor2 : Real;
  aAuxiliar : TaString;
begin
If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    GravaLog(' Bematech_FI_DataMovimento ->');
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    GravaLog(' Bematech_FI_DataMovimento <- iRet:' + IntToStr(iRet));
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := Pdv;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    GravaLog(' Bematech_FI_NumeroReducoes -> ');
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    GravaLog(' Bematech_FI_NumeroReducoes <- iRet:' + IntToStr(iRet));
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    GravaLog(' Bematech_FI_GrandeTotal -> ');
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    GravaLog(' Bematech_FI_GrandeTotal <- iRet:' + IntToStr(iRet));
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    GravaLog(' Bematech_FI_NumeroCupom -> ');
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    GravaLog(' Bematech_FI_NumeroCupom <- iRet:' + IntToStr(iRet));
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);
    aRetorno[ 5] := aRetorno[ 6];
    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);
    aRetorno[15] := FormataTexto('0',16, 0, 1);                   // --outros recebimentos--

    { *********************************************
      ********* TOTALIZADORES DO ECF **************
      ********************************************* }

    sRetorno := Space(889);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD - > ');
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciaisMFD(sRetorno);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD <- iRet:' + IntToStr(iRet));

    sRetorno := StrTran( sRetorno , ',' , '|' );
    MontaArray( sRetorno , aAuxiliar );

    aRetorno[11] := aAuxiliar[1];           //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    aRetorno[12] := aAuxiliar[12];           //**** Nao tributado Nao Tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := aAuxiliar[3];
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    sTribIS1 := Copy(aAuxiliar[4],1,Length(aAuxiliar[4])-2)+'.'+Copy(aAuxiliar[4],Length(aAuxiliar[4])-1,Length( aAuxiliar[4]));//Isenção de ISS
    sTribNS1 := Copy(aAuxiliar[5],1,Length(aAuxiliar[5])-2)+'.'+Copy(aAuxiliar[5],Length(aAuxiliar[5])-1,Length( aAuxiliar[5]));//Não incidencia de ISS
    sTribFS1 := Copy(aAuxiliar[6],1,Length(aAuxiliar[6])-2)+'.'+Copy(aAuxiliar[6],Length(aAuxiliar[6])-1,Length( aAuxiliar[6]));//Substituição de ISS

    //**** Desconto de ICMS ****//
    aRetorno[ 9] := aAuxiliar[7];
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    //aAuxiliar[8]; //Acrescimo sobre ICMS

    //**** Valor do Cancelamento de ICMS ****//
    aRetorno[ 7] := aAuxiliar[9];
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    // desconto de ISS
    aRetorno[18]:= aAuxiliar[10];
    aRetorno[18]:= Copy(aRetorno[18],1,Length(aRetorno[18])-2)+'.'+Copy(aRetorno[18],Length(aRetorno[18])-1,Length(aRetorno[18]));
    aRetorno[18]:= FormataTexto(aRetorno[18], 11, 2, 1 );

    //aAuxiliar[11]; //Acrescimo sobre ISS

    //Cancelamento sobre ISS
    aRetorno[19]:= aAuxiliar[12];
    aRetorno[19]:= Copy(aRetorno[19],1,Length(aRetorno[19])-2)+'.'+Copy(aRetorno[19],Length(aRetorno[19])-1,Length(aRetorno[19]));
    aRetorno[19]:= FormataTexto(aRetorno[19], 11, 2, 1 );

    // QTD DE Aliquotas
    aRetorno[20]:= '00';

    GravaLog(' Bematech_FI_LeituraXSerial ->');
    iRet := fFuncBematech_FI_LeituraXSerial();
    GravaLog(' Bematech_FI_LeituraXSerial <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path')+'\' +'RETORNO.TXT';
      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '';
        ReadLn(fFile, sLinha);

        While ( Pos(#$A,UpperCase( sLinha) )) > 0 Do
        Begin
          iPos := Pos(#$A,UpperCase( sLinha) );
          SetLength( aFile, Length(aFile) + 1 );
          aFile[ High(aFile) ] := Copy( sLinha,1,iPos -1 );
          sLinha := Copy( sLinha,iPos + 1,Length(sLinha) );
        End;

        CloseFile(fFile);

        For iPos := 0 to Length( aFile )-1 Do
        Begin
          sLinha := aFile[ iPos ];
          sLinha := TrataLinha(sLinha);
          if ( Pos('Contador de Cupom Fiscal:' ,sLinha)>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
          if ( Pos('VENDA LÖQUIDA:',sLinha)>0) or ( Pos('VENDA LÍQUIDA:',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
          if ( Pos('Contador de Reinício de Operação:',sLinha)>0) Or
             ( Pos('Contador de Rein¡cio de Opera‡Æo:',sLinha)>0) Or
             ( Pos('CONTADOR DE REINÍCIO DE OPERAÇÃO:',UpperCase(sLinha))>0) then  // CRO - Contador de Reinício de Operação
            aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
          if ( Pos('Total ',sLinha)>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
          begin
            if sFlag = 'S' // Verifica se é aliquota de ISS e soma o total ao array
            then aRetorno[16] := sTotalISS + ';' + aRetorno[16];

            // desliga a captura das aliquotas
            sFlag:='';
          end;

          if ( sFlag='T' ) and ( Copy(sLinha,1,1)='T' ) and ( Copy(sLinha,2,1)<>'o' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            sLinha := StrTran( sLinha, '*', ' ' );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            aRetorno[High(aRetorno)]:=Copy(sLinha,1,6)+' '+FormataTexto(StrTran(Copy(sLinha,8,22),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,30,19),'.',''),14,2,1,'.')
          End;

          // Totais ISS
          if ( sFlag='S' ) and ( Copy(sLinha,1,1)='S' ) then
          Begin
            // ' Valor '  ' Imposto Debitado
             fBase:= StrToFloat(StrTran(StrTran(copy(sLinha,12,24),'.',''),',','.'));
             fAliq:= StrToFloat(StrTran(StrTran(copy(sLinha,32,20),'.',''),',','.'));
             sTotalISS :=FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,1,14))+ fBase) ,14,2,1)+' '+
                            FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,16,14))+ fAliq) ,14,2,1);
                          //Aliquota                    //Valor Base                                    //Valor Debitado
             sLinhaISS := StrTran(Copy( sLinha , 1 , 6),',','.') + ' ' + FormataTexto(FloatToStr(fBase) ,14,2,1) + ' ' +
                           FormataTexto(FloatToStr(fAliq) ,14,2,1) + ';' ; // ';' separador de aliquotas de ISS
             aRetorno[16] := aRetorno[16] + sLinhaISS ;
          End;

          if (Pos('----------ICMS----------',sLinha)>0) then
          // Liga a captura das aliquotas de ICMS
            sFlag:='T';
          if (Pos('---------ISSQN----------',sLinha)>0) then
          begin
            // Liga a captura das aliquotas de ISS
            sFlag:='S';
            sTotalISS := '00000000000.00 00000000000.00';
          end;
        end;

        If Trim(aRetorno[16]) = ''
        then aRetorno[16]:= '00000000000.00 00000000000.00';

        //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
        //   Valor Debitado com 12 casas e 2 decimais + Separador ';'        
        If StrToFloat(sTribIS1) > 0
        then aRetorno[16] := aRetorno[16] + 'IS1' + ' ' +
                                FormataTexto(sTribIS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribNS1) > 0
        then aRetorno[16] := aRetorno[16] + 'NS1' + ' ' +
                                 FormataTexto(sTribNS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribFS1) > 0
        then aRetorno[16] := aRetorno[16] + 'FS1' + ' ' +
                                FormataTexto(sTribFS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

      end
      else
      begin
        GravaLog(' Arquivo ' + sFile + ' não foi encontrado. Portanto as informações das alíquotas não serão gravadas');
      end;
    end;
 end;

  Try
    GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
  Except
    GravaLog('Bematech - Redução Z - Erro na execução do comando: GrvTempRedZ()')
  End;

  DateTimeToString( sData, 'ddmmyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  GravaLog(' Bematech_FI_ReducaoZ -> ');
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  GravaLog(' Bematech_FI_ReducaoZ <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );
  Sleep(10000);

  If iRet = 1 then
  begin
    ReducaoEmitida := True;

    If aRetorno[0] = '00/00/00' then
    begin
      GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 00/00/00 ' +
               'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
      sAux := Space(6);
      sAux2:= Space(6);
      GravaLog(' Bematech_FI_DataHoraReducao -> ');
      iRet := fFuncBematech_FI_DataHoraReducao( sAux , sAux2);
      GravaLog(' Bematech_FI_DataHoraReducao <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux + ' , Hora: ' + sAux2);
      sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
      aRetorno[0] := sAux;
      GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
    end;

    If Trim(MapaRes) = 'S' then
    begin
       //*************************************************************************
       // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
       //*************************************************************************
       sRetorno := Space( 20000 );
       aAuxiliar:= NIL;
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> ');
       iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sRetorno );
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD <- iRet:' + IntToStr(iRet));
       sRetorno := StrTran( sRetorno, ',', '|' );
       MontaArray( sRetorno, aAuxiliar );

       //*************************************************************************
       // Grava o valor do desconto
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[23] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[24] ) / 100;
       aRetorno[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // desconto de ISS

       //*************************************************************************
       // Grava o valor do cancelamento
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[27] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[28] ) / 100;
       aRetorno[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[19]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // cancelamento de ISS

       //*************************************************************************
       // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
       //*************************************************************************
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';

       GravaLog(' <- Resumo Redução Z - ' + Result ); 

    end
    Else
        Result := '0';
  end
  Else
    Result := '1';

end;

//------------------------------------------------------------------------------
function TImpBematech6000.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Var
  sRetorno, cLinha , sPath: String;
  iRet : integer;
  sNomeArq , sNomeArqTmp , sNomeArqBin, sArqGerado : String;
  cArqTemp , cArqTempTXT : TextFile;
  Texto       : TStringList;
Begin
  sNomeArq    := ArqDownTXT;
  sNomeArqTmp := 'DOWNLOADTMP.TXT';
  sNomeArqBin := 'DOWNLOAD.BIN';
  sRetorno := '1';

  sRetorno := DownloadMFD( sTipo, sInicio, sFinal );

  // Pega caminho onde grava os arquivos da bemafi32.ini
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  If sRetorno = '0' then
  begin

    //POR COO
    If sTipo = '2' Then
    begin
       // Abre o arquivo DOWNLOAD.TXT com a imagem dos cupons capturados.
       AssignFile( cArqTemp, PathArquivo + sNomeArq );
       Reset( cArqTemp );

       // Cria o arquivo DOWNLOADTMP.TXT para guardar a imagens dos cupons capturados, retirando as linhas em branco.
       AssignFile( cArqTempTXT, sNomeArqTmp );
       Rewrite( cArqTempTXT );

       cLinha := '';
       while not EOF( cArqTemp ) do
       begin
         Readln( cArqTemp, cLinha );
           if ( cLinha <> '' ) then
           begin
             Writeln( cArqTempTXT, cLinha );
           end;
       end;

       CloseFile( cArqTemp );
       CloseFile( cArqTempTXT );

       // Cria um objeto do tipo TStringList.
       Texto := TStringList.Create;
       Texto.LoadFromFile( sNomeArqTmp );

       // Copia as informações de data inicial e final, dentro do objeto Texto.
       sInicio := copy( Texto.Strings[ 7 ], 1, 10 );
       sFinal  := copy( Texto.Strings[ Texto.Count - 2 ], 30, 10 );
    end;


    If sBinario <> '1' Then
    begin
      // Tira as barras
      sInicio := SubstituiStr(sInicio, '/', '');
      sFinal  := SubstituiStr(sFinal, '/', '');
      sArqGerado :=  UpperCase(PathArquivo + DEFAULT_PATHARQMFD + 'MFD' + NumSerie + '_' +
                          FormatDateTime('ddMMyyyy', Date) + '_' + FormatDateTime('hhmmss', Time)+'.txt');

      GravaLog('-> BemaGeraRegistrosTipoEMFD1( ' + sPath + sArqDownMFD +','+ sArqGerado +','+ sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ '2' + ')' );

      iRet := fFuncBemaGeraRegistrosTipoEMFD1( sPath + sArqDownMFD  ,
                                   sArqGerado   ,
                                   sInicio,
                                   sFinal ,
                                   sRazao ,
                                   sEnd   ,
                                   '' ,
                                   '2',
                                   '' , '', '', '', '', '', '', '', '', '', '', '', '' );
      GravaLog(' BemaGeraRegistrosTipoEMFD1 <- iRet:' + IntToStr(iRet));
      //TrataRetornoBematech( iRet, True );
      If iRet <> 0
      then sRetorno := '1';
    end
    end
    else
    begin
       If not CopyFile( PChar(  sPath + sArqDownMFD ), PChar( PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin ), False ) then
       begin
         ShowMessage( 'Erro ao copiar o arquivo ' +  sPath + sArqDownMFD + ' para ' + PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin );
         sRetorno := '1';
       end
       else GravaLog('-> BemaGeraRegistrosTipoE - formato binario( ' + sPath + sArqDownMFD +','+ PathArquivo +
                         DEFAULT_PATHARQMFD + sNomeArqBin +','+ sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ sBinario + ')' );
    end;

  Result := sRetorno;

end;

//----------------------------------------------------------------------------
function TImpBematech7000.Abrir(sPorta : String; iHdlMain:Integer) : String;
begin
sMarca := 'BEMATECH';

// Verifica o arquivo de configuracao da Bematech.
//'2' - Impressora com MFD -- Retorna número de série com 20 dígitos Mp7000 Hardware IBM
If ArqIniBematech( sPorta, sMarca, '2' ) then
begin
  Result := OpenBematech( sPorta, True );
  // Carrega as aliquotas e N. PDV para ganhar performance
  if Copy(Result,1,1) = '0' then
  begin
    AlimentaProperties;
    If lError then
    begin
      Result := '1';
      LjMsgDlg( MsgErroProp );
    end
  end
end
Else LjMsgDlg( 'Problemas com o arquivo ' + sArqIniBema );

end;

//------------------------------------------------------------------------------
 function TImpBematech7000.ReducaoZ(MapaRes:String):String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i, iPos : Integer;
  aRetorno,aFile : array of String;
  sLinhaISS, sTotalISS, sData, sHora ,
  sRetorno, sFile, sLinha, sFlag  ,
  sAux, sAux2, sTribIS1, sTribNS1, sTribFS1: String;
  fFile : TextFile;
  fBase, fAliq , fValor1, fValor2 : Real;
  aAuxiliar : TaString;
begin
If Trim(MapaRes) = 'S' then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    GravaLog(' Bematech_FI_DataMovimento ->');
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    GravaLog(' Bematech_FI_DataMovimento <- iRet:' + IntToStr(iRet));
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := Pdv;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    GravaLog(' Bematech_FI_NumeroReducoes ->');
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    GravaLog(' Bematech_FI_NumeroReducoes <- iRet:' + IntToStr(iRet));
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    GravaLog(' Bematech_FI_GrandeTotal ->');
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    GravaLog(' Bematech_FI_GrandeTotal <- iRet:' + IntToStr(iRet));
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                               //**** Numero documento Final ****//
    GravaLog(' Bematech_FI_NumeroCupom ->');
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    GravaLog(' Bematech_FI_NumeroCupom <- iRet:' + IntToStr(iRet));
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);
    aRetorno[ 5] := aRetorno[ 6];
    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);
    aRetorno[15] := FormataTexto('0',16, 0, 1);                         // --outros recebimentos--

    {
      *********************************************
      ********* TOTALIZADORES DO ECF **************
      *********************************************
    }
    sRetorno := Space(889);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD - > ');
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciaisMFD(sRetorno);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD <- iRet:' + IntToStr(iRet));

    sRetorno := StrTran( sRetorno , ',' , '|' );
    MontaArray( sRetorno , aAuxiliar );

    aRetorno[11] := aAuxiliar[1];           //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    aRetorno[12] := aAuxiliar[2];           //**** Nao tributado Nao Tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    aRetorno[10] := aAuxiliar[3];           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    sTribIS1 := Copy(aAuxiliar[4],1,Length(aAuxiliar[4])-2)+'.'+Copy(aAuxiliar[4],Length(aAuxiliar[4])-1,Length( aAuxiliar[4]));//Isenção de ISS
    sTribNS1 := Copy(aAuxiliar[5],1,Length(aAuxiliar[5])-2)+'.'+Copy(aAuxiliar[5],Length(aAuxiliar[5])-1,Length( aAuxiliar[5]));//Não incidencia de ISS
    sTribFS1 := Copy(aAuxiliar[6],1,Length(aAuxiliar[6])-2)+'.'+Copy(aAuxiliar[6],Length(aAuxiliar[6])-1,Length( aAuxiliar[6]));//Substituição de ISS

    //**** Desconto de ICMS ****//
    aRetorno[ 9] := aAuxiliar[7];
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    //aAuxiliar[8]; //Acrescimo sobre ICMS

    //Cancelamentos sobre ICMS
    aRetorno[ 7] := aAuxiliar[9];
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    // desconto de ISS
    aRetorno[18]:= aAuxiliar[10];
    aRetorno[18]:= Copy(aRetorno[18],1,Length(aRetorno[18])-2)+'.'+Copy(aRetorno[18],Length(aRetorno[18])-1,Length(aRetorno[18]));
    aRetorno[18]:= FormataTexto(aRetorno[18], 11, 2, 1 );

    //aAuxiliar[11]; //Acrescimo sobre ISS

    //Cancelamento sobre ISS
    aRetorno[19]:= aAuxiliar[12];
    aRetorno[19]:= Copy(aRetorno[19],1,Length(aRetorno[19])-2)+'.'+Copy(aRetorno[19],Length(aRetorno[19])-1,Length(aRetorno[19]));
    aRetorno[19]:= FormataTexto(aRetorno[19], 11, 2, 1 );

    // QTD DE Aliquotas
    aRetorno[20]:= '00';

    GravaLog(' Bematech_FI_LeituraXSerial -> ');
    iRet := fFuncBematech_FI_LeituraXSerial();
    GravaLog(' Bematech_FI_LeituraXSerial <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path' )+'\' +'RETORNO.TXT';
      if FileExists(sFile) then
      Begin
        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '';
        ReadLn(fFile, sLinha);

        While ( Pos(#$A,UpperCase( sLinha) )) > 0 Do
            Begin
                iPos := Pos(#$A,UpperCase( sLinha) );
                SetLength( aFile, Length(aFile) + 1 );
                aFile[ High(aFile) ] := Copy( sLinha,1,iPos -1 );
                sLinha := Copy( sLinha,iPos + 1,Length(sLinha) );
            End;

        CloseFile(fFile);

        For iPos := 0 to Length( aFile )-1 Do
        Begin
          sLinha := aFile[ iPos ];
          sLinha := TrataLinha(sLinha);
          if ( Pos('Contador de Cupom Fiscal:' ,sLinha)>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
          if ( Pos('VENDA LÖQUIDA:',sLinha)>0) or ( Pos('VENDA LÍQUIDA:',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
          if ( Pos('Contador de Reinício de Operação:',sLinha)>0) Or
             ( Pos('Contador de Rein¡cio de Opera‡Æo:',sLinha)>0) Or
             ( Pos('CONTADOR DE REINÍCIO DE OPERAÇÃO:',UpperCase(sLinha))>0) then  // CRO - Contador de Reinício de Operação
            aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
          if ( Pos('Total ',sLinha)>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
          begin
            if sFlag = 'S' // Verifica se é aliquota de ISS e soma o total ao array
            then aRetorno[16] := sTotalISS + ';' + aRetorno[16];

            // desliga a captura das aliquotas
            sFlag:='';
          end;

          if ( sFlag='T' ) and ( Copy(sLinha,1,1)='T' ) and ( Copy(sLinha,2,1)<>'o' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            sLinha := StrTran( sLinha, '*', ' ' );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            aRetorno[High(aRetorno)]:=Copy(sLinha,1,6)+' '+FormataTexto(StrTran(Copy(sLinha,8,22),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,30,19),'.',''),14,2,1,'.')
          End;

          // Totais ISS
          if ( sFlag='S' ) and ( Copy(sLinha,1,1)='S' ) then
          Begin
            // ' Valor '  ' Imposto Debitado
             fBase:= StrToFloat(StrTran(StrTran(copy(sLinha,12,24),'.',''),',','.'));
             fAliq:= StrToFloat(StrTran(StrTran(copy(sLinha,32,20),'.',''),',','.'));
             sTotalISS :=FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,1,14))+ fBase) ,14,2,1)+' '+
                            FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,16,14))+ fAliq) ,14,2,1);
                          //Aliquota                    //Valor Base                                    //Valor Debitado
             sLinhaISS := StrTran(Copy( sLinha , 1 , 6),',','.') + ' ' + FormataTexto(FloatToStr(fBase) ,14,2,1) + ' ' +
                           FormataTexto(FloatToStr(fAliq) ,14,2,1) + ';' ; // ';' separador de aliquotas de ISS
             aRetorno[16] := aRetorno[16] + sLinhaISS ;
          End;

          if (Pos('          ICMS          ',sLinha)>0) then
          // Liga a captura das aliquotas de ICMS
            sFlag:='T';
          if (Pos('         ISSQN          ',sLinha)>0) then
          begin
            // Liga a captura das aliquotas de ISS
            sFlag:='S';
            sTotalISS := '00000000000.00 00000000000.00';
          end;
        end;

        If Trim(aRetorno[16]) = ''
        then aRetorno[16]:= '00000000000.00 00000000000.00';

        //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
        //   Valor Debitado com 12 casas e 2 decimais + Separador ';'        
        If StrToFloat(sTribIS1) > 0
        then aRetorno[16] := aRetorno[16] + 'IS1' + ' ' +
                                FormataTexto(sTribIS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribNS1) > 0
        then aRetorno[16] := aRetorno[16] + 'NS1' + ' ' +
                                 FormataTexto(sTribNS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribFS1) > 0
        then aRetorno[16] := aRetorno[16] + 'FS1' + ' ' +
                                FormataTexto(sTribFS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

      end
    end;
 end;

  Try
    GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
  Except
    GravaLog('Bematech - Redução Z - Erro na execução do comando: GrvTempRedZ()')
  End;

  DateTimeToString( sData, 'ddmmyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  GravaLog(' Bematech_FI_ReducaoZ ->');
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  GravaLog(' Bematech_FI_ReducaoZ <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );
  Sleep(10000);
  If iRet = 1 then
  begin
    ReducaoEmitida := True;

    If aRetorno[0] = '00/00/00' then
    begin
      GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 00/00/00 ' +
               'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
      sAux := Space(6);
      sAux2:= Space(6);
      GravaLog(' Bematech_FI_DataHoraReducao -> ');
      iRet := fFuncBematech_FI_DataHoraReducao( sAux , sAux2);
      GravaLog(' Bematech_FI_DataHoraReducao <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux + ' , Hora: ' + sAux2);
      sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
      aRetorno[0] := sAux;
      GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
    end;

    If Trim(MapaRes) = 'S' then
    begin
       //*************************************************************************
       // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
       //*************************************************************************
       sRetorno := Space( 20000 );
       aAuxiliar:= NIL;
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> ');
       iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sRetorno );
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD <- iRet:' + IntToStr(iRet));
       sRetorno := StrTran( sRetorno, ',', '|' );
       MontaArray( sRetorno, aAuxiliar );

       //*************************************************************************
       // Grava o valor do desconto
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[23] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[24] ) / 100;
       aRetorno[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // desconto de ISS

       //*************************************************************************
       // Grava o valor do cancelamento
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[27] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[28] ) / 100;
       aRetorno[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[19]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // cancelamento de ISS

       //*************************************************************************
       // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
       //*************************************************************************
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';

       GravaLog(' <- Resumo da Redução Z : ' + Result );

    end
    Else
        Result := '0';
  end
  Else
    Result := '1';

end;

//------------------------------------------------------------------------------
function TImpBematech7000.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : String ):String;
Var
  sRetorno,cLinha, sPath , sNomeArq , sNomeArqTmp , sArqGerado : String;
  iRet : integer;
  cArqTemp, cArqTempTXT : TextFile;
  Texto : TStringList;
Begin
  sNomeArq    := ArqDownTXT;
  sNomeArqTmp := 'DOWNLOADTMP.TXT';
  sRetorno := '1';

  GravaLog('-> GeraRegTipoE : ' + sTipo + ',' + sInicio + ',' + sFinal + ',' + sRazao + ',' + sEnd + ',' + sBinario);
  sRetorno := DownloadMFD( sTipo, sInicio, sFinal );

  // Pega caminho onde grava os arquivos da bemafi32.ini
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  If sRetorno = '0' then
  begin

    //POR COO
    If sTipo = '2' Then
    begin
       // Abre o arquivo DOWNLOAD.TXT com a imagem dos cupons capturados.
       AssignFile( cArqTemp, PathArquivo + sNomeArq );
       Reset( cArqTemp );

       // Cria o arquivo DOWNLOADTMP.TXT para guardar a imagens dos cupons capturados, retirando as linhas em branco.
       AssignFile( cArqTempTXT, sNomeArqTmp );
       Rewrite( cArqTempTXT );

       cLinha := '';
       while not EOF( cArqTemp ) do
       begin
         Readln( cArqTemp, cLinha );
           if ( cLinha <> '' ) then
           begin
             Writeln( cArqTempTXT, cLinha );
           end;
       end;

       CloseFile( cArqTemp );
       CloseFile( cArqTempTXT );

       // Cria um objeto do tipo TStringList.
       Texto := TStringList.Create;
       Texto.LoadFromFile( sNomeArqTmp );

       // Copia as informações de data inicial e final, dentro do objeto Texto.
       sInicio := copy( Texto.Strings[ 7 ], 1, 10 );
       sFinal  := copy( Texto.Strings[ Texto.Count - 2 ], 30, 10 );
    end;

    If sBinario <> '1' then
    begin
      // Tira as barras
      sInicio := SubstituiStr(sInicio, '/', '');
      sFinal  := SubstituiStr(sFinal, '/', '');

      sArqGerado :=  UpperCase(PathArquivo + DEFAULT_PATHARQMFD + 'MFD' + NumSerie + '_' +
                          FormatDateTime('ddMMyyyy', Date) + '_' + FormatDateTime('hhmmss', Time)+'.txt');

      GravaLog('-> BemaGeraRegistrosTipoEMFD2( ' + sPath + sArqDownMFD +','+ sArqGerado +
                                ','+ sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ '2' + ')' );

      iRet := fFuncBemaGeraRegistrosTipoEMFD2( sPath + sArqDownMFD  ,
                                   sArqGerado   ,
                                   sInicio,
                                   sFinal ,
                                   sRazao ,
                                   sEnd   ,
                                   '' ,
                                   '2',
                                   '' , '', '', '', '', '', '', '', '', '', '', '', '' );

      GravaLog(' BemaGeraRegistrosTipoEMFD2 <- iRet: ' + IntToStr(iRet));
      TrataRetornoBematech( iRet, True );
      If iRet <> 0
      then sRetorno := '1';
    end;

  end;

  Result := sRetorno;

end;

//------------------------------------------------------------------------------
function TCMC7_BEMA.Abrir( aPorta, sMensagem :String ) : String;
Begin
  If Not bOpened Then
    Result := Copy( OpenBematech( aPorta ), 1, 1 )
  Else
    Result := '0';
End;
//------------------------------------------------------------------------------
function TCMC7_BEMA.LeDocumento : String;
Var
iRet : integer;
Codigo : String;
Begin
  Codigo := Space(36);
  iRet := fFuncBematech_FI_LeituraChequeMFD( Codigo );
  TrataRetornoBematech( iRet );
  If iRet = 1 then
    Result := '0|' + Codigo
  Else
  Begin
    iRet := fFuncBematech_FI_CancelaImpressaoCheque();    
    TrataRetornoBematech(iRet);                           
    Result := '1';
  End;
End;
//------------------------------------------------------------------------------
function TCMC7_BEMA.Fechar:String;
Begin
Result := CloseBematech;
End;
//------------------------------------------------------------------------------
function TCmc7Bem6000.Abrir( aPorta, sMensagem :String ) : String;
Begin
  If Not bOpened Then
    Result := Copy( OpenBematech( aPorta, True ), 1, 1 )
  Else
    Result := '0';
End;

//----------------------------------------------------------------------------
{ TImpBematech2100_0101 }
function TImpBematech2100_0101.ReducaoZ(MapaRes: String): String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i, iPos : Integer;
  aRetorno,aFile : array of String;
  sData, sHora, sRetorno, sLinhaISS,
  sTotalISS,sFile, sLinha, sFlag,
  sAux, sAux2, sTribIS1, sTribNS1, sTribFS1 : String;
  fFile : TextFile;
  fBase, fAliq,fValor1, fValor2 : Real;
  aAuxiliar : TaString;
  bAchou : Boolean;
begin
If (Trim(MapaRes) = 'S') then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    GravaLog(' Bematech_FI_DataMovimento -> ');
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    GravaLog(' Bematech_FI_DataMovimento <- iRet:' + IntToStr(iRet));
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := Pdv;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                               //**** Numero de reducoes ****//
    GravaLog(' Bematech_FI_NumeroReducoes -> ');
    iRet := fFuncBematech_FI_NumeroReducoes( aRetorno[3] );
    GravaLog(' Bematech_FI_NumeroReducoes <- iRet:' + IntToStr(iRet));
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    GravaLog(' Bematech_FI_GrandeTotal ->');
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    GravaLog(' Bematech_FI_GrandeTotal <- iRet:' + IntToStr(iRet));
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    GravaLog(' Bematech_FI_NumeroCupom ->');
    iRet := fFuncBematech_FI_NumeroCupom( aRetorno[ 6] );
    GravaLog(' Bematech_FI_NumeroCupom <- iRet:' + IntToStr(iRet));
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);

    aRetorno[ 5] := aRetorno[ 6];
    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);
    aRetorno[15] := FormataTexto('0',16, 0, 1);                         // --outros recebimentos--

   {
      *********************************************
      ********* TOTALIZADORES DO ECF **************
      *********************************************
    }

    sRetorno := Space(889);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD - > ');
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciaisMFD(sRetorno);
    GravaLog(' Bematech_FI_VerificaTotalizadoresParciaisMFD <- iRet:' + IntToStr(iRet));

    sRetorno := StrTran( sRetorno , ',' , '|' );
    MontaArray( sRetorno , aAuxiliar );

    aRetorno[11] := aAuxiliar[1];           //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    aRetorno[12] := aAuxiliar[2];           //**** Nao tributado Nao Tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    aRetorno[10] := aAuxiliar[3];           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    sTribIS1 := Copy(aAuxiliar[4],1,Length(aAuxiliar[4])-2)+'.'+Copy(aAuxiliar[4],Length(aAuxiliar[4])-1,Length( aAuxiliar[4]));//Isenção de ISS
    sTribNS1 := Copy(aAuxiliar[5],1,Length(aAuxiliar[5])-2)+'.'+Copy(aAuxiliar[5],Length(aAuxiliar[5])-1,Length( aAuxiliar[5]));//Não incidencia de ISS
    sTribFS1 := Copy(aAuxiliar[6],1,Length(aAuxiliar[6])-2)+'.'+Copy(aAuxiliar[6],Length(aAuxiliar[6])-1,Length( aAuxiliar[6]));//Substituição de ISS

    //**** Desconto de ICMS ****//
    aRetorno[ 9] := aAuxiliar[7];
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    //**** Valor do Cancelamento de ICMS ****//
    aRetorno[ 7] := aAuxiliar[9];
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    //aAuxiliar[8]; //Acrescimo sobre ICMS

    // desconto de ISS
    aRetorno[18]:= aAuxiliar[10];
    aRetorno[18]:= Copy(aRetorno[18],1,Length(aRetorno[18])-2)+'.'+Copy(aRetorno[18],Length(aRetorno[18])-1,Length(aRetorno[18]));
    aRetorno[18]:= FormataTexto(aRetorno[18], 11, 2, 1 );

    //aAuxiliar[11]; //Acrescimo sobre ISS

    //Cancelamento sobre ISS
    aRetorno[19]:= aAuxiliar[12];
    aRetorno[19]:= Copy(aRetorno[19],1,Length(aRetorno[19])-2)+'.'+Copy(aRetorno[19],Length(aRetorno[19])-1,Length(aRetorno[19]));
    aRetorno[19]:= FormataTexto(aRetorno[19], 11, 2, 1 );

    // QTD DE Aliquotas
    aRetorno[20]:= '00';

    GravaLog(' Bematech_FI_LeituraXSerial -> ');
    iRet := fFuncBematech_FI_LeituraXSerial();
    GravaLog(' Bematech_FI_LeituraXSerial <- iRet:' + IntToStr(iRet));
    TrataRetornoBematech( iRet, True );

    If iRet = 1 then
    begin
      sFile := LeArqBema( 'Sistema', 'Path' );

      If sFile[Length(sFile)] <> '\'
      then sFile := sFile + '\';

      sFile := sFile + 'RETORNO.TXT';
      GravaLog('Procura arquivo: ' + sFile);
      if FileExists(sFile) then
      Begin
        GravaLog('Arquivo de retorno existe em : ' + sFile);
        try
         GravaLog('Copiando o arquivo');
         If CopyFile( PChar(  sFile ), PChar( ExtractFilePath(Application.Name) + '\LogLX_'+ DateToStr(Now) +  FormatDateTime('HHnnsszzz' , Now) + '.txt'), False )
         then GravaLog('Arquivo copiado com sucesso')
         else GravaLog('Arquivo não copiado ')
        except
          GravaLog('Copia sem sucesso');
        end;

        AssignFile(fFile, sFile);
        Reset(fFile);
        sFlag:='';
        aRetorno[16]:= '';
        ReadLn(fFile, sLinha);

        GravaLog('Arquivo :' + sLinha);

        While ( Pos(#$A,UpperCase(sLinha) )) > 0 Do
        Begin
          GravaLog(' Achou caracter no arquivo ');
          bAchou := True;
          iPos := Pos(#$A,UpperCase( sLinha) );
          SetLength( aFile, Length(aFile) + 1 );
          aFile[ High(aFile) ] := Copy( sLinha,1,iPos -1 );
          sLinha := Copy( sLinha,iPos + 1,Length(sLinha) );
        End;

        CloseFile(fFile);
        GravaLog('Fecha arquivo');

        For iPos := 0 to Length( aFile )-1 Do
        Begin
          sLinha := aFile[ iPos ];
          sLinha := TrataLinha(sLinha);
          GravaLog('iPos:' + IntToStr(iPos) + '; Linha:' + sLinha);
          if ( Pos('Contador de Cupom Fiscal:' ,sLinha)>0) then
            aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
            GravaLog('Contador de Cupom Fiscal:' + aRetorno[5]);
          if ( Pos('VENDA LÖQUIDA:',sLinha)>0) or ( Pos('VENDA LÍQUIDA:',UpperCase(sLinha))>0) then  // Venda Liquida
            aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
            GravaLog('Venda Liquida:' + aRetorno[8]);
          if ( Pos('Contador de Reinício de Operação:',sLinha)>0) Or
             ( Pos('Contador de Rein¡cio de Opera‡Æo:',sLinha)>0) Or
             ( Pos('CONTADOR DE REINÍCIO DE OPERAÇÃO:',UpperCase(sLinha))>0) then  // CRO - Contador de Reinício de Operação
            aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
            GravaLog('CRO:' + aRetorno[17]);
          if ( Pos('Total ',sLinha)>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
          begin
            GravaLog('Total: sFlag branco');
            if sFlag = 'S' // Verifica se é aliquota de ISS e soma o total ao array
            then aRetorno[16] := sTotalISS + ';' + aRetorno[16];

            // desliga a captura das aliquotas
            sFlag:='';
          end;

          if ( sFlag='T' ) and ( Copy(sLinha,1,1)='T' ) and ( Copy(sLinha,2,1)<>'o' ) then
          Begin
            aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
            SetLength( aRetorno, Length(aRetorno)+1 );
            sLinha := StrTran( sLinha, '*', ' ' );
            // Aliquota '  ' Valor '  ' Imposto Debitado
            aRetorno[High(aRetorno)]:=Copy(sLinha,1,6)+' '+FormataTexto(StrTran(Copy(sLinha,8,22),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,30,19),'.',''),14,2,1,'.');
            GravaLog('aliquota T :' + aRetorno[High(aRetorno)]);
          End;

          // Totais ISS
          if ( sFlag='S' ) and ( Copy(sLinha,1,1)='S' ) then
          Begin
            // ' Valor '  ' Imposto Debitado
             fBase:= StrToFloat(StrTran(StrTran(copy(sLinha,12,24),'.',''),',','.'));
             fAliq:= StrToFloat(StrTran(StrTran(copy(sLinha,32,20),'.',''),',','.'));
             sTotalISS :=FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,1,14))+ fBase) ,14,2,1)+' '+
                            FormataTexto(FloatToStr(StrToFloat(copy(sTotalISS,16,14))+ fAliq) ,14,2,1);
                          //Aliquota                    //Valor Base                                    //Valor Debitado
             sLinhaISS := StrTran(Copy( sLinha , 1 , 6),',','.') + ' ' + FormataTexto(FloatToStr(fBase) ,14,2,1) + ' ' +
                           FormataTexto(FloatToStr(fAliq) ,14,2,1) + ';' ; // ';' separador de aliquotas de ISS
             aRetorno[16] := aRetorno[16] + sLinhaISS ;
            GravaLog('aliquota S :' + aRetorno[16]);
          End;

          if (Pos('          ICMS          ',sLinha)>0) then
          // Liga a captura das aliquotas de ICMS
            sFlag:='T';
          if (Pos('         ISSQN          ',sLinha)>0) then
          begin
            // Liga a captura das aliquotas de ISS
            sFlag:='S';
            sTotalISS := '00000000000.00 00000000000.00';
          end;
        end;

        If Trim(aRetorno[16]) = ''
        then aRetorno[16]:= '00000000000.00 00000000000.00';

        //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
        //   Valor Debitado com 12 casas e 2 decimais + Separador ';'
        If StrToFloat(sTribIS1) > 0
        then aRetorno[16] := aRetorno[16] + 'IS1' + ' ' +
                                FormataTexto(sTribIS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribNS1) > 0
        then aRetorno[16] := aRetorno[16] + 'NS1' + ' ' +
                                 FormataTexto(sTribNS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

        If StrToFloat(sTribFS1) > 0
        then aRetorno[16] := aRetorno[16] + 'FS1' + ' ' +
                                FormataTexto(sTribFS1 ,14,2,1) + ' ' + FormataTexto('0',14,2,1) + ';' ;

      end
      else
      begin
        GravaLog('Arquivo ' + sFile + ' não encontrado. Portanto não serão gravadas as informações de alíquotas');
      end;
    end;
 end;

  Try
    GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
  Except
    GravaLog('Bematech - Redução Z - Erro na execução do comando: GrvTempRedZ()')
  End;

  DateTimeToString( sData, 'ddmmyyyy', Date );
  DateTimeToString( sHora, 'hhnnss', Time );
  GravaLog(' Bematech_FI_ReducaoZ -> Data:' + sData + ', Hora:' + sHora);
  iRet := fFuncBematech_FI_ReducaoZ( sData, sHora );
  GravaLog(' Bematech_FI_ReducaoZ <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );
  GravaLog(' Bematech_FI_ReducaoZ (Tratado) <- iRet:' + IntToStr(iRet));

  If iRet = 1 then
  begin
    ReducaoEmitida := True;

    If aRetorno[0] = '00/00/00' then
    begin
      GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 00/00/00 ' +
               'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
      sAux := Space(6);
      sAux2:= Space(6);
      GravaLog(' Bematech_FI_DataHoraReducao -> ');
      iRet := fFuncBematech_FI_DataHoraReducao( sAux , sAux2);
      GravaLog(' Bematech_FI_DataHoraReducao <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux + ' , Hora: ' + sAux2);
      sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
      aRetorno[0] := sAux;
      GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
    end;

    If Trim(MapaRes) = 'S' then
    begin
       //*************************************************************************
       // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
       //*************************************************************************
       sRetorno := Space( 20000 );
       aAuxiliar:= NIL;
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD -> ');
       iRet := fFuncBematech_FI_DadosUltimaReducaoMFD( sRetorno );
       GravaLog(' Bematech_FI_DadosUltimaReducaoMFD <- iRet:' + IntToStr(iRet) + ' - Ret:' + sRetorno);
       sRetorno := StrTran( sRetorno, ',', '|' );
       MontaArray( sRetorno, aAuxiliar );

       //*************************************************************************
       // Grava o valor do cancelamento
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[27] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[28] ) / 100;
       aRetorno[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[19]:= FormataTexto( FloatToStr(fValor2) , 11, 2, 1 );                 // cancelamento de ISS

       //*************************************************************************
       // Grava o valor do desconto
       //*************************************************************************
       fValor1 := StrToFloat( aAuxiliar[23] ) / 100;
       fValor2 := StrToFloat( aAuxiliar[24] ) / 100;
       aRetorno[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
       aRetorno[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );                 // desconto de ISS

       //*************************************************************************
       // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
       //*************************************************************************
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';

       GravaLog('Mapa Resumo <- Retorno :' + Result );
    end
    Else
        Result := '0';
  end
  Else
    Result := '1';
end;

procedure TImpBematechMP25FI.AlimentaProperties;
    Procedure CargaIndiceAliq();
    var i, iRet : Integer;
        sIndiceISS : String;
        sISS, sICMS : String;
    begin
      try
        sICMS := ICMS;
        sIndiceISS := Space(48);
        iRet := fFuncBematech_FI_VerificaIndiceAliquotasIss( sIndiceISS );
        TrataRetornoBematech(iRet);
        If (iRet = 1) And (sIndiceISS[1] <> #0) then
        Begin
            i := 1;
            While Length(sICMS)>0 do
            Begin
                SetLength(aIndAliq,Length(aIndAliq)+2);
                aIndAliq[Length(aIndAliq)-2] := FormataTexto(IntToStr(i),2,0,2);
                If i <> StrToInt(Copy(sIndiceISS,1,2)) then
                begin
                  aIndAliq[Length(aIndAliq)-1] := 'T' + Copy(sICMS,1, Pos('|', sICMS)-1);
                end
                Else
                begin
                  aIndAliq[Length(aIndAliq)-1] := 'S' + Copy(sICMS,1, Pos('|', sICMS)-1);
                  sIndiceISS:= Copy(sIndiceISS,Pos(',', sIndiceISS)+1, Length(sIndiceISS));
                End;
                sICMS := Copy(sICMS,Pos('|', sICMS)+1, Length(sICMS));
                i := i + 1;
            End;
        End;
      except
      end;
    End;
var
  iRet : Integer;
  sRet, sICMS, sISS, sAliq: String;
  lEstendido , lErro : Boolean;
begin
  // Inicalização de propriedades
  ICMS  := '';
  ISS   := '';
  Pdv   := '';
  Eprom := '';
  Cnpj  := Space(18);
  Ie    := Space(15);
  NumLoja   := Space(4);
  NumSerie  := Space(20);
  TipoEcf   := '';
  MarcaEcf  := '';
  ModeloEcf := Space(10);
  IndicaMFAdi  := '';
  DataIntEprom := '';
  HoraIntEprom := '';
  ContadorCro  := '';
  ContadorCrz  := '';
  GTInicial    := '';
  GTFinal      := '';
  VendaBrutaDia:= '';
  ReducaoEmitida := False;
  //--------------------------

  // Inicalização de variaveis
  lError := False;
  lEstendido   := true;
  //--------------------------

  // Retorno de Aliquotas ( ISS )
  Try
     sRet := Space( 79 );
     GravaLog('Bematech_FI_VerificaAliquotasIss (79) -> ');
     iRet := fFuncBematech_FI_VerificaAliquotasIss( sRet );
     TrataRetornoBematech( iRet, lEstendido );
     GravaLog('Bematech_FI_VerificaAliquotasIss (79) <- Retorno :' + IntToStr(iRet));
     lErro := False;
  Except on E:Exception do
    begin
     GravaLog('Bematech_FI_VerificaAliquotasIss (79) <- ' + E.className + ' Erro :' + E.message);
     lErro := True;
    end;
  End;

  If lErro Then
  begin
    Try
     GravaLog('Bematech_FI_VerificaAliquotasIss (80) -> ');
     sRet := Space( 80 );
     iRet := fFuncBematech_FI_VerificaAliquotasIss( sRet );
     TrataRetornoBematech( iRet, lEstendido );
     GravaLog('Bematech_FI_VerificaAliquotasIss (80) <- Retorno :' + IntToStr(iRet));
     lErro := False;
    Except on E:Exception do
      begin
       GravaLog('Bematech_FI_VerificaAliquotasIss (80) <- ' + E.className + ' Erro :' + E.message);
       lErro := True;
      end;
    End;
  End;

  If iRet = 1 then
  begin
    sISS := Trim( StrTran( sRet, ',', '|' ) );
    While Length(sISS)>0 do
    begin
      sAliq := Copy(sISS,1,2)+','+Copy(sISS,3,2);
      ISS   := ISS + FormataTexto(sAliq,5,2,1) +'|';
      sISS  := Copy(sISS,6,Length(sISS));
    end
  end
  Else
    exit;

  // Retorno de Aliquotas ( ICMS )
  Try
   WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (79) -> ');
   sRet := Space( 79 );
   iRet := fFuncBematech_FI_RetornoAliquotas( sRet );
   TrataRetornoBematech( iRet, lEstendido );
   WriteLog('sigaloja.log', 'Bematech_FI_RetornoAliquotas (79) <- Retorno :' + IntToStr(iRet));
   lErro := False;
  Except on E:Exception do
    begin
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (79) <- ' + E.className + ' Erro :' + E.message);
     lErro := True;
    end;
  End;

  If lErro Then
  begin
    Try
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) -> ');
     sRet := Space( 80 );
     iRet := fFuncBematech_FI_RetornoAliquotas( sRet );
     TrataRetornoBematech( iRet, lEstendido );
     WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) <- Retorno :' + IntToStr(iRet));
     lErro := False;
    Except on E:Exception do
      begin
       WriteLog('sigaloja.log','Bematech_FI_RetornoAliquotas (80) <- ' + E.className + ' Erro :' + E.message);
       lErro := True;
      end;
    End;
  End;
  
  If iRet = 1 then
  begin
    sICMS := Trim( StrTran( sRet, ',', '|' ) );
    While Length(sICMS)>0 do
    begin
      sAliq := Copy(sICMS,1,2)+','+Copy(sICMS,3,2);
      ICMS  := ICMS + FormataTexto(sAliq,5,2,1) + '|';
      sICMS := Copy(sICMS,6,Length(sICMS));
    end;
    CargaIndiceAliq()
  end
  Else
    exit;

  // Retorno do Numero do Caixa (PDV)
  sRet := Space ( 4 );
  iRet := fFuncBematech_FI_NumeroCaixa( sRet );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
  begin
    If Pos(#0,sRet) > 0 then
      Pdv := Copy(sRet,1,Pos(#0,sRet)-1)
    Else
      Pdv := Copy(sRet,1,4);
  end
  Else
    exit;

  // Retorno da Versão do Firmware (Eprom)
  sRet := Space( 4 );
  iRet := fFuncBematech_FI_VersaoFirmware( sRet );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
    Eprom := Copy(sRet,1,Pos(#0,sRet)-1)
  Else
    exit;

  // Retorna o CNPJ
  // Retorna a IE
  iRet := fFuncBematech_FI_CGC_IE( Cnpj, Ie );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet <> 1 then
    exit;

  // Retorna o Numero da loja cadastrado no ECF
  iRet := fFuncBematech_FI_NumeroLoja( NumLoja );
  NumLoja := Trim( NumLoja );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet <> 1 then
    exit;

  // Retorna o Numero da Serie - Rotina compatível com MP-25, conforme convenio 8501.
  iRet := fFuncBematech_FI_NumeroSerieMFD( NumSerie );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
    NumSerie := Trim( NumSerie )
  Else
    exit;


  // Retorna o Tipo do ECF
  TipoEcf := 'ECF-IF';

  // Retorna Marca do ECF
  MarcaEcf := sMarca;

  // Retorna Modelo do ECF
  iRet := fFuncBematech_FI_ModeloImpressora( ModeloEcf );
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
    ModeloEcf := Trim( ModeloEcf )
  Else
    exit;

  // Retorna Data de gravação do último usuário da impressora
  // Retorna Hora de gravação do último usuário da impressora
  // Retorna Data de Instalação da Eprom
  // Retorna Hora de Instalação da Eprom
  // Retorna Letra indicativa de MF adicional
  { RETORNA ERRO SE FEITO NA INICIALIZACAO
  iRet := fFuncBematech_FI_DataHoraGravacaoUsuarioSWBasicoMFAdicional( sAuxDtU, sAuxDtS, sAuxMfA);
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    DataGrvUsuario := StrTran( Copy( sAuxDtU, 1, 10 ), '/', '');
    HoraGrvUsuario := StrTran( Copy( sAuxDtU, 12, 8 ), ':', '');
    DataIntEprom := StrTran( Copy( sAuxDtS, 1, 10 ), '/', '');
    HoraIntEprom := StrTran( Copy( sAuxDtS, 12, 8 ), ':', '');
    IndicaMFAdi  := sAuxMfA;
  end
  Else
    exit;
  }

  // Retorna Contador de Reinicio de Operação
  // Retorna Contador de ReduçãoZ
  iRet := fFuncBematech_FI_RegistrosTipo60();
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
  begin
    ContadorCro := LeArqRetorno( Path, sArqIniBema, 49, 6 );
    ContadorCrz := LeArqRetorno( Path, sArqIniBema, 55, 3 );
  end
  Else
    exit;

  //Retorna o Grande Total Inicial
  //Retorna o Grande Total Final
  //Retorna a Venda Bruta Diaria
  iRet := fFuncBematech_FI_RegistrosTipo60();
  TrataRetornoBematech( iRet, lEstendido );
  If iRet = 1 then
  begin
    VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
    GTFinal       := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
    GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );
  end
  Else
    exit;

end;

//--------------------------------------------------------------------------------
function TImpBematech2000.RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer  ; ImgQrCode: String) : String;
Var
  iRet,i,nPos: Integer;
  cTextoImpAux,sIndTot  : String;
  bImprime        : Boolean;
  sLista          : TStringList;
begin
  //*******************************************************************************
  // Inicialização das variaveis
  //*******************************************************************************
  Result      := '1';
  bImprime    := True;

  cIndTotalizador :=  Trim(cIndTotalizador);
  Val(cIndTotalizador,i,nPos);

  If i > 0
  then sIndTot := FormataTexto(IntToStr(i),2,0,1)
  else
     //caso haja algum problema manda o gerencial padrão
     sIndTot := '01';

  If bImprime then
  begin
    sLista := TStringList.Create;
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

     For i:=1 to nVias do
     Begin
         GravaLog(' AbreRelatorioGerencial ->');
         iRet := fFuncBematech_FI_AbreRelatorioGerencialMFD( pChar(sIndTot) );
         GravaLog(' AbreRelatorioGerencial <- iRet: ' + IntToStr(iRet));
         TrataRetornoBematech( iRet, True );
         If (iRet = 0) then
         Begin
           Result := '1';
           Exit;
         End;

         For nPos := 0 to sLista.Count-1 do
            iRet := fFuncBematech_FI_UsaRelatorioGerencialMFD( pChar(sLista.Strings[nPos]));   //O Limite do comando são 618 caracteres por envio

         GravaLog(' UsaRelatorioGerencialMFD <- iRet: ' + IntToStr(iRet));

         TrataRetornoBematech( iRet );
         If (iRet = 0) then
         Begin
           Result := '1';
           Exit;
         End;

        GravaLog(' -> FechaRelatorioGerencial' );
        iRet:= fFuncBematech_FI_FechaRelatorioGerencial;
        GravaLog(' <- FechaRelatorioGerencial : ' + IntToStr(iRet) );
        TrataRetornoBematech(iRet, True);

        If iRet = 1
        then Result := '0'
        Else Result := '1';
    End;

    //*******************************************************************************
    // Mostrar mensagem de erro se necessário
    //*******************************************************************************
    If Result = '1' then
      TrataRetornoBematech( iRet );

  end
  Else
  begin
    //*******************************************************************************
    // Mostrar mensagem de erro caso os totalizadores não tenham sido encontrados
    //*******************************************************************************
    LjMsgDlg('O Relatorio Gerencial ' + Trim(cIndTotalizador) + ' não existe no ECF. ');

    Result := '1';
  end;
end;

//------------------------------------------------------------------------------
Function TrataTags( Mensagem : String ) : String;
var
  cMsg : String;
begin
cMsg := Mensagem;

while Pos('<B>', cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<B>',sTagNegritoIni,[]);
   cMsg := StringReplace(cMsg,'</B>',sTagNegritoFim,[]);
end;

while Pos('<E>',cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<E>',sTagExpandidoIni,[]);
   cMsg := StringReplace(cMsg,'</E>',sTagExpandidoFim,[]);
end;

While Pos('<I>',cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<I>',sTagItalicoIni,[]);
   cMsg := StringReplace(cMsg,'</I>',sTagItalicoFim,[]);
end;

while Pos('<C>',cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<C>',sTagCondensadoIni,[]);
   cMsg := StringReplace(cMsg,'</C>',sTagCondensadoFim,[]);
end;

cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//------------------------------------------------------------------------------
function TImpBematech6000.GeraArquivoMFD(cDadoInicial, cDadoFinal,
  cTipoDownload, cUsuario: string; iTipoGeracao: integer; cChavePublica,
  cChavePrivada: string; iUnicoArquivo: integer): String;
var
   iRet : Integer;
   sNomeArq: String;
   sNumSerie2: String;
   sPath: String; //Caminho onde o ECF gera os arquivos
   sTipo: String; //Tipo do DownloadMFD( 1 = Data, 2 = Coo )
Const
   sArquivo = 'DOWNLOAD.MFD';
   sUsuario = '1' ;    // Usuario do movimento
begin
  // Pega caminho onde grava os arquivos da bemafi32.ini(DOWNLOAD.MFD)
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  //Pega número de série para compor o nome do arquivo gerado pelo ECF
  sNumSerie2 := PegaSerie;
  sNumSerie2 := Copy(sNumSerie2,3,Length(sNumSerie2)-2);

  //Formata Nome do arquivo que será gerado pelo ECF: Numero de Série + DadoInicial + _ + DadoFinal + .TXT, quando por data o formato será ddMMyy
  If cTipoDownload = 'D' Then
  Begin
    sTipo     := '1';
    sNomeArq  := sNumSerie2 + '_' + FormatDateTime('ddMMyy', StrToDate(cDadoInicial)) + '_' + FormatDateTime('ddMMyy', StrToDate(cDadoFinal)) + '.TXT';
  End
  Else
  Begin
    //Compativel apenas por Data
    MessageDlg( MsgIndsImp, mtError,[mbOK],0);
    Exit;
  End;

  //Gera arquivo Download.MFD necessário para a function GeraArquivoMFD
  GravaLog(' Bematech_FI_DownloadMFD -> Arquivo:' + sPath + sArquivo + ', Tipo: ' + sTipo +
           ', DadoIni:' + cDadoInicial + ', DadoFim:' + cDadoFinal + ', Usuario:' + sUsuario);
  iRet := fFuncBematech_FI_DownloadMFD( sPath + sArquivo, sTipo, cDadoInicial, cDadoFinal, sUsuario );
  GravaLog(' Bematech_FI_DownloadMFD <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet );

  //Remove barra, comando espera data sem barra
  cDadoInicial := SubstituiStr(cDadoInicial, '/', '');
  cDadoFinal   := SubstituiStr(cDadoFinal, '/', '');

  //Chama função para criação do arquivo Ato Cotepe 1704, conforme esperado no roteiro de testes do PAF-ECF versão 1.4
  If iRet = 1 Then
  Begin
      GravaLog(' BemaGeraRegistrosTipoEMFD1 -> Arquivo: ' + sPath + sArqDownMFD + ', ArqTXT:' +
                sPath + sNomeArq + ', DadoIni:' + cDadoInicial + ',DadoFim:' + cDadoFinal);
      iRet := fFuncBemaGeraRegistrosTipoEMFD1( sPath + sArqDownMFD  ,
                                   pchar( sPath + sNomeArq ) ,
                                   cDadoInicial,
                                   cDadoFinal,
                                   '' ,
                                   '' ,
                                   '' ,
                                   '2',
                                   '' , '', '', '', '', '', '', '', '', '', '', '', '' );
      GravaLog(' BemaGeraRegistrosTipoEMFD1 <- iRet:' + IntToStr(iRet));
  End;

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpBematech7000.GeraArquivoMFD(cDadoInicial, cDadoFinal,
  cTipoDownload, cUsuario: string; iTipoGeracao: integer; cChavePublica,
  cChavePrivada: string; iUnicoArquivo: integer): String;
var
   iRet : Integer;
   sNomeArq: String;
   sNumSerie2: String;
   sPath: String; //Caminho onde o ECF gera os arquivos
   sTipo: String; //Tipo do DownloadMFD( 1 = Data, 2 = Coo )
Const
   sArquivo = 'DOWNLOAD.MFD';
   sUsuario = '1' ;    // Usuario do movimento
begin
  // Pega caminho onde grava os arquivos da bemafi32.ini(DOWNLOAD.MFD)
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  //Pega número de série para compor o nome do arquivo gerado pelo ECF
  sNumSerie2 := PegaSerie;
  sNumSerie2 := Copy(sNumSerie2,3,Length(sNumSerie2)-2);

  //Formata Nome do arquivo que será gerado pelo ECF: Numero de Série + DadoInicial + _ + DadoFinal + .TXT, quando por data o formato será ddMMyy
  If cTipoDownload = 'D' Then
  Begin
    sTipo     := '1';
    sNomeArq  := sNumSerie2 + '_' + FormatDateTime('ddMMyy', StrToDate(cDadoInicial)) + '_' + FormatDateTime('ddMMyy', StrToDate(cDadoFinal)) + '.TXT';
  End
  Else
  Begin
    //Compativel apenas por Data
    MessageDlg( MsgIndsImp, mtError,[mbOK],0);
    Exit;
  End;

  //Gera arquivo Download.MFD necessário para a function GeraArquivoMFD
  GravaLog(' Bematech_FI_DownloadMFD -> Arquivo:' + sPath + sArquivo + ', Tipo: ' + sTipo +
           ', DadoIni:' + cDadoInicial + ', DadoFim:' + cDadoFinal + ', Usuario:' + sUsuario);
  iRet := fFuncBematech_FI_DownloadMFD( sPath + sArquivo, sTipo, cDadoInicial, cDadoFinal, sUsuario );
  GravaLog(' Bematech_FI_DownloadMFD <- iRet:' + IntToStr(iRet));
  TrataRetornoBematech( iRet );

  //Remove barra, comando espera data sem barra
  cDadoInicial := SubstituiStr(cDadoInicial, '/', '');
  cDadoFinal   := SubstituiStr(cDadoFinal, '/', '');

  //Chama função para criação do arquivo Ato Cotepe 1704, conforme esperado no roteiro de testes do PAF-ECF versão 1.4
  If iRet = 1 Then
  Begin
      GravaLog(' BemaGeraRegistrosTipoEMFD2 -> Arquivo: ' + sPath + sArqDownMFD + ', ArqTXT:' +
                sPath + sNomeArq + ', DadoIni:' + cDadoInicial + ',DadoFim:' + cDadoFinal);
      iRet := fFuncBemaGeraRegistrosTipoEMFD2( sPath + sArqDownMFD  ,
                                   pchar( sPath + sNomeArq ) ,
                                   cDadoInicial,
                                   cDadoFinal,
                                   '' ,
                                   '' ,
                                   '' ,
                                   '2',
                                   '' , '', '', '', '', '', '', '', '', '', '', '', '' );
      GravaLog(' BemaGeraRegistrosTipoEMFD2 <- iRet:' + IntToStr(iRet));
  End;

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//------------------------------------------------------------------------------
Procedure CancelaCNF;
var
  iRet : Integer;
begin
  GravaLog('Bematech_FI_CancelaCupom -> Cancelamento do Comprovante/Cupom');
  iRet := fFuncBematech_FI_CancelaCupom();
  GravaLog('Bematech_FI_CancelaCupom <- iRet :' + IntToStr(iRet));
end;

//------------------------------------------------------------------------------
function TImpBematech2000.AbreCNF(CPFCNPJ, Nome, Endereco: String): String;
var
  iRet : Integer;
begin
GravaLog('Bematech_FI_AbreRecebimentoNaoFiscalMFD -> CPFCNPJ : ' + CPFCNPJ + ' ,Nome : ' + Nome +',Endereco : ' + Endereco);
iRet := fFuncBematech_FI_AbreRecebimentoNaoFiscalMFD(CPFCNPJ,Nome,Endereco);
GravaLog('Bematech_FI_AbreRecebimentoNaoFiscalMFD <- iRet : ' + IntToStr(iRet));
TrataRetornoBematech( iRet );

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//------------------------------------------------------------------------------
function TImpBematech2000.FechaCNF(Mensagem: String): String;
var
  iRet : Integer;
begin

GravaLog('Bematech_FI_FechaRecebimentoNaoFiscalMFD ->');
iRet := fFuncBematech_FI_FechaRecebimentoNaoFiscalMFD(Copy(Mensagem,1,489));
GravaLog(' Bematech_FI_FechaRecebimentoNaoFiscalMFD <- iRet: ' + IntToStr(iRet));
TrataRetornoBematech(iRet);

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//------------------------------------------------------------------------------
function TImpBematech2000.PgtoCNF(FrmPagto, Valor, InfoAdicional,
  ValorAcresc, ValorDesc: String): String;
var
  iRet : Integer;
  cTipoAD,VlrAc,VlrDesc,sFrmPag,sVlrPag : String;
begin

iRet    := 1;
cTipoAD := '';
VlrAc   := '';
VlrDesc := '';

GravaLog('-> Bematech_FI_SubTotalizaRecebimentoMFD');
iRet := fFuncBematech_FI_SubTotalizaRecebimentoMFD();
GravaLog('<- Bematech_FI_SubTotalizaRecebimentoMFD :' + IntToStr(iRet));
TrataRetornoBematech( iRet );

//Descontos e acrescimos serão dados baseados no valor
If (Trim(ValorDesc) <> '') and (Trim(ValorDesc) <> '0') then
begin
  cTipoAD := 'D';
  VlrAc   := '';
  VlrDesc := ValorDesc;
end
else If (Trim(ValorAcresc) <> '') and (Trim(ValorAcresc) <> '0') then
     begin
       cTipoAD := 'A';
       VlrAc   := ValorAcresc;
       VlrDesc := '';
     end;

if (iRet = 1) and (cTipoAD <> '') then
begin
  GravaLog('-> Bematech_FI_IniciaFechamentoRecebimentoNaoFiscalMFD');
  iRet := ffuncBematech_FI_IniciaFechamentoRecebimentoNaoFiscalMFD(cTipoAD,'$',VlrAc,VlrDesc);
  GravaLog('<- Bematech_FI_IniciaFechamentoRecebimentoNaoFiscalMFD :' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
end;

If iRet = 1 then
begin
  GravaLog(' -> Bematech_FI_TotalizaRecebimentoMFD');
  iRet := fFuncBematech_FI_TotalizaRecebimentoMFD();
  GravaLog(' <- Bematech_FI_TotalizaRecebimentoMFD : ' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
End;

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

    If ValidaFrmPgto4200(sFrmPag , iRet ) then
    begin
      GravaLog('-> Bematech_FI_EfetuaFormaPagamentoMFD');
      iRet := fFuncBematech_FI_EfetuaFormaPagamentoMFD(Copy(sFrmPag,1,16) ,sVlrPag,'1',InfoAdicional);
      GravaLog('<- Bematech_FI_EfetuaFormaPagamentoMFD :' + IntToStr(iRet));
      TrataRetornoBematech( iRet );
    end
    else
      iRet := 0;
  end;
end;

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//------------------------------------------------------------------------------
function TImpBematech2000.RecCNF(IndiceTot, Valor, ValorAcresc,
  ValorDesc: String): String;
var
   iRet : Integer;
begin

GravaLog(' Bematech_FI_EfetuaRecebimentoNaoFiscalMFD -> IndiceTot :' + IndiceTot + ', Valor : ' + Valor);
iRet := fFuncBematech_FI_EfetuaRecebimentoNaoFiscalMFD(IndiceTot,Valor);
GravaLog('<- Bematech_FI_EfetuaRecebimentoNaoFiscalMFD :' + IntToStr(iRet));
TrataRetornoBematech(iRet);

If iRet = 1
then Result := '0|'
else Result := '1|';
end;

//------------------------------------------------------------------------------
//----------------------------------------------------------------------------
{
function TImpBematech2000.LeTotNFisc:String;
 //Inicio função Estática RetornaIndiceTot
 function RetornaIndiceTot(sRelGerenciais : String ; PosTotalizador : Integer) : String;
   var
     sRet,sAux : String;
     nCont,nQtdeVirg,nPosVirg: Integer;
   begin
     sRet      := '01';
     nCont     := 0 ;
     nQtdeVirg := 0;
     sAux      := sRelGerenciais ;
     while nCont < PosTotalizador do
     begin
       nPosVirg := Pos(',',sAux);
       StringReplace(sAux,',','|',[]);
       If nPosVirg > 0 then
       begin
        Inc(nQtdeVirg);
        nCont := nCont + nPosVirg;
       end;
     end;

     If nQtdeVirg > 0
     then sRet := FormataTexto(IntToStr(nQtdeVirg),2,0,1);

     Result := sRet;
   end;
   //final Função Estática Retona Indice Tot


var
  iRet, i , iPos, iCont : Integer;
  sRet, sAux : String;
  sTotaliz : String;
begin
  sRet := Space(600);
  GravaLog(' Bematech_FI_VerificaTotalizadoresNaoFiscaisMFD -> ');
  iRet := fFuncBematech_FI_VerificaTotalizadoresNaoFiscaisMFD( sRet );
  GravaLog(' Bematech_FI_VerificaTotalizadoresNaoFiscaisMFD <- iRet : ' + IntToStr(iRet));

  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    sRet := Trim(sRet);
    sTotaliz := '';
    iPos := Pos(',', sRet);
    sAux := sRet;
    iCont := 0;
    If iPos = 0 then iPos := Length(sRet);
    while iPos > 0 do
     begin
       sAux := Copy(sRet, 1, iPos-1);
       sRet := Copy(sRet, iPos+1, length(sRet)-iPos) ;
       iPos := Pos(',', sRet);
       If iPos = 0 then iPos := Length(sRet);
       Inc(iCont);
       sTotaliz := sTotaliz + FormataTexto( IntToStr(iCont), 2, 0, 4) + ',' + sAux + '|';

     end;

    Result := '0|' + sTotaliz;
  end
  Else
    Result := '1';
end; }


//****************************************************************************//
{ TImpBematech4200 }
//****************************************************************************//
function ValidaFrmPgto4200( var Condicao : String ; var iIndice : Integer): Boolean;
var
  sFormas,sPgto,sLinha : String;
  iRet,iTam : Integer;
  bAchou: Boolean;
begin
  bAchou := False;
  sFormas := Space(920);
  GravaLog(' Bematech_FI_VerificaFormasPagamentoMFD -> ');
  iRet :=  fFuncBematech_FI_VerificaFormasPagamentoMFD( sFormas );
  GravaLog(' Bematech_FI_VerificaFormasPagamentoMFD <- iRet: ' + IntToStr(iRet));
  TrataRetornoBematech(iRet,True);

  GravaLog(' TrataRetornoBematech -> iRet : ' + IntToStr(iRet));
  sFormas := Trim(sFormas);
  GravaLog(' Formas Cadastradas : ' + sFormas);
  GravaLog(' Condição : ' + Condicao );

  If iRet = 1 then
  begin
    iIndice := 0;

    while Trim(sFormas) <> '' do
    begin
      Inc(iIndice);

      iTam := Pos(',',sFormas);

      If iTam = 0
      then iTam := Length(sFormas);

      sLinha := Copy(sFormas,1,iTam);
      sFormas:= Copy(sFormas,iTam+1,Length(sFormas));
      sPgto  := Trim(Copy(sLinha,1,16));

      If LowerCase(Trim(sPgto)) = LowerCase(Trim(Copy(Condicao,1,16))) then
      begin
       Condicao := sPgto;
       bAchou   := True;
       Result   := True;
       Break;
      end;
    end;
  end;

  If bAchou = False then
  begin
   GravaLog(' Forma de Pagamento '+ Condicao + ' não cadastrada na ECF ');
   LjMsgDlg(' Forma de Pagamento '+ Condicao + ' não cadastrada na ECF ');
   Condicao := '';
   Result := False;
  end;
end;

//------------------------------------------------------------------------------
function TImpBematech4200.AbreCNF(CPFCNPJ, Nome, Endereco: String): String;
var
  iRet : Integer;
begin
GravaLog('Bematech_FI_AbreRecebimentoNaoFiscalCV0909 -> CPFCNPJ : ' + CPFCNPJ + ' ,Nome : ' + Nome +',Endereco : ' + Endereco);
iRet := fFuncBematech_FI_AbreRecebimentoNaoFiscalCV0909(Trim(CPFCNPJ),Trim(Nome),Trim(Endereco));
GravaLog('Bematech_FI_AbreRecebimentoNaoFiscalCV0909 <- iRet : ' + IntToStr(iRet));
TrataRetornoBematech( iRet );

If iRet = 1
then Result := '0|'
else Result := '1|';
end;

//------------------------------------------------------------------------------
function TImpBematech4200.AbreCupomNaoFiscal(Condicao, Valor, Totalizador,
  Texto: String): String;
var
  iRet,iIndForma : Integer;
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
//  A forma de pagamento utilizada no comprovante vinculado não pode ser "Dinheiro",
// mas pode ser "DINHEIRO".
  Condicao := Copy( Condicao, 1, 16 );

  GravaLog(' AbreCupomNaoFiscal -> Condicao :' + Condicao + ' , Valor :' + Valor
           + ', Totalizador :' + Totalizador + ', Texto:' + Texto);

  iRet      := 0;
  iIndForma := 0;
  ValidaFrmPgto4200( Condicao , iIndForma);

  If Condicao = ''
  then Result := '1'
  else
  begin
    //*******************************************************************************
    // Abre o comprovante não fiscal. Tenta abrir um vinculado mas caso não consiga
    // faz um recebimento não fiscal para depois abrir o comprovante não fiscal
    // Condicao = Descricao da Forma de pagamento - Nao pode ser DINHEIRO
    //*******************************************************************************
    Status_Impressora( False, True );
    GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado -> ' + Condicao );
    iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( Condicao , '', '' );
    GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
    If iRet <> 0 then
    Begin
      If Status_Impressora( False, True ) = 1
      then Result := '0'
      Else
      begin
         //*******************************************************************************
         // Faz um recebimento não fiscal para abrir o cupom vinculado
         //*******************************************************************************
         GravaLog(' Bematech_FI_RecebimentoNaoFiscal ->');
         iRet := fFuncBematech_FI_RecebimentoNaoFiscal( pchar(Totalizador), pchar(Valor), pchar(Condicao) );
         GravaLog(' Bematech_FI_RecebimentoNaoFiscal <- iRet :' + IntToStr(iRet));
         If Status_Impressora( False, True ) = 1 then
         begin
            //*******************************************************************************
            // Abre o comprovante vinculado
            //*******************************************************************************
            GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado -> ');
            iRet := fFuncBematech_FI_AbreComprovanteNaoFiscalVinculado( Condicao, '', '' );
            GravaLog(' Bematech_FI_AbreComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
            TrataRetornoBematech( iRet );
            If Status_Impressora( False, True ) = 1 then
            begin
              If iRet = 1
              then Result := '0'
              Else Result := '1';
            end;
         end
         Else
            Result := '1';
      end;
    End
    Else
      Result := '1';
  end;

  //*******************************************************************************
  // Se apresentou algum erro monstra a mensagem
  //*******************************************************************************
  If Result = '1'
  then TrataRetornoBematech( iRet );
end;

//------------------------------------------------------------------------------
procedure TImpBematech4200.AlimentaProperties;
     //************************************************************************
     //De acordo com o suporte bematech o INI não pode ser alterado senão
     //tenho erro de arquivo, portanto a configuração deve ser feita de maneira
     //externa, ou seja, deve ser pré-configurado, antes de acessar o sistema
     //************************************************************************
    (*Procedure CargaIndiceAliq();
    var i, iCont : Integer;
        sAlqIni, sISS, sICMS, sTipo : String;
        fArquivo : TIniFile;
    begin
      sICMS := ICMS;
      i := 1;
      sTipo := 'T';
      fArquivo    := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\' + sArqIniBema);

      //Segundo o suporte da Bematech para usar o índice,
      //eu devo alterar o .INI da seguinte maneira:
      //[Aliquotas]
      //Aliquota01=XXXX_A , onde XXXX é o valor da aliquota e A
      // é o tipo que pode ser T para ICMS e S para ISS

      //Alíquotas de ICMS  ( 1 a 30 ) ; Alíquotas de ISS ( 31 a 60 )
      For iCont := 1 to 60 do
      begin
        If StrToFloat(Copy(sICMS,1, Pos('|', sICMS)-1)) > 0 then
        begin
          SetLength(aIndAliq,Length(aIndAliq)+2);
          aIndAliq[Length(aIndAliq)-2] := FormataTexto(IntToStr(i),2,0,2);
          aIndAliq[Length(aIndAliq)-1] := sTipo + Copy(sICMS,1, Pos('|', sICMS)-1);
          sAlqIni := StringReplace(Copy(sICMS,1, Pos('|', sICMS)-1),'.','',[]) + '_' + sTipo;

          //Configuro o INI de acordo com as alíquotas cadastradas
          fArquivo.WriteString('Aliquotas','Aliquota' + aIndAliq[Length(aIndAliq)-2],sAlqIni);

          Inc(i);
        end;

        sICMS := Copy(sICMS,Pos('|', sICMS)+1, Length(sICMS));

        if iCont = 30
        then sTipo := 'S';
      end;

      fArquivo.Free;
    End;
    *)
var
  iRet : Integer;
  sRet, sICMS, sISS, sAliq,sDadosUltZ : String;
  lErro : Boolean;
  aDadosUltZ : TaString;
begin
  // Inicalização de propriedades
  ICMS  := '';
  ISS   := '';
  Pdv   := '';
  Eprom := '';
  Cnpj  := Space(19);
  Ie    := Space(16);
  NumLoja   := Space(5);
  NumSerie  := Space(20);
  TipoEcf   := Space(8);
  MarcaEcf  := Space(16);
  ModeloEcf := Space(21);
  IndicaMFAdi  := '';
  DataIntEprom := '';
  HoraIntEprom := '';
  ContadorCro  := '';
  ContadorCrz  := '';
  GTInicial    := '';
  GTFinal      := '';
  VendaBrutaDia:= '';
  ReducaoEmitida := False;
  lError := False;

  //Log da Versão da DLL do Fabricante
  sRet := Space(9);
  GravaLog(' Bematech_FI_VersaoDll -> ');
  iRet := fFuncBematech_FI_VersaoDll( sRet );
  GravaLog(' Bematech_FI_VersaoDll <- Retorno: iRet [' + IntToStr(iRet) + '] - Versão:' + Trim(sRet));

  // Retorno de Aliquotas ( ISS )
  try
   GravaLog('Bematech_FI_VerificaAliquotasIss (80) -> ');
   sRet := Space( 80 );
   iRet := fFuncBematech_FI_VerificaAliquotasIss( sRet );
   TrataRetornoBematech( iRet );
   GravaLog('Bematech_FI_VerificaAliquotasIss (80) <- Retorno :' + IntToStr(iRet));
   lErro := False;
  Except on E:Exception do
    begin
     GravaLog('Bematech_FI_VerificaAliquotasIss (80) <- ' + E.className + ' Erro :' + E.message);
     lErro := True;
    end;
  End;

  If iRet = 1 then
  begin
    sISS := Trim( StrTran( sRet, ',', '|' ) );
    While Length(sISS)>0 do
    begin
      sAliq := Copy(sISS,1,2)+','+Copy(sISS,3,2);
      ISS   := ISS + FormataTexto(sAliq,5,2,1) +'|';
      sISS  := Copy(sISS,6,Length(sISS));
    end
  end
  Else
    exit;

  // Retorno de Aliquotas ( ICMS )
  GravaLog('Bematech_FI_RetornoAliquotasCV0909 (299) -> ');
  sRet := Space( 299 );
  iRet := fFuncBematech_FI_RetornoAliquotasCV0909( sRet );
  TrataRetornoBematech( iRet );
  GravaLog('Bematech_FI_RetornoAliquotasCV0909 (299) <- Retorno :' + IntToStr(iRet));
  lErro := False;

  If iRet = 1 then
  begin
    sICMS := Trim( StrTran( sRet, ',', '|' ) );
    While Length(sICMS)>0 do
    begin
      sAliq := Copy(sICMS,1,2)+','+Copy(sICMS,3,2);
      ICMS  := ICMS + FormataTexto(sAliq,5,2,1) + '|';
      sICMS := Copy(sICMS,6,Length(sICMS));
    end;
    //CargaIndiceAliq() - comentario na declaração dessa função
  end
  Else
    exit;

  // Retorno do Numero do Caixa (PDV)
  GravaLog('Bematech_FI_NumeroCaixa ->');
  sRet := Space ( 4 );
  iRet := fFuncBematech_FI_NumeroCaixa( sRet );
  GravaLog('Bematech_FI_NumeroCaixa <- iRet :' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  If iRet = 1 then
  begin
    If Pos(#0,sRet) > 0
    then Pdv := Copy(sRet,1,Pos(#0,sRet)-1)
    Else Pdv := Copy(sRet,1,4);
  end
  Else
    exit;

  // Retorno da Versão do Firmware (Eprom)
  sRet := Space( 6 );
  GravaLog('Bematech_FI_VersaoFirmwareCV0909 ->');
  iRet := fFuncBematech_FI_VersaoFirmwareCV0909( sRet );
  GravaLog('Bematech_FI_VersaoFirmwareCV0909 <- iRet :' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  If iRet = 1
  then Eprom := Copy(sRet,1,6)
  Else exit;

  // Retorna o CNPJ , IE
  GravaLog(' Bematech_FI_CNPJMFD ');
  Cnpj := Space(21);
  iRet := fFuncBematech_FI_CNPJMFD(Cnpj);
  GravaLog('Bematech_FI_CNPJMFD <- iRet :' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  Cnpj := Copy(Cnpj,1,20);

  if iRet <> 1
  then Exit;

  GravaLog(' Bematech_FI_InscricaoEstadualMFD ');
  Ie := Space(21);
  iRet := fFuncBematech_FI_InscricaoEstadualMFD(Ie);
  GravaLog(' Bematech_FI_InscricaoEstadualMFD <- iRet: ' + IntToStr(iRet));
  TrataRetornoBematech(iRet);
  Ie := Copy(Ie,1,20);

  if iRet <> 1
  then Exit;

  // Retorna o Numero da loja cadastrado no ECF
  GravaLog('Bematech_FI_NumeroLoja ->');
  iRet := fFuncBematech_FI_NumeroLoja( NumLoja );
  GravaLog('Bematech_FI_NumeroLoja <- iRet :' + IntToStr(iRet));
  NumLoja := Trim( NumLoja );
  TrataRetornoBematech( iRet );
  If iRet <> 1
  then  exit;

  // Retorna o Numero da Serie
  GravaLog('Bematech_FI_NumeroSerieCV0909 ->');
  iRet := fFuncBematech_FI_NumeroSerieCV0909( NumSerie );
  GravaLog('Bematech_FI_NumeroSerieCV0909 <- iRet :' + IntToStr(iRet));
  NumSerie := Trim( NumSerie );
  TrataRetornoBematech( iRet );
  If iRet <> 1
  then exit;

  // Retorna Modelo do ECF
  GravaLog('Bematech_FI_MarcaModeloTipoImpressoraMFD ->');
  iRet := fFuncBematech_FI_MarcaModeloTipoImpressoraMFD(MarcaEcf,ModeloEcf,TipoEcf);
  GravaLog('Bematech_FI_MarcaModeloTipoImpressoraMFD <- iRet :' + IntToStr(iRet));
  TrataRetornoBematech( iRet );
  If iRet = 1
  then begin
         MarcaEcf  := Copy( MarcaEcf ,1, 15);
         ModeloEcf := Copy( ModeloEcf ,1,20 );
         TipoEcf   := Copy( TipoEcf ,1,7);
       end
  Else exit;

  // Retorna Contador de Reinicio de Operação
  // Retorna Contador de ReduçãoZ
  sDadosUltZ := Space(1200);
  GravaLog(' Bematech_FI_DadosUltimaReducaoCV0909 -> ');
  iRet := fFuncBematech_FI_DadosUltimaReducaoCV0909( sDadosUltZ );
  GravaLog(' Bematech_FI_DadosUltimaReducaoCV0909 <- iRet : ' + IntToStr(iRet));
  sDadosUltZ := StrTran( sDadosUltZ, ',', '|' );
  MontaArray( sDadosUltZ, aDadosUltZ );
  TrataRetornoBematech( iRet , True);
  //Verifica pois no Emulador da 4200 não retorna certo
  If (iRet = 1) And (Uppercase(Copy(sDadosUltZ,1,5)) <> 'ERRO:') then
  begin
    ContadorCrz  := aDadosUltZ[0];
    ContadorCro  := aDadosUltZ[3];
  end
  Else If iRet = 1 then
       begin
         ContadorCro := '0';
         ContadorCrz := '0';
       end
       Else
         exit;

  GravaLog(' <- AlimentaProperties - CRO: '+ContadorCro+' / CRZ: '+ContadorCrz );
  GravaLog(' -> AlimentaProperties - RETORNA GT INICIAL / GT FINAL / VENDA BRUTA DIARIA' );

  //Retorna o Grande Total Inicial
  //Retorna o Grande Total Final
  //Retorna a Venda Bruta Diaria
  If (Uppercase(Copy(sDadosUltZ,1,5)) <> 'ERRO:') then
  begin
    GravaLog(' AlimentaProperties - Bematech_FI_RegistrosTipo60 -> ');
    Try
      iRet := fFuncBematech_FI_RegistrosTipo60();
    except
      iRet := -999;
    end;

    If iRet = -999
    then begin
           GravaLog(' <- AlimentaProperties - Bematech_FI_RegistrosTipo60: '+IntToStr(-999));
           iRet := 1;
         end
    else GravaLog(' <- AlimentaProperties - Bematech_FI_RegistrosTipo60: '+IntToStr(iRet));
    TrataRetornoBematech( iRet, True );
    GravaLog(' <- AlimentaProperties - TrataRetornoBematech' );

    If iRet = 1 then
    begin
      GravaLog(' <- AlimentaProperties - VendaBrutaDia' );
      VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
      GravaLog(' <- AlimentaProperties - VendaBrutaDia: '+VendaBrutaDia );
      GravaLog(' <- AlimentaProperties - GTFinal' );
      GTFinal       := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
      GravaLog(' <- AlimentaProperties - GTFinal: '+GTFinal );
      GravaLog(' <- AlimentaProperties - GTInicial' );
      GTInicial := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ));
      GravaLog(' <- AlimentaProperties - VendaBrutaDia: '+VendaBrutaDia+' / GTFinal: '+GTFinal+' / GTInicial: '+GTInicial );
    end
    Else
      Exit;

  end
  else
  begin
    iRet := 1;
    GravaLog(' <- AlimentaProperties - VendaBrutaDia' );
    VendaBrutaDia := '0';
    GravaLog(' <- AlimentaProperties - VendaBrutaDia: '+VendaBrutaDia );
    GravaLog(' <- AlimentaProperties - GTFinal' );
    GTFinal       := '0';
    GravaLog(' <- AlimentaProperties - GTFinal: '+GTFinal );
    GravaLog(' <- AlimentaProperties - GTInicial' );
    GTInicial := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ));
    GravaLog(' <- AlimentaProperties - VendaBrutaDia: '+VendaBrutaDia+' / GTFinal: '+GTFinal+' / GTInicial: '+GTInicial );
  End;
end;

//------------------------------------------------------------------------------
function TImpBematech4200.DownloadMFD(sTipo, sInicio, sFinal: String): String;
Var
  sArquivo : String;    // Arquivo de download da MFD
  sUsuario : String;    // Usuario do movimento
  sDestino : String;    // Arquivo de destino depois de convertido
  iRet     : Integer;   // Retorno da dll
  sPath    : String;    // String onde foi gerado o arquivo pela Bematech
  sNewTipo : String;
Begin
  Result := '1';
  sArquivo := 'DOWNLOAD.MFD';
  sDestino := 'DOWNLOAD.TXT';
  sUsuario := '1';

  //O Protheus manda dados padrão mas para esse modelo de ECF a variável sTipo
  //tem conteudos diferentes, portanto faço tratamento abaixo de acordo com
  //o manual do fabricante
  if sTipo = '1'
  then sNewTipo := '1' //por Data
  else  if sTipo = '2'
        then sNewTipo := '3';  //por COO

  // Pega caminho onde grava os arquivos da bemafi32.ini
  sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

  GravaLog('Bematech_FI_DownloadMFDCV0909 -> ' + sPath + sArquivo + ',' + sTipo + ', NewTipo:' + sNewTipo  + ',' + sInicio + ',' + sFinal);
  iRet := fFuncBematech_FI_DownloadMFDCV0909( sPath + sArquivo, sNewTipo , sInicio, sFinal );
  GravaLog(' Bematech_FI_DownloadMFDCV0909 <- iRet : ' + IntToStr(iRet));
  TrataRetornoBematech(iRet, True);

  If iRet = 1 then
  begin

    if not DirectoryExists(PathArquivo)
    then ForceDirectories(PathArquivo);

    If (CopyFile(pChar(sPath+sArquivo),pChar(PathArquivo+sArquivo),False))
    then Result := '0'
    else ShowMessage('Erro ao copiar o arquivo [' + sPath+sArquivo + '] para [' + PathArquivo+sArquivo +']');
  end
  else
  begin
    GravaLog(' Erro na execução do comando Bematech_FI_DownloadMFDCV0909 ');
  end;
  {
  If iRet = 1 Then
  Begin
    GravaLog(' Bematech_FI_FormatoDadosMFD -> ' + sPath + sArquivo + ',' +  sPath + sDestino + ',' + '0,' + sTipo + ',' +
                sInicio + ',' + sFinal + ',' + sUsuario);
    iRet := fFuncBematech_FI_FormatoDadosMFD(  sPath + sArquivo,  sPath + sDestino, '0', sTipo, sInicio, sFinal, sUsuario );
    GravaLog(' Bematech_FI_FormatoDadosMFD <- iRet : ' + IntToStr(iRet));
    TrataRetornoBematech(iRet, True);

    // Grava arquivo no local indicado
    If iRet = 1
    Then  Result := CopRenArquivo( sPath, sDestino, PathArquivo, ArqDownTXT );
  End;
  }
end;

//------------------------------------------------------------------------------
function TImpBematech4200.FechaCNF(Mensagem: String): String;
var
  iRet : Integer;
begin

GravaLog('Bematech_FI_FechaRecebimentoNaoFiscalCV0909 ->');
iRet := fFuncBematech_FI_FechaRecebimentoNaoFiscalCV0909(Copy(Mensagem,1,489),1);
GravaLog(' Bematech_FI_FechaRecebimentoNaoFiscalCV0909 <- iRet: ' + IntToStr(iRet));
TrataRetornoBematech(iRet);

If iRet = 1
then Result := '0|'
else Result := '1|';
end;

//------------------------------------------------------------------------------
function TImpBematech4200.GeraRegTipoE(sTipo, sInicio, sFinal, sRazao,
  sEnd, sBinario: String): String;
Var
  sRetorno, sPath , sNomeArq , sNomeArqTmp , sTipoDown,
  pChavePublica,pChavePrivada, sArqGerado, sNomeArqBin: String;
  iRet : integer;
  Texto : TStringList;
Begin
  pChavePublica := 'A499F300F731F6892F44B83A5DD9D97CFFFD0ABE96E29B4B4B4EB2F9E5BCFFCF0A52EAFDF05779F90B3A199BE5776B13373CB2E7';
  pChavePublica := pChavePublica + '1D8AB67F4080CE27B226FFF032B6A7182C90C935EF2F4D343A743B60307EE4961F0C5EB02B1CEEF48D647C02E';
  pChavePublica := pChavePublica + '9BE164DC404B833F80C5B4268C04039547E7D5E242537B02360674B569208BD';

  pChavePrivada := 'D19598300478932ACFFE16CB6903552F15FDBD2D3B9659FAD79C3603C07B875919E9D8B28919B8F4C20C6AE23268A636D1206F5E6';
  pChavePrivada := pChavePrivada + 'BC79D89B6152804B15A9781C90E0A2D5064FB5B7CC01048AD8C66768F76D71647E7D39F8EDD714044CEA68F2A';
  pChavePrivada := pChavePrivada + '40106849132B01D14DDEB3FBA6FC1A9FBE9EA71BAB9293707A4EAD29CB6F3D';

  sNomeArq    := ArqDownTXT;
  sNomeArqTmp := 'DOWNLOADTMP.TXT';
  sNomeArqBin := 'DOWNLOAD.BIN';
  sRetorno    := '1';

  GravaLog('-> GeraRegTipoE : ' + sTipo + ',' + sInicio + ',' + sFinal + ',' + sRazao + ',' + sEnd + ',' + sBinario);
  sRetorno := DownloadMFD( sTipo, sInicio, sFinal );

  If sRetorno = '0' then
  begin
    // Pega caminho onde grava os arquivos da bemafi32.ini
    sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

    If sBinario <> '1' then
    begin
      If sTipo = '1'
      then sTipoDown := 'D'
      else
      If sTipo = '2'
      then sTipoDown := 'C';

      //Padrão do PAF
      sArqGerado := UpperCase(PathArquivo + DEFAULT_PATHARQMFD + 'MFD' + NumSerie + '_' +
                        FormatDateTime('ddMMyyyy', Date) + '_' + FormatDateTime('hhmmss', Time)+'.txt');

      GravaLog(' Bematech_FI_ArquivoMFDPath -> ( ' + sPath + sArqDownMFD +','+ sArqGerado +
                        ','+ sInicio +','+ sFinal +','+ sTipoDown + ',01,1,' + ')' );

      iRet := fFuncBematech_FI_ArquivoMFDPath(pChar(sPath + sArqDownMFD),pChar(sArqGerado),
                        pChar(sInicio),pChar(sFinal),pChar(sTipoDown),'01',1,pChar(pChavePublica),PChar(pChavePrivada),1);

      GravaLog(' Bematech_FI_ArquivoMFDPath <- iRet: ' + IntToStr(iRet));
      TrataRetornoBematech( iRet, True );
      If iRet = 1
      then sRetorno := '0'
      else sRetorno := '1';
    end
    else
    begin
       If not CopyFile( PChar(  sPath + sArqDownMFD ), PChar( PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin ), False ) then
       begin
         GravaLog('GeraRegTipoE ->' + 'Erro ao copiar o arquivo ' +  sPath + sArqDownMFD + ' para ' + PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin);
         ShowMessage( 'Erro ao copiar o arquivo ' +  sPath + sArqDownMFD + ' para ' + PathArquivo + DEFAULT_PATHARQMFD + sNomeArqBin );
         sRetorno := '1';
       end
       else GravaLog('-> BemaGeraRegistrosTipoE - formato binario( ' + sPath + sArqDownMFD +','+ PathArquivo +
                          DEFAULT_PATHARQMFD + sNomeArqBin +','+ sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ sBinario + ')' );
    end;
  end;

  Result := sRetorno;
end;


//------------------------------------------------------------------------------
function TImpBematech4200.MemoriaFiscal(DataInicio, DataFim: TDateTime;
  ReducInicio, ReducFim, Tipo: String): String;
var
  iRet : Integer;
  sDatai,sDataf,cTipo,sPath : String;
begin
  cTipo := '';

  // Pega o tipo gerado S =Simplificado / C =Completo
  Tipo  := UpperCase( Tipo );
  cTipo := Copy( Tipo, 2, 1);

  If Length(Tipo) <= 1
  Then cTipo := 'C';

  If Pos( 'I', Tipo ) > 0 then
  begin
    // Se o relatório for por Data
    If Trim(ReducInicio) + Trim(ReducFim) = '' then
    begin
      sDatai := FormataData( DataInicio, 1 );
      sDataf := FormataData( DataFim, 1 );
      GravaLog(' Bematech_FI_LeituraMemoriaFiscalDataCV0909 -> DataIni: ' + sDatai + ',DataFim: ' + sDataf + ', Tipo: ' + Tipo);
      iRet := fFuncBematech_FI_LeituraMemoriaFiscalDataCV0909(Pchar(sDatai),Pchar(sDataf),Pchar(cTipo));
      GravaLog(' Bematech_FI_LeituraMemoriaFiscalDataCV0909 <- iRet: ' + IntToStr(iRet));
    end
    // Se o relatório será por redução Z
    Else
    begin
      GravaLog(' Bematech_FI_LeituraMemoriaFiscalReducaoCV0909 -> ReducInicio: ' + ReducInicio + ',ReducFim: ' + ReducFim + ', Tipo: ' + Tipo);
      iRet :=fFuncBematech_FI_LeituraMemoriaFiscalReducaoCV0909(Pchar(ReducInicio),Pchar(ReducFim),Pchar(cTipo));
      GravaLog(' Bematech_FI_LeituraMemoriaFiscalReducaoCV0909 <- iRet: ' + IntToStr(iRet));
    end;

    TrataRetornoBematech( iRet, True );
    If iRet >= 0
    then Result := '0'
    Else Result := '1';
  end
  Else
  begin
      // Se o relatório for por Data
      If Trim(ReducInicio) + Trim(ReducFim) = '' then
      begin
        sDatai := FormataData( DataInicio, 4 );
        sDataf := FormataData( DataFim, 4 );
        GravaLog(' Bematech_FI_LeituraMemoriaFiscalSerialDataCV0909 -> DataIni: ' + sDatai + ',DataFim: ' + sDataf + ', Tipo: ' + Tipo);
        iRet := fFuncBematech_FI_LeituraMemoriaFiscalSerialDataCV0909(Pchar(sDatai),Pchar(sDataf),Pchar(cTipo));
        GravaLog(' Bematech_FI_LeituraMemoriaFiscalSerialDataCV0909 <- iRet: ' + IntToStr(iRet));
      end
      // Se o relatório será por redução Z
      Else
      begin
        GravaLog(' Bematech_FI_LeituraMemoriaFiscalSerialReducaoCV0909 -> ReducInicio: ' + ReducInicio + ',ReducFim: ' + ReducFim + ', Tipo: ' + Tipo);
        iRet :=fFuncBematech_FI_LeituraMemoriaFiscalSerialReducaoCV0909(Pchar(ReducInicio),Pchar(ReducFim),Pchar(cTipo));
        GravaLog(' Bematech_FI_LeituraMemoriaFiscalSerialReducaoCV0909 <- iRet: ' + IntToStr(iRet));
      end;

      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        // Pega caminho onde foi gravado o arquivo RETORNO.TXT
        sPath := LeArqIni( Path, sArqIniBema, 'Sistema', 'Path', 'C:\' );

        // Grava o arquivo no local indicado
        If cTipo = 's' Then
          Result := CopRenArquivo( sPath, sArqRetBema, PathArquivo, DEFAULT_ARQMEMSIM )
        Else
          Result := CopRenArquivo( sPath, sArqRetBema, PathArquivo, DEFAULT_ARQMEMCOM );
      end
      Else
        Result := '1';
  end;
end;

//------------------------------------------------------------------------------
function TImpBematech4200.Pagamento(Pagamento, Vinculado,  Percepcion: String): String;
var iRet , i   : integer;
    sFrmPag : String;
    sVlrPag : String;
    bFazPgto: Boolean;
begin

iRet := 0;

If not lDescAcres then
begin
  iRet := fFuncBematech_FI_IniciaFechamentoCupom('D', '$', Pchar('0.00'));
end;

while Length(pagamento)>0 do
begin
    If Pos('|',Pagamento)>17
    then sFrmPag := Copy(Pagamento,1,16)
    else sFrmPag:=Copy(Pagamento,1,Pos('|',Pagamento)-1);

    If sFrmPag = 'DINHEIRO'
    then sFrmPag:='Dinheiro';

    GravaLog(' ValidaFrmPgto4200 ->');
    bFazPgto := ValidaFrmPgto4200( sFrmPag , i);

    If bFazPgto
    then GravaLog(' ValidaFrmPgto4200 <- EfetuaPagto : True')
    else GravaLog(' ValidaFrmPgto4200 <- EfetuaPagto : False');

    If bFazPgto then
    begin
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
      GravaLog(' Bematech_FI_EfetuaFormaPagamento -> sFrmPag :' + sFrmPag + ' , sVlrPag :' + sVlrPag);
      iRet := fFuncBematech_FI_EfetuaFormaPagamento( sFrmPag , sVlrPag);
      GravaLog(' Bematech_FI_EfetuaFormaPagamento <- iRet:' + IntToStr(iRet));
   end;
end;

TrataRetornoBematech( iRet );
If iRet = 1
then Result := '0'
else Result := '1';

end;

//------------------------------------------------------------------------------
function TImpBematech4200.PegaCupom(Cancelamento: String): String;
var
   sNumCupom : String;
   iRet : Integer;
begin
  sNumCupom := Space( 9 );
  GravaLog(' Bematech_FI_NumeroCupomCV0909 -> ');
  iRet := fFuncBematech_FI_NumeroCupomCV0909( sNumCupom );
  GravaLog(' Bematech_FI_NumeroCupomCV0909 <- iRet:' + IntToStr(iRet));  
  TrataRetornoBematech( iRet );

  If iRet = 1
  then Result := '0|' + sNumCupom
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpBematech4200.RecCNF(IndiceTot, Valor, ValorAcresc,ValorDesc: String): String;
var
   iRet : Integer;
begin
Valor :=Trim(FormataTexto(Valor,12,2,3));
Valor := StringReplace(Valor,'.',',',[]);
GravaLog(' Bematech_FI_EfetuaRecebimentoNaoFiscalCV0909 -> IndiceTot :' + IndiceTot + ', Valor : ' + Valor);
iRet := fFuncBematech_FI_EfetuaRecebimentoNaoFiscalCV0909(IndiceTot,Valor);
GravaLog('<- Bematech_FI_EfetuaRecebimentoNaoFiscalCV0909 :' + IntToStr(iRet));
TrataRetornoBematech(iRet);

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//------------------------------------------------------------------------------
function TImpBematech4200.RecebNFis(Totalizador, Valor,Forma: String): String;
var iRet : Integer;
begin
  iRet := 0;

  GravaLog('Bematech_FI_RecebimentoNaoFiscal -> Totalizador : ' + Totalizador + ' , Valor : ' +
                Valor + ' , Forma :' + Forma);
                
  If ValidaFrmPgto4200(Forma , iRet) then
  begin
    iRet := fFuncBematech_FI_RecebimentoNaoFiscal( pchar(Totalizador), pchar(Trim(Valor)), pchar(Forma) );
    GravaLog('Bematech_FI_RecebimentoNaoFiscal <- iRet: ' + IntToStr(iRet));
    TrataRetornoBematech(iRet);
  end;

  if iRet = 1
  then Result := '0'
  else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpBematech4200.ReducaoZ(MapaRes: String): String;
    Function TrataLinha(Linha: String): String;
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
  iRet, i, iPos, nTamDoc  : Integer;
  aRetorno : array of String;
  sData, sHora , sRetorno, sLinhaISS,
  sTotalISS, sAux, sAux2  : String;
  fArq : TIniFile;
  fFile : TextFile;
  aAuxiliar : TaString;
  tStrFile : TStringList;
  fValor1, fValor2 ,fBase, fAliq ,
  nTotBaseISS, nTotImpIss : Real;
  bArred : Boolean;
begin

 MapaRes := Trim(MapaRes);
 tStrFile  := TStringList.Create;
 tStrFile.Clear;
 nTamDoc := 9;

 If MapaRes = 'S' then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(7);                                //**** Data do Movimento ****//
    GravaLog('Bematech_FI_DataMovimento ->');
    iRet := fFuncBematech_FI_DataMovimento(aRetorno[ 0]);
    GravaLog('Bematech_FI_DataMovimento <- iRet :' + IntToStr(iRet) + ', Retorno : ' + aRetorno[0]);
    aRetorno[ 0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := PDV;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(5);                               //**** Numero de reducoes ****//
    GravaLog('Bematech_FI_NumeroReducoes ->');
    iRet := fFuncBematech_FI_NumeroReducoes(aRetorno[3]);
    GravaLog('Bematech_FI_NumeroReducoes <- iRet :' + IntToStr(iRet) + ', Retorno : ' + aRetorno[3]);
    aRetorno[3] := Copy(aRetorno[3],1,4);
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(19);                              //**** Grande Total Final ****//
    GravaLog('Bematech_FI_GrandeTotal ->');
    iRet := fFuncBematech_FI_GrandeTotal( aRetorno[ 4] );
    GravaLog('Bematech_FI_GrandeTotal <- iRet :' + IntToStr(iRet) + ', Retorno : ' + aRetorno[4]);
    aRetorno[ 4] := Copy(aRetorno[4],1,18);
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(nTamDoc);                           //**** Numero documento Final ****//
    GravaLog('Bematech_FI_NumeroCupomCV0909 ->');
    iRet := fFuncBematech_FI_NumeroCupomCV0909( aRetorno[ 6] );
    GravaLog('Bematech_FI_NumeroCupomCV0909 <- iRet :' + IntToStr(iRet) + ', Retorno : ' + aRetorno[6]);
    aRetorno[ 6] := FormataTexto(aRetorno[6],nTamDoc,0,2);

    aRetorno[ 5] := aRetorno[ 6];

    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//

    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),nTamDoc,0,2); // *** Numero do comprovante da redução Z ***

    aRetorno[15] := FormataTexto('0',16, 0, 1);                         // --outros recebimentos--

     {*********************************************
      ********* TOTALIZADORES DO ECF **************
      *********************************************}
    sRetorno := Space(889);
    GravaLog('Bematech_FI_VerificaTotalizadoresParciaisMFD ->');
    iRet := fFuncBematech_FI_VerificaTotalizadoresParciaisMFD(sRetorno);
    GravaLog('Bematech_FI_VerificaTotalizadoresParciaisMFD <- iRet :' + IntToStr(iRet) + ', Retorno : ' + sRetorno);

    sRetorno := StrTran( sRetorno , ',' , '|' );
    MontaArray( sRetorno , aAuxiliar );

    aRetorno[11] := aAuxiliar[1];   //**** Nao tributado ISENTO      ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    aRetorno[12] := aAuxiliar[2];           //**** Nao tributado  ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    aRetorno[10] := aAuxiliar[3];           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    //sTribIS1 := Copy(aAuxiliar[4],1,Length(aAuxiliar[4])-2)+'.'+Copy(aAuxiliar[4],Length(aAuxiliar[4])-1,Length( aAuxiliar[4]));//Isenção de ISS
   // sTribNS1 := Copy(aAuxiliar[5],1,Length(aAuxiliar[5])-2)+'.'+Copy(aAuxiliar[5],Length(aAuxiliar[5])-1,Length( aAuxiliar[5]));//Não incidencia de ISS
    //sTribFS1 := Copy(aAuxiliar[6],1,Length(aAuxiliar[6])-2)+'.'+Copy(aAuxiliar[6],Length(aAuxiliar[6])-1,Length( aAuxiliar[6]));//Substituição de ISS

    //**** Cancelamento de ICMS ****//
    aRetorno[ 7] := aAuxiliar[9];
    aRetorno[ 7] := Copy(aRetorno[7],1,Length(aRetorno[7])-2)+'.'+Copy(aRetorno[7],Length(aRetorno[7])-1,Length(aRetorno[7]));
    aRetorno[ 7] := FormataTexto(aRetorno[ 7],15,2,1);

    //aAuxiliar[8]; //Acrescimo sobre ICMS

    //Venda Liquida - FI_VALCON
    GravaLog('Bematech_FI_VendaLiquida ->');
    aRetorno[8] := Space(14);
    iRet := fFuncBematech_FI_VendaLiquida(aRetorno[8]);
    aRetorno[8] := Trim(aRetorno[8]);
    GravaLog('Bematech_FI_VendaLiquida <- iRet :' + IntToStr(iRet) + ' - Retorno : ' + aRetorno[8]);
    aRetorno[8] := Copy(aRetorno[8],1,Length(aRetorno[8])-2)+'.'+Copy(aRetorno[8],Length(aRetorno[8])-1,Length(aRetorno[8]));
    aRetorno[8] := FormataTexto(aRetorno[8],15,2,1);

    //**** Desconto de ICMS ****//
    aRetorno[ 9] := aAuxiliar[7];
    aRetorno[ 9] := Copy(aRetorno[9],1,Length(aRetorno[9])-2)+'.'+Copy(aRetorno[9],Length(aRetorno[9])-1,Length(aRetorno[9]));
    aRetorno[ 9] := FormataTexto(aRetorno[ 9],11,2,1);

    //Desconto sobre ISS
    aRetorno[18]:= aAuxiliar[10];
    aRetorno[18]:= Copy(aRetorno[18],1,Length(aRetorno[18])-2)+'.'+Copy(aRetorno[18],Length(aRetorno[18])-1,Length(aRetorno[18]));
    aRetorno[18]:= FormataTexto(aRetorno[18], 11, 2, 1 );

    //aAuxiliar[11]; //Acrescimo sobre ISS

    //Cancelamento sobre ISS
    aRetorno[19]:= aAuxiliar[12];
    aRetorno[19]:= Copy(aRetorno[19],1,Length(aRetorno[19])-2)+'.'+Copy(aRetorno[19],Length(aRetorno[19])-1,Length(aRetorno[19]));
    aRetorno[19]:= FormataTexto(aRetorno[19], 11, 2, 1 );

    //QTD DE Aliquotas
    aRetorno[20]:= '00';

    //Contador de Cupons Fiscais Emitidos
    aRetorno[5]:= Space(10);
    GravaLog('Bematech_FI_ContadorCupomFiscalMFD ->');
    iRet := fFuncBematech_FI_ContadorCupomFiscalMFD(aRetorno[5]);
    GravaLog('Bematech_FI_ContadorCupomFiscalMFD <- iRet :' + IntToStr(iRet) + ', Retorno : ' + aRetorno[5]);
    aRetorno[5] := Copy(aRetorno[5],1,9);

    //Contador de reinício de operação (número de intervenções técnicas)
    aRetorno[17]:= Space(5);
    GravaLog('Bematech_FI_NumeroIntervencoes ->');
    iRet := fFuncBematech_FI_NumeroIntervencoes(aRetorno[17]);
    GravaLog('Bematech_FI_NumeroIntervencoes <- iRet :' + IntToStr(iRet) + ', Retorno : ' + aRetorno[17]);
    aRetorno[17] := Copy(aRetorno[17],1,4);

    Try
      GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
    Except
      GravaLog('Bematech - Redução Z - Erro na execução do comando: GrvTempRedZ()')
    End;
  end;

  If ((MapaRes = 'S') And (iRet = 1)) or (MapaRes <> 'S') then
  begin
    DateTimeToString( sData, 'dd/MM/yyyy', Date );
    DateTimeToString( sHora, 'hh:mm:ss', Time );
    GravaLog(' Bematech_FI_ReducaoZCV0909 ->');
    iRet := fFuncBematech_FI_ReducaoZCV0909( sData, sHora , 0);
    GravaLog(' Bematech_FI_ReducaoZCV0909 <- iRet: ' + IntToStr(iRet));
    Sleep(1000);
    TrataRetornoBematech( iRet, True );
  end;

  If iRet = 1 then
  begin
    If Trim(MapaRes) = 'S' then
    begin

       If aRetorno[0] = '00/00/00' then
       begin
         GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 00/00/00 ' +
                  'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
         sAux := Space(6);
         sAux2:= Space(6);
         GravaLog(' Bematech_FI_DataHoraReducao -> ');
         iRet := fFuncBematech_FI_DataHoraReducao( sAux , sAux2);
         GravaLog(' Bematech_FI_DataHoraReducao <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux + ' , Hora: ' + sAux2);
         sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
         aRetorno[0] := sAux;
         GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
       end;

       // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
       fValor1     := 1;
       sRetorno    := '';
       aAuxiliar   := Nil;
       aRetorno[16]:= '';
       sTotalISS   := '0';
       nTotBaseISS := 0;
       nTotImpIss  := 0;

       While (Trim(sRetorno) = '') And ( fValor1 < 4 ) do
       begin
         Sleep(1000);
         sRetorno := '';
         sRetorno := Space(1200);
         GravaLog( 'Bematech_FI_DadosUltimaReducaoCV0909 -> Try :' + FloatToStr(fValor1));
         iRet := fFuncBematech_FI_DadosUltimaReducaoCV0909( sRetorno );
         GravaLog('Bematech_FI_DadosUltimaReducaoCV0909 <- iRet: ' + IntToStr(iRet));
         fValor1 := fValor1 + 1;
       End;

       If (iRet = 1) And (Trim(sRetorno) <> '') then
       begin
         sRetorno := StrTran( sRetorno, ',', '|' );
         MontaArray( sRetorno, aAuxiliar );

         //*************************************************************************
         // Grava o valor do desconto
         //*************************************************************************
         fValor1 := StrToFloat( aAuxiliar[8] ) / 100;
         fValor2 := StrToFloat( aAuxiliar[11] ) / 100;
         aRetorno[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
         aRetorno[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );

         //*************************************************************************
         // Grava o valor do cancelamento
         //*************************************************************************
         fValor1 := StrToFloat( aAuxiliar[10] ) / 100;
         fValor2 := StrToFloat( aAuxiliar[13] ) / 100;
         aRetorno[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
         aRetorno[19]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );

        //**************************************************************************
        //Grava o valor das alíquotas
        //**************************************************************************
        //**************************************************************************
        // o Array na DLL retorna assim :
        // aAuxiliar[x] = T 		//Tipo de Alíquota
        // aAuxiliar[x+1] = 0580	//Aliquota
        // aAuxiliar[x+2] = 1000	//Base de Calculo
        // dai precisa efetuar o calculo do valor que é aquilo que o LOJA160/STREDZ espera
        //**************************************************************************
        For i := 16 to Pred(Length(aAuxiliar)) do
        begin
          sRetorno := Trim(aAuxiliar[i]);
          If (sRetorno = 'IS1') Or (sRetorno = 'NS1') Or (sRetorno = 'FS1') Or
             (sRetorno = 'S') Or (sRetorno = 'T') then
          begin
            sAux := aAuxiliar[i+1];
            sAux := Copy(sAux,1,Length(sAux)-2)+'.'+Copy(sAux,Length(sAux)-1,Length(sAux));
            sAux2 := aAuxiliar[i+2];
            sAux2 := Copy(sAux2,1,Length(sAux2)-2)+'.'+Copy(sAux2,Length(sAux2)-1,Length(sAux2));

            If  (sRetorno = 'IS1') Or (sRetorno = 'NS1') Or
                (sRetorno = 'FS1') Or (sRetorno = 'S')  then
            begin
              GravaLog(' Aliquota de ISS ');

              If (sRetorno = 'S') then
              begin
                sRetorno:= sRetorno + Copy(aAuxiliar[i+1],1,Length(aAuxiliar[i+1])-2)+
                                ','+Copy(aAuxiliar[i+1],Length(aAuxiliar[i+1])-1,Length(aAuxiliar[i+1]));

                fValor2	:= StrToFloat(sAux2) * (StrToFloat(sAux)/100);
                fValor2 := ArredCV0909( fValor2 );
                nTotBaseISS:= nTotBaseISS + StrToFloat(sAux2);
                nTotImpIss := nTotImpIss + fValor2;
              end
              else
                fValor2 := 0;

              //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
              //Valor Debitado com 12 casas e 2 decimais + Separador ';'
              sLinhaISS := sRetorno + Space(1) +
                           FormataTexto(sAux2,14,2,1) + Space(1) +
                           FormataTexto(FloatToStr(fValor2),14,2,1) + ';';

              aRetorno[16] := aRetorno[16] + sLinhaISS ;
              GravaLog('Conteudo alíquota de ISS - [' + sLinhaISS + ']');
            end;

            If sRetorno = 'T' then
            begin
              GravaLog(' Aliquota de ICMS ');
              aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
              SetLength( aRetorno, Length(aRetorno)+1 );

              sRetorno := sRetorno + Copy(aAuxiliar[i+1],1,Length(aAuxiliar[i+1])-2) + ','
                                   + Copy(aAuxiliar[i+1],Length(aAuxiliar[i+1])-1,Length(aAuxiliar[i+1]));

              fValor2 := StrToFloat(sAux2) * (StrToFloat(sAux)/100);
              fValor2 := ArredCV0909( fValor2 );

              // Aliquota '  ' Valor '  ' Imposto Debitado
              aRetorno[High(aRetorno)] := sRetorno + Space(1) +
                                          FormataTexto(sAux2,14,2,1,'.') + Space(1) +
                                          FormataTexto(StrTran(FloatToStr(fValor2),',','.'),14,2,1,'.');

              GravaLog('Conteudo alíquota de ICMS - [' + aRetorno[High(aRetorno)] + ']');
            end;
          end;
        End; //Do For

        sTotalISS := FormataTexto(StrTran(FloatToStr(nTotBaseISS),',',''),14,2,1,'.') + Space(1) +
                     FormataTexto(StrTran(FloatToStr(nTotImpIss),',',''),14,2,1,'.');

        aRetorno[16] := sTotalISS + ';' + aRetorno[16];
        If Copy(Trim(aRetorno[16]),Length(Trim(aRetorno[16])),1) <> ';'
        then aRetorno[16] := aRetorno[16] + ';';
       end;

       //*************************************************************************
       // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
       //*************************************************************************
       Result := '0|';
       For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';

       GravaLog(' Retorno Mapa Resumo <- [ '+ Result + ']');
    end
    Else
        Result := '0';
  end
  Else
    Result := '1';
end;

//------------------------------------------------------------------------------
function TImpBematech4200.RedZDado(MapaRes: String): String;
Var
  aRetTemp: TaString;
  i,iRet: Integer;
  sAux,sRetorno: String;
  fValor1, fValor2 : Real;
  aAuxiliar : TaString;
begin
  Result := '0|';

  // Ajusta os dados do Cancelamento e Descontos com base na última reducao Z
  fValor1 := 1;
  sRetorno := '';

  While (Trim(sRetorno) = '') And ( fValor1 < 4) do
  begin
    If fValor1 > 1
    Then Sleep(1000);  //quando nao retorna, aguarda 1 segundo para nova tentativa

    sRetorno := '';
    sRetorno := Space(1200);
    GravaLog( 'Bematech_FI_DadosUltimaReducaoCV0909 -> Try :' + FloatToStr(fValor1));
    iRet := fFuncBematech_FI_DadosUltimaReducaoCV0909( sRetorno );
    GravaLog('Bematech_FI_DadosUltimaReducaoCV0909 <- iRet: ' + IntToStr(iRet));
    fValor1 := fValor1 + 1;
  End;

  If (iRet = 1) And (Trim(sRetorno) <> '') then
  begin
    sRetorno := StrTran( sRetorno, ',', '|' );
    MontaArray( sRetorno, aAuxiliar );
  End;

  If (iRet = 1) AND (Length(aAuxiliar) > 1 )then
  Begin
    sAux := aAuxiliar[1] ; //data do movimento da ultima Z
    //Captura dados armazenados em arquivo antes do comando para emissão da ReducaoZ
    sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,7,2);
    aRetTemp := GetTempRedZ(sAux);
  End;

  If Length(aRetTemp) >= 18 Then
  Begin

    //*************************************************************************
    // Grava o valor do desconto
    //*************************************************************************
    fValor1 := StrToFloat( aAuxiliar[8] ) / 100;
    fValor2 := StrToFloat( aAuxiliar[11] ) / 100;
    aRetTemp[9] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
    aRetTemp[18]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );

    //*************************************************************************
    // Grava o valor do cancelamento
    //*************************************************************************
    fValor1 := StrToFloat( aAuxiliar[10] ) / 100;
    fValor2 := StrToFloat( aAuxiliar[13] ) / 100;
    aRetTemp[7] := FormataTexto( FloatToStr(fValor1), 11, 2, 1 );
    aRetTemp[19]:= FormataTexto( FloatToStr(fValor2), 11, 2, 1 );

    //*************************************************************************
    // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
    //*************************************************************************
    For i:= 0 to Length(aRetTemp)-1 do
    begin
      Result := Result + aRetTemp[i]+'|';
    End;

    GravaLog('Bematech Mapa Resumo(Recuperado) <- Retorno : '+ Result);
  End Else  GravaLog('Bematech Mapa Resumo(Recuperado) <- Retorno : Nao possui dados da ultima reducao');

End;

//------------------------------------------------------------------------------
function TImpBematech4200.RegistraItem(codigo, descricao, qtde, vlrUnit,
  vlrdesconto, aliquota, vlTotIt, UnidMed: String;
  nTipoImp: Integer): String;

  function CapturaIndAliq(AliqBusca: string): String;
  var i: Integer;
      sRet,sLinha,sAlq,sTipoAlq : String;
      fArquivo : TIniFile;
  begin
    i := 1;
    sRet := '';

    fArquivo := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\'+sArqIniBema);
    sTipoAlq := Copy(AliqBusca,1,1);
    sAlq     := Copy(AliqBusca,2,Length(AliqBusca));
    sAlq     := StringReplace(sAlq,'.','',[]);
    sAlq     := StringReplace(sAlq,',','',[]);

    For i:= 1 to 60 do  //Total de 60 alíquotas
    begin
      sLinha := fArquivo.ReadString('Aliquotas','Aliquota' + FormataTexto(IntToStr(i),2,0,2),'');

      If (Trim(sLinha) <> '')  and (sLinha[Length(sLinha)] = sTipoAlq) and (Copy(sLinha,1,4) = sAlq)  then
      begin
        sRet := FormataTexto(IntToStr(i),2,0,2);
        Break;
      end;
    end;

    fArquivo.Free;
    Result := sRet;
  end;

var
  iRet,iCasas : Integer;
  sTrib,sAliquota,sValAlq,sIndiceISS, sAliqISS,
  sTipoQtd : String;
  bISSAlq : Boolean;
begin

  iCasas:=2;
  bISSAlq := False;

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    Result := '11';
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

  If bISSAlq = False then
  begin
    If sTrib = 'F'
    then sAliquota := 'FF';

    If sTrib = 'I'
    then sAliquota := 'II';

    If sTrib = 'N'
    then sAliquota := 'NN';

    GravaLog('Efetuado tratamento para alíquota de ICMS');
  end;

  GravaLog('Alíquota que sera lançada na venda - Aliquota [' + sAliquota + ']');

  If sTrib[1] in ['T','S']  then    //Função retorna pros dois tipos de alíquotas
  begin
    sAliquota := FormataTexto(Copy(aliquota,2,5),4,2,1,'.');

    If Length(sAliquota) = 4 then
    begin
      sAliquota := FormataTexto(StringReplace(StringReplace( sAliquota, ',', '',[] ), '.', '', [] ),4,0,2);
      Insert('.',sAliquota,3);
    end;

    sValAlq   := sAliquota;
    sAliquota := CapturaIndAliq(sTrib+sAliquota);
    If Trim(sAliquota) = ''
    then sAliquota := FormataTexto(StringReplace(StringReplace( sValAlq , ',', '',[] ), '.', '', [] ),4,0,2) //alíquota "NNNN"
  end;

  // Codigo só pode ser até 49 posicoes.
  Codigo := Trim( Copy(codigo,1,49) );

  descricao := Trim(descricao);
  If Length(descricao) > 200
  then descricao := Copy(descricao, 1, 200);

  // Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
  sTipoQtd := 'F';

  // Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionária
  Qtde := FormataTexto( qtde, 7, 3, 1 );
  Qtde := StringReplace(qtde,'.',',',[]);

  // Valor unitário deve ter até 9 digitos, 3 casas decimais e com virgula
  vlrUnit := FormataTexto( vlrUnit, 9, 3, 1 );
  vlrUnit := StringReplace(vlrUnit,'.',',',[]);

  // Valor desconto deve ter até 8 digitos
  vlrDesconto := FormataTexto( vlrDesconto, 10, 2, 2 );

  //Unidade de Medida deve ter até 2 dígitos
  If Length(UnidMed) > 2 then
  begin
    UnidMed := Copy(UnidMed,1,2);
  end;

  // Retistra o Item
  GravaLog('Bematech_FI_VendeItemDepartamento ->' + Codigo +',' + descricao+',' +
                 sAliquota+',' + vlrUnit+',' + Qtde+',' + '0'+',' + vlrDesconto+',' + '01'+',' + UnidMed);
  iRet := fFuncBematech_FI_VendeItemDepartamento( Codigo, descricao, sAliquota, vlrUnit, Qtde, '0', vlrDesconto, '01', UnidMed);
  GravaLog('Bematech_FI_VendeItemDepartamento <- iRet :' + IntToStr(iRet));
  TrataRetornoBematech( iRet, True );

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;

//-------------------------------------------------------------------------------
function TImpBematech4200.RelGerInd(cIndTotalizador, cTextoImp: String; nVias: Integer; ImgQrCode: String): String;
Var
  iRet,i,nPos: Integer;
  cTextoImpAux,sIndTot  : String;
  bImprime        : Boolean;
  sLista          : TStringList;
begin
  //*******************************************************************************
  // Inicialização das variaveis
  //*******************************************************************************
  Result      := '1';
  bImprime    := True;

  cIndTotalizador :=  Trim(cIndTotalizador);
  Val(cIndTotalizador,i,nPos);

  If i > 0
  then sIndTot := FormataTexto(IntToStr(i),2,0,1)
  else
     //caso haja algum problema manda o gerencial padrão
     sIndTot := '01';

  If bImprime then
  begin
    sLista := TStringList.Create;
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

     For i:=1 to nVias do
     Begin
         GravaLog(' Bematech_FI_AbreRelatorioGerencialCV0909 -> indice:' + sIndTot);
         iRet := fFuncBematech_FI_AbreRelatorioGerencialCV0909( sIndTot );
         GravaLog(' Bematech_FI_AbreRelatorioGerencialCV0909 <- iRet: ' + IntToStr(iRet));
         TrataRetornoBematech( iRet, True );
         If iRet = 0 then
         Begin
           Result := '1';
           Exit;
         End;

         GravaLog(' Bematech_FI_UsaRelatorioGerencialCV0909 -> ');

         For nPos := 0 to sLista.Count-1 do
            iRet := fFuncBematech_FI_UsaRelatorioGerencialCV0909(sLista.Strings[nPos]);   //O Limite do comando são 618 caracteres por envio

         GravaLog(' <- Bematech_FI_UsaRelatorioGerencialCV0909 : ' + IntToStr(iRet));

         TrataRetornoBematech( iRet );
         If iRet = 0 then
         Begin
           Result := '1';
           Exit;
         End;

        GravaLog(' -> Bematech_FI_FechaRelatorioGerencialCV0909' );
        iRet:= fFuncBematech_FI_FechaRelatorioGerencialCV0909(1);
        GravaLog(' <- Bematech_FI_FechaRelatorioGerencialCV0909 : ' + IntToStr(iRet) );
        TrataRetornoBematech(iRet, True);

        If iRet = 1
        then Result := '0'
        Else Result := '1';
    End;

    //*******************************************************************************
    // Mostrar mensagem de erro se necessário
    //*******************************************************************************
    If Result = '1'
    then TrataRetornoBematech( iRet );

  end
  Else
  begin
    // Mostrar mensagem de erro caso os totalizadores não tenham sido encontrados
    GravaLog('O Relatorio Gerencial ' + Trim(cIndTotalizador) + ' não existe no ECF. ');
    LjMsgDlg('O Relatorio Gerencial ' + Trim(cIndTotalizador) + ' não existe no ECF. ');
    Result := '1';
  end;
end;

//------------------------------------------------------------------------------
function TImpBematech4200.StatusImp(Tipo: Integer): String;
    Function TrataFlag(iFlag: integer): integer;
    Begin
      Result := 0;
      if iFlag >= 128 then iFlag := iFlag -128;
      if iFlag >= 32  then iFlag := iFlag -32;
      if iFlag >= 8   then iFlag := iFlag -8;
      if iFlag >= 4   then iFlag := iFlag -4;
      if iFlag >= 2   then iFlag := iFlag -2;

      if iFlag = 1 then Result := 1;
    End;
var
  iRet, iFlag, i : Integer;
  sRet, Data, Hora, sDataHoje, FlagTruncamento, sCuponsEmitidos, sUltimoItem,
  sOperacoes, sCRG, sCDC, sDataHora : String;
  dDtHoje,dDtMov:TDateTime;
  iAck, iSt1, iSt2 : Integer;
  sVendaBruta, sSubTotal : String;
  sGrandeTotal : String;
  sDataMov: String;
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
  // 19 - Retorna a data do movimento
  // 20 - Verifica qual é o CNPJ cadastrado na Impressora
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

  //  1 - Obtem a Hora da Impressora
  sVendaBruta := Space(20);
  sGrandeTotal := Space(20);
  If Tipo = 1 then
  begin
    Data:=Space(7);
    Hora:=Space(7);
    GravaLog(' Bematech_FI_DataHoraImpressora ->');
    iRet := fFuncBematech_FI_DataHoraImpressora( Data, Hora );
    Data := Copy(Data,1,6);
    Hora := Copy(Hora,1,6);
    GravaLog(' Bematech_FI_DataHoraImpressora <- iRet [' + IntToStr(iRet) + '] - Data [' + Data + ' - Hora [' + Hora + ']');
    TrataRetornoBematech( iRet, True );
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
    Data:=Space(7);
    Hora:=Space(7);
    GravaLog(' Bematech_FI_DataHoraImpressora ->');
    iRet := fFuncBematech_FI_DataHoraImpressora( Data, Hora );
    Data := Copy(Data,1,6);
    Hora := Copy(Hora,1,6);
    GravaLog(' Bematech_FI_DataHoraImpressora <- iRet [' + IntToStr(iRet) + '] - Data [' + Data + ' - Hora [' + Hora + ']');
    TrataRetornoBematech( iRet, True );
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
    iRet := fFuncBematech_FI_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
    TrataRetornoBematech( iRet, True );
    If iSt1 >= 128 Then
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
    iRet := fFuncBematech_FI_FlagsFiscais(iFlag);
    iRet := TrataFlag(iFlag);
    If iRet = 1 Then
        Result := '7'    // aberto
    Else
        Result := '0';  // Fechado
  end
  //  6 - Ret. suprimento da impressora
  Else If Tipo = 6 then
  begin
      sRet := Space(3016);
      iRet := fFuncBematech_FI_VerificaFormasPagamento( sRet );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        i:=1;
        Repeat
            If UpperCase(Trim(Copy(sRet,1,16)))='DINHEIRO'
            then  Result := '0|' + Trim(FormataTexto(Copy(sRet,17,18)+','+Copy(sRet,35,2),12,2,3));

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
          iRet:= fFuncBematech_FI_DataMovimento(Data);
          If Data='000000'
          then Result:= '0'
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
  //  9 - Verifica o Status do ECF
  Else If Tipo = 9 then
        begin
           If Verifica_Status( False, False ) <> 1 then
                   Begin
                      iRet := fFuncBematech_FI_FlagsFiscais(iFlag);
                      iRet := TrataFlag(iFlag);
                        If iRet = 1 Then
                          Result := '0'    // aberto
                        Else
                          Result := '-1';  // Fechado
                   End
           else
                   Result := '0';
        end
  // 10 - Verifica se todos os itens foram impressos.
  Else If Tipo = 10 then
    Result := '0'
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  Else If Tipo = 11 then
    Result := '1'
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  Else If Tipo = 12 then
    Result := '1'
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  Else If Tipo = 13 then
  begin
    FlagTruncamento := Space(2);
    // Para o FlagTruncamento, retorna 1 se a impressora estiver no modo truncamento e 0 se estiver no modo arredondamento.
    iRet := fFuncBematech_FI_VerificaTruncamento( FlagTruncamento );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := Copy( FlagTruncamento, 1, 1 )
    Else
      Result := '1';
  end
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  else if Tipo = 14 then
    Result := '0'
  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  else if Tipo = 15 then
    Result := '1'
  // 16 - Verifica se exige o extenso do cheque
  else if Tipo = 16 then
    Result := '1'
  // 17 - Verifica venda bruta
  else if Tipo = 17 then
  begin
    GravaLog('Bematech_FI_VendaBruta ->');
    iRet := fFuncBematech_FI_VendaBruta( sVendaBRuta );
    GravaLog('Bematech_FI_VendaBruta <- iRet: '+ IntToStr(iRet) + ', Retorno:' + sVendaBRuta );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sVendaBRuta;
  end
  // 18 - Verifica Grande Total
  else if Tipo = 18 then
  begin
    GravaLog('Bematech_FI_GrandeTotal ->');
    iRet := fFuncBematech_FI_GrandeTotal( sGrandeTotal );
    GravaLog('Bematech_FI_GrandeTotal <- iRet: '+ IntToStr(iRet) + ', Retorno:' + sGrandeTotal );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sGrandeTotal;
  end
  // 19 - Retorna a data do movimento da impressora
  else if Tipo = 19 then
  begin
    sDataMov    := Space(6);
    sDataHoje   := Space(6);
    GravaLog('Bematech_FI_DataMovimento ->');
    iRet        := fFuncBematech_FI_DataMovimento( sDataMov );
    GravaLog('Bematech_FI_DataMovimento <- iRet: '+ IntToStr(iRet) + ', Retorno:' + sDataMov );
    TrataRetornoBematech( iRet, True );

    If iRet = 1 Then
     begin
      sDataHoje    := Copy(StatusImp(2),3,8);
      If sDataMov = '000000' then
          Result:= '2|'+ sDataHoje
      else

         begin
             sDataMov     := Copy(sDataMov,1,2)+'/'+Copy(sDataMov,3,2)+'/'+Copy(sDataMov,5,2);
             If (StrToDate(sDataMov) < StrToDate(sDataHoje)) then    // reducao pendente
                Result := '0|'+ sDataMov
             Else
                Result := '2|'+ sDataHoje;
          end
     end
    else
        //Retornou erro na operacao do 19
        Result := '-1';
  end

  // 20 - Retorna o CNPJ cadastrado na impressora
  else if Tipo = 20 then
    Result := '0|' + Cnpj

  // 21 - Retorna o IE cadastrado na impressora
  else if Tipo = 21 then
    Result := '0|' + Ie

  // 22 - Retorna o CRZ - Contador de Reduções Z
  else if Tipo = 22 then
  begin
    If ReducaoEmitida then
    begin
      GravaLog('Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('Bematech_FI_RegistrosTipo60 <- iRet: '+ IntToStr(iRet) );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        ContadorCrz := LeArqRetorno( Path, sArqIniBema, 55 , 3 );
        Result := '0|' + ContadorCrz
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
    If IndicaMFAdi = '' Then
      IndicaMFAdi := Retorna_Informacoes(1);
    Result := '0|' + IndicaMFAdi;
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
      DataIntEprom := Retorna_Informacoes(2);
    Result := '0|' + DataIntEprom;
  end

  // 30 - Retorna o Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  else if Tipo = 30 then
  begin
    If HoraIntEprom = '' Then
      HoraIntEprom := Retorna_Informacoes(3);
    Result := '0|' + HoraIntEprom;
  end

  // 31 - Retorna o Nº de ordem seqüencial do ECF no estabelecimento usuário
  else if Tipo = 31 then
    Result := '0|' + Pdv

  // 32 - Retorna o Grande Total Inicial
  else if Tipo = 32 then
  begin
    If ReducaoEmitida then
    begin
      GravaLog('Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('Bematech_FI_RegistrosTipo60 <- iRet: '+ IntToStr(iRet) );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
        GTFinal       := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
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
      GravaLog('Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('Bematech_FI_RegistrosTipo60 <- iRet: '+ IntToStr(iRet) );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        GTFinal := LeArqRetorno( Path, sArqIniBema, 74 , 16 );
        Result := '0|' + GTFinal
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
      GravaLog('Bematech_FI_RegistrosTipo60 ->');
      iRet := fFuncBematech_FI_RegistrosTipo60();
      GravaLog('Bematech_FI_RegistrosTipo60 <- iRet: '+ IntToStr(iRet) );
      TrataRetornoBematech( iRet, True );
      If iRet = 1 then
      begin
        VendaBrutaDia := LeArqRetorno( Path, sArqIniBema, 58 , 16 );
        Result := '0|' + VendaBrutaDia
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
    sCuponsEmitidos := Space(10);
    GravaLog('Bematech_FI_ContadorCupomFiscalMFD ->');
    iRet := fFuncBematech_FI_ContadorCupomFiscalMFD(sCuponsEmitidos);
    TrataRetornoBematech( iRet, True );
    GravaLog('Bematech_FI_ContadorCupomFiscalMFD <- iRet: ' + IntToStr(iRet));

    If iRet = 1
    then Result := '0|' + Copy(sCuponsEmitidos,1,9)
    else Result := '1';
  end
  
  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  else if Tipo = 36 then
  begin
    sOperacoes := Space(10);
    iRet := fFuncBematech_FI_NumeroOperacoesNaoFiscaisCV0909( sOperacoes );
    TrataRetornoBematech( iRet, True );
    sOperacoes := Copy(sOperacoes,1,9);

    If iRet = 1
    then Result := '0|' + sOperacoes
    Else Result := '1';
  end

  // 37 - Retorna o Contador Geral de Relatório Gerencial
  else if Tipo = 37 then
  begin
    sCRG := Space(6);
    iRet := fFuncBematech_FI_ContadorRelatoriosGerenciaisMFD( sCRG );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sCRG
    Else
      Result := '1';
  end

  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  else if Tipo = 38 then
  begin
    sCDC := Space(4);
    iRet := fFuncBematech_FI_ContadorComprovantesCreditoMFD( sCDC );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sCDC
    Else
      Result := '1';
  end

  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  else if Tipo = 39 then
  begin
    sDataHora := Space(12);
    iRet := fFuncBematech_FI_DataHoraUltimoDocumentoMFD( sDataHora );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sDataHora
    Else
      Result := '1';
  end

  // 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CÓDIGOS DE IDENTIFICAÇÃO DE ECF
  else if Tipo = 40 then
    Result := '0|' + CodigoEcf

  // 41 - Retorna o sequencial do último item vendido
  else if Tipo = 41 then
  Begin
    sUltimoItem := Space(4);
    iRet := fFuncBematech_FI_UltimoItemVendido( sUltimoItem );
    TrataRetornoBematech( iRet, True );
    If iRet = 1 then
      Result := '0|' + sUltimoItem
    Else
      Result := '1';
  End

  // 42 - Retorna o subtotal do cupom
  else if Tipo = 42 then
  Begin
    sSubTotal := Space(14);
    iRet := fFuncBematech_FI_SubTotal( sSubTotal );
    TrataRetornoBematech( iRet, True );
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
function TImpBematech4200.Suprimento(Tipo: Integer; Valor, Forma,
  Total: String; Modo: Integer; FormaSupr: String): String;
var
  iRet : Integer;
  sRet : String;
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
         if nSuprimento >= StrToFloat(Valor)
         then Result := '8'
         else Result := '9'
        end;
    2: begin
         GravaLog(' Bematech_FI_SuprimentoCV0909 -> ');
         iRet:= fFuncBematech_FI_SuprimentoCV0909(Valor,Forma);
         GravaLog(' Bematech_FI_SuprimentoCV0909 <- iRet:' + IntToStr(iRet));
         TrataRetornoBematech( iRet );
         If iRet = 1
         then Result := '0'
         Else Result := '1';

        end;
    3: begin
         GravaLog(' Bematech_FI_SangriaCV0909 -> ');
         iRet:= fFuncBematech_FI_SangriaCV0909(Valor,'Sangria');
         GravaLog(' Bematech_FI_SangriaCV0909 <- iRet:' + IntToStr(iRet));
         TrataRetornoBematech( iRet );
         If iRet = 1
         then Result := '0'
         Else Result := '1';
       end;
  end;
end;

//-------------------------------------------------------------------------------
function TImpBematech4200.RelatorioGerencial(Texto: String; Vias: Integer;
  ImgQrCode: String): String;
begin
GravaLog('Bematech 4200 - RelatorioGerencial');
Result := RelGerInd('01',Texto,Vias,ImgQrCode);
GravaLog('Bematech 4200 - RelatorioGerencial <- Result:' + Result);
end;

initialization
  RegistraImpressora('BEMATECH MP20FI II - V. 03.00'     , TImpBematech         , 'BRA' , '030501');
  RegistraImpressora('BEMATECH MP20FI II - V. 03.10'     , TImpBematech         , 'BRA' , '030503');
  RegistraImpressora('BEMATECH MP20FI II - V. 03.15'     , TImpBematech         , 'BRA' , '030504');
  RegistraImpressora('BEMATECH MP20FI II - V. 03.21'     , TImpBematech         , 'BRA' , ' ');
  RegistraImpressora('BEMATECH MP20FI II - V. 03.22'     , TImpBematech         , 'BRA' , '030505');
  RegistraImpressora('BEMATECH MP20FI II - V. 03.26'     , TImpBematech         , 'BRA' , '030507');
  RegistraImpressora('BEMATECH MP20FI II - V. 03.30'     , TImpBematech         , 'BRA' , '030509');
  RegistraImpressora('BEMATECH MP20FI II - V. 03.31'     , TImpBematech         , 'BRA' , '030508');
  RegistraImpressora('BEMATECH MP25FI - V. 01.00.00'     , TImpBematechMP25FI   , 'BRA' , '031001');
  RegistraImpressora('BEMATECH MP25FI - V. 01.01.01'     , TImpBematechMP25FI   , 'BRA' , '031002');
  RegistraImpressora('BEMATECH MP25FI - V. 01.01.02'     , TImpBematechMP25FI   , 'BRA' , '031005');
  RegistraImpressora('BEMATECH MP25FI - V. 01.02.02'     , TImpBematechMP25FI   , 'BRA' , '031003');
  RegistraImpressora('BEMATECH MP40FI II - V. 03.00'     , TImpBematech40       , 'BRA' , '031301');
  RegistraImpressora('BEMATECH MP40FI II - V. 03.10'     , TImpBematech40       , 'BRA' , '031303');
  RegistraImpressora('BEMATECH MP40FI II - V. 03.20'     , TImpBematech40       , 'BRA' , ' ');
  RegistraImpressora('BEMATECH MP40FI II - V. 03.21'     , TImpBematech40       , 'BRA' , '031304');
  RegistraImpressora('BEMATECH MP40FI II - V. 03.22'     , TImpBematech40       , 'BRA' , ' ');
  RegistraImpressora('BEMATECH MP40FI II - V. 03.26'     , TImpBematech40       , 'BRA' , ' ');
  RegistraImpressora('UNISYS BR-40 3.10 - V. 03.10'      , TImpBematech40       , 'BRA' , '030503');
  RegistraImpressora('YANCO 8000 - V. 1.1'               , TImpYanco8000        , 'BRA' , '470502');
  RegistraImpressora('YANCO 8000 - V. 1.2'               , TImpYanco8000        , 'BRA' , ' ');
  RegistraImpressora('YANCO 8000 - V. 2.0'               , TImpYanco8000        , 'BRA' , '470503');
  RegistraImpressora('BEMATECH MP2000 THFI - V. 01.00.00', TImpBematech2000     , 'BRA' , '030801');
  RegistraImpressora('BEMATECH MP2000 THFI - V. 01.01.01', TImpBematech2000     , 'BRA' , '030803');
  RegistraImpressora('BEMATECH MP2000 THFI - V. 01.01.02', TImpBematech2000     , 'BRA' , ' ');
  RegistraImpressora('BEMATECH MP2000 THFI - V. 01.03.02', TImpBematech2000_0302, 'BRA' , '030805');
  RegistraImpressora('BEMATECH MP2100 THFI - V. 01.00.00', TImpBematech2100     , 'BRA' , '030901');
  RegistraImpressora('BEMATECH MP2100 THFI - V. 01.00.01', TImpBematech2100     , 'BRA' , '030903');
  RegistraImpressora('BEMATECH MP2100 THFI - V. 01.01.00', TImpBematech2100     , 'BRA' , '030902');
  RegistraImpressora('BEMATECH MP2100 THFI - V. 01.01.01', TImpBematech2100_0101, 'BRA' , '030903');
  RegistraImpressora('BEMATECH MP3000 THFI - V. 01.01.00', TImpBematech3000     , 'BRA' , '031902');
  RegistraImpressora('BEMATECH MP4000 THFI - V. 01.00.01', TImpBematech4000		, 'BRA'	, '032101');
  RegistraImpressora('BEMATECH MP4000 THFI - V. 01.00.02', TImpBematech4000		, 'BRA'	, '032102');
  RegistraImpressora('BEMATECH MP4200 THFI - V. 01.00.00', TImpBematech4200		, 'BRA'	, '032201');
  RegistraImpressora('BEMATECH MP4200 THFI - V. 01.00.01', TImpBematech4200		, 'BRA'	, '032202');
  RegistraImpressora('BEMATECH MP4200 THFI - V. 01.00.02', TImpBematech4200		, 'BRA'	, '032203');
  RegistraImpressora('BEMATECH MP4200 THFI II - V. 01.00.00', TImpBematech4200		, 'BRA'	, '032301');
  RegistraImpressora('BEMATECH MP4200 THFI II - V. 01.00.01', TImpBematech4200		, 'BRA'	, '032302');
  RegistraImpressora('BEMATECH MP4200 THFI II - V. 01.00.02', TImpBematech4200		, 'BRA'	, '032303');
  RegistraImpressora('BEMATECH MP4200 THFI II - V. 01.99.01', TImpBematech4200		, 'BRA'	, '032304'); //avaliar o código CNIEE
  RegistraImpressora('BEMATECH MP6000 THFI - V. 01.03.03', TImpBematech6000     , 'BRA' , '031705');
  RegistraImpressora('BEMATECH MP6000 THFI - V. 01.03.02', TImpBematech6000     , 'BRA' , '031704');
  RegistraImpressora('BEMATECH MP7000 THFI - V. 01.00.01', TImpBematech7000     , 'BRA' , '032001');
  RegistraImpressora('IBM KR4-4610 - V. 01.03.03'     , TImpBematech6000        , 'BRA' , '180104');
  RegistraImpressora('BEMATECH MP20FI II R - V. 03.20', TImpBematechMP25FIR     , 'BRA' , '030603');
  RegistraImpressora('BEMATECH MP20FI II R - V. 03.22', TImpBematechMP25FIR     , 'BRA' , ' ');
  RegistraImpressora('BEMATECH MP20FI II R - V. 03.26', TImpBematechMP25FIR     , 'BRA' , ' ');
  RegistraImpCheque ('BEMATECH MP40 FI II'  , TImpCheqBematech   , 'BRA');
  RegistraImpCheque ('UNISYS BR-40 3.10'    , TImpCheqBematech   , 'BRA');
  RegistraImpCheque ('BEMATECH MP6000 THFI' , TImpCheqBem6000    , 'BRA');
  RegistraImpCheque ('BEMATECH MP7000 THFI' , TImpCheqBem7000    , 'BRA');
  RegistraCMC7      ('BEMATECH MP6000 THFI' , TCmc7Bem6000       , 'BRA');
  RegistraCMC7      ('BEMATECH MP7000 THFI' , TCmc7Bem6000       , 'BRA');
end.
