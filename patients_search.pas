unit patients_search;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GIFImg, ExtCtrls, Grids, DBGrids, StdCtrls, ABSMain, DB, ADODB, jpeg,
  Mask, ComCtrls, Filectrl, Buttons;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Image2: TImage;
    DBGrid1: TDBGrid;
    S_Surname: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    S_Name: TEdit;
    S_Diagnose: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    S_DiagnoseE: TEdit;
    dbPatientsSearch: TABSDatabase;
    QPatientsSearch: TABSQuery;
    DataSource1: TDataSource;
    Label6: TLabel;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label7: TLabel;
    CheckBox1: TCheckBox;
    QPatientDelete: TABSQuery;
    Label8: TLabel;
    StatusBar1: TStatusBar;
    QPatientsStatus: TABSQuery;
    Button1: TBitBtn;
    Button2: TBitBtn;
    Button3: TBitBtn;
    LicenceName: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure S_SurnameChange(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure SurgeryFromChange(Sender: TObject);
    procedure SurgeryToChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  LicenceNameText: string;

implementation

uses splash_frm, Patients_info, about;

{$R *.dfm}

procedure DelTree(const Directory: TFileName);
  var
    DrivesPathsBuff: array[0..1024] of char;
    DrivesPaths: string;
    len: longword;
    ShortPath: array[0..MAX_PATH] of char;
    dir: TFileName;
  procedure rDelTree(const Directory: TFileName);
  // Recursively deletes all files and directories
  // inside the directory passed as parameter.
  var
    SearchRec: TSearchRec;
    Attributes: LongWord;
    ShortName, FullName: TFileName;
    pname: pchar;
  begin
    if FindFirst(Directory + '*', faAnyFile and not faVolumeID,
       SearchRec) = 0 then begin
      try
        repeat // Processes all files and directories
          if SearchRec.FindData.cAlternateFileName[0] = #0 then
            ShortName := SearchRec.Name
          else
            ShortName := SearchRec.FindData.cAlternateFileName;
          FullName := Directory + ShortName;
          if (SearchRec.Attr and faDirectory) <> 0 then begin
            // It's a directory
            if (ShortName <> '.') and (ShortName <> '..') then
              rDelTree(FullName + '\');
          end else begin
            // It's a file
            pname := PChar(FullName);
            Attributes := GetFileAttributes(pname);
            if Attributes = $FFFFFFFF then
              raise EInOutError.Create(SysErrorMessage(GetLastError));
            if (Attributes and FILE_ATTRIBUTE_READONLY) <> 0 then
              SetFileAttributes(pname, Attributes and not
                FILE_ATTRIBUTE_READONLY);
            if Windows.DeleteFile(pname) = False then
              raise EInOutError.Create(SysErrorMessage(GetLastError));
          end;
        until FindNext(SearchRec) <> 0;
      except
        FindClose(SearchRec);
        raise;
      end;
      FindClose(SearchRec);
    end;
    if Pos(#0 + Directory + #0, DrivesPaths) = 0 then begin
      // if not a root directory, remove it
      pname := PChar(Directory);
      Attributes := GetFileAttributes(pname);
      if Attributes = $FFFFFFFF then
        raise EInOutError.Create(SysErrorMessage(GetLastError));
      if (Attributes and FILE_ATTRIBUTE_READONLY) <> 0 then
        SetFileAttributes(pname, Attributes and not
          FILE_ATTRIBUTE_READONLY);
      if Windows.RemoveDirectory(pname) = False then begin
        raise EInOutError.Create(SysErrorMessage(GetLastError));
      end;
    end;
  end;
  // ----------------
  begin
    DrivesPathsBuff[0] := #0;
    len := GetLogicalDriveStrings(1022, @DrivesPathsBuff[1]);
    if len = 0 then
      raise EInOutError.Create(SysErrorMessage(GetLastError));
    SetString(DrivesPaths, DrivesPathsBuff, len + 1);
    DrivesPaths := Uppercase(DrivesPaths);
    len := GetShortPathName(PChar(Directory), ShortPath, MAX_PATH);
    if len = 0 then
      raise EInOutError.Create(SysErrorMessage(GetLastError));
    SetString(dir, ShortPath, len);
    dir := Uppercase(dir);
    rDelTree(IncludeTrailingBackslash(dir));
end;

function CreateSQLString:String;
var
  sqlstring,sqlstre,sqljoin : string;
begin
  sqljoin := '';
  if (Form1.S_Surname.text <> '') then
    begin
      sqlstre := '([Last Name] Like "%' + Form1.S_Surname.Text + '%")';
    end;
  if (Form1.S_Name.text <> '') then
    begin
      if sqlstre <> '' then
        sqlstre := sqlstre + ' AND ';
      sqlstre := sqlstre + '([First Name] Like "%' + Form1.S_Name.Text + '%")';
    end;
  if (Form1.S_Diagnose.text <> '') then
    begin
      if sqlstre <> '' then
        sqlstre := sqlstre + ' AND ';
      sqlstre := sqlstre + '([Diagnose] =' + inttostr(Form1.S_Diagnose.ItemIndex) + ')';
    end;
  if (Form1.S_DiagnoseE.text <> '') then
    begin
      if sqlstre <> '' then
        sqlstre := sqlstre + ' AND ';
      sqlstre := sqlstre + '([Diagnose Extra] Like "%' + Form1.S_DiagnoseE.Text + '%")';
    end;
  if (Form1.CheckBox1.Checked) then
    begin
      sqljoin := ' LEFT JOIN [Surgery Info] ON [Patients Info].[Patient Id]=[Surgery Info].[Patient Id] ';
      if sqlstre <> '' then
        sqlstre := sqlstre + ' AND ';
      sqlstre := sqlstre + '([Surgery Info].[Surgery Date] BETWEEN "' + datetostr(Form1.DateTimePicker1.Date) + '" AND "' + datetostr(Form1.Datetimepicker2.Date) + '")';
    end;
  if sqlstre <> '' then
    sqlstre := ' WHERE ' + sqlstre;
  sqlstring := 'SELECT [Patient Id],[Last Name],[First Name],[Diagnose Extra] FROM [Patients Info]' + sqljoin + sqlstre + ' ORDER BY [Last Name];';
  Result := sqlstring;
end;

procedure TForm1.S_SurnameChange(Sender: TObject);
begin
  QPatientsSearch.SQL.Clear;
  QPatientsSearch.SQL.Add(CreateSQLString());
  QPatientsSearch.Active := True;
  if QPatientsSearch.RecordCount > 0 then
    begin;
      Button1.Enabled := True;
      Button2.Enabled := True;
    end
  else
    begin;
      Button1.Enabled := False;
      Button2.Enabled := False;
    end;
  Statusbar1.Panels.Items[0].Text := '  Ασθενείς :     ' + inttostr(QPatientsSearch.RecordCount) + ' / ' + inttostr(QPatientsStatus.RecordCount);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  DBGrid1DblClick(Form1);
end;

procedure TForm1.Button2Click(Sender: TObject);
var patientidstr : string;
    queryold: string;
    folderpath: string;
begin
  if QPatientsSearch.RecordCount > 0 then
    begin;
      patientIdStr := DBGrid1.Fields[0].AsString;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '';
      queryold := QPatientsSearch.SQL.Text;
      QPatientDelete.Active := False;
      QPatientDelete.SQL.Text := 'DELETE FROM [Surgery Info] WHERE [Patient Id] = "' + patientidstr + '";';
      QPatientDelete.ExecSQL;
      QPatientDelete.SQL.Text := 'DELETE FROM [Surgical Images] WHERE [Patient Id] = "' + patientidstr + '";';
      QPatientDelete.ExecSQL;
      QPatientDelete.SQL.Text := 'DELETE FROM [FollowUp Info] WHERE [Patient Id] = "' + patientidstr + '";';
      QPatientDelete.ExecSQL;
      QPatientDelete.SQL.Text := 'DELETE FROM [FollowUp Images] WHERE [Patient Id] = "' + patientidstr + '";';
      QPatientDelete.ExecSQL;
      QPatientDelete.SQL.Text := 'DELETE FROM [PreSurgical Images] WHERE [Patient Id] = "' + patientidstr + '";';
      QPatientDelete.ExecSQL;
      QPatientDelete.SQL.Text := 'DELETE FROM [Patients Info] WHERE [Patient Id] = "' + patientidstr + '";';
      QPatientDelete.ExecSQL;
      if (DirectoryExists(folderpath)) Then
        deltree(folderpath);
      QPatientsSearch.SQL.Text := queryold;
      QPatientsSearch.Active := True;
      QPatientsStatus.Refresh;
      Statusbar1.Panels.Items[0].Text := '  Ασθενείς :     ' + inttostr(QPatientsSearch.RecordCount) + ' / ' + inttostr(QPatientsStatus.RecordCount);
    end;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
      patients_search.Form1.Hide;
      Patients_info.IsNewPatient := true;
      Patients_Info.PatientsInfo.Show;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if Checkbox1.Checked then
    begin
      Datetimepicker1.Enabled := true;
      Datetimepicker2.Enabled := true;
    end
  else
    begin
      Datetimepicker1.Enabled := false;
      Datetimepicker2.Enabled := false;
    end;
  S_SurnameChange(Form1);
end;

procedure TForm1.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  if QPatientsSearch.RecordCount > 0 then
    begin
      Button1.Enabled := True;
      Button2.Enabled := True;
    end
  else
    begin
      Button1.Enabled := False;
      Button2.Enabled := False;
  end;
end;

procedure TForm1.DBGrid1DblClick(Sender: TObject);
begin
  if QPatientsSearch.RecordCount > 0 then
    begin;
      patients_search.Form1.Hide;
      Patients_info.IsNewPatient := false;
      Patients_info.PatientIdStr := DBGrid1.Fields[0].AsString;
      Patients_info.PatientsInfo.QPatientsInfo.ReadOnly := true;
      Patients_info.PatientsInfo.QPatientsInfo.SQL.Text := 'SELECT * FROM [Patients Info] WHERE [Patient Id] = "' + DBGrid1.Fields[0].AsString + '";';
      Patients_info.PatientsInfo.QPatientsInfo.Active :=true;
      Patients_info.PatientsInfo.QSurgerySearch.ReadOnly := true;
      Patients_info.PatientsInfo.QSurgerySearch.SQL.Text := 'SELECT * FROM [Surgery Info] WHERE [Patient Id] = "' + DBGrid1.Fields[0].AsString + '";';
      Patients_info.PatientsInfo.QSurgerySearch.Active := true;
      Patients_info.PatientsInfo.QFollowUpSearch.ReadOnly := true;
      Patients_info.PatientsInfo.QFollowUpSearch.SQL.Text := 'SELECT * FROM [FollowUp Info] WHERE [Patient Id] = "' + DBGrid1.Fields[0].AsString + '";';
      Patients_info.PatientsInfo.QFollowUpSearch.Active := true;
      Patients_info.PatientsInfo.QPreSurgicalImage.ReadOnly := true;
      Patients_info.PatientsInfo.QPreSurgicalImage.SQL.Text := 'SELECT * FROM [Presurgical Images] WHERE [Patient Id] = "' + DBGrid1.Fields[0].AsString + '";';
      Patients_info.PatientsInfo.QPreSurgicalImage.Active := true;
      Patients_Info.PatientsInfo.Show;
    end;
end;

procedure TForm1.SurgeryFromChange(Sender: TObject);
begin
  S_SurnameChange(Form1);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  if not (DirectoryExists('.\data\')) Then
    CreateDir('.\data\');
  dbPatientsSearch.Connected :=true;
  QPatientsSearch.ReadOnly := true;
  QPatientsSearch.SQL.Text := 'SELECT * FROM [Patients Info]  ORDER BY [Last Name];';
  QPatientsSearch.Active := true;
  QPatientsStatus.ReadOnly := true;
  QPatientsStatus.SQL.Text := 'SELECT * FROM [Patients Info]  ORDER BY [Last Name];';
  QPatientsStatus.Active := true;
  Statusbar1.Panels.Items[0].Text := '  Ασθενείς :     ' + inttostr(QPatientsSearch.RecordCount) + ' / ' + inttostr(QPatientsStatus.RecordCount);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DBPatientssearch.Close;
  DBPatientssearch.CompactDatabase();
  application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DateTimePicker2.Date := Date;
  LicenceNameText := 'Χρυσανθακόπουλος Π.';
end;

procedure TForm1.FormShow(Sender: TObject);
begin
      Form1.Caption := 'Αρχείο Ασθενών - Αναζήτηση  ( ' + patients_search.LicenceNameText + ' )';
      LicenceName.Caption := '( ' + patients_search.LicenceNameText + ' )';
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  AboutBox.Show;
end;

procedure TForm1.SurgeryToChange(Sender: TObject);
begin
  S_SurnameChange(Form1);
end;

end.
