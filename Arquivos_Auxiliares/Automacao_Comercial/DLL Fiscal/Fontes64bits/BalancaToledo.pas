unit BalancaToledo;

interface

uses
  Dialogs, BalancaMain, ImpCheqMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms;

Type
  TToledo = Class( TBalanca )
  Public
    function Abrir( sPorta:AnsiString ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function PegaPeso( ):AnsiString; override;
  End;

  TToledo9091 = Class(TToledo)
  Public
    function PegaPeso( ):AnsiString; override;
  End;

Function OpenToledo( sPorta:AnsiString ):AnsiString;
Function CloseToledo : AnsiString;

//------------------------------------------------------------------------------
implementation

Var
  fHandle : THandle;            // handle da P05.DLL
  fFuncToledo_AbrePorta         : function (const Porta,BaudRate,DataBits,Paridade:Integer): Integer; StdCall;
  fFuncToledo_FechaPorta        : function (): Integer; StdCall;
  fFuncToledo_PegaPeso          : function (const OpcaoEscrita:integer;Peso,Local:AnsiString):Integer; StdCall;

  bOpened   : Boolean;          // Flag que indica se a porta esta aberta
//------------------------------------------------------------------------------
Function OpenToledo( sPorta:AnsiString ) : AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      LjMsgDlg('A função "'+sMsg+'" não existe na Dll: ' + 'P05.dll');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet,iPorta,iBaud,iDtBits : Integer;
  fArquivo : TIniFile;
  sPath,sBaud,sDtBits,sParity : AnsiString;
begin
  GravaLog(' OpenToledo -> Porta:' + sPorta);
  Result  := '0';
  sParity := '1';
  sPath := ExtractFilePath(Application.ExeName);

  // Capturo do SIGALOJA.INI os dados para abertura de porta
  // [TOLEDO]
  // BaudRate = 9600
  // DataBits = 8
  // Parity = 1
  try
    GravaLog(' Balanca -> Leitura do arquivo SIGALOJA.INI no caminho [' + sPath + ']');
    fArquivo:= TIniFile.Create(sPath+'SIGALOJA.INI');
    sBaud   := fArquivo.ReadString('TOLEDO', 'BaudRate', '9600');
    sDtBits := fArquivo.ReadString('TOLEDO', 'DataBits', '8');
    sParity := fArquivo.ReadString('TOLEDO', 'Parity' , '1');
    fArquivo.Free;
  except
    MsgStop('Não foi possível ler o arquivo SIGALOJA.INI');
    GravaLog(' Balanca -> Não foi possível ler o arquivo SIGALOJA.INI');
  end;

  // Converto o retorno do sigaloja.ini
  If Trim( sBaud ) = '2400'
  Then iBaud := 0
  Else
    If Trim( sBaud ) = '4800'
    Then iBaud := 1
    Else
      If Trim( sBaud ) = '9600'
      Then iBaud := 2
      Else
        If Trim( sBaud ) = '1200'
        Then iBaud := 3
        Else iBaud := 2;

  If Trim( sDtBits ) = '7'
  Then iDtBits := 0
  Else
    If Trim( sDtBits ) = '8'
    Then iDtBits := 1
    Else iDtBits := 1;

  If Trim(sParity) = '' then
  begin
    GravaLog('Balança -> Chave ''Parity'' não está configurada, inserido valor padrão ''1''');
    sParity := '1';
  end;

  If Not bOpened Then
  Begin
    fHandle := LoadLibrary( 'P05.dll' );

    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'AbrePorta');
      if ValidPointer( aFunc, 'AbrePorta' ) then
        fFuncToledo_AbrePorta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'FechaPorta');
      if ValidPointer( aFunc, 'FechaPorta' ) then
        fFuncToledo_FechaPorta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'PegaPeso');
      if ValidPointer( aFunc, 'PegaPeso' ) then
        fFuncToledo_PegaPeso := aFunc
      else
        bRet := False;
    End
    Else
    Begin
      LjMsgDlg('O arquivo P05.DLL não foi encontrado.');
      GravaLog(' OpenToledo -> O arquivo P05.DLL não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      //Parâmetros: Porta (1,2,3,4) -- BaudRate(0=2400, 1=4800, 2=9600, 3=1200)
      //     DataBits (0 = 7 bits, 1 = 8 bits) -- Paridade ( 0 = Nenhuma, 1 = Ímpar, 2 = Par, 3 = Espaço)
      iPorta := StrToInt( Copy( Trim(sPorta), Length( sPorta ), 1 ) );
      GravaLog(' Toledo_AbrePorta -> ' + IntToStr(iPorta) + ',' + IntToStr(iBaud) + ',' + IntToStr(iDtBits) + ',' + sParity);
      iRet := fFuncToledo_AbrePorta( iPorta, iBaud, iDtBits, StrToInt(sParity) );
      GravaLog(' Toledo_AbrePorta <- iRet:' + IntToStr(iRet));

      If iRet <> 1 then
      begin
        GravaLog(' OpenToledo -> Erro na abertura da porta');
        LjMsgDlg('Erro na abertura da porta');
        result := '1|';
      end
      else
        bOpened := True;
    end
    else
    begin
      result := '1|';
    end;
  End;
End;
//------------------------------------------------------------------------------
Function CloseToledo : AnsiString;
var
  iRet : Integer;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      GravaLog(' Toledo_FechaPorta ->');
      iRet := fFuncToledo_FechaPorta;
      GravaLog(' Toledo_FechaPorta <- iRet:' + IntToStr(iRet));
      If iRet = 1 Then
      Begin
        FreeLibrary(fHandle);
        fHandle := 0;
        bOpened := False;
        Result := '0';
      End
      Else
        Result := '1';
    End;
  End
  Else
  Result := '1';
end;
//------------------------------------------------------------------------------
Function TToledo.Abrir( sPorta:AnsiString ):AnsiString;
Begin
  If Not bOpened Then
    Result := OpenToledo(sPorta)
  Else
    Result := '0';
End;
//------------------------------------------------------------------------------
function TToledo.Fechar( sPorta:AnsiString ):AnsiString;
begin
  Result := CloseToledo;
end;
//------------------------------------------------------------------------------
Function TToledo.PegaPeso():AnsiString;
Var
  iRet : Integer;
  pPeso : AnsiString;
  sPeso : AnsiString;
  lCaptura: Boolean;
  iCount: Integer;
Begin
  lCaptura := True;
  iCount   := 0;
  pPeso := Space( 8 );
  GravaLog(' Toledo_PegaPeso -> ');
  iRet := fFuncToledo_PegaPeso( 1, pPeso, '' );
  GravaLog(' Toledo_PegaPeso <- iRet:' + IntToStr(iRet) + ' - Peso:' + pPeso);

  //Antes de emitir alerta de peso instável, aguarda e faz nova tentativa caso o peso seja estabilizado
  While lCaptura do
  Begin
    //Verifica se Peso contem apenas numeros, quando peso instável pode conter os caracteres 'NNNN'
    Try
      If iRet = 1 Then
      Begin
        sPeso := FloatToStr( StrToFloat( pPeso ) / 1000  );
        lCaptura := False; //Não continua o While, já capturou o peso
      End;
    Except
      iRet := 0
    End;

    If iRet = 1 Then
    Begin
      Result := '0|'+ sPeso;
    End
    Else
    Begin
      If iCount < 5 Then
      Begin
        Inc(iCount);
        Sleep(500); // aguarda meio segundo para nova leitura
        Continue;
      End Else lCaptura := False;

      GravaLog(' Balança -> Peso Instavel ');
      ShowMessage( 'Peso instável!' );
      Result := '1|';
    End;

  End;

end;

{ TToledo9091 }

function TToledo9091.PegaPeso: AnsiString;
Var
  iRet : Integer;
  pPeso : AnsiString;
  sPeso : AnsiString;
  lCaptura: Boolean;
  iCount: Integer;
Begin
  lCaptura := True;
  iCount   := 0;
  pPeso := Space( 8 );
  GravaLog(' Toledo_PegaPeso9091 -> ');
  iRet := fFuncToledo_PegaPeso( 1, pPeso, '' );
  GravaLog(' Toledo_PegaPeso9091 <- iRet:' + IntToStr(iRet) + ' - Peso:' + pPeso);

  //Antes de emitir alerta de peso instável, aguarda e faz nova tentativa caso o peso seja estabilizado
  While lCaptura do
  Begin
    //Verifica se Peso contem apenas numeros, quando peso instável pode conter os caracteres 'NNNN'
    Try
      If iRet = 1 Then
      Begin
        sPeso := FloatToStr( StrToFloat(  pPeso ) / 100  );
        lCaptura := False; //Não continua o While, já capturou o peso
      End;
    Except
      iRet := 0
    End;

    If iRet = 1 Then
    Begin
      Result := '0|'+ sPeso;
    End
    Else
    Begin
      If iCount < 5 Then
      Begin
        Inc(iCount);
        Sleep(500); // aguarda meio segundo para nova leitura
        Continue;
      End Else lCaptura := False;

      GravaLog(' Balança -> Peso Instavel ');
      ShowMessage( 'Peso instável!' );
      Result := '1|';
    End;
  End;
end;

(*initialization
  RegistraBalanca( 'Toledo 9094', TToledo, 'BRA' );
  RegistraBalanca( 'Toledo 8217', TToledo, 'BRA' );
  RegistraBalanca( 'Toledo 9091', TToledo9091, 'BRA' );*)

end.
