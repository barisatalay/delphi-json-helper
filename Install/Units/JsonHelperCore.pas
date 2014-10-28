unit JsonHelperCore;
{- Unit Info----------------------------------------------------------------------------
Unit Name  : JsonHelperCore
Created By : Barış Atalay 28/10/2014
Last Change By :

Web Site: http://brsatalay.blogspot.com.tr/

Notes: 
----------------------------------------------------------------------------------------}

interface
Uses
  System.Classes,System.SysUtils,
  Generics.Collections,
  FMX.Listbox,FMX.Forms,
  XSuperObject,
  IdHttp;

const
  NotActive = 'JSON Helper not  is not active!';
  NoItem = 'Items not found!';
  FieldName = 'Field name must not be null!';
  NoJson = 'Unsupported json format! Must JSON Array like this [{..},{..}]';
  NoWhere = 'Unsupported where clause! Must where clause like this ''manga:"naruto", aktive:0 ... ''';
  DataNull = 'Response data is null.';
  HT = 'http';
  VA = 'Value';
  NullLJson = 'JSON is null!';
  NotSort = 'Is not sort able';

type
  TJSONHelper = class;

  TJSONHelper = class(TComponent)
    private
      FTimeOut: Integer;
      FActive: Boolean;
      WhereJSON,
      FData: ISuperObject;
      FFieldObject: TObjectList<TDictionary<String,Variant>>;
      FValues: TDictionary<String,Variant>;
      FIndex: Integer;
      SFList: String;
      FSortField: String;
      FJSON: TStringList;
      FOwner: TForm;
      procedure SetActive(const Value: Boolean);
      procedure Get;
      function GetFieldBy(const Name: String): Variant;
      procedure SetRaise(T:String);
      procedure SetFieldBy(const Name: String; const Value: Variant);
      function GetCount: Integer;
      function SAGet: String;
      function SFGet: String;
      procedure SFSet(const Value: String);
      procedure AktifKontrol;
      procedure DoSort;
      function GetsJSON: TStringList;
      procedure SetJSON(const Value: TStringList);
    public
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;
      procedure First;
      procedure Last;
      function EOF:Boolean;
      function BOF: Boolean;
      procedure Next;
      procedure Previous;
      function GetJson:String;
      property Count: Integer read GetCount;
      property FieldByName[const Name: String] : Variant read GetFieldBy write SetFieldBy;
      property RecNo: Integer read FIndex write FIndex;
      procedure SaveFile(AFile: String);
      function FromFile(AFile: String): String;
    published
      property JSON: TStringList read GetsJSON write SetJSON ;
      property Active: Boolean read FActive write SetActive;
      property TimeOut: Integer read FTimeOut write FTimeOut;
      property SortAble: String read SAGet;
      property SortField: String read SFGet write SFSet;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Android', [TJsonHelper]);
end;

{ TMangaCore }

procedure TJSONHelper.AktifKontrol;
begin
  if not FActive then SetRaise(NotActive);
end;

function TJsonHelper.BOF: Boolean;
begin
  AktifKontrol;
  if FIndex = 0 then
    Result := True
  else if FIndex > 0 then
    Result := False;
end;

constructor TJsonHelper.Create(AOwner: TComponent);
begin
  inherited;
  FOwner := AOwner as TForm;
  FTimeOut := 5000;
  FFieldObject := TObjectList<TDictionary<String,Variant>>.Create;
  FJSON := TStringList.Create;
end;

destructor TJsonHelper.Destroy;
begin
  FJSON.Free;
  FFieldObject.Free;
  FValues.Free;
  inherited;
end;

procedure TJSONHelper.DoSort;
var
  AMember,
  OMember: IMember;
begin
  if Trim(FSortField) <> '' then
    FData.A[VA].Sort(function(const Left, Right: ICast): Integer begin //SORT OLAYI BRADA
      Result := CompareText(Left.AsObject.S[FSortField], Right.AsObject.S[FSortField]);
    end);

  FFieldObject.Clear;

  for AMember in FData.A[VA] do
  begin
    FValues  := TDictionary<String,Variant>.Create;
    for OMember in AMember.AsObject do
      FValues.Add(OMember.Name,OMember.AsString);

    FFieldObject.Add(FValues);
  end;
  First;
end;

function TJsonHelper.EOF: Boolean;
begin
  AktifKontrol;

  if FIndex = FFieldObject.Count + 1 then
  begin
    Result := True;
    Dec(FIndex);
  end else
  if FIndex < FFieldObject.Count then
    Result := False;
end;

procedure TJsonHelper.First;
begin
  FIndex := 1;
end;

function TJSONHelper.FromFile(AFile: String): String;
{$REGION 'ParseStream'}
  function ParseStream(Stream: TStream): String;
  var
    Strm: TStringStream;
  begin
    Strm := TStringStream.Create;
    try
      Strm.LoadFromStream(Stream);
      Result := Strm.DataString ;
    finally
      Strm.Free;
    end;
  end;
{$ENDREGION}
var
  Strm: TFileStream;
begin
  Strm := TFileStream.Create(AFile, fmOpenRead, fmShareDenyWrite);
  try
    Result := ParseStream(Strm);
  finally
    Strm.Free;
  end;
end;

procedure TJsonHelper.Get;
var
  T: String;
  AMember,
  OMember: IMember;
  Q: Integer;
begin
  AktifKontrol;

  with TIdHTTP.Create(nil) do
  begin
    try
    ConnectTimeout := FTimeOut;
    ReadTimeout := FTimeOut;
    T := Copy(Trim(FJSON.Text),1,6);

    if Pos(HT,T) > 0 then
    begin
      T := Get(Trim(FJSON.text));
      if T.Trim = '' then
        SetRaise(DataNull);
    end else
      T := FJSON.Text;

    finally
      Disconnect;
      Free;
    end;
  end;

  FIndex := 1;
  {$IFDEF ANDROID}
  if (T[0] <> '[') and (T[Length(T)] <> ']') then
    SetRaise(NoJson);
  {$ELSE}
  if (T[1] <> '[') and (T[Length(T)] <> ']') then
    SetRaise(NoJson);
  {$ENDIF}


  T := '{ "' + VA + '":' + T;
  T := T + '}';

  if Pos('#$D',T) > 0 then
    T := T.Replace(#$D, '\r');

  if Pos('#$A',T) > 0 then
    T := T.Replace(#$D, '\r');

  FData := SO(T{.Replace(#$D, '\r').Replace(#$A, '\n')});

  Q := 0;
  for AMember in FData.A[VA] do
  begin
    if Q = 1 then Break;
    for OMember in AMember.AsObject do
    begin
      if not SFList.IsEmpty then SFList :=  SFList + ',';
      SFList := SFList + OMember.Name;
    end;
    Inc(Q);
  end;
  
  DoSort;
end;

function TJsonHelper.GetCount: Integer;
begin
  Result := FFieldObject.Count;
end;

function TJsonHelper.GetFieldBy(const Name: String): Variant;
begin
  AktifKontrol;
  Result := '';
  if Trim(Name) = '' then
    SetRaise(FieldName);

  if (FFieldObject.Count) < FIndex then
    SetRaise(NoItem);

  Result := FFieldObject.Items[FIndex - 1].Items[Name];
end;

function TJSONHelper.GetJSON: String;
var
  X:ISuperArray;
  XY:ISuperObject;
  K,
  I: Integer;
  Key: String;
begin
  X := SA;
  with FFieldObject do
  begin
    for I := 0 to Count -1  do
    begin
      XY := SO;
      for Key in Items[I].Keys do
        XY.S[Key]:= Items[I].Items[Key];
      X.Add(XY);
    end;
  end;
  Result := X.AsJSON;
end;

function TJSONHelper.GetsJSON: TStringList;
begin
  Result := FJSON;
end;

procedure TJsonHelper.Last;
begin
  AktifKontrol;
  FIndex := FFieldObject.Count - 1 ;
end;

procedure TJsonHelper.Next;
begin
  AktifKontrol;
  if FIndex <= FFieldObject.Count  then
    Inc(FIndex);
end;

procedure TJsonHelper.Previous;
begin
  AktifKontrol;
  if 1 < FIndex  then
    Dec(FIndex);
end;

function TJSONHelper.SAGet: String;
begin
  Result := SFList;
end;

procedure TJSONHelper.SaveFile(AFile: String);
var
  X: ISuperArray;
begin
  X := SA(GetJSON);
  X.SaveTo(AFile);
end;

procedure TJsonHelper.SetActive(const Value: Boolean);
begin
  FActive := Value;
  if Value = True then
  begin
    if Trim(FJSON.Text) = '' then
    begin
      SetRaise(NullLJson);
      FSortField := '';
      SFList := '';
      Exit;
    end;
    Get;
  end else
  begin
    FFieldObject.Clear;
    FSortField := '';
    SFList := '';
  end;
end;

procedure TJsonHelper.SetFieldBy(const Name: String; const Value: Variant);
begin
  if Trim(Name) = '' then
    SetRaise(FieldName );

  if (FFieldObject.Count) < FIndex then
    SetRaise(NoItem);

  FFieldObject.Items[FIndex - 1].Items[Name] := Value;
end;

procedure TJSONHelper.SetJSON(const Value: TStringList);
begin
  FJSON.Clear;
  FJSON.Assign(Value);
end;

procedure TJsonHelper.SetRaise(T: String);
begin
  raise Exception.Create(T);
end;

function TJSONHelper.SFGet: String;
begin
  Result := FSortField;
end;

procedure TJSONHelper.SFSet(const Value: String);
begin
  if (Pos(Value,SFList) = 0) and not (Trim(Value) = '') then
    SetRaise(NotSort);

  FSortField := Value;
  
  DoSort;
end;

end.

