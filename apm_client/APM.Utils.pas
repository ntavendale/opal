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
  System.SysUtils, System.Classes, System.Math, System.DateUtils;

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
  end;

implementation

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

end.
