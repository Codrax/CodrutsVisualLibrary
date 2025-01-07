unit Cod.Windows;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Registry, Vcl.Dialogs, Vcl.Forms, UITypes, Types, Winapi.shlobj,
  Cod.Registry, IOUtils, ActiveX, ComObj, ShellApi, Cod.ColorUtils, PsApi,
  Vcl.Imaging.pngimage, Cod.Graphics, Cod.Files, Cod.Types, Cod.MesssageConst,
  Winapi.TlHelp32, Cod.Windows.ThemeApi, Cod.SysUtils, Winapi.PropKey, Winapi.PropSys;

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

  // Process handle
  TProcessHandle = type THandle;
  TProcessHandleHelper = record helper for TProcessHandle
  public
    function ModuleFilePath: string;
    function ProcessName: string;
    function ModuleName: string;

    // For applications
    function GetAppUserModelID: string;

    // Commands
    function Terminate(AExitCode: integer=1): boolean;

    // Main
    constructor Create(ProcessID: DWORD; Permissions: DWORD; InheritHandle: boolean);
    procedure CloseHandle; // must be called after tasks are done
  end;

  // Process ID
  TProcessID = type DWORD;
  TProcessIDHelper = record helper for TProcessID
  public
    function ProcessHandle(Permissions: DWORD): TProcessHandle;
    function ProcessHandleReadOnly: TProcessHandle;
    function ProcessHandleAllAcccess: TProcessHandle;
  end;

  // Handle helper
  THWNDHelper = record helper for HWND
  public
    // Information
    function GetTitle: string;
    function GetBoundsRect: TRect;
    function GetClientRect: TRect;
    function GetCanvas: TCanvas;

    function GetAppUserModelID: string;

    // Messages
    function PostMessage(Message: UINT; wParam: WPARAM; lParam: LPARAM): boolean;
    function SendMessage(Message: UINT; wParam: WPARAM; lParam: LPARAM): int64;
    procedure PostCloseMessage;

    // Extras
    function GetModuleFilePathEx: string;

    // Process
    function GetProcessID: TProcessID;

    // Children
    function GetChildWindows: TArray<HWND>;
  end;

const
  shlwapi = 'shlwapi.dll';


{ Forms }
/// <summary>
///  Remove the WS_CAPTION style flag from the form and make a border only form which supports Windows Aero.
///  </summary>
procedure MakeBorderForm(Form: TForm);

{ shlwapi }
function SHLoadIndirectString(pszSource: PWideChar; pszOutBuf: PWideChar; cchOutBuf: UINT; ppvReserved: Pointer): HRESULT; stdcall; external shlwapi;

{ Shell32 }
function HasAdministratorPrivileges: boolean;
function IsUserAnAdmin(): BOOL; external shell32;
function IsAdministrator32: boolean;
function SHDoDragDrop(Handle: hwnd; dataObj: IDataObject; dropSource: IDropSource;
  dwEffect: Longint; var pdwEffect: Longint): integer; stdcall; external shell32 name 'SHDoDragDrop';

{ AdvApi32 }
function CheckTokenMembership(TokenHandle: THANDLE; SidToCheck: Pointer;
  var IsMember: BOOL): BOOL; stdcall; external advapi32 name 'CheckTokenMembership'

{ Kernel32 }
function GetApplicationUserModelId(hProcess: THandle; var AppUserModelIdLength: DWORD; AppUserModelId: PWideChar): HRESULT; stdcall; external kernel32;

{ Resources }
function LoadIndirectString(const Source: string; var Output: string; BufferSize: cardinal=4096): boolean;

function LoadIndirectStringFromResourceID(const FilePath: string; const ResourceID: string; out Output: string): boolean; overload;
function LoadIndirectStringFromResourceID(const FilePath: string; const ResourceID: string; out Output: string; VersionModifier: string): boolean; overload;

{ Windows }
function GetWindowsPlatform: TWinVersion;
function IsWOW64Emulated: boolean;
function IsWow64Executable: Boolean;
function GetWindowsArhitecture: TWinPlatform;
function NTKernelVersion: single;

{ Personalisation }
procedure SetWallpaper(const FileName: string);
function DarkModeAppsActive: Boolean;
function DarkModeSystemActive: Boolean;
procedure DarkModeApplyToWindow(Handle: HWND); overload;
procedure DarkModeApplyToWindow(Handle: HWND; DarkTheme: boolean); overload;
function TransparencyEnabled: Boolean;
function GetAccentColor(brightencolor: boolean = false): TColor;

{ Shell }
function GetWinlogonShell: string;
function GetTaskbarHeight: integer;
procedure MinimiseAllWindows;
function IdleTime: DWord;
procedure FlashWindowInTaskbar;

{ User }
function GetUserCLSID: string;
function GetUserGUID: string; (* This currently seems to not work/ is unrelated to user picture tasks *)
/// <summary> Returns user name. The value used in the users folder and login. </summary>
function GetUserNameString: string;
/// <summary> Returns computer name. eg. "HOME-COMPUTER". </summary>
function GetComputerNameString: string;
/// <summary> Returns account name of computer name. eg. "COMPUTER-NAME\john-doe" </summary>
function GetComputerAccountName: string;
/// <summary> Returns account display name. eg. "John Doe" </summary>
function GetCompleteUserName: string;
/// <summary>
/// Get account profile picture based on the provided resolution.
///  These can by standard, be as follows: 1080, 448, 424, 208, 192, 96, 64, 48, 40, 32
/// </summary>
function GetUserProfilePicturePath(PrefferedResolution: string = '1080'): string;
/// <summary> [DEPRACATED] Returns user profile picture location based on old standard. </summary>
function GetUserProfilePictureEx: string;

{ Process }
/// <summary> Returns list of all running processes. </summary>
function GetProcessList: TProcessList;
/// <summary> Returns process ID (PID) of this application. </summary>
function ProcessID: integer;
function GetCurrentAppName: string;
function GetOpenProgramFileName: string;
function GetOpenProgramFileNameEx: ansistring;
function GetActiveWindow: HWND;
function GetActiveWindows: TArray<HWND>;

{ HWND }
function GetAppUserModelIDFromWindow(Window: HWND; out Output: string): boolean;

{ Icons }
function GetIconStrIcon(IconString: string; Icon: TIcon): boolean; overload;
function GetIconStrIcon(IconString: string; PngImage: TPngImage): boolean; overload;
procedure GetFileIcon(FileName: string; PngImage: TPngImage; IconIndex: word = 0);
procedure GetFileIconEx(FileName: string; PngImage: TPngImage; IconIndex: word = 0; SmallIcon: boolean = false);
function GetFileIconCount(FileName: string): integer;
function GetAllFileIcons(FileName: string): TArray<TPngImage>;

{ Input }
procedure SimulateKeyPress32(key: Word; const shift: TShiftState; specialkey: Boolean);

{ Registry }
procedure RegisterApplicationPath(Name: string; Executable: string; Directory: string = '');
procedure UnregisterApplicationPath(Name: string);

{ Dialogs }
procedure OpenWindowsUI(WinInterface: TWinUX; SuppressAnimation: boolean = false);
procedure OpenWindowsSettings(Page: TWinSettingsPage);
procedure OpenWindowsUWPApp(AppURI: string);
procedure ShutDownWindows;

{ File and Folder Related Tasks }
procedure CreateShortcut(const Target, DestinationFile, Description, Parameters: string);
function GetFileTypeDescription(filetype: string): string;

const
  KEYEVENTF_KEYDOWN = 0; // declaration
  VK_ENTER = VK_RETURN;

implementation

const
  USER_PROFILE_PICTURES_LOCATION = '%PUBLIC%\AccountPictures\';
  APP_PATH_REGISTER_LOCATION = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\';

procedure MakeBorderForm(Form: TForm);
var
  Style: Cardinal;
begin
  Style := GetWindowLong(Form.Handle, GWL_STYLE);

  // Remove caption bar
  Style := Style and not (WS_CAPTION) or WS_SIZEBOX;
  SetWindowLong(Form.Handle, GWL_STYLE, Style);

  // Crate
  Form.Perform(WM_NCCREATE, 0, 0);

  // Is minimised?
  if not IsIconic(Form.Handle) then
    // Re-calculate bounds
    SetWindowPos(Form.Handle, 0, Form.Left, Form.Top, Form.Width, Form.Height,
      SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED)
end;

function HasAdministratorPrivileges: boolean;
begin
  Result := IsUserAnAdmin;
end;

function IsAdministrator32: boolean;
const
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority =
    (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;
var
  AdminGroup: PSID;
  Res: longbool;
begin
  // IsUserAdmin from Shell32 also works
  if AllocateAndInitializeSid(
    SECURITY_NT_AUTHORITY, 2,
    SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
    0, 0, 0, 0, 0, 0, AdminGroup) then
  begin
    try
      CheckTokenMembership(0, AdminGroup, Res);
      Result := Res;
    finally
      FreeSid(AdminGroup);
    end;
  end
  else
    Result := False;
end;

function LoadIndirectString(const Source: string; var Output: string; BufferSize: cardinal): boolean;
var
  OutputBuffer: WideString;
begin
  // Create
  SetLength(OutputBuffer, BufferSize);
  ZeroMemory(@OutputBuffer[1], BufferSize);

  // SHLoadIndirectString
  Result := Succeeded(SHLoadIndirectString(PWideChar(Source), @OutputBuffer[1], BufferSize, nil));

  // Result
  if Result then
    Output := WideCharToString(@OutputBuffer[1]);
end;

function LoadIndirectStringFromResourceID(const FilePath: string; const ResourceID: string; out Output: string): boolean;
begin
  Result := LoadIndirectString(
    Format('@%S,%S', [FilePath, ResourceID]), Output
  );
end;

function LoadIndirectStringFromResourceID(const FilePath: string; const ResourceID: string; out Output: string; VersionModifier: string): boolean;
begin
  Result := LoadIndirectString(
    Format('@%S,%S;%S', [FilePath, ResourceID, VersionModifier]), Output
  );
end;

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

procedure FlashWindowInTaskbar;
var
  Flash: FLASHWINFO;
begin
  FillChar(Flash, SizeOf(Flash), 0);
  Flash.cbSize := SizeOf(Flash);
  Flash.hwnd := Application.Handle;
  Flash.uCount := 5;
  Flash.dwTimeOut := 2000;
  Flash.dwFlags := FLASHW_ALL;
  FlashWindowEx(Flash);
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

function DarkModeAppsActive: Boolean;
begin
  Result := Cod.Windows.ThemeApi.ShouldAppsUseDarkMode;
end;

function DarkModeSystemActive: Boolean;
begin
  Result := Cod.Windows.ThemeApi.ShouldSystemUseDarkMode;
end;
procedure DarkModeApplyToWindow(Handle: HWND);
begin
  DarkModeApplyToWindow(Handle, DarkModeAppsActive);
end;

procedure DarkModeApplyToWindow(Handle: HWND; DarkTheme: boolean); overload;
var
  Value: longbool;
begin
  Value := DarkTheme; // must be longbool

  DwmSetWindowAttribute(Handle, ImmersiveDarkMode, Value, SizeOf(Value));
  AllowDarkModeForWindow(Handle, Value);
  AllowDarkModeForApp(Value);
end;

function TransparencyEnabled: Boolean;
begin
  Result := TQuickReg.GetBoolValue('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\', 'EnableTransparency');
end;

function GetUserNameString: string;
var
  dwSize: DWORD;
begin
  // Get size
  dwSize := 0;
  GetUserName(nil, dwSize);

  // None
  if dwSize = 0 then
    Exit('');

  // Provide address
  SetLength(Result, dwSize-1); // exclude null-terminated
  if not GetUserName(PWideChar(Result), dwSize) then
    RaiseLastOSError;
end;

function GetComputerNameString: string;
const
  nameType = TComputerNameFormat.ComputerNameNetBIOS;
var
  dwSize: DWord;
begin
  // Get size
  dwSize := 0;
  GetComputerNameEx(nameType, nil, dwSize);

  // None
  if dwSize = 0 then
    Exit('');

  // Provide address
  SetLength(Result, dwSize-1); // exclude null-terminated
  if not GetComputerNameEx(nameType, PWideChar(Result), dwSize) then
    RaiseLastOSError;
end;

function GetComputerAccountName: string;
const
  nameType = EXTENDED_NAME_FORMAT.NameSamCompatible;
var
  dwSize: DWORD;
begin
  // Get size
  dwSize := 0;
  GetUserNameEx(nameType, nil, dwSize);

  // None
  if dwSize = 0 then
    Exit('');

  // Provide address
  SetLength(Result, dwSize-1); // exclude null-terminated
  if not GetUserNameEx(nameType, PWideChar(Result), dwSize) then
    RaiseLastOSError;
end;

function GetCompleteUserName: string;
const
  nameType = NameDisplay;
var
  dwSize: DWORD;
begin
  // Get size
  dwSize := 0;
  GetUserNameEx(nameType, nil, dwSize);

  // None
  if dwSize = 0 then
    Exit('');

  // Provide address
  SetLength(Result, dwSize-1); // exclude null-terminated
  if not GetUserNameEx(nameType, PWideChar(Result), dwSize) then
    RaiseLastOSError;
end;

function GetFileTypeDescription(filetype: string): string;
begin
  if filetype = '' then
    Exit('File Folder');

  Result := STRING_UNKNOWN;
end;

function GetWinlogonShell: string;
begin
  Result := TQuickReg.GetStringValue('Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', 'Shell');
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

function GetActiveWindow: HWND;
begin
  Result := GetForegroundWindow;
end;

function EnumWindowsCallback_ProcessPointer(Wnd: HWND; lParam: LPARAM): BOOL; stdcall;
type
  AType = TArray<HWND>;
  ATypeP = ^AType;
var
  ArrayP: ATypeP;
begin
  ArrayP := ATypeP(lParam);
  const Index = Length(ArrayP^);
  SetLength(ArrayP^, Index+1);
  ArrayP^[Index] := Wnd;

  Result := true;
end;
function GetActiveWindows: TArray<HWND>;
begin
  Result := [];

  EnumWindows(@EnumWindowsCallback_ProcessPointer, LPARAM(@Result));
end;

function GetAppUserModelIDFromWindow(Window: HWND; out Output: string): boolean;
var
  propStore: IPropertyStore;
  propVariant: TPropVariant;
begin
  Result := false;
  Output := '';

  // Get prop store
  if not Succeeded(SHGetPropertyStoreForWindow(Window, IID_IPropertyStore, Pointer(propStore))) then
    Exit;

  // Assert
  ZeroMemory(@propVariant, SizeOf(propVariant));
  try
    if not Succeeded(propStore.GetValue(PKEY_AppUserModel_ID, propVariant)) then
      Exit;

    // Variant type
    case propVariant.vt of
      VT_EMPTY: Output := ''; // result false
      VT_BSTR: begin
        Result := true;
        Output := string(propVariant.bstrVal);
      end;
      VT_LPWSTR: begin
        Result := true;
        Output := string(propVariant.pwszVal);
      end;

      //else ;
    end;
  finally
    PropVariantClear(propVariant);
  end;
end;

function GetIconStrIcon(IconString: string; Icon: TIcon): boolean; overload;
var
  IconIndex: word;
  FilePath: string;
begin
  Result := false;

  // Load
  ExtractIconDataEx(IconString, FilePath, IconIndex);
  if not TFile.Exists(FilePath) then
    Exit;

  // Get TIcon
  Icon.Handle := ExtractAssociatedIcon(HInstance, PChar(FilePath), IconIndex);
  Icon.Transparent := true;

  // Success
  Result := true;
end;

function GetIconStrIcon(IconString: string; PngImage: TPngImage): boolean;
var
  Icon: TIcon;
  IconIndex: word;
begin
  Result := false;

  // Load
  ExtractIconDataEx(IconString, IconString, IconIndex);
  if not TFile.Exists(IconString) then
    Exit;

  // Get TIcon
  Icon := TIcon.Create;
  try
    Icon.Handle := ExtractAssociatedIcon(HInstance, PChar(IconString), IconIndex);
    Icon.Transparent := true;

    // Convert to PNG
    ConvertToPNG(Icon, PngImage);

    // Success
    Result := true;
  finally
    Icon.Free;
  end;
end;

procedure GetFileIcon(FileName: string; PngImage: TPngImage; IconIndex: word);
var
  ic: TIcon;
begin
  // Get TIcon
  ic := TIcon.Create;
  try
    ic.Handle := ExtractAssociatedIcon(HInstance, PChar(FileName), IconIndex);
    ic.Transparent := true;

    // Convert to PNG
    ConvertToPNG(ic, PngImage);
  finally
    ic.Free;
  end;
end;

procedure GetFileIconEx(FileName: string; PngImage: TPngImage; IconIndex: word;
  SmallIcon: boolean);
var
  ic: TIcon;
  SHFileInfo: TSHFileInfo;
  Flags: Cardinal;
begin
  Flags := SHGFI_ICON or SHGFI_USEFILEATTRIBUTES;
  if SmallIcon then
    Flags := Flags or SHGFI_SMALLICON
  else
    Flags := Flags or SHGFI_LARGEICON;

  SHGetFileInfo(PChar(FileName), 0, SHFileInfo, SizeOf(TSHFileInfo),
    Flags);

  // Get TIcon
  ic := TIcon.Create;
  try
    ic.Handle := SHFileInfo.hIcon;;
    ic.Transparent := true;

    // Convert to PNG
    PngImage := TPngImage.Create;

    ConvertToPNG(ic, PngImage);
  finally
    ic.Free;
  end;
end;

function GetFileIconCount(FileName: string): integer;
begin
  Result := ExtractIcon(0, PChar(FileName), Cardinal(-1));
end;

function GetAllFileIcons(FileName: string): TArray<TPngImage>;
var
  cnt: integer;
  I: Integer;
begin
  // Get Count
  cnt := GetFileIconCount(FileName);

  SetLength(Result, cnt);

  for I := 0 to cnt - 1 do
    begin
      Result[I] := TPngImage.Create;

      try
        GetFileIcon(FileName, Result[I], I);
      except
        // Invalid icon handle
      end;
    end;
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
    IncludeTrailingPathDelimiter( GetUserShellLocation(TUserShellLocation.AppDataLocal) )
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

procedure RegisterApplicationPath(Name: string; Executable: string; Directory: string);
const
  N_PATH = 'Path';
var
  R: TWinRegistry;
begin
  const RegPath = APP_PATH_REGISTER_LOCATION + Name + '\';

  R := TWinRegistry.Create;
  try
    if not R.KeyExists(RegPath) then
      R.CreateKey(RegPath);

    R.WriteValue(RegPath, '', Executable);

    if Directory <> '' then
      R.WriteValue(RegPath, N_PATH, Directory)
    else
      if R.GetValueExists(RegPath, N_PATH) then
        R.DeleteValue(Regpath, N_PATH);
  finally
    R.Free;
  end;
end;

procedure UnregisterApplicationPath(Name: string);
begin
  const RegPath = APP_PATH_REGISTER_LOCATION + Name + '\';
  if TQuickReg.KeyExists(RegPath) then
    TQuickReg.DeleteKey(RegPath);
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

procedure CreateShortcut(const Target, DestinationFile, Description, Parameters: string);
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
    SetArguments(PChar(Parameters));
    SetDescription(PChar(Description));
    SetPath(PChar(Target));
    SetWorkingDirectory(PChar(ExtractFileDir(Target)));
  end;
  PFile.Save(PWChar(WideString(DestinationFile)), FALSE);
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

{ THWNDHelper }

function THWNDHelper.GetAppUserModelID: string;
begin
  if not GetAppUserModelIDFromWindow(Self, Result) then
    Result := '';
end;

function THWNDHelper.GetBoundsRect: TRect;
begin
  GetWindowRect(Self, Result);
end;

function THWNDHelper.GetCanvas: TCanvas;
begin
  Result := TCanvas.Create;
  Result.Handle := GetWindowDC(Self);
end;

function THWNDHelper.GetChildWindows: TArray<HWND>;
begin
  EnumChildWindows(Self, @EnumWindowsCallback_ProcessPointer, LPARAM(@Result));
end;

function THWNDHelper.GetClientRect: TRect;
begin
  Winapi.Windows.GetClientRect(Self, Result);
end;

function THWNDHelper.GetProcessID: TProcessID;
begin
  GetWindowThreadProcessId(Self, DWORD(Result));
end;

function THWNDHelper.GetTitle: string;
var
  Title: array[0..255] of Char;
begin
  GetWindowText(Self, Title, Length(Title));

  Result := Title;
end;

function THWNDHelper.GetModuleFilePathEx: string;
var
  OutValue: array[0..MAX_PATH] of Char;
begin
  GetWindowModuleFileName(Self, OutValue, Length(OutValue));

  Result := OutValue;
end;

function THWNDHelper.PostMessage(Message: UINT; wParam: WPARAM;
  lParam: LPARAM): boolean;
begin
  Result := Winapi.Windows.PostMessage(Self, Message, wParam, lParam);
end;

function THWNDHelper.SendMessage(Message: UINT; wParam: WPARAM;
  lParam: LPARAM): int64;
begin
  Result := Winapi.Windows.SendMessage(Self, Message, wParam, lParam);
end;

procedure THWNDHelper.PostCloseMessage;
begin
  PostMessage(WM_CLOSE, 0, 0);
end;

{ TProcessIDHelper }

function TProcessIDHelper.ProcessHandle(Permissions: DWORD): TProcessHandle;
begin
  Result := TProcessHandle.Create(Self, Permissions, false);
end;

function TProcessIDHelper.ProcessHandleAllAcccess: TProcessHandle;
begin
  Result := ProcessHandle(PROCESS_ALL_ACCESS);
end;

function TProcessIDHelper.ProcessHandleReadOnly: TProcessHandle;
begin
  Result := ProcessHandle(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ);
end;

{ TProcessHandleHelper }

procedure TProcessHandleHelper.CloseHandle;
begin
  Winapi.Windows.CloseHandle(Self);
end;

constructor TProcessHandleHelper.Create(ProcessID, Permissions: DWORD;
  InheritHandle: boolean);
begin
  Self := OpenProcess(DWORD(Permissions), InheritHandle, DWORD(ProcessID));
end;

function TProcessHandleHelper.GetAppUserModelID: string;
var
  dwSize: DWORD;
begin
  // Get size
  dwSize := 0;
  GetApplicationUserModelId(Self, dwSize, nil);

  // None
  if dwSize = 0 then
    Exit('');

  // Provide address
  SetLength(Result, dwSize-1); // exclude null-terminated
  if not Succeeded(GetApplicationUserModelId(Self, dwSize, PWideChar(Result))) then
    RaiseLastOSError;
end;

function TProcessHandleHelper.ModuleFilePath: string;
var
  path: array[0..4095] of Char;
begin
  if GetModuleFileNameEx(Self, 0, @path[0], Length(path)) = 0 then
    RaiseLastOSError;

  Result := path;
end;

function TProcessHandleHelper.ModuleName: string;
var
  path: array[0..4095] of Char;
begin
  if GetModuleBaseName(Self, 0, @path[0], Length(path)) = 0 then
    RaiseLastOSError;

  Result := path;
end;

function TProcessHandleHelper.ProcessName: string;
begin
  Result := ChangeFileExt(ModuleName, '');
end;

function TProcessHandleHelper.Terminate(AExitCode: integer): boolean;
begin
  Result := Winapi.Windows.TerminateProcess( Self, AExitCode );
end;

end.