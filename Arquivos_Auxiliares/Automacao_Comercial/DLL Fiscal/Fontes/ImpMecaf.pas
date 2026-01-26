unit ImpMecaf;

interface

uses
  Dialogs, ImpFiscMain, ImpCheqMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms;

Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Mecaf
///
  TImpMecaf = class(TImpressoraFiscal)
  private
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function AbreEcf:String; override;
    function FechaEcf:String; override;
    function LeituraX:String; override;
    function ReducaoZ(MapaRes:String):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function PegaPDV:String; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function LeCondPag:String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String; Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function Suprimento( Tipo:Integer; Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String):String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function Gaveta:String; override;
    function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;
    function PegaSerie:String; override;
    function GravaCondPag( Condicao:String ):String; override;
    procedure AlimentaProperties; override;
    function ImpostosCupom(Texto: String): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd , sBinario : String  ):String; override;
    function TotalizadorNaoFiscal( Numero,Descricao:String ):String; override;
    function LeTotNFisc:String; override;
    function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String) : String; override;
    function DownMF(sTipo, sInicio, sFinal : String):String; override;
    function RedZDado( MapaRes : String):String; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
    function ImpTxtFis(Texto : String) : String; Override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenMecaf( sPorta:String ) : String;
Function CloseMecaf : String;
Function ArqIniMecaf( sPorta:String ):Boolean;
Function TrataRetornoMecaf( var iRet:Integer;nChar:Integer=0 ):String;
Function MsgErroMecaf( iRet:Integer ):String;
Function TrataTags( Mensagem : String ) : String;

//----------------------------------------------------------------------------
implementation

   { Constantes globais  }
Const
  CIF_OK            = 0;        // Sucesso
  CIF_OK_CUPNF      =	3;	      // Função executada com sucesso .Abrindo Cupom Rel Gerencial
  CIF_OK_CANCCUP    = 2 ;	      // Função executada com sucesso. Cancelando Cupom
  CIF_OK_PPAPEL     = 1;	      // Função executada com sucesso. Detectado pouco papel

  CIF_ERR           = -84;      // Falha Geral
  CIF_EMEXECUCAO    = -85;      // Comando nao recebido pelo ECF
  CIF_ERR_CONFIG    = -86;      // Erro no Cif.ini
  CIF_ERR_SERIAL    = -87;      // Falha na abertura da serial
  CIF_ERR_SYS       = -88;      // Erro na alocacao de recursos do windows.
  CIF_ERR_ANSWER    = -89;      // Retorno nao identificado
  CIF_ERR_READSER   = -90;      // Erro de TimeOut na Read Serial

  CIF_ERR_TEMP      = -91;      // Temperatura Alta
  CIF_ERR_PPAPEL    = -92;      // Detectado pouco papel

  CIF_IRRECUPERAVEL = -94;      // Erro Irrecuperavel
  CIF_ERR_MECANICO  = -95;      // Erro Mecanico
  CIF_ERR_TABERTA   = -96;      // Tampa Aberta
  CIF_SEMRETORNO    = -97;      // Sem Retorno
  CIF_OVERFLOW      = -98;      // Overflow
  CIF_TIMEOUT       = -99;      // TimeOut na execucao do comando


var
  fHandle : THandle;
  fFuncOpenCif                    : function  ():Integer; StdCall;
  fFuncCloseCif                   : procedure (); StdCall;
  fFuncAbreCupomFiscal            : function  ():Integer; StdCall;
  fFuncAbreCupomFiscalCPF_CNPJ    : function  ( CPF:pchar ):Integer; StdCall;
  fFuncLeituraX                   : function  ( RelGer:char ):Integer; StdCall;
  fFuncReducaoZ                   : function  ( RelGer:char ):Integer; StdCall;
  fFuncEcfPar                     : function  ( Dados:String ):Integer; StdCall;
  fFuncEsperaRetorno              : function  ( Buffer,Timeout:pchar ):Integer; StdCall;
  fFuncObtemRetorno               : function  ( Buffer:pchar ):Integer; StdCall;
  fFuncVendaItem                  : function  ( Formato:char; Qtd,VlrUnit,Trib:pchar; Desconto:char; Valor,Unidade,Cod:pchar; Ex:char; Desc,Legop:pchar ):Integer; StdCall;
  fFuncCancelaCupomFiscal         : function  ():Integer; StdCall;
  fFuncCancelamentoItem           : function  ( NumItem:pchar ):Integer; StdCall;
  fFuncFechaCupomFiscal           : function  ( tam,smg:pchar ):Integer; StdCall;
  fFuncPagamento                  : function  ( Reg,valor:pchar; troco:char ):Integer; StdCall;
  fFuncTroco                      : function  ( Reg:pchar ):Integer; StdCall;
  fFuncTotalizarCupom             : function  ( operacao,tipoper:char; Valor,Legenda:pchar ):Integer; StdCall;
  fFuncTotalizarCupomParcial      : function  ():Integer; StdCall;
  fFuncLeMemFiscalData            : function  ( datai,dataf:pchar; Res:char ):Integer; StdCall;
  fFuncLeMemFiscalReducao         : function  ( redi,redf:pchar; Res:char ):Integer; StdCall;
  fFuncProgramaLegenda            : function  ( Reg,Leg:pchar ):Integer; StdCall;
  fFuncProgAliquotas              : function  ( trib,valor:pchar ):Integer; StdCall;
  fFuncAbreCupomVinculado         : function  ():Integer; StdCall;
  fFuncAbreCupomNaoVinculado      : function  ():Integer; StdCall;
  fFuncImprimeLinhaNaoFiscal      : function  ( tipo:char; texto:pchar ):Integer; StdCall;
  fFuncImprimeLinhaNaoFiscalTexto : function  ( tipo:char; texto:pchar ):Integer; StdCall;
  fFuncEncerraCupomNaoFiscal      : function  ():Integer; StdCall;
  fFuncCancelaCupomNaoFiscal      : function  ():Integer; StdCall;
  fFuncAbrirGaveta                : function  ( tipo:char; ton,toff:pchar ):Integer; StdCall;
  fFuncTransStatus                : function  ( Test:Integer; aBuffer:pchar ):Integer; StdCall;
  fFuncTransDataHora              : function  ():Integer; StdCall;
  fFuncDescontoItem               : function  ( Oper:char; Valor,Legenda:pchar ):Integer; StdCall;
  fFuncImprimeNaoFiscal           : function  ( Vezes,aBuffer:pchar ):Integer; StdCall;
  fFuncModoChequeValidacao        : function  ( Tipo,Load:char ):Integer; StdCall;
  fFuncImprimeValidacao           : function  ( Leg1,Leg2:pchar ):Integer; StdCall;
  fFuncTransTabAliquotas          : function  ():Integer; StdCall;

  bOpened : Boolean;
  lDescAcres : Boolean = False;

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Mecaf
///
Function ArqIniMecaf( sPorta:String ):Boolean;
var
  fArq : TIniFile;
  sPath : String;
  sArq : String;
  lRet : Boolean;
  aPath : pchar;
begin
  aPath := StrAlloc( 100 );
  Fillchar( aPath^, 100, 0 );

  lRet := True;
  // Trocar por uma função da api para pegar o diretorio do windows
  GetWindowsDirectory( aPath, 100 );
  sPath := StrPas( aPath ) + '\';
  sArq := 'CIF.INI';

  Try
    fArq := TInifile.Create( sPath+sArq );
    If fArq.ReadString( 'PORT', 'COM', '' ) <> Copy(sPorta,4,1) then
      fArq.WriteString( 'PORT', 'COM', Copy(sPorta,4,1) );
    If fArq.ReadString( 'PORT', 'DEPURA', '' ) = '' then
      fArq.WriteString( 'PORT', 'DEPURA', '0' );
  Except
    lRet := False;
  End;
  Result := lRet;

  StrDispose( aPath );
end;

//----------------------------------------------------------------------------
Function OpenMecaf( sPorta:String ) : String;
  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ECF32M.DLL');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  iRet : Integer;
  bRet : Boolean;
begin
  If Not bOpened Then
  Begin
    fHandle := LoadLibrary( 'ECF32M.DLL' );
    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'OpenCif');
      if ValidPointer( aFunc, 'OpenCif' ) then
        fFuncOpenCif := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CloseCif');
      if ValidPointer( aFunc, 'CloseCif' ) then
        fFuncCloseCif := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AbreCupomFiscal');
      if ValidPointer( aFunc, 'AbreCupomFiscal' ) then
        fFuncAbreCupomFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AbreCupomFiscalCPF_CNPJ');
      if ValidPointer( aFunc, 'AbreCupomFiscalCPF_CNPJ' ) then
        fFuncAbreCupomFiscalCPF_CNPJ := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'LeituraX');
      if ValidPointer( aFunc, 'LeituraX' ) then
        fFuncLeituraX := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ReducaoZ');
      if ValidPointer( aFunc, 'ReducaoZ' ) then
        fFuncReducaoZ := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'EcfPar');
      if ValidPointer( aFunc, 'EcfPar' ) then
        fFuncEcfPar := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'EsperaRetorno');
      if ValidPointer( aFunc, 'EsperaRetorno' ) then
        fFuncEsperaRetorno := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ObtemRetorno');
      if ValidPointer( aFunc, 'ObtemRetorno' ) then
        fFuncObtemRetorno := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'VendaItem');
      if ValidPointer( aFunc, 'VendaItem' ) then
        fFuncVendaItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CancelaCupomFiscal');
      if ValidPointer( aFunc, 'CancelaCupomFiscal' ) then
        fFuncCancelaCupomFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CancelamentoItem');
      if ValidPointer( aFunc, 'CancelamentoItem' ) then
        fFuncCancelamentoItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'FechaCupomFiscal');
      if ValidPointer( aFunc, 'FechaCupomFiscal' ) then
        fFuncFechaCupomFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Pagamento');
      if ValidPointer( aFunc, 'Pagamento' ) then
        fFuncPagamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'Troco');
      if ValidPointer( aFunc, 'Troco' ) then
        fFuncTroco := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'TotalizarCupom');
      if ValidPointer( aFunc, 'TotalizarCupom' ) then
        fFuncTotalizarCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'TotalizarCupomParcial');
      if ValidPointer( aFunc, 'TotalizarCupomParcial' ) then
        fFuncTotalizarCupomParcial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'LeMemFiscalData');
      if ValidPointer( aFunc, 'LeMemFiscalData' ) then
        fFuncLeMemFiscalData := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'LeMemFiscalReducao');
      if ValidPointer( aFunc, 'LeMemFiscalReducao' ) then
        fFuncLeMemFiscalReducao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ProgramaLegenda');
      if ValidPointer( aFunc, 'ProgramaLegenda' ) then
        fFuncProgramaLegenda := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ProgAliquotas');
      if ValidPointer( aFunc, 'ProgAliquotas' ) then
        fFuncProgAliquotas := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AbreCupomVinculado');
      if ValidPointer( aFunc, 'AbreCupomVinculado' ) then
        fFuncAbreCupomVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AbreCupomNaoVinculado');
      if ValidPointer( aFunc, 'AbreCupomNaoVinculado' ) then
        fFuncAbreCupomNaoVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeLinhaNaoFiscal');
      if ValidPointer( aFunc, 'ImprimeLinhaNaoFiscal' ) then
        fFuncImprimeLinhaNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeLinhaNaoFiscalTexto');
      if ValidPointer( aFunc, 'ImprimeLinhaNaoFiscalTexto' ) then
        fFuncImprimeLinhaNaoFiscalTexto := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'EncerraCupomNaoFiscal');
      if ValidPointer( aFunc, 'EncerraCupomNaoFiscal' ) then
        fFuncEncerraCupomNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CancelaCupomNaoFiscal');
      if ValidPointer( aFunc, 'CancelaCupomNaoFiscal' ) then
        fFuncCancelaCupomNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AbrirGaveta');
      if ValidPointer( aFunc, 'AbrirGaveta' ) then
        fFuncAbrirGaveta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'TransStatus');
      if ValidPointer( aFunc, 'TransStatus' ) then
        fFuncTransStatus := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'TransDataHora');
      if ValidPointer( aFunc, 'TransDataHora' ) then
        fFuncTransDataHora := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'DescontoItem');
      if ValidPointer( aFunc, 'DescontoItem' ) then
        fFuncDescontoItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeNaoFiscal');
      if ValidPointer( aFunc, 'ImprimeNaoFiscal' ) then
        fFuncImprimeNaoFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ModoChequeValidacao');
      if ValidPointer( aFunc, 'ModoChequeValidacao' ) then
        fFuncModoChequeValidacao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeValidacao');
      if ValidPointer( aFunc, 'ImprimeValidacao' ) then
        fFuncImprimeValidacao := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'TransTabAliquotas');
      if ValidPointer( aFunc, 'TransTabAliquotas' ) then
        fFuncTransTabAliquotas := aFunc
      else
        bRet := False;

    end
    else
    begin
      ShowMessage('O arquivo ECF32M.DLL não foi encontrado');
      bRet := False;
    end;

    if bRet then
    begin
      result := '0|';
      iRet := fFuncOpenCif;
      TrataRetornoMecaf( iRet );
      If iRet < 0 then
      begin
        ShowMessage('Erro na abertura da porta');
        result := '1|';
      end
      else
      begin
        bOpened := True;
      end;
    end
    else
    begin
      result := '1|';
    end;
  End
  Else
    Result := '0';
End;

//----------------------------------------------------------------------------
Function CloseMecaf : String;
begin
  If bOpened Then
  Begin
    if (fHandle <> INVALID_HANDLE_VALUE) then
    begin
      fFuncCloseCif;
      FreeLibrary(fHandle);
      fHandle := 0;
    end;
    bOpened := False;
  End;
  Result := '0';
end;

//----------------------------------------------------------------------------
Function TrataRetornoMecaf( var iRet:Integer; nChar:Integer ):String;
var
  aBuffer : array[0..2000] of char;
  sMsg : String;
  aStatus : array[0..39] of char;
begin
  Fillchar( aBuffer, 2001, 0 );
  if iRet = 0 then
  begin
    repeat
      iRet := fFuncEsperaRetorno( aBuffer, '3' );
      Application.ProcessMessages;
    until (fFuncTransStatus( 17,aStatus ) = 0) and (iRet <> -97);
  end;

  If LogDLL Then
    WriteLog('sigaloja.log', PChar(DateTimeToStr(Now)+' <- Retorno Mecaf: '+ IntToStr(iRet) ));

  If iRet < 0 then
  begin
    sMsg := MsgErroMecaf( iRet );
    MsgStop( sMsg );
    Result := '';
  end
  Else
  begin
    If nChar <> 0 then
      Result := Copy(StrPas(aBuffer),6,nChar)
    Else
      Result := '';
  end;
end;

//----------------------------------------------------------------------------
Function MsgErroMecaf( iRet:Integer ):String;
var
  sMsg : String;
begin
  sMsg := '';
  Case iRet of
    -1  : sMsg := 'O cabeçalho contém caracteres inválidos';
    -2  : sMsg := 'Comando inexistente';
    -3  : sMsg := 'Valor não numérico em campo numérico';
    -4  : sMsg := 'Valor fora da faixa entre 20h e 7Fh';
    -5  : sMsg := 'Campo deveria iniciar com @, & ou %';
    -6  : sMsg := 'Campo deveria iniciar com $, # ou ?';
    -7  : sMsg := 'O intervalo é inconsistente. No caso de datas, valores anteriores a' +
                  ' 01/01/1995 serão considerados como pertencentes ao intervalo 2000-2094';
    -9  : sMsg := 'A string TOTAL não é aceita';
    -10 : sMsg := 'A sintaxe do comando está errada';
    -11 : sMsg := 'Execedeu o número máximo de linhas permitido pelo comando';
    -12 : sMsg := 'O terminador enviado não está obedecendo o protocolo de comunicação';
    -13 : sMsg := 'O checksum enviado está incorreto';
    -15 : sMsg := 'A situação tributária deve iniciar com T, F ou N';
    -16 : sMsg := 'Data inválida';
    -17 : sMsg := 'Hora inválida';
    -18 : sMsg := 'Alîquota não programada ou fora da intervalo';
    -19 : sMsg := 'O campo de sinal está incorreto';
    -20 : sMsg := 'Comando só aceito durante Intervenção Fiscal';
    -21 : sMsg := 'Comando só aceito durante Modo Normal';
    -22 : sMsg := 'Necessário abrir Cupom Fiscal';
    -23 : sMsg := 'Comando não aceito durante Cupom Fiscal';
    -24 : sMsg := 'Necessário abrir Cupom Não Fiscal';
    -25 : sMsg := 'Comando não aceito durante Cupom Não Fiscal';
    -26 : sMsg := 'O relógio já está em horário de verão';
    -27 : sMsg := 'O relógio não está em horário de verão';
    -28 : sMsg := 'Necessário realizar Redução Z';
    -29 : sMsg := 'Fechamento do dia (Redução Z) já executado';
    -30 : sMsg := 'Necessário programar legenda';
    -31 : sMsg := 'Item já cancelado ou item inexistente';
    -32 : sMsg := 'Cupom anterior não pode ser cancelado';
    -33 : sMsg := 'Detectado Falta de Papel';
    -36 : sMsg := 'Necessário programar os dados do estabelecimento';
    -37 : sMsg := 'Necessário realizar Intervenção Fiscal';
    -38 : sMsg := 'A Memória Fiscal não permite mais realizar vendas ' +
                  'Só é possível executar Leitura X ou Leitura da Memória Fiscal';
    -39 : sMsg := 'A Memória Fiscal não permite mais realizar vendas ' +
                  'Só é possível executar Leitura X ou Leitura da Memória Fiscal ' +
                  'ocorreu algum problema na memória NOVRAM. Será necessário ' +
                  'realizar uma Intervenção Fiscal';
    -40 : sMsg := 'Necessário programar a data do relógio';
    -41 : sMsg := 'Número máximo de itens por cupom ultrapassado';
    -42 : sMsg := 'Já foi realizado o ajuste de hora diário';
    -43 : sMsg := 'Comando válido ainda em execução';
    -44 : sMsg := 'Está em estado de impressão de cheques';
    -45 : sMsg := 'Não está em estado de impressão de cheques';
    -46 : sMsg := 'Necessário inserir o cheque';
    -47 : sMsg := 'Necessário inserir nova bobina';
    -48 : sMsg := 'Necessário executar uma Leitura X';
    -49 : sMsg := 'Detectado algum problema na impressora (paper jam, sobretensão, etc)';
    -50 : sMsg := 'Cupom já foi totalizado';
    -51 : sMsg := 'Necessário totalizar Cupom antes de fechar';
    -52 : sMsg := 'Necessário finalizar Cupom antes de fechar';
    -53 : sMsg := 'Ocorreu erro de gravação da memória fiscal';
    -54 : sMsg := 'Excedeu número máximo de estabelecimentos';
    -55 : sMsg := 'Memória Fiscal não iniciada';
    -56 : sMsg := 'Ultrapassou valor do pagamento';
    -57 : sMsg := 'Registrador não programado ou troco já realizado';
    -58 : sMsg := 'Falta completar valor do pagamento';
    -59 : sMsg := 'Campo somente de caracteres não-numéricos';
    -60 : sMsg := 'Excedeu campo máximo de caracteres';
    -61 : sMsg := 'Troco não realizado';
    -62 : sMsg := 'Comando desabilitado';

    CIF_OK            : sMsg := 'Comando executado com sucesso';
    CIF_OK_CUPNF      :	sMsg := 'Função executada com sucesso .Abrindo Cupom Rel Gerencial';
    CIF_OK_CANCCUP    : sMsg := 'Função executada com sucesso. Cancelando Cupom';
    CIF_OK_PPAPEL     : sMsg := 'Função executada com sucesso. Detectado pouco papel';
    CIF_ERR           : sMsg := 'Falha Geral';
    CIF_EMEXECUCAO    : sMsg := 'Comando nao recebido pelo ECF';
    CIF_ERR_CONFIG    : sMsg := 'Erro no arquivo Cif.ini';
    CIF_ERR_SERIAL    : sMsg := 'Erro na abertura da serial';
    CIF_ERR_SYS       : sMsg := 'Erro na alocacao de recursos do windows';
    CIF_ERR_ANSWER    : sMsg := 'Retorno nao identificado';
    CIF_ERR_READSER   : sMsg := 'Falha na leitura da serial';
    CIF_ERR_TEMP      : sMsg := 'Temperatura da cabeça está alta';
    CIF_ERR_PPAPEL    : sMsg := 'Detectado pouco papel';
    CIF_IRRECUPERAVEL : sMsg := 'Erro Irrecuperavel';
    CIF_ERR_MECANICO  : sMsg := 'Erro Mecânico';
    CIF_ERR_TABERTA   : sMsg := 'A tampa está aberta. Verifique a impressora';
    CIF_SEMRETORNO    : sMsg := 'Ainda não obteve retorno';
    CIF_OVERFLOW      : sMsg := 'Overflow';
    CIF_TIMEOUT       : sMsg := 'TimeOut na execucao do comando';
  end;
  Result :=  sMsg;
end;

//----------------------------------------------------------------------------
function TImpMecaf.Abrir(sPorta : String; iHdlMain:Integer) : String;
begin
  // Verifica o arquivo de configuracao da Mecaf.
  ArqIniMecaf( sPorta );
  Result := OpenMecaf( sPorta );
  // Carrega as aliquotas e N. PDV para ganhar performance
  if Copy(Result,1,1) = '0' then
    AlimentaProperties;
end;

//----------------------------------------------------------------------------
function TImpMecaf.Fechar( sPorta:String ):String;
begin
  Result := CloseMecaf;
end;

//----------------------------------------------------------------------------
function TImpMecaf.AbreEcf:String;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpMecaf.FechaEcf:String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpMecaf.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpMecaf.LeituraX:String;
var
  iRet : Integer;
begin
  // '0' - Não haverá relatório gerencial depois da Leitura X
  // '1' - Relatório gerencial habilitado após a emissão da Leitura X
  // (Para Fechar o relatorio deverá ser utilizada a função EncerraCupomNaoFiscal()
  iRet := fFuncLeituraX( '0' );
  TrataRetornoMecaf( iRet );
  if iRet >= 0 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpMecaf.ReducaoZ(MapaRes:String):String;
var
  iRet : Integer;
  iCont: Integer;
  sRet : String;
  sAux : String;
  sTot : String;
  sAliq : String;
  aRetorno : Array of String;
  nAliq : Integer;
  sIss : String;
  nI : Integer;
  sReco : String;
  sDesc : String;
  sCanc : String;
  sDescIss : String;
  sAcreIss : String;
  sCancIss : String;
  sAcreIcm : String;

begin
  // '0' - Não haverá relatório gerencial depois da Redução Z
  // '1' - Relatório gerencial habilitado após a emissão da Redução Z
  // (Para Fechar o relatorio deverá ser utilizada a função EncerraCupomNaoFiscal()

  // Para a Elgin foi alterada a forma de geracao do Mapa Resumo, pois nesse ECF
  // não é possível fazer uma leitura X serial, gravar em arquivo e depois
  // desmembrar linha a linha. A solução para isso foi usar os retornos do
  // ECFPAR() antes da realização da REdução Z. Mauro - 13/07/2006

  // Verifica se as aliquotas sao ISS ou ICMS - 0 = ICMS / 1 = ISS
  SetLength(aRetorno,21);

  iRet := fFuncEcfPar( '86' );
  sRet := TrataRetornoMecaf( iRet, 512 );
  sTot := HexToBin( sRet );

  nAliq := 0;
  sIss := '0';
  // Captura as aliquotas e os totais por aliquota
  For iCont := 0 to 15 Do
  Begin
    // Capturo a aliquota
    iRet := fFuncEcfPar( Trim( IntToStr( iCont + 16 ) ) );
    sRet := TrataRetornoMecaf( iRet, 512 );
    sAux := sRet;

    If sRet <> '0000' then
    Begin
      // Identifico se eh ICMS ou ISS
      If Copy( sTot, Length( sTot ), 1 ) = '0' then
      begin
        sAux := 'T' + Copy( sAux, 1, 2 ) + ',' + Copy( sAux, 3, 2 );
        nAliq := nAliq + 1;
      end
      Else
        sAux := 'S' + Copy( sAux, 1, 2 ) + ',' + Copy( sAux, 3, 2 );
      sTot := Copy( sTot, 1, Length( sTot ) - 1 );

      // Concateno com o valor aferido
      iRet := fFuncEcfPar( FormataTexto( Trim( IntToStr( iCont ) ), 2, 0, 2 ) );
      sRet := TrataRetornoMecaf( iRet, 512 );
      sAux := sAux + sRet;

      // Identificador(1) + Aliquota(5) + Valor(15)
      sAliq := sAliq + sAux;
    End;
  End;

  // Data do movimento
  aRetorno[0] := Space(6);
  iRet := fFuncEcfPar( '83' );
  aRetorno[0] := TrataRetornoMecaf( iRet, 6 );
  aRetorno[0] := Copy(aRetorno[0],1,2)+'/'+Copy(aRetorno[0],3,2)+'/'+Copy(aRetorno[0],5,2);

  // Número do PDV
  aRetorno[1] := Copy( Pdv, 3, 4 );

  // Número de Série
  aRetorno[2] := Copy( PegaSerie, 3, 10 );

  // Número de Reduções
  aRetorno[3] := Space( 4 );
  iRet := fFuncEcfPar( '42' );
  aRetorno[3] := TrataRetornoMecaf( iRet, 4 );

  // Grande Total Final
  aRetorno[4] := Space( 19 );
  iRet := fFuncEcfPar( '39' );
  aRetorno[4] := TrataRetornoMecaf( iRet, 19 );
  aRetorno[4] := Copy(aRetorno[4],1,Length(aRetorno[4])-2)+'.'+Copy(aRetorno[4],Length(aRetorno[4])-1,Length(aRetorno[4]));
  aRetorno[4] := FormataTexto(FloatToStr(StrToFloat(aRetorno[ 4])),19,2,1);

  // Número do Documento Final
  aRetorno[6] := Space( 6 );
  iRet := fFuncEcfPar( '41' );
  aRetorno[6] := TrataRetornoMecaf( iRet, 6 );
  aRetorno[5] := aRetorno[ 6];

  // Valor do Cancelamento
  aRetorno[7] := Space( 15 );
  iRet := fFuncEcfPar( '38' );
  aRetorno[7] := TrataRetornoMecaf( iRet, 15 );
  aRetorno[7] := Copy( aRetorno[7], 2, 12 ) + '.' + Copy( aRetorno[7], 14, 2 );
  sCanc := aRetorno[7];

  // Valor do Desconto
  aRetorno[9] := Space( 15 );
  iRet := fFuncEcfPar( '36' );
  aRetorno[9] := TrataRetornoMecaf( iRet, 15 );
  aRetorno[9] := Copy( aRetorno[9], 2, 12 ) + '.' + Copy( aRetorno[9], 14, 2 );
  sDesc := aRetorno[9];

  // Valor Substituição Tributária
  aRetorno[10] := Space( 15 );
  iRet := fFuncEcfPar( '34' );
  aRetorno[10] := TrataRetornoMecaf( iRet, 15 );
  aRetorno[10] := Copy( aRetorno[10], 2, 12 ) + '.' + Copy( aRetorno[10], 14, 2 );

  // Valor ISENTO
  aRetorno[11] := Space( 15 );
  iRet := fFuncEcfPar( '32' );
  aRetorno[11] := TrataRetornoMecaf( iRet, 15 );
  aRetorno[11] := Copy( aRetorno[11], 2, 12 ) + '.' + Copy( aRetorno[11], 14, 2 );

  // Valor Não-Tributado
  aRetorno[12] := Space( 15 );
  iRet := fFuncEcfPar( '33' );
  aRetorno[12] := TrataRetornoMecaf( iRet, 15 );
  aRetorno[12] := Copy( aRetorno[12], 2, 12 ) + '.' + Copy( aRetorno[12], 14, 2 );

  // Data da Redução Z
  aRetorno[13] := Copy(StatusImp(2),3,10);
  aRetorno[14] := FormataTexto(IntToStr(StrToInt(aRetorno[6])+1),6,0,2);

  // Outros Recebimentos
  aRetorno[15] := FormataTexto('0',16, 0, 1);

  // Qtde de Alíquotas
  aRetorno[20] := FormataTexto( Trim( IntToStr( nALiq ) ),2,0,2 ) ;

  // COO do Primeiro Cupom fiscal
  aRetorno[5] := Space( 6 );
  iRet := fFuncEcfPar( '82' );
  aRetorno[5] := TrataRetornoMecaf( iRet, 12 );
  aRetorno[5] := Copy( aRetorno[5], 6, 6 );

  // Venda Líquida
  // Nas leituras os totais de acrescimo nao sao descontados para a formacao da venda liquida...
    iRet := fFuncEcfPar( '87' );
  aRetorno[8] := TrataRetornoMecaf( iRet, 512 );
  sDescIss := Copy( aRetorno[8], 1, 13 ) + '.' + Copy( aRetorno[8], 14, 2 ) ;
  sAcreIss := Copy( aRetorno[8], 16, 13 ) + '.' + Copy( aRetorno[8], 29, 2 ) ;
  sCancIss := Copy( aRetorno[8], 31, 13 ) + '.' + Copy( aRetorno[8], 44, 2 ) ;
  iRet := fFuncEcfPar( '37' );
  sAcreIcm := Copy( TrataRetornoMecaf( iRet, 15 ), 1, 13 ) + '.' + Copy( TrataRetornoMecaf( iRet, 15 ), 14, 2 );
  aRetorno[8] := Space( 19 );
  iRet := fFuncEcfPar( '40' );
  aRetorno[8] := Copy( TrataRetornoMecaf( iRet, 19 ), 6, 12 ) + '.' + Copy( TrataRetornoMecaf( iRet, 19 ), 18, 2 ) ;
  aRetorno[8] := FloatToStr( StrToFloat( aRetorno[8] ) - StrToFloat( sDesc ) - StrToFloat( sCanc ) - StrToFloat( sDescIss ) - StrToFloat( sCancIss ) );
  aRetorno[8] := Replicate( '0', 14 - Length( aRetorno[8]) ) + aRetorno[8];
  
  // desconto de ISS
  aRetorno[18]:= sDescIss ;
  
  // cancelamento de ISS
  aRetorno[19]:= sCancIss ;

  // Reinicio de Operação
  aRetorno[17] := Space( 4 );
  iRet := fFuncEcfPar( '43' );
  aRetorno[17] := Copy( TrataRetornoMecaf( iRet, 4 ), 2, 3 );

  While sAliq <> '' do
  Begin
    If Copy( sAliq, 1, 1 ) = 'T' then
    begin
      SetLength( aRetorno, Length(aRetorno)+1 );
      // Troco ',' por '.' para transformar em Float
      sReco := StrTran( Copy( sAliq, 2, 5 ), ',','.' );
      // Converto e calculo o calor do imposto devido = Total x valor da aliquota
      sReco := FloatToStrF( StrToFloat( Copy( sAliq, 9, 11 ) + '.' + Copy( sAliq, 20, 2 )  ) * ( StrToFloat( sReco ) / 100 ) , ffFixed, 4, 3 );
      // Trunco o resultado
      If Pos( '.', sReco ) <> 0 then
        sReco := Copy( sReco, 1, Pos( '.', sReco ) + 2 );

      // Completo com zeros para ficar no padrão
      sReco := Replicate( '0', 14 - Length( sReco ) ) + sReco;
      aRetorno[High(aRetorno)] := Copy( sAliq, 1, 6 ) + ' ' + Copy( sALiq, 9, 11) + '.' + Copy( sAliq, 20, 2 ) + ' ' + sReco;
    End
    Else
    Begin
      // Total ISS
      sIss := IntToStr( StrToInt( sIss ) + StrToInt( Copy( sALiq, 7, 15 ) ) );
    End;
    sAliq := Copy( sAliq, 22, Length( sAliq ) );
  end;
  // Monta o Retorno do Total de ISS
  sIss := FormataTexto( sIss, 14, 0, 2 );
  aRetorno[16] := ' ' + Copy( sIss, 1, 11 ) + '.' + Copy( sIss, 12, 2 ) + FormataTexto( '0', 14, 2, 1, '.' );

  iRet := fFuncReducaoZ( '0' );
  TrataRetornoMecaf( iRet );

  If iRet >= 0 then
  begin
    If Trim(MapaRes) ='S' then
    begin
       Result := '0|';
       For nI:= 0 to High(aRetorno) do
          Result := Result + aRetorno[nI]+'|';
    end
    Else
        Result := '0';
  end
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpMecaf.AbreCupom(Cliente:String; MensagemRodape:String):String;
var
  iRet : Integer;
  aCPF : Pchar;
begin
  lDescAcres := False;
  aCPF := StrAlloc(28);
  Fillchar( aCPF^, 28, 0 );

  If (Cliente = '') or (StrToInt(copy(Eprom,5,3))<500) then
    iRet := fFuncAbreCupomFiscal
  Else
  begin
    Strpcopy( aCPF, Cliente );
    iRet := fFuncAbreCupomFiscalCPF_CNPJ( aCPF );
  end;

  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';

  StrDispose( aCPF );
end;

//----------------------------------------------------------------------------
function TImpMecaf.PegaCupom(Cancelamento:String):String;
var
  iRet : Integer;
  sRet : String;
begin
  iRet := fFuncEcfPar( '41' );
  If iRet >= 0 then
  begin
    sRet := TrataRetornoMecaf( iRet, 6 );
    Result := '0|' + sRet;
  end
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpMecaf.PegaPDV:String;
begin
  Result := '0|' + PDV;
end;

//----------------------------------------------------------------------------
function TImpMecaf.LeAliquotas:String;
begin
  Result := '0|' + ICMS;
end;

//----------------------------------------------------------------------------
function TImpMecaf.LeAliquotasISS:String;
begin
  Result := '0|' + ISS;
end;

//----------------------------------------------------------------------------
function TImpMecaf.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;
var
  iRet : Integer;
  sTrib : String;
  aQtde : pchar;
  avlrUnit : pchar;
  aTrib : pchar;
  aVlrDesconto : pchar;
  aCodigo : pchar;
  aDescricao : pchar;
  aUM : pchar;
  aLegenda : pchar;
  cTipoDesc : char;
  i : Integer;
  icont : Integer;
  lFind : Boolean;
  sRet : String;
  lRet : Boolean;
  nAliqImp : Double;
  nAliqSis : Double;

begin
  lRet := True;
  ///////////////////////////////////////////////////////////////////////////////
  // Os campos codigo e descricao devem ser completados com spacos a direita e //
  // os campos valores devem ser completados com zeros a esquerda.             //
  ///////////////////////////////////////////////////////////////////////////////

  aQtde := StrAlloc( 6 );
  aVlrUnit := StrAlloc( 11 );
  aTrib := StrAlloc( 3 );
  aVlrDesconto := StrAlloc( 15 );
  aCodigo := StrAlloc( 13 );
  aDescricao := StrAlloc( 38 );
  aUM := StrAlloc( 2 );
  aLegenda := StrAlloc( 14 );

  Fillchar( aQtde^, 6, 0 );
  Fillchar( aVlrUnit^, 11, 0 );
  Fillchar( aTrib^, 3, 0 );
  Fillchar( aVlrDesconto^, 15, 0 );
  Fillchar( aCodigo^, 13, 0 );
  Fillchar( aDescricao^, 38, 0 );
  Fillchar( aUM^, 2, 0 );
  Fillchar( aLegenda^, 14, 0 );

  qtde := FormataTexto( qtde, 6, 3, 2 );
  vlrUnit := FormataTexto( vlrUnit, 11, 2, 2 );
  cTipoDesc := '&';  // '&'-Valor  '%'-Percentual
  vlrDesconto := FormataTexto( vlrDesconto, 15, 2, 2 );
  codigo := copy( codigo+Space(13), 1, 13 );
  descricao := copy( descricao+Space(38), 1, 38 );

  // Checa a carga tributária
  sTrib := copy(aliquota,1,1);
  If sTrib = 'S' then
    sTrib := 'T00'
  Else If sTrib = 'I' then
    sTrib := 'I00'
  Else If sTrib = 'F' then
    sTrib := 'F00'
  Else If sTrib = 'N' then
    sTrib := 'N00'
  Else If sTrib = 'T' then
  begin
    i := 17;
    icont := 1;
    lFind := False;
    While (i <= 31) and not lFind do
    begin
      iRet := fFuncEcfPar( FormataTexto( IntToStr(i), 2, 0, 2 ) );
      If iRet >= 0 then
      begin
        sRet := TrataRetornoMecaf( iRet, 5 );

        //////////////////////////////////////////////////////////////////////////
        // Por problemas internos (Delphi) na manipulação de váriaveis          //
        // float, os seguintes valores não são iguais:                          //
        // StrToFloat( sRet ) / 100                                             //
        // StrToFloat( copy( aliquota, 2, 5 ) )                                 //
        // Logo, para que não ocorra este problema, foram criados duas variáveis//
        // do tipo Double para um cast de extended (Float Type) para Double.    //
        // Com isso, a comparação ocorrerá normalmente.                         //
        //////////////////////////////////////////////////////////////////////////
        nAliqImp := StrToFloat( sRet ) / 100;
        nAliqSis := StrToFloat( copy( aliquota, 2, 5 ) );

        If nAliqImp = nAliqSis then
        begin
          lFind := True;
          sTrib := 'T' + FormataTexto( IntToStr(icont), 2, 0, 2 );
        end;
      end;
      Inc(i);
      Inc(icont);
    end;
  end
  Else
  begin
    lRet := False;
    MsgStop('Aliquota não encontrada.');
  end;

  If lRet then
  Begin
    Strpcopy( aQtde, qtde );
    Strpcopy( aVlrUnit, vlrUnit );
    Strpcopy( aVlrDesconto, vlrDesconto );
    Strpcopy( aCodigo, codigo );
    Strpcopy( aDescricao, descricao );
    Strpcopy( aTrib, sTrib );
    Strpcopy( aUM, 'UN' );

    iRet := fFuncVendaItem( #0, aQtde, aVlrUnit, aTrib, cTipoDesc, aVlrDesconto, aUM, aCodigo, '1', aDescricao, aLegenda );
    TrataRetornoMecaf( iRet );

    If iRet >= 0 then
      Result := '0'
    Else
      Result := '1';
  End;

  StrDispose(aQtde);
  StrDispose(aVlrUnit);
  StrDispose(aVlrDesconto);
  StrDispose(aCodigo);
  StrDispose(aDescricao);
  StrDispose(aTrib);
  StrDispose(aUM);
end;

//----------------------------------------------------------------------------
function TImpMecaf.CancelaCupom( Supervisor:String ):String;
var
  iRet : Integer;
begin
  iRet := fFuncCancelaCupomFiscal;
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpMecaf.LeCondPag:String;
var
  iRet : Integer;
  i : Integer;
  sRet : String;
  sPagto : String;
begin
  sPagto := '';
  For i:=50 to 81 do
  begin
    iRet := fFuncEcfPar( IntToStr(i) );
    If iRet >= 0 then
    begin
      sRet := TrataRetornoMecaf( iRet, 16 );
      If Trim(sRet) <> '' then
        sPagto := sPagto + Trim(sRet) + '|';
    end;
  end;

  Result := '0|' + sPagto;
end;

//----------------------------------------------------------------------------
function TImpMecaf.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var
  iRet : Integer;
  aNumero : pchar;
begin
  aNumero := StrAlloc( 3 );
  Fillchar( aNumero^, 3, 0 );
  Strpcopy( aNumero, FormataTexto(numitem,3,0,2) );
  iRet := fFuncCancelamentoItem( aNumero );
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';
  StrDispose( aNumero )
end;

//----------------------------------------------------------------------------
function TImpMecaf.FechaCupom( Mensagem:String ):String;
var
  iRet : Integer;
  aTamanho : array[0..3] of char;
  aMensagem : array[0..99] of char;
  pTamanho : pchar;
  pMensagem : pchar;
  aBuffer : array[0..39] of char;
  sMsg : String;
begin
  Fillchar( aBuffer, 40, 0 );
  Fillchar( aTamanho, 4, 0 );
  Fillchar( aMensagem, 100, 0 );
  pTamanho := @aTamanho;            // Não tirar
  pMensagem := @aMensagem;          // essas linhas

  // Fecha o cupom
  Result := '1';
  iRet := fFuncTransStatus( 0, aBuffer );
  TrataRetornoMecaf( iRet );
  If (aBuffer[7] = '1') and  // Cupom Aberto
     (aBuffer[32] = '1') and  // Pagamento completado
     (aBuffer[33] = '1') and  // Troco Realizado
     (aBuffer[34] = '1') then   // Pagamento Iniciado
  begin
	sMsg := Mensagem;
	sMsg := TrataTags( sMsg );
    pTamanho := PChar( 'S'+FormataTexto(IntToStr(Length(sMsg)),3,0,2) );
    pMensagem := PChar( sMsg );

    iRet := fFuncFechaCupomFiscal( pTamanho, pMensagem );
    TrataRetornoMecaf( iRet );
    If iRet >= 0 then
      Result := '0';
  end;
end;

//----------------------------------------------------------------------------
function TImpMecaf.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;
  function PegaPagto( aPagtos:TaString; sPagto:String ):Integer;
  var
    i : Integer;
    lFound : Boolean;
  begin
    i := -1;
    lFound := False;
    While (i < Length(aPagtos)) and not lFound do
    begin
      Inc(i);
      If UpperCase(Trim(aPagtos[i])) = UpperCase(Trim(sPagto)) then
        lFound := True;
    end;
    If lFound then
      Result := i
    Else
      Result := -1;
  end;
var
  iRet : Integer;
  aReg : pchar;
  aValor : pchar;
  i : Integer;
  iPagto : Integer;
  lFound : Boolean;
  aAuxiliar : TaString;
  aPagtos : TaString;
  sPagtos : String;
begin
   // Inicializa variáveis
  Result := '1';

  aReg := StrAlloc( 2 );
  aValor := StrAlloc( 15 );
  Fillchar( aReg^, 2, 0 );
  Fillchar( aValor^, 15, 0 );

  // Fecha o cupom chamando a função de Totalizar cupom se não houve registro de desconto/acrescimo.
  If not lDescAcres then
  begin
    iRet := fFuncTotalizarCupomParcial;
    TrataRetornoMecaf( iRet );
  end;

  // Trata os parâmetros informados.
  MontaArray( Pagamento,aAuxiliar );

  // Le as formas de pagamento já cadastradas e ferifica se foi escolhida alguma forma que
  // não está cadastrada no ECF.
  i := 0;
  lFound := True;
  sPagtos := LeCondPag;
  sPagtos := Copy( sPagtos, 3, length(sPagtos) );
  sPagtos := StrTran( sPagtos, '.', '');
  MontaArray( sPagtos, aPagtos );
  While (i < Length(aAuxiliar)) and lFound do
  begin
    If Pos( UpperCase(Trim(aAuxiliar[i])), UpperCase(sPagtos) ) = 0 then
      lFound := False;
    i := i + 2;
  end;

  If not lFound then
  begin
    Result := '1';
    MsgStop( 'Foi informada uma condição de pagamento que não está cadastrada no ECF.');
  end
  Else
  begin
    i := 0;
    While i <= Length(aAuxiliar)-1 do
    begin
      iPagto := PegaPagto( aPagtos, aAuxiliar[i] );
      Strpcopy( aReg, FormataTexto(IntToStr(iPagto),2,0,2) );
      Strpcopy( aValor, FormataTexto(aAuxiliar[i+1],15,2,2) );
      iRet := fFuncPagamento( aReg, aValor, '1' );
      TrataRetornoMecaf( iRet );
      i := i + 2;
    end;

    // Imprime o Troco.
    Fillchar( aValor^, 15, 0 );
    Fillchar( aReg^, 2, 0 );
    Strpcopy( aReg, FormataTexto(IntToStr(PegaPagto( aPagtos, 'DINHEIRO' )),2,0,2) );
    Strpcopy( aValor, FormataTexto('0',15,2,2) );
    iRet := fFuncPagamento( aReg, aValor, '0');
    TrataRetornoMecaf( iRet );
    If iRet >= 0 then
      Result := '0';
  end;

  StrDispose( aReg );
  StrDispose( aValor );
end;

//----------------------------------------------------------------------------
function TImpMecaf.DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String;
var
  iRet : Integer;
  aValor : pchar;
begin
  aValor := StrAlloc( 15 );
  Fillchar( aValor^, 15, 0 );
  Strpcopy( aValor, FormataTexto(vlrDesconto,15,2,2) );

  iRet := fFuncTotalizarCupom( 'Z', '&', aValor, #0 );
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';

  lDescAcres := True;
  StrDispose( aValor );
end;

//----------------------------------------------------------------------------
function TImpMecaf.AcrescimoTotal( vlrAcrescimo:String ): String;
var
  iRet : Integer;
  aValor : pchar;
begin
  aValor := StrAlloc( 15 );
  Fillchar( aValor^, 15, 0 );
  Strpcopy( aValor, FormataTexto(vlrAcrescimo,15,2,2) );

  iRet := fFuncTotalizarCupom( '@', '&', aValor, #0 );
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';

  lDescAcres := True;
  StrDispose( aValor );
end;

//----------------------------------------------------------------------------
function TImpMecaf.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String ): String;
var
  iRet : Integer;
  sDatai : String;
  sDataf : String;
  aDatai : pchar;
  aDataf : pchar;
  aRedi : pchar;
  aRedf : pchar;
begin
  aDatai := StrAlloc( 6 );
  aDataf := StrAlloc( 6 );
  aRedi := StrAlloc( 4 );
  aRedf := StrAlloc( 4 );
  Fillchar( aDatai^, 6, 0 );
  Fillchar( aDataf^, 6, 0 );
  Fillchar( aRedi^, 4, 0 );
  Fillchar( aRedf^, 4, 0 );

  If Trim(ReducInicio) + Trim(ReducFim) = '' then
    Tipo := 'D'
  Else
    Tipo := 'R';

  // Se o relatório for por Data
  If Tipo = 'D' then
  begin
    sDatai := FormataData( DataInicio, 1 );
    sDataf := FormataData( DataFim, 1 );
    Strpcopy( aDatai, sDatai );
    Strpcopy( aDataf, sDataf );
    iRet := fFuncLeMemFiscalData( aDatai, aDataf, '0' );
    TrataRetornoMecaf( iRet );
    If iRet >= 0 then
      Result := '0'
    Else
      Result := '1';
  end
  // Se o relatório será por redução Z
  Else
  //If Tipo = 'R' then
  begin
    Strpcopy( aRedi, ReducInicio );
    Strpcopy( aRedf, ReducFim );
    iRet := fFuncLeMemFiscalReducao( aRedi, aRedf, '0' );
    TrataRetornoMecaf( iRet );
    If iRet >= 0 then
      Result := '0'
    Else
      Result := '1';
  end;

  StrDispose( aDatai );
  StrDispose( aDataf );
  StrDispose( aRedi );
  StrDispose( aRedf );
end;

//----------------------------------------------------------------------------
function TImpMecaf.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
// Tipo = 1 - ICMS
// Tipo = 2 - ISS
var
  iRet : Integer;
  aTrib : pchar;
  aValor : pchar;
  sAliquotas : String;
  lInclui : Boolean;
  i : Integer;
  iVazio : Integer;
  iPosicao : Integer;
  sRet : String;
begin
  Result := '1';
  iVazio := -1;
  aTrib := StrAlloc( 2 );
  aValor := StrAlloc( 4 );
  Fillchar( aTrib^, 2, 0 );
  Fillchar( aValor^, 4, 0 );

  lInclui := True;
  Aliquota := Trim(Aliquota);

  If Tipo = 1 then
  begin
    sAliquotas := ICMS;
    If Pos( Aliquota, sAliquotas ) > 0 then
      lInclui := False;
  end;

  If Tipo = 2 then
  begin
    sAliquotas := ISS;
    lInclui := False;
  end;

  If not lInclui then
    MsgStop( 'Já existe a alíquota informada.' )
  Else
  begin
    If Tipo = 1 then
    begin
      // Verifica uma posição disponível.
      iPosicao := 0;
      For i:=17 to 31 do
      begin
        Inc( iPosicao );
        iRet := fFuncEcfPar( FormataTexto( IntToStr(i), 2, 0, 2 ) );
        If iRet >= 0 then
        begin
          sRet := TrataRetornoMecaf( iRet, 4 );
          If sRet = '0000' then
            If iVazio = -1 then
            begin
              iVazio := iPosicao;
              break;
            end;
        end;
      end;
    end
    Else
    begin
      iRet := fFuncEcfPar( '16' );
      sRet := TrataRetornoMecaf( iRet, 4 );
      If (iRet >= 0) and (sRet = '0000') then
        iVazio := 0;
    end;

    If iVazio = -1 then
      MsgStop( 'Não existe espaços em branco para cadastrar aliquota.' )
    Else
    begin
      Strpcopy( aTrib, FormataTexto(IntToStr(iVazio),2,0,2) );
      Strpcopy( aValor, FormataTexto(Aliquota,4,2,2) );
      iRet := fFuncProgAliquotas( aTrib, aValor );
      TrataRetornoMecaf( iRet );
      If iRet >= 0 then
        Result := '0'
      Else
        Result := '1';
    end;
  end;

  StrDispose( aTrib );
  StrDispose( aValor );
end;

//----------------------------------------------------------------------------
function TImpMecaf.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
var
  iRet : Integer;
begin
  iRet := fFuncAbreCupomVinculado;
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
  begin
    iRet := fFuncAbreCupomNaoVinculado;
    TrataRetornoMecaf( iRet );
    If iRet >= 0 then
      Result := '0'
    Else
      Result := '1';
  end;
end;

//----------------------------------------------------------------------------
function TImpMecaf.TextoNaoFiscal( Texto:String; Vias:Integer ):String;
var
  aTexto : array[0..39] of char;
  pTexto : pchar;
  i : Integer;
  iVezes : Integer;
  icont : Integer;
  sTemp : String;
  sImp : String;
  iRet : Integer;
begin
  Fillchar( aTexto, 40, 0 );
  pTexto := @aTexto;          // Não tirar essa linha
  Result := '0';

  For iVezes:=1 to Vias do
  begin
    icont := 1;
    sTemp := Texto;
    sImp := '';
    i := 1;
    While icont <= Length(sTemp) do
    begin
      If (copy( sTemp, iCont, 1 ) = #10) or (i >= 40) then
      begin
        sImp := copy(sImp+Space(40),1,40);
        pTexto := PChar( sImp );
        iRet := fFuncImprimeLinhaNaoFiscal( '0', pTexto );
        TrataRetornoMecaf( iRet );
        If iRet < 0 then
        begin
          // Realiza o cancelamento do cupom para tentar a reimpressão
          iRet := fFuncCancelaCupomNaoFiscal;
          TrataRetornoMecaf( iRet );
          Result := '1';
          Break;
        end;
        i := 0;
        sImp := '';
      end
      Else
        sImp := sImp + copy( sTemp, icont, 1 );

      Inc( i );
      Inc( iCont );
    end;
  end;
end;

//----------------------------------------------------------------------------
function TImpMecaf.FechaCupomNaoFiscal: String;
var
  iRet : Integer;
begin
  iRet := fFuncEncerraCupomNaoFiscal;
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpMecaf.ReImpCupomNaoFiscal( Texto:String ):String;
begin
  MsgStop( 'Função não disponível para essa impressora.' );
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpMecaf.Suprimento( Tipo:Integer; Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
begin
  MsgStop('entre em contato com o suporte. TImpMecaf.Suprimento');
end;

//----------------------------------------------------------------------------
function TImpMecaf.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var
  iRet : Integer;
  aLegenda : pchar;
  aOpc : pchar;
begin
  aLegenda := StrAlloc( 5 );
  aOpc := StrAlloc( 40 );
  Fillchar( aLegenda^, 5, 0 );
  Fillchar( aOpc^, 40, 0 );
  Result := '0';

  // Temos que colocar a impressora em modo de validação.
  iRet := fFuncModoChequeValidacao( '0', '0' );
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
  begin
    Strpcopy( aLegenda, Space(5) );
    Strpcopy( aOpc, copy(Valor+' '+Texto+Space(40),1,40) );
    iRet := fFuncImprimeValidacao( aLegenda, aOpc );
    TrataRetornoMecaf( iRet );
    If iRet < 0 then
      Result := '1';
  end
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpMecaf.StatusImp( Tipo:Integer ):String;
var
  iRet : Integer;
  sRet : String;
  aBuffer : array[0..39] of char;
  i : Integer;
  lFound : Boolean;
  iPagto : Integer;
  iVazio : Integer;
  sVendaBruta : String;
  sGrandeTotal : String;
  sDataMov : String;
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
  // 17 - Retorna a Venda Bruta
  // 18 - Retorna o Grande Total

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

  Fillchar( aBuffer, 40, 0 );
  //  1 - Obtem a Hora da Impressora
  If Tipo = 1 then
  begin
    iRet := fFuncTransDataHora;
    If iRet >= 0 then
    begin
      sRet := Copy( TrataRetornoMecaf( iRet,17 ), 10, 8 );
      Result := '0|'+sRet;
    end
    Else
      Result := '1';
  end
  //  2 - Obtem a Data da Impressora
  Else If Tipo = 2 then
  begin
    iRet := fFuncTransDataHora;
    If iRet >= 0 then
    begin
      sRet := Copy( TrataRetornoMecaf( iRet,16 ), 1, 8 );
      Result := '0|'+sRet;
    end
    Else
      Result := '1';
  end
  //  3 - Verifica o Papel
  Else If Tipo = 3 then
  begin
    Fillchar( aBuffer, 40, 0 );
    iRet := fFuncTransStatus( 29, aBuffer );
    If iRet = 1 then // Falta papel.
      Result := '3'
    Else
    begin
      iRet := fFuncTransStatus( 18, aBuffer );
      If iRet = 1 then  // Pouco papel
        Result := '2'
      Else
        Result := '0';
    end;
  end
  //  4 - Verifica se é possível cancelar um ou todos os itens.
  Else if Tipo = 4 then
    Result := '0|TODOS'
  //  5 - Cupom Fechado ?
  Else If Tipo = 5 then
  begin
    iRet := fFuncTransStatus( 8, aBuffer );
    If iRet = 1 then  // aberto
      Result := '7'
    Else  // Fechado
      Result := '0';
  end
  //  6 - Ret. suprimento da impressora
  Else If Tipo = 6 then
  begin
    Result := '1';
    I := 50;
    lFound := False;
    iVazio := 0;
    iPagto := -1;
    While (i <= 81) and not lFound do
    begin
      iRet := fFuncEcfPar( IntToStr(i) );
      TrataRetornoMecaf( iRet );
      If iRet >= 0 then
      begin
        sRet := Trim( TrataRetornoMecaf( iRet,32 ) );
        Inc( iPagto );
        // Verifica um registrador vazio para o caso de cadastrar uma forma de pagto automaticamente.
        If iVazio = 0 then
          If sRet = '' then
            iVazio := iPagto;
        If UpperCase( Trim(Copy(sRet,1,16)) ) = 'DINHEIRO' then
        begin
          lFound := True;
          Result := '0|' + FloatToStrf(StrToFloat(copy(sRet,17,15))/100,ffFixed,18,2);
        end;
        Inc( i );
      end;
    end;
  end
  //  7 - ECF permite desconto por item
  Else If Tipo = 7 then
    Result := '0'
  //  8 - Verifica se o dia anterior foi fechado
  Else If Tipo = 8 then
  begin
    iRet := fFuncTransStatus( 3, aBuffer );
    If iRet = 1 then  // reducao pendente
      Result := '10'
    Else
      Result := '0';
  end
  //  9 - Verifica o Status do ECF
  Else If Tipo = 9 then
    Result := '0'
  // 10 - Verifica se todos os itens foram impressos.
  Else If Tipo = 10 then
    Result := '0'
  // 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
  Else If Tipo = 11 then
    Result := '1'
  // 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
  Else If Tipo = 12 then
    Result := '1'
  // 13 - Verifica se o ECF Arredonda o Valor do Item
  Else If Tipo = 13 then
    Result := '1'
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
  // 17 - Retorna a Venda Bruta Diária
  Else If Tipo = 17 then
  begin
    sVendaBruta := Space( 19 );
    iRet := fFuncEcfPar( '40' );
    sVendaBruta := TrataRetornoMecaf( iRet, 19 );
    If iRet >= 0 then
      Result := '0|' + sVendaBruta
    Else
      Result := '1';
  end
  // 18 - Retorna o Grande Total
  Else If Tipo = 18 then
  begin
    sGrandeTotal := Space( 19 );
    iRet := fFuncEcfPar( '39' );
    sGrandeTotal := TrataRetornoMecaf( iRet, 19 );
    If iRet >= 0 then
      Result := '0|' + sGrandeTotal
    Else
      Result := '1';
  end
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
function TImpMecaf.Gaveta:String;
var
  iRet : Integer;
begin
  iRet := fFuncAbrirGaveta( '0', '12', '48' );
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpMecaf.GravaCondPag( Condicao:String ):String;
var
  iRet : Integer;
  i : Integer;
  iReg : Integer;
  aLegenda : pchar;
  aReg : pchar;
  lFound : Boolean;
  sRet : String;
begin
  Result := '0';
  aLegenda := StrAlloc( 16 );
  aReg := StrAlloc( 2 );
  Fillchar( aLegenda^, 16, 0 );
  Fillchar( aReg^, 2, 0 );

  lFound := False;
  i := 50;
  iReg := -1;
  While (i <= 81) and not lFound do
  begin
    Inc( iReg );
    iRet := fFuncEcfPar( IntToStr(i) );
    TrataRetornoMecaf( iRet );
    If iRet >= 0 then
    begin
      sRet := Trim( TrataRetornoMecaf( iRet,16 ) );
      If Trim( sRet ) = '' then
        lFound := True;
      Inc( i );
    end;
  end;

  If lFound then
  begin
    Strpcopy( aReg, FormataTexto(IntToStr(iReg),2,0,2) );
    StrPcopy( aLegenda, Copy(Trim(Condicao)+Space(16),1,16) );
    iRet := fFuncProgramaLegenda( aReg, aLegenda );
    TrataRetornoMecaf( iRet );
    If iRet < 0 then
      Result := '1';
  end
  Else
    Result := '1';

  StrDispose( aLegenda );
  StrDispose( aReg );
end;

//----------------------------------------------------------------------------
function TImpMecaf.RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer; ImgQrCode: String) : String;
begin
  Result := RelatorioGerencial(cTextoImp , nVias , ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpMecaf.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
var
  iRet : Integer;
  sRet : String;
begin
  Result := '0';

  iRet := fFuncLeituraX( '1' );
  TrataRetornoMecaf( iRet );
  If iRet >= 0 then
  begin
    sRet := TextoNaoFiscal( Texto, Vias );
    If copy(sRet,1,1) = '0' then
    begin
      iRet := fFuncEncerraCupomNaoFiscal;
      TrataRetornoMecaf( iRet );
      If iRet < 0 then
        Result := '1';
    end;
  End
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpMecaf.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpMecaf.PegaSerie:String;
var
  iRet : Integer;
  sRet : String;
begin
  iRet := fFuncEcfPar( '49' );
  If iRet = 0 then
  begin
    sRet := TrataRetornoMecaf( iRet,10 );
    Result := '0|' + sRet;
  end
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
Procedure TImpMecaf.AlimentaProperties;
var
  iRet : Integer;
  i : Integer;
  sRet : String;
begin
  /// Inicalização de variaveis
  ICMS := '';
  ISS := '';
  Eprom := '';

//  iRet := fFuncTransTabAliquotas;
//  sRet := TrataRetornoMecaf( iRet, 64 );

  // Retorno de Aliquotas ( ISS )
  iRet := fFuncEcfPar( '16' );
  If iRet >= 0 then
  begin
    sRet := TrataRetornoMecaf( iRet,4 );
    If sRet <> '0000' then
    begin
      sRet := FloatToStrf( StrToFloat(sRet)/100, ffFixed, 18, 2 );
      ISS := sRet + '|';
    end;
  end;

  // Retorno de Aliquotas ( ICMS )
  For i:=17 to 31 do
  begin
    iRet := fFuncEcfPar( FormataTexto( IntToStr(i), 2, 0, 2 ) );
    If iRet >= 0 then
    begin
      sRet := TrataRetornoMecaf( iRet,5 );
      If sRet <> '0000' then
      begin
        sRet := FloatToStrf( StrToFloat(sRet)/100, ffFixed, 18, 2 );
        ICMS := ICMS + sRet + '|';
      end;
    end;
  end;

  // Retorno do Numero do Caixa (PDV)
  iRet := fFuncEcfPar( '48' );
  If iRet >= 0 then
    PDV := TrataRetornoMecaf( iRet,6 );

  // Retorno da Versão do Firmware (Eprom)
  iRet := fFuncEcfPar( '47' );
  If iRet >= 0 then
    Eprom := TrataRetornoMecaf( iRet,7 );

end;

//-----------------------------------------------------------
function TImpMecaf.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
begin
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpMecaf.RecebNFis( Totalizador, Valor, Forma:String ): String;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//------------------------------------------------------------------------------
function TImpMecaf.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpMecaf.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpMecaf.TotalizadorNaoFiscal( Numero,Descricao:String ) : String;
begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
end;

//------------------------------------------------------------------------------
function TImpMecaf.LeTotNFisc:String;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
function TImpMecaf.DownMF(sTipo, sInicio, sFinal : String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpMecaf.RedZDado( MapaRes : String ):String;
Begin
  Result := '0';
End;

//------------------------------------------------------------------------------
function TImpMecaf.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpMecaf.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpMecaf.ImpTxtFis(Texto : String) : String;
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

//----------------------------------------------------------------------------
function TImpMecaf.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
  RegistraImpressora( 'MECAF COMPACT FCR - FCP201', TImpMecaf, 'BRA', ' ');
  RegistraImpressora( 'MECAF COMPACT FCR - FCP500', TImpMecaf, 'BRA', '230403');
  RegistraImpressora( 'ELGIN IF500 - FCP201'      , TImpMecaf, 'BRA', '141001');
  RegistraImpressora( 'ELGIN IF500 - FCP500'      , TImpMecaf, 'BRA', '141002');
  RegistraImpressora( 'TRENDS FCP500 - V. 01.0E'  , TImpMecaf, 'BRA', '420103');
  RegistraImpressora( 'ZANTHUS QZ1001'            , TImpMecaf, 'BRA', '481401');
end.
