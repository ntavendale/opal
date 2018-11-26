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
  APM.MetaData, APM.Transaction, EndpointClient;

type
  TTransactionTest = class
    protected
      FMetadata: TAPMMetadata;
      FTransaction: TAPMTransaction;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Load;
      function Send: String;
  end;

function GetLoggedInUserName: String;
function GetLoggedInDomain: String;
function GetSID(var UserName, DomainName:String):String;
function SIDToStr(Input:PSID):string;

implementation

function GetLoggedInUserName: String;
var
  pNameBuff: PChar;
  dwNameBuffSize: DWORD;
begin
  dwNameBuffSize := 0;
  GetUserName(nil, dwNameBuffSize);
  if ERROR_INSUFFICIENT_BUFFER = GetLastError then
  begin
    GetMem(pNameBuff, dwNameBuffSize * Sizeof(Char));
    try
      if GetUserName(pNameBuff, dwNameBuffSize) then
        Result := String(pNameBuff)
      else
        RaiseLastOSError;
    finally
      FreeMem(pNameBuff);
    end;
  end
  else
    RaiseLastOSError;
end;

function GetLoggedInDomain: String;
var
  SNU                : SID_NAME_USE;
  SID                : PSID;
  dwSidSize          : DWORD;
  pNameBuff          : array[0..80] of Char;
  dwNameBuffSize     : DWORD;
  pComputerBuff      : array[0..80] of Char;
  dwComputerBuffSize : DWORD;
  pRefDomain         : PChar;
  dwRefDomainSize    : DWORD;
begin
  SID := nil;
  //Get User Name
  dwNameBuffSize := Sizeof(pNameBuff);
  GetUserName(pNameBuff,dwNameBuffSize);
  //Get Computer Name
  dwComputerBuffSize := Sizeof(pComputerBuff);
  GetComputerName(pComputerBuff,dwComputerBuffSize);

  dwSidSize:=0; //Makes LookupAccountNameFail
                //When it fails with ERROR_INSUFFICIENT_BUFFER
                //it load dwSidSize with the correct buffer size
  dwRefDomainSize := SizeOf(pRefDomain);

  //Do the first lookup with an undersized sid buffer
  pRefDomain := nil;
  LookupAccountName(pComputerBuff,pNameBuff,SID,dwSidSize,pRefDomain,dwRefDomainSize,SNU);

  //Raise error if it is other than undersized buffer error we are expecting
  if GetLastError <> ERROR_INSUFFICIENT_BUFFER then RaiseLastOSError;

  GetMem(SID,dwSidSize);//Allocate memory for Sid
  GetMem(pRefDomain,(dwRefDomainSize * 2));

  //Do lookup again with correct account name
  if not LookupAccountName(pComputerBuff,pNameBuff,SID,dwSidSize,pRefDomain,dwRefDomainSize,SNU) then
    RaiseLastOSError
  else begin
    Result := String(pRefDomain);
  end;
  FreeMem(SID);//free up memory used for SID
  FreeMem(pRefDomain)
end;

function GetSID(var UserName, DomainName:String):String;
var
  SNU                : SID_NAME_USE;
  SID                : PSID;
  dwSidSize          : DWORD;
  pNameBuff          : array[0..80] of Char;
  dwNameBuffSize     : DWORD;
  pComputerBuff      : array[0..80] of Char;
  dwComputerBuffSize : DWORD;
  pRefDomain         : PChar;
  dwRefDomainSize    : DWORD;
begin
  SID := nil;
  //Get User Name
  dwNameBuffSize := Sizeof(pNameBuff);
  GetUserName(pNameBuff,dwNameBuffSize);
  UserName := String(pNameBuff);
  //Get Computer Name
  dwComputerBuffSize := Sizeof(pComputerBuff);
  GetComputerName(pComputerBuff,dwComputerBuffSize);

  dwSidSize:=0; //Makes LookupAccountNameFail
                //When it fails with ERROR_INSUFFICIENT_BUFFER
                //it load dwSidSize with the correct buffer size
  dwRefDomainSize := SizeOf(pRefDomain);

  //Do the first lookup with an undersized sid buffer
  pRefDomain := nil;
  LookupAccountName(pComputerBuff,pNameBuff,SID,dwSidSize,pRefDomain,dwRefDomainSize,SNU);

  //Raise error if it is other than undersized buffer error we are expecting
  if GetLastError <> ERROR_INSUFFICIENT_BUFFER then RaiseLastOSError;

  GetMem(SID,dwSidSize);//Allocate memory for Sid
  GetMem(pRefDomain,(dwRefDomainSize * 2));

  //Do lookup again with correct account name
  if not LookupAccountName(pComputerBuff,pNameBuff,SID,dwSidSize,pRefDomain,dwRefDomainSize,SNU) then
    RaiseLastOSError
  else begin
    DomainName := String(pRefDomain);
    Result:=SIDToStr(SID);
  end;
  FreeMem(SID);//free up memory used for SID
  FreeMem(pRefDomain)
end;

function SIDToStr(Input:PSID):string;
var
  psia             : PSIDIdentifierAuthority;
  dwSubAuthorities : DWORD;
  dwSidRev         : DWORD;
  dwCounter        : DWORD;
begin
  dwSidRev :=1;// SID_REVISION;
  if IsValidSid(Input) then
  begin
    psia:=GetSidIdentifierAuthority(Input);
    dwSubAuthorities:=GetSidSubAuthorityCount(Input)^;
    Result:=Format('S-%u-',[dwSidRev]);
    if (psia^.Value[0] <> 0) or (psia^.Value[1] <> 0) then
      Result:=Result + Format('0x%02x%02x%02x%02x%02x%02x',[psia^.Value[0],psia^.Value [1],psia^.Value [2],psia^.Value [3],psia^.Value[4],psia^.Value [5]])
    else
      Result:=Result+Format('%u',[DWORD (psia^.Value [5])+DWORD (psia^.Value [4] shl 8)+DWORD (psia^.Value [3] shl 16)+DWORD (psia^.Value [2] shl 24)]);
    for dwCounter := 0 to dwSubAuthorities - 1 do
      Result:=Result+Format ('-%u', [GetSidSubAuthority(Input,dwCounter)^])
  end else
  begin
    Result:='NULL';
    raise Exception.Create ('Invalid Security ID Exception');
  end;
end;

constructor TTransactionTest.Create;
begin
  FMetadata := TAPMMetadata.Create;
  FTransaction := TAPMTransaction.Create;
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
  FMetadata.Service.Name := 'Delphi Client Test Service';
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
  FTransaction.TraceID := '8D0A60147C904756A47145B219617350';
  FTransaction.Duration := 125.6;
  FTransaction.TxResult := '200';
  FTransaction.TxType := 'request';
  FTransaction.Sampled := FALSE;
  FTransaction.Timestamp := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(Now), TRUE) * 1000000;
end;

function TTransactionTest.Send: String;
var
  LEndpoint: TEndpointClient;
  LIndexDetail: TStringList;
begin
  Result := '';
  LEndpoint := TEndpointClient.Create('http://192.168.116.138', 8200, String.Empty,String.Empty, 'intake/v2/events');
  try
    LIndexDetail := TStringList.Create;
    try
      LIndexDetail.Add('{"metadata":' + FMetadata.GetJsonString + '}');
      LIndexDetail.Add('{"transaction":' + FTransaction.GetJSONString + '}');
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


