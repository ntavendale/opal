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
unit APMServiceTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Context,
  DefaultInstances;

type
  [TestFixture]
  TAPMServiceTest = class(TObject)
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

procedure TAPMServiceTest.ConstructorTest;
var
  LActual: TAPMService;
begin
  LActual := TAPMService.Create;
  try
    Assert.AreEqual(String.Empty, LActual.Name);
    Assert.AreEqual(String.Empty, LActual.Environment);
    Assert.AreEqual(String.Empty, LActual.Version);
    Assert.IsFalse(LActual.HasAgent);
    Assert.AreEqual(String.Empty, LActual.AgentName);
    Assert.AreEqual(String.Empty, LActual.AgentVersion);
    Assert.IsFalse(LActual.HasFramework);
    Assert.AreEqual(String.Empty, LActual.FrameworkName);
    Assert.AreEqual(String.Empty, LActual.FrameworkVersion);
    Assert.IsFalse(LActual.HasLanguage);
    Assert.AreEqual(String.Empty, LActual.LanguageName);
    Assert.AreEqual(String.Empty, LActual.LanguageVersion);
    Assert.IsFalse(LActual.HasRuntime);
    Assert.AreEqual(String.Empty, LActual.RuntimeName);
    Assert.AreEqual(String.Empty, LActual.RuntimeVersion);
  finally
    LActual.Free;
  end;
end;

procedure TAPMServiceTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMService;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMService;
  try
    LActual := TAPMService.Create(LExpected);
    try
      Assert.AreEqual(LExpected.Name, LActual.Name);
      Assert.AreEqual(LExpected.Environment, LActual.Environment);
      Assert.AreEqual(LExpected.Version, LActual.Version);

      Assert.AreEqual(LExpected.HasAgent, LActual.HasAgent);
      Assert.AreEqual(LExpected.AgentName, LActual.AgentName);
      Assert.AreEqual(LExpected.AgentVersion, LActual.AgentVersion);

      Assert.AreEqual(LExpected.HasFramework, LActual.HasFramework);
      Assert.AreEqual(LExpected.FrameworkName, LActual.FrameworkName);
      Assert.AreEqual(LExpected.FrameworkVersion, LActual.FrameworkVersion);

      Assert.AreEqual(LExpected.HasLanguage, LActual.HasLanguage);
      Assert.AreEqual(LExpected.LanguageName, LActual.LanguageName);
      Assert.AreEqual(LExpected.LanguageVersion, LActual.LanguageVersion);

      Assert.AreEqual(LExpected.HasRuntime, LActual.HasRuntime);
      Assert.AreEqual(LExpected.RuntimeName, LActual.RuntimeName);
      Assert.AreEqual(LExpected.RuntimeVersion, LActual.RuntimeVersion);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMServiceTest.JSONObjectTest;
var
  LExpected: TAPMService;
  LActual, LObj: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMService;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['name']);
      Assert.AreEqual(LExpected.Name, LActual.Values['name'].Value);
      Assert.IsNotNull(LActual.Values['environment']);
      Assert.AreEqual(LExpected.Environment, LActual.Values['environment'].Value);
      Assert.IsNotNull(LActual.Values['version']);
      Assert.AreEqual(LExpected.Version, LActual.Values['version'].Value);

      LObj := LActual.Values['agent'] as TJSONObject;
      Assert.IsNotNull(LObj);
      Assert.AreEqual(LExpected.AgentName, LObj.Values['name'].Value);
      Assert.AreEqual(LExpected.AgentVersion, LObj.Values['version'].Value);
      LObj := LActual.Values['framework'] as TJSONObject;
      Assert.IsNotNull(LObj);
      Assert.AreEqual(LExpected.FrameworkName, LObj.Values['name'].Value);
      Assert.AreEqual(LExpected.FrameworkVersion, LObj.Values['version'].Value);
      LObj := LActual.Values['language'] as TJSONObject;
      Assert.IsNotNull(LObj);
      Assert.AreEqual(LExpected.LanguageName, LObj.Values['name'].Value);
      Assert.AreEqual(LExpected.LanguageVersion, LObj.Values['version'].Value);
      LObj := LActual.Values['runtime'] as TJSONObject;
      Assert.IsNotNull(LObj);
      Assert.AreEqual(LExpected.RuntimeName, LObj.Values['name'].Value);
      Assert.AreEqual(LExpected.RuntimeVersion, LObj.Values['version'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMServiceTest.JSONStringTest;
var
  LAgent: TAPMService;
  LExpected, LActual: String;
begin
  LExpected := '{"agent":{"name":"Test Agent","version":"1.2.3.4"},'+'"framework":{"name":"Test Framework","version":"5.6.7.8"},'+'"language":{"name":"Delphi Object Pascal","version":"20"},'+'"name":"Test Service Name","environment":"Production",'+'"runtime":{"name":".NET","version":"4.5.2"},"version":"1.0.0.0"}';
  LAgent := TDefaultInstances.CreateDefaultAPMService;
  try
    LActual := LAgent.GetJSONString;
  finally
    LAgent.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMServiceTest);
end.
