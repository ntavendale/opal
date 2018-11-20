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
unit APMRuntimeTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Metadata,
  DefaultInstances;

type
  [TestFixture]
  TAPMRuntimeTest = class(TObject)
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

procedure TAPMRuntimeTest.ConstructorTest;
var
  LActual: TAPMRuntime;
begin
  LActual := TAPMRuntime.Create;
  try
    Assert.AreEqual(String.Empty, LActual.Name);
    Assert.AreEqual(String.Empty, LActual.Version);
  finally
    LActual.Free;
  end;
end;

procedure TAPMRuntimeTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMRuntime;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMRuntime;
  try
    LActual := TAPMRuntime.Create(LExpected);
    try
      Assert.AreEqual(LExpected.Name, LActual.Name);
      Assert.AreEqual(LExpected.Version, LActual.Version);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMRuntimeTest.JSONObjectTest;
var
  LExpected: TAPMRuntime;
  LActual: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMRuntime;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['name']);
      Assert.AreEqual(LExpected.Name, LActual.Values['name'].Value);
      Assert.IsNotNull(LActual.Values['version']);
      Assert.AreEqual(LExpected.Version, LActual.Values['version'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMRuntimeTest.JSONStringTest;
var
  LAgent: TAPMRuntime;
  LExpected, LActual: String;
begin
  LExpected := '{"name":".NET","version":"4.5.2"}';
  LAgent := TDefaultInstances.CreateDefaultAPMRuntime;
  try
    LActual := LAgent.GetJSONString;
  finally
    LAgent.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMRuntimeTest);
end.
