unit ImpYanco;
interface

Uses
  Dialogs,
  ImpFiscMain,
  Windows,
  SysUtils,
  classes,
  LojxFun,
  Forms,
  CommInt;

Type
  TYanco = class(TCustomComm)
  protected
      procedure Comm1RxChar(Sender: TObject; Count: Integer);
      procedure Comm1Error(Sender: TObject; Errors: Integer);
  public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

  TImpFiscalYanco = class(TImpressoraFiscal)
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function LeituraX:AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override;
    function PegaPDV:AnsiString; override;
    function LeAliquotas:AnsiString; override;
    function LeAliquotasISS:AnsiString; override;
    function LeCondPag:AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function GravaCondPag( condicao:AnsiString ):AnsiString; override;
    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function AbreEcf:AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function CancelaCupom( Supervisor:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function ReducaoZ( MapaRes:AnsiString ):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString;Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    procedure AlimentaProperties; override;
    function PegaSerie:AnsiString; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString ; override;
    function RedZDado( MapaRes:AnsiString ):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
  end;

  Function FncSequencia:AnsiString;
  function EnviaComando(sCmd:AnsiString): AnsiString;
  Function TrataTags( Mensagem : AnsiString ) : AnsiString;

//----------------------------------------------------------------------------
implementation
//----------------------------------------------------------------------------
var
  Comm1 : TYanco;
  sRetorno : AnsiString;
  bRet : Boolean;

//------------------------------------------------------------------------------
constructor TYanco.Create(AOwner: TComponent);
begin
  inherited;
end;

//------------------------------------------------------------------------------
destructor TYanco.Destroy;
begin
  inherited;
end;
//------------------------------------------------------------------------------
function TImpFiscalYanco.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
  Comm1 := TYanco.Create(Application);
  Comm1.OnRxChar := Comm1.Comm1RxChar;
  Comm1.BaudRate := br9600;
  Comm1.Databits := da8;
  Comm1.Parity   := paNone;
  Comm1.StopBits := sb10;
  Comm1.DeviceName := sPorta;
  try
    //Abre a porta serial
    Comm1.Open;
    Comm1.SetRTSState(True);
    Comm1.SetDTRState(True);
    Comm1.SetBREAKState(False);
    Comm1.SetXONState(True);
    result := '0';
    AlimentaProperties;
  except
    result := '1';
  end;
end;

//---------------------------------------------------------------------------
function TImpFiscalYanco.Fechar( sPorta:AnsiString ) : AnsiString;
begin
 //Fecha porta serial
  Comm1.Close;
  Comm1.Free;
  result := '0|';
end;
//---------------------------------------------------------------------------
function TImpFiscalYanco.LeituraX: AnsiString;
var
  sRet : AnsiString;
begin
  sRet:=EnviaComando( '241             ');
  if copy(sRet,7,2)='00' then
     result := '0|'
  else
     result := '1|'
end;
//---------------------------------------------------------------------------
function TImpFiscalYanco.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  sRet,sCup : AnsiString;
begin
  sCup:='0000';
  sRet := EnviaComando( '2E');
  sRet:=copy(sRet,766,6);
  if StrToInt(sRet)>0 then
     Begin
     sCup:=sRet;
     sRet:=StatusImp( 5 );
     if Copy(sRet,1,1)='0' then
        sCup:=FormataTexto( IntToStr(StrToInt(sCup)-1),6,0,2);

     result :='0|'+sCup;
     end
  else
     result := '1|'
end;
//---------------------------------------------------------------------------
function TImpFiscalYanco.PegaPDV:AnsiString;
begin
  result :='0|'+PDV
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.LeAliquotas:AnsiString;
Begin
  result :='0|'+ICMS;
end;
//---------------------------------------------------------------------------
function TImpFiscalYanco.LeAliquotasISS:AnsiString;
Begin
  result :='0|'+ISS;
end;
//---------------------------------------------------------------------------
function TImpFiscalYanco.LeCondPag:AnsiString;
Begin
  Result := '0|'+FormasPgto;
end;
//---------------------------------------------------------------------------
function TImpFiscalYanco.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;
//---------------------------------------------------------------------------
function TImpFiscalYanco.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
var
 sAliq : AnsiString;
 sRet  : AnsiString;
 sAux  : AnsiString;
begin
  { Colocar a chamada da funcao de aliquota separadas por tipo, ou seja ICMS E TRATA-LA COMO SE FOSSO TODAS}
  Aliquota := FormataTexto(Aliquota,4,2,2);
  if Tipo=1 then
     Aliquota:='T'+Aliquota
  else
     Aliquota:='S'+Aliquota;
  sRet:='';

  sRet   := EnviaComando( '2E');
  if Trim(sRet)='' then
     Begin
     result := '1|';
     exit;
     end;

  sAux   :=copy(sRet,7,80);
  sAliq  :='';
  While Trim(sAux)<>'' do
     begin
     if copy(sAux,1,5)=Aliquota then
        begin
        result := '1';
        ShowMessage('Alíquota já cadastrada.');
        exit;
        end;
     if ( StrToInt(copy(sAux,2,4))=0 ) and ( Trim(Aliquota)<>'' ) and ( Pos( copy(sAux,1,1),'FN' )=0 ) then
        Begin
        sAliq:=sAliq+Aliquota;
        Aliquota:='';
        end
     else
        sAliq:=sAliq+copy(sAux,1,5);

     sAux:=copy(sAux,6,length(sAux));
     end;

  sRet :='11';
  if Trim(Aliquota)<>'' then
     begin
     ShowMessage('Não há espaço para cadastros de aliquotas');
     Result:='1';
     exit;
     end
  else
     sRet := EnviaComando( '04'+sAliq);

  if copy(sRet,7,2)='00' then
     Begin
     result := '0|';
     AlimentaProperties;
     end
  else
     result := '1|'
end;
//---------------------------------------------------------------------------
function TImpFiscalYanco.GravaCondPag( condicao:AnsiString ):AnsiString;
Var
  sRet     : AnsiString;
  sCond    : AnsiString;
  sAux     : AnsiString;
  sForma   : AnsiString;
  begin

  sRet   := EnviaComando( '2E');
  if Trim(sRet)='' then
     Begin
     result := '1|';
     exit;
     end;

  sAux     :=copy(sRet,104,450);
  sCond    :='';
  Condicao :=Trim(UpperCase(Condicao));
  While Trim(sAux)<>'' do
     begin
     sForma:=Trim(UpperCase(copy(sAux,1,15)));
     if sForma=Condicao then
        begin
        result := '1';
        ShowMessage('Forma de pagamento já cadastrada.');
        exit;
        end
     else
       if ( sForma='---' ) and ( Trim(Condicao)<>'' )  then
          Begin
          sCond:=sCond+Copy(Condicao+space(16),1,15);
          Condicao:='';
          end
       else
          sCond:=sCond+Copy(sForma+space(16),1,15);

        sAux:=copy(sAux,16,length(sAux));
     end;
  if Trim(Condicao)<>'' then
     begin
     ShowMessage('Não há espaço para cadastros de Formas de pagamentos');
     Result:='1';
     exit;
     end
  else
     sRet := EnviaComando( '0E'+sCond);

  if copy(sRet,7,2)='00' then
     Begin
     result := '0|';
     AlimentaProperties;
     end
  else
     result := '1|'

end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
var
  sRet : AnsiString;
begin
  sRet := EnviaComando( '130');

  if copy(sRet,7,2)='00' then
     result := '0|'
  else
     result := '1|'
end;
//----------------------------------------------------------------------------

function TImpFiscalYanco.AbreEcf:AnsiString;
begin
  //Funcao Inicio do Dia
  EnviaComando( '121             ');
  result := '0|';
End;
//----------------------------------------------------------------------------
function TImpFiscalYanco.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString ;
var
  sRet : AnsiString;
  sTot : AnsiString;
  sTipo: AnsiString;
  sAux : AnsiString;
  iPos : Integer;
begin
  //verifica se é para registra a venda do item ou só o desconto
  if ( Trim(codigo+descricao)='') and ( StrToFloat(vlrdesconto)>0.00 ) then
     begin
     vlrDesconto:=FormataTexto(vlrDesconto,12,3,2);
     sRet := EnviaComando( '18'+vlrDesconto+'00000');
     if copy(sRet,7,2)='00' then
        result := '0|'
     else
        result := '1|';
     exit;
     end;

  Codigo   :=Copy(Codigo+space(13),1,13);
  Descricao:=Copy(Descricao+space(30),1,30);
  sTot     := FloatToStr(StrToFloat(vlrUnit)*StrToFloat(qtde));
  if Pos('.',sTot)=0 then
     sTot:=sTot+'.00';

  vlrDesconto:=FormataTexto(vlrDesconto,12,3,2);
  vlrUnit  := FormataTexto(vlrUnit,9,3,2);

  qtde := FormataTexto(qtde,7,3,2);

  sTot := FormataTexto(sTot,12,3,2);

  sTipo:= Copy(Aliquota,1,1);
  Aliquota := Copy(Aliquota,2,5);
  if trim(aliquota)='' then
     aliquota :='0000'
  Else
     Aliquota := FormataTexto(Aliquota,4,2,2);

  Aliquota:=sTipo+Aliquota;
  sRet:='';
   //Pega variavel alimentada pela função proprietes
  sAux   :=Aliquotas;
  sRet:='';
  if Trim(sAux)='' then
     Begin
     result := '1|';
     exit;
     end;
  sRet   := '11';
  iPos   := 0;
  Result := '0';
  While Trim(sAux)<>'' do
     begin
     Inc(iPos);
     if copy(sAux,1,5)=Aliquota then
        begin
        Result:= IntToStr(iPos);
        Break;
        end;

     sAux:=copy(sAux,6,length(sAux));
     end;

  if Result='0'  then
     begin
     ShowMessage('Aliquota não cadastrada');
     Result:='1';
     exit;
     end
  else
     Begin
     sTipo:=FormataTexto(Result,2,0,2);
     sRet := EnviaComando( '14'+Codigo+Descricao+vlrUnit+qtde+sTot+sTipo+'0');
     if ( copy(sRet,7,2)='00' ) and (  StrToInt(vlrDesconto)>0 ) then
        sRet := EnviaComando( '18'+vlrDesconto+'00000')

     end;

  if copy(sRet,7,2)='00' then
     result := '0|'
  else
     result := '1|'
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;
var
  sRet,sAux,sVal,sForma : AnsiString;
  aAuxiliar      : TaString;
  iPos,i         : Integer;
begin
  // registra as formas de pagamento
  MontaArray( Pagamento,aAuxiliar );
  sForma := FormasPgto;
  sRet:='';
  if Trim(sForma)='' then
     Begin
     result := '1|';
     exit;
     end;

  for i:= 0 to high(aAuxiliar) do
      Begin
      iPos:=0;
      sAux:=sForma;
      While ( Trim(sAux)<>'' ) and (i mod 2 = 0) do
         begin
         Inc(iPos);
         if UpperCase(Trim(Copy(sAux,1,Pos('|',sAux)-1)))=UpperCase(Trim(aAuxiliar[i])) then
             Begin
             sRet:='11';
             sVal:=FormataTexto(aAuxiliar[i+1],13,2,1);
             sVal:=StrTran(sVal,'.','');
             sRet := EnviaComando( '15'+FormataTexto(IntToStr(iPos),2,0,2)+sVal);
             if copy(sRet,7,2)<>'00' then
                Begin
                result := '1|';
                exit;
                end;

             Break;
             end;
         sAux:=Copy(sAux,Pos('|',sAux)+1,Length(sAux))
         end;
      end;
  result :='0|';
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.FechaCupom( Mensagem:AnsiString ):AnsiString;
var
  sRet : AnsiString;
  cMsg : AnsiString ;
begin
  If Trim(Mensagem) <> '' then
  begin
    cMsg := Mensagem;
    cMsg := TrataTags( cMsg );
  end;

  cMsg:=Copy(cMsg+space(168),1,168);  
  sRet := EnviaComando( '1600'+cMsg);

  if copy(sRet,7,2)='00' then
     result := '0|'
  else
     result := '1|'
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString;
var
  sRet : AnsiString;
begin
  vlrDesconto:=FormataTexto(vlrDesconto,13,3,2);
  if StrToInt(vlrDesconto)>0 then
     begin
     sRet := EnviaComando( '1B'+vlrDesconto+'00000');
     if copy(sRet,7,2)='00' then
        result := '0|'
     else
        result := '1|';
     end
  else
     result := '0|';

end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var
  sRet : AnsiString;
begin
  vlrAcrescimo:=FormataTexto(vlrAcrescimo,13,3,2);
  if StrToInt(vlrAcrescimo)>0 then
     Begin
     sRet := EnviaComando( '1B'+vlrAcrescimo+'00002');
     if copy(sRet,7,2)='00' then
        result := '0|'
     else
        result := '1|';
     end
  else
     result := '0|';
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  sRet : AnsiString;
begin
  NumItem:=FormataTexto(NumItem,3,0,2);
  Descricao:=Copy(Descricao+space(22),1,22);
  sRet := EnviaComando( '35'+NumItem+Descricao);
  if copy(sRet,7,2)='00' then
     result := '0|'
  else
     result := '1|'
end;

//----------------------------------------------------------------------------
function TImpFiscalYanco.CancelaCupom( Supervisor:AnsiString ):AnsiString;
var
  sRet : AnsiString;
begin
  sRet:=StatusImp( 5 );
  if Copy(sRet,1,1)='1' then
     Begin
     sRet := EnviaComando( '1D');
     if copy(sRet,7,2)='00' then
        result := '0|'
      else
         result := '1|'
      end
  Else
     Begin
     sRet := EnviaComando( '1E');
     if copy(sRet,7,2)='00' then
        result := '0|'
     else
        result := '1|'
     end;
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.ReducaoZ( MapaRes:AnsiString ):AnsiString;
var
  sRet : AnsiString;
begin
  //Redução Z
  sRet:=EnviaComando( '22             ');
  if copy(sRet,7,2)='00' then
     Begin
     // Inicio do Dia.
     sRet := EnviaComando( '121             ');
     if copy(sRet,7,2)='00' then
        result := '0|'
     else
        result := '1|'
     end
  else
     result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalYanco.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalYanco.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString;
var
  sRet : AnsiString;
begin
  if ( StrToInt(Numero) < 4 ) and ( StrToInt(Numero) > 8 ) then
     Begin
     ShowMessage('Utilize os registradores de 5 à 8');
     Result:='1|';
     exit;
     end;
  if ( Trim(Descricao)= '' ) then
     Begin
     ShowMessage('Defina uma descrição para o totalizador');
     Result:='1|';
     exit;
     end;

  Numero   :=FormataTexto(Numero,1,0,2);
  Descricao:=Copy(Descricao+space(15),1,15);

  sRet:=EnviaComando( '10'+Numero+Descricao );
  if copy(sRet,7,2)='00' then
     result := '0|'
  else
     result := '1|'
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.AbreCupomNaoFiscal(Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString;
var
    sRet,sAux,sCondicoes : AnsiString;
    iCont : Integer;
    bOk : Boolean;
begin
    //Definicao de variaveis
    bOk        := True;
    iCont      := -1;
    sCondicoes := LeCondPag;

    while bOk do
    Begin

      //Verifico se existe condicao de pagamento cadastrada na impressora
      If Pos('|',sCondicoes) <= 0 Then
      Begin
        ShowMessage('Forma de Pagento não cadastrada na impressora fiscal.');
        result := '1|';
        bOk := False;
      End;

      //Verifico se a condicao no qual foi digitado, esta cadastrada na impressora
      //para que eu saiba sua sequencia e envie para a impressora.
      iCont := iCont +1 ;
      If Copy(sCondicoes,1,Pos('|',sCondicoes)-1) = UpperCase(Trim(Condicao)) Then
      Begin
        Totalizador:=FormataTexto(Totalizador,2,0,2);
        Valor:= StrTran(Valor,'.','');
        Valor:= FormataTexto(Valor,13,1,2);

        //Preencho com zero a esquerda (2 digitos).
        If iCont < 10 Then
          sAux := '0'+IntToStr(iCont)
        Else
          sAux := IntToStr(iCont);

        //Envio o comando para a impressora
        sRet:=EnviaComando( '29'+Totalizador+sAux+Valor );

        //Se eu obter um resultado positivo da impressora
        if copy(sRet,7,2)='00' then
            result := '0|'
        else
            result := '1|';

        //Apos a execucao, nao preciso mais realizar um loop
        bOk := False
      End
      Else
        //Caso nao seja a condicao no qual o usuario digitou, retiro a mesma
        //da AnsiString para realizar uma nova verificacao logo acima.
        sCondicoes := Copy(sCondicoes,Pos('|',sCondicoes)+1,Length(sCondicoes))
    End;
End;
//----------------------------------------------------------------------------
function TImpFiscalYanco.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  sRet : AnsiString;
  i    : Integer;
begin
  if Vezes>4 then
     Begin
     ShowMessage('Maximo de Autenticação é 4');
     Result:='1|';
     exit;
     end;

  For i:= 1 to Vezes do
     Begin
     ShowMessage('Posicione o Documento para '+IntToStr(i)+'a. Autenticação');
     sRet:=EnviaComando( '30');
     if copy(sRet,7,2)<>'00' then
        Begin
        result := '1|';
        exit;
        end;
     end;
  result := '0|'
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.FechaCupomNaoFiscal: AnsiString;
Begin
  result := '0|';
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.TextoNaoFiscal(Texto:AnsiString;Vias:Integer  ):AnsiString;
var
  sRet   : AnsiString;
  i      : Integer;
  sLinha : AnsiString;
begin
  i:=1;
  sLinha := '';
  while i <= Length(Texto) do
  begin
    if (copy(Texto,i,1) = #10) or (Length(sLinha)>=46) then
      begin
      sRet:=EnviaComando( '2B0'+sLinha);
      if copy(sRet,7,2)<>'00' then
         Begin
         result := '1|';
         exit;
         end;
      sLinha := '';
      end
    else
      sLinha := sLinha + copy(Texto,i,1);
    Inc(i);
  end;
  result := '0|';
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString;
Var
  sRet: AnsiString;
Begin
  sRet:=FormataData(DataInicio,1);
  sRet := EnviaComando('28'+FormataData(DataInicio,1)+FormataData(DataFim,1)+'1');
  if copy(sRet,7,2)='00' then
     result := '0|'
  else
     result := '1|'
end;
//----------------------------------------------------------------------------
function TImpFiscalYanco.StatusImp( Tipo:Integer ):AnsiString;
//Tipo - Indica qual o status quer se obter da impressora
//  1 - Obtem a Hora da Impressora
//  2 - Obtem a Data da Impressora
//  3 - Verifica o Papel
//  4 - Verifica se é possível cancelar um ou todos os itens.
//  5 - Cupom Fechado ?
//  6 - Ret. suprimento da impressora
//  7 - ECF permite desconto por item
//  8 - Verica se o dia anterior foi fechado
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

var
  sRet : AnsiString;
begin
  sRet:='1|';
  if Tipo = 1 then
     Begin
     sRet := EnviaComando( '2E');
     sRet:='0|'+Copy(sRet,740,5)+':00'
     end
  Else if Tipo = 2 then
     Begin
     sRet := EnviaComando( '2E');
     sRet:='0|'+Copy(sRet,747,8)
     end
  Else if Tipo = 3 then
     Begin
     sRet := EnviaComando('25');
     sRet:=Copy(sRet,15,1)+'|';
     end
  Else if Tipo = 4 then
     sRet:='0|Todos'
  Else if Tipo = 5 then
     Begin
     sRet := EnviaComando('25');
     sRet:=Copy(sRet,17,2);
     if sRet='1\' then
        sRet:='0|'
     else
        sRet:='1|';
     end
  //6 - Ret. suprimento da impressora
  Else if Tipo = 6 then
      sRet := '0.00'
  //7 - ECF permite desconto por item
  Else if Tipo = 7 then
     sRet := '0|'
  //8 - Verica se o dia anterior foi fechado
  Else if Tipo = 8 then
     sRet := '1'
  //9 - Verifica o Status do ECF
  Else if Tipo = 9 then
     sRet := '0'
  //10 - Verifica se todos os itens foram impressos.
  Else if Tipo = 10 then
     sRet := '0'
  //11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  Else if Tipo = 11 then
     sRet := '1'
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  Else if Tipo = 12 then
     sRet := '1'
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  Else if Tipo = 13 then
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

  result :=sRet
end;
//----------------------------------------------------------------------------

procedure TYanco.Comm1Error(Sender: TObject; Errors: Integer);
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
procedure TYanco.Comm1RxChar(Sender: TObject; Count: Integer);
var
  Buffer  : array[0..1024] of Char;
  Bytes, P: Integer;
  bInic   : Boolean;

begin
  if trim(sRetorno)='' then
    bInic:= false
  else
    bInic:= True;

  Fillchar(Buffer, Sizeof(Buffer), 0);
  Bytes := Comm1.Read(Buffer, Count);
  if Bytes = -1 then
    ShowMessage('Erro de leitura da resposta do comando')
  else
  begin
    for P := 0 to Bytes do
      case Buffer[P] of
        #10: begin
               // Memo2.Lines.add('');
               // Inc(FCurrentLine);
             end;
        #03: begin
             bRet:= True;
             Break;
             end;
        #02: begin
             bInic:= True;
             end;
        #0: begin
            Break;
            end;

        #13:;
         else
           begin
              if bInic then
                sRetorno:=sRetorno+Buffer[P];
           end;
      end;
  end;
end;
//---------------------------------------------------------------------------
function EnviaComando(sCmd:AnsiString): AnsiString;
var
  soma,sSeq : AnsiString;
  checksum,i:integer;
  sMens     : AnsiString;
  iVz       : Integer;

begin
  sRetorno:='';
  sMens   :='';
  bRet := false;
  iVz:=0;
  sSeq:=FncSequencia;
  soma := chr(2)+ sSeq+sCmd+ chr(3);
   //Calcula o checksum do pacote
   checksum:=0;
   for i:=1 to length(soma) do
      checksum:=checksum+ord(soma[i]);

   soma := soma + chr(Checksum div 256)+chr(checkSum mod 256);
   Comm1.Write(Soma[1], Length(Soma));
   while not  bRet and ( iVz< 300 ) do
      begin
      Application.ProcessMessages;
      sleep(100);
      Inc(iVz);
      end;
   if Trim(sRetorno)='' then
      ShowMessage('Falha de comunicação com a impressora');

   if ( sCmd<>'2E') and ( sCmd<>'25') and ( Copy(sRetorno,7,2)<>'00' )and ( sCmd<>'121             ') then
      Begin
      //Mensagem de erro da Impressora Fiscal
      Case StrToInt(copy(sRetorno,7,2)) of
          10 : sMens := 'Fim do papel';
          32 : sMens := 'Função não permitida sem totalização';
          34 : sMens := 'Situação tributária inválida';
          35 : sMens := 'Campo numérico inválido';
          36 : sMens := 'Números não permitido neste campo';
          41 : sMens := 'Função não permitida sem o inicio de operação fiscal';
          42 : sMens := 'Função não permitida sem o inicio de operação não fiscal';
          43 : sMens := 'Função não permitida durante operação fiscal ou não fiscal';
          44 : sMens := 'Função não permitida sem o inicio do Dia';
          45 : sMens := 'Função não permitida sem status de intervenção ou durante operação fiscal ou não fiscal';
          46 : sMens := 'Função não permitida com status de intervenção';
          47 : sMens := 'Função não permitida após inicio do dia';
          48 : sMens := 'Função não permitida sem status de intervenção ou durante operação fiscal ou não fiscal';
          50 : sMens := 'Necessita Redução Z';
          53 : sMens := 'Ultima função não permite a execução deste comando';
          54 : sMens := 'Cupom aberto mas não finalizado';
          55 : sMens := 'Função não permitida sem abertura de relatório X ou Z';
      end;
      if Trim(sMens)<>'' then
         ShowMessage(sMens);

      end;
   result:=sRetorno;
end;
//----------------------------------------------------------------------------
procedure TImpFiscalYanco.AlimentaProperties;
Var
  sRet                      : AnsiString;
  sICMS, sISS, sTodas, sAux : AnsiString;
begin
  sICMS  := '';
  sISS   := '';
  sTodas := '';

  sRet   := EnviaComando( '2E');
  sAux   := copy(sRet,7,80);
  sTodas := sAux;
  if Trim(sAux)='' then
     Begin
     exit;
     end;

  While Trim(sAux)<>'' do
     begin
     if ( copy(sAux,1,1)='T' ) and (StrToFloat(copy(sAux,2,4))>0 ) then
        sICMS:=sICMS+copy(sAux,2,2)+'.'+copy(sAux,4,2)+'|';

     if ( copy(sAux,1,1)='S' ) and (StrToFloat(copy(sAux,2,4))>0 ) then
        sISS:=sISS+copy(sAux,2,2)+'.'+copy(sAux,4,2)+'|';

     sAux:=copy(sAux,6,length(sAux));
  end;

  PDV       := copy(sRet,100,3);
  ICMS      := sICMS;
  ISS       := sISS;
  Aliquotas := sTodas;

  sAux := copy(sRet,104,450);
  sRet := '';

  While Trim(sAux)<>'' do
  begin
     if Trim(copy(sAux,1,15))<>'---' then
        sRet:=sRet+Trim(copy(sAux,1,15))+'|';
        sAux:=copy(sAux,16,length(sAux));
  end;
  FormasPgto := sRet;
End;
//----------------------------------------------------------------------------
Function FncSequencia:AnsiString;
var
  fArq : TextFile;
  sArq:AnsiString;
  sCmd: AnsiString;
begin
  sCmd:='0000';
  sArq:='C:\YANCO.SEQ';
  if FileExists(sArq) Then
     Begin
     AssignFile( fArq,sArq );
     Reset( fArq );
     ReadLn( fArq,sCmd );
     CloseFile( fArq );
     Application.ProcessMessages;
     end;

  if (StrToInt(sCmd)+1)>9999 then
     sCmd:='0000';

  sCmd:=FormataTexto(IntToStr(StrToInt(sCmd)+1),4,0,2);
  AssignFile( fArq,sArq );
  ReWrite( fArq );
  WriteLn( fArq,sCmd );
  CloseFile( fArq );
  Application.ProcessMessages;
  Result:=sCmd;
end;

//----------------------------------------------------------------------------
function TImpFiscalYanco.PegaSerie : AnsiString;
begin
    result := '1|Funcao nao disponivel';
end;

//----------------------------------------------------------------------------
function TImpFiscalYanco.Suprimento( Tipo:Integer;Valor:AnsiString;Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
var
    sTotaliz,sTipo,sRet : AnsiString;
begin
    //Utilizar o totalizador de "Recebimento"
    sTotaliz := '03';
    sTipo    := '  ';

    If Tipo = 1 Then //Caso a opção for igual a checar
        Valor := '0.00';

    Valor:= StrTran(Valor,'.','');
    Valor:= FormataTexto(Valor,13,1,2);

    //Envio o comando para a impressora
    sRet:=EnviaComando( '29'+sTotaliz+sTipo+Valor );

    //Se eu obter um resultado positivo da impressora
    if copy(sRet,7,2)='00' then
        result := '0|'
    else
        result := '1|';
End;

//-----------------------------------------------------------
function TImpFiscalYanco.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
begin
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalYanco.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
var iRet : Integer;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;
//-----------------------------------------------------------------------------
function TImpFiscalYanco.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalYanco.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalYanco.LeTotNFisc:AnsiString;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
function TImpFiscalYanco.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalYanco.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalYanco.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalYanco.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString;
var iRet : Integer;
begin
  Result := '0|Comando não implementado';
end;

//-----------------------------------------------------------------------------
function TImpFiscalYanco.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//-----------------------------------------------------------------------------
function TImpFiscalYanco.RedZDado( MapaRes : AnsiString ):AnsiString;
Begin
  Result := '0';
End;

//----------------------------------------------------------------------------
Function TrataTags( Mensagem : AnsiString ) : AnsiString;
var
  cMsg : AnsiString;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//----------------------------------------------------------------------------
function TImpFiscalYanco.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

(*initialization
  RegistraImpressora('YANCO 8000', TImpFiscalYanco, 'BRA', '470501'); *)

//----------------------------------------------------------------------------
end.
