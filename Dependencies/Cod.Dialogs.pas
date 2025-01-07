unit Cod.Dialogs;


interface

  uses
    Cod.Files, Windows, Vcl.Dialogs, Cod.Visual.Button, UITypes, Types, Classes, Variants, Vcl.Graphics,
    Vcl.Forms, Vcl.StdCtrls, Cod.Visual.StandardIcons, Vcl.Themes, Vcl.Styles,
    Vcl.Controls, Cod.Components, Cod.ColorUtils, SysUtils, Vcl.ExtCtrls,
    Vcl.TitleBarCtrls, Cod.SysUtils, Math, Cod.Math, Vcl.ComCtrls,
    Cod.Windows;

  type
    CMessageType = (ctInformation, ctError, ctCritical, ctQuestion, ctSucess, ctWarning, ctStar);
    CInputBoxResult = (cidrCancel, cidrOk);

    CButtonHelper = class helper for CButton
      procedure ApplyButtonSettings(LoadFromButton: CButton);
    end;

    CDialogBox = class
      private
        FTitle: string;
        FText: string;
        FTextFont: TFont;
        FButtonDesign: CButton;
        FFormColor: TColor;
        FFooterColor: TColor;
        FEnableFooter: boolean;
        FToggleGlobalSync: boolean;
        FAutoTextAdjust: boolean;

        FTitlebarHeight: integer;
        FButtonOffset: integer;
        FButtonHeight: integer;

        // Settings
        PromptCreation: boolean;
        ExtraSpacingUnits: integer;
        DialogUnits: TPoint;
        HasButtons: boolean;

        // Inherited Creation
        Form: TForm;
        Prompt,
        Footer: TLabel;

        // Settings
        function ApplyTitleBarSettings(Form: TForm; FormColor: TColor; EnableButtons: boolean): integer;

        // Utils
        function GetTextWidth(Text: string; Font: TFont): integer;
        function GetButonWidth(Text: string; Font: TFont): integer;
        function CalculateButtonHeight: integer;

        function ButtonTypeToModal(AType: TMsgDlgBtn): integer;
        function ButtonTypeToIcon(AType: TMsgDlgBtn): CButtonIcon;

        procedure ResizeForm(NewWidth: integer = -1; NewHeight: integer = -1);

        procedure CreateButtons(Buttons: TMsgDlgButtons);
        function FindButton(ModalResult: integer): CButton;

        function GetCharSize(Canvas: TCanvas): TPoint;
        procedure SetFooterColor(const Value: TColor);

      public
        // Public Settings
        CustomFooterColor: boolean;

        constructor Create; virtual;
        destructor Destroy; override;

        // Settings
        procedure SetButtonColor( AColor: TColor );

        // Execute
        procedure ExecuteInherited; virtual;
        function ModalExecution(FreeMem: boolean = true): integer;

        procedure FreeForm;

        property Title: string read FTitle write FTitle;
        property Text: string read FText write FText;
        property TextFont: TFont read FTextFont write FTextFont;
        property AutoTextAdjust: boolean read FAutoTextAdjust write FAutoTextAdjust;
        property ButtonDesign: CButton read FButtonDesign write FButtonDesign;
        property FormColor: TColor read FFormColor write FFormColor;
        property FooterColor: TColor read FFooterColor write SetFooterColor;
        property GlobalSyncTogle: boolean read FToggleGlobalSync write FToggleGlobalSync;
        property EnableFooter: boolean read FEnableFooter write FEnableFooter;
    end;

    CMessageBox = class(CDialogBox)
      private


      public
        constructor Create; override;
        destructor Destroy; override;

        procedure Execute; overload;
    end;

    CDialog = class(CDialogBox)
      private
        FKind: CMessageType;
        FButtons: TMsgDlgButtons;

        ImageHeight: integer;

      public
        constructor Create; override;
        destructor Destroy; override;

        function Execute: integer; overload;

        property Kind: CMessageType read FKind write FKind;
        property Buttons: TMsgDlgButtons read FButtons write FButtons;
    end;

    CInputBox = class(CDialogBox)
      private
        FValue: string;
        FCanCancel: boolean;
        FNumbersOnly: boolean;
        FPasswordChar: char;

      public
        DialogResult: CInputBoxResult;

        constructor Create; override;
        destructor Destroy; override;

        function Execute: string; overload;

        property Value: string read FValue write FValue;
        property CanCancel: boolean read FCanCancel write FCanCancel;
        property PasswordChar: char read FPasswordChar write FPasswordChar;
        property NumbersOnly: boolean read FNumbersOnly write FNumbersOnly;
    end;

    CMemoBox = class(CDialogBox)
      private
        FValue: TStringList;
        FCanCancel: boolean;
        FBoxWidth, FBoxHeight: integer;
    function GetAsText: string;
    procedure SetAsText(const Value: string);

      public
        DialogResult: CInputBoxResult;

        constructor Create; override;
        destructor Destroy; override;

        function Execute: boolean; overload;

        property Text: string read GetAsText write SetAsText;

        property Value: TStringList read FValue write FValue;
        property CanCancel: boolean read FCanCancel write FCanCancel;
        property BoxWidth: integer read FBoxWidth write FBoxWidth;
        property BoxHeight: integer read FBoxHeight write FBoxHeight;
    end;

    CInputBoxDialog = class(CDialogBox)
      private
        FValues: TStringList;
        FCanCancel: boolean;
        FDropStyle: TComboBoxStyle;

      public
        DialogResult: CInputBoxResult;

        SelectedIndex: integer;
        SelectedText: string;

        constructor Create; override;
        destructor Destroy; override;

        function Execute: integer; overload;

        property DropDownStyle: TComboBoxStyle read FDropStyle write FDropStyle;

        property Values: TStringList read FValues write FValues;
        property CanCancel: boolean read FCanCancel write FCanCancel;
    end;

    CRadioDialog = class(CDialogBox)
      private
        FItems: TStringList;
        FCanCancel: boolean;
        FSelectFirst: boolean;

      public
        DialogResult: CInputBoxResult;

        SelectedIndex: integer;
        SelectedText: string;

        constructor Create; override;
        destructor Destroy; override;

        function Execute: integer; overload;

        property Items: TStringList read FItems write FItems;
        property CanCancel: boolean read FCanCancel write FCanCancel;
        property SelectFirst: boolean read FSelectFirst write FSelectFirst;
    end;

var
  ButtonLabels: TArray<string> =
                        [
                        'Yes',        // Yes
                        'No',         // No
                        'Ok',         // Ok
                        'Cancel',     // Cancel
                        'Abort',      // Abort
                        'Retry',      // Retry
                        'Ignore',     // Ignore
                        'All',        // All
                        'Yes to All', // YesAll
                        'No to All',  // NoAll
                        'Help',       // Help
                        'Close'       //Close
                        ];


  function CodDialog(const Title, Text: string; Kind: CMessageType = ctInformation;
                       Buttons: TMsgDlgButtons = [mbOk]; ButtonPreset:
                       CButtonPreset = cbprCustom; FormColor: TColor = clWindow;
                       AllowFooter: boolean = true; BtColor: TColor = -1;
                       GlobalSyncToggle: boolean = false): integer;

  procedure CodMessage(const Title, Text: string; ButtonPreset:
                        CButtonPreset = cbprCustom; FormColor: TColor = clWindow;
                        AllowFooter: boolean = true; BtColor: TColor = -1;
                        GlobalSyncToggle: boolean = false);

  procedure CMessage(Text: string = 'Hello World!');

  function CodInput(const Title, Text: string; Value: string = '';
                      CanCancel: boolean = true; NumbersOnly:
                      boolean = false; PasswordChar: char = #0;
                      ButtonPreset: CButtonPreset = cbprCustom;
                      FormColor: TColor = clWindow; AllowFooter: boolean = true;
                      BtColor: TColor = -1;
                      GlobalSyncToggle: boolean = false): string;

  function CodInputQuery(const Title, Text: string; var Value: string; const
                      CanCancel: boolean = true; NumbersOnly:
                      boolean = false; PasswordChar: char = #0;
                      ButtonPreset: CButtonPreset = cbprCustom;
                      FormColor: TColor = clWindow; AllowFooter: boolean = true;
                      BtColor: TColor = -1;
                      GlobalSyncToggle: boolean = false): boolean;

  function CodDropDown(const Title, Text: string; Strings: TStringList; const
                      CanCancel: boolean = true; ButtonPreset: CButtonPreset = cbprCustom;
                      FormColor: TColor = clWindow; AllowFooter: boolean = true;
                      BtColor: TColor = -1; GlobalSyncToggle: boolean = false): integer;

  function CodRadioDialog(const Title, Text: string; Strings: TStringList; const
                      CanCancel: boolean = true; ButtonPreset: CButtonPreset = cbprCustom;
                      FormColor: TColor = clWindow; AllowFooter: boolean = true;
                      BtColor: TColor = -1; GlobalSyncToggle: boolean = false): integer;

implementation

function CodDialog(const Title, Text: string; Kind: CMessageType;
  Buttons: TMsgDlgButtons; ButtonPreset: CButtonPreset; FormColor: TColor;
  AllowFooter: boolean; BtColor: TColor; GlobalSyncToggle: boolean): integer;
var
  Dialog: CDialog;
begin
  Dialog := CDialog.Create;

  // Text
  Dialog.Title := Title;
  Dialog.Text := Text;

  // Colors & Design
  Dialog.EnableFooter := AllowFooter;
  Dialog.GlobalSyncTogle := GlobalSyncToggle;

  Dialog.FormColor := FormColor;
  Dialog.TextFont.Color := FontColorForBackground( FormColor );

  if BtColor <> -1 then
    Dialog.SetButtonColor( BtColor );
  Dialog.ButtonDesign.Preset.Kind := ButtonPreset;
  Dialog.ButtonDesign.Preset.Color := BtColor;

  // Dialog
  Dialog.Buttons := Buttons;
  Dialog.Kind := Kind;

  // Execute
  Result := Dialog.Execute;

  Dialog.Free;
end;

procedure CodMessage(const Title, Text: string; ButtonPreset:
  CButtonPreset; FormColor: TColor; AllowFooter: boolean; BtColor: TColor;
  GlobalSyncToggle: boolean);
var
  Dialog: CMessageBox;
begin
  Dialog := CMessageBox.Create;

  // Text
  Dialog.Title := Title;
  Dialog.Text := Text;

  // Colors & Design
  Dialog.EnableFooter := AllowFooter;
  Dialog.GlobalSyncTogle := GlobalSyncToggle;

  Dialog.FormColor := FormColor;
  Dialog.TextFont.Color := FontColorForBackground( FormColor );


  if BtColor <> -1 then
    Dialog.SetButtonColor( BtColor );
  Dialog.ButtonDesign.Preset.Kind := ButtonPreset;
  Dialog.ButtonDesign.Preset.Color := BtColor;

  // Execute
  Dialog.Execute;

  Dialog.Free;
end;


procedure CMessage(Text: string);
begin
  CodMessage('Message', Text);
end;

function CodInput(const Title, Text: string; Value: string;
  CanCancel: boolean; NumbersOnly: boolean; PasswordChar: char;
  ButtonPreset: CButtonPreset; FormColor: TColor; AllowFooter: boolean;
  BtColor: TColor; GlobalSyncToggle: boolean): string;
var
  Dialog: CInputBox;
begin
  Dialog := CInputBox.Create;

  // Text
  Dialog.Title := Title;
  Dialog.Text := Text;

  // Colors & Design
  Dialog.EnableFooter := AllowFooter;
  Dialog.GlobalSyncTogle := GlobalSyncToggle;

  Dialog.FormColor := FormColor;
  Dialog.TextFont.Color := FontColorForBackground( FormColor );


  if BtColor <> -1 then
    Dialog.SetButtonColor( BtColor );
  Dialog.ButtonDesign.Preset.Kind := ButtonPreset;
  Dialog.ButtonDesign.Preset.Color := BtColor;

  // Dialog
  Dialog.FCanCancel := CanCancel;
  Dialog.FValue := Value;
  Dialog.FNumbersOnly := NumbersOnly;
  Dialog.PasswordChar := PasswordChar;

  // Execute
  Result := Dialog.Execute;

  Dialog.Free;
end;

function CodInputQuery(const Title, Text: string; var Value: string; const
  CanCancel: boolean; NumbersOnly: boolean; PasswordChar: char;
  ButtonPreset: CButtonPreset; FormColor: TColor; AllowFooter: boolean;
  BtColor: TColor; GlobalSyncToggle: boolean): boolean;
var
  Dialog: CInputBox;

  TextResult: string;
begin
  Dialog := CInputBox.Create;

  // Text
  Dialog.Title := Title;
  Dialog.Text := Text;

  // Colors & Design
  Dialog.EnableFooter := AllowFooter;
  Dialog.GlobalSyncTogle := GlobalSyncToggle;

  Dialog.FormColor := FormColor;
  Dialog.TextFont.Color := FontColorForBackground( FormColor );


  if BtColor <> -1 then
    Dialog.SetButtonColor( BtColor );
  Dialog.ButtonDesign.Preset.Kind := ButtonPreset;
  Dialog.ButtonDesign.Preset.Color := BtColor;

  // Dialog
  Dialog.FCanCancel := CanCancel;
  Dialog.FValue := Value;
  Dialog.FNumbersOnly := NumbersOnly;
  Dialog.PasswordChar := PasswordChar;

  // Execute
  TextResult := Dialog.Execute;
  Result := Dialog.DialogResult = cidrOk;

  if Result then
    Value := TextResult;

  Dialog.Free;
end;

function CodDropDown(const Title, Text: string; Strings: TStringList; const
  CanCancel: boolean; ButtonPreset: CButtonPreset;
  FormColor: TColor; AllowFooter: boolean;
  BtColor: TColor; GlobalSyncToggle: boolean): integer;
var
  Dialog: CInputBoxDialog;
begin
  Dialog := CInputBoxDialog.Create;

  // Text
  Dialog.Title := Title;
  Dialog.Text := Text;

  // Colors & Design
  Dialog.EnableFooter := AllowFooter;
  Dialog.GlobalSyncTogle := GlobalSyncToggle;

  Dialog.FormColor := FormColor;
  Dialog.TextFont.Color := FontColorForBackground( FormColor );

  Dialog.CanCancel := CanCancel;
  Dialog.Values.Assign( Strings );

  if BtColor <> -1 then
    Dialog.SetButtonColor( BtColor );
  Dialog.ButtonDesign.Preset.Kind := ButtonPreset;
  Dialog.ButtonDesign.Preset.Color := BtColor;

  // Execute
  Result := Dialog.Execute;

  Dialog.Free;
end;

function CodRadioDialog(const Title, Text: string; Strings: TStringList; const
  CanCancel: boolean; ButtonPreset: CButtonPreset;
  FormColor: TColor; AllowFooter: boolean;
  BtColor: TColor; GlobalSyncToggle: boolean): integer;
var
  Dialog: CRadioDialog;
begin
  Dialog := CRadioDialog.Create;

  // Text
  Dialog.Title := Title;
  Dialog.Text := Text;

  // Colors & Design
  Dialog.EnableFooter := AllowFooter;
  Dialog.GlobalSyncTogle := GlobalSyncToggle;

  Dialog.FormColor := FormColor;
  Dialog.TextFont.Color := FontColorForBackground( FormColor );

  Dialog.CanCancel := CanCancel;
  Dialog.Items.Assign( Strings );

  if BtColor <> -1 then
    Dialog.SetButtonColor( BtColor );
  Dialog.ButtonDesign.Preset.Kind := ButtonPreset;
  Dialog.ButtonDesign.Preset.Color := BtColor;

  // Execute
  Result := Dialog.Execute;

  Dialog.Free;
end;


{ CDialog }

constructor CDialog.Create;
begin
  inherited;

  FKind := ctInformation;
  FButtons := [mbOk];

  ExtraSpacingUnits := 5;

  ImageHeight := 40;
end;

destructor CDialog.Destroy;
begin
  inherited;
end;

function CDialog.Execute: integer;
var
  InfoIcon: CStandardIcon;
  I: TMsgDlgBtn;
begin
  ExecuteInherited;

  with Form do begin
    // Form Settings
    Form.Constraints.MinHeight := FTitlebarHeight + ImageHeight;

    // Icon
    InfoIcon := CStandardIcon.Create(Form);
    with InfoIcon do
    begin
      Parent   := Form;

      Width := ImageHeight;

      Left     := Prompt.Left;
      Top      := Prompt.Top;

      case kind of
        ctInformation: begin
          MessageBeep(0);
          SelectedIcon := CodIconType.ciconInformation;
        end;

        ctError: begin
          MessageBeep(20);
          SelectedIcon := CodIconType.ciconError;
        end;

        ctCritical: begin
          MessageBeep(20);
          SelectedIcon := CodIconType.ciconStop;
        end;

        ctQuestion: begin
          MessageBeep(70);
          SelectedIcon := CodIconType.ciconQuestion;
        end;

        ctSucess: begin
          MessageBeep(50);
          SelectedIcon := CodIconType.ciconCheckmark;
        end;

        ctWarning: begin
          MessageBeep(50);
          SelectedIcon := CodIconType.ciconWarning;
        end;

        ctStar: begin
          MessageBeep(0);
          SelectedIcon := CodIconType.ciconStar;
        end;
      end;
    end;

    // Offset Prompt
    Prompt.Left := Prompt.Left + ImageHeight + FButtonOffset;
    Prompt.Constraints.MinHeight := ImageHeight;

    // Create Buttons
    CreateButtons( Buttons );

    // Default Buttons
    if mbCancel in Buttons then
      FindButton( mrCancel ).Cancel := true;
    if mbOK in Buttons then
      FindButton( mrOK ).Default := true
        else
          if mbYes in Buttons then
            FindButton( mrYes ).Default := true;
              if mbAll in Buttons then
                FindButton( mrAll ).Default := true
                  else
                    if mbYesToAll in Buttons then
                      FindButton( mrYesToALl ).Default := true
                        else
                          begin
                            for I in Buttons do
                              begin
                                FindButton( ButtonTypeToModal(I) ).Default := true;

                                Break;
                              end;
                          end;

    // Fix Sizing
    if Form.Height < InfoIcon.Top + InfoIcon.Height + Footer.Height + FButtonOffset then
      Form.Height := InfoIcon.Top + InfoIcon.Height + Footer.Height + FButtonOffset;

    // Result
    Result := ModalExecution;
  end;
end;

{ CMessageBox }

constructor CMessageBox.Create;
begin
  inherited;
end;

destructor CMessageBox.Destroy;
begin
  inherited;
end;

procedure CMessageBox.Execute;
begin
  ExecuteInherited;

  with Form do begin
    Self.CreateButtons([mbOk]);

    FindButton( mrOk ).Default := true;

    ModalExecution;
  end;
end;

{ CInputBox }

constructor CInputBox.Create;
begin
  inherited;

  DialogResult := cidrCancel;

  FPasswordChar := #0;
  FNumbersOnly := false;
  FCanCancel := true;
end;

destructor CInputBox.Destroy;
begin
  inherited;
end;

function CInputBox.Execute: string;
var
  TextBox: TEdit;
begin
  ExecuteInherited;

  with Form do begin
    // Create Text Box
    TextBox := TEdit.Create(Form);
    with TextBox do
    begin
      Parent   := Form;

      Text := Value;

      Font.Assign( TextFont );
      Font.Size := Font.Size + 2;

      PasswordChar := FPasswordChar;
      NumbersOnly := FNumbersOnly;

      Color := ChangeColorSat(Form.Color,-10);

      Left := Prompt.Left;

      Top := Prompt.Top + Prompt.Height + FButtonOffset;

      Anchors := [akLeft, akTop];
    end;

    ResizeForm( -1, Form.ClientHeight + TextBox.Height + FButtonOffset * 2 );

    // Create Buttons
    if FCanCancel then
      CreateButtons( [mbOk, mbCancel] )
    else
      CreateButtons( [mbOk] );

    // Default Button
    FindButton( mrOK ).Default := true;
    if FCanCancel then
      with FindButton( mrCancel ) do
        begin
          Cancel := true;
        end;

    // Set Edit Width
    TextBox.Width := Form.ClientWidth - Prompt.Left * 2; // This is set after in case the Buttons span a langer distance that the Form

    if ModalExecution(false) = mrOk then
      begin
        DialogResult := cidrOk;
        Result := TextBox.Text
      end
    else
      begin
        DialogResult := cidrCancel;
        Result := Value;
      end;

    // Free
    FreeForm;
  end;
end;

{ CDialogBox }

function CDialogBox.ApplyTitleBarSettings(Form: TForm; FormColor: TColor;
  EnableButtons: boolean): integer;
var
  TextColor: TColor;
  ttl: TTitleBarPanel;
begin
  with Form do begin
    // Buttons
    if NOT EnableButtons then
      Form.BorderIcons := [];

    // 9X and XP compatability
    if NTKernelVersion < 6 then
      Exit(0);

    // Text Color
    if GetColorSat(FormColor) > 65 then
      TextColor := clBlack
    else
      TextColor := clWhite;

    // Create component
    ttl := TTitleBarPanel.Create(Form);
    with ttl do begin
      Parent := Form;
      Result := Height;
    end;

    // Apply settings
    with Form.CustomTitleBar do begin
      Enabled := true;
      Control := ttl;

      SystemColors := false;
      SystemButtons := false;

      BackGroundColor := FormColor;
      InactiveBackgroundColor := BackgroundColor;

      ForegroundColor := TextColor;
      InactiveForegroundColor := TextColor;

      ButtonBackgroundColor := BackgroundColor;
      ButtonInactiveBackgroundColor := BackgroundColor;
      ButtonForegroundColor := ForegroundColor;
      ButtonInactiveForegroundColor := ForegroundColor;
    end;

  end;
end;

function CDialogBox.ButtonTypeToIcon(AType: TMsgDlgBtn): CButtonIcon;
begin
  case AType of
    TMsgDlgBtn.mbYes: Result := cicYes;
    TMsgDlgBtn.mbNo: Result := cicNo;
    TMsgDlgBtn.mbOK: Result := cicTrueYes;
    TMsgDlgBtn.mbCancel: Result := cicNo;
    TMsgDlgBtn.mbAbort: Result := cicNoAllow;
    TMsgDlgBtn.mbRetry: Result := cicRetry;
    TMsgDlgBtn.mbIgnore: Result := cicNoAllow;
    TMsgDlgBtn.mbAll: Result := cicTrueYes;
    TMsgDlgBtn.mbNoToAll: Result := cicNo;
    TMsgDlgBtn.mbYesToAll: Result := cicYes;
    TMsgDlgBtn.mbHelp: Result := cicQuestion;
    TMsgDlgBtn.mbClose: Result := cicNo;
    else Result := cicNone;
  end;
end;

function CDialogBox.ButtonTypeToModal(AType: TMsgDlgBtn): integer;
begin
  case AType of
    TMsgDlgBtn.mbYes: Result := mrYes;
    TMsgDlgBtn.mbNo: Result := mrNo;
    TMsgDlgBtn.mbOK: Result := mrOK;
    TMsgDlgBtn.mbCancel: Result := mrCancel;
    TMsgDlgBtn.mbAbort: Result := mrAbort;
    TMsgDlgBtn.mbRetry: Result := mrRetry;
    TMsgDlgBtn.mbIgnore: Result := mrIgnore;
    TMsgDlgBtn.mbAll: Result := mrAll;
    TMsgDlgBtn.mbNoToAll: Result := mrNoToAll;
    TMsgDlgBtn.mbYesToAll: Result := mrYesToAll;
    TMsgDlgBtn.mbHelp: Result := mrHelp;
    TMsgDlgBtn.mbClose: Result := mrClose;
    else Result := mrNone;
  end;
end;

function CDialogBox.CalculateButtonHeight: integer;
var
  BT: CButton;
begin
  BT := CButton.Create(nil);
  try
    // Apply Stiling
    BT.ApplyButtonSettings( FButtonDesign );

    // Get Height
    Result := Bt.Height;
  finally
    BT.Free;
  end;
end;

constructor CDialogBox.Create;
begin
  // Style Default
  FButtonDesign := CButton.Create(nil);
  with FButtonDesign do begin
    Preset.Color := $00FFA028;
  end;

  // Font Default
  FTextFont := TFont.Create;
  with FTextFont do
  begin
    Name := 'Segoe UI';
    Size := 10;
    Color := clBlack;
  end;

  // Default Settings
  ExtraSpacingUnits := 0;

  PromptCreation := true;
  HasButtons := true;
  CustomFooterColor := false;

  FAutoTextAdjust := true;
  FFormColor := clWindow;
  FEnableFooter := true;
end;

procedure CDialogBox.CreateButtons(Buttons: TMsgDlgButtons);
var
  I: TMsgDlgBtn;
  Right,
  ATop: integer;
begin
  // Prepare Values
  Right := Form.ClientWidth;
  ATop := Form.ClientHeight - FButtonHeight - FButtonOffset;

  // Create
  for I in Buttons do
  with CButton.Create(Form) do
    begin
      Parent := Form;

      Anchors := [akRight,akBottom];
      Preset.IgnoreGlobalSync := NOT FToggleGlobalSync;

      Height := FButtonHeight;
      Width := GetButonWidth(Text, Self.FButtonDesign.Font);

      Top := ATop;
      Left := Right - Width - FButtonOffset;

      ModalResult := ButtonTypeToModal( I );

      Text := ButtonLabels[ Integer(I) ];
      ButtonIcon := ButtonTypeToIcon( I );

      ApplyButtonSettings( FButtonDesign );
      if (Preset.Kind = cbprFluent) then
        Preset.Kind := cbprCustom;

      if FEnableFooter then
        begin
          ParentColor := false;

          Pen.FormSyncedColor := false;
          Pen.Color := Footer.Color;
        end;

      // Next
      Right := Right - Width - FButtonOffset;
    end;

  // Extend Form Size
  if Right < FButtonOffset then
    begin
      Form.ClientWidth := Form.ClientWidth + abs(Right) + FButtonOffset;
      if Footer <> nil then
        Footer.Width := Form.ClientWidth;
    end;
end;

destructor CDialogBox.Destroy;
begin
  inherited;
  FreeAndNil(FTextFont);
end;

procedure CDialogBox.ExecuteInherited;
const
  UNITS_LEFT = 6;
var
  TextLength,
  TxtUnits_X,
  //TxtUnits_Y,
  PureValue: double;
  ShrinkLabel: boolean;
begin
  // Styled Form
  if FFormColor = clWindow then
    FFormColor := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);

  // Default
  Form   := TForm.Create(Application);
  with Form do
    begin
      // Form Settings
      Position    := poScreenCenter;
      BorderStyle := bsDialog;

      Caption := FTitle;

      Color := FFormColor;
      Font.Assign( FTextFont );
      Canvas.Font.Assign( FTextFont );

      // Dialog Units
      DialogUnits := GetCharSize(Canvas);

      // Text Adjust
      if FAutoTextAdjust then
        if EqualApprox( GetColorSat(TextFont.Color), GetColorSat(FormColor), 75) then
          begin
            if ColorToRGB( GetColorSat(FFormColor) ) > 155 then
              TextFont.Color := ChangeColorSat( TextFont.Color, -150 )
            else
              TextFont.Color := ChangeColorSat( TextFont.Color, 150 );
          end;

      // Apply Titlebar
      FTitlebarHeight := ApplyTitleBarSettings(Form, FormColor, true);

      // Init Size
      ClientHeight := FTitlebarHeight;
      ClientWidth := 0;

      // Create Prompt
      if PromptCreation then
        begin
          TextLength := Length ( FText );
          PureValue := TextLength / 80;
          //TxtUnits_Y := ceil( PureValue );

          if PureValue <= 1 then
            TxtUnits_X := TextLength
          else
            TxtUnits_X := (260 - UNITS_LEFT * 2) div 4;

          ShrinkLabel := (ExtraSpacingUnits > 0) and
                         (TxtUnits_X > (260 - ExtraSpacingUnits) div 4);

          Prompt      := TLabel.Create(Form);
          with Prompt do
          begin
            Parent   := Form;

            Caption  := FText;
            Font.Assign( FTextFont );

            Left     := MulDiv(UNITS_LEFT, DialogUnits.X, 2);
            Top      := MulDiv(1, DialogUnits.Y, 1) + FTitlebarHeight;

            Layout := tlCenter;

            Constraints.MaxWidth := MulDiv(trunc(TxtUnits_X), DialogUnits.X, 1);
            if ShrinkLabel then
              Constraints.MaxWidth := Constraints.MaxWidth - MulDiv(trunc(ExtraSpacingUnits), DialogUnits.X, 1);

            WordWrap := True;
          end;

          // Add Prompt Size
          ClientHeight := Height + Prompt.Top + Prompt.Height;
          ClientWidth := Prompt.Left * 2 + Prompt.Width + MulDiv(trunc(ExtraSpacingUnits), DialogUnits.X, 1);
        end;

      // Creat Footer
      if HasButtons then
        begin
          // Change form size
          FButtonHeight := PercOf( CalculateButtonHeight, 80 );
          Form.ClientHeight := Form.ClientHeight + FButtonHeight;

          FButtonOffset := MulDiv(1, DialogUnits.Y, 3);

          // Create Bottom
          Footer := TLabel.Create(Form);
          with Footer do
          begin
            Parent   := Form;

            Anchors := [akLeft, akBottom];

            AutoSize := false;
            Transparent := false;

            if CustomFooterColor then
              Color := FFooterColor
            else
              Color := ChangeColorSat(Form.Color,-20);

            Height := FButtonHeight + FButtonOffset * 2;
            Width := Form.ClientWidth;
            Left     := 0;
            Top      := Form.ClientHeight - Height;

            Visible := FEnableFooter;
          end;
        end;
    end;
end;

function CDialogBox.FindButton(ModalResult: integer): CButton;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Form.ControlCount - 1 do
    if Form.Controls[I] is CButton then
      if CButton(Form.Controls[I]).ModalResult = ModalResult then
        Result := CButton(Form.Controls[I]);
end;

procedure CDialogBox.FreeForm;
begin
  Form.Free;
end;

function CDialogBox.GetButonWidth(Text: string; Font: TFont): integer;
begin
  Result := GetTextWidth(Text, Font) + 50;
  if Result < 90 then
    Result := 90;
end;

function CDialogBox.GetCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of Char;
begin
  // Gets the avarage letter width
  for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;


function CDialogBox.GetTextWidth(Text: string; Font: TFont): integer;
var
  c: TBitMap;
begin
  c := TBitMap.Create;
  try
    c.Canvas.Font.Assign(Font);
    Result := c.Canvas.TextWidth(Text);
  finally
    c.Free;
  end;
end;

function CDialogBox.ModalExecution(FreeMem: boolean): integer;
begin
  // Execute Modal & Return value
  try
    Result := Form.ShowModal;
  finally
    // Free Memory
    if FreeMem then
      FreeForm;
  end;
end;

procedure CDialogBox.ResizeForm(NewWidth: integer; NewHeight: integer);
begin
  if NewWidth <> -1 then
    Form.ClientWidth := NewWidth;

  if NewHeight <> -1 then
    Form.ClientHeight := NewHeight;

  if footer <> nil then
    begin
      Footer.Width := Form.ClientWidth;
      Footer.Top := Form.ClientHeight - Footer.Height;
    end;
end;

procedure CDialogBox.SetButtonColor(AColor: TColor);
begin
  with FButtonDesign do
    begin
      UseAccentColor := CAccentColor.None;

      Colors.Leave := AColor;
      Colors.Enter := ChangeColorSat( AColor, 60 );
      Colors.Down := ChangeColorSat( AColor, -100 );
      Colors.BLine := Colors.Down;
    end;
end;

procedure CDialogBox.SetFooterColor(const Value: TColor);
begin
  FFooterColor := Value;

  CustomFooterColor := true;
end;

{ CButtonHelper }

procedure CButtonHelper.ApplyButtonSettings(LoadFromButton: CButton);
begin
  with Self do begin
    // Preset
    Preset.Color := LoadFromButton.Preset.Color;
    Preset.Kind := LoadFromButton.Preset.Kind;
    Preset.PenColorAuto := LoadFromButton.Preset.PenColorAuto;
    Preset.ApplyOnce := LoadFromButton.Preset.ApplyOnce;
    Preset.ApplyOnce := LoadFromButton.Preset.ApplyOnce;

    // Accent
    UseAccentColor := LoadFromButton.UseAccentColor;

    // Colors
    Colors.Leave := LoadFromButton.Colors.Leave;
    Colors.Enter := LoadFromButton.Colors.Enter;
    Colors.Down := LoadFromButton.Colors.Down;
    Colors.BLine := LoadFromButton.Colors.BLine;

    // Settings
    FlatButton := LoadFromButton.FlatButton;
    FlatComplete := LoadFromButton.FlatComplete;

    Cursor := LoadFromButton.Cursor;
    Font.Assign(LoadFromButton.Font);
    FontAutoSize := LoadFromButton.FontAutoSize;
    GradientOptions := LoadFromButton.GradientOptions;

    RoundAmount := LoadFromButton.RoundAmount;
    RoundTransparent := LoadFromButton.RoundTransparent;

    // Text Color
    TextColors.Leave := LoadFromButton.TextColors.Leave;
    TextColors.Enter := LoadFromButton.TextColors.Enter;
    TextColors.Down := LoadFromButton.TextColors.Down;
    TextColors.BLine := LoadFromButton.TextColors.BLine;

    // Underline
    UnderLine.UnderLineRound := LoadFromButton.UnderLine.UnderLineRound;
    UnderLine.UnderLineThicknes := LoadFromButton.UnderLine.UnderLineThicknes;
    UnderLine.Enable := LoadFromButton.UnderLine.Enable;
  end;
end;

{ CInputBoxDialog }

constructor CInputBoxDialog.Create;
begin
  inherited;

  Values := TStringList.Create;

  FCanCancel := true;
  FDropStyle := csDropDownList;

  DialogResult := cidrCancel;
end;

destructor CInputBoxDialog.Destroy;
begin
  inherited;
end;

function CInputBoxDialog.Execute: integer;
var
  Box: TComboBox;
begin
  ExecuteInherited;

  with Form do begin
    // Create Dropdown Box
    Box := TComboBox.Create(Form);
    with Box do
    begin
      Parent   := Form;

      Style := csDropDownList;

      Items.Assign( Values );

      ItemIndex := 0;

      Font.Assign( TextFont );
      Font.Size := Font.Size + 2;

      Color := ChangeColorSat(Form.Color,-10);

      Left := Prompt.Left;

      Top := Prompt.Top + Prompt.Height + FButtonOffset;

      Anchors := [akLeft, akTop];
    end;

    ResizeForm( -1, Form.ClientHeight + Box.Height + FButtonOffset * 2 );

    // Create Buttons
    if FCanCancel then
      CreateButtons( [mbOk, mbCancel] )
    else
      CreateButtons( [mbOk] );

    // Default Button
    FindButton( mrOK ).Default := true;
    if FCanCancel then
      with FindButton( mrCancel ) do
        begin
          Cancel := true;
        end;

    // Set Edit Width
    Box.Width := Form.ClientWidth - Prompt.Left * 2; // This is set after in case the Buttons span a langer distance that the Form

    if ModalExecution(false) = mrOk then
      begin
        DialogResult := cidrOk;

        SelectedText := Box.Text;
        SelectedIndex := Box.ItemIndex;
      end
    else
      begin
        DialogResult := cidrCancel;

        SelectedText := Box.Text;
        SelectedIndex := -1;
      end;

    Result := SelectedIndex;

    // Free Memory
    FreeForm;
  end;
end;

{ CRadioDialog }

constructor CRadioDialog.Create;
begin
  inherited;

  Items := TStringList.Create;

  FCanCancel := true;
  FSelectFirst := true;

  DialogResult := cidrCancel;
end;

destructor CRadioDialog.Destroy;
begin
  inherited;
end;

function CRadioDialog.Execute: integer;
var
  Boxes: TArray<TRadioButton>;
  ATop, AHeights, ACircleRect, TWidth, LargestWidth, I: integer;
begin
  ExecuteInherited;

  with Form do begin
    // Create Radio Boxes
    ATop := Prompt.Top + Prompt.Height + FButtonOffset;
    LargestWidth := 0;
    AHeights := 0;

    SetLength( Boxes, Items.Count );

    for I := 0 to Items.Count - 1 do
      begin
        Boxes[I] := TRadioButton.Create(Form);
        with Boxes[I] do
        begin
          Parent   := Form;

          if (SelectFirst or not CanCancel) and (I = 0) then
            Checked := true;

          Hint := Items[I];

          // Font Color only works with VCL Styling off!
          Caption := '';

          Font.Assign( TextFont );
          Font.Size := Font.Size + 2;

          Color := ChangeColorSat(Form.Color,-10);

          ACircleRect := Height;

          Height := ceil(Height * 1.5);

          Width := Form.Width - Prompt.Left * 2;

          Left := Prompt.Left;

          Anchors := [akLeft, akTop];

          Top := ATop;
          ATop := ATop + Height;
          AHeights := AHeights + Height;

          // Create Text Label
          with TLabel.Create(Form) do
            begin
              Parent := Form;

              Caption := Items[I];

              Font.Assign( TextFont );
              Font.Size := Font.Size + 2;

              Layout := tlCenter;

              Top := Boxes[I].Top;
              Left := Boxes[I].Left + ACircleRect;
              Constraints.MinHeight := Boxes[I].Height;
              Width := 1000;

              TWidth := Self.GetTextWidth(Caption, Font) + Left;
              if TWidth > LargestWidth then
                LargestWidth := TWidth;

              SendToBack;
            end;
        end;
      end;

    ResizeForm( -1, Form.ClientHeight + AHeights + FButtonOffset * 2 );

    // Create Buttons
    if FCanCancel then
      CreateButtons( [mbOk, mbCancel] )
    else
      CreateButtons( [mbOk] );

    // Resize
    if LargestWidth > Form.ClientWidth then
      Form.ClientWidth := LargestWidth;

    // Default Button
    FindButton( mrOK ).Default := true;
    if FCanCancel then
      with FindButton( mrCancel ) do
        begin
          Cancel := true;
        end;

    if ModalExecution(false) = mrOk then
      begin
        DialogResult := cidrOk;

        for I := 0 to Length( Boxes ) - 1 do
          if Boxes[I].Checked then
            begin
              SelectedIndex := I;
              SelectedText := Boxes[I].Hint;

              Break;
            end;
      end
    else
      begin
        DialogResult := cidrCancel;

        SelectedIndex := -1;
      end;

    Result := SelectedIndex;

    // Free Memory
    FreeForm;
  end;
end;

{ CMemoBox }

constructor CMemoBox.Create;
begin
  inherited;

  FBoxWidth := 500;
  FBoxHeight := 300;
  DialogResult := cidrCancel;

  FValue := TStringList.Create;

  FCanCancel := true;
end;

destructor CMemoBox.Destroy;
begin
  inherited;
  FValue.Free;
end;

function CMemoBox.Execute: boolean;
var
  Text: TRichEdit;
begin
  ExecuteInherited;

  with Form do begin
    // Create Text Box
    Text := TRichEdit.Create(Form);
    with Text do
    begin
      Parent   := Form;

      Lines.Assign( Value );

      Font.Assign( TextFont );
      Font.Size := Font.Size + 2;

      Color := ChangeColorSat(Form.Color,-10);

      Left := Prompt.Left;

      Top := Prompt.Top + Prompt.Height + FButtonOffset;
      Height := FBoxHeight;

      Anchors := [akLeft, akTop];
    end;

    ResizeForm( FBoxWidth, Form.ClientHeight + Text.Height + FButtonOffset * 2 );

    // Create Buttons
    if FCanCancel then
      CreateButtons( [mbOk, mbCancel] )
    else
      CreateButtons( [mbOk] );

    // Default Button
    FindButton( mrOK ).Default := true;
    if FCanCancel then
      with FindButton( mrCancel ) do
        begin
          Cancel := true;
        end;

    // Set Edit Width
    Text.Width := Form.ClientWidth - Prompt.Left * 2; // This is set after in case the Buttons span a langer distance that the Form

    if ModalExecution(false) = mrOk then
      begin
        DialogResult := cidrOk;
        Result := true;
        Value.Assign( Text.Lines );
      end
    else
      begin
        DialogResult := cidrCancel;
        Result := false;
      end;

    // Free Memory
    FreeForm;
  end;
end;

function CMemoBox.GetAsText: string;
begin
  Result := FValue.Text;
end;

procedure CMemoBox.SetAsText(const Value: string);
begin
  FValue.Text := Value;
end;

end.
