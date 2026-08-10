unit ImpFisHasar;

interface

uses
  Dialogs,
  ImpFiscMain,
  ImpCheqMain,
  Windows,
  SysUtils,
  classes,
  IniFiles,
  Forms,
  LojxFun;
Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Hasar
///
  TImpFiscalHasarPR4F = class(TImpressoraFiscal)
  private
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    Function EnviaComando(aParams:String;sError:String=''):String;
    function Fechar( sPorta:String ):String; override;
    function LeituraX:String; override;
    function Status( Tipo: Integer;Texto:String ):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function PegaPDV:String; override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String; override;
    Function HasarCup( sTipo,sNumero:String):String;
    procedure AlimentaProperties; override;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function ImpostosCupom(Texto: String): String; override;
    function Gaveta:String; override;
    function AbreECF: String; override;
    function FechaECF: String; override;
    function PegaSerie: String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function GravaCondPag( condicao:string ) : String; override;
    function Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function SubTotal (sImprime: String):String;override;
    function EnvCmd( Comando:String; Posicao: Integer ): String; override;
    function ReImprime: String; override;
    function Percepcao(sAliqIVA, sTexto, sValor: String): String; override;
    function AbreDNFH( sTipoDoc, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc:String): String; override;
    function FechaDNFH: String; override;
    function TextoRecibo (sTexto: String): String; override;
    function MemTrab:String; override;
    function Capacidade:String; override;
    function AbreNota(Cliente:String):String; override;
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function RelatorioGerencial( Texto:String;Vias:Integer ; ImgQrCode: String):String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;
    function HorarioVerao( Tipo:String ):String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String; override;
    function TotalizadorNaoFiscal( Numero,Descricao:String ):String; override;
    function LeTotNFisc:String; override;
    function DownMF(sTipo, sInicio, sFinal : String):String; override;
    function RedZDado( MapaRes : String ):String; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
    function ImpTxtFis(Texto : String) : String; Override;
    function RelGerInd( cIndTotalizador,Texto: String; nVias: Integer; ImgQrCode: String): String; Override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
  end;

  TImpFiscalHasar320F = class(TImpFiscalHasarPR4F)
  private
  public
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String; override;
    function Gaveta:String; override;
    function PegaSerie: String; override;
    function SubTotal (sImprime: String):String;override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    procedure AlimentaProperties; override;
    function PegaCupom(Cancelamento:String):String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
  end;

  TImpFiscalHasar330F = class(TImpFiscalHasar320F)
  private
  public
     function StatusImp( Tipo:Integer ):String; override;
  end;

  TImpFiscalHasar435F = class(TImpFiscalHasar330F)
  private
  public
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String; override;
    function RelatorioGerencial( Texto:String;Vias:Integer ; ImgQrCode: String):String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function AbreDNFH( sTipoDoc, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: String): String; override;
    function FechaDNFH: String; override;
    function TextoRecibo (sTexto: String): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function ReImpCupomNaoFiscal( Texto:String ):String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:String ): String; override;
    function HorarioVerao( Tipo:String ):String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function SubTotal (sImprime: String):String;override;
    Function EnviaComando(aParams:String; sError:String=''):String;
    function Status( Tipo: Integer; Texto:String ):String; override;
    function ReImprime: String; override;
    function Percepcao(sAliqIVA, sTexto, sValor: String): String; override;
    function ReturnRecharge( sDescricao, sValor, sAliquota, sTipo : String; iTipoImp : Integer ):String; override;
  end;

  TImpFiscalHasarPL23 = class(TImpFiscalHasar435F)
  private
  public
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
  end;

  TImpFiscalHasarP441F = class(TImpFiscalHasar435F)
  private
  public
    function PegaSerie:String; override;
  end;

  //----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function Erro1(sErro,Tipo:String): String;
function HasarGetCmd( sCmd : String ) : String;
procedure HasarLog( Arquivo,Texto:String; bStamp:Boolean=TRUE );

implementation
Const
  MODE_ANSI  = 1;
  MODE_ASCII = 0;
var
  fHandle : THandle;
  iHandle : LongInt;
  sTipoCup: String;
  sPDV    : String;
  multiLine : boolean;
  bFatTic   : boolean; //indica se a foi aberto uma Fatura ou Ticket
  sSerie    : String;  //indica a serie da fatura aberta

  fFuncMandaPaqueteFiscal   : function (Handler: LongInt; Buffer: String): LongInt ; StdCall;
  fFuncUltimoStatus         : function (Handler: LongInt; var FiscalStatus: Integer; var PrinterStatus: Integer): LongInt ; StdCall;
  fFuncUltimaRespuesta      : function (Handler: LongInt; var Buffer: array of char): LongInt ; StdCall;
  fFuncOpenComFiscal        : function (Puerto, Mode: LongInt): LongInt ; StdCall;
  fFuncCloseComFiscal       : function (Handler: LongInt): LongInt ; StdCall;
  fFuncInitFiscal           : function (Handler: LongInt): LongInt ; StdCall;
  fFuncVersionDLLFiscal     : function (): LongInt ; StdCall;
  fFuncBusyWaitingMode      : function (Mode: LongInt) : LongInt; StdCall;
  fFuncCambiarVelocidad     : function (Handler, NewSpeed: LongInt): LongInt ; StdCall;
  fFuncProtocolMode         : function (Mode: LongInt) : LongInt; StdCall;
  fFuncSearchPrn            : function (Handler: LongInt): LongInt ; StdCall;

function TImpFiscalHasarPR4F.Abrir(sPorta : String; iHdlMain:Integer) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
       begin
       ShowMessage('A função "'+sMsg+'" não existe na Dll: WINFIS32.DLL');
       Result := False;
       end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;
  IniFile : TIniFile;
begin
  fHandle := LoadLibrary( 'WINFIS32.DLL' );
  if (fHandle <> 0) Then
    begin
    bRet := True;
    aFunc := GetProcAddress(fHandle,'MandaPaqueteFiscal');
    if ValidPointer( aFunc, 'MandaPaqueteFiscal') then
       fFuncMandaPaqueteFiscal := aFunc
    else
       begin
       bRet := False;
       end;

    aFunc := GetProcAddress(fHandle,'UltimoStatus');
    if ValidPointer( aFunc, 'UltimoStatus' ) then
      fFuncUltimoStatus := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'UltimaRespuesta');
    if ValidPointer( aFunc, 'UltimaRespuesta' ) then
      fFuncUltimaRespuesta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'OpenComFiscal');
    if ValidPointer( aFunc, 'OpenComFiscal' ) then
      fFuncOpenComFiscal := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'CloseComFiscal');
    if ValidPointer( aFunc, 'CloseComFiscal' ) then
      fFuncCloseComFiscal := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'InitFiscal');
    if ValidPointer( aFunc, 'InitFiscal' ) then
      fFuncInitFiscal := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'VersionDLLFiscal');
    if ValidPointer( aFunc, 'VersionDLLFiscal' ) then
      fFuncVersionDLLFiscal := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'BusyWaitingMode');
    if ValidPointer( aFunc, 'BusyWaitingMode' ) then
      fFuncBusyWaitingMode := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'CambiarVelocidad');
    if ValidPointer( aFunc, 'CambiarVelocidad' ) then
      fFuncCambiarVelocidad := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ProtocolMode');
    if ValidPointer( aFunc, 'ProtocolMode' ) then
      fFuncProtocolMode := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'SearchPrn');
    if ValidPointer( aFunc, 'SearchPrn' ) then
      fFuncSearchPrn := aFunc
    else
    begin
      bRet := False;
    end;
    end
  else
    Begin
    ShowMessage('O arquivo WinFis32.DLL não foi encontrado.');
    bRet := False;
    end;
  Result:='1|';
  if bRet then
     Begin
     iHandle := fFuncOpenComFiscal(StrToInt(Copy(sPorta,4,1)), MODE_ANSI);
     iRet:=iHandle;
     If iHandle >= 0 Then
     Begin
        EnviaComando(#102);
        EnviaComando(#150);
        IniFile := TIniFile.Create(ExpandFileName('sigaloja.ini'));
        multiLine := false;
        if ( iRet >= 0 ) and IniFile.SectionExists('hasar') then
        Begin
           fFuncCambiarVelocidad(ihandle,IniFile.ReadInteger('hasar','boundrate',9600));
           multiLine := (IniFile.ReadInteger('hasar','multiline',0) = 1);
        end;
        iRet:= fFuncInitFiscal(iHandle);
        if (IniFile.SectionExists('hasar'))  AND (iRet >= 0 ) then 
        Begin
           EnviaComando(#160 + '|'+IniFile.ReadString('hasar','boundrate','9600'));
        end;
        If (iRet >= 0 ) then
        Begin
           AlimentaProperties;
           sTipoCup := 'T';
           Result   := '0|';   
        End;
     End;
     If iRet < 0 then
        Begin
        Erro1(IntToStr(iRet),'I');
        fFuncCloseComFiscal(iHandle);
        Result:='1';
        End;
     End;
  if Copy(Result,1,1)<>'0' then
     Begin
     ShowMessage('Erro na abertura da porta');
     result := '1|';
     end;
end;
//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.Fechar( sPorta:String ) : String;
begin
  fFuncCloseComFiscal(iHandle);
  Result := '0|';
end;

//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.AbreCupom(Cliente:String; MensagemRodape:String):String;
Var
 sTipo: String;
 sCmd : String;
 sRet : String;
 iX   : Integer;
 aAuxiliar : TaString;
Begin
   GravaLog('TImpFiscalHasarPR4F - Inicio da função AbreCupom');

   //Protheus(Advpl) substitui "," vírgula por "&_",
   GravaLog('AbreCupom - Cliente [' + Cliente + ']');
   Cliente := StrTran(Cliente,'&_',',');
   GravaLog('AbreCupom - Cliente - Tratado [' + Cliente + ']');

   sTipo:='T';
   EnviaComando( PChar( #93 + '|1|' + #127) );
   EnviaComando( PChar( #93 + '|2|' + #127) );
   EnviaComando( PChar( #93 + '|3|' + #127) );
   EnviaComando( PChar( #93 + '|4|' + #127) );
   EnviaComando( PChar( #93 + '|5|' + #127) );
   EnviaComando( PChar( #93 + '|11|' + #127) );
   EnviaComando( PChar( #93 + '|12|' + #127) );
   EnviaComando( PChar( #93 + '|13|' + #127) );
   EnviaComando( PChar( #93 + '|14|' + #127) );

   // Monta um array auxiliar com as formas solicitadas
   MontaArray( Cliente,aAuxiliar );

   For iX := 0 to Length(aAuxiliar)-1 do
   begin
     GravaLog('AbreCupom - Indice [' + IntToStr(iX) + '] + aAuxiliar [ ' + aAuxiliar[iX] + ']');
   end;

   if ( Length(aAuxiliar)=7 ) then
   Begin
     sTipo := UpperCase(aAuxiliar[0]);
     aAuxiliar[2] := StrTran(aAuxiliar[2],'.','');
     sCmd  := PChar( '|'+aAuxiliar[1]+'|'+aAuxiliar[2]+'|'+aAuxiliar[3]+'|'+aAuxiliar[4]);
     if ( sTipo='B') or ( sTipo='A')
     then sRet := EnviaComando( 'b'+sCmd );

     sRet   := EnviaComando(']|9|' +Copy(aAuxiliar[5]+space(40),1,40));
     sRet   := EnviaComando(']|10|'+Copy(aAuxiliar[6]+space(40),1,40));
   End;
   sTipoCup := sTipo;
   sRet := EnviaComando('@|'+ sTipo+'|T','S' );
   if sRet='0' then
   Begin
      EnviaComando('*');
      If sTipo='A'
      then sCmd  := Status(5,sRet)
      Else sCmd  := Status(3,sRet);
       //Grava o tipo do Ultimo Cupom e o tipo do Cupom (T/A/B) no arquivo \ap5\bin\P+Numero PDV.HSR
       HasarCup( 'G',sTipo+sCmd);
   End;
   Result:=sRet;

   GravaLog('TImpFiscalHasarPR4F - Fim da função AbreCupom');
End;

//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.RegistraItem( codigo,descricao,qtde,vlrUnit,
                                        vlrdesconto,aliquota,vlTotIt,
                                        UnidMed:String; nTipoImp:Integer): String;
Var
  sCmd: String;
  sRet: String;

Begin
  if Pos('|',Aliquota)=0 then
     Aliquota:=Copy(Aliquota,2,5)+'|0.00';
  sCmd:='|'+Copy(Descricao,1,30);
  // Imprimindo o Nome do Produto
  sRet:=EnviaComando('A'+sCmd+'|0');

  // Registrando Item
  sCmd:='|'+Codigo+
        '|'+Trim(FormataTexto(qtde,9,3,3,'.'))+
        '|'+Trim(FormataTexto(VlrUnit,9,2,3,'.'))+
        '|'+Copy(Aliquota,1,5)+
        '|M'+
        '|'+Copy(Aliquota,7,4);
  sRet := EnviaComando('B'+sCmd+'|0|'+ Copy(aliquota,12,1),'S' );
  Result:=sRet;
End;
//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;
Var
  sCmd      : string;
  sRet      : String;
  aAuxiliar : TaString;
  i         : Integer;
  sPagOut   : String;
begin
  Pagamento := StrTran(Pagamento,',','.');
  // Monta um array auxiliar com as formas solicitadas
  MontaArray( Pagamento,aAuxiliar );
  // Faz o registro do pagamento
  i:=0;
  sPagOut:='0.00';
  While i<Length(aAuxiliar) do
    begin
    if i<=3 then
       Begin
       sCmd:='|'+aAuxiliar[i]+'|'+Trim(FormataTexto(aAuxiliar[i+1],9,2,3,'.'));
       sRet := EnviaComando('D'+ sCmd +'|T|0', 'S');
       End
    Else
       sPagOut:=  FloatToStr( StrToFloat(sPagOut)+ StrToFloat(aAuxiliar[i+1]) );

    Inc(i,2);
    end;
  If Trim(sPagOut)<>'0.00' then
       sRet := EnviaComando('D|Otros |'+Trim(FormataTexto(sPagOut,9,2,3,'.'))+'|T|0');

  result := sRet;
end;
//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.FechaCupom( Mensagem:String ):String;
Var
  sRet     : String;
  nX       : Integer;
  sTexto   : string;
  iLinha   : Integer;
Begin
  //Protheus(Advpl) substitui "," vírgula por "&_",
  Mensagem := StrTran(Mensagem,'&_',',');

  Mensagem:=Copy(Mensagem+Space(1000),1,1000);
  iLinha:=11;
  sTexto:='';
  If sTipoCup = 'T' then
  Begin
    For nX := 11 to 20 do
        sRet   := EnviaComando(']|'+IntToStr(nX)+'|'+#127);
  End
  Else
    For nX := 11 to 14 do
        sRet   := EnviaComando(']|'+IntToStr(nX)+'|'+#127);

  While Length(Mensagem) > 0 do
  Begin
    if ( ( sTipoCup ='T' ) and ( iLinha>20 ) ) or (( sTipoCup <>'T' ) and ( iLinha>14 ) )then
      break;
    // A mensagem é recortada a cada '_'(encontrado, ou, caso não haja '_' é             
    // recortada a cada 120 caracteres. São permitidas 4 linhas de mensagem no final do cupom.
     If Pos('_', Mensagem)>0 then 
     Begin
        If Pos('_', Mensagem) <> 1 then 
        begin
          sTexto:= Copy(Mensagem,1, Pos('_', Mensagem)-1); 
          sRet   := EnviaComando(']|'+IntToStr(iLinha)+'|'+sTexto);
          Inc(iLinha);
        End;
        Mensagem := Copy(Mensagem, Pos('_', Mensagem)+1, Length(Mensagem)); 
     End
     Else
     Begin
        sTexto:= Copy(Mensagem,1, 120);
        Mensagem := Copy(Mensagem, 121, Length(Mensagem));
        sRet   := EnviaComando(']|'+IntToStr(iLinha)+'|'+sTexto);
        Inc(iLinha);
     End;
  End;

  sRet   := EnviaComando('E|'+ IntToStr(0),'S');
  result := sRet;
End;
//---------------------------------------------------------------------------
function TimpFiscalHasarPR4F.PegaCupom(Cancelamento:String):String;
Var sBuff, sret, sLetraDoc, sDoc    : string;
    iRet    : LongInt;
    aBuff   : array [0..512] of char;
    i, ipos : integer;
Begin
  sRet   := EnviaComando('*');
  iRet   := fFuncUltimaRespuesta (iHandle , aBuff );
  sBuff  := aBuff;
  sLetraDoc:= '';
  sDoc   := Copy(Cancelamento,1,1);
  If sDoc <> 'R' then sLetraDoc := Copy(Cancelamento,3,1);

  i :=0 ;
  If (iRet >= 0) and (sLetraDoc<>'') then
  begin
    If (sLetraDoc = 'B') or (sLetraDoc = 'C') then
    Begin
      While (i < 2)do
      Begin
        ipos  := Pos(#28, sBuff);
        sBuff := Copy(sBuff, iPos+1, Length(sBuff));
        Inc(i);
      End;
      result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
     end
     Else
     Begin
        While (i < 4)do
        Begin
          ipos  := Pos(#28, sBuff);
          sBuff := Copy(sBuff, iPos+1, Length(sBuff));
          Inc(i);
        End;
        result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
     End;
  end
  else
     result := '1';

End;

//----------------------------------------- ----------------------------------
function TimpFiscalHasarPR4F.PegaPDV:String;
Var sBuff, sret    : string;
    iRet    : LongInt;
    aBuff   : array [0..512] of char;
    i, ipos : integer;
Begin
  sRet   := EnviaComando('s');
  iRet := fFuncUltimaRespuesta (iHandle , aBuff );
  sBuff := aBuff;

  i:=0;
  If iRet >= 0 then
  begin
      While ( i<6 ) do
      Begin
         ipos  := Pos(#28, sBuff);
         sBuff := Copy(sBuff, iPos+1, Length(sBuff));
         Inc(i);
      End;
         result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
  end
  else
  Begin
      result := '1';
  End;
End;

//----------------------------------------- ----------------------------------
function TimpFiscalHasarPR4F.ReImpCupomNaoFiscal( Texto:String ):String;
Var
  sRet: string;
Begin
  sRet   := EnviaComando(#153, 'S');
  Result := sRet;
End;

//----------------------------------------- ----------------------------------
function TimpFiscalHasarPR4F.DescontoTotal( vlrDesconto:String ;nTipoImp:Integer ): String;
Var
  sRet: String;
  sCmd: String;
Begin
  sCmd := Copy(vlrDesconto,1,Pos('|', vlrDesconto));
  vlrDesconto := Copy(vlrDesconto,Pos('|', vlrDesconto)+1, Length(vlrDesconto));
  sCmd := sCmd + Copy(vlrDesconto,1,Pos('|', vlrDesconto)) + 'm|';
  vlrDesconto := Copy(vlrDesconto,Pos('|', vlrDesconto)+1, Length(vlrDesconto));
  sCmd := sCmd + vlrDesconto;

  sRet   := EnviaComando('T'+sCmd+'|B','S');
  result := sRet;
End;

//----------------------------------------- ----------------------------------
function TImpFiscalHasarPR4F.AcrescimoTotal( vlrAcrescimo:String ): String;
Var
  sRet: String;
  sCmd: String;
Begin
  sCmd := Copy(vlrAcrescimo,1,Pos('|', vlrAcrescimo));
  vlrAcrescimo := Copy(vlrAcrescimo,Pos('|', vlrAcrescimo)+1, Length(vlrAcrescimo));
  sCmd := sCmd + Copy(vlrAcrescimo,1,Pos('|', vlrAcrescimo)) + 'M|';
  vlrAcrescimo := Copy(vlrAcrescimo,Pos('|', vlrAcrescimo)+1, Length(vlrAcrescimo));
  sCmd := sCmd + vlrAcrescimo;

  sRet   := EnviaComando('T'+sCmd+'|T','S');
  result := sRet;
End;

//----------------------------------------- ----------------------------------
function TImpFiscalHasarPR4F.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
Var
  sCmd: String;
  sRet: String;
Begin
   if Pos('|',Aliquota)=0 then
     Aliquota:=Copy(Aliquota,2,5)+'|0.00';

  sRet := EnviaComando('A|Item : '+Trim(NumItem)+' Anulado|0' );
  sCmd:='|'+Copy(Descricao,1,30);
  // Imprimindo o Nome do Produto
  sRet:=EnviaComando('A'+sCmd+'|0');
  // Cancelando Item
  sCmd:='|'+Trim(Codigo)+
        '|'+Trim(FormataTexto(qtde,9,3,3,'.'))+
        '|'+Trim(FormataTexto(VlrUnit,9,2,3,'.'))+
        '|'+Copy(Aliquota,1,5)+
        '|m'+
        '|'+Copy(Aliquota,7,4);
  sRet := EnviaComando('B'+sCmd+'|0|B','S' );
  Result:=sRet;
End;

//----------------------------------------- ----------------------------------
function TImpFiscalHasarPR4F.CancelaCupom( Supervisor:String ):String;
Var
  sRet: String;
Begin
// Recebe o parâmetro Supervisor no seguinte formato:
// cTexto+ '|' + cVlrPago

   sRet   := EnviaComando(#152);    

    if sRet <> '0' then
    begin
       sRet   := EnviaComando('D|' + Supervisor + '|C|0');
       sRet   := EnviaComando('J');
       sRet   := EnviaComando('E');
       sRet   := EnviaComando(#152);
    end;

  Result:=sRet;
End;

//----------------------------------------- ----------------------------------
function TImpFiscalHasarPR4F.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String;
var
  sDataIn,sDataFim: String;
  sRet    : String;
Begin
  if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
     Begin
     ReducInicio:= FormataTexto(ReducInicio,4,0,2);
     ReducFim   := FormataTexto(ReducFim,4,0,2);
     sRet       := EnviaComando(';|'+ReducInicio+'|'+ReducFim+'|T','S')
     End
  Else
     Begin
     sDataIn    :=FormataData(DataInicio,6);
     sDataFim   :=FormataData(DataFim,6);    
     sRet       := EnviaComando(':|'+sDataIn+'|'+sDataFim+'|T','S');
     End;

  result := sRet;
end;
//----------------------------------------- ----------------------------------
function TImpFiscalHasarPR4F.LeituraX : String;
var
  //iRet : Integer;
  sRet  : String;
begin
  sRet := EnviaComando('9'+#28+'X','S' );
  result := '0|';
end;
//------------------------------------------------------------
function TImpFiscalHasarPR4F.ReducaoZ( MapaRes:String ):String;
Var
  sRet: String;
  iRet : Integer;
  aBuffer: Array [0..512] of Char;
Begin
  sRet := EnviaComando('9'+#28+'Z','S' );
  If sRet = '0' then
  begin
    GravaLog(' fFuncUltimaRespuesta -> ');
    iRet := fFuncUltimaRespuesta (iHandle, aBuffer);
    GravaLog(' fFuncUltimaRespuesta <- iRet :' + IntToStr(iRet));
    Result := '0|'+aBuffer;
  end
  else
    Result:= '1';
End;

//------------------------------------------------------------
function TImpFiscalHasarPR4F.Gaveta : String;
Var
  sRet: String;
Begin
  sRet := EnviaComando('{');
  result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.AbreECF : String;
begin
  result := '0';
end;

// Função para enviar o comando mais de uma vez caso ocorra erro
function TImpFiscalHasarPR4F.EnviaComando(aParams:String;sError:String=''):String;

  Function PipeToFS(aParams:PChar):PChar;
  Var i : Integer;
  Begin
    For i := 1 To Length(aParams) Do
      If aParams[i] = '|' Then aParams[i] := #28;
    Result := aParams;
  End;

Const
  MODE_ANSI  = 1;
  MODE_ASCII = 0;
  nTamBuffer = 512;

Var
  iRet     : LongInt;
  sRet     : String;
  sParams  : String;
  sMsg     : String;
  sBuff    : Array [0..512] of Char;
Begin
  if LogDll then HasarLog( 'hasar.log', HasarGetCmd(aParams) );

  sParams := StrPas(PipeToFS(PChar(aParams)));
  iRet := fFuncMandaPaqueteFiscal(iHandle, sParams);
  if iRet<0 then
     Erro1(IntToStr(iRet),'I');

  if LogDll then
  begin
    sBuff := '';
    fFuncUltimaRespuesta (iHandle , sBuff );
    HasarLog( 'hasar.log', 'Rcvd: ' + sBuff, FALSE )
  end;

  if Trim(sMsg)<>'' then
     iRet:=1;

  If ( ( sError = 'S' ) AND ( Modelo <> 'HASAR SMH/P-435F' ) ) Then
  Begin
     sRet := Status(1,sRet);
     sRet := HexToBin(sRet);
     sRet:=Erro1(sRet,'P');
     if Trim(sRet)='' then
     Begin
        sRet := Status(2,sRet);
        sRet := HexToBin(sRet);
        sRet:=Erro1(sRet,'F');
        if Trim(sRet)='' then
           Result:='0'
        Else
           Result:='1';
     End
     Else
        Result:='1';
  End
  Else
  Begin
     sRet := IntToStr(iRet);
     Result := sRet;
  End;
End;

// Função para enviar comando genérico
function TImpFiscalHasarPR4F.EnvCmd(Comando: String; Posicao: Integer ): String;

  Function PipeToFS(aParams:PChar):PChar;
  Var i : Integer;
  Begin
    For i := 1 To Length(aParams) Do
    Begin
      If aParams[i] = '|' Then aParams[i] := #28;
    End;

    Result := aParams;
  End;
Var
  iRet          : integer;
  sComando, sRet: String;
  aBuff         : Array [0..512] of Char;
Begin

  if LogDll then HasarLog( 'hasar.log', HasarGetCmd(Comando) );

  If Pos('|',Comando)>0 then
      sComando := PipeToFs(PChar(Comando))
  Else
      sComando := Comando;

  aBuff:='';

  iRet := fFuncMandaPaqueteFiscal(iHandle, sComando);

  If iRet >= 0 then
  Begin
      iRet := fFuncUltimaRespuesta (iHandle , aBuff );
      if LogDll then HasarLog( 'hasar.log', 'Rcvd: ' + aBuff, FALSE );
      If iRet >= 0 then
      Begin
          Result := '0|'+ aBuff;
      End
      Else
      Begin
          sRet:= Copy(aBuff,1,4);
          sRet := HexToBin (sRet);
          Erro1(sRet,'S');

          sRet:= Copy(aBuff,6,4);
          sRet := HexToBin (sRet);
          Erro1(sRet,'F');

          Result := '1';
      End;
  End
  Else
  Begin
    Result := '1';
  End;

End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.Status( Tipo: Integer;Texto:String ):String;

  Function FSToPipe(aParams:PChar):PChar;
  Var i : Integer;
  Begin
    For i := 1 To Length(aParams) Do
      If aParams[i] = #28 Then aParams[i] := '|';
    Result := aParams;
  End;

Const
  nTamBuffer = 512;
Var
  sRet          : String;
  FiscalStatus  : Integer;
  PrinterStatus : Integer;
  sBuffer       : array[0..511] of char;
  aAuxiliar     : TaString;
Begin
  FiscalStatus := 0;
  PrinterStatus := 0;
  FillChar( sBuffer,nTamBuffer,0 );
  If fFuncUltimoStatus(iHandle, FiscalStatus, PrinterStatus) = 0 Then
     If fFuncUltimaRespuesta(iHandle, sBuffer) = 0 Then
        sRet := sRet + StrPas(FSToPipe(sBuffer));
  if ( Tipo>0 ) then
     Begin
     // Monta um array auxiliar com as formas solicitadas
     MontaArray( sRet,aAuxiliar );
     if ( Length(aAuxiliar)>=Tipo) then
        sRet:=aAuxiliar[Tipo-1]
     Else
        sRet:='';
     End;

  Result := sRet
end;
//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.LeAliquotas:String;
Begin
  Result:='0|'
End;
//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.LeAliquotasISS:String;
Begin
  Result:='0|'
End;
//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.LeCondPag:String;
Begin
  Result:='0|'
End;
//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
Begin
  Result:='0|'
End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
Var
  sRet: string;
Begin
   EnviaComando( PChar( #93 + '|1|' + #127) );
   EnviaComando( PChar( #93 + '|2|' + #127) );
   EnviaComando( PChar( #93 + '|3|' + #127) );
   EnviaComando( PChar( #93 + '|4|' + #127) );
   EnviaComando( PChar( #93 + '|5|' + #127) );
   EnviaComando( PChar( #93 + '|11|' + #127) );
   EnviaComando( PChar( #93 + '|12|' + #127) );
   EnviaComando( PChar( #93 + '|13|' + #127) );
   EnviaComando( PChar( #93 + '|14|' + #127) );
   sRet   := EnviaComando('H','S');
   result := sRet;
End;
//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
Var
  sRet: string;
  sCmd: string;
  nX  : Integer;
Begin
  nX:=0;
  While Length(Texto)>0 do
     Begin
     if ( Copy(Texto,1,1)=#$A ) or ( nX=40 ) Then
        Begin
        sCmd   := Trim(sCmd);
        sRet   := EnviaComando('I|'+sCmd+'|0');
        sCmd   := '';
        Texto  := Copy(Texto,2,length(Texto));
        nX     := 0;
        End
     Else
        Begin
        Inc(nX);
        sCmd   := sCmd+Copy(Texto,1,1);
        Texto  := Copy(Texto,2,length(Texto));
        End;
     End;

  sCmd   := Trim(sCmd);
  if sCmd<>'' then
     sRet   := EnviaComando('I|'+sCmd+'|0');
  result := sRet;
End;
//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.FechaCupomNaoFiscal: String;
Var
  sRet: string;
Begin
  sRet   := EnviaComando('J','S');
  result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.ReImprime: String;
Var
  sRet: string;
Begin
  sRet   := EnviaComando(#153, 'S'); 
  Result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.Percepcao(sAliqIVA, sTexto, sValor: String): String;
Var
  sRet: string;
Begin
  sRet   := EnviaComando( #96 + '|' + sAliqIVA + '|' + sTexto + '|' + sValor);
  Result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.AbreDNFH( sTipoDoc, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: String):String;
  Function FSToPipe(aParams:PChar):PChar;
  Var i : Integer;
  Begin
    For i := 1 To Length(aParams) Do
      If aParams[i] = #28 Then aParams[i] := '|';
    Result := aParams;
  End;
Var
  sCabec, sRet: string;
  iRet        : Integer;
  aBuff       : Array [0..512] of Char;
Begin

  If sTipoImp = 'S' Then
    bFatTic := True
  Else
    bFatTic := False;

  sDadosCli := StrTran(sDadosCli,'.','');
  sRet := EnviaComando('b' + sDadosCli);
  If sRet = '0' then
  Begin
    sDadosCab := Copy(sDadosCab, 2, Length(sDadosCab));
    sCabec    := '|' + Copy(sDadosCab,1,Pos('|',sDadosCab));
    sDadosCab := Copy(sDadosCab,Pos('|', sDadosCab)+1,Length(sDadosCab));
    sCabec    := sCabec + Copy(sDadosCab,1,Pos('|',sDadosCab)-1);
    sDadosCab := Copy(sDadosCab,Pos('|', sDadosCab),Length(sDadosCab));
    If (sTipoDoc <> 'x') then
    Begin
        sRet      := EnviaComando( #93 + sCabec);
        If sRet = '0' then
        Begin
            sRet  := EnviaComando( #93 + sDadosCab);
              If sRet = '0' then
              Begin
                sRet := EnviaComando( #147 + sDocOri);
                If sRet = '0' then
                Begin
                     If (sTipoDoc = 'R') or (sTipoDoc = 'S') then
                          sRet := EnviaComando( #128 +'|'+sTipoDoc + '|'+sTipoImp+'|');
                End
                Else
                    Result := '1';
              End
              Else
                Result := '1';
        End
        Else
            Result := '1';
    End
    Else
    Begin
        sRet := EnviaComando( #128 + '|' +sTipoDoc +'|'+sTipoImp+'|'+ sDocOri);
    End;
  End
  Else
  Begin
    sRet := '1';
  End;

  If sRet = '0' then
  Begin
      iRet   := fFuncUltimaRespuesta (iHandle , aBuff );
      If iRet >= 0 then
          Result := '0|'+aBuff
      Else
          Result := '1';
  End;

End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.FechaDNFH: String;
Var
  sRet: string;
Begin
  sRet   := EnviaComando(#129);
  Result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.TextoRecibo (sTexto: String): String;
Var
  sRet, Mensagem : string;
Begin

  While Length(sTexto) > 0 do
  Begin
    If bFatTic then
    Begin
      If Length(sTexto) > 106 Then
      Begin
         Mensagem := Copy(sTexto, 1, 106);
         sRet := EnviaComando(#151 + '|' + Mensagem);
         sTexto := Copy(sTexto, 107, Length(sTexto));
      End
      Else
      Begin
        sRet := EnviaComando(#151 + '|' + sTexto);
        sTexto := '';
      End;
    End
    Else
    Begin
      If Length(sTexto) > 40 Then
      Begin
         Mensagem := Copy(sTexto, 1, 40);
         sRet := EnviaComando(#151 + '|' + Mensagem);
         sTexto := Copy(sTexto, 41, Length(sTexto));
      End
      Else
      Begin
        sRet := EnviaComando(#151 + '|' + sTexto);
        sTexto := '';
      End;
    End;
  End;

  Result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.StatusImp( Tipo:Integer ):String;
var
  SRet : String;
  iRet : Integer;
  aBuff   : array [0..512] of char;
begin
// Tipo - Indica qual o status quer se obter da impressora
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
// 17 - Consulta de Estado - Específico Hasar

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

//³ Verificacion de Status de la Impresora                      ³
// a Função HexToBin - Retorna o do bit menos significativo para o mais significativo
// Bit  0 - Siempre Cero
// Bit  1 - Siempre Cero
// Bit  2 - 1 = Error de Impresora
// Bit  3 - 1 = Impresora Off-line
// Bit  4 - 1 = Falta Papel del Diario
// Bit  5 - 1 = Falta Papel de Tickets
// Bit  6 - 1 = Buffer de Impresora Lleno
// Bit  7 - 1 = Buffer de Impresora Vacio
// Bit  8 - 1 = Tapa de Impresora Abierta
// Bit  9 - Siempre Cero
// Bit 10 - Siempre Cero
// Bit 11 - Siempre Cero
// Bit 12 - Siempre Cero
// Bit 13 - Siempre Cero
// Bit 14 - 1 = Cajon de dinero cerrado o ausente
// Bit 15 - 1 = OR logico de los bits 2-5, 8 y 14

// Faz a leitura da Hora
if Tipo = 1 then
   begin
   EnviaComando('Y');
   sRet := Status(4,sRet);
   Result:='0|'+Copy(sRet,1,2)+':'+Copy(sRet,3,2)+':'+Copy(sRet,5,2);
   end
// Faz a leitura da Data
else if Tipo = 2 then
   begin
   EnviaComando('Y');
   sRet := Status(3,sRet);
   Result:='0|'+Copy(sRet,5,2)+'/'+Copy(sRet,3,2)+'/'+Copy(sRet,1,2);
   end
   // Faz a checagem de papel
else if Tipo = 3 then
   begin
   EnviaComando('Y');
   sRet := Status(1,sRet);
   sRet := HexToBin(sRet);
   if ( Copy(sRet,4,1)='0' ) and ( Copy(sRet,5,1)='0' ) then
      Result:='0|'
   Else
     Result:='7';
   End
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  Result:= '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
   Begin
   Result:='1|';
   EnviaComando('*');
   sRet := Status(4,sRet);
        If Copy(sRet,4,1)='2' then
           Result := '0'
        else
           Result := '7';
   End
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
  result := '1'
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
  result := '1'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  result := '1'
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
  Result := '0'
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
   Result := '1'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
    Result := '1'
else if Tipo = 17 then
  Begin
    sRet   := EnviaComando('*');
    iRet := fFuncUltimaRespuesta (iHandle , aBuff );
    If iRet >= 0 then
         result := '0|'+aBuff
    else
        result := '1';
  End
// 20 ao 40 - Retorno criado para o PAF-ECF
else if (Tipo >= 20) AND (Tipo <= 40) then
  Result := '0'
else If Tipo = 45 then
  Result := '0|'// 45 Codigo Modelo Fiscal
else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
  Result := '0|'// 45 Codigo Modelo Fiscal
Else
   Result:='1';
end;

//------------------------------------------------------------
function TImpFiscalHasarPR4F.FechaEcf : String;
Begin
  Result := ReducaoZ('N');
End;

//-----------------------------------------------------------
function TImpFiscalHasarPR4F.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
begin
  Result:='0';
end;

//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.GravaCondPag( condicao:string ) : String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalHasarPR4F.Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
begin
   Result := '0';
end;

//----------------------------------------- ----------------------------------
function TimpFiscalHasarPR4F.MemTrab:String;
Var sret    : string;
    iRet    : LongInt;
    aBuff   : array [0..512] of char;
Begin
  sRet := EnviaComando('g');
  iRet := fFuncUltimaRespuesta (iHandle , aBuff );
  If iRet >= 0
  then Result := '0|'+aBuff
  else Result := '1';
End;

//----------------------------------------- ----------------------------------
function TimpFiscalHasarPR4F.Capacidade:String;
Var sret    : string;
    iRet    : LongInt;
    aBuff   : array [0..512] of char;
Begin
  sRet   := EnviaComando('7');
  iRet := fFuncUltimaRespuesta (iHandle , aBuff );
  If iRet >= 0 then
       result := '0|'+aBuff
  else
      result := '1';
End;

//---------------------------------------------------------------------------
function TimpFiscalHasarPR4F.AbreNota(Cliente:String):String;
Var
 sTipo: String;
 sCmd : String;
 sRet : String;
 aBuff: array [0..512] of char;
 aAuxiliar : TaString;
Begin
     sRet:='1';
     sTipo:='B';
     // Monta um array auxiliar com as formas solicitadas
     MontaArray( Cliente,aAuxiliar );
     sTipo  := aAuxiliar[0];
     aAuxiliar[1] := Copy( aAuxiliar[1], 1, 45);
     aAuxiliar[2] := StrTran(aAuxiliar[2],'.','');
     sCmd   := PChar( '|'+aAuxiliar[1]+'|'+aAuxiliar[2]+'|'+aAuxiliar[3]+'|'+aAuxiliar[4]+'|'+aAuxiliar[5]);
     sRet   := EnviaComando( 'b'+sCmd,'S' );
     If sRet='0' then
        Begin
        //sRet   := EnviaComando(']|3|'+Copy(aAuxiliar[6]+space(40),1,40)); //Mensagem
        //sRet   := EnviaComando(']|4|'+Copy(aAuxiliar[7]+space(40),1,40)); //Mensagem
        //sRet   := EnviaComando(']|5|'+Copy(aAuxiliar[8]+space(40),1,40)); // Mensagem
        sRet   := EnviaComando('@|'+ sTipo+'|'+aAuxiliar[6]+'|'+aAuxiliar[6],'S' );
        fFuncUltimaRespuesta (iHandle , aBuff );

        if sRet='0' then
           Begin
           EnviaComando('*');
           If sTipo='A' then
              sCmd  := Status(5,sRet)
           Else
              sCmd  := Status(3,sRet);
              //Grava o tipo do Ultimo Cupom e o tipo do Cupom (T/A/B) no arquivo \ap5\bin\P+Numero PDV.HSR
              HasarCup( 'G',sTipo+sCmd);
           End;
        End;
   Result:=sRet+'|'+aBuff;
End;

//------------------------------------------------------------------------------
function TimpFiscalHasarPR4F.RecebNFis( Totalizador, Valor, Forma:String ): String;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//----------------------------------------------------------------------------
function TimpFiscalHasarPR4F.RelatorioGerencial( Texto:String;Vias:Integer ; ImgQrCode: String): String;
begin
  result := '0';
End;

//----------------------------------------------------------------------------
function TimpFiscalHasarPR4F.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TimpFiscalHasarPR4F.HorarioVerao( Tipo:String ):String;
begin
  result := '0';
End;

//------------------------------------------------------------------------------
function TimpFiscalHasarPR4F.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TimpFiscalHasarPR4F.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TimpFiscalHasarPR4F.TotalizadorNaoFiscal( Numero,Descricao:String ) : String;
begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
end;

//------------------------------------------------------------------------------
function TimpFiscalHasarPR4F.LeTotNFisc:String;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
function TimpFiscalHasarPR4F.DownMF(sTipo, sInicio, sFinal : String):String;
Begin
  MessageDlg( MsgIndsImp, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TimpFiscalHasarPR4F.RedZDado( MapaRes : String ):String;
Begin
  Result := '0';
End;

//------------------------------------------------------------------------------
function TimpFiscalHasarPR4F.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalHasarPR4F.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//****************************** P320F ***************************************
function TImpFiscalHasar320F.AbreCupom(Cliente:String; MensagemRodape:String):String;
Var
 sTipo: String;
 sCmd : String;
 sRet,cEndCli : String;
 iX   : Integer;
 aAuxiliar : TaString;
Begin
   GravaLog('TImpFiscalHasar320F - Inicio da função AbreCupom');

   //Protheus(Advpl) substitui "," vírgula por "&_",
   GravaLog('AbreCupom - Cliente [' + Cliente + ']');
   Cliente := StrTran(Cliente,'&_',',');
   GravaLog('AbreCupom - Cliente - Tratado [' + Cliente + ']');

   sRet:='1';

   //sCmd :='A|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|20183697308|I|C|MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM|||';
   sTipo:='B';

   // Monta um array auxiliar com as formas solicitadas
   MontaArray( Cliente,aAuxiliar );

   For iX := 0 to Length(aAuxiliar)-1 do
   begin
     GravaLog('AbreCupom - Indice [' + IntToStr(iX) + '] + aAuxiliar [ ' + aAuxiliar[iX] + ']');
   end;

   GravaLog(' EnvioComando - Indice 1 ->');
   If Trim(aAuxiliar[11]) = ''
   then EnviaComando( PChar( #93 + '|1|' + #127) )
   else EnviaComando( PChar( #93 + '|1|' + aAuxiliar[11] ));
   GravaLog(' EnvioComando - Indice 1 <-');

   If Length(aAuxiliar) > 12 then
   begin
     GravaLog(' EnvioComando - Indice 2 ->');
     If Trim(aAuxiliar[12]) = ''
     then EnviaComando( PChar( #93 + '|2|' + #127) )
     else EnviaComando( PChar( #93 + '|2|' + aAuxiliar[12] ));
     GravaLog(' EnvioComando - Indice 2 <-');

     GravaLog(' EnvioComando - Indice 3 ->');
     If Trim(aAuxiliar[13]) = ''
     then EnviaComando( PChar( #93 + '|3|' + #127) )
     else EnviaComando( PChar( #93 + '|3|' + aAuxiliar[13] ));
     GravaLog(' EnvioComando - Indice 3 <-');
   end
   Else
   begin
     GravaLog(' EnvioComando - Indice 2 ->');
     EnviaComando( PChar( #93 + '|2|' + #127) );
     GravaLog(' EnvioComando - Indice 2 <-');

     GravaLog(' EnvioComando - Indice 3 ->');
     EnviaComando( PChar( #93 + '|3|' + #127) );
     GravaLog(' EnvioComando - Indice 3 <-');
   end;

   GravaLog(' EnvioComando - Indice 4 ->');
   EnviaComando( PChar( #93 + '|4|' + #127) );
   GravaLog(' EnvioComando - Indice 4 <-');

   GravaLog(' EnvioComando - Indice 5 ->');
   EnviaComando( PChar( #93 + '|5|' + #127) );
   GravaLog(' EnvioComando - Indice 5 <-');

   GravaLog(' EnvioComando - Indice 11 ->');
   If Trim(aAuxiliar[5]) = ''
   then EnviaComando( PChar( #93 + '|11|' + #127) )
   else EnviaComando( PChar( #93 + '|11|' + aAuxiliar[5] )); // Vendedor na 1ª linha do rodapé
   GravaLog(' EnvioComando - Indice 11 <-');

   GravaLog(' EnvioComando - Indice 12 ->');
   EnviaComando( PChar( #93 + '|12|' + #127) );
   GravaLog(' EnvioComando - Indice 12 <-');

   GravaLog(' EnvioComando - Indice 13 ->');
   EnviaComando( PChar( #93 + '|13|' + #127) );
   GravaLog(' EnvioComando - Indice 13 <-');

   GravaLog(' EnvioComando - Indice 14 ->');
   EnviaComando( PChar( #93 + '|14|' + #127) );
   GravaLog(' EnvioComando - Indice 14 <-');

   cEndCli := Copy(Copy(Trim(aAuxiliar[8]), 1, 29)+' - '+Copy(Trim(aAuxiliar[9]), 1, 8)+' - '+Copy(Trim(aAuxiliar[10]), 1, 2), 1, 45);

   sTipo  := UpperCase(aAuxiliar[0]);
   aAuxiliar[2] := StrTran(aAuxiliar[2],'.','');

   sCmd   := PChar( '|'+aAuxiliar[1]+'|'+aAuxiliar[2]+'|'+aAuxiliar[3]+'|'+aAuxiliar[4]+'|'+cEndCli);
   GravaLog(' EnvioComando - b|sCmd|, S -> [' + sCmd + ']' );
   sRet   := EnviaComando( 'b'+sCmd,'S' );
   GravaLog(' EnvioComando - b|sCmd|, S <- sRet : [' + sRet + ']' );

   If sRet='0' then
   Begin
      //sRet   := EnviaComando(']|3|'+Copy(aAuxiliar[6]+space(40),1,40)); //Mensagem
      //sRet   := EnviaComando(']|4|'+Copy(aAuxiliar[7]+space(40),1,40)); //Mensagem
      //sRet   := EnviaComando(']|5|'+Copy(aAuxiliar[8]+space(40),1,40)); // Mensagem
      GravaLog(' EnvioComando - b|sCmd|, S -> [' + sCmd + ']' );
      sRet   := EnviaComando('@|'+sTipo+'|T','S' );
      GravaLog(' EnvioComando - b|sCmd|, S <- sRet : [' + sRet + ']' );

      if sRet = '0' then
      Begin
         GravaLog(' EnvioComando - * -> ');
         EnviaComando('*');
         GravaLog(' EnvioComando - * <- ');

         If sTipo='A'
         then sCmd  := Status(5,sRet)
         Else sCmd  := Status(3,sRet);

         //Grava o tipo do Ultimo Cupom e o tipo do Cupom (T/A/B) no arquivo \ap5\bin\P+Numero PDV.HSR
         HasarCup( 'G',sTipo+sCmd);
      End;
   End;
   Result := sRet;

   GravaLog('TImpFiscalHasar320F - Fim da função AbreCupom');
End;

//---------------------------------------------------------------------------
function TImpFiscalHasar320F.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String;
Var
  sCmd: String;
  sRet: String;
  sTipoImp : String;
  sValAliquota: String;
  nPos: Integer;
Begin
  if Pos('|',Aliquota)=0 then
     Aliquota:=Copy(Aliquota,1,5)+'|0.00';

  if Pos('%',Aliquota)<>0 then
     Aliquota:= Copy(Aliquota,2,30);

  nPos := Pos('|', Aliquota);
  If nPos > 0 Then
  Begin
     sValAliquota := Copy(Aliquota, nPos + 1, Length(Aliquota));
     sValAliquota := Copy(sValAliquota, 1, Pos('|', sValAliquota)-1 );
  End
  Else
  Begin
     sValAliquota := Copy(Aliquota,Pos('|',aliquota)+1,4)
  End;

  sValAliquota := Trim(sValAliquota);

  case nTipoImp of
       1  : sTipoImp := 'T';
       2  : sTipoImp := 'B';
  Else
       sTipoImp := 'B';
  end;

  // Registrando Item
  sCmd :='|' + (Copy(Codigo+' '+Descricao+space(50),1,50))+
         '|' + FormataTexto(qtde,14,10,1,'.')+
         '|' + FormataTexto(VlrUnit,11,4,1,'.')+
         '|' + FormataTexto(Copy(Aliquota,1,Pos('|',aliquota)-1),5,2,1)+
         '|M'+
         '|$'+ FormataTexto(sValAliquota,14,7,1);

  sRet := EnviaComando('B'+sCmd+'|0|s','S' );

  If (StrToFloat(vlrdesconto) > 0) and (sRet = '0') then
  begin
    sCmd := '|'+Space(50)+'|'+FormataTexto(vlrDesconto,12,2,1)+ '|m|0';
    //sRet := EnviaComando('U'+sCmd+'|B','S');
    sRet := EnviaComando('U'+sCmd+'|'+sTipoImp,'S');
  end;
  Result:= sRet;
End;

//------------------------------------------------------------
function TImpFiscalHasar320F.Gaveta : String;
Begin
  result := '0|';
End;

//----------------------------------------------------------------------------
Function TImpFiscalHasar320F.PegaSerie:String;
Var sBuff, sret    : string;
    iRet    : LongInt;
    aBuff   : array [0..512] of char;
    i, ipos : integer;
Begin
  sRet   := EnviaComando('s');
  iRet := fFuncUltimaRespuesta (iHandle , aBuff );
  sBuff := aBuff;

  i:=0;
  If iRet >= 0 then
  begin
      While (i < 4)do
      Begin
         ipos  := Pos(#28, sBuff);
         sBuff := Copy(sBuff, iPos+1, Length(sBuff));
         Inc(i);
      End;
      result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
  end
  else
      result := '1';
End;

//----------------------------------------------------------------------------
procedure TImpFiscalHasar320F.AlimentaProperties;
Var
  sRet: String;
Begin
    sRet := PegaPdv;
    If Copy(sRet,1,1) = '0' then
    Begin
        PDV := Copy(sRet,3,Length(sRet));
        sPDV := PDV;
    End;
End;

//----------------------------------------- ----------------------------------
function TImpFiscalHasar320F.DescontoTotal( vlrDesconto:String ; nTipoImp:Integer ): String;
Var
  sRet: String;
  sCmd: String;
  sTipoImp: String;
Begin
  vlrDesconto:=  copy(vlrDesconto,Pos('|',vlrDesconto)+1,length(vlrDesconto));
  sCmd :=        '|'+Space(50)+'|'+copy(vlrDesconto,1,12)+ '|m|';
  vlrDesconto := Copy(vlrDesconto, Pos('|',vlrDesconto)+1, Length(vlrDesconto));
  sCmd :=        sCmd + Copy(vlrDesconto,1,1);

  case nTipoImp of
       1  : sTipoImp := 'T';
       2  : sTipoImp := 's';
  Else
       sTipoImp := 's';
  end;
  
  sRet := EnviaComando('T'+sCmd+'|'+sTipoImp,'S');
  result := sRet;
End;

//----------------------------------------- ----------------------------------
function TImpFiscalHasar320F.AcrescimoTotal( vlrAcrescimo:String ): String;
Var
  sRet:   String;
  sCmd:   String;
Begin
  vlrAcrescimo:= Copy(vlrAcrescimo,Pos('|',vlrAcrescimo)+1,length(vlrAcrescimo));
  sCmd :=        '|'+Space(50)+'|'+copy(vlrAcrescimo,1,12)+ '|M|';
  vlrAcrescimo:= Copy(vlrAcrescimo, Pos('|',vlrAcrescimo)+1, Length(vlrAcrescimo));
  sCmd :=        sCmd + Copy(vlrAcrescimo,1,1);

  sRet   := EnviaComando('T'+sCmd+'|B','S');

  result := sRet;
End;

//---------------------------------------------------------------------------
function TimpFiscalHasar320F.PegaCupom(Cancelamento:String):String;
Var sBuff, sret, sDoc, sLetraDoc    : string;
    iRet    : LongInt;
    aBuff   : array [0..512] of char;
    i, ipos : integer;
Begin
  sRet   := EnviaComando('*');
  iRet   := fFuncUltimaRespuesta (iHandle , aBuff );
  sBuff  := aBuff;
  // Cancelamento tem o seguinte formato: X|X
  // A primeira posição indica se o número procurado é Documento, Nota de Credito ou Remito
  // A segunda posição indica se é do tipo A,B ou C
  result := '0';
  sDoc   := Copy(Cancelamento,1,1);
  If sDoc <> 'R' then sLetraDoc := Copy(Cancelamento,3,1);

  i :=0 ;
  If iRet >= 0 then
  begin
      // D - Documento
      If (sDoc = 'D') then
      begin
          If (sLetraDoc = 'B') or (sLetraDoc = 'C') then
          Begin
            While (i < 2)do
            Begin
               ipos  := Pos(#28, sBuff);
               sBuff := Copy(sBuff, iPos+1, Length(sBuff));
               Inc(i);
            End;
            result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
          end
          Else
          Begin
              While (i < 4)do
              Begin
                 ipos  := Pos(#28, sBuff);
                 sBuff := Copy(sBuff, iPos+1, Length(sBuff));
                 Inc(i);
              End;
              result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
          End;
      end;
      // N - Nota de Credito
      If (sDoc = 'N') then
      begin
          If (sLetraDoc = 'B') or (sLetraDoc = 'C') then
          Begin
            While (i < 6)do
            Begin
               ipos  := Pos(#28, sBuff);
               sBuff := Copy(sBuff, iPos+1, Length(sBuff));
               Inc(i);
            End;
            result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
          end
          Else
          Begin
              While (i < 7)do
              Begin
                 ipos  := Pos(#28, sBuff);
                 sBuff := Copy(sBuff, iPos+1, Length(sBuff));
                 Inc(i);
              End;
              result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
          End;
      end;
      // R - Remito
      If (sDoc = 'R') then
      begin
        While (i < 8)do
        Begin
            ipos  := Pos(#28, sBuff);
            sBuff := Copy(sBuff, iPos+1, Length(sBuff));
            Inc(i);
        End;
        result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
      end;
  end
  else
     result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalHasar320F.SubTotal (sImprime: String):String;
var
  sBuff, sRet : String;
  aBuff   : array [0..512] of char;
  iRet : Integer;
begin
  iRet := 0;
  sRet   := EnviaComando('C'+#28+ '' +Trim(sImprime));

  If sRet = '0' then
      iRet := fFuncUltimaRespuesta (iHandle , aBuff );

  If iRet >= 0 then
  begin
      sBuff := aBuff ;
      sBuff := sBuff + #28;
      sRet:='';
      While (length(sBuff)>0) do
      Begin
        sRet:= sRet + Copy(sBuff, 1, Pos(#28,sBuff)-1)+ #28;
        sBuff := Copy(sBuff, Pos(#28,sBuff)+1, Length(sBuff));
      End;
      result := '0|'+ sRet;
  end
  else
  Begin
      result := '1';
  End;
end;

//****************************** P330F ***************************************
function TImpFiscalHasar330F.StatusImp( Tipo:Integer ):String;
var
  SRet : String;
  iRet : Integer;
  aBuff   : array [0..512] of char;
begin
// Tipo - Indica qual o status quer se obter da impressora
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
// 17 - Consulta de Estado - Específico Hasar

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



//³ Verificacion de Status de la Impresora                      ³
// a Função HexToBin - Retorna o do bit menos significativo para o mais significativo
// Bit  0 - Siempre Cero
// Bit  1 - Siempre Cero
// Bit  2 - 1 = Error de Impresora
// Bit  3 - 1 = Impresora Off-line
// Bit  4 - 1 = Falta Papel del Diario
// Bit  5 - 1 = Falta Papel de Tickets
// Bit  6 - 1 = Buffer de Impresora Lleno
// Bit  7 - 1 = Buffer de Impresora Vacio
// Bit  8 - 1 = Tapa de Impresora Abierta
// Bit  9 - Siempre Cero
// Bit 10 - Siempre Cero
// Bit 11 - Siempre Cero
// Bit 12 - Siempre Cero
// Bit 13 - Siempre Cero
// Bit 14 - 1 = Cajon de dinero cerrado o ausente
// Bit 15 - 1 = OR logico de los bits 2-5, 8 y 14

// Faz a leitura da Hora
if Tipo = 1 then
   begin
   EnviaComando('Y');
   sRet := Status(4,sRet);
   Result:='0|'+Copy(sRet,1,2)+':'+Copy(sRet,3,2)+':'+Copy(sRet,5,2);
   end
// Faz a leitura da Data
else if Tipo = 2 then
   begin
   EnviaComando('Y');
   sRet := Status(3,sRet);
   Result:='0|'+Copy(sRet,5,2)+'/'+Copy(sRet,3,2)+'/'+Copy(sRet,1,2);
   end
   // Faz a checagem de papel
else if Tipo = 3 then
   begin
   EnviaComando('Y');
   sRet := Status(1,sRet);
   sRet := HexToBin(sRet);
   if ( Copy(sRet,4,1)='0' ) and ( Copy(sRet,5,1)='0' ) then
      Result:='0|'
   Else
     Result:='7';
   End
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  Result:= '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
   Begin
   Result:='1|';
   EnviaComando('*');
   sRet := Status(4,sRet);
        If Copy(sRet,4,1)='2' then
           Result := '0'
        else
           Result := '7';
   End
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
  result := '1'
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
  result := '1'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  result := '1'
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
  Result := '0'
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
   Result := '1'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
    Result := '1'
else if Tipo = 17 then
  Begin
    sRet   := EnviaComando('*');
    iRet := fFuncUltimaRespuesta (iHandle , aBuff );
    If iRet >= 0 then
         result := '0|'+aBuff
    else
        result := '1';
  End
// 20 ao 40 - Retorno criado para o PAF-ECF
else if (Tipo >= 20) AND (Tipo <= 40) then
  Result := '0'
else If Tipo = 45 then
       Result := '0|'// 45 Codigo Modelo Fiscal
else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
      Result := '0|'// 45 Codigo Modelo Fiscal
Else
   Result:='1';
end;

//----------------------------------------------------------------------------
Function TImpFiscalHasarPR4F.HasarCup( sTipo,sNumero:String):String;
var
  fArq : TextFile;
  sArq:String;
  sCmd: String;
begin
  sCmd:='*00000000';
  sArq:='P'+sPdv+'.HSR';
  if sTipo='L' then
     Begin
     if FileExists(sArq) Then
        Begin
        AssignFile( fArq,sArq );
        Reset( fArq );
        ReadLn( fArq,sCmd );
        CloseFile( fArq );
        Application.ProcessMessages;
        end;
     End
  Else
     Begin
     sCmd:=sNumero;
     AssignFile( fArq,sArq );
     ReWrite( fArq );
     WriteLn( fArq,sCmd );
     CloseFile( fArq );
     Application.ProcessMessages;
     End;

  Result:=sCmd;
end;

//----------------------------------------------------------------------------
procedure TImpFiscalHasarPR4F.AlimentaProperties;
Var
  sRet: String;
Begin
    sRet := PegaPdv;
    If Copy(sRet,1,1) = '0' then
    Begin
        PDV := Copy(sRet,3,Length(sRet));
        sPDV := PDV;
    End;
End;

//----------------------------------------------------------------------------
Function TImpFiscalHasarPR4F.PegaSerie:String;
Var sBuff, sret    : string;
    iRet    : LongInt;
    aBuff   : array [0..512] of char;
    i, ipos : integer;
Begin
  sRet   := EnviaComando('s');
  iRet := fFuncUltimaRespuesta (iHandle , aBuff );
  sBuff := aBuff;

  i:=0;
  If iRet >= 0 then
  begin
      While (i < 4)do
      Begin
         ipos  := Pos(#28, sBuff);
         sBuff := Copy(sBuff, iPos+1, Length(sBuff));
         Inc(i);
      End;
      result := '0|'+Copy(sBuff, 1, Pos(#28,sBuff)-1);
  end
  else
      result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalHasarPR4F.SubTotal (sImprime: String):String;
var
  sBuff, sRet : String;
  aBuff: array [0..512] of char;
  iRet : Integer;
begin
  sRet   := EnviaComando('C|N| |0');
  iRet := 0;
  If sRet = '0' then
      iRet := fFuncUltimaRespuesta (iHandle , aBuff );

  If iRet >= 0 then
  begin
      sBuff := aBuff ;
      sBuff := sBuff + #28;
      sRet:='';
      While (length(sBuff)>0) do
      Begin
        sRet:= sRet + Copy(sBuff, 1, Pos(#28,sBuff)-1)+ #28;
        sBuff := Copy(sBuff, Pos(#28,sBuff)+1, Length(sBuff));
      End;
      result := '0|'+ sRet;
  end
  else
  Begin
      result := '1';
  End;
end;

//------------------------------------------------------------------------------
function TImpFiscalHasarPL23.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String;
Var
  sCmd,sRet,sTipoImp: String;
Begin
  if Pos('|',Aliquota)=0 then
     Aliquota:=Copy(Aliquota,1,5)+'|0.00';
  // Registrando Item
  sCmd :='|' + (Copy(Codigo+' '+Descricao+space(50),1,50))+
         '|' + FormataTexto(qtde,14,10,1,'.')+
         '|' + FormataTexto(VlrUnit,11,4,1,'.')+
         '|' + FormataTexto(Copy(Aliquota,1,Pos('|',aliquota)-1),5,2,1)+
         '|M'+
         '|%'+ FormataTexto(Copy(Aliquota,Pos('|',aliquota)+1,4),14,7,1);

  case nTipoImp of
    1: sTipoImp := 'T';
    2: sTipoImp := 's';
  else
    sTipoImp := 's';
  end;

  sRet := EnviaComando('B'+sCmd+'|0|'+sTipoImp,'S' );

  If (StrToFloat(vlrdesconto) > 0) and (sRet = '0') then
  begin
    sCmd := '|'+Space(50)+'|'+FormataTexto(vlrDesconto,12,2,1)+ '|m|0';
    sRet := EnviaComando('U'+sCmd+'|'+sTipoImp,'S');
  end;
  Result:= sRet;
End;

//---------------------------------------------------------------------------
function TImpFiscalHasarPL23.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;
Var
  sCmd        : string;
  sRet        : String;
  aAuxiliar   : TaString;
  aPercepcion : TaString;
  aSubTotal   : TaString;
  i           : Integer;
  sMensagem   : String;
  sSubTotal   : String;
  iPercepcion : double;
begin
  i:=0;
  iPercepcion:=0;
  sRet := '0';
  sMensagem := 'Lo número máximo de modos de pago excedieron.';
  Pagamento := StrTran(Pagamento,',','.');

  // Monta um array auxiliar com as formas solicitadas
  MontaArray( Pagamento,aAuxiliar );

  // Monta um array com as percepciones a serem enviadas
  MontaArray( Percepcion,aPercepcion );

  While i<Length(aPercepcion) do
  Begin
    iPercepcion := iPercepcion+StrToFloat(aPercepcion[i+2]);
    Inc(i,3);
  End;

  i:=0;

  //permite ate 4 formas de pagamento
  if Length(aAuxiliar) > 8 then
     begin
     sRet := '1|' + sMensagem;
     ShowMessage(sMensagem);
     end;

   if Copy(sRet, 1, 1) <> '1' then
      begin
      sSubTotal := SubTotal('|P|0|0');
      If Copy( sSubTotal, 1, 1) = '0' then
         begin
         sSubTotal := SubstituiStr( sSubTotal, #28, '|' );
         MontaArray( sSubTotal, aSubTotal );
         aSubTotal[4] := FormataTexto( aSubTotal[4], 11, 2, 5);
         If Abs(StrToFloat(Vinculado) - ( StrToFloat(aSubTotal[4]) + iPercepcion )) >= 0.005 then
         Begin
          If ( StrToFloat( aSubTotal[4] ) + iPercepcion ) > StrToFloat( Vinculado ) then
            begin
              aSubTotal[4] := FloatToStr( ( StrToFloat( aSubTotal[4] ) + iPercepcion ) - StrToFloat( Vinculado ) );
              aSubTotal[4] := FormataTexto( aSubTotal[4], 12, 2, 1 );
              sRet   := EnviaComando('T|Ajuste por Redondeo|' + aSubTotal[4] + '|m|0|T','S'); //Desconto
            end
          Else If ( StrToFloat( aSubTotal[4] ) + iPercepcion ) < StrToFloat( Vinculado ) then
            begin
                aSubTotal[4] := FloatToStr( StrToFloat(Vinculado) - ( StrToFloat(aSubTotal[4]) + iPercepcion ) );
                aSubTotal[4] := FormataTexto( aSubTotal[4], 12, 2, 1);
                sRet   := EnviaComando('T|Ajuste por Redondeo|' + aSubTotal[4] + '|M|0|T','S'); //Acrecimo
            end;
          end;
         End;
      end;

  // Faz o registro das percepciones se houver
  if Length(aPercepcion)>0 then
  begin
    While i<Length(aPercepcion) do
    Begin
      Percepcao(aPercepcion[i], aPercepcion[i+1], aPercepcion[i+2]);
      Inc(i,3);
    End;

    i:=0;
  end;

  // Faz o registro do pagamento
  if Copy(sRet, 1, 1) <> '1' then
     begin
        While i<Length(aAuxiliar) do
           begin
           sCmd:='|'+aAuxiliar[i]+'|'+Trim(FormataTexto(aAuxiliar[i+1],9,2,3,'.'));
           sRet := EnviaComando('D'+ sCmd +'|T|0', 'S');
           Inc(i,2);
        end;
     end;

  result := sRet;
end;

//****************************** 435F ***************************************
function TImpFiscalHasar435F.Abrir(sPorta : String; iHdlMain:Integer) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
       begin
       ShowMessage('A função "'+sMsg+'" não existe na Dll: WINFIS32.DLL');
       Result := False;
       end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  iRet : Integer;
  IniFile : TIniFile;
begin
  fHandle := LoadLibrary( 'WINFIS32.DLL' );
  if (fHandle <> 0) Then
    begin
    bRet := True;
    aFunc := GetProcAddress(fHandle,'MandaPaqueteFiscal');
    if ValidPointer( aFunc, 'MandaPaqueteFiscal') then
       fFuncMandaPaqueteFiscal := aFunc
    else
       begin
       bRet := False;
       end;

    aFunc := GetProcAddress(fHandle,'UltimoStatus');
    if ValidPointer( aFunc, 'UltimoStatus' ) then
      fFuncUltimoStatus := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'UltimaRespuesta');
    if ValidPointer( aFunc, 'UltimaRespuesta' ) then
      fFuncUltimaRespuesta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'OpenComFiscal');
    if ValidPointer( aFunc, 'OpenComFiscal' ) then
      fFuncOpenComFiscal := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'CloseComFiscal');
    if ValidPointer( aFunc, 'CloseComFiscal' ) then
      fFuncCloseComFiscal := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'InitFiscal');
    if ValidPointer( aFunc, 'InitFiscal' ) then
      fFuncInitFiscal := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'VersionDLLFiscal');
    if ValidPointer( aFunc, 'VersionDLLFiscal' ) then
      fFuncVersionDLLFiscal := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'BusyWaitingMode');
    if ValidPointer( aFunc, 'BusyWaitingMode' ) then
      fFuncBusyWaitingMode := aFunc
    else
    begin
      bRet := False;
    end;
    aFunc := GetProcAddress(fHandle,'CambiarVelocidad');
    if ValidPointer( aFunc, 'CambiarVelocidad' ) then
      fFuncCambiarVelocidad := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ProtocolMode');
    if ValidPointer( aFunc, 'ProtocolMode' ) then
      fFuncProtocolMode := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'SearchPrn');
    if ValidPointer( aFunc, 'SearchPrn' ) then
      fFuncSearchPrn := aFunc
    else
    begin
      bRet := False;
    end;
    end
  else
    Begin
    ShowMessage('O arquivo WinFis32.DLL não foi encontrado.');
    bRet := False;
    end;
  Result:='1|';
  if bRet then
     Begin
     iHandle := fFuncOpenComFiscal(StrToInt(Copy(sPorta,4,1)), MODE_ANSI);
     iRet:=iHandle;
     If iHandle >= 0 Then
     Begin
        EnviaComando(#102);
        EnviaComando(#150);
        IniFile := TIniFile.Create(ExpandFileName('sigaloja.ini'));
        multiLine := false;
        if ( iRet >= 0 ) and IniFile.SectionExists('hasar') then
        Begin
           fFuncCambiarVelocidad(ihandle,IniFile.ReadInteger('hasar','boundrate',9600));
           multiLine := (IniFile.ReadInteger('hasar','multiline',0) = 1);
        end;
        iRet:= fFuncInitFiscal(iHandle);
        if (IniFile.SectionExists('hasar'))  AND (iRet >= 0 ) then 
        Begin
           EnviaComando(#160 + '|'+IniFile.ReadString('hasar','boundrate','9600'));
        end;
        If (iRet >= 0 ) then
        Begin
           // Altera configuração do ECF para não reimprimir o cupom quando há queda de energia
           EnviaComando(PChar(#100 + '|8|N'));
           AlimentaProperties;
           sTipoCup := 'T';
           Result   := '0|';
        End;
     End;
     If iRet < 0 then
        Begin
        Erro1(IntToStr(iRet),'I');
        fFuncCloseComFiscal(iHandle);
        Result:='1';
        End;
     End;
  if Copy(Result,1,1)<>'0' then
     Begin
     ShowMessage('Erro na abertura da porta');
     result := '1|';
     end;
end;

//------------------------------------------------------------------------------
function TImpFiscalHasar435F.AbreCupom(Cliente:String; MensagemRodape:String):String;
Var
 sTipo: String;
 sCmd : String;
 sRet : String;
 sFatCup : String;
 aAuxiliar : TaString;
 cEndCli : String;
 iX   : Integer;
Begin
   GravaLog('TImpFiscalHasar435F - Inicio da função AbreCupom');

   //Protheus(Advpl) substitui "," vírgula por "&_",
   GravaLog('AbreCupom - Cliente [' + Cliente + ']');
   Cliente := StrTran(Cliente,'&_',',');
   GravaLog('AbreCupom - Cliente - Tratado [' + Cliente + ']');

   sRet:='1';

   //sCmd :='A|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|20183697308|I|C|MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM|||';
   sTipo:='B';

   // Monta um array auxiliar com as formas solicitadas
   MontaArray( Cliente,aAuxiliar );
   GravaLog(' AbreCupom -  Tamanho de Auxiliar :' + IntToStr(Length(aAuxiliar)));

   For iX := 0 to Length(aAuxiliar)-1 do
   begin
     GravaLog('AbreCupom - Indice [' + IntToStr(iX) + '] + aAuxiliar [ ' + aAuxiliar[iX] + ']');
   end;

   GravaLog(' AbreCupom -  Passou do For');

   //-----------------------------------------------------
   // aAuxiliar[0] => Serie A o B
   // aAuxiliar[1] => Razón Social
   // aAuxiliar[2] => CUIT
   // aAuxiliar[3] => TIPO    => E Exento
   //                         => C Consumidor Final
   //                         => A No Responsable
   //                         => I Responsable Inscripto
   //                         => M Monotributo
   // aAuxiliar[4] => TIPO ID => C CUIT
   //                         => 2 DNI
   // aAuxiliar[5] => Vendedor
   // aAuxiliar[6] => Condicion de Pago
   // aAuxiliar[7] => Indica se sera impressora ticket
   // aAuxiliar[8] => Domicilio 1ra Linea
   // aAuxiliar[9] => Domicilio 2ra Linea
   // aAuxiliar[10] => Domicilio 3ra Linea
   // aAuxiliar[11] => Endereço Comercial do Proprietário
   // aAuxiliar[12] => Complemento Domicilio Comercial do Proprietário (Cidade - Estado - CEP)
   // aAuxiliar[13] => Estabelecimento - Resolução No 52 - Provincia de Mendoza (ME)
   //-----------------------------------------------------
   sTipo  := UpperCase(aAuxiliar[0]);
   GravaLog(' AbreCupom -  sTipo:' + sTipo);

   sSerie := UpperCase(aAuxiliar[0]);
   GravaLog(' AbreCupom -  sSerie:' + sSerie);

   aAuxiliar[2] := StrTran(aAuxiliar[2],'.','');
   GravaLog(' AbreCupom -  aAuxiliar[2]:' + aAuxiliar[2]);

   If (Length(aAuxiliar) > 7) AND (aAuxiliar[7] = 'S') then
     begin
        sFatCup := aAuxiliar[7];
        bFatTic := True;
        GravaLog(' EnviaComando : d|9|0 ->');
        sRet := EnviaComando('d|' + IntToStr(9) + '|' + IntToStr(0));   //impressao de fatura Slip - quantidade maxima de copias
        GravaLog(' EnviaComando : d|9|0 <- sRet [' + sRet + ']');
     end
   Else
     begin
        sFatCup := 'T';
        bFatTic := False;
        GravaLog(' EnviaComando : d|9|4 ->');
        sRet   := EnviaComando('d|' + IntToStr(9) + '|' + IntToStr(4));   //impressao de ticket - protheus controla a quantidade de impressoes - quantidade maxima de copias
        GravaLog(' EnviaComando : d|9|4 <- sRet [' + sRet + ']');
     end;

   sTipoCup := sFatCup;

   If aAuxiliar[2] = ''
   then aAuxiliar[2] := '9999999999';

   //esse modelo nao aceita clientes do tipo Responsable no inscripto (no existente en 435F)
   If ( aAuxiliar[3] = 'N' ) or ( aAuxiliar[3] = 'B' ) then
   begin
      ShowMessage('Los clientes del tipo responsable no inscripto no es aceito en el modelo de impressora.');
      Result := '1';
   end;

   If bFatTic
   then cEndCli := Copy(Copy(aAuxiliar[8], 1, 33)+' - '+Copy(aAuxiliar[9], 1, 9)+' - '+Copy(aAuxiliar[10], 1, 2), 1, 50)
   Else cEndCli := Copy(Copy(aAuxiliar[8], 1, 29)+' - '+Copy(aAuxiliar[9], 1, 8)+' - '+Copy(aAuxiliar[10], 1, 2), 1, 45);

   //limpa informacoes do cabecalho do cupom
   GravaLog(' EnviaComando : 93|1 ->');
   EnviaComando( PChar( #93 + '|1|' + aAuxiliar[11]) );
   GravaLog(' EnviaComando : 93|1 <-');

   GravaLog(' EnviaComando : 93|2 ->');
   If Length(aAuxiliar) > 12
   then EnviaComando( PChar( #93 + '|2|' + aAuxiliar[12]) )
   Else EnviaComando( PChar( #93 + '|2|' + '') );
   GravaLog(' EnviaComando : 93|2 <-');

   GravaLog(' EnviaComando : 93|3 ->');
   If Length(aAuxiliar) > 12
   then EnviaComando( PChar( #93 + '|3|' + aAuxiliar[13]) )
   Else EnviaComando( PChar( #93 + '|3|' + '') );
   GravaLog(' EnviaComando : 93|3 <-');

   GravaLog(' EnviaComando : 93|4 ->');
   EnviaComando( PChar( #93 + '|4|' + #127) );
   GravaLog(' EnviaComando : 93|4 <-');

   GravaLog(' EnviaComando : 93|5 ->');
   EnviaComando( PChar( #93 + '|5|' + #127) );
   GravaLog(' EnviaComando : 93|5 <-');

   GravaLog(' EnviaComando : 93|11 ->');
   EnviaComando( PChar( #93 + '|11|' + aAuxiliar[5]) ); // Vendedor na 1ª linha do rodapé
   GravaLog(' EnviaComando : 93|11 <-');

   GravaLog(' EnviaComando : 93|12 ->');
   EnviaComando( PChar( #93 + '|12|' + #127) );
   GravaLog(' EnviaComando : 93|12 <-');

   GravaLog(' EnviaComando : 93|13 ->');
   EnviaComando( PChar( #93 + '|13|' + #127) );
   GravaLog(' EnviaComando : 93|13 <-');

   GravaLog(' EnviaComando : 93|14 ->');
   EnviaComando( PChar( #93 + '|14|' + #127) );
   GravaLog(' EnviaComando : 93|14 <-');

   //seta as informacoes do cabecalho do cupom
   sCmd   := PChar( '|'+aAuxiliar[1]+'|'+aAuxiliar[2]+'|'+aAuxiliar[3]+'|'+aAuxiliar[4]+'|'+cEndCli);
   GravaLog(' EnviaComando : sCmd -> [' + sCmd + ']');
   sRet   := EnviaComando( 'b'+sCmd,'S' );
   GravaLog(' EnviaComando : sCmd <- sRet [' + sRet + ']');

   If sRet='0' then
   Begin
     GravaLog(' EnviaComando : sTipo -> ');
     sRet   := EnviaComando('@|'+ sTipo+'|'+sFatCup+'|'+sFatCup,'S' );
     GravaLog(' EnviaComando : sTipo <- sRet [' + sRet + ']');

     if sRet='0' then
     Begin
        EnviaComando('*');
        If sTipo='A'
        then sCmd  := Status(5,sRet)
        Else sCmd  := Status(3,sRet);

        //Grava o tipo do Ultimo Cupom e o tipo do Cupom (T/A/B) no arquivo \ap5\bin\P+Numero PDV.HSR
        HasarCup( 'G',sTipo+sCmd);
     End;
   End;

   Result:=sRet;

   GravaLog('TImpFiscalHasar435F - Fim da função AbreCupom');
End;

//------------------------------------------------------------------------------
function TImpFiscalHasar435F.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer): String;
Var
  sCmd         : String;
  sRet         : String;
  sPrintDesc   : String;
  sTexto       : String;
  sTipoImp     : String;
  IniArq       : TIniFile;
  iCont        : Integer;
  aAuxiliar    : TaString;
Begin

  IniArq    := TIniFile.Create(ExpandFileName('sigaloja.ini'));
  multiLine := (IniArq.ReadInteger('hasar','multiLine',0) = 1);

  If LogDll Then
  Begin
     If multiLine Then
       sTexto := 'multiLine = true'
     Else
       sTexto := 'multiLine = false';
     HasarLog( 'hasar.log', sTexto );
     If bFatTic Then
       sTexto := 'bFatTic = true'
     Else
       sTexto := 'bFatTic = false';
     HasarLog( 'hasar.log', sTexto );
  End;

  if Pos('|',Aliquota)=0 then
     Aliquota := Copy(Aliquota,1,5)+'|0.00';

  MontaArray( Aliquota, aAuxiliar );

  {if Pos('%',Aliquota)<>0 then
     Aliquota := Copy(Aliquota,2,30);}

  iCont := 0;
  // Registrando Item
  If ( multiLine ) And ( Not bFatTic ) And ( Length(Codigo + ' ' + Descricao) > 23 )  Then
  Begin

     sPrintDesc := Codigo + ' ' + Descricao;
     
     If (Length(sPrintDesc) > 23) And (Length(sPrintDesc) <= 31) Then
        sPrintDesc := Copy(sPrintDesc, 1, 23) + Space(8) + Copy(sPrintDesc, 24, Length(sPrintDesc)-23);

     While ( iCont < 4 ) And ( Length(sPrintDesc) > 23 ) Do
     Begin                                                                 // Imprime até 4 linhas de
        //ticket com linhas adicionais para descricao do produto           // descrição adicional
        sRet := EnviaComando('A'+'|'+ Copy(sPrintDesc,1,31)+'|0');
        sPrintDesc := Copy(sPrintDesc,32,Length(sPrintDesc));
        Inc(iCont);
     End;
     If LogDll Then
        HasarLog( 'hasar.log', sPrintDesc );
  End
  Else If (multiLine) and (bFatTic) and (Length(Codigo + ' ' + Descricao) > 50) then begin

     sPrintDesc := Codigo + ' ' + Descricao;
     While ( iCont < 4 ) And ( Length(sPrintDesc) > 50 ) Do
     Begin                                                                 // Imprime até 4 linhas de
        //ticket com linhas adicionais para descricao do produto           // descrição adicional
        sRet := EnviaComando('A'+'|'+ Copy(sPrintDesc,1,50)+'|0');
        sPrintDesc := Copy(sPrintDesc,51,Length(sPrintDesc));
        Inc(iCont);
     End;
     If LogDll Then
        HasarLog( 'hasar.log', sPrintDesc );

  End
  Else
  Begin
     //ticket e fatura com 1 para descricao do produto
     sPrintDesc := Copy(Codigo + ' ' + Descricao + space(50),1,50);

     If LogDll Then
     Begin
        HasarLog( 'hasar.log', 'RegistraItem3' );
        HasarLog( 'hasar.log', Copy(Codigo + ' ' + Descricao + space(50),1,50) );
     End;

  End;

  case nTipoImp of
       1  : sTipoImp := 'T';
       2  : sTipoImp := 's';
  Else
       sTipoImp := 's';
  end;

  sCmd :='|' + sPrintDesc +
         '|' + FormataTexto(qtde,14,10,1,'.')+
         '|' + FormataTexto(VlrUnit,11,4,1,'.')+
         '|' + FormataTexto(aAuxiliar[0],5,2,1)+
         '|M'+
         '|$'+ FormataTexto(aAuxiliar[1],15,8,1);

  sRet := EnviaComando('B'+sCmd+'|0|'+sTipoImp,'S' );

  If LogDll Then
  Begin
     HasarLog( 'hasar.log', 'RegistraItem4' );
     HasarLog( 'hasar.log', 'B' + sCmd + '|0|' + sTipoImp );
  End;

  If (StrToFloat(vlrdesconto) > 0) and (sRet = '0') then
  begin
    sCmd := '|'+Space(50)+'|'+FormataTexto(vlrDesconto,12,2,1)+ '|m|0';
    //sRet := EnviaComando('U'+sCmd+'|B','S');
    sRet := EnviaComando('U'+sCmd+'|'+sTipoImp,'S');
  end;
  Result:= sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.StatusImp( Tipo:Integer ):String;
var
  SRet : String;
  iRet : Integer;
  aBuff   : array [0..512] of char;
  sBuff : String;
begin
// Tipo - Indica qual o status quer se obter da impressora
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
// 17 - Consulta de Estado - Específico Hasar

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

//³ Verificacion de Status de la Impresora                      ³
// a Função HexToBin - Retorna o do bit menos significativo para o mais significativo
// Bit  0 - Siempre Cero
// Bit  1 - Siempre Cero
// Bit  2 - 1 = Error de Impresora
// Bit  3 - 1 = Impresora Off-line
// Bit  4 - 1 = Falta Papel del Diario
// Bit  5 - 1 = Falta Papel de Tickets
// Bit  6 - 1 = Buffer de Impresora Lleno
// Bit  7 - 1 = Buffer de Impresora Vacio
// Bit  8 - 1 = Tapa de Impresora Abierta
// Bit  9 - Siempre Cero
// Bit 10 - Siempre Cero
// Bit 11 - Siempre Cero
// Bit 12 - Siempre Cero
// Bit 13 - Siempre Cero
// Bit 14 - 1 = Cajon de dinero cerrado o ausente
// Bit 15 - 1 = OR logico de los bits 2-5, 8 y 14

If LogDll Then
   HasarLog( 'hasar.log', 'TImpFiscalHasar435F.StatusImp( ' + IntToStr(Tipo) + ' )' );


// Faz a leitura da Hora
if Tipo = 1 then
   begin
   EnviaComando('Y');
   sRet := Status(4,sRet);
   Result:='0|'+Copy(sRet,1,2)+':'+Copy(sRet,3,2)+':'+Copy(sRet,5,2);
   end
// Faz a leitura da Data
else if Tipo = 2 then
   begin
   EnviaComando('Y');
   sRet := Status(3,sRet);
   Result:='0|'+Copy(sRet,5,2)+'/'+Copy(sRet,3,2)+'/'+Copy(sRet,1,2);
   end
   // Faz a checagem de papel
else if Tipo = 3 then
   begin
   EnviaComando('Y');
   sRet := Status(1,sRet);
   sRet := HexToBin(sRet);
   if ( Copy(sRet,4,1)='0' ) and ( Copy(sRet,5,1)='0' ) then
      Result:='0|'
   Else
     Result:='7';
   End
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  Result:= '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
   Begin
     Result:='1|';

     If LogDll Then
       HasarLog( 'hasar.log', 'EnviaComando(*)' );

     EnviaComando('*');

     If LogDll Then
       HasarLog( 'hasar.log', 'Status(4,sRet)' );

     sRet := Status( 4, sRet );

     If LogDll Then
       HasarLog( 'hasar.log', 'sRet: ' + sRet );

     If Length( sRet ) > 3 Then
     Begin
       If Copy( sRet, 4, 1 ) = '2' Then
         Result := '0'
       Else
         Result := '7';
     End;
   End
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
  result := '1'
//9 - Verifica o Status do ECF
else if Tipo = 9 Then
  result := '1'
//10 - Verifica se todos os itens foram impressos.
else if Tipo = 10 Then
  result := '1'
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
  Result := '0'
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
else if Tipo = 15 then
   Result := '1'
// 16 - Verifica se exige o extenso do cheque
else if Tipo = 16 then
    Result := '1'
else if Tipo = 17 then
  Begin
    sRet   := EnviaComando('*');
    iRet := fFuncUltimaRespuesta (iHandle , aBuff );

    If (iRet >= 0) And (sRet = '0') then
    Begin
        sBuff := aBuff;
        While ContaChar(sBuff, #28) < 8 Do
           sBuff := sBuff + #28;

         result := '0|'+sBuff;
    End
    else
    Begin
        result := '1';
    End;
  End
// 20 ao 40 - Retorno criado para o PAF-ECF
else if (Tipo >= 20) AND (Tipo <= 40) then
  Result := '0'
else If Tipo = 45 then
  Result := '0|'// 45 Codigo Modelo Fiscal
else If Tipo = 46 then // 46 Identificação Protheus ECF (Marca, Modelo, firmware)
  Result := '0|'// 45 Codigo Modelo Fiscal
Else
  Result := '1';

If LogDll Then
   HasarLog( 'hasar.log', 'StatusImp - Result: ' + Result );

end;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String;
var
  sDataIn,sDataFim: String;
  sRet    : String;
Begin
  if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
     Begin
     //esta impressora nao aceita esse comando com o parametro de numero inicial e final de reducao Z
     sRet := '0';
     End
  Else
     Begin
     sDataIn    :=FormataData(DataInicio,6);
     sDataFim   :=FormataData(DataFim,6);
     sRet       := EnviaComando(':|'+sDataIn+'|'+sDataFim+'|T','S');
     End;

  result := sRet;
end;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.CancelaCupom( Supervisor:String ):String;
Var
  sRet: String;
Begin
// Recebe o parâmetro Supervisor no seguinte formato:
// cTexto+ '|' + cVlrPago

   sRet := EnviaComando(#152);

   if not(sRet = '0') then
   begin
      sRet := EnviaComando('D|' + Supervisor + '|C|0');
      sRet := EnviaComando('J');
      sRet := EnviaComando('E');
      sRet := EnviaComando(#152);
   end;

   Result:=sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.Suprimento( Tipo:Integer;Valor:String; Forma:String; Total:String; Modo:Integer; FormaSupr:String ):String;
Var  sRet      : string;
     aAuxiliar : TaString;
     i         : Integer;
begin
//Tipo -> 1 Le o suprimento da impressora
//Tipo -> 2 Grava suprimento na impressora
//Tipo -> 3 Efetua sangria

    i:= 0;
    //aAuxiliar - Descricao da Forma
    //aAuxiliar - Valor
    MontaArray( FormaSupr, aAuxiliar );

    if Tipo = 1 then
    begin
    //Função não disponível para este equipamento
        sRet := '0';
    end

    else if Tipo = 2 then
    begin
        sRet := AbreCupomNaoFiscal('','', '', '');
        if sRet = '0' then
            begin
            If Forma = '' then
               Forma := 'Efetivo';
            sRet := TextoNaoFiscal('*****************FUNDO FIJO******************', 1);
            sRet := TextoNaoFiscal(Valor + ' - ' + Forma,1);
            end;
        if sRet = '0' then
            sRet := FechaCupomNaoFiscal();
    end

    else if Tipo = 3 then
    begin
        sRet := AbreCupomNaoFiscal('','', '', '');
        if sRet = '0' then
            begin
            sRet := TextoNaoFiscal('**************RENDICION DE CAJA**************', 1);
            While i < Length(aAuxiliar) do
               begin
               sRet := TextoNaoFiscal(aAuxiliar[i + 1] + ' - ' + aAuxiliar[i],1);
               Inc(i,2)
               end;
            end;
        if sRet = '0' then
            sRet := FechaCupomNaoFiscal();
    end;

   Result := sRet;
end;

//---------------------------------------------------------------------------
function TImpFiscalHasar435F.RelatorioGerencial( Texto:String;Vias:Integer; ImgQrCode: String): String;
var
  i       :Integer;
  sRet    :String;
  sTexto  :String;
  sLinha  :String;
begin
  Result := '0';

  //verifica a quantidade de vias
  if Vias > 1 then
  Begin
    sTexto := Texto;
    i:=1;
    While i < Vias do
    Begin
        Texto:= Texto+ sTexto;
        Inc(i);
    End;
  End;

  // Abre o cupom não fiscal
  sRet := AbreCupomNaoFiscal('','', '', '');
  if sRet <> '0' then
  Begin
      Result := '1';
      Exit;
  End;

  {sRet := TextoNaoFiscal('**************Informe Gerencial**************', 1);
  sRet := TextoNaoFiscal(Space(45), 1);
  sRet := TextoNaoFiscal(Space(45), 1);}

  // Laço para imprimir toda a mensagem
  While ( Trim(Texto)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 40 caracter do Texto
         For i:= 1 to 40 do
         Begin
             // Caso encontre um CHR(10) (Line Feed) imprime a linha
             If Copy(Texto,i,1) = #10 then
                Break;
             sLinha := sLinha + Copy(Texto,i,1);
         end;
         sLinha := Copy(sLinha+space(40),1,40);
         Texto  := Copy(Texto,i+1,Length(Texto));
         sRet := TextoNaoFiscal(sLinha, 1);
         // Ocorreu erro na impressão do cupom
         if sRet <> '0' then
         Begin
            Result := '1';
            Exit;
         End;
      End;
  sRet := FechaCupomNaoFiscal();
  If sRet <> '0'
  then Result:='1'
  Else Result := '0';
End;

//---------------------------------------------------------------------------
function TImpFiscalHasar320F.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;
Var
  sCmd      : string;
  sRet      : String;
  aAuxiliar : TaString;
  aPercepcion : TaString;
  aSubTotal : TaString;
  i         : Integer;
  sMensagem : String;
  sSubTotal : String;
  iPercepcion : double;
Begin

   i := 0;
   iPercepcion := 0;
   sRet := '0';
   sMensagem := 'Lo número máximo de modos de pago excedieron.';
   Pagamento := StrTran( Pagamento, ',', '.' );

   // Monta um array auxiliar com as formas solicitadas
   MontaArray( Pagamento, aAuxiliar );

   // Monta um array com as percepciones a serem enviadas
   MontaArray( Percepcion, aPercepcion );

   While i < Length( aPercepcion ) Do
   Begin
      iPercepcion := iPercepcion + StrToFloat( aPercepcion[i+2] );
      Inc( i, 3 );
   End;

   i := 0;

   //permite ate 4 formas de pagamento
   if Length(aAuxiliar) > 8 then
   begin
      sRet := '1|' + sMensagem;
      ShowMessage(sMensagem);
   end;

   //Tratamento para ajuste por redondeo-------------------------------
   if Copy(sRet, 1, 1) <> '1' then
   begin
      sSubTotal := SubTotal('P|0|0');
      if LogDll then HasarLog( 'hasar.log', 'SubTotal: '+sSubTotal );
      If Copy( sSubTotal, 1, 1) = '0' then
      begin
         If LogDll Then HasarLog( 'hasar.log', 'SubstituiStr **********' );
         sSubTotal := SubstituiStr( sSubTotal, #28, '|' );
         If LogDll Then HasarLog( 'hasar.log', 'SubstituiStr: '+sSubTotal );
         If LogDll Then HasarLog( 'hasar.log', 'MontaArray **********' );
         MontaArray( sSubTotal, aSubTotal );
         If LogDll Then HasarLog( 'hasar.log', 'MontaArray Length(aSubTotal): '+IntToStr(Length(aSubTotal)) );
         If LogDll Then HasarLog( 'hasar.log', 'FormataTexto **********' );
         If Length(aSubTotal) > 4 Then
         Begin
            aSubTotal[4] := FormataTexto( aSubTotal[4], 11, 2, 5);
            If Abs(StrToFloat(Vinculado) - ( StrToFloat(aSubTotal[4]) + iPercepcion )) >= 0.005 then
            Begin
               If LogDll Then
               Begin
                  HasarLog( 'hasar.log', 'aSubTotal[4]: '+aSubTotal[4] );
                  HasarLog( 'hasar.log', 'Vinculado: '+Vinculado );
               End;
               If ( StrToFloat( aSubTotal[4] ) + iPercepcion ) > StrToFloat( Vinculado ) Then
               Begin
                  aSubTotal[4] := FloatToStr( ( StrToFloat( aSubTotal[4] ) + iPercepcion ) - StrToFloat( Vinculado ) );
                  aSubTotal[4] := FormataTexto( aSubTotal[4], 12, 2, 1 );
                  sRet   := EnviaComando('T|Ajuste por Redondeo|' + aSubTotal[4] + '|m|0|T','S'); //Desconto
               End
               Else If ( StrToFloat( aSubTotal[4] ) + iPercepcion ) < StrToFloat( Vinculado ) Then
               Begin
                  aSubTotal[4] := FloatToStr( StrToFloat(Vinculado) - ( StrToFloat(aSubTotal[4]) + iPercepcion ) );
                  aSubTotal[4] := StrTran( aSubTotal[4], '-', '');
                  aSubTotal[4] := FormataTexto( aSubTotal[4], 12, 2, 1);
                  sRet   := EnviaComando('T|Ajuste por Redondeo|' + aSubTotal[4] + '|M|0|T','S'); //Acrecimo
               End;
            End;
         End
         Else
         Begin
            sRet := CancelaCupom('Cancelamento Automatico - Pagamento - SubTotal');
            if LogDll then HasarLog( 'hasar.log', 'CancelaCupom: '+sRet );
            sRet := '1';
         End;
      End;
   End;

  // Faz o registro das percepciones se houver
  if Length(aPercepcion)>0 then
  begin
    If LogDll Then HasarLog( 'hasar.log', 'FormataTexto **********' );
    While i<Length(aPercepcion) do
    Begin
      If LogDll Then HasarLog( 'hasar.log', 'Percepcao( '+ aPercepcion[i] + ', ' + aPercepcion[i+1] + ', ' + aPercepcion[i+2] + ') ' );
      Percepcao(aPercepcion[i], aPercepcion[i+1], aPercepcion[i+2]);
      Inc(i,3);
    End;

    i:=0;
  end;

  // Faz o registro do pagamento
  if Copy(sRet, 1, 1) <> '1' then
     begin
        While i<Length(aAuxiliar) do
           begin
           sCmd:='|'+aAuxiliar[i]+'|'+Trim(FormataTexto(aAuxiliar[i+1],9,2,3,'.'));
           sRet := EnviaComando('D'+ sCmd +'|T|0', 'S');
           if LogDll then HasarLog( 'hasar.log', 'Pagamento '+IntToStr(i+1)+': '+sRet );
           If (i = 0) And (sRet <> '0') then
           Begin
              sRet := CancelaCupom('Cancelamento Automatico - Pagamento');
              if LogDll then HasarLog( 'hasar.log', 'CancelaCupom: '+sRet );
              i := Length(aAuxiliar)+1;
              sRet := '1';
           End;
           Inc(i,2);
        end;
     end;

  result := sRet;
end;

//---------------------------------------------------------------------------
function TImpFiscalHasar435F.FechaCupom( Mensagem:String ):String;
Var
  sRet      : String;
  nX        : Integer;
  sTexto    : String;
  sTextoAux : String;
  iLinha    : Integer;
Begin
  //Protheus(Advpl) substitui "," vírgula por "&_",
  Mensagem := StrTran(Mensagem,'&_',',');

  Mensagem  := Copy(Mensagem+Space(1000),1,1000);
  iLinha    := 12;
  sTexto    := '';
  sTextoAux := '';
  If sTipoCup = 'T' then
  Begin
    For nX := 12 to 20 do
        sRet   := EnviaComando(']|'+IntToStr(nX)+'|'+#127);
  End
  Else
    For nX := 12 to 14 do
        sRet   := EnviaComando(']|'+IntToStr(nX)+'|'+#127);

  While Length(Mensagem) > 0 Do
  Begin
    If ( ( sTipoCup = 'T' ) And ( iLinha > 20 ) ) Or (( sTipoCup <> 'T' ) And ( iLinha > 14 ) )Then
      break;
    // A mensagem é recortada a cada '_'(pipe) encontrado, ou, caso não haja '_' é
    // recortada a cada 120 caracteres. São permitidas 4 linhas de mensagem no final do cupom.
     If Pos('_', Mensagem)>0 Then //MUDADO SEPARADOR DE LINHA "|" PARA "_"
     Begin
        If Pos('_', Mensagem) <> 1 Then //MUDADO SEPARADOR DE LINHA "|" PARA "_"
        Begin
           sTexto := Copy(Mensagem,1, Pos('_', Mensagem)-1); //MUDADO SEPARADOR DE LINHA "|" PARA "_"
           While Length(sTexto) > 0 Do
           Begin
              If sTipoCup = 'T' Then
              Begin
                 sTextoAux := Copy(sTexto,1, 45);
                 sTexto := Copy(sTexto, 46, Length(sTexto));
              End
              Else
              Begin
                 sTextoAux := Copy(sTexto,1, 120);
                 sTexto := Copy(sTexto, 121, Length(sTexto));
              End;
              sRet := EnviaComando(']|' + IntToStr(iLinha) + '|' + sTextoAux);
              Inc(iLinha);
           End;
        End;
        Mensagem := Copy(Mensagem, Pos('_', Mensagem)+1, Length(Mensagem)); //MUDADO SEPARADOR DE LINHA "|" PARA "_"
     End
     Else
     Begin
        If sTipoCup = 'T' Then
        Begin
           sTexto := Copy(Mensagem,1, 45);
           Mensagem := Copy(Mensagem, 46, Length(Mensagem));
        End
        Else
        Begin
           sTexto := Copy(Mensagem,1, 120);
           Mensagem := Copy(Mensagem, 121, Length(Mensagem));
        End;
        sRet := EnviaComando(']|'+IntToStr(iLinha)+'|'+sTexto);
        Inc(iLinha);
     End;
  End;

  sRet   := EnviaComando('E|'+ IntToStr(0),'S');

  result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.AbreDNFH( sTipoDoc, sDadosCli, sDadosCab, sDocOri, sTipoImp, sIdDoc: String):String;
  Function FSToPipe(aParams:PChar):PChar;
  Var i : Integer;
  Begin
    For i := 1 To Length(aParams) Do
      If aParams[i] = #28 Then aParams[i] := '|';
    Result := aParams;
  End;
Var
  sCabec, sRet: string;
  iRet        : Integer;
  aBuff       : Array [0..512] of Char;
Begin

  If sTipoImp = 'S' Then
    bFatTic := True
  Else
    bFatTic := False;

  If LogDll Then
  Begin
     HasarLog( 'hasar.log', '********** AbreDNFH **********' );
     HasarLog( 'hasar.log', 'TImpFiscalHasar435F.AbreDNFH( ' + sTipoDoc + ', ' + sDadosCli + ', ' + sDadosCab + ', ' + sDocOri + ', ' + sTipoImp + ', ' + sIdDoc +')' );
  End;

  sRet   := EnviaComando('d|' + IntToStr(9) + '|' + IntToStr(0));   //impressao de fatura Slip - quantidade maxima de copias = 0

  sDadosCli := StrTran(sDadosCli,'.','');
  sRet := EnviaComando('b|' + sDadosCli);

  If LogDll Then
  Begin
     HasarLog( 'hasar.log', 'EnviaComando(b' + sDadosCli + ')' );
     HasarLog( 'hasar.log', 'sRet: ' + sRet );
  End;

  If sRet = '0' then
  Begin
    sDadosCab := Copy(sDadosCab, 2, Length(sDadosCab));
    sCabec    := '|' + Copy(sDadosCab,1,Pos('|',sDadosCab));
    sDadosCab := Copy(sDadosCab,Pos('|', sDadosCab)+1,Length(sDadosCab));
    sCabec    := sCabec + Copy(sDadosCab,1,Pos('|',sDadosCab)-1);
    sDadosCab := Copy(sDadosCab,Pos('|', sDadosCab),Length(sDadosCab));
    If (sTipoDoc <> 'x') then
    Begin
        sRet      := EnviaComando( #93 + sCabec);
        If sRet = '0' then
        Begin
            sRet  := EnviaComando( #93 + sDadosCab);
              If sRet = '0' then
              Begin
                sRet := EnviaComando( #147 + sDocOri);
                If sRet = '0' then
                Begin
                     If (sTipoDoc = 'R') or (sTipoDoc = 'S') then
                          sRet := EnviaComando( #128 +'|'+sTipoDoc + '|'+sTipoImp+'|');
                     If LogDll Then
                     Begin
                        HasarLog( 'hasar.log', 'EnviaComando( #128 |' + sTipoDoc + '|' + sTipoImp + '|)' );
                        HasarLog( 'hasar.log', 'sRet: ' + sRet );
                     End;
                End
                Else
                    Result := '1';
              End
              Else
                Result := '1';
        End
        Else
            Result := '1';
    End
    Else
    Begin
        sRet := EnviaComando( #128 + '|' +sTipoDoc +'|'+sTipoImp+'|'+ sDocOri);
        If LogDll Then
        Begin
           HasarLog( 'hasar.log', 'EnviaComando( #128 |' + sTipoDoc + '|' + sTipoImp + '|' + sDocOri + ')' );
           HasarLog( 'hasar.log', 'sRet: ' + sRet );
        End;
    End;
  End
  Else
  Begin
    sRet := '1';
  End;

  If sRet = '0' then
  Begin
      iRet   := fFuncUltimaRespuesta (iHandle , aBuff );
      If LogDll Then
      Begin
         HasarLog( 'hasar.log', 'fFuncUltimaRespuesta (iHandle , aBuff )' );
         HasarLog( 'hasar.log', 'iRet: ' + IntToStr(iRet) );
      End;
      If iRet >= 0 then
          Result := '0|'+aBuff
      Else
          Result := '1';
  End;

End;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.FechaDNFH: String;
Var
  sRet: string;
Begin
  sRet   := EnviaComando(#129);
  Result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.HorarioVerao( Tipo:String ):String;
var
   sData     : String;
   sHora     : String;
   sAuxHora  : String;
   sRet      : String;
begin
   DateTimeToString(sData, 'yymmdd', Date);
   sHora := Copy( StatusImp(1), 3, 8);
   sHora := SubstituiStr(sHora, ':', '');

   If Tipo = '+' then
      sAuxHora := IntToStr( StrToInt( Copy(sHora, 1, 2) ) + 1 ) + Copy(sHora, 3, 4)
   Else
      sAuxHora := IntToStr( StrToInt( Copy(sHora, 1, 2) ) - 1 ) + Copy(sHora, 3, 4);

   sRet   := EnviaComando( #88 + '|' + sData + '|' + sAuxHora );

   Result := sRet;
end;

//----------------------------------------- ----------------------------------
function TImpFiscalHasar435F.AcrescimoTotal( vlrAcrescimo:String ): String;
Var
  sRet:   String;
  sCmd:   String;
Begin
  vlrAcrescimo:= Copy(vlrAcrescimo,Pos('|',vlrAcrescimo)+1,length(vlrAcrescimo));
  sCmd :=        '|'+Space(50)+'|'+copy(vlrAcrescimo,1,12)+ '|M|';
  vlrAcrescimo:= Copy(vlrAcrescimo, Pos('|',vlrAcrescimo)+1, Length(vlrAcrescimo));
  sCmd :=        sCmd + Copy(vlrAcrescimo,1,1);

  If sSerie = 'A' then
     sRet   := EnviaComando('T'+sCmd+'|B','S')
  Else
     sRet   := EnviaComando('T'+sCmd+'|B','S');

  result := sRet;
End;

//------------------------------------------------------------------------------
function TImpFiscalHasar435F.SubTotal (sImprime: String):String;
var
  sBuff, sRet : String;
  aBuff   : array [0..512] of char;
  iRet : Integer;
begin
  iRet := -1;
  sRet   := EnviaComando('C'+#28+ '' +Trim(sImprime));
  if LogDll then HasarLog( 'hasar.log', 'SubTotal - EnviaComando: '+sRet );

  If sRet = '0' then
      iRet := fFuncUltimaRespuesta (iHandle , aBuff );

  If iRet >= 0 then
  begin
      sBuff := aBuff ;
      sBuff := sBuff + #28;
      sRet:='';
      While (length(sBuff)>0) do
      Begin
        sRet:= sRet + Copy(sBuff, 1, Pos(#28,sBuff)-1)+ #28;
        sBuff := Copy(sBuff, Pos(#28,sBuff)+1, Length(sBuff));
      End;
      result := '0|'+ sRet;
      if LogDll then HasarLog( 'hasar.log', 'SubTotal - result: 0|'+ sRet );
  end
  else
  Begin
      result := '1';
      if LogDll then HasarLog( 'hasar.log', 'SubTotal - result: 1' );
  End;
end;

//------------------------------------------------------------------------------
function TImpFiscalHasar435F.EnviaComando(aParams:String;sError:String=''):String;

  Function PipeToFS(aParams:PChar):PChar;
  Var i : Integer;
  Begin
    For i := 1 To Length(aParams) Do
      If aParams[i] = '|' Then aParams[i] := #28;
    Result := aParams;
  End;

Const
  MODE_ANSI  = 1;
  MODE_ASCII = 0;
  nTamBuffer = 512;

Var
  iRet     : LongInt;
  sParams  : String;
  sBuff    : Array [0..512] of Char;
Begin
  if LogDll then HasarLog( 'hasar.log', HasarGetCmd(aParams) );

  sParams := StrPas(PipeToFS(PChar(aParams)));
  if LogDll then HasarLog( 'hasar.log', 'fFuncMandaPaqueteFiscal - sParams: '+sParams );
  iRet := fFuncMandaPaqueteFiscal(iHandle, sParams);
  if LogDll And Not(iRet = -4) then
  Begin
     HasarLog( 'hasar.log', 'fFuncMandaPaqueteFiscal - iRet: '+IntToStr(iRet) );
     sBuff := '';
     fFuncUltimaRespuesta (iHandle , sBuff );
     HasarLog( 'hasar.log', 'Rcvd: '+sBuff );
  End
  Else
  Begin
     HasarLog( 'hasar.log', 'fFuncMandaPaqueteFiscal - iRet: '+IntToStr(iRet) );
     HasarLog( 'hasar.log', 'Error: Error de Comunicaciones.' );
  End;

  if (iRet = 0) then
     Result := '0'
  Else
     Result := '1';

  {if iRet<0 then
  Begin
     Erro1(IntToStr(iRet),'I');
     if LogDll then
     Begin
        HasarLog( 'hasar.log', 'Erro1 I' );
        HasarLog( 'hasar.log', 'Erro1 I: '+sRet );
     End;
  End;}

  //if LogDll then HasarLog( 'hasar.log', 'sError: '+sError );
  //if Trim(sMsg) <> '' then
  //if Trim(sError) <> '' then
  //   iRet:=1;

  {if sError = 'S' then
  Begin
     if LogDll then HasarLog( 'hasar.log', 'ERROR = S' );
     sRet := Status(1,sRet);
     if LogDll then HasarLog( 'hasar.log', 'Status 1' );
     sRet := HexToBin(sRet);
     if LogDll then HasarLog( 'hasar.log', 'HexToBin' );
     sRet:=Erro1(sRet,'P');
     if LogDll then
     Begin
        HasarLog( 'hasar.log', 'Erro1 P' );
        HasarLog( 'hasar.log', 'Erro1 P: '+sRet );
     End;
     if Trim(sRet)='' then
     Begin
        sRet := Status(2,sRet);
        if LogDll then HasarLog( 'hasar.log', 'Status 2' );
        sRet := HexToBin(sRet);
        if LogDll then HasarLog( 'hasar.log', 'HexToBin' );
        sRet:=Erro1(sRet,'F');
        if LogDll then
        Begin
           HasarLog( 'hasar.log', 'Erro1 F' );
           HasarLog( 'hasar.log', 'Erro1 F: '+sRet );
        End;
        if Trim(sRet)='' then
        Begin
           Result := '0';
           HasarLog( 'hasar.log', 'Result 0' );
        End
        Else
        Begin
           Result := '1';
           HasarLog( 'hasar.log', 'Result 1' );
        End;
     End
     Else
     Begin
        Result := '1';
        HasarLog( 'hasar.log', 'Result 1' );
     End;
  End
  Else
  Begin
     if LogDll then HasarLog( 'hasar.log', 'Result: 1' );
     Result := '1';
  End;}
End;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.Status( Tipo: Integer; Texto:String ):String;

  Function FSToPipe(aParams:PChar):PChar;
  Var i : Integer;
  Begin
    For i := 1 To Length(aParams) Do
      If aParams[i] = #28 Then aParams[i] := '|';
    Result := aParams;
  End;

Const
  nTamBuffer = 512;
Var
  sRetStat      : String;
  FiscalStatus  : Integer;
  PrinterStatus : Integer;
  sBuffer       : array[0..511] of char;
  aAuxiliar     : TaString;
  nRet, nTipo   : Integer;
Begin
  nTipo := Tipo;
  If LogDll Then HasarLog( 'hasar.log', 'TImpFiscalHasar435F.Status - Tipo: ' + IntToStr(Tipo) + ' - Texto: ' + Texto );
  FiscalStatus := 0;
  PrinterStatus := 0;
  sRetStat := '000000000000';
  FillChar( sBuffer,nTamBuffer,0 );

  If LogDll Then HasarLog( 'hasar.log', 'Status 1' );

  If LogDll Then HasarLog( 'hasar.log', 'Status 2: ' + sRetStat );

  nRet := fFuncUltimoStatus(iHandle, FiscalStatus, PrinterStatus);

  If LogDll Then HasarLog( 'hasar.log', 'Status 3: ' + IntToStr(nRet) );
  If LogDll Then HasarLog( 'hasar.log', 'Status 4: ' + sRetStat );


  If ( ( nRet = 0 ) And ( FiscalStatus <> 65497 ) And ( PrinterStatus <> 65497 ) ) Then
  Begin
     If LogDll Then HasarLog( 'hasar.log', 'Status 5' );
     nRet := fFuncUltimaRespuesta(iHandle, sBuffer);
     If LogDll Then HasarLog( 'hasar.log', 'Status 6: ' + IntToStr(nRet) );
     If nRet = 0 Then
     Begin
        If LogDll Then HasarLog( 'hasar.log', 'Status 7' );
        sRetStat := StrPas(FSToPipe(sBuffer));
        If LogDll Then HasarLog( 'hasar.log', 'Status 8: ' + sRetStat );
     End;
  End;

  If LogDll Then HasarLog( 'hasar.log', 'Status 9: ' + sRetStat );

  // Monta um array auxiliar com as formas solicitadas
  MontaArray( sRetStat, aAuxiliar );

  If LogDll Then HasarLog( 'hasar.log', 'Status 10 Length(aAuxiliar): ' + IntToStr(Length(aAuxiliar)) );

  If (( Length(aAuxiliar) > 1 ) And ( Length(aAuxiliar) >= nTipo ) And ( nRet = 0 ) ) Then
  Begin
     If LogDll Then HasarLog( 'hasar.log', 'Status 11: ' + sRetStat );
     sRetStat := aAuxiliar[Tipo-1];
  End;

  if LogDll then HasarLog( 'hasar.log', 'Status 12 : ' + sRetStat );

  Result := sRetStat;
end;

//------------------------------------------------------------------------------
function TImpFiscalHasar435F.ReImprime: String;
Var
  sRet: string;
Begin
  if LogDll then HasarLog( 'hasar.log', 'ReImprime ********************' );
  sRet   := EnviaComando(#153);
  if LogDll then HasarLog( 'hasar.log', 'ReImprime: '+sRet );
  Result := sRet;
End;

//----------------------------------------------------------------------------
function TImpFiscalHasar435F.Percepcao(sAliqIVA, sTexto, sValor: String): String;
Var
  sRet: string;
Begin
  sRet   := EnviaComando( #96 + '|' + sAliqIVA + '|' + sTexto + '|' + sValor);
  Result := sRet;
End;

//------------------------------------------------------------------------------ 
function TImpFiscalHasar435F.ReImpCupomNaoFiscal( Texto:String ):String;
Var
  sRet: string;
Begin
  sRet   := EnviaComando(#153, 'S');
  Result := sRet;
End;

//------------------------------------------------------------------------------ 
function TImpFiscalHasar435F.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
Var
  sRet: string;
Begin
   //limpa informações do cabeçario do cumpom fiscal
   EnviaComando( PChar( #93 + '|1|' + #127) );
   EnviaComando( PChar( #93 + '|2|' + #127) );
   EnviaComando( PChar( #93 + '|3|' + #127) );
   EnviaComando( PChar( #93 + '|4|' + #127) );
   EnviaComando( PChar( #93 + '|5|' + #127) );
   EnviaComando( PChar( #93 + '|11|' + #127) );
   EnviaComando( PChar( #93 + '|12|' + #127) );
   EnviaComando( PChar( #93 + '|13|' + #127) );
   EnviaComando( PChar( #93 + '|14|' + #127) );
   
   sRet   := EnviaComando('H','S');
   result := sRet;
End;

//------------------------------------------------------------------------------
function TImpFiscalHasar435F.TextoRecibo(sTexto: String): String;
Var
  sRet, Mensagem: string;
Begin

  While Length(sTexto) > 0 do
  Begin
    If bFatTic then
    Begin
      If Length(sTexto) > 106 Then
      Begin
         Mensagem := Copy(sTexto, 1, 106);
         sRet := EnviaComando(#151 + '|' + Mensagem);
         sTexto := Copy(sTexto, 107, Length(sTexto));
      End
      Else
      Begin
        sRet := EnviaComando(#151 + '|' + sTexto);
        sTexto := '';
      End;
    End
    Else
    Begin
      If Length(sTexto) > 40 Then
      Begin
         Mensagem := Copy(sTexto, 1, 40);
         sRet := EnviaComando(#151 + '|' + Mensagem);
         sTexto := Copy(sTexto, 41, Length(sTexto));
      End
      Else
      Begin
        sRet := EnviaComando(#151 + '|' + sTexto);
        sTexto := '';
      End;
    End;
  End;

  Result := sRet;
End;

//------------------------------------------------------------------------------
function TImpFiscalHasar435F.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
Var
  sRet: string;
  sCmd: string;
  nX  : Integer;
Begin
  nX:=0;
  While Length(Texto)>0 do
     Begin
     if ( Copy(Texto,1,1)=#$A ) or ( nX=40 ) Then
        Begin
        sCmd   := Trim(sCmd);
        sRet   := EnviaComando('I|'+sCmd+'|0');
        sCmd   := '';
        Texto  := Copy(Texto,2,length(Texto));
        nX     := 0;
        End
     Else
        Begin
        Inc(nX);
        sCmd   := sCmd+Copy(Texto,1,1);
        Texto  := Copy(Texto,2,length(Texto));
        End;
     End;

  sCmd   := Trim(sCmd);

  if sCmd <> '' then
  Begin
     sRet   := EnviaComando('I|'+sCmd+'|0')
  End
  Else
  Begin
     sRet   := '0';
  End;

  result := sRet;
End;

//------------------------------------------------------------------------------
function TImpFiscalHasar435F.ReturnRecharge( sDescricao, sValor, sAliquota, sTipo : String; iTipoImp : Integer ):String;
Var
  sRet       : String;
  sCmd       : String;
  sTipoImp   : String;
  sSumaResta : String;
  aAuxiliar  : TaString;
Begin

  sSumaResta := '|M';

  if Pos('|',sAliquota) = 0 then
    sAliquota := Copy(sAliquota,1,5)+'|0.00';

  MontaArray( sAliquota, aAuxiliar );

  case iTipoImp of
       1  : sTipoImp := 'T';
       2  : sTipoImp := 's';
  Else
       sTipoImp := 's';
  end;

  If StrToFloat(sValor) < 0 Then
  Begin
     sValor := FloatToStr(Abs(StrToFloat(sValor)));
     sSumaResta := '|m';
  End;

  sCmd := '|' + sDescricao +
          '|' + FormataTexto(sValor,11,2,1,'.') +
          '|' + FormataTexto(aAuxiliar[0],5,2,1) +
          sSumaResta +
          '|$' + FormataTexto(aAuxiliar[1],15,8,1) +
          '|0' +
          '|' + sTipoImp +
          '|' + sTipo;

  sRet := EnviaComando(Chr(109)+sCmd,'S' );

  Result:= sRet;

End;

//------------------------------------------------------------------------------
Function TImpFiscalHasarPR4F.ImpTxtFis(Texto : String) : String;
var
   sRet, sAux : String;
   nCont : Integer;
Begin

sAux := Texto;
nCont:= 1;
While (sAux <> '') and (nCont <= 4) do
begin
  sRet := EnviaComando(Chr(65)+'|'+ Copy(sAux,1,30) +'|2' );
  sAux := Copy(sAux,31,Length(sAux));
  Inc(nCont);
end;

Result := sRet;
End;

//------------------------------------------------------------------------------
Function Erro1(sErro,Tipo:String): String;

// Verificacion de Status de la Impresora  - Tipo = P
// Bit  0 - Siempre Cero
// Bit  1 - Siempre Cero
// Bit  2 - 1 = Error de Impresora
// Bit  3 - 1 = Impresora Off-line
// Bit  4 - 1 = Falta Papel del Diario
// Bit  5 - 1 = Falta Papel de Tickets
// Bit  6 - 1 = Buffer de Impresora Lleno
// Bit  7 - 1 = Buffer de Impresora Vacio
// Bit  8 - 1 = Tapa de Impresora Abierta
// Bit  9 - Siempre Cero
// Bit 10 - Siempre Cero
// Bit 11 - Siempre Cero
// Bit 12 - Siempre Cero
// Bit 13 - Siempre Cero
// Bit 14 - 1 = Cajon de dinero cerrado o ausente
// Bit 15 - 1 = OR logico de los bits 2-5, 8 y 14

// Verificacion de Status Fiscal - Tipo = F
// Bit  0 - 1 = Error en chequeo de memoria fiscal
// Bit  1 - 1 = Error en chequeo de memoria de trabajo
// Bit  2 - Siempre Cero
// Bit  3 - 1 = Comando Desconocido
// Bit  4 - 1 = Datos no validos en un campo
// Bit  5 - 1 = Comando no valido para el estado fiscal actual
// Bit  6 - 1 = Desborde del Total
// Bit  7 - 1 = Memoria Fiscal llena, bloqueada o dada de baja
// Bit  8 - 1 = Memoria Fiscal a punto de llenarse
// Bit  9 - 1 = Terminal fiscal certificada
// Bit 10 - 1 = Terminal dfiscal fiscalizada
// Bit 11 - 1 = Error en ingreso de fecha
// Bit 12 - 1 = Documento Fiscal Abierto
// Bit 13 - 1 = Documento Abierto
// Bit 14 - Siempre Cero
// Bit 15 - 1 = OR logico de los bits 0 a 8



var
  sMsg:string;
  iErro: Integer;
Begin
  sMsg:='';
  if Tipo='I' then
     Begin
     iErro:=StrToInt(sErro);
     case iErro of
       -1  : sMsg :='Error General.';
       -2  : sMsg :='Handler Inválido.';
       -3  : sMsg :='Intento de Enviar un Comando Cuando se Estaba Processando.';
       -4  : sMsg :='Error de Comunicaciones.';
       -5  : sMsg :='Puerto ya Abierto.';
       -6  : sMsg :='No Hay Memoria.';
       -7  : sMsg :='El Puerto ya Estaba Abierto.';
       -8  : sMsg :='La Dirección Del Buffer de Respuesta es Inválida.';
       -9  : sMsg :='El Comando no Finalizó, Sino que Volvió una Respuesta Tipo STAT_PRN.';
       -10 : sMsg :='El Proceso en Curso Fue Abortado Por El Usuario.';
     end;
     end
  Else if Tipo='P' then
     Begin
     sMsg:='';
     If  Copy( sErro, 14, 1 ) = '1' Then  // Bit 2 - 1 = Error de Impresora
	sMsg:='Error de Impresora Fiscal'

     Else If Copy( sErro,  13, 1 ) = '1' Then  // Bit 3 - 1 = Impresora Off-line
	sMsg:='Impresora Fiscal Off-Line!'

     Else If Copy( sErro,  12, 1 ) = '1'Then  // Bit 4  - 1 = Falta Papel del Diario
	sMsg:='Falta Papel en Impresora Fiscal'

     Else If Copy( sErro,  11, 1 ) = '1' Then // Bit 5 - 1 = Falta Papel de Tickets
	sMsg:='Falta Papel en Impresora Fiscal'

     Else If Copy( sErro,  10, 1 ) = '1' Then // Bit 8 - 1 = Tapa de Impresora Abierta
	sMsg:='Tapa de Impresora Abierta!';
     End

  Else if Tipo='F' then
     Begin
     sMsg:='';
     If Copy(sErro,1,1) = '1' Then   // Bit 15 - 1 = OR logico de los bits 0 a 8
        Begin
	If  Copy(sErro, 16, 1 ) = '1' Then // Bit 0 - 1 = Error en chequeo de memoria fiscal
		sMsg := 'Error en Chequeo de Memoria Fiscal. Terminal Bloqueada!'
	Else If Copy(sErro, 15, 1 ) = '1' Then  // Bit 1  - 1 = Error en chequeo de memoria de trabajo
		sMsg := 'Error en Chequeo de Memoria de Trabajo. Terminal Bloqueada!'
	Else If Copy(sErro, 13, 1 ) = '1' Then // Bit 3 - 1 = Comando Desconocido
		sMsg := 'Comando Desconocido'
	Else If Copy(sErro, 12, 1 ) = '1' Then  // Bit 4 - 1 = Datos no validos en un campo
		sMsg := 'Datos No Validos en un Campo'
	Else If Copy(sErro, 11, 1 ) = '1'  Then // Bit 5 - 1 = Comando no valido para el estado fiscal actual
		sMsg := 'Comando No Valido para el Estado Fiscal Actual'
	Else If Copy(sErro, 10, 1 ) = '1' Then  // Bit 6 - 1 = Desborde del Total
		sMsg := 'Desborde del Total'
	Else If Copy(sErro,  9, 1 ) = '1'  Then // Bit 7 - 1 = Memoria Fiscal llena, bloqueada o dada de baja
		sMsg := 'Memoria Fiscal llena, bloqueada o dada de baja. Terminal Bloqueda!'
	Else If Copy(sErro,  8, 1 ) = '1'  Then // Bit 8 - 1 = Terminal fiscal certificada
		sMsg := 'Memoria Fiscal a Punto de Llenarse!'
	Else
		sMsg := 'Error no determinado en la Impresora Fiscal!';
	End;
     End;

  if Trim(sMsg) <> '' then
     begin
     ShowMessage(sMsg);
     if LogDll then HasarLog( 'hasar.log', 'Error: ' +  sMsg, FALSE )
     end;

  Result := sMsg;
end;

//------------------------------------------------------------------------------
procedure HasarLog ( Arquivo,Texto:String; bStamp:Boolean=TRUE );
var
  pFile,pBuffer : PChar;
  hFile : Int64;
  nTam, nWritten : LongWord;
  sData : String;
begin
  sData := DateTimeToStr( Now() );
  pFile := StrAlloc(Length(Arquivo)+ 1);
  StrPCopy(pFile, Arquivo );
  hFile := CreateFile( pFile,
                       GENERIC_WRITE+GENERIC_READ,
                       0,                                     // Exclusive
                       Nil,
                       OPEN_ALWAYS,
                       FILE_FLAG_WRITE_THROUGH,
                       0 );
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    if bStamp then
      begin
      nTam := Length( sData ) + Length(Texto) + 3;
      pBuffer := PChar( sData + '-' + Texto + #13 + #10 );
      end
    else
      begin
      nTam := Length(Texto) + 2;
      pBuffer := PChar( Texto + #13 + #10 );
      end;

    SetFilePointer( hFile,
                    0,
                    Nil,
                    FILE_END );
    WriteFile( hFile,
               pBuffer^,
               nTam,
               nWritten,
               Nil);
    SetEndOfFile( hFile );
    FlushFileBuffers( hFile );
    CloseHandle( hFile );
  end;
  StrDispose(pFile);
end;

//------------------------------------------------------------------------------
function HasarGetCmd( sCmd : String ) : String;
var
   cMsg : String;
   iChr : Integer;
   sChr : Char;
begin
   sChr := sCmd[1];
   iChr := Ord( sChr );

   case iChr of
      042 : cMsg := ' 042 2ah StatusRequest';
      055 : cMsg := ' 055 37h HistoryCapacity';
      057 : cMsg := ' 057 39h DailyClose';
      058 : cMsg := ' 058 3ah DailyCloseByDate';
      059 : cMsg := ' 059 3bh DailyCloseByNumber';
      060 : cMsg := ' 060 3ch GetDailyReport';
      064 : cMsg := ' 064 40h OpenFiscalReceipt';
      065 : cMsg := ' 065 41h PrintFiscalText';
      066 : cMsg := ' 066 42h PrintLineItem';
      067 : cMsg := ' 067 43h Subtotal';
      068 : cMsg := ' 068 44h TotalTender';
      069 : cMsg := ' 069 45h CloseFiscalReceipt';
      071 : cMsg := ' 071 47h OpenNonFiscalSlip';
      072 : cMsg := ' 072 48h OpenNonFiscalReceipt';
      073 : cMsg := ' 073 49h PrintNonFiscalText';
      074 : cMsg := ' 074 4ah CloseNonFiscalReceipt';
      080 : cMsg := ' 080 50h FeedReceipt';
      081 : cMsg := ' 081 51h FeedJournal';
      082 : cMsg := ' 082 52h FeedReceiptJournal';
      084 : cMsg := ' 084 54h GeneralDiscount';
      085 : cMsg := ' 085 55h LastItemDiscount';
      088 : cMsg := ' 088 58h SetDateTime';
      089 : cMsg := ' 089 59h GetDateTime';
      090 : cMsg := ' 090 5ah BarCode';
      093 : cMsg := ' 093 5dh SetHeaderTrailer';
      094 : cMsg := ' 094 5eh GetHeaderTrailer';
      095 : cMsg := ' 095 5fh SetFantasyName';
      096 : cMsg := ' 096 60h Perceptions';
      097 : cMsg := ' 097 61h ChargeNonRegisteredTax';
      098 : cMsg := ' 098 62h SetCustomerData';
      099 : cMsg := ' 099 63h ChangeIVA Responsability';
      100 : cMsg := ' 100 64h ConfigureControllerByOne';
      101 : cMsg := ' 101 65h ConfigureControllerByBlock';
      102 : cMsg := ' 102 66h GetConfigurationData';
      103 : cMsg := ' 103 67h GetWorkingMemory';
      104 : cMsg := ' 104 68h DNFHFarmacias';
      105 : cMsg := ' 105 69h DNFHReparto';
      106 : cMsg := ' 106 6ah SetVoucherData1';
      107 : cMsg := ' 107 6bh SetVoucherData2';
      108 : cMsg := ' 108 6ch PrintVoucher';
      109 : cMsg := ' 109 6dh ReturnRecharge';
      110 : cMsg := ' 110 6eh ChangeIBNumber';
      112 : cMsg := ' 112 70h SendFirstIVA';
      113 : cMsg := ' 113 71h NextIVATransmission';
      115 : cMsg := ' 115 73h GetInitData';
      120 : cMsg := ' 120 78h ChangeBussinessStartupDate';
      123 : cMsg := ' 123 7bh OpenDrawer';
      127 : cMsg := ' 127 7fh GetPrinterVersion';
      128 : cMsg := ' 128 80h OpenDNFH';
      129 : cMsg := ' 129 81h CloseDNFH';
      146 : cMsg := ' 146 92h GetFantasyName';
      147 : cMsg := ' 147 93h SetEmbarkNumber';
      148 : cMsg := ' 148 94h GetEmbarkNumber';
      150 : cMsg := ' 150 96h GetGeneralConfigurationData';
      151 : cMsg := ' 151 97h ReceiptText';
      152 : cMsg := ' 152 98h Cancel';
      153 : cMsg := ' 153 99h Reprint';
      160 : cMsg := ' 160 a0h SetComSpeed';
      177 : cMsg := ' 177 b1h KillEpromFiscal';
      178 : cMsg := ' 178 b2h WriteDisplay';
   end;

   cMsg :=  cMsg + #13 + #10 + 'Send: ' + sCmd;

   result := cMsg;
end;

//----------------------------------------------------------------------------
Function TImpFiscalHasarP441F.PegaSerie:String;
Var sBuff, sret    : string;
    iRet    : LongInt;
    aBuff   : array [0..512] of char;
Begin
  sRet   := EnviaComando('s');
  iRet := fFuncUltimaRespuesta (iHandle , aBuff );
  sBuff := aBuff;

  If iRet >= 0 then
  begin
      result := '0|'+ Copy(sBuff, 1, Pos(#28, sBuff) - 1);
  end
  else
      result := '1';
End;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.RelGerInd(cIndTotalizador, Texto: String;
  nVias: Integer; ImgQrCode: String): String;
begin
Result := RelatorioGerencial(Texto,nVias, ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalHasarPR4F.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
  RegistraImpressora('HASAR SMH/P-320F'   , TImpFiscalHasar320F,  'ARG', ' ');
  RegistraImpressora('HASAR SMH/P-330F'   , TImpFiscalHasar330F,  'ARG', ' ');
  RegistraImpressora('HASAR SMH/P-PR4F'   , TImpFiscalHasarPR4F,  'ARG', ' ');
  RegistraImpressora('HASAR SMH/P-PL23'   , TImpFiscalHasarPL23,  'ARG', ' ');
  RegistraImpressora('HASAR SMH/P-435F'   , TImpFiscalHasar435F,  'ARG', ' ');
  RegistraImpressora('HASAR SMH/P-441F'   , TImpFiscalHasarP441F, 'ARG', ' ');
//------------------------------------------------------------------------------
end.
