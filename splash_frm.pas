unit splash_frm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GIFImg, jpeg, ExtCtrls, StdCtrls, VVersionInfo;

type
  Tslpash_frm = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Timer1: TTimer;
    Label5: TLabel;
    Label6: TLabel;
    Label1: TLabel;
    Image3: TImage;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  slpash_frm: Tslpash_frm;

implementation

uses patients_search;

{$R *.dfm}

     function GetFileInfo(Infostr: string): string;
     var
        N, Len: DWORD;
        Buf: PChar;
        Value: PChar;
        Filename: String;
     begin
        Filename := (Application.ExeName);
        Result := '';
        N := GetFileVersionInfoSize(PChar(Filename), N);
        if N > 0 then
        begin
           Buf := AllocMem(N);
           GetFileVersionInfo(PChar(Filename), 0, N, Buf);
           if VerQueryValue(Buf,
                            PChar('StringFileInfo\040904E4\' + Infostr),
                            Pointer(Value), Len) then
              Result := Value;
           FreeMem(Buf, N);
        end;
     end;

procedure Tslpash_frm.FormShow(Sender: TObject);
  var VersionInfo: TVVersionInfo;
begin
//  Label5.Caption := Versioninfo.CompanyName;
end;

procedure Tslpash_frm.Timer1Timer(Sender: TObject);
begin
  Application.CreateForm(TForm1, Form1);
  patients_search.Form1.Visible:=True;
  timer1.Enabled := False ;
  slpash_frm.visible:=False;
end;

end.
