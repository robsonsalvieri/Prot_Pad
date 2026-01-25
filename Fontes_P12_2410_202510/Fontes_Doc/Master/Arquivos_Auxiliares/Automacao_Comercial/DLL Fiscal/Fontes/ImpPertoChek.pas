unit ImpPertoChek;

interface

Uses
  Dialogs,
  IniFiles,
  CMC7Main,
  ImpCheqMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms;

Type

////////////////////////////////////////////////////////////////////////////////
///  CMC7 PertoChek
///
  TCMC7_Perto = class(TCMC7)
  public
    function Abrir( sPorta, sMensagem:String ): String; override;
    function Fechar: String; override;
    function LeDocumento:String; override;
    function LeDocCompleto:String; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque PertoChek
///
  TImpChequePerto = class(TImpressoraCheque)
  public
    function Abrir( aPorta:String ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta:String ): Boolean; override;
    function StatusCh( Tipo:Integer ):String; override;

  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenPerto( sPorta:String ) : String;
Function ClosePerto : String;
Function RetOK( iRet:Integer ) : Boolean;
function EnviaComando( sCmd: PChar; var sMsg: String) : Boolean;

//----------------------------------------------------------------------------
implementation

var fHandle : HINST;
    bOpened : Boolean;
    sDLL : String;
    aListError: Array[1..37] of String[75];
    IniComm : Function (IpszParam:PChar) : Boolean; StdCall;
    EndComm : Function : Boolean; StdCall;
    EnvComm : Function (IpszBuf:PChar) : Integer; StdCall;
    RecComm : Function (nTimeOut:Integer; IpszBuf:PChar) : Integer; StdCall;

////////////////////////////////////////////////////////////////////////////////
///  CMC7 PertoChek
///
Function TCMC7_Perto.Abrir( sPorta, sMensagem: String ) : String;
Begin
  Result := OpenPerto(sPorta);
End;

//----------------------------------------------------------------------------
Function TCMC7_Perto.Fechar : String;
Begin
  Result := ClosePerto;
End;

//---------------------------------------------------------------------------
function TCMC7_Perto.LeDocumento : String;
var
  sRet : String;

begin
  If Not EnviaComando('=',sRet) Then
    Result := '1|'
  Else
    // Padronizar o Retorno Com o CMC7 Bematech
    // Banco / Agencia / Compensacao / NumCheque /  bXX / Conta
    Result := '0| '+Copy(sRet,1,7)+'  '+Copy(sRet,24,3)+Copy(sRet,18,6)+'   '+Copy(sRet,8,10)+'  ';
  sRet := '';
  Enviacomando('>',sRet);
end;

//---------------------------------------------------------------------------
function TCMC7_Perto.LeDocCompleto : String;
var
  sRet : String;

begin
  If Not EnviaComando('P',sRet) Then
    Result := '1|'
  Else
    // CMC7 - Completo
    Result := '0|'+sRet;
  sRet := '';
  Enviacomando('>',sRet);
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque PertoChek
///
Function TImpChequePerto.Abrir( aPorta: String ) : Boolean;
Begin
  Result := (OpenPerto(aPorta) = '0');
End;

//----------------------------------------------------------------------------
Function TImpChequePerto.Fechar( aPorta:String ) : Boolean;
Begin
  Result := (ClosePerto = '0');
End;

//----------------------------------------------------------------------------
Function TImpChequePerto.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sValor  : String;
  sData   : String;
  sMsg    : String;
  sRet    : String;
  sFav    : String;
  sCidade : String;
  sVerso  : String;
  sVer    : String;
  fArquivo    : TIniFile;
Begin
  if length(Data)=6 then
     sData  := Copy(Data,5,2)+Copy(Data,3,2)+Copy(Data,1,2)
  else
     sData  := Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,3,2);
  sValor := FormataTexto(Valor, 12, 2, 2);
  sMsg := StrPas(Mensagem)+space(20);

// é feita uma verificação (comando V) para identificar se a impressora tem 64K ou 128K de memória,
// essa diferença interfere no comando $ - impressão do cheque. No caso de impressoras com "08"
// na versão de Eprom (64K), não aceitam '$4', apenas '$0'. Impressoras com "35" na versão de Eprom,
// tem 128k de memória.
   sVer := 'V';
   EnviaComando(PChar(sVer),sRet);
   sVer := Copy(sRet,1,Pos(' ',sRet));
   sRet := '';
   If Pos('08',sVer) > 0 then
    sValor := '$0'+sValor+Banco
   Else
   Begin
     //Verificando no SigaLoja.Ini se imprime a chancela ou não. '0' não imprime
     fArquivo := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'SIGALOJA.INI');
     If fArquivo.ReadString('PERTOCHECK','CHANCELA','0') = '0' Then
     Begin
        //Se recebe o ANO com 2 dígitos,imprime com 2 dígitos
       //Se recebe com 4 dígitos, imprime com 4.
       If length(Data)=6 then
         sValor := '$0'+sValor+Banco
       Else
         sValor := '$4'+sValor+Banco;
     End
     Else If fArquivo.ReadString('PERTOCHECK','CHANCELA','0') = '1' Then
     Begin
       //Se recebe o ANO com 2 dígitos,imprime com 2 dígitos
       //Se recebe com 4 dígitos, imprime com 4.
       If length(Data)=6 then
         sValor := '$1'+sValor+Banco
       Else
         sValor := '$5'+sValor+Banco;
     End;
     fArquivo.Free;
   End;

  sFav      :='%'+copy(LimpaAcentuacao(Favorec),1,49);
  sCidade   :='#'+Copy(LimpaAcentuacao(Cidade),1,20);
  sData     :='!'+Copy(sData,1,8);
  sMsg      :=':'+Copy(LimpaAcentuacao(sMsg),1,19);
  sVerso    := UpperCase(LimpaAcentuacao(Verso));

  //Substituído o comando " por X, pois o " imprime apenas duas linhas e com o X até 14

  if Length(sVerso) > 60 //verifica se haverá mais de uma linha
    then begin
        sVerso := Copy (Verso, 1, 60) + Space(14) + #255;
        sVerso := sVerso + Copy (Verso,  61, 60) + Space (14) + #255; //1º linha, com 74 carceteres...
        sVerso := sVerso + Copy (Verso, 121, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 181, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 241, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 301, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 361, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 421, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 481, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 561, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 621, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 681, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 721, 60) + Space (14) + #255;
        sVerso := sVerso + Copy (Verso, 781, 60) + Space (14) + #255; //14º linha

    end
  else
        //mesmo que seja impressa apenas uma linha deverá ser enviado os outros 13 fechamentos
        sVerso  := Copy(Verso,1,74) + Space (74 - Length (Verso)) + #255
                   + #255 + #255 + #255 + #255 + #255 + #255 + #255 + #255
                   + #255 + #255 + #255 + #255 + #255;

  sVerso := 'X'+sVerso;

  Result:= false;

  // Altera Data
  EnviaComando(PChar(sData),sRet);
  // Altera a Cidade
  EnviaComando(PChar(sCidade),sRet);
  // Altera Favorecido
  EnviaComando(PChar(sFav),sRet);
  // Altera Campo Extra
  EnviaComando(PChar(sMsg),sRet);
  // Imprime o Cheque
  if EnviaComando(PChar(sValor),sRet) then
     Begin
     Result:= True;
     If Length(Verso) > 0 then
        Begin
        ShowMessage('Retire o cheque da impressora e tecle <ENTER>');
        sRet := 'Insira o verso do cheque ';
        if EnviaComando(PChar(sVerso), sRet) then
           Result:= True;
        End;
     End;
End;

//----------------------------------------------------------------------------
function TImpChequePerto.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequePerto.StatusCh( Tipo:Integer ):String;
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
Function OpenPerto( sPorta:String ) : String;
  Function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
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
  sCmd    : pChar;
  sRet : String;
Begin
  If bOpened Then
    Begin
    Result := '0';
    Exit;
    End;
  aVeloc[0]:='9600';
  aVeloc[1]:='4800';
  aVeloc[2]:='2400';
  aVeloc[3]:='1200';
  bOpened := False;

  //Lista dos retorno de erros
  aListError[ 1] := '001 - Mensagem com dados Invalidos';
  aListError[ 2] := '002 - Tamanho da mensagem Invalido';
  aListError[ 3] := '005 - Leitura dos caracteres magnéticos invalido';
  aListError[ 4] := '006 - Problemas no acionamento do Motor 1';
  aListError[ 5] := '007 - Documento já pos marcado';
  aListError[ 6] := '008 - Problemas no acionamento do Motor 2';
  aListError[ 7] := '009 - Banco diferente do solicitado';
  aListError[ 8] := '010 - Sensor 3 desobstruido:Fita Magnetica no fim ou ausente';
  aListError[ 9] := '011 - Sensor 1 obstruido';
  aListError[10] := '012 - Sensor 2 obstruido';
  aListError[11] := '013 - Sensor 4 obstruido';
  aListError[12] := '014 - Erro no posicionamento da cabeça de impressão';
  aListError[13] := '015 - Erro no posicionamento na pós marcação';
  aListError[14] := '016 - Digito verificador do cheque não confere';
  aListError[15] := '017 - Ausencia de caracteres magneticos ou cheque na posição errada';
  aListError[16] := '018 - Documento não inserido na máquina';
  aListError[17] := '019 - Documento mal inserido';
  aListError[18] := '020 - Cheque preso durante o alinhamento:S1 e S2 desobstruidos';
  aListError[19] := '021 - Cheque preso durante o alinhamento:S1 obstruido e S2 desobstruido';
  aListError[20] := '022 - Cheque preso durante o alinhamento:S1 desobstruido e S2 obstr.';
  aListError[21] := '023 - Cheque preso durante o alinhamento:S1 e S2 obstruidos';
  aListError[22] := '024 - Cheque preso durante o preenchimento:S1 e S2 desobstruidos';
  aListError[23] := '025 - Cheque preso durante o preenchimento:S1 obstruido e S2 desobs.';
  aListError[24] := '026 - Cheque preso durante o preenchimento:S1 desobstruido e S2 obstr.';
  aListError[25] := '027 - Cheque preso durante o preenchimento:S1 e S2 obstruidos';
  aListError[26] := '028 - Caracter inexistente';
  aListError[27] := '031 - Lista negra interna cheia';
  aListError[28] := '040 - Relogio ausente ou não funcionando';
  aListError[29] := '041 - Maquina sem pos marcação';
  aListError[30] := '042 - Cheque ausente';
  aListError[31] := '050 - Erro de transmissão';
  aListError[32] := '060 - Cheque na lista negra';
  aListError[33] := '073 - Cheque não encontrado na lista negra';
  aListError[34] := '074 - Comando cancelado';
  aListError[35] := '084 - Arquivo de lay-outs cheio';
  aListError[36] := '085 - Lay-out inexistente na memória da PERTOCHEK';
  aListError[37] := '097 - Cheque na posição errada';

  sDLL := 'PERTOCHEKSER.DLL';
  fHandle := LoadLibrary( pChar(sDLL) );
  if (fHandle <> 0) Then
  begin
    bRet := True;
    aFunc := GetProcAddress(fHandle,'IniComm');
    if ValidPointer( aFunc, 'IniComm' ) then
      IniComm := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'EndComm');
    if ValidPointer( aFunc, 'EndComm' ) then
      EndComm := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'EnvComm');
    if ValidPointer( aFunc, 'EnvComm' ) then
      EnvComm := aFunc
    else
      bRet := False;

    aFunc := GetProcAddress(fHandle,'RecComm');
    if ValidPointer( aFunc, 'RecComm' ) then
      RecComm := aFunc
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
    sCmd := 'V';
    For nI:= 0 to 3 do
      Begin
        //StrPCopy(pBuffer, sPorta);
        StrNew(pBuffer);
        StrPCopy(pBuffer, sPorta);
        StrCat(pBuffer, PChar(':'+aVeloc[nI]+',N,8,1'));
        bRet := IniComm( pBuffer );
        if bRet then
          Begin
          If EnviaComando( PChar(sCmd),sRet) Then
             Begin
             bRet:=True;
             Break;
             End
          Else
             Begin
             bRet:=False;
             EndComm();
             End;
          End;
      End;
    StrDispose(pBuffer);
    if bRet then
      Begin
      bOpened := True;
      Result := '0';
      End
    Else
    Begin
      ShowMessage('Erro na abertura da porta');
      Result := '1';
    End;
  end
  else
    Result := '1';
End;

//----------------------------------------------------------------------------
function EnviaComando( sCmd: PChar; var sMsg: String) : Boolean;
var
  i,x      : Integer;
  iRet     : Integer;
  Resp     : Array[0..255] Of Char;
  Retorno  : String;
begin
  For x:=1 to 2 do
     Begin
     Result:=False;
     // Altera Data
     iRet:=EnvComm(sCmd);
     if iRet=1 then
        Begin
        if trim(sMsg)<>'' then
           ShowMessage(sMsg);

        iRet := RecComm(30, Resp);
        if iRet = 1 then
           Begin
           Result  := True;
           Retorno := Copy(StrPas(Resp),2,3);
           if ( sCmd='V' ) and (Copy(StrPas(Resp),1,2)='VF') then
              Retorno:='000';
           sMsg := Copy(Resp,5,Length(Resp)-4);
           If StrToInt(Retorno)>0 Then
              Begin
              For i := 1 To 37 Do
                 If Retorno = Copy(aListError[i],1,3) then
                    Begin
                    Result:=False;
                    MessageDlg(aListError[i], mtError, [mbOk], 0);
                    // Se o cheque ficou preso, Envia '>' para libera-lo.
                    If ( (StrToInt(Copy(Resp,2,3)) >= 20) And (StrToInt(Copy(Resp,2,3)) <= 27)) or ( Copy(Resp,2,3)='011') Then
                       Begin
                       EnvComm('>');
                       ShowMessage('Retire o documento');
                       sMsg :='Insira o documento'
                       End;
                    Break;
                    End;
              End;
           End;
        End;
        If ( Result ) or ( sCmd='V' ) then
           Break;
     End;
End;
//----------------------------------------------------------------------------
Function ClosePerto : String;
Begin
  If bOpened And (fHandle <> 0) Then
  Begin
    EndComm();
    Sleep(1000);
    FreeLibrary(fHandle);
    fHandle := 0;
    bOpened := False;
  End;
  Result := '0'
End;

//----------------------------------------------------------------------------
Function RetOK( iRet:Integer ) : Boolean;
begin
  Result := False;
  If iRet = 0 Then Result := True;
end;
//----------------------------------------------------------------------------
initialization
  RegistraCMC7     ('PERTOCHEK CMC7', TCMC7_Perto, 'BRA' );
  RegistraImpCheque('PERTOCHEK CH', TImpChequePerto, 'BRA' );
end.
//----------------------------------------------------------------------------

