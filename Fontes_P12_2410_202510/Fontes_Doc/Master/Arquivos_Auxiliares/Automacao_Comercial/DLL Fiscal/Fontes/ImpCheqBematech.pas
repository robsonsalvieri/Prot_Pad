unit ImpCheqBematech;

interface

uses
  Dialogs,
  ImpCheqMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  IniFiles;

const
  BufferSize      = 1024;
  DLL_COMANDO_OK  = 1;
  ERRO_OPEN_FILE  = -1;

Type

  //A DLL de comunicacao com as Impressoras de Cheque Bematech foi trocada de DP1032.DLL
  //para BemaDP32.DLL

  TImpChequeBematechDP10 = class(TImpressoraCheque)
  private
    fHandle: THandle;
    fFuncImprimeCheque          : Function (sBanco, sValor, sFavor, sCidad, sData, sMsg: string): Integer; StdCall;
    fFuncImprimeChequeTransf    : Function ( sBanco, sValor, sCidade, sData, sAgencia, sConta, sMensagem:String ):Integer; StdCall;
    fFuncIniciaPorta            : Function (pCom: PChar): Integer; StdCall;
    fFuncFechaPorta             : Function ():Integer; StdCall;
    fFuncImprimeTexto           : Function (Texto: string; AvancaLinha: integer): integer; stdcall;
    fFuncTravaDocumento         : Function (Trava: integer): integer; stdcall;
   public
    function Abrir( aPorta: String ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta: String ): Boolean; override;
    function StatusCh( Tipo:Integer ):String; override;
  end;

  TImpChequeBematechDP20 = class(TImpChequeBematechDP10)
  end;

var
  sPorta : String;
  bOpened : Boolean = False;
//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
function TImpChequeBematechDP10.Abrir( aPorta:String ): Boolean;

  function ValidPointer( aPointer: Pointer; aMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+aMsg+'" não existe na Dll: BemaDP32.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  nRet : Integer;
  pPorta : PChar;
  pPath : PChar;
  sPath : String;
  pTempPath  : PChar;
  sTempPath  : String;
  BufferTemp : Array[0..144] of Char;
begin
  // Verifica se o BEMADP32.INI Existe no Diretório do Windows
  pPath := PChar(Space(100));
  GetWindowsDirectory(pPath, 100);
  sPath := StrPas(pPath);
  if Not FileExists(sPath+'\BEMADP32.INI') then
  begin
    ShowMessage('É necessário que o arquivo BEMADP32.INI esteja no diretório '+sPath+'.');
    Result := False;
    Exit;
  end;

  fHandle := LoadLibrary( 'BemaDP32.DLL' );

  // Indica a possibilidade da utilização
  // via ActiveX portanto faz uma nova verificação.
  // Inicio

  if (fHandle = 0) Then
  begin
    GetTempPath(144,BufferTemp);
    sTempPath := trim(StrPas(BufferTemp))+'BemaDP32.DLL';
    pTempPath := PChar(sTempPath);
    fHandle   := LoadLibrary( pTempPath );
  end;
  // Fim

  if (fHandle <> 0) Then
  begin
    aFunc := GetProcAddress(fHandle,'Bematech_DP_ImprimeCheque');
    if ValidPointer( aFunc, 'Bematech_DP_ImprimeCheque' ) then
      fFuncImprimeCheque := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress( fHandle, 'Bematech_DP_ImprimeChequeTransferencia' );

    if ValidPointer( aFunc, 'Bematech_DP_ImprimeChequeTransferencia' ) then
      fFuncImprimeChequeTransf := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'Bematech_DP_IniciaPorta');
    if ValidPointer( aFunc, 'Bematech_DP_IniciaPorta' ) then
      fFuncIniciaPorta := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'Bematech_DP_FechaPorta');
    if ValidPointer( aFunc, 'Bematech_DP_FechaPorta' ) then
      fFuncFechaPorta := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'Bematech_DP_TravaDocumento');
    if ValidPointer( aFunc, 'Bematech_DP_TravaDocumento' ) then
      fFuncTravaDocumento := aFunc
    else
    begin
      Result := False;
      Exit;
    end;

    aFunc := GetProcAddress(fHandle,'Bematech_DP_ImprimeTexto');
    if ValidPointer( aFunc, 'Bematech_DP_ImprimeTexto' ) then
      fFuncImprimeTexto := aFunc
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
    ShowMessage ('Arquivo "BemaDP32.DLL" não encontrado! '+CHR(13)+
                 'Baixe esse arquivo em "ftp.microsiga.com.br/protheus/dlls_fiscais"');
    Exit;
  end;

  if Result then
  begin
    pPorta := Pchar(Space(4));
    StrPCopy(pPorta, aPorta);
    sPorta := aPorta;
    If bOpened = False then
    Begin
        nRet := fFuncIniciaPorta(pPorta);
    End
    Else
    Begin
        nRet := 1;
    End;

    if nRet <> 1 then
      ShowMessage('Erro na abertura da porta')
    Else
      bOpened := True;
  end;

 
end;

//---------------------------------------------------------------------------
function TImpChequeBematechDP10.Fechar( aPorta:String ): Boolean;
begin
  if (fHandle <> INVALID_HANDLE_VALUE) then
  begin
    if fFuncFechaPorta <> 1 then
      ShowMessage('Erro ao fechar a  comunicação com impressora de cheque')
    else
    begin
      bOpened := False;
    End;
    FreeLibrary(fHandle);
    fHandle := 0;
    sleep (500);

  end;
  Result := True;


end;

//---------------------------------------------------------------------------
function TImpChequeBematechDP10.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sValor   : String;
  sData    : String;
  sFVerso  : TStringList;
  nRet     : Integer;
  fArquivo : TIniFile;
  pPath    : PChar;
  sPath    : String;
  aCoordimp : Array[1..13] of String;
  nPos      : Integer;
  nItem     : Integer;
  nLin      : Integer;
  nCol      : Integer;
  sCoordimp : String;
  sLinha    : String;

  nmaxlin   : Integer;
  nmaxcol   : Integer;
  nlvalnum  : Integer;
  nlvalext1 : Integer;
  nlvalext2 : Integer;
  nlnomfav  : Integer;
  nlciddt   : Integer;
  ncvalnum  : Integer;
  ncvalext1 : Integer;
  ncvalext2 : Integer;
  ncnomfavo : Integer;
  nccidade  : Integer;
  ncdiacid  : Integer;
  ncmescid  : Integer;
  ncanocid  : Integer;

//       +------------------------------------- linha do valor numerico
//       |  +---------------------------------- linha do valor extenso 1
//       |  |  +------------------------------- linha do valor extenso 2
//       |  |  |  +---------------------------- linha do nome do favorecido
//       |  |  |  |  +------------------------- linha da cidade/data
//       |  |  |  |  |  +---------------------- coluna do valor numerico
//       |  |  |  |  |  |  +------------------- coluna do valor extenso 1
//       |  |  |  |  |  |  |  +---------------- coluna do valor extenso 2
//       |  |  |  |  |  |  |  |  +------------- coluna do nome do favorecido
//       |  |  |  |  |  |  |  |  |  +---------- coluna da cidade
//       |  |  |  |  |  |  |  |  |  |  +------- coluna do dia (rel cidade)
//       |  |  |  |  |  |  |  |  |  |  |  +---- coluna do mes (rel cidade)
//       |  |  |  |  |  |  |  |  |  |  |  |  +- coluna do ano (rel cidade)
//       |  |  |  |  |  |  |  |  |  |  |  |  |
//default=01,05,07,10,13,92,17,09,11,50,31,40,65        ; Formato default
begin
  if Length( Data ) = 6 then
  begin
     sData := Copy( Data, 5, 2 ) + '/' + Copy( Data, 3, 2 ) + '/' + Copy( Data, 1, 2 );
     Data  := PChar(Copy(sData,7,2) + Copy(sData,4,2)+Copy(sData,1,2));
  end
  else
  begin
     sData := Copy( Data, 7, 2 ) + '/' + Copy( Data, 5, 2 ) + '/' + Copy( Data, 1, 4 );
     Data  := PChar(Copy(sData,7,4) + Copy(sData,4,2)+Copy(sData,1,2));
  end;

  // Verifica se o BEMADP32.INI Existe no Diretório do Windows
  pPath := Pchar(Space(100));
  GetWindowsDirectory(pPath, 100);
  sPath := StrPas(pPath);
  fArquivo := TIniFile.Create(sPath+'\BEMADP32.INI');

  if (Pais = 'BOL') then
     sLinha:= fArquivo.ReadString('BOLIVIA', Banco, '')
  else
     sLinha:= fArquivo.ReadString('Formato', Banco, '');
     
  if sLinha <> '' then
  begin
    sCoordimp := sLinha;
    nPos    := Pos(',', sCoordimp);
    nItem   := 1;

    While (nPos > 0) do
    Begin
       aCoordimp[nItem] := Copy(sCoordimp,1,nPos-1);
       //Atualiza sConteudo
       sCoordimp := Copy(sCoordimp,nPos+1,Length(sCoordimp));

       //Pega posição da próxima vírgula
       nPos    := Pos(',', sCoordimp);

       Inc(nItem);
    End;

    //Pega último valor
    aCoordimp[nItem] := sCoordimp;

    nmaxlin:= 0;
    nmaxcol:= 0;

    // Pega o maior valor de linha
    for nPos := 1 to 5 do
       if (nmaxlin  < StrToIntDef( aCoordimp[nPos],0 )) Then
           nmaxlin := StrToIntDef( aCoordimp[nPos],0 );

    // Pega o maior valor de coluna
    for nPos := 6 to 13 do
       if (nmaxcol  < StrToIntDef( aCoordimp[nPos],0 )) Then
           nmaxcol := StrToIntDef( aCoordimp[nPos],0 );

    nlvalnum  := StrToIntDef( aCoordimp[01] , 0 );
    nlvalext1 := StrToIntDef( aCoordimp[02] , 0 );
    nlvalext2 := StrToIntDef( aCoordimp[03] , 0 );
    nlnomfav  := StrToIntDef( aCoordimp[04] , 0 );
    nlciddt   := StrToIntDef( aCoordimp[05] , 0 );
    ncvalnum  := StrToIntDef( aCoordimp[06] , 0 );
    ncvalext1 := StrToIntDef( aCoordimp[07] , 0 );
    ncvalext2 := StrToIntDef( aCoordimp[08] , 0 );
    ncnomfavo := StrToIntDef( aCoordimp[09] , 0 );
    nccidade  := StrToIntDef( aCoordimp[10] , 0 );
    ncdiacid  := StrToIntDef( aCoordimp[11] , 0 );
    ncmescid  := StrToIntDef( aCoordimp[12] , 0 );
    ncanocid  := StrToIntDef( aCoordimp[13] , 0 );
    fFuncIniciaPorta(Pchar(sPorta));

    If length(Mensagem)<1 then
        If Chancela = 'S' then
          Mensagem := Pchar('$'+FormataTexto(Valor, length(valor), 2, 3,',')+'$');

    sValor := FormataTexto(Valor, 15, 2, 3,',');

    if Length( Data ) = 6 then
    begin
        sData := Copy( Data, 5, 2 ) + Copy( Data, 3, 2 ) + Copy( Data, 1, 2 );
    end
    else
    begin
        sData := Copy( Data, 7, 2 ) + Copy( Data, 5, 2 ) + Copy( Data, 1, 4 );
    end;

    // Imprime na porta via DLL da Bematech.
    sValor := FloatToStrF(StrToFloat(sValor),ffnumber,18,2);
    sValor := Copy(sValor,1,length(svalor)-3)+','+Copy(sValor,length(svalor)-1,length(svalor));

    nLin:=0;
    nCol:=0;
    
    nRet := fFuncTravaDocumento(1);

    if (Pais = 'BOL') then
    begin
       for nLin := 1 to 11 do
       begin
          sLinha:= '';
          for nCol := 1 to 80 do
          begin
            if ((nLin = strtoint(aCoordimp[01])) and (nCol = strtoint(aCoordimp[06]))) then
               sLinha:= sLinha + sValor
            else if ((nLin = strtoint(aCoordimp[02])) and (nCol = strtoint(aCoordimp[07]))) then
               sLinha:= sLinha + Copy( Copy( Trim(StrPas(Extenso)),1,60) + '************************************************************************************',1,64)
            else if ((nLin = strtoint(aCoordimp[03])) and (nCol = strtoint(aCoordimp[08]))) then
               sLinha:= sLinha + Copy( Copy( Trim(StrPas(Extenso)),60,length(Trim(StrPas(Extenso)))) + '*******************************************************************',1,64)
            else if ((nLin = strtoint(aCoordimp[04])) and (nCol = strtoint(aCoordimp[09])))  then
               sLinha:= sLinha + StrPas( Favorec )
            else if ((nLin = strtoint(aCoordimp[05])) and  (nCol = strtoint(aCoordimp[10]))) then
               sLinha:= sLinha + Trim( StrPas( cidade ) )
            else if ((nLin = strtoint(aCoordimp[05])) and (nCol = strtoint(aCoordimp[11]))) then
               sLinha:= sLinha + Trim( Copy( Data, 5, 2 ) )
            else if ((nLin = strtoint(aCoordimp[05])) and (nCol = strtoint(aCoordimp[12]))) then
               sLinha:= sLinha + Trim( Copy( Data, 3, 2 ) )
            else if ((nLin = strtoint(aCoordimp[05])) and (nCol = strtoint(aCoordimp[13]))) then
               sLinha:= sLinha + Trim( Copy( Data, 1, 2 ) )
            else
                sLinha:= sLinha + ' ';
          end;
          nRet := fFuncImprimeTexto(copy(sLinha,1,80),1);
       end;
       nRet := fFuncTravaDocumento(0);
    end
    else nRet := fFuncImprimeCheque( StrPas( Banco ), sValor, StrPas( Favorec ), Trim( StrPas( cidade ) ), sData, StrPas( Mensagem )); //Brasil

   // Caso tenha sido especificado verso, então imprime...
    If ((Length(Verso) > 0) and (nRet = DLL_COMANDO_OK)) then
    Begin
      sFVerso := tStringList.Create;
      Showmessage('Insira o verso do cheque e tecle <ENTER>');

      {Caso o texto do Verso comece com um * , está sendo passado
      para o agente o nome de um arquivo texto com o conteúdo a ser
      impresso no Verso do Cheque. Observaçäo : O Caracter para indicar
      quebra de linha no verso deve ser o * (Asterisco) }
      if (Copy(Verso,1,1) = '*') then
      begin
        Try
          sFVerso.LoadFromFile(copy(Verso,2,length(Verso)));
          Verso := PChar(sFVerso.Text);
        except
          ShowMessage('Erro na leitura do arquivo: '+copy(Verso,2,length(Verso)));
        end;
      end;

      nRet := fFuncTravaDocumento(1);

      if nRet=1 then
      begin
          if length(verso)>2000 then verso:= pChar(copy(verso,1,2000));

          Repeat
                If length(verso)>800 then
                Begin
                    If pos(#10, copy(verso,1,800))>0 then
                    Begin
                        nRet := fFuncImprimeTexto(copy(Verso,1,pos(#10, verso)-1),1);
                        sleep(pos(#10, verso)*10);
                        verso := Pchar(copy(Verso,pos(#10, verso)+1,length(verso)));
                    End
                    Else
                    Begin
                        nRet := fFuncImprimeTexto(copy(Verso,1,800),1);
                        Sleep(10000);
                        verso := Pchar(copy(Verso,801,length(verso)));
                    End;
                End
                Else
                Begin
                    If pos(#10, verso)>0 then
                    Begin
                        nRet := fFuncImprimeTexto(copy(Verso,1,pos(#10, verso)-1),1);
                        sleep(pos(#10, verso)*10);
                        verso := Pchar(copy(Verso,pos(#10, verso)+1,length(verso)));
                    End
                    Else
                    Begin
                        nRet := fFuncImprimeTexto(Verso,1);
                        sleep(length(verso)*10);
                        verso := '';
                    End;
                End;
          Until length(verso)=0;

          if nRet=1 then
          begin
              nRet := fFuncTravaDocumento(0);
              if nRet <> 1 then  Showmessage ('Erro de comunicação com a Impressora');
          end
          else
          begin
              ShowMessage ('Erro de comunicação com a Impressora');
              nRet := fFuncTravaDocumento(0);
          end;
      end
      else
      begin
          ShowMessage ('Erro de comunicação com a Impressora');
      end;

      sFVerso.Free;
    End;

    if nRet = DLL_COMANDO_OK then
      Result := True
    else
      Result := False;

  end
  Else
  begin
    MsgStop('O código do banco ' + Banco +  ' não é válido ou não está cadastrado no arquivo ' + sPath + '\BemaDP32.INI.' + #10 + 'O cheque não será impresso.' );
    Result := False;
  end;
  fArquivo.Free;
end;

//---------------------------------------------------------------------------
function TImpChequeBematechDP10.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
var
  sValor   : String;
  sData    : String;
  nRet     : Integer;
  fArquivo : TIniFile;
  pPath    : PChar;
  sPath    : String;
begin
  if Length( Data ) = 6 then
  begin
     sData := Copy( Data, 5, 2 ) + '/' + Copy( Data, 3, 2 ) + '/' + Copy( Data, 1, 2 );
     Data  := Pchar( FormatDateTime( 'yymmdd', StrToDate( sData ) ) );
  end
  else
  begin
     sData := Copy( Data, 7, 2 ) + '/' + Copy( Data, 5, 2 ) + '/' + Copy( Data, 1, 4 );
     Data  := Pchar( FormatDateTime( 'yyyymmdd', StrToDate( sData ) ) );
  end;

  // Verifica se o BEMADP32.INI Existe no Diretório do Windows
  pPath := StrAlloc(100);

  GetWindowsDirectory( pPath, 100 );

  sPath := StrPas( pPath );

  StrDispose( pPath );

  fArquivo := TIniFile.Create( sPath + '\BEMADP32.INI' );

  if fArquivo.ReadString( 'Formato', Banco, '') <> '' then
  begin
    fFuncIniciaPorta( Pchar( sPorta ) );

    sValor := FormataTexto( Valor, 15, 2, 3, ',' );

    // Imprime na porta via DLL da Bematech.
    sValor := FloatToStrF( StrToFloat( sValor ), ffnumber, 18, 2 );
    sValor := Copy( sValor, 1, Length( sValor ) - 3 ) + ',' + Copy( sValor, Length( sValor ) - 1, Length( sValor ) );

    if Length( Data ) = 6 then
    begin
        sData := Copy( Data, 5, 2 ) + Copy( Data, 3, 2 ) + Copy( Data, 1, 2 );
    end
    else
    begin
        sData := Copy( Data, 7, 2 ) + Copy( Data, 5, 2 ) + Copy( Data, 1, 4 );
    end;

    nRet   := fFuncImprimeChequeTransf( StrPas( Banco ), sValor, Trim( StrPas( Cidade ) ), sData, StrPas( Agencia ), StrPas( Conta ), StrPas( Mensagem ) );

    fFuncFechaPorta;

    if nRet = DLL_COMANDO_OK then
      Result := True
    else
      Result := False;
  end
  else
  begin
    MsgStop( 'O código do banco ' + Banco +  ' não é válido ou não está cadastrado no arquivo ' + sPath + '\BemaDP32.INI.' + #10 + 'O cheque não será impresso.' );
    Result := False;
  end;

  fArquivo.Free;
end;

//----------------------------------------------------------------------------
function TImpChequeBematechDP10.StatusCh( Tipo:Integer ):String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '0';

end;

{ TImpChequeBematechDP10 }
Initialization
  RegistraImpCheque('BEMATECH DP10'  , TImpChequeBematechDP10, 'BRA|BOL');
  RegistraImpCheque('BEMATECH DP20'  , TImpChequeBematechDP20, 'BRA|BOL');

end.
