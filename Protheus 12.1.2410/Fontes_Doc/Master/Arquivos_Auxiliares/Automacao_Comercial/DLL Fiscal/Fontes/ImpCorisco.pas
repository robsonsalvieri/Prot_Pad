unit ImpCorisco;

interface

uses
  Dialogs, ImpFiscMain, Windows, SysUtils, classes, Messages, WinProcs,
  LojxFun, Forms;

const WM_ETX = WM_USER + 1003;

Type
  TImpFiscalCorisco = class(TImpressoraFiscal)
  private
    fHandle : THandle;
    eFuncAbrePorta     : function (iNumP,iBRate: Longint; Wnd:Hwnd):Integer; StdCall;
    eFuncEnviaString   : function (Var S:String):Integer; StdCall;
    eFuncFechaPorta    : function ():Integer; StdCall;
    fFuncRecebeDadosRX : function (pB:PChar; TimeIn:Word):Integer; StdCall;
  public
    flagetx : boolean;
    sRetorno : String;
    sPorta2  : String;
    iHdlMain2: Integer;

    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function LeituraX:String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function PegaPDV:String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function GravaCondPag( Condicao:String ):String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:String ): String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function Gaveta:String; override;
    function AbreECF: String; override;
    function FechaECF: String; override;
    function Suprimento( Tipo:Integer;Valor:String;Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function Status( Tipo:Integer; Texto:String ):String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function EnviaComando ( sComando:String; iTam:Integer =0):String;
    procedure AlimentaProperties; override;
    function PegaSerie:String; override;
    function SubTotal (sImprime: String):String; override;
    function NumItem:String; override;
    function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;
    function ImpostosCupom(Texto: String): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String):String; override;
    function TotalizadorNaoFiscal( Numero,Descricao:String ):String; override;
    function LeTotNFisc:String; override;
    function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String) : String; override;
    function DownMF(sTipo, sInicio, sFinal : String):String; override;
    function RedZDado( MapaRes:String ):String; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
    function ImpTxtFis(Texto : String) : String; override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
end;

TImpFiscalCorisco402 = class(TImpFiscalCorisco)
public
  function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
end;

Function TrataTags( Mensagem : String ) : String;

implementation
var
  sTamCod, sNumDec, sLeCondPag : String;
  bPend :Boolean;
//---------------------------------------------------------------------------
function TImpFiscalCorisco.Abrir(sPorta : String; iHdlMain: Integer) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ECFCOM32.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;
begin
  fHandle := LoadLibrary( 'ECFCOM32.DLL' );
  if (fHandle <> 0) Then
  begin
    bRet      := True;
    bPend     := False;
    sPorta2   :=sPorta;
    iHdlMain2 :=iHdlMain;

    aFunc := GetProcAddress(fHandle,'eFechaPorta');
    if ValidPointer( aFunc, 'eFechaPorta' ) then
      eFuncFechaPorta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'eAbrePorta');
    if ValidPointer( aFunc, 'eAbrePorta' ) then
      eFuncAbrePorta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'eEnviaString');
    if ValidPointer( aFunc, 'eEnviaString' ) then
      eFuncEnviaString := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'eRecebedadosRX');
    if ValidPointer( aFunc, 'eRecebedadosRX' ) then
      fFuncRecebeDadosRX := aFunc
    else
    begin
      bRet := False;
    end;

  end
  else
  begin
    ShowMessage('O arquivo ECFCOM32.DLL não foi encontrado.');
    bRet := False;
  end;

  if bRet then
  begin
    result := '0';
    iRet := eFuncAbrePorta(StrToInt(Copy(sPorta,4,1))-1,3, iHdlMain);
    if iRet <> 0 then
    begin
      If eFuncFechaPorta = 0 then
        iRet := eFuncAbrePorta(StrToInt(Copy(sPorta,4,1))-1,3, iHdlMain);
      if iRet <> 0 then
      begin
        ShowMessage('Erro na abertura da porta');
        result := '1';
      end;
    end;
  end
  else
    result := '1';

  //****************************************************************************
  // se a comunicacao estiver ok. Grava as aliquotas nas propriedades da classe
  //****************************************************************************
  if result = '0' then
    AlimentaProperties;

end;

//---------------------------------------------------------------------------
function TImpFiscalCorisco.Fechar( sPorta:String ) : String;
begin
  if (fHandle <> INVALID_HANDLE_VALUE) then
  begin
    if eFuncFechaPorta <> 0 then
      ShowMessage('Erro ao fechar a comunicação com impressora Fiscal.');
    FreeLibrary(fHandle);
    fHandle := 0;
  end;
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalCorisco.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.LeituraX : String;
var
  sRet : String;
begin
  sRet := EnviaComando( '3f1}');
  MsgLoja('Aguarde a impressão da Leitura X...');
  sRet := EnviaComando( '1X}' );
  MsgLoja;
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.ReducaoZ( MapaRes:String ) : String;
var
  sRet : String;
begin
  MsgLoja('Aguarde a impressão da Redução Z...');
  sRet := EnviaComando( '1F}' );
  MsgLoja;
  result := Status( 1,sRet );
  sRet := EnviaComando( '3f1}' );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.AbreCupom(Cliente:String; MensagemRodape:String) : String;
var
  sRet : String;
begin
  bPend := True;
  sRet := EnviaComando( '0V' );
  sret:=Status( 1,sRet );
  if Copy(sret,1,1)='1' then
  begin
      sRet := EnviaComando( '0V' );
      sret:=Status( 1,sRet );
  end;
  result := sRet ;
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.PegaCupom(Cancelamento:String):String;
var
  sRet : String;
begin
  sRet := EnviaComando( '4T03',6 );
  result := Status( 1,sRet );
  if copy(result,1,1)='0' then
    result := result + copy(sRetorno,2,Pos('<ETX>',sRetorno)-2);
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.PegaPDV:String;
var
  sRet : String;
begin
  sRet := EnviaComando( '3CL6',4 );
  result := Status( 1,sRet );
  if copy(result,1,1)='0' then
    result := result + copy(sRetorno,2,Pos('<ETX>',sRetorno)-2);
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
var
  sRet : String;
  aAliq : TaString;
  iPos : Integer;
  sAliq : String;
  iTamanho : Integer;
  sComando : String;
  sSituacao : String;
  sQtde : String;
  iRet:Integer;
begin
  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    result := '11';
    exit;
  end;

  // Verica o separador decimal dos valores informados.
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');
  qtde := StrTran(qtde,',','.');

  // Verifica se a aliquota é ISENTA, c/SUBSTITUICAO TRIBUTARIA, NAO TRIBUTAVEL, ISS ou ICMS
  sSituacao := copy(aliquota,1,1);
  aliquota := StrTran(Trim(copy(aliquota,2,5)),',','.');
  if Pos(sSituacao,'TS') > 0 then
  begin
    if sSituacao = 'T' then
      sRet := LeAliquotas
    else
      sRet := LeAliquotasISS;

    aliquota := FloatToStrf(StrToFloat(aliquota),ffFixed,18,2);
    MontaArray( Copy(sRet, 3, Length(sRet)), aAliq );
    iPos := 0;
    for iTamanho:=0 to Length(aAliq)-1 do
      if aAliq[iTamanho] = aliquota then
        iPos := iTamanho + 1;

    if iPos = 0 then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1';
      exit;
    end;

    sAliq := IntToStr(iPos);
    If Length(sAliq) < 2 then
      sAliq := '0' + sAliq;
    sAliq := sSituacao + sAliq;
  end
  else
  begin
    sAliq := sSituacao+'00';
  end;

  // Transforma a Quantidade Conforme o Numero de Decimais Utilizado Pelo ECF.
  if (Copy(sNumDec,1,1)='0') then
    sQtde := FormataTexto(qtde,6,2,2)
  else
    sQtde := FormataTexto(qtde,6,3,2);

  // Retorna o Tamanho do Codigo Usado Pelo ECF
  if copy(sTamCod,1,1) = '0' then
    iTamanho := StrToInt(copy(sTamCod,2,2))
  else
    iTamanho := 13;

  sComando := '0I' +
              Copy(codigo+Space(iTamanho),1,iTamanho) + Space(1) +
              Copy(descricao+Space(30),1,30) + #13 + #13 + #13 +
              sAliq +
              sQtde +
              FormataTexto(Vlrdesconto,9,2,2) +
              FormataTexto(VlrUnit,9,2,2);

  sComando := #27+sComando;
  iRet := eFuncEnviaString( sComando );
  bPend := True;
  result := IntToStr(iRet);
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.LeAliquotas:String;
begin
  result := '0|'+ICMS;
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.LeAliquotasISS:String;
begin
  result := '0|'+ISS;
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.GravaCondPag( Condicao:String ):String;
var
  sRet : String;
  sCond : String;
  aCond : TaString;
  iPos : Integer;
  iTamanho : Integer;
begin
  sCond := LeCondPag;
  MontaArray( Copy(sCond,3,Length(sCond)), aCond );
  iPos := 0;
  For iTamanho := 0 to Length(aCond)-1 do
    If UpperCase(aCond[iTamanho]) = UpperCase(Condicao) then
      iPos := iTamanho ;

  if Copy( EnviaComando('2P'),1,1 ) = '1' then
    begin
      If iPos = 0 then
        iPos := Length(aCond);
      sRet := EnviaComando( '3PE' + IntToStr(iPos) + Copy(Condicao+Space(17),1,17) + #13);
      sRet := EnviaComando( '3p1' + IntToStr(iPos));
      result := Status( 1,sRet );
    end
  else
    begin
      ShowMessage('Para gravar condição de pagamento é necessário fechar o ECF.');
      result := '1';
    end;
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.LeCondPag:String;
begin
  Result := sLeCondPag;
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
var
  sComando : String;
  i : Integer;
  sRet : String;
  aAliq : TaString;
  sOrdem : String;
  bAchou : Boolean;
  sTipo : String;
  iICMS : Integer;
  iISS  : Integer;
begin

  If Tipo = 1 then
    sTipo := 'T'      // Tributado ICMS
  Else If Tipo = 2 then
    sTipo := 'S';     // ISS

  sRet := LeAliquotas;
  MontaArray( Copy(sRet, 3, Length(sRet)), aAliq );

  bAchou := False;
  For i:=0 to Length(aAliq)-1 do
    if aAliq[i] = sTipo + FormataTexto(Aliquota,4,2,2) then
      bAchou := True;

  if bAchou then
  begin
    ShowMessage('A aliquota ' + Aliquota + ' ja está cadastrada.');
    result := '4';
  end
  else
  begin
    iICMS := 0;
    iISS  := 0;
    For i:=1 to Length(aAliq) do
      If sTipo = 'T' then
        Inc(iICMS)
      Else If sTipo = 'S' then
        Inc(iISS);

    If Tipo = 1 then  // ICMS
    begin
      sOrdem := FormataTexto(IntToStr(iICMS+1),2,0,2);
      sComando := '3IE' + sOrdem + FormataTexto(Aliquota,4,2,2);
    end
    else if Tipo = 2 then  // ISS
    begin
      sOrdem := FormataTexto(IntToStr(iISS+1),2,0,2);
      sComando := '3iE' + sOrdem + FormataTexto(Aliquota,4,2,2);
    end;

    sRet := EnviaComando('2P');
    // Só inclui a aliquota se o ECF estiver fechado
    if copy(sRet,1,1) = '1' then
    begin
      result := Status( 1,EnviaComando( sComando ) );
      if copy(result,1,1)='1' then
        result := result + copy(sRetorno,2,Pos('<ETX>',sRetorno)-2);
    end
    else
      result := '1|';
  end;

  // Armazena as aliquotas nas properties da classe
  AlimentaProperties;

end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String;
var
  sRet : String;
begin
  sRet := EnviaComando( '0DV'+FormataTexto(vlrDesconto,9,2,2) );
  Result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.AcrescimoTotal( vlrAcrescimo:String ): String;
var
  sRet : String;
begin
  sRet := EnviaComando( '0AV'+FormataTexto(vlrAcrescimo,9,2,2) );
  Result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var
  sRet : String;
  sSituacao : String;
  aAliq : TaString;
  iPos : Integer;
  iTamanho : Integer;
  sAliq : String;
  sComando : String;
  sQtde : String;
begin
  // Verica o separador decimal dos valores informados.
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');
  qtde := StrTran(qtde,',','.');

  // Verifica se a aliquota é ISENTA, c/SUBSTITUICAO TRIBUTARIA, NAO TRIBUTAVEL, ISS ou ICMS
  sSituacao := copy(aliquota,1,1);
  aliquota := StrTran(Trim(copy(aliquota,2,5)),',','.');
  if Pos(sSituacao,'TS') > 0 then
  begin
    if sSituacao = 'T' then
      sRet := LeAliquotas
    else
      sRet := LeAliquotasISS;

    aliquota := FloatToStrf(StrToFloat(aliquota),ffFixed,18,2);
    MontaArray( Copy(sRet, 3, Length(sRet)), aAliq );
    iPos := 0;
    for iTamanho:=0 to Length(aAliq)-1 do
      if aAliq[iTamanho] = aliquota then
        iPos := iTamanho + 1;

    if iPos = 0 then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1';
      exit;
    end;

    sAliq := IntToStr(iPos);
    If Length(sAliq) < 2 then
      sAliq := '0' + sAliq;
    sAliq := sSituacao + sAliq;
  end
  else
  begin
    sAliq := sSituacao+'00';
  end;

  // Transforma a Quantidade Conforme o Numero de Decimais Utilizado Pelo ECF.
  if (Copy(sNumDec,1,1)='0') then
    sQtde := FormataTexto(qtde,6,2,2)
  else
    sQtde := FormataTexto(qtde,6,3,2);

  // Retorna o Tamanho do Codigo Usado Pelo ECF
  if copy(sTamCod,1,1) = '0' then
    iTamanho := StrToInt(copy(sTamCod,2,2))
  else
    iTamanho := 13;

  sComando := '0CI' +
              Copy(codigo+Space(iTamanho),1,iTamanho) +
              sAliq +
              sQtde +
              FormataTexto(Vlrdesconto,9,2,2) +
              FormataTexto(VlrUnit,9,2,2);

  sRet := EnviaComando( sComando );
  result := Status( 1, sRet );

end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.CancelaCupom( Supervisor:String ):String;
var
  sRet : String;
begin
   sRet:=EnviaComando('2C',1);
   if copy( Status( 1,sRet ),1,1 ) = '0' then
      // Cupom Aberto
      sRet := EnviaComando( '0CC')
   Else
      // Cupom Fechado
      sRet := EnviaComando( '0CD' );

  result := '0|';
End;
//----------------------------------------------------------------------------
function TImpFiscalCorisco.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;

  function AchaPagto( sForma:String;aFormas:Array of String ):String;
  var
    iPos, iTamanho : Integer;
  begin
    iPos := -1;
    for iTamanho:=0 to Length(aFormas)-1 do
      if UpperCase(aFormas[iTamanho]) = UpperCase(sForma) then
        iPos := iTamanho;
    result := IntToStr(iPos);
  end;

var
  i : Integer;
  sRet : String;
  aFormas : TaString;
  sForma,sValor : String;
  aAuxiliar : TaString;
begin

  // Faz a checagem do Parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Comando para totalizacao do cupom fiscal
  sRet := EnviaComando( '0T' );

  // Pega as formas de pagto cadastradas na impressora
  sRet := LeCondPag;
  MontaArray( copy(sRet,3,Length(sRet)), aFormas );

  // Monta um array com os pagtos solicitados
  MontaArray( Pagamento,aAuxiliar );

  i:=0;
  While i<Length(aAuxiliar) do
  begin
    sForma := UpperCase(aAuxiliar[i]);
    sValor := aAuxiliar[i+1];
    Inc(i,2);
    sRet := EnviaComando( '0P' + AchaPagto( sForma,aFormas ) + #13 + #13 + FormataTexto(sValor,12,2,2));
  end;

  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.FechaCupom( Mensagem:String ):String;
var
  sRet : String;
  sLinha: string;
  sCmd,sMsg: string;
  iLinha,nX : Integer;
begin
  // Laço para imprimir toda a mensagem - Aceita somente 8 linha
  iLinha := 1;
  sCmd:='';
  sMsg := Mensagem ;
  sMsg := TrataTags( sMsg );
  while ( Trim(sMsg)<>'' ) and ( iLinha<9 ) do
    Begin
    sLinha:='';
    // Laço para pegar 40 caracter do Texto
    for nX:= 1 to 48 do
      Begin
      // Caso encontre um CHR(10) (enter);imprima
      If Copy(sMsg,nX,1)= #10 then
         Break;

      sLinha:=sLinha+Copy(sMsg,nX,1);
    end;
      sLinha:=Copy(sLinha+space(48),1,48);
      sCmd:=sCmd+sLinha;
      If Copy(sMsg,nX,1) = #10 then
         sMsg:=Copy(sMsg,nX+1,Length(sMsg))
      Else
         sMsg:=Copy(sMsg,nX,Length(sMsg));

      inc(iLinha);
      End;

  sRet := EnviaComando( '0L'+sCmd+'}' );
  sRet := EnviaComando( '0F' );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:String ): String;
var
  sRet : String;
begin
  sRet := EnviaComando( '1LD' + FormataData(DataInicio,5) + FormataData(DataFim,5) );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.AbreECF : String;
var
  sRet : String;
  sRet1 : String;
begin
  // Roteiro de abertura do ECF contido no Manual da Corisco V 4.01
  // Verificar possibilidade de abertura do ECF
  sRet := EnviaComando( '2P' );
  // Se o Estado Prioritário permite
  if copy(sRet,1,1) = '1' then
  begin
    // Se a data atual é maior do que a da última atualização
    sRet := EnviaComando( '4D');
    sRet := Copy(sRet,8,4)+Copy(sRet,5,2)+Copy(sRet,2,2);
    sRet1 := EnviaComando( '4t024');
    sRet1 := Copy(sRet1,2,8);
    if sRet > sRet1 then
    begin
      // Verifica se o ECF já está aberto
      sRet := EnviaComando( '2A' );
      if copy(sRet,1,1) = '1' then
      begin
        // Abre o ECF
        sRet := EnviaComando( '1A' );
        result := Status( 1, copy(sRet,1,1) );
      end
      else
        result := '0';
    end
    else
        result := '0';
  end
  else
    result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.FechaECF : String;
var
  sRet : String;
begin
  sRet := EnviaComando( '1F}' );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
begin
  result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
var
  sRet : String;
  sLinha : String;
begin
  sRet := EnviaComando( '2L');
  If Copy(sRet,1,1)='0' Then
     Begin
     sLinha := StrTran( Texto, #10, #13 );
     sRet := EnviaComando( '7V' + space(38)+#13+ sLinha + #13 + '}');
     If Copy(sRet,1,1)='0' Then
        If Vias>1 then
           sRet := EnviaComando( '7v');
     End;
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.FechaCupomNaoFiscal: String;
begin
  result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.ReImpCupomNaoFiscal( Texto:String ):String;
begin
   // para posterior implementacao
   result := '1'
end;

// Versão 4.01 ----------------------------------------------------------------------------
function TImpFiscalCorisco.Autenticacao( Vezes:Integer;Valor,Texto:String ): String;
var
  sRet : String;
begin
  If (Vezes < 1) then
    Vezes := 1
  Else If (Vezes > 4) then
    Vezes := 4;
  sRet := EnviaComando( '7A' + IntToStr(Vezes) + FormataTexto(Valor,12,2,2) + #13 + Copy(Texto,1,48) + #13 );
  result := Status( 1,sRet );
end;

// Versão 4.02 ----------------------------------------------------------------------------
function TImpFiscalCorisco402.Autenticacao( Vezes:Integer;Valor,Texto:String ): String;
var
  sRet : String;
begin
  sRet := EnviaComando( '7B' + #13 + Copy(Texto,1,48) + #13 );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.Suprimento( Tipo:Integer;Valor:String;Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
var
  sRet : String;
  iParam : Integer;
Begin
  if Tipo = 1 then
     Result :='0'
  Else if ( Tipo = 2 ) or  ( Tipo = 3 ) then
     Begin
     For iParam := 0 to 9 do
        Begin
        sRet := EnviaComando( '3NL'+IntToStr(iParam));
        If Pos(Trim(UpperCase(Total)),sRet)>0 then
           Begin
           sRet := EnviaComando( '7N');
           sRet := EnviaComando( '7I' + IntToStr(iParam)+Space(48)+ #13+'Valor da Operacao                      --------'+#13+ FormataTexto(Valor,12,2,2)); { Pagina 148}
           sRet := EnviaComando( '7FT');
           result := Status( 1,sRet );
           exit;
           End
        End;
     ShowMessage(' Totalizador - '+ Total +' nao cadastrado' );
     result := '1|';
     End
  Else if Tipo = 2 then
    Result:='0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.Gaveta:String;
var
  sRet : String;
begin
  sRet := EnviaComando('G');
  if Copy(sRet,1,1) = '1' then
  begin
    sRet := EnviaComando('K');
    result := Status( 1,sRet );
  end
  else
  begin
    ShowMessage('A gaveta já está aberta.');
    result := '1|';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.Status( Tipo:Integer; Texto:String ) : String;
  // Parametros
  // 1- Verifica se o ultimo comando foi executado
  // 2- Verifica a existencia de papel ( se tem ou não )
  // 3- Verifica o status do papel ( se está no fim ou não )
var
  bErro : Boolean;
begin
  bErro := False;
  case Tipo of
    1 : if (Texto = '') or (copy(Texto,1,1) <> '0') then
            bErro := True;
    else
      bErro := False;
    end;

  If bErro then
    result := '1|'
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.StatusImp( Tipo:Integer ):String;
var
  sRet : String;
  i: integer;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - Obtem a Hora da Impressora
//  2 - Obtem a Data da Impressora
//  3 - Verifica o Papel
//  4 - Verifica se é possivel cancelar TODOS ou só o ULTIMO item registrado.
//  5 - Cupom Fechado ?
//  6 - Ret. suprimento da impressora
//  7 - ECF permite desconto por item
//  8 - Verica se o dia anterior foi fechado
//  9  - retorna as aliquotas da property Aliquotas
// 10 - Verifica se todos os itens foram impressos
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

// Faz a leitura da Hora da Impressora
if Tipo = 1 then
begin
  sRet:=copy(EnviaComando('2H'),1,1);
  if Length(Trim(sRet))=1 then
     If Trim(sRet)='0' then
        Begin
        sRet := EnviaComando( '4H',5);
        if copy(sRet,1,1) = '0' then
           result := '0|' + Copy(sRet,2,5) + ':00'
        else
           result := '1';
        end
     else
       begin
       ShowMessage('Problemas no relógio da impressora.');
       result := '1';
       end
  Else
     Begin
     if copy(sRet,1,1) = '0' then
        result := '0|' + Copy(sRet,2,5) + ':00'
     else
       result := '1';
     End;
end
// Faz a leitura da Data da Impressora
else if Tipo = 2 then
begin
  bPend := True;
  if copy(EnviaComando('2H'),1,1)='0' then
  begin
    bPend := True;
    sRet := EnviaComando( '4D',10);
    if copy(sRet,1,1) = '0' then
      result := '0|' + Copy(sRet,2,6) + copy(sRet,10,2)
    else
      result := '1';
  end
  else
  begin
    ShowMessage('Problemas no relógio da impressora.');
    result := '1';
  end;
end
// Faz a checagem do papel
else if Tipo = 3 then
begin
  sRet := EnviaComando( 'E' );
  if copy(sRet,1,1) = '1' then
    result := '2'
  else
    result := '0';
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//Verifica se o cupom esta fechado ou aberto.
else if Tipo = 5 then
begin
  i:=0;
  sRet := EnviaComando( '2C' );
  while (copy(sRet,1,1) = '0') and (i<3) do
  begin
    Sleep(5000);
    sRet := EnviaComando( '2C' );
    Inc(i);
  end;

  if copy(sRet,1,1) =  '0' then
     result := '7' // cupom aberto
  else
     result := '0';
end
else if Tipo = 6 then
begin
  result := '0|0.00';
end
// Verif.se ECF permite desconto por item
else if Tipo = 7 then
  result := '11'
// Verifica se o ECF foi fechado no dia anterior
else if Tipo = 8 then
begin
  sRet := EnviaComando( '2D' );
  if copy(sRet,1,1) = '1' then
    result := '10'  // nao foi realizada a reducao z do dia anterior
  else
    result := '0';
end
//9 - retorna as aliquotas da property Aliquotas
else if Tipo = 9 then
  result := '0'
//10 - Verifica se todos os itens foram impressos
else if Tipo = 10 then
  result := '0'
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 then
  result := '1'
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
else if Tipo = 12 then
  result := '0'
// 13 - Verifica se o ECF Arredonda o Valor do Item
else if Tipo = 13 then
  result := '0'
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
  result := '1';
end;

//----------------------------------------------------------------------------
procedure TImpFiscalCorisco.AlimentaProperties;
var
  sComando : String;
  i : Integer;
  iPos : Integer;
  sRet : String;
  sAliq,sTodasAliquotas : String;
  sTestaMem : String;
  sPagto : String;
begin
  // Veririca as aliquotas de ICMS
  sRet := '';
  sTestaMem := Copy( EnviaComando('2P'),1,1 );
  if sTestaMem <> '2' then
  begin
    for i:=1 to 20 do
    begin
      sComando := '3IL' + FormataTexto(IntToStr(i),2,0,2);
      // Tenta 3 vezes para evitar falhas de comunicação
      for iPos := 1 to 3 do
      Begin
        sAliq := EnviaComando( sComando );
        If Copy(sAliq,1,1) = '0' then break;
      End;
      if copy(sAliq,1,1) = '0' then
        sRet := sRet + FloatToStrf(StrToFloat(copy(sAliq,2,4))/100,ffFixed,18,2) + '|'
      else
        break;
    end;
  end
  else
  begin
    ShowMessage('Erro na memória de trabalho da Impressora.');
    exit;
  end;

  sTodasAliquotas := sRet;
  ICMS := sRet;

  // Veririca as aliquotas de ISS
  sRet := '';
  sTestaMem := Copy( EnviaComando('2P'),1,1 );
  if sTestaMem <> '2' then
  begin
    for i:=1 to 10 do
    begin
      sComando := '3iL' + FormataTexto(IntToStr(i),2,0,2);
      sAliq := EnviaComando( sComando );
      if copy(sAliq,1,1) = '0' then
        sRet := sRet + FloatToStrf(StrToFloat(copy(sAliq,2,4))/100,ffFixed,18,2) + '|'
      else
        break;
    end;
  end
  else
    ShowMessage('Erro na memória de trabalho da Impressora.');

  ISS := sRet;
  sTodasAliquotas := sTodasAliquotas + sRet;
  Aliquotas := sTodasAliquotas;

  // Transforma a Quantidade Conforme o Numero de Decimais Utilizado Pelo ECF.
  sNumDec := EnviaComando('2f');
  // Retorna o Tamanho do Codigo Usado Pelo ECF
  sTamCod := EnviaComando('3OL');

  // Carrega as Formas de Pagamento
  sRet := '';
  for i:=0 to 9 do
  begin
    sComando := '3PL' + IntToStr(i);
    sPagto := EnviaComando( sComando );
    if copy(sPagto,1,1)='0' then
      if Length(Trim(copy(sPagto,2,Pos('<ETX>',sPagto)-2))) > 0 then
        sRet := sRet + Trim(copy(sPagto,2,Pos('<ETX>',sPagto)-2)) + '|';
  end;
  if length(sRet) > 3 then
    sLeCondPag := '0|' + sRet
  else
    sLeCondPag := '1';

end;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.EnviaComando ( sComando:String; iTam:Integer ):String;
var
   iRet : Integer;
   pRXDados : PChar;
   iTT     : Integer;
begin
  iTT := 3;
  GetMem(pRXDados,256);
  FillChar(pRXDados^,256,0);
  If bPend Then
     Begin
     eFuncFechaPorta;
     sleep(100);
     eFuncAbrePorta(StrToInt(Copy(sPorta2,4,1))-1,3,iHdlMain2);
     bPend := False;
     End;
  sComando := #27+sComando;
  // Criado laço para tratar o tamanho do retorno do comando ( iTam )
  While True do
     Begin
     sRetorno := '';
     iRet := eFuncEnviaString( sComando );
     // O retorno 7, não esta documento no manual, mas o resultado do comando é positivo
     if (iRet = 0 ) or ( iRet=7 ) then
        begin
        // Existe alguns comandos que não possuem retorno, portanto travam
        // e devem ser incluidos neste IF.
        // #27+'K' - Acionamento da Gaveta
        // Or ( sCmd='0I' )
        if ( sComando = #27+'K') then
           begin
           Result := '0<ETX>';
           Exit;
           end;
        // Para cancelamento do cupom fechado a resposta da impressora é mais demorada
        if Pos('0CD',sComando)<>0 then
          Sleep(200);
        // Quando o tamanho da resposta for igual a 1 é necessario pegar a resposta a partir que 1 caracter, qdo não após o 3 caracter.
        if iTam=1 then
           iTT := 1;
        // Iniciando o ponteiro com zero
        FillChar(pRXDados^,256,0);
        iRet := fFuncRecebeDadosRX(pRXDados, 0);
        if iRet<>0 then
           begin
           sRetorno := StrPas(pRXDados);
           iRet:=Pos(#3, sRetorno);
           if iRet<>0 then
              Begin
              // Caso a resposta esta com o tamanho solicitado libera o ponteiro e retorna o resultado
              if ( Length(Copy(sRetorno,iTT,iRet-1))= iTam ) or ( iTam=0 )then
                 Begin
                 sRetorno := Copy(sRetorno,1,iRet-1)+'<ETX>';
                 Result := sRetorno;
                 FreeMem(pRXDados);
                 Exit;
                 End;
              End
           else
           begin
              //estava dando erro no retorno do comando 4D - Retorna data, por isso, tenta
              //enviar o comando novamente
               iRet := eFuncEnviaString( sComando );
               if (iRet = 0 ) or ( iRet=7 ) then
               begin
                    FillChar(pRXDados^,256,0);
                    iRet := fFuncRecebeDadosRX(pRXDados, 0);
                    if iRet<>0 then
                    begin
                        if ( Length(Copy(sRetorno,iTT,iRet-1))= iTam ) or ( iTam=0 )then
                        Begin
                            sRetorno := Copy(sRetorno,1,iRet-1)+'<ETX>';
                            Result := sRetorno;
                            FreeMem(pRXDados);
                            Exit;
                        End;
                    end
                    else
                    begin
                        ShowMessage('Erro na recepcao dos dados. Verificar arquivo CORISCO.TXT.');
                        WriteLog('CORISCO.TXT', 'Comando['+sComando+'] iRet[0] pRXDados['+StrPas(pRXDados)+'] ');
                    end;
               end;
           end;
        end
        else
        begin
            //estava dando erro no retorno do comando 4D - Retorna data, por isso, tenta
            //enviar o comando novamente
            iRet := eFuncEnviaString( sComando );
            if (iRet = 0 ) or ( iRet=7 ) then
            begin
                FillChar(pRXDados^,256,0);
                iRet := fFuncRecebeDadosRX(pRXDados, 0);
                if iRet<>0 then
                begin
                    if ( Length(Copy(sRetorno,iTT,iRet-1))= iTam ) or ( iTam=0 )then
                    Begin
                        sRetorno := Copy(sRetorno,1,iRet-1)+'<ETX>';
                        Result := sRetorno;
                        FreeMem(pRXDados);
                        Exit;
                    End;
                end
                else
                begin
                    ShowMessage('Erro na recepcao dos dados. Verificar arquivo CORISCO.TXT.');
                    WriteLog('CORISCO.TXT', 'Comando['+sComando+'] iRet[0] pRXDados['+StrPas(pRXDados)+'] ');
                end;
            end;
        end;
     End
     else
       ShowMessage('Erro de comunicação física com o ECF. Erro número:'+IntToStr(iRet));
     End;
  Result := sRetorno;
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.PegaSerie : String;
begin
    result := '1|Funcao nao disponivel';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.SubTotal(sImprime: String ):String;
var
  sRet : String;
begin
  sRet := EnviaComando('0S',12);  // SubTotal
  if Copy(sRet,1,1)='0' then
    Result := '0|'+Copy(sRet,2,12)
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.NumItem:String;
var
  sRet : String;
begin
  sRet := EnviaComando('0N',4);
  if Copy(sRet,1,1)='0' then
    Result := '0|'+Copy(sRet,2,4)
  else
    Result := '1';
end;
//----------------------------------------------------------------------------
function TImpFiscalCorisco.RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer; ImgQrCode: String) : String;
begin
  Result := RelatorioGerencial(cTextoImp , nVias , ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
Var
  sRet : String;
  sLinha : String;
  iVz    : Integer;
begin
  sLinha:='';
  For iVz:= 1 to Vias do
     sLinha := sLinha+ StrTran( Texto, #10, #13 )+'-----------------------------------------------';

  sRet := EnviaComando( '1X{'+sLinha+'}');
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//-----------------------------------------------------------
function TImpFiscalCorisco.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
begin
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalCorisco.RecebNFis( Totalizador, Valor, Forma:String ): String;
Begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String  ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.TotalizadorNaoFiscal( Numero,Descricao:String ) : String;
begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.LeTotNFisc:String;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
GravaLog(' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
begin
GravaLog(' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.ImpTxtFis(Texto : String) : String;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
end;

//****************************************************************************//
Function TrataTags( Mensagem : String ) : String;
var
  cMsg : String;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//------------------------------------------------------------------------------
function TImpFiscalCorisco.DownMF(sTipo, sInicio, sFinal : String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
Function TImpFiscalCorisco.RedZDado(MapaRes:String):String;
begin
     Result := '0';
end;


//------------------------------------------------------------------------------
function TImpFiscalCorisco.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
  RegistraImpressora('CORISCO CV7000 V3 - V. 04.00', TImpFiscalCorisco   , 'BRA', '060805');
  RegistraImpressora('CORISCO CV7000 V3 - V. 04.01', TImpFiscalCorisco   , 'BRA', '060806');
  RegistraImpressora('CORISCO CV7000 V3 - V. 04.02', TImpFiscalCorisco402, 'BRA', '060807');
end.
