unit ImpFiscMain;

interface

uses
  Classes, System.SysUtils, Dialogs, IniFiles, Forms, LojxFun, FileCtrl,Windows,
  System.AnsiStrings;

const
  IMPCHEQ_NOERROR       = 0;
  IMPCHEQ_ERRNODRIVER   = -1;
  IMPCHEQ_ERRDUPLICATE  = -2;
  IMPCHEQ_ERROPENING    = -3;
  IMPCHEQ_ERRPRINTING   = -4;
  IMPCHEQ_ERRHANDLE     = -5;
  DEFAULT_PATHARQ       = 'c:\TOTVS PAF-ECF\';
  DEFAULT_ARQMEMSIM     = 'LMFS.TXT';
  DEFAULT_ARQMEMCOM     = 'LMFC.TXT';
  DEFAULT_PATHARQMFD    = 'ARQ MFD\';         //Pasta onde sera gerado o arquivo de registro TipoE (SE ALTERADO TERA QUE SER ALTERADO LOJXECF)
  ArqDownTXT  = 'DOWNLOAD.TXT';
  ArqTipRegE  = 'COTEPE1704.TXT';
  MsgIndsMFD  = 'Comando disponível apenas para ECF´s com MFD (Memória de Fita Detalhe).';
  MsgIndsImp  = 'Função não disponível para este equipamento';
  MsgErroProp = 'Não foi possivel Carregar Propriedades. Verifique a Impressora.';


  function  ImpFiscAbrir( sModelo,sPorta:PChar;iHdlMain:Integer ):Integer; StdCall;
  function  ImpFiscFechar( iHdl:Integer;sPorta:PChar ):Integer; StdCall;
  function  ImpFiscListar( var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscLeituraX( iHdl:Integer ):Integer; StdCall;
  function  ImpFiscReducaoZ( iHdl:Integer; var MapaRes:AnsiString ):Integer; StdCall;
  function  ImpFiscAbreCupom( iHdl:Integer;Cliente:pChar;MensagemRodape:pChar ):Integer; StdCall;
  function  ImpFiscPegaCupom( iHdl:Integer; var aBuff:AnsiString; Cancelamento:PAnsiChar ):Integer; StdCall;
  function  ImpFiscPegaPDV( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscRegistraItem( iHdl:Integer;codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:PChar; nTipoImp:Integer):Integer; StdCall;
  function  ImpFiscLeAliquotas( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscLeAliquotasISS( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscLeCondPag( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscGravaCondPag( iHdl:Integer;condicao:PChar ):Integer; StdCall;
  function  ImpFiscCancelaItem( iHdl:Integer;numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:PChar ):Integer; StdCall;
  function  ImpFiscCancelaCupom( iHdl:Integer;Supervisor:PChar ):Integer; StdCall;
  function  ImpFiscFechaCupom( iHdl:Integer; var Mensagem:AnsiString ):Integer; StdCall;
  function  ImpFiscPagamento( iHdl:Integer;Pagamento,Vinculado,Percepcion:PChar):Integer; StdCall;
  function  ImpFiscDescontoTotal( iHdl:Integer;vlrDesconto:PChar; nTipoImp:Integer ):Integer; StdCall;
  function  ImpFiscAcrescimoTotal( iHdl:Integer;vlrAcrescimo:PChar ):Integer; StdCall;
  function  ImpFiscMemoriaFiscal( iHdl:Integer;DataInicio,DataFim,ReducInicio,ReducFim,Tipo:Pchar ):Integer; StdCall;
  function  ImpFiscAdicionaAliquota( iHdl:Integer;Aliquota,Tipo:PChar ):Integer; StdCall;
  function  ImpFiscAbreCupomNaoFiscal( iHdl:Integer;Condicao,Valor,Totalizador,Texto:PChar ):Integer; StdCall;
  function  ImpFiscTextoNaoFiscal( iHdl:Integer;Texto:PChar;Vias:Integer ):Integer; StdCall;
  function  ImpFiscFechaCupomNaoFiscal( iHdl:Integer ):Integer; StdCall;
  function  ImpFiscReImpCupomNaoFiscal( iHdl:Integer; Texto:PChar ):Integer; StdCall;
  function  ImpFiscStatus( iHdl:Integer;Tipo: pChar; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscTotalizadorNaoFiscal( iHdl:Integer;Numero,Descricao:PChar ):Integer; StdCall;
  function  ImpFiscAutenticacao( iHdl:Integer;Vezes,Valor,Texto:PChar ):Integer; StdCall;
  function  ImpFiscGaveta( iHdl:Integer ):Integer; StdCall;
  function  ImpCheque ( iHdl:Integer;Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:PChar ):Integer; StdCall;
  function  ImpChequeTransf( iHdl:Integer; Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Integer; StdCall;
  function  ImpFiscAbreECF ( iHdl:Integer ):Integer; StdCall;
  function  ImpFiscFechaECF ( iHdl:Integer ):Integer; StdCall;
  function  ImpFiscSuprimento ( iHdl, Tipo:Integer; Valor:PChar; Forma:PChar; Total:Pchar; Modo:Integer; FormaSupr:PChar ):Integer; StdCall;
  function  ImpFiscHorarioVerao ( iHdl:Integer; Tipo:PChar ):Integer; StdCall;
  function  ImpFiscRelatorioGerencial ( iHdl:Integer;Texto:PChar;Vias:Integer; ImgQrCode: PChar):Integer; StdCall;
  function  ImpFiscCodBarrasITF ( iHdl:Integer;Cabecalho,Codigo,Rodape:PChar;Vias:Integer ):Integer; StdCall;
  function  ImpFiscAlimentaPropEmulECF ( iHdl:Integer; sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:Pchar ):Integer; StdCall;
  function  ImpFiscSubTotal( iHdl:Integer; sImprime: pChar; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscNumItem( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscPegaSerie( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscImpostosCupom( iHdl:Integer; aBuff:AnsiString): Integer; StdCall;
  function  ImpFiscPedido( iHdl:Integer; Totalizador, Tef, Texto, Valor, CondPagTef:PChar ): Integer; StdCall;
  function  ImpFiscEnvCmd( iHdl:Integer; Comando: PChar; Posicao: PChar; var aBuff:AnsiString ): Integer; StdCall;
  function  ImpFiscRecebNFis( iHdl:Integer; Totalizador, Valor, Forma:PChar ): Integer; StdCall;
  function  ImpFiscReImprime( iHdl:Integer ):Integer; StdCall;
  function  ImpFiscPercepcao( iHdl:Integer; AliqIVA, Texto, Valor: Pchar):Integer; StdCall;
  function  ImpFiscAbreDNFH (iHdl:Integer; TipoDoc, DadosCli, DadosCab, DocOri,
                 TipoImp, IdDoc: Pchar; var aBuff:AnsiString ): Integer; StdCall;
  function  ImpFiscFechaDNFH( iHdl:Integer ):Integer; StdCall;
  function  ImpFiscTextoRecibo (iHdl:Integer; Texto: Pchar): Integer; StdCall;
  function  ImpFiscMemTrab( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscCapacidade( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscAbreNota( iHdl:Integer;Cliente:AnsiString ):Integer; StdCall;
  function  ImpFiscAbreCupomRest(iHdl:Integer;Mesa, Cliente: PChar):Integer; StdCall;
  function  ImpFiscRegistraItemRest( iHdl:Integer;Mesa, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: PChar):Integer; StdCall;
  function  ImpFiscCancelaItemRest( iHdl:Integer;Mesa,Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: PChar):Integer; StdCall;
  function  ImpFiscConferenciaMesa( iHdl:Integer;Mesa, Acres, Desc: PChar):Integer; StdCall;
  function  ImpFiscImprimeCardapio( iHdl:Integer ):Integer; StdCall;
  function  ImpFiscLeCardapio( iHdl:Integer ):Integer; StdCall;
  function  ImpFiscLeMesasAbertas( iHdl:Integer; var aBuff:AnsiString):Integer; StdCall;
  function  ImpFiscRelatMesasAbertas(iHdl:Integer;Tipo: PChar):Integer; StdCall;
  function  ImpFiscLeRegistrosVendaRest(iHdl:Integer;Mesa: PChar; var aBuff:AnsiString):Integer; StdCall;
  function  ImpFiscFechaCupomMesa( iHdl:Integer;Pagamento, Acres, Desc, Mensagem:PChar ):Integer; StdCall;
  function  ImpFiscFechaCupContaDividida( iHdl:Integer;NumeroCupons, Acres, Desc, Pagamento, ValorCliente, Cliente: PChar):Integer; StdCall;
  function  ImpFiscTransfMesas( iHdl:Integer;Origem, Destino: PChar):Integer; StdCall;
  function  ImpFiscTransfItem( iHdl:Integer;MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc, MesaDestino: PChar):Integer; StdCall;
  function  ImpFiscDownMFD( iHdl:Integer; pTipo, pInicio, pFinal : pChar ):Integer; StdCall;
  function  ImpFiscGerRegTipoE( iHdl:Integer; pTipo, pInicio, pFinal, pRazao, pEnd, pBinario  : pChar):Integer; StdCall;
  function  ImpFiscGeraArquivoMFD ( iHdl:Integer; pDadoInicial, pDadoFinal, pTipoDownload: pChar ): Integer; StdCall;
  function  ImpFiscArqMFD( iHdl:Integer; pDadoInicial, pDadoFinal, pTipoDownload: pChar ): Integer; StdCall;
  function  ImpFiscReturnRecharge( iHdl:Integer; pDescricao, pValor, pAliquota, pTipo : pChar; iTipoImp : Integer ):Integer; StdCall;
  function  ImpFiscRelGerInd( iHdl:Integer; cIndTotalizador, Texto : PChar ; Vias: Integer; ImgQrCode: PChar):Integer; StdCall;
  function  ImpFiscLeTotNFisc( iHdl:Integer; var aBuff:AnsiString ):Integer; StdCall;
  function  ImpFiscDownMF(iHdl:Integer ; sTipo, sInicio, sFinal : Pchar):Integer; StdCall;
  function  ImpFiscRedZDado( iHdl:Integer; var MapaRes:AnsiString ):Integer; StdCall;
  function  ImpFiscIdCliente( iHdl:Integer; CPFCNPJ , Cliente , Endereco : pChar ): Integer; StdCall;
  function  ImpFiscEstornNFiscVinc( iHdl:Integer; CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC: pChar ): Integer; StdCall;
  function  ImpFiscImpTxtFis( iHdl: Integer; Texto: PChar) : Integer; StdCall;
  function  ImpFiscGrvQrCode( iHdl: Integer; SavePath,QrCode: PChar): Integer; StdCall;
  function  ImpFiscAbreCNF(iHdl: Integer;  CPFCNPJ, Nome, Endereco : PChar): Integer; StdCall;
  function  ImpFiscRecCNF(iHdl: Integer; IndiceTot , Valor, ValorAcresc,ValorDesc : PChar): Integer; StdCall;
  function  ImpFiscPgtoCNF(iHdl: Integer; FrmPagto , Valor,
                 InfoAdicional, ValorAcresc,ValorDesc : PChar): Integer; StdCall;
  function  ImpFiscFechaCNF(iHdl: Integer; Mensagem : PChar): Integer; StdCall;

  //TRAVA TECLADO
  function BlockInput(fbLookIt:Boolean):Integer; stdcall; external 'user32.dll';

Type
  ////////////////////////////////////////////////////////////////////////////
  //
  //  Driver básico de uma impressora
  //
  TImpressoraFiscal = Class(TObject)
  private
    fModelo     : AnsiString;
    fPorta      : AnsiString;
    fAliquotas  : AnsiString;
    fICMS       : AnsiString;
    fISS        : AnsiString;
    fFormasPgto : AnsiString;
    fPdv        : AnsiString;
    fSequencial : Integer;
    fValorPago  : Real;
    fValorVenda : Real;
    fNumCaixa   : AnsiString;
    fNomeCaixa  : AnsiString;
    fNumCupom   : AnsiString;
    fItens      : Integer;
    fItemNumero : Integer;
    fEprom      : AnsiString;

    //Variaveis necessarias para o PAF - ECF
    fCnpj           : AnsiString;         // CNPJ do estabelecimento usuário do ECF
    fIe             : AnsiString;         // Inscrição Estadual do estabelecimento usuário
    fNumLoja        : AnsiString;         // Numero da loja cadastrado no ECF
    fNumSerie       : AnsiString;         // Numero da Serie
    fTipoEcf        : AnsiString;         // Tipo de ECF
    fMarcaEcf       : AnsiString;         // Marca do ECF
    fModeloEcf      : AnsiString;         // Modelo do ECF
    fDataIntEprom   : AnsiString;         // Data de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
    fHoraIntEprom   : AnsiString;         // Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
    fContadorCro    : AnsiString;         // Contador de reinicio de operacao
    fContadorCrz    : AnsiString;         // Contador de reduçãoZ
    fIndicaMFAdi    : AnsiString;         // Letra indicativa de MF adicional
    fDataGrvUsuario : AnsiString;         // Data de gravação do último usuário da impressora
    fHoraGrvUsuario : AnsiString;         // Hora de gravação do último usuário da impressora
    fGTInicial      : AnsiString;         // Valor do Grande Total Inicial
    fGTFinal        : AnsiString;         // Valor do Grande Total Final
    fVendaBrutaDia  : AnsiString;         // Valor da Venda Bruta Diaria da Ultima ReducaoZ
    fPathArquivo    : AnsiString;         // Path onde sera gravado o arquivo
    fCodigoEcf      : AnsiString;         // Codigo do Ecf
    //--------------------------------------

    //Variavel de controle
    fReducaoEmitida : Boolean;
    //------------------------

  public
    constructor create( sModelo, sPorta, sCodEcf : AnsiString); virtual;

    function Abrir(sPorta:AnsiString;iHdlMain:Integer): AnsiString; virtual; abstract;
    function Fechar(sPorta:AnsiString): AnsiString; virtual; abstract;
    function LeituraX: AnsiString; virtual; abstract;
    function ReducaoZ(MapaRes:AnsiString): AnsiString; virtual; abstract;
    function AbreCupom(Cliente:AnsiString; MensagemRodape: AnsiString): AnsiString; virtual; abstract;
    function PegaCupom(Cancelamento:AnsiString): AnsiString; virtual; abstract;
    function PegaPDV: AnsiString; virtual; abstract;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; virtual; abstract;
    function LeAliquotas: AnsiString; virtual; abstract;
    function LeAliquotasISS: AnsiString; virtual; abstract;
    function LeCondPag: AnsiString; virtual; abstract;
    function GravaCondPag( condicao:AnsiString ):AnsiString; virtual; abstract;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; virtual; abstract;
    function CancelaCupom( Supervisor:AnsiString ): AnsiString; virtual; abstract;
    function FechaCupom( Mensagem:AnsiString ): AnsiString; virtual; abstract;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString): AnsiString; virtual; abstract;
    function DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString; virtual; abstract;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; virtual; abstract;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; virtual; abstract;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; virtual; abstract;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; virtual; abstract;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ): AnsiString; virtual; abstract;
    function FechaCupomNaoFiscal: AnsiString; virtual; abstract;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; virtual; abstract;
    function Status( Tipo:Integer;Texto:AnsiString ): AnsiString; virtual; abstract;
    function StatusImp( Tipo:Integer ): AnsiString; virtual; abstract;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ): AnsiString; virtual; abstract;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; virtual; abstract;
    function Gaveta: AnsiString; virtual; abstract;
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString; virtual; abstract;
    function ChequeTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:AnsiString ):AnsiString; virtual; abstract;
    function AbreECF: AnsiString; virtual; abstract;
    function FechaECF: AnsiString; virtual; abstract;
    function Suprimento( Tipo:Integer; Valor:AnsiString; Forma:AnsiString; Total:AnsiString;  Modo:Integer; FormaSupr:AnsiString ):AnsiString; virtual; abstract;
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer;ImgQrCode: AnsiString):AnsiString; virtual; abstract;
    function ImprimeCodBarrasITF( Cabecalho, Codigo, Rodape:AnsiString ;Vias:Integer):AnsiString; virtual; abstract;
    function HorarioVerao( Tipo:AnsiString ):AnsiString; virtual; abstract;
    function AlimentaPropEmulECF( sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:AnsiString ):AnsiString; virtual; abstract;
    procedure AlimentaProperties; virtual; abstract;
    function SubTotal(sImprime: AnsiString) : AnsiString; virtual; abstract;
    function NumItem : AnsiString; virtual; abstract;
    function PegaSerie: AnsiString; virtual; abstract;
    function ImpostosCupom(Texto: AnsiString): AnsiString; virtual; abstract;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; virtual; abstract;
    function EnvCmd( Comando:AnsiString; Posicao: Integer ): AnsiString; virtual; abstract;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; virtual; abstract;
    function ReImprime: AnsiString; virtual; abstract;
    function Percepcao(sAliqIVA, sTexto, sValor: AnsiString): AnsiString; virtual; abstract;
    function AbreDNFH (sTipoDoc, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: AnsiString):AnsiString; virtual; abstract;
    function FechaDNFH: AnsiString; virtual; abstract;
    function TextoRecibo (sTexto: AnsiString): AnsiString; virtual; abstract;
    function MemTrab: AnsiString; virtual; abstract;
    function Capacidade: AnsiString; virtual; abstract;
    function AbreNota(Cliente:AnsiString): AnsiString; virtual; abstract;
    function AbreCupomRest(Mesa, Cliente: AnsiString):AnsiString; virtual; abstract;
    function RegistraItemRest( Mesa, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: AnsiString): AnsiString; virtual; abstract;
    function CancelaItemRest( Mesa,Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: AnsiString): AnsiString; virtual; abstract;
    function ConferenciaMesa( Mesa, Acres, Desc: AnsiString):AnsiString; virtual; abstract;
    function ImprimeCardapio:AnsiString; virtual; abstract;
    function LeCardapio:AnsiString; virtual; abstract;
    function LeMesasAbertas:AnsiString; virtual; abstract;
    function RelatMesasAbertas(Tipo: AnsiString):AnsiString; virtual; abstract;
    function LeRegistrosVendaRest(Mesa: AnsiString):AnsiString; virtual; abstract;
    function FechaCupomMesa( Pagamento, Acres, Desc, Mensagem:AnsiString ): AnsiString; virtual; abstract;
    function FechaCupContaDividida( NumeroCupons, Acres, Desc, Pagamento, ValorCliente, Cliente: AnsiString): AnsiString; virtual; abstract;
    function TransfMesas( Origem, Destino: AnsiString): AnsiString; virtual; abstract;
    function TransfItem( MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc, MesaDestino: AnsiString): AnsiString; virtual; abstract;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; virtual; abstract;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString):AnsiString; virtual; abstract;
    function ReturnRecharge( sDescricao, sValor, sAliquota, sTipo : AnsiString; iTipoImp : Integer ):AnsiString; virtual; abstract;
    function GeraArquivoMFD( cDadoInicial: AnsiString; cDadoFinal: AnsiString; cTipoDownload: AnsiString; cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica: AnsiString; cChavePrivada: AnsiString; iUnicoArquivo: integer ): AnsiString;  virtual; abstract;
    function ArqMFD( cDadoInicial: AnsiString; cDadoFinal: AnsiString; cTipoDownload: AnsiString; cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica: AnsiString; cChavePrivada: AnsiString; iUnicoArquivo: integer ): AnsiString;  virtual; abstract;
    function RelGerInd( cIndTotalizador, Texto : AnsiString ; Vias: Integer ; ImgQrCode: AnsiString):AnsiString; virtual; abstract;
    function LeTotNFisc: AnsiString; virtual; abstract;
    function DownMF(sTipo, sInicio, sFinal : AnsiString): AnsiString; virtual; abstract;
    function RedZDado(MapaRes:AnsiString): AnsiString; virtual; abstract;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; virtual; abstract;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; virtual; abstract;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; virtual; abstract;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; virtual; abstract;
    function  AbreCNF(CPFCNPJ, Nome, Endereco : AnsiString): AnsiString; virtual; abstract;
    function  RecCNF( IndiceTot , Valor, ValorAcresc,ValorDesc : AnsiString): AnsiString; virtual; abstract;
    function  PgtoCNF( FrmPagto , Valor, InfoAdicional , ValorAcresc,ValorDesc : AnsiString): AnsiString; virtual; abstract;
    function  FechaCNF( Mensagem : AnsiString): AnsiString; virtual; abstract;

    property Modelo : AnsiString read fModelo;
    property Porta  : AnsiString read fPorta;

  published
    property Aliquotas : AnsiString  read fAliquotas  write fAliquotas;
    property ICMS      : AnsiString  read fICMS       write fICMS;
    property ISS       : AnsiString  read fISS        write fISS;
    property FormasPgto: AnsiString  read fFormasPgto write fFormasPgto;
    property Sequencial: Integer read fSequencial write fSequencial DEFAULT 0;
    property Pdv       : AnsiString  read fPdv        write fPdv;
    property ValorPago : Real    read fValorPago  write fValorPago;
    property ValorVenda: Real    read fValorVenda write fValorVenda;
    property NumCaixa  : AnsiString  read fNumCaixa   write fNumCaixa;
    property NomeCaixa : AnsiString  read fNomeCaixa  write fNomeCaixa;
    property NumCupom  : AnsiString  read fNumCupom   write fNumCupom;
    property Itens     : Integer read fItens      write fItens DEFAULT 0;
    property ItemNumero: Integer read fItemNumero write fItemNumero DEFAULT 0;
    property Eprom     : AnsiString  read fEprom      write fEprom;

    //Propriedades necessarias para o PAF - ECF
    property Cnpj           : AnsiString  read fCnpj           write fCnpj;
    property Ie             : AnsiString  read fIe             write fIe;
    property NumLoja        : AnsiString  read fNumLoja        write fNumLoja;
    property NumSerie       : AnsiString  read fNumSerie       write fNumSerie;
    property TipoEcf        : AnsiString  read fTipoEcf        write fTipoEcf;
    property MarcaEcf       : AnsiString  read fMarcaEcf       write fMarcaEcf;
    property ModeloEcf      : AnsiString  read fModeloEcf      write fModeloEcf;
    property DataIntEprom   : AnsiString  read fDataIntEprom   write fDataIntEprom;
    property HoraIntEprom   : AnsiString  read fHoraIntEprom   write fHoraIntEprom;
    property ContadorCro    : AnsiString  read fContadorCro    write fContadorCro;
    property ContadorCrz    : AnsiString  read fContadorCrz    write fContadorCrz;
    property IndicaMFAdi    : AnsiString  read fIndicaMFAdi    write fIndicaMFAdi;
    property DataGrvUsuario : AnsiString  read fDataGrvUsuario write fDataGrvUsuario;
    property HoraGrvUsuario : AnsiString  read fHoraGrvUsuario write fHoraGrvUsuario;
    property GTInicial      : AnsiString  read fGTInicial      write fGTInicial;
    property GTFinal        : AnsiString  read fGTFinal        write fGTFinal;
    property VendaBrutaDia  : AnsiString  read fVendaBrutaDia  write fVendaBrutaDia;
    property PathArquivo    : AnsiString  read fPathArquivo    write fPathArquivo;
    property CodigoEcf      : AnsiString  read fCodigoEcf      write fCodigoEcf;
   //-----------------------------------------

    //Propriedades de controle
    property ReducaoEmitida : Boolean  read fReducaoEmitida  write fReducaoEmitida;
    //-------------------------

  end;

  TImpressoraFiscalClass = class of TImpressoraFiscal;
  //
  /////////////////////////////////////////////////////////////////////////////

  procedure RegistraImpressora(sModelo: AnsiString; cClass: TImpressoraFiscalClass; sPaises:AnsiString; sCodECF:AnsiString=' ');

implementation

Type
  /////////////////////////////////////////////////////////////////////////////
  //
  //  TListaDrivers  - Lista com os Drivers
  //
  TListaDrivers = class(TStringList)
  public
    function  RegistraImpressora( sModelo: AnsiString; cClass: TImpressoraFiscalClass; sPaises:AnsiString; sCodECF:AnsiString=' ' ): Boolean;
    function  CriaImpressora( sModelo, sPorta: AnsiString; iHdlMain: Integer ): TImpressoraFiscal;
  end;
  //
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  //
  //  Lista com as impressoras
  //
  TListaImpressoras = class(TStringList)
  public
    destructor Destroy; override;

    function fAcha( iHdl:Integer ): TImpressoraFiscal;
    function fCriaImp ( sModelo,sPorta:AnsiString; iHdlMain:Integer ):AnsiString;
    function fApagaImp ( iHdl:Integer; sPorta:AnsiString ):AnsiString;
    function fLeituraX ( iHdl:Integer ):AnsiString;
    function fReducaoZ ( iHdl:Integer; MapaRes:AnsiString  ):AnsiString;
    function fAbreCupom ( iHdl:Integer;Cliente:AnsiString;MensagemRodape:AnsiString ):AnsiString;
    function fPegaCupom ( iHdl:Integer;Cancelamento:AnsiString ):AnsiString;
    function fPegaPDV ( iHdl:Integer ):AnsiString;
    function fRegistraItem ( iHdl:Integer; codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
    function fLeAliquotas ( iHdl:Integer ):AnsiString;
    function fLeAliquotasISS ( iHdl:Integer ):AnsiString;
    function fLeCondPag ( iHdl:Integer ):AnsiString;
    function fGravaCondPag( iHdl:Integer; Condicao:AnsiString ):AnsiString;
    function fCancelaItem ( iHdl:Integer;numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
    function fCancelaCupom ( iHdl:Integer;Supervisor:AnsiString ):AnsiString;
    function fFechaCupom ( iHdl:Integer; Mensagem:AnsiString ):AnsiString;
    function fPagamento ( iHdl:Integer; Pagamento,Vinculado,Percepcion:AnsiString): AnsiString;
    function fDescontoTotal ( iHdl:Integer; vlrDesconto:AnsiString ; nTipoImp:Integer ):AnsiString;
    function fAcrescimoTotal ( iHdl:Integer; vlrAcrescimo:AnsiString ):AnsiString;
    function fMemoriaFiscal ( iHdl:Integer; DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString ):AnsiString;
    function fAdicionaAliquota ( iHdl:Integer; Aliquota:AnsiString; Tipo:Integer ):AnsiString;
    function fAbreCupomNaoFiscal ( iHdl:Integer; Condicao,Valor,Totalizador,Texto:AnsiString ):AnsiString;
    function fTextoNaoFiscal ( iHdl:Integer; Texto:AnsiString;Vias:Integer ):AnsiString;
    function fFechaCupomNaoFiscal ( iHdl:Integer ):AnsiString;
    function fReImpCupomNaoFiscal ( iHdl:Integer; Texto:AnsiString ):AnsiString;
    function fStatus ( iHdl,Tipo:Integer ):AnsiString;
    function fTotalizadorNaoFiscal( iHdl:Integer; Numero,Descricao:AnsiString ):AnsiString;
    function fAutenticacao ( iHdl,Vezes:Integer;Valor,Texto:AnsiString ):AnsiString;
    function fGaveta ( iHdl:Integer ):AnsiString;
    function fCheque ( iHdl:Integer; Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ):AnsiString;
    function fChequeTransf( iHdl:Integer; Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:AnsiString ):AnsiString;
    function fAbreECF ( iHdl:Integer ):AnsiString;
    function fFechaECF ( iHdl:Integer ):AnsiString;
    function fSuprimento ( iHdl,Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
    function fRelatorioGerencial ( iHdl:Integer;Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString ):AnsiString;
    function fImprimeCodBarrasITF ( iHdl:Integer;Cabecalho,Codigo,Rodape:AnsiString;Vias:Integer ):AnsiString;
    function fHorarioVerao( iHdl:Integer;Tipo:AnsiString ):AnsiString;
    function fAlimentaPropEmulECF( iHdl:Integer; sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:AnsiString ):AnsiString;
    function fSubTotal ( iHdl:Integer; sImprime: AnsiString ):AnsiString;
    function fNumItem ( iHdl:Integer ):AnsiString;
    function fPegaSerie ( iHdl:Integer ):AnsiString;
    function fImpostosCupom(iHdl:Integer; Texto: AnsiString): AnsiString;
    function fPedido( iHdl:Integer; Totalizador, Tef, Texto, Valor, CondPagTef: AnsiString ): AnsiString;
    function fEnvCmd( iHdl:Integer; Comando: AnsiString; Posicao: Integer ): AnsiString;
    function fRecebNFis( iHdl:Integer; Totalizador, Valor, Forma: AnsiString ): AnsiString;
    function fReImprime( iHdl:Integer ):AnsiString;
    function fPercepcao( iHdl:Integer; AliqIVA, Texto, Valor: AnsiString): AnsiString;
    function fAbreDNFH ( iHdl:Integer; TipoDoc, DadosCli, DadosCab, DocOri, TipoImp, IdDoc: AnsiString):AnsiString;
    function fFechaDNFH( iHdl:Integer ): AnsiString;
    function fTextoRecibo (iHdl:Integer; Texto: AnsiString): AnsiString;
    function fMemTrab ( iHdl:Integer ):AnsiString;
    function fCapacidade ( iHdl:Integer ):AnsiString;
    function fAbreNota ( iHdl:Integer;Cliente:AnsiString ):AnsiString;
    function fAbreCupomRest(iHdl:Integer;Mesa, Cliente: AnsiString):AnsiString;
    function fRegistraItemRest( iHdl:Integer;Mesa, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: AnsiString): AnsiString;
    function fCancelaItemRest( iHdl:Integer;Mesa,Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc: AnsiString): AnsiString;
    function fConferenciaMesa( iHdl:Integer;Mesa, Acres, Desc: AnsiString):AnsiString;
    function fImprimeCardapio( iHdl:Integer ):AnsiString;
    function fLeCardapio( iHdl:Integer ):AnsiString;
    function fLeMesasAbertas( iHdl:Integer ):AnsiString;
    function fRelatMesasAbertas(iHdl:Integer;Tipo: AnsiString):AnsiString;
    function fLeRegistrosVendaRest(iHdl:Integer;Mesa: AnsiString):AnsiString;
    function fFechaCupomMesa( iHdl:Integer;Pagamento, Acres, Desc, Mensagem:AnsiString ): AnsiString;
    function fFechaCupContaDividida( iHdl:Integer;NumeroCupons, Acres, Desc, Pagamento, ValorCliente, Cliente: AnsiString): AnsiString;
    function fTransfMesas( iHdl:Integer;Origem, Destino: AnsiString): AnsiString;
    function fTransfItem( iHdl:Integer;MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc, MesaDestino: AnsiString): AnsiString;
    function fDownloadMFD( iHdl:Integer; sTipo, sInicio, sFinal : AnsiString ):AnsiString;
    function fGeraRegTipoE( iHdl:Integer; sTipo, sInicio, sFinal, sRazao, sEnd,  sBinario  : AnsiString):AnsiString;
    function fReturnRecharge( iHdl:Integer; sDescricao, sValor, sAliquota, sTipo : AnsiString; iTipoImp : Integer ):AnsiString;
    function fGeraArquivoMFD( iHdl:Integer; cDadoInicial: AnsiString; cDadoFinal: AnsiString; cTipoDownload: AnsiString; cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica: AnsiString; cChavePrivada: AnsiString; iUnicoArquivo: integer ): AnsiString;
    function fArqMFD( iHdl:Integer; cDadoInicial: AnsiString; cDadoFinal: AnsiString; cTipoDownload: AnsiString; cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica: AnsiString; cChavePrivada: AnsiString; iUnicoArquivo: integer ): AnsiString;
    function fRelGerInd( iHdl:Integer; cIndTotalizador, Texto : AnsiString ; Vias: Integer ; ImgQrCode: AnsiString):AnsiString;
    function fLeTotNFisc ( iHdl:Integer ):AnsiString;
    function fDownMF ( iHdl:Integer ; sTipo, sInicio, sFinal : AnsiString):AnsiString;
    function fRedZDado( iHdl:Integer;MapaRes:AnsiString  ):AnsiString;
    function fIdCliente( iHdl:Integer; CPFCNPJ , Cliente , Endereco : AnsiString ): AnsiString;
    function fEstornNFiscVinc( iHdl : Integer ; CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
    function fImpTxtFis( iHdl: Integer; Texto: AnsiString): AnsiString;
    function fGrvQrCode( iHdl: Integer; SavePath,QrCode: AnsiString): AnsiString;
    function  fAbreCNF(iHdl: Integer; CPFCNPJ, Nome, Endereco : AnsiString): AnsiString;
    function  fRecCNF(iHdl: Integer; IndiceTot , Valor, ValorAcresc,ValorDesc   : AnsiString): AnsiString;
    function  fPgtoCNF(iHdl: Integer; FrmPagto , Valor, InfoAdicional, ValorAcresc,ValorDesc  : AnsiString): AnsiString;
    function  fFechaCNF(iHdl: Integer; Mensagem : AnsiString): AnsiString;
  end;
  //
  /////////////////////////////////////////////////////////////////////////////

var
  _z_ListaDrivers : TLISTADRIVERS;
  _z_ListaImpressoras: TListaImpressoras;

//////////////////////////////////////////////////////////////////////////////
//
//  TImpressoraFiscal.Create
//
constructor TImpressoraFiscal.Create(sModelo, sPorta, sCodEcf: AnsiString);
var
  IniFile : TIniFile;
begin
  fModelo     := sModelo;
  fPorta      := sPorta;
  fCodigoEcf  := sCodEcf;

  //Carrega Path
  try
    IniFile := TIniFile.Create(ExpandFileName('sigaloja.ini'));
    fPathArquivo := IniFile.ReadString('paf-ecf', 'patharquivo', DEFAULT_PATHARQ );

    If not (Copy(fPathArquivo , Length(fPathArquivo), 1) = '\') then
      fPathArquivo := fPathArquivo + '\';

    IniFile.Free;
  except
    fPathArquivo := DEFAULT_PATHARQ;
  end;

end;
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
//  TListaDrivers
//
function  TListaDrivers.RegistraImpressora( sModelo: AnsiString; cClass: TImpressoraFiscalClass; sPaises:AnsiString; sCodECF:AnsiString=' ' ): Boolean;
var
  sPath : AnsiString;
  lOk : Boolean;
begin
  lOk := True;
  if sModelo = 'ECF Emulator' then
  begin
    // Pega o Path da SIGALOJA.DLL
    sPath := ExtractFilePath(Application.ExeName);
    if not FileExists(sPath+'ECFEMUL.INI') then
      lOk := False;
  end;

  Result := True;
  if lOk then
    if (IndexOf(sModelo) < 0) then
    begin
      AddObject(sModelo,TObject(cClass));
      AddObject(sPaises,TObject(cClass));
      AddObject(sCodECF,TObject(cClass));
    end
    else
      Result := False;

end;

//---------------------------------------------------------------------------

function  TListaDrivers.CriaImpressora( sModelo, sPorta: AnsiString; iHdlMain:Integer ): TImpressoraFiscal;
var
  iPos    : Integer;
  p       : Pointer;
  sCodEcf : AnsiString;
begin

  iPos    := IndexOf(sModelo);
  sCodEcf := Strings[iPos + 2];

  if (iPos < 0) Then
    Result := nil
  else
  begin
    p :=  TImpressoraFiscalClass( Objects[iPos] ).MethodAddress('TImpressoraFiscal');
    If not Assigned(p) then
      Result := TImpressoraFiscalClass( Objects[iPos] ).Create( sModelo, sPorta, sCodEcf )
    else
      Result := nil;
  end;
end;
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
//  TListaImpressoras
//
destructor TListaImpressoras.Destroy;
var
  i : Integer;
begin
  for i := 0 to Count-1 do
    if (Objects[i] <> nil) Then
      Objects[i].Free;
  inherited;
end;

//----------------------------------------------------------------------------
function TListaImpressoras.fAcha( iHdl: Integer ): TImpressoraFiscal;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TImpressoraFiscal(Objects[iHdl])
  else
    Result := nil;
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fApagaImp(iHdl:Integer;sPorta:AnsiString): AnsiString;
var
  aImp: TImpressoraFiscal;
begin
  aImp := fAcha(iHdl);
  if Assigned( aImp ) then
  begin
    aImp.Fechar(sPorta);
    //Objects[iHdl].Free;  Elgin da erro na hora de finalizar
    Objects[iHdl] := Nil;
    _z_ListaImpressoras.Delete(iHdl);
    result := '0|';
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fCriaImp(sModelo, sPorta: AnsiString; iHdlMain:Integer ): AnsiString;
var
  aImp: TImpressoraFiscal;
  sChave: AnsiString;
  sRet : AnsiString;
begin
  sChave := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);
  if (IndexOf(sChave) < 0) Then
  begin
    //tratamento pois este modelo foi removido e causou falha de comunicação no cliente
    If sModelo = 'DARUMA [FW] FS700 MATCH - V. 01.00.00' then
    begin
      GravaLog(' Abertura da DLL - Modelo (' + sModelo + ') não existe portanto '+
               ' verifique a correta versão do seu modelo e efetue a correção pela' +
               'rotina de Cadastro de Estação (LOJA121)');
      ShowMessage(' Abertura da DLL - Modelo (' + sModelo + ') não existe portanto '+
               ' verifique a correta versão do seu modelo e efetue a correção pela' +
               'rotina de Cadastro de Estação (LOJA121)');
      sModelo := 'DARUMA [FW] FS700 MATCH 2 - V. 01.00.00';
    end;

    GravaLog('SIGALOJA -> Modelo de impressora FISCAL carregado:'+ sModelo);
    GravaLog('SIGALOJA -> sPorta carregado:'+ sPorta);

    aImp := _z_ListaDrivers.CriaImpressora( sModelo, sPorta, iHdlMain );

    if Assigned(aImp) Then
    begin
      sRet := aImp.Abrir(sPorta,iHdlMain);
      if copy(sRet,1,1)<>'0' then  // erro, tenta fechar a porta e abri-la novamente
      begin
        sRet := aImp.Fechar(sPorta);
        sRet := aImp.Abrir(sPorta,iHdlMain);
      end;
      if copy(sRet,1,1)='0' Then
      begin
        Result := IntToStr(AddObject(sChave,aImp));
      end
      else
      begin
        aImp.Free;
        Result := '-1';
      end;
    end
    else
    begin
      GravaLog(' Modelo de Impressora FISCAL : ' + sModelo  + ' não encontrado ');
      ShowMessage(' Modelo de Impressora FISCAL : ' + sModelo  + ' não encontrado ');      
      Result := '-1';
    end;
  end
  else
    Result := '-1';

end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fLeituraX( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.LeituraX;
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fReducaoZ( iHdl:Integer; MapaRes:AnsiString  ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ReducaoZ( MapaRes );
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAbreCupom( iHdl:Integer;Cliente:AnsiString;MensagemRodape:AnsiString ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.AbreCupom(Cliente,MensagemRodape);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fPegaCupom( iHdl:Integer;Cancelamento:AnsiString ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.PegaCupom(Cancelamento);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fPegaPDV( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.PegaPDV;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fRegistraItem ( iHdl:Integer; codigo,descricao,qtde,
                                      vlrUnit,vlrdesconto,aliquota,vlTotIt,
                                      UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,
                                          aliquota,vlTotIt,UnidMed,nTipoImp );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fLeAliquotas( iHdl:Integer ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.LeAliquotas;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fLeAliquotasISS( iHdl:Integer ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.LeAliquotasISS;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fLeCondPag( iHdl:Integer ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.LeCondPag;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fGravaCondPag( iHdl:Integer;Condicao:AnsiString ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.GravaCondPag( Condicao );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fCancelaItem( iHdl:Integer;numitem,codigo,descricao,
                              qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.CancelaItem( numitem,codigo,descricao,qtde,
                                          vlrunit,vlrdesconto,aliquota );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fCancelaCupom( iHdl:Integer;Supervisor:AnsiString ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.CancelaCupom(Supervisor);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fImpostosCupom(iHdl:Integer; Texto: AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.ImpostosCupom(Texto);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fPagamento ( iHdl:Integer; Pagamento, Vinculado, Percepcion:AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.Pagamento( Pagamento, Vinculado, Percepcion );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fFechaCupom ( iHdl:Integer; Mensagem:AnsiString ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.FechaCupom( Mensagem );
    result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fDescontoTotal ( iHdl:Integer; vlrDesconto:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.DescontoTotal( vlrDesconto , nTipoImp );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAcrescimoTotal ( iHdl:Integer; vlrAcrescimo:AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.AcrescimoTotal( vlrAcrescimo );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fMemoriaFiscal ( iHdl:Integer; DataInicio,
                              DataFim:TDateTime ;ReducInicio,
                              ReducFim,Tipo:AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin

    // Verifica se Diretorio para gravaçao dos arquivos para o PAF-ECf existe
    If ExisteDir(aImp.fPathArquivo) Then
    begin
      sRet := aImp.MemoriaFiscal( DataInicio,DataFim,ReducInicio,ReducFim,Tipo );
      Result := sRet;
    end
    Else
      Result := '1|Erro ao Criar Diretório ' + aImp.fPathArquivo;

  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAdicionaAliquota ( iHdl:Integer; Aliquota:AnsiString; Tipo:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.AdicionaAliquota( Aliquota,Tipo );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAbreCupomNaoFiscal( iHdl:Integer; Condicao,
                                      Valor,Totalizador,Texto:AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
  nErro,nVal: Integer;
  bContinua : Boolean;
begin
  bContinua := True;

  Val(Totalizador,nVal,nErro);
  If nErro > 0 then
  begin
    ShowMessage('Totalizador : "' + Totalizador + '" enviado é inválido, use o índice (número) do totalizador');
    bContinua := False;
  end;

  aImp := fAcha( iHdl );
  if (bContinua) and (Assigned(aImp)) then
  begin
    sRet := aImp.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto );
    Result := sRet;
  end
  else Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fTextoNaoFiscal ( iHdl:Integer; Texto:AnsiString;Vias:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.TextoNaoFiscal( Texto, Vias );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fFechaCupomNaoFiscal ( iHdl:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.FechaCupomNaoFiscal;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fReImpCupomNaoFiscal ( iHdl:Integer;Texto:AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.ReImpCupomNaoFiscal( Texto );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fStatus ( iHdl,Tipo:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    // Tipo - Indica qual o status quer se obter da impressora:
    //    1 - Obtem a Hora da Impressora
    //    2 - Obtem a Data da Impressora
    //    3 - Verifica o Papel
    //    4 - Verifica se é possível cancelar um ou todos os itens.
    //    5 - Cupom Fechado ?
    //    6 - Ret. suprimento da impressora
    //    7 - ECF permite desconto por item
    //    8 - Verifica se o dia anterior foi fechado
    //    9 - Verifica o Status do ECF
    //   10 - Verifica se todos os itens foram impressos.
    //   11 - Data do movimento igual a data do dia ?
    //   12 - Impressora precisa abrir ECF ?
    sRet := aImp.StatusImp( Tipo );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fTotalizadorNaoFiscal ( iHdl:Integer; Numero,Descricao:AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.TotalizadorNaoFiscal( Numero,Descricao );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAutenticacao ( iHdl,Vezes:Integer;Valor,Texto:AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.Autenticacao( Vezes, Valor, Texto );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fGaveta( iHdl:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.Gaveta;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fCheque( iHdl:Integer;Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fChequeTransf( iHdl:Integer; Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );

  if Assigned( aImp ) then
  begin
    sRet := aImp.ChequeTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAbreECF ( iHdl:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.AbreECF;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fFechaECF ( iHdl:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.FechaECF;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fSuprimento ( iHdl, Tipo:Integer; Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.Suprimento( Tipo,Valor,Forma,Total,Modo,FormaSupr);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fRelatorioGerencial ( iHdl:Integer;Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.RelatorioGerencial(Texto,Vias,ImgQrCode);
    Result := sRet;
  end
  else
    Result := '1|';
end;
//-----------------------------------------------------------------------------
function TListaImpressoras.fImprimeCodBarrasITF ( iHdl:Integer;Cabecalho,Codigo,Rodape:AnsiString;Vias:Integer ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.ImprimeCodBarrasITF( Cabecalho,Codigo,Rodape,Vias );
    Result := sRet;
  end
  else
    Result := '1|';
end;


//------------------------------------------------------------------------------
function TListaImpressoras.fRelGerInd( iHdl:Integer; cIndTotalizador, Texto : AnsiString ; Vias: Integer;ImgQrCode: AnsiString):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    //Variavel já vem do protheus em maiuscula e sem espaços
    If cIndTotalizador = ''   //Quando não tem o título do totalizador, não impede a impressão e manda direto para impressão de gerencial comum
    then  sRet := aImp.RelatorioGerencial(Texto, Vias, ImgQrCode)
    else  sRet := aImp.RelGerInd(cIndTotalizador, Texto , Vias , ImgQrCode);

    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fHorarioVerao ( iHdl:Integer;Tipo:AnsiString ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.HorarioVerao( Tipo );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAlimentaPropEmulECF( iHdl:Integer; sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:AnsiString ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.AlimentaPropEmulECF( sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fSubTotal ( iHdl:Integer; sImprime: AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.SubTotal(sImprime);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fNumItem ( iHdl:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.NumItem;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fPegaSerie( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.PegaSerie;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fPedido ( iHdl:Integer; Totalizador, Tef,
                                   Texto, Valor, CondPagTef : AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fEnvCmd ( iHdl:Integer; Comando: AnsiString; Posicao: Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.EnvCmd( Comando, Posicao );
    Result := sRet;
  end
  else
  Begin
    Result := '-1';
  End;
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fRecebNFis ( iHdl:Integer; Totalizador, Valor, Forma: AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.RecebNFis( Totalizador, Valor, Forma );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//
/////////////////////////////////////////////////////////////////////////////

function TListaImpressoras.fReImprime( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ReImprime;
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fPercepcao( iHdl:Integer; AliqIVA, Texto, Valor: AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.Percepcao( AliqIVA, Texto, Valor );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAbreDNFH ( iHdl:Integer; TipoDoc, DadosCli,
                                   DadosCab, DocOri, TipoImp, IdDoc:AnsiString):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.AbreDNFH (TipoDoc, DadosCli, DadosCab, DocOri, TipoImp, IdDoc );
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fFechaDNFH( iHdl:Integer ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.FechaDNFH;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fTextoRecibo (iHdl:Integer; Texto: AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.TextoRecibo(Texto);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fMemTrab( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.MemTrab;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fCapacidade( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.Capacidade;
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAbreNota( iHdl:Integer;Cliente:AnsiString ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.AbreNota(Cliente);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fAbreCupomRest(iHdl:Integer; Mesa, Cliente: AnsiString):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.AbreCupomRest(Mesa, Cliente);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fRegistraItemRest( iHdl:Integer; Mesa, Codigo,
                                          Descricao, Aliquota, Qtde, VlrUnit,
                                          Acres, Desc: AnsiString): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.RegistraItemRest(Mesa, Codigo, Descricao, Aliquota,
                                                 Qtde, VlrUnit, Acres, Desc);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fCancelaItemRest( iHdl:Integer;Mesa,Codigo, Descricao,
                          Aliquota, Qtde, VlrUnit, Acres, Desc: AnsiString): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.CancelaItemRest( Mesa, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fConferenciaMesa( iHdl:Integer;Mesa, Acres, Desc: AnsiString):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ConferenciaMesa( Mesa, Acres, Desc);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fImprimeCardapio( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ImprimeCardapio;
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fLeCardapio( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.LeCardapio;
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fLeMesasAbertas( iHdl:Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.LeMesasAbertas;
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fRelatMesasAbertas(iHdl:Integer;Tipo: AnsiString):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.RelatMesasAbertas(Tipo);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fLeRegistrosVendaRest(iHdl:Integer;Mesa: AnsiString):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.LeRegistrosVendaRest(Mesa);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fFechaCupomMesa( iHdl:Integer;Pagamento, Acres, Desc, Mensagem:AnsiString ): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.FechaCupomMesa( Pagamento, Acres, Desc, Mensagem );
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fFechaCupContaDividida( iHdl:Integer;NumeroCupons, Acres, Desc, Pagamento, ValorCliente, Cliente: AnsiString): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.FechaCupContaDividida( NumeroCupons, Acres, Desc, Pagamento, ValorCliente, Cliente );
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fTransfMesas( iHdl:Integer;Origem, Destino: AnsiString): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.TransfMesas( Origem, Destino );
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fTransfItem( iHdl:Integer;MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc, MesaDestino: AnsiString): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.TransfItem( MesaOrigem, Codigo, Descricao, Aliquota, Qtde, VlrUnit, Acres, Desc, MesaDestino );
    result := sRet;
  end
  else
    result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fDownloadMFD( iHdl:Integer; sTipo, sInicio, sFinal : AnsiString): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin

    // Verifica se Diretorio para gravaçao dos arquivos para o PAF-ECf existe
    If ExisteDir(aImp.fPathArquivo) Then
    begin
      sRet := aImp.DownloadMFD( sTipo, sInicio, sFinal );
      result := sRet;
    end
    Else
      result := '1|Erro ao Criar Diretório ' + aImp.fPathArquivo;

  end
  else
    result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fGeraRegTipoE( iHdl:Integer; sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin

    // Verifica se Diretorio para gravaçao dos arquivos para o PAF-ECf existe
    If ExisteDir(aImp.fPathArquivo + DEFAULT_PATHARQMFD) Then
    begin
      sRet := aImp.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario );
      result := sRet;
    end
    Else
      result := '1|Erro ao Criar Diretório ' + aImp.fPathArquivo + DEFAULT_PATHARQMFD;

  end
  else
    result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fReturnRecharge( iHdl:Integer; sDescricao, sValor, sAliquota, sTipo : AnsiString; iTipoImp : Integer ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ReturnRecharge( sDescricao, sValor, sAliquota, sTipo, iTipoImp );
    result := sRet;
  end
  else
    result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fGeraArquivoMFD( iHdl:Integer; cDadoInicial: AnsiString; cDadoFinal: AnsiString; cTipoDownload: AnsiString; cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica: AnsiString; cChavePrivada: AnsiString; iUnicoArquivo: integer ): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.GeraArquivoMFD( cDadoInicial, cDadoFinal, cTipoDownload, cUsuario, iTipoGeracao, cChavePublica, cChavePrivada, iUnicoArquivo );
    result := sRet;
  end
  else
    result := '1|';
end;


//-----------------------------------------------------------------------------
function TListaImpressoras.fLeTotNFisc( iHdl:Integer ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.LeTotNFisc;
    Result := sRet;
  end
  else
    Result := '1|';
end;


//-----------------------------------------------------------------------------
function TListaImpressoras.fDownMF( iHdl:Integer; sTipo, sInicio, sFinal : AnsiString ):AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.DownMF(sTipo, sInicio, sFinal);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fArqMFD( iHdl:Integer; cDadoInicial: AnsiString; cDadoFinal: AnsiString; cTipoDownload: AnsiString; cUsuario: AnsiString; iTipoGeracao: integer; cChavePublica: AnsiString; cChavePrivada: AnsiString; iUnicoArquivo: integer ): AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ArqMFD( cDadoInicial, cDadoFinal, cTipoDownload, cUsuario, iTipoGeracao, cChavePublica, cChavePrivada, iUnicoArquivo );
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fRedZDado( iHdl:Integer;MapaRes:AnsiString  ):AnsiString;
var
  aImp : TImpressoraFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.RedZDado( MapaRes );
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fIdCliente( iHdl:Integer; CPFCNPJ , Cliente , Endereco : AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.IdCliente(CPFCNPJ , Cliente , Endereco);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.fEstornNFiscVinc( iHdl : Integer ; CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.EstornNFiscVinc(CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fImpTxtFis( iHdl : Integer ; Texto : AnsiString ): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.ImpTxtFis(Texto);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fGrvQrCode( iHdl: Integer; SavePath,QrCode: AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.GrvQrCode(SavePath,QrCode);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//------------------------------------------------------------------------------
function  TListaImpressoras.fAbreCNF( iHdl: Integer; CPFCNPJ, Nome, Endereco : AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.AbreCNF(CPFCNPJ, Nome, Endereco);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fRecCNF( iHdl: Integer; IndiceTot , Valor, ValorAcresc,ValorDesc : AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.RecCNF(IndiceTot , Valor, ValorAcresc,ValorDesc);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fPgtoCNF( iHdl: Integer; FrmPagto , Valor, InfoAdicional , ValorAcresc,ValorDesc : AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.PgtoCNF(FrmPagto , Valor, InfoAdicional , ValorAcresc , ValorDesc);
    Result := sRet;
  end
  else
    Result := '1|';
end;

//------------------------------------------------------------------------------
function TListaImpressoras.fFechaCNF( iHdl: Integer; Mensagem : AnsiString): AnsiString;
var
  sRet : AnsiString;
  aImp : TImpressoraFiscal;
begin
  aImp := fAcha( iHdl );
  if Assigned(aImp) then
  begin
    sRet := aImp.FechaCNF(Mensagem);
    Result := sRet;
  end
  else
    Result := '1|';
end;

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

procedure RegistraImpressora(sModelo: AnsiString; cClass: TImpressoraFiscalClass; sPaises:AnsiString; sCodECF:AnsiString=' ');
begin
  if (not _z_ListaDrivers.RegistraImpressora( sModelo, cClass, sPaises, sCodECF )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;

//----------------------------------------------------------------------------
function ImpFiscAbrir( sModelo,sPorta:PChar; iHdlMain:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
  oIniFile : TIniFile;
  HTela: THandle;
begin
  s := _z_ListaImpressoras.fCriaImp( sModelo, sPorta, iHdlMain );
  iPos := Pos('|',s);
  if iPos = 0
  then result := StrToInt( s )
  else result := StrToInt( copy(s,1,iPos-1) );

  oIniFile := TIniFile.Create(ExpandFileName('sigaloja.ini'));
  If oIniFile.SectionExists('PAF-ECF') then
  begin
    If oIniFile.ReadString('PAF-ECF','patharquivo','') <> '' then
    begin
      GravaLog(' Barra especial para PAF-ECF ativada ');
      HTela := FindWindow(Nil,'TOTVS PROTHEUS - MENU FISCAL INACESSÍVEL NESTA TELA');
      If HTela <> 0
      then SetWindowText(HTela,'TOTVS Protheus - PAF-ECF');
    End;
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscFechar( iHdl:Integer;sPorta:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fApagaImp( iHdl, StrPas(sPorta) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt( copy(s,1,iPos-1) );
end;

//----------------------------------------------------------------------------
function ImpFiscListar( var aBuff:AnsiString ):Integer;
begin
  aBuff := _z_ListaDrivers.CommaText;
  result := 0;
end;

//----------------------------------------------------------------------------
function ImpFiscLeituraX( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fLeituraX( iHdl );
  iPos := Pos('|',s);
  if iPos = 0
  then result := StrToInt( s )
  else result := StrToInt(copy(s,1,iPos-1)) ;
end;

//----------------------------------------------------------------------------
function ImpFiscReducaoZ( iHdl:Integer; var MapaRes:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fReducaoZ( iHdl, MapaRes );
  iPos := Pos('|',s);
  if iPos = 0
  then result := StrToInt( s )
  else
  begin
    MapaRes := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;

end;

//----------------------------------------------------------------------------
function ImpFiscAbreCupom( iHdl:Integer;Cliente:pChar;MensagemRodape:pChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAbreCupom( iHdl, Cliente , MensagemRodape );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscPegaCupom( iHdl:Integer; var aBuff:AnsiString; Cancelamento:PAnsiChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fPegaCupom( iHdl, Cancelamento );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscPegaPDV( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fPegaPDV( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := System.SysUtils.StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := System.SysUtils.StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscRegistraItem( iHdl:Integer;codigo,descricao,qtde,vlrUnit,
                              vlrdesconto,aliquota,vlTotIt,UnidMed:PChar;
                              nTipoImp:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fRegistraItem( iHdl,StrPas(codigo),
                                          StrPas(descricao),StrPas(qtde),StrPas(vlrUnit),
                                          StrPas(vlrdesconto),StrPas(aliquota),
                                          StrPas(vlTotIt), StrPas(UnidMed), nTipoImp );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscLeAliquotas( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fLeAliquotas( iHdl );
  iPos := Pos('|',s);
  if iPos = 0  then
  begin
    aBuff := ' ';
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscLeAliquotasISS( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fLeAliquotasISS( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscCancelaItem( iHdl:Integer;numitem,codigo,descricao,
                        qtde,vlrunit,vlrdesconto,aliquota:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fCancelaItem( iHdl,
                                         StrPas(numitem),
                                         StrPas(codigo),
                                         StrPas(descricao),
                                         StrPas(qtde),
                                         StrPas(vlrunit),
                                         StrPas(vlrdesconto),
                                         StrPas(aliquota) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscCancelaCupom( iHdl:Integer;Supervisor:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fCancelaCupom( iHdl, StrPas(Supervisor) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscImpostosCupom(iHdl:Integer;aBuff:AnsiString): Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fImpostosCupom( iHdl, aBuff) ;
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscFechaCupom( iHdl:Integer; var Mensagem:AnsiString ):Integer;
var
  s:AnsiString;
  sMensagem :AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fFechaCupom( iHdl, Mensagem );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
  begin
    sMensagem := Copy(s,iPos+1,Length(s));
    Mensagem := sMensagem ;
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscPagamento( iHdl:Integer;Pagamento:PChar;Vinculado:PChar;Percepcion:PChar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fPagamento( iHdl,
                                       StrPas(Pagamento),
                                       StrPas(Vinculado),
                                       StrPas(Percepcion) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscDescontoTotal( iHdl:Integer;vlrDesconto:PChar ; nTipoImp:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fDescontoTotal( iHdl,StrPas(vlrDesconto), nTipoImp );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscAcrescimoTotal( iHdl:Integer;vlrAcrescimo:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAcrescimoTotal( iHdl,StrPas(vlrAcrescimo) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscMemoriaFiscal( iHdl:Integer;DataInicio,DataFim,ReducInicio,ReducFim,Tipo:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  // Caso venha uma data vazia do Protheus
  If (DataInicio='  /  /  ') Or (DataInicio='  /  /    ')  then
     Datainicio:='01/01/01';
  If (DataFim='  /  /  ') Or (DataFim='  /  /    ') then
     DataFim:='01/01/01';

  s := _z_ListaImpressoras.fMemoriaFiscal( iHdl,
                                           StrToDate(StrPas(DataInicio)),
                                           StrToDate(StrPas(DataFim)),
                                           StrPas(ReducInicio),
                                           StrPas(ReducFim) ,
                                           StrPas(Tipo) );

  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscAdicionaAliquota( iHdl:Integer;Aliquota,Tipo:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAdicionaAliquota( iHdl,
                                              StrPas(Aliquota),
                                              StrToInt(StrPas(Tipo)) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscAbreCupomNaoFiscal( iHdl:Integer;Condicao,Valor,Totalizador,Texto:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAbreCupomNaoFiscal( iHdl,
                                                StrPas(Condicao),
                                                StrPas(Valor),
                                                StrPas(Totalizador),
                                                StrPas(Texto) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscTextoNaoFiscal( iHdl:Integer;Texto:PChar;Vias:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fTextoNaoFiscal( iHdl,StrPas(Texto),Vias );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscFechaCupomNaoFiscal( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fFechaCupomNaoFiscal( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscReImpCupomNaoFiscal( iHdl:Integer;Texto:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fReImpCupomNaoFiscal( iHdl,StrPas(Texto) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscStatus( iHdl:Integer;Tipo:pChar; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fStatus( iHdl, StrToInt(Tipo) );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscTotalizadorNaoFiscal( iHdl:Integer;Numero,Descricao:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fTotalizadorNaoFiscal( iHdl,
                                                  StrPas(Numero),
                                                  StrPas(Descricao) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscAutenticacao( iHdl:Integer;Vezes,Valor,Texto:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAutenticacao( iHdl,
                                          StrToInt(StrPas(Vezes)),
                                          StrPas(Valor),
                                          StrPas(Texto) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscLeCondPag( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fLeCondPag( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ';
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscGravaCondPag( iHdl:Integer;Condicao:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fGravaCondPag( iHdl, StrPas(Condicao) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscGaveta( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fGaveta( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscAbreNota( iHdl:Integer;Cliente:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAbreNota( iHdl, Cliente) ;
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    result := StrToInt( s );
  end
  else
  begin
    Cliente := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;


//----------------------------------------------------------------------------
function ImpCheque( iHdl:Integer;Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fCheque( iHdl,
                                    StrPas(Banco),
                                    StrPas(Valor),
                                    StrPas(Favorec),
                                    StrPas(Cidade),
                                    StrPas(Data),
                                    StrPas(Mensagem),
                                    StrPas(Verso),
                                    StrPas(Extenso) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpChequeTransf( iHdl:Integer; Banco, Valor, Cidade,
                           Data, Agencia, Conta, Mensagem:PChar ):Integer;
var
  s     : AnsiString;
  iPos  : Integer;
begin
  s := _z_ListaImpressoras.fChequeTransf( iHdl,
                                          StrPas( Banco ),
                                          StrPas( Valor ),
                                          StrPas( Cidade ),
                                          StrPas( Data ),
                                          StrPas( Agencia ),
                                          StrPas( Conta ),
                                          StrPas( Mensagem ) );

  iPos := Pos( '|', s );

  if iPos = 0 then
    Result := StrToInt( s )
  else
    Result := StrToInt( Copy( s, 1, iPos - 1 ) );
end;

//----------------------------------------------------------------------------
function ImpFiscAbreECF( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAbreECF( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscFechaECF( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fFechaECF( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscSuprimento( iHdl,Tipo:Integer;Valor:PChar; Forma:Pchar;
                       Total:PChar; Modo:Integer; FormaSupr:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fSuprimento( iHdl,Tipo,Valor,Forma,Total,Modo,FormaSupr );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function  ImpFiscHorarioVerao ( iHdl:Integer; Tipo:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fHorarioVerao( iHdl,StrPas(Tipo) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function  ImpFiscRelatorioGerencial( iHdl:Integer;Texto:PChar;Vias:Integer; ImgQrCode: Pchar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fRelatorioGerencial( iHdl,StrPas(Texto),Vias, StrPas(ImgQrCode));
  iPos := Pos('|',s);
  if iPos = 0
  then Result := StrToInt( s )
  else Result := StrToInt(copy(s,1,iPos-1));
end;
//----------------------------------------------------------------------------
function  ImpFiscCodBarrasITF( iHdl:Integer;Cabecalho:PChar;Codigo:PChar;Rodape:PChar;Vias:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fImprimeCodBarrasITF( iHdl,StrPas(Cabecalho),StrPas(Codigo),StrPas(Rodape),Vias );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------

function  ImpFiscRelGerInd( iHdl:Integer; cIndTotalizador, Texto : PChar ;
                                   Vias: Integer ; ImgQrCode: Pchar):Integer;
var
 s: AnsiString;
 iPos: Integer;
begin
  s := _z_ListaImpressoras.fRelGerInd( iHdl, StrPas(cIndTotalizador),
                                       StrPas(Texto), Vias , StrPas(ImgQrCode));
  iPos := Pos('|',s);
  if iPos = 0
  then result := StrToInt( s )
  else result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function  ImpFiscAlimentaPropEmulECF ( iHdl:Integer; sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:Pchar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAlimentaPropEmulECF( iHdl,StrPas(sNumPdv),StrPas(sNumCaixa),
                                                  StrPas(sNomeCaixa),StrPas(sNumCupom) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscSubTotal( iHdl:Integer; sImprime: PChar; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fSubTotal( iHdl, sImprime );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff :=  ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s)) ;
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscNumItem( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fNumItem( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := copy(s,iPos+1,Length(s)) ;
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscPegaSerie( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fPegaSerie( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function  ImpFiscPedido( iHdl:Integer; Totalizador, Tef, Texto,
                                           Valor, CondPagTef:PChar ): Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fPedido( iHdl, StrPas( Totalizador), StrPas(Tef),
                                          StrPas(Texto), StrPas(Valor), StrPas(CondPagTef) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;


//----------------------------------------------------------------------------
function ImpFiscEnvCmd( iHdl:Integer; Comando:PChar; Posicao: Pchar;
                                          var aBuff:AnsiString ): Integer;
var
  s: AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fEnvCmd( iHdl, Comando, StrToInt(Posicao) );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff:= ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;

end;

//----------------------------------------------------------------------------
function ImpFiscRecebNFis( iHdl:Integer; Totalizador, Valor, Forma:PChar ): Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fRecebNFis( iHdl, StrPas( Totalizador), StrPas(Valor),
                                          StrPas(Forma));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;


//----------------------------------------------------------------------------
function ImpFiscReImprime( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fReImprime( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1)) ;
end;

//----------------------------------------------------------------------------
function ImpFiscPercepcao( iHdl:Integer; AliqIVA, Texto, Valor: Pchar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fPercepcao( iHdl, StrPas(AliqIVA), StrPas(Texto), StrPas(Valor));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1)) ;
end;

//----------------------------------------------------------------------------
function ImpFiscAbreDNFH (iHdl:Integer; TipoDoc, DadosCli, DadosCab, DocOri,
                       TipoImp, IdDoc: Pchar; var aBuff:AnsiString): Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAbreDNFH( iHdl, StrPas(TipoDoc), StrPas(DadosCli),
             StrPas(DadosCab), StrPas(DocOri), StrPas(TipoImp), StrPas(IdDoc) );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1)) ;
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscFechaDNFH( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fFechaDNFH( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1)) ;
end;

//----------------------------------------------------------------------------
function  ImpFiscTextoRecibo (iHdl:Integer; Texto: Pchar): Integer; StdCall;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fTextoRecibo( iHdl, StrPas(Texto));
  iPos := Pos('|',s);

  If (s = '') then
        s := '0';

  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1)) ;
end;

//----------------------------------------------------------------------------
function ImpFiscMemTrab( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fMemTrab( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//------------------------------------------------------------------------------
function ImpFiscDownMFD( iHdl:Integer; pTipo, pInicio, pFinal : pChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  if ( Trim( pInicio ) = '' ) AND ( pTipo = '1' )  then
     pInicio:='01/01/01';

  if ( Trim( pFinal ) = '' ) AND ( pTipo = '1' )  then
     pFinal:='01/01/01';

  if ( Trim( pInicio ) = '' ) AND ( pTipo = '2' )  then
     pInicio:='000001';

  if ( Trim( pFinal ) = '' ) AND ( pTipo = '2' )  then
     pFinal:='000001';

  s := _z_ListaImpressoras.fDownloadMFD( iHdl, StrPas( pTipo ),
                                         StrPas( pInicio ),
                                         StrPas( pFinal ) );

  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//------------------------------------------------------------------------------
function ImpFiscGerRegTipoE( iHdl:Integer; pTipo, pInicio, pFinal, pRazao, pEnd, pBinario : pChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  if ( Trim( pInicio ) = '' ) AND ( pTipo = '1' )  then
     pInicio:='01/01/01';

  if ( Trim( pFinal ) = '' ) AND ( pTipo = '1' )  then
     pFinal:='01/01/01';

  if ( Trim( pInicio ) = '' ) AND ( pTipo = '2' )  then
     pInicio:='000001';

  if ( Trim( pFinal ) = '' ) AND ( pTipo = '2' )  then
     pFinal:='000001';

  s := _z_ListaImpressoras.fGeraRegTipoE( iHdl, StrPas( pTipo )  ,
                                                StrPas( pInicio ),
                                                StrPas( pFinal ) ,
                                                StrPas( pRazao ) ,
                                                StrPas( pEnd ) ,
                                                StrPas( pBinario) );

  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//------------------------------------------------------------------------------
function ImpFiscReturnRecharge( iHdl:Integer; pDescricao, pValor, pAliquota,
                                   pTipo : pChar; iTipoImp : Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin

  s := _z_ListaImpressoras.fReturnRecharge( iHdl, StrPas( pDescricao )  ,
                                                StrPas( pValor ),
                                                StrPas( pAliquota ) ,
                                                StrPas( pTipo ) ,
                                                iTipoImp );

  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscGeraArquivoMFD( iHdl:Integer; pDadoInicial, pDadoFinal,
                                   pTipoDownload: pChar ): Integer; StdCall;
var
  s:AnsiString;
  iPos:Integer;
  iTipoGeracao: Integer;
  pChavePublica: AnsiString;
  pChavePrivada: AnsiString;

  pChavePublica2: pChar;
  pChavePrivada2: pChar;
  iUnicoArquivo: Integer;
  pUsuario: pChar;
begin
pUsuario      := '01';
iTipoGeracao  := 0;
//Função obriga o envio de uma chave, como assinatura será removida e adicionada por meio de função padrão do PAF-ECF no Protheus(LjxDSignPaf) foi enviado a chave de exemplo da bematech.
pChavePublica := 'A499F300F731F6892F44B83A5DD9D97CFFFD0ABE96E29B4B4B4EB2F9E5BCFFCF0A52EAFDF05779F90B3A199BE5776B13373CB2E71D8AB67F4080CE27B226FFF032B6A7182C90C935EF2F4D343A743B60307EE4961F0C5EB02B1CEEF48D647C02E9BE164DC404B833F80C5B4268C04039547E';
pChavePublica :=  pChavePublica + '7D5E242537B02360674B569208BD';

pChavePrivada := 'D19598300478932ACFFE16CB6903552F15FDBD2D3B9659FAD79C3603C07B875919E9D8B28919B8F4C20C6AE23268A636D1206F5E6BC79D89B6152804B15A9781C90E0A2D5064FB5B7CC01048AD8C66768F76D71647E7D39F8EDD714044CEA68F2A40106849132B01D14DDEB3FBA6FC1A9FBE';
pChavePrivada := pChavePrivada + '9EA71BAB9293707A4EAD29CB6F3D';

pChavePublica2 := pChar(pChavePublica);
pChavePrivada2 := pChar(pChavePrivada);
iUnicoArquivo   := 1;

  s := _z_ListaImpressoras.fGeraArquivoMFD( iHdl, StrPas( pDadoInicial )        ,
                                                  StrPas( pDadoFinal )          ,
                                                  StrPas( pTipoDownload )       ,
                                                  StrPas( pUsuario )            ,
                                                  iTipoGeracao                  ,
                                                  StrPas( pChavePublica2 )       ,
                                                  StrPas( pChavePrivada2 )       ,
                                                  iUnicoArquivo );

  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscArqMFD( iHdl:Integer; pDadoInicial, pDadoFinal, pTipoDownload: pChar ): Integer; StdCall;
var
  s:AnsiString;
  iPos:Integer;
  iTipoGeracao: Integer;
  pChavePublica: AnsiString;
  pChavePrivada: AnsiString;

  pChavePublica2: pChar;
  pChavePrivada2: pChar;
  iUnicoArquivo: Integer;
  pUsuario: pChar;
begin
pUsuario      := '01';
iTipoGeracao  := 1;
//Função obriga o envio de uma chave, como assinatura será removida e adicionada por meio de função padrão do PAF-ECF no Protheus(LjxDSignPaf) foi enviado a chave de exemplo da bematech.
pChavePublica := 'A499F300F731F6892F44B83A5DD9D97CFFFD0ABE96E29B4B4B4EB2F9E5BCFFCF0A52EAFDF05779F90B3A199BE5776B13373CB2E71D8AB67F4080CE27B226FFF032B6A7182C90C935EF2F4D343A743B60307EE4961F0C5EB02B1CEEF48D647C02E9BE164DC404B833F80C5B4268C04039547E';
pChavePublica :=  pChavePublica + '7D5E242537B02360674B569208BD';

pChavePrivada := 'D19598300478932ACFFE16CB6903552F15FDBD2D3B9659FAD79C3603C07B875919E9D8B28919B8F4C20C6AE23268A636D1206F5E6BC79D89B6152804B15A9781C90E0A2D5064FB5B7CC01048AD8C66768F76D71647E7D39F8EDD714044CEA68F2A40106849132B01D14DDEB3FBA6FC1A9FBE';
pChavePrivada := pChavePrivada + '9EA71BAB9293707A4EAD29CB6F3D';

pChavePublica2 := pChar(pChavePublica);
pChavePrivada2 := pChar(pChavePrivada);
iUnicoArquivo   := 1;

  s := _z_ListaImpressoras.fArqMFD( iHdl, StrPas( pDadoInicial )        ,
                                                  StrPas( pDadoFinal )          ,
                                                  StrPas( pTipoDownload )       ,
                                                  StrPas( pUsuario )            ,
                                                  iTipoGeracao                  ,
                                                  StrPas( pChavePublica2 )       ,
                                                  StrPas( pChavePrivada2 )       ,
                                                  iUnicoArquivo );

  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscCapacidade( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fCapacidade( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscAbreCupomRest(iHdl:Integer;Mesa, Cliente: PChar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fAbreCupomRest( iHdl, StrPas(Mesa), StrPas(Cliente) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscRegistraItemRest( iHdl:Integer;Mesa, Codigo, Descricao, Aliquota,
                                   Qtde, VlrUnit, Acres, Desc: PChar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fRegistraItemRest( iHdl,StrPas(Mesa),StrPas(Codigo),
                                          StrPas(Descricao),StrPas(Aliquota),StrPas(Qtde),
                                          StrPas(VlrUnit),StrPas(Acres),
                                          StrPas(Desc));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscCancelaItemRest( iHdl:Integer;Mesa,Codigo, Descricao, Aliquota,
                                 Qtde, VlrUnit, Acres, Desc: PChar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fCancelaItemRest( iHdl,
                                         StrPas(Mesa),
                                         StrPas(Codigo),
                                         StrPas(Descricao),
                                         StrPas(Aliquota),
                                         StrPas(Qtde),
                                         StrPas(Vlrunit),
                                         StrPas(Acres),
                                         StrPas(Desc) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscConferenciaMesa( iHdl:Integer;Mesa, Acres, Desc: PChar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fConferenciaMesa( iHdl,
                                         StrPas(Mesa),
                                         StrPas(Acres),
                                         StrPas(Desc));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscImprimeCardapio( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fImprimeCardapio( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscLeCardapio( iHdl:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fLeCardapio( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscLeMesasAbertas( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fLeMesasAbertas( iHdl );

  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscRelatMesasAbertas(iHdl:Integer;Tipo: PChar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fRelatMesasAbertas( iHdl,
                                         StrPas(Tipo));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscLeRegistrosVendaRest(iHdl:Integer;Mesa: PChar;
                                      var aBuff:AnsiString):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fLeRegistrosVendaRest( iHdl,
                                                StrPas(Mesa));
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function ImpFiscFechaCupomMesa( iHdl:Integer;Pagamento, Acres, Desc, Mensagem:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fFechaCupomMesa( iHdl,
                                            StrPas(Pagamento),
                                            StrPas(Acres),
                                            StrPas(Desc),
                                            StrPas(Mensagem));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscFechaCupContaDividida( iHdl:Integer;NumeroCupons, Acres, Desc,
                                Pagamento, ValorCliente, Cliente: PChar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fFechaCupContaDividida( iHdl,
                                                StrPas(NumeroCupons),
                                                StrPas(Acres),
                                                StrPas(Desc),
                                                StrPas(Pagamento),
                                                StrPas(ValorCliente),
                                                StrPas(Cliente));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscTransfMesas( iHdl:Integer;Origem, Destino: PChar):Integer; StdCall;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fTransfMesas( iHdl,
                                         StrPas(Origem),
                                         StrPas(Destino));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscTransfItem( iHdl:Integer;MesaOrigem, Codigo, Descricao, Aliquota,
                   Qtde, VlrUnit, Acres, Desc, MesaDestino: PChar):Integer; StdCall;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fTransfItem( iHdl,
                                        StrPas(MesaOrigem),
                                        StrPas(Codigo),
                                        StrPas(Descricao),
                                        StrPas(Aliquota),
                                        StrPas(Qtde),
                                        StrPas(VlrUnit),
                                        StrPas(Acres),
                                        StrPas(Desc),
                                        StrPas(MesaDestino));
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscLeTotNFisc( iHdl:Integer; var aBuff:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fLeTotNFisc( iHdl );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ' ;
    result := StrToInt( s );
  end
  else
  begin
    aBuff := copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//----------------------------------------------------------------------------
function  ImpFiscIdCliente( iHdl:Integer; CPFCNPJ , Cliente , Endereco : pChar ): Integer;
var
  s: AnsiString;
  iPos: Integer;
begin
  s := _z_ListaImpressoras.fIdCliente( iHdl , StrPas(CPFCNPJ) , StrPas(Cliente) , StrPas(Endereco) );
  iPos := Pos('|',s);
  If iPos = 0
  then Result := StrToInt( s )
  else Result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscDownMF( iHdl:Integer ; sTipo, sInicio, sFinal : Pchar):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fDownMF( iHdl , StrPas(sTipo), StrPas(sInicio), StrPas(sFinal));

  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt(copy(s,1,iPos-1)) ;
end;

//----------------------------------------------------------------------------
function ImpFiscRedZDado( iHdl:Integer; var MapaRes:AnsiString ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fRedZDado( iHdl, MapaRes );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
  begin
    MapaRes := Copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;

end;

//----------------------------------------------------------------------------
function  ImpFiscEstornNFiscVinc( iHdl:Integer; CPFCNPJ , Cliente , Endereco ,
                                   Mensagem , COOCDC : pChar ): Integer;
var
  s: AnsiString;
  iPos: Integer;
begin
  s := _z_ListaImpressoras.fEstornNFiscVinc( iHdl , StrPas(CPFCNPJ) ,
        StrPas(Cliente) , StrPas(Endereco) , StrPas(Mensagem) , StrPas(COOCDC) );
  iPos := Pos('|',s);
  If iPos = 0
  then Result := StrToInt( s )
  else Result := StrToInt(Copy(s,1,iPos-1));
end;

//----------------------------------------------------------------------------
function ImpFiscImpTxtFis( iHdl: Integer; Texto: PChar) : Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.fImpTxtFis( iHdl, StrPas(Texto) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt( copy(s,1,iPos-1) );
end;

//------------------------------------------------------------------------------
function ImpFiscGrvQrCode( iHdl: Integer; SavePath,QrCode: PChar): Integer;
var
   s: AnsiString;
   iPos: Integer;
begin
  s := _z_ListaImpressoras.fGrvQrCode( iHdl, StrPas(SavePath),StrPas(QrCode));
  iPos := Pos('|',s);

  if iPos = 0
  then Result := StrToInt(s)
  else Result := StrToInt(Copy(s,1,iPos-1));
end;

//------------------------------------------------------------------------------
function  ImpFiscAbreCNF(iHdl: Integer;  CPFCNPJ, Nome, Endereco : PChar): Integer;
var
  s: AnsiString;
  iPos: Integer;
begin
  s := _z_ListaImpressoras.fAbreCNF(iHdl,StrPas(CPFCNPJ), StrPas(Nome), StrPas(Endereco));
  iPos := Pos('|',s);

  if iPos = 0
  then Result := StrToInt(s)
  else Result := StrToInt(Copy(s,1,iPos-1));
end;

//------------------------------------------------------------------------------
function  ImpFiscRecCNF(iHdl: Integer; IndiceTot , Valor, ValorAcresc,
                        ValorDesc : PChar): Integer;
var
  s: AnsiString;
  iPos: Integer;
begin
  s := _z_ListaImpressoras.fRecCNF( iHdl , StrPas(IndiceTot) , StrPas(Valor) ,
                                    StrPas(ValorAcresc), StrPas(ValorDesc));
  iPos := Pos('|',s);

  if iPos = 0
  then Result := StrToInt(s)
  else Result := StrToInt(Copy(s,1,iPos-1));
end;

//------------------------------------------------------------------------------
function  ImpFiscPgtoCNF(iHdl: Integer; FrmPagto , Valor, InfoAdicional ,
                                       ValorAcresc,ValorDesc: PChar): Integer;
var
  s: AnsiString;
  iPos: Integer;
begin
  s := _z_ListaImpressoras.fPgtoCNF( iHdl, StrPas(FrmPagto) , StrPas(Valor),
                                    StrPas(InfoAdicional), StrPas(ValorAcresc),
                                    StrPas(ValorDesc));
  iPos := Pos('|',s);

  if iPos = 0
  then Result := StrToInt(s)
  else Result := StrToInt(Copy(s,1,iPos-1));
end;

//------------------------------------------------------------------------------
function  ImpFiscFechaCNF(iHdl: Integer; Mensagem : PChar): Integer;
var
  s: AnsiString;
  iPos: Integer;
begin
  s := _z_ListaImpressoras.fFechaCNF( iHdl , StrPas(Mensagem));
  iPos := Pos('|',s);

  if iPos = 0
  then Result := StrToInt(s)
  else Result := StrToInt(Copy(s,1,iPos-1));
end;


//----------------------------------------------------------------------------
initialization
  _z_ListaImpressoras := TListaImpressoras.Create;
  _z_ListaDrivers := TListaDrivers.Create;


finalization
  _z_ListaImpressoras.Free;
  _z_ListaDrivers.Free;


//----------------------------------------------------------------------------

end.
