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
unit TransactionTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, WinAPI.Windows, System.DateUtils,
  APM.MetaData, APM.Transaction, UtilityRoutines, EndpointClient;

type
  TTransactionTest = class
  protected
    FEndpoint: String;
    FPort: WORD;
    FServiceName: String;
    FMetadata: TAPMMetadata;
    FTransaction: TAPMTransaction;
    FTraceID: String;
  public
    constructor Create(AEndpoint: String; APort: WORD; AServiceName: String; ATraceID: String);
    destructor Destroy; override;
    procedure Load;
    function Send: String;
  end;

implementation

constructor TTransactionTest.Create(AEndpoint: String; APort: WORD; AServiceName: String; ATraceID: String);
begin
  FEndpoint := AEndpoint;
  FServiceName := AServiceName;
  FPort := APort;
  FMetadata := TAPMMetadata.Create;
  FTransaction := TAPMTransaction.Create;
  FTransaction.TraceID := ATraceID;
end;

destructor TTransactionTest.Destroy;
begin
  FTransaction.Free;
  FMetadata.Free;
  inherited Destroy;
end;

procedure TTransactionTest.Load;
var
  i: Integer;
  LDomain, LUser: String;
begin
  FMetadata.AddService;
  FMetadata.Service.Name := FServiceName;
  FMetadata.Service.AgentName := 'Delphi';
  FMetadata.Service.AgentVersion := '1.0';
  FMetadata.Service.LanguageName := 'Delphi';
  {$IFDEF VER150}FMetadata.Service.LanguageVersion := 'Delphi 7';{$ENDIF}
  {$IFDEF VER160}FMetadata.Service.LanguageVersion := 'Delphi 8';{$ENDIF}
  {$IFDEF VER170}FMetadata.Service.LanguageVersion := 'Delphi 2005';{$ENDIF}
  {$IFDEF VER180}FMetadata.Service.LanguageVersion := 'Delphi 2006';{$ENDIF}
  {$IFDEF VER180}FMetadata.Service.LanguageVersion := 'Delphi 2007';{$ENDIF}
  {$IFDEF VER185}FMetadata.Service.LanguageVersion := 'Delphi 2007';{$ENDIF}
  {$IFDEF VER200}FMetadata.Service.LanguageVersion := 'Delphi 2009';{$ENDIF}
  {$IFDEF VER210}FMetadata.Service.LanguageVersion := 'Delphi 2010';{$ENDIF}
  {$IFDEF VER220}FMetadata.Service.LanguageVersion := 'Delphi XE';{$ENDIF}
  {$IFDEF VER230}FMetadata.Service.LanguageVersion := 'Delphi XE2';{$ENDIF}
  {$IFDEF VER240}FMetadata.Service.LanguageVersion := 'Delphi XE3';{$ENDIF}
  {$IFDEF VER250}FMetadata.Service.LanguageVersion := 'Delphi XE4';{$ENDIF}
  {$IFDEF VER260}FMetadata.Service.LanguageVersion := 'Delphi XE5';{$ENDIF}
  {$IFDEF VER265}FMetadata.Service.LanguageVersion := 'Appmethod 1.0';{$ENDIF}
  {$IFDEF VER270}FMetadata.Service.LanguageVersion := 'Delphi XE6';{$ENDIF}
  {$IFDEF VER280}FMetadata.Service.LanguageVersion := 'Delphi XE7';{$ENDIF}
  {$IFDEF VER290}FMetadata.Service.LanguageVersion := 'Delphi XE8';{$ENDIF}
  {$IFDEF VER300}FMetadata.Service.LanguageVersion := 'Delphi 10 Seattle';{$ENDIF}
  {$IFDEF VER310}FMetadata.Service.LanguageVersion := 'Delphi 10.1 Berlin';{$ENDIF}
  {$IFDEF VER320}FMetadata.Service.LanguageVersion := 'Delphi 10.2 Tokyo';{$ENDIF}
  {$IFDEF VER330}FMetadata.Service.LanguageVersion := 'Delphi 10.3 Rio';{$ENDIF}
  FMetadata.AddProcess;
  FMetadata.Process.ProcessID := GetCurrentProcessID;
  FMetadata.Process.ParentProcessID := 0;
  FMetadata.Process.Title := 'APMTest';
  for i := 1 to ParamCount do
    FMetadata.Process.ArgV.Add(ParamStr(i));

  FMetadata.AddUser;
  LDomain := GetLoggedInDomain;
  LUser := GetLoggedInUserName;
  FMetadata.User.ID := GetSID(LUser, LDomain);
  FMetadata.User.UserName := String.Format('%s\%s', [LDomain, LUser]);

  FTransaction.ID := 'B3CBAD6DA38E4C1D89238D550885FC75';
  FTransaction.TraceID := GetTraceID;
  FTransaction.Name := 'POST';
  FTransaction.Duration := 300.6;
  FTransaction.TxResult := '200';
  FTransaction.TxType := 'POST';
  FTransaction.Sampled := FALSE;
  FTransaction.Timestamp := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(Now), TRUE) * 1000000;
end;

function TTransactionTest.Send: String;
var
  LEndpoint: TEndpointClient;
  LIndexDetail: TStringList;
begin
  Result := '';
  LEndpoint := TEndpointClient.Create(FEndpoint, FPort, String.Empty,String.Empty, 'intake/v2/events');
  try
    LIndexDetail := TStringList.Create;
    try
      LIndexDetail.Add(FMetadata.GetJsonString(TRUE));
      LIndexDetail.Add(FTransaction.GetJSONString(TRUE));
      try
        LEndpoint.PostContentType(LIndexDetail.Text, 'application/x-ndjson');
        Result := LEndpoint.StatusText + #13#10 + LIndexDetail.Text;
      except
        Result := LIndexDetail.Text;
      end;
    finally
      LIndexDetail.Free;
    end;

  finally
    LEndpoint.Free;
  end;
end;

end.


