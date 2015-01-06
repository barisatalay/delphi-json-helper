unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, JsonHelperCore,
  FMX.StdCtrls, FMX.Layouts, FMX.ListBox;

type
  TForm4 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    JSONHelper1: TJSONHelper;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.fmx}
Uses System.IOUtils;

procedure TForm4.Button1Click(Sender: TObject);
begin
  JsonHelper1.Active := True;
end;

procedure TForm4.Button2Click(Sender: TObject);
var
  T: String;
begin
  JSONHelper1.Active := False;
  T := System.IOUtils.TPath.GetDocumentsPath + System.SysUtils.PathDelim + 'Helper.json';
  JSONHelper1.JSON.Clear;
  JSONHelper1.JSON.Add(JSONHelper1.FromFile(T));
  JSONHelper1.Active := True;
  Button5Click(Sender);
end;

procedure TForm4.Button3Click(Sender: TObject);
begin
  JSONHelper1.SaveFile(System.IOUtils.TPath.GetDocumentsPath + System.SysUtils.PathDelim + 'Helper.json');
end;

procedure TForm4.Button4Click(Sender: TObject);
begin
  JSONHelper1.RecNo := 1;
  JSONHelper1.FieldByName['mesaj'] := 'is it worked?';
  Button5Click(Sender);
end;

procedure TForm4.Button5Click(Sender: TObject);
begin
  ListBox1.Items.BeginUpdate;
  ListBox1.Items.Clear;
  try
    with JsonHelper1 do
    begin
      while not EOF do
      begin
        ListBox1.Items.Add(FieldByName['mesaj']);
        Next;
      end;
    end;
  finally
    ListBox1.Items.EndUpdate;
  end;
end;

end.
