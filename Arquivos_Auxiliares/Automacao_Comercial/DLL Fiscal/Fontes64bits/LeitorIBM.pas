unit LeitorIBM;

interface

Uses
  Dialogs, LeitorMain, Windows, SysUtils, classes, LojxFun, Forms, ComObj,
  syncobjs, IniFiles, Messages, Sndkey32;

Type
  TEditThread = class( TThread )
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Execute; override;
  end;

  TSendThread = class( TThread )
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Execute; override;
  end;

  TLeitor_IBM = class(TLeitor)
  public
    function Abrir( sPorta, sFoco: String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function LeitorFoco( Modo:Integer ):String; override;
  end;

//----------------------------------------------------------------------------
implementation
//----------------------------------------------------------------------------
var
  OposLeitor : OleVariant;
  ThreadEdit : TEditThread = nil;
  ThreadSend : TSendThread = nil;
  Codigos    : TStringList;
  Foco       : Boolean = True;
  bCtrlFoco  : Boolean = True;

//------------------------------------------------------------------------------
constructor TEditThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate:= True;
end;
//------------------------------------------------------------------------------
destructor TEditThread.Destroy;
begin
  inherited;
end;
//------------------------------------------------------------------------------
constructor TSendThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;
//------------------------------------------------------------------------------
destructor TSendThread.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
function TLeitor_IBM.Abrir(sPorta, sFoco: String) : String;
Var
  nRet : Integer;
  sScanner : String;
  sPath : String;
  fArquivo : TIniFile;
begin
    If sFoco='T' then
        bCtrlFoco := False
    else
        bCtrlFoco := True;
  
  // Pega o nome da impressora no arquivo de configuracao
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
  sScanner := fArquivo.ReadString('Devices', 'Scanner', '');
  fArquivo.Free;

  OposLeitor := CreateOleObject('OPOS.Scanner');
  nRet := OposLeitor.Open(sScanner);

  If nRet = 0 then
  begin
    OposLeitor.Claim(1000);
    OposLeitor.DeviceEnabled := True;
    OposLeitor.DataEventEnabled := True;
    Codigos := TStringList.Create;
    result := '0';
  end
  Else
    result := '1';

  // Executa a Thread para Ler os dados do Scanner
  If not assigned(ThreadEdit) then
  begin
    ThreadEdit:= TEditThread.Create;
    ThreadEdit.Resume;
  end;

  // Executa a Thread para mandar os dados para o Ap5
  If not assigned(ThreadSend) then
  begin
    ThreadSend:= TSendThread.Create;
    ThreadSend.Resume;
  end;

end;
//---------------------------------------------------------------------------
function TLeitor_IBM.Fechar( sPorta:String ) : String;
var
  nRet : Integer;
begin
  //Finaliza a Thread caso fique sem fechar em algum get
  ThreadEdit.Terminate;
  ThreadSend.Terminate;
  //Fecha porta serial
  nRet := OposLeitor.Close;
  If nRet = 0 then
    result := '0'
  Else
    result := '1';
end;

//----------------------------------------------------------------------------
function TLeitor_IBM.LeitorFoco( Modo:Integer ):String;
begin
  If Modo = 1 then
    Foco := True
  Else
    Foco := False;
end;

//----------------------------------------------------------------------------
procedure TEditThread.Execute;
begin
  While not Terminated do
  begin
    Application.ProcessMessages;
    Sleep(100);
    if OposLeitor.ScanData <> '' then
    begin
      Codigos.Add( OposLeitor.ScanData );
      OposLeitor.ClearInput;
      OposLeitor.DataEventEnabled := True;
    end;
  end;
end;

//---------------------------------------------------------------------------
procedure TSendThread.Execute;
var
  i : Integer;
  pTecla : PChar;
  CS : TCriticalSection;
Begin
  pTecla := StrAlloc(2);
  while not Terminated do
    Begin
    Application.ProcessMessages;
    Sleep(100);
    While (Codigos.Count > 0) and (Foco) do
    begin
      CS:= TCriticalSection.Create;
      try
        CS.Enter;
        For i:=1 to Length(Codigos.Strings[0]) do
        begin
          FillChar(pTecla^,2,0);
          StrPCopy(pTecla,Codigos.Strings[0][i]);
          SendKeys(pTecla,True);
        end;
        SendKeys('|',True); // Envia '|' Para Indicar que foi o Leitor que enviou
        SendKeys('~',True); // Envia um Enter para confirmar a Informacao;
        Codigos.Delete(0);
        Application.ProcessMessages;
        CS.Leave;
      finally
        CS.Free;
      end;
      Foco := bCtrlFoco;
    end;

  end;
  StrDispose(pTecla);

end;

//----------------------------------------------------------------------------
initialization
  RegistraLeitor( 'SCANNER IBM', TLeitor_IBM, 'POR|EUA' );
//----------------------------------------------------------------------------
end.
