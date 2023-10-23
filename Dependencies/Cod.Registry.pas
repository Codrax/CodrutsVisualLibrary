{***********************************************************}
{                    Codruts Win Register                   }
{                                                           }
{                         version 1.1                       }
{                           RELEASE                         }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                   -- WORK IN PROGRESS --                  }
{***********************************************************}


unit Cod.Registry;
{$SCOPEDENUMS ON}

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Registry, Vcl.Dialogs, Cod.ArrayHelpers, Cod.MesssageConst;

  type
    TRegistryMode = (Unloaded, Windows32, Windows64, Automatic);
    TRegistryError = (None, AccessDenied, KeyNoExist, ReadError);
    TRegistryErrorKind = (Disabled, Receive, OperatingSystem);
    TRegistryNeed = (Read, Write, Complete);

    TRegistryOnError = procedure(AError: TRegistryError) of object;

    // Moved Helper from Cod.VarHelpers for FMX compatability
    TRegHelper = class helper for TRegistry
      procedure RenameKey(const OldName, NewName: string);
      function CloneKey(const KeyName: string): string;

      function ReadCardinal(const Name: string): Cardinal;

      procedure MoveKeyTo(const OldName, NewKeyPath: string; Delete: Boolean);
    end;

    // Predefine
    TWinRegistry = class;

    // TQuickReg Class
    TQuickReg = class
    public
      class function CreateKey(KeyLocation: string): boolean;
      class function KeyExists(KeyLocation: string): boolean;
      class function DeleteKey(KeyLocation: string): boolean;
      class function RenameKey(KeyLocation, NewName: string): boolean;

      class function GetStringValue(KeyLocation, ValueName: string): string;
      class function GetIntValue(KeyLocation, ValueName: string): integer;

      class function GetValueExists(KeyLocation, ValueName: string): boolean;
      class function DeleteValue(KeyLocation, ValueName: string): boolean;
    end;

    // TWinRegistry Class
    TWinRegistry = class(TObject)
    private
      // Vars
      FLastError: TRegistryError;
      FRegistry: TRegistry;
      FRegistryMode: TRegistryMode;
      FHive, FDefaultHive: HKEY;
      FAutoHive: boolean;
      FOnError: TRegistryOnError;
      FErrorKind: TRegistryErrorKind;

      // Registry Edit
      procedure CreateReg(AType: TRegistryNeed; APosition: string = '');

      function GetPathEnd(Path: string): string;
      function GetPathItem(Path: string): string;
      procedure ApplyPath(var Path: string);
      procedure RemovePathLevels(var Path: string; Levels: integer);

      // Error
      procedure RaiseError(AError: TRegistryError);

      // Registry Mode
      function ApplyRegMode(mode: Cardinal = KEY_ALL_ACCESS): Cardinal;

      // Imported Utils
      function IsWOW64Emulated: Boolean;
      function IsWow64Executable: Boolean;
    procedure SetManualHive(const Value: HKEY);

    public
      // Create
      constructor Create;
      destructor Destroy; override;

      // Registry Mode
      procedure SetNewRegistryMode(AMode: TRegistryMode);

      // Key Functions
      function CreateKey(KeyLocation: string): boolean;
      function KeyExists(KeyLocation: string): boolean;
      function DeleteKey(KeyLocation: string): boolean;
      function CloneKey(KeyLocation: string): string;
      function RenameKey(KeyLocation, NewName: string): boolean;
      function MoveKey(KeyLocation, NewLocation: string; AlsoDelete: boolean = true): boolean;
      function CopyKey(KeyLocation, NewLocation: string): boolean;

      function GetKeyNames(KeyLocation: string): TStringList;
      function GetValueNames(KeyLocation: string): TStringList;

      function GetValueExists(KeyLocation, ValueName: string): boolean;
      function DeleteValue(KeyLocation, ValueName: string): boolean;

      procedure WriteValue(KeyLocation, ItemName: string; Value: string = ''); overload;
      procedure WriteValue(KeyLocation, ItemName: string; Value: integer = 0); overload;
      procedure WriteValue(KeyLocation, ItemName: string; Value: boolean = false); overload;
      procedure WriteValue(KeyLocation, ItemName: string; Value: double = 0); overload;
      procedure WriteValue(KeyLocation, ItemName: string; Value: TDateTime); overload;
      procedure WriteValue(KeyLocation, ItemName: string; Value: TDate); overload;
      procedure WriteValue(KeyLocation, ItemName: string; Value: TTime); overload;

      function GetStringValue(KeyLocation, ValueName: string): string;
      function GetIntValue(KeyLocation, ValueName: string): integer;
      function GetDateTimeValue(KeyLocation, ValueName: string): TDateTime;
      function GetBooleanValue(KeyLocation, ValueName: string): boolean;
      function GetFloatValue(KeyLocation, ValueName: string): double;
      function GetCurrencyValue(KeyLocation, ValueName: string): currency;
      function GetTimeValue(KeyLocation, ValueName: string): TTime;
      function GetDateValue(KeyLocation, ValueName: string): TDate;

      function GetValueType(KeyLocation, ValueName: string): TRegDataType;
      function GetValueAsString(KeyLocation, ValueName: string): string;
      function GetValueAsStringEx(KeyLocation, ValueName: string): string;

      procedure WriteStringValue(KeyLocation, ItemName: string; Value: string);
      procedure WriteIntValue(KeyLocation, ItemName: string; Value: integer);
      procedure WriteDateTimeValue(KeyLocation, ItemName: string; Value: TDateTime);
      procedure WriteBooleanValue(KeyLocation, ItemName: string; Value: boolean);
      procedure WriteFloatValue(KeyLocation, ItemName: string; Value: double);
      procedure WriteCurrency(KeyLocation, ItemName: string; Value: Currency);
      procedure WriteTime(KeyLocation, ItemName: string; Value: TTime);
      procedure WriteDate(KeyLocation, ItemName: string; Value: TDate);

      (* Properties *)
      property RegistryMode: TRegistryMode read FRegistryMode write FRegistryMode;

      // Error Handeling
      property LastError: TRegistryError read FLastError;
      { This property defines who will handle errors. Windows, the OnRecieve
        procedure or to just ignore them }
      property ErrorKind: TRegistryErrorKind read FErrorKind write FErrorKind;

      // Error Procedures
      property OnRaiseError: TRegistryOnError read FOnError write FOnError;

      procedure RegistryReceiveError(AError: TRegistryError);

      // Registry Mode
      procedure ResetRegistryMode;
      function WinModeLoaded: boolean;

      // Hive
      property AutomaticHive: boolean read FAutoHive write FAutoHive;
      property ManualHive: HKEY read FDefaultHive write SetManualHive;
      (* Detect the hive automatically from the KeyLocation, overriden by DefaultHive *)
      property DefaultHive: HKEY read FDefaultHive write FDefaultHive;

      // Utilities
      class function HiveToString(Hive: HKEY): string;
      class function StringToHive(AString: string; Default: HKEY = HKEY_CURRENT_USER): HKEY;
      class function StringToHiveEx(AString: string; var Hive: HKEY): boolean;
    end;

const
  KEY_SEPAR = '\';
  COMPUTER_BEGIN = 'Computer' + KEY_SEPAR;

  HIVE_CLASSES_ROOT: TArray<string> = ['HKEY_CLASSES_ROOT', 'HKCR', 'HKEY_CLASSES'];
  HIVE_CURRENT_USER: TArray<string> = ['HKEY_CURRENT_USER', 'HKCU', 'HKEY_USER'];
  HIVE_LOCAL_MACHINE: TArray<string> = ['HKEY_LOCAL_MACHINE', 'HKLM', 'HKEY_MACHINE'];
  HIVE_USERS: TArray<string> = ['HKEY_USERS', 'HKU'];
  HIVE_CURRENT_CONFIG: TArray<string> = ['HKEY_CURRENT_CONFIG', 'HKCC', 'HKEY_CONFIG'];
  HIVE_PERFORMANCE_DATA: TArray<string> = ['HKEY_PERFORMANCE_DATA', 'HKPD'];
  HIVE_DYN_DATA: TArray<string> = ['HKEY_DYN_DATA', 'HKEY_DD'];

implementation

{ TWinRegistry }

function TWinRegistry.WinModeLoaded: boolean;
begin
  Result := FRegistryMode <> TRegistryMode.Unloaded;

  if not Result then
    begin
      ResetRegistryMode;

      // Loaded
      Result := true;
    end;
end;

procedure TWinRegistry.ResetRegistryMode;
begin
  // Registry Variant
  if IsWOW64Emulated or IsWow64Executable then
    FRegistryMode := TRegistryMode.Windows64
  else
    FRegistryMode := TRegistryMode.Windows32;
end;

function TWinRegistry.IsWOW64Emulated: Boolean;
var
  IsWow64: BOOL;
begin
  // Check if the current process is running under WOW64
  if IsWow64Process(GetCurrentProcess, IsWow64) then
    Result := IsWow64
  else
    Result := False;
end;

function TWinRegistry.IsWow64Executable: Boolean;
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

constructor TWinRegistry.Create;
begin
  inherited Create;

  // Default
  FDefaultHive := HKEY_CURRENT_USER;
  FErrorKind := TRegistryErrorKind.Receive;
  FLastError := TRegistryError.None;
  FAutoHive := true;
  FOnError := RegistryReceiveError;
end;

destructor TWinRegistry.Destroy;
begin
  // Free Registry
  FRegistry.Free;

  inherited Destroy;
end;

function TWinRegistry.ApplyRegMode(mode: Cardinal): Cardinal;
begin
  // Select a registry based on arhitecture
  case FRegistryMode of
    TRegistryMode.Windows32: Result := mode OR KEY_WOW64_32KEY;
    TRegistryMode.Windows64: Result := mode OR KEY_WOW64_64KEY;
    else Result := mode;
  end;
end;

function TWinRegistry.CreateKey(KeyLocation: string): boolean;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, GetPathItem(KeyLocation) );

  // Create Key
  Result := false;
  try
    Result := FRegistry.CreateKey( GetPathEnd(KeyLocation) );
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

function TWinRegistry.DeleteKey(KeyLocation: string): boolean;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, GetPathItem(KeyLocation) );

  // Create Key
  Result := false;
  try
    Result := FRegistry.DeleteKey( GetPathEnd(KeyLocation) );
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

function TWinRegistry.DeleteValue(KeyLocation, ValueName: string): boolean;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  Result := false;
  try
    Result := FRegistry.DeleteValue( ValueName );
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

function TWinRegistry.GetStringValue(KeyLocation, ValueName: string): string;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  try
    Result := FRegistry.ReadString(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetTimeValue(KeyLocation, ValueName: string): TTime;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := 0;
  try
    Result := FRegistry.ReadTime(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetDateTimeValue(KeyLocation, ValueName: string): TDateTime;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := 0;
  try
    Result := FRegistry.ReadDateTime(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetDateValue(KeyLocation, ValueName: string): TDate;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := 0;
  try
    Result := FRegistry.ReadDate(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetFloatValue(KeyLocation, ValueName: string): double;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := 0;
  try
    Result := FRegistry.ReadFloat(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetValueType(KeyLocation, ValueName: string): TRegDataType;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := rdUnknown;
  try
    Result := FRegistry.GetDataType( ValueName );
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;


class function TWinRegistry.HiveToString(Hive: HKEY): string;
begin
  // Constant expression violates subrange bounds, IF STATEMENT instead of CASE to fix
  if Hive = HKEY_CLASSES_ROOT then
    Result := HIVE_CLASSES_ROOT[0]
  else
  if Hive = HKEY_CURRENT_USER then
    Result := HIVE_CURRENT_USER[0]
  else
  if Hive = HKEY_LOCAL_MACHINE then
    Result := HIVE_LOCAL_MACHINE[0]
  else
  if Hive = HKEY_USERS then
    Result := HIVE_USERS[0]
  else
  if Hive = HKEY_PERFORMANCE_DATA then
    Result := HIVE_PERFORMANCE_DATA[0]
  else
  if Hive = HKEY_DYN_DATA then
    Result := HIVE_DYN_DATA[0]
  else
    Result := STRING_UNKNOWN;
end;

function TWinRegistry.GetValueAsStringEx(KeyLocation, ValueName: string): string;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  try
    Result := FRegistry.GetDataAsString(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetValueAsString(KeyLocation, ValueName: string): string;
var
  ItemType: TRegDataType;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  try
    ItemType := FRegistry.GetDataType(ValueName);

    case ItemType of
      rdUnknown, rdString, rdExpandString: Result := GetStringValue(KeyLocation, ValueName);
      rdInteger: Result := inttostr( GetIntValue(KeyLocation, ValueName) );
      rdBinary: GetStringValue(KeyLocation, ValueName);
    end;
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetValueExists(KeyLocation, ValueName: string): boolean;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := false;
  try
    Result := FRegistry.ValueExists( ValueName );
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetValueNames(KeyLocation: string): TStringList;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := TStringList.Create;
  try
    FRegistry.GetValueNames( Result );
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.KeyExists(KeyLocation: string): boolean;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, GetPathItem(KeyLocation) );

  // Create Key
  Result := false;
  try
    Result := FRegistry.KeyExists( GetPathEnd(KeyLocation) );
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.CloneKey(KeyLocation: string): string;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Complete, GetPathItem(KeyLocation) );

  // Create Key
  try
    Result := FRegistry.CloneKey( GetPathEnd(KeyLocation) );
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

function TWinRegistry.RenameKey(KeyLocation, NewName: string): boolean;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Complete, GetPathItem(KeyLocation) );

  // Create Key
  Result := false;
  try
    FRegistry.RenameKey( GetPathEnd(KeyLocation), NewName );

    Result := FRegistry.KeyExists( NewName );
  except
    RaiseError( TRegistryError.KeyNoExist );
  end;
end;

procedure TWinRegistry.SetManualHive(const Value: HKEY);
begin
  FAutoHive := false;
  FDefaultHive := Value;
end;

procedure TWinRegistry.SetNewRegistryMode(AMode: TRegistryMode);
begin
  FRegistryMode := AMode;
end;

class function TWinRegistry.StringToHive(AString: string; Default: HKEY): HKEY;
begin
  if not StringToHiveEx(AString, Result) then
    Result := Default;
end;

class function TWinRegistry.StringToHiveEx(AString: string; var Hive: HKEY): boolean;
begin
  if HIVE_CLASSES_ROOT.Find(AString) <> -1 then
    begin
      Hive := HKEY_CLASSES_ROOT;
      Exit(true);
    end;

  if HIVE_CURRENT_USER.Find(AString) <> -1 then
    begin
      Hive := HKEY_CURRENT_USER;
      Exit(true);
    end;

  if HIVE_LOCAL_MACHINE.Find(AString) <> -1 then
    begin
      Hive := HKEY_LOCAL_MACHINE;
      Exit(true);
    end;

  if HIVE_USERS.Find(AString) <> -1 then
    begin
      Hive := HKEY_USERS;
      Exit(true);
    end;

  if HIVE_CURRENT_CONFIG.Find(AString) <> -1 then
    begin
      Hive := HKEY_CURRENT_CONFIG;
      Exit(true);
    end;

  if HIVE_PERFORMANCE_DATA.Find(AString) <> -1 then
    begin
      Hive := HKEY_PERFORMANCE_DATA;
      Exit(true);
    end;

  if HIVE_DYN_DATA.Find(AString) <> -1 then
    begin
      Hive := HKEY_DYN_DATA;
      Exit(true);
    end;

  Exit(false);
end;

function TWinRegistry.MoveKey(KeyLocation, NewLocation: string; AlsoDelete: boolean = true): boolean;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Complete, GetPathItem(KeyLocation) );

  // Create Key
  Result := false;
  try
    FRegistry.MoveKeyTo( GetPathEnd(KeyLocation), NewLocation, AlsoDelete );
    Result := true;
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

function TWinRegistry.CopyKey(KeyLocation, NewLocation: string): boolean;
begin
  Result := MoveKey(KeyLocation, NewLocation, false);
end;

function TWinRegistry.GetBooleanValue(KeyLocation, ValueName: string): boolean;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := false;
  try
    Result := FRegistry.ReadBool(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetCurrencyValue(KeyLocation, ValueName: string): currency;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := 0;
  try
    Result := FRegistry.ReadCurrency(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetIntValue(KeyLocation, ValueName: string): integer;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := 0;
  try
    Result := FRegistry.ReadInteger(ValueName);
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

function TWinRegistry.GetKeyNames(KeyLocation: string): TStringList;
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Read, KeyLocation );

  // Create Key
  Result := TStringList.Create;
  try
    FRegistry.GetKeyNames( Result );
  except
    RaiseError( TRegistryError.ReadError );
  end;
end;

procedure TWinRegistry.CreateReg(AType: TRegistryNeed; APosition: string);
var
  Access: Cardinal;
begin
  // Select Type
  case AType of
    TRegistryNeed.Read: Access := ApplyRegMode(KEY_READ);
    TRegistryNeed.Write: Access := ApplyRegMode(KEY_WRITE);
    TRegistryNeed.Complete: Access := ApplyRegMode(KEY_ALL_ACCESS);
    else Access := ApplyRegMode(KEY_ALL_ACCESS);
  end;

  // Create
  FRegistry := TRegistry.Create( Access );

  // Open Hive
  FRegistry.RootKey := FHive;

  // Position
  FRegistry.OpenKey( APosition, false );
end;

function TWinRegistry.GetPathEnd(Path: string): string;
begin
  Result := ExtractFileName( ExcludeTrailingPathDelimiter( Path ) );
end;

function TWinRegistry.GetPathItem(Path: string): string;
begin
  Result := ExtractFileDir( ExcludeTrailingPathDelimiter( Path ) );
end;

procedure TWinRegistry.ApplyPath(var Path: string);
label
  FoundItem, ExitSearch;
var
  StrRoot: string;
begin
  // Prepare
  Path := IncludeTrailingPathDelimiter( Path );

  if Pos(COMPUTER_BEGIN, Path) = 1 then
    RemovePathLevels( Path, 1 );

  // Extract Hive
  FHive := FDefaultHive;

  if FAutoHive then
    begin
      StrRoot := AnsiUpperCase(Copy( Path, 1, Pos(KEY_SEPAR, Path) - 1 ));

      // Cases
      if StringToHiveEx(StrRoot, FHive) then
        RemovePathLevels( Path, 1 );

      // Exit
      ExitSearch:
    end;
end;

procedure TWinRegistry.RegistryReceiveError(AError: TRegistryError);
begin
  case AError of
    TRegistryError.AccessDenied: ShowMessage( 'Windows Registry Error: Access Denied' );
    TRegistryError.KeyNoExist: ShowMessage( 'Windows Registry Error: The specified key does not exist' );
    TRegistryError.ReadError: ShowMessage( 'Windows Registry Error: Cannot read from the Windows Registry' );
  end;
end;

procedure TWinRegistry.RemovePathLevels(var Path: string; Levels: integer);
var
  P: integer;
  I: Integer;
begin
  for I := 1 to Levels do
    begin
      P := Pos( KEY_SEPAR, Path );

      if P <> 0 then
        Path := Copy( Path, P + 1, Length(Path) );
    end;
end;

procedure TWinRegistry.RaiseError(AError: TRegistryError);
begin
  // Error Message
  case FErrorKind of
    TRegistryErrorKind.Receive: if Assigned(FOnError) then
        FOnError(AError);
    TRegistryErrorKind.OperatingSystem: RaiseLastOSError;
  end;

  // Set Property
  FLastError := AError;
end;

procedure TWinRegistry.WriteStringValue(KeyLocation, ItemName: string; Value: string);
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  try
    FRegistry.WriteString(ItemName, Value);
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

procedure TWinRegistry.WriteTime(KeyLocation, ItemName: string; Value: TTime);
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  try
    FRegistry.WriteTime(ItemName, Value);
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

procedure TWinRegistry.WriteValue(KeyLocation, ItemName: string; Value: boolean);
begin
  WriteBooleanValue(KeyLocation, ItemName, Value);
end;

procedure TWinRegistry.WriteValue(KeyLocation, ItemName: string; Value: integer);
begin
  WriteIntValue(KeyLocation, ItemName, Value);
end;

procedure TWinRegistry.WriteValue(KeyLocation, ItemName, Value: string);
begin
  WriteStringValue(KeyLocation, ItemName, Value);
end;

procedure TWinRegistry.WriteValue(KeyLocation, ItemName: string; Value: double);
begin
  WriteFloatValue(KeyLocation, ItemName, Value);
end;

procedure TWinRegistry.WriteValue(KeyLocation, ItemName: string; Value: TTime);
begin
  WriteTime(KeyLocation, ItemName, Value);
end;

procedure TWinRegistry.WriteValue(KeyLocation, ItemName: string; Value: TDate);
begin
  WriteDate(KeyLocation, ItemName, Value);
end;

procedure TWinRegistry.WriteValue(KeyLocation, ItemName: string;
  Value: TDateTime);
begin
  WriteDateTimeValue(KeyLocation, ItemName, Value);
end;

procedure TWinRegistry.WriteBooleanValue(KeyLocation, ItemName: string; Value: boolean);
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  try
    FRegistry.WriteBool(ItemName, Value);
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

procedure TWinRegistry.WriteCurrency(KeyLocation, ItemName: string; Value: Currency);
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  try
    FRegistry.WriteCurrency(ItemName, Value);
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

procedure TWinRegistry.WriteDate(KeyLocation, ItemName: string; Value: TDate);
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  try
    FRegistry.WriteDate(ItemName, Value);
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

procedure TWinRegistry.WriteDateTimeValue(KeyLocation, ItemName: string; Value: TDateTime);
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  try
    FRegistry.WriteDateTime(ItemName, Value);
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

procedure TWinRegistry.WriteFloatValue(KeyLocation, ItemName: string; Value: double);
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  try
    FRegistry.WriteFloat(ItemName, Value);
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

procedure TWinRegistry.WriteIntValue(KeyLocation, ItemName: string; Value: integer);
begin
  // Prepare bPath & Open
  ApplyPath( KeyLocation );
  CreateReg( TRegistryNeed.Write, KeyLocation );

  // Create Key
  try
    FRegistry.WriteInteger(ItemName, Value);
  except
    RaiseError( TRegistryError.AccessDenied );
  end;
end;

{ TRegHelper }
function TRegHelper.ReadCardinal(const Name: string): Cardinal;
var
  Int: integer;
begin
  Int := ReadInteger(Name);
  if Int < 0 then
    begin
      (* Substract negative value  *)
      Result := Abs(Int + 1);
      Result := Cardinal.MaxValue - Result;
    end
  else
    Result := Int;
 end;

procedure TRegHelper.RenameKey(const OldName, NewName: string);
begin
  Self.MoveKey(OldName, NewName, true);
end;

function TRegHelper.CloneKey(const KeyName: string): string;
var
  CloneNumber: integer;
begin
  // Get Clone Index
  CloneNumber := 1;
  repeat
    inc(CloneNumber);
  until not Self.KeyExists(KeyName + '(' + inttostr( CloneNumber ) + ')');

  // New name
  Result := KeyName + '(' + inttostr( CloneNumber ) + ')';

  // Copy
  MoveKey(KeyName, Result, false);
end;

procedure TRegHelper.MoveKeyTo(const OldName, NewKeyPath: string; Delete: Boolean);
var
  RegistryOld,
  RegistryNew: TRegistry;

  I: integer;

  ValueNames: TStringList;
  KeyNames: TStringList;

  procedure MoveValue(SrcKey, DestKey: HKEY; const Name: string);
  var
    Len: Integer;
    OldKey, PrevKey: HKEY;
    Buffer: PChar;
    RegData: TRegDataType;
  begin
    OldKey := CurrentKey;
    SetCurrentKey(SrcKey);
    try
      Len := GetDataSize(Name);
      if Len >= 0 then
      begin
        Buffer := AllocMem(Len);
        try
          Len := GetData(Name, Buffer, Len, RegData);
          PrevKey := CurrentKey;
          SetCurrentKey(DestKey);
          try
            PutData(Name, Buffer, Len, RegData);
          finally
            SetCurrentKey(PrevKey);
          end;
        finally
          FreeMem(Buffer);
        end;
      end;
    finally
      SetCurrentKey(OldKey);
    end;
  end;
begin
  /// Attention!
  /// The NewKeyPath requires a registry path in the same HIVE. This NEEDS to be a
  /// path in the HIVE, only giving the new Key Name will create a new Key in the
  /// root of the HIVE!

  ValueNames := TStringList.Create;
  KeyNames := TStringList.Create;

  RegistryNew := TRegistry.Create( Self.Access );
  RegistryOld := TRegistry.Create( Self.Access );
  try
    // Open Keys
    RegistryOld.OpenKey( IncludeTrailingPathDelimiter( IncludeTrailingPathDelimiter( Self.CurrentPath ) + OldName ), false );
    RegistryNew.OpenKey( IncludeTrailingPathDelimiter( NewKeyPath ), True );

    // Index Keys/Values
    RegistryOld.GetValueNames(ValueNames);
    RegistryOld.GetKeyNames(KeyNames);

    // Copy Values
    for I := 1 to ValueNames.Count do
      MoveValue( RegistryOld.CurrentKey, RegistryNew.CurrentKey,
                 ValueNames[I - 1] );

    // Copy subkeys
    for I := 1 to KeyNames.Count do
      RegistryOld.MoveKeyTo(KeyNames[I - 1],
                            RegistryNew.CurrentPath + KeyNames[I - 1] + '\',
                            false);
  finally
    // Free Mem
    RegistryOld.Free;
    RegistryNew.Free;

    ValueNames.Free;
    KeyNames.Free;

    if Delete then
      Self.DeleteKey(OldName);
  end;
end;

{ TQuickReg }

class function TQuickReg.CreateKey(KeyLocation: string): boolean;
var
  Registry: TWinRegistry;
begin
  Registry := TWinRegistry.Create;
  try
    Result := Registry.CreateKey(KeyLocation);
  finally
    Registry.Free;
  end;
end;

class function TQuickReg.DeleteKey(KeyLocation: string): boolean;
var
  Registry: TWinRegistry;
begin
  Registry := TWinRegistry.Create;
  try
    Result := Registry.DeleteKey(KeyLocation);
  finally
    Registry.Free;
  end;
end;

class function TQuickReg.DeleteValue(KeyLocation, ValueName: string): boolean;
var
  Registry: TWinRegistry;
begin
  Registry := TWinRegistry.Create;
  try
    Result := Registry.DeleteValue(KeyLocation, ValueName);
  finally
    Registry.Free;
  end;
end;

class function TQuickReg.GetIntValue(KeyLocation, ValueName: string): integer;
var
  Registry: TWinRegistry;
begin
  Registry := TWinRegistry.Create;
  try
    Result := Registry.GetIntValue(KeyLocation, ValueName);
  finally
    Registry.Free;
  end;
end;

class function TQuickReg.GetStringValue(KeyLocation, ValueName: string): string;
var
  Registry: TWinRegistry;
begin
  Registry := TWinRegistry.Create;
  try
    Result := Registry.GetStringValue(KeyLocation, ValueName);
  finally
    Registry.Free;
  end;
end;

class function TQuickReg.GetValueExists(KeyLocation,
  ValueName: string): boolean;
var
  Registry: TWinRegistry;
begin
  Registry := TWinRegistry.Create;
  try
    Result := Registry.GetValueExists(KeyLocation, ValueName);
  finally
    Registry.Free;
  end;
end;

class function TQuickReg.KeyExists(KeyLocation: string): boolean;
var
  Registry: TWinRegistry;
begin
  Registry := TWinRegistry.Create;
  try
    Result := Registry.KeyExists(KeyLocation);
  finally
    Registry.Free;
  end;
end;

class function TQuickReg.RenameKey(KeyLocation, NewName: string): boolean;
var
  Registry: TWinRegistry;
begin
  Registry := TWinRegistry.Create;
  try
    Result := Registry.RenameKey(KeyLocation, NewName);
  finally
    Registry.Free;
  end;
end;

end.
