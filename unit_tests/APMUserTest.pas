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
unit APMUserTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Metadata,
  DefaultInstances;

type

  [TestFixture]
  TAPMUserTest = class(TObject)
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

procedure TAPMUserTest.ConstructorTest;
var
  LActual: TAPMUser;
begin
  LActual := TAPMUser.Create;
  try
    Assert.AreEqual(String.Empty, LActual.ID);
    Assert.AreEqual(String.Empty, LActual.Email);
    Assert.AreEqual(String.Empty, LActual.UserName);
  finally
    LActual.Free;
  end;
end;

procedure TAPMUserTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMUser;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMUser;
  try
    LActual := TAPMUser.Create(LExpected);
    try
      Assert.AreEqual(LExpected.ID, LActual.ID);
      Assert.AreEqual(LExpected.Email, LActual.Email);
      Assert.AreEqual(LExpected.UserName, LActual.UserName);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMUserTest.JSONObjectTest;
var
  LExpected: TAPMUser;
  LActual: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMUser;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['id']);
      Assert.AreEqual(LExpected.ID, LActual.Values['id'].Value);
      Assert.IsNotNull(LActual.Values['email']);
      Assert.AreEqual(LExpected.Email, LActual.Values['email'].Value);
      Assert.IsNotNull(LActual.Values['username']);
      Assert.AreEqual(LExpected.UserName, LActual.Values['username'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMUserTest.JSONStringTest;
var
  LUser: TAPMUser;
  LExpected, LActual: String;
begin
  LExpected := '{"id":"52A028B4-7A84-4E5B-A6D8-9696F169A54E","email":"me@here.com","username":"DOMAIN\\UserName"}';
  LUser := TDefaultInstances.CreateDefaultAPMUser;
  try
    LActual := LUser.GetJSONString;
  finally
    LUser.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMUserTest);
end.
