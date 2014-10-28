program XE7Example;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Units\Main.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
