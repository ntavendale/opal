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
unit APMMetadataTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Metadata,
  DefaultInstances;

type
  [TestFixture]
  TAPMMetadataTest = class(TObject)
  public
    [Test]
    procedure ConstructorTest;
    [Test]
    procedure CopyConstructorTest;
    [Test]
    procedure JSONObjectTest;
    [Test]
    procedure JSONStringTest;
    [Test]
    procedure RequestBodyFormatJSONStringTest;
  end;

implementation

procedure TAPMMetadataTest.ConstructorTest;
var
  LActual: TAPMMetadata;
begin
  LActual := TAPMMetadata.Create;
  try
    Assert.IsTrue(LActual.HasService);
    Assert.IsFalse(LActual.HasProcess);
    Assert.IsFalse(LActual.HasSystem);
    Assert.IsFalse(LActual.HasUser);
  finally
    LActual.Free;
  end;
end;

procedure TAPMMetadataTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMMetadata;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMMetadata;
  try
    LActual := TAPMMetadata.Create(LExpected);
    try
      Assert.AreEqual(LExpected.HasService, LActual.HasService);
      Assert.AreEqual(LExpected.Service.Name, LActual.Service.Name);
      Assert.AreEqual(LExpected.Service.Environment, LActual.Service.Environment);
      Assert.AreEqual(LExpected.Service.Version, LActual.Service.Version);

      Assert.AreEqual(LExpected.Service.HasAgent, LActual.Service.HasAgent);
      Assert.AreEqual(LExpected.Service.AgentName, LActual.Service.AgentName);
      Assert.AreEqual(LExpected.Service.AgentVersion, LActual.Service.AgentVersion);

      Assert.AreEqual(LExpected.Service.HasFramework, LActual.Service.HasFramework);
      Assert.AreEqual(LExpected.Service.FrameworkName, LActual.Service.FrameworkName);
      Assert.AreEqual(LExpected.Service.FrameworkVersion, LActual.Service.FrameworkVersion);

      Assert.AreEqual(LExpected.Service.HasLanguage, LActual.Service.HasLanguage);
      Assert.AreEqual(LExpected.Service.LanguageName, LActual.Service.LanguageName);
      Assert.AreEqual(LExpected.Service.LanguageVersion, LActual.Service.LanguageVersion);

      Assert.AreEqual(LExpected.Service.HasRuntime, LActual.Service.HasRuntime);
      Assert.AreEqual(LExpected.Service.RuntimeName, LActual.Service.RuntimeName);
      Assert.AreEqual(LExpected.Service.RuntimeVersion, LActual.Service.RuntimeVersion);

      Assert.AreEqual(LExpected.HasProcess, LActual.HasProcess);
      Assert.AreEqual(LExpected.Process.ProcessID, LActual.Process.ProcessID);
      Assert.AreEqual(LExpected.Process.ParentProcessID, LActual.Process.ParentProcessID);
      Assert.AreEqual(LExpected.Process.Title, LActual.Process.Title);
      Assert.AreEqual(LExpected.Process.ArgV.Count, LActual.Process.ArgV.Count);
      for i := 0 to (LExpected.Process.ArgV.Count - 1) do
        Assert.AreEqual(LExpected.Process.ArgV[i], LActual.Process.ArgV[i]);

      Assert.AreEqual(LExpected.HasSystem, LActual.HasSystem);
      Assert.AreEqual(LExpected.System.Architecture, LActual.System.Architecture);
      Assert.AreEqual(LExpected.System.Hostname, LActual.System.Hostname);
      Assert.AreEqual(LExpected.System.SystemPlatform, LActual.System.SystemPlatform);

      Assert.AreEqual(LExpected.HasUser, LActual.HasUser);
      Assert.AreEqual(LExpected.User.ID, LActual.User.ID);
      Assert.AreEqual(LExpected.User.Email, LActual.User.Email);
      Assert.AreEqual(LExpected.User.UserName, LActual.User.UserName);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMMetadataTest.JSONObjectTest;
var
  LExpected: TAPMMetadata;
  LActual: TJSONObject;
  LObj: TJSONObject;
  LService: TJSONObject;
  LProcess: TJSONObject;
  LSystem: TJSONObject;
  LUser: TJSONObject;
  LActualArgV: TJSONArray;
  LValue: TJSONValue;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMMetadata;
  try
    LActual := LExpected.GetJSONObject;
    try
      LService := LActual.Values['service'] as TJSONObject;
      Assert.IsNotNull(LService);
      Assert.IsNotNull(LService.Values['name']);
      Assert.AreEqual(LExpected.Service.Name, LService.Values['name'].Value);
      Assert.IsNotNull(LService.Values['environment']);
      Assert.AreEqual(LExpected.Service.Environment, LService.Values['environment'].Value);
      Assert.IsNotNull(LService.Values['version']);
      Assert.AreEqual(LExpected.Service.Version, LService.Values['version'].Value);

      LObj := LService.Values['agent'] as TJSONObject;
      Assert.IsNotNull(LObj);
      Assert.AreEqual(LExpected.Service.AgentName, LObj.Values['name'].Value);
      Assert.AreEqual(LExpected.Service.AgentVersion, LObj.Values['version'].Value);
      LObj := LService.Values['framework'] as TJSONObject;
      Assert.IsNotNull(LObj);
      Assert.AreEqual(LExpected.Service.FrameworkName, LObj.Values['name'].Value);
      Assert.AreEqual(LExpected.Service.FrameworkVersion, LObj.Values['version'].Value);
      LObj := LService.Values['language'] as TJSONObject;
      Assert.IsNotNull(LObj);
      Assert.AreEqual(LExpected.Service.LanguageName, LObj.Values['name'].Value);
      Assert.AreEqual(LExpected.Service.LanguageVersion, LObj.Values['version'].Value);
      LObj := LService.Values['runtime'] as TJSONObject;
      Assert.IsNotNull(LObj);
      Assert.AreEqual(LExpected.Service.RuntimeName, LObj.Values['name'].Value);
      Assert.AreEqual(LExpected.Service.RuntimeVersion, LObj.Values['version'].Value);

      LProcess := LActual.Values['process'] as TJSONObject;
      Assert.IsNotNull(LProcess);
      Assert.IsNotNull(LProcess.Values['pid']);
      Assert.AreEqual(Integer(LExpected.Process.ProcessID), StrToInt(LProcess.Values['pid'].Value));
      Assert.IsNotNull(LProcess.Values['ppid']);
      Assert.AreEqual(Integer(LExpected.Process.ParentProcessID), StrToInt(LProcess.Values['ppid'].Value));
      Assert.IsNotNull(LProcess.Values['title']);
      Assert.AreEqual(LExpected.Process.Title, LProcess.Values['title'].Value);
      LActualArgV := LProcess.Values['argv'] as TJSONArray;
      Assert.IsNotNull(LActualArgV);
      for LValue in LActualArgV do
        Assert.Contains(['/d', '/v'], LValue.Value);

      LSystem := LActual.Values['system'] as TJSONObject;
      Assert.IsNotNull(LSystem.Values['architecture']);
      Assert.AreEqual(LExpected.System.Architecture, LSystem.Values['architecture'].Value);
      Assert.IsNotNull(LSystem.Values['hostname']);
      Assert.AreEqual(LExpected.System.Hostname, LSystem.Values['hostname'].Value);
      Assert.IsNotNull(LSystem.Values['platform']);
      Assert.AreEqual(LExpected.System.SystemPlatform, LSystem.Values['platform'].Value);

      LUser := LActual.Values['user'] as TJSONObject;
      Assert.IsNotNull(LUser.Values['id']);
      Assert.AreEqual(LExpected.User.ID, LUser.Values['id'].Value);
      Assert.IsNotNull(LUser.Values['email']);
      Assert.AreEqual(LExpected.User.Email, LUser.Values['email'].Value);
      Assert.IsNotNull(LUser.Values['username']);
      Assert.AreEqual(LExpected.User.UserName, LUser.Values['username'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMMetadataTest.JSONStringTest;
var
  LMetadata: TAPMMetadata;
  LExpected, LActual: String;
begin
  LExpected := '{"service":{"agent":{"name":"Test Agent","version":"1.2.3.4"},'  +
               '"framework":{"name":"Test Framework","version":"5.6.7.8"},'      +
               '"language":{"name":"Delphi Object Pascal","version":"20"},'      +
               '"name":"Test Service Name","environment":"Production",'          +
               '"runtime":{"name":".NET","version":"4.5.2"},"version":"1.0.0.0"},'+
               '"process":{"pid":98,"ppid":90,"title":"Test Application","argv":["\/v","\/d"]},' +
               '"system":{"architecture":"x64","hostname":"hooded.claw","platform":"Windows"},' +
               '"user":{"id":"52A028B4-7A84-4E5B-A6D8-9696F169A54E","email":"me@here.com","username":"DOMAIN\\UserName"}' +
               '}';
  LMetadata := TDefaultInstances.CreateDefaultAPMMetadata;
  try
    LActual := LMetadata.GetJSONString;
  finally
    LMetadata.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

procedure TAPMMetadataTest.RequestBodyFormatJSONStringTest;
var
  LMetadata: TAPMMetadata;
  LExpected, LActual: String;
begin
  LExpected := '{"metadata":{"service":{"agent":{"name":"Test Agent","version":"1.2.3.4"},'  +
               '"framework":{"name":"Test Framework","version":"5.6.7.8"},'      +
               '"language":{"name":"Delphi Object Pascal","version":"20"},'      +
               '"name":"Test Service Name","environment":"Production",'          +
               '"runtime":{"name":".NET","version":"4.5.2"},"version":"1.0.0.0"},'+
               '"process":{"pid":98,"ppid":90,"title":"Test Application","argv":["\/v","\/d"]},' +
               '"system":{"architecture":"x64","hostname":"hooded.claw","platform":"Windows"},' +
               '"user":{"id":"52A028B4-7A84-4E5B-A6D8-9696F169A54E","email":"me@here.com","username":"DOMAIN\\UserName"}' +
               '}}';
  LMetadata := TDefaultInstances.CreateDefaultAPMMetadata;
  try
    LActual := LMetadata.GetJSONString(TRUE);
  finally
    LMetadata.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMMetadataTest);
end.
