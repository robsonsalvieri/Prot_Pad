unit DisplayGertec;

interface

uses
  Dialogs, DisplayMain, Windows, SysUtils, classes, LojxFun, IniFiles, ComObj, Forms;

Type
  // Teclado Gertec com Display - modelo TecD65
  GertecDisplay = class(TDisplay)
  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function Escrever( Texto:String ): String; override;
  end;

implementation
var
  fHandle : THandle;
  fOpenTec65  : function: Integer; stdcall;
  fCloseTec65 : procedure stdcall;
  fSetDisp    : procedure (Disp_OnOff:Integer); stdcall;
//  fTxKbd      : procedure (Dado:Char); stdcall;
  fDispStr    : procedure (Str:Pchar); stdcall;
//  fDispCh     : procedure (Caract:Char); stdcall;
  fGoToXY     : procedure (Lin, Col :Integer); stdcall;
//  fBackSpace  : procedure; stdcall;
//  fLineFeed   : procedure; stdcall;
  fFormFeed   : procedure; stdcall;
//  fCarRet     : procedure; stdcall;
//  fSetPIN     : procedure (PIN_OnOff:Integer); pascal;
//  fGetMCRMsg  : procedure (MCRMsg:Pchar); stdcall;
//  fGetMCRBuf  : procedure (ReadBuf:Pchar); stdcall;
//  fReset      : procedure; stdcall;
//  fSetCard    : procedure (Card_OnOff:Integer); stdcall;
//  fSetNumL    : procedure (NumLock_OnOff:Integer); stdcall;
//  fSetCapsL   : procedure (CapsLock_OnOff:Integer); stdcall;
//  fBeepOn     : procedure (Beep_OnOff:Integer); stdcall;
//  fBeepKeyOn  : procedure (BeepKey_OnOff:Integer); stdcall;
  fSetEcho    : procedure (EchoOnOff,EchoSenha:Integer); stdcall;
//  fSetOpKey   : procedure (OpKey_OnOff:Integer); stdcall;
//  fReadOpKey  : procedure (OpKey_String:Pchar); stdcall;

//---------------------------------------------------------------------------
function GertecDisplay.Abrir(sPorta : String) : String;
  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ' + 'tec55.dll');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;

begin
  Result := '0';

  // O INPOUT.DLL é necessário estar junto com o tec65_32.dll
  fHandle := LoadLibrary('tec55.dll');
  if (fHandle <> 0) Then
  begin
    bRet := True;

    aFunc := GetProcAddress(fHandle,'OpenTec55');
    if ValidPointer( aFunc, 'OpenTec55' ) then
      fOpenTec65 := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'CloseTec55');
    if ValidPointer( aFunc, 'CloseTec55' ) then
      fCloseTec65 := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'SetDisp');
    if ValidPointer( aFunc, 'SetDisp' ) then
      fSetDisp := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'GoToXY');
    if ValidPointer( aFunc, 'GoToXY' ) then
      fGoToXY := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'DispStr');
    if ValidPointer( aFunc, 'DispStr' ) then
      fDispStr := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'FormFeed');
    if ValidPointer( aFunc, 'FormFeed' ) then
      fFormFeed := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle , 'SetEcho');
    if ValidPointer( aFunc , 'SetEcho' )
    then fSetEcho := aFunc
    else bRet     := False;

  end
  else
  begin
    ShowMessage('O arquivo tec55.dll ou o INPOUT.DLL não foi encontrado.');
    bRet := False;
  end;

  if bRet then
  begin
    iRet := fOpenTec65;
    if iRet = 0 then
    begin
      fSetDisp(1);
      fSetEcho(1,0);
      fFormFeed;
    end
  end
  else
    bRet := False;

  if Not bRet then
    Result := '1|';

end;

//---------------------------------------------------------------------------
function GertecDisplay.Fechar( sPorta:String ) : String;
begin
  Result := '0';
  fCloseTec65;
end;

//----------------------------------------------------------------------------
function GertecDisplay.Escrever( Texto:String ): String;
var nLinha : LongInt;
    cLocal : String;
    nPos   : LongInt;
    cTxtEnv : String;
begin
  Result := '0';

  //Tratamento para Habilitar/Desabilitar visualização da digitação no Display, utilizado para informar senha
  If Texto = '*' Then
  Begin
    fSetEcho(1,0);
    Exit;
  End Else
  If Texto = '**' Then
  Begin
    fSetEcho(1,1);
    Exit;
  End Else
  If Texto = '***' Then //Desabilita visualização e não apenas substitui por *** 
  Begin
    fSetEcho(0,0);
    Exit;
  End;


  nLinha := StrToInt(Copy(Texto,1,1));
  cLocal := Copy(Texto,2,1);
  Texto  := Trim(Copy(Texto,3,Length(Texto)));

  //Quando texto na primeira linha, limpa todo o display antes de enviar o texto
  If nLinha <= 1 Then
  Begin
    fFormFeed;
  End;

  //Verifica se irá quebrar a linha com o caractere especial "|"
  While Texto <> '' do
  Begin
    nPos := Pos('|',Texto) ;

    If nPos > 0 Then
    Begin
        cTxtEnv := Copy(Texto,1,nPos-1);
        Delete(Texto,1,nPos);
    End Else
    Begin
        cTxtEnv := Texto;
        Texto   := '';
    End;

    fGoToXY(nLinha,1); //posiciona na linha para inicio do texto

    //Centraliza texto
    if cLocal='C'
    then cTxtEnv := Copy(Space((35-Length(cTxtEnv)) div 2) + cTxtEnv + Space(35),1,35);

    fDispStr(PChar(Copy(cTxtEnv,1,35)));

    Inc(nLinha); //incrementa linha para ser utilizado caso tenha quebra com "|"

  End;

end;

//----------------------------------------------------------------------------
initialization
  RegistraDisplay('Gertec DISPLAY', GertecDisplay, 'BRA' );
end.
