unit Main_process;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs
  ,isysctl_ndm_u,session_dm_u,ixryreg2_dm_u,ixryreg1_dm_u,Shareutils,
  StdCtrls,iworklst_ndm_u, Db, DBClient, Grids, DBGrids, RzCommon, RzDBGrid,
  RzTabs, ExtCtrls, RzPanel, RzButton, RzRadChk, Mask, RzEdit, RzBorder,
  RzPopups, RzSpnEdt;

type
  TForm1 = class(TForm)
    btnSearch_XR2: TButton;
    dds1: TDataSource;
    cds1: TClientDataSet;
    rzdbgrd1: TRzDBGrid;
    CT16: TRzRadioButton;
    CT64: TRzRadioButton;
    CT8: TRzRadioButton;
    Date_month: TRzSpinEdit;
    Date_year: TRzSpinEdit;
    procedure btnSearch_XR2Click(Sender: TObject);
    procedure btnClsContClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure OPEN_FILE(yyyy, mm :string);
    procedure CLOSE_FILE;
  public
    { Public declarations }
  end;

  dbgrd1 = class(DBGrids.TDBGrid)
  public
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  end;

var
  Form1: TForm1;
  IXR2 : IXRYREG2_REC;
  IXR1 : IXRYREG1_REC;
  IWL  : IWORKLST_REC;



function get_pt_type(pt_type:Integer) :string;

implementation

{$R *.DFM}

function dbgrd1.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos:TPoint): Boolean;
begin
  if WheelDelta < 0 then begin
     Datasource.DataSet.Next;
  end;
  if WheelDelta > 0 then begin
     DataSource.DataSet.Prior;
  end;
end;

procedure TForm1.OPEN_FILE(yyyy, mm :string);
begin
  INIT_IXRYREG1(IXR1);
  IXR1.DRIVE := 'LAST';
  IXR1.FNAME := 'MXRY1;MXRY1'+copy(yyyy,3,1)+mm);
  if INFOFILE(IXR1.DRIVE, IXR1.FNAME, 'INPUT')
  then begin IXR1.FD := OPENFILE(IXR1.DRIVE,IXR1.FNAME,'INPUT'); end
  else begin ShowMessage('Get IXR1 FD Error!'); end;

  INIT_IXRYREG2(IXR2);
  IXR2.DRIVE := 'LAST';
  IXR2.FNAME := 'MXRY2;MXRY2505';
  if INFOFILE(IXR2.DRIVE, IXR2.FNAME, 'INPUT')
  then begin IXR2.FD := OPENFILE(IXR2.DRIVE,IXR2.FNAME,'INPUT'); end
  else begin ShowMessage('Get IXR2 FD Error!') end;

  INIT_IWORKLST(IWL);
  IWL.FD := OPENFILE(IWL.DRIVE,IWL.FNAME,'INPUT');
end;

procedure TForm1.CLOSE_FILE;
begin
  CLOSFILE(IXR2.DRIVE,IXR2.FD);
  CLOSFILE(IXR1.DRIVE,IXR1.FD);
end;

procedure TForm1.btnSearch_XR2Click(Sender: TObject);
var
  sn,err_sn : integer;
  yyyy,mm : string;

begin
  yyyy := i2s(Date_year.Value);
  mm := i2s(Date_month.Value);
  OPEN_FILE(yyyy,mm);

  if cds1.Active = False then cds1.CreateDataSet;
  cds1.EmptyDataSet;
  sn := 0;
  err_sn := 0;
  btnSearch_XR2.Enabled := False;
  IXR1.DATE := 1050501;
  SETKEYNO(IXR1.DRIVE,IXR1.FD,2);
  READ_IXRYREG1(IXR1,27);
  log_msg('順序'
          +',月份'
          +',身分'
          +',門診/住院'
          +',報到日期'
          +',病歷號'
          +',病患姓名'
          +',醫令碼'
          +',檢查敘述'
          +',儀器代號'
          +',檢查單號'
          +',儀器類別'
          +',DUPL'
          +',SEQ'
          +',錯誤碼'
          ,'D:\ym_source\cch\bin\mark\Output_Old_CT_Exam_Data\log.txt');
   log_msg('順序'
          +',月份'
          +',身分'
          +',門診/住院'
          +',報到日期'
          +',病歷號'
          +',病患姓名'
          +',醫令碼'
          +',檢查敘述'
          +',儀器代號'
          +',檢查單號'
          +',儀器類別'
          +',DUPL'
          +',SEQ'
          +',錯誤碼'
          ,'D:\ym_source\cch\bin\mark\Output_Old_CT_Exam_Data\err-log.txt');
  while (IXR1.ERR =0) and (IXR1.DATE < 1050503) do
  begin
      IXR2.CHART_NO     := IXR1.CHART_NO;
      ixr2.XR1_DATE     := IXR1.DATE;
      ixr2.DUPLICATE_NO := IXR1.DUPLICATE_NO;
      IXR2.INP_OPD      := IXR1.INP_OPD;
      IXR2.SEQ          := IXR1.SEQ;
      SETKEYNO(IXR2.DRIVE,IXR2.FD,1);
      READ_IXRYREG2(IXR2,17);
     {while (IXR2.ERR =0) and (IXR2.CHART_NO = IXR1.CHART_NO) and (IXR2.XR1_DATE = IXR1.DATE)
     do begin}
        if (IXR2.ERR = 0) and (Pos('#1',IXR2.FILLER) > 0)
        and (IXR2.CHART_NO = IXR1.CHART_NO) and (IXR2.XR1_DATE = IXR1.DATE)
         then begin
          IWL.CHART_NO  := IXR2.CHART_NO;
          IWL.CKIN_DATE := IXR2.XR1_DATE;
          IWL.CKIN_TIME := 0;
          SETKEYNO(IWL.DRIVE,IWL.FD,3);
          READ_IWORKLST(IWL,37);
            while (IWL.ERR = 0) and (IWL.CHART_NO = ixr1.CHART_NO) and (IWL.CKIN_DATE = IXR1.DATE)
            do begin
                if (IWL.CHART_NO = IXR1.CHART_NO)
                and (IWL.CKIN_DATE = ixr1.DATE)
                and (iwl.ERR = 0)
                and (IWL.MODALITY = 'CT')
                and (IWL.CODE <> 'hp2103')
                then begin
                  Inc(sn);
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
                    post;
                  end;
                  log_msg(i2s(sn)
                      +','+Copy(i2s(IXR1.DATE),0,5)
                      +','+get_pt_type(ixr1.PT_TYPE)
                      +','+IXR1.INP_OPD
                      +','+i2s(IXR1.date)
                      +','+i2s(ixr1.chart_no)
                      +','+ixr1.PT_NAME
                      +','+iwl.CODE
                      +','+iwl.name
                      +','+ixr2.FILLER
                      +','+iwl.ACCESS_NO
                      +','+IWL.modality
                      +','+ixr1.DUPLICATE_NO
                      +','+i2s(IXR1.seq)
                      +','+i2s(iwl.err)
                      ,'D:\ym_source\cch\bin\mark\Output_Old_CT_Exam_Data\log.txt');
                end else
                begin
                  Inc(err_sn);
                  log_msg(i2s(err_sn)
                      +','+Copy(i2s(IXR1.DATE),0,5)
                      +','+get_pt_type(ixr1.PT_TYPE)
                      +','+IXR1.INP_OPD
                      +','+i2s(IXR1.date)
                      +','+i2s(ixr1.chart_no)
                      +','+ixr1.PT_NAME
                      +','+iwl.CODE
                      +','+iwl.name
                      +','+ixr2.FILLER
                      +','+iwl.ACCESS_NO
                      +','+IWL.modality
                      +','+ixr1.DUPLICATE_NO
                      +','+i2s(IXR1.seq)
                      +','+i2s(iwl.err)
                      ,'D:\ym_source\cch\bin\mark\Output_Old_CT_Exam_Data\error-log.txt');
                end;
            READ_IWORKLST(IWL,2);
            end;
        end;
      {READ_IXRYREG2(IXR2,2);
     end;}
    READ_IXRYREG1(IXR1,2);
  end;
  CLOSE_FILE;
  btnSearch_XR2.Enabled := True;
  ShowMessage('結束!');
end;

procedure TForm1.btnClsContClick(Sender: TObject);
begin
  CLOSE_FILE;
end;

function get_pt_type(pt_type:Integer) :string;
begin
  if pt_type = 41 then Result := '健保'
  else if pt_type = 11 then Result := '非健保'
  else Result := '不明';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Date_year.Value := StrToInt(FormatDateTime('eee',date));
  Date_month.Value := StrToInt(FormatDateTime('mm',date));
end;
end.
