unit DisplayMain;

interface

Uses Classes, SysUtils, Dialogs;

function Display_Listar( var aBuff:AnsiString ):Integer; StdCall;
function Display_Abrir( sModelo,sPorta:PChar ):Integer; StdCall;
function Display_Fechar( iHdl:integer;sPorta:PChar ):Integer; StdCall;
function Display_Escrever( iHdl:integer; aBuff:pChar ):Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
//
//  TDisplay - Classe
//
Type

  TDisplay = Class(TObject)
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
  TDisplayClass = class of TDisplay;
  procedure RegistraDisplay( sModelo:String; cClasse:TDisplayClass; sPaises:String );
//
////////////////////////////////////////////////////////////////////////////////
implementation

////////////////////////////////////////////////////////////////////////////////
//
//   TListaDisplays
//
Type
  TListaDisplay = Class(TStringList)
  public
    function RegistraDisplay( sModelo:String; cClasse:TDisplayClass; sPaises:String ):Boolean;
    function CriaDisplay( sModelo,sPorta:String ):TDisplay;
    function Acha( iHdl:integer ):TDisplay;
  end;

var
  _z_ListaDisplay : TListaDisplay;
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
constructor TDisplay.Create( sModelo,sPorta:String );
begin
  fModelo := sModelo;
  fPorta := sPorta;
end;
//----------------------------------------------------------------------------
procedure RegistraDisplay(sModelo: String; cClasse: TDisplayClass; sPaises:String);
begin
  if (not _z_ListaDisplay.RegistraDisplay( sModelo, cClasse, sPaises )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//   Funções da TListaCMC7
//
function TListaDisplay.RegistraDisplay( sModelo:String; cClasse:TDisplayClass; sPaises:String ):Boolean;
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
function TListaDisplay.CriaDisplay( sModelo,sPorta:String ) : TDisplay;
var
  iPos : integer;
  p : pointer;
begin
  iPos := IndexOf( sModelo );
  if iPos < 0 then
    result := nil
  else
  begin
    p :=  TDisplayClass( Objects[iPos] ).MethodAddress('TDisplay');
    If not Assigned(p) then
      result := TDisplayClass( Objects[iPos] ).Create( sModelo, sPorta )
    else
      result := nil;
  end;
end;

//----------------------------------------------------------------------------
function TListaDisplay.Acha( iHdl:integer ):TDisplay;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TDisplay(Objects[iHdl])
  else
    Result := nil;
end;

////////////////////////////////////////////////////////////////////////////////
//
//
function Display_Listar( var aBuff:AnsiString ):Integer;
begin
  aBuff := _z_ListaDisplay.CommaText;
  result := 0;
end;

//----------------------------------------------------------------------------
function Display_Abrir( sModelo,sPorta:PChar ):Integer;
var
  aDisplay : TDisplay;
  sRet : String;
  sChave : String;
begin
  sChave := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);
  if _z_ListaDisplay.IndexOf(sChave) < 0 then
  begin
    aDisplay := _z_ListaDisplay.CriaDisplay( StrPas(sModelo),StrPas(sPorta) );
    If Assigned(aDisplay) then
    begin
      sRet := aDisplay.Abrir( sPorta );
      if sRet = '0' then
        result := _z_ListaDisplay.AddObject(sChave,aDisplay)
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
function Display_Fechar( iHdl:integer;sPorta:PChar ):Integer;
var
  aDisplay : TDisplay;
  sRet : String;
begin
  aDisplay := _z_ListaDisplay.Acha( iHdl );
  if Assigned( aDisplay ) then
  begin
    sRet := aDisplay.Fechar( StrPas(sPorta) );
    _z_ListaDisplay.Objects[iHdl].Free;
    _z_ListaDisplay.Objects[iHdl] := nil;
    result := 0
  end
  else
    result := 1;

end;

//----------------------------------------------------------------------------
function Display_Escrever( iHdl:integer; aBuff:pChar ):Integer;
var
  aDisplay : TDisplay;
  sRet : String;
  iPos : Integer;
begin
  aDisplay := _z_ListaDisplay.Acha( iHdl );
  if Assigned( aDisplay ) then
  begin
    sRet := aDisplay.Escrever( aBuff );
    iPos := Pos('|',sRet);
    if iPos = 0 then
      result := StrToInt(sRet)
    else
    begin
      result := StrToInt(copy(sRet,1,iPos-1));
      StrPCopy( aBuff , copy(sRet,iPos+1,Length(sRet)) );
    end;
  end
  else
    result := 1;
end;

//----------------------------------------------------------------------------
initialization
  _z_ListaDisplay := TListaDisplay.Create;


finalization
  _z_ListaDisplay.Free;


//----------------------------------------------------------------------------
end.
