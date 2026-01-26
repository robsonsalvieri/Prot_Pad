unit ImpSwedaMFD;

interface

uses
  Dialogs,
  ImpFiscMain,
  ImpCheqMain,
  CMC7Main,
  Windows,
  SysUtils,
  classes,
  IniFiles,
  Forms,
  LojxFun;

// Sweda ST100
Type
TImpSwedaST100 = class( TImpressoraFiscal )
public
  Function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
  Function LeituraX:String; override;
  Function Fechar( sPorta:String ):String; override;
  Function AbreEcf:String; override;
  Function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
  Function CancelaCupom(Supervisor:String):String; override;
  Function ReducaoZ(MapaRes:String):String; override;
  Function RedZDado(MapaRes:String):String; override;  
  Function PegaCupom(Cancelamento:String):String; override;
  Function PegaPDV:String; override;
  Function LeAliquotas:String; override;
  Function LeAliquotasISS:String; override;
  Function RegistraItem( codigo, descricao, qtde, vlrUnit, vlrdesconto, aliquota, vlTotIt, UnidMed:String; nTipoImp:Integer ): String; override;
  Function LeCondPag:String; override;
  Function CancelaItem( numitem, codigo, descricao, qtde, vlrunit, vlrdesconto, aliquota:String ):String; override;
  Function FechaCupom( Mensagem:String ):String; override;
  Function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
  Function DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String; override;
  Function AcrescimoTotal( vlrAcrescimo:String ): String; override;
  Function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String; override;
  Function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
  Function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String; override;
  Function TextoNaoFiscal( Texto:String; Vias:Integer ):String; override;
  function FechaCupomNaoFiscal: String; override;
  Function ReImpCupomNaoFiscal( Texto:String ):String; override;
  Function Suprimento( Tipo:Integer; Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
  Function StatusImp( Tipo:Integer ):String; override;
  function Gaveta:String; override;
  function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
  function ImprimeCodBarrasITF( Cabecalho, Codigo, Rodape:String ;Vias:Integer):String; override;
  function PegaSerie:String; override;
  function GravaCondPag( Condicao:String ):String; override;
  function ImpostosCupom(Texto: String): String; override;
  function TotalizadorNaoFiscal( Numero,Descricao:String ):String; override;
  function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
  function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
  function HorarioVerao( Tipo:String ):String; override;
  function DownloadMFD( sTipo, sInicio, sFinal : String ):String; Override;
  Procedure AlimentaProperties; override;
  function Retorna_Informacoes( iRetorno : Integer ): String;
  function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String; Override;
  function GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: integer; cChavePublica: string; cChavePrivada: string; iUnicoArquivo: integer ): String; Override;
  function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer; ImgQrCode: String) : String; Override;
  function LeTotNFisc:String; override;
  function DownMF(sTipo, sInicio, sFinal : String):String; override;
  function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
  function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
  function ImpTxtFis(Texto : String) : String; Override;
  function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
  function GrvQrCode(SavePath,QrCode: String): String; Override;
end;

//modelos do CV0909
TImpSwedaSTCV0909 = class(TImpSwedaST100)
public
  function PegaCupom(Cancelamento:String):String; override;
end;

// ST1000 e ST2000
TImpSwedaST1000 = class( TImpSwedaST100 )
public
  function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
End;

// ST1000 - Impressora de Cheques
TImpCheqST1000 = class(TImpressoraCheque)
public
  function Abrir( aPorta:String ): Boolean; override;
  function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
  function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
  function Fechar(aPorta:String ): Boolean; override;
  function StatusCh( Tipo:Integer ):String; override;
end;

TCmc7_ST1000 = class( TCMC7 )
public
  function Abrir( aPorta, sMensagem: String  ):String; Override;
  function LeDocumento:String; Override;
  function Fechar:String; Override;
end;

// Funções e procedures não-dll
Function OpenSweda( sPorta:String ) : String;
Function CloseSweda : String;
Function TrataRetornoSweda( var iRet:Integer ):String;
Function MsgErroSweda( iRet:Integer ):String;
Function Status_Impressora( lMensagem:Boolean ): Integer;
Function ArqIniSweda( sPorta:String; bMfd:boolean ):Boolean;
Function TrataTags( Mensagem : String ) : String;
Function VldFormaPgto (var Condicao : String) : Boolean;

implementation
Const
  sArqIniSweda = 'SWC.INI';
  sArqDownMFD  = 'DOWNLOAD.MFD';
  sTagNegritoIni = Chr(16)+'B';
  sTagItalicoIni = Chr(16)+'I';
  sTagCondensadoIni = Chr(16)+'C';
  sTagExpandidoHIni = Chr(16)+'E'; //expandido horizontal
  sTagExpandidoVIni = Chr(16)+'V'; //expandido vertical
  sTagFim = Chr(16)+'N';
Var
  bOpened       : Boolean;
  fHandle       : THandle;
  fHandle2      : THandle;
  Path          : String;
  aIndAliq      : array of string;
  lDescAcres    : Boolean = False;
  sMarca        : String;               // Marca da ECF
  lError        : Boolean = False;      // Controle de Erro para Alimentar Propriedades

  sPathEcfRegistry : String = 'C:\';            // Path da ECF no Registry
  sArqEcfDefault : String = 'RETORNO.TXT';      // Arquivo Retorno
  fFuncECF_AbrePortaSerial                      : Function( ):Integer; StdCall;
  fFuncECF_FechaPortaSerial                     : Function( ):Integer; StdCall;
  fFuncECF_LeituraX                             : Function( ):Integer; StdCall;
  fFuncECF_AbreCupomMFD                         : Function( CGC, Nome, Endereco : string): Integer; StdCall;
  fFuncECF_CancelaCupomMFD                      : Function( CGC, Nome, Endereco: string)  : Integer; StdCall;
  fFuncECF_RetornoImpressora                    : Function( Var ACK: Integer; Var ST1: Integer; Var ST2: Integer ): Integer; StdCall;
  fFuncECF_VerificaIndiceAliquotasIss           : Function( Flag: String ): Integer; StdCall;
  fFuncECF_VerificaAliquotasIss                 : Function( Flag: String ): Integer; StdCall;
  fFuncECF_RetornoAliquotas                     : Function( Aliquotas: String ): Integer; StdCall;
  fFuncECF_NumeroCaixa                          : Function( NumeroCaixa: String ): Integer; StdCall;
  fFuncECF_VersaoFirmware                       : Function( VersaoFirmware: String ): Integer; StdCall;
  fFuncECF_ReducaoZ                             : Function( Data: String; Hora: String ): Integer; StdCall;
  fFuncECF_NumeroCupom                          : Function( NumeroCupom: String ): Integer; StdCall;
  fFuncECF_VendeItem                            : Function( Codigo: String; Descricao: String; Aliquota: String;
                                                            TipoQuantidade: String; Quantidade: String; CasasDecimais: Integer;
                                                            ValorUnitario: String; TipoDesconto: String; Desconto: String): Integer; StdCall;
  fFuncECF_AumentaDescricaoItem                 : Function( Descricao: String ): Integer; StdCall;
  fFuncECF_VerificaFormasPagamento              : Function( Formas: String ): Integer; StdCall;
  fFuncECF_CancelaItemGenerico                  : Function( NumeroItem: String ): Integer; StdCall;
  fFuncECF_TerminaFechamentoCupom               : Function( Mensagem: String): Integer; StdCall;
  fFuncECF_IniciaFechamentoCupom                : Function( AcrescimoDesconto: String; TipoAcrescimoDesconto: String;
                                                            ValorAcreDesc: String ): Integer; StdCall;
  fFuncECF_EfetuaFormaPagamento                 : Function( FormaPagamento: String; ValorFormaPagamento: String ): Integer; StdCall;
  fFuncECF_LeituraMemoriaFiscalData             : Function( DataInicial: String; DataFinal: String ): Integer; StdCall;
  fFuncECF_LeituraMemoriaFiscalReducao          : Function( ReducaoInicial: String; ReducaoFinal: String ): Integer; StdCall;
  fFuncECF_LeituraMemoriaFiscalSerialData       : Function( DataInicial: String; DataFinal: String ): Integer; StdCall;
  fFuncECF_LeituraMemoriaFiscalSerialReducao    : Function( ReducaoInicial: String; ReducaoFinal: String ): Integer; StdCall;
  fFuncECF_ProgramaAliquota                     : Function( Aliquota: String; ICMS_ISS: Integer ): Integer; StdCall;
  fFuncECF_AbreComprovanteNaoFiscalVinculado    : Function( FormaPagamento: String; Valor: String; NumeroCupom: String ): Integer; StdCall;
  fFuncECF_RecebimentoNaoFiscal                 : Function( IndiceTotalizador: String; Valor: String; FormaPagamento: String ): Integer; StdCall;
  fFuncECF_UsaComprovanteNaoFiscalVinculado     : Function( Texto: String ): Integer; StdCall;
  fFuncECF_Suprimento                           : Function( Valor: String; FormaPagamento: String ): Integer; StdCall;
  fFuncECF_Sangria                              : Function( Valor: String ): Integer; StdCall;
  fFuncECF_DataHoraImpressora                   : Function( Data: String; Hora: String ): Integer; StdCall;
  fFuncECF_VerificaEstadoImpressora             : Function( Var ACK: Integer; Var ST1: Integer; Var ST2: Integer ): Integer; StdCall;
  fFuncECF_DataMovimento                        : Function( Data: String ): Integer; StdCall;
  fFuncECF_VerificaTruncamento                  : Function( Flag: string ): Integer; StdCall;
  fFuncECF_VendaBruta                           : Function( vbruta: String): Integer; StdCall;
  fFuncECF_GrandeTotal                          : Function( GrandeTotal: String ): Integer; StdCall;
  fFuncECF_AcionaGaveta                         : Function( ):Integer; StdCall;
  fFuncECF_NomeiaTotalizadorNaoSujeitoIcms      : Function( Indice: Integer; Totalizador: String): Integer; StdCall;
  fFuncECF_VerificaRecebimentoNaoFiscal         : Function( Recebimentos: String ): Integer; StdCall;
  fFuncECF_FechaComprovanteNaoFiscalVinculado   : Function( ):Integer; StdCall;
  fFuncECF_ProgramaHorarioVerao                 : Function( ): Integer; StdCall;
  fFuncECF_VerificaRelatorioGerencialProgMFD    : Function( Relatorio : String): Integer; StdCall;
  fFuncECF_AbreRelatorioGerencialMFD            : Function( Indice : String): Integer; StdCall;
  fFuncECF_UsaRelatorioGerencialMFD             : Function( Texto: String ): Integer; StdCall;
  fFuncECF_RelatorioGerencial                   : Function( Texto: String ): Integer; StdCall;
  fFuncECF_FechaRelatorioGerencial              : Function( ) : Integer; StdCall;
  fFuncECF_NumeroSerieMFD                       : Function( NumeroSerie: String ): Integer; StdCall;
  fFuncECF_NumeroReducoes                       : Function( NumeroReducoes: String ): Integer; StdCall;
  fFuncECF_Cancelamentos                        : Function( ValorCancelamentos: String ): Integer; StdCall;
  fFuncECF_CancelamentosICMSISS                 : Function( ValorCancelamentosICMS: String; ValorCancelamentosISS: String ): Integer; StdCall;
  fFuncECF_Descontos                            : Function( ValorDescontos: String ): Integer; StdCall;
  fFuncECF_DescontosICMSISS                     : Function( DescICMS , DescISS : String ) : Integer; StdCall;
  fFuncECF_VerificaTotalizadoresParciais        : Function( Totalizadores: String ): Integer; StdCall;
  fFuncECF_RetornaRegistradoresNaoFiscais       : Function( rnf: String ): Integer; StdCall;
  fFuncECF_RetornaRegistradoresFiscais          : Function( rf: String ): Integer; StdCall;
  fFuncECF_LerAliquotasComIndice                : Function( Taxas: String): Integer; StdCall;
  fFuncECF_ProgramaMoedaPlural                  : Function( MoedaPlural : String ) : Integer; StdCall;
  fFuncECF_VerificaStatusCheque                 : Function( Var StatusCheque: Integer ): Integer; StdCall;
  fFuncECF_ImprimeChequeMFD                     : Function( Banco: String; Valor: String; Favorecido: String; Cidade: String; Data: String;
                                                            Mensagem: String; Verso, Linhas : String): Integer; StdCall;
  fFuncECF_LeituraChequeMFD                     : function( Codigo: String ): Integer; StdCall;
  fFuncECF_ProgramaFormaPagamentoMFD            : function( FormPag : String; Vinc : String ) : Integer; StdCall;
  fFuncECF_Autenticacao                         : Function( ):Integer; StdCall;

  fFuncECF_CGC_IE                               : Function( CGC: String; IE: String ): Integer; StdCall;
  fFuncECF_NumeroLoja                           : Function( NumeroLoja: String): Integer; StdCall;
  fFuncECF_VerificaModeloEcf                    : Function( ): Integer; StdCall;
  fFuncECF_VersaoFirmwareMFD                    : Function( VersaoFirmware: String ): Integer; StdCall;
  fFuncECF_RetornaCRO                           : Function( CRO: String ): Integer; StdCall;
  fFuncECF_RetornaCRZ                           : Function( CRZ: String ): Integer; StdCall;
  fFuncECF_RetornaPathMFD                       : Function( Caminho: String ): Integer; StdCall;
  fFuncECF_DataHoraGravacaoUsuarioSWBasicoMFAdicional : function (sDtHrGrvUser, sDtHrGrvSb, sMemFisAdi : String):Integer; StdCall;
  fFuncECF_ContadorCupomFiscalMFD               : function ( CCF: String):Integer; StdCall;
  fFuncECF_NumeroOperacoesNaoFiscais            : function ( NumeroOperacoes: String):Integer; StdCall;
  fFuncECF_ContadorRelatoriosGerenciaisMFD      : function ( ContadorRelatorio: String):Integer; StdCall;
  fFuncECF_ContadorComprovantesCreditoMFD       : function ( ContadorComprovantes: String):Integer; StdCall;
  fFuncECF_DataHoraUltimoDocumentoMFD           : function ( Data: String):Integer; StdCall;
  fFuncECF_LeituraMemoriaFiscalDataMFD          : function (DataInicial: String; DataFinal: String; cTipo:String): Integer; StdCall;
  fFuncECF_LeituraMemoriaFiscalReducaoMFD       : function (ReducaoInicial: String; ReducaoFinal: String; cTipo:String): Integer; StdCall;
  fFuncECF_LeituraMemoriaFiscalSerialDataMFD    : function (DataInicial: String; DataFinal: String; cTipo:String): Integer; StdCall;
  fFuncECF_LeituraMemoriaFiscalSerialReducaoMFD : function (ReducaoInicial: String; ReducaoFinal: String; cTipo:String): Integer; StdCall;
  fFuncECF_DownloadMFD                          : function (Arquivo: String; Tipo: String; DadoInic: String; DadoFim: String; Usuario: String): Integer; stdcall;
  fFuncECF_GeraRegistrosCAT52MFD                : function (Arquivo: String; Data: String): Integer; stdcall;
  fFuncECF_DownloadMF                           : function (Arquivo: String): Integer; stdcall;
  fFuncECF_FormatoDadosMFD                      : function (Origem: String; Destino: String; Formato: String; Tipo: String; Inicio: String; Fim: String; Usuario: String): Integer; StdCall;
  fFuncECF_ReproduzirMemoriaFiscalMFD           : function (Tipo: String; FxaIni: String; FxaFim: String; PatTxt:String; PatBin: String): Integer; StdCall;
  fFuncECF_UltimoItemVendido                    : Function( sUltimoItem: String): Integer; StdCall;
  fFuncECF_SubTotal                             : Function( sSubTotal: String): Integer; StdCall;
  fFuncECF_ArquivoEletronicoCOTEPE              : Function( sPathBin: String ; sPathBinTDM : String; sDestino : String ; sInicio : String; sFim : String; sOpcaoGeracao: Integer = 0) : Integer; StdCall;
  fECF_VerificaTotalizadoresNaoFiscaisMFD       : Function( Totalizadores: String ): Integer; StdCall;
  fFuncECF_ConfiguraCodigoBarrasMFD             : Function( Altura: Integer; Largura: Integer; Posicao: Integer; Fonte: Integer; Margem: Integer ): Integer; StdCall;
  fFuncECF_CodigoBarrasITFMFD                   : Function( Codigo: String): Integer; StdCall;
  fFuncECF_CodigoBarrasEAN13MFD                 : Function( Codigo: String): Integer; StdCall;
  fFuncECF_EstornoNaoFiscalVinculadoMFD         : Function( CPFCNPJ: String ; Nome : String ; Endereco : String) : Integer; StdCall;
  fFuncECF_IdentificaConsumidor                 : Function( Nome , Endereco, CGC_CPF : String ) : Integer; StdCall;
  fFuncECF_DataMovimentoUltimaReducaoMFD        : Function( DataMovimento : String ): Integer; StdCall;
  fFuncECF_DataHoraReducao                      : Function( DataReducao, HoraReducao : String): Integer; StdCall;

  //Funções para identificação automática do ECF - códigos 45 e 46 StatusImp
  fFuncECF_CodigoModeloFiscal                   : Function( Cniee, Compl: String ) : Integer; StdCall;
  //fFuncECF_VersaoFirmwareMFD                    : Function( VersaoFirmware: String ): Integer; StdCall;
  fFuncECF_MarcaModeloTipoImpressoraMFD         : Function( Marca, Modelo, Tipo: String ): Integer; StdCall;
  //Procedure e Functions

Function OpenSweda( sPorta : String ): String;

  Function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  Begin
    If Not Assigned(aPointer) Then
    Begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: CONVECF.DLL ou SWMFD.DLL '+#13+
                  '(Atualize a versão da DLL do Fabricante do ECF)');
      Result := False;
    End
    Else
      Result := True;
  End;

Var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;
  sIni : String;
  ListaArq : TStringList;
begin
  Result := '0|';
  If Not bOpened Then
  Begin
    fHandle := LoadLibrary( 'CONVECF.DLL' );
    fHandle2:= LoadLibrary( 'SWMFD.DLL' );

    If (fHandle <> 0) and (fHandle2 <> 0) Then
    Begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'ECF_FechaPortaSerial');
      If ValidPointer( aFunc, 'ECF_FechaPortaSerial' ) then
        fFuncECF_FechaPortaSerial := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_AbrePortaSerial');
      If ValidPointer( aFunc, 'ECF_AbrePortaSerial' )
      then fFuncECF_AbrePortaSerial := aFunc
      Else bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_AbreCupomMFD');
      If ValidPointer( aFunc, 'ECF_AbreCupomMFD' ) then
        fFuncECF_AbreCupomMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_CancelaCupomMFD');
      If ValidPointer( aFunc, 'ECF_CancelaCupomMFD' ) then
        fFuncECF_CancelaCupomMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraX');
      If ValidPointer( aFunc, 'ECF_LeituraX' ) then
        fFuncECF_LeituraX := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RetornoImpressora');
      If ValidPointer( aFunc, 'ECF_RetornoImpressora' ) then
        fFuncECF_RetornoImpressora := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaIndiceAliquotasIss');
      If ValidPointer( aFunc, 'ECF_VerificaIndiceAliquotasIss' ) then
        fFuncECF_VerificaIndiceAliquotasIss := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaAliquotasIss');
      If ValidPointer( aFunc, 'ECF_VerificaAliquotasIss' ) then
        fFuncECF_VerificaAliquotasIss := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RetornoAliquotas');
      If ValidPointer( aFunc, 'ECF_RetornoAliquotas' ) then
        fFuncECF_RetornoAliquotas := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_NumeroCaixa');
      If ValidPointer( aFunc, 'ECF_NumeroCaixa' ) then
        fFuncECF_NumeroCaixa := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VersaoFirmware');
      If ValidPointer( aFunc, 'ECF_VersaoFirmware' ) then
        fFuncECF_VersaoFirmware := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ReducaoZ');
      If ValidPointer( aFunc, 'ECF_ReducaoZ' ) then
        fFuncECF_ReducaoZ := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_NumeroCupom');
      If ValidPointer( aFunc, 'ECF_NumeroCupom' ) then
        fFuncECF_NumeroCupom := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VendeItem');
      If ValidPointer( aFunc, 'ECF_VendeItem' ) then
        fFuncECF_VendeItem := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_AumentaDescricaoItem');
      If ValidPointer( aFunc, 'ECF_AumentaDescricaoItem' ) then
        fFuncECF_AumentaDescricaoItem := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaFormasPagamento');
      If ValidPointer( aFunc, 'ECF_VerificaFormasPagamento' ) then
        fFuncECF_VerificaFormasPagamento := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_CancelaItemGenerico');
      If ValidPointer( aFunc, 'ECF_CancelaItemGenerico' ) then
        fFuncECF_CancelaItemGenerico := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_TerminaFechamentoCupom');
      If ValidPointer( aFunc, 'ECF_TerminaFechamentoCupom' ) then
        fFuncECF_TerminaFechamentoCupom := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_TerminaFechamentoCupom');
      If ValidPointer( aFunc, 'ECF_TerminaFechamentoCupom' ) then
        fFuncECF_TerminaFechamentoCupom := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_EfetuaFormaPagamento');
      If ValidPointer( aFunc, 'ECF_EfetuaFormaPagamento' ) then
        fFuncECF_EfetuaFormaPagamento := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraMemoriaFiscalData');
      If ValidPointer( aFunc, 'ECF_LeituraMemoriaFiscalData' ) then
        fFuncECF_LeituraMemoriaFiscalData := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraMemoriaFiscalReducao');
      If ValidPointer( aFunc, 'ECF_LeituraMemoriaFiscalReducao' ) then
        fFuncECF_LeituraMemoriaFiscalReducao := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraMemoriaFiscalSerialData');
      If ValidPointer( aFunc, 'ECF_LeituraMemoriaFiscalSerialData' ) then
        fFuncECF_LeituraMemoriaFiscalSerialData := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraMemoriaFiscalSerialReducao');
      If ValidPointer( aFunc, 'ECF_LeituraMemoriaFiscalSerialReducao' ) then
        fFuncECF_LeituraMemoriaFiscalSerialReducao := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_AbreComprovanteNaoFiscalVinculado');
      If ValidPointer( aFunc, 'ECF_AbreComprovanteNaoFiscalVinculado' ) then
        fFuncECF_AbreComprovanteNaoFiscalVinculado := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RecebimentoNaoFiscal');
      If ValidPointer( aFunc, 'ECF_RecebimentoNaoFiscal' ) then
        fFuncECF_RecebimentoNaoFiscal := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_UsaComprovanteNaoFiscalVinculado');
      If ValidPointer( aFunc, 'ECF_UsaComprovanteNaoFiscalVinculado' ) then
        fFuncECF_UsaComprovanteNaoFiscalVinculado := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_Suprimento');
      If ValidPointer( aFunc, 'ECF_Suprimento' ) then
        fFuncECF_Suprimento := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_Sangria');
      If ValidPointer( aFunc, 'ECF_Sangria' ) then
        fFuncECF_Sangria := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DataHoraImpressora');
      If ValidPointer( aFunc, 'ECF_DataHoraImpressora' ) then
        fFuncECF_DataHoraImpressora := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaEstadoImpressora');
      If ValidPointer( aFunc, 'ECF_VerificaEstadoImpressora' ) then
        fFuncECF_VerificaEstadoImpressora := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DataMovimento');
      If ValidPointer( aFunc, 'ECF_DataMovimento' ) then
        fFuncECF_DataMovimento := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaTruncamento');
      If ValidPointer( aFunc, 'ECF_VerificaTruncamento' ) then
        fFuncECF_VerificaTruncamento := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_GrandeTotal');
      If ValidPointer( aFunc, 'ECF_GrandeTotal' ) then
        fFuncECF_GrandeTotal := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_AcionaGaveta');
      If ValidPointer( aFunc, 'ECF_AcionaGaveta' ) then
        fFuncECF_AcionaGaveta := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_NomeiaTotalizadorNaoSujeitoIcms');
      If ValidPointer( aFunc, 'ECF_NomeiaTotalizadorNaoSujeitoIcms' ) then
        fFuncECF_NomeiaTotalizadorNaoSujeitoIcms := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaRecebimentoNaoFiscal');
      If ValidPointer( aFunc, 'ECF_VerificaRecebimentoNaoFiscal' ) then
        fFuncECF_VerificaRecebimentoNaoFiscal := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_FechaComprovanteNaoFiscalVinculado');
      If ValidPointer( aFunc, 'ECF_FechaComprovanteNaoFiscalVinculado' ) then
        fFuncECF_FechaComprovanteNaoFiscalVinculado := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ProgramaHorarioVerao');
      If ValidPointer( aFunc, 'ECF_ProgramaHorarioVerao' ) then
        fFuncECF_ProgramaHorarioVerao := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_FechaRelatorioGerencial');
      If ValidPointer( aFunc, 'ECF_FechaRelatorioGerencial' ) then
        fFuncECF_FechaRelatorioGerencial := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RelatorioGerencial');
      If ValidPointer( aFunc, 'ECF_RelatorioGerencial' ) then
        fFuncECF_RelatorioGerencial := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_NumeroSerieMFD');
      If ValidPointer( aFunc, 'ECF_NumeroSerieMFD' ) then
        fFuncECF_NumeroSerieMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_NumeroReducoes');
      If ValidPointer( aFunc, 'ECF_NumeroReducoes' ) then
        fFuncECF_NumeroReducoes := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_Cancelamentos');
      If ValidPointer( aFunc, 'ECF_Cancelamentos' ) then
        fFuncECF_Cancelamentos := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_CancelamentosICMSISS');
      If ValidPointer( aFunc, 'ECF_CancelamentosICMSISS' ) then
        fFuncECF_CancelamentosICMSISS := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_Descontos');
      If ValidPointer( aFunc, 'ECF_Descontos' ) then
        fFuncECF_Descontos := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DescontosICMSISS');
      If ValidPointer( aFunc , 'ECF_DescontosICMSISS' ) then
        fFuncECF_DescontosICMSISS := aFunc
      Else
        bRet := False;  

      aFunc := GetProcAddress(fHandle,'ECF_VerificaTotalizadoresParciais');
      If ValidPointer( aFunc, 'ECF_VerificaTotalizadoresParciais' ) then
        fFuncECF_VerificaTotalizadoresParciais := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RetornaRegistradoresNaoFiscais');
      If ValidPointer( aFunc, 'ECF_RetornaRegistradoresNaoFiscais' ) then
        fFuncECF_RetornaRegistradoresNaoFiscais := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RetornaRegistradoresFiscais');
      If ValidPointer( aFunc, 'ECF_RetornaRegistradoresFiscais' ) then
        fFuncECF_RetornaRegistradoresFiscais := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VendaBruta');
      If ValidPointer( aFunc, 'ECF_VendaBruta' ) then
        fFuncECF_VendaBruta := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LerAliquotasComIndice');
      If ValidPointer( aFunc, 'ECF_LerAliquotasComIndice' ) then
        fFuncECF_LerAliquotasComIndice := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_IniciaFechamentoCupom');
      If ValidPointer( aFunc, 'ECF_IniciaFechamentoCupom' ) then
        fFuncECF_IniciaFechamentoCupom := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ProgramaMoedaPlural');
      If ValidPointer( aFunc, 'ECF_ProgramaMoedaPlural' ) then
        fFuncECF_ProgramaMoedaPlural := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaStatusCheque');
      If ValidPointer( aFunc, 'ECF_VerificaStatusCheque' ) then
        fFuncECF_VerificaStatusCheque := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ImprimeChequeMFD');
      If ValidPointer( aFunc, 'ECF_ImprimeChequeMFD' ) then
        fFuncECF_ImprimeChequeMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraChequeMFD');
      If ValidPointer( aFunc, 'ECF_LeituraChequeMFD' ) then
        fFuncECF_LeituraChequeMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ProgramaAliquota');
      If ValidPointer( aFunc, 'ECF_ProgramaAliquota' ) then
        fFuncECF_ProgramaAliquota := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ProgramaFormaPagamentoMFD');
      If ValidPointer( aFunc, 'ECF_ProgramaFormaPagamentoMFD' ) then
        fFuncECF_ProgramaFormaPagamentoMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_Autenticacao');
      If ValidPointer( aFunc, 'ECF_Autenticacao' ) then
        fFuncECF_Autenticacao := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_CGC_IE');
      If ValidPointer( aFunc, 'ECF_CGC_IE' ) then
        fFuncECF_CGC_IE := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_NumeroLoja');
      If ValidPointer( aFunc, 'ECF_NumeroLoja' ) then
        fFuncECF_NumeroLoja := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaModeloEcf');
      If ValidPointer( aFunc, 'ECF_VerificaModeloEcf' ) then
        fFuncECF_VerificaModeloEcf := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VersaoFirmwareMFD');
      If ValidPointer( aFunc, 'ECF_VersaoFirmwareMFD' ) then
        fFuncECF_VersaoFirmwareMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RetornaCRO');
      If ValidPointer( aFunc, 'ECF_RetornaCRO' ) then
        fFuncECF_RetornaCRO := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RetornaCRZ');
      If ValidPointer( aFunc, 'ECF_RetornaCRZ' ) then
        fFuncECF_RetornaCRZ := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_RetornaPathMFD');
      If ValidPointer( aFunc, 'ECF_RetornaPathMFD' ) then
        fFuncECF_RetornaPathMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DataHoraGravacaoUsuarioSWBasicoMFAdicional');
      If ValidPointer( aFunc, 'ECF_DataHoraGravacaoUsuarioSWBasicoMFAdicional' ) then
        fFuncECF_DataHoraGravacaoUsuarioSWBasicoMFAdicional := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ContadorCupomFiscalMFD');
      If ValidPointer( aFunc, 'ECF_ContadorCupomFiscalMFD' ) then
        fFuncECF_ContadorCupomFiscalMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_NumeroOperacoesNaoFiscais');
      If ValidPointer( aFunc, 'ECF_NumeroOperacoesNaoFiscais' ) then
        fFuncECF_NumeroOperacoesNaoFiscais := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ContadorRelatoriosGerenciaisMFD');
      If ValidPointer( aFunc, 'ECF_ContadorRelatoriosGerenciaisMFD' ) then
        fFuncECF_ContadorRelatoriosGerenciaisMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ContadorComprovantesCreditoMFD');
      If ValidPointer( aFunc, 'ECF_ContadorComprovantesCreditoMFD' ) then
        fFuncECF_ContadorComprovantesCreditoMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DataHoraUltimoDocumentoMFD');
      If ValidPointer( aFunc, 'ECF_DataHoraUltimoDocumentoMFD' ) then
        fFuncECF_DataHoraUltimoDocumentoMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraMemoriaFiscalDataMFD');
      If ValidPointer( aFunc, 'ECF_LeituraMemoriaFiscalDataMFD' ) then
        fFuncECF_LeituraMemoriaFiscalDataMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraMemoriaFiscalReducaoMFD');
      If ValidPointer( aFunc, 'ECF_LeituraMemoriaFiscalReducaoMFD' ) then
        fFuncECF_LeituraMemoriaFiscalReducaoMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraMemoriaFiscalSerialDataMFD');
      If ValidPointer( aFunc, 'ECF_LeituraMemoriaFiscalSerialDataMFD' ) then
        fFuncECF_LeituraMemoriaFiscalSerialDataMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_LeituraMemoriaFiscalSerialReducaoMFD');
      If ValidPointer( aFunc, 'ECF_LeituraMemoriaFiscalSerialReducaoMFD' ) then
        fFuncECF_LeituraMemoriaFiscalSerialReducaoMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DownloadMFD');
      If ValidPointer( aFunc, 'ECF_DownloadMFD' ) then
        fFuncECF_DownloadMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_GeraRegistrosCAT52MFD');
      If ValidPointer( aFunc, 'ECF_GeraRegistrosCAT52MFD' ) then
        fFuncECF_GeraRegistrosCAT52MFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DownloadMF');
      If ValidPointer( aFunc, 'ECF_DownloadMF' ) then
        fFuncECF_DownloadMF := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_FormatoDadosMFD');
      If ValidPointer( aFunc, 'ECF_FormatoDadosMFD' ) then
        fFuncECF_FormatoDadosMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_ReproduzirMemoriaFiscalMFD');
      If ValidPointer( aFunc, 'ECF_ReproduzirMemoriaFiscalMFD' ) then
        fFuncECF_ReproduzirMemoriaFiscalMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_UltimoItemVendido');
      If ValidPointer( aFunc, 'ECF_UltimoItemVendido' ) then
        fFuncECF_UltimoItemVendido := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_SubTotal');
      If ValidPointer( aFunc, 'ECF_SubTotal' ) then
        fFuncECF_SubTotal := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle2, 'SWEDA_ArquivoEletronicoCOTEPE');
      If ValidPointer( aFunc , 'SWEDA_ArquivoEletronicoCOTEPE' ) then
        fFuncECF_ArquivoEletronicoCOTEPE := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle, 'ECF_AbreRelatorioGerencialMFD');
      if ValidPointer( aFunc , 'ECF_AbreRelatorioGerencialMFD' ) then
        fFuncECF_AbreRelatorioGerencialMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle, 'ECF_UsaRelatorioGerencialMFD');
      if ValidPointer( aFunc , 'ECF_UsaRelatorioGerencialMFD' ) then
        fFuncECF_UsaRelatorioGerencialMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle, 'ECF_VerificaRelatorioGerencialProgMFD');
      if ValidPointer( aFunc , 'ECF_VerificaRelatorioGerencialProgMFD' ) then
        fFuncECF_VerificaRelatorioGerencialProgMFD := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_VerificaTotalizadoresNaoFiscaisMFD');
      If ValidPointer( aFunc, 'ECF_VerificaTotalizadoresNaoFiscaisMFD' ) then
        fECF_VerificaTotalizadoresNaoFiscaisMFD := aFunc
      Else
        bRet := False;

       aFunc := GetProcAddress(fHandle,'ECF_CodigoModeloFiscal');
      If ValidPointer( aFunc, 'ECF_CodigoModeloFiscal' ) then
        fFuncECF_CodigoModeloFiscal:= aFunc
      Else
        bRet := False;


      aFunc := GetProcAddress(fHandle,'ECF_MarcaModeloTipoImpressoraMFD');
      If ValidPointer( aFunc, 'ECF_MarcaModeloTipoImpressoraMFD' ) then
        fFuncECF_MarcaModeloTipoImpressoraMFD:= aFunc
      Else
        bRet := False;


      aFunc := GetProcAddress(fHandle,'ECF_ConfiguraCodigoBarrasMFD');
      If ValidPointer( aFunc, 'ECF_ConfiguraCodigoBarrasMFD' ) then
        fFuncECF_ConfiguraCodigoBarrasMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_CodigoBarrasITFMFD');
      If ValidPointer( aFunc, 'ECF_CodigoBarrasITFMFD' ) then
        fFuncECF_CodigoBarrasITFMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_CodigoBarrasEAN13MFD');
      If ValidPointer( aFunc, 'ECF_CodigoBarrasEAN13MFD' ) then
        fFuncECF_CodigoBarrasEAN13MFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_EstornoNaoFiscalVinculadoMFD');
      If ValidPointer( aFunc, 'ECF_EstornoNaoFiscalVinculadoMFD' ) then
        fFuncECF_EstornoNaoFiscalVinculadoMFD := aFunc
      Else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_IdentificaConsumidor');
      If ValidPointer( aFunc, 'ECF_IdentificaConsumidor' )
      then fFuncECF_IdentificaConsumidor := aFunc
      Else bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DataMovimentoUltimaReducaoMFD');
      If ValidPointer( aFunc, 'ECF_DataMovimentoUltimaReducaoMFD')
      then fFuncECF_DataMovimentoUltimaReducaoMFD := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ECF_DataHoraReducao');
      If ValidPointer( aFunc , 'ECF_DataHoraReducao')
      then fFuncECF_DataHoraReducao := aFunc
      else bRet := False;

    End
    Else
    Begin
      ShowMessage('O arquivo CONVECF.DLL/SWMFD.DLL não foi encontrado.');
      GravaLog('O arquivo CONVECF.DLL/SWMFD.DLL não foi encontrado.');
      bRet := False;
    End;

    If bRet Then
    Begin
      GravaLog(' ECF_AbrePortaSerial -> ');
      iRet := fFuncECF_AbrePortaSerial();
      GravaLog(' ECF_AbrePortaSerial <- iRet:' + IntToStr(iRet));
      TrataRetornoSweda( iRet );
      If iRet <> 1 then
      begin
        LjMsgDlg('Erro na abertura da porta');
        GravaLog('Erro na abertura da porta');
        result := '1|';
      end
      else
      begin
        bOpened := True;

        //Log do Arquivo de Configuração
        sIni := ExtractFilePath(Application.ExeName) + 'CONVERSOR.INI';
        If FileExists(sIni) then
        Begin
          ListaArq := TStringList.Create;
          ListaArq.Clear;
          ListaArq.LoadFromFile(sIni);

          GravaLog(' ******** Arquivo CONVERSOR.INI *******');
          GravaLog( ListaArq.Text );
          GravaLog(' ******** Final da Leitura do Arquivo CONVERSOR.INI *******');
          ListaArq.Clear;
          ListaArq := NIL;
        End;
      end;
    end
    else
    begin
      result := '1|';
    end;
                                    
  End;
End;
//------------------------------------------------------------------------------
Function TrataRetornoSweda( var iRet:Integer ):String;
var
  sMsg : String;
begin
  GravaLog(' <- Retorno Sweda: '+ IntToStr(iRet));

  If (iRet < 1) and (iRet > -27) then
  begin
    sMsg := MsgErroSweda( iRet );
    MessageDlg( sMsg, mtError,[mbOK],0);
    lError := True;
  end
  else if iRet = -27 then
  begin
    lError := True;
    iRet := Status_Impressora(False);
  end;

  Result := '';
end;
//------------------------------------------------------------------------------
Function MsgErroSweda( iRet:Integer ):String;
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
    -24 : sMsg := 'Forma de pagamento não cadastrada';
  end;
  Result :=  sMsg;
end;
//------------------------------------------------------------------------------
Function Status_Impressora( lMensagem:Boolean ): Integer;
Var iACK, iST1, iST2, iRet: Integer;
Begin
    iACK := 0;
    iST1 := 0;
    iST2 := 0;
    iRet := fFuncECF_RetornoImpressora(iACK, iST1, iST2);

    GravaLog('ECF_RetornoImpressora - Status Sweda <- Retorno:'+
                IntToStr(iACK) + ', ' + IntToStr(iST1) + ', ' + IntToStr(iST2));

    If iACK = 6 then
    begin
          // Verifica ST1
          If iST1 >= 128 Then begin iST1 := iST1 - 128; iRet := 1 ; If lMensagem then LjMsgDlg('Fim de Papel'); end;
          If iST1 >= 64  Then begin iST1 := iST1 - 64;  iRet := 1 ; {If lMensagem then LjMsgDlg('Pouco Papel');} end;
          If iST1 >= 32  Then begin iST1 := iST1 - 32;  iRet := 1 ; If lMensagem then LjMsgDlg('Erro no Relógio'); end;
          If iST1 >= 16  Then begin iST1 := iST1 - 16;  iRet := 1 ; If lMensagem then LjMsgDlg('Impressora em Erro'); end;
          If iST1 >= 8   Then begin iST1 := iST1 - 8;   iRet := 1 ; If lMensagem then LjMsgDlg('CMD não iniciado com ESC'); end;
          If iST1 >= 4   Then begin iST1 := iST1 - 4;   iRet := 1 ; If lMensagem then LjMsgDlg('Comando Inexistente'); end;
          If iST1 >= 2   Then begin iST1 := iST1 - 2;   iRet := 1 ; If lMensagem then LjMsgDlg('Cupom Aberto'); end;
          If iST1 >= 1   Then begin iST1 := iST1 - 1;   iRet := 1 ; If lMensagem then LjMsgDlg('Nº de Parâmetros Inválidos'); end;

          // Verifica ST2

          If iST2 >= 128 Then begin iST2 := iST2 - 128; iRet := 1 ; If lMensagem then LjMsgDlg('Tipo de Parâmetro Inválido'); end;
          If iST2 >= 64  Then begin iST2 := iST2 - 64;  iRet := 1 ; If lMensagem then LjMsgDlg('Memória Fiscal Lotada'); end;
          If iST2 >= 32  Then begin iST2 := iST2 - 32;  iRet := 1 ; If lMensagem then LjMsgDlg('CMOS não Volátil'); end;
          If iST2 >= 16  Then begin iST2 := iST2 - 16;  iRet := 1 ; If lMensagem then LjMsgDlg('Alíquota Não Programada'); end;
          If iST2 >= 8   Then begin iST2 := iST2 - 8;   iRet := 1 ; If lMensagem then LjMsgDlg('Alíquotas Lotadas'); end;
          If iST2 >= 4   Then begin iST2 := iST2 - 4;   iRet := 1 ; If lMensagem then LjMsgDlg('Cancelamento Não Permitido'); end;
          If iST2 >= 2   Then begin iST2 := iST2 - 2;   iRet := 1 ; If lMensagem then LjMsgDlg('CGC/IE Não Programados'); end;
          If iST2 >= 1   Then begin iST2 := iST2 - 1;   iRet := -1; {If lMensagem then LjMsgDlg('Comando Não Executado');} end;
    End;
    Result := iRet;
End;
//------------------------------------------------------------------------------
Function ArqIniSweda( sPorta:String; bMfd:boolean ):Boolean;
var
  fArq : TIniFile;
  sPath,sNumPort,sIni : String;
  lRet : Boolean;
begin
  lRet := True;

  sPath := ExtractFilePath( Application.ExeName );

  If Copy(sPath,Length(sPath),1)= '\' then
  begin
    sIni := sPath+sArqIniSweda;
    Path  := sPath ;
  end
  Else
  begin
    sIni := sPath+'\'+sArqIniSweda;
    Path  := sPath +'\';
  end;

  If FileExists( sIni ) then
  begin
    Try
      sNumPort := UpperCase( Copy( sPorta, Length( sPorta ), 1 ) );

      fArq := TInifile.Create( sIni );
      If fArq.ReadString( 'COMUNICAÇÃO', 'PORTA', '' ) <> sNumPort
      then fArq.WriteString( 'COMUNICAÇÃO', 'PORTA', sNumPort );
    Except
      lRet := False;
    End;
  end
  Else
  begin
    LjMsgDlg( 'Arquivo ' + sArqIniSweda + ' não encontrado. ');
    lRet := False;
  end;

  Result := lRet;
end;
//------------------------------------------------------------------------------
Function CloseSweda : String;
var
  iRet : Integer;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      iRet := fFuncECF_FechaPortaSerial;
      TrataRetornoSweda( iRet );
      FreeLibrary(fHandle);
      fHandle := 0;
    end;
    bOpened := False;
  End;
  Result := '0';
end;

//------------------------------------------------------------------------------
// Comandos de impressora
function TImpSwedaST100.Abrir(sPorta : String; iHdlMain:Integer) : String;
var
    sPath  : String;
    sIni   : String;
    fArquivo : TIniFile;
begin
  sMarca := 'SWEDA';
  sPath  := ExtractFilePath( Application.ExeName );

  If Copy(sPath,Length(sPath),1)= '\' then
  begin
    sIni := sPath+'SWC.INI';
    Path  := sPath ;
  end
  Else
  begin
    sIni := sPath+'SWC.INI';
    Path  := sPath +'\';
  end;

  fArquivo    := TIniFile.Create(sIni);

  // Verifica o arquivo de configuracao.
  If ArqIniSweda( sPorta, False ) then
  begin
    If bOpened
    Then Result := '0'
    Else Result := OpenSweda(sPorta);

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
    LjMsgDlg( 'Problemas com o arquivo ' + sArqIniSweda );
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.Fechar( sPorta:String ):String;
begin
  Result := CloseSweda;
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.LeituraX:String;
var
  iRet : Integer;
begin
  iRet := fFuncECF_LeituraX;
  TrataRetornoSweda( iRet );
  if iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.AbreEcf:String;
begin
  Result := '0';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.AbreCupom(Cliente:String; MensagemRodape:String):String;
var
  iRet : Integer;
  aAuxiliar : TaString;
  sCnpjCpf, sNomeCli, sEnd : String;
begin
  lDescAcres:=False;
  sCnpjCpf := ' ';
  sNomeCli := ' ';
  sEnd     := ' ';

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

  iRet := fFuncECF_AbreCupomMFD(sCnpjCpf, sNomeCli, sEnd);
  TrataRetornoSweda( iRet );

  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.CancelaCupom(Supervisor:String):String;
var
  iRet : Integer;
begin
  // Para cancelar um cupom aberto deve-ser ter ao menos um item vendido.
  iRet := fFuncECF_CancelaCupomMFD( '', '', '' );
  TrataRetornoSweda( iRet );
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;
//------------------------------------------------------------------------------
Function TImpSwedaST100.ReducaoZ(MapaRes:String):String;
var
  iRet, i , nAliqISS, nBaseISS,nAliq, nBase,nCNom,nCBas,nCountAliq: Integer;
  aRetorno,aRetornoISS : array of String;
  sData, sHora , sContRet,sDtMov,sRetorno,sBase,sNome,sImp,sAux,sAux2,
  sAImp,cICMS,cISS, sTribIS1, sTribNS1, sTribFS1,
  sAliqISS,sBaseISS, sAuxISS, sTotalISS: String;
  fAImp, fIss,fLiq  : Real;
  bContinua,bGeraLog : Boolean;
begin

If Trim(MapaRes) = 'S' then
 begin
    SetLength(aRetorno,21);

    aRetorno[ 0]:= Space(6);                                //**** Data do Movimento ****//
    GravaLog(' ECF_DataMovimento -> ');
    iRet := fFuncECF_DataMovimento(aRetorno[0]);
    GravaLog(' ECF_DataMovimento <- iRet :' + IntToStr(iRet) + ' ; Retorno: '+ aRetorno[ 0]);
    aRetorno[ 0]:= Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

    aRetorno[ 1] := PDV;                                    //**** Numero do ECF ****//

    aRetorno[ 2] := PegaSerie;                              //**** Serie do ECF ****//
    If Copy(aRetorno[ 2],1,1)='0'
    then aRetorno[ 2] := Trim(Copy(aRetorno[2],3,Length(aRetorno[2])));

    aRetorno[ 3] := Space(4);                             //**** Numero de reducoes ****//
    GravaLog('ECF_NumeroReducoes ->');
    iRet := fFuncECF_NumeroReducoes( aRetorno[3] );
    GravaLog(' ECF_NumeroReducoes <- iRet :' + IntToStr(iRet) + ' ; Retorno: '+ aRetorno[3]);
    aRetorno[3] := FormataTexto(IntToStr(StrToInt(aRetorno[3])+1),4,0,2);

    aRetorno[ 4] := Space(18);                              //**** Grande Total Final ****//
    GravaLog(' ECF_GrandeTotal ->');
    iRet := fFuncECF_GrandeTotal( aRetorno[ 4] );
    GravaLog(' ECF_GrandeTotal <- iRet :' + IntToStr(iRet) );
    aRetorno[ 4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
    aRetorno[ 4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

    aRetorno[ 6] := Space(6);                           //**** Numero documento Final ****//
    GravaLog(' ECF_NumeroCupom ->');
    iRet := fFuncECF_NumeroCupom( aRetorno[ 6] );
    GravaLog(' ECF_NumeroCupom <- iRet:' + IntToStr(iRet));
    aRetorno[ 6] := FormataTexto(aRetorno[6],6,0,2);
    aRetorno[ 5] := aRetorno[ 6];

    //**** Cancelamentos ****//
    cICMS := Space (14);
    cISS  := Space (14);
    GravaLog(' ECF_CancelamentosICMSISS -> ');
    iRet := fFuncECF_CancelamentosICMSISS( cICMS, cISS );
    GravaLog(' ECF_CancelamentosICMSISS <- iRet: ' + IntToStr(iRet));

    // cancelamento de ICMS
    cICMS := Copy(cICMS, 1, Length(cICMS) - 2) + '.' + Copy(cICMS, Length(cICMS) - 1, Length(cICMS));
    cICMS := FormataTexto(cICMS, 15, 2, 1);
    aRetorno[ 7] := cICMS;

    // cancelamento de ISS
    cISS  := Copy(cISS, 1, Length(cISS) - 2) + '.' + Copy(cISS, Length(cISS) - 1, Length(cISS));
    cISS  := FormataTexto(cISS, 15, 2, 1);
    aRetorno[19] := cISS;

    {****** DESCONTOS ******}
    cICMS := Space (14);
    cISS  := Space (14);
    GravaLog(' ECF_DescontosICMSISS -> ');
    iRet := fFuncECF_DescontosICMSISS(cICMS ,cISS);
    GravaLog(' ECF_DescontosICMSISS <- iRet: ' + IntToStr(iRet));

    //**** Desconto de ICMS****//
    cICMS  := Copy(cICMS, 1, Length(cICMS) - 2) + '.' + Copy(cICMS, Length(cICMS) - 1, Length(cICMS));
    cICMS  := FormataTexto(cICMS, 11, 2, 1);
    aRetorno[9]:= cICMS ;

    //**** Desconto de ISS ****//
    cISS  := Copy(cISS, 1, Length(cISS) - 2) + '.' + Copy(cISS, Length(cISS) - 1, Length(cISS));
    cISS  := FormataTexto(cISS, 11, 2, 1);
    aRetorno[18]:= cISS ;

    //*************************//
    sRetorno := 'COMPLETO' + Space(1024);
    GravaLog(' ECF_VerificaTotalizadoresParciais -> ');
    iRet := fFuncECF_VerificaTotalizadoresParciais(sRetorno);
    sRetorno := Trim(sRetorno);
    GravaLog(' ECF_VerificaTotalizadoresParciais <- iRet [' + IntToStr(iRet) + '] - Retorno :' +sRetorno);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[11] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** ISENTO  ***//
    aRetorno[11] := Copy(aRetorno[11],1,Length(aRetorno[11])-2)+'.'+Copy(aRetorno[11],Length(aRetorno[11])-1,Length(aRetorno[11]));
    aRetorno[11] := FormataTexto(aRetorno[11],11,2,1);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[12] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** Nao tributado ****//
    aRetorno[12] := Copy(aRetorno[12],1,Length(aRetorno[12])-2)+'.'+Copy(aRetorno[12],Length(aRetorno[12])-1,Length(aRetorno[12]));
    aRetorno[12] := FormataTexto(aRetorno[12],11,2,1);

    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    aRetorno[10] := Copy(sRetorno,1,Pos(',',sRetorno)-1);           //**** SUBSTITUIcao TRIB ****//
    aRetorno[10] := Copy(aRetorno[10],1,Length(aRetorno[10])-2)+'.'+Copy(aRetorno[10],Length(aRetorno[10])-1,Length(aRetorno[10]));
    aRetorno[10] := FormataTexto(aRetorno[10],11,2,1);

    sRetorno := Copy(sRetorno,(11*14)+23,Length(sRetorno));

    //Isenção de ISS - IS
    sTribIS1 := Copy(sRetorno,1,Pos(',',sRetorno)-1);
    sTribIS1 := Copy(sTribIS1,1,Length(sTribIS1)-2)+'.'+Copy(sTribIS1,Length(sTribIS1)-1,Length(sTribIS1));
    sTribIS1 := FormataTexto(sTribIS1,14,2,1);

    //Não tributado de ISS - NS
    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    sTribNS1 := Copy(sRetorno,1,Pos(',',sRetorno)-1);
    sTribNS1 := Copy(sTribNS1,1,Length(sTribNS1)-2)+'.'+Copy(sTribNS1,Length(sTribNS1)-1,Length(sTribNS1));
    sTribNS1 := FormataTexto(sTribNS1,14,2,1);

    //Substituição de ISS - FS
    sRetorno := Copy(sRetorno,Pos(',',sRetorno)+1,Length(sRetorno));
    sTribFS1 := Copy(sRetorno,1,Pos(',',sRetorno)-1);
    sTribFS1 := Copy(sTribFS1,1,Length(sTribFS1)-2)+'.'+Copy(sTribFS1,Length(sTribFS1)-1,Length(sTribFS1));
    sTribFS1 := FormataTexto(sTribFS1,14,2,1);

    aRetorno[13] := Copy(StatusImp(2),3,10);                     //**** Data da Reducao  Z ****//
    aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);

    aRetorno[15] := FormataTexto('0',16, 0, 1);         // --outros recebimentos--
    aRetorno[20]:= '00';                                // QTD DE Aliquotas

    // Contador de Reinicio de operação
    aRetorno[17] := Space( 950 );
    GravaLog(' ECF_RetornaRegistradoresNaoFiscais -> ');
    fFuncECF_RetornaRegistradoresNaoFiscais( aRetorno[17] );
    GravaLog(' ECF_RetornaRegistradoresNaoFiscais <- iRet: ' + IntToStr(iRet) + ', Retorno:' +aRetorno[17]);
    aRetorno[17] := Copy( aRetorno[17], 42, 4 );

    // Aliquotas T e S
    ///////////// Acha o valor base de cada alíquota( ICMS e ISS )
    sBase := Space( 400 );
    GravaLog(' ECF_RetornaRegistradoresFiscais -> ');
    iRet := fFuncECF_RetornaRegistradoresFiscais( sBase );
    GravaLog(' ECF_RetornaRegistradoresFiscais <- iRet: ' + IntToStr(iRet) + ', Retorno:' +sBase);
    sBase := Copy( sBase, 95, 224 );

    //////////// Acha o nome das aliquotas( ICMS )
    sNome := Space( 300 );
    GravaLog(' ECF_LerAliquotasComIndice -> ');
    iRet := fFuncECF_LerAliquotasComIndice( sNome );
    GravaLog(' ECF_LerAliquotasComIndice <- iRet: ' + IntToStr(iRet) + ', Retorno:' +sNome);
    sAux := sNome;
    sNome := '';
    nAliq := 0;

    /////////// Monta os nomes de ICMS
    While Copy( sAux, 1, 1 ) = 'T' Do
    Begin
      sNome := sNome + 'T' + Copy( sAux, 3, 2 ) + '.' + Copy( sAux, 5, 2 ) + '|';
      sAux := Copy( sAux, 8, Length( sAux ) );
      Inc( nAliq );
    End;

    /////////// Monta os nomes de ISS
    While Copy( sAux, 1, 1 ) = 'S' Do
    Begin
      sAliqISS := sAliqISS + 'S' + Copy( sAux, 3, 2 ) + '.' + Copy( sAux, 5, 2 ) + '|';
      sAux := Copy( sAux, 8, Length( sAux ) );
      Inc( nAliqISS );
    End;

    ////////// Monta as Bases  de ICMS
    sAux := sBase;
    sBase := '';
    nBase := 1;
    While nBase <= nAliq Do
    Begin
      sBase := sBase + Copy( sAux, 1, 14 ) + '|';
      sAux := Copy( sAux, 15, Length( sAux ) );
      Inc( nBase );
    End;

    ////////// Monta as Bases  de ISS
    sAuxISS := sAux; // Pega o resto do conteúdo vindo dos valores de alíquotas
    sBaseISS := '';
    nBaseISS := 1;
    While nBaseISS <= nAliqISS Do
    Begin
      sBaseISS := sBaseISS + Copy( sAuxISS, 1, 14 ) + '|';
      sAuxISS := Copy( sAuxISS, 15, Length( sAuxISS ) );
      Inc( nBaseISS );
    End;

    ///////// Monta os impostos debitados - ICMS
    nBase := 1;
    nCNom := 2;
    nCBas := 1;
    While nBase <= nAliq Do
    Begin
      fAImp := (StrToFloat( Copy( sNome, nCNom, 5 ) ) / 100 )  * ( StrToFloat( Copy( sBase, nCBas, 14 ) ) /100 );
      sAImp := FormatCurr('00000000000.00',fAImp);
      sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;

      If ( Length( sAImp ) - Pos( '.', sAImp ) > 2 ) And ( Pos( '.', sAImp ) > 0 )
      Then sAimp := Copy( sAImp, 1, Pos( '.', sAImp ) + 2 );

      If Pos( '.', sAImp ) = 0
      Then sAimp := '00000000000.00'
      Else sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;

      sImp  := sImp + sAImp + '|';
      nCnom := nCNom + 7;
      nCBas := nCBas + 15;
      Inc( nBase );
    End;

    nBase := 1;
    nCountAliq := nAliq;
    While nBase <= nALiq do
    Begin
      For i:= 20 to Length(aRetorno)-1 do
      begin
        If Copy(aRetorno[i],1,6) = Copy(sNome,1,6) then //Valida se a alíquota está cadastrada duas vezes ou mais no ECF
        begin
          sAux := FormatCurr('00000000000.00', StrToFloat(Copy(aRetorno[i],8,14)) + StrToFloat(Copy( sBase, 2, 11 ) + '.' + Copy( sBase, 13, 2 )));
          sAux2:= FormatCurr('00000000000.00', StrToFloat(Copy(aRetorno[i],23,14)) + StrToFloat(Copy( sImp, 1, 14 )));
          aRetorno[i] := Copy( sNome, 1, 6 ) + ' ' + sAux + ' ' + sAux2;
          bContinua := False;
          nCountAliq := nCountAliq - 1; //subtrai uma alíquota pois são iguais
          Break;
        end
        else bContinua := True;
      end;

      If bContinua then
      begin
        SetLength( aRetorno, Length( aRetorno ) + 1 );
                                      // Aliquota                       Base                                                  Valor Debitado
        aRetorno[ High( aRetorno ) ] := Copy( sNome, 1, 6 ) + ' ' + Copy( sBase, 2, 11 ) + '.' + Copy( sBase, 13, 2 ) + ' ' + Copy( sImp, 1, 14 );
      end;

      sNome := Copy( sNome, 8, Length( sNome ) );
      sBase := Copy( sBase, 16, Length( sBase ) );
      sImp  := Copy( sImp, 16, Length( sImp ) );
      Inc(nBase);
    End;

    nAliq := nCountAliq; //Ajusta a quantidade de alíquotas cadastradas, removendo as que são iguais

    ///////// Monta os impostos debitados - ISS
    nBaseISS := 1;
    nCNom := 2;
    nCBas := 1;
    sImp  := '';
    sAImp := '';
    While nBaseISS <= nAliqISS Do
    Begin
      fAImp := (StrToFloat( Copy( sAliqISS, nCNom, 5 ) ) / 100 )  * ( StrToFloat( Copy( sBaseISS, nCBas, 14 ) ) /100 );
      sAImp := FormatCurr('00000000000.00',fAImp);
      sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;

      If ( Length( sAImp ) - Pos( '.', sAImp ) > 2 ) And ( Pos( '.', sAImp ) > 0 )
      Then sAimp := Copy( sAImp, 1, Pos( '.', sAImp ) + 2 );

      If Pos( '.', sAImp ) = 0
      Then sAimp := '00000000000.00'
      Else sAimp := Replicate( '0', 14 - Length( sAimp ) ) + sAImp;

      sImp  := sImp + sAImp + '|';
      nCnom := nCNom + 7;
      nCBas := nCBas + 15;
      Inc( nBaseISS );
    End;

    fIss := 0;
    nBaseISS := 1;
    While nBaseISS <= nAliqISS Do
    Begin
      SetLength( aRetornoISS, Length( aRetornoISS ) + 1 );
                                      // Aliquota                       Base                                                  Valor Debitado
      aRetornoISS[ High( aRetornoISS ) ] := Copy( sAliqISS, 1, 6 ) + ' ' + Copy( sBaseISS, 2, 11 ) + '.' + Copy( sBaseISS, 13, 2 ) + ' ' + Copy( sImp, 1, 14 );

      fIss := fIss + StrToFloat(Copy( sBaseISS, 2, 11 ) + '.' + Copy( sBaseISS, 13, 2 ));

      sAliqISS := Copy( sAliqISS, 8, Length( sAliqISS ) );
      sBaseISS := Copy( sBaseISS, 16, Length( sBaseISS ) );
      sImp  := Copy( sImp, 16, Length( sImp ) );
      Inc( nBaseISS );
    End;

    aRetorno[16] := '';
    For nBaseISS := 0 to Length(aRetornoISS) - 1 do
      aRetorno[16] := aRetorno[16] + aRetornoISS[nBaseISS] + ';'; // deve ser utilizado ponto e vírgula para separar porque pipe
                                                                  //é o separador no LOJA160 e se posto serão acrescidas mais
                                                                  //posições ao array de tratamento final
    //Total de ISS
    sTotalISS := FormatCurr('00000000000.00', fIss );

    // O retorno final de aretorno[16] será : Pos 1 - Total de ISS ; Pos 2 em diante : alíquotas de ISS ( Nome da Aliquota , Base , Valor Debitado )
    aRetorno[16] := sTotalISS + ';' + Trim(aRetorno[16]);

    If Copy(Trim(aRetorno[16]),Length(Trim(aRetorno[16])),1) <> ';'
    then aRetorno[16] := aRetorno[16] + ';';

    //Aliquota com 3 digitos + ' ' + Valor Base com 12 casas e 2 decimais + ' ' +
    //       Valor Debitado com 12 casas e 2 decimais + Separador ';'
    If StrToFloat(sTribIS1) > 0
    then aRetorno[16] := aRetorno[16] + 'IS1' + ' ' + sTribIS1 + ' ' + FormataTexto('0',14,2,1) + ';' ;

    If StrToFloat(sTribNS1) > 0
    then aRetorno[16] := aRetorno[16] + 'NS1' + ' ' + sTribNS1 + ' ' + FormataTexto('0',14,2,1) + ';' ;

    If StrToFloat(sTribFS1) > 0
    then aRetorno[16] := aRetorno[16] + 'FS1' + ' ' + sTribFS1 + ' ' + FormataTexto('0',14,2,1) + ';' ;

    aRetorno[20] := FormataTexto( IntToStr(nAliq), 2, 0, 2 );

    // Venda Líquida
    aRetorno[ 8] := Space( 18 );
    GravaLog(' ECF_VendaBruta -> ');
    iRet := fFuncECF_VendaBruta( aRetorno[ 8] );
    GravaLog(' ECF_VendaBruta <- iRet: ' + IntToStr(iRet) + ',Retorno:' + aRetorno[ 8]);
    aRetorno[ 8] := Copy( aRetorno[ 8], 1, Length( aRetorno[ 8]) - 2 ) + '.' + Copy( aRetorno[ 8], Length( aRetorno[ 8]) - 1, Length( aRetorno[ 8]) );
    fLiq := StrToFloat( aRetorno[ 8] ) - StrToFloat( aRetorno[ 7] ) - StrToFloat( aRetorno[ 9]) - StrToFloat( sTotalISS ) - StrToFloat( aRetorno[ 18] ) - StrToFloat( aRetorno[19] );
    aRetorno[ 8] := FloatToStr( fLiq );

    If Pos( '.', aRetorno[ 8] ) = 0
    Then aRetorno[ 8] := Replicate( '0', 12 - Length( aRetorno[ 8] ) ) + aRetorno[ 8] + '.00'
    Else If Pos( '.', aRetorno[ 8] ) = Length( aRetorno[ 8] ) - 1
    Then aRetorno[ 8] := Replicate( '0', 14 - Length( aRetorno[ 8] ) ) + aRetorno[ 8] + '0'
    Else If Pos( '.', aRetorno[ 8] ) = Length( aRetorno[ 8] ) - 2
    Then aRetorno[ 8] := Replicate( '0', 15 - Length( aRetorno[ 8] ) ) + aRetorno[ 8];
 end;

 DateTimeToString( sData, 'dd/mm/yyyy', Date );
 DateTimeToString( sHora, 'hh:mm:ss', Time );
 GravaLog('Sweda -> ECF_ReducaoZ - Data : ' + sData);
 GravaLog('Sweda -> ECF_ReducaoZ - Hora : ' + sHora);
 GravaLog('Sweda -> ECF_ReducaoZ ->');
 bGeraLog:= False;

 Try
   GrvTempRedZ(aRetorno); //realiza backup dos dados antes da Reducao Z
 Except
   GravaLog('Sweda - Redução Z - Erro na execução do comando: GrvTempRedZ()')
 End;

 Try
   iRet := fFuncECF_ReducaoZ( pChar(sData), pChar(sHora));
 Except
   iRet := 0;
   GravaLog(' Sweda - Redução Z - Erro na execução do comando')
 End;

 GravaLog('Sweda <- ECF_ReducaoZ - Retorno [' + IntToStr(iRet) + ']');
 TrataRetornoSweda( iRet );

If iRet = 1 then
begin
  If aRetorno[0] = '00/00/00' then
  begin
    GravaLog('ReducaoZ -> Impressora está sem movimento com data de movimento igual a 00/00/00 ' +
             'portanto será capturada a data da ultima Redução Z constante na MFD do ECF');
    sAux := Space(6);
    sAux2:= Space(6);
    GravaLog(' ECF_DataMovimentoUltimaReducaoMFD -> ');
    iRet := fFuncECF_DataMovimentoUltimaReducaoMFD( sAux );
    GravaLog(' ECF_DataMovimentoUltimaReducaoMFD <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux );
    sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);
    aRetorno[0] := sAux;
    GravaLog('ReducaoZ -> Data do movimento modificada para :' + aRetorno[0]);
  end;

  If Trim(MapaRes) = 'S' then
  begin
     //*************************************************************************
     // Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
     //*************************************************************************
     Result := '0|';
     For i:= 0 to High(aRetorno) do
        Result := Result + aRetorno[i]+'|';

     GravaLog('Sweda Fiscal - Mapa Resumo <- Retorno [ '+ Result + ']');
  end
  Else
      Result := '0';
end
Else
  Result := '1';

end;
//------------------------------------------------------------------------------
function TImpSwedaST100.PegaCupom(Cancelamento:String):String;
var
  iRet : Integer;
  sNumCupom : String;
  iCont: Integer;
begin

  // Máximo de 20 tentativas para resgatar o numero do cupom fiscal
  iCont := 20;
  iRet  := 0;
  While (iRet = 0) And (iCont > 0) Do
  Begin
     Sleep(500);
     sNumCupom := Space( 6 );
     GravaLog('ECF_NumeroCupom ->');
     iRet  := fFuncECF_NumeroCupom( sNumCupom );
     GravaLog(' ECF_NumeroCupom <- iRet : ' + IntToStr(iRet) + '; Retorno: ' + sNumCupom);
     iCont := iCont - 1
  End;

  TrataRetornoSweda( iRet );

  If iRet = 1
  then Result := '0|' + sNumCupom
  Else Result := '1';
end;

//------------------------------------------------------------------------------
function TImpSwedaST100.PegaPDV:String;
begin
  Result := '0|' + PDV;
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.LeAliquotas:String;
begin
  Result := '0|' + ICMS;
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.LeAliquotasISS:String;
begin
  Result := '0|' + ISS;
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
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
  sTrib, sAliquota, sIndiceISS, sAliqISS,sTipoQtd : String;
  iCasas: Integer;
  bISSAlq : Boolean;
begin
  iCasas := 2;
  bISSAlq := False;

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

  If bISSAlq = False then
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
    GravaLog(' ECF_VerificaIndiceAliquotasIss -> ');
    iRet := fFuncECF_VerificaIndiceAliquotasIss( sIndiceISS );
    GravaLog(' ECF_VerificaIndiceAliquotasIss <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda(iRet);
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
    GravaLog(' ECF_AumentaDescricaoItem -> ');
    fFuncECF_AumentaDescricaoItem(Descricao);
    GravaLog(' ECF_AumentaDescricaoItem <- ');
    // Coloca o tamanho da descrição para 29 posições devido a uma obrigatoriedade da função Bematech_FI_VendeItem
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

  If iRet <> 1
  then Result := '1';

  // Retistra o Item
  GravaLog(' ECF_VendeItem -> Codigo:' + Codigo +', Descricao:' + descricao + ', Aliquota:' + sAliquota +
           ', TpQdte : ' + sTipoQtd + ', Qtde: ' + Qtde + ', Casas: ' + IntToStr(iCasas) + ', Valor:' + vlrUnit +
           ',$, Desconto:' + vlrDesconto);
  iRet := fFuncECF_VendeItem( Codigo, descricao, sAliquota, sTipoQtd, Qtde, iCasas, vlrUnit,'$', vlrDesconto );
  GravaLog('ECF_VendeItem <- iRet :' + IntToStr(iRet));
  TrataRetornoSweda( iRet );
  If iRet = 1
  then Result := '0'
  Else Result := '1';

end;
//------------------------------------------------------------------------------
function TImpSwedaST100.LeCondPag:String;
var
  iRet, i : Integer;
  sRet : String;
  sPagto : String;
begin
  sRet := Space( 3016 );
  iRet := fFuncECF_VerificaFormasPagamento( sRet );
  TrataRetornoSweda( iRet );
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
//------------------------------------------------------------------------------
function TImpSwedaST100.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var
  iRet : Integer;
begin
  NumItem := FormataTexto( numitem, 3, 0, 2 );
  GravaLog(' ECF_CancelaItemGenerico -> Item:' + NumItem);
  iRet := fFuncECF_CancelaItemGenerico( NumItem );
  GravaLog(' ECF_CancelaItemGenerico <- iRet:' + IntToStr(iRet));
  TrataRetornoSweda( iRet );
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.FechaCupom( Mensagem:String ):String;
var
  iRet: Integer;
  cMsg: String;
begin
    cMsg := TrataTags( Mensagem );
    GravaLog(' ECF_TerminaFechamentoCupom -> Mensagem' + cMsg);
    iRet := fFuncECF_TerminaFechamentoCupom(pChar(cMsg));
    GravaLog(' ECF_TerminaFechamentoCupom <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda( iRet );
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
//------------------------------------------------------------------------------
function TImpSwedaST100.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;
var iRet    : integer;
    sFrmPag : String;
    sVlrPag : String;
begin
  while Length(pagamento) > 0 do
  begin
    If Pos('|',Pagamento)>17 then
        sFrmPag := Copy(Pagamento,1,16)
    else
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

    GravaLog(' ECF_EfetuaFormaPagamento -> Forma:' + sFrmPag + ', Valor:' + sVlrPag);
    iRet := fFuncECF_EfetuaFormaPagamento( sFrmPag , sVlrPag);
    GravaLog(' ECF_EfetuaFormaPagamento <- iRet:' + IntToStr(iRet));
  end;
  TrataRetornoSweda( iRet );

  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String;
var iRet: integer;
begin
    GravaLog(' ECF_IniciaFechamentoCupom -> D, $,' + vlrDesconto );
    iRet := fFuncECF_IniciaFechamentoCupom('D', '$', pChar( vlrDesconto ) );
    GravaLog(' ECF_IniciaFechamentoCupom <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda( iRet );
    If iRet = 1 then
    begin
       lDescAcres:=True;
       Result := '0';
    End
    Else
       Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.AcrescimoTotal( vlrAcrescimo:String ): String;
var iRet: integer;
begin
    GravaLog(' ECF_IniciaFechamentoCupom -> D, $,' + vlrAcrescimo );
    iRet := fFuncECF_IniciaFechamentoCupom('A','$', pChar( vlrAcrescimo ));
    GravaLog(' ECF_IniciaFechamentoCupom <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda( iRet );
    If iRet >= 0 then
    Begin
       lDescAcres:=True;
       Result := '0';
    End
    Else
       Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String;
var
  iRet : Integer;
  sDatai : String;
  sDataf : String;
  sTipoAux: String;
  bPorData: Boolean;
begin
  //Parametro "Tipo" recebe string com duas posições:
  //Primeira posição: "I" para impressão e "A" salvar arquivo
  //Segunda posição: "S" para leitura simplificada e "C" para leitura completa

  sTipoAux := UpperCase(Copy(Tipo,2,1)) ; //Configura se Leitura será Simplificada ou Completa, padrão Completa.

  if Not((sTipoAux = 'S') or (sTipoAux = 'C')) then
    sTipoAux := 'C';

  bPorData := (Trim(ReducInicio + ReducFim) = '');

  // Se o relatório for por Data
  If bPorData then
  begin
    sDatai := FormataData( DataInicio, 3 );
    sDataf := FormataData( DataFim, 3 );
  end
  else
  begin
    ReducInicio := FormataTexto(ReducInicio,4,0,2);
    ReducfIM    := FormataTexto(ReducfIM,4,0,2);
  end;

  if copy(Tipo,1,1) = 'I' then
  begin
      // Se o relatório for por Data
      If bPorData then
      begin
        GravaLog(' ECF_LeituraMemoriaFiscalDataMFD -> Inicio :' + sDatai + ' , Final : ' + sDataf + ', Tipo:' + sTipoAux );
        iRet := fFuncECF_LeituraMemoriaFiscalDataMFD(Pchar(sDatai),Pchar(sDataf),Pchar(sTipoAux));
        GravaLog(' ECF_LeituraMemoriaFiscalDataMFD <- iRet:' + IntToStr(iRet));
        TrataRetornoSweda( iRet );
        If iRet >= 0
        then Result := '0'
        Else Result := '1';
      end
      Else       // Se o relatório será por redução Z
      Begin
        GravaLog(' ECF_LeituraMemoriaFiscalReducaoMFD -> Inicio :' + ReducInicio + ', Final : ' + ReducFim + ', Tipo:' + sTipoAux );
        iRet :=fFuncECF_LeituraMemoriaFiscalReducaoMFD(Pchar(ReducInicio),Pchar(ReducFim),Pchar(sTipoAux));
        GravaLog(' ECF_LeituraMemoriaFiscalReducaoMFD <- iRet:' + IntToStr(iRet));
        TrataRetornoSweda( iRet );
        If iRet >= 0
        then Result := '0'
        Else Result := '1';
      end;
  end
  Else
  Begin
      // Se o relatório for por Data
      If bPorData then
      begin
        GravaLog(' ECF_LeituraMemoriaFiscalSerialDataMFD -> Inicio :' + sDatai + ' , Final : ' + sDataf + ', Tipo:' + sTipoAux );
        iRet := fFuncECF_LeituraMemoriaFiscalSerialDataMFD(PChar(sDatai),Pchar(sDataf),Pchar(sTipoAux));
        GravaLog(' ECF_LeituraMemoriaFiscalDataMFD <- iRet:' + IntToStr(iRet));
        TrataRetornoSweda( iRet );
        If iRet = 1
        then Result := '0'
        Else Result := '1';
      end
      Else       // Se o relatório será por redução Z
      Begin
        GravaLog(' ECF_LeituraMemoriaFiscalSerialReducaoMFD -> Inicio :' + ReducInicio + ', Final : ' + ReducFim + ', Tipo:' + sTipoAux );
        iRet :=fFuncECF_LeituraMemoriaFiscalSerialReducaoMFD(Pchar(ReducInicio),Pchar(ReducFim),Pchar(sTipoAux));
        GravaLog(' ECF_LeituraMemoriaFiscalSerialReducaoMFD <- iRet:' + IntToStr(iRet));
        TrataRetornoSweda( iRet );
        If iRet = 1
        then Result := '0'
        Else Result := '1';
      end;

      //verifica se irá salvar relatório Completo ou Simplificado
      If (Result = '0') then
      Begin
        If sTipoAux = 'S'
        Then Result := CopRenArquivo( sPathEcfRegistry, sArqEcfDefault, PathArquivo, DEFAULT_ARQMEMSIM )
        Else Result := CopRenArquivo( sPathEcfRegistry, sArqEcfDefault, PathArquivo, DEFAULT_ARQMEMCOM );
      End;
  end;
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
// Tipo = 1 - ICMS
// Tipo = 2 - ISS
var
  iRet : Integer;
begin
    If Tipo=1 then Tipo := 0;
    If Tipo=2 then Tipo := 1;
    Aliquota := FormataTexto(Aliquota,5,2,1);
    Aliquota := StrTran(Aliquota,'.','');
    GravaLog(' ECF_ProgramaAliquota -> Aliquota :' + Aliquota + ', Tipo : ' + IntToStr(Tipo) );
    iRet := fFuncECF_ProgramaAliquota( Aliquota , Tipo );
    GravaLog(' ECF_ProgramaAliquota <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda( iRet );
    If iRet = 1 then
    begin
       iRet := Status_Impressora( True );
       If iRet = 1
       then Result := '0'
       Else Result := '1';
    end
    Else
       Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String;
var
  iRet : Integer;
  sRetFormas : String;
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

  //A forma de pagamento utilizada no comprovante vinculado não pode ser "Dinheiro",
  //mas pode ser "DINHEIRO".
  Condicao := Copy( Condicao, 1, 16 );

  //*******************************************************************************
  // Abre o comprovante não fiscal. Tenta abrir um vinculado mas caso não consiga
  // faz um recebimento não fiscal para depois abrir o comprovante não fiscal
  // Condicao = Descricao da Forma de pagamento - Nao pode ser DINHEIRO
  //*******************************************************************************
  GravaLog('ECF_AbreComprovanteNaoFiscalVinculado -> Condicao: ' + Condicao + ', Valor :' + Valor);
  VldFormaPgto(Condicao);

  iRet := fFuncECF_AbreComprovanteNaoFiscalVinculado( Condicao, Valor, '' );
  GravaLog('ECF_AbreComprovanteNaoFiscalVinculado <- iRet: ' + IntToStr(iRet));
  If iRet <> 0 then
  Begin
      If Status_Impressora( False ) = 1 then
        Result := '0'
      Else
      begin
         // Faz um recebimento não fiscal para abrir o cupom vinculado
         GravaLog('ECF_RecebimentoNaoFiscal -> Totalizador:' + Totalizador + ', Valor:' + Valor + ', Condicao:' + Condicao );
         iRet := fFuncECF_RecebimentoNaoFiscal( pchar(Totalizador), pchar(Valor), pchar(Condicao) );
         GravaLog('ECF_RecebimentoNaoFiscal <- iRet : ' + IntToStr(iRet));
         If Status_Impressora( False ) = 1 then
         begin
            // Abre o comprovante vinculado
            iRet := fFuncECF_AbreComprovanteNaoFiscalVinculado( Condicao, Valor, '' );
            TrataRetornoSweda( iRet );
            If Status_Impressora( False ) = 1 then
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
  then TrataRetornoSweda( iRet );
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.TextoNaoFiscal( Texto:String; Vias:Integer ):String;
var
  sTexto,sTxtAux  : String;
  i,iRet,nCar ,nTamTexto: Integer;
  oLista : TStringList;
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

  oLista := TStringList.Create();
  oLista.Clear;
  sTexto := Texto;

  nCar := Pos(#10,sTexto);
  While nCar > 0 do
  Begin
    nCar     := Pos(#10,sTexto);
    sTxtAux  := sTxtAux + Copy(sTexto,1,nCar) ;
    sTexto:= Copy(sTexto,nCar+1,Length(sTexto));

    If Length(sTxtAux) >= 450 Then
    Begin
      oLista.Add(sTxtAux);
      sTxtAux := ''
    end;
  End;

  If Trim(sTexto) <> '' Then sTxtAux := ' ' + sTxtAux + sTexto + #10;
  If Trim(sTxtAux) <> '' Then oLista.Add(sTxtAux);

  GravaLog(' ECF_UsaComprovanteNaoFiscalVinculado -> Texto:' + Texto);
  For nCar := 0 to oLista.Count-1 do
     iRet   := fFuncECF_UsaComprovanteNaoFiscalVinculado( oLista.Strings[nCar] );
  GravaLog(' ECF_UsaComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));
  TrataRetornoSweda( iRet );
end;

//------------------------------------------------------------------------------
function TImpSwedaST100.FechaCupomNaoFiscal: String;
var
  iRet : Integer;
begin
  GravaLog('ECF_FechaComprovanteNaoFiscalVinculado ->');
  iRet := fFuncECF_FechaComprovanteNaoFiscalVinculado;
  GravaLog(' ECF_FechaComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));
  If iRet <> 0 then
  Begin
      iRet := Status_Impressora( True );
      If iRet = 1
      then Result := '0'
      Else Result := '1';
  End
  Else
    Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.ReImpCupomNaoFiscal( Texto:String ):String;
begin
  LjMsgDlg( 'Função não disponível para essa impressora.' );
  Result := '0';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.Suprimento( Tipo:Integer; Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
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
         GravaLog(' ECF_Suprimento ->');
         iRet:= fFuncECF_Suprimento(Valor,'Dinheiro');
         GravaLog(' ECF_Suprimento <- iRet:' + IntToStr(iRet));
         TrataRetornoSweda( iRet );
         If iRet = 1
         then Result := '0'
         Else Result := '1';
        end;
    3: begin
         GravaLog(' ECF_Sangria ->');
         iRet:= fFuncECF_Sangria(Valor);
         GravaLog(' ECF_Sangria <- iRet:' + IntToStr(iRet));
         TrataRetornoSweda( iRet );
         If iRet = 1
         then Result := '0'
         Else Result := '1';
       end;
  end;
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.StatusImp( Tipo:Integer ):String;
var
  iRet : Integer;
  sRet, Data, Hora, sDataHoje, sUltimoItem : String;
  dDtHoje,dDtMov:TDateTime;
  i : Integer;
  iAck, iSt1, iSt2 : Integer;
  sVendaBruta, sSubTotal : String;
  sGrandeTotal: String;
  sDataMov: String;
  sContadorCrz: String;
  sDataIntEprom,sHoraIntEprom,sDataUltDoc,sGTFinal, sCuponsEmitidos,sOperacoes,sGRG, sCDC,sCompl, sModeloFiscal, sMarca, sModelo, sTipo, sVersaoFirmware: String;
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
  // 43 e 44- Reservado Autocom
  // 45  - Modelo Fiscal
  // 46 - Marca, Modelo e Firmware

  //  1 - Obtem a Hora da Impressora
  If Tipo = 1 then
  begin
    Data:=Space(6);
    Hora:=Space(6);
    iRet := fFuncECF_DataHoraImpressora( Data, Hora );
    TrataRetornoSweda( iRet );
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
    iRet := fFuncECF_DataHoraImpressora( Data, Hora );
    TrataRetornoSweda( iRet );
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
    iRet := fFuncECF_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
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
    iRet := fFuncECF_VerificaEstadoImpressora( iAck, iSt1, iSt2 );
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
      iRet := fFuncECF_VerificaFormasPagamento( sRet );
      TrataRetornoSweda( iRet );
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
    iRet:=fFuncECF_DataMovimento(Data);
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
    iRet := fFuncECF_VendaBruta( sVendaBRuta );
    TrataRetornoSweda( iRet );
    If iRet = 1 then
        Result := '0|' + sVendaBRuta
    Else
        Result := '1';
  end
  // 18 - Verifica Grande Total
  else if Tipo = 18 then
  begin
    sGrandeTotal:= Space(18);
    GravaLog(' ECF_GrandeTotal -> ');
    iRet := fFuncECF_GrandeTotal( sGrandeTotal );
    GravaLog(' ECF_GrandeTotal <- iRet: ' + IntToStr(iRet));
    TrataRetornoSweda( iRet );
    If iRet = 1
    then Result := '0|' + sGrandeTotal
    Else Result := '1';

    GravaLog(' Sweda - Status(18) <- ' + Result);
  end
  // 19 - Verifica a data de movimento da impressora
  else if Tipo = 19 then
  begin
    sDataMov    := Space(6);
    sDataHoje   := Space(6);
    GravaLog(' ECF_DataMovimento -> ');
    iRet        := fFuncECF_DataMovimento( sDataMov );
    GravaLog(' ECF_DataMovimento <- iRet: ' + IntToStr(iRet));
    TrataRetornoSweda( iRet );
    Data        := Space(6);

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
        // Retornou erro na opercao do 19
        Result := '-1';

    GravaLog(' Sweda - Status(19) <- ' + Result);
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
    sContadorCrz := Space(4);
    If ReducaoEmitida then
    begin
      iRet := fFuncECF_RetornaCRZ(sContadorCrz);
      TrataRetornoSweda( iRet );
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
      // Calcula o Grande Total Inicial, (GTFinal - VendaBrutaDia)
      try
        sGTFinal := Space(18);
        iRet := fFuncECF_GrandeTotal(sGTFinal);
        TrataRetornoSweda( iRet );

        sGTFinal := FormataTexto(StrTran(sGTFinal,'.',''),15,2,1,'.');

        If Not(iRet = 1) then Abort;//foi tratado com Try para evitar que apenas o último comando retorne 1

        sVendaBruta := Space(18);
        iRet := fFuncECF_VendaBruta(sVendaBruta);
        TrataRetornoSweda( iRet );

        sVendaBruta := FormataTexto(StrTran(sVendaBruta,'.',''),15,2,1,'.');
      except
      end;

      If iRet = 1 then
      begin
        GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );
        Result := '0|' + GTInicial;
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
      iRet := fFuncECF_GrandeTotal(sGTFinal);
      TrataRetornoSweda( iRet );
      If iRet = 1 then
      begin
        sGTFinal := FormataTexto(StrTran(sGTFinal,'.',''),15,2,1,'.');
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
      iRet := fFuncECF_VendaBruta( sVendaBruta );
      TrataRetornoSweda( iRet );
      If iRet = 1 then
      begin
        sVendaBruta := FormataTexto(StrTran(sVendaBruta,'.',''),15,2,1,'.');
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
    iRet := fFuncECF_ContadorCupomFiscalMFD(sCuponsEmitidos);
    TrataRetornoSweda( iRet );

    If iRet = 1 then
      Result := '0|' + sCuponsEmitidos
    else
      Result := '1';
  end

  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  else if Tipo = 36 then
  begin
    sOperacoes := Space(6);
    iRet := fFuncECF_NumeroOperacoesNaoFiscais(sOperacoes);
    TrataRetornoSweda( iRet );

    If iRet = 1 then
      Result := '0|' + sOperacoes
    Else
      Result := '1';
  end

  // 37 - Retorna o Contador Geral de Relatório Gerencial
  else if Tipo = 37 then
  begin
    sGRG := Space(6);
    iRet := fFuncECF_ContadorRelatoriosGerenciaisMFD(sGRG);
    TrataRetornoSweda( iRet );

    If iRet = 1 then
      Result := '0|' + sGRG
    Else
      Result := '1';
  end

  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  else if Tipo = 38 then
  begin
    sCDC := Space(4);
    iRet := fFuncECF_ContadorComprovantesCreditoMFD(sCDC);
    TrataRetornoSweda( iRet );

    If iRet = 1 then
      Result := '0|' + sCDC
    Else
      Result := '1';
  end

  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  else if Tipo = 39 then
  begin
    sDataUltDoc := Space(12);
    iRet := fFuncECF_DataHoraUltimoDocumentoMFD( sDataUltDoc );
    TrataRetornoSweda( iRet );

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
    iRet := fFuncECF_UltimoItemVendido( sUltimoItem );
    If iRet = 1 then
      Result := '0|' + sUltimoItem
    Else
      Result := '1';
  End

  // 42 - Retorna o subtotal do cupom
  else if Tipo = 42 then
  Begin
    sSubTotal := Space(14);
    iRet := fFuncECF_SubTotal( sSubTotal );
    If iRet = 1 then
      Result := '0|' + sSubTotal
    Else
      Result := '1';
  End
  else If Tipo = 45 then //Codigo Modelo Fiscal
          begin
             sModeloFiscal :=Space(6);
             sCompl := space(128);
             iRet := fFuncECF_CodigoModeloFiscal( sModeloFiscal, sCompl );
             TrataRetornoSweda( iRet );
             If iRet = 1 then
                begin
                 Result := '0|'+Trim(sModeloFiscal);
                end
             Else
              Result := '1';
          end

 else If Tipo = 46 then //Identificação Protheus ECF (Marca, Modelo, firmware)
          begin
             sMarca := space(15);
             sModelo := space(20);
             sTipo := space(7);
             iRet := fFuncECF_MarcaModeloTipoImpressoraMFD( sMarca, sModelo, sTipo );
             TrataRetornoSweda( iRet );
             If iRet = 1 then
                begin
                 Result := '0|'+Trim(sMarca) + ' ' + Trim(sModelo) + ' - V. ';
                 sVersaoFirmware := space(6);
                 iRet := fFuncECF_VersaoFirmwareMFD( sVersaoFirmware );
                 TrataRetornoSweda( iRet );
                 If iRet = 1 then Result := Result + sVersaoFirmware;

                end
             Else
              Result := '1';
          end
  else
    Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.Gaveta:String;
var
  iRet : Integer;
begin
  iRet := fFuncECF_AcionaGaveta;
  TrataRetornoSweda( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
var
  iRet, i ,nTamTexto,nCar: Integer;
  sTexto,sTxtAux: String;
  oLista : TStringList;
begin
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

  oLista := TStringList.Create();
  oLista.Clear;
  sTexto := Texto;

  nCar := Pos(#10,sTexto);
  While nCar > 0 do
  Begin
      nCar     := Pos(#10,sTexto);
      sTxtAux  := sTxtAux + Copy(sTexto,1,nCar) ;
      sTexto:= Copy(sTexto,nCar+1,Length(sTexto));

      If Length(sTxtAux) >= 400 Then
      Begin
        oLista.Add(sTxtAux);
        sTxtAux := ''
      end;
   End;

   If Trim(sTexto) <> '' Then sTxtAux := ' ' + sTxtAux + sTexto + #10;
   If Trim(sTxtAux) <> '' Then oLista.Add(sTxtAux);

   GravaLog(' ECF_RelatorioGerencial -> Texto:' + Texto);
   For nCar:=0 to oLista.Count-1 do
      iRet   := fFuncECF_RelatorioGerencial(oLista.Strings[nCar]);
   GravaLog(' ECF_RelatorioGerencial <- iRet:' + IntToStr(iRet));
   TrataRetornoSweda(iRet);

  If iRet = 1 then
  begin
    GravaLog('ECF_FechaRelatorioGerencial ->');
    iRet:= fFuncECF_FechaRelatorioGerencial;
    GravaLog(' ECF_FechaRelatorioGerencial <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda(iRet);
    If iRet = 1
    then Result:='0'
    Else Result := '1';
  end
  else
  begin
    Result := '1';
  end;
end;

//------------------------------------------------------------------------------
function TImpSwedaST100.ImprimeCodBarrasITF( Cabecalho,Codigo,Rodape:String ;Vias:Integer):String;
var
  iRet, i, iRetBar : Integer;
  sCodigo  : String;
  nTamCod : Integer;
  nCar : Integer;
begin
  Result := '0';

  if Vias > 1 then
  Begin
    sCodigo := Codigo;
    i:=1;
    While i < Vias do
    Begin
        Codigo:= Codigo+ sCodigo;
        Inc(i);
    End;
  End;
    // Laço para imprimir toda a mensagem
  While ( Trim(Codigo)<>'' ) do
  Begin
    GravaLog(' ECF_ConfiguraCodigoBarrasMFD -> 162,1,2,0,0');
    iRetBar := fFuncECF_ConfiguraCodigoBarrasMFD(162,1,2,0,0);
    GravaLog(' ECF_ConfiguraCodigoBarrasMFD <- iRet:' + IntToStr(iRetBar));
    TrataRetornoSweda( iRetBar );

    GravaLog(' ECF_AbreRelatorioGerencialMFD -> Indice : 01');
    iRet := fFuncECF_AbreRelatorioGerencialMFD(pChar('01'));
    GravaLog(' ECF_AbreRelatorioGerencialMFD <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda( iRet );

    GravaLog(' ECF_RelatorioGerencial -> Cabecalho:' + Cabecalho);
    iRet   := fFuncECF_RelatorioGerencial(Cabecalho);
    GravaLog(' ECF_RelatorioGerencial <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda( iRet );

    nCar := 0;
    nTamCod := Length( Codigo );
    While (nTamCod >= nCar) and (Codigo <> '') do
    begin
      sCodigo := Copy( Codigo, 1, 600 );
      Codigo  := Copy( Codigo, 601, Length( Codigo ) );
      GravaLog(' ECF_CodigoBarrasITFMFD -> Codigo:' + sCodigo);
      iRet   := fFuncECF_CodigoBarrasITFMFD( pChar(sCodigo) );
      GravaLog(' ECF_CodigoBarrasITFMFD <- iRet:' + IntToStr(iRet));

      TrataRetornoSweda( iRet );
      nCar := nCar + Length( sCodigo );
    end;

    GravaLog(' ECF_RelatorioGerencial -> Rodape:' + Rodape);
    iRet   := fFuncECF_RelatorioGerencial(Rodape);
    GravaLog(' ECF_RelatorioGerencial <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda( iRet );

    if iRet <> 1 then
    Begin
      Result := '1';
      Exit;
    End;
  End;

  If iRet <> 1 then
  begin
    GravaLog('ECF_FechaRelatorioGerencial ->');
    iRet:= fFuncECF_FechaRelatorioGerencial;
    GravaLog('ECF_FechaRelatorioGerencial <- iRet:' + IntToStr(iRet));
    TrataRetornoSweda(iRet);
    If iRet = 1
    then Result := '0'
    Else Result := '1';
  end;

end;

//------------------------------------------------------------------------------
function TImpSwedaST100.PegaSerie:String;
begin
  Result := '0|' + NumSerie;
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.GravaCondPag( Condicao:String ):String;
Var
  iRet : Integer;
begin
  iRet := fFuncECF_ProgramaFormaPagamentoMFD( Condicao, '1' );
  TrataRetornoSweda(iRet);
  If iRet = 1 then
    Result := '0'
  Else
    Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.TotalizadorNaoFiscal( Numero,Descricao:String ) : String;
var
  iRet : Integer;
begin
  iRet := fFuncECF_NomeiaTotalizadorNaoSujeitoIcms(StrToInt(Numero),Descricao);
  TrataRetornoSweda(iRet);
  If iRet = 1
  then Result := '0'
  Else Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
Var
  iRet            : Integer;
  sPedido,sTefPedido, sCondicao, sPath, sTotalizadores  : String;
  fArquivo        : TIniFile;
  aAuxiliar       : TaString;
  lPedido,lTefPedido : Boolean;
  sTotPedido      : String;     // Contem o totalizador do registrador PEDIDO
  sTotTefPedido   : String;     // Contem o totalizador do registrador TEFPEDIDO
  iX              : Integer;
  sMsg,sLinha,sTxtAux  : String;
  oLista          : TStringList;
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

  // Pega os nomes dos totalizadores no arquivo de configuração (SWEDA.INI)
  sPath := ExtractFilePath(Application.ExeName);

  fArquivo    := TIniFile.Create(sPath+'\SWEDA.INI');
  GravaLog(' Arquivo Sweda.Ini gravado no caminho :' + sPath);

  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = ''
  then fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  GravaLog('Pedido [Sweda] -> sPedido : ' + sPedido);
  GravaLog('Pedido [Sweda] -> sTefPedido : ' + sTefPedido);
  GravaLog('Pedido [Sweda] -> sCondicao : ' + sCondicao);

  //*******************************************************************************
  // Checa indice do totalizador pelo nome informado
  //*******************************************************************************
  sTotalizadores  := Space(2200);
  GravaLog('ECF_VerificaRecebimentoNaoFiscal ->');
  iRet := fFuncECF_VerificaRecebimentoNaoFiscal( sTotalizadores );
  GravaLog('ECF_VerificaRecebimentoNaoFiscal <- iRet: ' + IntToStr(iRet));
  TrataRetornoSweda( iRet );

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

  GravaLog('Pedido [Sweda] -> Valor : ' + Valor);
  GravaLog('Pedido [Sweda] -> sCondicao : ' + sCondicao);

  //*******************************************************************************
  // Faz o recebimento não fiscal / Comprovante não fiscal não vinculado
  //*******************************************************************************
  If lPedido And lTefPedido then
  begin
    //*******************************************************************************
    // Abre o comprovante não fiscal não vinculado
    //*******************************************************************************

    GravaLog('Pedido [Sweda] -> sTotPedido : ' + sTotPedido);
    GravaLog('Pedido [Sweda] -> Valor : ' + Valor);
    GravaLog('Pedido [Sweda] -> sCondicao : ' + sCondicao);

    GravaLog('ECF_RecebimentoNaoFiscal -> Totalizador:' + sTotPedido + ', Valor:' + Valor + ', Condicao:' + sCondicao);
    iRet := fFuncECF_RecebimentoNaoFiscal ( pChar( sTotPedido ), pChar( Valor ), pChar( sCondicao ) );
    GravaLog('ECF_RecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));

    If Status_Impressora( False ) = 1 then
    begin

      //*******************************************************************************
      // Abre o comprovante não fiscal vinculado
      //*******************************************************************************
      GravaLog('ECF_AbreComprovanteNaoFiscalVinculado -> Condicao:' + sCondicao);
      iRet := fFuncECF_AbreComprovanteNaoFiscalVinculado( sCondicao, '', '' );
      GravaLog('ECF_AbreComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));
      If Status_Impressora( False ) = 1 then
      begin
          oLista := TStringList.Create();
          oLista.Clear;
          sLinha := Texto;

          iX := Pos(#10,sLinha);
          While iX > 0 do
          Begin
            iX     := Pos(#10,sLinha);
            sTxtAux := sTxtAux + Copy(sLinha,1,iX) ;
            sLinha:= Copy(sLinha,iX+1,Length(sLinha));

            If Length(sTxtAux) >= 450 Then
            Begin
              oLista.Add(sTxtAux);
              sTxtAux := ''
            end;
          End;

          If Trim(sLinha) <> '' Then sTxtAux := ' ' + sTxtAux + sLinha + #10;
          If Trim(sTxtAux) <> '' Then oLista.Add(sTxtAux);

          GravaLog('ECF_UsaComprovanteNaoFiscalVinculado -> Texto:' + Texto);
          For iX:= 0 to oLista.Count-1 do
             iRet   := fFuncECF_UsaComprovanteNaoFiscalVinculado(oLista.Strings[iX]);
          GravaLog('ECF_UsaComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));

          If Status_Impressora( False ) = 1 then
          begin
            GravaLog('ECF_FechaComprovanteNaoFiscalVinculado ->');
            iRet := fFuncECF_FechaComprovanteNaoFiscalVinculado;
            GravaLog('ECF_FechaComprovanteNaoFiscalVinculado <- iRet:' + IntToStr(iRet));
            If Status_Impressora( False ) = 1 then
            begin
              //*******************************************************************************
              // Checar se serah impresso o comprovante TEF. Caso afirmativo abre um novo
              // comprovante nao fiscal nao vinculado.
              //*******************************************************************************
              If Tef = 'S' then
              begin
                GravaLog('ECF_RecebimentoNaoFiscal ->');
                iRet := fFuncECF_RecebimentoNaoFiscal( pChar( sTotTefPedido ), pChar( Valor ), pChar( sCondicao ) );
                GravaLog('ECF_RecebimentoNaoFiscal <- iRet:' + IntToStr(iRet));
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
    If Result = '1'
    then TrataRetornoSweda( iRet );

  end
  Else
  begin
    //*******************************************************************************
    // Mostrar mensagem de erro caso os totalizadores não tenham sido encontrados
    //*******************************************************************************
    sMsg := '';

    If not lPedido
    then sMsg := sMsg + ' ' + sPedido;

    If not lTefPedido
    then sMsg := sMsg + ' ' + sTefPedido;

    If Trim(sMsg) <> ''
    then LjMsgDlg('Os totalizadores ' + sMsg + ' não existem no ECF. Checar o arquivo SWEDA.INI no caminho :"' + sPath + '"' );

    Result := '1';
  end;

  //*******************************************************************************
  // Libera as variaveis
  //*******************************************************************************
  fArquivo.Free;
end;

//------------------------------------------------------------------------------
function TImpSwedaST100.RecebNFis( Totalizador, Valor, Forma:String ): String;
var iRet : Integer;
begin
  GravaLog('ECF_RecebimentoNaoFiscal -> ' + Totalizador +',' + Valor + ',' + Forma );
  iRet := fFuncECF_RecebimentoNaoFiscal( pChar( Totalizador ), pChar( Valor ), pChar( Forma ) );
  TrataRetornoSweda(iRet);
  GravaLog(' ECF_RecebimentoNaoFiscal <- iRet: ' + IntToStr(iRet));
  if iRet = 1
  then Result := '0'
  else Result := '1';
end;
//------------------------------------------------------------------------------
function TImpSwedaST100.HorarioVerao( Tipo:String ):String;
var iRet : Integer;
begin
  GravaLog(' ECF_ProgramaHorarioVerao -> ');
  iRet := fFuncECF_ProgramaHorarioVerao();
  GravaLog(' ECF_ProgramaHorarioVerao <- iRet:' + IntToStr(iRet));
  if iRet = 1
  then Result := '0'
  else Result := '1';
end;

//------------------------------------------------------------------------------
Procedure TImpSwedaST100.AlimentaProperties;
    Procedure CargaIndiceAliq();
    var i, iRet : Integer;
        sIndiceISS : String;
        sICMS : String;
    begin
        Try
          sICMS := ICMS;
          sIndiceISS := Space(48);
          iRet := fFuncECF_VerificaIndiceAliquotasIss( sIndiceISS );
          TrataRetornoSweda(iRet);
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
        End;
    End;
var
  iRet : Integer;
  sRet, sICMS, sISS, sAliq, sNumCx, sFirmW, sPathArq,sPathAux: String;
  fArquivo: TIniFile;
  pPath: PChar;
begin
  /// Inicalização de variaveis
  ICMS  := '';
  ISS   := '';
  PDV   := '';
  Eprom := '';
  Cnpj          := Space(18);
  Ie            := Space(15);
  NumLoja       := Space(4);
  NumSerie      := Space(20);
  ContadorCro   := Space(4);
  ContadorCrz   := Space(4);
  GTInicial     := '';
  VendaBrutaDia := Space(18);
  GTFinal       := Space(18);
  ReducaoEmitida:= False;
  lError        := False;

  // Retorno de Aliquotas ( ISS )
  sRet := Space( 79 );
  GravaLog('ECF_VerificaAliquotasIss -> ');
  iRet := fFuncECF_VerificaAliquotasIss( sRet );
  TrataRetornoSweda( iRet );
  GravaLog('ECF_VerificaAliquotasIss <- iRet [ ' + IntToStr(iRet) +
           '] - Aliquotas [' + sRet + ']');

  If iRet = 1
  then sISS := Trim( StrTran( sRet, ',', '|' ) );

  While Length(sISS) > 0 do
  begin
    sAliq := Copy(sISS,1,2)+','+Copy(sISS,3,2);
    ISS   := ISS + FormataTexto(sAliq,5,2,1) +'|';
    sISS  := Copy(sISS,6,Length(sISS));
  end;

  // Retorno de Aliquotas ( ICMS )
  sRet := Space(79);
  GravaLog('ECF_RetornoAliquotas -> ');
  iRet := fFuncECF_RetornoAliquotas( sRet );
  TrataRetornoSweda( iRet );
  GravaLog('ECF_RetornoAliquotas <- iRet [ ' + IntToStr(iRet) +
           '] - Aliquotas [' + sRet + ']');

  If iRet = 1
  then sICMS := Trim( StrTran( sRet, ',', '|' ) );

  While Length(sICMS) > 0 do
  begin
    sAliq := Copy(sICMS,1,2)+','+Copy(sICMS,3,2);
    ICMS  := ICMS + FormataTexto(sAliq,5,2,1) +'|';
    sICMS := Copy(sICMS,6,Length(sICMS));
  end;

  CargaIndiceAliq();

  // Retorno do Numero do Caixa (PDV)
  sNumCx := Space( 4 );
  GravaLog('ECF_NumeroCaixa -> ');
  iRet := fFuncECF_NumeroCaixa( sNumCx );
  TrataRetornoSweda( iRet );
  GravaLog('ECF_NumeroCaixa <- iRet [ ' + IntToStr(iRet) + '] - Retorno [' + sNumCx + ']');
  If iRet = 1 then
  begin
    If Pos(#0,sNumCx) > 0
    then PDV := Copy(sNumCx,1,Pos(#0,sNumCx)-1)
    Else PDV := Copy(sNumCx,1,4);

    GravaLog(' Numero do PDV tratado [ ' + PDV + ']');
  end;

  // Retorno da Versão do Firmware (Eprom)
  sFirmW := Space( 6 );
  GravaLog('ECF_VersaoFirmwareMFD -> ');
  iRet := fFuncECF_VersaoFirmwareMFD( sFirmW );
  TrataRetornoSweda( iRet );
  GravaLog('ECF_VersaoFirmwareMFD <- iRet [ ' + IntToStr(iRet) + '] - Retorno [' + sFirmW + ']');
  If iRet = 1
  then Eprom := sFirmW
  else exit;

  // Retorna o CNPJ
  // Retorna a IE
  GravaLog('ECF_CGC_IE -> ');
  iRet := fFuncECF_CGC_IE( Cnpj, Ie );
  TrataRetornoSweda( iRet );
  GravaLog('ECF_CGC_IE <- iRet [ ' + IntToStr(iRet) + ']');
  If iRet <> 1
  then Exit;

  // Retorna o Numero da loja cadastrado no ECF
  GravaLog('ECF_NumeroLoja -> ');
  iRet := fFuncECF_NumeroLoja( NumLoja );
  NumLoja := Trim( NumLoja );
  TrataRetornoSweda( iRet );
  GravaLog('ECF_NumeroLoja <- iRet [ ' + IntToStr(iRet) + '] - Retorno [' + NumLoja + ']');
  If iRet <> 1
  then Exit;

  // Retorna o Numero da Serie
  GravaLog('ECF_NumeroSerieMFD -> ');
  iRet := fFuncECF_NumeroSerieMFD( NumSerie );
  NumSerie := Trim( NumSerie );
  TrataRetornoSweda( iRet );
  GravaLog('ECF_NumeroSerieMFD <- iRet [ ' + IntToStr(iRet) + '] - Retorno [' + NumSerie + ']');

  If iRet <> 1
  then Exit;

  // Retorna o Tipo do ECF
  TipoEcf := 'ECF-IF';

  // Retorna Marca do ECF
  MarcaEcf := sMarca;

  // Retorna Modelo do ECF
  GravaLog('ECF_VerificaModeloEcf -> ');
  iRet := fFuncECF_VerificaModeloEcf;
  TrataRetornoSweda( iRet );
  GravaLog('ECF_VerificaModeloEcf <- iRet [ ' + IntToStr(iRet) + ']');
  case iRet of
    1 : ModeloEcf := 'ST100' ;
    2 : ModeloEcf := 'ST1000' ;
    3 : ModeloEcf := 'ST200' ;
    4 : ModeloEcf := 'ST120' ;
    5 : ModeloEcf := 'ST2000' ;
    6 : ModeloEcf := 'ST2500' ;
   50 : ModeloEcf := '9000IE' ;
   51 : ModeloEcf := '9000IIE' ;
   52 : ModeloEcf := '9000IIIE' ;
   53 : ModeloEcf := '9000II' ;
   54 : ModeloEcf := '9000I' ;
   55 : ModeloEcf := '7000IE' ;
   56 : ModeloEcf := '7000II' ;
   57 : ModeloEcf := '7000I' ;
  end;

  // Retorna Contador de Reinicio de Operação
  GravaLog('ECF_RetornaCRO -> ');
  IRet := fFuncECF_RetornaCRO(ContadorCro);
  TrataRetornoSweda( iRet );
  GravaLog('ECF_RetornaCRO <- iRet [ ' + IntToStr(iRet) + ']');
  If iRet <> 1
  then exit;

  // Retorna Contador de ReduçãoZ
  GravaLog('ECF_RetornaCRZ -> ');
  IRet := fFuncECF_RetornaCRZ(ContadorCrz);
  TrataRetornoSweda( iRet );
  GravaLog('ECF_RetornaCRZ <- iRet [ ' + IntToStr(iRet) + ']');
  If iRet <> 1
  then exit;

  // Retorna o valor Total Bruto Vendido até o momento do referido movimento
  GravaLog('ECF_VendaBruta -> ');
  IRet := fFuncECF_VendaBruta(VendaBrutaDia);
  TrataRetornoSweda( iRet );
  GravaLog('ECF_VendaBruta <- iRet [ ' + IntToStr(iRet) + ']');
  If iRet <> 1
  then exit;

  // Retorna o valor do Grande Total da impressora
  GravaLog('ECF_GrandeTotal -> ');
  IRet := fFuncECF_GrandeTotal(GTFinal);
  TrataRetornoSweda( iRet );
  GravaLog('ECF_GrandeTotal <- iRet [ ' + IntToStr(iRet) + ']');
  If iRet <> 1
  then exit;

  // Calcula o Grande Total Inicial
  GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );

  //Path arquivos gerados pelo ECF
  //Por padrão, a impressora utiliza as configurações do arquivo CONVERSOR.INI, seguindo a hierarquia abaixo:
  //1º Pasta do Aplicativo, 2º Pasta System do SO, se não localizar o arquivo, gera as informações na pasta do aplicativo ***Emite Aviso***.
  sPathArq := ExtractFilePath(Application.ExeName) + 'CONVERSOR.INI' ;
  if not FileExists(sPathArq) then
  begin
    pPath := Pchar(Replicate('0',100));
    GetSystemDirectory(pPath,100);
    sPathArq := StrPas(pPath) + '\CONVERSOR.INI';

    if not FileExists(sPathArq) then
    begin
      ShowMessage('O arquivo CONVERSOR.INI não foi encontrado.');
      exit;
    end;
  end;

  fArquivo := TIniFile.Create(sPathArq);
  Try
    sPathEcfRegistry := fArquivo.ReadString('Sistema', 'Path', ExtractFilePath(Application.ExeName));
  Finally
    fArquivo := NIL;
  End;  
end;

//------------------------------------------------------------------------------
function TImpSwedaST100.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Var
  sArquivo : String;    // Arquivo de download da MFD
  sUsuario : String;    // Usuario do movimento
  sDestino : String;    // Arquivo de destino depois de convertido
  iRet     : Integer;   // Retorno da dll
  sPath    : String;    // Path de onde será gravado o DOWNLOAD.MFD e DOWNLOAD.TXT
  sRetorno : String;    // Retorno da Função
  sStringList: TStringList; // utilizado para remover a assinatura EAD do arquivo
Begin
  Result   := '1';
  sRetorno := '1';
  sArquivo := sArqDownMFD;
  sDestino := ArqDownTXT;
  sUsuario := '1';
  sPath    := sPathEcfRegistry;

  //Quando por COO, preenche com zeros a esquerda para evitar erro
  If sTipo = '2' then
  begin
    sInicio := FormataTexto(sInicio,6,0,2);
    sFinal  := FormataTexto(sFinal,6,0,2);
  end;

  GravaLog('ECF_DownloadMFD -> ' + sArquivo + ',' + sTipo + ',' + sInicio + ',' + sFinal + ',' + sUsuario);
  iRet := fFuncECF_DownloadMFD( PChar(sArquivo), PChar(sTipo), PChar(sInicio), PChar(sFinal), PChar(sUsuario) );
  TrataRetornoSweda(iRet);
  GravaLog(' ECF_DownloadMFD <- iRet: ' + IntToStr(iRet));

  If iRet = 1 Then
  Begin
    sRetorno := CopRenArquivo( sPath, sArquivo, PathArquivo, sArquivo );

    If sRetorno = '0' then
    begin
      sRetorno := '1';
      GravaLog('ECF_FormatoDadosMFD -> ' + sArquivo + ',' + sDestino + ',0,' + sTipo + ',' + sInicio + ',' + sFinal + ',' + sUsuario);
      iRet := fFuncECF_FormatoDadosMFD( sArquivo, sDestino, '0', sTipo, sInicio, sFinal, sUsuario );
      TrataRetornoSweda(iRet);
      GravaLog(' ECF_FormatoDadosMFD <- iRet: ' + IntToStr(iRet));

      If iRet = 1 Then
      begin
        // Grava arquivo no local indicado, removendo a assinatura
        sStringList := TStringList.Create ;
        sStringList.LoadFromFile(sPath + sDestino);

        If Copy(sStringList.Strings[sStringList.Count-1],1,3) = 'EAD' then
          sStringList.Delete(sStringList.Count-1);

        sStringList.SaveToFile(PathArquivo + sDestino);
        sStringList.Free ;
        sStringList := Nil;
        DeleteFile(sPath + sDestino);
        sRetorno := '0';
      end
    end
  end;

  Result := sRetorno;
end;


//------------------------------------------------------------------------------
function TImpSwedaST100.DownMF(sTipo, sInicio, sFinal : String):String;
Var
  sArquivo : String;    // Arquivo de download da MFD
  iRet     : Integer;   // Retorno da dll
  sPath    : String;    // Path de onde será gravado o DOWNLOAD.MFD e DOWNLOAD.TXT
  sRetorno : String;    // Retorno da Função
  sStringList: TStringList; // utilizado para remover a assinatura EAD do arquivo
Begin
  Result   := '1';
  sRetorno := '1';
  sArquivo := 'MFISCAL.bin';
  sPath    := sPathEcfRegistry;

  iRet := fFuncECF_DownloadMF(PChar(sArquivo));
  TrataRetornoSweda(iRet);

  If iRet = 1
  Then sRetorno := CopRenArquivo( sPath, sArquivo, PathArquivo, sArquivo );

  Result := sRetorno;
end;

 //------------------------------------------------------------------------------
Function TImpSwedaST100.RedZDado(MapaRes:String):String;
Var
  aRetTemp: TaString;
  i,iRet: Integer;
  sAux: String;
begin

sAux := Space(6);
GravaLog(' ECF_DataMovimentoUltimaReducaoMFD -> ');
iRet := fFuncECF_DataMovimentoUltimaReducaoMFD( sAux );
GravaLog(' ECF_DataMovimentoUltimaReducaoMFD <- iRet:' + IntToStr(iRet) + '  - Data: ' + sAux );

sAux := Copy(sAux,1,2)+'/'+Copy(sAux,3,2)+'/'+Copy(sAux,5,2);   //mesmo padrão da redução Z do fabricante

aRetTemp := GetTempRedZ(sAux);

Result := '0|';
For i:= 0 to High(aRetTemp) do
  Result := Result + aRetTemp[i]+'|';

GravaLog('Sweda Mapa Resumo(Recuperado) <- Retorno : '+ Result);

end;

//------------------------------------------------------------------------------
function TImpSwedaST1000.Autenticacao( Vezes:Integer; Valor,Texto:String ):String;
var
  iRet : Integer;
  iStatus : Integer;
  iVezes : Integer;

begin
  iVezes := 1;
  While iVezes < 5 do //Esse While verifica se o documento esta inserido, se estiver manda o comando
  Begin
    fFuncECF_VerificaStatusCheque( iStatus );
    If iStatus = 3 then
    Begin
      iRet := fFuncECF_Autenticacao;
      iVezes := 6; // Se mandar para a impressora sai do looping
    End
    Else
    Begin
      ShowMessage( 'Insira o documento para autenticação!' );
      iVezes := iVezes + 1;
      Sleep( 1500 );
    End;
     TrataRetornoSweda( iRet );
  End;

  If iRet = 1 then //Se o retorno de impressao do cheque foi ok, checa o status da impressão do cheque
  begin
    While iStatus <> 1 do // iStatus = 1 -> Impressão ok; 2 -> Cheque em impressão; 3-> Cheque posicionado; 4 -> Aguardando posicionamento
    Begin
      fFuncECF_VerificaStatusCheque( iStatus );
      sleep( 1000 );
    End;
    TrataRetornoSweda(iRet);
  End;

  If iRet = 1
  then Result := '0'
  Else Result := '1';

end;
//------------------------------------------------------------------------------
//**** Impressora de Cheque****
function TImpCheqST1000.Abrir( aPorta:String ): Boolean;
begin
  If Not bOpened Then
      Result := (Copy(OpenSweda(aPorta),1,1) = '0')
  Else
      Result := True;
end;
//------------------------------------------------------------------------------
function TImpCheqST1000.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  iRet : Integer;
  sData: String;
  iStatus : Integer;
  iVezes : Integer;
begin
  iVezes := 1;
  If length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;
  fFuncECF_ProgramaMoedaPlural( 'Reais' );
  iRet := 0;

  While iVezes < 5 do //Esse While verifica se o cheque esta inserido, se estiver manda o comando
  Begin
    fFuncECF_VerificaStatusCheque( iStatus );
    If iStatus = 3 then
    Begin
      iRet := fFuncECF_ImprimeChequeMFD( Banco, Valor, Favorec, Cidade, Copy(Data,7,2) + Copy(Data,5,2) + Copy(Data,1,4), Mensagem, '0', '0' );
      iVezes := 6; // Se mandar para a impressora sai do looping
    End
    Else
    Begin
      ShowMessage( 'Insira o cheque!' );
      iVezes := iVezes + 1;
      Sleep( 1500 );
    End;
  End;

  {
  If iRet = 1 then //Se o retorno de impressao do cheque foi ok, checa o status da impressão do cheque
  begin
    While iStatus <> 1 do // iStatus = 1 -> Impressão ok; 2 -> Cheque em impressão; 3-> Cheque posicionado; 4 -> Aguardando posicionamento
    Begin
      fFuncECF_VerificaStatusCheque( iStatus );
      sleep( 1000 );
    End;
    TrataRetornoSweda(iRet);
  End;}

  If iRet = 1 then
  Begin
      Sleep( 5000 );
      result := True;
  End
  Else
      result := False;

end;
//------------------------------------------------------------------------------
function TImpCheqST1000.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );
  Result := False;
end;
//------------------------------------------------------------------------------
function TImpCheqST1000.Fechar( aPorta:String ): Boolean;
begin
  Result := (Copy(CloseSweda,1,1) = '0');
end;
//------------------------------------------------------------------------------
function TImpCheqST1000.StatusCh( Tipo:Integer ):String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
end;
//-------------------Comandos para o CMC7---------------------------------------
function TCmc7_ST1000.Abrir( aPorta, sMensagem :String ) : String;
Begin
  If Not bOpened Then
    Result := Copy( OpenSweda( aPorta ), 1, 1 )
  Else
    Result := '0';
End;
//------------------------------------------------------------------------------
function TCmc7_ST1000.LeDocumento : String;
Var
iRet : integer;
Codigo : String;
Begin
  Codigo := Space(36);
  iRet := fFuncECF_LeituraChequeMFD( Codigo );
  TrataRetornoSweda( iRet );
  If iRet = 1 then
    Result := '0|' + Codigo
  Else
    Result := '1';
End;

//------------------------------------------------------------------------------
function TCmc7_ST1000.Fechar:String;
Begin
Result := CloseSweda;
End;

//------------------------------------------------------------------------------
function TImpSwedaST100.Retorna_Informacoes(iRetorno: Integer): String;
Var
  sRetorno, sAuxDtU, sAuxDtS, sAuxMfA : String;
  iRet     : Integer;
begin

  sRetorno := '';
  sAuxDtU := Space(20);
  sAuxDtS := Space(20);
  sAuxMfA := Space(5);

  GravaLog('-> ECF_DataHoraGravacaoUsuarioSWBasicoMFAdicional( sAuxDtU, sAuxDtS, sAuxMfA )');
  iRet := fFuncECF_DataHoraGravacaoUsuarioSWBasicoMFAdicional( sAuxDtU, sAuxDtS, sAuxMfA );
  TrataRetornoSweda( iRet );
  GravaLog(' ECF_DataHoraGravacaoUsuarioSWBasicoMFAdicional <- iRet: ' + IntToStr(iRet));

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

//------------------------------------------------------------------------------
function TImpSwedaST100.GeraRegTipoE(sTipo, sInicio, sFinal, sRazao, sEnd , sBinario : String): String;
 
Var
  iRet: integer;
  sArquivo, sArquivoBin, sNameFile: String;
begin
  Result := '1';

  //Arquivo binário necessário para Reproduzir a Memoria Fiscal
  sArquivo := 'MF.bin';
  GravaLog(' ECF_DownloadMF -> ' + sPathEcfRegistry + ',' + sArquivo );
  iRet := fFuncECF_DownloadMF(sPathEcfRegistry + sArquivo);
  GravaLog(' ECF_DownloadMF <- iRet: ' + IntToStr(iRet));
  TrataRetornoSweda(iRet);

  if  (sBinario = '1') And (iRet = 1) then
  begin
    sArquivoBin := 'download.bin';
    If not CopyFile( PChar(  sPathEcfRegistry + sArquivo ), PChar( PathArquivo+DEFAULT_PATHARQMFD+sArquivoBin ), False ) then
    begin
       ShowMessage( 'Erro ao copiar o arquivo ' +  sPathEcfRegistry + sArquivo + ' para ' + PathArquivo+DEFAULT_PATHARQMFD+sArquivoBin );
       GravaLog('Erro ao copiar o arquivo ' +  sPathEcfRegistry + sArquivo + ' para ' + PathArquivo+DEFAULT_PATHARQMFD+sArquivoBin);
    end
    else
    Begin
      GravaLog(' GeraRegTipoE <- formato binario( ' + sPathEcfRegistry + sArquivo +','+ PathArquivo+
                      DEFAULT_PATHARQMFD+sArquivoBin +','+ sInicio +','+ sFinal +','+ sRazao +','+ sEnd +',' +','+ sBinario + ')' );
      Result := '0';
    end;
  end
  else
  begin
    if iRet = 1 then
    begin
      //quando por COO, deverá ter 7 digitos
      If sTipo = '2' then
      begin
        sInicio := FormataTexto(sInicio,7,0,2);
        sFinal  := FormataTexto(sFinal,7,0,2);
      end;

      //Padrão PAF-ECF
      sNameFile := UpperCase('MFD' + NumSerie + '_' + FormatDateTime('ddMMyyyy', Date) + '_' + FormatDateTime('hhmmss', Time)+'.txt');

      GravaLog('ECF_ReproduzirMemoriaFiscalMFD -> ' + '3' +','+sInicio+','+sFinal+','+
                                PathArquivo+DEFAULT_PATHARQMFD+sNameFile+','+sPathEcfRegistry + sArquivo);
      iRet := fFuncECF_ReproduzirMemoriaFiscalMFD('3',sInicio,sFinal,PathArquivo+DEFAULT_PATHARQMFD+sNameFile,sPathEcfRegistry + sArquivo);
      GravaLog('ECF_ReproduzirMemoriaFiscalMFD <- iRet:' + IntToStr(iRet));
      TrataRetornoSweda(iRet);

      if not FileExists(PathArquivo+DEFAULT_PATHARQMFD+sNameFile) then
      begin
        ShowMessage(' Arquivo  ' + sNameFile + ' não foi gerado no caminho [' + PathArquivo+DEFAULT_PATHARQMFD + ']');
        GravaLog(' Arquivo  ' + sNameFile + ' não foi gerado no caminho [' + PathArquivo+DEFAULT_PATHARQMFD + ']'); 
      end;

      if iRet = 1
      then Result := '0';
    end;
  end;
end;

//------------------------------------------------------------------------------
function TImpSwedaST100.GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: integer; cChavePublica: string; cChavePrivada: string; iUnicoArquivo: integer ): String;
var
  iRet : Integer;
  sDadoi,sDadof,sTipoAux,sArquivo,sArqATOCotepe: String;
  bPorData: Boolean;
begin
  Result := '1';        
  sTipoAux := 'C';
  bPorData := (Trim(cTipoDownload) = 'D');

  //Arquivo binário necessário para Reproduzir a Memoria Fiscal - este comando não funciona para emulador da Sweda, é retornado um erro
  sArquivo := 'MF.bin';
  iRet := fFuncECF_DownloadMF(pChar(sPathEcfRegistry + sArquivo));
  TrataRetornoSweda(iRet);

  // Se o relatório for por Data
  If bPorData then
  begin
    sDadoi := FormatDateTime('ddMMyyyy', StrToDateTime( cDadoInicial ) );
    sDadof := FormatDateTime('ddMMyyyy', StrToDateTime( cDadoFinal ));
    sArqATOCotepe := NumSerie + '_' + FormatDateTime('ddMMyy', StrToDateTime( cDadoInicial ) ) + '_' + FormatDateTime('ddMMyy', StrToDateTime( cDadoFinal ) ) + '.TXT';
  end
  else
  begin
    sDadoi := cDadoInicial;
    sDadof := cDadoFinal;
    sArqATOCotepe := NumSerie + '_' + cDadoInicial + '_' + cDadoFinal+ '.TXT';
  end;

  If iRet = 1 then
  begin
   //Para impressora Sweda é possível gerar arquivo com o intervalo de COO além do intervalo de data
   GravaLog(' ECF_ArquivoEletronicoCOTEPE -> ' + sPathEcfRegistry + sArquivo + ',' +
                ' ,' + sPathEcfRegistry + sArqATOCotepe + ',' + sDadoi + ',' + sDadof);
   iRet := fFuncECF_ArquivoEletronicoCOTEPE(pChar(sPathEcfRegistry + sArquivo),pChar(''),pChar(sPathEcfRegistry + sArqATOCotepe),pChar(sDadoi),pChar(sDadof));
   GravaLog(' ECF_ArquivoEletronicoCOTEPE <- iRet: ' + IntToStr(iRet));
   //Quando funciona retorna 0 e por isso nao deve usar a função TratarRetornoSweda
   case iRet of
       2: ShowMessage(' Data inválida! ');
       3: ShowMessage(' Faixa inválida!');
       7: ShowMessage(' Falha na abertura do arquivo de origem! ');
       10:ShowMessage(' Falha na abertura do arquivo de saída! ');
    else
       Result := '0'
    end;
  end;

end;

//------------------------------------------------------------------------------
function TImpSwedaST100.LeTotNFisc:String;
var
  iRet, i, iPos, iPosF : Integer;
  sRet : String;
  sTotaliz : String;
begin
  sRet := Space( 599 );
  iRet := fECF_VerificaTotalizadoresNaoFiscaisMFD( sRet );
  TrataRetornoSweda( iRet );
  If iRet = 1 then
  begin
    sTotaliz := '';
    iPosF := Pos(',', sRet);
    If iPosF = 0 then iPosF := Length(sRet);
    For i:=1 to 30 do
      begin
        If Trim(Copy(sRet,1,iPosF-1))<>'' then
         begin
            If Copy( sRet, 1, 1) = '-' then
                iPos := 2
            Else
                iPos := 1;
            sTotaliz := sTotaliz + FormataTexto( IntToStr(i), 2, 0, 4) + ',' + Trim(copy( sRet, iPos, iPosF - iPos )) + '|';
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

//-------------------------------------------------------------------------------------------------------
function TImpSwedaST100.RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer; ImgQrCode: String) : String;
Var
  iRet,i,nPos: Integer;
  cTextoImpAux    : String;
  sRelGerenciais  : String;
  sMsg,sIndTot    : String;
  bImprime        : Boolean;
  sLista          : TStringList;
begin
  //cIndiceTot : Traz o texto do nome do totalizador cadastrado no ECF que deve ser o mesmo do arquivo SIGALOJA.INI
  //sIndTot    : É a posição do totalizador no ECF.

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
          GravaLog(' -> AbreRelatorioGerencialMFD' );
         iRet := fFuncECF_AbreRelatorioGerencialMFD( pChar(sIndTot) );
         GravaLog(' <- AbreRelatorioGerencialMFD: ' + IntToStr(iRet));

         TrataRetornoSweda( iRet );
         If (iRet = 0 ) then
         Begin
           Result := '1';
           Exit;
         End;

         GravaLog(' -> UsaRelatorioGerencialMFD ');

         For nPos := 0 to sLista.Count-1 do
            iRet := fFuncECF_UsaRelatorioGerencialMFD( pChar(sLista.Strings[nPos]));

         GravaLog(' <- UsaRelatorioGerencialMFD: ' + IntToStr(iRet));

         TrataRetornoSweda( iRet );
         If (iRet = 0) then
         Begin
           Result := '1';
           Exit;
         End;

        GravaLog(' -> FechaRelatorioGerencial' );
        iRet:= fFuncECF_FechaRelatorioGerencial;
        GravaLog(' <- FechaRelatorioGerencial : ' + IntToStr(iRet));

        TrataRetornoSweda(iRet);
        If iRet = 1 then
          Result := '0'
        Else
          Result := '1';
    End;

    //*******************************************************************************
    // Mostrar mensagem de erro se necessário
    //*******************************************************************************
    If Result = '1'
    then TrataRetornoSweda( iRet );

  end
  Else
  begin
    //*******************************************************************************
    // Mostrar mensagem de erro caso os totalizadores não tenham sido encontrados
    //*******************************************************************************
    LjMsgDlg('O Relatorio Gerencial ' + Trim(cIndTotalizador) + ' não existe no ECF.' );
    Result := '1';
  end;

end;

//------------------------------------------------------------------------------
function TImpSwedaST100.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
var
   iRet : Integer;
begin
  //as informações saem no inicio do cupom, mantido por compatibilidade
 If (Trim(cCPFCNPJ) <> '') or (Trim(cCliente) <> '') then
 begin
   GravaLog(' ECF_IdentificaConsumidor -> ' + cCPFCNPJ + ',' + cCliente + ',' + cEndereco );
   iRet := fFuncECF_IdentificaConsumidor(pchar(cCliente), pchar(cEndereco), pchar(cCPFCNPJ));
   GravaLog(' ECF_IdentificaConsumidor <- iRet : ' + IntToStr(iRet));
   TrataRetornoSweda( iRet );

   If iRet = 1
   then Result := '0|'
   else Result := '1|';
 end
 else
   Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpSwedaST100.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
var
  iRet : Integer;
begin

GravaLog(' -> ECF_EstornoNaoFiscalVinculadoMFD - Dados :(' + CPFCNPJ + ' ' + Cliente + ' ' + Endereco + ')');
iRet := fFuncECF_EstornoNaoFiscalVinculadoMFD(pChar(CPFCNPJ),pChar(Cliente),pChar(Endereco));
GravaLog(' <- ECF_EstornoNaoFiscalVinculadoMFD - Retorno :' + IntToStr(iRet));

TrataRetornoSweda( iRet );
If (iRet = 0) then
Begin
  Result := '1';
  Exit;
End;

GravaLog(' -> ECF_UsaComprovanteNaoFiscalVinculado - Dados :(' + Mensagem + ')');
iRet := fFuncECF_UsaComprovanteNaoFiscalVinculado(pChar(Mensagem));
GravaLog(' <- ECF_UsaComprovanteNaoFiscalVinculado - Retorno :' + IntToStr(iRet));

TrataRetornoSweda( iRet );
If (iRet = 0) then
Begin
  Result := '1';
  Exit;
End;

GravaLog(' -> ECF_FechaComprovanteNaoFiscalVinculado ');
iRet := fFuncECF_FechaComprovanteNaoFiscalVinculado();
GravaLog(' <- ECF_FechaComprovanteNaoFiscalVinculado - Retorno :' + IntToStr(iRet));
TrataRetornoSweda( iRet );

If iRet = 1
then Result := '0'
Else Result := '1';

end;

//------------------------------------------------------------------------------
function TImpSwedaST100.ImpTxtFis(Texto : String) : String;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
end;

//****************************************************************************//
Function TrataTags( Mensagem : String ) : String;
var
  cMsg : String;
begin
cMsg := Mensagem;

While Pos('<B>', cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<B>',sTagNegritoIni,[]);
   cMsg := StringReplace(cMsg,'</B>',sTagFim,[]);
end;

While Pos('<E>',cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<E>',sTagExpandidoHIni,[]);
   cMsg := StringReplace(cMsg,'</E>',sTagFim,[]);
end;

While Pos('<I>',cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<I>',sTagItalicoIni,[]);
   cMsg := StringReplace(cMsg,'</I>',sTagFim,[]);
end;

While Pos('<C>',cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<C>',sTagCondensadoIni,[]);
   cMsg := StringReplace(cMsg,'</C>',sTagFim,[]);
end;

cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//------------------------------------------------------------------------------
Function VldFormaPgto(var Condicao : String) : Boolean;
var
  sRetFormas,sForma,sMensagem: String;
  iRet,iPos : Integer;
  bAchou : Boolean;
begin
bAchou := False;
sRetFormas := Space(3016);
GravaLog('ECF_VerificaFormasPagamento ->');
iRet := fFuncECF_VerificaFormasPagamento(sRetFormas);
GravaLog('ECF_VerificaFormasPagamento <- ' + IntToStr(iRet));

While (sRetFormas <> '') and ( bAchou = False ) do
begin
  iPos := Pos(',',sRetFormas);
  If iPos = 0
  then iPos := Length(sRetFormas);

  sForma := Copy(sRetFormas,1,iPos-1);
  sForma := Copy(sForma,1,16);

  If UpperCase(Trim(sForma)) = UpperCase(Trim(Condicao)) then
  begin
    bAchou := True;
  end;

  sRetFormas := Copy(sRetFormas,iPos+1,Length(sRetFormas));
end;

If bAchou
then sMensagem := 'Forma de pagamento cadastrada'
else
begin
  sMensagem := 'Forma de pagamento : ' + Condicao + ', não cadastrada no ECF' + CHR(13) +
                'Verifique o SX5 ou arquivo de configuração (SIGALOJA.INI) e valide a forma ' + CHR(13) +
                ' de pagamento que está configurada';
end;

GravaLog(sMensagem);
Result := bAchou;
end;

//------------------------------------------------------------------------------
function TImpSwedaST100.Autenticacao(Vezes: Integer; Valor,
  Texto: String): String;
begin
GravaLog('Função não disponível para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpSwedaSTCV0909.PegaCupom(Cancelamento:String):String;
var
  iRet : Integer;
  sNumCupom : String;
  iCont: Integer;
begin
  // Máximo de 20 tentativas para resgatar o numero do cupom fiscal
  iCont := 20;
  iRet  := 0;
  While (iRet = 0) And (iCont > 0) Do
  Begin
     Sleep(500);
     sNumCupom := Space( 9 );
     iRet  := fFuncECF_NumeroCupom( sNumCupom );
     iCont := iCont - 1
  End;

  TrataRetornoSweda( iRet );

  If iRet = 1 then
    Result := '0|' + sNumCupom
  Else
    Result := '1';
end;


function TImpSwedaST100.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
RegistraImpressora('SWEDA IF ST100 - V. 01.00.04' , TImpSwedaST100  ,'BRA','381702');
RegistraImpressora('SWEDA IF ST100 - V. 02.00.01' , TImpSwedaST100  ,'BRA','381704');
RegistraImpressora('SWEDA IF ST120 - V. 01.00.01' , TImpSwedaST100  ,'BRA','382001');
RegistraImpressora('SWEDA IF ST120 - V. 01.00.05' , TImpSwedaST100  ,'BRA','382002');
RegistraImpressora('SWEDA IF ST200 - V. 01.00.01' , TImpSwedaST100  ,'BRA','381901');
RegistraImpressora('SWEDA IF ST200 - V. 01.00.05' , TImpSwedaST100  ,'BRA','381902');
RegistraImpressora('SWEDA IF ST1000 - V. 01.00.04', TImpSwedaST1000 ,'BRA','381802');
RegistraImpressora('SWEDA IF ST2000 - V. 01.00.01', TImpSwedaST1000 ,'BRA','382101');
RegistraImpressora('SWEDA IF ST2500 - V. 01.00.05', TImpSwedaST100  ,'BRA','382201');
//RegistraImpressora('SWEDA IF SB200 - V. 01.00.00' , TImpSwedaST100  ,'BRA','382301'); -- Comentado para futura homologação
RegistraImpCheque('SWEDA IF ST1000'               , TImpCheqST1000  ,'BRA');
RegistraImpCheque('SWEDA IF ST2000'               , TImpCheqST1000  ,'BRA');
RegistraImpCheque('SWEDA IF ST2500'               , TImpCheqST1000  ,'BRA');
RegistraCMC7('SWEDA IF ST1000'                    , TCmc7_ST1000    ,'BRA');
RegistraCMC7('SWEDA IF ST2000'                    , TCmc7_ST1000    ,'BRA');
RegistraCMC7('SWEDA IF ST2500'                    , TCmc7_ST1000    ,'BRA');
end.


