; https://jrsoftware.org/ishelp/
; https://newbedev.com/how-do-i-modify-the-path-environment-variable-when-running-an-inno-setup-installer
; https://stackoverflow.com/questions/25289056/how-to-set-a-global-environment-variable-from-inno-setup-installer/30310653

#define MyAppName "Apache Maven"
#define MyAppVersion "3.8.1"
#define MyAppPublisher "Personal Soft Informática"
#define MyAppURL "http://www.personalsoft.com.br"

[Setup]
AppId={{00973e0f-bf8f-4780-a966-c75e946b1b88}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ChangesEnvironment=yes
Compression=lzma
DefaultDirName={userpf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputBaseFilename={#MyAppName}-{#MyAppVersion}-Installer
OutputDir=target
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\uninstall.ico
UninstallDisplayName={#MyAppName}
VersionInfoVersion={#MyAppVersion}
PrivilegesRequired=lowest

[Files]
Source: "apache-maven-3.8.1\*"; DestDir: "{app}"; Flags: onlyifdoesntexist recursesubdirs

[Code]
//const RootKey = HKEY_LOCAL_MACHINE;
//const SubKeyName = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

const RootKey = HKEY_CURRENT_USER;
const SubKeyName = 'Environment';

procedure EnvAddPath(Path: string);
var
    Paths: string;
begin
    { Retrieve current path (use empty string if entry not exists) }
    if not RegQueryStringValue(RootKey, SubKeyName, 'Path', Paths)
    then Paths := '';

    { Skip if string already found in path }
    if Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';') > 0 then exit;

    { Add string to the end of the path variable }
    Paths := Paths + ';'+ Path +';'

    { Overwrite (or create if missing) path environment variable }
    if RegWriteStringValue(RootKey, SubKeyName, 'Path', Paths)
    then Log(Format('The [%s] added to PATH: [%s]', [Path, Paths]))
    else Log(Format('Error while adding the [%s] to PATH: [%s]', [Path, Paths]));
end;

procedure EnvRemovePath(Path: string);
var
    Paths: string;
    P: Integer;
begin
    { Skip if registry entry not exists }
    if not RegQueryStringValue(RootKey, SubKeyName, 'Path', Paths) then
        exit;

    { Skip if string not found in path }
    P := Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';');
    if P = 0 then exit;

    { Update path variable }
    Delete(Paths, P - 1, Length(Path) + 1);

    { Overwrite path environment variable }
    if RegWriteStringValue(RootKey, SubKeyName, 'Path', Paths)
    then Log(Format('The [%s] removed from PATH: [%s]', [Path, Paths]))
    else Log(Format('Error while removing the [%s] from PATH: [%s]', [Path, Paths]));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep = ssPostInstall)
    then EnvAddPath(ExpandConstant('{app}') +'\bin');
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if (CurUninstallStep = usPostUninstall)
    then EnvRemovePath(ExpandConstant('{app}') +'\bin');
end;
