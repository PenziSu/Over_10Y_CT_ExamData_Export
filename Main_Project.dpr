program Main_Project;

uses
  Forms,
  Main_GUI in 'Main_GUI.pas' {Form1},
  session_dm_u in '..\..\..\dm\session_dm_u.pas' {session_dm},
  isysctl_ndm_u in '..\..\..\dm\isysctl_ndm_u.pas',
  ixryreg2_dm_u in '..\..\..\dm\ixryreg2_dm_u.pas' {IXRYREG2_dm},
  ixryreg1_dm_u in '..\..\..\dm\ixryreg1_dm_u.pas' {IXRYREG1_dm},
  ShareUtils in '..\..\..\public\Shareutils.pas',
  Main_process in 'Main_process.pas',
  iworklst_ndm_u in '..\..\..\dm\iworklst_ndm_u.pas',
  idtlfa_dm_u in '..\..\..\dm\idtlfa_dm_u.pas' {IDTLFA_dm},
  mdtlfb_dm_u in '..\..\..\dm\mdtlfb_dm_u.pas' {MDTLFB_dm},
  iprice_dm_u in '..\..\..\dm\iprice_dm_u.pas' {IPRICE_dm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Tsession_dm, session_dm);
  Application.CreateForm(TIXRYREG2_dm, IXRYREG2_dm);
  Application.CreateForm(TIXRYREG1_dm, IXRYREG1_dm);
  Application.CreateForm(TIDTLFA_dm, IDTLFA_dm);
  Application.CreateForm(TMDTLFB_dm, MDTLFB_dm);
  Application.CreateForm(TIPRICE_dm, IPRICE_dm);
  Application.Run;
end.
