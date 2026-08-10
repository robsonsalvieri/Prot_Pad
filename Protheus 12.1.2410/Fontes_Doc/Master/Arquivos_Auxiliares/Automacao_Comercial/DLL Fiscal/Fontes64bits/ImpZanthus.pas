unit ImpZanthus;

interface

uses
  Dialogs,
  ImpFiscMain,
  ImpCheqMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms;

const
  pBuffSize = 200;

Type                

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Zanthus
///
  TImpFiscalZanthus = class(TImpressoraFiscal)
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
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString):AnsiString; override;
    function Gaveta:AnsiString; override;
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString; override;
    function Status( Tipo:Integer; Texto:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    Procedure PulaLinha( iNumero:Integer );
    function ProcRetorno( sArgumento:AnsiString ):AnsiString;
    function ProcRetornoAscII( sArgumento:AnsiString ):AnsiString;
    function GravaCondPag( condicao: AnsiString ):AnsiString; override;
    function PegaSerie:AnsiString; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : AnsiString ):AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override;
    Function RedZDado( MapaRes:AnsiString ):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
  end;

  TImpFiscalZanthus0351 = class(TImpFiscalZanthus)
  public
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer ): AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function GravaCondPag( condicao: AnsiString ):AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString; override;
  end;


  TImpFiscalZ11 = class(TImpFiscalZanthus)
  public
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
  end;

  TImpFiscalZ1E = class(TImpFiscalZanthus)
  Public
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function LeCondPag:AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer ): AnsiString; override;
  End;

  TImpFiscalZ20 = class(TImpFiscalZanthus)
  Public
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function Pagamento (Pagamento, Vinculado,Percepcion:AnsiString): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
  End;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Zanthus
///
  TImpChequeZanthus = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenZanthus( sPorta,sModelo:AnsiString ) : AnsiString;
Function CloseZanthus : AnsiString;
Function EnviaComando( sComando:AnsiString; sArgumentos:AnsiString = '' ):Integer;
Function TrataTags( Mensagem : AnsiString ) : AnsiString;

//---------------------------------------------------------------------------
implementation
var
  sDollar : AnsiString;
  bOpened : Boolean;
  fHandle : THandle;
  fFuncAbrePorta      : function ( porta:integer ):integer; StdCall;
  fFuncEnviaComando   : function ( C:AnsiChar ):integer; StdCall;
  fFuncEnviaComandoArg: function ( C:AnsiChar; S:PCHAR ):integer; StdCall;
  fFuncFechaPorta     : function ():integer; StdCall;
  fFuncLeBufferASCII  : function ( S:PCHAR ):integer; StdCall;
  fFuncLeBuffer       : function ( S:PCHAR ):integer; StdCall;
  fFuncLeRetorno      : function ():integer; StdCall;
  fFuncLeRetornoASCII : function ():byte; StdCall;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
  Result := OpenZanthus( sPorta, Modelo );
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  Result := CloseZanthus;
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.LeituraX : AnsiString;
var
  iRet : Integer;
begin
  iRet := EnviaComando( '3' );
  result := Status( 1, IntToStr(iRet) );
  PulaLinha( 0 );
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.ReducaoZ( MapaRes:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin
  iRet := EnviaComando( '4' );
  result := Status( 1, IntToStr(iRet) );
  PulaLinha( 0 );
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.LeAliquotas:AnsiString;
var
  iRet : Integer;
  sComando : AnsiString;
  sArgumento : AnsiString;
  s : AnsiString;
  sAliq : AnsiString;
  i : Integer;
begin
  sAliq := '';
  sComando := 'P';
  sArgumento := '000420';
  iRet := EnviaComando( sComando, sArgumento );
  If iRet = 0 then
  begin
    s := ProcRetornoAscII( sArgumento );
    i := 1;
    While i < Length(s) do
    begin
      If StrToInt(Copy(s,i,4)) <> 0 then
      begin
        sAliq := sAliq + FloatToStrf(StrToFloat(Copy(s,i,4))/100, ffFixed, 15, 2 ) + '|';
      end;
      Inc(i,4);
    end;
    result := '0|' + sAliq;
  end
  else
    result := '1|';
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString;
begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.LeAliquotasISS:AnsiString;
var
  iRet : Integer;
  sComando : AnsiString;
  sArgumento : AnsiString;
  s : AnsiString;
  sAliq : AnsiString;
  i : Integer;
begin
  sAliq := '';
  sComando := 'P';
  sArgumento := '002408';
  iRet := EnviaComando( sComando, sArgumento );
  If iRet = 0 then
  begin
    s := ProcRetornoAscII( sArgumento );
    i := 1;
    While i < Length(s) do
    begin
      If StrToInt(Copy(s,i,4)) <> 0 then
      begin
        sAliq := sAliq + FloatToStrf(StrToFloat(Copy(s,i,4))/100, ffFixed, 15, 2 ) + '|';
      end;
      Inc(i,4);
    end;
    result := '0|' + sAliq;
  end
  else
    result := '1|';
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.LeCondPag:AnsiString;
var
  iRet : Integer;
  sComando : AnsiString;
  sArgumento : AnsiString;
  s : AnsiString;
  sPagto : AnsiString;
  i : Integer;
  x : Integer;
begin
  sPagto := '';
  sComando := 'P';
  For i:=1 to 10 do
  begin
    sArgumento := '0' + IntToStr((372 + ((i-1) * 32))) + '32';
    iRet := EnviaComando( sComando, sArgumento );
    If iRet = 0 then
    begin
      s := ProcRetorno( sArgumento );
      x := 1;
      While x < Length(s) do
      begin
        If Trim(Copy(s,x,16)) <> '' then
          sPagto := sPagto + Trim(copy(s,x,16)) + '|';
        Inc(x,16);
      end;
    end;
  end;

  if Length(sPagto) > 4 then
    result := '0|' + sPagto
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
var
  iRet : Integer;
begin
  iRet := EnviaComando( '8' );
  result := Status( 1, IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet : Integer;
  sArgumento : AnsiString;
begin
  sArgumento := '117603';
  iRet := EnviaComando( 'P', sArgumento );
  result := Status( 1,IntToStr(iRet) );
  if iRet = 0 then
     result := result + '|' + ProcRetornoAscII( sArgumento );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.PegaPDV:AnsiString;
var
  iRet : Integer;
  sArgumento : AnsiString;
begin
  sArgumento := '000102';
  iRet := EnviaComando( 'P', sArgumento );
  result := Status( 1,IntToStr(iRet) );
  if iRet = 0 then
     result := result + '|' + ProcRetornoAscII( sArgumento );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  iRet, iTamanho : Integer;
  sRet, sArgumento, sVlrTotal, sAliq, sLinha, sSituacao : AnsiString;
  lCancela : Boolean;
  aAliq : TaString;
begin
  if (Trim(aliquota)<>'F') and (Trim(aliquota)<>'N') and (Trim(aliquota)<>'I') then
        aliquota := Copy(aliquota,1,1)+FormataTexto(Copy(Aliquota,2,Length(aliquota)),4,2,1);
  sSituacao := copy(aliquota,1,1);
  aliquota  := StrTran(copy(aliquota,2,5),',','.');
  lCancela  := True;
  // Verifica o tamanho da coluna de impressao
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));
    if lCancela then
    begin
      sRet := '';
      sArgumento := FormataTexto(IntToStr(StrToInt(numitem)-1),4,0,2);

      iRet := EnviaComando( 'e', sArgumento );
      if iRet <> 0 then
      begin
        ShowMessage('O item informado não se encontra na memória da impressora.');
        result := '1';
        exit;
      end;

      // Pega as aliquotas
      if sSituacao = 'T' then
        sAliq := LeAliquotas
      else
        sAliq := LeAliquotasISS;

      MontaArray( copy(sAliq,2,Length(sAliq)), aAliq );

      // verifica o valor total do item
      sVlrTotal := FloatToStrf( StrToFloat(vlrUnit)*StrToFloat(qtde)-StrToFloat(vlrdesconto), ffFixed, 18, 2);

      // faz a exclusao do item
      sLinha := '';
      sLinha := ' ' + sSituacao + ' ';
      sLinha := Replicate(' ',11-Length(sVlrTotal)) + StrTran(sVlrTotal,'.',',') + sLinha;
      if Pos(sSituacao,'T,S') > 0 then
        sLinha := Trim(sSituacao) + StrTran(aliquota,',','.') + '%' + sLinha;

      If Length(sLinha) < iTamanho then
        sLinha := Replicate(' ',iTamanho-Length(sLinha)) + sLinha;
      sLinha := sArgumento + sLinha;

      iRet := EnviaComando( 'd',sLinha );
      result := Status( 1,IntToStr(iRet) );
    end;
  end
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.CancelaCupom( Supervisor:AnsiString ):AnsiString;

  function CancelaCupAnt:AnsiString;
  var iRet : Integer;
  begin
    // Verifica se pode cancelar o cupom anterior
    iRet := EnviaComando( 'B' );
    result := Status( 1, IntToStr( iRet ) );
    if copy( result, 1, 1 ) = '0' then
    begin
      // Cancela o cupom anterior
      iRet := EnviaComando( '@' );
      result := Status( 1,IntToStr(iRet) );
    end;
  end;

var
  iRet : Integer;
  sArgumento, sRet : AnsiString;
begin
  // Verifica se é cupom fiscal ou não fiscal
  sArgumento := '221701';
  EnviaComando( 'P',sArgumento );
  sRet := ProcRetorno( sArgumento );
  if sRet <> 'c' then
  begin
    iRet := EnviaComando( ':' );
    result := Status( 1,IntToStr(iRet) );
  end
  else
  begin
    // Verifica se o cupom está aberto
    sArgumento := '117201';
    EnviaComando( 'P', sArgumento );
    sRet := ProcRetorno( sArgumento );
    if sRet = #2 then   // Repouso com dia já iniciado
       // Verifica se pode e caso ok, cancela cupom anterior
       result := CancelaCupAnt
    else
    begin
      // Cancela cupom atual
      iRet := EnviaComando( ':' );
      result := Status( 1,IntToStr(iRet) );
      // Se não teve sucesso ...
      if copy( result, 1, 1 ) = '1' then
      begin
        // Verifica se existe um cupom aberto e se já foi dado o troco do mesmo
        // Pois está é a única situação que não cancelava no meio da impressão
        // do cupom.
        sArgumento := '117201';
        EnviaComando( 'P', sArgumento );
        sRet := ProcRetorno( sArgumento );
        // Se afirmativo, fecha o cupom ...
        if sRet = #8 then
        begin
          iRet := EnviaComando( '9' );
          result := Status( 1, IntToStr( iRet ) );
        end
        else
          result := '0|';
        // Verifica se pode e caso ok, cancela cupom anterior
        if copy( result, 1, 1 ) = '0' then
          result := CancelaCupAnt;
      end;
    end;
    if copy(result,1,1) = '0' then PulaLinha(9);
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sLinha, sAliq, sRet, sArgumento, sVlrTotal, sSituacao : AnsiString;
  aAliq : TaString;
  bAliq : Boolean;
  iRet, iTamanho, i : Integer;
begin
  bAliq := False;
  vlrunit := Trim(FormataTexto(vlrunit,12,2,3));
  qtde := Trim(FormataTexto(qtde,12,2,3));
  if (Trim(aliquota)<>'F') and (Trim(aliquota)<>'N') and (Trim(aliquota)<>'I') then
          aliquota:= copy(aliquota,1,1)+Trim(FormataTexto(Copy(aliquota, 2, length(aliquota)),4,2,3));
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));

    // Trata os pontos decimais
    qtde := StrTran(qtde,',','.');
    vlrUnit := StrTran(vlrUnit,',','.');
    vlrdesconto := StrTran(vlrDesconto,',','.');

    // Faz o tratamento da aliquota
    sSituacao := copy(aliquota,1,1);
    aliquota := StrTran(copy(aliquota,2,5),',','.');

    //verifica se é para registra a venda do item ou só o desconto
    if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate(' ',11-Length(vlrDesconto)) + StrTran(vlrDesconto,'.',',') + sLinha;
          sLinha := sSituacao + aliquota + '%' + sLinha;
          If Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end
        else
          result := '1'
      else
        result := '0';
      exit;
    end;

    // Pega o valor total
    sVlrTotal := FloatToStrf(StrToFloat(qtde)*StrToFloat(vlrUnit), ffFixed, 18, 2);
    If Pos('.',sVlrTotal) > 0 then
      sVlrTotal := StrTran(sVlrTotal,'.',',');

    // Pega as aliquotas
    if sSituacao = 'S' then
      sAliq := LeAliquotasISS
    else
      sAliq := LeAliquotas;

    MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

    // Verifica se existe a aliquota
    For i := 0 to Length(aAliq)-1 do
    begin
      Aliquota := StrTran(Aliquota,',','.');
      sAliq := StrTran(aAliq[i],',','.');
      if StrTran(aAliq[i],',','.') = Aliquota then
        bAliq := True;
    end;

    sArgumento := '117201';
    EnviaComando( 'P',sArgumento );
    sRet := ProcRetornoAscII( '' );

    if (Pos(sSituacao,'TS') > 0) and (not bAliq) then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1';
      exit;
    end;

    // Monta a linha para registro do item
    sLinha := ' ';
    sLinha := sSituacao + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',11-Length(sVlrTotal)) + sVlrTotal + sLinha;
    if Pos(sSituacao,'TS') > 0 then
      sLinha := sSituacao + aliquota + '%' + sLinha;
    sLinha := Replicate(' ',9-Length(vlrUnit)) + StrTran(vlrUnit,'.',',') + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',7-Length(qtde)) + qtde + ' X' + sLinha;

    If Length( sLinha ) < iTamanho then
      sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;

    // Grava descricao
    EnviaComando( 'g', '00' );
    EnviaComando( 'g', '00'+copy(codigo+' '+descricao+Space(iTamanho),1,iTamanho) );

    // imprime linha do registro de venda
    iRet := EnviaComando( ';', sLinha );
    result := Status( 1,IntToStr(iRet) );

    If iRet = 0 then
    begin
      // Verifica o desconto do item
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate( ' ', 11-length(vlrdesconto)) +
                    StrTran(vlrDesconto,'.',',') + sLinha;
          if Pos(sSituacao,'TS') > 0 then
            sLinha := sSituacao + aliquota + '%' + sLinha;
          if Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.AbreECF:AnsiString;
Var
  iRet: Integer;
Begin
  result := '0|';
  iRet := EnviaComando( '1' );
  if copy( Status( 1,IntToStr(iRet) ), 1, 1 ) = '0' then
     PulaLinha( 0 )
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.FechaECF : AnsiString;
var
  iRet : Integer;
begin
  iRet := EnviaComando( '4' );
  result := Status( 1, IntToStr(iRet) );
  PulaLinha( 0 );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;

  function AchaPagto( sPagto:AnsiString; aPagtos: TaString ):AnsiString;
  var i, iPos : Integer;
  begin
    iPos := 0;
    for i:=0 to Length(aPagtos)-1 do
      if UpperCase(aPagtos[i]) = UpperCase(sPagto) then
        iPos := i + 1;
    result := IntToStr(iPos);
    if Length(result) < 2 then
      result := '0' + result;
  end;

  function MontaLinha( sPos, vlrDinheiro:AnsiString; iTamanho:Integer ):AnsiString;
  begin
    vlrDinheiro:= Trim(FormataTexto(vlrDinheiro,12,2,3));
    result := sPos + Replicate(' ',iTamanho-Length(vlrDinheiro)-5) + StrTran(vlrDinheiro,'.',',') + '   ';
  end;

var
  sPagto, sTotal, sLinha, sArgumento, sForma : AnsiString;
  aPagto,aAuxiliar : TaString;
  iRet, iTamanho,i : Integer;
begin

  // Faz a checagem do Parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Pega a condicao de pagamento
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Monta array com as formas de pagto solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Verifica se as formas de pagamento informadas existem na impressora
  i := 0;
  while i < Length(aAuxiliar) do
  begin
    if AchaPagto(aAuxiliar[i],aPagto) = '00' then
    begin
      ShowMessage('Não existe a condição de pagamento: ' + aAuxiliar[i]);
      break;
    end;
    Inc(i,2);
  end;

  // Verifica o tamanho da coluna de Impressao, e imprime total do cupom
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );

  if iRet = 0 then
  begin

    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));
    sArgumento := '213308';
    EnviaComando( 'P',sArgumento );

    sTotal := ProcRetornoAscII( sArgumento );
    sTotal := FloatToStrf(StrToFloat(sTotal)/100, ffFixed, 18, 2);
    if Pos('.', sTotal) > 0 then
      sTotal := StrTran(sTotal,'.',',');
    sTotal := Replicate(' ',iTamanho-Length(sTotal)-3) + sTotal;
    EnviaComando( 'O', sTotal+'   ' );

    // Verifica a forma de pagamento.
    i:=0;
    While i < Length(aAuxiliar) do
    begin
      sForma := AchaPagto(aAuxiliar[i],aPagto);
      if sForma = '00' then
        sForma := '01';
      sLinha := MontaLinha( sForma, aAuxiliar[i+1], iTamanho );
      EnviaComando( 'i',sLinha );
      Inc(i,2);
    end;

    // Solicita ao ECF a impressao do troco
    iRet := EnviaComando( 'j' );

    result := Status( 1,IntToStr(iRet) );

  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
  iRet : Integer;
  cMsg : AnsiString ;
begin
  // Imprime a mensagem promocional.
  If Trim(Mensagem) <> '' then
  begin
    cMsg := Mensagem;
    cMsg := TrataTags( cMsg );
    EnviaComando( 'o', '00'+cMsg);
  end;
  
  // Encerra o cupom
  iRet := EnviaComando( '9' );
  result := Status( 1,IntToStr(iRet) );

  // Salta linha
  PulaLinha( 0 );

end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer ): AnsiString;
var iRet, iTamanho : Integer;
var sLinha : AnsiString;
begin
  if StrToFloat( vlrDesconto ) > 0 then
  begin
    // Verifica o tamanho da coluna de Impressao.
    iRet := EnviaComando( '0' );
    result := Status( 1, IntToStr( iRet ) );
    if iRet = 0 then
    begin
      iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));
      // Registra o desconto.
      sLinha := '   ';
      if Pos('.',vlrDesconto) > 0 then
        vlrDesconto := StrTran( vlrDesconto,'.',',' );
      sLinha := Replicate(' ',iTamanho-Length(vlrDesconto)-3) + vlrDesconto + '   ';
      iRet := EnviaComando( '^', sLinha );
      result := Status( 1,IntToStr(iRet) );
    end;
  end
  else
    result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var
  iRet : Integer;
  sLinha : AnsiString;
  iTamanho : Integer;
begin
  vlrAcrescimo := Trim(FormataTexto(vlrAcrescimo,12,2,3));
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));
    // Registra o desconto.
    sLinha := '   ';
    if Pos('.',vlrAcrescimo) > 0 then
      vlrAcrescimo := StrTran( vlrAcrescimo,'.',',' );
    sLinha := Replicate(' ',iTamanho-Length(vlrAcrescimo)-3) + vlrAcrescimo + '   ';
    iRet := EnviaComando( 'f', sLinha );
    result := status( 1,IntToStr(iRet) );
  end;  
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString;
var
  iRet : Integer;
  sArgumento : AnsiString;
begin
  sArgumento := FormataData( DataInicio,1 ) + FormataData( DataFim,1 );
  iRet := EnviaComando( 'G', sArgumento );
  result := Status( 1,IntToStr(iRet) );

  // Salta linha
  PulaLinha( 0 );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
var
  iRet : Integer;
  sAliq : AnsiString;
  aAliq : TaString;
  bAchou : Boolean;
  i : Integer;
  sPos : AnsiString;
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
      if Length(aAliq) < 10 then
      begin
        sPos := IntToStr(Length(aAliq));
        If Length(sPos) < 2 then
          sPos := '0' + sPos;

        iRet := EnviaComando( 'Z', sPos + FormataTexto(Aliquota,4,2,2) );
//        ShowMessage( '"' + sPos + FormataTexto(Aliquota,4,2,2) + '"' );
        result := Status( 1,IntToStr(iRet) );
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
  begin
    bAchou := False;
    sAliq := LeAliquotasISS;
    MontaArray(sAliq, aAliq);

    For i:=0 to Length(aAliq)-1 do
      if StrTran(aAliq[i],',','.') = StrTran(Aliquota,',','.') then
        bAchou := True;

    if not bAchou then
      if Length(aAliq) < 5 then
      begin
        sPos := IntToStr(Length(aAliq)+9);
        If Length(sPos) < 2 then
          sPos := '0' + sPos;

        iRet := EnviaComando( 'Z', sPos + FormataTexto(Aliquota,4,2,2) );
//        ShowMessage( '"' + sPos + FormataTexto(Aliquota,4,2,2) + '"' );
        result := Status( 1,IntToStr(iRet) );
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
  end
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
begin
  iRet := EnviaComando( '?' );
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var iRet, i, iTamanho, nLoop : Integer;
var sLinha : AnsiString;
var lOk : boolean;
begin
  i      := 1;
  lOk    := True;
  sLinha := '';
  if length( Texto ) = 0 then Texto := '.' + #10;
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));
    for nLoop := 1 to Vias do
    begin
      while i <= Length(Texto) do
      begin
        if (copy(Texto,i,1) = #10) or (length(sLinha) >= iTamanho) then
        begin
          if sLinha <> '' then
          begin
            iRet := EnviaComando( '!', Copy(sLinha,1,iTamanho) );
            sLinha := '';
            if copy(Texto,i,1) <> #10 then sLinha := sLinha + copy(Texto,i,1);
            result := Status( 1, IntToStr( iRet ) );
            lOk := copy( result, 1, 1 ) = '0';
            if not lOk then break;
          end
          else
            PulaLinha(1);
        end
        else
          // Se for #, não grava na AnsiString
          if copy(Texto,i,1) <> #10 then sLinha := sLinha + copy(Texto,i,1);
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
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.FechaCupomNaoFiscal: AnsiString;
var
  iRet : Integer;
begin
  iRet := EnviaComando( '9' );
  result := Status( 1,IntToStr(iRet) );

  // Salta linha
  PulaLinha( 0 );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.ReImpCupomNaoFiscal( Texto:AnsiString ): AnsiString;
begin
  // para posterior implementacao
  result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString;
var
  i, iRet : Integer;
  Bancos : TStringList;
  sFile : AnsiString;
begin
  sFile := ExtractFilePath(Application.ExeName)+'DEFINCHQ.CFG';
  if FileExists(sFile) then
  begin
    Bancos := TStringList.Create;
    Bancos.LoadFromFile(sFile);
    for i := 0 to Bancos.Count - 1 do
      if Copy(Bancos.Strings[i],1,4) = '0'+Banco then
        break;
    if i=Bancos.Count then
      iRet := EnviaComando( 'k', '0'+Banco )
    else
      iRet := EnviaComando( 'k', '0000'+Copy(Bancos.Strings[i],5,999) );
  end
  else
    iRet := EnviaComando( 'k', '0'+Banco );
  if iRet = 0 then
  begin
    // configura as informações do cheque
    EnviaComando( 'l', '0'+Copy(Favorec,1,70) );   // dados do Favorecido;
    EnviaComando( 'l', '1'+Copy(Cidade,1,30) );    // Cidade
    EnviaComando( 'l', '2'+FormataData(StrToDate(Data),1) );  // Data do Cheque
    EnviaComando( 'l', '3'+FormataTexto(Valor,14,2,2) );     // Valor do Cheque
    EnviaComando( 'l', 'A'+Copy(Mensagem,1,60) );   // Observações
    EnviaComando( 'l', 'M'+'REAL' );  // Nome da Moeda no Singular
    EnviaComando( 'l', 'N'+'REAIS' );   // Nome da Moeda no Plural
    iRet := EnviaComando( 'm' );
  end;
  result := Status( 1,IntToStr(iRet) );

end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
  i : Integer;
begin
  iRet := 1;
  For i:=1 to Vezes do
  begin
    ShowMessage('Posicione o Documento para Autenticação.');
    iRet := EnviaComando( 'n', Texto );
  end;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
   function PegaRegistro( sCondicao:AnsiString):AnsiString;
   var
      i, iRet : Integer;
      sArgumento, s, sAcumNF: AnsiString;
   Begin
        For i:=1 to 20 do
        begin
            sArgumento := '00' + IntToStr((33 + ((i-1) * 17))) + '16';
            iRet    := EnviaComando( 'P', sArgumento );
            If Status( 1,IntToStr(iRet) ) = '0' then
            begin
                s       := ProcRetorno( sArgumento );
                sAcumNF := sAcumNF + Trim(copy(s,1,17)) + '|';
            end;
        end;
        i:=1;
        Result:='0';
        While ((Length(sAcumNF)>0) and (Result = '0')) do
        begin
            If UpperCase(sCondicao) = UpperCase(Copy(sAcumNF,1,Pos('|',sAcumNF)-1)) then
                Result:= FormataTexto(IntToStr(i),2,0,2);
            sAcumNF:= Copy(sAcumNF,Pos('|',sAcumNF)+1,Length(sAcumNF));
            Inc(i);
        end;
    end;
var
  iRet : Integer;
  sArgumento, sLinha, sCondicao, sIndicePag: AnsiString;
begin
  // Tipo = 1 - Verifica se tem troco disponivel
  // Tipo = 2 - Grava o valor informado no Suprimentos
  // Tipo = 3 - Sangra o valor informado

    Result := '1';
    sIndicePag := '';
    Valor := Trim(FormataTexto(Valor,12,2,3));
    Valor := StrTran(Valor,'.',',');

    If Tipo = 1 then
        Result:= '0';

    Case Tipo of
        2: sCondicao:='REFORCO';
        3: begin
            sCondicao:='SANGRIA';
            Valor := '-'+Valor;
           end;
    end;

    If (Tipo=2) or (Tipo=3) then
        sArgumento := PegaRegistro(sCondicao);

    If (Length(sArgumento)>0) and ((Tipo=2) or (Tipo=3))then
    begin
       iRet := EnviaComando( '7', sArgumento );
       If Status( 1,IntToStr(iRet) ) = '0' then
       begin
           sLinha:= Valor + '   ';
           While length(sLinha)<42 do
               sLinha:= ' '+sLinha;
           iRet := EnviaComando( ';', sLinha );
           If Status( 1,IntToStr(iRet) ) = '0' then
           begin

             If (Tipo=2) then                   //Suprimento
             begin
                If Pagamento( 'DINHEIRO|'+Valor,'N','') = '0' then
                begin
                    If FechaCupomNaoFiscal = '0' then
                        Result := '0'
                    Else
                        Result := '1';
                end
                Else
                    Result := '1';
             End
             Else                               //Sangria
             Begin
                If FechaCupomNaoFiscal = '0' then
                    Result := '0'
                Else
                    Result := '1';
             End;
           end
           Else
               Result := '1';
       end
       Else
         Result := '1';
    End;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.Gaveta:AnsiString;
var
  iRet : Integer;
begin
  iRet := EnviaComando( 'T' );
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.Status( Tipo:Integer; Texto:AnsiString ):AnsiString;
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
function TImpFiscalZanthus.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet : Integer;
  sRetorno, sData, sDataMov, sArgumento: AnsiString;
begin
// Tipo - Indica qual o status quer se obter da impressora:
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

// Verifica a data da impressora
If Tipo = 2 then
begin
  iRet := EnviaComando( 'R' );
  if iRet = 0 then
  begin
    sData := ProcRetornoAscII( sArgumento );
    result := '0|' + copy(sData,1,2) + '/' + copy(sData,3,2) + '/' + copy(sData,7,2);
  end
  else
    result := '1';
end
// Verifica a hora da Impressora
else if Tipo = 1 then
begin
  iRet := EnviaComando( 'R' );
  if iRet = 0 then
  begin
    sData := ProcRetornoAscII( sArgumento );
    result := '0|' + copy(sData,9,2) + ':' + copy(sData,11,2) + ':00';
  end
  else
    result := '1';
end
// Verifica o estado do papel
else if Tipo = 3 then
begin
  iRet := EnviaComando( 'S' );
  if iRet = 0 then
    if copy(ProcRetornoAscII( sArgumento ),2,1) = '0' then
      result := '0'
    else
      result := '3'
  else
    result := '1';
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  sArgumento := '117201';
  iRet := EnviaComando( 'P',sArgumento );
  if iRet = 0 then
  begin
    sRetorno := ProcRetornoAscII( sArgumento );
    if Pos(sRetorno,'03,06,07,08') > 0 then
      result := '7'
    else
      result := '0';
  end
  else
    result := '1';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  // Pega a Data do Movimento
  sArgumento := '117303';
  iRet := EnviaComando( 'P',sArgumento );
  if iRet = 0 then
  begin
    sDataMov := ProcRetornoAscII( sArgumento );
    // Pega a Data do ECF
    iRet := EnviaComando( 'R' );
    if iRet = 0 then
    begin
      sData := ProcRetornoAscII( sArgumento );
      sData := copy(sData,1,4) + copy(sData,7,2);
      // Se a Data do ECF for diferente da Data do Movimento
      // Verifique o Estado do Módulo Fiscal:
      // 01 - Deve fazer a Abertura do ECF
      // 02 - Deve fazer a Redução Z
      if sDataMov <> sData then
      begin
        // Pega o Estado do Módulo Fiscal
        sArgumento := '117201';
        iRet := EnviaComando( 'P',sArgumento );
        if iRet = 0 then
        begin
          sRetorno := ProcRetornoAscII( sArgumento );
          if sRetorno = '02' then
            Result := '01'
          else
            Result := '0';
        end
      end
      else
        Result := '0';
    end
    else
      Result := '1';
  end
  else
    Result := '1';
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
else
  Result := '1';
end;

//----------------------------------------------------------------------------
procedure TImpFiscalZanthus.PulaLinha( iNumero:Integer );
begin
  EnviaComando( 'U', FormataTexto(IntToStr(iNumero),2,0,2) );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.ProcRetorno( sArgumento:AnsiString ):AnsiString;
var
  pBuff : array[0..pBuffSize] of Char;
begin
  result := '';
  FillChar( pBuff,pBuffSize,0 );
  StrPCopy( pBuff, sArgumento );
  if fFuncLeBuffer( pBuff ) <> 0 then
    result := StrPas( pBuff );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.ProcRetornoAscII( sArgumento:AnsiString ):AnsiString;
var
  pBuff : array[0..pBuffSize] of Char;
begin
  FillChar( pBuff,pBuffSize,0 );
  StrPCopy( pBuff, sArgumento );
  if fFuncLeBuffer( pBuff ) <> 0 then
    fFuncLeBufferASCII( pBuff );
  result := StrPas( pBuff );
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString;
var iRet : Integer;
begin
  Result := RelatorioGerencial(cTextoImp , nVias , ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString;
var iRet : Integer;
begin
  iRet := EnviaComando( '3', '1');
  result := Status( 1, IntToStr( iRet ) );
  if copy( result, 1, 1 ) = '0' then
  begin
    result := TextoNaoFiscal( Texto, Vias );
    if copy( result, 1, 1 ) = '0' then
    begin
      iRet := EnviaComando( '9' );
      result := Status( 1, IntToStr( iRet ) );
      PulaLinha(9);
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.GravaCondPag( condicao: AnsiString ):AnsiString;
var sPagto, sNovaPos, sRet : AnsiString;
    aPagto : TaString;
    iRet, iCont, iLenPag, iTotal : Integer;
begin

  // Monta vetor com formas existentes
  sPagto   := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Verifica se já existe a forma de pagamento
  iLenPag := length( aPagto ) - 1;
  result  := '0';

  for iCont := 0 to iLenPag do
    if UpperCase( aPagto[ iCont ] ) = UpperCase( condicao ) then
    begin
      ShowMessage( 'Já existe a condição de pagamento: ' + condicao );
      result := '4|';
      exit;
    end;

  // Pega o total de formas de pagamento permitidas
  EnviaComando('0');

  sRet   := ProcRetornoASCII('');
  iTotal := StrToInt( '$' + copy( sRet, length( sRet ) - 13, 2 ) );

  // Se o contador for igual ao total de formas de pagamento, já tem o total de formas
  if (iLenPag + 1) = iTotal then
  begin
    ShowMessage( 'Sem espaço em memória para armazenar a nova forma de pagamento.' );
    result := '6|';
  end
  else if result = '0' then
  begin
    // Calcula nova posição
    sNovaPos := IntToStr( iLenPag + 2 );
    if length( sNovaPos ) = 1 then
      sNovaPos := '0' + sNovaPos;
    // Grava nova forma de pagamento.
    iRet := EnviaComando( 'W', 'P' + sNovaPos + copy( condicao, 1, 16 ) );
    result := Status( 1, IntToStr( iRet ) );
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.PegaSerie : AnsiString;
begin
    result := '1|Funcao nao disponivel';
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Zanthus IZ11
///
function TImpFiscalZ11.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sLinha, sAliq, sRet, sArgumento, sVlrTotal, sSituacao : AnsiString;
  aAliq : TaString;
  bAliq : Boolean;
  iRet, iTamanho, i : Integer;
begin
  bAliq := False;
  If Length(codigo) < 2 then
    Showmessage('O código do produto deve ser composto de no mínimo 2 caracteres');

  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));

    // Trata os pontos decimais
    qtde := StrTran(qtde,',','.');
    vlrUnit := StrTran(vlrUnit,',','.');
    vlrdesconto := StrTran(vlrDesconto,',','.');

    //formata a variável quanto a casas decimais.
    vlrUnit := FormataTexto(vlrUnit, 9, 3, 3);
    qtde := FormataTexto(qtde, 8, 2, 3);

    // Faz o tratamento da aliquota
    sSituacao := copy(aliquota,1,1);
    aliquota := StrTran(copy(aliquota,2,5),',','.');

    //verifica se é para registra a venda do item ou só o desconto
    if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate(' ',11-Length(vlrDesconto)) + StrTran(vlrDesconto,'.',',') + sLinha;
          sLinha := sSituacao + aliquota + '%' + sLinha;
          If Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end
        else
          result := '1'
      else
        result := '0';
      exit;
    end;

    // Pega o valor total
    sVlrTotal := FloatToStrf(StrToFloat(qtde)*StrToFloat(vlrUnit), ffFixed, 18, 2);
    If Pos('.',sVlrTotal) > 0 then
      sVlrTotal := StrTran(sVlrTotal,'.',',');

    // Pega as aliquotas
    if sSituacao = 'S' then
      sAliq := LeAliquotasISS
    else
      sAliq := LeAliquotas;

    MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

    // Verifica se existe a aliquota
    For i := 0 to Length(aAliq)-1 do
    begin
      Aliquota := StrTran(Aliquota,',','.');
      sAliq := StrTran(aAliq[i],',','.');
      if StrTran(aAliq[i],',','.') = Aliquota then
        bAliq := True;
    end;

    sArgumento := '117201';
    EnviaComando( 'P',sArgumento );
    sRet := ProcRetornoAscII( '' );

    if (Pos(sSituacao,'TS') > 0) and (not bAliq) then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1';
      exit;
    end;

    // Monta a linha para registro do item
    sLinha := ' ';
    sLinha := sSituacao + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',11-Length(sVlrTotal)) + sVlrTotal + sLinha;
    if Pos(sSituacao,'TS') > 0 then
      sLinha := sSituacao + aliquota + '%' + sLinha;
    sLinha := Replicate(' ',9-Length(vlrUnit)) + StrTran(vlrUnit,'.',',') + sLinha;
    sLinha := Replicate(' ',7-Length(qtde)) + qtde + ' X' + sLinha;

    If Length( sLinha ) < iTamanho then
      sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;

    // Grava descricao
    iRet := EnviaComando( 'g', '00' );
    iRet := EnviaComando( 'g', '00'+copy(trim(codigo)+' '+descricao+Space(iTamanho),1,iTamanho) );

    // imprime linha do registro de venda
    iRet := EnviaComando( ';', sLinha );
    result := Status( 1,IntToStr(iRet) );

    If iRet = 0 then
    begin
      // Verifica o desconto do item
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate( ' ', 11-length(vlrdesconto)) +
                    StrTran(vlrDesconto,'.',',') + sLinha;
          if Pos(sSituacao,'TS') > 0 then
            sLinha := sSituacao + aliquota + '%' + sLinha;
          if Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Zanthus
///
function TImpChequeZanthus.Abrir( aPorta:AnsiString ): Boolean;
begin
  Result := (Copy(OpenZanthus( aPorta, Modelo ),1,1) = '0');
end;

//----------------------------------------------------------------------------
function TImpChequeZanthus.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  i, iRet : Integer;
  Bancos : TStringList;
  sFile, sData : AnsiString;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  sFile := ExtractFilePath(Application.ExeName)+'DEFINCHQ.CFG';
  if FileExists(sFile) then
  begin
    Bancos := TStringList.Create;
    Bancos.LoadFromFile(sFile);
    for i := 0 to Bancos.Count - 1 do
      if Copy(Bancos.Strings[i],1,4) = '0'+Banco then
        break;
    if i=Bancos.Count then
      iRet := EnviaComando( 'k', '0'+Banco )
    else
      iRet := EnviaComando( 'k', '0000'+Copy(Bancos.Strings[i],5,999) );
  end
  else
    iRet := EnviaComando( 'k', '0'+Banco );
  if iRet = 0 then
  begin
    // configura as informações do cheque
    EnviaComando( 'l', '0'+Copy(Favorec,1,70) );                            // Dados do Favorecido;
    EnviaComando( 'l', '1'+Copy(Cidade,1,30) );                             // Cidade
    EnviaComando( 'l', '2'+Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,3,2) );  // Data do Cheque
    EnviaComando( 'l', '3'+FormataTexto(Valor,14,2,2) );                    // Valor do Cheque
    EnviaComando( 'l', 'A'+Copy(Mensagem,1,60) );                           // Observações
    EnviaComando( 'l', 'M'+'REAL' );                                        // Nome da Moeda no Singular
    EnviaComando( 'l', 'N'+'REAIS' );                                       // Nome da Moeda no Plural
    iRet := EnviaComando( 'm' );
  end;
  Result := (iRet = 0);
end;

//----------------------------------------------------------------------------
function TImpChequeZanthus.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequeZanthus.Fechar( aPorta:AnsiString ): Boolean;
begin
  Result := (CloseZanthus = '0');
end;

//----------------------------------------------------------------------------
function TImpChequeZanthus.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
  
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Zanthus 1E
///
function TImpFiscalZ1E.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;
Begin
  result := '0';
End;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
var
  iRet : Integer;
begin
  EnviaComando( '6' );
  iRet := EnviaComando( '8' );
  result := Status( 1, IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sLinha, sAliq, sRet, sArgumento, sVlrTotal, sSituacao : AnsiString;
  aAliq : TaString;
  bAliq : Boolean;
  iRet, iTamanho, i : Integer;
begin
  bAliq := False;
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));

    // Caso a parte fracionaria do numero seja igual a zero
    // imprimir um inteiro.
    if Int(StrToFloat(qtde)) = StrToFloat(qtde) then
      qtde := IntToStr(Trunc(StrToFloat(qtde)))
    else
      qtde := FloatToStrF(StrToFloat(qtde), ffFixed, 7, 3);

    vlrUnit := FormataTexto(vlrUnit,9,2,3);

    // Trata os pontos decimais
    qtde := StrTran(qtde,',','.');
    vlrUnit := StrTran(vlrUnit,',','.');
    vlrdesconto := StrTran(vlrDesconto,',','.');

    // Faz o tratamento da aliquota
    sSituacao := copy(aliquota,1,1);
    aliquota := StrTran(copy(aliquota,2,5),',','.');

    //verifica se é para registra a venda do item ou só o desconto
    if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate(' ',11-Length(vlrDesconto)) + StrTran(vlrDesconto,'.',',') + sLinha;
          sLinha := sSituacao + aliquota + '%' + sLinha;
          If Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end
        else
          result := '1'
      else
        result := '0';
      exit;
    end;

    // Pega o valor total
    sVlrTotal := FloatToStrf(StrToFloat(qtde)*StrToFloat(vlrUnit), ffFixed, 18, 2);
    If Pos('.',sVlrTotal) > 0 then
      sVlrTotal := StrTran(sVlrTotal,'.',',');

    // Pega as aliquotas
    if sSituacao = 'S' then
      sAliq := LeAliquotasISS
    else
      sAliq := LeAliquotas;

    MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

    // Verifica se existe a aliquota
    For i := 0 to Length(aAliq)-1 do
    begin
      Aliquota := StrTran(Aliquota,',','.');
      sAliq := StrTran(aAliq[i],',','.');
      if StrTran(aAliq[i],',','.') = Aliquota then
        bAliq := True;
    end;

    sArgumento := '117201';
    EnviaComando( 'P',sArgumento );
    sRet := ProcRetornoAscII( '' );

    if (Pos(sSituacao,'TS') > 0) and (not bAliq) then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1';
      exit;
    end;
    // Monta a linha para registro do item
    sLinha := ' ';
    sLinha := sSituacao + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',11-Length(sVlrTotal)) + sVlrTotal + sLinha;
    if Pos(sSituacao,'TS') > 0 then
      sLinha := sSituacao + aliquota + '%' + sLinha;
    //sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',9-Length(vlrUnit)) + StrTran(vlrUnit,'.',',') + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',7-Length(qtde)) + qtde + ' X' + sLinha;

    If Length( sLinha ) < iTamanho then
      sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;

    // Imprime descricao
    EnviaComando( '!', copy(codigo+' '+descricao+Space(iTamanho),1,iTamanho) );
    // Imprime linha do registro de venda
    iRet := EnviaComando( ';', sLinha );
    result := Status( 1,IntToStr(iRet) );

    If iRet = 0 then
    begin
      // Verifica o desconto do item
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate( ' ', 11-length(vlrdesconto)) +
                    StrTran(vlrDesconto,'.',',') + sLinha;
          if Pos(sSituacao,'TS') > 0 then
            sLinha := sSituacao + aliquota + '%' + sLinha;
          if Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
// A Z1E Não permite acrescimo no total.
begin
  Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  sLinha, sAliq, sRet, sArgumento, sVlrTotal, sSituacao : AnsiString;
  aAliq : TaString;
  bAliq : Boolean;
  iRet, iTamanho, i : Integer;
begin
  bAliq := False;
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));

    // Caso a parte fracionaria do numero seja igual a zero
    // imprimir um inteiro.
    if Int(StrToFloat(qtde)) = StrToFloat(qtde) then
      qtde := IntToStr(Trunc(StrToFloat(qtde)))
    else
      qtde := FloatToStrF(StrToFloat(qtde), ffFixed, 7, 3);

    vlrUnit := FormataTexto(vlrUnit,9,2,3);

    // Trata os pontos decimais
    qtde := StrTran(qtde,',','.');
    vlrUnit := StrTran(vlrUnit,',','.');
    vlrdesconto := StrTran(vlrDesconto,',','.');

    // Faz o tratamento da aliquota
    sSituacao := copy(aliquota,1,1);
    aliquota := StrTran(copy(aliquota,2,5),',','.');

    //verifica se é para registra a venda do item ou só o desconto
    if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate(' ',11-Length(vlrDesconto)) + StrTran(vlrDesconto,'.',',') + sLinha;
          sLinha := sSituacao + aliquota + '%' + sLinha;
          If Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end
        else
          result := '1'
      else
        result := '0';
      exit;
    end;

    // Pega o valor total
    sVlrTotal := FloatToStrf(StrToFloat(qtde)*StrToFloat(vlrUnit), ffFixed, 18, 2);
    If Pos('.',sVlrTotal) > 0 then
      sVlrTotal := StrTran(sVlrTotal,'.',',');

    // Pega as aliquotas
    if sSituacao = 'S' then
      sAliq := LeAliquotasISS
    else
      sAliq := LeAliquotas;

    MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

    // Verifica se existe a aliquota
    For i := 0 to Length(aAliq)-1 do
    begin
      Aliquota := StrTran(Aliquota,',','.');
      sAliq := StrTran(aAliq[i],',','.');
      if StrTran(aAliq[i],',','.') = Aliquota then
        bAliq := True;
    end;

    sArgumento := '117201';
    EnviaComando( 'P',sArgumento );
    sRet := ProcRetornoAscII( '' );

    if (Pos(sSituacao,'TS') > 0) and (not bAliq) then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1';
      exit;
    end;
    // Monta a linha para registro do item
    sLinha := ' ';
    sLinha := sSituacao + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',11-Length(sVlrTotal)) + sVlrTotal + sLinha;
    if Pos(sSituacao,'TS') > 0 then
      sLinha := sSituacao + aliquota + '%' + sLinha;
    //sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',9-Length(vlrUnit)) + StrTran(vlrUnit,'.',',') + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',7-Length(qtde)) + qtde + ' X' + sLinha;

    If Length( sLinha ) < iTamanho then
      sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;

    // Cancela o Item
    EnviaComando( '!', copy(codigo+' '+descricao+Space(iTamanho),1,iTamanho) );
    iRet := EnviaComando( '=', sLinha );
    result := Status( 1,IntToStr(iRet) );

    If iRet = 0 then
    begin
      // Verifica o desconto do item
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate( ' ', 11-length(vlrdesconto)) +
                    StrTran(vlrDesconto,'.',',') + sLinha;
          if Pos(sSituacao,'TS') > 0 then
            sLinha := sSituacao + aliquota + '%' + sLinha;
          if Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet : Integer;
  sRetorno, sData, sArgumento: AnsiString;
begin
// Tipo - Indica qual o status quer se obter da impressora:
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

// Verifica a hora da impressora
If Tipo = 1 then
begin
  iRet := EnviaComando( 'R' );
  if iRet = 0 then
  begin
    sData := ProcRetornoAscII( sArgumento );
    result := '0|' + copy(sData,9,2) + ':' + copy(sData,11,2) + ':00';
  end
  else
    result := '1';
end
// Verifica a data da Impressora
else if Tipo = 2 then
begin
  iRet := EnviaComando( 'R' );
  if iRet = 0 then
  begin
    sData := ProcRetornoAscII( sArgumento );
    result := '0|' + copy(sData,1,2) + '/' + copy(sData,3,2) + '/' + copy(sData,7,2);
  end
  else
    result := '1';
end
// Verifica o estado do papel
else if Tipo = 3 then
begin
  iRet := EnviaComando( 'S' );
  if iRet = 0 then
  begin
    sRetorno := ProcRetornoAscII( sArgumento );
    if copy(sRetorno,4,2) = '00' then
      result := '0'
    else
      result := '3';
  end
  else
    result := '1';
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  sArgumento := '022001';
  iRet := EnviaComando( 'P',sArgumento );
  if iRet = 0 then
  begin
    sRetorno := ProcRetornoAscII( sArgumento );
    if Pos(sRetorno,'03,06,07,08') > 0 then
      result := '7'
    else
      result := '0';
  end
  else
    result := '1';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  sArgumento := '022001';
  iRet := EnviaComando( 'P',sArgumento );
  if iRet = 0 then
  begin
    sRetorno := ProcRetornoAscII( sArgumento );
    if sRetorno = '01' then
      result := '10'
    else
      result := '0';
  end
  else
    result := '1';
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
else
  Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet : Integer;
  sArgumento : AnsiString;
begin
  sArgumento := '022403';
  iRet := EnviaComando( 'P', sArgumento );
  result := Status( 1,IntToStr(iRet) );
  if iRet = 0 then
     result := result + '|' + ProcRetornoAscII( sArgumento );
end;

//---------------------------------------------------------------------------
function TImpFiscalZ1E.LeCondPag:AnsiString;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
  iRet : Integer;
  sMsg : AnsiString;
begin
  sMsg := Mensagem;
  sMsg := TrataTags( sMsg );  
  // A Z1E Não Imprime a mensagem promocional.
  EnviaComando( '!', sMsg );

  // Encerra o cupom
  iRet := EnviaComando( '9' );
  result := Status( 1,IntToStr(iRet) );

  // Salta linha
  PulaLinha( 0 );
end;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
  i : Integer;
begin
  iRet := 1;
  For i:=1 to Vezes do
  begin
    ShowMessage('Posicione o Documento para Autenticação.');
    iRet := EnviaComando( '!', Valor+' '+Texto );
  end;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalZ1E.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString;
var iRet, iTamanho : Integer;
var sLinha : AnsiString;
begin
  if StrToFloat( vlrDesconto ) > 0 then
  begin
    // Verifica o tamanho da coluna de Impressao.
    iRet := EnviaComando( '0' );
    result := Status( 1, IntToStr( iRet ) );
    if iRet = 0 then
    begin
      iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));
      // Registra o desconto.
      sLinha := '   ';
      if Pos('.',vlrDesconto) > 0 then
        vlrDesconto := StrTran( vlrDesconto,'.',',' );
      vlrDesconto := Replicate(' ', 11-Length(vlrDesconto))+vlrDesconto;
      sLinha := Space(23) + 'T18.00%' + vlrDesconto + ' T ';
      sLinha := Replicate(' ',iTamanho-Length(sLinha)) + sLinha;
      iRet := EnviaComando( '^', sLinha );
      result := Status( 1,IntToStr(iRet) );
    end;
  end
  else
    result := '0';
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Zanthus IZ20
///
function TImpFiscalZ20.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
var
  iRet : Integer;
begin
  EnviaComando( '6' );
  iRet := EnviaComando( '8' );
  result := Status( 1, IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalZ20.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
// A Z20 Não permite acrescimo no total.
begin
  Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalZ20.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet : Integer;
  sRetorno, sData, sArgumento: AnsiString;
begin
// Tipo - Indica qual o status quer se obter da impressora:
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

// Verifica a hora da impressora
If Tipo = 2 then
begin
  iRet := EnviaComando( 'R' );
  if iRet = 0 then
  begin
    sData := ProcRetornoAscII( sArgumento );
    result := '0|' + copy(sData,1,2) + '/' + copy(sData,3,2) + '/' + copy(sData,7,2);
  end
  else
    result := '1';
end
// Verifica a data da Impressora
else if Tipo = 1 then
begin
  iRet := EnviaComando( 'R' );
  if iRet = 0 then
  begin
    sData := ProcRetornoAscII( sArgumento );
    result := '0|' + copy(sData,9,2) + ':' + copy(sData,11,2) + ':00';
  end
  else
    result := '1';
end
// Verifica o estado do papel
else if Tipo = 3 then
begin
  iRet := EnviaComando( 'S' );
  if iRet = 0 then
    if copy(ProcRetornoAscII( sArgumento ),2,1) = '0' then
      result := '0'
    else
      result := '3'
  else
    result := '1';
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  sArgumento := '095201';
  iRet := EnviaComando( 'P',sArgumento );
  if iRet = 0 then
  begin
    sRetorno := ProcRetornoAscII( sArgumento );
    if Pos(sRetorno,'03,06,07,08') > 0 then
      result := '7'
    else
      result := '0';
  end
  else
    result := '1';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  sArgumento := '095201';
  iRet := EnviaComando( 'P',sArgumento );
  if iRet = 0 then
  begin
    sRetorno := ProcRetornoAscII( sArgumento );
    if sRetorno = '01' then
      result := '10'
    else
      result := '0';
  end
  else
    result := '1';
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
else
  Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalZ20.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet : Integer;
  sArgumento : AnsiString;
begin
  sArgumento := '095603';
  iRet := EnviaComando( 'P', sArgumento );
  result := Status( 1,IntToStr(iRet) );
  if iRet = 0 then
     result := result + '|' + ProcRetornoAscII( sArgumento );
end;

//----------------------------------------------------------------------------
function TImpFiscalZ20.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sLinha, sAliq, sRet, sArgumento, sVlrTotal, sSituacao : AnsiString;
  aAliq : TaString;
  bAliq : Boolean;
  iRet, iTamanho, i : Integer;
begin
  bAliq := False;
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));

    // Caso a parte fracionaria do numero seja igual a zero
    // imprimir um inteiro.
    if Int(StrToFloat(qtde)) = StrToFloat(qtde) then
      qtde := IntToStr(Trunc(StrToFloat(qtde)))
    else
      qtde := FloatToStrF(StrToFloat(qtde), ffFixed, 7, 3);

    vlrUnit := FormataTexto(vlrUnit,9,2,3);

    // Trata os pontos decimais
    qtde := StrTran(qtde,',','.');
    vlrUnit := StrTran(vlrUnit,',','.');
    vlrdesconto := StrTran(vlrDesconto,',','.');

    // Faz o tratamento da aliquota
    sSituacao := copy(aliquota,1,1);
    aliquota := StrTran(copy(aliquota,2,5),',','.');

    //verifica se é para registra a venda do item ou só o desconto
    if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate(' ',11-Length(vlrDesconto)) + StrTran(vlrDesconto,'.',',') + sLinha;
          sLinha := sSituacao + aliquota + '%' + sLinha;
          If Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end
        else
          result := '1'
      else
        result := '0';
      exit;
    end;

    // Pega o valor total
    sVlrTotal := FloatToStrf(StrToFloat(qtde)*StrToFloat(vlrUnit), ffFixed, 18, 2);
    If Pos('.',sVlrTotal) > 0 then
      sVlrTotal := StrTran(sVlrTotal,'.',',');

    // Pega as aliquotas
    if sSituacao = 'S' then
      sAliq := LeAliquotasISS
    else
      sAliq := LeAliquotas;

    MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

    // Verifica se existe a aliquota
    For i := 0 to Length(aAliq)-1 do
    begin
      Aliquota := StrTran(Aliquota,',','.');
      sAliq := StrTran(aAliq[i],',','.');
      if StrTran(aAliq[i],',','.') = Aliquota then
        bAliq := True;
    end;

    sArgumento := '117201';
    EnviaComando( 'P',sArgumento );
    sRet := ProcRetornoAscII( '' );

    if (Pos(sSituacao,'TS') > 0) and (not bAliq) then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1';
      exit;
    end;

    // Monta a linha para registro do item
    sLinha := ' ';
    sLinha := sSituacao + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',11-Length(sVlrTotal)) + sVlrTotal + sLinha;
    if Pos(sSituacao,'TS') > 0 then
      sLinha := sSituacao + aliquota + '%' + sLinha;
    //sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',9-Length(vlrUnit)) + StrTran(vlrUnit,'.',',') + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',7-Length(qtde)) + qtde + ' X' + sLinha;

    If Length( sLinha ) < iTamanho then
      sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;

    // Grava descricao
    EnviaComando( 'g', '00' );
    EnviaComando( 'g', '00'+copy(codigo+' '+descricao+Space(iTamanho),1,iTamanho) );

    // Imprime linha do registro de venda
    iRet := EnviaComando( ';', sLinha );
    result := Status( 1,IntToStr(iRet) );

    If iRet = 0 then
    begin
      // Verifica o desconto do item
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate( ' ', 11-length(vlrdesconto)) +
                    StrTran(vlrDesconto,'.',',') + sLinha;
          if Pos(sSituacao,'TS') > 0 then
            sLinha := sSituacao + aliquota + '%' + sLinha;
          if Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZ20.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;

  function AchaPagto( sPagto:AnsiString; aPagtos: TaString):AnsiString;
  var i, iPos : Integer;
  begin
    iPos := 0;
    for i:=0 to Length(aPagtos)-1 do
      if UpperCase(aPagtos[i]) = UpperCase(sPagto) then
        iPos := i + 1;
    result := IntToStr(iPos);
    if Length(result) < 2 then
      result := '0' + result;
  end;

  function MontaLinha( sPos, vlrDinheiro:AnsiString; iTamanho:Integer ):AnsiString;
  begin
    vlrDinheiro:= Trim(FormataTexto(vlrDinheiro,12,2,3));
    result := sPos + Replicate(' ',iTamanho-Length(vlrDinheiro)-5) + StrTran(vlrDinheiro,'.',',') + '   ';
  end;

var
  sPagto, sTotal, sLinha, sArgumento, sForma : AnsiString;
  aPagto,aAuxiliar : TaString;
  iRet, iTamanho,i : Integer;
begin

  // Faz a checagem do Parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Pega a condicao de pagamento
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Monta array com as formas de pagto solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Verifica se as formas de pagamento informadas existem na impressora
  i := 0;
  while i < Length(aAuxiliar) do
  begin
    if AchaPagto(aAuxiliar[i],aPagto) = '00' then
    begin
      ShowMessage('Não existe a condição de pagamento: ' + aAuxiliar[i]);
      break;
    end;
    Inc(i,2);
  end;

  // Verifica o tamanho da coluna de Impressao, e imprime total do cupom
  iRet := EnviaComando( '0' );
  result := Status( 1, IntToStr( iRet ) );

  if iRet = 0 then
  begin

    iTamanho := StrToInt(sDollar+copy(ProcRetornoAscII(''),7,2));
    sArgumento := '192908';
    EnviaComando( 'P',sArgumento );

    sTotal := ProcRetornoAscII( sArgumento );
    sTotal := FloatToStrf(StrToFloat(sTotal)/100, ffFixed, 18, 2);
    if Pos('.', sTotal) > 0 then
      sTotal := StrTran(sTotal,'.',',');
    sTotal := Replicate(' ',iTamanho-Length(sTotal)-3) + sTotal;
    EnviaComando( 'O', sTotal+'   ' );

    // Verifica a forma de pagamento.
    i:=0;
    While i < Length(aAuxiliar) do
    begin
      sForma := AchaPagto(aAuxiliar[i],aPagto);
      if sForma = '00' then
        sForma := '01';
      sLinha := MontaLinha( sForma, aAuxiliar[i+1], iTamanho );
      iRet := EnviaComando( 'i',sLinha );
      Inc(i,2);
    end;

    // Solicita ao ECF a impressao do troco
    EnviaComando( 'j' );

    result := Status( 1,IntToStr(iRet) );

  end;

end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenZanthus( sPorta,sModelo :AnsiString ) : AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ZECF32.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;
begin
  If Not bOpened Then
  Begin
    if sModelo = 'ZANTHUS IZ11' Then
      sDollar := '$'
    else
      sDollar := '';

    fHandle := LoadLibrary( 'ZECF32.DLL' );
    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'ZECF_FechaPortaSerial');
      if ValidPointer( aFunc, 'ZECF_FechaPortaSerial' ) then
        fFuncFechaPorta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ZECF_InicializaPortaSerial');
      if ValidPointer( aFunc, 'ZECF_InicializaPortaSerial' ) then
        fFuncAbrePorta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ZECF_EnviaComando');
      if ValidPointer( aFunc, 'ZECF_EnviaComando' ) then
        fFuncEnviaComando := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ZECF_EnviaComandoComArgumento');
      if ValidPointer( aFunc, 'ZECF_EnviaComandoComArgumento' ) then
        fFuncEnviaComandoArg := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ZECF_LeBuffer');
      if ValidPointer( aFunc, 'ZECF_LeBuffer' ) then
        fFuncLeBuffer := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ZECF_LeBufferASCII');
      if ValidPointer( aFunc, 'ZECF_LeBufferASCII' ) then
        fFuncLeBufferASCII := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ZECF_LeRetornoASCII');
      if ValidPointer( aFunc, 'ZECF_LeRetornoASCII' ) then
        fFuncLeRetornoASCII := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ZECF_LeRetorno');
      if ValidPointer( aFunc, 'ZECF_LeRetorno' ) then
        fFuncLeRetorno := aFunc
      else
        bRet := False;
    end
    else
    begin
      ShowMessage('O arquivo ZECF32.DLL não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      iRet := fFuncAbrePorta(StrToInt(Copy(sPorta,4,1)));
      if iRet <> 0 then
        bRet := False;
      if not bRet then
      begin
        ShowMessage('Erro na abertura da porta');
        result := '1|';
      end
      else
      begin
        bOpened := True;
        Result := '0|';
      end;
    end
    else
      result := '1|';
  End
  Else
    Result := '0|';
end;

//----------------------------------------------------------------------------
Function CloseZanthus : AnsiString;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      if fFuncFechaPorta <> 0 then
        ShowMessage('Erro ao fechar a comunicação com impressora Fiscal.');
      FreeLibrary(fHandle);
      fHandle := 0;
    end;
    bOpened := False;
  End;
  Result := '0|';
end;

//----------------------------------------------------------------------------
function EnviaComando( sComando:AnsiString; sArgumentos:AnsiString = '' ):Integer;
var pBuff : PChar;
begin
  if sArgumentos = '' then
  begin
    fFuncEnviaComando( sComando[1] );
    result := fFuncLeRetorno;
  end
  else
  begin
    pBuff := StrAlloc( Length(sArgumentos)+1 );
    StrPCopy(pBuff,sArgumentos);
    fFuncEnviaComandoArg( sComando[1],pBuff );
    result := fFuncLeRetorno;
    StrDispose(pBuff);
  end;
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//-----------------------------------------------------------
function TImpFiscalZanthus.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
begin
  ShowMessage('Recurso de emissão de pedido não disponível para essa impressora.');
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
var iRet : Integer;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalZanthus.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalZanthus.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalZanthus.LeTotNFisc:AnsiString;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
Function TImpFiscalZanthus.RedZDado(MapaRes:AnsiString):AnsiString;
begin
     Result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalZanthus.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalZanthus.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalZanthus.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sLinha, sAliq, sRet, sArgumento, sVlrTotal, sSituacao : AnsiString;
  aAliq : TaString;
  bAliq : Boolean;
  iRet, iTamanho, i : Integer;
begin
  bAliq := False;
  vlrunit := Trim(FormataTexto(vlrunit,12,2,3));
  qtde := Trim(FormataTexto(qtde,12,2,3));
  if (Trim(aliquota)<>'F') and (Trim(aliquota)<>'N') and (Trim(aliquota)<>'I') then
          aliquota:= copy(aliquota,1,1)+Trim(FormataTexto(Copy(aliquota, 2, length(aliquota)),4,2,3));
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0', 'A' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+Hex2Dec(copy(ProcRetornoAscII(''),7,2)));

    // Trata os pontos decimais
    qtde := StrTran(qtde,',','.');
    vlrUnit := StrTran(vlrUnit,',','.');
    vlrdesconto := StrTran(vlrDesconto,',','.');

    // Faz o tratamento da aliquota
    sSituacao := copy(aliquota,1,1);
    aliquota := StrTran(copy(aliquota,2,5),',','.');

    //verifica se é para registra a venda do item ou só o desconto
    if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          sLinha := Replicate(' ',11-Length(vlrDesconto)) + StrTran(vlrDesconto,'.',',') + sLinha;
          sLinha := sSituacao + aliquota + '%' + sLinha;
          If Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
          result := Status( 1,IntToStr(iRet) );
        end
        else
          result := '1'
      else
        result := '0';
      exit;
    end;

    // Pega o valor total
    sVlrTotal := FloatToStrf(StrToFloat(qtde)*StrToFloat(vlrUnit), ffFixed, 18, 2);
    If Pos('.',sVlrTotal) > 0 then
      sVlrTotal := StrTran(sVlrTotal,'.',',');

    // Pega as aliquotas
    if sSituacao = 'S' then
      sAliq := LeAliquotasISS
    else
      sAliq := LeAliquotas;

    MontaArray( Copy(sAliq,2,Length(sAliq)), aAliq );

    // Verifica se existe a aliquota
    For i := 0 to Length(aAliq)-1 do
    begin
      Aliquota := StrTran(Aliquota,',','.');
      sAliq := StrTran(aAliq[i],',','.');
      if StrTran(aAliq[i],',','.') = Aliquota then
        bAliq := True;
    end;

    sArgumento := '117201';
    iRet := EnviaComando( 'P',sArgumento );
    sRet := ProcRetornoAscII( '' );

    if (Pos(sSituacao,'TS') > 0) and (not bAliq) then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1';
      exit;
    end;

    // Monta a linha para registro do item
    sLinha := ' ';
    sLinha := sSituacao + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',11-Length(sVlrTotal)) + sVlrTotal + sLinha;
    if Pos(sSituacao,'TS') > 0 then
      sLinha := sSituacao + aliquota + '%' + sLinha;
    sLinha := Replicate(' ',9-Length(vlrUnit)) + StrTran(vlrUnit,'.',',')+ ' ' + sLinha;
    sLinha := ' ' + sLinha;
    sLinha := Replicate(' ',7-Length(qtde)) + qtde + ' X' + sLinha;

    If Length( sLinha ) < iTamanho then
      sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;

    // Grava descricao
    iRet := EnviaComando( 'g', '00' );
    iRet := EnviaComando( 'g', '00'+copy(codigo+' '+descricao+Space(iTamanho),1,iTamanho) );

    // imprime linha do registro de venda
    iRet := EnviaComando( ';', sLinha );
    result := Status( 1,IntToStr(iRet) );

    If iRet = 0 then
    begin
      // Verifica o desconto do item
      if StrToFloat( vlrdesconto ) > 0 then
        if EnviaComando( ']' ) = 0 then     // verifica se pode ser dado o desconto
        begin
          sLinha := ' ' + sSituacao + ' ';
          vlrdesconto := StrTran(FormataTexto(vlrdesconto,12,2,3),'.',',');
          sLinha := Replicate( ' ', 11-length(vlrdesconto)) +
                    StrTran(vlrDesconto,'.',',') + sLinha;
          if Pos(sSituacao,'TS') > 0 then
            sLinha := sSituacao + aliquota + '%' + sLinha;
          if Length( sLinha ) < iTamanho then
            sLinha := Replicate( ' ',iTamanho-Length(sLinha) ) + sLinha;
          iRet := EnviaComando( '<', sLinha );
//'                T18.00%          0,0100 T ' não funciona
//'                  T18.00%        0,0100 T ' não funciona
//'                  T18.00%          0,01 T ' funciona
          result := Status( 1,IntToStr(iRet) );
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.CancelaCupom( Supervisor:AnsiString ):AnsiString;

  function CancelaCupAnt:AnsiString;
  var iRet : Integer;
  begin
    // Verifica se pode cancelar o cupom anterior
    iRet := EnviaComando( 'B' );
    result := Status( 1, IntToStr( iRet ) );
    if copy( result, 1, 1 ) = '0' then
    begin
      // Cancela o cupom anterior
      iRet := EnviaComando( '@' );
      result := Status( 1,IntToStr(iRet) );
    end;
  end;

var
  iRet : Integer;
  sArgumento, sRet : AnsiString;
begin
  // Verifica se é cupom fiscal ou não fiscal
  sArgumento := '231701';
  EnviaComando( 'P',sArgumento );
  sRet := ProcRetorno( sArgumento );
  if sRet <> 'c' then
  begin
    iRet := EnviaComando( ':' );
    result := Status( 1,IntToStr(iRet) );
  end
  else
  begin
    // Verifica se o cupom está aberto
    sArgumento := '117201';
    EnviaComando( 'P', sArgumento );
    sRet := ProcRetorno( sArgumento );
    if sRet = #2 then   // Repouso com dia já iniciado
       // Verifica se pode e caso ok, cancela cupom anterior
       result := CancelaCupAnt
    else
    begin
      // Cancela cupom atual
      iRet := EnviaComando( ':' );
      result := Status( 1,IntToStr(iRet) );
      // Se não teve sucesso ...
      if copy( result, 1, 1 ) = '1' then
      begin
        // Verifica se existe um cupom aberto e se já foi dado o troco do mesmo
        // Pois está é a única situação que não cancelava no meio da impressão
        // do cupom.
        sArgumento := '117201';
        EnviaComando( 'P', sArgumento );
        sRet := ProcRetorno( sArgumento );
        // Se afirmativo, fecha o cupom ...
        if sRet = #8 then
        begin
          iRet := EnviaComando( '9' );
          result := Status( 1, IntToStr( iRet ) );
        end
        else
          result := '0|';
        // Verifica se pode e caso ok, cancela cupom anterior
        if copy( result, 1, 1 ) = '0' then
          result := CancelaCupAnt;
      end;
    end;
    if copy(result,1,1) = '0' then PulaLinha(9);
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;

  function AchaPagto( sPagto:AnsiString; aPagtos:TaString ):AnsiString;
  var i, iPos : Integer;
  begin
    iPos := 0;
    for i:=0 to Length(aPagtos)-1 do
      if UpperCase(aPagtos[i]) = UpperCase(sPagto) then
        iPos := i + 1;
    result := IntToStr(iPos);
    if Length(result) < 2 then
      result := '0' + result;
  end;

  function MontaLinha( sPos, vlrDinheiro:AnsiString; iTamanho:Integer ):AnsiString;
  begin
    vlrDinheiro:= Trim(FormataTexto(vlrDinheiro,12,2,3));
    result := sPos + Replicate(' ',iTamanho-Length(vlrDinheiro)-5) + StrTran(vlrDinheiro,'.',',') + '   ';
  end;

var
  sPagto, sTotal, sLinha, sArgumento, sForma : AnsiString;
  aPagto,aAuxiliar : TaString;
  iRet, iTamanho,i : Integer;
begin

  // Faz a checagem do Parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Pega a condicao de pagamento
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Monta array com as formas de pagto solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Verifica se as formas de pagamento informadas existem na impressora
  i := 0;
  while i < Length(aAuxiliar) do
  begin
    if AchaPagto(aAuxiliar[i],aPagto) = '00' then
    begin
      ShowMessage('Não existe a condição de pagamento: ' + aAuxiliar[i]);
      break;
    end;
    Inc(i,2);
  end;

  // Verifica o tamanho da coluna de Impressao, e imprime total do cupom
  iRet := EnviaComando( '0', 'A' );
  result := Status( 1, IntToStr( iRet ) );

  if iRet = 0 then
  begin

    iTamanho := StrToInt(sDollar+Hex2Dec(copy(ProcRetornoAscII(''),7,2)));
    sArgumento := '213308';
    EnviaComando( 'P',sArgumento );

    sTotal := ProcRetornoAscII( sArgumento );
    sTotal := FloatToStrf(StrToFloat(sTotal)/100, ffFixed, 18, 2);
    if Pos('.', sTotal) > 0 then
      sTotal := StrTran(sTotal,'.',',');
    sTotal := Replicate(' ',iTamanho-Length(sTotal)-3) + sTotal;
    EnviaComando( 'O', sTotal+'   ' );

    // Verifica a forma de pagamento.
    i:=0;
    While i < Length(aAuxiliar) do
    begin
      sForma := AchaPagto(aAuxiliar[i],aPagto);
      if sForma = '00' then
        sForma := '01';
      sLinha := MontaLinha( sForma, aAuxiliar[i+1], iTamanho );
      EnviaComando( 'i',sLinha );
      Inc(i,2);
    end;

    // Solicita ao ECF a impressao do troco
    iRet := EnviaComando( 'j' );

    result := Status( 1,IntToStr(iRet) );

  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString;
var iRet, iTamanho : Integer;
var sLinha : AnsiString;
begin
  if StrToFloat( vlrDesconto ) > 0 then
  begin
    // Verifica o tamanho da coluna de Impressao.
    iRet := EnviaComando( '0', 'A' );
    result := Status( 1, IntToStr( iRet ) );
    if iRet = 0 then
    begin
      iTamanho := StrToInt(sDollar+Hex2Dec(copy(ProcRetornoAscII(''),7,2)));
      // Registra o desconto.
      sLinha := '   ';
      if Pos('.',vlrDesconto) > 0 then
        vlrDesconto := StrTran( vlrDesconto,'.',',' );
      sLinha := Replicate(' ',iTamanho-Length(vlrDesconto)-3) + vlrDesconto + '   ';
      iRet := EnviaComando( '^', sLinha );
      result := Status( 1,IntToStr(iRet) );
    end;
  end
  else
    result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  iRet, iTamanho : Integer;
  sRet, sArgumento, sVlrTotal, sAliq, sLinha, sSituacao : AnsiString;
  lCancela : Boolean;
  aAliq : TaString;
begin
  if (Trim(aliquota)<>'F') and (Trim(aliquota)<>'N') and (Trim(aliquota)<>'I') then
        aliquota := Copy(aliquota,1,1)+FormataTexto(Copy(Aliquota,2,Length(aliquota)),4,2,1);
  sSituacao := copy(aliquota,1,1);
  aliquota  := StrTran(copy(aliquota,2,5),',','.');
  lCancela  := True;
  // Verifica o tamanho da coluna de impressao
  iRet := EnviaComando( '0', 'A' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+Hex2Dec(copy(ProcRetornoAscII(''),7,2)));
    if lCancela then
    begin
      sRet := '';
      sArgumento := FormataTexto(IntToStr(StrToInt(numitem)-1),4,0,2);

      iRet := EnviaComando( 'e', sArgumento );
      if iRet <> 0 then
      begin
        ShowMessage('O item informado não se encontra na memória da impressora.');
        result := '1';
        exit;
      end;

      // Pega as aliquotas
      if sSituacao = 'T' then
        sAliq := LeAliquotas
      else
        sAliq := LeAliquotasISS;

      MontaArray( copy(sAliq,2,Length(sAliq)), aAliq );

      // verifica o valor total do item
      sVlrTotal := FloatToStrf( StrToFloat(vlrUnit)*StrToFloat(qtde)-StrToFloat(vlrdesconto), ffFixed, 18, 2);

      // faz a exclusao do item
      sLinha := '';
      sLinha := ' ' + sSituacao + ' ';
      sLinha := Replicate(' ',11-Length(sVlrTotal)) + StrTran(sVlrTotal,'.',',') + sLinha;
      if Pos(sSituacao,'T,S') > 0 then
        sLinha := Trim(sSituacao) + StrTran(aliquota,',','.') + '%' + sLinha;

      If Length(sLinha) < iTamanho then
        sLinha := Replicate(' ',iTamanho-Length(sLinha)) + sLinha;
      sLinha := sArgumento + sLinha;

      iRet := EnviaComando( 'd',sLinha );
      result := Status( 1,IntToStr(iRet) );
    end;
  end
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var
  iRet : Integer;
  sLinha : AnsiString;
  iTamanho : Integer;
begin
  vlrAcrescimo := Trim(FormataTexto(vlrAcrescimo,12,2,3));
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0', 'A' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+Hex2Dec(copy(ProcRetornoAscII(''),7,2)));
    // Registra o desconto.
    sLinha := '   ';
    if Pos('.',vlrAcrescimo) > 0 then
      vlrAcrescimo := StrTran( vlrAcrescimo,'.',',' );
    sLinha := Replicate(' ',iTamanho-Length(vlrAcrescimo)-3) + vlrAcrescimo + '   ';
    iRet := EnviaComando( 'f', sLinha );
    result := status( 1,IntToStr(iRet) );
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var iRet, i, iTamanho, nLoop : Integer;
var sLinha : AnsiString;
var lOk : boolean;
begin
  i      := 1;
  lOk    := True;
  sLinha := '';
  if length( Texto ) = 0 then Texto := '.' + #10;
  // Verifica o tamanho da coluna de Impressao.
  iRet := EnviaComando( '0', 'A' );
  result := Status( 1, IntToStr( iRet ) );
  if iRet = 0 then
  begin
    iTamanho := StrToInt(sDollar+Hex2Dec(copy(ProcRetornoAscII(''),7,2)));
    for nLoop := 1 to Vias do
    begin
      while i <= Length(Texto) do
      begin
        if (copy(Texto,i,1) = #10) or (length(sLinha) >= iTamanho) then
        begin
          if sLinha <> '' then
          begin
            iRet := EnviaComando( '!', Copy(sLinha,1,iTamanho) );
            sLinha := '';
            if copy(Texto,i,1) <> #10 then sLinha := sLinha + copy(Texto,i,1);
            result := Status( 1, IntToStr( iRet ) );
            lOk := copy( result, 1, 1 ) = '0';
            if not lOk then break;
          end
          else
            PulaLinha(1);
        end
        else
          // Se for #, não grava na AnsiString
          if copy(Texto,i,1) <> #10 then sLinha := sLinha + copy(Texto,i,1);
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
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.GravaCondPag( condicao: AnsiString ):AnsiString;
var sPagto, sNovaPos, sRet : AnsiString;
    aPagto : TaString;
    iRet, iCont, iLenPag, iTotal : Integer;
begin

  // Monta vetor com formas existentes
  sPagto   := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Verifica se já existe a forma de pagamento
  iLenPag := length( aPagto ) - 1;
  result  := '0';

  for iCont := 0 to iLenPag do
    if UpperCase( aPagto[ iCont ] ) = UpperCase( condicao ) then
    begin
      ShowMessage( 'Já existe a condição de pagamento: ' + condicao );
      result := '4|';
      exit;
    end;

  // Pega o total de formas de pagamento permitidas
  EnviaComando('0', 'A');

  sRet   := ProcRetornoASCII('');
  iTotal := StrToInt( '$' + copy( sRet, length( sRet ) - 13, 2 ) );

  // Se o contador for igual ao total de formas de pagamento, já tem o total de formas
  if (iLenPag + 1) = iTotal then
  begin
    ShowMessage( 'Sem espaço em memória para armazenar a nova forma de pagamento.' );
    result := '6|';
  end
  else if result = '0' then
  begin
    // Calcula nova posição
    sNovaPos := IntToStr( iLenPag + 2 );
    if length( sNovaPos ) = 1 then
      sNovaPos := '0' + sNovaPos;
    // Grava nova forma de pagamento.
    iRet := EnviaComando( 'W', 'P' + sNovaPos + copy( condicao, 1, 16 ) );
    result := Status( 1, IntToStr( iRet ) );
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalZanthus0351.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString;
var
  iRet : Integer;
  sArgumento : AnsiString;
begin
  If Trim(ReducInicio) + Trim(ReducFim) = '' then
  Begin
      sArgumento := FormataData( DataInicio,1 ) + FormataData( DataFim,1 )+ '0';
      iRet := EnviaComando( 'G', sArgumento );
  End
  Else
  Begin
      sArgumento := ReducInicio + ReducFim + '0';
      iRet := EnviaComando( 'H', sArgumento );
  End;

  result := Status( 1,IntToStr(iRet) );

  // Salta linha
  PulaLinha( 0 );
end;

Function TrataTags( Mensagem : AnsiString ) : AnsiString;
var
  cMsg : AnsiString;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//---------------------------------------------------------------------------
function TImpFiscalZanthus.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

(*initialization
  RegistraImpressora('ZANTHUS 1E'            , TImpFiscalZ1E        , 'BRA', '480201');
  RegistraImpressora('ZANTHUS IZ20'          , TImpFiscalZ20        , 'BRA', '480701');
  RegistraImpressora('ZANTHUS IZ21'          , TImpFiscalZanthus    , 'BRA', '480801');
  RegistraImpressora('ZANTHUS IZ21  - V03.51', TImpFiscalZanthus0351, 'BRA', '480802');
  RegistraImpressora('ZANTHUS IZ11'          , TImpFiscalZ11        , 'BRA', '480601');
  RegistraImpCheque ('ZANTHUS IZ21 V03.51', TImpChequeZanthus, 'BRA');
  RegistraImpCheque ('ZANTHUS IZ21'       , TImpChequeZanthus, 'BRA');  *)
//----------------------------------------------------------------------------
end.
