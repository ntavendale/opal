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
unit UtilityRoutines;

interface

uses
  System.SysUtils, System.Classes, System.JSON, WinAPI.Windows, System.DateUtils;

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

end.
