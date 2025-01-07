{***********************************************************}
{                 Cod Utils - Dark Mode Api                 }
{                                                           }
{                        version 1.0                        }
{                                                           }
{                                                           }
{     This library is sourced from the following repos      }
{        https://github.com/HemulGM/WindowDarkMode          }
{     https://github.com/chuacw/Delphi-Dark-Mode-demo       }
{  https://github.com/adzm/win32-custom-menubar-aero-theme  }
{                                                           }
{***********************************************************}

unit Cod.Windows.ThemeApi;
{$WARN SYMBOL_PLATFORM OFF}
{$ALIGN ON}
{$MINENUMSIZE 4}

interface

uses
  Winapi.Windows;

type
  TWinRoundType = (wrtDEFAULT = 0, wrtDONOTROUND = 1, wrtROUND = 2, wrtROUNDSMALL = 3);

  TDwmWindowAttribute = (
    DWMWA_NCRENDERING_ENABLED = 1,                    //
    DWMWA_NCRENDERING_POLICY,                         //
    DWMWA_TRANSITIONS_FORCEDISABLED,                  //
    DWMWA_ALLOW_NCPAINT,                              //
    DWMWA_CAPTION_BUTTON_BOUNDS,                      //
    DWMWA_NONCLIENT_RTL_LAYOUT,                       //
    DWMWA_FORCE_ICONIC_REPRESENTATION,                //
    DWMWA_FLIP3D_POLICY,                              //
    DWMWA_EXTENDED_FRAME_BOUNDS,                      //
    DWMWA_HAS_ICONIC_BITMAP,                          //
    DWMWA_DISALLOW_PEEK,                              //
    DWMWA_EXCLUDED_FROM_PEEK,                         //
    DWMWA_CLOAK,                                      //
    DWMWA_CLOAKED,                                    //
    DWMWA_FREEZE_REPRESENTATION,                      //
    DWMWA_PASSIVE_UPDATE_MODE,                        //
    DWMWA_USE_HOSTBACKDROPBRUSH,                      //17
    DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1 = 19,   //
    DWMWA_USE_IMMERSIVE_DARK_MODE = 20,               //
    DWMWA_WINDOW_CORNER_PREFERENCE = 33,              //
    DWMWA_BORDER_COLOR,                               //
    DWMWA_CAPTION_COLOR,                              //
    DWMWA_TEXT_COLOR,                                 //
    DWMWA_VISIBLE_FRAME_BORDER_THICKNESS,             //
    DWMWA_SYSTEMBACKDROP_TYPE,                        //
    DWMWA_LAST);

    TDWMWindowCornerPreference = (DWMWCP_DEFAULT = 0, DWMWCP_DONOTROUND = 1, DWMWCP_ROUND = 2, DWMWCP_ROUNDSMALL = 3);
    TImmersiveHCCacheMode = (IHCM_USE_CACHED_VALUE, IHCM_REFRESH);
    TPreferredAppMode = (DefaultMode, AllowDarkMode, ForceDarkMode, ForceLightMode, ModeMax);

    TWindowCompositionAttribute = (WCA_UNDEFINED = 0, //
    WCA_NCRENDERING_ENABLED = 1, //
    WCA_NCRENDERING_POLICY = 2, //
    WCA_TRANSITIONS_FORCEDISABLED = 3, //
    WCA_ALLOW_NCPAINT = 4, //
    WCA_CAPTION_BUTTON_BOUNDS = 5, //
    WCA_NONCLIENT_RTL_LAYOUT = 6, //
    WCA_FORCE_ICONIC_REPRESENTATION = 7, //
    WCA_EXTENDED_FRAME_BOUNDS = 8, //
    WCA_HAS_ICONIC_BITMAP = 9, //
    WCA_THEME_ATTRIBUTES = 10, //
    WCA_NCRENDERING_EXILED = 11, //
    WCA_NCADORNMENTINFO = 12, //
    WCA_EXCLUDED_FROM_LIVEPREVIEW = 13, //
    WCA_VIDEO_OVERLAY_ACTIVE = 14, //
    WCA_FORCE_ACTIVEWINDOW_APPEARANCE = 15, //
    WCA_DISALLOW_PEEK = 16, //
    WCA_CLOAK = 17, //
    WCA_CLOAKED = 18, //
    WCA_ACCENT_POLICY = 19, //
    WCA_FREEZE_REPRESENTATION = 20, //
    WCA_EVER_UNCLOAKED = 21, //
    WCA_VISUAL_OWNER = 22, //
    WCA_HOLOGRAPHIC = 23, //
    WCA_EXCLUDED_FROM_DDA = 24, //
    WCA_PASSIVEUPDATEMODE = 25, //
    WCA_USEDARKMODECOLORS = 26, //
    WCA_LAST = 27);

  WINDOWCOMPOSITIONATTRIBDATA = record
    Attrib: TWindowCompositionAttribute;
    pvData: Pointer;
    cbData: SIZE_T;
  end;

  TWindowCompositionAttribData = WINDOWCOMPOSITIONATTRIBDATA;
  PWindowCompositionAttribData = ^TWindowCompositionAttribData;

// DWM
function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HResult; stdcall; overload;
function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: TDwmWindowAttribute; var pvAttribute; cbAttribute: DWORD): HResult; stdcall; overload;
function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: TDwmWindowAttribute; var pvAttribute: TDWMWindowCornerPreference; cbAttribute: DWORD): HResult; stdcall; overload;

/// <summary>
/// Enables dark context menus which change automatically depending on the theme.
/// </summary>
procedure AllowDarkModeForApp(allow: BOOL); stdcall;
/// <summary>
/// Enables dark mode for window titlebar and border.
/// </summary>
function AllowDarkModeForWindow(hWnd: HWND; allow: Boolean): Boolean; stdcall;

// See https://en.wikipedia.org/wiki/Windows_10_version_history
function CheckBuildNumber(buildNumber: DWORD): Boolean;
function IsWindows10OrGreater(buildNumber: DWORD = 10000): Boolean;
function IsWindows11OrGreater(buildNumber: DWORD = 22000): Boolean;
function IsDarkModeAllowedForWindow(hWnd: HWND): BOOL; stdcall;
procedure RefreshImmersiveColorPolicyState; stdcall;
procedure RefreshTitleBarThemeColor(hWnd: HWND);
function ImmersiveDarkMode: TDwmWindowAttribute;

// Theme
function ShouldAppsUseDarkMode: BOOL; stdcall;
function ShouldSystemUseDarkMode: BOOL; stdcall;

const
  LOAD_LIBRARY_SEARCH_SYSTEM32 = $00000800;

implementation

uses
  System.Classes, System.SysUtils, UITypes, System.Win.Registry;

const
  BackColor: TColor = $1E1E1E;
  TextColor: TColor = $F0F0F0;
  InputBackColor: TColor = $303030;
  Dwmapi = 'dwmapi.dll';
  CDarkModeExplorer = 'DarkMode_Explorer';
  CModeExplorer = 'Explorer';
  CDarkModeControlCFD = 'DarkMode_CFD';
  DWM_CLOAKED_APP = $0000001;
  DWM_CLOAKED_SHELL = $0000002;
  DWM_CLOAKED_INHERITED = $0000004;
  ODS_NOACCEL = $0100;
  WM_UAHDESTROYWINDOW = $0090;	// handled by DefWindowProc
  WM_UAHDRAWMENU = $0091;	// lParam is UAHMENU
  WM_UAHDRAWMENUITEM = $0092;	// lParam is UAHDRAWMENUITEM
  WM_UAHINITMENU = $0093;	// handled by DefWindowProc
  WM_UAHMEASUREMENUITEM = $0094;	// lParam is UAHMEASUREMENUITEM
  WM_UAHNCPAINTMENUPOPUP = $0095;	// handled by DefWindowProc
  WM_UAHUPDATE = $0096;

var
  _AllowDarkModeForApp: function(allow: BOOL): BOOL; stdcall = nil;
  _AllowDarkModeForWindow: function(hWnd: HWND; allow: BOOL): BOOL; stdcall = nil;
  _GetIsImmersiveColorUsingHighContrast: function(mode: TImmersiveHCCacheMode): BOOL; stdcall = nil;
  _IsDarkModeAllowedForWindow: function(hWnd: HWND): BOOL; stdcall = nil;
  _OpenNcThemeData: function(hWnd: HWND; pszClassList: LPCWSTR): THandle; stdcall = nil;
  _RefreshImmersiveColorPolicyState: procedure; stdcall = nil;
  _SetPreferredAppMode: function(appMode: TPreferredAppMode): TPreferredAppMode; stdcall = nil;
  _SetWindowCompositionAttribute: function(hWnd: HWND; pData: PWindowCompositionAttribData): BOOL; stdcall = nil;
  _ShouldAppsUseDarkMode: function: BOOL; stdcall;
  _ShouldSystemUseDarkMode: function: BOOL; stdcall = nil;
  GDarkModeSupported: BOOL = False; // changed type to BOOL
  GDarkModeEnabled: BOOL = False;  // ?
  GUxTheme: HMODULE = 0;

function DwmSetWindowAttribute(hwnd: hwnd; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HResult; stdcall; overload; external Dwmapi name 'DwmSetWindowAttribute' delayed;

function DwmSetWindowAttribute(hwnd: hwnd; dwAttribute: TDwmWindowAttribute; var pvAttribute: TDWMWindowCornerPreference; cbAttribute: DWORD): HResult; stdcall; overload; external Dwmapi name 'DwmSetWindowAttribute' delayed;

function GetThemeRegistryKey(Value: string; out ThemeValue: BOOL): boolean;
begin
  Result := false;
  ThemeValue := true; // default (light theme)

  // Read from registry
  with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\')
        and ValueExists(Value) then begin
          Result := true;
          ThemeValue := ReadInteger(Value) <> 1;
        end;
    finally
      Free;
    end;
end;

procedure AllowDarkModeForApp(allow: BOOL);
begin
  if Assigned(_AllowDarkModeForApp) then
    _AllowDarkModeForApp(allow)
  else if Assigned(_SetPreferredAppMode) then
  begin
    if allow then
      _SetPreferredAppMode(TPreferredAppMode.AllowDarkMode)
    else
      _SetPreferredAppMode(TPreferredAppMode.DefaultMode);
  end;
end;

function DwmSetWindowAttribute(hwnd: hwnd; dwAttribute: TDwmWindowAttribute; var pvAttribute; cbAttribute: DWORD): HResult;
begin
  Result := DwmSetWindowAttribute(hwnd, Ord(dwAttribute), @pvAttribute, cbAttribute);
end;

function IsDarkModeAllowedForWindow(hWnd: hWnd): BOOL;
begin
  Result := Assigned(_IsDarkModeAllowedForWindow) and _IsDarkModeAllowedForWindow(hWnd);
end;

function GetIsImmersiveColorUsingHighContrast(mode: TImmersiveHCCacheMode): BOOL;
begin
  Result := Assigned(_GetIsImmersiveColorUsingHighContrast) and _GetIsImmersiveColorUsingHighContrast(mode);
end;

function ImmersiveDarkMode: TDwmWindowAttribute;
begin
  if IsWindows10OrGreater(18985) then
    Result := DWMWA_USE_IMMERSIVE_DARK_MODE
  else
    Result := DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1;
end;

procedure RefreshImmersiveColorPolicyState;
begin
  if Assigned(_RefreshImmersiveColorPolicyState) then
    _RefreshImmersiveColorPolicyState;
end;

function ShouldSystemUseDarkMode: BOOL;
begin
  {if Assigned(_ShouldSystemUseDarkMode) then
    Result :=  _ShouldSystemUseDarkMode
  else}
    GetThemeRegistryKey('SystemUsesLightTheme', Result);
end;
function CheckBuildNumber(buildNumber: DWORD): Boolean;
begin
  Result :=
    IsWindows10OrGreater(20348) or
    IsWindows10OrGreater(19045) or  //
    IsWindows10OrGreater(19044) or  //
    IsWindows10OrGreater(19043) or  //
    IsWindows10OrGreater(19042) or  //
    IsWindows10OrGreater(19041) or  // 2004
    IsWindows10OrGreater(18363) or  // 1909
    IsWindows10OrGreater(18362) or  // 1903
    IsWindows10OrGreater(17763);    // 1809
end;

function IsWindows10OrGreater(buildNumber: DWORD): Boolean;
begin
  Result := (TOSVersion.Major > 10) or ((TOSVersion.Major = 10) and (TOSVersion.Minor = 0) and (DWORD(TOSVersion.Build) >= buildNumber));
end;

function IsWindows11OrGreater(buildNumber: DWORD): Boolean;
begin
  Result := IsWindows10OrGreater(22000) or IsWindows10OrGreater(buildNumber);
end;

function AllowDarkModeForWindow(hWnd: hWnd; allow: Boolean): Boolean;
begin
  Result := GDarkModeSupported and _AllowDarkModeForWindow(hWnd, allow);
end;

function IsHighContrast: Boolean;
var
  highContrast: HIGHCONTRASTW;
begin
  highContrast.cbSize := SizeOf(highContrast);
  if SystemParametersInfo(SPI_GETHIGHCONTRAST, SizeOf(highContrast), @highContrast, Ord(False)) then
    Result := highContrast.dwFlags and HCF_HIGHCONTRASTON <> 0
  else
    Result := False;
end;

procedure RefreshTitleBarThemeColor(hWnd: hWnd);
var
  LUseDark: BOOL;
  LData: TWindowCompositionAttribData;
begin
  LUseDark := _IsDarkModeAllowedForWindow(hWnd) and _ShouldAppsUseDarkMode and not IsHighContrast;
  if TOSVersion.Build < 18362 then
    SetProp(hWnd, 'UseImmersiveDarkModeColors', THandle(LUseDark))
  else if Assigned(_SetWindowCompositionAttribute) then
  begin
    LData.Attrib := WCA_USEDARKMODECOLORS;
    LData.pvData := @LUseDark;
    LData.cbData := SizeOf(LUseDark);
    _SetWindowCompositionAttribute(hWnd, @LData);
  end;
end;

function ShouldAppsUseDarkMode: BOOL;
begin
  {if Assigned(_ShouldAppsUseDarkMode) then
    Result :=  _ShouldAppsUseDarkMode
  else}
    GetThemeRegistryKey('AppsUseLightTheme', Result);
end;

initialization
  if ((TOSVersion.Major <> 10) or (TOSVersion.Minor <> 0) or not CheckBuildNumber(TOSVersion.Build)) then
    Exit;

  GUxTheme := LoadLibrary('uxtheme.dll');
  if GUxTheme <> 0 then
  begin
    @_AllowDarkModeForWindow := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(133));
    @_GetIsImmersiveColorUsingHighContrast := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(106));
    @_IsDarkModeAllowedForWindow := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(137));
    @_RefreshImmersiveColorPolicyState := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(104));
    @_SetWindowCompositionAttribute := GetProcAddress(GetModuleHandle(user32), 'SetWindowCompositionAttribute');
    @_ShouldAppsUseDarkMode := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(132));
    @_ShouldSystemUseDarkMode := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(138));

    var P := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(135));
    if TOSVersion.Build < 18362 then
      @_AllowDarkModeForApp := P
    else
      @_SetPreferredAppMode := P;

    if Assigned(_RefreshImmersiveColorPolicyState) and
      Assigned(_ShouldAppsUseDarkMode) and Assigned(_AllowDarkModeForWindow) and
      (Assigned(_AllowDarkModeForApp) or Assigned(_SetPreferredAppMode)) and
      Assigned(_IsDarkModeAllowedForWindow) then
    begin
      GDarkModeSupported := True;
      AllowDarkModeForApp(True);
      _RefreshImmersiveColorPolicyState;
      GDarkModeEnabled := ShouldAppsUseDarkMode and not IsHighContrast;
    end;
  end;

finalization
  if GUxTheme <> 0 then
    FreeLibrary(GUxTheme);
end.

