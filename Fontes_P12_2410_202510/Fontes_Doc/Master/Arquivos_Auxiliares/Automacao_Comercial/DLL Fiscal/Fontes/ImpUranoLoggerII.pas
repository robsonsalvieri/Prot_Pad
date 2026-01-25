unit ImpUranoLoggerII;

interface

uses
  Dialogs,
  ImpFiscMain,
  Windows,
  SysUtils,
  Classes,
  LojxFun,
  IniFiles,
  ImpCheqMain,
  Forms,
  FileCtrl;

const
  // Tipo do Parâmetro, usado na AdicionaParam()
  G2_BOOLEAN          =  0;
  G2_DATE             =  2;
  G2_TIME             =  3;
  G2_INTEGER          =  4;
  G2_LONGINT          =  5;
  G2_MONEY            =  6;
  G2_STRING           =  7;
  G2_UNSIGNED_INT     =  9;
  G2_UNSIGNED_LONGINT = 10;

type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Urano Logger II
///
  TImpFiscalLoggerII = class(TImpressoraFiscal)
  private
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function AbreEcf:String; override;
    function FechaEcf:String; override;
    function LeituraX:String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function PegaPDV:String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ):String; override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function GravaCondPag( condicao:String ):String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function Gaveta:String; override;
    function StatusImp( Tipo:Integer ):String; override;
    Procedure PulaLinha( iNumero:Integer );
    function HorarioVerao( Tipo:String ):String; override;
    procedure AlimentaProperties; override;
    function RelatorioGerencial( Texto:String;Vias:Integer; ImgQrCode: String):String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;
    function TotalizadorNaoFiscal( Numero,Descricao:String ): String; override;
    function PegaSerie:String; override;
    function ImpostosCupom(Texto: String): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd , sBinario : String  ):String; override;
    function GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: integer; cChavePublica: string; cChavePrivada: string; iUnicoArquivo: integer ): String; override;
    function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer; ImgQrCode: String) : String; override;
    function LeTotNFisc:String; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;        
    function DownMF(sTipo, sInicio, sFinal : String):String; override;
    function RedZDado( MapaRes:String ):String; override;
    function ImpTxtFis(Texto : String) : String; Override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
end;

  TImpFiscalLoggerII_010008 = class(TImpFiscalLoggerII)
  private
  public
    procedure AlimentaProperties; override;
  end;

  TImpFiscalQuickWay = class(TImpFiscalLoggerII)
  public
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
  end;

  TImpFiscalQuickWayV05 = class(TImpFiscalLoggerII)
  public
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
  end;

  TImpFiscalTermoprinterTPF1004 = class(TImpFiscalLoggerII)
  public
    function StatusImp( Tipo:Integer ):String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
  end;

  TImpFiscal2EFC = class(TImpFiscalQuickWay)
  public
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
  end;

  TImpCheque2EFC = class( TImpressoraCheque )
  public
    function Abrir( aPorta:String ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar(aPorta:String ): Boolean; override;
    function StatusCh( Tipo:Integer ):String; override;
  End;

  tipo_parametro = Record
    Nome : string;
    Conteudo : string;
    Tipo : integer;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
function OpenLoggerII( sPorta:String; sImpressora:String ):String;
function CloseLoggerII : String;
function EnviaComando(sComando:String):LongInt;
function sPegaRet(sNomeRetorno:String):String;
function bPegaRet:Boolean;
function iPegaRet:LongInt;
function LeRegistrador(nTipo:LongInt; sValorParam:String):LongInt;
function Executa(nHdlLogger: integer; strComando: string; aParametros: array of tipo_parametro): integer;
function IsEmpty( str: string): boolean;
Function VerificaErro( lRetorno: Longint; var lCodErro: Longint): Boolean;
procedure TrataRetornoUrano( iRet: integer);
Function StatusProssegue( nValor: Integer): Boolean;
Function TrataTags( Mensagem : String ) : String;
function RemoveChar( Texto : String ): String;

implementation
{ Constantes globais  }
const
  sTagGeral  = '\x1B!'; //tag de formatacao multipla do tipo protocolo Logger II
  sTagNegrito = '\x08';
  sTagExpandido = '\x20';
  sTagDesativa = '\x00';           //tag que insere texto 'normal' e desativa as formatações

var
  bOpened : Boolean;
  fHandle : THandle;
  nHdlLogger : LongInt;
  aLastPagto : TAString;
  lSangria   : Boolean = False;
  Path       : String;
  lError     : Boolean = False;      // Controle de Erro para Alimentar Propriedades

  fVersao                : function  (Versao:String; TamVersao:LongInt):String; StdCall;
  fIniciaDriver          : function  (Canal:String):LongInt; StdCall;
  fEncerraDriver         : function  (Handle:LongInt):LongInt; StdCall;
  fConfiguraDriver       : function  (Handle, Speed:LongInt):LongInt; StdCall;
  fSetaArquivoLog        : procedure (NomeArquivoLog:String); StdCall;
  fObtemNomeLog          : function  (NomeArquivo:String; TamNomeArquivo:LongInt):String; StdCall;
  fDefineTimeout         : procedure (Handle, Timeout:LongInt); StdCall;
  fLeTimeout             : function  (Handle:LongInt):LongInt; StdCall;
  fLimpaParams           : procedure (Handle:LongInt); StdCall;
  fAdicionaParam         : procedure (Handle:LongInt; NomeParam,ValorParam:String; TipoParam:LongInt); StdCall;
  fListaParams           : function  (Handle:LongInt; ListaParams:String; TamListaParams:LongInt):String; StdCall;
  fExecutaComando        : function  (Handle:LongInt; Comando:String):LongInt; StdCall;
  fLeRegistrador         : function  (Handle:LongInt; NomeRegistrador,NomeComando:String; TamNomeComando:LongInt):LongInt; StdCall;
  fObtemCodErro          : function  (Handle:LongInt):LongInt; StdCall;
  fObtemNomeErro         : function  (Handle:LongInt; NomeErro:String; TamNomeErro:LongInt):String; StdCall;
  fObtemCircunstancia    : function  (Handle:LongInt; NomeCircunstancia:String; TamNomeCircunstancia:LongInt):String; StdCall;
  fObtemRetornos         : function  (Handle:LongInt; Retornos:String; TamRetorno:LongInt):pchar; StdCall;
  fTotalRetornos         : function  (Handle:LongInt):LongInt; StdCall;
  fRetorno               : function  (Handle,Indice:LongInt; NomeRetorno:String; TamNomeRetorno:LongInt; ValorRetorno:String; TamValorRetorno:LongInt):LongInt; StdCall;

  //Funções PAF-ECF Leitura.dll
  fDLLReadLeMemorias        : function ( szPortaSerial: String; szNomeArquivo: String; szSerieECF: String; bAguardaConcluirLeitura: String):Integer; StdCall;
  fDLLReadCancelaLeitura    : function :Integer; StdCall;

  //Funções PAF-ECF Ato17.dll
  fDLLATO17GeraArquivo      : function (szArquivoBinario: String; szArquivoTexto: String; szPeriodoIni: String; szPeriodoFIM: String; TipoPeriodo: String; szUsuario: String; szTipoLeitura: String):Integer; StdCall;

//---------------------------------------------------------------------------
function TImpFiscalLoggerII.Abrir(sPorta : String; iHdlMain:Integer) : String;
begin
  Result := OpenLoggerII( sPorta, '' );
  fSetaArquivoLog( ExtractFilePath(Application.ExeName) + 'urano.log' );
  // Carrega as aliquotas e as formas de pagamento para ganhar performance
  if Copy(Result,1,1) = '0' then
     AlimentaProperties;

  if lError then
  begin
    Result := '1';
    LjMsgDlg( MsgErroProp );
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.Fechar( sPorta:String ):String;
begin
  Result := CloseLoggerII;
end;

//---------------------------------------------------------------------------
function TImpFiscalLoggerII.LeituraX : String;
var
    iRet : Integer;
begin
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('EmiteLeituraX');
  if iRet = 0 then
  begin
    PulaLinha(170);
    Result := '0'
  end
  else
    Result := '1';
end;

//---------------------------------------------------------------------------
function TImpFiscalLoggerII.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalLoggerII.ReducaoZ ( MapaRes:String ): String;
var
  i,iRet,iMaxAliq : Integer;
  sRet,sAliq,sValor,sImposto : String;
  bOk,bAliqICMS : Boolean;
  aRetorno : array of String;
begin
  fDefineTimeout(nHdlLogger, 9999);
  bOk := True;
  if Trim(MapaRes) = 'S' then
  begin
    SetLength(aRetorno, 21);

    //**** Data do Movimento ****//
    iRet := LeRegistrador(G2_DATE, 'DataAbertura');
    if iRet > 0 then
    begin
      sRet := sPegaRet('ValorData');
      aRetorno[0] := Copy(sRet,1,6)+Copy(sRet,9,2)
    end
    else
      bOk := False;

    //**** Numero do ECF ****//
    if bOk then
    begin
      sRet := PegaPDV;
      if (Copy(sRet,1,1)='0') then
        aRetorno[1] := Copy(sRet,3,3)
      else
        bOk := False;
    end;

    //**** Serie do ECF ****//
    if bOk then
    begin
      sRet := PegaSerie;
      if (Copy(sRet,1,1)='0') then
      Begin
        aRetorno[2] := Copy(sRet,3,Length(sRet)-2);
        GravaLog(' <- ReducaoZ - NumSerie: ' + aRetorno[2]);
      End
      Else
        bOk := False;
    End;

    //**** Numero de Reducoes ****//
    if bOk then
    begin
      GravaLog(' Leitura do CRZ -> ');
      iRet := LeRegistrador(G2_INTEGER, 'CRZ');
      GravaLog(' Leitura do CRZ <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        aRetorno[3] := FormataTexto(IntToStr(iPegaRet()),5,0,2)
      end
      else
        bOk := False;
    end;

    //**** Grande Total Final ****//
    if bOk then
    begin
      GravaLog(' Leitura do GT -> ');
      iRet := LeRegistrador(G2_MONEY, 'GT');
      GravaLog(' Leitura do GT <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[4] := FormataTexto(sRet,19,2,1);
      end
      else
        bOk := False;
    end;

    //**** Numero Documento Inicial ****//
    if bOk then
    begin
      GravaLog(' Leitura do COOInicioDia -> ');
      iRet := LeRegistrador(G2_INTEGER, 'COOInicioDia');
      GravaLog(' Leitura do COOInicioDia <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
        aRetorno[5] := FormataTexto(IntToStr(iPegaRet()),6,0,2)
      else
        bOk := False;
    end;

    //**** Numero Documento Final ****//
    if bOk then
    begin
      sRet := PegaCupom('');
      if (Copy(sRet,1,1)='0') then
        aRetorno[6] := Copy(sRet,3,6)
      else
        bOk := False;
    end;

    //**** Valor do Cancelamento ICMS****//
    if bOk then
    begin
      GravaLog(' Leitura do TotalDiaCancelamentosICMS -> ');
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaCancelamentosICMS');
      GravaLog(' Leitura do TotalDiaCancelamentosICMS <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[7] := FormataTexto(sRet,15,2,1);
      end
      else
        bOk := False;
    end;

    //**** Valor do Cancelamento ISS****//
    if bOk then
    begin
      GravaLog(' Leitura do TotalDiaCancelamentosISSQN -> ');
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaCancelamentosISSQN');
      GravaLog(' Leitura do TotalDiaCancelamentosISSQN <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[19]:= FormataTexto(sRet,15,2,1);                 // cancelamento de ISS
      end
      else
        bOk := False;
    end;

    //**** Venda Líquida ****//
    if bOk then
    begin
      GravaLog(' Leitura do TotalDiaVendaLiquida -> ');
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaLiquida');
      GravaLog(' Leitura do TotalDiaVendaLiquida <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[8] := FormataTexto(sRet,15,2,1);
      end
      else
        bOk := False;
    end;

    //**** Desconto de ICMS****//
    if bOk then
    begin
      GravaLog(' Leitura do TotalDiaDescontos -> ');
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaDescontos');
      GravaLog(' Leitura do TotalDiaDescontos <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[9] := FormataTexto(sRet,11,2,1);
      end
      else
        bOk := False;
    end;

    //**** Desconto de ISS****//
    if bOk then
    begin
      GravaLog(' Leitura do TotalDiaDescontosISSQN -> ');
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaDescontosISSQN');
      GravaLog(' Leitura do TotalDiaDescontosISSQN <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[18] := FormataTexto(sRet,15,2,1);
      end
      else
        bOk := False;
    end;

    //**** Não tributado - Substituição Tributária ****//
    if bOk then
    begin
      GravaLog(' Leitura do TotalDiaSubstituicaoTributariaICMS -> ');
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaSubstituicaoTributariaICMS');
      GravaLog(' Leitura do TotalDiaSubstituicaoTributariaICMS <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[10] := FormataTexto(sRet,11,2,1);
      end
      else
        bOk := False;
    end;

    //**** Não Tributado - ISENTO ****//
    if bOk then
    begin
      GravaLog(' Leitura do TotalDiaIsencaoICMS -> ');
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaIsencaoICMS');
      GravaLog(' Leitura do TotalDiaIsencaoICMS <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[11] := FormataTexto(sRet,11,2,1);
      end
      else
        bOk := False;
    end;

    //**** Não tributado - Não Incidência ICMS ****//
    if bOk then
    begin
      GravaLog(' Leitura do TotalDiaNaoTributadoICMS -> ');
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaNaoTributadoICMS');
      GravaLog(' Leitura do TotalDiaNaoTributadoICMS <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
      begin
        sRet := sPegaRet('ValorMoeda');
        sRet := StrTran(sRet, '.', '');
        aRetorno[12] := FormataTexto(sRet,11,2,1);
      end
      else
        bOk := False;
    end;

    //**** Data da Reducao Z ****//
    if bOk then
      aRetorno[13] := Copy(StatusImp(2),3,8);

    if bOk then
    begin
      aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);
    end;

    //**** Outros Recebimentos ****//
    if bOk then
    begin
      aRetorno[15] := FormataTexto('0',16, 0, 1);
    end;

    //**** ISS ****//
    aRetorno[16]:= '00000000000.00 00000000000.00';

    //**** CRO - Contador de Reinício de Operação ****//
    if bOk then
    begin
      GravaLog(' Leitura do CRO -> ');
      iRet := LeRegistrador(G2_INTEGER, 'CRO');
      GravaLog(' Leitura do CRO <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
        aRetorno[17]:= Copy( FormataTexto(IntToStr(iPegaRet()),6,0,2),Length(FormataTexto(IntToStr(iPegaRet()),6,0,2))-2,3)
      else
        bOk := False;
    end;

    iMaxAliq := -1;
    // Retorna o índice da última aliquota cadastrada
    if bOk then
    begin
      GravaLog(' Leitura do AliquotaDisponivel -> ');
      iRet := LeRegistrador(G2_INTEGER, 'AliquotaDisponivel');
      GravaLog(' Leitura do AliquotaDisponivel <- iRet : ' + IntToStr(iRet));
      if iRet > 0 then
        iMaxAliq := iPegaRet()-1
      else
        bOk := False;
    end;

    aRetorno[20]:= '00';                                          // ****** qtde de aliquotas *****

    if bOk then
    begin
      for i := 0 to iMaxAliq do
      begin
        fLimpaParams(nHdlLogger);
        fAdicionaParam(nHdlLogger, 'CodAliquotaProgramavel', IntToStr(i), G2_INTEGER);
        EnviaComando('LeAliquota');
        sAliq    := sPegaRet('PercentualAliquota');
        sAliq    := StrTran(sAliq,',','.');
        bAliqICMS := sPegaRet('AliquotaICMS') = 'Y';
        LeRegistrador(G2_MONEY, 'TotalDiaValorAliquota['+IntToStr(i)+']');
        sValor   := sPegaRet('ValorMoeda');
        sValor   := StrTran(sValor, '.', '');
        LeRegistrador(G2_MONEY, 'TotalDiaImpostoAliquota['+IntToStr(i)+']');
        sImposto := sPegaRet('ValorMoeda');
        sImposto := StrTran(sImposto, '.', '');
        if bAliqICMS then
        begin
          //**** Qtde de Aliquotas ****//
          aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
          SetLength( aRetorno, Length(aRetorno)+1 );
          aRetorno[High(aRetorno)] := 'T'+FormataTexto(sAliq,5,2,1,'.')+' '+FormataTexto(sValor,14,2,1,'.')+' '+FormataTexto(sImposto,14,2,1,'.')
        end
        else
        begin
          // ' Valor '  ' Imposto Debitado
          sValor   := StrTran(sValor, ',', '.');
          sImposto := StrTran(sImposto, ',', '.');
          aRetorno[16] := FormataTexto(FloatToStr(StrToFloat(copy(aRetorno[16], 1,14))+StrToFloat(sValor)  ),14,2,1,'.')+' '+
                          FormataTexto(FloatToStr(StrToFloat(copy(aRetorno[16],16,14))+StrToFloat(sImposto)),14,2,1,'.');
        end;
      end;
    end;
  end;

  if bOk then
  begin
    fLimpaParams(nHdlLogger);
    GravaLog(' EmiteReducaoZ -> ');
    iRet := EnviaComando('EmiteReducaoZ');
    GravaLog(' EmiteReducaoZ <- iRet : ' + IntToStr(iRet));

    if iRet = 0 then
    begin
      PulaLinha(170);
      Result := '0';
      if Trim(MapaRes) = 'S' then
      begin
        Result := Result + '|';

         //**** Numero de Reducoes ****//
        if bOk then
        begin
          GravaLog(' Leitura do CRZ -> ');
          iRet := LeRegistrador(G2_INTEGER, 'CRZ');
          GravaLog(' Leitura do CRZ <- iRet : ' + IntToStr(iRet));
          if iRet > 0 then
          begin
            aRetorno[3] := FormataTexto(IntToStr(iPegaRet()),5,0,2)
          end
          else
            bOk := False;
        end;

        //**** Numero Documento Final ****//
        if bOk then
        begin
          sRet := PegaCupom('');
          if (Copy(sRet,1,1)='0') then
            aRetorno[6] := Copy(sRet,3,6)
          else
          bOk := False;
        end;

        For i:= 0 to High(aRetorno) do
          Result := Result + aRetorno[i]+'|';
      end;
    end
    else
      Result := '1';
  end
  else
    Result := '1';
  fDefineTimeout(nHdlLogger, 15);
end;

//---------------------------------------------------------------------------
function TImpFiscalLoggerII.LeAliquotas:String;
begin
  Result := '0|' + ALIQUOTAS;
end;

//---------------------------------------------------------------------------
function TImpFiscalLoggerII.LeAliquotasISS:String;
begin
  Result := '0|' + ISS;
end;

//---------------------------------------------------------------------------
function TImpFiscalLoggerII.LeCondPag:String;
begin
  Result := '0|'+FormasPgto
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.AbreCupom(Cliente:String; MensagemRodape:String):String;
var
  iRet : Integer;
  aAuxiliar : TaString;
  sCnpjCpf, sNomeCli, sEnd : String;
begin
  sCnpjCpf := '';
  sNomeCli := '';
  sEnd     := '';

  fLimpaParams(nHdlLogger);

  //Quando é enviado qualquer parametro(IdConsumidor,NomeConsumidor,EnderecoConsumidor) o cupom imprime o título dos 3 itens, mesmo quando não informando.
  If Pos('|', Cliente) > 0 then
  begin
    MontaArray(Cliente, aAuxiliar);

    If Length( aAuxiliar ) >= 1 then
    begin
      sCnpjCpf := Copy( aAuxiliar[0], 1, 29 );
      fAdicionaParam(nHdlLogger, 'IdConsumidor', sCnpjCpf, G2_STRING);
    end;

    If Length( aAuxiliar ) >= 2 then
    begin
      sNomeCli := Copy( aAuxiliar[1], 1, 30 );
      fAdicionaParam(nHdlLogger, 'NomeConsumidor', sNomeCli, G2_STRING);
    end;

    If Length( aAuxiliar ) >= 3 then
    begin
      sEnd := Copy( aAuxiliar[2], 1, 80 );
      fAdicionaParam(nHdlLogger, 'EnderecoConsumidor', sEnd, G2_STRING);
    end;
  end
  else if Cliente <> '' then
    fAdicionaParam(nHdlLogger, 'IdConsumidor', Copy(Cliente,0,30), G2_STRING);

  iRet := EnviaComando('AbreCupomFiscal');
  if iRet = 0 then
    Result := '0'
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.PegaCupom(Cancelamento:String):String;
var iRet : Integer;
begin
  Result := '1';
  iRet := LeRegistrador(G2_INTEGER, 'COO');
  if iRet > 0 then
    Result := '0|'+FormataTexto(IntToStr(iPegaRet()),6,0,2)
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.PegaPDV:String;
var iRet : Integer;
begin
  Result := '1';
  iRet := LeRegistrador(G2_INTEGER, 'ECF');
  if iRet > 0 then
    Result := '0|'+FormataTexto(IntToStr(iPegaRet()),3,0,2)
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var iRet : Integer;
begin
  fLimpaParams(nHdlLogger);
  fAdicionaParam(nHdlLogger, 'NumItem', NumItem, G2_INTEGER);
  iRet := EnviaComando('CancelaItemFiscal');
  if iRet = 0 then
    Result := '0'
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.CancelaCupom( Supervisor:String ):String;
var iRet : Integer;
begin
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('CancelaCupom');
  if iRet = 0 then
  begin
    PulaLinha(170);
    Result := '0'
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
var sAliquotaICMS : String;
    iRet : Integer;
    sSituacao : String;
    sTrib : String;
begin
  // Elimina os espaços iniciais e finais
  Codigo      := TrimLeft(TrimRight(Codigo));
  Descricao   := TrimLeft(TrimRight(Descricao));
  Qtde        := TrimLeft(TrimRight(Qtde));
  VlrUnit     := TrimLeft(TrimRight(VlrUnit));
  VlrDesconto := TrimLeft(TrimRight(VlrDesconto));
  VlTotIt     := TrimLeft(TrimRight(VlTotIt));

  //Verifica se é para registra a venda do item ou só o desconto
  if (Trim(Codigo+Descricao)='') And (StrToFloat(Qtde)+StrToFloat(VlrUnit)=0) then
  begin
    if StrToFloat(VlrDesconto) > 0 then
    begin
      VlrDesconto := StrTran(VlrDesconto, '.', ',');
      VlrDesconto := StrTran(VlrDesconto, ' ', '');
      fLimpaParams(nHdlLogger);
      fAdicionaParam(nHdlLogger, 'Cancelar', 'F', G2_BOOLEAN);
      fAdicionaParam(nHdlLogger, 'ValorAcrescimo', '-'+VlrDesconto, G2_MONEY);
      iRet := EnviaComando('AcresceItemFiscal');
      if iRet = 0 then
        Result := '0'
      else
        Result := '1';
    end
    else
      Result := '0';
    Exit;
  end;

  // Faz o tratamento da quantidade e do valor
  VlrUnit := StrTran(VlrUnit, '.', ',');
  Qtde    := StrTran(Qtde, '.', ',');

  // Faz o tratamento da aliquota
  sSituacao := Copy(Aliquota,1,1);
  Aliquota := StrTran(copy(Aliquota,2,5),'.',',');
  Aliquota := TrimLeft(TrimRight(Aliquota));

  if (sSituacao = 'T') Or (sSituacao = 'S') then
  begin
    sAliquotaICMS := 'Y';
    if sSituacao = 'S' then
      sAliquotaICMS := 'N';
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'AliquotaICMS', sAliquotaICMS, G2_BOOLEAN);
    fAdicionaParam(nHdlLogger, 'PercentualAliquota', Aliquota, G2_MONEY);
    iRet := EnviaComando('LeAliquota');
    if iRet > 0 then
      sTrib := sPegaRet('CodAliquotaProgramavel')
    else
      sTrib := '';
  end
  else if sSituacao = 'F' then // Substituição Tributária ICMS
    sTrib := '-2'
  else if sSituacao = 'I' then // Isento ICMS
    sTrib := '-3'
  else if sSituacao = 'N' then // Não Tributado ICMS
    sTrib := '-4';

  if sTrib = '' then
  begin
    ShowMessage('A alíquota informada '+sSituacao+Aliquota+' não existe no ECF');
    result := '1';
    Exit;
  end;

  fLimpaParams(nHdlLogger);
  if sSituacao = 'S' then
    fAdicionaParam(nHdlLogger, 'AliquotaICMS', 'F', G2_BOOLEAN);
  fAdicionaParam(nHdlLogger, 'CodAliquota', sTrib, G2_INTEGER);
  fAdicionaParam(nHdlLogger, 'CodProduto', Codigo, G2_STRING);
  fAdicionaParam(nHdlLogger, 'NomeProduto', Descricao, G2_STRING);
  fAdicionaParam(nHdlLogger, 'PrecoUnitario', VlrUnit, G2_MONEY);
  fAdicionaParam(nHdlLogger, 'Quantidade', Qtde, G2_MONEY);
  iRet := EnviaComando('VendeItem');
  if iRet = 0 then
  begin
    if StrToFloat(VlrDesconto) > 0 then
    begin
      VlrDesconto := StrTran(VlrDesconto, '.', ',');
      VlrDesconto := StrTran(VlrDesconto, ' ', '');
      fLimpaParams(nHdlLogger);
      fAdicionaParam(nHdlLogger, 'Cancelar', 'F', G2_BOOLEAN);
      fAdicionaParam(nHdlLogger , 'ValorAcrescimo', '-'+VlrDesconto, G2_MONEY);
      iRet := EnviaComando('AcresceItemFiscal');
      if iRet = 0 then
        Result := '0'
      else
        Result := '1';
    end
    else
      Result := '0'
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.AbreECF:String;
begin
  if StatusImp(8) = '10' then
    Application.MessageBox('Antes de realizar qualquer operação, é necessário realizar a Redução Z referente ao dia anterior.',
      'Redução Z Pendente', MB_OK + MB_ICONEXCLAMATION);
  result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalLoggerII.FechaEcf : String;
var iRet : Integer;
begin
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('EmiteReducaoZ');
  if iRet = 0 then
  begin
    PulaLinha(170);
    Result := '0';
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.Pagamento( Pagamento,Vinculado,Percepcion : String ): String;
var i,iRet : Integer;
begin
  Result := '0';
  Pagamento := StrTran(Pagamento,'.',',');

  // Monta um array auxiliar com as formas solicitadas
  MontaArray( Pagamento,aLastPagto );

  // Faz o registro do pagamento
  i:=0;
  while i<Length(aLastPagto) do
  begin
    fLimpaParams(nHdlLogger);
    if UpperCase(aLastPagto[i]) = 'DINHEIRO' then
      fAdicionaParam(nHdlLogger, 'CodMeioPagamento', '-2', G2_INTEGER)
    else
      fAdicionaParam(nHdlLogger, 'NomeMeioPagamento', aLastPagto[i], G2_STRING);
    fAdicionaParam(nHdlLogger, 'Valor', aLastPagto[i+1], G2_MONEY);
    iRet := EnviaComando('PagaCupom');
    if iRet = 0 then
      Inc(i,2)
    else
    begin
      Result := '1';
      Exit;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.FechaCupom( Mensagem:String ):String;
var
iRet : Integer;
cMsg : String ;
begin
  fLimpaParams(nHdlLogger);
  if Mensagem <> '' then
  begin
    cMsg := Mensagem;

    //a impressora nao aceita este caracter, por isso deve-se remove-lo
    while Pos( '"' , cMsg ) > 0 do
    begin
      cMsg := StringReplace( cMsg ,'"','''',[]);
    end;

    cMsg := TrataTags( cMsg );
    fAdicionaParam(nHdlLogger, 'TextoPromocional', cMsg, G2_STRING);
  end;

  iRet := EnviaComando('EncerraDocumento');
  if iRet = 0 then
  begin
    PulaLinha(170);
    Result := '0'
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String;
var iRet : Integer;
begin
  Result := '0';
  if StrToFloat(VlrDesconto) > 0 then
  begin
    VlrDesconto := StrTran(VlrDesconto, '.', ',');
    VlrDesconto := StrTran(VlrDesconto, ' ', '');
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'Cancelar', 'F', G2_BOOLEAN);
    fAdicionaParam(nHdlLogger, 'ValorAcrescimo', '-'+VlrDesconto, G2_MONEY);
    iRet := EnviaComando('AcresceSubtotal');
    if iRet = 0 then
      Result := '0'
    else
      Result := '1';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.AcrescimoTotal( vlrAcrescimo:String ): String;
var iRet : Integer;
begin
  Result := '0';
  if StrToFloat(VlrAcrescimo) > 0 then
  begin
    VlrAcrescimo := StrTran(VlrAcrescimo, '.', ',');
    VlrAcrescimo := StrTran(VlrAcrescimo, ' ', '');
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'Cancelar', 'F', G2_BOOLEAN);
    fAdicionaParam(nHdlLogger, 'ValorAcrescimo', VlrAcrescimo, G2_MONEY);
    iRet := EnviaComando('AcresceSubtotal');
    if iRet = 0 then
      Result := '0'
    else
      Result := '1';
  end;
end;

//----------------------------------------------------------------------------

function TImpFiscalLoggerII.GeraArquivoMFD( cDadoInicial: string; cDadoFinal: string; cTipoDownload: string; cUsuario: string; iTipoGeracao: integer; cChavePublica: string; cChavePrivada: string; iUnicoArquivo: integer ): String;
var
  cTipo,cNomeArq,sArquivo,sPorta,sInicio,sFinal,sPathExe : String;
  sLista : TStringList;
  iRet : Integer;
begin
  If cTipoDownload = 'D'
  Then cTipo := '1'
  Else cTipo := '2';

  Result   := '1';
  sPathExe := ExtractFilePath(Application.ExeName);
  sArquivo := sPathExe + DEFAULT_PATHARQMFD + 'URANO.MFD';

  If not ExisteDir(sPathExe+DEFAULT_PATHARQMFD)
  Then ForceDirectories(sPathExe+DEFAULT_PATHARQMFD);

  sPorta   := Porta;
  if sPorta = 'EMUL' then
    sPorta := 'Emul';

  fEncerraDriver(nHdlLogger);
  iRet := fDLLReadLeMemorias(sPorta,sArquivo,NumSerie,'1');

  {Reinicia a conexão com a Porta}
  nHdlLogger := fIniciaDriver(sPorta);

  if nHdlLogger = -1 then
    ShowMessage('Erro na abertura da porta');

  if cTipo = '1' Then
  begin
    sInicio := FormatDateTime('dd/mm/yyyy',StrToDate(cDadoInicial));
    sFinal  := FormatDateTime('dd/mm/yyyy',StrToDate(cDadoFinal));
    cNomeArq:= NumSerie + '_' + FormatDateTime('ddMMYY',StrToDate(cDadoInicial)) + '_' + FormatDateTime('ddMMYY',StrToDate(cDadoFinal)) + '.TXT'
  end;

  if iRet = 0 then
  begin
    iRet := fDLLATO17GeraArquivo(sArquivo,sPathExe+DEFAULT_PATHARQMFD+ArqTipRegE,sInicio,sFinal,'D','0','MFD');

    if iRet = 0 then
    begin
      Result := '0';
      sLista := TStringList.Create;
      sLista.LoadFromFile(sPathExe+DEFAULT_PATHARQMFD+ArqTipRegE);
      sLista.SaveToFile(sPathExe+DEFAULT_PATHARQMFD+cNomeArq); // Salva com um nome padrão para que o Protheus possa tratar deste arquivo
      sLista.Free;
      sLista := NIL;

      DeleteFile(sPathExe+DEFAULT_PATHARQMFD+ArqTipRegE);
    end;
  end;

end;

function TImpFiscalLoggerII.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String;
var
  iRet : Integer;
  sDataInicio, sDataFim : String;
  sTipoAux, sTipoLeitura: String;
  bPorData: Boolean;
  sArq, sRetorno: String;
  bContinua: Boolean;
  sValorRetorno: AnsiString;
  fArquivo: TextFile;
  nHandle: Integer;
begin
  //Parametro "Tipo" recebe string com duas posições:
  //Primeira posição: "I" para impressão e "A" salvar arquivo
  //Segunda posição: "S" para leitura simplificada e "C" para leitura completa

  sTipoLeitura := UpperCase(Copy(Tipo,1,1)); //Quando para gerar em arquivo, recebe A, função da impressora espera 'I' ou 'S'.
  sTipoAux     := UpperCase(Copy(Tipo,2,1)); //Configura se Leitura será Simplificada ou Completa, padrão Completa.

  if sTipoLeitura <> 'I' then
    sTipoLeitura := 'S';

  if Not((sTipoAux = 'S') or (sTipoAux = 'C')) then
    sTipoAux := 'C';

  bPorData := (Trim(ReducInicio + ReducFim) = '');
  fLimpaParams(nHdlLogger);

  If bPorData then
  begin
    DateTimeToString(sDataInicio, 'dd/mm/yyyy', DataInicio);
    DateTimeToString(sDataFim, 'dd/mm/yyyy', DataFim);
    fAdicionaParam(nHdlLogger, 'DataFinal', sDataFim, G2_DATE);
    fAdicionaParam(nHdlLogger, 'DataInicial', sDataInicio, G2_DATE);
  end
  else
  begin
    fAdicionaParam(nHdlLogger, 'ReducaoFinal', ReducFim, G2_INTEGER);
    fAdicionaParam(nHdlLogger, 'ReducaoInicial', ReducInicio, G2_INTEGER);
  end;

  fAdicionaParam(nHdlLogger, 'Destino', Copy(sTipoLeitura,1,1), G2_STRING);

  if sTipoAux = 'C' then
    fAdicionaParam(nHdlLogger, 'LeituraSimplificada', 'F', G2_BOOLEAN)
  else
    fAdicionaParam(nHdlLogger, 'LeituraSimplificada', 'T', G2_BOOLEAN);

  iRet := EnviaComando('EmiteLeituraMF');
  if iRet = 0 then
  begin
    if sTipoLeitura = 'S' then
    begin
      if sTipoAux = 'S' then
        sArq := PathArquivo + DEFAULT_ARQMEMSIM
      else
        sArq := PathArquivo + DEFAULT_ARQMEMCOM ;

      fDefineTimeout(nHdlLogger, 30);
      nHandle := FileCreate( sArq );
      FileClose( nHandle );

      AssignFile( fArquivo, sArq );
      Rewrite( fArquivo );
      bContinua := True;

      while bContinua do
      begin
        sValorRetorno := Space( 5000 );
        iRet := EnviaComando('LeImpressao');
        iRet := fRetorno(nHdlLogger, 0, 'TextoImpressao', 0, sValorRetorno, 5000);
        If Length( Trim( sValorRetorno ) ) < 3 Then
          bContinua := False;
        sValorRetorno := StrTran( sValorRetorno, 'Ç', 'Ã' );
        sValorRetorno := StrTran( sValorRetorno, '€', 'Ç' );
        sValorRetorno := StrTran( sValorRetorno, '‡', 'ç' );
        sValorRetorno := StrTran( sValorRetorno, 'Æ', 'ã' );
        sValorRetorno := StrTran( sValorRetorno, 'ä', 'õ' );
        sValorRetorno := StrTran( sValorRetorno, '¢', 'ó' );
        sValorRetorno := StrTran( sValorRetorno, 'µ', 'Á' );
        sValorRetorno := StrTran( sValorRetorno, 'Ö', 'Í' );
        sValorRetorno := StrTran( sValorRetorno, 'à', 'Ó' );
        sValorRetorno := StrTran( sValorRetorno, 'å', 'Õ' );
        sValorRetorno := StrTran( sValorRetorno, '¡', 'í' );

        while Trim( sValorRetorno ) <> '' do
        begin
          If ( Pos( #10, sValorRetorno ) > 0 ) And ( Pos( #10, sValorRetorno ) <= 48 )  Then
          begin
            If Pos( #10, sValorRetorno ) < 48 Then
              sRetorno := Copy( sValorRetorno, 1, Pos( #10, sValorRetorno ) ) + Space( 48 - Pos( #10, sValorRetorno ) )
            Else
              sRetorno := Copy( sValorRetorno, 1, Pos( #10, sValorRetorno ) );

            sValorRetorno := Copy( sValorRetorno, Pos( #10, sValorRetorno ) + 1, Length( sValorRetorno ) );
            Writeln( fArquivo, sRetorno );

          end
          else
          begin
            sRetorno := Copy( sValorRetorno, 1, 48 );
            sValorRetorno := Copy( sValorRetorno, 49, Length( sValorRetorno ) );
            Writeln( fArquivo, sRetorno );
          end;

        end;
      end;
      CloseFile( fArquivo );
      fDefineTimeout(nHdlLogger, 15);
      Result := '0';
    end
    else
      Result := '0';
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
var iRet, i : Integer;
    sAliq   : String;
    aAliq   : TaString;
    bAchou  : Boolean;
begin
  // Tipo = 1 - ICMS
  // Tipo = 2 - ISS
  Aliquota := StrTran(Aliquota,',','.');
  bAchou   := False;
  sAliq    := LeAliquotas;
  MontaArray(Copy(sAliq,2,Length(sAliq)), aAliq);
  For i:=0 to Length(aAliq)-1 do
  begin
    if StrTran(aAliq[i],',','.') = Aliquota then
      bAchou := True;
    if StrToFloat(aAliq[i]) = 0 then
      break;
  end;
  if not bAchou then
    if i < 15 then
    begin
      fLimpaParams(nHdlLogger);
      if Tipo = 2 then
        fAdicionaParam(nHdlLogger, 'AliquotaICMS', 'N', G2_BOOLEAN);    // Aliquota de ISS
      fAdicionaParam(nHdlLogger, 'PercentualAliquota', StrTran(Aliquota,'.',','), G2_MONEY);
      iRet := EnviaComando('DefineAliquota');
      if iRet > 0 then
        Result := '0'
      else
        Result := '1';
    end
    else
    begin
      ShowMessage('Não há mais espaço em memória para adicionar alíquotas.');
      result := '6|';
    end
  else
  begin
    ShowMessage('Aliquota já Cadastrada.');
    result := '4|';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.GravaCondPag( condicao:String ):String;
var iRet : Integer;
    aPagto : TaString;
    sPagto : String;
    iPos : Integer;
    i : Integer;
begin
  // Verifica as condicoes já existentes
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)), aPagto );
  iPos  := 99;
  for i:=0 to Length(aPagto)-1 do
  begin
    if UpperCase(aPagto[i]) = UpperCase(condicao) then
      iPos := i;
  end;

  if iPos = 99 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'NomeMeioPagamento', Condicao, G2_STRING);
    iRet := EnviaComando('DefineMeioPagamento');
    if iRet > 0 then
      Result := '0|'
    else
      Result := '1|';
  end
  else
  begin
    ShowMessage('Já existe a condição de pagamento ' + condicao );
    result := '4|';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
var i, iRet : Integer;
begin
  Valor := TrimLeft(TrimRight(Valor));
  Valor := StrTran(Valor,'.',',');
  // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if (Pos('.', Valor) = 0) And (Pos(',', Valor) = 0) then
  begin
    Valor    := Trim(Valor);
    Valor    := Copy(Valor,1,Length(Valor)-2)+','+Copy(Valor,Length(Valor)-1,2);
  end;
  fLimpaParams(nHdlLogger);

  // Se nao foi realizado cupom fiscal
  if Length(aLastPagto) = 0 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
    iRet := EnviaComando('AbreCreditoDebito');
    if iRet = 0 then
      Result := '0'
    else
      Result := '1';
  end
  else
  begin
    i:=0;
    while i<Length(aLastPagto) do
    begin
      if StrToFloat(StrTran(aLastPagto[i+1],',','.')) = StrToFloat(StrTran(Valor,',','.')) then
      begin
        fAdicionaParam(nHdlLogger, 'NumItem', IntToStr((i div 2)+1), G2_INTEGER);
        Break;
      end;
      Inc(i,2)
    end;
    SetLength(aLastPagto, 0);

    // Passando somente o valor no Emulador, funciona, no ECF não.
    fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
    iRet := EnviaComando('AbreCreditoDebito');
    if iRet = 0 then
      Result := '0'
    else
    begin
      // Verifica o Codigo de Erro. Caso seja 8000, significa que está sendo emitido
      // um Cupom Não Fiscal Não Vinculado. Como este ECF não possui este comando
      // é emitido um Relatório Gerencial.
      iRet := fObtemCodErro(nHdlLogger);
      if iRet = 8000 then
      begin
        fLimpaParams(nHdlLogger);
        fAdicionaParam(nHdlLogger, 'CodGerencial', '0', G2_INTEGER);
        iRet := EnviaComando('AbreGerencial');
        if iRet = 0 then
          Result := '0'
        else
          Result := '1';
      end
      else
        Result := '1';
    end;
  end;
  if (Result = '0') And (Texto <> '') then
    TextoNaoFiscal(Texto, 1);
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
var iRet, i, nLoop : Integer;
    lOk : boolean;
    iMax:Integer;
begin
  lOk := True;
  // Executa o loop para impressao das vias
  for nLoop := 1 to Vias do
  begin
    // Executa impressao do texto em bloco de 492 caracteres
    i := 0;
    iMax := Length(Texto);
    while i <= iMax do
    begin
      fLimpaParams(nHdlLogger);
      fAdicionaParam(nHdlLogger, 'TextoLivre', Copy(Texto,i,i+492), G2_STRING);
      iRet := EnviaComando('ImprimeTexto');
      lOk := (iRet = 0);
      if not lOk then break;
      i := i+493;
    end;
    // Se houve problema na impressão da linha aborta proximas vias
    if not lOk then break;
  end;
  if lOk then
    Result := '0'
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.FechaCupomNaoFiscal: String;
var iRet : Integer;
begin
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('EncerraDocumento');
  if iRet = 0 then
  begin
    PulaLinha(170);
    Result := '0'
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.ReImpCupomNaoFiscal( Texto:String ): String;
var iRet : Integer;
begin
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('ReimprimeViaCreditoDebito');
  if iRet = 0 then
    Result := '0'
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.TotalizadorNaoFiscal( Numero,Descricao:String ): String;
var iRet : integer;
begin
  if StrToInt(Numero) < 0 then
    result := '1|'
  else if Descricao = '' then
    result := '1|'
  else
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodNaoFiscal', Numero, G2_INTEGER);
    fAdicionaParam(nHdlLogger, 'NomeNaoFiscal', Descricao, G2_STRING);
    iRet := EnviaComando('DefineNaoFiscal');
    if iRet > 0 then
      Result := '0'
    else
      Result := '1';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.PegaSerie : String;
var
  iRet : Integer;
  sRet : String;
begin
  Result := '1';
  iRet := LeRegistrador(G2_STRING, 'NumeroSerieECF');
  sRet := '0|'+sPegaRet('ValorTexto');
  if iRet > 0 then
    Result := sRet;
  If LogDLL Then
    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- PegaSerie: ' + sRet ));
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.Suprimento( Tipo:Integer; Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
var iRet : Integer;
    sRet : String;
    bSangria : Boolean;
    sRetAux : String;
begin
  // Tipo 1 - Lê o Suprimento
  // Tipo 2 - Grava Suprimento
  // Tipo 3 - Efetua Sangria

  //****************************************************************************
  // Sequencia de comandos para fazer a sangria e o suprimento.
  // Obs.1: Na Sangria não pode ser informada a forma de pagamento
  // Obs.2: No suprimento deve sempre ser informado o pagamento como Dinheiro
  //
  // Sangria - comandos
  //    EmiteItemNaoFiscal
  //    EncerraDocumento
  //
  // Sangria - comandos
  //    EmiteItemNaoFiscal
  //    PagaCupom
  //    EncerraDocumento
  //****************************************************************************

  if Tipo = 1 then
  begin
    Result := '0|0.00';
  end
  else
  begin
    if Forma = '' then
    begin
      if Tipo = 2 then
        Forma := 'Suprimento'
      else
        Forma := 'Sangria';
    end;
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'NomeNaoFiscal', Forma, G2_STRING);
    iRet := EnviaComando('LeNaoFiscal');

    // Caso minusculo de erro, tente maiusculo
    If iRet < 0 Then
    Begin
      fLimpaParams(nHdlLogger);
      fAdicionaParam(nHdlLogger, 'NomeNaoFiscal', UpperCase( Forma ), G2_STRING);
      iRet := EnviaComando('LeNaoFiscal');
    End;

    If iRet > 0 then
    begin
      If Tipo = 3 then
        lSangria := True
      Else
        lSangria := False;

      sRetAux := sPegaRet('CodNaoFiscal');
      sRet := RecebNFis( sRetAux, Valor, 'DINHEIRO' );
      Result := Copy(sRet,1,1);
    end
    else
    begin
      Application.MessageBox(PChar('Não foi possível realizar '+Forma+' pois o Totalizador Não Fiscal "'+Forma+
        '" não existe. Insira-o com o aplicativo da Urano após uma Redução Z."'),
        'Erro com o ECF', MB_OK + MB_ICONERROR);
      Result := '1';
    end;
  end;
  lSangria := False;
end;
//----------------------------------------------------------------------------
function TImpFiscalLoggerII.Gaveta:String;
var iRet : Integer;
begin
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('AbreGaveta');
  if iRet = 0 then
    Result := '0'
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.HorarioVerao( Tipo:String ):String;
var iRet : Integer;
begin
  if Tipo = '+' then
    Tipo := '1'
  else
    Tipo := '0';
  fLimpaParams(nHdlLogger);
  fAdicionaParam(nHdlLogger, 'EntradaHV', Tipo, G2_INTEGER);
  iRet := EnviaComando('AcertaHorarioVerao');
  if iRet = 0 then
    Result := '0'
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.RelatorioGerencial( Texto:String;Vias:Integer; ImgQrCode: String):String;
var i, iRet, iMax : Integer;
    lOk : Boolean;
begin
  lOk := True;
  fLimpaParams(nHdlLogger);
  fAdicionaParam(nHdlLogger, 'CodGerencial', '0', G2_INTEGER);
  iRet := EnviaComando('AbreGerencial');
  if iRet = 0 then
  begin
    // Executa impressao do texto em bloco de 492 caracteres
    i := 0;
    iMax := Length(Texto);
    while i <= iMax do
    begin
      fLimpaParams(nHdlLogger);
      fAdicionaParam(nHdlLogger, 'TextoLivre', RemoveChar(Copy(Texto,i,i+492)), G2_STRING);
      iRet := EnviaComando('ImprimeTexto');
      lOk := (iRet = 0);
      if not lOk then break;
      i := i+492;
    end;
    if lOk then
      Result := FechaCupomNaoFiscal
    else
    begin
      CancelaCupom('');
      Result := '1';
    end;
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalLoggerII.StatusImp( Tipo:Integer ):String;
var iRet : Integer;
    sRet : String;
    sDataMov : String;
    sDataHj : String;
    sCuponsEmitidos,sOperacoes,sGRG,sCDC,sDataUltDoc: String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - Obtem a Hora da Impressora
//  2 - Obtem a Data da Impressora
//  3 - Verifica o Papel
//  4 - Verifica se é possivel cancelar TODOS ou só o ULTIMO item registrado.
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
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware
// Faz a leitura da Hora
if Tipo = 1 then
begin
  iRet := LeRegistrador(G2_TIME, 'Hora');
  if iRet > 0 then
    Result := '0|'+sPegaRet('ValorHora')
  else
    Result := '1';
end
// Faz a leitura da Data
else if Tipo = 2 then
begin
  iRet := LeRegistrador(G2_DATE, 'Data');
  if iRet > 0 then
  begin
    sRet := sPegaRet('ValorData');
    Result := '0|'+Copy(sRet,1,6)+Copy(sRet,9,2);
  end
  else
    Result := '1';
end
// Faz a checagem de papel
else if Tipo = 3 then
begin
  // Verifica se está sem papel
  iRet := LeRegistrador(G2_BOOLEAN, 'SemPapel');
  if iRet > 0 then
    if bPegaRet() then
      Result := '3'
    else
    begin
      // Verifica se tem pouco papel
      iRet := LeRegistrador(G2_BOOLEAN, 'SensorPoucoPapel');
      if iRet > 0 then
        if bPegaRet() then
          Result := '2'
        else
          Result := '0';
    end;
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  Result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  iRet := LeRegistrador(G2_INTEGER, 'EstadoFiscal');
  if iRet > 0 then
    if iPegaRet() = 2 then
    Result := '7'
  else
    Result := '0';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
// *** FALTA IMPLEMENTAR ***
  Result := '0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
// *** FALTA IMPLEMENTAR ***
  Result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  Result := '0';
  iRet := LeRegistrador(G2_INTEGER, 'Indicadores');
  if iRet > 0 then
  begin
    iRet := iPegaRet();
    if iRet >= 16384 then iRet := iRet - 16384;   // MDF Esgotada
    if iRet >= 8192  then iRet := iRet - 8192;    // ECF em linha
    if iRet >= 4096  then iRet := iRet - 4096;    // Clichê carregado
    if iRet >= 2048  then iRet := iRet - 2048;    // Inscrições carregadas
    if iRet >= 1024  then iRet := iRet - 1024;    // Documento em emissão não foi encerrado
    if iRet >= 512   then iRet := iRet - 512;     // Mecanismo impressor não configurado
    if iRet >= 256   then iRet := iRet - 256;     // ECF sem papel
    if iRet >= 128   then                         // Redução Z pendente
      Result := '10';
  end;
end
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
begin
  Result := '1';
  iRet := LeRegistrador(G2_INTEGER, 'Indicadores');
  if iRet > 0 then
  begin
    iRet := iPegaRet();
    if (iRet >= 8192) And (iRet < 16384) then     // ECF em linha
      Result := '0';
  end;
end
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  Result := '0'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 Then
  Result := '1'
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
else if Tipo = 12 then
  Result := '1'
// 13 - Verifica se o ECF Arredonda o Valor do Item
else if Tipo = 13 then
  Result := '0'
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
else if Tipo = 14 then
begin
  // 0 - Fechada
  Result := '1';
  iRet := LeRegistrador(G2_BOOLEAN, 'SensorGaveta');
  if iRet > 0 then
    if Not bPegaRet() then
      Result := '0';
end
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
  Result := '1'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
  Result := '1'
// 17 - Verifica Venda Bruta (RICMS 01 - SC - ANEXO 09)
else if Tipo = 17 then
begin
  Result := '1';
  iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaBruta');
  if iRet > 0 then
  begin
    sRet := sPegaRet('ValorMoeda');
    sRet := StrTran(sRet, '.', '');
    Result := '0|' + sRet;
  end
  else
    Result := '1';
end
// 18 - Verifica Grande Total (RICMS 01 - SC - ANEXO 09)
else if Tipo = 18 then
begin
  Result := '1';
  iRet := LeRegistrador(G2_MONEY, 'GT');
  if iRet > 0 then
  begin
    sRet := sPegaRet('ValorMoeda');
    sRet := StrTran(sRet, '.', '');
    Result := '0|' + sRet;
  end
  else
    Result := '1';
end
// 19 - Retorna a data do movimento da impressora
else if Tipo = 19 then
begin
  Result := '1';
  iRet := LeRegistrador(G2_Date, 'DataAbertura');
  If iRet > 0 Then
  Begin
    sRet := sPegaRet('ValorData');
    sDataMov := Copy( sRet, 1, 6 )+ Copy( sRet, 9, 2 );
    sDataHj := Copy( StatusImp( 2 ), 3, 8 );
    If ( StrToDate( sDataMov ) < StrToDate( sDataHj ) ) AND ( StatusImp( 8 ) = '10' ) then    // reducao pendente
      Result := '0|' + sDataMov
    else
      Result := '2|' + sDataHj;
  End
  Else
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
      iRet := LeRegistrador(G2_INTEGER, 'CRZ');
      If iRet > 0 then
      begin
        ContadorCrz := FormataTexto(IntToStr(iPegaRet()),5,0,2);
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
    begin
      iRet := LeRegistrador(G2_STRING, 'NumeroSerieECF');
      If iRet > 0 then
        IndicaMFAdi := Copy(NumSerie,12,1)
      else
        exit;
    end;
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

  // 29 - Retorna a Data de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF - Urano não contempla essa informação(não obrigatória Ato Cotepe0608 Anexo VI)
  else if Tipo = 29 then
    Result := '0|' + DataIntEprom

  // 30 - Retorna o Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  else if Tipo = 30 then
    Result := '0|' + HoraIntEprom

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
        iRet := LeRegistrador(G2_MONEY, 'GT');

        If Not(iRet > 0) then Abort;//foi tratado com Try para evitar que apenas o último comando retorne 1

        GTFinal := sPegaRet('ValorMoeda');
        GTFinal := StrTran(GTFinal, '.', '');

        iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaBruta');

        If Not(iRet > 0) then Abort;//foi tratado com Try para evitar que apenas o último comando retorne 1

        VendaBrutaDia := sPegaRet('ValorMoeda');
        VendaBrutaDia := StrTran(VendaBrutaDia, '.', '');
      except
      end;

      If iRet > 0 then
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
      iRet := LeRegistrador(G2_MONEY, 'GT');

      If (iRet > 0) then
      begin
        GTFinal := sPegaRet('ValorMoeda');
        GTFinal := StrTran(GTFinal, '.', '');

        GTInicial := GTFinal;
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
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaBruta');
      If iRet > 0 then
      begin
        VendaBrutaDia := sPegaRet('ValorMoeda');
        VendaBrutaDia := StrTran(VendaBrutaDia, '.', '');

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
    iRet := LeRegistrador(G2_INTEGER, 'CCF');

    If iRet > 0 then
    begin
      sCuponsEmitidos := IntToStr(iPegaRet());
      Result := '0|' + sCuponsEmitidos
    end
    else
      Result := '1';
  end

  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  else if Tipo = 36 then
  begin
    iRet := LeRegistrador(G2_INTEGER, 'NFC');

    If iRet > 0 then
    begin
      sOperacoes := IntToStr(iPegaRet());
      Result := '0|' + sOperacoes
    end
    else
      Result := '1';
  end

  // 37 - Retorna o Contador Geral de Relatório Gerencial
  else if Tipo = 37 then
  begin
    iRet := LeRegistrador(G2_INTEGER, 'GRG');

    If iRet > 0 then
    begin
      sGRG := IntToStr(iPegaRet());
      Result := '0|' + sGRG
    end else
      Result := '1';
  end

  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  else if Tipo = 38 then
  begin
    iRet := LeRegistrador(G2_INTEGER, 'CDC');

    If iRet > 0 then
    begin
      sCDC := IntToStr(iPegaRet());
      Result := '0|' + sCDC
    end
    else
      Result := '1';
  end

  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  else if Tipo = 39 then
  begin
    iRet := LeRegistrador(G2_DATE, 'DataUltimoDoc');

    If iRet > 0 then
    begin
      sDataUltDoc := sPegaRet('ValorData');
      Result := '0|' + sDataUltDoc;
    end
    else
      Result := '1';
  end

  // 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CÓDIGOS DE IDENTIFICAÇÃO DE ECF
  else if Tipo = 40 then
    Result := '0|' + CodigoEcf
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
procedure TImpFiscalLoggerII.PulaLinha( iNumero:Integer );
begin
  fLimpaParams(nHdlLogger);
  fAdicionaParam(nHdlLogger, 'Avanco', IntToStr(iNumero), G2_INTEGER);
  EnviaComando('AvancaPapel');
end;

//----------------------------------------------------------------------------
procedure TImpFiscalLoggerII.AlimentaProperties;
var i,iRet,iMaxAliq : Integer;
    sAliq : String;
    sForma : String;
begin
  ICMS       := '';
  Aliquotas  := '';
  ISS        := '';
  FormasPgto := 'DINHEIRO|';
  lError         := False;

  // Retorna o índice da última aliquota cadastrada
  iRet := LeRegistrador(G2_INTEGER, 'AliquotaDisponivel');
  if iRet > 0 then
  begin
    iMaxAliq := iPegaRet()-1;
    If iMaxAliq > 15 then iMaxAliq := 15;
  end
  else
    Exit;

  for i := 0 to iMaxAliq do
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodAliquotaProgramavel', IntToStr(i), G2_INTEGER);
    iRet := EnviaComando('LeAliquota');
    if iRet > 0 then
    begin
      sAliq := sPegaRet('PercentualAliquota');
      if Length(sAliq) > 0 then
      begin
        sAliq := StrTran(sAliq,',','.');
        Aliquotas := Aliquotas + sAliq + '|';
        if sPegaRet('AliquotaICMS')='Y' then
          ICMS := ICMS + sAliq +'|'
        else
          ISS := ISS + sAliq +'|';
      end;
    end;
  end;
  // Elimina o ultimo Pipe '|'
  if Copy(Aliquotas,Length(Aliquotas),1)='|' then
    Aliquotas := Copy(Aliquotas,0,Length(Aliquotas)-1);
  if Copy(ICMS,Length(ICMS),1)='|' then
    ICMS := Copy(ICMS,0,Length(ICMS)-1);
  if Copy(ISS,Length(ISS),1)='|' then
    ISS := Copy(ISS,0,Length(ISS)-1);

  // Realiza a leitura das formas de pagamento
  for i := 0 to 14 do
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodMeioPagamentoProgram', IntToStr(i), G2_INTEGER);
    iRet := EnviaComando('LeMeioPagamento');
    if iRet > 0 then
    begin
      sForma := sPegaRet('NomeMeioPagamento');
      if Length(sForma) > 0 then
        FormasPgto := FormasPgto + sForma + '|'
    end;
  end;
  // Elimina o ultimo Pipe '|'
  if Copy(FormasPgto,Length(FormasPgto),1)='|' then
    FormasPgto := Copy(FormasPgto,0,Length(FormasPgto)-1);

  // Retorno do Numero do Caixa (PDV)
  iRet := LeRegistrador(G2_INTEGER, 'ECF');
  if iRet > 0 then
    PDV := FormataTexto(IntToStr(iPegaRet()),3,0,2)
  else
    exit;

  // Retorno da Versão do Firmware (Eprom)
  iRet := LeRegistrador(G2_STRING, 'VersaoSW');
  If iRet > 0 then
    Eprom := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna o CNPJ
  iRet := LeRegistrador(G2_STRING, 'CNPJ');
  If iRet > 0 then
    Cnpj := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna a IE
  iRet := LeRegistrador(G2_STRING, 'IE');
  If iRet > 0 then
    Ie := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna o Numero da loja cadastrado no ECF
  iRet := LeRegistrador(G2_INTEGER, 'Loja');
  If iRet > 0 then
    NumLoja := IntToStr(iPegaRet())
  else
    exit;

  // Retorna o Numero da Serie - Composto por 12 ou 21 posições, sendo a última(12º ou 21º) posição, a Letra Indicativa do MF Adicional, quando possuir memória adicional.
  iRet := LeRegistrador(G2_STRING, 'NumeroSerieECF');
  If iRet > 0 then
  begin
    NumSerie    := sPegaRet('ValorTexto');
    If Length(NumSerie) > 12 then
    begin
      IndicaMFAdi := Copy(NumSerie,20,1);
      NumSerie    := Copy(NumSerie,1,21);
    end else
    begin
      IndicaMFAdi := Copy(NumSerie,12,1);
      NumSerie    := Copy(NumSerie,1,11);
    end;
  end
  else
    exit;

  // Retorna o Tipo do ECF
  TipoEcf := 'ECF-IF';

  // Retorna Marca do ECF
  iRet := LeRegistrador(G2_STRING, 'Marca');
  If iRet > 0 then
    MarcaEcf := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna Modelo do ECF
  iRet := LeRegistrador(G2_STRING, 'Modelo');
  If iRet > 0 then
    ModeloEcf := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna Contador de Reinicio de Operação
  iRet := LeRegistrador(G2_INTEGER, 'CRO');
  If iRet > 0 then
    ContadorCro := IntToStr(iPegaRet())
  else
    exit;

  // Retorna Contador de ReduçãoZ
  iRet := LeRegistrador(G2_INTEGER, 'CRZ');
  If iRet > 0 then
    ContadorCrz := IntToStr(iPegaRet())
  else
    exit;

  // Retorna o valor Total Bruto Vendido até o momento do referido movimento
  iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaBruta');

  If iRet > 0 then
  begin
    VendaBrutaDia := sPegaRet('ValorMoeda');
    VendaBrutaDia := FormataTexto(StrTran(VendaBrutaDia,'.',''),15,2,1,'.')
  end
  else
    exit;

  // Retorna o valor do Grande Total da impressora
  iRet := LeRegistrador(G2_MONEY, 'GT');

  If iRet > 0 then
  begin
    GTFinal := sPegaRet('ValorMoeda');
    GTFinal := FormataTexto(StrTran(GtFinal,'.',''),15,2,1,'.')
  end
  else
    exit;

  // Calcula o Grande Total Inicial
  GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );
  GTInicial := FormataTexto(StrTran(GTInicial,'.',''),15,2,1,'.');

  Path := ExtractFilePath(Application.ExeName);
end;

//-----------------------------------------------------------
function TImpFiscalLoggerII.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
var iRet : Integer;
    sRet : String;
    sPedido,sTEFPedido,sCondicao:String;
    sErro,sTotNFiscal:String;
begin
  sPedido    := SigaLojaINI('URALOG2.INI','IFPedido', 'Pedido',    'RECEBER');
  sTEFPedido := SigaLojaINI('URALOG2.INI','IFPedido', 'TEFPedido', 'RECEBER');
  sCondicao  := SigaLojaINI('URALOG2.INI','IFPedido', 'Condicao',  'Dinheiro');

  fLimpaParams(nHdlLogger);
  if TEF = 'S' then
  begin
    sErro := sPedido;
    fAdicionaParam(nHdlLogger, 'NomeNaoFiscal', sPedido, G2_STRING);
  end
  else
  begin
    sErro := sTEFPedido;
    fAdicionaParam(nHdlLogger, 'NomeNaoFiscal', sTEFPedido, G2_STRING);
  end;
  iRet := EnviaComando('LeNaoFiscal');
  if iRet = -1 then
  begin
    Application.MessageBox(PChar('Não foi possível realizar a impressão do pedido pois o Totalizador Não Fiscal "'+sErro+
      '" não existe. Insira-o com o aplicativo da Urano após uma Redução Z."'),
      'Erro com o ECF', MB_OK + MB_ICONERROR);
    Result := '1';
    Exit;
  end;
  sTotNFiscal := sPegaRet('CodNaoFiscal');

  Valor := TrimLeft(TrimRight(Valor));
  Valor := StrTran(Valor,'.',',');
  // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if (Pos('.', Valor) = 0) And (Pos(',', Valor) = 0) then
  begin
    Valor := Trim(Valor);
    Valor := Copy(Valor,1,Length(Valor)-2)+','+Copy(Valor,Length(Valor)-1,2);
  end;
  sRet := RecebNFis(sTotNFiscal, Valor, sCondicao);
  if sRet = '0' then
  begin
    sRet := AbreCupomNaoFiscal(sCondicao, Valor, '2', Texto);
    if sRet = '0' then
    begin
      sRet := FechaCupomNaoFiscal;
    end
  end;
  Result := sRet;
end;

//-----------------------------------------------------------
function TImpFiscalLoggerII.RecebNFis( Totalizador, Valor, Forma:String ): String;
var iRet : Integer;
begin
  Valor := TrimLeft(TrimRight(Valor));
  Valor := StrTran(Valor,'.',',');
  // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if (Pos('.', Valor) = 0) And (Pos(',', Valor) = 0) then
  begin
    Valor := Trim(Valor);
    Valor := Copy(Valor,1,Length(Valor)-2)+','+Copy(Valor,Length(Valor)-1,2);
  end;
  // A variavel Totalizador pode receber o indice do totalizador ou o nome
  if StrToIntDef(Totalizador, 0) = 0 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'NomeNaoFiscal', Totalizador, G2_STRING);
    iRet := EnviaComando('LeNaoFiscal');
    if iRet > 0 then
    begin
      Totalizador := sPegaRet('CodNaoFiscal');
    end
    else
    begin
      Application.MessageBox(PChar('Não foi possível realizar '+Totalizador+' pois o Totalizador Não Fiscal "'+Totalizador+
        '" não existe. Insira-o com o aplicativo da Urano após uma Redução Z."'),
        'Erro com o ECF', MB_OK + MB_ICONERROR);
      Result := '1';
    end;
  end;
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('AbreCupomNaoFiscal');
  if iRet = 0 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodNaoFiscal', Totalizador, G2_INTEGER);
    fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
    iRet := EnviaComando('EmiteItemNaoFiscal');
    if iRet = 0 then
    begin
      fLimpaParams(nHdlLogger);
      If not lSangria Then
      Begin
        if UpperCase(Forma) = 'DINHEIRO' then
          fAdicionaParam(nHdlLogger, 'CodMeioPagamento', '-2', G2_INTEGER)
        else
        fAdicionaParam(nHdlLogger, 'NomeMeioPagamento', Forma, G2_STRING);
        fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
        iRet := EnviaComando('PagaCupom');
      end;
    End;
    if iRet = 0 then
      Result := FechaCupom('')
    else
    begin
      CancelaCupom('');
      Result := '1';
    end;
  end
  else
    Result := '1';
end;
//-----------------------------------------------------------------------------
function TImpFiscalLoggerII.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Var
  iRet          : Integer;
  bContinua     : Boolean;
  sValorRetorno : AnsiString ;
  sArq          : String;
  nHandle       : Integer;
  fArquivo      : TextFile;
  sRetorno      : String;
  sRestoString  : String;
Begin
  sRestoString  := '';
  sArq :=  PathArquivo + ArqDownTXT;

  If FileExists( sArq ) Then
    DeleteFile( sArq );

  fDefineTimeout(nHdlLogger, 30);
  nHandle := FileCreate( sArq );
  FileClose( nHandle );

  AssignFile( fArquivo, sArq );
  Rewrite( fArquivo );

  bContinua := True;
  Result := '1';
  fLimpaParams(nHdlLogger);
  If sTipo = '1' Then
  Begin
    fAdicionaParam(nHdlLogger, 'DataFinal', FormatDateTime('dd/mm/yyyy',StrToDate(sFinal)), G2_Date );
    fAdicionaParam(nHdlLogger, 'DataInicial', FormatDateTime('dd/mm/yyyy',StrToDate(sInicio)), G2_Date );
  End
  Else
  Begin
    fAdicionaParam(nHdlLogger, 'COOFinal', sFinal, G2_UNSIGNED_LONGINT );
    fAdicionaParam(nHdlLogger, 'COOInicial', sInicio, G2_UNSIGNED_LONGINT );
  End;

  fAdicionaParam(nHdlLogger, 'Destino', 'S', G2_STRING );
  iRet := EnviaComando('EmiteLeituraFitaDetalhe');


  If iRet = 0 Then
  Begin
    While bContinua Do
    Begin
      sValorRetorno := Space( 4000 );
      iRet := EnviaComando('LeImpressao');
      iRet := fRetorno(nHdlLogger, 0, 'TextoImpressao', 0, sValorRetorno, 4000);
      If Length( Trim( sValorRetorno ) ) < 3 Then
        bContinua := False;

      sValorRetorno := StrTran( sValorRetorno, 'Ç', 'Ã' );
      sValorRetorno := StrTran( sValorRetorno, '€', 'Ç' );
      sValorRetorno := StrTran( sValorRetorno, '‡', 'ç' );
      sValorRetorno := StrTran( sValorRetorno, 'Æ', 'ã' );
      sValorRetorno := StrTran( sValorRetorno, 'ä', 'õ' );
      sValorRetorno := StrTran( sValorRetorno, '¢', 'ó' );
      sValorRetorno := StrTran( sValorRetorno, 'µ', 'Á' );
      sValorRetorno := StrTran( sValorRetorno, 'Ö', 'Í' );
      sValorRetorno := StrTran( sValorRetorno, 'à', 'Ó' );
      sValorRetorno := StrTran( sValorRetorno, 'å', 'Õ' );
      sValorRetorno := StrTran( sValorRetorno, '¡', 'í' );
      sValorRetorno := StrTran( sValorRetorno, '', '' );
      sValorRetorno := StrTran( sValorRetorno, ' ', 'á' );
      sValorRetorno := StrTran( sValorRetorno, '', 'á' );
      sValorRetorno := StrTran( sValorRetorno, '‚', 'é' );

      if (sRestoString <> '') then
        sValorRetorno := sRestoString + sValorRetorno;

      sRestoString := '';
      While Trim( sValorRetorno ) <> '' Do
      Begin
        If Not( Pos( #10, sValorRetorno ) > 0 ) And (Length(sValorRetorno) < 48) And ( Pos( #0, sValorRetorno ) > 0 ) then
        begin
          sRestoString := Copy(sValorRetorno,1,Length(sValorRetorno)-1);
          sValorRetorno := '';
          continue;
        end;

        If ( Pos( #10, sValorRetorno ) > 0 ) And ( Pos( #10, sValorRetorno ) <= 48 )  Then
        Begin
          If Pos( #10, sValorRetorno ) < 48 Then
            sRetorno := Copy( sValorRetorno, 1, Pos( #10, sValorRetorno ) ) + Space( 48 - Pos( #10, sValorRetorno ) )
          Else
            sRetorno := Copy( sValorRetorno, 1, Pos( #10, sValorRetorno ) );

          sValorRetorno := Copy( sValorRetorno, Pos( #10, sValorRetorno ) + 1, Length( sValorRetorno ) );

          {Verif. se informação é ref. a Assinatura do arquivo e remove, assinatura é realizada na ADVPL}
          IF Pos('EAD',sRetorno) > 0 Then
            Continue;

          Writeln( fArquivo, sRetorno );
        End
        Else
        Begin
          sRetorno := Copy( sValorRetorno, 1, 48 );
          sValorRetorno := Copy( sValorRetorno, 49, Length( sValorRetorno ) );

          {Verif. se informação é ref. a Assinatura do arquivo e remove, assinatura é realizada na ADVPL}
          IF Pos('EAD',sRetorno) > 0 Then
            Continue;

          Writeln( fArquivo, sRetorno );
        End;
      End;
    End;
  End;

  Result := '0';
  CloseFile( fArquivo );
  fDefineTimeout(nHdlLogger, 15);
End;

//------------------------------------------------------------------------------
function TImpFiscalLoggerII.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Var
  iRet: integer;
  sArquivo,sPorta,sArqGerado: String;
  inteiro: Integer;
begin
  Result   := '1';
  sArquivo := ExtractFilePath(Application.ExeName) + 'URANO.MFD';

  sPorta   := Porta;
  if sPorta = 'EMUL' then
    sPorta := 'Emul';

  fEncerraDriver(nHdlLogger);
  iRet := fDLLReadLeMemorias(sPorta,sArquivo,NumSerie,'1');

  {Reinicia a conexão com a Porta}
  nHdlLogger := fIniciaDriver(sPorta);

  if nHdlLogger = -1 then
    ShowMessage('Erro na abertura da porta');

  If sBinario <> '1'  Then
  begin
    if sTipo = '1' Then
    begin
      sInicio := FormatDateTime('dd/mm/yyyy',StrToDate(sInicio));
      sFinal  := FormatDateTime('dd/mm/yyyy',StrToDate(sFinal));
    end;

    if iRet = 0 then
    begin
      //Padrão do PAF
      sArqGerado := UpperCase(PathArquivo + DEFAULT_PATHARQMFD + 'MFD' + NumSerie + '_' +
                        FormatDateTime('ddMMyyyy', Date) + '_' + FormatDateTime('hhmmss', Time)+'.txt');

      iRet := fDLLATO17GeraArquivo(sArquivo,sArqGerado,sInicio,sFinal,'D','0','MFD');

      if iRet = 0 then
        Result := '0';
    end;
  end;
end;
//----------------------------------------------------------------------------
function TImpFiscalLoggerII.LeTotNFisc:String;
var
   iRet, i : Integer;
  sTotaliz : String;

begin
  /// Inicialização de variaveis

   sTotaliz := ''; 
   i:= 0;
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodNaoFiscal', IntToStr(i), G2_INTEGER);
    iRet := EnviaComando('LeNaoFiscal');
  If iRet > 0 then
    begin
     Result := '0|';
  // Realiza a leitura dos Totalizadores não fiscais
     for i := 0 to 14 do
     begin
       fLimpaParams(nHdlLogger);
       fAdicionaParam(nHdlLogger, 'CodNaoFiscal', IntToStr(i), G2_INTEGER);
       iRet := EnviaComando('LeNaoFiscal');
       if iRet > 0 then
       begin
         sTotaliz := sPegaRet('NomeNaoFiscal');
         if Length(sTotaliz) > 0 then
          Result:= Result + Trim(FormataTexto( IntToStr(i+1), 2, 0, 4)) + ',' + Trim(sTotaliz)+ '|';
       end;
     end;
   end
   Else Result := '1|';
end;
//------------------------------------------------------------------------------
function TImpFiscalLoggerII.DownMF(sTipo, sInicio, sFinal : String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
Function TImpFiscalLoggerII.RedZDado(MapaRes:String):String;
begin
     Result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalLoggerII.ImpTxtFis(Texto : String) : String;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalLoggerII.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalLoggerII.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
var
  iRet : Integer;
  sRet : String;
begin

If LogDLL
then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now) + '-> EstornaCreditoDebito '));

fLimpaParams(nHdlLogger);
fAdicionaParam(nHdlLogger, 'COO', COOCDC , G2_INTEGER);
iRet := EnviaComando('EstornaCreditoDebito');

If LogDLL
then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now) + '<- EstornaCreditoDebito : ' + IntToStr(iRet)));

if iRet = 1 then
begin

 if LogDLL
 then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now) + '-> TextoNãoFical'));

 sRet := TextoNaoFiscal(Mensagem,1);

 If LogDLL
 then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now) + '<- TextoNãoFical : ' + sRet));

 If sRet = '0' then //Comando executado com sucesso
 begin
   if LogDLL
   then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now) + '-> FechaCupomNaoFiscal'));

   Result := FechaCupomNaoFiscal();

   If LogDLL
   then WriteLog('sigaloja.log', PChar(DateTimeToStr(Now) + '<- FechaCupomNaoFiscal : ' + sRet));

 end
 else Result := '1|';

end
else
 Result := '1|';

end;

//----------------------------------------------------------------------------
procedure TImpFiscalLoggerII_010008.AlimentaProperties;
const NUM_ALIQ_PROG = 15;
var i,iRet,iMaxAliq, nQtde : Integer;
    sAliq : String;
    sForma : String;
    strRetorno : String;
    aValorParam : array[0..2] of tipo_parametro;
begin
  ICMS       := '';
  Aliquotas  := '';
  ISS        := '';
  FormasPgto := '';

  for i := 0 to NUM_ALIQ_PROG do
  begin
    aValorParam[0].Nome:= 'AliquotaICMS';
    aValorParam[0].Conteudo:= '';
    aValorParam[0].Tipo:= G2_BOOLEAN;
    aValorParam[1].Nome:= 'CodAliquotaProgramavel';
    aValorParam[1].Conteudo:= IntToStr(i);
    aValorParam[1].Tipo:= G2_INTEGER;
    aValorParam[2].Nome:= 'PercentualAliquota';
    aValorParam[2].Conteudo:= '';
    aValorParam[2].Tipo:= G2_MONEY;
    iRet := Executa(nHdlLogger, 'LeAliquota', aValorParam);
    if(iRet=0) then
    begin
      sAliq := sPegaRet('PercentualAliquota');
      if Length(sAliq) > 0 then
      begin
        sAliq := StrTran(sAliq,',','.');
        Aliquotas := Aliquotas + sAliq + '|';
        if sPegaRet('AliquotaICMS')='Y' then
          ICMS := ICMS + sAliq +'|'
        else
          ISS := ISS + sAliq +'|';
      end;
    end
    else if (iRet <> 8005) then
    begin
      ShowMessage('Erro código: '+IntToStr(iRet));
      Exit;
    end;
  end;
  // Elimina o ultimo Pipe '|'
  if Copy(Aliquotas,Length(Aliquotas),1)='|' then
    Aliquotas := Copy(Aliquotas,0,Length(Aliquotas)-1);
  if Copy(ICMS,Length(ICMS),1)='|' then
    ICMS := Copy(ICMS,0,Length(ICMS)-1);
  if Copy(ISS,Length(ISS),1)='|' then
    ISS := Copy(ISS,0,Length(ISS)-1);

  // Realiza a leitura das formas de pagamento
  for i := 0 to 14 do
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodMeioPagamentoProgram', IntToStr(i), G2_INTEGER);
    iRet := EnviaComando('LeMeioPagamento');
    if iRet > 0 then
    begin
      sForma := sPegaRet('NomeMeioPagamento');
      if Length(sForma) > 0 then
        FormasPgto := FormasPgto + sForma + '|'
    end;
  end;
  // Elimina o ultimo Pipe '|'
  if Copy(FormasPgto,Length(FormasPgto),1)='|' then
    FormasPgto := Copy(FormasPgto,0,Length(FormasPgto)-1);

  // Retorno do Numero do Caixa (PDV)
  iRet := LeRegistrador(G2_INTEGER, 'ECF');
  if iRet > 0 then
    PDV := FormataTexto(IntToStr(iPegaRet()),3,0,2)
  else
    exit;

  // Retorno da Versão do Firmware (Eprom)
  iRet := LeRegistrador(G2_STRING, 'VersaoSW');
  If iRet > 0 then
    Eprom := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna o CNPJ
  iRet := LeRegistrador(G2_STRING, 'CNPJ');
  If iRet > 0 then
    Cnpj := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna a IE
  iRet := LeRegistrador(G2_STRING, 'IE');
  If iRet > 0 then
    Ie := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna o Numero da loja cadastrado no ECF
  iRet := LeRegistrador(G2_INTEGER, 'Loja');
  If iRet > 0 then
    NumLoja := IntToStr(iPegaRet())
  else
    exit;


  // Retorna o Numero da Serie - Composto por 12 posições, sendo a última(12º) a Letra Indicativa do MF Adicional
  iRet := LeRegistrador(G2_STRING, 'NumeroSerieECF');
  If iRet > 0 then
  begin
    NumSerie    := sPegaRet('ValorTexto');
    IndicaMFAdi := Copy(NumSerie,12,1);
    NumSerie    := Copy(NumSerie,1,11);
  end
  else
    exit;

  // Retorna o Tipo do ECF
  TipoEcf := 'ECF-IF';

  // Retorna Marca do ECF
  iRet := LeRegistrador(G2_STRING, 'Marca');
  If iRet > 0 then
    MarcaEcf := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna Modelo do ECF
  iRet := LeRegistrador(G2_STRING, 'Modelo');
  If iRet > 0 then
    ModeloEcf := sPegaRet('ValorTexto')
  else
    exit;

  // Retorna Contador de Reinicio de Operação
  iRet := LeRegistrador(G2_INTEGER, 'CRO');
  If iRet > 0 then
    ContadorCro := IntToStr(iPegaRet())
  else
    exit;

  // Retorna Contador de ReduçãoZ
  iRet := LeRegistrador(G2_INTEGER, 'CRZ');
  If iRet > 0 then
    ContadorCrz := IntToStr(iPegaRet())
  else
    exit;

  // Retorna o valor Total Bruto Vendido até o momento do referido movimento
  iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaBruta');

  If iRet > 0 then
  begin
    VendaBrutaDia := sPegaRet('ValorMoeda');
    VendaBrutaDia := FormataTexto(StrTran(VendaBrutaDia,'.',''),15,2,1,'.')
  end
  else
    exit;

  // Retorna o valor do Grande Total da impressora
  iRet := LeRegistrador(G2_MONEY, 'GT');

  If iRet > 0 then
  begin
    GTFinal := sPegaRet('ValorMoeda');
    GTFinal := FormataTexto(StrTran(GtFinal,'.',''),15,2,1,'.')
  end
  else
    exit;

  // Calcula o Grande Total Inicial
  GTInicial     := Trim( FloatToStr( StrToFloat( GTFinal ) - StrToFloat( VendaBrutaDia ) ) );
  GTInicial := FormataTexto(StrTran(GTInicial,'.',''),15,2,1,'.');

  Path := ExtractFilePath(Application.ExeName);
end;

//------------------------------------------------------------------------------
function TImpFiscalQuickWay.RecebNFis( Totalizador, Valor, Forma:String ): String;
var iRet : Integer;
begin
  Valor := TrimLeft(TrimRight(Valor));
  Valor := StrTran(Valor,'.',',');
  // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if (Pos('.', Valor) = 0) And (Pos(',', Valor) = 0) then
  begin
    Valor := Trim(Valor);
    Valor := Copy(Valor,1,Length(Valor)-2)+','+Copy(Valor,Length(Valor)-1,2);
  end;
  // A variavel Totalizador pode receber o indice do totalizador ou o nome
  if StrToIntDef(Totalizador, 0) = 0 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'NomeNaoFiscal', Totalizador, G2_STRING);
    iRet := EnviaComando('LeNaoFiscal');
    if iRet > 0 then
    begin
      Totalizador := sPegaRet('CodNaoFiscal');
    end
    else
    begin
      Application.MessageBox(PChar('Não foi possível realizar '+Totalizador+' pois o Totalizador Não Fiscal "'+Totalizador+
        '" não existe. Insira-o com o aplicativo da Urano após uma Redução Z."'),
        'Erro com o ECF', MB_OK + MB_ICONERROR);
      Result := '1';
    end;
  end;
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('AbreCupomNaoFiscal');
  if iRet = 0 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodNaoFiscal', Totalizador, G2_INTEGER);
    fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
    iRet := EnviaComando('EmiteItemNaoFiscal');
    if iRet = 0 then
    begin
      fLimpaParams(nHdlLogger);
      if UpperCase(Forma) = 'DINHEIRO' then
        fAdicionaParam(nHdlLogger, 'CodMeioPagamento', '-2', G2_INTEGER)
      else
        fAdicionaParam(nHdlLogger, 'NomeMeioPagamento', Forma, G2_STRING);
      fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
      iRet := EnviaComando('PagaCupom');
      if iRet = 0 then
        Result := FechaCupom('')
      else
      begin
        CancelaCupom('');
        Result := '1';
      end;
    end
    else
    begin
      CancelaCupom('');
      Result := '1';
    end;
  end
  else
    Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalQuickWayV05.RecebNFis( Totalizador, Valor, Forma:String ): String;
var iRet : Integer;
begin
  Valor := TrimLeft(TrimRight(Valor));
  Valor := StrTran(Valor,'.',',');

    // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if (Pos('.', Valor) = 0) And (Pos(',', Valor) = 0) then
  begin
    Valor := Trim(Valor);
    Valor := Copy(Valor,1,Length(Valor)-2)+','+Copy(Valor,Length(Valor)-1,2);
  end;

  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('AbreCupomNaoFiscal');

  if iRet = 0 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodNaoFiscal', Totalizador, G2_INTEGER);
    fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
    iRet := EnviaComando('EmiteItemNaoFiscal');

    if iRet = 0 then
    begin
      fLimpaParams(nHdlLogger);

       If not lSangria Then
        Begin
         if UpperCase(Forma) = 'DINHEIRO' then
             fAdicionaParam(nHdlLogger, 'CodMeioPagamento', '-2', G2_INTEGER)
         else
             fAdicionaParam(nHdlLogger, 'NomeMeioPagamento', Forma, G2_STRING);
             fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
             iRet := EnviaComando('PagaCupom');
         end;

      if iRet = 0 then
        Result := FechaCupom('')
      else
      begin
        CancelaCupom('');
        Result := '1';
      end;
    end
    else
    begin
      CancelaCupom('');
      Result := '1';
    end;
  end
  else
    Result := '1';
end;

//------------------------------------------------------------------------------
Function TImpFiscal2EFC.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
Var
  iRet  : Integer;
  iVz   : Integer;
Begin
  Result := '1';
  iVz := 1;
  fLimpaParams( nHdlLogger );
  fAdicionaParam( nHdlLogger, 'TempoEspera', '30', G2_INTEGER);
  fAdicionaParam( nHdlLogger, 'TextoAutenticacao', Texto, G2_STRING);

  While Vezes >= iVz Do
  Begin
    iRet := EnviaComando( 'ImprimeAutenticacao' );
    iVz := iVz + 1;
  End;
  Sleep( 3000 );
  If iRet = 0 then
    Result := '0';
End;
//---------------------     CHEQUE        --------------------------------------
Function TImpCheque2EFC.Abrir( aPorta:String ) : Boolean;
Begin
  If Not bOpened Then
    Result := (Copy(OpenLoggerII( aPorta, ''  ),1,1) = '0')
  Else
    Result := True;

  fSetaArquivoLog( ExtractFilePath(Application.ExeName) + 'urano.log' );
End;
//------------------------------------------------------------------------------
function TImpCheque2EFC.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
Begin
  Result := False;
End;
//------------------------------------------------------------------------------
function TImpCheque2EFC.Fechar(aPorta:String ): Boolean;
Begin
  CloseLoggerII;
  Result := True;
End;
//------------------------------------------------------------------------------
function TImpCheque2EFC.StatusCh( Tipo:Integer ):String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
end;
//------------------------------------------------------------------------------
Function TImpCheque2EFC.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
Var
  iRet          : Integer;
  fArquivo      : TIniFile;
  nTam          : Integer;
  sMensagem     : String;
  sPath         : String;
  sData         : String;
  sDataAux      : String;
  nVezes        : Integer;
Begin
  nTam := 0;
  Result := False;
  If Trim( Mensagem ) <> '' Then
    StrPCopy( Mensagem, sMensagem );
  sData := StrPas( Data );
  sData := Trim( sData );
  nVezes := 1;
  While nVezes <= 2 Do
  Begin
    sDataAux := sDataAux + Copy( sData, Length( sData ) - 1, Length( sData ) ) + '/';
    sData := Copy( sData, 1, Length( sData ) - 2 );
    nVezes := nVezes + 1;
  End;
  sDataAux := sDataAux + sData;

  If Not FileExists( ExtractFilePath( Application.Name ) + 'CHEQUES.INI' ) Then
  Begin
    ShowMessage( 'Arquivo CHEQUES.INI não localizado no \BIN\REMOTE.' );
    Result := False;
  End
  Else
  Begin
    sPath := ExtractFilePath(Application.ExeName);
    fArquivo := TIniFile.Create(sPath+'CHEQUES.INI');
    If fArquivo.SectionExists( Banco ) Then
    Begin
      fLimpaParams( nHdlLogger );
      fAdicionaParam( nHdlLogger, 'Cidade',             StrPas( Cidade ), G2_STRING );
      fAdicionaParam( nHdlLogger, 'Data',               sDataAux, G2_DATE );
      fAdicionaParam( nHdlLogger, 'Favorecido',         StrPas( Favorec ), G2_STRING);
      fAdicionaParam( nHdlLogger, 'HPosAno',            fArquivo.ReadString( Banco, 'HPosAno', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosCidade',         fArquivo.ReadString( Banco, 'HPosCidade', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosDia',            fArquivo.ReadString( Banco, 'HPosDia', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosExtensoLinha1',  fArquivo.ReadString( Banco, 'HPosExtensoLinha1', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosExtensoLinha2',  fArquivo.ReadString( Banco, 'HPosExtensoLinha2', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosFavorecido',     fArquivo.ReadString( Banco, 'HPosFavorecido', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosMes',            fArquivo.ReadString( Banco, 'HPosMes', '0' ) , G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosMsgLinha1',      fArquivo.ReadString( Banco, 'HPosMsgLinha1', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosMsgLinha2',      fArquivo.ReadString( Banco, 'HPosMsgLinha2', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosMsgLinha3',      fArquivo.ReadString( Banco, 'HPosMsgLinha3', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'HPosValor',          fArquivo.ReadString( Banco, 'HPosValor', '0' ), G2_INTEGER );

      If Trim( sMensagem ) <> '' Then
      Begin
        fAdicionaParam( nHdlLogger, 'MensagemDocLinha1', Copy( sMensagem, 1, 80 ), G2_INTEGER );
        sMensagem := Copy( sMensagem , 81, Length( sMensagem ) );
        fAdicionaParam( nHdlLogger, 'MensagemDocLinha2', Copy( sMensagem, 1, 80 ), G2_INTEGER );
        sMensagem := Copy( sMensagem, 81, Length( sMensagem ) );
        fAdicionaParam( nHdlLogger, 'MensagemDocLinha3', Copy( sMensagem, 1, 80 ), G2_INTEGER );
        sMensagem := Copy( sMensagem, 81, Length( sMensagem ) );
      End;

      fAdicionaParam( nHdlLogger, 'TempoEspera',        '120', G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'Valor',              Valor, G2_MONEY );
      fAdicionaParam( nHdlLogger, 'VPosCidade',         fArquivo.ReadString( Banco, 'VPosCidade', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'VPosExtensoLinha1',  fArquivo.ReadString( Banco, 'VPosExtensoLinha1', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'VPosExtensoLinha2',  fArquivo.ReadString( Banco, 'VPosExtensoLinha2', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'VPosFavorecido',     fArquivo.ReadString( Banco, 'VPosFavorecido', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'VPosMsgLinha1',      fArquivo.ReadString( Banco, 'VPosMsgLinha1', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'VPosMsgLinha2',      fArquivo.ReadString( Banco, 'VPosMsgLinha2', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'VPosMsgLinha3',      fArquivo.ReadString( Banco, 'VPosMsgLinha3', '0' ), G2_INTEGER );
      fAdicionaParam( nHdlLogger, 'VPosValor',          fArquivo.ReadString( Banco, 'VPosValor', '0' ), G2_INTEGER );

      iRet := EnviaComando( 'ImprimeCheque' );
      If iRet = 0 Then
      Begin
        Sleep( 12000 );         // Espera 20 segundos antes de liberar o sistema
        Result := True;
      End;
    End;
  End;
End;


//----------------------------------------------------------------------------
function TImpFiscalTermoprinterTPF1004.StatusImp( Tipo:Integer ):String;
var iRet : Integer;
    sRet : String;
    sDataMov : String;
    sDataHj : String;
    sCuponsEmitidos,sOperacoes,sGRG,sCDC,sDataUltDoc: String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - Obtem a Hora da Impressora
//  2 - Obtem a Data da Impressora
//  3 - Verifica o Papel
//  4 - Verifica se é possivel cancelar TODOS ou só o ULTIMO item registrado.
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
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware

// Faz a leitura da Hora
if Tipo = 1 then
begin
  iRet := LeRegistrador(G2_TIME, 'Hora');
  if iRet > 0 then
    Result := '0|'+sPegaRet('ValorHora')
  else
    Result := '1';
end
// Faz a leitura da Data
else if Tipo = 2 then
begin
  iRet := LeRegistrador(G2_DATE, 'Data');
  if iRet > 0 then
  begin
    sRet := sPegaRet('ValorData');
    Result := '0|'+Copy(sRet,1,6)+Copy(sRet,9,2);
  end
  else
    Result := '1';
end
// Faz a checagem de papel
else if Tipo = 3 then
begin
  // Verifica se está sem papel
  iRet := LeRegistrador(G2_BOOLEAN, 'SemPapel');
  if iRet > 0 then
    if bPegaRet() then
      Result := '3'
    else
    begin
      // Verifica se tem pouco papel
      iRet := LeRegistrador(G2_BOOLEAN, 'SensorPoucoPapel');
      if iRet > 0 then
        if bPegaRet() then
          Result := '2'
        else
          Result := '0';
    end;
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  Result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  iRet := LeRegistrador(G2_INTEGER, 'EstadoFiscal');
  if iRet > 0 then
    if iPegaRet() = 2 then
    Result := '7'
  else
    Result := '0';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
// *** FALTA IMPLEMENTAR ***
  Result := '0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
// *** FALTA IMPLEMENTAR ***
  Result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  Result := '0';
  iRet := LeRegistrador(G2_INTEGER, 'Indicadores');
  if iRet > 0 then
  begin
    iRet := iPegaRet();
    if iRet >= 32768 then iRet := iRet - 32768;   // Retorno desconhecido
    if iRet >= 16384 then iRet := iRet - 16384;   // MDF Esgotada
    if iRet >= 8192  then iRet := iRet - 8192;    // ECF em linha
    if iRet >= 4096  then iRet := iRet - 4096;    // Clichê carregado
    if iRet >= 2048  then iRet := iRet - 2048;    // Inscrições carregadas
    if iRet >= 1024  then iRet := iRet - 1024;    // Documento em emissão não foi encerrado
    if iRet >= 512   then iRet := iRet - 512;     // Mecanismo impressor não configurado
    if iRet >= 256   then iRet := iRet - 256;     // ECF sem papel
    if iRet >= 128   then                         // Redução Z pendente
      Result := '10';
  end;
end
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
begin
  Result := '1';
  iRet := LeRegistrador(G2_INTEGER, 'Indicadores');
  if iRet > 0 then
  begin
    iRet := iPegaRet();
    If StatusProssegue(iRet) Then
        Result := '0'
    Else
        Result := '1'
    End;
end
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  Result := '0'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 Then
  Result := '1'
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
else if Tipo = 12 then
  Result := '1'
// 13 - Verifica se o ECF Arredonda o Valor do Item
else if Tipo = 13 then
  Result := '0'
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
else if Tipo = 14 then
begin
  // 0 - Fechada
  Result := '1';
  iRet := LeRegistrador(G2_BOOLEAN, 'SensorGaveta');
  if iRet > 0 then
    if Not bPegaRet() then
      Result := '0';
end
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
  Result := '1'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
  Result := '1'
// 17 - Verifica Venda Bruta (RICMS 01 - SC - ANEXO 09)
else if Tipo = 17 then
begin
  Result := '1';
  iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaBruta');
  if iRet > 0 then
  begin
    sRet := sPegaRet('ValorMoeda');
    sRet := StrTran(sRet, '.', '');
    Result := '0|' + sRet;
  end
  else
    Result := '1';
end
// 18 - Verifica Grande Total (RICMS 01 - SC - ANEXO 09)
else if Tipo = 18 then
begin
  Result := '1';
  iRet := LeRegistrador(G2_MONEY, 'GT');
  if iRet > 0 then
  begin
    sRet := sPegaRet('ValorMoeda');
    sRet := StrTran(sRet, '.', '');
    Result := '0|' + sRet;
  end
  else
    Result := '1';
end
// 19 - Retorna a data do movimento da impressora
else if Tipo = 19 then
begin
  Result := '1';
  iRet := LeRegistrador(G2_Date, 'DataAbertura');
  If iRet > 0 Then
  Begin
    sRet := sPegaRet('ValorData');
    sRet := '12/08/2010';
    sDataMov := Copy( sRet, 1, 6 )+ Copy( sRet, 9, 2 );
    sDataHj := Copy( StatusImp( 2 ), 3, 8 );
    If ( StrToDate( sDataMov ) < StrToDate( sDataHj ) ) AND ( StatusImp( 8 ) = '10' ) then    // reducao pendente
      Result := '0|' + sDataMov
    else
      Result := '2|' + sDataHj;
  End
  Else
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
      iRet := LeRegistrador(G2_INTEGER, 'CRZ');
      If iRet > 0 then
      begin
        ContadorCrz := FormataTexto(IntToStr(iPegaRet()),5,0,2);
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
    begin
      iRet := LeRegistrador(G2_STRING, 'NumeroSerieECF');
      If iRet > 0 then
        IndicaMFAdi := Copy(NumSerie,12,1)
      else
        exit;
    end;
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

  // 29 - Retorna a Data de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF - Urano não contempla essa informação(não obrigatória Ato Cotepe0608 Anexo VI)
  else if Tipo = 29 then
    Result := '0|' + DataIntEprom

  // 30 - Retorna o Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  else if Tipo = 30 then
    Result := '0|' + HoraIntEprom

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
        iRet := LeRegistrador(G2_MONEY, 'GT');

        If Not(iRet > 0) then Abort;//foi tratado com Try para evitar que apenas o último comando retorne 1

        GTFinal := sPegaRet('ValorMoeda');
        GTFinal := StrTran(GTFinal, '.', '');

        iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaBruta');

        If Not(iRet > 0) then Abort;//foi tratado com Try para evitar que apenas o último comando retorne 1

        VendaBrutaDia := sPegaRet('ValorMoeda');
        VendaBrutaDia := StrTran(VendaBrutaDia, '.', '');
      except
      end;

      If iRet > 0 then
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
      iRet := LeRegistrador(G2_MONEY, 'GT');

      If (iRet > 0) then
      begin
        GTFinal := sPegaRet('ValorMoeda');
        GTFinal := StrTran(GTFinal, '.', '');

        GTInicial := GTFinal;
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
      iRet := LeRegistrador(G2_MONEY, 'TotalDiaVendaBruta');
      If iRet > 0 then
      begin
        VendaBrutaDia := sPegaRet('ValorMoeda');
        VendaBrutaDia := StrTran(VendaBrutaDia, '.', '');

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
    iRet := LeRegistrador(G2_INTEGER, 'CCF');

    If iRet > 0 then
    begin
      sCuponsEmitidos := IntToStr(iPegaRet());
      Result := '0|' + sCuponsEmitidos
    end
    else
      Result := '1';
  end

  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  else if Tipo = 36 then
  begin
    iRet := LeRegistrador(G2_INTEGER, 'NFC');

    If iRet > 0 then
    begin
      sOperacoes := IntToStr(iPegaRet());
      Result := '0|' + sOperacoes
    end
    else
      Result := '1';
  end

  // 37 - Retorna o Contador Geral de Relatório Gerencial
  else if Tipo = 37 then
  begin
    iRet := LeRegistrador(G2_INTEGER, 'GRG');

    If iRet > 0 then
    begin
      sGRG := IntToStr(iPegaRet());
      Result := '0|' + sGRG
    end else
      Result := '1';
  end

  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  else if Tipo = 38 then
  begin
    iRet := LeRegistrador(G2_INTEGER, 'CDC');

    If iRet > 0 then
    begin
      sCDC := IntToStr(iPegaRet());
      Result := '0|' + sCDC
    end
    else
      Result := '1';
  end

  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  else if Tipo = 39 then
  begin
    iRet := LeRegistrador(G2_DATE, 'DataUltimoDoc');

    If iRet > 0 then
    begin
      sDataUltDoc := sPegaRet('ValorData');
      Result := '0|' + sDataUltDoc;
    end
    else
      Result := '1';
  end

  // 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CÓDIGOS DE IDENTIFICAÇÃO DE ECF
  else if Tipo = 40 then
    Result := '0|' + CodigoEcf
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


//-----------------------------------------------------------
function TImpFiscalTermoprinterTPF1004.RecebNFis( Totalizador, Valor, Forma:String ): String;
var iRet : Integer;
begin
  Valor := TrimLeft(TrimRight(Valor));
  Valor := StrTran(Valor,'.',',');
  // Trata os valores enviados.
  // O valor R$ 10,00 pode ser enviado como "000000000001000" ou "10.00"
  if (Pos('.', Valor) = 0) And (Pos(',', Valor) = 0) then
  begin
    Valor := Trim(Valor);
    Valor := Copy(Valor,1,Length(Valor)-2)+','+Copy(Valor,Length(Valor)-1,2);
  end;
  // A variavel Totalizador pode receber o indice do totalizador ou o nome
  if StrToIntDef(Totalizador, 0) = 0 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'NomeNaoFiscal', Totalizador, G2_STRING);
    iRet := EnviaComando('LeNaoFiscal');
    if iRet > 0 then
    begin
      Totalizador := sPegaRet('CodNaoFiscal');
    end
    else
    begin
      Application.MessageBox(PChar('Não foi possível realizar '+Totalizador+' pois o Totalizador Não Fiscal "'+Totalizador+
        '" não existe. Insira-o com o aplicativo da Urano após uma Redução Z."'),
        'Erro com o ECF', MB_OK + MB_ICONERROR);
      Result := '1';
    end;
  end;
  fLimpaParams(nHdlLogger);
  iRet := EnviaComando('AbreCupomNaoFiscal');
  if iRet = 0 then
  begin
    fLimpaParams(nHdlLogger);
    fAdicionaParam(nHdlLogger, 'CodNaoFiscal', Totalizador, G2_INTEGER);
    fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
    iRet := EnviaComando('EmiteItemNaoFiscal');
    if iRet = 0 then
    begin
      fLimpaParams(nHdlLogger);
      if UpperCase(Forma) = 'DINHEIRO' then
        fAdicionaParam(nHdlLogger, 'CodMeioPagamento', '-2', G2_INTEGER)
      else
        fAdicionaParam(nHdlLogger, 'NomeMeioPagamento', Forma, G2_STRING);
      fAdicionaParam(nHdlLogger, 'Valor', Valor, G2_MONEY);
      iRet := EnviaComando('PagaCupom');
    End;
    if iRet = 0 then
      Result := FechaCupom('')
    else
    begin
      CancelaCupom('');
      Result := '1';
    end;
  end
  else
    Result := '1';
end;
//-----------------------------------------------------------------------------


//******************  Funcoes Genericas ****************************************
procedure TrataRetornoUrano(iRet: integer);
var
  sMsgRetorno: String;
begin
  sMsgRetorno := '';
  case iRet of
       1     : sMsgRetorno := 'ErroGeralFaltaRAM|Não foi possível alocar mais memória.';
       2     : sMsgRetorno := 'ErroGeralPerdaRAM|Memória RAM foi corrompida.';
       1000  : sMsgRetorno := 'ErroMFDesconectada|Memória Fiscal foi desconectada.';
       1001  : sMsgRetorno := 'ErroMFLeitura|Erro de leitura na Memória Fiscal.';
       1002  : sMsgRetorno := 'ErroMFApenasLeitura|Memória está setada apenas para leitura.';
       1003  : sMsgRetorno := 'ErroMFTamRegistro|Registro fora dos padrões (erro interno).';
       1004  : sMsgRetorno := 'ErroMFCheia|Memória Fiscal está lotada.';
       1005  : sMsgRetorno := 'ErroMFCartuchosExcedidos|Número máximo de cartuchos excedidos.';
       1006  : sMsgRetorno := 'ErroMFJaInicializada|Tentativa de gravar novo modelo de ECF.';
       1007  : sMsgRetorno := 'ErroMFNaoInicializada|Tentativa de gravação de qualquer dado antes da inicialização da Memória Fiscal.';
       1008  : sMsgRetorno := 'ErroMFUsuariosExcedidos|Número máximo de usuários foi atingido.';
       1009  : sMsgRetorno := 'ErroMFIntervencoesExcedidas|Número máximo de intervenções foi atingido.';
       1010  : sMsgRetorno := 'ErroMFVersoesExcedidas|Número máximo de versões foi atingido.';
       1011  : sMsgRetorno := 'ErroMFReducoesExcedidas|Número máximo de reduções foi atingido.';
       1012  : sMsgRetorno := 'ErroMFGravacao|Erro na gravação de registro na memória fiscal';
       2000  : sMsgRetorno := 'ErroTransactDrvrLeitura|Erro de leitura no dispositivo físico.';
       2001  : sMsgRetorno := 'ErroTransactDrvrEscrita|Erro de leitura no dispositivo.';
       2002  : sMsgRetorno := 'ErroTransactDrvrDesconectado|Dispositivo de transações foi desconectado.';
       3000  : sMsgRetorno := 'ErroTransactRegInvalido|Tipo de registro a ser gravado inválido.';
       3001  : sMsgRetorno := 'ErroTransactCheio|Registro de transações está esgotado.';
       3002  : sMsgRetorno := 'ErroTransactTransAberta|Tentativa de abrir nova transação com transação já aberta.';
       3003  : sMsgRetorno := 'ErroTransactTransNaoAberta|Tentativa de fechar uma transação que não se encontrava aberta.';
       4000  : sMsgRetorno := 'ErroContextDrvrLeitura|Erro de leitura no dispositivo físico.';
       4001  : sMsgRetorno := 'ErroContextDrvrEscrita|Erro de escrita no dispositivo.';
       4002  : sMsgRetorno := 'ErroContextDrvrDesconectado|Dispositivo de contexto foi desconectado.';
       4003  : sMsgRetorno := 'ErroContextDrvrLeituraAposFim|Leitura após final do arquivo.';
       4004  : sMsgRetorno := 'ErroContextDrvrEscritaAposFim|Escrita após final do arquivo.';
       5000  : sMsgRetorno := 'ErroContextVersaoInvalida|Versão de contexto fiscal no dispositivo não foi reconhecida.';
       5001  : sMsgRetorno := 'ErroContextCRC|CRC do dispositivo está incorreto.';
       5002  : sMsgRetorno := 'ErroContextLimitesExcedidos|Tentativa de escrita fora da área de contexto.';
       6000  : sMsgRetorno := 'ErroRelogioInconsistente|Relógio do ECF inconsistente.';
       6001  : sMsgRetorno := 'ErroRelogioDataHoraInvalida|Data/hora informadas não estão consistentes.';
       7000  : sMsgRetorno := 'ErroPrintSemMecanismo|Nenhum mecanismo de impressão presente.';
       7001  : sMsgRetorno := 'ErroPrintDesconectado|Atual mecanismo de impressão está desconectado.';
       7002  : sMsgRetorno := 'ErroPrintCapacidadeInexistente|Mecanismo não possui capacidade suficiente para realizar esta operação.';
       7003  : sMsgRetorno := 'ErroPrintSemPapel|Impressora está sem papel para imprimir.';
       7004  : sMsgRetorno := 'ErroPrintFaltouPapel|Faltou papel durante a impressão do comando.';
       8000  : sMsgRetorno := 'ErroCMDForaDeSequencia|Comando fora de seqüência.';
       8001  : sMsgRetorno := 'ErroCMDCodigoInvalido|Código mercadoria não válido.';
       8002  : sMsgRetorno := 'ErroCMDDescricaoInvalida|Descrição inválida.';
       8003  : sMsgRetorno := 'ErroCMDQuantidadeInvalida|Quantidade inválida.';
       8004  : sMsgRetorno := 'ErroCMDAliquotaInvalida|Índice da alíquota não válido.';
       8005  : sMsgRetorno := 'ErroCMDAliquotaNaoCarregada|Alíquota não carregada.';
       8006  : sMsgRetorno := 'ErroCMDValorInvalido|Valor contém caracter inválido.';
       8007  : sMsgRetorno := 'ErroCMDMontanteOperacao|Total da operação igual a 0 (zero).';
       8008  : sMsgRetorno := 'ErroCMDAliquotaIndisponivel|Alíquota não disponível para carga.';
       8009  : sMsgRetorno := 'ErroCMDValorAliquotaInvalido|Valor da alíquota não válido.';
       8010  : sMsgRetorno := 'ErroCMDTrocaSTAposFechamento|Troca de situação tributária somente após Redução Z.';
       8011  : sMsgRetorno := 'ErroCMDFormaPagamentoInvalida|Índice do Meio de Pagamento não válido.';
       8012  : sMsgRetorno := 'ErroCMDPayIndisponivel|Meio de Pagamento indisponível para carga.';
       8013  : sMsgRetorno := 'ErroCMDCupomTotalizadoEmZero|Cupom totalizado em 0 (zero).';
       8014  : sMsgRetorno := 'ErroCMDFormaPagamentoIndefinida|Meio de Pagamento não definido.';
       8015  : sMsgRetorno := 'ErroCMDTrocaUsuarioAposFechamento|Carga de usuário permitido somente após Redução Z.';
       8016  : sMsgRetorno := 'ErroCMDSemMovimento|Dia sem movimento.';
       8017  : sMsgRetorno := 'ErroCMDPagamentoIncompleto|Total pago inferior ao total do cupom.';
       8018  : sMsgRetorno := 'ErroCMDGerencialNaoDefinido|Gerencial não definido.';
       8019  : sMsgRetorno := 'ErroCMDGerencialInvalido|Índice do Gerencial fora da faixa.';
       8020  : sMsgRetorno := 'ErroCMDGerencialIndisponivel|Gerencial não disponível para carga.';
       8021  : sMsgRetorno := 'ErroCMDNomeGerencialInvalido|Nome do Gerencial inválido.';
       8022  : sMsgRetorno := 'ErroCMDNaoHaMaisRelatoriosLivres|Esgotado número de Gerenciais.';
       8023  : sMsgRetorno := 'ErroCMDAcertoHVPermitidoAposZ|Acerto do horário de verão somente após a Redução Z.';
       8024  : sMsgRetorno := 'ErroCMDHorarioVeraoJaRealizado|Já acertou horário de verão.';
       8025  : sMsgRetorno := 'ErroCMDAliquotasIndisponiveis|Sem Alíquotas disponíveis para carga.';
       8026  : sMsgRetorno := 'ErroCMDItemInexistente|Item não vendido no cupom.';
       8027  : sMsgRetorno := 'ErroCMDQtdCancInvalida|Quantidade a ser cancelada maior do que a quantidade vendida.';
       8028  : sMsgRetorno := 'ErroCMDCampoCabecalhoInvalido|Cabeçalho possui campo(s) inválido(s).';
       8029  : sMsgRetorno := 'ErroCMDNomeDepartamentoInvalido|Nome do Departamento não válido.';
       8030  : sMsgRetorno := 'ErroCMDDepartamentoNaoEncontrado|Departamento não encontrado.';
       8031  : sMsgRetorno := 'ErroCMDDepartamentoIndefinido|Departamento não definido.';
       8032  : sMsgRetorno := 'ErroCMDFormasPagamentosIndisponiveis|Não há Meio de Pagamento disponível.';
       8033  : sMsgRetorno := 'ErroCMDAltPagamentoSoAposZ|Alteração de Meio de Pagamento somente após a Redução Z.';
       8034  : sMsgRetorno := 'ErroCMDNomeNaoFiscalInvalido|Nome do Documento Não Fiscal não pode ser vazio.';
       8035  : sMsgRetorno := 'ErroCMDDocsNaoFiscaisIndisponiveis|Não há mais Documentos Não Fiscais disponíveis.';
       8036  : sMsgRetorno := 'ErroCMDNaoFiscalIndisponivel|Documento Não Fiscal indisponível para carga.';
       8037  : sMsgRetorno := 'ErroCMDReducaoInvalida|Número da redução inicial inválida.';
       8038  : sMsgRetorno := 'ErroCMDCabecalhoJaImpresso|Cabeçalho do documento já foi impresso.';
       8039  : sMsgRetorno := 'ErroCMDLinhasSuplementaresExcedidas|Número máximo de linhas de propaganda excedidas.';
       8040  : sMsgRetorno := 'ErroCMDHorarioVeraoJaAtualizado|Relógio já está no estado desejado.';
       8041  : sMsgRetorno := 'ErroCMDValorAcrescimoInvalido|Valor do acréscimo inconsistente.';
       8042  : sMsgRetorno := 'ErroCMDNaoHaMeiodePagamento|Não há meio de pagamento definido.';
       8043  : sMsgRetorno := 'ErroCMDCOOVinculadoInvalido|COO do documento vinculado inválido.';
       8044  : sMsgRetorno := 'ErroCMDIndiceItemInvalido|Índice do item inexistente no contexto.';
       8045  : sMsgRetorno := 'ErroCMDCodigoNaoEncontrado|Código de item não encontrado no cupom atual.';
       8046  : sMsgRetorno := 'ErroCMDPercentualDescontoInvalido|Percentual do desconto ultrapassou 100%.';
       8047  : sMsgRetorno := 'ErroCMDDescontoItemInvalido|Desconto do item inválido.';
       8048  : sMsgRetorno := 'ErroCMDFaltaDefinirValor|Falta definir valor percentual ou absoluto em operação de desconto/acréscimo.';
       8049  : sMsgRetorno := 'ErroCMDItemCancelado|Tentativa de operação sobre item cancelado.';
       8050  : sMsgRetorno := 'ErroCMDCancelaAcrDescInvalido|Cancelamento de acréscimo/desconto inválidos.';
       8051  : sMsgRetorno := 'ErroCMDAcrDescInvalido|Operação de acréscimo/desconto inválida.';
       8052  : sMsgRetorno := 'ErroCMDNaoHaMaisDepartamentosLivres|Número de Departamentos esgotados.';
       8053  : sMsgRetorno := 'ErroCMDIndiceNaoFiscalInvalido|Índice de Documento Não Fiscal fora da faixa.';
       8054  : sMsgRetorno := 'ErroCMDTrocaNaoFiscalAposZ|Troca de Documento Não Fiscal somente após a Redução Z.';
       8055  : sMsgRetorno := 'ErroCMDInscricaoInvalida|CNPJ e/ou Inscrição Estadual inválida(s).';
       8056  : sMsgRetorno := 'ErroCMDVinculadoParametrosInsuficientes|Falta(m) parâmetro(s) no comando de abertura de Comprovante Crédito ou Débito.';
       8057  : sMsgRetorno := 'ErroCMDNaoFiscalIndefinido|Código e Nome do Documento Não Fiscal indefinidos.';
       8058  : sMsgRetorno := 'ErroCMDFaltaAliquotaVenda|Alíquota não definida no comando de venda.';
       8059  : sMsgRetorno := 'ErroCMDFaltaMeioPagamento|Código e Nome do Meio de Pagamento não definidos.';
       8060  : sMsgRetorno := 'ErroCMDFaltaParametro|Parâmetro de comando não informado.';
       8061  : sMsgRetorno := 'ErroCMDNaoHaDocNaoFiscaisDefinidos|Não há Documentos Não Fiscais definidos.';
       8062  : sMsgRetorno := 'ErroCMDOperacaoJaCancelada|Acréscimo/Desconto de item já cancelado.';
       8063  : sMsgRetorno := 'ErroCMDNaoHaAcrescDescItem|Não há acréscimo/desconto em item.';
       8064  : sMsgRetorno := 'ErroCMDItemAcrescido|Item já possui acréscimo.';
       8065  : sMsgRetorno := 'ErroCMDOperSoEmICMS|Operação de acréscimo em item ou subtotal só é valido para ICMS';
       8066  : sMsgRetorno := 'ErroCMDFaltaInformarValor|Valor do Comprovante Crédito ou Débito não informado.';
       8067  : sMsgRetorno := 'ErroCMDCOOInvalido|COO inválido.';
       8068  : sMsgRetorno := 'ErroCMDIndiceInvalido|Índice do Meio de Pagamento no cupom inválido.';
       8069  : sMsgRetorno := 'ErroCMDCupomNaoEncontrado|Documento Não Fiscal não encontrado.';
       8070  : sMsgRetorno := 'ErroCMDSequenciaPagamentoNaoEncontrada|Seqüência de pagamento não encontrada no cupom.';
       8071  : sMsgRetorno := 'ErroCMDPagamentoNaoPermiteCDC|Meio de pagamento não permite CDC.';
       8072  : sMsgRetorno := 'ErroCMDUltimaFormaPagamentoInv|Valor insuficiente para pagar o cupom.';
       8073  : sMsgRetorno := 'ErroCMDMeioPagamentoNEncontrado|Meio de pagamento origem ou destino não encontrado no último cupom emitido';
       8074  : sMsgRetorno := 'ErroCMDValorEstornoInvalido|Valor a ser estornado inválido';
       8075  : sMsgRetorno := 'ErroCMDMeiosPagamentoOrigemDestinoIguais|Meio de pagamento de origem e de destino são iguais.';
       8076  : sMsgRetorno := 'ErroCMDPercentualInvalido|Percentual da alíquota inválido.';
       8077  : sMsgRetorno := 'ErroCMDNaoHouveOpSubtotal|Não houve operação em subtotal para ser cancelada.';
       8078  : sMsgRetorno := 'ErroCMDOpSubtotalInvalida|Operação em subtotal inválida';
       8079  : sMsgRetorno := 'ErroCMDTextoAdicional|Erro no comando de Texto Adicional';
       8080  : sMsgRetorno := 'ErroCMDPrecoUnitarioInvalido|Preço unitário inválido';
       8081  : sMsgRetorno := 'ErroCMDDepartamentoInvalido|Departamento inválido';
       8082  : sMsgRetorno := 'ErroCMDDescontoInvalido|Desconto inválido.';
       8083  : sMsgRetorno := 'ErroCMDPercentualAcrescimoInvalido|Percentual de acréscimo inválido.';
       8084  : sMsgRetorno := 'ErroCMDAcrescimoInvalido|Valor do acréscimo inválido.';
       8085  : sMsgRetorno := 'ErroCMDNaoHouveVendaEmICMS|Cupom sem venda em alíquota de ICMS.';
       8086  : sMsgRetorno := 'ErroCMDCancelamentoInvalido|Cancelamento inválido.';
       8087  : sMsgRetorno := 'ErroCMDCliche|Comando de carga de clichê inválido';
       8088  : sMsgRetorno := 'ErroCMDNaoHouveVendaNaoFiscal|Não houve venda de item não fiscal';
       8089  : sMsgRetorno := 'ErroCMDDataInvalida|Data inválida.';
       8090  : sMsgRetorno := 'ErroCMDHoraInvalida|Hora inválida.';
       8091  : sMsgRetorno := 'ErroCMDEstorno|Erro no comando de Estorno de Meio de Pagamento';
       8092  : sMsgRetorno := 'ErroCMDAcertoRelogio|Erro no comando de acerto de relógio';
       8093  : sMsgRetorno := 'ErroCMDCDCInvalido|Comando de CDC inválido';
       8094  : sMsgRetorno := 'ErroCMDSenhaInvalida|Senha inválida para inicialização do proprietário.';
       8095  : sMsgRetorno := 'ErroCMDMecanismoCheque|Erro gerado pelo mecanismo de cheques';
       8096  : sMsgRetorno := 'ErroFaltaIniciarDia|Comando válido somente após a abertura do dia';
       8097  : sMsgRetorno := 'ErroCMDTotalizadorExcedido|Totalizador teve seu valor máximo excedido';
       9000  : sMsgRetorno := 'ErroMFDNenhumCartuchoVazio|Não foi encontrado nenhum cartucho de dados vazio para ser inicializado.';
       9001  : sMsgRetorno := 'ErroMFDCartuchoInexistente|Cartucho com o número de série informado não foi encontrado.';
       9002  : sMsgRetorno := 'ErroMFDNumSerie|Número de série do ECF é inválido na inicialização.';
       9003  : sMsgRetorno := 'ErroMFDCartuchoDesconectado|Cartucho de MFD desconectado ou com problemas.';
       9004  : sMsgRetorno := 'ErroMFDEscrita|Erro de escrita no dispositivo de MFD.';
       9005  : sMsgRetorno := 'ErroMFDSeek|Erro na tentativa de posicionar ponteiro de leitura.';
       9006  : sMsgRetorno := 'ErroMFDBadBadSector|Endereço do Bad Sector informado é inválido.';
       9007  : sMsgRetorno := 'ErroMFDLeitura|Erro de leitura na MFD.';
       9008  : sMsgRetorno := 'ErroMFDLeituraAlemEOF|Tentativa de leitura além dos limites da MFD.';
       9009  : sMsgRetorno := 'ErroMFDEsgotada|MFD não possui mais espaço para escrita.';
       9010  : sMsgRetorno := 'ErroMFDLeituraInterrompida|Leitura da MFD serial é interrompida por comando diferente de LeImpressao';
       10000 : sMsgRetorno := 'ErroBNFEstadoInvalido|Estado inválido para registro sendo codificado.';
       10001 : sMsgRetorno := 'ErroBNFParametroInvalido|Inconsistência nos parâmetros lidos no Logger.';
       10002 : sMsgRetorno := 'ErroBNFRegistroInvalido|Registro inválido detectado no Logger.';
       10003 : sMsgRetorno := 'ErroBNFErroMFD|Erro interno.';
       11000 : sMsgRetorno := 'ErroProtParamInvalido|Parâmetro repassado ao comando é inválido.';
       11001 : sMsgRetorno := 'ErroProtParamSintaxe|Erro de sintaxe na lista de parâmetros.';
       11002 : sMsgRetorno := 'ErroProtParamValorInvalido|Valor inválido para parâmetro do comando.';
       11003 : sMsgRetorno := 'ErroProtParamStringInvalido|String contém seqüência de caracteres inválidos.';
       11004 : sMsgRetorno := 'ErroProtParamRedefinido|Parâmetro foi declarado 2 ou mais vezes na lista.';
       11005 : sMsgRetorno := 'ErroProtParamIndefinido|Parâmetro obrigatório ausente na lista.';
       11006 : sMsgRetorno := 'ErroProtComandoInexistente|Não existe o comando no protocolo.';
       11007 : sMsgRetorno := 'ErroProtSequenciaComando|Estado atual não permite a execução deste comando.';
       11008 : sMsgRetorno := 'ErroProtAborta2aVia|Sinalização indicando que comando aborta a impressão da segunda via.';
       11009 : sMsgRetorno := 'ErroProtSemRetorno|Sinalização indicando que comando não possui retorno.';
       11010 : sMsgRetorno := 'ErroProtTimeout|Tempo de execução esgotado.';
       11011 : sMsgRetorno := 'ErroProtNomeRegistrador|Nome de registrador inválido.';
       11012 : sMsgRetorno := 'ErroProtTipoRegistrador|Tipo de registrador inválido.';
       11013 : sMsgRetorno := 'ErroProtSomenteLeitura|Tentativa de escrita em registrador de apenas leitura.';
       11014 : sMsgRetorno := 'ErroProtSomenteEscrita|Tentativa de leitura em registrador de apenas escrita.';
       11015 : sMsgRetorno := 'ErroProtComandoDiferenteAnterior|Comando recebido diferente do anterior no buffer de recepção.';
       11016 : sMsgRetorno := 'ErroProtFilaCheia|Fila de comandos cheia.';
       11017 : sMsgRetorno := 'ErroProtIndiceRegistrador|Índice de registrador indexado fora dos limites.';
       11018 : sMsgRetorno := 'ErroProtNumEmissoesExcedido|Número de emissões do Logger foi excedido na Intervenção Técnica.';
       11019 : sMsgRetorno := 'ErroMathDivisaoPorZero|Divisão por 0 (zero) nas rotinas de BDC.';
       15001 : sMsgRetorno := 'ErroApenasIntTecnica|Comando aceito apenas em modo de Intervencao Técnica.';
       15002 : sMsgRetorno := 'ErroECFIntTecnica|Comando não pode ser executado em modo de Intervenção Técnica.';
       15003 : sMsgRetorno := 'ErroMFDPresente|Já existe MFD presente neste ECF.';
       15004 : sMsgRetorno := 'ErroSemMFD|Não existe MFD neste ECF.';
       15005 : sMsgRetorno := 'ErroRAMInconsistente|Memória RAM do ECF não está consistente.';
       15006 : sMsgRetorno := 'ErroMemoriaFiscalDesconectada|Memória fiscal não encontrada.';
       15007 : sMsgRetorno := 'ErroDiaFechado|Dia já fechado.';
       15008 : sMsgRetorno := 'ErroDiaAberto|Dia aberto.';
       15009 : sMsgRetorno := 'ErroZPendente|Falta reducao Z.';
       15010 : sMsgRetorno := 'ErroMecanismoNaoConfigurado|Mecanismo impressor não selecionado.';
       15011 : sMsgRetorno := 'ErroSemPapel|Sem bobina de papel na estação de documento fiscal.';
       15012 : sMsgRetorno := 'ErroDocumentoEncerrado|Tentativa de finalizar documento já encerrado.';
       15013 : sMsgRetorno := 'ErroSemSinalDTR|Não há sinal de DTR.';
       15014 : sMsgRetorno := 'ErroSemInscricoes|Sem inscrições do usuário no ECF.';
       15015 : sMsgRetorno := 'ErroSemCliche|Sem dados do proprietário no ECF.';
       15016 : sMsgRetorno := 'ErroEmLinha|ECF encontra-se indevidamente em linha.';
       15017 : sMsgRetorno := 'ErroForaDeLinha|ECF não encontra-se em linha para executar o comando.';
       15018 : sMsgRetorno := '|ErroMecanismoBloqueado	Mecanismo está indisponível para impressão.';
       15019 : sMsgRetorno := 'ErroGabineteAberto|Gabinete do ECF foi aberto';
  end;

  if sMsgRetorno <> '' then
  begin
    lError := True;
    Application.MessageBox(PChar(Copy(sMsgRetorno,Pos('|',sMsgRetorno)+1,Length(sMsgRetorno))),PChar('Erro: '+IntToStr(iRet)+' com o ECF'), MB_OK + MB_ICONERROR);
  end;
end;
//------------------------------------------------------------------------------
Function OpenLoggerII( sPorta:String; sImpressora:String  ) : String;
  function ValidPointer( sDll:String ;aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ' + sDLL);
      Result := False;
    end
    else
      Result := True;
  end;

var aFunc: Pointer;
    bRet : Boolean;
    sDLL, sDLLLeitura, sDLLAto17 : String;

    pPath : PChar;
    sPath : String;
    ret: Integer;
begin
  sDLL        := 'DLLG2.DLL';
  sDLLLeitura := 'LEITURA.DLL';
  sDLLAto17   := 'ATO17.DLL';

  pPath := StrAlloc(100);
  GetSystemDirectory(pPath, 100);
  sPath := StrPas(pPath);
  StrDispose(pPath);
  if Not (Copy(sPath,Length(sPath),1) = '\') then
    sPath := sPath+'\';

  if Not FileExists(sPath+sDLL) then
  begin
    Application.MessageBox(PChar('Não foi possível localizar a DLLG2.DLL. Instale-a no diretório '+sPath+'.'),
      'Erro de Configuração', MB_OK + MB_ICONERROR);
    Result := '1|';
    Exit;
  end;

  if Not FileExists(sPath+sDLLLeitura) then
  begin
    Application.MessageBox(PChar('Não foi possível localizar a '+sDLLLeitura+'. Instale-a no diretório '+sPath+'.'),
      'Erro de Configuração', MB_OK + MB_ICONERROR);
    Result := '1|';
    Exit;
  end;

  if Not FileExists(sPath+sDLLAto17) then
  begin
    Application.MessageBox(PChar('Não foi possível localizar a '+sDLLAto17+'. Instale-a no diretório '+sPath+'.'),
      'Erro de Configuração', MB_OK + MB_ICONERROR);
    Result := '1|';
    Exit;
  end;

  if Not bOpened then
  begin
    fHandle := LoadLibrary('DLLG2.DLL'); //LoadLibrary(PChar(sDLL));
    if (fHandle <> 0) then
    begin
      bRet := True;
      aFunc := GetProcAddress(fHandle,'DLLG2_Versao');
      if ValidPointer( sDLL, aFunc, 'DLLG2_Versao' ) then
        fVersao := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_IniciaDriver');
      if ValidPointer( sDLL, aFunc, 'DLLG2_IniciaDriver' ) then
        fIniciaDriver := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_EncerraDriver');
      if ValidPointer( sDLL, aFunc, 'DLLG2_EncerraDriver' ) then
        fEncerraDriver := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_ConfiguraDriver');
      if ValidPointer( sDLL, aFunc, 'DLLG2_ConfiguraDriver' ) then
        fConfiguraDriver := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_SetaArquivoLog');
      if ValidPointer( sDLL, aFunc, 'DLLG2_SetaArquivoLog' ) then
        fSetaArquivoLog := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_ObtemNomeLog');
      if ValidPointer( sDLL, aFunc, 'DLLG2_ObtemNomeLog' ) then
        fObtemNomeLog := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_DefineTimeout');
      if ValidPointer( sDLL, aFunc, 'DLLG2_DefineTimeout' ) then
        fDefineTimeout := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_LeTimeout');
      if ValidPointer( sDLL, aFunc, 'DLLG2_LeTimeout' ) then
        fLeTimeout := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_LimpaParams');
      if ValidPointer( sDLL, aFunc, 'DLLG2_LimpaParams' ) then
        fLimpaParams := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_AdicionaParam');
      if ValidPointer( sDLL, aFunc, 'DLLG2_AdicionaParam' ) then
        fAdicionaParam := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_ListaParams');
      if ValidPointer( sDLL, aFunc, 'DLLG2_ListaParams' ) then
        fListaParams := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_ExecutaComando');
      if ValidPointer( sDLL, aFunc, 'DLLG2_ExecutaComando' ) then
        fExecutaComando := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_LeRegistrador');
      if ValidPointer( sDLL, aFunc, 'DLLG2_LeRegistrador' ) then
        fLeRegistrador := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_ObtemCodErro');
      if ValidPointer( sDLL, aFunc, 'DLLG2_ObtemCodErro' ) then
        fObtemCodErro := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_ObtemNomeErro');
      if ValidPointer( sDLL, aFunc, 'DLLG2_ObtemNomeErro' ) then
        fObtemNomeErro := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_ObtemCircunstancia');
      if ValidPointer( sDLL, aFunc, 'DLLG2_ObtemCircunstancia' ) then
        fObtemCircunstancia := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_ObtemRetornos');
      if ValidPointer( sDLL, aFunc, 'DLLG2_ObtemRetornos' ) then
        fObtemRetornos := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_TotalRetornos');
      if ValidPointer( sDLL, aFunc, 'DLLG2_TotalRetornos' ) then
        fTotalRetornos := aFunc
      else
      begin
        bRet := False;
      end;

      aFunc := GetProcAddress(fHandle,'DLLG2_Retorno');
      if ValidPointer( sDLL, aFunc, 'DLLG2_Retorno' ) then
        fRetorno := aFunc
      else
      begin
        bRet := False;
      end;
    End
    else
    begin
        ShowMessage('O arquivo DLLG2.DLL não foi encontrado.');
        bRet := False;
    end;

    if bRet and (fHandle <> 0) then
    begin
      bRet := True;
      aFunc := GetProcAddress(LoadLibrary(PChar(sDLLLeitura)),'DLLReadLeMemorias');
      if ValidPointer( sDLLLeitura, aFunc, 'DLLReadLeMemorias' ) then
        fDLLReadLeMemorias := aFunc
      else
      begin
        bRet := False;
      end;
    End;

    if bRet and (fHandle <> 0) then
    begin
      bRet := True;
      aFunc := GetProcAddress(LoadLibrary(PChar(sDLLAto17)),'DLLATO17GeraArquivo');
      if ValidPointer( sDLLAto17, aFunc, 'DLLATO17GeraArquivo' ) then
        fDLLATO17GeraArquivo := aFunc
      else
      begin
        bRet := False;
      end;
    End;

    if bRet then
    begin

      Result := '0|';
      if sPorta = 'EMUL' then
        sPorta := 'Emul';

      nHdlLogger := fIniciaDriver( sPorta );

      if nHdlLogger = -1 then
         bRet := False;
      if not bRet then
      begin
        ShowMessage('Erro na abertura da porta');
        Result := '1|';
      end
      else
      begin
        // Com um timeout menor, a Leitura X retorna erro.
        // Caso necessário, pode-se aumentar este valor.
        fDefineTimeout(nHdlLogger, 15);
        bOpened := True;
      end;
    end
    else
    begin
      Result := '1|';
    end;
  end;
end;
//------------------------------------------------------------------------------
function CloseLoggerII : String;
begin
  Result := '0';
  if bOpened then
  begin
     if (fHandle <> INVALID_HANDLE_VALUE) then
     begin
       if fEncerraDriver(nHdlLogger) = -1 then
       begin
         Application.MessageBox('Não foi possível fechar a comunicação com a impressora fiscal',
           'Erro de execução', MB_OK + MB_ICONERROR);
          Result := '1';
       end;
       FreeLibrary(fHandle);
       fHandle := 0;
     end;
     bOpened:= False;
  end;
end;

//------------------------------------------------------------------------------
function EnviaComando(sComando:String):LongInt;
var iRet:Integer;
    sMsg:String;
begin
  iRet := fExecutaComando(nHdlLogger, sComando);

  if iRet = -1 then
  begin
    Application.MessageBox('fExecutaComando - Comando não executado',
      'Erro na função EnviaComando', MB_OK + MB_ICONERROR);
    Result := -1;
    lError := True;
    Exit;
  end;
  if iRet = 0 then
  begin
    Application.MessageBox('fExecutaComando - Comando em execução',
      'Erro na função EnviaComando', MB_OK + MB_ICONERROR);
    Result := -1;
    lError := True;
    Exit;
  end;
  iRet := fObtemCodErro(nHdlLogger);
  if iRet = 0 then
  begin
    iRet := fTotalRetornos(nHdlLogger);
    if iRet = -1 then
    begin
      Application.MessageBox('fTotalRetornos(nHdlLogger)=-1',
        'Erro inesperado na função EnviaComando', MB_OK + MB_ICONERROR);
      lError := True;
    end;
    Result := iRet;
  end
  else
  begin
    if iRet = 11010 then
    begin
      Application.MessageBox('Verifique se o ECF está on-line.',
        'Erro com o ECF', MB_OK + MB_ICONERROR);
      lError := True;
    end
    else
    if ((sComando = 'LeMeioPagamento') And (iRet = 8014)) Or
       ((sComando = 'LeNaoFiscal') And (iRet = 8057)) Or
       ((sComando = 'LeAliquota') And (iRet = 8005)) Or
       ((sComando = 'AbreCreditoDebito') And (iRet = 8000)) Or
       ((sComando = 'AbreCreditoDebito') And (iRet = 8068)) Or
       ((sComando = 'AbreCreditoDebito') And (iRet = 8071)) then
    else  TrataRetornoUrano(iRet);
    Result := -1;
  end;
end;
//------------------------------------------------------------------------------
function sPegaRet(sNomeRetorno:String):String;
var iRet:Integer;
    sValorRetorno:String;
begin
  sValorRetorno := Space(50);
  iRet := fRetorno(nHdlLogger, 0, sNomeRetorno, 0, sValorRetorno, 50);
  If LogDLL Then
    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' -> sNomeRetorno: ' + IntToStr(iRet) ));
  if iRet = -1 then
  begin
    Result := '';
  end;
  if iRet > 0 then
  begin
    If LogDLL Then
      WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Result: ' + Copy(sValorRetorno, 0, Pos(#0,sValorRetorno)-1) ));
    Result := Copy(sValorRetorno, 0, Pos(#0,sValorRetorno)-1);
  end;
end;

function bPegaRet:Boolean;
begin
  Result := False;
  if Pos(sPegaRet('ValorNumericoIndicador'), 'YyTt1') > 0 then
    Result := True;
end;

function iPegaRet:LongInt;
begin
  Result := StrToInt(sPegaRet('ValorInteiro'));
end;

//------------------------------------------------------------------------------
function LeRegistrador(nTipo:LongInt; sValorParam:String):LongInt;
var sComando, sNomeParam : String;
    iRet:Integer;
begin
  if nTipo = G2_STRING then
  begin
    sNomeParam := 'NomeTexto';
    sComando   := 'LeTexto';
  end
  else if nTipo = G2_DATE then
  begin
    sNomeParam := 'NomeData';
    sComando   := 'LeData';
  end
  else if nTipo = G2_TIME then
  begin
    sNomeParam := 'NomeHora';
    sComando   := 'LeHora';
  end
  else if nTipo = G2_BOOLEAN then
  begin
    sNomeParam := 'NomeIndicador';
    sComando   := 'LeIndicador';
  end
  else if nTipo = G2_MONEY then
  begin
    sNomeParam := 'NomeDadoMonetario';
    sComando   := 'LeMoeda';
  end
  else if (nTipo = G2_INTEGER) Or (nTipo = G2_LONGINT) then
  begin
    sNomeParam := 'NomeInteiro';
    sComando   := 'LeInteiro';
  end
  else
    ShowMessage('LeRegistrador: Retorno ainda não implementado');

  fLimpaParams(nHdlLogger);
  fAdicionaParam(nHdlLogger, sNomeParam, sValorParam, G2_STRING);
  iRet := EnviaComando(sComando);
  Result := iRet;
end;

//------------------------------------------------------------------------------
function Executa(nHdlLogger: integer; strComando: string; aParametros: array of tipo_parametro): integer;
var
  nLin  : integer;
  lCodErro : Longint;
begin
  fLimpaParams(nHdlLogger);
  for nLin:= 0 to High(aParametros) do
  begin
    if(not IsEmpty(aParametros[nLin].Conteudo)) then
      fAdicionaParam(nHdlLogger, aParametros[nLin].Nome, aParametros[nLin].Conteudo, Integer(aParametros[nLin].Tipo));
  end;
  VerificaErro(fExecutaComando(nHdlLogger, strComando),lCodErro);
  result := lCodErro;
end;

//------------------------------------------------------------------------------
function IsEmpty( str: string): boolean;
begin
  result := true;
  if( str <> '') then
    result := false;
end;

//------------------------------------------------------------------------------
Function VerificaErro( lRetorno: Longint; var lCodErro: Longint): Boolean;
begin
    VerificaErro := False;
    lCodErro := 0;
    If (lRetorno > 0) Then
    begin
      lCodErro := fObtemCodErro(nHdlLogger);
      if(lCodErro > 0) then
        VerificaErro := True;
    End;
end;

//------------------------------------------------------------------------------
Function StatusProssegue( nValor: Integer): Boolean;
var
   cMensagem : String;
   lBloqueiaOperacao : Boolean;

begin
   lBloqueiaOperacao := False;

   if (nValor >= 16384) then
   begin
      //Indicador Valor MFD Esgotada está ativo
      cMensagem := cMensagem + 'MFD Esgotada' + Chr(13) + Chr(10);
      nValor := nValor - 16384;
      lBloqueiaOperacao := True;
   end;

   if (nValor >= 8192) then
   begin
      //Indicador Em Linha está ativo. Não é aplicado na 3202DT
      //cMensagem := cMensagem + 'Mecanismo... OK' + Chr(13) + Chr(10);
      nValor := nValor - 8192;
   end;

   If (nValor >= 4096) Then
   begin
      //Indicador FLAG_CLICHE_OK está ativo
      //cMensagem := cMensagem + 'Cliche... OK' + Chr(13) + Chr(10);
      nValor := nValor - 4096;
   end;

   if (nValor >= 2048) then
   begin
      //Indicador FLAG_INSCRICOES_OK está ativo
      //cMensagem := cMensagem + 'Inscrições... OK' + Chr(13) + Chr(10);
      nValor := nValor - 2048;
   end;

   if (nValor >= 1024) then
   begin
     //Indicador FLAG_DOCUMENTO_ABERTO está ativo
     cMensagem := cMensagem + 'Existe um documento aberto' + Chr(13) + Chr(10);
     nValor := nValor - 1024;
   end;

   if (nValor >= 512) then
   begin
      //Indicador FLAG_MECANISMO_NOK está ativo
      cMensagem := cMensagem + 'Mecanismo impressor não configurado.' + Chr(13) + Chr(10);
      nValor := nValor - 512;
      lBloqueiaOperacao := True;
   end;

   if (nValor >= 256) then
   begin
      //Indicador FLAG_SEM_PAPEL está ativo
      cMensagem := cMensagem + 'Sem papel na estação de cupom fiscal.' + Chr(13) + Chr(10);
      nValor := nValor - 256;
      lBloqueiaOperacao := True;
   end;

   if (nValor >= 128) then
   begin
      //Indicador FLAG_Z_PENDENTE está ativo
      cMensagem := cMensagem + 'Redução Z Pendente' + Chr(13) + Chr(10);
      nValor := nValor - 128;
      // BloqueiaOperacao := True; (Verificar)
   end;

   if (nValor >= 64) then
   begin
      //Indicador FLAG_DIA_ABERTO está ativo
      //cMensagem := cMensagem + 'Dia Aberto... OK' + Chr(13) + Chr(10);
      nValor := nValor - 64;
   end;

   if (nValor >= 32) then
   begin
      //Indicador FLAG_DIA_FECHADO está ativo
      cMensagem := cMensagem + 'Dia fiscal já encerrado' + Chr(13) + Chr(10);
      nValor := nValor - 32;
      lBloqueiaOperacao := True;
   end;

   if (nValor >= 16) then
   begin
      //Indicador FLAG_SEM_MF está ativo
      cMensagem := cMensagem + 'Memória fiscal não encontrada.' + Chr(13) + Chr(10);
      nValor := nValor - 16;
      lBloqueiaOperacao := True;
   end;

   if (nValor >= 8) then
   begin
      //Indicador FLAG_RELOGIO_NOK está ativo
      cMensagem := cMensagem + 'Relógio inconsistente.' + Chr(13) + Chr(10);
      nValor := nValor - 8;
      lBloqueiaOperacao := True;
   end;

   if (nValor >= 4) then
   begin
      //Indicador FLAG_RAM_NOK está ativo
      cMensagem := cMensagem + 'RAM não está consistente.' + Chr(13) + Chr(10);
      nValor := nValor - 4;
      lBloqueiaOperacao := True;
   end;

   if (nValor >= 2) then
   begin
      //Indicador FLAG_SEM_MFD está ativo
      cMensagem := cMensagem + 'MFD não encontrada.' + Chr(13) + Chr(10);
      nValor := nValor - 2;
      lBloqueiaOperacao := True;
   end;

   if (nValor >= 1) then
   begin
      //Indicador FLAG_INTERVENCAO_TECNICA está ativo
      cMensagem := cMensagem + 'Equipamento em Intervenção Técnica.' + Chr(13) + Chr(10);
      nValor := nValor - 1;
      lBloqueiaOperacao := True;
   end;

   StatusProssegue := Not lBloqueiaOperacao;

   If lBloqueiaOperacao Then
   Begin
        ShowMessage('Indicadores:  ' + Chr(13) + Chr(10) + cMensagem);
   End;
end;

//------------------------------------------------------------------------------
function TImpFiscalLoggerII.RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer; ImgQrCode: String) : String;
var i,n,iRet, iMax : Integer;
    lOk : Boolean;
    sCodGerencial: String;
begin
  lOk := True;
  Result := '0';

  fLimpaParams(nHdlLogger);
  fAdicionaParam(nHdlLogger, 'CodGerencial', cIndTotalizador , G2_INTEGER);
  iRet := EnviaComando('LeGerencial');
  sCodGerencial := sPegaRet('CodGerencial'); // Quando o Indice não existe retorna 99

  If (Trim(sCodGerencial) <> '99') and (cIndTotalizador <> '') then
  begin

    For n:= 1 to nVias do
    begin
        fLimpaParams(nHdlLogger);
        fAdicionaParam(nHdlLogger, 'CodGerencial', cIndTotalizador, G2_INTEGER);
        iRet := EnviaComando('AbreGerencial');
        GravaLog(' <- AbreGerencial: ' + IntToStr(iRet));

        if iRet = 0 then
        begin
          // Executa impressao do texto em bloco de 492 caracteres
          i := 0;
          iMax := Length(cTextoImp);
          while i <= iMax do
          begin
            fLimpaParams(nHdlLogger);
            fAdicionaParam(nHdlLogger, 'TextoLivre', RemoveChar(Copy(cTextoImp,i,i+492)), G2_STRING);
            iRet := EnviaComando('ImprimeTexto');
            GravaLog(' <- ImprimeTexto : ' + IntToStr(iRet));

            lOk := (iRet = 0);
            if not lOk
            then break;

            i := i+492;
          end;

          if lOk then
          begin
            Result := FechaCupomNaoFiscal; //Dentro desta função é executado EncerraDocumento
            GravaLog(' <- EncerraDocumento : ' + Result );
          end
          else
          begin
            CancelaCupom('');
            Result := '1';
          end;
        end
        else
          Result := '1';
    end;
  end
  else
  begin
    Result := '1';
    LjMsgDlg('O Relatorio Gerencial ' + Trim(cIndTotalizador) + ' não existe no ECF.' );
  end;
end;

Function TrataTags( Mensagem : String ) : String;
var
  cMsg : String;
begin
cMsg := Mensagem;

while Pos('<B>', cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<B>',sTagGeral + sTagNegrito,[]);
   cMsg := StringReplace(cMsg,'</B>',sTagGeral + sTagDesativa,[]);
end;

While Pos('<E>',cMsg) > 0 do
begin
   cMsg := StringReplace(cMsg,'<E>',sTagGeral + sTagExpandido,[]);
   cMsg := StringReplace(cMsg,'</E>',sTagGeral + sTagDesativa,[]);
end;

cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//Criada para remover caracter que pode gerar erro na impressao
function RemoveChar( Texto : String ): String;
var
  cAuxTexto : String;
begin
   cAuxTexto := Texto;
   while Pos('\',cAuxTexto) > 0 do
    cAuxTexto := StringReplace(cAuxTexto,'\','-',[]);
   Result := cAuxTexto;
end;

//******************  Final das Funcoes Genericas ****************************************
function TImpFiscalLoggerII.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
  RegistraImpressora('ITAUTEC QUICKWAY - V. 01.01.03'        , TImpFiscalQuickWay               , 'BRA', ' '     );
  RegistraImpressora('ITAUTEC QUICKWAY - V. 01.01.05'        , TImpFiscalQuickWayV05            , 'BRA', '222101');
  RegistraImpressora('URANO ZPM 200'                         , TImpFiscalLoggerII               , 'BRA', '492603');
  RegistraImpressora('URANO 1FIT LOGGER II - V. 03.00'       , TImpFiscalLoggerII               , 'BRA', '461203');
  RegistraImpressora('URANO FIT 1E TH - V. 01.00.00'         , TImpFiscalLoggerII               , 'BRA', ' '     );
  RegistraImpressora('URANO FIT 1E TH - V. 03.03.00'         , TImpFiscalLoggerII               , 'BRA', ' '     );
  RegistraImpressora('URANO/1FIT LOGGER - V. 03.03.04'       , TImpFiscalLoggerII               , 'BRA', '461207');
  RegistraImpressora('ELGIN FIT 1E TH - V. 01.00.00'         , TImpFiscalLoggerII               , 'BRA', '140701');
  RegistraImpressora('ELGIN FIT 1E TH - V. 01.00.08'         , TImpFiscalLoggerII_010008        , 'BRA', '140702');
  RegistraImpressora('ELGIN ZPM/1FIT LOGGER - V. 03.03.04'   , TImpFiscalLoggerII               , 'BRA', ' '     );
  RegistraImpressora('ITAUTEC ZPM/1FIT LOGGER - V. 03.03.04' , TImpFiscalLoggerII               , 'BRA', ' '     );
  RegistraImpressora('ITAUTEC 2EFC LOGGER - V. 03.01.00'     , TImpFiscal2EFC                   , 'BRA', ' '     );
  RegistraImpressora('TERMOPRINTER TPF-1004 - V. 01.00.47'   , TImpFiscalTermoprinterTPF1004    , 'BRA', '400601');
  RegistraImpCheque('ITAUTEC 2EFC LOGGER'                    , TImpCheque2EFC                   , 'BRA'          );
//------------------------------------------------------------------------------
end.




