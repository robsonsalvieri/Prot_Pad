unit ImpCupomMain;

interface

Uses Classes, SysUtils, Dialogs;

function Imp_Listar( aBuff:PChar ):Integer; StdCall;
function Imp_Abrir( sModelo,sPorta:PChar ):Integer; StdCall;
function Imp_Fechar( iHdl:integer;sPorta:PChar ):Integer; StdCall;
function Imp_Imprimir( iHdl:integer;aBuff:PChar ):Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
//
//  TImpressora - Classe
//
Type

  TImpressora = Class(TObject)
  private                      
    fModelo : String;
    fPorta : String;
  public
    constructor Create( sModelo, sPorta : String); virtual;
    function Abrir( sPorta:String ):String; virtual; abstract;
    function Fechar( sPorta:String ):String; virtual; abstract;
    function Imprimir( Texto:String ): String; virtual; abstract;

    property Modelo : String read fModelo;
    property Porta : String read fPorta;
  end;
  TImpressoraClass = class of TImpressora;
  procedure RegistraImp( sModelo:String; cClasse:TImpressoraClass; sPaises:String );
//
////////////////////////////////////////////////////////////////////////////////
implementation

////////////////////////////////////////////////////////////////////////////////
//
//   TListaImpressora
//
Type
  TListaImpressora = Class(TStringList)
  public
    function RegistraImp( sModelo:String; cClasse:TImpressoraClass; sPaises:String ):Boolean;
    function CriaImpressora( sModelo,sPorta:String ):TImpressora;
    function Acha( iHdl:integer ):TImpressora;
  end;

var
  _z_ListaImpressora : TListaImpressora;
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
constructor TImpressora.Create( sModelo,sPorta:String );
begin
  fModelo := sModelo;
  fPorta := sPorta;
end;
//----------------------------------------------------------------------------
procedure RegistraImp(sModelo: String; cClasse: TImpressoraClass; sPaises:String);
begin
  if (not _z_ListaImpressora.RegistraImp( sModelo, cClasse, sPaises )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//   Funções da TListaCMC7
//
function TListaImpressora.RegistraImp( sModelo:String; cClasse:TImpressoraClass; sPaises:String ):Boolean;
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

function TListaImpressora.CriaImpressora( sModelo,sPorta:String ) : TImpressora;
var
  iPos : integer;
  p : pointer;
begin
  iPos := IndexOf( sModelo );
  if iPos < 0 then
    result := nil
  else
  begin
    p :=  TImpressoraClass( Objects[iPos] ).MethodAddress('TImpressora');
    If not Assigned(p) then
      result := TImpressoraClass( Objects[iPos] ).Create( sModelo, sPorta )
    else
      result := nil;
  end;
end;

//----------------------------------------------------------------------------
function TListaImpressora.Acha( iHdl:integer ):TImpressora;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TImpressora(Objects[iHdl])
  else
    Result := nil;
end;

////////////////////////////////////////////////////////////////////////////////
//
//
function Imp_Listar( aBuff:PChar ):Integer;
begin
  StrPCopy( aBuff,_z_ListaImpressora.CommaText );
  result := 0;
end;

//----------------------------------------------------------------------------
function Imp_Abrir( sModelo,sPorta:PChar ):Integer;
var
  aImpressora : TImpressora;
  sRet : String;
  sChave : String;
begin
  sChave := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);
  if _z_ListaImpressora.IndexOf(sChave) < 0 then
  begin
    aImpressora := _z_ListaImpressora.CriaImpressora( StrPas(sModelo),StrPas(sPorta) );
    If Assigned(aImpressora) then
    begin
      sRet := aImpressora.Abrir( sPorta );
      if sRet = '0' then
        result := _z_ListaImpressora.AddObject(sChave,aImpressora)
      else
      begin
        aImpressora.Free;
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
function Imp_Fechar( iHdl:integer;sPorta:PChar ):Integer;
var
  aImpressora : TImpressora;
  sRet : String;
begin
  aImpressora := _z_ListaImpressora.Acha( iHdl );
  if Assigned( aImpressora ) then
  begin
    sRet := aImpressora.Fechar( StrPas(sPorta) );
    _z_ListaImpressora.Objects[iHdl].Free;
    _z_ListaImpressora.Objects[iHdl] := nil;
    result := 0
  end
  else
    result := 1;

end;

//----------------------------------------------------------------------------
function Imp_Imprimir( iHdl:integer;aBuff:PChar ):Integer;
var
  aImpressora : TImpressora;
  sRet : String;
  iPos : Integer;
begin
  aImpressora := _z_ListaImpressora.Acha( iHdl );
  if Assigned( aImpressora ) then
  begin
    sRet := aImpressora.Imprimir( StrPas(aBuff) );
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

//----------------------------------------------------------------------------
initialization
  _z_ListaImpressora := TListaImpressora.Create;


finalization
  _z_ListaImpressora.Free;


//----------------------------------------------------------------------------
end.
