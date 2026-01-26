unit LeitorMain;

interface

Uses Classes, SysUtils, Dialogs;

function Leitor_Listar( aBuff : PChar ) : Integer; StdCall;
function Leitor_Abrir( sModelo, sPorta, sFoco : PChar ) : Integer; StdCall;
function Leitor_Fechar( iHdl : Integer; sPorta : PChar ) : Integer; StdCall;
function Leitor_Foco( iHdl : Integer; Modo : Integer ) : Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
//
//  TLeitor - Classe
//
Type
  TLeitor = Class( TObject )
  private
    fModelo : String;
    fPorta  : String;

  public
    constructor Create( sModelo, sPorta : String ); virtual;

    function Abrir( sPorta, sFoco : String ) : String; virtual; abstract;
    function Fechar( sPorta : String ) : String; virtual; abstract;
    function LeitorFoco( Modo : Integer ) : String; virtual; abstract;

    property Modelo : String  read fModelo;
    property Porta  : String  read fPorta;
  end;

  TLeitorClass = class of TLeitor;

  procedure RegistraLeitor( sModelo : String; cClasse : TLeitorClass; sPaises : String );
//
////////////////////////////////////////////////////////////////////////////////

implementation

////////////////////////////////////////////////////////////////////////////////
//
//   TListaLeitor
//
Type
  TListaLeitor = Class( TStringList )
  public
    function RegistraLeitor( sModelo : String; cClasse : TLeitorClass; sPaises : String ) : Boolean;
    function CriaLeitor( sModelo, sPorta : String ) : TLeitor;
    function Acha( iHdl : integer ) : TLeitor;
  end;

var
  _z_ListaLeitor : TListaLeitor;
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
constructor TLeitor.Create( sModelo, sPorta : String );
begin
  fModelo := sModelo;
  fPorta  := sPorta;
end;

//----------------------------------------------------------------------------
procedure RegistraLeitor( sModelo: String; cClasse : TLeitorClass; sPaises : String );
begin
  if not _z_ListaLeitor.RegistraLeitor( sModelo, cClasse, sPaises ) Then
    raise Exception.CreateFmt( 'Erro na criação do driver "%s"', [sModelo] );
end;
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//   Funções da TListaLeitor
//
function TListaLeitor.RegistraLeitor( sModelo : String; cClasse : TLeitorClass; sPaises : String ) : Boolean;
begin
  if IndexOf( sModelo ) < 0 then
  begin
    AddObject( sModelo, TObject( cClasse ) );
    AddObject( sPaises, TObject( cClasse ) );
    Result := True;
  end
  else
    Result := False;
end;

//----------------------------------------------------------------------------
function TListaLeitor.CriaLeitor( sModelo, sPorta : String ) : TLeitor;
var
  iPos  : Integer;
  p     : Pointer;
begin
  iPos := IndexOf( sModelo );

  if iPos < 0 then
    Result := nil
  else
  begin
    p := TLeitorClass( Objects[iPos] ).MethodAddress( 'TLeitor' );

    if not Assigned( p ) then
      Result := TLeitorClass( Objects[iPos] ).Create( sModelo, sPorta )
    else
      Result := nil;
  end;
end;

//----------------------------------------------------------------------------
function TListaLeitor.Acha( iHdl : Integer ) : TLeitor;
begin
  if ( iHdl >= 0 ) and ( iHdl < Count ) Then
    Result := TLeitor( Objects[iHdl] )
  else
    Result := nil;
end;
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   Funções Principais
//   
function Leitor_Listar( aBuff : PChar ) : Integer;
begin
  StrPCopy( aBuff, _z_ListaLeitor.CommaText );
  Result := 0;
end;

//----------------------------------------------------------------------------
function Leitor_Abrir( sModelo, sPorta, sFoco : PChar ) : Integer;
var
  aLeitor : TLeitor;
  sRet    : String;
  sChave  : String;
begin
  sChave := Format( '{{{%s}}}{{{%s}}}', [sModelo, sPorta] );

  if _z_ListaLeitor.IndexOf( sChave ) < 0 then
  begin
    aLeitor := _z_ListaLeitor.CriaLeitor( StrPas( sModelo ), StrPas( sPorta ) );

    if Assigned( aLeitor ) then
    begin
      sRet := aLeitor.Abrir( StrPas( sPorta ), StrPas( sFoco ) );

      if sRet = '0' then
        Result := _z_ListaLeitor.AddObject( sChave, aLeitor )
      else
      begin
        aLeitor.Free;
        Result := -1;
      end;
    end
    else
      Result := -1;
  end
  else
    Result := -1;
end;

//----------------------------------------------------------------------------
function Leitor_Fechar( iHdl : integer; sPorta : PChar ) : Integer;
var
  aLeitor : TLeitor;
begin
  aLeitor := _z_ListaLeitor.Acha( iHdl );

  if Assigned( aLeitor ) then
  begin
    aLeitor.Fechar( StrPas( sPorta ) );

    ////////////////////////////////////////////////////////////////////////////
    //                       *** Problema encontrado: ***                     //
    // A classe _z_ListaLeitor do tipo TStringList é criada e inicializada    //
    // quando o fonte LeitorMain é acessado pela primeira vez. Com isso esta  //
    // classe só é criada na seção implementation, ou seja, não será mais     //
    // criada nem inicializada. Logo, se for chamado a função Free (destruir  //
    // o objeto e seus filhos) a classe _z_ListaLeitor não estará mais        //
    // disponível, até que a aplicação seja encerrada. Por isso quando é      //
    // chamado novamente a função Leitor_Abrir e tenta-se encontrar o         //
    // equipamento e a porta de comunicação no objeto, um erro é apresentado, //
    // pois já foi destruído.                                                 //
    //                                                                        //
    // _z_ListaLeitor.Objects[iHdl].Free;                                     //
    // _z_ListaLeitor.Objects[iHdl] := nil;                                   //
    //                                                                        //
    //                             *** Solução: ***                           //
    // Deletar o objeto que está dentro da classe _z_ListaLeitor e não        //
    // destruí-lo. Assim a classe estará sempre disponível, criada e          //
    // inicializada.                                                          //
    //                                                                        //
    // _z_ListaLeitor.Delete( iHdl );                                         //
    ////////////////////////////////////////////////////////////////////////////

    _z_ListaLeitor.Delete( iHdl );

    Result := 0
  end
  else
    Result := 1;
end;

//----------------------------------------------------------------------------
function Leitor_Foco( iHdl : integer; Modo : Integer ) : Integer;
var
  aLeitor : TLeitor;
begin
  aLeitor := _z_ListaLeitor.Acha( iHdl );

  if Assigned( aLeitor ) then
  begin
    aLeitor.LeitorFoco( Modo );
    Result := 0;
  end
  else
    Result := 1;
end;
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
initialization
  _z_ListaLeitor := TListaLeitor.Create;

  //----------------------------------------------------------------------------
finalization
  _z_ListaLeitor.Free;

end.
