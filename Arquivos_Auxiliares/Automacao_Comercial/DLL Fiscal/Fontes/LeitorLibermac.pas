unit LeitorLibermac;

interface

Uses
  Dialogs, LeitorMain, Windows, SysUtils, classes, LojxFun, Forms, CommInt,
  syncobjs, Messages, Sndkey32;

Type
  TEditThread = class( TThread )
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Execute; override;
  end;

  TLeitorOptico = class(TCustomComm)
  protected
      procedure Comm1RxChar(Sender: TObject; Count: Integer);
  public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

  TLeitor_Libermac = class(TLeitor)
  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function LeitorFoco( Modo:Integer ):String; override;
  end;

//----------------------------------------------------------------------------
implementation
//----------------------------------------------------------------------------
var
  Comm1 : TLeitorOptico;
  sRetorno   : String;
  ThreadEdit : TEditThread = nil;
  Codigos : TStringList;
  Foco : Boolean = True;


//------------------------------------------------------------------------------
constructor TLeitorOptico.Create;
begin
  inherited;
end;
//------------------------------------------------------------------------------
destructor TLeitorOptico.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
constructor TEditThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;
//------------------------------------------------------------------------------
destructor TEditThread.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
procedure TLeitorOptico.Comm1RxChar(Sender: TObject; Count: Integer);
var
  Buffer  : array[0..100] of Char;
  Bytes, P: Integer;
begin
  sRetorno:='';
  Fillchar(Buffer, Sizeof(Buffer), 0);
  sleep(50);
  Bytes := Comm1.Read(Buffer, 100);
  if Bytes = -1 then
    ShowMessage('Erro de leitura da resposta do comando')
  else
  begin
    for P := 0 to Bytes do
      If Buffer[P]<>#13 then
        sRetorno:=sRetorno+Buffer[P];
  end;
  sRetorno:=copy(sRetorno,1,length(sRetorno)-2);
  Codigos.Add(sRetorno);

end;

//------------------------------------------------------------------------------
function TLeitor_Libermac.Abrir(sPorta : String) : String;
begin
     Comm1 := TLeitorOptico.Create(Application);
     Comm1.OnRxChar := Comm1.Comm1RxChar;

     //  Application.OnException := HandleException;
     Comm1.BaudRate := br9600;
     Comm1.Databits := da8;
     Comm1.Parity   := paNone;
     Comm1.StopBits := sb10;
     Comm1.DeviceName := sPorta;
     try
       //Abre a porta serial
       Comm1.Open;
       Comm1.SetRTSState(True);
       Comm1.SetDTRState(True);
       Comm1.SetBREAKState(True);
       Comm1.SetXONState(True);


       If not assigned(ThreadEdit) then
       begin
         ThreadEdit:= TEditThread.Create;
         ThreadEdit.Resume;
       end;

       Codigos := TStringList.Create;
       result := '0';
     except
       result := '1';
     end;
end;
//---------------------------------------------------------------------------
function TLeitor_Libermac.Fechar( sPorta:String ) : String;
begin
  //Finaliza a Thread caso fique sem fechar em algum get
  ThreadEdit.Terminate;
  //Fecha porta serial
  Comm1.Close;
  Comm1.Free;
  result := '0|';
end;

//----------------------------------------------------------------------------
function TLeitor_Libermac.LeitorFoco( Modo:Integer ):String;
begin
  If Modo = 1 then
    Foco := True
  Else
    Foco := False;
end;

//---------------------------------------------------------------------------
procedure TEditThread.Execute;
Var
 i : integer;
 pTecla : Pchar;
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
        SendKeys('~',True); // Envia um Enter para confirmar a Informacao;]
        Foco := False;
        Codigos.Delete(0);
        Application.ProcessMessages;
        CS.Leave;
      finally
        CS.Free;
      end;
    end;


  end;
  StrDispose(pTecla);
end;

//----------------------------------------------------------------------------
initialization
  RegistraLeitor( 'LIBERMARC', TLeitor_Libermac, 'BRA' );
//----------------------------------------------------------------------------
end.
