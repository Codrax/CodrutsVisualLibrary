{***********************************************************}
{                     Codruts File Systems                  }
{                                                           }
{                        version 0.1                        }
{                           ALPHA                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                   -- WORK IN PROGRESS --                  }
{***********************************************************}

{$WARN SYMBOL_PLATFORM OFF}
{$SCOPEDENUMS ON}

unit Cod.Files;

interface
uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows, ShellAPI, Cod.Registry, Registry, ComObj,
  {$ENDIF}
  System.SysUtils, System.Variants, System.Classes, IOUtils, Math,
  Cod.MesssageConst, Cod.ArrayHelpers;

{$IFDEF MSWINDOWS}
const
  IOCTL_STORAGE_QUERY_PROPERTY =  $002D1400;

type
  {$SCOPEDENUMS OFF}
  STORAGE_QUERY_TYPE = (PropertyStandardQuery = 0, PropertyExistsQuery, PropertyMaskQuery, PropertyQueryMaxDefined);
  TStorageQueryType = STORAGE_QUERY_TYPE;

  STORAGE_PROPERTY_ID = (StorageDeviceProperty = 0, StorageAdapterProperty);
  TStoragePropertyID = STORAGE_PROPERTY_ID;

  STORAGE_PROPERTY_QUERY = packed record
    PropertyId: STORAGE_PROPERTY_ID;
    QueryType: STORAGE_QUERY_TYPE;
    AdditionalParameters: array [0..9] of AnsiChar;
  end;
  TStoragePropertyQuery = STORAGE_PROPERTY_QUERY;

  STORAGE_BUS_TYPE = (BusTypeUnknown = 0, BusTypeScsi, BusTypeAtapi, BusTypeAta, BusType1394, BusTypeSsa, BusTypeFibre,
    BusTypeUsb, BusTypeRAID, BusTypeiScsi, BusTypeSas, BusTypeSata, BusTypeMaxReserved = $7F);
  {$SCOPEDENUMS ON}
  TStorageBusType = STORAGE_BUS_TYPE;

  STORAGE_DEVICE_DESCRIPTOR = packed record
    Version: DWORD;
    Size: DWORD;
    DeviceType: Byte;
    DeviceTypeModifier: Byte;
    RemovableMedia: Boolean;
    CommandQueueing: Boolean;
    VendorIdOffset: DWORD;
    ProductIdOffset: DWORD;
    ProductRevisionOffset: DWORD;
    SerialNumberOffset: DWORD;
    BusType: DWORD;
    RawPropertiesLength: DWORD;
    RawDeviceProperties: array [0..0] of AnsiChar;
  end;
  TStorageDeviceDescriptor = STORAGE_DEVICE_DESCRIPTOR;
{$ENDIF}

type
  // Disk Item
  {$IFDEF MSWINDOWS}
  TFileAttribute = (Hidden, ReadOnly, SysFile, Compressed, Encrypted);
  TFileAttributes = set of TFileAttribute;

  TAppDataType = (Local, Roaming, LocalLow);

  TUserShellLocation = (User, AppData, AppDataLocal, Documents, Pictures,
    Desktop, Music, Videos, Network, Recent, StartMenu, Startup, Downloads,
    Programs);

  TFileIOFlag = (ConfirmMouse, Silent, NoConfirmation, AllowUndo, FilesOnly,
    SimpleProgress, NoConfirMakeDir, NoErrorUI, NoSecurityAttrib, NoRecursion,
    WantNukeWarning, NoUI);
  TFileIOFlags = set of TFileIOFlag;
  {$ENDIF}

  TSourceSize = (Bytes, Kilobytes, Megabytes, Gigbytes, Terrabytes, Petabytes);
  TFileDateTimeType = (Create, Modify, Access);

// Path
function GetSystemRoot: string;
function GetPathDepth(Path: string): integer;
function GetDisallowedFilenameCharacters: TCharArray;
function ValidateFileName(const AString: string): string;
function IsFileNameValid(const AString: string): boolean;

// Size
function SizeInString(Size: int64; Scale: TSourceSize=TSourceSize.Bytes; MaxDecimals: cardinal=2): string;
function TransposeSize(Size: int64; Source, Destination: TSourceSize; MaxDecimals: cardinal=2): string;

function GetFolderSize(FolderPath: string): int64;
function GetFolderSizeInStr(FolderPath: string): string;

function GetFileSize(FilePath: string): Int64;
function GetFileSizeInStr(FilePath: string): string;

// File Information
{$IFDEF MSWINDOWS}
function IsFileInUse(const FileName: string): Boolean;
{$ENDIF}
function GetFileDate(const FileName: string; AType: TFileDateTimeType): TDateTime;
procedure SetFileDate(const FileName: string; AType: TFileDateTimeType; NewDate: TDateTime);

// Common locations
{$IFDEF POSIX}
function GetPathInAppData(AppName: string; Company: string; Create: boolean): string; overload;
function GetPathInAppData(AppName: string; Create: boolean=true): string; overload;
{$ENDIF}
{$IFDEF MSWINDOWS}
function GetPathInAppData(AppName: string; Company: string;
  FolderType: TAppDataType; Create: boolean): string; overload;
function GetPathInAppData(AppName: string; FolderType: TAppDataType; Create: boolean=true): string; overload;
{$ENDIF}

(* NTFS *)
{$IFDEF MSWINDOWS}
function ReplaceWinPath(SrcString: string): string;

function ReplaceEnviromentVariabiles(SrcString: string): string;
function ReplaceShellLocations(SrcString: string): string;
function GetUserShellLocation(ShellLocation: TUserShellLocation): string;

function GetSystemDrive: string;

// Redeclared
procedure RecycleFile(Path: string; Flags: TFileIOFlags = []);
procedure RecycleFolder(Path: string; Flags: TFileIOFlags = []);

// Shell file management
procedure DeleteFromDisk(Path: string; Flags: TFileIOFlags = [TFileIOFlag.AllowUndo]);
procedure RenameDiskItem(Source: string; NewName: string; Flags: TFileIOFlags);
procedure MoveDiskItem(Source: string; Destination: string; Flags: TFileIOFlags = [TFileIOFlag.AllowUndo]);
procedure CopyDiskItem(Source: string; Destination: string; Flags: TFileIOFlags = [TFileIOFlag.AllowUndo, TFileIOFlag.NoConfirMakeDir]);

// Volumes
{$IFDEF MSWINDOWS}
procedure GetDiskSpace(const Disk: string; var FreeBytes, TotalBytes, TotalFreeBytes: int64);
function GetBusType(Drive: AnsiChar): TStorageBusType;
function GetUsbDrives: TArray<AnsiChar>;
{$ENDIF}

// Attributes for Files & Folders
function GetAttributes(Path: string): TFileAttributes;
procedure WriteAttributes(Path: string; Attribs: TFileAttributes; HandleCompression: boolean = true);

// Utils
function FileTimeToDateTime(Value: TFileTime): TDateTime;
function FileFlagsToIOFlags(Flags: TFileIOFlags): FILEOP_FLAGS;

// Compression
function CompressFile(const FileName:string;Compress:Boolean):integer;
function CompressFolder(const FolderName:string;Recursive, Compress:Boolean): integer;
{$ENDIF}

implementation

{$IFDEF MSWINDOWS}
uses
  Cod.Windows;
{$ENDIF}

function GetSystemRoot: string;
begin
  {$IFDEF MSWINDOWS}
  Result := ReplaceEnviromentVariabiles( '%SYSTEMROOT%' );
  {$ELSE}
  Result := '/';
  {$ENDIF}
end;

function GetPathDepth(Path: string): integer;
begin
  Path := IncludeTrailingPathDelimiter(Path);
  Result := Path.CountChar( TPath.DirectorySeparatorChar );
end;

function GetDisallowedFilenameCharacters: TCharArray;
begin
  Result := ['/', #0{$IFDEF MSWINDOWS}, '|', '<', '>', '\', '?', '"', ':', '*'{$ENDIF}];
end;

function ValidateFileName(const AString: string): string;
var
  x: integer;
begin
  Result := AString;
  const IllegalCharSet = GetDisallowedFilenameCharacters;
  for x := 1 to Length(Result) do
    if IllegalCharSet.Find(Result[x]) <> -1 then
      Result[x] := '_';
end;

function IsFileNameValid(const AString: string): boolean;
var
  x: integer;
begin
  const IllegalCharSet = GetDisallowedFilenameCharacters;
  for x := 1 to Length(AString) do
    if IllegalCharSet.Find(AString[x]) <> -1 then
      Exit(false);

  Result := true;
end;

function SizeInString(Size: int64; Scale: TSourceSize; MaxDecimals: cardinal): string;
var
  DestScale: TSourceSize;
begin
  // Process independently by source size
  const Sizing = Abs( size );
  case Sizing of
    0..1023: DestScale := Scale;
    1024..1048575: DestScale := TSourceSize(integer(Scale)+1);
    1048576..1073741823: DestScale := TSourceSize(integer(Scale)+2);
    else DestScale := TSourceSize(integer(Scale)+3);
  end;
  DestScale := TSourceSize(Min(cardinal(DestScale), cardinal(High(TSourceSize))));

  // Divide
  Result := TransposeSize(Size, Scale, DestScale, MaxDecimals);
end;

function TransposeSize(Size: int64; Source, Destination: TSourceSize; MaxDecimals: cardinal): string;
begin
  // Divide
  Result := Format( '%0.'+MaxDecimals.ToString+'f', [Size / Power( 1024, integer(Destination)-integer(Source))] ) ;

  // Measurement
  case Destination of
    TSourceSize.Bytes: Result := Concat( Result, ' ', 'B' );
    TSourceSize.Kilobytes: Result := Concat( Result, ' ', 'KB' );
    TSourceSize.Megabytes: Result := Concat( Result, ' ', 'MB' );
    TSourceSize.Gigbytes: Result := Concat( Result, ' ', 'GB' );
    TSourceSize.Terrabytes: Result := Concat( Result, ' ', 'TB' );
    TSourceSize.Petabytes: Result := Concat( Result, ' ', 'PB' );
  end;
end;

function GetFolderSize(FolderPath: string): int64;
var
  Items: TArray<string>;
  I: integer;
begin
  Result := 0;
  // Path
  FolderPath := FolderPath;

  // Search
  Items := TDirectory.GetFiles(FolderPath, '*', TSearchOption.soAllDirectories);
  for I := 0 to High(Items) do
    Inc(Result, TFile.GetSize(Items[I]));
end;

function GetFolderSizeInStr(FolderPath: string): string;
begin
  if DirectoryExists(FolderPath) then begin
    Result := SizeInString(GetFolderSize(FolderPath));
  end else
    Result := NOT_NUMBER;
end;

function GetFileSize(FilePath: string): Int64;
begin
  Result := TFile.GetSize(FilePath);
end;

function GetFileSizeInStr(FilePath: string): string;
begin
  if FileExists(FilePath) then begin
    Result := SizeInString(GetFileSize(FilePath));
  end else
    Result := NOT_NUMBER;
end;

{$IFDEF MSWINDOWS}
{$R-}
function IsFileInUse(const FileName: string): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  HFileRes := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if HFileRes = INVALID_HANDLE_VALUE then
  begin
    if GetLastError = ERROR_SHARING_VIOLATION then
      Result := True;
  end
    else
      CloseHandle(HFileRes);
end;
{$R+}
{$ENDIF}

function GetFileDate(const FileName: string; AType: TFileDateTimeType): TDateTime;
begin
  if NOT fileexists(FileName) then
    Exit(0);

  // Get by Type
  case AType of
    TFileDateTimeType.Create: Result := TFile.GetCreationTime(FileName);
    TFileDateTimeType.Modify: Result := TFile.GetLastWriteTime(FileName);
    TFileDateTimeType.Access: Result := TFile.GetLastAccessTime(FileName);
    else Result := 0;
  end;
end;

procedure SetFileDate(const FileName: string; AType: TFileDateTimeType; NewDate: TDateTime);
begin
  if NOT fileexists(FileName) then
    Exit;

  // Get by Type
  case AType of
    TFileDateTimeType.Create: TFile.SetCreationTime(FileName, NewDate);
    TFileDateTimeType.Modify: TFile.SetLastWriteTime(FileName, NewDate);
    TFileDateTimeType.Access: TFile.SetLastAccessTime(FileName, NewDate);
  end;
end;

{$IFDEF POSIX}
function GetPathInAppData(AppName: string; Company: string; Create: boolean): string; overload;
begin
  Result := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(TPath.GetHomePath)+'.config');

  // Company
  if Company <> '' then begin
    Result := IncludeTrailingPathDelimiter(Result + Company);
    if Create and (not TDirectory.Exists(Result)) then
      TDirectory.CreateDirectory(Result);
  end;

  // Get Result & Create
  Result := IncludeTrailingPathDelimiter(Result + AppName);
  if Create and (not TDirectory.Exists(Result)) then
    TDirectory.CreateDirectory(result);
end;

function GetPathInAppData(AppName: string; Create: boolean): string; overload;
begin
  Result := GetPathInAppData(AppName, ''{Default no company}, Create);
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
function GetPathInAppData(AppName: string; Company: string;
  FolderType: TAppDataType; Create: boolean): string;
begin
  if NTKernelVersion < 6 then
    // Windows Xp and below
    Result := GetSystemDrive + '\Documents and Settings\' + GetUserNameString + '\Application Data\'
      else
        // Windows Vista and above
        begin
          // Local, Roaming & Low
          case foldertype of
            TAppDataType.Local: Result := ReplaceWinPath('%LOCALAPPDATA%\');
            TAppDataType.Roaming: Result := ReplaceWinPath('%APPDATA%\');
            TAppDataType.LocalLow: Result := ReplaceWinPath('%userprofile%\AppData\LocalLow\');
          end;
        end;

  // Company
  if Company <> '' then begin
    Result := Result + Company  + '\';
    if Create and (not TDirectory.Exists(Result)) then
      TDirectory.CreateDirectory(Result);
  end;

  // Get Result & Create
  Result := Result + AppName + '\';
  if Create and (not TDirectory.Exists(Result)) then
    TDirectory.CreateDirectory(result);
end;

function GetPathInAppData(AppName: string; FolderType: TAppDataType; Create: boolean=true): string; overload;
begin
  Result := GetPathInAppData(AppName, DEFAULT_COMPANY, FolderType, Create);
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
function ReplaceWinPath(SrcString: string): string;
begin
  Result := SrcString;

  Result := ReplaceShellLocations(Result);
  Result := ReplaceEnviromentVariabiles(Result);
end;

function ReplaceEnviromentVariabiles(SrcString: string): string;
const
  ENV = '%';
var
  PStart, PEnd: integer;
  SContain, SResult: string;
  Valid: boolean;
begin
  // Initialise
  PEnd := 1;

  Result := SrcString;

  repeat
    // Get Positions
    PStart := Pos( ENV, SrcString, PEnd );
    PEnd := Pos( ENV, SrcString, PStart + 1 );

    // Validate
    Valid := (PStart > 0) and (PEnd > 0);

    // Replace
    if Valid then
      begin
        SContain := Copy( SrcString, PStart, PEnd - PStart + 1 );

        SResult := GetEnvironmentVariable( SContain.Replace(ENV, '') );

        if SResult <> '' then
          Result := StringReplace( Result, SContain, SResult, [rfIgnoreCase] );
      end;

  until not Valid;
end;

function ReplaceShellLocations(SrcString: string): string;
const
  GLOBAL_SHELL = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';
  USER_SHELL = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';

  SHELL_BEGIN = 'shell:';
var
  R: TRegistry;

  Items_Global,
  Items_User: TStringList;
  I: Integer;

  IName,
  IValue: string;
begin
  Result := SrcString;

  // No Val
  if Pos(SHELL_BEGIN, Result) = 0 then
    Exit;

  // Create
  R := TRegistry.Create( KEY_READ );

  Items_Global := TStringList.Create;
  Items_User := TStringList.Create;
  try
    // Read possibile values for global
    R.RootKey := HKEY_LOCAL_MACHINE;
    R.OpenKeyReadOnly( GLOBAL_SHELL );
    R.GetValueNames(Items_Global);

    // Replace Items
    for I := 0 to Items_Global.Count - 1 do
      begin
        IName := AnsiLowerCase(Items_Global[I]);

        if Pos(SHELL_BEGIN + IName, AnsiLowerCase(Result)) <> 0 then
          begin
            // Read Value
            IValue := R.ReadString( IName );

            Result := StringReplace( Result, SHELL_BEGIN + IName, IValue, [rfIgnoreCase, rfReplaceAll] );
          end;
      end;

    // Read possible values for user
    R.RootKey := HKEY_CURRENT_USER;
    R.OpenKeyReadOnly( USER_SHELL );
    R.GetValueNames(Items_User);

    // Replace Items
    for I := 0 to Items_User.Count - 1 do
      begin
        IName := AnsiLowerCase(Items_User[I]);

        if Pos(SHELL_BEGIN + IName, AnsiLowerCase(Result)) <> 0 then
          begin
            // Read Value
            IValue := R.ReadString( IName );

            Result := StringReplace( Result, SHELL_BEGIN + IName, IValue, [rfIgnoreCase, rfReplaceAll] );
          end;
      end;

  finally
    Items_Global.Free;
    Items_User.Free;

    R.Free;
  end;
end;

function GetUserShellLocation(ShellLocation: TUserShellLocation): string;
var
  RegString, RegValue: string;
  Registry: TWinRegistry;
begin
  case ShellLocation of
    TUserShellLocation.User: Exit( ReplaceWinPath('%USERPROFILE%') );
    TUserShellLocation.AppData: RegValue := 'AppData';
    TUserShellLocation.AppDataLocal: RegValue := 'Local AppData';
    TUserShellLocation.Documents: RegValue := 'Personal';
    TUserShellLocation.Pictures: RegValue := 'My Pictures';
    TUserShellLocation.Desktop: RegValue := 'Desktop';
    TUserShellLocation.Music: RegValue := 'My Music';
    TUserShellLocation.Videos: RegValue := 'My Video';
    TUserShellLocation.Network: RegValue := 'NetHood';
    TUserShellLocation.Recent: RegValue := 'Recent';
    TUserShellLocation.StartMenu: RegValue := 'Start Menu';
    TUserShellLocation.Programs: RegValue := 'Programs';
    TUserShellLocation.Startup: RegValue := 'Startup';
    TUserShellLocation.Downloads: RegValue := '{374DE290-123F-4565-9164-39C4925E467B}';
  end;

  Registry := TWinRegistry.Create;
  try
    RegString := Registry.GetStringValue('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders', RegValue);
  finally
    Registry.Free;
  end;

  Result := ReplaceWinPath(RegString);
end;

function GetSystemDrive: string;
begin
  Result := ReplaceEnviromentVariabiles( '%SYSTEMDRIVE%' );
end;

procedure RecycleFile(Path: string; Flags: TFileIOFlags);
begin
  Flags := Flags + [TFileIOFlag.AllowUndo];
  DeleteFromDisk( Path, Flags );
end;

procedure RecycleFolder(Path: string; Flags: TFileIOFlags);
begin
  Flags := Flags + [TFileIOFlag.AllowUndo];
  DeleteFromDisk( Path, Flags );
end;

procedure DeleteFromDisk(Path: string; Flags: TFileIOFlags);
var
  FileStructure: TSHFileOpStruct;
begin
  with FileStructure do
  begin
    Wnd := 0;
    wFunc := FO_DELETE;
    pFrom := PChar( ReplaceWinPath(Path) + #0 );

    // Flags
    fFlags := FileFlagsToIOFlags( Flags );
  end;
  try
    SHFileOperation(FileStructure);
  except
    on EAccessViolation do
      RaiseLastOSError;
  end;
end;

procedure RenameDiskItem(Source: string; NewName: string; Flags: TFileIOFlags);
var
  FileStructure: TSHFileOpStruct;
begin
  with FileStructure do
  begin
    Wnd := 0;
    wFunc := FO_RENAME;
    pFrom := PChar( Source );
    pTo := PChar( IncludeTrailingPathDelimiter( ExtractFileDir( Source ) ) + NewName );

    // Flags
    fFlags := FileFlagsToIOFlags( Flags );
  end;
  try
    SHFileOperation(FileStructure);
  except
    on EAccessViolation do
      RaiseLastOSError;
  end;
end;

procedure MoveDiskItem(Source: string; Destination: string; Flags: TFileIOFlags);
var
  FileStructure: TSHFileOpStruct;
begin
  with FileStructure do
  begin
    Wnd := 0;
    wFunc := FO_MOVE;
    pFrom := PChar( ExcludeTrailingPathDelimiter( ReplaceWinPath(Source) ) );
    { ExcludeTrailingPathDelimiter is required, as if a / is present the function
    will not work }
    pTo := PChar( ReplaceWinPath(Destination) );

    // Flags
    fFlags := FileFlagsToIOFlags( Flags );
  end;
  try
    SHFileOperation(FileStructure);
  except
    on EAccessViolation do
      RaiseLastOSError;
  end;
end;

procedure CopyDiskItem(Source: string; Destination: string; Flags: TFileIOFlags);
var
  FileStructure: TSHFileOpStruct;
begin
  with FileStructure do
  begin
    Wnd := 0;
    wFunc := FO_COPY;
    pFrom := PChar( ExcludeTrailingPathDelimiter( ReplaceWinPath(Source) ) );
    pTo := PChar( ReplaceWinPath(Destination) ); { The reason this PChar does not have
      ExcludeTrailingPathDelimiter is because if the Destination has a final \ it means
      to Copy the folder as it is and to become a subfolder of the Destionation, otherwise
      It will override the folder if the \ is not present. }

    // Flags
    fFlags := FileFlagsToIOFlags( Flags );
  end;
  try
    SHFileOperation(FileStructure);
  except
    on EAccessViolation do
      RaiseLastOSError;
  end;
end;

{$IFDEF MSWINDOWS}
procedure GetDiskSpace(const Disk: string; var FreeBytes, TotalBytes, TotalFreeBytes: int64);
var
  RootPath: PChar;
  AFreeBytes, ATotalBytes, ATotalFreeBytes: ULARGE_INTEGER;
begin
  RootPath := PChar(Disk);
  if not SHGetDiskFreeSpace(RootPath, AFreeBytes, ATotalBytes, ATotalFreeBytes) then
    RaiseLastOSError;

  FreeBytes := AFreeBytes.QuadPart;
  TotalBytes := ATotalBytes.QuadPart;
  TotalFreeBytes := ATotalFreeBytes.QuadPart;
end;

function GetBusType(Drive: AnsiChar): TStorageBusType;
var
  H: THandle;
  Query: TStoragePropertyQuery;
  dwBytesReturned: DWORD;
  Buffer: array [0..1023] of Byte;
  sdd: TStorageDeviceDescriptor absolute Buffer;
  OldMode: UINT;
begin
  Result := BusTypeUnknown;

  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    H := CreateFile(PChar(Format('\\.\%s:', [string(Drive)])), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
      OPEN_EXISTING, 0, 0);
    if H <> INVALID_HANDLE_VALUE then
    begin
      try
        dwBytesReturned := 0;
        FillChar(Query, SizeOf(Query), 0);
        FillChar(Buffer, SizeOf(Buffer), 0);
        sdd.Size := SizeOf(Buffer);
        Query.PropertyId := StorageDeviceProperty;
        Query.QueryType := PropertyStandardQuery;
        if DeviceIoControl(H, IOCTL_STORAGE_QUERY_PROPERTY, @Query, SizeOf(Query), @Buffer, SizeOf(Buffer), dwBytesReturned, nil) then
          Result := STORAGE_BUS_TYPE(sdd.BusType);
      finally
        CloseHandle(H);
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;


function GetUsbDrives: TArray<AnsiChar>;
var
  DriveBits: set of 0..25;
  I: Integer;
  Drive: AnsiChar;
begin
  Cardinal(DriveBits) := GetLogicalDrives;

  for I := 0 to 25 do
    if I in DriveBits then
    begin
      Drive := AnsiChar(Chr(Ord('a') + I));
      if GetBusType(Drive) = BusTypeUsb then
        TArrayUtils<AnsiChar>.AddValue(Drive, Result);
    end;
end;
{$ENDIF}

function GetAttributes(Path: string): TFileAttributes;
var
  Attrs: integer;
begin
  Attrs := FileGetAttr(Path);

  Result := [];

  if (Attrs and faHidden) <> 0 then
    Result := Result + [TFileAttribute.Hidden];

  if (Attrs and faReadOnly) <> 0 then
    Result := Result + [TFileAttribute.ReadOnly];

  if (Attrs and faSysFile) <> 0 then
    Result := Result + [TFileAttribute.SysFile];

  if (Attrs and faCompressed) <> 0 then
    Result := Result + [TFileAttribute.Compressed];

  if (Attrs and faEncrypted) <> 0 then
    Result := Result + [TFileAttribute.Encrypted];
end;

procedure WriteAttributes(Path: string; Attribs: TFileAttributes;
          HandleCompression: boolean);
var
  Attrs, WinAtr, I: integer;
  Present, Needed: boolean;

  DoWith: TFileAttribute;
begin
  for I := 0 to 4 do
    begin
      // Select Attrib
      DoWith := TFileAttribute(I);

      WinAtr := 0;
      case DoWith of
        TFileAttribute.ReadOnly: WinAtr := faReadOnly;
        TFileAttribute.Hidden: WinAtr := faHidden;
        TFileAttribute.SysFile: WinAtr := faSysFile;
        TFileAttribute.Compressed: WinAtr := faCompressed;
        TFileAttribute.Encrypted: WinAtr := faEncrypted;
      end;

      // Automatic Handeling
      if HandleCompression and (DoWith = TFileAttribute.Compressed) then
        begin
          if TFile.Exists(Path) then
            CompressFile(Path, DoWith in Attribs)
          else
            CompressFolder(Path, true, DoWith in Attribs);

          Break;
        end;

      // Change Attrib
      Attrs := FileGetAttr(Path);
      Present := (Attrs and WinAtr) <> 0;

      Needed := DoWith in Attribs;

      if Present <> Needed then
        if Present then
          FileSetAttr(Path, Attrs and (not WinAtr))
        else
          FileSetAttr(Path, Attrs or WinAtr);
    end;
end;

function FileTimeToDateTime(Value: TFileTime): TDateTime;
var
  Tmp: Integer;
begin
  FileTimeToDosDateTime(Value, LongRec(Tmp).Hi,
    LongRec(Tmp).Lo);
  Result := FileDateToDateTime(Tmp);
end;

function FileFlagsToIOFlags(Flags: TFileIOFlags): FILEOP_FLAGS;
begin
  // Converts set TFileIOFlags flags to Bit operation
  Result := 0;
  if TFileIOFlag.ConfirmMouse in Flags then
    Result := Result or FOF_CONFIRMMOUSE;
  if TFileIOFlag.Silent in Flags then
    Result := Result or FOF_SILENT;
  if TFileIOFlag.NoConfirmation in Flags then
    Result := Result or FOF_NOCONFIRMATION;
  if TFileIOFlag.AllowUndo in Flags then
    Result := Result or FOF_ALLOWUNDO;
  if TFileIOFlag.FilesOnly in Flags  then
    Result := Result or FOF_FILESONLY;
  if TFileIOFlag.SimpleProgress in Flags  then
    Result := Result or FOF_SIMPLEPROGRESS;
  if TFileIOFlag.NoConfirMakeDir in Flags  then
    Result := Result or FOF_NOCONFIRMMKDIR;
  if TFileIOFlag.NoErrorUI in Flags  then
    Result := Result or FOF_NOERRORUI;
  if TFileIOFlag.NoSecurityAttrib in Flags  then
    Result := Result or FOF_NOCOPYSECURITYATTRIBS;
  if TFileIOFlag.NoRecursion in Flags  then
    Result := Result or FOF_NORECURSION;
  if TFileIOFlag.WantNukeWarning in Flags  then
    Result := Result or FOF_WANTNUKEWARNING;
  if TFileIOFlag.NoUI in Flags  then
    Result := Result or FOF_NO_UI;
end;

function CompressFile(const FileName:string;Compress:Boolean):integer;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObject   : OLEVariant;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  FWbemObject   := FWMIService.Get(Format('CIM_DataFile.Name="%s"',[StringReplace(FileName,'\','\\',[rfReplaceAll])]));
  if Compress then
    Result:=FWbemObject.Compress()
  else
    Result:=FWbemObject.UnCompress();
end;

function CompressFolder(const FolderName:string;Recursive, Compress:Boolean):integer;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObject   : OLEVariant;
  StopFileName  : OLEVariant;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  FWbemObject   := FWMIService.Get(Format('CIM_Directory.Name="%s"',[StringReplace(FolderName,'\','\\',[rfReplaceAll])]));
  if Compress then
    if Recursive then
     Result:=FWbemObject.CompressEx(StopFileName, Null, Recursive)
    else
     Result:=FWbemObject.Compress()
  else
    if Recursive then
     Result:=FWbemObject.UnCompressEx(StopFileName, Null, Recursive)
    else
     Result:=FWbemObject.UnCompress();
end;
{$ENDIF}

end.
