unit Cod.Windows;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Registry, Vcl.Dialogs, Vcl.Forms, UITypes, Types, Winapi.shlobj,
  Cod.Registry, IOUtils, ActiveX, ComObj, ShellApi, Cod.ColorUtils, PsApi,
  Cod.Files, Cod.Types, Cod.MesssageConst, Winapi.TlHelp32;

  type
    // Cardinals
    TWinPlatform = (Platform32, Platform64);
    TWinVersion = (Win2000, WinXp, WinXp64, Vista2008, Win72008R2, Win8, Win10);

    TWinUX = (ActionCenter, Notifications, Calculator, Store, Support, Maps,
      Network, Cast, Wifi, Project, Bluetooth, Clock, Xbox, MediaPlayer,
      Weather, TaskSwitch, Settings, ScreenClip, Photos, PrintQueue,
      WinDefender, StartMenu);

    TWinSettingsPage = (Home, FlightMode, Bluetooth, Cellular, Accounts,
      Language, Location, LockScreen, Hotspot, Notifications, Power, Privacy,
      Display, Wifi, Workplace);

    // Records
    TProcess = record
      Module,  // Exe name, eg. "explorer.exe"
      FileName, // Exe Location
      Command: string;
      PID, // App PID
      ParentPID, // Parent PID
      Modules, // Attatched DLLs
      Threads, // Thread Count
      Priority, // Process Priority
      Flags: integer;

      // Utils
      procedure CloseProcess;
      procedure KillProcess;
      function GetIcon: TIcon;
    end;

    TProcessList = TArray<TProcess>;

    TProcessListHelper = record helper for TProcessList
      function FindProcess(Executable: string): integer;
    end;

  { Shell32 }
  function IsUserAnAdmin(): BOOL; external shell32;

  { AdvApi32 }
  function CheckTokenMembership(TokenHandle: THANDLE; SidToCheck: Pointer; var IsMember: BOOL): BOOL; stdcall; external advapi32 name 'CheckTokenMembership'

  { Windows API }
  function GetWindowsPlatform: TWinVersion;
  function IsWOW64Emulated: boolean;
  function IsWow64Executable: Boolean;
  function GetWindowsArhitecture: TWinPlatform;
  function NTKernelVersion: single;
  function IdleTime: DWord;
  function GetAccentColor(brightencolor: boolean = false): TColor;
  function IsAppsUseDarkTheme: Boolean;
  function IsSystemUseDarkTheme: Boolean;
  function IsTransparencyEnabled: Boolean;
  function GetUserNameString: string;
  function GetCompleteUserName: string;
  function GetFileTypeDescription(filetype: string): string;
  function GetTaskbarHeight: integer;
  function GetCurrentAppName: string;
  function GetOpenProgramFileName: string;
  function GetOpenProgramFileNameEx: ansistring;
  function GetUserCLSID: string;
  function GetUserGUID: string; (* This currently seems to not work/ is unrelated to user picture tasks *)
  function GetUserProfilePicturePath(PrefferedResolution: string = '1080'): string;
  (* Avalabile Resolutions are 1080, 448, 424, 208, 192, 96, 64, 48, 40, 32 *)
  function GetUserProfilePictureEx: string;
  procedure SetWallpaper(const FileName: string);
  procedure MinimiseAllWindows;
  function ProcessID: integer;

  function GetProcessList: TProcessList;

  procedure SimulateKeyPress32(key: Word; const shift: TShiftState; specialkey: Boolean);
  procedure OpenWindowsUI(WinInterface: TWinUX; SuppressAnimation: boolean = false);
  procedure OpenWindowsSettings(Page: TWinSettingsPage);
  procedure OpenWindowsUWPApp(AppURI: string);

  procedure ShutDownWindows;

  { File and Folder Related Tasks }
  procedure CreateShortcut(const PathObj, PathLink, Desc, Param: string);

implementation

const
  USER_PROFILE_PICTURES_LOCATION = '%PUBLIC%\AccountPictures\';

function GetWindowsPlatform: TWinVersion;
var
  NTKernel: single;
begin
  NTKernel := NTKernelVersion;
  if NTKernel <= 5  then
    Result := TWinVersion.Win2000
      else
        if NTKernel <= 5.1 then
          Result := TWinVersion.WinXp
            else
              if NTKernel <= 5.2 then
                Result := TWinVersion.WinXp64
                  else
                    if NTKernel <= 6.0 then
                      Result := TWinVersion.Vista2008
                        else
                          if NTKernel <= 6.1 then
                            Result := TWinVersion.Win72008R2
                              else
                                if NTKernel <= 6.2 then
                                  Result := TWinVersion.Win8
                                    else
                                      Result := TWinVersion.Win10;
end;

function IsWOW64Emulated: Boolean;
var
  IsWow64: BOOL;
begin
  // Check if the current process is running under WOW64
  if IsWow64Process(GetCurrentProcess, IsWow64) then
    Result := IsWow64
  else
    Result := False;
end;

function IsWow64Executable: Boolean;
type
  TIsWow64Process = function(AHandle: DWORD; var AIsWow64: BOOL): BOOL; stdcall;

var
  hIsWow64Process: TIsWow64Process;
  hKernel32: DWORD;
  IsWow64: BOOL;

begin
  Result := True;

  hKernel32 := Winapi.Windows.LoadLibrary('kernel32.dll');
  if hKernel32 = 0 then Exit;

  try
    @hIsWow64Process := Winapi.Windows.GetProcAddress(hKernel32, 'IsWow64Process');
    if not System.Assigned(hIsWow64Process) then
      Exit;

    IsWow64 := False;
    if hIsWow64Process(Winapi.Windows.GetCurrentProcess, IsWow64) then
      Result := not IsWow64;

  finally
    Winapi.Windows.FreeLibrary(hKernel32);
  end;
end;

function GetWindowsArhitecture: TWinPlatform;
begin
  if IsWOW64Emulated or IsWow64Executable then
    Result := TWinPlatform.Platform64
  else
    Result := TWinPlatform.Platform32;
end;

function NTKernelVersion: single;
begin
  Result := Win32MajorVersion + Win32MinorVersion / 10;
end;

function IdleTime: DWord;
var
  LastInput: TLastInputInfo;
begin
  LastInput.cbSize := SizeOf(TLastInputInfo);
  GetLastInputInfo(LastInput);
  Result := (GetTickCount - LastInput.dwTime) DIV 1000;
end;

function GetAccentColor(brightencolor: boolean ): TColor;
var
  R: TRegistry;
  ARGB: Cardinal;
begin
  Result := $D77800;  //  Default value on error
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKeyReadOnly('Software\Microsoft\Windows\DWM\') and R.ValueExists('AccentColor') then begin
      ARGB := R.ReadCardinal('AccentColor');
      Result := ARGB mod $FF000000; //  ARGB to RGB
    end;
  finally
    R.Free;
  end;

  if brightencolor then
    Result := ChangeColorSat(Result, 50);
end;

function IsAppsUseDarkTheme: Boolean;
var
  R: TRegistry;
begin
  Result := False;
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\') and R.ValueExists('AppsUseLightTheme') then begin
      Result := R.ReadInteger('AppsUseLightTheme') <> 1;
    end;
  finally
    R.Free;
  end;
end;

function IsSystemUseDarkTheme: Boolean;
var
  R: TRegistry;
begin
  Result := False;
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\') and R.ValueExists('SystemUsesLightTheme') then begin
      Result := R.ReadInteger('SystemUsesLightTheme') <> 1;
    end;
  finally
    R.Free;
  end;
end;

function IsTransparencyEnabled: Boolean;
var
  R: TRegistry;
begin
  Result := False;
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\') and R.ValueExists('EnableTransparency') then begin
      Result := R.ReadInteger('EnableTransparency') <> 1;
    end;
  finally
    R.Free;
  end;
end;

function GetUserNameString: string;
var
  nSize: DWord;
begin
 nSize := 1024;
 SetLength(Result, nSize);
 if GetUserName(PChar(Result), nSize) then
   SetLength(Result, nSize-1)
 else
   RaiseLastOSError;
end;

function GetCompleteUserName: string;
const
  nameType = NameDisplay;
var
  dwSize: DWORD;
  userName: PWideChar;
begin
  dwSize := 0;
  if Succeeded(GetUserNameEx(nameType, nil, dwSize)) then
  begin
    GetMem(userName, dwSize * SizeOf(WideChar));
    try
      if Succeeded(GetUserNameEx(nameType, userName, dwSize)) then
      begin
        // use the name
        Result := PChar(userName);
      end
      else
        RaiseLastOSError;
    finally
      FreeMem(userName);
    end;
  end
  else
    RaiseLastOSError;
end;

function GetFileTypeDescription(filetype: string): string;
begin
  if filetype = '' then
    Exit('File Folder');

  Result := STRING_UNKNOWN;
end;

function GetTaskbarHeight: integer;
var
  R: TRect;
begin
  SystemParametersInfo (Spi_getworkarea,0,@r,0);
  Result:=screen.Height-r.Bottom;
end;

function GetCurrentAppName: string;
var
  h: hWnd;
begin
  h := GetForegroundWindow;
  SetLength(Result, GetWindowTextLength(h) + 1);
  GetWindowText(h, PChar(Result), GetWindowTextLength(h) + 1);
end;

function GetOpenProgramFileName: String;
var
  pid     : DWORD;
  hProcess: THandle;
  path    : array[0..4095] of Char;
begin
  GetWindowThreadProcessId(GetForegroundWindow, pid);

  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, pid);
  if hProcess <> 0 then
    try
      if GetModuleFileNameEx(hProcess, 0, @path[0], Length(path)) = 0 then
        RaiseLastOSError;

      result := path;
    finally
      CloseHandle(hProcess);
    end
  else
    RaiseLastOSError;
end;

Function GetOpenProgramFileNameEx : ansistring;
var
  S : array[0..max_path] of char; // somplace to put the answer
  H : longword; // the window to be trapped
begin
  H := getforegroundwindow;
  Getwindowmodulefilename(h,s,max_path);
  result := ansistring(S);
end;

function GetUserCLSID: string;
var
  UserName, DomainName: string;
  UserSID: PSID;
  SIDSize: DWORD;
  SIDString: PChar;
  DomainSize: DWORD;
  SIDUse: SID_NAME_USE;
begin
  // Get the name of the currently logged-in user
  Username := GetUserNameString;

  // Lookup the account SID associated with the user name
  SIDSize := 0;
  DomainSize := 0;
  LookupAccountName(nil, PChar(UserName), nil, SIDSize, nil, DomainSize, SIDUse);
  UserSID := AllocMem(SIDSize);
  try
    SetLength(DomainName, DomainSize);
    if not LookupAccountName(nil, PChar(UserName), UserSID, SIDSize, PChar(DomainName),
        DomainSize, SIDUse) then
      RaiseLastOSError;

    // Convert the binary SID to a string format
    if not ConvertSidToStringSid(UserSID, SIDString) then
      RaiseLastOSError;
    try
      Result := SIDString;
    finally
      LocalFree(HLOCAL(SIDString));
    end;
  finally
    FreeMem(UserSID);
  end;
end;

function GetUserGUID: string;
var
  guid: TGUID;
begin
  if CoCreateGuid(guid) <> S_OK then
    RaiseLastOSError;
  Result := GUIDToString(guid);
end;

function GetUserProfilePicturePath(PrefferedResolution: string): string;
var
  L: TArray<string>;
  Path: string;
  Index: integer;
  I: Integer;
begin
  Path := IncludeTrailingPathDelimiter( ReplaceWinPath(USER_PROFILE_PICTURES_LOCATION) ) +
           GetUserCLSID + '\';

  L := TDirectory.GetFiles( Path );

  Index := 0;
  if Length( L ) > 0 then
    begin
      for I := 0 to High(L) do
        if Pos( 'Image' + PrefferedResolution, L[I]) <> 0 then
          begin
            Index := I;

            Break;
          end;

      Result := L[Index];
    end
      else
        Result := '';
end;

function GetUserProfilePictureEx: string;
begin
  Result :=
    IncludeTrailingPathDelimiter( GetUserShellLocation(TUserShellLocation.shlAppDataLocal) )
      + 'Microsoft\Windows\AccountPicture\UserImage.jpg';
end;

procedure SetWallpaper(const FileName: string);
begin
  if not SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(FileName), SPIF_UPDATEINIFILE) then
    raise Exception.Create(ERROR_SET_WALLPAPER);
end;

procedure MinimiseAllWindows;
var
  hTaskBar: HWND;
begin
  hTaskBar := FindWindow('Shell_TrayWnd', nil);
  if hTaskBar <> 0 then
    SendMessage(hTaskBar, WM_COMMAND, MAKEWPARAM(419, 0), 0);
end;

function ProcessID: integer;
begin
  Result := GetCurrentProcessId;
end;

function GetProcessList: TArray<TProcess>;
var
  hSnapshot: THandle;
  pe: TProcessEntry32;
  hProcess: THandle;
  bMore: BOOL;
  szProcessName: array[0..MAX_PATH] of Char;
  lpAddress, lpCommandLine: Pointer;
  dwRead: NativeUInt;
  szCommandLine: array[0..4096] of Char;

  Index: integer;
begin
  SetLength(Result, 0);

  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  pe.dwSize := SizeOf(TProcessEntry32);
  bMore := Process32First(hSnapshot, pe);
  while bMore do
  begin
    // Size
    Index := Length(Result);
    SetLength(Result, Index+1);

    // Module
    Result[Index].Module := pe.szExeFile;
    Result[Index].PID := pe.th32ProcessID;
    Result[Index].Modules := pe.th32ModuleID;
    Result[Index].Threads := pe.cntThreads;
    Result[Index].ParentPID := pe.th32ParentProcessID;
    Result[Index].Priority := pe.pcPriClassBase;
    Result[Index].Flags := pe.dwFlags;

    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or
      PROCESS_VM_READ, False, pe.th32ProcessID);
    if hProcess <> 0 then
    begin
      // Path
      GetModuleFileNameEx(hProcess, 0, szProcessName, SizeOf(szProcessName));
      Result[Index].FileName := szProcessName;

      // Command
      lpAddress := GetProcAddress(GetModuleHandle('kernel32.dll'), 'GetCommandLineA');
      if lpAddress <> nil then
      begin
        // Read the process memory at the address of GetCommandLineA to get the command line
        lpCommandLine := nil; // Initialize the pointer
        if ReadProcessMemory(hProcess, lpAddress, @lpCommandLine, SizeOf(lpCommandLine), dwRead) then
        begin
          // Read the actual command line from the memory pointed to by lpCommandLine
          dwRead := 0;
          if ReadProcessMemory(hProcess, lpCommandLine, @szCommandLine, SizeOf(szCommandLine), dwRead) then
            Result[Index].Command := szCommandLine;
        end;
      end;

      // Close
      CloseHandle(hProcess);
    end;

    // Next
    bMore := Process32Next(hSnapshot, pe);
  end;
  CloseHandle(hSnapshot);
end;

procedure SimulateKeyPress32(key: Word; const shift: TShiftState;
  specialkey: Boolean);
type
  TShiftKeyInfo = record
    shift: Byte;
    vkey: Byte;
  end;
  ByteSet = set of 0..7;
const
  shiftkeys: array [1..3] of TShiftKeyInfo = (
    (shift: Ord(ssCtrl) ; vkey: VK_CONTROL),
    (shift: Ord(ssShift) ; vkey: VK_SHIFT),
    (shift: Ord(ssAlt) ; vkey: VK_MENU)
  );
var
  flag: DWORD;
  bShift: ByteSet absolute shift;
  j: Integer;
begin
  for j := 1 to 3 do
  begin
    if shiftkeys[j].shift in bShift then
      keybd_event(
        shiftkeys[j].vkey, MapVirtualKey(shiftkeys[j].vkey, 0), 0, 0
    );
  end;
  if specialkey then
    flag := KEYEVENTF_EXTENDEDKEY
  else
    flag := 0;

  keybd_event(key, MapvirtualKey(key, 0), flag, 0);
  flag := flag or KEYEVENTF_KEYUP;
  keybd_event(key, MapvirtualKey(key, 0), flag, 0);

  for j := 3 downto 1 do
  begin
    if shiftkeys[j].shift in bShift then
      keybd_event(
        shiftkeys[j].vkey,
        MapVirtualKey(shiftkeys[j].vkey, 0),
        KEYEVENTF_KEYUP,
        0
      );
  end;
end;

procedure OpenWindowsUI(WinInterface: TWinUX; SuppressAnimation: boolean);
var
  URI, PARAM: string;
begin
  URI := '';
  PARAM := '';

  case WinInterface of
    TWinUX.ActionCenter: URI := 'ms-actioncenter:controlcenter/&suppressAnimations=' + BooleanToString(SuppressAnimation);
    TWinUX.Notifications: URI := 'ms-actioncenter://';
    TWinUX.Calculator: URI := 'ms-calculator://';
    TWinUX.Store: URI := 'ms-windows-store://';
    TWinUX.Support: URI := 'ms-contact-support://';
    TWinUX.Maps: URI := 'ms-drive-to://';
    TWinUX.Network: URI := 'ms-availablenetworks://';
    TWinUX.Cast: URI := 'ms-actioncenter:controlcenter/cast&suppressAnimations=' + BooleanToString(SuppressAnimation);
    TWinUX.Wifi: URI := 'ms-actioncenter:controlcenter/wifi&suppressAnimations=' + BooleanToString(SuppressAnimation);
    TWinUX.Project: URI := 'ms-actioncenter:controlcenter/project&suppressAnimations=' + BooleanToString(SuppressAnimation);
    TWinUX.Bluetooth: URI := 'ms-actioncenter:controlcenter/bluetooth&suppressAnimations=' + BooleanToString(SuppressAnimation);
    TWinUX.Clock: URI := 'ms-clock://';
    TWinUX.Xbox: URI := 'msxbox://';
    TWinUX.MediaPlayer: URI := 'ms-playto-audio://';
    TWinUX.Weather: URI := 'msnweather://';
    TWinUX.TaskSwitch: URI := 'ms-taskswitcher://';
    TWinUX.Settings: URI := 'ms-settings://';
    TWinUX.ScreenClip: URI := 'ms-screenclip://';
    TWinUX.Photos: URI := 'ms-photos://';
    TWinUX.PrintQueue: URI := 'ms-print-queue://';
    TWinUX.WinDefender: URI := 'windowsdefender://';
    TWinUX.StartMenu: SimulateKeyPress32( VK_LWIN, [], true);
  end;

  // Run
  if URI <> '' then
    ShellExecute(0, 'open', PChar(URI), PCHAR(PARAM), nil, 0);
end;

procedure OpenWindowsSettings(Page: TWinSettingsPage);
var
  URI: string;
begin
  case Page of
    TWinSettingsPage.Home: URI := 'ms-settings://';
    TWinSettingsPage.FlightMode: URI := 'ms-settings-airplanemode://';
    TWinSettingsPage.Bluetooth: URI := 'ms-settings-bluetooth://';
    TWinSettingsPage.Cellular: URI := 'ms-settings-cellular://';
    TWinSettingsPage.Accounts: URI := 'ms-settings-emailandaccounts://';
    TWinSettingsPage.Language: URI := 'ms-settings-language://';
    TWinSettingsPage.Location: URI := 'ms-settings-location://';
    TWinSettingsPage.LockScreen: URI := 'ms-settings-lock://';
    TWinSettingsPage.Hotspot: URI := 'ms-settings-mobilehotspot://';
    TWinSettingsPage.Notifications: URI := 'ms-settings-notifications://';
    TWinSettingsPage.Power: URI := 'ms-settings-power://';
    TWinSettingsPage.Privacy: URI := 'ms-settings-privacy://';
    TWinSettingsPage.Display: URI := 'ms-settings-screenrotation://';
    TWinSettingsPage.Wifi: URI := 'ms-settings-wifi://';
    TWinSettingsPage.Workplace: URI := 'ms-settings-workplace://';
  end;

  // Run
  ShellExecute(0, 'open', PChar(URI), '', nil, 0);
end;

procedure OpenWindowsUWPApp(AppURI: string);
var
  URI: string;
begin
  URI := AppURI + '://';

  ShellExecute(0, 'open', PChar(URI), PCHAR(URI), nil, 0);
end;

procedure ShutDownWindows;
begin
  ShellExecute(0, 'open', 'powershell', '-c "(New-Object -Com Shell.Application).ShutdownWindows()"', nil, 0);
end;

procedure CreateShortcut(const PathObj, PathLink, Desc, Param: string);
var
  IObject: IUnknown;
  SLink: IShellLink;
  PFile: IPersistFile;
begin
  IObject:=CreateComObject(CLSID_ShellLink);
  SLink:=IObject as IShellLink;
  PFile:=IObject as IPersistFile;
  with SLink do
  begin
    SetArguments(PChar(Param));
    SetDescription(PChar(Desc));
    SetPath(PChar(PathObj));
    SetWorkingDirectory(PChar(ExtractFileDir(PathObj)));
  end;
  PFile.Save(PWChar(WideString(PathLink)), FALSE);
end;

{ TProcessListHelper }

function TProcessListHelper.FindProcess(Executable: string): integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(Self) to High(Self) do
    if Self[I].Module = Executable then
      Exit(I);
end;

{ TProcess }

procedure TProcess.CloseProcess;
begin
  ShellExecute( 0, 'open', 'taskkill', PChar(Format('/PID "%D"', [PID])), nil, 0);
end;

function TProcess.GetIcon: TIcon;
var
  AICON: word;
begin
  if TFile.Exists(FileName) then
    begin
      AICON := 0;

      // Initiate
      Result := TIcon.Create;

      Result.Handle := ExtractAssociatedIcon(HInstance, PChar(FileName), AICON);
      Result.Transparent := true;
    end
      else
        Result := nil;
end;

procedure TProcess.KillProcess;
begin
  ShellExecute( 0, 'open', 'taskkill', PChar(Format('/PID "%D" /F', [PID])), nil, 0);
end;

end.