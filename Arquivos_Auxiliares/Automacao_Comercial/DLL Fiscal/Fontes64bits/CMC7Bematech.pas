unit CMC7Bematech;

interface

Uses
  Dialogs,
  CMC7Main,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms;

Type
  TCMC7_Bematech = class(TCMC7)
  private
    fHandle : HINST;
    IniPortaStr : function (sCom: PChar;nVeloc:Integer): Integer; stdcall;
    FechaPorta  : function : Integer; stdcall;
    DRCarrega   : function : Integer; stdcall;
  public
    function Abrir( sPorta, sMensagem: AnsiString):AnsiString; override;
    function Fechar : AnsiString; override;
    function LeDocumento:AnsiString; override;
    function Status( iRetorno:Integer ):AnsiString;
  end;

//----------------------------------------------------------------------------
implementation
//----------------------------------------------------------------------------
function TCMC7_Bematech.Abrir(sPorta, sMensagem: AnsiString) : AnsiString;

  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: DR1032.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;
  pTempPath  : PChar;
  sTempPath  : AnsiString;
  BufferTemp : Array[0..144] of Char;
begin
  fHandle := LoadLibrary( 'DR1032.DLL' );

    // Indica a possibilidade da utilização
    // via ActiveX portanto faz uma nova verificação.
    // Inicio

  if (fHandle = 0) Then
  begin
    GetTempPath(144,BufferTemp);
    sTempPath := trim(StrPas(BufferTemp))+'DR1032.DLL';
    pTempPath := PChar(sTempPath);
    fHandle   := LoadLibrary( pTempPath );
  end;
  // Fim

  if (fHandle <> 0) Then
  begin
    bRet := True;

    aFunc := GetProcAddress(fHandle,'IniPortaStr');
    if ValidPointer( aFunc, 'IniPortaStr' ) then
      IniPortaStr := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'FechaPorta');
    if ValidPointer( aFunc, 'FechaPorta' ) then
      FechaPorta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'DRCarrega');
    if ValidPointer( aFunc, 'DRCarrega' ) then
      DRCarrega := aFunc
    else
    begin
      bRet := False;
    end;

  end
  else
  begin
    ShowMessage('O arquivo DR1032.DLL não foi encontrado.');
    bRet := False;
  end;

  if bRet then
  begin
    iRet := IniPortaStr( PChar(sPorta),9600 );
    result := Status( iRet );
    if result <> '0' then
      bRet := False;
    if not bRet then
    begin
      If sMensagem = 'S' then
        ShowMessage('Erro na abertura da porta');
      result := '1';
    end;
  end
  else
    result := '1';

end;

//---------------------------------------------------------------------------
function TCMC7_Bematech.Fechar : AnsiString;
begin
  if (fHandle <> 0 ) then
  begin

//*****************************************************************************
// A função FechaPorta foi retirada pois dava erro de
// 'Esse programa executou operação ilegal e será fechado' no Win 98
// Essa alteração foi testada no Win 98 e 2000 com o remote local e em outra máquina
// Tb foram feitos testes com MP8, incluindo interface MDI.
//
// BOPS: 71243 - 'Ao utilizar um leitor CMC7 com a última Build está sendo gerado um erro.
// Com Win 2000 não ocorre. Foi reproduzido erro ao sair do sistema '
//*****************************************************************************
// 29/11/05 - Foram refeitos os testes com W98 e não foi reproduzida mais
// nenhuma nao conformidade.
//*****************************************************************************
    FechaPorta;
    Sleep(1000);
    FreeLibrary(fHandle);
    fHandle := 0;
  end;
  result := '0'
end;

//---------------------------------------------------------------------------
function TCMC7_Bematech.LeDocumento : AnsiString;
var
  iRet : Integer;
  sRet,sLinha,sPath : AnsiString;
  f : TextFile;
begin
  sPath := ExtractFilePath(Application.ExeName);
  iRet := DRCarrega;
  result := Status( iRet );
  if result = '0' then
  begin
    If FileExists(sPath+'DR10.RET') then
    begin
      AssignFile(f,sPath+'DR10.RET');
      Reset(f);
      sRet := '';
      While not Eof(f) do
      begin
        ReadLn(f,sLinha);
        sRet := sRet + sLinha;
      end;
      CloseFile(f);
      DeleteFile(sPath+'DR10.RET');
      result := result + '|' + sRet;
    end
    else
      result := '1';
  end;
end;

//----------------------------------------------------------------------------
function TCMC7_Bematech.Status( iRetorno:Integer ) : AnsiString;
begin
  if iRetorno = 1 then
    result := '0'
  else
    result := '1';

end;

//----------------------------------------------------------------------------
initialization
  RegistraCMC7('CMC7 BEMATECH', TCMC7_Bematech, 'BRA' );
//----------------------------------------------------------------------------
end.
