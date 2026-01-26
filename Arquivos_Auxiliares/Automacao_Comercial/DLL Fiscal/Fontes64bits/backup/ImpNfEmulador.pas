unit ImpNfEmulador;

interface

uses
  Dialogs, ImpNFiscMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms, CMC7Main, StdCtrls, ShellApi;

type

  //============================================================================
  //Não tem tratamento de Tag pois as tags são baseadas nessa impressora
  //============================================================================

  TImpNfEmulador = class(TImpNFiscal)
  private
  public
    function Abrir( sPorta:String; iVelocidade : Integer; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function ImpTexto( Texto : String):String; override;
    function ImpCodeBar( Tipo,Texto:String  ):String; override;
    function ImpBitMap( Arquivo:String ):String; override;
    function AbreGaveta(): String; override;
  end;

  Function OpenNF( sPorta:String; iVelocidade : Integer ):String;
  Function CloseNF : String;
  Function RemoveTags( Mensagem : String): String;

implementation

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
Function OpenNF( sPorta:String; iVelocidade : Integer) : String;
begin
GravaLogEmulNFisc('Emulador Nao Fiscal -> Abrir porta :' + sPorta);
GravaLogEmulNFisc('Emulador Nao Fiscal -> Velocidade :' + IntToStr(iVelocidade));
Result := '0|';
end;

//----------------------------------------------------------------------------
Function CloseNF : String;
begin
GravaLogEmulNFisc('Emulador Nao Fiscal -> FechaPorta ');
Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpNfEmulador.Abrir(sPorta : String; iVelocidade : Integer ; iHdlMain:Integer) : String;
begin
GravaLogEmulNFisc('Emulador Nao Fiscal -> Abrir porta de comunicação :' + sPorta);
Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpNfEmulador.Fechar( sPorta:String ):String;
begin
GravaLogEmulNFisc('Emulador Nao Fiscal -> Fecha Conexão');
Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpNfEmulador.ImpTexto( Texto : String):String;
Var
  sTextoImp,sQRCode: String;
  bCorte : Boolean;
  iInd   : Integer;
Begin
sTextoImp := Texto;
bCorte    := False;

If sTextoImp = '<gui></gui>' then
begin
 GravaLogEmulNFisc('Emulador Nao Fiscal ->  Corte de Papel ');
 bCorte := True;
end;

If not bCorte then
begin
  iInd := Pos('<QRCODE>',UpperCase(Texto));
  If iInd > 0 then
  begin
    sTextoImp := RemoveTags(Copy(Texto,1,Pred(iInd)));
    sQRCode   := Copy(Texto,Pred(iInd),Pos('</QRCODE>',UpperCase(Texto)));
    sQRCode   := RemoveTags(sQRCode);
  end
  else
  begin
    sTextoImp := RemoveTags(Texto);
  end;

  GravaLogEmulNFisc('Emulador Nao Fiscal -> Texto : ' + sTextoImp);
  GravaLogEmulNFisc('Emulador Nao Fiscal -> QrCode: ' + sQRCode);
end;

Result := '0|';
End;

//-----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//Criada para remover as tags caso a impressora nao possua tratamento para o comando enviado pelo Protheus
//---------------------------------------------------------------------------------------------------------
Function RemoveTags( Mensagem : String): String;
var
    aTagsProtheus : array [1..30] of String;
    cMsg,cAuxTag : String;
    n : Integer;
begin

aTagsProtheus[	1	] := 	'<B>'	;
aTagsProtheus[	2	] := 	'<I>'	;
aTagsProtheus[	3	] := 	'<CE>'	;
aTagsProtheus[	4	] := 	'<S>'	;
aTagsProtheus[	5	] := 	'<E>'	;
aTagsProtheus[	6	] := 	'<C>'	;
aTagsProtheus[	7	] := 	'<N>'	;
aTagsProtheus[	8	] := 	'<L>'	;
aTagsProtheus[	9	] := 	'<SL>'	;
aTagsProtheus[	10	] := 	'<TC>'	;
aTagsProtheus[	11	] := 	'<TB>'	;
aTagsProtheus[	12	] := 	'<AD>'	;
aTagsProtheus[	13	] := 	'<FE>'	;
aTagsProtheus[	14	] := 	'<XL>'	;
aTagsProtheus[	15	] := 	'<GUI>'	;
aTagsProtheus[	16	] := 	'<EAN13>'	;
aTagsProtheus[	17	] := 	'<EAN8>'	;
aTagsProtheus[	18	] := 	'<UPC-A>'	;
aTagsProtheus[	19	] := 	'<CODE39>'	;
aTagsProtheus[	20	] := 	'<CODE93>'	;
aTagsProtheus[	21	] := 	'<CODABAR>'	;
aTagsProtheus[	22	] := 	'<MSI>'	;
aTagsProtheus[	23	] := 	'<CODE11>'	;
aTagsProtheus[	24	] := 	'<PDF>'	;
aTagsProtheus[	25	] := 	'<CODE128>'	;
aTagsProtheus[	26	] := 	'<I2OF5>'	;
aTagsProtheus[	27	] := 	'<S2OF5>'	;
aTagsProtheus[	28	] := 	'<QRCODE>'	;
aTagsProtheus[	29	] := 	'<BMP>'	;
aTagsProtheus[	30	] := 	'<CORRECAO>'	;

cMsg := Mensagem;

For n := 1 to 30 do
  while Pos( LowerCase(aTagsProtheus[n]) , cMsg ) > 0 do
  begin
     cMsg := StringReplace(cMsg,LowerCase(aTagsProtheus[n]),'',[]);
     cAuxTag := LowerCase(aTagsProtheus[n]);
     Insert( '/',cAuxTag,2);
     cMsg := StringReplace(cMsg,cAuxTag,'',[]);
  end;

Result := cMsg;
end;



//----------------------------------------------------------------------------
function TImpNfEmulador.ImpCodeBar( Tipo,Texto:String  ):String;
begin
GravaLogEmulNFisc('Emulador Nao Fiscal -> Imprime Codigo de Barra');
Result:= '0|';
end;

//----------------------------------------------------------------------------
function TImpNfEmulador.ImpBitMap( Arquivo:String ):String;
begin
GravaLogEmulNFisc('Emulador Nao Fiscal -> Imprime Imagem');
Result := '0|';

end;

//-----------------------------------------------------------------------------
function TImpNfEmulador.AbreGaveta(): String;
begin
GravaLogEmulNFisc('Emulador Nao Fiscal -> Abertura de Gaveta');
Result := '0|';
end;

initialization
  RegistraImpressora('Emulador Nao fiscal'  , TImpNfEmulador  , 'BRA' ,'      ');

end.
