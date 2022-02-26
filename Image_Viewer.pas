unit Image_Viewer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TImageViewer = class(TForm)
    Image1: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure ImageRefresh;

var
  ImageViewer: TImageViewer;
  imagestr : string;

implementation

uses patients_search;

{$R *.dfm}

procedure TImageViewer.FormShow(Sender: TObject);
begin
  ImageViewer.Caption :=  'Image Viewer   ( ' + patients_search.LicenceNameText + ' )';
  Image1.Picture.LoadFromFile(imagestr);
end;

procedure imagerefresh;
begin
  ImageViewer.Image1.Picture.LoadFromFile(imagestr);
end;

end.
