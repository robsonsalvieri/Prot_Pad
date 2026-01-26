 library sigaloja;

uses
  SysUtils,
  Classes,
  Dialogs,
  Windows,
  Forms,
  ScktComp,
  IniFiles,
  ImpFiscMain in 'ImpFiscMain.pas',
  ImpCheqMain in 'ImpCheqMain.pas',
  ImpCheqBematech in 'ImpCheqBematech.pas',
  ImpFiscBematech in 'ImpFiscBematech.pas',
  ImpFiscBematechAutoNivel in 'ImpFiscBematechAutoNivel.pas',
  ImpSweda in 'ImpSweda.pas',
  LojxFun in 'LojxFun.pas',
  ImpZanthus in 'ImpZanthus.pas',
  ImpUrano in 'ImpUrano.pas',
  ImpCorisco in 'ImpCorisco.pas',
  ImpDataRegis in 'ImpDataRegis.pas',
  ImpFujitsu in 'ImpFujitsu.pas',
  CMC7Main in 'CMC7Main.pas',
  CMC7Bematech in 'CMC7Bematech.pas',
  PinPad_SC552 in 'PinPad_SC552.pas',
  PinPadMain in 'PinPadMain.pas',
  GavetaMain in 'GavetaMain.pas',
  GavetaMenno in 'GavetaMenno.pas',
  ComDrv32 in 'ComDrv32.pas',
  ImpCupomMain in 'ImpCupomMain.pas',
  ImpCupomBematech in 'ImpCupomBematech.pas',
  FormSigtron in 'FormSigtron.pas' {FSigtron},
  ImpSigTron in 'ImpSigTron.pas',
  ImpYanco in 'ImpYanco.pas',
  LeitorMain in 'leitorMain.pas',
  LeitorMetrologic in 'LeitorMetrologic.pas',
  ImpProComp in 'ImpProComp.pas',
  ImpIBM in 'ImpIBM.pas',
  DisplayIBM in 'DisplayIBM.pas',
  DisplayMain in 'DisplayMain.pas',
  GavetaIBM in 'GavetaIBM.pas',
  LeitorIBM in 'LeitorIBM.pas',
  sndkey32 in 'Sndkey32.pas',
  ImpPertoChek in 'ImpPertoChek.pas',
  ImpItautec in 'ImpItautec.pas',
  ImpECFEmulator in 'ImpECFEmulator.pas',
  ImpCheqChronos in 'ImpCheqChronos.pas',
  ImpChSchalter in 'ImpChSchalter.pas',
  ImpMecaf in 'ImpMecaf.pas',
  PinPad_SC552_CHIP in 'PinPad_SC552_Chip.pas',
  u_SITEF in 'u_SITEF.PAS',
  ImpEpson in 'ImpEpson.pas',
  ImpPertoPay in 'ImpPertoPay.pas',
  LeitorSymbol in 'LeitorSymbol.pas',
  ImpFisHasar in 'ImpFisHasar.pas',
  ImpUranoLoggerII in 'ImpUranoLoggerII.pas',
  DisplayFourth in 'DisplayFourth.pas',
  BalancaMain in 'BalancaMain.pas',
  BalancaFilizola in 'BalancaFilizola.pas',
  DisplayGertec in 'DisplayGertec.pas',
  ImpFiscSchalter in 'ImpFiscSchalter.pas',
  DisplayTorGertec in 'DisplayTorGertec.pas',
  DisplayTorMain in 'DisplayTorMain.pas',
  ImpSwedaMFD in 'ImpSwedaMFD.pas',
  BalancaToledo in 'BalancaToledo.pas',
  DisplayTorDaruma in 'DisplayTorDaruma.pas',
  ImpNFiscEpson in 'ImpNFiscEpson.pas',
  ImpNFiscMain in 'ImpNFiscMain.pas',
  ImpNFiscBema in 'ImpNFiscBema.pas',
  ImpDarumaFrame in 'ImpDarumaFrame.pas',
  ImpNFiscDaruma in 'ImpNFiscDaruma.pas',
  ImpNfEmulador in 'ImpNfEmulador.pas',
  BalancaEmulador in 'BalancaEmulador.pas',
  ImpNFiscElgin in 'ImpNFiscElgin.pas',
  ImpNFiscE1DLL in 'ImpNFiscE1DLL.pas',
  FultronicFs80H in 'FultronicFs80H.pas';

{$R *.res}

type
  TMyClientSocket = class(TClientSocket)
  private
    procedure TrataErroSocket(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure TrataDisconnect(Sender: TObject; Socket: TCustomWinSocket);
  protected
  published
  public
  end;

var
  sDLLVER : String;
  ClientSocket: TMyClientSocket;
  lError : Boolean;
  aFuncName : array [0..999] of String;

{
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJDLLVer  ºAutor  ³Mauro Mancio        º Data ³  16/04/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de versoes da DLL SIGALOJA.DLL                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA e SIGAFRT                                         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ VERSAO ³Prograd.³ALTERACAO                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³        ³ 9.9.99.99                                ³±±
±±³          ³        ³        ³ - - -- --                                ³±±
±±³          ³        ³        ³ | |  |  |                                ³±±
±±³          ³        ³        ³ | |  |  +--> ID                          ³±±
±±³          ³        ³        ³ | |  +-----> Qtd.de Eqtos. Homologados   ³±±
±±³          ³        ³        ³ | +--------> Versao da DLL               ³±±
±±³          ³        ³        ³ +----------> Sempre sero. Para manter a  ³±±
±±³          ³        ³        ³              compatibilidade entre Delphi³±±
±±³          ³        ³        ³              e Protheus.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³16/04/2001³0.2.36.1³Cesar V ³ DLL - Criacao do ID da DLL               ³±±
±±³16/04/2001³0.2.36.1³Cesar V ³ AP5 - Alteracao na funcao IFAbrir()      ³±±
±±³07/05/2001³0.2.36.2³Marcos  ³ Incluido Parametro funcao AbreCupom, CGC ³±±
±±³          ³        ³        ³ Cliente BEMATECH                         ³±±
±±³09/05/2001³0.2.36.3³A.Veiga ³ Inclusao do Status 11 que indica se eh   ³±±
±±³          ³        ³        ³ um ECF ou um Emulador de ECF que esta    ³±±
±±³          ³        ³        ³ sendo utilizado (0=Emulador, 1=ECF)      ³±±
±±³          ³        ³        ³ Inclusao de mais um parametro na funcao  ³±±
±±³          ³        ³        ³ de impressao de cheque.                  ³±±
±±³24/05/2001³0.2.37.3³A.Veiga ³ Inclusao da Impressora Itautec POS4000   ³±±
±±³          ³        ³        ³ ECF-IF/1E II (Eprom 1.00)                ³±±
±±³08/06/2001³0.2.37.4³CesarVal³ Inclusao do Status 12 que indica se eh   ³±±
±±³          ³        ³        ³ o ECF possui as funcoes IFNumItem e      ³±±
±±³          ³        ³        ³ IFSubTotal.                              ³±±
±±³08/01/2002³0.2.42.10³A.Veiga³ Inclusao da Impressora Mecaf FCP (201 e  ³±±
±±³          ³         ³       ³ 500 )                                    ³±±
±±³02/08/2002³0.2.45.14³Adriann³ Inclusao da Impressora EPSON, alteracao  ³±±
±±³          ³         ³       ³ na funcao de cheque, para receber "|" no ³±±
±±³          ³         ³       ³ lugar de ',' como separador de parametros³±±
±±³17/09/2002³0.2.48.14³Marcos ³ Inclusao de 2 novos modelos de pinpad    ³±±
±±³          ³         ³       ³ Dione SOLO 2005 CHIP e Schlunberger      ³±±
±±³          ³         ³       ³ Magic 1800 CHIP                          ³±±
±±³17/09/2002³0.2.48.15³Adriann³ Inclusao da parametro FOCO para Scanners ³±±
±±³17/09/2002³0.2.49.15³Adriann³ Inclusao da IF Zanthus QZ1001, 100%      ³±±
±±³          ³         ³       ³ compatível com a MECAF FCP201 conforme   ³±±
±±³          ³         ³       ³ ATO COTEPE/ICMS Nº16, DE 19 DE JUNHO DE  ³±±
±±³          ³         ³       ³ 2001                                     ³±±
±±³17/09/2002³0.2.49.16³Adriann³ Inclusao da Função PEDIDO implementada   ³±±
±±³          ³         ³       ³ somente na IF Itautec                    ³±±
±±³16/10/2002³0.2.51.16³Adriann³ Inclusao do Scanner SYMBOL MT 1800       ³±±
±±³30/10/2002³0.2.51.17³A.Veiga³ Inclusão de um parâmetro na função de    ³±±
±±³          ³         ³       ³ Abertura de cupom não fiscal             ³±±
±±³08/01/2002³0.2.51.18³Adriann³ Inclusão de CRO - Contador de Reinício de ±±
±±³          ³         ³       ³ Operação                                 ³±±
±±³13/01/2002³0.2.52.18³Adriann³ Inclusão do Leitor de CMC7 - Sweda       ³±±
±±³13/12/2006³0.3.90.1 ³Mauro S³ Retirado o tratamento anterior da leitura³±±
±±³          ³         ³       ³ da versão do arquivo em memoria, pois    ³±±
±±³          ³         ³       ³ estava ocasionando em alguns casos       ³±±
±±³          ³         ³       ³ esgotamento de memória no Remote.        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
}

FUNCTION LJDLLVER(const Filename : string): String;
Var
  sVersao : String;
Begin
  sVersao := GetVersao('SIGALOJA.DLL') + ' - ' + GetDataHoraArq('SIGALOJA.DLL');
  Result  := sVersao
end;

//------------------------------------------------------------------------------
function RetFuncName( i : Integer ) : String;
begin
  Result := aFuncName[i];
end;

//------------------------------------------------------------------------------
function LogDLL : Boolean;
var
  sPath,sRet : String;
  bRet : Boolean;
  fArquivo : TIniFile;
begin
   // Pega o Path da SIGALOJA.DLL
   sPath := ExtractFilePath(Application.ExeName);
   bRet  := False;
   
   try
      fArquivo := TIniFile.Create(sPath+'SIGALOJA.INI');

      sRet := fArquivo.ReadString('LogDLL', 'Log', '');

      If (Trim(sRet) = '') //Ativo o Log Automaticamente
      then fArquivo.WriteString('LogDLL','Log','1')
      else
      begin
         If sRet = '0'
         then bRet := False
         else bRet := True;
      end;

      //Define tamanho do Log ( em KBytes -> 5000 Kbytes  )
      If Trim(fArquivo.ReadString('LogDLL','TamanhoLog','')) = ''
      then fArquivo.WriteString('LogDLL','TamanhoLog','5000');

      Result := bRet;
      fArquivo.Free;
   except
      Result := bRet;
   end;
end;


// aFuncID   -> Código identificador da função
// aParams   -> Parâmetros passados para a função
// aBuff     -> Retorno da função
// Buff_Size -> Tamanho do buffer de retorno pré-alocado em advpl (Ex: cMane := Space(20))
function ExecInClientDLL( aFuncID : integer; aParams, aBuff:Pchar; Buff_Size : integer ): Integer; stdcall;
var
  nRet   : Integer;
  sParam : TStringList;
  pPar1,pPar2,pPar3,pPar4 : pChar;
  nPos : Integer;
  sString,sSeparador : String;
  sBuffer : String;
  pMsgErro : PChar;
  pPath : PChar;

  Base64Biometria: string;
  TamBiometria: Integer;
  cValicaoBiometria: string;
begin
  LogDLL;
  ClearLog;
  GravaLog(' -> '+RetFuncName(aFuncID)+'('+aParams+')');
  nRet := -1;

  if ClientSocket <> Nil then
  begin
    // Verifica o status da conexão Socket.
    if ClientSocket.Socket.Connected then
      // Transfere via Socket os comandos da SIGALOJA.DLL do Remote para o APTSC.
      ClientSocket.Socket.SendText(IntToStr(aFuncID)+#1+aParams)
    else
      lError := True;
    // Recebe via Socket, os comandos da SIGALOJA.DLL do APTSC.
    while (not lError) And (ClientSocket.Socket.ReceiveLength = 0) do
    begin
      Application.ProcessMessages;
      Sleep(100);
    end;
    // Falha na recepcao via Socket.
    if lError then
      nRet := 1
    else
    begin
      sBuffer := ClientSocket.Socket.ReceiveText;
      nPos := Pos(#1,sBuffer);
      nRet := StrToInt(Copy(sBuffer,nPos+1,20000));
      sBuffer := Copy(sBuffer,1,nPos-1);
      StrPCopy(aBuff,sBuffer);
    end;
    Result := nRet;
    exit;
  end;
  if lError then
  begin
    Result := 1;
    exit;
  end;

  sParam := TStringList.Create;

  if (aFuncID = 66) or (aFuncID = 23) or (aFuncID = 34) or (aFuncID = 22) or (aFuncID = 77)
  or (aFuncID = 41) or ( aFuncID = 113 ) or (aFuncID = 15) or (aFuncID = 49) or (aFuncID = 126) then
    sSeparador := '|'
  else
  If aFuncID = 133 then //INFTEXTO
    sSeparador := '\'
  else
    sSeparador := ',';

  sString := copy(StrPas(aParams),1,Length(StrPas(aParams)) );
  While True do
  begin
    nPos := Pos(sSeparador,sString);
    if nPos = 0 then
    begin
      sParam.Add( sString );
      break;
    end;
    sParam.Add( copy(sString,1,nPos-1) );
    sString := copy(sString,nPos+1,Length(sString));
  end;

  try
    case aFuncID of
      // ID da SIGALOJA.DLL
      999: begin
             //  No Win98, ocorria um erro na validação da versão da DLL
             //("Existe incompatibilidades entre versão do Repositório e a DLL Fiscal..."),
             // Esse erro ocorria, pq a função 999 não estava retornando a resposta corretamente.
             // A inserção da chamada CreateMessageDialog() solucionou o problema. Essa melhoria
             // só estárá em campo após bateria de testes do Depto. Qualidade.
             CreateMessageDialog('CreateMessageDialog', mtCustom, [mbOK]);
             nRet := 0;
             StrCopy(aBuff, PChar(sDLLVER));
           end;
      // Socket - AP Terminal Services Client
      998: begin
             ClientSocket := TMyClientSocket.Create(Application);
             with ClientSocket do
             begin
               Host         := sParam[0];
               Port         := StrToInt(sParam[1]);
               Open;
               lError       := False;
               OnError      := TrataErroSocket;
               OnDisconnect := TrataDisconnect;
             end;
             nRet := 0;
           end;
      // Versão compatível Protheus
      997: begin
             CreateMessageDialog('CreateMessageDialog', mtCustom, [mbOK]);
             nRet := 0;
             StrCopy(aBuff, PChar('11'));
           end;
      996: begin
             pPath := StrAlloc(100);
             GetSystemDirectory(pPath, 100);
             nRet := 0;
             StrCopy(aBuff,pPath);
           end;
      // Impressora Fiscal
      0  : nRet := ImpFiscAbrir( pChar(sParam[0]), pChar(sParam[1]), StrToInt(sParam[2]) );
      1  : nRet := ImpFiscFechar( StrToInt(sParam[0]), pChar(sParam[1]) );
      2  : nRet := ImpFiscListar( aBuff );
      3  : nRet := ImpFiscLeituraX( StrToInt(sParam[0]) );
      4  :
        begin
          StrPCopy(aBuff,sParam[1]);
          nRet := ImpFiscReducaoZ( StrToInt(sParam[0]),aBuff  );
        end;
      5  : nRet := ImpFiscAbreCupom( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]) );
      6  : nRet := ImpFiscPegaCupom( StrToInt(sParam[0]),aBuff, Pchar(sParam[1]) );
      7  : nRet := ImpFiscPegaPDV( StrToInt(sParam[0]),aBuff );
      8  : nRet := ImpFiscRegistraItem( StrToInt(sParam[0]),pChar(sParam[1]),pChar(sParam[2]),pChar(sParam[3]),pChar(sParam[4]),pChar(sParam[5]),pChar(sParam[6]),pChar(sParam[7]),pChar(sParam[8]),StrToInt(sParam[9]));
      9  : nRet := ImpFiscLeAliquotas( StrToInt(sParam[0]),aBuff );
      10 : nRet := ImpFiscLeAliquotasISS( StrToInt(sParam[0]),aBuff );
      11 : nRet := ImpFiscLeCondPag( StrToInt(sParam[0]),aBuff );
      12 : nRet := ImpFiscGravaCondPag( StrToInt(sParam[0]),pChar(sParam[1]));
      13 : nRet := ImpFiscCancelaItem( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]), pChar(sParam[5]), pChar(sParam[6]), pChar(sParam[7]));
      14 : nRet := ImpFiscCancelaCupom( StrToInt(sParam[0]), pChar(sParam[1]));
      15 :
        begin
          StrPCopy(aBuff,sParam[1]);
          nRet := ImpFiscFechaCupom( StrToInt(sParam[0]),aBuff );
        end;
      16 : nRet := ImpFiscPagamento( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]));
      17 : nRet := ImpFiscDescontoTotal( StrToInt(sParam[0]), pChar(sParam[1]), StrToInt(sParam[2]));
      18 : nRet := ImpFiscAcrescimoTotal( StrToInt(sParam[0]), pChar(sParam[1]) );
      19 : nRet := ImpFiscMemoriaFiscal( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]) , pChar(sParam[3]), pChar(sParam[4]), pChar(sParam[5]) );
      20 : nRet := ImpFiscAdicionaAliquota( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]) );
      21 : nRet := ImpFiscAbreCupomNaoFiscal( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]) );
      22 : nRet := ImpFiscReImpCupomNaoFiscal( StrToInt(sParam[0]), pChar(sParam[1]) );
      23 : nRet := ImpFiscTextoNaoFiscal( StrToInt(sParam[0]), pChar(sParam[1]),StrToInt(sParam[2]) );
      24 : nRet := ImpFiscFechaCupomNaoFiscal( StrToInt(sParam[0]) );
      25 : nRet := ImpFiscStatus( StrToInt(sParam[0]), pChar(sParam[1]), aBuff );
      26 : nRet := ImpFiscTotalizadorNaoFiscal( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]) );
      27 : nRet := ImpFiscAutenticacao( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]) );
      28 : nRet := ImpFiscGaveta( StrToInt(sParam[0]) );
      29 : nRet := ImpCheque( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]), pChar(sParam[5]), pChar(sParam[6]), pChar(sParam[7]), pChar(sParam[8]) );
      30 : nRet := ImpFiscAbreECF( StrToInt(sParam[0]) );
      31 : nRet := ImpFiscFechaECF( StrToInt(sParam[0]) );
      32 : nRet := ImpFiscSuprimento( StrToInt(sParam[0]),StrToInt(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]), StrToInt(sParam[5]), pChar(sParam[6]));
      33 : nRet := ImpFiscHorarioVerao ( StrToInt(sParam[0]), pChar(sParam[1]) );
      34 : nRet := ImpFiscRelatorioGerencial ( StrToInt(sParam[0]), pChar(sParam[1]),StrToInt(sParam[2]),pChar(sParam[3]));
      35 : nRet := ImpFiscAlimentaPropEmulECF ( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]) );
      36 : nRet := ImpFiscPegaSerie( StrToInt(sParam[0]),aBuff );
      37 : nRet := ImpFiscImpostosCupom(StrToInt(sParam[0]),PChar(sParam[1]));
      38 : nRet := ImpFiscPedido( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]), pChar(sParam[5]) );
      39 : nRet := ImpFiscEnvCmd( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), aBuff );
      40 : nRet := ImpFiscRecebNFis( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]) );
      41 : nRet := ImpFiscPercepcao( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]));
      42 : nRet := ImpFiscAbreDNFH(StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]), pChar(sParam[5]), pChar(sParam[6]), aBuff);
      43 : nRet := ImpFiscFechaDNFH(StrToInt(sParam[0]));
      44 : nRet := ImpFiscTextoRecibo(StrToInt(sParam[0]), pChar(sParam[1]));
      45 : nRet := ImpFiscReImprime(StrToInt(sParam[0]));
      46 : nRet := ImpFiscMemTrab( StrToInt(sParam[0]), aBuff );
      47 : nRet := ImpFiscCapacidade( StrToInt(sParam[0]), aBuff );
      48 :
        begin
          StrPCopy(aBuff,sParam[1]);
          nRet := ImpFiscAbreNota( StrToInt(sParam[0]),aBuff  );
        end;
      49 : nRet := ImpFiscRelGerInd(StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), StrToInt(sParam[3]), pChar(sParam[4]));

      // Leitor PinPad
      50 : nRet := PinPad_Listar( aBuff );
      51 : nRet := PinPad_Abrir( pChar(sParam[0]),pChar(sParam[1]) );
      52 : nRet := PinPad_LeCartao( StrToInt(sParam[0]),sParam[1],aBuff );
      53 :
        begin
          pPar1 := StrAlloc(1024);
          pPar2 := StrAlloc(1024);
          pPar3 := StrAlloc(1024);
          pPar4 := StrAlloc(1024);
          StrPcopy(pPar1,sParam[1]);
          StrPcopy(pPar2,sParam[2]);
          StrPcopy(pPar3,sParam[3]);
          StrPcopy(pPar4,sParam[4]);
          nRet := PinPad_LeSenha(StrToInt(sParam[0]),pPar1,pPAr2,pPar3,pPar4);
          StrCopy(aBuff,PChar( String(pPar1) + ',' + String(pPar2) + ',' + String(pPar3) + ',' + String(pPar4) ));
        end;
      54 : nRet := PinPad_Finaliza( StrToInt(sParam[0]) );
      // Leitor CMC7
      55 : nRet := CMC7_Listar( aBuff );
      56 : nRet := CMC7_Abrir( pChar(sParam[0]),pChar(sParam[1]), pChar(sParam[2]) );
      57 : nRet := CMC7_Fechar( StrToInt(sParam[0]) );
      58 : nRet := CMC7_LeDocumento( StrToInt(sParam[0]),aBuff );
      // Gaveta Serial
      59 : nRet := Gaveta_Listar( aBuff );
      60 : nRet := Gaveta_Abrir( pChar(sParam[0]),pChar(sParam[1]) );
      61 : nRet := Gaveta_Fechar( StrToInt(sParam[0]), pChar(sParam[1]) );
      62 : nRet := Gaveta_Acionar( StrToInt(sParam[0]), pChar(sParam[1]) );
      // Impressora de Cupom
      63 : nRet := Imp_Listar( aBuff );
      64 : nRet := Imp_Abrir( pChar(sParam[0]),pChar(sParam[1]) );
      65 : nRet := Imp_Fechar( StrToInt(sParam[0]),pChar(sParam[1]) );
      66 : nRet := Imp_Imprimir( StrToInt(sParam[0]),pChar(sParam[1]) );
      // Leitor Optico Serial
      67 : nRet := Leitor_Listar( aBuff );
      68 : nRet := Leitor_Abrir( pChar(sParam[0]),pChar(sParam[1]), pChar(sParam[2]) );
      69 : nRet := Leitor_Fechar( StrToInt(sParam[0]), pChar(sParam[1]) );
      70 : nRet := Leitor_Foco( StrToInt(sParam[0]), StrToInt(sParam[1]) );
      // Display
      72 : nRet := Display_Listar( aBuff );
      73 : nRet := Display_Abrir( pChar(sParam[0]),pChar(sParam[1]) );
      74 : nRet := Display_Fechar( StrToInt(sParam[0]), pChar(sParam[1]) );
      75 : nRet := Display_Escrever( StrToInt(sParam[0]), pChar(sParam[1]) );
      // Impressora de Cheque
      76 : nRet := ImpCheqAbrir ( pChar(sParam[0]), pChar(sParam[1]) );
      77 : nRet := ImpCheqImpr  ( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]), PChar(sParam[3]), PChar(sParam[4]), PChar(sParam[5]), PChar(sParam[6]), PChar(sParam[7]), PChar(sParam[8]), PChar(sParam[9]), PChar(sParam[10]) );
      78 : nRet := ImpCheqFecha ( StrToInt(sParam[0]), PChar(sParam[1]) );
      79 : nRet := ImpCheqListar( aBuff );

      80 : nRet := ImpFiscSubTotal( StrToInt(sParam[0]), Pchar(sParam[1]), aBuff );
      81 : nRet := ImpFiscNumItem( StrToInt(sParam[0]), aBuff );
      82 : nRet := CMC7_LeDocCompleto( StrToInt(sParam[0]),aBuff );
      83 : nRet := Gaveta_Status( StrToInt(sParam[0]),PChar(sParam[1]) );
      84 : nRet := ImpCheqStatus( StrToInt(sParam[0]), pChar(sParam[1]), aBuff );

      // Balancas Seriais
      85 : nRet := Balanca_PegaPeso( StrToInt(sParam[0]),aBuff );
      86 : nRet := Balanca_Abrir( pChar(sParam[0]),pChar(sParam[1]) );
      87 : nRet := Balanca_Fechar( StrToInt(sParam[0]), pChar(sParam[1]) );
      88 : nRet := Balanca_Listar( aBuff );

      // Criptografia do Sitef
      90 : nRet := MsCodSitef( aParams , aBuff );
      91 : nRet := MsDecSitef( aParams , aBuff );

      // Impressora Fiscal Restaurante
      100 : nRet := ImpFiscAbreCupomRest( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]) );
      101 : nRet := ImpFiscRegistraItemRest( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]), PChar(sParam[3]), PChar(sParam[4]), PChar(sParam[5]), PChar(sParam[6]), PChar(sParam[7]), PChar(sParam[7]));
      102 : nRet := ImpFiscConferenciaMesa( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]), PChar(sParam[3]));
      103 : nRet := ImpFiscImprimeCardapio( StrToInt(sParam[0]));
      104 : nRet := ImpFiscLeCardapio( StrToInt(sParam[0]));
      105 : nRet := ImpFiscLeMesasAbertas( StrToInt(sParam[0]), aBuff);
      106 : nRet := ImpFiscLeRegistrosVendaRest( StrToInt(sParam[0]), PChar(sParam[1]),aBuff);
      107 : nRet := ImpFiscFechaCupomMesa( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]), PChar(sParam[3]), PChar(sParam[4]));
      108 : nRet := ImpFiscFechaCupContaDividida( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]), PChar(sParam[3]), PChar(sParam[4]), PChar(sParam[5]), PChar(sParam[6]));
      109 : nRet := ImpFiscTransfMesas( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]));
      110 : nRet := ImpFiscTransfItem( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]), PChar(sParam[3]), PChar(sParam[4]), PChar(sParam[5]), PChar(sParam[6]), PChar(sParam[7]), PChar(sParam[8]), PChar(sParam[9]));
      111 : nRet := ImpFiscCancelaItemRest( StrToInt(sParam[0]), PChar(sParam[1]), PChar(sParam[2]), PChar(sParam[3]), PChar(sParam[4]), PChar(sParam[5]), PChar(sParam[6]), PChar(sParam[7]), PChar(sParam[8]));
      112 : nRet := ImpFiscRelatMesasAbertas( StrToInt(sParam[0]), PChar(sParam[1]));

      113: nRet := ImpCheqImprTransf( StrToInt( sParam[0] ), PChar( sParam[1] ), PChar( sParam[2] ), PChar( sParam[3] ), PChar( sParam[4] ), PChar( sParam[5] ), PChar( sParam[6] ), PChar( sParam[7] ) );

      // Display Torre
      114 : nRet := DispTor_Listar( aBuff );
      115 : nRet := DispTor_Abrir( pChar(sParam[0]),pChar(sParam[1]) );
      116 : nRet := DispTor_Fechar( StrToInt(sParam[0]), pChar(sParam[1]) );
      117 : nRet := DispTor_Escrever( StrToInt(sParam[0]), pChar(sParam[1]) );

      // Impressora Fiscal térmica
      118 : nRet := ImpFiscDownMFD( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]) );

      // Trava Teclado para Homologação TEF
      119 : Begin
              BlockInput(true);
              nRet:=0;
            End;

      // Destrava Teclado para Homologação TEF
      120 : Begin
              BlockInput(false);
            End;

      // Impressora Fiscal térmica
      121 : nRet := ImpFiscGerRegTipoE( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]),  pChar(sParam[5]), pChar(sParam[6]));

      // Impressora Fiscal ARG - Bonificação
      122 : nRet := ImpFiscReturnRecharge( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]), pChar(sParam[4]), StrToInt(sParam[5]) );

      123 : nRet := ImpFiscGeraArquivoMFD( StrToInt(sParam[0]), pChar(sParam[1])  , pChar(sParam[2]), pChar(sParam[3]) );
      124 : nRet := ImpFiscLeTotNFisc (  StrToInt(sParam[0]),aBuff ) ;
      125 : nRet := ImpFiscDownMF( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]) );

      // Impressora Fiscal - Impressao de Código de Barras
      126 : nRet := ImpFiscCodBarrasITF ( StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]),StrToInt(sParam[4]));
      127 : nRet := ImpFiscIdCliente( StrToInt(sParam[0]) , pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]) );
      128 : nRet := ImpFiscEstornNFiscVinc( StrToInt(sParam[0]) , pChar(sParam[1]), pChar(sParam[2]), pChar(sParam[3]) , pChar(sParam[4]) , pChar(sParam[5]));
      129 : begin
              StrPCopy(aBuff,sParam[1]);
              nRet := ImpFiscRedZDado(StrToInt(sParam[0]),aBuff );
            end;

      //FUNÇÕES DA IMPRESSORA NÃO FISCAL
      130  : nRet := ImpNFiscListar( aBuff );
      131  : nRet := ImpNFiscAbrir( pChar(sParam[0]), pChar(sParam[1]), StrToInt(sParam[2]) , StrToInt(sParam[3]));
      132  : nRet := ImpNFiscFechar( StrToInt(sParam[0]), pChar(sParam[1]) );
      133  : nRet := ImpNFiscImpTexto( StrToInt(sParam[0]), pChar(sParam[1]) );
      134  : nRet := ImpNFiscBitmap(StrToInt(sParam[0]), pChar(sParam[1]));
      135  : nRet := ImpNFiscCodeBar(StrToInt(sParam[0]), pChar(sParam[1]), pChar(sParam[2]));

      //Comando para Impressoras da Argentina
      136  : nRet := ImpFiscImpTxtFis( StrToInt(sParam[0]),pChar(sParam[1]) );

      //Função Impressora não-fiscal
      137  : nRet := ImpNFiscAbrGvt( StrToInt(sParam[0]) );

      //Grava QrCode em arquivo da Impressora Fiscal
      138  : nRet := ImpFiscGrvQrCode( StrToInt(sParam[0]) , pChar(sParam[1]) , pChar(sParam[2]));

      //Comandos para Substiuir a Pedido(desmembramento dos comandos)
      139  : nRet := ImpFiscAbreCNF(StrToInt(sParam[0]) , pChar(sParam[1]) , pChar(sParam[2]), pChar(sParam[3]));
      140  : nRet := ImpFiscRecCNF(StrToInt(sParam[0]) , pChar(sParam[1]) , pChar(sParam[2]), pChar(sParam[3]),pChar(sParam[4]));
      141  : nRet := ImpFiscPgtoCNF(StrToInt(sParam[0]) , pChar(sParam[1]) , pChar(sParam[2]), pChar(sParam[3]) , pChar(sParam[4]) , pChar(sParam[5]));
      142  : nRet := ImpFiscFechaCNF(StrToInt(sParam[0]) , pChar(sParam[1]));
      143  : nRet := ImpNFiscStatus(StrToInt(sParam[0]) , pChar(sParam[1]), aBuff);

      //Comandos para o leitor biometrico modelo futronic fs80h
      144:  begin
              nRet := OpenDllFtrAPI();
              
              if nRet = 0 then
              begin
                nRet := CapturarBiometria(Base64Biometria, TamBiometria);
                if nRet = 0 then
                  StrCopy(aBuff, PChar(Base64Biometria + ',' + IntToStr(TamBiometria)))
                else
                  StrCopy(aBuff, PChar(''));
              end
              else
              begin
                StrCopy(aBuff, PChar(''));
              end;

            end;
      145:  begin
              nRet := OpenDllFtrAPI();

              if nRet = 0 then
              begin
                nRet := CompararBiometria(sParam[0], cValicaoBiometria);
                if nRet = 0 then
                  StrCopy(aBuff, PChar(cValicaoBiometria))
                else
                  StrCopy(aBuff, PChar(''));
              end
              else
              begin
                StrCopy(aBuff, PChar(''));
              end;
            end;
    else
      nRet := 1;
    end;
  except
    pMsgErro := PChar('***********************************************************************'+#10+
                      DateTimeToStr(Now)+#10+
                      'Erro ao tentar executar o comando '+RetFuncName(aFuncID)+#10+
                      'parâmetros enviados:'+aParams+#10+
                      'Verifique se os parâmetros informados estão de acordo com o periférico.'+#10+
                      'Verifique se o driver do fabricante está atualizado.'+#10+
                      'Verifique se seu equipamento está funcionando corretamente.'+#10+
                      '***********************************************************************');
    GravaLog(pMsgErro);
    Application.MessageBox(pMsgErro, 'SIGALOJA.DLL', MB_OK + MB_ICONERROR);
    nRet := 1;
  end;

  Result := nRet;
  try
      sParam.Free;
  except
  end;

  GravaLog(' <- '+IntToStr(nRet)+ ' - ['+aBuff+']');
end;

//------------------------------------------------------------------------------
procedure TMyClientSocket.TrataErroSocket(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ClientSocket.Close;
  ClientSocket := Nil;
  if ErrorEvent = eeConnect then
    Application.MessageBox('Não foi possível estabelecer conexão com o AP Terminal Services Client.',
          'SIGALOJA.DLL', MB_OK + MB_ICONERROR);
  lError := True;
  ErrorCode := 0;
end;

//------------------------------------------------------------------------------
procedure TMyClientSocket.TrataDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  ClientSocket.Close;
    Application.MessageBox('O AP Terminal Services Client foi desconectado...',
          'SIGALOJA.DLL', MB_OK + MB_ICONERROR);
  lError := True;
end;

//------------------------------------------------------------------------------
Exports
  // Essa será a única função lida pelo client do Protheus
  ExecInClientDLL,

  // Essas funções não podem ser excluídas da seção exports pq. são utilizadas
  // no AP5ECF.EXE
  ImpCheqAbrir,
  ImpCheqImpr,
  ImpCheqFecha,
  ImpCheqListar,
  ImpFiscAbrir,
  ImpFiscFechar,
  ImpFiscListar,
  ImpFiscLeituraX,
  ImpFiscReducaoZ,
  ImpFiscAbreCupom,
  ImpFiscPegaCupom,
  ImpFiscPegaPDV,
  ImpFiscRegistraItem,
  ImpFiscLeAliquotas,
  ImpFiscLeAliquotasISS,
  ImpFiscLeCondPag,
  ImpFiscGravaCondPag,
  ImpFiscCancelaItem,
  ImpFiscCancelaCupom,
  ImpFiscFechaCupom,
  ImpFiscPagamento,
  ImpFiscDescontoTotal,
  ImpFiscAcrescimoTotal,
  ImpFiscMemoriaFiscal,
  ImpFiscAdicionaAliquota,
  ImpFiscAbreCupomNaoFiscal,
  ImpFiscTextoNaoFiscal,
  ImpFiscFechaCupomNaoFiscal,
  ImpFiscReImpCupomNaoFiscal,
  ImpFiscStatus,
  ImpFiscTotalizadorNaoFiscal,
  ImpFiscAutenticacao,
  ImpFiscGaveta,
  ImpCheque,
  ImpFiscAbreECF,
  ImpFiscFechaECF,
  ImpFiscSuprimento,
  ImpFiscRelatorioGerencial,
  ImpFiscHorarioVerao,
  ImpFiscSubTotal,
  ImpFiscNumItem,
  ImpFiscImpostosCupom,
  ImpFiscPegaSerie,
  ImpFiscPedido,
  ImpFiscEnvCmd,
  ImpFiscRecebNFis,
  ImpFiscLeTotNFisc,
  ImpFiscDownMF,
  ImpFiscRedZDado,
  CMC7_Listar,
  CMC7_Abrir,
  CMC7_Fechar,
  CMC7_LeDocumento,
  CMC7_LeDocCompleto,
  Leitor_Listar,
  Leitor_Abrir,
  Leitor_Fechar,
  PinPad_Listar,
  PinPad_Abrir,
  PinPad_LeCartao,
  PinPad_LeSenha,
  PinPad_Finaliza,
  Gaveta_Listar,
  Gaveta_Abrir,
  Gaveta_Fechar,
  Gaveta_Acionar,
  Gaveta_Status,
  Imp_Listar,
  Imp_Abrir,
  Imp_Fechar,
  Imp_Imprimir,
  Display_Listar,
  Display_Abrir,
  Display_Fechar,
  Display_Escrever,
  MsCodSitef,
  MsDecSitef,
  DispTor_Listar,
  DispTor_Abrir,
  DispTor_Fechar,
  DispTor_Escrever,
  ImpFiscReturnRecharge,
  ImpFiscCodBarrasITF,
  ImpFiscIdCliente,
  ImpFiscEstornNFiscVinc,
  ImpNFiscAbrir,
  ImpNFiscFechar,
  ImpNFiscImpTexto,
  ImpNFiscBitmap,
  ImpNFiscCodeBar;

begin
  DecimalSeparator := '.';
  // Verificar a versao da DLL somente na inicialização.
  sDLLVER := LJDLLVER('SIGALOJA.DLL');
  aFuncName[999] := 'RetID';
  aFuncName[998] := 'AP6TSC';
  aFuncName[997] := 'VersaoProtheus';
  aFuncName[  0] := 'IFAbrir';
  aFuncName[  1] := 'IFFechar';
  aFuncName[  2] := 'IFListar';
  aFuncName[  3] := 'IFLeituraX';
  aFuncName[  4] := 'IFReducaoZ';
  aFuncName[  5] := 'IFAbrCup';
  aFuncName[  6] := 'IFPegCup';
  aFuncName[  7] := 'IFPegPDV';
  aFuncName[  8] := 'IFRegItem';
  aFuncName[  9] := 'IFLeAliq';
  aFuncName[ 10] := 'IFLeAliISS';
  aFuncName[ 11] := 'IFLeConPag';
  aFuncName[ 12] := 'IFGrvCondP';
  aFuncName[ 13] := 'IFCancItem';
  aFuncName[ 14] := 'IFCancCup';
  aFuncName[ 15] := 'IFFechaCup';
  aFuncName[ 16] := 'IFPagto';
  aFuncName[ 17] := 'IFDescTot';
  aFuncName[ 18] := 'IFAcresTot';
  aFuncName[ 19] := 'IFMemFisc';
  aFuncName[ 20] := 'IFAdicAliq';
  aFuncName[ 21] := 'IFAbrCNFis';
  aFuncName[ 22] := 'CHImprime';    // A IFCheque foi substituida pela CHImprime
  aFuncName[ 23] := 'IFTxtNFis';
  aFuncName[ 24] := 'IFFchCNFis';
  aFuncName[ 25] := 'IFStatus';
  aFuncName[ 26] := 'IFTotNFis';
  aFuncName[ 27] := 'IFAutentic';
  aFuncName[ 28] := 'IFGaveta';
  aFuncName[ 29] := 'IFCheque';
  aFuncName[ 30] := 'IFAbrECF';
  aFuncName[ 31] := 'IFFchECF';
  aFuncName[ 32] := 'IFSupr';
  aFuncName[ 33] := 'IFHrVerao';
  aFuncName[ 34] := 'IFRelGer';
  aFuncName[ 35] := 'IFEmulECF';
  aFuncName[ 36] := 'IFPegSerie';
  aFuncName[ 37] := 'ImpFiscImpostosCupom';
  aFuncName[ 38] := 'IFPedido';
  aFuncName[ 39] := 'ExecHSR';
  aFuncName[ 40] := 'IFRecebNFis';
  aFuncName[ 41] := 'IFPercepcao';
  aFuncName[ 42] := 'IFAbrirDNFH';
  aFuncName[ 43] := 'IFFecharDNFH';
  aFuncName[ 44] := 'IFRecibo';
  aFuncName[ 45] := 'IFReimprime';
  aFuncName[ 46] := 'IFMemTrab';
  aFuncName[ 47] := 'IFCapacity';
  aFuncName[ 48] := 'IFAbreNota';
  aFuncName[ 49] := 'IFRelMFisc';

  aFuncName[ 50] := 'PinPadLis';
  aFuncName[ 51] := 'PinPadAbr';
  aFuncName[ 52] := 'PinPadLeC';
  aFuncName[ 53] := 'PinPadLeS';
  aFuncName[ 54] := 'PinPadFin';

  aFuncName[ 55] := 'CMC7Lis';
  aFuncName[ 56] := 'CMC7Abr';
  aFuncName[ 57] := 'CMC7Fec';
  aFuncName[ 58] := 'CMC7LeD';

  aFuncName[ 59] := 'GavetaLis';
  aFuncName[ 60] := 'GavetaAbr';
  aFuncName[ 61] := 'GavetaFec';
  aFuncName[ 62] := 'GavetaAci';

  aFuncName[ 63] := 'ImpCupLis';
  aFuncName[ 64] := 'ImpCupAbr';
  aFuncName[ 65] := 'ImpCupFec';
  aFuncName[ 66] := 'ImpCupImp';

  aFuncName[ 67] := 'LeitorLis';
  aFuncName[ 68] := 'LeitorAbr';
  aFuncName[ 69] := 'LeitorFec';
  aFuncName[ 70] := 'LeitorFoco';

  aFuncName[ 72] := 'DisplayLis';
  aFuncName[ 73] := 'DisplayAbr';
  aFuncName[ 74] := 'DisplayFec';
  aFuncName[ 75] := 'DisplayEnv';

  aFuncName[ 76] := 'CHAbrir';
  aFuncName[ 77] := 'CHImprime';
  aFuncName[ 78] := 'CHFechar';
  aFuncName[ 79] := 'CHListar';
  aFuncName[ 80] := 'IFSubTotal';
  aFuncName[ 81] := 'IFNumItem';
  aFuncName[ 82] := 'CMC7LeDC';
  aFuncName[ 83] := 'GavetaStat';
  aFuncName[ 84] := 'ChStatus';
  aFuncName[ 85] := 'BalancaPegaPeso';
  aFuncName[ 86] := 'BalancaAbr';
  aFuncName[ 87] := 'BalancaFec';
  aFuncName[ 88] := 'BalancaLis';

  aFuncName[ 90] := 'CodSitef';
  aFuncName[ 91] := 'DecSitef';

  aFuncName[100] := 'IFRAbrCp';
  aFuncName[101] := 'IFRRegIt';
  aFuncName[102] := 'IFRConfM';
  aFuncName[103] := 'IFRImpCdp';
  aFuncName[104] := 'IFRLeCdp';
  aFuncName[105] := 'IFRLeMesas';
  aFuncName[106] := 'IFRLeRegVend';
  aFuncName[107] := 'IFRFchCup';
  aFuncName[108] := 'IFRFCDiv';
  aFuncName[109] := 'IFRTrfMesa';
  aFuncName[110] := 'IFRTrfItem';
  aFuncName[111] := 'IFRCancIt';
  aFuncName[112] := 'IFRRelMes';
  aFuncName[113] := 'CHImprTransf';

  aFuncName[114] := 'DispTorLis';
  aFuncName[115] := 'DispTorAbr';
  aFuncName[116] := 'DispTorFec';
  aFuncName[117] := 'DispTorEnv';

  aFuncName[118] := 'IFDownMFD';
  aFuncName[119] := 'BlockInput';
  aFuncName[120] := 'BlockInput';

  aFuncName[121] := 'IFGerRegTipoE';

  aFuncName[122] := 'IFRetRecharge';
  aFuncName[123] := 'IFGeraArquivoMFD';
  aFuncname[124] := 'IFLeTotNFisc';
  aFuncName[125] := 'IFDownMF';
  aFuncName[126] := 'IFCodBar';
  aFuncName[127] := 'IFIdCliente';
  aFuncName[128] := 'IFEstornNFiscVinc';
  aFuncName[129] := 'IFRedZDado';

  aFuncName[130] := 'INFLista';
  aFuncName[131] := 'INFAbrir';
  aFuncname[132] := 'INFFechar';
  aFuncName[133] := 'INFTexto';
  aFuncName[134] := 'INFBitmap';
  aFuncname[135] := 'INFCodebar';
  aFuncName[136] := 'IFImpTxtFis';
  aFuncName[137] := 'IFGaveta';
  aFuncName[143] := 'INFStatus';
end.
