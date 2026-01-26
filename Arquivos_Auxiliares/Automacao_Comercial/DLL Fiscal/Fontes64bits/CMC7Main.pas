unit CMC7Main;

interface

Uses Classes, SysUtils, Dialogs;

function CMC7_Listar( var aBuff:AnsiString ):Integer; StdCall;
function CMC7_Abrir( sModelo,sPorta,sMensagem:PChar ):Integer; StdCall;
function CMC7_Fechar( iHdl:integer ):Integer; StdCall;
function CMC7_LeDocumento( iHdl:integer;aBuff:AnsiString ):Integer; StdCall;
function CMC7_LeDocCompleto( iHdl:integer;aBuff:AnsiString ):Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
//
//  TCMC7 - Classe
//
Type

  TCMC7 = Class(TObject)
  private
    fModelo : AnsiString;
    fPorta  : AnsiString;
  public
    constructor Create( sModelo, sPorta : AnsiString); virtual;

    function Abrir( sPorta, sMensagem:AnsiString ):AnsiString; virtual; abstract;
    function LeDocumento : AnsiString; virtual; abstract;
    function LeDocCompleto : AnsiString; virtual; abstract;
    function Fechar : AnsiString; virtual; abstract;

    property Modelo : AnsiString read fModelo;
    property Porta  : AnsiString read fPorta;
  end;

  TCMC7Class = class of TCMC7;
//
////////////////////////////////////////////////////////////////////////////////

  procedure RegistraCMC7( sModelo:AnsiString; cClasse:TCMC7Class; sPaises:AnsiString );

implementation

Type
  /////////////////////////////////////////////////////////////////////////////
  //
  //  TListaDrivers  - Lista com os Drivers
  //
  TListaDrivers = Class(TStringList)
  public
    function RegistraCMC7( sModelo:AnsiString; cClasse:TCMC7Class; sPaises:AnsiString ):Boolean;
    function CriaCMC7( sModelo,sPorta:AnsiString ):TCMC7;
  end;
  //
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  //
  //  Lista com os CMC7´s
  //
  TListaCMC7 = class(TStringList)
  public
    destructor Destroy; override;

    function Acha( iHdl:integer ):TCMC7;
    function CriaCMC7( sModelo, sPorta, sMensagem: AnsiString ): Integer;
    function LeDocumento( iHdl:integer;aBuff:AnsiString ):Integer;
    function LeDocCompleto( iHdl:integer;aBuff:AnsiString ):Integer;
    function ApagaCMC7( iHdl: Integer ):Integer;
  end;
  //
  /////////////////////////////////////////////////////////////////////////////

var
  _z_ListaDrivers : TListaDrivers;
  _z_ListaCMC7    : TListaCMC7;

//----------------------------------------------------------------------------
constructor TCMC7.Create( sModelo,sPorta:AnsiString );
begin
  fModelo := sModelo;
  fPorta  := sPorta;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  TListaDrivers
//
function TListaDrivers.RegistraCMC7( sModelo:AnsiString; cClasse:TCMC7Class; sPaises:AnsiString ):Boolean;
begin

  if (IndexOf(sModelo) < 0) then
  begin
    AddObject( sModelo,TObject(cClasse) );
    AddObject( sPaises,TObject(cClasse) );
    result := True;
  end
  else
    result := False;
end;

//----------------------------------------------------------------------------

function TListaDrivers.CriaCMC7( sModelo,sPorta:AnsiString ) : TCMC7;
var
  iPos : integer;
begin
  iPos := IndexOf( sModelo );
  if iPos < 0 then
    result := nil
  else
    result := TCMC7Class( Objects[iPos] ).Create( sModelo, sPorta )
end;

//----------------------------------------------------------------------------
destructor TListaCMC7.Destroy;
var
  i : Integer;
begin
  for i := 0 to Count-1 do
    if (Objects[i] <> nil) Then
      Objects[i].Free;
  inherited;
end;

//----------------------------------------------------------------------------
function TListaCMC7.Acha( iHdl:integer ):TCMC7;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TCMC7(Objects[iHdl])
  else
    Result := nil;
end;

//----------------------------------------------------------------------------
function TListaCMC7.ApagaCMC7( iHdl:integer ):Integer;
var
  aCMC7 : TCMC7;
begin
  aCMC7 := Acha( iHdl );
  if Assigned( aCMC7 ) then
  begin
    aCMC7.Fechar;
    Objects[iHdl].Free;
    Objects[iHdl] := nil;
    _z_ListaCMC7.Delete(iHdl);
    result := 0
  end
  else
    result := 1;
end;

//----------------------------------------------------------------------------
function TListaCMC7.CriaCMC7( sModelo,sPorta,sMensagem:AnsiString ):Integer;
var
  aCMC7 : TCMC7;
  sRet : AnsiString;
  sChave : AnsiString;
begin
  sChave := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);

  if (IndexOf(sChave) < 0) then
  begin
    aCMC7 := _z_ListaDrivers.CriaCMC7( sModelo, sPorta );
    If Assigned(aCMC7) then
    begin
      sRet := aCMC7.Abrir( sPorta, sMensagem );
      if sRet = '0' then
        result := AddObject(sChave,aCMC7)
      else
      begin
        aCMC7.Free;
        result := -1;
      end;
    end
    else
      result := -1;
  end
  else
    result := -1;

end;

//----------------------------------------------------------------------------
function TListaCMC7.LeDocumento( iHdl:integer;aBuff:AnsiString ):Integer;
var
  aCMC7 : TCMC7;
  sRet : AnsiString;
  iPos : Integer;
begin
  aCMC7 := Acha( iHdl );
  if Assigned( aCMC7 ) then
  begin
    sRet := aCMC7.LeDocumento;
    iPos := Pos('|',sRet);
    if iPos = 0 then
      result := StrToInt(sRet)
    else
    begin
      result := StrToInt(copy(sRet,1,iPos-1));
      if StrToInt(copy(sRet,1,iPos-1)) = 0 then
         aBuff := copy(sRet,iPos+1,Length(sRet))
      else
         aBuff := ''
    end;
  end
  else
    result := 1;
end;

//----------------------------------------------------------------------------
function TListaCMC7.LeDocCompleto( iHdl:integer;aBuff:AnsiString ):Integer;
var
  aCMC7 : TCMC7;
  sRet : AnsiString;
  iPos : Integer;
begin
  aCMC7 := Acha( iHdl );
  if Assigned( aCMC7 ) then
  begin
    sRet := aCMC7.LeDocCompleto;
    iPos := Pos('|',sRet);
    if iPos = 0 then
      result := StrToInt(sRet)
    else
    begin
      result := StrToInt(copy(sRet,1,iPos-1));
      if StrToInt(copy(sRet,1,iPos-1)) = 0 then
         aBuff := copy(sRet,iPos+1,Length(sRet))
      else
         aBuff := ''
    end;
  end
  else
    result := 1;
end;

//----------------------------------------------------------------------------
procedure RegistraCMC7(sModelo: AnsiString; cClasse: TCMC7Class; sPaises:AnsiString);
begin
  if (not _z_ListaDrivers.RegistraCMC7( sModelo, cClasse, sPaises )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;

//----------------------------------------------------------------------------
function CMC7_Abrir( sModelo,sPorta,sMensagem:PChar ):Integer;
begin
  Result := _z_ListaCMC7.CriaCMC7( StrPas(sModelo),StrPas(sPorta), StrPas(sMensagem) );
end;

//----------------------------------------------------------------------------
function CMC7_LeDocumento( iHdl:integer;aBuff:AnsiString ):Integer;
begin
  Result := _z_ListaCMC7.LeDocumento( iHdl, aBuff );
end;

//----------------------------------------------------------------------------
function CMC7_LeDocCompleto( iHdl:integer;aBuff:AnsiString ):Integer;
begin
  Result := _z_ListaCMC7.LeDocCompleto( iHdl, aBuff );
end;

//----------------------------------------------------------------------------
function CMC7_Fechar( iHdl:integer ):Integer;
begin
  Result := _z_ListaCMC7.ApagaCMC7( iHdl );
end;

//----------------------------------------------------------------------------
function CMC7_Listar( var aBuff:AnsiString ):Integer;
begin
  aBuff := _z_ListaDrivers.CommaText;
  Result := 0;
end;

//----------------------------------------------------------------------------
initialization
  _z_ListaCMC7 := TListaCMC7.Create;
  _z_ListaDrivers := TListaDrivers.Create;

finalization
  _z_ListaCMC7.Free;
  _z_ListaDrivers.Free;

//----------------------------------------------------------------------------
end.
