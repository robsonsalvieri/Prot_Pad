unit DisplayTorMain;

interface

Uses Classes, SysUtils, Dialogs;

function DispTor_Listar( aBuff:PChar ):Integer; StdCall;
function DispTor_Abrir( sModelo,sPorta:PChar ):Integer; StdCall;
function DispTor_Fechar( iHdl:integer;sPorta:PChar ):Integer; StdCall;
function DispTor_Escrever( iHdl:integer;aBuff:PChar ):Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
//
//  TDisplay - Classe
//
Type

  TDispTor = Class(TObject)
  private
    fModelo : String;
    fPorta : String;
  public
    constructor Create( sModelo, sPorta : String); virtual;
    function Abrir( sPorta:String ):String; virtual; abstract;
    function Fechar( sPorta:String ):String; virtual; abstract;
    function Escrever( Texto:String ): String; virtual; abstract;

    property Modelo : String read fModelo;
    property Porta : String read fPorta;
  end;
  TDispTorClass = class of TDispTor;
  procedure RegistraDispTor( sModelo:String; cClasse:TDispTorClass; sPaises:String );
//
////////////////////////////////////////////////////////////////////////////////
implementation

////////////////////////////////////////////////////////////////////////////////
//
//   TListaDisplays
//
Type
  TListaDispTor = Class(TStringList)
  public
    function RegistraDispTor( sModelo:String; cClasse:TDispTorClass; sPaises:String ):Boolean;
    function CriaDispTor( sModelo,sPorta:String ):TDispTor;
    function Acha( iHdl:integer ):TDispTor;
  end;

var
  _z_ListaDispTor : TListaDispTor;
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
constructor TDispTor.Create( sModelo,sPorta:String );
begin
  fModelo := sModelo;
  fPorta := sPorta;
end;
//----------------------------------------------------------------------------
procedure RegistraDispTor(sModelo: String; cClasse: TDispTorClass; sPaises:String);
begin
  if (not _z_ListaDispTor.RegistraDispTor( sModelo, cClasse, sPaises )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//   Funções da TListaCMC7
//
function TListaDispTor.RegistraDispTor( sModelo:String; cClasse:TDispTorClass; sPaises:String ):Boolean;
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
function TListaDispTor.CriaDispTor( sModelo,sPorta:String ) : TDispTor;
var
  iPos : integer;
  p : pointer;
begin
  iPos := IndexOf( sModelo );
  if iPos < 0 then
    result := nil
  else
  begin
    p :=  TDispTorClass( Objects[iPos] ).MethodAddress('TDispTor');
    If not Assigned(p) then
      result := TDispTorClass( Objects[iPos] ).Create( sModelo, sPorta )
    else
      result := nil;
  end;
end;

//----------------------------------------------------------------------------
function TListaDispTor.Acha( iHdl:integer ):TDispTor;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TDispTor(Objects[iHdl])
  else
    Result := nil;
end;

////////////////////////////////////////////////////////////////////////////////
//
//
function DispTor_Listar( aBuff:PChar ):Integer;
begin
  StrPCopy( aBuff,_z_ListaDispTor.CommaText );
  result := 0;
end;

//----------------------------------------------------------------------------
function DispTor_Abrir( sModelo,sPorta:PChar ):Integer;
var
  aDisplay : TDispTor;
  sRet : String;
  sChave : String;
begin
  sChave := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);
  if _z_ListaDispTor.IndexOf(sChave) < 0 then
  begin
    aDisplay := _z_ListaDispTor.CriaDispTor( StrPas(sModelo),StrPas(sPorta) );
    If Assigned(aDisplay) then
    begin
      sRet := aDisplay.Abrir( sPorta );
      if sRet = '0' then
        result := _z_ListaDispTor.AddObject(sChave,aDisplay)
      else
      begin
        aDisplay.Free;
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
function DispTor_Fechar( iHdl:integer;sPorta:PChar ):Integer;
var
  aDisplay : TDispTor;
  sRet : String;
begin
  aDisplay := _z_ListaDispTor.Acha( iHdl );
  if Assigned( aDisplay ) then
  begin
    sRet := aDisplay.Fechar( StrPas(sPorta) );
    _z_ListaDispTor.Objects[iHdl].Free;
    _z_ListaDispTor.Objects[iHdl] := nil;
    result := 0
  end
  else
    result := 1;

end;

//----------------------------------------------------------------------------
function DispTor_Escrever( iHdl:integer;aBuff:PChar ):Integer;
var
  aDisplay : TDispTor;
  sRet : String;
  iPos : Integer;
begin
  aDisplay := _z_ListaDispTor.Acha( iHdl );
  if Assigned( aDisplay ) then
  begin
    sRet := aDisplay.Escrever( StrPas(aBuff) );
    iPos := Pos('|',sRet);
    if iPos = 0 then
      result := StrToInt(sRet)
    else
    begin
      result := StrToInt(copy(sRet,1,iPos-1));
      StrpCopy(aBuff,copy(sRet,iPos+1,Length(sRet)));
    end;
  end
  else
    result := 1;
end;
//------------------------------------------------------------------------------
initialization
  _z_ListaDispTor := TListaDispTor.Create;


finalization
  _z_ListaDispTor.Free;


//----------------------------------------------------------------------------
end.
