unit FultronicFs80H;

interface

uses
  Windows, ComCtrls, StdCtrls, SysUtils, EncdDecd, Classes, LojxFun;

//--Funções de capturar biometria, comparar biometria e setar parametros para o equipamento
function CapturarBiometria(out base64: string; out tam64: integer): integer;
function CompararBiometria(sData: string; out cValidacao: string): integer;
function SetParams(): integer;
function OpenDllFtrAPI(): integer;

//--Funções de conversao para binario para base64 e de base64 para binario
function BufferToBase64(P: Pointer; Size: Integer): string;
function Base64ToBuffer(const Base64: string; out P: Pointer; out Size: Integer): Boolean;

implementation

const
  FTR_RETCODE_OK: DWORD = 0;
  FTR_PARAM_MAX_TEMPLATE_SIZE: DWORD = 6;
  FTR_PURPOSE_ENROLL: DWORD = 3;
  FTR_PARAM_CB_FRAME_SOURCE: DWORD = 4;
  FTR_PARAM_MAX_FARN_REQUESTED: DWORD = 13;
  FTR_PARAM_MAX_MODELS: DWORD = 10;
  FTR_PARAM_FAKE_DETECT: DWORD = 9;
  FTR_PARAM_FFD_CONTROL: DWORD = 11;
  FTR_PARAM_MIOT_CONTROL: DWORD = 12;

  BO_ENROLL: Integer = 1;
  BO_VERIFY: Integer = 2;

  FSD_FUTRONIC_USB: DWORD = 1;

type
  FTRAPI_RESULT = DWORD;
  FTR_USER_CTX  = Pointer;
  FTR_PURPOSE   = DWORD;
  FTR_PARAM     = DWORD;
  FTR_FARN      = Integer;

  BIOPERCONTEXT  = packed record
    oType:      Integer;
    wPrgBar:    ^TProgressBar;
    wTextLabel: ^TLabel;
  end;

  FTR_DATA = packed record
    dwSize:     DWORD;
    pData:      Pointer;
  end;
  FTR_DATA_PTR = ^FTR_DATA;

  FTR_ENROLL_DATA = packed record
    dwSize:     DWORD;
    dwQuality:  DWORD;
  end;
  FTR_ENROLL_DATA_PTR = ^FTR_ENROLL_DATA;

  FTR_PARAM_VALUE = ^DWORD;
  FTR_PARAM_VALUE_PTR = ^FTR_PARAM_VALUE;
  FTR_FARN_PTR = ^FTR_FARN;



var
  //
  // Funções e procedure da FtrAPI.DLL
  //
  TFTRTerminate:  procedure(); stdcall;
  TFTRInitialize: function(): FTRAPI_RESULT; stdcall;
  TFTRSetParam:   function(Param: FTR_PARAM; Value: FTR_PARAM_VALUE): FTRAPI_RESULT; stdcall;
  TFTRGetParam:   function( Param: FTR_PARAM; pValue: FTR_PARAM_VALUE_PTR ): FTRAPI_RESULT; stdcall;
  TFTREnrollX:    function( UserContext: FTR_USER_CTX; Purpose: FTR_PURPOSE; pTemplate: FTR_DATA_PTR; pEData: FTR_ENROLL_DATA_PTR ): FTRAPI_RESULT; stdcall;
  TFTRVerifyN:    function ( UserContext: FTR_USER_CTX; pTemplate: FTR_DATA_PTR; pResult: Pointer; pFARVerify: FTR_FARN_PTR ): FTRAPI_RESULT; stdcall;

//
// Abre a DLL do equipamento
//
function OpenDllFtrAPI(): integer;
var
  fHandle: THandle;
  Func: Pointer;
begin

  fHandle := LoadLibrary( 'FtrAPI.DLL' );

  if (fHandle <> 0) Then
  begin

    Func := GetProcAddress(fHandle,'FTRTerminate');
    if Assigned(Func) then
      TFTRTerminate := Func;

    Func := GetProcAddress(fHandle,'FTRInitialize');
    if Assigned(Func) then
      TFTRInitialize := Func;

    Func := GetProcAddress(fHandle,'FTRSetParam');
    if Assigned(Func) then
      TFTRSetParam := Func;

    Func := GetProcAddress(fHandle,'FTRGetParam');
    if Assigned(Func) then
      TFTRGetParam := Func;

    Func := GetProcAddress(fHandle,'FTREnrollX');
    if Assigned(Func) then
      TFTREnrollX := Func;

    Func := GetProcAddress(fHandle,'FTRVerifyN');
    if Assigned(Func) then
      TFTRVerifyN := Func;


    Result := 0;

  end
  else
  begin
    GravaLog('Erro ao carregar a FtrAPI.DLL. Verifique se as dlls (FTRAPI.dll e ftrScanAPI.dll) encontram-se dentro do diretório smartclient ou web-agent');
    Result := -1;
  end;

end;


//
// Captura a biometria do usuário (gera template)
//
function CapturarBiometria(out base64: string; out tam64: integer): integer;
var
   rCode:             FTRAPI_RESULT;
   TemplateSize:      Integer;
   lpTemplateBytes:   Pointer;
   Template:          FTR_DATA;
   eData:             FTR_ENROLL_DATA;
   boc:               BIOPERCONTEXT;
   Base64Template:    String;
begin
  Result := -1;
  GravaLog('Inicio da coleta da biometria.');

  if TFTRInitialize() = FTR_RETCODE_OK then
  begin
    rCode := SetParams();
    if rCode <> FTR_RETCODE_OK then
    begin
      GravaLog('Erro ao setar os parametros iniciais para a coleta da biometria!');
      TFTRTerminate;
      Exit;
    end;

    rCode := TFTRGetParam( FTR_PARAM_MAX_TEMPLATE_SIZE,
                          FTR_PARAM_VALUE_PTR( @TemplateSize ) );
    if rCode <> FTR_RETCODE_OK then
    begin
      GravaLog('Erro para buscar os parametros inicias no equipamento da biometria!');
      TFTRTerminate;
      Exit;
    end;
    GetMem( lpTemplateBytes, TemplateSize );

    // variavel para retorno da biometria
    Template.dwSize := TemplateSize;
    Template.pData  := lpTemplateBytes;
    eData.dwSize    := sizeof( FTR_ENROLL_DATA );

    // preparando a chamada para leitura da biometria
    boc.oType := BO_ENROLL;

    // leitura da biometria (apenas 1 leitura)
    rCode := TFTREnrollX( FTR_USER_CTX( @boc ), FTR_PURPOSE_ENROLL,
                          @Template, @eData );
    if rCode <> FTR_RETCODE_OK then
    begin
      GravaLog('Erro na coleta da biometria!');
      TFTRTerminate;
      FreeMem( lpTemplateBytes );
      Exit;
    end
    else
    begin

      Base64Template := BufferToBase64(Template.pData, Template.dwSize);
      base64 := Base64Template;
      tam64   := Template.dwSize;

      GravaLog('Coleta da biometria realizada com sucesso!');
      GravaLog('Biometria, parametro base64 - ' + Base64Template);
      GravaLog('Biometria, parametro tam64 - ' + IntToStr(tam64));

      Result := 0;
    end;

    FreeMem( lpTemplateBytes );

    // Finaliza a conexao com o equipamento
    TFTRTerminate;

  end
  else
  begin
    GravaLog('Erro ao inicializar equipamento da biometria, verifique se esta conectado na USB ou troque de porta USB. Verifique também se as dlls (FTRAPI.dll e ftrScanAPI.dll) encontram-se dentro do diretório smartclient ou web-agent!');
  end;
end;

//
// Compara o template salvo com o dedo atual do usuário
//
function CompararBiometria(sData: string; out cValidacao: string): integer;
var
  rCode: FTRAPI_RESULT;
  vFARN: FTR_FARN;
  vResult: LongBool;
  forVerify: FTR_DATA;
  boc: BIOPERCONTEXT;
  Tam: Integer;
  P: Pointer;
begin
  Result := -1;
  GravaLog('Inicio da verificação da biometria!');
  GravaLog('Biometria, parametro sData: ' + sData);

  if TFTRInitialize() = FTR_RETCODE_OK then
  begin

    rCode := SetParams();
    if rCode <> FTR_RETCODE_OK then
    begin
      GravaLog('Erro ao setar os parametros iniciais para a verificacao da biometria!');
      TFTRTerminate;
      Exit;
    end;

    // covertendo de base64 para binario
    Base64ToBuffer(sData, P, Tam);
    if Tam <= 0 then
    begin
      GravaLog('Erro para converter base64 em binario!');
      TFTRTerminate;
      Exit;
    end;

    // preparando contexto de chamada
    boc.oType := BO_VERIFY;

    // parametros
    forVerify.dwSize := Tam;
    forVerify.pData := P;

    // faz chamada para verificar biometria
    rCode := TFTRVerifyN( FTR_USER_CTX( @boc ), @forVerify, @vResult, @vFARN );
    if rCode <> FTR_RETCODE_OK then
    begin
      GravaLog('Erro ao realizar a verificação da biometria!');
      TFTRTerminate;
      Exit;
    end
    else
      Result := 0;

    // resultado
    if vResult = True then
    begin
      GravaLog('Verificação da biometria realizada com sucesso!');
      cValidacao := '1';
    end
    else
    begin
      GravaLog('Verificação esta errada, não é a mesma digital!');
      cValidacao := '2';
    end;

    TFTRTerminate;

  end
  else
  begin
    GravaLog('Erro ao inicializar equipamento da biometria, verifique se esta conectado na USB ou troque de porta USB. Verifique também se as dlls (FTRAPI.dll e ftrScanAPI.dll) encontram-se dentro do diretório smartclient ou web-agent!');
  end;

end;

//
// Seta os parametros iniciais do equipamento
//
function SetParams(): integer;
var
  rCodigo: FTRAPI_RESULT;
  bValue: Boolean;
  value: DWORD;
begin

  //Parametro para dizer a quantidade de vezes para fazer a coleta da biometria.
  rCodigo := TFTRSetParam( FTR_PARAM_MAX_MODELS, FTR_PARAM_VALUE( 3 ) );

  value := FSD_FUTRONIC_USB;
  rCodigo := TFTRSetParam( FTR_PARAM_CB_FRAME_SOURCE, FTR_PARAM_VALUE( value ) );

  bValue := FALSE;
  rCodigo := TFTRSetParam( FTR_PARAM_FAKE_DETECT, FTR_PARAM_VALUE( bValue ) );

  bValue := TRUE;
  rCodigo := TFTRSetParam( FTR_PARAM_FFD_CONTROL, FTR_PARAM_VALUE( bValue ) );

  bValue := FALSE;
  rCodigo := TFTRSetParam( FTR_PARAM_MIOT_CONTROL, FTR_PARAM_VALUE( bValue ) );

  Result := rCodigo;

end;

//
// Função para converter binario para base64
//
function BufferToBase64(P: Pointer; Size: Integer): string;
var
  InputStream: TMemoryStream;
  OutputStream: TStringStream;
begin
  InputStream := TMemoryStream.Create;
  OutputStream := TStringStream.Create('');
  try
    InputStream.WriteBuffer(P^, Size);
    InputStream.Position := 0;
    EncodeStream(InputStream, OutputStream);
    Result := OutputStream.DataString;
  finally
    InputStream.Free;
    OutputStream.Free;
  end;
end;


//
// Função para converter de base64 para binario (ponteiro)
//
function Base64ToBuffer(const Base64: string; out P: Pointer; out Size: Integer): Boolean;
var
  InputStream: TStringStream;
  OutputStream: TMemoryStream;
begin
  Result := False;
  InputStream := TStringStream.Create(Base64);
  OutputStream := TMemoryStream.Create;
  try
    DecodeStream(InputStream, OutputStream);
    Size := OutputStream.Size;
    GetMem(P, Size);
    OutputStream.Position := 0;
    OutputStream.ReadBuffer(P^, Size);
    Result := True;
  finally
    InputStream.Free;
    OutputStream.Free;
  end;
end;


end.
