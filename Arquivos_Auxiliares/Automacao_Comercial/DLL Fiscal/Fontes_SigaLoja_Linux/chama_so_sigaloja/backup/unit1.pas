unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type
    TExecutaSo = function(Id: integer; Params, Buff: PAnsiChar; BuffSize: Integer): Integer; cdecl;
    TGetVersaoDLL = function():string; cdecl;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btnAbreConexao: TButton;
    btnImpreTexto: TButton;
    btnFechaConexao: TButton;
    btnImprimeBitmap: TButton;
    btmImprimeCodigoBarras: TButton;
    btnAbreGavetaElgin: TButton;
    memTexto: TMemo;
    procedure btmImprimeCodigoBarrasClick(Sender: TObject);
    procedure btnAbreGavetaElginClick(Sender: TObject);
    procedure btnFechaConexaoClick(Sender: TObject);
    procedure btnImprimeBitmapClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnAbreConexaoClick(Sender: TObject);
    procedure btnImpreTextoClick(Sender: TObject);

    procedure LimpaMemo();

  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  LibHandle: TLibHandle;
  ExecutaSo: TExecutaSo;
  nRet: Integer;
  BuffSaida: String;

begin
  LibHandle:=LoadLibrary('./libsigaloja_linux.so');
  if LibHandle<>0 then
  begin
     Pointer(ExecutaSo) := GetProcAddress(LibHandle, 'ExecInClientDLL');
     nRet := ExecutaSo(999,'',@BuffSaida,77766);
     ShowMessage('1 - Retorno da so: ' + IntToStr(nRet));
     ShowMessage('2 - Retorno da so: ' + BuffSaida);
  end;
end;

procedure TForm1.btnFechaConexaoClick(Sender: TObject);
var
  LibHandle: TLibHandle;
  ExecutaSo: TExecutaSo;
  nRet: Integer;
  BuffSaida: String;
begin
  LimpaMemo();
  LibHandle:=LoadLibrary('./libsigaloja_linux.so');
  if LibHandle<>0 then
  begin
     Pointer(ExecutaSo) := GetProcAddress(LibHandle, 'ExecInClientDLL');
     nRet := ExecutaSo(132,'',@BuffSaida,77766);
     memTexto.Lines.Add('Retorno 1: ' + IntToStr(nRet));
     memTexto.Lines.Add('Retorno 2: ' + BuffSaida);
  end;

end;

procedure TForm1.btmImprimeCodigoBarrasClick(Sender: TObject);
var
  LibHandle: TLibHandle;
  ExecutaSo: TExecutaSo;
  nRet: Integer;
  BuffSaida: String;
begin
  LimpaMemo();
  LibHandle:=LoadLibrary('./libsigaloja_linux.so');
  if LibHandle<>0 then
  begin
     Pointer(ExecutaSo) := GetProcAddress(LibHandle, 'ExecInClientDLL');
     nRet := ExecutaSo(135,'2,3555464657,7,4,2',@BuffSaida,77766);
     memTexto.Lines.Add('Retorno 1: ' + IntToStr(nRet));
     memTexto.Lines.Add('Retorno 2: ' + BuffSaida);
  end;
end;

procedure TForm1.btnAbreGavetaElginClick(Sender: TObject);
var
  LibHandle: TLibHandle;
  ExecutaSo: TExecutaSo;
  nRet: Integer;
  BuffSaida: String;
begin
  LimpaMemo();
  LibHandle:=LoadLibrary('./libsigaloja_linux.so');
  if LibHandle<>0 then
  begin
     Pointer(ExecutaSo) := GetProcAddress(LibHandle, 'ExecInClientDLL');
     nRet := ExecutaSo(62,'',@BuffSaida,77766);
     memTexto.Lines.Add('Retorno 1: ' + IntToStr(nRet));
     memTexto.Lines.Add('Retorno 2: ' + BuffSaida);
  end;
end;

procedure TForm1.btnImprimeBitmapClick(Sender: TObject);
var
  LibHandle: TLibHandle;
  ExecutaSo: TExecutaSo;
  nRet: Integer;
  BuffSaida: String;
begin
  LimpaMemo();
  LibHandle:=LoadLibrary('./libsigaloja_linux.so');
  if LibHandle<>0 then
  begin
     Pointer(ExecutaSo) := GetProcAddress(LibHandle, 'ExecInClientDLL');
     nRet := ExecutaSo(134,'/home/londres/ADVPL/sigaloja_linux/imagem.jpg',@BuffSaida,77766);
     memTexto.Lines.Add('Retorno 1: ' + IntToStr(nRet));
     memTexto.Lines.Add('Retorno 2: ' + BuffSaida);
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  LibHandle: TLibHandle;
  GetVersaoDLL: TGetVersaoDLL;
  cRet: string;
begin
  LibHandle:=LoadLibrary('./libe1_impressora.so');
  if LibHandle <> 0 then
  begin
    Pointer(GetVersaoDLL) := GetProcAddress(LibHandle,'GetVersaoDLL');
    cRet := GetVersaoDLL();
  end
  else
  begin
     WriteLn('e1_impressora erro ao carregar.');
     FreeLibrary(LibHandle);
  end;

end;

procedure TForm1.btnAbreConexaoClick(Sender: TObject);
var
  LibHandle: TLibHandle;
  ExecutaSo: TExecutaSo;
  nRet: Integer;
  BuffSaida: String;
  Modelo, Porta, Parametros: string;
begin
  LimpaMemo();
  LibHandle:=LoadLibrary('./libsigaloja_linux.so');
  if LibHandle<>0 then
  begin
     Pointer(ExecutaSo) := GetProcAddress(LibHandle, 'ExecInClientDLL');
     Modelo := InputBox('Modelo da impressora','Informe o modelo da impressora, Exemplo: i9, i8','');
     Porta := InputBox('Porta da impressora','Informe a porta da impressora, exemplo: /dev/usb/lp0','');
     Parametros := PAnsiChar('1,' + Modelo + ',' + Porta + ',0');
     nRet := ExecutaSo(131,Parametros,@BuffSaida,77766); //elgin i9 - /dev/usb/lp0
     memTexto.Lines.Add('Retorno 1: ' + IntToStr(nRet));
     memTexto.Lines.Add('Retorno 2: ' + BuffSaida);
  end;
end;

procedure TForm1.btnImpreTextoClick(Sender: TObject);
var
  LibHandle: TLibHandle;
  ExecutaSo: TExecutaSo;
  nRet: Integer;
  BuffSaida: String;
  Cupom: string;
begin
  Cupom :=  '<bmp></bmp>' + #10 +
            '<ce>CNPJ: 53.113.791/0001-22 <b>TOTVS S.A.</b>' + #10 +
            'AV. BRAZ LEME,1000,SANTANA,SAO PAULO,AM' + #10 +
            'DOCUMENTO AUXILIAR DA' + #10 +
            '  NOTA FISCAL DE CONSUMIDOR ELETRÔNICA  </ce>' + #10 +
            '' + #10 +
            '<b><ce>Codigo          Desc. Qtd UN Vlr Unit. Vlr Total</ce></b>' + #10 +
            '<ce>8               NOTA FISCAL EMITIDA EM AMBIENTE </ce>' + #10 +
            '<ce>DE HOMOLOGACAO - SEM VALOR FISCAL               </ce>' + #10 +
            '<ce>                         1 UN   222,00     222,00</ce>' + #10 +
            '<ce>QTD. TOTAL DE ITENS                            1</ce>' + #10 +
            '<ce>VALOR TOTAL R$                            222,00</ce>' + #10 +
            '<ce>FORMA PAGAMENTO                 VALOR A PAGAR R$</ce>' + #10 +
            '<ce>Dinheiro                                  222,00</ce>' + #10 +
            '' + #10 +
            '<ce><b>Consulte pela Chave de Acesso em</b>' + #10 +
            '<c>http://www.sefaz.am.gov.br/nfce/consulta' + #10 +
            '1325 0553 1137 9100 0122 6511 7014 0000 2512 4152 3710 </c></ce>' + #10 +
            '' + #10 +
            '<ce><b>CONSUMIDOR NÃO IDENTIFICADO</b></ce>' + #10 +
            '' + #10 +
            '<ce><b>NFC-e n 14000025 Série 117 14/05/2025 21:17:53</b></ce>' + #10 +
            '<ce><b>Protocolo de Autorização: </b>113250012800873' + #10 +
            '<b>Data de Autorização: </b>14/05/2025 21:17:56</ce>' + #10 +
            '' + #10 +
            '<ce><c>EMITIDA EM AMBIENTE DE HOMOLOGAÇÃO – SEM VALOR FISCAL</c></ce>' + #10 +
            '' + #10 +
            '<ce><qrcode>http://homnfce.sefaz.am.gov.br/nfceweb/consultarNFCe.jsp?p=13250553113791000122651170140000251241523710|2|2|1|D62197113EAC94571E2F364F4C65426DDD1F6D74<lmodulo>4</lmodulo></qrcode></ce>' + #10 +
            '<ce>Obrigado! Volte Sempre!' + #10 +
            'Trib.Aprox R$: 0,00 Fed; R$: 0,00 Est; R$: 0,00 Mun.Fonte:IBPT</ce>' + #10 +
            '' + #10 +
            '<gui></gui>';

  LimpaMemo();
  LibHandle:=LoadLibrary('./libsigaloja_linux.so');
  if LibHandle<>0 then
  begin
     Pointer(ExecutaSo) := GetProcAddress(LibHandle, 'ExecInClientDLL');
     nRet := ExecutaSo(133,PAnsiChar(Cupom + '\0\0\0'),@BuffSaida,77766);
     memTexto.Lines.Add('Retorno 1: ' + IntToStr(nRet));
     memTexto.Lines.Add('Retorno 2: ' + BuffSaida);
  end;
end;

procedure TForm1.LimpaMemo();
begin
  memTexto.Clear;
end;

end.

