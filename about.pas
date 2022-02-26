unit About;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, VVersionInfo, jpeg, GIFImg;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    OKButton: TButton;
    Image2: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label1: TLabel;
    Image1: TImage;
    Image3: TImage;
    Label7: TLabel;
    Label8: TLabel;
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure OKButtonKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;
  VersionInfo: TVVersionInfo;

implementation

uses Easter_Egg, patients_search;

{$R *.dfm}

procedure TAboutBox.FormShow(Sender: TObject);
begin
  Label8.Caption := patients_search.LicenceNameText;
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
  AboutBox.Close;
end;

procedure TAboutBox.OKButtonKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [ssShift,ssAlt] then
    if Key = 48 then
      easteregg.Show;
end;

end.
 
