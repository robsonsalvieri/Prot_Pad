unit DisplayTorGertec;

interface
Uses
  Dialogs, LeitorMain, Windows, SysUtils, classes, LojxFun, Forms, CommInt,
  syncobjs, Messages, DisplayTorMain, Sndkey32;

Type
  vetor20 = array[1..20] of byte;
  TGertecTorDisplay = class(TDispTor)
  public
    function Abrir( sPorta:String ):String; override;
    function Fechar( sPorta:String ):String; override;
    function Escrever( Texto:String ): String; override;
    function Limpa( ) : String;
    function Posiciona( iColuna, iLinha : Integer ) : String;
  end;
implementation
var
  fHandle : THandle;
  fOpenDisplay : function( Porta:Byte; BaudRate:Integer; ByteSize, Parity, StopBits:Byte; var ErrMsg:Pchar ): Boolean; far;
  fSetTimeOut  : function( TimeOut:Integer ) : Boolean; far;
  fCloseDisplay: procedure; far;
  fSerialTransm: function( DadosTx: vetor20; NBytesATransmitir: Integer; var NBytesTransmitidos: Integer):Boolean; far;

Function TGertecTorDisplay.Abrir( sPorta : String ) : String;
  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ' + 'wiser.dll');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  bFunc : Boolean;
  pErro : Pchar;
begin
  Result   := '0';
  pErro    := '';
  fHandle := LoadLibrary('wiser.dll');
  if (fHandle <> 0) Then
  begin
    bRet := True;

    aFunc := GetProcAddress(fHandle,'AbrirAPortaSerial');
    if ValidPointer( aFunc, 'AbrirAPortaSerial' ) then
      fOpenDisplay := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'SerialSetTimeOut');
    if ValidPointer( aFunc, 'SerialSetTimeOut' ) then
      fSetTimeOut := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'FecharAPortaSerial');
    if ValidPointer( aFunc, 'FecharAPortaSerial' ) then
      fCloseDisplay := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'SerialTransmite');
    if ValidPointer( aFunc, 'SerialTransmite' ) then
      fSerialTransm := aFunc
    else
      bRet := False;
    end
  else
  begin
    ShowMessage('O arquivo wiser.dll não foi encontrado.');
    bRet := False;
  end;

  if bRet then
    bFunc := fOpenDisplay( StrToInt( Copy( sPorta, 4, 1 ) ), 9600, 8, 0, 0, pErro )
    //bFunc := fOpenDisplay( 1, 9600, 8, 0, 0, pErro )
  else
    bRet := False;

  if Not bRet then
    Result := '1|';
end;

Function TGertecTorDisplay.Fechar( sPorta : String ) : String;
Begin
  fCloseDisplay;
  Result := '0';
end;

Function TGertecTorDisplay.Escrever( Texto : String ) : String;
Var
  sAux : String;
  iTam : Integer;
  iEle : Integer;
  aEnvio : Vetor20;
  iTrans : Integer;
  bRet : Boolean;
Begin
  bRet := False;
  iTrans := 0;
  sAux := Texto;
  iTam := Length( sAux );
  Result := '1';


  Limpa();

  If iTam > 90 then
    iTam := 90;

  If iTam <= 20 then
  Begin
    For iEle := 0 To iTam Do
      aEnvio[iEle] := Ord( sAux[iEle] );
    bRet := fSerialTransm( aEnvio, iTam, iTrans );
  End
  Else
  Begin
    While Trim( sAux ) <> '' Do
    Begin
      For iEle := 0 To 20 Do
       aEnvio[iEle] := Ord( sAux[iEle] );
      bRet := fSerialTransm( aEnvio, iEle, iTrans );
      If bRet Then
      Begin
        Posiciona( 1, 2 );
        sAux := Copy( sAux, 21, Length( sAux ) );
        If Length( sAux ) < 20 then
          sAux := sAux + Replicate( ' ', 20 - Length( sAux ) );
        iTam := Length( sAux );
      End;
    End;
  End;
End;

Function TGertecTorDisplay.Limpa( ) : String;
Var
  aEnvio : vetor20;
  bRet : Boolean;
  iTrans : Integer;
Begin
  // Limpa o display
  aEnvio[1] := $C;
  bRet := fSerialTransm(aEnvio,1,iTrans);
End;

Function TGertecTorDisplay.Posiciona( iColuna, iLinha : Integer ): String;
Var
  aEnvio : vetor20;
  bRet : Boolean;
  iTrans : Integer;
Begin
  If iColuna > 2 then
    ShowMessage( 'Dimensão máxima para coluna é 2.' );
  if iLinha > 20 then
    ShowMessage( 'Dimensão máxima para linha é 20.' );

  aEnvio[1] := $09;
  aEnvio[2] := iColuna;
  aEnvio[3] := iLinha;

  bRet := fSerialTransm(aEnvio,3,iTrans);

End;


initialization
RegistraDispTor( 'Display Torre Gertec', TGertecTorDisplay, 'BRA' );

end.




