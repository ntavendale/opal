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
unit APMSystemTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Metadata,
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
