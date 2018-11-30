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
unit APMSystemTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Context,
  DefaultInstances;

type

  [TestFixture]
  TAPMSystemTest = class(TObject)
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

procedure TAPMSystemTest.ConstructorTest;
var
  LActual: TAPMSystem;
begin
  LActual := TAPMSystem.Create;
  try
    Assert.AreEqual(String.Empty, LActual.Architecture);
    Assert.AreEqual(String.Empty, LActual.Hostname);
    Assert.AreEqual(String.Empty, LActual.SystemPlatform);
  finally
    LActual.Free;
  end;
end;

procedure TAPMSystemTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMSystem;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMSystem;
  try
    LActual := TAPMSystem.Create(LExpected);
    try
      Assert.AreEqual(LExpected.Architecture, LActual.Architecture);
      Assert.AreEqual(LExpected.Hostname, LActual.Hostname);
      Assert.AreEqual(LExpected.SystemPlatform, LActual.SystemPlatform);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMSystemTest.JSONObjectTest;
var
  LExpected: TAPMSystem;
  LActual: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMSystem;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['architecture']);
      Assert.AreEqual(LExpected.Architecture, LActual.Values['architecture'].Value);
      Assert.IsNotNull(LActual.Values['hostname']);
      Assert.AreEqual(LExpected.Hostname, LActual.Values['hostname'].Value);
      Assert.IsNotNull(LActual.Values['platform']);
      Assert.AreEqual(LExpected.SystemPlatform, LActual.Values['platform'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMSystemTest.JSONStringTest;
var
  LSystem: TAPMSystem;
  LExpected, LActual: String;
begin
  LExpected := '{"architecture":"x64","hostname":"hooded.claw","platform":"Windows"}';
  LSystem := TDefaultInstances.CreateDefaultAPMSystem;
  try
    LActual := LSystem.GetJSONString;
  finally
    LSystem.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMSystemTest);
end.
