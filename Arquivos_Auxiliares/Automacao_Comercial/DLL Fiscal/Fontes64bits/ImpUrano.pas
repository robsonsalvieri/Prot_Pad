unit ImpUrano;

interface

uses
  Dialogs,
  ImpFiscMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  IniFiles,
  ImpCheqMain,
  Forms;

const
  pBuffSize = 200;

Type

  TImpFiscalUrano = class(TImpressoraFiscal)
  private
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
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ):AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function GravaCondPag( condicao:AnsiString ):AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function Gaveta:AnsiString; override;
    function Status( Tipo:Integer; Texto:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    Procedure PulaLinha( iNumero:Integer );
    function HorarioVerao( Tipo:AnsiString ):AnsiString; override;
    procedure AlimentaProperties; override;
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString ):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ): AnsiString; override;
    function PegaSerie:AnsiString; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString):AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override;
    function RedZDado( MapaRes:AnsiString ):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
  end;

  TImpFiscalUrano50 = class(TImpFiscalUrano)
  private
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
  end;

  TImpFiscalUranoII = class(TImpFiscalUrano)
  private
    fFuncStatusImpressora  : function ():integer; StdCall;
    fFuncPagamento         : function (forma,valor:AnsiString):Integer; StdCall;
    fFuncAvancaLinhas      : function (estacao,linhas: integer):integer; stdcall;
    fFuncCargaNaoVinculado : function ():integer; StdCall;
    fFuncFechaCupomNFiscal : function ():Integer; StdCall;
    fFuncAutentica         : function (linha:AnsiString):integer; StdCall;
    fFuncFechaCupom        : function (Tipo,operador:PChar):Integer; StdCall;
    fFuncCancelaCupom      : function (Operador:PChar):integer; StdCall;
    fFuncLeituraMF         : function (tipo,inicio,fim,reducaoinicio,reducaofinal:AnsiString):integer; StdCall;
    fFuncLeSensor          : function (sensor: char):integer; StdCall;
  public
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString; Vias:Integer ; ImgQrCode: AnsiString):AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function FechaEcf:AnsiString; override;
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function LeituraX:AnsiString; override;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function PegaPDV:AnsiString; override;
    function PegaSerie:AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function LeAliquotas:AnsiString; override;
    function LeAliquotasISS:AnsiString; override;
    function LeCondPag:AnsiString; override;
    function Pagamento( Pagamento, Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function GravaCondPag( condicao:AnsiString ):AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function Status( Tipo:Integer; Texto:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString; override;
    Procedure PulaLinha( iNumero:Integer );
    Procedure AlimentaProperties; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function BuscaTotalizador(Totalizador:AnsiString):AnsiString;
end;

  TImpFiscalUranoLog = class(TImpFiscalUrano)
  private
    fFuncPagamento          : function (forma, descricao, valor:AnsiString):Integer; StdCall;
    fFuncCortarPapel        : function ():integer; StdCall;
    fFuncPropaganda         : function (texto:AnsiString):integer; StdCall;
    fFuncAcrescimoSubTotal  : function  (descricao,valor:AnsiString):integer; StdCall;
    fFuncVinculado          : function (sequencia,documento,aut,nome, vias, texto, espaco, tempo:AnsiString):integer;StdCall;
    fFuncProgramaRelogio    : function (tipo, data, hora:AnsiString):integer;StdCall;
    fFuncCancelaItem        : function (item:AnsiString):Integer; StdCall;
    fFuncDescontoSubTotal   : function (descricao,valor:AnsiString):integer; StdCall;
    fFuncLeECF              : function (tipo,inicio,fim,proprietario,arquivo:AnsiString):integer; StdCall;
    fFuncLinhasLivres       : function (tamanho, texto:AnsiString):Integer; StdCall;
    fFuncEmiteNaoVinculado : function (codigo,descricao,valor:AnsiString):integer; StdCall;
    fFuncCancelaCupom      : function (Operador:PChar):integer; StdCall;
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    Procedure AlimentaProperties; override;
    function LeAliquotasISS:AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function PegaSerie:AnsiString; override;
    function LeCondPag:AnsiString; override;
    function Pagamento( Pagamento, Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function PegaPDV:AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function HorarioVerao( Tipo:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString; override;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
end;

  TImpFiscalUrano2EFC = class(TImpFiscalUrano)
  private
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ):AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Urano impressora Fiscal
///
  TImpCheqUrano2EFC = class(TImpressoraCheque)
  Private
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar(aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
Function OpenUrano( sPorta:AnsiString; sImpressora:AnsiString ):AnsiString;
Function CloseUrano : AnsiString;
Function TrataTags( Mensagem : AnsiString ) : AnsiString;

implementation
{ Constantes globais  }
var
  sNFiscal: AnsiString;
  iSoma: integer;
  bOpened : Boolean;
  fHandle : THandle;

  fFuncInicializaDll     : function ( porta:PChar ):integer; StdCall;
  fFuncFinalizaDll       : function ():integer; StdCall;
  fFuncImprimeCabecalho  : function ():integer; StdCall;
  fFuncVendaItem         : function (codigo,descricao,qtde,vrunit,taxa,unidade,tipo:AnsiString):integer; StdCall;
  fFuncCancelaItem       : function (motivo,item:AnsiString):Integer; StdCall;
  fFuncDescontoItem      : function (ratifica,descricao,valor:AnsiString):Integer; StdCall;
  fFuncPagamento         : function (forma,descricao,valor,acumular:AnsiString):Integer; StdCall;
  fFuncFechaCupom        : function (operador:PChar):Integer; StdCall;
  fFuncLinhasLivres      : function (texto:AnsiString):Integer; StdCall;
  fFuncCancelaVenda      : function (operador:PChar):Integer; StdCall;
  fFuncCancelaCupom      : function (Autorizacao,Operador:PChar):integer; StdCall;
  fFuncAcrescimoSubTotal : function (operacao,descricao,valor:AnsiString):integer; StdCall;
  fFuncDescontoSubTotal  : function (operacao,descricao,valor:AnsiString):integer; StdCall;
  fFuncRelatorio_XZ      : function (TipoRel:PChar):integer; StdCall;
  fFuncFinalizaRelatorio : function (operador:PChar):integer; StdCall;
  fFuncCargaAliquota     : function (aliquota,valor:AnsiString):integer; StdCall;
  fFuncCargaCliche       : function (tipo,linha1,linha2,linha3,loja,seq,CGC,ie,destino:Pchar):integer; StdCall;
  fFuncLeituraMF         : function (tipo,inicio,fim:AnsiString):integer; StdCall;
  fFuncPropaganda        : function (tipo,texto:AnsiString):integer; StdCall;
  fFuncAbreGaveta        : function ():integer; StdCall;
  fFuncAvancaLinhas      : function (iLinhas:PChar):integer; StdCall;
  fFuncEstadoImpressora  : function ():integer; StdCall;
  fFuncLeRegistrador     : function (registrador,valor:PChar):integer; StdCall;
  fFuncAutentica         : function ():integer; StdCall;
  fFuncLeSensor          : function (sensor:AnsiString):integer; StdCall;
  fFuncIdComprador       : function (nome,tipo,cgc,linha1,linha2:PChar):integer; StdCall;
  fFuncCupomStub         : function (operador:Pchar):integer; StdCall;
  fFuncSimboloMoeda      : function (Simbolo:Pchar):integer; StdCall;
  fFuncFormaPagamento    : function (forma,descricao:AnsiString):integer; StdCall;
  fFuncCargaNaoVinculado : function (codigo,descricao:AnsiString):integer; StdCall;
  fFuncEmiteNaoVinculado : function (codigo,descricao,valor:AnsiString):integer; StdCall;
  fFuncEmiteVinculado    : function (cupom,sequencia:AnsiString):integer; StdCall;
  fFuncTransferFinanceira: function (valor,origem,destino:PChar):integer; StdCall;
  fFuncImprimeCheque     : function (Arquivo:AnsiString; Banco: AnsiString; Valor: AnsiString; Favorecido: AnsiString; Cidade: AnsiString; Mensagem: AnsiString; Data: AnsiString): Integer; StdCall;
  fFuncNomeMoeda         : function ( Singular:AnsiString; Plural: AnsiString): Integer; StdCall;

//---------------------------------------------------------------------------
function TImpFiscalUrano.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
  Result := OpenUrano( sPorta,'URANO ZPM 1EF 3.0' );
  // Carrega as aliquotas e N. PDV para ganhar performance
  if Copy(Result,1,1) = '0' then
     AlimentaProperties;
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.Fechar( sPorta:AnsiString ):AnsiString;
begin
  Result := CloseUrano;
end;
//---------------------------------------------------------------------------
function TImpFiscalUrano.LeituraX : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncRelatorio_XZ( '0' );
  result := Status( 1, IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    PulaLinha( 6 );
end;

//---------------------------------------------------------------------------
function TImpFiscalUrano.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalUrano.ReducaoZ ( MapaRes:AnsiString ): AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncRelatorio_XZ( '1' );
  result := Status( 1, IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    PulaLinha( 6 );
end;

//---------------------------------------------------------------------------
function TImpFiscalUrano.LeAliquotas:AnsiString;
begin
  Result := '0|' + ALIQUOTAS;
end;

//---------------------------------------------------------------------------
function TImpFiscalUrano.LeAliquotasISS:AnsiString;
var
  iRet : Integer;
  i : Integer;
  lpValor : PChar;
  sAliq : AnsiString;
  sAliqTmp : AnsiString;
begin
  lpValor := StrAlloc(22);
  sAliq := '';
  For i:=34 to 40 do
  begin
    iRet := fFuncLeRegistrador( PChar(FormataTexto(IntToStr(i),2,0,2)),lpValor );
    if Trim(StrPas(lpValor)) <> '' then
      sAliqTmp := StrTran(StrPas(lpValor),',','') ;
      if StrToFloat(sAliqTmp) <> 0 then
        sAliq := sAliq + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';
  end;
  if (iRet = 33) then
    result := '0|' + sAliq
  else
    result := '1|';
  StrDispose( lpValor );
end;

//---------------------------------------------------------------------------
function TImpFiscalUrano.LeCondPag:AnsiString;
var
  iRet, iPos : Integer;
  i : Integer;
  lpValor : PChar;
  sAliq : AnsiString;
begin
  lpValor := StrAlloc( 22 );
  sAliq := '';
  For i:=42 to 51 do
  begin
    iRet := fFuncLeRegistrador( PChar(IntToStr(i)),lpValor );
    if Trim(StrPas(lpValor)) <> '' then
    begin
      // Verifica se é versão 3.0, tem o caracter '-' antes da condição. Se
      // for 4.0 não tem este caracter.
      if copy(Trim(StrPas(lpValor)), 1, 1 ) = '-' then
        iPos := 2
      else
        iPos := 1;
      sAliq := sAliq + copy(Trim(StrPas(lpValor)),iPos,Length(Trim(StrPas(lpValor)))) + '|';
    end;
  end;
  if (iRet = 33) then
    result := '0|' + sAliq
  else
    result := '1|';
  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
var iRet : Integer;
begin
  iRet := fFuncImprimeCabecalho;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
begin
  lpValor := StrAlloc( 22 );
  iRet := fFuncLeRegistrador( '18',lpValor );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    result := result + Trim(strpas(lpValor));
  StrDispose( lpValor );
end;


//----------------------------------------------------------------------------
function TImpFiscalUrano.PegaPDV:AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
begin
    lpValor := PChar(Space(22));
    iRet := fFuncLeRegistrador( '26',lpValor );
    result := Status( 1,IntToStr(iRet) );
    if copy( result,1,1 ) = '0' then
        result := result + Trim(strpas(lpValor));
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncCancelaItem('Cancelamento de Item de Venda', FormataTexto(numitem,3,0,2) );
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.CancelaCupom( Supervisor:AnsiString ):AnsiString;
var iRet, iStat : Integer;
    lEmVenda : Boolean;
    sCupomAntes, sCupomDepois : AnsiString;
begin
  // Inicializa a variavel lEmVenda como False
  lEmVenda := False;
  // Pega o status do ECF
  iStat := fFuncEstadoImpressora;
  // Verifica se está no meio de uma venda ou o cupom já foi fechado.
  // 118 -	Em período de venda
  // 119 -	Em venda de item
  // 120 -	Em pagamento
  // 121 - 	Em comercial (msg promocional)

  if Pos(Trim(IntToStr(iStat)),'118|119|120|121|') <> 0 then
    lEmVenda := True;

  If not lEmVenda then sCupomAntes := PegaCupom('');

  // Tenta fazer o cancelamento de uma venda em aberto.
  iRet := fFuncCancelaVenda( ' ' );
  if copy(Status(1,IntToStr(iRet)),1,1) <> '0' then
    // Envia o comando para fazer o cancelamento do ultimo cupom emitido
    iRet := fFuncCancelaCupom( '0', ' ' );

  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    Pulalinha( 6 )
  else
    // Se cancelamento enviado fora da sequencia
    if iRet = 63 then
    begin
      // Registra um item qualquer
      iRet := fFuncVendaItem( '1', 'Cancelamento', FormataTexto( '1',7,3,1 ),
                              '000000001', '8', 'Un', '0' );
      result := Status( 1,IntToStr(iRet) );
      if copy(Status(1,IntToStr(iRet)),1,1) = '0' then
      begin
        iRet := fFuncCancelaVenda( ' ' );
        if copy(Status(1,IntToStr(iRet)),1,1) <> '0' then
          iRet := fFuncCancelaCupom( '0', ' ' );
        result := Status( 1,IntToStr(iRet) );
        if copy( result,1,1 ) = '0' then
          Pulalinha( 6 );
      end;
    end
    Else
    begin
      // Se o ECF retornar um erro, faz a checagem para ver se o numero do cupom (COO)
      // foi incrementado, se afirmativo, significa que o cancelamento foi realmente efetuado.
      // Nestas condiçoes o retorno desta função deverá ser 0 (sucesso na execução)
      If not lEmVenda then
      begin
        sCupomDepois := PegaCupom('');
        If sCupomAntes <> sCupomDepois then
        begin
          Result := '0';
          Pulalinha( 6 );
        end;
      end;
    end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sAliq : AnsiString;
  aAliq : TaString;
  iRet : Integer;
  i : Integer;
  iPos : Integer;
  sSituacao : AnsiString;
  sTrib : AnsiString;
  iDecQuant : Integer;
  sDecimais : AnsiString;

begin
  // Verica o ponto decimal dos parâmetros
  qtde := StrTran(qtde,',','.');
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    If StrToFloat(vlrdesconto) > 0 then
    begin
      iRet := fFuncDescontoItem( '0',' ',FormataTexto(vlrdesconto,10,2,2) );
      result := Status( 1,IntToStr(iRet) );
    end
    else
      result := '0';
    exit;
  end;

  // Faz o tratamento da aliquota
  sSituacao := copy(aliquota,1,1);
  aliquota := StrTran(copy(aliquota,2,5),',','.');
  // Pega as aliquotas
  sAliq := LeAliquotas;
  MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

  // Verifica se existe a aliquota
  iPos := 99;
  For i := 0 to Length(aAliq)-1 do
  begin
    sAliq := StrTran(aAliq[i],',','.');
    if StrTran(aAliq[i],',','.') = trim(aliquota) then
      iPos := i;
  end;

  if sSituacao = 'T' then
    sTrib := IntToStr(iPos)
  else if sSituacao = 'S' then // Iss
    sTrib := '10'
  else if sSituacao = 'F' then // Substituicao
    sTrib := '7'
  else if sSituacao = 'I' then // Isento
    sTrib := '8'
  else if sSituacao = 'N' then // Nao tributado
    sTrib := '9';

  if (iPos = 99) and (Pos(sSituacao,'T') > 0) then
  begin
    ShowMessage('Não existe a alíquota informada.');
    result := '1';
    exit;
  end;

  qtde := FormataTexto(qtde,7,3,1);
  vlrUnit := Trim(FormataTexto(vlrUnit,9,2,2));

  // Faz o tratamento das casas decimais da quantidade.
  If StrToFloat(copy(qtde,Pos('.',qtde)+1,Length(qtde))) > 0 then
  begin
    sDecimais := copy(qtde,Pos('.',qtde)+1,Length(qtde));
    i := Length(sDecimais);
    While i > 0 do
    begin
      If copy(sDecimais,i,1) = '0' then
      begin
        sDecimais := copy(sDecimais,1,i-1);
        Dec(i);
      end
      else
        i := 0;
    end;
    iDecQuant := Length(sDecimais);
  end
  Else
    iDecQuant := 0;

  qtde := FormataTexto(qtde,7,iDecQuant,1);

  try
    iRet := fFuncVendaItem( copy(Codigo,1,13),
                          copy(descricao,1,66),
                          qtde,
                          StrTran(vlrUnit,'.',''),
                          sTrib,
                          'Un',
                          '0' );
    result := Status( 1,IntToStr(iRet) );
    If StrToFloat(vlrdesconto) > 0 then
    begin
      iRet := fFuncDescontoItem( '0',' ',FormataTexto(vlrdesconto,10,2,2) );
      result := Status( 1,IntToStr(iRet) );
    end;

  except
    MsgStop('Esta impressora só aceita código do produto do tipo numérico');
    result := '1';
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.AbreECF:AnsiString;
begin
  result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalUrano.FechaEcf : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncRelatorio_XZ( '1' );
  result := Status( 1, IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    PulaLinha( 6 );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.Pagamento( Pagamento,Vinculado,Percepcion : AnsiString ): AnsiString;
  function AchaPagto( sPagto:AnsiString; aPagtos:TaString ):AnsiString;
  var i, iPos, iTamCond : Integer;
  begin
    iPos := 99;
    for i:=0 to Length(aPagtos)-1 do
    begin
      iTamCond := Length(aPagtos[i]);
      if UpperCase(aPagtos[i]) = UpperCase(copy(sPagto,1,iTamCond)) then
      begin
        iPos := i;
        break;
      end;
    end;
    result := IntToStr(iPos);
    if iPos <> 99 then
      if Length(result) < 2 then
        result := '0' + result;
  end;
var
  sPagto : AnsiString;
  aPagto,aAuxiliar : TaString;
  iRet,i : Integer;
begin
  iRet := 0;
  // Verifica o parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Pega a condicao de pagamento
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Monta um array auxiliar com as formas solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Faz o registro do pagamento
  i:=0;
  While i<Length(aAuxiliar) do
  begin
    if AchaPagto(aAuxiliar[i],aPagto) <> '99' then
      iRet := fFuncPagamento( AchaPagto(aAuxiliar[i],aPagto), '  ', FormataTexto(aAuxiliar[i+1],11,2,2), '1' );
    Inc(i,2);
  end;

  result := Status( 1,IntToStr(iRet) );

end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
  iRet : Integer;
  sMsg : AnsiString;
begin
  sMsg := Mensagem;
  sMsg := TrataTags( sMsg );
  if sMsg <> '' then
    fFuncPropaganda( '0', sMsg );
  iRet := fFuncFechaCupom( ' ' );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    PulaLinha( 6 );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString;
var
  iRet : Integer;
begin
  vlrDesconto := StrTran(vlrDesconto,',','.');
  if StrToFloat(vlrDesconto) > 0 then
  begin
    iRet := fFuncDescontoSubTotal( '0', ' ', FormataTexto(vlrDesconto,7,2,2) );
    result := Status( 1,IntToStr(iRet) );
  end
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var
  iRet : Integer;
begin
  vlrAcrescimo := StrTran(vlrAcrescimo,',','.');
  if StrToFloat(vlrAcrescimo) > 0 then
  begin
    iRet := fFuncAcrescimoSubTotal( '0', ' ', PChar(FormataTexto(vlrAcrescimo,10,2,2)) );
    result := status( 1,IntToStr(iRet) );
  end
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncLeituraMF( '0', FormataData(DataInicio,1), FormataData(DataFim,1) );
  result := status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    PulaLinha( 6 );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
var
  iRet, i : Integer;
  sAliq   : AnsiString;
  aAliq   : TaString;
  bAchou  : Boolean;
begin
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
    if i < 7 then
    begin
      iRet := fFuncCargaAliquota( FormataTexto(IntToStr(i),2,0,2), FormataTexto(Aliquota,4,2,2) );
      result := Status( 1,IntToStr(iRet) );
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
function TImpFiscalUrano.GravaCondPag( condicao:AnsiString ):AnsiString;
var
  iRet : Integer;
  aPagto : TaString;
  sPagto : AnsiString;
  iPos, iCond : Integer;
  i : Integer;
begin
  // Verifica as condicoes já existentes
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)), aPagto );
  // Inicializa iCond com o tamanho do vetor, assim a nova condição sempre
  // cairá na próxima posição vaga para inclusão.
  iCond := length(aPagto);
  iPos  := 99;
  for i:=0 to Length(aPagto)-1 do
  begin
    if UpperCase(aPagto[i]) = UpperCase(condicao) then
      iPos := i;
    // Utilizado para Urano 3.0, que retorna um array com branco ('')
    if (UpperCase(aPagto[i]) = '') then
    begin
      iCond := i;
      break;
    end
  end;

  if iPos = 99 then
  begin
    iRet := fFuncFormaPagamento( FormataTexto(IntToStr(iCond),2,0,2), condicao );
    result := Status( 1,IntToStr(iRet) );
  end
  else
  begin
    ShowMessage('Já existe a condição de pagamento ' + condicao );
    result := '4|';
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
var iRet, i, iTamCond : Integer;
var sPagto, sPos : AnsiString;
var aPagto : TaString;
var lpValor : PChar;
begin
  // Faz a leitura das condicoes de pagamento
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)), aPagto );

  // Verifica o numero do cupom
  lpValor := StrAlloc( 22 );
  fFuncLeRegistrador( '18',lpValor );
  sPos := '99';
  for i := 0 to length(aPagto)-1 do
  begin
    iTamCond := Length(Trim(aPagto[i]));
    if ( iTamCond>0 ) and ( UpperCase(Trim(aPagto[i])) = UpperCase(copy(Trim(Condicao),1,iTamCond))) then
      Begin
      sPos := IntToStr(i);
      Break;
      End;
  end;

  // Ajusta sPos para ser passado como parâmetro
  if length( sPos ) = 1 then sPos := '0' + sPos;

  if sPos <> '99' then
  begin
    iRet := fFuncEmiteVinculado( Trim(StrPas(lpValor)), '01' );
    result := Status( 1,IntToStr(iRet) );
  end
  else
  begin
    ShowMessage('Não existe a condição de pagamento informada.');
    result := '1|';
  end;

  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var iRet, i, nLoop : Integer;
var sLinha : AnsiString;
var lOk : boolean;
begin

  iRet   := 0;
  i      := 1;
  sLinha := '';
  lOk    := True;

  // Caso o texto estaja vazio, imprime um '.'
  if Length(Texto) = 0 then Texto := '.' + #10;

  // Executa o loop para impressao das vias
  for nLoop := 1 to Vias do
  begin

    // Executa impressao do texto linha a linha
    while i <= Length(Texto) do
    begin
      if (copy(Texto,i,1) = #10) or (Length(sLinha)>=48) then
      begin
        if sLinha <> '' then
        begin
          iRet   := fFuncLinhasLivres( sLinha );
          sLinha := '';
          result := Status(1, IntToStr(iRet) );
          lOk    := copy( result, 1, 1 ) = '0';
          if not lOk then break;
        end
        else
          PulaLinha(1);
      end
      else
        // Se for #, não grava na AnsiString
        if copy(Texto,i,1) <> '#' then sLinha := sLinha + copy(Texto,i,1);
      Inc(i);
    end;

    // Se houve problema na impressão da linha aborta proximas vias
    if not lOk then break;

    // Verifica se é uma nova via
    if not (nLoop = Vias) then
    begin
      i      := 1;
      sLinha := '';
      // Processo para nova via
      PulaLinha(9);
      Sleep(5000);
    end;

  end;

  result := Status( 1,IntToStr(iRet) );

end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.FechaCupomNaoFiscal: AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFechaCupom( '0' );
  result := Status( 1,IntToStr(iRet) );
  if copy(result,1,1) = '0' then
    PulaLinha( 6 )
  Else
    fFuncFinalizaRelatorio( ' ' );

end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.ReImpCupomNaoFiscal( Texto:AnsiString ): AnsiString;
begin
  // para posterior implementacao
  result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
  i : Integer;
begin
  iRet := 1;
  For i:=1 to Vezes do
  begin
    ShowMessage('Posicione o Documento para Autenticação.');
    iRet := fFuncAutentica;
  end;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ): AnsiString;
var iRet, iNumero : integer;
begin
  if StrToInt(Numero) < 0 then
    result := '1|'
  else if Descricao = '' then
    result := '1|'
  else
  begin
    iNumero := StrToInt( Numero ) - 1;
    iRet := fFuncCargaNaoVinculado( FormataTexto(IntToStr(iNumero),2,0,2), copy(Descricao,1,30));
    result := Status( 1, IntToStr( iRet ) );
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.PegaSerie : AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
begin
  lpValor := StrAlloc( 22 );
  iRet := fFuncLeRegistrador( '25',lpValor );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    result := result + Trim(strpas(lpValor));
  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
var
  iRet      : Integer;
  i         : Integer;
  lpForma   : PChar;
  bRet      : Boolean;
  iReg      : Integer;
  sForma    : AnsiString;
  sValor    : AnsiString;
  sTipo     : AnsiString;   //Tipo de operação 'SUPRIMENTO DE CAIXA' ou 'SANGRIA'
begin
  // Tipo = 1 - Verifica se tem troco disponivel
  // Tipo = 2 - Grava o valor informado no Suprimentos
  // Tipo = 3 - Sangra o valor informado
  lpForma   := StrAlloc(30);
  bRet      := False;
  iReg      := 0;
  sValor    := FormataTexto(Valor,9,2,1);
  Valor     := FormataTexto(Valor,9,2,2);
  if Tipo = 3 then
    sTipo := 'SANGRIA'
  Else
    sTipo := 'SUPRIMENTO DE CAIXA';

  if Trim(Forma) = '' then
    begin
      For i:=62 to 76 do
      begin
        fFuncLeRegistrador( PChar(FormataTexto(IntToStr(i),2,0,2)),lpForma );
        if ( Trim(StrPas(lpForma))= '' ) and ( iReg=0 )  then
            iReg:=i-62;

        if Trim(StrPas(lpForma))=sTipo then
          begin
             bRet:=True;
             iReg:=i-62;
             break;
          end;
      end;
      if not bRet then
        fFuncCargaNaoVinculado( FormataTexto(IntToStr(iReg),2,0,2), sTipo + Space(30-Length(sTipo)));
      sForma := sTipo;
      Forma := 'DINHEIRO';
    end
  else
     begin
       iReg := (StrToInt(Total)-1);
       fFuncLeRegistrador( PChar(FormataTexto(IntToStr(iReg+62),2,0,2)),lpForma );
       sForma := Trim(StrPas(lpForma));
     end;
  if tipo=1 then
    begin
    lpForma   := StrAlloc(30);
    fFuncLeRegistrador( PChar(FormataTexto(IntToStr(iReg+77),2,0,2)),lpForma );
    result :=StrTran(Trim(lpForma),',','');
    end
  else
    Begin
      iRet:=fFuncEmiteNaoVinculado(FormataTexto(IntToStr(iReg),2,0,2),sForma,Valor);
      result := Status( 1,IntToStr(iRet) );
      Pagamento(Forma+'|'+sValor,'0','');
      FechaCupomNaoFiscal;
    end;
  StrDispose( lpForma );

end;
//----------------------------------------------------------------------------
function TImpFiscalUrano.Gaveta:AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncAbreGaveta;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.HorarioVerao( Tipo:AnsiString ):AnsiString;
begin
  ShowMessage('Impressora ainda não ajusta o relogio.');
  result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString;
begin
  Result := RelatorioGerencial(cTextoImp , nVias , ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString;
var iRet : Integer;
begin
  fFuncFinalizaRelatorio( ' ' );
  iRet   := fFuncRelatorio_XZ( '2' );
  result := Status( 1, IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
  begin
    result := TextoNaoFiscal( Texto, Vias );
    if copy( result,1,1 ) = '0' then
    begin
      iRet   := fFuncFinalizaRelatorio( ' ' );
      result := Status( 1, IntToStr(iRet) );
      if copy( result, 1, 1 ) = '0'
      then PulaLinha(6);
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
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
// 43 e 44- Reservado Autocom
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware

// Aloca memória no ponteiro lpValor
lpValor := StrAlloc( 22 );
StrPCopy( lpValor, '' );

// Faz a leitura da Hora
if Tipo = 1 then
begin
  iRet := fFuncLeRegistrador( '28', lpValor );
  result := Trim(strpas(lpValor));
  result := Status( 1, IntToStr(iRet) ) + result;
end
// Faz a leitura da Data
else if Tipo = 2 then
begin
  iRet := fFuncLeRegistrador( '27', lpValor );
  result := Trim(strpas(lpValor));
  result := Status( 1, IntToStr(iRet) ) + result;
end
// Faz a checagem de papel
else if Tipo = 3 then
begin
  //checa se tem papel
  iRet := fFuncLeSensor( '1' );
  if iRet = 48 then // sensor desligado
  begin
    //checa se tem pouco papel
    iRet := fFuncLeSensor( '2' );
    if iRet = 48 then // sensor desligado
      result := '0'
    else if iRet = 49 then // sensor ligado
      result := '3';
  end
  else if iRet = 49 then // sensor ligado
    result := '2'
  else
    result := '0';

  if (iRet = 48) or (iRet = 49) then
    result := '0|' + result
  else
    result := '1|' + result;
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  iRet := fFuncEstadoImpressora;
  If iRet = 119 then
    result := '7'
  Else
    result := '0';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
Begin
  iRet := fFuncEstadoImpressora;
  If iRet = 50 then
    result := '10'
  Else
    result := '0';
End
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
  result := '0'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  result := '0'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 Then
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
else
  Result := '1';

StrDispose(lpValor);
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.Status( Tipo:Integer; Texto:AnsiString ):AnsiString;
  // Parametros
  // 1- Verifica se o ultimo comando foi executado
  // 2- Verifica a existencia de papel ( se tem ou não )
  // 3- Verifica o status do papel ( se está no fim ou não )
var
  bErro : Boolean;
begin
  bErro := False;
  case Tipo of
    //*************************************************************************
    //*  O retorno 33 e o retorno 0 (zero) são retornos OK. Significa que o ECF
    //*  executou o comando. Contudo em contato com o suporte da Urano em
    //*  18/03/04 com o Felipe, constatamos que a impressora pode retornar
    //*  tanto 33 como 0, aleatoriamente e independente do comando.
    //*************************************************************************
    1 : if (Texto <> '33') and (Texto <> '0') then
            bErro := True;
        else
            bErro := False;
        end;


  If bErro then
    result := '1|'
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
procedure TImpFiscalUrano.PulaLinha( iNumero:Integer );
begin
  fFuncAvancaLinhas( PChar(FormataTexto(IntToStr(iNumero),2,0,2)) );
end;

//----------------------------------------------------------------------------
procedure TImpFiscalUrano.AlimentaProperties;
var
  iRet     : Integer;
  i        : Integer;
  lpValor  : PChar;
  sAliq    : AnsiString;
  sAliqTmp : AnsiString;
  sTodas   : AnsiString;

begin
  ICMS      := '';
  ALIQUOTAS := '';
  ISS       := '';
  sAliq     := '';
  sTodas    := '';
  lpValor := PChar(Space(22));
  For i:=34 to 40 do
  begin
    iRet := fFuncLeRegistrador( PChar(FormataTexto(IntToStr(i),2,0,2)),lpValor );
    if Trim(StrPas(lpValor)) <> '' then
      sAliqTmp := StrTran(StrPas(lpValor),',','')
    else
      sAliqTmp := '0';
    try
      if StrToFloat(sAliqTmp) <> 0 then
        sAliq := sAliq + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';

      sTodas := sTodas + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';
    except
    end;
  end;
  if (iRet = 33) then
  Begin
    ICMS      := sAliq;
    ALIQUOTAS := sTodas;
  End;

end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.LeTotNFisc:AnsiString;
begin
    Result := '0|-99';
end;


//------------------------------------------------------------------------------
function TImpFiscalUrano.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalUrano.RedZDado( MapaRes : AnsiString): AnsiString ;
Begin
  Result := '1';
End;


//------------------------------------------------------------------------------
function TImpFiscalUrano.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//---------------------------------------------------------------------------
function TImpFiscalUrano.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalUrano.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
end;

//---------------------------------------------------------------------------
function TImpFiscalUranoII.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;

  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: IMP32.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;
  lpValor : PChar;
begin
  fHandle := LoadLibrary( 'IMP32.DLL' );
  if (fHandle <> 0) Then
  begin
    bRet := True;
    aFunc := GetProcAddress(fHandle,'IniciaImpressora');
    if ValidPointer( aFunc, 'IniciaImpressora') then
       fFuncInicializaDll := aFunc
    else
       begin
       bRet := False;
       end;

    aFunc := GetProcAddress(fHandle,'FinalizaImpressora');
    if ValidPointer( aFunc, 'FinalizaImpressora' ) then
      fFuncFinalizaDll := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ImprimeCabecalho');
    if ValidPointer( aFunc, 'ImprimeCabecalho' ) then
      fFuncImprimeCabecalho := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'VendaItem');
    if ValidPointer( aFunc, 'VendaItem' ) then
      fFuncVendaItem := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CancelaItem');
    if ValidPointer( aFunc, 'CancelaItem' ) then
      fFuncCancelaItem := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'DescontoItem');
    if ValidPointer( aFunc, 'DescontoItem' ) then
      fFuncDescontoItem := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'Pagamento');
    if ValidPointer( aFunc, 'Pagamento' ) then
      fFuncPagamento := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'FinalizaVenda');
    if ValidPointer( aFunc, 'FinalizaVenda' ) then
      fFuncFechaCupom := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'FimCupomNFiscal');
    if ValidPointer( aFunc, 'FimCupomNFiscal' ) then
      fFuncFechaCupomNFiscal:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ImprimeLinhaNFiscal');
    if ValidPointer( aFunc, 'ImprimeLinhaNFiscal' ) then
      fFuncLinhasLivres := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CancelaVenda');
    if ValidPointer( aFunc, 'CancelaVenda' ) then
      fFuncCancelaVenda := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CancelaCupom');
    if ValidPointer( aFunc, 'CancelaCupom' ) then
      fFuncCancelaCupom := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'AcrescSubTotal');
    if ValidPointer( aFunc, 'AcrescSubTotal' ) then
      fFuncAcrescimoSubTotal := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'DescSubTotal');
    if ValidPointer( aFunc, 'DescSubTotal' ) then
      fFuncDescontoSubTotal := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'IniciaXZ');
    if ValidPointer( aFunc, 'IniciaXZ' ) then
      fFuncRelatorio_XZ := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'FinalizaXZ');
    if ValidPointer( aFunc, 'FinalizaXZ' ) then
      fFuncFinalizaRelatorio := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CarregaTabAliq');
    if ValidPointer( aFunc, 'CarregaTabAliq' ) then
      fFuncCargaAliquota := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CarregaCliche');
    if ValidPointer( aFunc, 'CarregaCliche' ) then
      fFuncCargaCliche := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'LeituraMemFiscal');
    if ValidPointer( aFunc, 'LeituraMemFiscal' ) then
      fFuncLeituraMF := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'MensagemPromocional');
    if ValidPointer( aFunc, 'MensagemPromocional' ) then
      fFuncPropaganda := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'AbreGaveta');
    if ValidPointer( aFunc, 'AbreGaveta' ) then
      fFuncAbreGaveta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'AvancoLinha');
    if ValidPointer( aFunc, 'AvancoLinha' ) then
      fFuncAvancaLinhas := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'StatusImpressora');
    if ValidPointer( aFunc, 'StatusImpressora' ) then
      fFuncStatusImpressora := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'LeRegistradores');
    if ValidPointer( aFunc, 'LeRegistradores' ) then
      fFuncLeRegistrador := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'AutenticaDocumento');
    if ValidPointer( aFunc, 'AutenticaDocumento' ) then
      fFuncAutentica := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'LeituraSensor');
    if ValidPointer( aFunc, 'LeituraSensor' ) then
      fFuncLeSensor := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'IdentificaComprador');
    if ValidPointer( aFunc, 'IdentificaComprador' ) then
      fFuncIdComprador := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CupomStub');
    if ValidPointer( aFunc, 'CupomStub' ) then
      fFuncCupomStub := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'SimboloMoeda');
    if ValidPointer( aFunc, 'SimboloMoeda' ) then
      fFuncSimboloMoeda := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'IniciaCupomNFiscal');
    if ValidPointer( aFunc, 'IniciaCupomNFiscal' ) then
      fFuncCargaNaoVinculado := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'FimCupomNFiscal');
    if ValidPointer( aFunc, 'FimCupomNFiscal' ) then
      fFuncEmiteNaoVinculado := aFunc
    else
    begin
      bRet := False;
    end;
  end
  else
  begin
    ShowMessage('O arquivo IMP32.DLL não foi encontrado.');
    bRet := False;
  end;
  if bRet then
  begin       
    Result:= '0|';
    bRet  := True;
    iRet  := fFuncInicializaDll( PChar(sPorta) );
    if iRet = 0 then
       Begin
       lpValor := StrAlloc(20);
       FillChar(lpValor^,20,0);
       iRet := fFuncLeRegistrador( PChar('01'),lpValor );
       if iRet <> 0 then
          bRet := False;
       end
    Else
       bRet := False;

    if not bRet then
      begin
      ShowMessage('Erro na abertura da porta');
      result := '1|';
      end
    Else
      AlimentaProperties;
    end
  else
    result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.LeituraX : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncRelatorio_XZ( '0' );
  result := Status( 1, IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    fFuncFinalizaRelatorio( ' ' );
    PulaLinha( 6 );
end;

//---------------------------------------------------------------------------
function TImpFiscalUranoII.ReducaoZ( MapaRes:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncRelatorio_XZ( '1' );
  result := Status( 1, IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    fFuncFinalizaRelatorio( ' ' );
    PulaLinha( 6 );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.LeAliquotas:AnsiString;
begin
  Result := '0|' + ALIQUOTAS;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.LeAliquotasISS:AnsiString;
var
  iRet : Integer;
  i : Integer;
  lpValor : PChar;
  sAliq : AnsiString;
  sAliqTmp : AnsiString;
begin
  lpValor := StrAlloc(22);
  sAliq := '';
  For i:=56 to 71 do
  begin
    iRet := fFuncLeRegistrador( PChar(FormataTexto(IntToStr(i),2,0,2)),lpValor );
    if Trim(StrPas(lpValor)) <> '' then
      sAliqTmp := StrTran(StrPas(lpValor),',','') ;
      if StrToFloat(sAliqTmp) <> 0 then
        sAliq := sAliq + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';
  end;
  if (iRet = 0) then
    result := '0|' + sAliq
  else
    result := '1|';
  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.LeCondPag:AnsiString;
begin
//  ShowMessage('Função não disponivél para este equipamento' );
  result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var iRet, i, nLoop : Integer;
var sLinha : AnsiString;
var lOk : boolean;
begin

  iRet   := 0;
  i      := 1;
  sLinha := '';
  lOk    := True;

  // Caso o texto estaja vazio, imprime um '.'
  if Length(Texto) = 0 then Texto := '.' + #10;

  // Executa o loop para impressao das vias
  for nLoop := 1 to Vias do
  begin

    // Executa impressao do texto linha a linha
    while i <= Length(Texto) do
    begin
      if (copy(Texto,i,1) = #10) or (Length(sLinha)>=48) then
      begin
        if sLinha <> '' then
        begin
          iRet   := fFuncLinhasLivres( sLinha );
          sLinha := '';
          result := Status(1, IntToStr(iRet) );
          lOk    := copy( result, 1, 1 ) = '0';
          if not lOk then break;
        end
        else
          PulaLinha(1);
      end
      else
        // Se for #, não grava na AnsiString
        if copy(Texto,i,1) <> '#' then sLinha := sLinha + copy(Texto,i,1);
      Inc(i);
    end;

    // Se houve problema na impressão da linha aborta proximas vias
    if not lOk then break;

    // Verifica se é uma nova via
    if not (nLoop = Vias) then
    begin
      i      := 1;
      sLinha := '';
      // Processo para nova via
      PulaLinha(9);
      Sleep(5000);
    end;

  end;

  result := Status( 1,IntToStr(iRet) );

end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.RelatorioGerencial(Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
begin
  result := AbreCupomNaoFiscal( '', '', '', '' );
  if copy( result,1,1 ) = '0' then
  begin
    result := TextoNaoFiscal( Texto, Vias );
    if copy( result,1,1 ) = '0' then
      result := FechaCupomNaoFiscal;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet    : Integer;
  lpValor : PChar;
  sCupom : AnsiString;
  sPDV   : AnsiString;
  sArq   : AnsiString;
  fArq   : TextFile;
begin
  sPDV:=PegaPDV;
  sPDV:=Copy(sPDV,3,length(sPDV));
  sArq:='C:\URANO'+sPDV+'.URN';
  if not FileExists(sArq) Then
     Begin
     lpValor := StrAlloc( 22 );
     iRet := fFuncLeRegistrador( '40',lpValor );
     result := Status( 1,IntToStr(iRet) );
     if copy( result,1,1 ) = '0' then
        result := result + Trim(strpas(lpValor));
        StrDispose( lpValor );
     end
  else
     Begin
     AssignFile( fArq,sArq );
     Reset( fArq );
     ReadLn( fArq,sCupom );
     CloseFile( fArq );
     Application.ProcessMessages;
     Result:='0|'+sCupom;
     end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.PegaPDV:AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
begin
  lpValor := StrAlloc( 22 );
  iRet := fFuncLeRegistrador( '48',lpValor );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    result := result + Trim(strpas(lpValor));
  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.PegaSerie : AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
begin
  lpValor := StrAlloc( 22 );
  iRet := fFuncLeRegistrador( '47',lpValor );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    result := result + Trim(strpas(lpValor));
  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sAliq : AnsiString;
  aAliq : TaString;
  iRet : Integer;
  i : Integer;
  iPos : Integer;
  sSituacao : AnsiString;
  sTrib : AnsiString;
  sDecimais : AnsiString;
  iDecQuant : Integer;
begin
  codigo := Trim(codigo);
  descricao := Trim(descricao);
  // Verica o ponto decimal dos parâmetros
  qtde := StrTran(qtde,',','.');
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');

  //verifica se é para registra a venda do item ou só o desconto
  // Porque nao usa a funcao de desconto ???
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
    If StrToFloat(vlrdesconto) > 0 then
      begin
      iRet := fFuncDescontoItem( '0',' ',FormataTexto(vlrdesconto,10,2,2) );
      result := Status( 1,IntToStr(iRet) );
      end
    else
      result := '0';

    exit;
    end;

  // Faz o tratamento da aliquota
  sSituacao := copy(aliquota,1,1);
  aliquota := StrTran(copy(aliquota,2,5),',','.');
  // Pega as aliquotas
  sAliq := LeAliquotas;
  MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

  // Verifica se existe a aliquota
  iPos := 99;
  For i := 0 to Length(aAliq)-1 do
  begin
    sAliq := StrTran(aAliq[i],',','.');
    if StrTran(aAliq[i],',','.') = aliquota then
      iPos := i;
  end;

  if sSituacao = 'T' then
    sTrib := IntToStr(iPos)  // 00 a 15 são aliquotas
  else if sSituacao = 'S' then // Iss
    sTrib := '23'
  else if sSituacao = 'F' then // Substituicao
    sTrib := '16'
  else if sSituacao = 'I' then // Isento
    sTrib := '17'
  else if sSituacao = 'N' then // Nao tributado
    sTrib := '18';

  if (iPos = 99) and (Pos(sSituacao,'T') > 0) then
  begin
    ShowMessage('Não existe a alíquota informada.');
    result := '1';
    exit;
  end;

  FormataTexto(qtde,7,3,1);

  // Faz o tratamento das casas decimais da quantidade.
  If StrToFloat(copy(qtde,Pos('.',qtde)+1,Length(qtde))) > 0 then
  begin
    sDecimais := copy(qtde,Pos('.',qtde)+1,Length(qtde));
    i := Length(sDecimais);
    While i > 0 do
    begin
      If copy(sDecimais,i,1) = '0' then
      begin
        sDecimais := copy(sDecimais,1,i-1);
        Dec(i);
      end
      else
        i := 0;
    end;
    iDecQuant := Length(sDecimais);
  end
  Else
    iDecQuant := 0;

  qtde := FormataTexto(qtde,7,iDecQuant,1);

  // Registra Item
  iRet := fFuncVendaItem( copy(codigo,1,13),
                          copy(descricao,1,66),
                          qtde,
                          StrTran(vlrUnit,'.',''),
                          sTrib,
                          'Un',
                          '0' );
  result := Status( 1,IntToStr(iRet) );
  If StrToFloat(vlrdesconto) > 0 then
  begin
    iRet := fFuncDescontoItem( '0',' ',FormataTexto(vlrdesconto,10,2,2) );
    result := Status( 1,IntToStr(iRet) );
  end;

end;

//---------------------------------------------------------------------------
function TImpFiscalUranoII.FechaEcf : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncRelatorio_XZ( '1' );
  result := Status( 1, IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
     begin
     fFuncFinalizaRelatorio( ' ' );
     PulaLinha( 6 );
     end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.Pagamento( Pagamento, Vinculado, Percepcion : AnsiString ): AnsiString;
var
  aAuxiliar : TaString;
  iRet,i : Integer;
begin
  iRet := 0;
  // Verifica o parametro
  Pagamento := StrTran(Pagamento,',','.');
  // Monta um array auxiliar com as formas solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Faz o registro do pagamento
  i:=0;
  While i<Length(aAuxiliar) do
    begin
    iRet := fFuncPagamento( aAuxiliar[i],FormataTexto(aAuxiliar[i+1],11,2,2));
    Inc(i,2);
  end;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.GravaCondPag( condicao:AnsiString ):AnsiString;
begin
  ShowMessage('Função não disponivél para este equipamento' );
  result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
var iRet : Integer;
begin
   FechaCupomNaoFiscal;
   iRet := fFuncCargaNaoVinculado;
   result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.FechaCupomNaoFiscal: AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFechaCupom(' ', ' ' );
  result := Status( 1,IntToStr(iRet) );
  if copy(result,1,1) = '0' then
  begin
     iRet := fFuncFechaCupomNFiscal;
     result := Status( 1,IntToStr(iRet) );
     if copy(result,1,1) = '0' then PulaLinha( 6 );
  end;
end;
//----------------------------------------------------------------------------
function TImpFiscalUranoII.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
  i    : Integer;
begin
  iRet := 1;
  if Vezes>2 then
     Vezes:=2;

  For i:=1 to Vezes do
    begin
    ShowMessage('Posicione o Documento para Autenticação.');
    iRet := fFuncAutentica(valor+'  '+Texto);
    if iRet<> 0 then
       Break;

    end;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.CancelaCupom( Supervisor:AnsiString ):AnsiString;
var
  iRet : Integer;
  sPDV : AnsiString;
  sArq : AnsiString;
begin
  iRet := fFuncCancelaVenda( ' ' );
  result := Status(1,IntToStr(iRet));
  if copy(result,1,1) <> '0' then
  begin
    sPDV:=PegaPDV;
    sPDV:=Copy(sPDV,3,length(sPDV));
    sArq:='C:\URANO'+sPDV+'.URN';
    if not FileExists(sArq) Then
      iRet := fFuncCancelaCupom( ' ' );
  end;
  result := Status(1,IntToStr(iRet));
  if copy( result,1,1 ) = '0' then
  begin
    sPDV:=PegaPDV;
    sPDV:=Copy(sPDV,3,length(sPDV));
    sArq:='C:\URANO'+sPDV+'.URN';
    if FileExists(sArq) Then
       deleteFile(sArq);
    Pulalinha( 6 );
  end
  else
  begin
    sPDV := PegaPDV;
    sPDV := Copy(sPDV,3,length(sPDV));
    sArq := 'C:\URANO'+sPDV+'.URN';
    if FileExists(sArq) then
    begin
      // Registra um item qualquer
      iRet := fFuncVendaItem( '1', 'Cancelamento', FormataTexto( '1',7,3,1 ),
                              '000000001', '17', 'Un', '0' );
      result := Status( 1,IntToStr(iRet) );
      if copy(Status(1,IntToStr(iRet)),1,1) = '0' then
      begin
        iRet := fFuncCancelaVenda( ' ' );
        if copy(Status(1,IntToStr(iRet)),1,1) <> '0' then
          iRet := fFuncCancelaCupom( ' ' );
        result := Status( 1,IntToStr(iRet) );
        if copy( result,1,1 ) = '0' then
        begin
          if FileExists(sArq) Then
            deleteFile(sArq);
          Pulalinha( 6 );
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
  iRet : Integer;
  sPDV   : AnsiString;
  sArq, sMsg   : AnsiString;
begin
  sMsg := Mensagem;
  sMsg := TrataTags( sMsg );
  if sMsg <> '' then
    fFuncPropaganda( '0', sMsg );

  iRet := fFuncFechaCupom(' ',' ' );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    Begin
    sPDV:=PegaPDV;
    sPDV:=Copy(sPDV,3,length(sPDV));
    sArq:='C:\URANO'+sPDV+'.URN';
    if FileExists(sArq) Then
       deleteFile(sArq);

    PulaLinha( 6 );
    end;
end;
//----------------------------------------------------------------------------
function TImpFiscalUranoII.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
  procedure CriaArq( sArquivo : AnsiString );
  var
    sCupom : AnsiString;
    fArq   : TextFile;
  begin
    sCupom:=PegaCupom('F');
    sCupom:=Copy(sCupom,3,length(sCupom));
    sCupom:=FormataTexto( IntToStr(StrToInt(sCupom)+1),6,0,2);
    AssignFile( fArq,sArquivo );
    ReWrite( fArq );
    WriteLn( fArq,sCupom );
    CloseFile( fArq );
    Application.ProcessMessages;
  end;

var
  iRet, iStat : Integer;
  sPDV, sArq : AnsiString;
begin

  sPDV:=PegaPDV;
  sPDV:=Copy(sPDV,3,length(sPDV));
  sArq:='C:\URANO'+sPDV+'.URN';
  if not FileExists(sArq) then
    CriaArq( sArq );

  iRet := fFuncImprimeCabecalho;
  if iRet = 73 then
  begin
    iStat := fFuncStatusImpressora;
    // Se foi necessario cancelar o cupom fiscal, entao abre um novo.
    if Pos(IntToStr(iStat),'99;100;101') <> 0 then
    begin
      CancelaCupom('');
      iRet := fFuncImprimeCabecalho;
      CriaArq( sArq );
    end;
  end;
  result := Status( 1,IntToStr(iRet) );

end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
var
  iRet   : Integer;
  sAliq  : AnsiString;
  sPos   : AnsiString;
  aAliq  : TaString;
  bAchou : Boolean;
  i : Integer;
begin
  Aliquota := StrTran(Aliquota,',','.');
  bAchou := False;
  sAliq := LeAliquotas;
  MontaArray(Copy(sAliq,2,Length(sAliq)), aAliq);

  For i:=0 to Length(aAliq)-1 do
    if StrTran(aAliq[i],',','.') = Aliquota then
    begin
      bAchou := True;
      break;
    end;

  if not bAchou then
  begin
    For i := 0 to Length(aAliq)-1 do
      if (aAliq[i] = '') or (StrToFloat(aAliq[i]) = 0) then
      begin
        sAliq := FormataTexto(IntToStr(i),2,0,2);
        break;
      end;
    if StrToInt(sAliq) <= 15 then
    begin
      sPos := FormataTexto(Aliquota,4,2,2);
      iRet := fFuncCargaAliquota( sAliq, sPos );
      result := Status( 1,IntToStr(iRet) );
    end
    else
    begin
      ShowMessage('Não há mais espaço em memória para adicionar alíquotas.');
      result := '6|';
    end;
  end
  else
  begin
    ShowMessage('Aliquota já Cadastrada.');
    result := '4|';
  end;

end;
//----------------------------------------------------------------------------
function TImpFiscalUranoII.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncLeituraMF( '0', FormataData(DataInicio,1), FormataData(DataFim,1),'    ','    ');
  result := status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    PulaLinha( 6 );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
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
// 43 e 44- Reservado Autocom
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware


// Aloca memória no ponteiro lpValor
lpValor := StrAlloc( 22 );
StrPCopy( lpValor, '' );

// Faz a leitura da Hora
if Tipo = 1 then
begin
  iRet := fFuncLeRegistrador( '50', lpValor );
  result := Trim(strpas(lpValor));
  result := Status( 1, IntToStr(iRet) ) + result;
end
// Faz a leitura da Data
else if Tipo = 2 then
begin
  iRet := fFuncLeRegistrador( '49', lpValor );
  result := Trim(strpas(lpValor));
  result := Status( 1, IntToStr(iRet) ) + result;
end
// Faz a checagem de papel
else if Tipo = 3 then
begin
  //checa se tem papel
  iRet := fFuncLeSensor( '0' );
  if iRet = 48 then // sensor desligado
  begin
    //checa se tem pouco papel
    iRet := fFuncLeSensor( '1' );
    if iRet = 48 then // sensor desligado
      result := '0'
    else if iRet = 49 then // sensor ligado
      result := '3';
  end
  else if iRet = 49 then // sensor ligado
    result := '2'
  else
    result := '0';
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  iRet := fFuncStatusImpressora;
  if iRet= 99 then
     result:='0|'
   else
     result:='7|';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
  result := '0'
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
else If Tipo = 45 then
       Result := '0|'// 45 Codigo Modelo Fiscal
else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
       Result := '0|'// 45 Codigo Modelo Fiscal
else
  Result := '1';

StrDispose(lpValor);
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.Status( Tipo:Integer; Texto:AnsiString ):AnsiString;
  // Parametros
  // 1- Verifica se o ultimo comando foi executado
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
    result := '1|'
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
procedure TImpFiscalUranoII.PulaLinha( iNumero:Integer );
begin
  fFuncAvancaLinhas(0,iNumero );

end;

//----------------------------------------------------------------------------
procedure TImpFiscalUranoII.AlimentaProperties;
var
  iRet     : Integer;
  i        : Integer;
  lpValor  : PChar;
  sAliq    : AnsiString;
  sAliqTmp : AnsiString;
  sTodas   : AnsiString;

begin
  lpValor   := StrAlloc(22);
  FillChar(lpValor^,22,0);
  sAliq     := '';
  ICMS      := '';
  ALIQUOTAS := '';
  ISS       := '';
  For i:=56 to 71 do
  begin
    iRet := fFuncLeRegistrador( PChar(FormataTexto(IntToStr(i),2,0,2)),lpValor );
    if Trim(StrPas(lpValor)) <> '' then
      sAliqTmp := StrTran(StrPas(lpValor),',','')
    Else
      sAliqTmp := '0';

    try
      if StrToFloat(sAliqTmp) <> 0 then
         sAliq := sAliq + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';

      sTodas := sTodas + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';

    except
    end;

  end;

  if (iRet = 0 ) then
  Begin
    ICMS      := sAliq;
    ALIQUOTAS := sTodas;
  End;

  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.BuscaTotalizador(Totalizador:AnsiString):AnsiString;
var sPath, sTotal : AnsiString;
var fArquivo : TIniFile;
var i : Integer;
begin
  // Verifica o path de onde esta o arquivo DREGIS.INI
  sPath := ExtractFilePath(Application.ExeName);

  // A Urano 2.0 não tem totalizadores para cupom não fiscal. Dessa forma deve
  // ser mantido na estação que estiver conectada a impressora um arquivo com
  // as formas de pagamento chamado URANOII.INI, no seguinte formato:
  // [TOTALIZADORES]
  // 1=SUPRIMENTOS DE CAIXA
  // 2=CHEQUE
  // 3=SINAL ...
  if not FileExists( sPath + 'URANOII.INI' ) then
  begin
     ShowMessage( 'O arquivo de totalizadores não fiscais URANOII.INI não foi encontrado.' );
     result := '1';
  end
  else
    try
      fArquivo := TIniFile.Create(sPath+'URANOII.INI');
      sTotal := '.';
      result := '';
      i := 1;
      while Trim(sTotal) <> '' do
      begin
        sTotal := fArquivo.ReadString('TOTALIZADORES', IntToSTr(i) ,'');
        if i = StrToInt( Totalizador ) then
          result := sTotal;
        Inc(i);
      end;
      if result = '' then
      begin
        ShowMessage( 'Totalizador ' + Totalizador + ' não encontrado.' );
        result := '1';
      end;
    except
      result := '1';
    end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoII.Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
var iRet, iEspacos, i : Integer;
var sTotal, sLinha, sValImp : AnsiString;
var aPagamento : array [1 .. 3 ] of AnsiString;
begin
  sTotal := BuscaTotalizador(Total);
  if sTotal <> '1' then
  begin
    iRet := fFuncCargaNaoVinculado;
    result := Status( 1, IntToStr( iRet ) );
    if copy( result, 1, 1 ) <> '1' then
    begin
      // Imprime a primeira linha
      iRet := fFuncLinhasLivres( Space( 18 ) + sTotal );
      result := Status( 1, IntToStr( iRet ) );
      if copy( result, 1, 1 ) <> '1' then
      begin
        // Imprime a segunda linha
        sLinha := Trim( sTotal );
        while length( sLinha ) < 28 do
          sLinha := sLinha + ' ';
        sValImp := ' R$';
        // Monta AnsiString do valor para utilizar nas proximas linhas
        iEspacos := 15 - length( Valor ); // Calcula espacos antes do valor
        while length( sValImp ) < iEspacos do
          sValImp := sValImp + ' ';
        sValImp := sValImp + Valor;
        sLinha := sLinha + sValImp;
        iRet := fFuncLinhasLivres( sLinha );
        result := Status( 1, IntToStr( iRet ) );
        if copy( result, 1, 1 ) <> '1' then
        begin
          // Imprime terceira linha
          iRet := fFuncLinhasLivres( Space( 32 ) + '----------------' );
          result := Status( 1, IntToStr( iRet ) );
          if copy( result, 1, 1 ) <> '1' then
          begin
            // Imprime Pagamento
            aPagamento[ 1 ] := 'SOMA';
            aPagamento[ 2 ] := Trim( Forma );
            aPagamento[ 3 ] := 'VALOR RECEBIDO';
            for i := 1 to 3 do
            begin
              sLinha := aPagamento[ i ];
              sLinha := sLinha + Space( 30 - length( sLinha ) );
              sLinha := sLinha + sValImp;
              iRet := fFuncLinhasLivres( sLinha );
              result := Status( 1, IntToStr( iRet ) );
              if copy( result, 1, 1 ) <> '1' then break;
            end;
            if copy( result, 1, 1 ) <> '1' then
            begin
              iRet := fFuncFechaCupomNFiscal;
              result := Status( 1, IntToStr( iRet ) );
            end;
          end;
        end;
      end;
    end;
  end
  else
    result := '1';
end;

//---------------------------------------------------------------------------
function TImpFiscalUranoLog.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;

  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: DllLOG32.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;
  i : Integer;
  sAliq : AnsiString;
  aAliq : TaString;
begin
  sNFiscal:='';
  fHandle := LoadLibrary( 'DllLOG32.DLL' );
  if (fHandle <> 0) Then
  begin
    bRet := True;

    aFunc := GetProcAddress(fHandle,'ecf_InicializaDLL');
    if ValidPointer( aFunc, 'ecf_InicializaDll' ) then
      fFuncInicializaDll := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_FinalizaDLL');
    if ValidPointer( aFunc, 'ecf_FinalizaDll' ) then
      fFuncFinalizaDll := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_ImprimeCabecalho');
    if ValidPointer( aFunc, 'ecf_ImprimeCabecalho' ) then
      fFuncImprimeCabecalho := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_VendaItem');
    if ValidPointer( aFunc, 'ecf_VendaItem' ) then
      fFuncVendaItem := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_CancelaItem');
    if ValidPointer( aFunc, 'ecf_CancelaItem' ) then
      fFuncCancelaItem := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_DescontoItem');
    if ValidPointer( aFunc, 'ecf_DescontoItem' ) then
      fFuncDescontoItem := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_Pagamento');
    if ValidPointer( aFunc, 'ecf_Pagamento' ) then
      fFuncPagamento := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_FechaCupom');
    if ValidPointer( aFunc, 'ecf_FechaCupom' ) then
      fFuncFechaCupom := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_LinhasLivres');
    if ValidPointer( aFunc, 'ecf_LinhasLivres' ) then
      fFuncLinhasLivres := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_CancelaVenda');
    if ValidPointer( aFunc, 'ecf_CancelaVenda' ) then
      fFuncCancelaVenda := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_CancelaCupom');
    if ValidPointer( aFunc, 'ecf_CancelaCupom' ) then
      fFuncCancelaCupom := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_AcrescimoSubtotal');
    if ValidPointer( aFunc, 'ecf_AcrescimoSubtotal' ) then
      fFuncAcrescimoSubTotal := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_DescontoSubtotal');
    if ValidPointer( aFunc, 'ecf_DescontoSubtotal' ) then
      fFuncDescontoSubTotal := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_Relatorio_XZ');
    if ValidPointer( aFunc, 'ecf_Relatorio_XZ' ) then
      fFuncRelatorio_XZ := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_FinalizaRelatorio');
    if ValidPointer( aFunc, 'ecf_FinalizaRelatorio' ) then
      fFuncFinalizaRelatorio := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_CargaAliquota');
    if ValidPointer( aFunc, 'ecf_CargaAliquota' ) then
      fFuncCargaAliquota := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_CargaCliche');
    if ValidPointer( aFunc, 'ecf_CargaCliche' ) then
      fFuncCargaCliche := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_Propaganda');
    if ValidPointer( aFunc, 'ecf_Propaganda' ) then
      fFuncPropaganda := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_AbreGaveta');
    if ValidPointer( aFunc, 'ecf_AbreGaveta' ) then
      fFuncAbreGaveta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_AvancaLinhas');
    if ValidPointer( aFunc, 'ecf_AvancaLinhas' ) then
      fFuncAvancaLinhas := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_EstadoImpressora');
    if ValidPointer( aFunc, 'ecf_EstadoImpressora' ) then
      fFuncEstadoImpressora := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_LeRegistrador');
    if ValidPointer( aFunc, 'ecf_LeRegistrador' ) then
      fFuncLeRegistrador := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_Autentica');
    if ValidPointer( aFunc, 'ecf_Autentica' ) then
      fFuncAutentica := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_LeSensor');
    if ValidPointer( aFunc, 'ecf_LeSensor' ) then
      fFuncLeSensor := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_IdComprador');
    if ValidPointer( aFunc, 'ecf_IdComprador' ) then
      fFuncIdComprador := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_CupomStub');
    if ValidPointer( aFunc, 'ecf_CupomStub' ) then
      fFuncCupomStub := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_FormaPagamento');
    if ValidPointer( aFunc, 'ecf_FormaPagamento' ) then
      fFuncFormaPagamento := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_CargaNaoVinculado');
    if ValidPointer( aFunc, 'ecf_CargaNaoVinculado' ) then
      fFuncCargaNaoVinculado := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_EmiteNaoVinculado');
    if ValidPointer( aFunc, 'ecf_EmiteNaoVinculado' ) then
      fFuncEmiteNaoVinculado := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_Vinculado');
    if ValidPointer( aFunc, 'ecf_Vinculado' ) then
      fFuncVinculado := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_CortaPapel');
    if ValidPointer( aFunc, 'ecf_CortaPapel' ) then
      fFuncCortarPapel := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_ProgramaRelogio');
    if ValidPointer( aFunc, 'ecf_ProgramaRelogio' ) then
      fFuncProgramaRelogio := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_LeECF');
    if ValidPointer( aFunc, 'ecf_LeECF' ) then
      fFuncLeECF := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ecf_EmiteNaoVinculado');
    if ValidPointer( aFunc, 'ecf_EmiteNaoVinculado' ) then
      fFuncEmiteNaoVinculado := aFunc
    else
    begin
      bRet := False;
    end;
  end
  else
  begin
    ShowMessage('O arquivo DllLOG32.DLL não foi encontrado.');
    bRet := False;
  end;

  if bRet then
  begin
    result := '0|';
    iRet:=fFuncInicializaDll( PChar(sPorta) );
    if iRet <> 33 then
      bRet := False;
    if not bRet then
    begin
      ShowMessage('Erro na abertura da porta');
      result := '1|';
    end
    Else
        For i := 1 to 3 do
        Begin
            AlimentaProperties;
            sAliq := LeAliquotas;
            MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );
            If Length(aAliq) <> 0 then break;
        End;
  end
  else
    result := '1|';
end;

//---------------------------------------------------------------------------
function TImpFiscalUranoLog.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  if (fHandle <> INVALID_HANDLE_VALUE) then
  begin
    if fFuncFinalizaDll <> 33 then
    begin
      ShowMessage('Erro ao fechar a comunicação com impressora Fiscal.');
      result := '1';
    end
    Else
      result := '0';
    FreeLibrary(fHandle);
    fHandle := 0;
  end;
end;

//----------------------------------------------------------------------------
procedure TImpFiscalUranoLog.AlimentaProperties;
var
  iRet     : Integer;
  i        : Integer;
  lpValor  : PChar;
  sAliq    : AnsiString;
  sAliqTmp : AnsiString;
  sTodas   : AnsiString;
  sRet     : AnsiString;
begin
  ICMS      := '';
  ALIQUOTAS := '';
  ISS       := '';
  sAliq     := '';
  sTodas    := '';
  lpValor   := StrAlloc(30);
  FillChar(lpValor^,30,0);
  For i:=20 to 31 do
  begin
    iRet := fFuncLeRegistrador(Pchar(FormataTexto(IntToStr(i),2,0,2)),lpValor );
    if Trim(StrPas(lpValor)) <> '' then
      sAliqTmp := StrTran(StrPas(lpValor),',','')
    else
      sAliqTmp := '0';
    try
      if StrToFloat(sAliqTmp) <> 0 then
        sAliq := sAliq + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';

        sTodas := sTodas + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';
    except
    end;
  end;

  if (iRet = 33) then
  Begin
    ICMS      := sAliq;
    ALIQUOTAS := sTodas;
  End;

  ISS := '';
  For i:=20 to 31 do
  begin
    fFuncLeRegistrador( PChar(FormataTexto(IntToStr(i),2,0,2)),lpValor );
    if Trim(StrPas(lpValor)) <> '' then
      sAliqTmp := StrTran(StrPas(lpValor),',','') ;
      if StrToFloat(sAliqTmp) <> 0 then
        ISS := ISS + FloatToStrf(StrToFloat(sAliqTmp)/100, ffFixed, 15, 2) + '|';
  end;

  iRet := fFuncLeRegistrador( '72',lpValor );
  sret := Status( 1,IntToStr(iRet) );
  if copy( sret,1,1 ) = '0' then
    PDV := Trim(strpas(lpValor));

  StrDispose( lpValor );
end;

//---------------------------------------------------------------------------
function TImpFiscalUranoLog.LeAliquotasISS:AnsiString;
begin
    Result:='0|'+ISS;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sAliq : AnsiString;
  aAliq : TaString;
  iRet : Integer;
  i : Integer;
  iPos : Integer;
  sSituacao : AnsiString;
  sTrib : AnsiString;
begin
  // Verica o ponto decimal dos parâmetros
  qtde := StrTran(qtde,',','.');
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    If StrToFloat(vlrdesconto) > 0 then
    begin
      iRet := fFuncDescontoItem( '0',' ',FormataTexto(vlrdesconto,10,2,2) );
      result := Status( 1,IntToStr(iRet) );
    end
    else
      result := '0';
    exit;
  end;

  // Faz o tratamento da aliquota
  sSituacao := copy(aliquota,1,1);
  aliquota := StrTran(copy(aliquota,2,5),',','.');
  // Pega as aliquotas
  sAliq := LeAliquotas;
  MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

  // Verifica se existe a aliquota
  iPos := 99;
  For i := 0 to Length(aAliq)-1 do
  begin
    sAliq := StrTran(aAliq[i],',','.');
    if StrTran(aAliq[i],',','.') = aliquota then
      iPos := i;
  end;

  if sSituacao = 'T' then
    sTrib := FormataTexto(IntToStr(iPos),2,0,2)
  else if sSituacao = 'S' then // Iss
    sTrib := '10'
  else if sSituacao = 'F' then // Substituicao
    sTrib := '12'
  else if sSituacao = 'I' then // Isento
    sTrib := '13'
  else if sSituacao = 'N' then // Nao tributado
    sTrib := '14';

  if (iPos = 99) and (Pos(sSituacao,'T') > 0) then
  begin
    ShowMessage('Não existe a alíquota informada.');
    result := '1';
    exit;
  end;

  qtde := Trim(FormataTexto(qtde,7,3,4));
  vlrUnit := Trim(FormataTexto(vlrUnit,9,2,2));

  try
    StrToFloat(Trim(Codigo));
    iRet := fFuncVendaItem( copy(Codigo,1,13),
                            copy(descricao,1,62),
                            qtde,
                            StrTran(vlrUnit,'.',''),
                            sTrib,
                            'Un',
                            '1' );
    result := Status( 1,IntToStr(iRet) );
    If StrToFloat(vlrdesconto) > 0 then
    begin
      iRet := fFuncDescontoItem( '0',' ',FormataTexto(vlrdesconto,9,2,2) );
      result := Status( 1,IntToStr(iRet) );
    end;

  except
    MsgStop('Esta impressora só aceita código do produto do tipo numérico');
    result := '1';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
begin
  lpValor := StrAlloc( 30 );
  FillChar(lpValor^,30,0);
  iRet := fFuncLeRegistrador( '65',lpValor );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    result := result + FormataTexto(IntToStr(StrToInt(Trim(strpas(lpValor)))+iSoma),6,0,2);
  iSoma := 0;
  StrDispose( lpValor );
end;

//---------------------------------------------------------------------------
function TImpFiscalUranoLog.LeCondPag:AnsiString;
var
  iRet : Integer;
  i : Integer;
  lpValor : PChar;
  sAliq : AnsiString;
begin
  lpValor := StrAlloc( 30 );
  FillChar(lpValor^,30,0);
  sAliq := '';
  For i:=33 to 47 do
  begin
    iRet := fFuncLeRegistrador( PChar(IntToStr(i)),lpValor );
    if Trim(StrPas(lpValor)) <> '' then
    begin
        sAliq := sAliq + copy(Trim(StrPas(lpValor)),1,Length(Trim(StrPas(lpValor)))) + '|';
    end;
  end;
  if (iRet = 33) then
    result := '0|' + sAliq
  else
    result := '1|';
  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.Pagamento( Pagamento,Vinculado,Percepcion : AnsiString ): AnsiString;
  function AchaPagto( sPagto:AnsiString; aPagtos:TaString ):AnsiString;
  var i, iPos, iTamCond : Integer;
  begin
    iPos := 99;
    for i:=0 to Length(aPagtos)-1 do
    begin
      iTamCond := Length(aPagtos[i]);
      if UpperCase(aPagtos[i]) = UpperCase(copy(sPagto,1,iTamCond)) then
      begin
        iPos := i;
        break;
      end;
    end;
    result := IntToStr(iPos);
    if iPos <> 99 then
      if Length(result) < 2 then
        result := '0' + result;
  end;
var
  sPagto : AnsiString;
  aPagto,aAuxiliar : TaString;
  sForma : AnsiString;
  iRet,i : Integer;
begin
  iRet := 0;
  // Verifica o parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Verifica parametro Vinculado
  if Vinculado <> '1' then Vinculado := '0';

  // Pega a condicao de pagamento
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Monta um array auxiliar com as formas solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Faz o registro do pagamento
  i:=0;
  While i<Length(aAuxiliar) do
  begin
    sForma:=AchaPagto(aAuxiliar[i],aPagto);
    if sForma <> '99' then
      iRet := fFuncPagamento( sForma, ' ', FormataTexto(aAuxiliar[i+1],10,2,2) );
    Inc(i,2);
  end;

  result := Status( 1,IntToStr(iRet) );

end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
  iRet : Integer;
  sMsg : AnsiString;
begin
  sMsg := Mensagem;
  sMsg := TrataTags( sMsg );
  if sMsg <> '' then
      fFuncPropaganda( sMsg + #0);
  iRet := fFuncFechaCupom( ' ' );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    PulaLinha( 6 );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.PegaPDV:AnsiString;
begin
    Result:='0|'+PDV;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.PegaSerie : AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
begin
  lpValor := StrAlloc( 22 );
  iRet := fFuncLeRegistrador( '067',lpValor );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    result := result + Trim(strpas(lpValor));
  StrDispose( lpValor );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
begin
    sNFiscal:= Condicao;     // nome da modalidade de pagamento
    result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
    Function Completa(Texto: AnsiString):AnsiString;
    begin
        While Length(Texto)<40 do
            Texto:= Texto+' ';
        Result:= Texto;
    end;
var iRet, i, fim, indice, j: Integer;
    sNovoTxt, sTexto, sLinha, sPagto, sPos : AnsiString;
    aPagto : TaString;
begin
  iRet   := 0;
  sLinha := '';
  sNovoTxt:= '';

  if Vias > 1 then stexto:=texto;
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)), aPagto );

  if sNFiscal<>'' then
  begin
     if Vias <= 1 then Vias:=0 else Vias:=1;
     for i := 0 to length(aPagto)-1 do
     begin
         if UpperCase(Trim(aPagto[i])) = UpperCase(Trim(sNFiscal)) then
           sPos := FormataTexto(IntToStr(i),2,0,2);
     end;

     While Pos(#10,Texto)>0 do
     begin
         If Pos(#10, Texto)<40 then
         begin
            indice:=Pos(#10,Texto);
            sNovoTxt:= sNovoTxt + Completa(Copy(Texto,1, indice-1));
            Texto:= Copy(Texto, indice+1, Length(Texto));
         end
         else
         begin
            sNovoTxt:=sNovoTxt+Copy(Texto, 1, 40);
            Texto:= Copy(Texto, 41, Length(Texto));
          end;
     end;
     If sNovoTxt='' then sNovoTxt:=sTexto;
     iRet:= fFuncVinculado(sPos,' ',' ', ' ',IntToStr(Vias), sNovoTxt, '05', '05');
  end
  else
  begin
    if Vias <= 1 then Vias:=1;
    //tem que mandar o texto linha a linha
    For i:=1 to Vias do
    begin
       If Length(texto)>0 then
       begin
           Repeat
                fim:=Length(texto);
                If Pos(#10,Copy(Texto, 1, 41))>0 then
                begin
                    If Pos(#10,Copy(Texto, 1, 41))= 1 then
                    begin
                        slinha := ' ';
                        texto:=Copy(Texto,2,fim);
                    end
                    Else
                    begin
                        indice:=Pos(#10,Copy(Texto, 1, 41));
                        slinha:= Pchar(Copy(Texto, 1, indice-1));
                        Texto:= Copy(Texto,indice+1,fim);
                    end;
                end
                else
                begin
                    sLinha:=Pchar(Copy(Texto,1,40));
                    Texto:=Copy(Texto,41,fim);
                end;
              j:=1;
              Repeat
                  iRet   := fFuncLinhasLivres( '041',sLinha );
                  j:=j+1;
              Until (iRet=33) or (j>4);
           until  Length(texto)< 2;
       end;
       texto:=stexto;
    end;
  end;

  PulaLinha(5);
  sNFiscal:='';
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var
  iRet : Integer;
begin
  vlrAcrescimo := StrTran(vlrAcrescimo,',','.');
  if StrToFloat(vlrAcrescimo) > 0 then
  begin
    iRet := fFuncAcrescimoSubTotal( ' ', PChar(FormataTexto(vlrAcrescimo,10,2,2)) );
    result := status( 1,IntToStr(iRet) );
  end
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
begin
result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.HorarioVerao( Tipo:AnsiString ):AnsiString;
var
  nRet: integer;
begin
  If Tipo='+' then Tipo:='1' else Tipo:='2';
  nRet:=fFuncProgramaRelogio(Tipo,'','');
  Result := Status(1,IntToStr(nRet));
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncCancelaItem(FormataTexto(numitem,3,0,2) );
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet : Integer;
  lpValor : PChar;
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
// 43 e 44- Reservado Autocom
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware

// Aloca memória no ponteiro lpValor
lpValor := StrAlloc( 30 );
FillChar(lpValor^,30,0);
StrPCopy( lpValor, '' );

// Faz a leitura da Hora
if Tipo = 1 then
begin
  iRet := fFuncLeRegistrador( '64', lpValor );
  result := Trim(strpas(lpValor));
  result := Status( 1, IntToStr(iRet) ) + result;
end
// Faz a leitura da Data
else if Tipo = 2 then
begin
  iRet := fFuncLeRegistrador( '63', lpValor );
  result := Copy(Trim(strpas(lpValor)),1,6)+Copy(Trim(strpas(lpValor)),9,2);
  result := Status( 1, IntToStr(iRet) ) + result;
end
// Faz a checagem de papel
else if Tipo = 3 then
begin
  //checa se tem papel
  iRet := fFuncLeSensor( '3' );
  if iRet = 48 then // sensor desligado
  begin
    //checa se tem pouco papel
    iRet := fFuncLeSensor( '4' );
    if iRet = 48 then // sensor desligado
      result := '0'
    else if iRet = 49 then // sensor ligado
      result := '3';
  end
  else if iRet = 49 then // sensor ligado
    result := '2'
  else
    result := '0';

  if (iRet = 48) or (iRet = 49) then
    result := '0|' + result
  else
    result := '1|' + result;
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  iRet := fFuncEstadoImpressora;
  If iRet <> 200 then
    result := '7'
  Else
    result := '0';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  iRet := fFuncEstadoImpressora;
  If iRet = 207 then
    result := '10'
  Else
    result := '0';
end
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
  result := '0'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  result := '0'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 Then
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
else If Tipo = 45 then
       Result := '0|'// 45 Codigo Modelo Fiscal
else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
       Result := '0|'// 45 Codigo Modelo Fiscal
else
  Result := '1';

StrDispose(lpValor);
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString;
var
  iRet : Integer;
begin
  vlrDesconto := StrTran(vlrDesconto,',','.');
  if StrToFloat(vlrDesconto) > 0 then
  begin
    iRet := fFuncDescontoSubTotal( ' ', FormataTexto(vlrDesconto,7,2,2) );
    result := Status( 1,IntToStr(iRet) );
  end
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString;
var
  iRet            : Integer;
  sDataIn,sDataFim: AnsiString;
  sFile           : AnsiString;
  sArquivo        : AnsiString;
Begin
  sArquivo := 'MEMFISC.RET';

  if (Tipo='I') OR (Pos('I', UpperCase(Tipo)) > 0) then
  // Leitura da memoria para Impressora
  Begin
     if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
     Begin
        ReducInicio:= FormataTexto(ReducInicio,6,0,2);
        ReducFim   := FormataTexto(ReducFim,6,0,2);
        iRet       := fFuncLeECF( '1', ReducInicio, ReducFim,' ',' ');
     End
     Else
     Begin
        sDataIn    := FormataData(DataInicio,2);
        sDataFim   := FormataData(DataFim,2);
        iRet       := fFuncLeECF( '0', sDataIn, sDataFim,' ',' ');
     End;
     result := Status( 1,IntTostr(iRet) );
     if copy(result,1,1) = '0' then
        PulaLinha(7);
  End
  Else
  // Leitura da memoria para disco
  Begin
     result:= '0';
     sFile := ExtractFilePath(Application.ExeName);
     if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
     Begin
        ReducInicio:=FormataTexto(ReducInicio,6,0,2);
        ReducFim   :=FormataTexto(ReducFim,6,0,2);
        iRet       := fFuncLeECF( '5', ReducInicio, ReducFim,' ',sFile + sArquivo);
     End
     Else
     Begin
        sDataIn    := FormataData(DataInicio,1);
        sDataFim   := FormataData(DataFim,1);
        iRet       := fFuncLeECF( '4', sDataIn, sDataFim,' ',sFile + sArquivo);
     End;
     Result := Status( 1,IntTostr(iRet) );

     If Copy(Result, 1, 1) = '0' then
        Result := CopRenArquivo( sFile, sArquivo, PathArquivo, DEFAULT_ARQMEMCOM );

  End;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString;
var iRet : Integer;
begin
  result := TextoNaoFiscal( Texto, Vias );
  if copy( result,1,1 ) = '0' then
  begin
    iRet   := fFuncFinalizaRelatorio( ' ' );
    result := Status( 1, IntToStr(iRet) );
    if copy( result, 1, 1 ) = '0'
    then PulaLinha(6);
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.ReImpCupomNaoFiscal( Texto:AnsiString ): AnsiString;
begin
  // essa impressora não possui esse recurso.
  result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.FechaCupomNaoFiscal: AnsiString;
begin
  result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.ReducaoZ( MapaRes:AnsiString ):AnsiString;
    function Organiza(Valor:AnsiString):AnsiString;
    var sValor: AnsiString;
        i : integer;
    begin
      if (Pos('.',Valor)>0) then
      begin
        sValor:=Valor;
        Valor:='';
        For i:=1 to Length(sValor) do
          If sValor[i]<>'.' then
            Valor:=Valor+sValor[i];
      end;
      Result:=Valor;
    end;
Var
  aRetorno        : array of AnsiString;
  pValor          : pChar;
  i, iRet : integer;
  sAux    : AnsiString;
begin

 pValor   := StrAlloc(30);
 FillChar(pValor^,30,0);

 If Trim(MapaRes)='S' then
 Begin
       // Prepara o array, aRetorno, com os dados do ECF...
      SetLength(aRetorno,21);

      fFuncLeRegistrador('063',pValor );
      aRetorno[ 0]:=trim(pValor);
      aRetorno[ 0]:=Copy(aRetorno[0],1,6)+Copy(aRetorno[0],9,2);   // Data Fiscal (DDMMAA)

      fFuncLeRegistrador('072',pValor );
      aRetorno[ 1]:= Trim(pValor);                                 // Nr. ECF

      fFuncLeRegistrador('067',pValor );
      aRetorno[ 2]:= Trim(pValor);                                 // Identificação do Equipamento

      fFuncLeRegistrador('075',pValor );
      aRetorno[ 4]:= Organiza(Trim (pValor));
      aRetorno[ 4]:= FormataTexto(aRetorno[4], 19, 2, 1, '.');     // GT

      fFuncLeRegistrador('125',pValor );
      aRetorno[ 5]:= Trim(pValor);                                 // COO inicial

      fFuncLeRegistrador('065',pValor );
      aRetorno[ 6]:= Trim(pValor);                                 // --Numero documento Final--

      fFuncLeRegistrador('001',pValor);
      aRetorno[ 7]:= Organiza(Trim (pValor));
      aRetorno[ 7]:= FormataTexto(aRetorno[7], 15, 2, 1, '.');     // Total de Vendas canceladas no dia	  (12 dígitos)

      fFuncLeRegistrador('077',pValor );
      aRetorno[ 8]:= Organiza(Trim (pValor));
      aRetorno[ 8]:= FormataTexto(aRetorno[8], 15, 2, 1, '.');     // Total Líquido do Dia	  (12 dígitos)

      fFuncLeRegistrador('002',pValor );
      aRetorno[ 9]:= Organiza(Trim(pValor));
      aRetorno[ 9]:=FormataTexto(aRetorno[9],12,2,3);
      fFuncLeRegistrador('003',pValor );
      sAux:= Organiza(Trim(pValor));
      sAux:=FormataTexto(sAux,12,2,3);
      aRetorno[9]:=FormataTexto(FloatToStr(StrToFloat(aRetorno[9])+StrToFloat(Trim(sAux))),12,2,1,'.');   // Total de Descontos no Dia	  (12 dígitos)

      fFuncLeRegistrador('017',pValor);
      aRetorno[10]:= Organiza(Trim (pValor));
      aRetorno[10]:= FormataTexto(aRetorno[10], 12, 2, 1, '.');             // Total Substituição	(12 dígitos)

      fFuncLeRegistrador('018',pValor);
      aRetorno[11]:= Organiza(Trim (pValor));
      aRetorno[11]:= FormataTexto(aRetorno[11], 12, 2, 1, '.');             // Total Isento	(12 dígitos)

      fFuncLeRegistrador('019',pValor);
      aRetorno[12]:= Organiza(Trim (pValor));
      aRetorno[12]:= FormataTexto(aRetorno[12], 12, 2, 1, '.');             // Total Não Tributável	(12 dígitos)

      aRetorno[13]:= '';                                                    // --data da reducao z-- n tem como capturar nessa impressora

      aRetorno[15]:= FormataTexto('0',16, 0, 2);                            // --outros recebimentos--

      // TOTAL ISS - Adrianne Furtado - Em 19/set/02 entrei em contato com Felipe/Suporte Urano
      // (F.: 51-462-8707) que me informou não haver possibilidade de capturar o Imposto Final e o
      // Tipo(ISS, ICMS) da taxa.
      // Sendo possível apenas capturar a Alíquota(%) e a Base de Cálculo(Valor Vendido).
      // Por isso esse parãmetro não foi implementado e Retorno[18] retorna '00'
      aRetorno[16]:= FormataTexto('0',14, 2, 1)+' '+FormataTexto('0',14, 2, 1);   //Total ISS

      // Suporte Urano informou que não há como capturar essa informação nessa versão(2.20) da Logger.
      aRetorno[17]:= '000';                                         //CRO - Contador de Reinício de Operação
      aRetorno[18]:= FormataTexto( '0', 14, 2, 1 );                 // desconto de ISS
      aRetorno[19]:= FormataTexto( '0', 14, 2, 1 );                 // cancelamento de ISS
      aRetorno[20]:= '00';                                          // QTD DE Aliquotas
 end;

  iRet := fFuncRelatorio_XZ( '1' );

  If Trim(MapaRes)='S' then
  Begin
    // Delay de aproximadamente 2 minutos para pegar o COO e o contador de Reduções...
    fFuncLeRegistrador('120',pValor );
    aRetorno[ 3] := Trim(pValor);                                         // Número de Reduçöes

    fFuncLeRegistrador('065',pValor );
    aRetorno[14]:= Trim(pValor);                                          // Sequencial de Operação  (4 dígitos)

    Result := '0|';
    PulaLinha( 6 );
    For i:= 0 to High(aRetorno) do
      Result := Result + aRetorno[i]+'|';
  End
  Else
  Result:=(Status(1,IntToStr(iRet)));

  StrDispose( pValor );

end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
    function Organiza(Valor:AnsiString):AnsiString;
    var sValor: AnsiString;
        i : integer;
    begin
      if (Pos('.',Valor)>0) then
      begin
        sValor:=Valor;
        Valor:='';
        For i:=1 to Length(sValor) do
          If sValor[i]<>'.' then
            Valor:=Valor+sValor[i];
      end;
      Result:=Valor;
    end;
var i : Integer;
    sTroco, sPos: AnsiString;
    aPagamento : array [1 .. 15 ] of AnsiString;
    pValor : PChar;
begin
  // Tipo = 1 - Verifica se tem troco disponivel
  // Tipo = 2 - Grava o valor informado no Suprimentos
  // Tipo = 3 - Sangra o valor informado

  pValor := StrAlloc(30);
  FillChar(pValor^,30,0);

  sPos:='';

  If Tipo = 1 then
  begin
     For i:=33 to 47 do
     begin
         fFuncLeRegistrador(Pchar(IntToStr(i)),pValor);
         aPagamento[i-32]:=pValor;
     end;
     For i:=0 to 14 do
     begin
         If Trim(aPagamento[i+1])='DINHEIRO' then
             sPos:=IntToStr(i+48);
     End;
     If sPos<>'' then
     begin
         fFuncLeRegistrador(pChar(sPos),pValor);
         sTroco:= pValor;
     End;
     sTroco:=FormataTexto(Organiza(Trim(sTroco)),12,2,3);
     If StrToFloat(sTroco) >= StrToFloat(Trim(Valor)) then
         Result:='8'
     Else
         Result:='9';
  End;

  If Tipo = 2 then
  begin
     For i:=78 to 87 do
     begin
         fFuncLeRegistrador(Pchar(IntToStr(i)),pValor);
         aPagamento[1]:=pValor;
         If UpperCase(Trim(aPagamento[1]))='SUPRIMENTO' then
            aPagamento[2]:=IntToStr(i-78)
     end;

     fFuncEmiteNaoVinculado(aPagamento[2],' ',Valor);

     For i:=33 to 47 do
     begin
         fFuncLeRegistrador(Pchar(IntToStr(i)),pValor);
         aPagamento[i-32]:=pValor;
     end;
     For i:=0 to 14 do
     begin
         If Uppercase(Trim(aPagamento[i+1]))=UpperCase(Forma) then
             sPos:=FormataTexto(IntToStr(i),2,0,1);
     End;
       fFuncPagamento((sPos),' ',Valor);
       fFuncFechaCupom(' ');
  End;

  If Tipo = 3 then
  begin
     For i:=78 to 87 do
     begin
         fFuncLeRegistrador(Pchar(IntToStr(i)),pValor);
         aPagamento[1]:=pValor;
         If Uppercase(Trim(aPagamento[1]))='SANGRIA' then
            aPagamento[2]:=IntToStr(i-78)
     end;

     fFuncEmiteNaoVinculado(aPagamento[2],' ',Valor);

     For i:=33 to 47 do
     begin
         fFuncLeRegistrador(Pchar(IntToStr(i)),pValor);
         aPagamento[i-32]:=pValor;
     end;
     For i:=0 to 14 do
     begin
         If Uppercase(Trim(aPagamento[i+1]))=UpperCase(Forma) then
             sPos:=FormataTexto(IntToStr(i),2,0,1);
     End;
       fFuncPagamento((sPos),' ',Valor);
       fFuncFechaCupom(' ');
  End;

  StrDispose(pValor);
  result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
var iRet : Integer;
begin
  iRet := fFuncImprimeCabecalho;
  result := Status( 1,IntToStr(iRet) );
  iSoma:=1;
end;

//----------------------------------------------------------------------------
function TImpFiscalUranoLog.CancelaCupom( Supervisor:AnsiString ):AnsiString;
var iRet : Integer;
begin
  iRet := fFuncCancelaVenda( '0' );
  if copy(Status(1,IntToStr(iRet)),1,1) <> '0' then
    iRet := fFuncCancelaCupom( ' ' );
  result := Status( 1,IntToStr(iRet) );
  if copy( result,1,1 ) = '0' then
    Pulalinha( 6 )
  else
    // Se cancelamento enviado fora da sequencia
    if iRet = 34 then
    begin
      // Registra um item qualquer
      iRet := fFuncVendaItem( '1', 'Cancelamento', '1 ',//FormataTexto( '1',7,3,1 ),
                              '000000001', '0', 'Un', '0' );
      result := Status( 1,IntToStr(iRet) );
      if copy(Status(1,IntToStr(iRet)),1,1) = '0' then
      begin
        iRet := fFuncCancelaVenda( ' ' );
        if copy(Status(1,IntToStr(iRet)),1,1) <> '0' then
          iRet := fFuncCancelaCupom( ' ' );
        result := Status( 1,IntToStr(iRet) );
        if copy( result,1,1 ) = '0' then
          Pulalinha( 6 );
      end;
    end;
end;

{function LeDetalhe(Tipo, Inicio, Fim, Modo:AnsiString):AnsiString;
begin
    Result:='0';
end;}

//-----------------------------------------------------------
function TImpFiscalUrano.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
begin
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
var iRet : Integer;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;
//------------------------------------------------------------------------------
function TImpFiscalUrano.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalUrano.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//---------------------------------------------------------------------------
function TImpFiscalUrano50.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
  Result := OpenUrano( sPorta,'URANO ZPM 1EF 5.0' );
  // Carrega as aliquotas e N. PDV para ganhar performance
  if Copy(Result,1,1) = '0' then
     AlimentaProperties;
end;

//---------------------------------------------------------------------------
function TImpFiscalUrano2EFC.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
  Result := OpenUrano( sPorta,'URANO 2EFC 1.0' );
  // Carrega as aliquotas e N. PDV para ganhar performance
  if Copy(Result,1,1) = '0' then
     AlimentaProperties;
end;
//----------------------------------------------------------------------------
function TImpFiscalUrano2EFC.Pagamento( Pagamento,Vinculado,Percepcion : AnsiString ): AnsiString;
  function AchaPagto( sPagto:AnsiString; aPagtos: TaString):AnsiString;
  var i, iPos, iTamCond : Integer;
  begin
    iPos := 99;
    for i:=0 to Length(aPagtos)-1 do
    begin
      iTamCond := Length(aPagtos[i]);
      if UpperCase(aPagtos[i]) = UpperCase(copy(sPagto,1,iTamCond)) then
      begin
        iPos := i;
        break;
      end;
    end;
    result := IntToStr(iPos);
    if iPos <> 99 then
      if Length(result) < 2 then
        result := '0' + result;
  end;
var
  sPagto : AnsiString;
  aPagto,aAuxiliar : TaString;
  iRet,i : Integer;
begin
  iRet := 0;
  // Verifica o parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Verifica parametro Vinculado
  if Vinculado <> '1' then Vinculado := '0';

  // Pega a condicao de pagamento
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Monta um array auxiliar com as formas solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Faz o registro do pagamento
  i:=0;
  While i<Length(aAuxiliar) do
  begin
    if AchaPagto(aAuxiliar[i],aPagto) <> '99' then
      iRet := fFuncPagamento( AchaPagto(aAuxiliar[i],aPagto), '  ', FormataTexto(aAuxiliar[i+1],10,2,2), Vinculado );
    Inc(i,2);
  end;

  result := Status( 1,IntToStr(iRet) );

end;
//----------------------------------------------------------------------------
function TImpFiscalUrano2EFC.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var iRet, i, nLoop : Integer;
var sLinha : AnsiString;
var sBloco : AnsiString;
var lOk : boolean;
begin
  iRet   := 0;
  i      := 1;
  sLinha := '';
  lOk    := True;
  fFuncFinalizaRelatorio( ' ' );

  // Caso o texto estaja vazio, imprime um '.'
  if Length(Texto) = 0 then Texto := '.' + #10;

  // Executa o loop para impressao das vias
  for nLoop := 1 to Vias do
  begin

    // Executa impressao do texto linha a linha
    while i <= Length(Texto) do
    begin
      if (Length(sLinha)>=42) then
      begin
         sBloco:=sBloco+sLinha;
         sLinha:='';
      End;
      if (Length(sBloco)>=420) then
      begin
        if sBloco <> '' then
        begin
          iRet   := fFuncLinhasLivres( sBloco );
          sBloco := '';
          result := Status(1, IntToStr(iRet) );
          lOk    := copy( result, 1, 1 ) = '0';
          if not lOk then break;
        end
        else
          PulaLinha(1);
      end
      else
         If (copy(Texto,i,1) = #10) then
             sLinha := Copy(sLinha+Space(42),1,42)
         Else
         // Se for #, não grava na AnsiString
            if copy(Texto,i,1) <> '#' then sLinha := sLinha + copy(Texto,i,1);

      Inc(i);
    end;
    if sBloco <> '' then
    begin
          iRet   := fFuncLinhasLivres( sBloco );
          sBloco := '';
          result := Status(1, IntToStr(iRet) );
          lOk    := copy( result, 1, 1 ) = '0';
    end;
    // Se houve problema na impressão da linha aborta proximas vias
    if not lOk then break;

    // Verifica se é uma nova via
    if not (nLoop = Vias) then
    begin
      i      := 1;
      sLinha := '';
      // Processo para nova via
      PulaLinha(9);
      Sleep(5000);
    end;

  end;

  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalUrano2EFC.RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString;
var iRet : Integer;
begin
  fFuncFinalizaRelatorio( ' ' );
  result := TextoNaoFiscal( Texto, Vias );
  if (copy( result,1,1 ) = '0') then
  begin
    iRet   := fFuncFinalizaRelatorio( ' ' );
    result := Status( 1, IntToStr(iRet) );
    if copy( result, 1, 1 ) = '0'
    then PulaLinha(6);
  end;
end;
{**********************  Impressora de Cheque *************************************************}
function TImpCheqUrano2EFC.Abrir( aPorta:AnsiString ): Boolean;
begin
  {
   Formato do Arquivo Banco2efc.txt

   [<comentários>] [<código-do-banco>]		         	[; <comentários>]
   Valor = <coluna> , <linha>					[; <comentários>]
   Extenso = <coluna1> , <linha1> , <coluna2> , <linha2>	[; <comentários>]
   Favorecido = <coluna> , <linha>				[; <comentários>]
   Cidade = <coluna> , <linha>					[; <comentários>]
   Data = <coluna1> , <coluna2> , <coluna3>			[; <comentários>]
   Mensagem = <linha> , <coluna>				[; <comentários>]
   eSpacamento = <espaçamento>				[; <comentários>]

   Exemplo de um arquivo:

   Banco [237]				; Banco ABC
   Valor = 20,1
   Extenso = 2,2,2,3
   Favorecido = 2,4
   Cidade = 10,7
   Data = 17,21,28
   Mensagem = 15, 1
   eSpacamento = 24

   * Fonte : Funções da Biblioteca de Comunicação 2EFC32.DLL - 32 bits
             ECF: Modelo 2EFC - firmware Versão 1.00
                          Manual DLL
             Revisões
             Listagem cronológica de revisões deste manual
             Data	Revisão
             12/98	A0
             03/99	A1
             Pagina: 20
   }
  If not FileExists( 'Banco2EFC.TXT') then
  Begin
     ShowMessage('Arquivo Banco2EFC.TXT não encontrado');
     Result := False;
  End
  Else
  Begin
     If Not bOpened Then
        Result := (Copy(OpenUrano(aPorta,'URANO 2EFC 1.0'),1,1) = '0')
     Else
        Result := True;
  End;
end;

function TImpCheqUrano2EFC.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  iRet : Integer;
  sData: AnsiString;
  sValor: AnsiString;
  sMsg : AnsiString;
begin
  result := False;
  if length(Data)=6 then
     sData := Copy(Data,5,2)+Copy(Data,3,2)+Copy(Data,1,2)
  Else
     sData := Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,3,2);

  Data  := Pchar(sData);
  sValor := StrPas(Valor);
  sValor := Trim(FormataTexto(sValor,14,2,4));
  sMsg   := StrPas(Mensagem);
  If Trim(sMsg)='' then
     sMsg:=' ';

  iRet   := fFuncNomeMoeda( 'REAL','REAIS');
  If  IntToStr(iRet)= '33' then
  Begin
      iRet := fFuncImprimeCheque('BANCO2EFC.TXT',Banco,sValor,Favorec,Cidade,sMsg,Data);
      If  IntToStr(iRet)= '33' then
          result := True;
  End;
End;

//----------------------------------------------------------------------------
function TImpCheqUrano2EFC.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpCheqUrano2EFC.Fechar( aPorta:AnsiString ): Boolean;
begin
  Result := (Copy(CloseUrano,1,1) = '0');
end;

//----------------------------------------------------------------------------
function TImpCheqUrano2EFC.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
end;

//******************  Funcoes Genericas ****************************************
Function OpenUrano( sPorta:AnsiString; sImpressora:AnsiString  ) : AnsiString;

  function ValidPointer( sDll:AnsiString ;aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ' + sDll);
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  iRet : Integer;
  bRet : Boolean;
  lpValor : PChar;
  sDll : AnsiString;

begin
  Result := '0|';
  If sImpressora='URANO 2EFC 1.0' Then
     sDll:='DLL2EFC3.DLL'
  else if (sImpressora='URANO ZPM 1EF 5.0') then
      sDll:='DLL1EFC4.DLL'
  else
      sDll:='DLL1EF32.DLL' ;

  If Not bOpened Then
  Begin
    fHandle := LoadLibrary(pChar(sDll));
    if (fHandle <> 0) Then
    begin
        bRet := True;
        aFunc := GetProcAddress(fHandle,'InicializaDLL');
        if ValidPointer( sDll, aFunc, 'InicializaDll' ) then
           fFuncInicializaDll := aFunc
        else
        begin
           bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'FinalizaDLL');
        if ValidPointer( sDll, aFunc, 'FinalizaDll' ) then
           fFuncFinalizaDll := aFunc
        else
        begin
           bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'ImprimeCabecalho');
        if ValidPointer( sDll, aFunc, 'ImprimeCabecalho' ) then
          fFuncImprimeCabecalho := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'VendaItem');
        if ValidPointer( sDll, aFunc, 'VendaItem' ) then
          fFuncVendaItem := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'CancelaItem');
        if ValidPointer( sDll, aFunc, 'CancelaItem' ) then
          fFuncCancelaItem := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'DescontoItem');
        if ValidPointer( sDll, aFunc, 'DescontoItem' ) then
          fFuncDescontoItem := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'Pagamento');
        if ValidPointer( sDll, aFunc, 'Pagamento' ) then
          fFuncPagamento := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'FechaCupom');
        if ValidPointer( sDll, aFunc, 'FechaCupom' ) then
          fFuncFechaCupom := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'LinhasLivres');
        if ValidPointer( sDll, aFunc, 'LinhasLivres' ) then
          fFuncLinhasLivres := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'CancelaVenda');
        if ValidPointer( sDll, aFunc, 'CancelaVenda' ) then
          fFuncCancelaVenda := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'CancelaCupom');
        if ValidPointer( sDll, aFunc, 'CancelaCupom' ) then
          fFuncCancelaCupom := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'AcrescimoSubtotal');
        if ValidPointer( sDll, aFunc, 'AcrescimoSubtotal' ) then
          fFuncAcrescimoSubTotal := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'DescontoSubtotal');
        if ValidPointer( sDll, aFunc, 'DescontoSubtotal' ) then
          fFuncDescontoSubTotal := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'Relatorio_XZ');
        if ValidPointer( sDll, aFunc, 'Relatorio_XZ' ) then
          fFuncRelatorio_XZ := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'FinalizaRelatorio');
        if ValidPointer( sDll, aFunc, 'FinalizaRelatorio' ) then
          fFuncFinalizaRelatorio := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'CargaAliquota');
        if ValidPointer( sDll, aFunc, 'CargaAliquota' ) then
          fFuncCargaAliquota := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'CargaCliche');
        if ValidPointer( sDll, aFunc, 'CargaCliche' ) then
          fFuncCargaCliche := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'LeituraMF');
        if ValidPointer( sDll, aFunc, 'LeituraMF' ) then
          fFuncLeituraMF := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'Propaganda');
        if ValidPointer( sDll, aFunc, 'Propaganda' ) then
          fFuncPropaganda := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'AbreGaveta');
        if ValidPointer( sDll, aFunc, 'AbreGaveta' ) then
          fFuncAbreGaveta := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'AvancaLinhas');
        if ValidPointer( sDll, aFunc, 'AvancaLinhas' ) then
          fFuncAvancaLinhas := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'EstadoImpressora');
        if ValidPointer( sDll, aFunc, 'EstadoImpressora' ) then
          fFuncEstadoImpressora := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'LeRegistrador');
        if ValidPointer( sDll, aFunc, 'LeRegistrador' ) then
          fFuncLeRegistrador := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'Autentica');
        if ValidPointer( sDll, aFunc, 'Autentica' ) then
          fFuncAutentica := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'LeSensor');
        if ValidPointer( sDll, aFunc, 'LeSensor' ) then
          fFuncLeSensor := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'IdComprador');
        if ValidPointer( sDll, aFunc, 'IdComprador' ) then
          fFuncIdComprador := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'CupomStub');
        if ValidPointer( sDll, aFunc, 'CupomStub' ) then
          fFuncCupomStub := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'SimboloMoeda');
        if ValidPointer( sDll, aFunc, 'SimboloMoeda' ) then
          fFuncSimboloMoeda := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'FormaPagamento');
        if ValidPointer( sDll, aFunc, 'FormaPagamento' ) then
          fFuncFormaPagamento := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'CargaNaoVinculado');
        if ValidPointer( sDll, aFunc, 'CargaNaoVinculado' ) then
          fFuncCargaNaoVinculado := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'EmiteNaoVinculado');
        if ValidPointer( sDll, aFunc, 'EmiteNaoVinculado' ) then
          fFuncEmiteNaoVinculado := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'EmiteVinculado');
        if ValidPointer( sDll, aFunc, 'EmiteVinculado' ) then
          fFuncEmiteVinculado := aFunc
        else
        begin
          bRet := False;
        end;

        aFunc := GetProcAddress(fHandle,'TransferFinanceira');
        if ValidPointer( sDll, aFunc, 'TransferFinanceira' ) then
          fFuncTransferFinanceira := aFunc
        else
        begin
          bRet := False;
        end;

        if (sImpressora='URANO 2EFC 1.0')then
        begin
          aFunc := GetProcAddress(fHandle,'ImprimeCheque');
          if ValidPointer( sDll, aFunc, 'ImprimeCheque' ) then
             fFuncImprimeCheque:= aFunc
          else
          begin
             bRet := False;
          end;

          aFunc := GetProcAddress(fHandle,'NomeMoeda');
          if ValidPointer( sDll, aFunc, 'NomeMoeda' ) then
             fFuncNomeMoeda:= aFunc
          else
          begin
             bRet := False;
          end;
        end;
    End
    else
    begin
        ShowMessage('O arquivo '+ sDll +' não foi encontrado.');
        bRet := False;
    end;
    if bRet then
    begin
       result := '0|';
       fFuncInicializaDll( PChar(sPorta) );
       lpValor := StrAlloc(20);
       FillChar(lpValor^,20,0);
       iRet := fFuncLeRegistrador( PChar('01'),lpValor );
       if iRet <> 33 then
          bRet := False;
       if not bRet then
       begin
          ShowMessage('Erro na abertura da porta');
          result := '1|';
       end
       Else
         bOpened := True;
      end;
    end
    else
       result := '1|';
end;
//----------------------------------------------------------------------------
Function CloseUrano : AnsiString;
begin
  result := '0';
  If bOpened Then
  Begin
     if (fHandle <> INVALID_HANDLE_VALUE) then
     begin
       if fFuncFinalizaDll <> 0 then
       begin
          ShowMessage('Erro ao fechar a comunicação com impressora Fiscal.');
          result := '1';
       end;
       FreeLibrary(fHandle);
       fHandle := 0;
     end;
     bOpened:= False;
  End;
end;

Function TrataTags( Mensagem : AnsiString ) : AnsiString;
var
  cMsg : AnsiString;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//******************  Final das Funcoes Genericas ****************************************

function TImpFiscalUrano.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

(*initialization
  RegistraImpressora('URANO ZPM 1EF - V. 06.00', TImpFiscalUrano50      , 'BRA', ' ');
  RegistraImpressora('URANO ZPM 1EF - V. 05.00', TImpFiscalUrano50      , 'BRA', '460108');
  RegistraImpressora('URANO ZPM 1EF - V. 04.00', TImpFiscalUrano50      , 'BRA', '460107');
  RegistraImpressora('URANO ZPM 1EF - V. 03.00', TImpFiscalUrano        , 'BRA', '460103');
  RegistraImpressora('URANO ZPM 1EF - V. 02.00', TImpFiscalUranoII      , 'BRA', '460102');
  RegistraImpressora('URANO LOGGER  - V. 02.20', TImpFiscalUranoLog     , 'BRA', '461601');
  RegistraImpressora('URANO 2EFC    - V. 01.00', TImpFiscalUrano2EFC    , 'BRA', '460901');
  RegistraImpCheque ('URANO 2EFC 1.00'  , TImpCheqUrano2EFC, 'BRA');*)
//----------------------------------------------------------------------------
end.

