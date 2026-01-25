unit ImpIBM;

{ ///////////////////     CONSIDERAÇÕES IMPORTANTES   //////////////////////////

  Esta homologação está utilizando um componente OLE da IBM devido aos diversos
  tipos de perifericos que existem. Pex. existe um POS (mod.4610) que trabalha
  com portas COM, outro POS (mod.4694) que trabalha com portas RS485 (proprietarias
  da IBM) e outro POS (mod. 700) que trabalha com portas USB.

  A IBM disponibiliza um objeto OLE que faz a comunicação com esses equipamentos
  não importando qual seja a porta, basta configurar.

  Para utilizacao desse objeto OLE deverá ser instalado os drivers da IBM.
  "IBM POS Suite" (possuite131a.exe)

  Obs 1: O nome do dispositivo que deve ser informado no Metodo Open do Objeto
  OLE deve estar gravado no registro do Windows. Há um software da IBM que faz
  essa modificação no Registre. Nesse registro, por exemplo, esta gravada qual
  é a porta que o equipamento está conectado.

  Obs 2: Quando estamos utilizando um equipamento de portas RS485 existe um
  aplicativo chamado AIPCTRL que deve ficar no ar. Esse aplicativo é instalado
  junto com os drivers da IBM.
}

interface

uses
  Dialogs, ImpFiscMain, ImpCheqMain, Windows, SysUtils, classes, LojxFun, IniFiles, ComObj, Forms;

const
  PTR_S_JOURNAL = 1;
  PTR_S_RECEIPT = 2;
  PTR_S_SLIP = 4;
  /////////////////////////////////////////////////////////////////////
  // OPOS "State" Property Constants
  /////////////////////////////////////////////////////////////////////
  OPOS_S_CLOSED = 1;
  OPOS_S_IDLE = 2;
  OPOS_S_BUSY = 3;
  OPOS_S_ERROR = 4;
  /////////////////////////////////////////////////////////////////////
  // OPOS "ResultCode" Property Constants
  /////////////////////////////////////////////////////////////////////
  OPOSERR = 100;
  OPOSERREXT = 200;
  OPOS_SUCCESS = 0;
  OPOS_E_CLOSED = 1 + OPOSERR;
  OPOS_E_CLAIMED = 2 + OPOSERR;
  OPOS_E_NOTCLAIMED = 3 + OPOSERR;
  OPOS_E_NOSERVICE = 4 + OPOSERR;
  OPOS_E_DISABLED = 5 + OPOSERR;
  OPOS_E_ILLEGAL = 6 + OPOSERR;
  OPOS_E_NOHARDWARE = 7 + OPOSERR;
  OPOS_E_OFFLINE = 8 + OPOSERR;
  OPOS_E_NOEXIST = 9 + OPOSERR;
  OPOS_E_EXISTS = 10 + OPOSERR;
  OPOS_E_FAILURE = 11 + OPOSERR;
  OPOS_E_TIMEOUT = 12 + OPOSERR;
  OPOS_E_BUSY = 13 + OPOSERR;
  OPOS_E_EXTENDED = 14 + OPOSERR;
  /////////////////////////////////////////////////////////////////////
  // "PrintBitmap" Method Constants:
  /////////////////////////////////////////////////////////////////////
  PTR_BM_ASIS = -11;
  PTR_BM_LEFT = -1;
  PTR_BM_CENTER = -2;
  PTR_BM_RIGHT = -3;
  /////////////////////////////////////////////////////////////////////
  // "RotatePrint" Method: "Rotation" Parameter Constants
  // "RotateSpecial" Property Constants
  /////////////////////////////////////////////////////////////////////
  PTR_RP_NORMAL = $0001;
  PTR_RP_RIGHT90 = $0101;
  PTR_RP_LEFT90 = $0102;
  PTR_RP_ROTATE180 = $0103;

Type

  ImpIBM4610 = class(TImpressoraFiscal)
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
    function CancelaCupom(Supervisor:AnsiString):AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString; override;
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
    function RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    function HorarioVerao( Tipo:AnsiString ):AnsiString; override;
    function AlimentaPropEmulECF( sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:AnsiString ):AnsiString; override;
    function PegaSerie:AnsiString; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override;
    function RedZDado( MapaRes : AnsiString ):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
end;

  ChqIBM4610 = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar(aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
end;

function Imprimir( sTexto:AnsiString ):Boolean;
Function TrataTags( Mensagem : AnsiString ) : AnsiString;

implementation

var
  OposImpressora : OleVariant;
  cArqLog        : AnsiString;
  sJournal       : AnsiString;

//------------------------------------------------------------------------------
function Imprimir( sTexto:AnsiString ):Boolean;
var
  nRetorno : Integer;
  fArqLog  : TextFile;
begin
  nRetorno := OposImpressora.PrintImmediate( PTR_S_RECEIPT, sTexto );
  If nRetorno = OPOS_SUCCESS Then
    Result := True
  Else
    Result := False;

  // Grava o arquivo de Log
  AssignFile(fArqLog, cArqLog);
  Append(fArqLog);
  WriteLn(fArqLog, sTexto);
  CloseFile(fArqLog);

  // Acumula o cupom para gerar o Journal
  sJournal := sJournal + StrTran(sTexto,#10,#13+#10);
end;

//------------------------------------------------------------------------------
function ImpIBM4610.Abrir(sPorta:AnsiString; iHdlMain:Integer) : AnsiString;
var
  nRetorno : Integer;
  sPath : AnsiString;
  fArquivo : TIniFile;
  sImpressora : AnsiString;
begin
  // Pega o nome da impressora no arquivo de configuracao
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
  sImpressora := fArquivo.ReadString('Devices', 'Printer', '');
  fArquivo.Free;

  // Estabelece a comunicação com a Impressora
  OposImpressora := CreateOleObject('OPOS.POSPrinter');   // nome do componente OLE da IBM
  nRetorno := OposImpressora.Open(sImpressora);   // O nome desse device deve estar no registro do Windows

  If nRetorno = OPOS_SUCCESS then
  begin
    Result := '0';
    OposImpressora.Claim(1000);
    OposImpressora.DeviceEnabled := True;
  end
  else
    Result := '1';

  // Definição do nome do arquivo de Log.
  cArqLog := sPath+'CUPOM.LOG';

  // Cria o StringList que ira armazenar o cupom para o Journal
  sJournal := '';
End;

//------------------------------------------------------------------------------
function ImpIBM4610.Fechar( sPorta:AnsiString ) : AnsiString;
var
  nRetorno : Integer;
begin
  nRetorno := OposImpressora.Close;
  If nRetorno = OPOS_SUCCESS then
    Result := '0'
  Else
    Result := '1';

end;

//------------------------------------------------------------------------------
function ImpIBM4610.AbreECF:AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.FechaECF : AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.LeituraX : AnsiString;
begin
  Result := '0|';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.ReducaoZ( MapaRes:AnsiString ) : AnsiString;
begin
  Result := '0'
end;

//---------------------------------------------------------------------------
function ImpIBM4610.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString) : AnsiString;
var
  sTexto    : AnsiString;
  sTexto1   : AnsiString;
  sBitmap   : AnsiString;
  sHeader   : AnsiString;
  sPath     : AnsiString;
  fArquivo  : TIniFile;
  i         : Integer;
  fArqLog   : TextFile;
begin
  // Zera os valores das properties ValorPago e ValorVenda
  ValorPago  := 0;
  ValorVenda := 0;
  Itens      := 0;
  ItemNumero := 0;

  // Verifica o path de onde esta o arquivo IBM4610.INI
  sPath := ExtractFilePath(Application.ExeName);

  // Inicializa o arquivo de Log
  AssignFile(fArqLog, cArqLog);
  ReWrite(fArqLog);
  CloseFile(fArqLog);

  Try
    fArquivo := TIniFile.Create(sPath+'IBM4610.INI');

    //Imprime um Bitmap no cabecalho do cupom
    sBitmap := fArquivo.ReadString('Header', 'Bitmap', '');
    If sBitmap <> '' then
    begin
      OposImpressora.PrintBitMap( PTR_S_RECEIPT, sPath+sBitmap, PTR_BM_ASIS, PTR_BM_CENTER );
      Sleep(1000);
    end;
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

    sTexto := DateToStr(Date);
    sTexto1:= TimeToStr(Time);
    sHeader := sHeader + Copy(sTexto + ' ' + sTexto1 + ' - ' + NomeCaixa,1,40) + #10 + #10;
    sHeader := sHeader + 'Prod.       Qty.       $Un.      $Tot.' + #10;
    If Imprimir( sHeader ) then
    begin
      // Se conseguiu abrir o cupom grava no IBM4610 que existe um cupom aberto. 1=Aberto 0=Fechado
      fArquivo.WriteString('Messages', 'Cupom', '1');
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
function ImpIBM4610.PegaCupom(Cancelamento:AnsiString): AnsiString;
begin
  Result := '0|'+NumCupom;
end;

//---------------------------------------------------------------------------
function ImpIBM4610.PegaPDV : AnsiString;
begin
  Result := '0|'+Pdv;
end;

//---------------------------------------------------------------------------
function ImpIBM4610.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sTexto : AnsiString;
  sPath  : AnsiString;
  sDesconto : AnsiString;
  fValorTotal : Real;
  sValorTotal : AnsiString;
  fArquivo : TIniFile;
  iqtde : Integer;
begin
  If Pos('.',qtde) > 0 then
    iqtde := StrToInt(Trim(Copy(qtde,1,Pos('.',qtde)-1)))
  else
    if Pos(',',qtde) > 0 then
      iqtde := StrToInt(Trim(Copy(qtde,1,Pos(',',qtde)-1)))
    else
      iqtde := StrToInt(Trim(qtde));
  //Incrementa o Numero de itens vendidos.
  Itens := Itens + iqtde;
  //Incrementa o Numero do item.
  ItemNumero := ItemNumero + 1;
  // Pega a configuracao do arquivo ini para ver qual eh a descricao do desconto
  // e prepara a linha para impressao do desconto se houver.
  sDesconto := '';
  If StrToFloat(vlrdesconto) > 0 then
  begin
    sPath := ExtractFilePath(Application.ExeName);
    Try
      fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
      sDesconto := fArquivo.ReadString('Messages', 'Desconto', '');
      If Trim(sDesconto) <> '' then
        sDesconto := copy(sDesconto+space(27),1,27) + ' ' + Right(Space(10)+vlrdesconto,10)+#10;
      fArquivo.Free;
    except
    end;
  end;

  // Prepara a linha para impressao do item
  sTexto := FormataTexto(IntToStr(ItemNumero),3,0,2) + ' - ' + copy(descricao + space(34),1,34) + #10;
  sTexto := sTexto + Space(10) + FormataTexto(qtde,6,0,4) + ' ';
  sTexto := sTexto + FormataTexto(vlrUnit,10,2,3) + ' ';

  fValorTotal := StrToFloat(qtde)*StrToFloat(vlrUnit);
  sValorTotal := FormataTexto(FloatToStr(fValorTotal),10,2,3) ;

  sTexto := sTexto + sValorTotal;
  sTexto := sTexto + #10;

  // Faz a impressao do item
  If Imprimir( sTexto ) then
  begin
    ValorVenda := ValorVenda + fValorTotal;
    Result := '0';
    // Imprime desconto se houver
    If Trim(sDesconto) <> '' then
    begin
      ValorVenda := ValorVenda - StrToFloat(vlrdesconto);
      Imprimir( sDesconto );
    end;
  end
  Else
  begin
    Result := '1';
    ItemNumero := ItemNumero - 1;
  end;
end;

//---------------------------------------------------------------------------
function ImpIBM4610.LeAliquotas:AnsiString;
begin
  // esse retorno foi colocado dessa forma pq. o sistema estava pedindo uma
  // aliquota para fazer a venda. Depois que for localizado a parte de impostos
  // poderá ser excluida daqui
  Result := '0|0.00|18.00|7.00|12.00|5.00';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.LeAliquotasISS:AnsiString;
begin
  // esse retorno foi colocado dessa forma pq. o sistema estava pedindo uma
  // aliquota para fazer a venda. Depois que for localizado a parte de impostos
  // poderá ser excluida daqui
  Result := '0|0.00|5.00';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.LeCondPag:AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  fValorTotal : Real;
  sValorTotal : AnsiString;
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
function ImpIBM4610.CancelaCupom(Supervisor:AnsiString):AnsiString;
var
  sPath : AnsiString;
  fArquivo : TIniFile;
  sTexto : AnsiString;
  sFooter : AnsiString;
  i : Integer;
begin
  Try
    // Verifica o path de onde esta o arquivo IBM4610.INI para imprimir as msgs
    sPath := ExtractFilePath(Application.ExeName);
    // Abre o arquivo de configuracao.
    fArquivo := TIniFile.Create(sPath+'IBM4610.INI');

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

    sTexto := #10 +    '        C O M P R O B A N T E ' + #10;
    sTexto := sTexto + '             F I S C A L      ' + #10;
    sTexto := sTexto + '            A N U L A D O     ' + #10;
    sTexto := sTexto + #10 + 'Trans: ' + NumCupom + ' Terminal: ' + Pdv + #10;
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

  // Verifica se a impressora aceita o comando para cortar o papel.
  If OposImpressora.CapRecPapercut then
    OposImpressora.CutPaper(100);
end;

//---------------------------------------------------------------------------
function ImpIBM4610.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
  sTexto    : AnsiString;
  sFooter   : AnsiString;
  sPath     : AnsiString;
  sValor,sMsg  : AnsiString;
  fArquivo  : TIniFile;
  i         : Integer;
begin
  // Verifica o path de onde esta o arquivo IBM4610.INI para imprimir as msgs
  sPath := ExtractFilePath(Application.ExeName);

  // Abre o arquivo de configuracao.
  fArquivo := TIniFile.Create(sPath+'IBM4610.INI');

  // Imprime o troco (se houver)
//  If ValorPago - ValorVenda > 0 then
//  begin
    sTexto := fArquivo.ReadString('Messages', 'Troco', Space(21));
    If Trim(sTexto) <> '' then
    begin
      sValor := Space(10) + FloatToStrf(ValorPago-ValorVenda,ffFixed,18,2);
      sTexto := copy(sTexto+Space(27),1,27) + ' ' + Right(sValor,10) + #10;
      Imprimir( sTexto );
    end;
 // end;

  sTexto := #10+'Item Count: '+IntToStr(Itens)+#10+'Trans: '+NumCupom+' Terminal: '+Pdv+#10;
  Imprimir(sTexto);

  Try
    sTexto := '.';
    sFooter := '';
	sMsg := Mensagem;
    sMsg := TrataTags( sMsg );
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
      // Se conseguiu fechar o cupom acerta o IBM4610.INI para informar que nao existe cupom aberto
      fArquivo.WriteString('Messages','Cupom','0');
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

  // Verifica se a impressora aceita o comando para cortar o papel.
  If OposImpressora.CapRecPapercut then
    OposImpressora.CutPaper(100);

  // Retorna o cupom em uma AnsiString para gerar o Journal
  Result := Result + '|' + sJournal;
  sJournal := '';

end;

//---------------------------------------------------------------------------
function ImpIBM4610.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;
var
  aAuxiliar : TaString;
  i         : Integer;
  sTexto    : AnsiString;
  sValor    : AnsiString;
  fValorPago: Real;
  sTotalVenda: AnsiString;
begin
  // imprime o Total da Venda
  sTotalVenda := #10+copy('TOTAL'+Space(27),1,27) + ' ' + Right(Space(10)+FloatToStrf(ValorVenda,ffFixed,18,2),10)+#10;
  Imprimir( sTotalVenda );

  // Monta um array auxiliar com os pagamentos solicitados
  Pagamento := StrTran(Pagamento,',','.');
  MontaArray( Pagamento,aAuxiliar );
  sTexto := #10;
  fValorPago := 0;

  i := 0;
  While i < Length(aAuxiliar) do
  begin
    sValor := Space(10) + aAuxiliar[i+1];
    sTexto := sTexto + copy(aAuxiliar[i]+Space(27),1,27) + ' ' + Right(sValor,10) + #10;
    fValorPago := fValorPago + StrToFloat(aAuxiliar[i+1]);
    Inc(i,2);
  end;

  If Imprimir( sTexto ) then
  begin
    ValorPago := ValorPago + fValorPago;
    Result := '0';
  end
  Else
    Result := '1';

end;

//---------------------------------------------------------------------------
function ImpIBM4610.DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString;
var
  sTexto : AnsiString;
  sDesconto : AnsiString;
  fArquivo : TIniFile;
  sPath : AnsiString;
begin
  If StrToFloat(vlrDesconto) <> 0 then
  Begin
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
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
function ImpIBM4610.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var
  sTexto : AnsiString;
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
function ImpIBM4610.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
begin
  If Imprimir( Texto ) then
    Result := '0'
  Else
    Result := '1';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.FechaCupomNaoFiscal: AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.Suprimento( Tipo:Integer;Valor:AnsiString;Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.Gaveta:AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString;
var
  nRetorno : Integer;
  sTexto : AnsiString;
begin
  If not OposImpressora.SlpEmpty then   // verifica se tem documento inserido na impressora
  begin
    sTexto := Trim(Banco)+Trim(Valor)+Trim(Favorec)+Trim(Cidade)+Trim(Data);
    If sTexto = '' then
    begin
      OposImpressora.BeginInsertion(5000);
      OposImpressora.EndInsertion;

      sTexto := Verso;
      nRetorno := OposImpressora.PrintImmediate( PTR_S_SLIP, sTexto+#10 );

      OposImpressora.BeginRemoval(5000);
      OposImpressora.EndRemoval;
      If nRetorno = OPOS_SUCCESS Then
        Result := '0'
      Else
        Result := '1';

    end
    Else
    begin
      OposImpressora.RotatePrint( PTR_S_SLIP, PTR_RP_LEFT90 );
      OposImpressora.BeginInsertion(5000);
      OposImpressora.EndInsertion;

      sTexto := #10+#10+#10+Space(50)+Valor+#10+#10+#10+Space(10)+Favorec;
      nRetorno := OposImpressora.PrintImmediate( PTR_S_SLIP, sTexto+#10 );

      OposImpressora.BeginRemoval(5000);
      OposImpressora.EndRemoval;
      OposImpressora.RotatePrint( PTR_S_SLIP,PTR_RP_NORMAL );
      If nRetorno = OPOS_SUCCESS Then
        Begin
          ShowMessage('Vire o cheque');
          OposImpressora.BeginInsertion(5000);
          OposImpressora.EndInsertion;

          sTexto := Verso;
          nRetorno := OposImpressora.PrintImmediate( PTR_S_SLIP, sTexto+#10 );

          OposImpressora.BeginRemoval(5000);
          OposImpressora.EndRemoval;

          If nRetorno = OPOS_SUCCESS Then
            Result := '0'
          Else
            Result := '1';
        End

      Else
        Result := '1';
    end
  end
  Else
    Result := '1';

end;

//---------------------------------------------------------------------------
function ImpIBM4610.Status( Tipo:Integer; Texto:AnsiString ):AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.StatusImp( Tipo:Integer ):AnsiString;
var
  sPath : AnsiString;
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
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
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
  begin
    result := '0'
  end
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  else if Tipo = 4 then
    result := '0|TODOS'
  //  5 - Cupom Fechado ?
  else if Tipo = 5 then
  begin
    sPath := ExtractFilePath(Application.ExeName);
    fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
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
//    result := '11'
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
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function ImpIBM4610.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString;
begin
  Result := RelatorioGerencial(cTextoImp , nVias, ImgQrCode);
end;

//----------------------------------------------------------------------------

function ImpIBM4610.RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
var
  fArqLog : TextFile;
  fArquivo : TIniFile;
  cArquivo : AnsiString;
  nResult : Integer;
  cLinha : AnsiString;
  sPath : AnsiString;
  sBitmap : AnsiString;
begin
  If (copy(Texto,1,1) = '[') And (Right(Texto,1) = ']') then
  begin
    // Verifica o path de onde estão os arquivos
    sPath := ExtractFilePath(Application.ExeName);

    fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
    //Imprime um Bitmap no cabecalho do cupom
    sBitmap := fArquivo.ReadString('Header', 'Bitmap', '');
    If sBitmap <> '' then
      OposImpressora.PrintBitMap( PTR_S_RECEIPT, sPath+sBitmap, PTR_BM_ASIS, PTR_BM_CENTER );

    //Imprime que o cupom é duplicado.
    OposImpressora.PrintImmediate( PTR_S_RECEIPT, '        D U P L I C A D O'+#10+#10 );

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
        OposImpressora.PrintImmediate( PTR_S_RECEIPT, cLinha );
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
    nResult  := OposImpressora.PrintImmediate( PTR_S_RECEIPT, Texto );
    If nResult = OPOS_SUCCESS Then
      Result := '0'
    Else
      Result := '1';
  end;

  // Verifica se a impressora aceita o comando para cortar o papel.
  If OposImpressora.CapRecPapercut then
    OposImpressora.CutPaper(100);

end;

//----------------------------------------------------------------------------
function ImpIBM4610.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.HorarioVerao( Tipo:AnsiString ):AnsiString;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function ImpIBM4610.AlimentaPropEmulECF( sNumPdv,sNumCaixa,sNomeCaixa,sNumCupom:AnsiString ):AnsiString;
begin
  Pdv       := sNumPdv;
  NumCaixa  := sNumCaixa;
  NomeCaixa := sNomeCaixa;
  NumCupom  := sNumCupom;
end;

//------------------------------------------------------------------------------
function ChqIBM4610.Abrir( aPorta:AnsiString ): Boolean;
var
  nRetorno : Integer;
  sPath : AnsiString;
  fArquivo : TIniFile;
  sImpressora : AnsiString;
begin
  // Pega o nome da impressora no arquivo de configuracao
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'IBM4610.INI');
  sImpressora := fArquivo.ReadString('Devices', 'Printer', '');
  fArquivo.Free;

  // Estabelece a comunicação com a Impressora
  OposImpressora := CreateOleObject('OPOS.POSPrinter');   // nome do componente OLE da IBM
  nRetorno := OposImpressora.Open(sImpressora);   // O nome desse device deve estar no registro do Windows

  If nRetorno = OPOS_SUCCESS then
  begin
    Result := True;
    OposImpressora.Claim(1000);
    OposImpressora.DeviceEnabled := True;
  end
  else
    Result := False;

End;

//------------------------------------------------------------------------------
function ChqIBM4610.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  nRetorno : Integer;
  sTexto   : AnsiString;
begin
  if length(Data)=6 then
  begin
    // Recebe a data no formato YYMMDD e transforma para MMDDYY.
    Data := PChar(Copy(Data,3,2)+'/'+Copy(Data,5,2)+'/'+Copy(Data,1,2));
  end;

  If not OposImpressora.SlpEmpty then   // verifica se tem documento inserido na impressora
  begin
    sTexto:=Trim(StrPas(Banco))+Trim(StrPas(Valor))+Trim(StrPas(Favorec))+Trim(StrPas(Cidade))+Trim(StrPas(Data));
    If sTexto = '' then
    begin
      OposImpressora.BeginInsertion(5000);
      OposImpressora.EndInsertion;

      sTexto := StrPas(Verso);
      nRetorno := OposImpressora.PrintImmediate( PTR_S_SLIP, sTexto+#10 );

      OposImpressora.BeginRemoval(5000);
      OposImpressora.EndRemoval;

      If nRetorno = OPOS_SUCCESS Then
        Result := True
      Else
        Result := False;

    end
    Else
    begin
      OposImpressora.BeginInsertion(5000);
      OposImpressora.EndInsertion;
      OposImpressora.RotatePrint( PTR_S_SLIP, PTR_RP_LEFT90 );

      sTexto := #10+#10+#10+Space(50)+StrPas(Data)+#10+#10+Space(5)+
                Copy(StrPas(Favorec)+Space(40),1,40)+
                StrPas(Valor)+#10+#10+#10+
                Space(5)+StrPas(Extenso)+#10+#10+#10+
                StrPas(Mensagem);
      nRetorno := OposImpressora.PrintNormal( PTR_S_SLIP, sTexto+#10 );

      OposImpressora.RotatePrint( PTR_S_SLIP, PTR_RP_NORMAL );
      OposImpressora.BeginRemoval(5000);
      OposImpressora.EndRemoval;
      If nRetorno = OPOS_SUCCESS then
      Begin
        If Trim(StrPas(Verso)) <> '' Then
        Begin
          ShowMessage('Vire o cheque');
          OposImpressora.BeginInsertion(5000);
          OposImpressora.EndInsertion;
          OposImpressora.RotatePrint( PTR_S_SLIP, PTR_RP_LEFT90 );

          sTexto := Verso;
          nRetorno := OposImpressora.PrintNormal( PTR_S_SLIP, sTexto+#10 );

          OposImpressora.RotatePrint( PTR_S_SLIP, PTR_RP_NORMAL );
          OposImpressora.BeginRemoval(5000);
          OposImpressora.EndRemoval;

          If nRetorno = OPOS_SUCCESS Then
            Result := True
          Else
            Result := False;
        End
        Else
          Result := True
      End
      Else
        Result := False;
    end;
  end
  Else
    Result := False;

end;

//----------------------------------------------------------------------------
function ChqIBM4610.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function ChqIBM4610.StatusCh( Tipo:Integer ):AnsiString;
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
function ChqIBM4610.Fechar(aPorta:AnsiString ): Boolean;
var
  nRetorno : Integer;
begin
  nRetorno := OposImpressora.Close;
  If nRetorno = OPOS_SUCCESS then
    Result := True
  Else
    Result := False;

end;

//----------------------------------------------------------------------------
function ImpIBM4610.PegaSerie : AnsiString;
begin
    result := '1|Funcao nao disponivel';
end;

//-----------------------------------------------------------
function ImpIBM4610.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
begin
  Result:='0';
end;

//------------------------------------------------------------------------------
function ImpIBM4610.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function ImpIBM4610.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function ImpIBM4610.LeTotNFisc:AnsiString;
begin
        Result := '0|-99';
end;

//------------------------------------------------------------------------------
function ImpIBM4610.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function ImpIBM4610.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function ImpIBM4610.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
end;

//****************************************************************************//
Function TrataTags( Mensagem : AnsiString ) : AnsiString;
var
  cMsg : AnsiString;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//------------------------------------------------------------------------------
function ImpIBM4610.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function ImpIBM4610.RedZDado( MapaRes : AnsiString):AnsiString;
Begin
  Result := '0';
End;

//------------------------------------------------------------------------------
function ImpIBM4610.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
  RegistraImpressora('IBM 4610 POS PRINTER', ImpIBM4610, 'POR|EUA', ' ');
  RegistraImpCheque ('IBM 4610 POS PRINTER', ChqIBM4610, 'POR|EUA');
end.
