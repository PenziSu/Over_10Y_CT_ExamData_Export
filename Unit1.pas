unit Unit1;

interface

type testClass = class
 private
 public
  {sn           :string;
  month        :string;
  identity     :string;
  source       :string;
  checkin_date :string;
  patient_id   :string;
  patient_name :string;
  order_code   :string;
  exam_desc    :string;
  channel_no   :string;}
  access_no    :string;
  //modality     :string;
  function GOGOGO(x:string):string;
end;


implementation

function testClass.GOGOGO(x:string):string;
var
  aa : testClass;
begin
  aa := testClass.Create;
  aa.access_no := x;
  Result := aa.access_no;
end;

end.
 