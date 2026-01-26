unit ImpCheqChronos;

interface

uses
  Dialogs,
  ImpCheqMain,
  Windows,
  SysUtils,
  classes,
  LojxFun;

Type

  TImpChequeChronos = class(TImpressoraCheque)
  private
    fHandle: THandle;
    fFuncAbre          : Function (pCom: PChar): Integer; StdCall;
    fFuncAbreEx        : Function (pCom, pVelocidade, pParidade, pDataBit, pStopBit:Integer): Integer; StdCall;
    fFuncFecha         : Function (pCom: Integer ): Integer; StdCall;
    fFuncStatus        : Function (pCom,pStatus: PChar): Integer; StdCall;
    fFuncEjeta         : Function (pCom: PChar): Integer; StdCall;
    fFuncCampoCheque   : Function (pCom,pCampo:Integer;pValCampo: String): Integer; StdCall;
    fFuncImprimeCheque : Function (pCom: Integer): Integer; StdCall;

  public
    function Abrir( aPorta: AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta: AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;

//---------------------------------------------------------------------------
implementation

Var
 idPorta: Integer;

//---------------------------------------------------------------------------
function TImpChequeChronos.Abrir( aPorta:AnsiString ): Boolean;

  function ValidPointer( aPointer: Pointer; aMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+aMsg+'" não existe na Dll: CHRON32.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc      : Pointer;
  nRet       : Integer;
  //iPorta     : Integer;
  iVelocidade: Integer;
  iParidade  : Integer;
  idataBit   : Integer;
  iStopBit   : Integer;

  begin
  fHandle := LoadLibrary( 'CHRON32.DLL' );
  if (fHandle <> 0) Then
  begin
    aFunc := GetProcAddress(fHandle,'PLUS_Abre');
    if ValidPointer( aFunc, 'PLUS_Abre' ) then
      fFuncAbre := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'PLUS_AbreEx');
    if ValidPointer( aFunc, 'PLUS_AbreEx' ) then
      fFuncAbreEx := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'PLUS_Fecha');
    if ValidPointer( aFunc, 'PLUS_Fecha' ) then
      fFuncFecha := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'PLUS_Status');
    if ValidPointer( aFunc, 'PLUS_Status' ) then
      fFuncStatus := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'PLUS_Ejeta');
    if ValidPointer( aFunc, 'PLUS_Ejeta' ) then
      fFuncEjeta := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'PLUS_CampoCheque');
    if ValidPointer( aFunc, 'PLUS_CampoCheque' ) then
      fFuncCampoCheque := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'PLUS_ImprimeCheque');
    if ValidPointer( aFunc, 'PLUS_ImprimeCheque' ) then
      fFuncImprimeCheque := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    Result := True;
  end
  else
  begin
    Result := False;
    Exit;
  end;

  if Result then
  begin

    idPorta    := StrToInt(Copy(aPorta,4,1));
    iVelocidade:= 9600;
    iParidade  := 0;
    idataBit   := 8;
    iStopBit   := 1;

    nRet:=fFuncAbreEx(idPorta, iVelocidade, iParidade, iDataBit, iStopBit);
    if nRet <> 1 then
      ShowMessage('Erro na abertura da porta');
  end;

end;
//---------------------------------------------------------------------------
function TImpChequeChronos.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sData   : AnsiString;
  nRet    : Integer;
  sErro   : AnsiString;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  sData  := Copy(Data,7,2)+'/'+Copy(Data,5,2)+'/'+Copy(Data,3,2);
  //sValor := FormataTexto(Valor, 15, 2, 3, '.');
  sErro   :='';
  if fFuncCampoCheque(idPorta,0,Favorec)<>1 then
     sErro:=sErro+'FAVORECIDO';
  if fFuncCampoCheque(idPorta,1,Cidade)<>1 then
     sErro:=sErro+'/LOCALIDADE';
  If fFuncCampoCheque(idPorta,2,Banco)<>1 Then
     sErro:=sErro+'/BANCO';
  if fFuncCampoCheque(idPorta,3,Valor)<>1 then
     sErro:=sErro+'/VALOR';
  if fFuncCampoCheque(idPorta,4,sData)<>1 then
     sErro:=sErro+'/DATA';

  If trim(sErro)<>'' then
     Begin
     Result:=false;
     Exit;
     End;

  nRet:= fFuncImprimeCheque(idPorta);
  if nRet <> 0 then
    Result := True
  else
    Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequeChronos.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//---------------------------------------------------------------------------
function TImpChequeChronos.Fechar( aPorta:AnsiString ): Boolean;
Var
  nRet: Integer;
Begin
   nRet:=fFuncFecha(idPorta);
  if nRet <> 0 then
    Result := True
  else
    Result := False;
End;

//----------------------------------------------------------------------------
function TImpChequeChronos.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';

end;

(*Initialization
  RegistraImpCheque('CHRONOS 31100'  , TImpChequeChronos, 'BRA');*)
end.

