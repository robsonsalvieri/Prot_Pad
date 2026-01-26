unit ImpNFiscElgin;

interface

uses
  Dialogs, ImpNFiscMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms, CMC7Main, StdCtrls, ShellApi;

type

  TImpNfElgin = class(TImpNFiscal)
  private
  public
    function Abrir( sPorta:String; iVelocidade : Integer; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function ImpTexto( Texto : String):String; override;
    function ImpCodeBar( Tipo,Texto:String  ):String; override;
    function ImpBitMap( Arquivo:String ):String; override;
    function TrataTags( var Texto : String ): String;
    function VerStatus(): Integer;
    function AbreGaveta() : String; override;
  end;

  Function OpenElginNF( sPorta:String; iVelocidade : Integer ):String;
  Function CloseElginNF : String;

implementation

var
        fHandle  : THandle; //'INTERFACEEPSONNF.DLL'
        aArTags : array [1..27] of String;

        //Funções da DLL
        fFuncIniciaPorta 		: function(Porta : PChar): Integer; StdCall;
        fFuncFechaPorta		        : function(): Integer; StdCall;
        fFuncImprimeTexto		: function(Texto : String) :Integer; StdCall;
        fFuncImprimeTextoTag		: function(Texto : String) : Integer; StdCall;
        fFuncFormataTX		        : function(Texto : String ; TipoLetra : Integer; Italico : Integer; Sublinhado : Integer; Expandido : Integer; Enfatizado : Integer) : Integer; StdCall;
        fFuncAcionaGuilhotina	        : function(Aciona : Integer) : Integer; StdCall;
        fFuncComandoTX		        : function(Comando : String; Tamanho : Integer) : Integer; StdCall;
        fFuncLe_Status		        : function() : Integer; StdCall;
        fFuncLe_Status_Gaveta	        : function() : Integer; StdCall;
        fFuncConfiguraCodigoBarras	: function(Altura : Integer; Largura : Integer ; HRI : Integer; Fonte : Integer; Margem : Integer) : Integer; StdCall;
        fFuncImprimeCodigoBarrasCODABAR : function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasCODE128 : function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasCODE39  : function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasCODE93  : function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasEAN13   : function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasEAN8	: function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasITF	: function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasUPCA	: function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasUPCE	: function(Texto : String) : Integer; StdCall;
        fFuncImprimeCodigoBarrasPDF417  : function(Correcao : Integer; Altura : Integer; Largura : Integer; Colunas : Integer; Codigo : String) : Integer; StdCall;
        fFuncImprimeCodigoQRCODE	: function(Restauracao : Integer; Modulo : Integer; Tipo : Integer; Versao : Integer; Modo : Integer; Codigo : String) : Integer; StdCall;
        fFuncGerarQRCodeArquivo	        : function(FileName : String; Dados : String) : Integer; StdCall;
        fFuncImprimeBmpEspecial	        : function(FileName : String; nX : Integer; nY : Integer; Angulo : Integer) : Integer; StdCall;
        fFuncHabilita_Log		: function(Estado : Integer; Caminho : String) : Integer; StdCall;
        fFuncConfiguraTaxaSerial	: function(TaxaSerial : Integer) : Integer; StdCall;
        fFuncAcionaGaveta               : function() : Integer; StdCall;

        bOpened : Boolean;

//----------------------------------------------------------------------------
Function OpenElginNF( sPorta:String; iVelocidade : Integer) : String;
  function ValidPointer( aPointer: Pointer; sMSg:String; sArqDll:String = 'INTERFACEEPSONNF.DLL' ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      LjMsgDlg('A função "' + sMsg + '" não existe na Dll: ' + sArqDll +#13+
               '(Atualize as DLLs do Fabricante do ECF)');
      GravaLog('A função "' + sMsg + '" não existe na Dll: ' + sArqDll +#13+
               '(Atualize as DLLs do Fabricante do ECF)');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  iRet,iVelIni : Integer;
  bRet : Boolean;
  sPathLog,sVelIni,sIni : String;
  fArq : TIniFile;
  ListaArq : TStringList;
begin
  sPathLog  := '';

  If Not bOpened Then
  Begin
    fHandle  := LoadLibrary( 'INTERFACEEPSONNF.DLL' );

    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'IniciaPorta');
      if ValidPointer( aFunc, 'IniciaPorta' )
      then fFuncIniciaPorta := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'FechaPorta');
      If ValidPointer( aFunc , 'FechaPorta' )
      then fFuncFechaPorta := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeTexto');
      If ValidPointer( aFunc , 'ImprimeTexto' )
      then fFuncImprimeTexto := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeTextoTag');
      If ValidPointer( aFunc , 'ImprimeTextoTag' )
      then fFuncImprimeTextoTag := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'FormataTX');
      If ValidPointer( aFunc , 'FormataTX' )
      then fFuncFormataTX := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ComandoTX');
      If ValidPointer( aFunc , 'ComandoTX' )
      then fFuncComandoTX := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'AcionaGuilhotina');
      If ValidPointer( aFunc , 'AcionaGuilhotina' )
      then fFuncAcionaGuilhotina := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Le_Status');
      If ValidPointer( aFunc , 'Le_Status' )
      then fFuncLe_Status := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Le_Status_Gaveta');
      If ValidPointer( aFunc , 'Le_Status_Gaveta' )
      then fFuncLe_Status_Gaveta := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ConfiguraCodigoBarras');
      If ValidPointer( aFunc , 'ConfiguraCodigoBarras' )
      then fFuncConfiguraCodigoBarras := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasCODABAR');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasCODABAR' )
      then fFuncImprimeCodigoBarrasCODABAR := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasCODE128');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasCODE128' )
      then fFuncImprimeCodigoBarrasCODE128 := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasCODE39');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasCODE39' )
      then fFuncImprimeCodigoBarrasCODE39 := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasCODE93');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasCODE93' )
      then fFuncImprimeCodigoBarrasCODE93 := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasEAN13');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasEAN13' )
      then fFuncImprimeCodigoBarrasEAN13 := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasEAN8');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasEAN8' )
      then fFuncImprimeCodigoBarrasEAN8 := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasITF');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasITF' )
      then fFuncImprimeCodigoBarrasITF := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasUPCA');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasUPCA' )
      then fFuncImprimeCodigoBarrasUPCA := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasUPCE');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasUPCE' )
      then fFuncImprimeCodigoBarrasUPCE := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasPDF417');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasPDF417' )
      then fFuncImprimeCodigoBarrasPDF417 := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoQRCODE');
      If ValidPointer( aFunc , 'ImprimeCodigoQRCODE' )
      then fFuncImprimeCodigoQRCODE := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'GerarQRCodeArquivo');
      If ValidPointer( aFunc , 'GerarQRCodeArquivo' )
      then fFuncGerarQRCodeArquivo := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeBmpEspecial');
      If ValidPointer( aFunc , 'ImprimeBmpEspecial' )
      then fFuncImprimeBmpEspecial := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'Habilita_Log');
      If ValidPointer( aFunc , 'Habilita_Log' )
      then fFuncHabilita_Log := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ConfiguraTaxaSerial');
      If ValidPointer( aFunc , 'ConfiguraTaxaSerial' )
      then fFuncConfiguraTaxaSerial := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'AcionaGaveta');
      If ValidPointer( aFunc , 'AcionaGaveta' )
      then fFuncAcionaGaveta := aFunc
      else bRet := False;

    end
    else
    begin
      LjMsgDlg('A dll InterfaceElginNF não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      If Copy(sPorta,1,3) = 'COM' then  //Quando porta COM deve setar a velocidade
      begin
        GravaLog('Elgin Nao Fiscal -> ConfiguraSerial ');

        fArq := TInifile.Create( ExtractFilePath(Application.ExeName)+'\'+'SIGALOJA.INI' );
        sVelIni := fArq.ReadString( 'LogDll', 'VelPorta', '' );

        If (Trim(sVelIni) = '') or (Trim(sVelIni) <> IntToStr(iVelocidade)) then
        begin
          LjMsgDlg('A velocidade da porta está diferente da velocidade cadastrada no arquivo SIGALOJA.INI.' + CHR(10)+CHR(13)+
                   'Verifique a velocidade correta da porta, efetue a configuração para a comunicação com a '+
                   ' impressora .' + CHR(10) + CHR(13) +
                   'Configuração atual: ' + IntToStr(iVelocidade) + ' - Configuração do arquivo .INI: ' + sVelIni);

          fArq.WriteString( 'LogDll', 'VelPorta', IntToStr(iVelocidade) );

          GravaLog('A velocidade da porta está diferente da velocidade cadastrada no arquivo SIGALOJA.INI.' + CHR(10)+CHR(13)+
                   'Verifique a velocidade correta da porta, efetue a configuração para a comunicação com a '+
                   ' impressora .' + CHR(10) + CHR(13) +
                   'Configuração atual: ' + IntToStr(iVelocidade) + ' - Configuração do arquivo .INI: ' + sVelIni);
        end;

        iRet := fFuncConfiguraTaxaSerial(iVelocidade);
        GravaLog('Elgin Nao Fiscal <- ConfiguraSerial :' + IntToStr(iRet));
      end;

      GravaLog('Elgin Nao Fiscal -> IniciaPorta :' + sPorta);
      iRet := fFuncIniciaPorta(pChar(Trim(sPorta)));
      GravaLog('Elgin Nao Fiscal <- IniciaPorta : ' + IntToStr(iRet));

      If iRet <> 1 then
      begin
        LjMsgDlg('Elgin Nao Fiscal : Erro na abertura da porta' + CHR(10)+CHR(13)+
                 'Verifique: ' + CHR(10)+ CHR(13)+
                 '- a configuração do arquivo SIGALOJA.INI' + CHR(10)+CHR(13)+
                 '- chave [LogDLL], seção VelPorta : configurando a velocidade da porta para conexão com a impressora' + CHR(10)+CHR(13)+
                 '- se o Windows está se comunicando com a impressora: teste por meio do programa do fabricante a impressão');

        GravaLog('Elgin Nao Fiscal : Erro na abertura da porta' + CHR(10)+CHR(13)+
                 'Verifique: ' + CHR(10)+CHR(13)+
                 '- a configuração do arquivo SIGALOJA.INI' + CHR(10)+CHR(13)+
                 '- chave [LogDLL], seção VelPorta : configurando a velocidade da porta para conexão com a impressora' + CHR(10)+CHR(13)+
                 '- se o Windows está se comunicando com a impressora: teste por meio do programa do fabricante a impressão');

        Result := '1|';
      end
      else
      begin
       bOpened := True;
       sPathLog := ExtractFilePath(Application.ExeName);
       GravaLog('Elgin Nao Fiscal -> Habilita_Log ');
       iRet := fFuncHabilita_Log(1,sPathLog);
       GravaLog('Elgin Nao Fiscal <- Habilita_Log : ' + IntToStr(iRet));

       If iRet = 1
       then GravaLog('Elgin Nao Fiscal -> Arquivo de Log de Impressora Habilitado em : "' + sPathLog + '"')
       else GravaLog('Elgin Nao Fiscal -> Arquivo de Log não Habilitado ');

       try
         sIni := ExtractFilePath(Application.ExeName) + 'InterfaceEpsonNF.XML';
         If FileExists(sIni) then
         Begin
           ListaArq := TStringList.Create;
           ListaArq.Clear;
           ListaArq.LoadFromFile(sIni);

           GravaLog(' ******** Arquivo InterfaceEpsonNF.XML *******');
           GravaLog( ListaArq.Text );
           GravaLog(' ******** Final da Leitura do Arquivo InterfaceEpsonNF.XML *******');
         End;
       except
         GravaLog('Não foi possível carregar/ler o arquivo de configuração InterfaceEpsonNF.XML');
       end;

       Result := '0|';
      end;
    end
    else Result := '1|';
  end;
end;

//----------------------------------------------------------------------------
Function CloseElginNF : String;
Var
  iRet : Integer;
begin
  If bOpened Then
  Begin
    If fHandle <> INVALID_HANDLE_VALUE then
    begin
      GravaLog('Elgin Nao Fiscal -> FechaPorta ');
      iRet := fFuncFechaPorta();
      GravaLog('Elgin Nao Fiscal <- FechaPorta :' + IntToStr(iRet));

      FreeLibrary(fHandle);
      fHandle := 0;
    end;

    bOpened := False;
  End;
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpNfElgin.Abrir(sPorta : String; iVelocidade : Integer ; iHdlMain:Integer) : String;
Var
  sRet : String;
begin

If Not bOpened
Then sRet := OpenElginNF(sPorta, iVelocidade )
Else sRet := '0|';

If Copy(sRet,1,1) = '0'
then GravaLog('Elgin Nao Fiscal : Sucesso ao abrir porta');

Result := sRet;

end;

//----------------------------------------------------------------------------
function TImpNfElgin.Fechar( sPorta:String ):String;
begin
Result := CloseElginNF;
end;

//----------------------------------------------------------------------------
function TImpNfElgin.ImpTexto( Texto : String):String;
var
  iRet,nPos  : Integer;
  oTexto : TStringList;
  sAux,sTextoImp, sTextoEnv: String;
  bCorte : Boolean;
begin
bCorte    := False;
sTextoImp := Texto;
oTexto    := TStringList.Create;
oTexto.Clear;

//Verifica se vai efetuar corte de papel
sAux := aArTags[12];
Insert('/',sAux,2);
if Concat(aArTags[12],sAux) = sTextoImp then
begin
  bCorte := True;

  iRet := VerStatus();

  If iRet = 1 then
  begin
    GravaLog('Elgin Nao Fiscal -> AcionaGuilhotina ');
    iRet := fFuncAcionaGuilhotina(1); //Manda corte inteiro
    GravaLog('Elgin Nao Fiscal <- AcionaGuilhotina :' + IntToStr(iRet));
  end;

  If iRet = 1
  then Result := '0|'
  else Result := '1|';
end;

If not bCorte then
begin
  sAux := '';
  iRet := VerStatus();

  If iRet = 1 then
  begin
    nPos := Pos(#10,sTextoImp);
    While nPos > 0 do
    Begin
      nPos  := Pos(#10,sTextoImp);
      sAux  := sAux + Copy(sTextoImp,1,nPos) ;
      sTextoImp := Copy(sTextoImp,nPos+1,Length(sTextoImp));

      //Envio poucos caracteres para que seja possível imprimir
      //o code128 sem problemas , no SAT
      If (Length(sAux) >= 180) Then
      Begin
        oTexto.Add(sAux);
        sAux := '';
      End;
    End;

    If Trim(sTextoImp) <> ''
    Then sAux := ' ' + sAux + sTextoImp + #10;

    If Trim(sAux) <> ''
    Then oTexto.Add(sAux);

    If TrataTags(Texto) = 'S' then
    begin
      GravaLog('Elgin Nao Fiscal -> ImprimeTextoTag : ' + Texto);
      For nPos := 0 to Pred(oTexto.Count) do
      Begin
         sTextoEnv := oTexto.Strings[nPos];
         //Verifica se último caracter é #10 e remove para nao duplicar o espaco entre linhas
         If Copy(sTextoEnv,Length(sTextoEnv),1) = #10
         then sTextoEnv := Copy(sTextoEnv,1,Length(sTextoEnv)-1);

         If Pos(aArTags[23],sTextoEnv) > 0 Then //aArTags[23] == <code128>
         Begin
           GravaLog('Elgin Nao Fiscal -> ConfiguraCodigoBarras');
           iRet := fFuncConfiguraCodigoBarras(50, 1, 0, 0, 30);
           GravaLog('Elgin Nao Fiscal <- ConfiguraCodigoBarras :' + IntToStr(iRet));
         End;

         If Trim(sTextoEnv) <> '' then
         Begin
           iRet := fFuncImprimeTextoTag(sTextoEnv);
         End;
      End;
      GravaLog('Elgin Nao Fiscal <- ImprimeTextoTag :' + IntToStr(iRet));
    end
    else
    begin
      GravaLog('Elgin Nao Fiscal -> ImprimeTexto : ' + Texto);
      For nPos := 0 to Pred(oTexto.Count) do
          iRet := fFuncImprimeTexto(oTexto.Strings[nPos]);
      GravaLog('Elgin Nao Fiscal <- ImprimeTexto :' + IntToStr(iRet));
    end;
  end;  

  If iRet = 1
  then Result := '0|'
  else Result := '1|';
end;

end;

//----------------------------------------------------------------------------
function TImpNfElgin.ImpCodeBar( Tipo,Texto:String  ):String;
var
  iRet : Integer;
  sAux : String;
begin

iRet := VerStatus();

If iRet = 1 then
begin
    GravaLog('Elgin Nao Fiscal -> ConfiguraCodigoBarras');
    iRet := fFuncConfiguraCodigoBarras(100,0,3,0,5);
    GravaLog('Elgin Nao Fiscal <- ConfiguraCodigoBarras :' + IntToStr(iRet));

    If iRet = 1 then
    begin
      GravaLog('Elgin Nao Fiscal -> ImpCodeBar ( Tipo :' + Tipo + '; Texto: '+ Texto + ')');

      If Tipo = '<upc-a>'
           then iRet := fFuncImprimeCodigoBarrasUPCA(Texto)
      else If Tipo = '<ean13>'
           then iRet := fFuncImprimeCodigoBarrasEAN13(Texto)
      else If Tipo = '<ean8>'
           then iRet := fFuncImprimeCodigoBarrasEAN8(Texto)
      else If Tipo = '<code39>'
           then iRet := fFuncImprimeCodigoBarrasCODE39(Texto)
      else If Tipo = '<code93>'
           then iRet := fFuncImprimeCodigoBarrasCODE93(Texto)
      else If Tipo = '<codabar>'
           then iRet := fFuncImprimeCodigoBarrasCODABAR(Texto)
      else If Tipo = '<i2of5>' then
           begin
            sAux := Tipo;
            Insert('/',sAux,2); //cria a tag de fechamento
            If Copy(ImpTexto(Tipo + Texto + sAux),1,1) = '0'
            then iRet := 1
            else iRet := 0;
           end
      else If Tipo = '<code128>'
           then iRet := fFuncImprimeCodigoBarrasCODE128(Texto)
      else If Tipo = '<pdf>'
           then iRet := fFuncImprimeCodigoBarrasPDF417(4,3,2,0,Texto)
      else If Tipo = '<qrcode>'
           then begin
                  iRet := fFuncImprimeCodigoQRCODE(3, 3, 1, 1, 1,  Texto);
                end
      else
         GravaLog('Elgin Nao Fiscal - Tipo de Código de Barras :' + Tipo + ' não encontrado ');

      GravaLog('Elgin Nao Fiscal <- ImpCodeBar :' + IntToStr(iRet));

      if iRet = 1
      then Result := '0|'
      else Result := '1|';
    end
    else
      Result := '1|';
end;

end;

//----------------------------------------------------------------------------
function TImpNfElgin.ImpBitMap( Arquivo:String ):String;
var
  iRet : Integer;
begin

iRet := VerStatus();

If iRet = 1 then
begin
  GravaLog('Elgin Nao Fiscal -> ImprimeBmpEspecial');
  iRet := fFuncImprimeBmpEspecial(Arquivo,0,0,0);
  GravaLog('Elgin Nao Fiscal <- ImprimeBmpEspecial : ' + IntToStr(iRet));
end;

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//----------------------------------------------------------------------------
function TImpNfElgin.VerStatus(): Integer;
var
   iRet : Integer;
   sMsg : String;
begin
GravaLog('Elgin Nao Fiscal -> VerStatus');
iRet := fFuncLe_Status();
GravaLog('Elgin Nao Fiscal <- VerStatus : ' + IntToStr(iRet));

case iRet of
   5: sMsg := 'Impressora com pouco papel! Verifique';
   9: sMsg := 'Tampa Aberta';
   24:sMsg := 'Impressora ONLINE';
   32:sMsg := 'Impressora SEM PAPEL';
else
   sMsg := 'Retorno : '+ IntToStr(iRet) + ' desconhecido. Verifique manual do fabricante';
end;

If (iRet = 1) or (iRet = 24)
then Result := 1
else begin
       GravaLog(sMsg);
       LjMsgDlg(sMsg);

       If iRet = 5
       then Result := 1
       else Result := 0;
     end;
end;

//----------------------------------------------------------------------------
function TImpNfElgin.TrataTags( var Texto : String ): String;
var
   sRet,sAux,sCorrigeQrCode : String;
   nX : Integer;
begin
sRet := '';

If aArTags[1] = '' then
begin
  aArTags[1] := '<b>';
  aArTags[2] := '<ad>';
  aArTags[3] := '<s>';
  aArTags[4] := '<e>';
  aArTags[5] := '<c>';
  aArTags[6] := '<n>';
  aArTags[7] := '<l>';
  aArTags[8] := '<ce>';
  aArTags[9] := '<da>';
  aArTags[10] := '<xl>';
  aArTags[11] := '<g>';
  aArTags[12] := '<gui>';
  aArTags[13] := '<bmp>';
  aArTags[14] := '<ibmp>';
  aArTags[15] := '<cespl>';
  aArTags[16] := '<upc-a>';
  aArTags[17] := '<ean13>';
  aArTags[18] := '<ean8>';
  aArTags[19] := '<code39>';
  aArTags[20] := '<code93>';
  aArTags[21] := '<codabar>';
  aArTags[22] := '<i2of5>';
  aArTags[23] := '<code128>';
  aArTags[24] := '<pdf>';
  aArTags[25] := '<qrcode>';
  aArTags[26] := '<lmodulo>';
  aArTags[27] := '<correcao>';
end;

//------------------------------------------------
//Caso o Texto venha com comando de impressão de
//QrCode deve manda comando para ajustar o tamanho
//do mesmo
//------------------------------------------------
nX := Pos( aArTags[25],Texto);
If (nX > 0) And (Pos( aArTags[26],Texto) = 0) then
begin
  sAux := aArTags[26];
  Insert('/',sAux,2); //cria a tag de fechamento
  sCorrigeQrCode := aArTags[26] + '5' + sAux;

  sAux := aArTags[25];
  Insert('/',sAux,2); //cria a tag de fechamento
  nX := Pos(sAux,Texto);
  Insert(sCorrigeQrCode,Texto,nX); //Deve inserir a tag de ajuste antes da tag de fechamento do qrcode (</qrcode>)
  GravaLog(' Elgin Não Fiscal - Inserida a tag <lmodulo>5</lmodulo> para impressão do QRCode ');
end;

For nX:= 1 to 27 do
begin
  If Pos(aArTags[nX],Texto) > 0 then
  begin
    sRet := 'S';
    Result := sRet;
    Exit;
  end;
end;

Result := sRet;
end;

//----------------------------------------------------------------------------
function TImpNfElgin.AbreGaveta: String;
var
  iRet : Integer;
begin

GravaLog('Elgin Nao Fiscal -> AcionarGaveta');
iRet := fFuncAcionaGaveta();
GravaLog('Elgin Nao Fiscal <- AcionarGaveta : ' + IntToStr(iRet));

If iRet = 1
then Result := '0|'
else Result := '1|';
end;

//=============================================================================
initialization
  RegistraImpressora('ELGIN I9'  , TImpNfElgin  , 'BRA' ,'      ');

end.
