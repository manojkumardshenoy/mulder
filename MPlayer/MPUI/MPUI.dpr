{   MPUI, an MPlayer frontend for Windows
    Copyright (C) 2005 Martin J. Fiedler <martin.fiedler@gmx.net>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
program MPUI;

uses
  Forms,
  Windows,
  Main in 'Main.pas' {MainForm},
  Log in 'Log.pas' {LogForm},
  Core in 'Core.pas',
  URL in 'URL.pas',
  Help in 'Help.pas' {HelpForm},
  About in 'About.pas' {AboutForm},
  Locale in 'Locale.pas',
  Options in 'Options.pas' {OptionsForm},
  Config in 'Config.pas',
  plist in 'plist.pas' {PlaylistForm},
  Info in 'Info.pas' {InfoForm},
  TrayIcon in 'TrayIcon.pas';

{$R *.res}

begin
  CheckInstances;
  Application.Initialize;
  Application.Title := 'MPUI';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(THelpForm, HelpForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TPlaylistForm, PlaylistForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.Run;
end.
