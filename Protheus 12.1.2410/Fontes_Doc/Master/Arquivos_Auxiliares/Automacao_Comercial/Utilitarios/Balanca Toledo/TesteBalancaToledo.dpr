program TesteBalancaToledo;

uses
  Forms,
  unt_balanca in 'unt_balanca.pas' {FrmTstBalToledo};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Comunica Balanca Toledo';
  Application.CreateForm(TFrmTstBalToledo, FrmTstBalToledo);
  Application.Run;
end.
