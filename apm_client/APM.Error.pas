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
unit APM.Error;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  System.DateUtils;

//Documentation: https://www.elastic.co/guide/en/apm/server/6.5/error-api.html
//Example: https://www.elastic.co/guide/en/apm/server/current/example-intakev2-events.html
//{"error":{"id":"abcdef0123456789","timestamp":1533827045999000,"log":{"level":"custom log level","message":"Cannot read property 'baz' of undefined"}}}

type
  TAPMException = class
  protected
    FCode: String;
    FMessage: String;
    FModule: String;
    FStackTrace: TList<String>;
    FExceptionType: String;
    FHandled: Boolean;
  public
    constructor Create; overload;
    constructor Create(AAPMException: TAPMException); overload;
    destructor Destroy; override;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Code: String read FCode write FCode;
    property ExceptionMessage: String read FMessage write FMessage;
    property Module: String read FModule write FModule;
    property StackTrace: TList<String> read FStackTrace;
    property ExceptionType: String read FExceptionType write FExceptionType;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TAPMLog = class
  protected
    FLevel: String;
    FLoggerName: String;
    FLogMessage: String;
    FParamMessage: String;
    FStackTrace: TList<String>;
  public
    constructor Create; overload;
    constructor Create(AAPMLog: TAPMLog); overload;
    destructor Destroy; override;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Level: String read FLevel write FLevel;
    property LoggerName: String read FLoggerName write FLoggerName;
    property LogMessage: String read FLogMessage write FLogMessage;
    property ParamMessage: String read FParamMessage write FParamMessage;
    property StackTrace: TList<String> read FStackTrace;
  end;

  //TraceID, TransactionID & ParentID are all or none. i.e.All must be set or none should be set.
  TAPMError = class
  protected
    FID: String;
    FTimeStamp: Int64; //Does not appear in documentation but shows up in sample request body (https://www.elastic.co/guide/en/apm/server/current/example-intakev2-events.html)
                       //Number of Microseconds past unix epoch (01/01/1970 00:00:00.000)
    FTraceID: String;
    FTransactionID: String;
    FParentID: String;
    FCulprit: String;
    FGroupingKey: String;
    FException: TAPMException;
    FLog: TAPMLog;
  public
    constructor Create; overload;
    constructor Create(AAPMError: TAPMError); overload;
    destructor Destroy; override;
    procedure SetTimeStamp(ADateTime: TDateTime; AIsUTC: Boolean = FALSE);
    function GetJSONObject(ARequestBodyFormat: Boolean = FALSE): TJSONObject;
    function GetJSONString(ARequestBodyFormat: Boolean = FALSE): String;
    property ID: String read FID write FID;
    property TimeStamp: Int64 read FTimeStamp write FTimeStamp;
    property TraceID: String read FTraceID write FTraceID;
    property TransactionID: String read FTransactionID write FTransactionID;
    property ParentID: String read FParentID write FParentID;
    property Culprit: String read FCulprit write FCulprit;
    property Exception: TAPMException read FException;
    property GroupingKey: String read FGroupingKey write FGroupingKey;
    property Log: TAPMLog read FLog;
  end;

  TErrors = class
  protected
    FList: TObjectList<TAPMError>;
    function GetCount: Integer;
    function GetListItem(AIndex: Integer): TAPMError;
    procedure SetListItem(AIndex: Integer; AValue: TAPMError);
  public
    constructor Create; overload;
    constructor Create(AErrors: TErrors); overload;
    destructor Destroy; override;
    procedure Add(AValue: TAPMError);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    property Count: Integer read GetCount;
    property Errors[AIndex: Integer]: TAPMError read GetListItem write SetListItem; default;
  end;

implementation

{$REGION 'TAPMException'}
constructor TAPMException.Create;
begin
  FCode := String.Empty;
  FMessage := String.Empty;
  FModule := String.Empty;
  FStackTrace := TList<String>.Create;
  FExceptionType := String.Empty;
  FHandled := FALSE;
end;

constructor TAPMException.Create(AAPMException: TAPMException);
var
  i: Integer;
begin
  FCode := AAPMException.Code;
  FMessage := AAPMException.ExceptionMessage;
  FModule := AAPMException.Module;
  FStackTrace := TList<String>.Create;
  for i := 0 to (AAPMException.StackTrace.Count - 1) do
    FStackTrace.Add(AAPMException.StackTrace[i]);
  FExceptionType := AAPMException.ExceptionType;
  FHandled := AAPMException.Handled;
end;

destructor TAPMException.Destroy;
begin
  FStackTrace.Free;
  inherited Destroy;
end;

function TAPMException.GetJSONObject: TJSONObject;
var
  LStackTrace: TJSONArray;
  LTrace: String;
begin
  Result := TJSONObject.Create;
  Result.AddPair('code', FCode);
  Result.AddPair('message', FMessage);
  Result.AddPair('module', FModule);
  Result.AddPair('attributes', TJSONNUll.Create);

  if FStackTrace.Count > 0 then
  begin
    LStackTrace := TJSONArray.Create;
    for LTrace in FStackTrace do
      LStackTrace.Add(LTrace);
    Result.AddPair('stacktrace', LStackTrace);
  end else
    Result.AddPair('stacktrace', TJSONNUll.Create);

  Result.AddPair('type', FExceptionType);
  Result.AddPair('handled', TJSONBool.Create(FHandled));
end;

function TAPMException.GetJSONString: String;
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

{$REGION 'TAPMLog'}
constructor TAPMLog.Create;
begin
  FLevel := String.Empty;
  FLoggerName := String.Empty;
  FLogMessage := String.Empty;
  FParamMessage := String.Empty;
  FStackTrace := TList<String>.Create;
end;

constructor TAPMLog.Create(AAPMLog: TAPMLog);
var
  i: Integer;
begin
  FLevel := AAPMLog.Level;
  FLoggerName := AAPMLog.LoggerName;
  FLogMessage := AAPMLog.LogMessage;
  FParamMessage := AAPMLog.ParamMessage;
  FStackTrace := TList<String>.Create;
  for i := 0 to (AAPMLog.StackTrace.Count - 1) do
  begin
    FStackTrace.Add(AAPMLog.StackTrace[i]);
  end;
end;

destructor TAPMLog.Destroy;
begin
  FStackTrace.Free;
  inherited Destroy;
end;

function TAPMLog.GetJSONObject: TJSONObject;
var
  LStackTrace: TJSONArray;
  LTrace: String;
begin
  Result := TJSONObject.Create;
  Result.AddPair('level', FLevel);
  Result.AddPair('logger_name', FLoggerName);
  Result.AddPair('message', FLogMessage);
  Result.AddPair('param_message', FParamMessage);
  if FStackTrace.Count > 0 then
  begin
    LStackTrace := TJSONArray.Create;
    for LTrace in FStackTrace do
      LStackTrace.Add(LTrace);
    Result.AddPair('stacktrace', LStackTrace);
  end
end;

function TAPMLog.GetJSONString: String;
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

{$REGION 'TAPMError'}
constructor TAPMError.Create;
begin
  FID := String.Empty;
  FTimeStamp := 0;
  FTraceID := String.Empty;
  FTransactionID := String.Empty;
  FParentID := String.Empty;
  FCulprit := String.Empty;
  FException := TAPMException.Create;
  FLog := TAPMLog.Create;
end;

constructor TAPMError.Create(AAPMError: TAPMError);
begin
  FID := AAPMError.ID;
  FTimeStamp := AAPMError.TimeStamp;
  FTraceID := AAPMError.TraceID;
  FTransactionID := AAPMError.TransactionID;
  FParentID := AAPMError.ParentID;
  FCulprit := AAPMError.Culprit;
  FException := TAPMException.Create(AAPMError.Exception);
  FLog := TAPMLog.Create(AAPMError.Log);
end;

destructor TAPMError.Destroy;
begin
  FLog.Free;
  FException.Free;
  inherited Destroy;
end;

procedure TAPMError.SetTimeStamp(ADateTime: TDateTime; AIsUTC: Boolean = FALSE);
begin
  FTimestamp := DateTimeToUnix(ADateTime, AIsUTC) * 1000000;
end;

function TAPMError.GetJSONObject(ARequestBodyFormat: Boolean = FALSE): TJSONObject;
var
  LErrorObj: TJSONObject;
  LStackTrace: TJSONArray;
  LTrace: String;
begin
  LErrorObj := TJSONObject.Create;
  LErrorObj.AddPair('id', FID);
  LErrorObj.AddPair('timestamp', TJSONNUmber.Create(FTimestamp));
  LErrorObj.AddPair('trace_id', FTraceID);
  LErrorObj.AddPair('transaction_id', FTransactionID);
  LErrorObj.AddPair('parent_id', FParentID);
  LErrorObj.AddPair('culprit', FCulprit);
  if not String.IsNullOrWhiteSpace(FGroupingKey) then
    LErrorObj.AddPair('grouping_key', FGroupingKey);

  if (not String.IsNullOrWhitespace(FException.ExceptionType)) or (not String.IsNullOrWhitespace(FException.ExceptionMessage)) then
  begin
    LErrorObj.AddPair('exception', FException.GetJSONObject);
  end;
  if not String.IsNullOrWhitespace(FLog.LogMessage) then
  begin
    LErrorObj.AddPair('log', FLog.GetJSONObject);
  end;
  if ARequestBodyFormat then
  begin
    Result := TJSONObject.Create;
    Result.AddPair('error', LErrorObj);
  end
  else
    Result := LErrorObj;
end;

function TAPMError.GetJSONString(ARequestBodyFormat: Boolean = FALSE): String;
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
{$ENDREGION}

{$REGION 'TErrors'}
constructor TErrors.Create;
begin
  FList := TObjectList<TAPMError>.Create(TRUE);
end;

constructor TErrors.Create(AErrors: TErrors);
var
  i: Integer;
begin
  FList := TObjectList<TAPMError>.Create(TRUE);
  for i := 0 to (AErrors.Count - 1) do
    FList.Add(TAPMError.Create(AErrors[i]));
end;

destructor TErrors.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TErrors.GetCount: Integer;
begin
  Result := FList.Count;
end;

function Terrors.GetListItem(AIndex: Integer): TAPMError;
begin
  Result := FList[AIndex];
end;

procedure Terrors.SetListItem(AIndex: Integer; AValue: TAPMError);
begin
  FList[AIndex] := AValue;
end;

procedure Terrors.Add(AValue: TAPMError);
begin
  FList.Add(AValue);
end;

procedure Terrors.Delete(AIndex: Integer);
begin
  FList.Delete(AIndex);
end;

procedure Terrors.Clear;
begin
  FList.Clear;
end;
{$ENDREGION}

end.
