unit followup_info;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, DBCtrls, ExtCtrls, jpeg, DB, ABSMain, ComCtrls,
  ExtDlgs, WinTypes, ShellApi;

type
  TFollowUpInfo = class(TForm)
    Panel2: TPanel;
    Label3: TLabel;
    Image3: TImage;
    Panel3: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Panel4: TPanel;
    Label7: TLabel;
    DBEdit4: TDBEdit;
    Label5: TLabel;
    Label1: TLabel;
    Label11: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    QFollowUpInfo: TABSQuery;
    DataSource1: TDataSource;
    QFollowUpImage: TABSQuery;
    DataSource4: TDataSource;
    FTimeSurgery: TMemo;
    FClinicalImage: TMemo;
    Image4: TImage;
    FMedicalInfo: TEdit;
    Button5: TButton;
    Button6: TButton;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    OpenPictureDialog1: TOpenPictureDialog;
    OpenDialog1: TOpenDialog;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    CheckBox1: TCheckBox;
    Shape1: TShape;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    Label6: TLabel;
    FInstructions: TMemo;
    CheckOther: TEdit;
    procedure DataSource4DataChange(Sender: TObject; Field: TField);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FollowUpInfo: TFollowUpInfo;
  FollowUpIdStr: string;
  IsNewFollowUp: boolean;

implementation

uses Patients_info, Image_Viewer, patients_search;

{$R *.dfm}

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

procedure TFollowUpInfo.Button1Click(Sender: TObject);
begin
  QFollowupImage.Prior;
end;

procedure TFollowUpInfo.Button2Click(Sender: TObject);
begin
  QFollowupImage.Next;
end;

procedure TFollowUpInfo.Button3Click(Sender: TObject);
var
  tempsql: string;
  imagedelete: string;
  folderpath : string;
begin
  folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupidstr + '\';
  if fileexists(folderpath + QFollowUpImage.FieldValues['Filename']) then
    sysutils.DeleteFile(folderpath + QFollowUpImage.FieldValues['Filename']);
  imagedelete := inttostr(QFollowUpImage.FieldValues['Image Id']);
  QFollowUpImage.Active := false;
  tempsql :=  QFollowUpImage.SQL.Text;
  QFollowUpImage.SQL.Text := 'DELETE FROM [FollowUp Images] WHERE [Image Id] = "' + imagedelete + '";';
  QFollowUpImage.ExecSQL;
  QFollowUpImage.SQL.Text := tempsql;
  QFollowUpImage.ExecSQL;
  QFollowUpImage.Active := true;
end;

procedure TFollowUpInfo.Button4Click(Sender: TObject);
var folderpath: string;
    orfilenmstr: string;
    cpfilenmstr: string;
    fileinfostr: string;
    tempsql: string;
    save_changes: boolean;
begin

  if IsNewFollowUp then
    begin
      FollowUpInfo.Enabled := false;
      If (MessageBox(0, 'The FollowUp`s Data must be saved. Do u want to save the record?', 'Save Changes?', +mb_YesNo) = 6) then
        begin
          QFollowUpInfo.ReadOnly := True;
          QFollowUpInfo.SQL.Text := 'INSERT INTO [FollowUp Info] ' +
                            '([Patient Id],[FollowUp Date],[Next FollowUp Date],' +
                            '[Time from Surgery],[Clinical Image],[Instructions],' +
                            '[Medical Info],' +
                            '[Check1],[Check2],[Check3],' +
                            '[Check4],[Check5],[Check6],' +
                            '[Check7],[Check8],[Check9],' +
                            '[CheckOther]) ' +
                            'VALUES ' +
                            '("' + Patients_Info.PatientIdStr + '","' +  datetostr(Datetimepicker1.date) + '","' + datetostr(Datetimepicker2.date) + '",' +
                            '"' +  FTimeSurgery.Text + '","' + FClinicalImage.Text + '","' + FInstructions.Text + '",' +
                            '"' +  FMedicalInfo.Text + '",' +
                            '"' +  booltostr(Checkbox1.Checked) + '","' + booltostr(Checkbox2.Checked) + '","' + booltostr(Checkbox3.Checked) + '",' +
                            '"' +  booltostr(Checkbox4.Checked) + '","' + booltostr(Checkbox5.Checked) + '","' + booltostr(Checkbox6.Checked) + '",' +
                            '"' +  booltostr(Checkbox7.Checked) + '","' + booltostr(Checkbox8.Checked) + '","' + booltostr(Checkbox9.Checked) + '",' +
                            '"' +  CheckOther.Text +   '"'
                             + ');';
          IsNewFollowUp := false;
          QFollowUpInfo.ExecSQL;
          QFollowUpInfo.SQL.Text := 'SELECT DISTINCT LASTAUTOINC ([FollowUp Info], [FollowUp Id]) FROM [FollowUp Info];';
          QFollowUpInfo.ExecSQL;
          QFollowUpInfo.Active :=true;
          FollowUpIdStr := QFollowUpInfo.Fields.Fields[0].AsString;

          QFollowUpInfo.ReadOnly := true;
          QFollowUpInfo.SQL.Text := 'SELECT * FROM [FollowUp Info] WHERE [FollowUp Id] = "' + Followup_info.FollowUpIdStr + '";';
          QFollowUpInfo.Active :=true;
          QFollowUpImage.ReadOnly := true;
          QFollowUpImage.SQL.Text := 'SELECT * FROM [FollowUp Images] WHERE [FollowUp Id] = "' + Followup_info.FollowUpIdStr + '";';
          QFollowUpImage.Active := true;

          Followup_info.FollowUpInfo.Image4.Visible := False;

          save_changes := true;
        end
      else
        begin
          save_changes := false;
        end;
      FollowUpInfo.Enabled := true;
    end;

  if save_changes then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      if OpenPictureDialog1.Execute then
        begin
          orfilenmstr := ExtractFileName(OpenPictureDialog1.FileName);
          cpfilenmstr := orfilenmstr;
          if fileexists(folderpath + cpfilenmstr) then
            repeat
              cpfilenmstr := InputBox('Προσοχή - Το αρχείο υπάρχει ήδη', 'Παρακαλώ εισάγετε νέο όνομα αρχείου : ', orfilenmstr);
            until (not (fileexists(folderpath + cpfilenmstr)));
          Filecopy(OpenPictureDialog1.FileName,folderpath+cpfilenmstr);
          fileinfostr := InputBox('Περιγραφή Εικόνας', 'Παρακαλώ εισάγετε περιγραφή για την εικόνα : ', cpfilenmstr);
          tempsql := QFollowUpImage.SQL.Text;
          QFollowUpImage.SQL.Text := 'INSERT INTO [FollowUp Images] ' +
                                    '([FollowUp Id],[Patient Id],[Filename],[FileInfo]) VALUES ' +
                                    '("' + followupidstr + '","' + patientidstr + '","' + cpfilenmstr + '","' + fileinfostr + '");';
          QFollowUpImage.ExecSQL;
          QFollowUpImage.SQL.Text := tempsql;
          QFollowUpImage.ExecSQL;
          QFollowUpImage.Active := true;
        end;
    end;
end;

procedure TFollowUpInfo.Button5Click(Sender: TObject);
 var folderpath: string;
begin
  folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupidstr + '\';
  if fileexists(folderpath + FMedicalInfo.Text) then
    sysutils.DeleteFile(folderpath + FMedicalInfo.Text);
  FMedicalInfo.Text := '';
  Button5.Enabled := False;
  Image4.Visible := False;
end;

procedure TFollowUpInfo.Button6Click(Sender: TObject);
 var folderpath: string;
    orfilenmstr: string;
    tempsql: string;
    save_changes: boolean;
begin

  if IsNewFollowUp then
    begin
      FollowUpInfo.Enabled := false;
      If (MessageBox(0, 'The surgery`s Data must be saved. Do u want to save the record?', 'Save Changes?', +mb_YesNo) = 6) then
        begin
          QFollowUpInfo.ReadOnly := True;
          QFollowUpInfo.SQL.Text := 'INSERT INTO [FollowUp Info] ' +
                            '([Patient Id],[FollowUp Date],[Next FollowUp Date],' +
                            '[Time from Surgery],[Clinical Image],[Instructions],' +
                            '[Medical Info],' +
                            '[Check1],[Check2],[Check3],' +
                            '[Check4],[Check5],[Check6],' +
                            '[Check7],[Check8],[Check9],' +
                            '[CheckOther]) ' +
                            'VALUES ' +
                            '("' + Patients_Info.PatientIdStr + '","' +  datetostr(Datetimepicker1.date) + '","' + datetostr(Datetimepicker2.date) + '",' +
                            '"' +  FTimeSurgery.Text + '","' + FClinicalImage.Text + '","' + FInstructions.Text + '",' +
                            '"' +  FMedicalInfo.Text + '",' +
                            '"' +  booltostr(Checkbox1.Checked) + '","' + booltostr(Checkbox2.Checked) + '","' + booltostr(Checkbox3.Checked) + '",' +
                            '"' +  booltostr(Checkbox4.Checked) + '","' + booltostr(Checkbox5.Checked) + '","' + booltostr(Checkbox6.Checked) + '",' +
                            '"' +  booltostr(Checkbox7.Checked) + '","' + booltostr(Checkbox8.Checked) + '","' + booltostr(Checkbox9.Checked) + '",' +
                            '"' +  CheckOther.Text +   '"'
                             + ');';
          IsNewFollowUp := false;
          QFollowUpInfo.ExecSQL;
          QFollowUpInfo.SQL.Text := 'SELECT DISTINCT LASTAUTOINC ([FollowUp Info], [FollowUp Id]) FROM [FollowUp Info];';
          QFollowUpInfo.ExecSQL;
          QFollowUpInfo.Active :=true;
          FollowUpIdStr := QFollowUpInfo.Fields.Fields[0].AsString;

          QFollowUpInfo.ReadOnly := true;
          QFollowUpInfo.SQL.Text := 'SELECT * FROM [FollowUp Info] WHERE [FollowUp Id] = "' + Followup_info.FollowUpIdStr + '";';
          QFollowUpInfo.Active :=true;
          QFollowUpImage.ReadOnly := true;
          QFollowUpImage.SQL.Text := 'SELECT * FROM [FollowUp Images] WHERE [FollowUp Id] = "' + Followup_info.FollowUpIdStr + '";';
          QFollowUpImage.Active := true;

          Followup_info.FollowUpInfo.Image4.Visible := False;
        end
      else
        begin
          save_changes := false;
        end;
      FollowUpInfo.Enabled := true;
    end;

  if save_changes then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      if OpenDialog1.Execute then
        begin
          orfilenmstr := ExtractFileName(OpenDialog1.FileName);
          if fileexists(folderpath + orfilenmstr) then
            Button5Click(FollowUpInfo);
          Filecopy(OpenDialog1.FileName,folderpath+orfilenmstr);
          FMedicalInfo.Text := orfilenmstr;
          Button5.Enabled := True;
          Image4.Visible := True;
        end;
    end;
end;

procedure TFollowUpInfo.CheckBox9Click(Sender: TObject);
begin
  if checkbox9.Checked then
    Checkother.Enabled := true
  else
    checkother.Enabled := false;
end;

procedure TFollowUpInfo.DataSource4DataChange(Sender: TObject; Field: TField);
 var folderpath: string;
begin
  Image3.Picture := nil;
  if QFollowUpImage.RecordCount > 0 then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupidstr + '\';
      if fileexists(folderpath + QFollowUpImage.FieldValues['Filename']) then
        Image3.Picture.LoadFromFile(folderpath + QFollowUpImage.FieldValues['Filename']);
      Button1.Enabled := True;
      Button2.Enabled := True;
      Button3.Enabled := True;
      Label7.Enabled := True;
      DBEdit4.Enabled := True;
      if (QFollowUpImage.RecNo = 1) then
        Button1.Enabled := False;
      if (QFollowUpImage.RecNo = QFollowUpImage.RecordCount) then
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

procedure TFollowUpInfo.FormClose(Sender: TObject; var Action: TCloseAction);
var
  messg_close: PAnsiChar;
begin
  QFollowUpInfo.Active := false;
  QFollowUpInfo.Close;

  if not checkbox9.Checked then
    checkother.Text := '';

  FollowUpInfo.Enabled := false;
  if IsNewFollowUp then
    messg_close := 'You have inserted a new Follow Up. Do you want to save the record?'
  else
    messg_close := 'Do you want to save the changes you made?';

  If (MessageBox(0, messg_close, 'Save Changes?', +mb_YesNo) = 6) then
    begin
      if IsNewFollowUp then
        begin
          QFollowUpInfo.SQL.Text := 'INSERT INTO [FollowUp Info] ' +
                            '([Patient Id],[FollowUp Date],[Next FollowUp Date],' +
                            '[Time from Surgery],[Clinical Image],[Instructions],' +
                            '[Medical Info],' +
                            '[Check1],[Check2],[Check3],' +
                            '[Check4],[Check5],[Check6],' +
                            '[Check7],[Check8],[Check9],' +
                            '[CheckOther]) ' +
                            'VALUES ' +
                            '("' + Patients_Info.PatientIdStr + '","' +  datetostr(Datetimepicker1.date) + '","' + datetostr(Datetimepicker2.date) + '",' +
                            '"' +  FTimeSurgery.Text + '","' + FClinicalImage.Text + '","' + FInstructions.Text + '",' +
                            '"' +  FMedicalInfo.Text + '",' +
                            '"' +  booltostr(Checkbox1.Checked) + '","' + booltostr(Checkbox2.Checked) + '","' + booltostr(Checkbox3.Checked) + '",' +
                            '"' +  booltostr(Checkbox4.Checked) + '","' + booltostr(Checkbox5.Checked) + '","' + booltostr(Checkbox6.Checked) + '",' +
                            '"' +  booltostr(Checkbox7.Checked) + '","' + booltostr(Checkbox8.Checked) + '","' + booltostr(Checkbox9.Checked) + '",' +
                            '"' +  CheckOther.Text +   '"'
                             + ');'
        end
      else
        begin
          QFollowUpInfo.SQL.Text := 'UPDATE [FollowUp Info] SET ' +
                            '[Patient Id] = "' + Patients_Info.PatientIdStr + '",' +
                            '[FollowUp Date] = "' + datetostr(Datetimepicker1.date) + '",' +
                            '[Next FollowUp Date] = "' + datetostr(Datetimepicker2.date) + '",' +
                            '[Time from Surgery] = "' + FTimeSurgery.Text + '",' +
                            '[Clinical Image] = "' + FClinicalImage.Text + '",' +
                            '[Instructions] = "' + FInstructions.Text + '",' +
                            '[Check1] = "' + booltostr(Checkbox1.Checked) + '",' +
                            '[Check2] = "' + booltostr(Checkbox2.Checked) + '",' +
                            '[Check3] = "' + booltostr(Checkbox3.Checked) + '",' +
                            '[Check4] = "' + booltostr(Checkbox4.Checked) + '",' +
                            '[Check5] = "' + booltostr(Checkbox5.Checked) + '",' +
                            '[Check6] = "' + booltostr(Checkbox6.Checked) + '",' +
                            '[Check7] = "' + booltostr(Checkbox7.Checked) + '",' +
                            '[Check8] = "' + booltostr(Checkbox8.Checked) + '",' +
                            '[Check9] = "' + booltostr(Checkbox9.Checked) + '",' +
                            '[CheckOther] = "' + CheckOther.text + '",' +
                            '[Medical Info] = "' + FMedicalInfo.Text + '" ' +
                            'WHERE [FollowUp Id] = "' + followupidstr + '";';
        end;
      QFollowUpInfo.ExecSQL;
    end;

  FollowUpInfo.Enabled := true;

  Patients_info.PatientsInfo.Enabled := True;
  Patients_info.PatientsInfo.Show;
  Patients_info.PatientsInfo.QFollowUpSearch.Refresh;
end;

procedure TFollowUpInfo.FormShow(Sender: TObject);
var folderpath : string;
begin
      FollowUpInfo.Caption :=  'Πληροφορίες Μετεγχειρητικής Παρακολούθησης  ( ' + patients_search.LicenceNameText + ' )';

  if not IsNewFollowUp then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      if (QFollowUpInfo.FieldValues['FollowUp Date'] <> Null) then
        Datetimepicker1.date := QFollowUpInfo.FieldValues['FollowUp Date']
      else
        Datetimepicker1.date := null;

      if (QFollowUpInfo.FieldValues['Next FollowUp Date'] <> Null) then
        Datetimepicker2.date := QFollowUpInfo.FieldValues['Next FollowUp Date']
      else
        Datetimepicker2.date := null;

      if (QFollowUpInfo.FieldValues['Time from Surgery'] <> Null) then
        FTimeSurgery.Text := QFollowUpInfo.FieldValues['Time from Surgery']
      else
        FTimeSurgery.Text := '';

      if (QFollowUpInfo.FieldValues['Clinical Image'] <> Null) then
        FClinicalImage.Text := QFollowUpInfo.FieldValues['Clinical Image']
      else
        FClinicalImage.Text := '';

      if (QFollowUpInfo.FieldValues['Instructions'] <> Null) then
        FInstructions.Text := QFollowUpInfo.FieldValues['Instructions']
      else
        FInstructions.Text := '';

      if (QFollowUpInfo.FieldValues['Check1'] <> Null) then
        checkbox1.Checked := QFollowUpInfo.FieldValues['Check1']
      else
        checkbox1.Checked := false;

      if (QFollowUpInfo.FieldValues['Check2'] <> Null) then
        checkbox2.Checked := QFollowUpInfo.FieldValues['Check2']
      else
        checkbox2.Checked := false;

      if (QFollowUpInfo.FieldValues['Check3'] <> Null) then
        checkbox3.Checked := QFollowUpInfo.FieldValues['Check3']
      else
        checkbox3.Checked := false;

      if (QFollowUpInfo.FieldValues['Check4'] <> Null) then
        checkbox4.Checked := QFollowUpInfo.FieldValues['Check4']
      else
        checkbox4.Checked := false;

      if (QFollowUpInfo.FieldValues['Check5'] <> Null) then
        checkbox5.Checked := QFollowUpInfo.FieldValues['Check5']
      else
        checkbox5.Checked := false;

      if (QFollowUpInfo.FieldValues['Check6'] <> Null) then
        checkbox6.Checked := QFollowUpInfo.FieldValues['Check6']
      else
        checkbox6.Checked := false;

      if (QFollowUpInfo.FieldValues['Check7'] <> Null) then
        checkbox7.Checked := QFollowUpInfo.FieldValues['Check7']
      else
        checkbox7.Checked := false;

      if (QFollowUpInfo.FieldValues['Check8'] <> Null) then
        checkbox8.Checked := QFollowUpInfo.FieldValues['Check8']
      else
        checkbox8.Checked := false;

      if (QFollowUpInfo.FieldValues['CheckOther'] <> Null) then
        begin
          checkother.text := QFollowUpInfo.FieldValues['CheckOther'];
          checkbox9.Checked := true;
        end
      else
        begin
          checkother.text := '';
          checkother.Enabled := false;
          checkbox9.Checked := false;
        end;

      if (QFollowUpInfo.FieldValues['Medical Info'] <> Null) then
        begin
          FMedicalInfo.Text := QFollowUpInfo.FieldValues['Medical Info'];
          Image4.Visible := true;
          Button5.Enabled := true
        end
      else
        begin
          FMedicalInfo.Text := '';
          Image4.Visible := false;
          Button5.Enabled := false
        end

    end
  else
    begin
      Datetimepicker1.date := date;
      Datetimepicker2.date := incmonth(date);
      FTimeSurgery.Text := '';
      FClinicalImage.Text := '';
      FMedicalInfo.Text := '';
      FInstructions.Text := '';
      Image4.Visible := False;
      Button5.Enabled := False;
      checkbox1.Checked := false;
      checkbox2.Checked := false;
      checkbox3.Checked := false;
      checkbox4.Checked := false;
      checkbox5.Checked := false;
      checkbox6.Checked := false;
      checkbox7.Checked := false;
      checkbox8.Checked := false;
      checkbox9.Checked := false;
      checkother.Enabled := false;

      Button1.Enabled := false;
      Button2.Enabled := false;
      Button3.Enabled := false;
      Label7.Enabled := False;
      DBEdit4.Enabled := False;

    end;
end;

procedure TFollowUpInfo.Image1Click(Sender: TObject);
begin
  DateTimePicker1.perform( wm_keydown, vk_f4, 0 );
end;

procedure TFollowUpInfo.Image2Click(Sender: TObject);
begin
  DateTimePicker2.perform( wm_keydown, vk_f4, 0 );
end;

procedure TFollowUpInfo.Image3Click(Sender: TObject);
 var folderpath: string;
begin
  if QFollowUpImage.RecordCount > 0 then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupidstr + '\';
      Image_Viewer.imagestr := folderpath + QFollowUpImage.FieldValues['Filename'];
      Image_Viewer.ImageViewer.show;
      Image_Viewer.ImageRefresh;
    end;
end;

procedure TFollowUpInfo.Image4Click(Sender: TObject);
 var folderpath: string;
     filepath: string;
begin
  if FMedicalInfo.Text <> '' then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\followup\fol_' + followupidstr + '\';
      filepath := folderpath + FMedicalInfo.Text;
      ShellExecute(0, nil, PChar(filePath), nil, nil, SW_NORMAL);
    end;
end;

end.
