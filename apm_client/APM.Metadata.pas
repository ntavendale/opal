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
unit APM.Metadata;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections;

type
  TAPMAgent = class
  protected
    FName: String;
    FVersion: String;
  public
    constructor Create; overload;
    constructor Create(AAPMAgent: TAPMAgent); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Name: String read FName write FName;
    property Version: String read FVersion write FVersion;
  end;

  TAPMFramework = class
  protected
    FName: String;
    FVersion: String;
  public
    constructor Create; overload;
    constructor Create(AAPMFramework: TAPMFramework); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Name: String read FName write FName;
    property Version: String read FVersion write FVersion;
  end;

  TAPMLanguage = class
  protected
    FName: String;
    FVersion: String;
  public
    constructor Create; overload;
    constructor Create(AAPMLanguage: TAPMLanguage); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Name: String read FName write FName;
    property Version: String read FVersion write FVersion;
  end;

  TAPMRuntime = class
  protected
    FName: String;
    FVersion: String;
  public
    constructor Create; overload;
    constructor Create(AAPMRuntime: TAPMRuntime); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Name: String read FName write FName;
    property Version: String read FVersion write FVersion;
  end;

  TAPMService = class
  protected
    FName: String;
    FEnvironment: String;
    FVersion: String;
    FAgent: TAPMAgent;
    FFramework: TAPMFramework;
    FLanguage: TAPMLanguage;
    FRuntime: TAPMRuntime;
    function GetHasAgent: Boolean;
    function GetAgentName: String;
    procedure SetAgentName(AValue: String);
    function GetAgentVersion: String;
    procedure SetAgentVersion(AValue: String);
    function GetHasFramework: Boolean;
    function GetFrameworkName: String;
    procedure SetFrameworkName(AValue: String);
    function GetFrameworkVersion: String;
    procedure SetFrameworkVersion(AValue: String);
    function GetHasLanguage: Boolean;
    function GetLanguageName: String;
    procedure SetLanguageName(AValue: String);
    function GetLanguageVersion: String;
    procedure SetLanguageVersion(AValue: String);
    function GetHasRuntime: Boolean;
    function GetRuntimeName: String;
    procedure SetRuntimeName(AValue: String);
    function GetRuntimeVersion: String;
    procedure SetRuntimeVersion(AValue: String);
  public
    constructor Create; overload;
    constructor Create(APMService: TAPMService); overload;
    destructor Destroy; override;
    procedure Reset;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Name: String read FName write FName;
    property Environment: String read FEnvironment write FEnvironment;
    property Version: String read FVersion write FVersion;
    property HasAgent: Boolean read GetHasAgent;
    property AgentName: String read GetAgentName write SetAgentName;
    property AgentVersion: String read GetAgentVersion write SetAgentVersion;
    property HasFramework: Boolean read GetHasFramework;
    property FrameworkName: String read GetFrameworkName write SetFrameworkName;
    property FrameworkVersion: String read GetFrameworkVersion write SetFrameworkVersion;
    property HasLanguage: Boolean read GetHasLanguage;
    property LanguageName: String read GetLanguageName write SetLanguageName;
    property LanguageVersion: String read GetLanguageVersion write SetLanguageVersion;
    property HasRuntime: Boolean read GetHasRuntime;
    property RuntimeName: String read GetRuntimeName write SetRuntimeName;
    property RuntimeVersion: String read GetRuntimeVersion write SetRuntimeVersion;
  end;

  TAPMProcess = class
  protected
    FProcessID: Cardinal;
    FParentProcessID: Cardinal;
    FTitle: String;
    FArgV: TList<String>;
  public
    constructor Create; overload;
    constructor Create(AAPMProcess: TAPMProcess); overload;
    destructor Destroy; override;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property ProcessID: Cardinal read FProcessID write FProcessID;
    property ParentProcessID: Cardinal read FParentProcessID write FParentProcessID;
    property Title: String read FTitle write FTitle;
    property ArgV: TList<String> read FArgV;
  end;

  TAPMSystem = class
  protected
    FArchitecture: String;
    FHostname: String;
    FPlatform: String;
  public
    constructor Create; overload;
    constructor Create(AAPMSystem: TAPMSystem); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property Architecture: String read FArchitecture write FArchitecture;
    property Hostname: String read FHostname write FHostname;
    property SystemPlatform: String read FPlatform write FPlatform;
  end;

  TAPMUser = class
  protected
    FID: String;
    FEmail: String;
    FUserName: String;
  public
    constructor Create; overload;
    constructor Create(AAPMUser: TAPMUser); overload;
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
    property ID: String read FID write FID;
    property Email: String read FEmail write FEmail;
    property UserName: String read FUserName write FUserName;
  end;

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
    function GetJSONObject: TJSONObject;
    function GetJSONString: String;
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

{$REGION 'TAPMAgent'}
constructor TAPMAgent.Create;
begin
  FName := String.Empty;
  FVersion := String.Empty;
end;

constructor TAPMAgent.Create(AAPMAgent: TAPMAgent);
begin
  FName := AAPMAgent.Name;
  FVersion := AAPMAgent.Version;
end;

function TAPMAgent.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', FName);
  Result.AddPair('version', FVersion);
end;

function TAPMAgent.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMFramework'}
constructor TAPMFramework.Create;
begin
  FName := String.Empty;
  FVersion := String.Empty;
end;

constructor TAPMFramework.Create(AAPMFramework: TAPMFramework);
begin
  FName := AAPMFramework.Name;
  FVersion := AAPMFramework.Version;
end;

function TAPMFramework.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', FName);
  Result.AddPair('version', FVersion);
end;

function TAPMFramework.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMLanguage'}
constructor TAPMLanguage.Create;
begin
  FName := String.Empty;
  FVersion := String.Empty;
end;

constructor TAPMLanguage.Create(AAPMLanguage: TAPMLanguage);
begin
  FName := AAPMLanguage.Name;
  FVersion := AAPMLanguage.Version;
end;

function TAPMLanguage.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', FName);
  Result.AddPair('version', FVersion);
end;

function TAPMLanguage.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMRuntime'}
constructor TAPMRuntime.Create;
begin
  FName := String.Empty;
  FVersion := String.Empty;
end;

constructor TAPMRuntime.Create(AAPMRuntime: TAPMRuntime);
begin
  FName := AAPMRuntime.Name;
  FVersion := AAPMRuntime.Version;
end;

function TAPMRuntime.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', FName);
  Result.AddPair('version', FVersion);
end;

function TAPMRuntime.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMService'}
constructor TAPMService.Create;
begin
  FName := String.Empty;
  FEnvironment := String.Empty;
  FVersion := String.Empty;
  FAgent := nil;
  FFramework := nil;
  FLanguage := nil;
  FRuntime := nil;
end;

constructor TAPMService.Create(APMService: TAPMService);
begin
  FName := APMService.Name;
  FEnvironment := APMService.Environment;
  FVersion := APMService.Version;
  if APMService.HasAgent then
  begin
    FAgent := TAPMAgent.Create;
    FAgent.Name := APMService.AgentName;
    FAgent.Version := APMService.AgentVersion;
  end;
  if APMService.HasFramework then
  begin
    FFramework := TAPMFramework.Create;
    FFramework.Name := APMService.FrameworkName;
    FFramework.Version := APMService.FrameworkVersion;
  end;
  if APMService.HasLanguage then
  begin
    FLanguage := TAPMLanguage.Create;
    FLanguage.Name := APMService.LanguageName;
    FLanguage.Version := APMService.LanguageVersion;
  end;
  if APMService.HasRuntime then
  begin
    FRuntime := TAPMRuntime.Create;
    FRuntime.Name := APMService.RuntimeName;
    FRuntime.Version := APMService.RuntimeVersion;
  end;
end;

destructor TAPMService.Destroy;
begin
  if nil <> FAgent then
    FAgent.Free;
  if nil <> FFramework then
    FFramework.Free;
  if nil <> FLanguage then
    FLanguage.Free;
  if nil <> FRuntime then
    FRuntime.Free;
  inherited Destroy;
end;

function TAPMService.GetHasAgent: Boolean;
begin
  Result := (nil <> FAgent);
end;

function TAPMService.GetAgentName: String;
begin
  Result := String.Empty;
  if nil <> FAgent then
    Result := FAgent.Name;
end;

procedure TAPMService.SetAgentName(AValue: String);
begin
  if nil = FAgent then
    FAgent := TAPMAgent.Create;
  FAgent.Name := AValue;
end;

function TAPMService.GetAgentVersion: String;
begin
  Result := String.Empty;
  if nil <> FAgent then
    Result := FAgent.Version;
end;

procedure TAPMService.SetAgentVersion(AValue: String);
begin
  if nil = FAgent then
    FAgent := TAPMAgent.Create;
  FAgent.Version := AValue;
end;

function TAPMService.GetHasFramework: Boolean;
begin
  Result := (nil <> FFramework);
end;

function TAPMService.GetFrameworkName: String;
begin
  Result := String.Empty;
  if nil <> FFramework then
    Result := FFramework.Name;
end;

procedure TAPMService.SetFrameworkName(AValue: String);
begin
  if nil = FFramework then
    FFramework := TAPMFramework.Create;
  FFramework.Name := AValue;
end;

function TAPMService.GetFrameworkVersion: String;
begin
  Result := String.Empty;
  if nil <> FFramework then
    Result := FFramework.Version;
end;

procedure TAPMService.SetFrameworkVersion(AValue: String);
begin
  if nil = FFramework then
    FFramework := TAPMFramework.Create;
  FFramework.Version := AValue;
end;

function TAPMService.GetHasLanguage: Boolean;
begin
  Result := (nil <> FLanguage);
end;

function TAPMService.GetLanguageName: String;
begin
  Result := String.Empty;
  if nil <> FLanguage then
    Result := FLanguage.Name;
end;

procedure TAPMService.SetLanguageName(AValue: String);
begin
  if nil = FLanguage then
    FLanguage := TAPMLanguage.Create;
  FLanguage.Name := AValue;
end;

function TAPMService.GetLanguageVersion: String;
begin
  Result := String.Empty;
  if nil <> FLanguage then
    Result := FLanguage.Version;
end;

procedure TAPMService.SetLanguageVersion(AValue: String);
begin
  if nil = FLanguage then
    FLanguage := TAPMLanguage.Create;
  FLanguage.Version := AValue;
end;

function TAPMService.GetHasRuntime: Boolean;
begin
  Result := (nil <> FRuntime);
end;

function TAPMService.GetRuntimeName: String;
begin
  Result := String.Empty;
  if nil <> FRuntime then
    Result := FRuntime.Name;
end;

procedure TAPMService.SetRuntimeName(AValue: String);
begin
  if nil = FRuntime then
    FRuntime := TAPMRuntime.Create;
  FRuntime.Name := AValue;
end;

function TAPMService.GetRuntimeVersion: String;
begin
  Result := String.Empty;
  if nil <> FRuntime then
    Result := FRuntime.Version;
end;

procedure TAPMService.SetRuntimeVersion(AValue: String);
begin
  if nil = FRuntime then
    FRuntime := TAPMRuntime.Create;
  FRuntime.Version := AValue;
end;

procedure TAPMService.Reset;
begin
  FName := String.Empty;
  FEnvironment := String.Empty;
  FVersion := String.Empty;

  if nil <> FAgent then
  begin
    FAgent.Free;
    FAgent := nil;
  end;

  if nil <> FFramework then
  begin
    FFramework.Free;
    FFramework := nil;
  end;

  if nil <> FLanguage then
  begin
    FLanguage.Free;
    FLanguage := nil
  end;

  if nil <> FRuntime then
  begin
    FRuntime.Free;
    FRuntime := nil;
  end;
end;

function TAPMService.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  if nil <> FAgent then
    Result.AddPair('agent', FAgent.GetJSONObject);
  if nil <> FFramework then
    Result.AddPair('framework', FFramework.GetJSONObject);
  if nil <> FLanguage then
    Result.AddPair('language', FLanguage.GetJSONObject);
  Result.AddPair('name', FName);
  Result.AddPair('environment', FEnvironment);
  if nil <> FRuntime then
    Result.AddPair('runtime', FRuntime.GetJSONObject);
  Result.AddPair('version', FVersion);
end;

function TAPMService.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMProcess'}
constructor TAPMProcess.Create;
begin
  FProcessID := 0;
  FParentProcessID := 0;
  FTitle := String.Empty;
  FArgV := TList<String>.Create;
end;

constructor TAPMProcess.Create(AAPMProcess: TAPMProcess);
var
  i: Integer;
begin
  FProcessID := AAPMProcess.ProcessID;
  FParentProcessID := AAPMProcess.ParentProcessID;
  FTitle := AAPMProcess.Title;
  FArgV := TList<String>.Create;
  for i := 0 to (AAPMProcess.ArgV.Count - 1) do
    FArgV.Add(AAPMProcess.ArgV[i]);
end;

destructor TAPMProcess.Destroy;
begin
  FArgV.Free;
  inherited Destroy;
end;

function TAPMProcess.GetJSONObject: TJSONObject;
var
  LArgVArray: TJSONArray;
  LArg: String;
begin
  Result := TJSONObject.Create;
  Result.AddPair('pid', TJsonNumber.Create(FProcessID));
  Result.AddPair('ppid', TJsonNumber.Create(FParentProcessID));
  Result.AddPair('title', FTitle);
  LArgVArray := TJSONArray.Create;
  for LArg in FArgV do
    LArgVArray.Add(LArg);
  Result.AddPair('argv', LArgVArray);
end;

function TAPMProcess.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMSystem'}
constructor TAPMSystem.Create;
begin
  FArchitecture := String.Empty;
  FHostname := String.Empty;
  FPlatform := String.Empty;
end;

constructor TAPMSystem.Create(AAPMSystem: TAPMSystem);
begin
  FArchitecture := AAPMSystem.Architecture;
  FHostname := AAPMSystem.Hostname;
  FPlatform := AAPMSystem.SystemPlatform;
end;

function TAPMSystem.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('architecture', FArchitecture);
  Result.AddPair('hostname', FHostname);
  Result.AddPair('platform', FPlatform);
end;

function TAPMSystem.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAPMUser'}
constructor TAPMUser.Create;
begin
  FID := String.Empty;
  FEmail := String.Empty;
  FUserName := String.Empty;
end;

constructor TAPMUser.Create(AAPMUser: TAPMUser);
begin
  FID := AAPMUser.ID;
  FEmail := AAPMUser.Email;
  FUserName := AAPMUser.UserName;
end;

function TAPMUser.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', FID);
  Result.AddPair('email', FEmail);
  Result.AddPair('username', FUserName);
end;

function TAPMUser.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}

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

function TAPMMetadata.GetJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  //Service is required
  //https://www.elastic.co/guide/en/apm/server/6.5/metadata-api.html
  Result.AddPair('service', FService.GetJSONObject);
  if (nil <> FProcess) then
    Result.AddPair('process', FProcess.GetJSONObject);
  if (nil <> FSystem) then
    Result.AddPair('system', FSystem.GetJSONObject);
  if (nil <> FUser) then
    Result.AddPair('user', FUser.GetJSONObject);
end;

function TAPMMetadata.GetJSONString: String;
var
  LObj: TJSONObject;
begin
  LObj := Self.GetJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
{$ENDREGION}
end.
