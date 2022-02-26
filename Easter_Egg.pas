unit Easter_Egg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg;

type
  TEasterEgg = class(TForm)
    Image1: TImage;
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EasterEgg: TEasterEgg;

implementation

uses about;

{$R *.dfm}

procedure TEasterEgg.Image1Click(Sender: TObject);
begin
  About.AboutBox.SetFocus;
  EasterEgg.Close;
end;

end.
