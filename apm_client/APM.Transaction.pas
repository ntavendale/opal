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
unit APM.Transaction;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections;

type
  TSpanCount = class
  protected
    FStarted: Cardinal;
    FDropped: Integer;
  public
    constructor Create; overload;
    constructor Create(ASpanCount: TSpanCount); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Started: Cardinal read FStarted write FStarted;
    property Dropped: Integer read FDropped write FDropped;
  end;

  TAPMTransaction = class
  protected
    FDuration: Double;
    FName: String;
    FResult: String;
    FTxType: String;
    FTimestamp: UInt64; //In sample, but not in documentation. Appears as unsingend int.
    FSampled: Boolean;
    FID: String;
    FTransactionType: String;
    FTraceID: String;
    FParentID: String;
    FSpanCount: TSpanCount;
  public
    constructor Create; overload;
    constructor Create(AAPMTransaction: TAPMTransaction); overload;
    destructor Destroy; override;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Duration: Double read FDuration write FDuration;
    property Name: String read FName write FName;
    property TxResult: String read FResult write FResult;
    property TxType: String read FTxType write FTxType;
    property Timestamp: UInt64 read FTimestamp write FTimestamp;
    property Sampled: Boolean read FSampled write FSampled;
    property ID: String read FID write FID;
    property TraceID: String read FTraceID write FTraceID;
    property ParentID: String read FParentID write FParentID;
    property SpanCount: TSpanCount read FSpanCount;
  end;

implementation

{$REGION 'TSpanCount'}
constructor TSpanCount.Create;
begin
  FStarted := 0;
  FDropped := -1;
end;

constructor TSpanCount.Create(ASpanCount: TSpanCount);
begin
  FStarted := ASpanCount.Started;
  FDropped := ASpanCount.Dropped;
end;

function TSpanCount.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('started', TJSONNumber.Create(FStarted));
  if FDropped > -1 then
    Result.AddPair('dropped', TJSONNumber.Create(FDropped));
end;

function TSpanCount.GetJSONString: String;
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

{$REGION 'TAPMTransaction'}
constructor TAPMTransaction.Create;
begin
  FDuration := 0.00;
  FName := String.Empty;
  FResult := String.Empty;
  FTxType := String.Empty;
  FTimestamp := 0;
  FSampled := TRUE;
  FID := String.Empty;
  FTraceID := String.Empty;
  FParentID := String.Empty;
  FSpanCount := TSpanCount.Create;
end;

constructor TAPMTransaction.Create(AAPMTransaction: TAPMTransaction);
begin
  FDuration := AAPMTransaction.Duration;
  FName := AAPMTransaction.Name;
  FResult := AAPMTransaction.TxResult;
  FTxType := AAPMTransaction.TxType;
  FSampled := AAPMTransaction.Sampled;
  FTimestamp := AAPMTransaction.Timestamp;
  FID := AAPMTransaction.ID;
  FTraceID := AAPMTransaction.TraceID;
  FParentID := AAPMTransaction.ParentID;
  FSpanCount := TSpanCount.Create(AAPMTransaction.SpanCount);
end;

destructor TAPMTransaction.Destroy;
begin
  FSpanCount.Free;
  inherited Destroy;
end;

function TAPMTransaction.GetJSONObject: TJSONObject;
begin
  //ES Documentation sample (https://www.elastic.co/guide/en/apm/server/current/example-intakev2-events.html)
  //{ "transaction": { "trace_id": "01234567890123456789abcdefabcdef", "id": "abcdef1478523690", "type": "request", "duration": 32.592981, "timestamp": 1535655207154000, "result": "200", "context": null, "spans": null, "sampled": null, "span_count": { "started": 0 }}}
  Result := TJSONObject.Create;
  Result.AddPair('trace_id', FTraceID);
  Result.AddPair('id', FID);
  Result.AddPair('parent_id', FParentID);
  Result.AddPair('type', FTxType);
  Result.AddPair('duration', TJSONNumber.Create(FDuration));
  Result.AddPair('timestamp', TJSONNumber.Create(FTimestamp));
  Result.AddPair('result', FResult);
  Result.AddPair('context', TJSONNull.Create);
  Result.AddPair('spans', TJSONNull.Create);
  if not FSampled then
    Result.AddPair('sampled', TJSONBool.Create(FSampled))
  else
    Result.AddPair('sampled', TJSONNull.Create); //per sample above
  Result.AddPair('span_count', FSpanCount.GetJSONObject);
end;

function TAPMTransaction.GetJSONString: String;
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
