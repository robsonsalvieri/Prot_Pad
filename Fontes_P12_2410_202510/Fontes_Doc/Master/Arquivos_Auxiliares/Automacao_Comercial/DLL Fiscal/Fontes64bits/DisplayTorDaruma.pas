unit DisplayTorDaruma;

interface
Uses
  Dialogs, LeitorMain, Windows, SysUtils, classes, LojxFun, Forms, CommInt,
  syncobjs, Messages, DisplayTorMain, Sndkey32, ComDrv32;
Const
  ESC   = #27;
  BS    = #8;
  HT    = #9;
  LF    = #10;
  HOM   = #11;
  CLR   = #12;
  CR    = #13;
  CAN   = #24;
Type
  TDarumaTorDisplay = class(TDispTor)
  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function Escrever( Texto:String ): String; override;
    function Limpa( ) : String;
    function Posiciona( iColuna, iLinha : Integer ) : String;
  end;

  TDispTorDriver = class(TCommPortDriver)
      protected
      FBuffer: TMemoryStream;
      FCriticalSection: TCriticalSection;
      FReading: boolean;
      OnError : Boolean;
      LastCmd : String;
      LastRet : String;
      LastItem: String;
      Using   : Boolean;
      OnPaperError: Boolean;
      Desconto: String;
      ITCanc : Integer;
      procedure DoReceiveData(Sender: TObject; DataPtr: Pointer; DataSize: cardinal);
      procedure BeginUpdateBuffer;
      procedure EndUpdateBuffer;
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

implementation

var
  CommDrv : TDispTorDriver;
  bOpened : Boolean;
//------------------------------------------------------------------------------
constructor TDispTorDriver.Create(AOwner: TComponent);
begin
  inherited;
  FBuffer := TMemoryStream.Create;
  FCriticalSection := TCriticalSection.Create;
end;

//------------------------------------------------------------------------------
destructor TDispTorDriver.Destroy;
begin
  FBuffer.Free;
  FCriticalSection.Free;
  inherited;
end;

//------------------------------------------------------------------------------
procedure TDispTorDriver.BeginUpdateBuffer;
begin
  FCriticalSection.Enter;
end;

//------------------------------------------------------------------------------
procedure TDispTorDriver.EndUpdateBuffer;
begin
  FCriticalSection.Leave;
end;

//------------------------------------------------------------------------------
procedure TDispTorDriver.DoReceiveData(Sender: TObject; DataPtr: Pointer; DataSize: cardinal);
var
  s: string;
  nOldPos: integer;
begin
  with TDarumaTorDisplay(Sender) do
  begin
    PausePolling;
    s := '     ';

    ReadData( @s[1], 5 );

    if DataSize > 0 then
    begin
      if not FReading then
      begin
        FReading := True;
        BeginUpdateBuffer;
      end;
      nOldPos := FBuffer.Position;
      FBuffer.Position := FBuffer.Size;
      FBuffer.Write(DataPtr^, DataSize);
      FBuffer.Position := nOldPos;
      if ((pChar(cardinal(DataPtr)+DataSize-1)^ = #13) and (pChar(cardinal(DataPtr)+DataSize-2)^ = #26)) or
         (pChar(cardinal(DataPtr))^ = #6) or ((pChar(cardinal(DataPtr))^ = #4) and (pChar(cardinal(DataPtr)+1)^ = #13)) then
      begin
        FReading := False;
        EndUpdateBuffer;
      end;
    end;

    ContinuePolling;
  end;
end;
//------------------------------------------------------------------------------
function TDarumaTorDisplay.Abrir(sPorta : String) : String;
begin

  CommDrv := TDispTorDriver.Create(Application);
  CommDrv.OnReceiveData := CommDrv.DoReceiveData;

  If Not bOpened Then
  Begin
    bOpened := True;

    if UpperCase(sPorta) = 'COM1' then
      CommDrv.ComPort := pnCOM1
    else if UpperCase(sPorta) = 'COM2' then
      CommDrv.ComPort := pnCOM2
    else if UpperCase(sPorta) = 'COM3' then
      CommDrv.ComPort := pnCOM3
    else if UpperCase(sPorta) = 'COM4' then
      CommDrv.ComPort := pnCOM4
    else if UpperCase(sPorta) = 'COM5' then
      CommDrv.ComPort := pnCOM5
    else if UpperCase(sPorta) = 'COM6' then
      CommDrv.ComPort := pnCOM6
    else if UpperCase(sPorta) = 'COM7' then
      CommDrv.ComPort := pnCOM7
    else
      CommDrv.ComPort := pnCOM8;

    CommDrv.ComPortSpeed := br9600;
    CommDrv.Connect;
    Result := '0';
  End;
End;
//------------------------------------------------------------------------------
function TDarumaTorDisplay.Fechar( sPorta:String ): String;
begin
  If bOpened Then
  Begin
    bOpened := False;
    CommDrv.Disconnect;
    CommDrv.Free;
    CommDrv := NIL;
  End;
  Result := '1|';
end;
//------------------------------------------------------------------------------
function TDarumaTorDisplay.Escrever( Texto:String ): String;
Var
  bRet : Boolean;
  sTextoAux : String;
Begin
  bRet := False;
  CommDrv.SendString( CLR + HOM );    // posiciono na 1º coluna da 1º linha
  If bOpened Then
  Begin
    While Texto <> '' Do
    Begin
      sTextoAux := Copy( Texto , 1, 16 );
      Texto := Copy( Texto, 17, Length( Texto ) );
      bRet := CommDrv.SendString( sTextoAux );
      If Length( sTextoAux ) = 16 Then
        CommDrv.SendString( CR );
      If Length( sTextoAux ) < 16 Then
        CommDrv.SendString( LF + CR );
    End;
  End
  Else
    MsgStop( 'Porta não aberta!' );

  If bRet Then
    Result := '0'
  Else
    Result := '1';
End;
//------------------------------------------------------------------------------
function TDarumaTorDisplay.Limpa( ) : String;
Var
  bRet : Boolean;
Begin
  Result := '1';
  bRet := CommDrv.SendString(CLR);      // Limpo o display

  If bRet Then
    Result := '0'
  Else
    Result := '1';
End;
//------------------------------------------------------------------------------
function TDarumaTorDisplay.Posiciona( iColuna, iLinha : Integer ) : String;
Var
  bRet : Boolean;
  iAux : Integer;
Begin
  iAux := 0;
  Result := '1';

  bRet := CommDrv.SendString(CLR + HOM);      // Limpo o Dissplay
  If bRet Then
  Begin
    If iLinha = 2 Then
      CommDrv.SendString(LF);
    While iColuna <= iAux Do
    Begin
      CommDrv.SendString(HT);
      iAux := iAux + 1;
    End;
  End;

  If bRet then
    Result := '0'
  Else
    Result := '1';
End;

//------------------------------------------------------------------------------
initialization
RegistraDispTor( 'Display Torre Daruma', TDarumaTorDisplay, 'BRA' );

end.
