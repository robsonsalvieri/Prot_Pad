unit PinPad_SC552_CHIP;

interface

Uses
  Dialogs, PinPadMain, Windows, SysUtils, Classes, LojxFun, Forms;


Type
  TPinPad_SC552_CHIP = class(TPinPad)
  private
    fHandle : THandle;
    f_SESolicitaTrilhas : Procedure (pModalidade, pStatus: PChar); StdCall;
    f_SEObtemTrilha1_2 : Procedure (pTrilha1:PChar; pTrilha2:PChar; pStatus: PChar); StdCall;
    f_SESolicitaSenhaDedicado : Procedure  (pTrilha2: PChar; pMsgEnvPin: PChar; pWork: PChar; pStatus: PChar); StdCall;
    f_SEObtemSenha : Procedure (pSenha: PChar; pStatus: PChar); StdCall;
    f_SEMsgPadrao : Procedure (pMsg: PChar; pStatus: PChar); StdCall;
    f_SEFinalizar : Procedure; StdCall;

  public
    function Abrir( sPorta:String ):String; override;
    function Fechar:String; override;
    function LeCartao(sModalidade:String):String; override;
    function LeSenha( sTrilha2,sMsg,sWork:String ):String; override;
  end;

//----------------------------------------------------------------------------
implementation
//----------------------------------------------------------------------------
function TPinPad_SC552_CHIP.Abrir(sPorta : String) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: SITPIN32CHIP.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  pStatus : PChar;

begin
  fHandle := LoadLibrary( 'SITPIN32CHIP.DLL' );

  pStatus:= StrAlloc(3);
  StrPCopy(pStatus, Space(2));

  if (fHandle <> 0) Then
  begin
    bRet := True;
    aFunc := GetProcAddress(fHandle,'SESolicitaTrilhas');
    if ValidPointer( aFunc, 'SESolicitaTrilhas' ) then
      f_SESolicitaTrilhas := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'SEObtemTrilha1_2');
    if ValidPointer( aFunc, 'SEObtemTrilha1_2' ) then
      f_SEObtemTrilha1_2 := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'SESolicitaSenhaDedicado');
    if ValidPointer( aFunc, 'SESolicitaSenhaDedicado' ) then
      f_SESolicitaSenhaDedicado := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'SEObtemSenha');
    if ValidPointer( aFunc, 'SEObtemSenha' ) then
      f_SEObtemSenha := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'SEMsgPadrao');
    if ValidPointer( aFunc, 'SEMsgPadrao' ) then
      f_SEMsgPadrao := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'SEFinalizar');
    if ValidPointer( aFunc, 'SEFinalizar' ) then
      f_SEFinalizar := aFunc
    else
    begin
      bRet := False;
    end;

  end
  else
  begin
    ShowMessage('O arquivo SITPIN32CHIP.DLL não foi encontrado.');
    bRet := False;
  end;

  if bRet then
    Begin
    //f_SEMsgPadrao( pChar( 'Microsiga'),pStatus);
    result := '0';
    End
  else
    result := '1';

(*
  if bRet then
  begin
    iRet := fIniPorta( PChar(sPorta),9600 );
    result := Status( iRet );
    if result <> '0' then
      bRet := False;
    if not bRet then
    begin
      ShowMessage('Erro na abertura da porta');
      result := '1';
    end;
  end
  else
    result := '1';
*)
end;

//---------------------------------------------------------------------------
function TPinPad_SC552_CHIP.Fechar : String;
begin
  if (fHandle <> INVALID_HANDLE_VALUE) then
  begin
    f_SEFinalizar;
    FreeLibrary(fHandle);
    fHandle := 0;
  end;
  Result := '0';
end;

//---------------------------------------------------------------------------
function TPinPad_SC552_CHIP.LeCartao(sModalidade:String):String;
var
  sRetAux : String;
  pModalidade : PChar;
  pStatus : PChar;
  pTrilha1 : PChar;
  pTrilha2 : PChar;
  dtHoraInicio : TDateTime;
  iTimeOut : Integer;
  sRetorno : String;
begin
  dtHoraInicio := Now;
  iTimeOut := 60000;
  pModalidade:=StrAlloc(2);
  if sModalidade='D' then
    sModalidade:='2'
  Else
    sModalidade:='1';

  StrPCopy(pModalidade, sModalidade );
  pStatus:= StrAlloc(3);
  StrPCopy(pStatus, Space(2));
  sRetAux := '';
  While (sRetAux <> '00') Do
  Begin
    //While (sRetAux = '99') Do Begin
    f_SESolicitaTrilhas( pModalidade ,pStatus);
    sRetAux:= StrPas(pStatus);
    If (Now > (dtHoraInicio + iTimeOut * (1/24/60/60/1000))) Then
      sRetAux:= '00';
  End;

  pTrilha2:= StrAlloc(41);
  pTrilha1:= StrAlloc(81);
  StrPCopy(pModalidade, Space(1));
  StrPCopy(pStatus, Space(2));
  StrPCopy(pTrilha1, Space(80));
  StrPCopy(pTrilha2, Space(40));

  sRetAux:= '';
  While (sRetAux <> '00') Do
  Begin
    //If (sRetAux <> '99') Then Break;

    f_SEObtemTrilha1_2(pTrilha1,pTrilha2,pStatus);
    sRetAux := String(pStatus);
    If ( Trim(sRetAux) = '09')  Then
    Begin
      sRetorno:= '#'+sRetAux;
      result := '1|' + sRetorno;
      Exit;
    End;
    if Trim(sRetAux)<>'00' then
      MessageBox( 0, PChar('Erro conect Pin ['+Trim(sRetAux)+']'), 'PinPad', MB_OK + MB_ICONERROR + MB_SYSTEMMODAL);

    If (Now > (dtHoraInicio + iTimeOut * (1/24/60/60/1000))) Then
    Begin
      sRetAux:= '00';
      StrCopy(pTrilha1, PChar(Replicate('1',80)));
      StrCopy(pTrilha2, PChar(Replicate('2',40)));
    End;
  End;

  If (Trim(String(pTrilha1)) = '') Then
    sRetorno:= String(pTrilha2)
  Else
    sRetorno:= String(pTrilha2) + Chr(4) + String(pTrilha1);

  StrDispose(pStatus);
  StrDispose(pTrilha1);
  StrDispose(pTrilha2);
  StrDispose(pModalidade);
  result := '0|' + sRetorno;
end;

//----------------------------------------------------------------------------
function TPinPad_SC552_CHIP.LeSenha( sTrilha2,sMsg,sWork:String ):String;
var
  pTrilha2 : PChar;
  pMsgEnv : PChar;
  pWork : PChar;
  pStatus : PChar;
  pSenha : PChar;
  sRetAux : String;
  sRetorno : String;
  iTamanho : Integer;
begin
  pTrilha2:= StrAlloc(41);
  pMsgEnv := StrAlloc(17);
  pWork   := StrAlloc(21);
  pStatus := StrAlloc(3);

  StrPCopy(pStatus , PChar(Replicate(' ',2)));
  StrPCopy(pTrilha2, sTrilha2);
  StrPCopy(pMsgEnv , sMsg);
  StrPCopy(pWork   , sWork);

  sRetAux := '';
  While (sRetAux <> '00') Do Begin
    //While (sRetAux = '99') Do Begin
    f_SESolicitaSenhaDedicado(pTrilha2,pMsgEnv,pWork,pStatus);
    sRetAux := StrPas(pStatus);
  End;

  pSenha:= StrAlloc(21);
  StrPCopy(pStatus, Space(2));
  StrPCopy(pSenha , Space(20));

  sRetAux:= '';
  While (sRetAux <> '00') Do
  Begin
    f_SEObtemSenha(pSenha,pStatus);
    sRetAux := String(pStatus);
    sRetorno:= String(pSenha);
    {Se apertou Corrige}
    If ( Trim(sRetAux) = '09')  Then
    Begin
      sRetorno:= '#'+sRetAux;
      result := '1|' + sRetorno;
      Exit;
    End;
  End;

  iTamanho:= StrToInt(Copy(sRetorno,1,2));
  sRetorno:= Copy(sRetorno,3,iTamanho);

  StrDispose(pStatus);
  StrDispose(pTrilha2);
  StrDispose(pMsgEnv);
  StrDispose(pWork);
  StrDispose(pSenha);
  result := '0|' + sRetorno;
end;

//----------------------------------------------------------------------------
initialization
  RegistraPinPad( 'VERIFONE SC552 CHIP'  , TPinPad_SC552_CHIP, 'BRA' );
  RegistraPinPad( 'VERIFONE SC5000 CHIP' , TPinPad_SC552_CHIP, 'BRA' );
  RegistraPinPad( 'DIONE SOLO 2005 CHIP' , TPinPad_SC552_CHIP, 'BRA' );
  RegistraPinPad( 'SCHL.MAGIC 1800 CHIP' , TPinPad_SC552_CHIP, 'BRA' );
  RegistraPinPad( 'GERTEC PPC-800 CHIP'  , TPinPad_SC552_CHIP, 'BRA' );
  RegistraPinPad( 'GERTEC PPC-900 CHIP'  , TPinPad_SC552_CHIP, 'BRA' );
  RegistraPinPad( 'INGENICO I3500 CHIP'  , TPinPad_SC552_CHIP, 'BRA' );
  RegistraPinPad( 'INGENICO 3070 CHIP'   , TPinPad_SC552_CHIP, 'BRA' );


  //----------------------------------------------------------------------------
end.
