unit ImpChSchalter;

interface

Uses
  Dialogs,
  ImpCheqMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms,
  CommInt;

Type
  TSchalter = class(TCustomComm)
  protected
      procedure Comm1RxChar(Sender: TObject; Count: Integer);
      procedure Comm1Error(Sender: TObject; Errors: Integer);
  public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;
////////////////////////////////////////////////////////////////////////////////
  TImpChSchalter = class(TImpressoraCheque)
  public
    function Abrir( aPorta:String ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta:String ): Boolean; override;
    function StatusCh( Tipo:Integer ):String; override;
  end;

  function EnviaComando(sCmd:String): String;
//----------------------------------------------------------------------------
implementation
//----------------------------------------------------------------------------
var
  Comm1 : TSchalter;
  sRetorno : String;
  bRet : Boolean;

//------------------------------------------------------------------------------
constructor TSchalter.Create(AOwner: TComponent);
begin
  inherited;
end;

//------------------------------------------------------------------------------
destructor TSchalter.Destroy;
begin
  inherited;
end;
//------------------------------------------------------------------------------
Function TImpChSchalter.Abrir( aPorta: String ) : Boolean;
begin
  Comm1 := TSchalter.Create(Application);
  Comm1.OnRxChar := Comm1.Comm1RxChar;
  Comm1.BaudRate := br9600;
  Comm1.Databits := da8;
  Comm1.Parity   := paNone;
  Comm1.StopBits := sb10;
  Comm1.DeviceName := aPorta;
  try
    //Abre a porta serial
    Comm1.Open;
    Comm1.SetRTSState(True);
    Comm1.SetDTRState(True);
    Comm1.SetBREAKState(False);
    Comm1.SetXONState(True);
    result := True;
  except
    result := False;
  end;
end;
//---------------------------------------------------------------------------
function TImpChSchalter.Fechar( aPorta:String ) : Boolean;
begin
 //Fecha porta serial
  Comm1.Close;
  Comm1.Free;
  result := True;
end;
//---------------------------------------------------------------------------
function TImpChSchalter.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sRet   : String;
  iLinha : Integer;
  nX     : Integer;
  sCmd   : String;
  sLinha : String;
  sData  : String;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  EnviaComando(  PChar( chr(27)+ 'b' + Banco));
  EnviaComando(  PChar( chr(27)+ 'c' + Trim(Cidade)) + '$');
  EnviaComando(  PChar( chr(27)+ 'd' + Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,3,2)));
  EnviaComando(  PChar( chr(27)+ 'f' + Favorec+ '$'));
  EnviaComando(  PChar( chr(27)+ 'v' + Valor + '$'));

  // Laço para imprimir dados do verso - Aceita somente 3 linha de 70 caracter
  iLinha := 1;
  sCmd:='';
  sRet:=StrPas(Verso);
  while ( Trim(sRet)<>'' ) and ( iLinha<12 ) do
    Begin
    sLinha:='';
    // Laço para pegar 40 caracter do Texto
    for nX:= 1 to 70 do
      Begin
      // Caso encontre um CHR(10) (enter);imprima
      If Copy(sRet,nX,1)= #10 then
         Break;

      sLinha:=sLinha+Copy(sRet,nX,1);
      end;
      sLinha:=Space(10)+Copy(sLinha+space(70),1,70)+Chr(10);
      sCmd:=sCmd+sLinha;
      If Copy(sRet,nX,1)=#10 then
         sRet:=Copy(sRet,nX+1,Length(sRet))
      Else
         sRet:=Copy(sRet,nX,Length(sRet));

      inc(iLinha);
    End;

  If Trim(sCmd)<> '' then
     Begin
     sCmd:=sCmd+Chr(12);
     EnviaComando( sCmd);
     End;
  result := True;
end;

//----------------------------------------------------------------------------
function TImpChSchalter.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpChSchalter.StatusCh( Tipo:Integer ):String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
  
end;

//---------------------------------------------------------------------------
function EnviaComando(sCmd:String): String;
begin
  sretorno:='';
  Comm1.Write(sCmd[1],Length(sCmd));
  result:='';
end;
//---------------------------------------------------------------------------
procedure TSchalter.Comm1RxChar(Sender: TObject; Count: Integer);
var
  Buffer  : array[0..1024] of Char;
  Bytes, P: Integer;
  bInic   : Boolean;

begin
  if trim(sRetorno)='' then
    bInic:= false
  else
    bInic:= True;

  Fillchar(Buffer, Sizeof(Buffer), 0);
  Bytes := Comm1.Read(Buffer, Count);
  if Bytes = -1 then
    ShowMessage('Erro de leitura da resposta do comando')
  else
  begin
    for P := 0 to Bytes do
      case Buffer[P] of
        #10: begin
               // Memo2.Lines.add('');
               // Inc(FCurrentLine);
             end;
        #03: begin
             bRet:= True;
             Break;
             end;
        #02: begin
             bInic:= True;
             end;
        #0: begin
            Break;
            end;

        #13:;
         else
           begin
              if bInic then
                sRetorno:=sRetorno+Buffer[P];
           end;
      end;
  end;
end;
//----------------------------------------------------------------------------
procedure TSchalter.Comm1Error(Sender: TObject; Errors: Integer);
//Mensagem de erro do Componente.
begin
  if (Errors and CE_BREAK > 0) then
    ShowMessage('The hardware detected a break condition.');
  if (Errors and CE_DNS > 0) then
    ShowMessage('Windows 95 only: A parallel device is not selected.');
  if (Errors and CE_FRAME > 0) then
    ShowMessage('The hardware detected a framing error.');
  if (Errors and CE_IOE > 0) then
    ShowMessage('An I/O error occurred during communications with the device.');
  if (Errors and CE_MODE > 0) then
  begin
    ShowMessage('The requested mode is not supported, or the hFile parameter'+
                 'is invalid. If this value is specified, it is the only valid error.');
  end;
  if (Errors and CE_OOP > 0) then
    ShowMessage('Windows 95 only: A parallel device signaled that it is out of paper.');
  if (Errors and CE_OVERRUN > 0) then
    ShowMessage('A character-buffer overrun has occurred. The next character is lost.');
  if (Errors and CE_PTO > 0) then
    ShowMessage('Windows 95 only: A time-out occurred on a parallel device.');
  if (Errors and CE_RXOVER > 0) then
  begin
    ShowMessage('An input buffer overflow has occurred. There is either no'+
                'room in the input buffer, or a character was received after'+
                'the end-of-file (EOF) character.');
  end;
  if (Errors and CE_RXPARITY > 0) then
    ShowMessage('The hardware detected a parity error.');
  if (Errors and CE_TXFULL > 0) then
  begin
    ShowMessage('The application tried to transmit a character, but the output'+
                 'buffer was full.');
  end;

end;
//----------------------------------------------------------------------------
initialization
  RegistraImpCheque('SCHALTER NSC 2.00',TImpChSchalter, 'BRA' );
end.
