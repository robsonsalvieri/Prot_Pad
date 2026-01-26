unit ImpFiscSchalter;

interface

uses
  Dialogs, ImpFiscMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms;

Type

////////////////////////////////////////////////////////////////////////////////
///  Impressora Fiscal Schalter ECF IF SCFI IE V3.03
///
  TImpSchalter = class(TImpressoraFiscal)
  private
  public
    function Abrir( sPorta:AnsiString; iHdlMain:Integer ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function LeituraX:AnsiString; override;
    function PegaCupom(Cancelamento:AnsiString):AnsiString; override; {VERIFICAR SE TA FUNCIONANDO LEGAL}
    function PegaPDV:AnsiString; override;
    function AbreEcf:AnsiString; override;

    function AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString):AnsiString; override;
    function CancelaCupom(Supervisor:AnsiString):AnsiString; override;
    function CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString; override;
    function RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString; override;
    function DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString; override;
    function AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString; override;
    function Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString; override;
    function FechaCupom( Mensagem:AnsiString ):AnsiString; override;
    function FechaEcf:AnsiString; override;
    function Gaveta:AnsiString; override;
    function Suprimento( Tipo:Integer; Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString; override;
    function AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:AnsiString ): AnsiString; override;
    function TextoNaoFiscal( Texto:AnsiString; Vias:Integer ):AnsiString; override;
    function FechaCupomNaoFiscal: AnsiString; override;
    function TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString; override;
    function ReducaoZ(MapaRes:AnsiString):AnsiString; override;
    function PegaSerie:AnsiString; override;
    function LeCondPag:AnsiString; override;
    function LeAliquotasISS:AnsiString; override;
    function LeAliquotas:AnsiString; override;
    function RelatorioGerencial( Texto:AnsiString ;Vias:Integer; ImgQrCode: AnsiString):AnsiString; override;
    function ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer ) : AnsiString; Override;
    function MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString ): AnsiString; override;

    function ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString; override;
    function RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString; override;
    function AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString; override;
    function GravaCondPag( Condicao:AnsiString ):AnsiString; override;
    function StatusImp( Tipo:Integer ):AnsiString; override;
    procedure AlimentaProperties; override;
    function ImpostosCupom(Texto: AnsiString): AnsiString; override;  //só compatibilização
    function Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString; override;
    function HorarioVerao( Tipo:AnsiString ):AnsiString; override;

    function DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString; override;
    function GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario  : AnsiString  ):AnsiString; override;
    function RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString; override;
    function LeTotNFisc:AnsiString; override;
    function DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString; override;
    function RedZDado( MapaRes : AnsiString ):AnsiString;
    function IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString; Override;
    function EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString; Override;
    {
        --  function Pedido( Totalizador, Tef, Texto, Valor, CondPagTef:AnsiString ): AnsiString; override;
    }
    function ImpTxtFis(Texto : AnsiString) : AnsiString; Override;
    function GrvQrCode(SavePath,QrCode: AnsiString): AnsiString; Override;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Procedures e Functions
///
Function OpenSchalter( sPorta:AnsiString ):AnsiString;
Function CloseSchalter : AnsiString;
Function ImpCabec : AnsiString;
function CancelaCF( Supervisor:AnsiString ):AnsiString;
Function ImpCabecNF : AnsiString;
function AchaPagto( sForma:AnsiString;aFormas:TaString ):AnsiString;
Function StatusSchalter( ) : LPSTR;
Function TrataTags( Mensagem : AnsiString ) : AnsiString;

//----------------------------------------------------------------------------
implementation

var
  fHandle : THandle;

  fFuncChangePort                 : function (choose  : Integer): Integer; StdCall;
  fFuncEcfCancDoc                 : function (operador: LPSTR): Integer; StdCall;
  fFuncEcfFimTrans                : function (operador: LPSTR): Integer; StdCall;
  fFuncEcfFimTransVinc            : function (operador: LPSTR; vincvias: LPSTR): integer;stdcall;
  fFuncEcfCancVenda               : function (operador: LPSTR): Integer; StdCall;
  fFuncEcfLeituraX                : function (operador: LPSTR): Integer; StdCall;
  fFuncEcfReducaoZ                : function (operador: LPSTR): Integer; StdCall;
  fFuncEcfLXGerencial             : function (operador: LPSTR): Integer; StdCall;
  fFuncEcfRZGerencial             : function (operador: LPSTR): Integer; StdCall;
  fFuncEcfAutentica               : function (operador: LPSTR): Integer; StdCall;
  fFuncEcfImpLinha                : function (szLinha: LPSTR): Integer; StdCall;
  fFuncEcfLineFeed                : function (byEst: Integer; wLin: Integer): Integer; StdCall;
  fFuncEcfAbreGaveta              : function (): Integer; StdCall;

  fFuncEcfImpCab                  : function (byEst: Integer): Integer; StdCall;
  fFuncEcfInicCupomNFiscal        : function (tipo: Integer): Integer; StdCall;
  fFuncEcfInicCNFVinculado        : function (order: LPSTR; postab: LPSTR; valor: LPSTR): Integer; StdCall;
  fFuncEcfVendaItem               : function (szDescr: LPSTR; szValor: LPSTR; byTaxa: Integer): Integer; StdCall;
  fFuncEcfVendaItem78             : function (szDescr: LPSTR; szValor: LPSTR; byTaxa: Integer): Integer; StdCall;
  fFuncEcfVenda_Item              : function (szCodigo: LPSTR; szDescricao: LPSTR; szQInteira: LPSTR; szQFracionada: LPSTR; szValor: LPSTR; byTaxa: Integer): Integer; StdCall;
  fFuncEcfVendaItem3d             : function (szCodigo: LPSTR; szDescricao: LPSTR; szQuantidade: LPSTR; szValor: LPSTR; byTaxa: Integer; szUnidade: LPSTR; szDigitos: LPSTR ) : Integer; StdCall;
  fFuncEcfDescItem                : function (byTipo: Integer; szDescr: LPSTR; szValor: LPSTR) : Integer; StdCall;
  fFuncEcfCancItem                : function (szDescr: LPSTR) : Integer; StdCall;

  fFuncEcfPagamento               : function (byTipo: Integer; szPosTable: LPSTR; szValor: LPSTR; byLmens: Integer) : Integer; StdCall;
  fFuncEcfSubTotal                : function ( ) : Integer; StdCall;
  fFuncEcfCancAcresDescSubTotal   : function (byAcres: Integer; byTipo: Integer; szDescr: LPSTR; szValor: LPSTR) : Integer; StdCall;
  fFuncEcfPagTransfer             : function (pagOUT: LPSTR; pagIN: LPSTR; Value: LPSTR) : Integer; StdCall;

  fFuncEcfLeituraXSerial          : function ( ) : PChar; StdCall;
  fFuncEcfLeitMemFisc             : function (byTipo: Integer; szDi: LPSTR; szDf: LPSTR; wRi: Integer; wRf: Integer; archive: LPSTR ) : Integer; StdCall;

  fFuncEcfStatusImp               : function  ( ) : PChar; StdCall;
  fFuncEcfStatusCupom             : function  (flag_geral: Integer ) : PChar; StdCall;
  fFuncEcfStatusAliquotas         : function  (postab: Integer ) : PChar; StdCall;
  fFuncEcfStatusPayTypes          : function  (postab: Integer ) : PChar; StdCall;
  fFuncEcfStatusDocsNFs           : function  (postab: Integer ) : PChar; StdCall;
  fFuncEcfStatusEquipo            : function  ( ) : PChar; StdCall;
  fFuncEcfStatusUser              : function  (userposition: Integer) : PChar; StdCall;
  fFuncEcfStatusVincs             : function  (postab: Integer) : PChar; StdCall;
  fFuncEcfStatusTroco             : function  ( )  : PChar; StdCall;

  fFuncEcfAcertaData              : function  (dia: Integer; mes: Integer; ano: Integer; hor: Integer; min: Integer; seg: Integer ) : Integer; StdCall;
  fFuncEcfCargaAliqSelect         : function  (byPosTab: LPSTR; szTipo: LPSTR; szAliquota: LPSTR) : Integer; StdCall;
  fFuncEcfProgHeader30            : function  (szL1: LPSTR; szL2: LPSTR; szL3: LPSTR; wLj: Integer; wEq: Integer; szCGC: LPSTR; szIE: LPSTR; szIM: LPSTR): Integer; StdCall;
  fFuncEcfCargaCodCripto          : function  (parametric: Integer) : Integer; StdCall;
  fFuncEcfPrgCod                  : function  (byTAM: Integer) : Integer; StdCall;
  fFuncEcfPayPatterns             : function  (szPosTab: LPSTR; szValor: LPSTR): Integer; StdCall;
  fFuncEcfProgNFComprov           : function  (szPosTab: LPSTR; szTitulo: LPSTR; szDesconto: LPSTR; szAcres: LPSTR; szCancel: LPSTR; szComPag: LPSTR; szVinculado: LPSTR; szVinculo: LPSTR): Integer; StdCall;
  fFuncEcfCancItemDef             : function  (szItem : LPSTR; szDescr:LPSTR ): integer;stdcall;


//----------------------------------------------------------------------------
function TImpSchalter.Abrir(sPorta : AnsiString; iHdlMain:Integer) : AnsiString;
begin
    Result := OpenSchalter( sPorta );
    if Copy(Result,1,1) = '0' then
      AlimentaProperties;
end;

//----------------------------------------------------------------------------
Function OpenSchalter( sPorta:AnsiString ):AnsiString;
  function ValidPointer( aPointer: Pointer; sMSg :AnsiString ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      LjMsgDlg('A função "'+sMsg+'" não existe na Dll: ' + 'DLL32PHI.dll');
      Result := False;
    end
    else
      Result := True;
  end;
var
  bRet  : Boolean;
  aFunc : Pointer;
  iRet  : Integer;
  iPorta: Integer;
Begin
    Result := '0|';
    fHandle := LoadLibrary( 'DLL32PHI.dll' );

    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'ChangePort');
      if ValidPointer( aFunc, 'ChangePort' ) then
        fFuncChangePort := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfCancDoc');
      if ValidPointer( aFunc, 'ecfCancDoc' ) then
        fFuncEcfCancDoc := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfFimTrans');
      if ValidPointer( aFunc, 'ecfFimTrans' ) then
        fFuncEcfFimTrans := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfFimTransVinc');
      if ValidPointer( aFunc, 'ecfFimTransVinc' ) then
        fFuncEcfFimTransVinc := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfCancVenda');
      if ValidPointer( aFunc, 'ecfCancVenda' ) then
        fFuncEcfCancVenda := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfLeituraX');
      if ValidPointer( aFunc, 'ecfLeituraX' ) then
        fFuncEcfLeituraX := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfReducaoZ');
      if ValidPointer( aFunc, 'ecfReducaoZ' ) then
        fFuncEcfReducaoZ := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfLXGerencial');
      if ValidPointer( aFunc, 'ecfLXGerencial' ) then
        fFuncEcfLXGerencial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfRZGerencial');
      if ValidPointer( aFunc, 'ecfRZGerencial' ) then
        fFuncEcfRZGerencial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfAutentica');
      if ValidPointer( aFunc, 'ecfAutentica' ) then
        fFuncEcfAutentica := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfImpLinha');
      if ValidPointer( aFunc, 'ecfImpLinha' ) then
        fFuncEcfImpLinha := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfLineFeed');
      if ValidPointer( aFunc, 'ecfLineFeed' ) then
        fFuncEcfLineFeed := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfAbreGaveta');
      if ValidPointer( aFunc, 'ecfAbreGaveta' ) then
        fFuncEcfAbreGaveta := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfImpCab');
      if ValidPointer( aFunc, 'ecfImpCab' ) then
        fFuncEcfImpCab := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfInicCupomNFiscal');
      if ValidPointer( aFunc, 'ecfInicCupomNFiscal' ) then
        fFuncEcfInicCupomNFiscal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfInicCNFVinculado');
      if ValidPointer( aFunc, 'ecfInicCNFVinculado' ) then
        fFuncEcfInicCNFVinculado := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfVendaItem');
      if ValidPointer( aFunc, 'ecfVendaItem' ) then
        fFuncEcfVendaItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfVendaItem78');
      if ValidPointer( aFunc, 'ecfVendaItem78' ) then
        fFuncEcfVendaItem78 := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfVenda_Item');
      if ValidPointer( aFunc, 'ecfVenda_Item' ) then
        fFuncEcfVenda_Item := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfVendaItem3d');
      if ValidPointer( aFunc, 'ecfVendaItem3d' ) then
        fFuncEcfVendaItem3d := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfDescItem');
      if ValidPointer( aFunc, 'ecfDescItem' ) then
        fFuncEcfDescItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfCancItem');
      if ValidPointer( aFunc, 'ecfCancItem' ) then
        fFuncEcfCancItem := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfPagamento');
      if ValidPointer( aFunc, 'ecfPagamento' ) then
        fFuncEcfPagamento := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfSubTotal');
      if ValidPointer( aFunc, 'ecfSubTotal' ) then
        fFuncEcfSubTotal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfCancAcresDescSubTotal');
      if ValidPointer( aFunc, 'ecfCancAcresDescSubTotal' ) then
        fFuncEcfCancAcresDescSubTotal := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfPagTransfer');
      if ValidPointer( aFunc, 'ecfPagTransfer' ) then
        fFuncEcfPagTransfer := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfLeituraXSerial');
      if ValidPointer( aFunc, 'ecfLeituraXSerial' ) then
        fFuncEcfLeituraXSerial := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfLeitMemFisc');
      if ValidPointer( aFunc, 'ecfLeitMemFisc' ) then
        fFuncEcfLeitMemFisc := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusImp');
      if ValidPointer( aFunc, 'ecfStatusImp' ) then
        fFuncEcfStatusImp := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusCupom');
      if ValidPointer( aFunc, 'ecfStatusCupom' ) then
        fFuncEcfStatusCupom := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusAliquotas');
      if ValidPointer( aFunc, 'ecfStatusAliquotas' ) then
        fFuncEcfStatusAliquotas := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusPayTypes');
      if ValidPointer( aFunc, 'ecfStatusPayTypes' ) then
        fFuncEcfStatusPayTypes := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusDocsNFs');
      if ValidPointer( aFunc, 'ecfStatusDocsNFs' ) then
        fFuncEcfStatusDocsNFs := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusEquipo');
      if ValidPointer( aFunc, 'ecfStatusEquipo' ) then
        fFuncEcfStatusEquipo := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusUser');
      if ValidPointer( aFunc, 'ecfStatusUser' ) then
        fFuncEcfStatusUser := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusVincs');
      if ValidPointer( aFunc, 'ecfStatusVincs' ) then
        fFuncEcfStatusVincs := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfStatusTroco');
      if ValidPointer( aFunc, 'ecfStatusTroco' ) then
        fFuncEcfStatusTroco := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfAcertaData');
      if ValidPointer( aFunc, 'ecfAcertaData' ) then
        fFuncEcfAcertaData := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfCargaAliqSelect');
      if ValidPointer( aFunc, 'ecfCargaAliqSelect' ) then
        fFuncEcfCargaAliqSelect := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfProgHeader30');
      if ValidPointer( aFunc, 'ecfProgHeader30' ) then
        fFuncEcfProgHeader30 := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfCargaCodCripto');
      if ValidPointer( aFunc, 'ecfCargaCodCripto' ) then
        fFuncEcfCargaCodCripto := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfPrgCod');
      if ValidPointer( aFunc, 'ecfPrgCod' ) then
        fFuncEcfPrgCod := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfPayPatterns');
      if ValidPointer( aFunc, 'ecfPayPatterns' ) then
        fFuncEcfPayPatterns := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfProgNFComprov');
      if ValidPointer( aFunc, 'ecfProgNFComprov' ) then
        fFuncEcfProgNFComprov := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ecfCancItemDef');
      if ValidPointer( aFunc, 'ecfCancItemDef' ) then
        fFuncEcfCancItemDef := aFunc
      else
        bRet := False;

    end
    else
    begin
      LjMsgDlg('O arquivo DLL32PHI.dll não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
        iPorta := StrToInt(Copy(sPorta,4,1))-1;
        //Abrir a porta
        If (iPorta = 0) or (iPorta = 1) then
        Begin
            iRet:= fFuncChangePort(iPorta);
            if ((iPorta = 0) and (iRet = 0)) or ((iPorta = 1) and (iRet = 1)) then
                Result := '0|'
            Else
                Result := '1|';
        End
        Else
        Begin
            LjMsgDlg('A Impressora Schalter funciona apenas se estiver conectada à COM1 ou COM2.');
            result := '1|';
        End;
    end
    else
    begin
      result := '1|';
    end;

End;


Function StatusSchalter() : LPSTR;
begin

    // Tabela com os códigos do status da impressora. Estes correspondem a posição 3 da AnsiString de retorno
    //--------------------------------------------------------------------------
    //Código numérico	Estado interno correspondente
    //--------------------------------------------------------------------------
    //      0	                livre
    //      65	                em venda
    //      83	                memória não inicializada
    //      84	                memória fiscal em erro
    //      85	                perda da memória RAM
    //      90	                cupom aberto (somente o cabeçalho impresso)
    //      99	                em intervenção técnica
    //      100	                em período de venda
    //      109	                erro irrecuperável
    //      113	                espera de fechamento
    //      115	                fechamento do dia já realizado
    //      122	                relatório
    //      123	                em pagamento
    //      124	                em linha comercial
    //--------------------------------------------------------------------------

    Result := PAnsiChar(fFuncEcfStatusImp());

end;


function CancelaCF( Supervisor:AnsiString ):AnsiString;
var

  pAux : PChar;         // Utilizado para verificar se encontrou erro no status da impressora
  vret : LPSTR;         // Retorna AnsiString com status da impressora
  iRet : Integer;       // Retorno da execução do comando enviado a impressora

begin

    vRet := StatusSchalter();
    pAux := PWideChar(StrPos(vret, 'Erro'));

    if pAux = nil then
    begin

        //Se na posição 3,3 do vret = 100 a impressora está em modo de venda, onde conforme
        //manual, pode ser cancelado o cupom pois este já foi emitido

        if copy(vRet,3,3) = '100' then
        begin
            iRet := fFuncEcfCancDoc('');

            if iRet <> 0 then
            begin
                //Código 91: Não há cupom a cancelar
                result := '1';
            end
            else
            begin
                iRet := fFuncEcfLineFeed(1,8);
                result := '0';
            end;
        end
        else
        begin
            //------------------------------
            // Faz o cancelamento da venda -
            //------------------------------
            iRet := fFuncEcfCancVenda('');

            if iRet <> 0 then
            begin
                result := '1';
	        end
            else
            begin
			    iRet := fFuncEcfLineFeed(1,8);
                result := '0';
            end;
        end;
    end
    else
        result := '1';

end;


function ImpCabec( ) : AnsiString;

var
  vret           : LPSTR;
  sRet           : AnsiString;
  aux_pchar      : PChar;
  estado_interno : AnsiString;
  situation      : integer;
  iGHeaderLayout : Integer;
  int66          : integer;

begin

    iGHeaderLayout := 0 ;

    vRet := StatusSchalter();

    aux_pchar := PWideChar(StrPos(vret, 'Erro'));

    if aux_pchar = nil then
    begin
        estado_interno := copy(vret,3,3);
        situation := strtoint(estado_interno);

        // 0   = Livre
        // 65  = Em venda
        // 90  = Com cupom aberto
        // 99  = Em intervenção técnica
        // 100 = Em período de venda
        // 113 = Esperando fechamento
        // 115 = Com o fechamento do dia já feito
        // 122 = Em relatório
        // 123 = Em pagamento
        // 124 = Em linha comercial

        if situation = 113 then
        begin
            //LjMsgDlg('A impressora está aguardando fechamento e não pode realizar vendas neste estado.');
            sRet := CancelaCF('');
            result := ('1');
        end;
        if situation = 115 then
        begin
           //LjMsgDlg('O fechamento do dia corrente já foi realizado. A impressora não pode realizar vendas neste estado.');
           sRet := CancelaCF('');
           result := '1';
        end;
        if situation = 123 then
        begin
           //LjMsgDlg('A impressora está em pagamento. Neste estado, não é possível vender novos itens.');

           sRet := CancelaCF('');
           result := ('1');
        end;
        if situation = 124 then
        begin
           //LjMsgDlg('A impressora está em linhas comerciais. Neste estado, não é possível vender novos itens.');

           sRet := CancelaCF('');
           result := ('1');
        end;

        if (situation = 0) or (situation = 100) then
        begin
            int66 := fFuncEcfImpCab(iGHeaderLayout);
            if int66 <> 0 then
            begin
                result := ('1');
	            LjMsgDlg('Erro ao imprimir cabeçalho: '  + intToStr( int66) );
            end;
        end;

        result := ('0');
    end;

end;


function ImpCabecNF() : AnsiString;

var
  vret           : LPSTR;
  aux_pchar      : PChar;
  estado_interno : AnsiString;
  situation      : integer;
  iGHeaderLayout : Integer;
  int66          : integer;

begin

    iGHeaderLayout := 1 ;

    vRet := StatusSchalter();

    aux_pchar := pWideChar(StrPos(vret, 'Erro'));

    if aux_pchar = nil then
    begin
        estado_interno := copy(vret,3,3);
        situation := strtoint(estado_interno);

        // 0   = Livre
        // 65  = Em venda
        // 90  = Com cupom aberto
        // 99  = Em intervenção técnica
        // 100 = Em período de venda
        // 113 = Esperando fechamento
        // 115 = Com o fechamento do dia já feito
        // 122 = Em relatório
        // 123 = Em pagamento
        // 124 = Em linha comercial

        if situation = 113 then
        begin
            LjMsgDlg('A impressora está aguardando fechamento e não pode realizar vendas neste estado.');
            result := ('1');
        end;
        if situation = 115 then
        begin
           LjMsgDlg('O fechamento do dia corrente já foi realizado. A impressora não pode realizar vendas neste estado.');
           result := ('1');
        end;
        if situation = 123 then
        begin
           LjMsgDlg('A impressora está em pagamento. Neste estado, não é possível vender novos itens.');
           result := ('1');
        end;
        if situation = 124 then
        begin
           LjMsgDlg('A impressora está em linhas comerciais. Neste estado, não é possível vender novos itens.');
           result := ('1');
        end;

        if (situation = 0) or (situation = 100) then
        begin
            int66 := fFuncEcfImpCab(iGHeaderLayout);
            if int66 <> 0 then
            begin
                result := ('1');
	            LjMsgDlg('Erro ao imprimir cabeçalho: '  + intToStr( int66) );
            end;
        end;

        result := ('0');
    end;

end;

//---------------------------------------------------------------------------

function AchaPagto( sForma:AnsiString;aFormas: TaString ):AnsiString;
  var
    iPos, iTamanho : Integer;
begin
    iPos := 0;
    for iTamanho:=0 to Length(aFormas)-1 do
      if UpperCase(Trim( aFormas[iTamanho] ) ) = UpperCase(sForma) then
        iPos := iTamanho;
    if Length(IntToStr(iPos)) < 2 then
      result := '0' + IntToStr(iPos)
    else
      result := IntToStr(iPos);
end;

//---------------------------------------------------------------------------
function TImpSchalter.Fechar( sPorta:AnsiString ) : AnsiString;
begin
  Result := CloseSchalter;
end;

//----------------------------------------------------------------------------
Function CloseSchalter : AnsiString;
begin
  Result := '0|';
end;

//----------------------------------------------------------------------------
function TImpSchalter.LeituraX:AnsiString;
var
  iRet : Integer;
begin
  iRet :=fFuncEcfLeituraX('BLABLA');
  if iRet = 0 then
    Result := '0'
  Else
    Result := '1';
end;

//----------------------------------------------------------------------------
function TImpSchalter.PegaCupom(Cancelamento:AnsiString):AnsiString;
var
  sRet : AnsiString;
  sNumCupom : AnsiString;
begin

  //Se não tiver nenhum cupom aberto, é retornado os dados do próximo cupom

  sRet := fFuncEcfStatusCupom(0);
  If Copy(sRet,1,5) <> 'Erro:' then
  Begin
    sNumCupom := Copy(sRet,6,6);
    If Cancelamento = 'T' then
        sNumCupom := IntToStr(StrToInt(sNumCupom)-1)
    else
        sNumCupom := IntToStr(StrToInt(sNumCupom));

    Result := '0|' +  sNumCupom;
  End
  Else
    Result := '1';
end;


//----------------------------------------------------------------------------
function TImpSchalter.PegaPDV:AnsiString;
var sRet    : AnsiString;
    sNumPDV : AnsiString;
begin

    sRet := fFuncEcfStatusCupom(0);
    If Copy(sRet,1,5) <> 'Erro:' then
    Begin
        sNumPDV := Copy(sRet,1,4);
        Result  := '0|' + sNumPDV;
    End
    Else
        Result  := '1|';

end;

//----------------------------------------------------------------------------
function TImpSchalter.PegaSerie:AnsiString;
var
    sRet    : AnsiString;
    pRet    : PChar;
    pAux    : PChar;

begin
    sRet:=Space(20);

    pRet   := fFuncEcfStatusEquipo( );
    pAux   := StrPos(pRet, 'Erro');

    if pAux = nil then
    begin
        sRet := copy(pRet,30,9);
        Result := '0|' + sRet;
    end else
    begin
        Result := '1';
    end;
end;

//----------------------------------------------------------------------------
function TImpSchalter.LeCondPag:AnsiString;
var
    i       : Integer;

    sErro   : AnsiString;
    sPagto  : AnsiString;
    sMsg    : AnsiString;
    sPay    : AnsiString;

    pRet    : PChar;
    pAux    : PChar;

begin

    sErro := '0';

    For i:=0 to 19 do
    begin
        //----------------------------------------------------------------
        //Faz a chamada da função que retorna as condições de pagamento  -
        //----------------------------------------------------------------
        pRet := fFuncEcfStatusPayTypes( i );
        pAux := StrPos(pRet, 'Erro');

        if pAux = nil then
        begin
            //----------------------------------------------------------------
            // O segundo caracter da linha de retorno indica se a condição de-
            // pagamento está Ativa("S") ou Não ("N"). Deve-se considerar    -
            // somente as condições que estão Ativas.                        -
            //----------------------------------------------------------------
            sPay := copy(pRet,2,1);
            sPagto := sPagto +  copy(pRet,4,20) + '|';
        end else
	    begin
            sMsg := ('Ocorreu o erro de número ' + copy(pRet,7,3)) + chr(13)+ chr(13) ;

            if strtoint(copy(pRet,7,3)) = 4 then
            begin
                sMsg := sMsg + chr(13) + 'CAUSAS:'+ chr(13)+ chr(13) ;

                sMsg := sMsg + '- Impressora fora de linha ou desligada.' + chr(13);
                sMsg := sMsg + '- Verifique se o cabo está conectado.' + chr(13);
                sMsg := sMsg + '- Verifique se a porta serial em uso está correta.' + chr(13);
            end;
	        LjMsgDlg( sMsg );
            sErro := '1';
	        break;
        end;
    end;

    If sErro = '0' then
    begin
        Result := '0|' + sPagto;
    end else
        Result := '1';
end;


//--------------------------------------------------------------------------------------------------------------
function TImpSchalter.MemoriaFiscal( DataInicio,DataFim:TDateTime;ReducInicio,ReducFim,Tipo:AnsiString  ): AnsiString;
var
  iRet      : Integer;
  sDataIn,sDataFim: AnsiString;
  sFile     : AnsiString;
  fFile     : TextFile;
  sArqAux   : AnsiString;
Begin
    sArqAux := 'MEMFISC.TXT';
    //------------------------------------------------------------------
    // Parâmetros da Função fFuncEcfLeitMemFisc :                      -
    //                      1) Tipo                                    -
    //                      2) Período Inicial                         -
    //                      3) Período Final                           -
    //                      4) Redução Inicial                         -
    //                      5) Redução Final                           -
    //                      6) Nome do Arquivo a ser gravado           -
    //------------------------------------------------------------------

    if (Tipo='I') OR (Pos('I', UpperCase(Tipo)) > 0) then
    // Leitura da memoria para Impressora
    Begin
        //-----------------------------------
        // Faz a impressão por Redução      -
        //-----------------------------------
        if ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
        Begin
            ReducInicio:=FormataTexto(ReducInicio,4,0,2) ;
            ReducFim   :=FormataTexto(ReducFim,4,0,2);

            iRet       := fFuncEcfLeitMemFisc (2, '', '', strToInt(ReducInicio), strToInt(ReducFim), '' );
        End
        Else
        Begin
            //-----------------------------------
            // Faz a impressão por data         -
            //-----------------------------------
            sDataIn    := FormataData(DataInicio,1);
            sDataFim   := FormataData(DataFim,1);
            iRet       := fFuncEcfLeitMemFisc (1, Pansichar(sDataIn), Pansichar(sdataFim), 0, 0, '' );
        End
    End
    Else
    Begin
        // Leitura da memoria para disco
        result:= '0';
        //----------------------------------------------------------------------------------------
        //Define o local de gravação do arquivo, que será o mesmo onde se encontra a SIGALOJA.DLL-
        //----------------------------------------------------------------------------------------
        sFile := ExtractFilePath(Application.ExeName);

        // Deletar o Arquivo anterior
        If FileExists(sFile + sArqAux) then
        Begin
            AssignFile( fFile, sFile + sArqAux);
            Erase(fFile);
        End;

        If ( Trim(ReducInicio)<>'') or ( Trim(ReducFim)<>'') then
        Begin
            ReducInicio:=FormataTexto(ReducInicio,4,0,2);
            ReducFim   :=FormataTexto(ReducFim,4,0,2);

            iRet := fFuncEcfLeitMemFisc (4, '', '', strToInt(ReducInicio), strToInt(ReducFim), Pansichar(sFile + sArqAux) );
        End
        Else
        Begin
            sDataIn    := FormataData(DataInicio,1);
            sDataFim   := FormataData(DataFim,1);

            iRet  := fFuncEcfLeitMemFisc (3, Pansichar(sDataIn), Pansichar(sdataFim), 0, 0, Pansichar(sFile + sArqAux) );
        End;
    End;

    if iRet = 0 then
    begin
        result := '0';

        If (Tipo = 'D') OR (Pos('A', UpperCase(Tipo)) > 0) Then
        begin
            // Grava arquivo no local indicado
            Result := CopRenArquivo( sFile, sArqAux, PathArquivo, DEFAULT_ARQMEMCOM );
            If Result = '0' Then
                LjMsgDlg ('Arquivo gerado com sucesso : ' + sFile + sArqAux );
        end
        else
            iRet := fFuncEcfLineFeed(1,7);

    end
    else
        LjMsgDlg ('Ocorreu o erro de número ' + intToStr(iRet) );

end;

//----------------------------------------------------------------------------
function TImpSchalter.AbreECF : AnsiString;
begin
  result := '0';
end;

//----------------------------------------------------------------------------




//----------------------------------------------------------------------------
function TImpSchalter.AbreCupom(Cliente:AnsiString; MensagemRodape:AnsiString) : AnsiString;
var
  vret           : LPSTR;       //Retorno da dll
  pAux           : PChar;       //Verifica se a dll retornou algum erro.
  sStatus        : AnsiString;      //Status da impressora
  situation      : integer;     //Situacao
  iGHeaderLayout : Integer;
  int66          : integer;
begin

    iGHeaderLayout := 0 ;

    vRet := StatusSchalter();

    pAux := PWideChar(StrPos(vret, 'Erro'));

    if pAux = nil then
    begin
        sStatus    := copy(vret,3,3);
        situation := strtoint(sStatus);

        // 0   = Livre
        // 65  = Em venda
        // 90  = Com cupom aberto
        // 99  = Em intervenção técnica
        // 100 = Em período de venda
        // 113 = Esperando fechamento
        // 115 = Com o fechamento do dia já feito
        // 122 = Em relatório
        // 123 = Em pagamento
        // 124 = Em linha comercial

        Result := '0';

        if situation = 113 then
        begin
            LjMsgDlg('A impressora está aguardando fechamento e não pode realizar vendas neste estado.');
            result := '1';
        end;
        if situation = 115 then
        begin
           LjMsgDlg('O fechamento do dia corrente já foi realizado. A impressora não pode realizar vendas neste estado.');
           result := '1';
        end;
        if situation = 123 then
        begin
           LjMsgDlg('A impressora está em pagamento. Neste estado, não é possível vender novos itens.');
           result := '1';
        end;
        if situation = 124 then
        begin
           LjMsgDlg('A impressora está em linhas comerciais. Neste estado, não é possível vender novos itens.');
           result := '1';
        end;

        if (situation = 0) or (situation = 100) then
        begin
            int66 := fFuncEcfImpCab(iGHeaderLayout);
            if int66 <> 0 then
            begin
                result := '1';
	            LjMsgDlg('Erro ao imprimir cabeçalho: '  + intToStr( int66) );
            end;
        end;


    end;
end;


//----------------------------------------------------------------------------
function TImpSchalter.ReducaoZ(MapaRes:AnsiString):AnsiString;

var
  i           : Integer;            // Contador
  iRet        : Integer;            // Retorno da fução
  sRet        : AnsiString;             // Utilizada para armazenar dados do retorno das funções
  sGrandTot   : AnsiString;             // Grande Total
  sNroECF     : AnsiString;             // Numero do ECF
  sSeriePDV   : AnsiString;             // Armazena a série do PDV
  sNumCupom   : AnsiString;             // Pega o próximo nro de cupom
  sCupomIni   : AnsiString;             // Pega o número do primeiro cupom impresso
  sCupomFin   : AnsiString;             // Pega o número do último cupom impresso
  sNroReduz   : AnsiString;             // Numero de Reduções Z realizadas pelo ECF
  sTotCanc    : AnsiString;             // Total de Cancelamentos do dia
  sTotDesc    : AnsiString;             // Total de descontos do dia
  sTotSubst   : AnsiString;             // Total de Substituição Tributária
  sTotIsento  : AnsiString;             // Total de isentos
  sTotNaoTrib : AnsiString;             // Total de Nao tributado
  sDataReduz  : AnsiString;             // Data da Redução Z;
  sTotISS     : AnsiString;             //Total de ISS
  sAliq       : AnsiString;             // Aliquota cadastrada na impressora
  sNroInterv  : AnsiString;             // Número de intervenções técnicas

  pRet        : PChar;              // Retorno da função LeituraXSerial
  aRetorno    : array of AnsiString;    //Retorno dos dados para o mapa resumo
  pPath       : PChar;
  sPath       : AnsiString;
  fArquivo    : TIniFile;

begin
    iRet := 0;

    MapaRes:= 'S';

    If Trim(MapaRes)='S' then
    begin

        // Prepara o array, aRetorno, com os dados do ECF...
        SetLength(aRetorno,21);

        sRet := fFuncEcfStatusCupom(0);
        If Copy(sRet,1,5) <> 'Erro:' then
        begin

            sNroECF     := Copy(sRet,1,4);

            sGrandTot   :=  StrTran(Copy(sRet,47,21),'.','');            // Grande Total (17 dígitos)
            sGrandTot   := FormataTexto(sGrandTot, 18, 2, 1);

            //------------------------------------------------------------------
            // Pega a Série do PDV
            //------------------------------------------------------------------
            sRet := PegaSerie();
            if Copy( sRet,1,1) = '0' then
            begin
                sSeriePDV := Copy (sRet, 3, length(sRet) );

                //--------------------------------------------------------------
                // Pega o Numero do Ultimo
                //--------------------------------------------------------------
                sRet := PegaCupom('');
                if Copy( sRet,1,1) = '0' then
                begin
                    sNumCupom :=  intToStr((strToInt(Copy(sRet, 3,length(sRet)))));
                    sNumCupom := FormataTexto( sNumCupom,6,0,2 );

                    //----------------------------------------------------------
                    // Pega os dados da leituraXserial
                    //----------------------------------------------------------
                    pRet := fFuncEcfLeituraXSerial();
                    If Copy(pRet,1,5) <> 'Erro:' then
                    begin
                        sNroReduz   := Copy(pRet,1,4);
                        sDataReduz  := Copy(pRet,5,8);
                        sNroInterv  := FormataTexto(Copy(pRet,13,4),3,0,2);
                        sCupomIni   := Copy(pRet,17,6);
                        sCupomFin   := Copy(pRet,23,6);
                        sTotCanc    := FormataTexto( StrTran(Copy(pRet,35,21),'.',''),13, 2, 1);
                        sTotDesc    := FormataTexto( StrTran(Copy(pRet,56,21),'.',''),13, 2, 1);
                        sTotSubst   := FormataTexto( StrTran(Copy(pRet,119,18),'.',''),13, 2,1);
                        sTotIsento  := FormataTexto( StrTran(Copy(pRet,137,18),'.',''),13, 2,1);
                        sTotNaoTrib := FormataTexto( StrTran(Copy(pRet,155,18),'.',''),13, 2,1);
                        sTotISS     := FormataTexto( StrTran(copy(pRet,637,18),'.',''),13, 2,1);

                        aRetorno[ 0]:= sDataReduz;      //**** Data do Movimento                ****//
                        aRetorno[ 1]:= sNroECF;         //**** Numero do ECF                    ****//
                        aRetorno[ 2]:= sSeriePDV;       //**** Serie do ECF                     ****//
                        aRetorno[ 3]:= sNroReduz;       //**** Numero de reducoes               ****//
                        aRetorno[ 4]:= sGrandTot;       //**** Grande Total Final               ****//
                        aRetorno[ 5]:= sCupomIni;       //**** Numero Cupom inicial             ****//aRetorno[ 6];
                        aRetorno[ 6]:= sCupomFin;       //**** Numero Cupom Final               ****//
                        aRetorno[ 7]:= sTotCanc;        //**** Valor do Cancelamento            ****//

                        aRetorno[ 9]:= sTotDesc;        //**** Desconto                         ****//
                        aRetorno[10]:= sTotSubst;       //**** Nao tributado SUBSTITUIcao TRIB  ****//
                        aRetorno[11]:= sTotIsento;      //**** Nao tributado ISENTO             ****//
                        aRetorno[12]:= sTotNaoTrib;     //**** Nao tributado Nao Tributado      ****//
                        aRetorno[13]:= aRetorno[0];     //**** Data da Reducao  Z               ****//
                        aRetorno[14]:= sNumCupom;       //**** Sequencial de Operação(4 dígitos)****//
                        aRetorno[15]:= FormataTexto('0',16, 0, 2);  // Outros recebimentos      ****//
                        aRetorno[16]:= sTotISS;         //**** Total de ISS                     ****//
                        aRetorno[17]:= sNroInterv;      //Numero de Intervenções                ****//
                        aRetorno[18]:= FormataTexto('0',16, 0, 2);  // Desconto de ISS      ****//
			aRetorno[19]:= FormataTexto('0',16, 0, 2);  // Cancelamento de ISS      ****//
                        aRetorno[20]:= '00';             // QTD DE Aliquotas

                        for i := 0 to 15 do
                        begin
                            pRet := fFuncEcfStatusAliquotas( i );
                            if Copy(pRet,1,5) <> 'Erro:' then
                            begin
                                sAliq := copy(pRet,3,5);
			                    if ( Copy(pRet, 2,1) = 'T' ) and (FormataTexto(sAliq,4,2,2) <> '0000')    then
                                begin
                                    aRetorno[20] :=  FormataTexto(IntToStr(StrToInt(aRetorno[20])+1),2,0,2);

                                    SetLength( aRetorno, Length(aRetorno)+1 );
                                    aRetorno[High(aRetorno)]:= 'T' + Copy(pRet,3,5)+' '+FormataTexto(StrTran(Copy(pRet,8,16),'.',''),14,2,1,'.')+' '+FormataTexto(StrTran(Copy(pRet,24,14),'.',''),14,2,1,'.');
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    iRet :=  1;
                end;
            end
            else
            begin
                iRet := 1;
            end;
        End
        Else
        begin
            iRet := 1;
        end;
    end;

    if iRet = 0 then
    begin
        iRet:=1;
        iRet := fFuncEcfReducaoZ('');
        if iRet <> 0 then
        begin
            LjMsgDlg('Erro na Redução Z: ' + intToStr(iRet)  );
            Result := '1|' + intToStr(iRet) ;
        end
        else
        begin
            Result := '0';

            // Zera o arquivo da Venda Bruta
            pPath       := Pchar(Replicate('0',100));
            GetSystemDirectory(pPath, 100);
            sPath := StrPas( pPath );
            fArquivo := TIniFile.Create( pPath + '\FILE.SCL');
            fArquivo.WriteString( 'SCHALTER','GT', '0' );

            If Trim(MapaRes) ='S' then
            begin
                Result := '0|';
                For i:= 0 to High(aRetorno) do
                    Result := Result + aRetorno[i]+'|';
            end;
            iRet := fFuncEcfLineFeed(1,8);
        end
    end
    else
    begin
        result := '1';
    end;

end;

//----------------------------------------------------------------------------
function TImpSchalter.LeAliquotas:AnsiString;
begin
  //Result := '0|' + ICMS;
  Result := '0|' + aliquotas;
end;
//----------------------------------------------------------------------------
function TImpSchalter.LeAliquotasISS:AnsiString;
begin
  result := '0|'+ISS;
end;

//----------------------------------------------------------------------------
Procedure TImpSchalter.AlimentaProperties;


var i       : Integer;
    pRet    : PChar;
    pAux    : PChar;
    sTipo   : AnsiString;
    sAliq   : AnsiString;

begin
    /// Inicalização de variaveis
    ICMS    := '';
    ISS     := '';
    PDV     := '';
    Eprom   := '';
    Aliquotas := '';

    for i := 0 to 15 do
    begin
        pRet := fFuncEcfStatusAliquotas( i );
        pAux := StrPos(pRet, 'Erro');
        if pAux = nil then
        begin
            Aliquotas := Aliquotas + copy(pRet,2,6) + '|';
            sAliq := copy(pRet,3,5);
            if (FormataTexto(sAliq,4,2,2) <> '0000') then
            begin
                sTipo := copy(pRet,2,1);

                if sTipo = 'S' then
                begin
                    // Retorno de Aliquotas ( ISS )
                    ISS   := ISS + FormataTexto(sAliq,5,2,1) +'|';
                end
                else If sTipo = 'T' then
                begin
                    // Retorno de Aliquotas (ICMS)
                    ICMS   := ICMS + FormataTexto(sAliq,5,2,1) +'|';
                end;
            end;
        end;
    end;
end;


//----------------------------------------------------------------------------
function TImpSchalter.StatusImp( Tipo:Integer ):AnsiString;
var
  iRet       : Integer;
  i          : Integer;
  vret       : LPSTR;
  pAux       : PChar;
  pRet       : PChar;
  pPath      : PChar;
  sPath      : AnsiString;
  sVB        : AnsiString;
  sRet       : AnsiString;
  sForma     : AnsiString;
  Data       : AnsiString;
  Hora       : AnsiString;
  sSuprimento: AnsiString;
  fArquivo   : TIniFile;

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
  // 17 - Verifica venda bruta
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

  pPath       := Pchar(Replicate('0',100));
  GetSystemDirectory(pPath, 100);
  sPath := StrPas( pPath );
  fArquivo := TIniFile.Create( pPath + '\FILE.SCL');
  //  1 - Obtem a Hora da Impressora
  If Tipo = 1 then
  begin
    Data:=Space(6);
    sRet := fFuncEcfStatusCupom(0);

    If Copy(sRet,1,5) <> 'Erro:' then
    Begin
      Hora   := Copy(sRet,12,6);
      Result := '0|'+Copy(Hora,1,2)+':'+Copy(Hora,3,2)+':'+Copy(Hora,5,2);
    end
    Else
      Result := '1';
  end
    //  2 - Obtem a Data da Impressora
  Else If Tipo = 2 then
  begin
    Data:=Space(6);
    sRet := fFuncEcfStatusCupom(0);

    If Copy(sRet,1,5) <> 'Erro:' then
    Begin
      Data   := Copy(sRet,18,8);
      Result := '0|'+ Data;
    end
    Else
      Result := '1';
  end
  //  3 - Verifica o Papel
  Else If Tipo = 3 then
  begin
    vRet := StatusSchalter();
    pAux := PwideChar(StrPos(vret, 'Erro'));

    if pAux = nil then
    begin
        //Sexta posição da AnsiString: 0) Normal; 1) Pouco Papel
        sRet := copy(vret,6,1);
        If sRet = '1' then
            Result := '2'    // Pouco papel
        Else
            Result := '0';
    end
  end

  //  4 - Verifica se é possível cancelar um ou todos os itens.
  Else if Tipo = 4 then
  begin
      Result := '0|TODOS';
  end
    Else If Tipo = 5 then
    Begin
        vRet := StatusSchalter();
        pAux := pwidechar(StrPos(vret, 'Erro'));

        if pAux = nil then
        begin
            sRet := copy(vret,3,3);

            //065   - Em venda;
            //090   - Cupom Aberto (somente cabeçalho);
            //123   - Esperando pagamento;
            //100   - Em periodo de venda (cupom fechado)
            //000   - Impressora Livre

            If (sRet = '090') or (sRet='123') or (sRet= '065') then
            begin
                result := '7';
            end
            else
                result :='0';
        end
        else
            result := '1';     //

  end
  //  6 - Ret. suprimento da impressora
  Else If Tipo = 6 then
  begin

    for i:=1 to 19 do
    begin
        //----------------------------------------------------------------
        //Faz a chamada da função que retorna as condições de pagamento  -
        //----------------------------------------------------------------
        pRet := fFuncEcfStatusPayTypes( i );
        pAux := StrPos(pRet, 'Erro');

        if pAux = nil then
        begin
            //----------------------------------------------------------------
            // O segundo caracter da linha de retorno indica se a condição de-
            // pagamento está Ativa("S") ou Não ("N"). Deve-se considerar    -
            // somente as condições que estão Ativas.                        -
            //----------------------------------------------------------------
            sRet := copy(pRet,2,1);
            if sRet = 'S' then
            begin
                sForma := UpperCase( Trim( copy(pRet,4,20) ) );

                if sForma='DINHEIRO' then
                begin
                    // Retorna o valor acumulado efetuado no dia
                    sSuprimento := StrTran(copy(pRet,25,20),',','.');
                    sSuprimento := FloatToStrf(StrToFloat(sSuprimento),ffFixed,18,2);

                    Break;
                end
            end else
            begin
                Result:= '1';
            end
        end;
    end;
    Result := '0|' + sSuprimento;
  end

  //  7 - ECF permite desconto por item
  Else If Tipo = 7 then
    Result := '0'

  //  8 - Verifica se o dia anterior foi fechado
  Else If Tipo = 8 then
  begin

    vRet := StatusSchalter();

    pAux := pWideChar(StrPos(vret, 'Erro'));

    if pAux = nil then
    begin
        sRet := copy(vret,3,3);
        iRet := strtoint(sRet);

        // 113 = Esperando fechamento
        if iRet = 113 then
        begin
            Result := '1';
        end
        else
        begin
            Result:= '0';
        end

    end;
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
  begin

    // Para o FlagTruncamento, retorna 1 se a impressora estiver no modo truncamento e 0 se estiver no modo arredondamento.
    // Conforme conversao com o Renato ("suporte da schalter") a impressora trabalha em modo de truncamento.
    // Não encontrei nehuma informação na documentação.
    Result := '1';

  end

  // 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
  else if Tipo = 14 then
  begin
    vRet := StatusSchalter();

    pAux := PWideChar(StrPos(vret, 'Erro'));

    if pAux = nil then
    begin
        //Gaveta aberta retorna 0. Se estiver fechada retorna 1
        sRet := copy(vret,8,1);
        Result := sRet;
    end
  end

  // 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
  else if Tipo = 15 then
    Result := '0'
  // 16 - Verifica se exige o extenso do cheque
  else if Tipo = 16 then
    Result := '1'
  // 17 - Verifica a Venda Bruta, na Schalter nao existe esse retorno
  // assumiremos o GT como venda bruta
  else if Tipo = 17 then
     Begin
        sRet := fFuncEcfStatusCupom(0);
        If fArquivo.ReadString( 'SCHALTER', 'GT', '' ) = '0' Then
        Begin
          If Copy( sRet, 1, 4 ) = 'Erro' then
            Result := '1'
          Else
          Begin
            sRet := Copy( sRet, 47, 21 );
            sRet := StrTran( sRet, '.', '' );
            sRet := FormataTexto( sRet, 21, 2, 2);
            fArquivo.WriteString( 'SCHALTER','GT', sRet );
            sRet := '0';
            sRet := FormataTexto( sRet, 21, 2, 2);
            Result := '0|' + sRet;
          End;

        End

        Else
        begin
          sRet := Copy( sRet, 47, 21 );
          sRet := StrTran( sRet, '.', '' );
          sRet := FormataTexto( sRet, 21, 2, 2);
          sVB := fArquivo.ReadString( 'SCHALTER', 'GT', '' );
          sVB := FormataTexto( sVB, 21, 0, 2);
          sVB := IntToStr( StrToInt( sRet ) - StrToInt( sVB ) );
          sVB := FormataTexto( sVB, 21, 0, 2);
          Result := '0|' + sVB;
        end;

        fArquivo.Free;

     End
  // 18 - Verifica o Grande Total
  else if Tipo = 18 then
     Begin
       sRet := fFuncEcfStatusCupom(0);
       If Copy( sRet, 1, 4 ) = 'Erro' then
         Result := '1'
       Else
       Begin
         sRet := Copy( sRet, 47, 21 );
         sRet := StrTran( sRet, '.', '' );
         sRet := FormataTexto( sRet, 21, 2, 2);
         fArquivo.WriteString( 'SCHALTER','GT', sRet );
         Result := '0|' + sRet;
       End
     End
  // 20 ao 40 - Retorno criado para o PAF-ECF
  else if (Tipo >= 20) AND (Tipo <= 40) then
    Result := '0'
  else
    Result := '1';

end;

//----------------------------------------------------------------------------
function TImpSchalter.RegistraItem( codigo,descricao,qtde,vlrUnit,vlrdesconto,aliquota,vlTotIt,UnidMed:AnsiString; nTipoImp:Integer ): AnsiString;
var
  sAliq     : AnsiString;
  sSituacao : AnsiString;
  sRet      : AnsiString;
  sCasas    : AnsiString;
  sTipoQtd  : AnsiString;
  iRet      : Integer;
  aAliq     : TaString;
  iAliq     : Integer;
  iPosTaxa  : Integer;
  iTamanho  : Integer;
  nPos      : Integer;

begin
    sCasas:='2';

    // Verifica a casa decimal dos parâmetros
    qtde        := StrTran(qtde,',','.');
    vlrUnit     := StrTran(vlrUnit,',','.');
    vlrdesconto := StrTran(vlrdesconto,',','.');
    vlTotIt     := Trim(StrTran(vlTotIt,',','.'));

    //verifica se é para registra a venda do item ou só o desconto
    if Trim(codigo+descricao+qtde+vlrUnit) = '' then
    begin
        if StrToFloat(vlrdesconto) <> 0 then
        begin
            iRet := fFuncEcfDescItem( 0, '', PAnsiChar( FormataTexto(vlrdesconto,9,2,2) ) );
        end
        else
        begin
            iRet := 0;
        end
    end
    else
    begin
        // Faz o tratamento da aliquota
        sSituacao := copy(aliquota,1,1);

        //aliquota := Trim(StrTran(copy(aliquota,2,5),',','.'));
        If Length( Trim( Copy( aliquota, 2, 5 ) ) ) = 4 then
          aliquota := Copy( aliquota, 1, 1 ) + '0' + Trim( Copy( aliquota, 2, 5 ) );
        aliquota := StrTran(copy(aliquota,1,6),'.',',');

        // Checa as aliquotas
        sRet := LeAliquotas;

        // Problemas na leitura de aliquota ?
        if copy( sRet, 1, 1 ) <> '0' then
        begin
            result := '1|';
            exit;
        end
        else
        begin
            sRet := copy( sRet, 3, length( sRet ) );
        end;

        // Verifica se a aliquota é ISENTA, c/SUBSTITUICAO TRIBUTARIA, NAO TRIBUTAVEL OU ISS
        If (sSituacao = 'T') or (sSituacao = 'S') then
        begin

            MontaArray( sRet, aAliq );

            //--------------------------------------------------------------------------------------
            // Procura a posicao da aliquota dentro do array. Esta posição define o tipo de imposto-
            //  0 - 15	taxa 0 até taxa 15 (fiscais ou ISS)                                        -
            //  16	Substituição tributária                                                        -
            //  17	Isento                                                                         -
            //  18	Não incidente                                                                  -
            //--------------------------------------------------------------------------------------
            iPosTaxa := -1;
            for iTamanho:=0 to Length(aAliq)-1 do
            begin
                if aAliq[iTamanho] = aliquota then
                    //iPosTaxa := iTamanho + 1;
                  iPosTaxa := iTamanho;
            end;
            if (iPosTaxa = -1) then
            begin
                ShowMessage('Aliquota não cadastrada.');
                result := '1|';
                exit;
            end;
            {Else
            begin
                // Pega a posição exata da alíquota no array
                iPosTaxa := iPosTaxa - 1;
            end;}
        end
        //produto Isento de Tributação
        else if Trim(sSituacao) = 'I' then
            iPosTaxa:= 17
        //produto com Substitução Tributária
        else if Trim(sSituacao) = 'F' then
            iPosTaxa:= 16
        //produto Não Tributado
        else if Trim(sSituacao) = 'N' then
            iPosTaxa:= 18;

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

        //--------------------------------------------------------------------------------------
        // Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
        //--------------------------------------------------------------------------------------
        sTipoQtd := 'F';

        //--------------------------------------------------------------------------------------
        // Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionária
        //--------------------------------------------------------------------------------------
        qtde := StrTran(FormataTexto( qtde, 7, 3, 1 ),'.',',');

        //--------------------------------------------------------------------------------------
        // Numero de cadas decimais para o preço unitário
        //--------------------------------------------------------------------------------------
        If Pos('.',vlrUnit) > 0 then
            If StrtoFloat(copy(vlrUnit,Pos('.',vlrUnit)+1,Length(vlrUnit))) > 99 then
                sCasas := '3'
            Else
                sCasas := '2';

        //////////////////////////////////////////////////////////////////////////////
        //  Função ecfVendaItem3d - Faz o Registro do ítem
        //  Parâmetros: 1) Código
        //              2) Descrição
        //              3) Quantidade - ( Máx 7 Caracter )
        //              5) Valor - Valor unitário do ítem
        //              6) Taxa - Indica a posição da alíquota;
        //                        Taxa        Tipo de Alíquota
        //                        0-15    :   Taxa 0 até taxa 15 (Ficais ou ISS)
        //                        16      :   Substituição tributária
        //                        17      :   Isento
        //                        18      :   Não incide
        //              7) Unidade
        //              8) Nro de casas decimais      Copy(codigo+Space(13),1,13)
        //////////////////////////////////////////////////////////////////////////////


        iRet :=fFuncEcfVendaItem3d (    Pansichar(codigo),
                                        Pansichar( Copy(descricao+Space(62),1,62) ),
                                        Pansichar( Qtde ),
                                        Pansichar( vlrUnit ),
                                        iPosTaxa,
                                        '',
                                        Pansichar(sCasas)  );

        if iRet = 0 then
        begin
            // Registra o desconto no ítem
            if StrToFloat(vlrdesconto) <> 0 then
                iRet := fFuncEcfDescItem( 0, '', Pansichar( FormataTexto(vlrdesconto,9,2,2) ) );
            end
    end;

    If iRet = 0 then
        Result := '0'
    Else
        Result := '1';

end;

//----------------------------------------------------------------------------


function TImpSchalter.CancelaCupom( Supervisor:AnsiString ):AnsiString;
var

  pAux : PChar;         // Utilizado para verificar se encontrou erro no status da impressora
  vret : LPSTR;         // Retorna AnsiString com status da impressora
  iRet : Integer;       // Retorno da execução do comando enviado a impressora

begin

    vRet := StatusSchalter();

    pAux := Pwidechar(StrPos(vret, 'Erro'));

    if pAux = nil then
    begin

        //Se na posição 3,3 do vret = 100 a impressora está em modo de venda, onde conforme
        //manual, pode ser cancelado o cupom pois este já foi emitido

        if copy(vRet,3,3) = '100' then
        begin
            iRet := fFuncEcfCancDoc('');

            if iRet <> 0 then
            begin
                //Código 91: Não há cupom a cancelar
                result := '1';
            end
            else
            begin
			    iRet := fFuncEcfLineFeed(1,8);
                result := '0';
            end;
        end
        else
        begin
            //------------------------------
            // Faz o cancelamento da venda -
            //------------------------------
            iRet := fFuncEcfCancVenda('');

            if iRet <> 0 then
            begin
                result := '1';
	        end
            else
            begin
			    iRet := fFuncEcfLineFeed(1,8);
                result := '0';
            end;
        end;
    end
    else
        result := '1';

end;

//----------------------------------------------------------------------------

function TImpSchalter.CancelaItem( numitem,codigo,descricao,qtde,vlrunit,vlrdesconto,aliquota:AnsiString ):AnsiString;
var
  iRet : Integer;  // Retorno do comando enviado a impressora
begin

  // O Numero do ítem a ser cancelado tem que conter 4 digitos;
  // Após o cancelamento do ítem a impressora não reordena a numeração dos ítens que já foram impressos
  iRet := fFuncEcfCancItemDef( Pansichar(FormataTexto(numitem,4,0,2)), '' );

  if iRet = 0 then
    result := '0'
  else
    result := '1';

end;

//----------------------------------------------------------------------------
function TImpSchalter.DescontoTotal( vlrDesconto:AnsiString;nTipoImp:Integer ): AnsiString;
var
  iRet : Integer;
begin

  vlrDesconto := StrTran(vlrDesconto,',','.');

  iRet := fFuncEcfCancAcresDescSubTotal( 0, 0,'' , Pansichar( FormataTexto(vlrDesconto,10,2,2) ) );

  if iRet = 0 then
    result := '0'
  else
    result := '1';

end;

//------------------------------------------------------------------------------

function TImpSchalter.AcrescimoTotal( vlrAcrescimo:AnsiString ): AnsiString;
var
  iRet : Integer;
begin

  vlrAcrescimo := FormataTexto(StrTran(vlrAcrescimo,',','.'),10,2,2)  ;

  iRet := fFuncEcfCancAcresDescSubTotal( 1, 0,'' , Pansichar( vlrAcrescimo ) );

  if iRet = 0 then
    result := '0'
  else
    result := '1';

end;

//----------------------------------------------------------------------------

function TImpSchalter.Pagamento( Pagamento,Vinculado,Percepcion:AnsiString ): AnsiString;

var
  sRet      : AnsiString;
  iRet      : Integer;
  aFormas   : TaString;
  aAuxiliar : TaString;
  i         : Integer;
  sForma    : AnsiString;
  sValor    : AnsiString;
  nPos      : Integer;
begin

  result := '1|';
  iRet := 1;

  // Verifica o parametro
  Pagamento := StrTran(Pagamento,',','.');

  // Le as condicoes de pagamento
  sRet := LeCondPag;
  sRet := Copy(sRet, 3, Length(sRet));
  MontaArray(sRet,aFormas);

  // Monta um array auxiliar com os parametros
  MontaArray( Pagamento,aAuxiliar );

  i:=0;
  While i<Length(aAuxiliar) do
  begin
    if StrToInt( AchaPagto( aAuxiliar[i],aFormas ) ) >= 0 then
      Begin
        nPos := Pos('.',aAuxiliar[i+1]);
        If nPos > 0 then
          aAuxiliar[i+1] := copy(aAuxiliar[i+1],1,nPos+2);
        sForma := AchaPagto( aAuxiliar[i],aFormas );
        sValor := FormataTexto(aAuxiliar[i+1],10,2,2);

        // Parametros da função EcfPagamento:
        // 1) Tipo da operação:  0 = Pagamento; 1 = Cancelamento do pagamento
        // 2) Forma de Pagamento;
        // 3) Valor do pagamento: AnsiString de 10 Caracteres (não deve-se usar vírgula ou ponto)
        // 4) Número de linhas para observação: No máximo 3
        iRet := fFuncEcfPagamento( 0, Pansichar( sForma ), Pansichar( sValor) , 0);

       if iRet = 0 then
          result := '0' ;

      End;
    Inc(i,2);
  end;

  if iRet <> 0 then
  begin
    result :='1';
    sRet := CancelaCF('');
  end;


end;

//----------------------------------------------------------------------------

function TImpSchalter.FechaCupom( Mensagem:AnsiString ):AnsiString;
var

  sLinha    : AnsiString;
  sMsg , sMsgAux  : AnsiString;
  iLinha    : Integer;
  iRet      : Integer;
  nX        : Integer;
begin
    // Laço para imprimir toda a mensagem
    sMsg := '';
	sMsgAux := Mensagem;
	sMsgAux := TrataTags( sMsgAux );
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

      iRet := fFuncEcfImpLinha (Pansichar( sLinha ) );

      inc(iLinha);
    End;

    iRet := fFuncEcfFimTrans('');

    if iRet = 0 then
    begin
        result := '0';
        iRet := fFuncEcfLineFeed(1,8);
    end
    else
    begin
        result := '0';
    end;

end;

//---------------------------------------------------------------------------

function TImpSchalter.AbreCupomNaoFiscal( Condicao,Valor,Totalizador, Texto:AnsiString ): AnsiString;

    function PegaRegistro( sCondicao:AnsiString):AnsiString;
    Var
        sRet    : AnsiString;
        aFormas : TaString;
        i       : Integer;
        pRet    : PChar;     // Retorna o Compravante não fiscal e suas propriedades
        pAux    : PChar;     // Verifica se o pRet retornou algum erro

    Begin
        result := '00';

        // Lendo todos as descrições dos registradores.
        // Busca  em que posição está cadastrado o documento não fiscal
        for i := 0 to 19 do
	    begin
            pRet := fFuncEcfStatusDocsNFs( i );

	        pAux := StrPos(pRet, 'Erro');
	        if pAux = nil then
	        begin

                //Verifica se o comprovante não fiscal cadastrado no Schalter.ini, está cadastrado
                if UpperCase(  trim(copy(pRet,3,20)) ) = UpperCase ( trim(sCondicao) ) then
                begin
                    Result:= intToStr( i ) ;
                end;
            end;
        end;
   End;

var
  iRet      : Integer;          // Utilizado para obter o retorno da execucao dos comandos
  sRet      : AnsiString;
  sNumAnt   : AnsiString;           // Último cupom impresso;
  i         : Integer;
  aFormas   : array of AnsiString;
  sFormas   : AnsiString;
  sPos      : AnsiString;           //Posição do totalizador não fiscal cadastrado na impressora;
  sPosTot   : AnsiString;
  iPos      : Integer;
  iTamanho  : Integer;
begin

    result := '1|';

    //Valor     := FormataTexto(Valor,9,2,2);
    Valor       := Copy( Valor, 1, Pos( '.', Valor) - 1 ) + Copy( Valor, Pos( '.', Valor) + 1, Length( Valor ) );
    Valor       := Copy( Valor, Length( Valor ) - 8, Length( Valor ) );

    If Trim(Totalizador)='' then
        Totalizador:='SIGALOJA';

    // Pegando o numero do ultimo cupom impresso
    //--------------------------------------------------------------
    // Pega o Numero do Ultimo Cupom impresso
    //--------------------------------------------------------------
    sRet := PegaCupom('');
    if Copy( sRet,1,1) = '0' then
    begin
        sNumAnt := Copy( sRet,3, length( sRet) );
        sNumAnt := FormataTexto( intToStr( strToInt(sNumAnt)-1 ) ,6,0,2 );

        // Monta o array aFormas com as condicoes de pagamento do cupom fiscal
        SetLength( aFormas,0 );

        sPos:= Totalizador;    // PegaRegistro(Totalizador);

        //------------------------------------------------------------------
        // Abrindo cupom nao fiscal vinculado
        //------------------------------------------------------------------
        sRet := ImpCabecNF();
        If sRet = '0' then
        begin
            iRet := fFuncEcfInicCNFVinculado( Pansichar( sNumAnt ), Pansichar( sPos ), Pansichar( Valor ) );

            if iRet <> 0 then
            begin
                //----------------------------------------------------------------------------------
                // Abrindo cupom não fiscal não vinculado para que o próximo seja vinculado a este
                //----------------------------------------------------------------------------------
                iRet := fFuncEcfInicCupomNFiscal(1);
                if iRet = 0 then
                begin
                    iRet := fFuncEcfVendaItem78 (Pansichar(Texto),Pansichar(valor), strToInt(sPos) );
                   
                    if iRet = 0 then
                    begin
                        // Faz o Fechamento do cupom
                        iRet := fFuncEcfFimTrans('');
                        if iRet = 0 then
                        begin
                            sNumAnt := intToStr( strToInt( sNumAnt) +1) ;
                            sNumAnt := FormataTexto( sNumAnt,4,2,2 );

                            sRet := ImpCabecNF();
                            If sRet = '0' then
                            begin
                                iRet := fFuncEcfInicCNFVinculado( Pansichar( sNumAnt), Pansichar(sPos), Pansichar(Valor) );
                                if iRet = 0 then
                                begin
                                    Result := '0';
                                end
                                else
                                begin
                                    //------------------------------------------
                                    //Cancela o cupom
                                    //------------------------------------------
                                    iRet := fFuncEcfCancDoc('');
                                end;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := '0';
            end
        end;
    end;
end;

//----------------------------------------------------------------------------

function TImpSchalter.FechaEcf:AnsiString;
var
  iRet : Integer;

begin
    iRet := fFuncEcfReducaoZ('');

    if iRet <> 0 then
    begin
        Result := '1';
    end
    else
    begin
        Result := '0';
        iRet := fFuncEcfLineFeed(1,8);
    end;

end;

//----------------------------------------------------------------------------

function TImpSchalter.Suprimento( Tipo:Integer;Valor:AnsiString; Forma:AnsiString; Total:AnsiString; Modo:Integer; FormaSupr:AnsiString ):AnsiString;

var
  I         : Integer;
  iRet      : Integer;

  sRet      : AnsiString;
  sNomeCNF  : AnsiString;
  sTexto    : AnsiString;
  sForma    : AnsiString;
  sValor    : AnsiString;


  pRet : PChar;     // Retorna o Compravante não fiscal e suas propriedades
  pAux : PChar;     // Verifica se o pRet retornou algum erro


  aFormas : TaString;
  sFormas : AnsiString;


  sCondicao : AnsiString;

  sPosDep : AnsiString;
  sPosRet : AnsiString;


begin

    Result :='1|';

    If Tipo = 1 then
    begin

        sValor :=  FormataTexto(Valor,10,2,2);
        sFormas :='DINHEIRO';

        // Le as condicoes de pagamento cadastradas na impressora e guarda no array aFormas
        sRet := LeCondPag;
        sRet := Copy(sRet, 3, Length(sRet));
        MontaArray(sRet, aFormas);

        sPosRet := AchaPagto( sFormas,aFormas );

        //----------------------------------------------------------------------
        // Verifica o valor em dinheiro armazenado nas formas de pagamento
        //----------------------------------------------------------------------
        // Pesquisando antes de efetuar a transferência...

        pRet := fFuncEcfStatusPayTypes( strToInt(sPosRet) );
        pAux := StrPos(pRet, 'Erro');

        if pAux = nil then
        begin
            sRet := copy(pRet, 2, 1);
            if sRet = 'S' then
            begin
                sRet := copy(pRet, 24, 20);

                if StrToFloat(FormataTexto(sRet,10,2,2)) >= StrToFloat(FormataTexto(Valor,10,2,2)) then
                    result := '8'
                else
                    result := '9' ;
            end;
        end
    end
    else If Tipo = 2 then
    Begin
        sValor :=  FormataTexto(Valor,9,2,2);

        sNomeCNF := SigaLojaINI('SCHALTER.INI', 'Suprimento', 'NomeCNF', 'RECEBIMENTOS DIVERSO');
        sTexto   := SigaLojaINI('SCHALTER.INI', 'Suprimento', 'Texto',   'FUNDO DE CAIXA');  // Limitado a 70 caracteres

        // Busca  em que posição está cadastrado o documento não fiscal de suprimento
        // Obrigatoriamente o parametro Permite pagamento = sim
        for i := 0 to 19 do
	    begin
            pRet := fFuncEcfStatusDocsNFs( i );

	        pAux := StrPos(pRet, 'Erro');
	        if pAux = nil then
	        begin

                //Verifica se o comprovante não fiscal cadastrado no Schalter.ini, está cadastrado
                //na impressora.Posição 3, 20 = DESCRIÇÃO DO COMPROVANTE NÃO FISCAL
                if UpperCase(  trim(copy(pRet,3,20)) ) = UpperCase ( trim(sNomeCNF) ) then
                begin

	                if  ( copy(pRet, 2,1) = 'S' ) or     //Verifica na posição 2 se o documento não fiscal está ativo na impressorathen
	                    ( copy(pRet,23,1) = 'N' ) or     //PERMITE DESCONTO = N
                        ( copy(pRet,24,1) = 'N' ) or     //PERMITE ACRESCIMO =N
                        ( copy(pRet,25,1) = 'N' ) or     //PERMITE CANCELAMENTO =N
                        ( copy(pRet,26,1) = 'S' ) or     //PERMITE PAGAMENTO = "S"
                        ( copy(pRet,27,1) = 'N' ) or     //É VINCULADO = N
                        ( copy(pRet,28,2) = '00') then  //FORMA AO QUAL É VINCULADO ='00'
                    begin
                        //imprime cabeçalho não fiscal

                        sRet := ImpCabecNF();
                        if sRet = '0' then
                        begin
                            //Imprime o Início do cupom não fiscal
                            iRet := fFuncEcfInicCupomNFiscal(1);

                            if iRet = 0 then
                            begin
                                //imprime o valor do suprimento
                                iRet := fFuncEcfVendaItem78(Pansichar(sTexto),Pansichar(sValor), i);

                                if iRet = 0 then
                                begin
                                    // Faz o Fechamento do cupom
                                    iRet := fFuncEcfFimTrans('');

                                    if iRet = 0 then
                                    begin
                                        result := '0';
                                        break;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end
    else if Tipo = 3 then
    begin

        sValor :=  FormataTexto(Valor,21,2,2);

        sNomeCNF := SigaLojaINI('SCHALTER.INI', 'Sangria', 'NomeCNF', 'SANGRIA');
        sTexto   := SigaLojaINI('SCHALTER.INI', 'Sangria', 'Texto',   'SANGRIA');  // Limitado a 70 caracteres

        sFormas :='DINHEIRO';

        // Le as condicoes de pagamento cadastradas na impressora e guarda no array aFormas
        sRet := LeCondPag;
        sRet := Copy(sRet, 3, Length(sRet));
        MontaArray(sRet, aFormas);

        // Processo de Sangria: Na Schalter para fazer sangria é preciso criar uma forma de pagamento
        // com o nome de sangria ("ou outro qualquer") e fazer a transferência de valores da forma de
        // pagamento que deseja sangrar para a forma de pagamento Sangria.

        // Monta um array auxiliar com os parametros:
        //                                - Pagamento de Retirada;
        //                                - Pagamento de Depósito;


        // Verifica se a existe a condição de pagamento para sangria
        // conforme configuração do arquivo schalter.ini na Seção: Sangria.

        //AchaPagto( aAuxiliar[i],aFormas ) <> '00'
        //sValor := FormataTexto(aAuxiliar[i+1],10,2,2);
        sPosDep := AchaPagto( sNomeCNF,aFormas );
        sPosRet := AchaPagto( sFormas,aFormas );

        //----------------------------------------------------------------------
        // Verifica antes de executar o comando
        //----------------------------------------------------------------------
        // Pesquisando antes de efetuar a transferência...

        pRet := fFuncEcfStatusPayTypes( strToInt(sPosRet) );
        pAux := StrPos(pRet, 'Erro');

        if pAux = nil then
        begin
            sRet := copy(pRet, 2, 1);
            if sRet = 'N' then
            begin
                //showmessage('O pagamento de retirada não está ativo.');
                result := '1';
            end
            else
            begin
                pRet := fFuncEcfStatusPayTypes( strtoint(sPosDep) );
                pAux := StrPos(pRet, 'Erro');

                if pAux = nil then
                begin
                    sRet := copy(pRet, 2, 1);
                    if sRet = 'N' then
                    begin
                        //showmessage('O pagamento de depósito não está ativo.');
                        result := '1';
                    end
                    else
                    begin
                        iRet := fFuncEcfPagTransfer(Pansichar(sPosRet), Pansichar(sPosDep), Pansichar(sValor) );

                        if iRet <> 0 then
                        begin
                            if (iRet = 70) then
                            begin
                                //showmessage('Verifique o valor do montante de transferência e ' +
                                //            'certifique-se de que há, no mínimo, este valor na ' +
                                //            'forma de pagamento de retirada');
                                result := '1|';
                            end
                            else
                            begin
                                result := '1';
                            end;
                        end
                        else
                        begin
                            // Faz o Fechamento do cupom
                            iRet := fFuncEcfFimTrans('');

                            if iRet = 0 then
                                result := '0'
                            else
                                Result := '1';
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            //rets :=  strtoint( copy(retStatPay,7,3) );
            result := '1';
        end;
    end;
end;

//----------------------------------------------------------------------------

function TImpSchalter.ReImpCupomNaoFiscal( Texto:AnsiString ):AnsiString;
begin
    //para posterior implementacao
    result := '1';
end;

//----------------------------------------------------------------------------
function TImpSchalter.Gaveta:AnsiString;
var
  iRet : Integer;
begin
  iRet := fFuncEcfAbreGaveta();

  If iRet >= 0 then
    Result := '0'
  Else
    Result := '1';

end;

//----------------------------------------------------------------------------

function TImpSchalter.RecebNFis( Totalizador, Valor, Forma:AnsiString ): AnsiString;

    function PegaRegistro( sCondicao:AnsiString):AnsiString;
    Var
        sRet    : AnsiString;
        aFormas : TaString;
        i       : Integer;
        pRet : PChar;     // Retorna o Compravante não fiscal e suas propriedades
        pAux : PChar;     // Verifica se o pRet retornou algum erro

    Begin
        // Lendo todos as descrições dos registradores.
        // Busca  em que posição está cadastrado o documento não fiscal
        Result:= '';
        for i := 0 to 19 do
	    begin
            pRet := fFuncEcfStatusDocsNFs( i );

	        pAux := StrPos(pRet, 'Erro');
	        if pAux = nil then
	        begin

                //Verifica se o comprovante não fiscal cadastrado no Schalter.ini, está cadastrado
                if UpperCase(  trim(copy(pRet,3,20)) ) = UpperCase ( trim(sCondicao) ) then
                begin
                    Result:= intToStr( i ) ;
                    break;
                end;
            end;
        end;
   End;
//**********************************************************************************************************
Var
  sRet      : AnsiString;
  iRet      : Integer;
  i         : Integer;
  aFormas   : TaString;
  sFormas   : AnsiString;
  sPos      : AnsiString;
  iTamanho  : Integer;
  sCondicao : AnsiString;
  aPgto     : TaString;
  sNomeCNF  : AnsiString;
  sTexto    : AnsiString;
begin

    result := '1|';

    Valor     := FormataTexto(Valor,9,2,2);
    sCondicao := Forma;

    // Le as condicoes de pagamento
    sRet := LeCondPag;
    sRet := Copy(sRet, 3, Length(sRet));
    MontaArray( sRet, aFormas );

    sNomeCNF:= SigaLojaINI('SCHALTER.INI', 'Recebimento', 'NomeCNFNV', 'RECEBIMENTO');
    sTexto    := SigaLojaINI('SCHALTER.INI', 'Recebimento', 'Texto',   'RECEBIMENTO');  // Limitado a 70 caracteres

    sPos:=PegaRegistro( sNomeCNF );

    if Trim(sPos) <> '' then
    begin
      //Imprime Cabeçalho Não Fiscal
      sRet := ImpCabecNF();
      If sRet = '0' then
      begin
        //Inicializa cupom não fiscal
        iRet := fFuncEcfInicCupomNFiscal(1);
        if iRet = 0 then
        begin
          //Registra o ítem no cupom não fiscal não vinculado
          iRet := fFuncEcfVendaItem78(Pansichar(sTexto),Pansichar(valor), strToInt(sPos) );
          if iRet = 0 then
          Begin
             iRet := fFuncEcfPagamento( 0, Pansichar( AchaPagto( Forma, aFormas ) ), Pansichar( FormataTexto( Valor, 10, 2, 0 ) ), 0);
             If sRet = '0' Then
            Begin
              sRet := FechaCupomNaoFiscal;
              result := '0|';
            End;
          end;
        end;
      end;
    end;
end;

//------------------------------------------------------------------------------

function TImpSchalter.TextoNaoFiscal( Texto:AnsiString;Vias:Integer ):AnsiString;
var
  i: Integer;
  sTexto  : AnsiString;
  iRet    : Integer;
  sLinha  :AnsiString;
Begin
  Result := '0';
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
  // Laço para imprimir toda a mensagem
  While ( Trim(Texto)<>'' ) do
      Begin
        sLinha := '';
         // Laço para pegar 40 caracter do Texto
         If Pos(#10,Copy(Texto,1,41))>1 then
         begin
            sLinha := Copy(Texto,1, Pos(#10,Texto)-1);
            Texto  := Copy(Texto,Pos(#10,Texto)+1, Length(Texto));
            iRet   := fFuncEcfImpLinha( Pansichar( sLinha )  );

         End
         Else If Pos(#10,Copy(Texto,1,41))=1 then
         Begin
            Texto := Copy(Texto,2,Length(Texto));
            iRet := fFuncEcfImpLinha( Pansichar( Space( 40 ) )  );
         End
         Else
         Begin
            sLinha := Copy(Texto,1, 40);
            Texto  := Copy(Texto,41, Length(Texto));
            iRet   := fFuncEcfImpLinha( Pansichar( sLinha )  );
         End;

         // Ocorreu erro na impressão do cupom
         if iRet <> 0 then
         Begin
            Result := '1';
            Break;
         End;
      End;
end;

//----------------------------------------------------------------------------
function TImpSchalter.RelGerInd( cIndTotalizador , cTextoImp : AnsiString ; nVias : Integer; ImgQrCode: AnsiString) : AnsiString;
begin
  Result := RelatorioGerencial(cTextoImp , nVias,ImgQrCode);
end;

//----------------------------------------------------------------------------
function TImpSchalter.RelatorioGerencial( Texto:AnsiString ;Vias:Integer; ImgQrCode: AnsiString):AnsiString;
var
  iRet, i : Integer;
  sTexto  : AnsiString;
  sLinha  :AnsiString;

begin

    Result := '0';

    // Fecha o cupom não fiscal
    iRet := fFuncEcfFimTrans('');

    //--------------------------------------------------------------------------
    // Para imprimir o Relatório gerencial, deve se antes emitir uma leitura X
    // então logo após o ECF deixa imprir  texto livre durante 10 minutos.
    //--------------------------------------------------------------------------
    iRet := fFuncEcfLXGerencial('');

    if iRet = 0 then
    begin

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
            iRet   := fFuncEcfImpLinha( Pansichar( sLinha )  );

            // Ocorreu erro na impressão do cupom
            if iRet<>0 then
            Begin
                Result := '1';
                // Fecha o cupom não fiscal
                iRet := fFuncEcfFimTrans('');
                Exit;
            End;
        End;
    end
    else
    begin
        // Fecha o cupom não fiscal
        Result := '1';
        iRet := fFuncEcfFimTrans('');
    end;

    // Fecha o cupom não fiscal
    iRet := fFuncEcfFimTrans('');

    if iRet <> 0 then
        result := '1';

end;

//----------------------------------------------------------------------------
function TImpSchalter.ImprimeCodBarrasITF( Cabecalho , Codigo, Rodape : AnsiString ; Vias : Integer):AnsiString;

begin
  WriteLog('SIGALOJA.LOG','Comando não suportado para este modelo!');
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpSchalter.FechaCupomNaoFiscal: AnsiString;
var
  iRet : Integer;
begin
    // Faz o Fechamento do cupom
    iRet := fFuncEcfFimTrans('');

    If iRet = 0 then
        Result := '0'
    Else
        Result := '1';
end;

//----------------------------------------------------------------------------
function TImpSchalter.AdicionaAliquota( Aliquota:AnsiString; Tipo:Integer ): AnsiString;
// Tipo = 1 - ICMS
// Tipo = 2 - ISS
var
  iRet  : Integer;
  i     : Integer;
  pRet  : PChar;
  sAliq : AnsiString;
  sPos  : AnsiString;
  sTipo : AnsiString;

begin

    result := '1';

    If Tipo=1 then sTipo := 'T';    //T significa Aliquota de ICMS
    If Tipo=2 then sTipo := 'S';    //S significa Aliquota de ISS

    Aliquota := FormataTexto(Aliquota,4,2,2);

    //--------------------------------------------------------------------------
    // Procura uma posição livre na tabela para inserir a nova alíquota;
    //--------------------------------------------------------------------------
    for i := 1 to 15 do
    begin
        pRet := fFuncEcfStatusAliquotas( i );
        if Copy(pRet,1,5) <> 'Erro:' then
        begin
            sAliq := copy(pRet,3,5);
            if (FormataTexto(sAliq,4,2,2) = '0000') then
            begin
                sPos :=  FormataTexto(intToStr(i),2,0,2);
                iRet := fFuncEcfCargaAliqSelect ( Pansichar(sPos) , Pansichar(sTipo), Pansichar( Aliquota) );
                If iRet = 0 then
                    Result := '0'
                Else
                    Result := '1';

                exit;
            end;
        end;
    end;
end;

//----------------------------------------------------------------------------
function TImpSchalter.GravaCondPag( condicao:AnsiString ) : AnsiString;
var
    iRet : Integer;
begin
    ShowMessage(' Para cadastrar Condição de pagamento, somente com intervenção técnica.');
    Result := '0';

end;

//------------------------------------------------------------------------------

function TImpSchalter.HorarioVerao( Tipo:AnsiString ):AnsiString;
var
iRet    : Word;
iDia    : Word;
iMes    : Word;
iAno    : Word;
iHor    : Word;
iMin    : Word;
iSeg    : Word;
tData   : TDateTime;
sRet    : AnsiString;

begin

    result :='1';

    //Armazena a Data
    sRet := StatusImp(2);
    if Copy(sRet,1,4) <> 'Erro' then;
    begin
        iDia  := strToInt( copy(sRet,3,2) );
        iMes  := strToInt( copy(sRet,6,2) );
        iAno  := strToInt( copy(sRet,9,2) );


        //Armazena a hora
        sRet := StatusImp(1);
        if Copy(sRet,1,4) <> 'Erro' then;
        begin
            iHor  := strToInt( copy(sRet,3,2) );
            iMin  := strToInt( copy(sRet,6,2) );
            iSeg  := strToInt( copy(sRet,9,2) );
        end;

        if Tipo = '+' then
            iHor := iHor + 1
        else
            iHor := iHor - 1;

        iRet := fFuncEcfAcertaData (iDia, iMes, iAno, iHor, iMin, iSeg );
        if iRet = 0 then
            Result := '0'
        else
            Result := '1';

    end;

end;



//------------------------------------------------------------------------------

function TImpSchalter.TotalizadorNaoFiscal( Numero,Descricao:AnsiString ):AnsiString;
begin

    ShowMessage(' Para cadastrar Totalizador não Fiscal, somente com intervenção técnica.');
    Result := '1';

end;

//------------------------------------------------------------------------------

function TImpSchalter.Autenticacao( Vezes:Integer; Valor,Texto:AnsiString ): AnsiString;
var
  iRet : Integer;
  i    : Integer;
begin
    result := '1';

    for i:=0 to 5 do
    begin
        iRet := fFuncEcfAutentica(Pansichar(Texto));
        if iRet = 0 then
        begin
            Result := '0';
            break;
        end
        Else
        begin
            ShowMessage('Posicione o papel para autenticação e pressione OK.');
            Result := '1';
        end;
    end;

    if iRet <> 0 then
    begin
        //------------------------------
        // Faz o cancelamento da venda -
        //------------------------------
        iRet := fFuncEcfCancVenda('');
    end
    else
    begin
        // Faz o Fechamento do cupom
        iRet := fFuncEcfFimTrans('');
    end

end;


//---------------------------------------------------------------------------
function TImpSchalter.ImpostosCupom(Texto: AnsiString): AnsiString;
begin
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpSchalter.DownloadMFD( sTipo, sInicio, sFinal : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpSchalter.GeraRegTipoE( sTipo, sInicio, sFinal, sRazao, sEnd, sBinario : AnsiString ):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;


//------------------------------------------------------------------------------
function TImpSchalter.LeTotNFisc:AnsiString;
begin
        Result := '0|-99';
end;

//------------------------------------------------------------------------------
function TImpSchalter.DownMF(sTipo, sInicio, sFinal : AnsiString):AnsiString;
Begin
  MessageDlg( MsgIndsMFD, mtError,[mbOK],0);
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpSchalter.RedZDado( MapaRes : AnsiString): AnsiString ;
Begin
  Result := '1';
End;

//------------------------------------------------------------------------------
function TImpSchalter.IdCliente( cCPFCNPJ , cCliente , cEndereco : AnsiString ): AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - IdCliente : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpSchalter.EstornNFiscVinc( CPFCNPJ , Cliente , Endereco , Mensagem , COOCDC : AnsiString ) : AnsiString;
begin
WriteLog('sigaloja.log', DateTimeToStr(Now)+' - EstornNFiscVinc : Comando Não Implementado para este modelo');
Result := '0|';
end;

//------------------------------------------------------------------------------
function TImpSchalter.ImpTxtFis(Texto : AnsiString) : AnsiString;
begin
 GravaLog(' - ImpTxtFis : Comando Não Implementado para este modelo');
 Result := '0';
end;

//------------------------------------------------------------------------------
Function TrataTags( Mensagem : AnsiString ) : AnsiString;
var
  cMsg : AnsiString;
begin
cMsg := Mensagem;
cMsg := RemoveTags( cMsg );
Result := cMsg;
end;

//------------------------------------------------------------------------------
function TImpSchalter.GrvQrCode(SavePath, QrCode: AnsiString): AnsiString;
begin
GravaLog(' GrvQrCode - não implementado para esse modelo ');
Result := '0';
end;

(*initialization
  //Versão de Eprom 3.03
  RegistraImpressora('SCHALTER SCFI IE - V. 03.03' , TImpSchalter, 'BRA', '340302');
  RegistraImpressora('SCHALTER SCFI IE - V. 03.06' , TImpSchalter, 'BRA', '340304');  *)
end.

