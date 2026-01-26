unit ImpNFiscBema;

interface

uses
  Dialogs, ImpNFiscMain, Winapi.Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms, CMC7Main, StdCtrls, ShellApi;

type

  TImpNfBema4200 = class(TImpNFiscal)
  private
  public
    function Abrir( sPorta:AnsiString; iVelocidade : Integer; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function ImpTexto( Texto : AnsiString):AnsiString; override;
    function ImpCodeBar( Tipo,Texto:AnsiString  ):AnsiString; override;
    function ImpBitMap( Arquivo:AnsiString ):AnsiString; override;
    function TrataTags( var Texto : AnsiString ): AnsiString;
    function VerStatus(): Integer;
    function ImpTxtFmt( cTexto: AnsiString ): AnsiString;
    function AltCodeBar(cMsg : AnsiString; var bTemTag : Boolean; cTipo: AnsiString = 'B'):AnsiString;
    function ImpTxtComum( Texto : AnsiString ): AnsiString;
    function CortaPapel : AnsiString ;
    function AbreGaveta(): AnsiString; override;
    function SetaEscBema : Integer;
    function StatusImp( Tipo:Integer ) : AnsiString; override;
  end;

  Function OpenBemaNF( sPorta:AnsiString; iVelocidade : Integer ):AnsiString;
  Function CloseBemaNF : AnsiString;

implementation

var
        fHandle  : THandle; //'MP2064.DLL'
        fHandle2 : THandle; //'SIUSBXP.DLL'
        aArTags : array [1..27] of AnsiString;

        //Funções da DLL
        fFuncIniciaPorta 		            : function(Porta : AnsiString): Integer; StdCall;
        fFuncBematechTX                 : function(Texto : AnsiString) :Integer; StdCall;
        fFuncComandoTX		              : function(Texto : AnsiString; Flag : Integer) : Integer; StdCall;
        fFuncCaracterGraf               : function(Texto : AnsiString; Tamanho: Integer) : Integer; StdCall;
        fFuncLe_Status		              : function() : Integer; StdCall;
        fFuncAutenticaDoc               : function( Texto : AnsiString;  Tempo : Integer) : Integer; StdCall;
        fFuncDocInsert                  : function(): Integer; StdCall;
        fFuncFechaPorta		              : function(): Integer; StdCall;
        fFuncLe_Status_Gaveta	          : function() : Integer; StdCall;
        fFuncCfgTamExt                  : function( NumeroLinhas : Integer) : Integer; StdCall;
        fFuncHabExtLongo                : function(Flag : Integer) : Integer; StdCall;
        fFuncHabEspImp                  : function(Flag : Integer) : Integer ; StdCall;
        fFuncEspImp                     : function() : Integer ; StdCall;
        fFuncConfiguraModeloImpressora  : function( ModeloImpressora : Integer) : Integer ; StdCall;
        fFuncAcionaGuilhotina           : function( Modo : Integer) : Integer ; StdCall;
        fFuncFormataTX                  : function ( BufTrans : AnsiString;  TpoLtra : Integer;  Italic : Integer;  Sublin : Integer;  Expand : Integer;  Enfat : Integer) : Integer ; StdCall;
        fFuncHabilitaPresenterRetratil  : function ( iFlag : Integer) : Integer ; StdCall;
        fFuncProgramaPresenterRetratil  : function ( iTempo : Integer) : Integer ; StdCall;
        fFuncVerificaPapelPresenter     : function () : Integer ; StdCall;
        fFuncConfiguraTaxaSerial        : function ( TaxaSerial : Integer) : Integer ; StdCall;  //9600 ou 115200

        // Função para Configuração dos Códigos de Barras
        fFuncConfiguraCodigoBarras      : function ( Altura , Largura , PosicaoCaracteres ,  Fonte ,  Margem : Integer) : Integer ; StdCall;

        // Funções para impressão dos códigos de barras
        fFuncImprimeCodigoBarrasUPCA    : function ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasUPCE    : function  ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasEAN13   : function  ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasEAN8    : function  ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasCODE39  : function  ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasCODE93  : function ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasCODE128 : function ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasITF     : function ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasCODABAR : function ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasISBN    : function  ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasMSI     : function  ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasPLESSEY : function ( Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoBarrasPDF417  : function ( NivelCorrecaoErros ,  Altura ,  Largura ,  Colunas : Integer ;  Codigo : AnsiString) : Integer ; StdCall;
        fFuncImprimeCodigoQRCODE        : function (errorCorrectionLevel , moduleSize , codeType , QRCodeVersion , encodingModes : Integer; codeQr : AnsiString) : Integer ; StdCall;

        // Funções para impressão de BitMap
        fFuncImprimeBitmap              : function  ( Name : AnsiString;  mode : Integer) : Integer ; StdCall;
        fFuncImprimeBmpEspecial         : function  ( Name : AnsiString;  xScale ,  yScale ,  angle : Integer)  : Integer ; StdCall;
        fFuncAjustaLarguraPapel         : function ( Width : Integer) : Integer ; StdCall;
        fFuncSelectDithering            : function  ( Tipo : Integer) : Integer ; StdCall;
        fFuncPrinterReset               : function () : Integer ; StdCall;
        fFuncLeituraStatusEstendido     : function () : Integer ; StdCall;
        fFuncIoControl                  : function () : Integer ; StdCall;

        bOpened : Boolean;

{***************************** Tags Especificas da Bematech **********************}
cCMDESCBEMA     : AnsiString =  Chr(29)+Chr(249)+Chr(32);
cBNegIni	: AnsiString =  Chr(27)+Chr(69);
cBNegFim	: AnsiString =  Chr(27)+Chr(70);
cBItaIni	: AnsiString =  Chr(27)+Chr(52);
cBItaFim	: AnsiString =  Chr(27)+Chr(53);
cBCondenIni	: AnsiString =  Chr(27)+Chr(15);
cBCondenFim	: AnsiString =  Chr(27)+Chr(72);
cBExpanIni	: AnsiString =  Chr(27)+Chr(87)+Chr(1);
cBExpanFim	: AnsiString =  Chr(27)+Chr(87)+Chr(0);
cBDuplaAIni	: AnsiString =  Chr(27)+Chr(100)+Chr(1);
cBDuplaAFim	: AnsiString =  Chr(27)+Chr(100)+Chr(0);
cBAlinRigth	: AnsiString =  Chr(27)+Chr(97)+Chr(2);
cBSubliIni	: AnsiString =  Chr(27)+Chr(45)+Chr(1);
cBSubliFim	: AnsiString =  Chr(27)+Chr(45)+Chr(0);
cBEnfatiIni	: AnsiString =  Chr(27)+Chr(69);
cBEnfatiFim	: AnsiString =  Chr(27)+Chr(70);
cBSubEscIni	: AnsiString =  Chr(27)+Chr(83)+Chr(1);
cBSobEscIni	: AnsiString =  Chr(27)+Chr(83)+Chr(0);
cBSubSobFim	: AnsiString =  Chr(27)+Chr(84);
cBNormal	: AnsiString =  CHR(27)+CHR(64);
cBCentralizado  : AnsiString =  CHR(27) + CHR(97) + CHR(1) ;
cBCorteTotal    : AnsiString =  CHR(27) + CHR(119);
cBCorteParcial  : AnsiString =  CHR(27) + CHR(109);

cSetaEscBema    : AnsiString =  Chr(29) + Chr(249) + Chr(53) + Chr(48);

{ ***********************   Tags do AUTODEF.CH ********************************}
TAG_NEGRITO_INI : AnsiString = '<b>';	//Inicia Texto em Negrito
TAG_ITALICO_INI	: AnsiString = '<i>';	//itálico
TAG_CENTER_INI	: AnsiString = '<ce>';	//centralizado
TAG_SUBLI_INI	: AnsiString = '<s>';	//sublinhado
TAG_EXPAN_INI 	: AnsiString = '<e>';	//expandido
TAG_CONDEN_INI	: AnsiString = '<c>';	//condensado
TAG_NORMAL_INI	: AnsiString = '<n>';	//normal
TAG_PULALI_INI	: AnsiString = '<l>';	//pula 1 linha
TAG_PULANL_INI	: AnsiString = '<sl>';	//pula NN linhas
TAG_RISCALN_INI	: AnsiString = '<tc>';	//risca a linha caracter especifico
TAG_TABS_INI	: AnsiString = '<tb>';	//tabulação
TAG_DIREITA_INI	: AnsiString = '<ad>'; //alinhado a direita
TAG_ELITE_INI	: AnsiString = '<fe>';	//habilita fonte elite
TAG_TXTEXGG_INI	: AnsiString = '<xl>';	//habilita texto extra grande
TAG_GUIL_INI	: AnsiString = '<gui>';//ativa guilhotina
TAG_EAN13_INI 	: AnsiString = '<ean13>';	//codigo de barra ean13
TAG_EAN8_INI	: AnsiString = '<ean8>';	//codigo de barra ean8
TAG_UPCA_INI	: AnsiString = '<upc-a>'; //codigo de barras upc-a
TAG_CODE39_INI	: AnsiString = '<code39>';//codigo de barras CODE39
TAG_CODE93_INI	: AnsiString = '<code93>'; //codigo de barras CODE93
TAG_CODABAR_INI	: AnsiString = '<codabar>';//codigo de barras CODABAR
TAG_MSI_INI	: AnsiString = '<msi>'; //codigo de barras MSI
TAG_CODE11_INI	: AnsiString = '<code11>';//codigo de barras CODE11
TAG_PDF_INI	: AnsiString = '<pdf>'; //codigo de barras PDF
TAG_COD128_INI	: AnsiString = '<code128>'; //codigo de barras CODE128
TAG_I2OF5_INI	: AnsiString = '<i2of5>'; //codigo I2OF5
TAG_S2OF5_INI 	: AnsiString = '<s2of5>'; //codigo S2OF5
TAG_QRCODE_INI	: AnsiString = '<qrcode>';	//codigo do tipo QRCODE
TAG_BMP_INI	: AnsiString = '<bmp>'; //imprimi logotipo carregado

//Tags disponibilizadas apenas para a bematech
TAG_ITF	   : AnsiString = '<itf>';
TAG_ISBN   : AnsiString = '<isbn>';
TAG_PLESSEY: AnsiString = '<plessey>';

//----------------------------------------------------------------------------
Function OpenBemaNF( sPorta:AnsiString; iVelocidade : Integer) : AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg:AnsiString; sArqDll:AnsiString = 'MP2064.DLL' ) : Boolean;
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
  iRet, i : Integer;
  bRet : Boolean;
  sPathLog,sIni,sAux : AnsiString;
  ListaArq : TStringList;
begin
  sPathLog  := '';
  Result    := '1|';
  GravaLog(' Bematech Não Fiscal -> OpenBemaNF');

  If Not bOpened Then
  Begin
    if FileExists('MP2064.DLL')
    then ShowMessage('Arquivo visivel e existente');

    if FileExists('SIUSBXP.DLL')
    then ShowMessage('Arquivo visivel e existente');

    GravaLog(' Bematech Não Fiscal -> Carrega MP2064.DLL ');
    fHandle  := Winapi.Windows.LoadLibrary( 'MP2064.DLL' );
    GravaLog(' Bematech Não Fiscal <- Carrega MP2064.DLL :' + IntToStr(fHandle));

    GravaLog(' Bematech Não Fiscal -> Carrega SIUSBXP.DLL ');
    fHandle2 := LoadLibrary( 'SIUSBXP.DLL' );
    GravaLog(' Bematech Não Fiscal <- Carrega SIUSBXP.DLL :' + IntToStr(fHandle2));

    if (fHandle <> 0) and (fHandle2 <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'IniciaPorta');
      if ValidPointer( aFunc, 'IniciaPorta' )
      then fFuncIniciaPorta := aFunc
      else bRet := False;
      GravaLog('Bema -> IniciaPorta');

      aFunc := GetProcAddress(fHandle,'FechaPorta');
      If ValidPointer( aFunc , 'FechaPorta' )
      then fFuncFechaPorta := aFunc
      else bRet := False;
      GravaLog('Bema -> FechaPorta');

      aFunc := GetProcAddress(fHandle,'ComandoTX');
      If ValidPointer( aFunc , 'ComandoTX' )
      then fFuncComandoTX := aFunc
      else bRet := False;
      GravaLog('Bema -> ComandoTX');

      aFunc := GetProcAddress(fHandle,'BematechTX');
      If ValidPointer( aFunc , 'BematechTX' )
      then fFuncBematechTX := aFunc
      else bRet := False;
      GravaLog('Bema -> BematechTX');

      aFunc := GetProcAddress(fHandle,'CaracterGrafico');
      If ValidPointer( aFunc , 'CaracterGrafico' )
      then fFuncCaracterGraf := aFunc
      else bRet := False;
      GravaLog('Bema -> CaracterGrafico');

      aFunc := GetProcAddress(fHandle,'Le_Status');
      If ValidPointer( aFunc , 'Le_Status' )
      then fFuncLe_Status := aFunc
      else bRet := False;
      GravaLog('Bema -> Le_Status');

      aFunc := GetProcAddress(fHandle,'AutenticaDoc');
      If ValidPointer( aFunc , 'AutenticaDoc' )
      then fFuncAutenticaDoc := aFunc
      else bRet := False;
      GravaLog('Bema -> AutenticaDoc');

      aFunc := GetProcAddress(fHandle,'DocumentInserted');
      If ValidPointer( aFunc , 'DocumentInserted' )
      then fFuncDocInsert := aFunc
      else bRet := False;
      GravaLog('Bema -> DocumentInserted');

      aFunc := GetProcAddress(fHandle,'Le_Status_Gaveta');
      If ValidPointer( aFunc , 'Le_Status_Gaveta' )
      then fFuncLe_Status_Gaveta := aFunc
      else bRet := False;
      GravaLog('Bema -> Le_Status_Gaveta');

      aFunc := GetProcAddress(fHandle,'ConfiguraTamanhoExtrato');
      If ValidPointer( aFunc , 'ConfiguraTamanhoExtrato' )
      then fFuncCfgTamExt := aFunc
      else bRet := False;
      GravaLog('Bema -> ConfiguraTamanhoExtrato');

      aFunc := GetProcAddress(fHandle,'HabilitaExtratoLongo');
      If ValidPointer( aFunc , 'HabilitaExtratoLongo' )
      then fFuncHabExtLongo := aFunc
      else bRet := False;
      GravaLog('Bema -> HabilitaExtratoLongo');

      aFunc := GetProcAddress(fHandle,'HabilitaEsperaImpressao');
      If ValidPointer( aFunc , 'HabilitaEsperaImpressao' )
      then fFuncHabEspImp := aFunc
      else bRet := False;
      GravaLog('Bema -> HabilitaEsperaImpressao');

      aFunc := GetProcAddress(fHandle,'EsperaImpressao');
      If ValidPointer( aFunc , 'EsperaImpressao' )
      then fFuncEspImp := aFunc
      else bRet := False;
      GravaLog('Bema -> EsperaImpressao');

      aFunc := GetProcAddress(fHandle,'ConfiguraModeloImpressora');
      If ValidPointer( aFunc , 'ConfiguraModeloImpressora' )
      then fFuncConfiguraModeloImpressora := aFunc
      else bRet := False;
      GravaLog('Bema -> ConfiguraModeloImpressora');

      aFunc := GetProcAddress(fHandle,'AcionaGuilhotina');
      If ValidPointer( aFunc , 'AcionaGuilhotina' )
      then fFuncAcionaGuilhotina := aFunc
      else bRet := False;
      GravaLog('Bema -> AcionaGuilhotina');

      aFunc := GetProcAddress(fHandle,'FormataTX');
      If ValidPointer( aFunc , 'FormataTX' )
      then fFuncFormataTX := aFunc
      else bRet := False;
      GravaLog('Bema -> FormataTX');

      aFunc := GetProcAddress(fHandle,'HabilitaPresenterRetratil');
      If ValidPointer( aFunc , 'HabilitaPresenterRetratil' )
      then fFuncHabilitaPresenterRetratil := aFunc
      else bRet := False;
      GravaLog('Bema -> HabilitaPresenterRetratil');

      aFunc := GetProcAddress(fHandle,'ProgramaPresenterRetratil');
      If ValidPointer( aFunc , 'ProgramaPresenterRetratil' )
      then fFuncProgramaPresenterRetratil := aFunc
      else bRet := False;
      GravaLog('Bema -> ProgramaPresenterRetratil');

      aFunc := GetProcAddress(fHandle,'VerificaPapelPresenter');
      If ValidPointer( aFunc , 'VerificaPapelPresenter' )
      then fFuncVerificaPapelPresenter := aFunc
      else bRet := False;
      GravaLog('Bema -> VerificaPapelPresenter');

      aFunc := GetProcAddress(fHandle,'ConfiguraTaxaSerial');
      If ValidPointer( aFunc , 'ConfiguraTaxaSerial' )
      then fFuncConfiguraTaxaSerial := aFunc
      else bRet := False;
      GravaLog('Bema -> ConfiguraTaxaSerial');

      aFunc := GetProcAddress(fHandle,'ConfiguraCodigoBarras');
      If ValidPointer( aFunc , 'ConfiguraCodigoBarras' )
      then fFuncConfiguraCodigoBarras := aFunc
      else bRet := False;
      GravaLog('Bema -> ConfiguraCodigoBarras');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasUPCA');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasUPCA' )
      then fFuncImprimeCodigoBarrasUPCA := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasUPCA');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasUPCE');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasUPCE' )
      then fFuncImprimeCodigoBarrasUPCE := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasUPCE');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasEAN13');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasEAN13' )
      then fFuncImprimeCodigoBarrasEAN13 := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasEAN13');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasEAN8');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasEAN8' )
      then fFuncImprimeCodigoBarrasEAN8 := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasEAN8');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasCODE39');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasCODE39' )
      then fFuncImprimeCodigoBarrasCODE39 := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasCODE39');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasCODE93');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasCODE93' )
      then fFuncImprimeCodigoBarrasCODE93 := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasCODE93');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasCODE128');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasCODE128' )
      then fFuncImprimeCodigoBarrasCODE128 := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasCODE128');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasITF');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasITF' )
      then fFuncImprimeCodigoBarrasITF := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasITF');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasCODABAR');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasCODABAR' )
      then fFuncImprimeCodigoBarrasCODABAR := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasCODABAR');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasISBN');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasISBN' )
      then fFuncImprimeCodigoBarrasISBN := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasISBN');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasMSI');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasMSI' )
      then fFuncImprimeCodigoBarrasMSI := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasMSI');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasPLESSEY');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasPLESSEY' )
      then fFuncImprimeCodigoBarrasPLESSEY := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasPLESSEY');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoBarrasPDF417');
      If ValidPointer( aFunc , 'ImprimeCodigoBarrasPDF417' )
      then fFuncImprimeCodigoBarrasPDF417 := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoBarrasPDF417');

      aFunc := GetProcAddress(fHandle,'ImprimeCodigoQRCODE');
      If ValidPointer( aFunc , 'ImprimeCodigoQRCODE' )
      then fFuncImprimeCodigoQRCODE := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeCodigoQRCODE');

      aFunc := GetProcAddress(fHandle,'ImprimeBitmap');
      If ValidPointer( aFunc , 'ImprimeBitmap' )
      then fFuncImprimeBitmap := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeBitmap');

      aFunc := GetProcAddress(fHandle,'ImprimeBmpEspecial');
      If ValidPointer( aFunc , 'ImprimeBmpEspecial' )
      then fFuncImprimeBmpEspecial := aFunc
      else bRet := False;
      GravaLog('Bema -> ImprimeBmpEspecial');

      aFunc := GetProcAddress(fHandle,'AjustaLarguraPapel');
      If ValidPointer( aFunc , 'AjustaLarguraPapel' )
      then fFuncAjustaLarguraPapel := aFunc
      else bRet := False;
      GravaLog('Bema -> AjustaLarguraPapel');

      aFunc := GetProcAddress(fHandle,'SelectDithering');
      If ValidPointer( aFunc , 'SelectDithering' )
      then fFuncSelectDithering := aFunc
      else bRet := False;
      GravaLog('Bema -> SelectDithering');

      aFunc := GetProcAddress(fHandle,'PrinterReset');
      If ValidPointer( aFunc , 'PrinterReset' )
      then fFuncPrinterReset := aFunc
      else bRet := False;
      GravaLog('Bema -> PrinterReset');

      aFunc := GetProcAddress(fHandle,'LeituraStatusEstendido');
      If ValidPointer( aFunc , 'LeituraStatusEstendido' )
      then fFuncLeituraStatusEstendido := aFunc
      else bRet := False;
      GravaLog('Bema -> LeituraStatusEstendido');

      aFunc := GetProcAddress(fHandle,'IoControl');
      If ValidPointer( aFunc , 'IoControl' )
      then fFuncIoControl := aFunc
      else bRet := False;
      GravaLog('Bema -> IoControl');
    end
    else
    begin
      LjMsgDlg('A DLL: MP2064.DLL e/ou SIUSBXP.DLL não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      GravaLog('Bematech Nao Fiscal -> Setando Modelo Impressora');

      //Caso seja Bema MP-4200 seta com modelo 7; para Bema-MP4000 seta com 5;
      i := 7;
      iRet := fFuncConfiguraModeloImpressora(i);
      GravaLog('Bematech Nao Fiscal <- Setando Modelo Impressora : ' + IntToStr(iRet));

      If (iRet = 1) and (Copy(sPorta,1,3) = 'COM') then
      begin
        GravaLog('Bematech Nao Fiscal  -> ConfiguraSerial : Velocidade = ' + IntToStr(iVelocidade));
        fFuncConfiguraTaxaSerial(iVelocidade);
        GravaLog('Bematech Nao Fiscal  <- ConfiguraSerial : sem retorno' );
      end;

      If iRet = 1 then
      begin
        GravaLog('Bematech Nao Fiscal  -> IniciaPorta ');
        iRet := fFuncIniciaPorta(Trim(sPorta));
        GravaLog('Bematech Nao Fiscal  <- IniciaPorta : iRet = ' + IntToStr(iRet));
      end;

      GravaLog('Bematech Nao Fiscal  -> HabilitaEsperaImpressao');
      i := fFuncHabEspImp(1);
      GravaLog('Bematech Nao Fiscal  <- HabilitaEsperaImpressao : iRet = ' + IntToStr(i));

      try
        ListaArq := TStringList.Create;

        //Log do Arquivo de Configuração
        sIni := ExtractFilePath(Application.ExeName) + 'BEMAFI32.INI';
        If FileExists(sIni) then
        Begin
          ListaArq.Clear;
          ListaArq.LoadFromFile(sIni);

          GravaLog(' ******** Arquivo BEMAFI32.INI *******');
          GravaLog( ListaArq.Text );
          GravaLog(' ******** Final da Leitura do Arquivo BEMAFI32.INI *******');
        End;

        //Log do Arquivo de Configuração
        sIni := ExtractFilePath(Application.ExeName) + 'MP2064.INI';
        If FileExists(sIni) then
        begin
          ListaArq.Clear;
          ListaArq.LoadFromFile(sIni);

          GravaLog(' ******** Arquivo MP2064.INI *******');
          GravaLog( ListaArq.Text );
          GravaLog(' ******** Final da Leitura do Arquivo MP2064.INI *******');
        End;
      Except
        GravaLog(' Não foi possível carregar/ler o arquivo BEMAFI32.INI ');
      end;

      If iRet <> 1 then
      begin
        LjMsgDlg('Bematech Nao Fiscal -> Erro na abertura da porta');
        Result := '1|';
      end
      else
      begin
        bOpened := True;
        Result := '0|';
      end;
    end
    else
    begin
      Result := '1|';
      GravaLog('Bematech Não Fiscal -> Função da DLL não foi carregada');
    end;
  end;
end;

//----------------------------------------------------------------------------
Function CloseBemaNF : AnsiString;
Var
  iRet : Integer;
begin
  If bOpened Then
  Begin
    If fHandle <> INVALID_HANDLE_VALUE then
    begin
      GravaLog('Bematech Nao Fiscal  -> FechaPorta ');
      iRet := fFuncFechaPorta();
      GravaLog('Bematech Nao Fiscal  <- FechaPorta : iRet = ' + IntToStr(iRet));

      FreeLibrary(fHandle);
      fHandle := 0;
    end;

    bOpened := False;
  End;
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpNfBema4200.Abrir(sPorta : AnsiString; iVelocidade : Integer ; iHdlMain:Integer) : AnsiString;
Var
  sRet : AnsiString;
begin

GravaLog('Bema -> Abrir porta ');

If Not bOpened
Then sRet := OpenBemaNF(sPorta, iVelocidade )
Else sRet := '0|';

If Copy(sRet,1,1) = '0'
then GravaLog('Bematech Nao Fiscal - Sucesso ao abrir porta');

GravaLog('Bema <- Abrir porta :' + sRet);
Result := sRet;

end;

//----------------------------------------------------------------------------
function TImpNfBema4200.Fechar( sPorta:AnsiString ):AnsiString;
begin
Result := CloseBemaNF();
end;

//----------------------------------------------------------------------------
function TImpNfBema4200.ImpTexto( Texto : AnsiString):AnsiString;
var
  iRet  : Integer;
  sAux,sRet: AnsiString;
  bCorte : Boolean;
  cEOF : AnsiString;
begin
sRet      := '';
bCorte    := False;

//Verifica se vai efetuar corte de papel
sAux := TAG_GUIL_INI;
Insert('/',sAux,2);
if Concat(TAG_GUIL_INI,sAux) = Trim(Texto) then
begin
  bCorte := True;

  iRet := VerStatus();

  If iRet = 1 then
  begin
    sRet := CortaPapel();
    If Copy(sRet,1,1) = '0'
    then iRet := 1
    else iRet := 0;
  end;

  If iRet = 1
  then Result := '0|'
  else Result := '1|';
end;

If (not bCorte) and (Trim(Texto) <> '') then
begin
  iRet := SetaEscBema();
  iRet := VerStatus();

  If iRet = 1 then
  begin
    If TrataTags(Texto) = 'S' then
    begin
      GravaLog('Bematech Nao Fiscal  -> ImprimeTextoTag : ' + Texto);
      sRet := ImpTxtFmt( Texto );
      GravaLog('Bematech Nao Fiscal  <- ImprimeTextoTag : iRet = ' + IntToStr(iRet));
    end
    else
    begin
      GravaLog('Bematech Nao Fiscal  -> ImprimeTexto : ' + Texto);
      sRet := ImpTxtComum(Texto);
      GravaLog('Bematech Nao Fiscal  <- ImprimeTexto : iRet = ' + sRet);
    end;

    If Copy(sRet,1,1) = '0'
    then iRet := 1
    else iRet := 0;
  end;

  If iRet = 1
  then Result := '0|'
  else Result := '1|';
end;

end;


//------------------------------------------------------------------------------
function TImpNfBema4200.AltCodeBar(cMsg : AnsiString; var bTemTag : Boolean; cTipo: AnsiString = 'B'):AnsiString;
var
   nI : Integer;
   cTexto,cIndic,cTag,cTroca : AnsiString;
   aTags : array [1..18] of AnsiString;
begin
aTags[1] := TAG_EAN13_INI;
aTags[2] := TAG_EAN8_INI;
aTags[3] := TAG_UPCA_INI;
aTags[4] := TAG_CODE39_INI;
aTags[5] := TAG_CODE93_INI;
aTags[6] := TAG_CODABAR_INI;
aTags[7] := TAG_MSI_INI;
aTags[8] := TAG_CODE11_INI;
aTags[9] := TAG_PDF_INI;
aTags[10] := TAG_COD128_INI;
aTags[11] := TAG_I2OF5_INI;
aTags[12] := TAG_S2OF5_INI;
aTags[13] := TAG_QRCODE_INI;
aTags[14] := TAG_ITF;
aTags[15] := TAG_ISBN;
aTags[16] := TAG_PLESSEY;
aTags[17] := TAG_BMP_INI;
aTags[18] := TAG_GUIL_INI;

cTexto := cMsg;
bTemTag:= False;

//QUANDO PASSADO "B" SERVE PARA PROTECAO DA TAG, em Branco indica a remoção da mesma
If cTipo = 'B'
then cIndic := ''
Else cIndic := 'B';

For nI := 1 to 18 do
begin
  cTag := aTags[nI];
  Insert(cIndic,cTag,2);
  While Pos(cTag,cTexto) > 0 do
  begin
    cTroca := aTags[nI];
    Insert(cTipo,cTroca,2);
    cTexto := StringReplace(cTexto,cTag,cTroca,[rfReplaceAll]);

    cTag := aTags[nI];
    Insert('/' + cIndic,cTag,2);

    cTroca := aTags[nI];
    Insert('/'+cTipo,cTroca,2);
    cTexto := StringReplace(cTexto,cTag, cTroca,[rfReplaceAll]);
    bTemTag:= True;
  End;
end;

Result := cTexto;
end;

//-----------------------------------------------------------------------------
Function  TImpNfBema4200.ImpTxtFmt( cTexto: AnsiString ): AnsiString;
var
  cI,cAux,cLinha, cTag, cRet: AnsiString;
  aTags	 : array [1..18] of AnsiString;
  nI,nF,nPos,x,iRet : Integer;
  bRetorno, bTemTag : Boolean;
begin

aTags[1] := TAG_EAN13_INI;
aTags[2] := TAG_EAN8_INI;
aTags[3] := TAG_UPCA_INI;
aTags[4] := TAG_CODE39_INI;
aTags[5] := TAG_CODE93_INI;
aTags[6] := TAG_CODABAR_INI;
aTags[7] := TAG_MSI_INI;
aTags[8] := TAG_CODE11_INI;
aTags[9] := TAG_PDF_INI;
aTags[10] := TAG_COD128_INI;
aTags[11] := TAG_I2OF5_INI;
aTags[12] := TAG_S2OF5_INI;
aTags[13] := TAG_QRCODE_INI;
aTags[14] := TAG_ITF;
aTags[15] := TAG_ISBN;
aTags[16] := TAG_PLESSEY;
aTags[17] := TAG_BMP_INI;
aTags[18] := TAG_GUIL_INI;

nI   := 0;
cRet := '';
cAux := AltCodeBar(cTexto, bTemTag ,'');

//Neste momento somente avalia a existência de Tag de Codigo de Barras/QrCode e Bitmap, pois o resto já foi removido
nPos := Pos('<',cAux);
While nPos > 0 do
begin
  nF := Pos('>',cAux);
  cI := Copy(cAux,nPos,(nF-nPos)+1); //Extrai a Tag

  For x:= 1 to 18 do
     If aTags[x] = cI then
     begin
       nI := x;
       Break;
     end;
    
  //Valida se é uma tag válida
  If nI > 0 then
  begin
    If nPos = 1 then
    begin
       cTag := cI;
       Insert('/',cTag,2);
       nF   := Pos(cTag,cAux);

       cLinha	:= Copy(cAux,1,nF+Length(cTag)-1);
       cAux	:= StringReplace(cAux,cLinha,'',[]);

       //Remove da cLinha as tags
       cLinha	:= StringReplace(cLinha,cI,'',[]);
       cLinha	:= StringReplace(cLinha,cTag,'',[]);

       If cI = TAG_BMP_INI
       then cRet := ImpBitMap(cLinha)
       else If cI = TAG_GUIL_INI
       then cRet := CortaPapel()
       Else cRet := ImpCodeBar(cI,cLinha);
    end
    Else If nPos > 0 then
         begin
	   cLinha  := Copy(cAux,1,nPos-1);
	   cAux	   := StringReplace(cAux,cLinha,'',[]);
	   cRet    := ImpTxtComum(cLinha);
         End
    Else
    begin
    	//Altera aqui para tentar evitar looping infinito
        cAux := StringReplace(cAux,'<','',[]);
    end;

    nPos:= Pos('<',cAux);
    bRetorno:= True;
  end;
End;

//Se ainda houver texto imprime o restante como texto comum
If (Trim(cAux) <> '')
then cRet := ImpTxtComum(cAux);

Result := cRet;

End;

//------------------------------------------------------------------------------
function TImpNfBema4200.ImpTxtComum( Texto : AnsiString ) : AnsiString;
var
  iRet, nPos, nPos2 : Integer;
  sTextoImp,sAux : AnsiString;
  oTexto : TStringList;
begin
oTexto := TStringList.Create;
oTexto.Clear;
sTextoImp := Texto;
sAux   := '';

iRet := VerStatus();
If iRet = 1 then
begin
  nPos := Pos(#10,sTextoImp);
  While nPos > 0 do
  Begin
    nPos  := Pos(#10,sTextoImp);
    sAux  := sAux + Copy(sTextoImp,1,nPos) ;
    sTextoImp := Copy(sTextoImp,nPos+1,Length(sTextoImp));

    If Length(sAux) >= 400 Then
    Begin
        //Se o proximo comando for  centralizado
        //envia no mesmo comando, pois a impressora ignora o comando
        //centralizado sozinho
        nPos2 := Pos(cBCentralizado,sTextoImp);
        If nPos2 = 1 Then
                Begin
                    sAux := sAux + cBCentralizado;
                    sTextoImp := Copy(sTextoImp,nPos2 + Length(cBCentralizado),Length(sTextoImp));
                    nPos  := Pos(#10,sTextoImp);
                End;
        oTexto.Add(sAux);
        sAux := '';
    end;
  End;

  If Trim(sTextoImp) <> ''
  Then sAux := ' ' + sAux + sTextoImp + #10;

  If Trim(sAux) <> ''
  Then oTexto.Add(sAux);

  For nPos := 0 to Pred(oTexto.Count) do
  Begin
    iRet := fFuncBematechTX(oTexto.Strings[nPos]);
        GravaLog('Bematech Nao Fiscal  -> BematechTX : ' + oTexto.Strings[nPos] );
        GravaLog('Bematech Nao Fiscal  <- BematechTX : ' + IntToStr(iRet));
  End;
end;

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//----------------------------------------------------------------------------
function TImpNfBema4200.ImpCodeBar( Tipo,Texto:AnsiString  ):AnsiString;
var
  iRet,iPasso,iInicio : Integer;
  sAux , sCmd, sTamQrCd: AnsiString;
begin

iRet := VerStatus();

If iRet = 1 then
begin
    GravaLog('Bematech Nao Fiscal  -> ConfiguraCodigoBarras');
    iRet := fFuncConfiguraCodigoBarras(90,0,0,0,0);
    GravaLog('Bematech Nao Fiscal  <- ConfiguraCodigoBarras : iRet = ' + IntToStr(iRet));

    If iRet = 1 then
    begin
      GravaLog('Bematech Nao Fiscal  -> ImpCodeBar ( Tipo :' + Tipo + '; Texto: '+ Texto + ')');

      If Tipo = TAG_UPCA_INI
           then iRet := fFuncImprimeCodigoBarrasUPCA(Texto)
      else If Tipo = TAG_EAN13_INI
           then iRet := fFuncImprimeCodigoBarrasEAN13(Texto)
      else If Tipo = TAG_EAN8_INI
           then iRet := fFuncImprimeCodigoBarrasEAN8(Texto)
      else If Tipo = TAG_CODE39_INI
           then iRet := fFuncImprimeCodigoBarrasCODE39(Texto)
      else If Tipo = TAG_CODE93_INI
           then iRet := fFuncImprimeCodigoBarrasCODE93(Texto)
      else If Tipo = TAG_CODABAR_INI
           then iRet := fFuncImprimeCodigoBarrasCODABAR(Texto)
      else If Tipo = TAG_COD128_INI
           then iRet := fFuncImprimeCodigoBarrasCODE128(Texto)
      else If Tipo = TAG_PDF_INI
           then iRet := fFuncImprimeCodigoBarrasPDF417(4,3,2,0,Texto)
      else If Tipo = TAG_QRCODE_INI
           then begin
                   sCmd := #27 + #97 + #1 ;       // código da centralização
                   iRet := fFuncComandoTX(sCmd,Length(sCmd));

                   sTamQrCd := UpperCase(SigaLojaINI( '','logdll','tamqrcode','P' ));

                   GravaLog('Bematech Nao Fiscal  -> ImpCodeBar ( Tamanho do QrCode [' + sTamQrCd + '] - configurado no arquivo SIGALOJA.INI)');

                   iPasso := 0;
                   iInicio:= 14;
                   If Length(Texto) > 200 then //devido a qtde de caracteres, deve aumentar o padrão para verificar diferença de tamanhos
                   begin
                     iPasso := 3;
                   end;

                   If sTamQrCd = 'M'
                   then iInicio := 17
                   else If sTamQrCd = 'G'
                   then iInicio := 20;

                   iRet := fFuncImprimeCodigoQRCODE(1, 4, 0, iInicio + iPasso, 1,Texto);
                end
      else
      GravaLog('Bematech Nao Fiscal  - Tipo de Código de Barras :' + Tipo + ' não encontrado ');

      GravaLog('Bematech Nao Fiscal  <- ImpCodeBar : iRet = ' + IntToStr(iRet));

      if iRet = 1
      then Result := '0|'
      else Result := '1|';
    end
    else
      Result := '1|';
end;

end;

//----------------------------------------------------------------------------
function TImpNfBema4200.ImpBitMap( Arquivo:AnsiString ):AnsiString;
var
  iRet : Integer;
begin

iRet := VerStatus();

If (Trim(Arquivo) <> '') and (iRet = 1) then
begin
  GravaLog('Bematech Nao Fiscal  -> ImprimeBmp');
  iRet := fFuncImprimeBitmap(Arquivo,0);
  GravaLog('Bematech Nao Fiscal  <- ImprimeBmp: iRet = ' + IntToStr(iRet));
end;

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//----------------------------------------------------------------------------
function TImpNfBema4200.VerStatus(): Integer;
var
   iRet, iWait, i : Integer;
   sMsg : AnsiString;
begin

i := 0;
GravaLog('Bematech Nao Fiscal  -> VerStatus');
iRet := 1;

while i < 4 do
begin
  iRet := fFuncLe_Status();
  If iRet <> 0
  then Break
  else
    begin
      Sleep(1500);
      GravaLog('Bematech Nao Fiscal -> VerStatus - Tentando novamente (' + IntToStr(i) + ')');
      Inc(i);
    end;
end;

GravaLog('Bematech Nao Fiscal  <- VerStatus : iRet = ' + IntToStr(iRet));

case iRet of
   0: sMsg := 'Erro de comunicação';
   1: sMsg := 'Impressora OK';
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
function TImpNfBema4200.TrataTags( var Texto : AnsiString ): AnsiString;
var
   sRet,sAux, cMsg, cTag : AnsiString;
   nX : Integer;
   bTemTag : Boolean;
begin
sRet := '';
cMsg := Texto;

While Pos(TAG_NORMAL_INI, cMsg) > 0 do
begin
  cTag := TAG_NORMAL_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_NORMAL_INI,cBNormal,[]);
  cMsg := StringReplace(cMsg,cTag,cBNormal,[]);
  sRet := 'S';
end;

while Pos(TAG_NEGRITO_INI, cMsg) > 0 do
begin
  cTag := TAG_NEGRITO_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_NEGRITO_INI, cBNegIni,[]);
  cMsg := StringReplace(cMsg,cTag, cBNegFim,[]);
  sRet := 'S';
end;

while Pos(TAG_EXPAN_INI,cMsg) > 0 do
begin
  cTag := TAG_EXPAN_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_EXPAN_INI, cBExpanIni,[]);
  cMsg := StringReplace(cMsg,cTag, cBExpanFim,[]);
  sRet := 'S';
end;

While Pos(TAG_ITALICO_INI,cMsg) > 0 do
begin
  cTag := TAG_ITALICO_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_ITALICO_INI, cBItaIni,[]);
  cMsg := StringReplace(cMsg,cTag, cBItaFim,[]);
  sRet := 'S';
end;

while Pos(TAG_CONDEN_INI,cMsg) > 0 do
begin
  cTag := TAG_CONDEN_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_CONDEN_INI, cBCondenIni,[]);
  cMsg := StringReplace(cMsg,cTag, cBCondenFim,[]);
  sRet := 'S';
end;
//Assim como na TotvsApi, esta tag não estava sendo removida totalmente,
//por trato o fechamento da Tag Condensado (</c>)
While Pos(cTag,cMsg) > 0 do
begin
  cMsg := StringReplace(cMsg,cTag,cBCondenFim,[]);
  sRet := 'S';
End;

While Pos(TAG_ELITE_INI,cMsg) > 0 do
begin
  cTag := TAG_ELITE_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_ELITE_INI, cBDuplaAIni,[]);
  cMsg := StringReplace(cMsg,cTag, cBDuplaAFim,[]);
  sRet := 'S';
end;

While Pos(TAG_SUBLI_INI,cMsg) > 0 do
begin
  cTag := TAG_SUBLI_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_SUBLI_INI, cBSubliIni,[]);
  cMsg := StringReplace(cMsg,cTag, cBSubliFim,[]);
  sRet := 'S';
end;

While Pos(TAG_TXTEXGG_INI,cMsg) > 0 do
begin
  cTag := TAG_TXTEXGG_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_TXTEXGG_INI, cBEnfatiIni,[]);
  cMsg := StringReplace(cMsg,cTag, cBEnfatiFim,[]);
  sRet := 'S';
End;

While Pos(TAG_CENTER_INI,cMsg) > 0 do
begin
  cTag := TAG_CENTER_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_CENTER_INI,cBCentralizado,[]);
  cMsg := StringReplace(cMsg,cTag,cBNormal,[]);
  sRet := 'S';
end;

While Pos(TAG_GUIL_INI,cMsg) > 0 do
begin
  cTag := TAG_GUIL_INI;
  Insert('/',cTag,2);
  cMsg := StringReplace(cMsg,TAG_GUIL_INI,cBCorteTotal,[]);
  cMsg := StringReplace(cMsg,cTag,'',[]);
  sRet := 'S';
end;

//Caso o qrcode/bitmap esteja inserido no meio do texto deve 
//tratar para imprimir separadamente por isso deve proteger os comandos
cMsg := AltCodeBar(cMsg, bTemTag ,'B');

//Efetua a remoção das tags "desconhecidas" pela bematech
cMsg := RemoveTags( cMsg );
Texto := cMsg;

If bTemTag
then sRet := 'S';

Result := sRet;
end;

//------------------------------------------------------------------------------
function TImpNfBema4200.CortaPapel : AnsiString;
var
   iRet : Integer;
begin
GravaLog('Bematech Nao Fiscal -> AcionaGuilhotina ');
iRet := fFuncAcionaGuilhotina(0); //Manda corte inteiro
GravaLog('Bematech Nao Fiscal <- AcionaGuilhotina : iRet = ' + IntToStr(iRet));

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//----------------------------------------------------------------------------
function TImpNfBema4200.AbreGaveta : AnsiString;
var
  iRet : Integer;
  sCmd : AnsiString;
begin
GravaLog('Bematech Nao Fiscal -> AcionarGaveta');
sCmd := #27 + #118 + #140;
iRet := fFuncComandoTX( sCmd, Length( sCmd ));
GravaLog('Bematech Nao Fiscal <- AcionarGaveta : ' + IntToStr(iRet));

If iRet = 1
then Result := '0|'
else Result := '1|';
end;

function TImpNfBema4200.SetaEscBema: Integer;
var
  iRet : Integer;
begin
GravaLog('Bematech Nao Fiscal -> Seta Comando Esc/Bema');
iRet := fFuncComandoTX( cSetaEscBema, Length( cSetaEscBema ));
GravaLog('Bematech Nao Fiscal - Seta Comando Esc/Bema <- iRet: ' + IntToStr(iRet));
Result := iRet;
end;

function TImpNfBema4200.StatusImp(Tipo: Integer): AnsiString;
begin
  GravaLog('StatusImp -> Comando não implementado para este modelo');
  Result := '0|';
end;


initialization
  RegistraImpressora('BEMATECH MP-4200 TH 01.00.00(S)'  , TImpNfBema4200  , 'BRA' ,'      ');
  RegistraImpressora('BEMATECH TH'  , TImpNfBema4200  , 'BRA' ,'      ');

end.
