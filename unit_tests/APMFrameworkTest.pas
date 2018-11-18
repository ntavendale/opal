//Copyright 2018 Oamaru Group Inc.
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
unit APMFrameworkTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Metadata,
  DefaultInstances;

type
  [TestFixture]
  TAPMFrameworkTest = class(TObject)
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

procedure TAPMFrameworkTest.ConstructorTest;
var
  LActual: TAPMFramework;
begin
  LActual := TAPMFramework.Create;
  try
    Assert.AreEqual(String.Empty, LActual.Name);
    Assert.AreEqual(String.Empty, LActual.Version);
  finally
    LActual.Free;
  end;
end;

procedure TAPMFrameworkTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMFramework;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMFramework;
  try
    LActual := TAPMFramework.Create(LExpected);
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

procedure TAPMFrameworkTest.JSONObjectTest;
var
  LExpected: TAPMFramework;
  LActual: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMFramework;
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

procedure TAPMFrameworkTest.JSONStringTest;
var
  LAgent: TAPMFramework;
  LExpected, LActual: String;
begin
  LExpected := '{"name":"Test Framework","version":"5.6.7.8"}';
  LAgent := TDefaultInstances.CreateDefaultAPMFramework;
  try
    LActual := LAgent.GetJSONString;
  finally
    LAgent.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMFrameworkTest);
end.
