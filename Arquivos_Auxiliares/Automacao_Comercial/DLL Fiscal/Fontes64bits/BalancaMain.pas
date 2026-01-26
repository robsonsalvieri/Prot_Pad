unit BalancaMain;

interface

Uses Classes, SysUtils, Dialogs;

function Balanca_Listar( var aBuff:AnsiString ):Integer; StdCall;
function Balanca_PegaPeso( iHdl:Integer; var sPeso:AnsiString ):Integer; StdCall;
function Balanca_Abrir( sModelo, sPorta:string ):Integer; StdCall;
function Balanca_Fechar( iHdl:integer;sPorta:PChar ):Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
//
//  TBalanca - Classe
//
Type

  TBalanca = Class(TObject)
  private
    fModelo : String;
    fPorta  : String;

  public
    constructor Create( sModelo, sPorta: AnsiString); virtual;
    function Abrir( sPorta:Ansistring ):AnsiString; virtual; abstract;
    function Fechar( sPorta:AnsiString ):AnsiString; virtual; abstract;
    function PegaPeso():AnsiString; virtual; abstract;

    property Modelo : String  read fModelo;
    property Porta  : String  read fPorta;
  end;
  TBalancaClass = class of TBalanca;
  procedure RegistraBalanca( sModelo:String; cClasse:TBalancaClass; sPaises:String );
//
////////////////////////////////////////////////////////////////////////////////
implementation

////////////////////////////////////////////////////////////////////////////////
//
//   TListaBalanca
//
Type
  TListaBalanca = Class(TStringList)
  public
    function RegistraBalanca( sModelo:String; cClasse:TBalancaClass; sPaises:String ):Boolean;
    function CriaBalanca( sModelo,sPorta:String ):TBalanca;
    function Acha( iHdl:integer ):TBalanca;
  end;

var
  _z_ListaBalanca : TListaBalanca;
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
constructor TBalanca.Create( sModelo,sPorta:AnsiString );
begin
  fModelo := sModelo;
  fPorta  := sPorta;
end;
//----------------------------------------------------------------------------
procedure RegistraBalanca(sModelo: String; cClasse: TBalancaClass; sPaises:String);
begin
  if (not _z_ListaBalanca.RegistraBalanca( sModelo, cClasse, sPaises )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//   Funções da TListaBalanca
//
function TListaBalanca.RegistraBalanca( sModelo:String; cClasse:TBalancaClass; sPaises:String ):Boolean;
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

function TListaBalanca.CriaBalanca( sModelo,sPorta:String ) : TBalanca;
var
  iPos : integer;
  p : pointer;
begin
  iPos := IndexOf( sModelo );
  if iPos < 0 then
    result := nil
  else
  begin
    p :=  TBalancaClass( Objects[iPos] ).MethodAddress('TBalanca');
    If not Assigned(p) then
      result := TBalancaClass( Objects[iPos] ).Create( sModelo, sPorta )
    else
      result := nil;
  end;
end;

//----------------------------------------------------------------------------
function TListaBalanca.Acha( iHdl:integer ):TBalanca;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TBalanca(Objects[iHdl])
  else
    Result := nil;
end;

////////////////////////////////////////////////////////////////////////////////
//
//
function Balanca_Listar( var aBuff:AnsiString ):Integer;
begin
  aBuff := _z_ListaBalanca.CommaText;
  result := 0;
end;

//----------------------------------------------------------------------------
function Balanca_Abrir( sModelo, sPorta:string ):Integer;
var
  aBalanca : TBalanca;
  sRet    : String;
  sChave  : String;
begin
  sChave  := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);
  if _z_ListaBalanca.IndexOf(sChave) < 0 then
  begin
    aBalanca := _z_ListaBalanca.CriaBalanca( sModelo, sPorta );
    If Assigned(aBalanca) then
    begin
      sRet := aBalanca.Abrir( sPorta );
      if sRet = '0' then
        result := _z_ListaBalanca.AddObject(sChave,aBalanca)
      else
      begin
        aBalanca.Free;
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
function Balanca_PegaPeso( iHdl:Integer; var sPeso:AnsiString ): Integer;
var
  sRet: String;
  aBalanca : TBalanca;
  iPos : integer;
begin
  aBalanca := _z_ListaBalanca.Acha( iHdl );
  if Assigned( aBalanca ) then
  sRet   := aBalanca.PegaPeso( );

  iPos := Pos('|',sRet);
  sPeso := Copy(sRet,iPos+1,Length(sRet));
  result := StrToInt(copy(sRet,1,iPos-1));

  If Copy(sRet,1,1) <> '0'
  then Result := 1
  Else Result := 0;
end;

//----------------------------------------------------------------------------
function Balanca_Fechar( iHdl:integer;sPorta:PChar ):Integer;
var
  aBalanca : TBalanca;
begin
  aBalanca := _z_ListaBalanca.Acha( iHdl );
  if Assigned( aBalanca ) then
  begin
    aBalanca.Fechar( StrPas(sPorta) );
    _z_ListaBalanca.Objects[iHdl].Free;
    _z_ListaBalanca.Objects[iHdl] := nil;
    result := 0
  end
  else
    result := 1;

end;

//----------------------------------------------------------------------------
initialization
  _z_ListaBalanca := TListaBalanca.Create;


finalization
  _z_ListaBalanca.Free;


//----------------------------------------------------------------------------

end.
