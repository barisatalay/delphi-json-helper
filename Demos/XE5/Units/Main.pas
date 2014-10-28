unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, JsonHelperCore;

type
  TForm26 = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    JSONHelper1: TJSONHelper;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form26: TForm26;

implementation

{$R *.fmx}
Uses System.IOUtils;

procedure TForm26.Button1Click(Sender: TObject);
begin
  JSONHelper1.JSON.Add('http://mangakafe.com/json.txt');
  JsonHelper1.Active := True;
end;

procedure TForm26.Button2Click(Sender: TObject);
begin
  JSONHelper1.SaveFile(System.IOUtils.TPath.GetDocumentsPath + System.SysUtils.PathDelim + 'Helper.json');
end;

procedure TForm26.Button3Click(Sender: TObject);
begin
  JSONHelper1.RecNo := 1;
  JSONHelper1.FieldByName['manga'] := 'is it worked?';
end;

procedure TForm26.Button4Click(Sender: TObject);
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

procedure TForm26.Button5Click(Sender: TObject);
var
  T: String;
begin
  JSONHelper1.Active := False;
  T := System.IOUtils.TPath.GetDocumentsPath + System.SysUtils.PathDelim + 'Helper.json';
  JSONHelper1.JSON.Clear;
  JSONHelper1.JSON.Add(JSONHelper1.FromFile(T));
  JSONHelper1.Active := True;
  Button4Click(Sender);
end;

end.
