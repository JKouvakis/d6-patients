unit Patients_info;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ABSMain, DB, StdCtrls, DBCtrls, Mask, GIFImg, ExtCtrls, Grids,
  DBGrids, DBTables, jpeg, ComCtrls, ExtDlgs, FileCtrl;

type
  TPatientsInfo = class(TForm)
    Label2: TLabel;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Image2: TImage;
    Panel2: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Image3: TImage;
    Panel3: TPanel;
    Panel4: TPanel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    DataSource1: TDataSource;
    DBEdit4: TDBEdit;
    Label7: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    QSurgerySearch: TABSQuery;
    QFollowUpSearch: TABSQuery;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    QPreSurgicalImage: TABSQuery;
    DataSource4: TDataSource;
    QSurgerySearchSurgeryDescription: TMemoField;
    QSurgerySearchSurgery: TSmallintField;
    QPatientsInfo: TABSQuery;
    FLastName: TEdit;
    FFirstName: TEdit;
    FHomePhone: TEdit;
    FMobile: TEdit;
    FOtherPhone: TEdit;
    FAddress: TMemo;
    FCity: TEdit;
    FCountry: TEdit;
    FPostalCode: TEdit;
    FDiagnoseExtra: TMemo;
    FClinicalFindings: TMemo;
    QSurgerySearchDate: TDateField;
    QSurgerySearchSurgeryId: TIntegerField;
    QFollowUpSearchFollowUpId: TIntegerField;
    QFollowUpSearchFollowUpDate: TDateField;
    QFollowUpSearchTimefromSurgery: TStringField;
    QFollowUpSearchNextFollowUpDate: TDateField;
    QFollowUpSearchClinicalImage: TMemoField;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    OpenPictureDialog1: TOpenPictureDialog;
    QSurgeryDelete: TABSQuery;
    IntegerField1: TIntegerField;
    DateField1: TDateField;
    MemoField1: TMemoField;
    QSurgeryDeleteSurgeryType: TSmallintField;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Label12: TLabel;
    FFathersName: TEdit;
    LicenceName: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure DataSource3DataChange(Sender: TObject; Field: TField);
    procedure DataSource4DataChange(Sender: TObject; Field: TField);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure QSurgerySearchSurgeryDescriptionGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure DBGrid2DblClick(Sender: TObject);
    procedure QFollowUpSearchClinicalImageGetText(Sender: TField;
      var Text: string; DisplayText: Boolean);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure QSurgerySearchSurgeryGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure Button11Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PatientsInfo: TPatientsInfo;
  PatientIdStr : String;
  IsNewPatient : Boolean;

implementation

uses patients_search, Surgery_info, followup_info, Image_Viewer, about;

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

procedure FileCopy(const FileFrom, FileTo: string) ;
var
  FromF, ToF: file;
  NumRead, NumWritten: Integer;
  Buffer: array[1..2048] of Byte;
begin
  AssignFile(FromF, FileFrom) ;
  Reset(FromF, 1) ;
  AssignFile(ToF, FileTo) ;
  Rewrite(ToF, 1) ;
  repeat

   BlockRead(FromF, Buffer, SizeOf(Buffer), NumRead) ;
   BlockWrite(ToF, Buffer, NumRead, NumWritten) ;
  until (NumRead = 0) or (NumWritten <> NumRead) ;
  CloseFile(FromF) ;
  CloseFile(ToF) ;
end;

procedure SavePatient();
begin
    PatientsInfo.QPatientsInfo.Active := false;
    PatientsInfo.QPatientsInfo.Close;
    PatientsInfo.QPatientsInfo.SQL.Text := 'UPDATE [Patients Info] SET ' +
                            '[Last Name] = "' + PatientsInfo.FLastName.Text + '",' +
                            '[First Name] = "' + PatientsInfo.FFirstName.Text + '",' +
                            '[Father Name] = "' + PatientsInfo.FFathersName.Text + '",' +
                            '[Birthdate] = "' + datetostr(PatientsInfo.Datetimepicker1.date) + '",' +
                            '[Gender] = "' + inttostr(PatientsInfo.Combobox1.ItemIndex) + '",' +
                            '[Home Phone] = "' + PatientsInfo.FHomePhone.Text + '",' +
                            '[Mobile Phone] = "' + PatientsInfo.FMobile.Text + '",' +
                            '[Other Phone] = "' + PatientsInfo.FOtherPhone.Text + '",' +
                            '[Address] = "' + PatientsInfo.FAddress.Text + '",' +
                            '[City] = "' + PatientsInfo.FCity.Text + '",' +
                            '[Postal Code] = "' + PatientsInfo.FPostalCode.Text + '",' +
                            '[Country] = "' + PatientsInfo.FCountry.Text + '",' +
                            '[Registration Date] = "' + datetostr(PatientsInfo.Datetimepicker2.date) + '",' +
                            '[Clinical Findings] = "' + PatientsInfo.FClinicalFindings.Text + '",' +
                            '[Diagnose] = "' + inttostr(PatientsInfo.Combobox2.ItemIndex) + '",' +
                            '[Diagnose Extra] = "' + PatientsInfo.FDiagnoseExtra.Text + '" ' +
                            'WHERE [Patient Id] = "' + patientidstr + '";';
  PatientsInfo.QPatientsInfo.ExecSQL;
end;

procedure TPatientsInfo.Button10Click(Sender: TObject);
var
    folderpath: string;
    save_changes: boolean;
begin
  save_changes := true;

  if IsNewPatient then
    begin
      PatientsInfo.Enabled := false;
      If (MessageBox(0, 'The patient`s Data must be saved. Do u want to save the record?', 'Save Changes?', +mb_YesNo) = 6) then
        begin
          PatientsInfo.QPatientsInfo.ReadOnly := true;
          PatientsInfo.QPatientsInfo.SQL.Text := 'INSERT INTO [Patients Info] ([Registration Date]) VALUES ("' + datetostr(date) + '");';
          PatientsInfo.QPatientsInfo.ExecSQL;
          PatientsInfo.QPatientsInfo.SQL.Text := 'SELECT DISTINCT LASTAUTOINC ([Patients Info], [Patient Id]) FROM [Patients Info];';
          PatientsInfo.QPatientsInfo.ExecSQL;
          PatientsInfo.QPatientsInfo.Active :=true;
          PatientIdStr := PatientsInfo.QPatientsInfo.Fields.Fields[0].AsString;

          PatientsInfo.QPatientsInfo.ReadOnly := true;
          PatientsInfo.QPatientsInfo.SQL.Text := 'SELECT * FROM [Patients Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QPatientsInfo.Active :=true;
          PatientsInfo.QSurgerySearch.ReadOnly := true;
          PatientsInfo.QSurgerySearch.SQL.Text := 'SELECT * FROM [Surgery Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QSurgerySearch.Active := true;
          PatientsInfo.QFollowUpSearch.ReadOnly := true;
          PatientsInfo.QFollowUpSearch.SQL.Text := 'SELECT * FROM [FollowUp Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QFollowUpSearch.Active := true;
          PatientsInfo.QPreSurgicalImage.ReadOnly := true;
          PatientsInfo.QPreSurgicalImage.SQL.Text := 'SELECT * FROM [Presurgical Images] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QPreSurgicalImage.Active := true;
          IsNewPatient := false;
          save_changes := true;
        end
      else
        begin
          save_changes := false;
          PatientsInfo.show;
        end;
      PatientsInfo.Enabled := true;
    end;

  if save_changes then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\preimages\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      patients_info.PatientsInfo.Enabled := False;
      Followup_info.IsNewFollowUp := true;
      Followup_info.FollowUpInfo.Show;
    end;
end;

procedure TPatientsInfo.Button11Click(Sender: TObject);
begin
  SavePatient();
end;

procedure TPatientsInfo.Button1Click(Sender: TObject);
begin
  QPresurgicalImage.Prior;
end;

procedure TPatientsInfo.Button2Click(Sender: TObject);
begin
  QPresurgicalImage.Next;
end;

procedure TPatientsInfo.Button3Click(Sender: TObject);
var
  tempsql: string;
  imagedelete: string;
  folderpath : string;
begin
  folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\preimages\';
  if fileexists(folderpath + QPresurgicalImage.FieldValues['Filename']) then
    DeleteFile(folderpath + QPresurgicalImage.FieldValues['Filename']);
  imagedelete := inttostr(QPresurgicalImage.FieldValues['Image Id']);
  QPreSurgicalImage.Active := false;
  tempsql :=  QPresurgicalImage.SQL.Text;
  QPresurgicalImage.SQL.Text := 'DELETE FROM [PreSurgical Images] WHERE [Image Id] = "' + imagedelete + '";';
  QPresurgicalImage.ExecSQL;
  QPresurgicalImage.SQL.Text := tempsql;
  QPresurgicalImage.ExecSQL;
  QPreSurgicalImage.Active := true;
end;

procedure TPatientsInfo.Button4Click(Sender: TObject);
var folderpath: string;
    orfilenmstr: string;
    cpfilenmstr: string;
    fileinfostr: string;
    tempsql: string;
    save_changes: boolean;
begin

  if IsNewPatient then
    begin
      PatientsInfo.Enabled := false;
      If (MessageBox(0, 'The patient`s Data must be saved. Do u want to save the record?', 'Save Changes?', +mb_YesNo) = 6) then
        begin
          PatientsInfo.QPatientsInfo.ReadOnly := true;
          PatientsInfo.QPatientsInfo.SQL.Text := 'INSERT INTO [Patients Info] ([Registration Date]) VALUES ("' + datetostr(date) + '");';
          PatientsInfo.QPatientsInfo.ExecSQL;
          PatientsInfo.QPatientsInfo.SQL.Text := 'SELECT DISTINCT LASTAUTOINC ([Patients Info], [Patient Id]) FROM [Patients Info];';
          PatientsInfo.QPatientsInfo.ExecSQL;
          PatientsInfo.QPatientsInfo.Active :=true;
          PatientIdStr := PatientsInfo.QPatientsInfo.Fields.Fields[0].AsString;

          PatientsInfo.QPatientsInfo.ReadOnly := true;
          PatientsInfo.QPatientsInfo.SQL.Text := 'SELECT * FROM [Patients Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QPatientsInfo.Active :=true;
          PatientsInfo.QSurgerySearch.ReadOnly := true;
          PatientsInfo.QSurgerySearch.SQL.Text := 'SELECT * FROM [Surgery Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QSurgerySearch.Active := true;
          PatientsInfo.QFollowUpSearch.ReadOnly := true;
          PatientsInfo.QFollowUpSearch.SQL.Text := 'SELECT * FROM [FollowUp Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QFollowUpSearch.Active := true;
          PatientsInfo.QPreSurgicalImage.ReadOnly := true;
          PatientsInfo.QPreSurgicalImage.SQL.Text := 'SELECT * FROM [Presurgical Images] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QPreSurgicalImage.Active := true;
          IsNewPatient := false;
          save_changes := true;
        end
      else
        begin
          PatientsInfo.show;
          save_changes := false;
        end;
      PatientsInfo.Enabled := true;
    end;

  if save_changes then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\preimages\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      if OpenPictureDialog1.Execute then
        begin
          QPresurgicalImage.Active := false;
          orfilenmstr := ExtractFileName(OpenPictureDialog1.FileName);
          cpfilenmstr := orfilenmstr;
          if fileexists(folderpath + cpfilenmstr) then
            repeat
              cpfilenmstr := InputBox('Προσοχή - Το αρχείο υπάρχει ήδη', 'Παρακαλώ εισάγετε νέο όνομα αρχείου : ', orfilenmstr);
            until (not (fileexists(folderpath + cpfilenmstr)));
          Filecopy(OpenPictureDialog1.FileName,folderpath+cpfilenmstr);
          fileinfostr := InputBox('Περιγραφή Εικόνας', 'Παρακαλώ εισάγετε περιγραφή για την εικόνα : ', cpfilenmstr);
          tempsql :=  QPresurgicalImage.SQL.Text;
          QPresurgicalImage.SQL.Text := 'INSERT INTO [PreSurgical Images] ' +
                                    '([Patient Id],[Filename],[FileInfo]) VALUES ' +
                                    '("' + patientidstr + '","' + cpfilenmstr + '","' + fileinfostr + '");';
          QPresurgicalImage.ExecSQL;
          QPresurgicalImage.SQL.Text := tempsql;
          QPresurgicalImage.ExecSQL;
          QPresurgicalImage.Active := true;
        end;
    end;
  PatientsInfo.Show;
end;

procedure TPatientsInfo.Button5Click(Sender: TObject);
begin
  DBGrid1Dblclick(PatientsInfo);
end;

procedure TPatientsInfo.Button6Click(Sender: TObject);
var surgeryidstr : string;
    queryold: string;
    folderpath: string;
begin
  if QSurgerySearch.RecordCount > 0 then
    begin;
      SurgeryIdStr := DBGrid1.Fields[0].AsString;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + SurgeryIdStr + '';
      queryold := QSurgerySearch.SQL.Text;
      QSurgeryDelete.Active := False;
      QSurgeryDelete.SQL.Text := 'DELETE FROM [Surgery Info] WHERE [Surgery Id] = "' + SurgeryIdStr + '";';
      QSurgeryDelete.ExecSQL;
      QSurgeryDelete.SQL.Text := 'DELETE FROM [Surgical Images] WHERE [Surgery Id] = "' + SurgeryIdStr + '";';
      QSurgeryDelete.ExecSQL;
      if (DirectoryExists(folderpath)) Then
        deltree(folderpath);
      QSurgerySearch.SQL.Text := queryold;
      QSurgerySearch.Active := True;
    end;
end;

procedure TPatientsInfo.Button7Click(Sender: TObject);
var
    save_changes: boolean;
    folderpath: string;
begin
  save_changes := true;

  if IsNewPatient then
    begin
      PatientsInfo.Enabled := false;
      If (MessageBox(0, 'The patient`s Data must be saved. Do u want to save the record?', 'Save Changes?', +mb_YesNo) = 6) then
        begin
          PatientsInfo.QPatientsInfo.ReadOnly := true;
          PatientsInfo.QPatientsInfo.SQL.Text := 'INSERT INTO [Patients Info] ([Registration Date]) VALUES ("' + datetostr(date) + '");';
          PatientsInfo.QPatientsInfo.ExecSQL;
          PatientsInfo.QPatientsInfo.SQL.Text := 'SELECT DISTINCT LASTAUTOINC ([Patients Info], [Patient Id]) FROM [Patients Info];';
          PatientsInfo.QPatientsInfo.ExecSQL;
          PatientsInfo.QPatientsInfo.Active :=true;
          PatientIdStr := PatientsInfo.QPatientsInfo.Fields.Fields[0].AsString;

          PatientsInfo.QPatientsInfo.ReadOnly := true;
          PatientsInfo.QPatientsInfo.SQL.Text := 'SELECT * FROM [Patients Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QPatientsInfo.Active :=true;
          PatientsInfo.QSurgerySearch.ReadOnly := true;
          PatientsInfo.QSurgerySearch.SQL.Text := 'SELECT * FROM [Surgery Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QSurgerySearch.Active := true;
          PatientsInfo.QFollowUpSearch.ReadOnly := true;
          PatientsInfo.QFollowUpSearch.SQL.Text := 'SELECT * FROM [FollowUp Info] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QFollowUpSearch.Active := true;
          PatientsInfo.QPreSurgicalImage.ReadOnly := true;
          PatientsInfo.QPreSurgicalImage.SQL.Text := 'SELECT * FROM [Presurgical Images] WHERE [Patient Id] = "' + Patients_info.PatientIdStr + '";';
          PatientsInfo.QPreSurgicalImage.Active := true;
          IsNewPatient := false;
          save_changes := true;
        end
      else
        begin
          PatientsInfo.show;
          save_changes := false;
        end;
      PatientsInfo.Show;
      PatientsInfo.Enabled := true;
    end;

  if save_changes then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\preimages\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      patients_info.PatientsInfo.Enabled := False;
      Surgery_info.IsNewSurgery := true;
      Surgery_info.SurgeryInfo.Show;
    end;
end;

procedure TPatientsInfo.Button8Click(Sender: TObject);
begin
  DBGrid2Dblclick(PatientsInfo);
end;

procedure TPatientsInfo.Button9Click(Sender: TObject);
var followupidstr : string;
    queryold: string;
    folderpath: string;
begin
  if QFollowUpSearch.RecordCount > 0 then
    begin;
      followupIdStr := DBGrid2.Fields[0].AsString;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupIdStr + '';
      queryold := QFollowupSearch.SQL.Text;
      QSurgeryDelete.Active := False;
      QSurgeryDelete.SQL.Text := 'DELETE FROM [Followup Info] WHERE [FollowUp Id] = "' + followupIdStr + '";';
      QSurgeryDelete.ExecSQL;
      QSurgeryDelete.SQL.Text := 'DELETE FROM [FollowUp Images] WHERE [FollowUp Id] = "' + followupIdStr + '";';
      QSurgeryDelete.ExecSQL;
      if (DirectoryExists(folderpath)) Then
        deltree(folderpath);
      QFollowUpSearch.SQL.Text := queryold;
      QFollowUpSearch.Active := True;
    end;
end;

procedure TPatientsInfo.DataSource2DataChange(Sender: TObject; Field: TField);
begin

  if QSurgerySearch.RecordCount > 0 then
    begin
      Button5.Enabled := True;
      Button6.Enabled := True;
    end
  else
    begin
      Button5.Enabled := False;
      Button6.Enabled := False;
    end;
end;

procedure TPatientsInfo.DataSource3DataChange(Sender: TObject; Field: TField);
begin
  if QFollowupSearch.RecordCount > 0 then
    begin
      Button8.Enabled := True;
      Button9.Enabled := True;
    end
  else
    begin
      Button8.Enabled := False;
      Button9.Enabled := False;
    end;
end;

procedure TPatientsInfo.DataSource4DataChange(Sender: TObject; Field: TField);
 var folderpath: string;
begin
  Image3.Picture := nil;
  if QPreSurgicalImage.RecordCount > 0 then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\preimages\';
      if fileexists(folderpath + QPresurgicalImage.FieldValues['Filename']) then
        Image3.Picture.LoadFromFile(folderpath + QPresurgicalImage.FieldValues['Filename']);
      Button1.Enabled := True;
      Button2.Enabled := True;
      Button3.Enabled := True;
      Label7.Enabled := True;
      DBEdit4.Enabled := True;
      if (QPreSurgicalImage.RecNo = 1) then
        Button1.Enabled := False;
      if (QPreSurgicalImage.RecNo = QPreSurgicalImage.RecordCount) then
        Button2.Enabled := False;
    end
  else
    begin
      Button1.Enabled := False;
      Button2.Enabled := False;
      Button3.Enabled := False;
      Label7.Enabled := False;
      DBEdit4.Enabled := False;
    end;
end;

procedure TPatientsInfo.DBGrid1DblClick(Sender: TObject);
begin
  if QSurgerySearch.RecordCount > 0 then
    begin;
      patients_info.PatientsInfo.Enabled := False;
      Surgery_info.IsNewSurgery := false;
      Surgery_info.SurgeryIdStr := DBGrid1.Fields[0].AsString;
      Surgery_info.SurgeryInfo.QSurgeryInfo.ReadOnly := True;
      Surgery_info.SurgeryInfo.QSurgeryInfo.SQL.Text := 'SELECT * FROM [Surgery Info] WHERE [Surgery Id] = "' + DBGrid1.Fields[0].AsString + '";';
      Surgery_info.SurgeryInfo.QSurgeryInfo.Active := true;
      Surgery_info.SurgeryInfo.QSurgicalImage.ReadOnly := True;
      Surgery_info.SurgeryInfo.QSurgicalImage.SQL.Text := 'SELECT * FROM [Surgical Images] WHERE [Surgery Id] = "' + DBGrid1.Fields[0].AsString + '";';
      Surgery_info.SurgeryInfo.QSurgicalImage.Active := true;
      Surgery_info.SurgeryInfo.Show;
    end;
end;

procedure TPatientsInfo.DBGrid2DblClick(Sender: TObject);
begin
  if QFollowUpSearch.RecordCount > 0 then
    begin;
      patients_info.PatientsInfo.Enabled := False;
      FollowUp_info.IsNewFollowUp := false;
      FollowUp_info.FollowUpIdStr := DBGrid2.Fields[0].AsString;
      FollowUp_info.FollowUpInfo.QFollowUpInfo.ReadOnly := True;
      FollowUp_info.FollowUpInfo.QFollowUpInfo.SQL.Text := 'SELECT * FROM [FollowUp Info] WHERE [FollowUp Id] = "' + DBGrid2.Fields[0].AsString + '";';
      FollowUp_info.FollowUpInfo.QFollowUpInfo.Active := true;
      FollowUp_info.FollowUpInfo.QFollowUpImage.ReadOnly := True;
      FollowUp_info.FollowUpInfo.QFollowUpImage.SQL.Text := 'SELECT * FROM [FollowUp Images] WHERE [FollowUp Id] = "' + DBGrid2.Fields[0].AsString + '";';
      FollowUp_info.FollowUpInfo.QFollowUpImage.Active := true;
      FollowUp_info.FollowUpInfo.Show;
    end;
end;

procedure TPatientsInfo.FormClose(Sender: TObject; var Action: TCloseAction);
  var messg_close: PAnsiChar;
begin
  QPatientsInfo.Active := false;
  QPatientsInfo.Close;

  PatientsInfo.Enabled := false;
  if IsNewPatient then
    messg_close := 'You have inserted a new patient. Do you want to save the record?'
  else
    messg_close := 'Do you want to save the changes you made?';

  If (MessageBox(0, messg_close, 'Save Changes?', +mb_YesNo) = 6) then
    begin
      if IsNewPatient then
        begin
          QPatientsInfo.SQL.Text := 'INSERT INTO [Patients Info] ' +
                            '([Last Name],[First Name],[Father Name],[Birthdate],' +
                            '[Gender],[Home Phone],[Mobile Phone],[Other Phone],' +
                            '[Address],[City],[Postal Code],' +
                            '[Country],[Registration Date],[Clinical Findings],' +
                            '[Diagnose],[Diagnose Extra]) ' +
                            'VALUES ' +
                            '("' + FLastName.Text + '","' +  FFirstName.Text + '","' +  FFathersName.Text + '","' + datetostr(Datetimepicker1.date) + '",' +
                            '"' + inttostr(Combobox1.ItemIndex) + '","' +  FHomePhone.Text + '","' + Fmobile.Text  + '","' + FOtherPhone.Text + '",' +
                            '"' + FAddress.Text + '","' + FCity.Text  + '","' + FPostalCode.Text + '",' +
                            '"' + FCountry.Text + '","' +  datetostr(Datetimepicker2.date) + '","' + FClinicalFindings.Text  + '",' +
                            '"' + inttostr(Combobox2.ItemIndex) + '","' +  FDiagnoseExtra.Text + '"'
                             + ');'
        end
      else
        begin
          QPatientsInfo.SQL.Text := 'UPDATE [Patients Info] SET ' +
                            '[Last Name] = "' + FLastName.Text + '",' +
                            '[First Name] = "' + FFirstName.Text + '",' +
                            '[Father Name] = "' + FFathersName.Text + '",' +
                            '[Birthdate] = "' + datetostr(Datetimepicker1.date) + '",' +
                            '[Gender] = "' + inttostr(Combobox1.ItemIndex) + '",' +
                            '[Home Phone] = "' + FHomePhone.Text + '",' +
                            '[Mobile Phone] = "' + FMobile.Text + '",' +
                            '[Other Phone] = "' + FOtherPhone.Text + '",' +
                            '[Address] = "' + FAddress.Text + '",' +
                            '[City] = "' + FCity.Text + '",' +
                            '[Postal Code] = "' + FPostalCode.Text + '",' +
                            '[Country] = "' + FCountry.Text + '",' +
                            '[Registration Date] = "' + datetostr(Datetimepicker2.date) + '",' +
                            '[Clinical Findings] = "' + FClinicalFindings.Text + '",' +
                            '[Diagnose] = "' + inttostr(Combobox2.ItemIndex) + '",' +
                            '[Diagnose Extra] = "' + FDiagnoseExtra.Text + '" ' +
                            'WHERE [Patient Id] = "' + patientidstr + '";';
        end;
      QPatientsInfo.ExecSQL;
    end;

  PatientsInfo.Enabled := true;
  Form1.show;
end;

procedure TPatientsInfo.FormShow(Sender: TObject);
 var folderpath: string;
begin

  PatientsInfo.Caption := 'Αρχείο Ασθενών  -   Id Ασθενή : ' + patientidstr + '   -  Πληροφορίες   ( ' + patients_search.LicenceNameText + ' )';
  LicenceName.Caption := '( ' + patients_search.LicenceNameText + ' )';

  if not isnewpatient then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\preimages\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      if (QPatientsInfo.FieldValues['Last Name'] <> Null) then
        FLastName.Text := QPatientsInfo.FieldValues['Last Name']
      else
        FLastName.Text := '';

      if (QPatientsInfo.FieldValues['First Name'] <> Null) then
        FFirstName.Text := QPatientsInfo.FieldValues['First Name']
      else
        FFirstName.Text := '';

      if (QPatientsInfo.FieldValues['Father Name'] <> Null) then
        FFathersName.Text := QPatientsInfo.FieldValues['Father Name']
      else
        FFathersName.Text := '';

      if (QPatientsInfo.FieldValues['Birthdate'] <> Null) then
        Datetimepicker1.Date := QPatientsInfo.FieldValues['Birthdate']
      else
        Datetimepicker1.Date := null;

      if (QPatientsInfo.FieldValues['Home Phone'] <> Null) then
        FHomePhone.Text := QPatientsInfo.FieldValues['Home Phone']
      else
        FHomePhone.Text := '';

      if (QPatientsInfo.FieldValues['Mobile Phone'] <> Null) then
        FMobile.Text := QPatientsInfo.FieldValues['Mobile Phone']
      else
        FMobile.Text := '';

      if (QPatientsInfo.FieldValues['Other Phone'] <> Null) then
        FOtherPhone.Text := QPatientsInfo.FieldValues['Other Phone']
      else
        FOtherPhone.Text := '';

      if (QPatientsInfo.FieldValues['Address'] <> Null) then
        FAddress.Text := QPatientsInfo.FieldValues['Address']
      else
        FAddress.Text := '';

      if (QPatientsInfo.FieldValues['City'] <> Null) then
        FCity.Text := QPatientsInfo.FieldValues['City']
      else
        FCity.Text := '';

      if (QPatientsInfo.FieldValues['Postal Code'] <> Null) then
        FPostalCode.Text := QPatientsInfo.FieldValues['Postal Code']
      else
        FPostalCode.Text := '';

      if (QPatientsInfo.FieldValues['Country'] <> Null) then
        FCountry.Text := QPatientsInfo.FieldValues['Country']
      else
        FCountry.Text := '';

      if (QPatientsInfo.FieldValues['Registration Date'] <> Null) then
        Datetimepicker2.Date := QPatientsInfo.FieldValues['Registration Date']
      else
        Datetimepicker1.Date := null;

      if (QPatientsInfo.FieldValues['Clinical Findings'] <> Null) then
        FClinicalFindings.Text := QPatientsInfo.FieldValues['Clinical Findings']
      else
        FClinicalFindings.Text := '';

      if (QPatientsInfo.FieldValues['Diagnose Extra'] <> Null) then
        FDiagnoseExtra.Text := QPatientsInfo.FieldValues['Diagnose Extra']
      else
        FDiagnoseExtra.Text := '';

      Combobox1.ItemIndex := QPatientsInfo.FieldValues['Gender'];

      Combobox2.ItemIndex := QPatientsInfo.FieldValues['Diagnose'];
    end
  else
    begin
      FLastName.Text := '';
      FFirstName.Text := '';
      FFathersName.Text := '';
      Datetimepicker1.Date := date;
      FHomePhone.Text := '';
      FMobile.Text := '';
      FOtherPhone.Text := '';
      FAddress.Text := '';
      FCity.Text := '';
      FPostalCode.Text := '';
      FCountry.Text := '';
      Datetimepicker2.Date := date;
      FClinicalFindings.Text := '';
      FDiagnoseExtra.Text := '';

      Combobox1.ItemIndex := 0;
      Combobox2.ItemIndex := 0;

      Button1.Enabled := False;
      Button2.Enabled := False;
      Button3.Enabled := False;
      Label7.Enabled := False;
      DBEdit4.Enabled := False;
      Button5.Enabled := False;
      Button6.Enabled := False;
      Button8.Enabled := False;
      Button9.Enabled := False;
    end;
end;

procedure TPatientsInfo.Image1Click(Sender: TObject);
begin
  AboutBox.Show;
end;

procedure TPatientsInfo.Image3Click(Sender: TObject);
 var folderpath: string;
begin
  if QPresurgicalImage.RecordCount > 0 then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\preimages\';
      Image_Viewer.imagestr := folderpath + QPresurgicalImage.FieldValues['Filename'];
      Image_Viewer.ImageViewer.show;
      Image_Viewer.ImageRefresh;
    end;
end;

procedure TPatientsInfo.Image4Click(Sender: TObject);
begin
  DateTimePicker1.perform( wm_keydown, vk_f4, 0 );
end;

procedure TPatientsInfo.Image5Click(Sender: TObject);
begin
  DateTimePicker2.perform( wm_keydown, vk_f4, 0 );
end;

procedure TPatientsInfo.QFollowUpSearchClinicalImageGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := QFollowUpSearch.FieldValues['Clinical Image'];
end;

procedure TPatientsInfo.QSurgerySearchSurgeryDescriptionGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := QSurgerySearch.FieldValues['Surgery Description'];
end;

procedure TPatientsInfo.QSurgerySearchSurgeryGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if QSurgerySearch.FieldValues['Surgery Type'] = 0 then
    Text := 'Συρραφή τραύμάτος';
  if QSurgerySearch.FieldValues['Surgery Type'] = 1 then
    Text := 'Κρανιοανάτρηση';
  if QSurgerySearch.FieldValues['Surgery Type'] = 2 then
    Text := 'Μέτρηση ενδοκρανίου πιέσεως';
  if QSurgerySearch.FieldValues['Surgery Type'] = 3 then
    Text := 'Εξωτ. παροχέτευση ΕΝΥ';
  if QSurgerySearch.FieldValues['Surgery Type'] = 4 then
    Text := 'Βαλβίδα υδροκεφάλου';
  if QSurgerySearch.FieldValues['Surgery Type'] = 5 then
    Text := 'Κρανιοτομία';
  if QSurgerySearch.FieldValues['Surgery Type'] = 6 then
    Text := 'Υποφυσεκτομή';
  if QSurgerySearch.FieldValues['Surgery Type'] = 7 then
    Text := 'Εμβολισμός εγκεφάλου';
  if QSurgerySearch.FieldValues['Surgery Type'] = 8 then
    Text := 'Εμβολισμός νωτιαίου μυελού';
  if QSurgerySearch.FieldValues['Surgery Type'] = 9 then
    Text := 'Δισκεκτομή';
  if QSurgerySearch.FieldValues['Surgery Type'] = 10 then
    Text := 'Πεταλεκτομή';
  if QSurgerySearch.FieldValues['Surgery Type'] = 11 then
    Text := 'Σπονδυλοδεσία';
end;

end.
