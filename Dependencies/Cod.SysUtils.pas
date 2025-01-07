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
  {$IFDEF MSWINDOWS}
  Registry, ShellApi, ActiveX, ComObj, Winapi.shlobj,
  Cod.Registry, Cod.ColorUtils, Vcl.Imaging.pngimage,
  Vcl.Graphics, Winapi.Windows, Vcl.Controls, Vcl.Themes, Vcl.Forms,
  Winapi.Messages,
  {$ENDIF}
  System.SysUtils, System.Classes, Types, IOUtils,
  Variants, System.TypInfo, Cod.MesssageConst, IniFiles;

  type
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

  { Forms }
  {$IFNDEF CONSOLE}
  procedure CenterFormInForm(form, primaryform: TForm; alsoopen: boolean = false);
  procedure CenterFormOnScreen(form: TForm);
  procedure ChangeMainForm(NewForm: TForm);
  function MouseAboveForm(form: TForm): boolean;
  procedure FormPositionSettings(Form: TForm; FileName: string; Load: boolean;
    Closing: boolean = true);
  procedure PrepareCustomTitleBar(var TitleBar: TForm; const Background: TColor; Foreground: TColor);
  procedure OpenFormSystemMenu(Form: TForm);
  procedure SetFormAllowClose(Form: TForm; Allow: boolean);
  {$ENDIF}

  { Exceptions }
  procedure AssertCon(Condition: boolean; Message: string);

  { Application }
  ///  <summary> Get parameter by index </summary>
  function GetParameter(Index: integer): string; overload; // get parameter by index
  ///  <summary> Get all parameters as string </summary>
  function GetParameters: string;
  ///  <summary>
  ///    Check for a Parameter, takes parameter as "value" without shell prefix, return index position
  ///  </summary>
  function FindParameter(Value: string): integer; overload;
  ///  <summary>
  ///    Check for a Parameter, takes parameter as "value" without shell prefix
  ///  </summary>
  function HasParameter(Value: string): boolean; overload;
  ///  <summary> Get value of the following param of the requested value </summary>
  function GetParameterValue(Value: string): string; overload;
  {$IFDEF POSIX}
  ///  <summary>
  ///    Check for a single char Unix parameter, return index position
  ///  </summary>
  function FindParameter(Value: char): integer; overload;
  ///  <summary> Check for a single char Unix parameter </summary>
  function HasParameter(Value: char): boolean; overload;
  ///  <summary> Get single char Unix parameter value </summary>
  function GetParameterValue(Value: char): string; overload;
  ///  <summary>
  ///    Check for a Unix Parameter alternative, either string or singlechar, return index position
  ///  </summary>
  function FindParameter(Value: string; AltChar: char): integer; overload;
  ///  <summary> Check for a Unix Parameter alternative, either string or singlechar </summary>
  function HasParameter(Value: string; AltChar: char): boolean; overload;
  ///  <summary> Gets the unix parameter, than returns the value </summary>
  function GetParameterValue(Value: string; AltChar: char): string; overload;
  {$ENDIF}

  { Objects }
  procedure CopyObject(ObjFrom, ObjTo: TObject);
  procedure ResetPropertyValues(const AObject: TObject);
  procedure SetProperty(const AObject: TObject; PropertyName, NewValue: string); overload;
  procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: integer); overload;
  procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: boolean); overload;
  procedure SetStringProperty(const AObject: TObject; PropertyName, NewValue: string);
  procedure SetIntegerProperty(const AObject: TObject; PropertyName: string; NewValue: integer);
  procedure SetBooleanProperty(const AObject: TObject; PropertyName: string; NewValue: boolean);

  { File Associations }
  {$IFDEF MSWINDOWS}
  procedure RegisterFileType( FileExt: String; FileTypeDescription: String;
    ICONResourceFileFullPath: String; ApplicationFullPath: String;
    OnlyForCurrentUser: boolean = true);
  procedure UnregisterFileType(FileExt: String; OnlyForCurrentUser: boolean = true);
  function FileTypeExists(FileExt: String; OnlyForCurrentUser: boolean = true): boolean;
  function GetFileTypeAssociation(FileExt: String; var ADesc, AIcon: string;
    OnlyForCurrentUser: boolean = true): string;
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  function GetGenericFileType( AExtension: string ): string;
  function GetGenericIconIndex( AExtension: string ): integer;
  function GetShellFileIcon(const AExtension: string; ALargeIcon: Boolean = true): TIcon;
  function GetGenericFileIcon( AExtension: string; ALargeIcon: boolean = true ): TIcon;
  {$ENDIF}

  { Shell }
  {$IFDEF MSWINDOWS}
  procedure ShellRun(Command: string; Show: boolean; Parameters: string = ''; Administrator: boolean = false; Directory: string = '');
  procedure PowerShellRun(Command: string; ShowConsole: boolean; Administrator: boolean = false; Directory: string = '');
  function PowerShellGetOutput(Command: string; ShowConsole: boolean; WaitFor: boolean = false; WantOutput: boolean = true): TStringList;
  procedure WaitForProgramExecution(CommandLine: string);
  function ExecAndWait(const CommandLine: string) : Boolean;
  {$ENDIF}
  ///  <summary>
  ///  Split command into parameter array as in the UNIX string literal standard.
  ///  </summary>
  function ParameterSplitting(Command: string): TArray<string>;

  {$IFNDEF CONSOLE}
  function GetFormMonitorIndex(Form: TForm): integer;
  {$ENDIF}

  { Paths }
  procedure ExtractIconData(AFilePath: string; var Path: string; out IconIndex: word);
  // Same as above, but with checks for if a file contains ","
  procedure ExtractIconDataEx(AFilePath: string; var Path: string; out IconIndex: word);

  { File }
  {$IFDEF MSWINDOWS}
  function GetAllFileProperties(filename: string; allowempty: boolean = true): TStringList;
  function GetFileProperty(FileName, PropertyName: string): string;
  //External
  function GetAllFileVersionInfo(FileName: string): TFileVersionInfo;
  function GetFileOwner(const AFileName : string) : string;
  {$ENDIF}

  { Misc }
  {$IFDEF MSWINDOWS}
  ///  <summary>
  ///    Check if the UI components are running in the IDE form
  ///  </summary>
  function IsInIDE: boolean;
  {$ENDIF}

const
  PARAM_PREFIX = {$IFDEF MSWINDOWS}'-'{$ELSE}'--'{$ENDIF};
  {$IFDEF POSIX}
  PARAM_PREFIX_CHAR = '-';
  {$ENDIF}

implementation

{$IFNDEF CONSOLE}
procedure CenterFormInForm(form, primaryform: TForm; alsoopen: boolean);
begin
  if form.Position <> poDesigned then
    form.Position := poDesigned;

  form.Left := primaryform.Left + primaryform.Width div 2 -form.Width div 2;
  form.Top := primaryform.Top + primaryform.Height div 2 -form.Height div 2;

  if alsoopen then
    form.Show;
end;

procedure CenterFormOnScreen(form: TForm);
begin
  form.Left := Screen.Width div 2 - form.Width div 2;
  form.Top := Screen.Height div 2 - form.Height div 2;
end;

procedure ChangeMainForm(NewForm: TForm);
begin
  Pointer((@Application.MainForm)^) := NewForm;
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

procedure FormPositionSettings(Form: TForm; FileName: string;
  Load, Closing: boolean);
const
  SECT_DAT = 'Positions';
var
  Ini: TIniFile;

  // Previous
  PrevState: TWindowState;
  PrevValue: byte;
  PrevEn: boolean;
begin
  with Form do
    begin
      if Load and not TFile.Exists(FileName) then
        begin
          Left := (Screen.Width - Width) div 2;
          Top := (Screen.Height - Height) div 2;
        end;

      Ini := TIniFile.Create(FileName);
      with Ini do
        try
          if Load then
            begin
              WindowState := TWindowState.wsNormal;
              if Form.Position <> poDesigned then
                Form.Position := poDesigned; // ensure designed

              Left := ReadInteger(SECT_DAT, 'Left', Left);
              Top := ReadInteger(SECT_DAT, 'Top', Top);
              Width := ReadInteger(SECT_DAT, 'Width', Width);
              Height := ReadInteger(SECT_DAT, 'Height', Height);

              WindowState := TWindowState(ReadInteger(SECT_DAT, 'State', integer(WindowState)));
              if WindowState = wsMinimized then
                WindowState := wsNormal;
            end
          else
            begin
              PrevEn := false;
              PrevValue := 255;

              WriteInteger(SECT_DAT, 'State', integer(WindowState));
              if WindowState = wsMinimized then
                begin
                  PrevEn := AlphaBlend;
                  PrevValue := AlphaBlendValue;

                  AlphaBlend := true;
                  AlphaBlendValue := 0;
                end;
              PrevState := WindowState;
              WindowState := TWindowState.wsNormal;

              WriteInteger(SECT_DAT, 'Left', Left);
              WriteInteger(SECT_DAT, 'Top', Top);
              WriteInteger(SECT_DAT, 'Width', Width);
              WriteInteger(SECT_DAT, 'Height', Height);

              // Revert
              if not Closing then
                begin
                  WindowState := PrevState;
                  if WindowState = wsMinimized then
                    begin
                      AlphaBlend := PrevEn;
                      AlphaBlendValue := PrevValue;
                    end;
                end;
            end;
        finally
          Free;
        end;
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

procedure OpenFormSystemMenu(Form: TForm);
var
  Handle: HMENU;
  MousePos: TPoint;
  cmd: integer;
function EnableBool(Value: boolean): UINT;
begin
  if Value then
    Result := MF_BYCOMMAND or MF_ENABLED
  else
    Result := MF_BYCOMMAND or MF_GRAYED;
end;
begin
  MousePos := Mouse.CursorPos;

  // Get the handle to the system menu
  Handle := GetSystemMenu(Form.Handle, False);

  // Enable / disable the items
  EnableMenuItem(Handle, SC_RESTORE,
    EnableBool((Form.WindowState = TWindowState.wsMaximized) and (biMaximize in Form.BorderIcons))
    );
  EnableMenuItem(Handle, SC_MOVE, EnableBool(Form.WindowState <> TWindowState.wsMaximized));
  EnableMenuItem(Handle, SC_SIZE,
    EnableBool((Form.WindowState <> TWindowState.wsMaximized) and (Form.BorderStyle in [bsSizeable, bsSizeToolWin]))
    );

  EnableMenuItem(Handle, SC_MAXIMIZE,
    EnableBool((Form.WindowState <> TWindowState.wsMaximized) and (biMaximize in Form.BorderIcons) and (Form.BorderStyle in [bsSizeable, bsSingle]))
  );
  EnableMenuItem(Handle, SC_MINIMIZE,
    EnableBool((Form.WindowState <> TWindowState.wsMinimized) and (biMinimize in Form.BorderIcons) and (Form.BorderStyle in [bsSizeable, bsSingle, bsDialog]))
  );

  // Get CMD
  cmd := Integer(
    TrackPopupMenu(Handle, TPM_RETURNCMD or TPM_LEFTALIGN or TPM_TOPALIGN, MousePos.X, MousePos.Y, 0,
      Form.Handle, nil)
    );

  // If a valid command is selected, send it to the system for default processing
  if cmd <> 0 then
    SendMessage(Form.Handle, WM_SYSCOMMAND, cmd, 0);
end;

procedure SetFormAllowClose(Form: TForm; Allow: boolean);
var
  Handle: HMENU;
function EnableBool(Value: boolean): UINT;
begin
  if Value then
    Result := MF_BYCOMMAND or MF_ENABLED
  else
    Result := MF_BYCOMMAND or MF_GRAYED;
end;
begin
  // Get the handle to the system menu
  Handle := GetSystemMenu(Form.Handle, False);

  // Set
  EnableMenuItem(Handle, SC_CLOSE, EnableBool(Allow) );
end;
{$ENDIF}

procedure AssertCon(Condition: boolean; Message: string);
begin
  if not Condition then
    raise Exception.Create(Message);
end;

{$IFDEF MSWINDOWS}
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

function FileTypeExists(FileExt: String;
  OnlyForCurrentUser: boolean): boolean;
var
  key: HKEY;
  Reg: TWinRegistry;
begin
  if OnlyForCurrentUser then
    key := HKEY_CURRENT_USER
  else
    key := HKEY_LOCAL_MACHINE;

  Result := false;

  Reg := TWinRegistry.Create;
  try
    Reg.ManualHive := key;
    if
      Reg.KeyExists('\Software\Classes\.' + FileExt) AND
      Reg.KeyExists('\Software\Classes\' + FileExt + 'File')
    then Result := true;
  finally
    Reg.Free;
  end;
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
{$ENDIF}

{$IFDEF MSWINDOWS}
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

function GetShellFileIcon(const AExtension: string; ALargeIcon: Boolean): TIcon;
{ This is a work in progress, It should get image thumbnails for video and images }
var
  AInfo: TSHFileInfo;
  AIcon: TIcon;
  AFlags: Integer;
begin
  AFlags := SHGFI_ICON or SHGFI_USEFILEATTRIBUTES or SHGFI_TYPENAME or SHGFI_ICONLOCATION;
  if ALargeIcon then
    AFlags := AFlags or SHGFI_LARGEICON
  else
    AFlags := AFlags or SHGFI_SMALLICON;

  if SHGetFileInfo(PChar(AExtension), FILE_ATTRIBUTE_NORMAL, AInfo, SizeOf(AInfo), AFlags) <> 0 then
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
{$ENDIF}

{$IFNDEF CONSOLE}
function GetFormMonitorIndex(Form: TForm): integer;
var
  I: Integer;
  CenterPosition: TPoint;
begin
  // Default
  Result := Screen.PrimaryMonitor.MonitorNum;

  // Position
  CenterPosition := Point(Form.Left + Form.Width div 2, Form.Top + Form.Height div 2);

  // Scan Monitors
  for I := 0 to Screen.MonitorCount -1 do
    if Screen.Monitors[I].BoundsRect.Contains( CenterPosition ) then
      Exit( Screen.Monitors[I].MonitorNum );
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
procedure ShellRun(Command: string; Show: boolean; Parameters: string; Administrator: boolean; Directory: string);
var
  OperationType: string;
  Parameter: integer;
begin
  if Administrator then
    OperationType := 'runas'
  else
    OperationType := 'open';

  if Show then
    Parameter := SW_NORMAL
  else
    Parameter := SW_HIDE;

  ShellExecute(0, PChar(OperationType), PChar(Command), PChar(Parameters), PChar(Directory), Parameter);
end;

procedure PowerShellRun(Command: string; ShowConsole: boolean; Administrator: boolean; Directory: string);
var
  Parameter: integer;
  OperationType: string;

  ShellParams: string;
begin
  // Settings
  if Administrator then
    OperationType := 'runas'
  else
    OperationType := 'open';

  if ShowConsole then
    Parameter := SW_NORMAL
  else
    Parameter := SW_HIDE;

  // Replace quote mark
  Command := Command.Replace('"', #$27);

  // As Param
  ShellParams := '-c "' + Command + '"';

  ShellExecute(0, PChar(OperationType), 'powershell', PChar(ShellParams), PChar(Directory), Parameter);
end;

function PowerShellGetOutput(Command: string; ShowConsole, WaitFor, WantOutput: boolean): TStringList;
const
    READ_BUFFER_SIZE = 2400;
var
    Security: TSecurityAttributes;
    readableEndOfPipe, writeableEndOfPipe: THandle;
    start: TStartUpInfo;
    ProcessInfo: TProcessInformation;
    Buffer: PAnsiChar;
    BytesRead: DWORD;
    AppRunning: DWORD;
    DosApp: string;
begin
    Security.nLength := SizeOf(TSecurityAttributes);
    Security.bInheritHandle := True;
    Security.lpSecurityDescriptor := nil;

    // Prepare Executable
    DosApp := 'powershell -c "' + Command.Replace('"', #$27) + '"';

    // Output
    Result := TStringList.Create;

    if CreatePipe({var}readableEndOfPipe, {var}writeableEndOfPipe, @Security, 0) then
    begin
        Buffer := AllocMem(READ_BUFFER_SIZE+1);
        FillChar(Start, Sizeof(Start), #0);
        start.cb := SizeOf(start);

        // Set up members of the STARTUPINFO structure.
        // This structure specifies the STDIN and STDOUT handles for redirection.
        // - Redirect the output and error to the writeable end of our pipe.
        // - We must still supply a valid StdInput handle (because we used STARTF_USESTDHANDLES to swear that all three handles will be valid)
        start.dwFlags := start.dwFlags or STARTF_USESTDHANDLES;
        start.hStdInput := GetStdHandle(STD_INPUT_HANDLE); //we're not redirecting stdInput; but we still have to give it a valid handle
        if WantOutput then
          start.hStdOutput := writeableEndOfPipe; //we give the writeable end of the pipe to the child process; we read from the readable end
        start.hStdError := writeableEndOfPipe;

        //We can also choose to say that the wShowWindow member contains a value.
        //In our case we want to force the console window to be hidden.
        start.dwFlags := start.dwFlags + STARTF_USESHOWWINDOW;
        if ShowConsole then
          start.wShowWindow := SW_NORMAL
        else
          start.wShowWindow := SW_HIDE;  // SW_HIDE makes the wait process stuck in a loop!

        // Don't forget to set up members of the PROCESS_INFORMATION structure.
        ProcessInfo := Default(TProcessInformation);

        //WARNING: The unicode version of CreateProcess (CreateProcessW) can modify the command-line "DosApp" string.
        //Therefore "DosApp" cannot be a pointer to read-only memory, or an ACCESS_VIOLATION will occur.
        //We can ensure it's not read-only with the RTL function: UniqueString
        UniqueString({var}DosApp);

        if CreateProcess(nil, PChar(DosApp), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, {var}ProcessInfo) then
        begin
            //Wait for the application to terminate, as it writes it's output to the pipe.
            //WARNING: If the console app outputs more than 2400 bytes (ReadBuffer),
            //it will block on writing to the pipe and *never* close.
            repeat
                Apprunning := WaitForSingleObject(ProcessInfo.hProcess, 100);

                if not WaitFor then
                  Application.ProcessMessages;
            until (Apprunning <> WAIT_TIMEOUT);

            //Read the contents of the pipe out of the readable end
            //WARNING: if the console app never writes anything to the StdOutput, then ReadFile will block and never return
            // If you just want to wait for a process to finish, set WantOutput to false
            if WantOutput then
              repeat
                BytesRead := 0;
                ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE, {var}BytesRead, nil);
                Buffer[BytesRead]:= #0;
                OemToAnsi(Buffer,Buffer);
                Result.Text := Result.text + String(Buffer);
              until (BytesRead < READ_BUFFER_SIZE);
        end;
        FreeMem(Buffer);
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(readableEndOfPipe);
        CloseHandle(writeableEndOfPipe);
    end;
end;

procedure WaitForProgramExecution(CommandLine: string);
const
    READ_BUFFER_SIZE = 2400;
var
    Security: TSecurityAttributes;
    readableEndOfPipe, writeableEndOfPipe: THandle;
    start: TStartUpInfo;
    ProcessInfo: TProcessInformation;
    Buffer: PAnsiChar;
    AppRunning: DWORD;
begin
    Security.nLength := SizeOf(TSecurityAttributes);
    Security.bInheritHandle := True;
    Security.lpSecurityDescriptor := nil;

    if CreatePipe({var}readableEndOfPipe, {var}writeableEndOfPipe, @Security, 0) then
    begin
        Buffer := AllocMem(READ_BUFFER_SIZE+1);
        FillChar(Start, Sizeof(Start), #0);
        start.cb := SizeOf(start);

        // Set up members of the STARTUPINFO structure.
        // This structure specifies the STDIN and STDOUT handles for redirection.
        // - Redirect the output and error to the writeable end of our pipe.
        // - We must still supply a valid StdInput handle (because we used STARTF_USESTDHANDLES to swear that all three handles will be valid)
        start.dwFlags := start.dwFlags or STARTF_USESTDHANDLES;
        start.hStdInput := GetStdHandle(STD_INPUT_HANDLE); //we're not redirecting stdInput; but we still have to give it a valid handle
        start.hStdOutput := writeableEndOfPipe; //we give the writeable end of the pipe to the child process; we read from the readable end
        start.hStdError := writeableEndOfPipe;

        start.dwFlags := start.dwFlags + STARTF_USESHOWWINDOW;
        start.wShowWindow := SW_HIDE;

        ProcessInfo := Default(TProcessInformation);

        UniqueString({var}CommandLine);

        if CreateProcess(nil, PChar(CommandLine), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, {var}ProcessInfo) then
        begin
            //Wait for the application to terminate, as it writes it's output to the pipe.
            //WARNING: If the console app outputs more than 2400 bytes (ReadBuffer),
            //it will block on writing to the pipe and *never* close.
            repeat
                Apprunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
            until (Apprunning <> WAIT_TIMEOUT);
        end;
        FreeMem(Buffer);
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(readableEndOfPipe);
        CloseHandle(writeableEndOfPipe);
    end;
end;

function ExecAndWait(const CommandLine: string) : Boolean;
var
  StartupInfo: TStartupInfo;        // start-up info passed to process
  ProcessInfo: TProcessInformation; // info about the process
  ProcessExitCode: DWord;           // process's exit code
begin
  // Set default error result
  Result := False;
  // Initialise startup info structure to 0, and record length
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  // Execute application commandline
  if CreateProcess(nil, PChar(CommandLine),
    nil, nil, False, 0, nil, nil,
    StartupInfo, ProcessInfo) then
  begin
    try
      // Now wait for application to complete
      if WaitForSingleObject(ProcessInfo.hProcess, INFINITE)
        = WAIT_OBJECT_0 then
        // It's completed - get its exit code
        if GetExitCodeProcess(ProcessInfo.hProcess,
          ProcessExitCode) then
          // Check exit code is zero => successful completion
          if ProcessExitCode = 0 then
            Result := True;
    finally
      // Tidy up
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;
  end;
end;
{$ENDIF}

function ParameterSplitting(Command: string): TArray<string>;
var
  P: integer;
  Position: integer;

  LayerDoubleType: boolean;
  TrimSize: integer;

procedure Cut;
begin
  // New entry
  if Position > 0 then begin
    const Index = Length(Result);
    SetLength(Result, Index+1);
    Result[Index] := Command.Substring(TrimSize, Position-TrimSize);

    if LayerDoubleType then
      Result[Index] := Result[Index].Replace('\"', '"');
  end;

  // Remove
  Command := Command.Substring(Position+1); // exclude char

  // Move
  Position := 0;
end;
function CalculateLiteral(Character: char): boolean;
var
  Finalised: boolean;
begin
  Result := false;
  if Command.Chars[0] = Character then begin
    P := 0;
    repeat
      P := Command.IndexOf(Character, P+1);
      Finalised := (P=-1) or (Character = #39) or (Command.Chars[P-1] <> '\');
    until Finalised;

    // Found suited
    if P <> -1 then begin
      LayerDoubleType := Character = '"';

      Position := P;
      TrimSize := 1;
      Result := true;
    end;
  end;
end;
begin
  Result := [];
  repeat
    TrimSize := 0;
    LayerDoubleType := false;

    // Get next space
    Position := Command.IndexOf(' ');
    if Position = -1 then
      Position := Command.Length;

    // Calculate if is string literal
    if not CalculateLiteral('"') then
      CalculateLiteral(#39);

    // Cut data
    Cut;
  until Command = '';
end;

function GetParameter(Index: integer): string;
begin
  Result := ParamStr(Index);

  {$IFDEF MSWINDOWS}
  // Fix WinNT
  if (Result[1] = '/') then
    Result[1] := '-';
  {$ENDIF}
end;

function GetParameters: string;
var
  I: Integer;
  Parameter: string;
  ACount: integer;
begin
  ACount := ParamCount;
  for I := 1 to ParamCount do
    begin
      Parameter := GetParameter(I);

      if Parameter.IndexOf(' ') <> -1 then
        Parameter := Format('"%S"', [Parameter]);

      Result := Result + Parameter;
      if I <> ACount then
        Result := Result + ' ';
    end;
end;

function FindParameter(Value: string): integer;
var
  S: string;
begin
  Result := -1;
  for var I := 1 to ParamCount do
    begin
      S := GetParameter(I);
      if (Length(S) < Length(PARAM_PREFIX)+1) or (Copy(S, 1, Length(PARAM_PREFIX)) <> PARAM_PREFIX) then
        Continue;

      // Remove prefix
      S := S.Remove(0, Length(PARAM_PREFIX));
      {$IFDEF MSWINDOWS}
      // Ignore casing
      S := Lowercase(S);
      {$ENDIF}

      // Check for equalitry
      if S = Value then
        Exit( I );
    end;
end;

function HasParameter(Value: string): boolean; overload;
begin
  Result := FindParameter( Value ) <> -1;
end;

function GetParameterValue(Value: string): string; overload;
begin
  const Index = FindParameter( Value );
  Result := GetParameter(Index+1);
end;

{$IFDEF POSIX}
function FindParameter(Value: char): integer;
var
  S: string;
begin
  Result := -1;
  for var I := 1 to ParamCount do
    begin
      S := GetParameter(I);
      if (Length(S) < Length(PARAM_PREFIX_CHAR)+1)
        or (Copy(S, 1, Length(PARAM_PREFIX_CHAR)) <> PARAM_PREFIX_CHAR)
        or (Copy(S, 1, Length(PARAM_PREFIX)) = PARAM_PREFIX) then
        Continue;

      // Remove prefix
      S := S.Remove(0, Length(PARAM_PREFIX_CHAR));

      // Check for char in list of chars
      if S.IndexOf( Value ) <> -1 then
        Exit( I );
    end;
end;

function HasParameter(Value: char): boolean; overload;
begin
  Result := FindParameter( Value ) <> -1;
end;

function GetParameterValue(Value: char): string; overload;
begin
  const Index = FindParameter( Value );
  Result := GetParameter(Index+1);
end;

function FindParameter(Value: string; AltChar: char): integer;
begin
  Result := FindParameter( Value );
  if Result <> -1 then
    Exit;
  Result := FindParameter( AltChar );
end;

function HasParameter(Value: string; AltChar: char): boolean; overload;
begin
  Result := FindParameter( Value, AltChar ) <> -1;
end;

function GetParameterValue(Value: string; AltChar: char): string; overload;
begin
  const Index = FindParameter( Value, AltChar );
  Result := GetParameter(Index+1);
end;
{$ENDIF}

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

{$IFDEF MSWINDOWS}
function IsInIDE: boolean;
begin
  if TStyleManager.ActiveStyle.Name = 'Mountain_Mist' then
    Result := true
  else
    Result := false;
end;
{$ENDIF}

procedure ExtractIconData(AFilePath: string; var Path: string; out IconIndex: word);
var
  Directory: string;
  FileName: string;

  Index: integer;
  O: integer;
begin
  FileName := ExtractFileName(AFilePath);

  // Extract position
  Index := FileName.LastIndexOf(',');

  // Index embedeed
  if (Index = -1) or not TryStrToInt(FileName.Substring(Index+1).Replace(' ', ''), O) then begin
    Path := AFilePath;
    IconIndex := 0;
    Exit;
  end;
  IconIndex := O;

  // Remove rest
  Directory := ExtractFileDir(AFilePath);
  if Directory <> '' then
    Directory := IncludeTrailingPathDelimiter(Directory);
  Path := Directory + FileName.Substring(0, Index); // I is the position, so no need for -1
end;

procedure ExtractIconDataEx(AFilePath: string; var Path: string; out IconIndex: word);
begin
  // Load
  if TFile.Exists(AFilePath) then begin
    Path := AFilePath;
    IconIndex := 0;
  end
    else
      ExtractIconData(AFilePath, Path, IconIndex);
end;

{$IFDEF MSWINDOWS}
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
  Result := NOT_FOUND;

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
    Result := NOT_DEFINED;
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
{$ENDIF}

end.
