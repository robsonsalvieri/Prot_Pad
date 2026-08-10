unit PinPadMain;

interface

Uses Classes, SysUtils, Dialogs;

function PinPad_Listar( aBuff:PChar ):Integer; StdCall;
function PinPad_Abrir( sModelo,sPorta:PChar ):Integer; StdCall;
function PinPad_LeCartao( iHdl:Integer;sModalidade:String;aBuff:PChar ):Integer; StdCall;
function PinPad_LeSenha( iHdl:Integer;pTrilha2,pMsg,pWork,pStatus:PChar ):Integer; StdCall;
function PinPad_Finaliza( iHdl:Integer ):Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
//
//  TPinPad - Classe
//
Type

  TPinPad = Class(TObject)
  private
    fModelo : String;
    fPorta : String;
  public
    constructor Create( sModelo, sPorta : String); virtual;
    function Abrir( sPorta:String ):String; virtual; abstract;
    function Fechar:String; virtual; abstract;
    function LeCartao(sModalidade:String):String; virtual; abstract;
    function LeSenha( sTrilha2,sMsg,sWork:String ):String; virtual; abstract;

    property Modelo : String read fModelo;
    property Porta : String read fPorta;
  end;
  TPinPadClass = class of TPinPad;
  procedure RegistraPinPad( sModelo:String; cClasse:TPinPadClass; sPaises:String );
//
////////////////////////////////////////////////////////////////////////////////
implementation

////////////////////////////////////////////////////////////////////////////////
//
//   TListaPinPad
//
Type
  TListaPinPad = Class(TStringList)
  public
    function RegistraPinPad( sModelo:String; cClasse:TPinPadClass; sPaises:String ):Boolean;
    function CriaPinPad( sModelo,sPorta:String ):TPinPad;
    function Acha( iHdl:integer ):TPinPad;
  end;

var
  _z_ListaPinPad : TListaPinPad;
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
constructor TPinPad.Create( sModelo,sPorta:String );
begin
  fModelo := sModelo;
  fPorta := sPorta;
end;
//----------------------------------------------------------------------------
procedure RegistraPinPad(sModelo: String; cClasse: TPinPadClass; sPaises:String);
begin
  if (not _z_ListaPinPad.RegistraPinPad( sModelo, cClasse, sPaises )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[sModelo] );
end;
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//   Funções da TListaPinPad
//
function TListaPinPad.RegistraPinPad( sModelo:String; cClasse:TPinPadClass; sPaises:String ):Boolean;
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

function TListaPinPad.CriaPinPad( sModelo,sPorta:String ) : TPinPad;
var
  iPos : integer;
  p : pointer;
begin
  iPos := IndexOf( sModelo );
  if iPos < 0 then
    result := nil
  else
  begin
    p :=  TPinPadClass( Objects[iPos] ).MethodAddress('TPinPad');
    If not Assigned(p) then
      result := TPinPadClass( Objects[iPos] ).Create( sModelo, sPorta )
    else
      result := nil;
  end;
end;

//----------------------------------------------------------------------------
function TListaPinPad.Acha( iHdl:integer ):TPinPad;
begin
  if (iHdl >= 0) and (iHdl < Count) Then
    Result := TPinPad(Objects[iHdl])
  else
    Result := nil;
end;

////////////////////////////////////////////////////////////////////////////////
//
//
function PinPad_Listar( aBuff:PChar ):Integer;
begin
  StrPCopy( aBuff,_z_ListaPinPad.CommaText );
  result := 0;
end;

//----------------------------------------------------------------------------
function PinPad_Abrir( sModelo,sPorta:PChar ):Integer;
var
  aPinPad : TPinPad;
  sRet : String;
  sChave : String;
begin
  sChave := Format('{{{%s}}}{{{%s}}}',[sModelo,sPorta]);
  if _z_ListaPinPad.IndexOf(sChave) < 0 then
  begin
    aPinPad := _z_ListaPinPad.CriaPinPad( StrPas(sModelo),StrPas(sPorta) );
    If Assigned(aPinPad) then
    begin
      sRet := aPinPad.Abrir( sPorta );
      if sRet = '0' then
        result := _z_ListaPinPad.AddObject(sChave,aPinPad)
      else
      begin
        aPinPad.Free;
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
function PinPad_Finaliza( iHdl:Integer ):Integer;
var
  aPinPad : TPinPad;
begin
  aPinPad := _z_ListaPinPad.Acha( iHdl );
  if Assigned( aPinPad ) then
  begin
    aPinPad.Fechar;
    _z_ListaPinPad.Objects[iHdl].Free;
    _z_ListaPinPad.Objects[iHdl] := nil;
    _z_ListaPinPad.Delete(iHdl);
    result := 0
  end
  else
    result := 1;

end;

//----------------------------------------------------------------------------
function PinPad_LeCartao( iHdl:Integer;sModalidade:String;aBuff:PChar ):Integer; StdCall;
var
  aPinPad : TPinPad;
  iPos : Integer;
  sRet : String;
begin
  aPinPad := _z_ListaPinPad.Acha( iHdl );
  if Assigned( aPinPad ) then
  begin
    sRet := aPinPad.LeCartao(sModalidade);  
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
function PinPad_LeSenha( iHdl:Integer;pTrilha2,pMsg,pWork,pStatus:PChar ):Integer; StdCall;
var
  aPinPad : TPinPad;
  iPos : Integer;
  sRet : String;
begin
  aPinPad := _z_ListaPinPad.Acha( iHdl );
  if Assigned( aPinPad ) then
  begin
    sRet := aPinPad.LeSenha( StrPas(pTrilha2),StrPas(pMsg),StrPas(pWork) );
    iPos := Pos('|',sRet);
    if iPos = 0 then
      result := StrToInt(sRet)
    else
    begin
      result := StrToInt(copy(sRet,1,iPos-1));
      StrpCopy(pStatus,copy(sRet,iPos+1,Length(sRet)));
    end;
  end
  else
    result := 1;
end;

//----------------------------------------------------------------------------
initialization
  _z_ListaPinPad := TListaPinPad.Create;


finalization
  _z_ListaPinPad.Free;


//----------------------------------------------------------------------------
end.
