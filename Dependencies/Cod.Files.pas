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

unit Cod.Files;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, IOUtils, ShellAPI, Vcl.Forms, Cod.WinRegister, ComObj;

  type
    // Disk Item
    CDiskItemType = (dskFile, dskDirectory);

    TFileAttribute = (atrHidden, atrReadOnly, atrSysFile, atrCompressed, atrEncrypted);
    TFileAttributes = set of TFileAttribute;

    TAppDataType = (adtLocal, adtRoaming, adtLocalLow);

    TUserShellLocation = (shlUser, shlAppData, shlAppDataLocal, shlDocuments,
                      shlPictures, shlDesktop, shlMusic, shlVideos,
                      shlNetwork, shlRecent, shlStartMenu, shlStartup,
                      shlDownloads, shlPrograms);

    TFileIOFlag = (fioConfirmMouse, fioSilent, fioNoConfirmation, fioAllowUndo,
                   fioFilesOnly, fioSimpleProgress, fioNoConfirMakeDir, fioNoErrorUI,
                   fioNoSecurityAttrib, fioNoRecursion, fioWantNukeWarning, fioNoUI);
    TFileIOFlags = set of TFileIOFlag;

    // File Item
    CFileItem = class
    public
      Filepath,
      Fileonlyname,
      Extention: string;

      Size: int64;

      Attribute: Cardinal;

      AccessDate,
      WriteDate,
      CreationDate: TDateTime;

      function Exists: boolean;
      procedure Load(filename: string; restrictinfo: boolean = false);

    private

    end;

    // Folder Item
    CFolderItem = class
    public
      Path,
      FolderOnlyName: string;

      Size: int64;

      Attribute: Cardinal;

      AccessDate,
      WriteDate,
      CreationDate: TDateTime;

      function Exists: boolean;
      procedure Load(foldername: string; restrictinfo: boolean = false);
    end;

    //Disk Item
    CDiskItem = class
      constructor Create;
      destructor Destroy; override;
    public
      ItemType: CDiskItemType;

      Path: string;
      Size: int64;

      FileItem: CFileItem;
      FolderItem: CFolderItem;

      procedure TrimTrailingPathDelimiter;
      function Exists: boolean;
      procedure Load(pathtoitem: string; restrictinfo: boolean = false);
    end;


  // System Utilities
  function FileTimeToDateTime(Value: TFileTime): TDateTime;
  function ShellPath(path: string): string;

  // File Folder IO
  function FileIoFlags(Flags: TFileIOFlags): FILEOP_FLAGS;

  (* Path *)
  function ReplaceWinPath(SrcString: string): string;
  function GetUserShellLocation(ShellLocation: TUserShellLocation): string;
  function GetPathInAppData(appname: string; codsoft: boolean = true;
                            create: boolean = true;
                            foldertype: TAppDataType = adtLocal): string;
  function FileExtension(FileName: string; includeperiod: boolean = true): string;

  (* Redeclared *)
  procedure RecycleFile(Path: string; Flags: TFileIOFlags = [fioAllowUndo]);
  procedure RecycleFolder(Path: string; Flags: TFileIOFlags = [fioAllowUndo]);

  (* Disk IO *)
  procedure DeleteFromDisk(Path: string; Flags: TFileIOFlags = [fioAllowUndo]);
  procedure RenameDiskItem(Source: string; NewName: string; Flags: TFileIOFlags);
  procedure MoveDiskItem(Source: string; Destination: string; Flags: TFileIOFlags = [fioAllowUndo]);
  procedure CopyDiskItem(Source: string; Destination: string; Flags: TFileIOFlags = [fioAllowUndo, fioNoConfirMakeDir]);

  (* Size *)
  function SizeInString(size: int64): string;

  function GetFolderSize(Path: string): int64;
  function GetFolderSizeInStr(path: string): string;

  function GetFileSize(FileName: WideString): Int64;
  function GetFileSizeInStr(FileName: WideString): string;

  (* Attributes *)
  function GetAttributes(Path: string): TFileAttributes;
  procedure WriteAttributes(Path: string; Attribs: TFileAttributes; HandleCompression: boolean = true);

  (* NTFT Compression *)
  function  CompressItem(const Path:string;Compress:Boolean; FolderRecursive: boolean = true):integer;
  function  CompressFile(const FileName:string;Compress:Boolean):integer;
  function  CompressFolder(const FolderName:string;Recursive, Compress:Boolean):integer;

  // Utilities
  function GetNTVersion: single;
  function GetUserNameString: string;

implementation

function FileIoFlags(Flags: TFileIOFlags): FILEOP_FLAGS;
begin
  // Converts set TFileIOFlags flags to Bit operation
  Result := 0;
  if fioConfirmMouse in Flags then
    Result := Result or FOF_CONFIRMMOUSE;
  if fioSilent in Flags then
    Result := Result or FOF_SILENT;
  if fioNoConfirmation in Flags then
    Result := Result or FOF_NOCONFIRMATION;
  if fioAllowUndo in Flags then
    Result := Result or FOF_ALLOWUNDO;
  if fioFilesOnly in Flags  then
    Result := Result or FOF_FILESONLY;
  if fioSimpleProgress in Flags  then
    Result := Result or FOF_SIMPLEPROGRESS;
  if fioNoConfirMakeDir in Flags  then
    Result := Result or FOF_NOCONFIRMMKDIR;
  if fioNoErrorUI in Flags  then
    Result := Result or FOF_NOERRORUI;
  if fioNoSecurityAttrib in Flags  then
    Result := Result or FOF_NOCOPYSECURITYATTRIBS;
  if fioNoRecursion in Flags  then
    Result := Result or FOF_NORECURSION;
  if fioWantNukeWarning in Flags  then
    Result := Result or FOF_WANTNUKEWARNING;
  if fioNoUI in Flags  then
    Result := Result or FOF_NO_UI;
end;

procedure RecycleFile(Path: string; Flags: TFileIOFlags);
begin
  DeleteFromDisk( Path, Flags );
end;

procedure RecycleFolder(Path: string; Flags: TFileIOFlags);
begin
  DeleteFromDisk( Path, Flags );
end;

procedure DeleteFromDisk(Path: string; Flags: TFileIOFlags);
var
  FileStructure: TSHFileOpStruct;
begin
  with FileStructure do
  begin
    Wnd := Application.Handle;
    wFunc := FO_DELETE;
    pFrom := PChar( ReplaceWinPath(Path) );

    // Flags
    fFlags := FileIOFlags( Flags );
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
    Wnd := Application.Handle;
    wFunc := FO_RENAME;
    pFrom := PChar( Source );
    pTo := PChar( IncludeTrailingPathDelimiter( ExtractFileDir( Source ) ) + NewName );

    // Flags
    fFlags := FileIOFlags( Flags );
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
    Wnd := Application.Handle;
    wFunc := FO_MOVE;
    pFrom := PChar( ExcludeTrailingPathDelimiter( ReplaceWinPath(Source) ) );
    { ExcludeTrailingPathDelimiter is required, as if a / is present the function
    will not work }
    pTo := PChar( ReplaceWinPath(Destination) );

    // Flags
    fFlags := FileIOFlags( Flags );
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
    Wnd := Application.Handle;
    wFunc := FO_COPY;
    pFrom := PChar( ExcludeTrailingPathDelimiter( ReplaceWinPath(Source) ) );
    pTo := PChar( ReplaceWinPath(Destination) ); { The reason this PChar does not have
      ExcludeTrailingPathDelimiter is because if the Destination has a final \ it means
      to Copy the folder as it is and to become a subfolder of the Destionation, otherwise
      It will override the folder if the \ is not present. }

    // Flags
    fFlags := FileIOFlags( Flags );
  end;
  try
    SHFileOperation(FileStructure);
  except
    on EAccessViolation do
      RaiseLastOSError;
  end;
end;

function ReplaceWinPath(SrcString: string): string;
var
  RFlags: TReplaceFlags;
begin
  RFlags := [rfReplaceAll, rfIgnoreCase];

  Result := SrcString;

  // Remove "
  Result := Result.Replace('"', '');

  if GetNTVersion < 6 then
    begin
      // Windows Xp, 9X and below
      Result := StringReplace(Result, '%AppData%', 'C:\Documents and Settings\' + GetUserNameString + '\AppData', RFlags);
      Result := StringReplace(Result, '%LocalAppData%', 'C:\Documents and Settings\' + GetUserNameString + '\AppData', RFlags);
      Result := StringReplace(Result, '%Public%', 'C:\Documents and Settings\All Users', RFlags);
      Result := StringReplace(Result, '%Temp%', 'C:\Documents and Settings\' + GetUserNameString + '\Local Settings\Temp', RFlags);
      Result := StringReplace(Result, '%Tmp%', 'C:\Documents and Settings\' + GetUserNameString + '\Local Settings\Temp', RFlags);
      Result := StringReplace(Result, '%UserProfile%', 'C:\Documents and Settings\' + GetUserNameString, RFlags);
      Result := StringReplace(Result, '%HomePath%', 'C:\Documents and Settings\' + GetUserNameString, RFlags);
    end
  else
    begin
      // Windows Vista 2008 and above
      Result := StringReplace(Result, '%AppData%', 'C:\Users' + GetUserNameString + '\AppData\Roaming', RFlags);
      Result := StringReplace(Result, '%LocalAppData%', 'C:\Users\' + GetUserNameString + '\AppData\Local', RFlags);
      Result := StringReplace(Result, '%Public%', 'C:\Users\Public', RFlags);
      Result := StringReplace(Result, '%Temp%', 'C:\Users\' + GetUserNameString + '\AppData\Local\Temp', RFlags);
      Result := StringReplace(Result, '%Tmp%', 'C:\Users\' + GetUserNameString + '\AppData\Local\Temp', RFlags);
      Result := StringReplace(Result, '%HomePath%', 'C:\Users\' + GetUserNameString + '\', RFlags);
      Result := StringReplace(Result, '%UserProfile%', 'C:\Users\' + GetUserNameString + '\', RFlags);
    end;

  Result := StringReplace(Result, '%AllUsersProfile%', 'C:\ProgramData', RFlags);
  Result := StringReplace(Result, '%CommonProgramFiles%', 'C:\Program Files\Common Files', RFlags);
  Result := StringReplace(Result, '%CommonProgramFiles(x86)%', 'C:\Program Files (x86)\Common Files', RFlags);
  Result := StringReplace(Result, '%HomeDrive%', 'C:\', RFlags);
  Result := StringReplace(Result, '%ProgramData%', 'C:\ProgramData', RFlags);
  Result := StringReplace(Result, '%ProgramFiles%', 'C:\Program Files', RFlags);
  Result := StringReplace(Result, '%ProgramFiles(x86)%', 'C:\Program Files (x86)', RFlags);
  Result := StringReplace(Result, '%SystemDrive%', 'C:', RFlags);
  Result := StringReplace(Result, '%SystemRoot%', 'C:\Windows', RFlags);
  Result := StringReplace(Result, '%OneDrive%', 'C:\Users\' + GetUserNameString + '\Onedrive\', RFlags);
  Result := StringReplace(Result, '%OneDriveConsumer%', 'C:\Users\' + GetUserNameString + '\Onedrive\', RFlags);

  // Custom additions
  Result := StringReplace(Result, '%WindowsApps%', 'C:\Program Files\WindowsApps', RFlags);
  Result := StringReplace(Result, '%UserWindowsApps%', 'C:\Users\' + GetUserNameString + '\AppData\Local\Microsoft\WindowsApps\', RFlags);
end;

function GetAttributes(Path: string): TFileAttributes;
var
  Attrs: integer;
begin
  Attrs := FileGetAttr(Path);

  Result := [];

  if (Attrs and faHidden) <> 0 then
    Result := Result + [atrHidden];

  if (Attrs and faReadOnly) <> 0 then
    Result := Result + [atrReadOnly];

  if (Attrs and faSysFile) <> 0 then
    Result := Result + [atrSysFile];

  if (Attrs and faCompressed) <> 0 then
    Result := Result + [atrCompressed];

  if (Attrs and faEncrypted) <> 0 then
    Result := Result + [atrEncrypted];
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
        atrReadOnly: WinAtr := faReadOnly;
        atrHidden: WinAtr := faHidden;
        atrSysFile: WinAtr := faSysFile;
        atrCompressed: WinAtr := faCompressed;
        atrEncrypted: WinAtr := faEncrypted;
      end;

      // Automatic Handeling
      if HandleCompression and (DoWith = atrCompressed) then
        begin
          CompressItem(Path, DoWith in Attribs);

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


function CompressItem(const Path:string;Compress:Boolean; FolderRecursive: boolean):integer;
begin
  Result := 0;
  if TFile.Exists(Path) then
    CompressFile(Path, Compress)
  else
    CompressFolder(Path, FolderRecursive, Compress);
end;

function  CompressFile(const FileName:string;Compress:Boolean):integer;
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

function  CompressFolder(const FolderName:string;Recursive, Compress:Boolean):integer;
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

function GetNTVersion: single;
begin
  Result := Win32MajorVersion + Win32MinorVersion / 10;
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

function GetPathInAppData(appname: string; codsoft,
  create: boolean; foldertype: TAppDataType): string;
begin
  if GetNTVersion < 6 then
    // Windows Xp and below
    result := 'C:\Documents and Settings\' + GetUserNameString + '\Application Data\'
      else
        begin
          // Windows Vista and above
          result := 'C:\Users\' + GetUserNameString + '\AppData\';

          // Local, Roaming & Low
          case foldertype of
            adtLocal: result := result + 'Local\';
            adtRoaming: result := result + 'Roaming\';
            adtLocalLow: result := result + 'LocalLow\';
          end;
        end;

  // Codrut Software
  if codsoft then begin
    result := result + 'CodrutSoftware\';
    if create and (not TDirectory.Exists(result)) then TDirectory.CreateDirectory(result);
  end;

  // Get Result & Create
  result := result + appname + '\';
  if create and (not TDirectory.Exists(result)) then
    TDirectory.CreateDirectory(result);
end;

function FileExtension(FileName: string; includeperiod: boolean): string;
begin
  Result := ExtractFileExt( FileName );

  if not includeperiod then
    Result := Copy( Result, 2, Length( Result ) );
end;

function GetFolderSize( Path: string ): int64;
var
 tsr: TSearchRec;
begin
  result := 0;
  // Path
  Path := ReplaceWinPath( IncludeTrailingPathDelimiter ( path ) );

  // Search
  if FindFirst ( path + '*', faAnyFile, tsr ) = 0 then begin
    repeat
      if ( tsr.attr and faDirectory ) > 0 then
        begin
          if ( tsr.name <> '.' ) and ( tsr.name <> '..' ) then
            inc ( result, GetFolderSize ( path + tsr.name ) );
        end
      else
        begin
          inc ( result, tsr.size );
        end;
    until FindNext ( tsr ) <> 0;
  FindClose ( tsr );
 end;
end;

function GetFolderSizeInStr(path: string): string;
begin
  if DirectoryExists(path) then begin
    Result := SizeInString(GetFolderSize(path));
  end else
    Result := 'NaN';
end;

function SizeInString(size: int64): string;
begin
  // Calculate in MB not Mb
  case size of
    0..1023: Result := inttostr(size) + ' B'; // B
    1024..1048575: Result := inttostr(trunc(size/1024)) + ' KB'; // KB
    1048576..1073741823: Result := inttostr(trunc(size/1048576)) + ' MB'; // BM
  end;
  if size > 1073741824 then
    Result := floattostr((trunc((size/1073741824)*10))/10) + ' GB'; // GB
  if size < 0 then
    Result := 'Err';
end;

function GetFileSize(FileName: WideString): Int64;
var
  sr : TSearchRec;
begin
  if FindFirst(fileName, faAnyFile, sr ) = 0 then
    result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
  else
    result := -1;
  FindClose(sr);
end;

function GetFileSizeInStr(FileName: WideString): string;
begin
  if FileExists(fileName) then begin
    Result := SizeInString(GetFileSize(filename));
  end else
    Result := 'NaN';
end;

{ CFileItem }

function StrCopy(mainstring: string; frompos, topos: integer): string;
begin
  if frompos < 1 then
    frompos := 1;
  Result := Copy(mainstring, frompos, topos - frompos + 1);
end;

function FileTimeToDateTime(Value: TFileTime): TDateTime;
var
  Tmp: Integer;
begin
  FileTimeToDosDateTime(Value, LongRec(Tmp).Hi,
    LongRec(Tmp).Lo);
  Result := FileDateToDateTime(Tmp);
end;

function ShellPath(path: string): string;
begin
  Path := Path.Replace(Char(39), '"');

  Result := path;
end;

function CFileItem.Exists: boolean;
begin
  if TFile.Exists(Filepath) then
    Result := true
  else
    Result := false;
end;

procedure CFileItem.Load(filename: string; restrictinfo: boolean);
var
  attributes: TWin32FileAttributeData;
begin
  filename := ShellPath(filename);
  if NOT fileexists(filename) then
    Exit;

  filepath := filename;

  fileonlyname := ExtractFileName(filename);

  extention := ExtractFileExt(fileonlyname);

  if NOT restrictinfo then
  begin
    if NOT GetFileAttributesEx(PWideChar(filename), GetFileExInfoStandard, @attributes) then
      EXIT;

    Size := Int64(attributes.nFileSizeLow) or Int64(attributes.nFileSizeHigh shl 32);

    Attribute := attributes.dwFileAttributes;

    WriteDate := FileTimeToDateTime(attributes.ftLastWriteTime);
    AccessDate := FileTimeToDateTime(attributes.ftLastAccessTime);
    CreationDate := FileTimeToDateTime(attributes.ftCreationTime);
  end;
end;

{ CFolderItem }

function CFolderItem.Exists: boolean;
begin
  if TDirectory.Exists(Path) then
    Result := true
  else
    Result := false;
end;

procedure CFolderItem.Load(foldername: string; restrictinfo: boolean);
begin
  foldername := ShellPath(foldername);
  if NOT directoryexists(foldername) then
    Exit;

  Path := foldername;

  //FolderOnlyName := StrCopy(foldername, foldername.LastIndexOf('\') + 2, Length(foldername) );
  FolderOnlyName := ExtractFileName( ExcludeTrailingPathDelimiter(foldername) );



  if NOT restrictinfo then
  begin
    Size := GetFolderSize(foldername);

    WriteDate := TDirectory.GetLastWriteTime(foldername);
    AccessDate := TDirectory.GetLastAccessTime(foldername);
    CreationDate := TDirectory.GetCreationTime(foldername);
  end;
end;

function GetUserShellLocation(ShellLocation: TUserShellLocation): string;
var
  RegString, RegValue: string;
begin
  case ShellLocation of
    shlUser: Exit( ReplaceWinPath('%USERPROFILE%') );
    shlAppData: RegValue := 'AppData';
    shlAppDataLocal: RegValue := 'Local AppData';
    shlDocuments: RegValue := 'Personal';
    shlPictures: RegValue := 'My Pictures';
    shlDesktop: RegValue := 'Desktop';
    shlMusic: RegValue := 'My Music';
    shlVideos: RegValue := 'My Video';
    shlNetwork: RegValue := 'NetHood';
    shlRecent: RegValue := 'Recent';
    shlStartMenu: RegValue := 'Start Menu';
    shlPrograms: RegValue := 'Programs';
    shlStartup: RegValue := 'Startup';
    shlDownloads: RegValue := '{374DE290-123F-4565-9164-39C4925E467B}';
  end;

  RegString := WinReg.GetStringValue(RegValue, 'Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders', HKEY_CURRENT_USER, false);

  Result := ReplaceWinPath(RegString);
end;

{ CDiskItem }

constructor CDiskItem.Create;
begin
  FileItem := CFileItem.Create;
  FolderItem := CFolderItem.Create;
end;

destructor CDiskItem.Destroy;
begin
  FreeAndNil(FileItem);
  FreeAndNil(FolderItem);
  inherited;
end;

function CDiskItem.Exists: boolean;
begin
  if ItemType = dskFile then
    Result := FileItem.Exists
  else
    Result := FolderItem.Exists;
end;

procedure CDiskItem.Load(pathtoitem: string; restrictinfo: boolean);
begin
  if fileexists(pathtoitem) then
  begin
    FileItem.Load(pathtoitem, restrictinfo);

    Size := FileItem.Size;
    ItemType := dskFile;
  end
  else
  if directoryexists(pathtoitem) then
  begin
    FolderItem.Load(pathtoitem, restrictinfo);

    Size := FolderItem.Size;
    ItemType := dskDirectory;
  end;

  Path := pathtoitem;
end;

procedure CDiskItem.TrimTrailingPathDelimiter;
begin
  Path := ExcludeTrailingPathDelimiter(Path);
  FolderItem.Path := ExcludeTrailingPathDelimiter(FolderItem.Path);
  FileItem.Filepath := ExcludeTrailingPathDelimiter(FileItem.Filepath);
end;

end.
