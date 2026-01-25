unit ImpEpson;

interface

uses
  Dialogs, ImpFiscMain, ImpCheqMain, Windows, SysUtils, classes, LojxFun, IniFiles, ComObj, Forms, CommInt;

Type

  TEpson = class(TCustomComm)
  protected
      procedure Comm1Error(Sender: TObject; Errors: Integer);
  public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

  ImpEpsonTMH6000II = class(TImpressoraFiscal)
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function LeituraX:String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function FechaEcf:String; override;
    function AbreEcf:String; override;
    function HorarioVerao( Tipo:String ):String; override;
    function PegaSerie:String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function Gaveta:String; override;
    function Status( Tipo:Integer; Texto:String ):String; override;
    function Suprimento( Tipo:Integer;Valor:String;Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function FechaCupomNaoFiscal: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function LeCondPag:String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function PegaPDV:String; override;
    function AlimentaPropEmulECF( sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:String ):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function CancelaCupom(Supervisor:String):String; override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function RelatorioGerencial( Texto:String;Vias:Integer; ImgQrCode: String):String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:String ): String; override;
    function ImpostosCupom(Texto: String): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String; override;
    function LeTotNFisc:String; override;
    function DownMF(sTipo, sInicio, sFinal : String):String; override;
    function RedZDado( MapaRes : String):String; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
    function ImpTxtFis(Texto : String) : String; Override;
    function RelGerInd( cIndTotalizador,Texto : String; nVias: Integer; ImgQrCode: String): String; Override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
  end;

  ChqEpsonTMH6000II = class(TImpressoraCheque)
  public
    function Abrir( aPorta:String ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar(aPorta:String ): Boolean; override;
    function StatusCh( Tipo:Integer ):String; override;    
  end;

  ImpEpsonTMU220AF = class(ImpEpsonTMH6000II)
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function PegaPDV:String; override;
    function LeituraX:String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function PegaSerie: String; override;
    function AbreECF: String; override;
    function FechaECF: String; override;
    function Status( Tipo: Integer;Texto:String ):String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function EnvCmd( Comando:String; Posicao: Integer ): String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function Percepcao(sAliq, sTexto, sValor: String): String; override;
    function SubTotal(sImprime: String):String;override;
    function Pagamento(Pagamento,Vinculado,Percepcion:String): String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function MemTrab:String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function ImpostosCupom(Texto: String): String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function GravaCondPag( condicao:string ) : String; override;
    function Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function AbreDNFH( sTipoFat, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: String): String; override; 
    function FechaDNFH: String; override;
    function Gaveta:String; override;
    function ReImprime: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function AbreNota(Cliente:String):String; override;
    function RelatorioGerencial( Texto:String;Vias:Integer; ImgQrCode: String):String; override;
    function HorarioVerao( Tipo:String ):String; override;
    procedure AlimentaProperties; override;
    function ImpTxtFis(Texto : String) : String; override;
  end;

  ImpEpsonTM300AF = class(ImpEpsonTMU220AF)
  public
    function PegaCupom(Cancelamento:String):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String; override;
    function FechaCupom( Mensagem:String ):String; override;
  end;

  ImpEpsonT900FA = class(TImpressoraFiscal)
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function PegaPDV:String; override;
    function LeituraX:String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function PegaSerie: String; override;
    function AbreECF: String; override;
    function FechaECF: String; override;
    function Status( Tipo: Integer;Texto:String ):String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function EnvCmd( Comando:String; Posicao: Integer ): String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function Percepcao(sAliq, sTexto, sValor: String): String; override;
    function SubTotal(sImprime: String):String;override;
    function Pagamento(Pagamento,Vinculado,Percepcion:String): String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function MemTrab:String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function ImpostosCupom(Texto: String): String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function GravaCondPag( condicao:string ) : String; override;
    function Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function AbreDNFH( sTipoFat, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: String): String; override; 
    function FechaDNFH: String; override;
    function Gaveta:String; override;
    function ReImprime: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function AbreNota(Cliente:String):String; override;
    function RelatorioGerencial( Texto:String;Vias:Integer; ImgQrCode: String):String; override;
    function HorarioVerao( Tipo:String ):String; override;
    procedure AlimentaProperties; override;
    function ImpTxtFis(Texto : String) : String; override;

    //Funções Genéricas
    function TM900FACmdExcRet(sCmd : String; nInd,nTamRet: Integer; bExecCmd : Boolean; var aResp: array of Byte): String;
    function TM900FACodError( iRet : Integer; bMsg : Boolean = True ): Integer;
    function TM900FADescErro( CodError : Integer ): String;
    function TM900FAUnMedida( cUM : string ): Integer;
    function TM900FACodIVA(sAliq : String): Integer;
    function TM900FACodII(sValor: String; var sAliq: String): Integer;
    function TM900FACompAtual(): String;
  end;

function Imprimir( sTexto:String ):Boolean;
function EnviaComando(sComando: String): Boolean;
function CortarPapel: Boolean;
function EpsonErrorMsg( sError, sTipo:String ): String;
function EpsonError( bShow: Boolean ):String;
procedure EpsonLog(Arquivo,Texto:String );
Function TrataTags( Mensagem : String ) : String;

implementation

var
  Comm1     : TEpson;
  sRetorno  : String;
  bRet      : Boolean;
  cArqLog   : String;
  sJournal  : String;
  sPDV      : String;
  sTipoCup  : String;
  sCupom    : String;
  multiLine : boolean;

  EPS_GetState        : function : integer; stdcall;
  EPS_SetCommPort     : function (port : integer): integer ; stdcall;
  EPS_GetCommPort     : function : integer ; stdcall;
  EPS_OpenPort        : function : WordBool; stdcall;
  EPS_ClosePort       : function : WordBool; stdcall;
  EPS_Purge           : function : WordBool; stdcall;
  EPS_AddDataField    : function (field : WideString) : WordBool; stdcall;
  EPS_SendCommand     : function : WordBool; stdcall;
  EPS_GetExtraField   : function (FieldNumber: Integer): WideString; stdcall;
  EPS_GetBoundRate    : function : Integer; stdcall;
  EPS_SetBoundRate    : function ( boundRate : Integer) : WordBool; stdcall;
  EPS_SetProtocolType : function ( protType : integer ) : WordBool; stdcall;
  EPS_GetProtocolType : function : integer; stdcall;
  EPS_LastError       : function : integer; stdcall;
  EPS_ExtraFieldsCount: function : integer; stdcall;
  EPS_FiscalStatus    : function : integer; stdcall;
  EPS_PrinterStatus   : function : integer; stdcall;
  EPS_ReturnCode      : function : integer; stdcall;

  //Comandos da TM-T900FA
  EP9FA_EnviarComando : function (comando : String): Integer; StdCall;
  EP9FA_ObtenerRespuestaExtendida : function (numero_campo : Integer; var buffer_salida : Byte; largo_buffer_salida : Integer ; var largo_final_buffer_salida : Integer): Integer; StdCall;
  EP9FA_Cancelar : function (): Integer; StdCall;
  EP9FA_ConsultarVersionDll : function (descripcion : String ; descripcion_largo_maximo , mayor , menor : Integer): Integer; StdCall;
  EP9FA_ConsultarVersionEquipo : function (descripcion : String; descripcion_largo_maximo , mayor , menor : Integer): Integer; StdCall;
  EP9FA_ConsultarFechaHora : function ( var respuesta : Byte;  descripcion_largo_maximo : Integer): Integer; StdCall;
  EP9FA_ConsultarDescripcionDeError : function (numero_de_errr: Integer; respuesta_descripcion : String; respuesta_descripcion_largo_maximo : Integer): Integer; StdCall;
  EP9FA_ConsultarEstado : function (id_consulta: Integer; var respuesta : Integer): Integer; StdCall;
  EP9FA_ConsultarNumeroPuntoDeVenta : function (respuesta : String ; respuesta_largo_maximo : Integer): Integer; StdCall;
  EP9FA_ConsultarNumeroComprobanteUltimo : function (tipo_de_comprobante , respuesta : String; respuesta_largo_maximo : Integer): Integer; StdCall;
  EP9FA_ConsultarNumeroComprobanteActual : function (respuesta : String; respuesta_largo_maximo :Integer): Integer; StdCall;
  EP9FA_ConsultarTipoComprobanteActual : function (respuesta : String; respuesta_largo_maximo : Integer): Integer; StdCall;
  EP9FA_CargarDatosCliente : function (nombre_o_razon_social1 , nombre_o_razon_social2 , domicilio1 , domicilio2 ,
                                        domicilio3 : String; id_tipo_documento : Integer ; numero_documento : String; id_responsabilidad_iva : Integer): Integer; StdCall;
  EP9FA_CargarComprobanteAsociado : function (descripcion : String): Integer; StdCall;
  EP9FA_AbrirComprobante : function (id_tipo_documento: Integer): Integer; StdCall;
  EP9FA_CargarTextoExtra : function ( descripcion : String): Integer; StdCall;
  EP9FA_ImprimirItem : function (id_modificador : Integer; descripcion , cantidad , precio : String; id_tasa_iva , ii_id : Integer; ii_valor : String;
                                id_codigo : Integer; codigo , codigo_unidad_matrix : String; codigo_unidad_medida : Integer): Integer; StdCall;
  EP9FA_ImprimirTextoLibre : function (descripcion : String): Integer; StdCall;
  EP9FA_ImprimirSubtotal : function () : Integer; StdCall;
  EP9FA_CargarAjuste : function (id_modificador : Integer; descripcion , monto : String; id_tasa_iva : Integer;
                                codigo_interno : String): Integer; StdCall;
  EP9FA_CargarOtrosTributos : function (codigo_otros_tributos : Integer; descripcion , monto : String; id_tasa_iva : Integer): Integer; StdCall;
  EP9FA_CargarPago : function ( id_modificador , codigo_forma_pago , cantidad_cuotas : Integer; monto , descripcion_cupones , descripcion ,
                                descripcion_extra1 , descripcion_extra2 : String): Integer; StdCall;
  EP9FA_CerrarComprobante : function (): Integer; StdCall;
  EP9FA_CargarLogo : function ( nombre_de_archivo : String): Integer; StdCall;
  EP9FA_EliminarLogo : function (): Integer; StdCall;
  EP9FA_ConfigurarVelocidad : function (velocidad : Integer): Integer; StdCall;
  EP9FA_ConfigurarPuerto : function (puerto : String): Integer; StdCall;
  EP9FA_Conectar : function (): Integer; StdCall;
  EP9FA_ImprimirCierreX : function (): Integer; StdCall;
  EP9FA_ImprimirCierreZ : function (): Integer; StdCall;
  EP9FA_Desconectar : function (): Integer; StdCall;
  EP9FA_Descargar : function (desde , hasta , path : String): Integer; StdCall;
  EP9FA_DescargarPeriodoPendiente : function (path : String): Integer; StdCall;
  EP9FA_ConfimarDescarga : function (hasta : String): Integer; StdCall;
  EP9FA_ConsultarFechaPrimerJornadaPendiente : function (respuesta_pendiente : String; respuesta_pendiente_largo_maximo : Integer): Integer; StdCall;
  EP9FA_EstablecerFechaHora : function ( fecha_hora : String ): Integer; StdCall;
  EP9FA_ImprimirAuditoria : function ( id_modificador : Integer; desde, hasta: String): Integer; StdCall;
  EP9FA_ConsultarSubTotalNetoComprobanteActual : function ( var respuesta: Byte; respuesta_largo_maximo : Integer): Integer; StdCall;
  EP9FA_ConsultarSubTotalBrutoComprobanteActual : function ( var respuesta: Byte; respuesta_largo_maximo : Integer): Integer; StdCall;
  EP9FA_ConsultarUltimoError : function () : Integer; StdCall;
  EP9FA_ObtenerEstadoFiscal : function () : Integer; StdCall;
  EP9FA_ObtenerEstadoImpresora : function () : Integer; StdCall;

  EP9FA_MakeSureDirectoryPathExists : function (lpPath : String): Integer; StdCall; // DLL "imagehlp.dll"

Const
  EP9FA_TagSucesso : Integer = 0;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Imprimir( sTexto:String ):Boolean;
var
  sComando : string;
  fArqLog  : TextFile;
begin
   bRet := false;

   sComando := chr(27)+Chr(51)+Chr(15);    //define o tamanho do avanço de linha
   Comm1.Write(sComando[1], Length(sComando));

   Comm1.Write(sTexto[1], Length(sTexto));

   sComando := chr(10);                      // Estarta conteúdo do Buffer e avança bobina
   Comm1.Write(sComando[1], Length(sComando));

  // Grava o arquivo de Log
  AssignFile(fArqLog, cArqLog);
  Append(fArqLog);
  WriteLn(fArqLog, sTexto);
  CloseFile(fArqLog);

  Result := True;

end;

//------------------------------------------------------------------------------
function CortarPapel:Boolean;
var
  sComando : string;
  sMens     : String;
begin
  sRetorno:='';
  sMens   :='';
  bRet := false;

   sComando := chr(27)+Chr(51)+Chr(130);    //define o tamanho do avanço de linha
   Comm1.Write(sComando[1], Length(sComando));

   sComando := chr(10);                      // Estarta conteúdo do Buffer e avança bobina
   Comm1.Write(sComando[1], Length(sComando));

   sComando := chr(27)+chr(105);            // Corta o Papel
   Comm1.Write(sComando[1], Length(sComando));

  Result := False;
end;


//------------------------------------------------------------------------------
function EnviaComando( sComando:String ):Boolean;
var
  iRet: integer;
begin
   iRet:= Comm1.Write(sComando[1], Length(sComando));
   If iret > -1 then
      Result := True
   else
      Result := False;
end;

//------------------------------------------------------------------------------
procedure TEpson.Comm1Error(Sender: TObject; Errors: Integer);
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

//------------------------------------------------------------------------------
constructor TEpson.Create(AOwner: TComponent);
begin
  inherited;
end;

//------------------------------------------------------------------------------
destructor TEpson.Destroy;
begin
  inherited;
end;


//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.AbreCupom(Cliente:String; MensagemRodape:String) : String;
var
  sTexto    : String;
  sTexto1   : String;
  sHeader   : String;
  sPath     : String;
  fArquivo  : TIniFile;
  i         : Integer;
  fArqLog   : TextFile;
begin
  // Zera os valores das properties ValorPago e ValorVenda
  ValorPago  := 0;
  Itens      := 0;
  ItemNumero := 0;

  // Verifica o path de onde esta o arquivo EPSON6000.INI
  sPath := ExtractFilePath(Application.ExeName);

  // Inicializa o arquivo de Log
  AssignFile(fArqLog, cArqLog);
  ReWrite(fArqLog);
  CloseFile(fArqLog);

  Try
    fArquivo := TIniFile.Create(sPath+'EPSON6000.INI');

    //Imprime um Texto no cabecalho do cupom
    sTexto := '.';
    sHeader := '';
    i := 1;
    While Trim(sTexto) <> '' do
    begin
      sTexto := fArquivo.ReadString('Header', IntToStr(i), '');
      If Trim(sTexto) <> '' then
        sHeader := sHeader + sTexto + #10;
      Inc(i);
    end;
    DateTimeToString(sTexto,'mm/dd/yyyy',Date);
    DateTimeToString(sTexto1,'hh:nn:ss AM/PM',Time);
    sHeader := sHeader + Copy(sTexto + ' ' + sTexto1 + ' - ' + NomeCaixa,1,40) + #10 ;
    If Imprimir( sHeader ) then
    begin
      // Se conseguiu abrir o cupom grava no EPSON6000.INI que existe um cupom aberto. 1=Aberto 0=Fechado
      fArquivo.WriteString('Messages', 'Cupom', '1');
      fArquivo.WriteString('Messages', 'Itens', '0' );
      EnviaComando(Chr(27)+Chr(33)+Chr(128));
      sHeader := 'Prod.       Qty.       $Un.      $Tot.    ';
      Imprimir(sHeader);
      EnviaComando(Chr(27)+Chr(33)+Chr(0));
      Result := '0';
    end
    Else
      Result := '1';
    fArquivo.Free;
  Except
    Result := '1';
  end;

end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,
                aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
var
  sTexto : String;
  sPath  : String;
  sDesconto : String;
  sValorTotal : String;
  fArquivo : TIniFile;
  iQtde : Integer;
  iItemArq : Integer;
begin
  If Pos('.',qtde) > 0
  then iqtde := StrToInt(Trim(Copy(qtde,1,Pos('.',qtde)-1)))
  else
    if Pos(',',qtde) > 0
    then iqtde := StrToInt(Trim(Copy(qtde,1,Pos(',',qtde)-1)))
    else iqtde := StrToInt(Trim(qtde));

  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'Epson6000.INI');
  iItemArq := StrToInt( fArquivo.ReadString('Messages', 'Itens', '00' ) );

  If Itens = 0 Then
  Begin
    If Itens <> iItemArq
    Then Itens := iItemArq;
  end;

  //Incrementa o Numero de itens vendidos.
  Itens := Itens + iqtde;
  //Incrementa o Numero do item.
  ItemNumero := ItemNumero + 1;

  fArquivo.WriteString('Messages', 'Itens', IntToStr( Itens ) );

  // Pega a configuracao do arquivo ini para ver qual eh a descricao do desconto
  // e prepara a linha para impressao do desconto se houver.
  sDesconto := '';
  If StrToFloat(vlrdesconto) > 0 then
  begin
    Try
      sDesconto := fArquivo.ReadString('Messages', 'Desconto', '');
      If Trim(sDesconto) <> '' then
        sDesconto := copy(sDesconto+space(27),1,27) + ' ' + Right(Space(10)+vlrdesconto,10)+#10;
      fArquivo.Free;
    except
    end;
  end;

  // Prepara a linha para impressao do item
  sValorTotal := FormataTexto(vlTotIt,10,2,3) ;

  while length(codigo)<15 do
    codigo:= codigo + ' ';
  sTexto := codigo + ' ' + copy(descricao + space(24),1,24) + #10;
  sTexto := sTexto + Space(10) + FormataTexto(qtde,6,0,4) + ' ';
  sTexto := sTexto + FormataTexto(FloatToStr(StrToFloat(vlTotIt)/StrToFloat(qtde)),10,2,3) + ' ';
  sTexto := sTexto + sValorTotal;

  // Faz a impressao do item
  If Imprimir( sTexto ) then
  begin
    Result := '0';
    // Imprime desconto se houver
    If Trim(sDesconto) <> '' then  Imprimir( sDesconto );
  end
  Else
  begin
    Result := '1';
    ItemNumero := ItemNumero - 1;
  end;
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;
var
  aAuxiliar : TaString;
  i         : Integer;
  sTexto    : String;
  sValor    : String;
  fValorPago: Real;
  sTotalVenda: String;
begin
  // imprime o Total da Venda

  EnviaComando(Chr(27)+Chr(33)+Chr(16));
  sTotalVenda := copy('TOTAL'+Space(27),1,27) + ' ' + Right(Space(10)+FloatToStrf(ValorVenda,ffFixed,18,2),10)+#10;
  Imprimir( sTotalVenda );
  EnviaComando(Chr(27)+Chr(33)+Chr(0));

  // Monta um array auxiliar com os pagamentos solicitados
  Pagamento := StrTran(Pagamento,',','.');
  MontaArray( Pagamento,aAuxiliar );
  fValorPago := 0;

  i := 0;
  While i < Length(aAuxiliar) do
  begin
    sValor := Space(10) + aAuxiliar[i+1];
    sTexto := sTexto + copy(aAuxiliar[i]+Space(27),1,27) + ' ' + Right(sValor,10) + #10;
    fValorPago := fValorPago + StrToFloat(aAuxiliar[i+1]);
    Inc(i,2);
  end;

  sTexto:=Copy(sTexto,1,Length(sTexto)-1);

  If Imprimir( sTexto ) then
  begin
    ValorPago := ValorPago + fValorPago;
    Result := '0';
  end
  Else
    Result := '1';

end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.FechaCupom( Mensagem:String ):String;
var
  sTexto , sMsg   : String;
  sFooter   : String;
  sPath     : String;
  sValor    : String;
  fArquivo  : TIniFile;
  i         : Integer;
begin
  // Verifica o path de onde esta o arquivo EPSON6000.INI para imprimir as msgs
  sPath := ExtractFilePath(Application.ExeName);

  // Abre o arquivo de configuracao.
  fArquivo := TIniFile.Create(sPath+'EPSON6000.INI');

// Imprime o troco
    sTexto := fArquivo.ReadString('Messages', 'Troco', Space(21));
    If Trim(sTexto) <> '' then
    begin
      sValor := Space(10) + FloatToStrf(ValorPago-ValorVenda,ffFixed,18,2);
      sTexto := copy(sTexto+Space(27),1,27) + ' ' + Right(sValor,10) + #10;
      Imprimir( sTexto );
    end;

  sTexto := #10+'Item Count: '+IntToStr(Itens)+#10+'Trans: '+NumCupom+' Terminal: '+Pdv+#10;
  Imprimir(sTexto);

  Try
    sTexto := '.';
    sFooter := '';
    sMsg := TrataTags( Mensagem );
    If Trim(sMsg) <> '' then
      sFooter := sFooter + sMsg + #10;
    i := 1;
    While sTexto <> '' do
    begin
      sTexto := fArquivo.ReadString('Footer', IntToStr(i), '');
      If sTexto <> '' then
        sFooter := sFooter + sTexto + #10;
      Inc(i);
    end;
    If Imprimir( sFooter ) then
    begin
      // Se conseguiu fechar o cupom acerta o EPSON6000.INI para informar que nao existe cupom aberto
      fArquivo.WriteString('Messages','Cupom','0');
      fArquivo.WriteString('Messages', 'Itens', '0' );
      Result := '0';
    end
    Else
      Result := '1';
  Except
    Result := '1';
  end;
  fArquivo.Free;

  sFooter := '';
  For i:=1 to 6 do
    sFooter := sFooter + #10;
  Imprimir( sFooter ); // pula linha no final do cupom

  CortarPapel;

  // Retorna o cupom em uma String para gerar o Journal
  Result := Result + '|' + sJournal;
  sJournal := '';

end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var
  fValorTotal : Real;
  sValorTotal : String;
  iqtde : Integer;
begin
  fValorTotal := -1*StrToFloat(qtde)*StrToFloat(vlrUnit);
  sValorTotal := FormataTexto(FloatToStr(fValorTotal),10,2,3) ;

  numitem := FormataTexto(numitem,3,0,2);
  If Imprimir( 'Item '+numitem+' anulado.           '+sValorTotal+#10 ) then
    begin
      If Pos('.',qtde) > 0 then
        iqtde := StrToInt(Trim(Copy(qtde,1,Pos('.',qtde)-1)))
      else
        if Pos(',',qtde) > 0 then
          iqtde := StrToInt(Trim(Copy(qtde,1,Pos(',',qtde)-1)))
        else
          iqtde := StrToInt(Trim(qtde));
      Itens := Itens - iqtde;
      ValorVenda := ValorVenda - StrToFloat(qtde)*StrToFloat(vlrUnit);
      Result := '0';
    end
  Else
     Result := '1';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.CancelaCupom(Supervisor:String):String;
var
  sPath : String;
  fArquivo : TIniFile;
  sTexto : String;
  sFooter : String;
  sNumCupCanc : String;
  i : Integer;
begin
  Try
    // Verifica o path de onde esta o arquivo EPSON6000.INI para imprimir as msgs
    sPath := ExtractFilePath(Application.ExeName);
    // Abre o arquivo de configuracao.
    fArquivo := TIniFile.Create(sPath+'EPSON6000.INI');

    sTexto := '.';
    sFooter := '';
    i := 1;
    While sTexto <> '' do
    begin
      sTexto := fArquivo.ReadString('Footer', IntToStr(i), '');
      If sTexto <> '' then
        sFooter := sFooter + sTexto + #10;
      Inc(i);
    end;

    //Em alguns países o Cancelamento do Cupom não está amarrado ao ÚLTIMO cupom
    // nesse caso será passado o número do cupom a ser cancelado nessa função.
    If Pos('|',Supervisor)>0 then
    Begin
        sNumCupCanc := Copy(Supervisor,Pos('|',Supervisor)+1,Length(Supervisor));
        Supervisor  := Copy(Supervisor,1,Pos('|',Supervisor)-1);
    End
    Else
        sNumCupCanc := NumCupom;

    sTexto := #10 +    '        C O M P R O B A N T E ' + #10;
    sTexto := sTexto + '             F I S C A L      ' + #10;
    sTexto := sTexto + '            A N U L A D O     ' + #10;
    sTexto := sTexto + #10 + 'Trans: ' + sNumCupCanc + ' Terminal: ' + Pdv + #10;
    sTexto := sTexto + 'Supervisor: ' + Supervisor + #10;
    sTexto := sTexto + sFooter;
    sTexto := sTexto + #10 + #10 + #10 + #10 + #10 + #10 + #10;

    If Imprimir( sTexto ) then
      Result := '0'
    Else
      Result := '1';

    fArquivo.Free;
  Except
    Result := '1';
  end;

  CortarPapel;

end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String;
var
  sTexto : String;
  sDesconto : String;
  fArquivo : TIniFile;
  sPath : String;
begin
  If StrToFloat(vlrDesconto) <> 0 then
  Begin
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'EPSON6000.INI');
  sDesconto := fArquivo.ReadString('Messages', 'Desconto', '');
  fArquivo.Free;
  sTexto := copy(sDesconto+Space(20), 1, 20);
  sTexto := sTexto + '        ' + FormataTexto(FloatToStr(-1*StrToFloat(vlrDesconto)),10,2,3);
  If Imprimir( sTexto ) then
  begin
    ValorVenda := ValorVenda - StrToFloat(vlrDesconto);
    Result := '0';
  end
  Else
    Result := '1';
  end
  Else
    Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.AcrescimoTotal( vlrAcrescimo:String ): String;
var
  sTexto : String;
begin
  sTexto := Space(20) + '+ ' + vlrAcrescimo;
  sTexto := copy(sTexto, Length(sTexto)-20, 20);
  If Imprimir( sTexto ) then
  begin
    ValorVenda := ValorVenda + StrToFloat(vlrAcrescimo);
    Result := '0';
  end
  Else
    Result := '1';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.RelatorioGerencial( Texto:String;Vias:Integer; ImgQrCode: String):String;
var
  fArqLog : TextFile;
  fArquivo : TIniFile;
  cArquivo : String;
  cLinha : String;
  sPath : String;
  bRet : Boolean;
begin
  If (copy(Texto,1,1) = '[') And (Right(Texto,1) = ']') then
  begin
    // Verifica o path de onde estão os arquivos
    sPath := ExtractFilePath(Application.ExeName);

    fArquivo := TIniFile.Create(sPath+'EPSON6000.INI');

    //Checa o arquivo de log.
    cArquivo := copy(Texto,2,Length(Texto)-2);
    If not FileExists(cArquivo) then
      cArquivo := sPath+cArquivo;

    If FileExists(cArquivo) then
    begin
      AssignFile(fArqLog, cArquivo);
      Reset(fArqLog);
      While not Eof(fArqLog) do
      begin
        ReadLn(fArqLog, cLinha);
        Comm1.Write(cLinha[1], Length(cLinha));
      end;
      CloseFile(fArqLog);
      Result := '0';
    end
    Else
      Result := '1';

    fArquivo.Free;
  end
  Else
  begin
    bRet := Imprimir(Texto);
    If bRet = True
    Then Result := '0'
    Else Result := '1';
  end;

  EnviaComando(Chr(10));
  CortarPapel;
end;

//----------------------------------------------------------------------------
function ImpEpsonTMH6000II.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;

begin
 GravaLog('ImprimeCodBarrasITF- Comando não suportado para este modelo!');
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.AlimentaPropEmulECF( sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:String ):String;
begin
  Pdv       := sNumPdv;
  NumCaixa  := sNumCaixa;
  NomeCaixa := sNomeCaixa;
  NumCupom  := sNumCupom;
  Result:= '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.LeAliquotas:String;
begin
  // esse retorno foi colocado dessa forma pq. o sistema exige aliquotas para fazer a venda.
  Result := '0|0.00|18.00|7.00|12.00|5.00';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.LeAliquotasISS:String;
begin
  // esse retorno foi colocado dessa forma pq. o sistema exige aliquotas para fazer a venda.
  Result := '0|0.00|5.00';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.PegaCupom(Cancelamento:String): String;
begin
  Result := '0|'+NumCupom;
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.PegaPDV : String;
begin
  Result := '0|'+Pdv;
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.ImpostosCupom(Texto: String): String;
var sTaxa: string;
    indice: integer;
    sValor: string;
    sVlrMerc : string;
begin
//  Texto tem o seguinte formato:
//  <VlrMerc>|<Valor da Venda >|<Tipo do Imposto><Descricao do Imposto><Alíquota><Valor do Imposto>|
//  Formato dos parâmetros:
//  VlrMerc - Valor da Mercadoria sem os impostos, da forma como deve ser impresso,
//             já com a formatação necessária (Ex: 100.00) e sem espaços.
//  Valor da Venda - Valor TOTAL da venda já com os imposto, da forma que deve ser impresso,
//                  já com a formatação necessária (virgula - Ex: 100.00) e sem espaços
//  Tipo do imposto  - Uma posição (0=discriminado, 1=incluído)
//  Descricao do imposto - Descricao com 10 posições, espaços a direita.
//  Alíquota - 4 dígitos, sem formatacao (Ex: 1800)
//  valor do Imposto - O resto da string, da forma como deve ser impresso,
//             já com a formatação necessária (Ex: 100.00) e sem espaços.

      indice := Pos('|', Texto);
      sVlrMerc := Copy (texto,1,indice-1);
      Texto := Copy (Texto,indice+1,length(Texto));
      indice := Pos('|', Texto);
      ValorVenda := StrToFloat(Copy (texto,1,indice-1));
      Texto := Copy (Texto,indice+1,length(Texto));

      Imprimir('_________________________________________');
      Imprimir('SUBTOTAL' + Space(18)+FormataTexto(sVlrMerc,12,2,3));

    While Length(Texto)>0 do
    begin
        indice:= Pos('|',Texto);
        sTaxa:= Copy (Texto,2,10);
        sValor:= Copy(Texto,16,(indice-1)-15);
        If Trim(sValor) <> '' then
            Imprimir(sTaxa+Space(12)+FormataTexto(sValor,16,2,3));
        Texto:=Copy(Texto, indice+1,Length(Texto));
    end;

  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.LeCondPag:String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
begin
  Result := '0';
end;


//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
Var
sTexto, slinha : string;
i, fim, indice, j : integer;
bRet : boolean;
begin
    stexto:=texto;
    bRet:= False;

    For i:=1 to Vias do
    begin
       If Length(texto)>0 then
       begin
           Repeat
                fim:=Length(texto);
                If Pos(#10,Copy(Texto, 1, 42))>0 then
                begin
                    indice:=Pos(#10,Copy(Texto, 1, 42));
                    slinha:= Pchar(Copy(Texto, 1, indice-1));
                    Texto:= Copy(Texto,indice+1,fim);
                end
                else
                begin
                    sLinha:=Pchar(Copy(Texto,1,42));
                    Texto:=Copy(Texto,43,fim);
                end;
              j:=1;
              Repeat
                  bRet := Imprimir(sLinha);
                  j:=j+1;
              Until (bRet = true) or (j<4);
           until  Length(texto)< 2;
       end;
       if i<>Vias then
       begin
             j:=1;
             Repeat
                  bRet := Imprimir(sLinha);
                  j:=j+1;
             Until (bRet = True) or (j<4);
       end;
       texto:=stexto;
    end;
    Imprimir(#10#10);
    CortarPapel;
    if bRet=true then
      Result := '0'
    Else
      Result := '1'
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.FechaCupomNaoFiscal: String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.ReImpCupomNaoFiscal( Texto:String ):String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var i: integer;
begin
    For i:=1 to Vezes do
    Begin
        EnviaComando(Chr(27)+Chr(123)+Chr(1));          // Ativa impressão de cabeça para baixo
        EnviaComando(Chr(27)+Chr(99)+Chr(48)+Chr(4));   // Direciona a impressão para Folha Solta
        Showmessage ('Insira a '+IntToStr(i)+'ª via.');
        Imprimir( Valor + Space(5) + Texto);
        EnviaComando(Chr(27)+Chr(113));                 //libera Folha Solta
        EnviaComando(Chr(27)+Chr(123)+Chr(0));          // Desativa impressão de cabeça para baixo
    End;
    EnviaComando(Chr(27)+Chr(99)+Chr(48)+Chr(1));       //Direciona impressão para a bobina
    Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.Suprimento( Tipo:Integer;Valor:String;Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
begin
  Result := '0';
end;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.Abrir(sPorta : String; iHdlMain:Integer) : String;
var
  sPath : String;
begin
  If Comm1=NIL then
  begin
      Comm1 := TEpson.Create(Application);
      Comm1.BaudRate := br19200;
      Comm1.Databits := da8;
      Comm1.Parity   := paNone;
      Comm1.StopBits := sb10;
      Comm1.DeviceName := sPorta;
      sPath := ExtractFilePath(Application.ExeName);
      // Definição do nome do arquivo de Log.
      cArqLog := sPath+'CUPOM.LOG';
      try
        //Abre a porta serial
        Comm1.Open;
        Comm1.SetRTSState(True);
        Comm1.SetDTRState(True);
        Comm1.SetBREAKState(False);
        result := '0';
      except
        result := '1';
      end;
  end
  else
    Result:='0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.Fechar( sPorta:String ) : String;
begin
 //Fecha porta serial
  Comm1.Close;
  Comm1.Free;
  result := '0|';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.Gaveta:String;
var
bRet: boolean;
begin
  bRet:= EnviaComando(Chr(27)+Chr(112)+Chr(0)+Chr(100)+Chr(150));
  If bRet=True then
     Result := '0'
  Else
     Result := '1';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.Status( Tipo:Integer; Texto:String ):String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.StatusImp( Tipo:Integer ):String;
var
  sPath : String;
  fArquivo : TIniFile;
begin
  // Se o ECF esta em erro, abortar

  //Tipo - Indica qual o status quer se obter da impressora
  //  1 - Obtem a Hora da Impressora
  //  2 - Obtem a Data da Impressora
  //  3 - Verifica o Papel
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  //  5 - Cupom Fechado ?
  //  6 - Ret. suprimento da impressora
  //  7 - ECF permite desconto por item
  //  8 - Verifica se o dia anterior foi fechado
  //  9 - Verifica o Status do ECF
  // 10 - Verifica se todos os itens foram impressos.
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  // 16 - Verifica se exige o extenso do cheque

  // 20 - Retorna o CNPJ cadastrado na impressora
  // 21 - Retorna o IE cadastrado na impressora
  // 22 - Retorna o CRZ - Contador de Reduções Z
  // 23 - Retorna o CRO - Contador de Reinicio de Operações
  // 24 - Retorna a letra indicativa de MF adicional
  // 25 - Retorna o Tipo de ECF
  // 26 - Retorna a Marca do ECF
  // 27 - Retorna o Modelo do ECF
  // 28 - Retorna o Versão atual do Software Básico do ECF gravada na MF
  // 29 - Retorna a Data de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  // 30 - Retorna o Horário de instalação da versão atual do Software Básico gravada na Memória Fiscal do ECF
  // 31 - Retorna o Nº de ordem seqüencial do ECF no estabelecimento usuário
  // 32 - Retorna o Grande Total Inicial
  // 33 - Retorna o Grande Total Final
  // 34 - Retorna a Venda Bruta Diaria
  // 35 - Retorna o Contador de Cupom Fiscal CCF
  // 36 - Retorna o Contador Geral de Operação Não Fiscal
  // 37 - Retorna o Contador Geral de Relatório Gerencial
  // 38 - Retorna o Contador de Comprovante de Crédito ou Débito
  // 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
  // 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CÓDIGOS DE IDENTIFICAÇÃO DE ECF
  // 45  - Modelo Fiscal
  // 46 - Marca, Modelo e Firmware
  
  //  1 - Retorna a Data
  If Tipo = 1 then
    Result := '0|' + TimeToStr(Time)
  //  2 - Verifica a data da Impressora
  else if Tipo = 2 then
    Result := '0|' + DateToStr(Date)
  //  3 - Verifica o estado do papel
  else if Tipo = 3 then
    result := '0'
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  else if Tipo = 4 then
    result := '0|TODOS'
  //  5 - Cupom Fechado ?
  else if Tipo = 5 then
  begin
    // cria um arquivo INI
    sPath := ExtractFilePath(Application.ExeName);
    fArquivo := TIniFile.Create(sPath+'EPSON6000.INI');
    // lê o conteúdo da seção MESSAGES, identificador CUPOM
    // retorna 0 se essa funçào ou identificador não existir
    Result := fArquivo.ReadString('Messages', 'Cupom', '0');
    fArquivo.Free;

    If Result <> '0' then
      result := '7'
    else
      result := '0';
  end
  //  6 - Ret. suprimento da impressora
  else if Tipo = 6 then
    result := '0|0.00'
  //  7 - ECF permite desconto por item
  else if Tipo = 7 then
    result := '11'
  //  8 - Verica se o dia anterior foi fechado
  else if Tipo = 8 then
    result := '0'
  //  9 - Verifica o Status do ECF
  else if Tipo = 9 then
    result := '0'
  // 10 - Verifica se todos os itens foram impressos.
  else if Tipo = 10 then
    result := '0'
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  else if Tipo = 11 then
    result := '0'
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  else if Tipo = 12 then
    result := '1'
  // 13 - Verifica se o ECF Arredonda o Valor do Item (1=Trunca / 0= Arredonda)
  else if Tipo = 13 then
    result := '1'
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  else if Tipo = 14 then
    Result := '0'
  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  else if Tipo = 15 then
    Result := '1'
  // 16 - Verifica se exige o extenso do cheque
  else if Tipo = 16 then
    Result := '1'
  // 20 ao 40 - Retorno criado para o PAF-ECF
  else if (Tipo >= 20) AND (Tipo <= 40) then
    Result := '0'
  else If Tipo = 45 then
    Result := '0|'// 45 Codigo Modelo Fiscal
  else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
    Result := '0|'// 45 Codigo Modelo Fiscal
  else
    Result := '1';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.LeituraX:String;
begin
    Result:= '0|';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.ReducaoZ( MapaRes:String ) : String;
begin
  Result := '0'
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.FechaECF : String;
begin
  Result := '0';
end;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.AbreECF:String;
begin
  EnviaComando(#27#64);
  Result := '0';
end;

//----------------------------------------------------------------------------
function ImpEpsonTMH6000II.PegaSerie : String;
begin
    result := '1|Funcao nao disponivel';
end;

//---------------------------------------------------------------------------
function ImpEpsonTMH6000II.HorarioVerao( Tipo:String ):String;
begin
  Result := '0';
end;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:String ): String;
var
  nRetorno : Integer;
  sTexto : String;
begin
    sTexto:=Trim(Banco)+Trim(Valor)+Trim(Favorec)+Trim(Cidade)+Trim(Data);
    EnviaComando(Chr(27)+Chr(99)+Chr(48)+Chr(4));      // Direciona a impressão para Folha Solta

    If sTexto = '' then
    begin
      sTexto := Verso+#10;
      nRetorno := Comm1.Write(sTexto[1], Length(sTexto));
      If nRetorno > -1 Then
        Result := '0'
      Else
        Result := '1';
    end
    Else
    begin
      sTexto := #10+#10+#10+Space(50)+Data+#10+#10+Space(5)+
                Copy(Favorec+Space(40),1,40)+Valor+#10+#10+#10+
                Space(5)+Extenso+#10+#10+#10+Mensagem+#10;
      nRetorno := Comm1.Write( sTexto[1], Length(sTexto));
      If nRetorno > -1  then
      Begin
        If Trim(Verso) <> '' Then
        Begin
          ShowMessage('Vire o cheque');
          sTexto := Verso+#10;
          nRetorno := Comm1.Write(sTexto[1],Length(sTexto));
          If nRetorno > -1 Then
            Result := '0'
          Else
            Result := '1';
        End
        Else
          Result := '0';
      End
      Else
        Result := '1';
    end;

  EnviaComando(Chr(27)+Chr(113));                  //libera Folha Solta
  EnviaComando(Chr(27)+Chr(99)+Chr(48)+Chr(1));    // Ativa bobina de Papel

end;

//------------------------------------------------------------------------------
function ChqEpsonTMH6000II.Abrir( aPorta:String ): Boolean;
var
  sPath : String;
begin
  If Comm1=NIL then
  begin
      Comm1 := TEpson.Create(Application);
      Comm1.BaudRate := br19200;
      Comm1.Databits := da8;
      Comm1.Parity   := paNone;
      Comm1.StopBits := sb10;
      Comm1.DeviceName := aPorta;
      sPath := ExtractFilePath(Application.ExeName);
      // Definição do nome do arquivo de Log.
      cArqLog := sPath+'CUPOM.LOG';
      try
        //Abre a porta serial
        Comm1.Open;
        Comm1.SetRTSState(True);
        Comm1.SetDTRState(True);
        Comm1.SetBREAKState(False);
        result := True;
      except
        result := False;
      end;
  end
  else
    Result:=True;
end;

//---------------------------------------------------------------------------
function ChqEpsonTMH6000II.Fechar( aPorta:String ) : Boolean;
begin
 //Fecha porta serial
  Comm1.Close;
  Comm1.Free;
  result := True;
end;

//------------------------------------------------------------------------------
function ChqEpsonTMH6000II.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  nLin, nlinha, ncol, nColuna, nLargura :Integer;
  sTexto, sPath, sData,sContExt : String;
  fArquivo  : TIniFile;
  procedure AvaliaCol(coluna: Integer);
  begin
    if ((Coluna / 256)>0) then
    begin
        nCol    := coluna div 256;
        nColuna := Coluna mod 256;
    end
    else
        nCol:=0;
  end;

  procedure AvaliaLin(Linha: Integer);
  begin
    if ((Linha / 256)>0) then
    begin
        nLin    := Linha div 256;
        nLinha := Linha mod 256;
    end
    else
        nLin:=0;
  end;

  function TrataMes(Mes: Integer):String;
  begin
        sPath := ExtractFilePath(Application.ExeName);
        fArquivo := TIniFile.Create(sPath+'EPSON6000.INI');
        Result := fArquivo.ReadString('Months', FormataTexto(IntToStr(Mes),2,0,2), ' ');
  end;

begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

    sTexto:=Trim(StrPas(Banco))+Trim(StrPas(Valor))+Trim(StrPas(Favorec))+Trim(StrPas(Cidade))+Trim(StrPas(Data));
    sContExt:='';

    If sTexto <> '' then
    begin

        EnviaComando(Chr(27)+'@');                    // ESC @ - inicializa impressora
        EnviaComando(Chr(27)+'c0'+Chr(4));      // ESC c 0 - Direciona a impressão para Folha Solta
        EnviaComando(Chr(27)+'c1'+Chr(4));      // ESC c 1 - Direciona a configuracao para Folha Solta
        EnviaComando(Chr(27)+'c3'+Chr(16));     // ESC c 3 - Seleciona Sensor de Saída de Papel(cheque)
        EnviaComando(Chr(27)+'c4'+Chr(32));     // ESC c 4 - Seleciona sensor de Fim de Papel para parar de imprimir
        EnviaComando(Chr(27)+'U'+Chr(1));       // ESC U - '1'-PAGE MODE  '2'-STANDARD MODE
        EnviaComando(Chr(27)+'L');              // ESC L - Seleciona PAGE MODE
        EnviaComando(Chr(27)+'T'+Chr(1));       // ESC T - Seleciona Direcao
        EnviaComando(Chr(27)+'3'+Chr(0));       // ESC 3 - seleciona espaçamento de linha
        EnviaComando(Chr(27)+'V'+Chr(1));             // ESC V - seleciona direcao

        // ESC W - Parâmetros:
        //          1º - Altura a partir do inicio  - Origem HORIZONTAL - coluna
        //          2º - Altura a partir do inicio  - Origem HORIZONTAL
        //                multiplica o 2º por 256 e soma ao 1º
        //          3º - Origem VERTICAL
        //          4º - Origem VERTICAL
        //          5º - Largura
        //          6º - Largura
        //          7º - Altura
        //          8º - Altura

        // Verifica o path de onde esta o arquivo EPSON6000.INI
        sPath := ExtractFilePath(Application.ExeName);
        fArquivo := TIniFile.Create(sPath+'EPSON6000.INI');

        nLargura := StrToInt(fArquivo.ReadString('CHECK', 'Width', '30'));
        if Length(extenso)>nLargura then
        begin
            sContExt := Copy(Extenso,nLargura,length(Extenso));
            Extenso  := PChar(Copy(Extenso,1,nLargura));
            While Length(sContExt)<nLargura do sContExt:=sContExt+'*';
        end
        Else
        begin
            While Length(sContExt)<nLargura do sContExt:=sContExt+'*';
            While Length(Extenso)<nLargura do Extenso:=Pchar(Extenso+'*');
        end;

        nLinha  := StrToInt(fArquivo.ReadString('Check', 'ValueLine', '199'));
        nColuna := StrToInt(fArquivo.ReadString('Check', 'ValueCol', '249'));
        AvaliaCol(nColuna);
        AvaliaLin(nLinha);
        EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
        sTexto :=FormataTexto(Valor,12,2,3);
        Comm1.Write(sTexto[1],Length(sTexto));

        nLinha  := StrToInt(fArquivo.ReadString('Check', 'InFull1Line', '249'));
        nColuna := StrToInt(fArquivo.ReadString('Check', 'InFull1Col', '599'));
        AvaliaCol(nColuna);
        AvaliaLin(nLinha);
        EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
        sTexto := Extenso+#10;
        Comm1.Write(sTexto[1],Length(sTexto));

        nLinha  := StrToInt(fArquivo.ReadString('Check', 'InFull2Line', '299'));
        nColuna := StrToInt(fArquivo.ReadString('Check', 'InFull2Col', '649'));
        AvaliaCol(nColuna);
        AvaliaLin(nLinha);
        EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
        sTexto := sContExt;
        Comm1.Write(sTexto[1],Length(sTexto));

        nLinha  := StrToInt(fArquivo.ReadString('Check', 'FavouredLine', '359'));
        nColuna := StrToInt(fArquivo.ReadString('Check', 'FavouredCol', '599'));
        AvaliaCol(nColuna);
        AvaliaLin(nLinha);
        EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
        sTexto := Favorec;
        Comm1.Write(sTexto[1],Length(sTexto));

        nLinha  := StrToInt(fArquivo.ReadString('Check', 'DateLine', '389'));
        AvaliaLin(nLinha);

        nColuna := StrToInt(fArquivo.ReadString('Check', 'DayCol', '349'));
        AvaliaCol(nColuna);
        EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
        sTexto := Copy(Data,7,2);
        Comm1.Write(sTexto[1],Length(sTexto));

        nColuna := StrToInt(fArquivo.ReadString('Check', 'MonthCol', '249'));
        AvaliaCol(nColuna);
        EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
        sTexto := TrataMes(StrToInt(Copy(Data,5,2)));
        Comm1.Write(sTexto[1],Length(sTexto));

        nColuna := StrToInt(fArquivo.ReadString('Check', 'YearCol', '99'));
        AvaliaCol(nColuna);
        EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
        sTexto := Copy(Data,1,4);
        Comm1.Write(sTexto[1],Length(sTexto));

        nLinha  := StrToInt(fArquivo.ReadString('Check', 'MsgLine', '489'));
        nColuna := StrToInt(fArquivo.ReadString('Check', 'MsgCol', '349'));
        AvaliaCol(nColuna);
        AvaliaLin(nLinha);
        EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
        sTexto := Trim(Mensagem);
        if sTexto<>'' then
            Comm1.Write(sTexto[1],Length(sTexto));

        EnviaComando(Chr(27)+Chr(12));           // ESC FF
        EnviaComando(Chr(27)+'@');               // ESC @

        if Trim(Verso)<>''then
        Begin
            ShowMessage('    Insira o Verso     ');

            EnviaComando(Chr(27)+'c0'+Chr(4));      // ESC c 0 - Direciona a impressão para Folha Solta
            EnviaComando(Chr(27)+'U'+Chr(1));       // ESC U - '1'-PAGE MODE  '2'-STANDARD MODE
            EnviaComando(Chr(27)+'L');              // ESC L - Seleciona PAGE MODE
            EnviaComando(Chr(27)+'T'+Chr(1));       // ESC T - Seleciona Direcao
            EnviaComando(Chr(27)+'3'+Chr(0));       // ESC 3 - seleciona espaçamento de linha
            EnviaComando(Chr(27)+'V'+Chr(1));             // ESC V - seleciona direcao


            nLinha  := StrToInt(fArquivo.ReadString('Check', 'VerseLine', '359'));
            nColuna := StrToInt(fArquivo.ReadString('Check', 'VerseCol', '0'));
            AvaliaCol(nColuna);
            AvaliaLin(nLinha);
            EnviaComando(Chr(27)+'W'+Chr(nLinha)+Chr(nLin)+Chr(0)+Chr(0)+Chr(51)+Chr(0)+Chr(nColuna)+Chr(nCol));  // ESC W
            sTexto := Verso;
            Comm1.Write(sTexto[1],Length(sTexto));

            EnviaComando(Chr(27)+Chr(12));           // ESC FF
            EnviaComando(Chr(27)+'@');               // ESC @
        end;
    end;

  EnviaComando(Chr(27)+Chr(99)+Chr(48)+Chr(1));    // ESC c 0 1 - Ativa bobina de Papel
  EnviaComando(Chr(27)+#86+Chr(0));              //ESC V - desabilita rotacao
  fArquivo.Free;
  Result:=True;
end;

//----------------------------------------------------------------------------
function ChqEpsonTMH6000II.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function ChqEpsonTMH6000II.StatusCh( Tipo:Integer ):String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
  
end;

//-----------------------------------------------------------
function ImpEpsonTMH6000II.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
begin
  Result:='0';
end;

//----------------------------------------------------------------------------
function ImpEpsonTMH6000II.RecebNFis( Totalizador, Valor, Forma:String ): String;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.LeTotNFisc:String;
begin
  Result := '0|-99';
end;


//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.DownMF(sTipo, sInicio, sFinal : String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.RedZDado( MapaRes : String ):String;
Begin
  Result := '0';
End;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
 GravaLog(' - IdCliente : Comando Não Implementado para este modelo');
 Result := '0';
end;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
begin
 GravaLog(' - EstornNFiscVinc : Comando Não Implementado para este modelo');
 Result := '0';
end;

//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.ImpTxtFis(Texto : String) : String;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
end;

//------------------------------------------------------------------------------
// EPSON TM-U220AF (ARGENTINA)
//------------------------------------------------------------------------------
Function ImpEpsonTMU220AF.Abrir( sPorta:String; iHdlMain:Integer ):String;
  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
       LjMsgDlg('La Funcion "'+sMsg+'" no existe en la Dll: EpsonInterface.dll');
       Result := False
    end
    else
       Result := True;
  end;

var fHandle : THandle;
    aFunc   : Pointer;
    bRet    : Boolean;
    IniFile : TIniFile;
    iBoundRate : Integer;
begin
  GravaLog(' Inicio da função Abrir - ImpEpsonTMU220AF ');

  fHandle := LoadLibrary( 'EpsonInterface.dll' );
  if (fHandle <> 0) Then
  begin
    GravaLog(' ImpEpsonTMU220AF - DLL EpsonInterface.dll encontrada');

    bRet := True;

    aFunc := GetProcAddress(fHandle,'GetState');
    if ValidPointer( aFunc, 'GetState')
    then EPS_GetState := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando GetState ');

    aFunc := GetProcAddress(fHandle,'SetCommPort');
    if ValidPointer( aFunc, 'SetCommPort')
    then EPS_SetCommPort := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando SetCommPort ');

    aFunc := GetProcAddress(fHandle,'GetCommPort');
    if ValidPointer( aFunc, 'GetCommPort')
    then EPS_GetCommPort := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando GetCommPort ');

    aFunc := GetProcAddress(fHandle,'OpenPort');
    if ValidPointer( aFunc, 'OpenPort')
    then EPS_OpenPort := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando OpenPort ');

    aFunc := GetProcAddress(fHandle,'ClosePort');
    if ValidPointer( aFunc, 'ClosePort')
    then EPS_ClosePort := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando ClosePort ');

    aFunc := GetProcAddress(fHandle,'Purge');
    if ValidPointer( aFunc, 'Purge')
    then EPS_Purge := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando Purge ');

    aFunc := GetProcAddress(fHandle,'AddDataField');
    if ValidPointer( aFunc, 'AddDataField')
    then EPS_AddDataField := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando AddDataField ');

    aFunc := GetProcAddress(fHandle,'SendCommand');
    if ValidPointer( aFunc, 'SendCommand')
    then EPS_SendCommand := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando SendCommand ');

    aFunc := GetProcAddress(fHandle,'GetExtraField');
    if ValidPointer( aFunc, 'GetExtraField')
    then EPS_GetExtraField := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando GetExtraField ');

    aFunc := GetProcAddress(fHandle,'GetBoundRate');
    if ValidPointer( aFunc, 'GetBoundRate')
    then EPS_GetBoundRate := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando GetBoundRate ');

    aFunc := GetProcAddress(fHandle,'SetBoundRate');
    if ValidPointer( aFunc, 'SetBoundRate')
    then EPS_SetBoundRate := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando SetBoundRate ');

    aFunc := GetProcAddress(fHandle,'LastError');
    if ValidPointer( aFunc, 'LastError')
    then EPS_LastError := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando LastError ');

    aFunc := GetProcAddress(fHandle,'SetProtocolType');
    if ValidPointer( aFunc, 'SetProtocolType')
    then EPS_SetProtocolType := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando SetProtocolType ');

    aFunc := GetProcAddress(fHandle,'GetProtocolType');
    if ValidPointer( aFunc, 'GetProtocolType')
    then EPS_GetProtocolType := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando GetProtocolType ');

    aFunc := GetProcAddress(fHandle,'ExtraFieldsCount');
    if ValidPointer( aFunc, 'ExtraFieldsCount')
    then EPS_ExtraFieldsCount := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando ExtraFieldsCount ');

    aFunc := GetProcAddress(fHandle,'FiscalStatus');
    if ValidPointer( aFunc, 'FiscalStatus')
    then EPS_FiscalStatus := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando FiscalStatus ');

    aFunc := GetProcAddress(fHandle,'PrinterStatus');
    if ValidPointer( aFunc, 'PrinterStatus')
    then EPS_PrinterStatus := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando PrinterStatus ');

    aFunc := GetProcAddress(fHandle,'ReturnCode');
    if ValidPointer( aFunc, 'ReturnCode')
    then EPS_ReturnCode := aFunc
    else bRet := False;
    GravaLog(' ImpEpsonTMU220AF - Comando ReturnCode ');

    If bRet Then
    begin
      If LogDll
      then EpsonLog( 'epson.log', PChar( 'Abrir: DLL Cargada!' ) );

      GravaLog(' ImpEpsonTMU220AF - DLL Carregada ');
    end
    else
    begin
      GravaLog(' ImpEpsonTMU220AF - Erro ao capturar os comandos da DLL ');
    end;

  end
  else
  begin
    ShowMessage( 'Abrir: Error al cargar DLL!!' );

    If LogDll
    Then EpsonLog( 'epson.log', PChar( 'Abrir: Error al cargar DLL!!' ) );

    GravaLog(' ImpEpsonTMU220AF - Erro ao carregar a DLL ');
    bRet := False;
  end;

  if bRet then
  begin
    IniFile := TIniFile.Create(ExpandFileName('sigaloja.ini'));

    If LogDll
    Then EpsonLog( 'epson.log', PChar( 'Puerto: ' + sPorta ) );

    //indica se o item tera mais que uma linha na impressao
    multiLine  := (IniFile.ReadInteger('epson','multiline',0) = 1);
    iBoundRate := IniFile.ReadInteger('epson','boundrate',9600);
    GravaLog(' ImpEpsonTMU220AF - Leitura do SIGALOJA.INI ');

    EPS_SetBoundRate(iBoundRate);
    GravaLog(' ImpEpsonTMU220AF - Setou a velocidade da porta - [' + IntToStr(iBoundRate) + ']');

    If LogDll
    Then EpsonLog( 'epson.log', PChar( 'Velocidad: ' + IntToStr(iBoundRate) ) );

    EPS_SetProtocolType(0);
    GravaLog(' ImpEpsonTMU220AF - Setou o Protocolo ');

    bRet := EPS_OpenPort();
    If bRet
    then GravaLog(' ImpEpsonTMU220AF - Abertura da Porta : True')
    else GravaLog(' ImpEpsonTMU220AF - Abertura da Porta : False');

    EpsonError(TRUE);
    GravaLog(' ImpEpsonTMU220AF - Setou Epson ERROR ');

    if bRet then
    begin
      GravaLog(' ImpEpsonTMU220AF - Antes de AlimentaProperties ');
      AlimentaProperties;
      GravaLog(' ImpEpsonTMU220AF - Depois de AlmientaProperties ');
      sTipoCup:='T';
      Result := '0|';
    end
    else
      Result := '1|';

  end;

GravaLog(' Fim da função Abrir - ImpEpsonTMU220AF -> Result :' + Result);
end;


//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.Fechar( sPorta:String ):String;
begin
  EPS_ClosePort;
  Result := '0|';
  If LogDll
  Then EpsonLog( 'epson.log', PChar( 'Cierra Puerto' ) );
end;


//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.PegaPDV:String;
var
  sPDV : String;
begin
  EPS_AddDataField( #42 );         // Solicitud de Estado
  EPS_AddDataField( 'C' );         // Información del Contribuyente
  EPS_SendCommand();
  sPDV := EPS_GetExtraField(2);    // PDV
  Result := '0|' + sPDV;

  If LogDll Then
     EpsonLog( 'epson.log', PChar( 'PegaPDV: ' + Result ) );

end;


//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.LeituraX:String;
begin
  EPS_AddDataField( #57 );         // Cierre de la Jornada Fiscal (Cierre ‘Z’) O
                                   // Cierre por cambio de Cajero (Cierre ‘X’)
  EPS_AddDataField( 'X' );         // Se hace un Cierre ‘X’
  EPS_AddDataField( 'P' );         // Si P el Cierre X sale impreso
  EPS_SendCommand();
  Result := '0|';

  If LogDll Then
     EpsonLog( 'epson.log', PChar( 'LeituraX: ' + Result ) );

end;


//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.ReducaoZ( MapaRes:String ):String;
begin
  EPS_AddDataField( #57 );         // Cierre de la Jornada Fiscal (Cierre ‘Z’) O
                                   // Cierre por cambio de Cajero (Cierre ‘X’)
  EPS_AddDataField( 'Z' );         // Se hace un Cierre ‘Z’
  EPS_AddDataField( 'P' );         // Si P el Cierre X sale impreso
  EPS_SendCommand();

  Result := EpsonError(TRUE); 

  If LogDll Then
     EpsonLog( 'epson.log', PChar( 'ReducaoZ: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String;
var
  sDataIn,sDataFim: String;
  bRet    : Boolean;
begin
  if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
    begin
    ReducInicio:= FormataTexto(ReducInicio,4,0,2);
    ReducFim   := FormataTexto(ReducFim,4,0,2);
    EPS_AddDataField( #59 );         // Reporte de la Memoria Fiscal por Fecha
    EPS_AddDataField( ReducInicio ); // Numero Z Inicio
    EPS_AddDataField( ReducFim );    // Numero Z Fim
    EPS_AddDataField( 'D' );         // Detallado con Centavos
    bRet := EPS_SendCommand();
    end
  else
    begin
    sDataIn    := Copy( FormataData(DataInicio,5), 3, 6 );
    sDataFim   := Copy( FormataData(DataFim,5), 3, 6 );
    EPS_AddDataField( #58 );         // Reporte de la Memoria Fiscal por Fecha
    EPS_AddDataField( sDataIn );     // Fecha Inicio
    EPS_AddDataField( sDataFim );    // Fecha Fim
    EPS_AddDataField( 'D' );         // Detallado con Centavos
    bRet := EPS_SendCommand();
    end;

  if bRet then Result := '0|' else Result := '1|';

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'MemoriaFiscal: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.AbreCupom(Cliente:String; MensagemRodape:String):String;

  function TipoCli( sTipo: String):String;
  begin
    if sTipo = 'I' then Result := 'I';
    if sTipo = 'N' then Result := 'R';
    if sTipo = 'E' then Result := 'E';
    if sTipo = 'M' then Result := 'M';
    if sTipo = 'C' then Result := 'F';
    if sTipo = 'A' then Result := 'S';
  end;

Var
   sTipo: String;
   aAuxiliar : TaString;
   sTipoCli  : String;
   sTipoDoc  : String;
   sLeyDom   : String;
   sLeyRem   : String;
   sRet      : String;
   iCont,iLinha,iColuna,iTtLinha: Integer;
Begin
   sTipo:='T';

   // if Copy( StatusImp(5), 1, 1 ) = '1' then CancelaCupom('SUPERVISOR');

   // Monta um array auxiliar com as formas solicitadas
   MontaArray( Cliente,aAuxiliar );
   //-----------------------------------------------------
   // aAuxiliar[0] => Serie A o B
   // aAuxiliar[1] => Razón Social
   // aAuxiliar[2] => CUIT
   // aAuxiliar[3] => TIPO    => E Exento
   //                         => C Consumidor Final
   //                         => A No Responsable
   //                         => I Responsable Inscripto
   //                         => M Monotributo
   // aAuxiliar[4] => TIPO ID => C CUIT
   //                         => 2 DNI
   // aAuxiliar[5] => Vendedor
   // aAuxiliar[6] => Condicion de Pago
   // aAuxiliar[7] => Indica se sera impressora ticket ----OBS. nao usado para essa epson ela soh imprime cupom
   // aAuxiliar[8] => Domicilio 1ra Linea
   // aAuxiliar[9] => Domicilio 2ra Linea
   // aAuxiliar[10] => Domicilio 3ra Linea
   //-----------------------------------------------------

   for iCont := 1 to 30 do aAuxiliar[9] := aAuxiliar[9] + ' ';
   for iCont := 1 to 10 do aAuxiliar[10] := aAuxiliar[10] + ' ';
   aAuxiliar[9] := Copy(aAuxiliar[9], 1, 30);
   aAuxiliar[10] := Copy(aAuxiliar[10], 1, 9);

   sRet := EpsonError(TRUE);

   if ( Length(aAuxiliar)>6 ) and ( sRet = '0|' ) then
   Begin
      sTipoCli := TipoCli( aAuxiliar[3] );
      if sTipoCli <> 'F' then sTipoDoc := 'CUIT' else sTipoDoc := ' ';
      sLeyDom  := 'Domicilio Desconocido';
      sLeyRem  := 'Sin Remitos Asociados';

      If Trim(MensagemRodape) <> '' Then
      Begin
         iTtLinha   := Length(Trim(MensagemRodape));
         If iTtLinha > 40
         Then iLinha  := iTtLinha div 40
         Else iLinha  := 12;

         If (iTtLinha > 40) And ((iTtLinha mod 40) <> 0) Then // Se o resto da divisão não for zero então soma mais uma linha
         Begin
          Inc(iLinha);
          iLinha   := iLinha + 11;
         End;

         iColuna  := 1;
         // As linhas que podem ser impressas vão de 11 a 16 com 40 caracteres por linha
         For iCont := 11 to iLinha-1 do
         Begin
          If iCont <= 16 Then
          Begin
            EPS_AddDataField( #93 );                                      // Este comando referencia o texto que será impresso no final do cupom, deve ser chamado para cada linha de texto.
            EPS_AddDataField( IntToStr(iCont) );                          //Linha onde será impresso texto
            EPS_AddDataField( Copy( Trim(MensagemRodape), iColuna , 40 ));//Texto a ser impresso
            EPS_SendCommand();                                            //Envia o comando
            iColuna := iColuna + 40;
          End;
          iTtLinha := iCont;
         End;

         For iTtLinha:= iTtLinha+1 to 16 do     // Deve-se limpar as linhas não utilizadas pois ele armazena o texto que foi impresso anteriormente
         Begin
           EPS_AddDataField( #93 );
           EPS_AddDataField( IntToStr(iTtLinha) );
           EPS_AddDataField( Space(40) );
           EPS_SendCommand();
         End;
      End;

      EPS_AddDataField( #96 );                                 // Abrir TF / TNC
      EPS_AddDataField( 'T' );                                 // 01 T para Ticket Factura
      EPS_AddDataField( 'C' );                                 // 02 IGNORADO
      EPS_AddDataField( aAuxiliar[0] );                        // 03 A o B
      EPS_AddDataField( '2' );                                 // 04 IGNORADO Cantidad de Copias
      EPS_AddDataField( 'F' );                                 // 05 IGNORADO
      EPS_AddDataField( '12' );                                // 06 IGNORADO
      EPS_AddDataField( 'I' );                                 // 07 IVA del EMISOR
      EPS_AddDataField( sTipoCli );                            // 08 IVA del COMPRADOR
      EPS_AddDataField( aAuxiliar[5] );                        // 09 Nombre 1ra Linea
      EPS_AddDataField( aAuxiliar[1] );                        // 10 Nombre 2da Linea
      EPS_AddDataField( sTipoDoc );                            // 11 Tipo de Documento
      EPS_AddDataField( aAuxiliar[2] );                        // 12 Nro de Documento
      EPS_AddDataField( 'N' );                                 // 13 Leyenda Bien de Uso
      EPS_AddDataField( aAuxiliar[8] );                        // 14 Domicilio 1ra Linea
      EPS_AddDataField( aAuxiliar[9] + ' ' + aAuxiliar[10] );  // 15 Domicilio 2da Linea
      EPS_AddDataField( aAuxiliar[6] );                        // 16 Domicilio 3ra Linea
      EPS_AddDataField( sLeyRem );                             // 17 Remitos 1ra Linea
      EPS_AddDataField( ' ' );                                 // 18 Remitos 2da Linea
      EPS_AddDataField( 'C' );                                 // 19 Para Farmacias
      EPS_SendCommand();
      sRet := EpsonError(TRUE);
      If Copy(sRet, 1, 2) = '1|' then
         CancelaCupom( ' ' )
      Else
         sCupom := Copy(PegaCupom(''), 3, 8);
   end
   else
      Result:='1|';

   Result := sRet;

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'AbreCupom: ' + Result ) );

End;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.CancelaCupom( Supervisor:String ):String;
var
   sTemp : String;
   sRet  : String; 
begin
   sTemp := HexToBin( IntToHex( EPS_FiscalStatus(), 4 ) );

   if Length( sTemp ) > 16 then sTemp := Copy( sTemp, 17, 16 );

   if ( Copy( sTemp, 4, 1 ) = '1' ) or ( Copy( sTemp, 3, 1 ) = '1' ) then 
      begin  
      EPS_AddDataField( #100 );
      EPS_AddDataField( 'EFECTIVO' );
      EPS_AddDataField( '00000000001' );
      EPS_AddDataField( 'T' );
      EPS_SendCommand();

      EPS_AddDataField( #100 );
      EPS_AddDataField( 'EFECTIVO' );
      EPS_AddDataField( '00000000001' );
      EPS_AddDataField( 'C' );
      EPS_SendCommand();
      sRet := EpsonError(FALSE); 

      if Copy(sRet, 1, 1) = '1' then
         begin
         //fechando comprovante nao fiscal
         sRet := '';
         EPS_AddDataField( #74 );
         EPS_AddDataField( 'T' );
         EPS_SendCommand();
         sRet := EpsonError(FALSE);

         end;
      end

   else
      begin
      EPS_AddDataField( #68 );
      EPS_AddDataField( 'Cancelar' );
      EPS_AddDataField( '00000000001' );
      EPS_AddDataField( 'C' );
      EPS_SendCommand();
      sRet := EpsonError(FALSE); 

      end;

      Result := sRet; 

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'CancelaCupom: ' + Result ) );

End;

//------------------------------------------------------------------------------
Function ImpEpsonTMU220AF.PegaSerie:String;
Var
  sSerie : String;
Begin
  EPS_AddDataField( #42 );         // Solicitud de Estado
  EPS_AddDataField( 'D' );         // Información sobre el documento que se esta emitiendo.
  EPS_SendCommand();
  sSerie := EPS_GetExtraField(2);  // Serie
  Result := '0|' + sSerie;

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'PegaSerie: ' + Result ) );

End;

//------------------------------------------------------------------------------
Function ImpEpsonTMU220AF.ImpTxtFis(Texto : String) : String;
var
   sRet : String;
Begin

//24-06-14 : Este comando não funcionou pra enviar as linhas adicionais
//por enquanto a alteração somente funciona para Hasar assim que encontrar o comando
//correto deve-se efetuar a correção.
(*sAux := Texto;
nCont:= 1;
While (sAux <> '') and (nCont <= 4) do
begin
  EPS_AddDataField( #65 );
  EPS_AddDataField( Copy(sAux,1,26) );
  EPS_SendCommand();
  sAux := Copy(sAux,27,Length(sAux));
  Inc(nCont);
end; *)

If LogDLL
then EpsonLog('epson.log', PChar('ImpTxtFis: Comando Não Implementado para este modelo'));

sRet := '0|';
Result := sRet;
End;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.RegistraItem(codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String;
Var
  sSerie    : String;
  slinDesc1 : String;
  slinDesc2 : String;
  slinDesc3 : String;
  sRet      : String;
  bDesconto : Boolean;
  nPos      : Integer;
begin
  sRet   := '0|';
  bDesconto := False;
  sSerie := PegaSerie;
  sSerie := Copy( sSerie, 3, 1 );
  aliquota := Copy(aliquota, 1, 5);
  nPos := Pos('|',aliquota);

  if nPos > 0 then
     aliquota := Copy(aliquota,1,(nPos-1));

  if Trim(vlrdesconto) <> '0.00' then
     begin
        bDesconto   := True;
        vlrdesconto := Trim(vlrdesconto);
        if sSerie = 'B' then
            vlrdesconto :=  FloatToStrF( StrToFloat( vlrdesconto ) * ( 1 + ( StrToFloat( aliquota ) / 100 ) ),
                                 ffGeneral, 9, 4 );
     end;

  if sRet = '0|' then
  begin

     if sSerie = 'B' then
        vlrUnit :=  FloatToStrF( StrToFloat( vlrUnit ) * ( 1 + ( StrToFloat( aliquota ) / 100 ) ),
                                 ffGeneral, 9, 4 );

     if multiLine then
     begin
         slinDesc1 :=  Copy(descricao + space(26), 01, 26);
         slinDesc2 :=  Trim( Copy(descricao + space(52), 27, 26) );
         slinDesc3 :=  Trim( Copy(descricao + space(78), 53, 26) );
     end
     else
     begin
         slinDesc1 :=  Copy(descricao + space(26), 01, 26);
         slinDesc2 :=  '';
         slinDesc3 :=  '';
     end;

     sRet := EpsonError(TRUE);

     if ( sSerie <> 'A' ) and ( sSerie <> 'B' ) then
        Result := '1|'
     else
     begin
        EPS_AddDataField( #98 );
        EPS_AddDataField( Copy( codigo + Space(18), 1, 18 ) );
        EPS_AddDataField( Trim( FormataTexto( qtde, 8, 3, 4 ) ) );
        EPS_AddDataField( Trim( FormataTexto( vlrUnit, 9, 4, 3 ) ) );
        EPS_AddDataField( FormataTexto( aliquota , 4, 2, 2 ) );
        EPS_AddDataField( 'M' );
        EPS_AddDataField( '00000' );
        EPS_AddDataField( '00000000' );
        EPS_AddDataField( slinDesc1 );
        EPS_AddDataField( slinDesc2 );
        EPS_AddDataField( slinDesc3 );
        EPS_AddDataField( FormataTexto( '0', 4, 2, 2 ) );
        EPS_AddDataField( '000000000000000' );
        EPS_SendCommand();
        sRet := EpsonError(TRUE);

        if ( sRet = '0|' ) and ( bDesconto ) then
        begin
           EPS_AddDataField( #98 );
           EPS_AddDataField( '.' );
           EPS_AddDataField( Trim( FormataTexto( '1.000', 8, 3, 4 ) ) );
           EPS_AddDataField( Trim( FormataTexto( vlrdesconto, 9, 4, 3 ) ) );
           EPS_AddDataField( FormataTexto( aliquota , 4, 2, 2 ) );
           EPS_AddDataField( 'R');
           EPS_AddDataField( '00001' );
           EPS_AddDataField( '00000000' );
           EPS_AddDataField( '' );
           EPS_AddDataField( '' );
           EPS_AddDataField( '' );
           EPS_AddDataField( FormataTexto( '0', 4, 2, 2 ) );
           EPS_AddDataField( '000000000000000' );
           EPS_SendCommand();
           sRet := EpsonError(TRUE);
        end;
     end;
  end;

  Result := sRet;

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'RegistraItem: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
Var
  sSerie : String;
  iPos1  : Integer;
  iPos2  : Integer;
  aliq : String;
begin
  sSerie := PegaSerie;
  sSerie := Copy( sSerie, 3, 1 );

  iPos1 := Pos('%',aliquota)+1;
  iPos2 := Pos('|',aliquota)-2;
  aliq  := Copy( aliquota, iPos1, iPos2 );

  if ( sSerie <> 'A' ) and ( sSerie <> 'B' ) then
    Result := '1|'
  else
    begin
    EPS_AddDataField( #98 );
    EPS_AddDataField( Copy( codigo + Space(18), 1, 18 ) );
    EPS_AddDataField( FormataTexto( qtde, 8, 3, 2 ) );
    EPS_AddDataField( FormataTexto( vlrUnit, 9, 2, 2 ) );
    EPS_AddDataField( FormataTexto( aliq, 4, 2, 2 ) );
    EPS_AddDataField( 'm' );
    EPS_AddDataField( '00000' );
    EPS_AddDataField( '00000000' );
    EPS_AddDataField( Copy(descricao + space(26), 01, 26) );
    EPS_AddDataField( Copy(descricao + space(52), 27, 26) );
    EPS_AddDataField( FormataTexto( '0', 4, 2, 2 ) );
    EPS_AddDataField( '' );
    EPS_SendCommand();
    Result := EpsonError(TRUE)
    end;

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'CancelaItem: ' + Result ) );

end;


//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.FechaCupom( Mensagem:String ):String;
var sSerie :String;
    sCupA,sCupBC :String;
begin
   EPS_AddDataField( #42 );         // Solicitud de Estado
   EPS_AddDataField( 'D' );         // Información sobre el documento que se esta emitiendo.
   EPS_SendCommand();
   sSerie := EPS_GetExtraField(2);  // Serie

   EPS_AddDataField( #101 );        // Cerrar Comprobante Fiscal Tique.
   EPS_AddDataField( 'T' );         // ‘F’= Factura Fiscal
                                    // ‘T’= Tique-Factura Fiscal
                                    // ‘R’= Si Estoy Abriendo un Recibo-Factura
   EPS_AddDataField( sSerie );      // Serie
   EPS_AddDataField( #177 );        // Ascii DEL

   EPS_SendCommand();

   EPS_AddDataField( #42 );
   EPS_AddDataField( 'A' );
   EPS_SendCommand();
   sCupBC := EPS_GetExtraField(2);
   sCUPA  := EPS_GetExtraField(4);

   Sleep(2000);

   If sSerie = 'A' Then
   Begin
      If sCupom = sCUPA Then
         Result := '0|'
      Else
         Result := '1|';
   End
   Else If sSerie = 'B' Then
   Begin
      If sCupom = sCUPBC Then
         Result := '0|'
      Else
         Result := '1|';
   End
   Else
      Result := '1|';

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'FechaCupom: ' + Result ) );

end;


//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.AbreECF: String;
begin
  result := '0|';

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'AbreECF: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.FechaECF: String;
begin
  Result := ReducaoZ('N');

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'FechaECF: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.Status( Tipo: Integer;Texto:String ):String;
begin
  result := '0|';

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'Status: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.StatusImp( Tipo:Integer ):String;
var
  sTemp : String;
begin

  //Tipo - Indica qual o status quer se obter da impressora
  //  1 - Obtem a Hora da Impressora
  //  2 - Obtem a Data da Impressora
  //  3 - Verifica o Papel
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  //  5 - Cupom Fechado ?
  //  6 - Ret. suprimento da impressora
  //  7 - ECF permite desconto por item
  //  8 - Verifica se o dia anterior foi fechado
  //  9 - Verifica o Status do ECF
  // 10 - Verifica se todos os itens foram impressos.
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  // 16 - Verifica se exige o extenso do cheque
  // 17 - Información sobre los contadores de documentos fiscales y no fiscales        
  // 18 - Verifica Grande Total (RICMS 01 - SC - ANEXO 09)
  // 19 - Retorna a data do movimento da impressora
  // 20 - Retorna o CNPJ( CUIT ) cadastrado na impressora          
  // 45  - Modelo Fiscal
  // 46 - Marca, Modelo e Firmware

// Hace la Lectura de la Hora
if Tipo = 1 then
  begin
  EPS_AddDataField( #89 );         // Solicitud de Estado
  EPS_SendCommand();
  sTemp := EPS_GetExtraField(2);
  Result := '0|' + Copy(sTemp,1,2)+':'+Copy(sTemp,3,2)+':'+Copy(sTemp,5,2);
  end
// Faz a leitura da Data
else if Tipo = 2 then
  begin
  EPS_AddDataField( #89 );         // Solicitud de Estado
  EPS_SendCommand();
  sTemp := EPS_GetExtraField(1);
  Result := '0|'+Copy(sTemp,5,2)+'/'+Copy(sTemp,3,2)+'/'+Copy(sTemp,1,2);
  end
// Faz a checagem de papel
else if Tipo = 3 then
   begin
   sTemp := IntToHex( EPS_PrinterStatus(), 4 );
   result:= Copy( sTemp, 2, 1) + '|';
   end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
   result:= '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
   begin
   sTemp := HexToBin( IntToHex( EPS_FiscalStatus(), 4 ) );

   if Length( sTemp ) > 16 then sTemp := Copy( sTemp, 17, 16 );

   if ( Copy( sTemp, 4, 1 ) = '1' ) or ( Copy( sTemp, 3, 1 ) = '1' ) then
      result:='7|'
   else
      result:='0|';
   end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
   result := '0|0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
   result := '0|'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
   result := '1|'
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
   result := '1|'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
   result := '1|'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 Then
   result := '1'
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
else if Tipo = 12 then
   result := '0|'
// 13 - Verifica se o ECF Arredonda o Valor do Item
else if Tipo = 13 then
   result := '1|'
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
else if Tipo = 14 then
   result := '0'
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
   result := '1|'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
   result := '1|'
// 17 - Información sobre los contadores de documentos fiscales y no fiscales         
else if Tipo = 17 then
  begin
  EPS_AddDataField( #42 );                 // Solicitud de Estado
  EPS_AddDataField( 'A' );                 // Información sobre los Numeradores
  EPS_SendCommand();
  //Result := '0| | |' + EPS_GetExtraField(3) + '| |' +  // Número del último Tique impreso o Factura B,C o Tique-Factura B,C
  //                     EPS_GetExtraField(5) + '| |' +  // Número del último Tique-Factura A o Factura A impreso
  //                     EPS_GetExtraField(10)+ '|' +    // Número de último comprobante Tique-Nota de Crédito o Nota de Crédito ‘B’ o ‘C’ emitido
  //                     EPS_GetExtraField(9) + '|' +    // Número de último comprobante Tique-Nota de Crédito o Nota de Crédito ‘A’ emitido
  //                     EPS_GetExtraField(8);           // Número del último número de referencia para Documentos No Fiscales o No Fiscales homologados emitido
  Result := '0|' + chr(28) + chr(28) + EPS_GetExtraField(3) + chr(28) + chr(28) + EPS_GetExtraField(5) + chr(28) + chr(28) + EPS_GetExtraField(10)+ chr(28) + EPS_GetExtraField(9) + chr(28) + EPS_GetExtraField(8);
  end
// 18 - Verifica Grande Total (RICMS 01 - SC - ANEXO 09)
else if Tipo = 18 then
   result := '1'
// 19 - Retorna a data do movimento da impressora
else if Tipo = 19 then
   result := '1'
// 20 - Retorna o CNPJ( CUIT ) cadastrado na impressora
else if Tipo = 20 then
  begin
  EPS_AddDataField( #42 );                  // Solicitud de Estado
  EPS_AddDataField( 'C' );                  // Información del Contribuyente
  EPS_SendCommand();
  Result := '0|' + EPS_GetExtraField(1);    // CUIT
  end

else If Tipo = 45 then
  Result := '0|'// 45 Codigo Modelo Fiscal
else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
  Result := '0|'// 45 Codigo Modelo Fiscal
else
   result := '1';

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'StatusImp: ' + IntToStr( Tipo ) + ' => ' + Result ) );

end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.EnvCmd( Comando:String; Posicao: Integer ): String;
var
   aAux:TaString;
   i,iLen:Integer;
   sRet:String;
begin
   MontaArray( Comando, aAux );
   i:= 0;

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'EnvCmd: ' ) );

   while i<Length(aAux) do
      begin
      EPS_AddDataField( aAux[i] );
      if LogDll then
         EpsonLog( 'epson.log', PChar( IntToStr( i ) + ' => ' + aAux[i] ) );

      i := i +1;
      end;

   EPS_SendCommand();
   sRet := EpsonError(TRUE) + '|';

   iLen:= EPS_ExtraFieldsCount();

   for i := 1 to iLen do
      sRet := sRet + EPS_GetExtraField(i) + '|';

   Result := sRet;

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'Respuesta:  => ' + Result ) );

end;

//----------------------------------------------------------------------------
procedure ImpEpsonTMU220AF.AlimentaProperties;
Var
  sRet: String;
Begin
    sRet := PegaPdv;
    If Copy(sRet,1,1) = '0' then
    Begin
        PDV := Copy(sRet,3,Length(sRet));
        sPDV := PDV;
    End;
GravaLog(' ImpEpsonTMU220AF - Fim de AlimenteProperties -> sPDV :' + sPDV);
End;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.PegaCupom(Cancelamento:String):String;
var
   sStatus, sTipo, sSerie, sDoc : String;
   iStatus:Integer;
begin
   iStatus := EPS_FiscalStatus();
   if iStatus < 0 then iStatus := iStatus * -1 ;
   sStatus := IntToHex( iStatus, 4 );
   sStatus := HexToBin( sStatus );

   // Documento Fiscal abierto o
   // Documento No Fiscal abierto que se emite por el rollo de papel
   if ( Copy( sStatus, 4, 1 ) = '1' ) or ( Copy( sStatus, 3, 1 ) = '1' ) then
      begin
      EPS_AddDataField( #42 );         // Solicitud de Estado
      EPS_AddDataField( 'D' );         // Información sobre el Documento en Curso
      EPS_SendCommand();

      sTipo := EPS_GetExtraField(1);
      // ‘K’ Tique.
      // ‘T’ Tique-Factura.
      // ‘O’ Documento No Fiscal.
      // ‘H’ Documento No Fiscal Homologado.
      // ‘M’ Documento No Fiscal Homologado Tique Nota de Crédito

      sSerie := EPS_GetExtraField(2);
      // ‘N’ No tiene una letra que identifique al documento.
      // ‘A’ Documento emitido con letra A.
      // ‘B’ Documento emitido con letra B.
      // ‘C’ Documento emitido con letra C.

      EPS_AddDataField( #42 );         // Solicitud de Estado
      EPS_AddDataField( 'A' );
      EPS_SendCommand();

      if ( sTipo = 'K' ) and ( sSerie = 'A' ) then sDoc := EPS_GetExtraField(5)
      else if ( sTipo = 'T' ) and ( sSerie = 'A' ) then sDoc := EPS_GetExtraField(5)
      else if ( sTipo = 'K' ) and ( sSerie = 'B' ) then sDoc := EPS_GetExtraField(3)
      else if ( sTipo = 'T' ) and ( sSerie = 'B' ) then sDoc := EPS_GetExtraField(3)
      else if ( sTipo = 'K' ) and ( sSerie = 'C' ) then sDoc := EPS_GetExtraField(3)
      else if ( sTipo = 'T' ) and ( sSerie = 'C' ) then sDoc := EPS_GetExtraField(3)
      else if ( sTipo = 'M' ) and ( sSerie = 'A' ) then sDoc := EPS_GetExtraField(9)
      else if ( sTipo = 'M' ) and ( sSerie = 'B' ) then sDoc := EPS_GetExtraField(10)
      else if ( sTipo = 'M' ) and ( sSerie = 'C' ) then sDoc := EPS_GetExtraField(10)
      else if ( sTipo = 'O' ) then sDoc := EPS_GetExtraField(6)
      else sDoc := Space(12);

      result := '0|' + sDoc;
      end
   else
      begin
        EPS_AddDataField( #42 );      // Solicitud de Estado
        EPS_AddDataField( 'A' );      // Información sobre los Numeradores
        EPS_SendCommand();

        sDoc := EPS_GetExtraField(3); // Número del último Tique impreso o Factura B,C o Tique-Factura B,C
        result := '0|' + sDoc;
      end;

   if Trim(sDoc) = ''
   then Result := '1|';

   if LogDll
   then EpsonLog( 'epson.log', PChar( 'PegaCupom: ' + result ) );

end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String;
Begin
   vlrDesconto := Copy(vlrDesconto,Pos('|', vlrDesconto)+1, Length(vlrDesconto));
   vlrDesconto := Copy(vlrDesconto,1, Pos('|', vlrDesconto)-1);
   vlrDesconto := FormataTexto( vlrDesconto, 11, 2, 2 );

   EPS_AddDataField( #100 );
   EPS_AddDataField( 'DESCUENTO' );
   EPS_AddDataField( vlrDesconto );
   EPS_AddDataField( 'D' );
   EPS_SendCommand();
   Result := EpsonError(TRUE);

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'DescontoTotal: ' + result ) );

End;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.AcrescimoTotal( vlrAcrescimo:String ): String;
begin
   vlrAcrescimo := Copy(vlrAcrescimo,Pos('|', vlrAcrescimo)+1, Length(vlrAcrescimo));
   vlrAcrescimo := Copy(vlrAcrescimo,1, Pos('|', vlrAcrescimo)-1);
   vlrAcrescimo := FormataTexto( vlrAcrescimo, 11, 2, 2 );

   EPS_AddDataField( #100 );
   EPS_AddDataField( 'RECARGO' );
   EPS_AddDataField( vlrAcrescimo );
   EPS_AddDataField( 'R' );
   EPS_SendCommand();
   Result   := EpsonError(TRUE);

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'AcrescimoTotal: ' + Result ) );

end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.Percepcao(sAliq, sTexto, sValor: String): String;
begin
   EPS_AddDataField( #102 );
   EPS_AddDataField( sTexto );
   EPS_AddDataField( 'O' );
   EPS_AddDataField( FormataTexto( sValor, 8, 2, 2 ) );
   EPS_AddDataField( '0000' );
   EPS_SendCommand();
   Result := EpsonError(TRUE);

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'Percepcao: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.SubTotal(sImprime: String):String;
var
   sRet, sErr, sField: string;
begin
   EPS_AddDataField( #99 );
   EPS_AddDataField( 'N' );
   EPS_AddDataField( ' ' );
   EPS_SendCommand();
   sErr   := EpsonError(TRUE);
   if sErr = '0|' then
      begin
      sRet := '0|';
      sRet := sRet + IntToHex( EPS_PrinterStatus(), 4 ) + #28;
      sRet := sRet + IntToHex( EPS_FiscalStatus(), 4 ) + #28;

      sField := EPS_GetExtraField(2);
      sRet := sRet + Trim( sField ) + #28;

      sField := EPS_GetExtraField(3);
      sField := Copy( sField, 1, Length( sField ) -2 ) + '.' +
                Copy( sField, Length( sField ) -1, Length( sField ) );
      sRet := sRet + Trim( sField ) + #28;

      sField := EPS_GetExtraField(4);
      sField := Copy( sField, 1, Length( sField ) -2 ) + '.' +
                Copy( sField, Length( sField ) -1, Length( sField ) );
      sRet := sRet + Trim( sField ) + #28;

      sRet := sRet + '0.00' + #28;

      sField := EPS_GetExtraField(7);
      sField := Copy( sField, 1, Length( sField ) -2 ) + '.' +
                Copy( sField, Length( sField ) -1, Length( sField ) );
      sRet := sRet + Trim( sField );
      end
   else
      sRet := '1|' + sErr;

   Result := sRet;

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'SubTotal: ' + Result ) );

end;

//---------------------------------------------------------------------------
Function ImpEpsonTMU220AF.Pagamento( Pagamento, Vinculado, Percepcion:String ): String;
Var
  aAuxiliar   : TaString;
  aPercepcion : TaString;
  sMensagem   : String;
  sSubTotal   : String;
  sSerie      : String;
  sRet        : String;
  i           : Integer;
  iPercepcion : double;
Begin

   If LogDll Then
      EpsonLog( 'epson.log', PChar( 'Pagamento( Pagamento: ' + Pagamento + ', Vinculado: ' + Vinculado + ', Percepcion: ' + Percepcion + ')' ) );

   i := 0;
   iPercepcion := 0;
   sRet := '0';
   sSerie := PegaSerie;
   sSerie := Copy( sSerie, 3, 1 );
   Pagamento := StrTran( Pagamento, ',', '.' );
   MontaArray( Pagamento, aAuxiliar );
   sMensagem := 'Lo número máximo de modos de pago excedieron.';

   // Monta um array com as percepciones a serem enviadas
   MontaArray( Percepcion, aPercepcion );

   While i < Length( aPercepcion ) Do
   Begin
      iPercepcion := iPercepcion + StrToFloat( aPercepcion[i+2] );
      Inc( i, 3 );
   End;

   i := 0;

  If LogDll Then EpsonLog( 'epson.log', PChar( 'Length(aPercepcion): ' + IntToStr(Length(aPercepcion)) ) );

   //impressora permite ate 4 formas de pagamento
   If Length(aAuxiliar) > 8 Then
      Begin
      sRet := '1|' + sMensagem;
      ShowMessage( sMensagem );
      End;

   If Copy(sRet, 1, 1) <> '1' Then
      Begin
      EPS_AddDataField( #99 );
      EPS_AddDataField( 'P' );
      EPS_AddDataField( 'SubTotal' );
      EPS_SendCommand();
      sRet   := EpsonError(TRUE);
      If sRet = '0|' Then
         Begin
         sSubTotal := EPS_GetExtraField(3);
         sSubTotal := Copy( sSubTotal, 1, Length( sSubTotal ) - 2 ) + '.' + Copy( sSubTotal, Length( sSubTotal ) - 1 , 2);
         sSubTotal := FormataTexto( sSubTotal, 11, 2, 5 );

         If Abs(StrToFloat(Vinculado) - ( StrToFloat(sSubTotal) + iPercepcion )) >= 0.005 then
         Begin
            If ( StrToFloat( sSubTotal ) + iPercepcion ) > StrToFloat( Vinculado ) Then
               Begin
               sSubTotal := FloatToStr( ( StrToFloat( sSubTotal ) + iPercepcion ) - StrToFloat( Vinculado ) );
               sSubTotal := FormataTexto( sSubTotal, 11, 2, 2 );
               EPS_AddDataField( #100 ); //Desconto
               EPS_AddDataField( 'Ajuste por Redondeo' );
               EPS_AddDataField( sSubTotal );
               EPS_AddDataField( 'D' );
               EPS_SendCommand();
               sRet := EpsonError(TRUE);
               If LogDll Then
                  EpsonLog( 'epson.log', PChar( 'Ajuste por Redondeo-: ' + sRet ) );
               End
            Else If ( StrToFloat( sSubTotal ) + iPercepcion ) < StrToFloat( Vinculado ) Then
               Begin
               sSubTotal := FloatToStr( ( StrToFloat( sSubTotal ) + iPercepcion ) - StrToFloat( Vinculado ) );
               sSubTotal := StrTran( sSubTotal, '-', '');
               sSubTotal := FormataTexto( sSubTotal, 11, 2, 2 );
               EPS_AddDataField( #100 );  //Acrescimo
               EPS_AddDataField( 'Ajuste por Redondeo' );
               EPS_AddDataField( sSubTotal );
               EPS_AddDataField( 'R' );
               EPS_SendCommand();
               sRet := EpsonError(TRUE);
               If LogDll Then
                  EpsonLog( 'epson.log', PChar( 'Ajuste por Redondeo+: ' + sRet ) );
               End;
            End;
         End;
      End;
   // Faz o registro das percepciones se houver
   If Copy(sRet, 1, 1) <> '1' Then
      Begin
      If Length(aPercepcion) > 0 Then
         Begin
         While i<Length(aPercepcion) Do
            Begin
            If LogDll Then EpsonLog( 'epson.log', PChar( 'Percepcao( '+ aPercepcion[i] + ', ' + aPercepcion[i+1] + ', ' + aPercepcion[i+2] + ') ' ) );
            Percepcao(aPercepcion[i], aPercepcion[i+1], aPercepcion[i+2]);
            Inc(i,3);
            End;
            i:=0;
         End;
      End;

   // Faz o registro do pagamento
   If Copy(sRet, 1, 1) <> '1' Then
      Begin
      While (i < Length(aAuxiliar) ) do
         Begin
         EPS_AddDataField( #100 );
         EPS_AddDataField( aAuxiliar[i] );
         EPS_AddDataField( FormataTexto( aAuxiliar[i+1], 11, 2, 2 ) );
         EPS_AddDataField( 'T' );
         EPS_SendCommand();
         sRet := EpsonError(TRUE);
         Inc(i,2);
         End;
      End;

   result := sRet;

   If LogDll Then
      EpsonLog( 'epson.log', PChar( 'Pagamento: ' + Result ) );

End;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.ImpostosCupom(Texto: String): String;
begin
   Result := '0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'ImpostosCupom: ' + Result ) );
end;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.LeAliquotas:String;
begin
   Result := '0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'LeAliquotas: ' + Result ) );
end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.LeAliquotasISS:String;
begin
   Result := '0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'LeAliquotasISS: ' + Result ) );
end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.LeCondPag:String;
begin
   Result := '0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'LeCondPag: ' + Result ) );
end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
begin
   Result := '0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'AdicionaAliquota: ' + Result ) );
end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
begin
  EPS_AddDataField( #72 );
  EPS_SendCommand();
  Result := EpsonError(TRUE);

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'AbreCupomNaoFiscal: ' + Result ) );
end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
Var
  sCmd: string;
  nX  : Integer;
begin
  nX:=0;
  while Length(Texto)>0 do
     begin
     if ( Copy(Texto,1,1)=#$A ) or ( nX=40 ) Then
        begin
        sCmd   := Trim(sCmd);
        EPS_AddDataField( #73 );
        EPS_AddDataField( sCmd );
        EPS_SendCommand();
        sCmd   := '';
        Texto  := Copy(Texto,2,length(Texto));
        nX     := 0;
        end
     else
        begin
        Inc(nX);
        sCmd   := sCmd+Copy(Texto,1,1);
        Texto  := Copy(Texto,2,length(Texto));
        end;
     end;

  sCmd   := Trim(sCmd);
  EPS_AddDataField( #73 );
  EPS_AddDataField( sCmd );
  EPS_SendCommand();
  result := EpsonError(FALSE); 

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'TextoNaoFiscal: ' + Result ) );

end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.FechaCupomNaoFiscal: String;
begin
   EPS_AddDataField( #74 );
   EPS_AddDataField( 'T' );
   EPS_SendCommand();
   result := EpsonError(TRUE);

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'TextoNaoFiscal: ' + Result ) );

end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.MemTrab:String;
begin
   result := '0|NO SOPORTADO';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'MemTrab: ' + Result ) );

end;

//-----------------------------------------------------------
function ImpEpsonTMU220AF.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
begin
   Result:='0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'Pedido: ' + Result ) );
end;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
begin
   Result:='0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'Autenticacao: ' + Result ) );
end;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.GravaCondPag( condicao:string ) : String;
begin
   Result:='0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'GravaCondPag: ' + Result ) );
end;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
Var
  sRet: string;
  aAuxiliar : TaString; 
  i         : Integer;
begin
    i:= 0;
    MontaArray( FormaSupr, aAuxiliar ); 

    if Tipo = 1 then
    begin
    //Função não disponível para este equipamento
        sRet := '0|';
    end

    else if Tipo = 2 then
    begin
        sRet := AbreCupomNaoFiscal('','', '', '');
        if sRet = '0|' then
            begin
            If Forma = '' then
               Forma := 'Efectivo';
            sRet := TextoNaoFiscal('*************FUNDO DE TROCO**************', 1);
            sRet := TextoNaoFiscal(Valor + ' - ' + Forma, 1);
            end;
        if sRet = '0|' then
            sRet := FechaCupomNaoFiscal();
     end

    else if Tipo = 3 then
    begin
        sRet := AbreCupomNaoFiscal('','', '', '');
        if sRet = '0|' then
            begin
            sRet := TextoNaoFiscal('*****************SANGRIA*****************', 1);
            While i < Length(aAuxiliar) do
               begin
               sRet := TextoNaoFiscal(aAuxiliar[i + 1] + ' - ' + aAuxiliar[i],1);
               Inc(i,2)
               end;
            end;
        if sRet = '0|' then
            sRet := FechaCupomNaoFiscal();
    end;

   Result := sRet;

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'Suprimento: ' + Result ) );
end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.AbreDNFH( sTipoFat, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: String):String;
  function TipoFat( sTipoFat: String):String;
  begin
    If sTipoFat = 'R' then
       Result := 'A'
    Else
       Result := 'B';
  end;

  function TipoCli( sTipo: String):String;
  begin
    if sTipo = 'I' then Result := 'I';
    if sTipo = 'N' then Result := 'R';
    if sTipo = 'E' then Result := 'E';
    if sTipo = 'M' then Result := 'M';
    if sTipo = 'C' then Result := 'F';
  end;

Var
   aCliente : TaString;
   sTipoCli,  sTipoDoc, sLeyRem, sNumCup, sRet : String;
Begin

   //dados do cliente
   MontaArray( sDadosCli, aCliente );

   //tipo de documento
   sTipoFat := TipoFat( sTipoFat );

   //tipo do cliente
   sTipoCli := TipoCli( aCliente[2] );
   if sTipoCli <> 'F' then sTipoDoc := 'CUIT' else sTipoDoc := ' ';

   //tipo de documento de identificacao
   sTipoDoc := aCliente[3];

   //sLeyDom  := 'Domicilio Desconocido';
   sLeyRem  := 'Sin Remitos Asociados';

   EPS_AddDataField( #96 );             // Abrir TNC
   EPS_AddDataField( 'M' );             // 01 M para Tique-Nota de Crédito Fiscal
   EPS_AddDataField( 'C' );             // 02 IGNORADO
   EPS_AddDataField( sTipoFat );        // 03 A o B
   EPS_AddDataField( '1' );             // 04 IGNORADO
   EPS_AddDataField( 'F' );             // 05 IGNORADO
   EPS_AddDataField( '12' );            // 06 IGNORADO
   EPS_AddDataField( 'I' );             // 07 IVA del EMISOR
   EPS_AddDataField( sTipoCli );        // 08 IVA del COMPRADOR
   EPS_AddDataField( aCliente[0] );     // 09 Nombre 1ra Linea
   EPS_AddDataField( ' ' );             // 10 Nombre 2da Linea
   EPS_AddDataField( sTipoDoc );        // 11 Tipo de Documento
   EPS_AddDataField( aCliente[1] );     // 12 Nro de Documento
   EPS_AddDataField( 'N' );             // 13 Leyenda Bien de Uso
   EPS_AddDataField( Copy(aCliente[4], 1, 40) );     // 14 Domicilio 1ra Linea  
   EPS_AddDataField( Copy(aCliente[4], 41, 10) );    // 15 Domicilio 2da Linea
   EPS_AddDataField( ' ' );             // 16 Domicilio 3ra Linea
   EPS_AddDataField( sLeyRem );         // 17 Remitos 1ra Linea
   EPS_AddDataField( ' ' );             // 18 Remitos 2da Linea
   EPS_AddDataField( 'C' );             // 19 Para Farmacias
   EPS_SendCommand();
   sRet := EpsonError(TRUE);

   //Retornar para o protheus o numero do DNFH aberto desse jeito
   If Copy(sRet, 1, 1) = '0' then
      begin
      sNumCup := PegaCupom('');
      If Trim(sNumCup) <> '' then
         begin
         sNumCup := '| |' + Copy(sNumCup, 3, Length(sNumCup));
         Result := '0|' + sNumCup;
         end
      Else
         Result := '1|';
      end;
   
   if LogDll then
      EpsonLog( 'epson.log', PChar( 'AbreDNFH: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.FechaDNFH: String;
var sSerie :String;
begin
   EPS_AddDataField( #42 );         // Solicitud de Estado
   EPS_AddDataField( 'D' );         // Información sobre el documento que se esta emitiendo.
   EPS_SendCommand();
   sSerie := EPS_GetExtraField(2);  // Serie

   EPS_AddDataField( #101 );        // Cerrar Comprobante Fiscal Tique.
   EPS_AddDataField( 'M' );         // M = Tique-Nota de Crédito Fiscal

   EPS_AddDataField( sSerie );      // Serie
   EPS_AddDataField( #177 );        // Ascii DEL
   EPS_SendCommand();
   Result := EpsonError(TRUE);

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'FechaDNFH: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTMU220AF.Gaveta : String;
begin
   EPS_AddDataField( #123 );        // Abrir el Cajón 1 de Efectivo
   EPS_SendCommand();
   Result := EpsonError(TRUE);

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'Gaveta: ' + Result ) );

end;

//----------------------------------------------------------------------------
function ImpEpsonTMU220AF.ReImprime: String;
begin
   Result := '0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'ReImprime: ' + Result ) );
end;

//----------------------------------------- ----------------------------------
function ImpEpsonTMU220AF.ReImpCupomNaoFiscal( Texto:String ):String;
Begin
   Result := '0|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'ReImpCupomNaoFiscal: ' + Result ) );
End;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.AbreNota(Cliente:String):String;

  function TipoCli( sTipo: String):String;
  begin
    if sTipo = 'I' then Result := 'I';
    if sTipo = 'N' then Result := 'R';
    if sTipo = 'E' then Result := 'E';
    if sTipo = 'M' then Result := 'M';
    if sTipo = 'C' then Result := 'F';
    if sTipo = 'A' then Result := 'S';
  end;

Var
   sTipo: String;
   aAuxiliar : TaString;
   sTipoCli : String;
   sTipoDoc : String;
   sLeyDom : String;
   sLeyRem : String;
Begin
   sTipo:='T';
   // Monta um array auxiliar com as formas solicitadas
   MontaArray( Cliente,aAuxiliar );
   //-----------------------------------------------------
   // aAuxiliar[0] => Serie A o B
   // aAuxiliar[1] => Razón Social
   // aAuxiliar[2] => CUIT
   // aAuxiliar[3] => TIPO    => E Exento
   //                         => C Consumidor Final
   //                         => A No Responsable
   //                         => I Responsable Inscripto
   //                         => M Monotributo
   // aAuxiliar[4] => TIPO ID => C CUIT
   //                         => 2 DNI
   // aAuxiliar[5] => Vendedor
   // aAuxiliar[6] => Condicion de Pago
   //-----------------------------------------------------

   if ( Length(aAuxiliar)=7 ) then
      Begin
      sTipoCli := TipoCli( aAuxiliar[3] );
      if sTipoCli <> 'F' then sTipoDoc := 'CUIT' else sTipoDoc := ' ';
      sLeyDom  := 'Domicilio Desconocido';
      sLeyRem  := 'Sin Remitos Asociados';

      EPS_AddDataField( #96 );             // Abrir TF / TNC
      EPS_AddDataField( 'T' );             // 01 T para Ticket Factura
      EPS_AddDataField( 'C' );             // 02 IGNORADO
      EPS_AddDataField( aAuxiliar[0] );    // 03 A o B
      EPS_AddDataField( '1' );             // 04 IGNORADO
      EPS_AddDataField( 'F' );             // 05 IGNORADO
      EPS_AddDataField( '12' );            // 06 IGNORADO
      EPS_AddDataField( 'I' );             // 07 IVA del EMISOR
      EPS_AddDataField( sTipoCli );        // 08 IVA del COMPRADOR
      EPS_AddDataField( aAuxiliar[1] );    // 09 Nombre 1ra Linea
      EPS_AddDataField( ' ' );             // 10 Nombre 2da Linea
      EPS_AddDataField( sTipoDoc );        // 11 Tipo de Documento
      EPS_AddDataField( aAuxiliar[2] );    // 12 Nro de Documento
      EPS_AddDataField( 'N' );             // 13 Leyenda Bien de Uso
      EPS_AddDataField( sLeyDom );         // 14 Domicilio 1ra Linea
      EPS_AddDataField( ' ' );             // 15 Domicilio 2da Linea
      EPS_AddDataField( ' ' );             // 16 Domicilio 3ra Linea
      EPS_AddDataField( sLeyRem );         // 17 Remitos 1ra Linea
      EPS_AddDataField( ' ' );             // 18 Remitos 2da Linea
      EPS_AddDataField( 'C' );             // 19 Para Farmacias
      EPS_SendCommand();
      Result := EpsonError(TRUE);
      end
   else
      Result:='1|';

   If LogDll then
      EpsonLog( 'epson.log', PChar( 'AbreNota: ' + Result ) );

End;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.RelatorioGerencial( Texto:String;Vias:Integer; ImgQrCode: String):String;
var
  i       :Integer;
  sRet    :String;
  sTexto  :String;
  sLinha  :String;
begin
  Result := '1|';

  //verifica a quantidade de vias
  if Vias > 1 then
  Begin
    sTexto := Texto;
    i:=1;
    While i < Vias do
    Begin
        Texto:= Texto+ sTexto;
        Inc(i);
    End;
  End;

  // Abre o cupom não fiscal
  sRet := AbreCupomNaoFiscal('','', '', '');
  If Copy(sRet, 1, 1) <> '0' then
      Result := '1|';

  sRet := TextoNaoFiscal('***********Relatorio Gerencial***********', 1);
  sRet := TextoNaoFiscal(Space(40), 1);

  // Laço para imprimir toda a mensagem
  While ( Trim(Texto)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 40 caracter do Texto
         For i:= 1 to 40 do
         Begin
             // Caso encontre um CHR(10) (Line Feed) imprime a linha
             If Copy(Texto,i,1) = #10 then
                Break;
             sLinha := sLinha + Copy(Texto,i,1);
         end;
         sLinha := Copy(sLinha+space(40),1,40);
         Texto  := Copy(Texto,i+1,Length(Texto));
         
         //imprime texto nao fiscal
         sRet   := TextoNaoFiscal(sLinha, 1);
         // Ocorreu erro na impressão do cupom
         if Copy(sRet, 1, 1) <> '0' then
            Result := '1|';
      End;
  //fecha o cupom nao fiscal
  sRet := FechaCupomNaoFiscal();
  If Copy(sRet, 1, 1) <> '0'
  then Result := '1|'
  Else Result := '0|';

  If LogDll then
     EpsonLog( 'epson.log', PChar( 'RelatorioGerencial: ' + Result ) );

end;

//---------------------------------------------------------------------------
function ImpEpsonTMU220AF.HorarioVerao( Tipo:String ):String;
var
   sData     :String;
   sHora     :String;
   sAuxHora  :String;
begin
   DateTimeToString(sData,'yymmdd',Date);
   sHora := Copy( StatusImp(1), 3, 8);
   sHora := SubstituiStr(sHora, ':', '');

   If Tipo = '+' then
      sAuxHora := IntToStr( StrToInt( Copy(sHora, 1, 2) ) + 1 ) + Copy(sHora, 3, 4)
   Else
      sAuxHora := IntToStr( StrToInt( Copy(sHora, 1, 2) ) - 1 ) + Copy(sHora, 3, 4) ;

   If LogDll then
      EpsonLog( 'epson.log', PChar( 'HorarioVerao: ' + sData + '|' + sAuxHora) );

   EPS_AddDataField( #88 );      // Establecer Fecha y Hora
   EPS_AddDataField( sData );    // Fecha
   EPS_AddDataField( sAuxHora ); // Hora
   EPS_SendCommand();
 
   Result := EpsonError(FALSE);

   If LogDll then
      EpsonLog( 'epson.log', PChar( 'HorarioVerao: ' + Result ) );

end;

//---------------------------------------------------------------------------
function ImpEpsonTM300AF.PegaCupom(Cancelamento:String):String;
var
   sStatus, sTipo, sSerie, sDoc : String;
   iStatus:Integer;
begin
   iStatus := EPS_FiscalStatus();
   if iStatus < 0 then iStatus := iStatus * -1 ;
   sStatus := IntToHex( iStatus, 4 );
   sStatus := HexToBin( sStatus );

   // Documento Fiscal abierto o
   // Documento No Fiscal abierto que se emite por el rollo de papel
   if ( Copy( sStatus, 4, 1 ) = '1' ) or ( Copy( sStatus, 3, 1 ) = '1' ) then
      begin
      EPS_AddDataField( #42 );         // Solicitud de Estado
      EPS_AddDataField( 'D' );         // Información sobre el Documento en Curso
      EPS_SendCommand();

      sTipo := EPS_GetExtraField(1);
      // ‘T’ Tique.
      // ‘I’ Tique-Factura.
      // ‘F’ Factura.
      // ‘O’ Documento No Fiscal.
      // ‘H’ Documento No Fiscal Homologado.

      sSerie := EPS_GetExtraField(2);
      // ‘N’ No tiene una letra que identifique al documento.
      // ‘A’ Documento emitido con letra A.
      // ‘B’ Documento emitido con letra B.
      // ‘C’ Documento emitido con letra C.

      EPS_AddDataField( #42 );         // Solicitud de Estado
      EPS_AddDataField( 'A' );
      EPS_SendCommand();

      if      ( sTipo = 'I' ) and ( sSerie = 'A' ) then sDoc := EPS_GetExtraField(5)
      else if ( sTipo = 'I' ) and (( sSerie = 'B' ) or ( sSerie = 'C' )) then sDoc := EPS_GetExtraField(3)
      else if ( sTipo = 'O' ) then sDoc := EPS_GetExtraField(6)
      else sDoc := Space(12);

      result := '0|' + sDoc;
      end
   else
      begin
      EPS_AddDataField( #42 );      // Solicitud de Estado
      EPS_AddDataField( 'A' );      // Información sobre los Numeradores
      EPS_SendCommand();

      sDoc := EPS_GetExtraField(3); // Número del último Tique impreso o Factura B,C o Tique-Factura B,C

      result := '0|' + sDoc;
      //result := '1|';
      end;

   if Trim(sDoc) = '' then
      result := '1|';

   if LogDll then
      EpsonLog( 'epson.log', PChar( 'PegaCupom: ' + result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTM300AF.AbreCupom(Cliente:String; MensagemRodape:String):String;

  function TipoCli( sTipo: String):String;
  begin
    if sTipo = 'I' then Result := 'I';
    if sTipo = 'N' then Result := 'R';
    if sTipo = 'E' then Result := 'E';
    if sTipo = 'M' then Result := 'M';
    if sTipo = 'C' then Result := 'F';
    if sTipo = 'A' then Result := 'S';
  end;

Var
   sTipo: String;
   aAuxiliar : TaString;
   sTipoCli : String;
   sTipoDoc : String;
   sLeyDom : String;
   sLeyRem : String;
Begin
   sTipo:='T';

   // if Copy( StatusImp(5), 1, 1 ) = '1' then CancelaCupom('SUPERVISOR');

   // Monta um array auxiliar com as formas solicitadas
   MontaArray( Cliente,aAuxiliar );
   //-----------------------------------------------------
   // aAuxiliar[0] => Serie A o B
   // aAuxiliar[1] => Razón Social
   // aAuxiliar[2] => CUIT
   // aAuxiliar[3] => TIPO    => E Exento
   //                         => C Consumidor Final
   //                         => A No Responsable
   //                         => I Responsable Inscripto
   //                         => M Monotributo
   // aAuxiliar[4] => TIPO ID => C CUIT
   //                         => 2 DNI
   // aAuxiliar[5] => Vendedor
   // aAuxiliar[6] => Condicion de Pago
   // aAuxiliar[7] => Indica se sera impressora ticket ----OBS. nao usado para essa epson ela soh imprime cupom
   //-----------------------------------------------------
   if ( Length(aAuxiliar)>6 ) then
      Begin
      sTipoCli := TipoCli( aAuxiliar[3] );
      if sTipoCli <> 'F' then sTipoDoc := 'CUIT' else sTipoDoc := ' ';
      sLeyDom  := 'Domicilio Desconocido';
      sLeyRem  := ' ';

      EPS_AddDataField( #96 );             // Abrir TF / TNC
      EPS_AddDataField( 'T' );             // 01 T para Ticket Factura
      EPS_AddDataField( 'C' );             // 02 IGNORADO
      EPS_AddDataField( aAuxiliar[0] );    // 03 A o B
      EPS_AddDataField( '2' );             // 04 IGNORADO Cantidad de Copias
      EPS_AddDataField( 'F' );             // 05 IGNORADO
      EPS_AddDataField( '12' );            // 06 IGNORADO
      EPS_AddDataField( 'I' );             // 07 IVA del EMISOR
      EPS_AddDataField( sTipoCli );        // 08 IVA del COMPRADOR
      EPS_AddDataField( aAuxiliar[1] );    // 09 Nombre 1ra Linea
      EPS_AddDataField( ' ' );             // 10 Nombre 2da Linea
      EPS_AddDataField( sTipoDoc );        // 11 Tipo de Documento
      EPS_AddDataField( aAuxiliar[2] );    // 12 Nro de Documento
      EPS_AddDataField( 'N' );             // 13 Leyenda Bien de Uso
      EPS_AddDataField( sLeyDom );         // 14 Domicilio 1ra Linea
      EPS_AddDataField( aAuxiliar[5] );    // 15 Domicilio 2da Linea
      EPS_AddDataField( aAuxiliar[6] );    // 16 Domicilio 3ra Linea
      EPS_AddDataField( sLeyRem );         // 17 Remitos 1ra Linea
      EPS_AddDataField( ' ' );             // 18 Remitos 2da Linea
      EPS_AddDataField( 'C' );             // 19 Para Farmacias
      EPS_SendCommand();
      Result := EpsonError(TRUE);
      end
   else
      Result:='1|';

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'AbreCupom: ' + Result ) );

End;

//------------------------------------------------------------------------------
function ImpEpsonTM300AF.RegistraItem(codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String;
Var
  sSerie    : String;
  slinDesc1 : String;
  slinDesc2 : String;
  slinDesc3 : String;
  sRet      : String;
  bDesconto : Boolean;
begin
  sRet   := '0|';
  bDesconto := False;
  sSerie := PegaSerie;
  sSerie := Copy( sSerie, 3, 1 );
  aliquota := Copy(aliquota, 1, 5);
  if Copy(aliquota, Length(aliquota), Length(aliquota))='|' then
     aliquota := Copy(aliquota, 1, Length(aliquota)-1);

  if Trim(vlrdesconto) <> '0.00' then
     begin
        bDesconto   := True;
        vlrdesconto := Trim(vlrdesconto);
        if sSerie = 'B' then
            vlrdesconto :=  FloatToStrF( StrToFloat( vlrdesconto ) * ( 1 + ( StrToFloat( aliquota ) / 100 ) ),
                                 ffGeneral, 9, 4 );
     end;

  if sRet = '0|' then
     begin

     if sSerie = 'B' then
        vlrUnit :=  FloatToStrF( StrToFloat( vlrUnit ) * ( 1 + ( StrToFloat( aliquota ) / 100 ) ),
                                 ffGeneral, 9, 4 );

     //Descricao do item com 3 linhas
     if multiLine then
     begin
         slinDesc1 :=  Copy(descricao + space(26), 01, 26);
         slinDesc2 :=  Trim( Copy(descricao + space(52), 27, 26) );
         slinDesc3 :=  Trim( Copy(descricao + space(78), 53, 26) );
     end
     else
     begin
         slinDesc1 :=  Copy(descricao + space(26), 01, 26);
         slinDesc2 :=  '';
         slinDesc3 :=  '';
     end;

     if ( sSerie <> 'A' ) and ( sSerie <> 'B' ) then
        Result := '1|'
     else
       begin

       EPS_AddDataField( #98 );
       EPS_AddDataField( Copy( codigo + Space(18), 1, 18 ) );
       EPS_AddDataField( Trim( FormataTexto( qtde, 8, 3, 4 ) ) );
       EPS_AddDataField( Trim( FormataTexto( vlrUnit, 9, 2, 2 ) ) );
       EPS_AddDataField( FormataTexto( aliquota , 4, 2, 2 ) );
       EPS_AddDataField( 'M' );
       EPS_AddDataField( '00000' );
       EPS_AddDataField( '00000000' );
       EPS_AddDataField( slinDesc1 );
       EPS_AddDataField( slinDesc2 );
       EPS_AddDataField( slinDesc3 );
       EPS_AddDataField( FormataTexto( '0', 4, 2, 2 ) );
       EPS_AddDataField( '000000000000000' );
       EPS_SendCommand();
       sRet := EpsonError(TRUE);

       if ( sRet = '0|' ) and ( bDesconto ) then
          begin
          EPS_AddDataField( #98 );
          EPS_AddDataField( Copy( codigo + Space(18), 1, 18 ) );
          EPS_AddDataField( Trim( FormataTexto( '1.000', 8, 3, 4 ) ) );
          EPS_AddDataField( FormataTexto( vlrdesconto, 9, 2, 2 ) );
          EPS_AddDataField( FormataTexto( aliquota , 4, 2, 2 ) );
          EPS_AddDataField( 'R') ;
          EPS_AddDataField( '00000' );
          EPS_AddDataField( '00000000' );
          EPS_AddDataField( slinDesc1 );
          EPS_AddDataField( slinDesc2 );
          EPS_AddDataField( slinDesc3 );
          EPS_AddDataField( FormataTexto( '0', 4, 2, 2 ) );
          EPS_AddDataField( '000000000000000' );
          EPS_SendCommand();
          sRet := EpsonError(TRUE)
          end;

       end;
     end;

     Result := sRet;

     if LogDll then
         EpsonLog( 'epson.log', PChar( 'RegistraItem: ' + Result ) );

end;

//------------------------------------------------------------------------------
function ImpEpsonTM300AF.FechaCupom( Mensagem:String ):String;
var sSerie :String;
begin
   EPS_AddDataField( #42 );         // Solicitud de Estado
   EPS_AddDataField( 'D' );         // Información sobre el documento que se esta emitiendo.
   EPS_SendCommand();
   sSerie := EPS_GetExtraField(2);  // Serie

   EPS_AddDataField( #101 );        // Cerrar Comprobante Fiscal Tique.
   EPS_AddDataField( 'T' );         // ‘F’= Factura Fiscal
                                    // ‘T’= Tique-Factura Fiscal
                                    // ‘R’= Si Estoy Abriendo un Recibo-Factura
   EPS_AddDataField( sSerie );      // Serie
   EPS_AddDataField( ' ' );

   EPS_SendCommand();
   Result := EpsonError(TRUE);

  if LogDll then
     EpsonLog( 'epson.log', PChar( 'FechaCupom: ' + Result ) );

end;

//----------------------------------------------------------------------------
function EpsonError(  bShow: Boolean  ):String;
var
  sErrP, sErrF : String;
  iErrP, iErrF : Integer;
begin
   iErrP := EPS_PrinterStatus();
   if iErrP < 0 then iErrP := iErrP * -1;
   sErrP := IntToHex( iErrP , 4 );
   sErrP := EpsonErrorMsg( sErrP, 'P' );
   if sErrP = '' then
      begin
      iErrF := EPS_FiscalStatus();
      if iErrF < 0 then iErrF := iErrF * -1;
      sErrF := IntToHex( iErrF , 4 );
      sErrF := EpsonErrorMsg( sErrF, 'F' );
      if sErrF = '' then
         Result := '0|'
      else
         begin
         if bShow then ShowMessage( sErrF );
         Result := '1|' + sErrF
         end
      end
   else
      begin
      if bShow then ShowMessage( sErrP );
      Result := '1|Error Impresora|' + sErrP
      end;

end;

//----------------------------------------------------------------------------
function EpsonErrorMsg( sError, sTipo:String ): String;
var
  sMsg:string;
  sBin:string;
  iError: Integer;
Begin
  sMsg:='';
  if sTipo='I' then
     Begin
     iError:=StrToInt(sError);
     case iError of
       -1  : sMsg :='Error General.';
       -2  : sMsg :='Handler Inválido.';
       -3  : sMsg :='Intento de Enviar un Comando Cuando se Estaba Processando.';
       -4  : sMsg :='Error de Comunicaciones.';
       -5  : sMsg :='Puerto ya Abierto.';
       -6  : sMsg :='No Hay Memoria.';
       -7  : sMsg :='El Puerto ya Estaba Abierto.';
       -8  : sMsg :='La Dirección Del Buffer de Respuesta es Inválida.';
       -9  : sMsg :='El Comando no Finalizó, Sino que Volvió una Respuesta Tipo STAT_PRN.';
       -10 : sMsg :='El Proceso en Curso Fue Abortado Por El Usuario.';
     end;
     end
   Else if sTipo='P' then
      begin
      sBin := HexToBin( sError );
      If Copy( sBin, 14, 1 ) = '1' Then  // Bit 2 - 1 = Error y/o falla de impresora.
         sMsg:=sMsg+'Error y/o falla de impresora'#13#10;
      If Copy( sBin, 13, 1 ) = '1' Then  // Bit 3 - 1 = Impresora fuera de línea.
         sMsg:=sMsg+'Impresora fuera de línea'#13#10;
      If Copy( sBin, 10, 1 ) = '1' Then  // Bit 6 - 1 = Búfer de impresora lleno.
         sMsg:=sMsg+'Búfer de impresora lleno'#13#10;
      If Copy( sBin, 02, 1 ) = '1' Then  // Bit 14- 1 = Impresora sin Papel para imprimir.
         sMsg:=sMsg+'Impresora sin Papel para imprimir'#13#10;
      end
   Else if sTipo='F' then
      begin
      sBin := HexToBin( sError );
      If Copy( sBin, 16, 1 ) = '1' Then  // Bit 0 - 1 = Error de comprobación de Memoria Fiscal.
         sMsg:=sMsg+'Error de comprobación de Memoria Fiscal'#13#10;
      If Copy( sBin, 15, 1 ) = '1' Then  // Bit 1 - 1 = Error de comprobación de Memoria de Trabajo.
         sMsg:=sMsg+'Error de comprobación de Memoria de Trabajo'#13#10;
      If Copy( sBin, 14, 1 ) = '1' Then  // Bit 2 - 1 = Poca batería.
         sMsg:=sMsg+'Poca batería'#13#10;
      If Copy( sBin, 13, 1 ) = '1' Then  // Bit 3 - 1 = Comando no reconocido..
         sMsg:=sMsg+'Comando no reconocido'#13#10;
      If Copy( sBin, 12, 1 ) = '1' Then  // Bit 4 - 1 = Campo de datos Inválido.
         sMsg:=sMsg+'Campo de datos Inválido'#13#10;
      If Copy( sBin, 11, 1 ) = '1' Then  // Bit 5 - 1 = Comando no válido para estado fiscal.
         sMsg:=sMsg+'Comando no válido para estado fiscal'#13#10;
      If Copy( sBin, 10, 1 ) = '1' Then  // Bit 6 - 1 = Desbordamiento de Totales.
         sMsg:=sMsg+'Desbordamiento de Totales'#13#10;
      If Copy( sBin, 9, 1 ) = '1'  Then  // Bit 7 - 1 = Memoria Fiscal llena.
         sMsg:=sMsg+'Memoria Fiscal llena'#13#10;
      If Copy( sBin, 5, 1 ) = '1'  Then  // Bit 11 - 1 = Es necesario hacer un cierre de la Jornada Fiscal
         sMsg:=sMsg+'Es necesario hacer un cierre de la Jornada Fiscal'#13#10;
      end;
   Result:=sMsg;
end;

//------------------------------------------------------------------------------
procedure EpsonLog ( Arquivo,Texto:String );
var
  pFile,pBuffer : PChar;
  hFile : Int64;
  nTam, nWritten : LongWord;
  sData : String;
begin
  sData := DateTimeToStr( Now() );
  pFile := StrAlloc(Length(Arquivo)+ 1);
  StrPCopy(pFile, Arquivo );
  hFile := CreateFile( pFile,
                       GENERIC_WRITE+GENERIC_READ,
                       0,                                     // Exclusive
                       Nil,
                       OPEN_ALWAYS,
                       FILE_FLAG_WRITE_THROUGH,
                       0 );
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    nTam := Length( sData ) + Length(Texto) + 3;
    pBuffer := PChar( sData + '-' + Texto + #13 + #10 );
    SetFilePointer( hFile,
                    0,
                    Nil,
                    FILE_END );
    WriteFile( hFile,
               pBuffer^,
               nTam,
               nWritten,
               Nil);
    SetEndOfFile( hFile );
    FlushFileBuffers( hFile );
    CloseHandle( hFile );
  end;
  StrDispose(pFile);
end;

//------------------------------------------------------------------------------
Function TrataTags( Mensagem : String ) : String;
var
  cMsg : String;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;                                                                            


//------------------------------------------------------------------------------
function ImpEpsonTMH6000II.RelGerInd(cIndTotalizador, Texto: String;
  nVias: Integer; ImgQrCode: String): String;
begin
Result := RelatorioGerencial(Texto,nVias,ImgQrCode);
end;

function ImpEpsonTMH6000II.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

//-----------------------------------------------------------------------------\\
//-----------------------------------------------------------------------------\\
//-----------------------------------------------------------------------------\\

{ ImpEpsonT900FA }

function ImpEpsonT900FA.AbreCupom(Cliente, MensagemRodape: String): String;
Var
 sTipo : String;
 aAuxiliar : TaString;
 iX, iRet, iTpDoc, iTpIVA, iTpComp  : Integer;
begin
   Result := '0';
   GravaLog('AbreCupom - Cliente [' + Cliente + ']');
   Cliente := StrTran(Cliente,'&_',',');
   GravaLog('AbreCupom - Cliente - Tratado [' + Cliente + ']');

   sTipo:='T';

   // Monta um array auxiliar com as formas solicitadas
   MontaArray( Cliente,aAuxiliar );
   GravaLog(' AbreCupom -  Tamanho de Auxiliar :' + IntToStr(Length(aAuxiliar)));

   For iX := 0 to Pred(Length(aAuxiliar)) do
   begin
     If aAuxiliar[iX] = ''
     then aAuxiliar[iX] := Space(2); //Não pode enviar informação em branco no comando da impressora
     GravaLog('AbreCupom - Indice [' + IntToStr(iX) + '] + aAuxiliar [ ' + aAuxiliar[iX] + ']');
   end;

   GravaLog(' AbreCupom -  Passou do For');

   //-----------------------------------------------------
   // aAuxiliar[0] => Serie A o B
   // aAuxiliar[1] => Razón Social
   // aAuxiliar[2] => CUIT
   // aAuxiliar[3] => TIPO    => E Exento
   //                         => C Consumidor Final
   //                         => A No Responsable
   //                         => I Responsable Inscripto
   //                         => M Monotributo
   // aAuxiliar[4] => TIPO ID => C CUIT
   //                         => 2 DNI
   // aAuxiliar[5] => Vendedor
   // aAuxiliar[6] => Condicion de Pago
   // aAuxiliar[7] => Indica se sera impressora ticket ----OBS. nao usado para essa epson ela soh imprime cupom
   // aAuxiliar[8] => Domicilio 1ra Linea
   // aAuxiliar[9] => Domicilio 2ra Linea
   // aAuxiliar[10] => Domicilio 3ra Linea
   //-----------------------------------------------------

   {
   ID_TIPO_DOCUMENTO - Conforme manual do fabricante:
   0 - Ningun documento.
   1 - D.N.I.
   2 - C.U.I.L.
   3 - C.U.I.T.
   4 - Cedula de identidad.
   5 - Pasaporte.
   6 - Libreta civica.
   7 - Libreta de enrolamiento.
   }
   iTpDoc := 0;

   If aAuxiliar[4] = 'C'
   then iTpDoc := 3;

   If aAuxiliar[4] = '2'
   then iTpDoc := 1;

   If (Trim(aAuxiliar[2]) = '')
   then iTpDoc := 0;

   {
   ID_RESPONSABILIDAD_IVA - Conforme manual do fabricante:
   0 - Ninguno.
   1 - I.V.A responsable inscripto.
   3 - I.V.A no responsable.
   4 - I.V.A monotributista.
   5 - I.V.A consumidor final.
   6 - I.V.A exento.
   7 - I.V.A no categorizado.
   8 - I.V.A monotributista social.
   9 - I.V.A monotributista eventual.
   10 - I.V.A monotributista eventual social.
   11 - I.V.A monotributo independiente promovido
   }
   iTpIVA := 0;
   If aAuxiliar[3] = 'S'
   then iTpIVA := 0;

   If aAuxiliar[3] = 'I'
   then iTpIVA := 1;

   If aAuxiliar[3] = 'A'
   then iTpIVA := 3;

   If aAuxiliar[3] = 'M'
   then iTpIVA := 4;

   If aAuxiliar[3] = 'C'
   then iTpIVA := 5;

   If aAuxiliar[3] = 'E'
   then iTpIVA := 6;

   {
   Conforme manual do fabricante
   1 - Tique.
   2 - Tique factura A/B/C/M
   3 - Tique nota de credito
   4 - Tique nota de debito
   21- Documento no fiscal homologado generico
   22- Documento no fiscal homologado de uso interno
   }
   If (aAuxiliar[0] = 'A') OR (aAuxiliar[0] = 'B')
   then iTpComp := 2
   else iTpComp := 1;

   GravaLog(' EP9FA_CargarDatosCliente ->');
   iRet := EP9FA_CargarDatosCliente(aAuxiliar[1],Space(1),aAuxiliar[8],aAuxiliar[9],aAuxiliar[10],iTpDoc,aAuxiliar[2],iTpIVA);
   GravaLog(' EP9FA_CargarDatosCliente <- iRet [ ' + IntToStr(iRet) + ']');

   iRet := TM900FACodError(iRet);

   If iRet = EP9FA_TagSucesso then
   begin
     GravaLog(' EP9FA_AbrirComprobante ->');
     iRet := EP9FA_AbrirComprobante(iTpComp);
     GravaLog(' EP9FA_AbrirComprobante <- iRet [ ' + IntToStr(iRet) + ']');

     iRet := TM900FACodError(iRet);
   end;

   If iRet = EP9FA_TagSucesso then
   begin
     GravaLog(' Cupom Fiscal Aberto com Sucesso ');
   end
   else
   begin
     GravaLog(' Error ao abrir comprovante fiscal ');
     CancelaCupom('');
     Result := '1|';
   end;
end;

function ImpEpsonT900FA.AbreCupomNaoFiscal(Condicao, Valor, Totalizador,
  Texto: String): String;
var
  iRet : Integer;
begin
GravaLog(' EP9FA_AbrirComprobante -> Indice 21 - Documento no fiscal homologado generico');
iRet := EP9FA_AbrirComprobante(21);
GravaLog(' EP9FA_AbrirComprobante <- iRet [ ' + IntToStr(iRet) + ']');

If TM900FACodError(iRet) = EP9FA_TagSucesso
then Result := '0'
else Result := '1'
end;

function ImpEpsonT900FA.AbreDNFH(sTipoFat, sDadosCli, sDadosCab, sDocOri,
  sTipoImp, sIdDoc: String): String;

  function TipoCli( sTipo: String):String;
  begin
    if sTipo = 'I' then Result := 'I';
    if sTipo = 'N' then Result := 'R';
    if sTipo = 'E' then Result := 'E';
    if sTipo = 'M' then Result := 'M';
    if sTipo = 'C' then Result := 'F';
  end;
  
var
  iRet,iTpDoc : Integer;
  aCliente : TaString;
  sNumDoc,sNumCup,sTipoCli : String;
begin

GravaLog(' AbreDNFH - Inicio da função ');

//dados do cliente
MontaArray( sDadosCli, aCliente );

For iRet := 0 to Pred(Length(aCliente)) do
begin
  If aCliente[iRet] = ''
  then aCliente[iRet] := Space(1);

  GravaLog('AbreDNFH - Indice [' + IntToStr(iRet) + '] + aAuxiliar [ ' + aCliente[iRet] + ']');
end;

//tipo do cliente
sTipoCli := TipoCli( aCliente[2] );
if sTipoCli <> 'F'
then iTpDoc := 3  //'CUIT'
else iTpDoc := 0; //''

//tipo de documento de identificacao
If iTpDoc = 0
then sNumDoc := ''
else sNumDoc := aCliente[1];

GravaLog(' EP9FA_CargarDatosCliente ->');
iRet := EP9FA_CargarDatosCliente(aCliente[0],Space(1),Copy(aCliente[4],1,40),
                                 Copy(aCliente[4],41,40),Copy(aCliente[4],81,40),
                                 iTpDoc,sNumDoc,5);
GravaLog(' EP9FA_CargarDatosCliente <- iRet [ ' + IntToStr(iRet) + ']');

If TM900FACodError(iRet) = EP9FA_TagSucesso then
begin
  GravaLog(' EP9FA_AbrirComprobante -> Indice 3 - Tique nota de crédito - tique nota crédito A/B/C/M.');
  iRet := EP9FA_AbrirComprobante(3);
  GravaLog(' EP9FA_AbrirComprobante <- iRet [ ' + IntToStr(iRet) + ']');
end;

If TM900FACodError(iRet) = EP9FA_TagSucesso then
begin
  sNumCup := PegaCupom('');
  If Copy(sNumCup,1,1) = '0' then
  begin
    sNumCup := '| |' + Copy(sNumCup, 3, Length(sNumCup));
    Result  := '0' + sNumCup;
  end
  else
  begin
    GravaLog(' Erro ao capturar informação do numero de cupom porem'
                + ' comando de abertura de Tique NC executado com sucesso ');
    Result := '0';
  end;
end
else
begin
  GravaLog('Erro ao executar os comandos');
  Result := '1';
end;

GravaLog(' AbreDNFH - Retorno da função - Result : ' + Result);

end;

function ImpEpsonT900FA.AbreECF: String;
var
  iRet : Integer;
begin
  Result := '0';
  GravaLog(' EP9FA_Conectar -> ');
  iRet := EP9FA_Conectar();
  GravaLog(' EP9FA_Conectar <- iRet [' + IntToStr(iRet) + ']');

  If TM900FACodError(iRet) <> EP9FA_TagSucesso
  then Result := '1|';
end;

function ImpEpsonT900FA.AbreNota(Cliente: String): String;
  function TipoCli( sTipo: String):String;
  begin
    if sTipo = 'I' then Result := 'I';
    if sTipo = 'N' then Result := 'R';
    if sTipo = 'E' then Result := 'E';
    if sTipo = 'M' then Result := 'M';
    if sTipo = 'C' then Result := 'F';
    if sTipo = 'A' then Result := 'S';
  end;
var
  aAuxiliar : TaString;
  iTpDoc,iRet  : Integer;
  sLeyDom,sLeyRem,sNumDoc,sTipoCli: String;
begin
   // Monta um array auxiliar com as formas solicitadas
   //-----------------------------------------------------
   // aAuxiliar[0] => Serie A o B
   // aAuxiliar[1] => Razón Social
   // aAuxiliar[2] => CUIT
   // aAuxiliar[3] => TIPO    => E Exento
   //                         => C Consumidor Final
   //                         => A No Responsable
   //                         => I Responsable Inscripto
   //                         => M Monotributo
   // aAuxiliar[4] => TIPO ID => C CUIT
   //                         => 2 DNI
   // aAuxiliar[5] => Vendedor
   // aAuxiliar[6] => Condicion de Pago
   //------------------------------------------------------
   MontaArray( Cliente,aAuxiliar );

   If Length(aAuxiliar) = 7 then
   begin
     sLeyDom  := 'Domicilio Desconocido';
     sLeyRem  := 'Sin Remitos Asociados';

     sTipoCli := TipoCli( aAuxiliar[3] );
     if sTipoCli <> 'F'
     then iTpDoc := 3  //'CUIT'
     else iTpDoc := 0; //''

     //tipo de documento de identificacao
     If iTpDoc = 0
     then sNumDoc := Space(1) //Não pode enviar em branco
     else sNumDoc := aAuxiliar[2];

     GravaLog(' EP9FA_CargarDatosCliente ->');
     iRet := EP9FA_CargarDatosCliente(aAuxiliar[1],Space(1),sLeyDom,Space(1),Space(1),iTpDoc,sNumDoc,5);
     GravaLog(' EP9FA_CargarDatosCliente <- iRet [ ' + IntToStr(iRet) + ']');

     If TM900FACodError(iRet) = EP9FA_TagSucesso then
     begin
       GravaLog(' EP9FA_AbrirComprobante -> Indice 3 - Tique nota de crédito - tique nota crédito A/B/C/M.');
       iRet := EP9FA_AbrirComprobante(2);
       GravaLog(' EP9FA_AbrirComprobante <- iRet [ ' + IntToStr(iRet) + ']');
       iRet := TM900FACodError(iRet);
     end;

     If iRet = EP9FA_TagSucesso
     then Result := '0'
     else begin
            GravaLog('Erro ao executar os comandos');
            Result := '1';
         end;
   end
   else
   begin
     GravaLog('Quantidade de parâmetros enviados são insuficientes - Esperado (7)');
     Result := '1';
   end;

   GravaLog(' AbreNota - Result :' + Result);
end;

function ImpEpsonT900FA.Abrir(sPorta: String; iHdlMain: Integer): String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
      if not Assigned(aPointer) Then
      begin
         LjMsgDlg('La Funcion "'+sMsg+'" no existe en la Dll: EpsonFiscalInterface.dll');
         Result := False
      end
      else
         Result := True;
  end;

var
    fHandle : THandle;
    aFunc   : Pointer;
    bRet    : Boolean;
    iRet    : Integer;
    sVelPorta: String;
begin
   GravaLog(' Inicio da função Abrir - ImpEpsonT900FA ');
   bRet := True;

   fHandle := LoadLibrary('EpsonFiscalInterface.dll');
   If fHandle <> 0 then
   begin
     GravaLog(' ImpEpsonT900FA - DLL Encontrada e carregada com sucesso ');

     aFunc := GetProcAddress(fHandle,'EnviarComando');
     If ValidPointer(aFunc,'EnviarComando')
     then EP9FA_EnviarComando := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando EnviarComando');

     aFunc := GetProcAddress(fHandle,'ObtenerRespuestaExtendida');
     If ValidPointer(aFunc,'ObtenerRespuestaExtendida')
     then EP9FA_ObtenerRespuestaExtendida := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ObtenerRespuestaExtendida');

     aFunc := GetProcAddress(fHandle,'Cancelar');
     If ValidPointer(aFunc,'Cancelar')
     then EP9FA_Cancelar := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando Cancelar');

     aFunc := GetProcAddress(fHandle,'ConsultarVersionDll');
     If ValidPointer(aFunc,'ConsultarVersionDll')
     then EP9FA_ConsultarVersionDll := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarVersionDll');

     aFunc := GetProcAddress(fHandle,'ConsultarVersionEquipo');
     If ValidPointer(aFunc,'ConsultarVersionEquipo')
     then EP9FA_ConsultarVersionEquipo := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarVersionEquipo');

     aFunc := GetProcAddress(fHandle,'ConsultarFechaHora');
     If ValidPointer(aFunc,'ConsultarFechaHora')
     then EP9FA_ConsultarFechaHora := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarFechaHora');

     aFunc := GetProcAddress(fHandle,'ConsultarDescripcionDeError');
     If ValidPointer(aFunc,'ConsultarDescripcionDeError')
     then EP9FA_ConsultarDescripcionDeError := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarDescripcionDeError');

     aFunc := GetProcAddress(fHandle,'ConsultarEstado');
     If ValidPointer(aFunc,'ConsultarEstado')
     then EP9FA_ConsultarEstado := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarEstado');

     aFunc := GetProcAddress(fHandle,'ConsultarNumeroPuntoDeVenta');
     If ValidPointer(aFunc,'ConsultarNumeroPuntoDeVenta')
     then EP9FA_ConsultarNumeroPuntoDeVenta := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarNumeroPuntoDeVenta');

     aFunc := GetProcAddress(fHandle,'ConsultarNumeroComprobanteUltimo');
     If ValidPointer(aFunc,'ConsultarNumeroComprobanteUltimo')
     then EP9FA_ConsultarNumeroComprobanteUltimo := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarNumeroComprobanteUltimo');

     aFunc := GetProcAddress(fHandle,'ConsultarNumeroComprobanteActual');
     If ValidPointer(aFunc,'ConsultarNumeroComprobanteActual')
     then EP9FA_ConsultarNumeroComprobanteActual := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarNumeroComprobanteActual');

     aFunc := GetProcAddress(fHandle,'ConsultarTipoComprobanteActual');
     If ValidPointer(aFunc,'ConsultarTipoComprobanteActual')
     then EP9FA_ConsultarTipoComprobanteActual := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarTipoComprobanteActual');

     aFunc := GetProcAddress(fHandle,'CargarDatosCliente');
     If ValidPointer(aFunc,'CargarDatosCliente')
     then EP9FA_CargarDatosCliente := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando CargarDatosCliente');

     aFunc := GetProcAddress(fHandle,'CargarComprobanteAsociado');
     If ValidPointer(aFunc,'CargarComprobanteAsociado')
     then EP9FA_CargarComprobanteAsociado := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando CargarComprobanteAsociado');

     aFunc := GetProcAddress(fHandle,'AbrirComprobante');
     If ValidPointer(aFunc,'AbrirComprobante')
     then EP9FA_AbrirComprobante := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando AbrirComprobante');

     aFunc := GetProcAddress(fHandle,'CargarTextoExtra');
     If ValidPointer(aFunc,'CargarTextoExtra')
     then EP9FA_CargarTextoExtra := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando CargarTextoExtra');

     aFunc := GetProcAddress(fHandle,'ImprimirItem');
     If ValidPointer(aFunc,'ImprimirItem')
     then EP9FA_ImprimirItem := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ImprimirItem');

     aFunc := GetProcAddress(fHandle,'ImprimirTextoLibre');
     If ValidPointer(aFunc,'ImprimirTextoLibre')
     then EP9FA_ImprimirTextoLibre := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ImprimirTextoLibre');

     aFunc := GetProcAddress(fHandle,'ImprimirSubtotal');
     If ValidPointer(aFunc,'ImprimirSubtotal')
     then EP9FA_ImprimirSubtotal := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ImprimirSubtotal');

     aFunc := GetProcAddress(fHandle,'CargarAjuste');
     If ValidPointer(aFunc,'CargarAjuste')
     then EP9FA_CargarAjuste := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando CargarAjuste');

     aFunc := GetProcAddress(fHandle,'CargarOtrosTributos');
     If ValidPointer(aFunc,'CargarOtrosTributos')
     then EP9FA_CargarOtrosTributos := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando CargarOtrosTributos');

     aFunc := GetProcAddress(fHandle,'CargarPago');
     If ValidPointer(aFunc,'CargarPago')
     then EP9FA_CargarPago := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando CargarPago');

     aFunc := GetProcAddress(fHandle,'CerrarComprobante');
     If ValidPointer(aFunc,'CerrarComprobante')
     then EP9FA_CerrarComprobante := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando CerrarComprobante');

     aFunc := GetProcAddress(fHandle,'CargarLogo');
     If ValidPointer(aFunc,'CargarLogo')
     then EP9FA_CargarLogo := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando CargarLogo');

     aFunc := GetProcAddress(fHandle,'EliminarLogo');
     If ValidPointer(aFunc,'EliminarLogo')
     then EP9FA_EliminarLogo := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando EliminarLogo');

     aFunc := GetProcAddress(fHandle,'ConfigurarVelocidad');
     If ValidPointer(aFunc,'ConfigurarVelocidad')
     then EP9FA_ConfigurarVelocidad := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConfigurarVelocidad');

     aFunc := GetProcAddress(fHandle,'ConfigurarPuerto');
     If ValidPointer(aFunc,'ConfigurarPuerto')
     then EP9FA_ConfigurarPuerto := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConfigurarPuerto');

     aFunc := GetProcAddress(fHandle,'Conectar');
     If ValidPointer(aFunc,'Conectar')
     then EP9FA_Conectar := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando Conectar');

     aFunc := GetProcAddress(fHandle,'ImprimirCierreX');
     If ValidPointer(aFunc,'ImprimirCierreX')
     then EP9FA_ImprimirCierreX := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ImprimirCierreX');

     aFunc := GetProcAddress(fHandle,'ImprimirCierreZ');
     If ValidPointer(aFunc,'ImprimirCierreZ')
     then EP9FA_ImprimirCierreZ := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ImprimirCierreZ');

     aFunc := GetProcAddress(fHandle,'Desconectar');
     If ValidPointer(aFunc,'Desconectar')
     then EP9FA_Desconectar := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando Desconectar');

     aFunc := GetProcAddress(fHandle,'Descargar');
     If ValidPointer(aFunc,'Descargar')
     then EP9FA_Descargar := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando Descargar');

     aFunc := GetProcAddress(fHandle,'DescargarPeriodoPendiente');
     If ValidPointer(aFunc,'DescargarPeriodoPendiente')
     then EP9FA_DescargarPeriodoPendiente := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando DescargarPeriodoPendiente');


     aFunc := GetProcAddress(fHandle,'ConfimarDescarga');
     If ValidPointer(aFunc,'ConfimarDescarga')
     then EP9FA_ConfimarDescarga := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConfimarDescarga');

     aFunc := GetProcAddress(fHandle,'ConsultarFechaPrimerJornadaPendiente');
     If ValidPointer(aFunc,'ConsultarFechaPrimerJornadaPendiente')
     then EP9FA_ConsultarFechaPrimerJornadaPendiente := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarFechaPrimerJornadaPendiente');

     aFunc := GetProcAddress(fHandle,'EstablecerFechaHora');
     If ValidPointer(aFunc,'EstablecerFechaHora')
     then EP9FA_EstablecerFechaHora := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando EstablecerFechaHora');

     aFunc := GetProcAddress(fHandle,'ImprimirAuditoria');
     If ValidPointer(aFunc,'ImprimirAuditoria')
     then EP9FA_ImprimirAuditoria := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ImprimirAuditoria');

     aFunc := GetProcAddress(fHandle,'ConsultarSubTotalNetoComprobanteActual');
     If ValidPointer(aFunc,'ConsultarSubTotalNetoComprobanteActual')
     then EP9FA_ConsultarSubTotalNetoComprobanteActual := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarSubTotalNetoComprobanteActual');

     aFunc := GetProcAddress(fHandle,'ConsultarSubTotalBrutoComprobanteActual');
     If ValidPointer(aFunc,'ConsultarSubTotalBrutoComprobanteActual')
     then EP9FA_ConsultarSubTotalBrutoComprobanteActual := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarSubTotalBrutoComprobanteActual');

     aFunc := GetProcAddress(fHandle,'ConsultarUltimoError');
     If ValidPointer(aFunc,'ConsultarUltimoError')
     then EP9FA_ConsultarUltimoError := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ConsultarUltimoError');

     aFunc := GetProcAddress(fHandle,'ObtenerEstadoFiscal');
     If ValidPointer(aFunc,'ObtenerEstadoFiscal')
     then EP9FA_ObtenerEstadoFiscal := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ObtenerEstadoFiscal');

     aFunc := GetProcAddress(fHandle,'ObtenerEstadoImpresora');
     If ValidPointer(aFunc,'ObtenerEstadoImpresora')
     then EP9FA_ObtenerEstadoImpresora := aFunc
     else bRet := False;
     GravaLog(' ImpEpsonT900FA - Comando ObtenerEstadoImpresora');

     If bRet then
     begin
       sVelPorta := Trim(SigaLojaINI('','LOGDLL','VELPORTA','9600'));
       If sVelPorta <> '' then
       begin
         GravaLog(' EP9FA_ConfigurarVelocidad -> Velocidade [' + sVelPorta + ']');
         iRet := EP9FA_ConfigurarVelocidad(StrToInt(sVelPorta));
         GravaLog(' EP9FA_ConfigurarVelocidad <- iRet [' + IntToStr(iRet) + ']');

         { Captura somente o numero da Porta}
         If Pos('COM',sPorta) > 0 then
         begin
           GravaLog(' EP9FA_ConfigurarPuerto -> Porta Recebido [' + sPorta + ']');
           sPorta := Copy(sPorta,4,Length(sPorta));
         end
         else
         begin
           ShowMessage('Error en la configuración de puerto! ' + CHR(13) +
                        ' Ajuste la informacion. Contenido -> ' + sPorta);
           GravaLog('Erro ao configurar a porta - Ajuste a informação - Setado :' + sPorta);
           bRet := False;
         end;

         If bRet then
         begin
           GravaLog(' EP9FA_ConfigurarPuerto -> Porta Tratado [' + sPorta + ']');
           iRet := EP9FA_ConfigurarPuerto(sPorta);
           GravaLog(' EP9FA_ConfigurarPuerto <- iRet [' + IntToStr(iRet) + ']');

           //************** OCORRE NO COMANDO ABREECF()************************
           //iRet := EP9FA_Conectar();

           If iRet = EP9FA_TagSucesso then
           begin
             GravaLog( ' ImpEpsonT900FA - Impressora Conectada com Sucesso ' );
           end
           else
           begin
             GravaLog( ' ImpEpsonT900FA - Erro ao tentar conectar com a Impressora ' );
             ShowMessage('Error al intentar conectar con la controladora fiscal');
             bRet := False;
           end;
         end;
       end
       else
       begin
         GravaLog( ' ImpEpsonT900FA - Velocidade da porta não configurada no SIGALOJA.INI -> Sessão [LOGDLL] / Chave : VelPorta ' );
         ShowMessage('Configure la velocidad de la puerta en el archivo SIGALOJA.INI');
         bRet := False
       end;
     end
     else
     begin
       ShowMessage('Error al cargar las properties, actulize su DLL EpsonFiscalInterface.dll');
       GravaLog('Error al cargar las properties, actulize su DLL EpsonFiscalInterface.dll');
       bRet := False;
     end;

   end
   else
   begin
     ShowMessage('Error al cargar la DLL EpsonFiscalInterface.dll');
     GravaLog('Erro ao carregar a DLL EpsonFiscalInterface.dll');
     bRet := False;
   end;

   If bRet
   then Result := '0|'
   else Result := '1|';
end;

function ImpEpsonT900FA.AcrescimoTotal(vlrAcrescimo: String): String;
var
  iRet, iX : Integer;
  aResp,aPad : array [0..65536] of Byte;
  sRet,sCmd,sDescripcion,sTpDoc,sTxIVA : String;
  bProssegue : Boolean;
begin
  GravaLog(' Inicio da função de Acrescimo no Total ');

  bProssegue := True;
  sDescripcion := 'Recargo Global';
  sTpDoc := TM900FACompAtual();
  sTxIVA := '';

  {------------------------------------------------
   Envio comando para retorno da informação de IVA
  -------------------------------------------------}

  //Para tipo : Tique ou Tique Nota de Credito
  If (sTpDoc = '83') OR (sTpDoc = '110') then
  begin
    sCmd := '0A0B|0001';
  end;

  //Para tipo : Tique-Factura ou Nota de Debito - A/B/C/M
  If (sTpDoc = '81') OR (sTpDoc = '82') OR (sTpDoc = '111') OR
     (sTpDoc = '115') OR (sTpDoc = '116') OR (sTpDoc = '117') OR
     (sTpDoc = '118') OR (sTpDoc = '120') then
  begin
    sCmd := '0B0B|0001';
  end;

 //Para tipo : Tique-Nota de Credito A/B/C/M
  If (sTpDoc = '112') OR (sTpDoc = '113') OR (sTpDoc = '114') OR
     (sTpDoc = '119') then
  begin
    sCmd := '0D0B|0001';
  end;

  If Trim(sCmd) = ''
  then bProssegue := False
  else
  begin
    GravaLog(' Antes de ler a informação de IVA do CF - sCmd [' + sCmd + ']');
    sRet := EnvCmd(sCmd,0);
    If Copy(sRet,1,1) = '0' then
    begin
      sRet := Trim(TM900FACmdExcRet('',2,0,False,aResp));
      If (sRet = '')
      then bProssegue := False
      else sTxIVA := Copy(sRet,1,2) + '.' + Copy(sRet,3,2) ;

      GravaLog(' informação de IVA do CF - sTxIVA [' + sTxIVA + ']');
    end
    else
    begin
      bProssegue := False;
      GravaLog(' Erro na leitura das informações de IVA ');
    end;
  end;

  If bProssegue then
  begin
    vlrAcrescimo := Copy(vlrAcrescimo,Pos('|', vlrAcrescimo)+1, Length(vlrAcrescimo));
    vlrAcrescimo := Copy(vlrAcrescimo,1, Pos('|', vlrAcrescimo)-1);
    vlrAcrescimo := StringReplace(vlrAcrescimo,',','.',[]);
    vlrAcrescimo := FormataTexto( FloatToStr( StrToFloat(vlrAcrescimo)),10,2,5);
    vlrAcrescimo := StringReplace(vlrAcrescimo,'.','',[]);
    vlrAcrescimo := StringReplace(vlrAcrescimo,',','',[]);

    //Para tipo : Tique ou Tique Nota de Credito
    If (sTpDoc = '83') OR (sTpDoc = '110') then
    begin
      sCmd := '0A04|0001|';
    end;

    //Para tipo : Tique-Factura ou Nota de Debito - A/B/C/M
    If (sTpDoc = '81') OR (sTpDoc = '82') OR (sTpDoc = '111') OR
       (sTpDoc = '115') OR (sTpDoc = '116') OR (sTpDoc = '117') OR
       (sTpDoc = '118') OR (sTpDoc = '120') then
    begin
      sCmd := '0B04|0001|';
    end;

   //Para tipo : Tique-Nota de Credito A/B/C/M
    If (sTpDoc = '112') OR (sTpDoc = '113') OR (sTpDoc = '114') OR
       (sTpDoc = '119') then
    begin
      sCmd := '0D04|0001|';
    end;

    {
    Descrição do comando :
    a- 0B04 - Comando de Desconto ou Acrescimo
    b- 0001 - Se refere a um acrescimo global ( para desconto usar 0000 )
    c- Descrição
    d- Valor - deve ser enviado sem virgulas ou pontos com duas casas. Ex.: 759; que é 7,59
    e- Taxa de IVA - para Acrescimo Global deve-se enviar em branco
    f- código interno
    g- Código de condição frente ao IVA - envia se Taxa de IVA maior que zero ( diferente de branco )
    }
    sTxIVA := ''; // Mando zerado (branco) pois quero considerar o acrescimo global
    GravaLog(' Taxa de IVA sera zerada para que seja considerada um Acrescimo no Total');

    sCmd := sCmd + sDescripcion + '|' + vlrAcrescimo + '|' + sTxIVA + '|';
    sCmd := sCmd + 'CodigoInterno4567890123456789012345678901234567890' + '|';

    If Trim(sTxIVA) <> '' //só inclui o valor 7 se o IVA for maior que zero
    then sCmd := sCmd + '7';

    GravaLog(' Envio do comando de Acrescimo - sCmd [' + sCmd+ ']');
    sRet := EnvCmd(sCmd,0);
    If Copy(sRet,1,1) = '0' then
    begin
      aResp := aPad;
      sRet := Trim(TM900FACmdExcRet('',1,0,False,aResp));    //Retorna o subtotal parcial
      iX := Length(sRet);
      If (sRet = '') Or (StrToFloat(sRet) = 0)
      then sRet := '00.00'
      else sRet := Copy(sRet,1,iX-2)+'.'+ Copy(sRet,iX-1,iX);

      GravaLog(' Retorno do Subtotal + Acrescimo - sCmd [' + sRet + ']');
      Result := '0|';
    end
    else
    begin
      bProssegue := False;
    end;

    if bProssegue = False then
    begin
      GravaLog(' Erro na execução do comando ');
      Result := '1';
    end;
  End
  else
  begin
    Result := '1';
  end;

  GravaLog(' Final - Acrescimo no Total - Result [' + Result + ']');
end;

function ImpEpsonT900FA.AdicionaAliquota(Aliquota: String;
  Tipo: Integer): String;
begin
Result := '0';
end;

procedure ImpEpsonT900FA.AlimentaProperties;
var
  sRet: String;
begin

sRet := PegaPdv;
If Copy(sRet,1,1) = '0' then
Begin
  PDV := Copy(sRet,3,Length(sRet));
  sPDV := PDV;
End;
GravaLog(' ImpEpsonT900FA - Fim de AlimentaProperties <- sPDV [' + sPDV + ']');

end;

function ImpEpsonT900FA.Autenticacao(Vezes: Integer; Valor,

  Texto: String): String;
begin
 Result := '0';
end;

function ImpEpsonT900FA.CancelaCupom(Supervisor: String): String;
var
   iRet : Integer;
begin

GravaLog(' EP9FA_Cancelar -> ');
iRet := EP9FA_Cancelar();
GravaLog(' EP9FA_Cancelar <- iRet [' + IntToStr(iRet) + ']');

If TM900FACodError(iRet) = EP9FA_TagSucesso then
begin
  GravaLog(' Cupom Cancelado com Sucesso ');
  Result := '0';
end
else
begin
  GravaLog(' Erro ao executar o comando de cancelamento ');
  Result := '1';
end;

end;

function ImpEpsonT900FA.CancelaItem(numitem, codigo, descricao, qtde,
  vlrunit, vlrdesconto, aliquota: String): String;
var
  iRet,iIdIVA,iIdII : Integer;
  sSerie,sAlqII: String;
  aInfoAlq : TaString;
begin

GravaLog('ImpEpsonT900FA - CancelaItem');
Result := '0';
sAlqII := Space(1);

sSerie:= Copy(PegaSerie,3,1);

If (sSerie <> 'A') and (sSerie <> 'B') then
begin
  GravaLog(' Erro no tipo de documento, série não compativel - Serie [' + sSerie + ']');
  Result := '1';
end
else
begin
  (*
    Aliquota, o Protheus envia:
    -Aliq de IVA
    -Valor de Impostos Brutos : geralmente vem em valor mas no comando aceita Percentual
    -Se inclui IVA

    Ex.:
    21.00|00000000014.21|B
  *)
  MontaArray(aliquota,aInfoAlq);
  iIdIVA := TM900FACodIVA(aInfoAlq[0]);
  iIdII  := TM900FACodII(aInfoAlq[1],sAlqII);

  GravaLog(' EP9FA_ImprimirItem -> ');
  iRet := EP9FA_ImprimirItem(201,descricao,qtde,vlrunit,iIdIVA,iIdII,sAlqII,1,codigo,Space(1),0);
  GravaLog(' EP9FA_ImprimirItem <- iRet [' + IntToStr(iRet) + ']');

  if TM900FACodError(iRet) <> EP9FA_TagSucesso then
  begin
    GravaLog(' Erro na tentativa de cancelar o item ');
    Result := '1';
  end;
end;

GravaLog('ImpEpsonT900FA - CancelaItem - Fim - Retorno [' + Result + ']');
end;

function ImpEpsonT900FA.DescontoTotal(vlrDesconto: String;
  nTipoImp: Integer): String;
var
  iRet : Integer;
begin
vlrDesconto := Copy(vlrDesconto,Pos('|', vlrDesconto)+1, Length(vlrDesconto));
vlrDesconto := Copy(vlrDesconto,1, Pos('|', vlrDesconto)-1);
vlrDesconto := StringReplace(vlrDesconto,',','.',[]);
vlrDesconto := FormataTexto( FloatToStr( StrToFloat(vlrDesconto)),13,2,1);

GravaLog('EP9FA_CargarAjuste -> Envio de Desconto - Valor [' + vlrDesconto + ']');
iRet := EP9FA_CargarAjuste(400,'Descuento',vlrDesconto,0,'DC');
GravaLog('EP9FA_CargarAjuste <- iRet [' + IntToStr(iRet) + ']');

If TM900FACodError(iRet) = EP9FA_TagSucesso then
begin
  Result := '0';
end
else
begin
  GravaLog('Erro ao tentar enviar o desconto no total');
  Result := '1';
end;

end;

function ImpEpsonT900FA.EnvCmd(Comando: String; Posicao: Integer): String;
var
  iRet : Integer;
begin

{
  EXEMPLO DE ENVIO DE COMANDO

  -Ejemplo de comando para realizar una descarga
    CTD desde el cierre Z número 1 al cierre Z número 3.
  EnviarComando( “0952|0000|1|3” )

  OU O COMANDO A SEGUIR DEVIDO A ESPECIFICIDADE DE ALGUNS COMANDOS

  - Comando para realizar una descarga CTD desde el el cierre Z número 1 al cierre Z número 3.
  EnviarComando( “0952|0000|x’31’|x’33’” )
}

GravaLog('EP9FA_EnviarComando -> Parametros [' + Comando + ']');
iRet := EP9FA_EnviarComando(Comando);
GravaLog('EP9FA_EnviarComando <- iRet [' + IntToStr(iRet) + ']');

iRet := TM900FACodError( iRet );
If iRet = EP9FA_TagSucesso
then Result := '0'
else Result := '1';
end;

function ImpEpsonT900FA.FechaCupom(Mensagem: String): String;
var
  iRet : Integer;
begin
  GravaLog(' EP9FA_CerrarComprobante -> ');
  iRet := EP9FA_CerrarComprobante();
  GravaLog(' EP9FA_CerrarComprobante <- iRet [' + IntToStr(iRet) + ']');

  if TM900FACodError(iRet) = EP9FA_TagSucesso then
  begin
    Result := '0';
  end
  else
  begin
    GravaLog(' Erro na tentativa de encerrar comprovante '); 
    Result := '1';
  end;
end;

function ImpEpsonT900FA.FechaCupomNaoFiscal: String;
begin
 Result := FechaCupom('');
end;

function ImpEpsonT900FA.FechaDNFH: String;
begin
 Result := FechaCupom('');
end;

function ImpEpsonT900FA.FechaECF: String;
var
  iRet : Integer;
begin
  GravaLog(' EP9FA_ImprimirCierreZ -> ');
  iRet := EP9FA_ImprimirCierreZ();
  GravaLog(' EP9FA_ImprimirCierreZ <- iRet [' + IntToStr(iRet) + ']');

  If TM900FACodError(iRet) = EP9FA_TagSucesso
  then Result := '0'
  else
  begin
    GravaLog(' Erro na execução do comando de Redução Z ');
    Result := '1';
  end;
end;

function ImpEpsonT900FA.Fechar(sPorta: String): String;
var
  iRet : Integer;
begin
GravaLog(' EP9FA_Desconectar -> ');
iRet := EP9FA_Desconectar();
GravaLog(' EP9FA_Desconectar <- iRet [' + IntToStr(iRet) + ']');
Result := '0';
end;

function ImpEpsonT900FA.Gaveta: String;
begin
GravaLog(' Abertura de gaveta -> ');
Result := EnvCmd('0707|0000',0);
GravaLog(' Abertura de gaveta <- Result [' + Result + ']');
end;

function ImpEpsonT900FA.GravaCondPag(condicao: string): String;
begin
Result := '0';
end;

function ImpEpsonT900FA.HorarioVerao(Tipo: String): String;
var
  iRet : Integer;
  sFecha_Hora,sHora,sData,sAuxHora: String;
begin
  Result := '0';
  DateTimeToString(sData,'ddmmyy',Date);
  sHora := Copy( StatusImp(1), 3, 8);
  sHora := SubstituiStr(sHora, ':', '');

  If Tipo = '+'
  then sAuxHora := IntToStr( StrToInt( Copy(sHora, 1, 2) ) + 1 ) + Copy(sHora, 3, 4)
  Else sAuxHora := IntToStr( StrToInt( Copy(sHora, 1, 2) ) - 1 ) + Copy(sHora, 3, 4) ;

  //Fecha_Hora no Padrão : ddmmyyTHHmmss
  sFecha_Hora := FormatDateTime('ddmmyyTHHmmss',Now);
  GravaLog(' EP9FA_EstablecerFechaHora ->  ');
  iRet := EP9FA_EstablecerFechaHora( sFecha_Hora );
  GravaLog(' EP9FA_EstablecerFechaHora <- iRet [' + IntToStr(iRet) + ']');

  If TM900FACodError(iRet) <> EP9FA_TagSucesso then
  begin
    GravaLog('Erro na tentativa de execução do comando '); 
    Result := '1';
  end;
end;

function ImpEpsonT900FA.ImpostosCupom(Texto: String): String;
begin
Result := '0'
end;

function ImpEpsonT900FA.ImpTxtFis(Texto: String): String;
var
  iRet : Integer;
begin
  Result := '0';
  GravaLog(' EP9FA_CargarTextoExtra -> ');
  iRet := EP9FA_CargarTextoExtra(Texto);
  GravaLog(' EP9FA_CargarTextoExtra <- iRet [' + IntToStr(iRet) + ']');

  If TM900FACodError(iRet) <> EP9FA_TagSucesso then
  begin
    GravaLog(' Erro ao tentar executar o comando ');
    Result := '1';
  end;
end;

function ImpEpsonT900FA.LeAliquotas: String;
begin
 Result := '0|';
end;

function ImpEpsonT900FA.LeAliquotasISS: String;
begin
 Result := '0|';
end;

function ImpEpsonT900FA.LeCondPag: String;
begin
 Result := '0|';
end;

function ImpEpsonT900FA.LeituraX: String;
var
  iRet : Integer;
begin
  Result := '0';
  GravaLog(' EP9FA_ImprimirCierreX -> ');
  iRet := EP9FA_ImprimirCierreX();
  GravaLog(' EP9FA_ImprimirCierreX <- iRet [' + IntToStr(iRet) + ']');

  If TM900FACodError(iRet) <> EP9FA_TagSucesso then
  begin
    GravaLog('erro ao tentar emitir a Leitura X');
    Result := '1';
  end;
end;

function ImpEpsonT900FA.MemoriaFiscal(DataInicio, DataFim: TDateTime;
  ReducInicio, ReducFim, Tipo: String): String;
var
  iRet : Integer;
  sDesde,sHasta: String;
begin
  Result := '0';
  if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
  begin
    sDesde := FormataTexto(ReducInicio,4,0,2);
    sHasta := FormataTexto(ReducFim,4,0,2);
  end
  else
  begin
    sDesde := FormataData(DataInicio,1);
    sHasta := FormataData(DataFim,1);
  end;

  {
  Id_modificador:
  - 500 : Auditoria detallada.
  - 501 : Auditoria resumida.
  }
  GravaLog(' EP9FA_ImprimirAuditoria -> ');
  iRet := EP9FA_ImprimirAuditoria(500,sDesde,sHasta);
  GravaLog(' EP9FA_ImprimirAuditoria <- iRet [' + IntToStr(iRet) + ']');

  If TM900FACodError(iRet) <> EP9FA_TagSucesso then
  begin
    GravaLog(' Erro ao tentar executar o comando ');
    Result := '1';
  end;

end;

function ImpEpsonT900FA.MemTrab: String;
begin
GravaLog(' Comando não suportado para este modelo ');
Result := '0';
end;

function ImpEpsonT900FA.Pagamento(Pagamento, Vinculado,
  Percepcion: String): String;

  function RetNumFormPg( sForma : string ): Integer;
  var
     nInd : Integer;
  begin
     nInd := 99; //Padrão: Otros Medios de Pago
     sForma := UpperCase(sForma);
    {Conforme manual:
        1 Carta de crédito documentario.
        2 Cartas de crédito simple.
        3 Cheque.
        4 Cheques cancelatorios.
        5 Crédito documentario.
        6 Cuenta corriente.
        7 Depósito.
        8 Efectivo.
        9 Endoso de cheque.
        10 Factura de crédito.
        11 Garantías bancarias.
        12 Giros.
        13 Letras de cambio.
        14 Medios de pago de comercio exterior.
        15 Orden de pago documentaria.
        16 Orden de pago simple.
        17 Pago contra reembolso.
        18 Remesa documentaria.
        19 Remesa simple.
        20 Tarjeta de crédito.
        21 Tarjeta de débito.
        22 Tique.
        23 Transferencia bancaria.
        24 Transferencia no bancaria
        99 Otros medios de pago.}

     If Pos('CHEQUE' , sForma ) > 0
     then nInd := 3;

     If Pos('CUENTA' , sForma ) > 0
     then nInd := 6;

     If Pos('EFECTIVO', sForma ) > 0
     then nInd := 8;

     If Pos('FACTURA' , sForma ) > 0
     then nInd := 10;

     If Pos('TARJETA', sForma ) > 0 then
     begin
       nInd := 20; //CREDITO

       If Pos('DEBITO',sForma) > 0
       then nInd := 21;
     end;

     If Pos('TIQUE', sForma ) > 0
     then nInd := 22;

     If Pos('TRANSFERENCIA', sForma ) > 0
     then nInd := 23;

     Result := nInd;
  end;
Var
  aAuxiliar,aPercepcion : TaString;
  sMensagem, sSubTotal, sSerie, sRet, sCmd, sTpDoc : String;
  iX,iRet : Integer;
  iPercepcion : double;
  aResp,aPad : array [0..65536] of Byte;
  bCmdTique, bCmdTqFac, bCmdNTCred : Boolean;
Begin
   GravaLog(' ImpEpsonT900FA - Inicio da função Pagamento ') ;
   iX := 0;
   iPercepcion := 0;
   iRet   := 0;
   sSerie := PegaSerie;
   sSerie := Copy( sSerie, 3, 1 );
   Pagamento := StrTran( Pagamento, ',', '.' );
   MontaArray( Pagamento, aAuxiliar );
   sMensagem := 'Lo número máximo de modos de pago excedieron.';
   sTpDoc := TM900FACompAtual();
   bCmdTique := False;
   bCmdTqFac := False;
   bCmdNTCred:= False;

   // Monta um array com as percepciones a serem enviadas
   MontaArray( Percepcion, aPercepcion );

   While iX < Length( aPercepcion ) Do
   Begin
      iPercepcion := iPercepcion + StrToFloat( aPercepcion[iX+2] );
      Inc( iX, 3 );
   End;

   GravaLog('Length(aPercepcion): ' + IntToStr(Length(aPercepcion)));

   //impressora permite ate 4 formas de pagamento
   If Length(aAuxiliar) > 8 Then
   Begin
      iRet := 1;
      GravaLog(sMensagem);
      ShowMessage( sMensagem );
   End;

   If iRet = EP9FA_TagSucesso Then
   Begin
      //Impressão do Subtotal para fechar a venda
      GravaLog('EP9FA_ImprimirSubtotal ->');
      iRet := EP9FA_ImprimirSubtotal();
      GravaLog('EP9FA_ImprimirSubtotal <- iRet [' + IntToStr(iRet) + ']');

      If TM900FACodError(iRet) = EP9FA_TagSucesso then
      begin

        If sTpDoc <> '' then
        begin
          //Para tipo : Tique ou Tique Nota de Credito
          If (sTpDoc = '83') OR (sTpDoc = '110') then
          begin
            sCmd := '0A03|0001';
            bCmdTique := True;
          end;

          //Para tipo : Tique-Factura ou Nota de Debito - A/B/C/M
          If (sTpDoc = '81') OR (sTpDoc = '82') OR (sTpDoc = '111') OR
             (sTpDoc = '115') OR (sTpDoc = '116') OR (sTpDoc = '117') OR
             (sTpDoc = '118') OR (sTpDoc = '120') then
          begin
            sCmd := '0B03|0001';
            bCmdTqFac := True;
          end;

          //Para tipo : Tique-Nota de Credito A/B/C/M
          If (sTpDoc = '112') OR (sTpDoc = '113') OR (sTpDoc = '114') OR
             (sTpDoc = '119') then
          begin
            sCmd := '0D03|0001';
            bCmdNTCred := True;
          end;

          sRet := EnvCmd(sCmd,0);
          If Copy(sRet,1,1) = '0' then
          begin
            aResp := aPad;
            sSubTotal := Trim(TM900FACmdExcRet('',1,0,False,aResp));    //Retorna o total bruto
            iX := Length(sSubTotal);
            If (sSubTotal = '') Or (StrToFloat(sSubTotal) = 0)
            then sSubTotal := '00,00'
            else sSubTotal := Copy(sSubTotal,1,iX-2)+'.'+ Copy(sSubTotal,iX-1,iX);

            If Abs(StrToFloat(Vinculado) - ( StrToFloat(sSubTotal) + iPercepcion )) >= 0.005 then
            Begin
              sRet := '0';
              If ( StrToFloat( sSubTotal ) + iPercepcion ) > StrToFloat( Vinculado ) Then
              Begin
                 sSubTotal := FloatToStr( ( StrToFloat( sSubTotal ) + iPercepcion ) - StrToFloat( Vinculado ) );
                 sSubTotal := '|' + sSubTotal + '|'; //Necessário para função DescontoTotal
                 sRet := DescontoTotal(sSubTotal,0);
              End
              Else If ( StrToFloat( sSubTotal ) + iPercepcion ) < StrToFloat( Vinculado ) Then
              Begin
                 sSubTotal := FloatToStr( ( StrToFloat( sSubTotal ) + iPercepcion ) - StrToFloat( Vinculado ) );
                 sSubTotal := StringReplace(sSubTotal,'-','',[]);
                 sSubTotal := '|' + sSubTotal + '|'; //Necessário para função AcrescimoTotal
                 sRet := AcrescimoTotal(sSubTotal);
              End;

              iRet := StrToInt(Copy(sRet,1,1));
            End;
          End;
        End
        else
        begin
          iRet := 1;
        end;
      End;

      // Faz o registro das percepciones se houver
      If (iRet = EP9FA_TagSucesso) AND (Length(aPercepcion) > 0) Then
      Begin
         iX := 0;
         While iX < Length(aPercepcion) Do
         Begin
           GravaLog( 'Percepcao( '+ aPercepcion[iX] + ', ' + aPercepcion[iX+1] + ', ' + aPercepcion[iX+2] + ') '  );
           Percepcao(aPercepcion[iX], aPercepcion[iX+1], aPercepcion[iX+2]);
           Inc(iX,3);
         End;
      End;
   End;

   // Faz o registro do pagamento
   If iRet = EP9FA_TagSucesso Then
   Begin
     iX := 0;
     While (iX < Length(aAuxiliar) ) do
     Begin
       GravaLog(' EP9FA_CargarPago -> ');
       iRet := EP9FA_CargarPago(200, RetNumFormPg(UpperCase(aAuxiliar[iX])), 1,
                    aAuxiliar[iX+1], Space(1), aAuxiliar[iX],Space(1),Space(1));
       GravaLog(' EP9FA_CargarPago <- iRet [' + IntToStr(iRet) + ']');

       If TM900FACodError(iRet) = EP9FA_TagSucesso then
       begin
         sRet := '0';
       end
       else
       begin
         sRet := '1';
         GravaLog(' Erro na impressão da forma de pagamento [' + aAuxiliar[iX] + ']');
       end;
       Inc(iX,2);
     End;
   End;

   If iRet <> EP9FA_TagSucesso
   then sRet := '1|';

   Result := sRet;
   GravaLog(' ImpEpsonT900FA - Fim da função Pagamento - Result :' + Result) ;
end;

function ImpEpsonT900FA.Pedido(Totalizador, Tef, Texto, Valor,
  CondPagTef: String): String;
begin
  Result := '0';
end;

function ImpEpsonT900FA.PegaCupom(Cancelamento: String): String;

   function TpDoc(sTipo: String): String;
   var
     sRet : String;
   begin
     sRet := '83';

     If sTipo = 'A'
     then sRet := '81';

     If sTipo = 'B'
     then sRet := '82';

     If sTipo = 'C'
     then sRet := '111';

     If sTipo = 'M'
     then sRet := '118';

     Result := sRet;
   end;

var
  iRet,iTemp : Integer;
  sNumCup,sRetSt,sTpDoc : String;
  aResp: array [0..65536] of Byte;
  aTipos : array[0..15] of String;
begin
  iTemp := 60;
  sNumCup:= Space( iTemp );
  sRetSt := StatusImp(5);
  sRetSt := Copy(sRetSt,1,1);

  If sRetSt = '1' then   //erro na execuação do comando anterior
  begin
    GravaLog(' Erro na verificação do Status do ECF ');
    iRet := 1;
  end
  else If sRetSt = '7' then //Cupom aberto
  begin
    GravaLog(' EP9FA_ConsultarNumeroComprobanteActual -> ');
    iRet := EP9FA_ConsultarNumeroComprobanteActual(sNumCup ,iTemp);
    GravaLog(' EP9FA_ConsultarNumeroComprobanteActual <- iRet [' + IntToStr(iRet) + ']');
  end
  else
  begin
    {sRetSt := TM900FACmdExcRet('0B10|0000',2,0,True,aResp);
    sTpDoc := TpDoc(sRetSt);
    GravaLog(' EP9FA_ConsultarNumeroComprobanteUltimo -> ' + sTpDoc);
    iRet := EP9FA_ConsultarNumeroComprobanteUltimo(sTpDoc, sNumCup , iTemp);
    GravaLog(' EP9FA_ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
    }

    aTipos[0] := '83';
    aTipos[1] := '81';
    aTipos[2] := '82';
    aTipos[3] := '110';
    aTipos[4] := '111';
    aTipos[5] := '112';
    aTipos[6] := '113';
    aTipos[7] := '114';
    aTipos[8] := '115';
    aTipos[9] := '116';
    aTipos[10] := '117';
    aTipos[11] := '118';
    aTipos[12] := '119';
    aTipos[13] := '120';
    aTipos[14] := '910';
    aTipos[15] := '950';

    For iTemp := 0 to Pred(Length(aTipos)) do
    begin
      sRetSt := TM900FACmdExcRet('0830|0000|' + aTipos[iTemp],5,0,True,aResp);

      If (Trim(sRetSt) <> '') and (StrToInt(sRetSt) >= 0) then
      begin
        GravaLog(' PegaCupom - Encontrado numero de cupom <- Numero [' +
                  sRetSt +'] / Tipo de Doc [ ' + aTipos[iTemp] + ']');
        Break;
      end;
    end;

    If sRetSt = ''
    then iRet := 1
    else
    begin
      sNumCup := sRetSt;
      iRet := EP9FA_TagSucesso;
    end;
  end;

  If TM900FACodError(iRet) = EP9FA_TagSucesso then
  begin
    Result := '0|' + Trim(sNumCup);
  end
  else
  begin
    GravaLog(' Erro ao capturar numero do cupom ');
    Result := '1|';
  end;

  GravaLog(' ImpEpsonT900FA - PegaCupom - Retorno do Numero do Cupom [' + Result + ']');
end;

function ImpEpsonT900FA.PegaPDV: String;
var
  iRet : Integer;
  sPDV : String;
begin
sPDV := Space(20);
GravaLog(' EP9FA_ConsultarNumeroPuntoDeVenta -> ');
iRet := EP9FA_ConsultarNumeroPuntoDeVenta(sPDV,Length(sPDV));
GravaLog(' EP9FA_ConsultarNumeroPuntoDeVenta <- iRet [' + IntToStr(iRet) + ']');

If TM900FACodError(iRet) = EP9FA_TagSucesso
then Result := '0|' + Trim(sPDV)
else
begin
  GravaLog('Erro ao tentar capturar o numero do PDV');
  Result := '1|';
end;

end;

function ImpEpsonT900FA.PegaSerie: String;
var
  sRet : String;
  iRet,iTam,iRTam  : Integer;
  aResp: array [0..65536] of Byte;
begin
  GravaLog(' Numero de Serie -> ');
  sRet := EnvCmd('0005|0000',0);
  GravaLog(' Numero de Serie <- iRet [' + sRet + ']');

  If Copy(sRet,1,1) = '0' then
  begin
    iTam := 16;
    iRTam:= 0;
    GravaLog(' EP9FA_ObtenerRespuestaExtendida -> ');
    iRet := EP9FA_ObtenerRespuestaExtendida(2,aResp[0],iTam,iRTam);
    GravaLog(' EP9FA_ObtenerRespuestaExtendida <- iRet: ' + IntToStr(iRet) + ']');

    If TM900FACodError( iRet ) = EP9FA_TagSucesso then
    begin
      sRet := '';

      For iTam := 0 to Pred(iRTam) do
        sRet := sRet + CHR(aResp[iTam]);

      Result := '0|' + Trim(sRet);
    end
    else
    begin
      GravaLog('Erro ao capturar o retorno do comando');
      Result := '1|';
    end;
  end
  else
  begin
    GravaLog('Erro ao tentar capturar o numero de serie da impressora');
    Result := '1|';
  end;

  GravaLog(' Serie Retornada - ' + Result);
end;

function ImpEpsonT900FA.Percepcao(sAliq, sTexto, sValor: String): String;
var
  iRet : Integer;
begin
  Result := '0';

  If Trim(sTexto) = ''
  then sTexto := 'Percepcion';

  GravaLog(' EP9FA_CargarOtrosTributos ->');
  iRet := EP9FA_CargarOtrosTributos( 9 , sTexto , FormataTexto( sValor, 11, 2, 5 ), 0 );
  GravaLog(' EP9FA_CargarOtrosTributos <- iRet [' + IntToStr(iRet) + ']');

  If TM900FACodError(iRet) <> EP9FA_TagSucesso then
  begin
    GravaLog(' Erro ao executar o comando ');
    Result := '1';
  end;

  GravaLog( ' ImpEpsonT900FA - Percepcao - Retorno : ' + Result );
end;

function ImpEpsonT900FA.ReducaoZ(MapaRes: String): String;
var
  iRet,iDadoRedZ : Integer;
  aRetorno: array of String;
  aResp,aPad : array [0..65536] of Byte;
  sRet1,sRet2,sRet3,sRet4,sRet5 : String;
begin
  Result := '0|';
  MapaRes:= Trim(MapaRes);
  iRet := 0;
  iDadoRedZ := -1; //Para garantir que os dados foram pegos ou não

  If MapaRes = 'S' then
  begin

    (*
    ³01 - XXXX			- Status da impressora
    ³02 - XXXX			- Status fiscal
    ³03 - XXXX			- Numero da reducao Z
    ³04 - XXXXX			- Quantidade de documentos fiscais cancelados
    ³05 - XXXXX			- Quantidade de documentos nao fiscal homologado
    ³06 - XXXXX			- Quantidade de documentos nao fiscal
    ³07 - XXXXXX		- Quantidade de documentos fiscais emitidos
    ³08 - X			- Reservado (sempre 0)
    ³09 - XXXXXXXX		- Numero do ultimo documento B/C emitido
    ³10 - XXXXXXXX		- Numero do ultimo documento A emitido
    ³11 - XXXXXXXXXXXX		- Valor vendido em documentos fiscais
    ³12 - XXXXXXXXXXXX		- Valor IVA em documentos fiscais
    ³13 - XXXXXXXXXXXX		- Valor impostos internos em documentos fiscais
    ³14 - XXXXXXXXXXXX		- Valor percepcao em documentos fiscais
    ³15 - XXXXXXXXXXXX		- Valor IVA nao inscrito em documentos fiscais
    ³16 - XXXXXXXX		- Numero ultima Nota de credito B/C emitida
    ³17 - XXXXXXXX		- Numero ultima Nota de credito A emitida
    ³18 - XXXXXXXXXXXX		- Credito em notas de credito
    ³19 - XXXXXXXXXXXX		- Valor IVA em notas de credito
    ³20 - XXXXXXXXXXXX		- Valor impostos internos em notas de credito
    ³21 - XXXXXXXXXXXX		- Valor percepcao em notas de credito
    ³22 - XXXXXXXXXXXX		- Valor IVA nao inscrito em notas de credito
    ³23 - XXXXXXXX		- Numero ultimo remito
    *)
    SetLength(aRetorno,23);

    //**** Status da Impressora ****//
    aRetorno[0]:= 'OK';

    //**** Status Fiscal ****
    aRetorno[1] := 'OK';

    //**** Numero da Redução Z ****//
    aResp := aPad;
    aRetorno[2] := TM900FACmdExcRet('080A|0000|83',3,5,True,aResp);

    //**** Qtde de documentos fiscais cancelados ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|81',8,10,True,aResp); //Tique Factura A

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|82',8,10,True,aResp); //Tique Factura B

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|83',8,10,True,aResp); //Tique

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080A|0000|111',8,10,True,aResp); //Tique Factura C

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080A|0000|118',8,10,True,aResp); //Tique Factura M

    aRetorno[3] := IntToStr(StrToInt(sRet1)+StrToInt(sRet2)+StrToInt(sRet3)+StrToInt(sRet4)+StrToInt(sRet5));

    //**** Quantidade de documentos nao fiscal homologado ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|91',7,10,True,aResp);

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|901',7,10,True,aResp);

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|910',7,10,True,aResp);

    aResp := aPad;
    sRet4 :=  TM900FACmdExcRet('080A|0000|950',7,10,True,aResp);

    aRetorno[ 4] := IntToStr(StrToInt(sRet1)+StrToInt(sRet2)+StrToInt(sRet3)+StrToInt(sRet4));

    //**** Quantidade de documentos nao fiscal ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|110',7,10,True,aResp);

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|112',7,10,True,aResp);

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|113',7,10,True,aResp);

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080A|0000|114',7,10,True,aResp);

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080A|0000|119',7,10,True,aResp);

    aRetorno[ 5] := IntToStr(StrToInt(sRet1)+StrToInt(sRet2)+StrToInt(sRet3)+StrToInt(sRet4)+StrToInt(sRet5));

    //**** Quantidade de documentos fiscais emitidos ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|81',7,10,True,aResp); //Tique Factura A

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|82',7,10,True,aResp); //Tique Factura B

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|83',7,10,True,aResp); //Tipo Tique

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080A|0000|111',7,10,True,aResp); //Tique Factura C

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080A|0000|118',7,10,True,aResp); //TIque Factura M

    aRetorno[ 6] := IntToStr(StrToInt(sRet1)+StrToInt(sRet2)+StrToInt(sRet3)+StrToInt(sRet4)+StrToInt(sRet5));

    //**** RESERVADO *****
    aRetorno[ 7] := '0';

    //**** Numero do ultimo documento B/C emitido ****//
    aRetorno[ 8] := Space(60);
    iRet := EP9FA_ConsultarNumeroComprobanteUltimo('82', aRetorno[ 8] , Length(aRetorno[ 8]));    //Tipo B
    If (TM900FACodError( iRet ) = EP9FA_TagSucesso) AND (StrToInt(Trim(aRetorno[8])) > 0)
    then aRetorno[ 8] := Trim(aRetorno[ 8])
    else
    begin
      aRetorno[ 8] := Space(60);
      iRet := EP9FA_ConsultarNumeroComprobanteUltimo('111', aRetorno[ 8] , Length(aRetorno[ 8]));    //Tipo C
      If (TM900FACodError( iRet ) = EP9FA_TagSucesso) AND (StrToInt(Trim(aRetorno[8])) > 0)
      then aRetorno[ 8] := Trim(aRetorno[ 8])
      else aRetorno[ 8] := '0';
    end;

    //**** Numero do ultimo documento A emitido ****//
    aRetorno[ 9] := Space(60);
    iRet := EP9FA_ConsultarNumeroComprobanteUltimo('81', aRetorno[ 9] , Length(aRetorno[ 9]));
    If TM900FACodError( iRet ) = EP9FA_TagSucesso
    then aRetorno[ 9] := Trim(aRetorno[ 9])
    else aRetorno[ 9] := '0';

    //**** Valor vendido em documentos fiscais ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|81',9,12,True,aResp);
    sRet1 := Copy(sRet1,1,Length(sRet1)-2)+'.'+Copy(sRet1,Length(sRet1)-1,Length(sRet1));

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|82',9,12,True,aResp);
    sRet2 := Copy(sRet2,1,Length(sRet2)-2)+'.'+Copy(sRet2,Length(sRet2)-1,Length(sRet2));

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|83',9,12,True,aResp);
    sRet3 := Copy(sRet3,1,Length(sRet3)-2)+'.'+Copy(sRet3,Length(sRet3)-1,Length(sRet3));

    aRetorno[10] := FormataTexto(FloatToStr(StrToFloat(sRet1) + StrToFloat(sRet2) + StrToFloat(sRet3)),19,2,1);

    //**** Valor IVA em documentos fiscais ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|81',10,12,True,aResp);
    sRet1 := Copy(sRet1,1,Length(sRet1)-2)+'.'+Copy(sRet1,Length(sRet1)-1,Length(sRet1));

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|82',10,12,True,aResp);
    sRet2 := Copy(sRet2,1,Length(sRet2)-2)+'.'+Copy(sRet2,Length(sRet2)-1,Length(sRet2));

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|83',10,12,True,aResp);
    sRet3 := Copy(sRet3,1,Length(sRet3)-2)+'.'+Copy(sRet3,Length(sRet3)-1,Length(sRet3));

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080A|0000|111',10,12,True,aResp);
    sRet4 := Copy(sRet4,1,Length(sRet4)-2)+'.'+Copy(sRet4,Length(sRet4)-1,Length(sRet4));

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080A|0000|118',10,12,True,aResp);
    sRet5 := Copy(sRet5,1,Length(sRet5)-2)+'.'+Copy(sRet5,Length(sRet5)-1,Length(sRet5));

    aRetorno[11] := FormataTexto(FloatToStr(StrToFloat(sRet1)
                        + StrToFloat(sRet2)+ StrToFloat(sRet3)
                        + StrToFloat(sRet4)+ StrToFloat(sRet5))
                        ,19,2,1);

    //**** Valor impostos internos em documentos fiscais ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|81',11,12,True,aResp);
    sRet1 := Copy(sRet1,1,Length(sRet1)-2)+'.'+Copy(sRet1,Length(sRet1)-1,Length(sRet1));

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|82',11,12,True,aResp);
    sRet2 := Copy(sRet2,1,Length(sRet2)-2)+'.'+Copy(sRet2,Length(sRet2)-1,Length(sRet2));

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|83',11,12,True,aResp);
    sRet3 := Copy(sRet3,1,Length(sRet3)-2)+'.'+Copy(sRet3,Length(sRet3)-1,Length(sRet3));

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080A|0000|111',11,12,True,aResp);
    sRet4 := Copy(sRet4,1,Length(sRet4)-2)+'.'+Copy(sRet4,Length(sRet4)-1,Length(sRet4));

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080A|0000|118',11,12,True,aResp);
    sRet5 := Copy(sRet5,1,Length(sRet5)-2)+'.'+Copy(sRet5,Length(sRet5)-1,Length(sRet5));

    aRetorno[12] := FormataTexto(FloatToStr(StrToFloat(sRet1)
                        + StrToFloat(sRet2) + StrToFloat(sRet3)
                        + StrToFloat(sRet4) + StrToFloat(sRet5))
                        ,19,2,1);

    //**** Valor percepcao em documentos fiscais ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080C|0000|81|0',3,12,True,aResp);
    sRet1 := Copy(sRet1,1,Length(sRet1)-2)+'.'+Copy(sRet1,Length(sRet1)-1,Length(sRet1));

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080C|0000|82|0',3,12,True,aResp);
    sRet2 := Copy(sRet2,1,Length(sRet2)-2)+'.'+Copy(sRet2,Length(sRet2)-1,Length(sRet2));

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080C|0000|83|0',3,12,True,aResp);
    sRet3 := Copy(sRet3,1,Length(sRet3)-2)+'.'+Copy(sRet3,Length(sRet3)-1,Length(sRet3));

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080C|0000|111|0',3,12,True,aResp);
    sRet4 := Copy(sRet4,1,Length(sRet4)-2)+'.'+Copy(sRet4,Length(sRet4)-1,Length(sRet4));

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080C|0000|118|0',3,12,True,aResp);
    sRet5 := Copy(sRet5,1,Length(sRet5)-2)+'.'+Copy(sRet5,Length(sRet5)-1,Length(sRet5));

    aRetorno[13] := FormataTexto(FloatToStr(StrToFloat(sRet1)
                        + StrToFloat(sRet2) + StrToFloat(sRet3)
                        + StrToFloat(sRet4) + StrToFloat(sRet5))
                        ,19,2,1);

    //**** Valor IVA nao inscrito em documentos fiscais ****//
    aRetorno[14] := FormataTexto(FloatToStr(0),19,2,1);

    //**** Numero ultima Nota de credito B/C emitida ****//
    sRet1 := Space(60);
    iRet := EP9FA_ConsultarNumeroComprobanteUltimo('113', sRet1 , Length(sRet1)); //Tipo B
    If (TM900FACodError( iRet ) = EP9FA_TagSucesso) AND ( StrToInt(sRet1) > 0 )
    then aRetorno[15] := Trim(aRetorno[15])
    else aRetorno[15] := '';

    If Trim(aRetorno[15]) = '' then
    begin
      aRetorno[15] := Space(60);
      iRet := EP9FA_ConsultarNumeroComprobanteUltimo('114', aRetorno[15] , Length(aRetorno[15])); //Tipo C
      If (TM900FACodError( iRet ) = EP9FA_TagSucesso) AND ( StrToInt(aRetorno[15]) > 0 )
      then aRetorno[15] := Trim(aRetorno[15])
      else aRetorno[15] := '0';
    end;

    //**** Numero ultima Nota de credito A emitida ****//
    aRetorno[16] := Space(60);
    iRet := EP9FA_ConsultarNumeroComprobanteUltimo('112', aRetorno[16] , Length(aRetorno[16]));
    If TM900FACodError( iRet ) = EP9FA_TagSucesso
    then aRetorno[16] := Trim(aRetorno[16])
    else aRetorno[16] := '0';

    //**** Credito em notas de credito ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|110',9,12,True,aResp);
    sRet1 := Copy(sRet1,1,Length(sRet1)-2)+'.'+Copy(sRet1,Length(sRet1)-1,Length(sRet1));

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|112',9,12,True,aResp);
    sRet2 := Copy(sRet2,1,Length(sRet2)-2)+'.'+Copy(sRet2,Length(sRet2)-1,Length(sRet2));

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|113',9,12,True,aResp);
    sRet3 := Copy(sRet3,1,Length(sRet3)-2)+'.'+Copy(sRet3,Length(sRet3)-1,Length(sRet3));

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080A|0000|114',9,12,True,aResp);
    sRet4 := Copy(sRet4,1,Length(sRet4)-2)+'.'+Copy(sRet4,Length(sRet4)-1,Length(sRet4));

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080A|0000|119',9,12,True,aResp);
    sRet5 := Copy(sRet5,1,Length(sRet5)-2)+'.'+Copy(sRet5,Length(sRet5)-1,Length(sRet5));

    aRetorno[17] := FormataTexto(FloatToStr(StrToFloat(sRet1)
                                + StrToFloat(sRet2) + StrToFloat(sRet3)
                                + StrToFloat(sRet4) + StrToFloat(sRet5))
                                ,19,2,1);

    //**** Valor IVA em notas de credito ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|110',10,12,True,aResp);
    sRet1 := Copy(sRet1,1,Length(sRet1)-2)+'.'+Copy(sRet1,Length(sRet1)-1,Length(sRet1));

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|112',10,12,True,aResp);
    sRet2 := Copy(sRet2,1,Length(sRet2)-2)+'.'+Copy(sRet2,Length(sRet2)-1,Length(sRet2));

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|113',10,12,True,aResp);
    sRet3 := Copy(sRet3,1,Length(sRet3)-2)+'.'+Copy(sRet3,Length(sRet3)-1,Length(sRet3));

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080A|0000|114',10,12,True,aResp);
    sRet4 := Copy(sRet4,1,Length(sRet4)-2)+'.'+Copy(sRet4,Length(sRet4)-1,Length(sRet4));

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080A|0000|119',10,12,True,aResp);
    sRet5 := Copy(sRet5,1,Length(sRet5)-2)+'.'+Copy(sRet5,Length(sRet5)-1,Length(sRet5));

    aRetorno[18] := FormataTexto(FloatToStr(StrToFloat(sRet1)
                                + StrToFloat(sRet2) + StrToFloat(sRet3)
                                + StrToFloat(sRet4) + StrToFloat(sRet5))
                                ,19,2,1);

    //**** Valor impostos internos em notas de credito ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080A|0000|110',11,12,True,aResp);
    sRet1 := Copy(sRet1,1,Length(sRet1)-2)+'.'+Copy(sRet1,Length(sRet1)-1,Length(sRet1));

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080A|0000|112',11,12,True,aResp);
    sRet2 := Copy(sRet2,1,Length(sRet2)-2)+'.'+Copy(sRet2,Length(sRet2)-1,Length(sRet2));

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080A|0000|113',11,12,True,aResp);
    sRet3 := Copy(sRet3,1,Length(sRet3)-2)+'.'+Copy(sRet3,Length(sRet3)-1,Length(sRet3));

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080A|0000|114',11,12,True,aResp);
    sRet4 := Copy(sRet4,1,Length(sRet4)-2)+'.'+Copy(sRet4,Length(sRet4)-1,Length(sRet4));

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080A|0000|119',11,12,True,aResp);
    sRet5 := Copy(sRet5,1,Length(sRet5)-2)+'.'+Copy(sRet5,Length(sRet5)-1,Length(sRet5));

    aRetorno[19] := FormataTexto(FloatToStr(StrToFloat(sRet1)
                                + StrToFloat(sRet2) + StrToFloat(sRet3)
                                + StrToFloat(sRet4) + StrToFloat(sRet5))
                                ,19,2,1);

    //**** Valor percepcao em notas de credito ****//
    aResp := aPad;
    sRet1 := TM900FACmdExcRet('080C|0000|110|0',3,12,True,aResp);
    sRet1 := Copy(sRet1,1,Length(sRet1)-2)+'.'+Copy(sRet1,Length(sRet1)-1,Length(sRet1));

    aResp := aPad;
    sRet2 := TM900FACmdExcRet('080C|0000|112|0',3,12,True,aResp);
    sRet2 := Copy(sRet2,1,Length(sRet2)-2)+'.'+Copy(sRet2,Length(sRet2)-1,Length(sRet2));

    aResp := aPad;
    sRet3 := TM900FACmdExcRet('080C|0000|113|0',3,12,True,aResp);
    sRet3 := Copy(sRet3,1,Length(sRet3)-2)+'.'+Copy(sRet3,Length(sRet3)-1,Length(sRet3));

    aResp := aPad;
    sRet4 := TM900FACmdExcRet('080C|0000|114|0',3,12,True,aResp);
    sRet4 := Copy(sRet4,1,Length(sRet4)-2)+'.'+Copy(sRet4,Length(sRet4)-1,Length(sRet4));

    aResp := aPad;
    sRet5 := TM900FACmdExcRet('080C|0000|119|0',3,12,True,aResp);
    sRet5 := Copy(sRet5,1,Length(sRet5)-2)+'.'+Copy(sRet5,Length(sRet5)-1,Length(sRet5));

    aRetorno[20] := FormataTexto(FloatToStr(StrToFloat(sRet1)
                                + StrToFloat(sRet2) + StrToFloat(sRet3)
                                + StrToFloat(sRet4) + StrToFloat(sRet5))
                                ,19,2,1);

    //**** Valor IVA nao inscrito em notas de credito ****//
    aRetorno[21] := FormataTexto(FloatToStr(0),19,2,1);

    //**** Numero ultimo remito ****//
    aRetorno[22] := Space(60);
    EP9FA_ConsultarNumeroComprobanteUltimo('910', aRetorno[22] , Length(aRetorno[22]));
    If iRet = EP9FA_TagSucesso
    then aRetorno[22] := Trim(aRetorno[22])
    else aRetorno[22] := '0';

    iDadoRedZ := 0;
    GravaLog(' Dados da SFI capturados com sucesso' );
  End
  else
    iDadoRedZ := 0;

  If iDadoRedZ = EP9FA_TagSucesso then
  begin
    GravaLog(' EP9FA_ImprimirCierreZ -> ');
    iRet := EP9FA_ImprimirCierreZ();
    GravaLog(' EP9FA_ImprimirCierreZ <- iRet [' + IntToStr(iRet) + ']');
  End;

  If (iDadoRedZ = EP9FA_TagSucesso) AND (TM900FACodError( iRet ) = EP9FA_TagSucesso) then
  begin
    GravaLog(' Redução Z emitida com sucesso' );
    Result := '0|';
    If MapaRes = 'S' then
    begin
      GravaLog('Acumulo dos dados da SFI para retorno' );

      For iRet:= 0 to High(aRetorno) do
        Result := Result + aRetorno[iRet] + CHR(28); //O Loja160 procura como separador char #28, se mudar aqui mudar na Hasar e no LOJA160
    end;
  end
  else
  begin
    ShowMessage(' Error en la emision del cierre Z ');
    GravaLog(' Erro na emissão da Redução Z ');
    Result := '1|';
  end;

  GravaLog('Função Reducao Z - Result [' + Copy(Result,1,1) + ']' );
end;

//------------------------------------------------------------------------------
function ImpEpsonT900FA.RegistraItem(codigo, descricao, qtde, vlrUnit,
  vlrdesconto, aliquota, vlTotIt, UnidMed: String;
  nTipoImp: Integer): String;
Var
  sSerie, slinDesc1, slinDesc2, slinDesc3,
  sRet, sAlqII : String;
  bDesconto : Boolean;
  iRet,iIdUM,iIdIVA,iIdII : Integer;
  aInfoAlq : TaString;
begin
  sRet   := '0|';
  iRet   := 0;
  Result := sRet;
  bDesconto := False;

  (*
    Aliquota, o Protheus envia:
    -Aliq de IVA
    -Valor de Impostos Brutos : geralmente vem em valor mas no comando aceita Percentual
    -Se inclui IVA

    Ex.:
    21.00|00000000014.21|B
  *)
  MontaArray(aliquota,aInfoAlq);
  sSerie := aInfoAlq[2];

  if Trim(vlrdesconto) <> '0.00' then
  begin
    bDesconto   := True;
    vlrdesconto := Trim(vlrdesconto);
    if sSerie = 'B' then
    begin
      vlrdesconto :=  FloatToStrF( StrToFloat( vlrdesconto ) * ( 1 + ( StrToFloat( aInfoAlq[0] ) / 100 ) ),
                             ffGeneral, 9, 4 );
    end;
  end;

  if sSerie = 'B' then
  begin
    vlrUnit :=  FloatToStrF( StrToFloat( vlrUnit ) * ( 1 + ( StrToFloat( aInfoAlq[0] ) / 100 ) ),
                               ffGeneral, 9, 4 );
  end;

   if multiLine then
   begin
     slinDesc1 :=  Trim( Copy(descricao + space(26), 01, 26) );
     slinDesc2 :=  Trim( Copy(descricao + space(52), 27, 26) );
     slinDesc3 :=  Trim( Copy(descricao + space(78), 53, 26) );
   end
   else
   begin
     slinDesc1 :=  Copy(descricao + space(26), 01, 26);
     slinDesc2 :=  '';
     slinDesc3 :=  '';
   end;

  iIdIVA := TM900FACodIVA(aInfoAlq[0]);
  iIdII  := TM900FACodII(Trim(aInfoAlq[1]),sAlqII);

  {**********************************
  TRATAMENTO PARA A UNIDADE DE MEDIDA
  ***********************************}
  iIdUM := TM900FAUnMedida(UnidMed);

  If (slinDesc2 <> '') then
  begin
    GravaLog('EP9FA_CargarTextoExtra - Linha 2 ->');
    iRet := EP9FA_CargarTextoExtra(slinDesc2);
    GravaLog('EP9FA_CargarTextoExtra <- iRet [' + IntToStr(iRet) + ']');
    iRet := TM900FACodError(iRet);
  end;

  If (iRet = EP9FA_TagSucesso) AND (slinDesc3 <> '') then
  begin
    GravaLog('EP9FA_CargarTextoExtra - Linha 3 ->');
    iRet := EP9FA_CargarTextoExtra(slinDesc3);
    GravaLog('EP9FA_CargarTextoExtra <- iRet [' + IntToStr(iRet) + ']');
    iRet := TM900FACodError(iRet);
  end;

  If (iRet = EP9FA_TagSucesso) then
  Begin
    GravaLog(' EP9FA_ImprimirItem -> ');
    iRet := EP9FA_ImprimirItem(200,slinDesc1,qtde,vlrunit,iIdIVA,iIdII,sAlqII,1,codigo,Space(1),iIdUM);
    GravaLog(' EP9FA_ImprimirItem <- iRet [' + IntToStr(iRet) + ']');

    if (bDesconto) AND (TM900FACodError(iRet) = EP9FA_TagSucesso) then
    begin
      vlrdesconto := FormataTexto( vlrdesconto, 12, 4, 1 );
      GravaLog(' EP9FA_ImprimirItem - Inserção de desconto no item -> ');
      iRet := EP9FA_ImprimirItem(206,'en el ITEM','00001.0000',vlrdesconto,iIdIVA,iIdII,'000000000.0000',1,codigo,Space(1),iIdUM);
      GravaLog(' EP9FA_ImprimirItem <- iRet [' + IntToStr(iRet) + ']');
    end;
  end;

  If TM900FACodError(iRet) <> EP9FA_TagSucesso
  then sRet := '1|';

  Result := sRet;

  GravaLog(' RegistraItem - Retorno : ' + Result );
end;

function ImpEpsonT900FA.ReImpCupomNaoFiscal(Texto: String): String;
begin
  Result := '0|';
end;

function ImpEpsonT900FA.ReImprime: String;
begin
  Result := '0|';
end;

function ImpEpsonT900FA.RelatorioGerencial(Texto: String; Vias: Integer;
  ImgQrCode: String): String;
var
  i :Integer;
  sRet,sTexto,sLinha :String;
begin
  Result := '0|';

  //verifica a quantidade de vias
  if Vias > 1 then
  Begin
    sTexto := Texto;
    i:=1;
    While i < Vias do
    Begin
        Texto:= Texto + sTexto;
        Inc(i);
    End;
  End;

  // Abre o cupom não fiscal
  sRet := AbreCupomNaoFiscal('','', '', '');
  If Copy(sRet, 1, 1) = '0' then
  begin
    sRet := TextoNaoFiscal('***********Relatorio Gerencial***********', 1);

    // Laço para imprimir toda a mensagem
    While ( Trim(Texto)<>'' ) do
    Begin
       sLinha := '';

       // Laço para pegar 40 caracter do Texto
       For i:= 1 to 40 do
       Begin
         // Caso encontre um CHR(10) (Line Feed) imprime a linha
         If Copy(Texto,i,1) = #10
         then Break;

         sLinha := sLinha + Copy(Texto,i,1);
       end;
       
       sLinha := Copy(sLinha+space(40),1,40);
       Texto  := Copy(Texto,i+1,Length(Texto));

       //imprime texto nao fiscal
       sRet   := TextoNaoFiscal(sLinha, 1);

       // Ocorreu erro na impressão do cupom
       if Copy(sRet, 1, 1) <> '0' then
       begin
         GravaLog(' Erro na impressão do texto não fiscal - Conteudo [' + sLinha + ']');
         Exit;
       end;
    End;

    //fecha o cupom nao fiscal
    sRet := FechaCupomNaoFiscal();
  end;

  If Copy(sRet, 1, 1) = '0'
  then Result := '0|'
  Else Result := '1|';

  GravaLog('ImpEpsonT900FA - RelatorioGerencial - Retorno : ' + Result );
end;

function ImpEpsonT900FA.Status(Tipo: Integer; Texto: String): String;
begin
 Result := '0';
end;

function ImpEpsonT900FA.StatusImp(Tipo: Integer): String;
var
  sTemp,sRetPad,sDataMov,sDataHoje : String;
  iRet,iTemp,iRTemp,iX : Integer;
  aResp: array [0..65536] of Byte;
begin
  sRetPad := '1';
  //Tipo - Indica qual o status quer se obter da impressora
  //  1 - Obtem a Hora da Impressora
  //  2 - Obtem a Data da Impressora
  //  3 - Verifica o Papel
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  //  5 - Cupom Fechado ?
  //  6 - Ret. suprimento da impressora
  //  7 - ECF permite desconto por item
  //  8 - Verifica se o dia anterior foi fechado
  //  9 - Verifica o Status do ECF
  // 10 - Verifica se todos os itens foram impressos.
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  // 16 - Verifica se exige o extenso do cheque
  // 17 - Información sobre los contadores de documentos fiscales y no fiscales
  // 18 - Verifica Grande Total (RICMS 01 - SC - ANEXO 09)
  // 19 - Retorna a data do movimento da impressora
  // 20 - Retorna o CNPJ( CUIT ) cadastrado na impressora
  // 45  - Modelo Fiscal
  // 46 - Marca, Modelo e Firmware

 // Leitura da Hora
 if Tipo = 1 then
 begin
    iTemp := 60;
    GravaLog(' EP9FA_ConsultarFechaHora -> ');
    iRet := EP9FA_ConsultarFechaHora(aResp[0],iTemp);
    GravaLog(' EP9FA_ConsultarFechaHora <- iRet [' + IntToStr(iRet) + ']');

    If TM900FACodError(iRet) = EP9FA_TagSucesso then
    begin
      sTemp := '';
      For iRet := 0 to Pred(iTemp) do
        If CHR(aResp[iRet]) <> #0
        then sTemp := sTemp + CHR(aResp[iRet]);

      Result := '0|' + Copy(sTemp,8,2)+':'+Copy(sTemp,10,2)+':'+Copy(sTemp,12,2);
    end
    else Result := '1|';
 end
 // Faz a leitura da Data
 else if Tipo = 2 then
 begin
    iTemp := 60;
    GravaLog(' EP9FA_ConsultarFechaHora -> ');
    iRet := EP9FA_ConsultarFechaHora(aResp[0],iTemp);
    GravaLog(' EP9FA_ConsultarFechaHora <- iRet [' + IntToStr(iRet) + ']');

    If TM900FACodError(iRet) = EP9FA_TagSucesso then
    begin
      sTemp := '';
      For iRet := 0 to Pred(iTemp) do
        If CHR(aResp[iRet]) <> #0
        then sTemp := sTemp + CHR(aResp[iRet]);

      Result := '0|' + Copy(sTemp,1,2)+'/'+Copy(sTemp,3,2)+'/'+Copy(sTemp,5,2);
    end
    else Result := '1|';
 end
 // Faz a checagem de papel
 else if Tipo = 3 then
 begin
   iTemp := -1;
   GravaLog(' EP9FA_ConsultarEstado -> 7004');
   iRet := EP9FA_ConsultarEstado(7004,iTemp);
   GravaLog(' EP9FA_ConsultarEstado <- iRet [' + IntToStr(iRet) + ']');

   If TM900FACodError(iRet) = EP9FA_TagSucesso then
   begin
     GravaLog(' Comando executado com sucesso ');
     Result := IntToStr(iTemp) + '|';
   end
   else
   begin
     Result := '1|';
   end;
 end
 //Verifica se é possível cancelar um ou todos os itens.
 else if Tipo = 4 then
   result:= '0|TODOS'
 //5 - Cupom Fechado ?
 else if Tipo = 5 then
 begin
   iTemp := -1;
   GravaLog(' EP9FA_ConsultarEstado -> ');
   iRet := EP9FA_ConsultarEstado(1003,iTemp);
   GravaLog(' EP9FA_ConsultarEstado <- iRet [' + IntToStr(iRet) + ']');

   If TM900FACodError(iRet) = EP9FA_TagSucesso then
   begin
     GravaLog(' Comando executado com sucesso ');
     if iTemp > 0
     then Result := '7|' //ABERTO
     else Result := '0|';
   end
   else
   begin
     Result := '1';
   end;
 end
 //6 - Ret. suprimento da impressora
 else if Tipo = 6 then
   result := '0|0.00'
 //7 - ECF permite desconto por item
 else if Tipo = 7 then
   result := '0|'
 //8 - Verica se o dia anterior foi fechado
 else if Tipo = 8 then
 begin
   Result := '0|';

   sTemp := EnvCmd('080A|0000|83',0); //080A - Esta em Hexadecimal -> Captura Informações da Jornada Fiscal
   If Copy(sTemp,1,1) = '0' then
   begin
     iTemp := 1;
     iRTemp:= -1;
     GravaLog(' EP9FA_ObtenerRespuestaExtendida -> 4');
     iRet := EP9FA_ObtenerRespuestaExtendida(4,aResp[0],iTemp,iRTemp);
     GravaLog(' EP9FA_ObtenerRespuestaExtendida <- iRet: ' + IntToStr(iRet) + ']');

     If TM900FACodError(iRet) = EP9FA_TagSucesso then
     begin
       sTemp := '';

       For iTemp := 0 to Pred(iRTemp) do
          sTemp := sTemp + CHR(aResp[iTemp]);

       If sTemp = 'S' then
       begin
          GravaLog('Epson TM900FA - NECESSÁRIO IMPRESSÃO DE REDUÇÃO Z');
          Result := '10'; //Red Z pendente
       end
       else
          GravaLog('Epson TM900FA - Sem pendência de Redução Z');
     end;
   end;
 end
 //9 - Verifica o Status do ECF
 else if Tipo = 9 Then
   result := '1|'
 //10 - Verifica se todos os itens foram impressos.
 else if Tipo = 10 Then
   result := '1|'
 //11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
 else if Tipo = 11 Then
   result := '1'
 // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
 else if Tipo = 12 then
   result := '0|'
 // 13 - Verifica se o ECF Arredonda o Valor do Item
 else if Tipo = 13 then
   result := '1|'
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
 else if Tipo = 14 then
   result := '0'
 // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
 else if Tipo = 15 then
   result := '1|'
 // 16 - Verifica se exige o extenso do cheque
 else if Tipo = 16 then
   result := '1|'
 // 17 - Información sobre los contadores de documentos fiscales y no fiscales
 else if Tipo = 17 then
 begin
   Result := '0|';

   //Número del último Tique impreso o Factura B,C o Tique-Factura B,C
   sTemp := Space(60);
   GravaLog(' ConsultarNumeroComprobanteUltimo -> Tipo B');
   iRet := EP9FA_ConsultarNumeroComprobanteUltimo('82',sTemp,Length(sTemp)); //TIQUE FACTURA B
   GravaLog(' ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
   sTemp := Trim(sTemp);

   If StrToInt(sTemp) = 0 then
   begin
     sTemp := Space(60);
     GravaLog(' ConsultarNumeroComprobanteUltimo -> Tipo C');
     iRet := EP9FA_ConsultarNumeroComprobanteUltimo('111',sTemp,Length(sTemp)); //TIQUE FACTURA C
     GravaLog(' ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
   End;

   Result := Result + chr(28) + chr(28) + Trim(sTemp);

   // Número del último Tique-Factura A o Factura A impreso
   sTemp := Space(60);
   GravaLog(' ConsultarNumeroComprobanteUltimo -> Tipo A');
   iRet := EP9FA_ConsultarNumeroComprobanteUltimo('81',sTemp,Length(sTemp)); //TIQUE FACTURA A
   GravaLog(' ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
   Result := Result + chr(28) + chr(28) + Trim(sTemp);

   // Número de último comprobante Tique-Nota de Crédito o Nota de Crédito ‘B’ o ‘C’ emitido
   sTemp := Space(60);
   GravaLog(' ConsultarNumeroComprobanteUltimo -> Nota de Credito B');
   iRet := EP9FA_ConsultarNumeroComprobanteUltimo('113',sTemp,Length(sTemp)); //Nota de Credito B
   GravaLog(' ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
   sTemp := Trim(sTemp);

   If StrToInt(sTemp) = 0 then
   begin
     sTemp := Space(60);
     GravaLog(' ConsultarNumeroComprobanteUltimo -> Nota de Credito C');
     iRet := EP9FA_ConsultarNumeroComprobanteUltimo('114',sTemp,Length(sTemp)); //Nota de Credito C
     GravaLog(' ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
   End;
   Result := Result + chr(28) + chr(28) + Trim(sTemp);

   // Número de último comprobante Tique-Nota de Crédito o Nota de Crédito ‘A’ emitido
   sTemp := Space(60);
   GravaLog(' ConsultarNumeroComprobanteUltimo -> Tique-Nota de Crédito o Nota de Crédito "A" ');
   iRet := EP9FA_ConsultarNumeroComprobanteUltimo('112',sTemp,Length(sTemp)); //Tique-Nota de Crédito o Nota de Crédito "A"
   GravaLog(' ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
   Result := Result + chr(28) + Trim(sTemp);

   // Número del último número de referencia para Documentos No Fiscales o No Fiscales homologados emitido
   sTemp := Space(60);
   GravaLog(' ConsultarNumeroComprobanteUltimo -> Documento no fiscal homologado genérico ');
   iRet := EP9FA_ConsultarNumeroComprobanteUltimo('910',sTemp,Length(sTemp)); //Documento no fiscal homologado genérico
   GravaLog(' ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
   sTemp := Trim(sTemp);

   If StrToInt(sTemp) = 0 then
   begin
     sTemp := Space(60);
     GravaLog(' ConsultarNumeroComprobanteUltimo -> Documento no fiscal homologado de uso interno ');
     iRet := EP9FA_ConsultarNumeroComprobanteUltimo('950',sTemp,Length(sTemp)); //Documento no fiscal homologado de uso interno.
     GravaLog(' ConsultarNumeroComprobanteUltimo <- iRet [' + IntToStr(iRet) + ']');
   end;

   Result := Result + chr(28) + Trim(sTemp);
 end
 // 18 - Verifica Grande Total (RICMS 01 - SC - ANEXO 09)
 else if Tipo = 18 then
   result := '1'
 // 19 - Retorna a data do movimento da impressora
 else if Tipo = 19 then
 begin
   Result := '-1';

   sTemp := EnvCmd('080A|0000|83',0); //080A - Esta em Hexadecimal -> Captura Informações da Jornada Fiscal
   If Copy(sTemp,1,1) = '0' then
   begin
     iTemp := 6;
     iRTemp:= -1;
     GravaLog(' EP9FA_ObtenerRespuestaExtendida -> 1');
     iRet := EP9FA_ObtenerRespuestaExtendida(1,aResp[0],iTemp,iRTemp);
     GravaLog(' EP9FA_ObtenerRespuestaExtendida <- iRet: ' + IntToStr(iRet) + ']');

     If TM900FACodError(iRet) = EP9FA_TagSucesso then
     begin
       sDataMov := '';
       sDataHoje:= '';

       For iTemp := 0 to Pred(iRTemp) do
          If CHR(aResp[iTemp]) <> #0
          then sDataMov := sDataMov + CHR(aResp[iTemp]);

       sDataHoje := StatusImp(2);
       sDataHoje := Copy(sDataHoje,3,Length(sDataHoje));

       If Trim(sDataMov) = '' then
       begin
         Result := '2|' + sDataHoje;
       end
       else
       begin
         sDataMov  := Copy(sDataMov,1,2)+'/'+Copy(sDataMov,3,2)+'/'+Copy(sDataMov,5,2);
         GravaLog('Data de Movimento :' + sDataMov);
         If (StrToDate(sDataMov) < StrToDate(sDataHoje)) // reducao pendente
         then Result := '0|'+ sDataMov
         Else Result := '2|'+ sDataHoje;
       end;
     end;
   end;
 end
 // 20 - Retorna o CNPJ( CUIT ) cadastrado na impressora
 else if Tipo = 20 then
 begin
   sTemp := EnvCmd('0507|0000',0);
   If Copy(sTemp,1,1) = '0' then
   begin
     iRTemp:= 0;
     iTemp := 11;
     sTemp := Space(iTemp);
     GravaLog(' EP9FA_ObtenerRespuestaExtendida -> ');
     iRet := EP9FA_ObtenerRespuestaExtendida(2,aResp[0],iTemp,iRTemp);
     GravaLog(' EP9FA_ObtenerRespuestaExtendida <- iRet: ' + IntToStr(iRet) + ']');

     If TM900FACodError(iRet) = EP9FA_TagSucesso then
     begin
        sTemp := '';
        For iX := 0 to Pred(iRTemp) do
          If CHR(aResp[iX]) <> #0
          then sTemp := sTemp + CHR(aResp[iX]);

        Result := '0|' + sTemp;
        GravaLog(' Retorno do CUIT (CNPJ) da Impressora [' + sTemp + ']');
     end
     else
     begin
       GravaLog(' Erro ao tentar capturar o CUIT(CNPJ) da Impressora  ');
     end;
   end
   else
   begin
     GravaLog('Erro ao tentar capturar o numero de CUIT(CNPJ) do ECF');
     Result := '1|';
   end;
 end
 else If Tipo = 45 then
   Result := '0|'// 45 Codigo Modelo Fiscal
 else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
   Result := '0|'
 else
   Result := '1|';

 If Trim(Result) = ''
 then Result := sRetPad;

 GravaLog(' StatusImp : ' + IntToStr( Tipo ) + '  - Retorno => ' + Result ) ;

end;

function ImpEpsonT900FA.SubTotal(sImprime: String): String;
var
  iRet,iX,iIndCmd : Integer;
  sSubTotal,sTotalIVA,sTotalPago,
  sEstImpres,sRet,sAux,sTpDoc,sCmd : String;
  aResp : array [0..65536] of Byte;
  bCmdTique,bCmdTqFac,bCmdNTCred : Boolean;
begin
  GravaLog('Inicio da função SubTotal');
  sRet := '1|';
  sTpDoc := TM900FACompAtual();
  bCmdTique := False;
  bCmdTqFac := False;
  bCmdNTCred:= False;

  If sTpDoc <> '' then
  begin
    //Para tipo : Tique ou Tique Nota de Credito
    If (sTpDoc = '83') OR (sTpDoc = '110') then
    begin
      sCmd := '0A0A|0000';
      bCmdTique := True;
    end;

    //Para tipo : Tique-Factura ou Nota de Debito - A/B/C/M
    If (sTpDoc = '81') OR (sTpDoc = '82') OR (sTpDoc = '111') OR
       (sTpDoc = '115') OR (sTpDoc = '116') OR (sTpDoc = '117') OR
       (sTpDoc = '118') OR (sTpDoc = '120') then
    begin
      sCmd := '0B0A|0000';
      bCmdTqFac := True;
    end;

    //Para tipo : Tique-Nota de Credito A/B/C/M
    If (sTpDoc = '112') OR (sTpDoc = '113') OR (sTpDoc = '114') OR
       (sTpDoc = '119') then
    begin
      sCmd := '0D0A|0000';
      bCmdNTCred := True;
    end;

    sAux := EnvCmd(sCmd,0);
    If Copy(sAux,1,1) = '0' then
    begin
      iIndCmd := 3;
      If bCmdTique
      then iIndCmd := 2;
      sSubTotal := Trim(TM900FACmdExcRet('',iIndCmd,0,False,aResp));
      iX := Length(sSubTotal);
      If (sSubTotal = '') Or (StrToFloat(sSubTotal) = 0)
      then sSubTotal := '00.00'
      else sSubTotal := Copy(sSubTotal,1,iX-2)+'.'+ Copy(sSubTotal,iX-1,iX);

      iIndCmd := 5;
      If bCmdTique
      then iIndCmd := 4;
      sTotalIVA := Trim(TM900FACmdExcRet('',iIndCmd,0,False,aResp));
      iX := Length(sTotalIVA);
      If (sTotalIVA = '') Or (StrToFloat(sTotalIVA) = 0)
      then sTotalIVA := '00.00'
      else sTotalIVA := Copy(sTotalIVA,1,iX-2)+'.'+ Copy(sTotalIVA,iX-1,iX);

      iIndCmd := 4;
      If bCmdTique
      then iIndCmd := 3;
      sTotalPago := Trim(TM900FACmdExcRet('',iIndCmd,0,False,aResp));
      iX := Length(sTotalPago);
      If (sTotalPago = '') Or (StrToFloat(sTotalPago) = 0)
      then sTotalPago := '00.00'
      else sTotalPago := Copy(sTotalPago,1,iX-2)+'.'+ Copy(sTotalPago,iX-1,iX);

      iIndCmd := 18;
      If bCmdTique
      then iIndCmd := 14;
      sEstImpres := Trim(TM900FACmdExcRet('',iIndCmd,0,False,aResp));
      If sEstImpres = ''
      then sEstImpres := Space(1);

      sRet := '0|';

      //Campo 1 - Estado da Impressora
      iRet := EP9FA_ObtenerEstadoImpresora();
      iRet := TM900FACodError(iRet,False);
      sRet := sRet + IntToStr(iRet) + #28;

      //Campo 2 - Estado Fiscal
      iRet := EP9FA_ObtenerEstadoFiscal();
      iRet := TM900FACodError(iRet,False);
      sRet := sRet + IntToStr(iRet) + #28;

      //Campo 3 - Estado da Impressão (Fase)
      sRet := sRet + sEstImpres + #28;

      //Campo 4 - (sub)total da venda
      sRet := sRet + sSubTotal + #28;

      //Campo 5 - total de IVA
      sRet := sRet + sTotalIVA + #28;

      //Campo 6 - ( não identificado )
      sRet := sRet + '0.00' + #28;

      //Campo 7 - Total Pago; //Envio o mesmo valor pois o protheus n usa essa posição
      sRet := sRet + sTotalPago + #28;
    end;
    
  end;

  Result := sRet;
end;

function ImpEpsonT900FA.Suprimento(Tipo: Integer; Valor, Forma,
  Total: String; Modo: Integer; FormaSupr: String): String;
Var
  sRet: string;
  aAuxiliar : TaString;
  i   : Integer;
begin
  i:= 0;
  MontaArray( FormaSupr, aAuxiliar );

  if Tipo = 1 then
  begin
    GravaLog('Função não disponível para este equipamento');
    sRet := '0|';
  end
  else if Tipo = 2 then
  begin
    sRet := AbreCupomNaoFiscal('','', '', '');
    if sRet = '0|' then
    begin
      If Forma = ''
      then Forma := 'Efectivo';

      sRet := TextoNaoFiscal('*************FUNDO DE TROCO**************', 1);
      sRet := TextoNaoFiscal(Valor + ' - ' + Forma, 1);
    end;

    if sRet = '0|'
    then sRet := FechaCupomNaoFiscal();
  end
  else if Tipo = 3 then
  begin
    sRet := AbreCupomNaoFiscal('','', '', '');
    if sRet = '0|' then
    begin
      sRet := TextoNaoFiscal('*****************SANGRIA*****************', 1);
      While i < Length(aAuxiliar) do
      begin
        sRet := TextoNaoFiscal(aAuxiliar[i + 1] + ' - ' + aAuxiliar[i],1);
        Inc(i,2)
      end;
    end;

    if sRet = '0|'
    then sRet := FechaCupomNaoFiscal();
  end;

  Result := sRet;
  GravaLog('ImpEpsonT900FA - Suprimento  - Retorno :' + Result ) ;
end;

function ImpEpsonT900FA.TextoNaoFiscal(Texto: String;
  Vias: Integer): String;
Var
  sCmd: string;
  nX,iRet  : Integer;
  oLista : TStringList;
begin
  nX := 0;
  Result := '0';
  iRet := 0;
  oLista := TStringList.Create;
  oLista.Clear;

  If Vias > 1 then
  begin
    sCmd := Texto;
    nX := 1;
    while nX < Vias do
    begin
      Texto := Texto + sCmd;
      Inc(nX);
    end;
  end;

  nX := Pos(#$A,Texto);
  while nX > 0 do
  begin
    If nX = 1
    Then Texto := ''
    Else If nX > 1 then
    begin
      sCmd   := Copy(Texto,1,nX);
      oLista.Add(sCmd);
      Texto  := Copy(Texto,nX+1,length(Texto));
    end;

    nX := Pos(#$A,Texto);
  end;

  If Trim(Texto) <> '' then
  begin
    oLista.Add(Texto);
    Texto := '';
  end;

  For nX := 0 to Pred(oLista.Count) Do
  begin
    GravaLog(' EP9FA_ImprimirTextoLibre -> Linha [' +
             IntToStr(nX) + '] - CONTEUDO [' +  oLista.Strings[nX] + ']');
    iRet := EP9FA_ImprimirTextoLibre(oLista.Strings[nX]);
    GravaLog(' EP9FA_ImprimirTextoLibre <- iRet [' + IntToStr(iRet) + ']' );
  End;

  If TM900FACodError(iRet) <> EP9FA_TagSucesso then
  begin
    GravaLog(' Erro na impressão do texto não fiscal ');
    Result := '1';
  end;

  GravaLog(' ImpEpsonT900FA - TextoNaoFiscal - Retorno : ' + Result );
end;

function ImpEpsonT900FA.TM900FACodError( iRet : Integer ; bMsg : Boolean = True ): Integer;
begin

Result := 0;

If iRet <> 0 then
begin
  Result := EP9FA_ConsultarUltimoError();
  GravaLog( 'Executou o comando EP9FA_ConsultarUltimoError');

  If (Result > 0) then
  begin
    GravaLog(' Detectado erro na execução do comando anterior- Código do Erro [' + IntToStr(Result) + ']');

    If bMsg
    then TM900FADescErro(Result);
  end;
end;

end;

function ImpEpsonT900FA.TM900FADescErro( CodError : Integer ): String;
var
  respuesta_descripcion : String;
  respuesta_descripcion_largo_maximo: Integer;
begin
  Result := '';
  respuesta_descripcion := '';
  respuesta_descripcion_largo_maximo := 250;
  respuesta_descripcion := Space(respuesta_descripcion_largo_maximo);

  EP9FA_ConsultarDescripcionDeError(CodError,respuesta_descripcion,respuesta_descripcion_largo_maximo);

  If Trim(respuesta_descripcion) <> '' then
  begin
    respuesta_descripcion := Trim(respuesta_descripcion);
    GravaLog(' Retorno da descrição de erro [' + respuesta_descripcion + ']');
    ShowMessage(' Comando con respuesta con error - ' + respuesta_descripcion );
    Result := respuesta_descripcion;
  end;

end;

function ImpEpsonT900FA.TM900FACmdExcRet(sCmd: String; nInd,nTamRet: Integer;
          bExecCmd : Boolean; var aResp: array of Byte): String;
var
  iRet,iTemp,iRTemp : Integer;
  sTemp: String;
begin

  Result:= '';

  If bExecCmd
  then sTemp := EnvCMD(sCmd,0)
  else sTemp := '0';

  If copy(sTemp,1,1) = '0' then
  begin
    iTemp := 60; // coloco um tamanho "padrão"
    if nTamRet > 0
    then iTemp := nTamRet;

    iRTemp:= -1;

    GravaLog(' EP9FA_ObtenerRespuestaExtendida -> ' + IntToStr(nInd));
    iRet := EP9FA_ObtenerRespuestaExtendida(nInd,aResp[0],iTemp,iRTemp);
    GravaLog(' EP9FA_ObtenerRespuestaExtendida <- iRet: ' + IntToStr(iRet) + ']');

    If iRet = 0 then
    begin
      sTemp := '';

      For iTemp := 0 to Pred(iRTemp) do
         If CHR(aResp[iTemp]) <> #0
         then sTemp := sTemp + CHR(aResp[iTemp]);

      Result := sTemp;
    end;
  end;
end;

function ImpEpsonT900FA.TM900FAUnMedida(cUM: string): Integer;
var
  UnidMed :String;
  iIdUM : Integer;
begin
  UnidMed:= Trim(cUM);
  iIdUM := 0; //Padrão Sin Descripcion

  If UnidMed = 'KG'
  then iIdUM := 1;

  If UnidMed = 'MT'
  then iIdUM := 2;

  If UnidMed = 'M2'
  then iIdUM := 3;

  If UnidMed = 'M3'
  then iIdUM := 4;

  If UnidMed = 'L'
  then iIdUM := 5;

  If UnidMed = 'UN'
  then iIdUM := 7;

  If UnidMed = 'P'
  then iIdUM := 8;

  If UnidMed = 'G'
  then iIdUM := 14;

  If UnidMed = 'MM'
  then iIdUM := 15;

  If UnidMed = 'CM'
  then iIdUM := 20;

  If UnidMed = 'TL'
  then iIdUM := 29;

  If UnidMed = 'ML'
  then iIdUM := 47;

  If UnidMed = 'GZ'
  then iIdUM := 54;

  Result := iIdUM;
end;

function ImpEpsonT900FA.TM900FACodIVA(sAliq: String): Integer;
var
  iValIVA : Currency;
  iIdIVA : Integer;
begin
  iValIVA := StrToFloat(sAliq);
  iIdIVA := 0;
  
  If iValIVA = 0
  then iIdIVA := 0;

  If iValIVA = 10.50
  then iIdIVA := 4;

  If iValIVA = 21
  then iIdIVA := 5;

  Result := iIdIVA;
end;

function ImpEpsonT900FA.TM900FACodII(sValor: String; var sAliq: String): Integer;
var
  iValII : Currency;
  iIdII : Integer;
begin
  iValII := StrToFloat(sValor);
  if iValII = 0 then
  begin
    iIdII := 0;
    sAliq := '00.00';
  end
  else
  begin
    If iValII > 1 then //Envio do valor
    begin
      iIdII := 1;
      sAliq := FormataTexto(FloatToSTr(iValII),11,4,5);
    end
    else //Envio do percentual
    begin
      iIdII := 2;
      sAliq := FormataTexto(FloatToSTr(iValII),9,8,5);
    end;
  end;

  Result := iIdII;
end;

function ImpEpsonT900FA.TM900FACompAtual: String;
var
  iRet : Integer;
  str_comprobante_tipo : String;
begin
  str_comprobante_tipo := Space(60);
  GravaLog(' EP9FA_ConsultarTipoComprobanteActual -> ');
  iRet := EP9FA_ConsultarTipoComprobanteActual(str_comprobante_tipo, Length(str_comprobante_tipo));
  GravaLog(' EP9FA_ConsultarTipoComprobanteActual <- iRet [' + IntToStr(iRet) + '] / TipoComp [' + str_comprobante_tipo + ']');

  If iRet = EP9FA_TagSucesso
  then Result := Trim(str_comprobante_tipo)
  else
  begin
    iRet := TM900FACodError(iRet);
    Result := '';
  end;

  GravaLog(' TM900FACompAtual - Result [' + Result + ']');
end;

initialization
  RegistraImpressora('EPSON TM-H6000II', ImpEpsonTMH6000II, 'MEX', ' ');
  RegistraImpressora('EPSON TM-U220AF',  ImpEpsonTMU220AF , 'ARG', ' ');
  RegistraImpressora('EPSON TM-300AF+',  ImpEpsonTM300AF  , 'ARG', ' ');
  RegistraImpressora('EPSON TM-2000AF+', ImpEpsonTM300AF  , 'ARG', ' ');
  RegistraImpressora('EPSON TM-T900FA',  ImpEpsonT900FA   , 'ARG', ' ');
  RegistraImpressora('EPSON TM-U220AFII',ImpEpsonT900FA   , 'ARG', ' ');
  RegistraImpCheque ('EPSON TM-H6000II', ChqEpsonTMH6000II, 'MEX');
end.

