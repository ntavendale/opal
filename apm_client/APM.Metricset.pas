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
unit APM.Metricset;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections;

type
  TMetricSample = class
  protected
    FName: String;
    FValue: Double;
  public
    constructor Create(AName: String; AValue: Double); overload;
    constructor Create(AMetricSample: TMetricSample); overload;
    property Name: String read FName write FName;
    property Value: Double read FValue write FValue;
  end;

  TAPMMetricset = class
  protected
    FTimeStamp: UInt64;
    FList: TObjectList<TMetricSample>;
    function GetCount: Integer;
    function GetListItem(AIndex: Integer): TMetricSample;
    procedure SetListItem(AIndex: Integer; AValue: TMetricSample);
  public
    constructor Create; overload;
    constructor Create(AMetricset: TAPMMetricset); overload;
    destructor Destroy;
    procedure Add(AValue: TMetricSample);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Count: Integer read GetCount;
    property TimeStamp: UInt64 read FTimestamp write FTimestamp;
    property MetricSample[AIndex: Integer]: TMetricSample read GetListItem write SetListItem; default;
  end;

implementation

{$REGION 'TMetricSample'}
constructor TMetricSample.Create(AName: String; AValue: Double);
begin
  FName := AName;
  FValue := AValue;
end;

constructor TMetricSample.Create(AMetricSample: TMetricSample);
begin
  FName := AMetricSample.Name;
  FValue := AMetricSample.Value;
end;
{$ENDREGION}

{$REGION 'TAPMMetricset'}
constructor TAPMMetricset.Create;
begin
  FTimeStamp := 0;
  FList := TObjectList<TMetricSample>.Create(TRUE);
end;

constructor TAPMMetricset.Create(AMetricset: TAPMMetricset);
var
  i: Integer;
begin
  FTimeStamp := AMetricset.TimeStamp;
  FList := TObjectList<TMetricSample>.Create(TRUE);
  for i := 0 to (AMetricset.Count - 1) do
    FList.Add(TMetricSample.Create(AMetricset[i]));
end;

destructor TAPMMetricset.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TAPMMetricset.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAPMMetricset.GetListItem(AIndex: Integer): TMetricSample;
begin
  Result := FList[AIndex];
end;

procedure TAPMMetricset.SetListItem(AIndex: Integer; AValue: TMetricSample);
begin
  FList[AIndex] := AValue;
end;

procedure TAPMMetricset.Add(AValue: TMetricSample);
begin
  FList.Add(AValue);
end;

procedure TAPMMetricset.Delete(AIndex: Integer);
begin
  FList.Delete(AIndex);
end;

procedure TAPMMetricset.Clear;
begin
  FList.Clear;
end;

function TAPMMetricset.GetJSONObject: TJSONObject;
var
  LSamples, LSample: TJSONObject;
  i: Integer;
begin
  Result := TJSONObject.Create;
  LSamples  := TJSONObject.Create;
  for i := 0 to (FList.Count - 1) do
  begin
    LSample := TJSONObject.Create;
    LSample.AddPair('value', TJSONNUmber.Create(FList[i].Value));
    LSamples.AddPair(FList[i].Name, LSample);
  end;

  Result.AddPair('samples', LSamples);
  Result.AddPair('timestamp', TJSONNUmber.Create(FTimeStamp));
end;

function TAPMMetricset.GetJSONString: String;
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

