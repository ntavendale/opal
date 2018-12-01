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
unit APM.Utils;

interface

uses
  System.SysUtils, System.Classes, System.Math, System.DateUtils, WinApi.Windows,
  WinApi.Messages;

type
  TInt64Rec = record
    case WORD of
    0: (AInt64: Int64);
    1: (ALowerInt32: Int32; AUpperInt32: Int32);
  end;

  T128Rec = record
    case WORD of
    0: (ALowerInt64: Int64; AUpperInt64: Int64);
    1: (AFirstInt32: Int32; ASecondInt32: Int32; AThirdInt32: Int32; AFourthInt32: Int32);
  end;
  TAPMUtils = class
  public
    class function Get64BitHexString(AInt64: Int64): String; overload;
    class function Get64BitHexString(AUpperInt32, ALowerInt32: Int32): String; overload;
    class function Get64BitHexString: String; overload;
    class function Get128BitHexString(AUpperInt64, ALowerInt64: Int64): String; overload;
    class function Get128BitHexString(AFourthInt32, AThirdInt32, ASecondInt32, AFirstInt32: Int32): String; overload;
    class function Get128BitHexString: String; overload;
    class function GetComputerName: String;
    class function GetPlatformName: String;
  end;

  TStopWatch = class
  private
    FTicksPerSecond: TLargeInteger;
    FStartTicks: TLargeInteger;
    FStopTicks: TLargeInteger;
    function GetElapsedSeconds: Double;
    function GetElapsedMilliseconds: Double;
    function GetElapsedMicroseconds: Double;
  public
    constructor Create;
    procedure Start;
    procedure Stop;
    class function CreateNew: TStopWatch;
    property ElapsedSeconds: Double read GetElapsedSeconds;
    property ElapsedMilliseconds: Double read GetElapsedMilliseconds;
    property ElapsedMicroseconds: Double read GetElapsedMicroseconds;
  end;

implementation

{$REGION 'TAPMUtils'}
class function TAPMUtils.Get64BitHexString(AInt64: Int64): String;
begin
  Result := String.Format('%.8x', [AInt64]);
  while Result.Length < 16 do
    Result := '0' + Result;
end;

class function TAPMUtils.Get64BitHexString(AUpperInt32, ALowerInt32: Int32): String;
var
  LRec: TInt64Rec;
begin
  LRec.AUpperInt32 := AUpperInt32;
  LRec.ALowerInt32 := ALowerInt32;
  Result := String.Format('%.8x', [LRec.AInt64]);
  while Result.Length < 16 do
    Result := '0' + Result;
end;

class function TAPMUtils.Get64BitHexString: String;
begin
  RandSeed := TTHread.GetTickCount;
  Result := Get64BitHexString(Random(MaxInt), Random(MaxInt));
end;

class function TAPMUtils.Get128BitHexString(AUpperInt64, ALowerInt64: Int64): String;
var
  L64: String;
begin
  L64 := String.Format('%.8x', [AUpperInt64]);
  while L64.Length < 16 do
    L64 := '0' + L64;

  Result := String.Format('%.8x', [ALowerInt64]);
  while Result.Length < 16 do
    Result := '0' + Result;
  Result := L64 + Result;
end;

class function TAPMUtils.Get128BitHexString(AFourthInt32, AThirdInt32, ASecondInt32, AFirstInt32: Int32): String;
var
  L64: String;
begin
  L64 := Get64BitHexString(AFourthInt32, AThirdInt32);
  while L64.Length < 16 do
    L64 := '0' + L64;

  Result := Get64BitHexString(ASecondInt32, AFirstInt32);
  while Result.Length < 16 do
    Result := '0' + Result;
  Result := L64 + Result;
end;

class function TAPMUtils.Get128BitHexString: String;
begin
  RandSeed := TTHread.GetTickCount;
  Result := Get128BitHexString(Random(MaxInt), Random(MaxInt), Random(MaxInt), Random(MaxInt));
end;

class function TAPMUtils.GetComputerName: String;
var
  LSize, LErr: DWORD;
  LBuff: PChar;
begin
  LSize := 0;
  GetComputerNameEx(ComputerNameDnsHostname, nil, LSize);
  LErr := GetLastError;
  if ERROR_MORE_DATA = LErr then
  begin
    GetMem(LBuff, (LSize + 1) * SizeOf(Char));
    try
      if GetComputerNameEx(ComputerNameDnsHostname, LBuff, LSize)  then
      begin
        Result := String(LBuff);
      end
      else
      begin
        LErr := GetLastError;
        Result := String.Format('Erro Code %d. %s', [LErr, SysErrormessage(LErr)]);
      end;
    finally
      FreeMem(LBuff);
    end;
  end;
end;

class function TAPMUtils.GetPlatformName: String;
var
  LVersionInfo: TOSVersionInfoEx;
begin
  Result := 'Windows';
  if GetVersionEx(LVersionInfo) then
  begin
    if (10 = LVersionInfo.dwMajorVersion) and (0 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION = LVersionInfo.wProductType) then
    begin
      Result := 'Windows 10';
    end
    else if (10 = LVersionInfo.dwMajorVersion) and (0 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION <> LVersionInfo.wProductType) then
    begin
      Result := 'Windows Server 2016';
    end
    else if (6 = LVersionInfo.dwMajorVersion) and (3 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION = LVersionInfo.wProductType) then
    begin
      Result := 'Windows 8.1';
    end
    else if (6 = LVersionInfo.dwMajorVersion) and (3 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION <> LVersionInfo.wProductType) then
    begin
      Result := 'Windows Server 2012 R2';
    end
    else if (6 = LVersionInfo.dwMajorVersion) and (2 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION = LVersionInfo.wProductType) then
    begin
      Result := 'Windows 8';
    end
    else if (6 = LVersionInfo.dwMajorVersion) and (2 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION <> LVersionInfo.wProductType) then
    begin
      Result := 'Windows Server 2012';
    end
    else if (6 = LVersionInfo.dwMajorVersion) and (1 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION = LVersionInfo.wProductType) then
    begin
      Result := 'Windows 7';
    end
    else if (6 = LVersionInfo.dwMajorVersion) and (1 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION <> LVersionInfo.wProductType) then
    begin
      Result := 'Windows Server 2008 R2';
    end
    else if (6 = LVersionInfo.dwMajorVersion) and (0 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION = LVersionInfo.wProductType) then
    begin
      Result := 'Windows Vista';
    end
    else if (6 = LVersionInfo.dwMajorVersion) and (0 = LVersionInfo.dwMinorVersion) and ( VER_NT_WORKSTATION <> LVersionInfo.wProductType) then
    begin
      Result := 'Windows Server 2008';
    end
    else
    begin
      Result := String.Format('Windws %d.%d Build: %d', [LVersionInfo.dwMajorVersion, LVersionInfo.dwMinorVersion, LVersionInfo.dwBuildNumber]);
    end;
  end;
end;
{$ENDREGION}

{$REGION 'TStopWatch'}
constructor TStopWatch.Create;
begin
  QueryPerformanceFrequency(FTicksPerSecond);
  FStartTicks := 0;
  FStopTicks := 0;
end;

function TStopWatch.GetElapsedSeconds: Double;
begin
  Result := (FStopTicks - FStartTicks) / FTicksPerSecond;
end;

function TStopWatch.GetElapsedMilliseconds: Double;
begin
  Result := 1000 * ((FStopTicks - FStartTicks) / FTicksPerSecond);
end;

function TStopWatch.GetElapsedMicroseconds: Double;
begin
  Result := 1000000 * ((FStopTicks - FStartTicks) / FTicksPerSecond);
end;

procedure TStopWatch.Start;
begin
  FStopTicks := 0;
  QueryPerformanceCounter(FStartTicks);
end;

procedure TStopWatch.Stop;
begin
  QueryPerformanceCounter(FStopTicks);
end;

class function TStopWatch.CreateNew: TStopWatch;
begin
  Result := TStopwatch.Create;
  Result.Start;
end;
{$ENDREGION}

end.
