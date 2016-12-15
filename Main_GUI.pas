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
    stat1.Panels[0].Text:='搜尋中...';
    if rg1.ItemIndex < 0 then
    begin
      ShowMessage('選擇CT切數');
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

    stat1.Panels[0].Text:='完成! 共花費'+i2s((GetTickCount - _SpendTimer)/1000)+'秒';
  finally
    btnSearch_XR2.Enabled := True;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Date_year.Value := StrToInt(FormatDateTime('eee',date));
  Date_year.Max := StrToInt(FormatDateTime('eee',date));
  Date_year.Min := 105;//105年才開始有紀錄CT列數。
  if Date_year.Max = Date_year.Min
  then Date_year.Increment := 0
  else Date_year.Increment := 1;
  Date_month.Value := StrToInt(FormatDateTime('mm',date));
  RG1.Columns :=1;
  RG1.Items.Add('64切CT'); //IXRYREG2的FILLER記錄代碼:#1
  RG1.Items.Add('4切CT');  //IXRYREG2的FILLER記錄代碼:#2
  RG1.Items.Add('16切CT'); //IXRYREG2的FILLER記錄代碼:#3

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
    FieldByname('月份').Value      := Copy(i2s(IXR1.DATE),0,5);
    FieldByname('身份').Value      := get_pt_type(ixr1.PT_TYPE);
    FieldByname('門診/住院').Value := IXR1.INP_OPD;
    FieldByname('報到日期').Value  := i2s(IXR1.date);
    FieldByname('病歷號').Value    := i2s(ixr1.chart_no);
    FieldByname('病患姓名').Value  := ixr1.PT_NAME;
    FieldByname('醫令碼').Value    := iwl.CODE;
    FieldByname('檢查敘述').Value  := iwl.name;
    FieldByname('儀器代碼').Value  := ixr2.FILLER;
    FieldByname('檢查單號').Value  := iwl.ACCESS_NO;
    FieldByname('儀器類別').Value  := IWL.modality;
  end;
end;}

end.
