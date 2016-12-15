unit Main_GUI;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs
  ,isysctl_ndm_u,session_dm_u,ixryreg2_dm_u,ixryreg1_dm_u,Shareutils,
  StdCtrls,iworklst_ndm_u,Main_process, Db, DBClient, Grids, DBGrids, RzCommon, RzDBGrid,
  RzTabs, ExtCtrls, RzPanel, RzButton, RzRadChk, Mask, RzEdit, RzBorder,
  RzPopups, RzSpnEdt,Unit1, ComCtrls;

type
  TForm1 = class(TForm)
    btnSearch_XR2: TButton;
    dds1: TDataSource;
    cds1: TClientDataSet;
    rzdbgrd1: TRzDBGrid;
    Date_month: TRzSpinEdit;
    Date_year: TRzSpinEdit;
    rg1: TRadioGroup;
    stat1: TStatusBar;
    procedure btnSearch_XR2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  tmp_AID:string;

implementation

{$R *.DFM}

procedure TForm1.btnSearch_XR2Click(Sender: TObject);
var
  yyy     :string;
  mm      :string;
  CHNL_NO :string;
  DisplayData : SearchData;
  _SpendTimer : Cardinal;
begin
  try
    _SpendTimer := GetTickCount;
    if fileexists('D:\ym_source\cch\bin\mark\Over_10YearCT_Exam_Data_Export\log-normal.csv')
    or fileexists('D:\ym_source\cch\bin\mark\Over_10YearCT_Exam_Data_Export\log-error.csv')
    then begin
      DeleteFile('D:\ym_source\cch\bin\mark\Over_10YearCT_Exam_Data_Export\log-normal.csv');
      DeleteFile('D:\ym_source\cch\bin\mark\Over_10YearCT_Exam_Data_Export\log-error.csv');
    end;
    btnSearch_XR2.Enabled := False;
    stat1.Panels[0].Text:='�j�M��...';
    if rg1.ItemIndex < 0 then
    begin
      ShowMessage('���CT����');
      Exit;
    end;
    yyy := i2s(Date_year.Value);
    mm := i2s(Date_month.Value,2);
    case rg1.ItemIndex of
     0:CHNL_NO := '#1';
     1:CHNL_NO := '#2';
     2:CHNL_NO := '#3';
    end;
    DisplayData := SearchData.Create;
    DisplayData.UpdateClientDataSet(cds1,yyy,mm,CHNL_NO);

    stat1.Panels[0].Text:='����! �@��O'+i2s((GetTickCount - _SpendTimer)/1000)+'��';
  finally
    btnSearch_XR2.Enabled := True;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Date_year.Value := StrToInt(FormatDateTime('eee',date));
  Date_year.Max := StrToInt(FormatDateTime('eee',date));
  Date_year.Min := 105;//105�~�~�}�l������CT�C�ơC
  if Date_year.Max = Date_year.Min
  then Date_year.Increment := 0
  else Date_year.Increment := 1;
  Date_month.Value := StrToInt(FormatDateTime('mm',date));
  RG1.Columns :=1;
  RG1.Items.Add('64��CT'); //IXRYREG2��FILLER�O���N�X:#1
  RG1.Items.Add('4��CT');  //IXRYREG2��FILLER�O���N�X:#2
  RG1.Items.Add('16��CT'); //IXRYREG2��FILLER�O���N�X:#3

end;

{procedure RetriveAndPostDate(sn,month,identity,source,checkin_date,patient_id,
                             patient_name,order_code,exam_desc,channel_no,
                             access_no,modality:string);
begin
  Inc(sn);
  if cds1.Active = False then cds1.CreateDataSet;
  cds1.EmptyDataSet;
  with cds1 do
  begin
    Append;
    FieldByname('#').Value         := i2s(sn);
    FieldByname('���').Value      := Copy(i2s(IXR1.DATE),0,5);
    FieldByname('����').Value      := get_pt_type(ixr1.PT_TYPE);
    FieldByname('���E/��|').Value := IXR1.INP_OPD;
    FieldByname('������').Value  := i2s(IXR1.date);
    FieldByname('�f����').Value    := i2s(ixr1.chart_no);
    FieldByname('�f�w�m�W').Value  := ixr1.PT_NAME;
    FieldByname('��O�X').Value    := iwl.CODE;
    FieldByname('�ˬd�ԭz').Value  := iwl.name;
    FieldByname('�����N�X').Value  := ixr2.FILLER;
    FieldByname('�ˬd�渹').Value  := iwl.ACCESS_NO;
    FieldByname('�������O').Value  := IWL.modality;
  end;
end;}

end.
