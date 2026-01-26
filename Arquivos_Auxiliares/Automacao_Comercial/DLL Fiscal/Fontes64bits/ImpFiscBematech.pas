unit ImpFiscBematech;

interface

uses
  Dialogs, ImpFiscMain, ImpCheqMain, Windows, SysUtils, classes, LojxFun,
  Forms, IniFiles;

Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Bematech
///
  TImpFiscalBematechMP20FI = class(TImpressoraFiscal)
  private
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function AbreEcf:AnsiString; override;
    function FechaEcf:AnsiString; override;
    function LeituraX:AnsiString; override;
    function ReducaoZ(MapaRes:AnsiString):AnsiString; override;
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
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString; Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function Status( Tipo:Integer; Texto:AnsiString='' ) : AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function Gaveta:AnsiString; override;
    function Suprimento( Tipo:Integer; Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString ;Vias:Integer ; ImgQrCode: AnsiString):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    function PegaSerie:AnsiString; override;
    procedure AlimentaProperties; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString) : AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override;
    function RedZDado(MapaRes:AnsiString):AnsiString; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
  end;

  TImpFiscalBematechMP40FI = class(TImpFiscalBematechMP20FI)
  public
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ): AnsiString; override;
  end;

  TImpFiscalBematechMP20F = class(TImpFiscalBematechMP20FI)
  public
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString ;Vias:Integer ):AnsiString; override;
  end;

  TImpFiscalBematechMP40F = class(TImpFiscalBematechMP20F)
  public
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Bematech MP40FI-II
///
  TImpChequeBematechMP40FI = class(TImpressoraCheque)
  public
    function Abrir( aPorta:AnsiString ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function Fechar(aPorta:AnsiString ): Boolean; override;
    function StatusCh( Tipo:Integer ):AnsiString; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Bematech MP40FI-I
///
TImpChequeBematechMP40F = class(TImpChequeBematechMP40FI)
  public
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenBematech( sPorta:AnsiString ) : AnsiString;
Function CloseBematech : AnsiString;
Function TrataErroFormataTX( iErro : Integer ): Boolean;
Function _Status( Tipo:Integer ) : AnsiString;
Function TrataTags( Mensagem : AnsiString ) : AnsiString;

//----------------------------------------------------------------------------
implementation

var
  fHandle : THandle;
  fFuncIniPortaStr : function (pCom: PChar): Integer; StdCall;
  fFuncFechaPorta  : function ():Integer; StdCall;
  fFuncFormataTX   : function (pTexto: PChar):Integer; StdCall;
  fStatus_Mp20FI   : function (Var Retorno, ACK, ST1, ST2: Integer): Integer; StdCall;
  fLe_Variaveis    : function (sVar: AnsiString):Integer; StdCall;
  fRetorna_ASCII   : function (iFlag: integer): Integer; StdCall;
  bOpened : Boolean;
  // Variaveis Usadas na Status_MP20FI e Le_Variaveis
  Retorno, ACK, ST1, ST2 : Integer;
  sST1, sST2, sVar : AnsiString;
  aAliquotas : array of AnsiString;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Bematech
///
function TImpFiscalBematechMP20FI.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
  Result := OpenBematech(sPorta);
  // Carrega as aliquotas e N. PDV para ganhar performance e evitar erro na versao 7.05 da MP20FI32.DLL
  if Copy(Result,1,1) = '0' then
    AlimentaProperties;
end;

//---------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  Result := CloseBematech;
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.LeituraX : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|6|'+#27) );
  if TrataErroFormataTX(iRet) and (Copy(Status(1),1,1)='0') then
    Result := '0|'
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.ReducaoZ( MapaRes:AnsiString ) : AnsiString;
var
  iRet,iLinha : Integer;
  sFile : AnsiString;
  fFile : TextFile;
  sLinha : AnsiString;
  aRetorno : array of AnsiString;
  sFlag: AnsiString;
  fOutros, fBase, fAliq : Real;
begin
{
aRetorno[ 0]+'|'+  // Data do Movimento
aRetorno[ 1]+'|'+  // Numero do ECF
aRetorno[ 2]+'|'+  // Serie do ECF
aRetorno[ 3]+'|'+  // Numero de reducoes
aRetorno[ 4]+'|'+  // Grande Total Final
aRetorno[ 5]+'|'+  // Numero doumento Inical
aRetorno[ 6]+'|'+  // Numero doumento Final
aRetorno[ 7]+'|'+  // Valor do Cancelamento
aRetorno[ 8]+'|'+  // Valor Contabil ( Venda Liquida )
aRetorno[ 9]+'|'+  // Desconto
aRetorno[10]+'|'+  // Nao tributado SUBSTITUIcao TRIB
aRetorno[11]+'|'+  // Nao tributado ISENTO
aRetorno[12]+'|'+  // Nao tributado Nao Tributado
aRetorno[13]+'|'+  // Data da Reducao  Z
aRetorno[14]+'|'+  // COO
aRetorno[15]+'|'+  // Outros Recebimentos
aRetorno[16]+'|'+  // Totais ISS
aRetorno[17]+'|'+  // CRO
aRetorno[18]+'|'+  // desconto de ISS
aRetorno[19]+'|'+  // cancelamento de ISS
aRetorno[20]+'|'+  // QTD DE Aliquotas
 }
  fOutros := 0;
  iRet := fFuncFormataTx( PChar(#27 + '|35|17|' + #27) );

  if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
  Begin
    sLinha := DecToBin( StrToInt(Trim(Copy(sVar,2,Length(sVar)))) );
    // Verifica se Já Houve redução Z no Dia
    if copy(sLinha,5,1) = '1' then
    Begin
      ShowMessage('Já houve redução "Z" no dia.');
      result := '1|';
      exit;
    End;
  End;

  If Trim(MapaRes)='N' then
  Begin
    //-----------------------------------------------------
    // Executa a Redução Z
    iRet := fFuncFormataTx( PChar(#27+'|5|'+#27) );

    if TrataErroFormataTx( iRet ) then
    begin
      result := Status( 1 );
      fFuncFormataTx( PChar(#27 + '|39|1|' + #27) );      // Envia comando para a impressora arredondar os valores
    end
    else
      result := '1|';

    exit;
  end;
  // Leitura X via serial
  SetLength(aRetorno,21);
  aRetorno[16]:= FormataTexto('0',14, 2, 1)+' '+FormataTexto('0',14, 2, 1);    // Total ISS
  aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS
  aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS
  aRetorno[20]:= '00';                                         // QTD DE Aliquotas

  iRet:=fFuncFormataTx( PChar(#27+'|69|'+#27));
  if not (TrataErroFormataTX(iRet)) or (Copy(Status(1),1,1)<>'0') then
  Begin
    Result:='1|';
    Exit;
  End;
  sFile := ExtractFilePath(Application.ExeName) + 'MP20FI.RET';
  if FileExists(sFile) then
  Begin
    AssignFile(fFile, sFile);
    Reset(fFile);
    sFlag:='';
    aRetorno[5]:='';
    While not Eof(fFile) do
    Begin
      ReadLn(fFile, sLinha);
      // Caso impressora em mode treinamanto elimina o caracter "?'
      sLinha:=StrTran(sLinha,'?',' ');
      if (Pos('GNF:', UpperCase(sLinha))>0) and  ( Pos('COO:',sLinha)>0) then   // Data da leitura X para comparacao com a data da redução Z.
        aRetorno[0]:=Copy(sLinha,1,8);
      if ( Pos('COO DO PRIMEIRO CUPOM FISCAL' , UpperCase(sLinha))>0) then
        aRetorno[5]:=Copy(sLinha,Length(sLinha)-5,6);
      if ( Pos('COO do £ltimo Cupom Fiscal', sLinha)>0) then  // Primeiro Cupom Fiscal
        aRetorno[6]:=Copy(sLinha,Length(sLinha)-5,6);
      if ( Pos('DESCONTOS', UpperCase(sLinha))>0)  then  // Desconto
        aRetorno[09]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-10,12),'.',''),11,2,1,'.');
      if ( Pos('VENDA LÖQUIDA',UpperCase(sLinha))>0) then  // Venda Liquida
        aRetorno[8]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-14,15),'.',''),15,2,1,'.');  // Venda Liquida
      if ( Pos('REIN¡CIO ',UpperCase(sLinha))>0) then  // CRO - Contador de Reinício de Operação
        aRetorno[17]:= Copy(sLinha,Length(sLinha)-2,3); //CRO
      if ( Pos('TOTAL',UpperCase(sLinha))>0 ) and (( sFlag='T' ) or (sFlag='S')) Then
        // desliga a captura das aliquotas
        sFlag:='';

      if ( sFlag='T' ) and ( Copy(sLinha,4,1)='T' ) then
      Begin
        aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
        SetLength( aRetorno, Length(aRetorno)+1 );
        // Aliquota '  ' Valor '  ' Imposto Debitado
        if Copy(sLinha,24,1) = ',' then
          aRetorno[High(aRetorno)]:=Copy(sLinha,4,6)+' '+FormataTexto(StrTran(Copy(sLinha,13,14),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,28,13),'.',''),14,2,1,'.')
        Else
          aRetorno[High(aRetorno)]:=Copy(sLinha,4,6)+' '+FormataTexto(StrTran(Copy(sLinha,16,14),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(sLinha,36,13),'.',''),14,2,1,'.');
      End;

      // Totais ISS
      if ( sFlag='S' ) and ( Copy(sLinha,4,1)='S' ) then
      Begin
        // ' Valor '  ' Imposto Debitado
         fBase:= StrToFloat(StrTran(copy(sLinha,13,14),',','.'));
         fAliq:= StrToFloat(StrTran(copy(sLinha,27,14),',','.'));
         aRetorno[16] :=FormataTexto(FloatToStr(StrToFloat(copy(aRetorno[16],1,14))+ fBase) ,14,2,1)+' '+
                        FormataTexto(FloatToStr(StrToFloat(copy(aRetorno[16],16,14))+ fAliq) ,14,2,1);
      End;

      if ( Pos('-------------NÆo Tributados-------------',sLinha)>0 )  then
        sFlag:='NT';
      if ( Pos('SUBSTITUI€ÇO TRIB',sLinha)>0 ) and ( sFlag='NT' ) then
        aRetorno[10]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-10,12),'.',''),11,2,1,'.');
      if ( Pos('ISEN€ÇO',sLinha)>0 ) and ( sFlag='NT' ) then
        aRetorno[11]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-10,12),'.',''),11,2,1,'.');
      if ( Pos('NÇO',sLinha)>0 ) and ( Pos('INCIDÒNCIA',sLinha)>0 ) and ( sFlag='NT' ) then
        aRetorno[12]:=FormataTexto(StrTran(Copy(sLinha,Length(sLinha)-10,12),'.',''),11,2,1,'.');
      if (Pos('---------------Tributados---------------',sLinha)>0) then
      // Liga a captura das aliquotas de ICMS
        sFlag:='T';
      if (Pos('------------------ISS-------------------',sLinha)>0) then
      // Liga a captura das aliquotas de ISS
        sFlag:='S';
    End;
    CloseFile(fFile);
  End;
  if aRetorno[5] = '' then
    aRetorno[5] := aRetorno[6];
  // Numero do PDV
  aRetorno[1]:=PDV;
  // Saber a Numero de serie do fimeware
  iRet:=fFuncFormataTx( PChar(#27+'|35|00|'+#27) );
  if not (TrataErroFormataTX(iRet)) or (Copy(Status(1),1,1)<>'0') then
  Begin
    Result:='1|';
    Exit;
  End;
  aRetorno[2] := Copy(sVar,1,13);
  //-----------------------------------------------------
  // Executa a Redução Z
  iRet := fFuncFormataTx( PChar(#27+'|5|'+#27) );
  if not TrataErroFormataTx( iRet ) then
  Begin
    result := '1|';
    Exit;
  End
  Else
    fFuncFormataTx( PChar(#27 + '|39|1|' + #27) );      // Envia comando para a impressora arredondar os valores      

  // Retorno do Numero de reducoes
  iRet := fFuncFormataTx( PChar(#27+'|35|09|'+#27) );
  if not (TrataErroFormataTX(iRet)) or (Copy(Status(1),1,1)<>'0') then
  Begin
    Result:='1|';
    Exit;
  End;
  aRetorno[3] := Copy(sVar,1,4);

  // Informaçoes da ultima reduçao Z
  iRet := fFuncFormataTx( PChar(#27+'|62|55|'+#27) );
  if not (TrataErroFormataTX(iRet)) or (Copy(Status(1),1,1)<>'0') then
  Begin
    Result:='1|';
    Exit;
  End;
  aRetorno[13] := Copy(sVar,583, 2)+'/'+Copy(sVar,585,2)+'/'+Copy(sVar,587,2);  // Data
  aRetorno[ 4] := Copy(sVar,  3,16)+'.'+Copy(sVar, 19,2);                       // Grande Total
  aRetorno[ 7] := Copy(sVar, 21,12)+'.'+Copy(sVar, 33,2);                       // Cancelamento
  aRetorno[14] := Copy(sVar,569, 6);                                            // Numero do Cupom
  for iLinha:= 0 to 8 do
    fOutros := fOutros + StrToFloat( Copy(sVar,407+(iLinha*14),14) );
  aRetorno[15] := FormataTexto(FloatToStrf(fOutros / 100 , ffFixed, 18, 2),16,2,1,'.');
  // Avaliando se alguma informação falhou
  iLinha:=0;
  While iLinha< Length(aRetorno) do
  Begin
    if Trim(aRetorno[iLinha])='' then
    Begin
      sLinha:='ERRO';
      Break;
    End;
    Inc(iLinha);
  End;

  {
      Validação da Data do movimento

      Caso o dia corrente não possua movimento. Em alguns ECF's a data virá nula...
      Caso isto ocorra a data a ser considerada, é a data tratada após o comando:
      (#27+'|69|'+#27), vide índice "0" do array aRetorno...
  }
  If aRetorno[13]='00/00/00' Then
     aRetorno[13] := aRetorno[0]
  Else
     aRetorno[0] := aRetorno[13];

  if ( aRetorno[0]=aRetorno[13] ) and (sLinha<>'ERRO') then
  Begin
    Result := '0|';
    for iLinha:= 0 to High(aRetorno) do
      Result:=Result+aRetorno[iLinha]+'|';
  End
  Else
    Result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.AbreECF : AnsiString;
begin
  Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.FechaECF : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|5|'+#27) );
  if TrataErroFormataTX(iRet) and (Copy(Status(1),1,1)='0') then
  begin
    fFuncFormataTx( PChar(#27 + '|39|1|' + #27) );      // Envia comando para a impressora arredondar os valores
    result := '0|';
  end
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString;
var
  iRet : Integer;
begin
  If Pos('|', Cliente) > 0 then
    Cliente := Copy( Cliente, 1, (Pos('|',Cliente) - 1));

  iRet := fFuncFormataTx( PChar(#27+'|00|'+Trim(Cliente)+'|'+#27) );
  if TrataErroFormataTX(iRet) and (Copy(Status(1),1,1)='0') then
    Begin
    // Verifica se já foi  impresso cabecalho do cupom
    while True do
       Begin
       iRet:=fFuncFormataTx( PChar(#27 + '|19|' + #27) );
       if iRet=0 then
          Break;
       End;

    Result := '0|';
    End
  else
    Result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|30|'+#27) );
  if TrataErroFormataTX(iRet) and (Copy(Status(1),1,1)='0') then
    Result := '0|' + sVar
  else
    Result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.PegaPDV : AnsiString;
begin
  Result := '0|'+PDV;
end;

//---------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  iRet : Integer;
  iTamanho : Integer;
  iPos : Integer;
  sAliq : AnsiString;
  sSituacao : AnsiString;
begin
  ///////////////////////////////////////////////////////////////////////////////////////////
  // A impressora Bematech MP40FI II não aceita a descricao do Produto apenas com números. //
  // e tbém não pode ser menor do que 9 (nove) digitos.                                    //
  ///////////////////////////////////////////////////////////////////////////////////////////

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    result := '11';
    exit;
  end;
  // Verifica o ponto decimal dos parâmetros
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');
  qtde := StrTran(qtde,',','.');
  sSituacao := copy(aliquota,1,1);
  Aliquota  := StrTran(copy(Aliquota,2,5),',','.');
  if trim(aliquota)='' then
    Aliquota :='00.00'
  else
    Aliquota := FormataTexto(Aliquota,5,2,1,'.');

  iPos := 0;
  for iTamanho:=0 to Length(aAliquotas)-1 do
    if aAliquotas[iTamanho] = sSituacao+Aliquota then
    begin
      iPos := iTamanho + 1;
      break
    end;

  if (iPos = 0) and (Pos(sSituacao,'ST')>0) then
  begin
    ShowMessage('Aliquota não cadastrada. '+sSituacao+Aliquota+'.');
    result := '1';
    exit;
  end;

  If Pos(sSituacao,'TS') > 0 then
  begin
    sAliq := IntToStr(iPos);
    If Length(sAliq) < 2 then
      sAliq := '0' + sAliq;
  end
  else
    sAliq := sSituacao + sSituacao;
    descricao := Trim(descricao);

  If (Length(Trim(Descricao))>29) and (Eprom >= '0300') then
    iRet:=fFuncFormataTx( PChar(#27+'|63|'+
                          sAliq+'|'+
                          FormataTexto(vlrUnit,9,3,2) + '|'+
                          FormataTexto(qtde,7,3,2) + '|'+
                          FormataTexto(vlrdesconto,10,2,2) + '|'+
                          FormataTexto('0',10,2,2) + '|'+
                          '01|00000000000000000000|  |'+
                          codigo+'|'+
                          descricao+'|'+ #27) )
  else If (Pos('.',vlrUnit) > 0) and (copy(vlrUnit,Pos('.',vlrUnit)+3,1) <> '0') then
  begin
     descricao := copy(descricao + Space(29),1,29);
     iRet := fFuncFormataTx( PChar(#27+'|56|'+ Copy(codigo,1,13) + '|' + descricao + '|' + sAliq + '|' + FormataTexto(qtde,7,3,2) + '|' + FormataTexto(vlrUnit,8,3,2) + '|' + FormataTexto(vlrdesconto,8,2,2) + '|' + #27) );
  end
  else
  begin
     descricao := copy(descricao + Space(29),1,29);
     iRet := fFuncFormataTx( PChar(#27+'|09|'+ Copy(codigo,1,13) + '|' + descricao + '|' + sAliq + '|' + FormataTexto(qtde,7,3,2) + '|' + FormataTexto(vlrUnit,8,2,2) + '|' + FormataTexto(vlrdesconto,8,2,2) + '|' + #27) );
  end;

  if TrataErroFormataTX(iRet) then
    Result := Status( 1 )
  else
    Result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.LeAliquotas : AnsiString;
begin
  Result := '0|'+Aliquotas;
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.LeAliquotasISS : AnsiString;
begin
  Result := '0|'+ISS;
end;

//----------------------------------------------------------------------------
procedure TImpFiscalBematechMP20FI.AlimentaProperties;
var
  sFlagISS, sAliq : AnsiString;
  iRet : Integer;
  i, iTam : Integer;
  sFile : AnsiString;
  fFile : TextFile;
  sLinha : AnsiString;
begin
  // Retorno dos Flags de Vinculação ao ISS
  iRet := fFuncFormataTx( PChar(#27+'|35|29|'+#27) );
  if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
  begin
    sFile := ExtractFilePath(Application.ExeName) + 'MP20FI.RET';
    if FileExists(sFile) then
    Begin
      AssignFile(fFile, sFile);
      Reset(fFile);
      ReadLn(fFile, sLinha);
      CloseFile(fFile);
      sVar := Copy(sLinha,1,2);
    end;
    if Length(sVar)=0 then
      sVar := #0#0
    else if Length(sVar)=1 then
      sVar := sVar + #0;
    sFlagISS := DecToBin(Ord(sVar[1]))+DecToBin(Ord(sVar[2]));
  end;

  // Retorno de Aliquotas
  iRet := fFuncFormataTx( PChar(#27+'|26|'+#27) );
  if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
  begin
    if Length(sVar) <> 0 then
    begin
      iTam := StrToInt(Copy(sVar,1,2));
      SetLength(aAliquotas, 16);
      for i := 0 to iTam-1 do
      begin
        sAliq := Copy(sVar,(i*4)+3,2)+'.'+Copy(sVar,(i*4)+5,2);
        Aliquotas := Aliquotas + sAliq+'|';
        if Copy(sFlagISS,i+1,1)='1' then
        begin
          aAliquotas[i] := 'S'+sAliq;
          ISS := ISS + sAliq+'|';
        end
        else
        begin
          aAliquotas[i] := 'T'+sAliq;
          ICMS := ICMS + sAliq+'|';
        end;
      end;
    end;
  end;

  // Retorno do Numero do Caixa (PDV)
  iRet := fFuncFormataTx( PChar(#27+'|35|14|'+#27) );
  if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
    PDV := sVar;

  // Retorno da Versão do Firmware (Eprom)
  iRet := fFuncFormataTx( PChar(#27+'|35|01|'+#27) );
  if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
    Eprom := sVar;
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.LeCondPag : AnsiString;
var
  iRet : Integer;
  sRet, sForma : AnsiString;
  iForma : Integer;
begin
  // Quando o Retorno é Maior que 700 bytes, Deve-se usar a Retorna_ASCII.
  // Usar nos Comandos : 35|32, 35|33, 35|34...
  fRetorna_ASCII(1);
  iRet := fFuncFormataTx( PChar(#27+'|35|32|'+#27) );
  if TrataErroFormataTX(iRet) and (Copy(Status(1),1,1)='0') then
  begin
    sRet := '';
    for iForma := 0 to 51 do
    begin
      sForma := UpperCase(Trim(Copy(sVar,iForma*16+2,16)));
      if (sForma<>'') and (sForma<>'VALOR RECEBIDO') and (sForma<>'TROCO') then
        sRet := sRet + sForma + '|';
    end;
    Result := '0|' + sRet;
  end
  else
    Result := '1';
  fRetorna_ASCII(0);                                    // Voltar ao Normal...
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|31|'+ FormataTexto(numitem,4,0,2) + '|' + #27) );
  if TrataErroFormataTX(iRet) then
    result := Status( 1 )
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.CancelaCupom( Supervisor:AnsiString ) : AnsiString;
var
  iRet : Integer;
  sLinha : AnsiString;
begin
  Result := '1|';

  // verifica se o cupom pode ser cancelado
  iRet := fFuncFormataTx( PChar(#27 + '|35|17|' + #27) );
  if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
  begin
    sLinha := DecToBin( StrToInt(Trim(Copy(sVar,2,Length(sVar)))) );
    if Eprom < '0300' then
    begin
      // Se Houver Cupom Fiscal
      if (copy(sLinha,8,1) = '1') then
      begin
        // Inicia o Fechamento
        fFuncFormataTx( Pchar(#27+'|32|d|0000|'+#27));
        // Faz um Pagamento
        iRet := fFuncFormataTx( Pchar(#27+'|34| |'+#27));
        if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
        begin
          // Pega o SubTotal Para Saber se Vai Ter Que Cancelar
          iRet := fFuncFormataTx( PChar(#27 + '|29|' + #27) );
          if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
            If StrToInt(sVar) > 0 then
            begin
              // Faz o cancelamento do cupom
              iRet := fFuncFormataTx( PChar(#27+'|14|'+#27) );
              if TrataErroFormataTX(iRet) then
                Result := Status( 1 );
            end;
        end;
      end
      else
      begin
        // Faz o cancelamento do cupom
        iRet := fFuncFormataTx( PChar(#27+'|14|'+#27) );
        if TrataErroFormataTX(iRet) then
          Result := Status( 1 );
      end;
    end
    else
    begin
      // Se Houver Cupom Fiscal e Não Permite Cancelar
      // Registra um Item para Permitir Cancelamento
      if (copy(sLinha,8,1) = '1') and not (copy(sLinha,3,1) = '1') then
        fFuncFormataTx( Pchar(#27+'|09|1|Cancelamento|II|0001|10|0000|'+#27));

      // Faz o cancelamento do cupom
      iRet := fFuncFormataTx( PChar(#27+'|14|'+#27) );
      if TrataErroFormataTX(iRet) then
        Result := Status( 1 );
    end;
  end;
end;
//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.FechaCupom( Mensagem:AnsiString ) : AnsiString;
var
  iRet : Integer;
  sMsg : AnsiString;
begin
  sMsg := TrataTags( Mensagem );
  if sMsg = '' then
    sMsg := ' ';
  iRet := fFuncFormataTx( PChar(#27 + '|34|' + sMsg + '|' + #27) );
  if TrataErroFormataTx(iRet) then
    result := Status( 1 )
  else
    result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;
var
  iRet : Integer;
  bErro : Boolean;
  aAuxiliar : TaString;
  i : Integer;
  sForma    : AnsiString;
  sDescPag  : AnsiString;
  sFormaPag : AnsiString;
  sValorPag : AnsiString;
begin
   Result := '1';
  If Eprom < '0300' then
  begin

    bErro := False;
    // Registra o desconto no total do cupom
    iRet := fFuncFormataTx( PChar(#27 + '|32|d|' + FormataTexto('0',14,2,2) + '|' + #27) );
    // Nao verifica Status porque o comando 32|d pode estar sendo enviado pela segunda vez e nesse caso sempre ocasionara erro no Status.bin
    if (not TrataErroFormataTx(iRet)) then exit;

    // registra as formas de pagamento
    MontaArray( Pagamento,aAuxiliar );

    i:=0;
    While i<Length(aAuxiliar) do
    begin
      iRet := fFuncFormataTx( PChar(#27+'|33|'+Copy(aAuxiliar[i],1,22)+'|'+FormataTexto(aAuxiliar[i+1],14,2,2)+'|'+#27) );
      Inc(i,2);
      If (not TrataErroFormataTx(iRet)) or (Copy(Status(1),1,1)='1') then
        bErro := True;
    end;

    If bErro then
      result := '1|'
    else
      result := '0|';
  end
  Else
  begin
    bErro := False;
    // Registra o desconto no total do cupom
    iRet := fFuncFormataTx( PChar(#27 + '|32|d|' + FormataTexto('0',14,2,2) + '|' + #27) );
    // Nao verifica Status porque o comando 32|d pode estar sendo enviado pela segunda vez e nesse caso sempre ocasionara erro no Status.bin
    if (not TrataErroFormataTx(iRet)) then exit;

    // registra as formas de pagamento
    MontaArray( Pagamento,aAuxiliar );
    // Divisao por 3 para saber se tem descricao para as formas de pagamento
    // Ex. aAuxiliar[0]='Dinheiro'
    //     aAuxiliar[1]='   5.00 '
    //     aAuxiliar[2]='Titulo 00001'
    i:=0;
    While i<Length(aAuxiliar) do
    begin
      sDescPag:='';
      sFormaPag:=Copy(aAuxiliar[i],1,16);
      Inc(i); //2
      sValorPag:=FormataTexto(aAuxiliar[i],14,2,2);
      Inc(i); //3
      if Length(aAuxiliar)>i then
        try
          StrToFloat(aAuxiliar[i+1]);
        except
          Begin
            sDescPag:=Copy(aAuxiliar[i],1,80);
            Inc(i);
          End;
        end;
      iRet := fFuncFormataTx( PChar(#27+'|71|'+sFormaPag+'|'+#27) );
      if TrataErroFormataTx(iRet) and (Copy(Status(1),1,1)='0') then
      begin
        sForma := sVar;
        if Trim(sDescPag)='' then
          iRet := fFuncFormataTx( PChar(#27+'|72|'+sForma+'|'+sValorPag+'|'+#27) )
        else
          iRet := fFuncFormataTx( PChar(#27+'|72|'+sForma+'|'+sValorPag+'|'+sDescPag+'|'+#27) );

        If (not TrataErroFormataTx(iRet)) or (Copy(Status(1),1,1)='1') then
        Begin
          bErro := True;
          Break;
        End;
      end
      else
      begin
        bErro := True;
        Break;
      end;
    end;

    If bErro then
      result := '1|'
    else
      result := '0|';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.DescontoTotal( vlrDesconto:AnsiString; nTipoImp:Integer ) : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|32|d|'+FormataTexto(vlrDesconto,14,2,2)+'|'+#27) );
  if TrataErroFormataTX(iRet) then
    result := Status( 1 )
  else
    result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.AcrescimoTotal( vlrAcrescimo:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|32|a|'+FormataTexto(vlrAcrescimo,14,2,2)+'|'+#27) );
  if TrataErroFormataTX(iRet) then
    result := Status( 1 )
  else
    result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:AnsiString  ) : AnsiString;
var
  iRet   : Integer;
  sDataIn,sDataFim: AnsiString;
  sFile,sLinha  : AnsiString;
  fArq,fFile: TextFile;
  sArq   :AnsiString;
  sRetorno :AnsiString;
Begin
  if (Tipo='D') OR (Pos('A', UpperCase(Tipo)) > 0) then
     Begin
     Tipo  :='R';
     sFile := ExtractFilePath(Application.ExeName) + 'MP20FI.RET';
     sArq  := ExtractFilePath(Application.ExeName) + 'MEMFISC.RET';
     End
  else
     Tipo  :='I';

  if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
     Begin
     ReducInicio:=FormataTexto(ReducInicio,4,0,2);
     ReducFim   :=FormataTexto(ReducFim,4,0,2);
     iRet       := fFuncFormataTx( PChar(#27+'|8|'+ReducInicio+'|'+ReducFim+'|'+Tipo+'|'+#27) );
     End
  Else
     Begin
     sDataIn    :=FormataData(DataInicio,1);
     sDataFim   :=FormataData(DataFim,1);
     iRet       := fFuncFormataTx( PChar(#27+'|8|'+sDataIn+'|'+sDataFim+'|'+Tipo+'|'+#27) );
     End;

  If ( Tipo='R' ) and ( FileExists(sFile))  Then
     Begin
     AssignFile(fFile , sFile);
     Reset(fFile);
     AssignFile( fArq,sArq );
     ReWrite( fArq );
     While not Eof(fFile) do
       Begin
       ReadLn(fFile, sLinha);
       WriteLn( fArq,sLinha );
       end;
     CloseFile( fFile );
     CloseFile( fArq );
     Application.ProcessMessages;
     if FileExists(sArq) then
        begin
        sRetorno := CopRenArquivo( ExtractFilePath(Application.ExeName), 'MEMFISC.RET', PathArquivo, DEFAULT_ARQMEMCOM );
        If sRetorno = '0' Then
           ShowMessage('Arquivo criado em: '+sArq);
        end;

     End;
  if TrataErroFormataTX(iRet) then
    result := Status( 1 )
  else
    result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ) : AnsiString;
var
  iRet : Integer;
  sAliq : AnsiString;
begin
  Aliquota := FloatToStrf(StrToFloat(Trim(StrTran(Aliquota,',','.'))),ffFixed,18,2);

  If Tipo=1 then
  begin
      sAliq := LeAliquotas;

      if Pos(Aliquota,sAliq) > 0 then
      begin
        ShowMessage('Aliquota já cadastrada.');
        result := '1';
      end
      else
      begin
        Aliquota := StrTran(Aliquota,',','.');
        iRet := fFuncFormataTx( PChar(#27+'|7|'+FormataTexto(Aliquota,4,2,2)+'|'+#27) );
        if TrataErroFormataTX(iRet) then
          result := Status( 1 )
        else
          result := '1';
      end;
  end
  Else
  begin
      sAliq := LeAliquotasISS;

      if Pos(Aliquota,sAliq) > 0 then
      begin
        ShowMessage('Aliquota já cadastrada.');
        result := '1';
      end
      else
      begin
        Aliquota := StrTran(Aliquota,',','.');
        iRet := fFuncFormataTx( PChar(#27+'|7|'+FormataTexto(Aliquota,4,2,2)+'|1|'+#27) );
        if TrataErroFormataTX(iRet) then
          result := Status( 1 )
        else
          result := '1';
      end;
  end;

  // Carrega as aliquotas e N. PDV para ganhar performance e evitar erro na versao 7.05 da MP20FI32.DLL
  if Copy(Result,1,1) = '0' then AlimentaProperties;
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ) : AnsiString;
var
  iRet : Integer;
  sRet : AnsiString;
  sComm : AnsiString;
begin
  Totalizador := FormataTexto(Totalizador,2,0,2);
  Condicao    := UpperCase(Trim(Condicao));
  sComm := '|66|'+Copy(Condicao+Replicate(' ',16-Length(Condicao)),1,16)+'|';
  iRet := fFuncFormataTx( PChar(#27+sComm+#27) );
  if (TrataErroFormataTx( iRet )) and (copy( Status(1),1,1 )='1') then
  begin
      iRet := fFuncFormataTx( PChar(#27+'|25|'+Copy(Totalizador,1,2)+'|'+FormataTexto(Valor,12,2,2)+'|'+Condicao+'|'+#27) );
      if TrataErroFormataTx( iRet ) then
      begin
        sComm := '|66|'+Copy(Condicao+Replicate(' ',16-Length(Condicao)),1,16)+'|';
        iRet := fFuncFormataTx( PChar(#27+sComm+#27) );
        if TrataErroFormataTx( iRet ) then
          result := Status( 1 )
        else
          result := '1|';
      end
      else
      begin
        sRet := TotalizadorNaoFiscal( Totalizador,'DIVERSOS' );
        if copy(sRet,1,1) = '0' then
        begin
          iRet := fFuncFormataTx( PChar(#27+'|25|'+Copy(Totalizador,1,2)+'|'+FormataTexto(Valor,12,2,2)+'|'+Condicao+'|'+#27) );
          if TrataErroFormataTx( iRet ) then
          begin
            iRet := fFuncFormataTx( PChar(#27+'|66|'+Copy(Condicao+Replicate(' ',16-Length(Condicao)),1,16)+'|'+#27) );
            if TrataErroFormataTx( iRet ) then
              result := Status( 1 );
          end
          else
            result := '1|'
        end
        else
          result := '1';
      end
  end
  else
    result := '0|';

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ) : AnsiString;
var
  iRet : integer;
  sRet : AnsiString;
  nLoop : integer;
  sTexto : AnsiString;
  lOk : boolean;
begin
  lOk := True;
  for nLoop := 1 to Vias do
    begin
      sTexto := Texto;
      while not (sTexto = '') do
        begin
          iRet := fFuncFormataTx( PChar(#27+'|67|'+Copy(sTexto,1,40)+'|'+#27) );
          sTexto := Copy(sTexto,41,Length(sTexto));
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
          if not lOk then break;
        end;
      if lOk then
        begin
          iRet := fFuncFormataTx( PChar(#27+'|67|'+#10+'|'+#27) );
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
        end;
      if not lOk then break;
      if not (nLoop = Vias) then
        begin
          iRet := fFuncFormataTx( PChar(#27+'|67|'+Replicate(#10,9)+'|'+#27) );
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
          if not lOk then break;
          Sleep(5000);
        end;
    end;
  if lOk then
    sRet := '0|'
  else
    sRet := '1|';
  result := sRet;
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.FechaCupomNaoFiscal : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|21|'+#27) );
  if TrataErroFormataTx(iRet) then
    result := Status( 1 )
  else
    result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.ReImpCupomNaoFiscal( Texto:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin

  iRet := fFuncFormataTx( PChar(#27+'|20|'+Texto+#10+'|'#27) );
  if TrataErroFormataTx(iRet) then
    result := Status( 1 )
  else
    result := '1|';

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.Suprimento( Tipo:Integer; Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;
var
  iRet : Integer;
  sRet : AnsiString;
  nSuprimento : Real;
begin
  // Tipo = 1 - Verifica se tem troco disponivel
  // Tipo = 2 - Grava o valor informado no Suprimentos
  // Tipo = 3 - Sangra o valor informado

  Valor := StrTran(Valor,',','.');

  //  6 - Ret. suprimento da impressora
  sRet := StatusImp(6);
  if Copy(sRet,1,1) = '0' then
  begin
    nSuprimento := StrToFloat(Copy(sRet,3,Length(sRet)));

    // Verifica qual a operacao pedida
    case Tipo of
      // Tipo = 1 - Verifica se tem troco disponivel
      1 : begin
            if nSuprimento >= StrToFloat(Valor) then
              Result := '8'
            else
              Result := '9'
          end;
      // Tipo = 2 - Grava o valor informado no Suprimentos
      2 : begin
            if Trim(Forma) = '' then Forma := 'Dinheiro';
            if Trim(Total) = '' then
              Total := 'SU'
            else
              Total := '#'+IntToStr(StrToInt(Total));
            iRet := fFuncFormataTx( PChar(#27+'|25|'+Trim(Total)+'|'+FormataTexto(Valor,14,2,2)+'|'+Trim(Forma)+'|'+#27) );
            if TrataErroFormataTx(iRet) then
              Result := Status( 1 )
            else
              Result := '1';
          end;
      // Tipo = 3 - Sangra o valor informado
      3 : begin
            iRet := fFuncFormataTx( PChar(#27+'|25|SA|'+FormataTexto(Valor,14,2,2)+'|'+#27) );
            if TrataErroFormataTx(iRet) then
              Result := Status( 1 )
            else
              Result := '1';
          end
      else
        Result := '1';
    end;
  end
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27 + '|65|' + Copy(Numero,1,2) + '|' + Copy(Descricao,1,10) + '|' + #27) );
  if TrataErroFormataTx(iRet) then
    result := Status( 1 )
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ) : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|16|'+#27) );
  if TrataErroFormataTx(iRet) then
    result := Status( 1 )
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.Gaveta : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|22|'+#64+'|'+#27) );
  if TrataErroFormataTx(iRet) then
    result := Status( 1 )
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer ; ImgQrCode: AnsiString ) : AnsiString;
begin
  Result := RelatorioGerencial(cTextoImp,nVias,ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.RelatorioGerencial( Texto:AnsiString;Vias:Integer; ImgQrCode: AnsiString ):AnsiString;
var
  iRet : integer;
  nLoop : integer;
  sTexto : AnsiString;
  lOk : boolean;
begin
  iRet := fFuncFormataTx( PChar(#27+'|21|'+#27) );
  If not (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0')) then
  begin
    result := '1|';
    exit;
  end;
  lOk := True;
  for nLoop := 1 to Vias do
    begin
      sTexto := Texto;
      while not (sTexto = '') do
        begin
          iRet := fFuncFormataTx( PChar(#27+'|20|'+Copy(sTexto,1,40)+'|'+#27) );
          sTexto := Copy(sTexto,41,Length(sTexto));
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
          if not lOk then break;
        end;
      if lOk then
        begin
          iRet := fFuncFormataTx( PChar(#27+'|20|'+#10+'|'+#27) );
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
        end;
      if not lOk then break;
      if not (nLoop = Vias) then
        begin
          iRet := fFuncFormataTx( PChar(#27+'|20|'+Replicate(#10,9)+'|'+#27) );
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
          if not lOk then break;
          Sleep(5000);
        end;
    end;
  if lOk then
    begin
      fFuncFormataTx( PChar(#27+'|21|'+#27) );
      result := '0|';
    end
  else
    result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP40FI.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:AnsiString ):AnsiString;
var
  iRet : Integer;
begin
  // Verifica o ponto decimal dos parâmetros
  Valor := StrTran(Valor,',','.');

  // Faz a impressao do cheque
  iRet := fFuncFormataTx( PChar(#27+'|59|reais|'+#27) );
  if (TrataErroFormataTx(iRet)) and (Copy(Status(1),1,1)='0') then
  begin
    iRet := fFuncFormataTx( PChar(#27+'|57|'+Banco+'|'+
                                             FormataTexto(Valor,14,2,2)+'|'+
                                             Copy(Favorec,1,45)+'|'+
                                             Copy(Cidade,1,27)+'|'+
                                             Copy(Data,1,2)+'|'+
                                             MesExtenso(StrToInt(Copy(Data,4,2)))+'|'+
                                             Copy(Data,7,4)+'|'+
                                             Mensagem+'|'+#27) );
    if TrataErroFormataTx(iRet) then
      Result := Status( 1 )
    else
      Result := '1|';
  end
  else
    Result := '1|';
end;

//----------------------------------------------------------------------------
Function TImpFiscalBematechMP20FI.Status( Tipo:Integer; Texto:AnsiString='' ) : AnsiString;
begin
  Result := _Status(Tipo);
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet : Integer;
  sLinha : AnsiString;
  sForma : AnsiString;
  sSuprimento : AnsiString;
  iForma : Integer;

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
  // 45  - Modelo Fiscal
  // 46 - Marca, Modelo e Firmware

  //  1 - Obtem a Hora da Impressora
  if Tipo = 1 then
  begin
    // Retorno da Data e Hora da Impressora
    iRet := fFuncFormataTx( PChar(#27 + '|35|23|' + #27) );
    if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
      Result := '0|' + Copy(sVar,7,2) + ':' + Copy(sVar,9,2) + ':' + Copy(sVar,11,2)
    else
      Result := '1|';
  end
  //  2 - Obtem a Data da Impressora
  else if Tipo = 2 then
  begin
    // Retorno da Data e Hora da Impressora
    iRet := fFuncFormataTx( PChar(#27 + '|35|23|' + #27) );
    if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
      Result := '0|' + Copy(sVar,1,2) + '/' + Copy(sVar,3,2) + '/' + Copy(sVar,5,2)
    else
      Result := '1|';
  end
  //  3 - Verifica o Papel
  else if Tipo = 3 then
  begin
    // ST1
    // bit 7 | 128 | Pouco papel
    // bit 6 |  64 | Fim de papel
    // bit 5 |  32 | Erro no relogio
    // bit 4 |  16 | Impressora em erro
    // bit 3 |   8 | Primeiro dado de CMD nao foi ESC (1BH)
    // bit 2 |   4 | Comando inexistente
    // bit 1 |   2 | Cupom aberto
    // bit 0 |   1 | Numero de parametros de CMD invalido

    // ST2
    // bit 7 | 128 | Tipo de parametro de CMD invalido
    // bit 6 |  64 | Memoria Fiscal lotada
    // bit 5 |  32 | Erro na Memoria RAM CMOS Nao Volatil
    // bit 4 |  16 | Aliquota nao programada
    // bit 3 |   8 | Capacidade de aliquota programaveis lotada
    // bit 2 |   4 | Cancelamento nao permitido
    // bit 1 |   2 | CGC/IE do proprietario nao programados
    // bit 0 |   1 | Comando nao executado

    // Retorno do Status da impressora
    iRet := fFuncFormataTx( PChar(#27 + '|19|' + #27) );
    if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
    begin
      if Copy(sST1,1,1) = '1' then
        Result := '2|'
      else if Copy(sST1,2,1) = '1' then
        Result := '3|'
      else
        Result := '0|';
    end
    else
      Result := '1|';
  end
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  else if Tipo = 4 then
    Result := '0|TODOS'
  //  5 - Cupom Fechado ?
  else if Tipo = 5 then
  begin
    // Retorno do "Flag" fiscal
    iRet := fFuncFormataTx( PChar(#27 + '|35|17|' + #27) );
    if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
    begin
      sLinha := DecToBin( StrToInt(Trim(Copy(sVar,2,Length(sVar)))) );
      if copy(sLinha,8,1) = '1' then
        Result := '7'
      else
        Result := '0';
    end
    else
      Result := '1|';
  end
  //  6 - Ret. suprimento da impressora
  else if Tipo = 6 then
  begin
    // INSTRUÇÕES DO RETORNO DOS TOTALIZADORES
    // 01 X 01 - 1 byte indicando se alguma forma de pagamento foi utilizada
    // 50 X 16 - Formas de Pagamento
    // 01 X 16 - Valor Recebido
    // 01 X 16 - Troco
    // 50 X 20 - Valor da Forma de Pagamento com 4 decimais
    // 01 X 20 - Valor Recebido com 4 decimais
    // 01 X 20 - Troco com 4 decimais

    // Quando o Retorno é Maior que 700 bytes, Deve-se usar a Retorna_ASCII.
    // Usar nos Comandos : 35|32, 35|33, 35|34...
    fRetorna_ASCII(1);
    // Retorno das Formas de Pagamento
    iRet := fFuncFormataTx( PChar(#27+'|35|32|'+#27) );
    if TrataErroFormataTX(iRet) and (Copy(Status(1),1,1)='0') then
    begin
      sSuprimento := '0';
      for iForma := 0 to 51 do
      begin
        sForma := UpperCase(Trim(Copy(sVar,iForma*16+2,16)));
        if sForma='DINHEIRO' then
        Begin
          // Exemplo de Retorno : '0000000000000000100000' (20 bytes)
          // R$ 10,00 com 4 decimais.
          sSuprimento := copy(sVar,834+(iForma*20),20);
          sSuprimento := FloatToStrf(StrToInt(sSuprimento)/10000,ffFixed,18,2);
          Break;
        End;
      end;
      Result := '0|'+sSuprimento;
    end;
    fRetorna_ASCII(0);                                    // Voltar ao Normal...
  end
  //  7 - ECF permite desconto por item
  else if Tipo = 7 then
    Result := '11|'
  //  8 - Verifica se o dia anterior foi fechado
  else if Tipo = 8 then
  begin
    // Retorno do "Flag" fiscal
    iRet := fFuncFormataTx( PChar(#27 + '|35|17|' + #27) );
    if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
    begin
      sLinha := DecToBin( StrToInt(Trim(Copy(sVar,2,Length(sVar)))) );
      if Copy(sLinha,5,1) = '1' then
        Result := '10|'
      else
        Result := '0|';
    end
    else
      Result := '1|';
  end
  //  9 - Verifica o Status do ECF
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
    Result := '0'
  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  else if Tipo = 14 then
  begin
    iRet := fFuncFormataTx( PChar(#27+'|23|'+#27) );
    if TrataErroFormataTx(iRet) then
    begin
      Status(1);
      // O retorno da impressora vem pelo MP20FI.RET.
      // Se o retorno for 255 a impressora está ABERTA
      // Se o retorno for 000 a impressora está FECHADA
      if sVar = '255' then
        // 1 - Aberta
        Result := '1'
      else
        // 0 - Fechada
        Result := '0';
    end
    else
      Result := '0';
  end
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
  //Retorno não encontrado                                                           ?
  else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.PegaSerie : AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncFormataTx( PChar(#27+'|35|00|'+#27) );
  if (TrataErroFormataTX(iRet)) and (Copy(Status(1),1,1)='0') then
    Result := '0|' + Trim(sVar)
  else
    Result := '1|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20F.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:AnsiString ) : AnsiString;
begin
  Result := '0|';
end;
//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.LeTotNFisc:AnsiString;
begin
        Result := '0|-99';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20F.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ) : AnsiString;
var
  iRet : integer;
  sRet : AnsiString;
  nLoop : integer;
  sTexto : AnsiString;
  lOk : boolean;
begin
  lOk := True;
  for nLoop := 1 to Vias do
    begin
      sTexto := Texto;
      while not (sTexto = '') do
        begin
          iRet := fFuncFormataTx( PChar(#27+'|20|'+Copy(sTexto,1,40)+'|'+#27) );
          sTexto := Copy(sTexto,41,Length(sTexto));
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
          if not lOk then break;
        end;
      if lOk then
        begin
          iRet := fFuncFormataTx( PChar(#27+'|20|'+#10+'|'+#27) );
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
        end;
      if not lOk then break;
      if not (nLoop = Vias) then
        begin
          iRet := fFuncFormataTx( PChar(#27+'|20|'+Replicate(#10,9)+'|'+#27) );
          lOk := (TrataErroFormataTx(iRet) and (Copy(Status( 1 ),1,1)='0'));
          if not lOk then break;
          Sleep(5000);
        end;
    end;
  if lOk then
    sRet := '0|'
  else
    sRet := '1|';
  result := sRet;
end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenBematech( sPorta:AnsiString ) : AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: MP20FI32.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  iRet : Integer;
  pPorta : PChar;
  bRet : Boolean;
begin
  If Not bOpened Then
  Begin
    fHandle := LoadLibrary( 'MP20FI32.DLL' );
    if (fHandle <> 0) Then
    begin
      bRet := True;

      // FechaPorta () as integer
      aFunc := GetProcAddress(fHandle,'FechaPorta');
      if ValidPointer( aFunc, 'FechaPorta' ) then
        fFuncFechaPorta := aFunc
      else
        bRet := False;

      // IniPortaStr (Porta as AnsiString) as integer
      aFunc := GetProcAddress(fHandle,'IniPortaStr');
      if ValidPointer( aFunc, 'IniPortaStr' ) then
        fFuncIniPortaStr := aFunc
      else
        bRet := False;

      // FormataTX (ByVal BUFFER As AnsiString) as integer
      aFunc := GetProcAddress(fHandle,'FormataTX');
      if ValidPointer( aFunc, 'FormataTX' ) then
        fFuncFormataTX := aFunc
      else
        bRet := False;

      // Status_Mp20FI ( Var1 as integer, Var2 as integer, Var3 as integer, Var4 as integer )
      aFunc := GetProcAddress(fHandle,'Status_Mp20FI');
      if ValidPointer( aFunc, 'Status_Mp20FI' ) then
        fStatus_Mp20FI := aFunc
      else
        bRet := False;

      // Le_Variaveis (ByVal var As AnsiString) As Integer
      aFunc := GetProcAddress(fHandle,'Le_Variaveis');
      if ValidPointer( aFunc, 'Le_Variaveis' ) then
        fLe_Variaveis := aFunc
      else
        bRet := False;

      // Retorna_ASCII (ByVal var As Integer) As Integer
      aFunc := GetProcAddress(fHandle,'Retorna_ASCII');
      if ValidPointer( aFunc, 'Retorna_ASCII' ) then
        fRetorna_ASCII := aFunc
      else
        bRet := False;

    end
    else
    begin
      ShowMessage('O arquivo MP20FI32.DLL não foi encontrado');
      bRet := False;
    end;

    if bRet then
    begin
      result := '0|';
      pPorta := StrAlloc(4);
      StrPCopy(pPorta, sPorta);
      iRet := fFuncIniPortaStr(pPorta);
      StrDispose(pPorta);
      if iRet <> 1 then
      begin
        ShowMessage('Erro na abertura da porta');
        result := '1|';
      end
      else
        bOpened := True;
    end
    else
      result := '1|';
  End
  Else
    Result := '0';
End;

//----------------------------------------------------------------------------
Function CloseBematech : AnsiString;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      if fFuncFechaPorta <> 1 then
      begin
        ShowMessage('Erro ao fechar a comunicação com impressora Fiscal');
        result := '1|'
      end;
      FreeLibrary(fHandle);
      fHandle := 0;
    end;
    bOpened := False;
  End;
  Result := '0|';
end;

//----------------------------------------------------------------------------
function TrataErroFormataTX( iErro : Integer ): Boolean;
begin
  If LogDll Then
    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Retorno Bematech: '+ IntToStr(iErro) ));

  if iErro = 1 then
    begin
      ShowMessage('Erro de comunicação física com a Impressora.');
      Result := False;
    end
  else if iErro = -2 then
    begin
      ShowMessage('Parâmetro Inválido.');
      Result := False;
    end
  else if iErro = -3 then
    begin
      ShowMessage('Versão antiga do firmware (não suporta novo comando).');
      Result := False;
    end
  else
  Result := True;
end;

//----------------------------------------------------------------------------
Function _Status( Tipo:Integer ) : AnsiString;
  // Parametros
  // 1- Verifica se o ultimo comando foi executado
var
  iRet : Integer;
  bErro : Boolean;
begin
  bErro := False;

  // Substitui o STATUS.BIN
  Retorno := 0;
  ACK     := 0;
  ST1     := 0;
  ST2     := 0;
  iRet := fStatus_Mp20FI( Retorno, ACK, ST1, ST2 );

  If LogDll Then
      WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Status Bematech: '+ IntToStr( Retorno ) + ', ' + IntToStr(ACK) + ', ' +
                               IntToStr(ST1) + ', ' + IntToStr(ST2) ));

  if TrataErroFormataTX(iRet) then
  begin
    sST1 := DecToBin(ST1);
    sST2 := DecToBin(ST2);

    case Tipo of
      1 : if copy(sST2,8,1) = '1' then
            bErro := True;
      2 : if copy(sST1,2,1) = '1' then
            bErro := True;
      3 : if copy(sST1,1,1) = '1' then
            bErro := True;
    else
      bErro := False
    end;
  end
  else
    bErro := False;

  if bErro then
    Result := '1|'
  else
  begin
    sVar := Space(3000);
    // Substitui a STATUS.RET
    iRet := fLe_Variaveis( sVar );
    if TrataErroFormataTX(iRet) then
      if Pos( 'COMANDO NAO EXECUTADO', UpperCase(sVar) ) > 0 then
        Result := '1|'
      else
      begin
        // Quando usar os Comandos : 35|32, 35|33, 35|34, que usam a fRetorna_ASCII(1),
        // a sVar não tem Chr(0) no final.
        if Pos(#0,sVar)<>0 then
          sVar := Copy(sVar, 1, Pos(#0,sVar)-1);
        Result := '0|';
      end
    else
      Result := '1|';
  end;
end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Bematech MP40FI-II
///
function TImpChequeBematechMP40FI.Abrir( aPorta:AnsiString ): Boolean;
begin
  Result := (Copy(OpenBematech(aPorta),1,1) = '0');
end;

//----------------------------------------------------------------------------
function TImpChequeBematechMP40FI.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  iRet : Integer;
  sData : AnsiString;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;
  // Faz a impressao do cheque
  iRet := fFuncFormataTx( PChar(#27+'|59|reais|'+#27) );
  if (TrataErroFormataTx(iRet)) and (Copy(_Status(1),1,1)='0') then
    iRet := fFuncFormataTx( PChar(#27+'|57|'+Banco+'|'+FormataTexto(Valor,14,2,2)+'|'+Copy(Favorec,1,45)+'|'+Copy(Cidade,1,27)+'|'+Copy(Data,7,2)+'|'+MesExtenso(StrToInt(Copy(Data,5,2)))+'|'+Copy(Data,1,4)+'|'+Mensagem+'|'+#27) );
    if TrataErroFormataTx(iRet) then
      result := (Copy(_Status( 1 ),1,1) = '0')
  else
    result := False;
end;

//----------------------------------------------------------------------------
function TImpChequeBematechMP40FI.Fechar( aPorta:AnsiString ): Boolean;
begin
  Result := (Copy(CloseBematech,1,1) = '0');
end;

//----------------------------------------------------------------------------
function TImpChequeBematechMP40FI.StatusCh( Tipo:Integer ):AnsiString;
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
function TImpFiscalBematechMP20FI.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString;
var
  pPath           : pchar;
  sPath           : AnsiString;
  fArquivo        : TIniFile;
  sPedido         : AnsiString;
  sTefPedido      : AnsiString;
  sCondicao       : AnsiString;
  sComm           : AnsiString;
  iRet            : Integer;
begin
  //*******************************************************************************
  // Para não forçar o cliente a utilizar registradores fixos do ECF na emissão
  // de cupom não fiscal vinculado e não vinculado para a impressão do comprovante
  // de venda (função abaixo) sera utilizado o arquivo BEMAFI32.INI
  // abaixo:
  //
  // [MICROSIGA]
  // Pedido=Nome do totalizador
  // TefPedido=Nome do totalizador
  // Condicao=Condição de pagamento
  //
  // Onde:
  // - Pedido deverá conter o nome do totalizador que irá conter os valores de registros
  // do cupom não fiscal ref. ao comprovante de venda
  // - TefPedido deverá conter o nome do totalizador que irá conter os valores de
  // de registros do cupom não fiscal ref. ao comprovante do TEF quando for utilizado
  // na venda assistida (LOJA701) com o conceito de reservas + pedidos.
  // Os valores default para esses totalizadores será "01"
  // - Condicao deverá conter a condição de pagamento que servirá para o recebimento
  // do comprovante não fiscal não vinculado
  //*******************************************************************************

  //*******************************************************************************
  // Inicialização das variaveis
  //*******************************************************************************
  Result      := '1';
  pPath       := StrAlloc( 100 );
  FillChar( pPath^, 100, 0 );

  //*******************************************************************************
  // Pega os nomes dos totalizadores no arquivo de configuração (BEMAFI32.INI)
  //*******************************************************************************
  GetSystemDirectory(pPath, 100);
  sPath := StrPas( pPath );
  fArquivo    := TIniFile.Create(sPath+'\BEMAFI32.INI');
  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Pedido', '01' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'TefPedido', '01' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondicao   := fArquivo.ReadString('Microsiga', 'Condicao', '' );

  //*******************************************************************************
  // Faz o tratamento dos parâmetros
  //*******************************************************************************
  Valor       := FormataTexto(Valor,12,2,2);
  sCondicao   := Copy( sCondicao+Space(16), 1, 16 );

  //*******************************************************************************
  // Faz o recebimento não fiscal / Comprovante não fiscal não vinculado
  //*******************************************************************************

  sComm := '|66|'+sCondicao+'|';
  iRet := fFuncFormataTx( PChar(#27+sComm+#27) );
  If (TrataErroFormataTx( iRet )) and (copy( Status(1),1,1 )='1') then
  begin
      iRet := fFuncFormataTx( PChar(#27+'|25|'+sPedido+'|'+Valor+'|'+sCondicao+'|'+#27) );
      If TrataErroFormataTx( iRet ) then
      begin
        sComm := '|66|'+sCondicao+'|';
        iRet := fFuncFormataTx( PChar(#27+sComm+#27) );
        If TrataErroFormataTx( iRet ) then
          If Copy(TextoNaoFiscal( Texto, 1 ),1,1) = '0' then
            If Copy(FechaCupomNaoFiscal,1,1) = '0' then
              Result := '0';
      end;
  end;

  //*******************************************************************************
  // Libera as variaveis
  //*******************************************************************************
  fArquivo.Free;
  StrDispose( pPath );

end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;
begin
  ShowMessage( MsgIndsImp );
  result := '1';
end;
//------------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;


//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.RedZDado( MapaRes:AnsiString ):AnsiString;
Begin
  Result := '1';
End;

//------------------------------------------------------------------------------
Function TrataTags( Mensagem : AnsiString ) : AnsiString;
var
  cMsg : AnsiString;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//----------------------------------------------------------------------------
function TImpFiscalBematechMP20FI.GrvQrCode(SavePath,
  QrCode: AnsiString): AnsiString;
begin

end;

(*initialization
  RegistraImpressora('BEMATECH MP20FI I - V. 02.12',  TImpFiscalBematechMP20F,  'BRA', '030203');
  RegistraImpressora('BEMATECH MP20FI I - V. 03.00',  TImpFiscalBematechMP20F,  'BRA', ' ');
  RegistraImpressora('BEMATECH MP40FI I - V. 02.12',  TImpFiscalBematechMP40F,  'BRA', '031201');
  RegistraImpressora('BEMATECH MP40FI I - V. 03.00',  TImpFiscalBematechMP40F,  'BRA', ' ');
  RegistraImpCheque ('BEMATECH MP40 FI I'          ,  TImpChequeBematechMP40F,  'BRA');*)
end.
//----------------------------------------------------------------------------
