program avsproxy_gui;

uses
  Forms,
  Windows,
  Messages,
  Unit_MainForm in 'Unit_MainForm.pas' {Form1},
  MuldeR_Process in '..\!_Toolz\MuldeR_Process.pas',
  MuldeR_MD5 in '..\!_Toolz\MuldeR_MD5.pas',
  Unit_LinkTime in '..\LameXP_NEW\Unit_LinkTime.pas',
  Unit_WideStrUtils in '..\LameXP_NEW\Unit_WideStrUtils.pas';

{$R *.res}

var
  msg: tagMsg;
  Timeout: Integer;

begin
  HandshakeMessage := RegisterWindowMessage('WM_ADMAVSPROXYGUI_HANDSHAKE');
  CreateMutex(nil, true, 'Avidemux AVSProxy GUI {bad585fd-f4f5-4f87-a0f3-52e57e8dd1c1}');

  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    PostMessage(HWND_BROADCAST, HandshakeMessage, HWND_BROADCAST, Application.Handle);
    Timeout := 0;

    repeat
      Timeout := Timeout+1;
      if PeekMessage(msg, Application.Handle, HandshakeMessage, HandshakeMessage,PM_REMOVE) then
      begin
        if (msg.wParam <> HWND_BROADCAST) then
        begin
          ShowWindow(msg.wParam, SW_RESTORE);
          SetForegroundWindow(msg.lParam);
          halt(0);
        end;
      end;
      Sleep(10);
    until
      Timeout > 500;

    MessageBox(0, 'Avisynth Proxy is already running, but not responding. Problems might occure!', 'Avisyth Proxy', MB_ICONERROR or MB_TOPMOST);  
  end;

  Application.Initialize;
  Application.Title := 'Avisynth Proxy';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
