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
unit DefaultInstances;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Metadata,
  APM.Transaction;

type
  TDefaultInstances = class
  public
    class function CreateDefaultAPMUser: TAPMUser;
    class function CreateDefaultAPMSystem: TAPMSystem;
    class function CreateDefaultAPMProcess: TAPMProcess;
    class function CreateDefaultAPMAgent: TAPMAgent;
    class function CreateDefaultAPMFramework: TAPMFramework;
    class function CreateDefaultAPMLanguage: TAPMLanguage;
    class function CreateDefaultAPMRuntime: TAPMRuntime;
    class function CreateDefaultAPMService: TAPMService;
    class function CreateDefaultAPMMetadata: TAPMMetadata;
    class function CreateDefaultAPMTransaction: TAPMTransaction;
  end;

implementation

class function TDefaultInstances.CreateDefaultAPMUser: TAPMUser;
begin
  Result := TAPMUser.Create;
  Result.ID := '52A028B4-7A84-4E5B-A6D8-9696F169A54E';
  Result.Email := 'me@here.com';
  Result.UserName := 'DOMAIN\UserName';
end;

class function TDefaultInstances.CreateDefaultAPMSystem: TAPMSystem;
begin
  Result := TAPMSystem.Create;
  Result.Architecture := 'x64';
  Result.Hostname := 'hooded.claw';
  Result.SystemPlatform := 'Windows';
end;

class function TDefaultInstances.CreateDefaultAPMProcess: TAPMProcess;
begin
  Result := TAPMProcess.Create;
  Result.ProcessID := 98;
  Result.ParentProcessID := 90;
  Result.Title := 'Test Application';
  Result.ArgV.Add('/v');
  Result.ArgV.Add('/d');
end;

class function TDefaultInstances.CreateDefaultAPMAgent: TAPMAgent;
begin
  Result := TAPMAgent.Create;
  Result.Name := 'Test Agent';
  Result.Version := '1.2.3.4';
end;

class function TDefaultInstances.CreateDefaultAPMFramework: TAPMFramework;
begin
  Result := TAPMFramework.Create;
  Result.Name := 'Test Framework';
  Result.Version := '5.6.7.8';
end;

class function TDefaultInstances.CreateDefaultAPMLanguage: TAPMLanguage;
begin
  Result := TAPMLanguage.Create;
  Result.Name := 'Delphi Object Pascal';
  Result.Version := '20';
end;

class function TDefaultInstances.CreateDefaultAPMRuntime: TAPMRuntime;
begin
  Result := TAPMRuntime.Create;
  Result.Name := '.NET';
  Result.Version := '4.5.2';
end;

class function TDefaultInstances.CreateDefaultAPMService: TAPMService;
begin
  Result := TAPMService.Create;
  Result.Name := 'Test Service Name';
  Result.Environment := 'Production';
  Result.Version := '1.0.0.0';
  Result.AgentName := 'Test Agent';
  Result.AgentVersion := '1.2.3.4';
  Result.FrameworkName := 'Test Framework';
  Result.FrameworkVersion := '5.6.7.8';
  Result.LanguageName := 'Delphi Object Pascal';
  Result.LanguageVersion := '20';
  Result.RuntimeName := '.NET';
  Result.RuntimeVersion := '4.5.2';
end;

class function TDefaultInstances.CreateDefaultAPMMetadata: TAPMMetadata;
begin
  Result := TAPMMetadata.Create;
  Result.AddService;
  Result.Service.Name := 'Test Service Name';
  Result.Service.Environment := 'Production';
  Result.Service.Version := '1.0.0.0';
  Result.Service.AgentName := 'Test Agent';
  Result.Service.AgentVersion := '1.2.3.4';
  Result.Service.FrameworkName := 'Test Framework';
  Result.Service.FrameworkVersion := '5.6.7.8';
  Result.Service.LanguageName := 'Delphi Object Pascal';
  Result.Service.LanguageVersion := '20';
  Result.Service.RuntimeName := '.NET';
  Result.Service.RuntimeVersion := '4.5.2';

  Result.AddProcess;
  Result.Process.ProcessID := 98;
  Result.Process.ParentProcessID := 90;
  Result.Process.Title := 'Test Application';
  Result.Process.ArgV.Add('/v');
  Result.Process.ArgV.Add('/d');

  Result.AddSystem;
  Result.System.Architecture := 'x64';
  Result.System.Hostname := 'hooded.claw';
  Result.System.SystemPlatform := 'Windows';

  Result.AddUser;
  Result.User.ID := '52A028B4-7A84-4E5B-A6D8-9696F169A54E';
  Result.User.Email := 'me@here.com';
  Result.User.UserName := 'DOMAIN\UserName';
end;

class function TDefaultInstances.CreateDefaultAPMTransaction: TAPMTransaction;
begin
  //ES Documentation sample (https://www.elastic.co/guide/en/apm/server/current/example-intakev2-events.html)
  //{ "transaction": { "trace_id": "01234567890123456789abcdefabcdef", "id": "abcdef1478523690", "type": "request", "duration": 32.592981, "timestamp": 1535655207154000, "result": "200", "context": null, "spans": null, "sampled": null, "span_count": { "started": 0 }}}
  Result := TAPMTransaction.Create;
  Result.TraceID := '01234567890123456789abcdefabcdef';
  Result.ID := 'abcdef1478523690';
  Result.TxType := 'request';
  Result.Duration := 32.592981;
  Result.TxResult := '200';
  Result.Timestamp := 1535655207154000;
  Result.SpanCount.Started := 0;
end;

end.
