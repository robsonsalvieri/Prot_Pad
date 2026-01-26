unit ImpNFiscDaruma;

interface

uses
  Dialogs, ImpNFiscMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms, CMC7Main, StdCtrls, ShellApi;

type

  //============================================================================
  //Não tem tratamento de Tag pois as tags são baseadas nessa impressora
  //============================================================================

  TImpNfDaruma = class(TImpNFiscal)
  private
  public
    function Abrir( sPorta:AnsiString; iVelocidade : Integer; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function ImpTexto( Texto : AnsiString):AnsiString; override;
    function ImpCodeBar( Tipo,Texto:AnsiString  ):AnsiString; override;
    function ImpBitMap( Arquivo:AnsiString ):AnsiString; override;
    function AbreGaveta(): AnsiString; override;
    function StatusImp( Tipo:Integer ) : AnsiString; override;
  end;

  Function OpenDarumaNF( sPorta:AnsiString; iVelocidade : Integer ):AnsiString;
  Function CloseDarumaNF : AnsiString;

implementation

var
    fHandle  : THandle; //'DarumaFrameWork.DLL'
    fFunc_eBuscarPortaVelocidade_DUAL_DarumaFramework    : function : Integer; StdCall;
    fFunc_rConsultaStatusImpressora_DUAL_DarumaFramework : function( stIndice: AnsiString; StTipo: AnsiString; StRetorno:AnsiString): Integer; StdCall;
    fFunc_rStatusGuilhotina_DUAL_DarumaFramework         : function : Integer; StdCall;
    fFunc_rStatusDocumento_DUAL_DarumaFramework          : function : Integer; StdCall;
    fFunc_rStatusGaveta_DUAL_DarumaFramework             : function (var iStatusGaveta: SmallInt): Integer;StdCall;
    fFunc_rStatusImpressora_DUAL_DarumaFramework         : function : Integer; StdCall;
    fFunc_regAguardarProcesso_DUAL_DarumaFramework       : function (stParametro: AnsiString): Integer;StdCall;
    fFunc_regCodePageAutomatico_DUAL_DarumaFramework     : function (stParametro: AnsiString): Integer;StdCall;
    fFunc_regEnterFinal_DUAL_DarumaFramework             : function (stParametro: AnsiString): Integer; StdCall;
    fFunc_regLinhasGuilhotina_DUAL_DarumaFramework       : function (stParametro: AnsiString): Integer; StdCall;
    fFunc_regModoGaveta_DUAL_DarumaFramework             : function (stParametro: AnsiString): Integer; StdCall;
    fFunc_regPortaComunicacao_DUAL_DarumaFramework       : function (stParametro: AnsiString): Integer; StdCall;
    fFunc_regTabulacao_DUAL_DarumaFramework              : function (stParametro: AnsiString): Integer; StdCall;
    fFunc_regTermica_DUAL_DarumaFramework                : function (stParametro: AnsiString): Integer; StdCall;
    fFunc_regVelocidade_DUAL_DarumaFramework             : function (stParametro: AnsiString): Integer; StdCall;
    fFunc_regZeroCortado_DUAL_DarumaFramework            : function (stParametro: AnsiString): Integer; StdCall;
    fFunc_eGerarQrCodeArquivo_DUAL_DarumaFramework       : function (stPath: AnsiString; stCodigo: AnsiString): Integer; StdCall;
    fFunc_iImprimirTexto_DUAL_DarumaFramework            : function (stTexto: AnsiString; iTam: Integer ): Integer; StdCall;
    fFunc_iImprimirBMP_DUAL_DarumaFramework              : function (stArqOrigem: AnsiString): Integer; StdCall;
    fFunc_iImprimirArquivo_DUAL_DarumaFramework          : function (stPath: AnsiString): Integer; StdCall;
    fFunc_iEnviarBMP_DUAL_DarumaFramework                : function (stArqOrigem: AnsiString): Integer; StdCall;
    fFunc_iAcionarGaveta_DUAL_DarumaFramework            : function : Integer; StdCall;
    fFunc_iAutenticarDocumento_DUAL_DarumaFramework      : function (stTexto: AnsiString; stLocal: AnsiString; stTimeOut: AnsiString): Integer; StdCall;
    fFunc_iConfigurarGuilhotina_DUAL_DarumaFramework     : function (iHabilitar: Integer; iQtdeLinha: Integer): Integer; StdCall;
    fFunc_regRetornaValorChave_DarumaFramework           : function (pszProduto:AnsiString;pszChave:AnsiString;pszValor:AnsiString):Integer; StdCall;
    fFunc_rVersaoFW_DUAL_DarumaFramework                 : function (pszRetornaVersao: AnsiString): Integer; StdCall;

    bOpened : Boolean;



//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
Function OpenDarumaNF( sPorta:AnsiString; iVelocidade : Integer) : AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg:AnsiString; sArqDll:AnsiString = 'DarumaFrameWork.DLL' ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      LjMsgDlg('A função "' + sMsg + '" não existe na Dll: ' + sArqDll +#13+
               '(Atualize as DLLs do Fabricante do ECF)');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  iRet : Integer;
  bRet : Boolean;
  sPathLog , sMsg , sIniVeloci,sIniPorta,sIni: AnsiString;
  ListaArq : TStringList;
begin
  sPathLog  := '';
  iRet      := 0;

  If Not bOpened Then
  Begin
    fHandle  := LoadLibrary( 'DarumaFrameWork.DLL' );

    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'eBuscarPortaVelocidade_DUAL_DarumaFramework');
      if ValidPointer( aFunc, 'eBuscarPortaVelocidade_DUAL_DarumaFramework' )
      then fFunc_eBuscarPortaVelocidade_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'rConsultaStatusImpressora_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'rConsultaStatusImpressora_DUAL_DarumaFramework' )
      then fFunc_rConsultaStatusImpressora_DUAL_DarumaFramework  := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'rStatusGuilhotina_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'rStatusGuilhotina_DUAL_DarumaFramework' )
      then fFunc_rStatusGuilhotina_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'rStatusDocumento_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'rStatusDocumento_DUAL_DarumaFramework' )
      then fFunc_rStatusDocumento_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'rStatusGaveta_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'rStatusGaveta_DUAL_DarumaFramework' )
      then fFunc_rStatusGaveta_DUAL_DarumaFramework  := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'rStatusImpressora_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'rStatusImpressora_DUAL_DarumaFramework' )
      then fFunc_rStatusImpressora_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regAguardarProcesso_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regAguardarProcesso_DUAL_DarumaFramework' )
      then fFunc_regAguardarProcesso_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regCodePageAutomatico_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regCodePageAutomatico_DUAL_DarumaFramework' )
      then fFunc_regCodePageAutomatico_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regEnterFinal_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regEnterFinal_DUAL_DarumaFramework' )
      then fFunc_regEnterFinal_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regLinhasGuilhotina_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regLinhasGuilhotina_DUAL_DarumaFramework' )
      then fFunc_regLinhasGuilhotina_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regModoGaveta_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regModoGaveta_DUAL_DarumaFramework' )
      then fFunc_regModoGaveta_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regPortaComunicacao_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regPortaComunicacao_DUAL_DarumaFramework' )
      then fFunc_regPortaComunicacao_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regTabulacao_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regTabulacao_DUAL_DarumaFramework' )
      then fFunc_regTabulacao_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regTermica_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regTermica_DUAL_DarumaFramework' )
      then fFunc_regTermica_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regVelocidade_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regVelocidade_DUAL_DarumaFramework' )
      then fFunc_regVelocidade_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'regZeroCortado_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'regZeroCortado_DUAL_DarumaFramework' )
      then fFunc_regZeroCortado_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'eGerarQrCodeArquivo_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'eGerarQrCodeArquivo_DUAL_DarumaFramework' )
      then fFunc_eGerarQrCodeArquivo_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iImprimirTexto_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'iImprimirTexto_DUAL_DarumaFramework' )
      then fFunc_iImprimirTexto_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iImprimirBMP_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'iImprimirBMP_DUAL_DarumaFramework' )
      then fFunc_iImprimirBMP_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iImprimirArquivo_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'iImprimirArquivo_DUAL_DarumaFramework' )
      then fFunc_iImprimirArquivo_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iEnviarBMP_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'iEnviarBMP_DUAL_DarumaFramework' )
      then fFunc_iEnviarBMP_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iAcionarGaveta_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'iAcionarGaveta_DUAL_DarumaFramework' )
      then fFunc_iAcionarGaveta_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iAutenticarDocumento_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'iAutenticarDocumento_DUAL_DarumaFramework' )
      then fFunc_iAutenticarDocumento_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'iConfigurarGuilhotina_DUAL_DarumaFramework');
      If ValidPointer( aFunc , 'iConfigurarGuilhotina_DUAL_DarumaFramework' )
      then fFunc_iConfigurarGuilhotina_DUAL_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle, 'regRetornaValorChave_DarumaFramework');
      if ValidPointer( aFunc , 'regRetornaValorChave_DarumaFramework')
      then fFunc_regRetornaValorChave_DarumaFramework := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle, 'rVersaoFW_DUAL_DarumaFramework');
      if ValidPointer( aFunc , 'rVersaoFW_DUAL_DarumaFramework')
      then fFunc_rVersaoFW_DUAL_DarumaFramework := aFunc
      else bRet := False;

    end
    else
    begin
      LjMsgDlg('A dll DarumaFrameWork não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      sIniVeloci := Space(100);
      sIniPorta  := Space(100);
      GravaLog('-> regRetornaValorChave_DarumaFramework - Produto: DUAL , Chave: PortaComunicacao' );
      iRet := fFunc_regRetornaValorChave_DarumaFramework('DUAL','PortaComunicacao',sIniPorta);
      sIniPorta  := Trim(sIniPorta);
      GravaLog('regRetornaValorChave_DarumaFramework <- iRet [' + IntToStr(iRet) + '] - Porta ['+sIniPorta+']');

      GravaLog('-> regRetornaValorChave_DarumaFramework - Produto: DUAL , Chave: Velocidade' );
      iRet := fFunc_regRetornaValorChave_DarumaFramework('DUAL','Velocidade',sIniVeloci);
      sIniVeloci := Trim(sIniVeloci);
      GravaLog('regRetornaValorChave_DarumaFramework <- iRet [' + IntToStr(iRet) + '] - Velocidade [' + sIniVeloci + ']');

      sMsg := Space(100) ;
      iRet := fFunc_regRetornaValorChave_DarumaFramework('DUAL','AtivaRota',sMsg);
      sMsg := Trim(sMsg);
      If sMsg = '1'
      then sMsg := 'SIM'
      else sMsg := 'NAO';

      GravaLog('Rota Ativa [Impressora em Rede] ?  - ' + sMsg );

      If (sMsg = 'NAO') then
      begin
        If (sIniPorta <> Trim(sPorta)) then
        begin
          LjMsgDlg('Daruma Nao Fiscal: Verifique a divergência abaixo! ' + CHR(13) +
                   'Arquivo de Configuração (DarumaFrameWork.xml)'  + CHR(13) +
                   '--> Porta : ' + sIniPorta + ' --> Velocidade : ' + sIniVeloci + CHR(13) +
                   'Cadastro de Estação ' + CHR(13) +
                   '--> Porta : ' + sPorta + ' --> Velocidade : ' + sIniVeloci + CHR(13) +
                   'As informações devem estar iguais para a comunicação com a impressora');
          GravaLog('Daruma Nao Fiscal: Verifique a divergência abaixo! ' + CHR(13) +
                   'Arquivo de Configuração (DarumaFrameWork.xml)'  + CHR(13) +
                   '--> Porta : ' + sIniPorta + ' --> Velocidade : ' + sIniVeloci + CHR(13) +
                   'Cadastro de Estação ' + CHR(13) +
                   '--> Porta : ' + sPorta + ' --> Velocidade : ' + sIniVeloci + CHR(13) +
                   'As informações devem estar iguais para a comunicação com a impressora');
          iRet := 0;
        end
        else
        begin
          If Copy(sIniPorta,1,3) = 'COM' then
          begin
            GravaLog('Daruma Nao Fiscal -> regVelocidade_DUAL_DarumaFramework :' + sIniVeloci);
            iRet := fFunc_regVelocidade_DUAL_DarumaFramework(sIniVeloci);
            GravaLog('Daruma Nao Fiscal  <- regPortaComunicacao_DUAL_DarumaFramework :' + IntToStr(iRet));
          end;

          GravaLog('Daruma Nao Fiscal -> regPortaComunicacao_DUAL_DarumaFramework');
          iRet := fFunc_regPortaComunicacao_DUAL_DarumaFramework(sIniPorta);
          GravaLog('Daruma Nao Fiscal  <- regPortaComunicacao_DUAL_DarumaFramework :' + IntToStr(iRet));
        end;
      End;

      If iRet = 1 then
      begin

        try
          sIni := ExtractFilePath(Application.ExeName) + 'DarumaFrameWork.XML';
          If FileExists(sIni) then
          Begin
            ListaArq := TStringList.Create;
            ListaArq.Clear;
            ListaArq.LoadFromFile(sIni);

            GravaLog(' ******** Arquivo DarumaFrameWork.XML *******');
            GravaLog( ListaArq.Text );
            GravaLog(' ******** Final da Leitura do Arquivo DarumaFrameWork.XML*******');
          End;
        except
          GravaLog('Não foi possível carregar/ler o arquivo de configuração DarumaFrameWork.XML');
        end;

        GravaLog('Daruma Nao Fiscal -> rStatusImpressora_DUAL_DarumaFramework ');
        iRet := fFunc_rStatusImpressora_DUAL_DarumaFramework();
        GravaLog('Daruma Nao Fiscal  - rStatusImpressora_DUAL_DarumaFramework <- iRet : ' + IntToStr(iRet));

        case iRet of
           0 : sMsg := 'Erro de comunicação/Impressora Desligada';
           1 : sMsg := '';
           -99:sMsg := 'Método não executado';
           -27:sMsg := 'Erro generico';
           -50:sMsg := 'Impressora OFFLINE';
           -51:sMsg := 'Impressora SEM PAPEL';
           -52:sMsg := 'Impressora Inicializando';
        else
            sMsg := 'Erro desconhecido';
        end;

        If sMsg <> '' then
        begin
          LjMsgDlg('Daruma Nao Fiscal : ' + sMsg);
          GravaLog('Daruma Nao Fiscal : ' + sMsg);
          iRet := 0
        end
        else
          iRet := 1;
      end;
    end
    else iRet := 0;
  end;

  If iRet = 1
  then Result := '0|'
  else Result := '1|';
end;

//----------------------------------------------------------------------------
Function CloseDarumaNF : AnsiString;
begin
  If bOpened Then
  Begin
    If fHandle <> INVALID_HANDLE_VALUE then
    begin
      GravaLog('Daruma Nao Fiscal -> FechaPorta ');
      FreeLibrary(fHandle);
      fHandle := 0;
    end;

    bOpened := False;
  End;

  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpNfDaruma.Abrir(sPorta : AnsiString; iVelocidade : Integer ; iHdlMain:Integer) : AnsiString;
Var
  sRet : AnsiString;
begin

If Not bOpened
Then sRet := OpenDarumaNF(sPorta, iVelocidade )
Else sRet := '0|';

If Copy(sRet,1,1) = '0'
then GravaLog('Daruma Nao Fiscal : Sucesso ao abrir porta');

Result := sRet;

end;

//----------------------------------------------------------------------------
function TImpNfDaruma.Fechar( sPorta:AnsiString ):AnsiString;
begin
Result := CloseDarumaNF;
end;

//----------------------------------------------------------------------------
function TImpNfDaruma.ImpTexto( Texto : AnsiString):AnsiString;
Var
  iRet,nPos  : Integer;
  oTexto : TStringList;
  sAux,sTextoImp: AnsiString;
  bCorte : Boolean;
Begin
oTexto := TStringList.Create;
oTexto.Clear;
sTextoImp := Texto;
bCorte    := False;
iRet := 0;

If sTextoImp = '<gui></gui>' then
begin
 sAux := Space(100);
 iRet := fFunc_regRetornaValorChave_DarumaFramework('DUAL','LinhasGuilhotina',sAux);
 GravaLog('Daruma Nao Fiscal <- Leu o arquivo .XML de Configuração, validado a quantidade de linhas' +
         'que vai pular antes do comando de corte - tag <LinhasGuilhotina> : Qtde [' + sAux + ']');
 nPos := StrToInt(Trim(sAux));
 If nPos <> 0 then
 begin
   sAux := '<sl>' + IntToStr(nPos) + '</sl>';
 end
 else
 begin
   sAux := '<sl>2</sl>'
 end;

 fFunc_iImprimirTexto_DUAL_DarumaFramework(sAux,0);  //Pula NN linhas
 GravaLog('Daruma Nao Fiscal <- Executou comando para pular linhas');

 iRet := fFunc_iImprimirTexto_DUAL_DarumaFramework(sTextoImp,0);
 GravaLog('Daruma Nao Fiscal <- iImprimirTexto_DUAL_DarumaFramework - Corte de Papel :' + IntToStr(iRet));
 bCorte := True;
end;

If not bCorte then
begin
  nPos := Pos(#10,sTextoImp);
  While nPos > 0 do
  Begin
    nPos  := Pos(#10,sTextoImp);
    sAux  := sAux + Copy(sTextoImp,1,nPos) ;
    sTextoImp := Copy(sTextoImp,nPos+1,Length(sTextoImp));

    If Length(sAux) >= 600 Then
    Begin
      sAux := Copy(sAux,1,Length(sAux)-1);
      oTexto.Add(sAux);
      sAux := '';
    end;
  End;
  
  If Trim(sTextoImp) <> ''
  Then sAux := ' ' + sAux + sTextoImp + #10;

  If Trim(sAux) <> ''
  Then oTexto.Add(sAux);

  GravaLog('Daruma Nao Fiscal  -> iImprimirTexto_DUAL_DarumaFramework : ' + Texto);

  For nPos := 0 to Pred(oTexto.Count) do
    iRet := fFunc_iImprimirTexto_DUAL_DarumaFramework(oTexto.Strings[nPos],0);

  GravaLog('Daruma Nao Fiscal <- iImprimirTexto_DUAL_DarumaFramework :' + IntToStr(iRet));
end;

If iRet = 1
then Result := '0|'
else Result := '1|';

End;


//----------------------------------------------------------------------------
function TImpNfDaruma.ImpCodeBar( Tipo,Texto:AnsiString  ):AnsiString;
begin
  ImpTexto(Texto);
end;

//----------------------------------------------------------------------------
function TImpNfDaruma.ImpBitMap( Arquivo:AnsiString ):AnsiString;
var
  iRet : Integer;
begin

GravaLog('Daruma Nao Fiscal -> iImprimirBMP_DUAL_DarumaFramework');
iRet := fFunc_iImprimirBMP_DUAL_DarumaFramework(Arquivo);
GravaLog('Daruma Nao Fiscal <- iImprimirBMP_DUAL_DarumaFramework : ' + IntToStr(iRet));

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//-----------------------------------------------------------------------------
function TImpNfDaruma.AbreGaveta(): AnsiString;
var
  iRet : Integer;
begin
GravaLog('Daruma Nao Fiscal -> iAcionarGaveta_DUAL_DarumaFramework');
iRet := fFunc_iAcionarGaveta_DUAL_DarumaFramework();
GravaLog('Daruma Nao Fiscal <- iAcionarGaveta_DUAL_DarumaFramework : ' + IntToStr(iRet));

If iRet = 1
then Result := '0|'
else Result := '1|';
end;

//-----------------------------------------------------------------------------
function TImpNfDaruma.StatusImp(Tipo: Integer): AnsiString;
var
  strVersao : AnsiString;
  iRet : Integer;
begin

If Tipo = 1 then   //FirmWare
begin
  strVersao := Space(8);
  GravaLog('Daruma Nao Fiscal -> rVersaoFW_DUAL_DarumaFramework');
  iRet := fFunc_rVersaoFW_DUAL_DarumaFramework(strVersao);
  GravaLog('Daruma Nao Fiscal <- rVersaoFW_DUAL_DarumaFramework : ' + strVersao);

  If iRet = 1 then
    Result := '0|' + strVersao
  else
    Result := '1|';
end

end;


//=============================================================================
initialization
  RegistraImpressora('DARUMA DR700 (S)' , TImpNfDaruma  , 'BRA' ,'      ');
  RegistraImpressora('DARUMA DR800' , TImpNfDaruma  , 'BRA' ,'      ');
  RegistraImpressora('DARUMA DR', TImpNfDaruma  , 'BRA' ,'      ');

end.
