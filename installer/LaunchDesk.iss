; LaunchDesk per-user Windows installer built from Flutter's complete release output.
; Compile with ISCC.exe /DAppSource="C:\path\to\build\windows\x64\run" /O"output" installer\LaunchDesk.iss
#define MyAppName "LaunchDesk"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "DRAEVIX Labs"
#ifndef AppSource
  #error AppSource must point to the complete Flutter Windows deployment directory.
#endif

[Setup]
AppId={{C1B780F4-8147-4E0D-A507-A834CD7B6A09}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\LaunchDesk
DefaultGroupName=LaunchDesk
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputBaseFilename=LaunchDesk-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName=LaunchDesk
CloseApplications=yes
RestartApplications=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: checkedonce

[Files]
Source: "{#AppSource}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\LaunchDesk"; Filename: "{app}\launchdesk.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\LaunchDesk"; Filename: "{app}\launchdesk.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\launchdesk.exe"; Description: "Launch LaunchDesk"; Flags: nowait postinstall skipifsilent
