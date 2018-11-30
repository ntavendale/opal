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
unit APM.Metadata;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  APM.Context;

type
  TAPMMetadata = class
  protected
    FService: TAPMService;
    FProcess: TAPMProcess;
    FSystem: TAPMSystem;
    FUser: TAPMUser;
    function GetHasService: Boolean;
    function GetHasProcess: Boolean;
    function GetHasSystem: Boolean;
    function GetHasUser: Boolean;
  public
    constructor Create; overload;
    constructor Create(AAPMMetadata: TAPMMetadata); overload;
    destructor Destroy; override;
    procedure AddService;
    procedure AddProcess;
    procedure AddSystem;
    procedure AddUser;
    procedure Reset;
    function GetJSONObject(ARequestBodyFormat: Boolean = FALSE): TJSONObject;
    function GetJSONString(ARequestBodyFormat: Boolean = FALSE): String;
    property HasService: Boolean read GetHasService;
    property HasProcess: Boolean read GetHasProcess;
    property HasSystem: Boolean read GetHasSystem;
    property HasUser: Boolean read GetHasUser;
    property Service: TAPMService read FService;
    property Process: TAPMProcess read FProcess;
    property System: TAPMSystem read FSystem;
    property User: TAPMUser read FUser;
  end;

implementation

{$REGION 'TAPMMetadata'}
constructor TAPMMetadata.Create;
begin
  //Service is required
  //https://www.elastic.co/guide/en/apm/server/6.5/metadata-api.html
  FService := TAPMService.Create;
end;

constructor TAPMMetadata.Create(AAPMMetadata: TAPMMetadata);
begin
  if AAPMMetadata.HasService then
    FService := TAPMService.Create(AAPMMetadata.Service);
  if AAPMMetadata.HasProcess then
    FProcess := TAPMProcess.Create(AAPMMetadata.Process);
  if AAPMMetadata.HasSystem then
    FSystem := TAPMSystem.Create(AAPMMetadata.System);
  if AAPMMetadata.HasUser then
    FUser := TAPMUser.Create(AAPMMetadata.User);
end;

destructor TAPMMetadata.Destroy;
begin
  Reset;
  inherited Destroy;
end;

function TAPMMetadata.GetHasService: Boolean;
begin
  Result := (nil <> FService);
end;

function TAPMMetadata.GetHasProcess: Boolean;
begin
  Result := (nil <> FProcess);
end;

function TAPMMetadata.GetHasSystem: Boolean;
begin
  Result := (nil <> FSystem);
end;

function TAPMMetadata.GetHasUser: Boolean;
begin
  Result := (nil <> FUser);
end;

procedure TAPMMetadata.AddService;
begin
  if (nil = FService) then
    FService := TAPMService.Create;
end;

procedure TAPMMetadata.AddProcess;
begin
  if (nil = FProcess) then
    FProcess := TAPMProcess.Create;
end;

procedure TAPMMetadata.AddSystem;
begin
  if (nil = FSystem) then
    FSystem := TAPMSystem.Create;
end;

procedure TAPMMetadata.AddUser;
begin
  if (nil = FUser) then
    FUser := TAPMUser.Create;
end;

procedure TAPMMetadata.Reset;
begin
  if (nil <> FService) then
  begin
    FService.Free;
    FService := nil;
  end;
  if (nil <> FProcess) then
  begin
    FProcess.Free;
    FProcess := nil;
  end;
  if (nil <> FSystem) then
  begin
    FSystem.Free;
    FSystem := nil;
  end;
  if (nil <> FUser) then
  begin
    FUser.Free;
    FUser := nil;
  end;
end;

function TAPMMetadata.GetJSONObject(ARequestBodyFormat: Boolean = FALSE): TJSONObject;
var
  LMetadataObj: TJSONObject;
begin
  LMetadataObj := TJSONObject.Create;
  //Service is required
  //https://www.elastic.co/guide/en/apm/server/6.5/metadata-api.html
  LMetadataObj.AddPair('service', FService.GetJSONObject);
  if (nil <> FProcess) then
    LMetadataObj.AddPair('process', FProcess.GetJSONObject);
  if (nil <> FSystem) then
    LMetadataObj.AddPair('system', FSystem.GetJSONObject);
  if (nil <> FUser) then
    LMetadataObj.AddPair('user', FUser.GetJSONObject);
  if ARequestBodyFormat then
  begin
    Result := TJSONObject.Create;
    Result.AddPair('metadata', LMetadataObj);
  end
  else
    Result := LMetadataObj;
end;

function TAPMMetadata.GetJSONString(ARequestBodyFormat: Boolean = FALSE): String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject(ARequestBodyFormat);
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}
end.
