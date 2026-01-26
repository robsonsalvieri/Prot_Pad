unit ImpCupomBematech;

interface

uses
  Dialogs,
  ImpCupomMain,
  Windows,
  SysUtils,
  classes,
  LojxFun;

const
  BufferSize = 1024;

Type

  ImpCupomBematechMP20MI = class(TImpressora)
  private
    fHandle : THandle;
    fCupomIniPortaStr : function (pCom: PChar): Integer; StdCall;
    fCupomFechaPorta  : function ():Integer; StdCall;
    fCupomFormataTX   : function (BufTras:string; TpoLtra:integer; Italic:integer;
           Sublin:integer; expand:integer; enfat:integer):Integer; StdCall;

  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function Imprimir( Texto:String ): String; override;
  end;


implementation

//---------------------------------------------------------------------------
function ImpCupomBematechMP20MI.Abrir(sPorta : String) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: MP2032.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  iRet : Integer;
  bRet : Boolean;
begin
  fHandle := LoadLibrary( 'MP2032.DLL' );
  if (fHandle <> 0) Then
  begin
    bRet := True;

    aFunc := GetProcAddress(fHandle,'FechaPorta');
    if ValidPointer( aFunc, 'FechaPorta' ) then
      fCupomFechaPorta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'IniciaPorta');
    if ValidPointer( aFunc, 'IniciaPorta' ) then
      fCupomIniPortaStr := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'FormataTX');
    if ValidPointer( aFunc, 'FormataTX' ) then
      fCupomFormataTX := aFunc
    else
    begin
      bRet := False;
    end;

  end
  else
  begin
    ShowMessage('O arquivo MP2032.DLL não foi encontrado');
    bRet := False;
  end;

  if bRet then
  begin
    result := '0';
    iRet := fCupomIniPortaStr(PChar(sPorta));
    if iRet <> 1 then
    begin
      ShowMessage('Erro na abertura da porta.');
      result := '1';
    end;
  end
  else
    result := '1';

end;

//---------------------------------------------------------------------------
function ImpCupomBematechMP20MI.Fechar( sPorta:String ) : String;
begin
  if (fHandle <> INVALID_HANDLE_VALUE) then
  begin
    if fCupomFechaPorta <> 1 then
    begin
      ShowMessage('Erro ao fechar a comunicação com impressora Fiscal');
      result := '1|'
    end;
    FreeLibrary(fHandle);
    fHandle := 0;
  end;
  Result := '0|';
end;

//----------------------------------------------------------------------------
function ImpCupomBematechMP20MI.Imprimir( Texto:String ): String;
var
  iRet : Integer;
  i : Integer;
  sLinha : String;
begin
  iRet := -1;
  i:=1;
  While i <= Length(Texto) do
  begin
    if (Length(sLinha) > 47) Or (Copy(Texto,i,1) = #10) Or (i = Length(Texto)) then
    begin
      iRet := fCupomFormataTX( sLinha+#10, 2, 0, 0, 0, 0 );
      if copy(Texto,i,1) <> #10 then
        sLinha := copy(Texto,i,1)
      else
        sLinha := '';
    end
    else
      sLinha := sLinha + copy(Texto,i,1);
    Inc(i);
  end;

  if iRet = 1 then
    result := '0'
  else
    result := '1';
end;

//----------------------------------------------------------------------------
//initialization
  //RegistraImp('BEMATECH MP20MI', ImpCupomBematechMP20MI, 'BRA');


end.
