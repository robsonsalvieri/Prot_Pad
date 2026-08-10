unit ImpDataRegis;

interface

uses
  Dialogs,
  ImpFiscMain,
  ImpCheqMain,
  Windows,
  SysUtils,
  Classes,
  IniFiles,
  LojxFun,
  Forms,
  ComDrv32,
  SyncObjs;

Type
////////////////////////////////////////////////////////////////////////////////
///  Thread
///
  TMyThread = class(TThread)
  private
    Comandos : TStringList;
    NumItems : Integer;
    NumCupom : AnsiString;
    NovoCupom : Boolean;
    procedure AddList(sComando : AnsiString);
  protected
    procedure Execute; override;
    procedure RegistraItem;
    procedure CheckResume;
  published
    constructor Create;
    destructor Destroi;
  public
  end;

  TStatusThread = class(TThread)
  protected
    procedure Execute; override;
  published
    constructor Create;
  public
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal DataRegis
///
  TImpFiscalDriver = class(TCommPortDriver)
    protected
      FBuffer: TMemoryStream;
      FCriticalSection: TCriticalSection;
      FReading: boolean;
      OnError : Boolean;
      LastCmd : AnsiString;
      LastRet : AnsiString;
      LastItem: AnsiString;
      Using   : Boolean;
      OnPaperError: Boolean;
      Desconto: AnsiString;
      ITCanc : Integer;
      procedure DoReceiveData(Sender: TObject; DataPtr: Pointer; DataSize: cardinal);
      procedure BeginUpdateBuffer;
      procedure EndUpdateBuffer;
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

  TImpFiscalDataRegis = class(TImpressoraFiscal)
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function AbreEcf:AnsiString; override;
    function FechaEcf:AnsiString; override;
    function LeituraX:AnsiString; override;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function PegaPDV:AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function LeAliquotas:AnsiString; override;
    function LeAliquotasISS:AnsiString; override;
    function LeCondPag:AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString;Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function Gaveta:AnsiString; override;
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString; override;
    function Status( Tipo:Integer; Texto:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    procedure AlimentaProperties; override;
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    function HorarioVerao( Tipo:AnsiString ):AnsiString; override;
    function SubTotal (sImprime: AnsiString):AnsiString; override;
    function NumItem:AnsiString; override;
    function PegaSerie:AnsiString; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString):AnsiString; override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override;
    function RedZDado( MapaRes:AnsiString ):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
  end;

  TImpFiscalDataRegis375 = class(TImpFiscalDataRegis)
  public
    procedure AlimentaProperties; override;
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function SubTotal (sImprime: AnsiString):AnsiString; override;
    function NumItem:AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque DataRegis
///
  TImpChequeDataRegis = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Fechar( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;
  TImpChequeDataRegis375 = class(TImpChequeDataRegis)
  public
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
  Function EnviaCmd( sCmd:AnsiString; sDados:AnsiString=''; lIF2:Boolean=False ):AnsiString;
  function Envia( sCmd:AnsiString; sDados:AnsiString='' ):bool;
  function TrataRet( Retorno: Array Of Char ) : AnsiString;
  procedure TrataDados( Texto:AnsiString );
  function ChecaPorta:Boolean;
  function CheckProcess:Boolean;
  function EnviaComando( sCmd:AnsiString; sDados:AnsiString=''; lIF2:Boolean=False ):AnsiString;
  procedure _MontaArray( sTexto:AnsiString; var aFormas:TaString);
  Function TrataTags( Mensagem : AnsiString ) : AnsiString;

//------------------------------------------------------------------------------
implementation

var
  CommDrv : TImpFiscalDriver;
  sCommand: AnsiString;
  MyThread : TMyThread;
  StatusThread : TStatusThread;
  bOpened : Boolean;
  lWritingLOG : Boolean;
  aValores : TAString;
  aForma : TAString;

////////////////////////////////////////////////////////////////////////////////
///  Thread
///
constructor TMyThread.Create;
begin
  inherited Create(True);
  Comandos := TStringList.Create;
  CommDrv.OnError := False;
  CommDrv.OnPaperError := False;
  Priority := tpNormal;
  FreeOnTerminate := True;              // Thread Free Itself when terminated
  Suspended := True;                    // Não Iniciar a Thread agora...
                                        // Somente depois da Abrir.
end;

//------------------------------------------------------------------------------
destructor TMyThread.Destroi;
begin
  Comandos.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------
procedure TMyThread.AddList(sComando : AnsiString);
begin
  // Espere Deletar um Item na MyThread.RegistraItem
  while lWritingLOG do
    Sleep(100);
  // Vou adicionar um Item...
  lWritingLOG := True;
  Comandos.Add(NumCupom+sComando);
  SaveToFile('DREGIS.LOG', Comandos);
  // Já adicionei um Item.
  lWritingLOG := False;
end;

//------------------------------------------------------------------------------
procedure TMyThread.Execute;
begin
  while (Terminated = False) do
  begin
    RegistraItem;
    Sleep(100);
  end;
end;

//------------------------------------------------------------------------------
procedure TMyThread.RegistraItem;
var
  sRet, sNumIT : AnsiString;
begin
  if Comandos.Count > 0 then
  begin
    if CommDrv.OnError Or CommDrv.OnPaperError then
      sRet := '-'
    else
      sRet := EnviaComando('A', Copy(Comandos.Strings[0],7,999));
    Inc(NumItems);
    // Espere Adicionar um Item na MyThread.AddList.
    while lWritingLOG do
      Sleep(100);
    // Vou deletar um Item...
    lWritingLOG := True;
    if Copy(sRet,1,1) = '+' then
    begin
      CommDrv.LastItem := Copy(Comandos.Strings[0],7,999);
      Comandos.Delete(0);
      SaveToFile('DREGIS.LOG', Comandos);
    end
    else
    begin
      sNumIT := FormataTexto(IntToStr(NumItems),3,0,2);
      WriteLog('DREGIS.ERR', Copy(Comandos.Strings[0],1,6)+sNumIT);
      Comandos.Delete(0);
      SaveToFile('DREGIS.LOG', Comandos);
      // Como Cancelou o Item, Aguarde Tentar Reestabelecer o ECF...
      if Not CommDrv.OnPaperError then
        Sleep(2000);
    end;
    // Já deletei o Item.
    lWritingLOG := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TMyThread.CheckResume;
var
  sNumIT : AnsiString;
  i : Integer;
begin
  if FileExists('DREGIS.LOG') then Comandos.LoadFromFile('DREGIS.LOG');
  if Comandos.Count > 0 then
    if Application.MessageBox('Existe Items Pendentes a Serem Impressos no ECF. Deseja Continuar a Impressão?',
    'Detectando Items Pendentes no ECF', MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION) = IDNO then
    begin
      for i := NumItems+1 to NumItems+Comandos.Count do
      begin
        sNumIT := FormataTexto(IntToStr(i),3,0,2);
        WriteLog('DREGIS.ERR', Copy(Comandos.Strings[0],1,6)+sNumIT);
        Comandos.Delete(0);
      end;
      Comandos.Clear;
      SaveToFile('DREGIS.LOG', Comandos);
    end;

  while Comandos.Count > 0 do
    MyThread.RegistraItem;
end;

//------------------------------------------------------------------------------
constructor TStatusThread.Create;
begin
  inherited Create(True);
  Priority := tpNormal;
  FreeOnTerminate := True;              // Thread Free Itself when terminated
  Suspended := False;                   // Continue the thread
end;

//------------------------------------------------------------------------------
procedure TStatusThread.Execute;
var
  iOnError : LongWord;
begin
  iOnError := GetTickCount;
  while (Terminated = False) do
  begin
    // Verifica se o ECF esta fisicamente on-line.
    if (lsDSR in CommDrv.GetLineStatus) then
      iOnError := GetTickCount;

    // Se em 6 segundos o ECF parar de responder, Eh Erro
    if (GetTickCount - iOnError) > 6000 then
      CommDrv.OnError := True
    else
      CommDrv.OnError := False;
    Application.ProcessMessages;
    Sleep(100);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal DataRegis
///
constructor TImpFiscalDriver.Create(AOwner: TComponent);
begin
  inherited;
  FBuffer := TMemoryStream.Create;
  FCriticalSection := TCriticalSection.Create;
end;

//------------------------------------------------------------------------------
destructor TImpFiscalDriver.Destroy;
begin
  FBuffer.Free;
  FCriticalSection.Free;
  inherited;
end;

//------------------------------------------------------------------------------
procedure TImpFiscalDriver.BeginUpdateBuffer;
begin
  FCriticalSection.Enter;
end;

//------------------------------------------------------------------------------
procedure TImpFiscalDriver.EndUpdateBuffer;
begin
  FCriticalSection.Leave;
end;

//------------------------------------------------------------------------------
procedure TImpFiscalDriver.DoReceiveData(Sender: TObject; DataPtr: Pointer; DataSize: cardinal);
var
  s: AnsiString;
  nOldPos: integer;
begin
  with TImpFiscalDriver(Sender) do
  begin
    PausePolling;
    s := '     ';

    ReadData( @s[1], 5 );

    if DataSize > 0 then
    begin
      if not FReading then
      begin
        FReading := True;
        BeginUpdateBuffer;
      end;
      nOldPos := FBuffer.Position;
      FBuffer.Position := FBuffer.Size;
      FBuffer.Write(DataPtr^, DataSize);
      FBuffer.Position := nOldPos;
      if ((pChar(cardinal(DataPtr)+DataSize-1)^ = #13) and (pChar(cardinal(DataPtr)+DataSize-2)^ = #26)) or
         (pChar(cardinal(DataPtr))^ = #6) or ((pChar(cardinal(DataPtr))^ = #4) and (pChar(cardinal(DataPtr)+1)^ = #13)) then
      begin
        FReading := False;
        EndUpdateBuffer;
      end;
    end;

    ContinuePolling;
  end;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
var sRet : AnsiString;
begin
  If Not bOpened Then
  Begin
    bOpened := True;

    CommDrv := TImpFiscalDriver.Create(Application);
    CommDrv.OnReceiveData := CommDrv.DoReceiveData;

    if upperCase(sPorta) = 'COM1' then
      CommDrv.ComPort := pnCOM1
    else if upperCase(sPorta) = 'COM2' then
      CommDrv.ComPort := pnCOM2
    else if upperCase(sPorta) = 'COM3' then
      CommDrv.ComPort := pnCOM3
    else if upperCase(sPorta) = 'COM4' then
      CommDrv.ComPort := pnCOM4
    else if upperCase(sPorta) = 'COM5' then
      CommDrv.ComPort := pnCOM5
    else if upperCase(sPorta) = 'COM6' then
      CommDrv.ComPort := pnCOM6
    else if upperCase(sPorta) = 'COM7' then
      CommDrv.ComPort := pnCOM7
    else
      CommDrv.ComPort := pnCOM8;

    CommDrv.ComPortSpeed := br9600;
    CommDrv.Connect;
  End;

  if lsDSR in CommDrv.GetLineStatus then
  begin
    StatusThread := TStatusThread.Create; // Somente fica olhando a porta do ECF
    MyThread := TMyThread.Create;         // Envia os comandos

    sRet := EnviaComando('C');
    if Copy(sRet,1,2) = '+S' then         // Pega Numero de Items Impressos
      MyThread.NumItems := StrToInt(Copy(sRet,17,3))
    else
      MyThread.NumItems := 0;

    sRet := EnviaComando('d');            // Pega Numero do Cupom
    if Copy(sRet,1,1) = '+' then
      MyThread.NumCupom := Copy(sRet,17,6);

    AlimentaProperties;

    MyThread.CheckResume;
    MyThread.Resume;                      // Iniciar a Thread da IFRegItem.
    Result := '0';
  end
  else
    Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  if not (StatusThread = nil) then
  begin
    StatusThread.Terminate;
    StatusThread.WaitFor;
  end;
  if not (MyThread = nil) then
  begin
    MyThread.Terminate;
    MyThread.WaitFor;
  end;
  If bOpened Then
  Begin
    bOpened := False;
    CommDrv.Disconnect;
    CommDrv.Free;
    CommDrv := NIL;
  End;
  Result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.LeituraX : AnsiString;
var
  sRet : AnsiString;
begin
  Result := '1';
  MsgLoja('Aguarde a Impressão da Leitura X...');
  sRet := EnviaComando( 'G','NN' );
  if Copy(sRet,1,1)='+' then
  begin
    Sleep(20000);
    // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
    // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
    sRet := EnviaComando('d');            // Pega Numero do Cupom
    if Copy(sRet,1,1) = '+' then
      MyThread.NumCupom := Copy(sRet,17,6);
    Result := '0';
  end;
  MsgLoja;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.ReducaoZ( MapaRes:AnsiString ) : AnsiString;
var
  sRet : AnsiString;
begin
  Result := '1';
  MsgLoja('Aguarde a Impressão da Redução Z...');
  sRet := EnviaComando( 'H','N' );
  if Copy(sRet,1,1)='+' then
  begin
    Sleep(40000);
    // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
    // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
    sRet := EnviaComando('d');            // Pega Numero do Cupom
    if Copy(sRet,1,1) = '+' then
      MyThread.NumCupom := Copy(sRet,17,6);
    Result := '0';
  end;
  MsgLoja;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.LeAliquotas:AnsiString;
begin
  result := '0|' + ICMS;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.LeAliquotasISS:AnsiString;
begin
  result := '0|' + ISS;
end;

//---------------------------------------------------------------------------
function TImpFiscalDataRegis.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.LeCondPag:AnsiString;
begin
  result := '0|' + FormasPgto;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
begin
  // Se o ECF esta em erro, abortar
  if CommDrv.OnError Or CommDrv.OnPaperError Or (MyThread.Comandos.Count > 0) then
  begin
    Result := '1';
    Exit;
  end;

  MyThread.NumItems  := 0;
  // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
  // Abrir Cupom, Leitura X e Redução Z.
  MyThread.NumCupom  := FormataTexto(IntToStr(StrToInt(MyThread.NumCupom)+1),6,0,2);
  MyThread.NovoCupom := True;
  // Registrar o Desconto no Total junto com a finalização do cupom.
  CommDrv.Desconto   := '0000000000000';
  CommDrv.LastItem   := '';
  // Quando Cancela um Item na IF2, Ela Considera o Cancelamento Como um Item... 
  CommDrv.ITCanc     := 0;
  Result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.PegaCupom(Cancelamento:AnsiString):AnsiString;
begin
  Result := '0|'+MyThread.NumCupom;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.PegaPDV:AnsiString;
var
  sRet : AnsiString;
begin
  sRet := EnviaComando( 'P','S' );
  if copy(sRet,1,1) = '+' then
    result := '0|' + copy(sRet,8,3)
  else
    result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  sRet : AnsiString;
begin
  Result := '1';
  sRet := EnviaComando( 'B', Replicate(' ', 57) );
  if Copy(sRet,1,1)='+' then
  begin
    // Quando Cancela um Item na IF2, Ela Considera o Cancelamento Como um Item... 
    CommDrv.ITCanc := CommDrv.ITCanc + 2;
    Result := '0';
  end;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.CancelaCupom( Supervisor:AnsiString ):AnsiString;
var
  sRet : AnsiString;
  lFechaCup : Boolean;
begin
  MsgLoja('Aguarde o Cancelamento do Cupom Fiscal...');
  Result := '1';
  // Na impressora IF/2 não existe o comando de cancelar o cupom aberto, então é emitido
  // o comando de efetuar pagamento com valor 0 (zero) para fechar o cupom e então é
  // feito o cancelamento.
  sRet := EnviaComando( 'R' );
  if Copy(sRet,1,1) = '+' then
  begin
    lFechaCup := False;
    if Pos(Copy(sRet,2,1),'V,F') > 0 then                   // Cupom Aberto???
      lFechaCup := True;
    CommDrv.OnPaperError := (Pos('P', sRet) > 0);           // Tem Papel???
    if Not CommDrv.OnPaperError then
    begin
      if lFechaCup then
      begin
        sRet := EnviaComando( 'D', Replicate('0',34) );
        If Copy(sRet,1,1)='+' then
          Sleep(2000)
        else
        begin
          MsgLoja;
          Exit;
        end;
      end;
      sRet := EnviaComando( 'R' );
      if Copy(sRet,Length(sRet),1)='P' then
      begin
        MsgLoja;
        Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
          'Falta de Papel', MB_OK + MB_ICONERROR);
        MsgLoja('Aguarde o Cancelamento do Cupom Fiscal...');
      end;

      sRet := EnviaComando( 'F' );
      Sleep(5000);
      if Copy(sRet,1,1) <> '+' then
      begin
        sRet := EnviaComando( 'F' );
        Sleep(5000);
      end;
      if Copy(sRet,1,1) = '+' then
      begin
        // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
        // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
        sRet := EnviaComando('d');            // Pega Numero do Cupom
        if Copy(sRet,1,1) = '+' then
          MyThread.NumCupom := Copy(sRet,17,6);
        Result := '0';
      end;
    end;
  end;
  MsgLoja;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sRet : AnsiString;
  sSituacao : AnsiString;
  pDesc : AnsiString;
  nVlrTotal, nDesc, nVlrDesc, nVlrDescOK : Real;
  sDados : AnsiString;
  sAliq : AnsiString;
  aAliq : TaString;
  sTributo : AnsiString;
  i,iPos : Integer;
  lOk : Boolean;
begin
  sRet := EnviaComando( 'R' );
  if Copy(sRet,1,1) = '+' then
  begin
    if (Not CommDrv.OnError) And CommDrv.OnPaperError then
    begin
      sRet := EnviaComando('R');
      if Copy(sRet,Length(sRet),1)='K' then
        CommDrv.OnPaperError := False;
    end;

    // Se o ECF esta em erro, abortar
    if CommDrv.OnError Or CommDrv.OnPaperError then
    begin
      Result := '1';
      Exit;
    end;

    //verifica se é para registra a venda do item ou só o desconto
    if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
      result := '11';
      exit;
    end;

    // Trata os pontos decimais
    qtde := StrTran(qtde,',','.');
    vlrUnit := StrTran(vlrUnit,',','.');
    vlrdesconto := StrTran(vlrDesconto,',','.');

    // Faz o tratamento da aliquota
    sSituacao := copy(aliquota,1,1);

    aliquota := StrTran(copy(aliquota,2,5),',','.');

    // o Codigo deve obrigatoriamente começar com 6 numeros.
    // Se nao vier informado um número o código irá iniciar com 0 (zero)
    lOk := False;
    While not lOk do
    begin
      Try
        StrToFloat(copy(codigo+Replicate('.',7),1,7));
        lOk := True;
      Except
        codigo := '0'+codigo;
      end;
    end;

    // Faz a leitura das aliquotas
    sAliq := Aliquotas;

    // Verifica se a aliquota esta cadastrada
    if aliquota = '' then
      aliquota := '0000';
    aliquota := FloatToStrf(StrToFloat(aliquota),ffFixed,18,2);
    _MontaArray( sAliq, aAliq );
    iPos := -1;
    For i:=0 to Length(aAliq) -1 do
      if aAliq[i] = sSituacao+aliquota then
        iPos := i;

    if iPos = -1 then
    begin
      result := '1';
      ShowMessage('Alíquota não cadastrada.');
      exit;
    end;

    if iPos < 10 then
      sTributo := '0' + IntToStr(iPos)
    else
      sTributo := IntToStr(iPos);

    // calcula o percentual do desconto
    if StrToFloat(vlrdesconto) > 0 then
    begin
      // Valor Final que o ECF irá imprimir...
      nVlrTotal  := Int(StrToFloat(vlrUnit)*StrToFloat(qtde)*100)/100;
      // Calcula o Percentual de Desconto...
      nDesc      := StrToFloat(FloatToStrF((StrToFloat(vlrdesconto)/nVlrTotal),ffFixed,18,4))*100;
      // Calcula o Valor do Desconto Para Achar o Valor Exato...
      nVlrDesc   := Int(nVlrTotal*nDesc)/100;
      nVlrDescOK := StrToFloat(vlrdesconto);
      while nVlrDesc < nVlrDescOK do
      begin
        nDesc     := nDesc + 0.01;
        nVlrDesc  := Int(nVlrTotal*nDesc*100)/100;
      end;
      pDesc := FormataTexto(FloatToStrF(nDesc,ffFixed,18,2),4,2,2);
    end
    else
      pDesc := '0000';

    // Monta os dados (parâmetros)
    sDados := copy(codigo+Space(13),1,13) +
              copy(descricao+Space(23),1,23) +
              sTributo +
              FormataTexto(qtde,6,3,2) +
              FormataTexto(vlrUnit,9,2,2) +
              pDesc ;

    MyThread.AddList(sDados);
    sRet := '+';
    result := '0';
  End
  Else
    Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.AbreECF:AnsiString;
var
  sRet : AnsiString;
begin
  sRet := EnviaComando( 'R' );
  if copy(sRet,1,1) = '+' then
  begin
    if copy(sRet,2,1) = 'A' then
    begin
      result := LeituraX;
    end
    else
      result := '0';
    CommDrv.OnPaperError := (Pos('P', sRet) > 0);           // Tem Papel???
  end
  else
    result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.FechaECF : AnsiString;
begin
  Result := ReducaoZ('');
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.Pagamento( Pagamento,Vinculado,Percepcion :AnsiString ): AnsiString;
var
  sRet : AnsiString;
  sForma : AnsiString;
  aAuxiliar : TaString;
  i,x : Integer;
  bErro : Boolean;
begin
  sRet := EnviaComando( 'R' );
  if Copy(sRet,1,1) <> '+' then
  begin
    Result := '1';
    Exit;
  end;
  CommDrv.OnPaperError := (Pos('P', sRet) > 0);           // Tem Papel???

  // Se o ECF esta em erro, abortar
  if CommDrv.OnError Or CommDrv.OnPaperError then
  begin
    MsgLoja;
    Result := '1';
    Exit;
  end;

  Pagamento := StrTran(Pagamento,',','.');

  sForma := LeCondPag;
  sForma := Copy(sForma,3,Length(sForma));
  _MontaArray( sForma,aForma );

  // prepara a array a Valores com o tamanho da aForma
  SetLength( aValores,Length(aForma) );
  // Acrescenta zeros em toda a aValores
  For i:=0 to Length(aValores)-1 do
    aValores[i] := '0';

  // Monta um array auxiliar com os pagamentos solicitados
  Pagamento := StrTran(Pagamento,',','.');
  _MontaArray( Pagamento,aAuxiliar );

  // Verifica se existem todas as formas solicitadas
  i := 0;
  bErro := False;
  While i < Length(aAuxiliar) do
  begin
    if Pos(UpperCase(aAuxiliar[i]),sForma) = 0 then
      bErro := True;
    Inc(i,2);
  end;

  // Abandona a rotina se não encontrar alguma forma de pagamento
  if bErro then
  begin
    MsgLoja;
    result := '1';
    ShowMessage('Foram solicitadas formas de pagamento que não constam no ECF.');
    Exit;
  end;

  // Alimenta a  matriz aValors
  i := 0;
  While i < Length(aAuxiliar) do
  begin
    For x:=0 to Length(aForma)-1 do
      if UpperCase(aForma[x]) = UpperCase(aAuxiliar[i]) then
        aValores[x] := aAuxiliar[i+1];
    Inc(i,2);
  end;

  Result := '0';

end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
    sRet: AnsiString;
    sDinheiro, sForma : AnsiString;
    iX : Integer;
    i : Integer;
    sMsg, sMsgAux: AnsiString;
    iLinha : Integer;
    sLinha : AnsiString;
begin
  MsgLoja('Aguarde a Impressão do Cupom Fiscal...');

  // Laço para imprimir toda a mensagem
  StrTran(Mensagem,',',' '); // Nao aceita impressao do caracter ','
  sMsg := '';
  iLinha := 0;
  //( Trim(mensagem)<>'' )
  While ( iLinha < 6 ) do
      Begin
      sLinha := '';
	  sMsgAux := Mensagem;
	  sMsgAux := TrataTags( sMsgAux );
      if ( Trim(sMsgAux)='' ) then
         sMsg := sMsg +  'N' + Space(40)
      Else
         Begin
         // Laço para pegar 40 caracter do Texto
         For iX:= 1 to 40 do
            Begin
            // Caso encontre um CHR(10) (Line Feed) imprime a linha
            If ( Copy(sMsgAux,iX,1) = #10 ) or ( Copy(sMsgAux,iX,1) = #13 ) then
               Break;

            sLinha := sLinha + Copy(sMsgAux,iX,1);
            end;
         sLinha := Copy(sLinha+space(40),1,40);
         sMsg := sMsg + 'S' + sLinha;
         sMsgAux := Copy(sMsgAux,iX,Length(sMsgAux));
         If ( Copy(sMsgAux,1,1) = #10) or ( Copy(sMsgAux,1,1) = #13) then
            sMsgAux := Copy(sMsgAux,2,Length(sMsgAux));
         If ( Copy(sMsgAux,1,1) = #10) or ( Copy(sMsgAux,1,1) = #13) then
            sMsgAux := Copy(sMsgAux,2,Length(sMsgAux));
         End;
      Inc(iLinha);
    End;
  sRet := EnviaComando('S', sMsg);

  // Efetua os pagamentos
  sDinheiro := '';
  sRet := '-';

  For i:=0 to Length(aValores)-1 do
  begin
    if i = 0 then
      sForma := '00'
    else
      sForma := FormataTexto(IntToStr(i),2,0,2);

    if (UpperCase(aForma[i]) = 'DINHEIRO') and (StrToFloat(aValores[i]) > 0) then
      sDinheiro := sForma+Replicate('0',18) + FormataTexto(aValores[i],14,2,2)
    else
      if StrToFloat(aValores[i]) > 0 then
        sRet := EnviaComando( 'D', sForma + Replicate('0',18) + FormataTexto(aValores[i],14,2,2) );
  end;

  if sDinheiro <> '' then
    sRet := EnviaComando( 'D', sDinheiro );

  result := Status( 1,sRet );
  MsgLoja;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString;
begin
  // O ECF DataRegis IF/2 V9.10 não permite desconto no total da transaçao.
  Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
begin
  // O ECF DataRegis IF/2 V9.10 não permite acrescimo no total da transaçao.
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString;
var
  sRet : AnsiString;
begin
  sRet := EnviaComando( 'I', 'N'+FormataData(DataInicio,1)+FormataData(DataFim,1) );
  result := Status( 1,sRet );
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
begin
  // esse comando exige que o jumper esteja na posição TÉCNICO. Para que isso ocorra haverá o
  // rompimento do lacre do gabinete. Só podem ser usados por técnicos credenciados pela DATAREGIS,
  // ou seus Revendedores
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
var
  sRet : AnsiString;
  i: Integer;
begin
  Result := '1';
  i := 0;
  sRet := EnviaComando( 'J', '00' + Space(38) );
  if Copy(sRet,1,1)='+' then
  begin
    // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
    // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
    sRet := EnviaComando('d');            // Pega Numero do Cupom
    if Copy(sRet,1,1) = '+' then
      MyThread.NumCupom := Copy(sRet,17,6);
    Result := '0';
  end
  else if (Copy(sRet,Length(sRet),1)='P') then
  Begin
        While (Copy(sRet,Length(sRet),1)='P') and (i<3) do
        Begin
            Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
              'Falta de Papel', MB_OK + MB_ICONERROR);
            sRet := EnviaComando( 'J', '00' + Space(38) );
            if Copy(sRet,1,1)='+' then
            begin
               // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
               // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
               sRet := EnviaComando('d');            // Pega Numero do Cupom
               if Copy(sRet,1,1) = '+' then
                 MyThread.NumCupom := Copy(sRet,17,6);
               i := 3;
               Result := '0';
            End;
            Inc(i);
        End;
  end;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var
  sRet : AnsiString;
  i,j : Integer;
  sLinha : AnsiString;
begin
  MsgLoja('Aguarde a Impressão do Texto Não Fiscal...');
  // faz a checagem do texto.
  i:=1;
  sLinha := '';
  while i <= Length(Texto) do
  begin
    if copy(Texto,i,1) = #10 then
    begin
      sRet := EnviaComando( 'J', Copy(sLinha+Space(40),1,40) );
      j := 1;
      While (Copy(sRet,Length(sRet),1)='P') and (j < 3) do
      Begin
        MsgLoja;
        Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
          'Falta de Papel', MB_OK + MB_ICONERROR);
        MsgLoja('Aguarde a Impressão do Texto Não Fiscal...');
        sRet := EnviaComando( 'J', Copy(sLinha+Space(40),1,40) );
        Inc(j);
      End;

      sLinha := '';
    end
    else
      sLinha := sLinha + copy(Texto,i,1);
    Inc(i);
  end;
  result := Status( 1,sRet );
  MsgLoja;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.FechaCupomNaoFiscal: AnsiString;
var
  sRet : AnsiString;
  i : integer;
begin
  sRet := EnviaComando( 'K' );
  i := 1;
  While (Copy(sRet,Length(sRet),1)='P') and (i < 3) do
  Begin
    Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
        'Falta de Papel', MB_OK + MB_ICONERROR);
    sRet := EnviaComando( 'K' );
    Inc(i);
  End;
  result := Status( 1,sRet );
  // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
  // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
  sRet := EnviaComando('d');            // Pega Numero do Cupom
  if Copy(sRet,1,1) = '+' then
    MyThread.NumCupom := Copy(sRet,17,6);
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.ReImpCupomNaoFiscal( Texto:AnsiString ): AnsiString;
begin
  // para posterior implementacao
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString;
var
  sRet : AnsiString;
begin
  Valor := StrTran(Valor,',','.');
  // configura o banco que será impresso
  sRet := EnviaComando( 'U', 'BREAL'+Space(26)+'REAIS'+Space(25) );
  sRet := EnviaComando( 'U', 'A01700300050007000930' + FormataTexto(Valor,14,2,2) +
                                                       Copy(Favorec+Space(50),1,50) +
                                                       Copy(Cidade+Space(20),1,20) +
                                                       FormataData(StrToDate(Data),1) );
  result := Status( 1,sRet );
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
Var
  sRet : AnsiString;
begin
  sRet := EnviaComando( 'U', 'C' + Copy(FormataTexto(StrTran(Valor,',','.'),14,2,1) + ' ' + Texto + Space(148),1,148) );
  result := Status( 1,sRet );
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.Suprimento( Tipo:Integer;Valor:AnsiString;Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
begin
  if Tipo = 1 then
    result := '0'
  else
    result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.Gaveta:AnsiString;
var
  sRet : AnsiString;
begin
  sRet := EnviaComando( 'N' );
  result := Status( 1,sRet );
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.Status( Tipo:Integer; Texto:AnsiString ):AnsiString;
var
  bErro : Boolean;
begin
  bErro := False;
  case Tipo of
    1 : if copy(Texto,1,1) <> '+' then
            bErro := True;
    else
      bErro := False;
    end;

  If bErro then
    result := '1'
  else
    result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.StatusImp( Tipo:Integer ):AnsiString;
var
  sRet : AnsiString;
begin
  // Se o ECF esta em erro, abortar
  if CommDrv.OnError then
  begin
    Result := '1';
    Exit;
  end;

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
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (0=Nao / 1=Sim)
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

  //  1 - Verifica a hora da impressora
  If Tipo = 1 then
  begin
    sRet := EnviaComando( 'd' );
    if copy(sRet,1,1) = '+' then
    begin
      result := '0|' + copy(sRet,11,5) + ':' + '00';
    end
    else
      result := '1';
  end
  //  2 - Verifica a data da Impressora
  else if Tipo = 2 then
  begin
    sRet := EnviaComando( 'd' );
    if copy(sRet,1,1) = '+' then
    begin
      result := '0|' + copy(sRet,2,8);
    end
    else
      result := '1';
  end
  //  3 - Verifica o estado do papel
  else if Tipo = 3 then
  begin
    sRet := EnviaComando( 'R' );
    if copy(sRet,1,1) = '+' then
      if copy(sRet,6,1) <> 'P' then
        result := '0'
      else
        result := '2'
    else
      result := '1';
  end
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  else if Tipo = 4 then
    result := '0|ULTIMO'
  //  5 - Cupom Fechado ?
  else if Tipo = 5 then
  begin
    sRet := EnviaComando( 'R' );
    if copy(sRet,1,1) = '+' then
      if Pos(copy(sRet,2,1),'V,F') > 0 then
        result := '7'
      else
        result := '0'
    else
      result := '1';
  end
  //  6 - Ret. suprimento da impressora
  else if Tipo = 6 then
    result := '0|0.00'
  //  7 - ECF permite desconto por item
  else if Tipo = 7 then
    result := '11'
  //  8 - Verica se o dia anterior foi fechado
  else if Tipo = 8 then
  begin
    sRet := EnviaComando('R');
    result := Status( 1,sRet );
    If result = '0' then
      If (copy(sRet,Length(sRet)-2,1) = 'R') Or (Copy(sRet,2,1) = 'O') then     // verifica se é necessario imprimir uma Reducao Z
        result := '10'
      else
        result := '0';
  end
  //  9 - Verifica o Status do ECF - No Caso da DataRegis, verifica a Thread
  else if Tipo = 9 then
    if CommDrv.OnError then
      Result := '1'
    else
    begin
      if CommDrv.OnPaperError then
      begin
        sRet := EnviaComando('R');
        if Copy(sRet,Length(sRet),1)='K' then
        begin
          CommDrv.OnPaperError := False;
          Result := '0';
        end
        else
        begin
          Result := '1';
        end;
      end
      else
        Result := '0';
    end
  // 10 - Verifica se todos os itens foram impressos.
  else if Tipo = 10 then
    if MyThread.Comandos.Count > 0 then
      Result := '1'
    else
      Result := '0'
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  else if Tipo = 11 then
    result := '1'
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  else if Tipo = 12 then
    result := '0'
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  else if Tipo = 13 then
    result := '1'
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  else if Tipo = 14 then
    // 0 - Fechada
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
  //Retorno não encontrado   
  else
    Result := '1';
end;

//------------------------------------------------------------------------------
procedure TImpFiscalDataRegis.AlimentaProperties;
Var
  sRet                      : AnsiString;
  i                         : Integer;
  iAliquotas                : Integer;
  nPos                      : Integer;
  sICMS, sISS, sTodas, sAux : AnsiString;
  sPath                     : AnsiString;
  sForma, sFormaString      : AnsiString;
  fArquivo                  : TIniFile;

begin
  // Alimentando propriedades das Aliquotas
  sICMS  := '';
  sISS   := '';
  sTodas := '';
  sRet   := EnviaComando( 'G','SN', True );
  if copy(sRet,1,1) = '+' then
  begin
    iAliquotas := StrToInt(copy(sRet,184,2));
    For i := 0 To iAliquotas-1 Do
    Begin
      nPos := 186+i*33;
      sAux := FloatToStrf( StrToFloat( Copy(sRet, nPos+1, 4) ) /100, ffFixed, 18, 2) + '|';
      If sRet[nPos] In ['T','I', 'F'] Then
        sICMS := sICMS + sAux
      Else If sRet[nPos+2] = 'S' Then
        sISS := sISS + sAux;
      sTodas := sTodas + sRet[nPos] + sAux;
    End;
    ICMS      := sICMS;
    ISS       := sISS;
    Aliquotas := sTodas;

    // Alimentando propriedades das Condições de Pagamento

    // Verifica o path de onde esta o arquivo DREGIS.INI
    sPath := ExtractFilePath(Application.ExeName);

    // O ECF IF/2 não permite a leitura das formas de pagamento dessa forma deve ser mantido na estação que estiver
    // conectada a impressora um arquivo com as formas de pagamento chamado DREGIS.INI, no seguinte formato:
    // [FORMAS DE PAGAMENTO]
    // 1=DINHEIRO
    // 2=CHEQUE
    // 3=CARTAO ...
    try
      fArquivo := TIniFile.Create(sPath+'DREGIS.INI');
      sForma := '.';
      i := 1;
      While Trim(sForma) <> '' do
      begin
        sForma := fArquivo.ReadString('FORMAS DE PAGAMENTO', IntToSTr(i) ,'');
        if sForma <> '' then
          sFormaString := sFormaString + sForma + '|';
        // Caso a Primeira Finalizadora Seja '' 
        if (sForma = '') and (i = 1) then
        begin
          sForma := '.';
          sFormaString := '|';
        end;
        Inc(i);
      end;
      FormasPgto := sFormaString;
    except
      FormasPgto := '';
    end;
  End;
End;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.HorarioVerao( Tipo:AnsiString ):AnsiString;
var
  sRet : AnsiString;
begin
  If Tipo = '+' then
    sRet := EnviaComando( 'T','A' )
  Else if Tipo = '-' then
    sRet := EnviaComando( 'T','D' )
  Else
    sRet := '-';
  result := Status( 1, sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalDataRegis.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString;
begin
  Result := RelatorioGerencial(cTextoImp , nVias , ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalDataRegis.RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
var
  sRet : AnsiString;
  sAux, sTexto : AnsiString;
  nLoop : Integer;
  lOk : Boolean;
begin
  Result := '1';

  MsgLoja('Aguarde a Impressão do Relatório Gerencial...');

  sRet := EnviaComando('R');
  if Copy(sRet,1,1)='-' then                         // Se falhou na primeira,
    sRet := EnviaComando('R');                       // Tenta novamente...
  if Copy(sRet,1,1)='-' then                         // Se falhou na segunda,
    sRet := EnviaComando('R');                       // Tenta novamente...
  if Copy(sRet,Length(sRet),1)='K' then
    CommDrv.OnPaperError := False
  else if Copy(sRet,Length(sRet),1)='P' then
  begin
    MsgLoja;
    Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
      'Falta de Papel', MB_OK + MB_ICONERROR);
    MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
    sRet := EnviaComando('R');                       // Tenta novamente...
    CommDrv.OnPaperError := Copy(sRet,Length(sRet),1)='P'
  end;

  // Se o ECF esta em erro, abortar
  if CommDrv.OnError Or CommDrv.OnPaperError then
  begin
    MsgLoja;
    Exit;
  end;

  // Imprime a Leitura X
  sRet := EnviaComando( 'G','NN' );
  if Copy(sRet,1,1)='+' then
  begin
    Sleep(20000);
    // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
    // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
    sRet := EnviaComando('d');            // Pega Numero do Cupom
    if Copy(sRet,1,1) = '+' then
      MyThread.NumCupom := Copy(sRet,17,6);
    Result := '0';
  end;

  lOk := True;
  Texto := LimpaAcentuacao( Texto );
  for nLoop := 1 to Vias do
  begin
    sTexto := Texto;
    While (Length(sTexto) > 0) and (sTexto <> #10) do
    begin
      if Pos(#10,sTexto) = 0 then
      begin
        sAux := copy(sTexto,1,40);
        sTexto := copy(sTexto,41,Length(sTexto));
      end
      else
      begin
        sAux := copy(sTexto,1,Pos(#10,sTexto)-1);
        sTexto := copy(sTexto,Pos(#10,sTexto)+1,Length(sTexto));
      end;

      sRet := EnviaComando( 'j', copy(sAux+'                                         ',1,40) );
      if Copy(sRet,1,1) <> '+' then
      begin
        MsgLoja;
        if Copy(sRet,Length(sRet),1)='P' then
        begin
          Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
            'Falta de Papel', MB_OK + MB_ICONERROR);
          MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
          sRet := EnviaComando('R');                       // Tenta novamente...
          if Copy(sRet,Length(sRet),1)='P' then
          begin
            MsgLoja;
            Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
              'Falta de Papel', MB_OK + MB_ICONERROR);
            MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
          end;
          sRet := EnviaComando('R');                       // Tenta novamente...
          if Copy(sRet,Length(sRet),1)='P' then
          begin
            MsgLoja;
            Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
              'Falta de Papel', MB_OK + MB_ICONERROR);
            MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
          end;
          sRet := EnviaComando( 'j', copy(sAux+'                                         ',1,40) );
        end
        else
        begin
          lOk := False;
          EnviaComando( 'K' );
          Break;
        end;
      end;
    end;

    if Not lOk then
      Break;

    if (Vias > 1) And (nLoop<>Vias) then
    begin
      MsgLoja;
      Application.MessageBox(PChar('Destaque a '+IntToStr(nLoop)+'a. Via...'),
        'Impressão do Relatório Gerencial', MB_OK + MB_ICONEXCLAMATION);
      MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
    end;
  end;

  if lOk And (Copy(sRet,1,1) = '+') then
  begin
    sRet := EnviaComando( 'K' );
    Result := '0';
  end;

  Sleep(2000);
  // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
  // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
  sRet := EnviaComando('d');            // Pega Numero do Cupom
  if Copy(sRet,1,1) = '+' then
    MyThread.NumCupom := Copy(sRet,17,6);
  MsgLoja;
end;

//----------------------------------------------------------------------------
function TImpFiscalDataRegis.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;


//------------------------------------------------------------------------------
function TImpFiscalDataRegis.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ) : AnsiString;
begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.LeTotNFisc:AnsiString;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
GravaLog(' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
GravaLog(' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
end;

//------------------------------------------------------------------------------
function Envia( sCmd:AnsiString; sDados:AnsiString='' ):bool;
var
  Texto1 : array[0..999] of char;
  Texto2 : array[0..999] of char;
  c,i    : Integer;
  chksum : byte;
begin

  // Inicializa as variáveis com zero
  FillChar(Texto1,1000,0);
  FillChar(Texto2,1000,0);

  // Faz o tratamento do comando e dos dados
  StrPCopy(Texto1,sCmd+sDados);
  Texto2[0] := char($fe);     // STX
  Texto2[1] := char($00);     // Bloco sempre zero
  Texto2[2] := Texto1[0];     // Comando
  c := StrLen( PAnsiChar( @Texto1[1] ));
  Texto2[3] := char(c);       // Tamanho

  //dados
  i := 1;
  While (Texto1[i] <> chr($00)) do
  begin
    StrCopy(PAnsiChar(@Texto2[i+3]),PAnsiChar(@Texto1[i]));
    Inc(i);
  end;

    // gera o checksum
    chksum := $0;
    chksum := chksum + Byte(c) + Byte(Texto1[0]);
    for i:=1 to c do
      chksum := chksum + Byte(Texto1[i]);
    Texto2[4+c] := char(chksum);

    // envia para a porta serial
    result := True;

    if lsDSR in CommDrv.GetLineStatus then
      CommDrv.SendData(@Texto2, c + 5)
    else
      result := False;
end;

//******************************************************************************
//******************************************************************************
//------------------------------------------------------------------------------
Function EnviaComando( sCmd:AnsiString; sDados:AnsiString=''; lIF2:Boolean=False ):AnsiString;
Var
  sRet     : AnsiString;
  sOK      : AnsiString;
  sStatus  : AnsiString;
  t1,t2,t3 : Comp;
  fTimeOut : Real;

Begin

  t2 := TimeStampToMSecs( DateTimeToTimeStamp(Now) );

  // Enquanto a EnviaComando estiver sendo utilizada, aguarde o término...
  while CommDrv.Using do
    Sleep(50);
  // Usando a EnviaComando.
  CommDrv.Using := True;

  if FileExists('ENVRET.LOG') then
    WriteLog('ENVRET.LOG', 'Envio   ('+sCmd+') '+sDados);

  if CommDrv.OnError then
    if Not CheckProcess then
    begin
      if FileExists('ENVRET.LOG') then
      begin
        t3 := TimeStampToMSecs(DateTimeToTimeStamp(Now)) - t2;
        WriteLog('ENVRET.LOG', 'Retorno ('+sCmd+') -');
        WriteLog('ENVRET.LOG', '        (em '+FloatToStr(t3)+' milisegundos.)');
      end;
      Result := '-';
      // Liberando a EnviaComando.
      CommDrv.Using := False;
      Exit;
    end;

  If sCmd = 'j' Then                          // Impressao de texto nao fiscal
    fTimeOut := 18000
  Else If sCmd = 'F' Then                     // Cancelamento de cupom
    fTimeOut := 7000
  Else If (sCmd = 'd') Or (sCmd = 'f') Then   // Pega Numero do Cupom
    fTimeOut := 10000
  Else If sCmd = 'A' Then                     // Registra Item
    fTimeOut := 4000
  Else
    fTimeOut := 6000;

  t1   := TimeStampToMSecs( DateTimeToTimeStamp(Now) );
  CommDrv.LastCmd := sCmd;              // Ultimo Comando Enviado Para o ECF
  sRet := EnviaCmd( sCmd,sDados,lIF2 );
  // Existe situacoes que o Numero do Cupom vem OK mas em branco.
  If (sCmd='d') And (Copy(sRet,1,1)='+') And
     ((Trim(Copy(sRet,2,9999))='') Or ((Copy(sRet,4,1)<>'/') And (Copy(sRet,7,1)<>'/'))) then
    sRet := '-';

  if (Copy(sRet,1,1)<>'+') And (Copy(sRet,Length(sRet),1)='P') then
    CommDrv.OnPaperError := True;

  if (sCmd<>'A') And (Not CommDrv.OnPaperError) then
  begin
    While (Copy(sRet,1,1) <> '+') And (TimeStampToMSecs(DateTimeToTimeStamp(Now))-t1 < fTimeOut) Do
    Begin

      Application.ProcessMessages;
      sOk     := Copy(sRet, Length(sRet)-2, 1);
      sStatus := Copy(sRet, 2, 1);

      If ((sOk = 'X') And (sStatus = 'X')) Or ((sOK + sStatus) = '') Then    // impressora possivelmente desligada
        sRet := '-'
      Else If (sOk = 'R') Or (sStatus = 'O') Then                            // verifica se é necessario imprimir uma Reducao Z
        sRet := '-'
      Else If sOk = 'N' Then
        sRet := '-'
      Else
        sRet := '-';

      If sRet = '-' Then
        sRet := EnviaCmd( sCmd, sDados, lIF2 );
      // Existe situacoes que o Numero do Cupom vem OK mas em branco.
      If (sCmd='d') And (Copy(sRet,1,1)='+') And
         ((Trim(Copy(sRet,2,9999))='') Or ((Copy(sRet,4,1)<>'/') And (Copy(sRet,7,1)<>'/'))) then
        sRet := '-';
    End;
  end;

  CommDrv.LastRet := sRet;              // Ultimo Retorno do ECF
  Result := sRet;

  if FileExists('ENVRET.LOG') then
  begin
    t3 := TimeStampToMSecs(DateTimeToTimeStamp(Now)) - t2;
    WriteLog('ENVRET.LOG', 'Retorno ('+sCmd+') '+sRet);
    WriteLog('ENVRET.LOG', '        (em '+FloatToStr(t3)+' milisegundos.)');
  end;

  // Liberando a EnviaComando.
  CommDrv.Using := False;

End;

//------------------------------------------------------------------------------
function ChecaPorta:Boolean;
begin
  Result := lsDSR in CommDrv.GetLineStatus;
end;

//------------------------------------------------------------------------------
function CheckProcess:Boolean;
Var
  nTries : Integer;
  lRet : Boolean;
Begin
  lRet := False;
  nTries := 1;
  While nTries <= 10 Do Begin
    If lsDSR In CommDrv.GetLineStatus Then
       Begin
         lRet := True;
         Break;
       End
    Else
       lRet := False;

    Inc(nTries);
    Sleep(500);
    Application.ProcessMessages;
  End;
  Result := lRet;
End;

//------------------------------------------------------------------------------
function WaitRead(var ABuffer: array of char; ABytesToRead:cardinal; var ABytesRead: cardinal; lIF2:Boolean=False): integer;
Var
  nTimeOut: integer;
  nSleep  : Integer;

Begin

  If sCommand = 'f' Then                                // Condição de Pagamento
    nSleep := 2000
  Else If (sCommand = 'j') Or (sCommand = 'J') Then     // Relatorio Gerencial ou Texto nao fiscal
    nSleep := 50
  Else If sCommand = 'G' Then                           // Alíquotas
  begin
    if lIF2 then
      nSleep := 5000
    else
      nSleep := 750;
  end
  Else If (sCommand = 'R') Or (sCommand = 'C') Then     // Status ou SubTotal
    nSleep := 1000
  Else If sCommand = 'A' Then                           // Registra Item
    nSleep := 1000
  Else If sCommand = 'S' Then                           // Comentarios (MV_LJFISMS)
    nSleep := 50
  Else                                                  // Qualquer outro comando
    nSleep := 750;

  With CommDrv Do
  Begin

    nTimeOut := 10;
    if sCommand <> 'A' then
      Sleep(nSleep);
    Application.ProcessMessages;
    While (FBuffer.size = 0) Or FReading Do
    Begin

      Sleep(nSleep);
      Application.ProcessMessages;
      Dec(nTimeout);
      If nTimeout = 0 Then
      Begin
        Result := 0;
        exit;
      End;

    End;

    BeginUpdateBuffer;
    ABytesRead := FBuffer.Read(ABuffer, FBuffer.Size);
    Result     := ABytesRead;
    FBuffer.Clear;
    EndUpdateBuffer;

  End;

End;

Procedure AjustaString (Var AString: Array Of Char);
Var
  nInd: integer;

Begin
  For nInd := Low(AString) To High(AString) Do
    If AString[nInd] = #0 Then
      AString[nInd] := #32;
End;

//------------------------------------------------------------------------------
Function EnviaCmd( sCmd:AnsiString; sDados:AnsiString=''; lIF2:Boolean=False ): AnsiString;
Var
  Retorno  : Array[0..999] Of char;
  Texto2   : Array[0..999] Of char;
  dsr      : Bool;
  c2       : Cardinal;
  sRetorno : AnsiString;

Begin

  // Recebe o comando solicitado
  sCommand := sCmd;

  // Inicializa as variáveis com zero
  FillChar(Retorno,1000, 0);
  FillChar(Texto2 ,1000, 0);
  sRetorno := '';

  dsr := Envia( sCmd, sDados );
  // faz o tratamento do retorno
  If dsr = True Then    // recebe os dados
  Begin
    c2 := 0;
    While (c2 < 1) Do
      if WaitRead(Retorno, 1, c2, lIF2) = 0 then
        Break;
    sRetorno := StrPas(Retorno);

    // Envia Sinal de que Recebeu os Retornos
    FillChar(Texto2 ,1000, 0);
    Texto2[0] := char($04);
    Texto2[1] := char($00);
    CommDrv.SendData(@Texto2,1);
WriteLog('DREGIS.TXT', 'Envio   ('+sCmd+') True - '+sDados);
    Case Retorno[0] Of
        char($04) : Begin   // ok     ACKN
WriteLog('DREGIS.TXT', 'Retorno ('+sCmd+') #04 '+sRetorno);
                      result := '+';
                    End;
        char($06) : Begin   // falha  NAKN
WriteLog('DREGIS.TXT', 'Retorno ('+sCmd+') #06 '+sRetorno);
WriteLog('DREGIS.TXT', 'Tamanho de c2: '+IntToStr(c2));
                      FillChar(Retorno,1000, 0);
                      c2 := 0;
                      While (c2 < 1) Do
                        If WaitRead(Retorno, 1, c2, lIF2) = 0 Then
                          Break;
sRetorno := StrPas(Retorno);
WriteLog('DREGIS.TXT', 'Retorno ('+sCmd+') #'+IntToStr(Ord(Retorno[0]))+' '+sRetorno);
WriteLog('DREGIS.TXT', 'Tamanho de c2: '+IntToStr(c2));
                      // Se deu NAKN na RegistraItem, Assume que é falta de papel.
                      if sCmd = 'A' then
                      begin
                        CommDrv.OnPaperError := True;
                        Result := '-';
                      end
                      else
                      begin
                        If Envia( 'R' ) Then
                        Begin
                          sCommand := 'f';            // Usar o TimeOut Deste Comando na WaitRead. (1400)
                          c2 := 0;
                          While (c2 < 1) Do
                            If WaitRead(Retorno, 1, c2, lIF2) = 0 Then
                              Break;
                          sRetorno := StrPas(Retorno);
                          if Retorno[0] = #8 then
                            Result := '-'+Trim(Copy(sRetorno,Pos(#26+#13,sRetorno)-7,6))
                          else
                            Result := '-';
                          FillChar(Texto2 ,1000, 0);
                          Texto2[0] := char($04);
                          Texto2[1] := char($00);
                          CommDrv.SendData(@Texto2,1);
                        End
                        Else
                          Result := '-';
                      end;
                      if FileExists('ENVRET.LOG') then
                        WriteLog('ENVRET.LOG', 'Falha NAKN no Comando '+sCmd+' - (Retorno := '+Result+')');
                    End;
        char($08) : Begin   // ok com resposta  ACKC
                      if sCmd='A' then
                        sRetorno := '+'
                      else
                        sRetorno := TrataRet(Retorno);
                      Result := sRetorno;
WriteLog('DREGIS.TXT', 'Retorno ('+sCmd+') #08 '+sRetorno);
                    End
    Else
      begin
        WriteLog('DREGIS.TXT', 'Retorno ('+sCmd+') #'+IntToStr(Ord(Retorno[0]))+' '+sRetorno);
        WriteLog('DREGIS.TXT', 'Tamanho de c2: '+IntToStr(c2));
        if sCmd='A' then
          Result := '+'
        else
          Result := '-';
      end;
    End;
  End
  Else
  begin
    Result := '-';
WriteLog('DREGIS.TXT', 'Envio   ('+sCmd+') False');
WriteLog('DREGIS.TXT', 'Retorno ('+sCmd+')');
  end;

  // O comando já foi executado
  sCommand := '';

End;

//------------------------------------------------------------------------------
function TrataRet( Retorno: Array Of Char ) : AnsiString;
var i,j  : Integer;
    nTam,chksum : Byte;
    sRet : AnsiString;
begin
  sRet := '';
  i := 2;
  if Retorno[0]+Retorno[1] <> #8+#13 then
  begin
WriteLog('DREGIS.TXT', '        Erro no ACKN + END...');
    Result := '-';
    Exit;
  end;
  while i <= 999 do
  begin
    if Retorno[i] <> #254 then
    begin
WriteLog('DREGIS.TXT', '        Erro no START... RETORNO DO COMANDO INVALIDO!!!');
      Result := '-';
      Exit;
    end;
    nTam   := Byte(Retorno[i+3]);
    chksum := Byte(Retorno[i+2]) + nTam;
    for j := (i+4) to (i+3+nTam) do
    begin
      sRet := sRet + Retorno[j];
      chksum := chksum + Byte(Retorno[j]);
    end;
    if chksum <> Byte(Retorno[i+4+nTam]) then
    begin
WriteLog('DREGIS.TXT', '        Erro no calculo do CheckSum...');
      Result := '-';
      Exit;
    end;
    i := i+5+nTam;
    if Retorno[i]+Retorno[i+1] = #26+#13 then
      i := 1000
    else if Retorno[i]+Retorno[i+1] = #13+#254 then
      Inc(i);
  end;
  Result := '+'+sRet;
end;


//------------------------------------------------------------------------------
procedure TrataDados( Texto:AnsiString );
var
  sMens : AnsiString;
  sMens1 : AnsiString;
begin
  sMens := '';
  sMens1 := '';
  Case Texto[5] of
    'B' : sMens := 'Buffer de impressao cheio';
    'C' : sMens := 'Comando não executado. Comando não definido ou não está disponível';
    'E' : sMens := 'EPROM fiscal desconectada';
    'c' : sMens := 'Cancelamento acima do limite.';
    'D' : sMens := 'Desconto acima do total';
    'F' : sMens := 'Erro nas variáveis fiscais. (Check sum inválido)';
    'f' : sMens := 'Cupom em fase de finalização. O Comando não é permitido agora.';
    'G' : sMens := 'Falta CGC/I.E.';
    'g' : sMens := 'Número de comprovantes inválido';
    'I' : sMens := 'Comando inválido/não reconhecido.';
    'i' : sMens := 'Dados do comando inválido.';
    'K' : sMens := ''; // 'Sem Erro';
    'M' : sMens := 'Erro de acesso na memória fiscal.';
    'm' : sMens := 'Erro de gravação na memória fiscal.';
    'N' : sMens := 'Tentativa de executar comando inválido para o estado de operação.';
    'n' : sMens := 'Número de finalizadores inválido';
    'P' : sMens := 'Fim de Papel';
    'p' : sMens := 'Impressora com falha';
    'R' : sMens := 'Obrigatório a emissão da Redução Z';
    'T' : sMens := 'Número ou índice de tributos errado.';
    't' : sMens := 'Foi encontrato a AnsiString TOTAL no comando.';
    'v' : sMens := 'Tentativa de cancelamento do cupom totalizado em zero.';
    'X' : sMens := 'Impressora ocupada.';
    'Z' : sMens := 'Redução já realizada hoje. Esse comando não pode ser executado em dia anterior ou no mesmo dia da última emissão da Redução Z';
  end;

  Case Texto[1] of
    'A' : sMens1 := 'Obrigatório a emissão da Leitura X';
    'O' : sMens1 := 'Obrigatório a emissão da Redução Z';
  end;
  If Pos(sMens1,sMens) = 0 then
    MessageDlg(sMens + #10 + sMens1, mtError, [mbOk], 0)
  else
    MessageDlg(sMens, mtError, [mbOk], 0);

end;

//------------------------------------------------------------------------------
procedure TImpFiscalDataRegis375.AlimentaProperties;
var
  sRet : AnsiString;
  sAliq : AnsiString;
  i : Integer;
  iAliquotas : Integer;
  sICMS, sISS, sTodas, sAux : AnsiString;
  sPagto : AnsiString;
  iPagto : Integer;

begin

  // Alimentando propriedades das Aliquotas
  sICMS := '';
  sISS := '';
  sTodas := '';
  sRet := EnviaComando( 'Q' );
  if copy(sRet,1,1) = '+' then
  begin
    iAliquotas := StrToInt(copy(sRet,2,2));
    sAliq := '';
    For i:=0 to iAliquotas-1 do
    begin
      sAux := FloatToStrf(StrToFloat(copy(copy(sRet,4+(i*5),5),2,4))/100,ffFixed,18,2) + '|';
      if copy(copy(sRet,4+(i*5),5),1,1) = 'T' then
        sICMS := sICMS + sAux
      else if copy(copy(sRet,4+(i*5),5),1,1) = 'S' then
        sISS := sISS + sAux;
      sTodas := sTodas + copy(copy(sRet,4+(i*5),5),1,1) + sAux;
    end;
    ICMS := sICMS;
    ISS := sISS;
    Aliquotas := sTodas;
  end;

  // Alimentando propriedades das Condições de Pagamento
  sRet := EnviaComando( 'f' );
  if copy(sRet,1,1) = '+' then
  begin
    iPagto := Length(copy(sRet,2,Length(sRet))) div 31;
    sPagto := '';
    For i:=0 to iPagto-1 do
      sPagto := sPagto + Trim(Copy(sRet, (i*31)+4, 14)) + '|';
    FormasPgto := sPagto;
  end
  else
    FormasPgto := '';

end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis375.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString;
begin
  Result := RelatorioGerencial(cTextoImp , nVias  ,ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalDataRegis375.RelatorioGerencial( Texto:AnsiString;Vias:Integer ; ImgQrCode: AnsiString):AnsiString;
var
  sRet : AnsiString;
  sAux, sTexto : AnsiString;
  nLoop : Integer;
  lOk : Boolean;
begin
  Result := '1';

  MsgLoja('Aguarde a Impressão do Relatório Gerencial...');

  sRet := EnviaComando('R');
  if Copy(sRet,1,1)='-' then                         // Se falhou na primeira,
    sRet := EnviaComando('R');                       // Tenta novamente...
  if Copy(sRet,1,1)='-' then                         // Se falhou na segunda,
    sRet := EnviaComando('R');                       // Tenta novamente...
  if Copy(sRet,Length(sRet),1)='K' then
    CommDrv.OnPaperError := False
  else if Copy(sRet,Length(sRet),1)='P' then
  begin
    MsgLoja;
    Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
      'Falta de Papel', MB_OK + MB_ICONERROR);
    MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
    sRet := EnviaComando('R');                       // Tenta novamente...
    CommDrv.OnPaperError := Copy(sRet,Length(sRet),1)='P'
  end;

  // Se o ECF esta em erro, abortar
  if CommDrv.OnError Or CommDrv.OnPaperError then
  begin
    MsgLoja;
    Exit;
  end;

  lOk := True;
  Texto := LimpaAcentuacao( Texto );
  for nLoop := 1 to Vias do
  begin
    sTexto := Texto;
    While (Length(sTexto) > 0) and (sTexto <> #10) do
    begin
      if Pos(#10,sTexto) = 0 then
      begin
        sAux := copy(sTexto,1,40);
        sTexto := copy(sTexto,41,Length(sTexto));
      end
      else
      begin
        sAux := copy(sTexto,1,Pos(#10,sTexto)-1);
        sTexto := copy(sTexto,Pos(#10,sTexto)+1,Length(sTexto));
      end;

      // Tento Mandar o Comando...
      sRet := EnviaComando( 'j', copy(sAux+'                                         ',1,40) );
      if Copy(sRet,1,1) <> '+' then
      begin
        MsgLoja;
        if Copy(sRet,Length(sRet),1)='P' then
        begin
          Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
            'Falta de Papel', MB_OK + MB_ICONERROR);
          MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
          sRet := EnviaComando('R');                       // Tenta novamente...
          if Copy(sRet,Length(sRet),1)='P' then
          begin
            MsgLoja;
            Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
              'Falta de Papel', MB_OK + MB_ICONERROR);
            MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
          end;
          sRet := EnviaComando('R');                       // Tenta novamente...
          if Copy(sRet,Length(sRet),1)='P' then
          begin
            MsgLoja;
            Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
              'Falta de Papel', MB_OK + MB_ICONERROR);
            MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
          end;
          sRet := EnviaComando( 'j', copy(sAux+'                                         ',1,40) );
        end
        else
        begin
          lOk := False;
          EnviaComando( 'K' );
          Break;
        end;
      end;
    end;

    if Not lOk then
      Break;

    if (Vias > 1) And (nLoop<>Vias) then
    begin
      MsgLoja;
      Application.MessageBox(PChar('Destaque a '+IntToStr(nLoop)+'a. Via...'),
        'Impressão do Relatório Gerencial', MB_OK + MB_ICONEXCLAMATION);
      MsgLoja('Aguarde a Impressão do Relatório Gerencial...');
    end;
  end;

  if lOk And (Copy(sRet,1,1) = '+') then
  begin
    sRet := EnviaComando( 'K' );
    Result := '0';
  end;

  Sleep(2000);
  // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
  // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
  sRet := EnviaComando('d');            // Pega Numero do Cupom
  if Copy(sRet,1,1) = '+' then
    MyThread.NumCupom := Copy(sRet,17,6);
  MsgLoja;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis375.ReducaoZ( MapaRes:AnsiString ) : AnsiString;
var
  sRet : AnsiString;
begin
  Result := '1';
  MsgLoja('Aguarde a Impressão da Redução Z...');
  sRet := EnviaComando( 'H','N' );
  if Copy(sRet,1,1)='+' then
  begin
    Sleep(30000);
    // Deve-se incrementar o Numero do Cupom somente nos comandos gerem esta possibilidade:
    // Abrir Cupom, Leitura X , Redução Z, Texto Não Fiscal.
    sRet := EnviaComando('d');            // Pega Numero do Cupom
    if Copy(sRet,1,1) = '+' then
      MyThread.NumCupom := Copy(sRet,17,6);
    Result := '0';
  end;
  MsgLoja;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis375.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString;
begin
  // O ECF DataRegis IF/2 V9.10 não permite desconto no total da transaçao.
  // O mesmo somente é permitido quando enviado junto com a primeira finalizadora.
  CommDrv.Desconto := FormataTexto(VlrDesconto,14,2,2);
  Result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis375.Pagamento( Pagamento,Vinculado,Percepcion :AnsiString ): AnsiString;
var
  sRet : AnsiString;
  sForma : AnsiString;
  aAuxiliar : TaString;
  i,x : Integer;
  bErro : Boolean;
begin
  sRet := EnviaComando( 'R' );
  if Copy(sRet,1,1) <> '+' then
  begin
    Result := '1';
    Exit;
  end;
  CommDrv.OnPaperError := (Pos('P', sRet) > 0);           // Tem Papel???

  i:=0;
  While (CommDrv.OnPaperError) and (i < 3) do
  Begin
      Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
      'Falta de Papel', MB_OK + MB_ICONERROR);
      sRet := EnviaComando( 'R' );
      CommDrv.OnPaperError := (Pos('P', sRet) > 0);           // Tem Papel???
      Inc(i);
  End;

  // Se o ECF esta em erro, abortar
  if CommDrv.OnError Or CommDrv.OnPaperError then
  begin
    MsgLoja;
    Result := '1';
    Exit;
  end;

  Pagamento := StrTran(Pagamento,',','.');

  sForma := LeCondPag;
  sForma := Copy(sForma,3,Length(sForma));
  _MontaArray( sForma,aForma );

  // prepara a array a Valores com o tamanho da aForma
  SetLength( aValores,Length(aForma) );
  // Acrescenta zeros em toda a aValores
  For i:=0 to Length(aValores)-1 do
    aValores[i] := '0';

  // Monta um array auxiliar com os pagamentos solicitados
  Pagamento := StrTran(Pagamento,',','.');
  _MontaArray( Pagamento,aAuxiliar );

  // Verifica se existem todas as formas solicitadas
  i := 0;
  bErro := False;
  While i < Length(aAuxiliar) do
  begin
    if Pos(UpperCase(aAuxiliar[i]),sForma) = 0 then
      bErro := True;
    Inc(i,2);
  end;

  // Abandona a rotina se não encontrar alguma forma de pagamento
  if bErro then
  begin
    MsgLoja;
    result := '1';
    ShowMessage('Foram solicitadas formas de pagamento que não constam no ECF.');
    Exit;
  end;

  // Alimenta a  matriz aValors
  i := 0;
  While i < Length(aAuxiliar) do
  begin
    For x:=0 to Length(aForma)-1 do
      if UpperCase(aForma[x]) = UpperCase(aAuxiliar[i]) then
        aValores[x] := aAuxiliar[i+1];
    Inc(i,2);
  end;

  Result := '0';

end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis375.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  sRet : AnsiString;
begin
  Result := '1';
  if CommDrv.LastItem <> '' then
  begin
    sRet := EnviaComando( 'b', CommDrv.LastItem );
    if Copy(sRet,1,1)='+' then
    begin
      CommDrv.LastItem := '';
      Result := '0';
    end;
  end;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis375.SubTotal(sImprime: AnsiString):AnsiString;
var
  sRet : AnsiString;
begin
  if (CommDrv.LastCmd = 'C') And (Copy(CommDrv.LastRet,1,2) = '+S') then
  begin
    sRet := CommDrv.LastRet;
    // Se Converter o SubTotal, e for Maior que Zero...
    if StrToInt(Copy(sRet,3,14)) > 0 then
      // Se Converter o NumItem, e for Maior que Zero...
      if StrToInt(Copy(sRet,17,3)) > 0 then
        Result := '0|'+Copy(sRet,3,14);
  end
  else
  begin
    sRet := EnviaComando('C');
    Result := '1';
    if Copy(sRet,1,1) = '+' then
    begin
      // Se não veio o retorno esperado, tento novamente...
      if Not ((Copy(sRet,1,2)='+S') Or (Copy(sRet,1,2)='+T')) then
        sRet := EnviaComando('C');
      // Se não veio o retorno esperado, tento pela ultima vez...
      if Not ((Copy(sRet,1,2)='+S') Or (Copy(sRet,1,2)='+T')) then
        sRet := EnviaComando('C');
      if Copy(sRet,1,2) = '+S' then
      try
        // Se Converter o SubTotal, e for Maior que Zero...
        if StrToInt(Copy(sRet,3,14)) > 0 then
          // Se Converter o NumItem, e for Maior que Zero...
          if StrToInt(Copy(sRet,17,3)) > 0 then
            Result := '0|'+Copy(sRet,3,14);
      except
        CommDrv.LastRet := '-';
        Result := '1';
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis375.NumItem:AnsiString;
var
  sRet : AnsiString;
begin
  if (CommDrv.LastCmd = 'C') And (Copy(CommDrv.LastRet,1,2) = '+S') then
  begin
    sRet := CommDrv.LastRet;
    // Se Converter o SubTotal, e for Maior que Zero...
    if StrToInt(Copy(sRet,3,14)) > 0 then
      // Se Converter o NumItem, e for Maior que Zero...
      if StrToInt(Copy(sRet,17,3)) > 0 then
        Result := '0|'+Copy(sRet,17,3);
  end
  else
  begin
    sRet := EnviaComando('C');
    Result := '1';
    if Copy(sRet,1,1) = '+' then
    begin
      // Se não veio o retorno esperado, tento novamente...
      if Not ((Copy(sRet,1,2)='+S') Or (Copy(sRet,1,2)='+T')) then
        sRet := EnviaComando('C');
      // Se não veio o retorno esperado, tento pela ultima vez...
      if Not ((Copy(sRet,1,2)='+S') Or (Copy(sRet,1,2)='+T')) then
        sRet := EnviaComando('C');
      if Copy(sRet,1,2) = '+S' then
      try
        // Se Converter o SubTotal, e for Maior que Zero...
        if StrToInt(Copy(sRet,3,14)) > 0 then
          // Se Converter o NumItem, e for Maior que Zero...
          if StrToInt(Copy(sRet,17,3)) > 0 then
            Result := '0|'+Copy(sRet,17,3)
      except
        CommDrv.LastRet := '-';
        Result := '1';
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis375.FechaCupom( Mensagem:AnsiString ):AnsiString;
var sRet : AnsiString;
    sDinheiro, sDesconto, sForma : AnsiString;
    lFirst : Boolean;
    iX : Integer;
    i, j : Integer;
    sMsg,sMsgAux: AnsiString;
    iLinha : Integer;
    sLinha : AnsiString;
begin
  MsgLoja('Aguarde a Impressão do Cupom Fiscal...');

  // Laço para imprimir toda a mensagem
  StrTran(Mensagem,',',' '); // Nao aceita impressao do caracter ','
  sMsg := '';
  iLinha := 0;
  //( Trim(mensagem)<>'' )
  While ( iLinha < 6 ) do
      Begin
      sLinha := '';
	  sMsgAux := Mensagem;
	  sMsgAux := TrataTags( sMsgAux );
      if ( Trim(sMsgAux)='' ) then
         sMsg := sMsg +  'N' + Space(40)
      Else
         Begin
         // Laço para pegar 40 caracter do Texto
         For iX:= 1 to 40 do
            Begin
            // Caso encontre um CHR(10) (Line Feed) imprime a linha
            If ( Copy(sMsgAux,iX,1) = #10 ) or ( Copy(sMsgAux,iX,1) = #13 ) then
               Break;

            sLinha := sLinha + Copy(sMsgAux,iX,1);
            end;
         sLinha := Copy(sLinha+space(40),1,40);
         sMsg := sMsg + 'S' + sLinha;
         sMsgAux := Copy(sMsgAux,iX,Length(sMsgAux));
         If ( Copy(sMsgAux,1,1) = #10) or ( Copy(sMsgAux,1,1) = #13) then
            sMsgAux := Copy(sMsgAux,2,Length(sMsgAux));
         If ( Copy(sMsgAux,1,1) = #10) or ( Copy(sMsgAux,1,1) = #13) then
            sMsgAux := Copy(sMsgAux,2,Length(sMsgAux));
         End;
      Inc(iLinha);
    End;
  sRet := EnviaComando('S', sMsg);

  // Efetua os pagamentos
  sDinheiro := '';
  sRet := '-';

  // Registrar o Desconto no Total
  if (CommDrv.Desconto<>'') And (StrToInt(CommDrv.Desconto)>0) then
  begin
    sDesconto := CommDrv.Desconto+'D';
    lFirst    := True;
  end
  else
  begin
    sDesconto := '';
    lFirst    := False;
  end;

  For i:=0 to Length(aValores)-1 do
  begin
    if i = 0 then
      sForma := '00'
    else
      sForma := FormataTexto(IntToStr(i),2,0,2);

    if (UpperCase(aForma[i]) = 'DINHEIRO') and (StrToFloat(aValores[i]) > 0) then
      sDinheiro := sForma+Replicate('0',18) + FormataTexto(aValores[i],14,2,2)
    else
      if StrToFloat(aValores[i]) > 0 then
      begin
        if lFirst then
        begin
          sRet := EnviaComando( 'c', sForma + Replicate('0',18) + FormataTexto(aValores[i],14,2,2) + sDesconto);
          j:=0;
          While (Copy(sRet,Length(sRet),1)='P') and (j < 3) do
          Begin
            MsgLoja;
            Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
            'Falta de Papel', MB_OK + MB_ICONERROR);
            MsgLoja('Aguarde a Impressão do Cupom Fiscal...');
            sRet := EnviaComando( 'c', sForma + Replicate('0',18) + FormataTexto(aValores[i],14,2,2) + sDesconto);
            Inc(j);
          End;
          sDesconto := '';
          lFirst := False;
        end
        else
        begin
          sRet := EnviaComando( 'D', sForma + Replicate('0',18) + FormataTexto(aValores[i],14,2,2) );
          j:=0;
          While (Copy(sRet,Length(sRet),1)='P') and (j < 3) do
          Begin
            MsgLoja;
            Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
            'Falta de Papel', MB_OK + MB_ICONERROR);
            MsgLoja('Aguarde a Impressão do Cupom Fiscal...');
            sRet := EnviaComando( 'D', sForma + Replicate('0',18) + FormataTexto(aValores[i],14,2,2) );
            Inc(j);
          End;
        end;
      end;
  end;

  if sDinheiro <> '' then
    if lFirst then
    begin
      sRet := EnviaComando( 'c', sDinheiro + sDesconto );
      j:=0;
      While (Copy(sRet,Length(sRet),1)='P') and (j < 3) do
      Begin
         MsgLoja;
         Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
         'Falta de Papel', MB_OK + MB_ICONERROR);
         MsgLoja('Aguarde a Impressão do Cupom Fiscal...');
         sRet := EnviaComando( 'c', sDinheiro + sDesconto );
         Inc(j);
      End;
    end
    else
    Begin
      sRet := EnviaComando( 'D', sDinheiro );
      j:=0;
      While (Copy(sRet,Length(sRet),1)='P') and (j < 3) do
      Begin
         MsgLoja;
         Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
         'Falta de Papel', MB_OK + MB_ICONERROR);
         MsgLoja('Aguarde a Impressão do Cupom Fiscal...');
         sRet := EnviaComando( 'D', sDinheiro );
         Inc(j);
      End;
    End;

  Result := Status( 1,sRet );
  MsgLoja;
end;


//------------------------------------------------------------------------------
procedure _MontaArray( sTexto:AnsiString; var aFormas:TaString );
var
  iTamanho : Integer;
  iPos : Integer;
  sFormas : AnsiString;
begin
  iTamanho := 0;
  While (Pos('|', sTexto) > 0) do
  begin
    Inc(iTamanho);
    SetLength( aFormas, iTamanho );
    iPos := Pos('|', sTexto);
    if iPos = 1 then
      sFormas := ''
    else
      sFormas := Copy(sTexto, 1, iPos-1);
    aFormas[iTamanho-1] := sFormas ;
    sTexto := Copy(sTexto, iPos+1, Length(sTexto));
  end;
  if Length(sTexto)>1 then
  begin
    Inc(iTamanho);
    SetLength( aFormas, iTamanho );
    aFormas[iTamanho-1] := sTexto;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque DataRegis
///
function TImpChequeDataRegis.Abrir( aPorta:AnsiString ): Boolean;
begin
  If Not bOpened Then
  Begin
    bOpened := True;

    CommDrv := TImpFiscalDriver.Create(Application);
    CommDrv.OnReceiveData := CommDrv.DoReceiveData;

    if upperCase(aPorta) = 'COM1' then
      CommDrv.ComPort := pnCOM1
    else if upperCase(aPorta) = 'COM2' then
      CommDrv.ComPort := pnCOM2
    else if upperCase(aPorta) = 'COM3' then
      CommDrv.ComPort := pnCOM3
    else if upperCase(aPorta) = 'COM4' then
      CommDrv.ComPort := pnCOM4
    else if upperCase(aPorta) = 'COM5' then
      CommDrv.ComPort := pnCOM5
    else if upperCase(aPorta) = 'COM6' then
      CommDrv.ComPort := pnCOM6
    else if upperCase(aPorta) = 'COM7' then
      CommDrv.ComPort := pnCOM7
    else
      CommDrv.ComPort := pnCOM8;

    CommDrv.ComPortSpeed := br9600;
    CommDrv.Connect;

    if lsDSR in CommDrv.GetLineStatus then
      Result := True
    else
      Result := False;
  End
  Else
    Result := True;
end;

//------------------------------------------------------------------------------
function TImpChequeDataRegis.Fechar( aPorta:AnsiString ): Boolean;
begin
  If bOpened Then
  Begin
    bOpened := False;
    CommDrv.Disconnect;
    CommDrv.Free;
    CommDrv := NIL;
  End;
  Result := True;
end;

//------------------------------------------------------------------------------
function TImpChequeDataRegis.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sData ,sRet, sPath, sLayOut : AnsiString;
  fArquivo : TIniFile;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  sRet := EnviaComando( 'R' );
  if Copy(sRet,Length(sRet),1)='P' then
    Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
      'Falta de Papel', MB_OK + MB_ICONERROR);

  sPath := ExtractFilePath(Application.ExeName);
  try
     fArquivo := TIniFile.Create(sPath+'DREGIS.INI');
     sLayOut  := fArquivo.ReadString('LAY-OUT BANCOS', StrPas(Banco), '03610708110114011726');
     fArquivo.Free;
   except
     sLayOut := '03610708110114011726';
  end;

  sRet := EnviaComando( 'U', 'BREAL'+Space(26)+'REAIS'+Space(25) );
  sRet := EnviaComando( 'U', PChar('A'+sLayOut) + FormataTexto(Valor,14,2,2) +
                                                  Copy(Favorec+Space(30),1,30) +
                                                  Copy(Cidade+Space(20),1,20) +
                                                  Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,3,2) );
  If Copy(sRet,1,1) = '+' Then
  Begin
    Sleep(20000);
    Application.MessageBox(PChar('Tecle ENTER, Após a Impressão do Cheque...'),
        'Impressão de Cheque', MB_OK + MB_ICONEXCLAMATION);
    Result := True;
  End
  Else
    Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequeDataRegis.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequeDataRegis.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpChequeDataRegis375.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sData, sRet, sPath, sLayOut : AnsiString;
  fArquivo : TIniFile;
begin
  if Length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  sRet := EnviaComando( 'R' );
  if Copy(sRet,Length(sRet),1)='P' then
    Application.MessageBox('Arrume a Bobina e Pressione ENTER Para Continuar a Impressão...',
      'Falta de Papel', MB_OK + MB_ICONERROR);

  sPath := ExtractFilePath(Application.ExeName);
  try
     fArquivo := TIniFile.Create(sPath+'DREGIS.INI');
     sLayOut  := fArquivo.ReadString('LAY-OUT BANCOS', StrPas(Banco), '03610708110114011726');
     fArquivo.Free;
   except
     sLayOut := '03610708110114011726';
  end;

  sRet := EnviaComando( 'U', 'BREAL'+Space(26)+'REAIS'+Space(25) );
  sRet := EnviaComando( 'U', PChar('A'+sLayOut) + FormataTexto(Valor,14,2,2) +
                                                  Copy(Favorec+Space(50),1,50) +
                                                  Copy(Cidade+Space(20),1,20) +
                                                  Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,3,2) );
  If Copy(sRet,1,1) = '+' Then
  Begin
    Sleep(20000);
    Application.MessageBox(PChar('Tecle ENTER, Após a Impressão do Cheque...'),
        'Impressão de Cheque', MB_OK + MB_ICONEXCLAMATION);
    Result := True;
  End
  Else
    Result := False;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.SubTotal(sImprime: AnsiString):AnsiString;
var
  sRet : AnsiString;
begin
  if (CommDrv.LastCmd = 'C') And (Copy(CommDrv.LastRet,1,2) = '+S') then
  begin
    sRet := CommDrv.LastRet;
    // Se Converter o SubTotal, e for Maior que Zero...
    if StrToInt(Copy(sRet,3,14)) > 0 then
      // Se Converter o NumItem, e for Maior que Zero...
      if StrToInt(Copy(sRet,17,3)) > 0 then
        Result := '0|'+Copy(sRet,3,14);
  end
  else
  begin
    sRet := EnviaComando('C');
    Result := '1';
    if Copy(sRet,1,1) = '+' then
    begin
      // Se não veio o retorno esperado, tento novamente...
      if Not ((Copy(sRet,1,2)='+S') Or (Copy(sRet,1,2)='+T')) then
        sRet := EnviaComando('C');
      // Se não veio o retorno esperado, tento pela ultima vez...
      if Not ((Copy(sRet,1,2)='+S') Or (Copy(sRet,1,2)='+T')) then
        sRet := EnviaComando('C');
      sRet := Copy(sRet,1,16)+FormataTexto(IntToStr(StrToInt(Copy(sRet,17,3))-CommDrv.ITCanc),3,0,2);
      if Copy(sRet,1,2) = '+S' then
      try
        // Se Converter o SubTotal, e for Maior que Zero...
        if StrToInt(Copy(sRet,3,14)) > 0 then
          // Se Converter o NumItem, e for Maior que Zero...
          if StrToInt(Copy(sRet,17,3)) > 0 then
            Result := '0|'+Copy(sRet,3,14);
      except
        CommDrv.LastRet := '-';
        Result := '1';
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.NumItem:AnsiString;
var
  sRet : AnsiString;
begin
  if (CommDrv.LastCmd = 'C') And (Copy(CommDrv.LastRet,1,2) = '+S') then
  begin
    sRet := CommDrv.LastRet;
    // Se Converter o SubTotal, e for Maior que Zero...
    if StrToInt(Copy(sRet,3,14)) > 0 then
      // Se Converter o NumItem, e for Maior que Zero...
      if StrToInt(Copy(sRet,17,3)) > 0 then
        Result := '0|'+Copy(sRet,17,3);
  end
  else
  begin
    sRet := EnviaComando('C');
    Result := '1';
    if Copy(sRet,1,1) = '+' then
    begin
      // Se não veio o retorno esperado, tento novamente...
      if Not ((Copy(sRet,1,2)='+S') Or (Copy(sRet,1,2)='+T')) then
        sRet := EnviaComando('C');
      // Se não veio o retorno esperado, tento pela ultima vez...
      if Not ((Copy(sRet,1,2)='+S') Or (Copy(sRet,1,2)='+T')) then
        sRet := EnviaComando('C');
      sRet := Copy(sRet,1,16)+FormataTexto(IntToStr(StrToInt(Copy(sRet,17,3))-CommDrv.ITCanc),3,0,2);
      if Copy(sRet,1,2) = '+S' then
      try
        // Se Converter o SubTotal, e for Maior que Zero...
        if StrToInt(Copy(sRet,3,14)) > 0 then
          // Se Converter o NumItem, e for Maior que Zero...
          if StrToInt(Copy(sRet,17,3)) > 0 then
            Result := '0|'+Copy(sRet,17,3)
      except
        CommDrv.LastRet := '-';
        Result := '1';
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalDataRegis.PegaSerie : AnsiString;
begin
    result := '1|Funcao nao disponivel';
end;

//-----------------------------------------------------------
function TImpFiscalDataRegis.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
begin
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalDataRegis.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

Function TrataTags( Mensagem : AnsiString ) : AnsiString;
var
  cMsg : AnsiString;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
Function TImpFiscalDataRegis.RedZDado(MapaRes:AnsiString):AnsiString;
begin
     Result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalDataRegis.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

(*initialization
  RegistraImpressora('DATAREGIS IF/2 - V. 09.10'  , TImpFiscalDataRegis   , 'BRA', '091103');
  RegistraImpressora('DATAREGIS IF 375 - V. 02.03', TImpFiscalDataRegis375, 'BRA', '091304');
  RegistraImpCheque ('DATAREGIS IF/2 - V. 09.10'  , TImpChequeDataRegis   , 'BRA');
  RegistraImpCheque ('DATAREGIS IF 375 - V. 02.03', TImpChequeDataRegis375, 'BRA');*)
end.
//------------------------------------------------------------------------------

