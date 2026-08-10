unit Message;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TfmMsg = class(TForm)
    Panel1: TPanel;
    laMsg: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMsg: TfmMsg;

implementation

{$R *.DFM}

end.
