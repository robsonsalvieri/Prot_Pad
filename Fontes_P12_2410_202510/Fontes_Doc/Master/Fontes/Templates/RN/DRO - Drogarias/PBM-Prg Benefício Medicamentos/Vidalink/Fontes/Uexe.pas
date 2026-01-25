unit Uexe;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    txtEan: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    txtInfo: TEdit;
    Label3: TLabel;
    lblTempo: TLabel;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  init:boolean;
  
implementation

function RetProdProtheus(sCateg, sKey : AnsiString; byTrataPeso,
        byDeciPeso, byArredonda, byDescr40 : Byte;
        var ptrBuffProd: AnsiString; prtBuffAssoc : AnsiString ): ShortInt; stdcall; external 'TotvsVida.dll';
procedure ShowDLLForm; external 'TotvsVida.dll';
procedure HideDLLForm; external 'TotvsVida.dll';
procedure SetApplicationHandle(Handle: HWnd); external 'TotvsVida.dll';
procedure Desconectar; external 'TotvsVida.dll';

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if not init then begin
     SetApplicationHandle(Application.Handle);
     init:=true;
  end;
  ShowDLLForm;
end;


procedure TForm1.Button2Click(Sender: TObject);
var
  ptrBuffProd : AnsiString;
  ptrBuffAssoc : String;
  intRetorno : ShortInt;
  t : Tdatetime;
begin
  if not init then begin
     SetApplicationHandle(Application.Handle);
     init:=true;
  end;
  t := now;
  txtInfo.Text := 'Buscando. Aguarde...';
  ptrBuffProd := '';
  intRetorno := RetProdProtheus('0', txtEan.Text, 0, 0, 0, 0, ptrBuffProd, ptrBuffAssoc);

  if intRetorno = 0 then
    begin
       txtInfo.Text := ptrBuffProd;
    end
  else
    begin
       txtInfo.Text := 'Produto não encontrado';
    end;
  t := now - t;
  lblTempo.Caption := FormatDateTime('hh:nn:ss',t);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   Desconectar;
end;

end.
