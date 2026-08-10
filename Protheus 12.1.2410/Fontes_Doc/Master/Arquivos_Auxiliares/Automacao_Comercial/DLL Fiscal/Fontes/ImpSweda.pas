unit ImpSweda;

interface

uses
  Dialogs,
  ImpFiscMain,
  ImpCheqMain,
  CMC7Main,
  Windows,
  SysUtils,
  classes,
  IniFiles,
  Forms,
  LojxFun;

Type
  TCMC7_Sweda = class(TCMC7)
  public
    function Abrir( sPorta, sMensagem:String ):String; override;
    function Fechar : String; override;
    function LeDocumento:String; override;
    function LeDocCompleto : String; override;
  end;

Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sweda V03 (Série - IF S-7000)
///  (Sem mecanismo de impressão de cheque)
  TImpFiscalSweda = class(TImpressoraFiscal)
  private
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function LeituraX:String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function PegaPDV:String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function DescontoTotal( vlrDesconto:String ; nTipoImp:Integer ): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function AbreECF: String; override;
    function FechaECF: String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function Gaveta:String; override;
    function Status( Tipo:Integer; Texto:String ):String; override;
    function PulaLinha( Numero:Integer ):String;
    function StatusImp( Tipo:Integer ):String; override;
    function GravaCondPag( condicao:string ) : String; override;
    function PegaSerie:String; override;
    procedure AlimentaProperties; override;
    function ImpostosCupom(Texto: String): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : String ):String; override;
    function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer; ImgQrCode: String) : String; override;
    function LeTotNFisc:String; override;
    function DownMF(sTipo, sInicio, sFinal : String):String; override;
    function RedZDado( MapaRes:String ):String; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
    function ImpTxtFis(Texto : String) : String; Override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sweda Versao 1.0 (Série IF S-7000)
///  (Sem mecanismo de impressão de cheque)
  TImpFiscalSweda100 = class(TImpFiscalSweda)
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function LeituraX:String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function PulaLinha( Numero:Integer ):String;
    function AbreECF: String; override;
    function FechaECF: String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function TotalizadorNaoFiscal( Numero,Descricao:String ):String; override;
    function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
    procedure AlimentaProperties; override;
    function EnviaComandoEspera(Texto:PChar;var Buffer:String;iVezes:Integer = 2):String;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function HorarioVerao( Tipo:String ):String; override;
  end;

  TImpFiscalSweda1A = class(TImpFiscalSweda100)
  public
    function GravaCondPag( condicao:string ) : String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sweda Versao 1.0 (Série IF S-7000)
///
  TImpFiscalSwedaII100= class(TImpFiscalSweda100)
  public
    function Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:String ): String; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sweda Versão 1.1
///
  TImpFiscalSweda101= class(TImpFiscalSweda100)
  public
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function GravaCondPag( condicao:string ) : String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function DescontoTotal( vlrDesconto:String ; nTipoImp:Integer ): String; override;
    function Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function FechaCupomNaoFiscal(): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    procedure AlimentaProperties; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; Override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sweda IF S-9000 Versão 1.0
///
  TImpFiscalSweda9000_10= class(TImpFiscalSweda101)
  public
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sweda IFS 9000I - Versão 1.7
  TImpFiscalSweda9000_17= class(TImpFiscalSweda101)
  public
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
   end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sweda Versão 1.5
///
  TImpFiscalSweda15= class(TImpFiscalSweda100)
  public
    function GravaCondPag( condicao:string ) : String; override;
  end;

  TImpFiscalSweda16= class(TImpFiscalSweda15)
  public
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Sweda IFS II V1.00
///
  TImpChequeSwedaII100 = class(TImpressoraCheque)
  public
    function Abrir( aPorta:String ): Boolean; override;
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean; override;
    function Fechar( aPorta:String ): Boolean; override;
    function StatusCh( Tipo:Integer ):String; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Sweda IFS II V03
///
  TImpChequeSweda = class(TImpChequeSwedaII100)
  public
    function Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean; override;
    function StatusCh( Tipo:Integer ):String; override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenSweda ( sPorta:String ) : String;
Function CloseSweda( sPorta:String ) : String;
Function EnviaComando(Texto:PChar):String;
Function TrataTags( Mensagem : String ) : String;

//----------------------------------------------------------------------------
implementation
var
  bOpened : Boolean;
  fHandle : THandle;
  fFuncAbrePorta   : function (Numero,Timeout:Integer):Boolean; far;
  fFuncEnviaComando: function (Texto:PChar):ShortString; far;
  fFuncFechPorta   : function (Numero:Integer):Boolean; far;
  sComando293      : String;
  sComando294      : String;
  sComando295      : String;
  sCMC7Porta       : String;
  nUltimoSeq       : Integer;
  sVinculado       : String;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Sweda
///
function TImpFiscalSweda.Abrir(sPorta : String; iHdlMain:Integer) : String;
Var
sPath : String;
sAdv  : String;
sAviso : String;
fArquivo : TIniFile;
begin
  // Tratamento realizado para mudar a captura do NC para o COO. Exibe mensagem
  // de aviso e armazena se quer deseja mostrar ou não no sigaloja.ini (/bin/remote)

  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'\SIGALOJA.INI');
  If fArquivo.ReadString('SWEDA', 'AVISO', '' ) = '' then
    fArquivo.WriteString('SWEDA', 'AVISO', 'S' );
  sAviso := fArquivo.ReadString('SWEDA', 'AVISO', '' );

  If sAviso = 'S' then
  begin
    If MessageDlg('A partir da versão 0.2.85.29, para as impressoras Sweda,' +#10+
                'o número de controle dos cupons emitidos deixa de ser o Número do ' +#10+
                'Cupom (NC) e passa a ser o Contador de Ordem de Operação (COO).' +#10 + #10 +
                'POR FAVOR, ALTERE A SÉRIE NO CADASTRO DE ESTAÇÃO!.' +#10+
                'A NÃO ALTERAÇÃO PODE CAUSAR DUPLICIDADE NA GERAÇÃO' +#10+
                'DOS TÍTULO A RECEBER!'+ #10 + #10 +
                'Deseja continuar exibindo essa mensagem?',
     mtWarning	, [mbYes, mbNo], 0) = 7 then
    fArquivo.WriteString('SWEDA', 'AVISO','N');
  end;

  // Abre a porta
  Result := OpenSweda( sPorta );

  // Carrega as aliquotas para ganhar performance
  if Copy(Result,1,1) = '0' then
    AlimentaProperties;
end;

//---------------------------------------------------------------------------
function TImpFiscalSweda.Fechar( sPorta:String ) : String;
begin
  Result := CloseSweda ( sPorta );
end;

//---------------------------------------------------------------------------
function TImpFiscalSweda.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;
//----------------------------------------------------------------------------
function TImpFiscalSweda.LeituraX : String;
var
  sRet : String;
begin
  MsgLoja('Aguarde a impressão da Leitura X...');
  sRet := EnviaComando( PChar(#27+'.13'+'}') );
  result := Status( 1, sRet );
  if copy(result,1,1) = '0' then
  begin
    Sleep(33000);
    sRet := PulaLinha(7);
  end;
  MsgLoja;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.ReducaoZ ( MapaRes:String ): String;
          // FUNÇÕES AUXILIARES...

          // Formata as alíquotas...
          Function FormataAliquota(sTributo:String):String;
            // Procura a alíquota pelo índice. Exemplo: índice('TXX') devolve: TXX,XX...
            Function FindAliquota(sString:String):String;
            Var
              iPosicao:Integer;
            Begin
                // Algumas impressoras podem conter valores nulos ao inv‚s de T??...
                If sString=EmptyStr Then
                Begin
                   Result := '';
                   Exit;
                End;
                // Procura a alíquota no primeiro pacote...
                Result   := EnviaComando( PChar(#27+'.293}') );
                Result   := Copy(Result,48,Length(Result));
                iPosicao := Pos(sString,Result);
                If (iPosicao>0) And (Trim(Copy(Result,iPosicao+8,4))<>EmptyStr) Then
                    Result := Copy(sString,1,1)+Copy(Result,iPosicao+8,2)+','+Copy(Result, iPosicao+10,2)
                Else
                  Begin
                    // Caso não encontre no primeiro pacote. Procura a alíquota no segundo pacote...
                    Result   := EnviaComando( PChar(#27+'.294}') );
                    Result   := Copy(Result,8,Length(Result));
                    iPosicao := Pos(sString,Result);
                    If (iPosicao>0) And (Trim(Copy(Result,iPosicao+8,4))<>EmptyStr) Then
                        Result := Copy(sString,1,1)+Copy(Result,iPosicao+8,2)+','+Copy(Result, iPosicao+10,2)
                    Else
                      Begin
                        // Caso não encontre no segundo pacote. Procura a alíquota no último pacote...
                        Result := EnviaComando( PChar(#27+'.295}') );
                        Result   := Copy(Result,8,Length(Result));
                        iPosicao := Pos(sString,Result);
                        If (iPosicao>0) And (Trim(Copy(Result,iPosicao+8,4))<>EmptyStr) Then
                            Result := Copy(sString,1,1)+Copy(Result,iPosicao+8,2)+','+Copy(Result, iPosicao+10,2)
                        Else
                          Result := '';
                      End;
                  End;
            End;
          Var
            sValor:String;
            nValor:Real;
          Begin
            If (Copy(sTributo,1,3)=EmptyStr) Then
            Begin
               Result := '';
               Exit;
            End;
            Result := FindAliquota( Copy(sTributo,1,3) );
            If Result<>EmptyStr Then
            Begin
               //  Formata o campo: Aliquota '  ' Valor '  ' Imposto Debitado
               sValor := FloatToStrf(StrToFloat(Copy(sTributo, 4, 14))/100, ffFixed, 14, 2);
               sValor := FormataTexto(sValor, 14, 2, 1, '.');
               nValor := StrToFloat(sValor)*StrToFloat(Copy(StrTran(Result,',','.'),2,5)); // ==>> 162,75
               Result := Result + ' ' + sValor + ' ' + FormataTexto(FloatToStr(Int(nValor)/100), 14, 2, 1, '.');
            End;
          End;

          // Função que emite de fato a redução Z...
          Function EmiteReducaoZ(sData:String; var sRetorno:String):Boolean;
          Var
            sRet:String;
            iContador: Integer;
          Begin
            // Delay de aproximadamente 2 minutos para tentar emitir a Redução Z...
            For iContador:=0 To 23 Do
            Begin
              sRetorno := EnviaComando( PChar(#27+'.14' + sData + '}') );   // Redução Z = 14 .. Leitura X = 13
              sRet     := Status( 1, sRetorno );
              if Copy(sRet,1,1) = '0' then
              begin
                PulaLinha(7);
                Break;
              end;
              Sleep(5000);
            End;  // For
            Result := (sRet='0');
          End;

var
  dDataHoje: TDateTime;
  sRet, sDataHoje, sRet271, sRet279, sRet272 : String;
  iContador: Integer;
  aRetorno: array of String;
begin
  If Trim(MapaRes)='S' then
  Begin
      // COMANDO 2...
      sRet272 := EnviaComando( PChar(#27+'.272}') );
      if Copy(Status(1,sRet272),1,1)<>'0' then
        Begin
          result := '1';
          Exit;
        End;

      // COMANDO 1...
      sRet271 := EnviaComando( PChar(#27+'.271}') );
      if Copy(Status(1,sRet271),1,1)<>'0' then
        Begin
          result := '1';
          Exit;
        End;

      // COMANDO 9...
      sRet279 := EnviaComando( PChar(#27+'.279}') );
      if Copy(Status(1,sRet279),1,1)<>'0' then
        Begin
          result := '1';
          Exit;
        End;

      // Prepara o array, aRetorno, com os dados do ECF...
      SetLength(aRetorno,21);
      aRetorno[ 0]:= Copy(sRet271, 8, 2) + '/' + Copy(sRet271,10, 2) + '/' + Copy(sRet271,12, 2); // Data Fiscal (DDMMAA)
      aRetorno[ 1]:= Copy(sRet271,4, 3);                                   // Nr. ECF
      aRetorno[ 2]:= Copy(Copy(sRet272, 8, 11)+Space(13), 0, 13);                                  // Identificação do Equipamento	(9 caracteres)
      aRetorno[ 4]:= FloatToStrf(StrToFloat(Copy(sRet271,20,17))/100, ffFixed, 18, 2);            // Grande Total (17 dígitos)
      aRetorno[ 4]:= FormataTexto(aRetorno[4], 19, 2, 1, '.');
      aRetorno[ 5]:= FormataTexto(Copy(sRet279,112, 4), 6, 0, 2);                                                         // Cupom Fiscal inicial - irredutível
      aRetorno[ 6]:= FormataTexto(Copy(sRet271,14, 4), 6, 0, 2);                                                         // --Numero documento Final--
      aRetorno[ 7]:= FloatToStrf((StrToFloat(Copy(sRet271,61,12))+StrToFloat(Copy(sRet271,77,12)))/100, ffFixed, 18, 2);  // Total de Vendas canceladas no dia	  (12 dígitos)
      aRetorno[ 7]:= FormataTexto(aRetorno[7], 15, 2, 1, '.');
      aRetorno[ 8]:= FloatToStrf(StrToFloat(Copy(sRet271,105,12))/100, ffFixed, 18, 2);                                   // Total Líquido do Dia	  (12 dígitos)
      aRetorno[ 8]:= FormataTexto(aRetorno[8], 15, 2, 1, '.');
      aRetorno[ 9]:= FloatToStrf(StrToFloat(Copy(sRet271,93,12))/100, ffFixed, 18, 2);                                    // Total de Descontos no Dia	  (12 dígitos)
      aRetorno[ 9]:= FormataTexto(aRetorno[9], 11, 2, 1, '.');
      aRetorno[10]:= FloatToStrf(StrToFloat(Copy(sRet272,43,12))/100, ffFixed, 18, 2);                                    // Total Substituição	(12 dígitos)
      aRetorno[10]:= FormataTexto(aRetorno[10], 11, 2, 1, '.');
      aRetorno[11]:= FloatToStrf(StrToFloat(Copy(sRet272,19,12))/100, ffFixed, 18, 2);                                    // Total Isento	(12 dígitos)
      aRetorno[11]:= FormataTexto(aRetorno[11], 11, 2, 1, '.');
      aRetorno[12]:= FloatToStrf(StrToFloat(Copy(sRet272,31,12))/100, ffFixed, 18, 2);                                    // Total Não Tributável	(12 dígitos)
      aRetorno[12]:= FormataTexto(aRetorno[12], 11, 2, 1, '.');
      aRetorno[13]:= aRetorno[0];                                                                                         // --data da reducao z--
      aRetorno[15]:= FormataTexto('0',16, 0, 2);                                                                          // --outros recebimentos--
      aRetorno[16]:= FormataTexto('0',14, 2, 1)+' '+FormataTexto('0',14, 2, 1);                                           // Total ISS
      aRetorno[17]:= Copy(sRet279,117, 3);                                                           // CRO - Contador de Reinício de Operação
      aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS
      aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS
      aRetorno[20]:= '00';                                         // QTD DE Aliquotas

      // COMANDO 272, 273 e 274 para pegar os totais das alíquotas cadastradas...
      If Copy(sRet272, 95, 3) <> EmptyStr Then
        Begin
          aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);             // QTD DE Aliquotas programadas no ECF
          SetLength( aRetorno, Length(aRetorno)+1 );
          aRetorno[High(aRetorno)] := FormataAliquota( Copy(sRet272,95,15) );

          Result := EnviaComando( PChar(#27+'.273}') );
          if Copy(Status(1,Result),1,1)='0' Then
          Begin
             Result := Copy(Result,8,105) + Copy(EnviaComando(PChar(#27+'.274}')),8,105);
             For iContador:=0 To 13 Do
             Begin
               If (Copy(Result,1,3) <> EmptyStr) And (Copy(Result,1,1)='T')Then
               Begin
                     sRet     := FormataAliquota( Trim(Copy(Result,1,15)) );
                     If sRet<>EmptyStr Then
                     Begin
                        If Copy(sRet,1,1)='S' then
                            aRetorno[16] := FormataTexto(FloatToStr(StrToFloat(copy(aRetorno[16],1,14))+StrToFloat(copy(sRet,8,14))),14,2,1)+' '+
                                            FormataTexto(FloatToStr(StrToFloat(copy(aRetorno[16],16,14))+StrToFloat(copy(sRet,23,14))),14,2,1)
                        else
                        begin
                           aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);             // QTD DE Aliquotas programadas no ECF
                           SetLength( aRetorno, Length(aRetorno)+1 );
                           aRetorno[High(aRetorno)] := sRet;
                        end;
                     End;
               End;
               Result  := Copy(Result,16,Length(Result));
             End;
          End;
        End;
  End;  // Fim do Mapa Resumo...


    dDataHoje:= Now;
    sDataHoje := FormataData( dDataHoje, 1 );
    If EmiteReducaoZ(sDataHoje,sRet) then
        Result:='0';

  If Trim(MapaRes)='S' then
  Begin
    // Repete o COMANDO 1... após a emissão da Redução Z...
    // Delay de aproximadamente 2 minutos para pegar o COO e o contador de Reduções...
    For iContador:=0 To 23 Do
    Begin
      sRet271 := EnviaComando( PChar(#27+'.271}') );
      If Copy(Status(1,sRet271),1,1)='0' Then
        Break;
      Sleep(5000);
    End;
    aRetorno[ 3] := Copy(sRet271,41, 4);                                                         // Número de Reduçöes (4 dígitos)
    aRetorno[14] := FormataTexto(Copy(sRet271,14, 4), 6, 0, 2);                                  // Sequencial de Operação  (4 dígitos)
    Result := '0|';
    For iContador:= 0 to High(aRetorno) do
      Result := Result + aRetorno[iContador]+'|';
  End;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.AbreECF : String;
begin
  result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.FechaECF : String;
var
  sRet : String;
  dDataHoje : TDateTime;
  sDataHoje : String;
begin
  MsgLoja('Aguarde a impressão da Redução Z...');

  dDataHoje:= Now;
  sDataHoje := FormataData( dDataHoje, 1 );
  sRet := fFuncEnviaComando( PChar(#27+'.14' + sDataHoje + '}') );
  result := Status( 1, sRet );
  if copy(result,1,1) = '0' then
    sRet := PulaLinha(7);
  MsgLoja;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.AbreCupom(Cliente:String; MensagemRodape:String) : String;
var
  sRet : String;
begin
  If Pos('|', Cliente) > 0 then
    Cliente := Copy( Cliente, 1, (Pos('|',Cliente) - 1));

  sRet := EnviaComando( PChar(#27+'.17' + Cliente + '}') );
  nUltimoSeq := 1;
  result := Status( 1,sRet );
  // Aguarda 3 Segundos, Que é o Tempo Necessário Para a Impressão.
  Sleep(3000);
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.PegaCupom(Cancelamento:String):String;
var
  sRet, sRet28 : String;
begin
  If Cancelamento = 'T' then
  Begin
        sRet28 := EnviaComando( PChar(#27+'.28}') );
        sRet28 := Copy(sRet28,8,8);
        If sRet28 <> ' VENDAS ' then
        Begin
            Result := '0|0000  ';
            Exit;
        End;
  End;

  sRet := EnviaComando( PChar(#27+'.271}') );
  if Copy(sRet,2,1)<>'+' then
    sRet := EnviaComando( PChar(#27+'.271}') );
  if Copy(sRet,2,1)<>'+' then
    ShowMessage('Erro ao Ler o Numero do Cupom no ECF.');
  if Copy(Status(1,sRet),1,1)='0' then
    result := '0|' + copy(sRet,14,4) +'  '
  else
    result := '1';

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.PegaPDV:String;
var
  sRet : String;
  i: integer;
begin
  i:=0;

  Repeat
     sRet := EnviaComando( PChar(#27+'.271}') );
     i:=i+1;
  until ((copy(sRet,2,1)<> '-') and (i<20));

  result := Status(1,sRet);
  if Copy(Status(1,sRet),1,1)='0' then
    result := '0|' + copy(sRet,4,3)
  else
    result := '1';
end;



//----------------------------------------------------------------------------
function TImpFiscalSweda.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
    Function ProcuraAliq(Aliq: string): String;
    Begin
        Aliq:= FormataTexto(Aliq,5,2,1);
        Aliq:= Copy(Aliq,1,2)+Copy(Aliq,4,2);
        // Procura a alíquota no primeiro pacote...
        If Pos(Aliq,sComando293) > 0 Then
            Result := Copy(sComando293,Pos(Aliq,sComando293)-8,3)
        Else
        Begin
            // Caso não encontre no primeiro pacote. Procura a alíquota no segundo pacote...
            If Pos(Aliq,sComando294) > 0 Then
                Result := Copy(sComando294,Pos(Aliq,sComando294)-8,3)
            Else
            Begin
                // Caso não encontre no segundo pacote. Procura a alíquota no último pacote...
                If Pos(Aliq,sComando295) > 0  Then
                    Result := Copy(sComando295,Pos(Aliq,sComando295)-8,3)
                Else
                    Result := 'T  ';
            End;
        End;
    End;
var
  sAliq, sSituacao, sRet: String;
  aAliq : TaString;
  iPos, iTamanho : Integer;
  nPos : Integer;
  sUnid : String;               // Guarda o caracter da legenda da unidade
begin
  // Verifica a casa decimal dos parâmetros
  qtde := StrTran(qtde,',','.');
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');
  vlTotIt := Trim(StrTran(vlTotIt,',','.'));

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    if StrToFloat(vlrdesconto) <> 0 then
    begin
      sRet := fFuncEnviaComando( PChar(#27+'.02'+Space(10)+FormataTexto(vlrdesconto,12,2,2) + '}') );
      result := Status( 1,sRet );
    end
    else
      result := '0';
    exit;
  end;

  // Faz o tratamento da aliquota
  sSituacao := copy(aliquota,1,1);
  aliquota := Trim(StrTran(copy(aliquota,2,5),',','.'));

  // Checa as aliquotas
  sRet := LeAliquotas;

  // Problemas na leitura de aliquota ?
  if copy( sRet, 1, 1 ) <> '0' then
  begin
    result := '1|';
    exit;
  end
  else
    sRet := copy( sRet, 3, length( sRet ) );

  // Verifica se a aliquota é ISENTA, c/SUBSTITUICAO TRIBUTARIA, NAO TRIBUTAVEL OU ISS
  If sSituacao = 'T' then
  begin

    MontaArray( sRet, aAliq );
    iPos := 0;
    for iTamanho:=0 to Length(aAliq)-1 do
      if aAliq[iTamanho] = aliquota then
        iPos := iTamanho + 1;

    if (iPos = 0) and (Pos(sSituacao,'TS') > 0) then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1|';
      exit;
    end;

    sAliq := ProcuraAliq(aliquota);

  end
  else if Trim(sSituacao) = 'I' then
        sAliq:= 'I  '
  else if Trim(sSituacao) = 'F' then
        sAliq:= 'F  '
  else if Trim(sSituacao) = 'N' then
        sAliq:= 'N  '
  else
        sAliq := 'T0 ';

  nPos := Pos('.',vlTotIt);
  VlTotIt := FormataTexto(Copy(vlTotIt,1,nPos+2),12,2,2);
  if copy(vlrUnit,length(vlrUnit)-3,1) = '.' then
  begin
    VlrUnit	:= FormataTexto(vlrUnit,9,3,2);
    Descricao:= '~'+descricao;
  end
  else
  begin
    VlrUnit	:= FormataTexto(vlrUnit,9,2,2);
  end;

  If UpperCase( Trim( UnidMed ) ) = 'L' Then
    sUnid := '@'
  Else
  Begin
    If ( UpperCase( Trim( UnidMed ) ) = 'MT' ) Or (UpperCase( Trim( UnidMed ) ) = 'M') Then
      sUnid := ')'
    Else
    Begin
      If UpperCase( Trim( UnidMed ) ) = 'KG' Then
        sUnid := '!'
      Else
        sUnid := '^';
    End;
  End;

  // Efetua o registro do item
  sRet := EnviaComando( PChar(#27+'.01'+ Copy(codigo+Space(13),1,13)+
                                              FormataTexto(qtde,7,3,2) +
                                              vlrUnit +
                                              vlTotIt +
                                              sUnid + Copy(descricao+Space(23),1,23) +
                                              sAliq + '}') );
 // verifica se houve erro no registro do item e registra o desconto
  if copy( Status(1,sRet),1,1 ) = '0' then
    if StrToFloat(vlrdesconto) <> 0 then
      sRet := fFuncEnviaComando( PChar(#27+'.02'+Space(10)+FormataTexto(vlrdesconto,12,2,2) + '}') );

  result := Status( 1,sRet );

end;


//----------------------------------------------------------------------------
function TImpFiscalSweda.LeAliquotas:String;
begin
  result := '0|'+Aliquotas;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.LeAliquotasISS:String;
begin
  result := '0|'+ISS;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.LeCondPag:String;
begin
   result := '0|'+FormasPgto;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.DescontoTotal( vlrDesconto:String ; nTipoImp:Integer): String;
var
  sRet : String;
begin
  vlrDesconto := StrTran(vlrDesconto,',','.');
  sRet := fFuncEnviaComando( PChar(#27+'.03'+Space(10)+FormataTexto(vlrDesconto,12,2,2)+'}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.AcrescimoTotal( vlrAcrescimo:String ): String;
var
  sRet : String;
begin
  vlrAcrescimo := StrTran(vlrAcrescimo,',','.');
  sRet := fFuncEnviaComando( PChar(#27+'.1153'+Replicate('0',4)+FormataTexto(vlrAcrescimo,11,2,2)+Space(3)+'S}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var
  sRet : String;
begin
  sRet := fFuncEnviaComando( PChar(#27+'.04' + FormataTexto(numitem,3,0,2) + '}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.CancelaCupom( Supervisor:String ):String;
var
  sRet : String;
begin
  sRet := fFuncEnviaComando( PChar(#27+'.05}') );
  result := Status( 1,sRet );
  sleep(8000);
  if copy(result,1,1) = '0' then
    sRet := PulaLinha(7);
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;

  function AchaPagto( sForma:String;aFormas:Array of String ):String;
  var
    iPos, iTamanho : Integer;
  begin
    iPos := 0;
    for iTamanho:=0 to Length(aFormas)-1 do
      if UpperCase(aFormas[iTamanho]) = UpperCase(sForma) then
        iPos := iTamanho + 1;
    if Length(IntToStr(iPos)) < 2 then
      result := '0' + IntToStr(iPos)
    else
      result := IntToStr(iPos);
  end;

var
  sRet : String;
  aFormas : TaString;
  aAuxiliar : TaString;
  i : Integer;
  sLinha : String;
  nPos : Integer;
begin
  // Verifica o parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Le as condicoes de pagamento
  sRet := LeCondPag;
  sRet := Copy(sRet, 3, Length(sRet));
  MontaArray(sRet,aFormas);

  // Monta um array auxiliar com os parametros
  MontaArray( Pagamento,aAuxiliar );

  sLinha := '';

  i:=0;
  While i<Length(aAuxiliar) do
  begin
    if AchaPagto( aAuxiliar[i],aFormas ) <> '00' then
      Begin
        nPos := Pos('.',aAuxiliar[i+1]);
        If nPos > 0 then
          aAuxiliar[i+1] := copy(aAuxiliar[i+1],1,nPos+2);
        sLinha := sLinha + AchaPagto( aAuxiliar[i],aFormas ) + FormataTexto(aAuxiliar[i+1],12,2,2);
      End;
    Inc(i,2);
  end;

  sRet := fFuncEnviaComando( PChar(#27+'.10'+sLinha+'}') );
  result := Status( 1,sRet );

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.FechaCupom( Mensagem:String ):String;
var
  sRet : String;
  sLinha : String;
  sMsg,sMsgAux : String;
  iLinha : Integer;
  nX : Integer;
begin
	sMsgAux := Mensagem;
	sMsgAux := TrataTags( sMsgAux );

    // Laço para imprimir toda a mensagem
    sMsg := '';
    iLinha := 0;
    While ( Trim(sMsgAux)<>'' ) and ( iLinha < 8 ) do
      Begin
      sLinha := '';
      // Laço para pegar 40 caracter do Texto
      For nX:= 1 to 40 do
      Begin
        // Caso encontre um CHR(10) (Line Feed) imprime a linha
        If Copy(sMsgAux,nX,1) = #10 then
          Break;
        sLinha := sLinha + Copy(sMsgAux,nX,1);
      end;
      sLinha := Copy(sLinha+space(40),1,40);
      sMsg := sMsg + '0' + sLinha;
      sMsgAux := Copy(sMsgAux,nX+1,Length(sMsgAux));
      inc(iLinha);
    End;

    sRet := fFuncEnviaComando( PChar(#27+'.12'+sMsg+'}') );
    result := Status( 1,sRet );

    if copy(result,1,1) = '0' then
      sRet := PulaLinha(9);
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
var
  sRet : String;
begin
  sRet := fFuncEnviaComando( PChar(#27+'.1900}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
var
  sTexto, sRet, slinha : String;
  i, j, fim, indice : integer;
begin
    stexto:=texto;
    For i:=1 to Vias do
    begin
       If Length(texto)>0 then
       begin
           Repeat
                fim:=Length(texto);
                If Pos(#10,Copy(Texto, 1, 40))>0 then
                begin
                    indice:=Pos(#10,Copy(Texto, 1, 40));
                    slinha:= Pchar(Copy(Texto, 1, indice-1));
                    Texto:= Copy(Texto,indice+1,fim);
                end
                else
                begin
                    sLinha:=Pchar(Copy(Texto,1,40));
                    Texto:=Copy(Texto,41,fim);
                end;
              j:=1;
              Repeat
                  sRet := fFuncEnviaComando( PChar(#27+'.080D'+sLinha+'}') );
                  j:=j+1;
              Until (Status(1,sRet)='0') or (j<4);
              result := Status( 1,sRet );
           until  Length(texto)< 2;
       end;
      texto:=stexto;
    end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.FechaCupomNaoFiscal: String;
var
  sRet : String;
begin
  sRet := fFuncEnviaComando( PChar(#27+'.12}') );
  result := Status( 1,sRet );
  if copy(result,1,1) = '0' then
    sRet := PulaLinha(9);
end;
                                                                 
//----------------------------------------------------------------------------
function TImpFiscalSweda.ReImpCupomNaoFiscal( Texto:String ): String;
begin
  //para posterior implementacao
  result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String;
var
  sRet      : String;
  sDataIn,sDataFim: String;
  sFile     : String;
  fFile : TextFile;
Begin
  If (Tipo='I') OR (Pos('I', UpperCase(Tipo)) > 0)  then
     // Leitura da memoria para Impressora
     Begin
     if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
        Begin
        ReducInicio:=FormataTexto(ReducInicio,4,0,2);
        ReducFim   :=FormataTexto(ReducFim,4,0,2);
        sRet       := fFuncEnviaComando( PChar(#27+'.15'+ReducInicio+ReducFim+'}') );
        End
     Else
        Begin
        sDataIn    := FormataData(DataInicio,1);
        sDataFim   := FormataData(DataFim,1);
        sRet       := fFuncEnviaComando( PChar(#27+'.16'+sDataIn+sdataFim+'}') );
        End;
     result := Status( 1,sRet );
     if copy(result,1,1) = '0' then
        sRet := PulaLinha(7);
     End
  Else
     // Leitura da memoria para disco
     Begin
     result:= '0';
     sFile := ExtractFilePath(Application.ExeName) + 'SNSN.EXE';
     if not FileExists(sFile) then
        Begin
        ShowMessage('Arquivo não encontrado :'+sFile);
        Result:='1';
        Exit;
        End;

     if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
        Begin
        ReducInicio:=FormataTexto(ReducInicio,4,0,2);
        ReducFim   :=FormataTexto(ReducFim,4,0,2);
        sFile := sFile+' '+Copy(Porta,4,1)+' '+ReducInicio+' '+reducFim;

        ShowMessage('Coloque um disquete formatado no drive A:');
        // Deletar o Arquivo anterior
        If FileExists('A:\LEITURA.MFR') then
           Begin
           AssignFile( fFile, 'A:\LEITURA.MFR');
           Erase(fFile);
           End;
         //Fechando a porta de comunicação para que o programa SNSN possa utiliza-la
         CloseSweda( Porta );

         WinExec ( Pchar(sFile)  , SW_SHOWNORMAL);

         // Loop para aguardar a gravação do arquivo em disco.
         sFile := 'A:\LEITURA.MFR';
         While not FileExists(sFile) do
             sleep(100);

         sleep(1000);
         OpenSweda( Porta );
         End
     Else
        Begin
        sDataIn    := FormataData(DataInicio,1);
        sDataFim   := FormataData(DataFim,1);
        sFile:=sFile+' '+Copy(Porta,4,1)+' '+sDataIn+' '+sDataFim;
        ShowMessage('Coloque um disquete formatado no drive A:');
        // Deletar o Arquivo anterior
        If FileExists('A:\LEITURA.MFD') then
           Begin
           AssignFile( fFile, 'A:\LEITURA.MFD');
           Erase(fFile);
           End;
         //Fechando a porta de comunicação para que o programa SNSN possa utiliza-la
         CloseSweda( Porta );

         WinExec ( Pchar(sFile)  , SW_SHOWNORMAL);

         // Loop para aguardar a gravação do arquivo em disco.
         sFile := 'A:\LEITURA.MFD';
         While not FileExists(sFile) do
             sleep(100);

         sleep(1000);
         OpenSweda( Porta );
        End;
     End;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
var
  sRet : String;
  sAliq : String;
  aAliq : array of String;
  iTamanho : Integer;
  iPos : Integer;
  sCodTrib : String;
  sLegenda : String;
begin
  sRet := LeAliquotas;
  sRet := Copy(sRet, 3, Length(sRet));
  iTamanho := 0;
  While (Pos('|', sRet) > 0) do
  begin
    iTamanho := iTamanho + 1;
    SetLength( aAliq, iTamanho );
    iPos := Pos('|', sRet);
    sAliq := Copy(sRet, 1, iPos-1);
    aAliq[iTamanho-1] := sAliq ;
    sRet := Copy(sRet, iPos+1, Length(sRet));
  end;

  if Pos( Aliquota, sAliq ) > 0 then
  begin
    ShowMessage('A aliquota ' + Aliquota + ' ja está cadastrada.');
    result := '4|';
  end
  else
  begin
    sCodTrib := FormataTexto(IntToStr(Length(aAliq)+1),2,0,2);
    if Length(aAliq) > 9 then
      sLegenda := 'ICM' + IntToStr(Length(aAliq))
    else
      sLegenda := 'ICMS' + IntToStr(Length(aAliq));
    sRet := fFuncEnviaComando( PChar(#27+'.33T'+sCodTrib+sLegenda+FormataTexto(Aliquota,4,2,2)+'0000'+'}') );
    result := Status( 1,sRet );
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var
  sRet : String;
begin
  sRet := fFuncEnviaComando( PChar(#27+'.260'+Texto+'}') );

  result := Status( 1,sRet );
end;
//----------------------------------------------------------------------------

function TImpFiscalSweda.Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
//**********************************************************************************************************
function PegaRegistro( sCondicao:String ):String;
   Var
     sRet       : String;
     i          : Integer;
     aFormas    : array of String;
     sFormas    : String;
     sPos       : String;
     bIndiceTot : Boolean;
     iTamanho   : Integer;
     Totalizador: String;
   Begin
     sRet    :='789ABCD';
     sFormas :='';
     For i:= 1 to 7 do
     Begin
       // Lendo todos as descrições dos registradores.
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
     end;
     sFormas:=Copy(sFormas,31,length(sFormas));

     iTamanho:=1;
     SetLength( aFormas,0 );
     while Trim(sFormas)<>'' do
     Begin
       SetLength( aFormas, iTamanho );
       aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
       sFormas:=Copy(sFormas,16,Length(sFormas));
       Inc(iTamanho);
     end;
     sPos       := '00';
     Totalizador:= '00';
     bIndiceTot := False;
     For i:=0 to high(aFormas) do
     Begin
       // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
       // Pois a legenda somente podera ser do mesmo titulo.
       // Ex.
       // 01 &GAVETA                -> Titulos
       // 02    + Recebimento       -> Legendas
       // 03    - Sangria           -> Legendas
       // 04 &Sigaloja              -> Titulos
       // 05    + Entrada Diversas  -> Legendas
       // 06    - Saidas diversas   -> Legendas
       if (Copy(aFormas[i],1,1)='&') and (bIndiceTot = False) then
         Totalizador:= '00';

       //Pegar o codigo do titulo
       if Trim(UpperCase(aFormas[i])) = '&SIGALOJA' then
       Begin
         Totalizador:= FormataTexto(IntToStr(i + 1),2,0,2);
         bIndiceTot := True;
       End;

       //Pegar o codigo da Legenda
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(sCondicao)) ) and
         ( Totalizador <> '00' ) then
         sPos := FormataTexto(IntToStr(i + 1),2,0,2);
     end;
     Result:=sPos+Totalizador;
   End;
//**********************************************************************************************************
Var
  sRet:     String;
  i:        Integer;
  aFormas:  array of String;
  sFormas:  String;
  sPos:     String;
  sCondicao:String;
  sFormaSupr:String;
  aPgto:    TaString;
  iTamanho: Integer;
  nPos:     Integer;
  sVlrIndiv:String;
  aFormaSupr:TaString;

begin
    // Tipo = 1 - Verifica se tem troco disponivel
    // Tipo = 2 - Grava o valor informado no Suprimentos
    // Tipo = 3 - Sangra o valor informado
    PegaRegistro( FormaSupr );
    sRet:=' -';
    sCondicao:= Forma;
    Valor   :=FormataTexto(Valor,12,2,2);
    sRet    :='789ABCD';
    sFormas :='';
    SetLength( aFormas,0 );
    if Tipo = 1 then // Tipo = 1 - Verifica se tem troco disponivel
    Begin
        sRet    :='67';
        For i:= 1 to 2 do
        Begin
            // Lendo os totais das modalidades de pagamento
            sPos     := fFuncEnviaComando( PChar(#27+'.27'+Copy(sRet,i,1)+'}') );
            iTamanho := (Pos('}',sPos)-1) - 7;

            if i=2 then
                sFormas  := sFormas+Copy(sPos,8,48)
            else
                sFormas  := Trim(Copy(sPos,8,iTamanho));

            iTamanho:=Length(aFormas)+1;
            while Trim(sFormas)<>'' do
            Begin
                SetLength( aFormas, iTamanho );
                aFormas[iTamanho-1] := Copy(sFormas,5,12) ;
                sFormas:=Copy(sFormas,17,Length(sFormas));
                Inc(iTamanho);
            end;
        End;

        // Le as condicoes de pagamento
        sRet := LeCondPag;
        sRet := Copy(sRet, 3, Length(sRet));
        MontaArray(sRet,aPgto);
        for i:=0 to Length(aPgto) do
        Begin
            if UpperCase(Trim(aPgto[i]))='DINHEIRO' Then
            Begin
                sPos:=IntToStr(i);
                Break;
            end;
        End;
        if StrToFloat(aFormas[StrToInt(sPos)]) >= StrToFloat(Valor) then
            result := '8'
        else
            result := '9' ;
        Exit;
    End;

    If Tipo = 3 then
    Begin
        MontaArray( FormaSupr, aFormaSupr);
        i:=0;
        While i<Length(aFormaSupr) do
        Begin
            sFormaSupr := sFormaSupr+'0'+aFormaSupr[i];
            sVlrIndiv:= FormataTexto(aFormaSupr[i+1],12,2,3);
            sFormaSupr := sFormaSupr+ Space(28-Length(aFormaSupr[i])) + sVlrIndiv;
            Inc(i,2);
        End;
    End;

    sFormas :='DINHEIRO';
    If Trim(Copy(Forma,3,length(Forma)))<>''  then
        sFormas :=Trim(Copy(Forma,3,length(Forma)));

    if ( Tipo = 2 ) and ( Trim(Forma)='' )  then        // Tipo = 2 - Grava o valor informado no Suprimentos
        sCondicao:='FUNDO DE CAIXA';
    if ( Tipo = 3) and ( Trim(Forma)='' ) then          // Tipo = 3 - Sangra o valor informado
        sCondicao:='SANGRIA';

    If ( Trim(Copy(Forma,1,2))<>'') and ( Trim(Copy(Total,1,2))<>'') then
        sPos:=Copy(Forma,1,2)+Copy(Total,1,2)
    Else
        sPos:=PegaRegistro(sCondicao);

    sRet := fFuncEnviaComando( PChar(#27+'.19' + Copy(sPos,3,2)+ '      }') );
    Result := Status( 1,sRet );
    if copy(Result,1,1) = '0' then
    Begin
        Sleep(2000);
        sRet := fFuncEnviaComando( PChar(#27+'.07' + Copy(sPos,1,2)+Valor+'}') );
        Result := Status( 1,sRet );
        Sleep(500);
        if Tipo= 2 then
            Valor   := FloattoStrf(StrtoFloat(Valor)/100,ffFixed,18,2);
        sRet:=Pagamento(sFormas+'|'+Valor,'N','');
        Sleep(500);
        if copy(Result,1,1) = '0' then
        Begin
            sRet := fFuncEnviaComando( PChar(#27+'.12NN'+sFormaSupr+'}') );
            Sleep(2000);
            result := Status( 1,sRet );
        End;
    End;

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.Gaveta:String;
var
  sRet : String;
begin
  // Abre gaveta acoplada ao IFS7000I (não retorna erro !!!)
  fFuncEnviaComando( PChar(#27+'.21'+'}') );

  // Abre gaveta acoplada aos demais modelos...
  sRet := fFuncEnviaComando( PChar(#27+'.42'+'}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.Status( Tipo:Integer; Texto:String ) : String;
  // Parametros
  // 1- Verifica se o ultimo comando foi executado
begin

  case Tipo of
    1 : if (copy(Texto,2,1) = '-') and (copy(Texto,4,1) = '1') then
            result := '5'
        else if copy(Texto,2,1) = '-' then
              result := '1'
        else if copy(Texto,2,1) = '+' then
              result := '0';
    else
      result := '0';
    end;

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.PulaLinha( Numero:Integer ): String;
var
  sRet : String;
begin
  if Numero > 9 then
    Numero := 9;
  sRet := fFuncEnviaComando( PChar(#27+'.089'+IntToStr(Numero)+'}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.StatusImp( Tipo:Integer ):String;
var
  sRet : String;
  sDataMov : String;

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
//  9 - Verifica o Status do ECF
// 10 - Verifica se todos os itens foram impressos.
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
// 13 - Verifica se o ECF Arredonda o Valor do Item
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
// 16 - Verifica se exige o extenso do cheque
// 17 - Verifica Venda Bruta ( RICMs 01 - SC - Anexo 09 )
// 18 - Verifica Grande Total ( RICMs 01 - SC - Anexo 09 )

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
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)='0' then
    result := '0|' + copy(sRet,50,2) + ':' + copy(sRet,52,2) + ':00'
  else
    result := '1';
end
// Faz a leitura da Data da Impressora
else if Tipo = 2 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)='0' then
    result := '0|' + copy(sRet,44,2) + '/' + copy(sRet,46,2) + '/' + copy(sRet,48,2)
  else
    result := '1';
end
// Faz a checagem do papel
else if Tipo = 3 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)<>'0' then // se retornar erro verifica se falta papel
  begin
    if copy(sRet,6,1) = '5' then
      result := '2'
    else
      result := '0';
  end
  else
    result := '0';
end
// Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|ULTIMO'
// Cupom Fechado ?
else if Tipo = 5 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)= '0' then
    if (copy(sRet,7,1) <> 'C') and (Trim(copy(sRet,8,8))='VENDAS') then
      result := '7'
    else
      result := '0'
  else
    result := '1';
end
// Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
// ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
// Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)= '0' then
    if copy(sRet,18,1)='F' then
      result := '10'
    else
      result := '0'
  else
    result := '1';
end
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
  result := '0'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  result := '0'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
else if Tipo = 11 Then
  result := '1'
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
else if Tipo = 12 then
  result := '1'
// 13 - Verifica se o ECF Arredonda o Valor do Item
else if Tipo = 13 then
  result := '1'
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
else if Tipo = 14 then
begin
  // 0 - Fechada
  sRet := fFuncEnviaComando( PChar(#27+'.43}') );
  if Copy(sRet,6,1)='0' then
    Result := '0'
  else
    Result := '1';
end
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
  Result := '0'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
  Result := '0'
// 17 - Verifica Venda Bruta
else if Tipo = 17 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.271}') );
  if copy(Status(1,sRet),1,1)= '0' then
    result := '0|'+ Copy( sRet, 44, 12);
end
// 18 - Verifica Grande Total
else if Tipo = 18 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.271}') );
  if copy(Status(1,sRet),1,1)= '0' then
    result := '0|'+ Copy( sRet, 19, 17);
end
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

//----------------------------------------------------------------------------------------------------------------------------------

function TImpFiscalSweda.RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String) : String;
var iRet : Integer;
begin
  Result := RelatorioGerencial(cTextoImp , nVias, ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
var sret : string;
begin
  //Enviar um comando de fechamento de cupom não fiscal pois na versão 0.03, não aceita o comando de Relatorio Gerencial
  //com o cupom não fiscal aberto e impressão da uma leitura X, como exigência de fiscal.
  FechaCupomNaoFiscal;
  LeituraX;
  sRet := fFuncEnviaComando( PChar(#27+'.19}') );
  result := Status( 1, sRet );
  if copy(result,1,1) = '0' then
  begin
    sRet := TextoNaoFiscal( Texto, Vias);
    If sRet = '0'
    then Result:= FechaCupomNaoFiscal
    else Result := '1';
  end
  else
     result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.RecebNFis( Totalizador, Valor, Forma:String ): String;
var iRet : Integer;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpFiscalSweda.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalSweda.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;


//------------------------------------------------------------------------------
function TImpFiscalSweda.LeTotNFisc:String;
begin
        Result := '0|-99';
end;

//------------------------------------------------------------------------------
function TImpFiscalSweda.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalSweda.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalSweda.ImpTxtFis(Texto : String) : String;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalSweda.DownMF(sTipo, sInicio, sFinal : String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalSweda.RedZDado( MapaRes : String): String ;
Begin
  Result := '1';
End;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.RecebNFis( Totalizador, Valor, Forma:String ): String;
   function PegaRegistro( sCondicao:String):String;
   Var
     sRet : String;
     i : Integer;
     aFormas : array of String;
     sFormas : String;
     sPos : String;
     iTamanho : Integer;
     Totalizador: String;
     sPath      : String;
     fArquivo   : TIniFile;
     sReceb     : String;
   Begin
      sPath := ExtractFilePath(Application.ExeName);
      fArquivo := TIniFile.Create(sPath+'\SIGALOJA.INI');

      // Pegar no SIGALOJA.INI os titulos dos não-fiscais
      If fArquivo.ReadString('SWEDA', 'Tit. Recebimento', '' ) = '' then
        fArquivo.WriteString('SWEDA', 'Tit. Recebimento', 'SIGALOJA' );

      sReceb  := fArquivo.ReadString('SWEDA', 'Tit. Recebimento', '' );
      sReceb := '&' + sReceb;

      sRet    :='789ABCD';
      sFormas :='';
      For i:= 1 to 7 do
       Begin
       // Lendo todos as descrições dos registradores.
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
       end;
      sFormas:=Copy(sFormas,31,length(sFormas));

      iTamanho:=1;
      SetLength( aFormas,0 );
      while Trim(sFormas)<>'' do
          Begin
          SetLength( aFormas, iTamanho );
          aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
          sFormas:=Copy(sFormas,16,Length(sFormas));
          Inc(iTamanho);
          end;
      sPos       := '0';
      Totalizador:= '0';
      For i:=0 to high(aFormas) do
          Begin
          // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
          // Pois a legenda somente podera ser do mesmo titulo.
          // Ex.
          // 04 &SIGALOJA              -> Titulos
          // 05    + FUNDO DE CAIXA    -> Legendas
          // 06    - SANGRIA           -> Legendas
          if (Copy(aFormas[i],1,1)='&') and ( Totalizador = '0' )then
             Totalizador:= '0';

          //Pegar o codigo do titulo
          if Trim(UpperCase(aFormas[i])) = sReceb then
            Totalizador:= FormataTexto(IntToStr(i + 1),2,0,2);

           //Pegar o codigo da Legenda
          if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(sCondicao)) ) and
            ( Totalizador <> '0' ) then
            sPos := FormataTexto(IntToStr(i + 1),2,0,2);
          end;
      Result:=sPos+Totalizador;
   End;
//**********************************************************************************************************
Var
  sRet : String;
  i : Integer;
  aFormas : array of String;
  sFormas : String;
  sPos : String;
  iTamanho : Integer;
  sCondicao : String;
  aPgto : TaString;

begin
//Tem que escrever no SIGALOJA.INI o acumulador que vai ser utilizado para o recebimento. Ex.:
//[Recebimento Titulos]
//Totalizadores=RECEBIMENTO
//
//Esse totalizador deverá estar abaixo do título &SIGALOJA.
//EX.:
//
// 04 &SIGALOJA              -> Titulos
// 05    + FUNDO DE CAIXA    -> Legendas
// 06    + RECEBIMENTOS      -> Legendas


  // Tipo = 2 - Grava o valor informado no Suprimentos
    Valor   :=FormataTexto(Valor,12,2,2);
    sCondicao:= Forma;
    sRet    :='789ABCD';
    SetLength( aFormas,0 );

    sPos:=PegaRegistro(sCondicao);

    sRet := fFuncEnviaComando( PChar(#27+'.19' + Copy(sPos,3,2)+ '      }') );
    Result := Status( 1,sRet );
    if copy(Result,1,1) = '0' then
    Begin
       Sleep(2000);
       sRet := fFuncEnviaComando( PChar(#27+'.07' + Copy(sPos,1,2)+Valor+'}') );
       Result := Status( 1,sRet );
       Sleep(500);
       Valor   := FloattoStrf(StrtoFloat(Valor)/100,ffFixed,18,2);
       sRet:=Pagamento(Forma+'|'+Valor,'N','');
       if copy(Result,1,1) = '0' then
       Begin
          sRet := fFuncEnviaComando( PChar(#27+'.12NN}') );
          Sleep(2000);
          result := Status( 1,sRet );
       End;
    End;

end;

//------------------------------------------------------------------------------
// Aqui comecam as definicoes dos comandos para a Sweda 1.00
//------------------------------------------------------------------------------
function TImpFiscalSweda100.Abrir(sPorta : String; iHdlMain:Integer) : String;
Var
sPath : String;
sAdv  : String;
sAviso : String;
fArquivo : TIniFile;
begin
  // Tratamento realizado para mudar a captura do NC para o COO. Exibe mensagem
  // de aviso e armazena se quer deseja mostrar ou não no sigaloja.ini (/bin/remote)

  sPath := ExtractFilePath(Application.ExeName);
  fArquivo := TIniFile.Create(sPath+'\SIGALOJA.INI');
  If fArquivo.ReadString('SWEDA', 'AVISO', '' ) = '' then
    fArquivo.WriteString('SWEDA', 'AVISO', 'S' );
  sAviso := fArquivo.ReadString('SWEDA', 'AVISO', '' );

  If sAviso = 'S' then
  begin
    If MessageDlg('A partir da versão 0.2.85.29, para as impressoras Sweda,' +#10+
                'o número de controle dos cupons emitidos deixa de ser o Número do ' +#10+
                'Cupom (NC) e passa a ser o Contador de Ordem de Operação (COO).' +#10 + #10 +
                'POR FAVOR, ALTERE A SÉRIE NO CADASTRO DE ESTAÇÃO!.' +#10+
                'A NÃO ALTERAÇÃO PODE CAUSAR DUPLICIDADE NA GERAÇÃO' +#10+
                'DOS TÍTULO A RECEBER!'+ #10 + #10 +
                'Deseja continuar exibindo essa mensagem?',
     mtWarning	, [mbYes, mbNo], 0) = 7 then
    fArquivo.WriteString('SWEDA', 'AVISO','N');
  end;
  Result := OpenSweda( sPorta );
  // Carrega as aliquotas para ganhar performance
  if Copy(Result,1,1) = '0' then
    AlimentaProperties;
end;

//------------------------------------------------------------------------------
function TImpFiscalSweda100.LeituraX:String;
var
  sRet : String;
begin
  MsgLoja('Aguarde a impressão da Leitura X...');
  sRet := EnviaComando( PChar(#27+'.13N'+'}') );
  result := Status( 1, sRet );

  if copy(result,1,1) = '0' then
  begin
    Sleep(33000);
    //sRet := PulaLinha(7);
  end;
  MsgLoja;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.ReducaoZ ( MapaRes:String ): String;
          // FUNÇÕES AUXILIARES...

          // Formata as alíquotas...
          Function FormataAliquota(sTributo:String):String;
            // Procura a alíquota pelo índice. Exemplo: índice('TXX') devolve: TXX,XX...
            Function FindAliquota(sString:String):String;
            Var
              iPosicao:Integer;
            Begin
                // Algumas impressoras podem conter valores nulos ao inv‚s de T??...
                If sString=EmptyStr Then
                Begin
                   Result := '';
                   Exit;
                End;
                // Procura a alíquota no primeiro pacote...
                Result   := EnviaComando( PChar(#27+'.293}') );
                iPosicao := Pos(sString,Result);
                If (iPosicao>0) And (Trim(Copy(Result,iPosicao+3,4))<>EmptyStr) Then
                      Result := Copy(sString,1,1)+Copy(Result,iPosicao+3,2)+','+Copy(Result,iPosicao+5,2)
                Else
                  Begin
                    // Caso não encontre no primeiro pacote. Procura a alíquota no segundo pacote...
                    Result   := EnviaComando( PChar(#27+'.294}') );
                    iPosicao := Pos(sString,Result);
                    If (iPosicao>0) And (Trim(Copy(Result,iPosicao+3,4))<>EmptyStr) Then
                      Result := Copy(sString,1,1)+Copy(Result,iPosicao+3,2)+','+Copy(Result,iPosicao+5,2)
                    Else
                      Begin
                        // Caso não encontre no segundo pacote. Procura a alíquota no último pacote...
                        Result := EnviaComando( PChar(#27+'.295}') );
                        iPosicao := Pos(sString,Result);
                        If (iPosicao>0) And (Trim(Copy(Result,iPosicao+3,4))<>EmptyStr) Then
                          Result := Copy(sString,1,1)+Copy(Result,iPosicao+3,2)+','+Copy(Result,iPosicao+5,2)
                        Else
                          Result := '';
                      End;
                  End;
            End;
          Var
            sValor:String;
            nValor:Real;
          Begin
            If (Copy(sTributo,1,3)=EmptyStr) Then
            Begin
               Result := '';
               Exit;
            End;
            Result := FindAliquota( Copy(sTributo,1,3) );
            If Result<>EmptyStr Then
            Begin
               //  Formata o campo: Aliquota '  ' Valor '  ' Imposto Debitado
               sValor := FloatToStrf(StrToFloat(Copy(sTributo, 4, 14))/100, ffFixed, 14, 2);
               sValor := FormataTexto(sValor, 14, 2, 1, '.');
               nValor := StrToFloat(sValor)*StrToFloat(Copy(StrTran(Result,',','.'),2,5)); // ==>> 162,75
               Result := Result + ' ' + sValor + ' ' + FormataTexto(FloatToStr(Int(nValor)/100), 14, 2, 1, '.');
            End;
          End;

          // Função que emite de fato a redução Z...
          Function EmiteReducaoZ(sData:String; var sRetorno:String):Boolean;
          Var
            sRet:String;
            iContador: Integer;
          Begin
            // Delay de aproximadamente 2 minutos para tentar emitir a Redução Z...
            For iContador:=0 To 23 Do
            Begin
              sRetorno := EnviaComando( PChar(#27+'.14N' + sData + '}') );   // Redução Z = 14 .. Leitura X = 13
              sRet     := Status( 1, sRetorno );
              if Copy(sRet,1,1) = '0' then
              begin
                PulaLinha(7);
                Break;
              end;
              Sleep(5000);
            End;  // For
            Result := (sRet='0');
          End;

var
  dDataHoje: TDateTime;
  sRet, sDataHoje, sRet271, sRet273, sRet27G : String;
  iContador: Integer;
  aRetorno: array of String;
begin
  Result:='1';
  If Trim(MapaRes)='S' then
  Begin
      // COMANDO G...
      sRet27G := EnviaComando( PChar(#27+'.27G}') );
      if Copy(Status(1,sRet27G),1,1)<>'0' then
        Begin
          result := '1';
          Exit;
        End;

      // COMANDO 1...
      sRet271 := EnviaComando( PChar(#27+'.271}') );
      if Copy(Status(1,sRet271),1,1)<>'0' then
        Begin
          result := '1';
          Exit;
        End;

      // COMANDO 3...
      sRet273 := EnviaComando( PChar(#27+'.273}') );
      if Copy(Status(1,sRet273),1,1)<>'0' then
        Begin
          result := '1';
          Exit;
        End;

      // Prepara o array, aRetorno, com os dados do ECF...
      SetLength(aRetorno,21);
      aRetorno[ 0]:= Copy(sRet271, 8, 2) + '/' + Copy(sRet271,10, 2) + '/' + Copy(sRet271,12, 2);                       // Data Fiscal (DDMMAA)
      aRetorno[ 1]:= Copy(sRet271,4, 3);                                                         // Nr. ECF
      aRetorno[ 2]:= Copy(Copy(sRet273,13, 9)+Space(13), 0, 13);                                                        // Identificação do Equipamento	(9 caracteres)
      aRetorno[ 4]:= FloatToStrf(StrToFloat(Copy(sRet271,20,17))/100, ffFixed, 18, 2);                                  // Grande Total (17 dígitos)
      aRetorno[ 4]:= FormataTexto(aRetorno[4], 19, 2, 1, '.');
      aRetorno[ 5]:= FormataTexto(Copy(sRet27G,8, 4), 6, 0, 2);                                                        // COO inicial	(4 dígitos)
      aRetorno[ 6]:= FormataTexto(Copy(sRet271,14, 4), 6, 0, 2);                                                        // --Numero documento Final--  COO
      aRetorno[ 7]:= FloatToStrf((StrToFloat(Copy(sRet271,61,12))+StrToFloat(Copy(sRet271,77,12)))/100, ffFixed, 18, 2);// Total de Vendas canceladas no dia	  (12 dígitos)
      aRetorno[ 7]:= FormataTexto(aRetorno[7], 15, 2, 1, '.');
      aRetorno[ 8]:= FloatToStrf(StrToFloat(Copy(sRet271,105,12))/100, ffFixed, 18, 2);                                 // Total Líquido do Dia	  (12 dígitos)
      aRetorno[ 8]:= FormataTexto(aRetorno[8], 15, 2, 1, '.');
      aRetorno[ 9]:= FloatToStrf(StrToFloat(Copy(sRet271,93,12))/100, ffFixed, 18, 2);                                  // Total de Descontos no Dia	  (12 dígitos)
      aRetorno[ 9]:= FormataTexto(aRetorno[9], 11, 2, 1, '.');
      aRetorno[10]:= FloatToStrf(StrToFloat(Copy(sRet273,46,12))/100, ffFixed, 18, 2);                                  // Total Substituição	(12 dígitos)
      aRetorno[10]:= FormataTexto(aRetorno[10], 11, 2, 1, '.');
      aRetorno[11]:= FloatToStrf(StrToFloat(Copy(sRet273,22,12))/100, ffFixed, 18, 2);                                  // Total Isento	(12 dígitos)
      aRetorno[11]:= FormataTexto(aRetorno[11], 11, 2, 1, '.');
      aRetorno[12]:= FloatToStrf(StrToFloat(Copy(sRet273,34,12))/100, ffFixed, 18, 2);                                  // Total Não Tributável	(12 dígitos)
      aRetorno[12]:= FormataTexto(aRetorno[12], 11, 2, 1, '.');
      aRetorno[13]:= aRetorno[0];                                                                                       // --data da reducao z--
      aRetorno[15]:= FormataTexto('0',16, 0, 2);                                                                        // --outros recebimentos--
      aRetorno[16]:= FormataTexto('0',14, 2, 1)+' '+FormataTexto('0',14, 2, 1);                                         // Total ISS
      aRetorno[17]:= Copy(sRet27G,17, 3);                                                                               // CRO - Contador de Reinício de Operação
      aRetorno[18]:= FormataTexto( '0', 11, 2, 1 );                 // desconto de ISS
      aRetorno[19]:= FormataTexto( '0', 11, 2, 1 );                 // cancelamento de ISS
      aRetorno[20]:= '00';                                         // QTD DE Aliquotas

      // COMANDO 273, 274 e 275 para pegar os totais das alíquotas cadastradas...
      If Copy(sRet273, 94, 3) <> EmptyStr Then
        Begin
          aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);                                       // QTD DE Aliquotas programadas no ECF
          SetLength( aRetorno, Length(aRetorno)+1 );
          aRetorno[High(aRetorno)] := FormataAliquota( Copy(sRet273,94,15) );

          Result := EnviaComando( PChar(#27+'.274}') );
          if Copy(Status(1,Result),1,1)='0' Then
          Begin
             Result := Copy(Result,8,105) + Copy(EnviaComando(PChar(#27+'.275}')),8,105);
             For iContador:=0 To 13 Do
             Begin
               If Trim(Copy(Result,1,3)) <> EmptyStr Then
               Begin
                     sRet     := FormataAliquota( Trim(Copy(Result,1,15)) );
                     If sRet<>EmptyStr Then
                     Begin
                        If Copy(sRet,1,1)='S' then
                            aRetorno[16] := FormataTexto(FloatToStr(StrToFloat(copy(aRetorno[16],1,14))+StrToFloat(copy(sRet,8,14))),14,2,1)+' '+
                                            FormataTexto(FloatToStr(StrToFloat(copy(aRetorno[16],16,14))+StrToFloat(copy(sRet,23,14))),14,2,1)
                        else
                        begin
                           aRetorno[20] := FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);
                           SetLength( aRetorno, Length(aRetorno)+1 );
                           aRetorno[High(aRetorno)] := sRet;
                        end;
                     End;
               End;
               Result  := Copy(Result,16,Length(Result));
             End;
          End;
        End;
  End;  // Fim do Mapa Resumo...

  dDataHoje:= Now;
  sDataHoje := FormataData( dDataHoje, 1 );
  If EmiteReducaoZ(sDataHoje,sRet) then
    Result:='0';

  If Trim(MapaRes)='S' then
  Begin
    // Repete o COMANDO 1... após a emissão da Redução Z...
    // Delay de aproximadamente 2 minutos para pegar o COO e o contador de Reduções...
    For iContador:=0 To 23 Do
    Begin
      sRet271 := EnviaComando( PChar(#27+'.271}') );
      If Copy(Status(1,sRet271),1,1)='0' Then
        Break;
      Sleep(5000);
    End;
    aRetorno[ 3] := Copy(sRet271,41, 4);                                                         // Número de Reduçöes (4 dígitos)
    aRetorno[14] := FormataTexto(Copy(sRet271,14, 4), 6, 0, 2);                                  // Sequencial de Operação  (4 dígitos)
    Result := '0|';
    For iContador:= 0 to High(aRetorno) do
      Result := Result + aRetorno[iContador]+'|';
  End;


end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
var
  sRet,sRet1,sRet2,sRet3 : String;
  sRetorno : String;
  sLinha : String;
  sAux : String;
  aAliq : TaString;
  i : Integer;
  iPos : Integer;
  iTamanho : Integer;
  sAliq : String;
  sSituacao : String;
  nPos : Integer;
  sDescrAdic : String;
  sUnid : String;
begin
  // Verifica a casa decimal dos parâmetros
  qtde := Trim(StrTran(qtde,',','.'));
  vlrUnit := Trim(StrTran(vlrUnit,',','.'));
  vlrdesconto := Trim(StrTran(vlrdesconto,',','.'));
  vlTotIt := Trim(StrTran(vlTotIt,',','.'));

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    if StrToFloat(vlrdesconto) <> 0 then
    begin
      sRet := fFuncEnviaComando( PChar(#27+'.02'+Space(10)+FormataTexto(vlrdesconto,12,2,2) + '}') );
      result := Status( 1,sRet );
    end
    else
      result := '0';
    exit;
  end;

  // Verifica a casa decimal dos parâmetros
  sSituacao := copy(aliquota,1,1);
  aliquota := Trim(StrTran(copy(aliquota,2,5),',','.'));

  // Checa as aliquotas
//  sRet1 := fFuncEnviaComando( PChar(#27+'.293}') );
//  sRet2 := fFuncEnviaComando( PChar(#27+'.294}') );
//  sRet3 := fFuncEnviaComando( PChar(#27+'.295}') );
  sRet1 := sComando293;
  sRet2 := sComando294;
  sRet3 := sComando295;
  if (copy(Status(1,sRet1),1,1)<>'0') or (copy(Status(1,sRet2),1,1)<>'0') or (copy(Status(1,sRet3),1,1)<>'0') then
  begin
    result := '1|';
    exit;
  end;

  sRetorno := copy(sRet1,49,28) + copy(sRet2,8,49) + copy(sRet3,8,28);
  sLinha := '';
  i := 0;
  while (i<=15) and (Trim(copy(sRetorno,(7*i)+1,7))<>'') do
  begin
    sAux := FloatToStrf(StrToFloat(copy(sRetorno,(7*i)+4,4))/100,ffFixed,18,2);
    if (FormataTexto(sAux,4,2,2) <> '0000') then
        sLinha := sLinha + copy(sRetorno,(7*i)+1,1) + sAux + '|';
    i := i + 1;
  end;

  sRet := sLinha;

  // Verifica se a aliquota é ISENTA, c/SUBSTITUICAO TRIBUTARIA, NAO TRIBUTAVEL, ISS ou ICMS
  If Pos(sSituacao,'T') > 0  then
  begin
    MontaArray( sRet, aAliq );
    iPos := 0;
      for iTamanho:=0 to Length(aAliq)-1 do
        if aAliq[iTamanho] = sSituacao+aliquota then
        Begin
          iPos := iTamanho + 1;
          break;
        end;
        if (iPos = 0) and (Pos(sSituacao,'TS') > 0) then
        begin
          ShowMessage('Aliquota não cadastrada.');
          result := '1|';
          exit;
        end;

      sAliq := copy(sRetorno,((iPos-1)*7)+1,3);
  end
  else If Pos(sSituacao,'S') > 0  then
  begin
    MontaArray( sRet, aAliq );
    iPos := 0;
      for iTamanho:=0 to Length(aAliq)-1 do
        if aAliq[iTamanho] = sSituacao+aliquota then
        Begin
          iPos := iTamanho + 1;
          break;
        end;
        if (iPos = 0) and (Pos(sSituacao,'TS') > 0) then
        begin
          ShowMessage('Aliquota não cadastrada.');
          result := '1|';
          exit;
        end;

      sAliq := copy(sRetorno,((iPos-1)*7)+1,3);
  end
  else
      sAliq := sSituacao + '  ';

  nPos := Pos('.',vlTotIt);
  VlTotIt := FloatToStr( StrToFloat( FormataTexto(vlrUnit,9,2,1) ) * StrToFloat( qtde ) );
  VlTotIt := FormataTexto(Copy(vlTotIt,1,nPos+2),12,2,2);

  if copy(vlrUnit,length(vlrUnit)-3,1) = '.' then
  begin
    VlrUnit	:= FormataTexto(vlrUnit,9,3,2);
    Descricao:= '~'+descricao;
  end
  else
  begin
    VlrUnit	:= FormataTexto(vlrUnit,9,2,2);
  end;

  sDescrAdic := '';
  Descricao := Trim(Descricao);
  If Length(Descricao) > 23 then
    sDescrAdic := copy(Descricao,24,Length(Descricao));

  If UpperCase( Trim( UnidMed ) ) = 'L' Then
    sUnid := '@'
  Else
  Begin
    If ( UpperCase( Trim( UnidMed ) ) = 'MT' ) Or (UpperCase( Trim( UnidMed ) ) = 'M') Then
      sUnid := ')'
    Else
    Begin
      If UpperCase( Trim( UnidMed ) ) = 'KG' Then
        sUnid := '!'
      Else
        sUnid := '^';
    End;
  End;

  // Valida o tamanho da descricao. Se for maior que 24 posições envia a descricao auxiliar.
  If Length(sDescrAdic) > 0 then
    sRet := EnviaComando( PChar(#27+'.01'+ Copy(codigo+Space(13),1,13)+
                                              FormataTexto(qtde,7,3,2) +
                                              vlrUnit +
                                              vlTotIt +
                                              sUnid + Copy(descricao+Space(23),1,23) +
                                              Copy( sAliq + Space( 3 ), 1, 3 )   +
                                              Copy(sDescrAdic+Space(40),1,40) +
                                              '}') )
  Else
    sRet := EnviaComando( PChar(#27+'.01'+ Copy(codigo+Space(13),1,13)+
                                              FormataTexto(qtde,7,3,2) +
                                              vlrUnit +
                                              vlTotIt +
                                              sUnid + Copy(descricao+Space(23),1,23) +
                                              sAliq + '}') );

  if copy( Status(1,sRet),1,1 ) = '0' then
    if StrToFloat(vlrdesconto) <> 0 then
      sRet := fFuncEnviaComando( PChar(#27+'.02'+Space(10)+FormataTexto(vlrdesconto,12,2,2) + '}') );

  result := Status( 1,sRet );

end;

//------------------------------------------------------------------------------
function TImpFiscalSweda100.AbreECF:String;
begin
  result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.FechaECF : String;
var
  sRet : String;
  dDataHoje : TDateTime;
  sDataHoje : String;
begin
  MsgLoja('Aguarde a impressão da Redução Z...');

  dDataHoje:= Now;
  sDataHoje := FormataData( dDataHoje, 1 );
  sRet := fFuncEnviaComando( PChar(#27+'.14N' + sDataHoje + '}') );
  result := Status( 1, sRet );
  if copy(result,1,1) = '0' then
  begin
    Sleep(33000);
    sRet := PulaLinha(7);
  end;
  MsgLoja;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.LeAliquotas:String;
begin
  result := '0|'+Aliquotas;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.LeAliquotasISS:String;
begin
  result := '0|'+ISS;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.LeCondPag:String;
begin
   result := '0|'+FormasPgto;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.PegaCupom(Cancelamento:String):String;
var
  sRet, sRet28 : String;
begin
  If Cancelamento = 'T' then
  Begin
        sRet28 := EnviaComando( PChar(#27+'.28}') );
        sRet28 := Copy(sRet28,11,8);
        If sRet28 <> ' VENDAS ' then
        Begin
            Result := '0|0000  ';
            Exit;
        End;
  End;

  sRet := EnviaComando( PChar(#27+'.271}') );
  if Copy(sRet,2,1)<>'+' then
    sRet := EnviaComando( PChar(#27+'.271}') );
  if Copy(sRet,2,1)<>'+' then
    ShowMessage('Erro ao Ler o Numero do Cupom no ECF.');
  if Copy(Status(1,sRet),1,1)='0' then
    result := '0|' + copy(sRet,14,4) +'  '
  else
    result := '1';

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.FechaCupom( Mensagem:String ):String;
var
  sRet  : String;
  sLinha: string;
  sCmd,sMsg: string;
  iLinha,nX : Integer;
begin
	sMsg := Mensagem;
	sMsg := TrataTags( sMsg );
    // Laço para imprimir toda a mensagem
    iLinha := 0;
    sCmd:='';
    while ( Trim(sMsg)<>'' ) and ( iLinha<9 ) do
      Begin
      sLinha:='';
      // Laço para pegar 40 caracter do Texto
      for nX:= 1 to 40 do
         Begin
         // Caso encontre um CHR(Line Feed) imprime a linha
         If Copy(sMsg,nX,1)= #10 then
            Break;

         sLinha:=sLinha+Copy(sMsg,nX,1);
         end;
      sLinha:=Copy(sLinha+space(40),1,40);
      sCmd:=sCmd+'0'+sLinha;
      sMsg:=Copy(sMsg,nX+1,Length(sMsg));

      inc(iLinha);
      End;
  sRet := EnviaComando( PChar(#27+'.12SN'+sCmd+'}') );
  result := Status( 1,sRet );
  // Tempo necessário para aguardar a Finalização do Cupom
  Sleep(4000);
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String;
var
  sRet : String;
begin
  vlrDesconto := StrTran(vlrDesconto,',','.');
  sRet := fFuncEnviaComando( PChar(#27+'.03'+Space(10)+FormataTexto(vlrDesconto,12,2,2)+'S}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.AcrescimoTotal( vlrAcrescimo:String ): String;
var
  sRet : String;
begin
  vlrAcrescimo := StrTran(vlrAcrescimo,',','.');
  sRet := fFuncEnviaComando( PChar(#27+'.1151'+Replicate('0',4)+FormataTexto(vlrAcrescimo,11,2,2)+'S}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
var
  sRet : String;
  sAliq : String;
  aAliq : array of String;
  iTamanho : Integer;
  iPos : Integer;
  sCodTrib : String;
begin
  sRet := LeAliquotas;
  sRet := Copy(sRet, 3, Length(sRet));
  iTamanho := 0;
  While (Pos('|', sRet) > 0) do
  begin
    iTamanho := iTamanho + 1;
    SetLength( aAliq, iTamanho );
    iPos := Pos('|', sRet);
    sAliq := Copy(sRet, 1, iPos-1);
    aAliq[iTamanho-1] := sAliq ;
    sRet := Copy(sRet, iPos+1, Length(sRet));
  end;

  if Pos( Aliquota, sAliq ) > 0 then
  begin
    ShowMessage('A aliquota ' + Aliquota + ' ja está cadastrada.');
    result := '4|';
  end
  else
  begin
    sCodTrib := FormataTexto(IntToStr(Length(aAliq)+1),2,0,2);
    //Verifica se é ICMS (Tipo 1) ou ISS (Tipo 2)
    If tipo = 1 Then
      sRet := fFuncEnviaComando( PChar(#27+'.33T'+sCodTrib+FormataTexto(Aliquota,4,2,2)+'}') )
    Else
      sRet := fFuncEnviaComando( PChar(#27+'.33S'+sCodTrib+FormataTexto(Aliquota,4,2,2)+'}') );
    result := Status( 1,sRet );
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
var
  sRet : String;
  sNumAnt : String;
  i : Integer;
  aFormas : array of String;
  sFormas : String;
  sPos : String;
  sPosTot : String;
  iPos : Integer;
  iTamanho : Integer;
  bTotalizadorIsNum : Boolean;
  sTotPad : String;
  sTotFormaPagto : String;
  sBuffer : String;
begin
  If Trim(Totalizador)='' then
     Totalizador:='SIGALOJA';

  // Pegando o numero do ultimo cupom impresso
  sNumAnt := fFuncEnviaComando( PChar(#27+'.271}') );

  if Copy( Status(1,sNumAnt),1,1 ) = '0' then
    sNumAnt := copy(sNumAnt,14,4)
  else
  begin
    result := '1|';
    exit;
  end;
  // Monta o array aFormas com as condicoes de pagamento do cupom fiscal
  sRet := LeCondPag;
  sRet := Copy(sRet, 3, Length(sRet));
  iTamanho := 0;
  While (Pos('|', sRet) > 0) do
  begin
    iTamanho := iTamanho + 1;
    SetLength( aFormas, iTamanho );
    iPos := Pos('|', sRet);
    sFormas := Copy(sRet, 1, iPos-1);
    aFormas[iTamanho-1] := sFormas ;
    sRet := Copy(sRet, iPos+1, Length(sRet));
  end;
  // Verificando qual o codigo da condicao de pagamento utilizado
  sPos := '0';
  For i:=0 to Length(aFormas)-1 do
    if UpperCase(Trim(aFormas[i])) = UpperCase(Trim(Condicao)) then
      sPos := IntToStr(i + 1);
  if length(sPos) < 2 then
    sPos := '0' + sPos;
  if sPos = '00' then
  begin
    ShowMessage('A finalizadora '+Condicao+' não foi cadastrada no ECF.');
    result := '1|';
    exit;
  end;
  // A diferença entre a 1.0 e a 1.A é que a 1.A para fazer cupom vinculado,
  // a finalizadora deve ter a FLAG de VINCULAÇÃO como 'S'.
  if Copy(sVinculado, StrToInt(sPos), 1) = 'N' then
  begin
    ShowMessage('A finalizadora '+Condicao+' não foi cadastrada como VINCULADA no ECF.');
    result := '1|';
    exit;
  end;

  // Abrindo cupom nao fiscal vinculado '00'
  sRet := fFuncEnviaComando( PChar(#27+'.1900'+sNumAnt+sPos+'}') );
  result := Status( 1,sRet );

  if copy(result,1,1) = '1' then  // Impressao do Cupom nao fiscal nao vinculado
    Begin
    sTotFormaPagto := sPos;
    sRet:=' -';
    Valor   :=FormataTexto(Valor,12,2,2);
    sRet    :='789ABCD';
    sFormas :='';
    For i:= 1 to 7 do
       Begin
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
       end;
    sFormas:=Copy(sFormas,31,length(sFormas));

    iTamanho:=1;
    SetLength( aFormas,0 );
    while Trim(sFormas)<>'' do
       Begin
        SetLength( aFormas, iTamanho );
        aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
        sFormas:=Copy(sFormas,16,Length(sFormas));
        Inc(iTamanho);
        end;

    Try
      StrToInt( Totalizador );
      bTotalizadorIsNum := True;
    Except
      bTotalizadorIsNum := False;
    End;

    sPos       := '0';
    sPosTot    := '0';
    For i:=0 to high(aFormas) do
    Begin
        // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
        // Pois a legenda somente podera ser do mesmo titulo.
        // Ex.
        // 01 &GAVETA                -> Titulos
        // 02    + Recebimento       -> Legendas
        // 03    - Sangria           -> Legendas
        // 04 &Sigaloja              -> Titulos
        // 05    + Entrada Diversas  -> Legendas
        // 06    - Saidas diversas   -> Legendas

       If bTotalizadorIsNum then
          sPosTot  := Totalizador
       Else
         //Pegar o codigo do titulo
         if Trim(UpperCase(aFormas[i])) = '&'+Trim(UpperCase(Totalizador)) then
            sPosTot:= FormataTexto(IntToStr(i + 1),2,0,2);

       //Pegar o codigo da Legenda
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(Condicao)) ) and
          ( sPosTot <> '0' ) then
          sPos := FormataTexto(IntToStr(i + 1),2,0,2);

       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = 'FUNDO DE CAIXA') then
          sTotPad := FormataTexto(IntToStr(i + 1),2,0,2);
       end;

    // Se não encontrar a forma solicitada, cria o cupom como 'FUNDO DE CAIXA'
    If sPos = '0' then
      sPos := sTotPad;

    // Abre o cupom não vinculado
    sBuffer := Space(128);
    sRet := EnviaComandoEspera( PChar(#27+'.19' + sPosTot + '      }'), sBuffer );
    If sRet = '0' then
    begin
      // Faz o recebimento não fiscal
      sBuffer := Space(128);
      sRet := EnviaComandoEspera( PChar(#27+'.07' + sPos + Valor + '}'), sBuffer, 3 );
      If sRet = '0' then
      begin
        // Totaliza o cupom
        sBuffer := Space(128);
        sRet := EnviaComandoEspera( PChar(#27+'.10'+sTotFormaPagto+Valor+'}'), sBuffer, 3 );
        If sRet = '0' then
        begin
          // Fecha o cupom indicando que haverá um vinculado
          sBuffer := Space(128);
          sRet := EnviaComandoEspera( PChar(#27+'.12SN}'), sBuffer, 3 );
          If sRet = '0' then
          begin
            sBuffer := Space(128);
            sRet := EnviaComandoEspera( PChar(#27+'.271}'), sBuffer, 10 );
            If sRet = '0' then
            begin
              sNumAnt := copy( sBuffer, 14, 4 );
              sBuffer := Space(128);
              sRet := EnviaComandoEspera( PChar(#27+'.1900'+sNumAnt+sTotFormaPagto+'}'), sBuffer, 10 );
            end;
          end;
        end;
      end;
    end;

    result := Status( 1, sBuffer );
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
var
  sRet, stexto : String;
  fim, indice, j, i : integer;
  slinha: PChar;
begin
    stexto:=texto;

    For i:=1 to Vias do
    begin
       If Length(texto)>0 then
       begin
           Repeat
                fim:=Length(texto);
                If Pos(#10,Copy(Texto, 1, 40))>0 then
                begin
                    indice:=Pos(#10,Copy(Texto, 1, 40));
                    slinha:= Pchar(Copy(Texto, 1, indice-1));
                    Texto:= Copy(Texto,indice+1,fim);
                end
                else
                begin
                    sLinha:=Pchar(Copy(Texto,1,40));
                    Texto:=Copy(Texto,41,fim);
                end;
              j:=1;
              Repeat
                  sRet := fFuncEnviaComando( PChar(#27+'.080'+sLinha+'}') );
                  j:=j+1;
              Until (Status(1,sRet)='0') or (j<4);
           until  Length(texto)< 2;
       end;
       if i<>Vias then
       begin
             j:=1;
             Repeat
                sRet := fFuncEnviaComando( PChar(#27+'.089'+'6}') );
                j:=j+1;
             Until (Status(1,sRet)='0') or (j<4);
       end;
      texto:=stexto;
    end;
    result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.FechaCupomNaoFiscal: String;
var
  sRet : String;
  tempo, tempoini: TDateTime;

begin
  result:='1';
  sRet := fFuncEnviaComando( PChar(#27+'.12}') );
  if Status( 1,sRet )='0' then
  begin
      timeseparator:=':';
      tempoini:=time;
      tempo:=tempoini;
      While (tempo < (tempoini+StrToTime('00:02:00'))) and (Copy(sRet,10,1)<>'C') do
      begin
          sRet := fFuncEnviaComando( PChar(#27+'.28}'));
          tempo:=time;
      end;
      If Copy(sRet,10,1)='C' then
        Result:='0'
      Else
        Result:='1';
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var
  sRet : String;
  iVz, i:Integer;

begin
  IF Vezes=0 then
     Vezes:=1;

  iVZ:=1;
  WHILE iVz<=Vezes do
     begin
        ShowMessage('Posicione o Documento para a '+IntToStr(iVz)+'a. Autenticação.');
        if iVz=1 then
        begin
           sRet := fFuncEnviaComando( PChar(#27+'.200N'+Replicate('0',14)+'10N'+'}') );
           i:=1;
           While ((copy(sRet,2,1)= '-') and (i<20)) do
           Begin
                Sleep(500);
                sRet := fFuncEnviaComando( PChar(#27+'.200N'+Replicate('0',14)+'10N'+'}') );
                i:=i+1;
           End;
        end
        else
          sRet := fFuncEnviaComando( PChar(#27+'.26}') );

        if copy(sRet,2,1) = '-' then
           Break
        else
           Inc(iVz);
     end;
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.PulaLinha( Numero:Integer ): String;
var
  sRet : String;
begin
  if Numero > 9 then
    Numero := 9;
  sRet := fFuncEnviaComando( PChar(#27+'.089'+IntToStr(Numero)+'}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda100.StatusImp( Tipo:Integer ):String;
var
  sRet : String;
  sDataMov : String;
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
//  9 - Verifica o Status do ECF
// 10 - Verifica se todos os itens foram impressos.
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
// 13 - Verifica se o ECF Arredonda o Valor do Item
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
// 16 - Verifica se exige o extenso do cheque
// 18 - Verifica Grande Total

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
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)='0' then
    result := '0|' + copy(sRet,53,2) + ':' + copy(sRet,55,2) + ':00'
  else
    result := '1';
end
// Faz a leitura da Data da Impressora
else if Tipo = 2 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)='0' then
    result := '0|' + copy(sRet,47,2) + '/' + copy(sRet,49,2) + '/' + copy(sRet,51,2)
  else
    result := '1';
end
// Faz a checagem do papel
else if Tipo = 3 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)<> '0' then // se retornar erro verifica se falta papel
  begin
    if copy(sRet,6,1) = '5' then
      result := '2'
    else
      result := '0';
  end
  else
    result := '0';
end
// Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
// Cupom Fechado ?
else if Tipo = 5 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)= '0' then
    if (copy(sRet,10,1) <> 'C') and (Trim(copy(sRet,11,8))='VENDAS') then
      result := '7'
    else
      result := '0'
  else
    result := '1';
end
// Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
// ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
// Verica se o dia anterior foi fechado
else if Tipo = 8 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)= '0' then
    if copy(sRet,21,1)='F' then
      result := '10'
    else
      result := '0'
  else
    result := '1';
end
//9 - Verifica o Status do ECF
else if Tipo = 9 then
  result := '0'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 then
  result := '0'
//11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
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
begin
  // 0 - Fechada
  sRet := fFuncEnviaComando( PChar(#27+'.43}') );
  if Copy(sRet,6,1)='0' then
    Result := '0'
  else
    Result := '1';
end
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
  Result := '0'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
  Result := '1'
else if Tipo = 17 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.27}') );
  if copy(Status(1,sRet),1,1)= '0' then
    result := '0|'+ Copy( sRet, 45, 12);
end
// 18 - Verifica Grande Total
else if Tipo = 18 then
begin
  sRet := fFuncEnviaComando( PChar(#27+'.27}') );
  if copy(Status(1,sRet),1,1)= '0' then
    result := '0|'+ Copy( sRet, 20, 17);
end
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

//----------------------------------------------------------------------------------------------------------------------------------
function TImpFiscalSweda100.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
var sRet, stexto, slinha: String;
    i, j, fim, indice: integer;
begin

  sRet := EnviaComando( PChar(#27+'.13S'+'}') );

  If Status( 1, sRet )='0' then
  begin
    stexto:=texto;
    For i:=1 to Vias do
    begin
       If Length(texto)>0 then
       begin
           Repeat
                fim:=Length(texto);
                If Pos(#10,Copy(Texto, 1, 40))>0 then
                begin
                    indice:=Pos(#10,Copy(Texto, 1, 40));
                    slinha:= Pchar(Copy(Texto, 1, indice-1));
                    Texto:= Copy(Texto,indice+1,fim);
                end
                else
                begin
                    sLinha:=Pchar(Copy(Texto,1,40));
                    Texto:=Copy(Texto,41,fim);
                end;
              j:=1;
              Repeat
                  sRet := fFuncEnviaComando( PChar(#27+'.080'+sLinha+'}') );
                  j:=j+1;
              Until (Status(1,sRet)='0') or (j<4);
           until  Length(texto)< 2;
       end;
       if i<>Vias then
       begin
             j:=1;
             Repeat
                sRet := fFuncEnviaComando( PChar(#27+'.089'+'6}') );
                j:=j+1;
             Until (Status(1,sRet)='0') or (j<4);
       end
       else
       begin
             j:=1;
             Repeat
                sRet := fFuncEnviaComando( PChar(#27+'.08}') );
                j:=j+1;
             Until (Status(1,sRet)='0') or (j<4);
       end;
      texto:=stexto;
    end;
  end;
  Result:=Status(1,sRet)+'|';
end;

//----------------------------------------------------------------------------------------------------------------------------------
function TImpFiscalSweda100.TotalizadorNaoFiscal( Numero,Descricao:String ):String;

var
  sRet : String;
begin
  sRet:=' -';
  if ( Copy(Descricao,1,1)<>'+' ) and ( Copy(Descricao,1,1)<>'-' ) then
     ShowMessage('O primeiro caracter define o tipo do acumulador (+)Creditos e (-)Debitos. Ex. +Recebimentos diversos, -Sangria')
  else
     Begin
     Descricao := Copy(Descricao+space(15),1,15);
     sRet      := fFuncEnviaComando( PChar(#27+'.38N&SIGALOJA      '+Descricao+'}') );
     end;

  result   := Status( 1,sRet );
end;

//------------------------------------------------------------
// Propriedades da impressora
procedure TImpFiscalSweda100.AlimentaProperties;
var
  sRet1 : String;
  sRet2 : String;
  sRet3 : String;
  sRet4 : String;
  sRetorno : String;
  sForma : String;
  sLinha : String;
  sAux : String;
  i : Integer;
begin
  // Aliquotas de ICMS
  i:=0;

  Repeat
     sRet1 := fFuncEnviaComando( PChar(#27+'.293}') );
     sComando293 := sRet1;
     i:=i+1;
  until ((copy(sRet1,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet2 := fFuncEnviaComando( PChar(#27+'.294}') );
     sComando294 := sRet2;
     i:=i+1;
  until ((copy(sRet2,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet3 := fFuncEnviaComando( PChar(#27+'.295}') );
     sComando295 := sRet3;
     i:=i+1;
  until ((copy(sRet3,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet4 := fFuncEnviaComando( PChar(#27+'.296}') );
     i:=i+1;
  until ((copy(sRet4,2,1)<> '-') and (i<20));

  PegaPDV;

  sLinha := '';
  if (copy(Status(1,sRet1),1,1)<>'0') or (copy(Status(1,sRet2),1,1)<>'0') or (copy(Status(1,sRet3),1,1)<>'0') then
  begin
    Aliquotas := sLinha;
    exit;
  end;
  sRetorno := copy(sRet1,49,28) + copy(sRet2,8,49) + copy(sRet3,8,28);
  i := 0;
  while (i<=15) and (Trim(copy(sRetorno,(7*i)+1,7))<>'') do
  begin
    sAux := FloatToStr(StrToFloat(copy(sRetorno,(7*i)+4,4))/100);
    if (FormataTexto(sAux,4,2,2) <> '0000') then
      if copy(sRetorno,(7*i)+1,1) = 'T' then
        sLinha := sLinha + FormataTexto(sAux,4,2,1,'.') + '|';
    i := i + 1;
  end;
  Aliquotas := sLinha;

  // Aliquotas de ISS
  sLinha := '';
  if (copy(Status(1,sRet1),1,1)<>'0') or (copy(Status(1,sRet2),1,1)<>'0') or (copy(Status(1,sRet3),1,1)<>'0') then
  begin
    ISS := sLinha;
    exit;
  end;
  sRetorno := copy(sRet1,49,28) + copy(sRet2,8,49) + copy(sRet3,8,28);
  i := 0;
  while (i<=15) and (Trim(copy(sRetorno,(7*i)+1,7))<>'') do
  begin
    sAux := FloatToStr(StrToFloat(copy(sRetorno,(7*i)+4,4))/100);
    if (FormataTexto(sAux,4,2,2) <> '0000') then
      if copy(sRetorno,(7*i)+1,1) = 'S' then
        sLinha := sLinha + FormataTexto(sAux,4,2,1,'.') + '|';
    i := i + 1;
  end;
  ISS := sLinha;

  // Formas de Pagamento
  sLinha := '';
  if (copy(Status(1,sRet3),1,1)<>'0') or (copy(Status(1,sRet4),1,1)<>'0') then
  begin
    FormasPgto := sLinha;
    exit;
  end;
  sForma := copy(sRet3,36,45) + copy(sRet4,8,105);
  // A diferença entre a 1.0 e a 1.A é que a 1.A para fazer cupom vinculado,
  // a finalizadora deve ter a FLAG de VINCULAÇÃO como 'S'.
  sVinculado := Copy(sRet3,81,3)+Copy(sRet4,113,7);
  For i:=0 to 9 do
  begin
    sAux := Trim(Copy(sForma,(i*15)+1,15));
    if sAux <> '' then
      sLinha := sLinha + sAux + '|';
  end;
  FormasPgto := sLinha;
End;
//----------------------------------------------------------------------------------------------------------------------------------
function TImpFiscalSweda100.HorarioVerao( Tipo:String ):String;
var sRet : String;
begin

If Tipo = '+' Then
  sRet := fFuncEnviaComando( PChar(#27+'.36S}') )
Else
  sRet := fFuncEnviaComando( PChar(#27+'.36N}') );

Result := Status( 1,sRet );
end;
//----------------------------------------------------------------------------------------------------------------------------------
function TImpFiscalSwedaII100.Cheque( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso:String ): String;
Var
  sRet:String;
begin
  Favorec:=copy(Trim(Favorec)+space(80),1,80);
  Cidade:=copy(Trim(Cidade)+space(30),1,30);

  Valor:=StrTran(Valor,',','');
  Valor:=FormataTexto(Valor,12,2,2);
  Verso:=copy(Trim(Verso)+space(120),1,120);
  Data:=FormataData(StrToDate(Data),2);

  sRet := fFuncEnviaComando( PChar(#27+'.44'+Favorec+Cidade+'}'));
  sRet := fFuncEnviaComando( PChar(#27+'.24'+Banco+Valor+'N'+Verso+'4'+Data+'}'));
  if Copy(sRet,2,1) = '+' then
    Result := '0'
  else
  begin
    // Se falhar a impressão, libera o documento.
    fFuncEnviaComando( PChar(#27+'.25}'));
    Result := '1';
  end;
end;

//------------------------------------------------------------
// Função para enviar o comando mais de uma vez caso ocorra erro
function EnviaComando(Texto:PChar):String;
var
  sRet    : String;
  sAut    : String;
  sSlip   : String;
  sStatus : String;
  iRet    : Integer;
  iVezes  : Integer;
begin
  // Controle de executar outra vez o comando caso ocorra erro de execuáão do comando.
  iVezes:=0;
  while iVezes<3 do
    Begin
    sRet := fFuncEnviaComando( Texto );
    Result:=sRet;

    If LogDLL Then
      WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Retorno Sweda: '+ sRet ));

    if copy(sRet,2,1)='-' then
       Begin
       if copy(sRet,3,2)='P' then
          Begin
          sAut    :='';
          sSlip   :='';
          sStatus :='';

          sRet:=copy(sRet,4,3);
          iRet:=StrToInt(copy(sRet,1,1));
          case iRet of
           0 : sAut:=sAut+'HÁ documento para AUTENTICAR';
           1 : sAut:=sAut+'Impressora off-line';
           2 : sAut:=sAut+'Time-out de Transmissão';
           5 : sAut:=sAut+'SEM documento para AUTENTICAR';
           6 : sAut:=sAut+'Time-out de recepção do impressor do ECF';
          end;

          iRet:=StrToInt(copy(sRet,2,1));
          case iRet of
           0 : sSlip:=sSlip+'HÁ folha SOLTA PRESENTE';
           1 : sSlip:=sSlip+'Impressora off-line';
           2 : sSlip:=sSlip+'Time-out de Transmissão';
           5 : sSlip:=sSlip+'SEM FOLHA solta presente';
           6 : sSlip:=sSlip+'Time-out de recepção do impressor do ECF';
          end;

          iRet:=StrToInt(copy(sRet,2,1));
          case iRet of
           0 : sStatus:=sSTatus+'Impressora tem papel';
           1 : sStatus:=sSTatus+'Impressora off-line';
           2 : sStatus:=sSTatus+'Time-out de Transmissão';
           5 : sStatus:=sSTatus+'Sem papel/papel acabando';
           6 : sStatus:=sSTatus+'Time-out de recepção do impressor do ECF';
          end;
          ShowMessage('Auto   - '+sAut+chr(10)+
                      'Slip   - '+sSlip+chr(10)+
                      'Status - '+sStatus+chr(10));
          end
       else

       Inc(iVezes);
       sleep(200);
       //iVezes:=3;
       end
    else
       Begin
       exit;
       end;
    end;
end;

//------------------------------------------------------------
//******************************************************************************
// A função EnviaComandoEspera foi criada para contemplar a impressão do cupom
// não fiscal para enviar o comando mais de uma vez.
//******************************************************************************
function TImpFiscalSweda100.EnviaComandoEspera(Texto:PChar;var Buffer:String;iVezes:Integer = 2):String;
var
  sRet    : String;
  iContador : Integer;
  iSequencial : Integer;
  iSequencial2 : Integer;
  i : Integer;
  bComandoOk : Boolean;
begin
  iContador := 0;
  sRet := '';
  bComandoOk := False;

  while (iContador <= iVezes) And (not bComandoOK) do
  begin

    //******************************************************************************
    // Faz um tratamento diferente quando for o comando ESC.27 pois o ECF tem
    // um delay para retornar o comando
    //******************************************************************************
    If Pos( #27+'.271', StrPas(Texto) ) > 0 then
    begin

        //******************************************************************
        // Envia o comando original para o ECF
        //******************************************************************
        sRet := '';
        sRet := fFuncEnviaComando( Texto );

        //******************************************************************
        // Armazena o retorno do ECF
        //******************************************************************
        Buffer := sRet;

        If Copy( Buffer, 1, 3 ) <> '.+C' then
          bComandoOk := False
        Else If Status( 1, Buffer ) = '0' then
          bComandoOk := True
        Else
          bComandoOk := False;

    end
    Else
    begin
      //******************************************************************
      // Pega o número sequencial do comando enviado para o ECF
      //******************************************************************
      i := 0;
      While i <= 5 do
      begin
        sRet := fFuncEnviaComando( PChar(#27+'.23}') );
        If Status( 1, sRet ) = '0' then
          i := 10
        Else
        begin
          Inc( i );
          Sleep(500);
        end;
      end;

      If Status( 1, sRet ) = '0' then
      begin
        Try
          iSequencial := StrToInt(Copy( sRet, 9, 4 ));
        Except
          iSequencial := 1;
        End;

        //******************************************************************
        // Envia o comando original para o ECF
        //******************************************************************
        sRet := '';
        sRet := fFuncEnviaComando( Texto );

        //******************************************************************
        // Armazena o retorno do ECF
        //******************************************************************
        Buffer := sRet;

        If Status( 1, sRet ) = '0' then
        begin
          //******************************************************************
          // Pega o número sequencial do comando enviado para o ECF
          //******************************************************************
          i := 0;
          While i <= 5 do
          begin
            sRet := fFuncEnviaComando( PChar(#27+'.23}') );
            If Status( 1, sRet ) = '0' then
              i := 10
            Else
            begin
              Inc( i );
              Sleep(500);
            end;
          end;

          //******************************************************************
          // Pega o número sequencial do comando enviado para o ECF
          //******************************************************************
          If Pos('.271', StrPas(Texto) ) = 0 then
            Inc( iSequencial );

          Try
            iSequencial2 := StrToInt(Copy( sRet, 9, 4 ));
          Except
            iSequencial2 := 1;
          End;

          If ((iSequencial) <> iSequencial2) and (iSequencial2<>1) then
            bComandoOk := False
          Else
            bComandoOk := True;

        end;
      end;
    end;

    If not bComandoOk then
    begin
      Sleep( 200 * iContador );
      Inc( iContador );
    end
    Else
      iContador := 20;
  end;


  If bComandoOk then
    Result := '0'
  Else
    Result := '1';

end;

//------------------------------------------------------------
// Propriedades da impressora
procedure TImpFiscalSweda.AlimentaProperties;
var
  sRet1 : String;
  sRet2 : String;
  sRet3 : String;
  sRet4 : String;
  sRetorno : String;
  sLinha : String;
  sForma : String;
  sAux : String;
  i : Integer;
begin

  // Leitura de ICMS
  sLinha := '';
  i := 0;

  Repeat
     sRet1 := fFuncEnviaComando( PChar(#27+'.293}') );
     sComando293 := sRet1;
     i:=i+1;
  until ((copy(sRet1,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet2 := fFuncEnviaComando( PChar(#27+'.294}') );
     sComando294 := sRet2;
     i:=i+1;
  until ((copy(sRet2,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet3 := fFuncEnviaComando( PChar(#27+'.295}') );
     sComando295 := sRet3;
     i:=i+1;
  until ((copy(sRet3,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet4 := fFuncEnviaComando( PChar(#27+'.296}') );
     i:=i+1;
  until ((copy(sRet4,2,1)<> '-') and (i<20));

  PegaPDV;

  if (copy(Status(1,sRet1),1,1)<>'0') or (copy(Status(1,sRet2),1,1)<>'0') or (copy(Status(1,sRet3),1,1)<>'0') then
  begin
    Aliquotas := sLinha;
    exit;
  end;
  sRetorno := copy(sRet1,49,64) + copy(sRet2,8,112) + copy(sRet3,8,64);
  i := 0;
  while (i<=15) and (Trim(copy(sRetorno,(16*i)+9,8))<>'') do
  begin
    sAux := FloatToStrf(StrToFloat(copy(sRetorno,(16*i)+9,4))/100,ffFixed,18,2);
    if (FormataTexto(sAux,4,2,2) <> '0000') then
        sLinha := sLinha + sAux + '|';
    i := i + 1;
  end;
  Aliquotas := sLinha;

  // Leitura de ISS
  ISS := '0.00';

  // Formas de Pagamento
  sLinha := '';
  if (copy(Status(1,sRet3),1,1)<>'0') or (copy(Status(1,sRet4),1,1)<>'0') then
  begin
    FormasPgto := sLinha;
    exit;
  end;
  sForma := copy(sRet3,72,45) + copy(sRet4,8,105);
  sLinha := '';
  For i:=0 to 9 do
  begin
    sAux := Trim(Copy(sForma,(i*15)+1,15));
    if sAux <> '' then
      sLinha := sLinha + sAux + '|';
  end;
  FormasPgto := sLinha;

end;

////////////////////////////////////////////////////////////////////////////////
///  Impressora de Cheque Sweda IFS II V1.00
///
function TImpChequeSwedaII100.Abrir( aPorta:String ): Boolean;
begin
  Result := (Copy(OpenSweda( aPorta ),1,1) = '0');
end;

//------------------------------------------------------------------------------
function TImpChequeSwedaII100.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sRet     : String;
  sFavorec : String;
  sCidade  : String;
  sValor   : String;
  sVerso   : String;
  sData    : String;
  sBanco   : String;
begin
  if length(Data)=6 then
  begin
     sData := Copy(Data,5,2)+'/'+Copy(Data,3,2)+'/'+Copy(Data,1,2);
     Data  := Pchar(FormatDateTime('yyyymmdd',StrToDate(sData)));
  end;

  sFavorec := Copy(Trim(Favorec)+Space(80),1,80);
  sCidade  := Copy(Trim(Cidade)+Space(30),1,30);
  sValor   := FormataTexto(Valor,12,2,2);
  sVerso   := Copy(Trim(Verso)+Space(120),1,120);
  sData    := Copy(Data,7,2)+Copy(Data,5,2)+Copy(Data,1,4);
  sBanco   := FormataTexto(Banco,3,0,2);

  sRet := fFuncEnviaComando( PChar(#27+'.44'+sFavorec+sCidade+'}'));
  sRet := fFuncEnviaComando( PChar(#27+'.24'+sBanco+sValor+'N'+sVerso+'4'+sData+'}'));
  if Copy(sRet,2,1) = '+' then
    Result := True
  else
  begin
    // Se falhar a impressão, libera o documento.
    fFuncEnviaComando( PChar(#27+'.25}'));
    Result := False;
  end;
end;

//----------------------------------------------------------------------------
function TImpChequeSwedaII100.ImprimirTransf( Banco, Valor, Cidade, Data, Agencia, Conta, Mensagem:PChar ):Boolean;
begin
  LjMsgDlg( 'Não implementado para esta impressora' );

  Result := False;
end;

//------------------------------------------------------------------------------
function TImpChequeSwedaII100.Fechar( aPorta:String ): Boolean;
begin
  Result := (Copy(CloseSweda( aPorta ),1,1) = '0');
end;

//----------------------------------------------------------------------------
function TImpChequeSwedaII100.StatusCh( Tipo:Integer ):String;
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
function TImpChequeSweda.Imprimir( Banco,Valor,Favorec,Cidade,Data,Mensagem,Verso,Extenso,Chancela,Pais:PChar ): Boolean;
var
  sRet      : String;
  sPath     : String;
  sParam    : String;
  sTextoChq : String;
  sLinha    : String;
  sIni      : String;
  sDia, sMes, sAno : String;
  aParam    : array of String;
  i         : Integer;
  fArquivo  : TIniFile;
begin
  Result := False;
  sTextoChq := '';
  i := 0;
  Valor := Pchar(Trim(FormataTexto(valor,12,2,3,'.')));

  SetLength(aParam,19);
  // Verifica o path de onde esta o arquivo Bancos.INI
  sPath := ExtractFilePath(Application.ExeName);
  sIni := sPath+'BANCOS.INI';
  If FileExists( sIni) then
  begin
      fArquivo  := TIniFile.Create(sPath+'BANCOS.INI');

      If Length(Data)=8 then
      Begin
          sDia := Copy(Data,7,2);
          sAno := Copy(Data,1,4);
          sMes := Copy(Data,5,2);
      End
      Else
      Begin
          sDia := Copy(Data,5,2);
          sAno := Copy(Data,1,2);
          sMes := Copy(Data,3,2);
      End;

      Case StrToInt(sMes) of
        01: sMes := 'Janeiro';
        02: sMes := 'Fevereiro';
        03: sMes := 'Março';
        04: sMes := 'Abril';
        05: sMes := 'Maio';
        06: sMes := 'Junho';
        07: sMes := 'Julho';
        08: sMes := 'Agosto';
        09: sMes := 'Setembro';
        10: sMes := 'Outubro';
        11: sMes := 'Novembro';
        12: sMes := 'Dezembro';
      end;

      sParam    := fArquivo.ReadString('BANCOS', Banco, 'BANCO PADRAO,1,S,55,1,N,23,0,S,7,1,N,3,0,S,25,1,5,8') + ',';

      While (Length(sParam) > 0) do
      Begin
        aParam[i] := Copy(sParam,1,Pos(',',sParam)-1);
        sParam := Copy(sParam,Pos(',',sParam)+1, Length(sParam));
        i := i+1;
      End;

      //**********************  VALOR NUMERICO *****************************//
      //Qtas linhas devem ser puladas antes de imprimir o valor numérico

      If StrToInt(aParam[1]) > 0 then
          sTextoChq := '9'+ aParam[1] + '|';

      //Pula meia-linha para ajustar o cheque qdo necessário, antes de imprimir o valor numérico
      If aParam[2] = 'S' then
          sTextoChq := sTextoChq + '81' + '|';

      //Linha do Valor Numérico
      sTextoChq := sTextoChq + '0' + Space(StrToInt(aParam[3])) + '(R$ ' + Valor + ')|';

      //**********************  PRIMEIRA LINHA DO EXTENSO  **********************//
      //Qtas linhas devem ser puladas antes de imprimir a primeira linha do extenso
      If StrToInt(aParam[4]) > 0 then
          sTextoChq := sTextoChq + '9'+sParam + '|';

      //Pula meia-linha antes de imprimir a primeira linha do extenso
      If aParam[5] = 'S' then
          sTextoChq := sTextoChq + '81' + '|';

      //Primeira Linha do Extenso
      sTextoChq := sTextoChq + '0' + Space(StrToInt(aParam[6])) + Copy(Extenso,1,76-StrToInt(aParam[6])) +'|';

      //**********************  SEGUNDA LINHA DO EXTENSO  **********************//
      //Qtas linhas devem ser puladas antes de imprimir a segunda linha do extenso
      If StrToInt(aParam[7]) > 0 then
          sTextoChq := sTextoChq + '9'+aParam[7] + '|';

      //Pula meia-linha antes de imprimir a segunda linha do extenso
      If aParam[8] = 'S' then
          sTextoChq := sTextoChq + '81' + '|';

      //Segunda Linha do Extenso
      sTextoChq := sTextoChq + '0' + Space(StrToInt(aParam[9])) + Copy(Extenso,77-StrToInt(aParam[6]),Length(Extenso)) +'|';

      //*****************************  FAVORECIDO  **************************//
      //Qtas linhas devem ser puladas antes de imprimir o favorecido
      If StrToInt(aParam[10]) > 0 then
          sTextoChq := sTextoChq + '9'+aParam[10] + '|';

      //Pula meia-linha antes de imprimir o favorecido
      If aParam[11] = 'S' then
          sTextoChq := sTextoChq + '81' + '|';

      //Favorecido
      sTextoChq := sTextoChq + '0' + Space(StrToInt(aParam[12])) + Favorec +'|';

      //********************************  DATA  ******************************//
      //Qtas linhas devem ser puladas antes de imprimir a DATA
      If StrToInt(aParam[13]) > 0 then
          sTextoChq := sTextoChq + '9'+aParam[13] + '|';

      //Pula meia-linha antes de imprimir a data
      If aParam[14] = 'S' then
          sTextoChq := sTextoChq + '81' + '|';

      //Data
      sTextoChq := sTextoChq + '0' + Space(StrToInt(aParam[15])) + Cidade ;
      sTextoChq := sTextoChq + Space(StrToInt(aParam[16])) + sDia ;
      sTextoChq := sTextoChq + Space(StrToInt(aParam[17])) + sMes ;
      sTextoChq := sTextoChq + Space(StrToInt(aParam[18])) + sAno +'|';

      i:= 0;
      sLinha := Copy(sTextoChq,1,Pos('|',sTextoChq)-1);
      sRet := fFuncEnviaComando( PChar(#27+'.24'+sLinha+'}'));
      Sleep(2000);
      While (Copy(sRet,2,1)<> '+') and (i < 3) do
      begin
        ShowMessage('É necessário inserir o cheque !');
        sRet := fFuncEnviaComando( PChar(#27+'.24'+sLinha+'}'));
        i:= i+1;
      end;
      sTextoChq := Copy(sTextoChq,Pos('|',sTextoChq)+1,Length(sTextoChq));

      While (Length(sTextoChq) > 0) do
      begin
          sLinha := Copy(sTextoChq,1,Pos('|',sTextoChq)-1);
          sRet := fFuncEnviaComando( PChar(#27+'.24'+sLinha+'}'));
          sTextoChq := Copy(sTextoChq,Pos('|',sTextoChq)+1,Length(sTextoChq));
      End;

      sRet := fFuncEnviaComando( PChar(#27+'.25}'));

      If Copy(sRet,2,1) = '+' then
          Result := True;
  End
  Else
  Begin
    Result := False;
    MsgStop( 'Arquivo BANCOS.INI não encontrado. ');
  End;

end;


//----------------------------------------------------------------------------
function TImpChequeSweda.StatusCh( Tipo:Integer ):String;
begin
//Tipo - Indica qual o status quer se obter da impressora
//  1 - É necessário enviar o extenso do cheque para a SIGALOJA.DLL ?

//É necessário enviar o extenso do cheque para a SIGALOJA.DLL ?
//      0 - Sim      1 - Não
result := '0';
end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenSweda( sPorta:String ) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: SERSWEDA.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  sRet : String;
begin
  If Not bOpened Then
  Begin
    fHandle := LoadLibrary( 'SERSWEDA.DLL' );
    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'FechaPorta');
      if ValidPointer( aFunc, 'FechaPorta' ) then
        fFuncFechPorta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AbrePorta');
      if ValidPointer( aFunc, 'AbrePorta' ) then
        fFuncAbrePorta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'EnviaComando');
      if ValidPointer( aFunc, 'EnviaComando' ) then
        fFuncEnviaComando := aFunc
      else
        bRet := False;
    end
    else
    begin
      ShowMessage('O arquivo SERSWEDA.DLL não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      bOpened := True;
      Result := '0|';
      // Esse comando só irá fazer a abertura da porta. Não checa se a impressora está ou não ligada.
      bRet := fFuncAbrePorta(StrToInt(Copy(sPorta,4,1)),5);
      If bRet then
      begin
        // Envia um comando somente para ver se a impressora está ou não respondendo.
        sRet := fFuncEnviaComando( PChar(#27+'.28}') );
        If Pos('-P002',sRet) > 0 then
          bRet := False;
      end;

      if not bRet then
      begin
        bOpened := False;
        result := '1|';
      end;
    end
    else
      result := '1|';
  End
  Else
    Result := '0|';
end;

//----------------------------------------------------------------------------
Function CloseSweda( sPorta:String ) : String;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      if not fFuncFechPorta( StrToInt(Copy(sPorta,4,1)) ) then
      begin
        ShowMessage('Erro ao fechar a comunicação com impressora Fiscal.');
        result := '1|';
      end;
      Sleep(1000);
      FreeLibrary(fHandle);
      bOpened := False;
      fHandle := 0;
    end;
    Result := '0|';
  End
  Else
    Result := '0|';
end;

//----------------------------------------------------------------------------
Function TImpFiscalSweda.GravaCondPag( condicao:string ) : String;
var sPagto, sRet, sLinha : String;
    aPagto : TaString;
    iCont, iLenPag : Integer;
begin

  // No caso desta versão da Sweda, se o primeiro caracter da string
  // condicao for igual a "=" será acumulado na legenda não-fiscal "TROCO
  // DE CHEQUE" ou se o primeiro caracter for igual a "#" será acumulado na
  // legenda não-fiscal "CONTRA-VALE".

  // Monta vetor com formas existentes
  sPagto   := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  iLenPag := length( aPagto ) - 1;
  result  := '0';

  // Acrescenta os 15 espacos obrigatorios
  for iCont := 0 to iLenPag do
    aPagto[ iCont ] := aPagto[ iCont ] + Space( 15 - Length( aPagto[ iCont ] ) );

  if Length( condicao ) < 15 then condicao := condicao + Space( 15 - length(condicao) );

  // Verifica se já existe a forma de pagamento
  for iCont := 0 to iLenPag do
    if UpperCase( aPagto[ iCont ] ) = UpperCase( condicao ) then
    begin
      ShowMessage( 'Já existe a condição de pagamento: ' + condicao );
      result := '4|';
      exit;
    end;

  // Se o contador for igual ao total de formas de pagamento, já tem o total de formas
  if (iLenPag + 1) = 10 then
  begin
    ShowMessage( 'Sem espaço em memória para armazenar a nova forma de pagamento.' );
    result := '6|';
  end;

  // Monta linha para mandar
  sLinha := '';
  for iCont := 0 to iLenPag do
    sLinha := sLinha + UpperCase( aPagto[ iCont ] );

  sLinha := sLinha + condicao;

  if copy(result,1,1) = '0' then
  begin
    // Grava nova forma de pagamento.
    sRet := EnviaComando( PChar(#27+'.39' + sLinha + '}' ) );
    result := Status(1,sRet);
  end;
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda.PegaSerie : String;

var
  sRet : String;
begin
  sRet := EnviaComando( PChar(#27+'.273}') );
  result := Status(1,sRet);
  if Copy(Status(1,sRet),1,1)='0' then
    result := '0|' + copy(sRet,13,9)
  else
    result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda101.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var
  sRet : String;
  iVz:Integer;
  nTent : Integer;
  sStatus : String;

begin
  IF Vezes=0 then
     Vezes:=1;

  nTent := 1;

  iVZ:=1;
  WHILE ( iVz<=Vezes ) And ( nTent <= 5 ) do
     begin
        ShowMessage('Posicione o Documento para a '+IntToStr(iVz)+'a. Autenticação.');
        if iVz=1 then
           sRet := fFuncEnviaComando( PChar(#27+'.200N'+Replicate('0',14)+'10N'+Space(20)+'}') )
        else
          sRet := fFuncEnviaComando( PChar(#27+'.26}') );

        if copy(sRet,2,1) = '-' then
           Inc( nTent )
        else
        Begin
           Inc(iVz);
           While Pos( '+', sStatus ) = 0 Do
           Begin
             If nTent > 5 Then
               Break;
             sStatus := fFuncEnviaComando( PChar(#27+'.28}') );
             If ( Pos( '+', sStatus ) <> 0 ) Then
               ShowMessage('Posicione o Documento para a '+IntToStr(iVz)+'a. Autenticação.');
             Inc( nTent );  
           End
        End

     end;
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
Function TImpFiscalSweda101.GravaCondPag( condicao:string ) : String;
var sPagto, sRet, sLinha : String;
    aPagto : TaString;
    iCont, iLenPag : Integer;
begin

  // No caso desta versão da Sweda, se o primeiro caracter da string
  // condicao for igual a "=" será acumulado na legenda não-fiscal "TROCO
  // DE CHEQUE" ou se o primeiro caracter for igual a "#" será acumulado na
  // legenda não-fiscal "CONTRA-VALE".

  // Nessa versão a programação das Modalidades de Pagamento só pode ser feita
  // em Modo Intervenção

(*  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)= '0' then
  begin
        If Copy (sRet,59,16)<>'MODO INTERVENCAO' then
        begin
                Showmessage ('Essa operação só é possível quando a Impressora Fiscal está em Modo Intervenção Técnica.');
                result := Status(1,sRet);
                exit;
        end;
  end;
  *)

  // Monta vetor com formas existentes
  sPagto   := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  iLenPag := length( aPagto ) - 1;
  result  := '0';

  // Acrescenta os 15 espacos obrigatorios
  for iCont := 0 to iLenPag do
    aPagto[ iCont ] := aPagto[ iCont ] + Space( 15 - Length( aPagto[ iCont ] ) );

  if Length( condicao ) < 15 then condicao := condicao + Space( 15 - length(condicao) );

  // Verifica se já existe a forma de pagamento
  for iCont := 0 to iLenPag do
    if UpperCase( aPagto[ iCont ] ) = UpperCase( condicao ) then
    begin
      ShowMessage( 'Já existe a condição de pagamento: ' + condicao );
      result := '4|';
      exit;
    end;

  // Se o contador for igual ao total de formas de pagamento, já tem o total de formas
  if (iLenPag + 1) = 10 then
  begin
    ShowMessage( 'Sem espaço em memória para armazenar a nova forma de pagamento.' );
    result := '6|';
  end;

  // Monta linha para mandar
  sLinha := '';
  for iCont := 0 to iLenPag do
    sLinha := sLinha + 'S'+UpperCase( Copy(aPagto[ iCont ],1,15) );

  sLinha := sLinha + 'S' +condicao;

  if copy(result,1,1) = '0' then
  begin
    // Grava nova forma de pagamento.
    sRet := EnviaComando( PChar(#27+'.39' + sLinha + '}' ) );
    If Status(1,sRet) <> '0' then
        ShowMessage( 'Esse comando tem efeito apenas entre a Redução Z e a primeira venda do dia.' );
    result := Status(1,sRet);
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda101.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
var
  sRet : String;
  sNumAnt : String;
  i : Integer;
  aFormas : array of String;
  sFormas : String;
  sPos : String;
  sPosTot : String;
  iPos : Integer;
  iTamanho : Integer;
  bTotalizadorIsNum : Boolean;
  sTotPad : String;
  sTotFormaPagto : String;
  sBuffer : String;
begin
  If Trim(Totalizador)='' then
     Totalizador:='SIGALOJA';

  // Pegando o numero do ultimo cupom impresso
  sNumAnt := fFuncEnviaComando( PChar(#27+'.271}') );

  if Copy( Status(1,sNumAnt),1,1 ) = '0' then
    sNumAnt := copy(sNumAnt,14,4)
  else
  begin
    result := '1|';
    exit;
  end;
  // Monta o array aFormas com as condicoes de pagamento do cupom fiscal
  sRet := LeCondPag;
  sRet := Copy(sRet, 3, Length(sRet));
  iTamanho := 0;
  While (Pos('|', sRet) > 0) do
  begin
    iTamanho := iTamanho + 1;
    SetLength( aFormas, iTamanho );
    iPos := Pos('|', sRet);
    sFormas := Copy(sRet, 1, iPos-1);
    aFormas[iTamanho-1] := sFormas ;
    sRet := Copy(sRet, iPos+1, Length(sRet));
  end;
  // Verificando qual o codigo da condicao de pagamento utilizado
  sPos := '0';
  For i:=0 to Length(aFormas)-1 do
    if UpperCase(Trim(aFormas[i])) = UpperCase(Trim(Condicao)) then
      sPos := IntToStr(i + 1);
  if length(sPos) < 2 then
    sPos := '0' + sPos;
  if sPos = '00' then
  begin
    ShowMessage('A finalizadora '+Condicao+' não foi cadastrada no ECF.');
    result := '1|';
    exit;
  end;
  // A diferença entre a 1.0 e a 1.A é que a 1.A para fazer cupom vinculado,
  // a finalizadora deve ter a FLAG de VINCULAÇÃO como 'S'.
  if Copy(sVinculado, StrToInt(sPos), 1) = 'N' then
  begin
    ShowMessage('A finalizadora '+Condicao+' não foi cadastrada como VINCULADA no ECF.');
    result := '1|';
    exit;
  end;
  // Abrindo cupom nao fiscal vinculado '00'
  sRet := fFuncEnviaComando( PChar(#27+'.1900'+sNumAnt+sPos+'                    01}') );
  result := Status( 1,sRet );

  if copy(result,1,1) = '1' then  // Impressao do Cupom nao fiscal nao vinculado
    Begin
    sTotFormaPagto := sPos;
    sRet:=' -';
    Valor   :=FormataTexto(Valor,12,2,2);
    sRet    :='789ABCD';
    sFormas :='';
    For i:= 1 to 7 do
       Begin
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
       end;
    sFormas:=Copy(sFormas,31,length(sFormas));

    iTamanho:=1;
    SetLength( aFormas,0 );
    while Trim(sFormas)<>'' do
       Begin
        SetLength( aFormas, iTamanho );
        aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
        sFormas:=Copy(sFormas,16,Length(sFormas));
        Inc(iTamanho);
        end;

    Try
      StrToInt( Totalizador );
      bTotalizadorIsNum := True;
    Except
      bTotalizadorIsNum := False;
    End;
    sPos       := '0';
    sPosTot    := '0';
    For i:=0 to high(aFormas) do
       Begin
        // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
        // Pois a legenda somente podera ser do mesmo titulo.
        // Ex.
        // 01 &GAVETA                -> Titulos
        // 02    + Recebimento       -> Legendas
        // 03    - Sangria           -> Legendas
        // 04 &Sigaloja              -> Titulos
        // 05    + Entrada Diversas  -> Legendas
        // 06    - Saidas diversas   -> Legendas

       If bTotalizadorIsNum then
          sPosTot  := Totalizador
       Else
         //Pegar o codigo do titulo
         if Trim(UpperCase(aFormas[i])) = '&'+Trim(UpperCase(Totalizador)) then
            sPosTot:= FormataTexto(IntToStr(i + 1),2,0,2);

       //Pegar o codigo da Legenda
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(Condicao)) ) and
          ( sPosTot <> '0' ) then
          sPos := FormataTexto(IntToStr(i + 1),2,0,2);
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = 'FUNDO DE CAIXA') then
          sTotPad := FormataTexto(IntToStr(i + 1),2,0,2);
       end;

    // Se não encontrar a forma solicitada, cria o cupom como 'FUNDO DE CAIXA'
    If sPos = '0' then
      sPos := sTotPad;

    // Abre o cupom não vinculado
    sBuffer := Space(128);
    sRet := EnviaComandoEspera( PChar(#27+'.19' + sPosTot + '      }'), sBuffer );
    If sRet = '0' then
    begin
      // Faz o recebimento não fiscal
      sBuffer := Space(128);
      sRet := EnviaComandoEspera( PChar(#27+'.07' + sPos + Valor + '}'), sBuffer, 3 );
      If sRet = '0' then
      begin
        // Totaliza o cupom
        sBuffer := Space(128);
        sRet := EnviaComandoEspera( PChar(#27+'.10'+sTotFormaPagto+Valor+'}'), sBuffer, 3 );
        If sRet = '0' then
        begin
          // Fecha o cupom indicando que haverá um vinculado
          sBuffer := Space(128);
          sRet := EnviaComandoEspera( PChar(#27+'.12N}'), sBuffer, 3 );
          If sRet = '0' then
          begin
            sBuffer := Space(128);
            sRet := EnviaComandoEspera( PChar(#27+'.271}'), sBuffer, 10 );
            If sRet = '0' then
            begin
              sNumAnt := copy( sBuffer, 14, 4 );
              sBuffer := Space(128);
              sRet := EnviaComandoEspera( PChar(#27+'.1900'+sNumAnt+sTotFormaPagto+'}'), sBuffer, 10 );
            end;
          end;
        end;
      end;
    end;

    result := Status( 1, sBuffer );
  end;



end;

//----------------------------------------------------------------------------
function TImpFiscalSweda101.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
    Function ProcuraAliq(Aliq: string): String;
    Begin
        Aliq:= FormataTexto(Aliq,5,2,1);
        Aliq:= Copy(Aliq,1,2)+Copy(Aliq,4,2);
        // Procura a alíquota no primeiro pacote...
        If Pos(Aliq,sComando293) > 0 Then
            Result := Copy(sComando293,Pos(Aliq,sComando293)-3,3)
        Else
        Begin
            // Caso não encontre no primeiro pacote. Procura a alíquota no segundo pacote...
            If Pos(Aliq,sComando294) > 0 Then
                Result := Copy(sComando294,Pos(Aliq,sComando294)-3,3)
            Else
            Begin
                // Caso não encontre no segundo pacote. Procura a alíquota no último pacote...
                If Pos(Aliq,sComando295) > 0  Then
                    Result := Copy(sComando295,Pos(Aliq,sComando295)-3,3)
                Else
                    Result := 'T  ';
            End;
        End;
    End;
var
  sAliq, sSituacao, sRet, sDescrAdic : String;
  aAliq : TaString;
  iPos, i, iTamanho, nSeqAtual : Integer;
begin
  // Verifica a casa decimal dos parâmetros
  qtde := StrTran(qtde,',','.');
  vlrUnit := StrTran(vlrUnit,',','.');
  vlrdesconto := StrTran(vlrdesconto,',','.');
  vlTotIt := Trim(StrTran(vlTotIt,',','.'));

  //verifica se é para registra a venda do item ou só o desconto
  if Trim(codigo+descricao+qtde+vlrUnit) = '' then
  begin
    if StrToFloat(vlrdesconto) <> 0 then
    begin
      sRet := fFuncEnviaComando( PChar(#27+'.02'+'0000'+FormataTexto(vlrdesconto,12,2,2) + '}') );
      result := Status( 1,sRet );
    end
    else
      result := '0';
    exit;
  end;

  // Faz o tratamento da aliquota
  sSituacao := copy(aliquota,1,1);
  aliquota := Trim(StrTran(copy(aliquota,2,5),',','.'));

  // Checa as aliquotas
  If sSituacao = 'T' then
    sRet := LeAliquotas
  Else
    sRet := LeAliquotasISS;

  // Problemas na leitura de aliquota ?
  if copy( sRet, 1, 1 ) <> '0' then
  begin
    result := '1|';
    exit;
  end
  else
    sRet := copy( sRet, 3, length( sRet ) );

  // Verifica se a aliquota é ISENTA, c/SUBSTITUICAO TRIBUTARIA, NAO TRIBUTAVEL OU ISS
  If ( sSituacao = 'T' ) Or ( sSituacao = 'S' )then
  begin

    MontaArray( sRet, aAliq );
    iPos := 0;
    for iTamanho:=0 to Length(aAliq)-1 do
      if aAliq[iTamanho] = aliquota then
      begin
        if iPos = 0 then
          iPos := iTamanho + 1;
      end;

    if (iPos = 0) and (Pos(sSituacao,'TS') > 0) then
    begin
      ShowMessage('Aliquota não cadastrada.');
      result := '1|';
      exit;
    end;

    sAliq := ProcuraAliq(aliquota);

  end
  else if Trim(sSituacao) = 'I' then
        sAliq:= 'I  '
  else if Trim(sSituacao) = 'F' then
        sAliq:= 'F  '
  else if Trim(sSituacao) = 'N' then
        sAliq:= 'N  '
  else
      sAliq := 'T0 ';

  vlTotIt   := FormataTexto(vlTotIt,12,2,2);
  vlrUnit   := FormataTexto(vlrUnit,9,2,2);
  // Efetua o registro do item
  {    sRet := EnviaComando( PChar(#27+'.01'+ Copy(codigo+Space(13),1,13)+
                                              FormataTexto(qtde,7,3,2) +
                                              vlrUnit +
                                              vlTotIt +
                                              Copy(descricao+Space(24),1,24) +
                                              sAliq + '}//') );} 
  If Length(Descricao) > 24 then
    sDescrAdic := copy(Descricao,25,Length(Descricao));

  // Valida o tamanho da descricao. Se for maior que 24 posições envia a descricao auxiliar.
  If Length(sDescrAdic) > 0 then
    sRet := EnviaComando( PChar(#27+'.01'+ Copy(codigo+Space(13),1,13)+
                                              FormataTexto(qtde,7,3,2) +
                                              vlrUnit +
                                              vlTotIt +
                                              Copy(descricao+Space(24),1,24) +
                                              sAliq +
                                              Copy(sDescrAdic+Space(40),1,40) +
                                              '}') )
  Else
    sRet := EnviaComando( PChar(#27+'.01'+ Copy(codigo+Space(13),1,13)+
                                              FormataTexto(qtde,7,3,2) +
                                              vlrUnit +
                                              vlTotIt +
                                              Copy(descricao+Space(24),1,24) +
                                              sAliq + '}') );
        If (sRet = '.-P006}') or (sRet = '.-P002}') then
        Begin
            i := 0;
            Repeat
                sRet := EnviaComando( PChar(#27+'.23}'));
                i := i+1;
            Until (i>3) or (Copy(sRet,2,1)='+');

            If (Copy(sRet,2,1)='+') then
            Begin
                nSeqAtual := StrToInt(Copy (sRet, 9, 4));
                If nSeqAtual = (nUltimoSeq +1) then
                    sRet := Copy(sRet, 7, 7)
                Else
                    Result := Status (1, sRet);
            End
            Else
                Result := Status (1, sRet);
        End
        Else If Pos('.-', sRet)>0 then
            Result := Status (1, sRet)
        Else
            nUltimoSeq := StrToInt(Copy(sRet, 3, 4));

 // verifica se houve erro no registro do item e registra o desconto
  if copy( Status(1,sRet),1,1 ) = '0' then
    if StrToFloat(vlrdesconto) <> 0 then
      sRet := fFuncEnviaComando( PChar(#27+'.02'+'0000'+FormataTexto(vlrdesconto,12,2,2) + '}') );

  result := Status( 1,sRet );

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda101.DescontoTotal( vlrDesconto:String ;nTipoImp:Integer ): String;
var
  sRet : String;
begin
  vlrDesconto := StrTran(vlrDesconto,',','.');
  sRet := fFuncEnviaComando( PChar(#27+'.03'+'0000'+FormataTexto(vlrDesconto,12,2,2)+'S}') );
  result := Status( 1,sRet );
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda101.Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
//**********************************************************************************************************
   function PegaRegistro( sCondicao:String ):String;
   Var
     sRet       : String;
     i          : Integer;
     aFormas    : array of String;
     sFormas    : String;
     sPos       : String;
     bIndiceTot : Boolean;
     iTamanho   : Integer;
     Totalizador: String;
     sPath      : String;
     fArquivo   : TIniFile;
     sSangria   : String;
     sTroco     : String;
     sReceb     : String;
     sTitulo    : String;

   Begin
     sPath := ExtractFilePath(Application.ExeName);
     fArquivo := TIniFile.Create(sPath+'\SIGALOJA.INI');

     // Pegar no SIGALOJA.INI os titulos dos não-fiscais
     If fArquivo.ReadString('SWEDA', 'Tit. Sangria', '' ) = '' then
       fArquivo.WriteString('SWEDA', 'Tit. Sangria', 'SIGALOJA' );

     If fArquivo.ReadString('SWEDA', 'Tit. Troco', '' ) = '' then
       fArquivo.WriteString('SWEDA', 'Tit. Troco', 'SIGALOJA' );

     If fArquivo.ReadString('SWEDA', 'Tit. Recebimento', '' ) = '' then
       fArquivo.WriteString('SWEDA', 'Tit. Recebimento', 'SIGALOJA' );

     sSangria:= fArquivo.ReadString('SWEDA', 'Tit. Sangria', '' );
     sTroco  := fArquivo.ReadString('SWEDA', 'Tit. Troco', '' );
     sReceb  := fArquivo.ReadString('SWEDA', 'Tit. Recebimento', '' );

     If sCondicao = 'FUNDO DE CAIXA' then
       sTitulo := '&' + sTroco
     Else
       sTitulo := '&' + sSangria;

     sRet    :='789ABCD';
     sFormas :='';
     For i:= 1 to 7 do
     Begin
       // Lendo todos as descrições dos registradores.
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
     end;
     sFormas:=Copy(sFormas,31,length(sFormas));

     iTamanho:=1;
     SetLength( aFormas,0 );
     while Trim(sFormas)<>'' do
     Begin
       SetLength( aFormas, iTamanho );
       aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
       sFormas:=Copy(sFormas,16,Length(sFormas));
       Inc(iTamanho);
     end;
     sPos       := '00';
     Totalizador:= '00';
     bIndiceTot := False;
     For i:=0 to high(aFormas) do
     Begin
       // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
       // Pois a legenda somente podera ser do mesmo titulo.
       // Ex.
       // 01 &GAVETA                -> Titulos
       // 02    + Recebimento       -> Legendas
       // 03    - Sangria           -> Legendas
       // 04 &Sigaloja              -> Titulos
       // 05    + Entrada Diversas  -> Legendas
       // 06    - Saidas diversas   -> Legendas
       if (Copy(aFormas[i],1,1)='&') and (bIndiceTot = False) then
         Totalizador:= '00';

       //Pegar o codigo do titulo
       if Trim(UpperCase(aFormas[i])) = sTitulo then
       Begin
         Totalizador:= FormataTexto(IntToStr(i + 1),2,0,2);
         bIndiceTot := True;
       End;

       //Pegar o codigo da Legenda
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(sCondicao)) ) and
         ( Totalizador <> '00' ) then
         sPos := FormataTexto(IntToStr(i + 1),2,0,2);
     end;
     Result:=sPos+Totalizador;
   End;
//**********************************************************************************************************
Var
  sRet : String;
  i : Integer;
  aFormas : array of String;
  sFormas : String;
  sPos : String;
  iTamanho : Integer;
  sCondicao : String;
  aPgto : TaString;
  aFormaSupr : TaString;
  sFormaSupr:String;
  sVlrIndiv : String;

begin
  // Tipo = 1 - Verifica se tem troco disponivel
  // Tipo = 2 - Grava o valor informado no Suprimentos
  // Tipo = 3 - Sangra o valor informado
  sRet:=' -';
  sCondicao:= Forma;
  Valor   :=FormataTexto(Valor,12,2,2);
  sRet    :='789ABCD';
  sFormas :='';
  SetLength( aFormas,0 );
  if Tipo = 1 then // Tipo = 1 - Verifica se tem troco disponivel
  Begin
    sRet    :='67';
    For i:= 1 to 2 do
    Begin
      // Lendo os totais das modalidades de pagamento
      sPos     := fFuncEnviaComando( PChar(#27+'.27'+Copy(sRet,i,1)+'}') );
      iTamanho := (Pos('}',sPos)-1) - 7;
      if i=2 then
        sFormas  := sFormas+Copy(sPos,8,48)
      else
        sFormas  := Trim(Copy(sPos,8,iTamanho));

      iTamanho:=Length(aFormas)+1;
      while Trim(sFormas)<>'' do
      Begin
        SetLength( aFormas, iTamanho );
        aFormas[iTamanho-1] := Copy(sFormas,5,12) ;
        sFormas:=Copy(sFormas,17,Length(sFormas));
        Inc(iTamanho);
      end;
    end;

    // Le as condicoes de pagamento
    sRet := LeCondPag;
    sRet := Copy(sRet, 3, Length(sRet));
    MontaArray(sRet,aPgto);
    for i:=0 to Length(aPgto) do
    Begin
      if UpperCase(Trim(aPgto[i]))='DINHEIRO' Then
      Begin
        sPos:=IntToStr(i);
        Break;
      end;
    End;
    if StrToFloat(aFormas[StrToInt(sPos)]) >= StrToFloat(Valor) then
      result := '8'
    else
      result := '9' ;
    Exit;
  End;
  //inserido para montar a string de formas de pagto. da sangria
  If Tipo = 3 then
    Begin
        MontaArray( FormaSupr, aFormaSupr);
        i:=0;
        While i<Length(aFormaSupr) do
        Begin
            sFormaSupr := sFormaSupr+'0'+aFormaSupr[i];
            sVlrIndiv:= FormataTexto(aFormaSupr[i+1],12,2,3);
            sFormaSupr := sFormaSupr+ Space(28-Length(aFormaSupr[i])) + sVlrIndiv;
            Inc(i,2);
        End;
  End;

  sFormas :='DINHEIRO';
  if Trim(Copy(Forma,3,length(Forma)))<>'' then
    sFormas :=Trim(Copy(Forma,3,length(Forma)));

  if (Tipo = 2) and (Trim(Forma)='') then  // Tipo = 2 - Grava o valor informado no Suprimentos
    sCondicao:='FUNDO DE CAIXA';
  if (Tipo = 3) and (Trim(Forma)='') then  // Tipo = 3 - Sangra o valor informado
    sCondicao:='SANGRIA';

  if ( Trim(Copy(Forma,1,2))<>'') and ( Trim(Copy(Total,1,2))<>'') then
    sPos:=Copy(Forma,1,2)+Copy(Total,1,2)
  else
    sPos:=PegaRegistro( sCondicao);

  if (Trim(Copy(Total,1,2))='') And ((Copy(sPos,1,2)='00') Or (Copy(sPos,3,2)='00')) then
  begin
    Application.MessageBox(PChar('Não existe o Totalizador Não-Fiscal "'+sCondicao+
      '" dentro do Título Não-Fiscal "SIGALOJA".'+#13+'Adicione-o após uma Redução Z e antes de realizar uma venda.'),
      'Totalizador Não-Fiscal não encontrado', MB_OK + MB_ICONERROR);
    Result := '1';
    Exit;
  end;

  sRet := fFuncEnviaComando( PChar(#27+'.19' + Copy(sPos,3,2)+ Space(26)+'00}') );
  Result := Status( 1,sRet );
  Sleep(2000);
  if Copy(Result,1,1) = '0' then
  begin
    sRet := fFuncEnviaComando( PChar(#27+'.07' + Copy(sPos,1,2)+Valor+'}') );
    Result := Status( 1,sRet );
    if Copy(Result,1,1) = '0' then
    begin
      Sleep(500);
      if Tipo=2 then
      begin
        Valor := FloatToStrF(StrToFloat(Valor)/100,ffFixed,18,2);
        Pagamento(sFormas+'|'+Valor,'N','');
        Sleep(500);
      end;
    end;
    sRet := fFuncEnviaComando( PChar(#27+'.12N'+sFormaSupr+'}') );
    Sleep(2000);
    Result := Status( 1,sRet );
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda101.FechaCupom( Mensagem:String ):String;
var
  sRet  : String;
  sLinha: string;
  sCmd,sMsg: string;
  iLinha,nX : Integer;
begin
	sMsg := Mensagem;
	sMsg := TrataTags( sMsg );
    // Laço para imprimir toda a mensagem
    iLinha := 0;
    sCmd:='';
    while ( Trim(sMsg)<>'' ) and ( iLinha<9 ) do
      Begin
      sLinha:='';
      // Laço para pegar 40 caracter do Texto
      for nX:= 1 to 40 do
         Begin
         // Caso encontre um CHR(Line Feed) imprime a linha
         If Copy(sMsg,nX,1)= #10 then
            Break;

         sLinha:=sLinha+Copy(sMsg,nX,1);
         end;
      sLinha:=Copy(sLinha+space(40),1,40);
      sCmd:=sCmd+'0'+sLinha;
      sMsg:=Copy(sMsg,nX+1,Length(sMsg));

      inc(iLinha);
      End;
  sRet := EnviaComando( PChar(#27+'.12N'+sCmd+'}') );
  result := Status( 1,sRet );
  // Tempo necessário para aguardar a Finalização do Cupom
  Sleep(4000);
end;

//----------------------------------------------------------------------------
function TImpFiscalSweda101.FechaCupomNaoFiscal: String;
var
  sRet : String;
begin
  sRet := fFuncEnviaComando( PChar(#27+'.12}') );
  result := Status( 1,sRet );
  Sleep( 2000 );
  sRet := fFuncEnviaComando( PChar(#27+'.12}') );
  result := Status( 1,sRet );
end;
//------------------------------------------------------------------------------
function TImpFiscalSweda101.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
 //**********************************************************************************************************
function PegaRegistro( sCondicao, sTitulo:String ):String;
   Var
     sRet       : String;
     i          : Integer;
     aFormas    : array of String;
     sFormas    : String;
     sPos       : String;
     bIndiceTot : Boolean;
     iTamanho   : Integer;
     Totalizador: String;
   Begin
     sRet    :='789ABCD';
     sFormas :='';
     For i:= 1 to 7 do
     Begin
       // Lendo todos as descrições dos registradores.
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
     end;
     sFormas:=Copy(sFormas,31,length(sFormas));

     iTamanho:=1;
     SetLength( aFormas,0 );
     while Trim(sFormas)<>'' do
     Begin
       SetLength( aFormas, iTamanho );
       aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
       sFormas:=Copy(sFormas,16,Length(sFormas));
       Inc(iTamanho);
     end;
     sPos       := '00';
     Totalizador:= '00';
     bIndiceTot := False;
     For i:=0 to high(aFormas) do
     Begin
       // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
       // Pois a legenda somente podera ser do mesmo titulo.
       // Ex.
       // 01 &GAVETA                -> Titulos
       // 02    + Recebimento       -> Legendas
       // 03    - Sangria           -> Legendas
       // 04 &Sigaloja              -> Titulos
       // 05    + Entrada Diversas  -> Legendas
       // 06    - Saidas diversas   -> Legendas
       if (Copy(aFormas[i],1,1)='&') and (bIndiceTot = False) then
         Totalizador:= '00';

       //Pegar o codigo do titulo
//       if Trim(UpperCase(aFormas[i])) = '&SIGALOJA' then
       if Trim(UpperCase(aFormas[i])) = sTitulo then
       Begin
         Totalizador:= FormataTexto(IntToStr(i + 1),2,0,2);
         bIndiceTot := True;
       End;

       //Pegar o codigo da Legenda
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(sCondicao)) ) and
         ( Totalizador <> '00' ) then
         sPos := FormataTexto(IntToStr(i + 1),2,0,2);
     end;
     Result:=sPos+Totalizador;
   End;
//**********************************************************************************************************
Var
  sRet:     String;
  i:        Integer;
  aFormas:  array of String;
  sFormas:  String;
  sPos:     String;
  sCondicao:String;
  sFormaSupr:String;
  aPgto:    TaString;
  iTamanho: Integer;
  nPos:     Integer;
  sVlrIndiv:String;
  aFormaSupr:TaString;
  sNumAnt : String;
  pPath : pChar;
  sPath : String;
  fArquivo : TIniFile;
  sPedido : String;
  sTefPedido : String;
  sCondPagto : String;
  sValorTot  : String;
  sTitulo    : String;
begin
//---- Nesse trecho busca no Windows/System32 o SWEDA.INI com as legendas e as
//---- formas de pagamentos usadas no Pedido.
//---- RECEBER = Legenda não fiscal que fará o registro do Pedido
//---- TEFPEDIDO = Legenda nção fiscal que guardara o pedido feito com tef
//---- CONDICAO = Forma de pagamento dos CNF´s gerados no pedido
//---- Se o arquivo ou as seções não existirem cria com os parâmetros abaixo

  pPath       := Pchar(Replicate('0',100));
  GetSystemDirectory(pPath, 100);
  sPath := StrPas( pPath );
  fArquivo := TIniFile.Create(sPath+'\SWEDA.INI');
  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  If fArquivo.ReadString('Microsiga', 'Titulo', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Titulo', '&SIGALOJA' );
  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondPagto  := fArquivo.ReadString('Microsiga', 'Condicao', '' );
  sTitulo     := fArquivo.ReadString('Microsiga', 'Titulo', '' );

//-----------------------FIM DO SWEDA.INI---------------------------------------

  sRet:=' -';
  Valor   :=FormataTexto(Valor,12,2,2);
  sValorTot := Valor;
  sRet    :='789ABCD';
  sFormas :='';
  SetLength( aFormas,0 );
  sRet    :='67';

  For i:= 1 To 2 Do
  Begin
//----------Inicio da leitura dos totais das modalidades de pagamento-----------
    sPos     := fFuncEnviaComando( PChar(#27+'.27'+Copy(sRet,i,1)+'}') );
    iTamanho := (Pos('}',sPos)-1) - 7;

    If i=2 Then
      sFormas  := sFormas+Copy(sPos,8,48)
    Else
      sFormas  := Trim(Copy(sPos,8,iTamanho));

    iTamanho := Length(aFormas) + 1;

    While Trim( sFormas ) <> '' Do
    Begin
      SetLength( aFormas, iTamanho );
      aFormas[ iTamanho - 1 ] := Copy( sFormas, 5, 12 ) ;
      sFormas := Copy( sFormas, 17, Length( sFormas ) );
      Inc( iTamanho );
    End;
  End;
//-------------Fim da leitura do totais das modalidades de pagamento------------

//-------------Inicio da leitura das modalidades de pagamento-------------------
  sRet := LeCondPag;
  sRet := Copy( sRet, 3, Length( sRet ) );
  MontaArray( sRet, aPgto );

  For i := 0 To Length( aPgto ) Do
  Begin
    If UpperCase( Trim( aPgto[ i ] ) ) = Trim( sCondPagto ) Then
    Begin
      sFormas := sCondPagto;
      Break;
    End;
  End;

  If i > Length( aPgto ) Then
    ShowMessage( 'Forma de pagamento não cadastrada!' );
//-------------Fim da leitura das modalidades de pagamento---------------------

  sPos := PegaRegistro( sPedido, sTitulo ); //Captura o código do titulo e da legenda NF
  Sleep( 1000 );
  //Abre comprovante não fiscal do pedido
  sRet := fFuncEnviaComando( PChar( #27 + '.19' + Copy( sPos, 3, 2 )+ '      }' ) );
  Result := Status( 1, sRet );

  If Copy( Result, 1, 1 ) = '0' Then
  Begin
    Sleep( 3000 );
    //Envia o registro no acumulador não fiscal
    sRet := fFuncEnviaComando( PChar(#27+'.07' + Copy(sPos,1,2)+ Valor + '}') );
    Result := Status( 1,sRet );
    Sleep( 500 );
    Valor := FloattoStrf( StrtoFloat( Valor ) / 100, ffFixed, 18, 2 );
    //Envia a forma de pagamento do CNF do pedido
    sRet := Pagamento( sFormas + '|' + Valor, 'N', '' );
    Sleep(500);

    If Copy( Result, 1, 1 ) = '0' Then
    Begin
      //Fechamento do CNF do Pedido
      sRet := fFuncEnviaComando( PChar( #27 + '.12N' + sFormaSupr + '}' ) );
      Sleep( 2000 );
      Result := Status( 1, sRet );
    End;
  End;

  If Copy( Result, 1, 1) = '0' Then
  Begin
    Sleep( 2000 );
    //Captura o COO para imprimir o texto do PE SCRPED()
    sNumAnt := fFuncEnviaComando( PChar( #27 + '.271}' ) );
    If Copy( Status( 1, sNumAnt ), 1, 1 ) = '0' Then
      sNumAnt := Copy( sNumAnt, 14, 4 )
    Else
    Begin
      Result := '1|';
      Exit;
    End;

    //Procura e define a forma de Pagto.
    For i := 0 To Length( aPgto ) Do
    Begin
      If UpperCase( Trim( aPgto[ i ] ) )= sFormas Then
      Begin
        sPos := IntToStr( i + 1 );
        Break;
      End;
    End;

    If Length( sPos ) = 1 Then
      sPos := '0' + sPos;

    //Abre CNF Vinculado para imprimir o texto do PE SCRPED()
    sRet := fFuncEnviaComando( PChar(#27 + '.1900' + sNumAnt + sPos + '                    01}' ) );
    Result := Status( 1, sRet );

    If copy(Result,1,1) = '0' Then
    Begin
      //Imprime o Texto SCRPED()
      sRet := TextoNaoFiscal( Texto, 1 );
      Result := Status( 1, sRet );
    End;

    If copy(Result,1,1) = '0' Then
      sRet := FechaCupomNaoFiscal;

  End;

  If Tef = 'S' Then
  Begin
    Sleep( 3000 );
    sPos := PegaRegistro( sTefPedido, sTitulo );
    //Abre o CNF para impressão do cupom TEF
    sRet := fFuncEnviaComando( PChar( #27 + '.19' + Copy( sPos, 3, 2 )+ '      }' ) );
    Result := Status( 1,sRet );

    If Copy( Result, 1, 1 ) = '0' Then
    Begin
      Sleep( 3000 );
      //Define a legenda do CNF para impressão do TEF
      sRet := fFuncEnviaComando( PChar( #27 + '.07' + Copy( sPos, 1, 2 )+ sValorTot + '}' ) );
      Result := Status( 1, sRet );
      Sleep( 500 );
      //Define valor e a forma de pagamento do CNF
      Valor := FloattoStrf( StrtoFloat( sValorTot ) / 100, ffFixed, 18, 2 );
      sRet := Pagamento( CondPagTef + '|' + Valor, 'N', '' );
      Sleep( 500 );
      If Copy( Result, 1, 1 ) = '0' Then
      Begin
        sRet := fFuncEnviaComando( PChar( #27 + '.12N' + sFormaSupr + '}' ) );
        Sleep( 2000 );
        Result := Status( 1, sRet );
      End;
    End;
  End;

    fArquivo.Free;
end;



//------------------------------------------------------------
// Propriedades da impressora
procedure TImpFiscalSweda101.AlimentaProperties;
var
  sRet1 : String;
  sRet2 : String;
  sRet3 : String;
  sRet4 : String;
  sRetorno : String;
  sForma : String;
  sLinha : String;
  sAux : String;
  i : Integer;
begin
  // Aliquotas de ICMS
  i:=0;

  Repeat
     sRet1 := fFuncEnviaComando( PChar(#27+'.293}') );
     sComando293 := sRet1;
     i:=i+1;
  until ((copy(sRet1,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet2 := fFuncEnviaComando( PChar(#27+'.294}') );
     sComando294 := sRet2;
     i:=i+1;
  until ((copy(sRet2,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet3 := fFuncEnviaComando( PChar(#27+'.295}') );
     sComando295 := sRet3;
     i:=i+1;
  until ((copy(sRet3,2,1)<> '-') and (i<20));

  i:=0;
  Repeat
     sRet4 := fFuncEnviaComando( PChar(#27+'.296}') );
     i:=i+1;
  until ((copy(sRet4,2,1)<> '-') and (i<20));

  PegaPDV;

  sLinha := '';
  if (copy(Status(1,sRet1),1,1)<>'0') or (copy(Status(1,sRet2),1,1)<>'0') or (copy(Status(1,sRet3),1,1)<>'0') then
  begin
    Aliquotas := sLinha;
    exit;
  end;
  sRetorno := copy(sRet1,49,28) + copy(sRet2,8,49) + copy(sRet3,8,28);
  i := 0;
  while (i<=15) and (Trim(copy(sRetorno,(7*i)+1,7))<>'') do
  begin
    sAux := FloatToStr(StrToFloat(copy(sRetorno,(7*i)+4,4))/100);
    if (FormataTexto(sAux,4,2,2) <> '0000') then
      if copy(sRetorno,(7*i)+1,1) = 'T' then
        sLinha := sLinha + FormataTexto(sAux,4,2,1,'.') + '|';
    i := i + 1;
  end;
  Aliquotas := sLinha;

  // Aliquotas de ISS
  sLinha := '';
  if (copy(Status(1,sRet1),1,1)<>'0') or (copy(Status(1,sRet2),1,1)<>'0') or (copy(Status(1,sRet3),1,1)<>'0') then
  begin
    ISS := sLinha;
    exit;
  end;
  sRetorno := copy(sRet1,49,28) + copy(sRet2,8,49) + copy(sRet3,8,28);
  i := 0;
  while (i<=15) and (Trim(copy(sRetorno,(7*i)+1,7))<>'') do
  begin
    sAux := FloatToStr(StrToFloat(copy(sRetorno,(7*i)+4,4))/100);
    if (FormataTexto(sAux,4,2,2) <> '0000') then
      if copy(sRetorno,(7*i)+1,1) = 'S' then
        sLinha := sLinha + FormataTexto(sAux,4,2,1,'.') + '|';
    i := i + 1;
  end;
  ISS := sLinha;

  // Formas de Pagamento
  sLinha := '';
  if (copy(Status(1,sRet3),1,1)<>'0') or (copy(Status(1,sRet4),1,1)<>'0') then
  begin
    FormasPgto := sLinha;
    exit;
  end;

  sForma := copy(sRet3,36,48) + copy(sRet4,8,112);
  For i:=0 to 9 do
  begin
    if i=0 then
        sAux := Trim(Copy(sForma,2,15))
    else
        sAux := Trim(Copy(sForma,(i*16)+2,15));
    if sAux <> '' then
      sLinha := sLinha + sAux + '|';
  end;
  FormasPgto := sLinha;
end;
//------------------------------------------------------------------------------
function TImpFiscalSweda101.RecebNFis( Totalizador, Valor, Forma:String ): String;
   function PegaRegistro( sCondicao:String):String;
   Var
     sRet : String;
     i : Integer;
     aFormas : array of String;
     sFormas : String;
     sPos : String;
     iTamanho : Integer;
     Totalizador: String;
     sPath      : String;
     fArquivo   : TIniFile;
     sReceb     : String;
   Begin
     sPath := ExtractFilePath(Application.ExeName);
     fArquivo := TIniFile.Create(sPath+'\SIGALOJA.INI');

     // Pegar no SIGALOJA.INI os titulos dos não-fiscais
     If fArquivo.ReadString('SWEDA', 'Tit. Recebimento', '' ) = '' then
       fArquivo.WriteString('SWEDA', 'Tit. Recebimento', 'SIGALOJA' );

     sReceb  := fArquivo.ReadString('SWEDA', 'Tit. Recebimento', '' );
     sReceb := '&' + sReceb;

     sRet    :='789ABCD';
     sFormas :='';
     For i:= 1 to 7 do
      Begin
       // Lendo todos as descrições dos registradores.
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
       end;
      sFormas:=Copy(sFormas,31,length(sFormas));

      iTamanho:=1;
      SetLength( aFormas,0 );
      while Trim(sFormas)<>'' do
          Begin
          SetLength( aFormas, iTamanho );
          aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
          sFormas:=Copy(sFormas,16,Length(sFormas));
          Inc(iTamanho);
          end;
      sPos       := '0';
      Totalizador:= '0';
      For i:=0 to high(aFormas) do
          Begin
          // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
          // Pois a legenda somente podera ser do mesmo titulo.
          // Ex.
          // 04 &SIGALOJA              -> Titulos
          // 05    + FUNDO DE CAIXA    -> Legendas
          // 06    - SANGRIA           -> Legendas
          if (Copy(aFormas[i],1,1)='&') and ( Totalizador = '0' )then
             Totalizador:= '0';

          //Pegar o codigo do titulo
          if Trim(UpperCase(aFormas[i])) = sReceb then
            Totalizador:= FormataTexto(IntToStr(i + 1),2,0,2);

           //Pegar o codigo da Legenda
          if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(sCondicao)) ) and
            ( Totalizador <> '0' ) then
            sPos := FormataTexto(IntToStr(i + 1),2,0,2);
          end;
      Result:=sPos+Totalizador;
   End;
//**********************************************************************************************************
Var
  sRet : String;
 // i : Integer;
  aFormas : array of String;
  //sFormas : String;
  sPos : String;
  //iTamanho : Integer;
  sCondicao : String;
  //aPgto : TaString;

begin
//Tem que escrever no SIGALOJA.INI o acumulador que vai ser utilizado para o recebimento. Ex.:
//[Recebimento Titulos]
//Totalizadores=RECEBIMENTO
//
//Esse totalizador deverá estar abaixo do título &SIGALOJA.
//EX.:
//
// 04 &SIGALOJA              -> Titulos
// 05    + FUNDO DE CAIXA    -> Legendas
// 06    + RECEBIMENTOS      -> Legendas


  // Tipo = 2 - Grava o valor informado no Suprimentos
    Valor   :=FormataTexto(Valor,12,2,2);
    sCondicao:= Forma;
    sRet    :='789ABCD';
    SetLength( aFormas,0 );

    sPos:=PegaRegistro(sCondicao);

    sRet := fFuncEnviaComando( PChar(#27+'.19' + Copy(sPos,3,2)+ '      }') );
    Result := Status( 1,sRet );
    if copy(Result,1,1) = '0' then
    Begin
       Sleep(2000);
       sRet := fFuncEnviaComando( PChar(#27+'.07' + Copy(sPos,1,2)+Valor+'}') );
       Result := Status( 1,sRet );
       Sleep(500);
       Valor   := FloattoStrf(StrtoFloat(Valor)/100,ffFixed,18,2);
       sRet:=Pagamento(Forma+'|'+Valor,'N','');
       if copy(Result,1,1) = '0' then
       Begin
          sRet := fFuncEnviaComando( PChar(#27+'.12N}') );
          Sleep(2000);
          result := Status( 1,sRet );
       End;
    End;

end;

//-----------------------------------------------------------
function TImpFiscalSweda.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
 //**********************************************************************************************************
function PegaRegistro( sCondicao, sTitulo:String ):String;
   Var
     sRet       : String;
     i          : Integer;
     aFormas    : array of String;
     sFormas    : String;
     sPos       : String;
     bIndiceTot : Boolean;
     iTamanho   : Integer;
     Totalizador: String;
   Begin
     sRet    :='789ABCD';
     sFormas :='';
     For i:= 1 to 7 do
     Begin
       // Lendo todos as descrições dos registradores.
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
     end;
     sFormas:=Copy(sFormas,31,length(sFormas));

     iTamanho:=1;
     SetLength( aFormas,0 );
     while Trim(sFormas)<>'' do
     Begin
       SetLength( aFormas, iTamanho );
       aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
       sFormas:=Copy(sFormas,16,Length(sFormas));
       Inc(iTamanho);
     end;
     sPos       := '00';
     Totalizador:= '00';
     bIndiceTot := False;
     For i:=0 to high(aFormas) do
     Begin
       // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
       // Pois a legenda somente podera ser do mesmo titulo.
       // Ex.
       // 01 &GAVETA                -> Titulos
       // 02    + Recebimento       -> Legendas
       // 03    - Sangria           -> Legendas
       // 04 &Sigaloja              -> Titulos
       // 05    + Entrada Diversas  -> Legendas
       // 06    - Saidas diversas   -> Legendas
       if (Copy(aFormas[i],1,1)='&') and (bIndiceTot = False) then
         Totalizador:= '00';

       //Pegar o codigo do titulo
       if Trim(UpperCase(aFormas[i])) = sTitulo then
       Begin
         Totalizador:= FormataTexto(IntToStr(i + 1),2,0,2);
         bIndiceTot := True;
       End;

       //Pegar o codigo da Legenda
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(sCondicao)) ) and
         ( Totalizador <> '00' ) then
         sPos := FormataTexto(IntToStr(i + 1),2,0,2);
     end;
     Result:=sPos+Totalizador;
   End;
//**********************************************************************************************************
Var
  sRet:     String;
  i:        Integer;
  aFormas:  array of String;
  sFormas:  String;
  sPos:     String;
  sCondicao:String;
  sFormaSupr:String;
  aPgto:    TaString;
  iTamanho: Integer;
  nPos:     Integer;
  sVlrIndiv:String;
  aFormaSupr:TaString;
  sNumAnt : String;
  pPath : pChar;
  sPath : String;
  fArquivo : TIniFile;
  sPedido : String;
  sTefPedido : String;
  sCondPagto : String;
  sValorTot  : String;
  sTitulo    : String;
begin
//---- Nesse trecho busca no Windows/System32 o SWEDA.INI com as legendas e as
//---- formas de pagamentos usadas no Pedido.
//---- RECEBER = Legenda não fiscal que fará o registro do Pedido
//---- TEFPEDIDO = Legenda nção fiscal que guardara o pedido feito com tef
//---- CONDICAO = Forma de pagamento dos CNF´s gerados no pedido
//---- Se o arquivo ou as seções não existirem cria com os parâmetros abaixo

  pPath       := Pchar(Replicate('0',100));
  GetSystemDirectory(pPath, 100);
  sPath := StrPas( pPath );
  fArquivo := TIniFile.Create(sPath+'\SWEDA.INI');
  If fArquivo.ReadString('Microsiga', 'Pedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Pedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'TefPedido', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'TefPedido', 'RECEBER' );

  If fArquivo.ReadString('Microsiga', 'Condicao', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Condicao', 'A Vista' );

  If fArquivo.ReadString('Microsiga', 'Titulo', '' ) = '' then
    fArquivo.WriteString('Microsiga', 'Titulo', '&MICROSIGA' );
  sPedido     := fArquivo.ReadString('Microsiga', 'Pedido', '' );
  sTefPedido  := fArquivo.ReadString('Microsiga', 'TefPedido', '' );
  sCondPagto  := fArquivo.ReadString('Microsiga', 'Condicao', '' );
  sTitulo     := fArquivo.ReadString('Microsiga', 'Titulo', '' );

//-----------------------FIM DO SWEDA.INI---------------------------------------

  sRet:=' -';
  Valor   :=FormataTexto(Valor,12,2,2);
  sValorTot := Valor;
  sRet    :='789ABCD';
  sFormas :='';
  SetLength( aFormas,0 );
  sRet    :='67';

  For i:= 1 To 2 Do
  Begin
//----------Inicio da leitura dos totais das modalidades de pagamento-----------
    sPos     := fFuncEnviaComando( PChar(#27+'.27'+Copy(sRet,i,1)+'}') );
    iTamanho := (Pos('}',sPos)-1) - 7;

    If i=2 Then
      sFormas  := sFormas+Copy(sPos,8,48)
    Else
      sFormas  := Trim(Copy(sPos,8,iTamanho));

    iTamanho := Length(aFormas) + 1;

    While Trim( sFormas ) <> '' Do
    Begin
      SetLength( aFormas, iTamanho );
      aFormas[ iTamanho - 1 ] := Copy( sFormas, 5, 12 ) ;
      sFormas := Copy( sFormas, 17, Length( sFormas ) );
      Inc( iTamanho );
    End;
  End;
//-------------Fim da leitura do totais das modalidades de pagamento------------

//-------------Inicio da leitura das modalidades de pagamento-------------------
  sRet := LeCondPag;
  sRet := Copy( sRet, 3, Length( sRet ) );
  MontaArray( sRet, aPgto );

  For i := 0 To Length( aPgto ) Do
  Begin
    If UpperCase( Trim( aPgto[ i ] ) ) = Trim( sCondPagto ) Then
    Begin
      sFormas := sCondPagto;
      Break;
    End;
  End;

  If i > Length( aPgto ) Then
    ShowMessage( 'Forma de pagamento não cadastrada!' );
//-------------Fim da leitura das modalidades de pagamento---------------------

  sPos := PegaRegistro( sPedido, sTitulo ); //Captura o código do titulo e da legenda NF
  Sleep( 1000 );
  //Abre comprovante não fiscal do pedido
  sRet := fFuncEnviaComando( PChar( #27 + '.19' + Copy( sPos, 3, 2 )+ '      }' ) );
  Result := Status( 1, sRet );

  If Copy( Result, 1, 1 ) = '0' Then
  Begin
    Sleep( 3000 );
    //Envia o registro no acumulador não fiscal
    sRet := fFuncEnviaComando( PChar(#27+'.07' + Copy(sPos,1,2)+Valor+'}') );
    Result := Status( 1,sRet );
    Sleep( 500 );
    Valor := FloattoStrf( StrtoFloat( Valor ) / 100, ffFixed, 18, 2 );
    //Envia a forma de pagamento do CNF do pedido
    sRet := Pagamento( sFormas + '|' + Valor, 'N', '' );
    Sleep(500);

    If Copy( Result, 1, 1 ) = '0' Then
    Begin
      //Fechamento do CNF do Pedido
      sRet := fFuncEnviaComando( PChar( #27 + '.12SN' + sFormaSupr + '}' ) );
      Sleep( 2000 );
      Result := Status( 1, sRet );
    End;
  End;

  If Copy( Result, 1, 1) = '0' Then
  Begin
    Sleep( 2000 );
    //Captura o COO para imprimir o texto do PE SCRPED()
    sNumAnt := fFuncEnviaComando( PChar( #27 + '.271}' ) );
    If Copy( Status( 1, sNumAnt ), 1, 1 ) = '0' Then
      sNumAnt := Copy( sNumAnt, 14, 4 )
    Else
    Begin
      Result := '1|';
      Exit;
    End;

    //Procura e define a forma de Pagto.
    For i := 0 To Length( aPgto ) Do
    Begin
      If UpperCase( Trim( aPgto[ i ] ) )= sFormas Then
      Begin
        sPos := IntToStr( i + 1 );
        Break;
      End;
    End;

    If Length( sPos ) = 1 Then
      sPos := '0' + sPos;

    //Abre CNF Vinculado para imprimir o texto do PE SCRPED()
    sRet := fFuncEnviaComando( PChar(#27 + '.1900' + sNumAnt+sPos + '}' ) );
    Result := Status( 1, sRet );

    If copy(Result,1,1) = '0' Then
    Begin
      //Imprime o Texto SCRPED()
      sRet := TextoNaoFiscal( Texto, 1 );
      Result := Status( 1, sRet );
    End;

    If copy(Result,1,1) = '0' Then
      sRet := FechaCupomNaoFiscal;

  End;

  If Tef = 'S' Then
  Begin
    Sleep( 3000 );
    sPos := PegaRegistro( sTefPedido, sTitulo );
    //Abre o CNF para impressão do cupom TEF
    sRet := fFuncEnviaComando( PChar( #27 + '.19' + Copy( sPos, 3, 2 )+ '      }' ) );
    Result := Status( 1,sRet );

    If Copy( Result, 1, 1 ) = '0' Then
    Begin
      Sleep( 3000 );
      //Define a legenda do CNF para impressão do TEF
      sRet := fFuncEnviaComando( PChar( #27 + '.07' + Copy( sPos, 1, 2 )+ sValorTot + '}' ) );
      Result := Status( 1, sRet );
      Sleep( 500 );
      //Define valor e a forma de pagamento do CNF
      Valor := FloattoStrf( StrtoFloat( sValorTot ) / 100, ffFixed, 18, 2 );
      sRet := Pagamento( CondPagTef + '|' + Valor, 'N', '' );
      Sleep( 500 );
      If Copy( Result, 1, 1 ) = '0' Then
      Begin
        sRet := fFuncEnviaComando( PChar( #27 + '.12SN' + sFormaSupr + '}' ) );
        Sleep( 2000 );
        Result := Status( 1, sRet );
      End;
    End;
  End;

    fArquivo.Free;
end;

//----------------------------------------------------------------------------
Function TImpFiscalSweda1A.GravaCondPag( condicao:string ) : String;
var sPagto, sRet, sLinha : String;
    aPagto : TaString;
    iCont, iLenPag : Integer;
begin

  // No caso desta versão da Sweda, se o primeiro caracter da string
  // condicao for igual a "=" será acumulado na legenda não-fiscal "TROCO
  // DE CHEQUE" ou se o primeiro caracter for igual a "#" será acumulado na
  // legenda não-fiscal "CONTRA-VALE".

  // Nessa versão a programação das Modalidades de Pagamento só pode ser feita
  // em Modo Intervenção

  sRet := fFuncEnviaComando( PChar(#27+'.28}') );
  if copy(Status(1,sRet),1,1)= '0' then
  begin
        If Copy (sRet,59,16)<>'MODO INTERVENCAO' then
        begin
                Showmessage ('Essa operação só é possível quando a Impressora Fiscal está em Modo Intervenção Técnica.');
                result := Status(1,sRet);
                exit;
        end;
  end;


  // Monta vetor com formas existentes
  sPagto   := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  iLenPag := length( aPagto ) - 1;
  result  := '0';

  // Acrescenta os 15 espacos obrigatorios
  for iCont := 0 to iLenPag do
    aPagto[ iCont ] := aPagto[ iCont ] + Space( 15 - Length( aPagto[ iCont ] ) );

  if Length( condicao ) < 15 then condicao := condicao + Space( 15 - length(condicao) );

  // Verifica se já existe a forma de pagamento
  for iCont := 0 to iLenPag do
    if UpperCase( aPagto[ iCont ] ) = UpperCase( condicao ) then
    begin
      ShowMessage( 'Já existe a condição de pagamento: ' + condicao );
      result := '4|';
      exit;
    end;

  // Se o contador for igual ao total de formas de pagamento, já tem o total de formas
  if (iLenPag + 1) = 10 then
  begin
    ShowMessage( 'Sem espaço em memória para armazenar a nova forma de pagamento.' );
    result := '6|';
  end;

  // Monta linha para mandar
  sLinha := '';
  for iCont := 0 to iLenPag do
    sLinha := sLinha + 'S'+UpperCase( Copy(aPagto[ iCont ],1,15) );

  sLinha := sLinha + 'S' +condicao;

  if copy(result,1,1) = '0' then
  begin
    // Grava nova forma de pagamento.
    sRet := EnviaComando( PChar(#27+'.39' + sLinha + '}' ) );
    result := Status(1,sRet);
  end;

end;

//----------------------------------------------------------------------------
function TImpFiscalSweda1A.ReImpCupomNaoFiscal( Texto:String ):String;
var
  sRet: String;
  fim, indice, j : integer;
  slinha: PChar;
begin
  sRet := EnviaComando( PChar(#27+'.13S'+'}') );

  If Copy(Status( 1, sRet ),1,1) = '0' then
  Begin
       If Length(texto)>0 then
       begin
           Repeat
                fim:=Length(texto);
                If Pos(#10,Copy(Texto, 1, 40))>0 then
                begin
                    indice:=Pos(#10,Copy(Texto, 1, 40));
                    slinha:= Pchar(Copy(Texto, 1, indice-1));
                    Texto:= Copy(Texto,indice+1,fim);
                end
                else
                begin
                    sLinha:=Pchar(Copy(Texto,1,40));
                    Texto:=Copy(Texto,41,fim);
                end;
                j:=1;
                Repeat
                    sRet := fFuncEnviaComando( PChar(#27+'.080'+sLinha+'}') );
                    j:=j+1;
                Until (Status(1,sRet)='0') or (j<4);
           until  Length(texto)< 2;
       end;

    result := Status( 1,sRet );
  end
  else
      Result:='1';

end;

//----------------------------------------------------------------------------
Function TImpFiscalSweda15.GravaCondPag( condicao:string ) : String;
var sPagto, sRet, sLinha : String;
    aPagto : TaString;
    iCont, iLenPag : Integer;
begin

  // No caso desta versão da Sweda, se o primeiro caracter da string
  // condicao for igual a "=" será acumulado na legenda não-fiscal "TROCO
  // DE CHEQUE" ou se o primeiro caracter for igual a "#" será acumulado na
  // legenda não-fiscal "CONTRA-VALE".

  // Monta vetor com formas existentes
  // Monta vetor com formas existentes
  sPagto   := LeCondPag;
  MontaArray( copy(sPagto,2,Length(sPagto)),aPagto );

  iLenPag := length( aPagto ) - 1;
  result  := '0';

  // Acrescenta os 15 espacos obrigatorios
  for iCont := 0 to iLenPag do
    aPagto[ iCont ] := aPagto[ iCont ] + Space( 15 - Length( aPagto[ iCont ] ) );

  if Length( condicao ) < 15 then condicao := condicao + Space( 15 - length(condicao) );

  // Verifica se já existe a forma de pagamento
  for iCont := 0 to iLenPag do
    if UpperCase( aPagto[ iCont ] ) = UpperCase( condicao ) then
    begin
      ShowMessage( 'Já existe a condição de pagamento: ' + condicao );
      result := '4|';
      exit;
    end;

  // Se o contador for igual ao total de formas de pagamento, já tem o total de formas
  if (iLenPag + 1) = 10 then
  begin
    ShowMessage( 'Sem espaço em memória para armazenar a nova forma de pagamento.' );
    result := '6|';
  end;

  // Monta linha para mandar
  sLinha := '';
  for iCont := 0 to iLenPag do
    sLinha := sLinha + 'S'+UpperCase( Copy(aPagto[ iCont ],1,15) );

  sLinha := sLinha + 'S' +condicao;

  if copy(result,1,1) = '0' then
  begin
    // Grava nova forma de pagamento.
    sRet := EnviaComando( PChar(#27+'.39' + sLinha + '}' ) );
    result := Status(1,sRet);
  end;
end;
//------------------------------------------------------------------------------
function TImpFiscalSweda9000_17.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
var
  sRet : String;
  sNumAnt : String;
  i : Integer;
  aFormas : array of String;
  sFormas : String;
  sPos : String;
  sPosTot : String;
  iPos : Integer;
  iTamanho : Integer;
  bTotalizadorIsNum : Boolean;
  sTotPad : String;
  sTotFormaPagto : String;
  sBuffer : String;
begin
  If Trim(Totalizador)='' then
     Totalizador:='SIGALOJA';

  // Pegando o numero do ultimo cupom impresso
  sNumAnt := fFuncEnviaComando( PChar(#27+'.271}') );

  if Copy( Status(1,sNumAnt),1,1 ) = '0' then
    sNumAnt := copy(sNumAnt,14,4)
  else
  begin
    result := '1|';
    exit;
  end;
  // Monta o array aFormas com as condicoes de pagamento do cupom fiscal
  sRet := LeCondPag;
  sRet := Copy(sRet, 3, Length(sRet));
  iTamanho := 0;
  While (Pos('|', sRet) > 0) do
  begin
    iTamanho := iTamanho + 1;
    SetLength( aFormas, iTamanho );
    iPos := Pos('|', sRet);
    sFormas := Copy(sRet, 1, iPos-1);
    aFormas[iTamanho-1] := sFormas ;
    sRet := Copy(sRet, iPos+1, Length(sRet));
  end;
  // Verificando qual o codigo da condicao de pagamento utilizado
  sPos := '0';
  For i:=0 to Length(aFormas)-1 do
    if UpperCase(Trim(aFormas[i])) = UpperCase(Trim(Condicao)) then
      sPos := IntToStr(i + 1);
  if length(sPos) < 2 then
    sPos := '0' + sPos;
  if sPos = '00' then
  begin
    ShowMessage('A finalizadora '+Condicao+' não foi cadastrada no ECF.');
    result := '1|';
    exit;
  end;
  // A diferença entre a 1.0 e a 1.A é que a 1.A para fazer cupom vinculado,
  // a finalizadora deve ter a FLAG de VINCULAÇÃO como 'S'.
  if Copy(sVinculado, StrToInt(sPos), 1) = 'N' then
  begin
    ShowMessage('A finalizadora '+Condicao+' não foi cadastrada como VINCULADA no ECF.');
    result := '1|';
    exit;
  end;
  // Abrindo cupom nao fiscal vinculado '00'
  sRet := fFuncEnviaComando( PChar(#27+'.1900'+sNumAnt+sPos+'                    01}') );
  result := Status( 1,sRet );

  if copy(result,1,1) = '1' then  // Impressao do Cupom nao fiscal nao vinculado
    Begin
    sTotFormaPagto := sPos;
    sRet:=' -';
    Valor   :=FormataTexto(Valor,12,2,2);
    sRet    :='789ABCD';
    sFormas :='';
    For i:= 1 to 7 do
       Begin
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
       end;
    sFormas:=Copy(sFormas,31,length(sFormas));

    iTamanho:=1;
    SetLength( aFormas,0 );
    while Trim(sFormas)<>'' do
       Begin
        SetLength( aFormas, iTamanho );
        aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
        sFormas:=Copy(sFormas,16,Length(sFormas));
        Inc(iTamanho);
        end;

    Try
      StrToInt( Totalizador );
      bTotalizadorIsNum := True;
    Except
      bTotalizadorIsNum := False;
    End;
    sPos       := '0';
    sPosTot    := '0';
    For i:=0 to high(aFormas) do
       Begin
        // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
        // Pois a legenda somente podera ser do mesmo titulo.
        // Ex.
        // 01 &GAVETA                -> Titulos
        // 02    + Recebimento       -> Legendas
        // 03    - Sangria           -> Legendas
        // 04 &Sigaloja              -> Titulos
        // 05    + Entrada Diversas  -> Legendas
        // 06    - Saidas diversas   -> Legendas

       If bTotalizadorIsNum then
          sPosTot  := Totalizador
       Else
         //Pegar o codigo do titulo
         if Trim(UpperCase(aFormas[i])) = '&'+Trim(UpperCase(Totalizador)) then
            sPosTot:= FormataTexto(IntToStr(i + 1),2,0,2);

       //Pegar o codigo da Legenda
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(Condicao)) ) and
          ( sPosTot <> '0' ) then
          sPos := FormataTexto(IntToStr(i + 1),2,0,2);
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = 'FUNDO DE CAIXA') then
          sTotPad := FormataTexto(IntToStr(i + 1),2,0,2);
       end;

    // Se não encontrar a forma solicitada, cria o cupom como 'FUNDO DE CAIXA'
    If sPos = '0' then
      sPos := sTotPad;

    // Abre o cupom não vinculado
    sBuffer := Space(128);
    sRet := EnviaComandoEspera( PChar(#27+'.19' + sPosTot + '      }'), sBuffer );
    If sRet = '0' then
    begin
      // Faz o recebimento não fiscal
      sBuffer := Space(128);
      sRet := EnviaComandoEspera( PChar(#27+'.07' + sPos + Valor + '}'), sBuffer, 3 );
      If sRet = '0' then
      begin
        // Totaliza o cupom
        sBuffer := Space(128);
        sRet := EnviaComandoEspera( PChar(#27+'.10'+sTotFormaPagto+Valor+'}'), sBuffer, 3 );
        If sRet = '0' then
        begin
          // Fecha o cupom indicando que haverá um vinculado
          sBuffer := Space(128);
          sRet := EnviaComandoEspera( PChar(#27+'.12N}'), sBuffer, 3 );
          If sRet = '0' then
          begin
            sBuffer := Space(128);
            sRet := EnviaComandoEspera( PChar(#27+'.271}'), sBuffer, 10 );
            If sRet = '0' then
            begin
              sNumAnt := copy( sBuffer, 14, 4 );
              sBuffer := Space(128);
              sRet := EnviaComandoEspera( PChar(#27+'.1900'+sNumAnt+sTotFormaPagto+'                    01}'), sBuffer, 10 );
            end;
          end;
        end;
      end;
    end;

    result := Status( 1, sBuffer );
  end;



end;
//------------------------------------------------------------------------------
function TImpFiscalSweda9000_17.Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
//**********************************************************************************************************
   function PegaRegistro( sCondicao:String ):String;
   Var
     sRet       : String;
     i          : Integer;
     aFormas    : array of String;
     sFormas    : String;
     sPos       : String;
     bIndiceTot : Boolean;
     iTamanho   : Integer;
     Totalizador: String;
     sPath      : String;
     fArquivo   : TIniFile;
     sSangria   : String;
     sTroco     : String;
     sReceb     : String;
     sTitulo    : String;

   Begin
     sPath := ExtractFilePath(Application.ExeName);
     fArquivo := TIniFile.Create(sPath+'\SIGALOJA.INI');

     // Pegar no SIGALOJA.INI os titulos dos não-fiscais
     If fArquivo.ReadString('SWEDA', 'Tit. Sangria', '' ) = '' then
       fArquivo.WriteString('SWEDA', 'Tit. Sangria', 'SIGALOJA' );

     If fArquivo.ReadString('SWEDA', 'Tit. Troco', '' ) = '' then
       fArquivo.WriteString('SWEDA', 'Tit. Troco', 'SIGALOJA' );

     If fArquivo.ReadString('SWEDA', 'Tit. Recebimento', '' ) = '' then
       fArquivo.WriteString('SWEDA', 'Tit. Recebimento', 'SIGALOJA' );

     sSangria     := fArquivo.ReadString('SWEDA', 'Tit. Sangria', '' );
     sTroco  := fArquivo.ReadString('SWEDA', 'Tit. Troco', '' );
     sReceb  := fArquivo.ReadString('SWEDA', 'Tit. Recebimento', '' );

     If sCondicao = 'FUNDO DE CAIXA' then
       sTitulo := '&' + sTroco
     Else
       sTitulo := '&' + sSangria;

     sRet    :='789ABCD';
     sFormas :='';
     For i:= 1 to 7 do
     Begin
       // Lendo todos as descrições dos registradores.
       sPos     := fFuncEnviaComando( PChar(#27+'.29'+Copy(sRet,i,1)+'}') );
       iTamanho := (Pos('}',sPos)-1) - 7;
       sFormas  := sFormas+Copy(sPos,8,iTamanho);
     end;
     sFormas:=Copy(sFormas,31,length(sFormas));

     iTamanho:=1;
     SetLength( aFormas,0 );
     while Trim(sFormas)<>'' do
     Begin
       SetLength( aFormas, iTamanho );
       aFormas[iTamanho-1] := Copy(sFormas,1,15) ;
       sFormas:=Copy(sFormas,16,Length(sFormas));
       Inc(iTamanho);
     end;
     sPos       := '00';
     Totalizador:= '00';
     bIndiceTot := False;
     For i:=0 to high(aFormas) do
     Begin
       // Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.
       // Pois a legenda somente podera ser do mesmo titulo.
       // Ex.
       // 01 &GAVETA                -> Titulos
       // 02    + Recebimento       -> Legendas
       // 03    - Sangria           -> Legendas
       // 04 &Sigaloja              -> Titulos
       // 05    + Entrada Diversas  -> Legendas
       // 06    - Saidas diversas   -> Legendas
       if (Copy(aFormas[i],1,1)='&') and (bIndiceTot = False) then
         Totalizador:= '00';

       //Pegar o codigo do titulo
       if Trim(UpperCase(aFormas[i])) = sTitulo then
       Begin
         Totalizador:= FormataTexto(IntToStr(i + 1),2,0,2);
         bIndiceTot := True;
       End;

       //Pegar o codigo da Legenda
       if ( Trim(UpperCase(copy(aFormas[i],2,15))) = Trim(UpperCase(sCondicao)) ) and
         ( Totalizador <> '00' ) then
         sPos := FormataTexto(IntToStr(i + 1),2,0,2);
     end;
     Result:=sPos+Totalizador;
   End;
//**********************************************************************************************************
Var
  sRet : String;
  i : Integer;
  aFormas : array of String;
  sFormas : String;
  sPos : String;
  iTamanho : Integer;
  sCondicao : String;
  aPgto : TaString;
  aFormaSupr : TaString;
  sFormaSupr:String;
  sVlrIndiv : String;

begin
  // Tipo = 1 - Verifica se tem troco disponivel
  // Tipo = 2 - Grava o valor informado no Suprimentos
  // Tipo = 3 - Sangra o valor informado
  sRet:=' -';
  sCondicao:= Forma;
  Valor   :=FormataTexto(Valor,12,2,2);
  sRet    :='789ABCD';
  sFormas :='';
  SetLength( aFormas,0 );
  if Tipo = 1 then // Tipo = 1 - Verifica se tem troco disponivel
  Begin
    sRet    :='67';
    For i:= 1 to 2 do
    Begin
      // Lendo os totais das modalidades de pagamento
      sPos     := fFuncEnviaComando( PChar(#27+'.27'+Copy(sRet,i,1)+'}') );
      iTamanho := (Pos('}',sPos)-1) - 7;
      if i=2 then
        sFormas  := sFormas+Copy(sPos,8,48)
      else
        sFormas  := Trim(Copy(sPos,8,iTamanho));

      iTamanho:=Length(aFormas)+1;
      while Trim(sFormas)<>'' do
      Begin
        SetLength( aFormas, iTamanho );
        aFormas[iTamanho-1] := Copy(sFormas,5,12) ;
        sFormas:=Copy(sFormas,17,Length(sFormas));
        Inc(iTamanho);
      end;
    end;

    // Le as condicoes de pagamento
    sRet := LeCondPag;
    sRet := Copy(sRet, 3, Length(sRet));
    MontaArray(sRet,aPgto);
    for i:=0 to Length(aPgto) do
    Begin
      if UpperCase(Trim(aPgto[i]))='DINHEIRO' Then
      Begin
        sPos:=IntToStr(i);
        Break;
      end;
    End;
    if StrToFloat(aFormas[StrToInt(sPos)]) >= StrToFloat(Valor) then
      result := '8'
    else
      result := '9' ;
    Exit;
  End;
  //inserido para montar a string de formas de pagto. da sangria
  If Tipo = 3 then
    Begin
        MontaArray( FormaSupr, aFormaSupr);
        i:=0;
        While i<Length(aFormaSupr) do
        Begin
            sFormaSupr := sFormaSupr+'0'+aFormaSupr[i];
            sVlrIndiv:= FormataTexto(aFormaSupr[i+1],12,2,3);
            sFormaSupr := sFormaSupr+ Space(28-Length(aFormaSupr[i])) + sVlrIndiv;
            Inc(i,2);
        End;
  End;

  sFormas :='DINHEIRO';
  if Trim(Copy(Forma,3,length(Forma)))<>'' then
    sFormas :=Trim(Copy(Forma,3,length(Forma)));

  if (Tipo = 2) and (Trim(Forma)='') then  // Tipo = 2 - Grava o valor informado no Suprimentos
    sCondicao:='FUNDO DE CAIXA';
  if (Tipo = 3) and (Trim(Forma)='') then  // Tipo = 3 - Sangra o valor informado
    sCondicao:='SANGRIA';

  if ( Trim(Copy(Forma,1,2))<>'') and ( Trim(Copy(Total,1,2))<>'') then
    sPos:=Copy(Forma,1,2)+Copy(Total,1,2)
  else
    sPos:=PegaRegistro( sCondicao);

  if (Trim(Copy(Total,1,2))='') And ((Copy(sPos,1,2)='00') Or (Copy(sPos,3,2)='00')) then
  begin
    Application.MessageBox(PChar('Não existe o Totalizador Não-Fiscal "'+sCondicao+
      '" dentro do Título Não-Fiscal "SIGALOJA".'+#13+'Adicione-o após uma Redução Z e antes de realizar uma venda.'),
      'Totalizador Não-Fiscal não encontrado', MB_OK + MB_ICONERROR);
    Result := '1';
    Exit;
  end;

  sRet := fFuncEnviaComando( PChar(#27+'.19' + Copy(sPos,3,2)+ Space(26)+'00}') );
  Result := Status( 1,sRet );
  Sleep(2000);
  if Copy(Result,1,1) = '0' then
  begin
    sRet := fFuncEnviaComando( PChar(#27+'.07' + Copy(sPos,1,2)+Valor+'}') );
    Result := Status( 1,sRet );
    if Copy(Result,1,1) = '0' then
    begin
      Sleep(500);
      if Tipo=2 then
      begin
        Valor := FloatToStrF(StrToFloat(Valor)/100,ffFixed,18,2);
        Pagamento(sFormas+'|'+Valor,'N','');
        Sleep(500);
      end;
    end;
    sRet := fFuncEnviaComando( PChar(#27+'.12N'+sFormaSupr+'}') );
    Sleep(2000);
    Result := Status( 1,sRet );
  end;

end;
//------------------------------------------------------------------------------

function TCMC7_Sweda.Abrir( sPorta, sMensagem:String ): String;
var bRet: boolean;
begin
  sCMC7Porta:= sPorta;
  bRet := (Copy(OpenSweda( sPorta ),1,1) = '0');
  If bRet = True then
        Result:= '0'
  Else
        Result:= '0';
end;

//---------------------------------------------------------------------------
function TCMC7_Sweda.Fechar : String;
begin
  Result := CloseSweda ( sCMC7Porta );
end;

//---------------------------------------------------------------------------
function TCMC7_Sweda.LeDocumento : String;
var sRet : string;
begin
  sRet := EnviaComando( PChar(#27+'.492'+'}') );      // Leitura Física com Remoção do cheque

  If Copy(sRet,1,2) = '.{' then
        Result:= '0|'+ StrTran(Copy(sRet,3,115),' ','')
  Else
        Result:= '1';

  sRet := EnviaComando( PChar(#27+'.493'+'}') );      // Limpeza do sensor
end;

//----------------------------------------------------------------------------
function TCMC7_Sweda.LeDocCompleto : String;
var sRet : string;
begin
  sRet := EnviaComando( PChar(#27+'.492'+'}') );      // Leitura Física com Remoção do cheque

  If Copy(sRet,1,2) = '.{' then
        Result:= '0|'+ Trim(Copy(sRet,3,Pos('}',sRet)-3))
  Else
        Result:= '1';
end;

//----------------------------------------------------------------------------
Function TrataTags( Mensagem : String ) : String;
var
  cMsg : String;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;



//----------------------------------------------------------------------------
function TImpFiscalSweda.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization

  RegistraImpressora('SWEDA IFS - V0.30'     , TImpFiscalSweda         , 'BRA', ' ');
  RegistraImpressora('SWEDA IFS - V1.00'     , TImpFiscalSweda100      , 'BRA', ' ');
  RegistraImpressora('SWEDA IFS - II V1.00'  , TImpFiscalSwedaII100    , 'BRA', ' ');
  RegistraImpressora('SWEDA IFS - V1.A'      , TImpFiscalSweda1A       , 'BRA', ' ');
  RegistraImpressora('SWEDA IFS - V1.01'     , TImpFiscalSweda101      , 'BRA', ' ');
  RegistraImpressora('SWEDA IFS II - V1.01'  , TImpFiscalSweda101      , 'BRA', ' ');
  RegistraImpressora('SWEDA IFS 9000 - V1.0' , TImpFiscalSweda9000_10  , 'BRA', ' ');
  RegistraImpressora('SWEDA IFS 9000 - V1.2' , TImpFiscalSweda9000_10  , 'BRA', ' ');     //9000 II V1.2 - Imprime cheques (eu tentei colocar o nome completo mas o sistema não aceita!)
  RegistraImpressora('SWEDA IFS 9000I - V1.7', TImpFiscalSweda9000_17  , 'BRA', '381202');
  RegistraImpressora('SWEDA IFS - V1.5'      , TImpFiscalSweda15       , 'BRA', ' ');
  RegistraImpressora('SWEDA IFS II - V1.5'   , TImpFiscalSweda15       , 'BRA', ' ');
  RegistraImpressora('SWEDA 7000 - V1.6'     , TImpFiscalSweda16       , 'BRA', '380706');
  RegistraImpressora('SWEDA 7000II - V1.6'   , TImpFiscalSweda16       , 'BRA', '380906');
  RegistraImpCheque ('SWEDA IFS - V0.30'    , TImpChequeSweda      , 'BRA');
  RegistraImpCheque ('SWEDA IFS II - V1.00' , TImpChequeSwedaII100 , 'BRA');
  RegistraImpCheque ('SWEDA IFS II - V1.01' , TImpChequeSwedaII100 , 'BRA');
  RegistraImpCheque ('SWEDA IFS II - V1.5'  , TImpChequeSwedaII100 , 'BRA');
  RegistraImpCheque ('SWEDA IFS 9000 - V1.0', TImpChequeSwedaII100 , 'BRA');
  RegistraImpCheque ('SWEDA IFS 9000 - V1.2', TImpChequeSwedaII100 , 'BRA');   //9000 II - Imprime cheques
  RegistraImpCheque ('SWEDA 7000II - V1.6'  , TImpChequeSwedaII100 , 'BRA');
  RegistraCMC7('CMC7 SWEDA', TCMC7_Sweda, 'BRA' );

//------------------------------------------------------------------------------
end.

