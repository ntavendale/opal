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
unit APMTestMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  TransactionTest, TransactionWithSpansTest, IdSSLOpenSSLHeaders,
  UtilityRoutines, EndpointClient;

const
  TEST_HOST = 'http://192.168.85.122';
  TEST_PORT = 8200;

type
  TfmAPMTestMain = class(TForm)
    btnTestTx: TButton;
    memGenerated: TMemo;
    btnSpans: TButton;
    odURLs: TOpenDialog;
    memPost: TMemo;
    btnPost: TButton;
    procedure btnTestTxClick(Sender: TObject);
    procedure btnSpansClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
  private
    { Private declarations }
    FTraceID: String;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  fmAPMTestMain: TfmAPMTestMain;

implementation

{$R *.dfm}

constructor TfmAPMTestMain.Create(AOwner: TComponent);
var
  LPath, LeayLib, LsslLib: String;
begin
  inherited Create(AOwner);
  FTraceID := GetTraceID;
  LPath := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  LeayLib := String.Format('%s\libeay32.dll', [LPath]);
  LsslLib := String.Format('%s\ssleay32.dll', [LPath]);
  if FileExists( LeayLib ) and FileExists( LsslLib ) then
    IdOpenSSLSetLibPath(LPath);
end;


procedure TfmAPMTestMain.btnTestTxClick(Sender: TObject);
var
  LTest: TTransactionTest;
begin
  memGenerated.Lines.Clear;
  LTest := TTransactionTest.Create(TEST_HOST, TEST_PORT, 'My TX Test Service', FTraceID);
  try
    LTest.Load;
    memGenerated.Text := LTest.Send;
  finally
    LTest.Free;
  end;
end;

procedure TfmAPMTestMain.btnSpansClick(Sender: TObject);
var
  LTest: TTransactionWithSpansTest;
  LURLFileContents, LURLList: TStrings;
  i: Integer;
begin
  memGenerated.Lines.Clear;
  Screen.Cursor := crHourglass;
  try
    if not odURLs.Execute then
      EXIT;

    LURLFileContents := TStringList.Create;
    try
      LURLFileContents.LoadFromFile(odURLs.FileName);
      for i := 0 to (LURLFileContents.Count - 1) do
      begin
        LTest := TTransactionWithSpansTest.Create(TEST_HOST, TEST_PORT, 'Second Test Span Service', LURLFileContents[i].Split([',']), FTraceID, String.Format('TX_Agent_%2d', [i]) );
        try
          LTest.Load;
          memGenerated.Text := memGenerated.Text + #13#10 + LTest.Send;
        finally
          LTest.Free;
        end;
        Sleep(5000);
      end;
    finally
      LURLFileContents.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmAPMTestMain.btnPostClick(Sender: TObject);
var
  LEndpoint: TEndpointClient;
  LIndexDetail: TStringList;
  i: Integer;
begin
  LEndpoint := TEndpointClient.Create(TEST_HOST, TEST_PORT, String.Empty,String.Empty, 'intake/v2/events');
  try
    try
      LEndpoint.PostContentType(memPost.Lines.Text, 'application/x-ndjson');
    except
    end;
    memPost.Lines.Add(LEndpoint.StatusText);
  finally
    LEndpoint.Free;
  end;
end;

end.
