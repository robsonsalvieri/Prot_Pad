unit ImpNFiscMain;

interface

Uses
  Classes, SysUtils, Dialogs, IniFiles, Forms, LojxFun, FileCtrl;


  function  ImpNFiscAbrir( sModelo,sPorta:PChar; iVelocidade : Integer; iHdlMain:Integer ):Integer; StdCall;
  function  ImpNFiscFechar( iHdl:Integer;sPorta:PChar ):Integer; StdCall;
  function  ImpNFiscImpTexto( iHdl:Integer ; Texto : PChar ):Integer; StdCall;
  function  ImpNFiscCodeBar( iHdl:Integer; Tipo,Texto:PChar ):Integer; StdCall;
  function  ImpNFiscBitmap( iHdl:Integer; Arquivo:PChar):Integer; StdCall;
  function  ImpNFiscListar( var aBuff:AnsiString ):Integer; StdCall;
  function  ImpNFiscAbrGvt( iHdl:Integer ):Integer; StdCall;
  function  ImpNFiscStatus( iHdl:Integer; Tipo: pChar; aBuff:AnsiString ):Integer; StdCall;

Type
  TImpNFiscal = Class(TObject)
  private
    fModelo : AnsiString;

  public
    constructor create( sModelo, sPorta, sCodEcf : AnsiString); virtual;
    function Abrir(sPorta:AnsiString; iVelocidade : Integer; iHdlMain:Integer): AnsiString; virtual; abstract;
    function Fechar(sPorta:AnsiString): AnsiString; virtual; abstract;
    function ImpTexto( Texto : AnsiString):AnsiString; virtual; abstract;
    function ImpCodeBar( Tipo,Texto:AnsiString  ):AnsiString; virtual; abstract;
    function ImpBitMap( Arquivo:AnsiString ):AnsiString; virtual; abstract;
    function AbreGaveta() : AnsiString; virtual; abstract;
    function StatusImp( iTipo:Integer ) : AnsiString; virtual; abstract;
    property Modelo : AnsiString read fModelo;
  end;

  TImpNFiscalClass = class of TImpNFiscal;

  procedure RegistraImpressora(sModelo: AnsiString; cClass: TImpNFiscalClass; sPaises:AnsiString; sCodECF:AnsiString=' ');

implementation

type
    TListaDrivers = class(TStringList)
    public
      function RegistraImpressora( sModelo: AnsiString; cClass: TImpNFiscalClass; sPaises:AnsiString; sCodECF:AnsiString=' ' ): Boolean;
      function CriaImpressora( sModelo, sPorta: AnsiString; iHdlMain:Integer ): TImpNFiscal;
    end;

    TlistaImpNFiscal = class(TStringList)
    public
      destructor Destroy; override;
      function fAcha( iHdl:Integer ): TImpNFiscal;
      function fCriaImp(sModelo, sPorta: AnsiString; iVelocidade : Integer; iHdlMain:Integer ): AnsiString;
      function fApagaImp(iHdl:Integer;sPorta:AnsiString): AnsiString;
      function fImpTexto( iHdl:Integer ; Texto : AnsiString):AnsiString;
      function fImpCodeBar( iHdl:Integer; Tipo,Texto:AnsiString  ):AnsiString;
      function fImpBitMap( iHdl:Integer; Arquivo:AnsiString ):AnsiString;
      function fAbreGaveta( iHdl:Integer ) : AnsiString;
      function fStatus( iHdl,iTipo:Integer ) : AnsiString;
    end;

var
   _z_ListaDrivers : TListaDrivers;
   _z_ListaImpNFisc: TlistaImpNFiscal;

constructor TImpNFiscal.Create(sModelo, sPorta, sCodEcf : AnsiString);
begin
fModelo := sModelo;
end;

destructor TlistaImpNFiscal.Destroy;
var
  i : Integer;
begin
  for i := 0 to Count-1 do
    if (Objects[i] <> nil) Then
      Objects[i].Free;
  inherited;
end;

//----------------------------------------------------------------------------
function TlistaImpNFiscal.fAcha( iHdl: Integer ): TImpNFiscal;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TImpNFiscal(Objects[iHdl])
  else
    Result := nil;
end;

//-----------------------------------------------------------------------------
function TlistaImpNFiscal.fApagaImp(iHdl:Integer;sPorta:AnsiString): AnsiString;
var
  aImp: TImpNFiscal;
begin
  aImp := fAcha(iHdl);
  if Assigned( aImp ) then
  begin
    aImp.Fechar(sPorta);
    Objects[iHdl] := Nil;
    _z_ListaImpNFisc.Delete(iHdl);
    result := '0|';
  end
  else
    result := '1|';
end;

//---------------------------------------------------------------------------
function  TListaDrivers.CriaImpressora( sModelo, sPorta: AnsiString; iHdlMain:Integer ): TImpNFiscal;
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
    p :=  TImpNFiscalClass( Objects[iPos] ).MethodAddress('TImpNFiscal');
    If not Assigned(p) then
      Result := TImpNFiscalClass( Objects[iPos] ).Create( sModelo, sPorta, sCodEcf )
    else
      Result := nil;
  end;
end;

//-----------------------------------------------------------------------------
function TListaDrivers.RegistraImpressora( sModelo: AnsiString; cClass: TImpNFiscalClass; sPaises:AnsiString; sCodECF:AnsiString=' ' ): Boolean;
begin
if (IndexOf(sModelo) < 0) then
begin
  AddObject(sModelo,TObject(cClass));
  AddObject(sPaises,TObject(cClass));
  AddObject(sCodECF,TObject(cClass));
  Result := True;
end
else
  Result := False;
end;

procedure RegistraImpressora(sModelo: AnsiString; cClass: TImpNFiscalClass; sPaises:AnsiString; sCodECF:AnsiString=' ');
begin
  if (not _z_ListaDrivers.RegistraImpressora( sModelo, cClass, sPaises, sCodECF ))
  Then Raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;

//-----------------------------------------------------------------------------
function TlistaImpNFiscal.fCriaImp(sModelo, sPorta: AnsiString; iVelocidade : Integer; iHdlMain:Integer ): AnsiString;
var
  aImp: TImpNFiscal;
  sChave,sRet : AnsiString;
begin
  sChave := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);
  if (IndexOf(sChave) < 0) Then
  begin

    GravaLog('SIGALOJA -> Modelo de Impressora NAO FISCAL carregado:'+ sModelo);
    GravaLog('SIGALOJA -> sPorta carregado:'+ sPorta);

    aImp := _z_ListaDrivers.CriaImpressora( sModelo, sPorta, iHdlMain );
    if Assigned(aImp) Then
    begin
      sRet := aImp.Abrir(sPorta,iVelocidade,iHdlMain);
      if copy(sRet,1,1)<>'0' then  // erro, tenta fechar a porta e abri-la novamente
      begin
        sRet := aImp.Fechar(sPorta);
        sRet := aImp.Abrir(sPorta,iVelocidade,iHdlMain);
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

      GravaLog(' SIGALOJA <- Result [' + Result + ']');
    end
    else
    begin
      GravaLog(' Modelo de Impressora NAO FISCAL : ' + sModelo  + ' não encontrado ');
      ShowMessage(' Modelo de Impressora NAO FISCAL : ' + sModelo  + ' não encontrado ');
      Result := '-1';
    end;
  end
  else
  begin
    Result := '0|';
    GravaLog(' <- Impressora já foi setada ');
  end;
end;

//-----------------------------------------------------------------------------
function TlistaImpNFiscal.fImpTexto( iHdl:Integer ; Texto : AnsiString):AnsiString;
var
  aImp : TImpNFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ImpTexto(Texto);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TlistaImpNFiscal.fImpCodeBar( iHdl:Integer; Tipo,Texto:AnsiString  ):AnsiString;
var
  aImp : TImpNFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ImpCodeBar( Tipo , Texto );
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TlistaImpNFiscal.fImpBitMap( iHdl:Integer; Arquivo:AnsiString ):AnsiString;
var
  aImp : TImpNFiscal;
  sRet : AnsiString;
begin
  aImp := fAcha( iHdl );
  If Assigned(aImp) then
  begin
    sRet := aImp.ImpBitmap(Arquivo);
    result := sRet;
  end
  else
    result := '1|';
end;

//-----------------------------------------------------------------------------
function TListaImpNFiscal.fAbreGaveta( iHdl : Integer ): AnsiString;
var
  aImp: TImpNFiscal;
  sRet: AnsiString;
begin
  aImp := fAcha(iHdl);

  If Assigned(aImp) then
  begin
    sRet := aImp.AbreGaveta();
    Result := sRet;
  end
  else
    Result := '1|';

end;

//=============================================================================
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//=============================================================================
//----------------------------------------------------------------------------
function ImpNFiscListar( var aBuff:AnsiString ):Integer;
begin
  aBuff := _z_ListaDrivers.CommaText;
  result := 0;
end;

//-----------------------------------------------------------------------------
function ImpNFiscAbrir( sModelo,sPorta:PChar; iVelocidade : Integer; iHdlMain:Integer ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpNFisc.fCriaImp( StrPas(sModelo), StrPas(sPorta), iVelocidade, iHdlMain );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt( copy(s,1,iPos-1) );

end;

//----------------------------------------------------------------------------
function ImpNFiscFechar( iHdl:Integer;sPorta:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpNFisc.fApagaImp( iHdl, StrPas(sPorta) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt( copy(s,1,iPos-1) );
end;

//----------------------------------------------------------------------------
function ImpNFiscImpTexto( iHdl:Integer; Texto:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpNFisc.fImpTexto( iHdl, StrPas(Texto) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt( copy(s,1,iPos-1) );
end;

//----------------------------------------------------------------------------
function ImpNFiscBitmap( iHdl:Integer;Arquivo:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpNFisc.fImpBitMap( iHdl, StrPas(Arquivo) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt( copy(s,1,iPos-1) );
end;

//----------------------------------------------------------------------------
function ImpNFiscCodeBar( iHdl:Integer;Tipo,Texto:PChar ):Integer;
var
  s:AnsiString;
  iPos:Integer;
begin
  s := _z_ListaImpNFisc.fImpCodeBar( iHdl, StrPas(Tipo), StrPas(Texto) );
  iPos := Pos('|',s);
  if iPos = 0 then
    result := StrToInt( s )
  else
    result := StrToInt( copy(s,1,iPos-1) );
end;

//-----------------------------------------------------------------------------
function ImpNFiscAbrGvt( iHdl: Integer ): Integer;
var
  s: AnsiString;
  iPos: Integer;
begin
  s := _z_ListaImpNFisc.fAbreGaveta( iHdl );
  iPos := Pos('|',s);
  if iPos = 0
  then result := StrToInt( s )
  else result := StrToInt( copy(s,1,iPos-1) );
end;

//----------------------------------------------------------------------------
function ImpNFiscStatus( iHdl:Integer;Tipo: pChar; aBuff:AnsiString ):Integer;
var
  s:String;
  iPos:Integer;
begin
  s := _z_ListaImpNFisc.fStatus( iHdl, StrToInt(StrPas(Tipo)) );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    aBuff := ' ';
    result := StrToInt( s );
  end
  else
  begin
    aBuff := copy(s,iPos+1,Length(s));
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//-----------------------------------------------------------------------------
function TListaImpNFiscal.fStatus( iHdl,iTipo : Integer ): AnsiString;
var
  aImp: TImpNFiscal;
  sRet: AnsiString;
begin
  aImp := fAcha(iHdl);

  If Assigned(aImp) then
  begin
    sRet := aImp.StatusImp(iTipo);
    Result := sRet;
  end
  else
    Result := '1|';

end;

//----------------------------------------------------------------------------
initialization
  _z_ListaImpNFisc := TlistaImpNFiscal.Create;
  _z_ListaDrivers  := TListaDrivers.Create;

finalization
  _z_ListaImpNFisc.Free;
  _z_ListaDrivers.Free;

end.
