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


unit Cod.WinRegister;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Registry, Vcl.Dialogs, Cod.VarHelpers;
  type
    WinReg = class  {$TYPEINFO ON}
    public
      constructor Create;
      destructor Destroy; override;
      class procedure SetRegMode(mode: integer);
      class function CreateKey(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
      class function KeyExists(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
      class function DeleteKey(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
      class function CloneKey(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
      class function RenameKey(RenameTo, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
      class function MoveKey(NewLocation, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false; AlsoDelete: boolean = true): boolean;
      class function CopyKey(NewLocation, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;

      class function GetKeyNames(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): TStringList;
      class function GetValueNames(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): TStringList;

      class function GetValueExists(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
      class procedure DeleteValue(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);

      class procedure WriteValue(ItemName, KeyLocation: string; Value: string = ''; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false); overload;
      class procedure WriteValue(ItemName, KeyLocation: string; Value: integer = 0; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false); overload;
      class procedure WriteValue(ItemName, KeyLocation: string; Value: boolean = false; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false); overload;
      class procedure WriteValue(ItemName, KeyLocation: string; Value: double = 0; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false); overload;
      class procedure WriteValue(ItemName, KeyLocation: string; Value: TDateTime; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false); overload;
      class procedure WriteValue(ItemName, KeyLocation: string; Value: TDate; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false); overload;
      class procedure WriteValue(ItemName, KeyLocation: string; Value: TTime; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false); overload;

      class function GetStringValue(StringName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): string;
      class function GetIntValue(IntName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): integer;
      class function GetDateTimeValue(StringName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): TDateTime;
      class function GetBooleanValue(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
      class function GetFloatValue(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): double;
      class function GetCurrencyValue(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): currency;
      class function GetTimeValue(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): TTime;
      class function GetDateValue(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): TDate;

      class function GetValueType(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): TRegDataType;
      class function GetValueAsString(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): string;

      class procedure WriteStringValue(ItemName, KeyLocation: string; Text: string = ''; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
      class procedure WriteIntValue(ItemName, KeyLocation: string; Value: integer = 0; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
      class procedure WriteDateTimeValue(ItemName, KeyLocation: string; TimeDateValue: TDateTime; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
      class procedure WriteBooleanValue(ItemName, KeyLocation: string; Value: boolean; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
      class procedure WriteFloatValue(ItemName, KeyLocation: string; Value: double; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
      class procedure WriteCurrency(ItemName, KeyLocation: string; Value: Currency; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
      class procedure WriteTime(ItemName, KeyLocation: string; Value: TTime; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
      class procedure WriteDate(ItemName, KeyLocation: string; Value: TDate; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
    private
      FAuthor, FSite, FVersion: string;
      class function GetLastItem(loc: string): string;
      class function GetAppropriateRegMode(mode: Cardinal = KEY_ALL_ACCESS): Cardinal;
    published
      property Author: string Read FAuthor;
      property Site: string Read FSite;
      property Version: string Read FVersion;
    end;

implementation

{ WinReg }

var
  regmode: integer = 0;

constructor WinReg.Create;
begin
  inherited Create;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.1';
end;

destructor WinReg.Destroy;
begin
  inherited Destroy;
end;

class function WinReg.CreateKey(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
var
   Registry: TRegistry;
begin
  Result := false;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_ALL_ACCESS));
   try
     Registry.RootKey := hiveid;
     Registry.OpenKey(Copy(KeyLocation,0,KeyLocation.Length - GetLastItem(KeyLocation).Length),true);
     try
     if not Registry.KeyExists(GetLastItem(KeyLocation)) then
      Registry.CreateKey(GetLastItem(KeyLocation));
      Result := true;
     except
      if emessage=true then ShowMessage('Could not create registry key. Acess Denied');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.DeleteKey(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
var
  Registry: TRegistry;
begin
  Result := false;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_ALL_ACCESS));
   try
     Registry.RootKey := hiveid;
     Registry.OpenKey(Copy(KeyLocation,0,KeyLocation.Length - GetLastItem(KeyLocation).Length),false);
     try
     if Registry.KeyExists(GetLastItem(KeyLocation)) then
       Registry.DeleteKey(GetLastItem(KeyLocation))
     else
       if emessage=true then ShowMessage('Could not delete registry key because the key does not exist.');
     Result := true;
     except
      if emessage=true then ShowMessage('Could not delete registry key. Acess Denied');
     end;
   finally
     Registry.Free;
   end;
end;

class procedure WinReg.DeleteValue(ItemName, KeyLocation: string;
  hiveid: HKEY; emessage: boolean);
var
   Registry: TRegistry;
begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_ALL_ACCESS));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          if Registry.ValueExists(ItemName) then Registry.DeleteValue(ItemName);
    finally
      Registry.Free;
     end;
end;

class function WinReg.GetStringValue(StringName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): string;
var
   Registry: TRegistry;
begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     // False because otherwise it would create a new key
     try
     Registry.OpenKey(KeyLocation, False);
     Result := Registry.ReadString(StringName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetTimeValue(ItemName, KeyLocation: string; hiveid: HKEY;
  emessage: boolean): TTime;
var
   Registry: TRegistry;
begin
  Result := Now;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     // False because otherwise it would create a new key
     try
     Registry.OpenKey(KeyLocation, False);
     Result := Registry.ReadTime(ItemName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetDateTimeValue(StringName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): TDateTime;
var
   Registry: TRegistry;
 begin
  Result := Now;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     // False because otherwise it would create a new key
     try
     Registry.OpenKey(KeyLocation, False);
     Result := Registry.ReadDateTime(StringName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetDateValue(ItemName, KeyLocation: string; hiveid: HKEY;
  emessage: boolean): TDate;
var
  Registry: TRegistry;
begin
  Result := Now;
  Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     // False because otherwise it would create a new key
     try
     Registry.OpenKey(KeyLocation, False);
     Result := Registry.ReadDate(ItemName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetFloatValue(ItemName, KeyLocation: string; hiveid: HKEY;
  emessage: boolean): double;
var
  Registry: TRegistry;
begin
  Result := 0;
  Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     // False because otherwise it would create a new key
     try
     Registry.OpenKey(KeyLocation, False);
     Result := Registry.ReadFloat(ItemName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetValueType(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): TRegDataType;
var
  Registry: TRegistry;
begin
  Result := TRegDataType.rdUnknown;
  Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     // False because otherwise it would create a new key
     try
       Registry.OpenKey(KeyLocation, False);
       Result := Registry.GetDataType(ItemName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetValueAsString(ItemName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): string;
var
  Registry: TRegistry;
  ItemType: TRegDataType;
begin
  Result := 'Unknown';
  Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     // False because otherwise it would create a new key
     try
       Registry.OpenKey(KeyLocation, False);
       ItemType := Registry.GetDataType(ItemName);

       case ItemType of
        rdUnknown, rdString, rdExpandString: Result := GetStringValue(ItemName, KeyLocation, hiveid);
        rdInteger: Result := inttostr( GetIntValue(ItemName, KeyLocation, hiveid) );
        rdBinary: GetStringValue(ItemName, KeyLocation, hiveid);
       end;
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;


class function WinReg.GetValueExists(ItemName, KeyLocation: string;
  hiveid: HKEY; emessage: boolean): boolean;
var
   Registry: TRegistry;
 begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKeyReadOnly(KeyLocation) then RaiseLastOSError(Registry.LastError);
          Result := Registry.ValueExists(ItemName);
    finally
      Registry.Free;
     end;
end;

class function WinReg.GetValueNames(KeyLocation: string; hiveid: HKEY;
  emessage: boolean): TStringList;
var
   Registry: TRegistry;
begin
  Result := TStringList.Create;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     Registry.OpenKeyReadOnly(Copy(KeyLocation,0,KeyLocation.Length - GetLastItem(KeyLocation).Length));
     try
      Registry.GetValueNames(Result);
     except
      if emessage=true then ShowMessage('A READ error occured.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.KeyExists(KeyLocation: string; hiveid: HKEY;
  emessage: boolean): boolean;
var
   Registry: TRegistry;
   lastitem: string;
   innerkey: string;
begin
  Result := false;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_ALL_ACCESS));
   try
     Registry.RootKey := hiveid;
     innerkey := Copy(KeyLocation,0,KeyLocation.Length - GetLastItem(KeyLocation).Length);
     Registry.OpenKeyReadOnly(innerkey);
     try
      lastitem := GetLastItem(KeyLocation);
      Result := Registry.KeyExists( lastitem ) and ((Pos(Registry.CurrentPath, innerkey) <> 0) or (Registry.CurrentPath = innerkey));
     except
      if emessage=true then ShowMessage('A READ error occured.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.CloneKey(KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
var
   Registry: TRegistry;
begin
  Result := false;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_ALL_ACCESS));
   try
     Registry.RootKey := hiveid;
     Registry.OpenKey(Copy(KeyLocation,0,KeyLocation.Length - GetLastItem(KeyLocation).Length),false);
     try
     if Registry.KeyExists(GetLastItem(KeyLocation)) then
      begin
        Registry.CloneKey( GetLastItem(KeyLocation) );
      end;
     except
      if emessage=true then ShowMessage('Could not create rename key. Acess Denied or Key does not exist');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.RenameKey(RenameTo, KeyLocation: string; hiveid: HKEY;
  emessage: boolean): boolean;
var
   Registry: TRegistry;
begin
  Result := false;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_ALL_ACCESS));
   try
     Registry.RootKey := hiveid;
     Registry.OpenKey(Copy(KeyLocation,0,KeyLocation.Length - GetLastItem(KeyLocation).Length),false);
     try
     if Registry.KeyExists(GetLastItem(KeyLocation)) then
      begin
        Registry.RenameKey( GetLastItem(KeyLocation), RenameTo);
        Result := true;
      end;
     except
      if emessage=true then ShowMessage('Could not create rename key. Acess Denied or Key does not exist');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.MoveKey(NewLocation, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false; AlsoDelete: boolean = true): boolean;
var
   Registry: TRegistry;
begin
  Result := false;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_ALL_ACCESS));
   try
     Registry.RootKey := hiveid;
     Registry.OpenKey(Copy(KeyLocation,0,KeyLocation.Length - GetLastItem(KeyLocation).Length), false);
     try
     if Registry.KeyExists(GetLastItem(KeyLocation)) then
      begin
        Registry.MoveKeyTo( GetLastItem(KeyLocation), NewLocation, AlsoDelete);
        Result := true;
      end;
     except
      if emessage=true then ShowMessage('Could not create rename key. Acess Denied or Key does not exist');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.CopyKey(NewLocation, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): boolean;
begin
  Result := MoveKey(NewLocation, KeyLocation, hiveid, emessage, false);
end;

class procedure WinReg.SetRegMode(mode: integer);
begin
  {            0 - auto             }
  {         1 - always32bit         }
  {         2 - always64bit         }
  regmode := mode;
end;

class function WinReg.GetAppropriateRegMode(mode: Cardinal): Cardinal;
begin
  Result := mode;
  case regmode of
    0: Result := mode;
    1: Result := mode OR KEY_WOW64_32KEY;
    2: Result := mode OR KEY_WOW64_64KEY;
  end;
end;

class function WinReg.GetBooleanValue(ItemName, KeyLocation: string;
  hiveid: HKEY; emessage: boolean): boolean;
var
   Registry: TRegistry;
 begin
  Result := false;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;

     // False because otherwise it would create a new key
     try
     Registry.OpenKeyReadOnly(KeyLocation);
     Result := Registry.ReadBool(ItemName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetCurrencyValue(ItemName, KeyLocation: string;
  hiveid: HKEY; emessage: boolean): currency;
var
   Registry: TRegistry;
begin
  Result := 0;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;

     // False because otherwise it would create a new key
     try
     Registry.OpenKeyReadOnly(KeyLocation);
     Result := Registry.ReadCurrency(ItemName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;

end;

class function WinReg.GetIntValue(IntName, KeyLocation: string; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false): integer;
var
   Registry: TRegistry;
 begin
  Result := 0;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;

     // False because otherwise it would create a new key
     try
     Registry.OpenKeyReadOnly(KeyLocation);
     Result := Registry.ReadInteger(IntName);
     except
      if emessage=true then ShowMessage('Error. Could not read from Windows Registry.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetKeyNames(KeyLocation: string; hiveid: HKEY;
  emessage: boolean): TStringList;
var
   Registry: TRegistry;
begin
  Result := TStringList.Create;
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_READ));
   try
     Registry.RootKey := hiveid;
     Registry.OpenKeyReadOnly(Copy(KeyLocation,0,KeyLocation.Length - GetLastItem(KeyLocation).Length));
     try
      Registry.GetKeyNames(Result);
     except
      if emessage=true then ShowMessage('A READ error occured.');
     end;
   finally
     Registry.Free;
   end;
end;

class function WinReg.GetLastItem(loc: string): string;
var
  p: integer;
begin
  repeat
    p := Pos('\',loc);
    loc := Copy(loc,p + 1,loc.Length);
  until (p = 0);
  result := loc;
end;

class procedure WinReg.WriteStringValue(ItemName, KeyLocation: string; Text: string = ''; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
var
   Registry: TRegistry;
 begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_WRITE));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          Registry.WriteString(ItemName, text);
    finally
      Registry.Free;
    end;
end;

class procedure WinReg.WriteTime(ItemName, KeyLocation: string; Value: TTime;
  hiveid: HKEY; emessage: boolean);
var
   Registry: TRegistry;
begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_WRITE));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          Registry.WriteTime(ItemName, Value);
    finally
      Registry.Free;
    end;
end;

class procedure WinReg.WriteValue(ItemName, KeyLocation: string; Value: boolean;
  hiveid: HKEY; emessage: boolean);
begin
  WinReg.WriteBooleanValue(ItemName, KeyLocation, Value, hiveid, emessage);
end;

class procedure WinReg.WriteValue(ItemName, KeyLocation: string; Value: integer;
  hiveid: HKEY; emessage: boolean);
begin
  WinReg.WriteIntValue(ItemName, KeyLocation, Value, hiveid, emessage);
end;

class procedure WinReg.WriteValue(ItemName, KeyLocation, Value: string;
  hiveid: HKEY; emessage: boolean);
begin
  WinReg.WriteStringValue(ItemName, KeyLocation, Value, hiveid, emessage);
end;

class procedure WinReg.WriteValue(ItemName, KeyLocation: string; Value: double;
  hiveid: HKEY; emessage: boolean);
begin
  WinReg.WriteFloatValue(ItemName, KeyLocation, Value, hiveid, emessage);
end;

class procedure WinReg.WriteValue(ItemName, KeyLocation: string; Value: TTime;
  hiveid: HKEY; emessage: boolean);
begin
  WinReg.WriteTime(ItemName, KeyLocation, Value, hiveid, emessage);
end;

class procedure WinReg.WriteValue(ItemName, KeyLocation: string; Value: TDate;
  hiveid: HKEY; emessage: boolean);
begin
  WinReg.WriteDate(ItemName, KeyLocation, Value, hiveid, emessage);
end;

class procedure WinReg.WriteValue(ItemName, KeyLocation: string;
  Value: TDateTime; hiveid: HKEY; emessage: boolean);
begin
  WinReg.WriteDateTimeValue(ItemName, KeyLocation, Value, hiveid, emessage);
end;

class procedure WinReg.WriteBooleanValue(ItemName, KeyLocation: string;
  Value: boolean; hiveid: HKEY; emessage: boolean);
var
   Registry: TRegistry;
 begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_WRITE));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          Registry.WriteBool(ItemName, Value);
    finally
      Registry.Free;
    end;
end;

class procedure WinReg.WriteCurrency(ItemName, KeyLocation: string;
  Value: Currency; hiveid: HKEY; emessage: boolean);
var
   Registry: TRegistry;
begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_WRITE));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          Registry.WriteCurrency(ItemName, Value);
    finally
      Registry.Free;
    end;
end;

class procedure WinReg.WriteDate(ItemName, KeyLocation: string; Value: TDate;
  hiveid: HKEY; emessage: boolean);
var
   Registry: TRegistry;
begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_WRITE));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          Registry.WriteDate(ItemName, Value);
    finally
      Registry.Free;
    end;
end;

class procedure WinReg.WriteDateTimeValue(ItemName, KeyLocation: string;
  TimeDateValue: TDateTime; hiveid: HKEY; emessage: boolean);
var
   Registry: TRegistry;
 begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_WRITE));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          Registry.WriteDateTime(ItemName, TimeDateValue);
    finally
      Registry.Free;
    end;
end;

class procedure WinReg.WriteFloatValue(ItemName, KeyLocation: string;
  Value: double; hiveid: HKEY; emessage: boolean);
var
   Registry: TRegistry;
begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_WRITE));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          Registry.WriteFloat(ItemName, Value);
    finally
      Registry.Free;
    end;
end;

class procedure WinReg.WriteIntValue(ItemName, KeyLocation: string; Value: integer = 0; hiveid: HKEY = HKEY_LOCAL_MACHINE; emessage: boolean = false);
var
   Registry: TRegistry;
 begin
   Registry := TRegistry.Create(GetAppropriateRegMode(KEY_WRITE));
     Registry.RootKey := hiveid;
     try
        if not Registry.OpenKey(KeyLocation, True) then RaiseLastOSError(Registry.LastError);
          Registry.WriteInteger(ItemName, Value);
    finally
      Registry.Free;
     end;
end;

end.
