unit PinPad_SC552;

interface

Uses
  Dialogs, PinPadMain, Windows, SysUtils, Classes, LojxFun, Forms;


Type
  TPinPad_SC552 = class(TPinPad)
  private
    fHandle : THandle;
    f_SESolicitaCartao : Procedure (pStatus: PChar); StdCall;
    f_SEObtemTrilha1_2 : Procedure (pTrilha1:PChar; pTrilha2:PChar; pStatus: PChar); StdCall;
    f_SESolicitaSenhaDedicado : Procedure  (pTrilha2: PChar; pMsgEnvPin: PChar; pWork: PChar; pStatus: PChar); StdCall;
    f_SEObtemSenha : Procedure (pSenha: PChar; pStatus: PChar); StdCall;
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
function TPinPad_SC552.Abrir(sPorta : String) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: SITPIN32.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
begin
  fHandle := LoadLibrary( 'SITPIN32.DLL' );
  if (fHandle <> 0) Then
  begin
    bRet := True;

    aFunc := GetProcAddress(fHandle,'SESolicitaCartao');
    if ValidPointer( aFunc, 'SESolicitaCartao' ) then
      f_SESolicitaCartao := aFunc
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
    ShowMessage('O arquivo SITPIN32.DLL não foi encontrado.');
    bRet := False;
  end;

  if bRet then
    result := '0'
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
function TPinPad_SC552.Fechar : String;
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
function TPinPad_SC552.LeCartao(sModalidade:String):String;
var
  sRetAux : String;
  pStatus : PChar;
  pTrilha1 : PChar;
  pTrilha2 : PChar;
  dtHoraInicio : TDateTime;
  iTimeOut : Integer;
  sRetorno : String;
begin
           dtHoraInicio := Now;
           iTimeOut := 60000;
           pStatus:= StrAlloc(3);
           StrPCopy(pStatus, Space(2));
           sRetAux := '';
           While (sRetAux <> '00') Do Begin
              f_SESolicitaCartao(pStatus);
              sRetAux:= StrPas(pStatus);
              If (Now > (dtHoraInicio + iTimeOut * (1/24/60/60/1000))) Then
                  sRetAux:= '00';
           End;

           pTrilha2:= StrAlloc(41);
           pTrilha1:= StrAlloc(81);
           StrPCopy(pStatus, Space(2));
           StrPCopy(pTrilha1, Space(80));
           StrPCopy(pTrilha2, Space(40));

           sRetAux:= '';
           While (sRetAux <> '00') Do Begin
              f_SEObtemTrilha1_2(pTrilha1,pTrilha2,pStatus);
              sRetAux := String(pStatus);
              If (Now > (dtHoraInicio + iTimeOut * (1/24/60/60/1000))) Then Begin
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

           result := '0|' + sRetorno;

end;

//----------------------------------------------------------------------------
function TPinPad_SC552.LeSenha( sTrilha2,sMsg,sWork:String ):String;
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
                       f_SESolicitaSenhaDedicado(pTrilha2,pMsgEnv,pWork,pStatus);
                       sRetAux := StrPas(pStatus);
                    End;

                    pSenha:= StrAlloc(21);
                    StrPCopy(pStatus, Space(2));
                    StrPCopy(pSenha , Space(20));

                    sRetAux:= '';
                    While (sRetAux <> '00') Do Begin
                       f_SEObtemSenha(pSenha,pStatus);
                       sRetAux := String(pStatus);
                       sRetorno:= String(pSenha);

                       {Se apertou Corrige}
                       If (Copy(Trim(sRetorno),1,3) = '01?') Then
                          Begin
                             sRetAux:= '';
                             sRetorno:= '';
                             StrPCopy(pStatus, Space(2));
                             StrPCopy(pSenha , Space(20));

                             While (sRetAux <> '00') Do Begin
                                f_SESolicitaSenhaDedicado(pTrilha2,pMsgEnv,pWork,pStatus);
                                sRetAux := StrPas(pStatus);
                             End;
                             sRetAux:= '';
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
  RegistraPinPad( 'VERIFONE SC552', TPinPad_SC552, 'BRA' );

//----------------------------------------------------------------------------
end.
