unit ImpECFEmulator;

interface

uses
  Dialogs,ImpFiscMain,ImpCheqMain,Windows,SysUtils,Classes,IniFiles,LojxFun,Forms;

const
  BufferSize = 1024;

Type

  TImpFiscalECFEmulator = class(TImpressoraFiscal)
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
    function DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString; Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function Status( Tipo:Integer; Texto:AnsiString='' ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function Gaveta:AnsiString; override;
    function Suprimento( Tipo:Integer;Valor:AnsiString;Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString ;Vias:Integer; ImgQrCode: AnsiString):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ):AnsiString; override;
    function PegaSerie:AnsiString; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function Percepcao(sAliqIVA, sTexto, sValor: AnsiString): AnsiString; override;
    function SubTotal (sImprime: AnsiString):AnsiString;override;
    function AbreDNFH( sTipoDoc, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: AnsiString): AnsiString; override;
    function FechaDNFH: AnsiString; override;
    function GravaCondPag( condicao:AnsiString ) : AnsiString; override;
    function ReImprime: AnsiString; override;
    function TextoRecibo (sTexto: AnsiString): AnsiString; override;
    function MemTrab:AnsiString; override;
    function Capacidade:AnsiString; override;
    function AbreNota(Cliente:AnsiString):AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override;
    function RedZDado( MapaRes : AnsiString):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
  end;

  TImpChequeECFEmulator = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar(aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;

  function LeChaves(sKeyName : AnsiString):AnsiString;
  procedure GravaChaves(sKeyName, sValue : AnsiString);
  function LeStatusDoECF : AnsiString;

implementation

//---------------------------------------------------------------------------
function LeChaves(sKeyName : AnsiString):AnsiString;
var
  sPath : AnsiString;
  fArquivo : TIniFile;
begin
   // Pega o Path da SIGALOJA.DLL
   sPath := ExtractFilePath(Application.ExeName);
   try
      fArquivo := TIniFile.Create(sPath+'ECFEMUL.INI');
      Result := fArquivo.ReadString('ECF Emulator', sKeyName, '');
      fArquivo.Free;
   except
      Result := '';
   end;
end;

//---------------------------------------------------------------------------
procedure GravaChaves(sKeyName, sValue : AnsiString);
var
  sPath : AnsiString;
  fArquivo : TIniFile;
  iCont : Integer;
  lContinua : boolean;
begin
   iCont := 1;
   lContinua := True;

   While ((iCont < 10) and (lContinua)) do
   begin
       try
           // Pega o Path da SIGALOJA.DLL
           sPath := ExtractFilePath(Application.ExeName);
           fArquivo := TIniFile.Create(sPath+'ECFEMUL.INI');
           fArquivo.WriteString('ECF Emulator', sKeyName, sValue);
           fArquivo.Free;
           lContinua := False;
           sleep(100);
       except
           lContinua := True;
           Inc( iCont );
       end;
   end;

end;

//---------------------------------------------------------------------------
function LeStatusDoECF : AnsiString;
begin
  if LeChaves('Status do ECF') = 'ON' then
    Result := '0'
  else
    Result := '1';
end;

//---------------------------------------------------------------------------
function TImpFiscalECFEmulator.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Abrir('+sPorta+','+IntToStr(iHdlMain)+') -> '+Result);
end;

//---------------------------------------------------------------------------
function TImpFiscalECFEmulator.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Fechar('+sPorta+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.LeituraX : AnsiString;
Var
  sNumero : AnsiString;
begin
  if LeChaves('Status do ECF') = 'ON' then
  begin
    sNumero := LeChaves('Numero do Cupom Fiscal');
    GravaChaves('Numero do Cupom Fiscal', FormataTexto(IntToStr(StrToInt(sNumero)+1),6,0,2));
    Result := '0';
  end
  else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - LeituraX() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.ReducaoZ( MapaRes:AnsiString ) : AnsiString;
begin
  if LeChaves('Status do ECF') = 'ON' then
  begin
    GravaChaves('Reducao Z', 'ON');
    Result := '0';
  end
  else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - ReducaoZ('+MapaRes+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.AbreECF : AnsiString;
begin
  if LeChaves('Status do ECF') = 'ON' then
  begin
    GravaChaves('Reducao Z', 'OFF');
    Result := '0';
  end
  else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - AbreECF() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.FechaECF : AnsiString;
begin
  if LeChaves('Status do ECF') = 'ON' then
  begin
    GravaChaves('Reducao Z', 'ON');
    Result := '0';
  end
  else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - FechaECF() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString) : AnsiString;
Var
  sNumero : AnsiString;
begin

  If Pos('|', Cliente) > 0 then
    Cliente := Copy( Cliente, 1, (Pos('|',Cliente) - 1));

  If LeChaves('Status do ECF') = 'ON' Then
  Begin
    If LeChaves('Cupom Aberto') = 'OFF' then
    Begin
      sNumero := LeChaves('Numero do Cupom Fiscal');
      GravaChaves('Numero do Cupom Fiscal', FormataTexto(IntToStr(StrToInt(sNumero)+1),6,0,2));
      GravaChaves('Cupom Aberto', 'ON');
      Result := '0|'+LeChaves('Numero do Cupom Fiscal');
    End
    Else
    Begin
      Application.MessageBox('Já existe um cupom aberto...',
        'ECF Emulator', MB_OK + MB_ICONERROR);
      Result := '1';
    End;
  End
  Else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - AbreCupom('+Cliente+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.PegaCupom(Cancelamento:AnsiString): AnsiString;
begin
   if LeChaves('Status do ECF') = 'ON' Then
      Result := '0|'+LeChaves('Numero do Cupom Fiscal')
   else
      Result := '1';
   WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - PegaCupom() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.PegaPDV : AnsiString;
begin
   if LeChaves('Status do ECF') = 'ON' Then
      Result := '0|'+LeChaves('Numero do ECF')
   else
      Result := '1';
   WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - PegaPDV() -> '+Result);
end;

//---------------------------------------------------------------------------
function TImpFiscalECFEmulator.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - ImpostosCupom('+Texto+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - RegistraItem('+Codigo+','+Descricao+','+Qtde+','+VlrUnit+','+VlrDesconto+','+Aliquota+','+VlTotIT+','+UnidMed+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.LeAliquotas : AnsiString;
begin
   if LeChaves('Status do ECF') = 'ON' Then
      Result := '0|'+LeChaves('Aliquotas ICMS')
   else
      Result := '1';
   WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - LeAliquotas() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.LeAliquotasISS : AnsiString;
begin
   if LeChaves('Status do ECF') = 'ON' Then
      Result := '0|'+LeChaves('Aliquotas ISS')
   else
      Result := '1';
   WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - LeAliquotasISS() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.LeCondPag : AnsiString;
begin
   if LeChaves('Status do ECF') = 'ON' Then
      Result := '0|'+LeChaves('Condicoes Pagto')
   else
      Result := '1';
   WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - LeCondPag() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - CancelaItem('+NumItem+','+Codigo+','+Descricao+','+Qtde+','+VlrUnit+','+VlrDesconto+','+Aliquota+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.CancelaCupom( Supervisor:AnsiString ) : AnsiString;
begin
  if LeChaves('Status do ECF') = 'ON' Then
  begin
    GravaChaves('Cupom Aberto', 'OFF');
    Result := '0';
  end
  else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - CancelaCupom('+Supervisor+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.FechaCupom( Mensagem:AnsiString ) : AnsiString;
begin
  if LeChaves('Status do ECF') = 'ON' Then
  begin
    GravaChaves('Cupom Aberto', 'OFF');
    Result := '0';
  end
  else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - FechaCupom('+Mensagem+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Pagamento('+Pagamento+','+Vinculado+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.DescontoTotal( vlrDesconto:AnsiString ;nTipoImp:Integer) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - DescontoTotal('+VlrDesconto+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.AcrescimoTotal( vlrAcrescimo:AnsiString ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - AcrescimoTotal('+VlrAcrescimo+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - MemoriaFiscal() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - AdicionaAliquota() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ) : AnsiString;
var
  sNumero : AnsiString;
begin
  Result := LeStatusDoECF;
  sNumero := LeChaves('Numero do Cupom Fiscal');
  GravaChaves('Numero do Cupom Fiscal', FormataTexto(IntToStr(StrToInt(sNumero)+1),6,0,2));
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - AbreCupomNaoFiscal('+Condicao+','+Valor+','+Totalizador+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ) : AnsiString;
begin
  if LeChaves('Status do ECF') = 'ON' Then
  begin
    if LeChaves('Simula Erro TextoNaoFiscal') = 'ON' Then
      Result := '1'
    else
    begin
      GravaChaves('Simula Erro TextoNaoFiscal', 'OFF');
      Result := '0';
    end;
  end
  else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - TextoNaoFiscal('+Texto+','+IntToStr(Vias)+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.FechaCupomNaoFiscal : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - FechaCupomNaoFiscal() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.ReImpCupomNaoFiscal( Texto:AnsiString ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - ReImpCupomNaoFiscal('+Texto+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.Status( Tipo:Integer; Texto:AnsiString='' ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Status('+IntToStr(Tipo)+','+Texto+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.Suprimento( Tipo:Integer;Valor:AnsiString;Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Suprimento('+IntToStr(Tipo)+','+Valor+','+Forma+','+Total+','+IntToStr(Modo)+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ) : AnsiString;
begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - TotalizadorNaoFiscal('+Numero+','+Descricao+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Autenticacao('+IntToStr(Vezes)+','+Valor+','+Texto+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.Gaveta : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Gaveta() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString;
begin
  Result := LeStatusDoEcf;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - RelatorioGerencialPorIndice('+cIndTotalizador+','+cTextoImp+','+IntToStr(nVias)+') -> '+Result);
end;
//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - RelatorioGerencial('+Texto+','+IntToStr(Vias)+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;
begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  WriteLog('ECFEMUL.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ):AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Cheque('+Banco+','+Valor+','+Favorec+','+Cidade+','+Data+','+Mensagem+','+Verso+','+Extenso+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.StatusImp( Tipo:Integer ):AnsiString;
Var
  sData, sHora, sNCCA, sNCCB, sNumero :AnsiString;
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
  // 17 - Información sobre los contadores de documentos fiscales y no fiscales //ARG
  // 45  - Modelo Fiscal
  // 46 - Marca, Modelo e Firmware

  Result := '1';
  If LeChaves('Status do ECF') = 'ON' Then Begin
    //  1 - Verifica a hora da impressora
    if Tipo = 1 then
    begin
      sHora := FormatDateTime( 'hh:mm:ss am/pm', Now);
      if (copy(sHora, 10, 2) = 'am') Or (copy(sHora, 1, 2) = '12')then
        sHora := Copy(sHora, 1,8 )
      else
        sHora := IntToStr(StrToInt(Copy(sHora, 1,2 )) + 12) + Copy(sHora, 3,6 );
      Result := '0|'+sHora;
    end
    //  2 - Verifica a data da Impressora
    else if Tipo = 2 then
       begin
         sData:=LeChaves('Formato Data');
         If sData='' Then
         Begin
           GravaChaves('Formato Data','dd/mm/yyyy');
           sData:='dd/mm/yyyy';
         End;
         Result := '0|'+FormatDateTime(sData, Date);
       end
    //  3 - Verifica o estado do papel
    else if Tipo = 3 then
      Result := '0'
    //  4 - Verifica se é possível cancelar um ou todos os itens.
    else if Tipo = 4 then
      Result := '0|TODOS'
    //  5 - Cupom Fechado ?
    else if Tipo = 5 then
    begin
      if LeChaves('Cupom Aberto') = 'ON' then
        Result := '7'
      else
        Result := '0';
    end
    //  6 - Ret. suprimento da impressora
    else if Tipo = 6 then
      Result := '0'
    //  7 - ECF permite desconto por item
    else if Tipo = 7 then
      Result := '11'
    //  8 - Verica se o dia anterior foi fechado
    else if Tipo = 8 then
    begin
      if LeChaves('Reducao Z') = 'ON' then
        Result := '10';
    end
    //  9 - Verifica o Status do ECF - No Caso da DataRegis, verifica a Thread
    else if Tipo = 9 then
      Result := '0'
    // 10 - Verifica se todos os itens foram impressos.
    else if Tipo = 10 then
      Result := '0'
    // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
    else if Tipo = 11 then
      Result := '1'
    // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
    else if Tipo = 12 then
      Result := '1'
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
    Else If Tipo = 17 Then
    Begin
      sNCCA := LeChaves('NCCA');
      sNCCB := LeChaves('NCCB');
      sNumero := LeChaves('Numero do Cupom Fiscal');
      If LeChaves('Pais') = 'ARG' Then
         Result := '0|' + '|' + '|' + sNumero + '|' + '|' + sNumero + '|' + '|' + sNCCB+ '|' + sNCCA + '|' + '|' + '|'
      Else
         Result := '1';
    End
    else If Tipo = 45 then
           Result := '0|'// 45 Codigo Modelo Fiscal
    else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
          Result := '0|'// 45 Codigo Modelo Fiscal
    else
      Result := '1';
  End;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - StatusImp('+IntToStr(Tipo)+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.PegaSerie : AnsiString;
begin
  Result := '0|999999999999';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - PegaSerie() -> '+Result);
end;

//-----------------------------------------------------------
function TImpFiscalECFEmulator.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
Var
  sNumero : AnsiString;
begin
  If LeChaves('Status do ECF') = 'ON' Then
  Begin
    If LeChaves('Cupom Aberto') = 'OFF' then
    Begin
      sNumero := LeChaves('Numero do Cupom Fiscal');
      GravaChaves('Numero do Cupom Fiscal', FormataTexto(IntToStr(StrToInt(sNumero)+1),6,0,2));
      Result := '0|'+LeChaves('Numero do Cupom Fiscal');
    End
    Else
    Begin
      Application.MessageBox('Já existe um cupom aberto...',
        'ECF Emulator', MB_OK + MB_ICONERROR);
      Result := '1';
    End;
  End
  Else
    Result := '1';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Pedido('+Totalizador+','+TEF+','+Texto+','+Valor+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - RecebNFis('+Totalizador+','+Valor+','+Forma+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.Percepcao(sAliqIVA, sTexto, sValor: AnsiString): AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Percepção('+sAliqIVA+','+sTexto+','+sValor+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.SubTotal (sImprime: AnsiString):AnsiString;
begin
  Result := '0|0000|0000|000000|0000000000,00|0000000000,00|0000000000,00|0000000000,00|';
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - SubTotal('+sImprime+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.AbreDNFH( sTipoDoc, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: AnsiString): AnsiString;
var
  sNumero   : AnsiString;
  aAuxiliar : TaString;
begin
  If LeChaves('Pais') = 'ARG' Then
  Begin
    MontaArray( sDadosCli,aAuxiliar );
    Result := LeStatusDoECF;
    If aAuxiliar[3] = 'I' Then
    Begin
      sNumero := LeChaves('NCCA');
      GravaChaves('NCCA', FormataTexto(IntToStr(StrToInt(sNumero)+1),6,0,2));
      Result := LeStatusDoECF;
    End
    Else If aAuxiliar[3] = 'C' Then
    Begin
      sNumero := LeChaves('NCCB');
      GravaChaves('NCCB', FormataTexto(IntToStr(StrToInt(sNumero)+1),6,0,2));
      Result := LeStatusDoECF;
    End
    Else
    Begin
      ShowMessage('Los clientes del tipo responsable no inscripto no es aceito en el modelo de impressora.');
      Result := '1';
    End;
    WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - AbreDNFH('+sTipoDoc+','+sDadosCli+','+sDadosCab+','+sDocOri+') -> '+Result);
  End
  Else
  Begin
    // ainda não implementada para outros paises
    Result := LeStatusDoECF;
    WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - AbreDNFH('+sTipoDoc+','+sDadosCli+','+sDadosCab+','+sDocOri+') -> '+Result);
  End;
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.FechaDNFH(): AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - FechaDNFH() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.GravaCondPag( condicao:AnsiString ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - GravaCondPag('+condicao+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.ReImprime: AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - ReImprime() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.TextoRecibo (sTexto: AnsiString): AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - TextoRecibo('+sTexto+') -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.MemTrab:AnsiString;
begin
// ainda não implementada
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - MemTrab() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.Capacidade:AnsiString;
begin
// ainda não implementada
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Capacidade() -> '+Result);
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.AbreNota(Cliente:AnsiString):AnsiString;
begin
// ainda não implementada
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - AbreNota('+Cliente+') -> '+Result);
end;
//-----------------------------------------------------------------------------
function TImpFiscalECFEmulator.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - DownloadMFD('+sTipo+','+sInicio+','+sFinal+') -> '+Result);
end;

//------------------------------------------------------------------------------
function TImpFiscalECFEmulator.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString;
Begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - GeraRegTipoE('+sTipo+','+sInicio+','+sFinal+','+sRazao+','+sEnd+',' + sBinario +') -> '+Result);
End;

//------------------------------------------------------------------------------
function TImpFiscalECFEmulator.LeTotNFisc:AnsiString;
Begin
  Result := Trim(LeStatusDoECF) + '|' ;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - LeTotNFisc() -> '+Result);
End;

//------------------------------------------------------------------------------
function TImpFiscalECFEmulator.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalECFEmulator.RedZDado( MapaRes : AnsiString): AnsiString ;
Begin
  Result := '1';
End;


//------------------------------------------------------------------------------
function TImpFiscalECFEmulator.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - IdCliente('+cCPFCNPJ+','+cCliente+','+cEndereco+') -> '+Result);
end;

//------------------------------------------------------------------------------
function TImpFiscalECFEmulator.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
  Result := LeStatusDoECF;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - EstornNFiscVinc('+CPFCNPJ+','+Cliente+','+Endereco+','+Mensagem+','+COOCDC+') -> '+Result);
end;

//------------------------------------------------------------------------------
function TImpFiscalECFEmulator.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - ImpTxtFis ( ' + Texto + ')' );
 Result := '0';
end;

//---------------------------------------------------------------------------
function TImpChequeECFEmulator.Abrir(aPorta : AnsiString) : Boolean;
begin
  Result := True;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Cheque.Abrir('+aPorta+') -> True');
end;

//---------------------------------------------------------------------------
function TImpChequeECFEmulator.Fechar( aPorta:AnsiString ) : Boolean;
begin
  Result := True;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Cheque.Fechar('+aPorta+') -> True');
end;

//---------------------------------------------------------------------------
function TImpChequeECFEmulator.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ) : Boolean;
var
  sData    : AnsiString;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  Result := True;
  WriteLog('ECFEMUL.LOG', DateTimeToStr(Now)+' - Cheque.Imprimir('+Banco+','+Valor+','+Favorec+','+Cidade+','+Data+','+Mensagem+','+Verso+','+Extenso+') -> True');
end;

//----------------------------------------------------------------------------
function TImpChequeECFEmulator.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//----------------------------------------------------------------------------
function TImpChequeECFEmulator.StatusCh( Tipo:Integer ):AnsiString;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ? 0-Sim  1-Não
//  2 - Essa impressora imprime Chancela ? 0-Sim  1-Não

If tipo = 1 then
  result := '1'
Else If tipo = 2 then
  result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalECFEmulator.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
  RegistraImpressora('ECF Emulator', TImpFiscalECFEmulator, '', ' ');
  RegistraImpCheque ('ECF Emulator', TImpChequeECFEmulator, '');
end.
