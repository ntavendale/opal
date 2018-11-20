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
unit APMExceptionTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Error,
  DefaultInstances;

type
  [TestFixture]
  TAPMExceptionTest = class(TObject)
  public
    [Test]
    procedure ConstructorTest;
    [Test]
    procedure CopyConstructorTest;
    [Test]
    procedure JSONObjectTest;
    [Test]
    procedure JSONStringTest;
  end;

implementation

procedure TAPMExceptionTest.ConstructorTest;
var
  LActual: TAPMException;
begin
  LActual := TAPMException.Create;
  try
    Assert.AreEqual(String.Empty, LActual.Code);
    Assert.AreEqual(String.Empty, LActual.ExceptionMessage);
    Assert.AreEqual(String.Empty, LActual.Module);
    Assert.AreEqual(0, LActual.StackTrace.Count);
    Assert.AreEqual(String.Empty, LActual.ExceptionType);
    Assert.IsFalse(LActual.Handled);
  finally
    LActual.Free;
  end;
end;

procedure TAPMExceptionTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMException;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMException;
  try
    LActual := TAPMException.Create(LExpected);
    try
      Assert.AreEqual(LExpected.Code, LActual.Code);
      Assert.AreEqual(LExpected.ExceptionMessage, LActual.ExceptionMessage);
      Assert.AreEqual(LExpected.Module, LActual.Module);
      Assert.AreEqual(LExpected.StackTrace.Count, LActual.StackTrace.Count);
      for i := 0 to LExpected.StackTrace.Count - 1 do
        Assert.AreEqual(LExpected.StackTrace[i], LActual.StackTrace[i]);
      Assert.AreEqual(LExpected.ExceptionType, LActual.ExceptionType);
      Assert.AreEqual(LExpected.Handled, LActual.Handled);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMExceptionTest.JSONObjectTest;
var
  LExpected: TAPMException;
  LActual: TJSONObject;
  LStackTrace: TJSONArray;
  LValue: TJSONValue;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMException;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['code']);
      Assert.AreEqual(LExpected.Code, LActual.Values['code'].Value);
      Assert.IsNotNull(LActual.Values['message']);
      Assert.AreEqual(LExpected.ExceptionMessage, LActual.Values['message'].Value);
      Assert.IsNotNull(LActual.Values['module']);
      Assert.AreEqual(LExpected.Module, LActual.Values['module'].Value);
      LStackTrace := LActual.Values['stacktrace'] as TJSONArray;
      Assert.IsNotNull(LStackTrace);
      for LValue in LStackTrace do
        Assert.Contains(['StackTrace Line 1', 'StackTrace Line 2'], LValue.Value);
      Assert.IsNotNull(LActual.Values['type']);
      Assert.AreEqual(LExpected.ExceptionType, LActual.Values['type'].Value);
      Assert.IsNotNull(LActual.Values['handled']);
      Assert.AreEqual(LExpected.Handled, StrToBool(LActual.Values['handled'].Value));
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMExceptionTest.JSONStringTest;
var
  LMException: TAPMException;
  LExpected, LActual: String;
begin
  LExpected := '{"code":"5","message":"Access Denied","module":"Test Module","attributes":null,"stacktrace":["StackTrace Line 1","StackTrace Line 2"],"type":"EAccessDenied","handled":true}';
  LMException := TDefaultInstances.CreateDefaultAPMException;
  try
    LActual := LMException.GetJSONString;
  finally
    LMException.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMExceptionTest);
end.
