unit ImpPertoPay;

interface

Uses
  Dialogs,
  ImpCheqMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms;

Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque PertoPay
///
  TImpChequePertoPay = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Procedure LstError;
function EnviaComando( sCmd: PChar; var sMsg: AnsiString) : Boolean;

//----------------------------------------------------------------------------
implementation

var
bOpened   : Boolean;
sDLL      : AnsiString;
fHandle   : HINST;
iR        : Integer;
aListError: Array[1..45] of String[77];

fProcessaComando  :function (lpszComand,lpszResp: PChar): integer; stdcall;
fIniciaPorta      :function (lpszPort : PChar):integer; stdcall;
fFechaPorta       :function : integer;  stdcall ;
fProcessFiscalCmd :function (lpBufferTx :PChar; nLenTx: cardinal;
                             lpBufferRx :PChar; var nLenRx :cardinal;
                             chTimeOut :byte; bFlow :LongBool) :integer; stdcall ;
////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque PertoChek
///
Function TImpChequePertoPay.Abrir( aPorta: AnsiString ) : Boolean;
  Function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na DLL: '+sDLL);
      Result := False;
    end
    else
      Result := True;
  end;

Var
  aFunc: Pointer;
  bRet : Boolean;
  pBuffer: pChar;
  aVeloc  : array[0..3] of PChar;
  nI      : Integer;
Begin
  If bOpened Then
    Begin
    Result := True;
    Exit;
    End;
  aVeloc[0]:='9600';
  aVeloc[1]:='4800';
  aVeloc[2]:='2400';
  aVeloc[3]:='1200';
  bOpened := False;

  sDLL := 'PERTOPAY.DLL';
  fHandle := LoadLibrary( pChar(sDLL) );
  if (fHandle <> 0) Then
  begin
    bRet := True;
    aFunc := GetProcAddress(fHandle,'ProcessaComando');
    if ValidPointer( aFunc, 'ProcessaComando' ) then
      fProcessaComando:= aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'IniciaPorta');
    if ValidPointer( aFunc, 'IniciaPorta' ) then
      fIniciaPorta:= aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'FechaPorta');
    if ValidPointer( aFunc, 'FechaPorta' ) then
      fFechaPorta:= aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'ProcessFiscalCmd');
    if ValidPointer( aFunc, 'ProcessFiscalCmd' ) then
      fProcessFiscalCmd:= aFunc
    else
      bRet := False;

  end
  else
  begin
    ShowMessage('O arquivo '+sDLL+' não foi encontrado.');
    bRet := False;
  end;

  if bRet then
  Begin
    pBuffer := StrAlloc(16);
    For nI:= 0 to 3 do
    Begin
      StrNew(pBuffer);
      StrPCopy(pBuffer, aPorta);
      StrCat(pBuffer, PChar(':'+aVeloc[nI]+',N,8,1'));
      {Comando que inicializa a porta do PC, com os
       seguintes parâmetros: - porta utilizada
                        - baud rate
                        - paridade(N,O,P)
                        - data bit(7,8)
                        - Stop bit(1,2)  }
      iR:= fIniciaPorta(pBuffer);
      //iR:= fIniciaPorta('COM1:9600,N,8,1');
      If iR = 1 Then
         Begin
         bRet:=True;
         Break;
         End
      Else
         Begin
         bRet:=False;
         iR:=fFechaPorta;
         End;
    End;
    StrDispose(pBuffer);
    if bRet then
      Begin
      bOpened := True;
      Result  := True;
      LstError;
      End
    Else
    Begin
      ShowMessage('Erro na abertura da porta');
      Result := True;
    End;
  end
  else
    Result := False;
End;
//----------------------------------------------------------------------------
Function TImpChequePertoPay.Fechar( aPorta:AnsiString ) : Boolean;
Begin
  Result := (fFechaPorta= 0);
End;

//----------------------------------------------------------------------------
Function TImpChequePertoPay.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sValor  : AnsiString;
  sData   : AnsiString;
  sMsg    : AnsiString;
  pValor  : PChar;
  pFav    : PChar;
  pCidade : PChar;
  pData   : PChar;
  pVerso  : PChar;
  sRet    : AnsiString;
  sVerso  : AnsiString;
  iLinha,nX : Integer;
  sLinha  : AnsiString;
  nTam    : Integer;
  sAux    : AnsiString;
Begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  pValor  := StrAlloc( 17);
  pFav    := StrAlloc( 50);
  pCidade := StrAlloc( 21);
  pData   := StrAlloc(  9);

  FillChar(pValor^,17,0);
  FillChar(pFav^,50,0);
  FillChar(pCidade^,21,0);
  FillChar(pData^,9,0);

  sData  := Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,3,2);
  sValor := FormataTexto(Valor, 12, 2, 2);
  sMsg := StrPas(Mensagem)+space(20);

  sVerso := '';

  Verso    := pChar( UpperCase(LimpaAcentuacao(Verso)));
  iLinha := 0;
  While Trim( Verso ) <> '' Do
  Begin
    nTam := Pos( #10, Verso );
    If nTam = 0 Then
      nTam := 78;

    If nTam > 78 then
    Begin
      nTam := 78;
      sAux := Copy( Verso, 1, nTam ) + #255;
    End
    else
      sAux := Copy( Verso, 1, nTam - 1 ) + #255;

    iLinha := iLinha + 1;

    Verso := pChar( Copy( StrPas( Verso ), nTam + 1, Length( Verso ) ) );
    sVerso := sVerso + sAux;
  End;

  If iLinha < 14 Then
    sVerso := sVerso + Replicate( #255, 14 - iLinha );

  StrPCopy(pValor,  '$0'+sValor+Banco);
  StrPCopy(pFav,    '%'+copy(Favorec,1,49));
  StrPCopy(pCidade, '#'+Copy(Cidade,1,20));
  StrPCopy(pData,   '!'+Copy(sData,1,8));
  pVerso:= Pchar( 'X' + sVerso);
  Mensagem:= Pchar(':'+Copy(sMsg,1,19));


  Result:= false;
  // Altera Data
  EnviaComando(pData,sRet);
  // Altera a Cidade
  EnviaComando(pCidade,sRet);
  // Altera Favorecido
  EnviaComando(pFav,sRet);
  // Altera Campo Extra
  EnviaComando(Mensagem,sRet);
  // Imprime o Cheque
  if EnviaComando(pValor,sRet) then
     Begin
     Result:= True;
     If Length(Trim(Copy(pVerso,2,60))) > 0 then
        Begin
        sRet := '';
        if EnviaComando( pVerso , sRet) then
           Result:= True;
     End;
  End;

StrDispose(pValor);
StrDispose(pFav);
StrDispose(pCidade);
StrDispose(pData);
End;

//----------------------------------------------------------------------------
function TImpChequePertoPay.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequePertoPay.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
  
end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenPerto( sPorta:AnsiString ) : AnsiString;
Begin
End;

//----------------------------------------------------------------------------
function EnviaComando( sCmd: PChar; var sMsg: AnsiString) : Boolean;
var
  Resp     : Array[0..1024] Of Char;
  i,x      : Integer;
begin
  For x:= 1 to 2 do
     Begin
     Result:=True;
     iR:=fProcessaComando(sCmd,Resp);
     If iR = 0 then
        Begin
        For i := 1 To 45 Do
            Begin
            If Copy(Resp,1,3) = Copy(aListError[i],1,3) then
               Begin
               Result:=False;
               MessageDlg(aListError[i], mtError, [mbOk], 0);
               // Se o cheque ficou preso, Envia '>' para libera-lo.
               If ( (StrToInt(Copy(Resp,2,3)) >= 20) And (StrToInt(Copy(Resp,2,3)) <= 27)) or ( Copy(Resp,2,3)='011') Then
                  Begin
                  iR:=fProcessaComando('>',Resp);
                  ShowMessage('Retire o documento');
                  End;
               Break;
               End;
            End;
        End
     Else
        Break;
  End;
End;
//----------------------------------------------------------------------------
Function ClosePerto : AnsiString;
Begin
  fFechaPorta;
  If bOpened And (fHandle <> 0) Then
  Begin
    Sleep(1000);
    FreeLibrary(fHandle);
    fHandle := 0;
    bOpened := False;
  End;
  Result := '0'
End;

//----------------------------------------------------------------------------
Procedure LstError;
Begin
  //Lista dos retorno de erros
  aListError[ 1] := '001 - Mensagem com dados Invalidos';
  aListError[ 2] := '000  - Sucesso na execução do comando.';
  aListError[ 3] := '001  - Mensagem com dados inválidos.';
  aListError[ 4] := '002  - Tamanho de mensagem inválido.';
  aListError[ 5] := '005  - Leitura dos caracteres magnéticos inválida.';
  aListError[ 6] := '006  - Problemas no acionamento do motor 1.';
  aListError[ 7] := '008  - Problemas no acionamento do motor 2.';
  aListError[ 8] := '009  - Banco diferente do solicitado.';
  aListError[ 9] := '011  - Sensor 1 obstruído.';
  aListError[10] := '012  - Sensor 2 obstruído.';
  aListError[11] := '013  - Sensor 4 obstruído.';
  aListError[12] := '014  - Erro o posicionamento da cabeça de impressão (relativo a S4).';
  aListError[13] := '015  - Erro o posicionamento na pós-marcação.';
  aListError[14] := '016  - Dígito verificador do cheque não confere.';
  aListError[15] := '017  - Ausência de caracteres magnéticos ou cheque na posição errada.';
  aListError[16] := '018  - Tempo esgotado.';
  aListError[17] := '019  - Documento mal inserido.';
  aListError[18] := '020  - Cheque preso durante o alinhamento (S1 e S2 desobstruídos).';
  aListError[19] := '021  - Cheque preso durante o alinhamento (S1 obstruído e S2 desobstruído).';
  aListError[20] := '022  - Cheque preso durante o alinhamento (S1 desobstruído e S2 obstruído).';
  aListError[21] := '023  - Cheque preso durante o alinhamento (S1 e S2 obstruídos).';
  aListError[22] := '024  - Cheque preso durante o preenchimento (S1 e S2 desobstruídos).';
  aListError[23] := '025  - Cheque preso durante o preenchimento (S1 obstruído e S2 desobstruído).';
  aListError[24] := '026  - Cheque preso durante o preenchimento (S1 desobstruído e S2 obstruído).';
  aListError[25] := '027  - Cheque preso durante o preenchimento (S1 e S2 obstruídos).';
  aListError[26] := '028  - Caracter inexistente.';
  aListError[27] := '030  - Não há cheques na memória.';
  aListError[28] := '031  - Lista negra interna cheia.';
  aListError[29] := '042  - Cheque ausente.';
  aListError[30] := '043  - Pin pad ou teclado ausente.';
  aListError[31] := '050  - Erro de transmissão.';
  aListError[32] := '051  - Erro de transmissão: Impressora off line, desconectada ou ocupada.';
  aListError[33] := '052  - Erro no pin pad.';
  aListError[34] := '060  - Cheque na lista negra.';
  aListError[35] := '073  - Cheque não encontrado na lista negra.';
  aListError[36] := '074  - Comando cancelado.';
  aListError[37] := '084  - Arquivo de lay out´s cheio.';
  aListError[38] := '085  - Lay out inexistente na memória.';
  aListError[39] := '091  - Leitura de cartão inválida.';
  aListError[40] := '097  - Cheque na posição errada.';
  aListError[41] := '111  - Pin pad não retornou EOT.';
  aListError[42] := '150  - Pin pad não retornou NAK.';
  aListError[43] := '155  - Pin pad não responde.';
  aListError[44] := '171  - Tempo esgotado na resposta do pin pad.';
  aListError[45] := '255  - Comando inexistente.';
End;
//----------------------------------------------------------------------------
(*initialization
   RegistraImpCheque('PERTOPAY', TImpChequePertoPay, 'BRA' );*)
end.
//----------------------------------------------------------------------------

