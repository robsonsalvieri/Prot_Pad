unit ImpItautec;

interface

uses
  Dialogs, ImpFiscMain, ImpCheqMain, Windows, SysUtils, classes, IniFiles, LojxFun, Forms;

Type

  TImpFiscalItautec = class(TImpressoraFiscal)
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function LeituraX:AnsiString; override;
    function AbreEcf:AnsiString; override;
    function FechaEcf:AnsiString; override;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
    function LeAliquotas:AnsiString; override;
    function LeAliquotasISS:AnsiString; override;
    function LeCondPag:AnsiString; override;
    function PegaPDV:AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function GravaCondPag( condicao:AnsiString ):AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function Gaveta:AnsiString; override;
    function PegaSerie:AnsiString; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    procedure AlimentaProperties; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override;
    function RedZDado( MapaRes : AnsiString ):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Itautec POS 4000 - ECF-IF/3EII
///
  TImpChequeItautec = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;


Function OpenItautec ( sPorta:AnsiString ) : AnsiString;
Function CloseItautec( sPorta:AnsiString ) : AnsiString;
Function TrataErro( Retorno: Word ): Boolean;
Function TrataTags( Mensagem : AnsiString ) : AnsiString;

Implementation
var
sCondicao    : AnsiString;
sCliente     : AnsiString;
sValor       : AnsiString;
sTotaliza    : AnsiString;
bOpened      : Boolean;
Data: array[0..7] of char;
Hora: array[0..5] of char;
Mov:  array[0..7] of char;
Verao: Byte;
Red: Byte;
fHandle : THandle;
fFuncE4Open            : Function ( Porta: Byte; Tipo: Byte ): Word; StdCall;
fFuncE4Close           : Function : Word; StdCall;
fFuncE4Reset           : Function (Numero:Integer):Integer; StdCall;
fFuncE4IniCup          : Function (Tipo: Byte): Word; StdCall;
fFuncE4FimCup          : Function : Word; stdcall;
fFuncE4RPPrim          : Function ( Cat: Byte): Word; stdcall;
fFuncE4RPProx          : Function (Cat: Byte; Compl: PChar; Sinal: PChar; var RP: Byte): Word; stdcall;
fFuncE4InfECF          : Function (Serie: PChar; CGC: PChar; IE: PChar; IM: PChar; Cliche: PChar; Firm: Pchar; Seq: Pchar; Var Modelo: Byte): Word; stdcall;
fFuncE4ValAtu          : Function (Reg: Byte; Valor: PChar): Word; stdcall;
fFuncE4RPCria          : Function (Cat: Byte; Compl: PChar; Sinal: PChar; var RP: Byte): Word; stdcall;
fFuncE4LMF             : Function (Tipo: Byte; Opc: Byte; Prm1: PChar; Prm2: PChar): Word; stdcall;
fFuncE4IteCF           : Function (RP: Byte; Cod: PChar; Desc: PChar; Qtd: PChar; Valor: PChar): Word; stdcall;
fFuncE4CanCup          : Function : Word; stdcall;
fFuncE4CanIt           : Function (RP: Byte; SeqItem: Word; Valor: PChar; Desc: PChar): Word; stdcall;
fFuncE4DesIt           : Function (Opc: Byte; RP: Byte; SeqItem: Word; Valor: PChar; Desc: PChar): Word; stdcall;
fFuncE4TotCup          : Function : Word; stdcall;
fFuncE4DesCup          : Function (Opc: Byte; Valor: PChar; Desc: PChar): Word; stdcall;
fFuncE4AcrCup          : Function (Opc: Byte; Valor: PChar; Desc: PChar): Word; stdcall;
fFuncE4RegPag          : Function (RP: Byte; Valor: PChar): Word; stdcall;
fFuncE4Troco           : Function : Word; stdcall;
fFuncE4InfCup          : Function (Reg: Word; Valor: PChar): Word; stdcall;
fFuncE4Print           : Function (Buffer: PChar): Word; stdcall;
fFuncE4Cons            : Function (Nome: PChar; Num: PChar; Endereco: PChar) : Word; stdcall;
fFuncE4Aut             : Function (Texto: PChar): Word; stdcall;
fFuncE4IniDoc          : Function : Word; stdcall;
fFuncE4FimDoc          : Function : Word; stdcall;
fFuncE4RdData          : Function  (Data: Pchar ; Hora: Pchar; var Verao: Byte; Mov: PChar; var Red: Byte): Word; stdcall;
fFuncE4OpeCNF          : Function (RP: Byte; Sinal: PChar; Desc: PChar; Valor: PChar): Word; stdcall;
fFuncE4StaECF          : Function (var Cupom: Byte; var Reg: Byte): Word; stdcall;
fFuncE4ImpChq          : Function (Banco: integer; Nominal, Cidade, Data, Valor, LinAdic1, LinAdic2: PChar): Word; stdcall;
fFuncE4ValRed          : Function (Reg: Byte; Valor: PChar): Word; stdcall;
fFuncE4OpenGv          : Function : Word; stdcall;
fFuncE4StatGv          : Function : Word; StdCall;

//---------------------------------------------------------------------------
function TImpFiscalItautec.Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString;
begin
  Result := '0';
  If not bOpened then
  begin
    Result := OpenItautec( sPorta );
  end;
  // Carrega as aliquotas e N. PDV e Cond. Pagto. para ganhar performance
  if Copy(Result,1,1) = '0' then
    AlimentaProperties;
end;

//----------------------------------------------------------------------------
Procedure TImpFiscalItautec.AlimentaProperties;
var
  Compl: array[0..17] of char;
  Sinal: array[0..2]  of char;
  RP: Byte;
  Serie:  array[0..20]  of char;
  CGC:    array[0..20]  of char;
  IE:     array[0..20]  of char;
  IM:     array[0..20]  of char;
  Cliche: array[0..255] of char;
  Firm:   array[0..5]   of char;
  Seq:    array[0..4]   of char;
  bTipo : Byte;
begin
  /// Inicialização de variaveis
  ICMS       := '';
  ISS        := '';
  FormasPgto := '';

  // Retorno de Aliquotas ( ICMS )
  if TrataErro(fFuncE4RPPrim(2)) then
  begin
    while fFuncE4RPProx(2, Compl, Sinal, RP) = 0 do
      ICMS := ICMS+'|'+ StrTran(Compl,',','.');
  end;

  // Retorno de Aliquotas ( ISS )
  if TrataErro(fFuncE4RPPrim(4)) then
  begin
    while fFuncE4RPProx (4, Compl, Sinal, RP) = 0 do
      ISS := ISS+'|'+ StrTran(Compl,',','.');
  end;

  // Retorno do Numero do Caixa (PDV)
  bTipo  := 1;
  fFuncE4InfECF(Serie, CGC, IE, IM, Cliche, Firm, Seq, bTipo);
  PDV := Seq;

  // Retorno das Condições de Pagamento
  if TrataErro(fFuncE4RPPrim(5)) then
  begin
    while fFuncE4RPProx (5, Compl, Sinal, RP) = 0 do
      FormasPgto := FormasPgto +'|'+ StrTran(Compl,',','.');
  end;

end;

//-----------------------------------------------------------
function TImpFiscalItautec.PegaPDV:AnsiString;
Begin
  Result := '0|'+PDV;
end;

//-----------------------------------------------------------
function TImpFiscalItautec.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  Valor: array[0..17] of char;

begin
  Result:='1|';
  if TrataErro (fFuncE4ValAtu (3, Valor)) then
    Result:='0|'+Valor;
end;

//---------------------------------------------------------------------------
function TImpFiscalItautec.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalItautec.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  Result := CloseItautec( sPorta );
end;

//---------------------------------------------------------------------------
function TImpFiscalItautec.LeituraX : AnsiString;
begin
  Result := '1|';
  TrataErro (fFuncE4Reset (0));
  if TrataErro (fFuncE4IniCup (0)) then
     Begin
     TrataErro (fFuncE4FimCup);
     Result := '0|';
     End
end;
//-----------------------------------------------------------
function TImpFiscalItautec.AbreEcf:AnsiString;
begin
  Result:='0|';
  TrataErro(fFuncE4Reset(0));
end;

//-----------------------------------------------------------
function TImpFiscalItautec.FechaEcf:AnsiString;
begin
  Result := ReducaoZ('S');
end;

//-----------------------------------------------------------
function TImpFiscalItautec.ReducaoZ( MapaRes:AnsiString ):AnsiString;
Var
  nI : Integer;
  aRetorno : array of AnsiString;
  fBase : Real;
  fAliq : Real;
  pRet : Array[0..15] of Char;
  nAliq : Integer;
  nContAli : integer;
  nAux : Integer;
  sAliq : AnsiString;
  sAliqISS : AnsiString;
  sAux : AnsiString;
  bCont : Boolean;
  nISS : Integer;
  sCalc : AnsiString;
  cResul : AnsiString;
Begin
If Trim( MapaRes ) = 'S' Then
Begin

  SetLength( aRetorno, 21 );

  // Data do movimento
  aRetorno[ 0 ] := StrPas( Mov );
  aRetorno[ 0 ] := Copy( aRetorno[ 0 ], 1, 2 ) + '/' + Copy( aRetorno[ 0 ], 3, 2 ) + '/' + Copy( aRetorno[ 0 ], 5, 4 );

  // Numero do PDV
  aRetorno[ 1 ] := '0' + PDV;

  // Numero de serie do ECF
  aRetorno[ 2 ] := Copy( PegaSerie, 3, Length( PegaSerie ) );

  // Numero de Reducoes
  If TrataErro( fFuncE4ValAtu( 4, pRet ) ) then
    aRetorno[ 3 ] := Copy( StrPas( pRet ), 2, Length( StrPas( pRet ) ) );

  // Grande Total
  If TrataErro( fFuncE4ValAtu( 1, pRet ) ) then
    aRetorno[ 4 ] := Copy( StrPas( pRet ), 1, Length( StrPas( pRet ) ) - 2 ) + '.' + Copy( StrPas( pRet ), Length( StrPas( pRet ) ) - 1, Length( StrPas( pRet ) ) );

  // Numero do documento final
  aRetorno[ 6 ] := Copy( PegaCupom( 'N' ), 3, 6 );
  aRetorno[ 5 ] := aRetorno[ 6 ];

  // Valor do cancelamento
  If TrataErro( fFuncE4ValAtu( 7, pRet ) ) then
    aRetorno[ 7 ] := Copy( StrPas( pRet ), 3, 12 ) + '.' + Copy( StrPas( pRet ), 15, 2 );

    aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS

  // Valor do Desconto
  If TrataErro( fFuncE4ValAtu( 8, pRet ) ) then
    aRetorno[ 9 ] := Copy( StrPas( pRet ), 7, 8 ) + '.' + Copy( StrPas( pRet ), 15, 2 );

    aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS

  // Valor de Substituição
  If TrataErro( fFuncE4ValAtu( 11, pRet ) ) then
    aRetorno[ 10 ] := Copy( StrPas( pRet ), 7, 8 ) + '.' + Copy( StrPas( pRet ), 15, 2 );

  // Valor de Isento
  If TrataErro( fFuncE4ValAtu( 12, pRet ) ) then
    aRetorno[ 11 ] := Copy( StrPas( pRet ), 7, 8 ) + '.' + Copy( StrPas( pRet ), 15, 2 );

  // Valor de Não Tributado
  If TrataErro( fFuncE4ValAtu( 13, pRet ) ) then
    aRetorno[ 12 ] := Copy( StrPas( pRet ), 7, 8 ) + '.' + Copy( StrPas( pRet ), 15, 2 );

  // Data da Redução Z
  aRetorno[ 13 ] := Copy( StatusImp( 2 ), 3, 10 );

  aRetorno[ 14 ] := FormataTexto( IntToStr( StrToInt( aRetorno[ 6 ] ) + 1 ), 6, 0, 2 );
  aRetorno[ 15 ] := FormataTexto('0',16, 0, 1);

  // Reinicio de operação
  If TrataErro( fFuncE4ValAtu( 0, pRet ) ) then
    aRetorno[ 17 ] := Copy( StrPas( pRet ), 4, 3 );

  // Quantidade de Aliquotas ICMS
  sAliq := Copy( LeAliquotas, 4, 100 );
  sAux := sAliq;
  While Trim( sAux ) <> '' do
  Begin
    nContAli := nContAli + 1;
    sAux := Copy( sAux, 7, Length( sAux ) );
  End;

  aRetorno[20]:= FormataTexto( IntToStr( nContAli ), 2, 0, 2 );

  // Captura as aliquotas ICMS
  nAliq := 20;
  nAux := 1;
  While nAux <= nContAli do
  Begin
    If fFuncE4ValAtu( nAliq, pRet ) = 0 then
    Begin
      SetLength( aRetorno, Length( aRetorno ) + 1 );
      sCalc := FloatToStr( ( StrToFloat( Copy( sAliq, 1, 5 ) ) * StrToFloat( StrPas( pRet ) ) ) /100 );
      sCalc := FormataTexto( sCalc, 12, 0, 2 );
      sCalc := Copy( sCalc, 1, 10 ) + '.' + Copy( sCalc, 11, 2 );
      aRetorno[ High( aRetorno ) ] := 'T' + Copy( sAliq, 1, 5 ) + ' ' + FormataTexto(StrTran(Copy( StrPas( pRet ), 4, 11 ) + '.' + Copy( StrPas( pRet ), 15, 2 ),'.','') ,14,2,1,'.') + ' ' + sCalc;
      nAliq := nAliq + 1;
      sAliq := Copy( sAliq, 7, Length( sAliq ) );
      nAux := nAux + 1;
    End
    Else
      break;
  End;

  // Venda liquida
  If fFuncE4ValRed( 1, pRet ) = 0 then  // Captura o GT inicial
  Begin
    //aRetorno[ 8 ] := StrPas( pRet );
    //aRetorno[ 8 ] := Copy( aRetorno[ 8 ], 1, 14 ) + '.' + Copy( aRetorno[ 8 ], 15, 2 );
    //aRetorno[ 8 ] := Copy( aRetorno[ 8 ], 1, Length( aRetorno[ 8 ] ) - 1 ) + '.' + Copy( aRetorno[ 8 ], Length( aRetorno[ 8 ] ) - 2, Length( aRetorno[ 8 ] ) );
    aRetorno[ 8 ] := Copy( StrPas( pRet ), 1, Length( StrPas( pRet ) ) - 2 ) + '.' + Copy( StrPas( pRet ), Length( StrPas( pRet ) ) - 1, Length( StrPas( pRet ) ) );
    aRetorno[ 8 ] := FloatToStr( StrToFloat( aRetorno[ 4 ] ) - StrToFloat( aRetorno[ 8 ] ) ); // VEnda Bruta
    aRetorno[ 8 ] := FloatToStr( StrToFloat( aRetorno[ 8 ] ) - StrToFloat( aRetorno[ 7 ] ) - StrToFloat( aRetorno[ 9 ] ) );
  End;

  // Captura as aliquotas de ISS
  aRetorno[16]:= '00000000000.00 00000000000.00';
  nAliq := 36;
  nIss := 0;
  sAliqISS := Copy( LeAliquotasISS, 4, 50 );
  sAux := sAliqISS;

  While Trim( sAux ) <> '' do
  Begin
    nISS := nISS + 1;
    sAux := Copy( sAux, 7, Length( sAux ) );
  End;

  nAux := 1;
  While nAux <= nISS do
  Begin
    If fFuncE4ValAtu( nAliq, pRet ) = 0 then
    Begin
      SetLength( aRetorno, Length( aRetorno ) + 1 );
      fBase := fBase + StrToFloat( Copy( StrPas( pRet ), 1, length( StrPas( pRet ) ) - 2 ) + '.' + Copy( StrPas( pRet ), length( StrPas( pRet ) ) -1, length( StrPas( pRet ) ) ) );
      fAliq := fAliq + ( fBase * StrToFloat( Copy( sAliqISS, 1, 5 ) )  / 100 );
      sAliqISS := Copy( sAliq, 7, Length( sAliq ) );
      aRetorno[ 16 ] := Copy( FormataTexto( FloatToStr( fBase ), 13, 2, 2 ), 1, 11 ) + '.' + Copy( FormataTexto( FloatToStr( fBase ), 13, 2, 2 ), 12, 2 ) + ' ' + Copy( FormataTexto( FloatToStr( fAliq ), 12, 2, 2 ), 1, 10 ) + '.' + Copy( FormataTexto( FloatToStr( fAliq ), 12, 2, 2 ), 11, 2 ) ;
      nAux := nAux + 1;
    End
    Else
      nAux := nISS + 1;
  End;
End;

  // Valor Contabil
  aRetorno[ 8 ] := FloatToStr( StrToFloat( aRetorno[ 8 ] ) - StrToFloat( Copy( FormataTexto( FloatToStr( fBase ), 13, 2, 2 ), 1, 11 ) + '.' + Copy( FormataTexto( FloatToStr( fBase ), 13, 2, 2 ), 12, 2 ) ) );

If fFuncE4Reset( 0 ) = 0 Then
Begin
  if TrataErro (fFuncE4IniCup (5)) then
  begin
    TrataErro (fFuncE4FimCup);
    If Trim( MapaRes ) ='S' then
    begin
      cResul := '0|';

      // Numero de Reducoes
      If TrataErro( fFuncE4ValAtu( 4, pRet ) ) then
        aRetorno[ 3 ] := Copy( StrPas( pRet ), 2, Length( StrPas( pRet ) ) );

      // Numero do documento final
      aRetorno[ 6 ] := Copy( PegaCupom( 'N' ), 3, 6 );
      aRetorno[ 5 ] := aRetorno[ 6 ];

      For ni:= 0 to High( aRetorno ) do
      begin
        cResul := cResul + aRetorno[ni]+'|';
      end;
      Result := cResul;
    end
    Else
      Result := '0|';
  End
  Else
    Result := '1|';
end;
End;
//-----------------------------------------------------------
function TImpFiscalItautec.LeAliquotas : AnsiString;
begin
  Result := '0|'+ICMS;
end;
//-----------------------------------------------------------
function TImpFiscalItautec.LeAliquotasISS : AnsiString;
begin
  Result := '0|'+ISS;
end;

//-----------------------------------------------------------
function TImpFiscalItautec.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
var
  i      : Integer;
  sRet   : AnsiString;
  aAliq  : TaString;
  bAchou : Boolean;
  bCat   : Byte;
  RP: Byte;
begin
  If Tipo = 1 then // Aliquota de ICMS
     Begin
     sRet := LeAliquotas;
     bCat := 2
     End
  Else  // Aliquota de ISS
     Begin
     sRet := LeAliquotasISS;
     bCat := 4
     End;

  Result:='1|';
  MontaArray( Copy(sRet, 3, Length(sRet)), aAliq );
  bAchou := False;
  For i:=0 to Length(aAliq)-1 do
    if aAliq[i] = Aliquota then
      bAchou := True;

  if bAchou then
     begin
     ShowMessage('A aliquota ' + Aliquota + ' ja está cadastrada.');
     result := '4';
     end
  else
    Begin
    Aliquota:=StrTran(Aliquota,'.',',');
    if TrataErro (fFuncE4RPCria (bCat, pChar(Aliquota), '', RP)) then
       Result:='0|';
    End;
end;

//-----------------------------------------------------------
function TImpFiscalItautec.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;
var
  i ,nPos : Integer;
  sRet    : AnsiString;
  aFormas : TaString;
  sForma  : AnsiString;
  sPagto  : AnsiString;
  sValor  : AnsiString;
  pTotCup : array[0..17] of char;
  iTotPag : Real;
begin
  Result  := '1|';
  sRet    := LeCondPag;
  sPagto  := Pagamento;
  iTotPag := 0;
  MontaArray( Copy(sRet, 3, Length(sRet)), aFormas );
  fFuncE4TotCup;
  While Trim(sPagto)<>'' do
      Begin
      nPos   := Pos('|',sPagto);
      sForma := Copy(sPagto,1,nPos-1);
      sPagto := Copy(sPagto,nPos+1,length(sPagto));
      nPos   := Pos('|',sPagto);
      sValor := Trim(FormataTexto(Copy(sPagto,1,nPos-1),12,2,3));
      sPagto := Copy(sPagto,nPos+1,length(sPagto));

      For i:=0 to Length(aFormas)-1 do
          Begin
          if Uppercase(Trim(aFormas[i])) = sForma then
             Begin
             if TrataErro (fFuncE4RegPag (i+60, PChar(sValor)))then
                Begin
                Result:='0|';
                iTotPag:=iTotPag+StrToFloat(sValor);
                Break;
                End;
             end;
          End;
      End;
  TrataErro (fFuncE4InfCup (504, pTotCup));  // Registrador 504 - Valor do subtotal do cupom
  TrataErro (fFuncE4Troco);
end;
//-----------------------------------------------------------
function TImpFiscalItautec.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString;
Var
  sDataI,sDataF: AnsiString;

begin
  Result:='1"|';
  sDataI:=FormataData(DataInicio,2);
  sDataF:=FormataData(DataFim,2);
  if TrataErro (fFuncE4LMF(0, 0, pChar(sDataI),pChar(sDataF) )) then
     Result:='0|';
end;
//-----------------------------------------------------------
function TImpFiscalItautec.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
begin
  If Pos('|', Cliente) > 0 then
    Cliente := Copy( Cliente, 1, (Pos('|',Cliente) - 1));

  If Length(Cliente) = 0 Then
     Cliente := ' ';

  sCliente := Cliente;
  Result:='1|';
  TrataErro (fFuncE4Reset(0));
  if TrataErro (fFuncE4IniCup (2)) then
     Result:='0|';
end;
//-----------------------------------------------------------
function TImpFiscalItautec.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
   sMsg : AnsiString;
begin
  Result := '1|';
  
  sMsg := Mensagem;
  sMsg := TrataTags( sMsg );
  
  if Trim(sMsg) <> '' then
     Begin
     TrataErro (fFuncE4Print ('================================================'));
     sMsg := Trim(sMsg);
     While Trim(sMsg)<>'' do
        Begin
        TrataErro (fFuncE4Print (PChar( Copy(sMsg,1,48))));
        sMsg:=Copy(sMsg,48,Length(sMsg));
        End;
     TrataErro (fFuncE4Print ('================================================'));
     End;
  TrataErro (fFuncE4Cons(' ', PChar(sCliente), ' '));
  if TrataErro (fFuncE4FimCup) then
     Result:='0|';
end;
//-----------------------------------------------------------
function TImpFiscalItautec.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  Retorno: Word;
  nI     : Integer;

begin
  Result:='0|';
  if TrataErro(fFuncE4IniDoc) then
     Begin
     For nI:= 1 to Vezes do
        Begin
        ShowMessage('Insira o documento, para '+IntToStr(nI)+'a');
        Retorno:=fFuncE4Aut(PChar( Copy(Texto+space(21),1,21) ));
        while IntToHex (Retorno, 4) = '0B37' do // Não existe documento inserido
           begin
           ShowMessage('Falha : Documento não Inserido...');
           Retorno := fFuncE4Aut (PChar( Copy(Texto+space(21),1,21) ));
           end;
        Result:='0|';
        End;
     TrataErro(fFuncE4FimDoc);
     End;
end;

//-----------------------------------------------------------
function TImpFiscalItautec.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
Var
  sAliq: AnsiString;
  sTipo: AnsiString;
  bReg : Byte;
  i      : Integer;
  sRet   : AnsiString;
  aAliq  : TaString;
  lAliqCad : Boolean;
  
begin
  Result := '1|';
  // somente Desconto no item
  if ( Trim(codigo+descricao)='') and ( StrToFloat(vlrdesconto)>0.00 ) then
     Begin
     if TrataErro (fFuncE4DesIt (0, 20, 0, PChar(vlrDesconto), 'Desconto em Item')) then
        Result := '0|';
     exit;
     end;

  sTipo  := Copy(Aliquota,1,1);
  sAliq  := Copy(Aliquota,2,Length(Aliquota)-1);
  sRet   := '';
  bReg   := 0;
  if sTipo='T' then
     sRet := LeAliquotas;
  if sTipo='S' then
     sRet := LeAliquotasISS;
  if sTipo='F' then
     bReg:=11;
  if sTipo='I' then
     bReg:=12;
  if sTipo='N' then
     bReg:=13;

  lAliqCad := False;
  if ( Trim(sRet)<>'') and ( bReg = 0 ) then
     Begin
     MontaArray( Copy(sRet, 3, Length(sRet)), aAliq );
     For i:=0 to Length(aAliq)-1 do
        if StrToFloat(aAliq[i]) = StrToFloat(sAliq) then
        Begin
          lAliqCad := True;
          if sTipo='T' then
             bReg:= i+20
          else
             bReg:= i+36;
          Break;
        end
     end;

  If (Pos(sTipo,'ST') > 0) and not (lAliqCad) then
  begin
    MsgStop('Aliquota não cadastrada');
    Result := '1';
  end
  Else
  begin
    Qtde := FloatToStrf(StrToFloat(Qtde),ffFixed,18,3);
    VlrUnit := FloatToStrf(StrToFloat(VlrUnit),ffFixed,18,2);
    if TrataErro( fFuncE4IteCF (bReg, PChar(Codigo), PChar(Descricao), PChar(Qtde), PChar(VlrUnit))) then
      if  StrToFloat(vlrdesconto)>0.00  then
      Begin
        vlrDesconto:= Trim(FormataTexto(vlrDesconto,12,2,3));
        if TrataErro (fFuncE4DesIt (0, 20, 0, pChar(vlrDesconto), 'Desconto em Item')) then
          Result := '0|'
      end
      else
        Result:='0|';
  end;
end;
//-----------------------------------------------------------
function TImpFiscalItautec.CancelaCupom( Supervisor:AnsiString ): AnsiString;
begin
  Result:='1|';
  if StatusImp(5) <> '0' then
  begin
    if TrataErro (fFuncE4Reset(0))then
        Result := '0|';
  end
  Else
  begin
     if   TrataErro (fFuncE4CanCup) then
        Result:='0|';
  end;
end;
//-----------------------------------------------------------
function TImpFiscalItautec.DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString;
begin
  Result:='1|';
  If StrToFloat(vlrDesconto) > 0 then
  begin
    vlrDesconto := FloatToStrf(StrToFloat(vlrDesconto),ffFixed,18,2);
    if TrataErro (fFuncE4DesCup (0, PChar(vlrDesconto), 'Desconto no Total do Cupom')) then
     Result:='0|';
  end
  Else
    Result := '0|';
end;
//-----------------------------------------------------------
function TImpFiscalItautec.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
begin
  Result:='1|';
  vlrAcrescimo := Trim( vlrAcrescimo );
  if TrataErro (fFuncE4AcrCup (0, PChar(VlrAcrescimo), 'Acrescimo no Total do Cupom')) then
     Result:='0|';
end;

//-----------------------------------------------------------
function TImpFiscalItautec.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
begin
  Result:='1|';
  if TrataErro (fFuncE4CanIt (20, StrToInt(NumItem), '0,00', 'Cancelamento de Item     ')) then
     Result:='0|';
end;
//-----------------------------------------------------------
function TImpFiscalItautec.GravaCondPag(condicao:AnsiString ):AnsiString;
var
  i       : Integer;
  sRet    : AnsiString;
  aFormas : TaString;
  bAchou  : Boolean;
  bCat    : Byte;
  RP      : Byte;
begin
  sRet := LeCondPag;
  bCat := 5;

  Result:='1|';
  MontaArray( Copy(sRet, 3, Length(sRet)), aFormas );
  bAchou := False;
  Condicao:=Uppercase(Trim(Condicao));
  For i:=0 to Length(aFormas)-1 do
    if Uppercase(Trim(aFormas[i])) = Condicao then
      Begin
      bAchou := True;
      break;
      end;

  if bAchou then
     begin
     ShowMessage('A Forma de pagamento : ' + Condicao + ' ja está cadastrada.');
     result := '4';
     end
  else
    Begin
    Condicao:=Copy(Condicao+space(16),1,16);
    if TrataErro (fFuncE4RPCria (bCat, pChar(Condicao), '', RP)) then
       Result:='0|';
    End;
end;
//-----------------------------------------------------------
function TImpFiscalItautec.LeCondPag : AnsiString;
begin
  Result := '0|'+FormasPgto;
end;
//-----------------------------------------------------------
function TImpFiscalItautec.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
    Procedure BuscaTotaliz(sTotalizador: AnsiString; var bIndice: Byte);
    var Descricao: array [0..16] of Char;
        sDescr: AnsiString;
        Sinal: array [0..1] of Char;
        RP: Byte;
        i: Integer;
    Begin
          bIndice:=0;
          i:=0;
          fFuncE4RPPrim ( 1 );
          While (i<20) and (bIndice<40) do
          begin
              fFuncE4RPProx ( 1, Descricao, Sinal, RP);
              sDescr:=Descricao;
              If (UpperCase(sDescr) = sTotalizador) then
                    bIndice := RP;
              i:=i+1;
          end;
    End;
var
  Recebimento : Byte;
begin
  sCondicao := Condicao;
  sValor    := Valor;
  sTotaliza := Totalizador;

  Recebimento := 0;
  BuscaTotaliz(Totalizador, Recebimento);

  Result:='1|';
  fFuncE4Reset(0);
  // Quando tem texto não imprime o cupom nao fiscal //*** otimizar a rotina depois.
  If Trim(Texto) <> '' then
  begin
    If TrataErro(fFuncE4Reset(0)) then
      If TrataErro(fFuncE4IniCup(19)) then
        If StrToFloat(Valor) > 0 then
          If TrataErro( fFuncE4OpeCNF (Recebimento, '-', PChar(Texto), PChar(Trim(Valor)))) then
            Result:='0|';
  end
  Else
  begin
    Result := '0|';
    If (fFuncE4IniCup(17)) > 0 then
      If TrataErro(fFuncE4Reset(0)) then
        If (fFuncE4IniCup(18)) > 0 then
          If TrataErro(fFuncE4Reset(0)) then
            If TrataErro(fFuncE4IniCup(19)) then
              Result:='1|';
  end;
end;

//-----------------------------------------------------------
function TImpFiscalItautec.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
Var
  sLinha: AnsiString;
  nI,nX : Integer;
  sTextoAux : AnsiString;
Begin
Result:='0';
sTextoAux := Texto;
//Verificando se tem Texto a ser impresso
If Trim(Texto)<>'' then
begin
  // Impressão da quantidade de vias.
  for nI := 1 to Vias do
  begin
    // Laço para imprimir toda a mensagem
    Texto := sTextoAux;
    while Trim(Texto)<>'' do
    begin
      sLinha:='';
      // Laço para pegar 40 caracter do Texto
      for nX:= 1 to 47 do
      begin
        // Caso encontre um CHR(10) (enter);imprima
        If Copy(Texto,nX,1)= #10 then
          Break;
        sLinha:=sLinha+Copy(Texto,nX,1);
      end;
      sLinha:=sLinha+Chr(10);

      // Impressão dos 40 caracteres,
      if not TrataErro (fFuncE4Print (PChar( sLinha))) then
      begin
        Result:='1|';
        Break;
      end;

      Texto:=Copy(Texto,nX+1,Length(Texto));
    end;

    if Copy(Result,1,1)='1' then
      Break;

    If Vias <> nI then
    begin
      fFuncE4Print(PChar(#10+#10+#10+#10+#10+#10+#10+#10+#10)); // Salta linhas pq ainda ha mais vias a serem impressas.
      Sleep(5000);
    end;

  end;
end;

End;
//----------------------------------------------------------------------------
function TImpFiscalItautec.FechaCupomNaoFiscal: AnsiString;
var
  sRet : AnsiString;
  aFormas : TaString;
  i : Integer;
begin
  Result:='1|';
  If fFuncE4FimCup <> 0 then
  begin
    If TrataErro(fFuncE4TotCup) then
    begin
      // Verifica se eh necessario fechar o cupom fiscal fazendo um totalizador
      sRet    := LeCondPag;
      MontaArray( Copy(sRet, 3, Length(sRet)), aFormas );
      For i := 0 to Length(aFormas)-1 do
        If Uppercase(Trim(aFormas[i])) = UpperCase(Trim(sCondicao)) then
          Break;

      If TrataErro (fFuncE4RegPag (60+i, PChar(sValor) )) then
      begin
        sCondicao := '';
        sValor    := '';
        sTotaliza := '';
        If TrataErro (fFuncE4Troco) then
          If TrataErro (fFuncE4FimCup) then
            Result:='0|';
      end;
    end;
  end
  Else
    Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalItautec.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString;
begin
  Result := RelatorioGerencial(cTextoImp , nVias, ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalItautec.RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
begin
  Result:='1|';
  fFuncE4Reset(0);

  If TrataErro (fFuncE4IniCup (4)) then
  begin
    result := TextoNaoFiscal( Texto, Vias );
    if copy( result, 1, 1 ) = '0' then
    begin
      if TrataErro (fFuncE4FimCup) then
        Result:='0|';
    end;
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalItautec.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalItautec.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString;
var
  RP: Byte;
begin
  Result:='1|';
  If (Copy(Descricao,1,1)<>'+') and ( Copy(Descricao,1,1)<>'-') then
     Begin
     ShowMessage('O primeiro caracter deve definir o tipo, sendo:'+chr(10)+chr(13)+
               '+ = Para entrada de valores       '+chr(10)+chr(13)+
               '- = Para saida de valores         '+chr(10)+chr(13));
     result:='1|';
     exit;
     end;

  if TrataErro (fFuncE4RPCria (1, pChar( Copy(Descricao,2,length(Descricao))), PChar(Copy(Descricao,1,1)), RP)) then
     Result:='0|';
End;
//----------------------------------------------------------------------------
function TImpFiscalItautec.Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
    Procedure BuscaTotaliz(sTotalizador: AnsiString; var bIndice: Byte);
    var Descricao: array [0..16] of Char;
        sDescr: AnsiString;
        Sinal: array [0..1] of Char;
        RP: Byte;
        i: Integer;
    Begin
          bIndice:=0;
          i:=0;
          fFuncE4RPPrim ( 1 );
          While (i<20) and (bIndice<60) do
          begin
              fFuncE4RPProx ( 1, Descricao, Sinal, RP);
              sDescr:=Descricao;
              If (UpperCase(sDescr) = UpperCase(sTotalizador)) then
                    bIndice := RP;
              i:=i+1;
          end;
    End;
var
  I,iFm : Integer;
  iCNF : Byte;
  sRet : AnsiString;
  aFormas : TaString;
  sNomeCNF, sTexto, sForma, sValor : AnsiString;
begin
  sValor := FloatToStrF(StrToFloat(Valor),ffFixed,18,2);;
  Result :='1|';
  iFm    := 0;
  If Tipo = 2 then
  Begin
    sNomeCNF := SigaLojaINI('ITAUTEC.INI', 'Suprimento', 'NomeCNF', 'Suprimento');
    sTexto   := SigaLojaINI('ITAUTEC.INI', 'Suprimento', 'Texto',   'SUPRIMENTO DE CAIXA');  // Limitado a 70 caracteres
    sForma   := SigaLojaINI('ITAUTEC.INI', 'Suprimento', 'Forma',   '(TROCO)');
    sRet := LeCondPag;
    MontaArray( Copy(sRet, 3, Length(sRet)), aFormas );
    For i:=0 to Length(aFormas)-1 do
    Begin
      if Uppercase(Trim(aFormas[i])) = Uppercase(sForma) then
      Begin
        iFm:=i+60;
        Break;
      End;
    End;
    BuscaTotaliz(sNomeCNF, iCNF);

    TrataErro(fFuncE4Reset (0));
    // Abre Cupom nào fiscal  (19)
    if TrataErro (fFuncE4IniCup(19)) then
      if TrataErro (fFuncE4OpeCNF(iCNF, '+', '', PChar(sValor))) then
      begin
        TrataErro(fFuncE4Print(PChar(sTexto)));
        if TrataErro(fFuncE4TotCup) then
          if TrataErro(fFuncE4RegPag(iFm, PChar(sValor))) then
          Begin
            TrataErro (fFuncE4Troco);
            if TrataErro (fFuncE4FimCup) then
              Result:='0|';
          End;
      end;
  End
  else if Tipo = 3 then
  begin
    sNomeCNF := SigaLojaINI('ITAUTEC.INI', 'Sangria', 'NomeCNF', 'Sangria');
    sTexto   := SigaLojaINI('ITAUTEC.INI', 'Sangria', 'Texto',   'SANGRIA');  // Limitado a 70 caracteres
    BuscaTotaliz(sNomeCNF, iCNF);
    TrataErro(fFuncE4Reset(0));
    // Abre Cupom nào fiscal  (19)
    if TrataErro(fFuncE4IniCup(19)) then
      if TrataErro(fFuncE4OpeCNF(iCNF, '-', '', PChar(sValor))) then
      begin
        TrataErro(fFuncE4Print(PChar(sTexto)));
        if TrataErro(fFuncE4TotCup) then
          if TrataErro (fFuncE4FimCup) then
            Result:='0|';
      end;
  end
  else
  begin
    Result := '0';
  End;
  Sleep(1000);
end;

//------------------------------------------------------------------------------
function TImpFiscalItautec.Gaveta:AnsiString;
begin
  TrataErro(fFuncE4OpenGv);
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalItautec.StatusImp( Tipo:Integer ):AnsiString;
var
  {Data: array[0..9] of char;
  Hora: array[0..5] of char;
  Mov:  array[0..9] of char;
  Verao: Byte;
  Red: Byte;  }
  Cupom: byte;

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
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware

// Verifica a hora da impressora
TrataErro (fFuncE4RdData (Data, Hora, Verao, Mov, Red));
If Tipo = 1 then
    result := '0|'+Copy(Hora,1,2)+':'+Copy(Hora,3,2)

// Verifica a data da Impressora
else if Tipo = 2 then
    result := '0|'+Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,5,4)
// Verifica o estado do papel
else if Tipo = 3 then
begin
  result := '0'
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
    Begin
    result := '0';
    if TrataErro (fFuncE4StaECF (Cupom, Red)) then
       if Cupom>0 then
          result := '7';
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
  result := '0';
  if (Copy(Data,1,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,5,4) <> Copy(Mov,1,2)+'/'+Copy(Mov,3,2)+'/'+Copy(Mov,5,4)) And (Red = 0) then
    result := '10';
end
//  9 - Verifica o Status do ECF
else if Tipo = 9 then
  result := '0'
// 10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 then
  result := '0'
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
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
begin
  // 0 - Fechada
  Result := IntToStr(fFuncE4StatGv);
end
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
End;
//-----------------------------------------------------------
function TrataErro (Retorno: Word): Boolean ;
var
  cMsg : AnsiString;
  cMsg1 : AnsiString;
begin
  TrataErro := TRUE;
  If LogDll Then
    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Retorno Itautec: ' + IntToStr( Retorno ) ));
  if (Retorno <> 0) then
  begin
    If Retorno = 2898 then
      MsgStop('Bobina de papel está acabando.')
    Else
    begin
      cMsg1 := 'Erro :'+IntToStr(Retorno);
      Case Retorno of
        2602 : cMsg := 'Número inválido de line feeds entre operações fiscais (5 linhas) ou não fiscais (2 linhas).';
        2612 : cMsg := 'Comando de venda(cupom ou comprovante) inválido após as 2:00 do dia posterior a data de movimento. Fazer uma Redução Z.';
        2613 : cMsg := 'Já foi feita uma redução nesta data de movimento. Nova venda (cupom ou comprovante) somente no dia seguinte.';
        2614 : cMsg := 'Função inválida pois ainda não totalizou.';
        2615 : cMsg := 'Função inválida pois já totalizou.';
        2616 : cMsg := 'Identificador de parâmetros de venda inválido.';
        2617 : cMsg := 'Parâmetros de venda repetido (Por exemplo: dois códigos).';
        2618 : cMsg := 'Parâmetro coluna inválida.';
        2619 : cMsg := 'Parâmetro quantidade de item inválido. O valor da quantidade de item devia ser ''1.000'', pois a coluna do preço unitário foi 0, ou seja, foi pedido para o mesmo não ser impresso.';
        2620 : cMsg := 'Ao editar parâmetros de venda saiu fora de linha de impressão. Estouro a direita.';
        2621 : cMsg := 'Ao editar parâmetros de venda saiu fora de linha de impressão. Estouro a esquerda.';
        2622 : cMsg := 'Ao editar parâmetros de venda, os dados se sobrepôem.';
        2623 : cMsg := 'Falta parâmetros obrigatórios na venda de item.';
        2624 : cMsg := 'Erro parâmetro não caracter ASCII.';
        2625 : cMsg := 'Erro parâmetro não dígito numérico ASCII.';
        2626 : cMsg := 'Número de dígitos do parâmetro inválido.';
        2627 : cMsg := 'Erro ao tratar dados da venda, por exemplo: falta de delimitador ''\0'' em parâmetros ASCII.';
        2628 : cMsg := 'Overflow em operação de item. Mais de 10 dígitos.';
        2629 : cMsg := 'Operação com valor 0,00';
        2630 : cMsg := 'Overflow em registrador parcial. Mais de 14 dígitos.';
        2631 : cMsg := 'Undeflow em registrador parcial.';
        2632 : cMsg := 'Overflow no total de vendas do dia. Mais de 16 dígitos.';
        2633 : cMsg := 'Erro no cálculo do subtotal.';
        2634 : cMsg := 'Valor do subtotal igual a 0.';
        2635 : cMsg := 'Divisão por 0.';
        2692 : cMsg := 'Total pago já maior que subtotal.';
        2693 : cMsg := 'Total pago ainda menor que subtotal.';
        2694 : cMsg := 'Já executou comando valor recebido.';
        2695 : cMsg := 'Ainda não executou comando valor recebido.';
        2696 : cMsg := 'Já executou comando troco.';
        2697 : cMsg := 'Ainda não executou comando troco.';
        2698 : cMsg := 'Acréscimo no item já efetuado.';
        2699 : cMsg := 'Item sem acréscimo.';
        2700 : cMsg := 'Tipo de registrador não fiscal inválido (+/-).';
        2701 : cMsg := 'Sem registrador de forma de pagamento definido ou sem registrador não fiscal definido.';
        2702 : cMsg := 'Acréscimo em item inválido.';
        2703 : cMsg := 'Cupom não fiscal vinculado inválido.';
        2704 : cMsg := 'Tipo ''-'' inválido nesse comando.';
        2705 : cMsg := 'Fim do tempo para impressão de não fiscal vinculado, Leitura X ou Redução Z.';
        2706 : cMsg := 'Tamanho do código inválido';
        2707 : cMsg := 'Leitura X de início de dia obrigatória.';
        2708 : cMsg := 'Margem esquerda insuficiente para impressão de autenticação.';
        2709 : cMsg := 'Documento preso na autenticação.';
        2710 : cMsg := 'Não tem valor válido para autenticação.';
        2711 : cMsg := 'Esgotaram-se as 5 autenticações no cupom.';
        2712 : cMsg := 'Autenticação não habilitada.';
        2713 : cMsg := 'Comando 101 não executado.';
        2714 : cMsg := 'Cupom adicional desabilitado - por intervenção.';
        2715 : cMsg := 'Cupom Adicional inválido - válido após venda.';
        2716 : cMsg := 'Já imprimiu 1 identificação do consumidor no cupom.';
        2717 : cMsg := 'Parâmetro tipo na autenticação inválido.';
        2718 : cMsg := 'Autenticação de desconto / acréscimo da tabela inválido.';
        2819 : cMsg := 'Porta serial inválida.';
        2820 : cMsg := 'Tipo do reset inválido.';
        2821 : cMsg := 'Opção verão inválida.';
        2822 : cMsg := 'Opção de horário da redução Z inválida.';
        2823 : cMsg := 'Opção de cupom inválida.';
        2824 : cMsg := 'Opção de desconto do item inválida.';
        2827 : cMsg := 'Opção de acréscimo no cupom inválida.';
        2828 : cMsg := 'Tipo da Leitura da Memória Fiscal inválido.';
        2829 : cMsg := 'Opção da Leitura da Memória Fiscal inválida.';
        2830 : cMsg := 'Opção de desconto do item inválida.';
        2838 : cMsg := 'Informação solicitada não está disponível na versão do firmware do ECF.';
        2839 : cMsg := 'Registrador inválido na função ValAtu.';
        2840 : cMsg := 'Registrador inválido na função ValRed.';
        2841 : cMsg := 'Registrador inválido na função ValImp.';
        2842 : cMsg := 'Categoria inválida na função RPCria.';
        2843 : cMsg := 'Categoria inválida na função RPPrim.';
        2844 : cMsg := 'Categoria inválida na função RPProx.';
        2845 : cMsg := 'Redução incial da Leitura da Memória Fiscal inválida.';
        2846 : cMsg := 'Redução final da Leitura da Memória Fiscal inválida.';
        2847 : cMsg := 'Redução inicial maior do que a Redução final da Leitura da Memória Fiscal.';
        2848 : cMsg := 'Data inicial da Leitura da Memória Fiscal inválida.';
        2849 : cMsg := 'Data final da Leitura da Memória Fiscal inválida.';
        2850 : cMsg := 'Data inicial maior do que a data final da Leitura da Memória Fiscal.';
        2851 : cMsg := 'Quantidade do item inválida.';
        2852 : cMsg := 'Preço unitário do item inválido.';
        2854 : cMsg := 'Código do item inválido.';
        2855 : cMsg := 'Descrição do item inválida.';
        2856 : cMsg := 'Registrador Parcial inválido na função OpeCNF.';
        2857 : cMsg := 'Erro no protocolo de comunicação do ECF.';
        2858 : cMsg := 'Modelo de ECF desconhecido.';
        2859 : cMsg := 'Erro no envio de pacotes para o ECF.';
        2860 : cMsg := 'Erro na recepção de pacotes do ECF.';
        2862 : cMsg := 'Cupom ou comprovante em andamento não pode ser encerrado.';
        2863 : cMsg := 'Sinal inválido na função OpeCNF.';
        2864 : cMsg := 'Sinal inválido na função RPCria.';
        2865 : cMsg := 'Quantidade de registradores na Categoria excedida.';
        2866 : cMsg := 'ECF não se encontra em estado de pós-redução.';
        2867 : cMsg := 'Final da lista de registradores na Categoria.';
        2868 : cMsg := 'Já foi realizada com sucesso a função de Open.';
        2869 : cMsg := 'Ainda não foi realizada com sucesso a função de Open.';
        2870 : cMsg := 'ECF não aceita documentos.';
        2871 : cMsg := 'Não existe documento inserido.';
        2872 : cMsg := 'Existe documento inserido.';
        2880 : cMsg := 'Banco não cadastrado. Verifique se o arquivo CHEQUEII.dat está no diretório \REMOTE' ;
        2898 : cMsg := 'Bobina acabando.';
      Else
        cMsg := '';
      End;
      MessageDlg(cMsg1 + #10 + cMsg, mtError, [mbOK], 0);
      TrataErro := FALSE;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalItautec.PegaSerie : AnsiString;
Var
  Serie:  array[0..20]  of char;
  CGC:    array[0..20]  of char;
  IE:     array[0..20]  of char;
  IM:     array[0..20]  of char;
  Cliche: array[0..255] of char;
  Firm:   array[0..5]   of char;
  Seq:    array[0..4]   of char;
  bTipo : Byte;
begin
    TrataErro( fFuncE4InfECF( Serie, CGC, IE, IM, Cliche, Firm, Seq, bTipo ) );
    result := '0|' + StrPas( Serie );
end;

//-----------------------------------------------------------
function TImpFiscalItautec.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
    Procedure BuscaTotaliz(sTotalizador: AnsiString; var bIndice: Byte);
    var Descricao: array [0..16] of Char;
        sDescr: AnsiString;
        Sinal: array [0..1] of Char;
        RP: Byte;
        i: Integer;
    Begin
          bIndice:=0;
          i:=0;
          fFuncE4RPPrim ( 1 );
          While (i<20) and (bIndice<40) do
          begin
              fFuncE4RPProx ( 1, Descricao, Sinal, RP);
              sDescr:=Descricao;
              If (UpperCase(sDescr) = sTotalizador) then
                    bIndice := RP;
              i:=i+1;
          end;
    End;


var
    Pedido      : byte;
    TefPedido   : byte;
    fim, indice : integer;
    slinha      : PChar;
    sPedido     : AnsiString;
    sTefPedido  : AnsiString;

  i,iFm   : Integer;
  sRet : AnsiString;
  aFormas : TaString;

begin
  Result:='1|';
  fFuncE4Reset(0);
  Pedido:=0;
  TefPedido:=0;

  //*******************************************************************************
  // Para não forçar o cliente a utilizar registradores fixos no ECF na emissão
  // de cupom não fiscal vinculado e não vinculado para a impressão do comprovante
  // de venda (função abaixo) foi criado o arquivo ITAUTEC.INI que terá o conteúdo
  // abaixo:
  //
  // [ITAUTEC POS4000]
  // Pedido=Nome do totalizador
  // TefPedido=Nome do totalizador
  //
  // [Sangria]
  // NomeCNF = Nome do CNF para a Sangria
  // Texto   = Texto a ser impresso no CNF, limitado a 70 caracteres
  //
  // [Suprimento]
  // NomeCNF = Nome do CNF para a Suprimento
  // Texto   = Texto a ser impresso no CNF, limitado a 70 caracteres
  // Forma   = Forma de pagamento a ser utilizada
  //
  // Onde:
  // - Pedido deverá conter o nome do totalizador que irá conter os valores de registros
  // do cupom não fiscal ref. ao comprovante de venda
  // - TefPedido deverá conter o nome do totalizador que irá conter os valores de
  // de registros do cupom não fiscal ref. ao comprovante do TEF quando for utilizado
  // na venda assistida (LOJA701) com o conceito de reservas + pedidos.
  // Os valores default para esses totalizadores será "RECEBIMENTO"
  //*******************************************************************************

  // Pega os nomes dos totalizadores no arquivo de configuração (ITAUTEC.INI)
  sPedido    := SigaLojaINI('ITAUTEC.INI', 'ITAUTEC POS4000', 'Pedido',    'RECEBIMENTO');
  sTefPedido := SigaLojaINI('ITAUTEC.INI', 'ITAUTEC POS4000', 'TefPedido', 'RECEBIMENTO');

  BuscaTotaliz(sPedido,Pedido);
  BuscaTotaliz(sTefPedido, TefPedido);

  //***
  iFm    := 0;
  sRet   := LeCondPag;
  MontaArray( Copy(sRet, 3, Length(sRet)), aFormas );
  For i:=0 to Length(aFormas)-1 do
    if Uppercase(Trim(aFormas[i])) = Uppercase(Trim('DINHEIRO')) then
    Begin
      iFm:=i+60;
      Break;
    End;

  //***
    If pedido > 39 then
    begin
        If TrataErro(fFuncE4IniCup(19)) then   // Abre comprovante não fiscal não vinculado;
            If TrataErro( fFuncE4OpeCNF (Pedido, '-', ' ' , PChar(Trim(Valor)))) then // Registra operação;
                If TrataErro(fFuncE4TotCup) then
                   If TrataErro (fFuncE4RegPag (iFm, PChar(Trim(Valor)))) then
                     If TrataErro (fFuncE4Troco) then
                        If TrataErro (fFuncE4FimCup) then

                        // Abre comprovante não fiscal vinculado a CNFNV;
                        If TrataErro(fFuncE4IniCup(17)) then
                        begin
                            If Length(texto)>0 then
                            begin
                                Repeat
                                    fim:=Length(texto);
                                    If Pos(#10,Copy(Texto, 1, 48))>0 then
                                    begin
                                        indice:=Pos(#10,Copy(Texto, 1, 48));
                                        slinha:= Pchar(Copy(Texto, 1, indice));
                                        Texto:= Copy(Texto,indice+1,fim);
                                    end
                                    else
                                    begin
                                        sLinha:=Pchar(Copy(Texto,1,47)+#10);
                                        Texto:=Copy(Texto,48,fim);
                                    end;
                                    TrataErro(fFuncE4Print(sLinha));
                                until  Length(texto)< 2;
                            end;
                            if (TrataErro(fFuncE4FimCup)) then Result:='0';
                        End;

        If Tef ='S' then
        Begin
            If TefPedido > 39 then
            begin
                If TrataErro(fFuncE4IniCup(19)) then   // Abre comprovante não fiscal não vinculado;
                    If TrataErro( fFuncE4OpeCNF (TefPedido, '-', ' ' , PChar(Trim(Valor)))) then // Registra operação;
                        If (TrataErro(fFuncE4TotCup)) then
                          If TrataErro (fFuncE4RegPag (iFm, PChar(Trim(Valor)))) then
                            If TrataErro (fFuncE4Troco) then
                              begin
                                TrataErro(fFuncE4FimCup);
                                Result:='0';
                              end;

            end;
        End;
    End
    Else
        Result:= '1';

end;

//----------------------------------------------------------------------------
function TImpFiscalItautec.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalItautec.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

 //------------------------------------------------------------------------------
function TImpFiscalItautec.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalItautec.LeTotNFisc:AnsiString;
var
  Compl: array[0..17] of char;
  Sinal: array[0..2]  of char;
  RP: Byte;
  sTotaliz : AnsiString;

begin
  /// Inicialização de variaveis


  // Retorno de Totalizadores
  if TrataErro(fFuncE4RPPrim(1)) then
  begin
    while fFuncE4RPProx(1, Compl, Sinal, RP) = 0 do
      begin
       sTotaliz   := sTotaliz  + Chr(RP) +',' + Trim(Compl) + '|' ;
      end;

      Result := '0|'+ sTotaliz;
  end
  Else Result := '1';
end;

 //------------------------------------------------------------------------------
function TImpFiscalItautec.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalItautec.RedZDado( MapaRes : AnsiString):AnsiString;
Begin
  Result := '0';
End;

//------------------------------------------------------------------------------
function TImpFiscalItautec.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalItautec.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalItautec.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenItautec( sPorta:AnsiString ) : AnsiString;

  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ECF4000.DLL');
      bOpened := False;
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc : Pointer;
  bRet  : Boolean;
begin
  bOpened := True;
  fHandle := LoadLibrary( 'ECF4000.DLL' );
  if (fHandle <> 0) Then
    begin
    bRet := True;

    aFunc := GetProcAddress(fHandle,'E4Open');
    if ValidPointer( aFunc, 'E4Open' ) then
      fFuncE4Open := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'E4RdData');
    if ValidPointer( aFunc, 'E4RdData' ) then
      fFuncE4RdData := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'E4StaECF');
    if ValidPointer( aFunc, 'E4StaECF' ) then
      fFuncE4StaECF := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'E4RegPag');
    if ValidPointer( aFunc, 'E4RegPag' ) then
      fFuncE4RegPag := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'E4ValAtu');
    if ValidPointer( aFunc, 'E4ValAtu' ) then
      fFuncE4ValAtu := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'E4Close');
    if ValidPointer( aFunc, 'E4Close' ) then
      fFuncE4Close := aFunc
    else
      begin
      bRet := False;
      end;


    aFunc := GetProcAddress(fHandle,'E4Troco');
    if ValidPointer( aFunc, 'E4Troco' ) then
      fFuncE4Troco := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4OpeCNF');
    if ValidPointer( aFunc, 'E4OpeCNF' ) then
      fFuncE4OpeCNF := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4InfCup');
    if ValidPointer( aFunc, 'E4InfCup' ) then
      fFuncE4InfCup := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4IniCup');
    if ValidPointer( aFunc, 'E4IniCup' ) then
      fFuncE4IniCup := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4Print');
    if ValidPointer( aFunc, 'E4Print' ) then
      fFuncE4Print := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4FimCup');
    if ValidPointer( aFunc, 'E4FimCup' ) then
      fFuncE4FimCup := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4Aut');
    if ValidPointer( aFunc, 'E4Aut' ) then
      fFuncE4Aut := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4Cons');
    if ValidPointer( aFunc, 'E4Cons' ) then
      fFuncE4Cons := aFunc
    else
      begin
      bRet := False;
      end;


    aFunc := GetProcAddress(fHandle,'E4IniDoc');
    if ValidPointer( aFunc, 'E4IniDoc' ) then
      fFuncE4IniDoc := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4FimDoc');
    if ValidPointer( aFunc, 'E4FimDoc' ) then
      fFuncE4FimDoc := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4RPPrim');
    if ValidPointer( aFunc, 'E4RPPrim' ) then
      fFuncE4RPPrim := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4RPProx');
    if ValidPointer( aFunc, 'E4RPProx' ) then
      fFuncE4RPProx := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4RPCria');
    if ValidPointer( aFunc, 'E4RPCria' ) then
      fFuncE4RPCria := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4IteCF');
    if ValidPointer( aFunc, 'E4IteCF' ) then
      fFuncE4IteCF := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4LMF');
    if ValidPointer( aFunc, 'E4LMF' ) then
      fFuncE4LMF := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4DesIt');
    if ValidPointer( aFunc, 'E4DesIt' ) then
      fFuncE4DesIt := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4CanIt');
    if ValidPointer( aFunc, 'E4CanIt' ) then
      fFuncE4CanIt := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4CanCup');
    if ValidPointer( aFunc, 'E4CanCup' ) then
      fFuncE4CanCup := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4InfECF');
    if ValidPointer( aFunc, 'E4InfECF' ) then
      fFuncE4InfECF := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4DesCup');
    if ValidPointer( aFunc, 'E4DesCup' ) then
      fFuncE4DesCup := aFunc
    else
      begin
      bRet := False;
      end;


    aFunc := GetProcAddress(fHandle,'E4TotCup');
    if ValidPointer( aFunc, 'E4TotCup' ) then
      fFuncE4TotCup := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4AcrCup');
    if ValidPointer( aFunc, 'E4AcrCup' ) then
      fFuncE4AcrCup := aFunc
    else
      begin
      bRet := False;
      end;


    aFunc := GetProcAddress(fHandle,'E4Reset');
    if ValidPointer( aFunc, 'E4Reset' ) then
      fFuncE4Reset := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4ImpChq');
    if ValidPointer( aFunc, 'E4ImpChq') then
      fFuncE4ImpChq := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4OpenGv');
    if ValidPointer( aFunc, 'E4OpenGv') then
      fFuncE4OpenGv := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4StatGv');
    if ValidPointer( aFunc, 'E4StatGv') then
      fFuncE4StatGv := aFunc
    else
      begin
      bRet := False;
      end;

    aFunc := GetProcAddress(fHandle,'E4ValRed');
    if ValidPointer( aFunc, 'E4ValRed') then
      fFuncE4ValRed := aFunc
    else
      begin
      bRet := False;
      end;


    end
  else
  begin
    ShowMessage('O arquivo ECF4000.DLL não foi encontrado.');
    bOpened := False;
    bRet := False;
  end;

  if bRet then
  begin
    result := '0|';

    If not TrataErro(fFuncE4Open(StrToInt(Copy(sPorta,4,1)),1)) then
    begin
      bOpened := False;
      ShowMessage('Erro na abertura da porta');
      result := '1|';
    end
  end
  else
    result := '1|';
end;

//---------------------------------------------------------------------------
Function CloseItautec( sPorta:AnsiString ) : AnsiString;
begin
  bOpened := False;
  if (fHandle <> INVALID_HANDLE_VALUE) then
  begin
    TrataErro(fFuncE4Close);
    FreeLibrary(fHandle);
  end;
  Result := '0|';
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Itautec POS 4000 - ECF-IF/3EII
///
function TImpChequeItautec.Abrir( aPorta:AnsiString ): Boolean;
begin
  Result := True;
  If not bOpened then
  begin
    Result := (Copy(OpenItautec( aPorta ),1,1) = '0');
  End
end;

//---------------------------------------------------------------------------
function TImpChequeItautec.Fechar( aPorta:AnsiString ): Boolean;
begin
    Result := True;
    If bOpened then
    begin
      Result := (Copy(CloseItautec( aPorta ),1,1) = '0');
    End
end;

//----------------------------------------------------------------------------
function TImpChequeItautec.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  Retorno, iBanco: Integer;
  dData: TDateTime;
begin
iBanco  := StrToInt(Banco);
Favorec := PChar(Copy(Favorec + Space(30),1,30));
Cidade  := PChar(Copy(Cidade + Space(20),1,20));
Valor   := PChar(FormataTexto(Valor,8,2,1));
Mensagem:= PChar(Copy(Mensagem + Space(70),1,70));
//Verso   := PChar(Copy(Verso + Space(70),1,70));

If length(data) = 8 then
    Data    := PChar(Copy(Data,7,2) + '/' + Copy(Data,5,2)+ '/' +Copy(Data,1,4))
else
    Data    := PChar(Copy(Data,5,2) + '/' + Copy(Data,3,2)+ '/' +Copy(Data,1,2));

dData   := StrToDate(Data);
Data    :=Pchar(FormataData(dData,2));

  Result := True;
  if TrataErro(fFuncE4IniDoc) then
  Begin
    Retorno:=fFuncE4ImpChq( iBanco, Favorec, Cidade, Data, Valor, Mensagem, '' );

    If not TrataErro(Retorno) then
    Begin
        Result := False;
        while IntToHex (Retorno, 4) = '0B37' do // Não existe documento inserido
        begin
            ShowMessage('Falha : Documento não Inserido...');
            Retorno := fFuncE4ImpChq( iBanco, Favorec, Cidade, Data, Valor, Mensagem, '' );
            If TrataErro(Retorno) then
                Result := True;
        end;
    End;
    ShowMessage('Retire o cheque');

    TrataErro(fFuncE4FimDoc);
  End;
end;

//----------------------------------------------------------------------------
function TImpChequeItautec.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequeItautec.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';

end;

Function TrataTags( Mensagem : AnsiString ) : AnsiString;
var
  cMsg : AnsiString;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//----------------------------------------------------------------------------
function TImpFiscalItautec.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

(*initialization
  RegistraImpressora('ITAUTEC POS4000 - V. 01.00' , TImpFiscalItautec, 'BRA', ' ');
  RegistraImpressora('ITAUTEC POS4000 - V. 06.15' , TImpFiscalItautec, 'BRA', ' ');
  RegistraImpCheque ('ITAUTEC POS4000' , TImpChequeItautec, 'BRA'); *)
//------------------------------------------------------------------------------
end.

