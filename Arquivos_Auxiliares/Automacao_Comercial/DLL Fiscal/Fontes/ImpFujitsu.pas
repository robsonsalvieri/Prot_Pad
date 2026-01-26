unit ImpFujitsu;

interface

uses
  Dialogs,
  ImpFiscMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms;

const
  pBuffSize = 200;

Type

  TImpFiscalGeneral = class(TImpressoraFiscal)
  private
    fHandle : THandle;
    fFuncAbrePorta      : function ( porta:Pointer ):integer; stdcall;    // OpenFujitsu
    fFuncEnviaComando   : function ( buffer:Pointer ):integer; stdcall;   // TxFujitsu
    fFuncLeRetorno      : function ( buffer:Pointer; Status1:Pointer; Status2:Pointer ):Integer; stdcall; // RxFujitsu
    fFuncFechaPorta     : procedure; stdcall;   // CloseFujitsu
    fFuncAnalisaByte    : procedure ( buffer:Pointer; ret:Pointer ); stdcall;    // AnalisaByte

  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function AbreEcf:String; override;
    function FechaEcf:String; override;
    function LeituraX:String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function PegaPDV:String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:String ): String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function TotalizadorNaoFiscal( Numero,Descricao:String ):String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
//    function Suprimento( Tipo:Integer;Valor:String ):String; override;
//    function Gaveta:String; override;
    function Status( Tipo:Integer; Texto:String ):String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function EnviaComando( sComando:String;sArgumento:String='' ):String;
    Procedure PulaLinha( iNumero:Integer );
    function RelatorioGerencial( Texto:String;Vias:Integer ; ImgQrCode: String):String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;
    function PegaSerie:String; override;
    function ImpostosCupom(Texto: String): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String; override;
    function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String) : String; override;
    function LeTotNFisc:String; override;
    function DownMF(sTipo, sInicio, sFinal : String):String; override;
    function RedZDado( MapaRes:String ):String; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
    function ImpTxtFis(Texto : String) : String; Override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
end;

Function TrataTags( Mensagem : String ) : String;

implementation

//---------------------------------------------------------------------------
function TImpFiscalGeneral.Abrir(sPorta : String; iHdlMain:Integer) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: GENERAL32.DLL');
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
  fHandle := LoadLibrary( 'GENERAL32.DLL' );
  if (fHandle <> 0) Then
  begin
    bRet := True;

    aFunc := GetProcAddress(fHandle,'CloseFujitsu');
    if ValidPointer( aFunc, 'CloseFujitsu' ) then
      fFuncFechaPorta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'OpenFujitsu');
    if ValidPointer( aFunc, 'OpenFujitsu' ) then
      fFuncAbrePorta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'TxFujitsu');
    if ValidPointer( aFunc, 'TxFujitsu' ) then
      fFuncEnviaComando := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'RxFujitsu');
    if ValidPointer( aFunc, 'RxFujitsu' ) then
      fFuncLeRetorno := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'AnalisaByte');
    if ValidPointer( aFunc, 'AnalisaByte' ) then
      fFuncAnalisaByte := aFunc
    else
    begin
      bRet := False;
    end;

  end
  else
  begin
    ShowMessage('O arquivo GENERAL32.DLL não foi encontrado em .' + ExtractFilePath(Application.ExeName) );
    bRet := False;
  end;

  if bRet then
  begin
    result := '0|';
    iRet := fFuncAbrePorta( PChar(sPorta) );
    if iRet <> 1 then
      bRet := False;
    if not bRet then
    begin
      ShowMessage('Erro na abertura da porta');
      result := '1|';
    end;
  end
  else
    result := '1|';

end;

//---------------------------------------------------------------------------
function TImpFiscalGeneral.Fechar( sPorta:String ) : String;
begin
  if (fHandle <> INVALID_HANDLE_VALUE) then
  begin
    fFuncFechaPorta;
    FreeLibrary(fHandle);
    fHandle := 0;
  end;
  Result := '0|';
end;

//---------------------------------------------------------------------------
function TImpFiscalGeneral.LeituraX : String;
var
  sRet : String;
begin
  sRet := EnviaComando( '51','0' );
  result := Status( 1, sRet );
end;

//---------------------------------------------------------------------------
function TImpFiscalGeneral.ReducaoZ ( MapaRes:String ): String;
var
  sRet : String;
begin
  sRet := EnviaComando( '52','0' );
  result := Status( 1, sRet );
end;

//---------------------------------------------------------------------------
function TImpFiscalGeneral.LeAliquotas:String;
var
  sRet : String;
  i : Integer;
  sAliquota,sAux : String;
begin
  sRet := EnviaComando( '60' );
  For i:=0 to 15 do
  begin
    sAux := copy(sRet,(i*5)+15,5);
    if (copy(sAux,1,1) = 'T') and (copy(sAux,2,4) <> '0000')then
      sAliquota := sAliquota + FloatToStrf(StrToFloat(copy(sAux,2,4))/100,ffFixed,18,2) + '|';
  end;
  result := Status( 1,sRet );
  if result = '0' then
    result := result + '|' + sAliquota;
end;

//---------------------------------------------------------------------------
function TImpFiscalGeneral.LeAliquotasISS:String;
var
  sRet : String;
  i : Integer;
  sAliquota,sAux : String;
begin
  sRet := EnviaComando( '60' );
  For i:=0 to 15 do
  begin
    sAux := copy(sRet,(i*5)+15,5);
    if (copy(sAux,1,1) = 'S') and (copy(sAux,2,4) <> '0000')then
      sAliquota := sAliquota + FloatToStrf(StrToFloat(copy(sAux,2,4))/100,ffFixed,18,2) + '|';
  end;
  result := Status( 1,sRet );
  if result = '0' then
    result := result + '|' + sAliquota;
end;

//---------------------------------------------------------------------------
function TImpFiscalGeneral.LeCondPag:String;
var
  sRet1, sRet2, sRet : String;
  sPagto : String;
  sAux : String;
  i : Integer;
begin
  sRet1 := EnviaComando( '61','1' );
  sRet2 := EnviaComando( '62','2' );
  sRet := copy(sRet1,15,Length(sRet1)) + copy(sRet2,15,Length(sRet2));

  sPagto := '';
  For i:=0 to 29 do
  begin
    sAux := Trim(copy(copy(sRet,(i*16)+1,16),1,15));
    if sAux <> '' then
      sPagto := sPagto + sAux + '|';
  end;

  result := Status( 1,sRet1 );
  if copy(result,1,1) = '0' then
    result := result + '|' + sPagto;
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.AbreCupom(Cliente:String; MensagemRodape:String):String;
var
  sRet : String;
begin
  sRet := EnviaComando( '20','0' );
  result := Status( 1, sRet );

end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.PegaCupom(Cancelamento:String):String;
var
  sRet : String;
begin
  sRet := EnviaComando( '65', '1' );
  result := Status( 1,sRet );
  if result = '0' then
    result := result + '|' + copy(sRet,15,6);
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.PegaPDV:String;
var
  sRet : String;
begin
  sRet := EnviaComando( '64' );
  result := Status( 1,sRet );
  if result = '0' then
     result := result + '|' + copy(sRet,110,4);
end;

//---------------------------------------------------------------------------
function TImpFiscalGeneral.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var
  sRet : String;
begin
  sRet := EnviaComando( '25',FormataTexto(numitem,3,0,2) );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.CancelaCupom( Supervisor:String ):String;
var
  sRet : String;
begin
  sRet := EnviaComando( '64' );
  result := Status( 1,sRet );
  if result = '0' then
  begin
    if copy(sRet,7,3) = '000' then  // cupom fechado
      sRet := EnviaComando( '2A' )
    else
      sRet := EnviaComando( '29' );
    result := Status( 1,sRet );

    // verifica se foi impresso apenas o cabecalho
    if copy(sRet,7,3) = '001' then
      result := '1';
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
var
  sRet : String;
  sAliquota,sAux : String;
  sLinha : String;
  sPos : String;
  sSituacao : String;
  i : Integer;
begin
  //verifica se é para registrar a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    if StrToFloat(vlrdesconto) > 0 then
    begin
      sRet := EnviaComando( '26','20000'+FormataTexto(vlrdesconto,12,2,2) );
      result := Status( 1,sRet );
    end
    else
      result := '0';
    exit;
  end;

  //verifica a aliquota a ser utilizada
  sSituacao := copy(aliquota,1,1);

  sPos := '00';
  if Pos(sSituacao,'IFN') > 0 then      // Isento, nao tributado ou subst.trib.
    if sSituacao = 'I' then
      sPos := '17'
    else if sSituacao = 'F' then
      sPos := '18'
    else
      sPos := '19'
  else                                  // tributado ICMS ou ISS
  begin
    aliquota := FloatToStrf(StrToFloat(Trim(copy(aliquota,2,5))),ffFixed,18,2);
    sRet := EnviaComando( '60' );
    if status(1,sRet) = '0' then
    begin
      // le as aliquotas cadastradas na impressora
      For i:=0 to 15 do
      begin
        sAux := copy(sRet,(i*5)+15,5);
        if copy(sAux,2,4) <> '0000' then
          sAliquota := sAliquota + copy(sAux,1,1) + FloatToStrf(StrToFloat(copy(sAux,2,4))/100,ffFixed,18,2) + '|';
      end;
      if Pos(sSituacao+aliquota,sAliquota) > 0 then
      begin
        // verifica qual o totalizador que esta a aliquota
        if (Pos(sSituacao+aliquota,sAliquota) mod 5) > 0 then
          sPos := IntToStr((Pos(sSituacao+aliquota,sAliquota) div 5) + 1)
        else
          sPos := IntToStr(Pos(aliquota,sAliquota) div 5);
        sPos := FormataTexto(sPos,2,0,2);
      end;
    end;
  end;

  if sPos = '00' then
  begin
    result := '1';   // aliquota nao cadastrada;
    exit;
  end
  else
  begin
    // monta a linha para registrar o item
    sLinha := '';
    sLinha := sLinha + copy(codigo+space(13),1,13);
    sLinha := sLinha + copy(descricao+space(28),1,28);
    sLinha := sLinha + FormataTexto(qtde,7,3,2);
    sLinha := sLinha + FormataTexto(vlrUnit,8,2,2);
    sLinha := sLinha + '2'; // casas decimais
    sLinha := sLinha + FormataTexto(FloatToStr(StrToFloat(qtde)*StrToFloat(vlrUnit)),12,2,2); // valor total
    sLinha := sLinha + sPos; // aliquota
    sRet := EnviaComando( '21',sLinha );
  end;

  result := Status( 1,sRet);

  // verifica o desconto
  if result = '0' then
    if StrToFloat(vlrdesconto) > 0 then
    begin
      sRet := EnviaComando( '26','20000'+FormataTexto(vlrdesconto,12,2,2) );
      result := Status( 1,sRet );
    end;


end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.AbreECF:String;
var
  sRet : String;
begin
  sRet := EnviaComando( '64' );
  result := Status( 1,sRet );
  if result = '0' then
  begin
    sRet := EnviaComando( '50' );
    result := Status( 1,sRet );
  end;
end;

//---------------------------------------------------------------------------
function TImpFiscalGeneral.FechaECF : String;
var
  sRet : String;
begin
  sRet := EnviaComando( '52','0' );
  result := Status( 1, sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;
  function AchaPagto( sPagto:String; aPagtos:Array of String ):String;
  var
    i : Integer;
    iPos : Integer;
  begin
    iPos := 0;
    for i:=0 to Length(aPagtos)-1 do
      if Trim(UpperCase(aPagtos[i])) = Trim(UpperCase(sPagto)) then
        iPos := i + 1;
    result := IntToStr(iPos);
    if Length(result) < 2 then
      result := '0' + result;
  end;
var
  sRet : String;
  sPagto : String;
  aPagto,aAuxiliar : TaString;
  i : Integer;
begin
  // Faz a checagem do Parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Pega a condicao de pagamento
  sPagto := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  // Monta array com as formas de pagto solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Verifica a forma de pagamento.
  i:=0;
  While i<Length(aAuxiliar) do
  begin
    if AchaPagto(aAuxiliar[i],aPagto) <> '00' then
    begin
      Sleep(500);
      sRet := EnviaComando( '22', AchaPagto(aAuxiliar[i],aPagto)+FormataTexto(aAuxiliar[i+1],13,2,2) );
    end;
    Inc(i,2);
  end;
  result := Status( 1,sRet );

end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.FechaCupom( Mensagem:String ):String;
var
  sRet, sMsg : String;
begin
  // Encerra o cupom
  sMsg := Mensagem ;
  sMsg := TrataTags( sMsg );
  sMsg := sMsg + space(168);
  sRet := EnviaComando( '23','0'+Copy(sMsg,1,42)+
                             '0'+Copy(sMsg,43,42)+
                             '0'+Copy(sMsg,85,42)+
                             '0'+Copy(sMsg,127,42)+
                             '0');
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String;
var
  sRet : String;
begin
  if StrToFloat(vlrDesconto) > 0 then
  begin
    // Registra o desconto.
    sRet := EnviaComando( '27', '20000' + FormataTexto(vlrDesconto,12,2,2) );
    result := Status( 1,sRet );
  end
  else
    result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.AcrescimoTotal( vlrAcrescimo:String ): String;
var
  sRet : String;
begin
  // Registra o acrescimo.
  sRet := EnviaComando( '27', '40000' + FormataTexto(vlrAcrescimo,12,2,2) );
  result := Status( 1,sRet );
end;


//----------------------------------------------------------------------------
function TImpFiscalGeneral.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String;
var
  sRet : String;
  sArgumento : String;
begin
  sArgumento := FormataData( DataInicio,2 ) + FormataData( DataFim,2 );
  sRet := EnviaComando( '55',sArgumento );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
begin
  // esse comando só poderá ser efetuado com intervenção tecnica, 'jumpeando' a placa
  result := '1';
end;
//----------------------------------------------------------------------------
function TImpFiscalGeneral.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
var
  sRet : String;
  sPagto : String;
  aPagto : TaString;
  i : Integer;
  iPos : Integer;
  sPos : String;
begin
  sRet := EnviaComando( '20','1' );
  result := Status( 1,sRet );
  if Pos(copy(sRet,10,3),'047,064') > 0 then
  begin
    sPagto := LeCondPag;
    MontaArray( copy(sPagto,3,Length(sPagto)),aPagto );
    iPos := 0;
    For i:=0 to Length(aPagto)-1 do
    begin
      if (UpperCase(Trim(aPagto[i])) = UpperCase(Trim(Condicao))) then
        iPos := i + 1;
    end;
    sPos := IntToStr(iPos);
    sRet := EnviaComando( '41', Totalizador + FormataTexto(sPos,2,0,2) + FormataTexto(Valor,13,2,2) );
    result := Status( 1,sRet );
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
var
  sRet : String;
  sLinha : String;
  i : Integer;
begin
  // faz a checagem do texto.
  i:=1;
  sLinha := '';
  while i <= Length(Texto) do
  begin
    if copy(Texto,i,1) = #10 then
    begin
      sRet := EnviaComando( '42', '0'+Copy(sLinha+Space(42),1,42) );
      sLinha := '';
    end
    else
      sLinha := sLinha + copy(Texto,i,1);
    Inc(i);
  end;
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.FechaCupomNaoFiscal: String;
var
  sRet : String;
begin
  sRet := EnviaComando( '43' );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var
  sRet : String;
begin
  sRet := EnviaComando( '2B' );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
{function TImpFiscalGeneral.Suprimento( Tipo:Integer;Valor:String ):String;
begin
  if Tipo = 1 then
    result := '0'
  else
    result := '1';
end;
}
//----------------------------------------------------------------------------
{function TImpFiscalGeneral.Gaveta:String;
var
  iRet : Integer;
begin
  iRet := EnviaComando( 'T' );
  result := Status( 1,IntToStr(iRet) );
end;
}
//----------------------------------------------------------------------------
function TImpFiscalGeneral.Status( Tipo:Integer; Texto:String ):String;
begin
  case Tipo of
    1 : if copy(Texto,1,1) = '+' then
            result := '0'
        else
            if copy(Texto,5,1) = '1' then
                result := '2'    // sem papel
            else
                result := '1';
    else
      result := '0';
    end;

end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.StatusImp( Tipo:Integer ):String;
var
  sRet : String;
  sData,sHora : String;
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
// 43 e 44- Reservado Autocom
// 45  - Modelo Fiscal
// 46 - Marca, Modelo e Firmware

// Verifica a hora da impressora
If Tipo = 1 then
begin
  sRet := EnviaComando( '64' );
  result := Status( 1,sRet );
  if result = '0' then
  begin
    sHora := copy(sRet,23,4);
    result := result + '|' + copy(sHora,1,2) + ':' + copy(sHora,3,2) + ':00';
  end;
end
// Verifica a data da Impressora
else if Tipo = 2 then
begin
  sRet := EnviaComando( '64' );
  result := Status( 1,sRet );
  if result = '0' then
  begin
    sData := copy(sRet,15,8);
    result := result + '|' + copy(sData,1,2) + '/' + copy(sData,3,2) + '/' + copy(sData,7,2);
  end;
end
// Verifica o estado do papel
else if Tipo = 3 then
begin
  sRet := EnviaComando( '64' );
  result := Status( 1,sRet );
  if result = '0' then
  begin
    if copy(sRet,6,1) = '1' then
      result := '2' // sem papel
    else
      result := '0' // com papel
  end;
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
begin
  sRet := EnviaComando( '64' );
  result := Status( 1,sRet );
  if result = '0' then
    if copy(sRet,7,3) = '000' then  // cupom fechado
      result := '0'
    else
      result := '7';
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  sRet := EnviaComando( '64' );
  WriteLog( 'log.txt', sRet );
  result := Status( 1,sRet );
  if result = '0' then
    if Pos(copy(sRet,10,3),'097,093') > 0 then
      result := '10'
    else
      result := '0';
end
//  9 - Verifica o Status do ECF
else if Tipo = 9 then
  result := '0'
// 10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 then
  result := '0'
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 then
  result := '1'
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
  //Retorno não encontrado
else
  Result := '1';

end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.EnviaComando( sComando:String;sArgumento:String='' ):String;
var
  iRet2 : Integer;
  pRet : array[0..256] of char;
  pStatus1 : array[0..1] of char;
  pStatus2 : array[0..1] of char;
  pRetBit : array[0..8] of char;
begin
  fFuncEnviaComando( PChar(sComando+sArgumento) );
  iRet2 := fFuncLeRetorno( @pRet,@pStatus1,@pStatus2 );
  if iRet2 > 0 then
    result := '+'
  else
    result := '-';

  // retorno do status 1
  fFuncAnalisaByte(@pStatus1,@pRetBit);
  result := result + Trim(StrPas(pRetBit));

  // retorno do status 2
  result := result + FormataTexto(IntToStr(ord(pStatus2[0])),3,0,2) ;

  // retorno do comando
  result := result + strpas( pRet );

end;

//----------------------------------------------------------------------------
procedure TImpFiscalGeneral.PulaLinha( iNumero:Integer );
begin
  EnviaComando( '44', FormataTexto(IntToStr(iNumero),2,0,2));
end;


//----------------------------------------------------------------------------
function TImpFiscalGeneral.RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String) : String;
begin
  Result := RelatorioGerencial(cTextoImp , nVias , ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.RelatorioGerencial( Texto:String;Vias:Integer ; ImgQrCode: String):String;
var
  sRet : String;
  sAux : String;
begin
  sRet := EnviaComando( '51','1' );
  result := Status( 1,sRet );
  If result = '0' then
  begin
    Texto := LimpaAcentuacao( Texto );
    While (Length(Texto) > 0) and (Texto <> #10) do
    begin
      sAux := copy(Texto,1,Pos(#10,Texto)-1);
      Texto := copy(Texto,Pos(#10,Texto)+1,Length(Texto));
      sRet := EnviaComando( '57', '0'+copy(sAux+Space(42),1,42) );
      if Status( 1,sRet ) <> '0' then
        exit;
    end;
    result := Status( 1,sRet );
    if result = '0' then
      EnviaComando( '56' );
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.PegaSerie : String;
begin
    result := '1|Funcao nao disponivel';
end;

//-----------------------------------------------------------
function TImpFiscalGeneral.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
begin
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalGeneral.RecebNFis( Totalizador, Valor, Forma:String ): String;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;
//------------------------------------------------------------------------------
function TImpFiscalGeneral.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalGeneral.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalGeneral.TotalizadorNaoFiscal( Numero,Descricao:String ) : String;
begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalGeneral.LeTotNFisc:String;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
function TImpFiscalGeneral.DownMF(sTipo, sInicio, sFinal : String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalGeneral.RedZDado(  MapaRes : String ):String;
begin
     Result := '0';
end;

//------------------------------------------------------------------------------
function TImpFiscalGeneral.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalGeneral.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalGeneral.ImpTxtFis(Texto : String) : String;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
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

//----------------------------------------------------------------------------
function TImpFiscalGeneral.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
  RegistraImpressora('FUJITSU IF GP-2000 - V. 01.00', TImpFiscalGeneral, 'BRA', ' ');

//----------------------------------------------------------------------------
end.
