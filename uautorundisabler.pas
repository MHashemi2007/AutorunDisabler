unit uAutorunDisabler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, Registry;

type

  { TfrmAutorunDisabler }

  TfrmAutorunDisabler = class(TForm)
    btnDisabler: TButton;
    btnEnabler: TButton;
    procedure btnDisablerClick(Sender: TObject);
    procedure btnEnablerClick(Sender: TObject);
  private
    function Is64bit: boolean;
  public

  end;

var
  frmAutorunDisabler: TfrmAutorunDisabler;

implementation

{$R *.lfm}

{ TfrmAutorunDisabler }

procedure TfrmAutorunDisabler.btnDisablerClick(Sender: TObject);
var
  Reg: TRegistry;
  MY_KEY: LongWord;
begin
  if Is64bit then
    MY_KEY := KEY_ALL_ACCESS or KEY_WOW64_64KEY
  else
    MY_KEY := KEY_ALL_ACCESS or KEY_WOW64_32KEY;
  Reg := TRegistry.Create(MY_KEY);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer', true) then
    begin
      Reg.WriteInteger('NoDriveTypeAutorun', 255);
      Reg.CloseKey;
    end;
    if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers', true) then
    begin
      Reg.WriteInteger('DisableAutoplay', 1);
      Reg.CloseKey;
    end;
    if Reg.OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf', true) then
    begin
      Reg.WriteString('', '@SYS:DoesNotExist');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  ShowMessage('Autorun Disabled!');
end;

procedure TfrmAutorunDisabler.btnEnablerClick(Sender: TObject);
var
  Reg: TRegistry;
  MY_KEY: LongWord;
begin
  if Is64bit then
    MY_KEY := KEY_ALL_ACCESS or KEY_WOW64_64KEY
  else
    MY_KEY := KEY_ALL_ACCESS or KEY_WOW64_32KEY;
  Reg := TRegistry.Create(MY_KEY);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer', true) then
    begin
      Reg.WriteInteger('NoDriveTypeAutorun', 0);
      Reg.CloseKey;
    end;
    if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers', true) then
    begin
      Reg.WriteInteger('DisableAutoplay', 0);
      Reg.CloseKey;
    end;
    if Reg.OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf', true) then
    begin
      Reg.WriteString('', '');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  ShowMessage('Autorun Enable!');
end;

function TfrmAutorunDisabler.Is64bit: boolean;
type
  TIsWow64Process = function(Handle: Windows.THandle; var Res: Windows.BOOL): Windows.BOOL; stdcall;
var
  IsWow64Result: Windows.BOOL;
  IsWow64Process: TIsWow64Process;
begin
  IsWow64Process := TIsWow64Process(Windows.GetProcAddress(
    Windows.GetModuleHandle('kernel32'), 'IsWow64Process'));
  if Assigned(IsWow64Process) then
  begin
    if not IsWow64Process(Windows.GetCurrentProcess, IsWow64Result) then
      raise SysUtils.Exception.Create('IsWindows64: bad process handle');
    Result := IsWow64Result;
  end
  else
    Result := False;
  begin
    Result := True;
  end;
end;

end.

