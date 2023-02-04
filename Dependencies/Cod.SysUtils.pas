{***********************************************************}
{                  Codruts System Utilities                 }
{                                                           }
{                        version 0.6                        }
{                           BETA                            }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                   -- WORK IN PROGRESS --                  }
{***********************************************************}

{$WARN SYMBOL_PLATFORM OFF}

unit Cod.SysUtils;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Registry, Vcl.Dialogs, Vcl.Forms, Vcl.StdCtrls,
  Vcl.Styles, Vcl.Themes, UITypes, Types, Winapi.shlobj, Cod.WinRegister, Math,
  IOUtils, ActiveX, ComObj, Variants, ShellApi, Cod.ColorUtils,
  System.TypInfo, Imaging.pngimage, PngFunctions, PsApi, Cod.Files, Cod.Types,
  Cod.StringUtils;

  type
    TWinVersion = (wvnWin2000, wvnWinXp, wvnXp64, wvnVista2008, wvnWin72008R2, wvnWin8, wvnWin10);
    { If the number of attributes if ever changed, it is required to update the
    write atttributes procedure with the new number in mind!! }

    TFileVersionInfo = record
      fCompanyName,
      fFileDescription,
      fFileVersion,
      fInternalName,
      fLegalCopyRight,
      fLegalTradeMark,
      fOriginalFileName,
      fProductName,
      fProductVersion,
      fComments: string;
    end;

    TStrInterval = record
      AStart: integer;
      AEnd: integer;

      function Length: integer;
    end;

const
  superspr : TArray<String> = ['⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹','⁺','⁻','⁼','⁽','⁾', '⁄','ᵃ', 'ᵇ', 'ᶜ', 'ᵈ', 'ᵉ', 'ᶠ', 'ᵍ', 'ʰ', 'ⁱ', 'ʲ', 'ᵏ', 'ˡ', 'ᵐ', 'ⁿ', 'ᵒ', 'ᵖ', 'q', 'ʳ', 'ˢ', 'ᵗ', 'ᵘ', 'ᵛ', 'ʷ', 'ˣ', 'ʸ', 'ᶻ', 'ᴬ', 'ᴮ', 'C', 'ᴰ', 'ᴱ', 'F', 'ᴳ', 'ᴴ', 'ᴵ', 'ᴶ', 'ᴷ', 'ᴸ', 'ᴹ', 'ᴺ', 'ᴼ', 'ᴾ', 'Q', 'ᴿ', 'S', 'ᵀ', 'ᵁ', 'ⱽ', 'ᵂ', 'X', 'Y', 'Z'];
  subspr : TArray<String> = ['₀','₁','₂','₃','₄','₅','₆','₇','₈','₉','+','-','=','(',')', '⁄', 'ₐ', 'b', 'c', 'd', 'ₑ', 'f', 'g', 'ₕ', 'ᵢ', 'j', 'ₖ', 'ₗ', 'ₘ', 'ₙ', 'ₒ', 'ₚ', 'q', 'ᵣ', 'ₛ', 'ₜ', 'ᵤ', 'ᵥ', 'w', 'ₓ', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  { Forms }
  procedure CenterFormInForm(form, primaryform: TForm; alsoopen: boolean = false);
  procedure CenterFormOnScreen(form: TForm);
  function MouseAboveForm(form: TForm): boolean;

  { Icons }
  procedure GetFileIcon(FileName: string; var PngImage: TPngImage; IconIndex: word = 0);
  function GetFileIconCount(FileName: string): integer;
  function GetAllFileIcons(FileName: string): TArray<TPngImage>;

  { String Legacy }
  function SuperStr(nr: string): string;
  function SubStr(nr: string): string;

  { Application }
  function IsAdministrator: boolean;

  { Components }
  procedure CopyObject(ObjFrom, ObjTo: TObject);
  procedure PrepareCustomTitleBar(var TitleBar: TForm; const Background: TColor; Foreground: TColor);
  procedure ResetPropertyValues(const AObject: TObject);
  procedure SetProperty(const AObject: TObject; PropertyName, NewValue: string); overload;
  procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: integer); overload;
  procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: boolean); overload;
  procedure SetStringProperty(const AObject: TObject; PropertyName, NewValue: string);
  procedure SetIntegerProperty(const AObject: TObject; PropertyName: string; NewValue: integer);
  procedure SetBooleanProperty(const AObject: TObject; PropertyName: string; NewValue: boolean);

  { File Associations }
  procedure UnregisterFileType(FileExt: String; OnlyForCurrentUser: boolean = true);
  function FileTypeExists(FileExt: String; OnlyForCurrentUser: boolean = true): boolean;
  function GetFileTypeAssociation(FileExt: String; var ADesc, AIcon: string; OnlyForCurrentUser: boolean = true): string;
  procedure RegisterFileType( FileExt: String; FileTypeDescription: String; ICONResourceFileFullPath: String; ApplicationFullPath: String; OnlyForCurrentUser: boolean = true);

  function GetGenericFileType( AExtension: string ): string;
  function GetGenericIconIndex( AExtension: string ): integer;
  function GetGenericFileIcon( AExtension: string; ALargeIcon: boolean = true ): TIcon;

  { Windows API }
  function GetWindowsVerByKernel: TWinVersion;
  function NTKernelVersion: single;
  function IdleTime: DWord;
  function GetAccentColor(brightencolor: boolean = false): TColor;
  function IsAppsUseDarkTheme: Boolean;
  function IsSystemUseDarkTheme: Boolean;
  function IsTransparencyEnabled: Boolean;
  function GetUserNm: string;
  function GetFileTypeDescription(filetype: string): string;
  function GetTaskbarHeight: integer;
  function GetCurrentAppName: string;
  function GetOpenProgramFileName: string;
  Function GetOpenProgramFileNameEx: ansistring;

  procedure ShutDownWindows;

  procedure CreateShortcut(const PathObj, PathLink, Desc, Param: string);

  { File and Folder Related Tasks }
  function GetTreeSize ( path: string ): int64;

  function GetAllFileProperties(filename: string; allowempty: boolean = true): TStringList;
  function GetFileProperty(FileName, PropertyName: string): string;
  //External
  function GetAllFileVersionInfo(FileName: string): TFileVersionInfo;
  function GetFileOwner(const AFileName : string) : string;

  { Misc }
  function IsInIDE: boolean;

implementation

procedure CenterFormOnScreen(form: TForm);
begin
  form.Left := Screen.Width div 2 - form.Width div 2;
  form.Top := Screen.Height div 2 - form.Height div 2;
end;

function GetTreeSize ( path: string ): int64;
var
 tsr: TSearchRec;
begin
 result := 0;
 path := IncludeTrailingPathDelimiter ( path );
 if FindFirst ( path + '*', faAnyFile, tsr ) = 0 then begin
  repeat
   if ( tsr.attr and faDirectory ) > 0 then begin
    if ( tsr.name <> '.' ) and ( tsr.name <> '..' ) then
     inc ( result, GetTreeSize ( path + tsr.name ) );
   end
   else
   begin
    if tsr.size < 0 then
      SHowMessage('');
    inc ( result, tsr.size );
   end;
  until FindNext ( tsr ) <> 0;
  FindClose ( tsr );
 end;
end;

procedure CenterFormInForm(form, primaryform: TForm; alsoopen: boolean);
begin
  if form.Position <> poDesigned then
    form.Position := poDesigned;

  form.Left := primaryform.Left + primaryform.Width div 2 -form.Width div 2;
  form.Top := primaryform.Top + primaryform.Height div 2 -form.Height div 2;

  if alsoopen then
    form.Show;
end;

function MouseAboveForm(form: TForm): boolean;
begin
  Result := false;

  if (mouse.CursorPos.X > form.Left)
    and (mouse.CursorPos.Y > form.Top)
    and (mouse.CursorPos.X < form.Left + form.Width)
    and (mouse.CursorPos.Y < form.Top + form.Height) then
      Result := true;
end;

procedure RegisterFileType(FileExt, FileTypeDescription,
  ICONResourceFileFullPath, ApplicationFullPath: String;
  OnlyForCurrentUser: boolean);
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if OnlyForCurrentUser then
      R.RootKey := HKEY_CURRENT_USER
    else
      R.RootKey := HKEY_LOCAL_MACHINE;

    if R.OpenKey('\Software\Classes\.' + FileExt, true) then begin
      R.WriteString('', FileExt + 'File');
      if R.OpenKey('\Software\Classes\' + FileExt + 'File', true) then begin
        R.WriteString('', FileTypeDescription);
        if R.OpenKey('\Software\Classes\' + FileExt + 'File\DefaultIcon', true) then
        begin
          R.WriteString('', ICONResourceFileFullPath);
          if R.OpenKey('\Software\Classes\' + FileExt + 'File\shell\open\command', true) then
          R.WriteString('', ApplicationFullPath + ' "%1"');
          end;
        end;
      end;
    finally
    R.Free;
  end;
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
end;

function GetGenericFileType( AExtension: string ): string;
{ Get file type for an extension }
var
  AInfo: TSHFileInfo;
begin
  SHGetFileInfo( PChar( AExtension ), FILE_ATTRIBUTE_NORMAL, AInfo, SizeOf( AInfo ),
    SHGFI_TYPENAME or SHGFI_USEFILEATTRIBUTES );
  Result := AInfo.szTypeName;
end;

function GetGenericIconIndex( AExtension: string ): integer;
{ Get icon index for an extension type }
var
  AInfo: TSHFileInfo;
begin
  if SHGetFileInfo( PChar( AExtension ), FILE_ATTRIBUTE_NORMAL, AInfo, SizeOf( AInfo ),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_USEFILEATTRIBUTES ) <> 0 then
  Result := AInfo.iIcon
  else
    Result := -1;
end;

function GetGenericFileIcon( AExtension: string; ALargeIcon: boolean ): TIcon;
{ Get icon for an extension }
var
  AInfo: TSHFileInfo;
  AIcon: TIcon;
  AFlags: integer;
begin
  AFlags :=SHGFI_ICON+SHGFI_TYPENAME+SHGFI_USEFILEATTRIBUTES;
  if ALargeIcon then
    AFlags := AFlags + SHGFI_LARGEICON
  else
    AFlags := AFlags + SHGFI_SMALLICON;

  if SHGetFileInfo( PChar( AExtension ), FILE_ATTRIBUTE_NORMAL, AInfo, SizeOf( AInfo ),
    AFlags ) <> 0 then
  begin
    AIcon := TIcon.Create;
    try
      AIcon.Handle := AInfo.hIcon;
      Result := AIcon;
    except
      AIcon.Free;
      raise;
    end;
  end
  else
    Result := nil;
end;

function FileTypeExists(FileExt: String;
  OnlyForCurrentUser: boolean): boolean;
var
  key: HKEY;
begin
  if OnlyForCurrentUser then
    key := HKEY_CURRENT_USER
  else
    key := HKEY_LOCAL_MACHINE;

  Result := false;

  if
    WinReg.KeyExists('\Software\Classes\.' + FileExt, key) AND
    WinReg.KeyExists('\Software\Classes\' + FileExt + 'File', key)
  then Result := true;
end;

function GetFileTypeAssociation(FileExt: String; var ADesc, AIcon: string;
         OnlyForCurrentUser: boolean): string;
var
  R: TRegistry;
begin
  R := TRegistry.Create(KEY_READ);
  try
    if FileExt[1] = '.' then
      FileExt := Copy(FileExt, 2, Length(FileExt));

    if OnlyForCurrentUser then
      R.RootKey := HKEY_CURRENT_USER
    else
      R.RootKey := HKEY_LOCAL_MACHINE;

    if R.OpenKey('\Software\Classes\.' + FileExt, false) then begin
      if R.OpenKey('\Software\Classes\' + FileExt + 'File', false) then begin
        ADesc := R.ReadString('');
        if R.OpenKey('\Software\Classes\' + FileExt + 'File\DefaultIcon', false) then
        begin
          AIcon := R.ReadString('');
          if R.OpenKey('\Software\Classes\' + FileExt + 'File\shell\open\command', false) then
          Result := R.ReadString('');

          Result := StringReplace(Result, ' "%1"', '', [rfReplaceAll]);
          end;
        end;
      end;
    finally
    R.Free;
  end;
end;

function GetFileTypeDescription(filetype: string): string;
begin
  if filetype = '' then
    Exit('File Folder');

  Result := 'Unknown';
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

function GetWindowsVerByKernel: TWinVersion;
var
  NTKernel: single;
begin
  NTKernel := NTKernelVersion;
  if NTKernel <= 5  then
    Result := wvnWin2000
      else
        if NTKernel <= 5.1 then
          Result := wvnWinXp
            else
              if NTKernel <= 5.2 then
                Result := wvnXp64
                  else
                    if NTKernel <= 6.0 then
                      Result := wvnVista2008
                        else
                          if NTKernel <= 6.1 then
                            Result := wvnWin72008R2
                              else
                                if NTKernel <= 6.2 then
                                  Result := wvnWin8
                                    else
                                      Result := wvnWin10;
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
      ARGB := R.ReadInteger('AccentColor');
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

function GetUserNm: string;
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

function IsAdministrator: boolean;
var
  str: string;
begin
  str :=  'Software\' + inttostr(randomrange(1000,9999));

  if WinReg.CreateKey(str) then
    Result := true
  else
    Result := false;

  WinReg.DeleteKey(str);
end;

procedure GetFileIcon(FileName: string; var PngImage: TPngImage; IconIndex: word);
var
  ic: TIcon;
begin
  // Get TIcon
  ic := TIcon.Create;
  ic.Handle := ExtractAssociatedIcon(HInstance, PChar(FileName), IconIndex);
  ic.Transparent := true;

  // Convert to PNG
  PngImage := TPngImage.Create;

  ConvertToPNG(ic, PngImage);
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

procedure CopyObject(ObjFrom, ObjTo: TObject);
  var
PropInfos: PPropList;
PropInfo: PPropInfo;
Count, Loop: Integer;
OrdVal: Longint;
StrVal: String;
FloatVal: Extended;
MethodVal: TMethod;
begin
//{ Iterate thru all published fields and properties of source }
//{ copying them to target }

//{ Find out how many properties we'll be considering }
Count := GetPropList(ObjFrom.ClassInfo, tkAny, nil);
//{ Allocate memory to hold their RTTI data }
GetMem(PropInfos, Count * SizeOf(PPropInfo));
try
//{ Get hold of the property list in our new buffer }
GetPropList(ObjFrom.ClassInfo, tkAny, PropInfos);
//{ Loop through all the selected properties }
for Loop := 0 to Count - 1 do
begin
  PropInfo := GetPropInfo(ObjTo.ClassInfo, String(PropInfos^[Loop]^.Name));
 // { Check the general type of the property }
  //{ and read/write it in an appropriate way }
  case PropInfos^[Loop]^.PropType^.Kind of
    tkInteger, tkChar, tkEnumeration,
    tkSet, tkClass{$ifdef Win32}, tkWChar{$endif}:
    begin
      OrdVal := GetOrdProp(ObjFrom, PropInfos^[Loop]);
      if Assigned(PropInfo) then
        SetOrdProp(ObjTo, PropInfo, OrdVal);
    end;
    tkFloat:
    begin
      FloatVal := GetFloatProp(ObjFrom, PropInfos^[Loop]);
      if Assigned(PropInfo) then
        SetFloatProp(ObjTo, PropInfo, FloatVal);
    end;
    {$ifndef DelphiLessThan3}
    tkWString,
    {$endif}
    {$ifdef Win32}
    tkLString,
    {$endif}
    tkString:
    begin
      { Avoid copying 'Name' - components must have unique names }
      if UpperCase(String(PropInfos^[Loop]^.Name)) = 'NAME' then
        Continue;
      StrVal := GetStrProp(ObjFrom, PropInfos^[Loop]);
      if Assigned(PropInfo) then
        SetStrProp(ObjTo, PropInfo, StrVal);
    end;
    tkMethod:
    begin
      MethodVal := GetMethodProp(ObjFrom, PropInfos^[Loop]);
      if Assigned(PropInfo) then
        SetMethodProp(ObjTo, PropInfo, MethodVal);
    end
  end
end
finally
  FreeMem(PropInfos, Count * SizeOf(PPropInfo));
end;
end;

procedure PrepareCustomTitleBar(var TitleBar: TForm; const Background: TColor; Foreground: TColor);
var
  CB, CF, SCB, SCF: integer;
begin
  if GetColorSat(BackGround) < 100 then
    CB := 30
  else
    CB := -30;

  if GetColorSat(Foreground) < 100 then
    CF := 30
  else
    CF := -30;

  SCF := CF div 2;
  SCB := CF div 2;

  with TitleBar.CustomTitleBar do
    begin
      BackgroundColor := BackGround;
      InactiveBackgroundColor := ChangeColorSat(BackGround, CB);
      ButtonBackgroundColor := BackGround;
      ButtonHoverBackgroundColor := ChangeColorSat(BackGround, SCB);
      ButtonInactiveBackgroundColor := ChangeColorSat(BackGround, CB);
      ButtonPressedBackgroundColor := ChangeColorSat(BackGround, CB);

      ForegroundColor := Foreground;
      ButtonForegroundColor := Foreground;
      ButtonHoverForegroundColor := ChangeColorSat(ForeGround, SCF);
      InactiveForegroundColor := ChangeColorSat(Foreground, CF);
      ButtonInactiveForegroundColor := ChangeColorSat(Foreground, CF);
      ButtonPressedForegroundColor := ChangeColorSat(Foreground, CF);
    end;
end;

procedure ResetPropertyValues(const AObject: TObject);
var
  PropIndex: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
const
  TypeKinds: TTypeKinds = [tkEnumeration, tkString, tkLString, tkWString,
    tkUString];
begin
  PropCount := GetPropList(AObject.ClassInfo, TypeKinds, nil);
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(AObject.ClassInfo, TypeKinds, PropList);
    for PropIndex := 0 to PropCount - 1 do
    begin
      PropInfo := PropList^[PropIndex];

      // Set
      if Assigned(PropInfo^.SetProc) then
      case PropInfo^.PropType^.Kind of
        tkString, tkLString, tkUString, tkWString:
          SetStrProp(AObject, PropInfo, '');
        tkEnumeration:
          if GetTypeData(PropInfo^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
            SetOrdProp(AObject, PropInfo, 0);

      end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

procedure SetProperty(const AObject: TObject; PropertyName, NewValue: string); overload;
begin
  if AObject <> nil then
    SetStringProperty( AObject, PropertyName, NewValue);
end;

procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: integer); overload;
begin
  if AObject <> nil then
    SetIntegerProperty( AObject, PropertyName, NewValue);
end;

procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: boolean); overload;
begin
  if AObject <> nil then
    SetBooleanProperty( AObject, PropertyName, NewValue);
end;

procedure SetStringProperty(const AObject: TObject; PropertyName, NewValue: string);
var
  PropIndex: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
  PropRest: string;
  PropDot: Integer;
const
  TypeKinds: TTypeKinds = [tkString, tkLString, tkWString, tkUString, tkClass];
begin
  PropCount := GetPropList(AObject.ClassInfo, TypeKinds, nil);
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(AObject.ClassInfo, TypeKinds, PropList);
    for PropIndex := 0 to PropCount - 1 do
    begin
      PropInfo := PropList^[PropIndex];

      // Multi Class
      if Pos('.', PropertyName) <> 0 then
        begin
          PropDot := Pos('.', PropertyName);
          PropRest := Copy( PropertyName, PropDot + 1, length(Propertyname) );
          PropertyName := Copy( PropertyName, 0, PropDot - 1 );
        end;

      // Set
      if AnsiLowerCase(string(PropInfo.Name)) = AnsiLowerCase(PropertyName) then
        if Assigned(PropInfo^.SetProc) then
        case PropInfo^.PropType^.Kind of
          tkString, tkLString, tkUString, tkWString:
            SetStrProp(AObject, PropInfo, NewValue);
          tkClass: SetStringProperty( GetObjectProp(AObject, PropInfo), PropRest, NewValue );
        end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

procedure SetIntegerProperty(const AObject: TObject; PropertyName: string; NewValue: integer);
var
  PropIndex: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
  PropRest: string;
  PropDot: Integer;
const
  TypeKinds: TTypeKinds = [tkInteger, tkEnumeration, tkClass];
begin
  PropCount := GetPropList(AObject.ClassInfo, TypeKinds, nil);
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(AObject.ClassInfo, TypeKinds, PropList);
    for PropIndex := 0 to PropCount - 1 do
    begin
      PropInfo := PropList^[PropIndex];

      // Multi Class
      if Pos('.', PropertyName) <> 0 then
        begin
          PropDot := Pos('.', PropertyName);
          PropRest := Copy( PropertyName, PropDot + 1, length(Propertyname) );
          PropertyName := Copy( PropertyName, 0, PropDot - 1 );
        end;

      // Set
      if AnsiLowerCase(string(PropInfo.Name)) = AnsiLowerCase(PropertyName) then
        if Assigned(PropInfo^.SetProc) then
        case PropInfo^.PropType^.Kind of
          tkEnumeration, tkInteger:
            SetOrdProp(AObject, PropInfo, NewValue);
          tkClass: SetIntegerProperty( GetObjectProp(AObject, PropInfo), PropRest, NewValue );
        end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

procedure SetBooleanProperty(const AObject: TObject; PropertyName: string; NewValue: boolean);
var
  PropIndex: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
  PropRest: string;
  PropDot: Integer;
const
  TypeKinds: TTypeKinds = [tkEnumeration, tkClass];
begin
  PropCount := GetPropList(AObject.ClassInfo, TypeKinds, nil);
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(AObject.ClassInfo, TypeKinds, PropList);
    for PropIndex := 0 to PropCount - 1 do
    begin
      PropInfo := PropList^[PropIndex];

      // Multi Class
      if Pos('.', PropertyName) <> 0 then
        begin
          PropDot := Pos('.', PropertyName);
          PropRest := Copy( PropertyName, PropDot + 1, length(Propertyname) );
          PropertyName := Copy( PropertyName, 0, PropDot - 1 );
        end;

      // Set
      if AnsiLowerCase(string(PropInfo.Name)) = AnsiLowerCase(PropertyName) then
        if Assigned(PropInfo^.SetProc) then
        case PropInfo^.PropType^.Kind of
          tkEnumeration, tkInteger:
            SetOrdProp(AObject, PropInfo, integer(NewValue));
          tkClass: SetBooleanProperty( GetObjectProp(AObject, PropInfo), PropRest, NewValue );
        end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

function IsInIDE: boolean;
begin
  if TStyleManager.ActiveStyle.Name = 'Mountain_Mist' then
    Result := true
  else
    Result := false;
end;

function SuperStr(nr: string): string;
var
  I: Integer;
begin
  for I := 1 to Length ( nr ) do
    case nr[I] of
      ' ': Result := Result + ' ';
      '0': Result := Result + superspr[0];
      '1': Result := Result + superspr[1];
      '2': Result := Result + superspr[2];
      '3': Result := Result + superspr[3];
      '4': Result := Result + superspr[4];
      '5': Result := Result + superspr[5];
      '6': Result := Result + superspr[6];
      '7': Result := Result + superspr[7];
      '8': Result := Result + superspr[8];
      '9': Result := Result + superspr[9];
      '+': Result := Result + superspr[10];
      '-': Result := Result + superspr[11];
      '=': Result := Result + superspr[12];
      '(': Result := Result + superspr[13];
      ')': Result := Result + superspr[14];
      '/': Result := Result + superspr[15];
      'a': Result := Result + superspr[16];
      'b': Result := Result + superspr[17];
      'c': Result := Result + superspr[18];
      'd': Result := Result + superspr[19];
      'e': Result := Result + superspr[20];
      'f': Result := Result + superspr[21];
      'g': Result := Result + superspr[22];
      'h': Result := Result + superspr[23];
      'i': Result := Result + superspr[24];
      'j': Result := Result + superspr[25];
      'k': Result := Result + superspr[26];
      'l': Result := Result + superspr[27];
      'm': Result := Result + superspr[28];
      'n': Result := Result + superspr[29];
      'o': Result := Result + superspr[30];
      'p': Result := Result + superspr[31];
      'q': Result := Result + superspr[32];
      'r': Result := Result + superspr[33];
      's': Result := Result + superspr[34];
      't': Result := Result + superspr[35];
      'u': Result := Result + superspr[36];
      'v': Result := Result + superspr[37];
      'w': Result := Result + superspr[38];
      'x': Result := Result + superspr[39];
      'y': Result := Result + superspr[40];
      'z': Result := Result + superspr[41];
      'A': Result := Result + superspr[42];
      'B': Result := Result + superspr[43];
      'C': Result := Result + superspr[44];
      'D': Result := Result + superspr[45];
      'E': Result := Result + superspr[46];
      'F': Result := Result + superspr[47];
      'G': Result := Result + superspr[48];
      'H': Result := Result + superspr[49];
      'I': Result := Result + superspr[50];
      'J': Result := Result + superspr[51];
      'K': Result := Result + superspr[52];
      'L': Result := Result + superspr[53];
      'M': Result := Result + superspr[54];
      'N': Result := Result + superspr[55];
      'O': Result := Result + superspr[56];
      'P': Result := Result + superspr[57];
      'Q': Result := Result + superspr[58];
      'R': Result := Result + superspr[59];
      'S': Result := Result + superspr[60];
      'T': Result := Result + superspr[61];
      'U': Result := Result + superspr[62];
      'V': Result := Result + superspr[63];
      'W': Result := Result + superspr[64];
      'X': Result := Result + superspr[65];
      'Y': Result := Result + superspr[66];
      'Z': Result := Result + superspr[67];
    end;
end;

procedure UnregisterFileType(FileExt: String;
  OnlyForCurrentUser: boolean);
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if OnlyForCurrentUser then
      R.RootKey := HKEY_CURRENT_USER
    else
      R.RootKey := HKEY_LOCAL_MACHINE;

    R.DeleteKey('\Software\Classes\.' + FileExt);
    R.DeleteKey('\Software\Classes\' + FileExt + 'File');
  finally
    R.Free;
  end;
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
end;

function SubStr(nr: string): string;
var
  I: Integer;
begin
  for I := 1 to Length ( nr ) do
    case nr[I] of
      ' ': Result := Result + ' ';
      '0': Result := Result + subspr[0];
      '1': Result := Result + subspr[1];
      '2': Result := Result + subspr[2];
      '3': Result := Result + subspr[3];
      '4': Result := Result + subspr[4];
      '5': Result := Result + subspr[5];
      '6': Result := Result + subspr[6];
      '7': Result := Result + subspr[7];
      '8': Result := Result + subspr[8];
      '9': Result := Result + subspr[9];
      '+': Result := Result + subspr[10];
      '-': Result := Result + subspr[11];
      '=': Result := Result + subspr[12];
      '(': Result := Result + subspr[13];
      ')': Result := Result + subspr[14];
      '/': Result := Result + subspr[15];
      'a': Result := Result + subspr[16];
      'b': Result := Result + subspr[17];
      'c': Result := Result + subspr[18];
      'd': Result := Result + subspr[19];
      'e': Result := Result + subspr[20];
      'f': Result := Result + subspr[21];
      'g': Result := Result + subspr[22];
      'h': Result := Result + subspr[23];
      'i': Result := Result + subspr[24];
      'j': Result := Result + subspr[25];
      'k': Result := Result + subspr[26];
      'l': Result := Result + subspr[27];
      'm': Result := Result + subspr[28];
      'n': Result := Result + subspr[29];
      'o': Result := Result + subspr[30];
      'p': Result := Result + subspr[31];
      'q': Result := Result + subspr[32];
      'r': Result := Result + subspr[33];
      's': Result := Result + subspr[34];
      't': Result := Result + subspr[35];
      'u': Result := Result + subspr[36];
      'v': Result := Result + subspr[37];
      'w': Result := Result + subspr[38];
      'x': Result := Result + subspr[39];
      'y': Result := Result + subspr[40];
      'z': Result := Result + subspr[41];
      'A': Result := Result + subspr[42];
      'B': Result := Result + subspr[43];
      'C': Result := Result + subspr[44];
      'D': Result := Result + subspr[45];
      'E': Result := Result + subspr[46];
      'F': Result := Result + subspr[47];
      'G': Result := Result + subspr[48];
      'H': Result := Result + subspr[49];
      'I': Result := Result + subspr[50];
      'J': Result := Result + subspr[51];
      'K': Result := Result + subspr[52];
      'L': Result := Result + subspr[53];
      'M': Result := Result + subspr[54];
      'N': Result := Result + subspr[55];
      'O': Result := Result + subspr[56];
      'P': Result := Result + subspr[57];
      'Q': Result := Result + subspr[58];
      'R': Result := Result + subspr[59];
      'S': Result := Result + subspr[60];
      'T': Result := Result + subspr[61];
      'U': Result := Result + subspr[62];
      'V': Result := Result + subspr[63];
      'W': Result := Result + subspr[64];
      'X': Result := Result + subspr[65];
      'Y': Result := Result + subspr[66];
      'Z': Result := Result + subspr[67];
    end;
end;

{File}
function GetAllFileProperties(filename: string; allowempty: boolean = true): TStringList;
var
  Shell : Variant;
  OleFolder : OleVariant;
  OleFolderItem: OleVariant;
  VsFilePath : Variant;
  VsFileName : Variant;
  PropName,
  PropValue: string;
  I: integer;

  Directory: string;
begin
  Result := TStringList.Create;

  Directory := Copy(FileName, 0, FileName.LastIndexOf('\'));

  if NOT TDirectory.Exists(directory) or NOT TFile.Exists(filename) then
    Exit;

  Shell := CreateOleObject('Shell.Application');
  VsFilePath := Directory;
  OleFolder := Shell.Namespace(VsFilePath);
  VsFileName := ExtractFileName(FileName);
  OleFolderItem := OleFolder.ParseName(VsFileName);


  I := 0;
  PropName := 'File Name';

  while (PropName <> '') or (I = 0) do
  begin
    PropValue := OleFolder.GetDetailsOf(OleFolderItem, I);
    if (NOT (PropValue = '')) or Allowempty then
      Result.Add(Format('%s = %s', [PropName, PropValue]));

    //if uppercase('Contributing artists') = uppercase(PropName) then

    I := I + 1;
    PropName := OleFolder.GetDetailsOf(null, I);
  end;
end;

function GetFileProperty(FileName, PropertyName: string): string;
var
  R: TStringList;
  s1, s2: string;
  I: Integer;
begin
  Result := 'Not Found';

  R := GetAllFileProperties(FileName);

  for I := 0 to R.Count - 1 do
  begin
    s1 := Copy(R[I], 0, Pos(' =', R[I]) - 1);
    s2 := Copy(R[I], length(s1) + 4, Length(R[I]) );

    if AnsiLowerCase(s1) = AnsiLowerCase(PropertyName) then
    begin
      Result := s2;
      Break;
    end;
  end;

  R.Free;
end;

function GetAllFileVersionInfo(FileName: string): TFileVersionInfo;
{ proc to get all version info from a file. }
var
  Buf       : PChar;
  fInfoSize : DWord;
  procedure InitVersion;
  var
    FileNamePtr  : PChar;
  begin
    with Result do
      begin
        FileNamePtr := PChar(FileName);
        fInfoSize := GetFileVersionInfoSize(FileNamePtr, fInfoSize);
        if fInfoSize > 0 then
          begin
            ReAllocMem(Buf, fInfoSize);
            GetFileVersionInfo(FileNamePtr, 0, fInfoSize, Buf);
          end;
      end;
  end;
  function GetVersion(What : String): string;
  var
    tmpVersion: string;
    Len       : Dword;
    Value     : PChar;
  begin
    Result := 'Not defined';
    if fInfoSize > 0 then
      begin
        SetLength(tmpVersion, 200);
        Value := @tmpVersion;
        { If you are not using an English OS, then replace the language &  }
        { code-page identifier with the correct one.  English (U.S.) is    }
        { 0409 (language) & 04E4 (code-page).  See Code-Page Identifiers & }
        { Language Identifiers in the Win32 help file for info.            }
        if VerQueryValue(Buf, PChar('StringFileInfo\040904E4\' + What),
                         Pointer(Value), Len) then
          Result := Value;
      end;
  end;
begin
  Buf := nil;
  with Result do
    begin
      InitVersion;
      fCompanyName      := GetVersion('CompanyName');
      fFileDescription  := GetVersion('FileDescription');
      fFileVersion      := GetVersion('FileVersion');
      fInternalName     := GetVersion('InternalName');
      fLegalCopyRight   := GetVersion('LegalCopyRight');
      fLegalTradeMark   := GetVersion('LegalTradeMark');
      fOriginalFileName := GetVersion('OriginalFileName');
      fProductName      := GetVersion('ProductName');
      fProductVersion   := GetVersion('ProductVersion');
      fComments         := GetVersion('Comments');
    end;
  if Buf <> nil then
    FreeMem(Buf);
end;

function GetFileOwner(const AFileName : string) : string;
var
  LSWbemLocator, LWMIService, LObjects, LObject : OLEVariant;
  FileName       : string;
  LEnumerator    : IEnumvariant;
  iValue         : LongWord;
begin;
  Result := '';
  LSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  LWMIService   := LSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');

  //Escape the `\` chars in the FileName value because the '\' is a reserved character in WMI.
  FileName        := StringReplace(AFileName, '\', '\\', [rfReplaceAll]);
  LObjects   := LWMIService.ExecQuery(Format('ASSOCIATORS OF {Win32_LogicalFileSecuritySetting="%s"} WHERE Assoc= Win32_LogicalFileOwner ResultRole = Owner', [FileName]));

  LEnumerator  := IUnknown(LObjects._NewEnum) as IEnumVariant;
  if LEnumerator.Next(1, LObject, iValue) = 0 then
     Result := string(LObject.AccountName);   //
end;

{ TStrInterval }

function TStrInterval.Length: integer;
begin
  Result := AEnd - AStart;
end;

end.
