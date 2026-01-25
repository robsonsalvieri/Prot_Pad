unit ImpCheqMain;

interface

uses
  Classes, SysUtils;

const
  IMPCHEQ_NOERROR       = 0;
  IMPCHEQ_ERRNODRIVER   = -1;
  IMPCHEQ_ERRDUPLICATE  = -2;
  IMPCHEQ_ERROPENING    = -3;
  IMPCHEQ_ERRPRINTING   = -4;
  IMPCHEQ_ERRHANDLE     = -5;

  Function ImpCheqAbrir( aModelo,aPorta: PChar ): Integer; StdCall;
  Function ImpCheqImpr( aHdl:Integer; Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Integer; StdCall;
  Function ImpCheqFecha( aHdl: Integer; aPorta:PChar ) : Integer; StdCall;
  Function ImpCheqListar( aBuff:PChar ): Integer; StdCall;
  Function ImpCheqStatus( aHdl:Integer; Tipo, aBuff: Pchar ): Integer; StdCall;
  Function ImpCheqImprTransf( aHdl:Integer; Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Integer; StdCall;

Type
  ////////////////////////////////////////////////////////////////////////////
  //  Driver básico de uma impressora
  TImpressoraCheque = class(tObject)
  private
    fModelo : String;
    fPorta  : String;
  public
    constructor Create( aModelo,aPorta: String ); virtual;

    function Abrir( sPorta:String ): Boolean; virtual; abstract;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela, Pais:PChar ): Boolean; virtual; abstract;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ): Boolean; virtual; abstract;
    function Fechar( sPorta:String ): Boolean; virtual; abstract;
    function StatusCh( Tipo:Integer ): String; virtual; abstract;

    property Modelo : String read fModelo;
    property Porta  : String read fPorta;
  end;

  TImpressoraChequeClass = class of TImpressoraCheque;
  //
  /////////////////////////////////////////////////////////////////////////////

  procedure RegistraImpCheque(aModelo: String; aClass: TImpressoraChequeClass; sPaises:String);

implementation

type
  /////////////////////////////////////////////////////////////////////////////
  //
  //  TListaDrivers  - Lista com os Drivers
  //
  TListaDrivers = class(TStringList)
  public
    function  RegistraImpCheque( aModelo: String; aClass: TImpressoraChequeClass; sPaises:String ): Boolean;
    function  CriaImpressora( aModelo, aPorta: String ): TImpressoraCheque;
  end;
  //
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  //
  //  Lista com as impressoras
  //
  TListaImpressoras = class(TStringList)
  public
    destructor Destroy; override;

    function Acha( aHdl: Integer ): TImpressoraCheque;
    function CriaImp( aModelo, aPorta: String ): Integer;
    function Imprime( aHdl:Integer; Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Integer;
    function ImprimeTransf( aHdl:Integer; Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Integer;
    function ApagaImp( aHdl: Integer; aPorta:String ):Integer;
    function Status ( aHdl,Tipo:Integer ):String;
  end;
  //
  /////////////////////////////////////////////////////////////////////////////

var
  _z_ListaDrivers : TListaDrivers;
  _z_ListaImpressoras: TListaImpressoras;

//////////////////////////////////////////////////////////////////////////////
//
//  TImpressoraCheque.Create
//
constructor TImpressoraCheque.Create(aModelo, aPorta: String);
begin
  fModelo := aModelo;
  fPorta  := aPorta;
end;
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
//  TListaDrivers
//
function  TListaDrivers.RegistraImpCheque( aModelo: String; aClass: TImpressoraChequeClass; sPaises:String ): Boolean;
begin

  if (IndexOf(aModelo) < 0) Then
  begin
    AddObject(aModelo,TObject(aClass));
    AddObject(sPaises,TObject(aClass));
    Result := True;
  end
  else
    Result := False;
end;

//---------------------------------------------------------------------------

function  TListaDrivers.CriaImpressora( aModelo, aPorta: String ): TImpressoraCheque;
var
  aPos: Integer;
begin
  aPos := IndexOf(aModelo);
  if (aPos < 0) Then
    Result := nil
  else
    Result := TImpressoraChequeClass( Objects[aPos] ).Create( aModelo, aPorta );
end;
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
//  TListaImpressoras
//
destructor TListaImpressoras.Destroy;
var
  i : Integer;
begin
  for i := 0 to Count-1 do
    if (Objects[i] <> nil) Then
      Objects[i].Free;
  inherited;
end;

//----------------------------------------------------------------------------
function TListaImpressoras.Acha( aHdl: Integer ): TImpressoraCheque;
begin
  if (aHdl >= 0) and (aHdl < Count) Then
    Result := TImpressoraCheque(Objects[aHdl])
  else
    Result := nil;
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.ApagaImp(aHdl: Integer; aPorta:String): Integer;
var
  aImp: TImpressoraCheque;
begin
  aImp := Acha(aHdl);
  if Assigned( aImp ) then
  begin
    aImp.Fechar( aPorta );
    Objects[aHdl].Free;
    Objects[aHdl] := Nil;
    _z_ListaImpressoras.Delete(aHdl);
    result := IMPCHEQ_NOERROR;
  end
  else
    result := IMPCHEQ_ERRHANDLE;
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.CriaImp(aModelo, aPorta: String): Integer;
var
  aImp: TImpressoraCheque;
  aChave: String;
begin
  aChave := Format('{{{%s}}}{{{%s}}}',[aModelo,aPorta]);

  if (IndexOf(aChave) < 0) Then
  begin
    aImp := _z_ListaDrivers.CriaImpressora( aModelo, aPorta );
    if Assigned(aImp) Then
    begin
      if aImp.Abrir(aPorta) Then
        Result := AddObject(aChave,aImp)
      else
      begin
        aImp.Free;
        Result := IMPCHEQ_ERROPENING;
      end;
    end
    else
      Result := IMPCHEQ_ERRNODRIVER;
  end
  else
    Result := IMPCHEQ_ERRDUPLICATE;
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.Imprime( aHdl:Integer; Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Integer;
var
  aImp : TImpressoraCheque;
begin
  aImp := Acha( aHdl );
  if Assigned(aImp) then
  begin
    if aImp.Imprimir(Banco, Valor, Favorec, Cidade, Data, Mensagem, Verso, Extenso, Chancela, Pais) then
      result := IMPCHEQ_NOERROR
    else
      result := IMPCHEQ_ERRPRINTING;
  end
  else
    result := IMPCHEQ_ERRHANDLE;
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.ImprimeTransf( aHdl:Integer; Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ): Integer;
var
  aImp : TImpressoraCheque;
begin
  aImp := Acha( aHdl );

  if Assigned( aImp ) then
  begin
    if aImp.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem ) then
      result := IMPCHEQ_NOERROR
    else
      result := IMPCHEQ_ERRPRINTING;
  end
  else
    result := IMPCHEQ_ERRHANDLE;
end;

//-----------------------------------------------------------------------------
function TListaImpressoras.Status ( aHdl,Tipo:Integer ): String;
var
  sRet : String;
  aImp : TImpressoraCheque;
begin
  aImp := Acha( aHdl );
  if Assigned(aImp) then
  begin
    // Tipo - Indica qual o status quer se obter da impressora:
    //  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
    //  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não
    sRet := aImp.StatusCh( Tipo );
    Result := sRet;
  end
  else
    Result := '1|';
end;
//
/////////////////////////////////////////////////////////////////////////////

procedure RegistraImpCheque(aModelo: String; aClass: TImpressoraChequeClass; sPaises:String);
begin
  if (not _z_ListaDrivers.RegistraImpCheque( aModelo, aClass, sPaises )) Then
    raise Exception.CreateFmt('Erro na criação do driver "%s"',[aModelo] );
end;

//-----------------------------------------------------------------------------
Function ImpCheqAbrir( aModelo,aPorta: PChar ): Integer;
var
  cModelo : String;
  cPorta  : String;
begin
  cModelo := StrPas(aModelo);
  cPorta  := StrPas(aPorta);
  Result  := _z_ListaImpressoras.CriaImp( cModelo, cPorta );
end;

//-----------------------------------------------------------------------------
Function ImpCheqImpr( aHdl:Integer; Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela, Pais:PChar ): Integer;
begin
  Result := _z_ListaImpressoras.Imprime(aHdl, Banco, Valor, Favorec, Cidade, Data, Mensagem, Verso, Extenso, Chancela, Pais);
end;

//-----------------------------------------------------------------------------
Function ImpCheqFecha( aHdl: Integer; aPorta:PChar ): Integer;
var
  cPorta : String;
begin
  cPorta := StrPas(aPorta);
  Result := _z_ListaImpressoras.ApagaImp( aHdl, aPorta );
end;

//-----------------------------------------------------------------------------
Function ImpCheqListar( aBuff:PChar ): Integer;
var s:String;
begin
  s := _z_ListaDrivers.CommaText;
  StrPCopy( aBuff, s );
  Result := 0;
end;

//----------------------------------------------------------------------------
function ImpCheqStatus( aHdl:Integer;Tipo,aBuff:PChar ):Integer;
var
  s:String;
  iPos:Integer;
begin
  s := _z_ListaImpressoras.Status( aHdl, StrToInt(StrPas(Tipo)) );
  iPos := Pos('|',s);
  if iPos = 0 then
  begin
    StrPCopy( aBuff,' ' );
    result := StrToInt( s );
  end
  else
  begin
    StrPCopy( aBuff,copy(s,iPos+1,Length(s)) );
    result := StrToInt(copy(s,1,iPos-1));
  end;
end;

//-----------------------------------------------------------------------------
Function ImpCheqImprTransf( aHdl:Integer; Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Integer;
begin
  Result := _z_ListaImpressoras.ImprimeTransf( aHdl, Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem );
end;

//-----------------------------------------------------------------------------
initialization
  _z_ListaImpressoras := TListaImpressoras.Create;
  _z_ListaDrivers := TListaDrivers.Create;

finalization
  _z_ListaImpressoras.Free;
  _z_ListaDrivers.Free;

end.
