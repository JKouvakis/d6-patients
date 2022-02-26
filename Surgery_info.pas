unit Surgery_info;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrls, Mask, ExtCtrls, jpeg, DB, ABSMain, ExtDlgs,
  ComCtrls, WinTypes, ShellApi;

type
  TSurgeryInfo = class(TForm)
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
    Label11: TLabel;
    Label19: TLabel;
    ComboBox2: TComboBox;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    Image2: TImage;
    Button5: TButton;
    Button6: TButton;
    QSurgeryInfo: TABSQuery;
    DataSource1: TDataSource;
    QSurgicalImage: TABSQuery;
    DataSource4: TDataSource;
    FSurgeryDescription: TMemo;
    FComplications: TMemo;
    FHospCertificate: TEdit;
    OpenPictureDialog1: TOpenPictureDialog;
    OpenDialog1: TOpenDialog;
    DateTimePicker1: TDateTimePicker;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure DataSource4DataChange(Sender: TObject; Field: TField);
    procedure FDateEnter(Sender: TObject);
    procedure FDateExit(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SurgeryInfo: TSurgeryInfo;
  SurgeryIdStr: String;
  IsNewSurgery: boolean;

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

procedure TSurgeryInfo.Button1Click(Sender: TObject);
begin
  QSurgicalImage.Prior;
end;

procedure TSurgeryInfo.Button2Click(Sender: TObject);
begin
  QSurgicalImage.Next;
end;

procedure TSurgeryInfo.Button3Click(Sender: TObject);
var
  tempsql: string;
  imagedelete: string;
  folderpath : string;
begin
  folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + surgeryidstr + '\';
  if fileexists(folderpath + QSurgicalImage.FieldValues['Filename']) then
    sysutils.DeleteFile(folderpath + QSurgicalImage.FieldValues['Filename']);
  imagedelete := inttostr(QSurgicalImage.FieldValues['Image Id']);
  QSurgicalImage.Active := false;
  tempsql :=  QSurgicalImage.SQL.Text;
  QSurgicalImage.SQL.Text := 'DELETE FROM [Surgical Images] WHERE [Image Id] = "' + imagedelete + '";';
  QSurgicalImage.ExecSQL;
  QSurgicalImage.SQL.Text := tempsql;
  QSurgicalImage.ExecSQL;
  QSurgicalImage.Active := true;
end;

procedure TSurgeryInfo.Button4Click(Sender: TObject);
var folderpath: string;
    orfilenmstr: string;
    cpfilenmstr: string;
    fileinfostr: string;
    tempsql: string;
    save_changes: boolean;
begin

  if IsNewSurgery then
    begin
      SurgeryInfo.Enabled := false;
      If (MessageBox(0, 'The surgery`s Data must be saved. Do u want to save the record?', 'Save Changes?', +mb_YesNo) = 6) then
        begin
         QSurgeryInfo.SQL.Text := 'INSERT INTO [Surgery Info] ' +
                            '([Patient Id],[Surgery Date],[Surgery Type],' +
                            '[Surgery Description],' +
                            '[Complications And Treatment],[Hospitalisation Certificate]) ' +
                            'VALUES ' +
                            '("' + Patients_Info.PatientIdStr + '","' +  datetostr(Datetimepicker1.date) + '","' + inttostr(Combobox2.Itemindex) + '",' +
                            '"' +  FSurgeryDescription.Text + '",' +
                            '"' + FComplications.Text + '","' +  FHospCertificate.Text + '"'
                            + ');';

          QSurgeryInfo.ExecSQL;
          QSurgeryInfo.SQL.Text := 'SELECT DISTINCT LASTAUTOINC ([Surgery Info], [Surgery Id]) FROM [Surgery Info];';
          QSurgeryInfo.ExecSQL;
          QSurgeryInfo.Active :=true;
          SurgeryIdStr := QSurgeryInfo.Fields.Fields[0].AsString;

          QSurgeryInfo.ReadOnly := true;
          QSurgeryInfo.SQL.Text := 'SELECT * FROM [Surgery Info] WHERE [Surgery Id] = "' + Surgery_info.SurgeryIdStr + '";';
          QSurgeryInfo.Active :=true;
          QSurgicalImage.ReadOnly := true;
          QSurgicalImage.SQL.Text := 'SELECT * FROM [Surgical Images] WHERE [Surgery Id] = "' + Surgery_info.SurgeryIdStr + '";';
          QSurgicalImage.Active := true;

          Surgery_info.SurgeryInfo.Image1.Visible := False;

          IsNewSurgery := false;
          save_changes := true;
        end
      else
        begin
          save_changes := false;
        end;
      SurgeryInfo.Enabled := true;
    end;

  if save_changes then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + surgeryidstr + '\';
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
          tempsql := QSurgicalImage.SQL.Text;
          QSurgicalImage.SQL.Text := 'INSERT INTO [Surgical Images] ' +
                                    '([Surgery Id],[Patient Id],[Filename],[FileInfo]) VALUES ' +
                                    '("' + surgeryidstr + '","' + patientidstr + '","' + cpfilenmstr + '","' + fileinfostr + '");';
          QSurgicalImage.ExecSQL;
          QSurgicalImage.SQL.Text := tempsql;
          QSurgicalImage.ExecSQL;
          QSurgicalImage.Active := true;
        end;
    end;
end;

procedure TSurgeryInfo.Button5Click(Sender: TObject);
 var folderpath: string;
begin
  folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + surgeryidstr + '\';
  if fileexists(folderpath + FHospCertificate.Text) then
    sysutils.DeleteFile(folderpath + FHospCertificate.Text);
  FHospCertificate.Text := '';
  Button5.Enabled := False;
  Image1.Visible := False;
end;

procedure TSurgeryInfo.Button6Click(Sender: TObject);
 var folderpath: string;
    orfilenmstr: string;
    tempsql: string;
    save_changes: boolean;
begin

  if IsNewSurgery then
    begin
      SurgeryInfo.Enabled := false;
      If (MessageBox(0, 'The surgery`s Data must be saved. Do u want to save the record?', 'Save Changes?', +mb_YesNo) = 6) then
        begin
         QSurgeryInfo.SQL.Text := 'INSERT INTO [Surgery Info] ' +
                            '([Patient Id],[Surgery Date],[Surgery Type],' +
                            '[Surgery Description],' +
                            '[Complications And Treatment],[Hospitalisation Certificate]) ' +
                            'VALUES ' +
                            '("' + Patients_Info.PatientIdStr + '","' +  datetostr(Datetimepicker1.date) + '","' + inttostr(Combobox2.Itemindex) + '",' +
                            '"' +  FSurgeryDescription.Text + '",' +
                            '"' + FComplications.Text + '","' +  FHospCertificate.Text + '"'
                            + ');';


          QSurgeryInfo.ExecSQL;
          QSurgeryInfo.SQL.Text := 'SELECT DISTINCT LASTAUTOINC ([Surgery Info], [Surgery Id]) FROM [Surgery Info];';
          QSurgeryInfo.ExecSQL;
          QSurgeryInfo.Active :=true;
          SurgeryIdStr := QSurgeryInfo.Fields.Fields[0].AsString;

          QSurgeryInfo.ReadOnly := true;
          QSurgeryInfo.SQL.Text := 'SELECT * FROM [Surgery Info] WHERE [Surgery Id] = "' + Surgery_info.SurgeryIdStr + '";';
          QSurgeryInfo.Active :=true;
          QSurgeryInfo.ReadOnly := true;
          QSurgeryInfo.SQL.Text := 'SELECT * FROM [Surgical Images] WHERE [Surgery Id] = "' + Surgery_info.SurgeryIdStr + '";';
          QSurgeryInfo.Active := true;

          Surgery_info.SurgeryInfo.Image1.Visible := False;

          IsNewSurgery := false;
          save_changes := true;
        end
      else
        begin
          save_changes := false;
        end;
      SurgeryInfo.Enabled := true;
    end;

  if save_changes then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + surgeryidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      if OpenDialog1.Execute then
        begin
          orfilenmstr := ExtractFileName(OpenDialog1.FileName);
          if fileexists(folderpath + orfilenmstr) then
            Button5Click(SurgeryInfo);
            Filecopy(OpenDialog1.FileName,folderpath+orfilenmstr);
          FHospCertificate.Text := orfilenmstr;
          Button5.Enabled := True;
          Image1.Visible := True;
        end;
    end;
end;

procedure TSurgeryInfo.DataSource4DataChange(Sender: TObject; Field: TField);
 var folderpath: string;
begin
  Image3.Picture := nil;
  if QSurgicalImage.RecordCount > 0 then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + surgeryidstr + '\';
      if fileexists(folderpath + QSurgicalImage.FieldValues['Filename']) then
        Image3.Picture.LoadFromFile(folderpath + QSurgicalImage.FieldValues['Filename']);
      Button1.Enabled := True;
      Button2.Enabled := True;
      Button3.Enabled := True;
      Label7.Enabled := True;
      DBEdit4.Enabled := True;
      if (QSurgicalImage.RecNo = 1) then
        Button1.Enabled := False;
      if (QSurgicalImage.RecNo = QSurgicalImage.RecordCount) then
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

procedure TSurgeryInfo.FDateEnter(Sender: TObject);
begin
  Image2.Visible := true
end;

procedure TSurgeryInfo.FDateExit(Sender: TObject);
begin
  Image2.Visible := false
end;

procedure TSurgeryInfo.FormClose(Sender: TObject; var Action: TCloseAction);
var
  messg_close: PAnsiChar;
begin
  QSurgeryInfo.Active := false;
  QSurgeryInfo.Close;

  SurgeryInfo.Enabled := false;
  if IsNewSurgery then
    messg_close := 'You have inserted a new surgery. Do you want to save the record?'
  else
    messg_close := 'Do you want to save the changes you made?';

  If (MessageBox(0, messg_close, 'Save Changes?', +mb_YesNo) = 6) then
    begin
      if IsNewSurgery then
        begin
          QSurgeryInfo.SQL.Text := 'INSERT INTO [Surgery Info] ' +
                            '([Patient Id],[Surgery Date],[Surgery Type],' +
                            '[Surgery Description],' +
                            '[Complications And Treatment],[Hospitalisation Certificate]) ' +
                            'VALUES ' +
                            '("' + Patients_Info.PatientIdStr + '","' +  datetostr(Datetimepicker1.date) + '","' + inttostr(Combobox2.Itemindex) + '",' +
                            '"' +  FSurgeryDescription.Text + '",' +
                            '"' + FComplications.Text + '","' +  FHospCertificate.Text + '"'
                             + ');'

        end
      else
        begin
          QSurgeryInfo.SQL.Text := 'UPDATE [Surgery Info] SET ' +
                            '[Patient Id] = "' + Patients_Info.PatientIdStr + '",' +
                            '[Surgery Date] = "' + datetostr(Datetimepicker1.date) + '",' +
                            '[Surgery Type] = "' + inttostr(Combobox2.ItemIndex) + '",' +
                            '[Surgery Description] = "' + FSurgeryDescription.Text + '",' +
                            '[Complications And Treatment] = "' + FComplications.Text + '",' +
                            '[Hospitalisation Certificate] = "' + FHospCertificate.Text + '" ' +
                            'WHERE [Surgery Id] = "' + Surgery_Info.SurgeryIdStr + '";';
        end;
      QSurgeryInfo.ExecSQL;
    end;

  SurgeryInfo.Enabled := true;

  Patients_info.PatientsInfo.Enabled := True;
  Patients_info.PatientsInfo.Show;
  Patients_info.PatientsInfo.QSurgerySearch.Refresh;
end;

procedure TSurgeryInfo.FormShow(Sender: TObject);
var folderpath : string;
begin
  Surgeryinfo.Caption :=  'Πληροφορίες Χειρουργείου   ( ' + patients_search.LicenceNameText + ' )';

  if Not IsNewSurgery then
    begin

      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + surgeryidstr + '\';
      if not (DirectoryExists(folderpath)) Then
        begin
          CreateDir(folderpath);
        end;

      if (QSurgeryInfo.FieldValues['Surgery Date'] <> Null) then
        Datetimepicker1.date := QSurgeryInfo.FieldValues['Surgery Date']
      else
        Datetimepicker1.date := null;

      Combobox2.ItemIndex := QSurgeryInfo.FieldValues['Surgery Type'];

      if (QSurgeryInfo.FieldValues['Surgery Description'] <> Null) then
        FSurgeryDescription.Text := QSurgeryInfo.FieldValues['Surgery Description']
      else
        FSurgeryDescription.Text := '';

      if (QSurgeryInfo.FieldValues['Complications And Treatment'] <> Null) then
        FComplications.Text := QSurgeryInfo.FieldValues['Complications And Treatment']
      else
        FComplications.Text := '';

      if (QSurgeryInfo.FieldValues['Hospitalisation Certificate'] <> Null) then
        begin
          FHospCertificate.Text := QSurgeryInfo.FieldValues['Complications And Treatment'];
          Image1.Visible := true;
          Button5.Enabled := true
        end
      else
        begin
          FHospCertificate.Text := '';
          Image1.Visible := false;
          Button5.Enabled := false
        end

    end
  else
    begin
      Datetimepicker1.date := date;
      Combobox2.ItemIndex := 0;
      FSurgeryDescription.Text := '';
      FComplications.Text := '';
      FHospCertificate.Text := '';
      Image1.visible := false;
      Button5.Enabled := false;

      Button1.Enabled := false;
      Button2.Enabled := false;
      Button3.Enabled := false;
      Label7.Enabled := False;
      DBEdit4.Enabled := False;

    end;
end;

procedure TSurgeryInfo.Image1Click(Sender: TObject);
 var folderpath: string;
     filepath: string;
begin
  if FHospCertificate.Text <> '' then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + surgeryidstr + '\';
      filepath := folderpath + FHospCertificate.Text;
      ShellExecute(0, nil, PChar(filePath), nil, nil, SW_NORMAL);
    end;
end;

procedure TSurgeryInfo.Image3Click(Sender: TObject);
 var folderpath: string;
begin
  if QSurgicalImage.RecordCount > 0 then
    begin
      folderpath := ExtractFilePath(Application.ExeName) + 'data\pat_' + patientidstr + '\surgery\sur_' + surgeryidstr + '\';
      Image_Viewer.imagestr := folderpath + QSurgicalImage.FieldValues['Filename'];
      Image_Viewer.ImageViewer.show;
      Image_Viewer.ImageRefresh;
    end;
end;

end.
