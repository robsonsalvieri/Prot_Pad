unit unt_balanca;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, jpeg, ExtCtrls;

type
  TFrmTstBalToledo = class(TForm)
    btnComunica: TButton;
    ed_peso: TEdit;
    btnPeso: TButton;
    btnFechaComu: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cbParida: TComboBox;
    cbdatab: TComboBox;
    cbveloci: TComboBox;
    cbporta: TComboBox;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure btnComunicaClick(Sender: TObject);
    procedure btnFechaComuClick(Sender: TObject);
    procedure btnPesoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmTstBalToledo: TFrmTstBalToledo;
  bPortaCom : Boolean;
  fHandle : THandle;            // handle da P05.DLL
  fFuncToledo_AbrePorta         : function (const Porta,BaudRate,DataBits,Paridade:Integer): Integer; StdCall;
  fFuncToledo_FechaPorta        : function (): Integer; StdCall;
  fFuncToledo_PegaPeso          : function (const OpcaoEscrita:integer;Peso,Local:Pchar):Integer; StdCall;

implementation

{$R *.DFM}

procedure TFrmTstBalToledo.FormCreate(Sender: TObject);
var
  aFunc: Pointer;

begin
fHandle := LoadLibrary( 'P05.dll' );

If fHandle <> 0 then
begin
  aFunc := GetProcAddress(fHandle,'AbrePorta');
  fFuncToledo_AbrePorta := aFunc;

  aFunc := GetProcAddress(fHandle,'FechaPorta');
  fFuncToledo_FechaPorta := aFunc;

  aFunc := GetProcAddress(fHandle,'PegaPeso');
  fFuncToledo_PegaPeso := aFunc;
end
else
begin
  ShowMessage('DLL P05.DLL não encontrada');
end;

end;

procedure TFrmTstBalToledo.btnComunicaClick(Sender: TObject);
var
  iRet,iPorta,iBaud,iDtBits,iParid : Integer;
begin
iPorta := cbporta.ItemIndex+1;
iBaud  := cbveloci.ItemIndex;
iDtBits:= cbdatab.ItemIndex;
iParid := cbParida.ItemIndex;

If iPorta <= 0
then iPorta := 1;

If iBaud < 0
then iBaud := 0;

If iDtBits < 0
then iDtBits := 0;

If iParid < 0
then iParid := 0;

iRet := fFuncToledo_AbrePorta(iPorta,iBaud,iDtBits,iParid);
If iRet <> 1
then ShowMessage('Erro na abertura da porta')
else begin
       ShowMessage('Comunicação OK');
       bPortaCom := True;
     end;
end;

procedure TFrmTstBalToledo.btnFechaComuClick(Sender: TObject);
var
  iRet : Integer;
begin
iRet := fFuncToledo_FechaPorta;
if iRet <> 1
then ShowMessage('Erro no fechamento')
else ShowMessage('Porta Fechada');

bPortaCom := False;
end;

procedure TFrmTstBalToledo.btnPesoClick(Sender: TObject);
var
  iRet : Integer;
  Peso : String;
  Ppeso: PChar;
begin

If bPortaCom then
begin
  SetLength(Peso,8);
  Ppeso := PChar(Peso);
  iRet := fFuncToledo_PegaPeso(1,Ppeso,'');
  if iRet <> 1
  then ShowMessage('Erro no peso')
  else ed_peso.Text := Ppeso;
end
else
begin
  ShowMessage('Atenção, a comunicação com a balança não está aberta');
end;

end;

end.
