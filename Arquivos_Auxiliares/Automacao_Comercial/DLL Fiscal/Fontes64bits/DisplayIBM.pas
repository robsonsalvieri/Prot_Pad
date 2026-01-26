unit DisplayIBM;

interface

uses
  Dialogs, DisplayMain, Windows, SysUtils, classes, LojxFun, IniFiles, ComObj, Forms;

const
  /////////////////////////////////////////////////////////////////////
  // OPOS "State" Property Constants
  /////////////////////////////////////////////////////////////////////
  OPOS_S_CLOSED = 1;
  OPOS_S_IDLE = 2;
  OPOS_S_BUSY = 3;
  OPOS_S_ERROR = 4;
  /////////////////////////////////////////////////////////////////////
  // OPOS "ResultCode" Property Constants
  /////////////////////////////////////////////////////////////////////
  OPOSERR = 100;
  OPOSERREXT = 200;
  OPOS_SUCCESS = 0;
  OPOS_E_CLOSED = 1 + OPOSERR;
  OPOS_E_CLAIMED = 2 + OPOSERR;
  OPOS_E_NOTCLAIMED = 3 + OPOSERR;
  OPOS_E_NOSERVICE = 4 + OPOSERR;
  OPOS_E_DISABLED = 5 + OPOSERR;
  OPOS_E_ILLEGAL = 6 + OPOSERR;
  OPOS_E_NOHARDWARE = 7 + OPOSERR;
  OPOS_E_OFFLINE = 8 + OPOSERR;
  OPOS_E_NOEXIST = 9 + OPOSERR;
  OPOS_E_EXISTS = 10 + OPOSERR;
  OPOS_E_FAILURE = 11 + OPOSERR;
  OPOS_E_TIMEOUT = 12 + OPOSERR;
  OPOS_E_BUSY = 13 + OPOSERR;
  OPOS_E_EXTENDED = 14 + OPOSERR;
  /////////////////////////////////////////////////////////////////////
  // "DisplayText" Method: "Attribute" Property Constants
  // "DisplayTextAt" Method: "Attribute" Property Constants
  /////////////////////////////////////////////////////////////////////
  DISP_DT_NORMAL = 0;
  DISP_DT_BLINK = 1;
  /////////////////////////////////////////////////////////////////////
  // "MarqueeType" Property Constantsconst LONG DISP_MT_NONE = 0;
  /////////////////////////////////////////////////////////////////////
  DISP_MT_NONE = 0;
  DISP_MT_UP = 1;
  DISP_MT_DOWN = 2;
  DISP_MT_LEFT = 3;
  DISP_MT_RIGHT = 4;
  DISP_MT_INIT = 5;

Type
  IBMDisplay = class(TDisplay)
  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function Escrever( Texto:String ): String; override;
  end;

implementation

var
  OposDisplay : OleVariant;

//---------------------------------------------------------------------------
function IBMDisplay.Abrir(sPorta : String) : String;
var
  nRetorno : Integer;
  sPath : String;
  sDisplay : String;
  fArquivo : TIniFile;
begin
  // Pega o nome da impressora no arquivo de configuracao
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
  sDisplay := fArquivo.ReadString('Devices', 'Display', '');

  // Estabelece a comunicação com o Display
  OposDisplay := CreateOleObject('OPOS.LineDisplay');   // nome do componente OLE da IBM
  nRetorno := OposDisplay.Open(sDisplay);   // O nome desse device deve estar no registro do Windows

  If nRetorno = OPOS_SUCCESS then
  begin
    Result := '0';
    OposDisplay.Claim(1000);
    OposDisplay.DeviceEnabled := True;
    OposDisplay.MarqueeType := DISP_MT_NONE;
    OposDisplay.InterCharacterWait := 0;
  end
  else
    Result := '1';
end;

//---------------------------------------------------------------------------
function IBMDisplay.Fechar( sPorta:String ) : String;
var
  nRetorno : Integer;
begin
  nRetorno := OposDisplay.Close;
  If nRetorno = OPOS_SUCCESS then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function IBMDisplay.Escrever( Texto:String ): String;
var
  nRetorno  : Integer;
  sTexto1 : String;
  sTexto2 : String;
begin
  Texto := Copy(Texto,3, Length(Texto));
  If Pos( #10, Texto  ) > 0 then
  begin
    sTexto1 := copy( Texto,1,Pos(#10,Texto)-1 );
    sTexto2 := copy( Texto,Pos(#10,Texto)+1,Length(Texto) );
  end
  Else
  begin
    sTexto1 := Texto;
    sTexto2 := '';
  end;
  sTexto1 := Copy(sTexto1+Space(20),1,20);
  sTexto2 := Copy(sTexto2+Space(20),1,20);

  nRetorno := OposDisplay.DisplayTextAt( 0,0,sTexto1+sTexto2,DISP_DT_NORMAL );
  If nRetorno = OPOS_SUCCESS then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
initialization
  RegistraDisplay('IBM DISPLAY', IBMDisplay, 'POR|EUA' );

end.
