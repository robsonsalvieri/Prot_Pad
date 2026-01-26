unit GavetaIBM;

interface

Uses
  Dialogs,
  GavetaMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms,
  ComObj,
  IniFiles;

Type
  TGaveta_IBM = class(TGaveta)
  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function Acionar( sPorta:String ):String; override;
    function Status( sPorta:String ): String; override;
  end;

Var
  OposGaveta : OleVariant;

Implementation

//----------------------------------------------------------------------------
function TGaveta_IBM.Abrir(sPorta : String) : String;
var
  nRet : Integer;
  sPath : String;
  sGaveta : String;
  fArquivo : TIniFile;
begin
  // Pega o nome da gaveta.
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
  sGaveta := fArquivo.ReadString('Devices', 'CashDrawer', '');
  fArquivo.Free;

  OposGaveta := CreateOleObject('OPOS.CashDrawer');
  nRet := OposGaveta.Open(sGaveta);

  If nRet = 0 then
  begin
    OposGaveta.Claim(1000);
    OposGaveta.DeviceEnabled := True;
    Result := '0';
  end
  Else
    Result := '1';
end;

//---------------------------------------------------------------------------
function TGaveta_IBM.Fechar( sPorta:String ) : String;
begin
  OposGaveta.Close;
  Result := '0';
end;

//---------------------------------------------------------------------------
function TGaveta_IBM.Acionar( sPorta:String ):String;
begin
  OposGaveta.OpenDrawer;
  result := '0';
end;

//---------------------------------------------------------------------------
function TGaveta_IBM.Status( sPorta:String ):String;
begin
  if OposGaveta.DrawerOpened then
    // 1 - Aberta
    Result := '1'
  else
    // 0 - Fechada
    Result := '0';
end;

//----------------------------------------------------------------------------
initialization
  RegistraGaveta( 'Gaveta IBM', TGaveta_IBM, 'POR|EUA' );

//----------------------------------------------------------------------------
end.
