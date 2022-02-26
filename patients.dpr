program patients;

uses
  Forms,
  Windows,
  splash_frm in 'splash_frm.pas' {slpash_frm},
  patients_search in 'patients_search.pas' {Form1},
  Patients_info in 'Patients_info.pas' {PatientsInfo},
  Surgery_info in 'Surgery_info.pas' {SurgeryInfo},
  followup_info in 'followup_info.pas' {FollowUpInfo},
  Image_Viewer in 'Image_Viewer.pas' {ImageViewer},
  about in 'about.pas' {AboutBox},
  Easter_Egg in 'Easter_Egg.pas' {EasterEgg},
  VVersionInfo in 'VVersionInfo.pas';

{$R *.res}

begin
  slpash_frm := Tslpash_frm.Create(Application);
  try
    slpash_frm.Show;
    Application.Initialize;
//    Application.MainFormOnTaskbar := True;
    Application.Title := 'Αρχείο Ασθενών  (401 NΡΧ)';
    slpash_frm.Update;
    sleep(2000); // Or a delay command.
    Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TPatientsInfo, PatientsInfo);
  Application.CreateForm(TSurgeryInfo, SurgeryInfo);
  Application.CreateForm(TFollowUpInfo, FollowUpInfo);
  Application.CreateForm(TImageViewer, ImageViewer);
//  Application.CreateForm(TVersionInfo, VersionInfo);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TEasterEgg, EasterEgg);
  slpash_frm.Hide;
  finally
    slpash_frm.Free;
  end;
  Application.Run
end.
