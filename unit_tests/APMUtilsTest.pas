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
unit APMUtilsTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Utils,
  DefaultInstances;

type
  [TestFixture]
  TAPMUtilsTest = class(TObject)
  public
    [Test]
    procedure Int64ToHex64StringTest;
    [Test]
    procedure Hex128StringTest;
  end;

implementation

procedure TAPMUtilsTest.Int64ToHex64StringTest;
var
  LExpected, LActual: String;
begin
  LExpected := '07B6DF341F5DA3BB';
  LActual := TAPMUtils.Get64BitHexString($07B6DF341F5DA3BB);
  Assert.AreEqual(Lexpected, LActual);

  LActual := TAPMUtils.Get64BitHexString($07B6DF34, $1F5DA3BB);
  Assert.AreEqual(Lexpected, LActual);
end;

procedure TAPMUtilsTest.Hex128StringTest;
var
  LExpected, LActual: String;
begin
  LExpected := '07B6DF341F5DA3BB07B6DF341F5DA3BA';
  LActual := TAPMUtils.Get128BitHexString($07B6DF341F5DA3BB, $07B6DF341F5DA3BA);
  Assert.AreEqual(Lexpected, LActual);

  LActual := TAPMUtils.Get128BitHexString($07B6DF34, $1F5DA3BB, $07B6DF34, $1F5DA3BA);
  Assert.AreEqual(Lexpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMUtilsTest);
end.
