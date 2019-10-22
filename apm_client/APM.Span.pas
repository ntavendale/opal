(*******************************************************************************
*                                                                              *
*                      Copyright 2018 Oamaru Group Inc.                        *
*                                                                              *
* Permission is hereby granted, free of charge, to any person obtaining a copy *
* of this software and associated documentation files (the "Software"), to     *
* deal in the Software without restriction, including without limitation the   *
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or  *
* sell copies of the Software, and to permit persons to whom the Software is   *
* furnished to do so, subject to the following conditions:                     *
*                                                                              *
* The above copyright notice and this permission notice shall be included in   *
* all copies or substantial portions of the Software.                          *
*                                                                              *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS *
* IN THE SOFTWARE.                                                             *
*                                                                              *
*******************************************************************************)
unit APM.Span;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.DateUtils,
  System.Generics.Collections, APM.Utils, APM.Context;

//Documentation: https://www.elastic.co/guide/en/apm/server/6.5/span-api.html
//Example: https://www.elastic.co/guide/en/apm/server/current/example-intakev2-events.html
//{"id":"0123456a89012345","trace_id":"0123456789abcdef0123456789abcdef","parent_id":"ab23456a89012345","transaction_id":"ab23456a89012345","parent":1,"name":"GET \/api\/types","type":"request","start":1.845,"duration":3.5642981,"stacktrace":[],"context": {}  }

type
  TAPMDBContext = class
  protected
    FInstance: String;
    FStatement: String;
    FDBType: String;
    FUser: String;
  public
    constructor Create; overload;
    constructor Create(AAPMDBContext: TAPMDBContext); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Instance: String read FInstance write FInstance;
    property Statement: String read FStatement write FStatement;
    property DBType: String read FDBType write FDBType;
    property User: String read FUser write FUser;
  end;

  TAPMhttpContext = class
  protected
    FURL: String;
    FStatusCode: Integer;
    FMethod: String;
  public
    constructor Create; overload;
    constructor Create(AAPMhttpContext: TAPMhttpContext); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property URL: String read FURL write FURL;
    property StatusCode: Integer read FStatusCode write FStatusCode;
    property Method: String read FMethod write FMethod;
  end;

  TAPMContext = class
  protected
    FDB: TAPMDBContext;
    Fhttp: TAPMhttpContext;
  public
    constructor Create; overload;
    constructor Create(AAPMContext: TAPMContext); overload;
    destructor Destroy; override;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property DBContext: TAPMDBContext read FDB;
    property httpContext: TAPMhttpContext read Fhttp;
  end;

  TAPMSpan = class
  protected
    FID: String;
    FTraceID: String;
    FTransactionID: String;
    FParentID: String;
    FParent: Integer;
    FName: String;
    FType: String;
    FStart: Double;
    FDuration: Double;
    FStackTrace: TList<String>;
    FContext: TAPMContext;
    FStopwatch: TStopwatch;
    FTimeStamp: Int64;
  public
    constructor Create; overload;
    constructor Create(AAPMSpan: TAPMSpan); overload;
    destructor Destroy; override;
    procedure BeginSpan;
    procedure EndSpan;
    function GetJSONObject(ARequestBodyFormat: Boolean = FALSE): TJSONObject;
    function GetJSONString(ARequestBodyFormat: Boolean = FALSE): String;
    procedure SetTimeStamp(ADateTime: TDateTime; AIsUTC: Boolean = FALSE);
    property ID: String read FID write FID;
    property TraceID: String read FTraceID write FTraceID;
    property TransactionID: String read FTransactionID write FTransactionID;
    property ParentID: String read FParentID write FParentID;
    property Parent: Integer read FParent write FParent;
    property Name: String read FName write FName;
    property SpanType: String read FType write FType;
    property Start: Double read FStart write FStart;
    property Duration: Double read FDuration write FDuration;
    property TimeStamp: Int64 read FTimeStamp write FTimeStamp;
    property StackTrace: TList<String> read FStackTrace;
    property Context: TAPMContext read FContext;
  end;

  TSpans = class
  protected
    FList: TObjectList<TAPMSpan>;
    function GetCount: Integer;
    function GetListItem(AIndex: Integer): TAPMSpan;
    procedure SetListItem(AIndex: Integer; AValue: TAPMSpan);
  public
    constructor Create; overload;
    constructor Create(ASpans: TSpans); overload;
    destructor Destroy; override;
    procedure Add(AValue: TAPMSpan);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    property Count: Integer read GetCount;
    property Spans[AIndex: Integer]: TAPMSpan read GetListItem write SetListItem; default;
  end;

implementation

{$REGION 'TAPMDBContext'}
constructor TAPMDBContext.Create;
begin
  FInstance := String.Empty;
  FStatement := String.Empty;
  FDBType := String.Empty;
  FUser := String.Empty;
end;

constructor TAPMDBContext.Create(AAPMDBContext: TAPMDBContext);
begin
  FInstance := AAPMDBContext.Instance;
  FStatement := AAPMDBContext.Statement;
  FDBType := AAPMDBContext.DBType;
  FUser := AAPMDBContext.User;
end;

function TAPMDBContext.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('instance', FInstance);
  Result.AddPair('statement', FStatement);
  Result.AddPair('type', FDBType);
  Result.AddPair('user', FUser);
end;

function TAPMDBContext.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMhttpContext'}
constructor TAPMhttpContext.Create;
begin
  FURL := String.Empty;
  FStatusCode := 0;
  FMethod := String.Empty;
end;

constructor TAPMhttpContext.Create(AAPMhttpContext: TAPMhttpContext);
begin
  FURL := AAPMhttpContext.URL;
  FStatusCode := AAPMhttpContext.StatusCode;
  FMethod := AAPMhttpContext.Method;
end;

function TAPMhttpContext.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('url', FURL);
  Result.AddPair('status_code', TJSONNumber.Create(FStatusCode));
  Result.AddPair('method', FMethod);
end;

function TAPMhttpContext.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMContext'}
constructor TAPMContext.Create;
begin
  FDB := TAPMDBContext.Create;
  Fhttp := TAPMhttpContext.Create;
end;

constructor TAPMContext.Create(AAPMContext: TAPMContext);
begin
  FDB := TAPMDBContext.Create(AAPMContext.DBContext);
  Fhttp := TAPMhttpContext.Create(AAPMContext.httpContext);
end;

destructor TAPMContext.Destroy;
begin
  FDB.Free;
  Fhttp.Free;
  inherited Destroy;
end;

function TAPMContext.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  if not String.IsNullOrWhitespace(FDB.FInstance) then
    Result.AddPair('db', FDB.GetJSONObject);
  if not String.IsNullOrWhitespace(Fhttp.URL) then
    Result.AddPair('http', Fhttp.GetJSONObject);
end;

function TAPMContext.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMSpan'}
constructor TAPMSpan.Create;
begin
  FID := String.Empty;
  FTraceID := String.Empty;
  FTransactionID := String.Empty;
  FParentID := String.Empty;
  FParent := 0;
  FName := String.Empty;
  FType := String.Empty;
  FStart := 0.00;
  FDuration := 0.00;
  FTimeStamp := 0;
  FStackTrace := TList<String>.Create;
  FContext := TAPMContext.Create;
  FStopwatch := TStopwatch.Create;
end;

constructor TAPMSpan.Create(AAPMSpan: TAPMSpan);
var
  i: Integer;
begin
  FID := AAPMSpan.ID;
  FTraceID := AAPMSpan.TraceID;
  FTransactionID := AAPMSpan.TransactionID;
  FParentID := AAPMSpan.ParentID;
  FParent := AAPMSpan.Parent;
  FName := AAPMSpan.Name;
  FType := AAPMSpan.SpanType;
  FStart := AAPMSpan.Start;
  FDuration := AAPMSpan.Duration;
  FTimeStamp := AAPMSpan.TimeStamp;
  FStackTrace := TList<String>.Create;
  for i := 0 to (AAPMSpan.StackTrace.Count - 1) do
    FStackTrace.Add(AAPMSpan.StackTrace[i]);
  FContext := TAPMContext.Create(AAPMSpan.Context);
  FStopwatch := TStopwatch.Create;
end;

destructor TAPMSpan.Destroy;
begin
  FStopwatch.Free;
  FStackTrace.Free;
  FContext.Free;
end;

procedure TAPMSpan.BeginSpan;
begin
  FStopwatch.Start;
end;

procedure TAPMSpan.EndSpan;
begin
  FStopwatch.Stop;
  FDuration := FStopwatch.ElapsedMilliseconds;
end;

function TAPMSpan.GetJSONObject(ARequestBodyFormat: Boolean = FALSE): TJSONObject;
var
  LSpanObj: TJSONObject;
  LStackStrce: TJSONArray;
  i: Integer;
begin
  LSpanObj := TJSONObject.Create;
  LSpanObj.AddPair('id', FID);
  LSpanObj.AddPair('trace_id', FTraceID);
  LSpanObj.AddPair('parent_id', FParentID);
  LSpanObj.AddPair('transaction_id', FTransactionID);
  LSpanObj.AddPair('parent', TJSONNUmber.Create(FParent));
  LSpanObj.AddPair('name', FName);
  LSpanObj.AddPair('type', FType);
  LSpanObj.AddPair('start', TJSONNUmber.Create(FStart));
  LSpanObj.AddPair('duration', TJSONNUmber.Create(FDuration));
  LStackStrce := TJSONArray.Create;
  for i := 0 to (FStackTrace.Count - 1) do
     LStackStrce.Add(FStackTrace[i]);
  LSpanObj.AddPair('stacktrace', LStackStrce);
  LSpanObj.AddPair('context', FContext.GetJSONObject);
  if ARequestBodyFormat then
  begin
    Result := TJSONObject.Create;
    Result .AddPair('span', LSpanObj);
  end else
    Result := LSpanObj;
end;

function TAPMSpan.GetJSONString(ARequestBodyFormat: Boolean = FALSE): String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject(ARequestBodyFormat);
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;

procedure TAPMSpan.SetTimeStamp(ADateTime: TDateTime; AIsUTC: Boolean = FALSE);
begin
  FTimestamp := DateTimeToUnix(ADateTime, AIsUTC) * 1000000;
end;
{$ENDREGION}

{$REGION 'TSpans'}
constructor TSpans.Create;
begin
  FList := TObjectList<TAPMSpan>.Create(TRUE);
end;

constructor TSpans.Create(ASpans: TSpans);
var
  i: Integer;
begin
  FList := TObjectList<TAPMSpan>.Create(TRUE);
  for i := 0 to (ASpans.Count - 1) do
    FList.Add(TAPMSpan.Create(ASpans[i]));
end;

destructor TSpans.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TSpans.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSpans.GetListItem(AIndex: Integer): TAPMSpan;
begin
  Result := FList[AIndex];
end;

procedure TSpans.SetListItem(AIndex: Integer; AValue: TAPMSpan);
begin
  FList[AIndex] := AValue;
end;

procedure TSpans.Add(AValue: TAPMSpan);
begin
  FList.Add(AValue);
end;

procedure TSpans.Delete(AIndex: Integer);
begin
  FList.Delete(AIndex);
end;

procedure TSpans.Clear;
begin
  FList.Clear;
end;
{$ENDREGION}
end.




