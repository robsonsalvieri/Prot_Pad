unit ImpProComp;

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

  TImpFiscalProComp = class(TImpressoraFiscal)
  private
    fHandle : THandle;
    fFuncAbre              : Function:Integer; StdCall;
    fFuncFecha             : Function:Integer; StdCall;
    fFuncAbreCupom         : Function:Integer; StdCall;
    fFuncVendaItem         : Function(pFormat,pQtde,pPrcUnit,pTrib,pDesc,pVlrDesc,pUnidade,pCodigo,pTamDescr,pDescr,pLegenda:String):Integer; StdCall;
    fFuncDescontoItem      : Function(pDesc,pVlrDesc,pLegenda:String):Integer; StdCall;
    fFuncCancItem          : function(item:String):Integer; StdCall;
    fFuncTotalCupom        : Function(pOper:PChar;pTOper,pValor,pLegenda:String):Integer; StdCall;
    fFuncPagamento         : Function(pReg,pVPgto,pSubtr:String):Integer; StdCall;
    fFuncFechaCupom        : Function(pTamMsg,pMsg:String):Integer; StdCall;
    fFuncCancelaCupom      : Function:Integer; StdCall;
    fFuncLeituraX          : Function(pRelGer:String):Integer; StdCall;
    fFuncReducaoZ          : Function(pRelGer:String):Integer; StdCall;
    fFuncLerData           : function(TipoRel:PChar):integer; StdCall;
    fFuncLerReducao        : function(operador:PChar):integer; StdCall;
    fFuncAbreNFNVinculado  : Function:Integer; StdCall;
    fFuncAbreNFVinculado   : Function:Integer; StdCall;
    fFuncEncerraNaoFiscal  : Function:Integer; StdCall;
    fFuncImprimeNaoFiscal  : function(pTipo:PChar;pLinha:String):Integer; StdCall;
    fFuncTransStatus       : Function(iBitTeste:Byte;pBuffer:Pointer):Integer; StdCall;
    fFuncObtemRetorno      : Function(pBuf_Ret:Pointer):Integer; StdCall;
    fFuncLeRegistrador     : Function(pPar:String):Integer; StdCall;
    fFuncLeAliquota        : Function:Integer; StdCall;
    fFuncTransTot          : Function:Integer; StdCall;
    fFuncTransDataHora     : Function:Integer; StdCall;
    fFuncGravaForma        : Function(pPar,Descricao:String):Integer; StdCall;
    fFuncGravaAliq         : Function(pPar,Valor:String):Integer; StdCall;
    fFuncOperRegNaoVinculado : Function(pReg,pValor:String;pOper,pToper:PChar;pValorOp,pLegenda:String):Integer; StdCall;
    fFuncLeituraMFData       : Function (pDataIni,pDataFim,pTipo:String):Integer; StdCall;
    fFuncModoAutentica       : Function:Integer; StdCall;
    fFuncAutentica           : Function (pLegenda,pTexto:String):Integer; StdCall;
    fFuncCancAutentica       : Function:Integer; StdCall;
    fFuncAbreGaveta          : Function(pTipo, pTon, pToff: pChar):Integer; StdCall;
  public
    procedure MensagemProComp( iRetorno : Integer );
    function Abrir( sPorta:String; iHdlMain:Integer ):String; override;
    function LeituraX:String; override;
    function Fechar( sPorta:String ):String; override;
    function Status( Tipo:Integer; Texto:String ):String; override;
    function Retorno:String;
    function LeAliquotas:String; override;
    function LeAliquotasISS:String; override;
    function LeCondPag:String; override;
    function PegaPDV:String; override;
    function PegaCupom(Cancelamento:String):String; override;
    function ReducaoZ( MapaRes:String ):String; override;
    function StatusImp( Tipo:Integer ):String; override;
    function GravaCondPag( condicao:String ):String; override;
    function AdicionaAliquota( Aliquota:String; Tipo:Integer ): String; override;
    function AbreCupom(Cliente:String; MensagemRodape:String):String; override;
    function CancelaCupom( Supervisor:String ):String; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String; override;
    function DescontoTotal( vlrDesconto:String ;nTipoImp:Integer): String; override;
    function AcrescimoTotal( vlrAcrescimo:String ): String; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:String ): String; override;
    function FechaCupom( Mensagem:String ):String; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String; override;
    function TextoNaoFiscal( Texto:String;Vias:Integer ):String; override;
    function FechaCupomNaoFiscal: String; override;
    procedure AlimentaProperties; override;
    function TotalizadorNaoFiscal( Numero,Descricao:String ):String; override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:String  ): String; override;
    function Autenticacao( Vezes:Integer; Valor,Texto:String ): String; override;
    function AbreEcf:String; override;
    function PegaSerie:String; override;
    function Gaveta:String; override;
    function LeStatus( var S:String ): Integer;
    function ImpostosCupom(Texto: String): String; override;
    function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String; override;
    function RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer ) : String; Override;  
    function RecebNFis( Totalizador, Valor, Forma:String ): String; override;
    function FechaEcf:String; override;
    function DownloadMFD( sTipo, sInicio, sFinal : String ):String; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : String):String; override;
    function RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String) : String; override;
    function LeTotNFisc:String; override;
    function DownMF(sTipo, sInicio, sFinal : String):String; override;
    function RedZDado ( MapaRes : String):String ; override;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String; Override;
    function ImpTxtFis(Texto : String) : String; Override;
    function GrvQrCode(SavePath,QrCode: String): String; Override;
  end;
  
Function TrataTags( Mensagem : String ) : String;

implementation

//---------------------------------------------------------------------------
function TImpFiscalProComp.Abrir(sPorta : String; iHdlMain:Integer) : String;

  function ValidPointer( aPointer: Pointer; sMSg :String ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      ShowMessage('A função "'+sMsg+'" não existe na Dll: ECF3E32.DLL');
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
  fHandle := LoadLibrary( 'ECF3E32.DLL' );
  if (fHandle <> 0) Then
  begin
    bRet := True;
    aFunc := GetProcAddress(fHandle,'OPENCIF');
    if ValidPointer( aFunc, 'OPENCIF') then
      fFuncAbre := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CLOSECIF');
    if ValidPointer( aFunc, 'CLOSECIF' ) then
      fFuncFecha  := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ABRECUPOMFISCAL');
    if ValidPointer( aFunc, 'ABRECUPOMFISCAL' ) then
      fFuncAbreCupom := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'VENDAITEM');
    if ValidPointer( aFunc, 'VENDAITEM' ) then
      fFuncVendaItem := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CANCELAMENTOITEM');
    if ValidPointer( aFunc, 'CANCELAMENTOITEM' ) then
      fFuncCancItem  := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'TOTALIZARCUPOM');
    if ValidPointer( aFunc, 'TOTALIZARCUPOM' ) then
      fFuncTotalCupom := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'PAGAMENTO');
    if ValidPointer( aFunc, 'PAGAMENTO' ) then
      fFuncPagamento := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'FECHACUPOMFISCAL');
    if ValidPointer( aFunc, 'FECHACUPOMFISCAL' ) then
      fFuncFechaCupom := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CANCELACUPOMFISCAL');
    if ValidPointer( aFunc, 'CANCELACUPOMFISCAL' ) then
      fFuncCancelaCupom := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'LEITURAX');
    if ValidPointer( aFunc, 'LEITURAX' ) then
      fFuncLeituraX := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'REDUCAOZ');
    if ValidPointer( aFunc, 'REDUCAOZ' ) then
      fFuncReducaoZ := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'LEMEMFISCALDATA');
    if ValidPointer( aFunc, 'LEMEMFISCALDATA' ) then
      fFuncLerData := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'LEMEMFISCALREDUCAO');
    if ValidPointer( aFunc, 'LEMEMFISCALREDUCAO') then
      fFuncLerReducao := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ABRIRGAVETA');
    if ValidPointer( aFunc, 'ABRIRGAVETA') then
      fFuncAbreGaveta := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ABRECUPOMVINCULADO');
    if ValidPointer( aFunc, 'ABRECUPOMVINCULADO' ) then
      fFuncAbreNFVinculado := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ABRECUPOMNAOVINCULADO');
    if ValidPointer( aFunc, 'ABRECUPOMNAOVINCULADO' ) then
      fFuncAbreNFNVinculado := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'OPERREGNAOVINCULADO');
    if ValidPointer( aFunc, 'OPERREGNAOVINCULADO' ) then
      fFuncOperRegNaoVinculado:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ENCERRARCUPOM');
    if ValidPointer( aFunc, 'ENCERRARCUPOM' ) then
      fFuncEncerraNaoFiscal := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'IMPRIMELINHANAOFISCAL');
    if ValidPointer( aFunc, 'IMPRIMELINHANAOFISCAL' ) then
      fFuncImprimeNaoFiscal:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'TRANSSTATUS');
    if ValidPointer( aFunc, 'TRANSSTATUS' ) then
      fFuncTransStatus := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'OBTEMRETORNO');
    if ValidPointer( aFunc, 'OBTEMRETORNO' ) then
      fFuncObtemRetorno := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'ECFPARESP');
    if ValidPointer( aFunc, 'ECFPARESP' ) then
      fFuncLeRegistrador := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'TRANSTABALIQUOTAS');
    if ValidPointer( aFunc, 'TRANSTABALIQUOTAS' ) then
      fFuncLeAliquota := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'TRANSTOTCONT');
    if ValidPointer( aFunc, 'TRANSTOTCONT') then
      fFuncTransTot := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'TRANSDATAHORA');
    if ValidPointer( aFunc, 'TRANSDATAHORA') then
      fFuncTransDataHora:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'PROGRAMALEGENDA');
    if ValidPointer( aFunc, 'PROGRAMALEGENDA') then
      fFuncGravaForma:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'PROGALIQUOTAS');
    if ValidPointer( aFunc, 'PROGALIQUOTAS') then
      fFuncGravaAliq:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'DESCONTOITEM');
    if ValidPointer( aFunc, 'DESCONTOITEM') then
      fFuncDescontoItem:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'LEMEMFISCALDATA');
    if ValidPointer( aFunc, 'LEMEMFISCALDATA') then
      fFuncLeituraMFData := aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'MODOCHEQUEVALIDACAO');
    if ValidPointer( aFunc, 'MODOCHEQUEVALIDACAO') then
      fFuncModoAutentica:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'IMPRIMEVALIDACAO');
    if ValidPointer( aFunc, 'IMPRIMEVALIDACAO') then
      fFuncModoAutentica:= aFunc
    else
    begin
      bRet := False;
    end;

    aFunc := GetProcAddress(fHandle,'CANCELACHEQUEVALIDACAO');
    if ValidPointer( aFunc, 'CANCELACHEQUEVALIDACAO') then
      fFuncCancAutentica:= aFunc
    else
    begin
      bRet := False;
    end;

  end
  else
  begin
    ShowMessage('O arquivo ECF3E32.DLL não foi encontrado.');
    bRet := False;
  end;

  if bRet then
  begin
    result := '0|';
    iRet := fFuncAbre;
    if iRet <> 0 then
      bRet := False;
    if not bRet then
    begin
        MensagemProcomp( iRet );
        result := '1|';
      end
    Else
    begin
        AlimentaProperties;
        result := '0|';
    end;
  end
  else
    result := '1|';

end;
//---------------------------------------------------------------------------
function TImpFiscalProComp.Fechar( sPorta:String ) : String;
begin
  result := '0';
  FreeLibrary(fHandle);
  fHandle := 0;
end;

//---------------------------------------------------------------------------
function TImpFiscalProComp.ImpostosCupom(Texto: String): String;
begin
  Result := '0';
end;

//---------------------------------------------------------------------------
function TImpFiscalProComp.LeituraX : String;
var
  iRet : Integer;
  sPar : string;
begin
   sPar := '0';
   iRet:=fFuncLeituraX( PChar(sPar) );
   result := Status( 1, IntToStr(iRet) );
end;

//---------------------------------------------------------------------------
function TImpFiscalProComp.LeAliquotas:String;
var
  iRet : Integer;
  sPar : string;
  sRet : String;
begin
   sPar := '0';
   sRet := '';
   iRet :=fFuncLeAliquota;
   if iRet=0 then
     sPar:=Retorno;
     sPar:=Copy(sPar,10,length(sPar));
     While Trim(sPar)<>'' do
        begin
        if copy(sPar,1,4)<>'0000' then
          sRet:=sRet+copy(sPar,1,2)+'.'+copy(sPar,3,2)+'|';
        sPar:=copy(sPar,5,length(sPar));
        end;


   result := '0|'+sRet;
end;
//---------------------------------------------------------------------------
//Esta impressora não diferenia ICMS de ISS, logo as duas rotinas sao identicas.
function TImpFiscalProComp.LeAliquotasISS:String;
var
  iRet : Integer;
  sPar : string;
  sRet : String;
begin
   //Somente é possivel cadastrar ISS no primeiro registrador
   sPar := '0000';
   sRet := '';
   iRet :=fFuncLeAliquota;
   if iRet=0 then
     sPar:=Retorno;
     sPar:=Copy(sPar,6,4);
     sRet:=sRet+copy(sPar,1,2)+'.'+copy(sPar,3,2)+'|';

   result := '0|'+sRet;
end;

//---------------------------------------------------------------------------
function TImpFiscalProComp.LeCondPag:String;
Begin
   result := '0|' + FormasPgto;
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.PegaPDV:String;
var
  iRet : Integer;
  sRet    : String;

begin
 sRet:='48';
 iRet := fFuncLeRegistrador( PChar(sRet) );
 if iRet=0 then
   sRet:=Retorno
 else
   sRet:='';

 result := '0|'+Copy(sRet,6,11) ;
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.PegaCupom(Cancelamento:String):String;
var
  sRet  : String;
  iRet  : Integer;
begin
 sRet:='';
 iRet := fFuncTransTot;
 If iRet <> 0 then
   fFuncTransTot;
 sRet:=Copy(Retorno,12,6);
 result := '0|'+sRet ;
end;
//---------------------------------------------------------------------------
function TImpFiscalProComp.ReducaoZ( MapaRes:String ) : String;
var
  iRet : Integer;
  sRet    : String;

begin
  sRet:='0';
  iRet := fFuncReducaoZ(PChar(sRet)) ;
  result := Status( 1, IntToStr(iRet) );
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.GravaCondPag( condicao:String ):String;
var
  iRet : Integer;
  sPagto : String;
  iPos : Integer;
  i : Integer;
  sRet: string;
begin
  // Verifica as condicoes já existentes
  Condicao:=UpperCase(Trim(Condicao));
  iPos:=0;
  For i:=50 to 65 do
    begin
    iRet := fFuncLeRegistrador( PChar(IntToStr(i)) );
    if iRet=0 then
       Begin
       sRet:=Trim(Copy(Retorno,6,14));
       if ( sRet='') and (iPos=0) then
          iPos:=i-50;
       if sRet=Condicao then
          begin
          ShowMessage('Já existe a condição de pagamento ' + condicao );
          result := '4|';
          exit;
          end;
       end;
    end;
  if iPos=0 Then
     begin
     ShowMessage('Não há registro para cadastro de condição de pagamento ');
     result := '1|';
     exit;
     end
  else
     Begin
     sPagto:=FormataTexto(IntToStr(iPos),2,0,2);
     Condicao:=Copy(Condicao+space(16),1,16);
     iRet:=fFuncGravaForma( sPagto,Condicao);
     result := Status( 1, IntToStr(iRet) );
     end;
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.AdicionaAliquota( Aliquota:String; Tipo:Integer ): String;
var
  iRet : Integer;
  sPar : string;
  sRet : String;
  iPos,i :Integer;
begin
   Aliquota := FormataTexto(aliquota,4,2,2);
   sPar := '0';
   sRet := '';
   iRet :=fFuncLeAliquota;
   if iRet=0 then
     Begin
     sPar:=Retorno;
     sPar:=Copy(sPar,6,length(sPar));
     iPos:=99;
     i   :=0;
     While Trim(sPar)<>'' do
        begin
        if (copy(sPar,1,4)='0000') and (iPos=99) then
            if ((Tipo=1) and (i>0)) or ((Tipo=2) and (i=0))  then
               iPos:=i;
        if (copy(sPar,1,4)=Aliquota) then
           Begin
           ShowMessage('Aliquota já cadastrada');
           result := '4|';
           exit;
           end;
        sPar:=copy(sPar,5,length(sPar));
        inc(i);
        end;
     if iPos=99 then
        begin
        ShowMessage('Não há registro para cadastro de Aliquotas');
        result := '6|';
        exit;
        end
     else
        Begin
        sPar:=FormataTexto(IntToStr(iPos),2,0,2);
        iRet:=fFuncGravaAliq(sPar,Aliquota);
        result := Status( 1, IntToStr(iRet) );
        end;
    end
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.AbreCupom(Cliente:String; MensagemRodape:String):String;
var
  iRet : Integer;
begin
  iRet := fFuncAbreCupom;
  result := Status( 1,IntToStr(iRet) );
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.CancelaCupom( Supervisor:String ):String;
var
  iRet : Integer;
begin
  iRet := fFuncCancelaCupom;
  result := Status( 1,IntToStr(iRet) );
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:String; nTipoImp:Integer ): String;

Var sFormato,
    sTipoDesc,
    sUnidade,
    sTamDescr,
    sLegendaOp : String;
    iRet,i,iPos : Integer;
    sPar : string;
    sRet : String;
    sSituacao: String;
Begin

  if ( Trim(codigo+descricao)= '') and ( qtde='0.00') then
    begin
    if StrToFloat(vlrdesconto) <> 0 then
      begin
      vlrdesconto:= FormataTexto(vlrdesconto,15,2,2);
      sLegendaOp := 'Desconto      ';
      sTipoDesc  := '&';
      iRet := fFuncDescontoItem( PChar(sTipoDesc),
                                 PChar(vlrdesconto),
                                 PChar(sLegendaOp));

      result := Status( 1,IntToStr(iRet) );
      exit;
      end
    else
      result := '0';
    exit;
  end;

  // Verifica se é tipo F, N ou I. Nestes casos não há percentual
  if Pos(aliquota,'FNI') > 0 then
    aliquota := aliquota + '00';

  // Faz o tratamento da aliquota
  sSituacao := copy(aliquota,1,1);

  Aliquota  := Copy(Aliquota,2,5);
  Aliquota  := FormataTexto(aliquota,4,2,2);

  iPos:=99;
  sPar := '0';
  sRet := '';
  iRet :=fFuncLeAliquota;
  if iRet=0 then
    Begin
    sPar:=Retorno;
    sPar:=Copy(sPar,6,length(sPar));
    i:=0;
    While Trim(sPar)<>'' do
       begin
       if ( copy(sPar,1,4)=Aliquota) and (( (sSituacao='T') and (i>0) ) or ((sSituacao='S') and (i=0)))  then
          Begin
          sSituacao:='T';
          iPos:=i;
          Break;
          end;
       Inc(i);
       sPar:=copy(sPar,5,length(sPar));
       end;

    if ( iPos=99 ) and ( Pos(sSituacao,'TS')>0 ) then
       Begin
       ShowMessage('Aliquota não cadastrada');
       result := '1';
       exit;
       end;
    end;
    if ( iPos=99 ) and ( Pos(sSituacao,'FIN')>0) then
       iPos:=0;
  Aliquota:=sSituacao+FormataTexto(IntToStr(iPos),2,0,2);

  sFormato   := '0';
  Qtde       := FormataTexto(Qtde,6,3,2);
  vlrUnit    := FormataTexto(vlrUnit,11,2,2);
  vlrdesconto:= FormataTexto(vlrdesconto,15,2,2);
  Codigo     := Copy(Codigo+space(13),1,13);
  sTipoDesc  := '&';
  sUnidade   := '  ';
  sTamDescr  := '0';
  Descricao  := Copy(UpperCase(Descricao)+space(20),1,20);
  sLegendaOp := '              ';
  iRet:=fFuncVendaItem( PChar(sFormato),
                   PChar(Qtde),
                   PChar(vlrUnit),
                   PChar(Aliquota),
                   PChar(sTipoDesc),
                   PChar(vlrdesconto),
                   PChar(sUnidade),
                   PChar(Codigo),
                   PChar(sTamDescr),
                   PChar(Descricao),
                   PChar(sLegendaOp));
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:String ):String;
var
  iRet : Integer;
begin
  NumItem:=FormataTexto(NumItem,3,0,2);
  iRet := fFuncCancItem(PChar(NumItem));
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.DescontoTotal( vlrDesconto:String;nTipoImp:Integer ): String;
var
  iRet        : Integer;
  sOper       : String;
  sTipo       : String;
  sLegendaOp  : String;
begin
  sOper       :='';
  sTipo       :='&';
  sLegendaOp  := 'Desconto      ';
  vlrDesconto := FormataTexto(vlrDesconto,15,2,2);
  if StrToFloat(vlrDesconto) > 0 then
    begin
    iRet := fFuncTotalCupom( PChar(sOper),sTipo,vlrDesconto,sLegendaOp);
    result := Status( 1,IntToStr(iRet) );
    end
  else
    result := '0|';
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.AcrescimoTotal( vlrAcrescimo:String ): String;
var
  iRet        : Integer;
  sOper       : String;
  sTipo       : String;
  sLegendaOp  : String;
begin
  sOper       :='@';
  sTipo       :='&';
  sLegendaOp  := 'Acresimo      ';
  vlrAcrescimo:= FormataTexto(vlrAcrescimo,15,2,2);
  if StrToFloat(vlrAcrescimo) > 0 then
    begin
    iRet := fFuncTotalCupom( PChar(sOper),sTipo,vlrAcrescimo,sLegendaOp);
    result := Status( 1,IntToStr(iRet) );
    end
  else
    result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.Pagamento( Pagamento,Vinculado,Percepcion:String ): String;

Var
   sReg,  sSubtr : string;
   iRet,i,iPos: Integer;
   sForma,sValor: String;
   sRet: String;
   aForma : TaString;
   sTipo,
   sSequencia,
   sResult: String;
   aComando    : Array [0..0] Of Char;

begin
  sSubtr := '0';
  sRet := LeCondPag;
  sRet := Copy(sRet, 3, Length(sRet));
  MontaArray(sRet,aForma);
  // efetua a Totalização
  sTipo      := '';
  sSequencia := '&';
  sResult    := '              ';
  sValor     := '000000000000000';

  fFuncTotalCupom(StrPCopy(aComando,sTipo),
                            PChar(sSequencia),
                            PChar(sValor) ,
                            PChar(sResult) );
  // Colocado uma pausa para terminar a execução do comando anterior que é demorado.
  while Trim(Pagamento)<>'' do
      Begin
      //Pegando a Descrição
      iPos      := Pos('|',Pagamento);
      sForma    := Copy(Pagamento,1,iPos-1);
      Pagamento := Copy(Pagamento,iPos+1,Length(Pagamento));
      //Pegando o Valor
      iPos      := Pos('|',Pagamento);
      sValor    := Copy(Pagamento,1,iPos-1);
      Pagamento := Copy(pagamento,iPos+1,Length(Pagamento));
      iRet:=99;
      for i:= 0 to High(aForma) do
         If aForma[i]=sForma then
            Begin
            // A forma de pagamento pode ter índice 0 (zero).
            sReg   := FormataTexto(IntToStr( i ),2,0,2);
            sValor := FormataTexto(sValor,15,2,2);
            Sleep (2000);
            iRet   := fFuncPagamento(Pchar(sReg),Pchar(sValor),Pchar(sSubtr));
            break;
            end;
      if iRet=99 then
          Begin
          ShowMessage('Forma de pagamento não cadastrada '+sForma);
          Result:='1|';
          exit;
          end;
      end;
  //Verifica se tem Troco
  Sleep (2000);
  sRet:='97';
  iRet := fFuncLeRegistrador( PChar(sRet) );
  if iRet=0 then
    sRet:=Retorno
  else
    sRet:='';

  sRet:=Copy(sRet,6,15);
  if StrToInt(sRet)>0  then
     Begin
     // Efetua o troco
     Sleep (1000);
     sReg   :='01';
     sValor := '000000000000000';
     iRet   :=fFuncPagamento(Pchar(sReg),Pchar(sValor),Pchar(sSubtr));
     end;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.FechaCupom( Mensagem:String ):String;
Var
   sTamMsg,sMsg:string;
   iRet: Integer;
begin
   sMsg := Mensagem;
   sMsg := TrataTags( sMsg );
   sMsg := Trim(sMsg);
   If sMsg = '' then
      sMsg :='  ';
      
   sTamMsg  := IntToStr(length(sMsg));
   sTamMsg  := FormataTexto(sTamMsg,3,0,2);
   sTamMsg  := 'S'+sTamMsg;
      //Fecha o cupom fiscal
   iRet:=fFuncFechaCupom(Pchar(sTamMsg),Pchar(sMsg));
   result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.AbreCupomNaoFiscal( Condicao,Valor,Totalizador,Texto:String ): String;
var
  iRet        : Integer;
  i           : Integer;
  sPagto      : String;
  aPagto      : TaString;
  sPos        : String;
  sOper       : String;
  sTipo       : String;
  sLegendaOp  : String;
  sValorOp    : String;
  sSubtr      : String;
begin
  Totalizador:= FormataTexto(Totalizador,2,0,2);
  Valor      := FormataTexto(Valor,15,2,2);
  sOper       :='@';
  sTipo       :='%';
  sLegendaOp  := '              ';
  sValorOp     := '0000';
  sSubtr := '0';

  iRet := fFuncAbreNFVinculado;
  Result := Status( 1,IntToStr(iRet) );
  if Copy(Result,1,1)='1' then
     Begin
     // Faz a leitura das condicoes de pagamento
     sPagto := LeCondPag;
     MontaArray( copy(sPagto,2,Length(sPagto)), aPagto );
     sPos := '99';
     for i := 0 to length(aPagto)-1 do
       if UpperCase(Trim(aPagto[i])) = UpperCase(Trim(Condicao)) then
          sPos := IntToStr(i);

     sPos := FormataTexto(sPos,2,0,2);
     if sPos <> '99' then
        Begin
        // Abre Cupom Nao Fiscal Não Vinculado
        fFuncAbreNFNVinculado;
        sleep(2000);
        // Registra Valor no Totalizado Cupom Nao Fiscal Não Vinculado
        fFuncOperRegNaoVinculado(Totalizador,Valor,Pchar(sOper),Pchar(sTipo),sValorOp,sLegendaOp);
        sleep(2000);
        // Efetua o pagemanto do Cupom Nao Fiscal Nao Vinculado.
        fFuncPagamento(Pchar(sPos),Pchar(Valor),Pchar(sSubtr));
        sleep(2000);
        // Fecha Cupom Nao Fiscal Nao Vinculado.
        fFuncEncerraNaoFiscal;
        sleep(2000);
        // Abre um Cupom Nao Fiscal Vinculado ao Cupom Nao Fiscal Nao Vinculado ao anterior
        iRet := fFuncAbreNFVinculado;
        Result := Status( 1,IntToStr(iRet) );
        end
     else
        begin
        ShowMessage('Não existe a condição de pagamento informada.');
        result := '1|';
        end;
     end;
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.TextoNaoFiscal( Texto:String;Vias:Integer ):String;
var
  iRet   : Integer;
  sLinha : String;
  i      : Integer;
  sTipo  : String;

begin
  // faz a checagem do texto.
  sTipo  :='0';
  iRet   := 0;
  i      :=1;
  sLinha := '';
  while i <= Length(Texto) do
  begin
    if (copy(Texto,i,1) = #10) or (Length(sLinha)>=48) then
    begin
      Sleep(1000);
      sLinha:=Copy(sLinha+space(48),1,48);
      iRet := fFuncImprimeNaoFiscal( PChar(sTipo),sLinha );
      sLinha := '';
    end
    else
      sLinha := sLinha + copy(Texto,i,1);
    Inc(i);
  end;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.FechaCupomNaoFiscal: String;
var
  iRet : Integer;
begin
  iRet := fFuncEncerraNaoFiscal;
  result := Status( 1,IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
procedure TImpFiscalProComp.AlimentaProperties;
Var
  sRet                      : String;
  i,iRet  : Integer;
  sAliq   : String;
begin
  sAliq := '';
  For i:=50 to 65 do
     Begin
     iRet := fFuncLeRegistrador( PChar(IntToStr(i)) );
     if iRet=0 then
        Begin
        sRet:=Trim(Copy(Retorno,6,14));
        if sRet<>'' then
           sAliq:=sAliq+sRet+'|'
        Else
           sAliq:=sAliq + ' |';
        end;
     End;
  FormasPgto:= sAliq;
End;

//---------------------------------------------------------------------------
function TImpFiscalProComp.TotalizadorNaoFiscal( Numero,Descricao:String ):String;
var
  iRet : Integer;
begin
  if ( StrToInt(Numero) < 16 ) and ( StrToInt(Numero) > 31 ) then
     Begin
     ShowMessage('Utilize os registradores de 66 à 81');
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
  Descricao:=Copy(Descricao+space(16),1,16);

  iRet:=fFuncGravaForma( Numero,Descricao);
  result := Status( 1, IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.MemoriaFiscal( DataInicio,DataFim:TDateTime ;ReducInicio,ReducFim,Tipo:String ): String;
var
  iRet : Integer;
  sTipo: String;
begin
  sTipo:='0';
  iRet := fFuncLeituraMFData( FormataData(DataInicio,1), FormataData(DataFim,1),sTipo );
  result := status( 1,IntToStr(iRet) );
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.Autenticacao( Vezes:Integer; Valor,Texto:String ): String;
var
  iRet : Integer;
  i : Integer;
  //sTipo,sLocal,sPos:String;
begin
  Texto:=Trim(Texto);
  if Texto<>'' then
     Texto:=Copy(Texto+space(48),1,48);

  iRet:=fFuncModoAutentica;
  result := Status( 1,IntToStr(iRet) );
  For i:=1 to Vezes do
    begin
    ShowMessage('Posicione o Documento para Autenticação.');
    iRet := fFuncAutentica('     ',Texto);
    result := Status( 1,IntToStr(iRet) );
    end;
//  result := Status( 1,IntToStr(iRet) );
  if Copy(result,1,1)='1' then
     fFuncCancAutentica;
end;
//----------------------------------------------------------------------------
function TImpFiscalProComp.AbreEcf:String;
begin
  result := '0|';
End;

//----------------------------------------------------------------------------
function TImpFiscalProComp.StatusImp( Tipo:Integer ):String;
var
  iRet     : Integer;
  sRet     : String;
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

// Faz a leitura da Hora
if Tipo = 1 then
begin
  iRet := fFuncTransDataHora;
  if iRet=0 then
     sRet:=Retorno
  else
     sRet:='';

 result := '0|'+Copy(sRet,15,8) ;
end
// Faz a leitura da Data
else if Tipo = 2 then
begin
  iRet := fFuncTransDataHora;
  if iRet=0 then
     sRet:=Retorno
  else
     sRet:='';

 result := '0|'+Copy(sRet,6,8) ;
end
// Faz a checagem de papel
else if Tipo = 3 then
begin
  iRet := LeStatus( sRet );
  if iRet = 0 then
    if sRet[23] = '1' then
      sRet := '7|'
    else
      sRet := '0|'
  else
    sRet := '1|';

  Result := sRet;
end
//Verifica se é possível cancelar um ou todos os itens.
else if Tipo = 4 then
  result := '0|TODOS'
//5 - Cupom Fechado ?
else if Tipo = 5 then
Begin
  iRet := LeStatus( sRet );
  if iRet = 0 then
    if sRet[1] = '1' then
      sRet := '7|'
    else
      sRet := '0|'
  else
    sRet := '1|';

  Result := sRet;
end
//6 - Ret. suprimento da impressora
else if Tipo = 6 then
  result := '0|0.00'
//7 - ECF permite desconto por item
else if Tipo = 7 then
  result := '0'
//8 - Verica se o dia anterior foi fechado
else if Tipo = 8 then
Begin
  iRet := LeStatus( sRet );
  if iRet = 0 then
    if sRet[6] = '1' then
      sRet := '10|'
    else
      sRet := '0|'
  else
    sRet := '1|';

  Result := sRet;
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
function TImpFiscalProComp.Status( Tipo:Integer; Texto:String ):String;
  // Parametros
  // 1- Verifica se o ultimo comando foi executado
  // 2- Verifica a existencia de papel ( se tem ou não )
  // 3- Verifica o status do papel ( se está no fim ou não )
var
  bErro              : Boolean;
  ptRetorno          : Pointer;
  lRetornou          : Boolean;
  dtHoraInicio       : TDateTime;
  iTimeOut,iRetorno  : Integer;
  sRet               : String;
begin
  bErro := False;
  case Tipo of
    1 : if Texto = '0' then
        Begin
          sRet         :='';
          ptRetorno    := AllocMem(255);
          lRetornou    := False;
          dtHoraInicio := Now;
          iTimeOut     := 60000;
          while not lRetornou do
          begin
            iRetorno := fFuncObtemRetorno( ptRetorno );
            if (iRetorno = 0) then
            Begin
              if Pos('COMANDO OK',StrPas(ptRetorno))<> 0 Then
                bErro := False
              else
                sRet:=Copy(StrPas(ptRetorno),10,length(StrPas(ptRetorno)));

              lRetornou := True;
            end
            else if (iRetorno > 0) or (iRetorno <> -26) then
            begin
              MensagemProComp(iRetorno);
              bErro := True;
              lRetornou := True;
            end;
            // Ultrapassou o time-out de retorno da impressora
            if (Now > (dtHoraInicio + iTimeOut * (1/24/60/60/1000))) then
            begin
              MessageDlg( 'Erro de comunicação com a impressora fiscal ProComp !', mtError, [mbOk], 0);
              bErro := True;
              break;
            end;
            Sleep (100);
          end;
          FreeMem( ptRetorno );
        end
        else
          bErro := False;
  end;

  If bErro then
    result := '1|'
  else
    result := '0|'+sRet;
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.Gaveta:String;
var
  iRet : Integer;
begin
  iRet := fFuncAbreGaveta('0','5','5');
  result := Status( 1, IntToStr(iRet) );
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.Retorno:String;
var
  ptRetorno          : Pointer;
  lRetornou          : Boolean;
  dtHoraInicio       : TDateTime;
  iTimeOut,iRetorno  : Integer;
  sRet               : String;
begin
  sRet         :='';
  ptRetorno    := AllocMem(512);
  lRetornou    := False;
  dtHoraInicio := Now;
  iTimeOut     := 60000;
  while not lRetornou do
     begin
     iRetorno := fFuncObtemRetorno( ptRetorno );
     if (iRetorno = 0) then
        Begin
        sRet:=StrPas(ptRetorno);
        lRetornou:=True;
        end;
     // Ultrapassou o time-out de retorno da impressora
     if (Now > (dtHoraInicio + iTimeOut * (1/24/60/60/1000))) then
        begin
        MessageDlg( 'Erro de comunicação com a impressora fiscal ProComp !', mtError, [mbOk], 0);
        break;
        end;
     Sleep (100);
  end;

  FreeMem( ptRetorno );

  Result:=sRet;
end;
//----------------------------------------------------------------------------
procedure TImpFiscalProComp.MensagemProComp(iRetorno: Integer);
Var sMensagem : String;
begin
   sMensagem:='';
   if iRetorno = -1 then
      sMensagem := 'Erro genérico na execução da função. Perda de comunicação com a impressora.'
   else if iRetorno = -3  then
      sMensagem := 'Leitura assincrona em andamento. Comando sendo executado.'
   else if iRetorno = -4  then
      sMensagem := 'TimeOut na execucao do comando.'
   else if iRetorno = -5  then
      sMensagem := 'Tamanho da mensagem enviada pela impressora é maior que o buffer de recepção fornecido pela aplicação.'
   else if iRetorno = -7  then
      sMensagem := 'Erro no arquivo de configuração CIF.INI.'
   else if iRetorno = -8  then
      sMensagem := 'Falha na abertura da serial.'
   else if iRetorno = -11 then
      sMensagem := 'Tampa aberta.'
   else if iRetorno = -12 then
      sMensagem := 'Erro mecânico.'
   else if iRetorno = -13 then
      sMensagem := 'Erro irrecuperavel.'
   else if iRetorno = -14 then
      sMensagem := 'Temperatura da cabeça de impressão está alta.'
   else if iRetorno = -15 then
      sMensagem := 'Pouco papel.'
   else if iRetorno = -16 then
      sMensagem := 'Em inicio de cupom de venda.'
   else if iRetorno = -17 then
      sMensagem := 'Em venda de item.'
   else if iRetorno = -18 then
      sMensagem := 'Em cancelamento de item.'
   else if iRetorno = -19 then
      sMensagem := 'Em cancelamento de cupom.'
   else if iRetorno = -20 then
      sMensagem := 'Em fechamento de cupom.'
   else if iRetorno = -21 then
      sMensagem := 'Em Reducao Z.'
   else if iRetorno = -22 then
      sMensagem := 'Em Leitura X.'
   else if iRetorno = -23 then
      sMensagem := 'Em leitura de memória fiscal.'
   else if iRetorno = -24 then
      sMensagem := 'Em totalização.'
   else if iRetorno = -25 then
      sMensagem := 'Em pagamento.'
   else if iRetorno = -26 then
      sMensagem := 'Ainda não obteve retorno.'
   else if iRetorno = 1 then
      sMensagem := 'O cabeçalho contém caracteres inválidos.'
   else if iRetorno = 2 then
      sMensagem := 'Comando inexistente.'
   else if iRetorno = 3 then
      sMensagem := 'Valor não numérico em campo numérico.'
   else if iRetorno = 4 then
      sMensagem := 'Valor fora da faixa entre 20h e 7Fh.'
   else if iRetorno = 5 then
      sMensagem := 'Campo de iniciar com @, & ou %.'
   else if iRetorno = 6 then
      sMensagem := 'Campo de iniciar com $, # ou ?.'
   else if iRetorno = 7 then
      sMensagem := 'O intervalo é inconsistente. O primeiro deve menor que o segundo.'
   else if iRetorno = 8 then
      sMensagem := 'Tributo inválido.'
   else if iRetorno = 9 then
      sMensagem := 'A string TOTAL não é aceita.'
   else if iRetorno = 10 then
      sMensagem := 'A sintaxe do comando está errada.'
   else if iRetorno = 11 then
      sMensagem := 'Excedeu o número máximo de linhas permitidas pelo comando.'
   else if iRetorno = 12 then
      sMensagem := 'O terminador enviado não obedece o protocolo de comunicação.'
   else if iRetorno = 13 then
      sMensagem := 'O checksum enviado está incorreto.'
   else if iRetorno = 15 then
      sMensagem := 'A situação tributária deve iniciar com T, F ou N.'
   else if iRetorno = 16 then
      sMensagem := 'Data inválida.'
   else if iRetorno = 17 then
      sMensagem := 'Hora inválida.'
   else if iRetorno = 18 then
      sMensagem := 'Aliquota não programada ou fora do intervalo.'
   else if iRetorno = 19 then
      sMensagem := 'O campo de sinal está incorreto.'
   else if iRetorno = 20 then
      sMensagem := 'Comando só aceito em intervenção fiscal.'
   else if iRetorno = 21 then
      sMensagem := 'Comando só aceito em modo normal.'
   else if iRetorno = 22 then
      sMensagem := 'Necessário abrir cupom fiscal.'
   {else if iRetorno = 23 then
      sMensagem := 'Comando não aceito durante cupom fiscal.'}
   else if iRetorno = 24 then
      sMensagem := 'Necessário abrir cupom não fiscal.'
{   else if iRetorno = 25 then
      sMensagem := 'Comando não aceito durante cupom não fiscal.'}
   else if iRetorno = 26 then
      sMensagem := 'O relógio está em horário de verão.'
   else if iRetorno = 27 then
      sMensagem := 'O relógio não está em horário de verão.'
   else if iRetorno = 28 then
      sMensagem := 'Necessário realizar redução Z.'
   else if iRetorno = 29 then
      sMensagem := 'Fechamento do dia (Redução Z) já executado.'
   else if iRetorno = 30 then
      sMensagem := 'Necessário programar legenda.'
   else if iRetorno = 31 then
      sMensagem := 'Item inexistente ou já cancelado.'
   else if iRetorno = 32 then
      sMensagem := 'O cupom anterior não pode ser cancelado.'
   else if iRetorno = 33 then
      sMensagem := 'Detectado falta de papel.'
   else if iRetorno = 36 then
      sMensagem := 'Necessário programar os dados do estabelecimento.'
   else if iRetorno = 37 then
      sMensagem := 'Necessário realizar intervenção técnica.'
   else if iRetorno = 38 then
      sMensagem := 'A memória fiscal não permite mais realizar vendas.'
   else if iRetorno = 39 then
      sMensagem := 'Ocorreu algum problema na memória fiscal.'
   else if iRetorno = 40 then
      sMensagem := 'Necessário programar a data do relógio.'
   else if iRetorno = 41 then
      sMensagem := 'Número máximo de ítens por cupom ultrapassado.'
   else if iRetorno = 42 then
      sMensagem := 'Já foi realizado o ajuste de hora diário.'
   else if iRetorno = 43 then
      sMensagem := 'Comando válido ainda em execução.'
   else if iRetorno = 44 then
      sMensagem := 'Está em estado de impressão de cheque.'
   else if iRetorno = 45 then
      sMensagem := 'Não está em estado de impressão de cheque.'
   else if iRetorno = 46 then
      sMensagem := 'Necessário inserir o cheque.'
   else if iRetorno = 47 then
      sMensagem := 'Necessário inserir nova bobina.'
   else if iRetorno = 48 then
      sMensagem := 'Necessário executar leitura X.'
   else if iRetorno = 49 then
      sMensagem := 'Detectado algum problema na impressora.'
   else if iRetorno = 50 then
      sMensagem := 'Cupom já foi totalizado.'
   else if iRetorno = 51 then
      sMensagem := 'Necessário totalizar cupom antes de fechar.'
   else if iRetorno = 52 then
      sMensagem := 'Necessário finalizar cupom com comando correto.'
   else if iRetorno = 53 then
      sMensagem := 'Ocorreu erro de gravação na memória fiscal.'
   else if iRetorno = 54 then
      sMensagem := 'Excedeu número máximo de estabelecimentos.'
   else if iRetorno = 55 then
      sMensagem := 'Memória fiscal não inicializada completamente.'
   else if iRetorno = 56 then
      sMensagem := 'Ultrapassou valor do pagamento.'
   else if iRetorno = 57 then
      sMensagem := 'Registrador não programado ou troco já realizado.'
   else if iRetorno = 58 then
      sMensagem := 'Falta completar valor do pagamento.'
   else if iRetorno = 59 then
      sMensagem := 'Campo somente de caracteres não numéricos.'
   else if iRetorno = 60 then
      sMensagem := 'Excedeu campo máximo de caracteres.'
   else if iRetorno = 61 then
      sMensagem := 'Troco não realizado.';
{   else if iRetorno = 62 then
      sMensagem := 'Comando desabilitado.'}
//   else
//      sMensagem := 'Erro da impressora fiscal. Retorno desconhecido : '+IntToStr(iRetorno);

   if Trim(sMensagem)<>'' then
      ShowMessage(sMensagem);
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.PegaSerie : String;
begin
    result := '1|Funcao nao disponivel';
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.LeStatus( var S:String ): Integer;
var
  ptBuffer  : Pointer;
  iBitTeste : Byte;
  iRet      : Integer;
begin
  { A função fFuncTransStatus só retorna algum valor quando a diretiva Optimization
    do projeto está ligada. Quer dizer, este trecho de código só funciona com
    optimização. O IFOPT abaixo verifica se está usando Optimização, caso contrário,
    seta-a neste trecho de código.
    Cesar - 5/10/01
  }
  {$IFOPT O-}
    {$OPTIMIZATION ON}
  {$ENDIF}

  ptBuffer  := AllocMem(40);
  iBitTeste := 0;
  iRet := fFuncTransStatus(iBitTeste,ptBuffer);
  if iRet = 0 then
    S := StrPas(ptBuffer);

  FreeMem(ptBuffer);

  Result := iRet;

  { Voltando a Optimização do jeito que estava... }
  {$IFOPT O-}
    {$OPTIMIZATION OFF}
  {$ENDIF}
end;

//-----------------------------------------------------------
function TImpFiscalProComp.Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:String ): String;
begin
  Result:='0';
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.RelGerInd( cIndTotalizador , cTextoImp : String ; nVias : Integer ; ImgQrCode: String) : String;
begin
  Result := RelatorioGerencial(cTextoImp , nVias , ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.RelatorioGerencial( Texto:String ;Vias:Integer; ImgQrCode: String):String;
var iRet : Integer;
    sRet : String;
begin
  iRet := fFuncEncerraNaoFiscal;
  Result := '1';
  iRet   := fFuncLeituraX('1');
  sRet   := Copy(Status( 1, IntToStr(iRet) ),1,1);
  If sRet = '0' then
  begin
    sRet :=  TextoNaoFiscal( Texto, Vias );
    sRet   := Copy(sRet,1,1);
    If sRet = '0' then
    Begin
      Sleep( 2000 );
      Result := FechaCupomNaoFiscal;
    End;
  End;
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : String ; Vias : Integer):String;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.RecebNFis( Totalizador, Valor, Forma:String ): String;
begin
  ShowMessage('Função não disponível para este equipamento' );
  result := '1';
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.FechaEcf:String;
begin
  result := ReducaoZ('N');
end;

//------------------------------------------------------------------------------
function TImpFiscalProComp.DownloadMFD( sTipo, sInicio, sFinal : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalProComp.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : String ):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalProComp.LeTotNFisc:String;
Begin
  Result := '0|-99' ;
End;

//------------------------------------------------------------------------------
function TImpFiscalProComp.DownMF(sTipo, sInicio, sFinal : String):String;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpFiscalProComp.RedZDado( MapaRes : String): String ;
Begin
  Result := '1';
End;

//----------------------------------------------------------------------------
function TImpFiscalProComp.IdCliente( cCPFCNPJ , cCliente , cEndereco : String ): String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpFiscalProComp.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : String ) : String;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpFiscalProComp.ImpTxtFis(Texto : String) : String;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0|';
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
function TImpFiscalProComp.GrvQrCode(SavePath, QrCode: String): String;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

initialization
  RegistraImpressora('PROCOMP V2.1'   , TImpFiscalProComp, 'BRA', ' ');
//----------------------------------------------------------------------------
end.

