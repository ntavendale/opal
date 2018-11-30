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
unit APMUserTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Context,
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
