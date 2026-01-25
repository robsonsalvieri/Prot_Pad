unit GavetaMain;

interface

Uses Classes, SysUtils, Dialogs;

function Gaveta_Listar( aBuff:PChar ):Integer; StdCall;
function Gaveta_Abrir( sModelo,sPorta:PChar ):Integer; StdCall;
function Gaveta_Fechar( iHdl:integer;sPorta:PChar ):Integer; StdCall;
function Gaveta_Acionar( iHdl:integer;pPorta:PChar ):Integer; StdCall;
function Gaveta_Status( iHdl:integer;pPorta:PChar ):Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
//
//  TGaveta - Classe
//
Type

  TGaveta = Class(TObject)
  private
    fModelo : String;
    fPorta : String;
  public
    constructor Create( sModelo, sPorta : String); virtual;
    function Abrir( sPorta:String ):String; virtual; abstract;
    function Fechar( sPorta:String ):String; virtual; abstract;
    function Acionar( sPorta:String ):String; virtual; abstract;
    function Status( sPorta:String ): String; virtual; abstract;

    property Modelo : String read fModelo;
    property Porta : String read fPorta;
  end;
  TGavetaClass = class of TGaveta;
  procedure RegistraGaveta( sModelo:String; cClasse:TGavetaClass; sPaises:String );
//
////////////////////////////////////////////////////////////////////////////////
implementation

////////////////////////////////////////////////////////////////////////////////
//
//   TListaGaveta
//
Type
  TListaGaveta = Class(TStringList)
  public
    function RegistraGaveta( sModelo:String; cClasse:TGavetaClass; sPaises:String ):Boolean;
    function CriaGaveta( sModelo,sPorta:String ):TGaveta;
    function Acha( iHdl:integer ):TGaveta;
  end;

var
  _z_ListaGaveta : TListaGaveta;
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
constructor TGaveta.Create( sModelo,sPorta:String );
begin
  fModelo := sModelo;
  fPorta := sPorta;
end;
//----------------------------------------------------------------------------
procedure RegistraGaveta(sModelo: String; cClasse: TGavetaClass; sPaises:String);
begin
  if (not _z_ListaGaveta.RegistraGaveta( sModelo, cClasse, sPaises )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//   Funções da TListaGaveta
//
function TListaGaveta.RegistraGaveta( sModelo:String; cClasse:TGavetaClass; sPaises:String ):Boolean;
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

function TListaGaveta.CriaGaveta( sModelo,sPorta:String ) : TGaveta;
var
  iPos : integer;
  p : pointer;
begin
  iPos := IndexOf( sModelo );
  if iPos < 0 then
    result := nil
  else
  begin
    p :=  TGavetaClass( Objects[iPos] ).MethodAddress('TGaveta');
    If not Assigned(p) then
      result := TGavetaClass( Objects[iPos] ).Create( sModelo, sPorta )
    else
      result := nil;
  end;
end;

//----------------------------------------------------------------------------
function TListaGaveta.Acha( iHdl:integer ):TGaveta;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TGaveta(Objects[iHdl])
  else
    Result := nil;
end;

////////////////////////////////////////////////////////////////////////////////
//
//
function Gaveta_Listar( aBuff:PChar ):Integer;
begin
  StrPCopy( aBuff,_z_ListaGaveta.CommaText );
  result := 0;
end;

//----------------------------------------------------------------------------
function Gaveta_Abrir( sModelo,sPorta:PChar ):Integer;
var
  aGaveta : TGaveta;
  sRet : String;
  sChave : String;
begin
  sChave := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);
  if _z_ListaGaveta.IndexOf(sChave) < 0 then
  begin
    aGaveta := _z_ListaGaveta.CriaGaveta( StrPas(sModelo),StrPas(sPorta) );
    If Assigned(aGaveta) then
    begin
      sRet := aGaveta.Abrir( sPorta );
      if sRet = '0' then
        result := _z_ListaGaveta.AddObject(sChave,aGaveta)
      else
      begin
        aGaveta.Free;
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
function Gaveta_Fechar( iHdl:integer;sPorta:PChar ):Integer;
var
  aGaveta : TGaveta;
begin
  aGaveta := _z_ListaGaveta.Acha( iHdl );
  if Assigned( aGaveta ) then
  begin
    aGaveta.Fechar( StrPas(sPorta) );
    _z_ListaGaveta.Objects[iHdl].Free;
    _z_ListaGaveta.Objects[iHdl] := nil;
    result := 0
  end
  else
    result := 1;

end;

//----------------------------------------------------------------------------
function Gaveta_Acionar( iHdl:integer;pPorta:PChar ):Integer; StdCall;
var
  aGaveta : TGaveta;
  sRet : String;
  iPos : Integer;
begin
  aGaveta := _z_ListaGaveta.Acha( iHdl );
  if Assigned( aGaveta ) then
  begin
    sRet := aGaveta.Acionar( StrPas(pPorta) );
    iPos := Pos('|',sRet);
    if iPos = 0 then
      result := StrToInt(sRet)
    else
      result := StrToInt(copy(sRet,1,iPos-1));
  end
  else
    result := 1;
end;

//----------------------------------------------------------------------------
function Gaveta_Status( iHdl:integer;pPorta:PChar ):Integer; StdCall;
var
  aGaveta : TGaveta;
  sRet : String;
  iPos : Integer;
begin
  aGaveta := _z_ListaGaveta.Acha( iHdl );
  if Assigned( aGaveta ) then
  begin
    sRet := aGaveta.Status( StrPas(pPorta) );
    iPos := Pos('|',sRet);
    if iPos = 0 then
      result := StrToInt(sRet)
    else
      result := StrToInt(copy(sRet,1,iPos-1));
  end
  else
    result := 1;
end;

//----------------------------------------------------------------------------

initialization
  _z_ListaGaveta := TListaGaveta.Create;

finalization
  _z_ListaGaveta.Free;

//----------------------------------------------------------------------------
end.
