unit u_SITEF;

interface

Uses
  Dialogs,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms;

  function MsCODSITEF(aString : PChar; var aBuff: AnsiString) : Integer; StdCall;
  function MsDECSITEF(aString : PChar; var aBuff: AnsiString) : Integer; StdCall;
  function CheckCODIF32 : Integer;

implementation

var

//  _CodificaSiTef
  fCodificaSitef   : procedure (Buffer: PChar; Tam: Word); stdcall;
// _DecodificaSiTef
  fDecodificaSitef : procedure (Buffer: PChar; Tam: Word); stdcall;

//----------------------------------------------------------------------------
function MsCodSITEF(aString:PChar; var aBuff:AnsiString) : Integer;

var
  fHandle : THandle;
  nInt    : Integer;
  aCript  : Pchar;
  i       : Integer;
  cOrd : String;
begin
  Result   := 1;

  // Verifica se a CODIF32.DLL existe
  CheckCODIF32();

  fHandle := LoadLibrary( 'CODIF32.DLL' );
  if (fHandle <> 0) Then
  begin
    fCodificaSiTef := GetProcAddress(fHandle,'_CodificaSiTef');
    nInt := StrLen(aString) div 3;
    aCript := StrAlloc(nInt);
    ZeroMemory(aCript,nInt);
    // A partir do ID 0.2.67.22, o LOJXECF passa a enviar para a DLL somente numeros decimais
    // representando o caracter atraves das funcoes CodSitef() e DecSitef().
    // Ex: Foi gerado a string Chr(0)+Chr(48)+Chr(1)...
    //     O LOJXECF envia a string '000'+'048'+'001'... Esta string de numeros
    // eh tratada dentro da SIGALOJA.DLL
    for i := 0 to nInt-1 do
      aCript[i] := Chr(StrToInt(aString[i*3]+aString[(i*3)+1]+aString[(i*3)+2]));
    // Codificacao pela CODIF32.DLL
    fCodificaSiTef(aCript,nInt);
    // Transformacao do resultado em numeros
    for i := 0 to nInt-1 do
    begin
      cOrd := FormataTexto(IntToStr(Ord(aCript[i])),3,0,2);
      aBuff[(i*3)+0] := AnsiChar(cOrd[1]);
      aBuff[(i*3)+1] := AnsiChar(cOrd[2]);
      aBuff[(i*3)+2] := AnsiChar(cOrd[3]);
    end;
    StrDispose(aCript);
  end;
  FreeLibrary(fHandle);
end;

//----------------------------------------------------------------------------
function MsDECSITEF(aString : PChar; var aBuff:AnsiString) : Integer;

var
  fHandle : THandle;
  nInt : Integer;
  aCript : Pchar;
  i : Integer;
  cOrd : String;
begin
  Result := 1;

  // Verifica se a CODIF32.DLL existe
  CheckCODIF32();

  fHandle := LoadLibrary( 'CODIF32.DLL' );
  if (fHandle <> 0) Then
  begin
    fDecodificaSitef := GetProcAddress(fHandle,'_DecodificaSiTef');
    nInt := StrLen(aString) div 3;
    aCript := StrAlloc(nInt);
    ZeroMemory(aCript,nInt);
    // A partir do ID 0.2.67.22, o LOJXECF passa a enviar para a DLL somente numeros decimais
    // representando o caracter atraves das funcoes CodSitef() e DecSitef().
    // Ex: Foi gerado a string Chr(0)+Chr(48)+Chr(1)...
    //     O LOJXECF envia a string '000'+'048'+'001'... Esta string de numeros
    // eh tratada dentro da SIGALOJA.DLL
    for i := 0 to nInt-1 do
      aCript[i] := Chr(StrToInt(aString[i*3]+aString[(i*3)+1]+aString[(i*3)+2]));
    // Codificacao pela CODIF32.DLL
    fDecodificaSiTef(aCript,nInt);
    // Transformacao do resultado em numeros
    for i := 0 to nInt-1 do
    begin
      cOrd := FormataTexto(IntToStr(Ord(aCript[i])),3,0,2);
      aBuff[(i*3)+0] := AnsiChar(cOrd[1]);
      aBuff[(i*3)+1] := AnsiChar(cOrd[2]);
      aBuff[(i*3)+2] := AnsiChar(cOrd[3]);
    end;
    StrDispose(aCript);
  end;
  FreeLibrary(fHandle);
end;

//----------------------------------------------------------------------------
function CheckCODIF32 : Integer;
var
  sFile : String;
begin
  // Pega o Path da SIGALOJA.DLL
  sFile := ExtractFilePath(Application.ExeName);

  if Copy(sFile,Length(sFile),1)<>'\' then
    sFile := sFile + '\';
  sFile := sFile + 'CODIF32.DLL';

  if Not FileExists(sFile) then
    ShowMessage('Arquivo CODIF32.DLL não encontrado.');

  Result := 0;
end;


//----------------------------------------------------------------------------
end.
