unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, JsonHelperCore,
  FMX.StdCtrls, FMX.Layouts, FMX.ListBox, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, System.IOUtils;

type
  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ListBox1: TListBox;
    JSONHelper1: TJSONHelper;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation    //http://mangakafe.com/json.txt

{$R *.fmx}

procedure TForm3.Button1Click(Sender: TObject);
begin
  JsonHelper1.Active := True;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  ListBox1.Items.Clear;
  with JsonHelper1 do
  begin
    ListBox1.BeginUpdate;
    while not EOF do
    begin
      ListBox1.Items.Add(FieldByName['manga']);
      Next;
    end;
    ListBox1.EndUpdate;
  end;
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
  JSONHelper1.SaveFile(System.IOUtils.TPath.GetDocumentsPath + System.SysUtils.PathDelim + 'Helper.json');
end;

procedure TForm3.Button4Click(Sender: TObject);
begin
  JSONHelper1.RecNo := 1;
  JSONHelper1.FieldByName['manga'] := 'is it worked?';
end;

procedure TForm3.Button5Click(Sender: TObject);
var
  T: String;
begin
  JSONHelper1.Active := False;
  T := System.IOUtils.TPath.GetDocumentsPath + System.SysUtils.PathDelim + 'Helper.json';
  JSONHelper1.JSON.Clear;
  JSONHelper1.JSON.Add(JSONHelper1.FromFile(T));
  JSONHelper1.Active := True;
  Button2Click(Sender);
end;

end.
