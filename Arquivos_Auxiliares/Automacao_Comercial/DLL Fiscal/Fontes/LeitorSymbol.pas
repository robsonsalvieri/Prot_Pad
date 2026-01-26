unit LeitorSymbol;

interface

Uses
  Dialogs, LeitorMain, Windows, SysUtils, classes, LojxFun, Forms, CommInt,
  syncobjs, Messages, Sndkey32;

Type
  TEditThread = class( TThread )
  public
    constructor Create;

    destructor Destroy; override;

    procedure Execute; override;
  end;

  TLeitorOptico = class( TCustomComm )
  protected
    procedure Comm1RxChar( Sender : TObject; Count : Integer );
    procedure Comm1RxCharB( Sender : TObject; Count : Integer );    
  public
    constructor Create( AOwner : TComponent ); override;

    destructor Destroy; override;
  end;

  TLeitor_Symbol = class( TLeitor )
  public
    function Abrir( sPorta : String; sFoco : String ) : String; override;
    function Fechar( sPorta : String ) : String; override;
    function LeitorFoco( Modo : Integer ):String; override;
  end;

  TLeitor_SymbolLS5700 = class( TLeitor_Symbol )
  public
    function Abrir( sPorta : String; sFoco : String ) : String; override;
  end;

  TLeitor_SymbolLS7708 = class( TLeitor_Symbol )
  public
    function Abrir( sPorta : String; sFoco : String ) : String; override;
  end;

//----------------------------------------------------------------------------
implementation

//----------------------------------------------------------------------------
var
  Comm1         : TLeitorOptico;
  sRetorno      : String;
  ThreadEdit    : TEditThread = nil;
  Codigos       : TStringList;
  Foco          : Boolean = True;
  bCtrlFoco     : Boolean = True;
  bFim          : Boolean = False;

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
  inherited Create( True );
  FreeOnTerminate := True;
end;

//------------------------------------------------------------------------------
destructor TEditThread.Destroy;
begin
  inherited;
end;

//---------------------------------------------------------------------------
procedure TEditThread.Execute;
var
  i      : integer;
  pTecla : Pchar;
  CS     : TCriticalSection;
begin
  pTecla := StrAlloc(2);

  while not Terminated do
  begin
    Application.ProcessMessages;
    Sleep( 100 );

    While ( Codigos.Count > 0 ) and ( Foco ) do
    begin
      CS := TCriticalSection.Create;

      try
        CS.Enter;

        for i := 1 to Length( Codigos.Strings[0] ) do
        begin
          FillChar( pTecla^, 2, 0 );
          StrPCopy( pTecla, Codigos.Strings[0][i] );
          SendKeys( pTecla, True );
        end;

        SendKeys( '~', True ); // Envia um Enter para confirmar a Informacao
        Foco := bCtrlFoco;
        Codigos.Delete( 0 );
        Application.ProcessMessages;
        CS.Leave;
      finally
        CS.Free;
      end;
    end;
  end;

  StrDispose( pTecla );
end;

//------------------------------------------------------------------------------
function TLeitor_Symbol.Abrir( sPorta : String; sFoco : String ) : String;
begin
  bFim := True;

  if sFoco = 'T' then
    bCtrlFoco := False
  else
    bCtrlFoco := True;

  Comm1                 := TLeitorOptico.Create( Application );
  Comm1.OnRxChar        := Comm1.Comm1RxChar;

  //  Application.OnException := HandleException
  Comm1.BaudRate        := br9600;
  Comm1.Databits        := da8;
  Comm1.Parity          := paNone;
  Comm1.StopBits        := sb10;
  Comm1.DeviceName      := sPorta;

  try
    //Abre a porta serial
    Comm1.Open;
    Comm1.SetRTSState( True );
    Comm1.SetDTRState( True );
    Comm1.SetBREAKState( True );
    Comm1.SetXONState( True );

    if not Assigned( ThreadEdit ) then
    begin
      ThreadEdit := TEditThread.Create;
      ThreadEdit.Resume;
    end;

    Codigos     := TStringList.Create;
    Result      := '0';
  except
    Result      := '1';
  end;
end;

//---------------------------------------------------------------------------
function TLeitor_Symbol.Fechar( sPorta : String ) : String;
var
  bOk : Boolean;
begin
  bOk := False;

  //Finaliza a Thread caso fique sem fechar em algum get
  ThreadEdit.Terminate;

  while not bOk do
    if ThreadEdit.Terminated then
    begin
      //////////////////////////////////////////////////////////////////////////
      // Como a thread já foi finalizada, ela só será inicializada novamente  //
      // se ela for criada na função TLeitor_Symbol.Abrir.                    //
      // para que isso aconteça, ela precisa ser destruída e setada como nil. //
      //////////////////////////////////////////////////////////////////////////
      ThreadEdit := nil;
      bOk        := True;
    end;

  //Fecha porta serial
  Comm1.Close;
  Comm1.Free;

  bFim := True;

  result := '0|';
end;

//----------------------------------------------------------------------------
function TLeitor_Symbol.LeitorFoco( Modo:Integer ):String;
begin
  If Modo = 1 then
    Foco := True
  Else
    Foco := False;
end;

//------------------------------------------------------------------------------
function TLeitor_SymbolLS5700.Abrir( sPorta : String; sFoco : String ) : String;
begin
  bFim := False;

  if sFoco = 'T' then
    bCtrlFoco := False
  else
    bCtrlFoco := True;

  Comm1                 := TLeitorOptico.Create( Application );
  Comm1.OnRxChar        := Comm1.Comm1RxChar;

  //  Application.OnException := HandleException;
  Comm1.BaudRate        := br9600;
  Comm1.Databits        := da8;
  Comm1.Parity          := paNone;
  Comm1.StopBits        := sb10;
  Comm1.DeviceName      := sPorta;

  try
    //Abre a porta serial
    Comm1.Open;

    if not Assigned( ThreadEdit ) then
    begin
      ThreadEdit := TEditThread.Create;
      ThreadEdit.Resume;
    end;

    Codigos     := TStringList.Create;
    Result      := '0';
  except
    Result      := '1';
  end;
end;

//------------------------------------------------------------------------------
function TLeitor_SymbolLS7708.Abrir( sPorta : String; sFoco : String ) : String;
begin
  bFim := False;

  if sFoco = 'T' then
    bCtrlFoco := False
  else
    bCtrlFoco := True;

  Comm1                 := TLeitorOptico.Create( Application );
  Comm1.OnRxChar        := Comm1.Comm1RxCharB;

  //  Application.OnException := HandleException;
  Comm1.BaudRate        := br9600;
  Comm1.Databits        := da8;
  Comm1.Parity          := paNone;
  Comm1.StopBits        := sb10;
  Comm1.DeviceName      := sPorta;

  try
    //Abre a porta serial
    Comm1.Open;

    if not Assigned( ThreadEdit ) then
    begin
      ThreadEdit := TEditThread.Create;
      ThreadEdit.Resume;
    end;

    Codigos     := TStringList.Create;
    Result      := '0';
  except
    Result      := '1';
  end;
end;

//------------------------------------------------------------------------------
procedure TLeitorOptico.Comm1RxChar( Sender : TObject; Count : Integer );
var
  Buffer : array[0..100] of Char;
  Bytes  : Integer;
  P      : Integer;
begin
  //////////////////////////////////////////////////////////////////////////////
  //                       *** Problema encontrado: ***                       //
  // A Classe Comm1 é inicializada ao abrir o Leitor Optico. Com isso uma     //
  // thread entra em execução - TCommEventThread. Esta thread aguarda uma     //
  // mensagem da porta serial. Ao receber a mensagem mesmo que a thread       //
  // já tenha sido terminada, ela entra em Syncronize( DoOnSignal ), ou seja  //
  // a função que foi recebida pelo handler da mensagem é executada.          //
  // Logo, se o usuário sair da venda, as seguintes funções são executadas    //
  //                                                                          //
  // Comm1.Close;                                                             //
  // Comm1.Free;                                                              //
  //                                                                          //
  // Com isso, a thread termina, é desalocada da memória e destruída.         //
  // Mas a porta serial continua em execução por causa do Syncronize.         //
  // A função Comm1RxChar entra em execução, mas a thread já foi destruída.   //
  // A função Comm1.Read é então chamada, ocorrendo erro de memória.          //
  //                                                                          //
  //                             *** Solução: ***                             //
  // Para garantir que a função Comm1.Read só será chamada quando a porta     //
  // estiver aberta e em comunicação, uma variável foi criada                 //
  //                                                                          //
  // bFim : Boolean; (private)                                                //
  //                                                                          //
  // Esta variável só será True quando a porta de comunicação estiver         //
  // "on-line". Se o sistema chamar a função para fechar a porta, a variável  //
  // é setada para True, e se chamar a função chamar a função para abrir      //
  // a porta, a variável estará False.                                        //
  //////////////////////////////////////////////////////////////////////////////

  if not bFim then
  begin
    sRetorno := '';
    Fillchar( Buffer, Sizeof( Buffer ), 0 );
    Sleep( 50 );
    Bytes := Comm1.Read( Buffer, 100 );

    if Bytes = -1 then
      ShowMessage( 'Erro de leitura da resposta do comando' )
    else
    begin
      for P := 0 to Bytes do
        if Buffer[P] <> #13 then
        begin
          case Buffer[P] of
            '±' : Buffer[P] := '1';
            '²' : Buffer[P] := '2';
            '´' : Buffer[P] := '4';
            '·' : Buffer[P] := '7';
            '¸' : Buffer[P] := '8';
          end;

          sRetorno := sRetorno + Buffer[P];
        end
    end;

    sRetorno := Copy( sRetorno, 1, Length( sRetorno ) - 2 );
    Codigos.Add( sRetorno );
  end;
end;

//------------------------------------------------------------------------------
procedure TLeitorOptico.Comm1RxCharB( Sender : TObject; Count : Integer );
var
  Buffer : array[0..100] of Char;
  Bytes  : Integer;
  P      : Integer;
begin
  //////////////////////////////////////////////////////////////////////////////
  //                       *** Problema encontrado: ***                       //
  // A Classe Comm1 é inicializada ao abrir o Leitor Optico. Com isso uma     //
  // thread entra em execução - TCommEventThread. Esta thread aguarda uma     //
  // mensagem da porta serial. Ao receber a mensagem mesmo que a thread       //
  // já tenha sido terminada, ela entra em Syncronize( DoOnSignal ), ou seja  //
  // a função que foi recebida pelo handler da mensagem é executada.          //
  // Logo, se o usuário sair da venda, as seguintes funções são executadas    //
  //                                                                          //
  // Comm1.Close;                                                             //
  // Comm1.Free;                                                              //
  //                                                                          //
  // Com isso, a thread termina, é desalocada da memória e destruída.         //
  // Mas a porta serial continua em execução por causa do Syncronize.         //
  // A função Comm1RxChar entra em execução, mas a thread já foi destruída.   //
  // A função Comm1.Read é então chamada, ocorrendo erro de memória.          //
  //                                                                          //
  //                             *** Solução: ***                             //
  // Para garantir que a função Comm1.Read só será chamada quando a porta     //
  // estiver aberta e em comunicação, uma variável foi criada                 //
  //                                                                          //
  // bFim : Boolean; (private)                                                //
  //                                                                          //
  // Esta variável só será True quando a porta de comunicação estiver         //
  // "on-line". Se o sistema chamar a função para fechar a porta, a variável  //
  // é setada para True, e se chamar a função chamar a função para abrir      //
  // a porta, a variável estará False.                                        //
  //////////////////////////////////////////////////////////////////////////////

  if not bFim then
  begin
    sRetorno := '';
    Fillchar( Buffer, Sizeof( Buffer ), 0 );
    Sleep( 50 );
    Bytes := Comm1.Read( Buffer, 100 );

    if Bytes = -1 then
      ShowMessage( 'Erro de leitura da resposta do comando' )
    else
    begin
      for P := 0 to Bytes do
        if Buffer[P] <> #13 then
        begin
          case Buffer[P] of
            '±' : Buffer[P] := '1';
            '²' : Buffer[P] := '2';
            '´' : Buffer[P] := '4';
            '·' : Buffer[P] := '7';
            '¸' : Buffer[P] := '8';
          end;

          sRetorno := sRetorno + Buffer[P];
        end
    end;

    sRetorno := Copy( sRetorno, 1, Bytes );
    Codigos.Add( sRetorno );
  end;
end;

//----------------------------------------------------------------------------
initialization
  RegistraLeitor( 'SYMBOL MT 1800', TLeitor_Symbol,       'BRA' );
  RegistraLeitor( 'SYMBOL LS5700' , TLeitor_SymbolLS5700, 'BRA' );
  RegistraLeitor( 'SYMBOL LS 7708', TLeitor_SymbolLS7708, 'BRA' );
end.
