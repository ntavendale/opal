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
unit APM.Transaction;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections;

type
  TAPMTransaction = class
  protected
    FID: String;
    FTraceID: String;
    FParentID: String;
  public
    property ID: String read FID write FID;
    property TraceID: String read FTraceID write FTraceID;
    property ParentID: String read FParentID write FParentID;
  end;

implementation

end.
