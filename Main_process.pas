unit Main_process;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs
  ,isysctl_ndm_u,session_dm_u,ixryreg2_dm_u,ixryreg1_dm_u,Shareutils,
  StdCtrls,iworklst_ndm_u,DBClient,idtlfa_dm_u,mdtlfb_dm_u,iprice_dm_u;

type ConnectDB = class
 private
  year  : string;
  month : string;
  drive : string;
  procedure OPEN_FILE;
  procedure CLOSE_FILE;
 public
end;

type
  TStringArray = array[0..3] of String;

type SearchData = class
 private
   function TransferCTChnlCode(code:string):string;
   function get_pt_type(pt_type:Integer) :string;
   function CheckIDTLFAandMDTLFB(PatientSource:string; PatientID,OPDate:Integer; DuplicateNo:string; ExamDate:Integer;MonthlyFileName:String):TStringArray;
   function OrderCodeToCorrCode(OrderCode:string):String;
 public
//  tmp : TClientDataSet;
  procedure UpdateClientDataSet(var DataSet:TClientDataSet; yyyy,mm,CHNL_NO:string);
end;


implementation

var
  IXR1:IXRYREG1_REC;
  IXR2:IXRYREG2_REC;
  IWL :IWORKLST_REC;
  IDA :IDTLFA_REC;
  MDB :MDTLFB_REC;
  IPC :IPRICE_REC;

procedure ConnectDB.OPEN_FILE();
var
  sDRIVE,sFNAME1,sFNAME2,IdaFname,MdbFname : string;
begin
  //�P�_�ݭnŪ�������٬O����
  IF (year+month) = (FormatDateTime('eeemm',date)) then
  begin
     sDRIVE := 'MAS';
     sFNAME1 := 'IXRYREG1';
     sFNAME2 := 'IXRYREG2';
     IdaFname := 'IDTLFA';
     MdbFname := 'MDTLFB';
  end else
  begin
     sDRIVE   := 'LAST';
     sFNAME1  := 'MXRY1;MXRY1'+copy(year,3,1)+month;
     sFNAME2  := 'MXRY2;MXRY2'+copy(year,3,1)+month;
     IdaFname := 'IDTLFA;IDTLFA'+copy(year,3,1)+month;
     MdbFname := 'MDTLFB;MDTLFB'+copy(year,3,1)+month;;
  end;

  if (UpperCase(drive) = 'MAS') or (UpperCase(drive) = 'ALL')
  then begin
    INIT_IXRYREG1(IXR1);
    IXR1.DRIVE := sDRIVE;
    IXR1.FNAME := sFNAME1;
    if INFOFILE(IXR1.DRIVE, IXR1.FNAME, 'INPUT')
    then begin IXR1.FD := OPENFILE(IXR1.DRIVE,IXR1.FNAME,'INPUT'); end
    else begin ShowMessage('Get IXR1 FD Error!'); end;

    INIT_IXRYREG2(IXR2);
    IXR2.DRIVE := sDRIVE;
    IXR2.FNAME := sFNAME2;
    if INFOFILE(IXR2.DRIVE, IXR2.FNAME, 'INPUT')
    then begin IXR2.FD := OPENFILE(IXR2.DRIVE,IXR2.FNAME,'INPUT'); end
    else begin ShowMessage('Get IXR2 FD Error!') end;

    INIT_IWORKLST(IWL);
    IWL.FD := OPENFILE(IWL.DRIVE,IWL.FNAME,'INPUT');

    INIT_IPRICE(IPC);
    IPC.FD := OPENFILE(IPC.DRIVE,IPC.FNAME,'INPUT');
  end;

  if (UpperCase(drive) = 'LBOF') or (UpperCase(drive) = 'ALL')
  then begin
    INIT_IDTLFA(IDA);
    IDA.DRIVE := 'LBOF';
    IDA.FNAME := IdaFname;
    if INFOFILE(IDA.DRIVE,IDA.FNAME,'INPUT')
    then IDA.FD := OPENFILE(IDA.DRIVE,IDA.FNAME,'INPUT')
    else ShowMessage('Get IDA FD Error!');

    INIT_MDTLFB(MDB);
    MDB.DRIVE := 'LBOF';
    MDB.FNAME := MdbFname;
    if INFOFILE(MDB.DRIVE,MDB.FNAME,'INPUT')
    then MDB.FD := OPENFILE(MDB.DRIVE,MDB.FNAME,'INPUT')
    else ShowMessage('Get MDB FD Error!');
  end;
end;

procedure ConnectDB.CLOSE_FILE();
begin
  if (UpperCase(drive) = 'MAS') or (UpperCase(drive) = 'ALL')
  then begin
    CLOSFILE(IXR1.DRIVE,IXR1.FD);
    CLOSFILE(IXR2.DRIVE,IXR2.FD);
    CLOSFILE(IWL.DRIVE,IWL.FD);
    CLOSFILE(IPC.DRIVE,IPC.FD);
  end;

  if (UpperCase(drive) = 'LBOF') or (UpperCase(drive) = 'ALL')
  then begin
    CLOSFILE(IDA.DRIVE,IDA.FD);
    CLOSFILE(MDB.DRIVE,MDB.FD);
  end;
end;

procedure SearchData.UpdateClientDataSet(var DataSet:TClientDataSet; yyyy,mm,CHNL_NO:string);
var
  sn,err_sn,_DtlfResultCount : Integer;
  DB : ConnectDB;
  StartDate,EndDate : String;
  StepByStep_Start,StepByStep_End:string;
  StepByStep : integer;
  _DtlfResult : TStringArray;
begin
  if DataSet.Active = False then
  begin
    DataSet.CreateDataSet;
  end;
  DataSet.EmptyDataSet;

  (*�إ߸�Ʈw�s�u*)
  DB        := ConnectDB.Create;
  DB.year   := yyyy;
  DB.month  := mm;
  DB.drive  := 'ALL';
  DB.OPEN_FILE;

  sn        := 0;
  err_sn    := 0;
  StartDate := yyyy+mm+'01';
  EndDate   := yyyy+mm+'31';

  //StepByStep           := yyyy+mm; //��l�ƴ`��Ū��LBOF�ɮפ����
  StepByStep_Start := yyyy+mm; //��l�ƴ`��Ū��LBOF�ɮפ����
  StepByStep_End   := yyyy+i2s(s2i(mm)+1); //��l�ƴ`��Ū��LBOF�ɮפ����

  IXR1.DATE := StrToInt(StartDate);
  SETKEYNO(IXR1.DRIVE,IXR1.FD,2);
  READ_IXRYREG1(IXR1,27);
  log_msg('����'+',���'+',����'+',�ӷ�'+',�}����'+',������'+',�f����'
        +',�f�w�m�W'+',��O�X'+',���O�X'+',�ˬd�ԭz'+',�����N��'+',�ˬd�渹'
        +',�������O'+',DUPL'+',SEQ'+',���~�X'+',�ӳ����O'+',�ץ����'+',�`�Ǹ�'
        ,'D:\ym_source\cch\bin\mark\Output_Old_CT_Exam_Data\log-normal.csv');
  log_msg('����'+',���'+',����'+',�ӷ�'+',�}����'+',������'+',�f����'
        +',�f�w�m�W'+',��O�X'+',���O�X'+',�ˬd�ԭz'+',�����N��'+',�ˬd�渹'
        +',�������O'+',DUPL'+',SEQ'+',���~�X'+',�ӳ����O'+',�ץ����'+',�`�Ǹ�'
        ,'D:\ym_source\cch\bin\mark\Output_Old_CT_Exam_Data\log-error.csv');
  try
    while (IXR1.ERR =0) and (IXR1.DATE < s2i(EndDate)) do
    begin
        IXR2.CHART_NO     := IXR1.CHART_NO;
        ixr2.XR1_DATE     := IXR1.DATE;
        ixr2.DUPLICATE_NO := IXR1.DUPLICATE_NO;
        IXR2.INP_OPD      := IXR1.INP_OPD;
        IXR2.SEQ          := IXR1.SEQ;
        SETKEYNO(IXR2.DRIVE,IXR2.FD,1);
        READ_IXRYREG2(IXR2,17);
        if (IXR2.ERR = 0) and (Pos(CHNL_NO,IXR2.FILLER) > 0)
        and (IXR2.CHART_NO = IXR1.CHART_NO) and (IXR2.XR1_DATE = IXR1.DATE)
         then begin
          IWL.CHART_NO  := IXR2.CHART_NO;
          IWL.CKIN_DATE := IXR2.XR1_DATE;
          IWL.CKIN_TIME := 0;
          SETKEYNO(IWL.DRIVE,IWL.FD,3);
          READ_IWORKLST(IWL,37);
            while (IWL.ERR = 0) and (IWL.CHART_NO = ixr1.CHART_NO) and (IWL.CKIN_DATE = IXR1.DATE) do
            begin
              (*��l��_DtlfResult*)
              for _DtlfResultCount := 0 to 3 do
              begin
                _DtlfResult[_DtlfResultCount] := '';
              end;

              (*Debug �S�w�ˬd�渹*)
              if iwl.ACCESS_NO = 'X10511118492'
              then Sleep(1000);

              for StepByStep := s2i(StepByStep_Start) to s2i(StepByStep_End) do
              begin
                (*���o[IDTLFA]&[MDTLFB]�ɮפ��e*)
                _DtlfResult := CheckIDTLFAandMDTLFB(UpperCase(IXR1.INP_OPD),
                                                    ixr1.chart_no,
                                                    iwl.ORDER_DATE,
                                                    UpperCase(ixr1.DUPLICATE_NO),
                                                    iwl.CKIN_DATE,
                                                    i2s(StepByStep));
                if not (_DtlfResult[0] = '') and not (_DtlfResult[3] = '') then
                begin
                  Break;
                end else
                begin
                  //Sleep(1000);
                end;
              end;


              if (IWL.CHART_NO = IXR1.CHART_NO)
              and (IWL.CKIN_DATE = ixr1.DATE)
              and (iwl.ERR = 0)
              and (IWL.MODALITY = 'CT')
              and not (IWL.CODE = 'hp2103') {*�~�|���פJ*}
              and not (ixr1.PT_TYPE = 11)
              then begin
                (*Inc(sn);
                with DataSet do
                begin
                  Append;
                  FieldByname('#').Value         := i2s(sn);
                  FieldByname('���').Value      := Copy(i2s(IXR1.DATE),0,5);
                  FieldByname('����').Value      := get_pt_type(ixr1.PT_TYPE);
                  FieldByname('���E/���|').Value := IXR1.INP_OPD;
                  FieldByname('������').Value  := i2s(IXR1.date);
                  FieldByname('�f����').Value    := i2s(ixr1.chart_no);
                  FieldByname('�f�w�m�W').Value  := ixr1.PT_NAME;
                  FieldByname('��O�X').Value    := iwl.CODE;
                  FieldByname('�ˬd�ԭz').Value  := iwl.name;
                  FieldByname('�����N�X').Value  := TransferCTChnlCode(Copy(ixr2.FILLER,2,2));
                  FieldByname('�ˬd�渹').Value  := iwl.ACCESS_NO;
                  FieldByname('�������O').Value  := IWL.modality;
                  {FieldByname('�ӳ����O').Value  := _DtlfResult[0];
                  FieldByname('�ץ����').Value  := _DtlfResult[1];
                  FieldByname('�`�Ǹ�').Value    := _DtlfResult[2];}
                  Post;
                end;*)

                log_msg(i2s(sn)
                    +','+Copy(i2s(IXR1.DATE),0,5)
                    +','+get_pt_type(ixr1.PT_TYPE)
                    +','+IXR1.INP_OPD
                    +','+i2s(iwl.ORDER_DATE)
                    +','+i2s(IXR1.date)
                    +','+i2s(ixr1.chart_no)
                    +','+ixr1.PT_NAME
                    +','+iwl.CODE
                    +','+OrderCodeToCorrCode(iwl.CODE)
                    +','+iwl.name
                    +','+TransferCTChnlCode(Copy(ixr2.FILLER,2,2))
                    +','+iwl.ACCESS_NO
                    +','+IWL.modality
                    +','+ixr1.DUPLICATE_NO
                    +','+i2s(IXR1.seq)
                    +','+i2s(iwl.err)
                    +','+_DtlfResult[0]
                    +','+_DtlfResult[1]
                    +','+_DtlfResult[2]
                    +','+_DtlfResult[3]
                    ,'D:\ym_source\cch\bin\mark\Output_Old_CT_Exam_Data\log-normal.csv');
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
                    +','+OrderCodeToCorrCode(iwl.CODE)
                    +','+iwl.name
                    +','+TransferCTChnlCode(Copy(ixr2.FILLER,2,2))
                    +','+iwl.ACCESS_NO
                    +','+IWL.modality
                    +','+ixr1.DUPLICATE_NO
                    +','+i2s(IXR1.seq)
                    +','+i2s(iwl.err)
                    +','+_DtlfResult[0]
                    +','+_DtlfResult[1]
                    +','+_DtlfResult[2]
                    +','+_DtlfResult[3]
                    ,'D:\ym_source\cch\bin\mark\Output_Old_CT_Exam_Data\log-error.csv');
              end;
              READ_IWORKLST(IWL,2);
            end;
        end;
      READ_IXRYREG1(IXR1,2);
    end;
  finally
    (*������Ʈw�s�u*)
    DB.CLOSE_FILE;
  end;
end;

function SearchData.TransferCTChnlCode(code:string):string;
begin
  if code = '#1' then Result := '64��'
  else if code = '#2' then Result := '4��'
  else if code = '#3' then Result := '16��'
  else Result := '����';
end;

function SearchData.get_pt_type(pt_type:Integer) :string;
begin
  if pt_type = 41 then Result := '���O'
  else if pt_type = 11 then Result := '�D���O'
  else Result := '����';
end;

function SearchData.CheckIDTLFAandMDTLFB
(PatientSource:string; PatientID,OPDate:Integer; DuplicateNo:string; ExamDate:Integer; MonthlyFileName:String):TStringArray;
var
  DB_IVYSAUR : ConnectDB;

begin
  DB_IVYSAUR := ConnectDB.Create;
  DB_IVYSAUR.year := Copy(MonthlyFileName,1,3);
  DB_IVYSAUR.month := Copy(MonthlyFileName,4,5);
  DB_IVYSAUR.drive := 'LBOF';
  DB_IVYSAUR.OPEN_FILE;
  try
    if PatientSource = 'O' then
    begin
      IDA.CHART_NO := PatientID;
      IDA.OPD_DATE := s2i(Copy(i2s(ExamDate),1,5)+'01');
      IDA.DUPLICATE_NO := DuplicateNo;
      SETKEYNO(IDA.DRIVE,IDA.FD,1);
      READ_IDTLFA(IDA,17);
      while (IDA.ERR = 0) and(IDA.CHART_NO = PatientID) do
      begin
        if (IDA.OPD_DATE >= OPDate) and (IDA.OPD_DATE <= ExamDate) then
        begin
          Result[0] := IDA.REPORT_CLASS;
          Result[1] := IDA.CASE_TYPE;
          Result[2] := i2s(IDA.TOTAL_SEQ);
          Result[3] := i2s(IDA.CURE_END_DATE);
        end;
        READ_IDTLFA(IDA,2);
      end;
    end
    else if PatientSource = 'I' then
    begin
      MDB.CHART_NO := PatientID;
      MDB.DUPLICATE_NO := DuplicateNo;
      SETKEYNO(MDB.DRIVE,MDB.FD,1);
      READ_MDTLFB(MDB,17);
      if (MDB.CHART_NO = PatientID) then
      begin
        while (MDB.ERR = 0) and (MDB.CHART_NO = PatientID)  do
        begin
          if (ExamDate >= MDB.REPORT_DATE_B) and (ExamDate <= MDB.REPORT_DATE_E) then
          begin
            Result[0] := MDB.REPORT_CLASS;
            Result[1] := MDB.CASE_TYPE;
            Result[2] := i2s(MDB.TOTAL_SEQ);
          end;
          READ_MDTLFB(MDB,2);
        end;
      end;
    end;
  finally
    DB_IVYSAUR.CLOSE_FILE;
  end;
end;

function SearchData.OrderCodeToCorrCode(OrderCode:string):String;
begin
  IPC.CODE := OrderCode;
  IPC.EFF_DATE := 0;
  READ_IPRICE_COMP18(IPC);
  if IPC.ERR = 0
  then Result := IPC.CORR_CODE[4];
end;

end.