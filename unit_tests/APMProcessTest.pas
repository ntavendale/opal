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
unit APMProcessTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Context,
  DefaultInstances;

type

  [TestFixture]
  TAPMProcessTest = class(TObject)
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

procedure TAPMProcessTest.ConstructorTest;
var
  LActual: TAPMProcess;
begin
  LActual := TAPMProcess.Create;
  try
    Assert.AreEqual(Cardinal(0), LActual.ProcessID);
    Assert.AreEqual(Cardinal(0), LActual.ParentProcessID);
    Assert.AreEqual(String.Empty, LActual.Title);
    Assert.AreEqual(Cardinal(0), LActual.ArgV.Count);
  finally
    LActual.Free;
  end;
end;

procedure TAPMProcessTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMProcess;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMProcess;
  try
    LActual := TAPMProcess.Create(LExpected);
    try
      Assert.AreEqual(LExpected.ProcessID, LActual.ProcessID);
      Assert.AreEqual(LExpected.ParentProcessID, LActual.ParentProcessID);
      Assert.AreEqual(LExpected.Title, LActual.Title);
      Assert.AreEqual(LExpected.ArgV.Count, LActual.ArgV.Count);
      for i := 0 to (LExpected.ArgV.Count - 1) do
        Assert.AreEqual(LExpected.ArgV[i], LActual.ArgV[i]);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMProcessTest.JSONObjectTest;
var
  LExpected: TAPMProcess;
  LActual: TJSONObject;
  LActualArgV: TJSONArray;
  LValue: TJSONValue;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMProcess;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['pid']);
      Assert.AreEqual(Integer(LExpected.ProcessID), StrToInt(LActual.Values['pid'].Value));
      Assert.IsNotNull(LActual.Values['ppid']);
      Assert.AreEqual(Integer(LExpected.ParentProcessID), StrToInt(LActual.Values['ppid'].Value));
      Assert.IsNotNull(LActual.Values['title']);
      Assert.AreEqual(LExpected.Title, LActual.Values['title'].Value);
      LActualArgV := LActual.Values['argv'] as TJSONArray;
      Assert.IsNotNull(LActual.Values['argv']);
      for LValue in LActualArgV do
        Assert.Contains(['/d', '/v'], LValue.Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMProcessTest.JSONStringTest;
var
  LSystem: TAPMProcess;
  LExpected, LActual: String;
begin
  LExpected := '{"pid":98,"ppid":90,"title":"Test Application","argv":["\/v","\/d"]}';
  LSystem := TDefaultInstances.CreateDefaultAPMProcess;
  try
    LActual := LSystem.GetJSONString;
  finally
    LSystem.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMProcessTest);
end.
