unit FormSigtron;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, SIGDRCMLib_TLB;

type
  TFSigtron = class(TForm)
    SigDrCm1: TSigDrCm;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSigtron: TFSigtron;

implementation

{$R *.DFM}

end.
