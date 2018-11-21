(*******************************************************************************
*                      Copyright 2018 Oamaru Group Inc.                        *
*                                                                              *
*Permission is hereby granted, free of charge, to any person obtaining a copy  *
*of this software and associated documentation files (the "Software"), to deal *
*in the Software without restriction, including without limitation the rights  *
*to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     *
*copies of the Software, and to permit persons to whom the Software is         *
*furnished to do so, subject to the following conditions:                      *
*                                                                              *
*The above copyright notice and this permission notice shall be included in all*
*copies or substantial portions of the Software.                               *
*                                                                              *
*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
*IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      *
*FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   *
*AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        *
*LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, *
*OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE *
*SOFTWARE.                                                                     *
*******************************************************************************)
unit APM.Span;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections;

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
  public
    constructor Create; overload;
    constructor Create(AAPMSpan: TAPMSpan); overload;
    destructor Destroy; override;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property ID: String read FID write FID;
    property TraceID: String read FTraceID write FTraceID;
    property TransactionID: String read FTransactionID write FTransactionID;
    property ParentID: String read FParentID write FParentID;
    property Parent: Integer read FParent write FParent;
    property Name: String read FName write FName;
    property SpanType: String read FType write FType;
    property Start: Double read FStart write FStart;
    property Duration: Double read FDuration write FDuration;
    property StackTrace: TList<String> read FStackTrace;
    property Context: TAPMContext read FContext;
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
  FStackTrace := TList<String>.Create;
  FContext := TAPMContext.Create;
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
  FStackTrace := TList<String>.Create;
  for i := 0 to (AAPMSpan.StackTrace.Count - 1) do
    FStackTrace.Add(AAPMSpan.StackTrace[i]);
  FContext := TAPMContext.Create(AAPMSpan.Context);
end;

destructor TAPMSpan.Destroy;
begin
  FStackTrace.Free;
  FContext.Free;
end;

function TAPMSpan.GetJSONObject: TJSONObject;
var
  LStackStrce: TJSONArray;
  i: Integer;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', FID);
  Result.AddPair('trace_id', FTraceID);
  Result.AddPair('parent_id', FParentID);
  Result.AddPair('transaction_id', FTransactionID);
  Result.AddPair('parent', TJSONNUmber.Create(FParent));
  Result.AddPair('name', FName);
  Result.AddPair('type', FType);
  Result.AddPair('start', TJSONNUmber.Create(FStart));
  Result.AddPair('duration', TJSONNUmber.Create(FDuration));
  LStackStrce := TJSONArray.Create;
  for i := 0 to (FStackTrace.Count - 1) do
     LStackStrce.Add(FStackTrace[i]);
  Result.AddPair('stacktrace', LStackStrce);
  Result.AddPair('context', FContext.GetJSONObject);
end;

function TAPMSpan.GetJSONString: String;
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

end.




